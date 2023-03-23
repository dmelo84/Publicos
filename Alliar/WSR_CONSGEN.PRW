#Include 'Protheus.ch'
#Include 'FWMVCDEF.ch'
#Include 'RestFul.CH'
#INCLUDE "TBICONN.CH" 

User Function WSR_CONSGEN()
Return



WSRESTFUL CONSGEN DESCRIPTION "[CUSTOMIZADO] Serviço REST Consulta Genericas no Protheus V2."

WSMETHOD POST DESCRIPTION "Realiza consulta generica no Protheus" WSSYNTAX "/WSR_CONSGEN || /WSR_CONSGEN/{}"

END WSRESTFUL


WSMETHOD POST  WSSERVICE CONSGEN
LOcal cBody		:= ""
Local lRet		:= .T.

Local cRetAux


Local cAutBasic		:= ""





::SetContentType("application/json")

/*------------------------------------------------------ Augusto Ribeiro | 18/01/2018 - 9:36:31 PM
	Bloco de Autorização 
------------------------------------------------------------------------------------------*/

cAutBasic	:= self:GetHeader("Authorization") //| BASIC YWRtaW46|
	

IF U_CPxAuWSR(cAutBasic)

	cBody := ::GetContent()
	IF !EMPTY(cBody)
	

		//IF FWJsonDeserialize(cBody,@oJson)
		CONOUT(cBody)
		cRetAux	:= U_cpxCJson(cBody)
		::SetResponse(cRetAux)
	ELSE
		SetRestFault(400, "Empty Body")	
	ENDIF
ELSE
	SetRestFault(401, "Authentication Required")
ENDIF


Return(lRet)



