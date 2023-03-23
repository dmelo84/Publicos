#include 'protheus.ch'
#include 'parmtype.ch'


USER FUNCTION ALJSGET(URL,aHeader,cPath)

	Local alJsonRet := {.F.,""}
	
	//| Endere�o do Host que iremos fazer o consumo do REST
	
	Local olJsonGet := FWRest():New(URL)
	
	//| Informa o path onde ser� feito a requisi��o
	
	olJsonGet:setPath(cPath)
	
	//| Efetua o GET no Host/Path informados.
	
	IF olJsonGet:Get(aHeader)
		
		alJsonRet[1] := .T.
		alJsonRet[2] := olJsonGet:GetResult()
	
	ELSE
	
		alJsonRet[2] := olJsonGet:GetLastError()

	ENDIF	

RETURN(alJsonRet)
