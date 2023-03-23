#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.ch"

/*/{Protheus.doc} FA280QRY
Evita listar Títulos de mutuo na tela de "gerar faturas" do CR 

@since 30/12/2014
@version P11 11.8
@description trata consistencias do mutuo
@obs Uso: Bradesco Seguros - BSP 
 
@return Boolean
/*/

User Function FA280QRY ()
Local aArea := GetArea()
Local cRet := ''
              
If FindFunction("U_ALFI14")
	cRet := U_ALFI14()
EndIf

restArea(aArea)
Return (cRet)

