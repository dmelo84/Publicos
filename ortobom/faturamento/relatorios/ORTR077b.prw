#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOTVS.CH"

*---------------------------------------------------------------------------*
* Programa....: ORTR077                                            09.02.09 *
* Programador.: Jose Carlos Noronha                                         *
* Finalidade..: Relatório de Pedidos em Carteira                            *
* Data........: 24/07/06                                                    *
* Propriedade.: Ortobom Colchoes                                            *
* Alteraçao: Conversao para tmsprint  - Fábio Costa - TecnoSum - 14/05/2013 *
* Alteraçao: Atendimento a SSI 30595  - Fábio Costa - TecnoSum - 05/08/2013 *
* Alteraçao: Atendimento a SSI 30661  - Fábio Costa - TecnoSum - 06/08/2013 *
*---------------------------------------------------------------------------*
* Alteraçao: Atendimento a SSI 105463 - Vagner Almeida         - 26/01/2021 *
* Incluir alguns filtros em nosso relatório "Pedidos em Carteira" (ORTR077) *
* conforme anexo prints enviados. Filtros a serem inclusos:					*
* 									GERENTE									*	
* 									AGRUPA CLIENTES							*
* 									TIPO DE BLOQUEIO						*
* 									LISTAR OUTRAS UNIDADES					*
* 									FILTRAR POR BAIRRO						*
* 									REMESSA POR CONTA E ORDEM				*
*---------------------------------------------------------------------------*
* Vagner Almeida - 09/09/2021 - SSI 124131                                  *
* Solicitante: Marco Aurelio						                        *
* Objetivo: Solicito que seja incluído no Relatório ORTR077B – Relório de   *    						                        				*
* 			Pedidos em Carteira a opção de exportar em CSV.					*
*---------------------------------------------------------------------------*
* Vagner Almeida - 16/09/2021 - SSI 123499                                  *
* Solicitante: Marco Aurelio						                        *
* Objetivo: Solicito que seja incluído no relatório ORTR077 – Pedidos em    *    						                        				*
* 		    Carteira, o parâmetro de desconto SIMBAHIA (SIM ou NÃO).		*
* 		    Sendo assim, ao optar pelo desconto, o relatório trará o valor 	*
* 		    líquido do pedido que possua o respectivo desconto.				*
*---------------------------------------------------------------------------*

*----------------------*
User Function ORTR077b(cRPC,cNRot,cInfRet)
*----------------------*          
Default cRPC		 := "N"
Default cNRot		 := ""
Default cInfRet		 := ""
Private cTmpArq        := ""
// Fim Rogerio Carvalho 25/06/2019
Private _cRpc		 := cRpc
Private _cNRot		 := cNRot
Private _cInfRet	 := cInfRet
Private oPrn,oFont,oFontM,oFont2,oFontS
Private cHora 	   	:= Time()
Private nLin       	:= 0
Private nPag	   	:= 0
Private nCol	   	:= 10
Private cNomFil		:= ""

Private Cabec1       := ""
Private Cabec2       := ""

Private nVez         := 1
Private titulo       := "Relatorio de Pedidos em Carteira"
Private cDesc1       := "ESTE MAPA DEVE SER GERADO PELO ADMINISTRADOR PARA QUE O SECRETARIO POSSA DAR RESPOSTA SOBRE O STATUS DOS PEDIDOS"
Private cDesc2       := ""
Private cDesc3       := ""

Private nomeprog     := "ORTR077"

Private cbcont       := 0
Private CONTFL       := 1
Private m_pag        := 1
Private wnrel        := "ORTR077"
Private cPerg        := "ORTR77"
Private aPonto       := {}
Private cString      := "SC5"
Private nDebTot      := 0
Private _cAssistente := Space(20), _cVendedor := "", _cRoteiro := "", cOper:=""
Private x
Private _aProd		:= {}
Private dEstCan     := {}
Private _aProdT		:= {}
Private _nPos		:=  0
Private _nPos2      :=  0
Private _aResumo3	:= {}
Private _aResumo2   := {}
Private _aResumo2B  := {}
Private _aResumo2C  := {}
Private _aResumo2E  := {}
Private _aResumo	:= {}
Private aCliente    := {} // Array para vendedores
Private _aPedProb	:= {}
Private _aSegmento  := {}
Private _aModelos   := {}
Private _aProdTatr  := {}
Private _aPedAt     := {}
Private _aPedzer    := {}
Private _aProgGP    := {}
Private _AEST       := {}
Private nTxUpme		:= 0
Private nCart30d	:= 0
Private nCart3060d  := 0
Private nCartM60d	:= 0
Private nTotDias	:= 0
Private nEspLivre   := 0
Private nTotLivre   := 0
Private nEspFut     := 0
Private nTotFut     := 0
Private nValtot     := 0
Private nEspLivreG  := 0
Private nTotLivreG  := 0
Private nEspFutG    := 0
Private nTotFutG    := 0
Private nEspTot     := 0
Private nQTotprod   := 0
Private nTotNFat    := 0
Private xOper		:= ""
Private CAUTORIZ    := ""
Private aRentSeg30	:= {0,0,0,0}
Private aRtSeg3060  := {0,0,0,0}
Private aRentSeg60	:= {0,0,0,0}
Private aRent30     := {0,0,0,0}
Private aRent3060	:= {0,0,0,0}
Private aRent60		:= {0,0,0,0}
Private aRentTot	:= {0,0,0,0}
Private cSeg 		:= ""
Private cNumsc      := ""
Private ncont       := 0
Private nSolicit    := 0
Private cQry        := ""
Private cProdT      := ""
Private lImp        := .F.
Private lSeglin     := .F.
Private lCob        := .F.
Private cProd       := ""
Private cDesc       := ""
Private cMed        := ""
Private cPed        := ""
Private cProdTatr   := ""
Private cCdcm       := ""
Private cLib        := ""
Private cCob        := ""
Private cModelo     := ""
Private cOrdCom     := ""
Private nDias       := 0
Private Usuario     := RetCodUsr()
Private _nSegA      := 0
Private _aSegmentA 	:= {}
Private _nSegB      := 0
Private _aSegmentB 	:= {}
Private _nModA  	:= 0
Private _aModelosA  := {}
Private _nModB   	:= 0
Private _aModelosB  := {}
Private _aProdGP    := {}
Private nTotQTDA    := 0
Private nTotTotalA  := 0
Private nTotQTDB    := 0
Private nTotTotalB  := 0
Private nEspTotB    := 0
Private nValtotB    := 0
Private nEspLGB 	:= 0
Private nTotLGB 	:= 0
Private nTotLGE 	:= 0

Private nEspFutGB   := 0
Private nTotFutGB   := 0
Private nTotFuGBE   := 0
Private nEspTotC    := 0
Private nValtotC    := 0
Private nEspLGC 	:= 0
Private nTotLGC 	:= 0
Private nTotLGBE 	:= 0
Private nEspFutGC   := 0
Private nTotFutGC   := 0
Private nCamOut 	:= 0
private I 			:= 0
private nManFi  	:= 0
private nTraven 	:= 0
private nQTDTot  	:= 0
private nQTDTotB 	:= 0
private nQTDTotBE 	:= 0
private nQTotLce 	:= 0
private nQTDTotC 	:= 0
private nQCamOut 	:= 0
private	nQManFi 	:= 0
private	nQTraVen 	:= 0
private nLQManFi 	:= 0
private nLManFi  	:= 0
private nLQTraVen	:= 0
Private	nLQTraVeE	:= 0
Private	nLTraVenE 	:= 0
Private	nQTraVeE	:= 0
Private	nTraVenE 	:= 0
private nLTraVen 	:= 0
private nLQSacVen	:= 0
private nLSacVen 	:= 0
private nQSacVen 	:= 0
private nSacVen  	:= 0
private NQSACOAB 	:= 0
Private nQTDtotC1	:= 0
Private nValtotC1	:= 0
Private nQTDtotC2	:= 0
Private nValtotC2	:= 0
Private nQTDtotC3	:= 0
Private nValtotC3	:= 0
Private nQTDtotC4	:= 0
Private	nValtotC4	:= 0
Private nQTDtotC5	:= 0
Private nValtotC5	:= 0
Private nQCamOut1	:= 0
Private nCamOut1 	:= 0
Private nQCamOut2	:= 0
Private nCamOut2 	:= 0
Private nQCamOut3	:= 0
Private nCamOut3 	:= 0
Private nQCamOut4	:= 0
Private nCamOut4 	:= 0
Private nQCamOut5	:= 0
Private nCamOut5 	:= 0
Private nQCamOut6 	:= 0
Private nCamOut6   	:= 0
Private nQCamOut7 	:= 0
Private nCamOut7  	:= 0
Private nQCamOut8 	:= 0
Private nCamOut8  	:= 0
Private nQCamOut9 	:= 0
Private nCamOut9  	:= 0
Private nQCamOutA 	:= 0
Private nCamOutA  	:= 0
Private nQCamOutB 	:= 0
Private nCamOutB  	:= 0
Private nQCamOutC 	:= 0
Private nCamOutC  	:= 0
Private	nQManP  	:= 0
Private nQTravP 	:= 0
Private nQTravPe    := 0 
Private nQLencP 	:= 0
Private	nQSaiaP 	:= 0
Private	nQProtP 	:= 0
Private	nQEdreP 	:= 0
Private nQCLeiP		:= 0
Private	nQCapaP 	:= 0
Private nQSacoP 	:= 0
Private nQTDtotC	:= 0
Private nVtotC  	:= 0
Private	nQSacoAC 	:= 0
Private	nVSacoAC 	:= 0
Private	nDiasS   	:= 0

Private nQTDtotD	:= 0
Private nVtotD  	:= 0

Private nQTDtotE	:= 0
Private nVtotE  	:= 0

Private nQTDtotF	:= 0
Private nVtotF  	:= 0

Private nQTCLeiF	:= 0
Private nVtCLeiF	:= 0

Private nQTDtotG	:= 0
Private nVtotG  	:= 0
Private nQTDtotH 	:= 0
Private nVtotH  	:= 0
Private	lImpLcab	:=.T.

Private _aBate 		:= {}

Private nQManAB  	:= 0
Private nQTravAB 	:= 0
Private nQTravAE	:= 0
Private nQLencAB 	:= 0
Private nQSaiaAB 	:= 0
Private nQProtAB 	:= 0
Private nQEdreAB 	:= 0
Private nQCLeiAB	:= 0
Private nQCapaAB 	:= 0

Private _aCUMES 	:= {}

Private nQManAC  	:= 0
Private nQTravAC 	:= 0
Private nQTravACe   := 0 
Private nQLencAC 	:= 0
Private nQSaiaAC 	:= 0
Private nQProtAC 	:= 0
Private nQEdreAC 	:= 0
Private nQCapaAC 	:= 0
Private nQcobreAC   := 0

Private nVManAC  	:= 0
Private nVTravAC 	:= 0
Private nVTravACe   := 0
Private nVLencAC 	:= 0
Private nVSaiaAC 	:= 0
Private nVProtAC 	:= 0
Private nVEdreAC 	:= 0
Private nVcobreAC   := 0
Private nVCapaAC 	:= 0
Private nDiasM  	:= 0
Private nDiasM   	:= 0
Private nDiasT   	:= 0
Private nDiasTe   	:= 0
Private nDiasL   	:= 0
Private nDiasS   	:= 0
Private nDiasSC   	:= 0
Private nDiasP   	:= 0
Private nDiasE   	:= 0
Private nDiasC   	:= 0
Private nDiasCL     := 0
Private nQTDlgc  	:= 0
Private nQtlen   	:= 0
Private nVTLen   	:= 0
Private nQTSai   	:= 0
Private NVTSAI   	:= 0
Private nQTSai 		:= 0
Private nVTSai 		:= 0
Private nQTProt 	:= 0
Private nVTProt 	:= 0
Private nQTEdre 	:= 0
Private nVTEdre 	:= 0
Private nQTCLei		:= 0
Private nVTCLei		:= 0
Private nQTCap 		:= 0
Private nVTCap 		:= 0
Private nQTSac 		:= 0
Private nVTSac 		:= 0
Private _nqtdleit	:= 0
Private _ntpedleit	:= 0

Private nQTDtotH 	:= 0
Private	nVtotH  	:= 0
Private	nQTSac 		:= 0
Private	nVTSac 		:= 0
Private	nQTDtotI 	:= 0
Private	nVtotI  	:= 0
Private	nQTSRec		:= 0
Private	nVTSRec		:= 0
Private nQTDtotJ 	:= 0
Private	nVtotJ  	:= 0
Private	nQTSBob		:= 0
Private	nVTSBob		:= 0
Private	nQTDtotK 	:= 0
Private	nVtotK  	:= 0
Private	nQTSBRec	:= 0
Private	nVTSBRec	:= 0
Private	nQTDtotL 	:= 0
Private	nVtotL  	:= 0
Private	nQTSFil	    := 0
Private	nVTSFil	    := 0
Private	nQTDtotM 	:= 0
Private	nVtotM  	:= 0
Private	nQTSFRec	:= 0
Private	nVTSFRec	:= 0
Private _lRpc 		:= .F.
Private _nTotTotal	:= 0
//SSI-105463 - Vagner Almeida - 18/12/2020 - Inicio
Private cLib        := ""
Private cCom        := ""
//SSI-105463 - Vagner Almeida - 18/12/2020 - Final

If _cRpc <> "S"
	ValidPerg(cPerg)
	If !Pergunte(cPerg,.T.)
		Return
	Endif
Else 
	_lRpc := .T.
	MV_PAR01 := "      "
	MV_PAR02 := "  "
	MV_PAR03 := "ZZZZZZ"
	MV_PAR04 := "ZZ"
	MV_PAR05 := 5
	MV_PAR06 := "   "
	MV_PAR07 := "ZZZ"
	MV_PAR08 := "      "
	MV_PAR09 := "ZZZZZZ"
	MV_PAR10 := 1
	MV_PAR11 := 1
	MV_PAR12 := 1
	MV_PAR13 := 1
	MV_PAR14 := 1
	MV_PAR15 := 1
	MV_PAR16 := 1
	MV_PAR17 := 1
	MV_PAR18 := 1
	MV_PAR19 := 1
	MV_PAR20 := 1
	MV_PAR21 := 1
	MV_PAR22 := 1
	MV_PAR23 := CTOD("  /  /    ")
	MV_PAR24 := "  "
	MV_PAR25 := 1
	MV_PAR26 := 2
	MV_PAR27 := 1
	MV_PAR28 := 1
	MV_PAR29 := 1
	MV_PAR30 := 1
	MV_PAR31 := 1
	MV_PAR32 := 1
	MV_PAR33 := CTOD("  /  /    ")
	MV_PAR34 := 1
	MV_PAR35 := 1
	//SSI-105463 - Vagner Almeida - 18/12/2020 - Início
	MV_PAR36 := ' '
	MV_PAR37 := 1
	MV_PAR38 := 1
	MV_PAR39 := 1
	mv_par40 := ' '
	MV_PAR41 := 2
	//SSI-105463 - Vagner Almeida - 18/12/2020 - Final
	MV_PAR42 := 1	//SSI-124131 - Vagner Almeida - 09/09/2020 
	MV_PAR43 := 1 	//SSI-123499 - Vagner Almeida - 16/09/2020 
Endif

If Empty(mv_par23)
	mv_par23:=DDATABASE //CTOD("31/12/08")
Endif

//SSI-105463 - Vagner Almeida - 18/12/2020 - Início
If _cRpc <> "S"
	IF !Empty( MV_PAR36 )
		While !( SubStr( MV_PAR36 , 1 , 1 ) $ "G" )
			IF !MsgYesNo( "Código do Gerente Informado Inválido. Redigitar?" , "Atenção" )
				Return
			EndIF
			Pergunte(cPerg,.T.)
		End While
	EndIF
Endif
//SSI-105463 - Vagner Almeida - 18/12/2020 - Final


If MV_PAR16 = 1
	titulo +=  "  ( GERAL )"
ELSEIF MV_PAR16 = 2
	titulo +=  "  ( LIBERADOS )"
ELSEIF MV_PAR16 = 3
	titulo +=  "  ( NÃO LIBERADOS )"
ELSEIF MV_PAR16 = 4
	titulo +=  "  ( QUARENTENA )"
ENDIF

oFont	:= TFont():New('Courier new',, 09,, .T.,,,,,.F.,.F.)
oFontM	:= TFont():New('Courier new',, 10,, .T.,,,,,.F.,.F.)
oFont2	:= TFont():New('Courier new',, 09,, .T.,,,,,.F.,.F.)
oFontS	:= TFont():New('Courier new',, 08,, .T.,,,,,.F.,.F.)

dbSelectArea("SM0")
dbSeek(cEmpAnt)
cNomFil := SM0->M0_FILIAL

dbSelectArea("SC5")
dbOrderNickName("PSC51")

If _cRpc <> "S"
	IF !Empty( MV_PAR36 )
		While !( SubStr( MV_PAR36 , 1 , 1 ) $ "G" )
			IF !MsgYesNo( "Código do Gerente Informado Inválido. Redigitar?" , "Atenção" )
				Return
			EndIF
			Pergunte(cPerg,.T.)
		End While
		IF !Empty( MV_PAR36 )
			TITULO += "( Gerente: " + MV_PAR36 + " " + AllTrim( Posicione("SA3",1,xFilial("SA3")+MV_PAR36,"A3_NREDUZ" ) + " " ) + ")"
		EndIF
	EndIF
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a interface padrao com o usuario...                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If _cRpc <> "S"
	oPrn := TMSPrinter():New( titulo )
	oPrn:Setup()
	
	oPrn:SetLandscape()   // Modo Paisagem
	oPrn:SetPaperSize(09) // Formato A4
	
	if !oPrn:Canceled()
		Processa( {|| GeraRel(@oPrn) }, "Aguarde...", "Gerando Relatório...",.T.)
		
		oPrn:Preview()
		oPrn:End()
	EndIf
Else
	GeraRel(@oPrn)
	If _cRpc == "S" .and. alltrim(_cNRot) == "ORTPMPRG" .and. alltrim(_cInfRet) == "CARTGER"
		Return _nTotTotal
	Endif
EndIf

FreeObj(oPrn)
oPrn := Nil

Return

*****************************
Static Function GeraRel(oPrn)
*****************************

Local nOrdem
Local cQuery
Local nTime     := 1
Local nVez      := 1
Private nValor  := 0
Private	_lPedProb	:=	.F.
Private aRota:={}
Private nEsp 	:= 50
Private nZcont  := 0

Private _nIndic	:=0
Private _aPProd :={}

Private nTotPeso:=0

Private	nMix    := 0
Private	nTOTmix := 0
Private	nQtdMix := 0

Private aLinha	  := {} //SSI-124131 - Vagner Almeida - 09/09/2021
Private aDetalhe  := {} //SSI-124131 - Vagner Almeida - 09/09/2021

nTxUpme	:= Posicione("SM2",1,DToS(dDataBase),"M2_MOEDA5")

FVALIDARRAY('1',_aSegmento)
aSort(_aSegmento,,,{|x,y| x[2]<y[2]})

FVALIDARRAY('1',_aSegmentA)
aSort(_aSegmentA,,,{|x,y| x[2]<y[2]})

FVALIDARRAY('1',_aSegmentB)
aSort(_aSegmentB,,,{|x,y| x[2]<y[2]})

cQuery :="SELECT A1_XROTA, MAX(ZQ_DTPREVE) DTPREVE "
cQuery += "  FROM "+RetSQLName("SZQ")+" SZQ, "+RetSQLName("SC5")+" SC5, "+RetSQLName("SA1")+" SA1 "
cQuery += " WHERE SZQ.D_E_L_E_T_ = ' '   "
cQuery += "   AND SC5.D_E_L_E_T_ = ' '   "
cQuery += "   AND SA1.D_E_L_E_T_ = ' '   "
cQuery += "   AND ZQ_EMBARQ = C5_XEMBARQ   "
cQuery += "   AND C5_CLIENTE = A1_COD    "
cQuery += "   AND C5_LOJACLI = A1_LOJA   "
cQuery += "   AND ZQ_FILIAL = '"+xFilial("SZQ")+"'  "
cQuery += "   AND C5_FILIAL = '"+xFilial("SC5")+"'     "
cQuery += "   AND A1_FILIAL = '"+xFilial("SA1")+"'     "
cQuery += " GROUP BY A1_XROTA         "
cQuery += " ORDER BY 1                 "
memowrit("c:\ortr077reg.sql",cQuery)
If Select("TSC5") > 0
	dbSelectArea("TSC5")
	TSC5->(DbCloseArea())
EndIf
TcQuery cQuery Alias "TSC5" New
dbselectarea("TSC5")
dbgotop()
do while !eof()
	aadd(aRota,{TSC5->A1_XROTA,TSC5->DTPREVE})
	dbskip()
enddo
dbclosearea()
cQuery := " SELECT SUM(100 * (C6_XPRUNIT - C6_XCUSTO) / (Case when C6_XPRUNIT=0 then 1 else C6_XPRUNIT End)) AS CMIX, (CASE WHEN C5_XOPER = '17' OR C5_XOPER = '02' OR C5_XOPER = '03'  THEN 0 ELSE 1 END) ORDT, "
cQuery += "	(TO_DATE("+Dtos(dDataBase)+",'YYYYMMDD')- TO_DATE(C5_EMISSAO,'YYYYMMDD')) ORDD, SA1.A1_COD, SA1.A1_LOJA, SA1E.A1_NOME A1_NOMEE, SA1.A1_NOME, SA1.A1_MUN, "
cQuery += "	SA1.A1_BAIRRO, SA1.A1_XROTA,SA1.A1_XTIPO, ZH_ITINER, C5_VEND1, SA1.A1_CGC, C5_XPEDCLI, "
cQuery += "	(SELECT SZ3.Z3_DESC                            "
cQuery += "	   FROM "+RetSqlName('SZ3')+" SZ3"
cQuery += "	  WHERE Z3_CODIGO = SA1.A1_XROTA                "
cQuery += "	    AND SZ3.D_E_L_E_T_ = ' '                     "
cQuery += "	    AND SZ3.Z3_FILIAL = '"+xFilial("SZ3")+"') ZONAV, "
cQuery += "NVL(A3_NOME,'SEM VENDEDOR') A3_NOME, C5_NUM, C5_TIPO, C5_TABELA, C5_XOPER, C5_CLIENTE, "
cQuery += "       (SELECT (CASE WHEN COUNT(*) > 0 THEN '1' ELSE '0' END) "
cQuery += "          FROM "+RETSQLNAME("SZE")
cQuery += "         WHERE D_E_L_E_T_ = ' ' "
cQuery += "           AND ZE_FILIAL = '"+xFilial("SZE")+"'"
cQuery += "           AND ZE_PEDIDO = C5_NUM "
cQuery += "           AND ZE_USUARIO = ' ' "
cQuery += "           AND ZE_AUTORIZ IN ('BLQMIX','BLQBRD','BLQPZM')) REGCOM, "
cQuery += "       (SELECT (CASE WHEN COUNT(*) > 0 THEN '1' ELSE '0' END) "
cQuery += "          FROM "+RETSQLNAME("SZE")
cQuery += "         WHERE D_E_L_E_T_ = ' '  "
cQuery += "           AND ZE_FILIAL = '"+xFilial("SZE")+"'"
cQuery += "           AND ZE_PEDIDO = C5_NUM "
cQuery += "           AND ZE_USUARIO = ' ' "
cQuery += "           AND ZE_AUTORIZ IN ('BLQDEB','BLQPEN','BLQSOC','BLQCOM','BLQPRZ','BLQPNV','BLQPDC')) REGCOB, "
//SSI-105463 - Vagner Almeida - 18/12/2020 - Incício 
cQuery += "        RPAD(DECODE(SA1.A1_XBLQDOC, '1', 'BLQLDO', '') || (SELECT RPAD(REGEXP_REPLACE(LISTAGG(DECODE(TIPO, "
cQuery += "                                                   'M', "
cQuery += "                                                   'BLQLMA', "
cQuery += "                                                   'C', "
cQuery += "                                                   'BLQLCA', "
cQuery += "                                                   'D', "
cQuery += "                                                   'BLQLDO', "
cQuery += "                                                   'P', "
cQuery += "                                                   'BLQLNP', "
cQuery += "                                                   'F', "
cQuery += "                                                   'BLQLFB', "
cQuery += "                                                   '      '), "
cQuery += "                                            '|') WITHIN "
cQuery += "                                    GROUP(ORDER BY DECODE(TIPO, "
cQuery += "                                                 'M', "
cQuery += "                                                 'BLQLMA', "
cQuery += "                                                 'C', "
cQuery += "                                                 'BLQLCA', "
cQuery += "                                                 'D', "
cQuery += "                                                 'BLQLDO', "
cQuery += "                                                 'P', "
cQuery += "                                                 'BLQLNP', "
cQuery += "                                                 'F', "
cQuery += "                                                 'BLQLFB', "
cQuery += "                                                 '      ')), "
cQuery += "                                    '([^|]+)(\|\1)+($|,)', "
cQuery += "                                    '\1\3') || ' ', "
cQuery += "                     30) "
cQuery += "           FROM SIGA.BLQSISLOJA "
cQuery += "          WHERE UNIDADE = '"+cEmpAnt+"' "
cQuery += "            AND CNPJ = SA1.A1_CGC "
cQuery += "            AND DATALIB = '        ' "
cQuery += "            AND TIPO IN ('M', 'C', 'D', 'P', 'F')), 30) AS REGLOJ, "
//SSI-105463 - Vagner Almeida - 18/12/2020 - Final
cQuery += "        (SELECT (CASE WHEN COUNT(*) > 0 THEN '1' ELSE '0' END) "
cQuery += "          FROM "+RETSQLNAME("SZE")
cQuery += "         WHERE D_E_L_E_T_ = ' '   "
cQuery += "           AND ZE_FILIAL = '"+xFilial("SZE")+"' "
cQuery += "           AND ZE_PEDIDO = C5_NUM  "
cQuery += "           AND ZE_USUARIO = ' ' "
cQuery += "           AND ZE_AUTORIZ NOT IN ('BLQMIX','BLQBRD','BLQPZM','BLQSBM','BLQREP','BLQDEB','BLQPEN','BLQSOC','BLQCOM')) FABCOB, "
cQuery += " C5_EMISSAO, SA1.A1_XQTDLP,SA1.A1_XQTDCHS,SA1.A1_XQTDCTS,SA1.A1_XQTDPRG,SA1.A1_XQTDPRO, SA1.A1_XQTDPEN,SA1.A1_XROTA, "
cQuery += " C5_XPERENT,SA1.A1_XQTDPRM, C5_XDTLIB, C5_XTPSEGM, C5_XEMBARQ, C5_XNPVORT, "
cQuery += " SUM((C6_QTDVEN * B1_XESPACO)/DECODE(C5_XTPCOMP,'V',3,'C',2,1)) AS ESPACO, C5_XENTREG, "
// SSI 30595
cQuery += "CASE WHEN C5_XDTLIB <> '        ' THEN"
cQuery += "          (TO_DATE(TO_CHAR(SYSDATE,'YYYYMMDD'),'YYYYMMDD') - TRUNC(TO_DATE(CASE"
cQuery += "         WHEN C5_XENTREG <> '        ' THEN                                     "
cQuery += "          C5_XENTREG                                                             "
cQuery += "         ELSE                                                                     "
cQuery += "          CASE WHEN C5_XESTCAN <> '        ' THEN C5_XESTCAN ELSE C5_EMISSAO END   "
cQuery += "       END, 'YYYYMMDD'))) ELSE(TO_DATE(TO_CHAR(SYSDATE, 'YYYYMMDD'), 'YYYYMMDD') - TRUNC(TO_DATE(CASE WHEN C5_XESTCAN <> '        ' THEN C5_XESTCAN ELSE C5_EMISSAO END, 'YYYYMMDD'))) END DIAS,"
/*
cQuery += "          (TO_DATE(TO_CHAR(SYSDATE,'YYYYMMDD'),'YYYYMMDD') - TRUNC(TO_DATE(CASE "
cQuery += "         WHEN C5_XENTREG <> ' ' THEN "
cQuery += "          C5_XENTREG "
cQuery += "         ELSE        "
cQuery += "          C5_EMISSAO "
cQuery += "       END, 'YYYYMMDD'))) DIAS, " //ELSE TO_DATE("+Dtos(dDataBase)+", 'YYYYMMDD') - TO_DATE(C5_EMISSAO, 'YYYYMMDD') END) DIAS, "
/*
/*
cQuery += "(CASE WHEN C5_XDTLIB <> ' ' THEN (TO_DATE(TO_CHAR(SYSDATE, 'YYYYMMDD'), 'YYYYMMDD') -
cQuery += "                                        TRUNC(TO_DATE(CASE WHEN C5_XENTREG <> ' ' THEN
cQuery += "                                                          C5_XENTREG
cQuery += "                                                     ELSE
cQuery += "                                                          C5_EMISSAO
cQuery += "                                                     END , 'YYYYMMDD')))
cQuery += "            ELSE
cQuery += "                TO_DATE("+Dtos(dDataBase)+", 'YYYYMMDD') - TO_DATE(C5_EMISSAO, 'YYYYMMDD')
cQuery += "            END) DIAS," // DIAS EM ATRASO PELA DT DE ENTREGA
*/

// ALTERADO EM 17/07/09
//cQuery += " SUM(C6_QTDVEN * (CASE WHEN C5_XOPER = '07' THEN C6_PRCVEN ELSE C6_XPRUNIT END)) AS TOTPED, "

If cEmpAnt == '21'
   cQuery+="    Sum((SC6.C6_QTDVEN - (Select NVL(Sum(ITROM.QUANT), 0) As QUANT
   cQuery+="                          From Siga.CABROM210 CABROM, Siga.ITROM210 ITROM
   cQuery+="                          Where CABROM.FILIAL = '02'
   cQuery+="                            And CABROM.TIPOROM = 'F'
   cQuery+="                            And ITROM.FILIAL = '02'
   cQuery+="                            And ITROM.NUMROMAN = CABROM.NUMROMAN
   cQuery+="                            And CABROM.NUMPV = SC5.C5_NUM
   cQuery+="                            And ITROM.PRODORIG = SC6.C6_PRODUTO
   cQuery+="                            And (SubStr(ITRom.NFISCAL, 1, 1) <> ' ' Or ITRom.NFISCAL Is Not Null)
   cQuery+="                            And Not Exists (Select SD1.D1_DOC
   cQuery+="                                            From Siga." +RetSQLName("SD1")+ " SD1
   cQuery+="                                            Where SD1.D1_FILIAL = '" +xFilial("SD1")+ "'
   cQuery+="                                              And SD1.D1_NFORI = ITRom.NFISCAL
   cQuery+="                                              And SD1.D1_LOTECTL = ITRom.LOTECTL
   cQuery+="                                              And SD1.D1_COD = ITRom.PRODORIG
   cQuery+="                                              And SD1.D_E_L_E_T_ = ' ')))  * C6_PRUNIT) As TOTPED,
   cQuery+="    Sum(C6_QTDVEN) As C6_QTDVEN, "

//SSI-123499 - Vagner Almeida - 16/09/2020 - Inicio
ElseIf cEmpAnt == '24' .And. MV_PAR43 == 2
   cQuery+="    (CASE                                                                       "
   cQuery+="         WHEN C5_XTPSEGM = '3' AND C5_XOPER <> '07' AND C5_XOPER <> '08' THEN   "
   cQuery+="          SUM(((C6_XPRUNIT - ((C6_XGUELTA + C6_XRESSAR) * C6_XPRUNIT / 100))) * "
   cQuery+="              C6_QTDVEN - C6_XFEILOJ)                               "
   cQuery+="         ELSE                                          "
   cQuery+="          SUM(CASE                                     "
   cQuery+="         WHEN C5_XOPER = '07' OR C5_XOPER = '08' THEN "
   cQuery+="          C6_PRCVEN  * C6_QTDVEN - C6_XFEILOJ  "
   cQuery+="         ELSE                    "
   cQuery+="          C6_XPRUNIT * C6_QTDVEN - C6_XFEILOJ"
   cQuery+="       END) "
   cQuery+="       END) AS TOTPED, "
   cQuery+="    C6_QTDVEN, "
//SSI-123499 - Vagner Almeida - 16/09/2020 - Final
Else
   cQuery+="    (CASE                                                                       "
   cQuery+="         WHEN C5_XTPSEGM = '3' AND C5_XOPER <> '07' AND C5_XOPER <> '08' THEN   "
   cQuery+="          SUM(((C6_XPRUNIT - ((C6_XGUELTA + C6_XRESSAR) * C6_XPRUNIT / 100))) * "
   cQuery+="              C6_QTDVEN)                               "
   cQuery+="         ELSE                                          "
   cQuery+="          SUM(CASE                                     "
   cQuery+="         WHEN C5_XOPER = '07' OR C5_XOPER = '08' THEN "
   cQuery+="          C6_PRCVEN * C6_QTDVEN  "
   cQuery+="         ELSE                    "
   cQuery+="          C6_XPRUNIT * C6_QTDVEN "
   cQuery+="       END) "
   cQuery+="       END) AS TOTPED, "
   cQuery+="    C6_QTDVEN, "
EndIf   

//Adicionado por Bruno para Calculo da Rentabilidade
cQuery += " (SELECT SUM(C6_QTDVEN * (CASE WHEN C5_XOPER = '07' THEN C6_PRCVEN  ELSE  C6_XPRUNIT   END)) FROM "+RetSQLName("SC6")+" WHERE D_E_L_E_T_ = ' ' "
cQuery += " AND C6_FILIAL = '"+ xFilial("SC6") + "'"+" AND C6_NUM = C5_NUM AND C6_PRODUTO LIKE '407095%') TERC, "
cQuery += " C5_XMIX, "
//Fim
cQuery += " C5_XENTREF, BM_XSUBGRU, C5_XOPER , sum((select SUM(B2_QATU) "
cQuery += "                           from "+RetSQLName("SB2") + " SB2 WHERE D_E_L_E_T_ = ' ' AND B2_QATU > 0 "
cQuery += "                            AND B2_COD = C6_PRODUTO AND B2_LOCAL = '18')) QTDEST , C5_XESTCAN "
//If MV_PAR13 = 2 //.Or.	mv_par18	=	2  //.or. mv_par20 = 2
cQuery += ", C6_PRODUTO, C6_DESCRI, "
cQuery += " (CASE WHEN B1_XMODELO = ' ' THEN 'NAO CADASTRADO' ELSE B1_XMODELO END) B1_XMODELO, B1_XMED,B1_XPERSON, BM_GRUPO, B1_PESO	 "
//Endif
cQuery += " FROM " + RetSQLName("SC6") + " SC6, "
cQuery += RetSQLName("SB1") + " SB1, "
cQuery += RetSQLName("SA1") + " SA1, "
cQuery += RetSQLName("SA1") + " SA1E, "
cQuery += RetSQLName("SA3") + " SA3, "
cQuery += RetSQLName("SC5") + " SC5, "
cQuery += RetSQLName("SZH") + " SZH, "
If cEmpAnt == '24'
	if  MV_PAR35 > 2 //SSI 12674
		cQuery += RetSQLName("SC2") + " SC2, "
	EndIf
EndIf
cQuery += RetSQLName("SBM") + " SBM,  CARTEIRA"+cEmpAnt+"0 "
cQuery += " WHERE B1_GRUPO = BM_GRUPO    "
cQuery += " AND SC5.R_E_C_N_O_ = REC     "
cQuery += " AND SA3.A3_COD(+) = C5_VEND1    "
//SSI-105463 - Vagner Almeida - 18/12/2020 - Início
If ! Empty( MV_PAR36 )
	cQuery += " AND SA3.A3_GEREN = '" + MV_PAR36 + "'"
EndIf
//SSI-105463 - Vagner Almeida - 18/12/2020 - Final
cQuery += " AND SC5.C5_NUM = C6_NUM      "
cQuery += " AND C5_CLIENTE = C6_CLI      "
cQuery += " AND C5_LOJACLI = C6_LOJA     "
cQuery += " AND B1_COD = C6_PRODUTO      "
If cEmpAnt == '24' .and. MV_PAR35 > 2 //SSI 12674
	cQuery += " AND C2_NUM = C6_NUMOP      "
	cQuery += " AND C2_PRODUTO = C6_PRODUTO      "
	cQuery += " AND SC2.D_E_L_E_T_ = ' ' "
	cQuery += " AND C2_FILIAL = '" + xFilial("SC2") + "'"
EndIf
cQuery += " AND ZH_CLIENTE (+)= C5_CLIENTE  "
cQuery += " AND ZH_LOJA  (+)= C5_LOJACLI    "
cQuery += " AND ZH_VEND  (+)= C5_VEND1      "
cQuery += " AND ZH_SEGMENT(+)= C5_XTPSEGM   "
cQuery += " AND SA1.A1_COD = C5_CLIENTE     "
cQuery += " AND SA1E.A1_COD (+)= C5_XCLITRO "
cQuery += " AND SA1.A1_LOJA = C5_LOJACLI     "
cQuery += " AND SA1E.A1_LOJA (+)= C5_XLOJATR "
cQuery += " AND C5_XEMBARQ = ' '"
cQuery += " AND C6_NOTA = ' '   "
//cQuery += " AND SX5.X5_TABELA = 'ZA'  	  "
//cQuery += " AND SX.X5_TABELA(+) = 'ZD'    "
cQuery += " AND C5_XACERTO	=	' '      " /**********/

//SSI-105463 - Vagner Almeida - 18/12/2020 - Início
//cQuery += " AND C5_XOPER NOT IN ('13','20','21','99') "  //Não lista pedidos "Não repor" e "Cancelados"

If MV_PAR39 == 2 // Origem (DE)
	cQuery += " AND C5_XOPER NOT IN ('20','21','96','99') " 
Else
	cQuery += " AND C5_XOPER NOT IN ('13','20','21','96','99') "	
Endif

//cQuery += " AND C5_CLIENTE between '" + MV_PAR01 + "' and '" + MV_PAR03 + "'"
//cQuery += " AND C5_LOJACLI between '" + MV_PAR02 + "' and '" + MV_PAR04 + "'"
IF MV_PAR37 == 1
	cQuery += " AND C5_CLIENTE between '" + MV_PAR01 + "' and '" + MV_PAR03 + "'"
	cQuery += " AND C5_LOJACLI between '" + MV_PAR02 + "' and '" + MV_PAR04 + "'"
ELSE
	cQuery += " AND C5_CLIENTE IN	(SELECT A1_COD "
	cQuery += "						   FROM SIGA."+RetSQLName("SA1")+" SA11 "
	cQuery += "						  WHERE A1_XCODGRU IN (SELECT A1_XCODGRU "
	cQuery += "												 FROM SIGA."+RetSQLName("SA1")+" SA12 "
	cQuery += "												WHERE A1_COD between '" + MV_PAR01 + "' and '" + MV_PAR03 + "'))"
Endif

If !Empty(MV_PAR40)
	cQuery += " AND UPPER(SA1.A1_BAIRRO) = ('" + UPPER(MV_PAR40) + "') "
EndIf

If MV_PAR41 == 1
	cQuery += " AND C5_XOPER <> '23'     "
ElseIf MV_PAR41 == 3
	cQuery += " AND C5_XOPER = '23'     "
EndIf

//SSI-105463 - Vagner Almeida - 18/12/2020 - Final

cQuery += " AND C5_TABELA BETWEEN '" + MV_PAR06 + "' AND '" + MV_PAR07 + "'"
cQuery += " AND C5_VEND1 between '" + MV_PAR08 + "' and '" + MV_PAR09 + "'"
If MV_PAR05 <> 5
	cQuery += " AND C5_XTPSEGM = '" + STRZERO(MV_PAR05,1) + "'"
Endif
If MV_PAR10 = 1
	cQuery += " AND B1_COD NOT LIKE '407095%' "                       // NAO LISTA TERCEIROS
Else
	If MV_PAR12 = 2
		cQuery += " AND B1_COD LIKE '407095%' "                      // LISTA SOMENTE TERCEIROS SE O PARAMETRO 9 FOR IGUAL A 2 (SIM)
	Endif
Endif

IF MV_PAR25 = 2 .OR. MV_PAR26 = 2 .OR. MV_PAR27 = 2 .OR. MV_PAR28 = 2 .OR. MV_PAR29 = 2 .OR. MV_PAR30 = 2 .OR. MV_PAR31 = 2 .OR. MV_PAR32 = 2
	cOpr := "("
	If MV_PAR25 = 2
		cOpr += "'02','03','17',"                 // TROCAS
	Endif
	If MV_PAR26 = 2
		cOpr += "'01','12','13',"                 // NORMAL
	Endif
	If MV_PAR27 = 2
		cOpr += "'22',"                           // QUIMICO
	Endif
	If MV_PAR28 = 2
		cOpr += "'07',"                           // DEMOSTRACAO
	Endif
	If MV_PAR29 = 2
		cOpr += "'08',"                           // REPOSICAO
	Endif
	If MV_PAR30 = 2
		cOpr += "'05',"                           // BONIFICACAO
	Endif
	If MV_PAR31 = 2
		cOpr += "'09',"                           // CONSERTO
	Endif
	If MV_PAR32 = 2
		cOpr += "'06','24','25',"                 // CONSERTO
	Endif
	
	cOpr := SUBSTR(cOpr,1,LEN(COPR)-1)
	cQuery += "AND C5_XOPER IN "+cOpr+")"
ENDIF

If cEmpAnt == "21"  // Henrique - 16/03/2021
   /*
   cQuery+= "  AND C5_NUM Not In (Select C5_XPEDCLI "
   cQuery+= "                     From Siga." +RetSQLName("SC5")+ " C5 "
   cQuery+= "                     Where C5.D_E_L_E_T_ = ' ' "
   cQuery+= "                     AND C5_XPEDCLI <> ' ' "
   cQuery+= "                     AND C5_XOPER <> '99') "
   */
   cQuery+= "  AND C6_BLQ <> 'R' "
   cQuery+= "  AND (Select NVL(Sum(ITROM.QUANT),0) As QUANT "
   cQuery+= "       From Siga.CABROM210 CABROM, "
   cQuery+= "            Siga.ITROM210 ITROM "         
   cQuery+= "       Where CABROM.FILIAL      = '02' "
   cQuery+= "         And CABROM.TIPOROM     = 'F' "
   cQuery+= "         And ITROM.FILIAL       = '02' "
   cQuery+= "         And ITROM.NUMROMAN     = CABROM.NUMROMAN "
   cQuery+= "         And CABROM.NUMPV       = SC5.C5_NUM "
   cQuery+= "         And ITROM.PRODORIG     = SC6.C6_PRODUTO "
   cQuery+= "         And (SubStr(ITRom.NFISCAL,1,1) <> ' ' Or ITRom.NFISCAL Is Not Null) " 
   cQuery+= "         And Not Exists (Select SD1.D1_DOC " 
   cQuery+= "                         From Siga." +RetSQLName("SD1")+ " SD1 " 
   cQuery+= "                         Where SD1.D1_FILIAL        = '" +xFilial("SD1")+ "' "
   cQuery+= "                           And SD1.D1_NFORI         = ITRom.NFISCAL "
   cQuery+= "                           And SD1.D1_LOTECTL       = ITRom.LOTECTL "
   cQuery+= "                           And SD1.D1_COD           = ITRom.PRODORIG "
   cQuery+= "                           And SD1.D_E_L_E_T_ = ' '))-SC6.C6_QTDVEN < 0 "
EndIf

If MV_PAR15 = 2
	cQuery += " AND C5_XENTREF <> ' ' "                           // C/DATA ENTREGA
Endif
If mv_par16 = 2
	cQuery += " AND C5_XDTLIB <> ' '  AND C5_XQUAREN != '1'  "                            // LIBERADOS
ElseIf mv_par16 = 3
	cQuery += " AND C5_XDTLIB = ' '  AND C5_XQUAREN != '1'  "                             // NAO LIBERADOS
ElseIf mv_par16 = 4
	cQuery += " AND C5_XQUAREN = '1' "                            // QUARENTENA
Endif
/*If mv_par16 = 2
	cQuery += " AND C5_XDTLIB <> ' ' "                            // LIBERADOS
ElseIf mv_par16 = 3
	cQuery += " AND C5_XDTLIB = ' ' "                             // NAO LIBERADOS
Endif*/
If mv_par17 = 2
	cQuery += " AND C5_XTPSEGM = '3' "					 // Só Lojas
ElseIf mv_par17 = 3
	cQuery += " AND C5_XTPSEGM <> '3' "                    // Sem Lojas
EndIf

If cEmpAnt == '24' .And. MV_PAR35 == 2 //Sem Gerar OP
	cQuery += " AND C6_NUMOP = ' ' "
ElseIf cEmpAnt == '24' .And. MV_PAR35 == 3 //OP gerada
	cQuery += " AND C6_NUMOP <> ' ' "
	cQuery += " AND C2_PRIOR <>  '999' "
ElseIf cEmpAnt == '24' .And. MV_PAR35 == 4 //OP finalizada
	cQuery += " AND C6_NUMOP <> ' ' "
	cQuery += " AND C2_PRIOR =  '999' "
Endif

cQuery += " AND SC6.D_E_L_E_T_ = ' ' "
//cQuery += " AND SZE.D_E_L_E_T_(+) = ' ' "
cQuery += " AND SB1.D_E_L_E_T_ = ' ' "
cQuery += " AND SA1.D_E_L_E_T_ = ' ' "
cQuery += " AND SA1E.D_E_L_E_T_ (+)= ' ' "
cQuery += " AND SA3.D_E_L_E_T_(+) = ' ' "
cQuery += " AND SC5.D_E_L_E_T_ = ' ' "
cQuery += " AND SZH.D_E_L_E_T_ (+)= ' ' "
cQuery += " AND SBM.D_E_L_E_T_ = ' ' "
cQuery += " AND C6_FILIAL = '" + xFilial("SC6") + "'"
cQuery += " AND B1_FILIAL = '" + xFilial("SB1") + "'"
cQuery += " AND SA1.A1_FILIAL = '" + xFilial("SA1") + "'"
cQuery += " AND SA1E.A1_FILIAL (+)= '" + xFilial("SA1") + "'"
cQuery += " AND A3_FILIAL(+) = '" + xFilial("SA3") + "'"
cQuery += " AND C5_FILIAL = '" + xFilial("SC5") + "'"
cQuery += " AND ZH_FILIAL (+)= '" + xFilial("SZH") + "'"
cQuery += " AND BM_FILIAL = '" + xFilial("SBM") + "'"
//cQuery += " AND SZE.ZE_FILIAL(+) = '" + xFilial("SZE") + "'"
cQuery += " GROUP BY SA1.A1_COD, SA1.A1_LOJA, SA1.A1_NOME,SA1E.A1_NOME, SA1.A1_MUN, SA1.A1_BAIRRO, SA1.A1_XROTA,SA1.A1_XTIPO,ZH_ITINER, "
cQuery += " C5_VEND1, A3_NOME, C5_NUM, C5_TIPO, C5_TABELA, C5_XOPER, C5_EMISSAO,SA1.A1_XQTDLP,SA1.A1_XQTDCHS,SA1.A1_XQTDCTS,SA1.A1_XQTDPRG, "
cQuery += " SA1.A1_XQTDPRO,SA1.A1_XQTDPEN, SA1.A1_XQTDPRM,SA1.A1_XROTA, C5_XPERENT, C5_XDTLIB, C5_XTPSEGM,  C5_XNPVORT, "
cQuery += " C5_XEMBARQ,  C5_XENTREG, C5_XENTREF, C5_XMIX, C5_XOPER, C5_CLIENTE, SA1.A1_CGC,C5_XESTCAN, C5_XPEDCLI,BM_XSUBGRU  "
//If MV_PAR13 = 2 //.Or.	mv_par18	=	2  //.or. mv_par20 = 2
If cEmpAnt == '21'
   cQuery += " , C6_PRODUTO, C6_DESCRI, B1_XMODELO, C5_XEMBARQ, "
Else
   cQuery += " , C6_PRODUTO, C6_DESCRI, C6_QTDVEN, B1_XMODELO, C5_XEMBARQ, "
EndIf   

cQuery += " SA1.A1_XBLQDOC, "	//SSI-105463 - Vagner Almeida - 18/12/2020 
cQuery += " B1_XPERSON, B1_XMED, C5_XENTREG, C5_XENTREF, C5_XOPER, BM_GRUPO, B1_PESO  "

//Endif
If mv_par21==2 .AND. mv_par22 ==1
	cQuery += "ORDER BY A3_NOME, ORDT, DIAS DESC "
Elseif mv_par22 ==2 .AND. mv_par21==1
	cQuery += "ORDER BY ZONAV, ORDT, DIAS DESC "
ElseIf  mv_par22 ==2 .AND. mv_par21==2
	cQuery += "ORDER BY ZONAV, A3_NOME, ORDT, DIAS DESC "
Else
	cQuery += "ORDER BY ORDT, DIAS DESC "
EndIf

If	MV_PAR14	=	1
	cQuery += ", C5_NUM DESC"
Else
	If	MV_PAR14	=	1
		//		cQuery += ", "+Iif(MV_PAR14 = 2,"SA1E.A1_NOME","SA1.A1_NOME")+",C5_NUM DESC"
	Else
		cQuery += ",SA1.A1_BAIRRO,C5_NUM DESC"
	Endif
Endif

memowrit("c:\ortr077.sql",cQuery)
TcQuery cQuery Alias "TSC5" New

DbSelectArea("TSC5")
DbGoTop()

if !_lRpc
	ProcRegua(RecCount())
endif

_cVend     := TSC5->C5_VEND1
_cVendedor := TSC5->C5_VEND1 + "-" + TSC5->A3_NOME
_cRoteiro  := TSC5->ZH_ITINER
nGCli      := 0
nVTotPed   := 0
nVTotSimBA := 0 //SSI-123499 - Vagner Almeida - 20/09/2021
nTot_D     := 0
nTot_B     := 0
nTot_T     := 0
nTot_N     := 0
nTotLE     := 0
nTotVI 	   := 0
nTot_C     := 0
nTotPed    := 0
nTotEsp    := 0
nTotCEnt   := 0
nTotRP     := 0
nPed       := 0   // total geral de pedidos
nTroc      := 0   // total geral de trocas
nTrocM8    := 0   // trocas com mais de 8 dias
nVendM8    := 0   // vendas com mais de 8 dias
nVendM15   := 0   // vendas com mais de 15 dias
nATrEnt    := 0   // atraso na entrega
nATrLib    := 0   // atraso na liberacao
nTotNFat   := 0   // total nao faturado

x := 0

nLin := fImpCab("1",.T., oPrn)

DbSelectArea("TSC5")
Do While !Eof()
	if !_lRpc
		IncProc()
	endif
	_nIndic += 1
	
	If MV_PAR11 = 2              // somente em atraso
		IF MV_PAR14 = 2 .AND. DDATABASE-STOD(C5_EMISSAO) <= Val(mv_par24)
			DbSelectArea("TSC5")
			dbskip()
			Loop
		Endif
		
		IF C5_XOPER == "02" .OR. C5_XOPER == "03" .OR. C5_XOPER == "17"
			IF DDATABASE-STOD(C5_EMISSAO) <= Val(mv_par24)
				DbSelectArea("TSC5")
				dbskip()
				Loop
			ENDIF
		ELSE
			IF DDATABASE-STOD(C5_EMISSAO) <= Val(mv_par24) //< 15
				DbSelectArea("TSC5")
				dbskip()
				Loop
			ENDIF
		ENDIF
	Endif
	
	DbSelectArea("TSC5")
	
	cCdcm := " "
	
	IF TSC5->C5_XDTLIB = " "
		
		cCob := ALLTRIM(TSC5->REGCOB)
		ccom := ALLTRIM(TSC5->REGCOM) //SSI-105463 - Vagner Almeida - 18/12/2020 
		
		IF ALLTRIM(TSC5->REGCOM) = "1" .AND.  cCob <> "1"
			If Empty(cCdcm)
				cCdcm := " /S"
			Endif
		ELSEIF cCob = "1" .AND. ALLTRIM(TSC5->REGCOM) <> '1'
			If Empty(cCdcm)
				cCdcm := "S/"
			Endif
		ELSEIF ALLTRIM(TSC5->REGCOM) == "1" .AND. cCob = "1"
			If Empty(cCdcm)
				cCdcm := "S/S"
			Endif
		ELSE
			If Empty(cCdcm)
				cCdcm := " /"
			Endif
		ENDIF
	ENDIF
	
	_lPedProb	:=	.F.
	
	IF TSC5->A1_XQTDLP > 0  .OR. TSC5->A1_XQTDCHS > 0 ;
		.OR. TSC5->A1_XQTDCTS > 0	.OR. TSC5->A1_XQTDPRG > 0 ;
		.OR. TSC5->A1_XQTDPRO > 0 .OR. TSC5->A1_XQTDPEN > 0 ;
		.OR. TSC5->A1_XQTDPRM > 0
		
		_nPos	:=	aScan(_aPedProb,{|x| Alltrim(x[8])==Alltrim(TSC5->C5_NUM)})
		
		If	_nPos	=	0
			/*1*/	            /*2*/            /*3*/           /*4*/             /*5*/          /*6*/            /*7*/             /*8*/
			AADD(_aPedProb,{TSC5->A1_XQTDLP,TSC5->A1_XQTDCHS,TSC5->A1_XQTDCTS,TSC5->A1_XQTDPRG,TSC5->A1_XQTDPRO,TSC5->A1_XQTDPEN,TSC5->A1_XQTDPRM,TSC5->C5_NUM})
			
		Endif
		_lPedProb	:=	.T.
		
	ENDIF
	
	x := x+1
	cNum  := TSC5->C5_NUM
	// SSI 30208
	nPeso := FscGetPeso(cNum) //SSI 20485
	nMix  := TSC5->CMIX
	nTOTmix += nMix
	nQtdMix += 1
	DbSelectArea("TSC5")
	//--
	cPOrt := TSC5->C5_XNPVORT
	cOper := BuscStat(TSC5->C5_XOPER)
	dLib  := TSC5->C5_XDTLIB
	cNomV := TSC5->A3_NOME
	dEstCan := TSC5->C5_XESTCAN
	
	If TSC5->C5_XOPER = '02'		.Or.	TSC5->C5_XOPER = '03'	.Or.	TSC5->C5_XOPER = '17'
		cNomC :=	TSC5->A1_NOMEE
	Else
		cNomC :=	TSC5->A1_NOME
	Endif
	
	cOrdCom:=C5_XPEDCLI
	dEmi  := TSC5->C5_EMISSAO
	cRota := TSC5->A1_XROTA
	cZona := AllTrim(TSC5->A1_XROTA)
	cCid  := TSC5->A1_MUN
	If TSC5->C5_TIPO $ "B/D"
		cCid  := Posicione("SA2",1,xFilial("SA2")+TSC5->A1_COD,"SA2->A2_MUN")
		cZona := " "
		cRota := " "
	EndIf
	cTab  := TSC5->C5_TABELA
	cEntr := TSC5->C5_XENTREG
	cEntrF:= TSC5->C5_XENTREF
	cItin := TSC5->ZH_ITINER
	cZonaV:= TSC5->ZONAV
	nDias := TSC5->DIAS
	nPos:=ascan(aRota,{|x| x[1]==TSC5->A1_XROTA})
	if nPos > 0
		cUltEmb:=aRota[nPos,2]
	else
		cUltEmb:=space(08)
	Endif
	//SSI-105463 - Vagner Almeida - 17/12/2020 - Início
	/*
	If !Empty(dLib)
		cLib := "S"
	Else
		If ALLTRIM(TSC5->REGCOM) == "1" .OR. ALLTRIM(TSC5->REGCOB) == "1"
			cLib := "R"               // Nao liberado, aguardando procedimento da regional
		Else
			cLib := "N"               // Nao liberado, aguardando procedimento da fabrica
		Endif
	Endif
	*/
	cLib	:= ""
	If !Empty(dLib) .And. !("BLQLMA" $ TSC5->REGLOJ .Or. "BLQLCA" $ TSC5->REGLOJ .Or. "BLQLDO" $ TSC5->REGLOJ .Or. "BLQLNP" $ TSC5->REGLOJ)
		cLib	:= "S"
	Else
		If AllTrim(TSC5->REGCOM) == "1" .Or. AllTrim(TSC5->REGCOB) == "1"
			cLib	+= "R"
		EndIf
		If "BLQLMA" $ TSC5->REGLOJ
			cLib	+= "M"
		EndIf
		If "BLQLCA" $ TSC5->REGLOJ
			cLib	+= "C"
		EndIf
		If "BLQLDO" $ TSC5->REGLOJ
			cLib	+= "D"
		EndIf
		If "BLQLNP" $ TSC5->REGLOJ
			cLib	+= "P"
		EndIf
		If "BLQLFB" $ TSC5->REGLOJ
			cLib	+= "F"
		EndIf
		If Empty(cLib)
			cLib	:= "N"
		EndIf
	Endif
	
	if Clib = "R"
		If MV_PAR38 = 2               // somente bloqueio cobranca (cd))
			if cCob = "0" .or. ccom = "1"
				TSC5->( dbskip() )
				loop
			Endif
		ElseIf MV_PAR38 = 3          // somente bloqueio comercial (cm))
			if ccom = "0" .or. ccob = "1"
				TSC5->( dbskip() )
				loop
			Endif
		elseIf MV_par38 = 4          // bloqueio cobranca e comercial (cd/cm))
			if cCob = "0" .or. ccom = "0"
				TSC5->( dbskip() )
				loop
			Endif
		Endif
	else
		If MV_PAR38 <> 1            // normal(N) so pode ser impresso com a opção de nenhum bloqueio
			TSC5->( dbskip() )
			loop
		Endif
	EndIf
	
	//---> fim ssi 50008
	
	cLib	:= PADL(cLib, 03)
	
	//SSI-105463 - Vagner Almeida - 17/12/2020 - Final
	
	//nPeso:=0 SSI 20485
	DbSelectArea("TSC5")
	Do While ! EOF() .and. TSC5->C5_NUM = cNum
		If !Empty(TSC5->A1_CGC) .And. SubStr(TSC5->C5_VEND1,1,1) == "C"
			_nPos	:=	aScan(_aResumo3,{|x| x[1]==TSC5->C5_VEND1})
			If	_nPos	==	0
				aAdd(_aResumo3,{TSC5->C5_VEND1,PADR(TSC5->A3_NOME,15),TSC5->ESPACO,TSC5->TOTPED})
			Else
				_aResumo3[_nPos,3]	+=	TSC5->ESPACO
				_aResumo3[_nPos,4]	+=	TSC5->TOTPED
			EndIf
		EndIf
		_nPos	:=	aScan(_aResumo,{|x| Alltrim(x[1])==Alltrim(cZona+cItin)})
		If	_nPos	=	0
			AADD(_aResumo,{Alltrim(TSC5->A1_XROTA)+Alltrim(TSC5->ZH_ITINER),Alltrim(TSC5->A1_XROTA),Alltrim(TSC5->ZH_ITINER),TSC5->ESPACO,TSC5->TOTPED,Alltrim(TSC5->A1_XROTA)})
		Else
			_aResumo[_nPos][4]	:=	_aResumo[_nPos][4]	+	TSC5->ESPACO
			_aResumo[_nPos][5]	:=	_aResumo[_nPos][5]	+	TSC5->TOTPED
		Endif
		_nPos := aScan(aCliente,{|x| x[1] == TSC5->A1_COD})
		If TSC5->C5_TIPO $ "B/D"
			cNomC := Posicione("SA2",1,xFilial("SA2")+TSC5->A1_COD,"SA2->A2_NOME")
		Else
			cNomC := Posicione("SA1",1,xFilial("SA1")+TSC5->A1_COD,"SA1->A1_NOME")
		EndIf
		if _nPos = 0
			aAdd(aCliente,{TSC5->A1_COD,TSC5->A1_CGC,TSC5->A1_XTIPO,nEspLivre,TSC5->TOTPED,cNomC})
		else
			aCliente[_nPos][5]	:=		aCliente[_nPos][5]	+	TSC5->TOTPED
			aCliente[_nPos][4]	:=		aCliente[_nPos][4]	+	nEspLivre
		endif

		nTotPed  	+= TSC5->TOTPED
		
		If !Empty(cEntr) .or. !Empty(cEntrF)
			nTotCEnt	+=	TSC5->TOTPED
		Endif
		
		nTotEsp  	+= TSC5->ESPACO
		nVTotPed 	:= nVTotPed + TSC5->TOTPED
		cTpSegm     := TSC5->C5_XTPSEGM
		//nPeso      +=TSC5->(C6_QTDVEN*B1_PESO)		 SSI 20485
		_nMod	:= Ascan(_aModelos,{|aVal|aVal[1]==Alltrim(TSC5->BM_XSUBGRU)})
		_nModA	:= 0
		_nModB	:= 0
		if (nTotDias <= 30)
			_nModA	:= Ascan(_aModelosA,{|aVal|aVal[1]==Alltrim(TSC5->BM_XSUBGRU)})
		Else
			_nModB	:= Ascan(_aModelosB,{|aVal|aVal[1]==Alltrim(TSC5->BM_XSUBGRU)})
		Endif
		_nSeg	:= Ascan(_aSegmento,{|aVal|aVal[1]==Alltrim(TSC5->BM_XSUBGRU)})
		if _nSeg > 0
			_aSegmento[_nSeg][3] += TSC5->C6_QTDVEN
			_aSegmento[_nSeg][4] += TSC5->TOTPED
		endif
		if (nTotDias <= 30)
			if _nSegA > 0
				_aSegmentA[_nSegA][3] += TSC5->C6_QTDVEN
				_aSegmentA[_nSegA][4] += TSC5->TOTPED
			endif
			
		else
			if _nSegB > 0
				_aSegmentB[_nSegB][3] += TSC5->C6_QTDVEN
				_aSegmentB[_nSegB][4] += TSC5->TOTPED
			endif
		endif
		if _nMod = 0
			If TSC5->BM_GRUPO $ "7545|9201"
				_nqtdleit	:= TSC5->C6_QTDVEN
				_ntpedleit	:= TSC5->TOTPED
			Endif
			AADD(_aModelos,{AllTrim(TSC5->BM_XSUBGRU),AllTrim(posicione("SX5",1,xFilial("SX5")+"ZA"+TSC5->BM_XSUBGRU,"X5_DESCRI" )),TSC5->C6_QTDVEN,TSC5->TOTPED, TSC5->BM_GRUPO,_nqtdleit,_ntpedleit,AllTrim(TSC5->B1_XMODELO),TSC5->(C6_QTDVEN*B1_PESO)})
		else
			_aModelos[_nMod][3] += TSC5->C6_QTDVEN
			_aModelos[_nMod][4] += TSC5->TOTPED
			_aModelos[_nMod][9] += TSC5->(C6_QTDVEN*B1_PESO)
		endif
		If MV_PAR13 = 2
			IF Ascan(_aProd,TSC5->C6_DESCRI) = 0
				AADD(_aProd,TSC5->C6_DESCRI)
			Endif
		Endif
		
		If MV_PAR13 = 2 .Or. mv_par18 = 2
			
			If mv_par18 = 2
				//Incrementa Array para impressão do resumo de produtos no fim do relatório
				_nPT	:=	Ascan(_aProdT,{|aVal|aVal[1]==Alltrim(TSC5->C6_PRODUTO)})
				
				IF _nPT = 0
					AADD(_aProdT,{AllTrim(TSC5->C6_PRODUTO),AllTrim(TSC5->C6_DESCRI),AllTrim(TSC5->B1_XMED),TSC5->C6_QTDVEN, TSC5->QTDEST })
				Else
					_aProdT[_nPT][4]	+=	TSC5->C6_QTDVEN
				Endif
			Endif
			
			
			If mv_par18 = 2 .AND. MV_PAR11 = 2
				//Incremente Array para a impressao de produtos terceirizado e seu respectivos pedidos em atraso
				AADD(_aProdTatr,{AllTrim(TSC5->C6_PRODUTO),AllTrim(TSC5->C6_DESCRI),AllTrim(TSC5->B1_XMED), Alltrim(TSC5->C5_NUM),alltrim(TSC5->A1_XROTA)})
			Endif
			
			//			Pedidos com produtos com qtd zerada em estoque
			if TSC5->QTDEST - TSC5->C6_QTDVEN<= 0
				_nPT	:=	Ascan(_aPedzer,{|aVal|aVal[1]==Alltrim(TSC5->C5_NUM)})
				IF _nPT = 0
					AADD(_aPedzer,{TSC5->C5_NUM,TSC5->A1_XROTA})
				Endif
			endif
			//Incrementa array para impressao da Listagem de Segmentos
			
			If !Empty(TSC5->C5_XENTREG)
				nTotDias:= STOD(TSC5->C5_XENTREG) - DDATABASE
			Else
				nTotDias:=0
			Endif
			
			if (nTotDias <= 30)
				_nSegA  := Ascan(_aSegmentA,{|aVal|aVal[1]==Alltrim(TSC5->BM_XSUBGRU)})
			Else
				_nSegB  := Ascan(_aSegmentB,{|aVal|aVal[1]==Alltrim(TSC5->BM_XSUBGRU)})
			Endif
			
			
			//			if (nTotDias <= 30)
			if _nModA = 0
				if nTotDias<=30
					AADD(_aModelosA,{AllTrim(TSC5->BM_XSUBGRU),AllTrim(posicione("SX5",1,xFilial("SX5")+"ZA"+TSC5->BM_XSUBGRU,"X5_DESCRI" )),TSC5->C6_QTDVEN,TSC5->TOTPED})
				else
					AADD(_aModelosA,{AllTrim(TSC5->BM_XSUBGRU),AllTrim(posicione("SX5",1,xFilial("SX5")+"ZA"+TSC5->BM_XSUBGRU,"X5_DESCRI" )),0,0})
				endif
			else
				if nTotDias <= 30
					_aModelosA[_nModA][3] += TSC5->C6_QTDVEN
					_aModelosA[_nModA][4] += TSC5->TOTPED
				endif
			endif
			
			if _nModB = 0
				if nTotDias>30
					AADD(_aModelosB,{AllTrim(TSC5->BM_XSUBGRU),AllTrim(posicione("SX5",1,xFilial("SX5")+"ZA"+TSC5->BM_XSUBGRU,"X5_DESCRI" )),TSC5->C6_QTDVEN,TSC5->TOTPED})
				else
					AADD(_aModelosB,{AllTrim(TSC5->BM_XSUBGRU),AllTrim(posicione("SX5",1,xFilial("SX5")+"ZA"+TSC5->BM_XSUBGRU,"X5_DESCRI" )),0,0})
				endif
			else
				if nTotDias>30
					_aModelosB[_nModB][3] += TSC5->C6_QTDVEN
					_aModelosB[_nModB][4] += TSC5->TOTPED
				endif
			endif
			
			//Calculo do total das carteiras por perido: 30, 30 e 60 e maior que 60
			nTotDias:= STOD(TSC5->C5_XENTREG) - DDATABASE
			xOper:= TSC5->C5_XOPER
			if (nTotDias <= 30)
				nCart30d += TSC5->TOTPED
				if !empty(TSC5->TERC)
					if TSC5->C5_XMIX <> 0
						aRent30[4]:= aRent30[4] + (TSC5->C5_XMIX * TSC5->TERC)
						aRentSeg30[4]:= aRentSeg30[4] + TSC5->TERC
					endif
				elseif TSC5->C5_XTPSEGM=="1" .OR. TSC5->C5_XTPSEGM=="5"  //Industrial e Industrial - Ortoclass
					if TSC5->C5_XMIX <> 0
						aRent30[2]:= aRent30[2] + (TSC5->C5_XMIX * TSC5->TOTPED)
						aRentSeg30[2]:= aRentSeg30[2] + TSC5->TOTPED
					endif
				elseif TSC5->C5_XTPSEGM=="3" .OR. TSC5->C5_XTPSEGM=="4"  // Franquia e Exclusivas
					if TSC5->C5_XMIX <> 0
						aRent30[3]:= aRent30[3] + (TSC5->C5_XMIX * TSC5->TOTPED)
						aRentSeg30[3]:= aRentSeg30[3] + TSC5->TOTPED
					endif
				elseif TSC5->C5_XTPSEGM=="2" .OR. TSC5->C5_XTPSEGM=="6" //Comercial  e Comercial - Ortoclass
					if TSC5->C5_XMIX <> 0
						aRent30[1]:= aRent30[1] + (TSC5->C5_XMIX * TSC5->TOTPED)
						aRentSeg30[1]:= aRentSeg30[1] + TSC5->TOTPED
					endif
				endif
			elseif (nTotDias > 30 .and. nTotDias<=60)
				nCart3060d += TSC5->TOTPED
				if 	!empty(TSC5->TERC)
					if TSC5->C5_XMIX <> 0
						aRent3060[4]:= aRent3060[4] + (TSC5->C5_XMIX * TSC5->TERC)
						aRtSeg3060[4]:= aRtSeg3060[4] + TSC5->TERC
					endif
				elseif TSC5->C5_XTPSEGM=="1" .OR. TSC5->C5_XTPSEGM=="5"  //Industrial e Industrial - Ortoclass
					if TSC5->C5_XMIX <> 0
						aRent3060[2]:= aRent3060[2] + (TSC5->C5_XMIX * TSC5->TOTPED)
						aRtSeg3060[2]:= aRtSeg3060[2] + TSC5->TOTPED
					endif
				elseif TSC5->C5_XTPSEGM=="3" .OR. TSC5->C5_XTPSEGM=="4"  // Franquia e Exclusivas
					if TSC5->C5_XMIX <> 0
						aRent3060[3]:= aRent3060[3] + (TSC5->C5_XMIX * TSC5->TOTPED)
						aRtSeg3060[3]:= aRtSeg3060[3] + TSC5->TOTPED
					endif
				elseif TSC5->C5_XTPSEGM=="2" .OR. TSC5->C5_XTPSEGM=="6" //Comercial  e Comercial - Ortoclass
					if TSC5->C5_XMIX <> 0
						aRent3060[1]:= aRent3060[1] + (TSC5->C5_XMIX * TSC5->TOTPED)
						aRtSeg3060[1]:= aRtSeg3060[1] + TSC5->TOTPED
					endif
				endif
			elseif (nTotDias > 60)
				nCartM60d += TSC5->TOTPED
				if !empty(TSC5->TERC)
					if TSC5->C5_XMIX <> 0
						aRent60[4]:= aRent60[4] + (TSC5->C5_XMIX * TSC5->TERC)
						aRentSeg60[4]:= aRentSeg60[4] + TSC5->TERC
					endif
				elseif TSC5->C5_XTPSEGM=="1" .OR. TSC5->C5_XTPSEGM=="5"  //Industrial e Industrial - Ortoclass
					if TSC5->C5_XMIX <> 0
						aRent60[2]:= aRent60[2] + (TSC5->C5_XMIX * TSC5->TOTPED)
						aRentSeg60[2]:= aRentSeg60[2] + TSC5->TOTPED
					endif
				elseif TSC5->C5_XTPSEGM=="3" .OR. TSC5->C5_XTPSEGM=="4"  // Franquia e Exclusivas
					if TSC5->C5_XMIX <> 0
						aRent60[3]:= aRent60[3] + (TSC5->C5_XMIX * TSC5->TOTPED)
						aRentSeg60[3]:= aRentSeg60[3] + TSC5->TOTPED
					endif
				elseif TSC5->C5_XTPSEGM=="2" .OR. TSC5->C5_XTPSEGM=="6" //Comercial  e Comercial - Ortoclass
					if TSC5->C5_XMIX <> 0
						aRent60[1]:= aRent60[1] + (TSC5->C5_XMIX * TSC5->TOTPED)
						aRentSeg60[1]:= aRentSeg60[1] + TSC5->TOTPED
					endif
				endif
			endif
			nTotDias:= 0
			xOper:= ""
		Else
			//Incrementa array para impressao da Listagem de Segmentos
			
			If !Empty(TSC5->C5_XENTREG)
				nTotDias:= STOD(TSC5->C5_XENTREG) - DDATABASE
			Else
				nTotDias:=0
			Endif
			
			if (nTotDias <= 30)
				_nSegA  := Ascan(_aSegmentA,{|aVal|aVal[1]==Alltrim(TSC5->BM_XSUBGRU)})
			Else
				_nSegB  := Ascan(_aSegmentB,{|aVal|aVal[1]==Alltrim(TSC5->BM_XSUBGRU)})
			Endif
			if (nTotDias <= 30)
				if _nModA = 0
					AADD(_aModelosA,{AllTrim(TSC5->BM_XSUBGRU),AllTrim(posicione("SX5",1,xFilial("SX5")+"ZA"+TSC5->BM_XSUBGRU,"X5_DESCRI" )),TSC5->C6_QTDVEN,TSC5->TOTPED})
				else
					_aModelosA[_nModA][3] += TSC5->C6_QTDVEN
					_aModelosA[_nModA][4] += TSC5->TOTPED
				endif
				
			else
				if _nModB = 0
					AADD(_aModelosB,{AllTrim(TSC5->BM_XSUBGRU),AllTrim(posicione("SX5",1,xFilial("SX5")+"ZA"+TSC5->BM_XSUBGRU,"X5_DESCRI" )),TSC5->C6_QTDVEN,TSC5->TOTPED})
				else
					_aModelosB[_nModB][3] += TSC5->C6_QTDVEN
					_aModelosB[_nModB][4] += TSC5->TOTPED
				endif
			endif
			
			//Calculo do total das carteiras por perido: 30, 30 e 60 e maior que 60
			nTotDias:= STOD(TSC5->C5_XENTREG) - DDATABASE
			xOper:= TSC5->C5_XOPER
			
			if (nTotDias <= 30)
				nCart30d += TSC5->TOTPED
				if !empty(TSC5->TERC)
					if TSC5->C5_XMIX <> 0
						aRent30[4]:= aRent30[4] + (TSC5->C5_XMIX * TSC5->TERC)
						aRentSeg30[4]:= aRentSeg30[4] + TSC5->TERC
					endif
				elseif TSC5->C5_XTPSEGM=="1" .OR. TSC5->C5_XTPSEGM=="5"  //Industrial e Industrial - Ortoclass
					if TSC5->C5_XMIX <> 0
						aRent30[2]:= aRent30[2] + (TSC5->C5_XMIX * TSC5->TOTPED)
						aRentSeg30[2]:= aRentSeg30[2] + TSC5->TOTPED
					endif
				elseif TSC5->C5_XTPSEGM=="3" .OR. TSC5->C5_XTPSEGM=="4"  // Franquia e Exclusivas
					if TSC5->C5_XMIX <> 0
						aRent30[3]:= aRent30[3] + (TSC5->C5_XcRotaMIX * TSC5->TOTPED)
						aRentSeg30[3]:= aRentSeg30[3] + TSC5->TOTPED
					endif
				elseif TSC5->C5_XTPSEGM=="2" .OR. TSC5->C5_XTPSEGM=="6" //Comercial  e Comercial - Ortoclass
					if TSC5->C5_XMIX <> 0
						aRent30[1]:= aRent30[1] + (TSC5->C5_XMIX * TSC5->TOTPED)
						aRentSeg30[1]:= aRentSeg30[1] + TSC5->TOTPED
					endif
				endif
			elseif ((nTotDias > 30 .and. nTotDias<=60))
				nCart3060d += TSC5->TOTPED
				if 	!empty(TSC5->TERC)
					if TSC5->C5_XMIX <> 0
						aRent3060[4]:= aRent3060[4] + (TSC5->C5_XMIX * TSC5->TERC)
						aRtSeg3060[4]:= aRtSeg3060[4] + TSC5->TERC
					endif
				elseif TSC5->C5_XTPSEGM=="1" .OR. TSC5->C5_XTPSEGM=="5"  //Industrial e Industrial - Ortoclass
					if TSC5->C5_XMIX <> 0
						aRent3060[2]:= aRent3060[2] + (TSC5->C5_XMIX * TSC5->TOTPED)
						aRtSeg3060[2]:= aRtSeg3060[2] + TSC5->TOTPED
					endif
				elseif TSC5->C5_XTPSEGM=="3" .OR. TSC5->C5_XTPSEGM=="4"  // Franquia e Exclusivas
					if TSC5->C5_XMIX <> 0
						aRent3060[3]:= aRent3060[3] + (TSC5->C5_XMIX * TSC5->TOTPED)
						aRtSeg3060[3]:= aRtSeg3060[3] + TSC5->TOTPED
					endif
				elseif TSC5->C5_XTPSEGM=="2" .OR. TSC5->C5_XTPSEGM=="6" //Comercial  e Comercial - Ortoclass
					if TSC5->C5_XMIX <> 0
						aRent3060[1]:= aRent3060[1] + (TSC5->C5_XMIX * TSC5->TOTPED)
						aRtSeg3060[1]:= aRtSeg3060[1] + TSC5->TOTPED
					endif
				endif
			elseif (nTotDias > 60)
				nCartM60d += TSC5->TOTPED
				if !empty(TSC5->TERC)
					if TSC5->C5_XMIX <> 0
						aRent60[4]:= aRent60[4] + (TSC5->C5_XMIX * TSC5->TERC)
						aRentSeg60[4]:= aRentSeg60[4] + TSC5->TERC
					endif
				elseif TSC5->C5_XTPSEGM=="1" .OR. TSC5->C5_XTPSEGM=="5"  //Industrial e Industrial - Ortoclass
					if TSC5->C5_XMIX <> 0
						aRent60[2]:= aRent60[2] + (TSC5->C5_XMIX * TSC5->TOTPED)
						aRentSeg60[2]:= aRentSeg60[2] + TSC5->TOTPED
					endif
				elseif TSC5->C5_XTPSEGM=="3" .OR. TSC5->C5_XTPSEGM=="4"  // Franquia e Exclusivas
					if TSC5->C5_XMIX <> 0
						aRent60[3]:= aRent60[3] + (TSC5->C5_XMIX * TSC5->TOTPED)
						aRentSeg60[3]:= aRentSeg60[3] + TSC5->TOTPED
					endif
				elseif TSC5->C5_XTPSEGM=="2" .OR. TSC5->C5_XTPSEGM=="6" //Comercial  e Comercial - Ortoclass
					if TSC5->C5_XMIX <> 0
						aRent60[1]:= aRent60[1] + (TSC5->C5_XMIX * TSC5->TOTPED)
						aRentSeg60[1]:= aRentSeg60[1] + TSC5->TOTPED
					endif
				endif
			endif
			
			nTotDias:= 0
			xOper:= ""
			
		Endif
		DbSelectArea("TSC5")
		dbskip()
		
	EndDo
	
	if !_lRpc
		If nLin > 2300
			nLin := fImpCab("1",.F.,oPrn)
		EndIf
		
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-55 )
		
		oPrn:Line(nLin-5,  145, nLin-5+50,  145 ) // INDICE COMPRA
		oPrn:Line(nLin-5,  210+100, nLin-5+50,  210+100 ) // COMPRA PEDIDO
		oPrn:Line(nLin-5,  200+90+80+100, nLin-5+50,  200+90+80+100 ) // PEDIDO LIB
		oPrn:Line(nLin-5,  290+90+70+100, nLin-5+50,  290+90+70+100 ) // LIB CD/CM
		oPrn:Line(nLin-5,  450+90+75+100, nLin-5+50,  450+90+75+100 ) // CD/CM EMISSAO
		oPrn:Line(nLin-5,  630+90+75+100, nLin-5+50,  630+90+75+100 ) // EMISSAO LIBERACAO
		oPrn:Line(nLin-5,  830+90+75+100, nLin-5+50,  830+90+75+100 ) // LIBERACAO REVALID
		oPrn:Line(nLin-5, 1010+90+75+100, nLin-5+50, 1010+90+75+100 ) // REVALID DIAS
		oPrn:Line(nLin-5, 1113+90+70+100, nLin-5+50, 1113+90+70+100 ) // DIAS ENTREGA
		oPrn:Line(nLin-5, 1510+90+35+100, nLin-5+50, 1510+90+35+100 ) // ENTREGA TP
		oPrn:Line(nLin-5, 1575+90+35+100, nLin-5+50, 1575+90+35+100 ) // TP SEG
		oPrn:Line(nLin-5, 1650+90+30+100, nLin-5+50, 1650+90+30+100 ) // SEG VEND
		oPrn:Line(nLin-5, 1974+80+100-20, nLin-5+50, 1974+80+100-20 ) // VEND CLIENTE
		oPrn:Line(nLin-5, 2265+90+100-60, nLin-5+50, 2265+90+100-60 ) // CLIENTE VLR
		oPrn:Line(nLin-5, 2465+90+100-60, nLin-5+50, 2465+90+100-60 ) // VLR ZONA
		oPrn:Line(nLin-5, 2912+40-45-60, nLin-5+50, 2912+40-45-60 ) // ZONA CIDADE ULT.CARG
		oPrn:Line(nLin-5, 3090+40-45-60, nLin-5+50, 3090+40-45-60 ) // ULT.CARG ESPACOS
		oPrn:Line(nLin-5, 3248+25-45-60, nLin-5+50, 3248+25-45-60 ) // ESPACOS ROT
		oPrn:Line(nLin-5, 3330+25-45-60, nLin-5+50, 3330+25-45-60 ) // ROT TAB
		
		aDetalhe  := {} //SSI-124131 - Vagner Almeida - 09/09/2021
		
		oPrn:Say(nLin,0060,Transform(_nIndic, "@E 9999"), oFont2) //num
		oPrn:Say(nLin,0150,AllTrim(cOrdCom), oFont2) //pcompra
		oPrn:Say(nLin,0325,cNum+Iif(_lPedProb = .T.,"*",""), oFont2) //pedido
		oPrn:Say(nLin,0500,cLib, oFont2) //lib

		//SSI-124131 - Vagner Almeida - 09/09/2021 - Inicio
		aAdd(aDetalhe, Transform(_nIndic, "@E 9999")      ) 
		aAdd(aDetalhe, AllTrim(cOrdCom)                   ) 
		aAdd(aDetalhe, cNum + Iif(_lPedProb = .T.,"*","") ) 
		aAdd(aDetalhe, cLib                               ) 
		//SSI-124131 - Vagner Almeida - 09/09/2021 - Final
		
		IF MV_PAR34 == 1
			oPrn:Say(nLin,0550,cCdcm, oFont2)  //cd/cm
			aAdd(aDetalhe, cCdcm)							//SSI-124131 - Vagner Almeida - 09/09/2021                               ) 
		Else
			oPrn:Say(nLin,0550,Transform(nMix  ,"@E 9999.99"), oFont2)  //cd/cm
			aAdd(aDetalhe, Transform(nMix  ,"@E 9999.99"))	//SSI-124131 - Vagner Almeida - 09/09/2021                               ) 
		EndIf
		//oPrn:Say(nLin,0550,cCdcm, oFont2) //cd/cm
		oPrn:Say(nLin,0725,DtoC(STOD(dEmi)), oFont2) //emissao
		oPrn:Say(nLin,0910,DtoC(STOD(dLib)), oFont2) //liberação
		//SSI-124131 - Vagner Almeida - 09/09/2021 - Inicio
		aAdd(aDetalhe, DtoC(STOD(dEmi)))
		aAdd(aDetalhe, DtoC(STOD(dLib)))
		//SSI-124131 - Vagner Almeida - 09/09/2021 - Final
		
		If !empty(dEstCan)
			oPrn:Say(nLin,1100,DtoC(STOD(dEstCan)), oFont2)
		//SSI-124131 - Vagner Almeida - 09/09/2021 - Inicio
			aAdd(aDetalhe, DtoC(STOD(dEstCan)))
		Else
			aAdd(aDetalhe, "")
		//SSI-124131 - Vagner Almeida - 09/09/2021 - Final
		endif
		
		oPrn:Say(nLin,1285,Transform(iif(nDias < 0,0,nDias), "@E 9999"), oFont2)
		aAdd(aDetalhe, Transform(iif(nDias < 0,0,nDias), "@E 9999"))	//SSI-124131 - Vagner Almeida - 09/09/2021                               ) 
		
		If mv_par22 ==2 //.AND. !EMPTY(mv_par23)
			
			//If cEntr < dtos(mv_par23)
			//	oPrn:Say(nLin,1225,"LIVRE", oFont2)
			//Else
			oPrn:Say(nLin,1385,DtoC(STOD(cEntr)), oFont2)
			if !empty(cEntr)
				oPrn:Say(nLin,1545,"a", oFont2)
				oPrn:Say(nLin,1575,Iif(Empty(cEntrF),"LIVRE",DtoC(STOD(cEntrF))), oFont2)
				aAdd(aDetalhe, DtoC(STOD(cEntr)) + " a " + Iif(Empty(cEntrF),"LIVRE",DtoC(STOD(cEntrF))))	//SSI-124131 - Vagner Almeida - 09/09/2021                               ) 
			endif
			//Endif
		ELSE
			oPrn:Say(nLin,1385,Iif(Empty(cEntr),"LIVRE",DtoC(STOD(cEntr))), oFont2)			
			if !empty(cEntr)
				oPrn:Say(nLin,1545,"a", oFont2)
				oPrn:Say(nLin,1575,Iif(Empty(cEntrF),"LIVRE",DtoC(STOD(cEntrF))), oFont2)
			//SSI-124131 - Vagner Almeida - 09/09/2021 - Inicio                                
				aAdd(aDetalhe, DtoC(STOD(cEntr)) + " a " + Iif(Empty(cEntrF),"LIVRE",DtoC(STOD(cEntrF))))	
			Else	
				aAdd(aDetalhe, "LIVRE")
			//SSI-124131 - Vagner Almeida - 09/09/2021 - Final                                
			endif

		ENDIF
		oPrn:Say(nLin,1750,cOper,oFont2)
		oPrn:Say(nLin,1825,cTpSegm,oFont2)
		oPrn:Say(nLin,1885,LEFT(cNomV,12), oFont2)
		oPrn:Say(nLin,2150,LEFT(cNomC,12), oFont2)

		oPrn:Say(nLin,2410,Transform(nTotPed,"@E 9999,999.99"), oFont2)
		oPrn:Say(nLin,2600,Alltrim(LEFT(cCid,12)), oFont2)
		oPrn:Say(nLin,2850,DtoC(STOD(cUltEmb)), oFont2)
		//SSI-124131 - Vagner Almeida - 09/09/2021 - Inicio                                
		aAdd(aDetalhe, cOper)
		aAdd(aDetalhe, cTpSegm)
		aAdd(aDetalhe, cNomV)
		aAdd(aDetalhe, cNomC)

		aAdd(aDetalhe, Transform(nTotPed,"@E 9999,999.99"))
		aAdd(aDetalhe, cCid)
		aAdd(aDetalhe, DtoC(STOD(cUltEmb)))
		//SSI-124131 - Vagner Almeida - 09/09/2021 - Final                                
		
		IF MV_PAR34 == 1
			oPrn:Say(nLin,3030,Transform(nTotEsp,"@E 9999999.99"), oFont2)
			aAdd(aDetalhe, Transform(nTotEsp,"@E 9999999.99"))	//SSI-124131 - Vagner Almeida - 09/09/2021 
		Else
			oPrn:Say(nLin,3030,Transform(nPeso  ,"@E 9999999.99"), oFont2)
			aAdd(aDetalhe, Transform(nPeso  ,"@E 9999999.99"))	//SSI-124131 - Vagner Almeida - 09/09/2021 
		EndIf
		//oPrn:Say(nLin,3000,Transform(nTotEsp,"@E 9,999.99"), oFont2)

		oPrn:Say(nLin,3200,cItin, oFont2)
		oPrn:Say(nLin,3275,cTab, oFont2)

		//SSI-124131 - Vagner Almeida - 09/09/2021 - Inicio                                
		aAdd(aDetalhe, cItin)
		aAdd(aDetalhe, cTab)
		aAdd(aLinha, aDetalhe)
		//SSI-124131 - Vagner Almeida - 09/09/2021 - Final                                
	endif
	
	nTotPeso += nPeso
	AADD(_aPProd,{ _nIndic,cNum+Iif(_lPedProb = .T.,"*",""),_aProd })
	
	nLin += nEsp
	
	nPed++ // total geral de pedidos
	If cOper = "D"
		nTot_D += nTotPed
	ElseIf cOper = "B"
		nTot_B += nTotPed
	ElseIf cOper = "T"
		nTot_T  += nTotPed
		nTroc ++  // total geral de trocas
		
		If DDATABASE-STOD(dEmi) > 8 // trocas com mais de 8 dias
			nTrocM8++
		Endif
	ElseIf cOper = "Q"
		nTotVI += nTotPed
		
	ElseIf cOper = "N"
		if cTpSegm == "4"
			nTotLe += nTotPed
		else
			nTot_N += nTotPed
		endif
		If DDATABASE-STOD(dEmi) > 8 // vendas com mais de 8 dias
			nVendM8++
		Endif
		If DDATABASE-STOD(dEmi) > 15 // vendas com mais de 15 dias
			nVendM15++
		Endif
	Endif
	
	IF !Empty(dLib)
		If DDATABASE-STOD(dLib) > 3 //.AND. EMPTY(dLib) // ATRASO NA LIBERACAO
			nATrLib++
		Endif
	ENDIF
	
	_aProd	:=	{}
	nTotPed  := 0
	nTotEsp  := 0
		
Enddo

if !_lRpc
	nLin += nEsp
	oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-55 )
	oPrn:Say(nLin,0060,"TOTAL GERAL    : " + AllTrim(TRANSFORM(nVTotPed ,"@E 99,999,999.99")), oFont2)
	
	IF MV_PAR34 <> 1
		oPrn:Say(nLin,0700,"MIX MÉDIO      : " + AllTrim(TRANSFORM(nTOTmix/nQtdMix ,"@E 99,999,999.99")), oFont2)
		oPrn:Say(nLin,1400,"TOTAL KG       : " + AllTrim(Transform(nTotPeso,"@E 99,999,999.99")), oFont2)
		oPrn:Say(nLin,2100,"PREÇO MEDIO KG : " + AllTrim(Transform(nVTotPed/nTotPeso,"@E 99,999,999.99")), oFont2)
	EndIf
endif

nLin += nEsp*2
nTOTmix := 0
nQtdMix := 0

// Imprime os produtos
If MV_PAR13 = 2
	nLin := fImpCab("P", .F., oPrn)
	
	For c	:=	1	To	Len(_aPProd)
		
		If nLin > 2200
			nLin := fImpCab("P", .F., oPrn)
		Endif
		
		if !_lRpc
			oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-52 )
			oPrn:Line(nLin-5,  145, nLin-5+50,  145 ) // INDICE PEDIDO
			oPrn:Line(nLin-5,  200+100, nLin-5+50,  200+100 ) // PEDIDO LIB
			
			oPrn:Say(nLin,0060,Transform(_aPProd[c][1], "@E 9999"), oFont2)
			oPrn:Say(nLin,0150,_aPProd[c][2], oFont2)
			
			If MV_PAR13 = 2 .And. Len(_aPProd[c][3]) > 0
				oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-52 )
				
				_cProds := ""
				
				If Len(_aPProd[c][3]) < 3
					_cProds := ""
					For a	:=	1	To	Len(_aPProd[c][3])
						_cProds += AllTrim(_aPProd[c][3][a]) + ", "
					Next
					oPrn:Say(nLin,0350,LEFT(AllTrim(_cProds), Len(AllTrim(_cProds))-1), oFont2)
					nLin += nEsp
				Else
					For a	:=	1	To	Len(_aPProd[c][3])
						_cProds += AllTrim(_aPProd[c][3][a]) + ", "
						nZcont += 1
						
						if nZcont = 3
							_cProds := AllTrim(_cProds)
							
							oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-55 )
							oPrn:Say(nLin,0350,LEFT(AllTrim(_cProds), Len(AllTrim(_cProds))-1), oFont2)
							
							_cProds := ""
							nZcont 	:= 0
							
							nLin += nEsp
						EndIf
					Next
				EndIf
			Else
				nLin += nEsp
			Endif
		endif
	Next
EndIf
// INICIA OUTRO MODELO

nLin := fImpCab("--", .F., oPrn)
//Endif

nTotNFat := FNAOFAT()

TOTSUBGRU()

if !_lRpc
	oPrn:Say ( nLin , 60,Space(10)+"TOTAL DE DEMONSTRACAO.......................................................... ", oFont2)
	oPrn:Say ( nLin , 60,Space(90)+Transform(nTot_D   , "@E 99,999,999.99"), oFont2)
	
	nLin += nEsp
	
	oPrn:Say ( nLin , 60,Space(10)+"TOTAL DE BRINDE................................................................ ", oFont2)
	oPrn:Say ( nLin , 60,Space(90)+Transform(nTot_B   , "@E 99,999,999.99"), oFont2)
	
	nLin += nEsp
	
	oPrn:Say ( nLin , 60,Space(10)+"TOTAL DE TROCAS................................................................ ", oFont2)
	oPrn:Say ( nLin , 60,Space(90)+Transform(nTot_T   , "@E 99,999,999.99"), oFont2)
	
	nLin += nEsp
	
	oPrn:Say ( nLin , 60,Space(10)+"TOTAL LOJA ESPEC............................................................... ", oFont2)
	oPrn:Say ( nLin , 60,Space(90)+Transform(nTotLE  , "@E 99,999,999.99"), oFont2)
	
	nLin += nEsp
	
	oPrn:Say ( nLin , 60,Space(10)+"TOTAL VENDA INSUMOS............................................................", oFont2)
	oPrn:Say ( nLin , 60,Space(90)+Transform(nTotVI  , "@E 99,999,999.99"), oFont2)
	
	nLin += nEsp
	
	oPrn:Say ( nLin , 60,Space(10)+"TOTAL DE VENDAS................................................................ ", oFont2)
	oPrn:Say ( nLin , 60,Space(90)+Transform(nTot_N  , "@E 99,999,999.99"), oFont2)
	
	nLin += nEsp
	
	oPrn:Say ( nLin , 60,Space(10)+"TOTAL C/ DT.ENTREGA............................................................ ", oFont2)
	oPrn:Say ( nLin , 60,Space(90)+Transform(nTotCEnt , "@E 99,999,999.99"), oFont2)
	
	nLin += nEsp
	
	oPrn:Say ( nLin , 60,Space(10)+"TOTAL PROG. NÃO FATURADO....................................................... ", oFont2)
	oPrn:Say ( nLin , 60,Space(90)+Transform(nTotNFat , "@E 99,999,999.99"), oFont2)
	
	nLin += nEsp*2
	
	oPrn:Say ( nLin , 60,Space(10)+"TOTAL GERAL DE PEDIDOS.........................................................", oFont2)
	oPrn:Say ( nLin , 60,Space(90)+Transform(nPed , "@E 9,999,999,999"), oFont2)
	
	nLin += nEsp
	
	oPrn:Say ( nLin , 60,Space(10)+"TOTAL GERAL DE TROCAS..........................................................", oFont2)
	oPrn:Say ( nLin , 60,Space(90)+Transform(nTroc , "@E 9,999,999,999"), oFont2)
	
	nLin += nEsp
	
	oPrn:Say ( nLin , 60,Space(10)+"TROCAS COM MAIS DE 8 DIAS......................................................", oFont2)
	oPrn:Say ( nLin , 60,Space(90)+Transform(nTrocM8 , "@E 9,999,999,999"), oFont2)
	
	nLin += nEsp
	
	oPrn:Say ( nLin , 60,Space(10)+"VENDAS COM MAIS DE 8 DIAS......................................................", oFont2)
	oPrn:Say ( nLin , 60,Space(90)+Transform(nVendM8 , "@E 9,999,999,999"), oFont2)
	
	nLin += nEsp
	
	oPrn:Say ( nLin , 60,Space(10)+"VENDAS COM MAIS DE 15 DIAS.....................................................", oFont2)
	oPrn:Say ( nLin , 60,Space(90)+Transform(nVendM15 , "@E 9,999,999,999"), oFont2)
	
	nLin += nEsp
	
	oPrn:Say ( nLin , 60,Space(10)+"ATRASO NA LIBERACAO (PEDIDOS COM MAIS DE 72H SEM LIB. DO CADASTRO).............", oFont2)
	oPrn:Say ( nLin , 60,Space(90)+Transform(nATrLib , "@E 9,999,999,999"), oFont2)
	
	nLin += nEsp*2
endif
// ===============================

nLin := fImpCab("V", .F., oPrn)
aSort(_aResumo3,,,{|x,y| x[4]>y[4]})

_nTotEsp:=0
_nTotVal:=0
For c	:=	1	To	Len(_aResumo3)
	
	If nLin > (2200 - 5*nEsp)
		nLin := fImpCab("V",.F.,oPrn)
	Endif
	if !_lRpc
		oPrn:Box( nLin-5,0050,nLin-5+50,1370)
		oPrn:Line(nLin-5,0270,nLin-5+50,0270)
		oPrn:Line(nLin-5,0710,nLin-5+50,0710)
		oPrn:Line(nLin-5,1040,nLin-5+50,1040)
		
		oPrn:Line(nLin-5+50,1430,nLin-5+50,oPrn:nHorzRes()-75)
		
		//Imprime linha negrito para separar vendedores com menos de 1000 UPME
		If _aResumo3[c][4] < (1000*nTxUpme)
			If c == 1 .Or. _aResumo3[c-1][4] > (1000*nTxUpme)
				oPrn:Line(nLin-7,0050,nLin-7,1370)
				oPrn:Line(nLin-3,0050,nLin-3,1370)
			EndIf
		EndIf
		
		If !Empty(_aResumo3[c][1])
			oPrn:Say(nLin,0060,AllTrim(_aResumo3[c][1]), oFont2)//C5_VEND1
		Endif
		
		If !Empty(_aResumo3[c][2])
			oPrn:Say(nLin,0280,AllTrim(_aResumo3[c][2]), oFont2)//A3_NREDUZ
		Endif
		
		oPrn:Say(nLin,0765,Transform(_aResumo3[c][3], "@E 9,999,999.999"), oFont2)//TRB->ESPACO
		oPrn:Say(nLin,1095,Transform(_aResumo3[c][4], "@E 9,999,999.999"), oFont2)//TRB->VALOR
	endif
	_nTotEsp+=_aResumo3[c][3]
	_nTotVal+=_aResumo3[c][4]
	
	nLin += nEsp
Next
if !_lRpc
	oPrn:Box( nLin-5,0050,nLin-5+50,1370)
	oPrn:Say(nLin,0060,"TOTAL..........:", oFont2)
	oPrn:Say(nLin,0765,Transform(_nTotEsp, "@E 9,999,999.999"), oFont2)//TOTAL DOS ESPACOS
	oPrn:Say(nLin,1095,Transform(_nTotVal, "@E 9,999,999.999"), oFont2)//TOTAL DOS VALORRES
endif
nLin += nEsp * 2
_nTotEsp:=0
_nTotVal:=0


// INICIA OUTRO MODELO

nLin := fImpCab("4", .F., oPrn)

FVALIDARRAY('3',_aResumo)
aSort(_aResumo,,,{|x,y| x[1]<y[1]})
aSort(aCliente,,,{|x,y| x[5]>y[5]})

_nTotEsp:=0
_nTotVal:=0
For c	:=	1	To	Len(_aResumo)
	
	If nLin > 2200
		nLin := fImpCab("4",.F.,oPrn)
	Endif
	if !_lRpc
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-2200 )
		oPrn:Line(nLin-5,  270, nLin-5+50,  270 ) //
		oPrn:Line(nLin-5,  460, nLin-5+50,  460 ) //
		oPrn:Line(nLin-5,  850, nLin-5+50,  850 ) //
		
		If _aResumo[c][2] <> ""
			oPrn:Say(nLin,0060,AllTrim(_aResumo[c][2]), oFont2)//TRB->ZONA
		Endif
		If _aResumo[c][3] <> ""
			oPrn:Say(nLin,0300,AllTrim(_aResumo[c][3]), oFont2)//TRB->ITIN
		Endif
		
		oPrn:Say(nLin,0575,Transform(_aResumo[c][4], "@E 9,999,999.999"), oFont2)//TRB->ESPACO
		oPrn:Say(nLin,0975,Transform(_aResumo[c][5], "@E 9,999,999.999"), oFont2)//TRB->VALOR
	endif
	_nTotEsp+=_aResumo[c][4]
	_nTotVal+=_aResumo[c][5]
	
	nLin += nEsp
Next
if !_lRpc
	oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-2200 )
	
	oPrn:Say(nLin,0060,"TOTAL..........:", oFont2)
	oPrn:Say(nLin,0575,Transform(_nTotEsp, "@E 9,999,999.999"), oFont2)//TOTAL DOS ESPACOS
	oPrn:Say(nLin,0975,Transform(_nTotVal, "@E 9,999,999.999"), oFont2)//TOTAL DOS VALORRES
endif
nLin += nEsp * 2

_nTotEsp:=0
_nTotVal:=0

// 2 ESPC AQUI

//==================================

fEspaco()                // preenche  o array com as zonas de entrega e os espacos

//QUADRO 1
FVALIDARRAY('4',_aResumo2)
aSort(_aResumo2,,,{|x,y| x[1]<y[1]})

//QUADRO 2
FVALIDARRAY('4',_aResumo2B)
aSort(_aResumo2B,,,{|x,y| x[1]<y[1]})

//QUADRO 2
FVALIDARRAY('4',_aResumo2E)
aSort(_aResumo2E,,,{|x,y| x[1]<y[1]})

//QUADRO 3
FVALIDARRAY('4',_aResumo2C)
aSort(_aResumo2C,,,{|x,y| x[1]<y[1]})

nLin := fImpCab("9",.F.,oPrn)

For d	:=	1	To	Len(_aResumo2)
	
	If nLin > 2200
		nLin := fImpCab("9",.F.,oPrn)
	Endif
	
	if !_lRpc
		If CEMPANT$"22"
			oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-55 )
			
			oPrn:Line(nLin-5, 0210-20, nLin-5+50, 0210-20 ) // ZN.ENT ESPAÇOS
			oPrn:Line(nLin-5, 0405-15, nLin-5+50, 0405-15 ) // ESPAÇOS QTDE
			oPrn:Line(nLin-5, 0615-25, nLin-5+50, 0615-25 ) // QTDE VALOR
			oPrn:Line(nLin-5, 0850-40, nLin-5+50, 0850-40 ) // VALOR ESPACOS
			oPrn:Line(nLin-5, 1050-40, nLin-5+50, 1050-40 ) // ESPACOS VALOR
			
			oPrn:Line(nLin-5, 1280-50, nLin-5+50, 1280-50 ) // VALOR ESPAÇOS
			oPrn:Line(nLin-5, 1500-70, nLin-5+50, 1500-70 ) // ESPAÇOS QTDE
			oPrn:Line(nLin-5, 1735-85, nLin-5+50, 1735-85 ) // QTDE VALOR
			oPrn:Line(nLin-5, 1975-85, nLin-5+50, 1975-85 ) // VALOR ESPACOS
			oPrn:Line(nLin-5, 2190-110, nLin-5+50, 2190-110 ) // ESPACOS VALOR
			
			oPrn:Line(nLin-5, 2445-110-5, nLin-5+50, 2445-110-5 ) // VALOR ESPAÇOS
			oPrn:Line(nLin-5, 2645-60-64, nLin-5+50, 2645-60-64 ) // ESPAÇOS QTD
			oPrn:Line(nLin-5, 2870-60-70-10, nLin-5+50, 2870-60-70-10 ) // QTD VALOR
			oPrn:Line(nLin-5, 3120-60-60, nLin-5+50, 3120-60-60 ) // VALOR ESPAÇOS
			oPrn:Line(nLin-5, 3330-60-70-5, nLin-5+50, 3330-60-70-5 ) // ESPAÇOS VALOR
			
		Else
			oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-2225 )
			
			oPrn:Line(nLin-5, 0210-20, nLin-5+50, 0210-20 ) // ZN.ENT ESPAÇOS
			oPrn:Line(nLin-5, 0405-15, nLin-5+50, 0405-15 ) // ESPAÇOS QTDE
			oPrn:Line(nLin-5, 0615-25, nLin-5+50, 0615-25 ) // QTDE VALOR
			oPrn:Line(nLin-5, 0850-40, nLin-5+50, 0850-40 ) // VALOR ESPACOS
			oPrn:Line(nLin-5, 1050-40, nLin-5+50, 1050-40 ) // ESPACOS VALOR
			
		EndIf
		
		//oPrn:Say ( nLin   , 60,"ZZZZZZ|99,000.00 |99,000.00 |99,000.00 |99,000.00 |99,000.00 |99,000.00 |99,000.00 |99,000.00 |99,000.00 |99,000.00 |99,000.00 |99,000.00 |99,000.00 |99,000.00 |99,000.00", oFont2)
		
		oPrn:Say(nLin,0060,Iif(EMPTY(_aResumo2[d][1]), " ", _aResumo2[d][1]), oFont2)
		oPrn:Say(nLin,0200,Transform(_aResumo2[d][4],"@E 99,999.99" ), oFont2)
		oPrn:Say(nLin,0400,Transform(_aResumo2[d][8],"@E 99,999.99" ), oFont2)
		oPrn:Say(nLin,0600,Transform(_aResumo2[d][5],"@E 999,999.99" ), oFont2)
		oPrn:Say(nLin,0825,Transform(_aResumo2[d][6],"@E 99,999.99" ), oFont2)
		oPrn:Say(nLin,1025,Transform(_aResumo2[d][7],"@E 999,999.99" ), oFont2)
		
		If CEMPANT$"22"
			
			oPrn:Say(nLin,1250,Transform(_aResumo2B[d][4],"@E 99,999.99" ), oFont2)
			oPrn:Say(nLin,1435,Transform(_aResumo2B[d][8],"@E 999,999.99" ), oFont2)
			oPrn:Say(nLin,1645,Transform(_aResumo2B[d][5],"@E 9,999,999.99" ), oFont2)
			oPrn:Say(nLin,1900,Transform(_aResumo2B[d][6],"@E 99,999.99" ), oFont2)
			oPrn:Say(nLin,2115,Transform(_aResumo2B[d][7],"@E 999,999.99" ), oFont2)
			
			oPrn:Say(nLin,2340,Transform(_aResumo2C[d][4],"@E 99,999.99" ), oFont2)
			oPrn:Say(nLin,2545,Transform(_aResumo2C[d][8],"@E 99,999.99" ), oFont2)
			oPrn:Say(nLin,2760,Transform(_aResumo2C[d][5],"@E 9,999,999.99" ), oFont2)
			oPrn:Say(nLin,3010,Transform(_aResumo2C[d][6],"@E 99,999.99" ), oFont2)
			oPrn:Say(nLin,3170,Transform(_aResumo2C[d][7],"@E 9,999,999.99" ), oFont2)
			
			oPrn:Say(nLin,1250,Transform(_aResumo2B[d][4],"@E 99,999.99" ), oFont2)
			oPrn:Say(nLin,1435,Transform(_aResumo2B[d][8],"@E 999,999.99" ), oFont2)
			oPrn:Say(nLin,1645,Transform(_aResumo2B[d][5],"@E 9,999,999.99" ), oFont2)
			oPrn:Say(nLin,1900,Transform(_aResumo2B[d][6],"@E 99,999.99" ), oFont2)
			oPrn:Say(nLin,2115,Transform(_aResumo2B[d][7],"@E 999,999.99" ), oFont2)
			
		Endif
	Endif
	//TOTAIS QUADRO 1
	nEspTot      := nEspTot + _aResumo2[d][2]
	nValtot      := nValtot + _aResumo2[d][3]
	nEspLivreG   := nEspLivreG + _aResumo2[d][4]
	nTotLivreG   := nTotLivreG + _aResumo2[d][5]
	nEspFutG     := nEspFutG + _aResumo2[d][6]
	nTotFutG     := nTotFutG + _aResumo2[d][7]
	NQtdTot      := NQtdTot + _aResumo2[d][8]
	
	//TOTAIS QUADRO 2
	nEspTotB      := nEspTotB + _aResumo2B[d][2]
	nValtotB      := nValtotB + _aResumo2B[d][3]
	nEspLGB       := nEspLGB  + _aResumo2B[d][4]
	nTotLGB       := nTotLGB  + _aResumo2B[d][5]
	nEspFutGB     := nEspFutGB + _aResumo2B[d][6]
	nTotFutGB     := nTotFutGB + _aResumo2B[d][7]
	nQTDTotB      := nQTDTotB + _aResumo2B[d][8]
		
		//oPrn:Say(nLin,1225,Transform(nTotLGB+nTotFutGB,"@E 99,999,999.99"), oFontS)
		
	nTotLGBE      := nTotLGE   + _aResumo2E[d][5]
	nTotFuGBE     := nTotFuGBE + _aResumo2E[d][7]
	nQTDTotBE     := nQTDTotBE + _aResumo2E[d][8]
		
	//TRAV/ENCHIMENTOS
		//oPrn:Say(nLin,1050,Transform(int(iif((nQTDtotB/10000)<0,0,nQTDtotB/10000)),"@E 999,999"), oFont2)
	
	//TOTAIS QUADRO 3
	nEspTotC      := nEspTotC + _aResumo2C[d][2]
	nValtotC      := nValtotC + _aResumo2C[d][3]
	
	//LIVRE
	nEspLGC       := nEspLGC + _aResumo2C[d][4]
	nTotLGC       := nTotLGC + _aResumo2C[d][5]
	nQTDlgc       := nQTDlgc + _aResumo2C[d][8]
	//FUTURO
	nEspFutGC     := nEspFutGC + _aResumo2C[d][6]
	nTotFutGC     := nTotFutGC + _aResumo2C[d][7]
	
	nLin += nEsp
Next

//nLin += nEsp
if !_lRpc
	If CEMPANT$"22"
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-55 )
		
		oPrn:Line(nLin-5, 0210-20, nLin-5+50, 0210-20 ) // ZN.ENT ESPAÇOS
		oPrn:Line(nLin-5, 0405-15, nLin-5+50, 0405-15 ) // ESPAÇOS QTDE
		oPrn:Line(nLin-5, 0615-25, nLin-5+50, 0615-25 ) // QTDE VALOR
		oPrn:Line(nLin-5, 0850-40, nLin-5+50, 0850-40 ) // VALOR ESPACOS
		oPrn:Line(nLin-5, 1050-40, nLin-5+50, 1050-40 ) // ESPACOS VALOR
		
		oPrn:Line(nLin-5, 1280-50, nLin-5+50, 1280-50 ) // VALOR ESPAÇOS
		oPrn:Line(nLin-5, 1500-70, nLin-5+50, 1500-70 ) // ESPAÇOS QTDE
		oPrn:Line(nLin-5, 1735-85, nLin-5+50, 1735-85 ) // QTDE VALOR
		oPrn:Line(nLin-5, 1975-85, nLin-5+50, 1975-85 ) // VALOR ESPACOS
		oPrn:Line(nLin-5, 2190-110, nLin-5+50, 2190-110 ) // ESPACOS VALOR
		
		oPrn:Line(nLin-5, 2445-110-5, nLin-5+50, 2445-110-5 ) // VALOR ESPAÇOS
		oPrn:Line(nLin-5, 2645-60-64, nLin-5+50, 2645-60-64 ) // ESPAÇOS QTD
		oPrn:Line(nLin-5, 2870-60-70-10, nLin-5+50, 2870-60-70-10 ) // QTD VALOR
		oPrn:Line(nLin-5, 3120-60-60, nLin-5+50, 3120-60-60 ) // VALOR ESPAÇOS
		oPrn:Line(nLin-5, 3330-60-70-5, nLin-5+50, 3330-60-70-5 ) // ESPAÇOS VALOR
		
	Else
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-2225 )
		oPrn:Line(nLin-5, 0210-20, nLin-5+50, 0210-20 ) // ZN.ENT ESPAÇOS
		oPrn:Line(nLin-5, 0405-15, nLin-5+50, 0405-15 ) // ESPAÇOS QTDE
		oPrn:Line(nLin-5, 0615-25, nLin-5+50, 0615-25 ) // QTDE VALOR
		oPrn:Line(nLin-5, 0850-40, nLin-5+50, 0850-40 ) // VALOR ESPACOS
		oPrn:Line(nLin-5, 1050-40, nLin-5+50, 1050-40 ) // ESPACOS VALOR
		
	EndIf
	
	oPrn:Say(nLin,0060,"TOTAL: ", oFont2)
	oPrn:Say(nLin,0200,Transform(nEspLivreG,"@E 99,999.99" ), oFont2)
	oPrn:Say(nLin,0400,Transform(NQtdTot   ,"@E 99,999.99" ), oFont2)
	oPrn:Say(nLin,0600,Transform(nTotLivreG,"@E 999,999.99" ), oFont2)
	oPrn:Say(nLin,0825,Transform(nEspFutG  ,"@E 99,999.99" ), oFont2)
	oPrn:Say(nLin,1025,Transform(nTotFutG  ,"@E 999,999.99" ), oFont2)
	
	IF CEMPANT$"22"
		
		oPrn:Say(nLin,1250,Transform(nEspLGB  ,"@E 99,999.99" ), oFont2)
		oPrn:Say(nLin,1435,Transform(NQtdTotB ,"@E 999,999.99" ), oFont2)
		oPrn:Say(nLin,1645,Transform(nTotLGB  ,"@E 9,999,999.99" ), oFont2)
		oPrn:Say(nLin,1900,Transform(nEspFutGB,"@E 99,999.99" ), oFont2)
		oPrn:Say(nLin,2115,Transform(nTotFutGB,"@E 999,999.99" ), oFont2)
		
		oPrn:Say(nLin,2340,Transform(nEspLGC  ,"@E 99,999.99" ), oFont2)
		oPrn:Say(nLin,2545,Transform(nQTDlgc  ,"@E 99,999.99" ), oFont2)
		oPrn:Say(nLin,2760,Transform(nTotLGC  ,"@E 9,999,999.99" ), oFont2)
		oPrn:Say(nLin,3010,Transform(nEspFutGC,"@E 99,999.99" ), oFont2)
		oPrn:Say(nLin,3170,Transform(nTotFutGC,"@E 9,999,999.99" ), oFont2)
		
	ENDIF
endif
//nLin += nEsp*2
nLin := fImpCab("6",.F.,oPrn)

FPROGZONA()

FVALIDARRAY('1',_aModelos)
aSort(_aModelos,,,{|x,y| x[2]<y[2]})
if !_lRpc
    If cEmpAnt == "21"
		oPrn:Box( nLin-5, 0050 , nLin-5+50, 0660 )
		oPrn:Box( nLin-5, 0660 , nLin-5+50, 1320 )
		oPrn:Box( nLin-5, 1320 , nLin-5+50, 1980 )
		oPrn:Box( nLin-5, 1980 , nLin-5+50, 2640 )
		oPrn:Box( nLin-5, 2640 , nLin-5+50, 3350 )
		oPrn:Say(nLin,0060,"CAPACIDADE FABRIL",oFont2)
		oPrn:Say(nLin,0950,"JACAR (9.000)"    ,oFont2)
		oPrn:Say(nLin,1620,"PLANO (79.000)"   ,oFont2)
		oPrn:Say(nLin,2260,"MALHA (3.000)"    ,oFont2)
		oPrn:Say(nLin,2950,"FITIM (500)"      ,oFont2)
		
		nLin += nEsp
		
		oPrn:Box( nLin-5, 0050 , nLin-5+50, 0660 )
		oPrn:Box( nLin-5, 0660 , nLin-5+50, 1320 )
		oPrn:Box( nLin-5, 1320 , nLin-5+50, 1980 )
		oPrn:Box( nLin-5, 1980 , nLin-5+50, 2640 )
		oPrn:Box( nLin-5, 2640 , nLin-5+50, 3350 )
						
		oPrn:Say(nLin,0800,"QTD(ML)",oFont2)
		oPrn:Say(nLin,1050,"VALOR",oFont2)
		
		oPrn:Say(nLin,1460,"QTD(ML)",oFont2)
		oPrn:Say(nLin,1710,"VALOR",oFont2)
				
		oPrn:Say(nLin,2120,"QTD(ML)",oFont2)
		oPrn:Say(nLin,2370,"VALOR",oFont2)
		
		oPrn:Say(nLin,2780,"QTD(ML)",oFont2)
		oPrn:Say(nLin,3030,"VALOR",oFont2)
		
		nLin += nEsp

	ElseIf cEmpAnt == "22"
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-500 )
		
		oPrn:Line(nLin-5, 1050-20    , nLin-5+100, 1050-20 )	 //
		oPrn:Line(nLin-5, 1500-50    , nLin-5+100, 1500-50 )	 //
		oPrn:Line(nLin-5, 1935-105   , nLin-5+100, 1935-105 )	 //
		oPrn:Line(nLin-5, 2512-105   , nLin-5+100, 2512-105 )	 //
		
		
		//	oPrn:Say ( nLin    , 60,"CAPACIDADE FABRIL              5000 MANTA/FIBRAS TRAV/ENCHIMENTO 7000 Lencol 250         Saia 700           Protetor 900       Edredon/C. Leito 230 Capa 8000         ", oFont2)
		oPrn:Say(nLin,0060,"CAPACIDADE FABRIL",oFont2)
		oPrn:Say(nLin,0650,"5000 MANTA/FIBRAS", oFont2)
		oPrn:Say(nLin,1050,"TRAV/ENCHIMENTO 10000", oFont2)
		//oPrn:Say(nLin,1475,"Lencol 250", oFont2)
		oPrn:Say(nLin,1475,"Lencol 300", oFont2)  // ssi 4963
		oPrn:Say(nLin,1850,"Saia 400", oFont2)
		oPrn:Say(nLin,2525,"TRAVESSEIRO ESPUMA", oFont2) 
		
		nLin += nEsp
		
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-500 )
		
		oPrn:Say(nLin,0650,"QTD(KG)",oFont2)
		oPrn:Say(nLin,0900,"VALOR",oFont2)
		
		oPrn:Say(nLin,1050,"QTD(Pçs)",oFont2)
		oPrn:Say(nLin,1350,"VALOR",oFont2)
		
		oPrn:Say(nLin,1475,"QTD(Pçs)",oFont2)
		oPrn:Say(nLin,1725,"VALOR",oFont2)
		
		oPrn:Say(nLin,1850,"QTD(Pçs)",oFont2)
		oPrn:Say(nLin,2100,"VALOR",oFont2)
		
		oPrn:Say(nLin,2415,"QTD(Pçs)",oFont2)
		oPrn:Say(nLin,2815,"VALOR",oFont2)
		
		
		nLin += nEsp
	Else
		//SACO
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-0100 )
		oPrn:Say(nLin,0060,"CAPACIDADE FABRIL",oFont2)
		oPrn:Say(nLin,0920,"5000 SACOS PLASTICOS", oFont2)
		oPrn:Say(nLin,1930,"FILME", oFont2)
		oPrn:Say(nLin,2840,"BOBINA", oFont2)
		
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-1890 )
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-0990 )
		nLin += nEsp
		
		
		oPrn:Say(nLin,0650,"QTD(KG)",oFont2)
		oPrn:Say(nLin,0900,"VALOR",oFont2)
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-2350 )
		
		oPrn:Say(nLin,1150,"QTD(KG)",oFont2)
		oPrn:Say(nLin,1400,"VALOR",oFont2)
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-1890 )
		
		oPrn:Say(nLin,1600,"QTD(KG)",oFont2)
		oPrn:Say(nLin,1850,"VALOR",oFont2)
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-1440 )
		
		oPrn:Say(nLin,2050,"QTD(KG)",oFont2)
		oPrn:Say(nLin,2300,"VALOR",oFont2)
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-0990 )
		
		oPrn:Say(nLin,2500,"QTD(KG)",oFont2)
		oPrn:Say(nLin,2750,"VALOR",oFont2)
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-0540 )
		
		oPrn:Say(nLin,2950,"QTD(KG)",oFont2)
		oPrn:Say(nLin,3200,"VALOR",oFont2)
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-0100 )
		
		nLin += nEsp
		
	Endif
endif
//CARTEIRA
For I := 1 to len(_aModelos)
	If _aModelos[i][1] $ "00003I" // LENC	OL
		nQTDtotC 	+= _aModelos[i][3]
		nVtotC		+= _aModelos[i][4]
		nQTLen		:= _aModelos[i][3]
		nVTLen		:= _aModelos[i][4]
	ELSEIF _aModelos[i][1] $ "20009I" // SAIA
		nQTDtotD	+= _aModelos[i][3]
		nVtotD		+= _aModelos[i][4]
		nQTSai		:= _aModelos[i][3]
		nVTSai		:= _aModelos[i][4]
	ELSEIF _aModelos[i][1] $ "00007I" // PROTETOR
		nQTDtotE	+= _aModelos[i][3]
		nVtotE  	+= _aModelos[i][4]
		nQTProt		:= _aModelos[i][3]
		nVTProt		:= _aModelos[i][4]
	ELSEIF _aModelos[i][1] $ "00004I"
		nQTDtotF 	+= _aModelos[i][3]
		nVtotF  	+= _aModelos[i][4]
		nQTEdre		:= _aModelos[i][3]
		nVTEdre		:= _aModelos[i][4]
	ELSEIF _aModelos[i][1] $ "00009I"
		nQTCLeiF 	+= _aModelos[i][3]
		nVtCLeiF  	+= _aModelos[i][4]
		nQTCLei		:= _aModelos[i][3]
		nVTCLei		:= _aModelos[i][4]
	ELSEIF _aModelos[i][1] $ "00011I" // CAPA
		nQTDtotG 	+= _aModelos[i][3]
		nVtotG  	+= _aModelos[i][4]
		nQTCap 		:= _aModelos[i][3]
		nVTCap 		:= _aModelos[i][4]
		
	ELSEIF _aModelos[i][8] $ "001023|001024|001027|001123|001124|001127" // SACO PLASTICO
		nQTDtotH 	+= _aModelos[i][9]
		nVtotH  	+= _aModelos[i][4]
		nQTSac 		:= _aModelos[i][9]
		nVTSac 		:= _aModelos[i][4]
	ELSEIF _aModelos[i][8] $ "001025|001026|001125|001126" // SACO RECICLADO
		nQTDtotI 	+= _aModelos[i][9]
		nVtotI  	+= _aModelos[i][4]
		nQTSRec		:= _aModelos[i][9]
		nVTSRec		:= _aModelos[i][4]
		
	ELSEIF _aModelos[i][8] $ "000023|000024|000027|000123|000124|000127" // BOBINA
		nQTDtotJ 	+= _aModelos[i][9]
		nVtotJ  	+= _aModelos[i][4]
		nQTSBob		:= _aModelos[i][9]
		nVTSBob		:= _aModelos[i][4]
		
	ELSEIF _aModelos[i][8] $ "000025|000026|000125|000126|" // BOBINA RECICLADO
		nQTDtotK 	+= _aModelos[i][9]
		nVtotK  	+= _aModelos[i][4]
		nQTSBRec	:= _aModelos[i][9]
		nVTSBRec	:= _aModelos[i][4]
		
	ELSEIF _aModelos[i][8] $ "000033|000034|000035|000038|000039|000040|000153|000133|000134|000135" // FILME
		nQTDtotL 	+= _aModelos[i][9]
		nVtotL  	+= _aModelos[i][4]
		nQTSFil	    := _aModelos[i][9]
		nVTSFil	    := _aModelos[i][4]
		
	ELSEIF _aModelos[i][8] $ "000036|000037" // FILME RECICLADO
		nQTDtotM 	+= _aModelos[i][9]
		nVtotM  	+= _aModelos[i][4]
		nQTSFRec	:= _aModelos[i][9]
		nVTSFRec	:= _aModelos[i][4]
	ENDIF
	
	
	//    ENDIF
	
	
NEXT

//PROGRAMACAO
For I:=1 to len(_aProgGP)
	If _aProgGP[i][1] $ "00001I|00005I" // MANTAS/FIBRAS
		nLQManFi	+= _aProgGP[i][3]
		nLManFi		+= _aProgGP[i][2]
		//valor para total geral
		nQManFi		+= _aProgGP[i][3]
		nManFi  	+= _aProgGP[i][2]
		
	elseif _aProgGP[i][1] $ "00002I|100070|00008I"	//TRAVESSEIRO/ENCHIMENTO
		
		nLQTraVen	+= _aProgGP[i][3]
		nLTraVen 	+= _aProgGP[i][2]
		//valor para total geral
		nQTraVen	+= _aProgGP[i][3]
		nTraVen 	+= _aProgGP[i][2]
		
	elseif _aProgGP[i][1] $ "10008O"	//TRAVESSEIRO ESPUMA
		
		nLQTraVeE	+= _aProgGP[i][3]
		nLTraVenE 	+= _aProgGP[i][2]
		//valor para total geral
		nQTraVeE	+= _aProgGP[i][3]
		nTraVenE 	+= _aProgGP[i][2]
		
	elseif _aProgGP[i][1] $ "20010I"
		nLQSacVen	+= _aProgGP[i][3]
		nLSacVen 	+= _aProgGP[i][2]
		//valor para total geral
		nQSacVen	+= _aProgGP[i][3]
		nSacVen 	+= _aProgGP[i][2]
	else
		IF _aProgGP[i][1] $ "00003I" // LENCOL
			nQCamOut1 +=_aProgGP[i][3]
			nCamOut1  += _aProgGP[i][2]
		ELSEIF _aProgGP[i][1] $ "20009I" // SAIA
			nQCamOut2 +=_aProgGP[i][3]
			nCamOut2  += _aProgGP[i][2]
		ELSEIF _aProgGP[i][1] $ "00007I" // PROTETOR
			nQCamOut3 +=_aProgGP[i][3]
			nCamOut3  += _aProgGP[i][2]
		ELSEIF _aProgGP[i][1] $ "00004I" // EDREDON
			nQCamOut4 +=_aProgGP[i][3]
			nCamOut4  += _aProgGP[i][2]
		ELSEIF _aProgGP[i][1] $ "00009I" // EDREDON
			nQCamOut6 +=_aProgGP[i][3]
			nCamOut6  += _aProgGP[i][2]
		ELSEIF _aProgGP[i][1] $ "00011I" // CAPA
			nQCamOut5 +=_aProgGP[i][3]
			nCamOut5  += _aProgGP[i][2]
			
		ELSEIF _aProgGP[i][4] $ "001023|001024|001027|001123|001124|001127" // SACO PLASTICO
			nQCamOut7 	+= _aProgGP[i][3]
			nCamOut7  	+= _aProgGP[i][2]
		ELSEIF _aProgGP[i][4] $ "001025|001026|001125|001126" // SACO RECICLADO
			nQCamOut8 	+= _aProgGP[i][3]
			nCamOut8  	+= _aProgGP[i][2]
		ELSEIF _aProgGP[i][4] $ "000023|000024|000027|000123|000124|000127" // BOBINA
			nQCamOut9 	+= _aProgGP[i][3]
			nCamOut9  	+= _aProgGP[i][2]
		ELSEIF _aProgGP[i][4] $ "000025|000026|000125|000126|" // BOBINA RECICLADO
			nQCamOutA 	+= _aProgGP[i][3]
			nCamOutA  	+= _aProgGP[i][2]
		ELSEIF _aProgGP[i][4] $ "000033|000034|000035|000038|000039|000040|000153|000133|000134|000135" // FILME
			nQCamOutB 	+= _aProgGP[i][3]
			nCamOutB  	+= _aProgGP[i][2]
		ELSEIF _aProgGP[i][4] $ "000036|000037" // FILME RECICLADO
			nQCamOutC 	+= _aProgGP[i][3]
			nCamOutC  	+= _aProgGP[i][2]
		ENDIF
	ENDIF
	
	//	Endif
Next

if !_lRpc
    If cEmpAnt == "21"
		oPrn:Box( nLin-5, 0050 , nLin-5+100, 0660 )
		oPrn:Box( nLin-5, 0660 , nLin-5+100, 1320 )
		oPrn:Box( nLin-5, 1320 , nLin-5+100, 1980 )
		oPrn:Box( nLin-5, 1980 , nLin-5+100, 2640 )
		oPrn:Box( nLin-5, 2640 , nLin-5+100, 3350 )

	ElseIf CempAnT == "22"
		//oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-1100 )
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-500 )
		
		oPrn:Line(nLin-5, 1050-20 , nLin-5+100, 1050-20 )	 //
		oPrn:Line(nLin-5, 1500-50 , nLin-5+100, 1500-50 )	 //
		oPrn:Line(nLin-5, 1935-105, nLin-5+100, 1935-105 )	 //
		//oPrn:Line(nLin-5, 2525-105, nLin-5+100, 2815-105 )	 //
		oPrn:Line(nLin-5, 2512-105   , nLin-5+100, 2512-105 )	 //
		
		
	Else
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-2350 )
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-1890 )
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-1440 )
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-0990 )
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-0540 )
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-0100 )
		
	EndIf
	
	oPrn:Say(nLin,0060,"TOT. CARTEIRA ANTES DA PROG.: ", oFont2)
	
	If cEmpAnt == "21"
	ELSEIf CEMPANT == "22"
		//MANTAS/FIBRAS
		oPrn:Say(nLin,0650,Transform(nQManFi+nQTDtot,"@E 999,999"), oFont2)
		oPrn:Say(nLin,0800,Transform(nTotLivreG+nTotFutG+nManFi,"@E 99,999,999.99"), oFontS)
		
		//TRAVESSEIROS/ENCHIMENTOS
		oPrn:Say(nLin,1050,Transform(nLQTraVen+nQTDtotB,"@E 999,999"), oFont2)
		oPrn:Say(nLin,1225,Transform(nTotLGB+nTotFutGB+nTraVen,"@E 99,999,999.99"), oFontS)
		
		//TRAVESSEIROS ESPUMA
		oPrn:Say(nLin,2415,Transform(nQTraVeE+nQTDtotBE,"@E 999,999"), oFont2)                 //QTD 
		oPrn:Say(nLin,2700,Transform(nTotLGBE+nTotFuGBE+nTraVenE,"@E 99,999,999.99"), oFontS)	  //Valor
		
		//LENCOL
		oPrn:Say(nLin,1475,Transform(nQCamOut1+nQTLen,"@E 999,999"), oFont2)
		oPrn:Say(nLin,1600,Transform(nCamOut1+nVTLen,"@E 99,999,999.99"), oFontS)
		
		//SAIA
		oPrn:Say(nLin,1850,Transform(nQCamOut2+nQTSai,"@E 999,999"), oFont2)
		oPrn:Say(nLin,1985,Transform(nCamOut2+nVTSai,"@E 99,999,999.99"), oFontS)
		
		//TRAVESSEIRO DE ESPUMA
		/*oPrn:Say(nLin,1850,Transform(nQCamOut2+nQTSai,"@E 999,999"), oFont2)
		oPrn:Say(nLin,1985,Transform(nCamOut2+nVTSai,"@E 99,999,999.99"), oFontS)*/
	ELSE
		//SACO PLASTICO
		//	oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-0200 )
		
		oPrn:Say(nLin,0650,Transform(nQSacVen+nQTSac,"@E 999,999"), oFont2)
		oPrn:Say(nLin,0800,Transform(nSacVen+nVTSac,"@E 99,999,999.99"), oFontS)
		//	oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-1850 )
		
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-2350 )
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-1890 )
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-1440 )
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-0990 )
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-0540 )
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-0100 )
		/*
		oPrn:Say(nLin,1050,Transform(nQTraVen+nQTDtotB,"@E 999,999"), oFont2)
		oPrn:Say(nLin,1225,Transform(nTotLGB+nTotFutGB+nTraVen,"@E 99,999,999.99"), oFontS)
		
		oPrn:Say(nLin,1475,Transform(nQCamOut1+nQTLen,"@E 999,999"), oFont2)
		oPrn:Say(nLin,1600,Transform(nCamOut1+nVTLen,"@E 99,999,999.99"), oFontS)
		*/
	ENDIF
	
	nLin += nEsp
	
    If cEmpAnt == "21"
		oPrn:Box( nLin-5, 0050 , nLin-5+100, 0660 )
		oPrn:Box( nLin-5, 0660 , nLin-5+100, 1320 )
		oPrn:Box( nLin-5, 1320 , nLin-5+100, 1980 )
		oPrn:Box( nLin-5, 1980 , nLin-5+100, 2640 )
		oPrn:Box( nLin-5, 2640 , nLin-5+100, 3350 )

	ElseIf CempAnT == "22"

		//oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-1100 )
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-500 )
		
		oPrn:Line(nLin-5, 1050-20    , nLin-5+100, 1050-20 )	 //
		oPrn:Line(nLin-5, 1500-50    , nLin-5+100, 1500-50 )	 //
		oPrn:Line(nLin-5, 1935-105   , nLin-5+100, 1935-105 )	 //
		//oPrn:Line(nLin-5, 2525-105, nLin-5+100, 2815-105 )	 //
		oPrn:Line(nLin-5, 2512-105   , nLin-5+100, 2512-105 )	 //
		
		
	Else
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-2350 )
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-1890 )
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-1440 )
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-0990 )
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-0540 )
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-0100 )
	EndIf
	
	oPrn:Say(nLin,0060,"TOTAL CARTEIRA APOS PROG....: ", oFont2)
	
    If cEmpAnt == "21"
	ElseIf cEmpAnt == "22"
		//MANTA
		oPrn:Say(nLin,0650,Transform(nQTDtot,"@E 999,999"), oFont2)
		oPrn:Say(nLin,0800,Transform(nTotLivreG+nTotFutG,"@E 99,999,999.99"), oFontS)
		
		//TRAV/ENCHIMENTOS
		/*oPrn:Say(nLin,1050,Transform(nQTDtotB,"@E 999,999"), oFont2)
		oPrn:Say(nLin,1225,Transform(nTotLGB+nTotFuGBE,"@E 99,999,999.99"), oFontS)*/
		
		//TRAV/ENCHIMENTOS
		oPrn:Say(nLin,1050,Transform(nQTDtotB,"@E 999,999"), oFont2)
		oPrn:Say(nLin,1225,Transform(nTotLGB+nTotFutGB,"@E 99,999,999.99"), oFontS)
		
		//TRAVESSEIRO ESPUMA
		oPrn:Say(nLin,2415,Transform(nQTDTotBE,"@E 999,999"), oFont2)
		oPrn:Say(nLin,2700,Transform(nTotLGBE+nTotFuGBE,"@E 99,999,999.99"), oFontS)
	
		//LENCOL
		oPrn:Say(nLin,1475,Transform(nQTDtotC,"@E 999,999"), oFont2)
		oPrn:Say(nLin,1600,Transform(nVtotC,"@E 99,999,999.99"), oFontS)
		
		//SAIA
		oPrn:Say(nLin,1850,Transform(nQTDtotD,"@E 999,999"), oFont2)
		oPrn:Say(nLin,1985,Transform(nVtotD,"@E 99,999,999.99"), oFontS)
	ELSE
		//SACO PLASTICO
		oPrn:Say(nLin,0650,Transform(nQTDtotH, "@E 999,999"), oFont2)
		oPrn:Say(nLin,0800,Transform(nVtotH, "@E 99,999,999.99"), oFontS)
	ENDIF
	
	nLin += nEsp
	
    If cEmpAnt == "21"
		oPrn:Box( nLin-5, 0050 , nLin-5+100, 0660 )
		oPrn:Box( nLin-5, 0660 , nLin-5+100, 1320 )
		oPrn:Box( nLin-5, 1320 , nLin-5+100, 1980 )
		oPrn:Box( nLin-5, 1980 , nLin-5+100, 2640 )
		oPrn:Box( nLin-5, 2640 , nLin-5+100, 3350 )

	ElseIf CempAnT == "22"

		//oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-1100 )
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-500 )
		
		oPrn:Line(nLin-5, 1050-20    , nLin-5+100, 1050-20 )	 //
		oPrn:Line(nLin-5, 1500-50    , nLin-5+100, 1500-50 )	 //
		oPrn:Line(nLin-5, 1935-105   , nLin-5+100, 1935-105 )	 //
		oPrn:Line(nLin-5, 2512-105   , nLin-5+100, 2512-105 )	 //
		//oPrn:Line(nLin-5, 2525-105, nLin-5+100, 2815-105 )	 //
		
	Else
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-2350 )
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-1890 )
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-1440 )
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-0990 )
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-0540 )
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-0100 )
	EndIf
	oPrn:Say(nLin,0060,"TOT. PROGRAMADO EM  "  + DTOC(MV_PAR33) + ": ", oFont2)
	
	//**PROGRAMADOS**
	If cEmpAnt == "21"
	ElseIf cEmpAnt == "22"
		
		//MANTA
		oPrn:Say(nLin,0650,Transform(nLQManFi,"@E 999,999"), oFont2)
		oPrn:Say(nLin,0800,Transform(nLManFi,"@E 99,999,999.99"), oFontS)
		
		//TRAVESSEIRO
		oPrn:Say(nLin,1050,Transform(nLQTraVen,"@E 999,999"), oFont2)
		oPrn:Say(nLin,1225,Transform(nLTraVen,"@E 99,999,999.99"), oFontS)

		//TRAVESSEIRO Espuma
		oPrn:Say(nLin,2415,Transform(nLQTraVeE,"@E 999,999"), oFont2)
		oPrn:Say(nLin,2700,Transform(nLTraVenE,"@E 99,999,999.99"), oFontS)
		
		
		// LENCOL
		oPrn:Say(nLin,1475,Transform(nQCamOut1,"@E 999,999"), oFont2)
		oPrn:Say(nLin,1600,Transform(nCamOut1,"@E 99,999,999.99"), oFontS)
		
		// SAIA
		oPrn:Say(nLin,1850,Transform(nQCamOut2,"@E 999,999"), oFont2)
		oPrn:Say(nLin,1985,Transform(nCamOut2,"@E 99,999,999.99"), oFontS)
	ELSE
		//SACO PLASTICO
		oPrn:Say(nLin,0650,Transform(nLQSacVen, "@E 999,999"), oFont2)
		oPrn:Say(nLin,0800,Transform(nLSacVen, "@E 99,999,999.99"), oFontS)
	ENDIF
endif
nLin += nEsp

FPRODUC()

if !_lRpc
    If cEmpAnt == "21"
		oPrn:Box( nLin-5, 0050 , nLin-5+50, 0660 )
		oPrn:Box( nLin-5, 0660 , nLin-5+50, 1320 )
		oPrn:Box( nLin-5, 1320 , nLin-5+50, 1980 )
		oPrn:Box( nLin-5, 1980 , nLin-5+50, 2640 )
		oPrn:Box( nLin-5, 2640 , nLin-5+50, 3350 )

	ElseIf CempAnT == "22"
		//oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-1100 )
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-500 )
		
		oPrn:Line(nLin-5, 1050-20    , nLin-5+50, 1050-20 )	 //
		oPrn:Line(nLin-5, 1500-50    , nLin-5+50, 1500-50 )	 //
		oPrn:Line(nLin-5, 1935-105   , nLin-5+50, 1935-105 )	 //
		//oPrn:Line(nLin-5, 2525-105, nLin-5+100, 2815-105 )	 //
		oPrn:Line(nLin-5, 2512-105   , nLin-5+100, 2512-105 )	 //
	Else
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-2350 )
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-1890 )
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-1440 )
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-0990 )
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-0540 )
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-0100 )
	EndIf
	
	oPrn:Say(nLin,0060,"TOTAL PROD. ESTOQUE "  + DTOC(MV_PAR33) + ": ", oFont2)
endif

For i := 1 To Len(_aProdGP)
	
	If _aProdGP[i][1] $ "00001I|00005I" // MANTAS/FIBRAS
		nQManP += _aProdGP[i][3]
	elseif _aProdGP[i][1] $ "00002I|100070|00008I" // TRAV.
		nQTravP += _aProdGP[i][3]
	elseif _aProdGP[i][1] $ "10008O" // TRAV. Espuma
	   nQTravPe += _aProdGP[i][3]
	else
		IF _aProdGP[i][4] $ "00003I" // LENCOL
			nQLencP +=_aProdGP[i][3]
		ELSEIF _aProdGP[i][4] $ "20009I" // SAIA
			nQSaiaP +=_aProdGP[i][3]
		ELSEIF _aProdGP[i][4] $ "00007I" // PROTETOR
			nQProtP +=_aProdGP[i][3]
		ELSEIF _aProdGP[i][4] $ "00004I" // EDREDON
			nQEdreP +=_aProdGP[i][3]
			nQCLeiP +=_aProdGP[i][6]
		ELSEIF _aProdGP[i][4] $ "00011I" // CAPA
			nQCapaP +=_aProdGP[i][3] 
		ELSEIF _aProdGP[i][4] $ "20010I" // CAPA
			nQSacoP +=_aProdGP[i][3]
		ENDIF
	ENDIF
NEXT

if !_lRpc
	If cEmpAnt == "21"
	ElseIf CempAnT$"22"
		oPrn:Say(nLin,0650,Transform(nQManP, "@E 999,999"), oFont2)
		
		//TRAVESSEIROS/ENCHIMENTOS
		oPrn:Say(nLin,1050,Transform(nQTravP, "@E 999,999"), oFont2)
		
		//Travesseiros Espuma
		oPrn:Say(nLin,2625,Transform(nQTravPe, "@E 999,999"), oFont2)
		
		//LENCOL
		oPrn:Say(nLin,1475,Transform(nQLencP, "@E 999,999"), oFont2)
		
		//SAIA
		oPrn:Say(nLin,1850,Transform(nQSaiaP, "@E 999,999"), oFont2)
	Else
		//SACO
		oPrn:Say(nLin,0650,Transform(nQSacoP, "@E 999,999"), oFont2)
	Endif
endif
FABATE()
nLin += nEsp
if !_lRpc
    If cEmpAnt == "21"
		oPrn:Box( nLin-5, 0050 , nLin-5+50, 0660 )
		oPrn:Box( nLin-5, 0660 , nLin-5+50, 1320 )
		oPrn:Box( nLin-5, 1320 , nLin-5+50, 1980 )
		oPrn:Box( nLin-5, 1980 , nLin-5+50, 2640 )
		oPrn:Box( nLin-5, 2640 , nLin-5+50, 3350 )

	ElseIf CempAnT == "22"
		//oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-1100 )
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-500 )
		
		oPrn:Line(nLin-5, 1050-20    , nLin-5+50, 1050-20 )	 //
		oPrn:Line(nLin-5, 1500-50    , nLin-5+50, 1500-50 )	 //
		oPrn:Line(nLin-5, 1935-105   , nLin-5+50, 1935-105 )	 //
		oPrn:Line(nLin-5, 2512-105   , nLin-5+100, 2512-105 )	 //
		
	Else
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-2350 )
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-1890 )
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-1440 )
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-0990 )
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-0540 )
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-0100 )
	EndIf
	
	oPrn:Say(nLin,0060,"TOTAL ABAT. ESTOQUE "  + DTOC(MV_PAR33) + ": ", oFont2)
endif
For i := 1 To Len(_aBATE)
	If _aBATE[i][1] $ "00001I|00005I" // MANTAS/FIBRAS
		nQManAB  += _aBATE[i][2]
		
	elseif _aBATE[i][1] $ "00002I|00008I|100070" // TRAV.
		nQTravAB += _aBATE[i][2]
		
	elseif _aBATE[i][1] $ "10008O" // TRAV.ESPUMA
	   nQTravAE += _aBATE[i][2]
		
	ELSEIF _aBATE[i][1] $ "00003I" // LENCOL
		nQLencAB += _aBATE[i][2]
		
	ELSEIF _aBATE[i][1] $ "20009I" // SAIA
		nQSaiaAB += _aBATE[i][2]
		
	ELSEIF _aBATE[i][1] $ "00007I" // PROTETOR
		nQProtAB += _aBATE[i][2]
		
	ELSEIF _aBATE[i][1] $ "00004I" // EDREDON
		nQEdreAB += _aBATE[i][2]
		//		nQCLeiAB += _aBATE[i][3]
		
	ELSEIF _aBATE[i][1] $ "00011I" // CAPA
		nQCapaAB += _aBATE[i][2]
		
	ELSEIF _aBATE[i][1] $ "20010I" // CAPA
		nQSacoAB += _aBATE[i][2]
		
	ENDIF
	
NEXT
if !_lRpc
	If cEmpAnt == "21"
	ElseIf cEmpAnt$"22"
		
		//MANTAS
		oPrn:Say(nLin,0650,Transform(nQManAB, "@E 999,999"), oFont2)
		
		//TRAVESSEIROS/ENCHIMENTOS
		oPrn:Say(nLin,1050,Transform(nQTravAB, "@E 999,999"), oFont2)
		
		//Travesseiro Espuma
		oPrn:Say(nLin,2625,Transform(nQTravAE, "@E 999,999"), oFont2)
				
		//LENCOL
		oPrn:Say(nLin,1475,Transform(nQLencAB, "@E 999,999"), oFont2)
		
		//SAIA
		oPrn:Say(nLin,1850,Transform(nQSaiaAB, "@E 999,999"), oFont2)
	Else
		oPrn:Say(nLin,0650,Transform(nQSacoAB, "@E 999,999"), oFont2)
	Endif
	
	nLin += nEsp
	
    If cEmpAnt == "21"
		oPrn:Box( nLin-5, 0050 , nLin-5+50, 0660 )
		oPrn:Box( nLin-5, 0660 , nLin-5+50, 1320 )
		oPrn:Box( nLin-5, 1320 , nLin-5+50, 1980 )
		oPrn:Box( nLin-5, 1980 , nLin-5+50, 2640 )
		oPrn:Box( nLin-5, 2640 , nLin-5+50, 3350 )

	ElseIf CempAnT == "22"
		//oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-1100 )
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-500 )
		
		oPrn:Line(nLin-5, 1050-20    , nLin-5+50, 1050-20 )	 //
		oPrn:Line(nLin-5, 1500-50    , nLin-5+50, 1500-50 )	 //
		oPrn:Line(nLin-5, 1935-105   , nLin-5+50, 1935-105 )	 //
		oPrn:Line(nLin-5, 2512-105   , nLin-5+100, 2512-105 )	 //
	Else
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-2350 )
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-1890 )
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-1440 )
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-0990 )
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-0540 )
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-0100 )
	EndIf
	oPrn:Say(nLin,0060,"TOTAL PRODUZIDO ............: ", oFont2)
	
	If cEmpAnt == "21"
	ElseIf cEmpAnt == "22"
		
		//MANTAS
		oPrn:Say(nLin,0650,Transform(nLQManFi + nQManP - nQManAB, "@E 999,999"), oFont2)
		
		//TRAVESSEIROS/ENCHIMENTOS
		oPrn:Say(nLin,1050,Transform(nLQTraVen + nQTravP - nQTravAB, "@E 99,999,999.99"), oFont2)
		
		//Travesseiros Espuma
		oPrn:Say(nLin,2625,Transform(nLQTraVeE + nQTravPE - nQTravAE, "@E 99,999,999.99"), oFont2)
		
		//LENCOL
		oPrn:Say(nLin,1475,Transform(nQCamOut1 + nQLencP - nQLencAB, "@E 999,999"), oFont2)
		
		//SAIA
		oPrn:Say(nLin,1850,Transform(nQCamOut2 + nQSaiaP - nQSaiaAB, "@E 999,999"), oFont2)
	Else
		oPrn:Say(nLin,0650,Transform(nLQSacVen + nQSacoP - nQSacoAB, "@E 999,999"), oFont2)
	Endif
	
	nLin += nEsp
	
    If cEmpAnt == "21"
		oPrn:Box( nLin-5, 0050 , nLin-5+50, 0660 )
		oPrn:Box( nLin-5, 0660 , nLin-5+50, 1320 )
		oPrn:Box( nLin-5, 1320 , nLin-5+50, 1980 )
		oPrn:Box( nLin-5, 1980 , nLin-5+50, 2640 )
		oPrn:Box( nLin-5, 2640 , nLin-5+50, 3350 )

	ElseIf CempAnT == "22"
		//oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-1100 )
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-500 )
		
		oPrn:Line(nLin-5, 1050-20    , nLin-5+50, 1050-20 )	 //
		oPrn:Line(nLin-5, 1500-50    , nLin-5+50, 1500-50 )	 //
		oPrn:Line(nLin-5, 1935-105   , nLin-5+50, 1935-105 )	 //
		oPrn:Line(nLin-5, 2512-105   , nLin-5+100, 2512-105 )	 //
	Else
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-2350 )
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-1890 )
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-1440 )
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-0990 )
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-0540 )
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-0100 )
	EndIf
	oPrn:Say(nLin,0060,"ACUMULADO MES ..............: ", oFont2)
endif
FACUMES()

For i := 1 To Len(_aCUMES)
	If _aCUMES[i][1] $ "00001I|00005I" // MANTAS/FIBRAS
		nQManAC  += _aCUMES[i][3]
		nVManAC  += _aCUMES[i][4]
		If _aCUMES[i][5] > nDiasM
			nDiasM   := _aCUMES[i][5]
		Endif
	elseif _aCUMES[i][1] $ "00002I|100070|00008I" // TRAV.
		nQTravAC += _aCUMES[i][3]
		nVTravAC += _aCUMES[i][4]
		If _aCUMES[i][5] > nDiasT
			nDiasT   := _aCUMES[i][5]
		Endif
		
		cModelo := _aCUMES[i][1]
	elseif _aCUMES[i][1] $ "10008O" // TRAV.ESPUMA
		nQTravACe += _aCUMES[i][3]
		nVTravACe += _aCUMES[i][4]
		If _aCUMES[i][5] > nDiasTe
			nDiasTe   := _aCUMES[i][5]
		Endif
		
		cModelo := _aCUMES[i][1]
	ELSEIF _aCUMES[i][1] $ "00003I" // LENCOL
		nQLencAC += _aCUMES[i][3]
		nVLencAC += _aCUMES[i][4]
		nDiasL   := _aCUMES[i][5]
	ELSEIF _aCUMES[i][1] $ "20009I" // SAIA
		nQSaiaAC += _aCUMES[i][3]
		nVSaiaAC += _aCUMES[i][4]
		nDiasS   := _aCUMES[i][5]
	ELSEIF _aCUMES[i][1] $ "00007I" // PROTETOR
		nQProtAC += _aCUMES[i][3]
		nVProtAC += _aCUMES[i][4]
		nDiasP   := _aCUMES[i][5]
	ELSEIF _aCUMES[i][1] $ "00004I" // EDREDON
		nQEdreAC += _aCUMES[i][3]
		nVEdreAC += _aCUMES[i][4]
		nDiasE   := _aCUMES[i][5]
	ELSEIF _aCUMES[i][1] $ "00009I" // COBRE LEITO
		nQcobreAC += _aCUMES[i][3]
		nVcobreAC += _aCUMES[i][4]
		nDiasCL   := _aCUMES[i][5]
	ELSEIF _aCUMES[i][1] $ "00011I" // CAPA
		nQCapaAC += _aCUMES[i][3]
		nVCapaAC += _aCUMES[i][4]
		nDiasC   := _aCUMES[i][5]
	ELSEIF _aCUMES[i][1] $ "20010I" // CAPA
		nQSacoAC += _aCUMES[i][3]
		nVSacoAC += _aCUMES[i][4]
		nDiasSC   := _aCUMES[i][5]
	ENDIF
	
NEXT

if !_lRpc
	If cEmpAnt == "21"
	ElseIf cEmpAnt == "22"
		
		//MANTA
		oPrn:Say(nLin,0650,Transform(nQManAC,"@E 999,999"), oFont2)
		oPrn:Say(nLin,0800,Transform(nVManAC,"@E 99,999,999.99"), oFontS)
		
		//TRAVESSEIRO
		oPrn:Say(nLin,1050,Transform(nQTravAC,"@E 999,999"), oFont2)
		oPrn:Say(nLin,1225,Transform(nVTravAC,"@E 99,999,999.99"), oFontS)
		
		//TRAVESSEIRO Espuma
   	    oPrn:Say(nLin,2415,Transform(nQTravACe,"@E 999,999"), oFont2)
		oPrn:Say(nLin,2700,Transform(nVTravACe,"@E 99,999,999.99"), oFontS)
		
		// LENCOL
		oPrn:Say(nLin,1475,Transform(nQLencAC,"@E 999,999"), oFont2)
		oPrn:Say(nLin,1600,Transform(nVLencAC,"@E 99,999,999.99"), oFontS)
		
		// SAIA
		oPrn:Say(nLin,1850,Transform(nQSaiaAC,"@E 999,999"), oFont2)
		oPrn:Say(nLin,1985,Transform(nVSaiaAC,"@E 99,999,999.99"), oFontS)
	Else
		
		//SACO
		oPrn:Say(nLin,0650,Transform(nQSacoAC, "@E 999,999"), oFont2)
		oPrn:Say(nLin,0800,Transform(nVSacoAC, "@E 99,999,999.99"), oFontS)
		
	Endif
	
	nLin += nEsp
	
    If cEmpAnt == "21"
		oPrn:Box( nLin-5, 0050 , nLin-5+50, 0660 )
		oPrn:Box( nLin-5, 0660 , nLin-5+50, 1320 )
		oPrn:Box( nLin-5, 1320 , nLin-5+50, 1980 )
		oPrn:Box( nLin-5, 1980 , nLin-5+50, 2640 )
		oPrn:Box( nLin-5, 2640 , nLin-5+50, 3350 )

	ElseIf CempAnT == "22"
		//oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-1100 )
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-500 )
		
		oPrn:Line(nLin-5, 1050-20    , nLin-5+50, 1050-20 )	 //
		oPrn:Line(nLin-5, 1500-50    , nLin-5+50, 1500-50 )	 //
		oPrn:Line(nLin-5, 1935-105   , nLin-5+50, 1935-105 )	 //
		oPrn:Line(nLin-5, 2512-105   , nLin-5+100, 2512-105 )	 //
	Else
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-2350 )
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-1890 )
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-1440 )
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-0990 )
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-0540 )
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-0100 )
	EndIf
	oPrn:Say(nLin,0060,"MEDIA DIA ..................: ", oFont2)
	
	If cEmpAnt == "21"
	ElseIF cEmpAnt == "22"
		
		//MANTA
		oPrn:Say(nLin,0650,Transform(nQManAC/nDiasM,"@E 999,999"), oFont2)
		oPrn:Say(nLin,0800,Transform(nVManAC/nDiasM,"@E 99,999,999.99"), oFontS)
		
		//TRAVESSEIRO
		oPrn:Say(nLin,1050,Transform(nQTravAC/nDiasT,"@E 999,999"), oFont2)
		oPrn:Say(nLin,1225,Transform(nVTravAC/nDiasT,"@E 99,999,999.99"), oFontS)
		
		//TRAVESSEIRO ESPUMA
		oPrn:Say(nLin,2415,Transform(nQTravACe/nDiasTe,"@E 999,999"), oFont2)				
		oPrn:Say(nLin,2700,Transform(nVTravACe/nDiasTe,"@E 99,999,999.99"), oFontS)
		
		// LENCOL
		oPrn:Say(nLin,1475,Transform(nQLencAC/nDiasL,"@E 999,999"), oFont2)
		oPrn:Say(nLin,1600,Transform(nVLencAC/nDiasL,"@E 99,999,999.99"), oFontS)
		
		// SAIA
		oPrn:Say(nLin,1850,Transform(nQSaiaAC/nDiasS,"@E 999,999"), oFont2)
		oPrn:Say(nLin,1985,Transform(nVSaiaAC/nDiasS,"@E 99,999,999.99"), oFontS)
	ELSE
		//SACO
		oPrn:Say(nLin,0650,Transform(nQSacoAC/nDiasM, "@E 999,999"), oFont2)
		oPrn:Say(nLin,0800,Transform(nVSacoAC/nDiasM, "@E 99,999,999.99"), oFontS)
	ENDIF
	
	nLin += nEsp
	
    If cEmpAnt == "21"
		oPrn:Box( nLin-5, 0050 , nLin-5+50, 0660 )
		oPrn:Box( nLin-5, 0660 , nLin-5+50, 1320 )
		oPrn:Box( nLin-5, 1320 , nLin-5+50, 1980 )
		oPrn:Box( nLin-5, 1980 , nLin-5+50, 2640 )
		oPrn:Box( nLin-5, 2640 , nLin-5+50, 3350 )

	ElseIf CempAnT == "22"

		//oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-1100 )
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-500 )
		
		oPrn:Line(nLin-5, 1050-20    , nLin-5+50, 1050-20 )	 //
		oPrn:Line(nLin-5, 1500-50    , nLin-5+50, 1500-50 )	 //
		oPrn:Line(nLin-5, 1935-105   , nLin-5+50, 1935-105 )	 //
		oPrn:Line(nLin-5, 2512-105   , nLin-5+100, 2512-105 )	 //
	Else
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-2350 )
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-1890 )
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-1440 )
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-0990 )
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-0540 )
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-0100 )
	EndIf
	oPrn:Say(nLin,0060,"DIAS QUE OCORRERAM PROG ....: ", oFont2)
	
	If cEmpAnt == "21"
	ElseIf cEmpAnt == "22"
		//MANTA
		oPrn:Say(nLin,0650,Transform(nDiasM,"@E 999,999"), oFont2)
		
		//TRAV/ENCHIMENTOS
		oPrn:Say(nLin,1050,Transform(nDiasT,"@E 999,999"), oFont2)
		
		//TRAV/ESPUMA
		oPrn:Say(nLin,2415,Transform(nDiasTe,"@E 999,999"), oFont2)
		
		//LENCOL
		oPrn:Say(nLin,1475,Transform(nDiasL,"@E 999,999"), oFont2)
		
		//SAIA
		oPrn:Say(nLin,1850,Transform(nDiasS,"@E 999,999"), oFont2)
	Else
		//SACO
		oPrn:Say(nLin,0650,Transform(nDiasSC, "@E 999,999"), oFont2)
	Endif
	
	nLin += nEsp
	
    If cEmpAnt == "21"
		oPrn:Box( nLin-5, 0050 , nLin-5+50, 0660 )
		oPrn:Box( nLin-5, 0660 , nLin-5+50, 1320 )
		oPrn:Box( nLin-5, 1320 , nLin-5+50, 1980 )
		oPrn:Box( nLin-5, 1980 , nLin-5+50, 2640 )
		oPrn:Box( nLin-5, 2640 , nLin-5+50, 3350 )

	ElseIf CempAnT == "22"
		//oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-1100 )
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-500 )
		
		oPrn:Line(nLin-5, 1050-20    , nLin-5+50, 1050-20 )	 //
		oPrn:Line(nLin-5, 1500-50    , nLin-5+50, 1500-50 )	 //
		oPrn:Line(nLin-5, 1935-105   , nLin-5+50, 1935-105 )	 //
		oPrn:Line(nLin-5, 2512-105   , nLin-5+100, 2512-105 )	 //
	Else
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-2350 )
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-1890 )
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-1440 )
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-0990 )
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-0540 )
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-0100 )
	EndIf
	
	oPrn:Say(nLin,0060,"CARTEIRA / MEDIA DIA .......: ", oFont2)
	
    If cEmpAnt == "21"
	ElseIF cEmpAnt == "22"
		
		//MANTA
		oPrn:Say(nLin,0650,Transform(int(iif((nQTDtot/5000)<0,0,(nQTDtot/5000))),"@E 999,999"), oFont2)
		
		//TRAV/ENCHIMENTOS
		oPrn:Say(nLin,1050,Transform(int(iif((nQTDtotB/10000)<0,0,nQTDtotB/10000)),"@E 999,999"), oFont2)
		
		//TRAV/ESPUMA
		oPrn:Say(nLin,2625,Transform(int(iif((nQTDtotB/10000)<0,0,nQTDtotB/10000)),"@E 999,999"), oFont2)
		
		//LENCOL
		oPrn:Say(nLin,1475,Transform(int(iif((nQTDtotC/500)<0,0,(nQTDtotC/500))),"@E 999,999"), oFont2)
		
		//SAIA
		oPrn:Say(nLin,1850,Transform(int(iif((nQTDtotD/700)<0,0,(nQTDtotD/700))),"@E 999,999"), oFont2)
	Else
		//SACO
		oPrn:Say(nLin,0650,Transform(nQTDtotH/(nQSacoAC/nDiasSC), "@E 999,999"), oFont2)
		
	Endif
	
	nLin += nEsp
	
    If cEmpAnt == "21"
		oPrn:Box( nLin-5, 0050 , nLin-5+50, 0660 )
		oPrn:Box( nLin-5, 0660 , nLin-5+50, 1320 )
		oPrn:Box( nLin-5, 1320 , nLin-5+50, 1980 )
		oPrn:Box( nLin-5, 1980 , nLin-5+50, 2640 )
		oPrn:Box( nLin-5, 2640 , nLin-5+50, 3350 )

	ElseIf CempAnT == "22"
		//oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-1100 )
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-500 )
		
		oPrn:Line(nLin-5, 1050-20    , nLin-5+50, 1050-20 )	 //
		oPrn:Line(nLin-5, 1500-50    , nLin-5+50, 1500-50 )	 //
		oPrn:Line(nLin-5, 1935-105   , nLin-5+50, 1935-105 )	 //
		oPrn:Line(nLin-5, 2512-105   , nLin-5+100, 2512-105 )	 //
	Else
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-2350 )
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-1890 )
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-1440 )
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-0990 )
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-0540 )
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-0100 )
	EndIf
	oPrn:Say(nLin,0060,"ESTOQUE ....................: ", oFont2)
endif
FEstoque()
if !_lRpc
	If cEmpAnt == "21"
	ElseIF cEMpAnt == "22"
		
		// MANTAS/FIBRAS
		oPrn:Say(nLin,0650,Transform(_AEST[1][1], "@E 999,999"), oFont2)
		
		// TRAV.
		oPrn:Say(nLin,1050,Transform(_AEST[1][2], "@E 999,999"), oFont2)
		
		// TRAV.ESPUMA
		oPrn:Say(nLin,2625,Transform(_AEST[1][10], "@E 999,999"), oFont2)
		
		// LENCOL
		oPrn:Say(nLin,1475,Transform(_AEST[1][3], "@E 999,999"), oFont2)
		
		//  SAIA
		oPrn:Say(nLin,1850,Transform(_AEST[1][4], "@E 999,999"), oFont2)
	ELSE
		oPrn:Say(nLin,0650,Transform(_AEST[1][8], "@E 999,999"), oFont2)
	ENDIF
	nLin += 400
endif

If cEmpAnt == "21"
ElseIF cEmpAnt == "22"
	if !_lRpc
		//oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-1100 )
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-600 )
		
		oPrn:Line(nLin-5, 1050-20    , nLin-5+100, 1050-20 )	 //
		oPrn:Line(nLin-5, 1500-50    , nLin-5+100, 1500-50 )	 //
		oPrn:Line(nLin-5, 1935-105   , nLin-5+100, 1935-105 )	 //
		//oPrn:Line(nLin-5, 2512-105   , nLin-5+100, 2512-105 )	 //
		
		oPrn:Say(nLin,0060,"CAPACIDADE FABRIL",oFont2)
		oPrn:Say(nLin,0650,"Protetor 1400", oFont2)
		oPrn:Say(nLin,1050,"Edredon 100", oFont2)
		oPrn:Say(nLin,1475,"C.Leito 30", oFont2)
		oPrn:Say(nLin,1850,"Capa 10000", oFont2)
		nLin += nEsp
		
		//oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-1100 )
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-600 )
		
		oPrn:Say(nLin,0650,"QTD(Pçs)",oFont2)
		oPrn:Say(nLin,0900,"VALOR",oFont2)
		
		oPrn:Say(nLin,1050,"QTD(Pçs)",oFont2)
		oPrn:Say(nLin,1350,"VALOR",oFont2)
		
		oPrn:Say(nLin,1475,"QTD(Pçs)",oFont2)
		oPrn:Say(nLin,1725,"VALOR",oFont2)
		
		oPrn:Say(nLin,1850,"QTD(Pçs)",oFont2)
		oPrn:Say(nLin,2100,"VALOR",oFont2)
		
		nLin += nEsp
		
		//oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-1100 )
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-600 )
		
		oPrn:Line(nLin-5, 1050-20 , nLin-5+100, 1050-20 )	 //
		oPrn:Line(nLin-5, 1500-50 , nLin-5+100, 1500-50 )	 //
		oPrn:Line(nLin-5, 1935-105, nLin-5+100, 1935-105 )	 //
		
		oPrn:Say(nLin,0060,"TOT. CARTEIRA ANTES DA PROG.: ", oFont2)
		
		//PROTETOR
		oPrn:Say(nLin,0650,Transform(nQCamOut3+nQTProt,"@E 999,999"), oFont2)
		oPrn:Say(nLin,0800,Transform(nCamOut3+nVTProt,"@E 99,999,999.99"), oFontS)
		
		//EDREDON
		oPrn:Say(nLin,1050,Transform(nQCamOut4+nQTEdre,"@E 999,999"), oFont2)
		oPrn:Say(nLin,1225,Transform(nCamOut4+nVTEdre,"@E 99,999,999.99"), oFontS)
		
		//Cobre Leito
		oPrn:Say(nLin,1475,Transform(nQCamOut6+nQTCLei,"@E 999,999"), oFont2)
		oPrn:Say(nLin,1600,Transform(nCamOut6+nVTCLei,"@E 99,999,999.99"), oFontS)
		
		//CAPA
		oPrn:Say(nLin,1850,Transform(nQCamOut5+nQTCap,"@E 999,999"), oFont2)
		oPrn:Say(nLin,1985,Transform(nCamOut5+nVTCap,"@E 99,999,999.99"), oFontS)
		
		
		nLin += nEsp
		
		//oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-1100 )
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-600 )
		
		oPrn:Line(nLin-5, 1050-20    , nLin-5+100, 1050-20 )	 //
		oPrn:Line(nLin-5, 1500-50    , nLin-5+100, 1500-50 )	 //
		oPrn:Line(nLin-5, 1935-105   , nLin-5+100, 1935-105 )	 //
		
		oPrn:Say(nLin,0060,"TOTAL CARTEIRA APOS PROG....: ", oFont2)
		
		//protetor
		oPrn:Say(nLin,0650,Transform(nQTDtotE,"@E 999,999"), oFont2)
		oPrn:Say(nLin,0800,Transform(nVtotE,"@E 99,999,999.99"), oFontS)
		
		//EDREDON
		oPrn:Say(nLin,1050,Transform(nQTDtotF,"@E 999,999"), oFont2)
		oPrn:Say(nLin,1225,Transform(nVtotF,"@E 99,999,999.99"), oFontS)
		
		//Cobre leito
		oPrn:Say(nLin,1475,Transform(nQTCLeiF,"@E 999,999"), oFont2)
		oPrn:Say(nLin,1600,Transform(nVtCLeiF,"@E 99,999,999.99"), oFontS)
		
		//CAPA
		oPrn:Say(nLin,1850,Transform(nQTDtotG,"@E 999,999"), oFont2)
		oPrn:Say(nLin,1985,Transform(nVtotG,"@E 99,999,999.99"), oFontS)
		
		nLin += nEsp
		
		//oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-1100 )
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-600 )
		
		oPrn:Line(nLin-5, 1050-20    , nLin-5+100, 1050-20 )	 //
		oPrn:Line(nLin-5, 1500-50    , nLin-5+100, 1500-50 )	 //
		oPrn:Line(nLin-5, 1935-105   , nLin-5+100, 1935-105 )	 //
		
		oPrn:Say(nLin,0060,"TOT. PROGRAMADO EM  "  + DTOC(MV_PAR33) + ": ", oFont2)
		
		//**PROGRAMADOS**
		
		// PROTETOR
		oPrn:Say(nLin,0650,Transform(nQCamOut3,"@E 999,999"), oFont2)
		oPrn:Say(nLin,0800,Transform(nCamOut3,"@E 99,999,999.99"), oFontS)
		
		// EDREDON
		oPrn:Say(nLin,1050,Transform(nQCamOut4,"@E 999,999"), oFont2)
		oPrn:Say(nLin,1225,Transform(nCamOut4,"@E 99,999,999.99"), oFontS)
		
		// Cobre leito
		oPrn:Say(nLin,1475,Transform(nQCamOut6,"@E 999,999"), oFont2)
		oPrn:Say(nLin,1600,Transform(nCamOut6,"@E 99,999,999.99"), oFontS)
		
		// CAPA
		oPrn:Say(nLin,1850,Transform(nQCamOut5,"@E 999,999"), oFont2)
		oPrn:Say(nLin,1985,Transform(nCamOut5,"@E 99,999,999.99"), oFontS)
		
		nLin += nEsp
		
		//oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-1100 )
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-600 )
		
		oPrn:Line(nLin-5, 1050-20    , nLin-5+50, 1050-20 )	 //
		oPrn:Line(nLin-5, 1500-50    , nLin-5+50, 1500-50 )	 //
		oPrn:Line(nLin-5, 1935-105   , nLin-5+50, 1935-105 )	 //
		
		oPrn:Say(nLin,0060,"TOTAL PROD. ESTOQUE "  + DTOC(MV_PAR33) + ": ", oFont2)
		
		//PROTETOR
		oPrn:Say(nLin,0650,Transform(nQProtP, "@E 999,999"), oFont2)
		
		//EDREDON
		oPrn:Say(nLin,1050,Transform(nQEdreP, "@E 999,999"), oFont2)
		
		//Cobre leito
		oPrn:Say(nLin,1475,Transform(nQCLeiP, "@E 999,999"), oFont2)
		
		//CAPA
		oPrn:Say(nLin,1850,Transform(nQCapaP, "@E 999,999"), oFont2)
		
		//FABATE()
		nLin += nEsp
		
		//oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-1100 )
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-600 )
		
		oPrn:Line(nLin-5, 1050-20    , nLin-5+50, 1050-20 )	 //
		oPrn:Line(nLin-5, 1500-50    , nLin-5+50, 1500-50 )	 //
		oPrn:Line(nLin-5, 1935-105   , nLin-5+50, 1935-105 )	 //
		
		oPrn:Say(nLin,0060,"TOTAL ABAT. ESTOQUE "  + DTOC(MV_PAR33) + ": ", oFont2)
		
		//PROTETOR
		oPrn:Say(nLin,0650,Transform(nQProtAB, "@E 999,999"), oFont2)
		
		//EDREDON
		oPrn:Say(nLin,1050,Transform(nQEdreAB, "@E 999,999"), oFont2)
		
		//Cobre leito
		oPrn:Say(nLin,1475,Transform(nQEdreAB, "@E 999,999"), oFont2)
		
		//CAPA
		oPrn:Say(nLin,1850,Transform(nQCapaAB, "@E 999,999"), oFont2)
		
		nLin += nEsp
		
		//oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-1100 )
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-600 )
		
		oPrn:Line(nLin-5, 1050-20    , nLin-5+50, 1050-20 )	 //
		oPrn:Line(nLin-5, 1500-50    , nLin-5+50, 1500-50 )	 //
		oPrn:Line(nLin-5, 1935-105   , nLin-5+50, 1935-105 )	 //
		
		oPrn:Say(nLin,0060,"TOTAL PRODUZIDO ............: ", oFont2)
		
		//PROTETOR
		oPrn:Say(nLin,0650,Transform(nQCamOut3 + nQProtP - nQProtAB, "@E 999,999"), oFont2)
		
		//EDREDON
		oPrn:Say(nLin,1050,Transform(nQCamOut4 + nQEdreP - nQEdreAB, "@E 999,999"), oFont2)
		
		//CAPA
		oPrn:Say(nLin,1475,Transform(nQCamOut6 + nQCLeiP - nQEdreAB, "@E 999,999"), oFont2)
		
		
		//CAPA
		oPrn:Say(nLin,1850,Transform(nQCamOut5 + nQCapaP - nQCapaAB, "@E 999,999"), oFont2)
		
		nLin += nEsp
		
		//oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-1100 )
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-600 )
		
		oPrn:Line(nLin-5, 1050-20    , nLin-5+50, 1050-20 )	 //
		oPrn:Line(nLin-5, 1500-50    , nLin-5+50, 1500-50 )	 //
		oPrn:Line(nLin-5, 1935-105   , nLin-5+50, 1935-105 )	 //
		
		
		oPrn:Say(nLin,0060,"ACUMULADO MES ..............: ", oFont2)
		
		// PROTETOR
		oPrn:Say(nLin,0650,Transform(nQProtAC,"@E 999,999"), oFont2)
		oPrn:Say(nLin,0800,Transform(nVProtAC,"@E 99,999,999.99"), oFontS)
		
		// EDREDON
		oPrn:Say(nLin,1050,Transform(nQEdreAC,"@E 999,999"), oFont2)
		oPrn:Say(nLin,1225,Transform(nVEdreAC,"@E 99,999,999.99"), oFontS)
		
		// COBRE LEITO
		oPrn:Say(nLin,1475,Transform(nQcobreAC,"@E 999,999"), oFont2)
		oPrn:Say(nLin,1600,Transform(nVcobreAC,"@E 99,999,999.99"), oFontS)
		
		// CAPA
		oPrn:Say(nLin,1850,Transform(nQCapaAC,"@E 999,999"), oFont2)
		oPrn:Say(nLin,1985,Transform(nVCapaAC,"@E 99,999,999.99"), oFontS)
		
		nLin += nEsp
		
		//oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-1100 )
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-600 )
		
		oPrn:Line(nLin-5, 1050-20    , nLin-5+50, 1050-20 )	 //
		oPrn:Line(nLin-5, 1500-50    , nLin-5+50, 1500-50 )	 //
		oPrn:Line(nLin-5, 1935-105   , nLin-5+50, 1935-105 )	 //
		
		oPrn:Say(nLin,0060,"MEDIA DIA ..................: ", oFont2)
		
		// PROTETOR
		oPrn:Say(nLin,0650,Transform(nQProtAC/nDiasP,"@E 999,999"), oFont2)
		oPrn:Say(nLin,0800,Transform(nVProtAC/nDiasP,"@E 99,999,999.99"), oFontS)
		
		// EDREDON
		oPrn:Say(nLin,1050,Transform(nQEdreAC/nDiasE,"@E 999,999"), oFont2)
		oPrn:Say(nLin,1225,Transform(nVEdreAC/nDiasE,"@E 99,999,999.99"), oFontS)
		
		// Cobre leito
		oPrn:Say(nLin,1475,Transform(nqcobreAC/nDiasCL,"@E 999,999"), oFont2)
		oPrn:Say(nLin,1600,Transform(nVcobreAC/nDiasCL,"@E 99,999,999.99"), oFontS)
		
		// CAPA
		oPrn:Say(nLin,1850,Transform(nQCapaAC/nDiasC,"@E 999,999"), oFont2)
		oPrn:Say(nLin,1985,Transform(nVCapaAC/nDiasC,"@E 99,999,999.99"), oFontS)
		
		nLin += nEsp
		
		//oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-1100 )
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-600 )
		
		oPrn:Line(nLin-5, 1050-20    , nLin-5+50, 1050-20 )	 //
		oPrn:Line(nLin-5, 1500-50    , nLin-5+50, 1500-50 )	 //
		oPrn:Line(nLin-5, 1935-105   , nLin-5+50, 1935-105 )	 //
		
		oPrn:Say(nLin,0060,"DIAS QUE OCORRERAM PROG ....: ", oFont2)
		
		//PROTETOR
		oPrn:Say(nLin,0650,Transform(nDiasP,"@E 999,999"), oFont2)
		
		//EDREDON
		oPrn:Say(nLin,1050,Transform(nDiasE,"@E 999,999"), oFont2)
		
		//Cobre leito
		oPrn:Say(nLin,1475,Transform(nDiasCL,"@E 999,999"), oFont2)
		
		//CAPA
		oPrn:Say(nLin,1850,Transform(nDiasC,"@E 999,999"), oFont2)
		
		nLin += nEsp
		
		//oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-1100 )
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-600 )
		
		oPrn:Line(nLin-5, 1050-20    , nLin-5+50, 1050-20 )	 //
		oPrn:Line(nLin-5, 1500-50    , nLin-5+50, 1500-50 )	 //
		oPrn:Line(nLin-5, 1935-105   , nLin-5+50, 1935-105 )	 //
		
		oPrn:Say(nLin,0060,"CARTEIRA / MEDIA DIA .......: ", oFont2)
		
		//PROTETOR
		oPrn:Say(nLin,0650,Transform(int(iif((nQTDtotE/1400)<0,0,(nQTDtotE/1400))),"@E 999,999"), oFont2)
		
		//EDREDON
		oPrn:Say(nLin,1050,Transform(int(iif((nQTDtotF/200)<0,0,(nQTDtotF/200))),"@E 999,999"), oFont2)
		
		//Cobre leito
		oPrn:Say(nLin,1475,Transform(int(iif((nQTCLeiF/30)<0,0,(nQTCLeiF/30))),"@E 999,999"), oFont2)
		
		//CAPA
		oPrn:Say(nLin,1850,Transform(int(iif((nQTDtotG/10000)<0,0,(nQTDtotG/10000))),"@E 999,999"), oFont2)
		
		nLin += nEsp
		
		//oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-1100 )
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-600 )
		
		oPrn:Line(nLin-5, 1050-20    , nLin-5+50, 1050-20 )	 //
		oPrn:Line(nLin-5, 1500-50    , nLin-5+50, 1500-50 )	 //
		oPrn:Line(nLin-5, 1935-105   , nLin-5+50, 1935-105 )	 //
		
		oPrn:Say(nLin,0060,"ESTOQUE ....................: ", oFont2)
	endif
	FEstoque()
	if !_lRpc
		//  PROTETOR
		oPrn:Say(nLin,0650,Transform(_AEST[1][5], "@E 999,999"), oFont2)
		
		//  EDREDON
		oPrn:Say(nLin,1050,Transform(_AEST[1][6], "@E 999,999"), oFont2)
		
		//  COBRE
		oPrn:Say(nLin,1475,Transform(_AEST[1][9], "@E 999,999"), oFont2)
		
		//  CAPA
		oPrn:Say(nLin,1850,Transform(_AEST[1][7], "@E 999,999"), oFont2)
	endif
Endif

//============================
If mv_par19 = 2
	// Pedidos com Problemas
	fImpPedProb(_aPedProb)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Imprime resumo de produtos³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If mv_par18 = 2
	
	nLin := fImpCab("3", .F., oPrn)
	
	aSort(_aProdT,,,{|x,y| x[1]<y[1]})
	//                            1         2         3         4         5         6         7         8         9        10        11        12        13        14        15        16        17        18        19        20        21        22        23
	//                  01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012
	//	@ nLin,00 Psay "CODIGO         DENOMINACAO                                        MEDIDAS             CARTEIRA   ESTOQUE   RESULTADO   SOLICITADO   NUM. SOLICITACOES DE COMPRA"
	
	For i	:=	1	To	Len(_aProdT)
		If nLin > 2200
			nLin := fImpCab("3", .F., oPrn)
		EndIf
		if !_lRpc
			oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-55 )
			oPrn:Line(nLin-5,  265, nLin-5+50,  265 ) // CODIGO DENOMINACAO
			oPrn:Line(nLin-5,  1100, nLin-5+50,  1100 ) // DENOMINACAO MEDIDAS
			oPrn:Line(nLin-5,  1405, nLin-5+50,  1405 ) // MEDIDAS CARTEIRA
			oPrn:Line(nLin-5,  1600, nLin-5+50,  1600 ) // CARTEIRA ESTQ
			oPrn:Line(nLin-5,  1720, nLin-5+50,  1720 ) // ESTQ RESULT
			oPrn:Line(nLin-5,  1885, nLin-5+50,  1885 ) // RESULT SOLICITADO
			oPrn:Line(nLin-5,  2115, nLin-5+50,  2115 ) //
			
			oPrn:Say(nLin,0060,alltrim( _aProdT[i][1] ), oFont2)
			oPrn:Say(nLin,0275,SUBSTR(alltrim( _aProdT[i][2] ), 1, 39), oFont2)
			oPrn:Say(nLin,1110,alltrim( _aProdT[i][3] ), oFont2)
			oPrn:Say(nLin,1420,TransForm(_aProdT[i][4],"@E 99999"), oFont2)
			
			oPrn:Say(nLin,1610,TransForm(_aProdT[i][5],"@E 99999"), oFont2)
			oPrn:Say(nLin,1750,TransForm(_aProdT[i][5]-_aProdT[i][4],"@E 999999"), oFont2)
		endif
		cQry :=	"select sum(c7_quant-c7_quje) solicit"
		cQry +=	"  from "+retsqlname("SC7")+" "
		cQry +=	" where d_e_l_e_t_ = ' '      "
		cQry +=	"   and c7_filial = '"+xFilial("SC7")+"' "
		cQry +=	"   and c7_produto = '"+_aProdT[i][1]+"'"
		cQry +=	"   and c7_residuo = ' '      "
		cQry +=	"   and c7_quant > c7_quje    "
		If Select("QRY") > 0
			dbSelectArea("QRY")
			dbCloseArea()
		EndIf
		
		TcQuery cQry ALIAS "QRY" NEW
		dbSelectArea("QRY")
		
		While !QRY->(EOF())
			nSolicit := qry->solicit
			dbskip()
		end
		dbSelectArea("QRY")
		dbCloseArea()
		if !_lRpc
			oPrn:Say(nLin,2000,TransForm(nSolicit,"@E 99999"), oFont2)
		endif
		cQry :=	"select c7_num, c7_emissao, c7_datprf  "
		cQry +=	"  from "+retsqlname("SC7")+" "
		cQry +=	" where d_e_l_e_t_ = ' '      "
		cQry +=	"   and c7_filial = '"+xFilial("SC7")+"' "
		cQry +=	"   and c7_produto = '"+_aProdT[i][1]+"'"
		cQry +=	"   and c7_residuo = ' '      "
		cQry +=	"   and c7_quant > c7_quje    "
		If Select("QRY") > 0
			dbSelectArea("QRY")
			dbCloseArea()
		EndIf
		
		TcQuery cQry ALIAS "QRY" NEW
		dbSelectArea("QRY")
		cNumsc := ""
		cDtSol := ""
		cDtEnt := ""
		
		While !QRY->(EOF())
			if ncont = 1    //limite de solicitacoes por linha
				if !_lRpc
					oPrn:Box(nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-55 )
					oPrn:Say(nLin,2150,cNumsc, oFont2)
					// =-=
					oPrn:Say(nLin,2600,cDtSol, oFont2)
					oPrn:Say(nLin,2925,cDtEnt, oFont2)
				endif
				cNumsc	:= ""
				cDtSol  := ""
				cDtEnt  := ""
				ncont 	:= 0
				nLin += nEsp
			endif
			
			cNumsc	+= qry->c7_num
			cDtSol  += SUBSTR(DTOC(STOD(QRY->c7_emissao)),1,5)
			cDtEnt  += SUBSTR(DTOC(STOD(QRY->c7_datprf)),1,5)
			
			QRY->( dbskip() )
			if QRY->( !EOF())
				cNumsc += "" //";"
				cDtSol += "" //";"
				cDtEnt += "" //";"
			Endif
			ncont++
		end
		if !_lRpc
			oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-55 )
			//oPrn:Line(nLin-5,  2115, nLin-5+50,  2115 ) //
			oPrn:Say(nLin,2150,cNumsc, oFont2)
			// =-=
			oPrn:Say(nLin,2600,cDtSol, oFont2)
			oPrn:Say(nLin,2925,cDtEnt, oFont2)
		endif
		nQTotProd += _aProdT[i][4]
		nLin += nEsp
		cNumsc := ""
		nCont  := 0
	Next
	if !_lRpc
		oPrn:Box(nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-55 )
		oPrn:Say(nLin,1100,"Totalizador ==>>", oFont2)
		oPrn:Say(nLin,1420,TransForm(nQTotProd,"@E 999999"), oFont2)
	endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Imprime Produtos em Pedidos em Atraso³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

nCont := 0
If !Empty(_aProdTatr)
	nLin := fImpCab("A",.F.,oPrn)
	aSort(_aProdTatr,,,{|x,y| x[1]<y[1]})
	cProdTatr := _aProdTatr[1][1]
Endif

lImp := .T.

For i	:=	1	To	Len(_aProdTatr)
	
	If nLin > 2200 //.and. x= 1
		nLin := fImpCab("A", .F., oPrn)
	EndIf
	
	If nCont > 9  .AND. lSeglin = .F.
		if !_lRpc
			oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-55 )
			oPrn:Line(nLin-5,  265, nLin-5+50,  265 ) // CODIGO DENOMINACAO
			oPrn:Line(nLin-5,  1100, nLin-5+50,  1100 ) // DENOMINACAO MEDIDAS
			oPrn:Line(nLin-5,  1405, nLin-5+50,  1405 ) // MEDIDAS CARTEIRA
			
			oPrn:Say(nLin,0060,alltrim(cProd), oFont2)
			oPrn:Say(nLin,0275,SUBSTR(alltrim(cDesc), 1, 39), oFont2)
			oPrn:Say(nLin,1110,alltrim(cMed), oFont2)
			oPrn:Say(nLin,1425,alltrim(substr(cPed,1, len(cPed)-2)), oFont2)
		endif
		cPed := ""
		nCont := 0
		nLin += nEsp
		lImp := .F.
		lSeglin := .T.
	Elseif nCont > 9 .AND. lSeglin = .T.
		if !_lRpc
			oPrn:Box(nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-55 )
			oPrn:Say(nLin,1425,alltrim(substr(cPed,1, len(cPed)-2)), oFont2)
		endif
		cPed := ""
		nCont := 0
		nLin += nEsp
		lImp := .F.
		lSeglin := .T.
	Else
		lImp := .T.
	Endif
	If cProdTatr = _aProdTatr[i][1]
		cProd := _aProdTatr[i][1]
		cDesc := _aProdTatr[i][2]
		cMed  := _aProdTatr[i][3]
		cRota := _aProdTatr[i][5]
		cPed  += _aProdTatr[i][4]
		For j	:=	1	To	Len(_aResumo2)
			If alltrim(cRota) = _aResumo2[j][1]
				If cEmpAnt = "06"
					If cRota = "000001"
						if  _aResumo2[j][4] < 350
							cPed += "#"
						endif
					else
						if _aResumo2[j][4] < 850
							cPed += "#"
						endif
					Endif
				endif
			Endif
		next
		
		For j	:=	1	To	Len(_aPedzer)
			If alltrim(cPed) = alltrim(_aPedzer[j][1])
				cPed += "*"
			Endif
		Next
		
		cPed += ", "
		
		nCont++
	Else
		If lImp = .T. .AND. lSeglin = .T. .AND. cPed <> ' '
			
			if !_lRpc
				oPrn:Box(nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-55 )
				oPrn:Say(nLin,1425,alltrim(substr(cPed,1, len(cPed)-2)), oFont2)
			endif
			nLin += nEsp
			
		ELSEIF lImp = .T. .AND. cPed <> ' '
			if !_lRpc
				oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-55 )
				oPrn:Line(nLin-5,  265, nLin-5+50,  265 ) // CODIGO DENOMINACAO
				oPrn:Line(nLin-5,  1100, nLin-5+50,  1100 ) // DENOMINACAO MEDIDAS
				oPrn:Line(nLin-5,  1405, nLin-5+50,  1405 ) // MEDIDAS CARTEIRA
				
				oPrn:Say(nLin,0060,alltrim(cProd), oFont2)
				oPrn:Say(nLin,0275,SUBSTR(alltrim(cDesc), 1, 40), oFont2)
				oPrn:Say(nLin,1110,alltrim(cMed), oFont2)
				oPrn:Say(nLin,1425,alltrim(substr(cPed,1, len(cPed)-2)), oFont2)
			endif
			nLin += nEsp
		Endif
		nCont := 1
		cPed := ""
		cProd := _aProdTatr[i][1]
		cDesc := _aProdTatr[i][2]
		cMed  := _aProdTatr[i][3]
		cPed  += _aProdTatr[i][4]
		cRota := _aProdTatr[i][5]
		
		For j	:=	1	To	Len(_aResumo2)
			If alltrim(cRota) = _aResumo2[j][1]
				If cEmpAnt = "06"
					If cRota = "000001"
						if  _aResumo2[j][4] < 350
							cPed += "#"
						endif
					else
						if _aResumo2[j][4] < 850
							cPed += "#"
						endif
					Endif
				endif
			Endif
		next
		For j	:=	1	To	Len(_aPedzer)
			If alltrim(cPed) = alltrim(_aPedzer[j][1])
				cPed += "*"
			endif
		Next
		cPed += ", "
		lSeglin := .F.
	Endif
	
	lImp := .F.
	cProdTatr := _aProdTatr[i][1]
	
Next

if !_lRpc
	oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-55 )
	oPrn:Line(nLin-5,  265, nLin-5+50,  265 ) // CODIGO DENOMINACAO
	oPrn:Line(nLin-5,  1100, nLin-5+50,  1100 ) // DENOMINACAO MEDIDAS
	oPrn:Line(nLin-5,  1405, nLin-5+50,  1405 ) // MEDIDAS CARTEIRA
	
	oPrn:Say(nLin,0060,alltrim(cProd), oFont2)
	oPrn:Say(nLin,0275,SUBSTR(alltrim(cDesc), 1, 40), oFont2)
	oPrn:Say(nLin,1110,alltrim(cMed), oFont2)
	oPrn:Say(nLin,1425,alltrim(substr(cPed,1, len(cPed)-2)), oFont2)
endif
nLin += nEsp

for i := 1 to len(_aProdTatr)
	_nPT	:=	Ascan(_aPedAt,{|aVal|aVal[1]==Alltrim(_aProdTatr[i][4])})
	IF _nPT = 0
		AADD(_aPedAt,{AllTrim(_aProdTatr[i][4])})
	Endif
next
nLin += nEsp

if !_lRpc
	oPrn:Say(nLin,0750,"Total Pedidos em Atraso ==>>", oFont2)
	oPrn:Say(nLin,1425,TransForm(Len(_aPedAt),"@E 9999"), oFont2)
endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Imprime Segmentos    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If mv_par20 = 2
	
	FVALIDARRAY('1',_aSegmento)
	aSort(_aSegmento,,,{|x,y| x[2]<y[2]})
	
	FVALIDARRAY('1',_aSegmentA)
	aSort(_aSegmentA,,,{|x,y| x[2]<y[2]})
	
	FVALIDARRAY('1',_aSegmentB)
	aSort(_aSegmentB,,,{|x,y| x[2]<y[2]})
	
	FVALIDARRAY('1',_aModelos)  //2
	aSort(_aModelos,,,{|x,y| x[2]<y[2]})
	
	FVALIDARRAY('1',_aModelosA) //2
	aSort(_aModelosA,,,{|x,y| x[2]<y[2]})
	
	FVALIDARRAY('1',_aModelosB) //2
	aSort(_aModelosB,,,{|x,y| x[2]<y[2]})
	
	nLin := fImpCab("5", .F., oPrn)
	
	nTotQTd  := 0
	nTotTotal:= 0
	
	nTotQTDA   := 0
	nTotTotalA := 0
	
	nTotQTDB   := 0
	nTotTotalB := 0
	
	For i	:=	1	To	Len(_aModelos)
		If nLin > 2200
			nLin := fImpCab("5", .F., oPrn)
			nLin += nEsp
			if !_lRpc
				oPrn:Box(nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-55 )
				oPrn:Say(nLin,0060,PADC("POR MODELO DE PRODUTOS",200), oFont2)
				nLin += nEsp
				
				oPrn:Box( nLin-5, 50, nLin-5+100, oPrn:nHorzRes()-55 )
				oPrn:Line(nLin-5,  1240, nLin-5+100, 1240 ) //
				oPrn:Line(nLin-5,  2150, nLin-5+100, 2150 ) //
				
				oPrn:Say(nLin,0550,"SEGMENTOS",oFont2)
				oPrn:Say(nLin,1600,"ATE 15 DD (LIVRE)",oFont2)
				oPrn:Say(nLin,2500,"ENTREGA APOS 15 DIAS",oFont2)
				nLin += nEsp
				
				oPrn:Say(nLin,0150,"GRUPO",oFont2)
				oPrn:Say(nLin,0550,"QUANTIDADE",oFont2)
				oPrn:Say(nLin,1000,"VALOR",oFont2)
				
				oPrn:Say(nLin,1300,"GRUPO",oFont2)
				oPrn:Say(nLin,1650,"QUANTIDADE",oFont2)
				oPrn:Say(nLin,2000,"VALOR",oFont2)
				
				oPrn:Say(nLin,2250,"GRUPO", oFont2)
				oPrn:Say(nLin,2600,"QUANTIDADE", oFont2)
				oPrn:Say(nLin,3000,"VALOR", oFont2)
				nLin += nEsp
			endif
		ELSE
			IF I == 1
				if !_lRpc
					oPrn:Box(nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-55 )
					oPrn:Say(nLin,0060,PADC("POR MODELO DE PRODUTOS",200), oFont2)
					nLin += nEsp
					
					oPrn:Box( nLin-5, 50, nLin-5+100, oPrn:nHorzRes()-55 )
					oPrn:Line(nLin-5,  1240, nLin-5+100, 1240 ) //
					oPrn:Line(nLin-5,  2150, nLin-5+100, 2150 ) //
					
					oPrn:Say(nLin,0550,"SEGMENTOS",oFont2)
					oPrn:Say(nLin,1600,"ATE 15 DD (LIVRE)",oFont2)
					oPrn:Say(nLin,2500,"ENTREGA APOS 15 DIAS",oFont2)
					nLin += nEsp
					
					oPrn:Say(nLin,0150,"GRUPO",oFont2)
					oPrn:Say(nLin,0550,"QUANTIDADE",oFont2)
					oPrn:Say(nLin,1000,"VALOR",oFont2)
					
					oPrn:Say(nLin,1300,"GRUPO",oFont2)
					oPrn:Say(nLin,1650,"QUANTIDADE",oFont2)
					oPrn:Say(nLin,2000,"VALOR",oFont2)
					
					oPrn:Say(nLin,2250,"GRUPO", oFont2)
					oPrn:Say(nLin,2600,"QUANTIDADE", oFont2)
					oPrn:Say(nLin,3000,"VALOR", oFont2)
				endif
				nLin += nEsp
			ENDIF
		EndIf
		
		If _aModelos[i][1] $ "'00002I'|'00008I'|'00003I'|'00004I'|'20009I'|'00007I'|'00011I'|'00001I'|'00005I'|'000007'|20010I"
			if !_lRpc
				oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-55 )
				oPrn:Line(nLin-5,  1240, nLin-5+50, 1240 ) //
				oPrn:Line(nLin-5,  2150, nLin-5+50, 2150 ) //
				
				oPrn:Say(nLin,0100,_aModelos[i][2], oFont2)
				oPrn:Say(nLin,0550,TransForm(round(_aModelos[i][3],2),"@E 9,999,999"), oFont2)
				oPrn:Say(nLin,0975,TransForm(round(_aModelos[i][4],2),"@E 9,999,999.99"), oFont2)
				
				oPrn:Say(nLin,1300,_aModelosA[i][2], oFont2)
				oPrn:Say(nLin,1650,TransForm(round(_aModelosA[i][3],2),"@E 9,999,999"), oFont2)
				oPrn:Say(nLin,1900,TransForm(round(_aModelosA[i][4],2),"@E 9,999,999.99"), oFont2)
				
				oPrn:Say(nLin,2250,_aModelosB[i][2], oFont2)
				oPrn:Say(nLin,2600,TransForm(round(_aModelosB[i][3],2),"@E 9,999,999"), oFont2)
				oPrn:Say(nLin,2900,TransForm(round(_aModelosB[i][4],2),"@E 9,999,999.99"), oFont2)
				nLin += nEsp
			endif
			nTotQTD   += round(_aModelos[i][3],2)
			nTotTotal += round(_aModelos[i][4],2)
			
			nTotQTDA   += round(_aModelosA[i][3],2)
			nTotTotalA += round(_aModelosA[i][4],2)
			
			nTotQTDB   += round(_aModelosB[i][3],2)
			nTotTotalB += round(_aModelosB[i][4],2)
		Endif
	next
	
	nLin += nEsp
	if !_lRpc
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-55 )
		oPrn:Line(nLin-5,  1240, nLin-5+50, 1240 ) //
		oPrn:Line(nLin-5,  2150, nLin-5+50, 2150 ) //
		
		oPrn:Say(nLin,0100,"*** TOTAL *** ", oFont2)
		oPrn:Say(nLin,0550,TransForm(nTOTQTD,"@E 9,999,999"), oFont2)
		oPrn:Say(nLin,0975,TransForm(nTOTTOTAL,"@E 9,999,999.99"), oFont2)
		
		oPrn:Say(nLin,1300,"*** TOTAL *** ", oFont2)
		oPrn:Say(nLin,1650,TransForm(nTOTQTDA,"@E 9,999,999"), oFont2)
		oPrn:Say(nLin,1900,TransForm(nTOTTOTALA,"@E 9,999,999.99"), oFont2)
		
		oPrn:Say(nLin,2250,"*** TOTAL *** ", oFont2)
		oPrn:Say(nLin,2600,TransForm(nTOTQTDB,"@E 9,999,999"), oFont2)
		oPrn:Say(nLin,2900,TransForm(nTOTTOTALB,"@E 9,999,999.99"), oFont2)
	endif
	nLin += nEsp*4
	
	nTotQTd  := 0
	nTotTotal:= 0
	
	nTotQTdA  := 0
	nTotTotalA:= 0
	
	nTotQTdB  := 0
	nTotTotalB:= 0
	
	For i	:=	1	To	Len(_aSegmento)
		If nLin > 2200
			nLin := fImpCab("5", .F., oPrn)
			nLin += nEsp
			if !_lRpc
				oPrn:Box(nLin-5,50,nLin-5+50, oPrn:nHorzRes()-55 )
				oPrn:Say(nLin,0060,PADC("POR GRUPO DE PRODUTOS",200), oFont2)
				nLin += nEsp
				
				oPrn:Box( nLin-5,50,nLin-5+100, oPrn:nHorzRes()-55 )
				oPrn:Line(nLin-5,1240,nLin-5+100, 1240 ) //
				oPrn:Line(nLin-5,2150,nLin-5+100, 2150 ) //
				
				oPrn:Say(nLin,0550,"SEGMENTOS",oFont2)
				oPrn:Say(nLin,1575,"ATE 15 DD (LIVRE)",oFont2)
				oPrn:Say(nLin,2500,"ENTREGA APOS 15 DIAS",oFont2)
				nLin += nEsp
				
				oPrn:Say(nLin,0150,"GRUPO",oFont2)
				oPrn:Say(nLin,0550,"QUANTIDADE",oFont2)
				oPrn:Say(nLin,1000,"VALOR",oFont2)
				
				oPrn:Say(nLin,1300,"GRUPO",oFont2)
				oPrn:Say(nLin,1650,"QUANTIDADE",oFont2)
				oPrn:Say(nLin,2000,"VALOR",oFont2)
				
				oPrn:Say(nLin,2250,"GRUPO", oFont2)
				oPrn:Say(nLin,2600,"QUANTIDADE", oFont2)
				oPrn:Say(nLin,3000,"VALOR", oFont2)
			endif
			nLin += nEsp
		ELSE
			IF I == 1
				if !_lRpc
					oPrn:Box(nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-55)
					oPrn:Say(nLin,0060,PADC("POR GRUPO DE PRODUTOS",200), oFont2)
					nLin += nEsp
					
					oPrn:Box(nLin-5, 50, nLin-5+100, oPrn:nHorzRes()-55)
					oPrn:Line(nLin-5,  1240, nLin-5+100, 1240 ) //
					oPrn:Line(nLin-5,  2150, nLin-5+100, 2150 ) //
					
					oPrn:Say(nLin,0550,"SEGMENTOS",oFont2)
					oPrn:Say(nLin,1575,"ATE 15 DD (LIVRE)",oFont2)
					oPrn:Say(nLin,2500,"ENTREGA APOS 15 DIAS",oFont2)
					nLin += nEsp
					
					oPrn:Say(nLin,0150,"GRUPO",oFont2)
					oPrn:Say(nLin,0550,"QUANTIDADE",oFont2)
					oPrn:Say(nLin,1000,"VALOR",oFont2)
					
					oPrn:Say(nLin,1300,"GRUPO",oFont2)
					oPrn:Say(nLin,1650,"QUANTIDADE",oFont2)
					oPrn:Say(nLin,2000,"VALOR",oFont2)
					
					oPrn:Say(nLin,2250,"GRUPO", oFont2)
					oPrn:Say(nLin,2600,"QUANTIDADE", oFont2)
					oPrn:Say(nLin,3000,"VALOR", oFont2)
					nLin += nEsp
				endif
			ENDIF
		EndIf
		
		If _aSegmento[i][1] $ "'00011I'|'00004I'|'00008I'|'00005I'|'00003I'|'00001I'|'00007I'|'00002I'|10007O|20010I"
			if !_lRpc
				oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-55 )
				oPrn:Line(nLin-5,  1240, nLin-5+50, 1240 ) //
				oPrn:Line(nLin-5,  2150, nLin-5+50, 2150 ) //
				
				oPrn:Say(nLin,0100,_aSegmento[i][2], oFont2)
				oPrn:Say(nLin,0550,TransForm(round(_aSegmento[i][3],2),"@E 9,999,999"), oFont2)
				oPrn:Say(nLin,0975,TransForm(round(_aSegmento[i][4],2),"@E 9,999,999.99"), oFont2)
				
				oPrn:Say(nLin,1300,_aSegmentA[i][2], oFont2)
				oPrn:Say(nLin,1650,TransForm(round(_aSegmentA[i][3],2),"@E 9,999,999"), oFont2)
				oPrn:Say(nLin,1900,TransForm(round(_aSegmento[i][4],2),"@E 9,999,999.99"), oFont2)
				
				oPrn:Say(nLin,2250,_aSegmentB[i][2], oFont2)
				oPrn:Say(nLin,2600,TransForm(round(_aSegmentB[i][3],2),"@E 9,999,999"), oFont2)
				oPrn:Say(nLin,2900,TransForm(round(_aSegmentB[i][4],2),"@E 9,999,999.99"), oFont2)
			endif
			nTotQTD   += round(_aSegmento[i][3],2)
			nTotTotal += round(_aSegmento[i][4],2)
			
			nTotQTDA   += round(_aSegmentA[i][3],2)
			nTotTotalA += round(_aSegmentA[i][4],2)
			
			nTotQTDB   += round(_aSegmentB[i][3],2)
			nTotTotalB += round(_aSegmentB[i][4],2)
			
			nLin += nEsp
		ENDIF
	Next
	if !_lRpc
		nLin += nEsp
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-55 )
		oPrn:Line(nLin-5,  1240, nLin-5+50, 1240 ) //
		oPrn:Line(nLin-5,  2150, nLin-5+50, 2150 ) //
		
		oPrn:Say(nLin,0100,"*** TOTAL *** ", oFont2)
		oPrn:Say(nLin,0550,TransForm(nTOTQTD,"@E 9,999,999"), oFont2)
		oPrn:Say(nLin,0975,TransForm(nTOTTOTAL,"@E 9,999,999.99"), oFont2)
		
		oPrn:Say(nLin,1300,"*** TOTAL *** ", oFont2)
		oPrn:Say(nLin,1650,TransForm(nTOTQTDA,"@E 9,999,999"), oFont2)
		oPrn:Say(nLin,1900,TransForm(nTOTTOTALA,"@E 9,999,999.99"), oFont2)
		
		oPrn:Say(nLin,2250,"*** TOTAL *** ", oFont2)
		oPrn:Say(nLin,2600,TransForm(nTOTQTDB,"@E 9,999,999"), oFont2)
		oPrn:Say(nLin,2900,TransForm(nTOTTOTALB,"@E 9,999,999.99"), oFont2)
		nLin += nEsp
	endif
Endif


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
//³Imprime RESUMO DE CARTEIRA POR PERIODO³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
If _cRpc == "S" .and. _cNRot == "ORTPMPRG" .and. _cInfRet == "CARTGER"
	_nTotTotal := nCart30d+nCart3060d+nCartM60d
//	Return _nTotTotal
Endif

nLin := fImpCab("6", .F., oPrn)
if !_lRpc
oPrn:Box(nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-1600)
oPrn:Say(nLin,0060,"CARTEIRA PARA OS PROXIMOS 30 DIAS       :  ==>> " + Transform(nCart30d,"@E 99,999,999.99"), oFont2)
nLin += nEsp

oPrn:Box(nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-1600)
oPrn:Say(nLin,0060,"CARTEIRA ENTRE OS PROXIMOS 31 : 60 DIAS :  ==>> " + Transform(nCart3060d,"@E 99,999,999.99"), oFont2)
nLin += nEsp

oPrn:Box(nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-1600)
oPrn:Say(nLin,0060,"CARTEIRA APOS OS PROXIMOS 60 DIAS       :  ==>> " + Transform(nCartM60d,"@E 99,999,999.99"), oFont2)
nLin += nEsp*2
endif

aRentTot[1]:= (aRent30[1]+aRent30[2]+aRent30[3]+aRent30[4])/(aRentSeg30[1]+aRentSeg30[2]+aRentSeg30[3]+aRentSeg30[4])//(aRent30[1]/aRentSeg30[1])+(aRent30[2]/aRentSeg30[2])+(aRent30[3]/aRentSeg30[3])+(aRent30[4]/aRentSeg30[4])
aRentTot[2]:= (aRent3060[1]+aRent3060[2]+aRent3060[3]+aRent3060[4])/(aRtSeg3060[1]+aRtSeg3060[2]+aRtSeg3060[3]+aRtSeg3060[4])//(aRent3060[1]/aRentSeg3060[1])+(aRent3060[2]/aRentSeg3060[2])+(aRent3060[3]/aRentSeg3060[3])+(aRent3060[4]/aRentSeg3060[4])
aRentTot[3]:= (aRent60[1]+aRent60[2]+aRent60[3]+aRent60[4])/(aRentSeg60[1]+aRentSeg60[2]+aRentSeg60[3]+aRentSeg60[4])//(aRent60[1]/aRentSeg60[1])+(aRent60[2]/aRentSeg60[2])+(aRent60[3]/aRentSeg60[3])+(aRent60[4]/aRentSeg60[4])

if !_lRpc
oPrn:Box(nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-1600)
oPrn:Say(nLin,0060,"RENTABILIDADE", oFont2)
nLin += nEsp

oPrn:Box( nLin-5,0050,nLin-5+50,oPrn:nHorzRes()-1600)
oPrn:Line(nLin-5,0270,nLin-5+50,0270) // comercial
oPrn:Line(nLin-5,0590,nLin-5+50,0590) // industrual
oPrn:Line(nLin-5,0890,nLin-5+50,0890) // loja
oPrn:Line(nLin-5,1190,nLin-5+50,1190) // terceiros
oPrn:Line(nLin-5,1490,nLin-5+50,1490) // total

oPrn:Say(nLin,0275,"COMERCIAL", oFont2)
oPrn:Say(nLin,0595,"INDUSTRIAL", oFont2)
oPrn:Say(nLin,0895,"LOJA", oFont2)
oPrn:Say(nLin,1195,"TERCEIR.", oFont2)
oPrn:Say(nLin,1495,"TOTAL", oFont2)
nLin += nEsp

oPrn:Box( nLin-5,0050,nLin-5+50,oPrn:nHorzRes()-1600)
oPrn:Line(nLin-5,0270,nLin-5+50,0270) // comercial
oPrn:Line(nLin-5,0590,nLin-5+50,0590) // industrual
oPrn:Line(nLin-5,0890,nLin-5+50,0890) // loja
oPrn:Line(nLin-5,1190,nLin-5+50,1190) // terceiros
oPrn:Line(nLin-5,1490,nLin-5+50,1490) // total

oPrn:Say(nLin,0060,"30 DIAS", oFont2)
oPrn:Say(nLin,0320,Transform(aRent30[1]/aRentSeg30[1], "@E 99,999,999.99"), oFont2) //comercial
oPrn:Say(nLin,0620,Transform(aRent30[2]/aRentSeg30[2], "@E 99,999,999.99"), oFont2) //industrial
oPrn:Say(nLin,0920,Transform(aRent30[3]/aRentSeg30[3], "@E 99,999,999.99"), oFont2) //loja
oPrn:Say(nLin,1220,Transform(aRent30[4]/aRentSeg30[4], "@E 99,999,999.99"), oFont2) //terceiros
oPrn:Say(nLin,1520,Transform(aRentTot[1], "@E 99,999,999.99"), oFont2)              //total
nLin += nEsp

oPrn:Box( nLin-5,0050,nLin-5+50,oPrn:nHorzRes()-1600)
oPrn:Line(nLin-5,0270,nLin-5+50,0270) // comercial
oPrn:Line(nLin-5,0590,nLin-5+50,0590) // industrual
oPrn:Line(nLin-5,0890,nLin-5+50,0890) // loja
oPrn:Line(nLin-5,1190,nLin-5+50,1190) // terceiros
oPrn:Line(nLin-5,1490,nLin-5+50,1490) // total

oPrn:Say(nLin,0060,"30/60 DIAS", oFont2)
oPrn:Say(nLin,0320,Transform(aRent3060[1]/aRtSeg3060[1], "@E 99,999,999.99"), oFont2)
oPrn:Say(nLin,0620,Transform(aRent3060[2]/aRtSeg3060[2], "@E 99,999,999.99"), oFont2)
oPrn:Say(nLin,0920,Transform(aRent3060[3]/aRtSeg3060[3], "@E 99,999,999.99"), oFont2)
oPrn:Say(nLin,1220,Transform(aRent3060[4]/aRtSeg3060[4], "@E 99,999,999.99"), oFont2)
oPrn:Say(nLin,1520,Transform(aRentTot[2], "@E 99,999,999.99"), oFont2)

nLin += nEsp

oPrn:Box( nLin-5,0050,nLin-5+50,oPrn:nHorzRes()-1600)
oPrn:Line(nLin-5,0270,nLin-5+50,0270) // comercial
oPrn:Line(nLin-5,0590,nLin-5+50,0590) // industrual
oPrn:Line(nLin-5,0890,nLin-5+50,0890) // loja
oPrn:Line(nLin-5,1190,nLin-5+50,1190) // terceiros
oPrn:Line(nLin-5,1490,nLin-5+50,1490) // total

oPrn:Say(nLin,0060,"60 DIAS", oFont2)
oPrn:Say(nLin,0320,Transform(aRent60[1]/aRentSeg60[1], "@E 99,999,999.99"), oFont2)
oPrn:Say(nLin,0620,Transform(aRent60[2]/aRentSeg60[2], "@E 99,999,999.99"), oFont2)
oPrn:Say(nLin,0920,Transform(aRent60[3]/aRentSeg60[3], "@E 99,999,999.99"), oFont2)
oPrn:Say(nLin,1220,Transform(aRent60[4]/aRentSeg60[4], "@E 99,999,999.99"), oFont2)
oPrn:Say(nLin,1520,Transform(aRentTot[3], "@E 99,999,999.99"), oFont2)

nLin += nEsp

oPrn:Box( nLin-5,0050,nLin-5+50,oPrn:nHorzRes()-1600)
oPrn:Line(nLin-5,0270,nLin-5+50,0270) // comercial
oPrn:Line(nLin-5,0590,nLin-5+50,0590) // industrual
oPrn:Line(nLin-5,0890,nLin-5+50,0890) // loja
oPrn:Line(nLin-5,1190,nLin-5+50,1190) // terceiros
oPrn:Line(nLin-5,1490,nLin-5+50,1490) // total

oPrn:Say(nLin,0060,"TOT.GERAL", oFont2)
oPrn:Say(nLin,0320,Transform((aRent30[1]+aRent3060[1]+aRent60[1])/(aRentSeg30[1]+aRtSeg3060[1]+aRentSeg60[1]), "@E 99,999,999.99"), oFont2)
oPrn:Say(nLin,0620,Transform((aRent30[2]+aRent3060[2]+aRent60[2])/(aRentSeg30[2]+aRtSeg3060[2]+aRentSeg60[2]), "@E 99,999,999.99"), oFont2)
oPrn:Say(nLin,0920,Transform((aRent30[3]+aRent3060[3]+aRent60[3])/(aRentSeg30[3]+aRtSeg3060[3]+aRentSeg60[3]), "@E 99,999,999.99"), oFont2)
oPrn:Say(nLin,1220,Transform((aRent30[4]+aRent3060[4]+aRent60[4])/(aRentSeg30[4]+aRtSeg3060[4]+aRentSeg60[4]), "@E 99,999,999.99"), oFont2)
oPrn:Say(nLin,1520,Transform(aRentTot[1]+aRentTot[2]+aRentTot[3], "@E 99,999,999.99"), oFont2)


// RESUMO DOS 10 MAIORES CLIENTES

nLin := fImpCab("7", .F., oPrn)

oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-1460)
oPrn:Line(nLin-5,  0470, nLin-5+50, 0470 ) //
oPrn:Line(nLin-5,  0885, nLin-5+50, 0885 ) //
oPrn:Line(nLin-5,  1250, nLin-5+50, 1250 ) //
oPrn:Line(nLin-5,  1550, nLin-5+50, 1550 ) //

oPrn:Say(nLin,0060,"CLIENTE", oFont2)
oPrn:Say(nLin,0500,"CNPJ", oFont2)
oPrn:Say(nLin,1050,"SEGMENTO", oFont2)
oPrn:Say(nLin,1400,"ESPAÇOS", oFont2)
oPrn:Say(nLin,1810,"VALOR", oFont2)
nLin += nEsp
endif

nTotal:=0
if len(aCliente) > 10
	nMax:=10
else
	nMax:=len(aCliente)
endif

//
// CONTINUAR
//
for i:=1 to nMax
	if !_lRpc
	oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-1460)
	oPrn:Line(nLin-5,  0470, nLin-5+50, 0470 ) //
	oPrn:Line(nLin-5,  0885, nLin-5+50, 0885 ) //
	oPrn:Line(nLin-5,  1250, nLin-5+50, 1250 ) //
	oPrn:Line(nLin-5,  1550, nLin-5+50, 1550 ) //
	
//	oPrn:Say(nLin,0060,substr(Posicione("SA1",1,xFilial("SA1")+aCliente[i][1],"SA1->A1_NOME"),1,19), oFont2)
	oPrn:Say(nLin,0060,substr(aCliente[i][6],1,19), oFont2)
	
	if len(aCliente[i][2])>13
		oPrn:Say(nLin,0500,Transform(Alltrim(aCliente[i][2]),"@R 99.999.999/9999-99"), oFont2)
	else
		oPrn:Say(nLin,0500,Transform(Alltrim(aCliente[i][2]),"@R 999.999.999-99"), oFont2)
	endif
	
	oPrn:Say(nLin,1175,Transform(alltrim(aCliente[i][3]),"@E 99"), oFont2) // segmento
	oPrn:Say(nLin,1325,Transform(aCliente[i][4],"@E 999,999,999"), oFont2) // espaços
	oPrn:Say(nLin,1635,Transform(aCliente[i][5],"@E 99,999,999,999"), oFont2) //valor
	ENDIF
	nTotal+=aCliente[i][5]
	nLin += nEsp
next
if !_lRpc
oPrn:Box(nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-1460)
oPrn:Say(nLin,0060," *** TOTAL *** ", oFont2)
oPrn:Say(nLin,1635,Transform(nTotal,"@E 99,999,999,999"), oFont2)

nLin += nEsp*2

oPrn:Say(nLin,0060,"LEGENDA SEGMENTOS:", oFont2)
nLin += nEsp
oPrn:Say(nLin,0060,"1 - INDUSTRIAL | 2 - COMERCIAL  |  3 - LOJAS  |  4 - LOJAS EXCLUSIVAS  |  5 - ORTOCLASS INDUSTRIAL  |  6 - ORTOCLASS COMERCIAL", oFont2)
ENDIF

DbSelectArea("TSC5")
TSC5->( DbCloseArea() )

//SSI-124131 - Vagner Almeida - 09/09/2021 - Inicio
	If Len( aLinha ) > 0 .and. mv_par42 == 2
		GeraCSV( aLinha )
	EndIf
//SSI-124131 - Vagner Almeida - 09/09/2021 - Final

MS_FLUSH()

Return


*------------------------------*
Static Function BuscStat(xOper)
*------------------------------*
If xOper = "01" .Or. xOper = "12" .Or. xOper = "13"
	cOper := "N" // VENDA
ElseIf xOper = "02" .or.  xOper = "03" .Or. xOper = "17"
	cOper := "T" // TROCA
ElseIf xOper = "05"
	cOper := "B" // BRINDE
ElseIf xOper = "07"
	cOper := "D" // DEMONSTR.
ElseIf xOper = "08"
	cOper := "R" // REPOSICAO
ElseIf xOper = "09"
	cOper := "C" // CONSERTO
ElseIf xOper = "22"
	cOper := "Q" // VENDA DE INSUMOS
Else
	cOper := xOper
EndIf
Return(cOper)

*-------------------------*
Static Function ValidPerg()
*-------------------------*
Local aAreaAtu := GetArea()
Local aRegs    := {}
Local i,j

Aadd(aRegs,{cPerg,"01","Cliente de                    ","","","MV_CH1","C",6,0,0,"G","","mv_par01","","","","","","","","","","","","","","",""  ,"","","","","","","","","","SA1",""})
Aadd(aRegs,{cPerg,"02","Loja de                       ","","","MV_CH2","C",2,0,0,"G","","mv_par02","","","","","","","","","","","","","","",""  ,"","","","","","","","","","",""})
Aadd(aRegs,{cPerg,"03","Cliente até                   ","","","MV_CH3","C",6,0,0,"G","","mv_par03","","","","","","","","","","","","","","",""  ,"","","","","","","","","","SA1",""})
Aadd(aRegs,{cPerg,"04","Loja até                      ","","","MV_CH4","C",2,0,0,"G","","mv_par04","","","","","","","","","","","","","","",""  ,"","","","","","","","","","",""})
Aadd(aRegs,{cPerg,"05","Tipo de Cliente               ","","","MV_CH5","N",1,0,0,"C","","mv_par05","Industrial","","","","","Comercial","","","","","Loja","","","","","Loja Especializada","","","","","Geral","","","","",""})
Aadd(aRegs,{cPerg,"06","Tabela De                     ","","","MV_CH6","C",3,0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aRegs,{cPerg,"07","Tabela Ate                    ","","","MV_CH7","C",3,0,0,"G","","mv_par07","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aRegs,{cPerg,"08","Vendedor de                   ","","","MV_CH8","C",6,0,0,"G","","MV_PAR08","","","","","","","","","","","","","","","","","","","","","","","","","SA3",""})
Aadd(aRegs,{cPerg,"09","Vendedor até                  ","","","MV_CH9","C",6,0,0,"G","","MV_PAR09","","","","","","","","","","","","","","","","","","","","","","","","","SA3",""})
aAdd(aRegs,{cPerg,"10","Listar Pedidos de Terceiros   ","","","MV_CHA","N",1,0,0,"C","","MV_PAR10","Nao","","","","","Sim","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"11","Somente Pedidos em Atraso     ","","","MV_CHB","N",1,0,0,"C","","MV_PAR11","Nao","","","","","Sim","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"12","Somente Pedidos de Terceiros  ","","","MV_CHC","N",1,0,0,"C","","MV_PAR12","Nao","","","","","Sim","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"13","Listar Produtos               ","","","MV_CHD","N",1,0,0,"C","","MV_PAR13","Nao","","","","","Sim","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"14","(Trocas) Ordenado por         ","","","MV_CHE","N",1,0,0,"C","","MV_PAR14","Cliente","","","","","Bairro","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"15","Somente Ped.c/ Data de Entrega","","","MV_CHF","N",1,0,0,"C","","MV_PAR15","Nao","","","","","Sim","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"16","Status do Pedido              ","","","MV_CHG","N",1,0,0,"C","","MV_PAR16","Geral","","","","","Liberados","","","","","Não Liberados","","","","","Quarentena","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"17","Em Lojas                      ","","","MV_CHH","N",1,0,0,"C","","MV_PAR17","Geral","","","","","Só Lojas ","","","","","Sem Lojas","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"18","Listar Res.Produtos           ","","","MV_CHI","N",1,0,0,"C","","MV_PAR18","Nao","","","","","Sim","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"19","Listar Rel.Prob.Cadastrais    ","","","MV_CHJ","N",1,0,0,"C","","MV_PAR19","Nao","","","","","Sim","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"20","Listar por segmento  		  ","","","MV_CHL","N",1,0,0,"C","","MV_PAR20","Nao","","","","","Sim","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"21","Ordena por vendedores         ","","","MV_CHM","N",1,0,0,"C","","MV_PAR21","Nao","","","","","Sim","","","","","","","","","","","","","","","","","","","",""})
Aadd(aRegs,{cPerg,"22","Lista por Zona  	          ","","","MV_CHN","N",1,0,0,"C","","MV_PAR22","Nao","","","","","Sim","","","","","","","","","","","","","","","","","","","",""})
Aadd(aRegs,{cPerg,"23","Data Futura a Partir  	      ","","","MV_CHO","D",8,0,0,"G","","MV_PAR23","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aRegs,{cPerg,"24","Dias em Atraso     	          ","","","MV_CHP","C",2,0,0,"G","","MV_PAR24","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aRegs,{cPerg,"25","Listar Pedidos de Troca       ","","","MV_CHQ","N",1,0,0,"C","","MV_PAR25","Nao","","","","","Sim","","","","","","","","","","","","","","","","","","","",""})
Aadd(aRegs,{cPerg,"26","Listar Pedidos Normais        ","","","MV_CHR","N",1,0,0,"C","","MV_PAR26","Nao","","","","","Sim","","","","","","","","","","","","","","","","","","","",""})
Aadd(aRegs,{cPerg,"27","Listar Pedidos de Quimico     ","","","MV_CHS","N",1,0,0,"C","","MV_PAR27","Nao","","","","","Sim","","","","","","","","","","","","","","","","","","","",""})
Aadd(aRegs,{cPerg,"28","Listar Pedidos de Demostracao ","","","MV_CHT","N",1,0,0,"C","","MV_PAR28","Nao","","","","","Sim","","","","","","","","","","","","","","","","","","","",""})
Aadd(aRegs,{cPerg,"29","Listar Pedidos de Reposicao   ","","","MV_CHU","N",1,0,0,"C","","MV_PAR29","Nao","","","","","Sim","","","","","","","","","","","","","","","","","","","",""})
Aadd(aRegs,{cPerg,"30","Listar Pedidos de Bonificacao ","","","MV_CHV","N",1,0,0,"C","","MV_PAR30","Nao","","","","","Sim","","","","","","","","","","","","","","","","","","","",""})
Aadd(aRegs,{cPerg,"31","Listar Pedidos de Conserto    ","","","MV_CHX","N",1,0,0,"C","","MV_PAR31","Nao","","","","","Sim","","","","","","","","","","","","","","","","","","","",""})
Aadd(aRegs,{cPerg,"32","Listar Outros                 ","","","MV_CHY","N",1,0,0,"C","","MV_PAR32","Nao","","","","","Sim","","","","","","","","","","","","","","","","","","","",""})
Aadd(aRegs,{cPerg,"33","Data de Programacao  	      ","","","MV_CHZ","D",8,0,0,"G","","MV_PAR33","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aRegs,{cPerg,"34","Exibir MIX e KG?    	      ","","","MV_CAB","N",1,0,0,"C","","MV_PAR34","Nao","","","","","Sim","","","","","","","","","","","","","","","","","","","",""})
//If cEmpant = '24'		//SSI-105463 - Vagner Almeida - 18/12/2020 
	Aadd(aRegs,{cPerg,"35","Posição da Carteira       ","","","MV_CAC","N",1,0,0,"C","","MV_PAR35","Geral","","","","","Sem Gerar OP","","","","","OP Gerada","","","","","OP Finalizada","","","","","","","","","",""})
//Endif					//SSI-105463 - Vagner Almeida - 18/12/2020 

//SSI-105463 - Vagner Almeida - 18/12/2020 - Início
Aadd(aRegs,{cPerg,"36","Gerente                       ","","","MV_CAD","C",6,0,0,"G","","MV_PAR36","","","","","","","","","","","","","","","","","","","","","","","","","SA3",""})
Aadd(aRegs,{cPerg,"37","Agrupa Clientes 			  ","","","MV_CAE","N",1,0,0,"C","","MV_PAR37","Nao","","","","","Sim","","","","","","","","","","","","","","","","","","","",""})
Aadd(aRegs,{cPerg,"38","Tipo de Bloqueio              ","","","mv_CAF","N",1,0,0,"C","","MV_PAR38","Nenhuma opção","","","","","Cobranca","","","","","Comercial","","","","","Cobr e Come","","","","","","","","","",""})
Aadd(aRegs,{cPerg,"39","Listar Outras Unidades        ","","","mv_CAG","N",1,0,0,"C","","MV_PAR39","Nenhum","","","","","Origem","","","","","Destino","","","","","","","","","","","","","","",""})
Aadd(aRegs,{cPerg,"40","Filtrar por Bairro            ","","","mv_CAH","C",10,0,0,"G","","mv_par40","","","","","","","","","","","","","","",""  ,"","","","","","","","","","",""})
Aadd(aRegs,{cPerg,"41","Remessa por conta e ordem     ","","","MV_CAI","N",1,0,0,"C","","MV_PAR41","Nao","","","","","Sim","","","","","Somente","","","","","","","","","","","","","","",""})
//SSI-105463 - Vagner Almeida - 18/12/2020 - Final
//SSI-124131 - Vagner Almeida - 09/09/2020 - Final
Aadd(aRegs,{cPerg,"42","Gera Arquivo CSV?             ","","","MV_CAJ","N",1,0,0,"C","","MV_PAR42","Nao","","","","","Sim","","","","","","","","","","","","","","","","","","","",""})
//SSI-124131 - Vagner Almeida - 09/09/2020 - Final
//SSI-123499 - Vagner Almeida - 16/09/2021 - Inicio
Aadd(aRegs,{cPerg,"43","Desconto SIMBAHIA?		      ","","","MV_CAK","N",1,0,0,"C","","MV_PAR43","Nao","","","","","Sim","","","","","","","","","","","","","","","","","","","",""})
//SSI-123499 - Vagner Almeida - 16/09/2021 - Final

//Cria 8Pergunta
cPerg := U_AjustaSx1(cPerg,aRegs)

RestArea( aAreaAtu )

Return(.T.)


*---------------------------------*
Static Function fImpCab(cTp, lPrimeira, oPrn)
*---------------------------------*

nPag	+= 1
nCol	:= 0
cCol 	:= Space(0)
nEsp	:= 50
if !_lRpc
If !lPrimeira
	oPrn:EndPage()
EndIf
oPrn:StartPage()

//oPrn:Box ( [ nRow], [ nCol], [ nBottom], [ nRight] )
oPrn:Box( 50, 50, 200, oPrn:nHorzRes()-55 )
oPrn:Box( 49, 49, 199, oPrn:nHorzRes()-54 )

// Lado Esquerdo
oPrn:Say ( 085, 95, "Hora: " + cHora + " - (" + nomeprog + ")"     , oFontM)
oPrn:Say ( 125, 95, "Empresa: " + cEmpAnt + " / Filial: " + cNomFil, oFontM)

// Centro
oPrn:Say ( 110 , 1200, Upper(titulo), oFontM)

// Lado Direito
nTam := oPrn:GetTextWidth ( "Emissão:" + Dtos(Date()), oFontM ) + 115
oPrn:Say ( 085, oPrn:nHorzRes()-nTam, "Folha: " + AllTrim(Str(nPag)), oFontM)
oPrn:Say ( 125, oPrn:nHorzRes()-nTam, "Emissão:" + DtoC(Date()), oFontM)

nLin	:= 210

If nVez = 1
	oPrn:Say ( nLin, 060, cDesc1  , oFont2)
	nLin += nEsp
	nVez++
EndIf

If MV_PAR16 = 1
	oPrn:Say ( nLin, 060, "Status dos Pedidos : GERAL " , oFont2)
Elseif MV_PAR16 = 2
	oPrn:Say ( nLin, 060, "Status dos Pedidos : LIBERADOS " , oFont2)
Elseif MV_PAR16 = 3
	oPrn:Say ( nLin, 060, "Status dos Pedidos : NAO LIBERADOS " , oFont2)
Elseif MV_PAR16 = 3
	oPrn:Say ( nLin, 060, "Status dos Pedidos : QUARENTENA " , oFont2)
Endif

If MV_PAR13 = 1  //NAO
	oPrn:Say ( nLin, 060, Space(037) + "Lista Produtos : NAO "     , oFont2)
ELSE
	oPrn:Say ( nLin, 060, Space(037) + "Lista Produtos : SIM "     , oFont2)
ENDIF

IF MV_PAR10 = 1
	oPrn:Say ( nLin, 060, Space(065) + "Lista Pedidos Terc. : NAO" , oFont2)
ELSE
	oPrn:Say ( nLin, 060, Space(065) + "Lista Pedidos Terc. : SIM" , oFont2)
ENDIF

IF MV_PAR05 = 1
	oPrn:Say ( nLin, 060, Space(098) + "Tipo de Cliente : Industrial", oFont2)
ELSEIF MV_PAR05 = 2
	oPrn:Say ( nLin, 060, Space(098) + "Tipo de Cliente : Comercial", oFont2)
ELSEIF MV_PAR05 = 3
	oPrn:Say ( nLin, 060, Space(098) + "Tipo de Cliente : Loja", oFont2)
ELSEIF MV_PAR05 = 4
	oPrn:Say ( nLin, 060, Space(098) + "Tipo de Cliente : Loja Especializada", oFont2)
ELSEIF MV_PAR05 = 5
	oPrn:Say ( nLin, 060, Space(098) + "Tipo de Cliente : Geral", oFont2)
ENDIF

IF MV_PAR11 = 1
	oPrn:Say ( nLin, 060, Space(132) + "Somente Pedidos em Atraso :  NAO "	, oFont2)
Else
	oPrn:Say ( nLin, 060, Space(132) + "Somente Pedidos em Atraso :  SIM "	, oFont2)
Endif

nLin += nEsp

oPrn:Say ( nLin, 060, Space(000) + "Vendedor de : " + MV_PAR08 + " ate " + MV_PAR09	, oFont2)
oPrn:Say ( nLin, 060, Space(045) + "Cliente  de : " + MV_PAR01 + " ate " + MV_PAR03, oFont2)
oPrn:Say ( nLin, 060, Space(090) + "Tabela de : " + MV_PAR06 + " ate " + MV_PAR07		, oFont2)

//SSI-123499 - Vagner Almeida - 20/09/2021 - Inicio
If cEmpAnt == '24' .And. MV_PAR43 == 1
	oPrn:Say ( nLin, 060, Space(132) + "Desconto SIMBAHIA : NAO", oFont2)
Else
	oPrn:Say ( nLin, 060, Space(132) + "Desconto SIMBAHIA : SIM", oFont2)
EndIf		
//SSI-123499 - Vagner Almeida - 20/09/2021 - Inicio

nLin += nEsp

If cTp = "2"
	oPrn:Say(nLin,0060,"RESUMO DOS PEDIDOS COM PROBLEMAS CADASTRAIS", oFont2)
	nLin += nEsp
ElseIf cTp = "3"
	oPrn:Say(nLin,0060,"RESUMO DOS PRODUTOS", oFont2)
	nLin += nEsp
ElseIf cTp = "A"
	oPrn:Say(nLin,0060,"RESUMO DOS PRODUTOS COM PEDIDOS EM ATRASO", oFont2)
	nLin += nEsp
Endif

nLin += nEsp

oPrn:Line(nLin  , 50, nLin  , oPrn:nHorzRes()-50 )
oPrn:Line(nLin+2, 50, nLin+2, oPrn:nHorzRes()-50 )
oPrn:Line(nLin+4, 50, nLin+4, oPrn:nHorzRes()-50 )

nLin += nEsp

If cTp = "1"
	oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-55 )
	
	oPrn:Line(nLin-5,  145, nLin-5+50,  145 ) // INDICE COMPRA
	oPrn:Line(nLin-5,  210+100, nLin-5+50,  210+100 ) // COMPRA PEDIDO
	oPrn:Line(nLin-5,  200+90+80+100, nLin-5+50,  200+90+80+100 ) // PEDIDO LIB
	oPrn:Line(nLin-5,  290+90+70+100, nLin-5+50,  290+90+70+100 ) // LIB CD/CM
	oPrn:Line(nLin-5,  450+90+75+100, nLin-5+50,  450+90+75+100 ) // CD/CM EMISSAO
	oPrn:Line(nLin-5,  630+90+75+100, nLin-5+50,  630+90+75+100 ) // EMISSAO LIBERACAO
	oPrn:Line(nLin-5,  830+90+75+100, nLin-5+50,  830+90+75+100 ) // LIBERACAO REVALID
	oPrn:Line(nLin-5, 1010+90+75+100, nLin-5+50, 1010+90+75+100 ) // REVALID DIAS
	oPrn:Line(nLin-5, 1113+90+70+100, nLin-5+50, 1113+90+70+100 ) // DIAS ENTREGA
	oPrn:Line(nLin-5, 1510+90+35+100, nLin-5+50, 1510+90+35+100 ) // ENTREGA TP
	oPrn:Line(nLin-5, 1575+90+35+100, nLin-5+50, 1575+90+35+100 ) // TP SEG
	oPrn:Line(nLin-5, 1650+90+30+100, nLin-5+50, 1650+90+30+100 ) // SEG VEND
	oPrn:Line(nLin-5, 1974+80+100-20, nLin-5+50, 1974+80+100-20 ) // VEND CLIENTE
	oPrn:Line(nLin-5, 2265+90+100-60, nLin-5+50, 2265+90+100-60 ) // CLIENTE VLR
	oPrn:Line(nLin-5, 2465+90+100-60, nLin-5+50, 2465+90+100-60 ) // VLR ZONA
	oPrn:Line(nLin-5, 2912+40-45-60, nLin-5+50, 2912+40-45-60 ) // ZONA CIDADE ULT.CARG
	oPrn:Line(nLin-5, 3090+40-45-60, nLin-5+50, 3090+40-45-60 ) // ULT.CARG ESPACOS
	oPrn:Line(nLin-5, 3248+25-45-60, nLin-5+50, 3248+25-45-60 ) // ESPACOS ROT
	oPrn:Line(nLin-5, 3330+25-45-60, nLin-5+50, 3330+25-45-60 ) // ROT TAB
	
	//	oPrn:Say ( nLin   , 60,"NUM. PCOMPRA PEDIDO  LIB CD/CM   EMISSAO  LIBERACAO REVALID  DIAS ENTREGA           TP SEG VEND         CLIENTE      VLR       ZONA CIDADE  ULT.CARG SPACOS ROT TAB", oFont2)
	oPrn:Say(nLin,0060,"NUM.", oFont2)
	oPrn:Say(nLin,0150,"PCOMPR", oFont2)
	oPrn:Say(nLin,0325,"PEDIDO", oFont2)
	oPrn:Say(nLin,0475,"LIB", oFont2)
	IF MV_PAR34 == 1
		oPrn:Say(nLin,0550,"CD/CM ", oFont2)
	Else
		oPrn:Say(nLin,0550,"    MIX", oFont2)
	EndIf
	//oPrn:Say(nLin,0550,"CD/CM ", oFont2)
	oPrn:Say(nLin,0725,"EMISSAO", oFont2)
	oPrn:Say(nLin,0910,"LIBERACAO", oFont2)
	oPrn:Say(nLin,1100,"REVALID", oFont2)
	oPrn:Say(nLin,1285,"DIAS", oFont2)
	oPrn:Say(nLin,1400,"ENTREGA", oFont2)
	oPrn:Say(nLin,1750,"TP", oFont2)
	oPrn:Say(nLin,1800,"SEG", oFont2)
	oPrn:Say(nLin,1885,"VEND", oFont2)
	oPrn:Say(nLin,2150,"CLIENTE", oFont2)
	oPrn:Say(nLin,2410,"VLR", oFont2)
	oPrn:Say(nLin,2600,"ZONA CIDADE", oFont2)
	oPrn:Say(nLin,2850,"ULT.CARG", oFont2)
	IF MV_PAR34 == 1
		oPrn:Say(nLin,3025,"ESPACOS", oFont2)
	Else
		oPrn:Say(nLin,3025,"    KG", oFont2)
	EndIf
	oPrn:Say(nLin,3175,"ROT", oFont2)
	oPrn:Say(nLin,3275,"TAB", oFont2)
	
ElseIf cTp = "2"
	
	oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-55 )
	oPrn:Line(nLin-5,  200, nLin-5+50,  200 ) // PEDIDO LIB
	
	//	oPrn:Say ( nLin   , 60,"PEDIDO   PROBLEMAS NO SISTEMA DE CADASTRO", oFont2)
	oPrn:Say(nLin,0060,"PEDIDO", oFont2)
	oPrn:Say(nLin,0225,"PROBLEMAS NO SISTEMA DE CADASTRO", oFont2)
	
ElseIf cTp = "3"
	
	oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-55 )
	oPrn:Line(nLin-5,  265, nLin-5+50,  265 ) // CODIGO DENOMINACAO
	oPrn:Line(nLin-5,  1100, nLin-5+50,  1100 ) // DENOMINACAO MEDIDAS
	oPrn:Line(nLin-5,  1405, nLin-5+50,  1405 ) // MEDIDAS CARTEIRA
	oPrn:Line(nLin-5,  1600, nLin-5+50,  1600 ) // CARTEIRA ESTQ
	oPrn:Line(nLin-5,  1720, nLin-5+50,  1720 ) // ESTQ RESULT
	oPrn:Line(nLin-5,  1885, nLin-5+50,  1885 ) // RESULT SOLICITADO
	oPrn:Line(nLin-5,  2115, nLin-5+50,  2115 ) //
	
	//	oPrn:Say ( nLin   , 60,"CODIGO     DENOMINACAO                               MEDIDAS        CARTEIRA  ESTQ  RESULT  SOLICITADO  NUM SOLICITAÇÕES DE COMPRA", oFont2)
	oPrn:Say(nLin,0060,"CODIGO",oFont2)
	oPrn:Say(nLin,0275,"DENOMINACAO",oFont2)
	oPrn:Say(nLin,1110,"MEDIDAS",oFont2)
	oPrn:Say(nLin,1420,"CARTEIRA",oFont2)
	oPrn:Say(nLin,1610,"ESTQ",oFont2)
	oPrn:Say(nLin,1725,"RESULT",oFont2)
	oPrn:Say(nLin,1900,"SOLICITADO",oFont2)
	oPrn:Say(nLin,2150,"SOLICITAÇÕES DE COMPRA",oFont2)
	oPrn:Say(nLin,2600,"DT.SOLICITACAO",oFont2)
	oPrn:Say(nLin,2925,"DT.PREV.ENTREGA",oFont2)
	
ElseIf cTp = "V"
	
	oPrn:Box( nLin-5,0050,nLin-5+50,1370)
	oPrn:Line(nLin-5,0270,nLin-5+50,0270)
	oPrn:Line(nLin-5,0710,nLin-5+50,0710)
	oPrn:Line(nLin-5,1040,nLin-5+50,1040)
	
	oPrn:Say(nLin,0060,"VENDEDOR"  ,oFont2)
	oPrn:Say(nLin,0456,"NOME"	   ,oFont2)
	oPrn:Say(nLin,0810,"ESPACOS"   ,oFont2)
	oPrn:Say(nLin,1155,"VALOR"     ,oFont2)
	
	oPrn:Say(nLin,2370,"ACOES"     ,oFont2)
	oPrn:Line(nLin-5+40,2360,nLin-5+40,2480)
	
	oPrn:Line(2200-nEsp,0350,2200-nEsp,0950)
	oPrn:Say(2200-nEsp,0450,"SECRETÁRIO COMERCIAL",oFont2)
	
	oPrn:Line(2200-nEsp,1400,2200-nEsp,2000)
	oPrn:Say(2200-nEsp,1530,"GERENTE COMERCIAL",oFont2)
	
	oPrn:Line(2200-nEsp,2500,2200-nEsp,3100)
	oPrn:Say(2200-nEsp,2650,"GERENTE GERAL",oFont2)
	
ElseIf cTp = "4"
	
	oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-2200 )
	oPrn:Line(nLin-5,  270, nLin-5+50,  270 ) //
	oPrn:Line(nLin-5,  460, nLin-5+50,  460 ) //
	oPrn:Line(nLin-5,  850, nLin-5+50,  850 ) //
	
	oPrn:Say(nLin,0060,"ZONA  VEND",oFont2)
	oPrn:Say(nLin,0300,"ITIN."     ,oFont2)
	oPrn:Say(nLin,0575,"ESPACOS"   ,oFont2)
	oPrn:Say(nLin,0975,"VALOR"     ,oFont2)
	
ElseIf cTp = "5"
	
	oPrn:Box(nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-55 )
	oPrn:Say(nLin,0060,"SEGMENTOS", oFont2)
ElseIf cTp = "P"
	
	oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-55 )
	oPrn:Line(nLin-5,  145, nLin-5+50,  145 ) // INDICE PEDIDO
	oPrn:Line(nLin-5,  200+100, nLin-5+50,  200+100 ) // PEDIDO LIB
	
	oPrn:Say(nLin,0060,"NUM.",oFont2)
	oPrn:Say(nLin,0150,"PEDIDO",oFont2)
	oPrn:Say(nLin,0350,"PRODUTOS",oFont2)
	
ElseIf cTp = "7"
	
	oPrn:Box(nLin-5,50, nLin-5+50, oPrn:nHorzRes()-55 )
	oPrn:Say(nLin,0060,"                                  10 Maiores Clientes                                  ", oFont2)
	
ElseIf cTp = "8"
	
	oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-55 )
	oPrn:Line(nLin-5,  310, nLin-5+50,  265 ) // PEDIDO LIB
	
	oPrn:Say ( nLin   , 60,"ZONA DE ENTREGA        ESPACOS          VALOR", oFont2)
	
Elseif cTp = "9"
	IF CEMPANT$"22"
		
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-55 )
		oPrn:Line(nLin-5, 1280-50, nLin-5+50, 1280-50 ) //
		oPrn:Line(nLin-5, 2445-110-5, nLin-5+50, 2445-110-5 ) //
		
		oPrn:Say(nLin,0600,"MANTA", oFont2)
		oPrn:Say(nLin,1650,"TRAVESSEIRO", oFont2)
		oPrn:Say(nLin,2700,"CAMARIA", oFont2)
		nLin += nEsp
		
		oPrn:Box( nLin-5, 50, nLin-5+190, oPrn:nHorzRes()-55 )
		
		oPrn:Line(nLin-5, 0210-20, nLin-5+190, 0210-20 ) // ZN.ENT ESPAÇOS
		oPrn:Line(nLin-5, 0405-15, nLin-5+140, 0405-15 ) // ESPAÇOS QTDE
		oPrn:Line(nLin-5, 0615-25, nLin-5+140, 0615-25 ) // QTDE VALOR
		oPrn:Line(nLin-5, 0850-40, nLin-5+190, 0850-40 ) // VALOR ESPACOS
		oPrn:Line(nLin-5, 1050-40, nLin-5+140, 1050-40 ) // ESPACOS VALOR
		oPrn:Line(nLin-5+140, 0210-20, nLin-5+140, 0850-40 )
		oPrn:Line(nLin-5+140, 0850-40, nLin-5+140, 1280-50 )
		
		oPrn:Line(nLin-5, 1280-50, nLin-5+190, 1280-50 ) // VALOR ESPAÇOS
		oPrn:Line(nLin-5, 1500-70, nLin-5+140, 1500-70 ) // ESPAÇOS QTDE
		oPrn:Line(nLin-5, 1735-85, nLin-5+140, 1735-85 ) // QTDE VALOR
		oPrn:Line(nLin-5, 1975-85, nLin-5+190, 1975-85 ) // VALOR ESPACOS
		oPrn:Line(nLin-5, 2190-110,nLin-5+140,2190-110 ) // ESPACOS VALOR
		oPrn:Line(nLin-5+140, 1280-50, nLin-5+140, 1945-85 )
		oPrn:Line(nLin-5+140, 1945-85, nLin-5+140, 2445-110-5 )
		
		oPrn:Line(nLin-5, 2445-110-5, nLin-5+190, 2445-110-5 ) // VALOR ESPAÇOS
		oPrn:Line(nLin-5, 2645-60-64, nLin-5+140, 2645-60-64 ) // ESPAÇOS QTD
		oPrn:Line(nLin-5, 2870-60-80, nLin-5+140, 2870-60-70-10 ) // QTD VALOR
		oPrn:Line(nLin-5, 3120-60-60, nLin-5+190, 3120-60-60 ) // VALOR ESPAÇOS
		oPrn:Line(nLin-5, 3330-60-75, nLin-5+140, 3330-60-70-5 ) // ESPAÇOS VALOR
		
		oPrn:Line(nLin-5+140, 2445-115, nLin-5+140, 3050-120 )
		oPrn:Line(nLin-5+140, 3050-120, nLin-5+140, oPrn:nHorzRes()-55 )
		
		oPrn:Say(nLin       ,0060,"ZN.ENT" ,oFont2)
		
		//MANTA
		oPrn:Say(nLin       ,0200,"ESPAÇOS",oFont2)
		oPrn:Say(nLin+nEsp  ,0200,"ENTREGA",oFont2)
		oPrn:Say(nLin+nEsp*2,0200,"LIVRE"  ,oFont2)
		
		oPrn:Say(nLin       ,0400,"QTD"    ,oFont2)
		oPrn:Say(nLin+nEsp  ,0400,"FISICA" ,oFont2)
		oPrn:Say(nLin+nEsp*2,0400,"LIVRE"  ,oFont2)
		
		oPrn:Say(nLin       ,0600,"VALOR"  ,oFont2)
		oPrn:Say(nLin+nEsp  ,0600,"ENTREGA",oFont2)
		oPrn:Say(nLin+nEsp*2,0600,"LIVRE"  ,oFont2)
		
		oPrn:Say(nLin       ,0825,"ESPAÇOS",oFont2)
		oPrn:Say(nLin+nEsp  ,0825,"ENTREGA",oFont2)
		oPrn:Say(nLin+nEsp*2,0825,"FUTURA" ,oFont2)
		
		oPrn:Say(nLin       ,1025,"VALOR"  ,oFont2)
		oPrn:Say(nLin+nEsp  ,1025,"ENTREGA",oFont2)
		oPrn:Say(nLin+nEsp*2,1025,"FUTURA" ,oFont2)
		
		oPrn:Say(nLin+nEsp*3,0400,"(< 15 DD)", oFont2)
		oPrn:Say(nLin+nEsp*3,0950,"(> 15 DD)", oFont2)
		
		
		//TRAVESSEIRO
		oPrn:Say(nLin       ,1245,"ESPAÇOS",oFont2)
		oPrn:Say(nLin+nEsp  ,1245,"ENTREGA",oFont2)
		oPrn:Say(nLin+nEsp*2,1245,"LIVRE"  ,oFont2)
		
		oPrn:Say(nLin       ,1445,"QTD"    ,oFont2)
		oPrn:Say(nLin+nEsp  ,1445,"FISICA" ,oFont2)
		oPrn:Say(nLin+nEsp*2,1445,"LIVRE"  ,oFont2)
		
		oPrn:Say(nLin       ,1660,"VALOR"  ,oFont2)
		oPrn:Say(nLin+nEsp  ,1660,"ENTREGA",oFont2)
		oPrn:Say(nLin+nEsp*2,1660,"LIVRE"  ,oFont2)
		
		oPrn:Say(nLin       ,1910,"ESPAÇOS",oFont2)
		oPrn:Say(nLin+nEsp  ,1910,"ENTREGA",oFont2)
		oPrn:Say(nLin+nEsp*2,1910,"FUTURA" ,oFont2)
		
		oPrn:Say(nLin       ,2090,"VALOR"  ,oFont2)
		oPrn:Say(nLin+nEsp  ,2090,"ENTREGA",oFont2)
		oPrn:Say(nLin+nEsp*2,2090,"FUTURA" ,oFont2)
		
		oPrn:Say(nLin+nEsp*3,1450,"(< 15 DD)", oFont2)
		oPrn:Say(nLin+nEsp*3,2005,"(> 15 DD)", oFont2)
		
		
		//		CAMARIA
		oPrn:Say(nLin       ,2340,"ESPAÇOS",oFont2)
		oPrn:Say(nLin+nEsp  ,2340,"ENTREGA",oFont2)
		oPrn:Say(nLin+nEsp*2,2340,"LIVRE"  ,oFont2)
		
		oPrn:Say(nLin       ,2540,"QTD"    ,oFont2)
		oPrn:Say(nLin+nEsp  ,2540,"FISICA" ,oFont2)
		oPrn:Say(nLin+nEsp*2,2540,"LIVRE"  ,oFont2)
		
		oPrn:Say(nLin       ,2740,"VALOR"  ,oFont2)
		oPrn:Say(nLin+nEsp  ,2740,"ENTREGA",oFont2)
		oPrn:Say(nLin+nEsp*2,2740,"LIVRE"  ,oFont2)
		
		oPrn:Say(nLin       ,3005,"ESPAÇOS",oFont2)
		oPrn:Say(nLin+nEsp  ,3005,"ENTREGA",oFont2)
		oPrn:Say(nLin+nEsp*2,3005,"FUTURA" ,oFont2)
		
		oPrn:Say(nLin       ,3205,"VALOR"  ,oFont2)
		oPrn:Say(nLin+nEsp  ,3205,"ENTREGA",oFont2)
		oPrn:Say(nLin+nEsp*2,3205,"FUTURA" ,oFont2)
		
		oPrn:Say(nLin+nEsp*3,2585,"(< 15 DD)", oFont2)
		oPrn:Say(nLin+nEsp*3,3120,"(> 15 DD)", oFont2)
		
		/*
		
		oPrn:Say ( nLin   , 60,"                                                           ESPAÇOS   QTD       VALOR      ESPAÇOS   VALOR      ESPAÇOS   QTD       VALOR      ESPAÇOS   VALOR  ", oFont2)
		nLin += nEsp-10
		oPrn:Say ( nLin   , 60,"                                                           ENTREGA   FISICA    ENTREGA    ENTREGA   ENTREGA    ENTREGA   FISICA    ENTREGA    ENTREGA   ENTREGA", oFont2)
		nLin += nEsp-10
		oPrn:Say ( nLin   , 60,"                                                           LIVRE     LIVRE     LIVRE      FUTURA    FUTURA     LIVRE     LIVRE     LIVRE      FUTURA    FUTURA ", oFont2)
		nLin += nEsp-10
		oPrn:Say ( nLin   , 60,"                                                              (  < 15 DD  )                   ( > 15 DD )         ( < 15 DD  )                  (  > 15 DD  ) ", oFont2)
		*/
		//oPrn:Say ( nLin   , 60,"ZZZZZZ|99,000.00|99,000.00|999,000.00|99,000.00|999,000.00|99,000.00|99,000.00|999,000.00|99,000.00|999,000.00|99,000.00|99,000.00|999,000.00|99,000.00|999,999.99", oFont2)
		
	ELSE
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-2225 )
		oPrn:Say(nLin,0250,PADC("S A C O    P L A S T I C O",60),oFont2)
		nLin += nEsp
		
		oPrn:Box( nLin-5, 50, nLin-5+220-30, oPrn:nHorzRes()-2225 )
		oPrn:Line(nLin-5, 0210-20, nLin-5+190, 0210-20 ) // ZN.ENT ESPAÇOS
		oPrn:Line(nLin-5, 0405-15, nLin-5+140, 0405-15 ) // ESPAÇOS QTDE
		oPrn:Line(nLin-5, 0615-25, nLin-5+140, 0615-25 ) // QTDE VALOR
		oPrn:Line(nLin-5, 0850-40, nLin-5+190, 0850-40 ) // VALOR ESPACOS
		oPrn:Line(nLin-5, 1050-40, nLin-5+140, 1050-40 ) // ESPACOS VALOR
		oPrn:Line(nLin-5+140, 0210-20, nLin-5+140, 0850-40 )
		oPrn:Line(nLin-5+140, 0850-40, nLin-5+140, oPrn:nHorzRes()-2225 )
		
		oPrn:Say(nLin       ,0060,"ZN.ENT" ,oFont2)
		
		oPrn:Say(nLin       ,0200,"ESPAÇOS",oFont2)
		oPrn:Say(nLin+nEsp  ,0200,"ENTREGA",oFont2)
		oPrn:Say(nLin+nEsp*2,0200,"LIVRE"  ,oFont2)
		
		oPrn:Say(nLin       ,0400,"QTD"    ,oFont2)
		oPrn:Say(nLin+nEsp  ,0400,"FISICA" ,oFont2)
		oPrn:Say(nLin+nEsp*2,0400,"LIVRE"  ,oFont2)
		
		oPrn:Say(nLin       ,0600,"VALOR"  ,oFont2)
		oPrn:Say(nLin+nEsp  ,0600,"ENTREGA",oFont2)
		oPrn:Say(nLin+nEsp*2,0600,"LIVRE"  ,oFont2)
		
		oPrn:Say(nLin       ,0825,"ESPAÇOS",oFont2)
		oPrn:Say(nLin+nEsp  ,0825,"ENTREGA",oFont2)
		oPrn:Say(nLin+nEsp*2,0825,"FUTURA" ,oFont2)
		
		oPrn:Say(nLin       ,1025,"VALOR"  ,oFont2)
		oPrn:Say(nLin+nEsp  ,1025,"ENTREGA",oFont2)
		oPrn:Say(nLin+nEsp*2,1025,"FUTURA" ,oFont2)
		
		oPrn:Say(nLin+nEsp*3,0400,"(< 15 DD)", oFont2)
		oPrn:Say(nLin+nEsp*3,0950,"(> 15 DD)", oFont2)
		
		lImpLcab:=.F.
	ENDIF
	nLin += nEsp*4
	
ElseIf cTp = "A"
	
	oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:nHorzRes()-55 )
	oPrn:Line(nLin-5,  265, nLin-5+50,  265 ) // CODIGO DENOMINACAO
	oPrn:Line(nLin-5,  1100, nLin-5+50,  1100 ) // DENOMINACAO MEDIDAS
	oPrn:Line(nLin-5,  1405, nLin-5+50,  1405 ) // MEDIDAS CARTEIRA
	
	oPrn:Say(nLin,0060,"CODIGO",oFont2)
	oPrn:Say(nLin,0275,"DENOMINACAO",oFont2)
	oPrn:Say(nLin,1110,"MEDIDAS",oFont2)
	oPrn:Say(nLin,1425,"PEDIDOS",oFont2)
Endif
ENDIF
nLin += nEsp
//lImpLcab:=.T.
x := 0

Return(nLin)


Static Function fImpPedProb(_aPedProb)
nLin := fImpCab("2", .F., oPrn)

For y:=1 To Len(_aPedProb)
	
	If nLin > 2300 //.and. x = 1
		nLin := fImpCab("2", .F., oPrn)
	Endif
	
	cTexto := "CLIENTE COM : " + ALLTRIM(STRZERO(_aPedProb[y][1],3)) + " Lucros E Perdas" +; // Qtd de Luc e Perdas
	SPACE(3)+";  Qtd CH sem Fundos-Prop: " + ALLTRIM(STRZERO(_aPedProb[y][2],3)) +; // Qtd de Cheques sem fundos - proprios
	SPACE(3)+";  Qtd CH sem Fundos-Terc: " + ALLTRIM(STRZERO(_aPedProb[y][3],3)) +;  // Qtd de Cheques sem fundos - Terceiros
	SPACE(3)+";  Qtd Prorrogacao: "  + ALLTRIM(STRZERO(_aPedProb[y][4],3))  //Qtd de Prorrogação
	cTexto2 := "Qtd Duplicatas Venc-Prop: " + ALLTRIM(STRZERO(_aPedProb[y][5],3)) +; // Qtd de Duplicatas vencidas - proprios
	SPACE(3)+";  Qtd Pendencia: " + ALLTRIM(STRZERO(_aPedProb[y][6],3)) +; // Qtd de Pendencias
	SPACE(3)+";  Qtd Promissoria: " +ALLTRIM(STRZERO(_aPedProb[y][7],3)) // Qtd de Promissorias
	if !_lRpc
	oPrn:Box( nLin-5, 50, nLin-5+100, oPrn:nHorzRes()-55 )
	oPrn:Line(nLin-5,  200, nLin-5+100,  200 ) // PEDIDO L
	
	oPrn:Say(nLin,0060,_aPedProb[y][8], oFont2)
	oPrn:Say(nLin,0225,cTexto, oFont2)
	
	nLin += nEsp
	
	oPrn:Say(nLin,0225,cTexto2, oFont2)
	nLin += nEsp
	Endif
next

Return



STATIC FUNCTION FNAOFAT()
************************
local cQry := ""
local nTot := 0

cQry := "SELECT NVL(SUM(C6_VALOR), 0) TOT"
cQry += "  FROM "+RETSQLNAME("SC5")+ " SC5 , "+RETSQLNAME("SC6")+ " SC6 , "+RETSQLNAME("SZQ")+ " SZQ"
cQry += " WHERE C5_NUM = C6_NUM"
cQry += "   AND C5_XEMBARQ = ZQ_EMBARQ"
cQry += "   AND SC5.D_E_L_E_T_ = ' '"
cQry += "   AND SC6.D_E_L_E_T_ = ' '"
cQry += "   AND SZQ.D_E_L_E_T_ = ' '"
cQry += "   AND C5_FILIAL = '"+xFilial("SC5")+"'"
cQry += "   AND C6_FILIAL = '"+xFilial("SC6")+"'"
cQry += "   AND ZQ_FILIAL = '"+xFilial("SZQ")+"'"
cQry += "   AND C5_NOTA = ' '"
cQry += "   AND ZQ_DTPREVE >= '"+DTOS(DaySub( dDatabase , 7 ))+"'"
cQry += "   AND C5_XOPER NOT IN ('13', '20', '21', '96', '99')   "


memowrit("c:\ORTR077nf.sql",cQry)
IF select("QRY") > 0
	DBSELECTAREA("QRY")
	DBCLOSEAREA()
ENDIF

TcQuery cQry Alias "QRY" New
DBSELECTAREA("QRY")


NTOT := QRY->TOT

DBSELECTAREA("QRY")
DBCLOSEAREA()

RETURN NTOT

*************************
STATIC FUNCTION TOTSUBGRU()
*************************

cQuery:=" SELECT sum(CASE                                                                       "
cQuery+="         WHEN C5_XTPSEGM = '3' AND C5_XOPER <> '07' AND C5_XOPER <> '08' THEN   "
cQuery+="          (((C6_XPRUNIT - ((C6_XGUELTA + C6_XRESSAR) * C6_XPRUNIT / 100))) * "
cQuery+="              C6_QTDVEN)                               "
cQuery+="         ELSE                                          "
cQuery+="          (CASE                                     "
cQuery+="         WHEN C5_XOPER = '07' OR C5_XOPER = '08' THEN "
cQuery+="          C6_PRCVEN * C6_QTDVEN  "
cQuery+="         ELSE                    "
cQuery+="          C6_XPRUNIT * C6_QTDVEN "
cQuery+="       END) "
cQuery+="       END) AS TOTPED, "
cQuery += "  SBM.BM_XSUBGRU   "
cQuery += " FROM " + RetSQLName("SC6") + " SC6, "
cQuery += RetSQLName("SB1") + " SB1, "
cQuery += RetSQLName("SA1") + " SA1, "
cQuery += RetSQLName("SA1") + " SA1E, "
cQuery += RetSQLName("SA3") + " SA3, "
cQuery += RetSQLName("SC5") + " SC5, "
cQuery += RetSQLName("SZH") + " SZH, "
cQuery += RetSQLName("SBM") + " SBM,  CARTEIRA"+cEmpAnt+"0 "
cQuery += " WHERE B1_GRUPO = BM_GRUPO    "
cQuery += " AND SC5.R_E_C_N_O_ = REC     "
cQuery += " AND SA3.A3_COD(+) = C5_VEND1    "
cQuery += " AND SC5.C5_NUM = C6_NUM      "
cQuery += " AND C5_CLIENTE = C6_CLI      "
cQuery += " AND C5_LOJACLI = C6_LOJA     "
cQuery += " AND B1_COD = C6_PRODUTO      "
cQuery += " AND ZH_CLIENTE (+)= C5_CLIENTE  "
cQuery += " AND ZH_LOJA  (+)= C5_LOJACLI    "
cQuery += " AND ZH_VEND  (+)= C5_VEND1      "
cQuery += " AND ZH_SEGMENT(+)= C5_XTPSEGM   "
cQuery += " AND SA1.A1_COD = C5_CLIENTE     "
cQuery += " AND SA1E.A1_COD (+)= C5_XCLITRO "
cQuery += " AND SA1.A1_LOJA = C5_LOJACLI     "
cQuery += " AND SA1E.A1_LOJA (+)= C5_XLOJATR "
cQuery += " AND C5_XEMBARQ = ' '"
cQuery += " AND C6_NOTA = ' '   "
cQuery += " AND C5_XACERTO	=	' '      " /**********/

//SSI-105463 - Vagner Almeida - 18/12/2020 - Início

//cQuery += " AND C5_XOPER NOT IN ('13','20','21','99') "  //Não lista pedidos "Não repor" e "Cancelados"

If MV_PAR39 == 2 // Origem (DE)
	cQuery += " AND C5_XOPER NOT IN ('20','21','96','99') "  	//Não lista pedidos "Não repor" e "Cancelados"
Else
	cQuery += " AND C5_XOPER NOT IN ('13','20','21','96','99') "	//Não lista pedidos "Não repor" e "Cancelados"
Endif

//cQuery += " AND C5_CLIENTE between '" + MV_PAR01 + "' and '" + MV_PAR03 + "'"
//cQuery += " AND C5_LOJACLI between '" + MV_PAR02 + "' and '" + MV_PAR04 + "'"
IF MV_PAR37 == 1
	cQuery += " AND C5_CLIENTE between '" + MV_PAR01 + "' and '" + MV_PAR03 + "'"
	cQuery += " AND C5_LOJACLI between '" + MV_PAR02 + "' and '" + MV_PAR04 + "'"
ELSE
	cQuery += " AND C5_CLIENTE IN	(SELECT A1_COD "
	cQuery += "							 FROM SIGA."+RetSQLName("SA1")+" SA11 "
	cQuery += "							 WHERE A1_XCODGRU IN (SELECT A1_XCODGRU "
	cQuery += "													FROM SIGA."+RetSQLName("SA1")+" SA12 "
	cQuery += "												   WHERE A1_COD between '" + MV_PAR01 + "' and '" + MV_PAR03 + "'))"
Endif

If !Empty(MV_PAR40)
	cQuery += " AND UPPER(SA1.A1_BAIRRO) = ('" + UPPER(MV_PAR40) + "') "
EndIf

//SSI-105463 - Vagner Almeida - 18/12/2020 - Final

cQuery += " AND C5_TABELA BETWEEN '" + MV_PAR06 + "' AND '" + MV_PAR07 + "'"
cQuery += " AND C5_VEND1 between '" + MV_PAR08 + "' and '" + MV_PAR09 + "'"
If MV_PAR05 <> 5
	cQuery += " AND C5_XTPSEGM = '" + STRZERO(MV_PAR05,1) + "'"
Endif
If MV_PAR10 = 1
	cQuery += " AND B1_COD NOT LIKE '407095%' "                       // NAO LISTA TERCEIROS
Else
	If MV_PAR12 = 2
		cQuery += " AND B1_COD LIKE '407095%' "                      // LISTA SOMENTE TERCEIROS SE O PARAMETRO 9 FOR IGUAL A 2 (SIM)
	Endif
Endif

IF MV_PAR25 = 2 .OR. MV_PAR26 = 2 .OR. MV_PAR27 = 2 .OR. MV_PAR28 = 2 .OR. MV_PAR29 = 2 .OR. MV_PAR30 = 2 .OR. MV_PAR31 = 2
	cOpr := "("
	If MV_PAR25 = 2
		cOpr += "'02','03','17',"                 // TROCAS
	Endif
	If MV_PAR26 = 2
		cOpr += "'01','12','13',"                 // NORMAL
	Endif
	If MV_PAR27 = 2
		cOpr += "'22',"                           // QUIMICO
	Endif
	If MV_PAR28 = 2
		cOpr += "'07',"                           // DEMOSTRACAO
	Endif
	If MV_PAR29 = 2
		cOpr += "'08',"                           // REPOSICAO
	Endif
	If MV_PAR30 = 2
		cOpr += "'05',"                           // BONIFICACAO
	Endif
	If MV_PAR31 = 2
		cOpr += "'09',"                           // CONSERTO
	Endif
	
	cOpr := SUBSTR(cOpr,1,LEN(COPR)-1)
	cQuery += "AND C5_XOPER IN "+cOpr+")"
	
Else
	cOpr += "('01','12','13',"                 // NORMAL
	cOpr := SUBSTR(cOpr,1,LEN(COPR)-1)
ENDIF


If MV_PAR15 = 2
	cQuery += " AND C5_XENTREF <> ' ' "                           // C/DATA ENTREGA
Endif

If mv_par16 = 2
	cQuery += " AND C5_XDTLIB <> ' '  AND C5_XQUAREN != '1'  "                            // LIBERADOS
ElseIf mv_par16 = 3
	cQuery += " AND C5_XDTLIB = ' '  AND C5_XQUAREN != '1'  "                             // NAO LIBERADOS
ElseIf mv_par16 = 4
	cQuery += " AND C5_XQUAREN = '1' "                            // QUARENTENA
Endif
/*If mv_par16 = 2
	cQuery += " AND C5_XDTLIB <> ' ' "                            // LIBERADOS
ElseIf mv_par16 = 3
	cQuery += " AND C5_XDTLIB = ' ' "                             // NAO LIBERADOS
Endif*/

If mv_par17 = 2
	cQuery += " AND C5_XTPSEGM = '3' "					 // Só Lojas
ElseIf mv_par17 = 3
	cQuery += " AND C5_XTPSEGM <> '3' "                    // Sem Lojas
EndIf

cQuery += " AND SC6.D_E_L_E_T_ = ' ' "
cQuery += " AND SB1.D_E_L_E_T_ = ' ' "
cQuery += " AND SA1.D_E_L_E_T_ = ' ' "
cQuery += " AND SA1E.D_E_L_E_T_ (+)= ' ' "
cQuery += " AND SA3.D_E_L_E_T_(+) = ' ' "
cQuery += " AND SC5.D_E_L_E_T_ = ' ' "
cQuery += " AND SZH.D_E_L_E_T_ (+)= ' ' "
cQuery += " AND SBM.D_E_L_E_T_ = ' ' "
cQuery += " AND C6_FILIAL = '" + xFilial("SC6") + "'"
cQuery += " AND B1_FILIAL = '" + xFilial("SB1") + "'"
cQuery += " AND SA1.A1_FILIAL = '" + xFilial("SA1") + "'"
cQuery += " AND SA1E.A1_FILIAL (+)= '" + xFilial("SA1") + "'"
cQuery += " AND A3_FILIAL(+) = '" + xFilial("SA3") + "'"
cQuery += " AND C5_FILIAL = '" + xFilial("SC5") + "'"
cQuery += " AND ZH_FILIAL (+)= '" + xFilial("SZH") + "'"
cQuery += " AND BM_FILIAL = '" + xFilial("SBM") + "'"
cQuery += " GROUP BY BM_XSUBGRU "
cQuery += " ORDER BY BM_XSUBGRU "

memowrit("c:\4umo_subgru.sql",cQuery)
//TcQuery cQuery Alias "TQRY" New


RETURN



static function fEspaco()
***********************
Local cQry := ""
LOCAL _POS := 0

cQry := " SELECT A1_XROTA, "
cQry += "       BM_XSUBGRU, "
cQry += "       B1_XMODELO, "
cQry += "       SUM(C6_QTDVEN) QTDVEN, "
cQry += "       SUM(CASE WHEN C5_XENTREG <= '"+DTOS(mv_par23+15)+"' "
cQry += "           THEN (C6_QTDVEN * B1_XESPACO) / DECODE(C5_XTPCOMP, 'V', 3, 'C', 2, 1) "
cQry += "           ELSE 0 END) ESPLIVRE, "
cQry += "       SUM(CASE WHEN C5_XENTREG <= '"+DTOS(mv_par23+15)+"' "
cQry += "           THEN (DECODE(C5_XOPER,'07',C6_PRCVEN,'08',C6_PRCVEN,C6_XPRUNIT)- "
cQry += "            DECODE(C5_XTPSEGM,'3',((C6_XGUELTA + C6_XRESSAR) * C6_XPRUNIT / 100),0))*C6_QTDVEN "
cQry += "           ELSE 0 END) TOTLIVRE, "
cQry += "       SUM(CASE WHEN C5_XENTREG > '"+DTOS(mv_par23+15)+"' "
cQry += "           THEN (C6_QTDVEN * B1_XESPACO) / DECODE(C5_XTPCOMP, 'V', 3, 'C', 2, 1) "
cQry += "           ELSE 0 END) ESPFUT, "
cQry += "       SUM(CASE WHEN C5_XENTREG > '"+DTOS(mv_par23+15)+"' "
cQry += "           THEN (DECODE(C5_XOPER,'07',C6_PRCVEN,'08',C6_PRCVEN,C6_XPRUNIT)- "
cQry += "            DECODE(C5_XTPSEGM,'3',((C6_XGUELTA + C6_XRESSAR) * C6_XPRUNIT / 100),0))*C6_QTDVEN "
cQry += "           ELSE 0 END) TOTFUT, "
cQry += "       SUM((C6_QTDVEN * B1_XESPACO) / DECODE(C5_XTPCOMP, 'V', 3, 'C', 2, 1)) AS ESPACO, "
cQry += "       SUM((DECODE(C5_XOPER,'07',C6_PRCVEN,'08',C6_PRCVEN,C6_XPRUNIT)- "
cQry += "            DECODE(C5_XTPSEGM,'3',((C6_XGUELTA + C6_XRESSAR) * C6_XPRUNIT / 100),0))*C6_QTDVEN) TOTPED, "
cQry += "       MIN(C5_EMISSAO) ULTPEDROTA "
cQry += "  FROM "+RETSQLNAME("SC5")+ " SC5, "
cQry += "       "+RETSQLNAME("SC6")+ " SC6, "
cQry += "       "+RETSQLNAME("SB1")+ " SB1, "
cQry += "       "+RETSQLNAME("SA1")+ " SA1,  CARTEIRA"+cEmpAnt+"0, "
cQry += "       "+RETSQLNAME("SBM")+ " SBM "
cQry += " WHERE C5_NUM = C6_NUM  "
cQry += "   AND SC5.R_E_C_N_O_ = REC "
cQry += "   AND C6_PRODUTO = B1_COD "
cQry += "   AND C5_CLIENTE = A1_COD "
cQry += "   AND SA1.A1_LOJA = C5_LOJACLI "
cQry += "   AND SA1.A1_COD = C5_CLIENTE  "
cQry += "   AND B1_GRUPO = BM_GRUPO "
cQry += "   AND SC5.D_E_L_E_T_ = ' ' "
cQry += "   AND SC6.D_E_L_E_T_ = ' ' "
cQry += "   AND SB1.D_E_L_E_T_ = ' ' "
cQry += "   AND SA1.D_E_L_E_T_ = ' ' "
cQry += "   AND SBM.D_E_L_E_T_ = ' ' "
cQry += "   AND C5_FILIAL = '"+xFilial("SC5")+"'"
cQry += "   AND C6_FILIAL = '"+xFilial("SC6")+"'"
cQry += "   AND B1_FILIAL = '"+xFilial("SB1")+"'"
cQry += "   AND A1_FILIAL = '"+xFilial("SA1")+"'"
cQry += "   AND BM_FILIAL = '"+xFilial("SBM")+"'"
cQry += "   AND C5_NOTA = ' ' "
cQry += "   AND C5_XACERTO = ' ' "
cQry += "   AND C5_XEMBARQ = ' ' "

//SSI-105463 - Vagner Almeida - 18/12/2020 - Início

//cQry += "   AND C5_XOPER NOT IN ('13', '20', '21', '99') "

If MV_PAR39 == 2 // Origem (DE)
	cQry += " AND C5_XOPER NOT IN ('20','21','96','99') "  		//Não lista pedidos "Não repor" e "Cancelados" e "Aglutinados"
Else
	cQry += " AND C5_XOPER NOT IN ('13','20','21','96','99') "	//Não lista pedidos "Não repor" e "Cancelados" e "Aglutinados"
Endif

//cQry += " AND C5_CLIENTE between '" + MV_PAR01 + "' and '" + MV_PAR03 + "'"
//cQry += " AND C5_LOJACLI between '" + MV_PAR02 + "' and '" + MV_PAR04 + "'"
IF MV_PAR37 == 1
	cQry += " AND C5_CLIENTE between '" + MV_PAR01 + "' and '" + MV_PAR03 + "'"
	cQry += " AND C5_LOJACLI between '" + MV_PAR02 + "' and '" + MV_PAR04 + "'"
ELSE
	cQry += " AND C5_CLIENTE IN	(SELECT A1_COD "
	cQry += "							 FROM SIGA."+RetSQLName("SA1")+" SA11 "
	cQry += "							 WHERE A1_XCODGRU IN (SELECT A1_XCODGRU "
	cQry += "													FROM SIGA."+RetSQLName("SA1")+" SA12 "
	cQry += "												   WHERE A1_COD between '" + MV_PAR01 + "' and '" + MV_PAR03 + "'))"
Endif

If !Empty(MV_PAR40)
	cQry += " AND UPPER(A1_BAIRRO) = ('" + UPPER(MV_PAR40) + "') "
EndIf

//SSI-105463 - Vagner Almeida - 18/12/2020 - Final

cQry += " AND C5_TABELA BETWEEN '" + MV_PAR06 + "' AND '" + MV_PAR07 + "'"
cQry += " AND C5_VEND1 between '" + MV_PAR08 + "' and '" + MV_PAR09 + "'"
If MV_PAR05 <> 5
	cQry += " AND C5_XTPSEGM = '" + STRZERO(MV_PAR05,1) + "'"
Endif

//cQry += "AND C5_XOPER IN "+cOpr+")"  //SSI-105463 - Vagner Almeida - 18/12/2020 

If MV_PAR15 = 2
	cQry += " AND C5_XENTREF <> ' ' "                           // C/DATA ENTREGA
Endif

If mv_par16 = 2
	cQry += " AND C5_XDTLIB <> ' '  AND C5_XQUAREN != '1'  "                            // LIBERADOS
ElseIf mv_par16 = 3
	cQry += " AND C5_XDTLIB = ' '  AND C5_XQUAREN != '1'  "                             // NAO LIBERADOS
ElseIf mv_par16 = 4
	cQry += " AND C5_XQUAREN = '1' "                            // QUARENTENA
Endif
/*If mv_par16 = 2
	cQry += " AND C5_XDTLIB <> ' ' "                            // LIBERADOS
ElseIf mv_par16 = 3
	cQry += " AND C5_XDTLIB = ' ' "                             // NAO LIBERADOS
Endif*/

If mv_par17 = 2
	cQry += " AND C5_XTPSEGM = '3' "					 // Só Lojas
ElseIf mv_par17 = 3
	cQry += " AND C5_XTPSEGM <> '3' "                    // Sem Lojas
EndIf

If MV_PAR10 = 1
	cQry += " AND B1_COD NOT LIKE '407095%' "                       // NAO LISTA TERCEIROS
Else
	If MV_PAR12 = 2
		cQry += " AND B1_COD LIKE '407095%' "                      // LISTA SOMENTE TERCEIROS SE O PARAMETRO 9 FOR IGUAL A 2 (SIM)
	Endif
Endif
cQry += " GROUP BY A1_XROTA , BM_XSUBGRU, B1_XMODELO ,C6_QTDVEN "
cQry += " ORDER BY 1  "
If Select("QRY") > 0
	dbSelectArea("QRY")
	dbCloseArea()
EndIf
memowrit("c:\ortr077fe.sql",cQry)
TcQuery cQry ALIAS "QRY" NEW
dbSelectArea("QRY")

While !QRY->(EOF())
	
	//QUADRO 1 - MANTAS/FIBRAS
	IF QRY->BM_XSUBGRU $ IIF(CEMPANT$"22","00001I|00005I","20010I")
		_POS	:= Ascan(_aResumo2,{|aVal|aVal[1]==Alltrim(QRY->A1_XROTA)})
		If _POS = 0
			AADD(_aResumo2,{Alltrim(QRY->A1_XROTA),QRY->ESPACO, QRY->TOTPED, QRY->EspLivre, QRY->TotLivre, QRY->EspFut, QRY->TotFut,QRY->QTDVEN})
		else
			_aResumo2[_POS][2] +=  QRY->ESPACO
			_aResumo2[_POS][3] +=  QRY->TOTPED
			_aResumo2[_POS][4] +=  QRY->EspLivre
			_aResumo2[_POS][5] +=  QRY->TotLivre
			_aResumo2[_POS][6] +=  QRY->EspFut
			_aResumo2[_POS][7] +=  QRY->TotFut
			_aResumo2[_POS][8] +=  QRY->QTDVEN
		Endif
	ELSE
		_POS	:= Ascan(_aResumo2,{|aVal|aVal[1]==Alltrim(QRY->A1_XROTA)})
		If _POS = 0
			AADD(_aResumo2,{Alltrim(QRY->A1_XROTA),0,0,0,0,0,0,0})
		ENDIF
	ENDIF
	
	//QUADRO 2 - TRAV ESPUMAS
	IF QRY->BM_XSUBGRU $ "00002I|100070|00008I" 
		
		_POS	:= Ascan(_aResumo2B,{|aVal|aVal[1]==Alltrim(QRY->A1_XROTA)})
		If _POS = 0
			AADD(_aResumo2B,{Alltrim(QRY->A1_XROTA),QRY->ESPACO, QRY->TOTPED, QRY->EspLivre, QRY->TotLivre, QRY->EspFut, QRY->TotFut, QRY->QTDVEN})
		else
			_aResumo2B[_POS][2] +=  QRY->ESPACO
			_aResumo2B[_POS][3] +=  QRY->TOTPED
			_aResumo2B[_POS][4] +=  QRY->EspLivre
			_aResumo2B[_POS][5] +=  QRY->TotLivre
			_aResumo2B[_POS][6] +=  QRY->EspFut
			_aResumo2B[_POS][7] +=  QRY->TotFut
			_aResumo2B[_POS][8] +=  QRY->QTDVEN
			
		Endif
		***
		//QUADRO - TRAV ESPUMAS
	ElseIF QRY->BM_XSUBGRU $ "10008O" 
		
		_POS	:= Ascan(_aResumo2E,{|aVal|aVal[1]==Alltrim(QRY->A1_XROTA)})
		If _POS = 0
			AADD(_aResumo2E,{Alltrim(QRY->A1_XROTA),QRY->ESPACO, QRY->TOTPED, QRY->EspLivre, QRY->TotLivre, QRY->EspFut, QRY->TotFut, QRY->QTDVEN})
		else
			_aResumo2E[_POS][2] +=  QRY->ESPACO
			_aResumo2E[_POS][3] +=  QRY->TOTPED
			_aResumo2E[_POS][4] +=  QRY->EspLivre
			_aResumo2E[_POS][5] +=  QRY->TotLivre
			_aResumo2E[_POS][6] +=  QRY->EspFut
			_aResumo2E[_POS][7] +=  QRY->TotFut
			_aResumo2E[_POS][8] +=  QRY->QTDVEN
		Endif
		***
	ELSE
		
		_POS	:= Ascan(_aResumo2E,{|aVal|aVal[1]==Alltrim(QRY->A1_XROTA)})
		If _POS = 0
			AADD(_aResumo2E,{Alltrim(QRY->A1_XROTA),0, 0, 0, 0, 0, 0, 0})
		ENDIF
	ENDIF
	
	//QUADRO 3 - CAMARIA/OUTROS
	IF !(QRY->BM_XSUBGRU $ "00002I|00001I|00005I|20010I|100070|10008O|00008I")
		
		_POS	:= Ascan(_aResumo2C,{|aVal|aVal[1]==Alltrim(QRY->A1_XROTA)})
		If _POS = 0
			AADD(_aResumo2C,{Alltrim(QRY->A1_XROTA),QRY->ESPACO, QRY->TOTPED, QRY->EspLivre, QRY->TotLivre, QRY->EspFut, QRY->TotFut,QRY->QTDVEN})
		else
			_aResumo2C[_POS][2] +=  QRY->ESPACO
			_aResumo2C[_POS][3] +=  QRY->TOTPED
			_aResumo2C[_POS][4] +=  QRY->EspLivre
			_aResumo2C[_POS][5] +=  QRY->TotLivre
			_aResumo2C[_POS][6] +=  QRY->EspFut
			_aResumo2C[_POS][7] +=  QRY->TotFut
			_aResumo2C[_POS][8] +=  QRY->QTDVEN
		ENDIF
		
		
		
	ELSE
		
		_POS	:= Ascan(_aResumo2C,{|aVal|aVal[1]==Alltrim(QRY->A1_XROTA)})
		If _POS = 0
			AADD(_aResumo2C,{Alltrim(QRY->A1_XROTA),0, 0, 0, 0, 0, 0,0})
		ENDIF
	ENDIF
	
	dbskip()
end

dbSelectarea("QRY")
DBCLOSEAREA()

DBSELECTAREA("TSC5")

RETURN

***************************
STATIC FUNCTION FVALIDARRAY(cTP,_ARRAY)
//(4,_aResumo2E)
***************************
Local aArea     := GetArea()
LOCAL _POS := 0

If cTP = '1'  // SE ARRAY ASEGMENTO
	
	cQry := "SELECT X5_CHAVE , X5_DESCRI "
	cQry += "  FROM "+RETSQLNAME("SX5")+ " "
	cQry += " WHERE D_E_L_E_T_ = ' ' "
	cQry += "   AND X5_FILIAL = '"+xFilial("SX5")+"'  "
	cQry += "   AND X5_TABELA = 'ZA' "
	cQry += "   ORDER BY X5_DESCRI   "
	Memowrite("C:\VALIDARRAY.SQL", cQry)
	If Select("VARR") > 0
		dbSelectArea("VARR")
		dbCloseArea()
	EndIf
	
	TcQuery cQry ALIAS "VARR" NEW
	dbSelectArea("VARR")
	dbGoTop()
	
	While !VARR->(EOF())
		
		_POS	:= Ascan(_ARRAY,{|aVal|aVal[2]==Alltrim(VARR->X5_DESCRI)})
		
		
		If _POS = 0
			AADD(_ARRAY,{Alltrim(VARR->X5_CHAVE),Alltrim(VARR->X5_DESCRI),0,0,0,0,0,"",0})
		Endif
		
		dbskip()
	End
	
	
	dbclosearea()
	
ElseIF cTP = '2' // SE ARRAY MODELOS
	
	
	cQry := "SELECT X5_CHAVE , X5_DESCRI "
	cQry += "  FROM "+RETSQLNAME("SX5")+ " "
	cQry += " WHERE D_E_L_E_T_ = ' ' "
	cQry += "   AND X5_FILIAL = '"+xFilial("SX5")+"'  "
	cQry += "   AND X5_TABELA = 'ZD' "
	cQry += "   ORDER BY X5_DESCRI   "
	Memowrite("C:\VALIDARRAY.SQL", cQry)
	If Select("VARR") > 0
		dbSelectArea("VARR")
		dbCloseArea()
	EndIf
	
	TcQuery cQry ALIAS "VARR" NEW
	dbSelectArea("VARR")
	dbGoTop()
	
	While !VARR->(EOF())
		
		_POS	:= Ascan(_ARRAY,{|aVal|aVal[2]==Alltrim(VARR->X5_DESCRI)})
		
		
		If _POS = 0
			AADD(_ARRAY,{Alltrim(VARR->X5_CHAVE),Alltrim(VARR->X5_DESCRI),0,0})
		Endif
		
		
		dbskip()
	End
	
	
	
ELSE
	
	cQry := "SELECT Z3_CODIGO "
	cQry += "  FROM "+RETSQLNAME("SZ3")+ " "
	cQry += " WHERE D_E_L_E_T_ = ' ' "
	cQry += "   AND Z3_FILIAL = '"+xFilial("SZ3")+"'  "
	Memowrite("C:\VALIDARRAY.SQL", cQry)
	If Select("VARR") > 0
		dbSelectArea("VARR")
		dbCloseArea()
	EndIf
	
	TcQuery cQry ALIAS "VARR" NEW
	dbSelectArea("VARR")
	dbGoTop()
	
	While !VARR->(EOF())
		
		If cTP = '3'
			_POS	:= Ascan(_ARRAY,{|aVal|aVal[1]==Alltrim(VARR->Z3_CODIGO+'A')})
			
			
			If _POS = 0
				AADD(_ARRAY,{Alltrim(VARR->Z3_CODIGO)+'A',Alltrim(VARR->Z3_CODIGO),'',0, 0, 0, 0, 0, 0, 0})
			Endif
			
		Else
			
			_POS	:= Ascan(_ARRAY,{|aVal|aVal[1]==Alltrim(VARR->Z3_CODIGO)})
			
			
			If _POS = 0
				AADD(_ARRAY,{Alltrim(VARR->Z3_CODIGO),0, 0, 0, 0, 0, 0, 0 })
			Endif
			
			
		endif
		
		dbskip()
	End
	
	DBCLOSEAREA()
	
	
	
ENDIF


RestArea( aArea )
RETURN

//PROGRAMADO POR GRUPO DE PRODUTO
STATIC FUNCTION FPROGZONA()
****************************
LOCAL CQRY:=""
LOCAL _POS:= 0
Local _nqtdleit	 := 0
Local _ntpedleit := 0

CQRY:="SELECT BM_XSUBGRU , B1_XMODELO, "
cQry+= "       SUM(C6_QTDVEN) QTDVEN , "
cQry+= "       SUM((DECODE(C5_XOPER,'07',C6_PRCVEN,'08',C6_PRCVEN,C6_XPRUNIT)- "
cQry+= "            DECODE(C5_XTPSEGM,'3',((C6_XGUELTA + C6_XRESSAR) * C6_XPRUNIT / 100),0))*C6_QTDVEN) VALOR, BM_GRUPO "
CQRY+="  FROM "+RETSQLNAME("SC5")+" SC5 , "+RETSQLNAME("SC6")+" SC6 , "+RETSQLNAME("SB1")+" SB1 , "+RETSQLNAME("SBM")+" SBM, " +RETSQLNAME("SZQ")+ " SZQ "
CQRY+="  WHERE SC5.D_E_L_E_T_ = ' ' "
CQRY+="  AND SC6.D_E_L_E_T_ = ' ' "
CQRY+="  AND SB1.D_E_L_E_T_ = ' ' "
CQRY+="  AND SBM.D_E_L_E_T_ = ' ' "
CQRY+="  AND SZQ.D_E_L_E_T_ = ' ' "
CQRY+="  AND C5_FILIAL = '"+xFilial("SC5")+"' "
CQRY+="  AND C6_FILIAL = '"+xFilial("SC6")+"' "
CQRY+="  AND B1_FILIAL = '"+xFilial("SB1")+"' "
CQRY+="  AND BM_FILIAL = '"+xFilial("SBM")+"' "
CQRY+="  AND ZQ_FILIAL = '"+xFilial("SZQ")+"' "
CQRY+="  AND C5_NUM = C6_NUM   "
CQRY+="  AND C5_CLIENTE = C6_CLI    "
CQRY+="  AND B1_COD = C6_PRODUTO    "
CQRY+="  AND B1_GRUPO = BM_GRUPO    "
CQRY+="  AND C5_XEMBARQ = ZQ_EMBARQ "
CQRY+="  AND C5_XOPER NOT IN ('13', '20', '21','22','96', '99') "
CQRY+="  AND ZQ_DTPREVE = '"+DTOS(MV_PAR33)+"' "
CQRY+="  GROUP BY BM_XSUBGRU , B1_XMODELO, BM_GRUPO"
Memowrite("C:\PROG_ZONA.SQL", cQry)
If Select("PRG") > 0
	dbSelectArea("PRG")
	dbCloseArea()
EndIf

TcQuery cQry ALIAS "PRG" NEW
dbSelectArea("PRG")
dbGoTop()

While !PRG->(EOF())
	If PRG->BM_GRUPO $ "7545|9201"
		_nqtdleit  := PRG->QTDVEN
		_ntpedleit := PRG->VALOR
	eNDIF
	AADD(_aProgGP,{PRG->BM_XSUBGRU,PRG->VALOR,PRG->QTDVEN,PRG->B1_XMODELO, PRG->BM_GRUPO,_nqtdleit,_ntpedleit })
	DBSKIP()
END

RETURN


//PROGRAMADO POR GRUPO DE PRODUTO
STATIC FUNCTION FPRODUC()
***********************
LOCAL CQRY:=""
LOCAL _POS:= 0
LOCAL _nqtdleit  := 0
LOCAL _ntpedleit := 0


CQRY:="SELECT BM_XSUBGRU, B1_XMODELO, SUM(C2_QUANT) QTDVEN, 0 VALOR, SUM(B2_QATU) ESTOQUE, BM_GRUPO "
CQRY+="  FROM "+RETSQLNAME("SB1")+" SB1, " +RETSQLNAME("SBM")+" SBM, "+RETSQLNAME("SC2")+" SC2, "+RETSQLNAME("SB2")+" SB2  "
CQRY+=" WHERE SB1.D_E_L_E_T_ = ' '   "
CQRY+="   AND SBM.D_E_L_E_T_ = ' '   "
CQRY+="   AND SC2.D_E_L_E_T_ = ' '   "
CQRY+="   AND SB2.D_E_L_E_T_ = ' '   "
CQRY+="   AND B1_FILIAL = '"+xFilial("SB1")+"'   "
CQRY+="   AND BM_FILIAL = '"+xFilial("SBM")+"'   "
CQRY+="   AND C2_FILIAL = '"+xFilial("SC2")+"'   "
CQRY+="   AND B2_FILIAL = '"+xFilial("SB2")+"'   "
CQRY+="   AND C2_XOPEST = 'S'    "
CQRY+="   AND C2_PRODUTO = B1_COD "
CQRY+="   AND B1_GRUPO = BM_GRUPO "
CQRY+="   AND B1_COD = B2_COD "
CQRY+="   AND B1_LOCPAD = B2_LOCAL "
CQRY+="   AND C2_DATPRI = '"+DTOS(MV_PAR33)+"' "
CQRY+=" GROUP BY BM_XSUBGRU, B1_XMODELO, BM_GRUPO "

Memowrite("C:\PROG_GRUPO.SQL", cQry)
If Select("PRD") > 0
	dbSelectArea("PRD")
	dbCloseArea()
EndIf

TcQuery cQry ALIAS "PRD" NEW
dbSelectArea("PRD")
dbGoTop()

While !PRD->(EOF())
	If PRD->BM_GRUPO $ "7545|9201"
		_nqtdleit  := PRD->QTDVEN
		_ntpedleit := PRD->VALOR
	eNDIF
	AADD(_aProdGP,{PRD->BM_XSUBGRU,PRD->VALOR,PRD->QTDVEN,PRD->B1_XMODELO, PRD->ESTOQUE,_nqtdleit, _ntpedleit},)
	DBSKIP()
END

RETURN


STATIC FUNCTION FABATE()
**********************
LOCAL CQRY:=""
LOCAL _nqtdleit  := 0
LOCAL _ntpedleit := 0


CQRY:=" Select BM_XSUBGRU, Sum(QTD) QTD                "
CQRY+="   from (SELECT b1_tipo, bm_xsubgru, c6_produto, b1_desc, b1_xperson, c6_xmed, "
CQRY+="                Sum(c6_xqtdtrf) QTD,            "
CQRY+="                (CASE WHEN zq_xtpcar = '7' THEN "
CQRY+="                   zq_xtpcar           "
CQRY+="                  ELSE                 "
CQRY+="                   '1'                 "
CQRY+="                END) zq_xtpcar,        "
CQRY+="                zq_dtpreve             "
CQRY+="           FROM "+retsqlname("SZQ")+" zq, "
CQRY+="                "+retsqlname("SC5")+" c5, "
CQRY+="                "+retsqlname("SC6")+" c6, "
CQRY+="                "+retsqlname("SB1")+" B1, "
CQRY+="                "+retsqlname("SBM")+" sbm "
CQRY+="          WHERE c5_num = c6_num        "
CQRY+="            AND zq_embarq = c5_xembarq "
CQRY+="            AND b1_grupo = bm_grupo "
CQRY+="            AND zq_filial = '"+xFilial("SZQ")+"'    "
CQRY+="            AND c5_filial = '"+xFilial("SC5")+"'    "
CQRY+="            AND c6_filial = '"+xFilial("SC6")+"'    "
CQRY+="            AND b1_filial = '"+xFilial("SB1")+"'    "
CQRY+="            AND bM_filial = '"+xFilial("SBM")+"'    "
CQRY+="            AND zq.d_e_l_e_t_ = ' ' "
CQRY+="            AND c5.d_e_l_e_t_ = ' ' "
CQRY+="            AND c6.d_e_l_e_t_ = ' ' "
CQRY+="            AND b1.d_e_l_e_t_ = ' ' "
CQRY+="            AND b1_cod = c6_produto "
CQRY+="            AND zq_dtpreve = '"+DTOS(MV_PAR33)+"' "
CQRY+="            AND c6_xqtdtrf <> 0 "
CQRY+="          GROUP BY b1_tipo, c6_produto, b1_desc, b1_xperson, c6_xmed, zq_xtpcar, zq_dtpreve, bm_xsubgru "
CQRY+="              UNION ALL "
CQRY+="              SELECT b1_tipo, bm_xsubgru, c6_produto, b1_desc, b1_xperson, c6_xmed, "
CQRY+="                     sum(pa1_quant) QTD,         "
CQRY+="                     (CASE                       "
CQRY+="                       WHEN zq_xtpcar = '7' THEN "
CQRY+="                        zq_xtpcar            "
CQRY+="                       ELSE                  "
CQRY+="                        '1'                  "
CQRY+="                     END) zq_xtpcar,         "
CQRY+="                     zq_dtpreve              "
CQRY+="                FROM "+retsqlname("SZQ")+" zq,  "
CQRY+="                     "+retsqlname("SC5")+" c5,  "
CQRY+="                     "+retsqlname("SC6")+" c6,  "
CQRY+="                     "+retsqlname("PA1")+" PA1, "
CQRY+="                     "+retsqlname("SB1")+" B1,  "
CQRY+="                     "+retsqlname("sbm")+" sbm  "
CQRY+="               WHERE c5_num = c6_num         "
CQRY+="                 AND zq_embarq = c5_xembarq  "
CQRY+="                 AND b1_grupo = bm_grupo     "
CQRY+="                 AND zq_filial = '"+xFilial("SZQ")+"' "
CQRY+="                 AND c5_filial = '"+xFilial("SC5")+"' "
CQRY+="                 AND c6_filial = '"+xFilial("SC6")+"' "
CQRY+="                 AND pa1_filial = '"+xFilial("PA1")+"'"
CQRY+="                 AND b1_filial = '"+xFilial("SB1")+"' "
CQRY+="                 AND bm_filial = '"+xFilial("SBM")+"' "
CQRY+="                 AND zq.d_e_l_e_t_ = ' '     "
CQRY+="                 AND c5.d_e_l_e_t_ = ' '     "
CQRY+="                 AND c6.d_e_l_e_t_ = ' '     "
CQRY+="                 AND pa1.d_e_l_e_t_ = ' '    "
CQRY+="                 AND b1.d_e_l_e_t_ = ' '     "
CQRY+="                 AND SBM.D_E_L_E_T_ = ' '    "
CQRY+="                 AND b1_cod = c6_produto     "
CQRY+="                 AND zq_dtpreve = '"+DTOS(MV_PAR33)+"' "
CQRY+="                 AND pa1.pa1_produt = c6.c6_produto "
CQRY+="                 AND pa1.pa1_item = c6.c6_item   "
CQRY+="                 AND pa1.pa1_pedido = c6.c6_num  "
CQRY+="                 AND pa1.pa1_tipo = 'E' "
CQRY+="               GROUP BY b1_tipo, c6_produto, b1_desc, b1_xperson, c6_xmed,zq_xtpcar, zq_dtpreve, bm_xsubgru) x "
CQRY+="       GROUP BY b1_tipo,   "
CQRY+="                BM_XSUBGRU "
Memowrite("C:\ABATE_GRUPO.SQL", cQry)
If Select("ABT") > 0
	dbSelectArea("ABT")
	dbCloseArea()
EndIf

TcQuery cQry ALIAS "ABT" NEW
dbSelectArea("ABT")
dbGoTop()

While !ABT->(EOF())
	
	AADD(_aBate,{ABT->BM_XSUBGRU,ABT->QTD})
	DBSKIP()
END

RETURN


STATIC FUNCTION FACUMES()
**************************
LOCAL CQRY:=""
LOCAL _POS:= 0


CQRY:="SELECT GRU BM_XSUBGRU, MODELO B1_XMODELO,NVL(VALOR, 0) VALOR, NVL((QTDVEN + PRODUZ),0)-NVL(ABATE, 0) QTDVEN, NVL(ABATE, 0) ABATE, NVL(PRODUZ, 0) PRODUZ, NVL(DIAS,0) DIAS "
CQRY+="  FROM (SELECT GRU, MODELO, SUM(VALOR) VALOR, SUM(QTDVEN) QTDVEN, SUM(ABATE) ABATE, SUM(PRODUZ) PRODUZ, "
CQRY+="        ((SELECT sum(Count(Distinct C2_DATPRI)) 	"
CQRY+="            FROM "+RETSQLNAME("SB1")+" SB12, "
CQRY+="                 "+RETSQLNAME("SBM")+" SBM2, "
CQRY+="                 "+RETSQLNAME("SC2")+" SC2  "
CQRY+="           WHERE SB12.D_E_L_E_T_ = ' ' "
CQRY+="             AND SBM2.D_E_L_E_T_ = ' ' "
CQRY+="             AND SC2.D_E_L_E_T_ = ' '  "
CQRY+="             AND B1_FILIAL = '"+xFilial("SB1")+"'"
CQRY+="             AND BM_FILIAL = '"+xFilial("SBM")+"'"
CQRY+="             AND C2_FILIAL = '"+xFilial("SC2")+"'"
CQRY+="             AND B1_GRUPO = BM_GRUPO   "
CQRY+="             AND GRU = SBM2.BM_XSUBGRU "
CQRY+="             AND C2_PRODUTO = B1_COD   "
CQRY+="             AND C2_DATPRI BETWEEN '" + dtos(FirstDate(MV_PAR33)) + "' AND '"+dtos(MV_PAR33)+"'"
CQRY+="           GROUP BY C2_DATPRI)) DIAS   "
CQRY+="          FROM ( SELECT *   "
CQRY+="                  FROM (SELECT BM_XSUBGRU GRU, B1_XMODELO MODELO, SUM(C6_QTDVEN) QTDVEN, "
CQRY+="                                (SELECT Sum(c6_xqtdtrf) QTD "
CQRY+="                                   FROM "+RETSQLNAME("SZQ")+" zq, "
CQRY+="                                        "+RETSQLNAME("SC5")+" c5, "
CQRY+="                                        "+RETSQLNAME("SC6")+" c6, "
CQRY+="                                        "+RETSQLNAME("SB1")+" B1, "
CQRY+="                                        "+RETSQLNAME("SBM")+" bm  "
CQRY+="                                  WHERE C5.c5_num = C6.c6_num        "
CQRY+="                                    AND ZQ.zq_embarq = C5.c5_xembarq "
CQRY+="                                    AND B1.b1_grupo = BM.bm_grupo "
CQRY+="                                    AND ZQ.zq_filial = '"+xFilial("SZQ")+"'  "
CQRY+="                                    AND C5.c5_filial = '"+xFilial("SC5")+"'  "
CQRY+="                                    AND c6_filial = '"+xFilial("SC6")+"'     "
CQRY+="                                    AND B1.b1_filial = '"+xFilial("SB1")+"'  "
CQRY+="                                    AND BM.bM_filial = '"+xFilial("SBM")+"'  "
CQRY+="                                    AND zq.d_e_l_e_t_ = ' '  "
CQRY+="                                    AND c5.d_e_l_e_t_ = ' '  "
CQRY+="                                    AND c6.d_e_l_e_t_ = ' '  "
CQRY+="                                    AND b1.d_e_l_e_t_ = ' '  "
CQRY+="                                    AND B1.b1_cod = C6.c6_produto  "
CQRY+="                                    AND ZQ_DTPREVE BETWEEN '" + dtos(FirstDate(MV_PAR33)) + "' AND '"+dtos(MV_PAR33)+"'"
CQRY+="                                    AND C6.c6_xqtdtrf <> 0                     "
CQRY+="                                    AND B1.B1_COD = SB1.B1_COD                 "
CQRY+="                                    AND B1.B1_XMODELO = SB1.B1_XMODELO         "
CQRY+="                                    AND BM.BM_XSUBGRU = SBM.BM_XSUBGRU) ABATE, "
CQRY+="                                0 PRODUZ,                 "
CQRY+="                                SUM((DECODE(C5_XOPER,     "
CQRY+="                                            '07',         "
CQRY+="                                            C6_PRCVEN,    "
CQRY+="                                            '08',         "
CQRY+="                                            C6_PRCVEN,    "
CQRY+="                                            C6_XPRUNIT) - "
CQRY+="                                    DECODE(C5_XTPSEGM, "
CQRY+="                                            '3', "
CQRY+="                                            ((C6_XGUELTA + C6_XRESSAR) * C6_XPRUNIT / 100), "
CQRY+="                                            0)) * C6_QTDVEN) VALOR  "
CQRY+="                           FROM "+RETSQLNAME("SC5")+" SC5, "
CQRY+="                                "+RETSQLNAME("SC6")+" SC6, "
CQRY+="                                "+RETSQLNAME("SB1")+" SB1, "
CQRY+="                                "+RETSQLNAME("SBM")+" SBM, "
CQRY+="                                "+RETSQLNAME("SZQ")+" SZQ  "
CQRY+="                          WHERE SC5.D_E_L_E_T_ = ' '   "
CQRY+="                            AND SC6.D_E_L_E_T_ = ' '   "
CQRY+="                            AND SB1.D_E_L_E_T_ = ' '   "
CQRY+="                            AND SBM.D_E_L_E_T_ = ' '   "
CQRY+="                            AND SZQ.D_E_L_E_T_ = ' '   "
CQRY+="                            AND C5_FILIAL = '"+xFilial("SC5")+"'  "
CQRY+="                            AND C6_FILIAL = '"+xFilial("SC6")+"'  "
CQRY+="                            AND B1_FILIAL = '"+xFilial("SB1")+"'  "
CQRY+="                            AND BM_FILIAL = '"+xFilial("SBM")+"'  "
CQRY+="                            AND ZQ_FILIAL = '02'       "
CQRY+="                            AND C5_NUM = C6_NUM        "
CQRY+="                            AND C5_CLIENTE = C6_CLI    "
CQRY+="                            AND B1_COD = C6_PRODUTO    "
CQRY+="                            AND B1_GRUPO = BM_GRUPO    "
CQRY+="                            AND C5_XEMBARQ = ZQ_EMBARQ "
CQRY+="                            AND ZQ_DTPREVE BETWEEN '" + dtos(FirstDate(MV_PAR33)) + "' AND '"+dtos(MV_PAR33)+"'"
CQRY+="                            AND C5_XOPER NOT IN ('13', '20', '21', '22','96', '99') "
CQRY+="                          GROUP BY BM_XSUBGRU, B1_XMODELO, B1_COD "
CQRY+="              UNION ALL                               "
CQRY+="                         SELECT BM_XSUBGRU, B1_XMODELO,0 QTDVEN, 0 ABATE, SUM(C2_QUANT) PRODUZ, 0 VALOR "
CQRY+="                           FROM "+RETSQLNAME("SB1")+" SB11, "
CQRY+="                                "+RETSQLNAME("SBM")+" SBM1, "
CQRY+="                                "+RETSQLNAME("SC2")+" SC21  "
CQRY+="                          WHERE SB11.D_E_L_E_T_ = ' ' "
CQRY+="                            AND SBM1.D_E_L_E_T_ = ' ' "
CQRY+="                            AND SC21.D_E_L_E_T_ = ' ' "
CQRY+="                            AND SB11.B1_FILIAL = '"+xFilial("SB1")+"'  "
CQRY+="                            AND SBM1.BM_FILIAL = '"+xFilial("SBM")+"'  "
CQRY+="                            AND SC21.C2_FILIAL = '"+xFilial("SC2")+"' "
CQRY+="                            AND SC21.C2_XOPEST = 'S'  "
CQRY+="                            AND SC21.C2_PRODUTO = SB11.B1_COD "
CQRY+="                            AND SB11.B1_GRUPO = SBM1.BM_GRUPO "
CQRY+="                            AND SC21.C2_DATPRI BETWEEN '" +dtos(FirstDate(MV_PAR33)) + "' AND '"+dtos(MV_PAR33)+"'"
CQRY+="                          GROUP BY BM_XSUBGRU, B1_XMODELO)) "
CQRY+="         GROUP BY GRU, MODELO ) "
Memowrite("C:\ACUMES_GRUPO.SQL", cQry)
If Select("ACU") > 0
	dbSelectArea("ACU")
	dbCloseArea()
EndIf

TcQuery cQry ALIAS "ACU" NEW
dbSelectArea("ACU")
dbGoTop()

While !ACU->(EOF())
	AADD(_aCUMES,{ACU->BM_XSUBGRU,ACU->B1_XMODELO,ACU->QTDVEN,ACU->VALOR,ACU->DIAS,_nqtdleit,_ntpedleit})
	DBSKIP()
END

RETURN

//Estoque na data
Static Function FEstoque()
***********************

local sDtFech	:=""
local CQRY		:=""
local _CQRY		:=""

_CQRY:="  SELECT MAX(B9_DATA) DTFECH                      "
_CQRY+="    FROM " + RetSqlName("SB9") + " SB9            "
_CQRY+="   WHERE D_E_L_E_T_ = ' '                         "
_CQRY+="     AND B9_FILIAL  = '" + xFilial("SB9") + "'    "
_CQRY+="     AND B9_DATA <= '" +Dtos(mv_par33)+ "'        "
If Select("_QRY") > 0
	dbSelectArea("_QRY")
	dbCloseArea()
	
EndIf

TCQUERY _cQry ALIAS "_QRY" NEW

dbSelectArea("_QRY")
If Eof()
	sDtFech:= "20010101"
else
	sDtFech:= _QRY->DTFECH
EndIf

CQRY:="SELECT NVL(sum((CASE WHEN BM_XSUBGRU = '00001I' OR BM_XSUBGRU = '00005I' THEN SUM(QTD) END)), 0) MANTAS, "
CQRY+="       NVL(sum((CASE WHEN BM_XSUBGRU = '00002I' OR BM_XSUBGRU = '100070' OR BM_XSUBGRU = '00008I' THEN SUM(QTD) END)), 0) TRAV,        "
CQRY+="       NVL(sum((CASE WHEN BM_XSUBGRU = '10008O' THEN SUM(QTD) END)), 0) TRAVE,       "
CQRY+="       NVL(sum((CASE WHEN BM_XSUBGRU = '00003I' THEN SUM(QTD) END)), 0) LENCOL,      "
CQRY+="       NVL(sum((CASE WHEN BM_XSUBGRU = '20009I' THEN SUM(QTD) END)), 0) SAIA,        "
CQRY+="       NVL(sum((CASE WHEN BM_XSUBGRU = '00007I' THEN SUM(QTD) END)), 0) PROTETOR,    "
CQRY+="       NVL(sum((CASE WHEN BM_XSUBGRU = '00004I' THEN SUM(QTD) END)), 0) EDREDON,     "
CQRY+="       NVL(sum((CASE WHEN BM_XSUBGRU = '00009I' THEN SUM(QTD) END)), 0) COBRE,     "
CQRY+="       NVL(sum((CASE WHEN BM_XSUBGRU = '00011I' THEN SUM(QTD) END)), 0) CAPA,         "
CQRY+="       NVL(sum((CASE WHEN BM_XSUBGRU = '20010I' THEN SUM(QTD) END)), 0) SACO,         "
CQRY+="       NVL(sum((CASE WHEN B1_XMODELO IN ('') THEN SUM(QTD) END)), 0) SACO         "
CQRY+="  FROM (SELECT B1_TIPO TIPO, D2_COD COD, B1_DESC DESCR, D2_LOCAL ALMOX, SUM(D2_QUANT * -1) QTD,  "
CQRY+="               B1_XMED XMED, 0 PROD, 0, 0 XCUSTO, 0 XCUSMED, DECODE(B1_XFORLIN, '        ', 0, 1) B1_XFORLIN, "
CQRY+="               B1_GRUPO, B1_XMODELO  "
CQRY+="          FROM "+RETSQLNAME("SD2")+" SD2, "+RETSQLNAME("SB1")+" SB1, "+RETSQLNAME("SF4")+" SF4  "
CQRY+="         WHERE SD2.D_E_L_E_T_ = ' '   "
CQRY+="           AND SB1.D_E_L_E_T_ = ' '   "
CQRY+="           AND SF4.D_E_L_E_T_ = ' '   "
CQRY+="           AND D2_FILIAL = '"+xFilial("SD2")+"'       "
CQRY+="           AND F4_FILIAL = '"+xFilial("SF4")+"'       "
CQRY+="           AND B1_FILIAL = '"+xFilial("SB1")+"'       "
CQRY+="           AND D2_COD = B1_COD        "
CQRY+="           AND D2_TES = F4_CODIGO     "
CQRY+="           AND B1_ATIVO = 'S'         "
CQRY+="           AND D2_LOCAL = '18'        "
CQRY+="           AND D2_EMISSAO <= '"+DTOS(MV_PAR33)+ "' "
CQRY+="           AND D2_EMISSAO > '"+sDtFech+"'  "
CQRY+="           AND F4_ESTOQUE = 'S'         "
CQRY+="         GROUP BY D2_COD, B1_DESC, D2_LOCAL, B1_TIPO, B1_XMED, B1_XFORLIN, B1_GRUPO, B1_XMODELO "
CQRY+="        UNION ALL "
CQRY+="        SELECT B1_TIPO, D1_COD, B1_DESC, D1_LOCAL, SUM(D1_QUANT), B1_XMED, 0 PROD, 0, 0 XCUSTO, "
CQRY+="               B1_XCUSMED, DECODE(B1_XFORLIN, '        ', 0, 1) B1_XFORLIN,B1_GRUPO, B1_XMODELO "
CQRY+="          FROM "+RETSQLNAME("SD1")+" SD1, "+RETSQLNAME("SB1")+" SB1, "+RETSQLNAME("SF4")+" SF4 "
CQRY+="         WHERE SD1.D_E_L_E_T_ = ' ' "
CQRY+="           AND SB1.D_E_L_E_T_ = ' ' "
CQRY+="           AND SF4.D_E_L_E_T_ = ' ' "
CQRY+="           AND D1_FILIAL = '"+xFilial("SD1")+"' "
CQRY+="           AND F4_FILIAL = '"+xFilial("SF4")+"' "
CQRY+="           AND B1_FILIAL = '"+xFilial("SB1")+"' "
CQRY+="           AND D1_COD = B1_COD      "
CQRY+="           AND D1_TES = F4_CODIGO   "
CQRY+="           AND B1_ATIVO = 'S'       "
CQRY+="           AND D1_LOCAL = '18'      "
CQRY+="           AND D1_DTDIGIT <= '"+DTOS(MV_PAR33)+"' "
CQRY+="           AND D1_DTDIGIT > '"+sDtFech+"'  "
CQRY+="           AND F4_ESTOQUE = 'S'         "
CQRY+="         GROUP BY D1_COD, B1_DESC, D1_LOCAL, B1_TIPO, B1_XMED, B1_XCUSMED, B1_XFORLIN, B1_GRUPO, B1_XMODELO "
CQRY+="        UNION ALL "
CQRY+="        SELECT B1_TIPO, D3_COD, B1_DESC, D3_LOCAL, "
CQRY+="               SUM(CASE "
CQRY+="                     WHEN D3_TM < '500' THEN "
CQRY+="                      D3_QUANT  "
CQRY+="                     ELSE       "
CQRY+="                      D3_QUANT * -1 "
CQRY+="                   END),        "
CQRY+="               B1_XMED, 0 PROD, 0, 0 XCUSTO, 0 XCUSMED,DECODE(B1_XFORLIN, '        ', 0, 1) B1_XFORLIN, B1_GRUPO, B1_XMODELO "
CQRY+="          FROM "+retsqlname("SD3")+" SD3, "+retsqlname("SB1")+" SB1  "
CQRY+="         WHERE SD3.D_E_L_E_T_ = ' '   "
CQRY+="           AND SB1.D_E_L_E_T_ = ' '   "
CQRY+="           AND D3_FILIAL = '"+xFilial("SD3")+"'       "
CQRY+="           AND B1_FILIAL = '"+xFilial("SB1")+"'       "
CQRY+="           AND D3_COD = B1_COD        "
CQRY+="           AND B1_ATIVO = 'S'         "
CQRY+="           AND D3_LOCAL = '18'        "
CQRY+="           AND D3_EMISSAO <= '"+DTOS(MV_PAR33)+"' "
CQRY+="           AND D3_EMISSAO > '"+sDtFech+"'  "
CQRY+="         GROUP BY D3_COD, B1_DESC,D3_LOCAL, B1_TIPO,B1_XMED,B1_XFORLIN,B1_GRUPO,B1_XMODELO "
CQRY+="        UNION ALL "
CQRY+="        SELECT B1_TIPO, B9_COD, B1_DESC, B9_LOCAL, B9_QINI, B1_XMED, 0 PROD, 0, 0 XCUSTO, 0 XCUSMED, "
CQRY+="               DECODE(B1_XFORLIN, '        ', 0, 1) B1_XFORLIN, B1_GRUPO,  B1_XMODELO                "
CQRY+="          FROM "+retsqlname("SB9")+" SB9, "+retsqlname("SB1")+" SB1 "
CQRY+="         WHERE SB9.D_E_L_E_T_ = ' '    "
CQRY+="           AND SB1.D_E_L_E_T_ = ' '    "
CQRY+="           AND B9_FILIAL = '"+xFilial("SB9")+"' "
CQRY+="           AND B1_FILIAL = '"+xFilial("SB1")+"' "
CQRY+="           AND B9_COD = B1_COD         "
CQRY+="           AND B1_ATIVO = 'S'          "
CQRY+="           AND B9_LOCAL = '18'         "
CQRY+="           AND B9_DATA = '"+sDtFech+"' "
CQRY+="        UNION ALL                      "
CQRY+="        SELECT B1_TIPO,C2_PRODUTO,B1_DESC, C2_LOCAL, 0, B1_XMED, SUM(C2_QUANT - C2_QUJE), 0,0 XCUSTO, "
CQRY+="               0 XCUSMED, DECODE(B1_XFORLIN, '        ', 0, 1) B1_XFORLIN, B1_GRUPO, B1_XMODELO       "
CQRY+="          FROM "+retsqlname("SB1")+" SB1, "+retsqlname("SC2")+" SC2 "
CQRY+="         WHERE SB1.D_E_L_E_T_ = ' '    "
CQRY+="           AND SC2.D_E_L_E_T_ = ' '    "
CQRY+="           AND B1_FILIAL = '"+xFilial("SB1")+"' "
CQRY+="           AND C2_FILIAL = '"+xFilial("SC2")+"' "
CQRY+="           AND C2_PRODUTO = B1_COD     "
CQRY+="           AND C2_QUJE < C2_QUANT      "
CQRY+="           AND B1_ATIVO = 'S'          "
CQRY+="           AND C2_LOCAL = '18'         "
CQRY+="           AND C2_XOPEST = 'S'         "
CQRY+="           AND C2_PEDIDO = ' '         "
CQRY+="           AND C2_EMISSAO BETWEEN '"+Dtos(dDataBase)+"' AND '"+DTOS(MV_PAR33)+"' "
CQRY+="         GROUP BY B1_TIPO, C2_PRODUTO, B1_DESC, C2_LOCAL,B1_XMED, B1_XFORLIN, B1_GRUPO, B1_XMODELO), "
CQRY+="       "+RETSQLNAME("SBM")+" SBM "
CQRY+=" WHERE B1_GRUPO = BM_GRUPO "
CQRY+=" GROUP BY B1_XMODELO, BM_XSUBGRU "
CQRY+=" ORDER BY 1 "

Memowrite("C:\ESTOQUE_077.SQL", cQry)
If Select("EST") > 0
	dbSelectArea("EST")
	dbCloseArea()
EndIf

TcQuery cQry ALIAS "EST" NEW
dbSelectArea("EST")
dbGoTop()

While !EST->(EOF())
	AADD(_AEST,{EST->MANTAS,EST->TRAV,EST->LENCOL,EST->SAIA,EST->PROTETOR,EST->EDREDON,EST->CAPA,EST->SACO,EST->COBRE,EST->TRAVE})
	DBSKIP()
END

RETURN


// PEGA O MIX DO PEDIDO
Static Function FscGetMix(cNumPed)
Local aArea		:= GetArea()
Local cQuery	:= ""
Local nMix		:= 0
Local nConta    := 0
Local nLL		:= 0
Local nTotCusto := 0
Local nTotParc  := 0
Local nVerba  	:= 0
/*
cQuery	:= "SELECT C6_XPRUNIT, C6_XCUSTO,(C6_QTDVEN*C6_XCUSTO) AS CUSTTOT, (C6_QTDVEN*C6_XPRUNIT) AS PRTOT, ZH_VERBREP FROM "
cQuery	+= RetSqlName("SC6") + " SC6, "
cQuery	+= RetSqlName("SZH") + " SZH, "
cQuery	+= RetSqlName("SC5") + " SC5, "
cQuery	+= RetSqlName("SA2") + " SA2 "
cQuery	+= "WHERE "
cQuery  += "   SC6.D_E_L_E_T_        = ' ' "
cQuery  += "   AND SC5.D_E_L_E_T_    = ' ' "
cQuery  += "   AND SA2.D_E_L_E_T_    = ' ' "
cQuery  += "   AND SZH.D_E_L_E_T_(+) = ' ' "
cQuery  += "   AND SC5.C5_FILIAL     = '"+xFilial("SC5")+"'"
cQuery  += "   AND SC6.C6_FILIAL     = '"+xFilial("SC6")+"'"
cQuery  += "   AND SA2.A2_FILIAL     = '"+xFilial("SA2")+"'"
cQuery  += "   AND SZH.ZH_FILIAL(+)  = '"+xFilial("SZH")+"'"
cQuery  += "   AND SC6.C6_NUM = '" + cNumPed +"'"
cQuery  += "   AND C5_NUM     = C6_NUM     "
cQuery  += "   AND C5_CLIENTE = A2_COD     "
cQuery  += "   AND C5_LOJACLI = A2_LOJA    "
cQuery  += "   AND C5_XTPSEGM = ZH_SEGMENT "
cQuery  += "   AND A2_COD     = ZH_CLIENTE(+) "
cQuery  += "   AND A2_LOJA    = ZH_LOJA(+)    "
*/
cQuery:="SELECT C6_XPRUNIT, C6_XCUSTO,(C6_QTDVEN*C6_XCUSTO) AS CUSTTOT, (C6_QTDVEN*C6_XPRUNIT) AS PRTOT, C5_XVERREP, C5_XVEREXT  "
cQuery+="FROM SIGA."+RetSqlName("SC5")+" SC5, "
cQuery+="     SIGA."+RetSqlName("SB1")+" SB1, "
cQuery+="     SIGA."+RETSQLNAME("SBM")+" SBM, "
cQuery+="     SIGA."+RetSqlName("SC6")+" SC6, "
cQuery+="     SIGA."+RetSqlName("SF4")+" SF4, "
cQuery+="     SIGA."+RetSqlName("SA3")+" SA3, "
cQuery+="     SIGA."+RetSqlName("SA1")+" SA1, "
cQuery+="     SIGA."+RetSqlName("SZ5")+" SZ5, "
cQuery+="     SIGA."+RetSqlName("SZH")+" SZH, "
cQuery+="     SIGA."+RetSqlName("SZQ")+" SZQ, "
cQuery+="     SIGA."+RetSqlName("SX5")+" SX5, "
cQuery+="     SIGA."+RetSqlName("CC2")+" CC2  "
cQuery+="  WHERE SA1.D_E_L_E_T_  = ' '  "
cQuery+="  AND B1_GRUPO = BM_GRUPO "
cQuery+="  AND SZ5.Z5_SEGMENT(+) = ' ' "
cQuery+="  AND A1_COD   = Z5_CLIENTE(+)  "
cQuery+="  AND A1_LOJA  = Z5_LOJA(+)    "
cQuery+="  AND CC2_FILIAL    = ' ' "
cQuery+="  AND CC2.D_E_L_E_T_= ' ' "
cQuery+="  AND CC2_EST      = A1_EST "
cQuery+="  AND CC2_CODMUN   = A1_COD_MUN "
cQuery+="  AND ZQ_EMBARQ(+) = C5_XEMBARQ "
cQuery+="  AND ZQ_EMBARQ(+) <> '          '   "
cQuery+="  AND C5_XMOTCAN   = X5_CHAVE (+) "
cQuery+="  AND X5_TABELA (+)= 'ZS' "
cQuery+="  AND C5_NUM = C6_NUM "
cQuery+="  AND C5_CLIENTE = A1_COD "
cQuery+="  AND C5_LOJACLI = A1_LOJA "
cQuery+="  AND C6_PRODUTO = B1_COD "
cQuery+="  AND C6_TES = F4_CODIGO "
cQuery+="  AND A1_COD = ZH_CLIENTE "
cQuery+="  AND A1_LOJA = ZH_LOJA   "
cQuery+="  AND ZH_MSBLQL <> '1'   "
cQuery+="  AND C5_XTPSEGM = ZH_SEGMENT "
cQuery+="  AND A3_COD = ZH_VEND "
cQuery+="  AND C5_TIPO NOT IN ('B','D') "
cQuery+="  AND SC5.D_E_L_E_T_ = ' '    "
cQuery+="  AND SC6.D_E_L_E_T_ = ' '    "
cQuery+="  AND SB1.D_E_L_E_T_ = ' '    "
cQuery+="  AND SBm.D_E_L_E_T_ = ' '    "
cQuery+="  AND SA3.D_E_L_E_T_ = ' '    "
cQuery+="  AND SF4.D_E_L_E_T_ = ' '    "
cQuery+="  AND SZH.D_E_L_E_T_ = ' '    "
cQuery+="  AND SZQ.D_E_L_E_T_(+) = ' '    "
cQuery+="  AND SZ5.D_E_L_E_T_(+) = ' ' "
cQuery+="  AND C5_FILIAL = '" + XFILIAL("SC5") + "' "
cQuery+="  AND C6_FILIAL = '" + XFILIAL("SC6") + "' "
cQuery+="  AND B1_FILIAL = '" + XFILIAL("SB1") + "' "
cQuery+="  AND BM_FILIAL = '" + XFILIAL("SB1") + "' "
cQuery+="  AND F4_FILIAL = '" + XFILIAL("SF4") + "' "
cQuery+="  AND A3_FILIAL = '" + XFILIAL("SA3") + "' "
cQuery+="  AND A1_FILIAL = '" + XFILIAL("SA1") + "' "
cQuery+="  AND ZH_FILIAL = '" + XFILIAL("SZH") + "' "
cQuery+="  AND Z5_FILIAL(+) = '" + XFILIAL("SZ5") + "' "
cQuery+="  AND ZQ_FILIAL(+) = '" + XFILIAL("SZQ") + "' "
cQuery+="  AND X5_FILIAL(+) = '" + XFILIAL("SZQ") + "' "
cQuery+="  AND C5_NUM = '" + cNumPed +"'"
cQuery+="UNION "
cQuery+="SELECT C6_XPRUNIT, C6_XCUSTO,(C6_QTDVEN*C6_XCUSTO) AS CUSTTOT, (C6_QTDVEN*C6_XPRUNIT) AS PRTOT, C5_XVERREP, ZH_VEREXT "
cQuery+=" FROM SIGA."+RetSqlName("SC5")+" SC5, "
cQuery+="      SIGA."+RetSqlName("SB1")+" SB1, "
cQuery+="      SIGA."+RetSqlName("SBM")+" SBM, "
cQuery+="      SIGA."+RetSqlName("SC6")+" SC6, "
cQuery+="      SIGA."+RetSqlName("SF4")+" SF4, "
cQuery+="      SIGA."+RetSqlName("SA3")+" SA3, "
cQuery+="      SIGA."+RetSqlName("SA2")+" SA2,  "
cQuery+="      SIGA."+RetSqlName("SZH")+" SZH,  "
cQuery+="      SIGA."+RetSqlName("SZQ")+" SZQ,  "
cQuery+="      SIGA."+RETSQLNAME("CC2")+" CC2 "
cQuery+=" WHERE SA2.D_E_L_E_T_    = ' ' "
cQuery+="   AND SZQ.D_E_L_E_T_(+) = ' ' "
cQuery+="   AND SC5.D_E_L_E_T_    = ' ' "
cQuery+="   AND SC6.D_E_L_E_T_    = ' ' "
cQuery+="   AND SB1.D_E_L_E_T_    = ' ' "
cQuery+="   AND SA3.D_E_L_E_T_(+) = ' ' "
cQuery+="   AND SF4.D_E_L_E_T_    = ' ' "
cQuery+="   AND SZH.D_E_L_E_T_(+) = ' ' "
cQuery+="   AND CC2.D_E_L_E_T_(+) = ' ' "
cQuery+="   AND CC2_FILIAL(+) = '" + XFILIAL("CC2") + "' "
cQuery+="   AND C5_FILIAL     = '" + XFILIAL("SC5") + "' "
cQuery+="   AND C6_FILIAL     = '" + XFILIAL("SC6") + "' "
cQuery+="   AND B1_FILIAL     = '" + XFILIAL("SB1") + "' "
cQuery+="   AND BM_FILIAL     = '" + XFILIAL("SB1") + "' "
cQuery+="   AND F4_FILIAL     = '" + XFILIAL("SF4") + "' "
cQuery+="   AND A3_FILIAL(+)  = '" + XFILIAL("SA3") + "' "
cQuery+="   AND A2_FILIAL     = '" + XFILIAL("SA2") + "' "
cQuery+="   AND ZH_FILIAL(+)  = '" + XFILIAL("SZH") + "' "
cQuery+="   AND ZQ_FILIAL(+)  = '" + XFILIAL("SZQ") + "' "
cQuery+="   AND C5_NUM        = C6_NUM "
cQuery+="   AND ZQ_EMBARQ(+)  = C5_XEMBARQ "
cQuery+="   AND CC2_EST(+)    = A2_EST "
cQuery+="   AND CC2_CODMUN(+) = A2_COD_MUN "
cQuery+="   AND BM_GRUPO   = B1_GRUPO "
cQuery+="   AND C5_VEND1   = A3_COD(+)"
cQuery+="   AND C5_CLIENTE = A2_COD "
cQuery+="   AND C5_LOJACLI = A2_LOJA "
cQuery+="   AND C5_XTPSEGM = ZH_SEGMENT "
cQuery+="   AND A2_COD     = ZH_CLIENTE(+) "
cQuery+="   AND A2_LOJA    = ZH_LOJA(+)   "
cQuery+="   AND C6_PRODUTO = B1_COD "
cQuery+="   AND C6_TES     = F4_CODIGO "
cQuery+="   AND C5_TIPO IN ('B','D') "
cQuery+="   AND C5_NUM = '" + cNumPed +"'"

memowrit("c:\getmix.sql",cQuery)
TCQUERY cQuery ALIAS "GMIX" NEW
dbselectarea("GMIX")

do while GMIX->( !eof() )
	
	nTotCusto 	+= GMIX->CUSTTOT
	nTotParc  	+= GMIX->PRTOT
	nVerba  	:= GMIX->C5_XVERREP + GMIX->C5_XVEREXT
	
	//nConta += 1
	//nMix += (GMIX->C6_XPRUNIT-GMIX->C6_XCUSTO)/GMIX->C6_XPRUNIT
	
	GMIX->( dbskip() )
enddo

//nMix := nMix/nConta

nLL     := noround((nTotParc - (nTotParc*nVerba)/100) / nTotCusto,2)
nLL     := noRound(((nLL-1)/nLL)*100)

GMIX->( dbclosearea() )

RestArea( aArea )
Return nLL //nMix

// PEGA O PESO EM KG DO PEDIDO
Static Function FscGetPeso(cNumPed)

Local aArea		:= GetArea()
Local cQuery	:= ""
Local nPeso		:= 0

cQuery	:= "SELECT C6_UM, C6_QTDVEN, B1_PESO FROM "
cQuery	+= RetSqlName("SC6") + " SC6,"
cQuery	+= RetSqlName("SB1") + " SB1 "
cQuery	+= "WHERE "
cQuery  += "   B1_COD = C6_PRODUTO 		"
cQuery  += "   AND SC6.C6_NUM = '" + cNumPed + "'"
cQuery  += "   AND SC6.D_E_L_E_T_ = ' '		"
cQuery  += "   AND SB1.D_E_L_E_T_ = ' '		"
cQuery  += "   AND SC6.C6_FILIAL  = '"+xFilial("SC6")+"'"
cQuery  += "   AND SB1.B1_FILIAL  = '"+xFilial("SB1")+"'"

memowrit("c:\getpeso.sql",cQuery)
TCQUERY cQuery ALIAS "GPESO" NEW
dbselectarea("GPESO")

do while GPESO->( !eof() )
	
	if GPESO->C6_UM == 'KG'
		nPeso += GPESO->C6_QTDVEN
	else
		nPeso += GPESO->C6_QTDVEN*GPESO->B1_PESO
	endIf
	
	GPESO->( dbskip() )
enddo

GPESO->( dbclosearea() )

RestArea( aArea )
Return nPeso

/*--------------------------------------*
 | Func:  GeraCSV()                		|
 | Autor: Vagner Almeida 				|
 | Data:  23/03/2021              		|
 | Desc:  Informações do Caixa			|
 | Parâmetro(s) Recebido(s) : Nenhum	|
 | Parâmetro(s) Retornado(s): Nemhum 	|
 *--------------------------------------*/
Static Function GeraCSV( aLinha )

	Local nHandle	:= 0
	Local cLinha	:= ''
	Local cCabec 	:= ''
	Local nI		:= 0
	Local nX		:= 0
	Local cArquivo	:= 'C:\TEMP\ORTR077B_' + DTOS(date()) +	subst(time(),1,2) + ;
															subst(time(),4,2) + ;
															subst(time(),7,2) + '.csv'
	
	MakeDir('C:\TEMP')
	
	nHandle := fCreate(cArquivo, 0)
	If nHandle == -1
		MsgStop('Erro ao criar arquivo: ' + AllTrim(Str(fError())))
		Return
	Endif
	
	cCabec 	:= "NUM."
	cCabec 	+= ";PCOMPR"
	cCabec 	+= ";PEDIDO"
	cCabec 	+= ";LIB"

	IF MV_PAR34 == 1
		cCabec 	+= ";CD/CM "
	Else
		cCabec 	+= ";    MIX"
	EndIf

	cCabec 	+= ";EMISSAO"
	cCabec 	+= ";LIBERACAO"
	cCabec 	+= ";REVALID"
	cCabec 	+= ";DIAS"
	cCabec 	+= ";ENTREGA"
	cCabec 	+= ";TP"
	cCabec 	+= ";SEG"
	cCabec 	+= ";VEND"
	cCabec 	+= ";CLIENTE"
	cCabec 	+= ";VLR"
	cCabec 	+= ";ZONA CIDADE"
	cCabec 	+= ";ULT.CARG"

	IF MV_PAR34 == 1
		cCabec 	+= ";ESPACOS"
	Else
		cCabec 	+= ";    KG"
	EndIf
	
	cCabec 	+= ";ROT"
	cCabec 	+= ";TAB"

   	fWrite(nHandle, cCabec + CHR(13) + CHR(10))

	For nI := 1 to Len( aLinha ) 
		
		cLinha := ''
		
		For nX := 1 to Len( aLinha[nI] )
		
		 	If nX == 1
		 		cLinha += aLinha[nI][nX]
			Else
		 		cLinha += ';' + aLinha[nI][nX]
			EndIf
			
		Next nX
	
		fWrite(nHandle,cLinha + CHR(13) + CHR(10))

	Next nI

	fClose(nHandle)
	
	MsgAlert("Pasta: 'C:\TEMP' " +  Chr(13) + Chr(10) + "Arquivo: " + Substr( cArquivo,9), "Arquivo Gerado!" )
	
Return()
