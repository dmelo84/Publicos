#INCLUDE 'PROTHEUS.CH'
#INCLUDE 'TBICONN.CH'


/*
MT120APV
Troca grupo de aprovacao no ato da geracao do pedido na tela de analise de cotacao

@author 
@since 09/12/2014
@version 1.0
*/
User Function MT120APV()
Local aArea := GetArea()
Local cRet := SC7->C7_APROV //aqui retornamos o conteudo ja existente no C7_APROV, mas ´será no PE AVALCOT que iremos setar o C7_APROV com o grupo de aprovacao que realmente ser ausado

//If IsInCallStack("MATA250")
If PARAMIXB != Nil
	
	If FindFunction("U_ALCOM06")
		U_ALCOM06(PARAMIXB[2])
	EndIf
EndIf

RestArea(aArea)
Return cRet

