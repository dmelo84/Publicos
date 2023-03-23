#Include "Totvs.ch"

/*
MT120APV
imPEDE GRAVAR PEDIDO COM ITENS DE DIFERENTES GRUPOS DE APROVACAO 

LOCALIZAÇÃO : Function A120TudOk() responsável pela validação de todos os itens 
da GetDados do Pedido de Compras / Autorização de Entrega.

EM QUE PONTO : O ponto se encontra no final da função e é disparado após a confirmação 
dos itens da getdados e antes do rodapé da dialog do PC, deve ser utilizado para 
validações especificas do usuario onde será controlada pelo retorno do ponto de 
entrada oqual se for .F. o processo será interrompido e se .T. será validado.

@author 
@since 09/12/2014
@version 1.0
*/


User Function MT120OK()
Local lRet := .T.
Local nI   := 0
Local aArea		:= GetArea()

//| Alterado por Fabio Sales em 20170615.
//| Limpa o campo ID do Fluig quando o pedido  for originado de uma cópia.

IF lCop

	For nI:= 1 To Len(aCols)
	
		aCols[nI][aScan(aHeader,{|x| AllTrim(x[2]) == 'C7_XIDFLG'})] := ""
		
	Next nI
	
ENDIF

If FindFunction("U_ALCOM07")

	lRet := U_ALCOM07()
	
EndIf
	
RestArea(aArea)
	
Return lRet
