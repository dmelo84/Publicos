#Include 'Protheus.ch'
#Include 'TbiConn.ch'
#Include 'RestFul.CH'
#include "tryexception.ch"
#Include 'FwMVCDef.ch'

#Define CODIGO 		1
#Define DESCRICAO	2

#Define IMPORT_PRODUTO	1
#Define IMPORT_PREPROD	2
#Define IMPORT_PRINCAT	3
#Define IMPORT_COMPLEM	4

/*
=====================================================================================
|Programa: RFLUW009    |Autor: Wanderley R. Neto                   |Data: 15/11/2019|
=====================================================================================
|Descrição: Web Service para consulta e integração dos Produtos ao Protheus         |
|                                                                                   |
=====================================================================================
|CONTROLE DE ALTERAÇÕES:                                                            |
=====================================================================================
|Programador          |Data       |Descrição                                        |
=====================================================================================
|                     |           |                                                 |
=====================================================================================
*/
User Function RFLUW009();Return Nil

WsRestFul Produtos DESCRIPTION "Serviço REST para listagem e atualização dos produtos"

	WsData produto	as String
	WsData tipo		as String

	WsMethod GET DESCRIPTION "Retorna a lista de Produtos disponíveis na base" WSSYNTAX "/produtos || /produtos/tipo= || /produtos/produto="
	WsMethod POST DESCRIPTION "Inclui um novo Produto na base do Protheus" WSSYNTAX "/produtos/{}"

End WsRestFul

/*
=====================================================================================
|Programa: RFLUW009    |Autor: Wanderley R. Neto                   |Data: 16/12/2019|
=====================================================================================
|Descrição: Método GET para consulta do produtos. É possível filtrar por código de  |
| produto e tipo                                                                    |
| ex: http://192.168.9.17:8012/api/produtos?produto=I212.200.SP.002                 |
=====================================================================================
*/
WsMethod GET WsReceive produto, tipo WsService Produtos

	Local oProduto	:= ListaProduto():New()
	Local cCodBusca	:= ::produto
	Local cTipoBusca:= ::tipo
	Local nProd		:= 0
	Local aProd		:= {}
	Local cRet		:= ''

	Reset Environment
	RPCSetType(3)  //Nao consome licensas
	Prepare Environment Empresa '01' Filial '01'
	
	::SetContentType("application/json")

	DbSelectArea('SB1')
	SB1->(DbSetOrder(1))

	// Busca os produtos de acordo com o parametros recbidos.
	aProd := BuscaProd(cCodBusca, cTipoBusca)

	// --------------------------------------------------
	// Gera listagem dos produtos
	// --------------------------------------------------
	For nProd := 1 To Len(aProd)
	
		oProduto:Adicionar(aProd[nProd, CODIGO],EncodeUtf8(aProd[nProd, DESCRICAO]))
	
	Next nProd

	cRet := FWJsonSerialize(oProduto)
	Conout('RFLUW009'+' - '+DToC(dDataBase)+' '+Time()+'| Realizada consulta de Produtos.')
	::SetResponse(cRet)

	Reset Environment

Return .T.

/*
=====================================================================================
|Programa: RFLUW009    |Autor: Wanderley R. Neto                   |Data: 22/11/2019|
=====================================================================================
|Descrição: Funçao para buscar os produtos de acordo com os parametros enviados pela|
| API                                                                               |
=====================================================================================
*/
Static Function BuscaProd(cCod, cTipo)

Local aProd		:= {}
Local cQUery	:= ''
Local cAliasTmp	:= GetNextAlias()

cQuery += CRLF + " SELECT B1_COD, B1_DESC "
cQuery += CRLF + "   FROM "+RetSqlName('SB1')
cQuery += CRLF + "  WHERE D_E_L_E_T_ = '' "

Do Case

	Case !Empty(cCod)
		cQuery += CRLF + "    AND B1_COD = '"+cCod+"'"

	Case !Empty(cTipo)
		cQuery += CRLF + "    AND B1_TIPO = '"+cTipo+"'"

EndCase

dbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasTmp,.F., .F.)

While (cAliasTmp)->( ! Eof() )

	AAdd(aProd, {;
				(cAliasTmp)->B1_COD,;	// CODIGO
				(cAliasTmp)->B1_DESC;	// DESCRICAO
				})

	(cAliasTmp)->( DbSkip() )
End

(cAliasTmp)->(dbCloseArea())

Return aProd

/*
=====================================================================================
|Programa: RFLUW009    |Autor: Wanderley R. Neto                   |Data: 16/12/2019|
=====================================================================================
|Descrição: Classe de listagem de produtos para retorno via JSON                    |
|                                                                                   |
=====================================================================================
*/
Class ListaProduto

	Data Produtos

	MEthod New() Constructor
	Method Adicionar(cCodigo, xValor) 

EndClass

Method New() Class ListaProduto

	::Produtos := {}

Return Self

Method Adicionar(cCodigo, xValor) Class ListaProduto

	Local oDado := DadosTabela():New(cCodigo, xValor)
	AAdd(::Produtos, oDado)

Return Self

/*
=====================================================================================
|Programa: RFLUW009    |Autor: Wanderley R. Neto                   |Data: 25/11/2019|
=====================================================================================
|Descrição: Metodo de integração para inclusão de novo produto via Fluig. Recebe um |
| JSON via post.                                                                    |
=====================================================================================
*/
WsMethod POST WsService Produtos

	Local cJsonPost	:= Self:GetContent()		// Recupera o JSON enviado via POST
	Local oJson		:= Nil
	Local cNovoProd	:= ''
	Local xValor	:= ''
	Local cMsg		:= ''
	Local lRet		:= .T.
	Local bError	:= { |oError| (	DisarmTransaction(),;
									SetRestFault(500,'Erro na rotina de integração de produtos via Fluig.'),;
									RpcClearEnv(),;
									lRet :=  .F.) }


	Reset Environment
	RPCSetType(3)  //Nao consome licensas
	Prepare Environment Empresa '01' Filial '01'

	If !Empty(cJsonPost)

		FwJSONDeserialize(cJsonPost,@oJson)
		
		TRYEXCEPTION USING bError

			// Obtem array de inclusoes (Produto/Pre-Produto/Princ Ativo/Complementos)
			aProp := ObtemDados(oJson:params)
		
		CATCHEXCEPTION USING oError

			SetRestFault(500,EncodeUtf8('Erro no obtenção dos dados.'))
			Reset Environment
			Return .F.

		ENDEXCEPTION

		Begin Transaction

			// ---------------------------------------------------------------
			// CADASTRO DE PRINCIPIO ATIVO
			// ---------------------------------------------------------------
			TRYEXCEPTION USING bError

				// Cadastra novo Principio Ativo
				If !Empty(aProp[IMPORT_PRINCAT])
					CadPrAtiv(aProp[IMPORT_PRINCAT])
				EndIf

			CATCHEXCEPTION USING oError

				DisarmTransaction()	
				SetRestFault(500,'Erro no processamento do Principio Ativo.')
				Reset Environment
				Return .F.

			ENDEXCEPTION

			// ---------------------------------------------------------------
			// CADASTRO DE PRÉ-PRODUTO
			// ---------------------------------------------------------------
			TRYEXCEPTION USING bError

				// Cadastra novo Pre Produto
				If !Empty(aProp[IMPORT_PREPROD])
					lRet := CadProd(aProp[IMPORT_PREPROD], .T., @cMsg)
				EndIf

				If !lRet 
					DisarmTransaction()					
					SetRestFault(500,cMsg)
					Reset Environment
					Return .F.
				EndIf

			CATCHEXCEPTION USING oError

				If Empty(cMsg)
					cMsg := EncodeUtf8('Erro no processamento do Pré Produto.')
				EndIf

				DisarmTransaction()	
				SetRestFault(500,cMsg)
				Reset Environment
				Return .F.

			ENDEXCEPTION

			// ---------------------------------------------------------------
			// CADASTRO DE PRODUTOS
			// ---------------------------------------------------------------
			TRYEXCEPTION USING bError
			
				If !Empty(aProp[IMPORT_PRODUTO])
					lRet := CadProd(aProp[IMPORT_PRODUTO], .F., @cMsg)
				EndIf

				If !lRet 
					If 'produto não é válido para inclusão' $ cMsg
						// Tratamento especial quando produto já existe.
						// Atividade será concluida no Fluig e usuários serão notificados que o código já existe no Protheus.
						nCodErr := 501
						
					Else	
						nCodErr := 500
					EndIf
					DisarmTransaction()					
					SetRestFault(nCodErr,cMsg)
					Reset Environment
					Return .F.
				EndIf

			CATCHEXCEPTION USING oError
			
				DisarmTransaction()	
				SetRestFault(500,'Erro no processamento do Produto.')
				Reset Environment
				Return .F.

			ENDEXCEPTION

			// ---------------------------------------------------------------
			// CADASTRO DE COMPLEMENTO DE PRODUTO
			// ---------------------------------------------------------------
			TRYEXCEPTION USING bError
				cMsg := ''
				
				If !Empty(aProp[IMPORT_PRODUTO])
					lRet := CadCompl(aProp[IMPORT_COMPLEM], @cMsg)
				EndIf

				If !lRet 
					DisarmTransaction()					
					SetRestFault(500,cMsg)
					Reset Environment
					Return .F.
				EndIf

			CATCHEXCEPTION USING oError
			
				If Empty(cMsg)
					cMsg := 'Erro no processamento do Complemento do Produto.'
				EndIf
				DisarmTransaction()	
				SetRestFault(500,cMsg)
				Reset Environment
				Return .F.

			ENDEXCEPTION
		End Transaction

	Else
		SetRestFault(400,'JSON inválido ou vazio')
	EndIf

	Reset Environment

Return lRet

/*
=====================================================================================
|Programa: RFLUW009    |Autor: Wanderley R. Neto                   |Data: 25/11/2019|
=====================================================================================
|Descrição: Realiza o De/Para entre as propriedades envaidas pelo Fluig e o campo   |
| correspondente no Protheus.                                                       |
=====================================================================================
*/
Static Function DPProtheus(cCampo,nCpo)
Local cCpoProt		:= ''
DEFault nCpo := 1
Do Case
	Case cCampo == 'codigo'
		cCpoProt := 'B1_COD'
	Case cCampo == 'descricao'
		cCpoProt := 'B1_DESC'
	Case cCampo == 'tipo'
		cCpoProt := 'B1_TIPO'
	Case cCampo == 'armazem'
		cCpoProt := 'B1_LOCPAD'
	Case cCampo == 'grupo'
		cCpoProt := 'B1_GRUPO'
	Case cCampo == 'formulacao'
		cCpoProt := 'B1_XFORMUL'
	Case cCampo == 'classe'
		cCpoProt := 'B1_XCLASSE'
	Case cCampo == 'unimed'	
		cCpoProt := 'B1_UM'
	Case cCampo == 'segunimed'
		cCpoProt := 'B1_SEGUM'
	Case cCampo == 'concentracao'
		cCpoProt := 'B1_XCONCEN'
	Case cCampo == 'fabricante'
		// If nCpo == 1
			cCpoProt := 'B1_XCODFAB'
		// Else
		// 	cCpoProt := 'B1_XLOJFAB'
		// EndIf
	Case cCampo == 'registrante'
		cCpoProt := 'B1_XREGIST'
	Case cCampo == 'bloqueio'
		cCpoProt := 'B1_MSBLQL'
	Case cCampo == 'infcomp'
		cCpoProt := 'B1_XCOMP'
	Case cCampo == 'pesoliq'
		cCpoProt := 'B1_PESO'
	Case cCampo == 'pesobru'
		cCpoProt := 'B1_PESBRU'
	Case cCampo == 'fatconver'
		cCpoProt := 'B1_CONV'
	Case cCampo == 'tipconver'
		cCpoProt := 'B1_TIPCONV'
	Case cCampo == 'rastro'
		cCpoProt := 'B1_RASTRO'
	Case cCampo == 'ncm'
		cCpoProt := 'B1_POSIPI'
	Case cCampo == 'prodimp'
		cCpoProt := 'B1_IMPORT'
	Case cCampo == 'prodind'
		cCpoProt := 'B1_INDUSTR'
	Case cCampo == 'quantemb'
		cCpoProt := 'B1_QE'
	Case cCampo == 'quantemb2'
		cCpoProt := 'B5_QE1'
	Case cCampo == 'emb'
		cCpoProt := 'B5_EMB1'
	Case cCampo == 'contacontab'
		cCpoProt := 'B1_CONTA'
	Case cCampo == 'itemcontab'
		cCpoProt := 'B1_ITEMCC'
	Case cCampo == 'ccusto'
		cCpoProt := 'B1_CC'
	Case cCampo == 'ativocontab'
		cCpoProt := 'B1_ATIVO'
	Case cCampo == 'origem'
		cCpoProt := 'B1_ORIGEM'
	Case cCampo == 'gruptrib'
		cCpoProt := 'B1_GRTRIB'
	Case cCampo == 'codtribmun'
		cCpoProt := 'B1_TRIBMUN'
	Case cCampo == 'imprend'
		cCpoProt := 'B1_IRRF'
	Case cCampo == 'foraest'
		cCpoProt := 'B1_FORAEST'
	Case cCampo == 'classfisc'
		cCpoProt := 'B1_CLASFIS'
	Case cCampo == 'perccsll'
		cCpoProt := 'B1_PCSLL'
	Case cCampo == 'percconf'
		cCpoProt := 'B1_PCOFINS'
	Case cCampo == 'percpis'
		cCpoProt := 'B1_PPIS'
	Case cCampo == 'aliqicms'
		cCpoProt := 'B1_PICM'
	Case cCampo == 'aliqipi'
		cCpoProt := 'B1_IPI'
	Case cCampo == 'aliqiss'
		cCpoProt := 'B1_ALIQISS'
	Case cCampo == 'codserviss'
		cCpoProt := 'B1_CODISS'
	Case cCampo == 'formretiss'
		cCpoProt := 'B1_FRETISS'
	Case cCampo == 'percredinss'
		cCpoProt := 'B1_REDINSS'
	Case cCampo == 'percredirff'
		cCpoProt := 'B1_REDIRRF'
	Case cCampo == 'percredpis'
		cCpoProt := 'B1_REDPIS'
	Case cCampo == 'percredconf'
		cCpoProt := 'B1_REDCOF'
	Case cCampo == 'calcinss'
		cCpoProt := 'B1_INSS'
	Case cCampo == 'esptipi'
		cCpoProt := 'B1_ESPECIE'
	Case cCampo == 'exncm'
		cCpoProt := 'B1_EX_NCM'
	Case cCampo == 'tepadrao'
		cCpoProt := 'B1_TE'
	Case cCampo == 'tspadrao'
		cCpoProt := 'B1_TS'
	Case cCampo == 'retempis'
		cCpoProt := 'B1_PIS'
	Case cCampo == 'retemconf'
		cCpoProt := 'B1_COFINS'
	Case cCampo == 'retemcsll'
		cCpoProt := 'B1_CSLL'
	Case cCampo == 'cnae'
		cCpoProt := 'B1_CNAE'
	Case cCampo == 'credicms'
		cCpoProt := 'B1_CRICMS'
	Case cCampo == 'tabnatrec'
		cCpoProt := 'B1_TNATREC'
	Case cCampo == 'sittrib'
		cCpoProt := 'B1_SITTRIB'
	Case cCampo == 'retornoop'
		cCpoProt := 'B1_RETOPER'
	Case cCampo == 'rastroativo'
		cCpoProt := 'B1_RSATIVO'
	Case cCampo == 'princativo'
		cCpoProt := 'B5_XPRINCI'
	Case cCampo == 'nomecientif'
		cCpoProt := 'B5_CEME'
	Case cCampo == 'preprod'
		cCpoProt := 'B1_XPREPRO'
	Case cCampo == 'descricao_complementar'
		cCpoProt := 'descricao_complementar'
	Case cCampo == 'anuente'
		cCpoProt := 'B1_ANUENTE'	
EndCase

Return cCpoProt

/*
=====================================================================================
|Programa: RFLUW009    |Autor: Wanderley R. Neto                   |Data: 28/11/2019|
=====================================================================================
|Descrição: Grava log com json recebido da integração                               |
| >> Função para debug/teste <<                                                     |
=====================================================================================
*/
Static Function GrvJson(cJson)

Local nFile := FCreate("json_produto.txt") 

If nFile == -1
	MsgAlert("O Arquivo não foi criado:" + STR(FERROR()))
Else
	FWrite(nFile, cJson)
	FClose(nFile)
EndIf

Return 

/*
=====================================================================================
|Programa: RFLUW009    |Autor: Wanderley R. Neto                   |Data: 02/12/2019|
=====================================================================================
|Descrição: Obtem os dados do Json e estrutura array para processamento dos cadastros
|                                                                                   |
=====================================================================================
*/
Static Function ObtemDados(aParams)

Local aProp		:= ClassDataArr( aParams )
Local aImport	:= Array(4)
Local nProp		:= 0
Local nInt		:= 0
Local aTmp		:= {}
Local nPosPrePr	:= AScan(aProp, {|x| lower(x[1]) == 'preprod' })
Local lCadPP	:= aProp[nPosPrePr,2]:cadPreProd

// Campo do Complemento de Produto
Local cCpoComp1	:= 'quantemb2'
Local cCpoComp2	:= 'emb'
Local cCpoComp3	:= 'descricao_complementar'
// Campos do Pre Produto
Local cCpoPP	:= 'codigo|descricao|tipo|unimed|armazem|grupo|segunimed|fatconver|tipconver|contacontab|itemcontab|prodimp|prodind|origem|gruptrib|'
Local cAuxDesc	:= ''
Local nTamDesc	:= ''
Local nContDesc	:= ''

If lCadPP
	aImport[IMPORT_PREPROD] := {}
EndIf
aImport[IMPORT_PRODUTO] := {}
aImport[IMPORT_COMPLEM] := {}

For nProp := 1 To Len(aProp)

	Do Case
		Case lower(aProp[nProp,1]) == 'princativo'

			// -------------------------------------------------------------
			// Adiciona propriedades do Principio ativo a ser cadastrado
			// -------------------------------------------------------------
			If aProp[nProp,2]:cadPrincpAtivo

				aImport[IMPORT_PRINCAT] := Array(2)
				aImport[IMPORT_PRINCAT,1] := aProp[nProp,2]:codigo
				aImport[IMPORT_PRINCAT,2] := DecodeUTF8(aProp[nProp,2]:descricao)
			
				Aadd(aImport[IMPORT_COMPLEM],{'princativo',aProp[nProp,2]:codigo,0})
				Aadd(aImport[IMPORT_COMPLEM],{'nomecientif',DecodeUTF8(aProp[nProp,2]:descricao),0})
			
			Else

				Aadd(aImport[IMPORT_COMPLEM],{'princativo',aProp[nProp,2]:codigo,0})
				Aadd(aImport[IMPORT_COMPLEM],{'nomecientif',Posicione('ZZ3',1,xFilial('ZZ3')+aProp[nProp,2]:codigo,'ZZ3_DESCPR'),0})

			EndIf


		Case lower(aProp[nProp,1]) == cCpoComp1 .Or. lower(aProp[nProp,1]) == cCpoComp2
			Aadd(aImport[IMPORT_COMPLEM],aClone(aProp[nProp]))

		Case lower(aProp[nProp,1]) == cCpoComp3 .And. !Empty(aProp[nProp,2])

			cAuxDesc := AllTrim(aProp[nProp,2])
			nTamDesc := Len(cAuxDesc)
			nContDesc := 0

			While nTamDesc > 0  
				
				nContDesc++

				Aadd(aImport[IMPORT_COMPLEM],{'B5_XDESCR'+cValToChar(nContDesc),SubString(cAuxDesc,1,TamSX3('B5_XDESCR1')[1]),0})

				cAuxDesc := Stuff(cAuxDesc,1,TAmSX3('B5_XDESCR1')[1],'')

				nTamDesc := Len(cAuxDesc)
				
				If nContDesc == 7 // Qtd de campos de descricao
					Exit // Sai do loop
				EndIf

			End

		Otherwise

			If lower(aProp[nProp,1]) <> 'preprod'
				// -------------------------------------------------------------
				// Adiciona propriedades do Produto a ser cadastrado
				// -------------------------------------------------------------
				Aadd(aImport[IMPORT_PRODUTO],aClone(aProp[nProp]))

				If Lower(aProp[nProp,1]) == 'codigo'
					Aadd(aImport[IMPORT_COMPLEM],{'B5_COD',aProp[nProp,2],0})
				EndIf
				

				If lCadPP
					If Lower(aProp[nProp,1]) $ cCpoPP

						Aadd(aImport[IMPORT_PREPROD],aClone(aProp[nProp]))

						If Lower(aProp[nProp,1]) == 'codigo'
							aImport[IMPORT_PREPROD,len(aImport[IMPORT_PREPROD]),2] := aProp[nPosPrePr,2]:codigo

						ElseIf Lower(aProp[nProp,1]) == 'tipo'
							// Define Tipo Padrão dos pre produtos = 'AT'
							aImport[IMPORT_PREPROD,len(aImport[IMPORT_PREPROD]),2] := 'AT'

						ElseIf Lower(aProp[nProp,1]) == 'descricao'
							aImport[IMPORT_PREPROD,len(aImport[IMPORT_PREPROD]),2] := aProp[nPosPrePr,2]:descricao

						EndIf

					EndIf
				EndIf
			Else
				Aadd(aImport[IMPORT_PRODUTO],{'preprod',aProp[nPosPrePr,2]:codigo,0})
			EndIf

	EndCase

Next nProp

Return aImport

/*
=====================================================================================
|Programa: RFLUW009    |Autor: Wanderley R. Neto                   |Data: 02/12/2019|
=====================================================================================
|Descrição: Realiza o cadastro do Principio Ativio                                  |
|                                                                                   |
=====================================================================================
*/
Static FUnction CadPrAtiv(aPrAtivo)

DbSelectArea('ZZ3')
ZZ3->(DbSetOrder(1))

If ! ZZ3->( DbSeek( xFilial('ZZ3') + aPrAtivo[1] ) )

	RecLock('ZZ3', .T.)

		ZZ3->ZZ3_COD	:= aPrAtivo[1]
		ZZ3->ZZ3_DESCPR	:= aPrAtivo[2]

	ZZ3->(MsUnlock())

EndIf

Return

/*
=====================================================================================
|Programa: RFLUW009    |Autor: Wanderley R. Neto                   |Data: 05/12/2019|
=====================================================================================
|Descrição: Função para efetuar o cadastramento de um produto/pré-produto na base   |
| com base no array montado a partir do json enviado pela integração.               |
=====================================================================================
*/
Static Function CadProd(aProduto, lPreProd, cMsg)

	Local oProduto	:= myProduto():New(3)	// Objeto que cadastrará o novo produto
	Local nProp		:= 0
	Local cCpoProt	:= ''
	Local lRet		:= .T.

	Default lPreProd := .F.

	DbSelectArea('SB1')
	SB1->(DbSetOrder(1))
	DbSelectArea('SX3')
	SX3->(DbSetOrder(2))

	// ---------------------------------------------------------------
	// Varre propriedades enviadas para preencher campos do Produto
	// ---------------------------------------------------------------
	For nProp := 1 To Len(aProduto)

		// Rotina de/para de propriedades JSON/Protheus
		cCpoProt := DPProtheus(Lower(aProduto[nProp, 1]))
		cCpoProt := Padr(cCpoProt, 10)

		If SX3->( DbSeek( cCpoProt ) )


			// xValor := &('oJson:params:'+AllTrim(aProduto[nProp,1]))
			xValor := DecodeUTF8(aProduto[nProp,2])

			Do Case

				Case SX3->X3_TIPO == 'N'
					xValor := Val(xValor)

				Case SX3->X3_TIPO == 'D'
					xValor := SToD(xValor)
				
			EndCase
		
			// Adiciona campos baseado no JSON
			oProduto:AddCampo(cCpoProt,xValor)
			
			If AllTrim(cCpoProt) == 'B1_COD'

				// Valida Codigo
				lRet := oProduto:ValidaCod(xValor,.F.)
				cNovoProd := xValor

				If !lRet

					cMsg := 'Código de '+iif(lPreProd,'pré ','')+'produto não é válido para inclusão.'
					Exit

				EndIf
			
			EndIf
		EndIf


	Next nProp

	oProduto:AddCampo('B1_GARANT','2')
	If lRet
		If !oProduto:Gravar()
			lRet := .F.
			cMsg := EncodeUtf8('Erro na gravação do '+iif(lPreProd,'pré ','')+'Produto.')
			Conout('RFLUW009'+' - '+DToC(dDataBase)+' '+Time()+'| '+iif(lPreProd,'Pré ','')+'Produto '+cNovoProd+' não foi gravado:'+CRLF+;
						oProduto:InfoErro() )
		EndIf
	EndIf

Return lRet

/*
=====================================================================================
|Programa: RFLUW009    |Autor: Wanderley R. Neto                   |Data: 05/12/2019|
=====================================================================================
|Descrição: Rotina de cadstramento do complemento de produtos segundo dados informa-|
| dos via integração                                                                |
=====================================================================================
*/
Static Function CadCompl(aCompl, cMsg)

Local oModel	:= Nil
Local nPosCod	:= ASCan(aCompl, {|x| AllTrim(x[1])=='B5_COD'})
Local cCodProd	:= ''
Local nCpo		:= 0

If nPosCod > 0
	cCodProd := aCompl[nPosCod,2]
EndIf

DbSelectArea('ZZ3')
DbSelectArea('SB5')

oModel := FwLoadModel("MATA180")
oModel:SetOperation(MODEL_OPERATION_INSERT)
oModel:Activate()

oModel:SetValue("SB5MASTER","B5_COD"    ,cCodProd)

DbSelectArea('SX3')
SX3->(DbSetOrder(2))

For nCpo := 1 To Len(aCompl)

	If ! AllTrim(aCompl[nCpo,1]) $ 'B5_COD'
		If 'B5_XDESC' $ aCompl[nCpo, 1]
			cCpoProt := aCompl[nCpo, 1]
		Else
			cCpoProt := DPProtheus(Lower(aCompl[nCpo, 1]))
		EndIf

		cCpoProt := Padr(cCpoProt, 10)

		If SX3->( DbSeek( cCpoProt ) )

			xValor := aCompl[nCpo,2]

			Do Case

				Case SX3->X3_TIPO == 'N'
					xValor := Val(xValor)

				Case SX3->X3_TIPO == 'D'
					xValor := SToD(xValor)
				
			EndCase

			oModel:SetValue("SB5MASTER",cCpoProt,xValor)

		EndIf
	EndIf	

Next nCpo

If oModel:VldData()
	If oModel:CommitData()
		Conout('RFLUW009'+' - '+DToC(dDataBase)+' '+Time()+'| Complemento de PRoduto incluido')
		lRet := .T.
	Else
		Conout('RFLUW009'+' - '+DToC(dDataBase)+' '+Time()+'| Falha na inclusão do Complemento de Produto')
		lRet := .F.
	EndIf
Else
	cMsg := EncodeUtf8('Falha ao incluir complemento de produto: '+oModel:GetErrorMessage()[4]+'-'+oModel:GetErrorMessage()[6])
	Conout('RFLUW009'+' - '+DToC(dDataBase)+' '+Time()+'| Falha ao incluir complemento de produto: '+oModel:GetErrorMessage()[4]+'-'+oModel:GetErrorMessage()[6])
	lRet := .F.
EndIf

oModel:DeActivate()
oModel:Destroy()
oModel := NIL

Return lRet
