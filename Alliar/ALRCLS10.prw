#INCLUDE "PROTHEUS.CH"
//-------------------------------------------------------------------
/*{Protheus.doc} ALRCLS10
Funcao Generica para Compilacao

@author Guilherme Santos
@since 29/07/2016
@version P12
*/
//-------------------------------------------------------------------
User Function ALRCLS10()
Return NIL
//-------------------------------------------------------------------
/*{Protheus.doc} ResPedVenda
Eliminacao dos Residuos do Pedido de Venda

@author Guilherme Santos
@since 29/07/2016
@version P12
*/
//-------------------------------------------------------------------
Class ResPedVenda
	Data cPedido
	Data cMensagem

	Method New(cPedido) Constructor
	Method Gravacao()
	Method GetMensagem()
EndClass
//-------------------------------------------------------------------
/*{Protheus.doc} New
Construtor do Objeto

@author Guilherme Santos
@since 29/07/2016
@version P12
*/
//-------------------------------------------------------------------
Method New(cPedido) Class ResPedVenda
	::cPedido := cPedido
Return Self
//-------------------------------------------------------------------
/*{Protheus.doc} Gravacao
Gravacao da Eliminacao de Residuos

@author Guilherme Santos
@since 29/07/2016
@version P12
*/
//-------------------------------------------------------------------
Method Gravacao() Class ResPedVenda
	Local aArea		:= GetArea()
	Local aAreaSC5	:= SC5->(GetArea())
	Local aAreaSC6	:= SC6->(GetArea())
	Local aAreaSC9	:= SC9->(GetArea())
	Local lRetorno 	:= .T.

	Begin Transaction

		DbSelectArea("SC5")
		DbSetOrder(1)		//C5_FILIAL, C5_NUM

		If SC5->(DbSeek(xFilial("SC5") + ::cPedido))
			DbSelectArea("SC6")
			DbSetOrder(1)			//C6_FILIAL, C6_NUM, C6_ITEM

			If SC6->(DbSeek(xFilial("SC6") + SC5->C5_NUM))
				While !SC6->(Eof()) .AND. xFilial("SC6") + SC5->C5_NUM == SC6->C6_FILIAL + SC6->C6_NUM

					If !MaResDoFat(SC6->(Recno()), .T., .T.)
						lRetorno 	:= .F.
						::cMensagem := "Erro durante a Eliminação dos Residuos do Item " + SC6->C6_ITEM + " do Pedido " + SC5->C5_NUM
						DisarmTransaction()
						Exit
					EndIf

					SC6->(DbSkip())
				End
			EndIf
		EndIf

	End Transaction

	RestArea(aAreaSC9)
	RestArea(aAreaSC6)
	RestArea(aAreaSC5)
	RestArea(aArea)
Return lRetorno
//-------------------------------------------------------------------
/*{Protheus.doc} GetMensagem
Retorno das Mensagens de Erro

@author Guilherme Santos
@since 29/07/2016
@version P12
*/
//-------------------------------------------------------------------
Method GetMensagem() Class ResPedVenda
Return ::cMensagem
