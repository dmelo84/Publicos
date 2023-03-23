#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.ch"

/*/{Protheus.doc} FA080EST2
Ao final d do cancelamento da baixa do titulo no CP destino disparo em seguida o cancelamento da baixa do titulo CR origem

@since 30/12/2014
@version P11 11.8
@description trata consistencias do mutuo
@obs Uso: Bradesco Seguros - BSP 
 
@return Boolean
/*/

User Function F080EST2
Local aArea := GetArea()
Local lRet  := .T.

If FindFunction ("U_ALFIN3BaixaCancelaCROrigem")
	lRet := U_ALFIN3BaixaCancelaCROrigem (.F.)
EndIf

restArea(aArea)
Return (lRet)

