#INCLUDE 'PROTHEUS.CH'
#INCLUDE "FWMVCDEF.CH"
//-------------------------------------------------------------------
/*{Protheus.doc} ALDESUNI
Guardar valor do M->xcdmarc para usar no filtro das unidades

@author Itamar Gama.:
@since 08/01/2016
@version P12
*/
//-------------------------------------------------------------------

User Function ALDESUNI()
Local aAreaSM0:= GetAre("SM0")
Local cDescFil:=''

DbSelectArea("SM0")
DbSetOrder(1)

If SM0->(DbSeek(cEmpAnt + M->UC_XCODUNI))
	cDescFil	:= SM0->M0_FILIAL
EndIf

RestArea(aAreaSM0)

Return(cDescFil)