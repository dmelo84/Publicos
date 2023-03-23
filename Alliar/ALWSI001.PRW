#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"
#INCLUDE "TOPCONN.CH"
//#INCLUDE "ALWSI001.CH"

Static cMsgLog	:= ""

User Function ALWSI001()
Return NIL
//-------------------------------------------------------------------
/*{Protheus.doc} WsIntegracaoFluig
Web Service de Integracao Protheus x Fluig

@author Totvs
@since 19/01/2016
@version P12
*/
//-------------------------------------------------------------------
WSSERVICE wsIntegracaoFluig DESCRIPTION "FSW - Integração entre Fluig e Protheus" NAMESPACE XNAMESPACE
	
	//Atributos
	
	//Consultas
	WSDATA SColaborador  		AS FSENVColaborador
	WSDATA SBeneficio    		AS FSENVBeneficio
	WSDATA SPedidoCompra 		AS FSENVPedidoCompra
	WSDATA SPreNFE       		AS FSENVPreNFE
	WSDATA SCancPreNFE       	AS FSENVCancPreNFE
	WSDATA SFilial       		AS FSENVFilial
	WSDATA SEmail        		AS FSENVEmail
	WSDATA SDataPreNFE   		AS FSENVDataPreNFE
	WSDATA SEmpresa      		AS FSENVEmpresa
	
	//Cadastros
	WSDATA SFornecedor        	AS FSENVFornecedor
	WSDATA SAfastamento       	AS FSENVAfastamento
	WSDATA SPNFEntrada        	AS FSENVPNFEntrada
	WSDATA STrocaTurno        	AS FSENVTrocaTurno
	WSDATA SAcidenteTrabalho  	AS FSENVAcidenteTrabalho
	WSDATA SSolicitacaoCompra 	AS FSENVSolicitacaoCompra
	WSDATA SProgramacaoFerias 	AS FSENVProgramacaoFerias
	WSDATA SProduto           	AS FSENVProduto
	WSDATA SMovimentoBancario 	AS FSENVMovimentoBancario
	WSDATA SAprovacaoPC       	AS FSENVAprovacaoPC
	WSDATA SCadBeneficio      	AS FSENVCadBeneficio
	WSDATA SCadAdmissao       	AS FSENVCadAdmissao
	WSDATA SMovPessoal        	AS FSENVMovPessoal
	
	//Retorno do Ws
	WSDATA SRetorno 				AS FSRETFLUIG
	
	//Retorno do colaborador
	WSDATA SRetornoColaborador 	AS FSRETColaborador
	
	//Retorno do benefício
	WSDATA SRetornoBeneficio 	AS FSRETBeneficio
	
	//Retorno do pedido de compra
	WSDATA SRetPedCom	AS ARRAY OF FSRetPCom
	
	//Retorno da Consulta de Pre-NFE
	WSDATA SRetornoPreNFE 		AS ARRAY OF FSRETPreNFE
	
	//Retorno da Consulta de Empresa
	WSDATA SRetornoFilial 		AS ARRAY OF FSRETFilial
	
	//Retorno da Consulta de E-mail aprovadores do pedido
	WSDATA SRetornoEmail 		AS ARRAY OF FSRETEmail
	
	//Retorno da Consulta de Empresa/Filial
	WSDATA SRetornoEmpresa 		AS FSRETEmpresa
	
	//Inclusão e Consulta de Solicitação ao Armazem
	WsData xRecIncSol				As stRecIncSol
	WsData xRetIncSol				As String
	WsData xRecStatSol			As stRecStatSol
	WsData xRetStatSol			As String
	
	WsData cSolIDFlg				as String

	//Titulos a Pagar / Medição GCT
	WsData cEmpTit				as String
	WsData cFilTit				as String
	WsData cRetorno				as String
	WsData cToken					as String
	WsData nOperacao				as Integer
	WSData aInDataSE2				as InDataSE2
	WSData aInDataSEV				as InDataSEV	OPTIONAL
	WSData aInDataGCT				as InDataGCT
	
	//Baixa CIPA
	WsData xRecBaixaCIPA			As stRecBaixaCIPA
	WsData xRetBaixaCIPA			As String
	
	//Aprovacao Solicitacao Transferencia
	WsData cEmpSol				as String
	WsData cFilSol				as String
	WsData cIdentFlg				as String
	WsData cRetAprov				as String
	WsData cTxtAprov				as String

	//Validacao das Restricoes de Compras x Grupos de Produtos
	WsData cCodProd				as String
	WsData cUsrMail				as String
	

	//Relacao Aniversariantes do Mes
	WsData  cSRACpf                as STring
	WsData	cMesAni				as String
	WsData xGrupos 				as axGrupos
	WsData xAniversarios			as axAniversarios
	
	WsData xRetCC					as stRetCC
	
	WsData cCodUsr				as String
	
	//|GRUPOS USUARIOS PROTHEUS|
	WsData cGrupos					As String OPTIONAL
	WsData EstruturaGrpProtheus   	as StructGRPPROT
	
	//|USUARIOS PROTHEUS|
	WsData cEmpUsuario				As String 
	WsData EstruturaUsrProtheus   	as StructUSRPROT

	//Método para consulta colaborador
	WSMETHOD ConsultaColaborador 	DESCRIPTION "Consulta de colaborador"
	
	//Método para consulta benefício
	WSMETHOD ConsultaBeneficio 		DESCRIPTION "Consulta de benefício"
	
	//Método para consulta pedido de compra
	WSMETHOD ConsultaPedidoCompra 	DESCRIPTION "Consulta de pedido de compra"
	
	//Método para consulta de status de Pré-Nota
	WSMETHOD ConsultaPreNFE 			DESCRIPTION "Consulta do status da pré-nota de entrada"
	
	//Método para consulta de empresa
	WSMETHOD ConsultaDadosEmpresa 	DESCRIPTION "Consulta dados da empresa/filial"
	
	//Método para consulta de aprovadores do pedido
	WSMETHOD ConsultaEmail 			DESCRIPTION "Consulta e-mail dos aprovadores do pedido"
	
	//Método para consulta data de entrada da nota
	WSMETHOD ConsultaDataPreNFE 	DESCRIPTION "Consulta data de entrada da pré-nota de entrada"
	
	//Método para consulta empresa/filial
	WSMETHOD ConsultaEmpresaFilial 	DESCRIPTION "Consulta grupo empresa/filial"
	
	//Método para incluir/alterar/excluir fornecedor
	WSMETHOD Fornecedor 				DESCRIPTION "Inclusão/Alteração/Exclusão de fornecedor"
	
	//Método para incluir/alterar/excluir afastamento
	WSMETHOD Afastamento 			DESCRIPTION "Inclusão/Alteração/Exclusão de afastamento"
	
	//Método para geracao pre-nota de entrada
	WSMETHOD PNFEntrada 				DESCRIPTION "Geração da Pré-Nota de Entrada"
	
	//Método para incluir/alterar/excluir troca de turno
	WSMETHOD TrocaTurno 				DESCRIPTION "Inclusão/Alteração/Exclusão de troca de turno"
	
	//Método para incluir/alterar/excluir acidente de trabalho
	WSMETHOD AcidenteTrabalho 		DESCRIPTION "Inclusão/Alteração/Exclusão de acidente de trabalho"
	
	//Método para incluir/alterar solicitação de compra
	WSMETHOD SolicitacaoCompra 		DESCRIPTION "Inclusão/Alteração de solicitação de compra"
	
	//Método para incluir/alterar programação de férias
	WSMETHOD ProgramacaoFerias 		DESCRIPTION "Inclusão/Alteração de programação de férias"
	
	//Método para incluir/alterar cadastro de produto
	WSMETHOD Produto 					DESCRIPTION "Inclusão/Alteração de produto"
	
	//Método para incluir/alterar movimento bancário
	WSMETHOD MovimentoBancario 		DESCRIPTION "Inclusão/Alteração de movimento bancário"
	
	//Método para aprovação do pedido de compra
	WSMETHOD AprovacaoPC 			DESCRIPTION "Aprovação do pedido de compra V2"
	
	//Método para incluir/alterar benefício
	WSMETHOD Beneficio 				DESCRIPTION "Inclusão/Alteração do benefício"
	
	//Método para incluir/alterar admissão
	WSMETHOD Admissao 				DESCRIPTION "Inclusão/Alteração de admissão"
	
	//Método para incluir/alterar Movimentação de Pessoal
	WSMETHOD MovPessoal 				DESCRIPTION "Inclusão/Alteração de Movimentação de Pessoal"
	
	//Método para inclusão de Títulos a Pagar (Com e Sem rateio por Centro de Custo)
	WSMethod IncTitPag 				Description "Inclusao Contas a Pagar"
	
	//Método para inclusão de Medição no módulo Gestão de Contratos
	WSMethod IncMedGCT				Description "Inclusao Medicao de Contratos"
	
	//Método para Inclusão de Solicitação ao Armazém no Protheus
	WsMethod IncSolArm				Description "Inclusão de Solicitação ao Armazém"
	
	//Metodo para Exclusao da Solicitacao ao Armazem no Protheus
	WsMethod ExcSolArm				Description "Exclusão de Solicitação ao Armazém"

	//Método para consulta de Solicitação ao Armazém no Protheus
	WsMethod StatusSolArm			Description "Consulta Status de Solicitação ao Armazem"
	
	//Método para baixa de pendencias relacionadas ao Mandato CIPA (Pendencias e Datas no Mandato)
	WsMethod BaixaCIPA				Description "Baixa Pendencias e Atualiza Mandato CIPA"
	WsMethod RetParcial				Description "Ret Parcial Pendencias e Atualiza Mandato CIPA"
	
	//Metodo para Aprovacao da Solicitacao de Transferencia de Descarte
	WSMethod AprovaSol				Description "Aprovacao de Solicitacao de Transferencia"

	//Metodo para Validar as Restricoes de Compras x Grupos de Produtos
	WSMethod VldSolCompra			Description "Valida as Restricoes de Compras x Grupos de Produtos"

	//Metodo para Retorno do Centro de Custo da Filial informada
	WSMethod ConsCC					Description "Retorna o Centro de Custo da Filial Informada"

	//Method para Aprovacao da Pre-Requisicao ao Armazem
	WsMethod AprovaReq				Description "Aprovação da Pre-Requisição de Armazém."	

	//Metodo para Retorno da Relacao de Aniversariantes do Mes
	WsMethod Aniversarios			Description "Relação de Aniversariantes do Mes."

	WSMethod UsrMail 				Description "Retona o E-Mail do Usuario do Protheus."
	
	
	WSMethod CancelaPreNFE 			Description "Realiza o cancelamento de uma Pre-Nota de Entrada"
	
	WSMETHOD GrupoUsrProtheus			Description "Grupos Usuarios Protheus"
	
	WSMETHOD UsuariosProtheus			Description "Grupos Usuarios Protheus"

ENDWSSERVICE
//-------------------------------------------------------------------
/*{Protheus.doc} ConsultaEmpresaFilial
Método para consultar empresa/filial

@author Totvs
@since 19/01/2016
@version P12
*/
//-------------------------------------------------------------------
WsMethod ConsultaEmpresaFilial wsreceive SEmpresa wssend SRetornoEmpresa wsservice wsIntegracaoFluig
	Local oNewGrpEmp := Nil
	Local aGEmp := {}
	Local g := 0
	Local d := 0
	Local i := 0
	Local cKeyGrpEmp := ""
	Local lAddEmp := .F.
	Local cUsr     := ::SEmpresa:cUsuario
	Local cMail    := ::SEmpresa:cEmail
	Local cTipo    := ::SEmpresa:cTipo    //"0-Grupos de empresas; 1-Grupo + / Empresas; 2-Grupo + Empresa + Filial;"
	Local cGrupo   := ::SEmpresa:cGrupo   //Quando o tipo for 1 então deve-se informar o Grupo da empresa
	//Quando o tipo for 2 então deve-se informar o Grupo da empresa e Empresa. Se empresa não
	//For informada irá retornar todas as filias do Grupo de todas as empresas
	Local cEmpresa := ::SEmpresa:cEmpresa
	Local lCustomFil	:= GETMV("AL_CUSTFIL",.F.,.T.) // vERIFICA se filial esta bloqueado na tabela customizada
	
	
	IF lCustomFil
		DBSELECTAREA("SZK")
		SZK->(DBSETORDER(1)) //| 

	ENDIF
	
	
	//Se for Tipo 1 ou 2 o grupo deve ser informado.
	If ( (cTipo = "1") .OR. (cTipo = "2") ) .AND. Empty(cGrupo)
		IniVar(@oNewGrpEmp)
		AAdd( ::SRetornoEmpresa:aGrpEmp, oNewGrpEmp )
		Return .T.
	EndIf
	
	aGEmp := U_GetG_E_F( cUsr, cMail  )
	
	If cValToChar(aGEmp[1,1]) == "ERRO"
		IniVar(@oNewGrpEmp)
		AAdd( ::SRetornoEmpresa:aGrpEmp, oNewGrpEmp )
		Return .T.
	EndIf
	
	i := 0
	For g := 1 to Len(aGEmp)
		If cTipo = "0"
			If Empty(cGrupo) .OR. cGrupo == aGEmp[g, 1]
				//Cria Objeto de retorno
				i := i + 1
				IniVar( @oNewGrpEmp )
				oNewGrpEmp:cCodGrpEmp  := aGEmp[g, 1]
				oNewGrpEmp:cNomeGrpEmp := aGEmp[g, 2]
				AAdd( ::SRetornoEmpresa:aGrpEmp, oNewGrpEmp )
			EndIf
		Else
			cKeyGrpEmp := ""
			For d := 1 to Len(aGEmp[g, 3])
				If Empty(cGrupo) .OR. cGrupo == aGEmp[g, 1]
					If Empty(cEmpresa)  .OR. cEmpresa == aGEmp[g, 3, d, 3]
						
						lAddEmp := ( cTipo $ "2") .OR. ;
							( (cTipo $ "1") .AND. !( (";" + aGEmp[g, 1] + '-' + aGEmp[g, 3, d, 3] + ";" ) $ cKeyGrpEmp ) )
						
						If lAddEmp
							cKeyGrpEmp += ";" + aGEmp[g, 1] + '-' + aGEmp[g, 3, d, 3] + ";"
							i := i + 1
							IniVar( @oNewGrpEmp )
							
							oNewGrpEmp:cCodGrpEmp  := IIF(aGEmp[g, 1] == NIL, " ", aGEmp[g, 1])
							oNewGrpEmp:cNomeGrpEmp := IIF(aGEmp[g, 2] == NIL, " ", aGEmp[g, 2])
							oNewGrpEmp:cCodEmp     := IIF(aGEmp[g, 3, d, 3] == NIL, " ", aGEmp[g, 3, d, 3] )
							oNewGrpEmp:cEmpresa    := IIF(aGEmp[g, 3, d, 4] == NIL, " ", aGEmp[g, 3, d, 4] )
							
							If cTipo $ "2"
								
								
								IF lCustomFil
									IF SZK->(DBSEEK(oNewGrpEmp:cCodGrpEmp+IIF(aGEmp[g, 3, d, 5] == NIL , " ", aGEmp[g, 3, d, 5] ) )) 
										IF SZK->ZK_MSBLQL <> "1"
											oNewGrpEmp:cCodFil     := IIF(aGEmp[g, 3, d, 5] == NIL , " ", aGEmp[g, 3, d, 5] )
											oNewGrpEmp:cNomeFil    := IIF(aGEmp[g, 3, d, 7] == NIL , " ", aGEmp[g, 3, d, 7] )
											AAdd( ::SRetornoEmpresa:aGrpEmp, oNewGrpEmp )										
										ENDIF			
									ENDIF
								ELSE
									oNewGrpEmp:cCodFil     := IIF(aGEmp[g, 3, d, 5] == NIL , " ", aGEmp[g, 3, d, 5] )
									oNewGrpEmp:cNomeFil    := IIF(aGEmp[g, 3, d, 7] == NIL , " ", aGEmp[g, 3, d, 7] )
									AAdd( ::SRetornoEmpresa:aGrpEmp, oNewGrpEmp )
								ENDIF
							ELSE
								AAdd( ::SRetornoEmpresa:aGrpEmp, oNewGrpEmp )
							EndIf
							
						EndIf
					EndIf
				EndIf
			End For
		EndIf
	End For
	
	If i == 0
		IniVar(@oNewGrpEmp)
		AAdd( ::SRetornoEmpresa:aGrpEmp, oNewGrpEmp )
	EndIf
	
	
Return .T.
//-------------------------------------------------------------------
/*{Protheus.doc} ConsultaColaborador
Método para consultar colaborador

@author Totvs
@since 19/01/2016
@version P12
*/
//-------------------------------------------------------------------
WSMETHOD ConsultaColaborador WSRECEIVE SColaborador WSSEND sretornocolaborador WSSERVICE wsIntegracaoFluig
	//Consulta tabela de colaboradores
	DbSelectArea("SRA")
	DbSetOrder(1)
	
	If DbSeek(xFilial("SRA") + ::SColaborador:cMAT)
		::SRetornoColaborador:RA_MAT     := SRA->RA_MAT
		::SRetornoColaborador:RA_NOME    := SRA->RA_NOME
		::SRetornoColaborador:RA_MAE     := SRA->RA_MAE
		::SRetornoColaborador:RA_NASC    := SRA->RA_NASC
		::SRetornoColaborador:RA_CIC     := SRA->RA_CIC
		::SRetornoColaborador:RA_SEXO    := SRA->RA_SEXO
		::SRetornoColaborador:RA_ESTCIVI := SRA->RA_ESTCIVI
		::SRetornoColaborador:RA_NUMCP   := SRA->RA_NUMCP
		::SRetornoColaborador:RA_DTCPEXP := SRA->RA_DTCPEXP
		::SRetornoColaborador:RA_ESTADO  := SRA->RA_ESTADO
		::SRetornoColaborador:RA_RG      := SRA->RA_RG
		::SRetornoColaborador:RA_DTRGEXP := SRA->RA_DTRGEXP
		::SRetornoColaborador:RA_RGEXP   := SRA->RA_RGEXP
		::SRetornoColaborador:RA_RGUF    := SRA->RA_RGUF
		::SRetornoColaborador:RA_PIS     := SRA->RA_PIS
		::SRetornoColaborador:RA_SALARIO := AllTrim(Str(SRA->RA_SALARIO))
		::SRetornoColaborador:RA_ENDEREC := SRA->RA_ENDEREC
		::SRetornoColaborador:RA_BAIRRO  := SRA->RA_BAIRRO
	Else
		Return .F.
	EndIf
	
Return .T.
//-------------------------------------------------------------------
/*{Protheus.doc} ConsultaBeneficio
Método para consultar beneficio

@author Totvs
@since 19/01/2016
@version P12
*/
//-------------------------------------------------------------------
WSMETHOD ConsultaBeneficio WSRECEIVE SBeneficio WSSEND SRetornoBeneficio WSSERVICE wsIntegracaoFluig
	cAliasQry := GetNextAlias()
	cQuery := " SELECT DISTINCT(SR0.R0_CODIGO) "
	cQuery += " FROM " + RetSqlName("SR0")+" SR0 "
	cQuery += " WHERE "
	cQuery += "       SR0.R0_TPVALE = '" + ::SBeneficio:cTipoVale + "'"
	cQuery += " AND   SR0.R0_FILIAL = '" + xFilial("SR0") + "'"
	cQuery += " AND   SR0.D_E_L_E_T_ <> '*' "
	cQuery += " ORDER BY SR0.R0_CODIGO "
	
	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
	
	dbSelectArea(cAliasQry)
	dbGoTop()
	
	If !Eof()
		While !Eof()
			oNewSR0 :=  WSClassNew( "FSBeneficio" )
			
			oNewSR0:R0_TPVALE := ::SBeneficio:cTipoVale
			oNewSR0:R0_CODIGO := (cAliasQry)->R0_CODIGO
			
			If ::SBeneficio:cTipoVale == '0' //VT
				oNewSR0:R0_DESC := Posicione("SRN",1,xFilial("SRN")+(cAliasQry)->R0_CODIGO,"RN_DESC")
			Else //VR ou VA
				oNewSR0:R0_DESC := Posicione("RFO",1,xFilial("RFO")+::SBeneficio:cTipoVale+(cAliasQry)->R0_CODIGO,"RFO_DESCR")
			EndIf
			
			AAdd( ::SRetornoBeneficio:Beneficio, oNewSR0 )
			
			(cAliasQry)->(dbSkip())
		End
	Else
		(cAliasQry)->(dbCloseArea())
		
		Return .F.
	EndIf
	
	(cAliasQry)->(dbCloseArea())
	
Return .T.
//-------------------------------------------------------------------
/*{Protheus.doc} ConsultaPedidoCompra
Método para consultar pedido de compra

@author Totvs
@since 19/01/2016
@version P12
*/
//-------------------------------------------------------------------
WSMETHOD ConsultaPedidoCompra WSRECEIVE SPedidoCompra WSSEND SRetPedCom WSSERVICE wsIntegracaoFluig
	Local aArea	:= GetArea()
	Local cQuery	:= ""
	Local cTabQry	:= GetNextAlias()
	Local cAliasCPX := GetNextAlias()
	Local oNewSC7 := NIL
	Local cPicture := "@E 999999999.99"
	Local cPicPrec := "@E 999999999.9999"
	Local cFiltraMed	:= "A"

	Local aForTer := {}
	Local nX := 1
	
	IF EMPTY(::SPedidoCompra:FiltraMed)
		cFiltraMed	:= "A"
	ELSE
		cFiltraMed	:= ::SPedidoCompra:FiltraMed
	ENDIF
	
	cQuery := " SELECT CPX_CODIGO+CPX_LOJA FORNECE " 
	cQuery += " FROM "+RetSqlName("CPX")+" CPX " 
	cQuery += " WHERE CPX_CODFOR = '"+Left(::SPedidoCompra:CNPJSC7,TamSx3("A2_COD")[1])+"' " 
	cQuery += " AND CPX_LOJFOR = '"+SubStr(::SPedidoCompra:CNPJSC7, TamSx3("A2_COD")[1]+1, TamSx3("A2_LOJA")[1])+"' "
	cQuery += " AND CPX.D_E_L_E_T_ <> '*' "

	DbUseArea(.T., "TOPCONN", TcGenQry(NIL, NIL, cQuery), cAliasCPX, .T., .T.)
	
	While (cAliasCPX)->(!EOF( ))
		aAdd(aForTer, (cAliasCPX)->FORNECE)
		(cAliasCPX)->(DbSkip())
	Enddo

	cQuery := "SELECT		SC7.C7_FORNECE" + CRLF
	cQuery += ",			SC7.C7_LOJA" + CRLF
	cQuery += ",			SC7.C7_NUM" + CRLF
	cQuery += ",			SC7.C7_EMISSAO" + CRLF
	cQuery += ",			SC7.C7_ORIGIMP" + CRLF
	cQuery += ",			SC7.C7_TIPO" + CRLF
	cQuery += ",			SC7.C7_ITEM" + CRLF
	cQuery += ",			SC7.C7_PRODUTO" + CRLF
	cQuery += ",			SB1.B1_DESC" + CRLF
	cQuery += ",			SC7.C7_UM" + CRLF
	cQuery += ",			CASE WHEN SC7.C7_QUJE <> 0 AND SC7.C7_QUJE < SC7.C7_QUANT THEN SC7.C7_QUANT - SC7.C7_QUJE ELSE SC7.C7_QUANT END C7_QUANT" + CRLF
	cQuery += ",			SC7.C7_PRECO" + CRLF
	cQuery += ",			SC7.C7_TOTAL" + CRLF
	cQuery += ",			SC7.C7_LOCAL" + CRLF
	cQuery += ",			SC7.C7_SEGUM" + CRLF
	cQuery += ",			SC7.C7_QTSEGUM" + CRLF
	cQuery += ",			SC7.C7_DATPRF" + CRLF
	cQuery += ",			SC7.C7_OBS" + CRLF
	cQuery += ",			SC7.C7_CC" + CRLF
	cQuery += ",			SC7.C7_MOEDA" + CRLF
	
	/*----------------------------------------
		17/07/2018 - Jonatas Oliveira - Compila
		Inclusão valores de 
		Despesa
		Seguro
		Frete
		Desconto
	-----------------------------------------*/
	 
	cQuery += ",			SC7.C7_DESPESA" + CRLF
	cQuery += ",			SC7.C7_SEGURO" + CRLF
	cQuery += ",			SC7.C7_VALFRE" + CRLF
	cQuery += ",			SC7.C7_VLDESC" + CRLF
	cQuery += ",			SC7.C7_VALIPI" + CRLF
	
	cQuery += ",			CASE WHEN CTT.CTT_DESC01 IS NULL THEN '' ELSE CTT.CTT_DESC01 END CTT_DESC01" + CRLF
	cQuery += ",			SB1.B1_RASTRO" + CRLF

	cQuery += "FROM		" + RetSqlName("SC7") + " SC7" + CRLF
	cQuery += "			INNER JOIN" + CRLF
	cQuery += "			" + RetSqlName("SA2") + " SA2" + CRLF
	
	cQuery += "			ON 	SA2.A2_FILIAL = '" + xFilial("SA2") + "'" + CRLF
	If	LEN(::SPedidoCompra:CNPJSC7) == 14
		cQuery += "			AND	(SA2.A2_CGC = '" + ::SPedidoCompra:CNPJSC7 + "'" + CRLF
	Else
		cQuery += "			AND	((SA2.A2_COD = '"+Left(::SPedidoCompra:CNPJSC7,TamSx3("A2_COD")[1])+"' AND SA2.A2_LOJA = '"+SubStr(::SPedidoCompra:CNPJSC7, TamSx3("A2_COD")[1]+1, TamSx3("A2_LOJA")[1])+"' )  "+ CRLF
	Endif
	If len(aForTer) > 0	
		For nX := 1 to len(aForTer)
			cQuery += "  OR SA2.A2_COD+SA2.A2_LOJA = '" +aForTer[nX]+ "' " + CRLF
		Next nX	
		cQuery += "  )" + CRLF
	Else
		cQuery += ")" + CRLF
	Endif									
	cQuery += "			AND	SA2.A2_COD = SC7.C7_FORNECE" + CRLF
	cQuery += "			AND	SA2.A2_LOJA = SC7.C7_LOJA" + CRLF
	cQuery += "			AND	SA2.D_E_L_E_T_ <> '*'" + CRLF

	cQuery += "			INNER JOIN" + CRLF
	cQuery += "			" + RetSqlName("SB1") + " SB1" + CRLF
	
	cQuery += "			ON 	SB1.B1_FILIAL = '" + xFilial("SB1") + "'" + CRLF
	cQuery += "			AND	SB1.B1_COD = SC7.C7_PRODUTO" + CRLF
	cQuery += "			AND	SB1.D_E_L_E_T_ <> '*'" + CRLF

	cQuery += "			LEFT JOIN" + CRLF
	cQuery += "			" + RetSqlName("CTT") + " CTT" + CRLF
	
	cQuery += "			ON 	CTT.CTT_FILIAL = '" + xFilial("CTT", ::SPedidoCompra:FilSC7) + "'" + CRLF
	cQuery += "			AND	CTT.CTT_CUSTO = SC7.C7_CC" + CRLF
	cQuery += "			AND	CTT.D_E_L_E_T_ <> '*'" + CRLF

	cQuery += "WHERE		SC7.C7_FILIAL  = '" + xFilial("SC7", ::SPedidoCompra:FilSC7) + "'" + CRLF
	cQuery += "AND 		SC7.C7_CONAPRO = 'L'" + CRLF
	cQuery += "AND 		SC7.C7_ENCER =  ''" + CRLF
	cQuery += "AND 		SC7.C7_QUANT > SC7.C7_QUJE" + CRLF
	cQuery += "AND 		((SC7.C7_QUJE = 0 AND SC7.C7_QTDACLA = 0) OR (SC7.C7_QUJE <> 0 AND SC7.C7_QUJE < SC7.C7_QUANT))" + CRLF
	IF cFiltraMed == "S"
		cQuery += "AND C7_CONTRA <> '' "
	ELSEIF cFiltraMed == "N"
		cQuery += "AND C7_CONTRA = '' "
	ENDIF
	cQuery += "AND 		SC7.D_E_L_E_T_ <> '*'" + CRLF

	cQuery += "ORDER BY 	SC7.C7_FORNECE, SC7.C7_LOJA, SC7.C7_NUM" + CRLF

	cQuery := ChangeQuery(cQuery)
		
	DbUseArea(.T., "TOPCONN", TcGenQry(NIL, NIL, cQuery), cTabQry, .T., .T.)
		
	If (cTabQry)->(Eof())
		oNewSC7				:= WSClassNew("FSRetPCom")
		oNewSC7:C7_FORNECE 	:= " "
		oNewSC7:C7_LOJA    	:= " "
		oNewSC7:C7_NUM     	:= " "
		oNewSC7:C7_EMISSAO 	:= CtoD("")
		oNewSC7:C7_ORIGIMP 	:= " "
		oNewSC7:C7_TIPO    	:= 0
		oNewSC7:C7_ITEM    	:= " "
		oNewSC7:C7_PRODUTO 	:= " "
		oNewSC7:C7_DESCRI  	:= " "
		oNewSC7:C7_UM      	:= " "
		oNewSC7:C7_QUANT   	:= AllTrim(Str(0))
		oNewSC7:C7_PRECO   	:= AllTrim(Str(0))
		oNewSC7:C7_TOTAL   	:= AllTrim(Str(0))
		oNewSC7:C7_LOCAL   	:= " "
		oNewSC7:C7_SEGUM   	:= " "
		oNewSC7:C7_QTSEGUM 	:= AllTrim(Str(0))
		oNewSC7:C7_DATPRF  	:= " "
		oNewSC7:C7_OBS     	:= " "
		oNewSC7:C7_CC      	:= " "
		oNewSC7:C7_MOEDA   	:= 0
		
		/*----------------------------------------
			17/07/2018 - Jonatas Oliveira - Compila
			Inclusão valores de 
			Despesa
			Seguro
			Frete
			Desconto
		------------------------------------------*/		
		
		oNewSC7:C7_DESPESA 	:= AllTrim(Str(0))
		oNewSC7:C7_SEGURO	:= AllTrim(Str(0))
		oNewSC7:C7_VALFRE	:= AllTrim(Str(0))
		oNewSC7:C7_VLDESC	:= AllTrim(Str(0))
		oNewSC7:C7_VALIPI	:= AllTrim(Str(0))
		
		oNewSC7:CTT_DESC01 	:= " "
		oNewSC7:B1_RASTRO  	:= " "
		
		Aadd(::SRetPedCom, oNewSC7)
	Else
		While !(cTabQry)->(Eof())
		
			oNewSC7				:= WSClassNew("FSRetPCom")
			oNewSC7:C7_FORNECE	:= (cTabQry)->C7_FORNECE
			oNewSC7:C7_LOJA		:= (cTabQry)->C7_LOJA
			oNewSC7:C7_NUM		:= (cTabQry)->C7_NUM
			oNewSC7:C7_EMISSAO	:= StoD((cTabQry)->C7_EMISSAO)
			oNewSC7:C7_ORIGIMP	:= (cTabQry)->C7_ORIGIMP
			oNewSC7:C7_TIPO		:= (cTabQry)->C7_TIPO
			oNewSC7:C7_ITEM		:= (cTabQry)->C7_ITEM
			oNewSC7:C7_PRODUTO	:= (cTabQry)->C7_PRODUTO
			oNewSC7:C7_DESCRI		:= (cTabQry)->B1_DESC
			oNewSC7:C7_UM			:= (cTabQry)->C7_UM
			oNewSC7:C7_QUANT		:= StrTran(Transform((cTabQry)->C7_QUANT, cPicture), ",", ".")
			oNewSC7:C7_PRECO		:= StrTran(Transform((cTabQry)->C7_PRECO, "@E 999999999.9999"), ",", ".")
			oNewSC7:C7_TOTAL		:= StrTran(Transform((cTabQry)->C7_TOTAL, cPicture), ",", ".")
			oNewSC7:C7_LOCAL		:= (cTabQry)->C7_LOCAL
			oNewSC7:C7_SEGUM		:= (cTabQry)->C7_SEGUM
			oNewSC7:C7_QTSEGUM	:= StrTran(Transform((cTabQry)->C7_QTSEGUM, cPicture), ",", ".")
			oNewSC7:C7_DATPRF		:= (cTabQry)->C7_DATPRF
			oNewSC7:C7_OBS		:= (cTabQry)->C7_OBS
			oNewSC7:C7_CC			:= (cTabQry)->C7_CC
			oNewSC7:C7_MOEDA		:= (cTabQry)->C7_MOEDA
			
		/*----------------------------------------
			17/07/2018 - Jonatas Oliveira - Compila
			Inclusão valores de 
			Despesa
			Seguro
			Frete
			Desconto
		------------------------------------------*/				
			
			oNewSC7:C7_DESPESA	:= StrTran(Transform((cTabQry)->C7_DESPESA, cPicture), ",", ".")
			oNewSC7:C7_SEGURO   := StrTran(Transform((cTabQry)->C7_SEGURO, cPicture), ",", ".")
			oNewSC7:C7_VALFRE   := StrTran(Transform((cTabQry)->C7_VALFRE, cPicture), ",", ".")
			oNewSC7:C7_VLDESC   := StrTran(Transform((cTabQry)->C7_VLDESC, cPicture), ",", ".")
			oNewSC7:C7_VALIPI   := StrTran(Transform((cTabQry)->C7_VALIPI, cPicture), ",", ".")
			
			oNewSC7:CTT_DESC01	:= (cTabQry)->CTT_DESC01
			oNewSC7:B1_RASTRO		:= (cTabQry)->B1_RASTRO
			
			Aadd(::SRetPedCom, oNewSC7)
		
			(cTabQry)->(DbSkip())
		End
	EndIf
	
	If Select(cTabQry) > 0
		(cTabQry)->(DbCloseArea())
	EndIf
	
	RestArea(aArea)
	
Return .T.
//-------------------------------------------------------------------
/*{Protheus.doc} ConsultaPreNFE
Método para consultar status Pré-Nota Entrada

@author Totvs
@since 19/01/2016
@version P12
*/
//-------------------------------------------------------------------
WSMETHOD ConsultaPreNFE WSRECEIVE SPreNFE WSSEND SRetornoPreNFE WSSERVICE wsIntegracaoFluig
	Local cFornec, cLoja
	
	dbSelectArea("SA2")
	dbSetOrder(3)
	
	If dbSeek(xFilial("SA2",::SPreNFE:FilSF1)+::SPreNFE:CNPJSF1)
		cFornec := AllTrim(SubStr(::SPreNFE:CNPJSF1,1,8))
		
		If SA2->A2_TIPO == 'F'
			cLoja := SubStr(::SPreNFE:CNPJSF1,9,3)
		ElseIf SA2->A2_TIPO == 'J'
			cLoja := SubStr(::SPreNFE:CNPJSF1,9,4)
		EndIf
		cLoja := AllTrim(cLoja)
	EndIf
	
	cAliasQry := GetNextAlias()
	cQuery := " SELECT SF1.F1_STATUS "
	cQuery += " FROM " + RetSqlName("SF1") + " SF1 "
	cQuery += " WHERE SF1.F1_FORNECE = '" + cFornec + "'"
	cQuery += " AND   SF1.F1_LOJA    = '" + cLoja + "'"
	cQuery += " AND   SF1.F1_DOC     = '" + ::SPreNFE:DocSF1 + "'"
	cQuery += " AND   SF1.F1_FILIAL  = '" + xFilial("SF1",::SPreNFE:FilSF1) + "'"
	cQuery += " AND   SF1.D_E_L_E_T_ <> '*' "
	cQuery := ChangeQuery(cQuery)
	
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
	dbSelectArea(cAliasQry)
	dbGoTop()
	
	oNewSF1 :=  WSClassNew( "FSRETPreNFE" )
	
	If !Eof()
		If !Empty((cAliasQry)->F1_STATUS)
			oNewSF1:Classifica := .T.
		Else
			oNewSF1:Classifica := .F.
		EndIf
		
		(cAliasQry)->(dbCloseArea())
		AAdd( ::SRetornoPreNFE, oNewSF1 )
		
	Else
		(cAliasQry)->(dbCloseArea())
		
		oNewSF1:Classifica := .F.
		
		Return .F.
	EndIf
	
Return .T.
//-------------------------------------------------------------------
/*{Protheus.doc} ConsultaDataPreNFE
Método para consultar data de entrada Pré-Nota Entrada

@author TOTVS
@since 19/01/2016
@version P12
*/
//-------------------------------------------------------------------
WSMETHOD ConsultaDataPreNFE WSRECEIVE SDataPreNFE WSSEND SRetorno WSSERVICE wsIntegracaoFluig
	
	if (StoD(::SDataPreNFE:DataEntrada) > GETMV("MV_ULMES")) .AND. (StoD(::SDataPreNFE:DataEntrada) > GETMV("MV_DBLQMOV"))
		::SRetorno:RETORNO 	:= 1
		::SRetorno:MENSAGEM	:= " "
	else
		::SRetorno:RETORNO 	:= 3
		::SRetorno:MENSAGEM	:= "Nao e possivel solicitar o lancamento dessa nota com a Data de Digitacao informada! Solicite verificar no Protheus os parâmetros MV_ULMES e MV_DBLQMOV!"
	endif
Return .T.
//-------------------------------------------------------------------
/*{Protheus.doc} ConsultaDadosEmpresa
Método para consultar dados da Empresa

@author TOTVS
@since 19/01/2016
@version P12
*/
//-------------------------------------------------------------------
WSMETHOD ConsultaDadosEmpresa WSRECEIVE SFilial WSSEND SRetornoFilial WSSERVICE wsIntegracaoFluig
	
	dbSelectArea("SM0")
	dbGotop()
	While !Eof()
		If AllTrim(SM0->M0_CODIGO) == AllTrim(FWCodEmp()) .AND. AllTrim(SM0->M0_CODFIL) == AllTrim(::SFilial:FilSM0)
			
			oNewSM0 :=  WSClassNew( "FSRETFilial" )
			oNewSM0:M0_NOME    := SM0->M0_NOME
			oNewSM0:M0_FILIAL  := SM0->M0_FILIAL
			oNewSM0:M0_NOMECOM := SM0->M0_NOMECOM
			oNewSM0:M0_CNAE    := SM0->M0_CNAE
			oNewSM0:M0_ENDCOB  := SM0->M0_ENDCOB
			oNewSM0:M0_BAIRCOB := SM0->M0_BAIRCOB
			oNewSM0:M0_CEPCOB  := SM0->M0_CEPCOB
			oNewSM0:M0_CIDCOB  := SM0->M0_CIDCOB
			oNewSM0:M0_ESTCOB  := SM0->M0_ESTCOB
			oNewSM0:M0_TEL     := SM0->M0_TEL
			oNewSM0:M0_DESC    := SM0->M0_NOME + SM0->M0_FILIAL
			
			AAdd( ::SRetornoFilial, oNewSM0 )
			
			//Return .T.
			Exit
		EndIf
		dbSkip()
	EndDo
	
Return .T.
//-------------------------------------------------------------------
/*{Protheus.doc} ConsultaEmail
Método para consultar e-mail dos aprovadores do pedido

@author TOTVS
@since 19/01/2016
@version P12
*/
//-------------------------------------------------------------------
WSMETHOD ConsultaEmail WSRECEIVE SEmail WSSEND SRetornoEmail WSSERVICE wsIntegracaoFluig
	Local cRetorno := ""
	Local lRetorno := .T.
	
	dbSelectArea("SCR")
	dbSetOrder(1)
	
	If SCR->(dbSeek(::SEmail:cFilDoc+"PC"+::SEmail:Documento))
		
		While !SCR->(Eof()) .AND. SCR->CR_FILIAL == ::SEmail:cFilDoc .AND. SCR->CR_TIPO == "PC" .AND. AllTrim(SCR->CR_NUM) == AllTrim(::SEmail:Documento)
			PswOrder(1) 
			If PswSeek(SCR->CR_USER)

				oNewSCR :=  WSClassNew( "FSRETEmail" )

				oNewSCR:CR_NIVEL := SCR->CR_NIVEL
				oNewSCR:CR_EMAIL := PswRet(1)[1][14]
				
				AAdd( ::SRetornoEmail, oNewSCR )
			EndIf
			
			SCR->(dbSkip())
		End
	Else
		cRetorno := "Pedido não localizado."
		lRetorno := .F.
	EndIf

	If !lRetorno
		Console(cRetorno)
		SetSoapFault(XNOMEPROG, cRetorno)
	EndIf

Return lRetorno
//-------------------------------------------------------------------
/*{Protheus.doc} Fornecedor
Método para incluir/modificar fornecedor

@author TOTVS
@since 19/01/2016
@version P12
*/
//-------------------------------------------------------------------
WSMETHOD Fornecedor WSRECEIVE SFornecedor WSSEND SRetorno WSSERVICE wsIntegracaoFluig
	Local nRetorno  := 0
	Local cMsg	    := ""
	
	//Funcao para gravar os dados do fornecedor
	nRetorno := U_CadFor(SFornecedor, @cMsg)
	
	//Retorno
	::SRetorno:RETORNO 	:= nRetorno
	::SRetorno:MENSAGEM	:= cMsg
	
Return .T.
//-------------------------------------------------------------------
/*{Protheus.doc} Afastamento
Método para incluir/modificar afastamento

@author TOTVS
@since 19/01/2016
@version P12
*/
//-------------------------------------------------------------------
WSMETHOD Afastamento WSRECEIVE SAfastamento WSSEND SRetorno WSSERVICE wsIntegracaoFluig
	Local nRetorno  := 0
	Local cMsg	    := ""
	
	//Funcao para gravar os dados do afastamento
	nRetorno := U_CadAfa(SAfastamento, @cMsg)
	
	//Retorno
	::SRetorno:RETORNO 	:= nRetorno
	::SRetorno:MENSAGEM	:= cMsg
	
Return .T.
//-------------------------------------------------------------------
/*{Protheus.doc} PNFEntrada
Método para geração de pre-nota de entrada

@author TOTVS
@since 19/01/2016
@version P12
*/
//-------------------------------------------------------------------
WSMETHOD PNFEntrada WSRECEIVE SPNFEntrada WSSEND SRetorno WSSERVICE wsIntegracaoFluig
	Local nRetorno  := 0
	Local cMsg	    := ""
		
	CONOUT("wsIntegracaoFluig", "PNFEntrada INICIO - "+DTOC(DATE())+" "+TIME())
	CONOUT("wsIntegracaoFluig", HTTPOTHERCONTENT())
	//Funcao para gravar os dados da pre-nota de entrada

//	WSDLDbgLevel(2)
		
	nRetorno := U_CadNFE(SPNFEntrada, @cMsg)
	
	
	//Retorno
	::SRetorno:RETORNO 	:= nRetorno
	::SRetorno:MENSAGEM	:= cMsg

	
	
	CONOUT("wsIntegracaoFluig", "PNFEntrada FIM - "+DTOC(DATE())+" "+TIME())
	
Return .T.
//-------------------------------------------------------------------
/*{Protheus.doc} TrocaTurno
Método para incluir/modificar troca de turno

@author TOTVS
@since 19/01/2016
@version P12
*/
//-------------------------------------------------------------------
WSMETHOD TrocaTurno WSRECEIVE STrocaTurno WSSEND SRetorno WSSERVICE wsIntegracaoFluig
	Local nRetorno  := 0
	Local cMsg	    := ""
	
	//Funcao para gravar os dados da troca de turno
	nRetorno := U_CadTUR(STrocaTurno, @cMsg)
	
	//Retorno
	::SRetorno:RETORNO 	:= nRetorno
	::SRetorno:MENSAGEM	:= cMsg
	
Return .T.
//-------------------------------------------------------------------
/*{Protheus.doc} AcidenteTrabalho
Método para incluir/modificar acidente de trabalho

@author TOTVS
@since 19/01/2016
@version P12
*/
//-------------------------------------------------------------------
WSMETHOD AcidenteTrabalho WSRECEIVE SAcidenteTrabalho WSSEND SRetorno WSSERVICE wsIntegracaoFluig
	Local nRetorno  := 0
	Local cMsg	    := ""
	
	//Funcao para gravar os dados da troca de turno
	nRetorno := U_CadACT(SAcidenteTrabalho, @cMsg)
	
	//Retorno
	::SRetorno:RETORNO 	:= nRetorno
	::SRetorno:MENSAGEM	:= cMsg
	::SRetorno:ID       := Trim(TNC->TNC_ACIDEN)
	
Return .T.
//-------------------------------------------------------------------
/*{Protheus.doc} SolicitacaoCompra
Método para incluir/modificar solicitação de compra

@author TOTVS
@since 19/01/2016
@version P12
*/
//-------------------------------------------------------------------
WSMETHOD SolicitacaoCompra WSRECEIVE SSolicitacaoCompra WSSEND SRetorno WSSERVICE wsIntegracaoFluig
	
	Local nRetorno  := 0
	Local cMsg	    := ""
	Private lMsFinalAuto := .F. //usada pela função RpcSetEnv

//	RPCSetType(3)

	if VldEmpFil(::SSolicitacaoCompra:cEmpFluig, ::SSolicitacaoCompra:cFilFluig)
		RpcSetEnv(::SSolicitacaoCompra:cEmpFluig, ::SSolicitacaoCompra:cFilFluig)
	endif

	//Funcao para gravar os dados da solicitação de compra
	nRetorno := U_CadSOC(SSolicitacaoCompra, @cMsg)
	
	//Retorno
	::SRetorno:RETORNO 	:= nRetorno
	::SRetorno:MENSAGEM	:= cMsg
	::SRetorno:ID       := Trim(SC1->C1_NUM)
	
Return .T.
//-------------------------------------------------------------------
/*{Protheus.doc} ProgramacaoFerias
Método para incluir/modificar programação de férias

@author TOTVS
@since 19/01/2016
@version P12
*/
//-------------------------------------------------------------------
WSMETHOD ProgramacaoFerias WSRECEIVE SProgramacaoFerias WSSEND SRetorno WSSERVICE wsIntegracaoFluig
	
	Local nRetorno  := 0
	Local cMsg	    := ""
	
	//Funcao para gravar os dados da programação de férias
	nRetorno := U_CadPFE(SProgramacaoFerias, @cMsg)
	
	//Retorno
	::SRetorno:RETORNO 	:= nRetorno
	::SRetorno:MENSAGEM	:= cMsg
	
Return .T.
//-------------------------------------------------------------------
/*{Protheus.doc} Produto
Método para incluir/modificar cadastro de produto

@author TOTVS
@since 19/01/2016
@version P12
*/
//-------------------------------------------------------------------
WSMETHOD Produto WSRECEIVE SProduto WSSEND SRetorno WSSERVICE wsIntegracaoFluig
	
	Local nRetorno  := 0
	Local cMsg	    := ""
	
	//Funcao para gravar os dados do cadastro de produto
	nRetorno := U_CadPRO(SProduto, @cMsg)
	
	//Retorno
	::SRetorno:RETORNO 	:= nRetorno
	::SRetorno:MENSAGEM	:= cMsg
	::SRetorno:ID	    := Trim(SB1->B1_COD)
	
Return .T.
//-------------------------------------------------------------------
/*{Protheus.doc} MovimentoBancario
Método para incluir/modificar movimento bancário

@author TOTVS
@since 19/01/2016
@version P12
*/
//-------------------------------------------------------------------
WSMETHOD MovimentoBancario WSRECEIVE SMovimentoBancario WSSEND SRetorno WSSERVICE wsIntegracaoFluig
	
	Local nRetorno  := 0
	Local cMsg	    := ""
	Private lMsFinalAuto := .F. //usada pela função RpcSetEnv

//	RPCSetType(3)
	
	if VldEmpFil(::SMovimentoBancario:cEmpFluig, AllTrim(::SMovimentoBancario:cFilFluig))
		RpcSetEnv(::SMovimentoBancario:cEmpFluig, AllTrim(::SMovimentoBancario:cFilFluig))
	endif

	//Funcao para gravar os dados do movimento bancário
	nRetorno := U_CadMVB(SMovimentoBancario, @cMsg)
	
	//Retorno
	::SRetorno:RETORNO 	:= nRetorno
	::SRetorno:MENSAGEM	:= cMsg
	
Return .T.
//-------------------------------------------------------------------
/*{Protheus.doc} AprovacaoPC
Método para aprovação do pedido de compra

@author TOTVS
@since 19/01/2016
@version P12
*/
//-------------------------------------------------------------------
WSMETHOD AprovacaoPC WSRECEIVE SAprovacaoPC WSSEND SRetorno WSSERVICE wsIntegracaoFluig
	
	Local nRetorno  := 0
	Local cMsg	    := ""
	
	CONOUT("ALPCAPRO INICIO TST "+TIME())
	
	//Begin Transaction

		//Funcao para aprovar os dados do pedido de compra
		//|Criação de Fila de processamento|
		
		nRetorno := U_ALPCAPRO(SAprovacaoPC, @cMsg)
		
		//Retorno
		::SRetorno:RETORNO 	:= nRetorno
		::SRetorno:MENSAGEM	:= cMsg
		::SRetorno:ID	    	:= ""

	//End Transaction
	
	CONOUT("ALPCAPRO FIM "+TIME())
	
Return .T.
//-------------------------------------------------------------------
/*{Protheus.doc} Beneficio
Método para cadastro de benefício

@author TOTVS
@since 19/01/2016
@version P12
*/
//-------------------------------------------------------------------
WSMETHOD Beneficio WSRECEIVE SCadBeneficio WSSEND SRetorno WSSERVICE wsIntegracaoFluig
	
	Local nRetorno  := 0
	Local cMsg	    := ""
	
	//Funcao para aprovar os dados do pedido de compra
	nRetorno := U_CadBNF(SCadBeneficio, @cMsg)
	
	//Retorno
	::SRetorno:RETORNO 	:= nRetorno
	::SRetorno:MENSAGEM	:= cMsg
	
Return .T.
//-------------------------------------------------------------------
/*{Protheus.doc} Admissao
Método para cadastro de admissão

@author TOTVS
@since 19/01/2016
@version P12
*/
//-------------------------------------------------------------------
WSMETHOD Admissao WSRECEIVE SCadAdmissao WSSEND SRetorno WSSERVICE wsIntegracaoFluig
	
	Local nRetorno  := 0
	Local cMsg	    := ""
	
	//Funcao para cadastrar admissão
	nRetorno := U_CadADM(SCadAdmissao, @cMsg)
	
	//Retorno
	::SRetorno:RETORNO 	:= nRetorno
	::SRetorno:MENSAGEM	:= cMsg
	::SRetorno:ID       := SRA->RA_MAT
	
Return .T.
//-------------------------------------------------------------------
/*{Protheus.doc} MovPessoal
Método para cadastro de movimentação de pessoal

@author TOTVS
@since 19/01/2016
@version P12
*/
//-------------------------------------------------------------------
WSMETHOD MovPessoal WSRECEIVE SMovPessoal WSSEND SRetorno WSSERVICE wsIntegracaoFluig
	
	Local nRetorno  := 0
	Local cMsg	    := ""
	
	//Funcao para cadastro de movimentação de pessoal
	nRetorno := U_CadMVP(SMovPessoal, @cMsg)
	
	//Retorno
	::SRetorno:RETORNO 	:= nRetorno
	::SRetorno:MENSAGEM	:= cMsg
	
Return .T.
//-------------------------------------------------------------------
/*{Protheus.doc} IncMedGCT
Inclusao de Medicao de Contratos

@author Guilherme.Santos
@since 28/12/2015
@version P12
*/
//-------------------------------------------------------------------
WSMethod IncMedGCT WSReceive cEmpTit, cFilTit, cToken, nOperacao, aInDataGCT WsSend sRetorno WSService wsIntegracaoFluig
	Local lEncerra	:= If(::nOperacao == 4, .T., .F.)
	Local lRetorno	:= .T.
	Local oContrato	:= NIL
	Local nI			:= 0
	Local nTrans		:= 0
	Local cCampo		:= ""
	Local xValor		:= ""
	Local xIdFluig		:= ""
	Local nItem		:= 0
	Local lCabecalho	:= .F.
	Local lItens		:= .F.
	Local cCNAalias
	Local cSA2alias
	Local nIdx1 := 0
	Local nIdx2 := 0
	Local nIdx3 := 0
	Local nIdx4 := 0
	Local nIdx5 := 0
	Local nOperacao	:= 0
		
	//campos obrigatorios no execauto de contratos com planilha
	Local lFilialInf := .F. //CND_FILIAL
	Local lContraInf := .F. //CND_CONTRA
	Local lRevisaInf := .F. //CND_REVISA
	Local lCompetInf := .F. //CND_COMPET 
	Local lNumeroInf := .F. //CND_NUMERO 
	Local lNumMedInf := .F. //CND_NUMMED
	Local lForneInf  := .F. //CND_FORNEC
	Local lLjForInf  := .F. //CND_LJFORN
	Local lMoedaInf  := .F. //CND_MOEDA  default: 1
	Local lZeradoInf := .F. //CND_ZERO   default: 2
	Local lPrcelInf  := .F. //CND_PARCEL default: ---
	Local lLocPlanilha := .F.
	Local lLocFornec  := .F.
	Local lMedSevico  := .F.
	
	Local nX3TIPO := SX3->(FIELDPOS("X3_TIPO"))
	Local nX3TAMANHO := SX3->(FIELDPOS("X3_TAMANHO"))
	
	
	Private xCritMed	  := ""
	
	Private aTabelas		:= {"CN9", "CNC", "CNA", "CNB", "CND", "CNE", "CN1", "CNF", "CNS", "CNZ"}
	Private cContrato		:= ""
	Private cRevisao		:= ""
	Private cFileLog		:= "CNTA120.LOG"
	Private aContrato		:= {}
	Private aItemCtr		:= {}
	Private aItnsCtr		:= {}
	Private lExibeTela		:= .F.
	Private lGravaLog		:= .T.
	Private cMensagem		:= ""
//	Private cFileLog		:= "MATAXXX.LOG"
	Private cPathLog		:= "\LOGS\"
	Private cEmpBkp		:= ""
	Private cFilBkp		:= ""
	Private cEmpGrv		:= ""
	Private cFilGrv		:= ""
		
	
	Console("Preparando Ambiente para Inclusao da Medicao - Empresa: " + ::cEmpTit + " - Filial: " + ::cFilTit)
	Conout("IncMedGCT", HttpOtherContent())
//	RPCSetType(3)
	RpcSetEnv(::cEmpTit, ::cFilTit, NIL, NIL, "GCT", NIL, {"CN9", "CNC", "CNA", "CNB", "CND", "CNE", "CN1", "CNF", "CNS", "CNZ"})
	
//	U_CP12ADD("000004", "SZC", 1, HttpOtherContent(), )
	
	If VldEmpFil(::cEmpTit, ::cFilTit)
		Console("Validando Token")
		lRetorno := VldToken(::cToken)
		
		If lRetorno
			Console("Token Valido.")
			
			If Empty(::aInDataGCT)
				//::cRetorno		:= "Dados invalidos"
				
				::SRetorno:RETORNO 	:= 0
				::SRetorno:MENSAGEM	:= "Dados invalidos"
				::SRetorno:ID       := ""
				
				lRetorno 		:= .F.
			Else
				Console("Verificando dados recebidos para Integracao")
				
				nTrans := Len(::aInDataGCT:NewInGCT)
				
				Console("Quantidade de Campos Recebidos: " + StrZero(nTrans, 3))
				
				If nTrans > 0
					
					Console("Inicializando o Objeto para gravacao do Contrato.")
					
					//oContrato	:= uMedicao():New()
					
					Console("Adicionando dados do Contrato")
					
					DbSelectArea("SX3")
					DbSetOrder(2)		//X3_CAMPO
					
					aItemCtr := {}
					
					For nI := 1 to Len(::aInDataGCT:NewInGCT)
						cCampo		:= ::aInDataGCT:NewInGCT[nI]:cCpoGCT
						cCampo		:= cCampo + Space(10 - Len(cCampo))
						xValor		:= ::aInDataGCT:NewInGCT[nI]:xVlrGCT
						lCabecalho	:= .F.
						lItens		:= .F.
						
						If "CND_" $ cCampo
							lCabecalho := .T.
						Else
						    If "CNE_" $ cCampo
								lItens := .T.
								
								If AllTrim(cCampo) == "CNE_ITEM"
									nItem	+= 1
									
									If nItem > 1
										//Aadd(oContrato:aItens, {})
										//oContrato:SetItem()
										AADD(aItnsCtr,aItemCtr )
										aItemCtr := {}
									EndIf
									
								EndIf
							EndIf
						EndIf
						
						Console("Campo: " + cCampo + "|xValor: " + xValor + "|")
						
						If SX3->(DbSeek(cCampo))
							Do Case 
							Case SX3->(FIELDGET(nX3TIPO)) == "N"
								xValor := Val(xValor)
							Case SX3->(FIELDGET(nX3TIPO)) == "D"
								xValor := CtoD(xValor)
							Case SX3->(FIELDGET(nX3TIPO)) == "C" 
								xValor := xValor + Space(SX3->(FIELDGET(nX3TAMANHO)) - Len(xValor))
							EndCase
						EndIf
						
						If lCabecalho
							
//							oContrato:AddCabec(cCampo, xValor)
							U_ALMED01C(cCampo, xValor)
							
//							AADD(cContrato,{})
							
							If AllTrim(cCampo) == 'CND_XIDFLG'
								nIdx := aScan(aContrato ,{|x| AllTrim(x[1]) == 'CND_XIDFLG'})
								If nIdx > 0
									xIdFluig := ALLTRIM(xValor)//<--estes campo sao consultados adiantes, por isto, populamos eles tb! 
								EndIf
							EndIf
							
							If AllTrim(cCampo) == 'CND_REVISA'
								nIdx := aScan(aContrato,{|x| AllTrim(x[1]) == 'CND_REVISA'})
								If nIdx > 0
									cRevisao := xValor//<--estes campo sao consultados adiantes, por isto, populamos eles tb! 
								EndIf
							EndIf
							
							If AllTrim(cCampo) == 'CND_CONTRA'
								nIdx := aScan(aContrato,{|x| AllTrim(x[1]) == 'CND_CONTRA'})
								If nIdx > 0
									cContrato := xValor//<--estes campo sao consultados adiantes, por isto, populamos eles tb! 
								EndIf
							EndIf
							
							
							
						ElseIf lItens
//							oContrato:AddItem(cCampo, xValor)
							
							U_ALMED01I(cCampo, xValor)
							
							
							//Aadd(oContrato:aItens, {})
							//aAdd(oContrato:aItens[Len(oContrato:aItens)], {cCampo,xValor,NIL} )
								
						EndIf
					Next nI
					
					IF LEN(aItemCtr) > 0 
						AADD(aItnsCtr,aItemCtr )
					ENDIF 
					/*
					If lItens
						oContrato:SetItem()
					EndIf
					*/
					
					Console("Inicio da Gravacao da Medicao")
					
					//======= Verifica se nos enviaram os campos que sao obroigatorios no ato do execauto da medicao. ALguns campos, caso nao enbviados, calcularemos por conta propria(Vide adiante)
					nIdx := aScan(aContrato,{|x| AllTrim(x[1]) == 'CND_FILIAL'})
					
					If nIdx == 0
						cCampo := 'CND_FILIAL'
						xValor := cFilAnt
						lFilialInf := .T.
//						oContrato:AddCabec(cCampo, xValor)
						U_ALMED01C(cCampo, xValor)
					Else
						lFilialInf := .T.
					EndIf
					
					
					nIdx := aScan(aContrato,{|x| AllTrim(x[1]) == 'CND_CONTRA'})
					
					If nIdx > 0
						lContraInf := .T.
					EndIf
		
					nIdx := aScan(aContrato,{|x| AllTrim(x[1]) == 'CND_REVISA'})
					
					If nIdx > 0
						lRevisaInf := .T.
					EndIf
					
					nIdx := aScan(aContrato,{|x| AllTrim(x[1]) == 'CND_COMPET'})
					
					If nIdx > 0
						lCompetInf := .T.
					EndIf
					
					nIdx := aScan(aContrato,{|x| AllTrim(x[1]) == 'CND_NUMERO'})
					
					If nIdx > 0
						lNUmeroInf := .T.
					EndIf
			
					nIdx := aScan(aContrato,{|x| AllTrim(x[1]) == 'CND_SERVIC'})
					
					If nIdx > 0
						lMedSevico  := .T.
					EndIf
					
					nIdx := aScan(aContrato,{|x| AllTrim(x[1]) == 'CND_NUMMED'})
					
					If nIdx > 0
						lNumMedInf := .T.
					Else
						xValor := CN130NumMd()//gera o proximo numero de medicao
						cCampo := 'CND_NUMMED'
//						oContrato:AddCabec(cCampo, xValor)
						U_ALMED01C(cCampo, xValor)
						lNumMedInf := .T.
					EndIf


					nIdx := aScan(aContrato,{|x| AllTrim(x[1]) == 'CND_FORNEC'})
					
					If nIdx > 0
						lForneInf := .T.
					EndIf

					nIdx := aScan(aContrato,{|x| AllTrim(x[1]) == 'CND_LJFORN'})
					
					If nIdx > 0
						lLjForInf := .T.
					EndIf
	
					lLocFornec := .F.
					
					If lForneInf .ANd. lLjForInf 				
						cSA2alias := GetNextAlias()
						
						nIdx1 := aScan(aContrato,{|x| AllTrim(x[1]) == 'CND_LJFORN'})
						nIdx2 := aScan(aContrato,{|x| AllTrim(x[1]) == 'CND_FORNEC'})
						
						BeginSql Alias cSA2alias
							
							SELECT SA2.*       
							       FROM %table:SA2% SA2
							              
							       WHERE              
							             SA2.A2_FILIAL     = %xFilial:SA2%
							             AND SA2.%NotDel%
							             AND SA2.A2_COD     = %EXP:( aContrato[nIdx2][2]    )%    
							             AND SA2.A2_LOJA     = %EXP:( aContrato[nIdx1][2]    )%    
							                
						EndSql
							
						If (cSA2alias)->(!Eof()) .And. AllTrim((cSA2alias)->(A2_COD)) == AllTrim(aContrato[nIdx2][2]) 	.And. AllTrim((cSA2alias)->(A2_LOJA)) == AllTrim(aContrato[nIdx1][2]) 
							lLocFornec := .T.
						EndIf
						
						(cSA2alias)->(DbCLoseArea())
					
					EndIf
					
					
					lLocPlanilha := .F.
					
					
					If lLocFornec .And. lForneInf .ANd. lLjForInf .And. lNUmeroInf .And. lContraInf .And. lRevisaInf				
					
						cCNAalias := GetNextAlias()
						
						nIdx1 := aScan(aContrato,{|x| AllTrim(x[1]) == 'CND_LJFORN'})
						nIdx2 := aScan(aContrato,{|x| AllTrim(x[1]) == 'CND_FORNEC'})
						nIdx3 := aScan(aContrato,{|x| AllTrim(x[1]) == 'CND_NUMERO'})
						nIdx4 := aScan(aContrato,{|x| AllTrim(x[1]) == 'CND_CONTRA'})
						nIdx5 := aScan(aContrato,{|x| AllTrim(x[1]) == 'CND_REVISA'})
					
						BeginSql Alias cCNAalias
							
							SELECT CNA.*       
							       FROM %table:CNA% CNA
							              
							       WHERE              
							             CNA.CNA_FILIAL     = %xFilial:CNA%
							             AND CNA.%NotDel%
							             AND CNA.CNA_CONTRA     = %EXP:( aContrato[nIdx4][2]    )%    
							             AND CNA.CNA_REVISA     = %EXP:( aContrato[nIdx5][2]    )%    
							             AND CNA.CNA_NUMERO     = %EXP:( aContrato[nIdx3][2]    )%    
							             AND CNA.CNA_FORNEC     = %EXP:( aContrato[nIdx2][2]    )%    
							             AND CNA.CNA_LJFORN     = %EXP:( aContrato[nIdx1][2]    )%    
							                
						EndSql
							
						If (cCNAalias)->(!Eof()) .And. AllTrim((cCNAalias)->(CNA_CONTRA)) == AllTrim(aContrato[nIdx4][2]) ;
						                         .And. AllTrim((cCNAalias)->(CNA_REVISA)) == AllTrim(aContrato[nIdx5][2]) ;
						                         .And. AllTrim((cCNAalias)->(CNA_NUMERO)) == AllTrim(aContrato[nIdx3][2]) ;
						                         .And. AllTrim((cCNAalias)->(CNA_FORNEC)) == AllTrim(aContrato[nIdx2][2]) .And. AllTrim((cCNAalias)->(CNA_LJFORN )) == AllTrim(aContrato[nIdx1][2])
							
							lLocPlanilha := .T.	
						EndIf
						
						(cCNAalias)->(DbCLoseArea())
						
					EndIf
					
					nIdx := aScan(aContrato,{|x| AllTrim(x[1]) == 'CND_MOEDA'})
					
					If nIdx > 0
						lMoedaInf := .T.
					Else
						lMoedaInf := .T.
						xValor := '1'
						cCampo := 'CND_MOEDA'
//						oContrato:AddCabec(cCampo, xValor)
						U_ALMED01C(cCampo, xValor)
					EndIf
					
					nIdx := aScan(aContrato,{|x| AllTrim(x[1]) == 'CND_ZERO'})
					
					If nIdx > 0
						lZeradoInf := .T.						
					Else	
						xValor := '2'
						cCampo := 'CND_ZERO'
//						oContrato:AddCabec(cCampo, xValor)
						U_ALMED01C(cCampo, xValor)
						lZeradoInf := .T.	
					EndIf
					
					nIdx := aScan(aContrato,{|x| AllTrim(x[1]) == 'CND_PARCEL'})
					
					If nIdx > 0
						lPrcelInf := .T.						
					Else	
						xValor := '---'
						cCampo := 'CND_PARCEL'
//						oContrato:AddCabec(cCampo, xValor)
						U_ALMED01C(cCampo, xValor)
						lPrcelInf := .T.	
					EndIf	
					
										
					If lLocFornec .And. lLocPlanilha .And. lMedSevico .And. ;
					   lFilialInf .And. lContraInf .And. lRevisaInf .And. lCompetInf .And. lNumeroInf .And. lNumMedInf .And.  ; 
					   lForneInf .ANd.  lLjForInf  .ANd. lMoedaInf  .ANd. lZeradoInf .ANd. lPrcelInf
					    
					    xCritMed := ""
						nOperacao := 3
						
						IF LEN(aItnsCtr) == 0 
							AADD(aItnsCtr,aItemCtr )
						ENDIF 
							
						If U_ALMED01G(lEncerra, nOperacao, xIdFluig)
						
							nIdx := aScan(aContrato,{|x| AllTrim(x[1]) == 'CND_NUMMED'})
					
							If nIdx > 0
								//::cRetorno :=  " > Operacao Concluida com Sucesso. Medição: " + Alltrim(oContrato:ACABEC[nIdx][2])
								::SRetorno:RETORNO 	:= 0
								::SRetorno:MENSAGEM	:= " > Operacao Concluida com Sucesso. Medição: " + Alltrim(aContrato[nIdx][2])
								::SRetorno:ID       := Alltrim(aContrato[nIdx][2])
		
							Else
								//::cRetorno :=  " >  Operacao Concluida com Sucesso. "
								::SRetorno:RETORNO 	:= 0
								::SRetorno:MENSAGEM	:= " >  Operacao Concluida com Sucesso. "
								::SRetorno:ID       := ""
							EndIf
							
							Console(::SRetorno:MENSAGEM/*::cRetorno*/)
						Else
							//::cRetorno		:=  oContrato:xCritMed + oContrato:GetMensagem()
							
							::SRetorno:RETORNO 	:= 0
							::SRetorno:MENSAGEM	:= oContrato:xCritMed + oContrato:GetMensagem()
							::SRetorno:ID       := ""
							lRetorno 		:= .F.
							
							Console(" > Erro na Gravacao da Medicao." + oContrato:xCritMed )
							Console(::SRetorno:MENSAGEM/*::cRetorno*/)
						EndIf
					Else
											
						If !lFilialInf .And. lRetorno 
							
							::SRetorno:RETORNO 	:= 0
							::SRetorno:MENSAGEM	:="Informe o campo 'Filial' para gerar a medição no sistema!" 
							::SRetorno:ID       := ""
							
							//::cRetorno		:= "Informe o campo 'Filial' para gerar a medição no sistema!"
							lRetorno 		:= .F.
							Console("Erro na Gravacao da Medicao.")
							Console(::SRetorno:MENSAGEM/*::cRetorno*/)
						EndIf
					
						If !lContraInf .And. lRetorno 
							::SRetorno:RETORNO 	:= 0
							::SRetorno:MENSAGEM	:="Informe o campo 'Contrato' para gerar a medição no sistema!" 
							::SRetorno:ID       := ""
							
							//::cRetorno		:= "Informe o campo 'Contrato' para gerar a medição no sistema!"
							lRetorno 		:= .F.
							Console("Erro na Gravacao da Medicao.")
							Console(::SRetorno:MENSAGEM/*::cRetorno*/)
						EndIf
						If !lRevisaInf .And. lRetorno 
							::SRetorno:RETORNO 	:= 0
							::SRetorno:MENSAGEM	:="Informe o campo 'Revisão' para gerar a medição no sistema!" 
							::SRetorno:ID       := ""
							
							//::cRetorno		:= "Informe o campo 'Revisão' para gerar a medição no sistema!"
							lRetorno 		:= .F.
							Console("Erro na Gravacao da Medicao.")
							Console(::SRetorno:MENSAGEM/*::cRetorno*/)
						EndIf
						If !lCompetInf .And. lRetorno 
							::SRetorno:RETORNO 	:= 0
							::SRetorno:MENSAGEM	:="Informe o campo 'Competência' para gerar a medição no sistema!" 
							::SRetorno:ID       := ""
							
							//::cRetorno		:= "Informe o campo 'Competência' para gerar a medição no sistema!"
							lRetorno 		:= .F.
							Console("Erro na Gravacao da Medicao.")
							Console(::SRetorno:MENSAGEM/*::cRetorno*/)
						EndIf
						If !lNumeroInf .And. lRetorno 
							::SRetorno:RETORNO 	:= 0
							::SRetorno:MENSAGEM	:="Informe o campo 'Nro da Planilha' para gerar a medição no sistema!" 
							::SRetorno:ID       := ""
							
							//::cRetorno		:= "Informe o campo 'Nro da Planilha' para gerar a medição no sistema!"
							lRetorno 		:= .F.
							Console("Erro na Gravacao da Medicao.")
							
							Console(::SRetorno:MENSAGEM/*::cRetorno*/)
						EndIf
						If !lNumMedInf .And. lRetorno 
							::SRetorno:RETORNO 	:= 0
							::SRetorno:MENSAGEM	:="Informe o campo 'Nro da Medição' para gerar a medição no sistema!" 
							::SRetorno:ID       := ""
							
							//::cRetorno		:= "Informe o campo 'Nro da Medição' para gerar a medição no sistema!"
							lRetorno 		:= .F.
							Console("Erro na Gravacao da Medicao.")
							
							Console(::SRetorno:MENSAGEM/*::cRetorno*/)
						EndIf
						If !lFOrneInf .And. lRetorno 
							::SRetorno:RETORNO 	:= 0
							::SRetorno:MENSAGEM	:="Informe o campo 'Fornecedor' para gerar a medição no sistema!" 
							::SRetorno:ID       := ""
							
							//::cRetorno		:= "Informe o campo 'Fornecedor' para gerar a medição no sistema!"
							lRetorno 		:= .F.
							Console("Erro na Gravacao da Medicao.")
							
							Console(::SRetorno:MENSAGEM/*::cRetorno*/)
						EndIf
						If !lLjForInf .And. lRetorno 
							::SRetorno:RETORNO 	:= 0
							::SRetorno:MENSAGEM	:="Informe o campo 'Loja do Fornecedor' para gerar a medição no sistema!" 
							::SRetorno:ID       := ""
							
							//::cRetorno		:= "Informe o campo 'Loja do Fornecedor' para gerar a medição no sistema!"
							lRetorno 		:= .F.
							Console("Erro na Gravacao da Medicao.")
							
							Console(::SRetorno:MENSAGEM/*::cRetorno*/)
						EndIf
						
						If !lMoedaInf .And. lRetorno 
							::SRetorno:RETORNO 	:= 0
							::SRetorno:MENSAGEM	:="Informe o campo Moeda para gerar a medição no sistema!" 
							::SRetorno:ID       := ""
							
							//::cRetorno		:= "Informe o campo Moeda para gerar a medição no sistema!"
							lRetorno 		:= .F.
							Console("Erro na Gravacao da Medicao.")
							
							Console(::SRetorno:MENSAGEM/*::cRetorno*/)
						EndIf
					
						If !lZeradoInf .And. lRetorno 
							::SRetorno:RETORNO 	:= 0
							::SRetorno:MENSAGEM	:="Informe o campo ZERO(CND_ZERO para gerar a medição no sistema!" 
							::SRetorno:ID       := ""
							
							//::cRetorno		:= "Informe o campo ZERO(CND_ZERO para gerar a medição no sistema!"
							lRetorno 		:= .F.
							Console("Erro na Gravacao da Medicao.")
							
							Console(::SRetorno:MENSAGEM/*::cRetorno*/)
						EndIf
						
						If !lPrcelInf .And. lRetorno 
							::SRetorno:RETORNO 	:= 0
							::SRetorno:MENSAGEM	:= "Informe o campo Parcela para gerar a medição no sistema!"
							::SRetorno:ID       := ""
							
							//::cRetorno		:= "Informe o campo Parcela para gerar a medição no sistema!" 
							lRetorno 		:= .F.
							Console("Erro na Gravacao da Medicao.")
							
							Console(::SRetorno:MENSAGEM/*::cRetorno*/)
						EndIf
						
						If !lLocFornec .And. lRetorno 
							::SRetorno:RETORNO 	:= 0
							::SRetorno:MENSAGEM	:= "Informe um fornecedor existente sistema!"
							::SRetorno:ID       := ""
							 
							lRetorno 		:= .F.
							Console("Erro na Gravacao da Medicao.")
							
							Console(::SRetorno:MENSAGEM/*::cRetorno*/)
						EndIf
						
						
						If !lLocPlanilha .And. lRetorno 
							::SRetorno:RETORNO 	:= 0
							::SRetorno:MENSAGEM	:= "Informe uma planilha existente no sistema!"
							::SRetorno:ID       := ""
							
							//::cRetorno		:= "Informe o campo Parcela para gerar a medição no sistema!" 
							lRetorno 		:= .F.
							Console("Erro na Gravacao da Medicao.")
							
							Console(::SRetorno:MENSAGEM/*::cRetorno*/)
						EndIf
						
						If !lMedSevico .And. lRetorno 
							::SRetorno:RETORNO 	:= 0
							::SRetorno:MENSAGEM	:= "Informe o conteúdo do campo Medição de Serviço (CND_SERVIC) !"
							::SRetorno:ID       := ""
							
							//::cRetorno		:= "Informe o campo Parcela para gerar a medição no sistema!" 
							lRetorno 		:= .F.
							Console("Erro na Gravacao da Medicao.")
							
							Console(::SRetorno:MENSAGEM/*::cRetorno*/)
						EndIf
						
						
					EndIf
					
				EndIf
			EndIf
		Else
			::SRetorno:RETORNO 	:= 0
			::SRetorno:MENSAGEM	:= "Token Invalido"
			::SRetorno:ID       := ""
							
			//::cRetorno := "Token Invalido"
			lRetorno := .F.
		EndIf
	Else
		::SRetorno:RETORNO 	:= 0
		::SRetorno:MENSAGEM	:= "->Empresa ou Filial invalida"
		::SRetorno:ID       := " "
			
		//::cRetorno	:= "Empresa ou Filial invalida"
		lRetorno	:= .F.
	EndIf
	 
	If !lRetorno
		Console(::SRetorno:MENSAGEM	/*::cRetorno*/)
		SetSoapFault("[WSIntFluig]", ::SRetorno:MENSAGEM/*::cRetorno*/)
	EndIf

//	RPCClearEnv()
	
Return lRetorno //cretorno
//-------------------------------------------------------------------
/*{Protheus.doc} IncTitPag
Inclusao Contas a Pagar

@author Guilherme.Santos
@since 21/12/2015
@version P12
*/
//-------------------------------------------------------------------
WSMethod IncTitPag WSReceive cEmpTit, cFilTit, cToken, nOperacao, aInDataSE2, aInDataSEV WsSend cRetorno WSService wsIntegracaoFluig
	Local nTrans		:= 0
	Local nI			:= 0
	Local nJ			:= 0
	Local nK			:= 0
	
	Local lRetorno	:= .T.
	
	Local oTitulo		:= NIL
	
	Local cCampo		:= ""
	Local xValor		:= ""
	
	Local aRateio		:= {}
	Local cTipoSX3		:= "" 
	
	Local nX3TIPO 	 := SX3->(FIELDPOS("X3_TIPO"))
	Local nX3TAMANHO := SX3->(FIELDPOS("X3_TAMANHO"))
	
	Private INCLUI	:= .T.
	
	Conout("IncTitPag", httpOthercontent())
	Console("Preparando Ambiente para Gravacao do Titulo - Empresa: " + ::cEmpTit + " - Filial: " + ::cFilTit, .F., .F.)
	
	RpcSetEnv(::cEmpTit, ::cFilTit, NIL, NIL, "FIN", NIL, {"SE2", "SA2", "SEV", "SEZ"})
	
	If VldEmpFil(::cEmpTit, ::cFilTit)
		Console("Validando Token", .F., .F.)
		lRetorno := VldToken(::cToken)
		
		If lRetorno
			Console("Token Valido.", .F., .F.)
			
			If Empty(::aInDataSE2)
				::cRetorno		:= "Dados invalidos"
				lRetorno 		:= .F.
			Else
				Console("Verificando dados recebidos para Integracao", .F., .F.)
				
				nTrans := Len(::aInDataSE2:NewInSE2)
				
				Console("Quantidade de Campos Recebidos: " + StrZero(nTrans, 3), .F., .F.)
				
				If nTrans > 0
					
					Console("Inicializando o Objeto para gravacao dos Titulos.", .F., .F.)
					
					oTitulo := uTitPagar():New()
					
					oTitulo:AddValues("EMPRESA"		, ::cEmpTit)
	
					Console("Adicionando dados do Titulo", .F., .F.)
					
					DbSelectArea("SX3")
					DbSetOrder(2)		//X3_CAMPO
					
					For nI := 1 to Len(::aInDataSE2:NewInSE2)
						cCampo		:= ::aInDataSE2:NewInSE2[nI]:cCpoSE2
						cCampo		:= cCampo + Space(10 - Len(cCampo))
						xValor		:= ::aInDataSE2:NewInSE2[nI]:xVlrSE2
						
						Console("Campo: " + cCampo + "|xValor: " + xValor + "|", .F., .F.)
						
						If SX3->(DbSeek(cCampo))
							
							cTipoSX3	:= SX3->(FIELDGET(nX3TIPO))
							
							Do Case //|nX3TIPO
							Case cTipoSX3 == "N"
								xValor := Val(xValor)
							Case cTipoSX3 == "D"
								xValor := CtoD(xValor)
							Case cTipoSX3 == "C" 
								xValor := xValor + Space(SX3->(FIELDGET(nX3TAMANHO)) - Len(xValor))
							EndCase
						EndIf
						
						oTitulo:AddValues(cCampo, xValor)
					Next //|nI
					
					Console("Verificando dados do Rateio", .F., .F.)
					
					nTrans := Len(::aInDataSEV:NewDataSEV)
					Console("Quantidade de Registros Recebidos do Rateio por Natureza: " + StrZero(nTrans, 3), .F., .F.)

					/*
					aAdd(aRatAux, {"CTJ_PERCEN", 99.99		, Nil})
					aAdd(aRatAux, {"CTJ_VALOR",  150.00	, Nil})
					aAdd(aRatAux, {"CTJ_CCD",    ""			, Nil})
					aAdd(aRatAux, {"CTJ_DESC",   "Teste"	, Nil})
					*/				

					If nTrans > 0
						For nI := 1 to Len(::aInDataSEV:NewDataSEV)
							
							Console("Quantidade de Campos Recebidos do Rateio por Centro de Custo: " + StrZero(Len(::aInDataSEV:NewDataSEV[nI]:NewRegSEV), 3), .F., .F.)
							
							DbSelectArea("SX3")
							DbSetOrder(2)		//X3_CAMPO
							
							For nJ := 1 to Len(::aInDataSEV:NewDataSEV[nI]:NewRegSEV)
								cCampo := ::aInDataSEV:NewDataSEV[nI]:NewRegSEV[nJ]:cCpoSEV
								xValor := ::aInDataSEV:NewDataSEV[nI]:NewRegSEV[nJ]:xVlrSEV
								
								Console("Campo: " + cCampo + "|xValor: " + xValor + "|", .F., .F.)
								
								If SX3->(DbSeek(cCampo))
									Do Case
									Case SX3->(FIELDGET(nX3TIPO)) == "N"
										xValor := Val(xValor)
									Case SX3->(FIELDGET(nX3TIPO)) == "D"
										xValor := CtoD(xValor)
									Case SX3->(FIELDGET(nX3TIPO)) == "C"
										xValor := xValor + Space(SX3->(FIELDGET(nX3TAMANHO)) - Len(xValor))
									EndCase
								EndIf

								oTitulo:AddRatCC(cCampo, xValor)								
							Next nJ

							oTitulo:SetRatCC()
						Next nI
					EndIf
					
					Console("Inicio da Gravacao do Titulo", .F., .F.)
					
					If oTitulo:Gravacao(3)
						::cRetorno := "Operacao Concluida com Sucesso."
						::cRetorno += "Prefixo: " + oTitulo:GetPrefixo()
						::cRetorno += "-Titulo: " + oTitulo:GetTitulo()
						::cRetorno += "-Parcela: " + oTitulo:GetParcela()
						::cRetorno += "-Tipo: " + oTitulo:GetTipo()
						::cRetorno += "-Fornecedor: " + oTitulo:GetFornece()
						::cRetorno += "-Loja: " + oTitulo:GetLoja()
						Console(::cRetorno)
					Else
						::cRetorno		:= oTitulo:GetMensagem()
						lRetorno 		:= .F.
						Console("Erro na Gravacao do Titulo.", .F., .F.)
						Console(::cRetorno, .F., .F.)
					EndIf
				EndIf
			EndIf
		Else
			::cRetorno := "Token Invalido"
			lRetorno := .F.
		EndIf
	Else
		::cRetorno := "Empresa ou Filial invalidas."
		lRetorno := .F.
	EndIf
	
	If !lRetorno
		Console(::cRetorno, .F., .F.)
		SetSoapFault("[WSIntFluig]", ::cRetorno)
	EndIf

	Console("IncTitPag", .F., .F.)

Return lRetorno

/*/{Protheus.doc} IncSolArm

@author Jorge Heitor
@since 22/12/2015
@version 12.1.007
@description Método para inclusão de Solicitação ao Armazém automática
@obs ALLIAR

@return Boolean, .T.
/*/
WsMethod IncSolArm WsReceive xRecIncSol WsSend xRetIncSol WsService wsIntegracaoFluig
	Local lRet			:= .T.
	Local cMsgErro	:= ""
	Local nX			:= 0
	Local oSolArm		:= uSolArmazem():New()
	Local oPreReq		:= uPreReq():New()

	Console("IncSolArm",HttpOtherContent())
	Console("Preparando Ambiente para Inclusao da Solicitacao ao Armazem - Empresa: " + ::xRecIncSol:cEmp + " - Filial: " + ::xRecIncSol:cFil, .F., .F.)

	//Prepara Ambiente
	RpcSetEnv(::xRecIncSol:cEmp, ::xRecIncSol:cFil, NIL, NIL, "EST", NIL, {"SCP", "SB1", "SAH","SAI","SC1"})

	Console("Validando Token", .F., .F.)

	If VldToken(::xRecIncSol:cToken)

		Console("Token Valido.", .F., .F.)

		If VldEmpFil(::xRecIncSol:cEmp, ::xRecIncSol:cFil)

			oSolArm:AddCabec("EMPRESA"		, ::xRecIncSol:cEmp)
			oSolArm:AddCabec("CP_FILIAL"	, ::xRecIncSol:cFil)
			oSolArm:AddCabec("CP_EMISSAO"	, dDatabase)
			oSolArm:AddCabec("CP_XIDFLG"	, ::xRecIncSol:cIdFluig)

			//Monta Array de Itens
			For nX := 1 To Len(::xRecIncSol:aItens)
				
				oSolArm:AddItem("CP_FILIAL"		, ::xRecIncSol:cFil)
				oSolArm:AddItem("CP_ITEM"		, ::xRecIncSol:aItens[nX]:cItem)
				oSolArm:AddItem("CP_PRODUTO"	, ::xRecIncSol:aItens[nX]:cProduto)
				oSolArm:AddItem("CP_UM"			, ::xRecIncSol:aItens[nX]:cUM)
				oSolArm:AddItem("CP_QUANT"		, Val(::xRecIncSol:aItens[nX]:nQuant))
				oSolArm:AddItem("CP_SEGUM"		, ::xRecIncSol:aItens[nX]:cSegUm)
				oSolArm:AddItem("CP_DATPRF"		, CtoD(::xRecIncSol:aItens[nX]:dDatPrf))
				oSolArm:AddItem("CP_LOCAL"		, ::xRecIncSol:aItens[nX]:cArmazem)
				oSolArm:AddItem("CP_OBS"			, ::xRecIncSol:aItens[nX]:cObs)
				oSolArm:AddItem("CP_CC"			, ::xRecIncSol:aItens[nX]:cCC)
				oSolArm:AddItem("CP_NUMSC"		, ::xRecIncSol:aItens[nX]:cNumSC)
				oSolArm:AddItem("CP_XIDFLG"		, ::xRecIncSol:cIdFluig)

				oSolArm:SetItem()
			Next nX
			
			Begin Transaction

				Console("Incluindo Solicitacao ao Armazem: " + ::xRecIncSol:cIdFluig, .F., .F.)

				If oSolArm:Gravacao(3)
					Console("Solicitação ao Armazém '" + oSolArm:GetNumero() + "' gerada no Protheus com sucesso!", .F., .F.)
					
					Console("Incluindo Pre-Requisicao: " + ::xRecIncSol:cIdFluig, .F., .F.)

					If oPreReq:Gravacao(oSolArm:GetNumero())
						::xRetIncSol	:= oPreReq:GetNumero()
						
						If Empty(::xRetIncSol)
							::xRetIncSol := oSolArm:GetNumero()
						EndIf
					Else
						cMsgErro		:= "Erro na Gravação da Pre Requisição ao Armazém." + CRLF
						cMsgErro		+= oPreReq:GetMensagem()

						Console(cMsgErro + CRLF + ::xRecIncSol:cIdFluig, .F., .F.)
	
						lRet			:= .F.
						DisarmTransaction()
					EndIf
				Else
					cMsgErro		:= "Erro na Gravação da Solicitacao ao Armazém." + CRLF
					cMsgErro	:= oSolArm:GetMensagem()

					Console(cMsgErro, .F., .F.)

					lRet 		:= .F.
					DisarmTransaction()
				EndIf
			End Transaction
		Else
			cMsgErro	:= "Empresa/Filial inválida(s)."
			lRet 		:= .F.

			Console(cMsgErro, .F., .F.)
		EndIf
	Else
		cMsgErro	:= "Token inválido."
		lRet 		:= .F.
		Console(cMsgErro, .F., .F.)
	EndIf

	If !lRet
		SetSoapFault("IncSolArm", cMsgErro)
	EndIf

Return lRet
//-------------------------------------------------------------------
/*{Protheus.doc} ExcSolArm
Exclusao da Solicitacao ao Armazem

@author Guilherme Santos
@since 26/04/2016
@version P12
*/
//-------------------------------------------------------------------
WsMethod ExcSolArm WsReceive cEmpSol, cFilsol, cToken, cSolIDFlg WsSend cRetorno WsService wsIntegracaoFluig
	Local cMsgErro	:= ""
	Local lRetorno 	:= .T.

	Console("Preparando Ambiente para Exclusao da Solicitacao ao Armazem - Empresa: " + ::cEmpSol + " - Filial: " + ::cFilSol, .F., .F.)

	//Prepara Ambiente
	RpcSetEnv(::cEmpSol, ::cFilSol, NIL, NIL, "EST", NIL, {"SCP", "SB1", "SAH", "SAI", "SC1"})

	Console("Validando Token", .F., .F.)

	If VldToken(::cToken)

		Console("Token Valido.", .F., .F.)

		If VldEmpFil(::cEmpSol, ::cFilSol)
			DbSelectArea("SCP")
			DbOrderNickName("CPXIDFLG")
			
			If SCP->(DbSeek(xFilial("SCP") + ::cSolIDFlg))

				Console("Excluindo Solicitacao ao Armazem: " + ::cSolIDFlg, .F., .F.)

				If !U_ALREST06("SCP", SCP->(Recno()), 5, .T., @cMsgErro)
					Console("Erro ao Excluir a Solicitacao ao Armazem: " + ::cSolIDFlg, .F., .F.)
					lRetorno	:= .F.
				EndIf
			Else			
				cMsgErro	:= "ID Fluig não localizado."
				lRetorno	:= .F.
				Console(cMsgErro, .F., .F.)
			EndIf		
		Else
			cMsgErro	:= "Empresa/Filial inválida(s)."
			lRetorno	:= .F.
			Console(cMsgErro, .F., .F.)
		EndIf
	Else
		cMsgErro	:= "Token inválido."
		lRetorno	:= .F.
		Console(cMsgErro, .F., .F.)
	EndIf

	If !lRetorno
		SetSoapFault("ExcSolArm", cMsgErro)
	EndIf
	
Return lRetorno
/*/{Protheus.doc} StatusSolArm

@author Jorge Heitor
@since 22/12/2015
@version 12.1.007
@description Método para consulta de Status da Solicitação ao Armazém
@obs ALLIAR

@return Boolean, .T.
/*/
WsMethod StatusSolArm WsReceive xRecStatSol WsSend xRetStatSol WsService wsIntegracaoFluig
	Local lRet		:= .T.
	Local cQuery	:= ""
	Local nQtdReg	:= 0
	Local nQtdEnc	:= 0
	
	If VldToken(::xRecStatSol:cToken)
		If VldEmpFil(::xRecStatSol:cEmp,::xRecStatSol:cFil)
			If Empty(::xRecStatSol:cFil) .OR. Empty(::xRecStatSol:cIdFluig)
				lRet := .F.
				SetSoapFault("StatusSolArm", "Parametros Filial ou ID Fluig não informados.")
			Else
				cQuery := " SELECT * FROM " + RetSqlName("SCP")
				cQuery += " WHERE CP_FILIAL = '" + ::xRecStatSol:cFil + "' AND CP_XIDFLG = '" + ::xRecStatSol:cIdFluig + "' AND D_E_L_E_T_ = ''"
				
				cQuery := ChangeQuery(cQuery)
				
				If Select("TSCP") > 0 ; TSCP->(dbCloseArea()) ; EndIf  //20210730 colocado () dbcloseare
					
				TcQuery cQuery Alias "TSCP" NEW
				
				While !TSCP->(Eof())
					nQtdReg++

					If TSCP->CP_STATUS == "E"
						nQtdEnc++
					EndIf

					TSCP->(DbSkip())
				End

				If nQtdReg > 0
					If nQtdReg == nQtdEnc
						::xRetStatSol := "true"
					Else
						::xRetStatSol := "false"
					EndIf
				Else
					lRet := .F.
					SetSoapFault("StatusSolArm", "ID Fluig não localizado.")
				EndIf
			EndIf
		Else
			lRet := .F.
			SetSoapFault("StatusSolArm","Empresa/Filial inválida(s).")
		EndIf
	Else
		lRet := .F.
		SetSoapFault("StatusSolArm","Token inválido.")
	EndIf
		
Return lRet
/*/{Protheus.doc} BaixaCIPA

@author Jorge Heitor
@since 14/01/2016
@version 12.1.007
@description Método para efetuar a baixa das Pendencias CIPA, bem como atualizar datas no mandato
@obs ALLIAR

@return Boolean, lRet
/*/
WsMethod BaixaCIPA WsReceive xRecBaixaCIPA WsSend xRetBaixaCIPA WsService wsIntegracaoFluig
	
	Local lRet		:= .T.
	Local x
	Local oBaixa	:= uConcluiCIPA():New()
	
	If VldToken(::xRecBaixaCIPA:cToken)
		
		If VldEmpFil(::xRecBaixaCIPA:cEmp,::xRecBaixaCIPA:cFil)
			
			oBaixa:cEmpDest := ::xRecBaixaCIPA:cEmp
			oBaixa:cFilDest := ::xRecBaixaCIPA:cFil
			oBaixa:cIDFluig := ::xRecBaixaCIPA:cIDFluig
			
			For x := 1 to Len(oBaixa:aDatas)
				
				If oBaixa:aDatas[x][1] == "TNN_CONVOC"
					
					oBaixa:aDatas[x][2] := CtoD(::xRecBaixaCIPA:aDatas:TNN_CONVOC)
					
				ElseIf oBaixa:aDatas[x][1] == "TNN_COMISS"
					
					oBaixa:aDatas[x][2] := CtoD(::xRecBaixaCIPA:aDatas:TNN_COMISS)
					
				ElseIf oBaixa:aDatas[x][1] == "TNN_COPEDI"
					
					oBaixa:aDatas[x][2] := CtoD(::xRecBaixaCIPA:aDatas:TNN_COPEDI)
					
				ElseIf oBaixa:aDatas[x][1] == "TNN_INSCRI"
					
					oBaixa:aDatas[x][2] := CtoD(::xRecBaixaCIPA:aDatas:TNN_INSCRI)
					
				ElseIf oBaixa:aDatas[x][1] == "TNN_INSCRF"
					
					oBaixa:aDatas[x][2] := CtoD(::xRecBaixaCIPA:aDatas:TNN_INSCRF)
					
				ElseIf oBaixa:aDatas[x][1] == "TNN_ELEICR"
					
					oBaixa:aDatas[x][2] := CtoD(::xRecBaixaCIPA:aDatas:TNN_ELEICR)
					
				ElseIf oBaixa:aDatas[x][1] == "TNN_CURCIP"
					
					oBaixa:aDatas[x][2] := CtoD(::xRecBaixaCIPA:aDatas:TNN_CURCIP)
					
				ElseIf oBaixa:aDatas[x][1] == "TNN_COSIND"
					
					oBaixa:aDatas[x][2] := CtoD(::xRecBaixaCIPA:aDatas:TNN_COSIND)
					
				ElseIf oBaixa:aDatas[x][1] == "TNN_POSSE"
					
					oBaixa:aDatas[x][2] := CtoD(::xRecBaixaCIPA:aDatas:TNN_POSSE)
					
				EndIf
				
			Next x
			
			//Chama método para baixa na classe uConcluiCIPA
			If oBaixa:Baixa()
				
				::xRetBaixaCIPA := oBaixa:cMsgRet
				
			Else
				
				lRet := .F.
				SetSoapFault("BaixaCIPA",oBaixa:cMsgRet)
				
			EndIf
			
		Else
			
			lRet := .F.
			SetSoapFault("BaixaCIPA","Empresa/Filial inválida(s).")
			
		EndIf
		
	Else
		
		lRet := .F.
		SetSoapFault("BaixaCIPA","Token inválido.")
		
	EndIf
	
Return lRet
//-------------------------------------------------------------------
/*{Protheus.doc} AprovaSol
Aprovacao de Solicitacao de Transferencia

@author Guilherme.Santos
@since 05/01/2016
@version P12
*/
//-------------------------------------------------------------------
WSMethod AprovaSol WSReceive cEmpSol, cFilSol, cToken, cIdentFlg, cRetAprov, cTxtAprov WsSend cRetorno WSService wsIntegracaoFluig
	Local cRetGrv		:= ""
	Local lRetorno	:= .T.
	
	Console("Preparando Ambiente para Aprovacao de Transferencia - Empresa: " + ::cEmpSol + " - Filial: " + ::cFilSol)
	
//	RPCSetType(3)
	RpcSetEnv(::cEmpSol, ::cFilSol, NIL, NIL, "EST", NIL, {"NNS", "NNT", "NNR", "SD3"})
	
	Begin Transaction
		If VldEmpFil(::cEmpSol, ::cFilSol)
			Console("Validando Token")
			If VldToken(::cToken)
				DbSelectArea("NNS")
				DbOrderNickName("XIDFLG")
				
				If NNS->(DbSeek(xFilial("NNS") + ::cIdentFlg))
					If NNS->NNS_STATUS $ "3|4"
						RecLock("NNS", .F.)
						NNS->NNS_STATUS	:= If(::cRetAprov == "1", "1", "4")
						NNS->NNS_JUSTIF	:= If(Empty(NNS->NNS_JUSTIF), "", NNS->NNS_JUSTIF + " ") + ::cTxtAprov
						MsUnlock()
						If ::cRetAprov == "1"
							lRetorno := FinSol(@cRetGrv)
							If lRetorno
								RecLock("NNS", .F.)
								NNS->NNS_STATUS	:= "2"
								MsUnlock()
								::cRetorno := "A Solicitacao foi aprovada com sucesso."
							Else
								::cRetorno := cRetGrv
							EndIf
						Else
							::cRetorno := "A Solicitacao foi rejeitada com sucesso."
						EndIf
					Else
						::cRetorno	:= "O Status (" + If(NNS->NNS_STATUS == "2", "2-Transferido", "1-Liberado") + ") da Solicitacao de Transferencia nao permite alteracoes."
						lRetorno	:= .F.
					EndIf
				Else
					::cRetorno	:= "Registro " + ::cIdentFlg + " nao localizado."
					lRetorno	:= .F.
				EndIf
			Else
				::cRetorno		:= "Token Invalido."
				lRetorno		:= .F.
			EndIf
		Else
			lRetorno		:= .F.
			::cRetorno		:= ""
		EndIf
		
		If !lRetorno
			Console(::cRetorno)
			SetSoapFault(XNOMEPROG, ::cRetorno)
			DisarmTransaction()
		EndIf
	End Transaction

	//RPCClearEnv()

Return lRetorno
//-------------------------------------------------------------------
/*{Protheus.doc} VldSolCompra
Valida as Restricoes de Compras x Grupos de Produtos

@author Guilherme Santos
@since 26/01/2016
@version P12
*/
//-------------------------------------------------------------------
WSMethod VldSolCompra WSReceive cEmpSol, cFilSol, cToken, cCodProd, cUsrMail WsSend cRetorno WSService wsIntegracaoFluig
	Local lRetorno 	:= .T.
	Local oVldSol		:= uPodeSolicitar():New()

	Console("Preparando Ambiente para Validacao do Grupo de Aprovacao - Empresa: " + ::cEmpSol + " - Filial: " + ::cFilSol)
	
//	RPCSetType(3)
	RpcSetEnv(::cEmpSol, ::cFilSol, NIL, NIL, "EST", NIL, {"SAI", "SB1", "SCW"})

	If VldEmpFil(::cEmpSol, ::cFilSol)
		If VldToken(::cToken)
			//Altera a Empresa e a Filial
			cEmpAnt := ::cEmpSol
			cFilAnt := ::cFilSol

			//Valida o Usuario x Produto
			lRetorno 		:= oVldSol:Consultar(::cUsrMail, ::cCodProd)
	
			//Recupera a Mensagem de Validacao
			::cRetorno		:= oVldSol:GetMensagem()
		Else
			lRetorno		:= .F.
			::cRetorno		:= "Token Invalido."
		EndIf
	Else
		lRetorno		:= .F.
		::cRetorno		:= "Empresa + Filial Invalida."
	EndIf

	If !lRetorno
		Console(::cRetorno)
		SetSoapFault(XNOMEPROG, ::cRetorno)
	EndIf

//	RPCClearEnv()

Return lRetorno
//-------------------------------------------------------------------
/*{Protheus.doc} ConsCC
Retorna o Centro de Custo da Filial Informada

@author Guilherme Santos
@since 24/02/2016
@version P12
*/
//-------------------------------------------------------------------
WsMethod ConsCC WSReceive cEmpSol, cFilSol, cToken WsSend xRetCC WSService wsIntegracaoFluig
	Local aArea		:= {}
	Local cQuery		:= ""
	Local cTabQry		:= ""
	Local cMsgErro	:= ""
	Local lRetorno	:= .T.

	Console("Preparando Ambiente para Retorno do Centro de Custo - Empresa: " + ::cEmpSol + " - Filial: " + ::cFilSol)
	
	RpcSetEnv(::cEmpSol, ::cFilSol, NIL, NIL, "CTB", NIL, {"CTT"})

	If VldEmpFil(::cEmpSol, ::cFilSol)
		If VldToken(::cToken)
			cQuery		:= ""
			cTabQry	:= GetNextAlias()
			
			cQuery += "SELECT 	CTT.CTT_CUSTO" + CRLF
			cQuery += ",			CTT.CTT_DESC01" + CRLF
			cQuery += "FROM 		" + RetSqlName("CTT") + " CTT" + CRLF
			cQuery += "WHERE 		CTT.CTT_FILIAL = '" + xFilial("CTT") + "'" + CRLF
			cQuery += "AND 		CTT.CTT_XEMPFI = '" + SM0->M0_CGC + "'" + CRLF
			cQuery += "AND		CTT.CTT_BLOQ <> '1'" + CRLF
			cQuery += "AND		CTT.D_E_L_E_T_ = ''" + CRLF

			cQuery := ChangeQuery(cQuery)
				
			DbUseArea(.T., "TOPCONN", TcGenQry(NIL, NIL, cQuery), cTabQry, .T., .T.)

			If (cTabQry)->(Eof())
				lRetorno := .F.
				cMsgErro	:= "Sem dados para Retorno."
			Else
				::xRetCC := WSClassNew("stRetCC")

				::xRetCC:cCodigo := (cTabQry)->CTT_CUSTO
				::xRetCC:cDescri := (cTabQry)->CTT_DESC01
			EndIf
			
			If Select(cTabQry) > 0
				(cTabQry)->(DbCloseArea())
			EndIf
		Else
			lRetorno		:= .F.
			cMsgErro		:= "Token Invalido."
		EndIf
	Else
		lRetorno		:= .F.
		cMsgErro		:= "Empresa + Filial Invalida."
	EndIf

	If !lRetorno
		Console(cMsgErro)
		SetSoapFault(XNOMEPROG, cMsgErro)
	EndIf

Return lRetorno
//-------------------------------------------------------------------
/*{Protheus.doc} AprovaReq
Aprovacao da Pre-Requisicao ao Armazem

@author Guilherme Santos
@since 08/03/2016
@version P12
*/
//-------------------------------------------------------------------
WSMethod AprovaReq WsReceive xRecIncSol WsSend cRetorno WSService wsIntegracaoFluig
	Local cIdFlg		:= ""
	Local cKeySCP		:= ""
	Local lRetorno 	:= .T.
	Local oBxaReq		:= NIL
	Local nX			:= 0

	Console("Preparando Ambiente para Aprovacao da Pre-Requisicao ao Armazem - Empresa: " + ::xRecIncSol:cEmp + " - Filial: " + ::xRecIncSol:cFil)
	
	RpcSetEnv(::xRecIncSol:cEmp, ::xRecIncSol:cFil, NIL, NIL, "EST", NIL, {"SCP", "SB1", "SAH", "SAI", "SC1", "SCQ", "SB2", "SD3"})
	
	Console("Validando Token")

	If VldToken(::xRecIncSol:cToken)

		Console("Validando Empresa / Filial")

		If VldEmpFil(::xRecIncSol:cEmp, ::xRecIncSol:cFil)

			DbSelectArea("SCP")
			DbOrderNickName("CPXIDFLG")		//CP_FILIAL, CP_XIDFLG, CP_ITEM

			Begin Transaction
				For nX := 1 To Len(::xRecIncSol:aItens)
					cIdFlg		:= ::xRecIncSol:cIdFluig + Space(TamSX3("CP_XIDFLG")[1] - Len(::xRecIncSol:cIdFluig))
					cKeySCP	:= xFilial("SCP") + cIdFlg + ::xRecIncSol:aItens[nX]:cItem
	
					If SCP->(DbSeek(cKeySCP))
						/*
						-----------------------------------------------------------------------------------------------------
							Uma Gravacao para cada Item da Pre-Requisicao
						-----------------------------------------------------------------------------------------------------	
						*/
						/*
						-----------------------------------------------------------------------------------------------------
							Inicializa o Objeto para Gravacao
						-----------------------------------------------------------------------------------------------------	
						*/
						oBxaReq := uBaixaPreReq():New()
						/*
						-----------------------------------------------------------------------------------------------------
							Campos SCP
						-----------------------------------------------------------------------------------------------------	
						*/
						oBxaReq:AddValues("CP_FILIAL"		, SCP->CP_FILIAL)
						oBxaReq:AddValues("CP_ITEM"			, SCP->CP_ITEM)
						oBxaReq:AddValues("CP_PRODUTO"		, SCP->CP_PRODUTO)
						oBxaReq:AddValues("CP_UM"			, SCP->CP_UM)
						oBxaReq:AddValues("CP_QUANT"		, Val(::xRecIncSol:aItens[nX]:nQuant))
						oBxaReq:AddValues("CP_LOCAL"		, SCP->CP_LOCAL)
						oBxaReq:AddValues("CP_OBS"			, "Baixa Originada no Fluig")
						oBxaReq:AddValues("CP_CC"			, SCP->CP_CC)
						/*
						-----------------------------------------------------------------------------------------------------
							Campos SD3
						-----------------------------------------------------------------------------------------------------	
						*/
						oBxaReq:AddValues("D3_FILIAL"		, SCP->CP_FILIAL)
						oBxaReq:AddValues("D3_TM"			, SuperGetMV("AL_TMPRERQ"))
						oBxaReq:AddValues("D3_COD"			, SCP->CP_PRODUTO)
						oBxaReq:AddValues("D3_LOCAL"		, SCP->CP_LOCAL)
						oBxaReq:AddValues("D3_QUANT"		, Val(::xRecIncSol:aItens[nX]:nQuant))
						//oBxaReq:AddValues("D3_LOTECTL"		, ::xRecIncSol:aItens[nX]:cLoteCtl)
						//oBxaReq:AddValues("D3_DOC"			, "")
						oBxaReq:AddValues("D3_EMISSAO"		, dDatabase)
						/*
						-----------------------------------------------------------------------------------------------------
							Gravacao da Baixa da Pre-Requisicao e Geracao do Movimento da SD3
						-----------------------------------------------------------------------------------------------------	
						*/
						If !oBxaReq:Gravacao(1)
							/*
							-----------------------------------------------------------------------------------------------------
								Em caso de Erro aborta todos os Lancamentos e Retorna para o Fluig
							-----------------------------------------------------------------------------------------------------	
							*/
							::cRetorno		:= oBxaReq:GetMensagem()
							lRetorno 		:= .F.
							DisarmTransaction()
							Exit
						EndIf				
					Else
						::cRetorno		:= "Registro " + ::cIdentFlg + " não localizado."
						lRetorno		:= .F.
						DisarmTransaction()
						Exit
					EndIf
				Next nX
			End Transaction
		Else
			::cRetorno		:= "Empresa ou Filial Invalidas"
			lRetorno		:= .F.
		EndIf
	Else
		::cRetorno		:= "Token Invalido."
		lRetorno		:= .F.
	EndIf
	
	If !lRetorno
		Console(::cRetorno)
		SetSoapFault(XNOMEPROG, ::cRetorno)
		DisarmTransaction()
	EndIf

Return lRetorno
//-------------------------------------------------------------------
/*{Protheus.doc} Aniversarios
Metodo para Retorno da Relacao de Aniversariantes do Mes

@author Guilherme Santos
@since 06/05/2016
@version P12
*/
//-------------------------------------------------------------------
WsMethod Aniversarios WSReceive cEmpSol, cFilSol, cToken, cMesAni, xGrupos, cSRACpf WsSend xAniversarios WSService wsIntegracaoFluig
	Local cQuery		:= ""
	Local cRetorno	:= ""
	Local cTabQry		:= ""
	Local nI			:= 0
	Local lRetorno 	:= .T.
	Local cFilialAtivado := ""
	Local cSalvFIL := ''
	//Private lOkUsuAtivoNaFlial := .F.
	       
	Console("Preparando Ambiente para Retorno da Lista de Aniversariantes - Empresa: " + ::cEmpSol + " - Filial: " + ::cFilSol)
	
	RpcSetEnv(::cEmpSol, ::cFilSol, NIL, NIL, "GPE", NIL, {"SRA", "CTT"})
	
	Console("Validando Token")

	If VldToken(::cToken)

		Console("Validando Empresa / Filial")

		If VldEmpFil(::cEmpSol, ::cFilSol)
		
			cTabQry := GetNextAlias()
				
			cQuery += "SELECT 	SRA.RA_FILIAL" + CRLF
			cQuery += ",			SRA.RA_NOME" + CRLF
			cQuery += ",			SRA.RA_NASC" + CRLF
			cQuery += ",			SRA.RA_CC" + CRLF
	
			cQuery += "FROM 		" + RetSqlName("SRA") + " SRA" + CRLF
		
	        If !Empty(cSRACpf) //se fluig nos informou o cpf
	           	cFilialAtivado := FzPsqSRA (cSRACpf)
	        EndIf
	
	        If !Empty(cFilialAtivado)//cpf está ativo em alguma empresa
	           	cQuery += "WHERE SUBSTRING(SRA.RA_FILIAL, 1, 5) =  SUBSTRING('" + cFilialAtivado + "',1,5)  " + CRLF
	        Else//faz pesquisa antiga
	            
		        cQuery += "WHERE 		SUBSTRING(SRA.RA_FILIAL, 1, 5) IN ('"
		             
				For nI := 1 to Len(::xGrupos:IntGrupos)
					cQuery += ::xGrupos:IntGrupos[nI]:cGrpEmp
		
					If nI < Len(::xGrupos:IntGrupos)
						cQuery += "','"
					EndIf
				Next nI
		
				cQuery += "')" + CRLF
			EndIf
				
			cQuery += "AND 		SUBSTRING(SRA.RA_NASC,5,2) = '" + ::cMesAni + "'" + CRLF
			cQuery += "AND 		SRA.RA_SITFOLH NOT IN ('D','T','A','F')" + CRLF
			cQuery += "AND		SRA.D_E_L_E_T_ = ''" + CRLF
	
			cQuery += "ORDER BY SUBSTRING(SRA.RA_NASC, 7, 2), SRA.RA_NOME" + CRLF
	
			cQuery := ChangeQuery(cQuery)
					
			DbUseArea(.T., "TOPCONN", TcGenQry(NIL, NIL, cQuery), cTabQry, .T., .T.)
					
			If (cTabQry)->(Eof())
				cRetorno 	:= "Sem Aniversariantes para Retornar."
				lRetorno 	:= .F.
			Else
	          If !(cTabQry)->(Eof())
	          
	          		cSalvFIL := cFilAnt

					While !(cTabQry)->(Eof())
						Aadd(::xAniversarios:IntAniversarios, WSClassNew( "stAniversarios" ))
			
							::xAniversarios:IntAniversarios[Len(::xAniversarios:IntAniversarios)]:cFilAni := (cTabQry)->RA_FILIAL
							::xAniversarios:IntAniversarios[Len(::xAniversarios:IntAniversarios)]:cNomFun := (cTabQry)->RA_NOME
							::xAniversarios:IntAniversarios[Len(::xAniversarios:IntAniversarios)]:cDtNasc := Substr((cTabQry)->RA_NASC, 7, 2) + "/" + Substr((cTabQry)->RA_NASC, 5, 2) + "/" + Substr((cTabQry)->RA_NASC, 1, 4)
							//::xAniversarios:IntAniversarios[Len(::xAniversarios:IntAniversarios)]:cCCusto := (cTabQry)->RA_CC
							//::xAniversarios:IntAniversarios[Len(::xAniversarios:IntAniversarios)]:cDescCC := Posicione("CTT", 1, (cTabQry)->RA_FILIAL + (cTabQry)->RA_CC, "CTT_DESC01")
		
							::xAniversarios:IntAniversarios[Len(::xAniversarios:IntAniversarios)]:cDescFil :=  FWFilialName(cEmpAnt, (cTabQry)->RA_FILIAL,1) //SM0->M0_FILIAL
									
							(cTabQry)->(DbSkip())
					End
					
					FWFilialName(cEmpAnt, cSalvFIL,1) //SM0->M0_FILIAL
						
				EndIf
				
			EndIf
				
			If Select(cTabQry) > 0
				(cTabQry)->(DbCloseArea())
			EndIf
			
		Else
			cRetorno		:= "Empresa ou Filial Invalidas"
			lRetorno		:= .F.
		EndIf
	Else
		cRetorno		:= "Token Invalido."
		lRetorno		:= .F.
	EndIf
	
	If !lRetorno
		Console(cRetorno)
		SetSoapFault(XNOMEPROG, cRetorno)
		DisarmTransaction()
	EndIf


Return lRetorno
//-------------------------------------------------------------------
/*/{Protheus.doc} VldEmpFil

@author Jorge Heitor
@since 22/12/2015
@version 12.1.007
@description Função para validar a Empresa e Filial informadas na chamada do Método
@obs ALLIAR

@return Boolean, .T.
/*/
//-------------------------------------------------------------------
Static Function VldEmpFil(cEmp, cFil)
	
	Local lRet		:= .F.
	//Local aAreaSM0	:= SM0->(GetArea())
	
	dbSelectArea("SM0")
	dbSetOrder(1)
	
	If SM0->(DbSeek(cEmp + cFil))
		lRet 		:= .T.
		cFilAnt	:= cFil
	Else
		lRet := .F.
	EndIf
	
//	RestArea(aAreaSM0)
	
Return lRet
//-------------------------------------------------------------------
/*{Protheus.doc} VldToken
Valida o Token Informado

@author Guilherme.Santos
@since 21/12/2015
@version P12
*/
//-------------------------------------------------------------------
Static Function VldToken(cToken)
	Local lRetorno := AllTrim(SuperGetMV("ES_TOKENWS", NIL, "XXX")) == cToken
Return lRetorno
//-------------------------------------------------------------------
/*{Protheus.doc} Console
Grava o Texto no Console do AppServer

@author Guilherme.Santos
@since 21/12/2015
@version P12
*/
//-------------------------------------------------------------------
Static Function Console(cTexto, lGrava, lNewLog)
	Default lGrava 	:= .F.
	Default lNewLog	:= .F.

	If lNewLog
		cMsgLog += XNOMEPROG + " - " + DtoC(Date()) + " - " + Time() + " - " + cTexto + CRLF

		If lGrava
			MemoWrite("ALWSI001_" + cTexto + "_" + DtoS(dDatabase) + "_" + StrTran(Time(), ":", "") + ".LOG", cMsgLog)
			cMsgLog := ""
		EndIf		
	Else

		IF TYPE("XNOMEPROG") == "C"
			ConOut(XNOMEPROG + " - " + DtoC(Date()) + " - " + Time() + " - " + cTexto)
		ELSE
			ConOut(" - " + DtoC(Date()) + " - " + Time() + " - " + cTexto)
		ENDIF


	EndIf

Return NIL
//-------------------------------------------------------------------
/*{Protheus.doc} FinSol
Finaliza a Solicitacao de Transferencia

@author Guilherme.Santos
@since 05/01/2016
@version P12
*/
//-------------------------------------------------------------------
Static Function FinSol(cRetGrv)
	Local aArea		:= GetArea()
	Local aAreaNNS	:= NNS->(GetArea())
	Local aAreaNNT	:= NNT->(GetArea())
	
	Local oModSol		:= FWLoadModel("MATA311")						//Carrega o Model da Transferencia
	Local oModNNS		:= oModSol:GetModel("NNSMASTER")				//Carrega o SubModel
	Local lRetorno	:= .T.
	
	lRetorno	:= lRetorno .AND. oModSol:SetOperation(4)			//Alteracao
	lRetorno 	:= lRetorno .AND. oModSol:Activate()				//Ativa o Model
	lRetorno 	:= lRetorno .AND. oModNNS:LoadValue("NNS_STATUS", "2")		//Transferido
	lRetorno 	:= lRetorno .AND. A311Transf(oModSol)				//Efetua a Transferencia
//	lRetorno	:= lRetorno .AND. oModSol:CommitData()				//Finaliza o Registro da Solicitacao
	
	If !lRetorno
		cRetGrv := MODXERR(oModSol)

		Console("---------------------------------------------------------")
		Console("Erro na Execucao da Rotina de Efetivacao da Transferencia")
		Console("---------------------------------------------------------")
		Console(cRetGrv)
		Console("---------------------------------------------------------")
	EndIf
	
	RestArea(aAreaNNT)
	RestArea(aAreaNNS)
	RestArea(aArea)
Return lRetorno
//-------------------------------------------------------------------
/*{Protheus.doc} GCTXERR
Retorna a Mensagem de Erro do Model

@author Guilherme.Santos
@since 14/08/2015
@version P12
@param oModMsg, Objeto, Objeto de onde sera Retornada a Mensagem de Erro
@return cRetorno, Caracter, Mensagem de Erro do Objeto
*/
//-------------------------------------------------------------------
Static Function MODXERR(oModMsg)
	Local aMsgErro 	:= oModMsg:GetErrorMessage()
	Local cRetorno 	:= ""
	Local nI			:= 0

	For nI := 1 to Len(aMsgErro)
		Do Case
		Case ValType(aMsgErro[nI]) == "C"
			cRetorno += aMsgErro[nI] + Space(1)
		Case ValType(aMsgErro[nI]) == "N"
			cRetorno += AllTrim(Str(aMsgErro[nI])) + Space(1)
		EndCase
	Next nI

Return cRetorno
//-------------------------------------------------------------------
/*{Protheus.doc} IniVar
Inicializa Variavel do Web Service

@author TOTVS
@since 19/01/2016
@version P12
*/
//-------------------------------------------------------------------
Static Function IniVar(oGrpEmp)
   oGrpEmp := Nil
   oGrpEmp := WSClassNew("FSEmpresa")
   
   oGrpEmp:cCodGrpEmp  := " "
   oGrpEmp:cNomeGrpEmp := " "
   oGrpEmp:cCodEmp     := " "
   oGrpEmp:cEmpresa    := " "
   oGrpEmp:cCodUnNeg   := " "
   oGrpEmp:cUnidNeg    := " "
   oGrpEmp:cCodFil     := " "
   oGrpEmp:cNomeFil    := " "
Return .T.
/*
-----------------------------------------------------------------------------------------------------
Estrutura dos Dados para Integracao
-----------------------------------------------------------------------------------------------------
*/
//Estrutura de Entrada de Empresa/Filial
wsstruct FSENVEmpresa
	WsData cUsuario As String
	WsData cEmail   As String
	WsData cTipo    As String  //Description "0-Grupos de empresas; 1-Grupo + / Empresas; 2-Grupo + Empresa + Filial;"
	WsData cGrupo   As String  //Quando o tipo for 1 então deve-se informar o Grupo da empresa
	WsData cEmpresa As String  //Quando o tipo for 2 então deve-se informar o Grupo da empresa e Empresa. Se empresa não
	//For informada irá retornar todas as filias do Grupo de todas as empresas
endwsstruct

//Estrutura de Retorno de Empresa/Filial
wsstruct FSRETEmpresa
	WSData aGrpEmp as Array of FSEmpresa
endwsstruct

//Estrutura Filial
wsStruct FSEmpresa
	WSData cCodGrpEmp  as String
	WSData cNomeGrpEmp As String
	WSData cCodEmp     As String
	WsData cEmpresa    As String
	WsData cCodUnNeg   As String
	WsData cUnidNeg    As String
	WsData cCodFil     As String
	WsData cNomeFil    As String
endwsStruct

//Estrutura de colaborador
WSSTRUCT FSENVColaborador
	WSDATA cMAT As String
ENDWSSTRUCT

//Estrutura de retorno do colaborador
WSSTRUCT FSRETColaborador
	WSDATA RA_MAT     As String //MATRICULA
	WSDATA RA_NOME    As String //Nome do colaborador
	WSDATA RA_MAE     As String //Nome da mãe
	WSDATA RA_NASC    As Date   //Data de nascimento
	WSDATA RA_CIC     As String //CPF
	WSDATA RA_SEXO    As String //Sexo do colaborador
	WSDATA RA_ESTCIVI As String //Estado civil
	WSDATA RA_NUMCP   As String //Número e série da CTPS
	WSDATA RA_DTCPEXP As Date   //Data de emissão da CTPS
	WSDATA RA_ESTADO  As String //Estado da CTPS
	WSDATA RA_RG      As String //RG
	WSDATA RA_DTRGEXP As Date   //Data de Emissão
	WSDATA RA_RGEXP   As String //Órgão expedidor
	WSDATA RA_RGUF    As String //Estado emissão identidade
	WSDATA RA_PIS     As String //Número do PIS
	WSDATA RA_SALARIO As String  //Salário
	WSDATA RA_ENDEREC As String //Endereço
	WSDATA RA_BAIRRO  As String //Bairro
ENDWSSTRUCT

//Estrutura de benefício
WSSTRUCT FSENVBeneficio
	WSDATA cTipoVale As String
ENDWSSTRUCT

//Estrutura de retorno do benefício
WSSTRUCT FSRETBeneficio
	WSDATA Beneficio As Array of FSBeneficio
ENDWSSTRUCT

//Estrutura do benefício
WSSTRUCT FSBeneficio
	WSDATA R0_TPVALE As String //Tipo do Vale
	WSDATA R0_CODIGO As String //Codigo do Beneficio
	WSDATA R0_DESC   As String //Descricao do Beneficio
ENDWSSTRUCT

//Estrutura de PreNFE
WSSTRUCT FSENVPreNFE
	WSDATA FilSF1  As String
	WSDATA DocSF1  As String
	WSDATA CNPJSF1 As String
ENDWSSTRUCT


//Estrutura de CancPreNFE
WSSTRUCT FSENVCancPreNFE
	WSDATA FilSF1  As String
	WSDATA idProcFluig  As String
ENDWSSTRUCT

//Estrutura de retorno PreNFE
WSSTRUCT FSRETPreNFE
	WSDATA Classifica As Boolean
ENDWSSTRUCT

WSSTRUCT FSRETCancPreNFE
	WSDATA Classifica As Boolean
ENDWSSTRUCT

//Estrutura de Data PreNFE
WSSTRUCT FSENVDataPreNFE
	WSDATA Filial      As String
	WSDATA DataEntrada As String
ENDWSSTRUCT

//Estrutura de Empresa
WSSTRUCT FSENVFilial
	WSDATA FilSM0 As String
ENDWSSTRUCT

//Estrutura de retorno de Empresa
WSSTRUCT FSRETFilial
	WSDATA M0_NOME    As String //Não exibir no formulário
	WSDATA M0_FILIAL  As String //Nome do grupo de empresa
	WSDATA M0_DESC    As String //Nome da empresa + nome da filial
	WSDATA M0_NOMECOM As String //Não exibir no formulário
	WSDATA M0_CNAE    As String //CNAE
	WSDATA M0_ENDCOB  As String //Endereço da empresa
	WSDATA M0_BAIRCOB As String //Bairro da empresa
	WSDATA M0_CEPCOB  As String //CEP da empresa
	WSDATA M0_CIDCOB  As String //Município da empresa
	WSDATA M0_ESTCOB  As String //Estado da empresa
	WSDATA M0_TEL     As String //Telefone da empresa
ENDWSSTRUCT

//Estrutura de E-mail aprovadores do pedido
WSSTRUCT FSENVEmail
	WSData cFilDoc as String
	WSDATA Documento As String
ENDWSSTRUCT

//Estrutura de retorno de E-mail aprovadores do pedido
WSSTRUCT FSRETEmail
	WSDATA CR_NIVEL as String
	WSDATA CR_EMAIL As String //Não exibir no formulário
ENDWSSTRUCT

//Estrutura de fornecedor
WSSTRUCT FSENVFornecedor
	WSDATA OPERACAO     AS INTEGER
	WSDATA A2_TIPO		AS STRING
	WSDATA A2_CGC 	    AS STRING
	WSDATA A2_NOME      AS STRING
	WSDATA A2_NREDUZ    AS STRING
	WSDATA A2_END       AS STRING
	WSDATA A2_BAIRRO    AS STRING
	WSDATA A2_EST       AS STRING
	WSDATA A2_COD_MUN   AS STRING
	WSDATA A2_MUN       AS STRING
	WSDATA A2_CEP       AS STRING
	WSDATA A2_DDD       AS STRING
	WSDATA A2_TEL       AS STRING
	WSDATA A2_FAX       AS STRING
	WSDATA A2_INSCR     AS STRING
	WSDATA A2_INSCRM    AS STRING
	WSDATA A2_PAIS      AS STRING
	WSDATA A2_PAISDES   AS STRING
	WSDATA A2_EMAIL     AS STRING
	WSDATA A2_HPAGE     AS STRING
	WSDATA A2_BANCO     AS STRING
	WSDATA A2_AGENCIA   AS STRING
	WSDATA A2_NUMCON    AS STRING
	WSDATA A2_COND      AS STRING
	WSDATA A2_NATUREZ   AS STRING
	WSDATA A2_RECPIS    AS STRING
	WSDATA A2_RECCOFI   AS STRING
	WSDATA A2_RECCSLL   AS STRING
	WSDATA A2_RECISS    AS STRING
	WSDATA A2_CALCIRF   AS STRING
	WSDATA A2_SIMPNAC   AS STRING
	WSDATA A2_TPJ       AS STRING
	WSDATA A2_CODPAIS   AS STRING
	WSDATA A2_XIDFLG    AS STRING
	WSDATA A2_DVCTA     AS STRING
	WSDATA A2_DVAGE     AS STRING
	WSDATA A2_COMPLEM   AS STRING
	WSDATA FIL_TIPCTA   AS STRING
ENDWSSTRUCT

//Estrutura de afastamento
WSSTRUCT FSENVAfastamento
	WSDATA OPERACAO        AS INTEGER
	WSDATA R8_FILIAL       AS STRING
	WSDATA R8_MAT          AS STRING
	WSDATA R8_TIPOAFA      AS STRING
	WSDATA R8_PD           AS STRING
	WSDATA R8_DATAINI      AS DATE
	WSDATA R8_DATAFIM      AS DATE   OPTIONAL
	WSDATA R8_CID          AS STRING OPTIONAL
ENDWSSTRUCT

//Estrutura de geração de pre-nota de entrada
WSSTRUCT FSENVPNFEntrada
	//PRE-NOTA
	WSDATA OPERACAO        AS INTEGER
	WSDATA F1_FILIAL       AS STRING
	WSDATA F1_TIPO         AS STRING
	WSDATA F1_FORMUL       AS STRING
	WSDATA F1_DOC          AS STRING
	WSDATA F1_SERIE        AS STRING
	WSDATA F1_EMISSAO      AS DATE
	WSDATA F1_FORNECE      AS STRING
	WSDATA F1_LOJA         AS STRING
	WSDATA F1_XIDFLG       AS STRING
	WSDATA F1_XVENC        AS STRING OPTIONAL
	WSDATA F1_USERID       AS STRING
	WSDATA F1_COND         AS STRING OPTIONAL
	WSDATA F1_XTPINT       AS STRING OPTIONAL
	WSDATA F1_XTPDOC       AS STRING OPTIONAL
	WSDATA F1_XCOMPET      AS STRING OPTIONAL	   
	WSDATA F1_XMULTCP      AS STRING OPTIONAL
	
	WSDATA F1_DESPESA	AS FLOAT OPTIONAL
	WSDATA F1_FRETE		AS FLOAT OPTIONAL
	WSDATA F1_DESCONT	AS FLOAT OPTIONAL
	WSDATA F1_SEGURO	AS FLOAT OPTIONAL
	
	//ITENS PRE-NOTA
	WSDATA ITEM            As Array of FSENVITEMPNFEntrada
	
	WSDATA DUPLICATA       As Array of FSENVPNFEDuplic OPTIONAL
	
	//ITENS RATEIO PRE-NOTA
	//WSDATA ITEMRATEIO       As Array of FSENVITEMPNFRateio
	
ENDWSSTRUCT

WSSTRUCT FSENVPNFEDuplic
	WSDATA Z01_PARC         AS STRING OPTIONAL
	WSDATA Z01_VENCTO       AS DATE OPTIONAL
	WSDATA Z01_VALOR        AS STRING OPTIONAL
ENDWSSTRUCT



//Estrutura de geração de itens pre-nota de entrada
WSSTRUCT FSENVITEMPNFEntrada
	WSDATA D1_ITEM         AS STRING
	WSDATA D1_COD          AS STRING
	WSDATA D1_UM           AS STRING
	WSDATA D1_QUANT        AS STRING
	WSDATA D1_VUNIT        AS STRING
	WSDATA D1_TOTAL        AS STRING
	WSDATA D1_CC           AS STRING
	WSDATA D1_PEDIDO       AS STRING OPTIONAL
	WSDATA D1_ITEMPC       AS STRING OPTIONAL
	WSDATA D1_LOTEFOR      AS STRING
	WSDATA D1_DTVALID      AS DATE   OPTIONAL
	WSDATA D1_LOTECTL      AS STRING OPTIONAL
	WSDATA D1_XBUDGET      AS STRING OPTIONAL
	WSDATA D1_XMOTBUD      AS STRING OPTIONAL 
	WSDATA D1_VALIPI       AS STRING OPTIONAL 
	
	//ITENS RATEIO PRE-NOTA
	WSDATA ITEMRATEIO       AS Array OF FSENVITEMPNFRateio OPTIONAL
	
ENDWSSTRUCT


//Estrutura de geração de itens pre-nota de entrada
WSSTRUCT FSENVITEMPNFRateio
	//WSDATA DE_ITEMNF       AS STRING 
	WSDATA DE_CC           AS STRING
	WSDATA DE_VALOR 	   AS STRING
	WSDATA DE_PERC         AS STRING
ENDWSSTRUCT

//Estrutura de troca turno
WSSTRUCT FSENVTrocaTurno
	WSDATA OPERACAO        AS INTEGER
	WSDATA PF_FILIAL       AS STRING
	WSDATA PF_MAT          AS STRING
	WSDATA PF_DATA         AS DATE
	WSDATA PF_TURNODE      AS STRING
	WSDATA PF_SEQUEDE      AS STRING
	WSDATA PF_REGRADE      AS STRING
	WSDATA PF_TURNOPA      AS STRING
	WSDATA PF_SEQUEPA      AS STRING
	WSDATA PF_REGRAPA      AS STRING
ENDWSSTRUCT

//Estrutura de acidente de trabalho
WSSTRUCT FSENVAcidenteTrabalho
	WSDATA OPERACAO        AS INTEGER
	WSDATA TNC_FILIAL      AS STRING
	WSDATA TNC_MAT         AS STRING
	WSDATA TNC_TIPCAT      AS STRING
	WSDATA TNC_TIPREV      AS STRING
	WSDATA TNC_APOSEN      AS STRING
	WSDATA TNC_AREA        AS STRING
	WSDATA TNC_DTACID      AS DATE
	WSDATA TNC_HRACID      AS STRING
	WSDATA TNC_HRTRAB      AS STRING
	WSDATA TNC_TIPACI      AS STRING
	WSDATA TNC_AFASTA      AS STRING
	WSDATA TNC_DTULTI      AS DATE
	WSDATA TNC_INDLOC      AS STRING
	WSDATA TNC_LOCAL       AS STRING
	WSDATA TNC_CGCPRE      AS STRING
	WSDATA TNC_ESTACI      AS STRING
	WSDATA TNC_CIDACI      AS STRING
	WSDATA TNC_PARTE       AS STRING
	WSDATA TNC_CODOBJ      AS STRING
	WSDATA TNC_ACIDEN      AS STRING
	
	WSDATA TNC_DESACI      AS STRING
	WSDATA TNC_INDACI      AS STRING
	WSDATA TNC_VITIMA      AS STRING
	WSDATA TNC_NUMFIC      AS STRING
	WSDATA TNC_TRANSF      AS STRING
	WSDATA TNC_EMITEN      AS STRING
	WSDATA TNC_DTOBIT      AS DATE    OPTIONAL
	WSDATA TNC_CODCID      AS STRING
	WSDATA TNC_DESCR1      AS STRING
	WSDATA TNC_POLICI      AS STRING
	WSDATA TNC_MORTE       AS STRING
	WSDATA TNC_CODPAR      AS STRING
	WSDATA TNC_CODLES      AS STRING
	WSDATA TNC_LOCACT      AS STRING
	WSDATA TNC_HORSAI      AS STRING
	WSDATA TNC_TRAJET      AS STRING
	WSDATA TNC_MEIO        AS STRING
	WSDATA TNC_LOCACI      AS STRING
	WSDATA TNC_DISTAC      AS FLOAT   OPTIONAL
	WSDATA TNC_XDISTA      AS STRING  OPTIONAL
	WSDATA TNC_MUDANC      AS STRING
	WSDATA TNC_MOTIVO      AS STRING
	
	WSDATA TNC_TESTE1      AS STRING  OPTIONAL
	WSDATA TNC_ENDTE1      AS STRING  OPTIONAL
	WSDATA TNC_NUEND1      AS INTEGER OPTIONAL
	WSDATA TNC_BAIRR1      AS STRING  OPTIONAL
	WSDATA TNC_ESTAD1      AS STRING  OPTIONAL
	WSDATA TNC_CIDT1       AS STRING  OPTIONAL
	WSDATA TNC_CIDAD1      AS STRING  OPTIONAL
	WSDATA TNC_MTEST1      AS STRING  OPTIONAL
	WSDATA TNC_TESTE2      AS STRING  OPTIONAL
	WSDATA TNC_ENDTE2      AS STRING  OPTIONAL
	WSDATA TNC_NUEND2      AS INTEGER OPTIONAL
	WSDATA TNC_BAIRR2      AS STRING  OPTIONAL
	WSDATA TNC_ESTAD2      AS STRING  OPTIONAL
	WSDATA TNC_CIDT2       AS STRING  OPTIONAL
	WSDATA TNC_CIDAD2      AS STRING  OPTIONAL
	WSDATA TNC_MTEST2      AS STRING  OPTIONAL
	
	WSDATA TNC_NOMFIC      AS STRING
ENDWSSTRUCT

//Estrutura de entrada de pedido de compra
WSSTRUCT FSENVPedidoCompra
	WSDATA EmpSC7     As String OPTIONAL
	WSDATA FilSC7     As String OPTIONAL
	WSDATA CNPJSC7    As String OPTIONAL
	WSDATA FiltraMed    As String OPTIONAL //| Vazio OU "A" = Ambos, S=Lista Pc Medicao, N=Nao Lista PC Medicao|
ENDWSSTRUCT

//Estrutura de retorno de pedido de compra
WSSTRUCT FSRetPCom
	WSDATA C7_FORNECE As String //Codigo do Fornecedor
	WSDATA C7_LOJA    As String //Codigo da Loja
	WSDATA C7_NUM     As String //Numero do Pedido de Compra
	WSDATA C7_EMISSAO As Date   //Data da Emissão
	WSDATA C7_ORIGIMP As String //Origem
	WSDATA C7_TIPO    As Float  //Tipo
	WSDATA C7_ITEM    As String //Codigo do Item
	WSDATA C7_PRODUTO As String //Codigo do Produto
	WSDATA C7_DESCRI  As String //Descrição do Produto ?!?!?!?!?!?!?!?!?!?!?!?!?!?!??!
	WSDATA C7_UM      As String //Unidade de Medida
	WSDATA C7_QUANT   As String //Quantidade
	WSDATA C7_PRECO   As String  //Preço Unitário
	WSDATA C7_TOTAL   As String  //Valor Total
	WSDATA C7_LOCAL   As String //Armazem
	WSDATA C7_SEGUM   As String
	WSDATA C7_QTSEGUM As String
	WSDATA C7_DATPRF  As String
	WSDATA C7_OBS     As String //Observação
	WSDATA C7_CC      As String //Centro de Custo
	WSDATA C7_MOEDA   As Float  //Moeda
	
	WSDATA C7_DESPESA  As String
	WSDATA C7_SEGURO   As String
	WSDATA C7_VALFRE   As String
	WSDATA C7_VLDESC   As String
	WSDATA C7_VALIPI   As String
	
	
	WSDATA CTT_DESC01 As String 
	WSDATA B1_RASTRO  As String
ENDWSSTRUCT

//Estrutura da solicitação de compra
WSSTRUCT FSENVSolicitacaoCompra
	WSDATA cEmpFluig		AS STRING
	WSDATA cFilFluig		AS STRING
	WSDATA OPERACAO         AS INTEGER
	WSDATA C1_NUM	      	AS STRING
	WSDATA C1_EMISSAO       AS DATE
	WSDATA C1_SOLICIT       AS STRING
	WSDATA C1_FILENT        AS STRING
	WSDATA C1_XIDFLG        AS STRING
	WSDATA C1_XTPSCFL       AS STRING
	WSDATA C1_FILIAL        AS STRING
	WSDATA ITEM				AS ARRAY OF FSENVITEMSolicitacaoCompra
ENDWSSTRUCT

//Estrutura do Item da solicitação de Compra 
WSSTRUCT FSENVITEMSolicitacaoCompra
	WSDATA C1_ITEM          AS STRING
	WSDATA C1_PRODUTO       AS STRING
	WSDATA C1_UM            AS STRING
	WSDATA C1_QUANT     		AS STRING
	WSDATA C1_SEGUM         AS STRING
	WSDATA C1_QTSEGUM     	AS STRING
	WSDATA C1_LOCAL     		AS STRING
	WSDATA C1_OBS	     		AS STRING
	WSDATA C1_CC	     		AS STRING
	WSDATA C1_DATPRF     	AS DATE
	WSDATA C1_XGRUP         AS STRING OPTIONAL //hfp  ABAX  -- 20210802 VOLTAMOS COMO OPTINAL, POR CAUSA SOL ANTIGAS NO FLUIG
	WSDATA C1_XBUDGET			AS STRING OPTIONAL //hfp  ABAX  //optional em 20210730
	WSDATA C1_XMOTBUD			AS STRING OPTIONAL //hfp  ABAX  //optional em 20210730
ENDWSSTRUCT

//Estrutura da programação de férias
WSSTRUCT FSENVProgramacaoFerias
	WSDATA OPERACAO         AS INTEGER
	WSDATA RF_FILIAL        AS STRING
	WSDATA RF_TEMABPE       AS STRING
	WSDATA RF_MAT           AS STRING
    WSDATA RF_DFERVAT       AS STRING
    WSDATA RF_DFEPRO1       AS STRING
    WSDATA RF_DABPRO1       AS STRING
    WSDATA RF_DATABAS       AS DATE
    WSDATA RF_DATAINI       AS DATE
    WSDATA RF_DATAFIM       AS DATE 
    WSDATA RF_PERC13S       AS STRING OPTIONAL
    WSDATA RF_PD            AS STRING
    WSDATA RF_STATUS        AS STRING
    WSDATA RF_ABOPEC        AS STRING OPTIONAL
ENDWSSTRUCT

//Estrutura do cadastro de produto
WSSTRUCT FSENVProduto
	WSDATA OPERACAO         AS INTEGER
	WSDATA B1_FILIAL        AS STRING
	WSDATA B1_TIPO          AS STRING
	WSDATA B1_GRUPO         AS STRING
	WSDATA B1_DESC          AS STRING
	WSDATA B1_UM            AS STRING
	WSDATA B1_SEGUM         AS STRING
	WSDATA B1_CONV          AS STRING
	WSDATA B1_TIPCONV       AS STRING
	WSDATA B1_CONTA         AS STRING
	WSDATA B1_ALIQISS       AS STRING
	WSDATA B1_CODISS        AS STRING
	WSDATA B1_IRRF          AS STRING
	WSDATA B1_INSS          AS STRING
	WSDATA B1_REDINSS       AS STRING
	WSDATA B1_REDIRRF       AS STRING
	WSDATA B1_REDPIS        AS STRING
	WSDATA B1_REDCOF        AS STRING
	WSDATA B1_PCSLL         AS STRING
	WSDATA B1_PIS           AS STRING
	WSDATA B1_COFINS        AS STRING
	WSDATA B1_CSLL          AS STRING
	WSDATA B1_XIDFLG        AS STRING
	WSDATA B1_XMARCEX       AS STRING
	WSDATA B1_XMARPRE       AS STRING
	WSDATA B1_XRESMAR       AS STRING
	WSDATA B1_COD           AS STRING
	WSDATA B1_XCONTA2       AS STRING
	WSDATA B1_ORIGEM        AS STRING
	WSDATA B1_RASTRO        AS STRING
	WSDATA B1_XCONTA1       AS STRING
ENDWSSTRUCT

//Estrutura do movimento bancário
WSSTRUCT FSENVMovimentoBancario
	WSDATA cEmpFluig		AS STRING
	WSDATA cFilFluig		AS STRING
	WSDATA OPERACAO         AS INTEGER
	WSDATA E5_FILIAL        AS STRING
	WSDATA E5_DATA          AS STRING
	WSDATA E5_VALOR         AS STRING
	WSDATA E5_NATUREZ       AS STRING
	WSDATA E5_HISTOR        AS STRING
	WSDATA E5_XIDFLG        AS STRING
	WSDATA RATEIO           AS ARRAY OF FSENVRATEIOMovimentoBancario OPTIONAL
ENDWSSTRUCT

//Estrutura do rateio do movimento bancário
WSSTRUCT FSENVRATEIOMovimentoBancario
	WSDATA CV4_DEBITO       AS STRING
	WSDATA CV4_VALOR        AS STRING
	WSDATA CV4_CCD          AS STRING
ENDWSSTRUCT

//Estrutura de aprovação de pedido de compra
WSSTRUCT FSENVAprovacaoPC
	WSDATA CR_FILIAL      AS STRING
	WSDATA CR_NUM         AS STRING
	WSDATA CR_STATUS      AS STRING //A->Aprovar; R->Rejeitar
	WSDATA CR_RECNO       AS INTEGER//RECNO DA SCR
ENDWSSTRUCT

//Estrutura do benefício
WSSTRUCT FSENVCadBeneficio
	WSDATA OPERACAO    AS INTEGER
	WSDATA R0_FILIAL   AS STRING
	WSDATA R0_MAT	   AS STRING
	WSDATA R0_TPVALE   AS STRING
	WSDATA R0_CODIGO   AS STRING
	WSDATA R0_QDIAINF  AS INTEGER
	WSDATA R0_QDNUTIL  AS INTEGER
ENDWSSTRUCT

//Estrutura do cadastro de admissão
WSSTRUCT FSENVCadAdmissao
	WSDATA OPERACAO    AS INTEGER
	WSDATA RA_FILIAL   AS STRING
	WSDATA RA_MAT	   AS STRING
	WSDATA RA_NOME     AS STRING
	WSDATA RA_NOMECMP  AS STRING
	WSDATA RA_MAE      AS STRING
	WSDATA RA_PAI      AS STRING
	WSDATA RA_SEXO     AS STRING
	WSDATA RA_RACACOR  AS STRING
	WSDATA RA_NASC     AS DATE
	WSDATA RA_ESTCIVI  AS STRING
	WSDATA RA_CPAISOR  AS STRING
	WSDATA RA_NACIONA  AS STRING
	WSDATA RA_NACIONC  AS STRING
	WSDATA RA_BRNASEX  AS STRING
	WSDATA RA_NATURAL  AS STRING
	WSDATA RA_CODMUNN  AS STRING
	WSDATA RA_MUNNASC  AS STRING
	WSDATA RA_GRINRAI  AS STRING
	WSDATA RA_EMAIL    AS STRING
	WSDATA RA_DEFIFIS  AS STRING
	WSDATA RA_BRPDH    AS STRING
	WSDATA RA_TPDEFFI  AS STRING
	WSDATA RA_PORTDEF  AS STRING
	WSDATA RA_OBSDEFI  AS STRING
	WSDATA RA_CC       AS STRING
	WSDATA RA_ADMISSA  AS DATE
	WSDATA RA_TIPOADM  AS STRING
	WSDATA RA_OPCAO    AS DATE
	WSDATA RA_TNOTRAB  AS STRING
	WSDATA RA_PERFGTS  AS STRING
	WSDATA RA_BCDEPSA  AS STRING
	WSDATA RA_TPCTSAL  AS STRING
	WSDATA RA_CTDEPSA  AS STRING
	WSDATA RA_HRSMES   AS STRING
	WSDATA RA_HRSEMAN  AS STRING
	WSDATA RA_HRSDIA   AS STRING
	WSDATA RA_CODFUNC  AS STRING
	WSDATA RA_SALARIO  AS STRING
	WSDATA RA_ANTEAUM  AS STRING
	WSDATA RA_PGCTSIN  AS STRING
	WSDATA RA_ADCPERI  AS STRING
	WSDATA RA_TPCONTR  AS STRING
	WSDATA RA_DTFIMCT  AS DATE   OPTIONAL
	WSDATA RA_PROCES   AS STRING
	WSDATA RA_HOPARC   AS STRING
	WSDATA RA_SEGUROV  AS STRING
	WSDATA RA_CLAURES  AS STRING
	WSDATA RA_PERCADT  AS STRING
	WSDATA RA_SINDICA  AS STRING
	WSDATA RA_TIPOPGT  AS STRING
	WSDATA RA_CATFUNC  AS STRING
	WSDATA RA_VIEMRAI  AS STRING
	WSDATA RA_CATEG    AS STRING
	WSDATA RA_CATEFD   AS STRING
	WSDATA RA_VCTOEXP  AS DATE   OPTIONAL
	WSDATA RA_VCTEXP2  AS DATE   OPTIONAL
	WSDATA RA_PERICUL  AS STRING	OPTIONAL
	WSDATA RA_INSMIN   AS STRING
	WSDATA RA_INSMED   AS STRING
	WSDATA RA_DTVTEST  AS DATE   OPTIONAL
	WSDATA RA_ADCINS   AS STRING	OPTIONAL
	WSDATA RA_ASSIST   AS STRING
	WSDATA RA_CONFED   AS STRING
	WSDATA RA_MENSIND  AS STRING
	WSDATA RA_FTINSAL  AS STRING
	WSDATA RA_OCORREN  AS STRING
	WSDATA RA_CARGO    AS STRING
	WSDATA RA_REGRA    AS STRING
	WSDATA RA_COMPSAB  AS STRING
	WSDATA RA_EAPOSEN  AS STRING
	WSDATA RA_NJUD14   AS STRING
	WSDATA RA_SEQTURN  AS STRING
	WSDATA RA_CIC      AS STRING
	WSDATA RA_PIS      AS STRING
	WSDATA RA_RG       AS STRING
	WSDATA RA_DTRGEXP  AS DATE
	WSDATA RA_RGUF     AS STRING
	WSDATA RA_RGORG    AS STRING
	WSDATA RA_RGEXP    AS STRING
	WSDATA RA_ORGEMRG  AS STRING
	WSDATA RA_BHFOL    AS STRING
	WSDATA RA_NUMCP    AS STRING
	WSDATA RA_SERCP    AS STRING
	WSDATA RA_ACUMBH   AS STRING
	WSDATA RA_UFCP     AS STRING
	WSDATA RA_DTCPEXP  AS DATE
	WSDATA RA_HABILIT  AS STRING
	WSDATA RA_CNHORG   AS STRING
	WSDATA RA_DTEMCNH  AS DATE   OPTIONAL
	WSDATA RA_DTVCCNH  AS DATE   OPTIONAL
	WSDATA RA_RESERVI  AS STRING
	WSDATA RA_TIPENDE  AS STRING
	WSDATA RA_TITULOE  AS STRING
	WSDATA RA_ZONASEC  AS STRING
	WSDATA RA_SECAO    AS STRING
	WSDATA RA_LOGRTP   AS STRING
	WSDATA RA_LOGRDSC  AS STRING
	WSDATA RA_LOGRNUM  AS STRING
	WSDATA RA_ENDEREC  AS STRING
	WSDATA RA_REGCIVI  AS STRING
	WSDATA RA_TPLIVRO  AS STRING
	WSDATA RA_NUMENDE  AS STRING
	WSDATA RA_COMPLEM  AS STRING
	WSDATA RA_TIPCERT  AS STRING
	WSDATA RA_BAIRRO   AS STRING
	WSDATA RA_EMICERT  AS DATE   OPTIONAL
	WSDATA RA_ESTADO   AS STRING
	WSDATA RA_MATCERT  AS STRING
	WSDATA RA_CODMUN   AS STRING
	WSDATA RA_LIVCERT  AS STRING
	WSDATA RA_FOLCERT  AS STRING
	WSDATA RA_MUNICIP  AS STRING
	WSDATA RA_CARCERT  AS STRING
	WSDATA RA_CEP      AS STRING
	WSDATA RA_UFCERT   AS STRING
	WSDATA RA_CDMUCER  AS STRING
	WSDATA RA_NUMEPAS  AS STRING
	WSDATA RA_DDDFONE  AS STRING
	WSDATA RA_EMISPAS  AS STRING
	WSDATA RA_TELEFON  AS STRING
	WSDATA RA_UFPAS    AS STRING
	WSDATA RA_DEMIPAS  AS DATE   OPTIONAL
	WSDATA RA_DDDCELU  AS STRING
	WSDATA RA_NUMCELU  AS STRING
	WSDATA RA_DVALPAS  AS DATE   OPTIONAL
	WSDATA RA_CODPAIS  AS STRING
	WSDATA RA_CHIDENT  AS STRING
	WSDATA RA_NUMRIC   AS STRING
	WSDATA RA_EMISRIC  AS STRING
	WSDATA RA_UFRIC    AS STRING
	WSDATA RA_CDMURIC  AS STRING
	WSDATA RA_DEXPRIC  AS DATE   OPTIONAL
	WSDATA RA_CODIGO   AS STRING
	WSDATA RA_OCEMIS   AS STRING
	WSDATA RA_OCDTEXP  AS DATE   OPTIONAL
	WSDATA RA_OCDTVAL  AS DATE   OPTIONAL
	WSDATA RA_CODUNIC  AS STRING
	WSDATA RA_RNE      AS STRING
	WSDATA RA_RNEORG   AS STRING
	WSDATA RA_RNEDEXP  AS DATE   OPTIONAL
	WSDATA RA_DATCHEG  AS DATE   OPTIONAL
	WSDATA RA_ANOCHEG  AS STRING
	WSDATA RA_NUMNATU  AS STRING
	WSDATA RA_DATNATU  AS DATE   OPTIONAL
	WSDATA RA_CASADBR  AS STRING
	WSDATA RA_FILHOBR  AS STRING
	WSDATA RA_REGIME   AS STRING
	WSDATA RA_FWIDM    AS STRING
	WSDATA RA_INSMAX   AS STRING
	WSDATA RA_ADTPOSE  AS STRING
	WSDATA RA_TPJORNA  AS STRING
	WSDATA RA_TPPREVI  AS STRING OPTIONAL
	WSDATA RF_PD       AS STRING OPTIONAL
	WSDATA DEPENDENTES AS ARRAY OF FSENVDependentesAdmissao OPTIONAL
	WSDATA BENEFICIOS  AS ARRAY OF FSENVBeneficiosAdmissao  OPTIONAL
ENDWSSTRUCT

//Estrutura de cadastro de dependentes
WSSTRUCT FSENVDependentesAdmissao
	WSDATA RB_COD      AS STRING
	WSDATA RB_NOME     AS STRING
	WSDATA RB_DTNASC   AS DATE
	WSDATA RB_TPDEP    AS STRING
	WSDATA RB_SEXO     AS STRING
	WSDATA RB_TIPIR    AS STRING
	WSDATA RB_GRAUPAR  AS STRING
	WSDATA RB_TIPSF    AS STRING
	WSDATA RB_CIC      AS STRING
	WSDATA RB_AUXCRE   AS STRING
	WSDATA RB_VLRCRE   AS STRING
ENDWSSTRUCT

//Estrutura de cadastro de benefícios
WSSTRUCT FSENVBeneficiosAdmissao
	WSDATA R0_TPVALE  AS STRING
	WSDATA R0_CODIGO  AS STRING
	WSDATA R0_MEIO    AS STRING
	WSDATA R0_QDIAINF AS FLOAT
	WSDATA R0_QDNUTIL AS FLOAT
ENDWSSTRUCT

//Estrutura de cadastro de movimentação de pessoal
WSSTRUCT FSENVMovPessoal
	WSDATA OPERACAO   AS INTEGER
	WSDATA RA_FILIAL  AS STRING
	WSDATA RA_MAT     AS STRING
	WSDATA RA_SALARIO AS STRING
	WSDATA RA_CARGO   AS STRING
	WSDATA RJ_FUNCAO  AS STRING
	WSDATA R7_DATA    AS DATE
	WSDATA R7_TIPO    AS STRING
	WSDATA R3_PD      AS STRING
ENDWSSTRUCT

//Estrutura de retorno
WSSTRUCT FSRETFLUIG
	WSDATA RETORNO		AS INTEGER
	WSDATA MENSAGEM 	AS STRING
	WSDATA ID           AS STRING
ENDWSSTRUCT

//-------------------------------------------
//Colecao de Campos do Titulo para Integracao
//-------------------------------------------
WSStruct InDataSE2
	WSData NewInSE2 as Array Of InCpoSE2
EndWSStruct
//-------------------------------------------
//Campos do Titulo para Integracao
//-------------------------------------------
WSStruct InCpoSE2
	WsData cCpoSE2		as String						//01 - Nome do Campo para Gravacao
	WsData xVlrSE2		as String						//02 - Conteudo do Campo para Gravacao
EndWSStruct
//-------------------------------------------
//Colecao de Registros para Integracao
//-------------------------------------------
WSStruct InDataSEV
	WsData NewDataSEV	as Array of InRegSEV Optional
EndWSStruct
//-------------------------------------------
//Registro para Integracao
//-------------------------------------------
WSStruct InRegSEV
	WsData NewRegSEV		as Array of InCpoSEV			//Campos do SEV
//	WsData aInDataSEZ		as InDataSEZ					//Array com o Rateio para o Registro da SEV x SEZ
EndWSStruct
//-------------------------------------------
//Campos do Rateio para Integracao
//-------------------------------------------
WSStruct InCpoSEV
	WsData cCpoSEV		as String					//01 - Nome do Campo da SEV
	WsData xVlrSEV		as String					//02 - Conteudo do Campo da SEV
EndWSStruct
//-------------------------------------------
//Colecao de Registros para Integracao
//-------------------------------------------
WSStruct InDataSEZ
	WsData NewDataSEZ	as Array of InRegSEZ
EndWSStruct
//-------------------------------------------
//Registro para Integracao
//-------------------------------------------
WSStruct InRegSEZ
	WsData NewRegSEZ	as Array of InCpoSEZ
EndWSStruct
//-------------------------------------------
//Campos do Rateio para Integracao
//-------------------------------------------
WSStruct InCpoSEZ
	WsData cCpoSEZ	as String						//01 - Nome do Campo da SEZ
	WsData xVlrSEZ	as String						//02 - Conteudo do Campo da SEZ
EndWSStruct
//---------------------------------------------
//Colecao de Campos do Contrato para Integracao
//---------------------------------------------
WSStruct InDataGCT
	WSData NewInGCT as Array Of InCpoGCT
EndWSStruct
//-------------------------------------------
//Campos do Titulo para Integracao
//-------------------------------------------
WSStruct InCpoGCT
	WsData cCpoGCT		as String						//01 - Nome do Campo para Gravacao
	WsData xVlrGCT		as String						//02 - Conteudo do Campo para Gravacao
EndWSStruct
				
WsStruct stRecIncSol
	WsData cToken		As String
	WsData cEmp			As String
	WsData cFil			As String
	WsData aItens		As Array of stItens
	WsData cIdFluig		As String
EndWSStruct

WsStruct stItens
	
	WsData cItem		As String
	WsData cProduto		As String
	WsData cUM			As String
	WsData nQuant		As String
	WsData cSegUm		As String
	WsData dDatPrf		As String
	WsData cArmazem		As String
	WsData cObs			As String
	WsData cCC			As String
	WsData cNumSC		As String
	
EndWsStruct
				
WsStruct stRecStatSol
	
	WsData cToken		As String
	WsData cEmp			As String
	WsData cFil			As String
	WsData cIdFluig		As String
	
EndWSStruct
				
WsStruct stRecBaixaCIPA
	
	WsData cToken		As String
	WsData cEmp			As String
	WsData cFil			As String
	WsData aDatas		As stDatasCIPA
	WsData cIdFluig		As String
	
EndWSStruct
				
WsStruct stDatasCIPA
	
	WsData TNN_CONVOC	As String
	WsData TNN_COMISS	As String
	WsData TNN_COPEDI	As String
	WsData TNN_INSCRI	As String
	WsData TNN_INSCRF	As String
	WsData TNN_ELEICR	As String
	WsData TNN_CURCIP	As String
	WsData TNN_COSIND	As String
	WsData TNN_POSSE	As String
					
EndWsStruct

WsStruct axGrupos
	WsData intGrupos 			as Array of stGrupos
EndWsStruct

WsStruct axAniversarios
	WsData intAniversarios	as Array of stAniversarios
EndWsStruct

WsStruct stGrupos
	WsData cGrpEmp		As String
EndWSStruct

WsStruct stAniversarios
	WsData cFilAni		As String
	WsData cNomFun		As String
	WsData cDtNasc		As String
	//WsData cCCusto		As String
	WsData cDescFil		As String
EndWSStruct

WsStruct stRetCc
	WsData cCodigo		As String
	WsData cDescri		As String
EndWSStruct

//|GRUPOS DE USUARIOS PROTHEUS|
WSSTRUCT StructGRPPROT
	WsData DadosGRPPROT		As StrDadosGrp
ENDWSSTRUCT



WSSTRUCT StrDadosGrp

	WsData CODERRO		      		As String
	WsData MSGERRO				 	As String
	WsData GRPPROT					As Array Of GRPPROT OPTIONAL
	
ENDWSSTRUCT



WsStruct GRPPROT

	WsData Codigo   	As String	OPTIONAL
	WsData Descricao	As String	OPTIONAL
	

EndWsStruct



//|GRUPOS DE USUARIOS PROTHEUS|
WSSTRUCT StructUSRPROT
	WsData DadosUSRPROT		As StrDadosUsr
ENDWSSTRUCT

WSSTRUCT StrDadosUsr

	WsData CODERRO		      		As String
	WsData MSGERRO				 	As String
	WsData USRPROT					As Array Of USRPROT OPTIONAL
	
ENDWSSTRUCT

WsStruct USRPROT

	WsData Codigo   	As String	OPTIONAL
	WsData Usuario 		As String	OPTIONAL
	WsData Nome			As String	OPTIONAL
	

EndWsStruct

//-------------------------------------------------------------------
/*{Protheus.doc} FzPsqSRA
Verifica em qual filial este cpf está ativo

@author Totvs
@since 19/01/2016
@version P12
*/
//-------------------------------------------------------------------
static function   FzPsqSRA(cUsuCpf)
Local cPsqAlias := GetNextALias()
Local cRet      := ""

BeginSql Alias cPsqAlias
		SELECT SRA.RA_FILIAL 
		       FROM %table:SRA% SRA
		       WHERE SRA.%NotDel%
		             AND SRA.RA_CIC    = %Exp:(cUsuCpf)%
		             AND SRA.RA_SITFOLH NOT IN ('A','D','F','T') //<-- significa que o cara ta ativo
EndSql


If (cPsqAlias)->(!Eof())
	cRet := AllTrim((cPsqAlias)->(RA_FILIAL))
ENdIf

(cPsqAlias)->(DbCloseArea())

return cRet


/*/{Protheus.doc} RetParcial

@author Totvs
@since 14/01/2016
@version 12.1.007
@description Método para efetuar ret parcial das Pendencias CIPA, bem como atualizar datas no mandato
@obs ALLIAR

@return Boolean, lRet
/*/
WsMethod RetParcial WsReceive xRecBaixaCIPA WsSend xRetBaixaCIPA WsService wsIntegracaoFluig
	
	Local lRet		:= .T.
	Local x
	Local oBaixa	:= uConcluiCIPA():New()
	
	If VldToken(::xRecBaixaCIPA:cToken)
		
		If VldEmpFil(::xRecBaixaCIPA:cEmp,::xRecBaixaCIPA:cFil)
			
			oBaixa:cEmpDest := ::xRecBaixaCIPA:cEmp
			oBaixa:cFilDest := ::xRecBaixaCIPA:cFil
			oBaixa:cIDFluig := ::xRecBaixaCIPA:cIDFluig
			
			For x := 1 to Len(oBaixa:aDatas)
				
				If oBaixa:aDatas[x][1] == "TNN_CONVOC"
					
					oBaixa:aDatas[x][2] := CtoD(::xRecBaixaCIPA:aDatas:TNN_CONVOC)
					
				ElseIf oBaixa:aDatas[x][1] == "TNN_COMISS"
					
					oBaixa:aDatas[x][2] := CtoD(::xRecBaixaCIPA:aDatas:TNN_COMISS)
					
				ElseIf oBaixa:aDatas[x][1] == "TNN_COPEDI"
					
					oBaixa:aDatas[x][2] := CtoD(::xRecBaixaCIPA:aDatas:TNN_COPEDI)
					
				ElseIf oBaixa:aDatas[x][1] == "TNN_INSCRI"
					
					oBaixa:aDatas[x][2] := CtoD(::xRecBaixaCIPA:aDatas:TNN_INSCRI)
					
				ElseIf oBaixa:aDatas[x][1] == "TNN_INSCRF"
					
					oBaixa:aDatas[x][2] := CtoD(::xRecBaixaCIPA:aDatas:TNN_INSCRF)
					
				ElseIf oBaixa:aDatas[x][1] == "TNN_ELEICR"
					
					oBaixa:aDatas[x][2] := CtoD(::xRecBaixaCIPA:aDatas:TNN_ELEICR)
					
				ElseIf oBaixa:aDatas[x][1] == "TNN_CURCIP"
					
					oBaixa:aDatas[x][2] := CtoD(::xRecBaixaCIPA:aDatas:TNN_CURCIP)
					
				ElseIf oBaixa:aDatas[x][1] == "TNN_COSIND"
					
					oBaixa:aDatas[x][2] := CtoD(::xRecBaixaCIPA:aDatas:TNN_COSIND)
					
				ElseIf oBaixa:aDatas[x][1] == "TNN_POSSE"
					
					oBaixa:aDatas[x][2] := CtoD(::xRecBaixaCIPA:aDatas:TNN_POSSE)
					
				EndIf
				
			Next x
			
			//Chama método para baixa na classe uConcluiCIPA
			If oBaixa:RetParcial()
				
				::xRetBaixaCIPA := oBaixa:cMsgRet
				
			Else
				
				lRet := .F.
				SetSoapFault("RetParcial",oBaixa:cMsgRet)
				
			EndIf
			
		Else
			
			lRet := .F.
			SetSoapFault("RetParcial","Empresa/Filial inválida(s).")
			
		EndIf
		
	Else
		
		lRet := .F.
		SetSoapFault("RetParcial","Token inválido.")
		
	EndIf
	
Return lRet
//-------------------------------------------------------------------
/*{Protheus.doc} UsrMail
Retorna o email do Usuario do Protheus

@author Guilherme Santos
@since 10/11/2016
@version P12
*/
//-------------------------------------------------------------------
WSMethod UsrMail WSReceive cToken, cCodUsr WsSend cRetorno WSService wsIntegracaoFluig
	Local cRetorno := ""
	Local lRetorno := .T.

	Console("Validando Token")

	If VldToken(::cToken)
		Console("Token Valido.")

		//Ordena pesquisa por id do usuário
		PswOrder(1)

		If PswSeek(::cCodUsr)
			::cRetorno := PswRet(1)[1][14]
		Else
			cRetorno := "Usuario invalido."
			lRetorno := .F.
		EndIf
	Else
		cRetorno := "Token invalido"
		lRetorno := .F.
	EndIf

	If !lRetorno
		Console(cRetorno)
		SetSoapFault(XNOMEPROG, cRetorno)
	EndIf

Return lRetorno




//-------------------------------------------------------------------
/*{Protheus.doc} PNFEntrada
Método para geração de pre-nota de entrada

@author TOTVS
@since 19/01/2016
@version P12
*/
//-------------------------------------------------------------------


/*/{Protheus.doc} CancelaPreNFE
Cancela Pre-nota de Entrada
@author aribeiro
@since 24/02/2017
@version undefined

@example
(examples)
@see (links_or_references)
/*/
WSMETHOD CancelaPreNFE WSRECEIVE SCancPreNFE WSSEND SRetorno WSSERVICE wsIntegracaoFluig
Local cFornec, cLoja
Local cQuery	:= "" 
lOCAL aRetAux
Local nHSemaf	:= 0
Local cFile		:= "DELSF1"



Private lWSFluig	:= .T.

Console("Preparando Ambiente para Inclusao da Solicitacao ao Armazem - Empresa: 01 - Filial: " + ::SCancPreNFE:FilSF1 , .F., .F.)

//Prepara Ambiente
RpcSetEnv("01", ::SCancPreNFE:FilSF1 , NIL, NIL, "COM", NIL, {"SF1", "SB1"})




cQuery := " SELECT SF1.R_E_C_N_O_ AS SF1_RECNO"
cQuery += " FROM " + RetSqlName("SF1") + " SF1 "
cQuery += " WHERE  SF1.F1_FILIAL  = '" + ::SCancPreNFE:FilSF1 + "'"
cQuery += " AND  SF1.F1_XIDFLG  = '" + ::SCancPreNFE:idProcFluig + "'"
cQuery += " AND   SF1.D_E_L_E_T_ = '' "

If Select("TSQL") > 0
	TSQL->(DbCloseArea())
EndIf

DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TSQL",.F., .T.)						

IF TSQL->(!EOF())
		
		
	/*------------------------------------------------------ Augusto Ribeiro | 22/03/2017 - 10:16:35 PM
		ABRE semaforo de processamento para evitar LOOp ENTRE INTEGRACAO DO FLUIG
	------------------------------------------------------------------------------------------*/
	nRDelSF1	:= TSQL->SF1_RECNO
	cFile		:= cFile+alltrim(nRDelSF1)+".lck"
	nHSemaf		:= U_CPXSEMAF("A", cFile, nHSemaf)		
	
		
	IF nHSemaf > 0				

		aRetAux	:= U_alDelPre(TSQL->SF1_RECNO)
	
		IF aRetAux[1]
		
			::SRetorno:RETORNO 	:= 1
			::SRetorno:MENSAGEM	:= " "		
		ELSE
	
			::SRetorno:RETORNO 	:= 3
			::SRetorno:MENSAGEM	:= "Falha na exclusao da pre-nota: "+aRetAux[2]		
		ENDIF
				
	ELSE
		/*------------------------------------------------------ Augusto Ribeiro | 22/03/2017 - 10:20:38 PM
			Caso semaforo já esteja aberto, significa que exclusão já esta sendo realizada
			pelo Protheus, desta forma, não existe necessidade de realizar a exclusão via 
			integracao
		------------------------------------------------------------------------------------------*/
		::SRetorno:RETORNO 	:= 1
		::SRetorno:MENSAGEM	:= ""
	ENDIF
	
	/*------------------------------------------------------ Augusto Ribeiro | 22/03/2017 - 10:16:35 PM
	FECHA semaforo de processamento para evitar LOOp ENTRE INTEGRACAO DO FLUIG
	------------------------------------------------------------------------------------------*/		
	U_CPXSEMAF("F", cFile, nHSemaf)							
		
ELSE
	::SRetorno:RETORNO 	:= 3
	::SRetorno:MENSAGEM	:= "Pre-Nota nao localizada"			
ENDIF

TSQL->(DbCloseArea())






Return .T.

/*/{Protheus.doc} GrupoUsrProtheus
Grupos Usuarios Protheus
@author Jonatas Oliveira | www.compila.com.br
@since 15/06/2017
@version 1.0
/*/
WSMETHOD GrupoUsrProtheus WSRECEIVE cGrupos WSSEND EstruturaGrpProtheus WSSERVICE wsIntegracaoFluig
	Local aRet := AllGroups()                            
	Local nI
	Local aGrupos := {}
	
	EstruturaGrpProtheus:DadosGRPPROT:GRPPROT := {}
				
	For nI := 1 to Len(aRet)	
		aAdd( EstruturaGrpProtheus:DadosGRPPROT:GRPPROT , WsClassNew( "GRPPROT" ) )
		
		EstruturaGrpProtheus:DadosGRPPROT:GRPPROT[nI]:Codigo   	:= aRet[nI][1][1]
		EstruturaGrpProtheus:DadosGRPPROT:GRPPROT[nI]:Descricao := aRet[nI][1][2]
	Next
	
	EstruturaGrpProtheus:DadosGRPPROT:MSGERRO 	:= "Sucesso"
	EstruturaGrpProtheus:DadosGRPPROT:CODERRO	:=	"0"

Return(.T.)


/*/{Protheus.doc} GrupoUsrProtheus
Grupos Usuarios Protheus
@author Jonatas Oliveira | www.compila.com.br
@since 15/06/2017
@version 1.0
/*/
WSMETHOD UsuariosProtheus WSRECEIVE cEmpUsuario WSSEND EstruturaUsrProtheus WSSERVICE wsIntegracaoFluig
	Local aRet := AllUsers()   
	Local aGrpEmp	:= {}                         
	
	Local nI
	Local nY := 0 
	Local aUsers 	:= {}
	
	EstruturaUsrProtheus:DadosUSRPROT:USRPROT := {}
			
	For nI := 1 to Len(aRet)
	
		//|Não apresenta usuário Bloqueado|
		IF !aRet[nI][1][17]
			
			aGrpEmp	:= {} 
			
			aGrpEmp := aRet[nI][2][6]
			
			//|Apenas usuários com acesso à todas empresas ou da empresa informada no parametro|
			IF aScan(aGrpEmp,{|x| AllTrim(x) == '@@@@'}) > 0  .OR. aScan(aGrpEmp,{|x| SUBSTR(x,3,3) == cEmpUsuario}) > 0 
				nY ++ 				
				
				aAdd( EstruturaUsrProtheus:DadosUSRPROT:USRPROT , WsClassNew( "USRPROT" ) )
				
				EstruturaUsrProtheus:DadosUSRPROT:USRPROT[nY]:Codigo   		:= aRet[nI][1][1]
				EstruturaUsrProtheus:DadosUSRPROT:USRPROT[nY]:Usuario   	:= aRet[nI][1][2]
				EstruturaUsrProtheus:DadosUSRPROT:USRPROT[nY]:Nome   		:= aRet[nI][1][4]
				
			ENDIF 	 
		ENDIF 
	Next nI
	
	EstruturaUsrProtheus:DadosUSRPROT:MSGERRO 	:= "Sucesso"
	EstruturaUsrProtheus:DadosUSRPROT:CODERRO	:=	"0"

Return(.T.)
