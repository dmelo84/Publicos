// #########################################################################################
// Projeto:
// Modulo :
// Fonte  : F340VALID
// ---------+-------------------+-----------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+-----------------------------------------------------------
// 27/10/14 | TOTVS | Developer Studio | Gerado pelo Assistente de Código
// ---------+-------------------+-----------------------------------------------------------

#include "rwmake.ch"

Static lFuncPCCBx := FindFunction("FPccBxCr")

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} F340VALID
No contas a pagar, evitar utiliza um titulo Mutuo como base para a compensacao

@author    TOTVS | Developer Studio - Gerado pelo Assistente de Código
@version   1.xx
@since     27/10/2014
/*/
//------------------------------------------------------------------------------------------
user function F340VALID()
Local aArea := GetArea()
Local lRet 		:= .T.

If FindFunction("U_ALFI08")
	lRet := U_ALFI08()
EndIf

restArea(aArea)
Return lRet 

