#INCLUDE "PROTHEUS.CH"
#INCLUDE "MSOBJECT.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "RWMAKE.ch"
#INCLUDE 'TBICONN.CH'

//-------------------------------------------------------------------
/*{Protheus.doc} Classe02
Funcao dummy para Compilacao

@author Guilherme.Santos
@since 28/12/2015
@version P12
*/
//-------------------------------------------------------------------
User Function Classe02()
Return NIL
//-------------------------------------------------------------------
/*{Protheus.doc} uMedicao
Classe responsavel pela Inclusao das Medicoes de Contratos

@author Guilherme.Santos
@since 28/12/2015
@version P12
*/
//-------------------------------------------------------------------
	Class uMedicao From uExecAuto
		Data cContrato									//Numero do Contrato
		Data cRevisao										//Revisao do Contrato
		Data xCritMed				As String
		Method New()										//Inicializa o Objeto
		Method AddCabec(cCampo, xValor, xValid)		//Adiciona dados ao Cabecalho
		Method AddItem(cCampo, xValor, xValid)			//Adiciona dados ao Item
		Method Gravacao(lEncerra, nMeuOper,xIdFluig)						//Gravacao da Medicao


	EndClass
//-------------------------------------------------------------------
/*{Protheus.doc} New
Inicializa o Objeto

@author Guilherme.Santos
@since 21/12/2015
@version P12
*/
//-------------------------------------------------------------------
Method New() Class uMedicao
	_Super:New()

	::aTabelas		:= {"CN9", "CNC", "CNA", "CNB", "CND", "CNE", "CN1", "CNF", "CNS", "CNZ"}
	::cContrato	:= ""
	::cRevisao		:= ""
//	::xIdFluig		:= ""
	::cFileLog		:= "CNTA120.LOG"
Return Self
//-------------------------------------------------------------------
/*{Protheus.doc} AddCabec
Inclusao dos Dados do Cabecalho

@author Guilherme.Santos
@since 28/12/2015
@version P12
*/
//-------------------------------------------------------------------
Method AddCabec(cCampo, xValor, xValid) Class uMedicao
	Local lAdiciona := .T.
//	Private xIdFluig	:= ""
	Default xValid := NIL

	Do Case
	Case cCampo == "CND_CONTRA"
		::cContrato 	:= xValor
	Case cCampo == "CND_REVISA"
		::cRevisao		:= xValor
	Case cCampo == "CND_XIDFLG"
		If CND->(FieldPos("CND_XIDFLG")) == 0
			lAdiciona := .F.
		Else
			xIdFluig := xValor
		EndIf
	EndCase

	If lAdiciona
		//Tratamentos Adicionais
		_Super:AddCabec(cCampo, xValor, xValid)
	EndIf


Return NIL
//-------------------------------------------------------------------
/*{Protheus.doc} AddItem
Inclusao dos Dados dos Itens

@author Guilherme.Santos
@since 28/12/2015
@version P12
*/
//-------------------------------------------------------------------
Method AddItem(cCampo, xValor, xValid) Class uMedicao

	If AllTrim(cCampo) == "CNE_DTENT"
		If xValor < dDatabase
			xValor := dDatabase
		EndIf
	EndIf

	//Tratamentos Adicionais
	_Super:AddItem(cCampo, xValor, xValid)
Return NIL
//-------------------------------------------------------------------
/*{Protheus.doc} Gravacao
Inclusao da Medicao do Contrato

@author Guilherme.Santos
@since 28/12/2015
@version P12
*/
//-------------------------------------------------------------------
Method Gravacao(lEncerra, nMeuOper, xIdFluig) Class uMedicao
	Local lRetorno		:= .T.
	Local cErro := ''
	Local nIndx := 0
	Local aCabec := {}
	Local aItem  := {}
	//Local aCabec, aItens, aLinha, nI
	Private lMsHelpAuto 	:= .T.
	Private lMsErroAuto	:= .F.
	Private cWsMedIdent := "1"




	/*------------------------------------------------------ Augusto Ribeiro | 04/10/2017 - 6:07:05 PM
	Parametro que indica se medição sera finalizada automaticamente.
	------------------------------------------------------------------------------------------*/
	lEncerra	:= Getmv("ES_ENCMED",.F.,.T.)
	
	::xCritMed := ""
	::SetEnv(1, "GCT")

	DbSelectArea("CN9")
	DbSetOrder(1)		//CN9_FILIAL, CN9_NUMERO, CN9_REVISA
	
	If CN9->(DbSeek(xFilial("CN9") + ::cContrato + ::cRevisao)) 

		cErro := ContrFixoCronog(::aCabec, ::aItens)
		
		If !Empty(cErro)
			::cMensagem := cErro
			lRetorno := .F.
		EndIf
		
		/*
		-----------------------------------------------------------------------------------------------------
			Executa rotina automatica para gerar as medicoes
		-----------------------------------------------------------------------------------------------------	
		*/
	If lRetorno
		DBSELECTAREA("CND")
		CND->(DbOrderNickName("FLUIG"))
//			CND->(DBSETORDER(6))//|CND_XIDFLG|

			/*----------------------------------------
				11/01/2018 - Jonatas Oliveira - Compila
				Se já existir a medição exclui para gerar
				nova
			------------------------------------------*/			
			IF CND->(DBSEEK(xIdFluig))
				
				IF !Empty(CND->CND_DTFIM).AND. CND->CND_AUTFRN == '1' 	.AND. CND->CND_SERVIC == '1'
					lRetorno := .F.
					::cMensagem := "Medicao Encerrada"
				ELSE
					lMsErroAuto	:= .F.
					
					cDoc := CND->CND_NUMMED	
					aAdd(aCabec,{"CND_FILIAL"	,CND->CND_FILIAL	,NIL})	
					aAdd(aCabec,{"CND_CONTRA"	,CND->CND_CONTRA	,NIL})	
					aAdd(aCabec,{"CND_REVISA"	,CND->CND_REVISA	,NIL})	
					aAdd(aCabec,{"CND_NUMERO"	,CND->CND_NUMERO	,NIL})	
					aAdd(aCabec,{"CND_NUMMED"	,CND->CND_NUMMED	,NIL})
					
					CNTA120(aCabec, aItem, 5, .F.)
					
					If lMsErroAuto

						lRetorno := .F.
				
						If ::lExibeTela
							MostraErro()
						EndIf
							
						If ::lGravaLog
							::cMensagem := MostraErro(::cPathLog, ::cFileLog)
						EndIf
					EndIf
				ENDIF 
			ENDIF 
			
			IF lRetorno

				lMsErroAuto	:= .F.
				
				CNTA120(::aCabec, ::aItens, nMeuOper, .F.)
				
				If lMsErroAuto
					lRetorno := .F.
			
					If ::lExibeTela
						MostraErro()
					EndIf
						
					If ::lGravaLog
						::cMensagem := MostraErro(::cPathLog, ::cFileLog)
					EndIf
				EndIf
			ENDIF 
				
			If lRetorno .AND. lEncerra
			//IF .T. 
				/*
				-----------------------------------------------------------------------------------------------------
					Executa rotina automatica para encerrar as medicoes
				-----------------------------------------------------------------------------------------------------	
				*/
		//CNTA120(::aCabec, ::aItens, 6, .F.)
		lMsErroAuto	:= .F.
		//lRetAux		:= STARTJOB("U_CL02ENC",GetEnvServer(), .F., {"01",CND->CND_FILIAL,CND->CND_NUMMED})

				/*---------------------------------
					FILA INTEGRADOR PROTHEUS
				----------------------------------*/
				U_CP12ADD("000001", "CND", CND->(RECNO()), , )
			
			EndIf
		
		Else
			::xCritMed := " (Contrato: '" + ::cContrato + "' Revisao: '" + ::cRevisao + "' )"
			lRetorno := .F.
		EndIf
	Else
		::xCritMed := " (Contrato: '" + ::cContrato + "' Revisao: '" + ::cRevisao + "' )"
	
		::cMensagem := "Contrato nao localizado."
		//Console("Contrato nao localizado.")
		lRetorno := .F.
	EndIf

	::SetEnv(2, "GCT")

Return lRetorno

//-------------------------------------------------------------------
/*{Protheus.doc} ContrFixoCronog
Verifica se é contrato fixo com cronograma

@author Oswaldo.Leite
@since 28/12/2015
@version P12
*/
//-------------------------------------------------------------------
Static function ContrFixoCronog(aLstCabec, aLstItens)

	Local cErrMensagem := ''
	Local cCN1alias := GetNextAlias()
	Local cCNFalias := GetNextAlias()
	Local nPerc := 0
	Local nVlrDe := 0
	Local nVlrAte := 0
	Local nIdx1  := 0
	Local nIdx2  := 0
	Local nIdx3  := 0
	Local nIdx4  := 0
	Local nIdx5  := 0
	LOcal nCnt := 0
	LOcal nSomaCNEs := 0
	Local nVlrMenorAte := 0
	Local lForaIntervalo := .T.
	Local cQuery

	BeginSql Alias cCN1alias
		SELECT CN1.* FROM %table:CN1% CN1 WHERE              
		CN1.CN1_FILIAL     = %xFilial:CN1%
		AND CN1.%NotDel%    AND CN1.CN1_CODIGO     = %EXP:( CN9->CN9_TPCTO )%        
	EndSql


	If (cCN1alias)->(!Eof()) .And. AllTrim((cCN1alias)->(CN1_CODIGO)) == AllTrim(CN9->CN9_TPCTO)
		If AllTrim((cCN1alias)->(CN1_MEDEVE)) == "2"  .And. AllTrim((cCN1alias)->(CN1_MEDAUT)) == "1"  .And.  	   AllTrim((cCN1alias)->(CN1_CTRFIX)) == "1"  .ANd. AllTrim((cCN1alias)->(CN1_VLRPRV)) == "1"

			nIdx1 := aScan(ALSTCABEC,{|x| AllTrim(x[1]) == 'CND_SERVIC'})
			nIdx2 := aScan(ALSTCABEC,{|x| AllTrim(x[1]) == 'CND_CONTRA'})
			nIdx3 := aScan(ALSTCABEC,{|x| AllTrim(x[1]) == 'CND_COMPET'})
			nIdx4 := aScan(ALSTCABEC,{|x| AllTrim(x[1]) == 'CND_NUMERO'})
			nIdx5 := aScan(ALSTITENS[1],{|x| AllTrim(x[1]) == 'CNE_VLTOT'})

			If nIdx1 > 0 .And. nIdx2 > 0 .And. nIdx3 > 0 .And. nIdx4 > 0 .And. nIdx5 > 0

	   	/*
		    BeginSql Alias cCNFalias
								
			SELECT CNF.* FROM %table:CNF% CNF WHERE              
			CNF.CNF_FILIAL     = %xFilial:CNF%
			AND CNF.%NotDel%    
			AND CNF.CNF_FILIAL     = %EXP:( Fwxfilial('CNF') )%
			AND CNF.CNF_CONTRA     = %EXP:( aLSTCabec[nIdx2][2] )%
			AND CNF.CNF_NUMPLA     = %EXP:( aLSTCabec[nIdx4][2] )%
			AND CNF.CNF_COMPET     = %EXP:( aLSTCabec[nIdx3][2] )%        
								                
			EndSql
		*/

			/*------------------------------------------------------ Augusto Ribeiro | 23/10/2017 - 11:52:30 AM
				Correção de erro que não considerava revisão vigente do contrato
			------------------------------------------------------------------------------------------*/		
			cQuery := " SELECT CNF.* "+CRLF
			cQuery += " FROM "+RetSqlName("CNF")+" CNF "+CRLF
			cQuery += " INNER JOIN "+RetSqlName("CN9")+" CN9 "+CRLF
			cQuery += "     ON CN9_FILIAL = CNF_FILIAL "+CRLF
			cQuery += "     AND CN9_NUMERO = CNF_CONTRA "+CRLF
			cQuery += "     AND CN9_SITUAC= '05' "+CRLF
			cQuery += "     AND CN9_REVISA = CNF_REVISA "+CRLF
			cQuery += "     AND CN9.D_E_L_E_T_ = '' "+CRLF
			cQuery += " WHERE CNF_FILIAL = '"+Fwxfilial('CNF')+"' "+CRLF
			cQuery += " AND CNF_CONTRA = '"+aLSTCabec[nIdx2][2]+"' "+CRLF
			cQuery += " AND CNF_NUMPLA = '"+aLSTCabec[nIdx4][2]+"' "+CRLF
			cQuery += " AND CNF_COMPET =  '"+aLSTCabec[nIdx3][2]+"' "+CRLF
			cQuery += " AND CNF.D_E_L_E_T_ = '' "+CRLF
			
			DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), cCNFalias,.F., .T.)						
			
								
			If (cCNFalias)->(!Eof()) .And. AllTrim((cCNFalias)->(CNF_CONTRA)) == AllTrim(aLSTCabec[nIdx2][2]) .And. ;
			    AllTrim((cCNFalias)->(CNF_NUMPLA)) == AllTrim(aLSTCabec[nIdx4][2]) .ANd. ; 	
			    AllTrim((cCNFalias)->(CNF_COMPET)) == AllTrim(aLSTCabec[nIdx3][2]) 

		   
			    For nCnt := 1 to Len(ALSTITENS)
			    	nSomaCNEs +=  ALSTITENS[nCnt][nIdx5][2]
		   		Next
		        
		   		If AllTrim(aLSTCABEC[nIdx1][2]) == '1'//Nao
		   			If nSomaCNEs > (cCNFalias)->(CNF_VLPREV)
			   			cErrMensagem := "Valor total da medição (" + AllTrim( Transform(nSomaCNEs,"@E 9999,999,999.99")  ) +") maior que o valor (" + AllTrim(   Transform((cCNFalias)->(CNF_VLPREV),"@E 9999,999,999.99")       ) + ")  do Cronograma " + AllTrim((cCNFalias)->(CNF_NUMERO)) + " !"
		   			ENdIf
				Else		 	
					nPerc := (cCN1alias)->(CN1_LMTMED)
					nVlrDe := (cCNFalias)->(CNF_VLPREV)
					nVlrAte := (cCNFalias)->(CNF_VLPREV) + ((nVlrDe * nPerc)/100 )
					nVlrMenorAte := (cCNFalias)->(CNF_VLPREV) - ((nVlrDe * nPerc)/100 )
					lForaIntervalo := .T.

					//If (nSomaCNEs < nVlrDe) .or. (nSomaCNEs > nVlrAte)
					If (nSomaCNEs >= nVlrDe) .And. (nSomaCNEs <= nVlrAte)
						lForaIntervalo := .F.
					EndIf

					If (nSomaCNEs >= nVlrMenorAte) .And. (nSomaCNEs <= nVlrDe)
						lForaIntervalo := .F.
					EndIf
					
					If lForaIntervalo
						cErrMensagem := ">>> Valor total da medição (" + AllTrim(Transform(nSomaCNEs,"@E 9999,999,999.99")) +") não corresponde a margem de valores ( de " + AllTrim( Transform(nVlrDe,"@E 9999,999,999.99")  )  + " até " + AllTrim( Transform(nVlrAte,"@E 9999,999,999.99")  ) + ") "  
						cErrMensagem += " ou a margem ( de " + AllTrim( Transform(nVlrMenorAte,"@E 9999,999,999.99")  )  + " até " + AllTrim( Transform(nVlrDe,"@E 9999,999,999.99")  ) + ")  "
						cErrMensagem += " deste Cronograma " + AllTrim((cCNFalias)->(CNF_NUMERO)) + " !"
					EndIf
		   		EndIf
		   	Else
		   		cErrMensagem := "Cronograma não localizado no sistema (tabela CNF)!"
	   		EndIf
	   		
	   		(cCNFalias)->(DbCLoseArea())
 	   EndIf
 	   
 	EndIf
	
EndIf
						
(cCN1alias)->(DbCLoseArea())


Return cErrMensagem
/*
=============================================================================
Se CND_SERVIC == 1 Nao


CNE_VLTOT  <=   CNF_VLPREV

caso contrario

"Valor da medição nao corresponde ao valor do Cronograma 99999"


somatoria dos CNE´s

filtrar por :   CNF_NUMPLA   CNF_CONTRA  CNF_FILIAL  CNF_COMPET
=============================================================================

CNF_VLPREV = 1000


SOmatoria das medicoes = 1000 ate 1500



Se CND_SERVIC == 2

vejo o percentual da CN1_LMTMED (50)


filtrar por :   CNF_NUMPLA   CNF_CONTRA  CNF_FILIAL  CNF_COMPET
=============================================================================
*/

static function faztru(ablo)
	Local nRet := 1
return .F.

User function ALVFWSM()
	Local cRet := "1"

//If Type("cWsMedIdent") == "U" //IsInCallStack("FVeDatIr")
	cRet := '2'//cWsMedIdent
//else
	Alert ('aaa: ' + cRet)
//EndIf

return cRet




/*/{Protheus.doc} CL02ENC
Encerra medição automaticamente
@author Augusto Ribeiro | www.compila.com.br
@since 10/10/2017
@version undefined
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
USER FUNCTION CL02ENC(nRecCND, nSleep)
	LOCAL aRet	:= {.f.,""}

	Local _cEmp
	Local _cFilial, nI, cMsgErro
	Local _cCodEmp, _cCodFil, _cFilNew

	Default nSleep	:= 10


	IF !EMPTY(nRecCND)
		DBSELECTAREA("CND")
		CND->(DBGOTO(nRecCND))
		IF CND->(!Deleted())

			//SLEEP(nSleep) //| 10 segundos |

		/*---------------------------------------
		Realiza a TROCA DA FILIAL CORRENTE SPO
		-----------------------------------------*/
		_cCodEmp 	:= SM0->M0_CODIGO
		_cCodFil	:= SM0->M0_CODFIL
		_cFilNew	:= CND->CND_FILIAL //| CODIGO DA FILIAL DE DESTINO 
		
		IF _cCodEmp+_cCodFil <> _cCodEmp+_cFilNew
			CFILANT := _cFilNew
			opensm0(_cCodEmp+CFILANT)
		ENDIF
		
		
		aCabec	:={}
		DBSELECTAREA("CND")
		FOR nI := 1 to CND->(FCOUNT())
			aadd(aCabec, {FIELDNAME(nI), FIELDGET(nI), nil})
		NEXT
	
		DBSELECTAREA("CNE")
		CNE->(DBSETORDER(4)) //| 
		IF CNE->(DBSEEK(CND->CND_FILIAL+CND->CND_NUMMED)) 	
			aItens	:={}
			WHILE CNE->(!EOF()) .and. CND->CND_FILIAL == CNE->CNE_FILIAL .AND. CND->CND_NUMMED == CNE->CNE_NUMMED
				aLinha	:= {}
				FOR nI := 1 to CNE->(FCOUNT())
					aadd(aLinha, {FIELDNAME(nI), FIELDGET(nI), nil})
				NEXT
				
				
				aadd(aItens, aLinha)
				
				CNE->(DBSKIP())  
			ENDDO
			  	
		
		ENDIF
		
		lMsErroAuto	:= .F.
		
		MSExecAuto({|x,y,z,k|CNTA120(x,y,z,k)},aCabec,aItens,6,.f.)
//		CNTA120(aCabec,aItens,6, .F.)
	
		IF lMsErroAuto 
			
			cAutoLog	:= alltrim(NOMEAUTOLOG())
	
			cMemo := STRTRAN(MemoRead(cAutoLog),'"',"")
			cMemo := STRTRAN(cMemo,"'","")
	
			//| Apaga arquivo de Log
			Ferase(cAutoLog)
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Le Log da Execauto e retorna mensagem amigavel ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			//|*******COMPILAXFUN.PRW*******|
			cMsgErro := U_CPXERRO(cMemo)
			IF EMPTY(cMsgErro)
				cMsgErro	:= alltrim(cMemo)
			ENDIF			
			
			aRet[2]	:= alltrim(cMsgErro)
			
			/*----------------------------------------
				01/02/2018 - Jonatas Oliveira - Compila
				Insere Fila integrador FALHA - ENCERRA SOLICITACAO FLUIG 
			------------------------------------------*/
			U_CP12ADD("000005", "CND", nRecCND, aRet[2], )
			//ENDIF		
		ELSE
		
			//ABAX 
			cxTMP:= CND->CND_PEDIDO
			FABAX03(  cxTMP )

			IF !EMPTY(CND->CND_DTFIM)		
				aRet[1]	:= .T.
			ELSE
				aRet[2]	:= "Não foi possivel encerrar a medição. Necessario encerramento manual através do Protheus."
				
				/*----------------------------------------
					01/02/2018 - Jonatas Oliveira - Compila
					Insere Fila integrador FALHA - ENCERRA SOLICITACAO FLUIG 
				------------------------------------------*/
				U_CP12ADD("000005", "CND", nRecCND, aRet[2], )				
			ENDIF
		ENDIF   
			
		
		/*---------------------------------------
		Restaura FILIAL  
		-----------------------------------------*/
		IF _cCodEmp+_cCodFil <> _cCodEmp+_cFilNew
			CFILANT := _cCodFil
			opensm0(_cCodEmp+CFILANT)			 			
		ENDIF  	
	ELSE
		aRet[2]	:= "O Registro esta excluido."
	ENDIF
ENDIF
	
Return(aRet)



/*/{Protheus.doc} CL02FLU
Integracao com Fluig - Medicao
@author Augusto Ribeiro | www.compila.com.br
@since 10/10/2017
@version undefined
@param nRecCND, RECNO CND
@param cOpc, cOpc = "ASSUME", "ENCERRA"
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
USER FUNCTION CL02FLU(nRecCND, cOpc)
Local aRet			:= {.F.,""}
Local aRetAux
Local cCompFluig	:= ""

IF !EMPTY(nRecCND)
	DBSELECTAREA("CND")
	CND->(DBGOTO(nRecCND))
	IF cOpc == "ASSUME"
		aRet	:= U_cpFTakeP(VAL(CND->CND_XIDFLG),GETMV("MV_ECMMAT",.F.,""))
	ELSEIF cOpc == "ENCERRA"
		cCompFluig	:= "Medicao Encerrada Automaticamente. "
		IF !EMPTY(CND->CND_PEDIDO)
			cCompFluig += " PEDIDO: "+ALLTRIM(CND->CND_PEDIDO)
		ELSEIF !EMPTY(CND->CND_NUMTIT)
			cCompFluig += " TITULO: "+ALLTRIM(CND->CND_NUMTIT)
		ENDIF 
				
		aRet	:= U_cpFSSTsk(VAL(CND->CND_XIDFLG), GETMV("MV_ECMMAT",.F.,""), 19,cCompFluig, .T., .F., )				
				
	ENDIF
ENDIF

Return(aRet)

/*/{Protheus.doc} CL02FLUF
Integracao com Fluig - Medicao
@author Augusto Ribeiro | www.compila.com.br
@since 10/10/2017
@version undefined
@param nRecCND, RECNO CND
@param cOpc, cOpc = "ASSUME", "ENCERRA"
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
USER FUNCTION CL02FLUF(nRecCND, cOpc)
Local aRet			:= {.F.,""}
Local aRetAux
Local cCompFluig	:= ""

IF !EMPTY(nRecCND)
	DBSELECTAREA("CND")
	CND->(DBGOTO(nRecCND))
	IF cOpc == "ASSUME"
		cCompFluig	:= "Falha Encerramento de Medicao. "
		IF ZD1->ZD1_RECALI == nRecCND .AND. !EMPTY(ZD1->ZD1_DADOS)
			cCompFluig	+=  CRLF+ZD1->ZD1_DADOS
		ENDIF
		
		/*----------------------------------------
			01/02/2018 - Jonatas Oliveira - Compila
			Assume a medição
		------------------------------------------*/
		aRet	:= U_cpFTakeP(VAL(CND->CND_XIDFLG), GETMV("MV_ECMMAT",.F.,""))
		
		/*----------------------------------------
			01/02/2018 - Jonatas Oliveira - Compila
			Movimenta a medição
		------------------------------------------*/
		IF aRet[1]
			aRet	:= U_cpFSSTsk(VAL(CND->CND_XIDFLG), GETMV("MV_ECMMAT",.F.,""), 21,cCompFluig, .T., .F., )	
		ENDIF 
	ENDIF
ENDIF

Return(aRet)




/*/{Protheus.doc} nomeFunction
	(long_description)   ABAX
	@type  Function
	@author user
	@since 25/06/2021
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/

Static Function FABAX03(cXPedido)
	Local aAreSC7:= SC7->( GetArea() )

	Local cAlias	  //abax
	Local cItem
	Local cZeros
	
	Default cXPedido:= CND->CND_PEDIDO

	SC7->( DbSetOrder(1) )	//C7_FILIAL, C7_NUM, C7_ITEM

	If SC7->(DbSeek(xFilial("SC7") + cXPedido))

		While !SC7->(Eof()) .AND. xFilial("SC7") + cXPedido == SC7->C7_FILIAL + SC7->C7_NUM

			// ABAX
			cAlias	:=	GetNextAlias()
			//ajusta tamanho do item  aqui na Alliar o SC7 esta com 4 e CNE com 3
			cZeros:=Repl('0',10)
			cItem		:=  Right( cZeros+SC7->C7_ITEM, TamSx3('CNE_ITEM')[1] )

			BeginSql Alias cAlias
				%NoParser%

				SELECT * 
				FROM %table:CNE010% CNE 
				WHERE CNE.%NotDel%  AND CNE_FILIAL = %xFilial:CNE%  
					AND CNE_PEDIDO = %exp:cXPedido%  AND  CNE_ITEM = %exp:cItem% 
		 
			EndSql    //GetLastQuery()[2]

			IF (cAlias)->(!Eof())

				SC7->(RECLOCK("SC7", .F.))
				SC7->C7_XBUDGET	:= (cAlias)->CNE_XBUDGE  //abax
				SC7->C7_XMOTBUD	:= (cAlias)->CNE_XMOTBU  //abax
				SC7->(MSUNLOCK())

			ENDIF

			(cAlias)->(dbCloseArea())


			SC7->(DbSkip())
		EndDO

	EndIf

	//Reposiciona na SC7
	RestArea(aAreSC7)



RETURN

	/*
	aRetAux	:= U_cpFTakeP(VAL(CND->CND_XIDFLG),GETMV("MV_ECMMAT",.F.,""))
	IF aRetAux[1]
		cCompFluig	:= "Medicao Encerrada Automaticamente. "
		IF !EMPTY(CND->CND_PEDIDO)
			cCompFluig += " PEDIDO: "+ALLTRIM(CND->CND_PEDIDO)
		ELSEIF !EMPTY(CND->CND_NUMTIT)
			cCompFluig += " TITULO: "+ALLTRIM(CND->CND_NUMTIT)
		ENDIF 
		
		aRetAux	:= U_cpFSSTsk(VAL(CND->CND_XIDFLG), GETMV("MV_ECMMAT",.F.,""), 19,cCompFluig, .T., .F., )
		IF !(aRetAux[1])
			CONOUT("CN120ENMED","Erro: "+aRetAux[2])
		ENDIF
	ELSE 
		CONOUT("CN120ENMED","Erro: "+aRetAux[2])
	ENDIF
	*/
