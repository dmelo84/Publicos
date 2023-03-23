#INCLUDE "PROTHEUS.CH"


 /*
 
O ponto de entrada MT120PCOK é utilizado para validar a inclusão do pedido de compra (MATA120) após a confirmação do formulário.

* inicialmente para criar variavel publica e controlar o que foi modificado no pedido - projeto ABAX  - HFP - Compila

 */
User Function MT120PCOK()

	Local aAreaSC7 := SC7->(GetArea())
	Local lRet := .T.
	Local nOper := PARAMIXB[1]
	Local cXPedido:= SC7->C7_NUM
	Local aEstrSC7:= {}
	Local jj

	Public aMudAbax:={}   // Variavel publica para ter seu valor "lido", no ponto entrada MT120FIM

	If nOper == 2 //-- 1 = Chamada via A120LINOK, 2 = Chamada via A120TUDOK


		SC7->(dbSetOrder(1))
		SC7->(dbSeek(xFilial("SC7") + cXPedido) )

		aEstrSC7:= SC7->(dbStruct())
		nStru:=Len(aEstrSC7)

		While !SC7->(Eof()) .AND. xFilial("SC7") + cXPedido == SC7->C7_FILIAL + SC7->C7_NUM

			AADD(aMudAbax,{})

			For jj:=1 to nStru

				AADD(aMudAbax[len(aMudAbax)], {sc7->(FieldName(jj)), sc7->(FieldGet(jj)) } )

			NEXT

			SC7->(DbSkip())
		ENDDO

		RestArea(aAreaSC7)

	ENDIF

Return lRet
