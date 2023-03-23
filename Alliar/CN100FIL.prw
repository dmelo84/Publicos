#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TBICONN.CH'
#include "FILEIO.CH"     


/*
cn100fil
adiciona rotina para assinar contrato ao menu


@author 
@since 09/12/2014
@version 1.0
*/
User Function CN100FIL()

If FindFunction("U_GCT03ASS")
	U_GCT03ASS()
EndIf

    
Return .T.

