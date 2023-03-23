#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.ch"

/*/{Protheus.doc} F290FIL
EVITA LISTAR  Títulos de mutuo NA TELA DE GERAR FATURAS DO CP

@since 30/12/2014
@version P11 11.8
@description trata consistencias do mutuo
@obs Uso: Bradesco Seguros - BSP 
 
@return Boolean
/*/

User Function F290FIL ()
Local aArea := GetArea()
Local cRet  := ''

If FindFunction("U_ALFI05")
	cRet := U_ALFI05()
EndIf

restArea(aArea)

Return (cRet)

