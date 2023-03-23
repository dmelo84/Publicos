#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TBICONN.CH'


/*
MT130IFR - 
fILTRA POR GRUPOS DE APROVACAO AS SOLICITAÇOES DE COMPRA QUE SERAO USADAS NA COTACAO


@author 
@since 09/12/2014
@version 1.0
*/
User Function MT130IFR()
Local aArea := GetARea()
Local aRet := {}

If FindFunction("U_ALCOM9")
	aRet := U_ALCOM9()
EndIf

RestArea(aArea)  
Return aRet 