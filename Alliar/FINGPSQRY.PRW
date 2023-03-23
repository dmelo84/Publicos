#INCLUDE "PROTHEUS.CH" 
#INCLUDE "FWMVCDEF.CH"

/*
FINGPSQRY
seleciona intervalo de ID para a rotina: finrgps

@author totvs
@since 09/12/2014
@version 1.0
*/

User function FINGPSQRY ()
Local aArea := GetArea()
Local cQuery := " "

If FIndFunction ("U_REINP13")
	cQuery := U_REINP13()
EndIf

restArea (aArea)
return cQuery