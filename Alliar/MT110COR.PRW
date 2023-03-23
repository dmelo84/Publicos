#Include "Protheus.ch"

/*
MT110COR
//controle de legendas chamado na tela de solicitação de compras, MATA110

@author 
@since 09/12/2015
@version 1.0
*/

USER FUNCTION MT110COR() 
Local aRetCores := PARAMIXB[1]
Local aArea     := GetArea()
Local nIndAzul  := 0
Local nIndVerde := 0
Local nIndDisable := 0
Local cStr := ""
Local cStr1 := ""
Local cStr2 := ""
Local cStr3 := ""

Local nIndAmarelo := 0


nIndAzul     := aScan( aRetCores, { | x | x[2] == "BR_AZUL" } )
nIndVerde    := aScan( aRetCores, { | x | x[2] == "ENABLE" } )
nIndDisable  := aScan( aRetCores, { | x | x[2] == "DISABLE" } )
nIndAmarelo  := aScan( aRetCores, { | x | x[2] == "BR_AMARELO" } )

//Tratamento de legendas para integração BioNexo
If nIndAzul > 0 //Cor Azul será exibida para solicitações de compra Bionexo apos clicar em (ENVIAR)
	cStr1 := aRetCores[nIndAzul][1]
	cStr := "(" + aRetCores[nIndAzul][1] + '  .AND. C1_XSTABIO<>"2" ) ' + ' .OR. (C1_XNUMPDC <> "" .AND. (C1_XSTABIO="1"      )   ) ' 
	aRetCores[nIndAzul][1] :=   cStr
EndIf


If nIndVerde > 0 //cor verde
	cStr2 := aRetCores[nIndVerde][1]                                                               //3 = cancelou o envio para o bionexo   0 = ainda nao enviou ao bionexo
	cStr :=  aRetCores[nIndVerde][1] + "" + ' .AND. (C1_XNUMPDC = Space(Len(C1_XNUMPDC)) .AND. (C1_XSTABIO="3" .OR. C1_XSTABIO="0" .OR. C1_XSTABIO = Space(Len(C1_XSTABIO)) )          ) ' 
	aRetCores[nIndVerde][1] :=   cStr

EndIf

If nIndDisable > 0 //Cor VERMELHA (totalmente atendido) será exibida para Solicitações de compras bionexo (após clicarmos no botão RETORNAR)
	cStr3 := aRetCores[nIndDisable][1]
	cStr :=  "(" + aRetCores[nIndDisable][1] + ")" + ' .OR. (C1_XNUMPDC <> "" .AND. C1_XSTABIO="2") ' 
	aRetCores[nIndDisable][1] :=   cStr
	
EndIf

/*sem uso:
If nIndAmarelo > 0 //Cor AMARELA (parcialmente atendido) será exibida para Solicitações de compras bionexo (após clicarmos no botão RETORNAR)
	cStr3 := aRetCores[nIndAmarelo][1]
	cStr :=  "(" + aRetCores[nIndAmarelo][1] + ")" + ' .OR. (C1_XNUMPDC <> "" .AND. C1_XSTABIO="2") ' 
	aRetCores[nIndAmarelo][1] :=   cStr
	
EndIf
*/
	
restArea(aArea)
return aRetCores