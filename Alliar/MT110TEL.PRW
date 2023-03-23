#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.ch"

/*/{Protheus.doc} MT110TEL
ACRESCENTA NOVOS CAMPOS NO CABECALHO DA tela SC1

@since 30/12/2014
@version P11 11.8
@description trata consistencias do mutuo
@obs Uso: Alliar
 
@return Boolean
/*/

User Function MT110TEL ()
Local aArea   := GetArea()

If FindFunction("U_ALCO33")
	U_ALCO33(PARAMIXB)
EndIf

restArea(aArea)
Return 

