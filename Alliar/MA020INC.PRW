#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.ch"

/*/{Protheus.doc} MA02INC

@since 30/12/2014
@version P11 11.8
@description trata consistencias do mutuo
@obs Uso: Alliar
 
@return Boolean
/*/

User Function MA020INC()
Local aArea := GetArea()
Local lRet  := .T.

If FindFunction ("U_ALFIN1")
	lRet := U_ALFIN1("MATA020")
EndIf

restArea(aArea)
Return (lRet)

