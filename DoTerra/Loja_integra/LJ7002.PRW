#include 'protheus.ch'
#include 'parmtype.ch'

/*------------------------------------------------------
|Ponto de Entrada - Gravação de campo na SC5 depois da  |
|efetivação da venda                                    |
|Desenvolvedor Diogo Melo                               |
|Data: 06/05/2019                                       |
--------------------------------------------------------*/

User Function LJ7002

	Local cQuery  := ''
	Local lRet := .F.
	Local nRecSC5 := 0

	dbSelectArea("SC5")

	If SC5->(MsSeek(xFilial("SL1") + SL1->L1_PEDIDO)) .and. !Empty(SL1->L1_TIPO)

		nRecSC5 := SC5->(RECNO())

		RecLock("SC5", .F.)
		SC5->C5_NOTA   := STRZERO(VAL(SL1->L1_DOC),9)
		SC5->C5_SERIE  := SL1->L1_SERIE
		SC5->C5_ORIGEM := "LOJA7002"
		SC5->C5_OK     := "OK"
		SC5->C5_P_STFED := "13"
		MsUnlock()

		dbSelectArea("SC6")

		cQuery += " SELECT C6_FILIAL, C6_NUM, C6_ITEM, C6_PRODUTO, C6_NOTA, C6_SERIE, R_E_C_N_O_ as nRecSC "
		cQuery += " FROM "+ RetSqlName("SC6") +" SC6 "
		cQuery += " WHERE D_E_L_E_T_ <> '*' "
		cQuery += " AND C6_FILIAL = '"+xFilial("SL1")+"' " 
		cQuery += " AND C6_NUM = '"+SL1->L1_PEDIDO+"' "

		cQuery := ChangeQuery(cQuery)
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"cAliasSC6", .F., .T.)

		While cAliasSC6->(!Eof())
			SC6->(dbgoto(cAliasSC6->nRecSC))

			nPosItem := aScan(aCols,{ |x| Upper(AllTrim(x[1])) == alltrim(cAliasSC6->C6_ITEM)   })
			nPosProd := aScan(aCols,{ |x| Upper(AllTrim(x[2])) == alltrim(cAliasSC6->C6_PRODUTO)})
			cPOk := aCols[nPosProd][26]

			If cPOk > 0

				IF /*Qtd Lida*/cPOk == SC6->C6_QTDVEN
					RecLock("SC6", .F.)
					SC6->C6_NOTA  := STRZERO(VAL(SL1->L1_DOC),9)
					SC6->C6_SERIE := SL1->L1_SERIE
					MsUnlock()
				Else
					SC5->(dbGoto(nRecSC5))
					Reclock("SC5",.F.)
					SC5->C5_NOTA := ' '
					SC5->C5_OK   := 'PA'
					SC5->C5_MKOK := ' '
					MsUnlock()
				EndIf
			Else
				Alert("Itens não separados")
				lRet := .F.
				Return
			EndIf

			cAliasSC6->(dbSkip())

		EndDo
		cAliasSC6->(dbCloseArea())
		lRet := .T.
	Else
		Conout("PE - LJ7002 -> Importação de pedidos")
		lRet := .F.
	EndIf
	SC5->(dbCloseArea())
	SC6->(dbCloseArea())

Return lRet