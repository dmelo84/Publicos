#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "TBICONN.CH"
#include "Tbiconn.ch"

User function QsIntAut

	Local cQry := " "
	Local nReg := 0
	Local aCab := {}
	Local aItens := {}
	Local aItePed := {}
	Local cMsgNota := ''
	
	RPCClearEnv() //Caso ambiente esteja aberto, fecho/Limpo.
	RPCSetType(3)
	RPCSetEnv('01','01')

	//--Variaveis do filtro bonificação
	cCfop   := SUPERGETMV("MV_XVALCF",.T.,"5910|6910" )
	aFiltro := STRTOKARR(cCfop, "|")
	cFiltro := ''
	//-----------------------------------
	/* Valida bonificação */
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
	/*-------------------*/	

	cQry := " Select C5_FILIAL, C5_NUM, C5_CLIENTE, C5_LOJACLI, C5_TIPOCLI, C5_DESCONT, C5_EMISSAO, "
	cQry += " C5_CONDPAG, C5_VEND1,C5_P_DTRAX, C5_MKOK, C5_OK " 
	cQry += " FROM "+ RetSqlName("SC5") +" SC5 " 
	cQry += " WHERE D_E_L_E_T_ != '*' AND C5_TIPO = 'N' "
	cQry += " AND C5_BLQ = ' ' "
	cQry += " AND C5_FILIAL = '"+cFilant+"'" 
	cQry += " AND C5_OK in (' ','PA') " 
	cQry += " AND C5_P_AG = 0 "
	cQry += " AND C5_P_DTRAX != ' ' "
	cQry += " AND C5_NOTA = ' ' "
	cQry += " AND C5_ORIGEM != 'QSIntLoj' "

	cQry := ChangeQuery(cQry)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQry),"cSC5", .F., .T.)

	dbSelectArea("cSC5")
	cSC5->(dbGoTop())

	While cSC5->(!EOF())
	
	cMsgNota := ' ' //Se não limpar traz o numero do pedido anterior
	nReg := u_RETSC6(cSC5->C5_NUM, cFiltro)
	nBon := u_BoniSC6(cSC5->C5_NUM, cFiltro)

	If nBon > 0
			cMsgNota := "Pedido: "+cSC5->C5_NUM+" Contem itens bonificado. "
	EndIf
		
	If nReg > 0 
	cIdMember := POSICIONE("SA1", 1, xFilial("SA1") + cSC5->C5_CLIENTE + cSC5->C5_LOJACLI, "A1_P_DTRAX")

		aAdd(aCab,{/**/;
		xFilial("SC5"),/*aCab[1][1]*/;
		cSC5->C5_NUM,   /*aCab[1][2]*/;
		cSC5->C5_CLIENTE,/*aCab[1][3]*/;
		cSC5->C5_LOJACLI,/*aCab[1][4]*/;
		cSC5->C5_TIPOCLI,/*aCab[1][5]*/;
		cSC5->C5_DESCONT,/*aCab[1][6]*/;
		cSC5->C5_EMISSAO,/*aCab[1][7]*/;
		cSC5->C5_CONDPAG,/*aCab[1][8]*/;
		Iif(Empty(cSC5->C5_VEND1),"000001",cSC5->C5_VEND1),/*aCab[1][9]*/,;
		/*SL1->LQ_NUMMOV||aCab[1][10]*/'01',;
		cSC5->C5_P_DTRAX, /*aCabDados[1][12]*/;
		cIdMember, /*aCabDados[1][13]*/;
		cMsgNota}) //aCabDados[1][14]

	EndIf
		cSC5->(dbSkip())
	EndDo

	For nX := 1 to Len(aCab)

		cQry := " "
		cQry += " Select C6_FILIAL, C6_NUM,C6_PRODUTO, C6_LOCAL, C6_QTDVEN, C6_PRCVEN, C6_VALOR, C6_DESCONT, "
		cQry += " C6_VALDESC, C6_TES, C6_ITEM, C6_UM "
		cQry += " from "+ RetSqlName("SC6")+ " SC6 "
		cQry += " where D_E_L_E_T_ != '*' "
		cQry += " And C6_FILIAL = '"+xFilial("SC6")+"'" 
		cQry += " And C6_NUM = '"+aCab[nX][2]+"'"
		cQry += " And C6_CF not IN "+cFiltro

		cQry := ChangeQuery(cQry)
		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQry),"cSC6", .F., .T.)
		dbSelectArea("cSC6")

		aItens := {}

		While cSC6->(!EOF())

		aRetSaldo := u_RetSaldo(cSC6->C6_PRODUTO, cSC6->C6_LOCAL, cSC6->C6_QTDVEN)

			aAdd(aItens,{;
			cSC6->C6_FILIAL,/*aItensDados[1][1]*/;
			cSC6->C6_NUM,/*aItensDados[1][2]*/;
			cSC6->C6_PRODUTO,/*aItensDados[1][3]*/;
			cSC6->C6_QTDVEN,/*aItensDados[1][4]*/;
			cSC6->C6_UM,/*aItensDados[1][5]*/;
			cSC6->C6_PRCVEN,/*aItensDados[1][6]*/;
			cSC6->C6_VALOR,/*aItensDados[1][7]*/;
			cSC6->C6_DESCONT,/*aItensDados[1][8]*/;
			cSC6->C6_VALDESC,/*aItensDados[1][9]*/;
			cSC6->C6_TES,/*aItensDados[1][10]*/;
			cSC6->C6_ITEM,/*aItensDados[1][11]*/;
			iIF(Len(aRetSaldo) > 0,aRetSaldo[1][1], " ")/*aItensDados[1][12]*/})

			cSC6->(dbSkip())
		Enddo
		aAdd(aItePed,aItens)
		cSC6->(dbCloseArea())
	
	Next

	u_MyLOJA701(,.T.,"2",aCab,aItePed)

	RpcClearEnv()

Return (aCab,aItePed)

/*-----------------------------------------------------------------
|Função de Processamento                                           |
|Retorna quantidade de itens a SC6 para validar o execauto         |
|Desenvolvedo: Diogo Melo                                          |
|Data atualização: 09/05/2019                                      |
-------------------------------------------------------------------*/

user function RETSC6(cNum, cFiltro)

	Local cQry
	Local nReg := 0
	Local nY := 0

	//Contar Registro
	cQry := " "
	cQry := " Select Count(C6_NUM) as nSC6 "
	cQry += " from "+ RetSqlName("SC6")+ " SC6 "
	cQry += " where D_E_L_E_T_ != '*' "
	cQry += " And C6_FILIAL = '"+xFilial("SC6")+"'" 
	cQry += " And C6_NUM = '"+cNum+"'"
	cQry += " And C6_CF not IN "+cFiltro

	cQry := ChangeQuery(cQry)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQry),"nCountSC6", .F., .T.)
	dbSelectArea("nCountSC6")

	While nCountSC6->(!EOF())
	
		nReg := nCountSC6->nSC6
		nCountSC6->(dbSkip())

	Enddo
	nCountSC6->(dbCloseArea())

Return (nReg)

/*-----------------------------------------------------------------
|Função de Processamento                                           |
|Retorna quantidade de itens a SC6 com bonificação                 |
|Desenvolvedo: Diogo Melo                                          |
|Data atualização: 31/08/2019                                      |
-------------------------------------------------------------------*/

user function BoniSC6(cNum, cFiltro)

	Local cQry
	Local nBoni := 0
	
	//Contar Registro
	cQry := " "
	cQry := " Select Count(C6_NUM) as nSC6 "
	cQry += " from "+ RetSqlName("SC6")+ " SC6 "
	cQry += " where D_E_L_E_T_ != '*' "
	cQry += " And C6_FILIAL = '"+xFilial("SC6")+"'" 
	cQry += " And C6_NUM = '"+cNum+"'"
	cQry += " And C6_CF IN "+cFiltro

	cQry := ChangeQuery(cQry)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQry),"nCountSC6", .F., .T.)
	dbSelectArea("nCountSC6")

	While nCountSC6->(!EOF())
	
		nBoni := nCountSC6->nSC6

		nCountSC6->(dbSkip())
	Enddo
	nCountSC6->(dbCloseArea())

Return (nBoni)

/*-----------------------------------------------------------------
|Função de Processamento                                           |
|Retorna saldo da SB8(Lote) para validar o execauto                |
|Desenvolvedo: Diogo Melo                                          |
|Data atualização: 09/05/2019                                      |
-------------------------------------------------------------------*/

user function RetSaldo(cProduto, cLocal, nQtd)

	Local cQry := ' '
	Local cLote := ' '
	Local nSaldo := 0
	Local aRetInfo := {}

	cQry += " Select DISTINCT B8_PRODUTO, B8_LOCAL, B8_QTDORI, B8_DTVALID, B8_LOTECTL, B8_SALDO, B8_EMPENHO " 
	cQry += " FROM " +Retsqlname("SB8") + " SB8 "
	cQry += " INNER JOIN " + RetSqlName("SC6") +" SC6 "
	cQry += " ON B8_PRODUTO = C6_PRODUTO "
	cQry += " AND B8_FILIAL = C6_FILIAL "
	cQry += " AND B8_LOCAL = C6_LOCAL "
	cQry += " AND SB8.D_E_L_E_T_ = ' ' "
	cQry += " AND SC6.D_E_L_E_T_ = ' ' "
	cQry += " WHERE C6_PRODUTO = '"+Alltrim(cProduto)+"'"
	cQry += " AND C6_LOCAL = '"+cLocal+"'"
	cQry += " AND B8_SALDO > 0 "
	cQry += " AND B8_EMPENHO < B8_SALDO "

	cQry := ChangeQuery(cQry)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQry),"cSB8", .F., .T.)
	dbSelectArea("cSB8")

	While cSB8->(!eof())

	If cSB8->B8_SALDO >= nQtd .and. cSB8->B8_EMPENHO < cSB8->B8_SALDO .and. stod(B8_DTVALID) <= dDatabase

		Aadd(aRetInfo,{cSB8->B8_LOTECTL, B8_SALDO, B8_DTVALID})
		Exit

	EndIf

	cSB8->(dbskip())

	EndDo
	dbCloseArea("cSB8")
Return (aRetInfo)