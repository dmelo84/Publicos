#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.ch"

/*/{Protheus.doc} FA050INC
EVITA INCLUIR MANULAMENTE UM TITULO SE2 COM PREFIXO DE MUTUO
TRATA TB A EXIGENCIA DOS C.CUSTOS NOS TITULSO DE CP!
@since 30/12/2014
@version P11 11.8
@description trata consistencias do mutuo
@obs Uso: Alliar
 
@return Boolean
/*/

User Function FA050INC ()
Local aArea := GetArea()
Local lRet  := .T.


If FindFunction("U_ALFIN5")
	lRet := U_ALFIN5(.F.)
EndIf


If lRet .And. FindFunction("U_ALFING")
	lRet := U_ALFING()
EndIf

restArea(aArea)

Return (lRet)

