#Include 'Protheus.ch'
#Include 'FWMVCDEF.ch'
#Include 'RestFul.CH'

User Function CP12_INTEGRADOR()
Return



WSRESTFUL CP12_INTEGRADOR DESCRIPTION "Serviço REST de integração genérico"

WSDATA ROTINA AS STRING  
WSDATA XPAR1 AS STRING  
WSDATA XPAR2 AS STRING  
WSDATA XPAR3 AS STRING  
WSDATA XPAR4 AS STRING  
WSDATA XPAR5 AS STRING  
WSDATA XPAR6 AS STRING  

WSMETHOD POST DESCRIPTION "Insere, Altera e Exclui dados" WSSYNTAX "/CP12_INTEGRADOR"
WSMETHOD GET DESCRIPTION "Busca dados de acordo com os parametros passados" WSSYNTAX "/CP12_INTEGRADOR"

END WSRESTFUL


WSMETHOD POST  WSSERVICE CP12_INTEGRADOR
Local nStCode	:= 400
Local cMsgRet	:= "Erro indeterminado [CP12_INTEGRADOR]"
Local cIdRet	:= ""
LOcal cCusRet	:= ""

LOcal cBody		:= ""
Local cJsonRet	:= ""
Local oJson, aRetAux

Local cAutBasic		:= ""
Local lAutorizado	:= .F.	


::SetContentType("application/json")

/*------------------------------------------------------ Augusto Ribeiro | 18/01/2018 - 9:36:31 PM
	Bloco de Autorização 
------------------------------------------------------------------------------------------*/

cAutBasic	:= self:GetHeader("Authorization") //| BASIC YWRtaW46|
	

IF U_CPxAuWSR(cAutBasic)

	cBody := ::GetContent()
	
	IF cBody == Nil
		cBody := ""
	EndIf
	
	IF !EMPTY(cBody)
	

		//IF FWJsonDeserialize(cBody,@oJson)
		
		aRetAux	:= U_CP12W2D(cBody)
		
		nStCode	:= aRetAux[1]
		cMsgRet	:= aRetAux[2]
		cIdRet	:= aRetAux[3]
		cCusRet	:= aRetAux[4]
				
	ELSE
		nStCode	:= 400
		cMsgRet	:= "Empty Body"		
	ENDIF
ELSE
	nStCode	:= 401
	cMsgRet	:= "Authentication Required"
ENDIF


//| |
cMsgRet	:= STRTRAN(alltrim(cMsgRet),'"','')
cJsonRet	:= ""
cJsonRet	+= ' { "statuscode":'+alltrim(str(nStCode))+', '
cJsonRet	+= '"message":"'+cMsgRet+'",'
cJsonRet	+= '"idRet":"'+alltrim(cIdRet)+'",'
cJsonRet	+= '"customRet":{'+alltrim(cCusRet)+'} }  '

::SetResponse(cJsonRet)

Return(.T.)




WSMETHOD GET WSRECEIVE ROTINA, XPAR1, XPAR2, XPAR3, XPAR4, XPAR5, XPAR6 WSSERVICE CP12_INTEGRADOR
Local lRet		:= .f.

LOcal cBody		:= ""
Local cJsonRet	:= ""
Local oJson, aRetAux

Local cAutBasic		:= ""
Local lAutorizado	:= .F.	


::SetContentType("application/json")

/*------------------------------------------------------ Augusto Ribeiro | 18/01/2018 - 9:36:31 PM
	Bloco de Autorização 
------------------------------------------------------------------------------------------*/

cAutBasic	:= self:GetHeader("Authorization") //| BASIC YWRtaW46|
	

IF U_CPxAuWSR(cAutBasic)

	IF !EMPTY(SELF:ROTINA)
	
		

		//IF FWJsonDeserialize(cBody,@oJson)
		
		aRetAux	:= U_CP12W2G(SELF:ROTINA, {SELF:XPAR1, SELF:XPAR2, SELF:XPAR3, SELF:XPAR4, SELF:XPAR5, SELF:XPAR6} )
		
		
		IF aRetAux[1]
			cJsonRet	:= aRetAux[3]
			lRet		:= .t.
		ELSE
			SetRestFault(401, aRetAux[2])
		ENDIF
				
	ELSE
		SetRestFault(400, "Empty parameter")	
	ENDIF
ELSE

	SetRestFault(401, "Authentication Required")	
ENDIF

IF lRet
	::SetResponse(cJsonRet)
ENDIF

Return(lRet)





