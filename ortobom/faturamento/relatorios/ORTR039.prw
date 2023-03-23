#INCLUDE  'RWMAKE.CH'
#INCLUDE 'TOPCONN.CH'

#DEFINE ENTER Chr(13)+Chr(10)

//+-------------------------------------------------------------------------+
//|Funcao      | ORTR039  | Autor |  Marcos Furtado                         |
//+------------+------------------------------------------------------------+
//|Data        | 11.05.2006                                                 |
//+------------+------------------------------------------------------------+
//|Descricao   | Relatório de Conferencia Carga Individual                  |
//|            |                                                            |
//+---------------------------------------+------+--------------------------+
//|Alterado por|Marcos Furtado            | Data |	12/09/2013              |
//+---------------------------------------+------+--------------------------+
//|Descricao   |Retirado de utilização o parâmetro MV_XTESNCA. Foi criada   |
//|            |a tabela TESNCA+cEmpAnt contendo todos os tes de NCA.       |
//+-------------------------------------------------------------------------+
//|Alterado por|Henrique Antonio          | Data |	23/05/2014              |
//+---------------------------------------+------+--------------------------+
//|Descricao   |Inibida a linha que excluia da query os clientes EX para o  |
//|            |valor de Destruicao.                                        |
//|            |SSI 1759.                                                   |
//+-------------------------------------------------------------------------+
//|Alterado por|Henrique Antonio          | Data |	16/09/2014              |
//+---------------------------------------+------+--------------------------+
//|Descricao   |SSI - 2392 - Incluido o valor da ST no valor da carga. Con- |
//|            |firmado com a Núbia.                                        |
//+-------------------------------------------------------------------------+
//|Alterado por|Gustavo Thees Castro      | Data |	11/12/2014              |
//+---------------------------------------+------+--------------------------+
//|Descricao   |SSI - 5520 - Alteracao de lay-out.                          |
//|            |           - Acrescentadas as informações:                  |
//|            |             - Adiantamento de Frete,                       |
//|            |             - Frete a Pagar.                               |
//+-------------------------------------------------------------------------+
//|Alterado por|Gustavo Thees Castro      | Data |	15/01/2015              |
//+---------------------------------------+------+--------------------------+
//|Descricao   |SSI - 8201 - Alteracao de lay-out.                          |
//|            |               - Quantidade de linhas diminuida,            |
//|            |                 para caber em 1 (uma) página,              |
//|            |               - Linhas de assinaturas impressas            |
//|            |                 em todas as páginas.                       |
//+-------------------------------------------------------------------------+

***********************
User Function ORTR039()
***********************

Private cPict       := ""
Private titulo      := "CONFERENCIA DE CARGA INDIVIDUAL"
Private Cabec1      := ""
Private Cabec2      := ""
Private imprime     := .T.
Private aOrd        := {}
Private cDesc1      := "USUARIO       : ALMOXARIFE, EXPEDIDOR                      "
Private cDesc2      := "OBJETIVO      : Conferencia Acerto  - Individual           "
Private cDesc3      := "PER.UTILIZACAO: DIARIA                                     "
Private lEnd        := .F.
Private lAbortPrint := .F.
Private CbTxt       := ""
Private limite      := 80
Private tamanho     := "P"
Private nomeprog    := "ORTR039"
Private nTipo       := 15
Private aReturn     := { "Zebrado", 1, "Administracao", 1, 2, 1, "", 1}
Private nLastKey    := 0
Private m_pag       := 1
Private wnrel       := "ORTR039"
Private cPerg       := "ORTR39"
Private cString     := "SE1"
Private lImp        := .F.
Private nEsp        := 50
Private nLin        := 3200
Private npag        := 1
Private nPisCof     := 0
Private oPrn,oFont1

dbSelectArea("SM0")
dbSeek(cEmpAnt)
cNomFil := SM0->M0_FILIAL

//	Totalizadores do rodapé
ValidPerg(cPerg)
Pergunte(cPerg, .T.)

DbSelectArea("SE1")
dbOrderNickName("PSE11")

oFont1:=   TFont():New("Courier New",,14,,.T.)
oFont2:=   TFont():New("Courier New",,11,,.T.)
oFont3:=   TFont():New("Courier New",,18,,.T.)
oPrn  := TReport():New("0RTR039",Titulo,,{|oPrn| GeraRel(oPrn)},titulo)
oPrn:PrintDialog()

Return

// ------------------------------------------------------------------
*****************************
Static Function GeraRel(oPrn)
*****************************

Local   cQuery     :=""
Local   cTipo      :=""
local   nCol       := 0
Local   lNPid      := .F.

Private nVlFrete   := 0
Private nTotItem   := 0
Private nTotVlr    := 0
Private nSubVlr    := 0
Private nTotEmb    := 0
Private nTotGer    := 0
Private nTotChDp   := 0
Private nTotDin    := 0
Private nTotDinAtc := 0
Private nTotChC    := 0
Private nTotLoja   := 0
Private nTotChCT   := 0
Private nTotChDT   := 0
Private nTotChAtc  := 0
Private nTotCC     := 0
Private nTotCD	   := 0 // [BRUNO:11/02/2011]
Private nTotDP     := 0
Private nTotPA     := 0
Private nTotTR     := 0
Private nTotDev    := 0
Private nTotNca    := 0
Private nTotJrs    := 0
Private nTotBon    := 0
Private nTotRep    := 0
Private nTotAju    := 0
Private nTotDif    := 0
Private nTotPrz    := 0
Private nTotChCD   := 0
Private nTotNp     := 0
Private nTotPen    := 0
Private nTotDC     := 0 // Duplicatas consignado
Private nTotCons   := 0 // Conserto
Private nTotInd	   := 0 // Industrializacao
Private nTotDevFor := 0 // Devolucao de Fornecedor
Private nTotDevMEM := 0 // Devolucao Tipo Memo

Dbselectarea("SE1")
ValCarga()
cQuery:=" SELECT ZQ_EMBARQ,      "
cQuery+="        SZQ.ZQ_TRANSP,  "
cQuery+="        SZQ.ZQ_PERFRET, "
cQuery+="        SZQ.ZQ_KILOMET, "
cQuery+="        SZQ.ZQ_VALORKM, "
cQuery+="        SZQ.ZQ_VALORSA, "
cQuery+="        SZQ.ZQ_DTEMBAR, "
cQuery+="        SZQ.ZQ_VALOR,   "
cQuery+="        SZQ.ZQ_ESPACO,  "
cQuery+="        SZQ.ZQ_TPCARGA, "
cQuery+="        SZQ.ZQ_VALFRET, "
cQuery+="        SZQ.ZQ_VLFRPG,  "
// -[ SSI 5520 - Início ]--------------------------------------------
cQuery+="        SZQ.ZQ_ADIANT,  "
// -[ SSI 5520 - Fim ]-----------------------------------------------
cQuery+="        SZQ.ZQ_PRACA,   "
cQuery+="        SZQ.ZQ_PEDAGIO, "	//SSI 18055 - Marcos Furtado
cQuery+="        SA4.A4_NOME,    "
cQuery+="        SA4.A4_XESPACO, "
cQuery+="        SA4.A4_XAJUDAN, " && Henrique - 25/09/2013 - SSI 30837
cQuery+="        SC5.C5_XACERTO, " //Geraldo - 14/01/2019 - SSI 73715
cQuery+="        SC5.C5_XOPER, "   //Marcelo - 25/10/2021 - SSI 100079"
cQuery+="        sum(nvl((SELECT (CASE WHEN C5_XOPER = '18' THEN sum(D2_VALIMP5 + D2_VALIMP6 + D2_VALCSL) ELSE 0 END) IMP "
cQuery+="                 FROM Siga."           + RETSQLNAME("SD2") + "  "
cQuery+="                 WHERE D_E_L_E_T_ = ' '   "
cQuery+="                    AND D2_FILIAL = '" +    xFilial("SD2") + "' "
cQuery+="                    AND D2_PEDIDO = C5_NUM), "
cQuery+="            0)) PISCOF       "
cQuery+=" FROM Siga."+RetSQLName("SZQ")+" SZQ, "
cQuery+="      Siga."+RetSQLName("SA4")+" SA4, "
cQuery+="      Siga."+RetSQLName("SC5")+" SC5  "
cQuery+="     WHERE SC5.D_E_L_E_T_ = ' '  "
cQuery+="       AND SC5.C5_FILIAL  = '" + xFilial("SC5")  +"' "
If MV_PAR05 == '50'
	cQuery+="  AND SZQ.ZQ_EMBARQ  >= '500000' "
ElseIf MV_PAR05 <> '99' .And. MV_PAR05 <> '50'
	cQuery+="  AND SZQ.ZQ_EMBARQ  < '500000' "
EndIF
cQuery+="  AND C5_XEMBARQ     BETWEEN '" +      MV_PAR03  + "' "
cQuery+="  AND                        '" +      MV_PAR04  + "' "
cQuery+="  AND SC5.C5_XACERTO BETWEEN '" + DTOS(MV_PAR01) + "' "
cQuery+="  AND                        '" + DTOS(MV_PAR02) + "' "
cQuery+="  AND SZQ.D_E_L_E_T_    =  ' ' "
cQuery+="  AND SA4.D_E_L_E_T_(+) =  ' ' "
cQuery+="  AND SZQ.ZQ_FILIAL     =  '" + xFilial("SZQ")  + "' "
cQuery+="  AND SA4.A4_FILIAL(+)  =  '" + xFilial("SA4")  + "' "
cQuery+="  AND SZQ.ZQ_EMBARQ  BETWEEN '"    + MV_PAR03   + "' "
cQuery+="  AND                           '" + MV_PAR04   + "' "
cQuery+="  AND C5_XEMBARQ        = ZQ_EMBARQ "
cQuery+="  AND ZQ_TRANSP         = A4_COD(+) "
cQuery+=" group by ZQ_EMBARQ,      "
cQuery+="          SZQ.ZQ_TRANSP,  "
cQuery+="          SZQ.ZQ_PERFRET, "
cQuery+="          SZQ.ZQ_KILOMET, "
cQuery+="          SZQ.ZQ_VALORKM, "
cQuery+="          SZQ.ZQ_VALORSA, "
cQuery+="          SZQ.ZQ_DTEMBAR, "
cQuery+="          SZQ.ZQ_VALOR,   "
cQuery+="          SZQ.ZQ_ESPACO,  "
cQuery+="          SZQ.ZQ_TPCARGA, "
cQuery+="          SZQ.ZQ_VALFRET, "
cQuery+="          SZQ.ZQ_VLFRPG,  "
// -[ SSI 5520 - Início ]--------------------------------------------
cQuery+="          SZQ.ZQ_ADIANT,  "
// -[ SSI 5520 - Fim ]-----------------------------------------------
cQuery+="        SZQ.ZQ_PEDAGIO,   "	//SSI 18055 - Marcos Furtado
cQuery+="          SZQ.ZQ_PRACA,   "
cQuery+="          SA4.A4_NOME,    "
cQuery+="          SA4.A4_XESPACO, "
cQuery+="          SA4.A4_XAJUDAN, " && Henrique - 25/09/2013 - SSI 30837
cQuery+="          SC5.C5_XACERTO, " //Geraldo - 14/01/2019 - SSI 73715
cQuery+="          SC5.C5_XOPER    " //Marcelo - 25/10/2021 - SSI 100079
cQuery+=" ORDER BY ZQ_EMBARQ "
MemoWrite("C:\ortr039a.sql", cQuery)

If Select("QRY") > 0
	dbSelectArea("QRY")
	dbCloseArea()
EndIf

oPrn:SetPortrait()
oPrn:HideHeader()
oPrn:HideFooter()

TcQuery cQuery New Alias "QRY"

QRY->(DbGoTop())
If QRY->(Eof())
	QRY->(DbCloseArea())
	MsgBox("Nao ha Dados a serem impressos para este relatorio","Aviso","INFO")
	Return()
EndIf

SetPrc(0,0)
While !QRY->(EOF())
	nVlFrete   := nTotItem := nSubVlr  := nTotVlr    := nTotEmb := 0
	nTotGer    := nTotChDp := nTotDin  := nTotDinAtc := nTotChC := 0
	nTotLoja   := nTotChCT := nTotChDT := nTotChAtc  := nTotCC  := 0
	nTotDP     := nTotPA   := nTotTR   := nTotDev    := nTotNca := 0
	nTotJrs    := nTotBon  := nTotRep  := nTotAju    := nTotDif := 0
	nTotPrz    := nTotChCD := nTotNp   := nTotPen    := nTotDC  := 0 // Duplicatas consignado
	nTotDes    := 0
	nTotCD	   := 0 // [BRUNO:11/02/2011]
	nTotCons   := 0 // [BRUNO:17/05/2011]
	nTotInd    := 0 // [BRUNO:17/05/2011]
	nTotDevFor := 0 // [BRUNO:17/05/2011]
	nTotDevMem := 0
	
	If nLin > 2800
		ImpCab(oPrn)
	endif
	
	oPrn:Say(nLin,0000,"Nro do Termo:",oFont1)
	oPrn:Say(nLin-20,00340,SubStr(QRY->ZQ_EMBARQ,1,3)+"."+;
	SubStr(QRY->ZQ_EMBARQ,4,3),oFont3)
	nLin += nEsp
	nLin += nEsp
	
	oPrn:Say(nLin,0000,Space(10)+QRY->ZQ_TRANSP+"-"+QRY->A4_NOME,oFont1)
	oPrn:Say(nLin,0000,Space(60)+DtoC(StoD(QRY->C5_XACERTO)),oFont1)
	//		oPrn:Say(nLin,0000,Space(60)+Posicione("SC5",5,xfilial('SC5')+qry->zq_embarq,'dtoc(c5_xacerto)'),oFont1) // Rocha 19/05/07 Stod(QRY->ZQ_DTEMBAR)
	//		nLin +=nEsp // gus -new
	
	oPrn:Say(nLin,0000,Space(10)+"___________________________________",oFont1)
	oPrn:Say(nLin,0000,Space(59)+"__________",oFont1)
	nLin +=nEsp
	
	oPrn:Say(nLin,0000,Space(10)+Padc("Motorista",30),oFont1)
	oPrn:Say(nLin,0000,Space(60)+"  Data  ",oFont1)
	nLin +=nEsp
	//		nLin +=nEsp // gus - new
	
	If ! Empty(QRY->A4_XAJUDAN)
		oPrn:Say(nLin+049,0000,Space(25)+"Ajudante:" + QRY->A4_XAJUDAN,oFont2)  && Henrique - 25/09/2013 - SSI 30837
	EndIf
	nLin +=nEsp
	
	nValST  := fValST(QRY->ZQ_EMBARQ) && Henrique - 16/09/2014 - SSI 2392
	nTotRec := RetValorRec(QRY->ZQ_EMBARQ)
	nTotDev := RetDev(QRY->ZQ_EMBARQ)
	nTotDES := RetDes(QRY->ZQ_EMBARQ)
	//nTotDev += nTotDES      // considerando o valor de destruição como devolução.
	nPisCof := QRY->PISCOF  // Pis/Confins para as Notas de Serviço
	
	oPrn:Say(nLin,0000,"Valor recebido : " + Transform(nTotRec+nTotDev+nTotDES,"@e 999,999,999.99"),oFont1)
	
	nTotNca := RetNca(QRY->ZQ_EMBARQ)
	oPrn:Say(nLin,0000,Space(40)+"Nao carregado  : " + Transform(nTotNca ,"@e 999,999,999.99"),oFont1)
	nLin +=nEsp
	
	//		oPrn:Say(nLin,0000,"Valor da Carga : " + Transform(nValST + QRY->ZQ_VALOR-nPisCof ,"999,999,999.99"),oFont1)
	oPrn:Say(nLin,0000,"Valor da Carga : " + Transform(nValST + QRY->ZQ_VALOR,"@e 999,999,999.99"),oFont1)
	nLin +=nEsp
	
	oPrn:Say(nLin,0000,"Nfs Canceladas : " + Transform(0,"@e 999,999,999.99"),oFont1)
	nLin +=nEsp
	
	oPrn:Say(nLin,0000,Space(40)+"Valor Real     : " + Transform(nTotRec + nTotNca + nTotDev +nTotDES ,"@e 999,999,999.99"),oFont1)
	nLin +=nEsp
	
	//		oPrn:Say(nLin,0000,"Diferenca      : " + Transform(nTotRec + nTotNca + nTotDev +nTotDES - nValST - (QRY->ZQ_VALOR-nPisCof),"@e 999,999,999.99"),oFont1)
	oPrn:Say(nLin,0000,"Diferenca      : " + Transform(nTotRec + nTotNca + nTotDev +nTotDES - nValST - QRY->ZQ_VALOR,"@e 999,999,999.99"),oFont1)
    If cEmpAnt == "21"
	   oPrn:Say(nLin,0000,Space(40)+"Tipo de Carga  : " + Posicione("SX5",1,xFilial("SX5")+"ZO"+QRY->ZQ_TPCARGA,"X5_DESCRI"),oFont1)
	Else
	   oPrn:Say(nLin,0000,Space(40)+"Tipo de Carga  : " + Posicione("SX5",1,xFilial("SX5")+"PO"+QRY->ZQ_TPCARGA,"X5_DESCRI"),oFont1)
    EndIf	   
	nLin +=nEsp
	
	oPrn:Say(nLin,0000,"Espacos        : " + Transform( Iif( !( AllTrim( QRY->C5_XOPER ) $ "04/23" ), QRY->ZQ_ESPACO, 0 ),"@e 999,999,999.99"),oFont1) // Marcelo - 25/10/2021 - SSI 100079

	If QRY->A4_XESPACO > 0 .And. !( AllTrim( QRY->C5_XOPER ) $ "04/23" )  // Marcelo - 25/10/2021 - SSI 100079
		oPrn:Say(nLin,0000,Space(40)+"% Ocupacao     : " + Transform(round((QRY->ZQ_ESPACO/QRY->A4_XESPACO)*100,2),"999.99"),oFont1)
	Else
		oPrn:Say(nLin,0000,Space(40)+"% Ocupacao     : 0",oFont1)
	endif
	nLin +=nEsp
	nLin +=nEsp
	
	nTotJrs := RetJrs(QRY->ZQ_EMBARQ)
	oPrn:Say(nLin,0000,"Juros          : "  + Transform(nTotJrs,"@e 999,999,999.99"),oFont1)
	
	cUsuAce := RetUsu(QRY->ZQ_EMBARQ)
	oPrn:Say(nLin,0000,Space(40)+"Operador.......: "  +cUsuAce,oFont1)
	nLin +=nEsp
	nLin +=nEsp
	
	//		oPrn:Say(nLin,0000,"ACERTO: PROPRIETARIO (  )     MOTORISTA (  ) ",oFont1) // gus - new
	//		nLin +=nEsp                                                                // gus - new
	//		nLin +=nEsp                                                                // gus - new
	
	cPropri := ""
	cPropri := POSICIONE("SA4",1,xFilial("SA4")+QRY->ZQ_TRANSP,"A4_XCODPRP")
	oPrn:Say(nLin,0000,"NOME DO PROPRIETARIO     : "  + cPropri + "-" + Posicione("PB7",1,xFilial("PB7")+cPropri,"PB7_NOME"),oFont1)
	nLin +=nEsp
	
	oPrn:Say(nLin,0000,"ESPACOS DO CAMINHAO      :" + Transform(POSICIONE("SA4",1,xFilial("SA4")+QRY->ZQ_TRANSP,"SA4->A4_XESPACO"),"@e 999,999,999.99"),oFont1)
	nLin +=nEsp
	nLin +=nEsp
	
	nTotDin := RetVal(QRY->ZQ_EMBARQ,"DH")
	nSubVlr := nSubVlr + nTotDin
	oPrn:Say(nLin,0000,"DINHEIRO.................: " + Transform(nTotDin  ,"@e 999,999,999.99"),oFont1)
	nLin +=nEsp
	
	nTotCC  := RetVal(QRY->ZQ_EMBARQ,"CC")
	nSubVlr := nSubVlr + nTotCC
	oPrn:Say(nLin,0000,"CARTAO DE CREDITO........: " + Transform(nTotCC   ,"@e 999,999,999.99"),oFont1)
	nLin +=nEsp
	
	nTotCD  := RetVal(QRY->ZQ_EMBARQ,"CD")
	nSubVlr := nSubVlr + nTotCD
	oPrn:Say(nLin,0000,"CARTAO DE DEBITO.........: " + Transform(nTotCD   ,"@e 999,999,999.99"),oFont1)
	nLin +=nEsp
	
	nTotChAtc := RetChqAtc(QRY->ZQ_EMBARQ)
	nSubVlr   := nSubVlr + nTotChatc
	oPrn:Say(nLin,0000,"CHEQUE ANTECIPADO........: " + Transform(nTotChAtc,"@e 999,999,999.99"),oFont1)
	nLin +=nEsp
	
	nTotChD := RetVal(QRY->ZQ_EMBARQ,"CHD")
	nSubVlr := nSubVlr + nTotChD
	oPrn:Say(nLin,0000,"CHEQUES DIA..............: " + Transform(nTotChD  ,"@e 999,999,999.99"),oFont1)
	nLin +=nEsp
	
	nTotChC := RetVal(QRY->ZQ_EMBARQ,"CHC")
	nSubVlr := nSubVlr + nTotChC
	oPrn:Say(nLin,0000,"CHEQUES CARTEIRA.........: " + Transform(nTotChC  ,"@e 999,999,999.99"),oFont1)
	nLin +=nEsp
	
	nTotDP  := RetVal(QRY->ZQ_EMBARQ,"DP")
	nSubVlr := nSubVlr + nTotDP
	oPrn:Say(nLin,0000,"DUPLICATAS...............: " + Transform(nTotDP   ,"@e 999,999,999.99"),oFont1)
	nLin +=nEsp
	
	nTotDP  := RetVal(QRY->ZQ_EMBARQ,"DPC")
	nSubVlr := nSubVlr + nTotDP
	oPrn:Say(nLin,0000,"DUPLICATAS CARTEIRA......: " + Transform(nTotDP   ,"@e 999,999,999.99"),oFont1)
	nLin +=nEsp
	
	nTotNp  := RetVal(QRY->ZQ_EMBARQ,"NP")
	nSubVlr := nSubVlr + nTotNp
	oPrn:Say(nLin,0000,"NOTAS PROMISSORIAS.......: " + Transform(nTotNp   ,"@e 999,999,999.99"),oFont1)
	nLin +=nEsp
	
	nTotDc  := RetDupCgn(QRY->ZQ_EMBARQ)
	nSubVlr := nSubVlr + nTotDc
	oPrn:Say(nLin,0000,"DUPLICATAS CONSIGNACAO...: " + Transform(nTotDc   ,"@e 999,999,999.99"),oFont1)
	nLin +=nEsp
	
	nTotPen := RetVal(QRY->ZQ_EMBARQ,"PEN")
	nSubVlr := nSubVlr + nTotPen
	oPrn:Say(nLin,0000,"DUPLICATAS P.............: " + Transform(nTotPen  ,"@e 999,999,999.99"),oFont1)
	nLin +=nEsp
	
	oPrn:Say(nLin,0000,"SUBTOTAL.................: " + Transform(nSubVlr  ,"@e 999,999,999.99"),oFont1)
	nTotVlr := nTotVlr + nSubVlr
	nSubVlr := 0
	nLin +=nEsp
	nLin +=nEsp
	
	// ------------------------------------------------------------------
	
	nTotTR     := RetTroca(QRY->ZQ_EMBARQ)
	nSubVlr    := nSubVlr + nTotTR
	oPrn:Say(nLin,0000,"TROCA....................: " + Transform(nTotTR    ,"@e 999,999,999.99"),oFont1)
	nLin +=nEsp
	
	nSubVlr    := nSubVlr + nTotDev
	oPrn:Say(nLin,0000,"DEVOLUCOES...............: " + Transform(nTotDev   ,"@e 999,999,999.99"),oFont1)
	nLin +=nEsp
	
	nSubVlr    := nSubVlr + nTotDES
	oPrn:Say(nLin,0000,"DESTRUICAO...............: " + Transform(nTotDES   ,"@e 999,999,999.99"),oFont1)
	nLin +=nEsp
	
	nTotCons   := RetOutros(QRY->ZQ_EMBARQ,"09")
	nSubVlr    := nSubVlr + nTotCons
	oPrn:Say(nLin,0000,"REMESSA P/ CONSERTO......: " + Transform(nTotCons  ,"@e 999,999,999.99"),oFont1)
	nLin +=nEsp
	
	nTotInd    := RetOutros(QRY->ZQ_EMBARQ,"25")
	nSubVlr    := nSubVlr + nTotInd
	oPrn:Say(nLin,0000,"REMESSA P/ COMODATO......: " + Transform(nTotInd   ,"@e 999,999,999.99"),oFont1)
	nLin +=nEsp
	
	nTotRco    := RetOutros(QRY->ZQ_EMBARQ,"23")
	if cEmpAnt<>"07"
		nSubVlr    := nSubVlr + nTotRco
	Endif
	oPrn:Say(nLin,0000,"REMESSA P/ CONTA E ORDEM.: " + Transform(nTotRco   ,"@e 999,999,999.99"),oFont1)
	nLin +=nEsp
	
	nTotDevFor := RetOutros(QRY->ZQ_EMBARQ,"06")
	nSubVlr    := nSubVlr + nTotDevFor
	oPrn:Say(nLin,0000,"REMESSA P/ FORNECEDOR....: " + Transform(nTotDevFor,"@e 999,999,999.99"),oFont1)
	nLin +=nEsp
	
	nTotDevMem := RetDevMEM(QRY->ZQ_EMBARQ)
	nSubVlr    := nSubVlr + nTotDevMem
	//		nTotVlr    := nTotVlr + nSubVlr
	oPrn:Say(nLin,0000,"DEVOLUCOES(MEMO EM ANEXO): " + Transform(nTotDevMem,"@e 999,999,999.99"),oFont1)
	nLin +=nEsp

	// -----[ SSI 5520 - Início ]----------------------------------------
	// -----[ Alteracao de lay-out, a pedido da Sra. Nubia. ]
	// ------------------------------------------------------------------
	//		oPrn:Say(nLin,0000,"SUBTOTAL.................: " + Transform(nSubVlr,"@e 999,999,999.99"),oFont1)
	//		nLin +=nEsp
	//
	//		oPrn:Say(nLin,0000,"TOTAL....................: " + Transform(nTotVLr,"@e 999,999,999.99"),oFont1)
	//		nLin +=nEsp
	// -----[ SSI 5520 - Fim ]-------------------------------------------
	
	nTotBon    := RetBonif(QRY->ZQ_EMBARQ)
	nSubVlr    := nSubVlr + nTotBon
	//		nTotVlr    := nTotVlr + nTotBon
	oPrn:Say(nLin,0000,"BONIFICACOES.............: " + Transform(nTotBon ,"@e 999,999,999.99"),oFont1)
	nLin +=nEsp
	
	nTotRep    := RetOutros(QRY->ZQ_EMBARQ,"08")
	nSubVlr    := nSubVlr + nTotRep
	//		nTotVlr := nTotVlr + nTotRep
	oPrn:Say(nLin,0000,"REPOSICAO................: " + Transform(nTotRep ,"@e 999,999,999.99"),oFont1)
	nLin +=nEsp
	
	nTotLoja   := RetLoja(QRY->ZQ_EMBARQ)
	nSubVlr    := nSubVlr + nTotLoja
	//		nTotVlr    := nTotVlr + nTotLoja
	oPrn:Say(nLin,0000,"LOJA.....................: " + Transform(nTotLoja,"@e 999,999,999.99"),oFont1)
	nLin +=nEsp
	
	// -----[ SSI 5520 - Início ]----------------------------------------
	// -----[ Alteracao de lay-out, a pedido da Sra. Nubia. ]
	// ------------------------------------------------------------------
	oPrn:Say(nLin,0000,"SUBTOTAL.................: " + Transform(nSubVlr ,"@e 999,999,999.99"),oFont1)
	nLin +=nEsp
	nLin +=nEsp
	
	nTotVlr    := nTotVlr + nSubVlr
	oPrn:Say(nLin,0000,"TOTAL GERAL..............: " + Transform(nTotVlr ,"@e 999,999,999.99"),oFont1)
	nLin +=nEsp
	nLin +=nEsp
	
	// -----[ SSI 5520 - Fim ]-------------------------------------------
	
	nTotRec  := PedRec(QRY->ZQ_EMBARQ)
	nPisCof  := QRY->PISCOF
	cPedRecN := fPRecNum(QRY->ZQ_EMBARQ)
	
	oPrn:Say(nLin,0000,"PEDIDO RECEBEDOR.........: " + Transform(nTotRec ,"@e 999,999,999.99"),oFont1)
	oPrn:Say(nLin,0000,Space(42)+cPedRecN,oFont1)
	nLin +=nEsp
	
	nVlFrete := QRY->ZQ_VLFRPG
	oPrn:Say(nLin,0000,"FRETE....................: " + Transform(nVlFrete,"@e 999,999,999.99"),oFont1)
	nLin +=nEsp
	
	// -----[ SSI 5520 - Início ]----------------------------------------
	oPrn:Say(nLin,0000,'ADIANTAMENTO DE FRETE....: ' + Transform(            QRY->ZQ_ADIANT ,'@e 999,999,999.99'),oFont1)
	nLin +=nEsp
	//SSI 18055 - Marcos Furtado
	oPrn:Say(nLin,0000,'PEDAGIO..................: ' + Transform(            QRY->ZQ_PEDAGIO ,'@e 999,999,999.99'),oFont1)
	nLin +=nEsp
	oPrn:Say(nLin,0000,'FRETE A PAGAR............: ' + Transform((nVlFrete - QRY->ZQ_ADIANT - QRY->ZQ_PEDAGIO),'@e 999,999,999.99'),oFont1)
	nLin +=nEsp
	// -----[ SSI 5520 - Fim ]-------------------------------------------
	
	oPrn:Say(nLin,0000,"KMs RODADOS..............: " + Transform(IIf(cEmpAnt=="21",0,QRY->ZQ_KILOMET),"@e 999,999,999.99"),oFont1)
	nLin +=nEsp
	
	oPrn:Say(nLin,0000,"% FRETE..................: " + Transform(ROUND((nVlFrete / QRY->ZQ_VALOR) * 100,2),"@e 999,999,999.99"),oFont1)
	nLin +=nEsp
	nLin +=nEsp
	
	oPrn:Say(nLin,0000,"CODIGO DE AREA...........: " + QRY->ZQ_PRACA,oFont1)
	
	nLin += nEsp+170
	oPrn:Say ( nLin , 030, "_______________________            _______________________             _______________________", oFont1)
	nLin += nEsp
	oPrn:Say ( nLin , 030, "  AUXILIAR DO ACERTO                ENCARREGADO DO ACERTO                GERENTE FINANCEIRO   ", oFont1)
	
	QRY->(Dbskip())
End

//	nLin += nEsp+170
//	oPrn:Say ( nLin , 030, "_______________________            _______________________             _______________________", oFont1)
//	nLin += nEsp
//	oPrn:Say ( nLin , 030, "  AUXILIAR DO ACERTO                ENCARREGADO DO ACERTO                GERENTE FINANCEIRO   ", oFont1)

If nTotItem > 0
	ImpTotal(2) // Imprime Totais do movimento do NPID
EndIF

QRY->(DbCloseArea())

SET DEVICE TO SCREEN
If aReturn[5]==1
	DbCommitAll()
	SET PRINTER TO
	OurSpool(wnrel)
Endif
Ms_Flush()

Return

// ------------------------------------------------------------------
***************************
Static Function ValidPerg()
***************************

Local aAreaAtu := GetArea()
Local aRegs    := {}
Local i,j

Aadd(aRegs,{cPerg,"01","Data Producao de: ","","","mv_ch1","D",08,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aRegs,{cPerg,"02","Data Producao ate:","","","mv_ch2","D",08,0,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aRegs,{cPerg,"03","Embarque De:      ","","","mv_ch3","C",06,0,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aRegs,{cPerg,"04","Embarque Ate:     ","","","mv_ch4","C",06,0,0,"G","","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aRegs,{cPerg,"05","No. de Copias:    ","","","mv_ch5","C",02,0,0,"C","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","",""})

//  Cria Pergunta
cPerg := U_AjustaSx1(cPerg,aRegs)

RestArea(aAreaAtu)

Return(.T.)

// ------------------------------------------------------------------
*********************************
Static Function RetDev(cEmbarque)
*********************************

Local nValor := 0
Local cQry   := ""
/*
cQry+=" SELECT SUM(CASE WHEN C5_XVALENT > 0 THEN ROUND((VALPED-C5_XVALENT)*(TOTDEV/VALNF),2) ELSE TOTDEV END) VALDEV "
cQry+=" FROM (SELECT "
cQry+="              SUM(("
cQry+="  (select sum(d1_quant) From Siga."+ RetSqlName("SD1") + " SD1"
cQry+="   WHERE SD1.D_E_L_E_T_  = ' '                  "
cQry+="   AND SD1.D1_FILIAL   = '"+xFilial("SD1")+"' "
//	cQry+="   AND SD1.D1_FILIAL   IN ('01','02') "
cQry+="   AND SD1.D1_NFORI    = D2_DOC           "
cQry+="   AND SD1.D1_SERIORI  = D2_SERIE         "
cQry+="   AND SD1.D1_COD      = D2_COD           "
cQry+="   and D1_TES  NOT IN "
cQry+="   (Select TES From siga.TESNCA"+cEMPANT+"0 ) "
cQry+="   AND SD1.D1_ITEMORI  = D2_ITEM          "
cQry+="   AND SD1.D1_FORNECE  = D2_CLIENTE       "
cQry+="   AND SD1.D1_LOJA     = D2_LOJA          "
cQry+="   AND SD1.D1_EMISSAO  <= C5_XACERTO          "
cQry+="   AND SD1.D1_DTDIGIT  <= C5_XACERTO)          "
cQry+="                  / DECODE(D2_QUANT,0,1,D2_QUANT)) * (D2_TOTAL + D2_VALIPI + D2_ICMSRET)) TOTDEV, "
cQry+="              SUM(D2_TOTAL+D2_VALIPI+D2_ICMSRET) VALNF,         "
cQry+="              SUM((C6_XPRUNIT*C6_QTDVEN)+ DECODE(C5_XDESPRO,3,D2_VALIPI,0) + D2_ICMSRET) VALPED, C5_XVALENT, C5_NUM  "
cQry+="       FROM  (SELECT D2_TOTAL, D2_VALIPI, D2_ICMSRET, D2_QTDEDEV, D2_QUANT, C6_XPRUNIT, C6_QTDVEN, C5_XVALENT, C5_NUM, D2_DOC, D2_SERIE, D2_COD, D2_ITEM, "
cQry+="                     D2_CLIENTE, D2_LOJA, C5_XACERTO, C5_XDESPRO                      "
cQry+="                FROM Siga."+RetSQLName("SD2")+" SD2, "
cQry+="                     Siga."+RetSQLName("SC6")+" SC6, "
cQry+="                     Siga."+RetSQLName("SC5")+" SC5  "
cQry+="               WHERE SD2.D_E_L_E_T_ = ' '                  "
cQry+="                 AND SC5.D_E_L_E_T_ = ' '                  "
cQry+="                 AND SC6.D_E_L_E_T_ = ' '                  "
cQry+="                 AND SC6.C6_FILIAL  = '"+xFilial("SC6")+"' "
cQry+="                 AND SC5.C5_FILIAL  = '"+xFilial("SC5")+"' "
//	cQry+="                 AND SD2.D2_FILIAL  IN ('01','02') "
cQry+="                 AND SD2.D2_FILIAL  = '"+xFilial("SD2")+"' "
cQry+="                 AND SC5.C5_NUM	   = SD2.D2_PEDIDO		 "
cQry+="                 AND SC6.C6_NUM	   = SD2.D2_PEDIDO		 "
cQry+="                 AND SC6.C6_ITEM	   = SD2.D2_ITEMPV		 "
cQry+="                 AND SC5.C5_XEMBARQ = '"+cEmbarque+"')      "
cQry+="   GROUP BY C5_XVALENT, c5_num)      "                       
*/

cQry:="SELECT VALDEV+VALDEVL VALDEV  FROM CARGA"+cEmpAnt+"0 WHERE CARGA = '"+cEmbarque     +"' AND FILIAL = '"+cFilAnt+"' "

If Select("TRBEMB") > 0 ; TRBEMB->(DbCloseArea()) ; Endif

MemoWrite("C:\ortr039b.sql", cQry)

TcQuery cQry Alias "TRBEMB" New
TRBEMB->(DbGoTop())
nValor := TRBEMB->VALDEV
If Select("TRBEMB") > 0 ; TRBEMB->(DbCloseArea()) ; Endif

Return(nValor)

// ------------------------------------------------------------------
*********************************
Static Function RetNca(cEmbarque)
*********************************

Local nValor := 0
Local cQry   := ""
/*
cQry+=" SELECT SUM(CASE "
cQry+="			  WHEN C5_XVALENT > 0 THEN "
cQry+="			  	ROUND((VALPED-C5_XVALENT)*(TOTDEV/VALNF),2) "
cQry+="			  ELSE 					"
cQry+="			  	TOTDEV 				"
cQry+="			  END) VALDEV 			"
cQry+="   FROM (SELECT SUM(((SELECT SUM(D1_QUANT) 			 "
cQry+=" 					   FROM Siga."+ RetSqlName("SD1") + " SD1 "
cQry+="   					   WHERE SD1.D_E_L_E_T_  = ' '                  "
cQry+="   					   AND SD1.D1_FILIAL   = '"+xFilial("SD1")+"' "
cQry+="   					   AND SD1.D1_NFORI    = D2_DOC           "
cQry+="   					   AND SD1.D1_SERIORI  = D2_SERIE         "
cQry+="   					   AND SD1.D1_COD      = D2_COD           "
cQry+="   					   AND D1_TES  IN (Select TES From siga.TESNCA"+cEMPANT+"0 ) "
cQry+="   					   AND SD1.D1_ITEMORI  = D2_ITEM          "
cQry+="   					   AND SD1.D1_FORNECE  = D2_CLIENTE       "
cQry+="   					   AND SD1.D1_LOJA     = D2_LOJA          "
cQry+="   					   AND SD1.D1_EMISSAO  <= C5_XACERTO      "
cQry+="   					   AND SD1.D1_DTDIGIT  <= C5_XACERTO) /   "
cQry+="                   DECODE(D2_QUANT,0,1,D2_QUANT)) * (D2_TOTAL + D2_VALIPI + D2_ICMSRET)) TOTDEV, "
cQry+="              	  SUM(D2_TOTAL+D2_VALIPI+D2_ICMSRET) VALNF,         "
cQry+="              	  SUM((C6_XPRUNIT*C6_QTDVEN)+ D2_VALIPI + D2_ICMSRET) VALPED, "
cQry+="              	  C5_XVALENT, C5_NUM  "
cQry+="       	FROM  (SELECT D2_TOTAL, D2_VALIPI, D2_ICMSRET, D2_QTDEDEV, D2_QUANT, C6_XPRUNIT, C6_QTDVEN, C5_XVALENT, C5_NUM, D2_DOC, D2_SERIE, D2_COD, D2_ITEM, "
cQry+="                     D2_CLIENTE, D2_LOJA, C5_XACERTO                                                                                       "
cQry+="                FROM Siga."+RetSQLName("SD2")+" SD2, "
cQry+="                     Siga."+RetSQLName("SC6")+" SC6, "
cQry+="                     Siga."+RetSQLName("SC5")+" SC5  "
cQry+="                WHERE SD2.D_E_L_E_T_ = ' '                  "
cQry+="                 AND SC5.D_E_L_E_T_ = ' '                  "
cQry+="                 AND SC6.D_E_L_E_T_ = ' '                  "
cQry+="                 AND SC6.C6_FILIAL  = '"+xFilial("SC6")+"' "
cQry+="                 AND SC5.C5_FILIAL  = '"+xFilial("SC5")+"' "
cQry+="                 AND SD2.D2_FILIAL  = '"+xFilial("SD2")+"' "
cQry+="                 AND SC5.C5_NUM	   = SD2.D2_PEDIDO		 "
cQry+="                 AND SC6.C6_NUM	   = SD2.D2_PEDIDO		 "
cQry+="                 AND SC6.C6_ITEM	   = SD2.D2_ITEMPV		 "
cQry+="                 AND SC5.C5_XEMBARQ = '"+cEmbarque+"')      "
cQry+="        GROUP BY C5_XVALENT, c5_num)      "
*/
cQry:="SELECT VALNCA  FROM CARGA"+cEmpAnt+"0 WHERE CARGA = '"+cEmbarque     +"' AND FILIAL = '"+cFilAnt+"' "

If Select("TRBEMB") > 0 ; TRBEMB->(DbCloseArea()) ; Endif

MemoWrite("C:\ortr039c.sql", cQry)

TcQuery cQry Alias "TRBEMB" New
TRBEMB->(DbGoTop())
nValor := TRBEMB->VALNCA
Return(nValor)

// ------------------------------------------------------------------
**************************************
Static Function RetValorRec(cEmbarque)
**************************************

Local nValor := 0
Local cQry   := ""

cQry:=" SELECT SUM(CASE WHEN C5_XPEDREC = ' ' THEN SZB.ZB_VALPARC ELSE 0 END) VALOR             "
cQry+=" FROM Siga." +RetSQLName("SZB")+" SZB, Siga." +RetSQLName("SC5")+"  SC5 "
cQry+=" WHERE SZB.D_E_L_E_T_ = ' ' AND SC5.D_E_L_E_T_ (+)= ' ' "
cQry+="   AND SZB.ZB_FILIAL   = '"+xFilial("SZB")+"' "
cQry+="   AND SC5.C5_FILIAL   (+)= '"+xFilial("SC5")+"' "
cQry+="   AND SC5.C5_xoper <> '24' "
cQry+="   AND SZB.ZB_DOCREC   = '"+cEmbarque     +"' "
cQry+="   AND SZB.ZB_ROTINA   = 'A'         "
cQry+="   AND SC5.C5_NUM     (+)= SZB.ZB_NUMPED "

If Select("TRBEMB") > 0 ; TRBEMB->(DbCloseArea()) ; Endif
MemoWrite("C:\ortr039d.sql", cQry)
TcQuery cQry ALIAS "TRBEMB" NEW
TRBEMB->(DbGoTop())
nValor := TRBEMB->VALOR
If Select("TRBEMB") > 0 ; TRBEMB->(DbCloseArea()) ; Endif

cQuery:="SELECT c5_num, sum((CASE WHEN ZK_OPERAC = 'SB' THEN ZK_VALOR*-1 ELSE ZK_VALOR END)) - NVL((SELECT SUM(sd1.d1_total + sd1.d1_valipi - sd1.d1_valdesc + "
cQuery+="                              SD1.D1_ICMSRET) valor "
cQuery+="                     FROM Siga."+RETSQLNAME("SD1")+" SD1, Siga."+RETSQLNAME("SD2")+" SD2 "
cQuery+="                    WHERE sd1.d_e_l_e_t_ <> '*' "
cQuery+="                      AND sd2.d_e_l_e_t_ <> '*' "
cQuery+="                      AND sd1.d1_filial = '"+XFILIAL("SD1")+"'"
cQuery+="                      AND sd1.d1_nfori = sd2.d2_doc "
cQuery+="                      AND sd1.d1_seriori = sd2.d2_serie "
cQuery+="                      AND sd1.d1_itemori = sd2.d2_item "
cQuery+="                      AND sd1.d1_fornece = sd2.d2_cliente "
cQuery+="                      AND sd1.d1_loja = sd2.d2_loja "
cQuery+="                      AND sd1.d1_nfori <> ' ' "
cQuery+="                      AND sd1.d1_tipo IN ('D', 'B') "
cQuery+="                      AND SD2.D2_PEDIDO = SC51.C5_NUM), "
cQuery+="                   0) VALOR "
cQuery+="FROM Siga."+RetSQLName("SZK")+" SZK, Siga."+RetSQLName("SC5")+" SC51 "
cQuery+="WHERE SZK.D_E_L_E_T_ <> '*'  "
cQuery+="  AND SC51.D_E_L_E_T_ <> '*'  "
cQuery+="  AND SC51.C5_FILIAL = '" + xFilial("SC5")  +"' "
cQuery+="  AND SZK.ZK_FILIAL = '" + xFilial("SZK")  +"' "
cQuery+=" and ZK_cliente||ZK_loja=c5_cliente||c5_lojacli"
cQuery+="  AND ZK_OPERAC 	IN ('AP','ST','PI','SB') "
cQuery+="  AND C5_NUM  		= ZK_PEDIDO    "
cQuery+="  AND C5_XEMBARQ = '"+cEmbarque+"' "
cQuery+="   AND C5_NUM   NOT IN (SELECT DISTINCT ZB_NUMPED      "
cQuery+="                               FROM Siga."+RetSQLName("SZB")+" SZB "
cQuery+="                               WHERE SZB.D_E_L_E_T_ <> '*'    "
cQuery+="                               AND   SZB.ZB_FILIAL   = '"+xFilial("SZB")+"' "
cQuery+="                               AND   SZB.ZB_ROTINA   = 'A'                  "
cQuery+="                               AND   SZB.ZB_TPOPER   = ' '                  "
cQuery+="                               AND   SZB.ZB_DOCREC   = '"+cEmbarque+"')     " // Elimina somente aceite para não duplicar valor
cQuery+=" GROUP BY C5_NUM"

If Select("TRBEMB") > 0 ; TRBEMB->(DbCloseArea()) ; Endif
MemoWrite("C:\ortr039g.sql", cQuery)
TcQuery cQuery Alias "TRBEMB" New
TRBEMB->(DbGoTop())
While TRBEMB->(!EOF())
	nValor += TRBEMB->VALOR
	TRBEMB->(DbSkip())
End

If Select("TRBEMB") > 0 ; TRBEMB->(DbCloseArea()) ; Endif

Return(nValor)

// ------------------------------------------------------------------
************************************
Static Function RetChqAtc(cEmbarque)
************************************

Local nValor := 0
Local cQry   := ""

cQuery:=" SELECT SUM((CASE WHEN VALORANT <= VALDEV THEN 0 ELSE VALORANT - VALDEV END)) VALANT "//SUM(VALORANT - VALDEV) VALANT "
cQuery+="  FROM (SELECT C5_NUM, "
cQuery+="               SUM(CASE WHEN ZK_OPERAC = 'SB' THEN ZK_VALOR*-1 ELSE ZK_VALOR END) VALORANT, "
cQuery+="               NVL((SELECT SUM(sd1.d1_total + sd1.d1_valipi - sd1.d1_valdesc + "
cQuery+="                              SD1.D1_ICMSRET) valor "
cQuery+="                     FROM Siga."+RETSQLNAME("SD1")+" SD1, Siga."+RETSQLNAME("SD2")+" SD2 "
cQuery+="                    WHERE sd1.d_e_l_e_t_ <> '*' "
cQuery+="                      AND sd2.d_e_l_e_t_ <> '*' "
cQuery+="                      AND sd1.d1_filial = '"+XFILIAL("SD1")+"'"
cQuery+="                      AND sd1.d1_nfori = sd2.d2_doc "
cQuery+="                      AND sd1.d1_seriori = sd2.d2_serie "
cQuery+="                      AND sd1.d1_itemori = sd2.d2_item "
cQuery+="                      AND sd1.d1_fornece = sd2.d2_cliente "
cQuery+="                      AND sd1.d1_loja = sd2.d2_loja "
cQuery+="                      AND sd1.d1_nfori <> ' ' "
cQuery+="                      AND sd1.d1_tipo IN ('D', 'B') "
cQuery+="                      AND SD2.D2_PEDIDO = SC51.C5_NUM), "
cQuery+="                   0) VALDEV "
cQuery+="          FROM Siga."+RETSQLNAME("SZK")+" SZK, Siga."+RETSQLNAME("SC5")+" SC51 "
cQuery+="         WHERE SZK.D_E_L_E_T_ <> '*' "
cQuery+="           AND SC51.D_E_L_E_T_ <> '*' "
cQuery+="           AND SC51.C5_FILIAL = '"+XFILIAL("SC5")+"'"
cQuery+="           AND SZK.ZK_FILIAL = '"+XFILIAL("SZK")+"'"
cQuery+="           AND ZK_OPERAC in ('AP', 'ST', 'PI', 'SB') "
cQuery+="           AND C5_NUM = ZK_PEDIDO "
cQuery+="           AND C5_XEMBARQ = '"+QRY->ZQ_EMBARQ+"'"
cQuery+="         GROUP BY C5_NUM) "

If Select("TRBEMB") > 0 ; TRBEMB->(DbCloseArea()) ; Endif
MemoWrite("C:\ortr039h.sql", cQuery)
TcQuery cQuery Alias "TRBEMB" New
TRBEMB->(DbGoTop())
nValor := TRBEMB->VALANT
if nValor < 0
	nValor:=0
endif
If Select("TRBEMB") > 0 ; TRBEMB->(DbCloseArea()) ; Endif

Return(nValor)

// ------------------------------------------------------------------
************************************
Static Function RetDupCgn(cEmbarque)
************************************

Local nValor := 0
Local cQry   := ""

cQry:=" SELECT SUM(SZB.ZB_VALOR) VALOR              "
cQry+=" FROM Siga."+RetSQLName("SZB")+" SZB,             "
cQry+="      Siga."+RetSQLName("SC5")+" SC5              "
cQry+="WHERE SZB.D_E_L_E_T_ <> '*'                  "
cQry+="  AND SC5.D_E_L_E_T_ <> '*'                  "
cQry+="  AND SC5.C5_FILIAL   = '"+xFilial("SC5")+"' "
cQry+="  AND SZB.ZB_FILIAL   = '"+xFilial("SZB")+"' "
cQry+="  AND SZB.ZB_ROTINA   = 'A'                  "
cQry+="  AND SZB.ZB_TPOPER   = ' '                  "
cQry+="  AND SC5.C5_NUM      = SZB.ZB_NUMPED        "
cQry+="  AND SC5.C5_XOPER    = '07'                 "//Demonstracao   // alterado em 09/02/2007 - Cleverson
cQry+="  AND SC5.C5_XEMBARQ  = '"+cEmbarque+"'      "

If Select("TRBEMB") > 0 ; TRBEMB->(DbCloseArea()) ; Endif
MemoWrite("C:\ortr039i.sql", cQry)
TcQuery cQry Alias "TRBEMB" New
TRBEMB->(DbGoTop())
nValor := TRBEMB->VALOR
If Select("TRBEMB") > 0 ; TRBEMB->(DbCloseArea()) ; Endif

Return(nValor)

// ------------------------------------------------------------------
***********************************
Static Function RetTroca(cEmbarque)
***********************************

Local nValor := 0
Local cQry   := ""

cQry:=" SELECT SUM(ZB_VALPARC) VALOR "
cQry+="       FROM Siga."+RetSQLName("SZB")+" SZB,               "
cQry+="            Siga."+RetSQLName("SC5")+" SC5                "
cQry+="       WHERE SZB.D_E_L_E_T_ <> '*'                   "
cQry+="         AND SC5.D_E_L_E_T_ <> '*'                   "
cQry+="         AND SC5.C5_FILIAL   = '"+xFilial("SC5")+"'  "
cQry+="         AND SZB.ZB_FILIAL   = '"+xFilial("SZB")+"'  "
cQry+="         AND SZB.ZB_ROTINA   = 'A'                   "
cQry+="         AND SZB.ZB_TPOPER   = ' '                   "
cQry+="         AND SC5.C5_NUM      = SZB.ZB_NUMPED         "
cQry+="         AND SC5.C5_XOPER    IN ('02','03','17')     "//T=Troca
cQry+="         AND SC5.C5_XEMBARQ  = '"+cEmbarque+"'       "

If Select("TRBEMB") > 0 ; TRBEMB->(DbCloseArea()) ; Endif
MemoWrite("C:\ortr039j.sql", cQry)
TcQuery cQry Alias "TRBEMB" New
TRBEMB->(DbGoTop())
nValor := TRBEMB->VALOR
If Select("TRBEMB") > 0 ; TRBEMB->(DbCloseArea()) ; Endif

Return(nValor)

// ------------------------------------------------------------------
***********************************
Static Function RetBonif(cEmbarque)
***********************************

Local nValor := 0
Local cQry   := ""

cQuery:=" SELECT SUM(VALOR) VALOR FROM ("
cQuery+=" SELECT SUM(ZB_VALOR) VALOR "
cQuery+=" FROM Siga." + RetSQLName("SZB") + " SZB, Siga." + RetSQLName("SC5") + " SC5 "
cQuery+=" WHERE SZB.D_E_L_E_T_ <> '*'  "
cQuery+="   AND SC5.D_E_L_E_T_ <> '*'  "
cQuery+="   AND SC5.C5_FILIAL = '" + xFilial("SC5")  +"' "
cQuery+="   AND SZB.ZB_FILIAL = '" + xFilial("SZB")  +"' "
cQuery+="   AND C5_NUM        = ZB_NUMPED "
cQuery+="   AND ZB_TPOPER     = 'BON'     "
cQuery+="   AND C5_XEMBARQ    = '" + QRY->ZQ_EMBARQ+"' "
cQuery+=" UNION "
cQuery+=" SELECT SUM(ZB_VALOR) VALOR "
cQuery+=" FROM Siga." + RetSQLName("SZB") + " SZB, Siga." + RetSQLName("SC5") + " SC5 "
cQuery+=" WHERE SZB.D_E_L_E_T_ <> '*'  "
cQuery+="   AND SC5.D_E_L_E_T_ <> '*'  "
cQuery+="   AND SC5.C5_FILIAL   = '" + xFilial("SC5")  +"' "
cQuery+="   AND SZB.ZB_FILIAL   = '" + xFilial("SZB")  +"' "
cQuery+="   AND C5_NUM  		= ZB_NUMPED "
cQuery+="   AND ZB_TPOPER      <> 'BON'     "
cQuery+="   AND C5_XOPER IN ('05')"  //R=Reposicao,D=Demonstracao,B=Brinde,T=Troca
cQuery+="   AND C5_XEMBARQ      = '" + cEmbarque + "') "

If Select("TRBEMB") > 0 ; TRBEMB->(DbCloseArea()) ; Endif
MemoWrite("C:\ortr039l.sql", cQry)
TcQuery cQuery Alias "TRBEMB" New
TRBEMB->(DbGoTop())
nValor := TRBEMB->VALOR
If Select("TRBEMB") > 0 ; TRBEMB->(DbCloseArea()) ; Endif

Return(nValor)

// ------------------------------------------------------------------
**********************************
Static Function RetLoja(cEmbarque)
**********************************

Local nValor := 0

cQuery:=" SELECT SUM(VALOR) VALOR FROM ("
cQuery+=" SELECT SUM(ZB_VALOR) VALOR "
cQuery+=" FROM Siga." + RetSQLName("SZB") + " SZB, Siga." + RetSQLName("SC5") + " SC5, Siga." + RetSQLName("SA1") + " SA1 "
cQuery+=" WHERE SZB.D_E_L_E_T_ = ' '  "
cQuery+="   AND SC5.D_E_L_E_T_ = ' '  "
cQuery+="   AND SC5.C5_FILIAL  = '" + xFilial("SC5")  +"' "
cQuery+="   AND SZB.ZB_FILIAL  = '" + xFilial("SZB")  +"' "
cQuery+="   AND SA1.A1_FILIAL  = '" + xFilial("SA1")  +"' "
cQuery+="   AND C5_NUM         = ZB_NUMPED  "
cQuery+="   AND A1_COD         = C5_CLIENTE "
cQuery+="   AND A1_LOJA        = C5_LOJACLI "
cQuery+="   AND A1_EST        <> 'EX'       "
cQuery+="   AND ZB_ROTINA      = 'A'        "
cQuery+="   AND ZB_TPOPER      = ' '        "
cQuery+="   AND C5_XOPER NOT IN ('02','03','07','17','08','05','23','24','25') " // T=Troca
cQuery+="   AND C5_XTPSEGM   IN ('3','4') "                                 // Loja e Loja Especializada
cQuery+="   AND C5_XEMBARQ     = '" + cEmbarque + "') "

If Select("TRBEMB") > 0 ; TRBEMB->(DbCloseArea()) ; Endif
MemoWrite("C:\ortr039n.sql", cQuery)
TcQuery cQuery ALIAS "TRBEMB" NEW
DbSelectArea("TRBEMB")
dbGoTop()
nValor := TRBEMB->VALOR
DbSelectArea("TRBEMB")
dbclosearea()

Return(nValor)

// ------------------------------------------------------------------
*********************************
Static Function RetDES(cEmbarque)
*********************************

Local nValor := 0

cQuery:=" SELECT SUM(VALOR)    VALOR FROM ("
cQuery+=" SELECT SUM(ZB_VALOR) VALOR "
cQuery+=" FROM Siga." + RetSQLName("SZB") + " SZB, Siga." + RetSQLName("SC5") + " SC5, Siga." + RetSQLName("SA1") + " SA1 "
cQuery+=" WHERE SZB.D_E_L_E_T_ = ' '  "
cQuery+="   AND SC5.D_E_L_E_T_ = ' '  "
cQuery+="   AND SA1.D_E_L_E_T_ = ' '  "
cQuery+="   AND SC5.C5_FILIAL  = '" + xFilial("SC5") + "' "
cQuery+="   AND SZB.ZB_FILIAL  = '" + xFilial("SZB") + "' "
cQuery+="   AND SA1.A1_FILIAL  = '" + xFilial("SA1") + "' "
cQuery+="   AND C5_NUM         = ZB_NUMPED    "
cQuery+="   AND A1_COD         = C5_CLIENTE   "
cQuery+="   AND A1_LOJA        = C5_LOJACLI   "
&&	cQuery+="   AND A1_EST        <> 'EX'         " && Henrique - 23/05/2014 - SSI 1759
cQuery+="   AND ZB_ROTINA      = 'A'  "
cQuery+="   AND ZB_TPOPER      = ' '  "
cQuery+="   AND C5_XOPER       = '24' "//Destruição
cQuery+="   AND C5_XEMBARQ     = '" + cEmbarque + "') "

If Select("TRBEMB") > 0 ; TRBEMB->(DbCloseArea()) ; Endif
MemoWrite("C:\ortr039m.sql", cQuery)
TcQuery cQuery ALIAS "TRBEMB" NEW
DbSelectArea("TRBEMB")
dbGoTop()
nValor := TRBEMB->VALOR
DbSelectArea("TRBEMB")
dbclosearea()

Return(nValor)

// ------------------------------------------------------------------
*********************************
Static Function RetJrs(cEmbarque)
*********************************

Local nValor := 0

cQuery:=" SELECT SUM(ZB_VALJUR) VALOR "
cQuery+=" FROM Siga." + RetSQLName("SZB") + " SZB, Siga." + RetSQLName("SC5") + " SC5 "
cQuery+=" WHERE SZB.D_E_L_E_T_ <> '*'  "
cQuery+="   AND SC5.D_E_L_E_T_ <> '*'  "
cQuery+="   AND SC5.C5_FILIAL   = '" + xFilial("SC5") + "' "
cQuery+="   AND SZB.ZB_FILIAL   = '" + xFilial("SZB") + "' "
cQuery+="   AND ZB_ROTINA       = 'A'       "
cQuery+="   AND ZB_TPOPER      <> 'BON'     "
cQuery+="   AND C5_NUM          = ZB_NUMPED "
cQuery+="   AND C5_XEMBARQ      = '" + cEmbarque + "' "

If Select("TRBEMB") > 0 ; TRBEMB->(DbCloseArea()) ; Endif
MemoWrite("C:\ortr039o.sql", cQuery)
TcQuery cQuery ALIAS "TRBEMB" NEW
DbSelectArea("TRBEMB")
dbGoTop()
nValor := TRBEMB->VALOR
DbSelectArea("TRBEMB")
dbclosearea()

Return(nValor)

// ------------------------------------------------------------------
*********************************
Static Function PedRec(cEmbarque)
*********************************

Local nValor := 0

cQuery:=" SELECT SUM(ZB_VALOR) VALOR "
cQuery+="   FROM Siga." + RetSqlName("SZB")
cQuery+="  WHERE R_E_C_N_O_ IN (SELECT DISTINCT SZB.R_E_C_N_O_                               "
cQuery+="                         FROM Siga." + RetSqlName("SZB") + " SZB, Siga." + RetSqlName("SC5") + " SC5 "
cQuery+="                        WHERE SC5.D_E_L_E_T_ = ' '                                  "
cQuery+="                          AND SC5.C5_FILIAL  = '"+xFilial("SC5")+"'                                 "
cQuery+="                          AND C5_XEMBARQ     = '" + cEmbarque + "'                  "
cQuery+="                          AND SZB.D_E_L_E_T_ = ' '                                  "
cQuery+="                          AND ZB_ROTINA      = 'A'                                  "
cQuery+="                          AND ZB_NUMPED      = C5_XPEDREC                           "
cQuery+="                          AND SZB.ZB_FILIAL  = '"+xFilial("SC5")+"'                                 "
cQuery+="                          AND ZB_TPOPER     <> ' ')                                 "

If Select("TRBEMB") > 0 ; TRBEMB->(DbCloseArea()) ; Endif
MemoWrite("C:\ortr039pa.sql", cQuery)
TcQuery cQuery ALIAS "TRBEMB" NEW
DbSelectArea("TRBEMB")
dbGoTop()
nValor := TRBEMB->VALOR
DbSelectArea("TRBEMB")
dbclosearea()
cQuery:=" SELECT SUM(D2_TOTAL+D2_VALIPI+D2_ICMSRET) VALOR"
cQuery+="   FROM Siga." + RetSqlName("SD2")
cQuery+="  WHERE R_E_C_N_O_ IN (SELECT DISTINCT SD2.R_E_C_N_O_          "
cQuery+="                         FROM Siga." + RetSqlName("SD2") + " SD2, Siga." + RetSqlName("SC5") + " SC5 "
cQuery+="                        WHERE SC5.D_E_L_E_T_ = ' '              "
cQuery+="                          AND SC5.C5_FILIAL  = '"+xFilial("SC5")+"'             "
cQuery+="                          AND C5_XEMBARQ     = '" + cEmbarque + "' "
cQuery+="                          AND SD2.D_E_L_E_T_ = ' '              "
cQuery+="                          AND D2_PEDIDO      = C5_XPEDREC       "
cQuery+="                          AND D2_PEDIDO     <> ' '              "
cQuery+="                          AND D2_FILIAL      = '"+xFilial("SD2")+"')            "
If Select("TRBEMB") > 0 ; TRBEMB->(DbCloseArea()) ; Endif
MemoWrite("C:\ortr039pb.sql", cQuery)
TcQuery cQuery ALIAS "TRBEMB" NEW
DbSelectArea("TRBEMB")
dbGoTop()
nValor -= TRBEMB->VALOR
DbSelectArea("TRBEMB")
dbclosearea()

Return(nValor)

// ------------------------------------------------------------------
************************************
Static Function PedRecOut(cEmbarque)
************************************

Local nValor := 0

cQuery:="  SELECT SUM(CASE WHEN VALORACE > 0 THEN VALORACE - VALORPEDREC - VALOROUTPED ELSE 0 END) VALOR FROM (SELECT "
cQuery+="  DISTINCT C5_XPEDREC,nvl((SELECT SUM(ZB_VALOR) FROM Siga." + RetSQLName("SZB") + " SZB "
cQuery+="  WHERE SZB.D_E_L_E_T_ <> '*'  "
cQuery+="    AND ZB_NUMPED       = C5_XPEDREC "
cQuery+="    AND ZB_ROTINA       = 'A' "
cQuery+="    AND ZB_DOCREC      <> '" + cEmbarque      + "' "
cQuery+="    AND SZB.ZB_FILIAL   = '" + xFilial("SZB") + "' "
cQuery+="    AND ZB_TPOPER      <> ' '),0) VALORACE,  " // VALOR ACERTADO DO PEDIDO RECEBEDOR
cQuery+=" nvl((SELECT SUM(D2_TOTAL+D2_VALIPI) FROM Siga." + RetSQLName("SD2") + " SD2, Siga." + RetSQLName("SC5") + " SC52 "
cQuery+=" WHERE  SD2.D_E_L_E_T_ <> '*'  "
cQuery+="   AND SC52.D_E_L_E_T_ <> '*'  "
cQuery+="   AND D2_PEDIDO        = SC5.C5_XPEDREC "
cQuery+="   AND D2_PEDIDO        = SC52.C5_NUM "
cQuery+="   AND SC52.C5_XEMBARQ <> '" + cEmbarque + "' "
cQuery+="   AND SC5.C5_XPEDREC  <> ' ' "
cQuery+="   AND SD2.D2_FILIAL    = '" + xFilial("SD2") + "'),0) VALORPEDREC, " // VALOR DO PEDIDO RECEBEDOR
cQuery+=" nvl((SELECT SUM(D2_TOTAL + D2_VALIPI) "
cQuery+="       FROM Siga." + RetSQLName("SD2") + " SD2, Siga." + RetSQLName("SC5") + " SC52 "
cQuery+="            WHERE  SD2.D_E_L_E_T_ <> '*' "
cQuery+="              AND SC52.D_E_L_E_T_ <> '*' "
cQuery+="              AND SC52.C5_XPEDREC  = SC5.C5_XPEDREC "
cQuery+="              AND D2_PEDIDO        = SC52.C5_NUM    "
cQuery+="              AND SC52.C5_XEMBARQ <> '" + cEmbarque + "'"
cQuery+="			   AND SC5.C5_XPEDREC  <> ' ' "
cQuery+="              AND SD2.D2_FILIAL    = '"+xFilial("SC5")+"'),0) " //VALOR DE OUTROS PEDIDOS ACERTADOS COM ESTE PEDIDO RECEBEDOR
cQuery+="   VALOROUTPED "
cQuery+=" FROM Siga." + RetSQLName("SC5") + " SC5 "
cQuery+=" WHERE SC5.D_E_L_E_T_ <> '*'  "
cQuery+="   AND SC5.C5_FILIAL   = '" + xFilial("SC5") + "' "
cQuery+="   AND C5_XEMBARQ      = '" + cEmbarque      + "' "
cQuery+="   AND C5_XPEDREC     <> ' ' "
cQuery+="   ) "

If Select("TRBEMB") > 0 ; TRBEMB->(DbCloseArea()) ; Endif
MemoWrite("C:\ortr039q.sql", cQuery)
TcQuery cQuery ALIAS "TRBEMB" NEW
DbSelectArea("TRBEMB")
dbGoTop()
nValor := TRBEMB->VALOR
DbSelectArea("TRBEMB")
dbclosearea()

Return(nValor)

// ------------------------------------------------------------------
***********************************
Static Function fPRecNum(cEmbarque)
***********************************

Local cPedRec := "( "

cQuery:=" SELECT C5_XPEDREC "
cQuery+=" FROM Siga." + RetSQLName("SC5") + " SC5 "
cQuery+=" WHERE SC5.D_E_L_E_T_ <> '*'  "
cQuery+="   AND SC5.C5_FILIAL   = '" + xFilial("SC5") + "' "
cQuery+="   AND C5_XEMBARQ      = '" + cEmbarque      + "' "
cQuery+="   AND C5_XPEDREC     <> ' '"

If Select("TRBEMB") > 0 ; TRBEMB->(DbCloseArea()) ; Endif
MemoWrite("C:\ortr039r.sql", cQuery)
TcQuery cQuery ALIAS "TRBEMB" NEW
DbSelectArea("TRBEMB")
dbGoTop()
While !Eof()
	If cPedRec == "( "
		cPedRec += ALLTRIM(TRBEMB->C5_XPEDREC)
	Else
		cPedRec += "," + ALLTRIM(TRBEMB->C5_XPEDREC)
	EndIf
	DbSkip()
EndDo
cPedRec += " )"

TRBEMB->(dbclosearea())

Return(cPedRec)

// ------------------------------------------------------------------
***************************************
Static Function RetVal(cEmbarque,cTipo)
***************************************

Local nValor := 0

cQuery:=" SELECT SUM(ZB_VALPARC) VALOR "
cQuery+=" FROM Siga." + RetSQLName("SZB") + " SZB, Siga." + RetSQLName("SC5") + " SC5 "
cQuery+=" WHERE SZB.D_E_L_E_T_ <> '*'  "
cQuery+="   AND SC5.D_E_L_E_T_ <> '*'  "
cQuery+="   AND SC5.C5_FILIAL   = '" + xFilial("SC5") + "' "
cQuery+="   AND SZB.ZB_FILIAL   = '" + xFilial("SZB") + "' "
cQuery+="   AND ZB_ROTINA       = 'A' "
if cTipo == "CHC"
	cQuery+="  AND ZB_TPOPER LIKE 'CH%' "
	cQuery+="  AND TO_DATE(ZB_DTVENC,'YYYYMMDD')-TO_DATE(ZB_DTMOV,'YYYYMMDD') > "+ALLTRIM(STR(GETNEWPAR("MV_XCHQDEP",1)))
else
	if cTipo == "CHD"
		cQuery+="  AND ZB_TPOPER LIKE 'CH%' "
		cQuery+="  AND TO_DATE(ZB_DTVENC,'YYYYMMDD')-TO_DATE(ZB_DTMOV,'YYYYMMDD') <= "+ALLTRIM(STR(GETNEWPAR("MV_XCHQDEP",1)))
	else
		if cTipo == "DH"
			cQuery+="  AND ZB_TPOPER IN ('DH','DEP') "
		else
			cQuery+="  AND ZB_TPOPER IN ('"+cTipo+"') "
		endif
	endif
endif
cQuery+="  AND C5_NUM  = ZB_NUMPED    "
cQuery+="  AND C5_XEMBARQ = '"+cEmbarque+"' "

If Select("TRBEMB") > 0 ; TRBEMB->(DbCloseArea()) ; Endif
MemoWrite("C:\ortr039s.sql", cQuery)
TcQuery cQuery ALIAS "TRBEMB" NEW
DbSelectArea("TRBEMB")
dbGoTop()
nValor := TRBEMB->VALOR
DbSelectArea("TRBEMB")
dbclosearea()

Return(nValor)

// ------------------------------------------------------------------
******************************************
Static Function RetOutros(cEmbarque,cOper)
******************************************

Local nValor := 0
Local cQuery := ""

cQuery+=" SELECT SUM(ZB_VALOR) VALOR "
cQuery+=" FROM Siga." + RetSQLName("SZB") + " SZB, Siga." + RetSQLName("SC5") + " SC5 "
cQuery+=" WHERE SZB.D_E_L_E_T_ <> '*'  "
cQuery+="   AND SC5.D_E_L_E_T_ <> '*'  "
cQuery+="   AND SC5.C5_FILIAL   = '" + xFilial("SC5") + "' "
cQuery+="   AND SZB.ZB_FILIAL   = '" + xFilial("SZB") + "' "
cQuery+="   AND C5_NUM          = ZB_NUMPED    "
cQuery+="   AND ZB_ROTINA       = 'A' "
cQuery+="   AND ZB_TPOPER       = ' ' "
cQuery+="   AND C5_XOPER        = '" + cOper     + "' " // Conserto
cQuery+="   AND C5_XEMBARQ      = '" + cEmbarque + "'"

If Select("TRBEMB") > 0 ; TRBEMB->(DbCloseArea()) ; Endif
MemoWrite("C:\ortr039n.sql", cQuery)
TcQuery cQuery ALIAS "TRBEMB" NEW
DbSelectArea("TRBEMB")
dbGoTop()
nValor := TRBEMB->VALOR
DbSelectArea("TRBEMB")
dbclosearea()

Return(nValor)

// ------------------------------------------------------------------
************************************
Static Function RetDevMem(cEmbarque)
************************************

Local nValor := 0
Local cQuery := ""

cQuery+=" SELECT SUM(ZB_VALOR) VALOR "
cQuery+=" FROM Siga." + RetSQLName("SZB") + " SZB, Siga." + RetSQLName("SC5") + " SC5 "
cQuery+=" WHERE SZB.D_E_L_E_T_ <> '*'  "
cQuery+="   AND SC5.D_E_L_E_T_ <> '*'  "
cQuery+="   AND SC5.C5_FILIAL   = '" + xFilial("SC5") + "' "
cQuery+="   AND SZB.ZB_FILIAL   = '" + xFilial("SZB") + "' "
cQuery+="   AND C5_NUM          = ZB_NUMPED "
cQuery+="   AND ZB_ROTINA       = 'A'       "
cQuery+="   AND ZB_TPOPER       = 'MEM'     "
cQuery+="   AND C5_XEMBARQ      = '" + cEmbarque + "'"

If Select("TRBEMB") > 0 ; TRBEMB->(DbCloseArea()) ; Endif
MemoWrite("C:\ortr039memo.sql", cQuery)
TcQuery cQuery ALIAS "TRBEMB" NEW
DbSelectArea("TRBEMB")
dbGoTop()
nValor := TRBEMB->VALOR
DbSelectArea("TRBEMB")
dbclosearea()

Return(nValor)

// ------------------------------------------------------------------
*********************************
Static Function RetUsu(cEmbarque)
*********************************

Local cOperador := ""
Local cQuery    := ""
Local nCntl		:= 0

cQuery+=" SELECT ZB_USUACE  "
cQuery+=" FROM Siga." + RetSQLName("SZB")  + " SZB "
cQuery+=" WHERE SZB.D_E_L_E_T_ = ' '                      "
cQuery+="   AND SZB.ZB_FILIAL  = '" + xFilial("SZB") + "' "
cQuery+="   AND ZB_ROTINA      = 'A'                      "
cQuery+="   AND ZB_DOCREC      = '" + cEmbarque      + "' "

If Select("TRBEMB") > 0 ; TRBEMB->(DbCloseArea()) ; Endif
MemoWrite("C:\ortr039usuace.sql", cQuery)
TcQuery cQuery ALIAS "TUSU" NEW
DbSelectArea("TUSU")
while !(eof())
	if !empty(TUSU->ZB_USUACE) .and. cOperador <> Alltrim(TUSU->ZB_USUACE)
		cOperador+= Alltrim(TUSU->ZB_USUACE)+" | "
		nCntl++
		if nCntl >= 2
			cOperador+= ENTER
		endif
	endif
	dbSkip()
enddo
DbSelectArea("TUSU")
dbclosearea()

Return(cOperador)

// ------------------------------------------------------------------
****************************
Static Function ImpCab(oPrn)
****************************

oPrn:EndPage()
oPrn:StartPage()
nLin := 50

//--[ gus - new ]----------------------------------------------------
//
//	oPrn:Box(nLin,0005,nLin+nEsp*4,2330)
//	nLin+=nEsp
//
//	oPrn:Say(nLin,0010,"HORA: " + Time() + " - (" + Nomeprog + ")",oFont2)
//	oPrn:Say(nLin,2025,"No FOLHA: " + strzero(nPag,3,0),oFont2)
//
//	nLin += nEsp
//	oPrn:Say(nLin,1000,titulo,oFont2)
//
//	oPrn:Say(nLin,0010,"EMPRESA: "+cEmpAnt + " / Filial: " + substr(cNomFil,1,2),oFont2)
//	oPrn:Say(nLin,1945,"EMISSAO: "+DToC(Date()),oFont2)
//	nLin += nEsp*2
//
//	oPrn:Box(nLin,0005,nLin+nEsp*3,2330)
//	oPrn:Say(nlin,0010,"USUARIO              : AUXILIAR ACERTO/ENCARREGADO ACERTO/GERENCIA FINANCEIRA",oFont2)
//	nLin += nEsp
//	oPrn:Say(nlin,0010,"OBJETIVO             : ANALISAR DETALHADAMENTE AS INFORMACOES DAS CARGAS."    ,oFont2)
//	nLin += nEsp
//	oPrn:Say(nlin,0010,"PERIODO DE UTILIZACAO: DIARIO",oFont2)
//	nLin += nEsp*2
//
//-------------------------------------------------------------------

oPrn:Box(nLin,0005,nLin+nEsp*3,2330)
nLin += nEsp
oPrn:Say(nLin,0010,"HORA: "     + Time() + " - (" + Nomeprog + ")",oFont2)
oPrn:Say(nLin,2025,"No FOLHA: " + strzero(nPag,3,0),oFont2)
nLin += nEsp
oPrn:Say(nLin,0010,"EMPRESA: "  + cEmpAnt + " / Filial: " + substr(cNomFil,1,2),oFont2)
oPrn:Say(nLin,1000,titulo,oFont2)
oPrn:Say(nLin,1945,"EMISSAO: "  + DToC(Date()),oFont2)
nLin += nEsp
oPrn:Box(nLin,0005,nLin+nEsp*2,2330)
oPrn:Say(nlin,0010,"USUARIO  : AUXILIAR ACERTO/ENCARREGADO ACERTO/GERENCIA FINANCEIRA",oFont2)
nLin += nEsp
oPrn:Say(nlin,0010,"OBJETIVO : ANALISAR DETALHADAMENTE AS INFORMACOES DAS CARGAS.                          PERIODO DE UTILIZACAO: DIARIO",oFont2)
nLin += nEsp*2

//  oPrn:Say(nlin,0010,"PERIODO DE UTILIZACAO: DIARIO",oFont2)
//  nLin += nEsp*2

//-------------------------------------------------------------------

nPag += 1

Return(oPrn)

// ------------------------------------------------------------------

&& Henrique - 16/09/2014 - SSI 2392
*********************************
Static Function fValST(cEmbarque)
*********************************

Local nRetorno:=0

cQry:=        " Select Sum(F2_ICMSRET) F2_ICMSRET "
cQry+=ENTER + " From Siga." + RetSQLName("SF2") + " "
cQry+=ENTER + " Where D_E_L_E_T_ = ' '"
&&  cQry+=ENTER + "   AND F2_TIPO    = 'N'"
cQry+=ENTER + "   AND F2_DOC In (SELECT C5_NOTA "
cQry+=ENTER + "                 FROM Siga." + RetSQLName("SC5")  + " SC5 "
cQry+=ENTER + "                 WHERE SC5.D_E_L_E_T_ = ' '                      "
cQry+=ENTER + "                   AND SC5.C5_FILIAL  = '" + xFilial("SC5") + "' "
cQry+=ENTER + "                   AND SC5.C5_XEMBARQ = '" + cEmbarque      + "')"

MemoWrite("C:\ORTR039ST.sql", cQry)
DbUseArea(.T., 'TOPCONN', TCGenQry(,,cQry),"QRYSt", .F., .T.)
QRYSt->(DbGoTop())
If QRYSt->(Eof())
	While ! QRYSt->(Eof())
		nRetorno+=QRYSt->F2_ICMSRET
		QRYSt->(DbSkip())
	End
EndIf
QRYSt->(DbCloseArea())

Return(nRetorno)

// ------------------------------------------------------------------
// [ fim de ortr039.prw ]
// ------------------------------------------------------------------
*****************************
Static Function ValCarga()    	
*****************************
Local cQuery:=""
cQuery:="SELECT DISTINCT C5_XEMBARQ "
cQuery+="  FROM "+RetSQLName("SC5")+" "
cQuery+="  WHERE D_E_L_E_T_ = ' ' "
cQuery+="    AND C5_FILIAL = '"+xFilial("SC5")+"' "
cQuery+="    AND C5_XACERTO BETWEEN '"+DTOS(MV_PAR01)+ "' AND '" + DTOS(MV_PAR02) + "' "
cQuery+="    AND C5_XEMBARQ BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"' "
U_ORTQUERY(cQuery,"VALCG039")
DbSelectArea("VALCG039")
Do While !eof()
	cQuery:="UPDATE "+RetSqlName("SZQ")
	cQuery+="   SET ZQ_VALOR = NVL((SELECT SUM(DECODE(C5_XVALENT,0,DECODE(C5_XUNORI,'07',DECODE(C5_XOPER,'14',D2_TOTAL + D2_VALIPI, "
	cQuery+="                       DECODE(C5_XPEDCLX,'"+space(20)+"',D2_TOTAL + D2_VALIPI, "
	cQuery+="                     	DECODE(D2_EST,'SE',D2_TOTAL + D2_VALIPI, DECODE(C5_XTPSEGM,'3',D2_TOTAL +D2_VALIPI,'4',D2_TOTAL +D2_VALIPI, "
	cQuery+="                       C6_XPRUNIT * D2_QUANT)))), D2_TOTAL + D2_VALIPI), C6_XPRUNIT * D2_QUANT + DECODE(C5_XDESPRO, 3, D2_VALIPI, 0)) + "
	cQuery+="                       D2_ICMSRET)                       "
	cQuery+="                         FROM "+RetSqlName("SC5")+" SC5, "+RetSqlName("SD2")+" SD2, "+RetSqlName("SC6")+" SC6 "
	cQuery+="                        WHERE SC5.D_E_L_E_T_ = ' ' "
	cQuery+="                          AND SC6.D_E_L_E_T_ = ' ' "
	cQuery+="                          AND SD2.D_E_L_E_T_ = ' ' "
	cQuery+="                          AND C5_FILIAL = '"+xFilial("SC5")+"' "
	cQuery+="                          AND C6_FILIAL = '"+xFilial("SC6")+"' "
	cQuery+="                          AND D2_FILIAL = '"+xFilial("SD2")+"' "
	cQuery+="                          AND C5_NUM = D2_PEDIDO "
	cQuery+="                          AND C6_NUM = D2_PEDIDO
	cQuery+="                          AND C6_ITEM = D2_ITEMPV
	cQuery+="                          AND C5_XEMBARQ = ZQ_EMBARQ) -
	cQuery+="                              nvl((SELECT SUM(C5_XVALENT)
	cQuery+="                                     FROM "+RetSqlName("SC5")+" SC5 "
	cQuery+="                                    WHERE SC5.D_E_L_E_T_ = ' '      "
	cQuery+="                                      AND C5_FILIAL = '"+xFilial("SC5")+"'     "
	cQuery+="                                      AND C5_XEMBARQ = ZQ_EMBARQ),0),ZQ_VALOR) "
	cQuery+="   WHERE D_E_L_E_T_ = ' ' "
	cQuery+="     AND ZQ_FILIAL =  '"+xFilial("SZQ")+"' "
	cQuery+="     AND ZQ_EMBARQ = '"+VALCG039->C5_XEMBARQ+"' "
	TCSQLExec(cQuery)
	cQuery:=" UPDATE "+RetSqlName("SZQ")
	cQuery+="    SET ZQ_VALOR = NVL((SELECT sum(D2_ICMSRET + D2_VALIPI) "
	cQuery+="                          FROM "+RetSqlName("SC5")+" SC5, "+RetSqlName("SD2")+" SD2, "+RetSqlName("SC6")+" SC6 "
	cQuery+="                         WHERE SC5.D_E_L_E_T_ = ' ' "
	cQuery+="                           AND SC6.D_E_L_E_T_ = ' ' "
	cQuery+="                           AND SD2.D_E_L_E_T_ = ' ' "
	cQuery+="                           AND C5_FILIAL = '"+xFilial("SC5")+"' "
	cQuery+="                           AND C6_FILIAL = '"+xFilial("SC6")+"' "
	cQuery+="                           AND D2_FILIAL = '"+xFilial("SD2")+"' "
	cQuery+="                           AND C5_TIPO in ('I', 'P') "
	cQuery+="                           AND C5_NUM = D2_PEDIDO    "
	cQuery+="                           AND C6_NUM = D2_PEDIDO    "
	cQuery+="                           AND C6_ITEM = D2_ITEMPV   "
	cQuery+="                           AND C5_XEMBARQ = ZQ_EMBARQ) -
	cQuery+="                               nvl((SELECT SUM(C5_XVALENT)
	cQuery+="                                      FROM "+RetSqlName("SC5")+" SC5 "
	cQuery+="                                     WHERE SC5.D_E_L_E_T_ = ' ' "
	cQuery+="                                       AND C5_FILIAL = '"+xFilial("SC5")+"' "
	cQuery+="                                       AND C5_XEMBARQ = ZQ_EMBARQ),0),ZQ_VALOR)
	cQuery+="   WHERE D_E_L_E_T_ = ' ' "
	cQuery+="     AND ZQ_FILIAL =  '"+xFilial("SZQ")+"' "
	cQuery+="     AND EXISTS (SELECT 'X'
	cQuery+="                   FROM "+RetSqlName("SC5")+" SC5 "
	cQuery+="                  WHERE SC5.D_E_L_E_T_ = ' ' "
	cQuery+="                    AND C5_FILIAL = '"+xFilial("SC5")+"' "
	cQuery+="                    AND C5_XEMBARQ = ZQ_EMBARQ  "
	cQuery+="                    AND C5_TIPO in ('I', 'P'))  "
	cQuery+="     AND ZQ_EMBARQ = '"+VALCG039->C5_XEMBARQ+"' "
	TCSQLExec(cQuery)
	TCSQLExec("COMMIT")
    U_SPEXEC("VALCARGA"+cEMPANT+"0",{VALCG039->C5_XEMBARQ})
	//TCSPExec("VALCARGA"+cEmpAnt+"0",VALCG039->C5_XEMBARQ)
	DbSelectArea("VALCG039")
	DbSkip()
EndDo
Return()  
