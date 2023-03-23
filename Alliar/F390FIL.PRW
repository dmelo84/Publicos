#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.ch"

/*/{Protheus.doc} F390FIL
EVITA LISTAR  Títulos de mutuo NA TELA DE cheques do CP

@since 30/12/2014
@version P11 11.8
@description trata consistencias do mutuo
@obs Uso: Bradesco Seguros - BSP 
 
@return Boolean
/*/

User Function F390FIL ()
Local aArea := GetArea()
Local cRet := ''

If FindFunction("U_ALFI09")
	cRet := U_ALFI09()
EndIf

restArea(aArea)

Return (cRet)

