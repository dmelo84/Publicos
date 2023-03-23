#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.ch"

/*/{Protheus.doc} F340FCPTOP
Evita listar Títulos de mutuo na tela de "compensar" do CP 

@since 30/12/2014
@version P11 11.8
@description trata consistencias do mutuo
@obs Uso: Bradesco Seguros - BSP 
 
@return Boolean
/*/

User Function F340FCPTOP ()
Local aArea := GetArea()
Local cRet  := PARAMIXB[1]

If FindFunction("U_ALFI07")
	cRet := U_ALFI07(PARAMIXB[1])
EndIf

restArea(aArea)
Return (cRet)

