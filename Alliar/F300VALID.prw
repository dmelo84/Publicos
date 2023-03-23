// #########################################################################################
// Projeto:
// Modulo :
// Fonte  : F300VALID
// ---------+-------------------+-----------------------------------------------------------
// Data     | Autor             | Descricao
// ---------+-------------------+-----------------------------------------------------------
// 27/10/14 | TOTVS | Developer Studio | Gerado pelo Assistente de C�digo
// ---------+-------------------+-----------------------------------------------------------

#include "rwmake.ch"



//------------------------------------------------------------------------------------------
/*/{Protheus.doc} F300VALID
Permite a manuten��o de dados armazenados em .

@author    TOTVS | Developer Studio - Gerado pelo Assistente de C�digo
@version   1.xx
@since     27/10/2014
/*/
//------------------------------------------------------------------------------------------
user function F300VALID()
Local lRet 		:= .T.
                                          
If FindFunction("U_ALFI06")
	lRet := U_ALFI06()
EndIf

Return lRet 


