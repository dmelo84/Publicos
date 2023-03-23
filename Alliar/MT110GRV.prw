#INCLUDE "RWMAKE.CH"
#include "protheus.ch"
//---------------------------------------------------------------------------------------
/*/{Protheus.doc} MT110GRV

Ponto de entrada gravar novo campo na tabela SC1

@author     totvs
@since     	15/09/2014
@version  	P.11
@obs        Nenhum
/*/
User Function MT110GRV()
Local aArea := GetArea()
	
If FindFunction("U_ALCO19")
	U_ALCO19()
EndIf

RestArea(aArea)
Return