#Include "Totvs.ch"

/*
MT120APV
imPEDE GRAVAR PEDIDO COM ITENS DE DIFERENTES GRUPOS DE APROVACAO 

LOCALIZA��O : Function A120TudOk() respons�vel pela valida��o de todos os itens 
da GetDados do Pedido de Compras / Autoriza��o de Entrega.

EM QUE PONTO : O ponto se encontra no final da fun��o e � disparado ap�s a confirma��o 
dos itens da getdados e antes do rodap� da dialog do PC, deve ser utilizado para 
valida��es especificas do usuario onde ser� controlada pelo retorno do ponto de 
entrada oqual se for .F. o processo ser� interrompido e se .T. ser� validado.

@author 
@since 09/12/2014
@version 1.0
*/


User Function MT120OK()
Local lRet := .T.
Local nI   := 0
Local aArea		:= GetArea()

//| Alterado por Fabio Sales em 20170615.
//| Limpa o campo ID do Fluig quando o pedido  for originado de uma c�pia.

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
