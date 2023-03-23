#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TBICONN.CH'


/*
MT120COR
Legenda de Pedidos rejeitados


@author 
@since 09/12/2014
@version 1.0
*/
User Function MT120COR()
Local aRet := PARAMIXB[1]

Local aArea		:= GetArea()

If FindFunction("U_ALCOM02")
	aRet := U_ALCOM02(aRet)
EndIf

restArea(aArea)    
Return aRet

