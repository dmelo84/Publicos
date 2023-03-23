#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.ch"

/*/{Protheus.doc} F240FPGT
EVITA LISTAR  Títulos de mutuo NA TELA DE GERAR BORDERO CP

@since 30/12/2014
@version P11 11.8
@description trata consistencias do mutuo
@obs Uso: Bradesco Seguros - BSP 
 
@return Boolean
/*/

User Function F240FPGT ()
Local aArea := GetArea()
Local cRet  := ''

If FindFunction("U_ALFI04")
	cRet := U_ALFI04()
EndIf

restArea(aArea)

Return (cRet)

