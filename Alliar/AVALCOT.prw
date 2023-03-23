#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TBICONN.CH'


/*
MT120APV
Troca grupo de aprovacao no ato da geracao do pedido na tela de analise de cotacao


@author 
@since 09/12/2014
@version 1.0
*/
User Function AVALCOT()
Local aArea := GetARea()
Local nEvento := PARAMIXB[1]

If nEvento == 4
	
	If FindFunction("U_ALCO12")
		U_ALCO12()
	EndIf
EndIf

RestArea(aArea)  
Return 

