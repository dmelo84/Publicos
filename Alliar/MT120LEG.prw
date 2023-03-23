#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TBICONN.CH'
#include "FILEIO.CH"     


/*
MT120LEG
Legenda de Pedidos rejeitados exibido na tela do pedido de compra


@author 
@since 09/12/2014
@version 1.0
*/
User Function MT120LEG()
Local aRet := PARAMIXB[1]

If FindFunction("U_ALCOM03")
	aRet := U_ALCOM03(aRet)
EndIf

    
Return aRet

