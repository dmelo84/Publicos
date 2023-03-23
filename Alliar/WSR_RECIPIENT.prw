#Include 'Protheus.ch'
#Include 'FWMVCDEF.ch'
#Include 'RestFul.CH'

User Function WSR_RECIPIENT()
Return



WSRESTFUL RECIPIENT DESCRIPTION "Serviço REST para interação com Gesplan - RECIPIENT "

WSMETHOD POST DESCRIPTION "Exportar Beneficiarios" WSSYNTAX "/RECIPIENT "

END WSRESTFUL


WSMETHOD POST  WSSERVICE RECIPIENT
	Local lRet		:= .T.
	Local cJson		:= ""


	Local cAutBasic		:= ""
	Local lAutorizado	:= .F.	

	LOcal cBody		:= ""


	::SetContentType("application/json")

	/*------------------------------------------------------ Jonatas Oliveira | 30/11/2018
	Bloco de Autorização 
	------------------------------------------------------------------------------------------*/

	cAutBasic	:= self:GetHeader("Authorization") //| BASIC YWRtaW46 #  BASIC YWRtaW46| ( Encode64("integrador:integrador@1234") aW50ZWdyYWRvcjppbnRlZ3JhZG9yQDEyMzQ=)

	IF U_CPxAuWSR(cAutBasic)

		cBody := ::GetContent()
		IF !EMPTY(cBody)
			//cJson	:= U_ALGPCASH()
			cJson	:= U_ALGPBENE(cBody)
		ELSE
			SetRestFault(401, "Authentication Required")
		ENDIF

		::SetResponse(cJson)
	ELSE
		SetRestFault(401, "Authentication Required")
		lRet	:= .F.
	ENDIF


Return(lRet)
