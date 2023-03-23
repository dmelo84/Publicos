#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.ch"

/*/{Protheus.doc} FA080OWN
Títulos de mutuo utilizarao somente cancelamento de baixa, jamais exclusao da baixa

@since 30/12/2014
@version P11 11.8
@description trata consistencias do mutuo
@obs Uso: Bradesco Seguros - BSP 
 
@return Boolean
/*/

User Function FA080OWN ()
Local aArea := GetArea()
Local lRet  := .T.
                     
If FindFunction("U_ALFI13")
	lRet := U_ALFI13(PARAMIXB[1])
EndIf

restArea(aArea)
Return (lRet)

