#INCLUDE "TOTVS.CH"

Static lProc := .T.

User Function setLproc()
	lProc := .F.
Return Nil


// P.E Validacao Ped Venda
User Function MT410TOK()	
	Local lRet := .T.	

	//Gravacao do Valor Liquido do Item do Pedido
	SetVlrLiq()

	If lProc	
		lRet := U_ALRFAT02()			 // Executa Funcao p/ Informar Valores dos Tributos Retidos
	Endif

Return lRet
//-------------------------------------------------------------------
/*{Protheus.doc} SetVlrLiq
Gravacao do Valor Liquido do Item do Pedido

@author Guilherme Santos
@since 12/08/2016
@version P12
*/
//-------------------------------------------------------------------
Static Function SetVlrLiq()
	Local nItem		:= 0
	Local nPosDel		:= Len(aHeader) + 1
	Local nPosVlr		:= Ascan(aHeader, {|x| AllTrim(x[02]) == "C6_XVLRLIQ"})
	Local nPosTot		:= Ascan(aHeader, {|x| AllTrim(x[02]) == "C6_VALOR"})
	Local lLiquido	:= If(SC5->(FieldPos("C5_XBRTLIQ")) > 0, M->C5_XBRTLIQ == "L", .F.)
	
	//So Executa na Execauto do Pedido gerado atraves do Web Service
	If l410Auto .AND. lLiquido .AND. nPosVlr > 0
		For nItem := 1 to Len(aCols)
			If !aCols[nItem][nPosDel]
				aCols[nItem][nPosVlr] := aCols[nItem][nPosTot]
			EndIf
		Next nItem 
	EndIf

Return NIL
