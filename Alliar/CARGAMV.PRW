#INCLUDE 'PROTHEUS.CH'
#INCLUDE "FWMVCDEF.CH"
//-------------------------------------------------------------------
/*{Protheus.doc} CARGAMV
Guardar valor do M->xcdmarc para usar no filtro das unidades

@author Itamar Gama.:
@since 08/01/2017
@version P12
*/
//-------------------------------------------------------------------
User Function CARGAMV()


If MV_PAR60 <> Alltrim(M->UC_XCDMARC)
	MV_PAR60:=Alltrim(M->UC_XCDMARC)
Endif	

Return(MV_PAR60)

