#Include 'Protheus.ch'
#Include 'FWMVCDEF.ch'
#Include 'RestFul.CH'

User Function VALIDAXFUN()
Return



WSRESTFUL VALIDAXFUN DESCRIPTION "Serviço REST para manipulação de Medicos"

WSDATA VLDTYPE AS STRING  
WSDATA XPAR1 AS STRING 
WSDATA XPAR2 AS STRING
WSDATA XPAR3 AS STRING  
WSDATA XPAR4 AS STRING  
WSDATA XPAR5 AS STRING    
WSDATA XPAR6 AS STRING

WSMETHOD GET DESCRIPTION "Retorna validacao conforme tipo parametro type" WSSYNTAX "/VALIDAXFUN || /MEDICOS/{VLDTYPE, XPAR1,XPAR2,XPAR3,XPAR4,XPAR5,XPAR6}"

END WSRESTFUL



WSMETHOD GET WSRECEIVE VLDTYPE, XPAR1, XPAR2, XPAR3, XPAR4, XPAR5, XPAR6 WSSERVICE VALIDAXFUN
Local cJson    := ""
Local nAction  := -1
Local cMsg	   := ""
Local cQuery	:= ""
Local cQryCtr	:= ""
Local nCodeRet	:= 400
Local nCount, cDtPar, cDtCompet


::SetContentType("application/json")


#DEFINE ACTION_SUCESSO 0
#DEFINE ACTION_ALERTA 1
#DEFINE ACTION_NEGA	-1

/*------------------------------------------------------ Augusto Ribeiro | 18/01/2018 - 9:36:31 PM
	Bloco de Autorização 
------------------------------------------------------------------------------------------*/

cAutBasic	:= self:GetHeader("Authorization") //| BASIC YWRtaW46| ( Encode64("integrador:integrador@1234") aW50ZWdyYWRvcjppbnRlZ3JhZG9yQDEyMzQ=)
	

IF U_CPxAuWSR(cAutBasic)
	
	
	IF !EMPTY(SELF:VLDTYPE)
	
	
		/*------------------------------------------------------ Augusto Ribeiro | 01/02/2018 - 5:47:01 PM
			Validacao do campo competencia do contrato - Fluxo Inclusão Medicao FLuig
			XPAR1 = FILIAL
			XPAR2 = CONTRATO
			XPAR3 = COMPETENCIA
		------------------------------------------------------------------------------------------*/
		IF SELF:VLDTYPE == "CND_COMPET"
		
			IF !EMPTY(SELF:XPAR1) .AND.;
				!EMPTY(SELF:XPAR2) .AND.;
				!EMPTY(SELF:XPAR3)
				
				SELF:XPAR1	:= ALLTRIM(SELF:XPAR1)
				SELF:XPAR2	:= ALLTRIM(SELF:XPAR2)
				cDtPar		:= ALLTRIM(SELF:XPAR3)
				cRevisa		:= ALLTRIM(SELF:XPAR5)
				/*
				cQuery := " SELECT CND_COMPET "+CRLF
				cQuery += " FROM "+RetSqlName("CND")+" CND  WITH(NOLOCK) "+CRLF
				cQuery += " WHERE CND.CND_FILIAL = '"+SELF:XPAR1+"' "+CRLF
				cQuery += " AND CND.CND_CONTRA = '"+SELF:XPAR2+"' "+CRLF
				cQuery += " AND CND.D_E_L_E_T_ = '' "+CRLF
				cQuery += " AND CND.CND_NUMERO = '"+SELF:XPAR4+"' "+CRLF
				cQuery += " GROUP BY CND_COMPET "+CRLF
				cQuery += " ORDER BY CONVERT(datetime, '01/'+CND_COMPET) DESC "+CRLF
				*/
				
				cQuery := " SELECT CNF_COMPET, CNF_DTREAL, CNF_SALDO "+CRLF
				cQuery += " FROM "+RetSqlName("CNF")+" CNF  WITH(NOLOCK)  "+CRLF
				cQuery += " WHERE CNF.D_E_L_E_T_ = '' "+CRLF
				cQuery += " 	AND CNF.CNF_FILIAL = '"+SELF:XPAR1+"' "+CRLF
				cQuery += " 	AND CNF.CNF_CONTRA = '"+SELF:XPAR2+"' "+CRLF
				cQuery += " 	AND CNF.CNF_NUMPLA = '"+SELF:XPAR4+"' "+CRLF
				cQuery += " 	AND CNF_REVISA = '"+cRevisa+"' "+CRLF
				//cQuery += " 	AND CNF_COMPET <= '"+cDtPar+"' "+CRLF
				cQuery += " 	AND RIGHT(CNF_COMPET,4)+LEFT(CNF_COMPET,2) <= '"+RIGHT(cDtPar,4)+LEFT(cDtPar,2)+"' "+CRLF
				cQuery += " 	ORDER BY RIGHT(CNF_COMPET,4)+LEFT(CNF_COMPET,2) DESC, CNF_PARCEL DESC "+CRLF
								
				If Select("TSQL") > 0
					TSQL->(DbCloseArea())
				EndIf
				
				DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TSQL",.F., .T.)						
				
			
				IF TSQL->(!EOF())
					 
					nSaldo		:= 0
					lExistComp	:= .F.
					cCompAnt	:= ""
					//dDtPar		:= ctod("01/"+cDtPar)
					nCount	:= 0
					WHILE TSQL->(!EOF())
						nCount++
						cDtCompet	:= ALLTRIM(TSQL->CNF_COMPET) //ctod("01/"+CND_COMPET)
						
						
						
						IF cDtPar == cDtCompet 
							IF  TSQL->CNF_SALDO > 0//EMPTY(TSQL->CNF_DTREAL)//RIGHT(XPAR3,4)+LEFT(XPAR3,2) == RIGHT(CND_COMPET,4)+LEFT(CND_COMPET,2)
								nSaldo	:= TSQL->CNF_SALDO
							ENDIF
						ELSEIF  nCount == 1
							cMsg	:= "Competencia nao localizada no cronograma financeiro do contrato"
							EXIT
						ELSEIF EMPTY(cCompAnt) .OR. cCompAnt == cDtCompet
							cCompAnt := cDtCompet
							IF  TSQL->CNF_SALDO > 0
								cMsg	:= "Competencia anterior em aberto. ["+cDtCompet+"]"
								EXIT
							ENDIF		
						ELSE
							EXIT
						ENDIF
						
						
						
						
						
						
//						IF cDtPar == cDtCompet 
//							IF  TSQL->CNF_SALDO > 0//EMPTY(TSQL->CNF_DTREAL)//RIGHT(XPAR3,4)+LEFT(XPAR3,2) == RIGHT(CND_COMPET,4)+LEFT(CND_COMPET,2)
//								nAction	:= ACTION_SUCESSO
//								cMsg	:= ""
//							ELSE
//								cMsg	:= "Ja existe uma medicao para esta competencia."
//								EXIT								
//							ENDIF
//						ELSEIF nCount == 1
//							cMsg	:= "Competencia nao localizada no cronograma financerio do contrato"
//							EXIT	
//						ELSEIF EMPTY(TSQL->CNF_DTREAL)
//							cMsg	:= "Competencia anterior em aberto. ["+cDtCompet+"]"
//						ENDIF 	

						TSQL->(DBSKIP()) 
					ENDDO	
					
					
					IF nSaldo > 0 .AND. EMPTY(cMsg)
						nAction	:= ACTION_SUCESSO
						cMsg	:= ""
					ELSE
						nAction	:= ACTION_NEGA
						IF 	nSaldo <= 0 .AND. EMPTY(cMsg)
							cMsg	:= "Competencia ["+cDtPar+"] nao possui saldo em aberto"
						ENDIF
					ENDIF
							
				ELSE 
					nAction	:= ACTION_SUCESSO
					cMsg	:= ""
				ENDIF
				
				TSQL->(DbCloseArea())
				nCodeRet	:= 200
				IF EMPTY(cMsg)
					nAction := ACTION_SUCESSO
				ENDIF
			ELSE
				nCodeRet	:= 400
				cMsg		:= "Para validacao da competencia, e obrigatorio informar, filial, contrato competencia"
			ENDIF
		ELSE 
			nCodeRet	:= 400
			cMsg	:= "Nenhuma validacao implementada com o VLDTYPE ["+SELF:VLDTYPE+"]"
		ENDIF
	ELSE 
		nCodeRet	:= 400
		cMsg		:= "Primeiro parametro VLDTYPE Invalido"	 
	ENDIF
ELSE
	//SetRestFault(401, "Authentication Required")
	nCodeRet	:= 401
	cMsg		:= "Authentication Required"	
ENDIF		
		

	
	//cpxToJson(cName, xValue)

cJson	:= "{"
cJson	+= U_cpxToJson("code", nCodeRet)+","
cJson	+= U_cpxToJson("msg", cMsg)+","
cJson	+= U_cpxToJson("action", nAction)
cJson	+= "}"


/*	
cJson	:= ' { '
cJson	+= ' "MEDICOS": [], '
cJson	+= ' "MSGERRO": "Parametro EMAILVISIT e de preenchimento obrigatorio" '
cJson	+= '} '
*/

::SetResponse(cJson)

//RestArea(aArea)
Return(.T.)