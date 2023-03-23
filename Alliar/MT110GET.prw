#INCLUDE "RWMAKE.CH"
#include "protheus.ch"
//---------------------------------------------------------------------------------------
/*/{Protheus.doc} MT110GET

Ponto de entrada para aumentar o espaço do cabeçalho da tela SC1

@author     totvs
@since     	15/09/2014
@version  	P.11
@obs        Nenhum
/*/

User Function MT110GET()
Local aArea := GetArea()
Local aRet:= PARAMIXB[1]
	
If FindFunction("U_ALCO16")
	U_ALCO16(aRet)
EndIf


restarea(aArea)	
Return(aRet)