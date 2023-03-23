#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.ch"

/*{Protheus.doc}  F0FA080CHK
BAIXA DO TITULO DO CONTAS A PAGAR
@since 30/12/2014
@version P11 11.8
@description trata consistencias do mutuo
@obs Uso: Alliar
 
@return Boolean
*/

User Function FA080CHK()
Local aArea := GetArea()
Local lRet  := .T.

If FindFunction ("U_VrExistBco")
	lRet := U_VrExistBco()
EndIf

restArea(aArea)
Return (lRet)

