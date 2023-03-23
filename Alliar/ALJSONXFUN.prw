#include 'protheus.ch'
#include 'parmtype.ch'


USER FUNCTION ALJSGET(URL,aHeader,cPath)

	Local alJsonRet := {.F.,""}
	
	//| Endereço do Host que iremos fazer o consumo do REST
	
	Local olJsonGet := FWRest():New(URL)
	
	//| Informa o path onde será feito a requisição
	
	olJsonGet:setPath(cPath)
	
	//| Efetua o GET no Host/Path informados.
	
	IF olJsonGet:Get(aHeader)
		
		alJsonRet[1] := .T.
		alJsonRet[2] := olJsonGet:GetResult()
	
	ELSE
	
		alJsonRet[2] := olJsonGet:GetLastError()

	ENDIF	

RETURN(alJsonRet)
