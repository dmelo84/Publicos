#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.ch"

/*/{Protheus.doc} F090FIL
EVITA LISTAR  Títulos de mutuo NA TELA "Baixas Automaticas" do CP

@since 30/12/2014
@version P11 11.8
@description trata consistencias do mutuo
@obs Uso: Bradesco Seguros - BSP 
 
@return Boolean
/*/

User Function F090FIL ()
Local aArea := GetArea()
Local cRet := ''

If FindFunction("U_ALFI03")
	cRet := U_ALFI03()
EndIf

restArea(aArea)

Return (cRet)

