#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} M040SE1
//Ponto de entrada na gravacao dos titulos a receber para     
//gravacao de campos complementares                          
@author Telso Carneiro
@since 11/05/2019
@version 1.0
@return ${return}, ${return_description}
@type function
/*/
user function M040SE1()
	Local C5GetArea := SC5->(GetArea())
	Local nTaxa     := 0
	
	Local cQry := ""
	Local nX := 0
	Local cCfop := SUPERGETMV("MV_XVALCF",.T.,"5910|6910" )
	Local aFiltro := STRTOKARR(cCfop, "|")
	Local cPedido := SC5->C5_NUM
	Local cFiltro := ''
	Local nValFrete := 0
	Local aParcela := {}
	
	If Empty(SE1->E1_P_DTRAX)
		SC5->(dbSetOrder(1))
		If SC5->(MsSeek(xFilial("SC5")+SE1->E1_PEDIDO))
		
			nTaxa := 0
			SAE->(DbSetorder(1))
				if SAE->(DbSeek(xFilial("SAE")+SC5->C5_P_BAND))
					nTaxa := (SAE->AE_TAXA/100)
				endif 
			RecLock("SE1",.F.)	
			SE1->E1_P_DTRAX := SC5->C5_P_DTRAX
			SE1->E1_P_WLDPA := SC5->C5_P_WLDPA
			SE1->E1_P_BAND  := SC5->C5_P_BAND
			SE1->E1_P_TIPAG := SC5->C5_P_TIPAG
			
				if nTaxa > 0
					SE1->E1_DECRESC := ROUND(SE1->E1_VALOR*nTaxa,2)
				endif
				
				MsUnlock()
		ENDIF
	EndIf
			
		If !Empty(SC5->C5_FRETE) .or. SC5->C5_FRETE > 0

		If Empty(cCfop)
				HELP('MV_XVALCF',1,"Erro Cadastro",,"Parametro MV_XVALCF não cadastro",2,0,,,,,,"O Parametro é responsavel pelo filtro do CFOP que será considerado no calculo do frete EX:. 5910|6910 ")
				SC5->(RestArea(C5GetArea))
				RETURN
		ENDIF

			If Len(aFiltro) > 0
				If Empty(cFiltro)
				cFilQry	:= ""
					For nX  := 1 To Len(aFiltro)
						If Empty( cFilQry )
						cFilQry +="("
						Else
						cFilQry += ","
						Endif
						cFilQry += "'" + Alltrim(aFiltro[nX]) +"'"
					Next nX
				cFilQry+=")"
				cFiltro := cFilQry
				EndIf
			ENDIF
			
			cQry := " Select SUM (D2_VALFRE) As VlFrete from " +RetSqlName("SD2")+ " SD1 "
			cQry += " Where D_E_L_E_T_ <> '*' "
			cQry += " AND D2_FILIAL = '"+cFilAnt+"'"
			cQry += " AND D2_PEDIDO = '"+cPedido+"'"
			cQry += " AND D2_CF IN "+ cFiltro
			
			cQry := ChangeQuery( cQry )
			cInd1:= CriaTrab(Nil,.F.)

			dbUseArea(.T.,'TOPCONN',TcGenQry(,,cQry),'SD1TMP',.T.,.T.)

			dbSelectArea("SD1TMP")
			While SD1TMP->(!eof())

			nValFrete += SD1TMP->VlFrete

			SD1TMP->(dbSkip())
			ENDDO

			SD1TMP->(dbCloseArea())

			If nValFrete > 0
			aParcela := Condicao(SF2->F2_VALMERC,SC5->C5_CONDPAG,,SC5->C5_EMISSAO,)
			nParcela := Len(aParcela)

			nFrtSoma := nValFrete / nParcela
			nSE2Valor := SE1->E1_VALOR + nFrtSoma

			Reclock("SE1",.F.)
				REPLACE E1_VALOR WITH nSE2Valor
				REPLACE E1_SALDO WITH nSE2Valor
				REPLACE E1_VLCRUZ WITH nSE2Valor
				//REPLACE E1_ORIGEM WITH "M040SE1"
			MsUnlock()

			SC5->(RestArea(C5GetArea))
			else
				SC5->(RestArea(C5GetArea))
				RETURN
			ENDIF

		EndIf	
return