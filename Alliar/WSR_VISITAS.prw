#Include 'Protheus.ch'
#Include 'FWMVCDEF.ch'
#Include 'RestFul.CH'
#Include "rwmake.Ch"
#INCLUDE "TOPCONN.CH"
#INCLUDE "FWMBROWSE.CH"
#INCLUDE 'TBICONN.CH'

/*/{Protheus.doc} WSR_VISITAS
Rest para inclusใo e altera็ใo de visitas
@author Jonatas Oliveira | www.compila.com.br
@since 02/06/2017
@version 1.0
/*/
User Function WSR_VISITAS()
Return



WSRESTFUL VISITAS DESCRIPTION "Servi็o REST para manipula็ใo de VISITAS"



//WSMETHOD GET DESCRIPTION "Retorna o VISITAS informado na URL" WSSYNTAX "/VISITAS || /VISITAS/{crm}"
WSMETHOD POST DESCRIPTION "Insere VISITAS" WSSYNTAX " /VISITAS/{}"

END WSRESTFUL




WSMETHOD POST  WSSERVICE VISITAS
	Local oObjProd := Nil
	Local cStatus  := ""
	LOcal cBody		:= ""
	Local cJRetOK   := '{"code":200,"status":"success"}'
	Local oJson	
	Local lRet		:= .F.

	//Local aRetUsr := AllUsers()                            
	Local nI
	Local cUserPt := ""
	
	
	Local ADADOS	:= {}
	Local cMsgDeta	:= ""
	Local nOper		:= 0 //| 3- Inclusใo, 4- Altera็ใo, 5- Exclusใo|
	Local cCdFluig	:= ""
	Local aRetGrv	:={}
	Local DDTAUX	
	Local cQuery	:= ""
	Local lContinua	:= .T.
	
	::SetContentType("application/json")

	cBody := ::GetContent()
	IF !EMPTY(cBody)
		IF FWJsonDeserialize(cBody,@oJson)
		
			PswOrder(4)//|E-mail|
			If PswSeek( alltrim(oJson:EMAIL), .T. )
				cUserPt := PswRet( 1, .F. )[1][1]
				
				
				
				_cEmp		:= "01"
				_cFilial	:= "00101MG0001"//"00101MG0001"//"00303MG0001"
			
				PREPARE ENVIRONMENT EMPRESA _cEmp FILIAL _cFilial
				
				
				DBSELECTAREA("Z05")
				Z05->(DBSETORDER(3))//|Z05_IDFLUI|
				
				
				DBSELECTAREA("ACH")
				ACH->(DBSETORDER(1))//|Z05_IDFLUI|
				
				cQuery += " SELECT R_E_C_N_O_ AS RECNACH, * "
				cQuery += " FROM "+Retsqlname("ACH")+" "
				cQuery += " WHERE D_E_L_E_T_ = '' "
				cQuery += " 	AND ACH_XCRMUF = '"+ upper(oJson:Z05_UFCRM) +"' "
				cQuery += " 	AND ACH_XCRM = '"+ oJson:Z05_CRM +"' "
				
			
				If Select("QRYEXC") > 0
					QRYEXC->(DbCloseArea())
				EndIf
			
				dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),'QRYEXC')
				
				IF QRYEXC->(!EOF())
					
					ACH->(DBGOTO(QRYEXC->RECNACH))
									
					cCdFluig := ALLTRIM(oJson:Z05_IDFLUI)
					
					IF Z05->(DBSEEK(cCdFluig))
						nOper := 4
					ELSE
						nOper := 3
					ENDIF 

					
					DDTAUX		:= DDATABASE					
					DDATABASE :=  CTOD(oJson:Z05_DTIN)
						
					IF Z05->Z05_STATUS == "3" .AND. nOper == 4//|ALTERAวรO|
//						SetRestFault(301, "Visita ja finalizada anteriormente.")
						cJRetOK   := '{"code":301,"status":"Visita ja finalizada anteriormente."}'
						::SetResponse(cJRetOK)
						lRet	:= .T.
						lContinua := .F.
					ENDIF 
					
					IF lContinua
						AADD(aDados, {"Z05_STATUS"		, "3"	, .F.})	//1=Prevista;2=Programada;3=Finalizada
							
						IF nOper == 3//|INCLUSรO|
						
							AADD(aDados, {"Z05_USUAR"		, 	UsrRetName(cUserPt)			, .F.})
							AADD(aDados, {"Z05_CODVIS"		, 	cUserPt 			, .F.})
							AADD(aDados, {"Z05_VISITA"		, 	Alltrim(UsrFullName(cUserPt)) 			, .F.})
							AADD(aDados, {"Z05_CODMED"		, 	QRYEXC->ACH_CODIGO 	, .F.})
							AADD(aDados, {"Z05_LOJAME"		, 	QRYEXC->ACH_LOJA   	, .F.})
							AADD(aDados, {"Z05_CRM"			,   ACH->ACH_XCRM  		, .F.})
							AADD(aDados, {"Z05_UFCRM"		, 	ACH->ACH_XCRMUF		, .F.})
							AADD(aDados, {"Z05_SEGMEN"		, 	POSICIONE("AOV",1, XFILIAL("AOV") + ACH->ACH_CODSEG ,"AOV_DESSEG"), .F.})
							AADD(aDados, {"Z05_NOME"		,   ACH->ACH_RAZAO 		, .F.})
							AADD(aDados, {"Z05_ESPECI"		, 	ACH->ACH_XESP01		, .F.})
							AADD(aDados, {"Z05_EMAIL"		,  	ACH->ACH_EMAIL 		, .F.})
							AADD(aDados, {"Z05_ENDER"		,  	ACH->ACH_END   		, .F.})
							AADD(aDados, {"Z05_BAIRRO"		, 	ACH->ACH_BAIRRO		, .F.})
							AADD(aDados, {"Z05_MUNIC"		,  	ACH->ACH_CIDADE		, .F.})
							AADD(aDados, {"Z05_UF"			,   ACH->ACH_EST   		, .F.})
							AADD(aDados, {"Z05_CEP"			,   ACH->ACH_CEP   		, .F.})
							AADD(aDados, {"Z05_COMPL"		,  	ACH->ACH_XCOMPL		, .F.})
						
						
							AADD(aDados, {"Z05_DTPREV"		, CTOD(oJson:Z05_DTPREV) 	, .F.})
							AADD(aDados, {"Z05_HRPREV"		, oJson:Z05_HRPREV		, .F.})
							AADD(aDados, {"Z05_HRFIMP"		, oJson:Z05_HRFIMP		, .F.})
							//AADD(aDados, {"Z05_CRM"			, oJson:Z05_CRM			, .F.})
							//AADD(aDados, {"Z05_UFCRM"		, oJson:Z05_UFCRM		, .F.})
							AADD(aDados, {"Z05_IDFLUI"		, cCdFluig				, .F.})
												
						ENDIF 	
						
						AADD(aDados, {"Z05_CLINIC"		, oJson:Z05_CLINIC		, .F.})
						
						AADD(aDados, {"Z05_DTIN"		, CTOD(oJson:Z05_DTIN)	, .F.})
						AADD(aDados, {"Z05_HRIN"		, oJson:Z05_HRIN		, .F.})
						AADD(aDados, {"Z05_LATIIN"		, oJson:Z05_LATIIN		, .F.})
						AADD(aDados, {"Z05_ENDIN"		, RemovChar(oJson:Z05_ENDIN)		, .F.})
						AADD(aDados, {"Z05_LONGIN"		, oJson:Z05_LONGIN		, .F.})
						AADD(aDados, {"Z05_ENDFI"		, RemovChar(oJson:Z05_ENDFI)		, .F.})
						AADD(aDados, {"Z05_DTFIM"		, CTOD(oJson:Z05_DTFIM)	, .F.})
						AADD(aDados, {"Z05_HRFIM"		, oJson:Z05_HRFIM		, .F.})
						AADD(aDados, {"Z05_LATIFI"		, oJson:Z05_LATIFI		, .F.})
						AADD(aDados, {"Z05_LONGFI"		, oJson:Z05_LONGFI		, .F.})
						AADD(aDados, {"Z05_REUNIA"		, oJson:Z05_REUNIA		, .F.})//|1=Sim;2=Nao|
						
						IF AttIsMemberOf(oJson , "Z05_REUMED")
							AADD(aDados, {"Z05_REUMED"		, oJson:Z05_REUMED		, .F.})//|1=Sim;2=Nao|
						ENDIF
						
						IF AttIsMemberOf(oJson , "Z05_REUSEC")
							AADD(aDados, {"Z05_REUSEC"		, oJson:Z05_REUSEC		, .F.})//|1=Sim;2=Nao|
						ENDIF
						
						AADD(aDados, {"Z05_FEEDB"		, oJson:Z05_FEEDB		, .F.})//|1=Pessimo;2=Ruim;3=Regular;4=Bom;5=Otimo|
						AADD(aDados, {"Z05_DETALH"		, oJson:Z05_DETALH		, .F.})
				 					
						aRetGrv	:= U_ALVISIA("Z05", 3, aDados, nOper ,"ALVISIT", cCdFluig)
						
						RESET ENVIRONMENT 
						
						IF !aRetGrv[1]
							cJRetOK   := '{"code":300,"status":" Falha: '+ ALLTRIM(aRetGrv[2]) +'"}'
						ELSE
							cJRetOK   := '{"code":200,"status":"Successo '+ IIF(nOper == 4, "Alteracao", "Inclusao") +'"}'
						ENDIF 
						
						//cJRetOK   := '{"code":200,"status":"'+ cUserPt +'"}'
						//'{"code":200,"status":"success"}'
						::SetResponse(cJRetOK)
						lRet	:= .T.
					ENDIF 
				ELSE
					SetRestFault(403, "Medico nao encontrado ACH ["+alltrim(oJson:Z05_CRM)+"][" +upper(oJson:Z05_UFCRM) + "]")
				ENDIF 	
			ELSE
				SetRestFault(403, "E-mail nao informado ou usuario nao encontrado ["+alltrim(oJson:EMAIL)+"]")
			ENDIF 
			 
			
			/*
			For nI := 1 to Len(aRetUsr)	
				Aadd(aUsers, {aRetUsr[nI][1][1] , aRetUsr[nI][1][2], aRetUsr[nI][1][4] , aRetUsr[nI][1][14] }	)	//N๚mero de identifica็ใo seqüencial com o tamanho de 6 caracteres
				
				Aadd(aUsers, aRetUsr[nI][1][2]	)	//Nome do usuแrio
				Aadd(aUsers, aRetUsr[nI][1][4]	)	//Nome completo do usuแrio
				Aadd(aUsers, aRetUsr[nI][1][14]	)	//E-mail
				 
				
			Next nI
			
			
			IF  aScan(aUsers,{|x| AllTrim(x[4]) == "julio.franco.cdb.com"})
				
			ENDIF 
			*/
			//SetRestFault(200, "TUDO OK")
		
		ELSE
			SetRestFault(402, "Invalid Json")

		ENDIF
	ELSE
		SetRestFault(401, "Body Vazio")
	ENDIF


	DDATABASE := DDTAUX

Return(lRet)






/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ RemovCharบAutor  ณ Augusto Ribeiro	 บ Data ณ  08/06/2011 บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Remove caracter especial                                   ฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
STATIC Function RemovChar(cRet)
	Local cRet

	cRet	:= upper(cRet)

	cRet	:= STRTRAN(cRet,"ม","A")
	cRet	:= STRTRAN(cRet,"ษ","E")
	cRet	:= STRTRAN(cRet,"อ","I")
	cRet	:= STRTRAN(cRet,"ำ","O")
	cRet	:= STRTRAN(cRet,"ฺ","U")
	cRet	:= STRTRAN(cRet,"ภ","A")
	cRet	:= STRTRAN(cRet,"ศ","E")
	cRet	:= STRTRAN(cRet,"ฬ","I")
	cRet	:= STRTRAN(cRet,"า","O")
	cRet	:= STRTRAN(cRet,"ู","U")
	cRet	:= STRTRAN(cRet,"ร","A")
	cRet	:= STRTRAN(cRet,"ี","O")
	cRet	:= STRTRAN(cRet,"ฤ","A")
	cRet	:= STRTRAN(cRet,"ห","E")
	cRet	:= STRTRAN(cRet,"ฯ","I")
	cRet	:= STRTRAN(cRet,"ึ","O")
	cRet	:= STRTRAN(cRet,"Ü","U")
	cRet	:= STRTRAN(cRet,"ย","A")
	cRet	:= STRTRAN(cRet,"ส","E")
	cRet	:= STRTRAN(cRet,"ฮ","I")
	cRet	:= STRTRAN(cRet,"ิ","O")
	cRet	:= STRTRAN(cRet,"Û","U")
	cRet	:= STRTRAN(cRet,"ว","C")
	cRet	:= STRTRAN(cRet,"บ"," ")
	cRet	:= STRTRAN(cRet,"-","")
	cRet	:= STRTRAN(cRet,".","")
	cRet	:= STRTRAN(cRet,"R$","")
	cRet	:= STRTRAN(cRet,"NULL","")


Return(cRet)