#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.ch"

/*/{Protheus.doc} FA330QRY
EVITA LISTAR  Títulos de mutuo NA TELA DE COMPENSACAO DO CR

@since 30/12/2014
@version P11 11.8
@description trata consistencias do mutuo
@obs Uso: Bradesco Seguros - BSP 
 
@return Boolean
/*/

User Function FA330QRY ()
Local aArea := GetArea()
Local cRet := PARAMIXB[1]
          
If FindFunction("U_ALFI15")
	cRet := U_ALFI15(PARAMIXB[1])
EndIf

restArea(aArea)

Return (cRet)

