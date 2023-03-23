

/*/{Protheus.doc} FATA030
ponto de entrada na cadastro de Partner - Pacientes
PADRAO MVC
@author Augusto Ribeiro | www.compila.com.br
@since 27/06/2018
@version undefined
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/

User Function FATA030()
Local lRet	:= .t.
Local aParam	:= PARAMIXB

IF VALTYPE(aParam) == "A" 
	
	IF LEN(aParam) >= 2
		IF ALLTRIM(aParam[2]) == "MODELCOMMITTTS"
			aArea	:= GetArea()
			U_CP12ADD("000014", "AC4", AC4->(RECNO()),, )
			RestArea(aArea)
		ENDIF
	ENDIF
ENDIF

Return(lRet)