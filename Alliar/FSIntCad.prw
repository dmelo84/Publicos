#include "APWEBSRV.CH"
#include "TOPCONN.CH"
#include "PROTHEUS.CH"

//Importacao de Fornecedores
User Function CadFor(aFornecedor,cMsg)
	Local nRetorno 	:= 0
	Local nOpcao    := 0
	
	Local cA2_COD   := ""
	Local cA2_LOJA  := ""

	Local aCampos   := {}
	Local aItens    := {}

	Private lMsErroAuto := .F.
	
	nOpcao   := aFornecedor:OPERACAO  
	
	cA2_COD  := U_FncFORSq(aFornecedor)
	cA2_LOJA := U_FncFORLj(aFornecedor)

	AADD(aCampos , {"A2_TIPO"         ,aFornecedor:A2_TIPO    ,NIL})
	AADD(aCampos , {"A2_CGC"          ,aFornecedor:A2_CGC     ,NIL})
	AADD(aCampos , {"A2_NOME"         ,aFornecedor:A2_NOME    ,NIL})
	AADD(aCampos , {"A2_NREDUZ"       ,aFornecedor:A2_NREDUZ  ,NIL})
	AADD(aCampos , {"A2_END"          ,aFornecedor:A2_END     ,NIL})
	AADD(aCampos , {"A2_BAIRRO"       ,AllTrim(aFornecedor:A2_BAIRRO) ,NIL})
	AADD(aCampos , {"A2_EST"          ,aFornecedor:A2_EST     ,NIL})
	AADD(aCampos , {"A2_COD_MUN"      ,aFornecedor:A2_COD_MUN ,NIL})
	AADD(aCampos , {"A2_MUN"          ,aFornecedor:A2_MUN     ,NIL})
	AADD(aCampos , {"A2_CEP"          ,aFornecedor:A2_CEP     ,NIL})
	AADD(aCampos , {"A2_DDD"          ,aFornecedor:A2_DDD     ,NIL})
	AADD(aCampos , {"A2_TEL"          ,aFornecedor:A2_TEL     ,NIL})
	AADD(aCampos , {"A2_FAX"          ,aFornecedor:A2_FAX     ,NIL})
	AADD(aCampos , {"A2_INSCR"        ,aFornecedor:A2_INSCR   ,NIL})
	AADD(aCampos , {"A2_INSCRM"       ,aFornecedor:A2_INSCRM  ,NIL})
	AADD(aCampos , {"A2_PAIS"         ,aFornecedor:A2_PAIS    ,NIL})
	AADD(aCampos , {"A2_PAISDES"      ,aFornecedor:A2_PAISDES ,NIL})
	AADD(aCampos , {"A2_EMAIL"        ,aFornecedor:A2_EMAIL   ,NIL})
	AADD(aCampos , {"A2_HPAGE"        ,aFornecedor:A2_HPAGE   ,NIL})
	AADD(aCampos , {"A2_BANCO"        ,aFornecedor:A2_BANCO   ,NIL})
	AADD(aCampos , {"A2_AGENCIA"      ,aFornecedor:A2_AGENCIA ,NIL})
	AADD(aCampos , {"A2_NUMCON"       ,aFornecedor:A2_NUMCON  ,NIL})
	AADD(aCampos , {"A2_COND"         ,aFornecedor:A2_COND    ,NIL})
	AADD(aCampos , {"A2_NATUREZ"      ,aFornecedor:A2_NATUREZ ,NIL})
	AADD(aCampos , {"A2_RECPIS"       ,aFornecedor:A2_RECPIS  ,NIL})
	AADD(aCampos , {"A2_RECCOFI"      ,aFornecedor:A2_RECCOFI ,NIL})
	AADD(aCampos , {"A2_RECCSLL"      ,aFornecedor:A2_RECCSLL ,NIL})
	AADD(aCampos , {"A2_RECISS"       ,aFornecedor:A2_RECISS  ,NIL})
	AADD(aCampos , {"A2_CALCIRF"      ,aFornecedor:A2_CALCIRF ,NIL})
	AADD(aCampos , {"A2_SIMPNAC"      ,aFornecedor:A2_SIMPNAC ,NIL})
	AADD(aCampos , {"A2_TPJ"          ,aFornecedor:A2_TPJ     ,NIL})
	AADD(aCampos , {"A2_CODPAIS"      ,aFornecedor:A2_CODPAIS ,NIL})
	AADD(aCampos , {"A2_XIDFLG"       ,aFornecedor:A2_XIDFLG  ,NIL})
	AADD(aCampos , {"A2_DVCTA"        ,aFornecedor:A2_DVCTA   ,NIL})
	AADD(aCampos , {"A2_DVAGE"        ,aFornecedor:A2_DVAGE   ,NIL})
	AADD(aCampos , {"A2_COMPLEM"      ,aFornecedor:A2_COMPLEM ,NIL}) 
    AADD(aCampos , {"A2_COD"          ,cA2_COD                ,NIL})
	AADD(aCampos , {"A2_LOJA"         ,cA2_LOJA               ,NIL})
	AADD(aCampos , {"A2_XCLM0"        ,"2"                    ,NIL})
	  
	AAdd(aItens , aCampos)
		
	MSExecAuto({|x ,y| MATA020(x ,y)} ,aCampos ,nOpcao) //Inclusao

	Do Case		
		//Em caso de erro
		Case (lMsErroAuto)				
			//Erro ao incluir/excluir o fornecedor
			nRetorno := 3 //Erro
			cMsg := MemoRead(NomeAutoLog())
						
			//Apaga historio do execauto
			FErase(NomeAutoLog()) 
					
		//Fornecedor incluido
		Case (!lMsErroAuto .And. nOpcao == 3)		
			nRetorno := 1 //Incluida
			cMsg := "Fornecedor " + Trim(cA2_COD) +" incluido com sucesso"
			
		//Fornecedor alterado
		Case (!lMsErroAuto .And. nOpcao == 4)	
			nRetorno := 1 //Alterado
			cMsg := "Fornecedor alterado com sucesso"
			
		//Fornecedor excluido
		Case (!lMsErroAuto .And. nOpcao == 5)
			nRetorno := 1 //Excluida
			cMsg := "Fornecedor excluido com sucesso"
						
	EndCase	
	
	//Se a inclusão/edição e deleção foram realizadas com sucesso.
	if nRetorno == 1
		U_CadDBFor(aFornecedor, cA2_COD, cA2_LOJA)
	endif

Return (nRetorno)




/*/{Protheus.doc} CadForV2
Cadastro de Fornecedor Versão 2
Funcao gererica utilizando Array para desacoplar da Interface de entrada
@author Augusto Ribeiro | www.compila.com.br
@since 12/03/2018
@version version
@param nOperacao, 3=Inclusa,4=Alteracao,5=Exclusao
@param aDados, Dados do cadastro do Fornecedor
@param aBancos, Bancos vinculados ao Fornecedor (IMPORTANTE: Enviar campo OPERACAO neste Array para identificar operacao a ser realizada)
@return aRet, {.f.,""}
@example
(examples)
@see (links_or_references)
/*/
User Function CadForV2(nOperacao, aDados, aBancos)
Local aRet		:= {.f.,""}
Local cAutoLog, cMemo
LOCAL nA2COD, nA2LOJA, nA2CGC, nA2TIPO, nA2EST
Local lFindFor	:= .F.

IF !EMPTY(nOperacao) .AND. !EMPTY(aDados)

	IF nOperacao == 3 .OR. nOperacao == 4 .OR. nOperacao == 5

		nA2COD	:= aScan(aDados, { |x| AllTrim(x[1]) == "A2_COD" })
		nA2LOJA	:= aScan(aDados, { |x| AllTrim(x[1]) == "A2_LOJA" })
		nA2CGC	:= aScan(aDados, { |x| AllTrim(x[1]) == "A2_CGC" })
		nA2TIPO	:= aScan(aDados, { |x| AllTrim(x[1]) == "A2_TIPO" })
		nA2EST	:= aScan(aDados, { |x| AllTrim(x[1]) == "A2_EST" })
		
		
		IF nA2CGC > 0 .AND. nA2TIPO > 0 .AND. nA2EST > 0
			
			
			/*------------------------------------------------------ Augusto Ribeiro | 12/03/2018 - 2:27:05 PM
				GERA CODIGO DO FORNECEDOR
			------------------------------------------------------------------------------------------*/
			IF nOperacao == 3
	
				IF IIF(nA2COD == 0,.T., EMPTY(aDados[nA2COD,2]))
					aCodLoja	:= ForCdLj(nOperacao, aDados[nA2CGC,2], aDados[nA2TIPO,2], aDados[nA2EST,2])
				
					IF !EMPTY(aCodLoja)
				
						IF nA2COD > 0
							aDados[nA2COD,2]	:= aCodLoja[1]
						ELSE
							AADD(aDados, {"A2_COD",aCodLoja[1], nil})
						ENDIF
						
						IF nA2LOJA > 0
							aDados[nA2LOJA,2]	:= aCodLoja[2]
						ELSE
							AADD(aDados, {"A2_LOJA",aCodLoja[2], nil})
						ENDIF						
					ENDIF
				ENDIF
				
			ELSEIF (nOperacao == 4 .OR. nOperacao == 5) .and. nA2COD > 0
			
				cCodFor		:= PADR(ALLTRIM(aDados[nA2COD,2]),TAMSX3("A2_COD")[1])
				cLojaFor	:= PADR(ALLTRIM(aDados[nA2LOJA,2]),TAMSX3("A2_LOJA")[1])
			
				DBSELECTAREA("SA2")
				SA2->(DBSETORDER(1)) //| 
				IF SA2->(DBSEEK(xfilial("SA2")+cCodFor+cLojaFor))				
					aDados[nA2COD,2]	:= SA2->A2_COD
					aDados[nA2LOJA,2]	:= SA2->A2_LOJA	
				ENDIF
				lFindFor	:= .t.
			ENDIF
			
			
			IF ((nOperacao == 4 .OR. nOperacao == 5) .AND. lFindFor) .OR. nOperacao == 3
		
				lMsErroAuto	:= .F.
				MSExecAuto({|x ,y| MATA020(x ,y)} ,aDados ,nOperacao) //Inclusao
				
				BEGIN TRANSACTION 
				If lMsErroAuto
			
					cAutoLog	:= alltrim(NOMEAUTOLOG())
			
					cMemo := STRTRAN(MemoRead(cAutoLog),'"',"")
					cMemo := STRTRAN(cMemo,"'","")
			
					//| Apaga arquivo de Log
					Ferase(cAutoLog)
			
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Le Log da Execauto e retorna mensagem amigavel ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					aRet[1]	:= .F.
					aRet[2] := U_CPXERRO(cMemo)
					IF EMPTY(aRet[2])
						aRet[2]	:= alltrim(cMemo)
					ENDIF
					DISARMTRANSACTION()
				ELSE
				
					if !Empty(aBancos)
						aRetAux	:= bcoCadFor(SA2->A2_COD, SA2->A2_LOJA, aBancos)
						aRet	:= aRetAux
					else
						aRet[1]	:= .T.
					endif	
					
				EndIf
				END TRANSACTION 
				
			ELSE
				aRet[2]	:= "Fornecedor não localizado ["+PADR(ALLTRIM(aDados[nA2COD,2]),TAMSX3("A2_COD")[1])+"]"
			ENDIF
			
			
		ELSE
			aRet[2]	:= "Campo obrigatorios nao informados [A2_TIPO, A2_EST, A2_CGC]"
		ENDIF	
	ELSE
		aRet[2]	:= "Operacao invalida"
	ENDIF

ELSE
	aRet[2]	:= "Parametros inválidos [CadForV2]["+ALLTRIM(STR(nOperacao))+"]["+ALLTRIM(STR(LEN(aDados)))+"]"
ENDIF
	
Return(aRet)





		
//Importacao de Afastamento
User Function CadAfa(aAfastamento,cMsg)
	
	Local nRetorno := 0
	Local nOpcao   := 0

	// Local cR8_SEQ := ""
	
	Local aCampos  := {}
	Local aItens   := {}
	
	Private lMsErroAuto := .F.

	cFilAnt  := aAfastamento:R8_FILIAL
	
	cMsg     := ""
	nOpcao   := aAfastamento:OPERACAO
	
	//Cabeçalho SRA
	AADD(aCampos ,{"OPERACAO"   ,aAfastamento:OPERACAO                  ,NIL})
	AADD(aCampos ,{"RA_FILIAL"  ,xFilial("SR8" ,aAfastamento:R8_FILIAL) ,NIL})
	AADD(aCampos ,{"RA_MAT" 	 ,aAfastamento:R8_MAT                   ,NIL})
	
	//Itens SR8 
	AADD(aCampos ,{"R8_FILIAL"  ,xFilial("SR8" ,aAfastamento:R8_FILIAL) ,NIL})
	AADD(aCampos ,{"R8_MAT" 	,aAfastamento:R8_MAT                    ,NIL})
	AADD(aCampos ,{"R8_TIPOAFA" ,aAfastamento:R8_TIPOAFA                ,NIL})
	AADD(aCampos ,{"R8_DATA" 	,DATE()                                 ,NIL})
	AADD(aCampos ,{"R8_DATAINI" ,aAfastamento:R8_DATAINI                ,NIL})

	If ValType(aAfastamento:R8_CID) == "C"
		AADD(aCampos ,{"R8_CID" ,aAfastamento:R8_CID                    ,NIL})
	EndIf
	
	if(ValType(aAfastamento:R8_DATAFIM) == "D") 
		AADD(aCampos ,{"R8_DATAFIM" ,aAfastamento:R8_DATAFIM            ,NIL})
	endif 

	aAdd(aItens , aCampos)

	GravaSR8(aCampos, aItens)
	
	Do Case		
		//Em caso de erro
		Case (lMsErroAuto)				
			//Erro ao incluir/excluir produto
			nRetorno := 3 //Erro
			cMsg := MemoRead(NomeAutoLog())
						
			//Apaga historio do execauto
			FErase(NomeAutoLog()) 
					
		//Afastamento incluido
		Case (!lMsErroAuto .And. nOpcao == 3)		
			nRetorno := 1 //Incluida
			cMsg := "Afastamento incluido com sucesso"
			
		//Afastamento alterado
		Case (!lMsErroAuto .And. nOpcao == 4)
			nRetorno := 1 //Alterado
			cMsg := "Afastamento alterado com sucesso"
			
		//Afastamento excluido
		Case (!lMsErroAuto .And. nOpcao == 5)
			nRetorno := 1 //Excluida
			cMsg := "Afastamento excluido com sucesso"
						
	EndCase	
	
	//Chamada função do Oswaldo Leite - TOTVS SP
	if nRetorno == 1
		If FindFunction("U_ALGP41")
			U_ALGP41 (xFilial("SRA"), aAfastamento:R8_MAT, aAfastamento:R8_DATAFIM, aAfastamento:R8_TIPOAFA) 
		EndIf
	endif    

Return (nRetorno)

//Importacao de Pre-NF Entrada
User Function CadNFE(aPNFEntrada,cMsg)
Local nCont, i
Local nRetorno := 0
Local nF1DOC		:= TAMSX3("F1_DOC")[1]
Local nF1SERIE		:= TAMSX3("F1_SERIE")[1]
Local nF1FORNECE	:= TAMSX3("F1_FORNECE")[1]
Local nF1LOJA		:= TAMSX3("F1_LOJA")[1]
Local nRateio, aLinhaR
Local aItemRat		:= {}
Local llTemPC		:= .T.
Local llTemItPC		:= .T.
Local llPCobg		:= .F.
Local lPCNFE		:= GetNewPar( "MV_PCNFE", .F. ) 
Local lConcess		:= .f.
Local cCodProd
Local cNatuFin		:= ""
Local lHonorario	:= .F.
Local cNatFor		:= ""
Local aDuplicatas	:= {}
Local cFluxo		:= ""

Local ni

Private lMsErroAuto := .F. 
Private lMsHelpAuto := .F. 
Private lAutoErrNoFile := .T.
Private aItensR		:= {}

	
	cFilAnt := aPNFEntrada:F1_FILIAL
	
	nModulo := 4 //numero do módulo 

	aCabec := {} 
	aItens := {}
	nOpcao := aPNFEntrada:OPERACAO
	
	/*------------------------------------------------------ Augusto Ribeiro | 27/09/2018 - 5:48:29 PM
		Inclusão de Pre-Nota Honorários Medicos
	------------------------------------------------------------------------------------------*/
	IF nOpcao == 30
		lHonorario	:= .T.
		nOpcao		:= 3
	ENDIF
	
	IF nOpcao == 3	
	
		DBSELECTAREA("SA2")
		DBSETORDER(1) //| A2_FILIAL,A2_COD,A2_LOJA
		
		IF SA2->(DBSEEK(XFILIAL("SA2") + PADR(aPNFEntrada:F1_FORNECE,nF1FORNECE)+PADR(aPNFEntrada:F1_LOJA,nF1LOJA) )) .AND. lPCNFE
		
			cNatFor	:= SA2->A2_NATUREZ
		
			IF lHonorario
				llPCobg:= .F.
			ELSEIF SA2->A2_XPCOBG <> "2"   //| 1=Sim,2=Não e o Default é Sim.				
				llPCobg:= .T.			
			ENDIF
			
		ENDIF
		
		
		aPNFEntrada:F1_DOC	:= ALLTRIM(PADL(aPNFEntrada:F1_DOC,nF1DOC,"0"))
		
		DBSELECTAREA("SF1")
		SF1->(DBSETORDER(1)) //| F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA+F1_TIPO
		cChvSF1	:= xFilial("SF1" ,aPNFEntrada:F1_FILIAL)+aPNFEntrada:F1_DOC+PADR(aPNFEntrada:F1_SERIE,nF1SERIE)+PADR(aPNFEntrada:F1_FORNECE,nF1FORNECE)+PADR(aPNFEntrada:F1_LOJA,nF1LOJA)
		IF SF1->(DBSEEK(cChvSF1)) 
		
			IF ALLTRIM(aPNFEntrada:F1_XIDFLG) == ALLTRIM(SF1->F1_XIDFLG)
			
				nRetorno	:= 2
				cMsg 		:= "Pre-NF de Entrada já existe"
			ELSE
				nRetorno	:= 3
				cMsg 		:= "Pre-NF de Entrada já existe para outra solicitação. Necessario excluir pre-nota no Protheus para prosseguir"
			ENDIF
		ENDIF	
	ENDIF	
	
	
	IF nRetorno == 0
	
		ConOut("Filial " + xFilial("SF1" ,aPNFEntrada:F1_FILIAL) )
		ConOut("Doc " + aPNFEntrada:F1_DOC )
		
		aadd(aCabec,{"F1_FILIAL"  ,xFilial("SF1" ,aPNFEntrada:F1_FILIAL)                                          ,Nil}) 
		aadd(aCabec,{"F1_TIPO"    ,aPNFEntrada:F1_TIPO                                                            ,Nil}) 
		aadd(aCabec,{"F1_FORMUL"  ,aPNFEntrada:F1_FORMUL                                                          ,Nil}) 
		aadd(aCabec,{"F1_DOC"     ,aPNFEntrada:F1_DOC                                                             ,Nil})   
		aadd(aCabec,{"F1_SERIE"   ,aPNFEntrada:F1_SERIE                                                           ,Nil})      
		aadd(aCabec,{"F1_EMISSAO" ,aPNFEntrada:F1_EMISSAO                                                         ,Nil}) 
		aadd(aCabec,{"F1_FORNECE" ,aPNFEntrada:F1_FORNECE+Space(TamSX3("A2_COD")[1]-Len(aPNFEntrada:F1_FORNECE))  ,Nil}) 
		aadd(aCabec,{"F1_LOJA"    ,aPNFEntrada:F1_LOJA+Space(TamSX3("A2_LOJA")[1]-Len(aPNFEntrada:F1_LOJA))       ,Nil}) 
		
		/*----------------------------------------
			17/07/2018 - Jonatas Oliveira - Compila
			Adicionado valores:
			Despesa
			Frete
			Desconto
			Seguro
		------------------------------------------*/
		IF  AttIsMemberOf(aPNFEntrada , "F1_DESPESA") 
			IF EMPTY(aPNFEntrada:F1_DESPESA )
				aPNFEntrada:F1_DESPESA		:= 0
			ENDIF
			aadd(aCabec,{"F1_DESPESA" ,aPNFEntrada:F1_DESPESA                                                         ,Nil}) 
		ENDIF 
		
		IF  AttIsMemberOf(aPNFEntrada , "F1_FRETE") 
			
			IF EMPTY(aPNFEntrada:F1_FRETE )
				aPNFEntrada:F1_FRETE		:= 0
			ENDIF
			aadd(aCabec,{"F1_FRETE"   ,aPNFEntrada:F1_FRETE                                           	              ,Nil}) 
		ENDIF 
		
		IF  AttIsMemberOf(aPNFEntrada , "F1_DESCONT") 
			IF EMPTY(aPNFEntrada:F1_DESCONT )
				aPNFEntrada:F1_DESCONT		:= 0
			ENDIF
			
			aadd(aCabec,{"F1_DESCONT" ,aPNFEntrada:F1_DESCONT                                                         ,Nil}) 
			
		ENDIF 
		
		IF  AttIsMemberOf(aPNFEntrada , "F1_SEGURO") 
			IF EMPTY(aPNFEntrada:F1_SEGURO )
				aPNFEntrada:F1_SEGURO		:= 0
			ENDIF
		
			aadd(aCabec,{"F1_SEGURO"  ,aPNFEntrada:F1_SEGURO                                            	          ,Nil}) 
		
		ENDIF
		
		/*-----------------------------------------------------
			Competencia - Provisao contábil
		-------------------------------------------------------*/
		IF  AttIsMemberOf(aPNFEntrada , "F1_XCOMPET") 
			IF !EMPTY(aPNFEntrada:F1_XCOMPET )
				aadd(aCabec,{"F1_XCOMPET" ,aPNFEntrada:F1_XCOMPET                                                         ,Nil})
			ENDIF 
		ENDIF 		
		/*-----------------------------------------------------
			Competencia - Provisao contábil
		-------------------------------------------------------*/
		IF  AttIsMemberOf(aPNFEntrada , "F1_XMULTCP") 
			IF !EMPTY(aPNFEntrada:F1_XMULTCP )
				aadd(aCabec,{"F1_XMULTCP" ,aPNFEntrada:F1_XMULTCP                                                        ,Nil})
			ENDIF 
		ENDIF 			
		
		/*------------------------------------------------------ Augusto Ribeiro | 01/09/2017 - 2:27:12 PM
			Melhoria concessionária
		------------------------------------------------------------------------------------------*/
		if Len(aPNFEntrada:ITEM) > 0		
		
			cCodProd	:= ALLTRIM(aPNFEntrada:ITEM[1]:D1_COD)
			IF lHonorario
			
				
				aadd(aCabec,{"F1_COND" 		,"001"		,Nil}) 
				aadd(aCabec,{"F1_ESPECIE"  	,"NFSE"		,Nil})
				aadd(aCabec,{"F1_XFLUXOF" 	,"3"		,Nil}) //| 3=Honorarios Medicos|
				
				cFluxo 	:= "3"
				
				IF !EMPTY(cNatFor)
					cNatuFin	:= cNatFor
				ELSE
					cNatuFin	:= GetMv("AL_NATHM",.F.,"21010004")
				ENDIF 
				
			ELSEIF cCodProd == "13000069" .OR.;
				cCodProd == "13000070" .OR.;
				cCodProd == "13000028" .OR.;
				cCodProd == "13000071" .OR.;
				cCodProd == "13000074" .OR.;
				cCodProd == "13000083"
				
				aadd(aCabec,{"F1_XFLUXOF" 	,"2"		,Nil})//|2=Concessionarias|
				
				cFluxo := "2"
				
				lConcess	:= .T.
		
				//| Condição de pagamento fixa |
				aadd(aCabec,{"F1_COND" ,"001",Nil})
			
				IF cCodProd == "13000069"//|ENERGIA ELETRICA|
					aadd(aCabec,{"F1_ESPECIE"  , "NFCEE"                                         ,Nil})
					
					cNatuFin := GetMv("AL_NATENE",.F.,"21010050")   
					
				ELSEIF  cCodProd == "13000070"//|AGUA E ESGOTO|
					aadd(aCabec,{"F1_ESPECIE"  , "NFFA"          ,Nil})
					
					cNatuFin := GetMv("AL_NATAGU",.F.,"21010049") 
					
				ELSEIF  cCodProd == "13000028" .OR.  cCodProd == "13000071" .OR.  cCodProd == "13000074"
					aadd(aCabec,{"F1_ESPECIE"  , "NTST"                              ,Nil})
			
					IF cCodProd == "13000028"//|INTERNET|
						cNatuFin := GetMv("AL_NATINT",.F.,"21010057") 
						
					ELSEIF cCodProd == "13000071"//|TELEFONIA|
						cNatuFin := GetMv("AL_NATTEL",.F.,"21010048") 
						
					ELSEIF cCodProd == "13000074"//|TV POR ASSINATURA|
						cNatuFin := GetMv("AL_NATTVA",.F.,"21010057")			
					ENDIF 	
					
				ELSEIF cCodProd == "13000083"//| GÁS |
					aadd(aCabec,{"F1_ESPECIE"  , "NFCFG"       ,Nil})				
					cNatuFin := GetMv("AL_NATGAS",.F.,"21010069") 						
					
				ENDIF	
			ELSE
				                                                                     
				aadd(aCabec,{"F1_XFLUXOF" 	,"1"		,Nil})//|1=Lanc. Doc. Entrada|
				
				cFluxo 	:= "1"
				
			ENDIF		
		ENDIF
		
		//ConOut("F1_XVENC " + CTOD(aPNFEntrada:F1_XVENC) )
		//| Vencimento|
		IF AttIsMemberOf(aPNFEntrada , "F1_XVENC")
			IF !EMPTY(aPNFEntrada:F1_XVENC)
				aadd(aCabec,{"F1_XVENC"  ,CTOD(aPNFEntrada:F1_XVENC)                                                  ,Nil})
			ENDIF
		ENDIF 
		IF AttIsMemberOf(aPNFEntrada , "F1_COND")
			IF !EMPTY(aPNFEntrada:F1_COND)
				aadd(aCabec,{"F1_COND"  ,aPNFEntrada:F1_COND                                                  ,Nil})
			ENDIF
		ENDIF 		
		
		IF AttIsMemberOf(aPNFEntrada , "F1_XTPINT")
			IF !EMPTY(aPNFEntrada:F1_XTPINT)
				IF !EMPTY(aPNFEntrada:F1_XTPINT)
					aadd(aCabec,{"F1_XTPINT"  ,aPNFEntrada:F1_XTPINT          ,Nil})
				ELSE
					IF cFluxo == "2"			
						aadd(aCabec,{"F1_XTPINT"  ,"CS"	                      ,Nil})
								
					ELSEIF cFluxo == "3"
						aadd(aCabec,{"F1_XTPINT"  ,"HM"	                      ,Nil})
					ENDIF 	                                                
				ENDIF
			ENDIF
		ELSE
			IF cFluxo == "2"			
				aadd(aCabec,{"F1_XTPINT"  ,"CS"	                             ,Nil})
						
			ELSEIF cFluxo == "3"
				aadd(aCabec,{"F1_XTPINT"  ,"HM"				              	,Nil})
			ENDIF 	
		
		ENDIF 

		IF AttIsMemberOf(aPNFEntrada , "F1_XTPDOC")
			IF !EMPTY(aPNFEntrada:F1_XTPDOC)
				aadd(aCabec,{"F1_XTPDOC"  ,aPNFEntrada:F1_XTPDOC                                                  ,Nil})	
			ENDIF
		ENDIF 		
					
				
		aadd(aCabec,{"F1_XIDFLG"  ,aPNFEntrada:F1_XIDFLG                                                          ,Nil})
		aadd(aCabec,{"F1_USERID"  ,aPNFEntrada:F1_USERID                                                          ,Nil})
		aadd(aCabec,{"F1_DTDIGIT" ,DATE()                                                                         ,Nil})
	
		For nCont := 1 to Len(aPNFEntrada:ITEM)
			aLinha := {} 
			
			aadd(aLinha,{"D1_FILIAL"  ,xFilial("SD1" ,aPNFEntrada:F1_FILIAL) ,Nil})
			aadd(aLinha,{"D1_DOC"     ,aPNFEntrada:F1_DOC                                                             ,Nil})
			aadd(aLinha,{"D1_SERIE"   ,aPNFEntrada:F1_SERIE                                                           ,Nil})      
            aadd(aLinha,{"D1_FORNECE" ,aPNFEntrada:F1_FORNECE+Space(TamSX3("A2_COD")[1]-Len(aPNFEntrada:F1_FORNECE))  ,Nil}) 
            aadd(aLinha,{"D1_LOJA"    ,aPNFEntrada:F1_LOJA+Space(TamSX3("A2_LOJA")[1]-Len(aPNFEntrada:F1_LOJA))       ,Nil}) 			
			
			
			aadd(aLinha,{"D1_COD"     ,aPNFEntrada:ITEM[nCont]:D1_COD        ,Nil}) 
			
			//| valida se Tem pedido de compra.
			
			IF VALTYPE(aPNFEntrada:ITEM[nCont]:D1_PEDIDO)=="C"	
				IF !EMPTY(aPNFEntrada:ITEM[nCont]:D1_PEDIDO)
					aadd(aLinha,{"D1_PEDIDO"  ,aPNFEntrada:ITEM[nCont]:D1_PEDIDO     ,Nil})
					
					lConcess := .F.					
				ELSE
					llTemPC	:= .F.
				ENDIF
			ELSE
				llTemPC	:= .F.				
			ENDIF
			
			//| Valida se tem o item do pedido de compra.			
			IF VALTYPE(aPNFEntrada:ITEM[nCont]:D1_ITEMPC)=="C"			
				IF !EMPTY(aPNFEntrada:ITEM[nCont]:D1_ITEMPC)
					aadd(aLinha,{"D1_ITEMPC"  ,aPNFEntrada:ITEM[nCont]:D1_ITEMPC     ,Nil})
										
					lConcess := .F.
				ELSE
					llTemItPC := .F.
				ENDIF
			ELSE
				llTemItPC := .F. 
			ENDIF
						
			aadd(aLinha,{"D1_QUANT"   ,Val(aPNFEntrada:ITEM[nCont]:D1_QUANT) ,Nil}) 
			aadd(aLinha,{"D1_VUNIT"   ,Val(aPNFEntrada:ITEM[nCont]:D1_VUNIT) ,Nil}) 
			aadd(aLinha,{"D1_TOTAL"   ,Val(aPNFEntrada:ITEM[nCont]:D1_TOTAL) ,Nil}) 
		    //aadd(aLinha,{"D1_SERIE"   ,aPNFEntrada:F1_SERIE                  ,Nil})
		    aadd(aLinha,{"D1_EMISSAO" ,aPNFEntrada:F1_EMISSAO                ,Nil})
		    aadd(aLinha,{"D1_TIPO"    ,"N"                                   ,Nil})
		    aadd(aLinha,{"D1_TP"      ,"PA"                                  ,Nil})
		    //aadd(aLinha,{"D1_FORNECE" ,aPNFEntrada:F1_FORNECE                ,Nil})
		    //aadd(aLinha,{"D1_LOJA"    ,aPNFEntrada:F1_LOJA                   ,Nil})
		    aadd(aLinha,{"D1_DTDIGIT" ,aPNFEntrada:F1_EMISSAO                ,Nil})
		    aadd(aLinha,{"D1_ITEM"    ,aPNFEntrada:ITEM[nCont]:D1_ITEM       ,Nil}) 	
		    aadd(aLinha,{"D1_UM"      ,aPNFEntrada:ITEM[nCont]:D1_UM         ,Nil})
		    aadd(aLinha,{"D1_CC"      ,aPNFEntrada:ITEM[nCont]:D1_CC         ,Nil})
		    aadd(aLinha,{"D1_LOTEFOR" ,aPNFEntrada:ITEM[nCont]:D1_LOTEFOR    ,Nil})
		    
		    IF !EMPTY(aPNFEntrada:ITEM[nCont]:D1_DTVALID)
		    	aadd(aLinha,{"D1_DTVALID" ,aPNFEntrada:ITEM[nCont]:D1_DTVALID    ,Nil})
		    endif
		    
		    IF !EMPTY(aPNFEntrada:ITEM[nCont]:D1_LOTECTL)
		    	aadd(aLinha,{"D1_LOTECTL" ,aPNFEntrada:ITEM[nCont]:D1_LOTECTL    ,Nil})
		    ENDIF
		    
		    IF aPNFEntrada:ITEM[nCont]:D1_XBUDGET != NIL
		    	aadd(aLinha,{"D1_XBUDGET" ,aPNFEntrada:ITEM[nCont]:D1_XBUDGET    ,Nil})
		    	ConOut("D1_XBUDGET . " + aPNFEntrada:ITEM[nCont]:D1_XBUDGET )
		    ELSE
		    	ConOut("D1_XBUDGET não informado "  )
		    ENDIF 
		    
		    IF aPNFEntrada:ITEM[nCont]:D1_XMOTBUD != NIL
		    	aadd(aLinha,{"D1_XMOTBUD" ,aPNFEntrada:ITEM[nCont]:D1_XMOTBUD    ,Nil})
		    	ConOut("D1_XMOTBUD . " + aPNFEntrada:ITEM[nCont]:D1_XMOTBUD )
		    ELSE
		    	ConOut("D1_XMOTBUD não informado "  )
		    ENDIF
		    	     	
	     	aadd(aItens,aLinha)
	     	
	     		     	
	     	cItemNf	:= aPNFEntrada:ITEM[nCont]:D1_ITEM
	     	
	     	IF VALTYPE(aPNFEntrada:ITEM[nCont]:ITEMRATEIO) == "A"
	     	
	     		nRateio	:= Len(aPNFEntrada:ITEM[nCont]:ITEMRATEIO)
		     	
		     	IF nRateio > 0
		     		aadd(aItemRat, cItemNf)	 
		     	
			     	For nI := 1 to nRateio
						aLinhaR := {} 
						
						aadd(aLinhaR,{"DE_FILIAL"	,xFilial("SF1" ,aPNFEntrada:F1_FILIAL)                                          ,Nil})
						aadd(aLinhaR,{"DE_DOC"		,aPNFEntrada:F1_DOC                                                             ,Nil})
						aadd(aLinhaR,{"DE_SERIE"	,aPNFEntrada:F1_SERIE                                                           ,Nil})
						aadd(aLinhaR,{"DE_FORNECE"	,aPNFEntrada:F1_FORNECE+Space(TamSX3("A2_COD")[1]-Len(aPNFEntrada:F1_FORNECE))  ,Nil})
						aadd(aLinhaR,{"DE_LOJA"		,aPNFEntrada:F1_LOJA+Space(TamSX3("A2_LOJA")[1]-Len(aPNFEntrada:F1_LOJA))       ,Nil}) 
						aadd(aLinhaR,{"DE_ITEMNF"	,cItemNf       																	,Nil}) 
						aadd(aLinhaR,{"DE_ITEM"		,STRZERO(nI, TamSX3("DE_ITEM")[1]) 												,Nil}) 
						aadd(aLinhaR,{"DE_PERC"		,Val(aPNFEntrada:ITEM[nCont]:ITEMRATEIO[nI]:DE_PERC) 										,Nil}) 
						aadd(aLinhaR,{"DE_CC"		,aPNFEntrada:ITEM[nCont]:ITEMRATEIO[nI]:DE_CC												,Nil}) 
						//aadd(aLinhaR,{"DE_VALOR"		,Val(aPNFEntrada:ITEM[nCont]:ITEMRATEIO[nI]:DE_VALOR) 										,Nil})
			
				     	aadd(aItensR,aLinhaR)
			     	Next nI
		     	ENDIF
		     ENDIF
		     
		     //aadd(aItens,aLinha)
		     	
		Next nCont
		
		//| (Caso não pedido ou o item do pedido) e para o fornecedor exigi pedido não deixa passar.
		
		IF !llTemPC .AND. !llTemItPC .AND. llPCobg 
				
				cMsg 	:= "Para este fornecedor será necessário digitar o pedido de compra."
				Return(3)
		ENDIF
		
		
		/*------------------------------------------------------ Augusto Ribeiro | 18/12/2018 - 4:36:57 PM
			Verifica se existem duplicatas
		------------------------------------------------------------------------------------------*/
		IF AttIsMemberOf(aPNFEntrada , "DUPLICATA")
			nQtdeParc	:= len(aPNFEntrada:DUPLICATA)
			aDuplicatas	:= {}
			FOR nI := 1 TO nQtdeParc
				aadd(aDuplicatas, {aPNFEntrada:DUPLICATA[nI]:Z01_PARC,;
									aPNFEntrada:DUPLICATA[nI]:Z01_VENCTO,;
									aPNFEntrada:DUPLICATA[nI]:Z01_VALOR })
			NEXT nI
			
		ENDIF 		
		
		
		BEGIN TRANSACTION
			
			DBSELECTAREA("SDE")
		
			For nCont := 1 To Len(aItensR)
				RecLock("SDE",.T.)	
				
					SDE->DE_FILIAL		:= aItensR[nCont][1][2]	
					SDE->DE_DOC         := aItensR[nCont][2][2]	
					SDE->DE_SERIE       := aItensR[nCont][3][2]	
					SDE->DE_FORNECE     := aItensR[nCont][4][2]	
					SDE->DE_LOJA        := aItensR[nCont][5][2]	
					SDE->DE_ITEMNF      := aItensR[nCont][6][2]	
					SDE->DE_ITEM        := aItensR[nCont][7][2]	
					SDE->DE_PERC        := aItensR[nCont][8][2]	
					SDE->DE_CC          := aItensR[nCont][9][2]	
					//SDE->DE_VALOR       := aItensR[nCont][10][2]	
				
				SDE->(MsUnLock())
			Next  

			
			MSExecAuto( {|x,y,z| MATA140(x,y,z) }, aCabec, aItens, nOpcao)   
			
			If lMsErroAuto
				DISARMTRANSACTION()
				aLog := GetAutoGrLog()
		
				for i := 1 to Len(aLog)
				   cMsg += aLog[i] + Chr(13) + Chr(10) 
				Next i
		
				//Return(3)
				nRetorno := 3
			Else
			
			
				/*------------------------------------------------------ Augusto Ribeiro | 25/04/2017 - 2:27:07 PM
					Grava FLAG do rateio via Reclock pois campo nao existe na Pre-nota
					e não e gravado pela execauto					
				------------------------------------------------------------------------------------------*/
				IF LEN(aItemRat) >= 1
					
					DBSELECTAREA("SD1")
					SD1->(DBSETORDER(1)) //| D1_FILIAL, D1_DOC, D1_SERIE, D1_FORNECE, D1_LOJA, D1_COD, D1_ITEM, R_E_C_N_O_, D_E_L_E_T_
					IF SD1->(DBSEEK(SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA))) 
						
						WHILE SD1->(!EOF()) .AND. SD1->(D1_FILIAL+D1_DOC+D1_SERIE+D1_FORNECE+D1_LOJA) == SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)
						
							IF aScan(aItemRat,SD1->D1_ITEM) > 0								
								RECLOCK("SD1", .F.)
									SD1->D1_RATEIO := "1"								
								MSUNLOCK()								
							ENDIF 
						
							SD1->(DBSKIP())
						ENDDO
							
					ENDIF
				ENDIF
			
			
				nRetorno := 1
		
				If nOpcao == 3
				
					IF LEN(aDuplicatas) > 0
					
						/*------------------------------------------------------ Augusto Ribeiro | 18/12/2018 - 4:45:52 PM
							Caso ja exista, exclui registros
						------------------------------------------------------------------------------------------*/
						DBSELECTAREA("Z01")
						Z01->(DBSETORDER(1))//| Z01_FILIAL+Z01_DOC+Z01_SERIE+Z01_FORNEC+Z01_LOJA+Z01_PARC
						IF Z01->(DBSEEK(SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA)))
							WHILE Z01->(!EOF()) .AND. SF1->(F1_FILIAL+F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA) == Z01->(Z01_FILIAL+Z01_DOC+Z01_SERIE+Z01_FORNEC+Z01_LOJA)
							
								RECLOCK("Z01",.F.)
									Z01->(DBDELETE())
								MSUNLOCK()
								
								Z01->(DBSKIP())
							ENDDO 
						ENDIF
					
						FOR nI := 1 to len(aDuplicatas)
							RECLOCK("Z01",.T.)							
								Z01->Z01_FILIAL   := SF1->F1_FILIAL
								Z01->Z01_DOC      := SF1->F1_DOC
								Z01->Z01_SERIE    := SF1->F1_SERIE
								Z01->Z01_FORNEC   := SF1->F1_FORNECE
								Z01->Z01_LOJA     := SF1->F1_LOJA
								Z01->Z01_PARC     := aDuplicatas[nI,1]
								Z01->Z01_VENCTO   := aDuplicatas[nI,2]
								Z01->Z01_VALOR    := val(aDuplicatas[nI,3])							
							MSUNLOCK()
						
						NEXT nI					
					ENDIF
				
				
					cMsg := "Pre-NF de Entrada incluída com sucesso"
				ElseIf nOpcao == 4
					cMsg := "Pre-NF de Entrada alterada com sucesso!"
				ElseIf nOpcao == 5
					cMsg := "Pre-NF de Entrada excluída com sucesso!"
				Else
					nRetorno := 4
					cMsg := "Operação inválida!"
				EndIf
			EndIf
			
		END TRANSACTION 
		
		
		
		if nRetorno == 1
			/*------------------------------------------------------ Augusto Ribeiro | 08/09/2017 - 10:46:01 AM
				Classifica NFE automaticamente de forma assincrona
			------------------------------------------------------------------------------------------*/
			lClaNFE	:= GETMV("ES_AUTOCLA",.F.,.F.)
			IF lConcess  .AND. lClaNFE	.and. nRetorno == 1
				STARTJOB("U_alJClaNF",GetEnvServer(), .F., {"01",SF1->F1_FILIAL,SF1->F1_DOC,SF1->F1_SERIE,SF1->F1_FORNECE,SF1->F1_LOJA,cNatuFin})
	//			U_CP12ADD("000018", "SF1", SF1->(RECNO()), , )
			ENDIF
		endif
	ENDIF

Return(nRetorno)

//Importacao de troca de turno
User Function CadTUR(aTrocaTurno,cMsg)
	Local nRetorno 	:= 0
	Local nOpcao    := 0
	Local cMatSPF   := AllTrim(aTrocaTurno:PF_MAT)+Space(TamSX3("PF_MAT")[1]-Len(AllTrim(aTrocaTurno:PF_MAT)))
	
	//Inicio Variaveis SRA
	Local i := 0
	Local aRotina := {} //| StaticCall(gpea010 ,MenuDef) //| FUNCAO NAO UTILIZADA - REMOCAO PARA COMPILA 12.1.33
	Local aCampos := {}
	//Local aLog    := {}
	
	Private lMsErroAuto := .F.
	//Fim Variaveis SRA
	
	cFilAnt  := aTrocaTurno:PF_FILIAL
	
	cMsg   := ""
	nOpcao := aTrocaTurno:OPERACAO 
	
	Do Case 	
		Case (nOpcao == 3) //Inclusão
        
	        //Validações afastamento
	        nRetorno := U_FncTURVl(aTrocaTurno, cMatSPF, @cMsg)
	        
	        if (nRetorno == 3)
	        	Return(nRetorno)
	        endif
	        	     
	        dbSelectArea("SPF")
			RecLock("SPF",.T.)
			
			SPF->PF_FILIAL  := xFilial("SPF",aTrocaTurno:PF_FILIAL)
			SPF->PF_MAT     := cMatSPF
			SPF->PF_DATA    := aTrocaTurno:PF_DATA
			SPF->PF_TURNODE := aTrocaTurno:PF_TURNODE
			SPF->PF_SEQUEDE := aTrocaTurno:PF_SEQUEDE
			SPF->PF_REGRADE := aTrocaTurno:PF_REGRADE
			SPF->PF_TURNOPA := aTrocaTurno:PF_TURNOPA
			SPF->PF_SEQUEPA := aTrocaTurno:PF_SEQUEPA
			SPF->PF_REGRAPA := aTrocaTurno:PF_REGRAPA
			SPF->(MsUnlock())
			
			//Inicio Atualização SRA
			aAdd(aCampos, {"RA_FILIAL"   ,xFilial("SRA",aTrocaTurno:PF_FILIAL) ,NIL})
			aAdd(aCampos, {"RA_MAT"      ,cMatSPF                              ,NIL})
			aAdd(aCampos, {"RA_TNOTRAB"  ,aTrocaTurno:PF_TURNOPA               ,NIL})
			aAdd(aCampos, {"RA_REGRA"    ,aTrocaTurno:PF_REGRAPA               ,NIL})
			aAdd(aCampos, {"RA_SEQTURN"  ,aTrocaTurno:PF_SEQUEPA               ,NIL})
				
			MSExecAuto({|x,y,w,z| GPEA010(x,y,w,z)} ,Nil ,aRotina ,aCampos ,4)
			//Fim Atualização SRA
			
			If (!lMsErroAuto)				
				//Código Oswaldo Equipe SP
				dbSelectArea('SR6')
				SR6->(DbSetOrder(1))
				SR6->(DbSeek( Fwxfilial('SR6') + SRA->RA_TNOTRAB )  )
 
				If SR6->(!Eof()) .And. AllTrim(SR6->R6_TURNO) ==  AllTrim(SRA->RA_TNOTRAB)
					RECLOCK('SRA',.F.)
				
					SRA->RA_HRSMES  := SR6->R6_XHRSME
					SRA->RA_HRSEMAN := SR6->R6_XHRSME / 5
					SRA->RA_JORNRED := SRA->RA_HRSEMAN
					SRA->RA_HRSDIA  := SRA->RA_HRSEMAN / 6 
 
					If AllTrim(SRA->RA_ADCPERI) == "2"
						SRA->RA_PERICUL := SRA->RA_HRSMES
						
					EndIf
				
					If AllTrim(SRA->RA_ADCINS) != "1"

           			 SRA->RA_INSMAX  := SRA->RA_HRSMES
   					ENDIF
				
					SRA->(MsUnlock())   
				EndIf
			
			EndIf
			
	        cMsg := "Troca de Turno incluida com sucesso"
        	
	    Case (nOpcao = 4) //Edição
	    	
	    	//Validações afastamento
	        nRetorno := U_FncTURVl(aTrocaTurno, cMatSPF, @cMsg)
	        
	        if (nRetorno == 3)
	        	Return(nRetorno)
	        endif
	        	        	
	    	dbSelectArea("SPF")
	        dbSetOrder(1)      
	        dbSeek(xFilial("SPF",aTrocaTurno:PF_FILIAL)+cMatSPF+DTOS(aTrocaTurno:PF_DATA))
        	
	        RECLOCK("SPF", .F.)
        	
	        SPF->PF_TURNODE := aTrocaTurno:PF_TURNODE
			SPF->PF_SEQUEDE := aTrocaTurno:PF_SEQUEDE
			SPF->PF_REGRADE := aTrocaTurno:PF_REGRADE
			SPF->PF_TURNOPA := aTrocaTurno:PF_TURNOPA
			SPF->PF_SEQUEPA := aTrocaTurno:PF_SEQUEPA
			SPF->PF_REGRAPA := aTrocaTurno:PF_REGRAPA
        	
	        //Destrava o registro
	        SPF->(MsUnlock())    
	        
	        //Inicio Atualização SRA
			aAdd(aCampos, {"RA_FILIAL"   ,xFilial("SRA",aTrocaTurno:PF_FILIAL) ,NIL})
			aAdd(aCampos, {"RA_MAT"      ,cMatSPF                              ,NIL})
			aAdd(aCampos, {"RA_TNOTRAB"  ,aTrocaTurno:PF_TURNOPA               ,NIL})
			aAdd(aCampos, {"RA_REGRA"    ,aTrocaTurno:PF_REGRAPA               ,NIL})
			aAdd(aCampos, {"RA_SEQTURN"  ,aTrocaTurno:PF_SEQUEPA               ,NIL})
				
			MSExecAuto({|x,y,w,z| GPEA010(x,y,w,z)} ,Nil ,aRotina ,aCampos ,4)
			//Fim Atualização SRA
			
			If (!lMsErroAuto)
				//Código Oswaldo Equipe SP
				dbSelectArea('SR6')
				SR6->(DbSetOrder(1))
				SR6->(DbSeek( Fwxfilial('SR6') + SRA->RA_TNOTRAB )  )
 
				If SR6->(!Eof()) .And. AllTrim(SR6->R6_TURNO) ==  AllTrim(SRA->RA_TNOTRAB)
					RECLOCK('SRA',.F.)
					SRA->RA_HRSMES  := SR6->R6_XHRSME
					SRA->RA_HRSEMAN := SR6->R6_XHRSME / 5
					SRA->RA_JORNRED := SRA->RA_HRSEMAN
					SRA->RA_HRSDIA  := SRA->RA_HRSEMAN / 6 
 
					If AllTrim(SRA-> RA_ADCPERI) == "2"
						SRA-> RA_PERICUL := SRA->RA_HRSMES
					EndIf
 
					SRA->(MsUnlock())   
				EndIf
			EndIf
			
	        cMsg := "Troca de Turno alterada com sucesso"
        	
	    Case (nOpcao == 5) //Exclusão
	    	SPF->(DbSetOrder(1))
         
	        //Busca exata
	        if SPF->(dbSeek(xFilial("SPF",aTrocaTurno:PF_FILIAL)+cMatSPF+DTOS(aTrocaTurno:PF_DATA)))     
	        	RecLock("SPF")
	        	SPF->(DbDelete())
	        	SPF->(MsUnlock())
            
	        	cMsg := "Troca de Turno excluída com sucesso"
	        endif
	End Case	

Return (nRetorno)

//Importacao de acidente de trabalho
User Function CadACT(aAcidenteTrabalho,cMsg)
	Local nRetorno 	:= 0
	Local nOpcao    := 0
	
	nOpcao   := aAcidenteTrabalho:OPERACAO 
	nRetorno := 1
	cMsg     := ""
	
	Do Case 	
		Case (nOpcao == 3) //Inclusão
        
			//Validações Acidente de trabalho
	        nRetorno := U_FncACTVl(aAcidenteTrabalho, @cMsg)
	        
	        if (nRetorno == 3)
	        	Return(nRetorno)
	        endif
	        	        	
	        dbSelectArea("TNC")
        	
	        TNC->(RECLOCK("TNC", .T.))
        	
	        TNC->TNC_FILIAL := xFilial("TNC", aAcidenteTrabalho:TNC_FILIAL)
	        TNC->TNC_ACIDEN := U_FncACTSq(aAcidenteTrabalho)
			TNC->TNC_MAT    := aAcidenteTrabalho:TNC_MAT
			TNC->TNC_TIPCAT := aAcidenteTrabalho:TNC_TIPCAT
			TNC->TNC_TIPREV := aAcidenteTrabalho:TNC_TIPREV
			TNC->TNC_APOSEN := aAcidenteTrabalho:TNC_APOSEN
			TNC->TNC_AREA   := aAcidenteTrabalho:TNC_AREA
			TNC->TNC_DTACID := aAcidenteTrabalho:TNC_DTACID
			TNC->TNC_HRACID := aAcidenteTrabalho:TNC_HRACID
			TNC->TNC_HRTRAB := aAcidenteTrabalho:TNC_HRTRAB
			TNC->TNC_TIPACI := aAcidenteTrabalho:TNC_TIPACI
			TNC->TNC_AFASTA := aAcidenteTrabalho:TNC_AFASTA
			TNC->TNC_DTULTI := aAcidenteTrabalho:TNC_DTULTI
			TNC->TNC_INDLOC := aAcidenteTrabalho:TNC_INDLOC
			TNC->TNC_LOCAL  := aAcidenteTrabalho:TNC_LOCAL
			TNC->TNC_CGCPRE := aAcidenteTrabalho:TNC_CGCPRE
			TNC->TNC_ESTACI := aAcidenteTrabalho:TNC_ESTACI
			TNC->TNC_CIDACI := aAcidenteTrabalho:TNC_CIDACI
			TNC->TNC_PARTE  := aAcidenteTrabalho:TNC_PARTE				
			TNC->TNC_CODOBJ := aAcidenteTrabalho:TNC_CODOBJ
			
			TNC->TNC_DESACI := aAcidenteTrabalho:TNC_DESACI
            TNC->TNC_INDACI := aAcidenteTrabalho:TNC_INDACI
            TNC->TNC_VITIMA := aAcidenteTrabalho:TNC_VITIMA
            TNC->TNC_NUMFIC := aAcidenteTrabalho:TNC_NUMFIC
            TNC->TNC_TRANSF := aAcidenteTrabalho:TNC_TRANSF
            TNC->TNC_EMITEN := aAcidenteTrabalho:TNC_EMITEN
            TNC->TNC_DTOBIT := aAcidenteTrabalho:TNC_DTOBIT
            TNC->TNC_CODCID := aAcidenteTrabalho:TNC_CODCID
            TNC->TNC_DESCR1 := aAcidenteTrabalho:TNC_DESCR1
            TNC->TNC_POLICI := aAcidenteTrabalho:TNC_POLICI
            TNC->TNC_MORTE  := aAcidenteTrabalho:TNC_MORTE
            TNC->TNC_CODPAR := aAcidenteTrabalho:TNC_CODPAR
            TNC->TNC_CODLES := aAcidenteTrabalho:TNC_CODLES
            TNC->TNC_LOCACT := aAcidenteTrabalho:TNC_LOCACT
            TNC->TNC_HORSAI := aAcidenteTrabalho:TNC_HORSAI
            TNC->TNC_TRAJET := aAcidenteTrabalho:TNC_TRAJET
            TNC->TNC_MEIO   := aAcidenteTrabalho:TNC_MEIO
            TNC->TNC_LOCACI := aAcidenteTrabalho:TNC_LOCACI
            TNC->TNC_DISTAC := aAcidenteTrabalho:TNC_DISTAC
            TNC->TNC_XDISTA := aAcidenteTrabalho:TNC_XDISTA            
            
            TNC->TNC_MUDANC := aAcidenteTrabalho:TNC_MUDANC
            TNC->TNC_MOTIVO := aAcidenteTrabalho:TNC_MOTIVO
            
            TNC->TNC_TESTE1 := aAcidenteTrabalho:TNC_TESTE1    
            TNC->TNC_ENDTE1 := aAcidenteTrabalho:TNC_ENDTE1    
            TNC->TNC_NUEND1 := aAcidenteTrabalho:TNC_NUEND1   
            TNC->TNC_BAIRR1 := aAcidenteTrabalho:TNC_BAIRR1     
            TNC->TNC_ESTAD1 := aAcidenteTrabalho:TNC_ESTAD1     
            TNC->TNC_CIDT1  := aAcidenteTrabalho:TNC_CIDT1   
            TNC->TNC_CIDAD1 := aAcidenteTrabalho:TNC_CIDAD1   
            TNC->TNC_MTEST1 := aAcidenteTrabalho:TNC_MTEST1 
            TNC->TNC_TESTE2 := aAcidenteTrabalho:TNC_TESTE2  
            TNC->TNC_ENDTE2 := aAcidenteTrabalho:TNC_ENDTE2 
            TNC->TNC_NUEND2 := aAcidenteTrabalho:TNC_NUEND2    
            TNC->TNC_BAIRR2 := aAcidenteTrabalho:TNC_BAIRR2   
            TNC->TNC_ESTAD2 := aAcidenteTrabalho:TNC_ESTAD2  
            TNC->TNC_CIDT2  := aAcidenteTrabalho:TNC_CIDT2   
            TNC->TNC_CIDAD2 := aAcidenteTrabalho:TNC_CIDAD2   
            TNC->TNC_MTEST2 := aAcidenteTrabalho:TNC_MTEST2
            
            TNC->TNC_NOMFIC := aAcidenteTrabalho:TNC_NOMFIC
        	
	        //Destrava o registro
	        TNC->(MSUNLOCK())     
		
	        cMsg := "Acidente de trabalho incluido com sucesso"
        	
	    Case (nOpcao = 4) //Edição
	    	
	    	//Validações afastamento
	        nRetorno := U_FncACTVl(aAcidenteTrabalho, @cMsg)
	        
	        if (nRetorno == 3)
	        	Return(nRetorno)
	        endif
	        	        	
	    	dbSelectArea("TNC")
	        dbSetOrder(1)      
	        dbSeek(xFilial("TNC", aAcidenteTrabalho:TNC_FILIAL)+aAcidenteTrabalho:TNC_ACIDEN)
        	
	        TNC->(RECLOCK("TNC", .F.))
        	
			TNC->TNC_MAT    := xFilial("TNC", aAcidenteTrabalho:TNC_FILIAL)
			TNC->TNC_TIPCAT := aAcidenteTrabalho:TNC_TIPCAT
			TNC->TNC_TIPREV := aAcidenteTrabalho:TNC_TIPREV
			TNC->TNC_APOSEN := aAcidenteTrabalho:TNC_APOSEN
			TNC->TNC_AREA   := aAcidenteTrabalho:TNC_AREA
			TNC->TNC_DTACID := aAcidenteTrabalho:TNC_DTACID
			TNC->TNC_HRACID := aAcidenteTrabalho:TNC_HRACID
			TNC->TNC_HRTRAB := aAcidenteTrabalho:TNC_HRTRAB
			TNC->TNC_TIPACI := aAcidenteTrabalho:TNC_TIPACI
			TNC->TNC_AFASTA := aAcidenteTrabalho:TNC_AFASTA
			TNC->TNC_DTULTI := aAcidenteTrabalho:TNC_DTULTI
			TNC->TNC_INDLOC := aAcidenteTrabalho:TNC_INDLOC
			TNC->TNC_LOCAL  := aAcidenteTrabalho:TNC_LOCAL
			TNC->TNC_CGCPRE := aAcidenteTrabalho:TNC_CGCPRE
			TNC->TNC_ESTACI := aAcidenteTrabalho:TNC_ESTACI
			TNC->TNC_CIDACI := aAcidenteTrabalho:TNC_CIDACI
			TNC->TNC_PARTE  := aAcidenteTrabalho:TNC_PARTE				
			TNC->TNC_CODOBJ := aAcidenteTrabalho:TNC_CODOBJ
			
			TNC->TNC_DESACI := aAcidenteTrabalho:TNC_DESACI
            TNC->TNC_INDACI := aAcidenteTrabalho:TNC_INDACI
            TNC->TNC_VITIMA := aAcidenteTrabalho:TNC_VITIMA
            TNC->TNC_NUMFIC := aAcidenteTrabalho:TNC_NUMFIC
            TNC->TNC_TRANSF := aAcidenteTrabalho:TNC_TRANSF
            TNC->TNC_EMITEN := aAcidenteTrabalho:TNC_EMITEN
            TNC->TNC_DTOBIT := aAcidenteTrabalho:TNC_DTOBIT
            TNC->TNC_CODCID := aAcidenteTrabalho:TNC_CODCID
            TNC->TNC_DESCR1 := aAcidenteTrabalho:TNC_DESCR1
            TNC->TNC_POLICI := aAcidenteTrabalho:TNC_POLICI
            TNC->TNC_MORTE  := aAcidenteTrabalho:TNC_MORTE
            TNC->TNC_CODPAR := aAcidenteTrabalho:TNC_CODPAR
            TNC->TNC_CODLES := aAcidenteTrabalho:TNC_CODLES
            TNC->TNC_LOCACT := aAcidenteTrabalho:TNC_LOCACT
            TNC->TNC_HORSAI := aAcidenteTrabalho:TNC_HORSAI
            TNC->TNC_TRAJET := aAcidenteTrabalho:TNC_TRAJET
            TNC->TNC_MEIO   := aAcidenteTrabalho:TNC_MEIO
            TNC->TNC_LOCACI := aAcidenteTrabalho:TNC_LOCACI
            TNC->TNC_DISTAC := aAcidenteTrabalho:TNC_DISTAC
            TNC->TNC_XDISTA := aAcidenteTrabalho:TNC_XDISTA 
            
            
            
            TNC->TNC_MUDANC := aAcidenteTrabalho:TNC_MUDANC
            TNC->TNC_MOTIVO := aAcidenteTrabalho:TNC_MOTIVO
            
            TNC->TNC_TESTE1 := aAcidenteTrabalho:TNC_TESTE1    
            TNC->TNC_ENDTE1 := aAcidenteTrabalho:TNC_ENDTE1    
            TNC->TNC_NUEND1 := aAcidenteTrabalho:TNC_NUEND1   
            TNC->TNC_BAIRR1 := aAcidenteTrabalho:TNC_BAIRR1     
            TNC->TNC_ESTAD1 := aAcidenteTrabalho:TNC_ESTAD1     
            TNC->TNC_CIDT1  := aAcidenteTrabalho:TNC_CIDT1   
            TNC->TNC_CIDAD1 := aAcidenteTrabalho:TNC_CIDAD1   
            TNC->TNC_MTEST1 := aAcidenteTrabalho:TNC_MTEST1 
            TNC->TNC_TESTE2 := aAcidenteTrabalho:TNC_TESTE2  
            TNC->TNC_ENDTE2 := aAcidenteTrabalho:TNC_ENDTE2 
            TNC->TNC_NUEND2 := aAcidenteTrabalho:TNC_NUEND2    
            TNC->TNC_BAIRR2 := aAcidenteTrabalho:TNC_BAIRR2   
            TNC->TNC_ESTAD2 := aAcidenteTrabalho:TNC_ESTAD2  
            TNC->TNC_CIDT2  := aAcidenteTrabalho:TNC_CIDT2   
            TNC->TNC_CIDAD2 := aAcidenteTrabalho:TNC_CIDAD2   
            TNC->TNC_MTEST2 := aAcidenteTrabalho:TNC_MTEST2
            
            TNC->TNC_NOMFIC := aAcidenteTrabalho:TNC_NOMFIC
        	
	        //Destrava o registro
	        TNC->(MSUNLOCK())     
		
	        cMsg := "Acidente de trabalho alterado com sucesso"
        	
	    Case (nOpcao == 5) //Exclusão
	    	TNC->(DbSetOrder(1))
	    	
	        //Busca exata
	        if TNC->(dbSeek(xFilial("TNC", aAcidenteTrabalho:TNC_FILIAL)+aAcidenteTrabalho:TNC_ACIDEN))   
	        	RecLock("TNC")
	        	TNC->(DbDelete())
	        	TNC->(MsUnlock())
            
	        	cMsg := "Acidente de trabalho excluído com sucesso"
	        endif
	End Case	

Return (nRetorno)

//Importacao de solicitação de compra
User Function CadSOC(aSolicitacaoCompra,cMsg)
	
	Local nOpcao := aSolicitacaoCompra:OPERACAO 
	Local nRetorno := 0, i, nCount
	Local aCab := {}, aItem := {}, aLinha := {}
	Local cLogin := "", cEmailUsr := "", aDetUsr := {}, aGrupos := {}
	Local cGrpApr	:= ""
	Local cChvSC1	:= ""
	Local nRecSc1	:= 0
	
	Private lMsErroAuto := .F. 
	Private lMsHelpAuto := .F. 
	Private lAutoErrNoFile := .T.

	cMsg     := ""

	cEmailUsr := aSolicitacaoCompra:C1_SOLICIT //endereço de E-mail que vem do fluig

	//Busca Usuário pelo e-mail
	PswOrder(4)
	
	If PswSeek(cEmailUsr, .T.)
		aDetUsr := PswRet()
		aGrupos := aClone(aDetUsr[1][10])
		cLogin  := aDetUsr[1][2] //Login do Usuário
		__CUSERID := aDetUsr[1][1]
	EndIf

	If nOpcao <> 3
		aCab := {{"C1_FILIAL"  ,xFilial("SC1", aSolicitacaoCompra:C1_FILIAL) ,Nil},;
		         {"C1_EMISSAO" ,aSolicitacaoCompra:C1_EMISSAO                ,Nil},; // Data de Emissao
			     {"C1_SOLICIT" ,cLogin                                       ,Nil},;
			     {"C1_NUM" 	   ,aSolicitacaoCompra:C1_NUM                    ,Nil}}
	Else
		aCab := {{"C1_FILIAL"  ,xFilial("SC1", aSolicitacaoCompra:C1_FILIAL) ,Nil},;
			     {"C1_EMISSAO" ,aSolicitacaoCompra:C1_EMISSAO                ,Nil},; // Data de Emissao
		         {"C1_SOLICIT" ,cLogin                                       ,Nil}}	
	EndIf

	For nCount := 1 to Len(aSolicitacaoCompra:ITEM)
		aLinha := {}
					
		aadd(aLinha,{"C1_ITEM"      ,aSolicitacaoCompra:ITEM[nCount]:C1_ITEM      ,Nil})
		aadd(aLinha,{"C1_PRODUTO"   ,aSolicitacaoCompra:ITEM[nCount]:C1_PRODUTO   ,Nil})
		aadd(aLinha,{"C1_QUANT"     ,Val(aSolicitacaoCompra:ITEM[nCount]:C1_QUANT),Nil})
		aadd(aLinha,{"C1_LOCAL"     ,aSolicitacaoCompra:ITEM[nCount]:C1_LOCAL     ,Nil})
		aadd(aLinha,{"C1_DATPRF"    ,aSolicitacaoCompra:ITEM[nCount]:C1_DATPRF    ,Nil})
		aadd(aLinha,{"C1_CC"        ,aSolicitacaoCompra:ITEM[nCount]:C1_CC        ,Nil})
		aadd(aLinha,{"C1_OBS"       ,aSolicitacaoCompra:ITEM[nCount]:C1_OBS       ,Nil})
		aadd(aLinha,{"C1_ORIGEM"    ,"FsIntCad"                                   ,Nil}) 
		aadd(aLinha,{"C1_XIDFLG"    ,aSolicitacaoCompra:C1_XIDFLG                 ,Nil})
	   aadd(aLinha,{"C1_XTPSCFL"   ,aSolicitacaoCompra:C1_XTPSCFL                ,Nil})


		xTmp:= Valtype(aSolicitacaoCompra:ITEM[nCount]:C1_XBUDGET)

		IF xTmp == "U"
			aadd(aLinha,{"C1_XBUDGET"	, "X"		,Nil})  //abax 
		ELSE
			aadd(aLinha,{"C1_XBUDGET"	, aSolicitacaoCompra:ITEM[nCount]:C1_XBUDGET		,Nil})  //abax
		ENDIF

		xTmp:= Valtype(aSolicitacaoCompra:ITEM[nCount]:C1_XMOTBUD)

		IF xTmp == "U"
			aadd(aLinha,{"C1_XMOTBUD"	, ""		,Nil})      //abax
		ELSE
			aadd(aLinha,{"C1_XMOTBUD"	,aSolicitacaoCompra:ITEM[nCount]:C1_XMOTBUD		,Nil})      //abax
		ENDIF

			// aadd(aLinha,{"C1_XGRUP"     ,aSolicitacaoCompra:ITEM[nCount]:C1_XGRUP     ,Nil})  //abax Retirado

     	aadd(aItem,aLinha) 
	Next

	CUSERNAME := cLogin

	MSExecAuto({|v,x,y| MATA110(v,x,y)},aCab,aItem,nOpcao)
	  
	If lMsErroAuto
		aLog := GetAutoGrLog()

		for i := 1 to Len(aLog)
		   cMsg += aLog[i] + Chr(13) + Chr(10) 
		Next i

		Return(3)
	Else
	
		cChvSc1	:= XFILIAL("SC1") + SC1->C1_NUM
		nRecSc1	:= SC1->( RECNO() )
		
		DBSELECTAREA("SC1")
		SC1->(DBSETORDER(1))
		
		SC1->(DBGOTOP())
		
		IF SC1->(DBSEEK(cChvSc1))
			WHILE SC1->(!EOF()) .AND. cChvSc1	== XFILIAL("SC1") + SC1->C1_NUM
			
				cGrpApr := U_ALCOM6("SC1")
				
				IF SC1->C1_XAPROV <> cGrpApr
					SC1->(RecLock("SC1",.F.))
						SC1->C1_XAPROV := cGrpApr					
					SC1->(MsUnLock())
				ENDIF 
				
				SC1->(DBSKIP())
			ENDDO		
		ENDIF 
		
		SC1->(DBGOTO( nRecSc1 ))
		If nOpcao == 3
			cMsg := "Solicitação de Compra incluída com sucesso"
		ElseIf nOpcao == 4
			cMsg := "Solicitação de Compra alterada com sucesso!"
		ElseIf nOpcao == 5
			cMsg := "Solicitação de Compra excluída com sucesso!"
		EndIf
		nRetorno := 1	
	EndIf

Return (nRetorno)

//Importacao de programação de férias
User Function CadPFE(aProgramacaoFerias,cMsg)
	Local nRetorno 	:= 0
	Local nOpcao    := 0
	
	nOpcao   := aProgramacaoFerias:OPERACAO
	nRetorno := 1
	cMsg     := ""

    Do Case 	
    	Case (nOpcao == 3) //Inclusão
        
	        //Validações Programação Férias
	        nRetorno := U_FncPFEVl(aProgramacaoFerias, @cMsg)
	        
	        if (nRetorno == 3)
	        	Return(nRetorno)
	        endif
	        	       
	        dbSelectArea("SRF")
        	
	        RECLOCK("SRF", .T.)
        	
	        SRF->RF_FILIAL     := aProgramacaoFerias:RF_FILIAL
	        SRF->RF_TEMABPE    := aProgramacaoFerias:RF_TEMABPE
			SRF->RF_MAT        := aProgramacaoFerias:RF_MAT
			SRF->RF_DFERVAT    := Val(aProgramacaoFerias:RF_DFERVAT)
			SRF->RF_DFEPRO1    := Val(aProgramacaoFerias:RF_DFEPRO1)
			SRF->RF_DABPRO1    := Val(aProgramacaoFerias:RF_DABPRO1)	
			SRF->RF_DATAINI    := aProgramacaoFerias:RF_DATAINI
			SRF->RF_PERC13S    := Val(aProgramacaoFerias:RF_PERC13S)
			SRF->RF_DATABAS    := aProgramacaoFerias:RF_DATABAS
			SRF->RF_DATAFIM    := aProgramacaoFerias:RF_DATAFIM
			SRF->RF_PD         := aProgramacaoFerias:RF_PD
			SRF->RF_STATUS     := aProgramacaoFerias:RF_STATUS
			SRF->RF_ABOPEC     := aProgramacaoFerias:RF_ABOPEC
			
	        //Destrava o registro
	        MSUNLOCK()     
		
	        cMsg := "Programação de Férias incluida com sucesso"
        	
	    Case (nOpcao = 4) //Edição
	    	
	    	//Validações afastamento
	        nRetorno := U_FncPFEVl(aProgramacaoFerias, @cMsg)
	        
	        if (nRetorno == 3)
	        	Return(nRetorno)
	        endif
	        	        
			dbSelectArea("SRF")
			dbSetOrder(1)
			If dbSeek(aProgramacaoFerias:RF_FILIAL + aProgramacaoFerias:RF_MAT + DTOS(aProgramacaoFerias:RF_DATABAS))     // Busca exata
				While !SRF->(Eof())
 
					If aProgramacaoFerias:RF_DATABAS = SRF->RF_DATABAS .AND. aProgramacaoFerias:RF_DATAFIM = SRF->RF_DATAFIM .AND.;
					   aProgramacaoFerias:RF_FILIAL  = SRF->RF_FILIAL  .AND. aProgramacaoFerias:RF_MAT     = SRF->RF_MAT  
						Reclock("SRF", .F.)
						SRF->RF_FILIAL     := aProgramacaoFerias:RF_FILIAL
						SRF->RF_TEMABPE    := aProgramacaoFerias:RF_TEMABPE
						SRF->RF_MAT        := aProgramacaoFerias:RF_MAT
						SRF->RF_DFERVAT    := Val(aProgramacaoFerias:RF_DFERVAT)
						SRF->RF_DFEPRO1    := Val(aProgramacaoFerias:RF_DFEPRO1)
						SRF->RF_DABPRO1    := Val(aProgramacaoFerias:RF_DABPRO1)
			        	SRF->RF_DATAINI    := aProgramacaoFerias:RF_DATAINI
						SRF->RF_PERC13S    := Val(aProgramacaoFerias:RF_PERC13S)
						SRF->RF_DATABAS    := aProgramacaoFerias:RF_DATABAS
						SRF->RF_DATAFIM    := aProgramacaoFerias:RF_DATAFIM
						SRF->RF_PD         := aProgramacaoFerias:RF_PD
						SRF->RF_STATUS     := aProgramacaoFerias:RF_STATUS
						SRF->RF_ABOPEC     := aProgramacaoFerias:RF_ABOPEC
						MsUnlock()
					EndIf

					SRF->(dbSkip())
				End
				cMsg := "Programação de Férias alterada com sucesso"
			Else
				cMsg := "Programação de Férias não foi alterada. Não foi encontrado o registro no Protheus!"
			EndIf
	
	    Case (nOpcao == 5) //Exclusão
	    	SRF->(DbSetOrder(1))
         
	        //Busca exata
	        if SRF->(dbSeek(aProgramacaoFerias:RF_FILIAL + aProgramacaoFerias:RF_MAT + DTOS(aProgramacaoFerias:RF_DATABAS)))     
	        	RecLock("SRF")
	        	SRF->(DbDelete())
	        	SRF->(MsUnlock())
            
	        	cMsg := "Programação de Férias excluida com sucesso"
	        endif
	End Case	    

Return (nRetorno)		 			

//Importacao de produto
User Function CadPRO(aProduto,cMsg)
	Local nRetorno 	:= 0
	Local nOpcao    := 0

	Local aCampos   := {}
	Local cB1_COD   := " "

	Private lMsErroAuto := .F.

	nOpcao := aProduto:OPERACAO 
	
	if (nOpcao == 3) //Se for inclusão
		cAliasQry := GetNextAlias()
		
		cQuery := "  SELECT MAX(SB1.B1_COD) AS CODIGO"
		cQuery += "    FROM " + RetSqlName("SB1") + " SB1 "
		cQuery += "    WHERE SB1.B1_FILIAL = '" + xFilial("SB1") + "'"
		cQuery += "      AND SB1.B1_GRUPO = '" + aProduto:B1_GRUPO + "'"
		cQuery += "      AND SUBSTRING(SB1.B1_COD,1,4) = '" + aProduto:B1_GRUPO + "'"
		cQuery += "      AND LEN(RTRIM(SB1.B1_COD)) = 8 "
		cQuery += "      AND SB1.D_E_L_E_T_ <> '*' "
 		cQuery := ChangeQuery(cQuery)
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)
		dbSelectArea(cAliasQry)
		dbGoTop()
	
		If !(cAliasQry)->(Eof())
			//Código do grupo
			cB1_COD := Soma1(SubStr((cAliasQry)->CODIGO,1,8))
	    
		else
			cB1_COD := PADL(aProduto:B1_GRUPO, 4, "0") + PADL("1", 4, "0") //11   
		endif
	
		(cAliasQry)->(dbCloseArea())
		
	else
		cB1_COD := aProduto:B1_COD 
	endif
	
	aCampos := {{"B1_FILIAL"   ,xFilial("SB1")        ,NIL},;
	            {"B1_TIPO"     ,aProduto:B1_TIPO      ,NIL},;
	            {"B1_GRUPO"    ,aProduto:B1_GRUPO     ,NIL},;
	            {"B1_COD"      ,cB1_COD               ,NIL},;
	            {"B1_DESC"     ,aProduto:B1_DESC      ,NIL},;
	            {"B1_UM"       ,aProduto:B1_UM        ,NIL},;
	            {"B1_SEGUM"    ,aProduto:B1_SEGUM     ,NIL},;
	            {"B1_CONV"     ,Val(aProduto:B1_CONV) ,NIL},;
	            {"B1_TIPCONV"  ,aProduto:B1_TIPCONV   ,NIL},;
	            {"B1_CONTA"    ,aProduto:B1_CONTA     ,NIL},;
	            {"B1_XCONTA2"  ,aProduto:B1_XCONTA2   ,NIL},;
	            {"B1_ALIQISS"  ,Val(aProduto:B1_ALIQISS)   ,NIL},;
	            {"B1_CODISS"   ,aProduto:B1_CODISS    ,NIL},;
	            {"B1_IRRF"     ,aProduto:B1_IRRF      ,NIL},;
	            {"B1_INSS"     ,aProduto:B1_INSS      ,NIL},;
	            {"B1_REDINSS"  ,Val(aProduto:B1_REDINSS)   ,NIL},;
	            {"B1_REDIRRF"  ,Val(aProduto:B1_REDIRRF)   ,NIL},;
	            {"B1_REDPIS"   ,Val(aProduto:B1_REDPIS)    ,NIL},;
	            {"B1_REDCOF"   ,Val(aProduto:B1_REDCOF)    ,NIL},;
	            {"B1_PCSLL"    ,Val(aProduto:B1_PCSLL)     ,NIL},;
	            {"B1_PIS"      ,aProduto:B1_PIS       ,NIL},;
	            {"B1_COFINS"   ,aProduto:B1_COFINS    ,NIL},;
	            {"B1_CSLL"     ,aProduto:B1_CSLL      ,NIL},;
	            {"B1_XIDFLG"   ,aProduto:B1_XIDFLG    ,NIL},;
	            {"B1_LOCPAD"   ,"01"                  ,NIL},;
	            {"B1_XMARCEX"  ,aProduto:B1_XMARCEX   ,NIL},;
	            {"B1_XMARPRE"  ,aProduto:B1_XMARPRE   ,NIL},;
	            {"B1_XRESMAR"  ,aProduto:B1_XRESMAR   ,NIL},;
	            {"B1_ORIGEM"   ,aProduto:B1_ORIGEM    ,NIL},;
	            {"B1_RASTRO"   ,aProduto:B1_RASTRO    ,NIL},;
	            {"B1_XCONTA1"  ,aProduto:B1_XCONTA1   ,NIL}}
	      
	MATA010(aCampos, nOpcao)
		
	Do Case		
		//Em caso de erro
		Case (lMsErroAuto)				
			//Erro ao incluir/excluir produto
			nRetorno := 3 //Erro
			cMsg := MemoRead(NomeAutoLog())
						
			//Apaga historio do execauto
			FErase(NomeAutoLog()) 
					
		//Produto incluido
		Case (!lMsErroAuto .And. nOpcao == 3)		
			nRetorno := 1 //Incluida
			cMsg := "Produto " + Trim(SB1->B1_COD) +" incluido com sucesso"
			
		//Produto alterado
		Case (!lMsErroAuto .And. nOpcao == 4)
				
			nRetorno := 1 //Alterado
			cMsg := "Produto alterado com sucesso"
			
		//Produto excluido
		Case (!lMsErroAuto .And. nOpcao == 5)
			nRetorno := 1 //Excluida
			cMsg := "Produto excluido com sucesso"
						
	EndCase	

Return (nRetorno)

//Importacao de Saldo Fundo Fixo
User Function CadMVB(aMovimentoBancario,cMsg)
	Local nRetorno 	  := 0
	Local nOpcao      := 0
	
	Local aFINA100    := {}
	
	Local cA6_COD     := ""
	Local cA6_AGENCIA := ""
	Local cA6_NUMCON  := ""
	
	Local cCV4_SEQ    := "" 
	
	Local nCont 
	
	Local cFK5_MOV    := ""
	
	Private lMsErroAuto := .F.
	Private F100AUTO    := .T.
	
	cCV4_SEQ := ""
	cMsg     := ""
    nOpcao   := aMovimentoBancario:OPERACAO
    	
	cAliasQry := GetNextAlias()
	cQuery := " SELECT DISTINCT(SA6.A6_COD), "
	cQuery += "        SA6.A6_AGENCIA,       "
	cQuery += "        SA6.A6_NUMCON         "
	cQuery += "   FROM " + RetSqlName("SA6")+" SA6 "
	cQuery += "  WHERE SA6.A6_FILIAL = '" + FWxFilial("SA6", aMovimentoBancario:E5_FILIAL) + "'"
	cQuery += "    AND SA6.A6_XEMPFIL = '"+aMovimentoBancario:E5_FILIAL+"' "
	cQuery += "    AND SA6.D_E_L_E_T_ <> '*' "
	cQuery += "  ORDER BY SA6.A6_COD "

	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)  

	dbSelectArea(cAliasQry)
	dbGoTop()
	
	If !(cAliasQry)->(Eof())
		cA6_COD      := (cAliasQry)->A6_COD
		cA6_AGENCIA  := (cAliasQry)->A6_AGENCIA
		cA6_NUMCON   := (cAliasQry)->A6_NUMCON
	endif
	
	(cAliasQry)->(dbCloseArea())	
	
	aFINA100 := {{"E5_FILIAL"  ,aMovimentoBancario:E5_FILIAL                        ,Nil},;
	             {"E5_DATA"    ,CtoD(aMovimentoBancario:E5_DATA)                    ,Nil},;
	             {"E5_VALOR"   ,Val(aMovimentoBancario:E5_VALOR)                    ,Nil},;
	             {"E5_NATUREZ" ,aMovimentoBancario:E5_NATUREZ                       ,Nil},;
	             {"E5_HISTOR"  ,aMovimentoBancario:E5_HISTOR                        ,Nil},;
	             {"E5_XIDFLG"  ,aMovimentoBancario:E5_XIDFLG                        ,Nil},;
	             {"E5_RATEIO"  ,iif(Len(aMovimentoBancario:RATEIO) > 1, "S", "N")   ,Nil},;
	             {"E5_BANCO"   ,cA6_COD                                             ,Nil},;
	             {"E5_AGENCIA" ,cA6_AGENCIA                                         ,Nil},;
	             {"E5_CONTA"   ,cA6_NUMCON                                          ,Nil},;
	             {"E5_MOEDA"   ,"M1"                                                ,Nil}}
	             
	//MSExecAuto({|x ,y ,z| FINA100(x ,y ,z)} ,0 ,aFINA100 ,3)
	MSExecAuto({|x,y,z,w| FINA100(x,y,z,w) },,aFINA100,3)
	
	Do Case		
		//Em caso de erro
		Case (lMsErroAuto)				
			//Erro ao incluir/excluir produto
			nRetorno := 3 //Erro
			cMsg := MemoRead(NomeAutoLog())
						
			//Apaga historio do execauto
			FErase(NomeAutoLog()) 
					
		//Produto incluido
		Case (!lMsErroAuto .And. nOpcao == 3)		
			nRetorno := 1 //Incluida
			cMsg := "Movimento bancário incluido com sucesso"
			
		//Produto alterado
		Case (!lMsErroAuto .And. nOpcao == 4)
				
			nRetorno := 1 //Alterado
			cMsg := "Movimento bancário alterado com sucesso"
			
		//Produto excluido
		Case (!lMsErroAuto .And. nOpcao == 5)
			nRetorno := 1 //Excluida
			cMsg := "Movimento bancário excluido com sucesso"
						
	EndCase
	
	If nRetorno == 1
		If Len(aMovimentoBancario:RATEIO) > 1
			
			cFK5_MOV := FK5->FK5_IDMOV
			
			//Atualiza FK5
			dbSelectArea("FK5")
	        dbSetOrder(1)      
	        
	        if dbSeek(xFilial("FK5" ,aMovimentoBancario:E5_FILIAL) + AllTrim(cFK5_MOV))
	        	FK5->(RECLOCK("FK5", .F.))
	        	FK5->FK5_ORIGEM := "FINA100"
	        	FK5->(MSUNLOCK()) 
        	endif
        	
        	cCV4_SEQ  := GetSx8Num("CV4", "CV4_SEQUEN")
			ConfirmSx8() 
        	
        	//Atualiza FK8
        	dbSelectArea("FK8")
	        dbSetOrder(1)      
	        
	        if dbSeek(xFilial("FK8" ,aMovimentoBancario:E5_FILIAL) + AllTrim(cFK5_MOV))
	        	FK8->(RECLOCK("FK8", .F.))
	        	FK8->FK8_ARQRAT := SubStr(FK8->FK8_ARQRAT, 01, 19) + AllTrim(cCV4_SEQ)
	        	FK8->(MSUNLOCK()) 
        	endif

			//Atualiza SE5
			dbSelectArea("SE5")
	        dbSetOrder(21)      
	        
	        if dbSeek(xFilial("SE5",aMovimentoBancario:E5_FILIAL)+AllTrim(cFK5_MOV))
	        	While !SE5->(Eof()) .AND.;
	        		SE5->E5_FILIAL           == xFilial("SE5", aMovimentoBancario:E5_FILIAL) .AND.;
				    AllTrim(SE5->E5_IDORIG)  == AllTrim(cFK5_MOV) 
				
					SE5->(RECLOCK("SE5", .F.))
					SE5->E5_ARQRAT  := SubStr(SE5->E5_ARQRAT, 01, 19) + AllTrim(cCV4_SEQ)
					SE5->(MSUNLOCK()) 
					
					SE5->(dbSkip())
				End
				
        	endif
	        
			dDataSeq := CtoD(aMovimentoBancario:E5_DATA)
	
			For nCont := 1 to Len(aMovimentoBancario:RATEIO)
				cDebito   := aMovimentoBancario:RATEIO[nCont]:CV4_DEBITO
				nPercent  := ((Val(aMovimentoBancario:RATEIO[nCont]:CV4_VALOR) / Val(aMovimentoBancario:E5_VALOR)) * 100)
				nValor    := Val(aMovimentoBancario:RATEIO[nCont]:CV4_VALOR)
				cCcd      := aMovimentoBancario:RATEIO[nCont]:CV4_CCD
				cItSeqCV4 := PADL(cValToChar(nCont), 06, "0")
				
				dbSelectArea("GV4")
				dbSetOrder(1)
				
				If !GravaCV4(cCV4_SEQ,dDataSeq,cDebito,/*cCredit*/,nPercent,nValor,/*cHist*/,/*cCcc*/,cCcd,/*cItemD*/,/*cItemC*/,/*cClVlDb*/,/*cClVlCr*/, cItSeqCV4, /*cProcPCO*/, /*cItemPCO*/, /*cProgr*/, {}) //CadRMVB(aMovimentoBancario)
					cMsg := "O Movimento bancário informado já está cadastrado!"
					nRetorno := 3
				Else
					cMsg := "O Movimento bancário informado foi incluído com sucesso!"
				EndIf
			Next
		EndIf
	endif

Return (nRetorno)

/*/{Protheus.doc} ALPCAPRO
Função responsável para abertura de fila de
Processamento
@author Jonatas Oliveira | www.compila.com.br
@since 20/09/2018
@version 1.0
/*/
User Function ALPCAPRO(aAprovacaoPC,cMsg)
Local nRetorno 	 := 0
Local lAprov     := .F.
Local lOK        := .F. 
Local cStatus    := "" 
Local aRetAux

Private aRetAp	 := {.T.,"Processando"} 


cFilAnt := aAprovacaoPC:CR_FILIAL

//Atualiza SCR
dbSelectArea("SCR")
//SCR->(DbSetOrder(1))

SCR->(DbGoTo(aAprovacaoPC:CR_RECNO))

IF ALLTRIM(aAprovacaoPC:CR_STATUS) == "A"//|Aprovação|
	
	aRetAux	:= U_CP12ADD("000021", "SCR", aAprovacaoPC:CR_RECNO, HttpOtherContent() ,	 , "01",  SCR->CR_XIDFLG  )
			
ELSEIF ALLTRIM(aAprovacaoPC:CR_STATUS) == "R"//|Recusa| 
	aRetAux	:= U_CP12ADD("000022", "SCR", aAprovacaoPC:CR_RECNO, HttpOtherContent() ,	 , "01",  SCR->CR_XIDFLG  )
//		U_CP12ADD("000022", "SCR", aAprovacaoPC:CR_RECNO, HttpOtherContent(), )

ENDIF 

/*
IF aRetAux[1]
	nRetorno	:= 1 //| sUCESSO|
ELSE
	nRetorno	:= 0
	cMsg	:= aRetAux[2]
ENDIF 
*/



Return( nRetorno )


//Importacao de Aprovação de Pedido de Compras
/*/{Protheus.doc} CadAPC
Alteração realizada para que a aprovação e recusa
do pedido de compra seja executada vi Fila de Processamento
@author Jonatas Oliveira | www.compila.com.br
@since 20/09/2018
@version 1.0
@param nRecSCR,N, Recno do registro SCR
@param cTpAprov, C, A= Aprovação;B= Recusa
@return aRetAp, A, {lSucesso, cMensagem}
/*/
User Function CadAPC(nRecSCR, cTpAprov)
//	Local nRetorno 	 := 0
	Local lAprov     := .F.
	Local lOK        := .F. 
	Local cStatus    := "" 
    Local aRetAp	 := { .T. ,""}
    Local aProces	 := { .T. ,""}

    DEFAULT cTpAprov := "A"//|A-Aprovar; R=Recusar

    dbSelectArea("SCR")	
	SCR->(DbGoTo(nRecSCR))

    cFilAnt := SCR->CR_FILIAL
	
	//Atualiza SCR

	cStatus := SCR->CR_STATUS
	
	//If SCR->(dbSeek(xFilial("SCR" ,SCR->CR_FILIAL) + "PC" + SCR->CR_NUM)) 
	if !SCR->(Eof()) 
	
		dbSelectArea("SC7")
		SC7->(DbSetOrder(1)) 
		
		If SC7->(dbSeek(xFilial("SC7")  + ALLTRIM(SCR->CR_NUM)) )
			if SC7->C7_CONAPRO == "L"
				lOK := .T.
//				nRetorno := 4	// Pedido estÃ¡ totalmente aprovado
				cMsg := "Pedido esta totalmente aprovado"
				aRetAp	 := { .T. , cMsg}
			endif
		Endif

		if !lOK
			lAprov := .T.
		
			If cTpAprov == "R" .AND.;
		   		AllTrim(cStatus) == "02"
				U_Rejeitar(nRecSCR)
				cMsg := "Pedido de compra " + Trim(SCR->CR_NUM) + " rejeitado com sucesso"
				aRetAp	 := { .T. , cMsg}

//				nRetorno := 5	// Pedido rejeitado
//				cMsg := "Pedido de compra " + Trim(SCR->CR_NUM) + " rejeitado com sucesso"
			elseif cTpAprov == "R" .AND. AllTrim(cStatus) == "01" 
				cMsg := "Pedido bloqueado pelo sistema (aguardando outros nÃ­veis)"
				aRetAp	 := { .F. , cMsg}
			EndIf

			If cTpAprov == "A" .AND.;
		   		AllTrim(cStatus) == "02"
		   
				dbSelectArea("SA2")
				dbSetOrder(1)
				MsSeek(xFilial("SA2")+SC7->C7_FORNECE+SC7->C7_LOJA)
				aAreaSA2	:= GetArea()
		
				dbSelectArea("SAL")       
				dbSetOrder(3)
				MsSeek(xFilial("SAL")+SC7->C7_APROV+SAK->AK_COD)
				aAreaSAL	:= GetArea()  
		
				//Atualiza SC7
				dbSelectArea("SC7")
				SC7->(DbSetOrder(1))
				
				If SC7->(dbSeek(xFilial("SC7")  + ALLTRIM(SCR->CR_NUM)) ) 
					aAreaSC7	:= GetArea()
					
					
					//Posiciona na SCR
					dbSelectArea("SCR")
					SCR->(DbGoTo(nRecSCR))
					aAreaSCR	:= GetArea()
				
					
					/*----------------------------------------
						22/04/2017 - Jonatas Oliveira - Compila
						Valida Saldo do Aprovador
					------------------------------------------*/
					ValiSld(@aRetAp)
					
					RestArea(aAreaSA2)
					RestArea(aAreaSAL)
					RestArea(aAreaSC7)
					RestArea(aAreaSCR)
					
					/*----------------------------------------
						Realiza a aprovação Função padrão
					------------------------------------------*/
					IF aRetAp[1] 
						A097ProcLib(nRecSCR, 2,,,,,dDataBase)
					ELSE
						lAprov := .F.
						cMsg := aRetAp[2] + " " + Trim(SCR->CR_NUM)
//						nRetorno := 3
					ENDIF 	
				Else
					aRetAp	 := { .F. ,"Pedido Não Localizado"}
				Endif
			Endif
		Endif
	Endif
	
	if lAprov
		//nRetorno := 1
		
		if cTpAprov == "A"
			
			dbSelectArea("SCR")
			SCR->(DbGoTo(nRecSCR))
	
			if SCR->CR_STATUS == "01"
				cMsg := "Pedido bloqueado pelo sistema (aguardando outros niveis)"
				aRetAp	 := { .F. , cMsg}
//				nRetorno := 6	// Pedido bloqueado pelo sistema (aguardando outros nÃ­veis)

			elseif !aRetAp[1]
				nRetorno := 6
				aRetAp	 := { .F., "Falha na Aprovacao"}
				
			elseif SCR->CR_STATUS == "02"
				cMsg := "Pedido pendente de aprovacao"
				aRetAp	 := { .F. , cMsg}
//				nRetorno := 9	// Pedido pendente de aprovaÃ§Ã£o

			elseif SCR->CR_STATUS == "03"
				cMsg := "Pedido aprovado com sucesso pelo usuario '"+ALLTRIM(UsrRetName(SCR->CR_USER))+"'!"
				aRetAp	 := { .T. , cMsg}
//				nRetorno := 7	// Pedido aprovado com sucesso pelo usuÃ¡rio

			elseif SCR->CR_STATUS == "05"
				cMsg := "Pedido liberado por outro usuario"
				aRetAp	 := { .T. , cMsg}
//				nRetorno := 8	// Pedido liberado por outro usuÃ¡rio
			endif

		endif
		
	else
		//nRetorno := 3
		
		if lOK 
			cMsg := "Pedido de compra " + Trim(SCR->CR_NUM) + "ja aprovado"
			aRetAp	 := { .T. , cMsg }
//			nRetorno := 7
		elseif !aRetAp[1]
				nRetorno := 6	
		elseif cTpAprov == "A"
			cMsg := "Erro na aprovacao do Pedido de compra " + Trim(SCR->CR_NUM)
			aRetAp	 := { .F. , cMsg }
//			nRetorno := 3
		else
			cMsg := "Erro na rejeicao do Pedido de compra " + Trim(SCR->CR_NUM)
			aRetAp	 := { .F. , cMsg }
//			nRetorno := 3
		endif
	endif
	
	/*----------------------------------------
		03/10/2018 - Jonatas Oliveira - Compila
		Integra com Fluig
	------------------------------------------*/
	IF aRetAp[1]
		//aRetAp	:= U_cpFSSTsk(VAL(SCR->CR_XIDFLG ), GETMV("MV_ECMMAT",.F.,""), 30,aRetAp[2], .T., .F., )
		aRetAux	:= U_CP12ADD("000030", "SCR", SCR->(RECNO()), aRetAp[2] ,	 , "01",  SCR->CR_XIDFLG  )
	ELSE
		//aRetAp	:= U_cpFSSTsk(VAL(SCR->CR_XIDFLG ), GETMV("MV_ECMMAT",.F.,""), 5,aRetAp[2], .T., .F., )
		aRetAux	:= U_CP12ADD("000031", "SCR", SCR->(RECNO()), aRetAp[2] ,	 , "01",  SCR->CR_XIDFLG  )
	ENDIF 


Return(aProces)


/*/{Protheus.doc} CadAPCFA
Movimenta solicitação no Fluig para proxima atividade quando APROVADO
@author Augusto Ribeiro | www.compila.com.br
@since 28/02/2019
@version undefined
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
User Function CadAPCFL(nRecSCR, nProxAtv)
Local aRet	:= { .F. ,""}

Default nProxAtv	:= 0 //\ 30 aprovado, 5 reprovado

dbSelectArea("SCR")	
SCR->(DbGoTo(nRecSCR))


aRet	:= U_cpFSSTsk(VAL(SCR->CR_XIDFLG ), GETMV("MV_ECMMAT",.F.,""), nProxAtv,ALLTRIM(ZD1->ZD1_DADOS), .T., .F., )


Return(aRet)




//Importacao de Benefício
User Function CadBNF(aBeneficio,cMsg)
	Local nRetorno 	:= 0
	Local nOpcao    := 0
	
	nOpcao   := aBeneficio:OPERACAO 
	nRetorno := 1
	cMsg     := ""
	
	Do Case 	
		Case (nOpcao == 3) //Inclusão
        
	        //Validações afastamento
	        nRetorno := U_FncBNFVl(aBeneficio, @cMsg)
	        
	        if (nRetorno == 3)
	        	Return(nRetorno)
	        endif
	        	        	
	        dbSelectArea("SR0")
        	
	        RECLOCK("SR0", .T.)
        	
	        SR0->R0_FILIAL     := aBeneficio:R0_FILIAL
        	SR0->R0_MAT        := aBeneficio:R0_MAT
        	SR0->R0_TPVALE     := aBeneficio:R0_TPVALE 
        	SR0->R0_CODIGO     := aBeneficio:R0_CODIGO
        	SR0->R0_QDIAINF    := aBeneficio:R0_QDIAINF
        	SR0->R0_QDNUTIL    := aBeneficio:R0_QDNUTIL
        	
	        //Destrava o registro
	        MSUNLOCK()     
		
	        cMsg := "Benefício incluido com sucesso"
        	
	    Case (nOpcao = 4) //Edição
	    	
	    	//Validações afastamento
	        nRetorno := U_FncBNFVl(aBeneficio, @cMsg)
	        
	        if (nRetorno == 3)
	        	Return(nRetorno)
	        endif
	        	        	
	    	dbSelectArea("SR0")
	        dbSetOrder(1)      
	        dbSeek(aBeneficio:R0_FILIAL + aBeneficio:R0_MAT + aBeneficio:R0_CODIGO + aBeneficio:R0_TPVALE)     // Busca exata
        	
	        RECLOCK("SR0", .F.)
        	
	        SR0->R0_FILIAL     := aBeneficio:R0_FILIAL
        	SR0->R0_MAT        := aBeneficio:R0_MAT
        	SR0->R0_TPVALE     := aBeneficio:R0_TPVALE 
        	SR0->R0_CODIGO     := aBeneficio:R0_CODIGO
        	SR0->R0_QDIAINF    := aBeneficio:R0_QDIAINF
        	SR0->R0_QDNUTIL    := aBeneficio:R0_QDNUTIL
        	
	        //Destrava o registro
	        MSUNLOCK()     
		
	        cMsg := "Benefício alterado com sucesso"
        	
	    Case (nOpcao == 5) //Exclusão
	    	SR0->(DbSetOrder(1))
         
	        //Busca exata
	        if SR0->(dbSeek(aBeneficio:R0_FILIAL + aBeneficio:R0_MAT + aBeneficio:R0_CODIGO + aBeneficio:R0_TPVALE))     
	        	RecLock("SR0")
	        	SR0->(DbDelete())
	        	SR0->(MsUnlock())
            
	        	cMsg := "Benefício excluído com sucesso"
	        endif
	End Case	

Return (nRetorno)

//Importacao de Admissão
User Function CadADM(aAdmissao,cMsg)
	Local nRetorno 	:= 0
	Local nOpcao    := 0
	Local nCont     := 0
	Local nRA_DEPIR := 0
	Local nRA_DEPSF := 0 
	Local cRA_MAT   := ""
	
	//Alteração para chamar função pelo EXECAUTO
	Local aCampos	  := {}
	Local aDependente := {}
    Local aItens      := {}
    
	Local aRotina := {} //| StaticCall(gpea010 ,MenuDef)  //| FUNCAO NAO UTILIZADA - REMOCAO PARA COMPILA 12.1.33
	Local lInclui := .F.
	Local i := 0
	Local aLog := {}
	
	Private lMsErroAuto := .f.
	Private lAutoErrNoFile := .t.
	
	nOpcao   := aAdmissao:OPERACAO 
	nRetorno := 1
	cMsg     := ""

	lInclui := .F.
	lAltera := .F.

	If (nOpcao == 3)
		lInclui := .t.
		If Empty(aAdmissao:RA_MAT)
			aAdmissao:RA_MAT := U_FncADMSq(aAdmissao)
		EndIf
	Else  
		lAltera := .t.

		If Empty(aAdmissao:RA_FILIAL) .OR. Empty(aAdmissao:RA_MAT)
			cMsg := "Para OPERACAO igual a 4 deverá ser informada a RA_FILIAL e RA_MAT !"
			Return(3)
		EndIf

		dbSelectArea("SRA")
		dbSetOrder(1)
		
		If !(SRA->(DbSeek(FwXFilial('SRA', aAdmissao:RA_FILIAL) + aAdmissao:RA_MAT) ) )
			cMsg := " Não foi encontrada a chave informada para OPERACAO igual a 4 !"
			Return(3)
		EndIf

	EndIf 
        	
	aAdd(aCampos, {"RA_FILIAL"    , aAdmissao:RA_FILIAL   , NIL})
 	aAdd(aCampos, {"RA_MAT"	      , aAdmissao:RA_MAT      , NIL})
 	aAdd(aCampos, {"RA_REGISTR"	  , aAdmissao:RA_MAT      , NIL})
 	aAdd(aCampos, {"RA_NOME"      , aAdmissao:RA_NOME     , NIL})
 	aAdd(aCampos, {"RA_NOMECMP"   , aAdmissao:RA_NOMECMP  , NIL}) 
 	aAdd(aCampos, {"RA_MAE"       , aAdmissao:RA_MAE      , NIL})
 	aAdd(aCampos, {"RA_PAI"       , aAdmissao:RA_PAI      , NIL})
 	aAdd(aCampos, {"RA_SEXO"      , aAdmissao:RA_SEXO     , NIL})
 	aAdd(aCampos, {"RA_RACACOR"   , aAdmissao:RA_RACACOR  , NIL})
 	aAdd(aCampos, {"RA_NASC"      , aAdmissao:RA_NASC     , NIL})
 	aAdd(aCampos, {"RA_ESTCIVI"   , aAdmissao:RA_ESTCIVI  , NIL})
 	aAdd(aCampos, {"RA_CPAISOR"   , aAdmissao:RA_CPAISOR  , NIL})
 	aAdd(aCampos, {"RA_NACIONA"   , aAdmissao:RA_NACIONA  , NIL})
 	aAdd(aCampos, {"RA_NACIONC"   , aAdmissao:RA_NACIONC  , NIL})
 	aAdd(aCampos, {"RA_BRNASEX"   , aAdmissao:RA_BRNASEX  , NIL})
 	aAdd(aCampos, {"RA_NATURAL"   , aAdmissao:RA_NATURAL  , NIL})
 	aAdd(aCampos, {"RA_CODMUNN"   , aAdmissao:RA_CODMUNN  , NIL})
 	aAdd(aCampos, {"RA_MUNNASC"   , aAdmissao:RA_MUNNASC  , NIL})
 	aAdd(aCampos, {"RA_GRINRAI"   , aAdmissao:RA_GRINRAI  , NIL})
 	aAdd(aCampos, {"RA_EMAIL"     , aAdmissao:RA_EMAIL    , NIL})
 	aAdd(aCampos, {"RA_DEFIFIS"   , aAdmissao:RA_DEFIFIS  , NIL})
 	aAdd(aCampos, {"RA_BRPDH"     , aAdmissao:RA_BRPDH    , NIL})
 	aAdd(aCampos, {"RA_TPDEFFI"   , aAdmissao:RA_TPDEFFI  , NIL})
 	aAdd(aCampos, {"RA_PORTDEF"   , aAdmissao:RA_PORTDEF  , NIL})
 	aAdd(aCampos, {"RA_OBSDEFI"   , aAdmissao:RA_OBSDEFI  , NIL})
 	aAdd(aCampos, {"RA_CC"        , aAdmissao:RA_CC       , NIL})
 	aAdd(aCampos, {"RA_ADMISSA"   , aAdmissao:RA_ADMISSA  , NIL})
 	aAdd(aCampos, {"RA_TIPOADM"   , aAdmissao:RA_TIPOADM  , NIL})
 	aAdd(aCampos, {"RA_OPCAO"     , aAdmissao:RA_OPCAO    , NIL})
 	aAdd(aCampos, {"RA_TNOTRAB"   , aAdmissao:RA_TNOTRAB  , NIL})
 	aAdd(aCampos, {"RA_PERFGTS"   , Val(aAdmissao:RA_PERFGTS)  , NIL})
 	aAdd(aCampos, {"RA_BCDEPSA"   , aAdmissao:RA_BCDEPSA  , NIL})
 	aAdd(aCampos, {"RA_TPCTSAL"   , aAdmissao:RA_TPCTSAL  , NIL})
 	aAdd(aCampos, {"RA_CTDEPSA"   , aAdmissao:RA_CTDEPSA  , NIL})
 	aAdd(aCampos, {"RA_HRSMES"    , Val(aAdmissao:RA_HRSMES)   , NIL})
 	aAdd(aCampos, {"RA_HRSEMAN"   , Val(aAdmissao:RA_HRSEMAN)  , NIL})
 	aAdd(aCampos, {"RA_HRSDIA"    , Val(aAdmissao:RA_HRSDIA)   , NIL})
 	aAdd(aCampos, {"RA_CODFUNC"   , aAdmissao:RA_CODFUNC  , NIL})
 	aAdd(aCampos, {"RA_SALARIO"   , Val(aAdmissao:RA_SALARIO)  , NIL})
 	aAdd(aCampos, {"RA_ANTEAUM"   , Val(aAdmissao:RA_ANTEAUM)  , NIL})
 	aAdd(aCampos, {"RA_PGCTSIN"   , aAdmissao:RA_PGCTSIN  , NIL})
 	
 	//Se tiver periculosidade
 	if (AllTrim(aAdmissao:RA_ADCPERI) == "2")
 		aAdd(aCampos, {"RA_ADCPERI"   , aAdmissao:RA_ADCPERI  , NIL})

		If ValType(aAdmissao:RA_PERICUL) <> "U" .AND. Val(aAdmissao:RA_PERICUL) > 0
	 		aAdd(aCampos, {"RA_PERICUL"   , Val(aAdmissao:RA_PERICUL)  , NIL})
	 	EndIf
 	endif
 	
 	aAdd(aCampos, {"RA_TPCONTR"   , aAdmissao:RA_TPCONTR  , NIL})
 	aAdd(aCampos, {"RA_DTFIMCT"   , aAdmissao:RA_DTFIMCT  , NIL})
 	aAdd(aCampos, {"RA_PROCES"    , aAdmissao:RA_PROCES   , NIL})
 	aAdd(aCampos, {"RA_HOPARC"    , aAdmissao:RA_HOPARC   , NIL})
 	aAdd(aCampos, {"RA_SEGUROV"   , aAdmissao:RA_SEGUROV  , NIL})
 	aAdd(aCampos, {"RA_CLAURES"   , aAdmissao:RA_CLAURES  , NIL})
 	aAdd(aCampos, {"RA_PERCADT"   , Val(aAdmissao:RA_PERCADT)  , NIL})
 	aAdd(aCampos, {"RA_SINDICA"   , aAdmissao:RA_SINDICA  , NIL})
 	aAdd(aCampos, {"RA_TIPOPGT"   , aAdmissao:RA_TIPOPGT  , NIL})
 	aAdd(aCampos, {"RA_CATFUNC"   , aAdmissao:RA_CATFUNC  , NIL})
 	aAdd(aCampos, {"RA_VIEMRAI"   , aAdmissao:RA_VIEMRAI  , NIL})
 	aAdd(aCampos, {"RA_CATEG"     , aAdmissao:RA_CATEG    , NIL})
 	aAdd(aCampos, {"RA_CATEFD"    , aAdmissao:RA_CATEFD   , NIL})
 	aAdd(aCampos, {"RA_VCTOEXP"   , aAdmissao:RA_VCTOEXP  , NIL})
 	aAdd(aCampos, {"RA_INSMIN"    , Val(aAdmissao:RA_INSMIN)   , NIL})
 	aAdd(aCampos, {"RA_INSMED"    , Val(aAdmissao:RA_INSMED)   , NIL})
 	aAdd(aCampos, {"RA_DTVTEST"   , aAdmissao:RA_DTVTEST  , NIL})

	If ValType(aAdmissao:RA_ADCINS) <> "U" .AND. !Empty(aAdmissao:RA_ADCINS)
	 	aAdd(aCampos, {"RA_ADCINS"    , aAdmissao:RA_ADCINS   , NIL})
	EndIf
	
 	aAdd(aCampos, {"RA_ASSIST"    , aAdmissao:RA_ASSIST   , NIL})
 	aAdd(aCampos, {"RA_CONFED"    , aAdmissao:RA_CONFED   , NIL})
 	aAdd(aCampos, {"RA_MENSIND"   , aAdmissao:RA_MENSIND  , NIL})
 	aAdd(aCampos, {"RA_FTINSAL"   , Val(aAdmissao:RA_FTINSAL)  , NIL})
 	aAdd(aCampos, {"RA_OCORREN"   , aAdmissao:RA_OCORREN  , NIL})
 	aAdd(aCampos, {"RA_CARGO"     , aAdmissao:RA_CARGO    , NIL})
 	aAdd(aCampos, {"RA_REGRA"     , aAdmissao:RA_REGRA    , NIL})
 	aAdd(aCampos, {"RA_COMPSAB"   , aAdmissao:RA_COMPSAB  , NIL})
 	aAdd(aCampos, {"RA_EAPOSEN"   , aAdmissao:RA_EAPOSEN  , NIL})
 	aAdd(aCampos, {"RA_NJUD14"    , aAdmissao:RA_NJUD14   , NIL})
 	aAdd(aCampos, {"RA_SEQTURN"   , aAdmissao:RA_SEQTURN  , NIL})
 	aAdd(aCampos, {"RA_CIC"       , aAdmissao:RA_CIC      , NIL})
 	aAdd(aCampos, {"RA_PIS"       , aAdmissao:RA_PIS      , NIL})
 	aAdd(aCampos, {"RA_RG"        , aAdmissao:RA_RG       , NIL})
 	aAdd(aCampos, {"RA_DTRGEXP"   , aAdmissao:RA_DTRGEXP  , NIL})
 	aAdd(aCampos, {"RA_RGUF"      , aAdmissao:RA_RGUF     , NIL})
 	aAdd(aCampos, {"RA_RGORG"     , aAdmissao:RA_RGORG    , NIL})
 	aAdd(aCampos, {"RA_RGEXP"     , aAdmissao:RA_RGEXP    , NIL})
 	aAdd(aCampos, {"RA_ORGEMRG"   , aAdmissao:RA_ORGEMRG  , NIL})
 	aAdd(aCampos, {"RA_BHFOL"     , aAdmissao:RA_BHFOL    , NIL})
 	aAdd(aCampos, {"RA_NUMCP"     , aAdmissao:RA_NUMCP    , NIL})
 	aAdd(aCampos, {"RA_SERCP"     , aAdmissao:RA_SERCP    , NIL})
 	aAdd(aCampos, {"RA_ACUMBH"    , aAdmissao:RA_ACUMBH   , NIL})
 	aAdd(aCampos, {"RA_UFCP"      , aAdmissao:RA_UFCP     , NIL})
 	aAdd(aCampos, {"RA_DTCPEXP"   , aAdmissao:RA_DTCPEXP  , NIL})
 	aAdd(aCampos, {"RA_HABILIT"   , aAdmissao:RA_HABILIT  , NIL})
 	aAdd(aCampos, {"RA_CNHORG"    , aAdmissao:RA_CNHORG   , NIL})
 	aAdd(aCampos, {"RA_DTEMCNH"   , aAdmissao:RA_DTEMCNH  , NIL})
 	aAdd(aCampos, {"RA_DTVCCNH"   , aAdmissao:RA_DTVCCNH  , NIL})
 	aAdd(aCampos, {"RA_RESERVI"   , aAdmissao:RA_RESERVI  , NIL})
 	aAdd(aCampos, {"RA_TIPENDE"   , aAdmissao:RA_TIPENDE  , NIL})
 	aAdd(aCampos, {"RA_TITULOE"   , aAdmissao:RA_TITULOE  , NIL})
 	aAdd(aCampos, {"RA_ZONASEC"   , aAdmissao:RA_ZONASEC  , NIL})
 	aAdd(aCampos, {"RA_SECAO"     , aAdmissao:RA_SECAO    , NIL})
 	aAdd(aCampos, {"RA_LOGRTP"    , aAdmissao:RA_LOGRTP   , NIL})
 	aAdd(aCampos, {"RA_LOGRDSC"   , aAdmissao:RA_LOGRDSC  , NIL})
 	aAdd(aCampos, {"RA_LOGRNUM"   , aAdmissao:RA_LOGRNUM  , NIL})
 	aAdd(aCampos, {"RA_ENDEREC"   , aAdmissao:RA_ENDEREC  , NIL})
 	aAdd(aCampos, {"RA_REGCIVI"   , aAdmissao:RA_REGCIVI  , NIL})
 	aAdd(aCampos, {"RA_TPLIVRO"   , aAdmissao:RA_TPLIVRO  , NIL})
 	aAdd(aCampos, {"RA_NUMENDE"   , aAdmissao:RA_NUMENDE  , NIL})
 	aAdd(aCampos, {"RA_COMPLEM"   , aAdmissao:RA_COMPLEM  , NIL})
 	aAdd(aCampos, {"RA_TIPCERT"   , aAdmissao:RA_TIPCERT  , NIL})
 	aAdd(aCampos, {"RA_BAIRRO"    , aAdmissao:RA_BAIRRO   , NIL})
 	aAdd(aCampos, {"RA_EMICERT"   , aAdmissao:RA_EMICERT  , NIL})
 	aAdd(aCampos, {"RA_ESTADO"    , aAdmissao:RA_ESTADO   , NIL})
 	aAdd(aCampos, {"RA_MATCERT"   , aAdmissao:RA_MATCERT  , NIL})
 	aAdd(aCampos, {"RA_CODMUN"    , aAdmissao:RA_CODMUN   , NIL})
 	aAdd(aCampos, {"RA_LIVCERT"   , aAdmissao:RA_LIVCERT  , NIL})
 	aAdd(aCampos, {"RA_FOLCERT"   , aAdmissao:RA_FOLCERT  , NIL})
 	aAdd(aCampos, {"RA_MUNICIP"   , aAdmissao:RA_MUNICIP  , NIL})
 	aAdd(aCampos, {"RA_CARCERT"   , aAdmissao:RA_CARCERT  , NIL})
 	aAdd(aCampos, {"RA_CEP"       , aAdmissao:RA_CEP      , NIL})
 	aAdd(aCampos, {"RA_UFCERT"    , aAdmissao:RA_UFCERT   , NIL})
 	aAdd(aCampos, {"RA_CDMUCER"   , aAdmissao:RA_CDMUCER  , NIL})
 	aAdd(aCampos, {"RA_NUMEPAS"   , aAdmissao:RA_NUMEPAS  , NIL})
 	aAdd(aCampos, {"RA_DDDFONE"   , aAdmissao:RA_DDDFONE  , NIL})
 	aAdd(aCampos, {"RA_EMISPAS"   , aAdmissao:RA_EMISPAS  , NIL})
 	aAdd(aCampos, {"RA_TELEFON"   , aAdmissao:RA_TELEFON  , NIL})
 	aAdd(aCampos, {"RA_UFPAS"     , aAdmissao:RA_UFPAS    , NIL})
 	aAdd(aCampos, {"RA_DEMIPAS"   , aAdmissao:RA_DEMIPAS  , NIL})
 	aAdd(aCampos, {"RA_DDDCELU"   , aAdmissao:RA_DDDCELU  , NIL})
 	aAdd(aCampos, {"RA_NUMCELU"   , aAdmissao:RA_NUMCELU  , NIL})
 	aAdd(aCampos, {"RA_DVALPAS"   , aAdmissao:RA_DVALPAS  , NIL})
 	aAdd(aCampos, {"RA_CODPAIS"   , aAdmissao:RA_CODPAIS  , NIL})
 	aAdd(aCampos, {"RA_CHIDENT"   , aAdmissao:RA_CHIDENT  , NIL})
 	aAdd(aCampos, {"RA_NUMRIC"    , aAdmissao:RA_NUMRIC   , NIL})
 	aAdd(aCampos, {"RA_EMISRIC"   , aAdmissao:RA_EMISRIC  , NIL})
 	aAdd(aCampos, {"RA_UFRIC"     , aAdmissao:RA_UFRIC    , NIL})
 	aAdd(aCampos, {"RA_CDMURIC"   , aAdmissao:RA_CDMURIC  , NIL})
 	aAdd(aCampos, {"RA_DEXPRIC"   , aAdmissao:RA_DEXPRIC  , NIL})
 	aAdd(aCampos, {"RA_CODIGO"    , aAdmissao:RA_CODIGO   , NIL})
 	aAdd(aCampos, {"RA_OCEMIS"    , aAdmissao:RA_OCEMIS   , NIL})
 	aAdd(aCampos, {"RA_OCDTEXP"   , aAdmissao:RA_OCDTEXP  , NIL})
 	aAdd(aCampos, {"RA_OCDTVAL"   , aAdmissao:RA_OCDTVAL  , NIL})
 	aAdd(aCampos, {"RA_CODUNIC"   , aAdmissao:RA_CODUNIC  , NIL})
 	aAdd(aCampos, {"RA_RNE"       , aAdmissao:RA_RNE      , NIL})
 	aAdd(aCampos, {"RA_RNEORG"    , aAdmissao:RA_RNEORG   , NIL})
 	aAdd(aCampos, {"RA_RNEDEXP"   , aAdmissao:RA_RNEDEXP  , NIL})
 	aAdd(aCampos, {"RA_DATCHEG"   , aAdmissao:RA_DATCHEG  , NIL})
 	aAdd(aCampos, {"RA_ANOCHEG"   , aAdmissao:RA_ANOCHEG  , NIL})
 	aAdd(aCampos, {"RA_NUMNATU"   , aAdmissao:RA_NUMNATU  , NIL})
 	aAdd(aCampos, {"RA_DATNATU"   , aAdmissao:RA_DATNATU  , NIL})
 	aAdd(aCampos, {"RA_CASADBR"   , aAdmissao:RA_CASADBR  , NIL})
 	aAdd(aCampos, {"RA_FILHOBR"   , aAdmissao:RA_FILHOBR  , NIL})
 	aAdd(aCampos, {"RA_REGIME"    , aAdmissao:RA_REGIME   , NIL})
 	aAdd(aCampos, {"RA_FWIDM"     , aAdmissao:RA_FWIDM    , NIL})
 	aAdd(aCampos, {"RA_INSMAX"    , Val(aAdmissao:RA_INSMAX)   , NIL})
 	aAdd(aCampos, {"RA_ADTPOSE"   , aAdmissao:RA_ADTPOSE  , NIL})
 	aAdd(aCampos, {"RA_TPJORNA"   , aAdmissao:RA_TPJORNA  , NIL})
 	aAdd(aCampos, {"RA_TPPREVI"   , aAdmissao:RA_TPPREVI  , NIL})
 	aAdd(aCampos, {"RA_VCTEXP2"   , aAdmissao:RA_VCTEXP2  , NIL})

	MSExecAuto({|x,y,w,z| GPEA010(x,y,w,z)},Nil, aRotina, aCampos, nOpcao)										
//conout('ALLIAR MARCOS começo')	
	Do Case		
		//Em caso de erro
		Case (lMsErroAuto)				
//conout('ALLIAR MARCOS erro')
			//Erro ao incluir/excluir produto
			nRetorno := 3 //Erro

			aLog := GetAutoGrLog()
	
			for i := 1 to Len(aLog)
			   cMsg += aLog[i] + Chr(13) + Chr(10) 
			Next i

		//Produto incluido
		Case (!lMsErroAuto .And. nOpcao == 3)
//conout('ALLIAR MARCOS entrou 1')
			//Se tiver dependentes
			if Len(aAdmissao:DEPENDENTES) > 0
//conout('ALLIAR MARCOS entrou 2')
				SRB->(DbSetOrder(1))
				//Busca exata para deletar os dependentes
				If (SRB->(dbSeek(aAdmissao:RA_FILIAL + aAdmissao:RA_MAT)))
					while !SRB->(Eof()) .AND. (SRB->RB_FILIAL+SRB->RB_MAT == aAdmissao:RA_FILIAL + aAdmissao:RA_MAT )      
						SRB->(RecLock("SRB"))
						SRB->(DbDelete())
						SRB->(MsUnlock())
						SRB->(dbSkip())
					End
				EndIf
//conout('ALLIAR MARCOS qtde reg:'+AllTrim(Str(Len(aAdmissao:DEPENDENTES))))
				//Inclui novamente os dependentes
				For nCont := 1 to Len(aAdmissao:DEPENDENTES)
					//Seleciona a tabela
					//dbSelectArea("SRB")
					
					//SRB->(RECLOCK("SRB", .T.))
					//SRB->RB_FILIAL  := aAdmissao:RA_FILIAL
					//SRB->RB_MAT     := aAdmissao:RA_MAT  
					//SRB->RB_COD     := aAdmissao:DEPENDENTES[nCont]:RB_COD
					//SRB->RB_NOME    := aAdmissao:DEPENDENTES[nCont]:RB_NOME
					//SRB->RB_DTNASC  := aAdmissao:DEPENDENTES[nCont]:RB_DTNASC
					//SRB->RB_TPDEP   := aAdmissao:DEPENDENTES[nCont]:RB_TPDEP
					//SRB->RB_SEXO    := aAdmissao:DEPENDENTES[nCont]:RB_SEXO
					//SRB->RB_TIPIR   := aAdmissao:DEPENDENTES[nCont]:RB_TIPIR
					//SRB->RB_GRAUPAR := aAdmissao:DEPENDENTES[nCont]:RB_GRAUPAR
					//SRB->RB_TIPSF   := aAdmissao:DEPENDENTES[nCont]:RB_TIPSF
					//SRB->RB_CIC     := aAdmissao:DEPENDENTES[nCont]:RB_CIC
					//SRB->RB_AUXCRE  := aAdmissao:DEPENDENTES[nCont]:RB_AUXCRE
					//SRB->RB_VLRCRE  := aAdmissao:DEPENDENTES[nCont]:RB_VLRCRE

					//SRB->(MSUNLOCK())	
					
					aDependente := {}
					aItens      := {}
					
					aAdd(aDependente,{"RB_FILIAL" 	,aAdmissao:RA_FILIAL                     ,NIL})
					aAdd(aDependente,{"RB_MAT"      ,aAdmissao:RA_MAT                        ,NIL})
					aAdd(aDependente,{"RB_COD"      ,aAdmissao:DEPENDENTES[nCont]:RB_COD     ,NIL})  
					aAdd(aDependente,{"RB_NOME"     ,aAdmissao:DEPENDENTES[nCont]:RB_NOME    ,NIL})  
					aAdd(aDependente,{"RB_DTNASC"   ,aAdmissao:DEPENDENTES[nCont]:RB_DTNASC  ,NIL})  
					aAdd(aDependente,{"RB_TPDEP"    ,aAdmissao:DEPENDENTES[nCont]:RB_TPDEP   ,NIL})
					aAdd(aDependente,{"RB_SEXO"     ,aAdmissao:DEPENDENTES[nCont]:RB_SEXO    ,NIL})
					aAdd(aDependente,{"RB_TIPIR"    ,aAdmissao:DEPENDENTES[nCont]:RB_TIPIR   ,NIL})
					aAdd(aDependente,{"RB_GRAUPAR"  ,aAdmissao:DEPENDENTES[nCont]:RB_GRAUPAR ,NIL})
					aAdd(aDependente,{"RB_TIPSF"    ,aAdmissao:DEPENDENTES[nCont]:RB_TIPSF   ,NIL})
					aAdd(aDependente,{"RB_CIC"      ,aAdmissao:DEPENDENTES[nCont]:RB_CIC     ,NIL})
					aAdd(aDependente,{"RB_AUXCRE"   ,aAdmissao:DEPENDENTES[nCont]:RB_AUXCRE  ,NIL})
					aAdd(aDependente,{"RB_VLRCRE"   ,Val(aAdmissao:DEPENDENTES[nCont]:RB_VLRCRE)  ,NIL})
                            
					aAdd(aItens,aDependente)
//conout('ALLIAR MARCOS entrou 3')
					GravaSRB(aCampos, aItens)
	
				Next nCont
			endif
			
			//Se tiver benefícios
			if Len(aAdmissao:BENEFICIOS) > 0
				SR0->(DbSetOrder(1))
				//Busca exata para deletar os benefícios

				If (SR0->(dbSeek(aAdmissao:RA_FILIAL + aAdmissao:RA_MAT)))
					while !SR0->(Eof()) .AND. (SR0->R0_FILIAL+SR0->R0_MAT == aAdmissao:RA_FILIAL + aAdmissao:RA_MAT )      
						SR0->(RecLock("SR0"))
						SR0->(DbDelete())
						SR0->(MsUnlock())
						SR0->(dbSkip())
					end
				endif 

				For nCont := 1 to Len(aAdmissao:BENEFICIOS)
					//Seleciona a tabela
					dbSelectArea("SR0")
					SR0->(RECLOCK("SR0", .T.))
					SR0->R0_FILIAL  := aAdmissao:RA_FILIAL
					SR0->R0_MAT     := aAdmissao:RA_MAT
					SR0->R0_TPVALE  := aAdmissao:BENEFICIOS[nCont]:R0_TPVALE
					SR0->R0_CODIGO  := aAdmissao:BENEFICIOS[nCont]:R0_CODIGO
					SR0->R0_MEIO    := aAdmissao:BENEFICIOS[nCont]:R0_MEIO
					SR0->R0_QDIAINF := aAdmissao:BENEFICIOS[nCont]:R0_QDIAINF
					SR0->R0_QDNUTIL := aAdmissao:BENEFICIOS[nCont]:R0_QDNUTIL
					
					SR0->(MSUNLOCK())	
				Next nCont		
			endif
			
			nRetorno := 1 //Incluida
			cMsg := "Admissão incluída com sucesso"
			
		//Produto alterado
		Case (!lMsErroAuto .And. nOpcao == 4)
			//Se tiver dependentes
			if Len(aAdmissao:DEPENDENTES) > 0
				SRB->(DbSetOrder(1))
				//Busca exata para deletar os dependentes
				If (SRB->(dbSeek(aAdmissao:RA_FILIAL + aAdmissao:RA_MAT)))
					while !SRB->(Eof()) .AND. (SRB->RB_FILIAL+SRB->RB_MAT == aAdmissao:RA_FILIAL + aAdmissao:RA_MAT )      
						SRB->(RecLock("SRB"))
						SRB->(DbDelete())
						SRB->(MsUnlock())
						SRB->(dbSkip())
					End
				EndIF 
		     
				//Inclui novamente os dependentes
				For nCont := 1 to Len(aAdmissao:DEPENDENTES)
					//Seleciona a tabela
					//dbSelectArea("SRB")
					
					//SRB->(RECLOCK("SRB", .T.))
					//SRB->RB_FILIAL  := aAdmissao:RA_FILIAL
					//SRB->RB_MAT     := aAdmissao:RA_MAT  
					//SRB->RB_COD     := aAdmissao:DEPENDENTES[nCont]:RB_COD
					//SRB->RB_NOME    := aAdmissao:DEPENDENTES[nCont]:RB_NOME
					//SRB->RB_DTNASC  := aAdmissao:DEPENDENTES[nCont]:RB_DTNASC
					//SRB->RB_TPDEP   := aAdmissao:DEPENDENTES[nCont]:RB_TPDEP
					//SRB->RB_SEXO    := aAdmissao:DEPENDENTES[nCont]:RB_SEXO
					//SRB->RB_TIPIR   := aAdmissao:DEPENDENTES[nCont]:RB_TIPIR
					//SRB->RB_GRAUPAR := aAdmissao:DEPENDENTES[nCont]:RB_GRAUPAR
					//SRB->RB_TIPSF   := aAdmissao:DEPENDENTES[nCont]:RB_TIPSF
					//SRB->RB_CIC     := aAdmissao:DEPENDENTES[nCont]:RB_CIC
					//SRB->RB_AUXCRE  := aAdmissao:DEPENDENTES[nCont]:RB_AUXCRE
					//SRB->RB_VLRCRE  := aAdmissao:DEPENDENTES[nCont]:RB_VLRCRE

					//SRB->(MSUNLOCK())	
					
					aDependente := {}
					aItens      := {}
					
					aAdd(aDependente,{"RB_FILIAL" 	,aAdmissao:RA_FILIAL                     ,NIL})
					aAdd(aDependente,{"RB_MAT"      ,aAdmissao:RA_MAT                        ,NIL})
					aAdd(aDependente,{"RB_COD"      ,aAdmissao:DEPENDENTES[nCont]:RB_COD     ,NIL})  
					aAdd(aDependente,{"RB_NOME"     ,aAdmissao:DEPENDENTES[nCont]:RB_NOME    ,NIL})  
					aAdd(aDependente,{"RB_DTNASC"   ,aAdmissao:DEPENDENTES[nCont]:RB_DTNASC  ,NIL})  
					aAdd(aDependente,{"RB_TPDEP"    ,aAdmissao:DEPENDENTES[nCont]:RB_TPDEP   ,NIL})
					aAdd(aDependente,{"RB_SEXO"     ,aAdmissao:DEPENDENTES[nCont]:RB_SEXO    ,NIL})
					aAdd(aDependente,{"RB_TIPIR"    ,aAdmissao:DEPENDENTES[nCont]:RB_TIPIR   ,NIL})
					aAdd(aDependente,{"RB_GRAUPAR"  ,aAdmissao:DEPENDENTES[nCont]:RB_GRAUPAR ,NIL})
					aAdd(aDependente,{"RB_TIPSF"    ,aAdmissao:DEPENDENTES[nCont]:RB_TIPSF   ,NIL})
					aAdd(aDependente,{"RB_CIC"      ,aAdmissao:DEPENDENTES[nCont]:RB_CIC     ,NIL})
					aAdd(aDependente,{"RB_AUXCRE"   ,aAdmissao:DEPENDENTES[nCont]:RB_AUXCRE  ,NIL})
					aAdd(aDependente,{"RB_VLRCRE"   ,Val(aAdmissao:DEPENDENTES[nCont]:RB_VLRCRE)  ,NIL})
                            
					aAdd(aItens,aDependente)
					
					GravaSRB(aCampos, aItens)
					
				Next nCont
			endif
			
			//Se tiver benefícios
			if Len(aAdmissao:BENEFICIOS) > 0
				SR0->(DbSetOrder(1))
				//Busca exata para deletar os benefícios

				If (SR0->(dbSeek(aAdmissao:RA_FILIAL + aAdmissao:RA_MAT)))
					while !SR0->(Eof()) .AND. (SR0->R0_FILIAL+SR0->R0_MAT == aAdmissao:RA_FILIAL + aAdmissao:RA_MAT )      
						SR0->(RecLock("SR0"))
						SR0->(DbDelete())
						SR0->(MsUnlock())
						SR0->(dbSkip())
					end
				endif 

				For nCont := 1 to Len(aAdmissao:BENEFICIOS)
					//Seleciona a tabela
					dbSelectArea("SR0")
					SR0->(RECLOCK("SR0", .T.))
					SR0->R0_FILIAL  := aAdmissao:RA_FILIAL
					SR0->R0_MAT     := aAdmissao:RA_MAT
					SR0->R0_TPVALE  := aAdmissao:BENEFICIOS[nCont]:R0_TPVALE
					SR0->R0_CODIGO  := aAdmissao:BENEFICIOS[nCont]:R0_CODIGO
					SR0->R0_MEIO    := aAdmissao:BENEFICIOS[nCont]:R0_MEIO
					SR0->R0_QDIAINF := aAdmissao:BENEFICIOS[nCont]:R0_QDIAINF
					SR0->R0_QDNUTIL := aAdmissao:BENEFICIOS[nCont]:R0_QDNUTIL
					
					SR0->(MSUNLOCK())	
				Next nCont		
			endif
				
			nRetorno := 1 //Alterado
			cMsg := "Admissão alterada com sucesso"
			
		//Produto excluido
		Case (!lMsErroAuto .And. nOpcao == 5)
			
			//Deleta dependentes
			SRB->(DbSetOrder(1))

			If (SRB->(dbSeek(aAdmissao:RA_FILIAL + aAdmissao:RA_MAT)))
				while !SRB->(Eof()) .AND. (SRB->RB_FILIAL+SRB->RB_MAT == aAdmissao:RA_FILIAL + aAdmissao:RA_MAT )      
					SRB->(RecLock("SRB"))
					SRB->(DbDelete())
					SRB->(MsUnlock())
					SRB->(dbSkip())
				End
			EndIF
			
			//Deleta benefícios
			SR0->(DbSetOrder(1))

			If (SR0->(dbSeek(aAdmissao:RA_FILIAL + aAdmissao:RA_MAT)))
				while !SR0->(Eof()) .AND. (SR0->R0_FILIAL+SR0->R0_MAT == aAdmissao:RA_FILIAL + aAdmissao:RA_MAT )      
					SR0->(RecLock("SR0"))
					SR0->(DbDelete())
					SR0->(MsUnlock())
					SR0->(dbSkip())
				end
			endif 
			
			nRetorno := 1 //Excluida
			cMsg := "Admissão excluida com sucesso"
						
	EndCase           					        

Return (nRetorno)

//Importacao de Movimentação de Pessoal
User Function CadMVP(aMovPessoal,cMsg)
	Local nRetorno 	:= 0
	Local nOpcao    := 0
	Local cSeq      := ""
	
	Local aCampos	:= {}
	Local aRotina   := {} //| StaticCall(gpea010 ,MenuDef)  //| FUNCAO NAO UTILIZADA - REMOCAO PARA COMPILA 12.1.33
	
	Local i    := 0
	Local aLog := {}
	
	Private lMsErroAuto    := .F.
	Private lAutoErrNoFile := .T.
	
	cFilAnt  := aMovPessoal:RA_FILIAL
	
	cMsg    := ""
    nOpcao  := aMovPessoal:OPERACAO
    lAltera := .T.
    
	Do Case 	
		Case (nOpcao == 3) //Inclusão
        
	        //Validações Movimentação de Pessoal
	        nRetorno := U_FncMVPVl(aMovPessoal ,@cMsg)
	        
	        if (nRetorno == 3)
	        	Return(nRetorno)
	        endif
	        
 			aAdd(aCampos, {"RA_FILIAL"    ,xFilial("SRA" ,aMovPessoal:RA_FILIAL)   ,NIL})
 			aAdd(aCampos, {"RA_MAT"       ,aMovPessoal:RA_MAT                      ,NIL})
			aAdd(aCampos, {"RA_ANTEAUM"   ,Val(aMovPessoal:RA_SALARIO)             ,NIL})
			aAdd(aCampos, {"RA_SALARIO"   ,Val(aMovPessoal:RA_SALARIO)             ,NIL})
			aAdd(aCampos, {"RA_CARGO"     ,aMovPessoal:RA_CARGO                    ,NIL})
			aAdd(aCampos, {"RA_CODFUNC"   ,aMovPessoal:RJ_FUNCAO                   ,NIL})
			aAdd(aCampos, {"RA_TIPOALT"   ,"009"                                   ,NIL})
			aAdd(aCampos, {"RA_DATAALT"   ,DATE()                                  ,NIL})
				
			MSExecAuto({|x,y,w,z| GPEA010(x,y,w,z)},Nil, aRotina, aCampos, 4)		
			
			If lMsErroAuto
				nRetorno := 3 //Erro
				
				aLog := GetAutoGrLog()
	
				for i := 1 to Len(aLog)
					cMsg += aLog[i] + Chr(13) + Chr(10) 
				Next i
			else
				//Atualiza salário da SRA - Não mudar porque a rotina automática não atualiza
				dbSelectArea("SRA")
				dbSetOrder(1)      
	        
				If dbSeek(xFilial("SRA" ,AllTrim(aMovPessoal:RA_FILIAL)) + AllTrim(aMovPessoal:RA_MAT))
					SRA->(RECLOCK("SRA", .F.))
					SRA->RA_SALARIO := Val(aMovPessoal:RA_SALARIO) 
					SRA->(MSUNLOCK()) 
				Endif
				
				//Deleta o registro na SR7 caso já exista
				SR7->(DbSetOrder(1))

				If (SR7->(dbSeek(xFilial("SR7" ,AllTrim(aMovPessoal:RA_FILIAL)) + AllTrim(aMovPessoal:RA_MAT) + DTOS(aMovPessoal:R7_DATA) + AllTrim(aMovPessoal:R7_TIPO))))
					SR7->(RecLock("SR7"))
					SR7->(DbDelete())
					SR7->(MsUnlock())
				Endif 
				
				//Tabela de histórico das alterações salariais
				dbSelectArea("SR7")
				SR7->(RecLock("SR7", .T.))
				
				cSeq := U_FncMVPSq(aMovPessoal)//Sequencia 
				
				SR7->R7_FILIAL  := xFilial("SR7", aMovPessoal:RA_FILIAL)//Filial
				SR7->R7_MAT     := aMovPessoal:RA_MAT//Matricula
				SR7->R7_DATA    := aMovPessoal:R7_DATA//Data
				SR7->R7_SEQ     := cSeq
				SR7->R7_TIPO    := aMovPessoal:R7_TIPO
				SR7->R7_FUNCAO  := aMovPessoal:RJ_FUNCAO
				SR7->R7_DESCFUN := Posicione("SRJ",1,xFilial("SRJ",aMovPessoal:RA_FILIAL)+aMovPessoal:RJ_FUNCAO,"RJ_DESC")
				SR7->R7_TIPOPGT := U_FncMVPTp(aMovPessoal)//Tipo de pagamento
				SR7->R7_CATFUNC := U_FncMVPCf(aMovPessoal)//Categoria do funcional
				SR7->R7_CARGO   := aMovPessoal:RA_CARGO//Cargo
				SR7->R7_DESCCAR := Posicione("SQ3",1,xFilial("SQ3",aMovPessoal:RA_FILIAL)+aMovPessoal:RA_CARGO,"Q3_DESCSUM")
				SR7->R7_USUARIO := "FLUIG"
				
				SR7->(MsUnlock())
				
				//Deleta o registro na SR3 caso já exista
				SR3->(DbSetOrder(1))

				If (SR3->(dbSeek(xFilial("SR3" ,AllTrim(aMovPessoal:RA_FILIAL)) + AllTrim(aMovPessoal:RA_MAT) + DTOS(aMovPessoal:R7_DATA) + AllTrim(aMovPessoal:R7_TIPO) + AllTrim(aMovPessoal:R3_PD))))
					SR3->(RecLock("SR3"))
					SR3->(DbDelete())
					SR3->(MsUnlock())
				Endif 
				
				//Tabela de histórico dos valores salariais
				dbSelectArea("SR3")
				SR3->(RecLock("SR3", .T.))
				
				SR3->R3_FILIAL  := xFilial("SR3", aMovPessoal:RA_FILIAL)
				SR3->R3_MAT     := aMovPessoal:RA_MAT
				SR3->R3_DATA    := aMovPessoal:R7_DATA
				SR3->R3_SEQ     := cSeq
				SR3->R3_TIPO    := aMovPessoal:R7_TIPO
				SR3->R3_PD      := aMovPessoal:R3_PD 
				
				if !Empty(aMovPessoal:R3_PD)
					SR3->R3_DESCPD  := iif((aMovPessoal:R3_PD == "000"), "SALARIO BASE", Posicione("SRV",1,xFilial("SRV",aMovPessoal:RA_FILIAL)+aMovPessoal:R3_PD,"RV_DESC"))
				endif
				 
				SR3->R3_VALOR   := Val(aMovPessoal:RA_SALARIO)
				SR3->R3_ANTEAUM := Val(aMovPessoal:RA_SALARIO)
				
				SR3->(MsUnlock())
				
				nRetorno := 1	
				cMsg     := "Movimentação de pessoal incluida com sucesso"
			Endif
	End Case	

Return (nRetorno)

User Function RegExiste(cTabela, cChave, nIndice)
	dbSelectArea(cTabela)
	dbSetOrder(nIndice) 
	
	if (!dbSeek(cChave))
		(cTabela)->(dbCloseArea())
		Return .F.
    endif
    
    (cTabela)->(dbCloseArea())
    
Return .T.

Static Function GravaSRB(aCab,aItens)
    Local aArea       := GetArea()
    Local oModel,oSubModel
    Local cFil        := ""
    Local cMat        := "" 
    Local nPos        := 0
    Local cCampo      := ""
    Local nI          := 0    
    Local cCod        := ""
    Local lEdicao     := .F.
    Local nJ          := 0        
    Local lRet        := .T.
    Local aErro       := {}
    Local lFieldExist := .T.
    Local lHouveErro  := .F.
    
    nPos := AScan (aCab, {|x|x[1]=='RA_FILIAL'})        
    if(nPos > 0)
        cFil := aCab[nPos,2]            
    endIf
    nPos := AScan (aCab, {|x|x[1]=='RA_MAT'})        
    if(nPos > 0)
        cMat := aCab[nPos,2]            
    endIf
//conout("ALLIAR MARCOS GravaSRB 01")    
    if(SRA->(dbSeek(cFil + cMat)))
//conout("ALLIAR MARCOS GravaSRB 02")
        //| StaticCall(GPEA020,SetRotAuto,.T.)  //| FUNCAO NAO UTILIZADA - REMOCAO PARA COMPILA 12.1.33
        oModel     := FWLoadModel("GPEA020")
        
        oModel:SetOperation(4)
        oModel:Activate()
        oSubModel    := oModel:GetModel("GPEA020_SRB")
        
        for nI:= 1 to Len(aItens)
            nPos := AScan (aItens[nI], {|x|x[1]=='RB_COD'})        
            if(nPos > 0)
                cCod := aItens[nI,nPos,2]
                oSubModel:GoLine(1)
                lEdicao := ((oSubModel:SeekLine({{'RB_COD',cCod}})))
            Else
                cCod := StrZero(oSubModel:GetQtdLine(),2)                 
                lEdicao := .F.                
            endIf    
                
            if(!lEdicao) .And. (oSubModel:GetQtdLine() > 0)
                oSubModel:AddLine()                                                                
            EndIf        
            
            for nJ:= 1 to Len(aItens[nI]) 
                cCampo := aItens[nI,nJ,1]
                xValor := aItens[nI,nJ,2]                
                
                if(!lEdicao) .Or. (lEdicao .And. !(cCampo $"RB_FILIAL|RB_MAT|RB_COD"))
                    lFieldExist:= (oSubModel:GetIdField(cCampo) > 0)
                    
                    if(lFieldExist)
                        if!(oSubModel:SetValue(cCampo,xValor))    
                            aErro := oModel:GetErrorMessage()            
                            aEval(aErro,{|x|AutoGrLog(cFil +'/'+ cMat+'/'+ cCod +' : ' + cValToChar(x))})    
                            lHouveErro := .T.
//conout("ALLIAR MARCOS GravaSRB 03")
                            Exit //Sai do Loop
                        endIf                        
                    endIf
                    
                endIf                
            next nJ   
        next nI

        If (oModel:VldData())
//conout("ALLIAR MARCOS GravaSRB 04")
        	oModel:CommitData()            
            lMsErroAuto := lHouveErro
        Else
//conout("ALLIAR MARCOS GravaSRB 05")
        	aErro := oModel:GetErrorMessage()
            
            if(len(aErro) > 0)                
            	aEval(aErro,{|x|IIF(Empty(x),,AutoGrLog(cFil +'/'+ cMat+'/'+ cCod +' : ' + cValToChar(x)))})                
            endIf
            
            lMsErroAuto := .T.            
        EndIf
            
        oModel:Deactivate()
        oModel:Destroy()
        oModel:= nil    
    endIf                
    
    aSize(aErro,0)
    RestArea(aArea)
Return (nil)

Static Function GravaSR8(aCab,aItens)
    Local oModel    := Nil
    Local oSubMdl   := Nil

	Local nTam      := TamSx3("R8_SEQ")[1]
	
	Local aSeek     := {}
	
	
	Local cFil      := ""
   Local cMat      := "" 
   
   Private aPerAtual := {}
       
    cFil := aCab[AScan (aCab, {|x|x[1]=='RA_FILIAL'}) ,2]            
    cMat := aCab[AScan (aCab, {|x|x[1]=='RA_MAT'})    ,2]            
    
	//Inclusão de nova linha
    If (SRA->(DbSeek(xFilial("SRA", cFil) + cMat))) 
    	fGetPerAtual( @aPerAtual, xFilial("RCH"), SRA->RA_PROCES, If (SRA->RA_CATFUNC $ "P*A", fGetCalcRot("9"),fGetRotOrdinar()) )
    	
     	Do Case
     		Case (aCab[AScan (aCab, {|x|x[1]=='OPERACAO'}) ,2] == 3) .OR.;
     	         (aCab[AScan (aCab, {|x|x[1]=='OPERACAO'}) ,2] == 4)
     	         oModel := FWLoadModel("GPEA240")          
     	         oModel:SetOperation(4)
     		
     	         If oModel:Activate()              
     	         	oSubMdl := oModel:GetModel("GPEA240_SR8")   
     			
     	         	//Inicio - Verifica se é edição
     	         	aAdd(aSeek,{"R8_FILIAL"   ,aItens[1,AScan(aItens[1], {|x|x[1]=='R8_FILIAL'})  ,2]})
     	         	aAdd(aSeek,{"R8_MAT"      ,aItens[1,AScan(aItens[1], {|x|x[1]=='R8_MAT'})     ,2]})
     	         	aAdd(aSeek,{"R8_DATAINI"  ,aItens[1,AScan(aItens[1], {|x|x[1]=='R8_DATAINI'}) ,2]}) 
        		
     	         	oSubMdl:GoLine(1)//Volta ao topo pra pra buscar!!
     	         	//Fim - Verifica se é edição
        
     	         	//Se for inclusão
     	         	If !(oSubMdl:SeekLine(aSeek) .And. !oSubMdl:IsDeleted())
     	         		If oSubMdl:Length() > 1              
     	         			nSeq := oSubMdl:AddLine()
     	         		Else
     	         			If oSubMdl:IsInserted()
     	         				nSeq := 1
     	         			Else
     	         				nSeq := oSubMdl:AddLine()
     	         			EndIf
     	         		EndIf
				                 
     	         		oSubMdl:SetValue("R8_FILIAL"  ,aItens[1,AScan(aItens[1], {|x|x[1]=='R8_FILIAL'})  ,2])
     	         		oSubMdl:SetValue("R8_MAT"     ,aItens[1,AScan(aItens[1], {|x|x[1]=='R8_MAT'})     ,2])
     	         		oSubMdl:SetValue("R8_SEQ"     ,StrZero(nSeq,nTam))
     	         		oSubMdl:SetValue("R8_DATAINI" ,aItens[1,AScan(aItens[1], {|x|x[1]=='R8_DATAINI'}) ,2])
     	         	EndIf

     	         	oSubMdl:SetValue("R8_DATA"    ,aItens[1,AScan(aItens[1], {|x|x[1]=='R8_DATA'})    ,2])
     	         	oSubMdl:SetValue("R8_TIPOAFA" ,aItens[1,AScan(aItens[1], {|x|x[1]=='R8_TIPOAFA'}) ,2])
     			            
     	         	If AScan(aItens[1], {|x|x[1]=='R8_CID'}) > 0 
     	         		oSubMdl:SetValue("R8_CID" ,aItens[1,AScan(aItens[1], {|x|x[1]=='R8_CID'}) ,2])
     	         	EndIf
			
     	         	If AScan(aItens[1], {|x|x[1]=='R8_DATAFIM'}) > 0
     	         		oSubMdl:SetValue("R8_DATAFIM" ,aItens[1,AScan(aItens[1], {|x|x[1]=='R8_DATAFIM'}) ,2])
     	         	EndIf          
            
     	         	If (oModel:VldData())
     	         		oModel:CommitData()            
     	         	Else
     	         		aLog := oModel:GetErrorMessage()
            
     	         		If Len(aLog) > 0                
     	         			aEval(aLog,{|x|IIF(Empty(x),,AutoGrLog(cFil +'/'+ cMat+' : ' + cValToChar(x)))})                
     	         		EndIf
            
     	         		lMsErroAuto := .T.            
     	         	EndIf
            	
     	         	oModel:Deactivate()
     	         	oModel:Destroy()
     	         	oModel := nil
     	         EndIf
     	             
     	    Case (aCab[AScan (aCab, {|x|x[1]=='OPERACAO'}) ,2] == 5) //Exclusão de linha
     	    	oModel := FWLoadModel("GPEA240")          
     	    	oModel:SetOperation(4)
     		
     	    	If oModel:Activate()              
     	    		oSubMdl := oModel:GetModel("GPEA240_SR8")   
     			
     	    		aAdd(aSeek,{"R8_FILIAL"   ,aItens[1,AScan(aItens[1], {|x|x[1]=='R8_FILIAL'})  ,2]})
     	    		aAdd(aSeek,{"R8_MAT"      ,aItens[1,AScan(aItens[1], {|x|x[1]=='R8_MAT'})     ,2]})
     	    		aAdd(aSeek,{"R8_DATAINI"  ,aItens[1,AScan(aItens[1], {|x|x[1]=='R8_DATAINI'}) ,2]}) 
        		
     	    		oSubMdl:GoLine(1)//Volta ao topo pra pra buscar!!
        		
     	    		If (oSubMdl:SeekLine(aSeek) .And. !oSubMdl:IsDeleted())
     	    			oSubMdl:DeleteLine()
     	    		EndIf
        		
     	    		If (oModel:VldData())
     	    			oModel:CommitData()
     	    		Else
     	    			aLog := oModel:GetErrorMessage()				
     	    			aEval(aLog,{|x|ConOut(x)})								
     	    		EndIf			          
     			
     	    		oModel:Deactivate()
     	    		oModel:Destroy()
     	    		oModel := nil
     	    	EndIf    
        EndCase
    EndIf
Return


/*/{Protheus.doc} ValiSld
Valida Saldo do Aprovador
@author Jonatas Oliveira | www.compila.com.br
@since 22/04/2017
@version 1.0
/*/
Static Function ValiSld(aRetAp)

	Local aArea		:= GetArea()
	Local aHeadCpos := {}
	Local aHeadSize := {}
	Local aArrayNF	:= {}
	Local aCampos   := {}
	Local aRetSaldo := {}
	Local aTolerancia := {}

	Local cObs 		:= IIF(!Empty(SCR->CR_OBS),SCR->CR_OBS,SPACE(50))
	Local ca097User := RetCodUsr()
	Local cTipoLim  := ""
	Local CRoeda    := ""
	Local cAprov    := ""
	Local cName     := ""
	Local cSavColor := ""
	Local cGrupo	:= ""
	Local cCodLiber := SCR->CR_APROV
	Local cDocto    := SCR->CR_NUM
	//hfp Local cTipo     := SCR->CR_TIPO   
	Local cFilDoc   := SCR->CR_FILIAL
	Local dRefer 	:= dDataBase
	Local cPCLib	:= ""
	//hfp Local cPCUser	:= ""
															   

	Local lAprov    := .F.
	Local lLiberou	:= .F.
	Local lLibOk    := .F.                                               
	Local lContinua := .T.
	Local lShowBut  := .T.
	Local lOGpaAprv := SuperGetMv("MV_OGPAPRV",.F.,.F.)
	Local lVlr		:= .F.
	Local lQtd		:= .F.

	Local nSavOrd   := IndexOrd()        
	Local nSaldo    := 0
	Local nOpc      := 0
	Local nSalDif	:= 0
	Local nTotal    := 0
	Local nMoeda	:= 1
	Local nX        := 1
	Local nRecnoAS400:= 1
	Local nTolVlr	:= 0
	Local nTolQtd	:= 0

	Local oDlg
	Local oDataRef
	Local oSaldo
	Local oSalDif
	Local oBtn1
	Local oBtn2
	Local oBtn3
	Local oQual     

	Local lA097PCO	:= ExistBlock("A097PCO")
	Local lLanPCO	:= .T.	//-- Podera ser modificada pelo PE A097PCO

	Local lPrjCni := FindFunction("ValidaCNI") .And. ValidaCNI()

	Local lTolerNeg := GetNewPar("MV_TOLENEG",.F.)
	
	//Local aRet	:= {.T.,""}

	dbSelectArea("SAL")
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Inicializa as variaveis utilizadas no Display.               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aRetSaldo := MaSalAlc(cCodLiber,dRefer)
	nSaldo 	  := aRetSaldo[1]
	CRoeda 	  := A097Moeda(aRetSaldo[2])   //20210722 - hfp - Compila  Funcao foi descontinuada, ver functio dela no final desse fonte
	cName  	  := UsrRetName(ca097User)
	nTotal    := xMoeda(SCR->CR_TOTAL,SCR->CR_MOEDA,aRetSaldo[2],SCR->CR_EMISSAO,,SCR->CR_TXMOEDA)

	Do Case
	Case SAK->AK_TIPO == "D"
		cTipoLim :=OemToAnsi("Diario") // "Diario"
	Case  SAK->AK_TIPO == "S"
		cTipoLim := OemToAnsi("Semanal") //"Semanal"
	Case  SAK->AK_TIPO == "M"
		cTipoLim := OemToAnsi("Mensal") //"Mensal"
	Case  SAK->AK_TIPO == "A"
		cTipoLim := OemToAnsi("Anual") //"Anual"
	EndCase

	Do Case

	Case SCR->CR_TIPO == "PC" .Or. SCR->CR_TIPO == "AE"

		dbSelectArea("SC7")
		dbSetOrder(1)
		MsSeek(xFilial("SC7")+Substr(SCR->CR_NUM,1,len(SC7->C7_NUM)))
		cGrupo := SC7->C7_APROV

		dbSelectArea("SA2")
		dbSetOrder(1)
		MsSeek(xFilial("SA2")+SC7->C7_FORNECE+SC7->C7_LOJA)
		
		dbSelectArea("SAL")       
		dbSetOrder(3)
		MsSeek(xFilial("SAL")+SC7->C7_APROV+SAK->AK_COD)    
		
		If Eof()    
		   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		   //³ Posiciona a Tabela SAL pelo Aprovador de Origem caso o Documento tenha sido ³
		   //| transferido por Ausência Temporária ou Transferência superior e o aprovador |
		   //| de destino não fizer parte do Grupo de Aprovação.                           |
		   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
		   If !Empty(SCR->(FieldPos("CR_USERORI")))
			   dbSeek(xFilial("SAL")+SC7->C7_APROV+SCR->CR_APRORI) 
		   EndIf
		EndIf
		
		If lOGpaAprv
			If Eof()
				//Aviso("A097NOAPRV","O aprovador não foi encontrado no grupo de aprovação deste documento, verifique e se necessário inclua novamente o aprovador no grupo de aprovação ",{"Ok"}) 
				//"O aprovador não foi encontrado no grupo de aprovação deste documento, verifique e se necessário inclua novamente o aprovador no grupo de aprovação "
				lContinua := .F.
				aRetAp[1] := .F.
				aRetAp[2] := "O aprovador não foi encontrado no grupo de aprovação deste documento, verifique e se necessário inclua novamente o aprovador no grupo de aprovação "    
			EndIf              
		Endif

	Case SCR->CR_TIPO == "CP"

		dbSelectArea("SC3")
		dbSetOrder(1)
		MsSeek(xFilial("SC3")+Substr(SCR->CR_NUM,1,len(SC3->C3_NUM)))
		cGrupo := SC3->C3_APROV

		dbSelectArea("SA2")
		dbSetOrder(1)
		MsSeek(xFilial("SA2")+SC3->C3_FORNECE+SC3->C3_LOJA)
		
		dbSelectArea("SAL")
		dbSetOrder(3)
		MsSeek(xFilial("SAL")+SC3->C3_APROV+SAK->AK_COD)
		
		If Eof()    
		   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		   //³ Posiciona a Tabela SAL pelo Aprovador de Origem caso o Documento tenha sido ³
		   //| transferido por Ausência Temporária ou Transferência superior e o aprovador |
		   //| de destino não fizer parte do Grupo de Aprovação.                           |
		   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
		   If !Empty(SCR->(FieldPos("CR_USERORI")))
			   dbSeek(xFilial("SAL")+SC3->C3_APROV+SCR->CR_APRORI) 
		   EndIf
		EndIf
			 
		If lOGpaAprv
			If Eof()
				//Aviso("A097NOAPRV","O aprovador não foi encontrado no grupo de aprovação deste documento, verifique e se necessário inclua novamente o aprovador no grupo de aprovação ",{"Ok"}) 
				// "O aprovador não foi encontrado no grupo de aprovação deste documento, verifique e se necessário inclua novamente o aprovador no grupo de aprovação "
				lContinua := .F.
				aRetAp[1] := .F.
				aRetAp[2] := "O aprovador não foi encontrado no grupo de aprovação deste documento, verifique e se necessário inclua novamente o aprovador no grupo de aprovação "	    	    
			EndIf
		EndIf
		
	Case SCR->CR_TIPO == "MD"

		dbSelectArea("CND")
		dbSetOrder(4)
		MsSeek(xFilial("CND")+Substr(SCR->CR_NUM,1,len(CND->CND_NUMMED)))
		cGrupo := CND->CND_APROV

		dbSelectArea("SA2")
		dbSetOrder(1)
		MsSeek(xFilial("SA2")+CND->CND_FORNEC+CND->CND_LJFORN)
		
		dbSelectArea("SAL")                      
		dbSetOrder(3)
		MsSeek(xFilial("SAL")+cGrupo+SAK->AK_COD)
		
		If Eof()    
		   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		   //³ Posiciona a Tabela SAL pelo Aprovador de Origem caso o Documento tenha sido ³
		   //| transferido por Ausência Temporária ou Transferência superior e o aprovador |
		   //| de destino não fizer parte do Grupo de Aprovação.                           |
		   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
		   If !Empty(SCR->(FieldPos("CR_USERORI")))
			   dbSeek(xFilial("SAL")+cGrupo+SCR->CR_APRORI) 
		   EndIf
		EndIf
			 
		If lOGpaAprv
			If Eof()
				//Aviso("A097NOAPRV","O aprovador não foi encontrado no grupo de aprovação deste documento, verifique e se necessário inclua novamente o aprovador no grupo de aprovação ",{"Ok"}) 
				// "O aprovador não foi encontrado no grupo de aprovação deste documento, verifique e se necessário inclua novamente o aprovador no grupo de aprovação "
				lContinua := .F.
				aRetAp[1] := .F.
				aRetAp[2] := "O aprovador não foi encontrado no grupo de aprovação deste documento, verifique e se necessário inclua novamente o aprovador no grupo de aprovação "	    	    
			EndIf
		EndIf
		
	Case SCR->CR_TIPO == "CT"

		dbSelectArea("CN9")
		dbSetOrder(1)
		MsSeek(xFilial("CN9")+Substr(SCR->CR_NUM,1,len(CN9->CN9_NUMERO)))
		cGrupo := CN9->CN9_APROV               
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Obtem o primeiro fornecedor relacionado ao contrato e na liberacao sera 		³
		//³apresentado o primeiro fornecedor incluido no contrato 						³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
		dbSelectArea("CNC")
		dbSetOrder(1)
		MsSeek(xFilial("CNC")+CN9->CN9_NUMERO)

		dbSelectArea("SA2")
		dbSetOrder(1)
		MsSeek(xFilial("SA2")+CNC->CNC_CODIGO+CNC->CNC_LOJA)
		
		dbSelectArea("SAL")                      
		dbSetOrder(3)
		MsSeek(xFilial("SAL")+cGrupo+SAK->AK_COD)
		
		If Eof()    
		   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		   //³ Posiciona a Tabela SAL pelo Aprovador de Origem caso o Documento tenha sido ³
		   //| transferido por Ausência Temporária ou Transferência superior e o aprovador |
		   //| de destino não fizer parte do Grupo de Aprovação.                           |
		   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ   
		   If !Empty(SCR->(FieldPos("CR_USERORI")))
			   dbSeek(xFilial("SAL")+cGrupo+SCR->CR_APRORI) 
		   EndIf
		EndIf
			 
		If lOGpaAprv
			If Eof()
				//Aviso("A097NOAPRV","O aprovador não foi encontrado no grupo de aprovação deste documento, verifique e se necessário inclua novamente o aprovador no grupo de aprovação ",{"Ok"}) 
				// "O aprovador não foi encontrado no grupo de aprovação deste documento, verifique e se necessário inclua novamente o aprovador no grupo de aprovação "
				lContinua := .F.
				aRetAp[1] := .F.
				aRetAp[2] := "O aprovador não foi encontrado no grupo de aprovação deste documento, verifique e se necessário inclua novamente o aprovador no grupo de aprovação "
					    	    
			EndIf
		EndIf 
	EndCase

	If SAL->AL_LIBAPR != "A"
		lAprov := .T.
		cAprov := OemToAnsi("VISTO / LIVRE") // "VISTO / LIVRE"
	EndIf
	nSalDif := nSaldo - IIF(lAprov,0,nTotal)
	If (nSalDif) < 0
		//Help(" ",1,"A097SALDO") //Aviso("Saldo Insuficiente","Saldo na data insuficiente para efetuar a liberacao do pedido. Verifique o saldo disponivel para aprovacao na data e o valor total do pedido.",{"Voltar"},2) 
		//"Saldo Insuficiente"###"Saldo na data insuficiente para efetuar a liberacao do pedido. Verifique o saldo disponivel para aprovacao na data e o valor total do pedido."###"Voltar"
		lContinua := .F.
		aRetAp[1] := .F.
		aRetAp[2] := "Saldo na data insuficiente para efetuar a liberacao do pedido. Verifique o saldo disponivel para aprovacao na data e o valor total do pedido."
	EndIf
	RestArea(aArea)

Return()








//USer Function FncFORSq(aFornecedor) 
/*/{Protheus.doc} ForCdLj
Gera Codigo do Fornecedor
Simplificaçao e unificacao das rotinas FncFORSq, FncFORLj
@author Augusto Ribeiro | www.compila.com.br
@since 12/03/2018
@version undefined
@param param
@return aRet, {cCodFor, cLoja}
@example
(examples)
@see (links_or_references)
/*/
Static Function ForCdLj(nOper, cCnpj, cTipo, cEst)
Local aRet		:= {} 
Local cA2_COD 	:= ""
Local cA2_LOJA	:= ""

if (cTipo == 'J') 

	IF (nOper == 3)  .AND. (Trim(cEst) == "EX")
	   
	   cAliasQry := GetNextAlias()
	   cQuery := " SELECT MAX(CAST(SA2.A2_COD AS NUMERIC)) + 1 INCREMENTO "
	   cQuery += "   FROM " + RetSqlName("SA2")+" SA2 "
	   cQuery += "  WHERE SA2.A2_FILIAL = '" + xFilial("SA2") + "'"
	   cQuery += "    AND SA2.A2_EST = '" + Trim(cEst) + "'"
	   cQuery += "    AND SA2.D_E_L_E_T_ <> '*' "
	
	   cQuery := ChangeQuery(cQuery)
	   dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)  
	
	   dbSelectArea(cAliasQry)
	   dbGoTop()
	
	   If !Eof()	
	   		if Empty((cAliasQry)->INCREMENTO)
	   			cA2_COD := PADL("1", 08, "0")
	   		else
	   			cA2_COD := PADL(cVALTOCHAR((cAliasQry)->INCREMENTO), 08, "0") 
	   		endif
	   else
	   		cA2_COD := PADL("1", 08, "0")
	   endif
	
	   (cAliasQry)->(dbCloseArea())
	   
	   cA2_LOJA := "0001" 
	ELSE
		cA2_COD  := SUBSTR(cCnpj, 1, 8)
		cA2_LOJA := SUBSTR(cCnpj, 9, 4)
	ENDIF
ELSE
	cA2_COD  := SUBSTR(cCnpj, 1, 8)
	cA2_LOJA := SUBSTR(cCnpj, 9, 3)	   
endif

IF !EMPTY(cA2_COD) .AND. !EMPTY(cA2_LOJA)
	aRet	:= {cA2_COD,cA2_LOJA}
ENDIF

Return(aRet)



/*/{Protheus.doc} bcoCadFor
Grava bancos do Fornecedor, sempre mantendo somente um como principal
@author Augusto Ribeiro | www.compila.com.br
@since 12/03/2018
@version undefined
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function bcoCadFor(cCodFor, cLoja, aBancos)
Local aRet	:= {.f., ""} 
Local nBANCO, nAGENCI, nDVAGE, nCONTA, nDVCTA, nTIPO, nOPER, nI, nY, nTotCpo, cNameCpo, nPosAux
Local nLinPrinc	:= 0 
Local lAddBco	:= .f.
Local nTBanco	:= tamSX3("FIL_BANCO")[1]
Local nTAgenci	:= tamSX3("FIL_AGENCI")[1]
Local nTConta	:= tamSX3("FIL_CONTA")[1]
Local nRecFIL	:= 0
Local nRecPri	:= 0
Local cBanco	:= ""
Local cAgenc	:= ""
Local cDVAgenc	:= ""
Local cConta	:= "" 
Local cDVConta	:= ""
Local lPosSA2	:= .F.

IF !EMPTY(aBancos)

	IF SA2->A2_COD == cCodFor .AND. SA2->A2_LOJA == cLoja
		lPosSA2	:= .T.
	else
		DBSELECTAREA("SA2")
		SA2->(DBSETORDER(1)) //| 
		IF SA2->(DBSEEK(xfilial("SA2")+cCodFor+cLoja)) 
			
			lPosSA2	:= .T.
				
		ENDIF
	ENDIF

	IF lPosSA2
		
		nOPER	:= aScan(aBancos[1], { |x| AllTrim(x[1]) == "OPERACAO" })
		nBANCO	:= aScan(aBancos[1], { |x| AllTrim(x[1]) == "FIL_BANCO" })
		nAGENCI	:= aScan(aBancos[1], { |x| AllTrim(x[1]) == "FIL_AGENCI" })	
		nDVAGE	:= aScan(aBancos[1], { |x| AllTrim(x[1]) == "FIL_DVAGE" })	
		nCONTA	:= aScan(aBancos[1], { |x| AllTrim(x[1]) == "FIL_CONTA" })	
		nDVCTA	:= aScan(aBancos[1], { |x| AllTrim(x[1]) == "FIL_DVCTA" })	
		nTIPO	:= aScan(aBancos[1], { |x| AllTrim(x[1]) == "FIL_TIPO" })
		
		IF nBANCO > 0 .AND. nAGENCI > 0 .AND. nCONTA > 0 .AND. nTIPO > 0
			FOR nI := 1 to len(aBancos)
			
				IF aBancos[nI, nTIPO, 2] == "1" .and. aBancos[nI,nOPER,2] <> 5  // 1=Principal,2=Normal
					IF nLinPrinc > 0
						aRet[2]	:= "Somente um banco pode ser definido como Principal [bcoCadFor]"
					ELSE
						nLinPrinc	:= nI
						
						IF nBANCO > 0
							cBanco		:= aBancos[nI,nBANCO,2]
						ENDIF
						IF nAGENCI > 0
							cAgenc		:= aBancos[nI,nAGENCI,2]
						ENDIF
						IF nDVAGE > 0
							cDVAgenc	:= aBancos[nI,nDVAGE,2]
						ENDIF
						IF nCONTA > 0
							cConta		:= aBancos[nI,nCONTA,2]
						ENDIF
						IF nDVCTA > 0
							cDVConta	:= aBancos[nI,nDVCTA,2]
						ENDIF
					ENDIF
				ENDIF
			
			NEXT nI
			
			
			IF EMPTY(aRet[2])
			
			
				BEGIN TRANSACTION
				
				
				/*------------------------------------------------------ Augusto Ribeiro | 12/03/2018 - 3:47:06 PM
					Grava ou Insere novo Registro
				------------------------------------------------------------------------------------------*/
				DBSELECTAREA("FIL")
				FIL->(DBSETORDER(1)) //
				nTotCpo	:= FIL->(FCOUNT()) 
				FOR nY := 1 to len(aBancos)
				
					/*------------------------------------------------------ Augusto Ribeiro | 12/03/2018 - 4:53:17 PM
						Acerta tamanho dos campos para evitar falha na busca
					------------------------------------------------------------------------------------------*/
					aBancos[nY,nBANCO,2]	:= LEFT(alltrim(aBancos[nY,nBANCO,2]),nTBanco)
					aBancos[nY,nAGENCI,2]	:= LEFT(alltrim(aBancos[nY,nAGENCI,2]),nTAgenci)
					aBancos[nY,nCONTA,2]	:= LEFT(alltrim(aBancos[nY,nCONTA,2]),nTConta)
				
					nRecFIL	:= FindFIL(cCodFor, cLoja, aBancos[nY,nBANCO,2], aBancos[nY,nAGENCI,2], aBancos[nY,nCONTA,2])
					IF nRecFIL > 0 
						FIL->(DBGOTO(nRecFIL))
						lNewBco	:= .F.
					ELSE
						lNewBco	:= .T.
					ENDIF 
					
					IF aBancos[nY,nOPER,2] == 5 
						IF !lNewBco
							RecLock("FIL", .f.)
								dbDelete()
							msunlock()
						ELSE
							aRet[2]	:= "Registro nao localizado para exclusao ["+aBancos[nY,nBANCO,2]+"]["+aBancos[nY,nAGENCI,2]+"]["+aBancos[nY,nCONTA,2]+"]"
						ENDIF					
					ELSE
						
						RegToMemory("FIL", lNewBco, .F.)
		
						
						RecLock("FIL", lNewBco)
						
						M->FIL_FILIAL	:= XFILIAL("FIL")
						M->FIL_FORNEC 	:= cCodFor
						M->FIL_LOJA   	:= cLoja
						
						For nI := 1 To nTotCpo
							cNameCpo	:= ALLTRIM(FIL->(FIELDNAME(nI)))
							nPosAux	:= aScan(aBancos[nY], { |x| AllTrim(x[1]) == cNameCpo })  
							IF nPosAux > 0
								FieldPut(nI, aBancos[nY,nPosAux, 2])
							ELSE
								FieldPut(nI, M->&(cNameCpo) )
							ENDIF
						Next nI
						
						FIL->(MsUnLock())	
						
						IF aBancos[nY, nTIPO, 2] == "1"
							nRecPri	:= FIL->(RECNO())
						ENDIF 
					ENDIF
									
				NEXT nY
				
				
				
				
				/*------------------------------------------------------ Augusto Ribeiro | 12/03/2018 - 3:48:54 PM
					Garante que somente existira um principal
				------------------------------------------------------------------------------------------*/
				IF nRecPri > 0
					DBSELECTAREA("FIL")
					FIL->(DBSETORDER(1)) //
	
					DBSELECTAREA("FIL")
					FIL->(DBSETORDER(1)) //| 
					IF FIL->(DBSEEK(xfilial("FIL")+cCodFor+cLoja))					
						WHILE FIL->(!EOF()) .AND. FIL->FIL_FORNEC+FIL->FIL_LOJA == cCodFor+cLoja
						
						
							IF FIL->FIL_TIPO == "1" .AND. nRecPri <> FIL->(RECNO())
								RECLOCK("FIL",.F.)
									FIL->FIL_TIPO   := "2"
								MSUNLOCK()
							ENDIF
						
							FIL->(DBSKIP()) 
						ENDDO						
					ENDIF
	
				ENDIF
				
				
				/*------------------------------------------------------ Augusto Ribeiro | 15/03/2018 - 1:48:34 PM
					Atualiza dados bancarios no cadastro do Fornecedor
				------------------------------------------------------------------------------------------*/
				RecLock("SA2",.F.)
					SA2->A2_BANCO    := cBanco
					SA2->A2_AGENCIA  := cAgenc
					SA2->A2_DVAGE    := cDVAgenc
					SA2->A2_NUMCON   := cConta
					SA2->A2_DVCTA    := cDVConta
				MSUNLOCK()				
				
				END TRANSACTION
	
				aRet[1]	:= .t.
			ENDIF
	
		ELSE 	
			aRet[2]	:= "Parametros invalidos. Banco, Agencia e Conta [bcoCadFor]"
		ENDIF
	ELSE
		aRet[2]	:= "Fornecedor não localizado ["+cCodFor+cLoja+"] [bcoCadFor]"
	ENDIF		
ELSE 	
	aRet[2]	:= "Parametros invalidos [bcoCadFor]"
ENDIF

Return(aRet)


/*/{Protheus.doc} FindFIL
Verifica se banco do fornecedor existe
@author Augusto Ribeiro | www.compila.com.br
@since 12/03/2018
@version undefined
@param param
@return nRet, RECNO da FIL
@example
(examples)
@see (links_or_references)
/*/
Static Function FindFIL(cCodFor, cLoja, cBanco, cAgencia, cConta)
Local nRet		:= 0
Local cQuery	:= ""


cQuery := " SELECT FIL.R_E_C_N_O_ as FIL_RECNO "+CRLF
cQuery += " FROM "+RetSqlName("FIL")+" FIL "+CRLF
cQuery += " WHERE FIL_FILIAL = '' "+CRLF
cQuery += " AND FIL_FORNEC = '"+cCodFor+"' "+CRLF
cQuery += " AND FIL_LOJA = '"+cLoja+"' "+CRLF
cQuery += " AND FIL_BANCO = '"+cBanco+"' "+CRLF
cQuery += " AND FIL_AGENCI = '"+cAgencia+" ' "+CRLF
cQuery += " AND FIL_CONTA = '"+cConta+"' "+CRLF
cQuery += " AND FIL.D_E_L_E_T_ = '' "+CRLF


If Select("TFIL") > 0
	TFIL->(DbCloseArea())
EndIf

DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TFIL",.F., .T.)						

IF TFIL->(!EOF())
	nRet	:= TFIL->FIL_RECNO
ENDIF	

TFIL->(DbCloseArea())


Return(nRet)






/*/{Protheus.doc} CP09CFIL
Busca bancos do fornecedor
@author Jonatas Oliveira | www.compila.com.br
@since 03/03/2018
@version 1.0
/*/
//User Function CP09CFIL()
User Function SA2CFIL()
Local lRet		:= .F.
Local lContinua	:= .F.
Local cQuery	:= ""
Local cTitulo	:= "Bancos"
Local cAliasTab	:= "FIL"
Local aBtnAdd, oModel, cFilFilter

cQuery := "	SELECT FIL_BANCO, FIL_AGENCI, FIL_DVAGE ,FIL_CONTA, FIL_DVCTA, FIL_MOVCTO, FIL.R_E_C_N_O_ AS TAB_RECNO "+CRLF
cQuery += " FROM "+RetSqlName("FIL")+" FIL "+CRLF
cQuery += "	WHERE FIL.D_E_L_E_T_ = '' "+CRLF
cQuery += "		AND FIL_FORNEC = '"+ M->E2_FORNECE +"' "+CRLF
cQuery += "		AND FIL_LOJA = '"+ M->E2_LOJA +"' "+CRLF
cQuery += "		AND ( 	FIL_BANCO LIKE '#CAMPO_BUSCA#%'  "+CRLF
cQuery += "			OR FIL_AGENCI LIKE '#CAMPO_BUSCA#%'  "+CRLF
cQuery += "			OR FIL_CONTA LIKE '#CAMPO_BUSCA#%' ) "+CRLF


lRet	:= U_CPXCPAD(cTitulo, cAliasTab, cQuery, aBtnAdd)


Return(lRet)



/* 
**********************************************************************************
FUNCAO A097Moeda  - hfp 20210722

==> funcao descontinuada pela TOTVS.
    Recuperada de um fonte antigo e adaptado aqui, para nao dar erro.

*********************************************************************************** 
*/
Static Function A097Moeda(nMoeda)
Local cRet := ""
Local cAuxMoeda := AllTrim(Str(nMoeda,2))

cRet :=  GetMv("MV_SIMB"+cAuxMoeda)
If ValType(cRet) <> "C"
	cRet := ""
EndIf

Return cRet
