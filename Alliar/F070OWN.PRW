#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.ch"

/*/{Protheus.doc} F070OWN
evita listar titulos de mutuo na rotina de baixar em Lote no CR

@since 30/12/2014
@version P11 11.8
@description trata consistencias do mutuo
@obs Uso: Bradesco Seguros - BSP 
 
@return Boolean
/*/

User Function F070OWN ()
Local aArea   := GetArea()
Local cFiltro := ""

If FindFunction("U_ALFI01")
	cFiltro := U_ALFI01()
EndIf

restArea(aArea)
Return (cFiltro)

