#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.ch"

/*/{Protheus.doc} FA070CA3
EVITAR CANCELAMENTO E EXCLUSAO DE BAIXA NO CR SE TITULO FOR DO TIPO MUTUO 

@since 30/12/2014
@version P11 11.8
@description trata consistencias do mutuo
@obs Uso: Bradesco Seguros - BSP 
 
@return Boolean
/*/

User Function FA070CA3 ()
Local aArea := GetArea()
Local lRet := .T.
                 
If FindFunction("U_ALFI11")
	lRet := U_ALFI11()
EndIf

restArea(aArea)
Return (lRet)

