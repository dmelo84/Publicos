#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.ch"

/*/{Protheus.doc} FA460FIL
EVITA LISTAR  Títulos de mutuo NA TELA DE LIQUIDACAO DO CR

@since 30/12/2014
@version P11 11.8
@description trata consistencias do mutuo
@obs Uso: Alliar
 
@return Boolean
/*/

User Function FA460FIL ()
Local aArea := GetArea()
Local cRet := ''

If FindFunction("U_ALFI16")
	cRet := U_ALFI16()
EndIf

restArea(aArea)
Return (cRet)

