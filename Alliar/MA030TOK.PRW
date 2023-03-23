#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.ch"

/*/{Protheus.doc} MA030TOK

@since 30/12/2014
@version P11 11.8
@description trata consistencias do mutuo
@obs Uso:Alliar
 
@return Boolean
/*/

User Function MA030TOK
Local aArea := GetArea()
Local lRet  := .T.

If FindFunction ("U_ALFIN1")
	lRet := U_ALFIN1("MATA030")
EndIf


If lRet .And. FindFunction ("U_ALRFAT01")//<- conciliado PE do Leandro
	lRet := U_ALRFAT01()
EndIf

//| Validação do CEP
If lRet
	lRet := U_alVldCEP("A1_CEP")
endif

restArea(aArea)
Return(lRet)

