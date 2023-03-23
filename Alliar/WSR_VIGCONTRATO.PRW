#Include 'Protheus.ch'
#Include 'FWMVCDEF.ch'
#Include 'RestFul.CH'

//User Function WSR_VIGCONTRATO()
//Return

WSRESTFUL VIG_CONTRATO DESCRIPTION "Serviço REST para Consulta Vigencia de Contrato - GCT"

WSDATA VLDTYPE AS STRING  
WSDATA XPAR1 AS STRING 
WSDATA XPAR2 AS STRING
WSDATA XPAR3 AS STRING  
WSDATA XPAR4 AS STRING  
WSDATA XPAR5 AS STRING    
WSDATA XPAR6 AS STRING

WSMETHOD POST DESCRIPTION "Retorna vigencia" WSSYNTAX "VIGENCIA GET" PATH "/vig_contrato"

END WSRESTFUL

WSMETHOD POST WSSERVICE VIG_CONTRATO
Local cJson    := ""
Local nAction  := -1
Local cQuery	:= ""
Local nCodeRet	:= 400
Local cMsg	   := "Erro Indeterminado [VIG_CONTRATO]"

CONOUT("WSR_VIGCONTRATO","GENESIS")

::SetContentType("application/json")

#DEFINE ACTION_SUCESSO 0
#DEFINE ACTION_ALERTA 1
#DEFINE ACTION_NEGA	-1

/*------------------------------------------------------ Augusto Ribeiro | 18/01/2018 - 9:36:31 PM
	Bloco de Autorização 
------------------------------------------------------------------------------------------*/
cAutBasic	:= self:GetHeader("Authorization") //| BASIC YWRtaW46|

IF U_CPxAuWSR(cAutBasic)

	cBody 		:= ::GetContent()
	CONOUT("WSR_VIGCONTRATO",cBody)
	/*------------------------------------------------------ Augusto Ribeiro | 23/02/2018 - 1:25:21 PM
		Rotina para inclusão da Medição
	------------------------------------------------------------------------------------------*/
	aRetAux		:= U_WSRVIGEN(cBody)
	nCodeRet	:= aRetAux[1]
	cMsg		:= aRetAux[2]

ELSE
	nCodeRet	:= 401
	cMsg		:= "Authentication Required"	
ENDIF		

cJson	:= "{"
cJson	+= U_cpxToJson("errorCode", nCodeRet)+","
cJson	+= U_cpxToJson("errorMessage", cMsg)
cJson	+= "}"

::SetResponse(cJson)

Return(.T.)

/*/{Protheus.doc} WSRVIGEN
Verifica vigencia do contrato com base no JSON passado.
@author Augusto Ribeiro
@since 23/02/2018
@version undefined
@return return, return_description
@param cBody, Json - Body
@example
(examples)
@see (links_or_references)
/*/
User Function WSRVIGEN(cBody)
Local aRet	:= {400, "Erro Indeterminado [WSRVIGEN]"}
Local aCabec	:= {}
Local aItens	:= {}
Local aItem		:= {}
Local oJson, nI
Local cMsgErro	:= ""
Local aCpoCabec		:= {}
Local nCodeRet
Local cNumMed	:= ""
Local cParMed	:= ""

Local cEmpMed, cFilMed, nOper

IF !EMPTY(cBody)
	IF FWJsonDeserialize(cBody,@oJson)
	
		/*--------------------------
			INFORMACOES BASICAS
		---------------------------*/
		IF AttIsMemberOf(oJson , "EMP")
			cEmpMed	:= alltrim(oJson:EMP)
		ELSE
			cMsgErro += "Propriedade [EMP] de preenchimento obridatorio"+CRLF
		ENDIF
		IF AttIsMemberOf(oJson , "FILIAL")
			cFilMed	:= alltrim(oJson:FILIAL)
		ELSE
			cMsgErro += "Propriedade [FILIAL] de preenchimento obridatorio"+CRLF
		ENDIF
		IF AttIsMemberOf(oJson , "OPERACAO")
			nOper	:= oJson:OPERACAO
		ELSE
			cMsgErro += "Propriedade [OPERACAO] de preenchimento obridatorio"+CRLF
		ENDIF		
		
		/*-------------------------
			CABECALHO
		---------------------------*/
		IF AttIsMemberOf(oJson , "CABEC")
			
			IF AttIsMemberOf(oJson:CABEC , "CND_CONTRA")
				AADD(aCabec, {"CND_CONTRA",PADR(alltrim(oJson:CABEC:CND_CONTRA),TAMSX3("CND_CONTRA")[1]),NIL})
			ENDIF
			IF AttIsMemberOf(oJson:CABEC , "CND_REVISA")
				//AADD(aCabec, {"CND_REVISA",alltrim(oJson:CABEC:CND_REVISA),NIL})
				AADD(aCabec, {"CND_REVISA",PADR(alltrim(oJson:CABEC:CND_REVISA),TAMSX3("CND_REVISA")[1]),NIL})
				
			ENDIF
			IF AttIsMemberOf(oJson:CABEC , "CND_FORNEC")
				AADD(aCabec, {"CND_FORNEC",alltrim(oJson:CABEC:CND_FORNEC),NIL})
			ENDIF
			IF AttIsMemberOf(oJson:CABEC , "CND_LJFORN")
				AADD(aCabec, {"CND_LJFORN",alltrim(oJson:CABEC:CND_LJFORN),NIL})
			ENDIF			
			IF AttIsMemberOf(oJson:CABEC , "CND_COMPET")
				AADD(aCabec, {"CND_COMPET",alltrim(oJson:CABEC:CND_COMPET),NIL})
			ENDIF
			IF AttIsMemberOf(oJson:CABEC , "CND_NUMERO")
				AADD(aCabec, {"CND_NUMERO",alltrim(oJson:CABEC:CND_NUMERO),NIL})
			ENDIF
			IF AttIsMemberOf(oJson:CABEC , "CND_SERVIC")
				AADD(aCabec, {"CND_SERVIC",alltrim(oJson:CABEC:CND_SERVIC),NIL})
			ENDIF
			
			IF AttIsMemberOf(oJson:CABEC , "CND_PARCEL")
				
				IF EMPTY(STRTRAN(alltrim(oJson:CABEC:CND_PARCEL),"-",""))
					cParMed := VldParc(cFilMed , PADR(alltrim(oJson:CABEC:CND_CONTRA),TAMSX3("CND_CONTRA")[1]) , alltrim(oJson:CABEC:CND_COMPET) , PADR(alltrim(oJson:CABEC:CND_REVISA),TAMSX3("CND_REVISA")[1]))
					
					AADD(aCabec, {"CND_PARCEL", cParMed ,NIL})					 
				ELSE
					AADD(aCabec, {"CND_PARCEL",alltrim(oJson:CABEC:CND_PARCEL),NIL})
				ENDIF 	
			ENDIF
			IF AttIsMemberOf(oJson:CABEC , "CND_DTVENC")
				AADD(aCabec, {"CND_DTVENC", ctod(alltrim(oJson:CABEC:CND_DTVENC)) ,NIL})
			ENDIF
			IF AttIsMemberOf(oJson:CABEC , "CND_XIDFLG")
				AADD(aCabec, {"CND_XIDFLG",alltrim(oJson:CABEC:CND_XIDFLG),NIL})
			ENDIF
	
			/*--------------------------
				ITENS
			---------------------------*/			
			IF AttIsMemberOf(oJson , "ITENS")
				aItem	:= {}
				FOR nI := 1 TO len(oJson:ITENS)
					aItem	:= {}
					
					IF AttIsMemberOf(oJson:ITENS[nI] , "CNE_ITEM")
						AADD(aItem, {"CNE_ITEM",alltrim(oJson:ITENS[nI]:CNE_ITEM),NIL})
					ENDIF
					IF AttIsMemberOf(oJson:ITENS[nI] , "CNE_PRODUT")
						AADD(aItem, {"CNE_PRODUT",alltrim(oJson:ITENS[nI]:CNE_PRODUT),NIL})
					ENDIF	
					IF AttIsMemberOf(oJson:ITENS[nI] , "CNE_QUANT")
						AADD(aItem, {"CNE_QUANT",oJson:ITENS[nI]:CNE_QUANT,NIL})
					ENDIF	
					IF AttIsMemberOf(oJson:ITENS[nI] , "CNE_VLUNIT")
						AADD(aItem, {"CNE_VLUNIT",oJson:ITENS[nI]:CNE_VLUNIT,NIL})
					ENDIF	
			
					IF AttIsMemberOf(oJson:ITENS[nI] , "CNE_DTENT")
						AADD(aItem, {"CNE_DTENT",ctod(alltrim(oJson:ITENS[nI]:CNE_DTENT)),NIL})
					ENDIF	
					IF AttIsMemberOf(oJson:ITENS[nI] , "CNE_CC")
						AADD(aItem, {"CNE_CC",alltrim(oJson:ITENS[nI]:CNE_CC),NIL})
					ENDIF	
					IF AttIsMemberOf(oJson:ITENS[nI] , "CNE_PEDTIT")
						AADD(aItem, {"CNE_PEDTIT",alltrim(oJson:ITENS[nI]:CNE_PEDTIT),NIL})
					ENDIF					
					
					
					AADD(aItens, aItem)				
				NEXT nI	
			ELSE
				cMsgErro += "Itens da Medicao nao informado [CNE]"+CRLF
			ENDIF
		ELSE
			cMsgErro += "Cabecalho da Medicao nao informado [CND]"+CRLF			
		ENDIF
		
		IF EMPTY(cMsgErro)	
			aRetAux	:= U_WSRGVIG(cEmpMed, cFilMed, nOper, aCabec, aItens)
			IF !aRetAux[1] 
				IF empty(aRetAux[2])
				 	if empty(aRetAux[3])
				 		cMsgErro	:= "Erro indeterminado. aRetAux[3] == EMPTY"
				 	else
				 		cMsgErro	:= "Erro indeterminado."
				 	endif
				ELSE
					cMsgErro	:= aRetAux[2]
				ENDIF
			ENDIF
		ENDIF

	ELSE
		nCodeRet		:= 400
		cMsgErro		:= "Invalid Json"
	ENDIF
ELSE
	nCodeRet		:= 401
	cMsgErro		:= "Body Vazio"
ENDIF

IF EMPTY(cMsgErro)
	aRet	:= {200, "Dentro da vigência"}
ELSE
	IF EMPTY(nCodeRet)
		nCodeRet	:= 400
	ENDIF
	aRet	:= {nCodeRet, cMsgErro}
ENDIF	

Return(aRet)


/*/{Protheus.doc} WSRGVIG
Grava medição de contrato
@author Augusto Ribeiro | www.compila.com.br
@since 23/02/2018
@version undefined
@param param
@return aRet, {lOK, cMSgErro, cNumMedicao}
@example
(examples)
@see (links_or_references)
/*/
User Function WSRGVIG(cEmpMed, cFilMed, nOper, aCabec, aItens)
Local aRet			:= {.f., "", ""}
Local cMsgErro		:= ""
Local nI, nY, nPosAux
Local _cCodEmp, _cCodFil, _cFilNew
//Local xGetPort	:= GetPort(3)

//Local aObgCabec		:= {"CND_CONTRA", "CND_COMPET", "CND_NUMERO", "CND_FORNEC", "CND_LJFORN", "CND_SERVIC", "CND_PARCEL", "CND_DTVENC", "CND_XIDFLG"}
Local aObgCabec		:= {"CND_CONTRA", "CND_COMPET", "CND_NUMERO", "CND_FORNEC", "CND_LJFORN", "CND_SERVIC", "CND_XIDFLG"}
Local aObgItens		:= {"CNE_ITEM", "CNE_PRODUT", "CNE_VLUNIT", "CNE_DTENT", "CNE_CC", "CNE_PEDTIT"}
//Local aObgItens		:= {"CNE_ITEM", "CNE_PRODUT", "CNE_QUANT", "CNE_VLUNIT", "CNE_VLTOT", "CNE_DTENT", "CNE_CC", "CNE_PEDTIT"}
//Local aObgItens		:= {"CNE_ITEM", "CNE_PRODUT", "CNE_QUANT", "CNE_VLUNIT", "CNE_DTENT", "CNE_CC", "CNE_PEDTIT"}

Local nDCONTRA, nDREVISA, nDXIDFLG, nDDTVENC, nEDTENT, nDNUMERO
Local cSemaf
lOCAL nHSemafaro	:= 0
Local cPortWEB := ""

Local oErro 		:= ErrorBlock({|e| lError := .T., iif(nHSemafaro>0, U_CPXSEMAF("F", cSemaf,nHSemafaro),.t.) ,cMsgErro := "[WSRGVIG e] "+IIF(VALTYPE(e:Description)=="C", e:Description,"Falha na execucao ")+CRLF+"ERROR STACK"+IIF(VALTYPE(e:Description)=="C",e:ERRORSTACK,"")  })

CONOUT("WSRGVIG INICIO "+DTOC(DDATABASE)+" "+TIME())

BEGIN SEQUENCE 

IF !EMPTY(cEmpMed) .AND. !EMPTY(cFilMed) .AND. !EMPTY(nOper) .AND. !EMPTY(aCabec) .AND. !EMPTY(aItens)

	/*--------------------------
		CABEC
	---------------------------*/
	For nI := 1 TO LEN(aObgCabec)
		
		nPosAux	:= aScan(aCabec, { |x| AllTrim(x[1]) == aObgCabec[nI] })
		IF nPosAux > 0
			If EMPTY(aCabec[nPosAux,2])
				cMsgErro += "Campo ["+aObgCabec[nI]+"] e de preenchimento obrigatorio."+CRLF
			ENDIF
		ELSE
			cMsgErro += "Campo ["+aObgCabec[nI]+"] nao informado na integracao."+CRLF
		ENDIF	
	Next nI
	
	nDDTVENC	:= aScan(aCabec, { |x| AllTrim(x[1]) == "CND_DTVENC" })
	
	/*--------------------------
		ITENS
	---------------------------*/	
	FOR nY := 1 to len(aItens)
		For nI := 1 TO LEN(aObgItens)
			
			nPosAux	:= aScan(aItens[nY], { |x| AllTrim(x[1]) == aObgItens[nI] })
			IF nPosAux > 0
				If EMPTY(aItens[nY,nPosAux,2])
					cMsgErro += "Item ["+alltrim(str(nY))+"] Campo ["+aObgItens[nI]+"] e de preenchimento obrigatorio."+CRLF
				ENDIF
			ELSE
				cMsgErro += "Item ["+alltrim(str(nY))+"] Campo ["+aObgItens[nI]+"]  nao informado na integracao."+CRLF
			ENDIF	
			
			/*--------------------------------------
				Regra ja existente fonte original
			---------------------------------------*/
			nEDTENT	:= aScan(aItens[nY], { |x| AllTrim(x[1]) == "CNE_DTENT" })
			IF !EMPTY(nEDTENT)
				IF aItens[nY,nEDTENT,2] < dDatabase
					aItens[nY,nEDTENT,2]	:= dDatabase
				ENDIF 
			ENDIF
		Next nI	
	Next nY
	

	nDXIDFLG	:= aScan(aCabec, { |x| AllTrim(x[1]) == "CND_XIDFLG" })

	IF iif(EMPTY(nDXIDFLG),.F., !EMPTY(aCabec[nDXIDFLG,2]))
		

		CONOUT("WSRGVIG CND_XIDFLG "+alltrim(aCabec[nDXIDFLG,2]))
		
		cSemaf	:= "WSRGVIG_"+alltrim(aCabec[nDXIDFLG,2])
		
		/*------------------------------------------------------ Augusto Ribeiro | 12/10/2017 - 7:01:42 PM
			Abre semaforo de Processamento
		------------------------------------------------------------------------------------------*/
		nHSemafaro	:= U_CPXSEMAF("A", cSemaf)
		
		IF nHSemafaro > 0		
		
			IF EMPTY(cMsgErro)
				/*---------------------------------------
					Realiza a TROCA DA FILIAL CORRENTE 
				-----------------------------------------*/
				_cCodEmp 	:= SM0->M0_CODIGO
				_cCodFil	:= SM0->M0_CODFIL
				_cFilNew	:= cFilMed //| CODIGO DA FILIAL DE DESTINO 
				
				IF _cCodEmp+_cCodFil <> _cCodEmp+_cFilNew
					CFILANT := _cFilNew
					opensm0(_cCodEmp+CFILANT)
				ENDIF
				
				nDCONTRA	:= aScan(aCabec, { |x| AllTrim(x[1]) == "CND_CONTRA" })
				nDREVISA	:= aScan(aCabec, { |x| AllTrim(x[1]) == "CND_REVISA" })
				nDNUMERO	:= aScan(aCabec, { |x| AllTrim(x[1]) == "CND_NUMERO" })
				
				cContra	:= PADR(aCabec[nDCONTRA,2],TAMSX3("CND_CONTRA")[1])
				IF nDREVISA > 0
					cRevisa	:= PADR(aCabec[nDREVISA,2],TAMSX3("CND_REVISA")[1])
				ELSE
					cRevisa	:= PADR(" ",TAMSX3("CND_REVISA")[1])
				ENDIF
				
				/*------------------------------------------------------ Augusto Ribeiro | 27/02/2018 - 8:28:25 AM
					Localiza contra e verifica se exta dentro da vigencia.
				------------------------------------------------------------------------------------------*/
				DBSELECTAREA("CN9")
				CN9->(DBSETORDER(1)) //| 
				IF CN9->(DBSEEK(cFilMed+cContra+cRevisa,.F.))
					
					IF IIF(EMPTY(CN9->CN9_DTFIM),.T., CN9->CN9_DTFIM >= dDATABASE)
						
						//| Verifica se o contrato é fixo |						
						cAux	:= ContrFixoCronog(aCabec, aItens)
						IF !EMPTY(cAux)
							cMsgErro	+= cAux+CRLF
						ENDIF
						
						DBSELECTAREA("CNA")
						CNA->(DBSETORDER(1)) //| CNA_FILIAL+CNA_CONTRA+CNA_REVISA+CNA_NUMERO
						IF CNA->(!DBSEEK(CN9->CN9_FILIAL+CN9->CN9_NUMERO+CN9->CN9_REVISA+PADR(ALLTRIM(aCabec[nDNUMERO,2]),TAMSX3("CNA_NUMERO")[1]) ,.F.)) 
							cMsgErro += "Planilha nao encontrada ["+CNA->CNA_NUMERO+"]"+CRLF
						ENDIF						
					ELSE	
						cMsgErro += "Contrato fora da vigencia ["+DTOC(CN9->CN9_DTFIM)+"]"+CRLF
					ENDIF

				ELSE
					cMsgErro += "Contrato nao localizado ["+cFilMed+cContra+cRevisa+"]"+CRLF
				ENDIF	
					
				/*---------------------------------------
					Restaura FILIAL  
				-----------------------------------------*/
				IF _cCodEmp+_cCodFil <> _cCodEmp+_cFilNew
					CFILANT := _cCodFil
					opensm0(_cCodEmp+CFILANT)			 			
				ENDIF   		
			ENDIF
			
			U_CPXSEMAF("F", cSemaf,nHSemafaro)	
		ELSE
			cMsgErro	+= "Não foi possivel abrir o semaforo["+cSemaf+"]"+CRLF
		ENDIF	
	ELSE
		cMsgErro += "ID Fluig não informado."+CRLF
	ENDIF	
ELSE 
	cMsgErro += "Parametros Invalidos [WSRGVIG]"+CRLF	
ENDIF

END SEQUENCE

ErrorBlock(oErro)

IF EMPTY(cMsgErro)
	aRet[1]	:= .T.
ELSE
	aRet[2]	:= cMsgErro //+" [PORT "+cPortWEB+"]"
ENDIF

CONOUT("WSRGVIG FIM "+DTOC(DDATABASE)+" "+TIME())

Return(aRet)


/*/{Protheus.doc} ContrFixoCronog
Verifica se é contrato fixo com cronograma

** ATENÇÃO **
CN9 deve estar posicionado


@author Augusto Ribeiro | www.compila.com.br
@since 27/02/2018
@version undefined
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function ContrFixoCronog(ALSTCABEC, ALSTITENS)
Local cMsgErro	:= ""

DBSELECTAREA("CN1")
CNI->(DBSETORDER(1)) //| 
IF CN1->(DBSEEK(xfilial("CN1")+CN9->CN9_TPCTO,.F.)) 

	IF CN1->CN1_MEDEVE == "2" .And.;
	 	AllTrim(CN1->CN1_MEDAUT) == "1" .AND.;
	 	AllTrim(CN1->CN1_CTRFIX) == "1" .AND.;
	 	AllTrim(CN1->CN1_VLRPRV) == "1"
	
	
	   nIdx1 := aScan(ALSTCABEC,{|x| AllTrim(x[1]) == 'CND_SERVIC'})
 	   nIdx2 := aScan(ALSTCABEC,{|x| AllTrim(x[1]) == 'CND_CONTRA'})
	   nIdx3 := aScan(ALSTCABEC,{|x| AllTrim(x[1]) == 'CND_COMPET'})
	   nIdx4 := aScan(ALSTCABEC,{|x| AllTrim(x[1]) == 'CND_NUMERO'})
	   nIdx5 := aScan(ALSTITENS[1],{|x| AllTrim(x[1]) == 'CNE_VLTOT'})
						
	   If nIdx1 > 0 .And. nIdx2 > 0 .And. nIdx3 > 0 .And. nIdx4 > 0 .And. nIdx5 > 0

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
			   			cMsgErro := "Valor total da medição (" + AllTrim( Transform(nSomaCNEs,"@E 9999,999,999.99")  ) +") maior que o valor (" + AllTrim(   Transform((cCNFalias)->(CNF_VLPREV),"@E 9999,999,999.99")       ) + ")  do Cronograma " + AllTrim((cCNFalias)->(CNF_NUMERO)) + " !"
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
						cMsgErro := ">>> Valor total da medição (" + AllTrim(Transform(nSomaCNEs,"@E 9999,999,999.99")) +") não corresponde a margem de valores ( de " + AllTrim( Transform(nVlrDe,"@E 9999,999,999.99")  )  + " até " + AllTrim( Transform(nVlrAte,"@E 9999,999,999.99")  ) + ") "  
						cMsgErro += " ou a margem ( de " + AllTrim( Transform(nVlrMenorAte,"@E 9999,999,999.99")  )  + " até " + AllTrim( Transform(nVlrDe,"@E 9999,999,999.99")  ) + ")  "
						cMsgErro += " deste Cronograma " + AllTrim((cCNFalias)->(CNF_NUMERO)) + " !"
					EndIf
		   		EndIf
		   	Else
		   		cMsgErro := "Cronograma não localizado no sistema (tabela CNF)!"
	   		EndIf
	   		
	   		(cCNFalias)->(DbCLoseArea())
 	   EndIf
	 	
	
	ENDIF

ENDIF

Return(cMsgErro)

/*/{Protheus.doc} VldParc
Verifica a Parcela da medicao
@author Jonatas Oliveira | www.compila.com.br
@since 17/07/2018
@version 1.0
/*/
Static Function VldParc(_cFilMed, _cCtrMed, _cPerMed, _cRevMed )
	Local cQuery	:= ""
	Local cRet		:= ""
	
	cQuery +=  " SELECT CNF_PARCEL "
	cQuery +=  " FROM "+Retsqlname("CNF")+" CNF  WITH(NOLOCK)   "
	cQuery +=  " WHERE CNF.D_E_L_E_T_ = ''  "
	cQuery +=  " 	AND CNF.CNF_FILIAL = '" +_cFilMed + "' " 
	cQuery +=  " 	AND CNF.CNF_CONTRA = '" +_cCtrMed + "'  "
	cQuery +=  " 	AND CNF_REVISA = '"+_cRevMed+"'  "
	cQuery +=  " 	AND CNF_COMPET = '"+_cPerMed+"' " 
	
	
	If Select("QRYPAR") > 0
		QRYPAR->(DbCloseArea())
	EndIf
	
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),'QRYPAR')
	
	IF QRYPAR->(!EOF())
	
		cRet := QRYPAR->CNF_PARCEL
	ENDIF 
	
	
	
Return(cRet)
