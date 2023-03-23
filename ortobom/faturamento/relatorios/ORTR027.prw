#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "SIGAWIN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "PROTHEUS.CH"

#DEFINE CRLF Chr(13)+Chr(10)

/*/
Autor     : Ronaldo Pena (Korus Consultoria)
--------------------------------------------------------
Data      : 02/03/2007
--------------------------------------------------------
Descricao : Relatorio - Termo de Responsabilidade
--------------------------------------------------------
Partida   : Menu de Usuario

********************************************************

Alterado  : Marcio William
--------------------------------------------------------
Data      : 16/07/09
--------------------------------------------------------
Descricao : Alterado o campo segmento( ZH_ITINER ) para
rota (A1_XROTA) e ajuste do layout

********************************************************

Alterado  : Marcio William
--------------------------------------------------------
Data      : 15/05/10
--------------------------------------------------------
Descricao : Incluido a Justificativa quando o termo possui
varias zonas.
========================================================
Alterado  : Henrique
--------------------------------------------------------
Data      : 12/05/2014
--------------------------------------------------------
Descricao : Inclusão da opcao Site. Solicitação da Núbia
direto pelo telefone sem SSI.
========================================================
Alterado  : Henrique
--------------------------------------------------------
Data      : 23/06/2014
--------------------------------------------------------
Descricao : SSI 2497. Conforme orientação do  Dupim,  os
pedidos que tenham o ampo C5_XDESPRO  preen-
chidos com 1 ou 2 indicam que houve desconto
de IPI e o valor de tabela e carga devem ser
composto com a formula abaixo:
C6_QTDVEN * C6_XPRUNIT
Conforme conversa com a  Núbia,  aguardar  o
retorno do Felipe para confirmar se a  alte-
ração será no ORTR027 ou no ORTR063
========================================================
Alterado  : Henrique
--------------------------------------------------------
Data      : 29/08/2014
--------------------------------------------------------
Descricao : SSI 3974. Calculo de tabela para SIMBAIA.
========================================================
Alterado  : Henrique
--------------------------------------------------------
Data      : 19/06/2015
--------------------------------------------------------
Descricao : SSI 12200. Incluir a opcao Destricao.
========================================================
/*/
***********************
User Function ORTR027()
***********************

Private _aPedido  := {}
Private _cPedido  := ""
Private _lSeg     := .t.
Private aEstDA    := {}
Private aEstVP    := {}
Private aOrd      := {}
Private aReturn   :={"Zebrado", 1, "Administracao", 2, 1, 1, "", 1}
Private cDesc1    := " "
Private cDesc2    := " "
Private cDesc3    := " "
Private cNomeprog := "ORTR027"
Private cNomFil   := ""
Private cPerg     := "ORTR27"
Private cString   := ""
Private cTamanho  := "G"
Private cTitulo   := "TERMO DE RESPONSABILIDADE"
Private cZona     := ""
Private limit     := 1500
Private limit2    := 55
Private lRota     := .F.
Private m_Pag     := 1
Private MaxLin    := 2300 //limite para salto de pagina 2300 paisagem e 3200 retrato
Private nEsp      := 50 //espacamento entre linhas
Private nEsp2     := 60 //espacamento entre linhas
Private nEsp3     := 75 //espacamento entre linhas
Private nImpT     := 0
Private nImpTot   := 0
Private nLastKey  := 0
Private nLin      := 2450 //2300 paisagem e 3200 retrato
Private nPag      := 1
Private nPdf      := 0
Private nPdf2     := 0
Private nTotCof   := 0
Private nTotCSLL  := 0
Private nTotPis   := 0
Private nValTab   := 0
Private oPrn
Private wnrel     := "ORTR027"

dbSelectArea("SM0")
dbSeek(cEmpAnt+cFilAnt)
cNomFil := SM0->M0_FILIAL

dbSelectArea("SB1")
dbOrderNickName("PSB11")


ValidPerg()
If (Pergunte(cPerg, .T.)) == .f.  //Cria a Pergunta
	Return
Endif

cTipoRel := StrZero(mv_par03,2)
If !cTipoRel $ ("01,50,99")
	cTipoRel:="01"
Endif

cEmbIni  := mv_par01
cEmbFim  := mv_par02

oFont1	:= TFont():New("Courier New",,11,,.T.)
oFontN  := TFont():New('Courier New',,11,,.F.)
oFont2	:= TFont():New("Courier New",,12,,.T.)
oFont3	:= TFont():New("Courier New",,14,,.T.)
oFont4	:= TFont():New("Courier New",,16,,.T.)
oFont5	:= TFont():New("Courier New",,10,,.T.)
oPrn:= TReport():New("ORTR027",cTitulo,,{|oPrn| fImprime()},cTitulo)
oPrn:HideHeader() //oculta cabeçalho
oPrn:HideFooter() //oculta rodapé
oPrn:SetLandsCape()    //   SETA A PAGINA COMO PADRAO PAISAGEM
//oPrn:oPage:nPaperSize == 9
oPrn:oPage:setPaperSize(10)
oPrn:SetEdit(.F.)         // Bloqueia personalizar
oPrn:NoUserFilter()       // nao permite criar FIltro de usuario
oPrn:PrintDialog()

if oPrn:Cancel()
	Return
EndIf

FreeObj(oPrn)
oPrn := Nil
Return

If aReturn[5] == 1
	Set Printer To
	DbCommitAll()
	OurSpool(wnrel)
Endif
Ms_Flush()

Return

**************************
/*/{Protheus.doc} fImprime
//TODO Descrição auto-gerada.
@author rickson.oliveira
@since 03/07/2020
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
Static Function fImprime()
**************************

Local _nFrt        := 0
Local _nPercFrt    := 0
Local _nTotFrt     := 0

Private _nPeso     := 0
Private _nValCarga := 0
Private nTotTabFre := 0

if MV_PAR05-MV_PAR04 >= 3 .AND. MV_PAR01<>MV_PAR02
	MsgBox("Periodo Invalido para esse relatorio, informe periodo menor ou numero da carga")
	Return(.F.)
endif

cQry :=      " SELECT A.*, ROWNUM FROM ("
cQry += CRLF+" SELECT SZQ.ZQ_PERFRET,SC5.C5_XCLITRO, SC5.C5_XLOJATR,SC5.C5_XEMBARQ,"
cQry += CRLF+"        SZQ.ZQ_DTEMBAR,"
cQry += CRLF+"        SZQ.ZQ_VALOR,"
cQry += CRLF+"        SZQ.ZQ_DTPREVE,"
cQry += CRLF+"        SZQ.ZQ_VALFRET,"
cQry += CRLF+"        SZQ.ZQ_VLFRPG, "
cQry += CRLF+"        SZQ.ZQ_FRTMIN,"
cQry += CRLF+"        SD2.D2_DOC,"
cQry += CRLF+"        SUM(SD2.D2_DESCZFR) SUFRAMA, 	"
cQry += CRLF+"        SUM(SD2.D2_DESCON) D2_DESCON, 	"
cQry += CRLF+"        (CASE WHEN (SELECT COUNT(C5_NUM)  "
cQry += CRLF+"              FROM SIGA."+RETSQLNAME("SC5")+" SC51, SIGA."+RETSQLNAME("SC6")+" SC61, SIGA."+RETSQLNAME("DA1")+ " DA11 "
cQry += CRLF+"             WHERE SC51.D_E_L_E_T_ = ' ' "
cQry += CRLF+"               AND SC61.D_E_L_E_T_ = ' ' "
cQry += CRLF+"               AND DA11.D_E_L_E_T_ = ' ' "
cQry += CRLF+"               AND SC61.C6_FILIAL = '"+xFilial("SC6")+"'  "
cQry += CRLF+"               AND SC51.C5_FILIAL = '"+xFilial("SC5")+"'  "
cQry += CRLF+"               AND DA11.DA1_FILIAL = '"+xFilial("DA1")+"' "
cQry += CRLF+"               AND SC61.C6_PRODUTO = DA11.DA1_CODPRO "
cQry += CRLF+"               AND DA11.DA1_CODTAB = SC51.C5_TABELA "
cQry += CRLF+"               AND SC51.C5_CLIENTE = SC61.C6_CLI "
cQry += CRLF+"               AND SC51.C5_NUM = SC61.C6_NUM "
cQry += CRLF+"               AND SC51.C5_NUM = SC5.C5_NUM "
cQry += CRLF+"               AND C6_XPRCVEN <> DA1_PRCVEN) > 0  THEN SC5.C5_NUM||'*' ELSE SC5.C5_NUM END) C5_NUM, "
cQry += CRLF+"        SC5.C5_XDESPRO,"
cQry += CRLF+"        SC5.C5_XPRZMED,"
cQry += CRLF+"        SC5.C5_CLIENTE,"
cQry += CRLF+"        SC5.C5_LOJACLI,"
cQry += CRLF+"        SC5.C5_XVALENT,"
cQry += CRLF+"        SA1.A1_NOME, SA1.A1_EST,  A1_GRPTRIB,"
cQry += CRLF+"        SA1.A1_MUN , SA1.A1_BAIRRO ,A1_XPERFRE,SA1.A1_XROTA,"  // ADD A QUERY A1_XROTA
cQry += CRLF+"        SC5.C5_XORDEMB,"
cQry += CRLF+"        SC5.C5_XTPSEGM,"
cQry += CRLF+"        SC5.C5_XOPER,"
cQry += CRLF+"        NVL(SZH.ZH_VEND,SC5.C5_VEND1) VEND,"
cQry += CRLF+"        NVL(SZH.ZH_ITINER,'Z') ZH_ITINER, "
cQry += CRLF+"        CASE WHEN (C5_COTACAO = 'OTP156' OR (C5_XOPER = '14' AND C5_XCPFVEN IN ('03007331000141', '15436940000103', '00776574000660', '07170938000107'))) THEN 'VA' " // Marcelo Coutinho - 10/05/2021 - Solicitação 125668
cQry += CRLF+"             WHEN C5_XOPER ='07' THEN 'D' "
cQry += CRLF+"             WHEN C5_XOPER ='24' THEN 'DT' " // Henrique - 19/06/2015 SSI 12200
cQry += CRLF+"             WHEN C5_XOPER ='06' THEN 'DV' "
cQry += CRLF+"             WHEN C5_XOPER ='22' THEN 'Q' "
cQry += CRLF+"             WHEN C5_XOPER ='09' THEN 'CS' "
cQry += CRLF+"             WHEN C5_XOPER ='17' THEN 'T' "
cQry += CRLF+"             WHEN C5_XOPER ='08' THEN 'R' "
cQry += CRLF+"             WHEN C5_XOPER ='25' THEN 'RI' "
cQry += CRLF+"             WHEN C5_XOPER ='23' THEN 'RCO' "
cQry += CRLF+"             WHEN C5_XOPER ='02' AND B1_XMODELO NOT IN ('000015','000028') THEN 'E' "
cQry += CRLF+"             WHEN C5_XOPER ='18' THEN 'SV' "
cQry += CRLF+"             WHEN C5_XOPER ='01' AND C5_XTPSEGM IN ('8') Then 'SI' " && Henrique - 12/05/2014 - Solicitação da Núbia - Incluir Site
cQry += CRLF+"             WHEN C5_XOPER ='03' AND C5_XVALENT = 0 THEN 'T' "
cQry += CRLF+"             WHEN C5_XVALENT <> 0 THEN 'A' "
cQry += CRLF+"             WHEN C5_XTPSEGM IN ('2','6') AND C5_XOPER IN ('03') AND C5_XPRZMED > '000' THEN 'C' "
cQry += CRLF+"             WHEN C5_XOPER IN ('05') THEN 'B' ELSE "
cQry += CRLF+"               CASE WHEN C5_XOPER IN ('08') THEN 'R' "
cQry += CRLF+"                  WHEN C5_XOPER IN ('16') THEN 'Z' "
cQry += CRLF+"                  ELSE"
cQry += CRLF+"                  CASE WHEN C5_XTPSEGM IN ('1','2','5','6', 'M', 'I') THEN 'V' "
cQry += CRLF+"                       WHEN C5_XTPSEGM IN ('3') THEN 'F' "
cQry += CRLF+"                       WHEN C5_XTPSEGM IN ('L') THEN 'BP' "
cQry += CRLF+"                       WHEN C5_XTPSEGM IN ('4') THEN 'EX' "
cQry += CRLF+"                       WHEN C5_XTPSEGM IN ('9') THEN 'DE' "
cQry += CRLF+"                       WHEN C5_XTPSEGM IN ('8') THEN 'SI' "
cQry += CRLF+"                       ELSE 'X' END"
cQry += CRLF+"        END END QUEBRA ,"
cQry += CRLF+"        CASE WHEN C5_XTPSEGM IN ('5','6') THEN 'O' "
cQry += CRLF+"             WHEN C5_XTPSEGM IN ('4')     THEN 'E' ELSE 'X' END QADIC, "
cQry += CRLF+"        Sum(CASE WHEN B1_XMODELO='000008' OR (B1_XMODELO='000011' AND C6_XTPMED='2') THEN DECODE(SC6.C6_UNSVEN,0,SC6.C6_QTDVEN,SC6.C6_UNSVEN) ELSE SC6.C6_QTDVEN END)  QUANT, "
cQry += CRLF+"        SUM(CASE WHEN D2_TIPO IN ('I','P') THEN 0 ELSE SD2.D2_TOTAL END)  VLRTOT,"
cQry += CRLF+"        Sum(Case When C5_XOPER='24' Then 0 Else SC6.C6_XPRUNIT*SC6.C6_QTDVEN End)     VLRTAB,"
cQry += CRLF+"        Sum(SC6.C6_XPRUNIT*((100-C6_XGUELTA-C6_XRESSAR)/100)*SD2.D2_QUANT) VLRBFRT,"
cQry += CRLF+"        Sum(SC6.C6_XCUSTO*SC6.C6_QTDVEN) VLRCUS,"
cQry += CRLF+"        Sum(D2_VALIPI) VLRIPI, "
cQry += CRLF+"        Sum(DECODE(C5_XDESPRO,'3',DECODE(C5_XVALENT,0,0,D2_VALIPI),' ',DECODE(C5_XVALENT,0,0,D2_VALIPI),D2_VALIPI)) VLRIPI2, "
cQry += CRLF+"        Sum(D2_VALICM) VLRICM, "
cQry += CRLF+"        Sum(D2_ICMSRET) VLRST, "
cQry += CRLF+"        SUM(C6_QTDVEN*B1_PESO) PESO, "
cQry += CRLF+"        (SELECT Z2_MUNENT FROM SIGA." +RetSqlName("SZ2")+ " WHERE Z2_FILIAL = '"+xFilial("SZ2")+"' AND D_E_L_E_T_ = ' ' AND Z2_MUNENT <> ' ' AND ROWNUM = 1 AND SC5.C5_NUM = Z2_NUMPED) MUNENT "
cQry += CRLF+" FROM SIGA." +RetSqlName("SC5")+ " SC5, "
cQry += CRLF+"      SIGA." +RetSqlName("SC6")+ " SC6, "
cQry += CRLF+"      SIGA." +RetSqlName("SA1")+ " SA1, "
cQry += CRLF+"      SIGA." +RetSqlName("SB1")+ " SB1, "
cQry += CRLF+"      SIGA." +RetSqlName("SZQ")+ " SZQ, "
cQry += CRLF+"      SIGA." +RetSqlName("SD2")+ " SD2, "
cQry += CRLF+"      SIGA." +RetSqlName("SZH")+ " SZH  "
cQry += CRLF+" WHERE SC5.D_E_L_E_T_  <> '*' "
if !empty(cEmbIni) .or. Upper(cEmbFim) <> "ZZZZZZ"
	cQry += CRLF+"   AND SC5.C5_XEMBARQ BETWEEN '"+cEmbIni+"' AND '"+cEmbFim+"' "
endif
if cTipoRel =="50"
	cQry += CRLF+"   AND SC5.C5_XEMBARQ > '500000' "
else
	if cTipoRel <> "99"
		cQry += CRLF+"   AND SC5.C5_XEMBARQ < '500000' "
	endif
endif
cQry += CRLF+"   AND SZQ.ZQ_DTPREVE BETWEEN '"+DTOS(MV_PAR04)+"' AND '"+DTOS(MV_PAR05)+"' "
cQry += CRLF+"   AND SC5.C5_FILIAL = '"+xFilial("SC5")+"'"
cQry += CRLF+"   AND SC6.C6_FILIAL = '"+xFilial("SC6")+"'"
cQry += CRLF+"   AND ZH_FILIAL(+) = '"+xFilial("SZH")+"'"
cQry += CRLF+"   AND C5_CLIENTE  = ZH_CLIENTE(+) "
cQry += CRLF+"   AND C5_LOJACLI  = ZH_LOJA(+)    "
cQry += CRLF+"   AND C5_XTPSEGM  = ZH_SEGMENT(+) "
cQry += CRLF+"   AND ZH_VEND(+) NOT LIKE 'L%' "
cQry += CRLF+"   AND SZH.D_E_L_E_T_(+) <> '*' "
cQry += CRLF+"   AND SZH.ZH_MSBLQL(+) <> '1' "
If cEmpAnt=="26"
	cQry += CRLF+"   AND D2_FILIAL IN ('01','02')"
Else
	cQry += CRLF+"   AND D2_FILIAL = '"+xFilial("SD2")+"'"
Endif
cQry += CRLF+"   AND D2_PEDIDO  = C6_NUM "
cQry += CRLF+"   AND D2_ITEMPV  = C6_ITEM "
cQry += CRLF+"   AND D2_COD     = C6_PRODUTO "
cQry += CRLF+"   AND ZQ_FILIAL  = '"+xFilial("SZQ")+"'"
cQry += CRLF+"   AND C5_XEMBARQ = ZQ_EMBARQ "
cQry += CRLF+"   AND B1_FILIAL  = '"+xFilial("SB1")+"'"
cQry += CRLF+"   AND C6_PRODUTO = B1_COD"
cQry += CRLF+"   AND A1_FILIAL  = '"+xFilial("SA1")+"'"
cQry += CRLF+"   AND C5_CLIENTE = A1_COD"
cQry += CRLF+"   AND C5_LOJACLI = A1_LOJA"
cQry += CRLF+"   AND C5_FILIAL = C6_FILIAL "
cQry += CRLF+"   AND C5_NUM = C6_NUM "
cQry += CRLF+"   AND SC6.D_E_L_E_T_ <> '*' "
cQry += CRLF+"   AND SA1.D_E_L_E_T_ <> '*' "
cQry += CRLF+"   AND SB1.D_E_L_E_T_ <> '*' "
cQry += CRLF+"   AND SZQ.D_E_L_E_T_ <> '*' "
cQry += CRLF+"   AND SD2.D_E_L_E_T_ <> '*' "
cQry += CRLF+"   AND C5_TIPO NOT IN ('D','B') "
cQry += CRLF+" GROUP BY SZQ.ZQ_PERFRET,SC5.C5_XCLITRO, SC5.C5_XLOJATR,SC5.C5_XEMBARQ ,"
cQry += CRLF+"       SZQ.ZQ_DTEMBAR, SZQ.ZQ_DTPREVE, SZQ.ZQ_VALOR, SZQ.ZQ_VALFRET ,"
cQry += CRLF+"       SZQ.ZQ_FRTMIN , SD2.D2_DOC, SC5.C5_NUM, SC5.C5_XDESPRO,  "
cQry += CRLF+"       SC5.C5_XPRZMED, SC5.C5_XVALENT, SC5.C5_CLIENTE, SC5.C5_LOJACLI,"
cQry += CRLF+"       SZQ.ZQ_VLFRPG, SA1.A1_NOME, SA1.A1_EST, A1_GRPTRIB,"
cQry += CRLF+"       SA1.A1_MUN  ,SA1.A1_BAIRRO , A1_XPERFRE, A1_XROTA,"
cQry += CRLF+"       SC5.C5_XORDEMB, SC5.C5_XTPSEGM, SC5.C5_XOPER ,"
cQry += CRLF+"       SC5.C5_VEND1 ,"
cQry += CRLF+"       SZH.ZH_VEND ,"
cQry += CRLF+"       SZH.ZH_ITINER ," 
cQry += CRLF+"        CASE WHEN (C5_COTACAO = 'OTP156' OR (C5_XOPER = '14' AND C5_XCPFVEN IN ('03007331000141', '15436940000103', '00776574000660', '07170938000107'))) THEN 'VA' " // Marcelo Coutinho - 10/05/2021 - Solicitação 125668
cQry += CRLF+"             WHEN C5_XOPER ='07' THEN 'D' "
cQry += CRLF+"             WHEN C5_XOPER ='24' THEN 'DT' " // Henrique - 19/06/2015 SSI 12200
cQry += CRLF+"             WHEN C5_XOPER ='06' THEN 'DV'"
cQry += CRLF+"             WHEN C5_XOPER ='22' THEN 'Q' "
cQry += CRLF+"             WHEN C5_XOPER ='09' THEN 'CS'"
cQry += CRLF+"             WHEN C5_XOPER ='17' THEN 'T' "
cQry += CRLF+"             WHEN C5_XOPER ='08' THEN 'R' "
cQry += CRLF+"             WHEN C5_XOPER ='25' THEN 'RI'"
cQry += CRLF+"             WHEN C5_XOPER ='23' THEN 'RCO'"
cQry += CRLF+"             WHEN C5_XOPER ='02' AND B1_XMODELO NOT IN ('000015','000028') THEN 'E' "
cQry += CRLF+"             WHEN C5_XOPER ='18' THEN 'SV' "
cQry += CRLF+"             When C5_XOPER IN ('01') AND C5_XTPSEGM IN ('8') Then 'SI' " && Henrique - 12/05/2014 - Solicitação da Núbia - Incluir Site
cQry += CRLF+"             WHEN C5_XOPER IN ('03')  AND C5_XVALENT = 0 THEN 'T' "
cQry += CRLF+"             WHEN C5_XVALENT <> 0 THEN 'A' "
cQry += CRLF+"             WHEN C5_XTPSEGM IN ('2','6') AND C5_XOPER IN ('03') AND C5_XPRZMED > '000' THEN 'C' "
cQry += CRLF+"             WHEN C5_XOPER IN ('05') THEN 'B' ELSE "
cQry += CRLF+"             CASE WHEN C5_XOPER IN ('08') THEN 'R' "
cQry += CRLF+"                  WHEN C5_XOPER IN ('16') THEN 'Z' "
cQry += CRLF+"                  ELSE"
cQry += CRLF+"                  CASE WHEN C5_XTPSEGM IN ('1','2','5','6', 'M', 'I') THEN 'V' "
cQry += CRLF+"                       WHEN C5_XTPSEGM IN ('3')     THEN 'F' "
cQry += CRLF+"                       WHEN C5_XTPSEGM IN ('L')     THEN 'BP' "
cQry += CRLF+"                       WHEN C5_XTPSEGM IN ('4')     THEN 'EX' "
cQry += CRLF+"                       WHEN C5_XTPSEGM IN ('9')     THEN 'DE' "
cQry += CRLF+"                       WHEN C5_XTPSEGM IN ('8')     THEN 'SI' "
cQry += CRLF+"                       ELSE 'X' END"
cQry += CRLF+"        END END "
cQry += CRLF+" UNION "
cQry += CRLF+" SELECT SZQ.ZQ_PERFRET,SC5.C5_XCLITRO, SC5.C5_XLOJATR,SC5.C5_XEMBARQ,"
cQry += CRLF+"        SZQ.ZQ_DTEMBAR,"
cQry += CRLF+"        SZQ.ZQ_VALOR,"
cQry += CRLF+"        SZQ.ZQ_DTPREVE,"
cQry += CRLF+"        SZQ.ZQ_VALFRET,"
cQry += CRLF+"        SZQ.ZQ_FRTMIN,"
cQry += CRLF+"        SZQ.ZQ_VLFRPG  ,"
cQry += CRLF+"        SD2.D2_DOC,"
cQry += CRLF+"        SUM(SD2.D2_DESCZFR) SUFRAMA, 	"
cQry += CRLF+"        SUM(SD2.D2_DESCON) D2_DESCON, 	"
cQry += CRLF+"        (CASE WHEN (SELECT COUNT(C5_NUM)  "
cQry += CRLF+"              FROM SIGA."+RETSQLNAME("SC5")+" SC51, SIGA."+RETSQLNAME("SC6")+" SC61, SIGA."+RETSQLNAME("DA1")+ " DA11 "
cQry += CRLF+"              WHERE SC51.D_E_L_E_T_ = ' ' "
cQry += CRLF+"                AND SC61.D_E_L_E_T_ = ' ' "
cQry += CRLF+"                AND DA11.D_E_L_E_T_ = ' ' "
cQry += CRLF+"                AND SC61.C6_FILIAL = '"+xFilial("SC6")+"'  "
cQry += CRLF+"                AND SC51.C5_FILIAL = '"+xFilial("SC5")+"'  "
cQry += CRLF+"                AND DA11.DA1_FILIAL = '"+xFilial("DA1")+"' "
cQry += CRLF+"                AND SC61.C6_PRODUTO = DA11.DA1_CODPRO 	"
cQry += CRLF+"                AND DA11.DA1_CODTAB = SC51.C5_TABELA 	"
cQry += CRLF+"                AND SC51.C5_CLIENTE = SC61.C6_CLI 		"
cQry += CRLF+"                AND SC51.C5_NUM = SC61.C6_NUM 			"
cQry += CRLF+"                AND SC51.C5_NUM = SC5.C5_NUM 			"
cQry += CRLF+"                AND C6_XPRCVEN <> DA1_PRCVEN) > 0  THEN SC5.C5_NUM||'*' ELSE SC5.C5_NUM END) C5_NUM, "
cQry += CRLF+"        SC5.C5_XDESPRO ,"
cQry += CRLF+"        SC5.C5_XPRZMED,"
cQry += CRLF+"        SC5.C5_CLIENTE,"
cQry += CRLF+"        SC5.C5_LOJACLI,"
cQry += CRLF+"        SC5.C5_XVALENT,"
cQry += CRLF+"        SA2.A2_NOME, SA2.A2_EST, A2_GRPTRIB,"
cQry += CRLF+"        SA2.A2_MUN , ' ' A1_BAIRRO , 0 A1_XPERFRE,' ' A1_XROTA,"
cQry += CRLF+"        SC5.C5_XORDEMB,"
cQry += CRLF+"        SC5.C5_XTPSEGM,"
cQry += CRLF+"        SC5.C5_XOPER,	 "
cQry += CRLF+"        NVL(SZH.ZH_VEND,SC5.C5_VEND1) VEND,"
cQry += CRLF+"        NVL(SZH.ZH_ITINER,'Z') ZH_ITINER, "
cQry += CRLF+"        CASE WHEN (C5_COTACAO = 'OTP156' OR (C5_XOPER = '14' AND C5_XCPFVEN IN ('03007331000141', '15436940000103', '00776574000660', '07170938000107'))) THEN 'VA' " // Marcelo Coutinho - 10/05/2021 - Solicitação 125668
cQry += CRLF+"             WHEN C5_XOPER ='07' THEN 'D' "
cQry += CRLF+"             WHEN C5_XOPER ='24' THEN 'DT' " // Henrique - 19/06/2015 SSI 12200
cQry += CRLF+"             WHEN C5_XOPER ='06' THEN 'DV' "
cQry += CRLF+"             WHEN C5_XOPER ='22' THEN 'Q' "
cQry += CRLF+"             WHEN C5_XOPER ='09' THEN 'CS' "
cQry += CRLF+"             WHEN C5_XOPER ='17' THEN 'T' "
cQry += CRLF+"             WHEN C5_XOPER ='08' THEN 'R' "
cQry += CRLF+"             WHEN C5_XOPER ='25' THEN 'RI' "
cQry += CRLF+"             WHEN C5_XOPER ='23' THEN 'RCO' "
cQry += CRLF+"             WHEN C5_XOPER ='18' THEN 'SV' "
cQry += CRLF+"             When C5_XOPER IN ('01') AND C5_XTPSEGM IN ('8') Then 'SI' " && Henrique - 12/05/2014 - Solicitação da Núbia - Incluir Site
cQry += CRLF+"             WHEN C5_XOPER IN ('02') THEN 'E' "
cQry += CRLF+"             WHEN C5_XOPER IN ('03')  AND C5_XVALENT = 0 THEN 'T' "
cQry += CRLF+"             WHEN C5_XVALENT <> 0 THEN 'A' "
cQry += CRLF+"             WHEN C5_XTPSEGM IN ('2','6') AND C5_XOPER IN ('03') AND C5_XPRZMED > '000' THEN 'C' "
cQry += CRLF+"             WHEN C5_XOPER IN ('05') THEN 'B' ELSE "
cQry += CRLF+"             CASE WHEN C5_XOPER IN ('08') THEN 'R' "
cQry += CRLF+"                  WHEN C5_XOPER IN ('16') THEN 'Z' "
cQry += CRLF+"                  ELSE"
cQry += CRLF+"                  CASE WHEN C5_XTPSEGM IN ('1','2','5','6', 'M', 'I') THEN 'V' "
cQry += CRLF+"                       WHEN C5_XTPSEGM IN ('3')     THEN 'F' "
cQry += CRLF+"                       WHEN C5_XTPSEGM IN ('L')     THEN 'BP' "
cQry += CRLF+"                       WHEN C5_XTPSEGM IN ('4')     THEN 'EX' "
cQry += CRLF+"                       WHEN C5_XTPSEGM IN ('9')     THEN 'DE' "
cQry += CRLF+"                       WHEN C5_XTPSEGM IN ('8')     THEN 'SI' "
cQry += CRLF+"                       ELSE 'X' END"
cQry += CRLF+"        END END QUEBRA ,"
cQry += CRLF+"        CASE WHEN C5_XTPSEGM IN ('5','6') THEN 'O' "
cQry += CRLF+"             WHEN C5_XTPSEGM IN ('4')     THEN 'E' ELSE 'X' END QADIC, "
cQry += CRLF+"        Sum(CASE WHEN B1_XMODELO='000008' OR (B1_XMODELO='000011' AND C6_XTPMED='2') THEN DECODE(SC6.C6_UNSVEN,0,SC6.C6_QTDVEN,SC6.C6_UNSVEN) ELSE SC6.C6_QTDVEN END)  QUANT, "
cQry += CRLF+"        SUM(CASE WHEN D2_TIPO IN ('I','P') THEN 0 ELSE SD2.D2_TOTAL END)  VLRTOT,"

// Henrique - 28/05/2015 - SSI 12200
cQry += CRLF+"        Sum(Case When C5_XOPER='24' Then 0 Else SC6.C6_XPRUNIT*SC6.C6_QTDVEN End)     VLRTAB,"
cQry += CRLF+"        Sum(SC6.C6_XPRUNIT*((100-C6_XGUELTA-C6_XRESSAR)/100)*SD2.D2_QUANT) VLRBFRT,"
cQry += CRLF+"        Sum(SC6.C6_XCUSTO*SC6.C6_QTDVEN) VLRCUS,"
cQry += CRLF+"        Sum(D2_VALIPI) VLRIPI, "
cQry += CRLF+"        Sum(DECODE(C5_XDESPRO,'3',0,' ',DECODE(C5_XVALENT,0,0,D2_VALIPI),D2_VALIPI)) VLRIPI2, "
cQry += CRLF+"        Sum(D2_VALICM) VLRICM, "
cQry += CRLF+"        Sum(D2_ICMSRET) VLRST, "
cQry += CRLF+"        SUM(C6_QTDVEN*B1_PESO) PESO, "
cQry += CRLF+"        (SELECT Z2_MUNENT FROM SIGA." +RetSqlName("SZ2")+ " WHERE Z2_FILIAL = '"+xFilial("SZ2")+"' AND D_E_L_E_T_ = ' ' AND Z2_MUNENT <> ' ' AND ROWNUM = 1 AND SC5.C5_NUM = Z2_NUMPED) MUNENT "
cQry += CRLF+" FROM SIGA." +RetSqlName("SC5")+ " SC5, "
cQry += CRLF+"      SIGA." +RetSqlName("SC6")+ " SC6, "
cQry += CRLF+"      SIGA." +RetSqlName("SA2")+ " SA2, "
cQry += CRLF+"      SIGA." +RetSqlName("SB1")+ " SB1, "
cQry += CRLF+"      SIGA." +RetSqlName("SZQ")+ " SZQ, "
cQry += CRLF+"      SIGA." +RetSqlName("SD2")+ " SD2, "
cQry += CRLF+"      SIGA." +RetSqlName("SZH")+ " SZH  "
cQry += CRLF+" WHERE SC5.D_E_L_E_T_  <> '*' "
if !empty(cEmbIni) .or. Upper(cEmbFim) <> "ZZZZZZ"
	cQry += CRLF+"   AND SC5.C5_XEMBARQ  BETWEEN '"+cEmbIni+"' AND '"+cEmbFim+"' "
endif
if cTipoRel =="50"
	cQry += CRLF+"   AND SC5.C5_XEMBARQ  > '500000' "
else
	if cTipoRel <> "99"
		cQry += CRLF+"   AND SC5.C5_XEMBARQ  < '500000' "
	endif
endif
cQry += CRLF+"   AND SZQ.ZQ_DTPREVE  BETWEEN '"+DTOS(MV_PAR04)+"' AND '"+DTOS(MV_PAR05)+"' "
cQry += CRLF+"   AND SC5.C5_FILIAL = '"+xFilial("SC5")+"'"
cQry += CRLF+"   AND SC6.C6_FILIAL = '"+xFilial("SC6")+"'"
cQry += CRLF+"   AND  ZH_FILIAL(+) = '"+xFilial("SZH")+"'"
cQry += CRLF+"   AND C5_CLIENTE    = ZH_CLIENTE(+) "
cQry += CRLF+"   AND C5_LOJACLI    = ZH_LOJA(+)    "
cQry += CRLF+"   AND C5_XTPSEGM    = ZH_SEGMENT(+) "
cQry += CRLF+"   AND ZH_VEND(+) NOT LIKE 'L%' "
cQry += CRLF+"       AND SZH.D_E_L_E_T_(+)  <> '*' "
cQry += CRLF+"       AND SZH.ZH_MSBLQL(+) <> '1' "
If cEmpAnt=="26"
	cQry += CRLF+"   AND D2_FILIAL IN ('01','02')"
Else
	cQry += CRLF+"   AND D2_FILIAL = '"+xFilial("SD2")+"'"
Endif
cQry += CRLF+"       AND D2_PEDIDO     = C6_NUM "
cQry += CRLF+"       AND D2_ITEMPV     = C6_ITEM "
cQry += CRLF+"       AND D2_COD        = C6_PRODUTO "
cQry += CRLF+"       AND ZQ_FILIAL     = '"+xFilial("SZQ")+"'"
cQry += CRLF+"       AND C5_XEMBARQ    = ZQ_EMBARQ "
cQry += CRLF+"       AND B1_FILIAL     = '"+xFilial("SB1")+"'"
cQry += CRLF+"       AND C6_PRODUTO    = B1_COD"
cQry += CRLF+"       AND A2_FILIAL     = '"+xFilial("SA2")+"'"
cQry += CRLF+"       AND C5_CLIENTE    = A2_COD "
cQry += CRLF+"       AND C5_LOJACLI    = A2_LOJA"
cQry += CRLF+"       AND C5_FILIAL = C6_FILIAL  "
cQry += CRLF+"       AND C5_NUM = C6_NUM        "
cQry += CRLF+"       AND SC6.D_E_L_E_T_  <> '*' "
cQry += CRLF+"       AND SA2.D_E_L_E_T_  <> '*' "
cQry += CRLF+"       AND SB1.D_E_L_E_T_  <> '*' "
cQry += CRLF+"   AND SZQ.D_E_L_E_T_  <> '*' "
cQry += CRLF+"   AND SD2.D_E_L_E_T_  <> '*' "
cQry += CRLF+"   AND C5_TIPO IN ('D','B') "
cQry += CRLF+" GROUP BY SZQ.ZQ_PERFRET,SC5.C5_XCLITRO, SC5.C5_XLOJATR,SC5.C5_XEMBARQ ,"
cQry += CRLF+"       SZQ.ZQ_DTEMBAR , SZQ.ZQ_DTPREVE, SZQ.ZQ_VALOR,"
cQry += CRLF+"       SZQ.ZQ_VALFRET , SZQ.ZQ_FRTMIN, SD2.D2_DOC,"
cQry += CRLF+"       SZQ.ZQ_VLFRPG  , SC5.C5_NUM, SC5.C5_XDESPRO,"
cQry += CRLF+"       SC5.C5_XPRZMED , SC5.C5_XVALENT, SC5.C5_CLIENTE ,"
cQry += CRLF+"       SC5.C5_LOJACLI , SA2.A2_NOME, SA2.A2_EST,"
cQry += CRLF+"       SA2.A2_GRPTRIB , SA2.A2_MUN,"
cQry += CRLF+"       SC5.C5_XORDEMB , SC5.C5_XTPSEGM ,"
cQry += CRLF+"       SC5.C5_XOPER   , SC5.C5_VEND1   ,"
cQry += CRLF+"       SZH.ZH_VEND,"
cQry += CRLF+"       SZH.ZH_ITINER  ,"
cQry += CRLF+"  CASE WHEN (C5_COTACAO = 'OTP156' OR (C5_XOPER = '14' AND C5_XCPFVEN IN ('03007331000141', '15436940000103', '00776574000660', '07170938000107'))) THEN 'VA' " // Marcelo Coutinho - 10/05/2021 - Solicitação 125668
cQry += CRLF+"       WHEN C5_XOPER ='07' THEN 'D' "
cQry += CRLF+"       WHEN C5_XOPER ='24' THEN 'DT' " // Henrique - 19/06/2015 SSI 12200
cQry += CRLF+"       WHEN C5_XOPER ='06' THEN 'DV' "
cQry += CRLF+"       WHEN C5_XOPER ='22' THEN 'Q' "
cQry += CRLF+"       WHEN C5_XOPER ='09' THEN 'CS' "
cQry += CRLF+"       WHEN C5_XOPER ='17' THEN 'T' "
cQry += CRLF+"       WHEN C5_XOPER ='08' THEN 'R' "
cQry += CRLF+"       WHEN C5_XOPER ='25' THEN 'RI' "
cQry += CRLF+"       WHEN C5_XOPER ='23' THEN 'RCO' "
cQry += CRLF+"       WHEN C5_XOPER ='18' THEN 'SV' "
// separação de vendas site e site terceiro - fabio 21/05/14
cQry += CRLF+"       When C5_XOPER ='01' AND C5_XTPSEGM IN ('8') Then 'SI' " && Henrique - 12/05/2014 - Solicitação da Núbia - Incluir Site
//Retirado por Thiago em 08/09/10 - Contabilizar Troca de Terceirizado como Troca de Prod. Danificado
cQry += CRLF+"       WHEN C5_XOPER ='02' THEN 'E' "
//Retirado por Dupim em 14/07/10 Troca com valor somente C5_XVALENT > 0
cQry += CRLF+"       WHEN C5_XOPER ='03'  AND C5_XVALENT = 0 THEN 'T' "
//Retirado por Dupim em 14/07/10 Troca com valor somente C5_XVALENT > 0
cQry += CRLF+"       WHEN C5_XVALENT <> 0 THEN 'A' "
cQry += CRLF+"       WHEN C5_XTPSEGM IN ('2','6') AND C5_XOPER IN ('03') AND C5_XPRZMED > '000' THEN 'C' "
cQry += CRLF+"       WHEN C5_XOPER IN ('05') THEN 'B' ELSE "
cQry += CRLF+"     CASE WHEN C5_XOPER IN ('08') THEN 'R' "
cQry += CRLF+"     WHEN C5_XOPER IN ('16') THEN 'Z' "
cQry += CRLF+"ELSE"
cQry += CRLF+" CASE WHEN C5_XTPSEGM IN ('1','2','5','6', 'M', 'I') THEN 'V' "
cQry += CRLF+"      WHEN C5_XTPSEGM IN ('3')     THEN 'F' "
cQry += CRLF+"      WHEN C5_XTPSEGM IN ('L')     THEN 'BP' "
cQry += CRLF+"      WHEN C5_XTPSEGM IN ('4')     THEN 'EX' "
cQry += CRLF+"      WHEN C5_XTPSEGM IN ('9')     THEN 'DE' "
cQry += CRLF+"      WHEN C5_XTPSEGM IN ('8')     THEN 'SI' "
cQry += CRLF+" ELSE 'X' END"
cQry += CRLF+" END END) A "
cQry += CRLF+" ORDER BY C5_XEMBARQ,QUEBRA,D2_DOC "

Memowrite("C:\ORTR027A.SQL",cQry)

*************************
*   I M P R E S S A O   *
*************************

If Select("QRY") > 0
	QRY->(DbCloseArea())
Endif

TcQuery cQry ALIAS "QRY" NEW

dbgobottom()

nRegsTrb := QRY->ROWNUM
oPrn:SetMeter(nRegsTRB)
QRY->(DbGoTop())

While QRY->(!Eof())

	cZona     := QRY->A1_XROTA
	cTermo    := QRY->C5_XEMBARQ
	dDtTermo  := Stod(QRY->ZQ_DTEMBAR)
	aTotTermo := {0,0,0,0,0,0,0,0}
	nTotPed   := 0
	aDados    := {}
	m_Pag     := 1
	
	fImpCabec(.t.)
	nTotLoja    := 0
	nTotTab     := 0
	nTotEspe    := 0
	
	While QRY->(!Eof()) .And. QRY->C5_XEMBARQ == cTermo
	
		cQuebra     := IIf(cEmpAnt # "21",QRY->QUEBRA ,IIf(QRY->QUEBRA=="Y","V",QRY->QUEBRA))
		cQAdic      := QRY->QADIC
		cDescQuebra := fQuebra(Alltrim(cQuebra))
		aTotQuebra  := {0,0,0,0,0,0,0,0}
		cTipo       := cQuebra //fTipo(Alltrim(cQuebra))
		
		While QRY->(!Eof()) .And. QRY->QUEBRA = cQuebra .And. QRY->C5_XEMBARQ == cTermo
			
			If nLin >= MaxLin
				fImpCabec()
			Endif
			
			nValIpi := QRY->VLRIPI

			_nValCarga := QRY->ZQ_VALOR
			_nPeso     += QRY->PESO
			
			_nFrt:=0
			
			If alltrim(cTipo)$('JPRVDYZCF|EX|SI|ST|STP')
				_nFrt:=QRY->A1_XPERFRE
			endif
			
			If alltrim(cTipo)$('T')
				_nFrt:=0
			endIf
			
			_nFrtPC := Posicione("SA1",1,xFilial("SA1")+QRY->C5_CLIENTE,"A1_XPERFRE")
			
			If !( QRY->C5_XOPER $ "18/04/23" ) // 26/10/2021 - Marcelo - SSI 100079 - Acréscimo das opções 03 e 24
				_nTotFrt	:=	QRY->ZQ_VALFRET
				_nPercFrt	:=	QRY->ZQ_PERFRET
			Endif
			
			if Len(aEstDA)>0
				nPos        := ascan(aEstDA,{|x| x[1]==QRY->A1_EST})
			else
				nPos:=0
			endif
			if nPos>0
				if QRY->VLRICM > 0
					aEstDA[nPos,2]+=QRY->VLRTOT
				endif
				aEstDA[nPos,3]+=1
			else
				aadd(aEstDA,{QRY->A1_EST,QRY->VLRTOT,1})
			endif
			nDoc:=val(QRY->D2_DOC)
			if ndoc > 999999
				oPrn:Say(nLin,0010,transform(nDoc, "@E 9999999"),oFont1)
			else
				oPrn:Say(nLin,0010,transform(nDoc, "@E 999,999"),oFont1)
			endif
			
			oPrn:Say(nLin,0180,Transform(QRY->C5_NUM, "@R AAA.AAAA"),oFont1) //Num.Ped
			
			oPrn:Say(nLin,0360,Subs(QRY->A1_NOME,1,20),oFont1) 		  //Nome do Cliente
			oPrn:Say(nLin,0780,Subs(QRY->A1_MUN,1,12),oFont1)     //Municipio
			oPrn:Say(nLin,1040,Subs(QRY->A1_BAIRRO,1,12),oFont1)  //Bairro

			IF ALLTRIM(cZona) <> ALLTRIM(QRY->A1_XROTA)
				lRota := .T.
			ENDIF
			
			oPrn:Say(nLin,1300,QRY->VEND+"/"+QRY->A1_XROTA,oFont1) //Vendedor/Rota
			oPrn:Say(nLin,1580,cTipo,oFont1)
			oPrn:Say(nLin,1640,Transform(_nFrt, "@E 99.99"),oFont1)
			oPrn:Say(nLin,1760,Transf(QRY->C5_XORDEMB,"99"),oFont1)
			oPrn:Say(nLin,1820,Transf(QRY->QUANT ,"@E 999,999.999"),oFont1)
			
			oPrn:Say(nLin,2060,Transf(QRY->VLRTOT,"@E 9,999,999.99"),oFont1)
			
			oPrn:Say(nLin,2320,Transf(nValIpi, "@E 99,999.99"),oFont1)
			IF QRY->C5_XVALENT <> 0
				nValTab:=QRY->VLRTAB-QRY->C5_XVALENT-QRY->SUFRAMA
			Else
				If QRY->C5_XOPER $ '08'     // SSI 117712
					nValTab:=QRY->VLRTAB+nValIpi
				Else
					nValTab:=QRY->VLRTOT+nValIpi
				EndIf
			endif
			// Henrique - 28/05/2015 - SSI 12200 - Inclui o IIF
			oPrn:Say(nLin,2520,Transf(IIf(QRY->C5_XOPER # "24",nValTab,0),"@E 999,999.99"),oFont1)
			
			//Alteração feita por Marcos Furtado - 16/09/2014
			//Objetivo: Se houver um '*' ao lado do numero indica que é este valor que vai para o ORTR063. Caso contrario vai a coluna de valor quando há IPI.
			IF AllTrim(QRY->QUEBRA)=='V' .AND. QRY->C5_XDESPRO == '1' .AND. nValIpi >= 0
				&& Henrique - 28/05/2015 - SSI 12200 - Inclui o IF C5_XOPER='24'
				If QRY->C5_XOPER # '24'
					oPrn:Say(nLin,2720,'*',oFont1)
				EndIf
			EndIf
			oPrn:Say(nLin,2740,Transf(QRY->VLRST,"@E 999,999.99"),oFont1)
			oPrn:Say(nLin,2960,Transf(nImpT,"@E 999,999.99"),oFont1)
			oPrn:Say(nLin,3180,Transf(QRY->VLRST+nValTab-nImpT,"@E 999,999.99"),oFont1)
		
			_cMopl := ""
			
			_cOpl  := " SELECT ENDERECO "
			_cOpl  += "        , NUMERO "
			_cOpl  += "        , COMPLEMENTO "
			_cOpl  += "        , BAIRRO "
			_cOpl  += "        , CIDADE "
			_cOpl  += "        FROM SIGA.ENDENT ET "
			_cOpl  += "       , SIGA."+RetSqlName('SZ2') +" SZ2 "
			_cOpl  += "        WHERE ET.PEDIDO = Z2_PEDIDO "
			_cOpl  += "        AND SZ2.D_E_L_E_T_ = ' ' "
			_cOpl  += "        AND Z2_NUMPED = '"+SUBSTR(+QRY->C5_NUM,1,6)+"'"
			_cOpl  += " 	   GROUP BY ENDERECO, NUMERO, COMPLEMENTO, BAIRRO, CIDADE "
			If Select("OPL") > 0  ; OPL->(DbCloseArea()) ; Endif
			TcQuery _cOpl Alias "OPL" New
			
			While	!EOF()
				_cMopl	+= +Alltrim(OPL->ENDERECO)+","+Alltrim(OPL->NUMERO)+","+Alltrim(OPL->COMPLEMENTO)+"."+Alltrim(OPL->BAIRRO)+"."+Alltrim(OPL->CIDADE)
				OPL->(dbSkip())
			Enddo
			
			If !empty(_cMopl)
				nLin += nEsp
				//oPrn:Say(nLin,0010,"OPL:",oFont1)
				oPrn:Say(nLin,0110,AllTrim(_cMopl),oFont1)
				nLin += nEsp
				If	Len(AllTrim(_cMopl)) >= limit
					nLin += nEsp
					oPrn:Say(nLin,0110,SubStr(AllTrim(_cMopl),1,limit),oFont1)
					nLin += nEsp
					_cMopl:=SubStr(AllTrim(_cMopl),Limit+1,Len(AllTrim(_cMopl)))
					If	Len(AllTrim(_cMopl)) >= limit
						oPrn:Say(nLin,0110,SubStr(AllTrim(_cMopl),1,limit),oFont1)
						nLin += nEsp
						oPrn:Say(nLin,0110,SubStr(AllTrim(_cMopl),Limit+1,Len(AllTrim(_cMopl))),oFont1)
					Else
						oPrn:Say(nLin,0110,AllTrim(_cMopl),oFont1)
					endif
				Endif
			Endif
			
			//FIM SSI 95899
			
			_cMsg	:=	""
			If	!Empty(QRY->MUNENT)
				_cMsg	+=	Alltrim(QRY->MUNENT)
			Endif
			
			//Busca Mensagens gravadas no campo observação dos itens dos pedidos de venda
			
			_cQr	:=	"SELECT C6_XOBS FROM SIGA."+RetSqlName("SC6") +" WHERE C6_FILIAL = '"+xFilial("SC6")+"' AND  C6_NUM = '"+QRY->C5_NUM+"' AND C6_XOBS <> ' ' AND D_E_L_E_T_ = ' '"
			
			If Select("MSG") > 0  ; MSG->(DbCloseArea()) ; Endif
			TcQuery _cQr Alias "MSG" New
			
			While	!EOF()
				_cMsg	+= "-"+Alltrim(MSG->C6_XOBS)
				MSG->(dbSkip())
			Enddo

			If !empty(_cMsg)
				nLin += nEsp
				oPrn:Say(nLin,0010,"OBSERVAÇÕES: ",oFont1)
				oPrn:Say(nLin,0280,AllTrim(_cMsg),oFont1)
				nLin += nEsp
				If	Len(AllTrim(_cMsg)) >= limit
					nLin += nEsp
					oPrn:Say(nLin,0280,SubStr(AllTrim(_cMsg),1,limit),oFont1)
					nLin += nEsp
					_cMsg:=SubStr(AllTrim(_cMsg),Limit+1,Len(AllTrim(_cMsg)))
					If	Len(AllTrim(_cMsg)) >= limit
						oPrn:Say(nLin,0280,SubStr(AllTrim(_cMsg),1,limit),oFont1)
						nLin += nEsp
						oPrn:Say(nLin,0280,SubStr(AllTrim(_cMsg),Limit+1,Len(AllTrim(_cMsg))),oFont1)
					Else
						oPrn:Say(nLin,0280,AllTrim(_cMsg),oFont1)
					endif

				Endif
			Endif
			nPos := ascan(_aPedido,{|x| x[1]==QRY->C5_NUM})
			If nPos == 0
				nTotPed++
				AADD(_aPedido,{QRY->C5_NUM})
				_cPedido := QRY->C5_NUM
			EndIF
			
			aTotQuebra[1] += QRY->QUANT
			aTotQuebra[2] += QRY->VLRTOT
			aTotQuebra[3] += nValIpi
			&& Henrique - 28/05/2015 - SSI 12200
			&& aTotQuebra[4] += IIf(QRY->C5_XOPER # "24",nValTab,0)
			aTotQuebra[4] += IIf(QRY->C5_XOPER # "24",nValTab,0)
			
			aTotQuebra[5] += QRY->VLRST
			aTotQuebra[6] += nimpT
			aTotQuebra[7] += nValTab+QRY->VLRST-nimpt
			
			// PC 26/09/12
			aTotQuebra[8]  += QRY->VLRTOT * (_nFrt/100)
			// FIM PC 26/09/12
			
			aTotTermo[1]  += QRY->QUANT
			
			aTotTermo[2] += QRY->VLRTOT
			
			aTotTermo[3]  += nValiPi
			aTotTermo[4]  += nValTab
			aTotTermo[5]  += QRY->VLRST
			aTotTermo[6]  += nimpT
			aTotTermo[7]  += nValTab+QRY->VLRST-nimpt
			
			// PC 26/09/12
			aTotTermo[8]  += QRY->VLRTOT * (_nFrtPC/100)
			// FIM PC 26/09/12
			
			nTotLoja += If(alltrim(cQuebra) $ 'F|EX'.and. alltrim(cQAdic) == "X" .and. alltrim(cQuebra) != 'E'      ,QRY->VLRTOT+QRY->VLRST,0)
			
			If QRY->C5_XVALENT <> 0
				nTotLoja += QRY->VLRTAB-QRY->C5_XVALENT-QRY->SUFRAMA
			EndIf

			if alltrim(cQuebra)	<>	'Z' 	.And.;
				alltrim(cQuebra)	<>	'T' 	.And.;
				alltrim(cQuebra)	<>	'E' 	.And.;
				alltrim(cQuebra)	<>	'S' 	.And.;
				alltrim(cQuebra)	<>	'Q' 	.And.;
				alltrim(cQuebra)	<>	'D' 	.And.;
				'B'	<> alltrim(cQuebra)			.And.;
				alltrim(cQuebra)	<>	'Y' 	.And.;
				alltrim(cQuebra)	<>	'DV'    .And.;
				alltrim(cQuebra)	<>	'Q'     .And.;
				alltrim(cQuebra)	<>	'RF'    .And.;
				alltrim(cQuebra)	<>	'CS'    .And.;
				alltrim(cQuebra)	<>	'SV'    .And.; //WALLACE:15/06/2015 INCLUINDO PREST.SERVIÇO -- SSI-12719
				alltrim(cQuebra)	<>	'RC'    .And.; //BRUNO:27/08/2011 INCLUINDO REMESSA DE INDUSTRIALIZACAO
				alltrim(cQuebra)	<>	'RI'    .And.; //BRUNO:27/08/2011 INCLUINDO REMESSA DE INDUSTRIALIZACAO
				alltrim(cQuebra)	<>	'RCO'    .And.; //BRUNO:22/09/2011 INCLUINDO REMESSA POR CONTA E ORDEM
				!(QRY->C5_XVALENT = 0 .And. QRY->C5_XPRZMED	> '000'	.And. QRY->C5_XOPER	$ '02/03' .And.	QRY->C5_XTPSEGM	$	'3/4/L')
				
				nTotTab  += nValTab-nValipi+QRY->VLRIPI2
				
			Endif

			If	alltrim(cQuebra)	<>	'A' 	.And.;
				alltrim(cQuebra)	<>	'T' 	.And.;
				alltrim(cQuebra)	<>	'E' 	.And.;
				alltrim(cQuebra)	<>	'S' 	.And.;
				alltrim(cQuebra)	<>	'Q' 	.And.;
				alltrim(cQuebra)	<>	'B' 	.And.;
				alltrim(cQuebra)	<>	'DV'    .And.;
				alltrim(cQuebra)	<>	'CS'    .And.;
				alltrim(cQuebra)	<>	'RI'    .And.; //BRUNO:27/08/2011 INCLUINDO REMESSA DE INDUSTRIALIZACAO
				alltrim(cQuebra)	<>	'RCO'   .And.; //BRUNO:22/09/2011 INCLUINDO REMESSA POR CONTA E ORDEM
				alltrim(cQuebra)	<>	'SV'    .And.;
				!(QRY->C5_XVALENT = 0 .And. QRY->C5_XPRZMED	> '000' .And. QRY->C5_XOPER $ '02/03' .And. QRY->C5_XTPSEGM	$ '3/4/L')
				
				nTotTabFre  += nValTab
			Endif
			
			//Retirado somatório do tipo "E" (Troca Danificado) ... SSI-9449
			//DIRERENÇA DE TROCAS -- SSI 31077
			//DIRERENÇA DE TROCAS -- SSI 10054  => Autorização na SSI
			If ( Alltrim(cQuebra) == 'E' ) .and. QRY->C5_XVALENT > 0
				nTotTab  += nValTab
			EndIf

			If ( Alltrim(cQuebra) == 'EX' )
				nTotTab  += nValTab-nValipi
			EndIf
			
			If ( Alltrim(cQuebra) == 'SI' )
				nTotTab  += nValTab//-nValipi
			EndIf
			
			If ( Alltrim(cQuebra) == 'STP' )
				nTotTab  += nValTab//-nValipi
			EndIf
			
			If ( Alltrim(cQuebra) == 'DE' )
				nTotTab  += nValTab//-nValipi
			EndIf
			
			If ( Alltrim(cQuebra) == 'ST' )
				//nTotTab  += nValTab-nValipi
			EndIf
			
			//nTotEspe += If(alltrim(cQuebra) == 'F'.and. alltrim(cQAdic) == "E"       ,QRY->VLRTOT,0)
			nTotEspe += If(alltrim(cQuebra) $ 'F|EX|BP'.and. alltrim(cQAdic) == "E"       ,QRY->VLRTOT,0)
			
			nLin += nEsp
			
			QRY->(DbSkip())
		End
		oPrn:Say(nLin,0800,cDescQuebra,oFont1)
		oPrn:Say(nLin,1820,Transf(aTotQuebra[1],"@E 999,999.999"),oFont1)
		oPrn:Say(nLin,2060,Transf(aTotQuebra[2],"@E 9,999,999.99"),oFont1)
		oPrn:Say(nLin,2300,Transf(aTotQuebra[3],"@E 999,999.99"),oFont1)
		oPrn:Say(nLin,2520,Transf(aTotQuebra[4],"@E 999,999.99"),oFont1)
		oPrn:Say(nLin,2740,Transf(aTotQuebra[5],"@E 999,999.99"),oFont1)
		oPrn:Say(nLin,2960,Transf(aTotQuebra[6],"@E 999,999.99"),oFont1)
		oPrn:Say(nLin,3180,Transf(aTotQuebra[7],"@E 999,999.99"),oFont1)
		nLin += nEsp
		oPrn:Line(nLin,0000,nLin,3370)
		nLin += nEsp
	End
	
	oPrn:Line(nLin,0800,nLin,3370)
	
	nLin += nEsp
	oPrn:Say(nLin,0800,"Total:",oFont1)
	oPrn:Say(nLin,1320,Transf(aTotTermo[8],"@E 9,999,999.99"),oFont1)
	oPrn:Say(nLin,1820,Transf(aTotTermo[1],"@E 999,999.999"),oFont1)
	oPrn:Say(nLin,2060,Transf(aTotTermo[2],"@E 9,999,999.99"),oFont1)
	oPrn:Say(nLin,2300,Transf(aTotTermo[3],"@E 999,999.99"),oFont1)
	oPrn:Say(nLin,2480,Transf(aTotTermo[4],"@E 9,999,999.99"),oFont1)
	oPrn:Say(nLin,2740,Transf(aTotTermo[5],"@E 999,999.99"),oFont1)
	oPrn:Say(nLin,2960,Transf(aTotTermo[6],"@E 999,999.99"),oFont1)
	oPrn:Say(nLin,3140,Transf(aTotTermo[7],"@E 9,999,999.99"),oFont1)
	// PC 26/09/12
	@ nLin,187 PSay Transf(aTotTermo[8],"@E 9,999,999.99")
	// FIM PC 26/09/12
	nLin += nEsp*2
	
	_nValCarga := aTotTermo[7]
	
	nImpTot:=0
	fImpRodape(_nTotFrt,nTotTab,_nPercFrt, aTotTermo[2])
	lRota := .F.

End
dbselectarea("QRY")
dbclosearea()
Return

**********************************
Static Function fImpCabec(lfirst)
**********************************
DEFAULT lfirst := .f.

oPrn:EndPage()
oPrn:StartPage()
nLin := 50
oPrn:Box(nLin,0005,nLin+nEsp*4,3370)
nLin+=nEsp

oPrn:Say(nLin,0010,"HORA: " + Time() + " - (" + cNomeprog + ")",oFont2)
oPrn:Say(nLin,3015-nPdf2,"No FOLHA: " + strzero(nPag,3,0),oFont2)

nLin += nEsp
oPrn:Say(nLin,1300-nPdf2,ctitulo,oFont2)

oPrn:Say(nLin,0010,"EMPRESA: "+CEMPANT + " / Filial: " + substr(cNomFil,1,2),oFont2)
oPrn:Say(nLin,2925-nPdf2,"EMISSAO: "+dtoc(ddatabase),oFont2)
nLin += nEsp*2

If nPag == 1 .or. lfirst
	oPrn:Box(nLin-nPdf,0005,nLin+nEsp*3,3370)
	oPrn:Say(nlin,0010,"USUARIO              : AUXILIAR DE FATURAMENTO, GERENCIA ADMINISTRATIVA, GERENCIA FINANCEIRA, ENCARREGADO DE ACERTO.",oFont1)
	nLin += nEsp
	oPrn:Say(nlin,0010,"OBJETIVO             : CONFERIR E ANALISAR OS VALORES DAS CARGAS.",oFont1)
	nLin += nEsp
	oPrn:Say(nlin,0010,"PERIODO DE UTILIZAÇÃO: DIÁRIO.",oFont1)
	nLin += nEsp*2
EndIf

if substr(cTermo,1,1) < "5"
	If nPag == 1 .or. lfirst
		oPrn:Say(nLin,0010,"DECLARO para os devidos fins de direito que recebi para __ Transportar __ Cobrar ao(s) __ Mercadorias  __ Documentos constantes abaixo, para a finalidade de entrega e",oFont1)
		nLin += nEsp
		oPrn:Say(nLin,0010,"respectivos recebimentos, assumindo inteira e total responsabilidade por danos, perdas roubos, dilaceracoes e extravios, na forma da lei, obrigando-me a prestar contas",oFont1)
		nLin += nEsp
		oPrn:Say(nLin,0010,"apos o regresso da viagem.",oFont1)
		nLin += nEsp*2
	endif
	oPrn:Say(nLin,0010,"No TERMO: "+cTermo,oFont3)
	oPrn:Say(nLin,0700,"Data da Programação: "+Dtoc(stod(QRY->ZQ_DTPREVE)),oFont1)
	nLin += nEsp
	//EndIF
else
	nLin += nEsp
	oPrn:Say(nlin,0010,padc("PEDIDOS CANCELADOS",132),oFont1)
	oPrn:Say(nLin,1450,"No TERMO: "+cTermo,oFont1)
	nLin += nEsp
endif
//                        10        20        30        40        50        60        70        80        90       100       110       120       130
//               012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
oPrn:Line(nLin,0000,nLin,3370)
nLin += nEsp
oPrn:Say(nLin,0010,"COMPLEMENTO DE CARGA: ",oFont1) //DMS
nLin += nEsp //DMS
oPrn:Say(nLin,0010,"NOTA",oFont1)
oPrn:Say(nLin,0180,"NUMERO",oFont1)
oPrn:Say(nLin,0360,"CLIENTE",oFont1)
oPrn:Say(nLin,0780,"MUNICIPIO",oFont1)
oPrn:Say(nLin,1040,"BAIRRO",oFont1)
oPrn:Say(nLin,1300,"VENDEDOR",oFont1)
oPrn:Say(nLin,1640,"%FRT",oFont1)
oPrn:Say(nLin,1760,"SC",oFont1)
oPrn:Say(nLin,1860,"QUANTIDADE",oFont1)
oPrn:Say(nLin,2200,"VALOR",oFont1)
oPrn:Say(nLin,2440,"IPI",oFont1)
oPrn:Say(nLin,2600,"TABELA",oFont1)
oPrn:Say(nLin,2750,"SUBSTITUIÇÃO",oFont1)
oPrn:Say(nLin,3010,"PIS/COFINS",oFont1)
oPrn:Say(nLin,3280,"TOTAL",oFont1)

nLin += nEsp
oPrn:Say(nLin,0010,"FISCAL",oFont1)
oPrn:Say(nLin,0180,"PEDIDO",oFont1)
oPrn:Say(nLin,1300,"ZONA",oFont1)
oPrn:Say(nLin,2750,"TRIBUTÁRIA",oFont1)
oPrn:Say(nLin,3010,"CSLL",oFont1)
nLin += nEsp

oPrn:Line(nLin,0000,nLin,3370)
nLin += nEsp
nPag ++

Return

********************************
Static Function fQuebra(cQuebra)
********************************

cRet:= "TIPO INEXISTENTE...:"

If     cQuebra == "V"    ; cRet:= "TOTAL TAB.COMERCIAL...:"
Elseif cQuebra == "F"    ; cRet:= "TOTAL LOJA FRANQUIA...:"
Elseif cQuebra == "BP"   ; cRet:= "TOTAL BLUE POINT......:"
Elseif cQuebra == "EX"   ; cRet:= "TOTAL EXCLUSIVA.......:"
Elseif cQuebra == "Y"    ; cRet:= "TOT. TERC.COMERCIAL...:"
Elseif cQuebra == "Z"    ; cRet:= "TOT. TERCEIROS LOJA...:"
Elseif cQuebra == "J"    ; cRet:= "TOT. PROD.UNID.LOJA...:"
Elseif cQuebra == "P"    ; cRet:= "TOT. PROD.UNID.COMERC.:"
Elseif cQuebra == "R"    ; cRet:= "TOT. REPOSICAO........:"
Elseif cQuebra == "D"    ; cRet:= "TOT. DEMONSTRACAO.....:"
Elseif cQuebra == "DV"   ; cRet:= "TOT. DEVOLUCAO FORNEC.:"
Elseif cQuebra == "Q"    ; cRet:= "TOT. INSUMOS..........:"
Elseif cQuebra == "B"    ; cRet:= "TOT. BRINDE...........:"
Elseif cQuebra == "A"    ; cRet:= "TOT. TR. C/VALOR......:"
Elseif cQuebra == "T"    ; cRet:= "TOT. TROCA............:"
Elseif cQuebra == "C"    ; cRet:= "TOT. TR. C/VL.COMERC..:"
Elseif cQuebra == "S"    ; cRet:= "TOT. TR. C/VL.TERC....:"
Elseif cQuebra == "E"    ; cRet:= "TOT. TR. DANIFICADO...:"
Elseif cQuebra == "CS"   ; cRet:= "TOT. REMESSA CONSERTO.:"
Elseif cQuebra == "RI"   ; cRet:= "REM. INDUSTRIALIZAÇÃO.:"
Elseif cQuebra == "RCO"  ; cRet:= "REM. CONTA E ORDEM....:"
Elseif cQuebra == "STP"  ; cRet:= "TOT. SITE TERC PROPRIO:"
Elseif cQuebra == "SV"   ; cRet:= "TOT. PREST. DE SERVICO:"
ElseIf cQuebra == "SI"   ; cRet:= "TOT. SITE.............:"  // Henrique - 12/05/2014
ElseIf cQuebra == "ST"   ; cRet:= "TOT. SITE TERCEIRO....:"  // Fabio    - 21/05/2014
ElseIf cQuebra == "DT"   ; cRet:= "TOT. DESTRUIÇÃO.......:"  // Henrique - 22/06/2015
ElseIf cQuebra == "DE"   ; cRet:= "TOT. DEB. ESTATISTICA.:"  // Wallace  - 19/01/2016
ElseIf cQuebra == "VA"   ; cRet:= "TOT. VENDA ANYMARKET..:"  // Marcelo  - 10/05/2021
Endif


Return(cRet)

*********************************************************
Static Function fImpRodape(_nValFrete,_nTotTab,_nPercFrt,_nTotValor)
*********************************************************

Local i
//Início SSI 10853
Local _cCnh    := ""
Local _cCpf    := ""
Local _cNomMot := ""
Local _cPlaca  := ""
//Fim SSI 10853

cQry := " SELECT SUM(C6_QTDVEN*B1_XESPACO) ESPACO    ,"
cQry += "        ZQ_ESPACO				   ESP       ,"
cQry += "        ZQ_TRANSP				   CODMOT    ," //SSI 10853
cQry += "        SUM(SC6.C6_XPRUNIT*((100-C6_XGUELTA-C6_XRESSAR)/100)*SC6.C6_QTDVEN)  PF     ,"
cQry += "        SUM(C6_XCUSTO*C6_QTDVEN)  PC        ,"
cQry += "        MAX(ZQ_KILOMET)           ZQ_KILOMET,"
cQry += "        MAX(ZQ_VALORKM)           ZQ_VALORKM,"
cQry += "		(SELECT SUM(c6_qtdven * (CASE WHEN c5_xtpsegm in ('3','L') OR c5_xoper = '16' Then (C6_XPRUNIT*((100-c6_xguelta-c6_xressar)/100)) ELSE C6_XPRUNIT END)) "
cQry += "		    FROM SIGA."+RetSQLName("SC6")+" SC6T, SIGA."+RetSQLName("SC5")+" SC5T WHERE SC5T.C5_NUM = SC6T.C6_NUM AND SC5T.C5_FILIAL = '"+xFilial("SC6")+"' AND SC6T.C6_FILIAL = '"+xFilial("SC6")+"' AND SC5T.C5_XEMBARQ = '"+cTermo+"' AND SC5T.D_E_L_E_T_ = ' ' AND SC6T.D_E_L_E_T_ = ' ' AND C5_XOPER NOT IN ('02','05','06','07','08','17') ) AS TOTAL, "
cQry += "        (SELECT SUM (  TO_NUMBER (CASE WHEN c5_xprzmed = ' ' THEN '0' ELSE c5_xprzmed END) * c6_qtdven * "
cQry += "               (CASE WHEN c5_xtpsegm in ('3','L') OR c5_xoper = '16' THEN (C6_XPRUNIT*((100-c6_xguelta-c6_xressar)/100)) ELSE C6_XPRUNIT END )) "
cQry += "                FROM SIGA."+RetSQLName("SC6")+" SC6T, SIGA."+RetSQLName("SC5")+" SC5T WHERE SC5T.C5_NUM = SC6T.C6_NUM AND SC5T.C5_FILIAL = '"+xFilial("SC6")+"' AND SC6T.C6_FILIAL = '"+xFilial("SC6")+"' AND SC5T.C5_XEMBARQ = '"+cTermo+"' AND SC5T.D_E_L_E_T_ = ' ' AND SC6T.D_E_L_E_T_ = ' ' AND C5_XOPER NOT IN ('02','05','06','07','08','17') ) PRZMED, "
cQry += "        SUM(C6_XPRUNIT*C6_QTDVEN*ZQ_PERFRET/100) ZQFRE,"
/* SSI 111993 */
cQry += "        SUM(C6_XPRUNIT*C6_QTDVEN*A1_XPERFRE/100) A1FRE, "
cQry += "        COUNT(DISTINCT A1_MUN) QTDCID "
/* SSI 111993 */
cQry += " FROM SIGA."+RetSQLName("SC6")+" SC6, "
cQry += "      SIGA."+RetSQLName("SC5")+" SC5, "
cQry += "      SIGA."+RetSQLName("SZQ")+" SZQ, "
cQry += "      SIGA."+RetSQLName("SA1")+" SA1, "
cQry += "      SIGA."+RetSQLName("SB1")+" SB1  "
cQry += " WHERE SC6.D_E_L_E_T_ <> '*' "
cQry += "   AND SC5.D_E_L_E_T_ <> '*' "
cQry += "   AND SZQ.D_E_L_E_T_ <> '*' "
cQry += "   AND SA1.D_E_L_E_T_ <> '*' "
cQry += "   AND SB1.D_E_L_E_T_ <> '*' "
cQry += "   AND SC6.C6_FILIAL = '"+xFilial("SC6")+"'"
cQry += "   AND SC5.C5_FILIAL = '"+xFilial("SC5")+"'"
cQry += "   AND SZQ.ZQ_FILIAL = '"+xFilial("SZQ")+"'"
cQry += "   AND SA1.A1_FILIAL = '"+xFilial("SA1")+"'"
cQry += "   AND SB1.B1_FILIAL = '"+xFilial("SB1")+"'"
cQry += "   AND C6_NUM          = C5_NUM "
cQry += "   AND C6_PRODUTO      = B1_COD "
cQry += "   AND C5_CLIENTE      = A1_COD "
cQry += "   AND C5_LOJACLI      = A1_LOJA "
cQry += "   AND C5_XEMBARQ      = ZQ_EMBARQ "
cQry += "   AND C5_XEMBARQ      = '"+cTermo+"'"
//cQry += "   Group By ZQ_ESPACO	" SSI 10853
cQry += "   Group By ZQ_ESPACO, ZQ_TRANSP	"

memowrit('c:\ortr027rdp.sql',cQry)
If Select("ROD") > 0  ; ROD->(DbCloseArea()) ; Endif
DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),"ROD",.F.,.T.)
ROD->(DbGoTop())


If nLin + (nEsp * 6) >= MaxLin
	fImpCabec()
Endif

//@ nLin,001 PSay "MIX.....: "+Transf(ROD->MIX*100,"@E 9,999.99")
oPrn:Say(nLin,0010,"MIX.....: "+Transf(((ROD->PF-ROD->PC)/ROD->PF)*100,"@E 999.99"),oFont1)
oPrn:Say(nLin,0400,"ESPACOS.: "+Transf(ROD->ESP,"@E 999,999.99"),oFont1)
oPrn:Say(nLin,0860,"KM......: "+Transf(ROD->ZQ_KILOMET,"@E 999,999.99"),oFont1)
If cEmpAnt == "24"
	oPrn:Say(nLin,1600,"Total Kg: "+Transf(_nPeso,"@E 999,999,999.999"),oFont1)
	_nPeso := 0
EndIF

nLin += nEsp
oPrn:Say(nLin,0010,"PZ.MEDIO: "+Transf(Round(ROD->PRZMED/ROD->TOTAL,0),"@E 999.99"),oFont1)
oPrn:Say(nLin,0400,"LOJA....: "+Transf(nTotLoja,"@E 999,999.99"),oFont1)
oPrn:Say(nLin,0860,"L.ESPEC.: "+Transf(nTotEspe,"@E 999,999.99"),oFont1)
oPrn:Say(nLin,1600,"Vl. Carga:"+Transf(_nValCarga,"@E 999,999,999.99"),oFont1)

nLin += nEsp
oPrn:Say(nLin,0010,"PIS.....: " +Transf(nTotPis,"@E 999.99"),oFont1)
oPrn:Say(nLin,0400,"COFINS..: " +Transf(nTotCof,"@E 999,999.99"),oFont1)
oPrn:Say(nLin,0860,"CSLL....: " +Transf(nTotCSLL,"@E 999,999.99"),oFont1)
/* SSI 111993 */
nLin += nEsp
oPrn:Say(nLin,0010,"CIDADES.: " +Transf(ROD->QTDCID,"@E 999"),oFont1)
/* SSI 111993 */
nLin += nEsp
// Retirado tipo E a pedido da Núbia em relação a SSI-10054
//oPrn:Say(nLin,0010,"TABELA(-R-Z-T-E-S-D-B-Y-DV-Q-RF-RC-RI-RCO-SV-ST): "+Transf(_nTotTab,"@E 999,999.99"),oFont1)
oPrn:Say(nLin,0010,"TABELA(R-T-S-D-B-DT-DV-Q-RF-RC-RI-RCO-SV-BP): "+Transf(_nTotTab,"@E 999,999.99"),oFont1)

nLin += nEsp*2
IF ROD->ZQ_VALORKM > 0
	oPrn:Say(nLin,0010,"TOTAL EM KM: ",oFont1)
	oPrn:Say(nLin,0280,transform(ROD->ZQ_KILOMET, "@E 999,999.99"),oFont1)
	oPrn:Say(nLin,0500,"VL POR KM: ",oFont1)
	oPrn:Say(nLin,0720,transform(ROD->ZQ_VALORKM, "@E 999,999.99"),oFont1)
	oPrn:Say(nLin,0940,"VL TOTAL: ",oFont1)
	oPrn:Say(nLin,1140,transform(ROD->ZQ_KILOMET*ROD->ZQ_VALORKM, "@E 999,999.99"),oFont1)
	oPrn:Say(nLin,1360,Transf(_nPercFrt,"@E 999.99 %"),oFont1)
ELSE
	oPrn:Say(nLin,0010,"TOTAL DE FRETE PELO PERCENTUAL: ",oFont1)
	if _nValFrete>0
		If cEmpAnt <> "07"
			oPrn:Say(nLin,0700,Transf(_nValFrete,"@E 999,999.99"),oFont1)
		Else
			oPrn:Say(nLin,0700,Transf((_nPercFrt*_nTotValor)/100,"@E 999,999.99"),oFont1)
		Endif
	else
		If cEmpAnt <> "07"
			oPrn:Say(nLin,0700,Transf(_nPercFrt*nTotTabFre/100,"@E 999,999.99"),oFont1)
		Else
			oPrn:Say(nLin,0700,Transf((_nPercFrt*_nTotValor)/100,"@E 999,999.99"),oFont1)
		Endif
	endif
	oPrn:Say(nLin,0960,Transf(_nPercFrt,"@E 999.99 %"),oFont1)
ENDIF

nLin += nEsp *2

oPrn:Say(nLin,0010,"TOTAL DE PEDIDOS DO ROMANEIO: "+Trans(nTotPed,"999"),oFont1)
if MV_PAR07>0
	for i:=1 to len(aEstDA)
		IF aEstDa[i,1]==MV_PAR06
			nLin += nEsp
			oPrn:Say(nLin,0010,"Diferencial Aliquota "+aEstDA[i,1]+": "+Transform(aEstDa[i,2]*MV_PAR07/100,"@E 999,999.99")+" Taxa documento: "+Transform(aEstDA[i,3]*MV_PAR08,"@E 999,999.99"),oFont1)
		endif
		IF aEstDa[i,1]==MV_PAR09
			nLin += nEsp
			oPrn:Say(nLin,0010,"Diferencial Aliquota "+aEstDA[i,1]+": "+Transform(aEstDa[i,2]*MV_PAR10/100,"@E 999,999.99")+" Taxa documento: "+Transform(aEstDA[i,3]*MV_PAR11,"@E 999,999.99"),oFont1)
		endif
	next
endif
aEstDa:={}
nLin += nEsp*3

If nLin + (nEsp * 2) >= MaxLin
	fImpCabec()
Endif

oPrn:Say(nLin,1200,"_______________________________________       ",oFont1)
nLin += nEsp
oPrn:Say(nLin,1200,"        GERENTE ADMINISTRATIVO				  ",oFont1)
nLin += nEsp

If nLin + (nEsp * 8) >= MaxLin
	fImpCabec()
Endif

oPrn:Line(nLin,0000,nLin,3370)
nLin += nEsp

oPrn:Say(nLin,1350,"LEGENDA",oFont1)

nLin += nEsp *2
oPrn:Say(nLin,0010,"V   - VENDA COMERCIAL"				,oFont1)
oPrn:Say(nLin,0950,"F   - VENDA FRANQUIA"				,oFont1)
oPrn:Say(nLin,1900,"EX  - EXCLUSIVA"					,oFont1)
oPrn:Say(nLin,2850,"DT  - DESTRUICAO"					,oFont1)
nLin += nEsp
oPrn:Say(nLin,0010,"P   - PROD.UNID.COMERCIAL"			,oFont1)
oPrn:Say(nLin,0950,"J   - PROD.UNID.FRANQUIA"			,oFont1)
oPrn:Say(nLin,1900,"R   - REPOSICAO"					,oFont1)
oPrn:Say(nLin,2850,"D   - DEMONSTRACAO"					,oFont1)
nLin += nEsp
oPrn:Say(nLin,0010,"DV  - DEVOLUCAO DEFINITIVA"			,oFont1)
oPrn:Say(nLin,0950,"Q   - INSUMOS"						,oFont1)
oPrn:Say(nLin,1900,"B   - BRINDE"						,oFont1)
oPrn:Say(nLin,2850,"SI  - VENDA SITE"					,oFont1)
nLin += nEsp
oPrn:Say(nLin,0010,"A   - TROCA COM VALOR DA FRANQUIA"	,oFont1)
oPrn:Say(nLin,0950,"T   - TROCA"						,oFont1)
oPrn:Say(nLin,1900,"C   - TROCA COM VALOR COIMERCIAL"	,oFont1)
oPrn:Say(nLin,2850,"DE -  DÉBITO ESTATÍSTICA "			,oFont1)
nLin += nEsp
oPrn:Say(nLin,0010,"RI  - REMESSA COMODATO"				,oFont1)
oPrn:Say(nLin,0950,"E   - TROCA DANIFICADO"				,oFont1)
oPrn:Say(nLin,1900,"CS  - REMESSA CONSERTO "			,oFont1)
oPrn:Say(nLin,2850,"BP  - BLUE POINT"					,oFont1)
nLin += nEsp
oPrn:Say(nLin,0010,"RF  - REMESSA FORNEDEDOR"			,oFont1)
oPrn:Say(nLin,0950,"RCO - REMESSA POR CONTA E ORDEM"	,oFont1)
oPrn:Say(nLin,1900,"SV  - PRESTAÇÃO DE SERVICO"			,oFont1)
oPrn:Say(nLin,2850,"VA  - VENDA ANYMARKET"				,oFont1)
nLin += nEsp
oPrn:Line(nLin,0000,nLin,3370)

nLin += nEsp*2

If nLin + (nEsp * 5) >= MaxLin
	fImpCabec()
Endif

//Início SSI 10853
_aAreaA4 := GetArea()
DbSelectArea("SA4")
DbSetOrder(1)
If DbSeek(xFilial("SA4")+ROD->CODMOT)
	_cNomMot	:= alltrim(SA4->A4_COD)+" - "+alltrim(SA4->A4_NOME)
	_cPlaca		:= alltrim(SA4->A4_XPLACA)
	_cCpf		:= alltrim(SA4->A4_CGC)
	_cCnh		:= Alltrim(SA4->A4_XCNH)
EndIf
RestArea(_aAreaA4)
//Fim SSI 10853

oPrn:Say(nLin,0800,"MOTORISTA",oFont1)
oPrn:Say(nLin,1400,"PRAZO ACERTADO DE RETORNO",oFont1)
//oPrn:Say(nLin,2000,"PLACA:",oFont1) SSI 10853
nLin += nEsp*2
dbSelectArea("SM0")
dbSeek(cEmpAnt+cFilAnt)
oPrn:Say(nLin,0010,Alltrim(SM0->M0_CIDENT)+", "+SM0->M0_ESTENT,oFont1)
oPrn:Say(nLin,0800,"___/___/___",oFont1)
oPrn:Say(nLin,1500,"___/___/___",oFont1)
oPrn:Say(nLin,2000,"_____________________________",oFont1)
nLin += nEsp
oPrn:Say(nLin,2000,"ASSINATURA MOTORISTA/COBRADOR",oFont1)
//Início SSI 10853
nLin += nEsp
oPrn:Say(nLin,2000,"PLACA: "+_cPlaca,oFont1)
nLin += nEsp
oPrn:Say(nLin,2000,"NOME: "+_cNomMot,oFont1)
nLin += nEsp
oPrn:Say(nLin,2000,"CPF: "+_cCpf,oFont1)
nLin += nEsp
oPrn:Say(nLin,2000,"CNH: "+_cCnh,oFont1)
//Fim SSI 10853


_nTotTab:=0
_nValFrete:=0
nTotTabFre :=0

Return()

***************************
Static Function ValidPerg()
***************************

Local aAreaAtu := GetArea()
Local aRegs    := {}

Aadd(aRegs,{cPerg  , "01"   , "Embarque Inicial....?" ,"","", "mv_ch1" , "C"   , 06      , 0,0        ,"G"  ,""     ,"mv_par01",""  ,""     ,""     ,""     ,""     ,"","","","","","","","","",""  ,"","","","","","","","","","",""     })
Aadd(aRegs,{cPerg  , "02"   , "Embarque Final......?" ,"","", "mv_ch2" , "C"   , 06      , 0,0        ,"G"  ,""     ,"mv_par02",""  ,""     ,""     ,""     ,""     ,"","","","","","","","","",""  ,"","","","","","","","","","",""     })
Aadd(aRegs,{cPerg  , "03"   , "Numero de Copias....?" ,"","", "mv_ch3" , "N"   , 02      , 0,0        ,"G"  ,""     ,"mv_par03",""  ,""     ,""     ,""     ,""     ,"","","","","","","","","",""  ,"","","","","","","","","","",""     })
Aadd(aRegs,{cPerg  , "04"   , "Da data.............?" ,"","", "mv_ch4" , "D"   , 08      , 0,0        ,"G"  ,""     ,"mv_par04",""  ,""     ,""     ,""     ,""     ,"","","","","","","","","",""  ,"","","","","","","","","","",""     })
Aadd(aRegs,{cPerg  , "05"   , "Ate a data..........?" ,"","", "mv_ch5" , "D"   , 08      , 0,0        ,"G"  ,""     ,"mv_par05",""  ,""     ,""     ,""     ,""     ,"","","","","","","","","",""  ,"","","","","","","","","","",""     })
Aadd(aRegs,{cPerg  , "06"   , "UF Dif.Aliquota.....?" ,"","", "mv_ch6" , "C"   , 02      , 0,0        ,"G"  ,""     ,"mv_par06",""  ,""     ,""     ,""     ,""     ,"","","","","","","","","",""  ,"","","","","","","","","","",""     })
Aadd(aRegs,{cPerg  , "07"   , "Perc.Dif.Aliquota...?" ,"","", "mv_ch7" , "N"   , 05      , 2,0        ,"G"  ,""     ,"mv_par07",""  ,""     ,""     ,""     ,""     ,"","","","","","","","","",""  ,"","","","","","","","","","",""     })
Aadd(aRegs,{cPerg  , "08"   , "Taxa por documento..?" ,"","", "mv_ch8" , "N"   , 08      , 2,0        ,"G"  ,""     ,"mv_par08",""  ,""     ,""     ,""     ,""     ,"","","","","","","","","",""  ,"","","","","","","","","","",""     })
Aadd(aRegs,{cPerg  , "09"   , "UF Dif.Aliquota.....?" ,"","", "mv_ch9" , "C"   , 02      , 0,0        ,"G"  ,""     ,"mv_par09",""  ,""     ,""     ,""     ,""     ,"","","","","","","","","",""  ,"","","","","","","","","","",""     })
Aadd(aRegs,{cPerg  , "10"   , "Perc.Dif.Aliquota...?" ,"","", "mv_chA" , "N"   , 05      , 2,0        ,"G"  ,""     ,"mv_par10",""  ,""     ,""     ,""     ,""     ,"","","","","","","","","",""  ,"","","","","","","","","","",""     })
Aadd(aRegs,{cPerg  , "11"   , "Taxa por documento..?" ,"","", "mv_chB" , "N"   , 08      , 2,0        ,"G"  ,""     ,"mv_par11",""  ,""     ,""     ,""     ,""     ,"","","","","","","","","",""  ,"","","","","","","","","","",""     })

cPerg := U_AjustaSx1(cPerg,aRegs)

RestArea( aAreaAtu )

Return(.T.)
