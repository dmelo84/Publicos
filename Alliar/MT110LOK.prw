#INCLUDE "RWMAKE.CH"
#include "protheus.ch"
//---------------------------------------------------------------------------------------
/*/{Protheus.doc} MT110LOK

Ponto de entrada Altera as coordenadas de Array e redimensiona a dialog da SC

@author    totvs
@since     	15/09/2014
@version  	P.11
@obs        Nenhum
/*/
User Function MT110LOK()
Local aArea := GetArea()
Local lRet := PARAMIXB[1]
	
If FindFunction("U_ALCO18")  .And. !l110Auto
	lRet := U_ALCO18(PARAMIXB)
EndIf

restarea(aArea)
Return(lRet)