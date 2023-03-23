#Include 'Protheus.ch'

/*-----------------------------------------------------------------
|Ponto de Entrada controle de DATA                                 |
|Na inclusão do documento de entrada é gerado um titulo no contas  |
|a pagar relizando a tratamento na condição de pagamento de acordo |
|com a regra estabelecida pelo cliente.                            |
|Desenvolvedor: Diogo Melo                                         |
|Data atualização: 15/07/2019                                      |
-------------------------------------------------------------------*/

User Function MT100GE2()

	Local aTitAtual   := PARAMIXB[1]
	Local nOpc        := PARAMIXB[2]
	Local aHeadSE2    := PARAMIXB[3]
	Local nX          := ParamIXB[4]
	Local aParcelas   := ParamIXB[5]
	Local cCondSF1    := GETNEWPAR("MV_TPCOND", "099|098")
	Local nPosTit     := Ascan(aHeadSE2,{|x| Alltrim(x[1]) == 'Vencimento'})
	
	If cCondicao $ cCondSF1
		If nOpc == 1 .and. cCondicao == alltrim(cCondSF1)
			//.. inclusao
			If CMONTH(aTitAtual[nPosTit]) <> CMONTH(date())
				SE2->E2_VENCREA := aTitAtual[nPosTit] - 3
				SE2->E2_VENCTO  := aTitAtual[nPosTit] - 3
				//SE2->E2_ORIGEM  := "MT100GE2"
			EndIf
		EndIf
	EndIf
Return