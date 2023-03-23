#include "rwmake.ch"
#include "protheus.ch"

/*
MT120FOL
Incluir novos folders

@author oswaldo.leite 
@since 09/12/2014
@version 1.0
*/

User Function MT120FOL()
Local nOpc    	:= PARAMIXB[1]
Local aPosGet 	:= PARAMIXB[2] 
Local oObs 

Public cCampo1 := ''

If FindFunction("U_ALCO15")
	U_ALCO15(nOpc, aPosGet)
EndIf

Return