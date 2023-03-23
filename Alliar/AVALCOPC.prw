#INCLUDE "PROTHEUS.CH"
//-------------------------------------------------------------------------------------------------
/*{Protheus.doc} AVALCOPC
Ponto de Entrada no Final da Geracao do Pedido de Compra a partir da Analise da Cotacao de Compra

@author Guilherme Santos
@since 05/03/2016
@version P12
*/
//-------------------------------------------------------------------------------------------------
User Function AVALCOPC()
	Local aArea		:= GetArea()
	Local aAreaSC7 	:= SC7->(GetArea())

	Private INCLUI := .T.

	//O Pedido de Compra esta posicionado na Chamada do Ponto de Entrada

	U_MT120FIM()

	RestArea(aAreaSC7)
	RestArea(aArea)
	
Return NIL
