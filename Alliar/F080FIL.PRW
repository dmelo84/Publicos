#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.ch"

/*/{Protheus.doc} F080FIL
Evita listar Títulos de mutuo na tela de "baixa em lotes" do CP 

@since 30/12/2014
@version P11 11.8
@description trata consistencias do mutuo
@obs Uso: Bradesco Seguros - BSP 
 
@return Boolean
/*/

User Function F080FIL ()
Local aArea := GetArea()
Local cRet := ''

If FindFunction("U_ALFI02")
	cRet := U_ALFI02()
EndIf

restArea(aArea)
Return (cRet)

