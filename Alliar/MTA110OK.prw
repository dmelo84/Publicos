#INCLUDE "RWMAKE.CH"
#include "protheus.ch"
//---------------------------------------------------------------------------------------
/*/{Protheus.doc} MTA110OK

tudo ok da tela SC1

@since     	15/09/2014
@version  	P.11
@obs        Nenhum
/*/
User Function MTA110OK()
Local aArea := GetArea()
Local lRet := .T.

If FindFunction("U_ALCO17")   

	If !l110Auto
		
		lRet := U_ALCO17()
	else/*
		dbselectarea('SZ8')
		reclock('SZ8',.T.)
		SZ8->Z8_CONTA := '79'
		SZ8->Z8_USER   := AllTrim(PARAMIXB[2]) + '>' + PARAMIXB[1]
		MsUnLock()*/
	
		lRet := U_ALCO20(PARAMIXB[2])
	
	EndIf
EndIf
	
restarea(aArea)
Return(lRet)