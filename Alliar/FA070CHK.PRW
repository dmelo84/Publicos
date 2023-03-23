#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.ch"

/*/{Protheus.doc} FA070chk
EVITA EFETUAR BAIXA DE TITULOS DO TIPO MUTUO NO CONTAS A RECEBER

@since 30/12/2014
@version P11 11.8
@description trata consistencias do mutuo
@obs Uso: Alliar
 
@return Boolean
/*/

User Function FA070chk ()
Local aArea := GetArea()
Local lRet  := .T.
               
If FindFunction("U_ALFI12")
	lRet := U_ALFI12()
EndIf

restArea(aArea)
Return (lRet)

