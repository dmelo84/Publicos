#Include "PROTHEUS.Ch"
 #INCLUDE "RWMAKE.CH"
 #INCLUDE "TOPCONN.CH"

/*/{Protheus.doc} RFIN004
Relatório de fluxo de caixa por natureza.
@author Fabio Sales | www.compila.com.br

@version 1
@see (www.compila.com.br)
/*/


User Function RFIN004()
	Local oReport
	If TRepInUse()	//verifica se relatorios personalizaveis esta disponivel
		oReport := ReportDef()
		oReport:PrintDialog()
	EndIf
Return


/*/{Protheus.doc} ReportDef
FUNCAO PRINCIPAL D EIMPRESSÀO
@author Fabio Sales | www.compila.com.br
@since 12/10/2016
@version 1
@see (www.compila.com.br)
/*/

Static Function ReportDef()

	Local oReport
	Local oSection
	Private cPerg     := "RFIN004"
	Private nDias	  := 0

	ValPerg(cPerg)

	Pergunte(cPerg,.T.,"FLUXO DE CAIXA")



	IF MV_PAR08 == 2 //| Relatório diários

		nDias := DateDiffDay(mv_par05,mv_par06)

	 	While  nDias > 30 .OR. mv_par05 > mv_par06

	  		If (mv_par05 > mv_par06)

	  			Aviso("RFIN004","O parametro data de, deve ser menor que o data ate: ",{"OK"},1)

			ElseIf nDias > 30

				Aviso("RFIN004","Só é permitido período de até 31 dias",{"OK"},1)

		 	EndIf

		  	Pergunte(cPerg,.T.,"PONTO DE PEDIDO")

		  	nDias := DateDiffDay(mv_par05,mv_par06)

		EndDo

	ENDIF

	oReport := TReport():New("RFIN004","FLUXO DE CAIXA POR NATUREZA","",{|oReport| PrintReport(oReport)},"IMPRESSAO DO FLUXO DE CAIXA POR NATUREZA")
	oSection1 := TRSection():New(oReport,OemToAnsi("MOVIMENTAÇÕES"),{"FCAIXA"})


	If mv_par09 == 1 //Analítico

		TRCell():New(oSection1,"FILIAL"			,"FCAIXA"	,"FILIAL"		,"@!",15)
		TRCell():New(oSection1,"DATA"			,"FCAIXA"	,"DATA"			,"",10)
		TRCell():New(oSection1,"LOTE"			,"FCAIXA"	,"LOTE"			,"",10)
		TRCell():New(oSection1,"XIDFLG"			,"FCAIXA"	,"ID FLUIG"		,"@!",30)
		TRCell():New(oSection1,"PREFIXO"		,"FCAIXA"	,"PREFIXO"		,"@!",03)
		TRCell():New(oSection1,"NUMERO"			,"FCAIXA"	,"NUMERO"		,"@!",09)
		TRCell():New(oSection1,"PARCELA"		,"FCAIXA"	,"PARCELA"		,"@!",02)
		TRCell():New(oSection1,"TIPO"			,"FCAIXA"	,"TIPO TIT."	,"@!",03)
		TRCell():New(oSection1,"ORIEN"			,"FCAIXA"	,"TIPO"			,"@!",10)

		TRCell():New(oSection1,"CLIFOR"			,"FCAIXA"	,"CLIE/FORNEC"	,"@!",12)
		TRCell():New(oSection1,"LOJA"			,"FCAIXA"	,"LOJA"			,"@!",08)
		TRCell():New(oSection1,"BENEF"			,"FCAIXA"	,"NOME"			,"@!",35)

		TRCell():New(oSection1,"NATUREZA"		,"FCAIXA"	,"COD. NAT"		,"@!",10)
		TRCell():New(oSection1,"DESCRI"			,"FCAIXA"	,"NATUREZA"		,"@!",20)
		TRCell():New(oSection1,"VALPER"			,"FCAIXA"	,"VALOR"        ,"@E 999,999,999.99",30)

		oSection2 := TRSection():New(oSection1,"TOTAL POR FILIAL E GRUPO","FCAIXA")

		TRCell():New(oSection2	,"SALDANT"		,"FCAIXA"	,"SALDO ANTERIOR"	,"@E 999,999,999.99",14)
		TRCell():New(oSection2	,"SALDPER"		,"FCAIXA"	,"SALDO PERIODO"	,"@E 999,999,999.99",14)
		TRCell():New(oSection2	,"SALDO"		,"FCAIXA"	,"SALDO"			,"@E 999,999,999.99",14)

	Else // Sintético

		IF MV_PAR08 == 1

			TRCell():New(oSection1,"FILIAL"			,"FCAIXA"	,"FILIAL"		,"@!",15)
			TRCell():New(oSection1,"TIPO"			,"FCAIXA"	,"TIPO"			,"@!",10)
			TRCell():New(oSection1,"NATUREZA"		,"FCAIXA"	,"COD. NAT"		,"@!",10)
			TRCell():New(oSection1,"DESCRI"			,"FCAIXA"	,"NATUREZA"		,"@!",20)
			TRCell():New(oSection1,"VALPER"			,"FCAIXA"	,"PERIODO DE " + dtocy(mv_Par05) +" A " + dtocy(mv_Par06) ,"@E 999,999,999.99",30)

			oSection2 := TRSection():New(oSection1,"TOTAL POR FILIAL E GRUPO","FCAIXA")

			TRCell():New(oSection2,"TIPO"			,"FCAIXA"	,"TIPO"		,"@!",10)
			TRCell():New(oSection2,"TOTGRP"			,"FCAIXA"	,"TOTAL"	,"@E 999,999,999.99",14)

			oSection3 := TRSection():New(oSection2,"TOTAL GERAL","FCAIXA")

			TRCell():New(oSection3	,"SALDANT"		,"FCAIXA"	,"SALDO ANTERIOR"	,"@E 999,999,999.99",14)
			TRCell():New(oSection3	,"SALDPER"		,"FCAIXA"	,"SALDO PERIODO"	,"@E 999,999,999.99",14)
			TRCell():New(oSection3	,"SALDO"		,"FCAIXA"	,"SALDO"			,"@E 999,999,999.99",14)

		ELSE


			TRCell():New(oSection1	,	"FILIAL"		,"FCAIXA"	,"FILIAL"		,"@!"	,10)
			TRCell():New(oSection1	,	"GRUPO"			,"FCAIXA"	,"GRUPO	"		,"@!"	,10)
			TRCell():New(oSection1	,	"NATUREZA"		,"FCAIXA"	,"COD. NAT"		,"@!"	,10)
			TRCell():New(oSection1	,	"DESCRI"		,"FCAIXA"	,"NATUREZA"		,"@!"	,10)

			nconta := 0

			clData := MV_PAR05

			IF nconta <= nDias
				nconta++
				TRCell():New(oSection1,"D1"		,"FCAIXA",dtocy(clData),"@E 999,999,999.99",30)
			ENDIF

			clData := DaySum(clData,1)

			IF nconta <= nDias
				nconta++
				TRCell():New(oSection1,"D2"		,"FCAIXA",dtocy(clData),"@E 999,999,999.99",30)
			ENDIF

			IF nconta <= nDias
				nconta++
				clData := DaySum(clData,1)
				TRCell():New(oSection1,"D3"		,"FCAIXA",dtocy(clData),"@E 999,999,999.99",30)
			ENDIF

			IF nconta <= nDias
				nconta++
				clData := DaySum(clData,1)
				TRCell():New(oSection1,"D4"		,"FCAIXA",dtocy(clData),"@E 999,999,999.99",30)
			ENDIF

			IF nconta <= nDias
				nconta++
				clData := DaySum(clData,1)
				TRCell():New(oSection1,"D5"		,"FCAIXA",dtocy(clData),"@E 999,999,999.99",30)
			ENDIF

			IF nconta <= nDias
				nconta++
				clData := DaySum(clData,1)
				TRCell():New(oSection1,"D6"		,"FCAIXA",dtocy(clData),"@E 999,999,999.99",30)
			ENDIF
			IF nconta <= nDias
				nconta++
				clData := DaySum(clData,1)
				TRCell():New(oSection1,"D7"		,"FCAIXA",dtocy(clData),"@E 999,999,999.99",30)
			ENDIF
			IF nconta <= nDias
				nconta++
				clData := DaySum(clData,1)
				TRCell():New(oSection1,"D8"		,"FCAIXA",dtocy(clData),"@E 999,999,999.99",30)
			ENDIF
			IF nconta <= nDias
				nconta++
				clData := DaySum(clData,1)
				TRCell():New(oSection1,"D9"		,"FCAIXA",dtocy(clData),"@E 999,999,999.99",30)
			ENDIF
			IF nconta <= nDias
				nconta++
				clData := DaySum(clData,1)
				TRCell():New(oSection1,"D10"	,"FCAIXA",dtocy(clData),"@E 999,999,999.99",30)
			ENDIF
			IF nconta <= nDias
				nconta++
				clData := DaySum(clData,1)
				TRCell():New(oSection1,"D11"	,"FCAIXA",dtocy(clData),"@E 999,999,999.99",30)
			ENDIF
			IF nconta <= nDias
				nconta++
				clData := DaySum(clData,1)
				TRCell():New(oSection1,"D12"	,"FCAIXA",dtocy(clData),"@E 999,999,999.99",30)
			ENDIF

			IF nconta <= nDias
				nconta++
				clData := DaySum(clData,1)
				TRCell():New(oSection1,"D13" 	,"FCAIXA",dtocy(clData),"@E 999,999,999.99",30)
			ENDIF
			IF nconta <= nDias
				nconta++
				clData := DaySum(clData,1)
				TRCell():New(oSection1,"D14"	,"FCAIXA",dtocy(clData),"@E 999,999,999.99",30)
			ENDIF
			IF nconta <= nDias
				nconta++
				clData := DaySum(clData,1)
				TRCell():New(oSection1,"D15"	,"FCAIXA",dtocy(clData),"@E 999,999,999.99",30)
			ENDIF
			IF nconta <= nDias
				nconta++
				clData := DaySum(clData,1)
				TRCell():New(oSection1,"D16"	,"FCAIXA",dtocy(clData),"@E 999,999,999.99",30)
			ENDIF
			IF nconta <= nDias
				nconta++
				clData := DaySum(clData,1)
				TRCell():New(oSection1,"D17"	,"FCAIXA",dtocy(clData),"@E 999,999,999.99",30)
			ENDIF
			IF nconta <= nDias
				nconta++
				clData := DaySum(clData,1)
				TRCell():New(oSection1,"D18"	,"FCAIXA",dtocy(clData),"@E 999,999,999.99",30)
			ENDIF
			IF nconta <= nDias
				nconta++
				clData := DaySum(clData,1)
				TRCell():New(oSection1,"D19"	,"FCAIXA",dtocy(clData),"@E 999,999,999.99",30)
			ENDIF
			IF nconta <= nDias
				nconta++
				clData := DaySum(clData,1)
				TRCell():New(oSection1,"D20"	,"FCAIXA",dtocy(clData),"@E 999,999,999.99",30)
			ENDIF
			IF nconta <= nDias
				nconta++
				clData := DaySum(clData,1)
				TRCell():New(oSection1,"D21"	,"FCAIXA",dtocy(clData),"@E 999,999,999.99",30)
			ENDIF
			IF nconta <= nDias
				nconta++
				clData := DaySum(clData,1)
				TRCell():New(oSection1,"D22"	,"FCAIXA",dtocy(clData),"@E 999,999,999.99",30)
			ENDIF

			IF nconta <= nDias
				nconta++
				clData := DaySum(clData,1)
				TRCell():New(oSection1,"D23"	,"FCAIXA",dtocy(clData),"@E 999,999,999.99",30)
			ENDIF
			IF nconta <= nDias
				nconta++
				clData := DaySum(clData,1)
				TRCell():New(oSection1,"D24"	,"FCAIXA",dtocy(clData),"@E 999,999,999.99",30)
			ENDIF
			IF nconta <= nDias
				nconta++
				clData := DaySum(clData,1)
				TRCell():New(oSection1,"D25"	,"FCAIXA",dtocy(clData),"@E 999,999,999.99",30)
			ENDIF
			IF nconta <= nDias
				nconta++
				clData := DaySum(clData,1)
				TRCell():New(oSection1,"D26"	,"FCAIXA",dtocy(clData),"@E 999,999,999.99",30)
			ENDIF
			IF nconta <= nDias
				nconta++
				clData := DaySum(clData,1)
				TRCell():New(oSection1,"D27"	,"FCAIXA",dtocy(clData),"@E 999,999,999.99",30)
			ENDIF
			IF nconta <= nDias
				nconta++
				clData := DaySum(clData,1)
				TRCell():New(oSection1,"D28"	,"FCAIXA",dtocy(clData),"@E 999,999,999.99",30)
			ENDIF
			IF nconta <= nDias
				nconta++
				clData := DaySum(clData,1)
				TRCell():New(oSection1,"D29"	,"FCAIXA",dtocy(clData),"@E 999,999,999.99",30)
			ENDIF
			IF nconta <= nDias
				nconta++
				clData := DaySum(clData,1)
				TRCell():New(oSection1,"D30"	,"FCAIXA",dtocy(clData),"@E 999,999,999.99",30)
			ENDIF
			IF nconta <= nDias
				nconta++
				clData := DaySum(clData,1)
				TRCell():New(oSection1,"D31"	,"FCAIXA",dtocy(clData),"@E 999,999,999.99",30)
			ENDIF

		ENDIF

	EndIf


Return oReport

/*/{Protheus.doc} PrintReport
FUNCAO RESPONSÁVEL PELA IMPRESSÃO DO RELATÓRIO
@author Fabio Sales | www.compila.com.br
@since 12/10/2016
@version 1
@see (www.compila.com.br)
/*/

Static Function PrintReport(oReport)

	Local clTipo	:= ""
	Local nTotfilg	:= 0
	Local nCount	:= 0
	Local grpNat	:= ""
	Local descNat	:= ""
	Local oSection1 := oReport:Section(1)
	Private nSaldoIni := 0


	MsAguarde({|| fSelDados()},"Selecionando Dados")

	If MV_PAR09 == 1 // Analítico
		FCAIXA->(DBGoTop())
		FCAIXA->( dbEval( {|| nCount++ } ) )
		FCAIXA->(DBGoTop())

		oSection2 := oReport:Section(1):Section(1) // Totalizador

		oReport:SetMeter(nCount)
		oSection1:Init()

		NSaldAnt := nSaldoIni
		nTotPer  := 0

		While  FCAIXA->(!Eof() )

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ8¿
			//³Não imprime as linhas com baixas canceladas. Executado para o analítico³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ8Ù
			/*
			If FCAIXA->LOTE <> ''
				If TemBxCanc(FCAIXA->PREFIXO + FCAIXA->NUMERO + FCAIXA->PARCELA + FCAIXA->TIPO + FCAIXA->CLIFOR + FCAIXA->LOJA + FCAIXA->SEQ)
					FCAIXA->(dbskip())
					loop
				EndIf
		    EndIf
		    */

			oSection1:PrintLine()

			nTotPer += FCAIXA->VALPER

			FCAIXA->(DbSkip())
			oReport:IncMeter()
		EndDo


		oSection2:Cell("SALDANT"):SetBlock( { || NSaldAnt } )
		oSection2:Cell("SALDPER"):SetBlock( { || nTotPer } )
		oSection2:Cell("SALDO"):SetBlock( { || NSaldAnt + nTotPer} )


		oSection2:Init()
		oSection2:PrintLine()
		oSection2:Finish()


		oSection1:Finish()

	Else // Sintético

		IF MV_PAR08==1
			oSection2 := oReport:Section(1):Section(1)
			oSection3 := oReport:Section(1):Section(1):Section(1)

			oSection2:Cell("TIPO"):SetBlock( { || clTipo } )
			oSection2:Cell("TOTGRP"):SetBlock( { || nTotfilg } )
		ELSE
			oSection1:Cell("GRUPO"):SetBlock( { || grpNat } )
			oSection1:Cell("DESCRI"):SetBlock( { || descNat } )
		ENDIF


		FCAIXA->(DBGoTop())
		FCAIXA->( dbEval( {|| nCount++ } ) )
		FCAIXA->(DBGoTop())

		oReport:SetMeter(nCount)

		NSaldAnt	:= 0
		nSaldPer	:= 0
		nTotRec		:= 0
		nTotPerd	:= 0

		IF 	MV_PAR08==2
			oSection1:Init()
		ENDIF

		While  !Eof()

			IF 	MV_PAR08==1
				oSection1:Init()
				clTipo		:= FCAIXA->TIPO
			ENDIF

			nTotfilg 	:= 0

			IF MV_PAR08 == 1

				While FCAIXA->(!Eof())  .AND. FCAIXA->TIPO == clTipo

					If oReport:Cancel()
						Exit
					EndIf

					oSection1:PrintLine()

					//NSaldAnt += FCAIXA->SALDO_ANT
					nTotfilg += FCAIXA->VALPER

					FCAIXA->(DbSkip())

					oReport:IncMeter()

				ENDDO
				NSaldAnt := nSaldoIni
				IF alltrim(clTipo) =="OUTRAS" .OR. alltrim(clTipo) =="RECEITA"

					nTotRec += nTotfilg

				ELSE

					nTotPerd += nTotfilg

				ENDIF

				oSection1:Finish()

				IF MV_PAR08==1
					oSection2:Init()
					oSection2:PrintLine()
					oSection2:Finish()
				ENDIF

			ELSE


				grpNat	:= Posicione("SED", 1, xFilial("SED") + FCAIXA->NATUREZA, "ED_COND")
				descNat := Posicione("SED", 1, xFilial("SED") + FCAIXA->NATUREZA, "ED_DESCRIC")

				IF grpNat=="R"
					grpNat := 'RECEITA'
				ELSEIF grpNat=="D"
					grpNat := 'DESPESA'
				ELSE
					grpNat := 'OUTRAS'
				ENDIF

				oSection1:PrintLine()
				FCAIXA->(DbSkip())
				oReport:IncMeter()

			ENDIF

		EndDo

		IF MV_PAR08	== 1

			oSection3:Cell("SALDANT"):SetBlock( { || NSaldAnt } )
			oSection3:Cell("SALDPER"):SetBlock( { || nSaldPer } )
			oSection3:Cell("SALDO"):SetBlock( { || NSaldAnt + nSaldPer} )

			nSaldPer := nTotRec - nTotPerd

			oSection3:Init()
			oSection3:PrintLine()
			oSection3:Finish()
		ELSE
			oSection1:Finish()
		ENDIF

	EndIf
Return

/*/{Protheus.doc} PrintReport
SELEÇÃO DOS DADOOS  PARA IMPRESSÃO
@author Fabio Sales | www.compila.com.br
@since 12/10/2016
@version 1
@see (www.compila.com.br)
/*/

Static Function fSelDados()
	Local _nJ
	Local _nI
	Local lSpbInUse := SpbInUse()
	Local clQuery 	:= ""
	Local nI		:= 0
	Local cTabela14 := FR470Tab14() // StaticCall(FINR470,FR470Tab14) //| REMOVIDO PARA COMPATIBILIDADE 12.1.33

	//***************
	//Busca contas
	//***************
	_aBancos := {}
	_cquery := ""
	_cquery += " SELECT A6_FILIAL, A6_COD, A6_AGENCIA, A6_NUMCON, A6_MOEDA "
	_cquery += " FROM 	" + RetSqlName("SA6")
	_cquery += " WHERE 	A6_FILIAL BETWEEN '"+SubStr(mv_par01,1,5)+"' AND '"+SubStr(mv_par02,1,5)+"' "
	//_cquery += " 	AND A6_COD NOT LIKE 'CX%' "
	_cquery += " 	AND D_E_L_E_T_ = ' ' "
	If Select("CTAS") > 0
		CTAS->(dbCloseArea())
	EndIf
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,_cQuery),"CTAS",.F.,.T.)

	While CTAS->(!EOF())
		aadd(_aBancos, {substr(CTAS->A6_FILIAL,1,5), CTAS->A6_COD, CTAS->A6_AGENCIA, CTAS->A6_NUMCON, CTAS->A6_MOEDA, mv_par05})
		CTAS->(dbSkip())
	EndDo
	CTAS->(dbCloseArea())

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Separa as contas para query³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	_cContas := ""
	AEval( _aBancos, { | x | _cContas += x[2] + x[3] + x[4] + "','" } )
	_cContas := StrTran("'" + _cContas + "'",",''","")

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³SALDOS INICIAIS³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nSaldoIni := 0
	_aAreaSM0 := SM0->(GetArea())
	SM0->(dbGoTop())
	SM0->(dbSetOrder(1))
	While SM0->(!EOF()) .And. SM0->M0_CODIGO == cEmpAnt
	If SM0->M0_CODFIL >= MV_PAR01 .And. SM0->M0_CODFIL <= MV_PAR02
		AEval( _aBancos, { | x | nSaldoIni += GetSldIni(Alltrim(SM0->M0_CODFIL), x[2], x[3], x[4], x[5], x[6]) } )
	EndIf
		SM0->(dbSkip())
	EndDo
	RestArea(_aAreaSM0)


	If Mv_PAR09 == 1 //Analítico

		//***************
		//Movimentos
		//***************
		clQuery += BaseData(_cContas) &&Edson Melo - Atenção ao realizar alteração nessa função, pois reflete em todos os relatórios (Analítico, Sintético Mensal e Sintético Diário)

	Else //Sintético


		IF MV_PAR08 == 1  // Sintético > Mensal

			//***************
			//Movimentos
			//***************

			clQuery := " SELECT FILIAL, TIPO, NATUREZA, DESCRI, SALDO_ANT, SUM(VALPER) * CASE TIPO WHEN 'DESPESAS' THEN -1 ELSE 1 END AS VALPER "+CRLF
			clQuery += " FROM ( "+CRLF

			clQuery += "       SELECT  FILIAL, "+CRLF
			clQuery += "               ORIEN TIPO, "+CRLF
			clQuery += "               NATUREZA, " +CRLF
			clQuery += "               DESCRI, " +CRLF
			clQuery += "               0 SALDO_ANT, "+CRLF
			clQuery += "               SUM(VALPER) AS VALPER

			clQuery += "       FROM ( " + CRLF
			clQuery +=                BaseData(_cContas) + CRLF &&Edson Melo - Atenção ao realizar alteração nessa função, pois reflete em todos os relatórios (Analítico, Sintético Mensal e Sintético Diário)
			clQuery += "       ) AS T2 " + CRLF
			clQuery += "       GROUP BY FILIAL, ORIEN, NATUREZA, DESCRI " + CRLF

			clQuery += " ) AS T GROUP BY FILIAL, TIPO, NATUREZA, DESCRI, SALDO_ANT " +CRLF
			clQuery += " ORDER BY TIPO, NATUREZA, FILIAL "+CRLF

		ELSE  //Sintático > Diário

			clQuery := " SELECT FILIAL,
			clQuery += " 		TIPO, "+CRLF
			clQuery += " 		NATUREZA, "+CRLF
			clQuery += " 		DESCRI "+CRLF

			nDias := DateDiffDay(mv_par05,mv_par06)+1
			For nI := 1 to 31
				If nI < (nDias	+ 1)
					clQuery +=" ,SUM(D"+ alltrim(str(nI)) +")D" + alltrim(str(nI))+CRLF
				Else
					clQuery +=" ,SUM(0)D" + alltrim(str(nI))+CRLF
				EndIf
			Next

			clQuery += " FROM 	( "+CRLF
			clQuery += " 		SELECT 	FILIAL, "+CRLF
			clQuery += " 				ORIEN TIPO, "+CRLF
			clQuery += " 				NATUREZA, "+CRLF
			clQuery += " 				DESCRI, "+CRLF
			clQuery += " 				SUM(CASE WHEN SUBSTRING(DATA,7,2) = '01' THEN VALPER ELSE 0 END) AS D1,   "+CRLF
			clQuery += " 				SUM(CASE WHEN SUBSTRING(DATA,7,2) = '02' THEN VALPER ELSE 0 END) AS D2,   "+CRLF
			clQuery += " 				SUM(CASE WHEN SUBSTRING(DATA,7,2) = '03' THEN VALPER ELSE 0 END) AS D3,   "+CRLF
			clQuery += " 				SUM(CASE WHEN SUBSTRING(DATA,7,2) = '04' THEN VALPER ELSE 0 END) AS D4,   "+CRLF
			clQuery += " 				SUM(CASE WHEN SUBSTRING(DATA,7,2) = '05' THEN VALPER ELSE 0 END) AS D5,   "+CRLF
			clQuery += " 				SUM(CASE WHEN SUBSTRING(DATA,7,2) = '06' THEN VALPER ELSE 0 END) AS D6,   "+CRLF
			clQuery += " 				SUM(CASE WHEN SUBSTRING(DATA,7,2) = '07' THEN VALPER ELSE 0 END) AS D7,   "+CRLF
			clQuery += " 				SUM(CASE WHEN SUBSTRING(DATA,7,2) = '08' THEN VALPER ELSE 0 END) AS D8,   "+CRLF
			clQuery += " 				SUM(CASE WHEN SUBSTRING(DATA,7,2) = '09' THEN VALPER ELSE 0 END) AS D9,   "+CRLF
			clQuery += " 				SUM(CASE WHEN SUBSTRING(DATA,7,2) = '10' THEN VALPER ELSE 0 END) AS D10,  "+CRLF
			clQuery += " 				SUM(CASE WHEN SUBSTRING(DATA,7,2) = '11' THEN VALPER ELSE 0 END) AS D11,  "+CRLF
			clQuery += " 				SUM(CASE WHEN SUBSTRING(DATA,7,2) = '12' THEN VALPER ELSE 0 END) AS D12,  "+CRLF
			clQuery += " 				SUM(CASE WHEN SUBSTRING(DATA,7,2) = '13' THEN VALPER ELSE 0 END) AS D13,  "+CRLF
			clQuery += " 				SUM(CASE WHEN SUBSTRING(DATA,7,2) = '14' THEN VALPER ELSE 0 END) AS D14,  "+CRLF
			clQuery += " 				SUM(CASE WHEN SUBSTRING(DATA,7,2) = '15' THEN VALPER ELSE 0 END) AS D15,  "+CRLF
			clQuery += " 				SUM(CASE WHEN SUBSTRING(DATA,7,2) = '16' THEN VALPER ELSE 0 END) AS D16,  "+CRLF
			clQuery += " 				SUM(CASE WHEN SUBSTRING(DATA,7,2) = '17' THEN VALPER ELSE 0 END) AS D17,  "+CRLF
			clQuery += " 				SUM(CASE WHEN SUBSTRING(DATA,7,2) = '18' THEN VALPER ELSE 0 END) AS D18,  "+CRLF
			clQuery += " 				SUM(CASE WHEN SUBSTRING(DATA,7,2) = '19' THEN VALPER ELSE 0 END) AS D19,  "+CRLF
			clQuery += " 				SUM(CASE WHEN SUBSTRING(DATA,7,2) = '20' THEN VALPER ELSE 0 END) AS D20,  "+CRLF
			clQuery += " 				SUM(CASE WHEN SUBSTRING(DATA,7,2) = '21' THEN VALPER ELSE 0 END) AS D21,  "+CRLF
			clQuery += " 				SUM(CASE WHEN SUBSTRING(DATA,7,2) = '22' THEN VALPER ELSE 0 END) AS D22,  "+CRLF
			clQuery += " 				SUM(CASE WHEN SUBSTRING(DATA,7,2) = '23' THEN VALPER ELSE 0 END) AS D23,  "+CRLF
			clQuery += " 				SUM(CASE WHEN SUBSTRING(DATA,7,2) = '24' THEN VALPER ELSE 0 END) AS D24,  "+CRLF
			clQuery += " 				SUM(CASE WHEN SUBSTRING(DATA,7,2) = '25' THEN VALPER ELSE 0 END) AS D25,  "+CRLF
			clQuery += " 				SUM(CASE WHEN SUBSTRING(DATA,7,2) = '26' THEN VALPER ELSE 0 END) AS D26,  "+CRLF
			clQuery += " 				SUM(CASE WHEN SUBSTRING(DATA,7,2) = '27' THEN VALPER ELSE 0 END) AS D27,  "+CRLF
			clQuery += " 				SUM(CASE WHEN SUBSTRING(DATA,7,2) = '28' THEN VALPER ELSE 0 END) AS D28,  "+CRLF
			clQuery += " 				SUM(CASE WHEN SUBSTRING(DATA,7,2) = '29' THEN VALPER ELSE 0 END) AS D29,  "+CRLF
			clQuery += " 				SUM(CASE WHEN SUBSTRING(DATA,7,2) = '30' THEN VALPER ELSE 0 END) AS D30,  "+CRLF
			clQuery += " 				SUM(CASE WHEN SUBSTRING(DATA,7,2) = '31' THEN VALPER ELSE 0 END) AS D31 "+CRLF

			clQuery += "       FROM ( " + CRLF
			clQuery +=                BaseData(_cContas) + CRLF &&Edson Melo - Atenção ao realizar alteração nessa função, pois reflete em todos os relatórios (Analítico, Sintético Mensal e Sintético Diário)
			clQuery += "       ) AS T2 " + CRLF
			clQuery += "       GROUP BY FILIAL, ORIEN, NATUREZA, DESCRI, DATA, COND " + CRLF

			clQuery += " )  AS T  "+CRLF
			clQuery += " GROUP BY TIPO, NATUREZA, FILIAL, DESCRI "+CRLF
			clQuery += " ORDER BY TIPO, NATUREZA, FILIAL, DESCRI "+CRLF
		EndIf
	EndIf

	IF SELECT("FCAIXA") > 0
		dbSelectArea("FCAIXA")
		FCAIXA->(DbCloseArea())
	ENDIF

	//Aviso('',clQuery,{'OK'})

	MemoWrite(GetTempPath(.T.) + "RFIN004.SQL", clQuery)
	//clQuery := ChangeQuery(clQuery)
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,clQuery),"FCAIXA",.F.,.T.)

	If Mv_par09 == 1
		tcSetField("FCAIXA","DATA","D",08,00)
	EndIf

Return

Static Function ValPerg(cPerg)

	PutSx1(cPerg,"01","Filial de?","","","mv_ch1","C",11,00,00,"G","","SM0","","","mv_Par01","","","","","","","","","","","","","","","","",{"Digite a filial inicial que "+ chr(10) + chr(13) + " se deseja imprimir"},{},{},"")
	PutSx1(cPerg,"02","Filial Ate?","","","mv_ch2","C",11,00,00,"G","","SM0","","","mv_Par02","","","","","","","","","","","","","","","","",{"Digite a filial final que "+ chr(10) + chr(13) + "se deseja imprimir"},{},{},"")
	PutSx1(cPerg,"03","Da Natureza?","","","mv_ch3","C",10,00,00,"G","","SED","","","mv_Par03","","","","","","","","","","","","","","","","",{"Natureza inicial inicial que "+ chr(10) + chr(13) + " se deseja imprimir"},{},{},"")
	PutSx1(cPerg,"04","Ate a Natureza","","","mv_ch4","C",10,00,00,"G","","SED","","","mv_Par04","","","","","","","","","","","","","","","","",{"Natureza final que "+ chr(10) + chr(13) + "se deseja imprimir"},{},{},"")
	PutSx1(cPerg,"05","Data de ?","","","mv_ch5","D",08,00,00,"G","","","","","mv_Par05","","","","","","","","","","","","","","","","",{" Informe Data inicial "+ chr(10) + chr(13) + " para impressão"},{},{},"")
	PutSx1(cPerg,"06","'Data Ate?","","","mv_ch6","D",08,00,00,"G","","","","","mv_Par06","","","","","","","","","","","","","","","","",{"Informe a data final "+ chr(10) + chr(13) + "para impressão"},{},{},"")
	PutSx1(cPerg,"07","Tipo de Saldo","","","mv_ch7","N",01,0,0,"C","","","","","mv_par07","Orcado","","","","Previsto","","","Realizado","","","","","","","","",{"Define o tipo de  "+ chr(10) + chr(13) + "Salso a ser impresso"},{},{},"" )
	PutSx1(cPerg,"08","Modelo","","","mv_ch8","N",01,0,0,"C","","","","","mv_par08","Mensal","","","","Diario","","","","","","","","","","","",{"Modelo do relatorio "},{},{},"" )
	PutSx1(cPerg,"09","Tipo Rel.","","","mv_ch9","N",01,0,0,"C","","","","","mv_par09","Analítico","","","","Sintético","","","","","","","","","","","",{"Detalhado ou resumido? "},{},{},"" )

Return


Static Function GetSldIni(_cFil, _cBco, _cAge, _aAcc, _nMoeda, _dDtRef)

Local nMoedaBco	:=	Max(_nMoeda,1)
Local nSldIni := 0

SE8->(dbSeek(_cFil+_cBco+_cAge+_aAcc+Dtos(_dDtRef),.T.))   // filial + banco + agencia + conta
SE8->(dbSkip(-1))

IF SE8->E8_FILIAL != _cFil .Or. SE8->E8_BANCO != _cBco .or. SE8->E8_AGENCIA!=_cAge .or. SE8->E8_CONTA!=_aAcc .or. SE8->(BOF()) .or. SE8->(EOF())
	nSaldoAtu:=0
	nSldIni:=0
Else
	//If mv_par07 == 1  //Todos
	nSldIni:=Round(xMoeda(SE8->E8_SALATUA,nMoedaBco,1,SE8->E8_DTSALAT),2)
	/*
	ElseIf mv_par07 == 2 //Conciliados
		nSldIni:=Round(xMoeda(SE8->E8_SALRECO,nMoedaBco,1,SE8->E8_DTSALAT),nMoeda)
	ElseIf mv_par07 == 3	//Nao Conciliados
		nSldIni:=Round(xMoeda(SE8->E8_SALATUA-SE8->E8_SALRECO,nMoedaBco,1,SE8->E8_DTSALAT),nMoeda)
	Endif
	*/
Endif

Return nSldIni




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³RFIN004   ºAutor  ³Microsiga           º Data ³  12/29/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function BaseData(_cContas)

Local cBaseQry := ""
Local lSpbInUse := SpbInUse()
Local cTabela14 := FR470Tab14() //| StaticCall(FINR470,FR470Tab14) //| REMOVIDO PARA COMPATIBILIDADE 12.1.33
cBaseQry += " SELECT FILIAL, DATA, LOTE, XIDFLG, PREFIXO, NUMERO, PARCELA, TIPO, CLIFOR, LOJA, BENEF, SEQ, ORIEN, RECPAG, NATUREZA, COND, DESCRI, VALPER, RECE5 "+CRLF
cBaseQry += " FROM ("+CRLF
cBaseQry += " SELECT E5_FILIAL FILIAL, "+CRLF
cBaseQry += " 		E5_DTDISPO DATA, "+CRLF
cBaseQry += " 		E5_LOTE LOTE, "+CRLF
cBaseQry += " 		E5_XIDFLG XIDFLG, "+CRLF
cBaseQry += " 		E5_PREFIXO PREFIXO, "+CRLF
cBaseQry += " 		E5_NUMERO NUMERO, "+CRLF
cBaseQry += " 		E5_PARCELA PARCELA, "+CRLF
cBaseQry += " 		E5_TIPO TIPO, "+CRLF
cBaseQry += " 		E5_CLIFOR CLIFOR, "+CRLF
cBaseQry += " 		E5_LOJA LOJA, "+CRLF
cBaseQry += " 		E5_BENEF BENEF, "+CRLF
cBaseQry += " 		E5_SEQ SEQ, "+CRLF
cBaseQry += " 		CASE ED_COND WHEN 'R' THEN 'RECEITA' WHEN 'D' THEN 'DESPESAS' ELSE 'OUTRAS' END AS ORIEN, "+CRLF
cBaseQry += " 		E5_RECPAG RECPAG, "+CRLF
cBaseQry += " 		ED_CODIGO NATUREZA, " +CRLF
cBaseQry += " 		ED_DESCRIC DESCRI, " +CRLF
cBaseQry += " 		ED_COND COND, " +CRLF
cBaseQry += " 		E5_VALOR * (CASE E5_RECPAG WHEN 'P' THEN -1 ELSE 1 END) AS VALPER, "+CRLF
cBaseQry += " 		SE5.R_E_C_N_O_ RECE5 "+CRLF
cBaseQry += " FROM " + RetSqlName("SE5") + " SE5 "+CRLF
cBaseQry += " LEFT JOIN " + RetSqlName("SED") + " SED ON "+CRLF
cBaseQry += "            E5_NATUREZ = ED_CODIGO "+CRLF
cBaseQry += "        AND SED.D_E_L_E_T_ = '' "+CRLF
cBaseQry += " LEFT JOIN " + RetSqlName("SA6") + " SA6 ON "+CRLF
cBaseQry += "  A6_AGENCIA=E5_AGENCIA AND A6_NUMCON=E5_CONTA   "+CRLF
cBaseQry += "  AND  SA6.D_E_L_E_T_ = '' "+CRLF
cBaseQry += " WHERE E5_FILIAL BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"'  " +CRLF      //"'" + xFilial("SE5") + "'" + " AND "
cBaseQry += " 	AND E5_NATUREZ BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' "+CRLF
cBaseQry += " 	AND E5_DTDISPO >=  '"     + DTOS(mv_par05) + "'"+CRLF
If lSpbInuse
	cBaseQry += " 	AND ((E5_DTDISPO <= '" + DTOS(mv_par06) + "') OR "+CRLF
	cBaseQry += " 		 (E5_DTDISPO >= '" + DTOS(mv_par06) + "' AND "+CRLF
	cBaseQry += " 		 (E5_DATA    >= '" + DTOS(mv_par05) + "' AND "+CRLF
	cBaseQry += "  		  E5_DATA    <= '" + DTOS(mv_par06) + "')))"+CRLF
Else
	cBaseQry += "    AND E5_DTDISPO <=  '"     + DTOS(mv_par06) + "'"+CRLF
Endif
cBaseQry += " 	AND E5_BANCO + E5_AGENCIA + E5_CONTA IN ("+ _cContas+") "+CRLF
cBaseQry += "    AND NOT (E5_DOCUMEN = ' ' AND E5_LOTE <> ' ') "+CRLF
cBaseQry += " 	AND NOT ( E5_NUMCHEQ BETWEEN '*              ' AND '*ZZZZZZZZZZZZZZ' ) "+CRLF
cBaseQry += " 	AND E5_SITUACA <> 'C' "+CRLF
cBaseQry += " 	AND E5_VALOR <> 0 "+CRLF
//cBaseQry += " 	AND (E5_VENCTO <= '" + DTOS(mv_par06)  + "' OR E5_VENCTO <= E5_DATA OR E5_ORIGEM = 'FINA070') "+CRLF
cBaseQry += " 	AND E5_TIPODOC NOT IN ('DC','JR','MT','CM','D2','J2','M2','C2','V2','CP','TL','BA','I2','EI') "	+CRLF
cBaseQry += " 	AND NOT ( E5_MOEDA IN ('C1','C2','C3','C4','C5','CH') AND E5_NUMCHEQ = '               ' AND ( E5_TIPODOC NOT IN( 'TR', 'TE' ) ) ) "+CRLF
cBaseQry += " 	AND NOT ( E5_TIPODOC IN ('TR','TE') AND ( ( E5_NUMCHEQ BETWEEN '*              ' AND '*ZZZZZZZZZZZZZZ') OR (E5_DOCUMEN BETWEEN '*                ' AND '*ZZZZZZZZZZZZZZZZ' ))) "+CRLF
cBaseQry += " 	AND NOT ( E5_TIPODOC IN ('TR','TE') AND E5_NUMERO = '" + Space( TamSX3( "E5_NUMERO" )[1] ) + "' AND E5_MOEDA NOT IN " + FormatIn(cTabela14+"/DO","/") + " ) "+CRLF
cBaseQry += " 	AND SE5.D_E_L_E_T_ = ' ' AND A6_BLOCKED='2'AND A6_FLUXCAI='S' "+CRLF

cBaseQry += " UNION ALL "+CRLF

cBaseQry += " SELECT	E5_FILIAL FILIAL, "+CRLF
cBaseQry += " 		E5_DTDISPO DATA, "+CRLF
cBaseQry += " 		E5_LOTE LOTE, "+CRLF
cBaseQry += " 		E5_XIDFLG XIDFLG, "+CRLF
cBaseQry += " 		E5_PREFIXO PREFIXO, "+CRLF
cBaseQry += " 		E5_NUMERO NUMERO, "+CRLF
cBaseQry += " 		E5_PARCELA PARCELA, "+CRLF
cBaseQry += " 		E5_TIPO TIPO, "+CRLF
cBaseQry += " 		E5_CLIFOR CLIFOR, "+CRLF
cBaseQry += " 		E5_LOJA LOJA, "+CRLF
cBaseQry += " 		E5_BENEF BENEF, "+CRLF
cBaseQry += " 		E5_SEQ SEQ, "+CRLF
cBaseQry += " 		CASE ED_COND WHEN 'R' THEN 'RECEITA' WHEN 'D' THEN 'DESPESAS' ELSE 'OUTRAS' END AS ORIEN, "+CRLF
cBaseQry += " 		E5_RECPAG RECPAG, "+CRLF
cBaseQry += " 		ED_CODIGO NATUREZA, " +CRLF
cBaseQry += " 		ED_DESCRIC DESCRI, " +CRLF
cBaseQry += " 		ED_COND COND, "+CRLF
cBaseQry += " 		E5_VALOR * (CASE E5_RECPAG WHEN 'P' THEN -1 ELSE 1 END) AS VALPER, "+CRLF
cBaseQry += " 		SE5.R_E_C_N_O_ RECE5 "+CRLF
cBaseQry += " FROM  	" + RetSqlName("SE5") + " SE5 "+CRLF
cBaseQry += " LEFT JOIN " + RetSqlName("SED") + " SED ON "+CRLF
cBaseQry += "            E5_NATUREZ = ED_CODIGO "+CRLF
cBaseQry += "        AND SED.D_E_L_E_T_ = ' ' "+CRLF
cBaseQry += " LEFT JOIN " + RetSqlName("SA6") + " SA6 ON "+CRLF
cBaseQry += "  A6_AGENCIA=E5_AGENCIA AND A6_NUMCON=E5_CONTA AND A6_BLOCKED='2'AND A6_FLUXCAI='S'  "+CRLF
cBaseQry += "  AND  SA6.D_E_L_E_T_ = '' "+CRLF
cBaseQry += " WHERE E5_FILIAL BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"'  "   +CRLF    //"'" + xFilial("SE5") + "'" + " AND "
cBaseQry += " 	AND E5_NATUREZ BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' "+CRLF
cBaseQry += " 	AND E5_DTDISPO >=  '"     + DTOS(mv_par05) + "'"+CRLF
If lSpbInuse
	cBaseQry += " 	AND ((E5_DTDISPO <=  '" + DTOS(mv_par06) + "') OR "+CRLF
	cBaseQry += " 		 (E5_DTDISPO >=  '" + DTOS(mv_par06) + "' AND "+CRLF
	cBaseQry += " 		 (E5_DATA >=  '" + DTOS(mv_par05) + "' AND "+CRLF
	cBaseQry += "  		  E5_DATA <=  '" + DTOS(mv_par06) + "')))"+CRLF
Else
	cBaseQry += "    AND E5_DTDISPO <=  '"     + DTOS(mv_par06) + "'"+CRLF
Endif
cBaseQry += " 	AND E5_BANCO + E5_AGENCIA + E5_CONTA IN ("+ _cContas+") "+CRLF
cBaseQry += " 	AND E5_VALOR <> 0 "+CRLF
cBaseQry += " 	AND E5_TIPODOC NOT IN ('DC','D2','JR','J2','TL','MT','M2','CM','C2') "	+CRLF
cBaseQry += "    AND NOT (E5_SITUACA = 'C')"+CRLF
cBaseQry += "    AND NOT (E5_LOTE = '" + Space(Len(SE5->E5_LOTE)) + "')"+CRLF
cBaseQry += "    AND NOT (E5_DATA = '" + Space(TamSX3("E5_DATA")[1]) + "')"+CRLF
cBaseQry += "    AND NOT (E5_NUMERO = '" + Space(Len(SE5->E5_NUMERO)) + "')"+CRLF
cBaseQry += " 	AND SE5.D_E_L_E_T_ = ' 'ns  A6_BLOCKED='2'AND A6_FLUXCAI='S' "+CRLF
//cBaseQry += " ORDER BY  ED_COND, ED_CODIGO, E5_FILIAL "
cBaseQry += " ) AS TEMP "+CRLF
cBaseQry += " GROUP BY FILIAL, DATA, LOTE, XIDFLG, PREFIXO, NUMERO, PARCELA, TIPO, CLIFOR, LOJA, BENEF, SEQ, ORIEN, RECPAG, NATUREZA, COND, DESCRI, VALPER, RECE5 "+CRLF

Return(cBaseQry)




//----------------------------------------------------------------
/*/{Protheus.doc}FR470Tab14
Carrega e retorna moedas da tabela 14 

@author Gustavo Henrique 
@since  15/07/10
@version 12

@return Dados da tabela 14 cadastrada no SX5
/*/
//-----------------------------------------------------------------
Static Function FR470Tab14() As Character
	Local cTabela14 As Character
	Local aRetSX5 	As Array
	Local nX		As Numeric

	cTabela14 := ""
	aRetSX5   := FWGetSX5( "14",,"pt-br")
	nX		  := 0
	
	For nX := 1 to Len(aRetSX5)
		cTabela14 += (Alltrim(aRetSX5[nX,3]) + "/")
	Next nX
	
	If cPaisLoc == "BRA"
		cTabela14 := SubStr(cTabela14, 1, Len(cTabela14) - 1)
	Else	
		cTabela14 += "/$ " 
	EndIf

Return cTabela14
