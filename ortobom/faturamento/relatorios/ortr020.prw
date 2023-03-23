#include "TbiConn.ch"
#include "rwmake.ch"
#include "protheus.ch"
#include "TopConn.ch"
#include "colors.ch"
#include "font.ch"
#INCLUDE "JPEG.CH"

*****************************************************************************
* Programas Contidos neste Fonte                                            *
*****************************************************************************
* User Functions                                                            *
*---------------------------------------------------------------------------*
* OrtR020()                                                                 *
*---------------------------------------------------------------------------*
* Static Functions                                                          *
*---------------------------------------------------------------------------*
* RunReport()    | ValidPerg()    | ImpRodap()     |                        *
*****************************************************************************
* Tabelas Utilizadas (SC5, SA1)                                             *                     
*****************************************************************************
* Parametros:                                                               *
*****************************************************************************

*****************************************************************************
*+-------------------------------------------------------------------------+*
*|Funcao      | OrtR020  | Autor |  Ricardo Ferreira                       |*
*+------------+------------------------------------------------------------|*
*|Data        | 17.03.2006                                                 |*
*+------------+------------------------------------------------------------+*
*|Descricao   | Pedido de Circulacao interna                               |*
*|            |                                                            |*
*+-------------------------------------------------------------------------+*
*|Alterado por| Evaldo Mufalani	         | Data | 20/04/2006               |*
*+-------------------------------------------------------------------------+*
*|Descricao   |-Incluido parâmetro MV_PAR09, que define se Imprime Pedidos |*
*|            | do Segmento de LOJAS ;                                     |*
*|            |-Incluido parâmetro MV_PAR10, que filtra o OPERADOR que     |*
*|            | incluiu o Pedido ;                                         |*
*|            |-Inclusão de Condição para verificar a Impressão do Prazo   |*
*|            | Medio ou SEM VALOR COMERCIAL - C5_XOPER ;                  |*
*+-------------------------------------------------------------------------+*
*|Alterado por| Cleverson L. Schaefer    | Data | 09/06/2006               |*
*+-------------------------------------------------------------------------+*
*|Descricao   |-Inclusao de teste com campo C5_XOPER, com tipo 05 (brinde) |*
*|            | para impressao da situacao do pedido.                      |*
*+-------------------------------------------------------------------------+*
*|Alterado por| Marcio William   | Data | 24/04/2009                       |*
*+-------------------------------------------------------------------------+*
*|Descricao   |-Acrescentado o motivo do cancelamento e informações sobre  |*
*|            | o pedido quando tiver data de liberação tais como :        |*
*|            | Número do TQ , Data da Programação, Data do Cancelamento , |*
*|            | Data da Saída e Data da Liberação. 	                       |*
*|            |-Retirando os campos operação,Tp. Pedido e Tp Pagamento     |*
*|            |  pois as informações estavam duplicadas                    |*
*+-------------------------------------------------------------------------+*
*|Alterado por| Marcio William   | Data | 18/05/2009                       |*
*+-------------------------------------------------------------------------+*
*|Descricao   |-Retirado o filtro de pedidos de Troca.                     |*
*+-------------------------------------------------------------------------+*
*|Alterado por| Marcio William   | Data | 28/04/2010                       |*
*+-------------------------------------------------------------------------+*
*|Descricao   |- Acrescenta as mensagens da SC5, campos :                  |*
*|             - C5_MENPAD  / C5_XMENPA2 / C5_XMENPA3 / C5_MENNOTA         |*
*|             - C5_XMENNF2 / C5_XMENNF1 / C5_XMENNF3.                     |*
*|             - Adcionado informacoes fiscais do produto.                 |*
*| SSI : 13533                                                             |*
*+-------------------------------------------------------------------------+*
*|Alterado por| Marcio William   | Data | 29/07/2010                       |*
*+-------------------------------------------------------------------------+*
*|Descricao   |- Acrescentado os descontos p/tipo distribuidor(ZH_DISTRIB) |*
*|             - LINHA 740 DO FONTE                                        |*
*|             - ZZ_TIPO = 1 -> FINANCEIRO                                 |*
*|             - ZZ_TIPO = 2 -> QUANTITATIVO                               |*
*|             - ZZ_TIPO = 3 -> DISTRIBUIDOR                               |*
*+-------------------------------------------------------------------------+*
*|Alterado por| J                | Data | 31/05/2012                       |*
*+-------------------------------------------------------------------------+*
*|Descricao   |- SSI 24808                                                 |*
*+-------------------------------------------------------------------------+*
*|Alterado por| J                | Data | 27/06/2012                       |*
*+-------------------------------------------------------------------------+*
*|Descricao   |- SSI 25761                                                 |*
*+-------------------------------------------------------------------------+*
*|Alterado por| Fagner Oliveira da Silva  | Data | 06/04/2013              |*
*+-------------------------------------------------------------------------+*
*|Este trecho do programa foi Alterado a pedido do DUPIM em atendimento    |*
*|ao SSI-27230. Foi feita uma validação para não permitir que pedidos do   |*
*|segmento 3 ou 4 sejam impressos.                                         |*
*+-------------------------------------------------------------------------+*
*|Alterado por| Marcos Furtado            | Data | 02/05/2013              |*
*+-------------------------------------------------------------------------+*
*|Atendimento da SSI 27944 - Ajuste com campo comissao.                    |*
*+-------------------------------------------------------------------------+*
*|Alterado por| Marcos Furtado            | Data | 20/05/2013              |*
*+-------------------------------------------------------------------------+*
*|Inclusão das observações do Pedido.                                      |*
*+-------------------------------------------------------------------------+*
*|Alterado por| Gilvan Couto              | Data | 29/05/2013              |*
*+-------------------------------------------------------------------------+*
*|Conversão para modo grafico.                                             |*
*+-------------------------------------------------------------------------+*
*|Alterado por| Fábio Costa               | Data | 05/08/2013              |*
*+-------------------------------------------------------------------------+*
*|SSI 30659 - Alterações referente aos campos de quantidade                |*
*+-------------------------------------------------------------------------+*
*|Alterado por| Gustavo Thees Castro      | Data | 27/02/2015              |*
*+-------------------------------------------------------------------------+*
*|SSI 8893 - Inclusão do campo Peso Liquido                                |*
*+-------------------------------------------------------------------------+*
*|SIS CI 022 Adm/CPD - Joni Fujiyama   	  | Data | 29/07/2019       	   |*
*|Ajuste na linha de Endereço, complemento, bairro e município             |*
*+-------------------------------------------------------------------------+*
*****************************************************************************
// SSI - 68788 - Peder Munksgaard - 13/09/218
// Melhorias na regua de processamento a fim de amenizar sensação
// de travamento do relatório por parte dos usuários.

User Function ORTR020()
***********************

Private cPict          := ""
Private titulo         := "Pedidos de Circulação Interna"
Private Cabec1         := ""
Private Cabec2         := ""
Private imprime        := .T.
Private aOrd 		   := {}
//Private aCols		   :=	{}

Private cDesc1       := "USUARIO       : GER.GERAL, GER.LOJA, ASSESSORES E GESTORES "
Private cDesc2       := "OBJETIVO      : PEDIDO PARA CIRCULACAO INTERNA             "
Private cDesc3       := "PER.UTILIZACAO: DIARIA                                     "
//Private cCabDet      := "PEDIDO  TAB DATA  QTD      %  VALOR R$   VALOR T PRZ TP DIFERENCA|PEDIDO  TAB DATA  QTD      %  VALOR R$   VALOR T PRZ TP DIFERENCA"
//                       9999999 999 99/99 000 99,999 99.999,99 99.999,99 999 99 99.999,99|9999999 999 88/99 000 99,999 99.999,99 99.999,99 999 99 99.999,99
//                                10        20        30        40        50        60        70        80        90       100       110       120       130       140       150       160       170       180       190       200       210       220
//                       01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890
Private nEsp         := 50
Private nEsp2        := 75
Private nLin         := 50
Private lEnd         := .F.
Private lAbortPrint  := .F.
Private limite       := 250//132
Private tamanho      := "M"
Private nomeprog     := "ORTR20"
Private nTipo        := 15
Private aReturn      := { "Zebrado", 1, "Administracao", 1, 2, 1, "", 1}
Private nLastKey     := 0
Private cbtxt        := Space(10)
Private cbcont       := 00
Private CONTFL       := 01
Private m_pag        := 01
Private wnrel        := "ORTR20"
Private cPerg        := "ORTR20"
Private cString      := "SC5"
Private aMENNOTA     :={}
Private lImp := .F.
//Totalizadores do rodapé
Private nTotParc := 0
Private nTotProds:= 0
Private nTotCusto:= 0
Private nTCusto  := 0
Private nTotEsp  := 0
Private nTotDesc := 0
Private nTotPruni:=0
Private nTotPrcve:=0
Private _aItens	 :={}
Private aMedTri  :={}
Private aPed     :={}
Private nTotPeca := 0
Private nTotMkp  := 0
Private nTotMix  := 0
Private x        := 0
Private ndesconto:= 0
Private cCodCli  := Space(6)
Private cLojaCli := Space(2)
Private _nVlrUPME	:=	0
Private _nMedComp	:=	0
Private _oDlg,_oSayPed,_oBtnOK,_oGetPed,_oBtnCanc,_oBtnImp,_oSayTitulo
Private _cPed		:=	" " //Space(6)
Private _cPedidos	:=	" "
Private _cDtEntreg	:=	Space(8)
Private nVerba      := 0
Private nVerbaExt   := 0
Private msgFisc1    := ""
Private msgFisc2    := ""
Private msgFisc3    := ""
Private msgNota     := ""
Private msgNfe1     := ""
Private msgNfe2     := ""
Private msgNfe3     := ""
Private dDataDe		:= ""
Private dDataAte    := ""
Private nQtdProd    := 0
//PREPARE ENVIRONMENT EMPRESA "03" FILIAL "02" MODULO "FAT"

//ValidPerg(cPerg)
//Pergunte(cPerg,.t.)
Private lTit		:= .t.
Private MaxLin 		:= 2400
Private oPrn
Private oFont1	:= TFont():New( "Courier New",,11,,.T.,,,,,.F.)

Private _cMsgQOri	:= "" //SSI 9366
Private _cPedCli	:= "" //SSI 10813
Private _cA1Msg	:= "" //SSI 9675


oPrn:= TReport():New("ORTR20",Titulo,,{|oPrn| GeraRel(oPrn)},Titulo)
oPrn:HideHeader() //oculta cabeçalho
oPrn:HideFooter() //oculta rodapé
oPrn:SetLandscape()    //   SETA A PAGINA COMO PADRAO PAISAGEM
//oPrn:SetPortrait()    //   SETA A PAGINA COMO PADRAO PAISAGEM
oPrn:DisableOrietation()
oPrn:SetEdit(.F.)         // Bloqueia personalizar
oPrn:NoUserFilter()       // nao permite criar FIltro de usuario
oPrn:PrintDialog()

if oPrn:Cancel()
	Return
EndIf

FreeObj(oPrn)
oPrn := Nil
Return


Static Function GeraRel(oPrn)
apedidos := Digpedido() // funcao que monta tela para digitacao dos pedidos ( parametros para o relatorio )
Return

//Private oFont1	:= TFont():New( "Courier New",,09,,.T.,,,,,.F.)
/*
oPrn := TMSPrinter():New(cPerg + " - " + titulo)
oPrn:Setup()
//oPrn:StartPage()
oPrn:SetLandScape()
oPrn:SetSize(297, 210)
apedidos := Digpedido() // funcao que monta tela para digitacao dos pedidos ( parametros para o relatorio )
Return
*/

Static Function fImp()

_nCont   := 0
_cPedidos:=" "
/*
for i:=1 to Len(aCols)
If	!Empty(aCols[i,1])
_cPedidos+="'"+aCols[i,1]+"'"
if i < Len(aCols)
_cPedidos+=","
endif
Endif
next
*/
If	!Empty(dDataDe)	.And. !Empty(dDataAte)
	if dDataAte-dDataDe> 7
		Alert("Nao e permitida a execução desse relatorio para um periodo superior a 7 dias")
		Return()
	endif
	aCols	:=	{}
	if lImpNag .or. lImpNeg
		_cQryA	:=	"SELECT DISTINCT DECODE(C5_XPEDDES,'      ',C5_NUM,C5_XPEDDES) C5_NUM "
	Else
		_cQryA	:=	"SELECT C5_NUM "
	Endif
	_cQryA	+=	"FROM SIGA."+RetSqlName("SC5")+" WHERE C5_FILIAL = '"+xFilial("SC5")+"' AND D_E_L_E_T_ = ' ' "
	_cQryA	+=	"AND C5_EMISSAO BETWEEN '"+Dtos(dDataDe)+"' AND '"+Dtos(dDataAte)+"'  AND C5_XOPER <> '17' "
	_cQryA	+=	"AND C5_XEMBARQ < '5' "
	_cQryA	+=	"AND C5_FILIAL = '"+xFilial("SC5")+"' "
	if (lPedImp)
		_cQryA	+=	" AND C5_COTACAO ='IMPPDA' AND C5_XPEDMAE <> 'T' "
		//	_cQryA	+=	" AND ( ( C5_XMOTCAN = '98' AND C5_XOPER = '99' AND C5_XDTLIB <> ' ' ) OR C5_XDTLIB = ' ' )  "
	endif
	//PEDIDO DE TERCEIROS DAS UNIDADES
	if (lPedUni)
		_cQryA	+=	" AND C5_XPEDCLI <> ' ' "
		_cQryA	+=	" AND C5_XUNORI <> ' ' "
	endif
	//Início SSI 3230
	If !Empty(cclide) .and. !Empty(ccliate)
		_cQryA	+=	" AND C5_CLIENTE BETWEEN '"+cclide+"' AND '"+ccliate+"' "
	EndIf
	//Fim SSI 3230
	
	TcQuery _cQryA Alias "RNGPED" New
	
	//SSI - 68788
	dbSelectArea("RNGPED")
	Count to _nCont
	RNGPED->(dbGotop())
	
	oPrn:SetMeter(_nCont)
	oPrn:IncMeter()
	//
	
	
	While !EOF()
		oPrn:IncMeter()
		Aadd(aCols,{RNGPED->C5_NUM,.F.})
		RNGPED->(DbSkip())
	Enddo
	
	RNGPED->(DbCloseArea())
	
	//Início SSI 3230
ElseIf	!Empty(cclide)	.And. !Empty(ccliate)
	aCols	:=	{}
	if lImpNag .or. lImpNeg
		_cQryA	:=	"SELECT DISTINCT DECODE(C5_XPEDDES,'      ',C5_NUM,C5_XPEDDES) C5_NUM "
	Else
		_cQryA	:=	"SELECT C5_NUM "
	Endif
	_cQryA	:=	"FROM SIGA."+RetSqlName("SC5")+" WHERE C5_FILIAL = '"+xFilial("SC5")+"' AND D_E_L_E_T_ = ' ' "
	_cQryA	+=	"AND C5_CLIENTE BETWEEN '"+cclide+"' AND '"+ccliate+"'  AND C5_XOPER <> '17' "
	_cQryA	+=	"AND C5_XEMBARQ < '5' "
	_cQryA	+=	"AND C5_FILIAL = '"+xFilial("SC5")+"' "
	if (lPedImp)
		_cQryA	+=	" AND C5_COTACAO ='IMPPDA' AND C5_XPEDMAE <> 'T' "
	endif
	//PEDIDO DE TERCEIROS DAS UNIDADES
	if (lPedUni)
		_cQryA	+=	" AND C5_XPEDCLI <> ' ' "
	endif
	
	TcQuery _cQryA Alias "RNGPED" New
	
	//SSI - 68788
	dbSelectArea("RNGPED")
	Count to _nCont
	RNGPED->(dbGotop())
	
	oPrn:SetMeter(_nCont)
	oPrn:IncMeter()
	//
	
	While !EOF()
		oPrn:IncMeter()
		Aadd(aCols,{RNGPED->C5_NUM,.F.})
		RNGPED->(DbSkip())
	Enddo
	
	RNGPED->(DbCloseArea())
	//Fim SSI 3230
Endif


dbSelectArea("SC5")
dbOrderNickName("PSC51")
/*
wnrel := SetPrint(cString,NomeProg,"",@titulo,cDesc1,cDesc2,cDesc3,.T.,aOrd,.F.,Tamanho,,.T.)

If nLastKey == 27
Return
Endif

SetDefault(aReturn,cString)

If nLastKey == 27
Return
Endif

nTipo := If(aReturn[4]==1,15,18)
*/
RptStatus({|| RunReport(Cabec1,Cabec2,Titulo,nLin) },Titulo)
Return



*******************************************************************************
* Funcao : RUNREPORT   * Autor : Ricardo Ferreira        * Data : 13/03/2006  *
*******************************************************************************
* Descricao : Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTASUS      *
*             monta a janela com a regua de processamento do relatorio.       *
*******************************************************************************
* Uso       : OrtR020                                                         *
*******************************************************************************

Static Function RunReport(Cabec1,Cabec2,Titulo,nLin)
****************************************************

Local cQuery 	:=""
//Local cPed   	:=""
//Local nLin   	:=1
local aMedCli   := {}
Local i      	:=0
Local cGruPer	:= ""
Local nPerCom	:= 0
Local _nCont    := 0

Private _COBSCOB := ""
Private ntotalKg := 0
private _nprum   := ""
Private lDescAutGer	:= .F.
Private _cDesmembra := ""
Private _cDesmeORI := ""
Private _cDesmeOBS := ""
dbSelectArea(cString)
dbSetOrder(1)//nao trocar

// DECODE(C6_XCUSTO, 0, 0, ROUND(C6_XPRUNIT/C6_XCUSTO,2)),
// Evaldo: 20/04/2006 => incluido C5_XOPER na Query

//SSI - 68788
//SetRegua(len(aCols))
oPrn:SetMeter(len(aCols))
//

for i:=1 to len(aCols)
	
	//SSI - 68788
	oPrn:IncMeter()
	//
	if !acols[i,2]
		
		if len(alltrim(aCols[i,1]))==6
			cSegm := Posicione("SC5",1,xFilial("SC5")+aCols[i,1],"C5_XTPSEGM")
		else
			cSegm := Posicione("SC5",7,xFilial("SC5")+aCols[i,1],"C5_XTPSEGM")
		endif
		
		//		cQuery:=" SELECT  C5_XPEDFIC,C5_XTALSAC,C5_XVALENT,C6_TES,A1_NOME, C5_XREFTAB,             "
		cQuery:=" SELECT C5_XOBSCAN, C5_XPEDDES, C5_XNPVORT, C5_XRESTRI, C5_XPEDFIC,C5_XVALENT,C5_TIPOCLI,C6_TES,A1_NOME, C5_XREFTAB,C5_XFEIRAO, B1_UM, B1_SEGUM, B1_XALT, B1_XLARG, B1_XCOMP,       "
		cQuery+=" C5_MENPAD , C5_XMENPA2 , C5_XMENPA3, C5_MENNOTA , C5_XMENNF1 , C5_XMENNF2 , C5_XMENNF3, B1_POSIPI,"
		cQuery+=" C5_XMENLIB,C5_XTPSEGM,"
		if lImpNag
			cQuery+=	" DECODE(C5_XPEDDES,'      ',C5_NUM,C5_XPEDDES) " //Caso Negociacao grupada saem todos com o numero do pedido agrupador
		Endif
		cQuery+=" C5_NUM, C5_EMISSAO, A1_COD, A1_LOJA, C5_CLIENT,"
		cQuery+=" A1_XCIDADE, A1_NREDUZ, A1_END, A1_XCMPEND, A1_TEL, A1_DDD,A1_BAIRRO, "
		cQuery+=" A1_MUN, NVL(CC2_MUN,'NAO CADASTRADO') CC2_MUN, A1_XQTDLP,A1_XQTDCHS,A1_XQTDCTS, A1_CGC, A1_XCLI100, A1_XCLIEXC,           "
		cQuery+=" A1_XQTDPRG,A1_XQTDPRO,A1_XQTDPEN,A1_XQTDPRM,C5_XENTREG, C6_QTDVEN*B1_PESO PESOIT,   "
		cQuery+=" C5_XENTREF, C5_XTPCOMP, C5_CLIENTE, C5_LOJACLI,A1_XROTA,  C5_TPFRETE, "
		cQuery+=" C5_XUNORI, A1_MENSAGE, C5_XPEDCLI,	 " //SSI 9225 - Thais //SSI 9675 - Inclusão do A1_MENSAGE //SSI 10813
		cQuery+=" ( SELECT COUNT(*) AS COUNT FROM SIGA."+RetSqlName("SA1")+" SA1R "
		cQuery+="    WHERE SA1R.A1_XCODCOM = SA1.A1_XCODCOM  				 "
		cQuery+="    AND SA1R.A1_FILIAL = '" + XFILIAL("SA1") + "' "
		cQuery+="    AND SA1R.D_E_L_E_T_ = ' '               				 "
		cQuery+="    AND SA1R.A1_XCODCOM <> ' ') COUNT,      				 "
		
		cQuery+=" ( SELECT ZP_OBS FROM SIGA."+RetSqlName("SZP")+" SZP             "
		cQuery+="	 WHERE ZP_DATA IN ( SELECT MAX(ZP_DATA) FROM "+RetSqlName("SZP")+" SZP "
		cQuery+="	                    WHERE  ZP_CLIENTE = SA1.A1_COD   "
		cQuery+="	 					AND ZP_CLIENTE = SA1.A1_COD 		 "
		cQuery+="    					AND ZP_FILIAL = '" + XFILIAL("SZP") + "' "
		cQuery+="    					AND SZP.D_E_L_E_T_ = ' ' )           "
		cQuery+="	 AND ZP_CLIENTE = SA1.A1_COD 							 "
		cQuery+="    AND ZP_FILIAL = '" + XFILIAL("SZP") + "'                "
		cQuery+="    AND SZP.D_E_L_E_T_ = ' ' AND ROWNUM = 1 "
		cQuery+="    ) OBSCOB,                                               "
		cQuery+=" ( C6_XPRUNIT*((100-C6_XGUELTA-C6_XRESSAR)/100)*C6_QTDVEN) VB,"
		cQuery+=" ( CASE WHEN BM_XSUBGRU NOT IN ('20007I', '00009G', '10006G', '10007O', '20008I') AND B1_XMODELO NOT IN ('000015') AND C6_TES NOT IN ('517', '518') THEN  C6_XCUSTO*C6_QTDVEN ELSE 0 END ) CUSTO2,"
		cQuery+="   A1_EST, A1_CEP, C5_VEND1, C5_XPRZMED, C5_TABELA, C5_TIPO, C6_PRODUTO, "
		cQuery+="   C6_QTDVEN, C6_DESCRI, B1_DESC, B1_XPERSON, B1_XMED,B1_XCHANFR, B1_PESO,  C6_PRCVEN, B1_XESPACO,B1_IPI, C5_XENTREG, C6_DESCONT, "
		cQuery+="	(C6_QTDVEN*C6_XPRUNIT) AS PRTOT, Round((C6_QTDVEN*C6_PRCVEN),2) AS PRPROD, (C6_QTDVEN*C6_PRCVEN) AS DFPRPROD,"
		cQuery+="   DECODE(B1_XMODELO,'000008',ROUND(C6_PRCVEN*C6_QTDVEN/DECODE(C6_UNSVEN,0,1,C6_UNSVEN),2),'000018',ROUND((C6_QTDVEN*C6_XPRUNIT)/DECODE(C6_UNSVEN,0,1,C6_UNSVEN),2),'000011',DECODE(C6_XTPMED,'2',ROUND(C6_XPRUNIT*C6_QTDVEN/DECODE(C6_UNSVEN,0,1,C6_UNSVEN),2),C6_XPRUNIT),C6_XPRUNIT) As XPRUNIT,  C6_XPRUNIT, "
		cQuery+="  (C6_QTDVEN*C6_XCUSTO) AS CUSTTOT, C6_XCUSTO, "
		cQuery+="   B1_TIPO, C6_UNSVEN, (C6_QTDVEN*C6_XPRUNIT) C6_VALOR, C5_TRANSP, B1_XMODELO, "

&& Henrique - 03/01/2020
&&            Estava apresentando erro no campo C6_XMARKUP. SSI número 89248
&&		cQuery+="   A3_NREDUZ, A1_CONTATO, C5_USERLGI, C5_XTPPGT, C6_XMARKUP, "
		cQuery+="   A3_NREDUZ, A1_CONTATO, C5_USERLGI, C5_XTPPGT,C6_XMARKUP, "
	   //	cQuery+="   (Select DISTINCT C6_XMARKUP From Siga." +RetSQLName("SC6")+ " Where C6_NUM = C5_NUM) C6_XMARKUP,"  // Retirado pois estava apresentando erro. Marcela Coimbra

		cQuery+="   C5_XTELEMK, C6_XMIX, C6_XOBS, C5_XOBSADI, C5_XOBSFAB, C5_CONDPAG, "
		cQuery+="	Z5_DTREN,C6_XTPMED, B1_XCOMP, "
		cQuery+="	B1_XALT*B1_XLARG*B1_XCOMP VOLUME, A1_XQTDCOM,C6_ITEM, B1_XMODELO, "
		cQuery+="   F4_XDUPLIC, C5_XOPER, C5_XDESPRO,C5_XORDCOM,B1_XDESCEX, "
		cQuery+="   DESQTD, DESFIN, PRCDES, PRCTAB, B1_XMODELO, (SELECT SUM(E3_COMIS) "
		cQuery+="  FROM SIGA."+RETSQLNAME("SE3")+" SE3 "
		cQuery+=" WHERE D_E_L_E_T_ = ' ' "
		cQuery+="   AND E3_FILIAL = '"+XFILIAL("SE3")+"' "
		cQuery+="   AND E3_CODCLI = C5_CLIENTE "
		cQuery+="   AND E3_LOJA = C5_LOJACLI "
		cQuery+="   AND E3_NUM = C5_NUM) TQ, "
		cQuery+="  NVL( (SELECT SUM(Z5_LIMTOT) FROM SIGA."+RetSqlName("SZ5")+" SZ51 "
		cQuery+="          WHERE SZ51.Z5_FILIAL = '"+xFilial("SZ5")+"' "
		cQuery+="          AND SZ51.D_E_L_E_T_ = ' '              "
		cQuery+="          AND SZ51.Z5_SEGMENT = ' '              " //Adicionado por Bruno  em 01/06/09 por causa da mudança na SZ5
		cQuery+="          AND Z5_CLIENTE IN (SELECT A1_COD FROM SIGA." +RetSQLName("SA1") + " SA13 "
		cQuery+="                            WHERE SA13.A1_FILIAL = '"+xFilial("SA1")+"'  "
		cQuery+="                              AND SA13.D_E_L_E_T_ = ' '                  "
		cQuery+="                              AND SA13.A1_XCODCOM = SA1.A1_XCODCOM)),0) AS Z5_LIMTOT, "
		cQuery+="  NVL( (SELECT SUM(Z5_LIMAUTO) FROM "+RetSqlName("SZ5")+" SZ52 "
		cQuery+="        WHERE SZ52.Z5_FILIAL = '"+xFilial("SZ5")+"' "
		cQuery+="        AND  SZ52.D_E_L_E_T_ = ' ' 				 "
		cQuery+="        AND  SZ52.Z5_SEGMENT = ' ' 				 " //Adicionado por Bruno  em 01/06/09 por causa da mudança na SZ5
		cQuery+="        AND  SZ52.Z5_CLIENTE IN (SELECT A1_COD FROM SIGA." +RetSQLName("SA1") + " SA13 "
		cQuery+="                            WHERE SA13.A1_FILIAL = '"+xFilial("SA1")+"'  "
		cQuery+="                              AND SA13.A1_XCODCOM = SA1.A1_XCODCOM "
		cQuery+="                              AND SA13.D_E_L_E_T_ = ' ')),0) AS Z5_LIMAUTO, "
		cQuery+=" NVL( (SELECT SUM(E1_SALDO) FROM " +RetSQLName("SE1") + " SE1   "
		cQuery+="        WHERE SE1.E1_FILIAL = '"+xFilial("SE1")+"' "
		cQuery+="        AND E1_SALDO > 0                           "
		cQuery+="        AND E1_CLIENTE IN (SELECT A1_COD FROM SIGA." +RetSQLName("SA1") + " SA13 "
		cQuery+="                            WHERE SA13.A1_FILIAL = '"+xFilial("SA1")+"'  "
		cQuery+="                              AND SA13.A1_XCODCOM = SA1.A1_XCODCOM "
		cQuery+="                              AND SA13.D_E_L_E_T_ = ' ')            "
		cQuery+="        AND SE1.D_E_L_E_T_ = ' '),0) AS LIMCONS,   "
		cQuery+=" NVL( (SELECT /*+ INDEX(SE12 SE11508) */ COUNT(E1_SALDO) FROM SIGA."+RetSQLName("SE1") + " SE12 "
		cQuery+="        WHERE SE12.E1_FILIAL = '"+xFilial("SE1")+"' "
		cQuery+="        AND SE12.E1_VENCREA < '"+Dtos(dDataBase)+"' "
		cQuery+="        AND SE12.E1_TIPO IN ('DP','DPC')            "
		cQuery+="        AND SE12.E1_SALDO > 0                       "
		cQuery+="        AND E1_CLIENTE IN (SELECT A1_COD FROM SIGA." +RetSQLName("SA1") + " SA13 "
		cQuery+="                            WHERE SA13.A1_FILIAL = '"+xFilial("SA1")+"'  "
		cQuery+="                              AND SA13.A1_XCODCOM = SA1.A1_XCODCOM "
		cQuery+="                              AND SA13.D_E_L_E_T_ = ' ')            "
		cQuery+="        AND SE12.D_E_L_E_T_ = ' '),0) AS QTDDP,     "
		cQuery+=" NVL( (SELECT COUNT(E1_SALDO) "
		cQuery+=" FROM COBR"+CEMPANT+"0 SE13 "
		cQuery+="        WHERE SE13.E1_VENCREA < '"+Dtos(dDataBase)+"' "
		cQuery+="          AND SE13.E1_FILIAL = '"+xFilial("SE1")+"' "
		cQuery+="          AND SE13.E1_TIPO IN ('PEN')				 "
		cQuery+="          AND SE13.E1_SALDO > 0 					 "
		cQuery+="          AND SE13.E1_CLIENTE IN (SELECT A1_COD FROM SIGA." +RetSQLName("SA1") + " SA13 "
		cQuery+="                            WHERE SA13.A1_FILIAL  = '"+xFilial("SA1")+"'  "
		cQuery+="                              AND SA13.A1_XCODCOM = SA1.A1_XCODCOM  "
		cQuery+="                              AND SA13.D_E_L_E_T_ = ' ')            "
		cQuery+="        ),0) AS QTDPEN 	 "
		cQuery+="  , X5_DESCRI , ZQ_DTPREVE , ZQ_DTEMBAR , C5_XDTLIB , C5_XEMBARQ , c5_nota , ZH_ITINER , C5_XVERREP, C5_XVEREXT , ZH_CLIESP, B1_XCODBAS, B1_GRUPO, B1_XSEGMEN, C6_XFEILOJ, C5_XNICHO "
		cQuery+="FROM SIGA."+RetSqlName("SA3")+" SA3, "
		cQuery+="     SIGA."+RetSqlName("SA1")+" SA1, "
		cQuery+="     SIGA."+RetSqlName("SZ5")+" SZ5, "
		cQuery+="     SIGA."+RetSqlName("SZH")+" SZH,  "
		cQuery+="     SIGA."+RetSqlName("SZQ")+" SZQ,"
		cQuery+="     SIGA."+RetSqlName("SX5")+" SX5, "
		cQuery+="     SIGA."+RetSqlName("CC2")+" CC2,  "
		cQuery+="     PCI"+cEmpAnt+"0 PCI  "
		cQuery+="  WHERE SA1.D_E_L_E_T_ = ' '  "
		cQuery+="  AND CC2.D_E_L_E_T_(+) = ' ' "
		cQuery+="  AND SZ5.Z5_SEGMENT(+) = ' ' " //Adicionado por Bruno  em 01/06/09 por causa da mudança na SZ5
		cQuery+="  AND A1_COD = Z5_CLIENTE(+)  "
		cQuery+="  AND A1_LOJA = Z5_LOJA(+)    "
		cQuery+="  AND CC2_FILIAL(+) = ' ' "
		cQuery+="  AND CC2_EST(+)    = A1_EST "
		cQuery+="  AND CC2_CODMUN(+) = A1_COD_MUN "
		cQuery+="  AND ZQ_EMBARQ(+) = C5_XEMBARQ "
		cQuery+="  AND ZQ_EMBARQ(+) <> '          '   "
		cQuery+="  AND C5_XMOTCAN  = X5_CHAVE (+) "
		cQuery+="  AND X5_TABELA (+)= 'ZS' "
		//If cEmpAnt=="03"
		   cQuery+="  AND C5_FILIAL = '"+xFilial("SC5")+"' "
		//EndIf
		if cSegm == '3' .or. cSegm == '4'
			cQuery+="  AND C5_VEND1 = A3_COD "
		endif
		cQuery+="  AND C5_CLIENTE = A1_COD "
		cQuery+="  AND C5_LOJACLI = A1_LOJA "
		cQuery+="  AND C6_PRODUTO = B1_COD "
		cQuery+="  AND A1_COD = ZH_CLIENTE "
		cQuery+="  AND A1_LOJA = ZH_LOJA   "
		cQuery+="  AND ZH_MSBLQL <> '1'   "
		cQuery+="  AND C5_XTPSEGM = ZH_SEGMENT "
		cQuery+="  AND A3_COD(+) = ZH_VEND "
		cQuery+="  AND C5_TIPO NOT IN ('B','D') "
		cQuery+="  AND SA3.D_E_L_E_T_ = ' '    "
		cQuery+="  AND SZH.D_E_L_E_T_ = ' '    "
		cQuery+="  AND SZQ.D_E_L_E_T_(+) = ' '    "
		cQuery+="  AND SZ5.D_E_L_E_T_(+) = ' ' "
		cQuery+="  AND A3_FILIAL(+) = '" + XFILIAL("SA3") + "' "
		cQuery+="  AND A1_FILIAL = '" + XFILIAL("SA1") + "' "
		cQuery+="  AND ZH_FILIAL = '" + XFILIAL("SZH") + "' "
		cQuery+="  AND Z5_FILIAL(+) = '" + XFILIAL("SZ5") + "' "
		cQuery+="  AND ZQ_FILIAL(+) = '" + XFILIAL("SZQ") + "' "
		cQuery+="  AND X5_FILIAL(+) = '" + XFILIAL("SZQ") + "' "
		cQuery+="  AND (C6_QTDVEN > 0 OR C5_TIPO = 'I') "		//SSI 69904
		if len(alltrim(aCols[i,1]))==6
			if lImpNeg .or. lImpNag
				cQuery+="  AND (C5_NUM = '"+aCols[i,1]+"' OR C5_XPEDDES = '"+aCols[i,1]+"') "
			Else
				cQuery+="  AND C5_NUM = '"+aCols[i,1]+"' "
			Endif
		else
			cQuery+="  AND C5_XPEDFIC = '"+aCols[i,1]+"' "
		endif
		cQuery+="UNION "
		cQuery+=" SELECT  C5_XOBSCAN, C5_XPEDDES, C5_XNPVORT, C5_XRESTRI, C5_XPEDFIC,C5_XVALENT,C5_TIPOCLI,C6_TES,A2_NOME, C5_XREFTAB,C5_XFEIRAO,B1_UM, B1_SEGUM, B1_XALT, B1_XLARG, B1_XCOMP,           "
		cQuery+=" C5_MENPAD , C5_XMENPA2 , C5_XMENPA3, C5_MENNOTA , C5_XMENNF1 , C5_XMENNF2 , C5_XMENNF3, B1_POSIPI , "
		cQuery+=" C5_XMENLIB,C5_XTPSEGM,C5_NUM, C5_EMISSAO,A2_COD,A2_LOJA, C5_CLIENT, "
		cQuery+=" ' ' A1_XCIDADE, A2_NREDUZ, A2_END, '"+Space(GetSX3Cache("A1_XCMPEND", "X3_TAMANHO"))+"', A2_TEL, A2_DDD,A2_BAIRRO, "
		cQuery+=" A2_MUN, NVL(CC2_MUN,'NAO CADASTRADO') CC2_MUN, 0 A1_XQTDLP, 0 A1_XQTDCHS, "
		cQuery+=" 0 A1_XQTDCTS, A2_CGC, ' ' A1_XCLI100,' ' A1_XCLIEXC, 0 A1_XQTDPRG, 0 A1_XQTDPRO, 0 A1_XQTDPEN, "
		cQuery+=" 0 A1_XQTDPRM,C5_XENTREG, C6_QTDVEN*B1_PESO PESOIT,   C5_XENTREF, C5_XTPCOMP, "
		cQuery+=" C5_CLIENTE, C5_LOJACLI,' ' A1_XROTA, C5_TPFRETE, "
		cQuery+=" C5_XUNORI, ' ' A1_MENSAGE, C5_XPEDCLI, " //SSI 9225 - Thais //SSI 9675 Inclusão do A1_MENSAGE //SSI 10813
		cQuery+=" 0 COUNT,"
		cQuery+=" ' ' OBSCOB,"
		cQuery+=" ( C6_XPRUNIT*((100-C6_XGUELTA-C6_XRESSAR)/100)*C6_QTDVEN) VB,"
		cQuery+=" ( CASE WHEN BM_XSUBGRU NOT IN ('20007I', '00009G', '10006G', '10007O', '20008I') AND B1_XMODELO NOT IN ('000015') AND C6_TES NOT IN ('517', '518') THEN  C6_XCUSTO*C6_QTDVEN ELSE 0 END ) CUSTO2, "
		cQuery+="   A2_EST, A2_CEP, C5_VEND1, C5_XPRZMED, C5_TABELA, C5_TIPO, C6_PRODUTO, "
		cQuery+="   C6_QTDVEN, C6_DESCRI, B1_DESC, B1_XPERSON, B1_XMED,B1_XCHANFR, B1_PESO, C6_PRCVEN,  "
		cQuery+="   B1_XESPACO,B1_IPI, C5_XENTREG, C6_DESCONT, (C6_QTDVEN*C6_XPRUNIT) AS PRTOT, Round((C6_QTDVEN*C6_PRCVEN),2) AS PRPROD, (C6_QTDVEN*C6_PRCVEN) AS DFPRPROD,"
		cQuery+="  (Case When B1_XMODELO = '000008' OR B1_XMODELO = '000018' Then C6_XPRUNIT/5 Else C6_XPRUNIT End) As XPRUNIT, C6_XPRUNIT, "
		cQuery+="  (C6_QTDVEN*C6_XCUSTO) AS CUSTTOT, C6_XCUSTO, B1_TIPO, C6_UNSVEN, (C6_QTDVEN*C6_XPRUNIT) C6_VALOR, C5_TRANSP, B1_XMODELO, "
		cQuery+="   A3_NREDUZ, A2_CONTATO, C5_USERLGI, C5_XTPPGT, C6_XMARKUP, C5_XTELEMK, C6_XMIX, C6_XOBS, C5_XOBSADI, C5_XOBSFAB, C5_CONDPAG, "
		cQuery+="   ' ' Z5_DTREN, C6_XTPMED, B1_XCOMP, B1_XALT*B1_XLARG*B1_XCOMP VOLUME, "
		cQuery+="   0 A1_XQTDCOM,C6_ITEM, B1_XMODELO, F4_XDUPLIC, C5_XOPER, C5_XDESPRO,C5_XORDCOM,  B1_XDESCEX, "
		cQuery+="   DESQTD, DESFIN, PRCTAB, PRCDES, B1_XMODELO, "
		cQuery+="       (SELECT SUM(E3_COMIS) "
		cQuery+="  FROM SIGA."+RETSQLNAME("SE3")+" SE3 "
		cQuery+=" WHERE D_E_L_E_T_ = ' ' "
		cQuery+="   AND E3_FILIAL = '"+XFILIAL("SE3")+"' "
		cQuery+="   AND E3_CODCLI = C5_CLIENTE "
		cQuery+="   AND E3_LOJA = C5_LOJACLI "
		cQuery+="   AND E3_NUM = C5_NUM) TQ, "
		cQuery+=" 0 Z5_LIMTOT, "
		cQuery+=" 0 Z5_LIMAUTO, "
		cQuery+=" 0 LIMCONS, "
		cQuery+=" 0 AS QTDDP, "
		cQuery+=" 0 AS QTDPEN "
		cQuery+="  , '' , ZQ_DTPREVE , ZQ_DTEMBAR , C5_XDTLIB , C5_XEMBARQ , c5_nota , ZH_ITINER , C5_XVERREP, C5_XVEREXT , ZH_CLIESP, B1_XCODBAS, B1_GRUPO, B1_XSEGMEN, C6_XFEILOJ, C5_XNICHO "
		cQuery+=" FROM SIGA."+RetSqlName("SA3")+" SA3, "
		cQuery+="      SIGA."+RetSqlName("SA2")+" SA2,  "
		cQuery+="      SIGA."+RetSqlName("SZH")+" SZH,  "
		cQuery+="      SIGA."+RetSqlName("SZQ")+" SZQ,  "
		cQuery+="      SIGA."+RETSQLNAME("CC2")+" CC2,  "
		cQuery+="      PCI"+cEmpAnt+"0 PCI  "		 "
		cQuery+=" WHERE SA2.D_E_L_E_T_ = ' ' "
		cQuery+="   AND SZQ.D_E_L_E_T_(+) = ' ' "
		cQuery+="   AND SA3.D_E_L_E_T_(+) = ' ' "
		cQuery+="   AND SZH.D_E_L_E_T_(+) = ' ' "
		cQuery+="   AND CC2.D_E_L_E_T_(+) = ' ' "
		cQuery+="   AND C5_FILIAL = '" + XFILIAL("SC5") + "' "
		cQuery+="   AND CC2_FILIAL(+) = '" + XFILIAL("CC2") + "' "
		cQuery+="   AND A3_FILIAL(+)  = '" + XFILIAL("SA3") + "' "
		cQuery+="   AND A2_FILIAL     = '" + XFILIAL("SA2") + "' "
		cQuery+="   AND ZH_FILIAL(+)  = '" + XFILIAL("SZH") + "' "
		cQuery+="   AND ZQ_FILIAL(+)  = '" + XFILIAL("SZQ") + "' "
		cQuery+="   AND ZQ_EMBARQ(+) = C5_XEMBARQ "
		cQuery+="   AND CC2_EST(+) = A2_EST "
		cQuery+="   AND CC2_CODMUN(+) = A2_COD_MUN "
		cQuery+="   AND C5_VEND1 = A3_COD(+)"
		cQuery+="   AND C5_CLIENTE = A2_COD "
		cQuery+="   AND C5_LOJACLI = A2_LOJA "
		cQuery+="   AND C5_XTPSEGM = ZH_SEGMENT " // ADD MARCIO
		cQuery+="   AND A2_COD = ZH_CLIENTE(+) "
		cQuery+="   AND A2_LOJA = ZH_LOJA(+)   "
		cQuery+="   AND C5_TIPO IN ('B','D') "
		cQuery+="   AND (C6_QTDVEN > 0 OR C5_TIPO = 'I') "		//SSI 69904
		cQuery+="   AND C5_NUM = '"+aCols[i,1]+"' "
		cQuery+=" ORDER BY C5_NUM, C6_ITEM "
		
		U_ORTQUERY(cQuery, "ORTR020_R")
		//MpSysOpenQuery(cQuery,"ORTR020_R")
		
		DbSelectArea("ORTR020_R")
		If EOF()
			MsgBox("Nao ha Dados a serem impressos para o pedido: "+aCols[i,1],"Aviso","INFO")
			DbSelectArea("ORTR020_R")
			DbCloseArea()
			loop
		Else
			// SSI - 68788
			Count to _nCont
			oPrn:SetMeter(_nCont)
			ORTR020_R->(dbGotop())
			oPrn:IncMeter()
			//
		EndIf
		
		if i==1
			SetPrc(0,0)
			lImp := .F.
		endif
		_lRiscoDesc	:=	.F.
		nSimBahia:=0
		While ORTR020_R->(!EOF())
			// SSI - 68788
			oPrn:IncMeter()
			//
			oPrn:StartPage()
			cOperador 	:=	Substr(EMBARALHA(ORTR020_R->C5_USERLGI,1),1,15)
			cPed		:=	ORTR020_R->C5_NUM
			_cUnOri		:= alltrim(ORTR020_R->C5_XUNORI) //SSI 9225 - Thais
			_cPedCli	:= alltrim(ORTR020_R->C5_XPEDCLI) //SSI 10813
			_cDtEntreg	:=	ORTR020_R->C5_XENTREG
			_cDtEmis	:=	ORTR020_R->C5_EMISSAO
			_nVlrUPME	:=	Posicione("SM2",1,_cDtEmis,"M2_MOEDA5")
			_nKm		:=	Posicione("SZN",1,xFilial("SZN")+ORTR020_R->A1_XCIDADE,"ZN_KMUNID")
			_nLimTot	:=	ORTR020_R->Z5_LIMTOT
			_nLimAut	:=	ORTR020_R->LIMCONS
			if ORTR020_R->C5_EMISSAO >= '20091101'
				nVerba    :=  ORTR020_R->C5_XVERREP
				nVerbaExt :=  ORTR020_R->C5_XVEREXT
			endif
			dbselectarea("SA1")
			dbOrderNickName("PSA11")
			SA1->(dbseek(xFilial("SA1")+ORTR020_R->C5_CLIENTE))
			_cZona 		:= ALLTRIM(ORTR020_R->A1_XROTA) + " - " + substr(ALLTRIM(POSICIONE("SZ3",1,xFilial("SZ3")+ORTR020_R->A1_XROTA,"Z3_DESC")),1,30)
			_nCount		:= ORTR020_R->COUNT
			_cCliesp	:= ORTR020_R->ZH_CLIESP
			_cClient	:= ORTR020_R->A1_COD+"-"+substr(ORTR020_R->A1_NOME,1,35)
			_cTipo		:= ALLTRIM(ORTR020_R->C5_XTPSEGM)
			_cNicho		:= AllTrim(Posicione("SZ0",1,xFilial("SZ0")+'CM'+ALLTRIM(ORTR020_R->C5_XNICHO),"Z0_DESCRI"))
			_cPfeirao	:= IIF(SUBSTR(ORTR020_R->C5_XFEIRAO,1,1)=='S','SIM','NAO')
			_cPedido	:= alltrim(ORTR020_R->C5_NUM)
			_cDesmeORI	:= alltrim(ORTR020_R->C5_XPEDDES)
			_cDesmeOBS	:= alltrim(ORTR020_R->C5_XOBSCAN)
			IF !EMPTY(ORTR020_R->C5_XNPVORT) .AND. ORTR020_R->C5_NUM <> ORTR020_R->C5_XNPVORT
				_cPedido	:= alltrim(ORTR020_R->C5_NUM)
			ENDIF
			_cClilj		:= ORTR020_R->A1_COD+ORTR020_R->A1_LOJA
			_cNfantasi	:= AllTrim(SA1->A1_NREDUZ)
			_cIEstadua	:= alltrim(SA1->A1_INSCR)
			_cCgc		:= ORTR020_R->A1_CGC
			_cTel		:= SubStr(alltrim(ORTR020_R->A1_TEL)+" - "+AllTrim(ORTR020_R->A1_DDD),1,80)
			_dDigit		:= DTOC(STOD(ORTR020_R->C5_EMISSAO))
			_cBairro	:= alltrim(ORTR020_R->A1_BAIRRO)
			_cMunic		:= IIF(!EMPTY(ORTR020_R->CC2_MUN),substr(alltrim(ORTR020_R->CC2_MUN),1,35),alltrim(ORTR020_R->A1_MUN))
			_cUf		:= alltrim(ORTR020_R->A1_EST)
			_cCep		:= alltrim(ORTR020_R->A1_CEP)
			_cEndereco	:= SubStr(alltrim(ORTR020_R->A1_END) + " " + AllTrim(ORTR020_R->A1_XCMPEND),1,59)
			_cFrete		:= Iif(ORTR020_R->C5_TPFRETE="C","CIF",Iif(ORTR020_R->C5_TPFRETE="F","FOB"," "))
			_dPeriodo	:= DTOC(STOD(ORTR020_R->C5_XENTREG))+" A "+DTOC(STOD(ORTR020_R->C5_XENTREF))
			
			_cComprado	:= ORTR020_R->A1_CONTATO
			_cUsuar		:= ORTR020_R->C5_USERLGI
			//_dDtren		:= ORTR020_R->Z5_DTREN
			_dDtren		:= UltRenCad(ORTR020_R->A1_COD,ORTR020_R->A1_LOJA) // SSI 31525
			_dDtren		:= IIF( _dDtren <> "",_dDtren, ORTR020_R->Z5_DTREN) // SSI 31525
			_cNreduz	:= ORTR020_R->A3_NREDUZ
			_cXoper		:= ORTR020_R->C5_XOPER
			_cTabela	:= ORTR020_R->C5_TABELA
			_cXrefTab	:= ORTR020_R->C5_XREFTAB
			_cItinera	:= ORTR020_R->ZH_ITINER
			_cSituac 	:= alltrim(GetAdvFVal('SX5','X5_DESCRI',xFilial('SX5')+'DJ'+ORTR020_R->C5_XOPER,1,''))
			_cNegoc		:= ORTR020_R->C5_XORDCOM
			_cXduplic	:= ORTR020_R->F4_XDUPLIC
			_cCondicao	:= ORTR020_R->C5_CONDPAG
			_cPrazo		:= ""
			_cPrazomed	:= ORTR020_R->C5_XPRZMED
			_cCodLM     := ORTR020_R->Z5_LIMTOT*_nVlrUPME
			_cCodDAR    := ORTR020_R->LIMCONS
			_cCodLA		:= ORTR020_R->Z5_LIMAUTO*_nVlrUPME
			_cPedficha	:= ORTR020_R->C5_XPEDFIC
			_cTpClient	:= ORTR020_R->C5_TIPOCLI
			_cTpPag		:= Alltrim(substr(POSICIONE("SX5",1,xFilial("SX5")+"Z4"+ORTR020_R->C5_XTPPGT,"X5_DESCRI"),1,18)+ " "+alltrim(ORTR020_R->C5_XDESPRO))
			lDescAutGer	:= (SubStr(UPPER(ORTR020_R->C5_XRESTRI), 1, 1) == "T")
			
			_cA1Msg		:= Alltrim(ORTR020_R->A1_MENSAGE) //SSI 9675
			_cCli100 	:= iif(ORTR020_R->A1_XCLIEXC='1','SIM','NÃO')
			
			// ==========================
			// MARKETPLACE GRUPO MARTINS E SOCORREDORAS
			If ORTR020_R->C5_CLIENTE <> ORTR020_R->C5_CLIENT
				dbselectarea("SA1")
				dbOrderNickName("PSA11")
				SA1->(dbseek(xFilial("SA1")+ORTR020_R->C5_CLIENT))
				If Found()
					_cZona 		:= ALLTRIM(SA1->A1_XROTA) + " - " + substr(ALLTRIM(POSICIONE("SZ3",1,xFilial("SZ3")+SA1->A1_XROTA,"Z3_DESC")),1,30)
					_cClilj		:= SA1->A1_COD+SA1->A1_LOJA
					_cClient	:= SA1->A1_COD+"-"+substr(SA1->A1_NOME,1,35)
					_cEndereco	:= SubStr(alltrim(SA1->A1_END) + " " + AllTrim(SA1->A1_XCMPEND),1,59)
					_cBairro	:= alltrim(SA1->A1_BAIRRO)
					_cMunic		:= alltrim(SA1->A1_MUN)
					_cUf		:= alltrim(SA1->A1_EST)
					_cCep		:= alltrim(SA1->A1_CEP)
					_cTel		:= SubStr(alltrim(SA1->A1_TEL)+" - "+AllTrim(SA1->A1_DDD),1,80)
					_nKm		:= Posicione("SZN",1,xFilial("SZN")+SA1->A1_XCIDADE,"ZN_KMUNID")
					_cCgc		:= SA1->A1_CGC
				Endif
				
			Endif
			// ==========================
			
			// VERIFICACAO SE O CLIENTE É ESPECIAL
			/*----------------------------------------------------------------*/
			aMedCli:=fPrazo(ORTR020_R->C5_EMISSAO,ORTR020_R->C5_CLIENTE,ORTR020_R->C5_LOJACLI)
			if aMedCli[1]>aMedCli[2]
				if aMedCli[1]>aMedCli[3]
					if aMedCli[1] > aMedCli[4]
						_nMedCli:=aMedCli[1]
					else
						_nMedCli:=aMedCli[4]
					endif
				else
					if aMedCli[3] > aMedCli[4]
						_nMedCli:=aMedCli[3]
					else
						_nMedCli:=aMedCli[4]
					endif
				endif
				
			elseif aMedCli[2] > aMedCli[3]
				if aMedCli[2]>aMedCli[4]
					_nMedCli:=aMedCli[2]
				else
					_nMedCli:=aMedCli[4]
				endif
			else
				if aMedCli[3]>aMedCli[4]
					_nMedCli:=aMedCli[3]
				else
					_nMedCli:=aMedCli[4]
				endif
				
			endif
			_nMedTri := aMedCli[1]
			_nMedUlt := aMedCli[2]
			_nMedMes := aMedCli[3]
			_nMeddia := aMedCli[4]
			
			_nMixTri := aMedCli[5]
			_nMixUlt := aMedCli[6]
			_nMixMes := aMedCli[7]
			_nMixdia := aMedCli[8]
			/*-----------------------------------------------------------------*/
			
			nLin	:=	fImpCab(nLin,_nMedTri,_nMedMes,_nMedDia,_nMedUlt,cPed,lTit)
			
			_nOri := 0 //SSI 9225 - Thais
			
			While ORTR020_R->(!EOF()) .And. cPed == ORTR020_R->C5_NUM
				//IncRegua()
				
				/*Calculando o valor da comissão de cada item*/
				
				IF ORTR020_R->C5_XTPSEGM $ '1|M|I|'
					cGruPer  := "B1_XCOMIND"
				ELSE
					cGruPer  := "B1_XCOMCOM"
				ENDIF
				
				nPercom   := U_POSNICK("SZH",1,xFilial("SZH") + ORTR020_R->C5_CLIENTE + ORTR020_R->C5_LOJACLI + ALLTRIM(cSegm),"ZH_COMIS")
				
				if nPerCom == 0
					nPerCom   := U_POSNICK("SA1",1,xFilial("SA1") + ORTR020_R->C5_CLIENTE + ORTR020_R->C5_LOJACLI,"A1_COMIS")
				endif
				
				if nPerCom == 0
					nPerCom   := U_POSNICK("SA3",1,xFilial("SA3") + ORTR020_R->C5_VEND1,"A3_XCOMIS")
				endif
				
				if nPerCom == 0
					nPerCom   := U_POSNICK("SB1",1,xFilial("SB1") + ORTR020_R->C6_PRODUTO,cGruPer)
				endif
				
				DbSelectArea("SD2")
				dbOrderNickName("PSD28")
				If DbSeek(xFilial("SD2")+ORTR020_R->C5_NUM+ORTR020_R->C6_ITEM)
					
					IF ORTR020_R->B1_XMODELO $ '000008|000018'
						nValPed := ORTR020_R->C6_VALOR - SD2->D2_VALDEV
					Else
						nValPed   := ((SD2->D2_QUANT - SD2->D2_QTDEDEV) * ORTR020_R->XPRUNIT)
					Endif
					nValCom   := Round((nValPed * nPerCom)/ 100,2) // Comissao
					nValCom   += IIF(LEFT(ORTR020_R->C5_XEMBARQ,1)>="5",nValCom*.08,0)
				ELSE
					nValCom := 0
				Endif
				/*Fim da alteração de calculo de comissao por item*/
				nDif:=ORTR020_R->PRPROD-ORTR020_R->DFPRPROD
				If nDif > 1
					nDif:=0
				EndIf
				nTotParc+=nDif
				
				nTotParc  	+= ORTR020_R->PRTOT
				nTotProds	+= ORTR020_R->PRPROD
				nTotEntr	:=	ORTR020_R->C5_XVALENT
				nTotCusto 	+= ORTR020_R->CUSTTOT
				nTCusto     += ORTR020_R->CUSTO2
				
				If ORTR020_R->B1_XMODELO $ ("000008|000018")
					nEspAux     :=  ORTR020_R->C6_UNSVEN*ORTR020_R->B1_XESPACO
				Else
					nEspAux     :=  ORTR020_R->C6_QTDVEN*ORTR020_R->B1_XESPACO
				endif
				
				IF ORTR020_R->C5_XTPCOMP=="V"
					nEspAux/=3
				ELSEIF ORTR020_R->C5_XTPCOMP=="C"
					nEspAux/=2
				ENDIF
				nTotEsp   += nEspAux
				
				nTotPruni += (ORTR020_R->PRCTAB)
				nTotPrcve += (ORTR020_R->XPRUNIT*IF(ORTR020_R->B1_XMODELO $ ("000008|000018"),ORTR020_R->C6_UNSVEN,ORTR020_R->C6_QTDVEN))
				
				cCodCli   := ORTR020_R->A1_COD
				cLojaCli  := ORTR020_R->A1_LOJA
				if ORTR020_R->B1_XMODELO=="000014"
					nTotPeca  += (ORTR020_R->C6_UNSVEN/(ORTR020_R->B1_XCOMP*1000))
				else
					nTotPeca  += ORTR020_R->C6_QTDVEN
				endif
				
				cC6_XOBS := fGetOBS(ORTR020_R->C5_NUM)
				
				nPosNt := Ascan(aMenNota,cC6_XOBS)
				if nPosNt = 0
					aadd(aMenNota,cC6_XOBS)
				endif
				
				//Incluído a observação do Pedido importado pela rotina ORTA334 - Marcos Furtado
				nPosNt:= Ascan(aMenNota,ORTR020_R->C5_XOBSFAB)
				if nPosNt = 0
					aadd(aMenNota,ORTR020_R->C5_XOBSFAB)
				endif
				
				_cOBSCOB	:=	ORTR020_R->OBSCOB
				_cTelemk	:=	Posicione("SA3",1,xFilial("SA3")+ORTR020_R->C5_XTELEMK,"A3_NREDUZ")
				
				_cMenLib	:=	ORTR020_R->C5_XMENLIB
				_nQtdDp	:=	ORTR020_R->QTDDP
				_nQtdPen	:=	ORTR020_R->QTDPEN
				lImp := .T. // Essa variavel identifica se já foi impresso pelo menos 1 item para poder entrar no rodapé antes de imprimir outro cabeçalho
				
				msgFisc1    := ORTR020_R->C5_MENPAD
				msgFisc2    := ORTR020_R->C5_XMENPA2
				msgFisc3    := ORTR020_R->C5_XMENPA3
				msgNota     := ORTR020_R->C5_MENNOTA
				msgNfe1     := ORTR020_R->C5_XMENNF1
				msgNfe2     := ORTR020_R->C5_XMENNF2
				msgNfe3     := ORTR020_R->C5_XMENNF3
				cMsgAdi     := ORTR020_R->C5_XOBSADI
				
				//Início - SSI 9225 - Thais
				If cEmpAnt == '24' .and. !Empty(_cUnOri)
					If _nOri < 1
						_cMsgQOri := fQtdOri(alltrim(cPed),_cUnOri)
						_nOri := 1
						_cUnOri	:=  "" //SSI 9675
					EndIf
				EndIf
				//Fim - SSI 9225 - Thais
				
				
				If	nLin >= MaxLin
					oPrn:EndPage()
					oPrn:StartPage()
					nLin	:=	fImpCab(nLin,_nMedTri,_nMedMes,_nMedDia,_nMedUlt,cPed,lTit)
				End
				oPrn:Say(nLin,0000,SUBSTR(ORTR020_R->C6_PRODUTO,1,10),oFont1)                  // CODIGO PRODUTO
				oPrn:Say(nLin,0210,transform(ORTR020_R->C6_QTDVEN, "@E 99999.999"),oFont1) // QUANTIDADE //99,999 SSI 5957 - Thais
				If !cEmpAnt $ ('21')		//SSI 66915
					If !cEmpAnt $ ('24')
						oPrn:Say(nLin,0360,transform(ORTR020_R->C6_UNSVEN, "@E 999999.99"),oFont1) // QTD KG SSI 5957 - Thais
					Else
						oPrn:Say(nLin,0360,Padc(AllTrim(ORTR020_R->B1_UM),10),oFont1) // QTD KG
					EndIf
				EndIf
				if cEmpAnt=="24"		//SSI 55553
					oPrn:Say(nLin,0560,Substr(AllTrim(ORTR020_R->B1_DESC),1,23)  ,oFont1) // DESCRICAO PRODUTO
					oPrn:Say(nLin,1045,ALLTRIM(ORTR020_R->B1_POSIPI)      ,oFont1) // CLASSIFICACAO FISCAL
					oPrn:Say(nLin,1230,fMedida(ORTR020_R->B1_XMED)+IF(ORTR020_R->B1_XCHANFR>0," "+alltrim(str(ORTR020_R->B1_XCHANFR)),""),oFont1) // MEDIDAS
				Else
					oPrn:Say(nLin,0560,Substr(ORTR020_R->C6_DESCRI,1,28)  ,oFont1) // DESCRICAO PRODUTO
					oPrn:Say(nLin,1125,ALLTRIM(ORTR020_R->B1_POSIPI)      ,oFont1) // CLASSIFICACAO FISCAL
					oPrn:Say(nLin,1310,fMedida(ORTR020_R->B1_XMED)+IF(ORTR020_R->B1_XCHANFR>0," "+alltrim(str(ORTR020_R->B1_XCHANFR)),""),oFont1) // MEDIDAS
				Endif
				oPrn:Say(nLin,1670,transform(ORTR020_R->C6_XMARKUP,"@E 9.99"),oFont1) // MARKUP
				oPrn:Say(nLin,1775,transform(ORTR020_R->XPRUNIT,"@E 99999.99"),oFont1) // PR.UNIT
				/*
				oPrn:Say(nLin,1950,transform(ORTR020_R->PRCTAB,"@E 99999.99"),oFont1) // PR.MARFIL
				oPrn:Say(nLin,2125,transform(ORTR020_R->DESFIN,"@E 99"      ),oFont1) // DESC.FINANCEIRO
				oPrn:Say(nLin,2175,transform(ORTR020_R->DESQTD,"@E 99"      ),oFont1) // DESC.QUANTITATIVO
				oPrn:Say(nLin,2215,transform(ORTR020_R->PRCDES,"@E 999,999.99"),oFont1) // PR.TABELA COM DESCONTO CASCATA
				oPrn:Say(nLin,2375,transform(Iif(ORTR020_R->B1_XMODELO$("000008|000018"),ORTR020_R->C6_UNSVEN * ORTR020_R->XPRUNIT,ORTR020_R->PRTOT) ,"@E 9,999,999.99"),oFont1) // PR. TOTAL
				*/
				nsoma := 0
				
				if ORTR020_R->C5_XTPSEGM == '2' .and. !empty(ORTR020_R->B1_XCODBAS)
					
					dbselectarea("SZV")
					dbsetorder(1)
					If dbseek(xFilial("SZV")+ORTR020_R->C5_TABELA+ORTR020_R->B1_GRUPO)
						nval    := SZV->ZV_VENDA
						nPerdes := SZV->ZV_DESCONT
					Else
						nval    := ORTR020_R->PRCTAB
						nPerdes := 0
					EndIf
					
					if nPerdes <> 0
						nval := nval - (nval * nPerdes / 100)
					endif
					
					nVal := nVal * (1 + gvaria(ORTR020_R->C5_XREFTAB))
					nval := nval * (ORTR020_R->B1_XALT * ORTR020_R->B1_XLARG * ORTR020_R->B1_XCOMP)
					ndesconto := (nval * (1-(ORTR020_R->DESQTD /100))* (1-(ORTR020_R->DESFIN /100)))
					
					oPrn:Say(nLin,1970,transform(nval,"@E 99999.99"),oFont1) // PR.MARFIL
					oPrn:Say(nLin,2145,transform(ORTR020_R->DESFIN,"@E 99"      ),oFont1) // DESC.FINANCEIRO
					oPrn:Say(nLin,2195,transform(ORTR020_R->DESQTD,"@E 99"      ),oFont1) // DESC.QUANTITATIVO
					oPrn:Say(nLin,2235,transform(ndesconto,"@E 99999.99"),oFont1)
					oPrn:Say(nLin,2395,transform(Iif(ORTR020_R->B1_XMODELO$("000008|000018"),ORTR020_R->C6_UNSVEN * ORTR020_R->XPRUNIT,ORTR020_R->PRTOT) ,"@E 9,999,999.99"),oFont1) // PR. TOTAL
					_nVlrExt	:= ndesconto - (ORTR020_R->C6_XPRUNIT*ORTR020_R->C6_QTDVEN)
					
					If cEmpAnt=='24'
						If ORTR020_R->B1_UM == "KG"
							oPrn:Say(nLin,2620,transform(ORTR020_R->C6_QTDVEN, "@E 99,999.99"),oFont1)
							nsoma := 200
							ntotalKg += ORTR020_R->C6_QTDVEN
						Else
							oPrn:Say(nLin,2620,transform(ORTR020_R->B1_PESO*ORTR020_R->C6_QTDVEN, "@E 99,999.99" ),oFont1)
							nsoma := 200
							ntotalKg += ORTR020_R->PESOIT
						endif
					ENDIF
					
					If	_nVlrExt > 0.99
						_nPercExt	:=	(_nVlrExt / ORTR020_R->PRCDES)	*	100
						oPrn:Say(nLin,2595+nsoma,transform(_nVlrExt,	"@E 999,999.99"),oFont1)
						oPrn:Say(nLin,2795+nsoma,transform(_nPercExt,	"@E 999.99"    ),oFont1)
						_lRiscoDesc	:=	.T.
					Endif
					
				else
					oPrn:Say(nLin,1970,transform(ORTR020_R->PRCTAB,"@E 99999.99"),oFont1) // PR.MARFIL
					oPrn:Say(nLin,2155,transform(ORTR020_R->DESFIN,"@E 99"      ),oFont1) // DESC.FINANCEIRO
					oPrn:Say(nLin,2195,transform(ORTR020_R->DESQTD,"@E 99"      ),oFont1) // DESC.QUANTITATIVO
					oPrn:Say(nLin,2235,transform(ORTR020_R->PRCDES,"@E 999,999.99"),oFont1) // PR.TABELA COM DESCONTO CASCATA
					oPrn:Say(nLin,2395,transform(Iif(ORTR020_R->B1_XMODELO$("000008|000018"),ORTR020_R->C6_UNSVEN * ORTR020_R->XPRUNIT,ORTR020_R->PRTOT) ,"@E 9,999,999.99"),oFont1) // PR. TOTAL
					_nVlrExt	:= (ORTR020_R->PRCDES - (ORTR020_R->C6_XPRUNIT*ORTR020_R->C6_QTDVEN))
					
					If cEmpAnt=='24' .Or. AllTrim(_cTipo) $ "1"
						If ORTR020_R->B1_UM == "KG"
							oPrn:Say(nLin,2620,transform(ORTR020_R->C6_QTDVEN, "@E 99,999.99"),oFont1)
							nsoma := 200
							ntotalKg += ORTR020_R->C6_QTDVEN
							
							If	_nVlrExt > 0.99
								_nPercExt	:=	(_nVlrExt / ORTR020_R->PRCDES)	*	100
								oPrn:Say(nLin,2620+nsoma,transform(_nVlrExt,	"@E 999,999.99"),oFont1)
								oPrn:Say(nLin,2820+nsoma,transform(_nPercExt,	"@E 999.99"    ),oFont1)
								_lRiscoDesc	:=	.T.
							Endif
						Else
							oPrn:Say(nLin,2620,transform(ORTR020_R->B1_PESO*ORTR020_R->C6_QTDVEN, "@E 99,999.99" ),oFont1)
							nsoma := 200
							ntotalKg += ORTR020_R->PESOIT
							
							If	_nVlrExt > 0.99
								_nPercExt	:=	(_nVlrExt / ORTR020_R->PRCDES)	*	100
								oPrn:Say(nLin,2620+nsoma,transform(_nVlrExt,	"@E 999,999.99"),oFont1)
								oPrn:Say(nLin,2820+nsoma,transform(_nPercExt,	"@E 999.99"    ),oFont1)
								_lRiscoDesc	:=	.T.
							Endif
							
						endif
					else
						
						
						If	_nVlrExt > 0.99
							_nPercExt	:=	(_nVlrExt / ORTR020_R->PRCDES)	*	100
							oPrn:Say(nLin,2595+nsoma,transform(_nVlrExt,	"@E 999,999.99"),oFont1)
							oPrn:Say(nLin,2795+nsoma,transform(_nPercExt,	"@E 999.99"    ),oFont1)
							_lRiscoDesc	:=	.T.
						Endif
					endif
					
				endif
				
				
				oPrn:Say(nLin,2945+nsoma,ORTR020_R->C6_TES         ,oFont1) // TES
				oPrn:Say(nLin,3045+nsoma,transform(ORTR020_R->B1_IPI,"@E 99"),oFont1) // IPI
				
				// -------------[ SSI 8893 - Início ]--------------------------------
				oPrn:Say(nLin,3120+nsoma,transform(ORTR020_R->PESOIT,'@E 999.99'),oFont1) // Peso Liquido
				// -------------[ SSI 8893 - Fim ]-----------------------------------
				
				if(lCom)
					oPrn:Say(nLin,3095+nsoma,transform(nValCom, "@E 9,999,999.99"),oFont1)
				endif
				
				If !Empty(ORTR020_R->B1_XPERSON)
					nLin += nEsp
					oPrn:Say(nLin,0580,ORTR020_R->B1_XPERSON,oFont1)
				Endif
				nLin += nEsp
				cXOper :=ORTR020_R->C5_XOPER
				dDtLib :=stod(ORTR020_R->C5_XDTLIB)
				cMotCan:=ORTR020_R->X5_DESCRI
				dDtSai :=stod(ORTR020_R->ZQ_DTEMBAR)
				dDtPrev:=stod(ORTR020_R->ZQ_DTPREVE)
				cCarga :=ORTR020_R->C5_XEMBARQ
				cNota  :=ORTR020_R->C5_NOTA
				nSimBahia+=ORTR020_R->C6_XFEILOJ
				DbSelectArea("ORTR020_R")
				ORTR020_R->(DBSKIP())
			enddo
			_nOri := 0 //SSI 9225 - Thais
			
			_nQtdUPME	:=	Round((nTotParc / _nVlrUPME),0)
			
			
			
			
			
			Improdap(nLin)
			lImp := .F.
			
			nTotParc := 0
			nTotProds:= 0
			nTotCusto:= 0
			nTCusto  := 0
			nTotEsp  := 0
			nTotPeca := 0
			nTotMkp  := 0
			nTotMix  := 0
			ntotalKg := 0
			aMenNota :={}
			//	nTotPruni :=0
			nTotPrcve 	:=	0
			nTotPruni	:=	0
			_aItens	:=	{}
			oPrn:EndPage()
		End Do
		ORTR020_R->(DbCloseArea())
	endif
next i


SET DEVICE TO SCREEN

If aReturn[5]==1
	dbCommitAll()
	SET PRINTER TO
	OurSpool(wnrel)
Endif

MS_FLUSH()

Return



*******************************************************************************
* Funcao : ImpRodap()   * Autor : Ricardo Ferreira       * Data : 13/03/2006  *
*******************************************************************************
* Descricao : Funcao auxiliar para impressao do Rodapé do relatório de Pedido *
*             de Circulação interna.                                          *
*******************************************************************************
* Uso       : OrtR020                                                         *
*******************************************************************************

Static Function ImpRodap(nLin)
*****************************
Local i
Local cMenAux:=""

If	nLin >= MaxLin
	oPrn:EndPage()
	oPrn:StartPage()
	nLin	:=	fImpCab(nLin,_nMedTri,_nMedMes,_nMedDia,_nMedUlt,cPed,.f.)
End

//oPrn:Say(nLin,2500,"____________",oFont1)
//nLin += nEsp
nPerDesc := round(((nTotPruni-nTotPrcve)/nTotPruni)*100,2)
If nPerDesc	<	0
	nPerDesc:=	0
Endif

oPrn:Say(nLin,0010 , "TOTAL PECAS   : " + AllTrim(transform(nTotPeca, "@E 99,999"))        ,oFont1)
oPrn:Say(nLin,0750 , "TOTAL ESPACOS : " + AllTrim(transform(nTotEsp , "@E 99,999,999.99")) ,oFont1)
oPrn:Say(nLin,1400 , "TOTAL PEDIDO  : " + AllTrim(transform(nTotParc, "@E 99,999,999.99")) ,oFont1)
If cEmpAnt $ ('24') .Or. AllTrim(_cTipo) $ "1"
	oPrn:Say(nLin,2050 , "TOTAL KG      : " + AllTrim(transform(ntotalKg, "@E 99,999,999.99")) ,oFont1)
	oPrn:Say(nLin,2700 , "PREÇO MEDIO   : " + AllTrim(transform(nTotParc/ntotalKg, "@E 99,999,999.99")) ,oFont1)
ENDIF
nLin += nEsp

If	nLin >= MaxLin
	oPrn:EndPage()
	oPrn:StartPage()
	nLin	:=	fImpCab(nLin,_nMedTri,_nMedMes,_nMedDia,_nMedUlt,cPed,.f.)
End

oPrn:Say(nLin,1400 , "TOTAL PRODUTOS: " + AllTrim(transform(nTotProds, "@E 99,999,999.99")) ,oFont1)
//oPrn:Say(nLin,0750 , "TOTAL IPI     : " + AllTrim(transform(nTotProds, "@E 99,999,999.99")) ,oFont1)
//oPrn:Say(nLin,1400 , "TOTAL ST      : " + AllTrim(transform(nTotProds, "@E 99,999,999.99")) ,oFont1)
nLin += nEsp

oPrn:Say(nLin,2075,"% DESC:",oFont1)
oPrn:Say(nLin,2800,transform(nPerDesc, "@E 999.99"),oFont1)

IF nVerba > 0 .Or. nVerbaExt > 0
	nLin += nEsp
	oPrn:Say(nLin,0010,"TOTAL VERBA REPASSE: "+transform((nTotParc*nVerba)/100, "@E 999,999,999.99"),oFont1)
	oPrn:Say(nLin,0750,"TOTAL VERBA EXTRA: "+transform((nTotParc*nVerbaExt)/100, "@E 9,999,999.99"),oFont1)
	oPrn:Say(nLin,1400,"TOTAL PEDIDO - VERBAS: "+transform(nTotParc - (nTotParc*(nVerba+nVerbaExt))/100, "@E 999,999,999.99"),oFont1)
	nLin += nEsp
endif

If	nLin >= MaxLin
	oPrn:EndPage()
	oPrn:StartPage()
	nLin	:=	fImpCab(nLin,_nMedTri,_nMedMes,_nMedDia,_nMedUlt,cPed,.f.)
End

If	nTotEntr > 0
	oPrn:Say(nLin,0010,"TOTAL ENTRADA TROCA: "+transform(nTotEntr, "@E 999,999,999.99"),oFont1)
	oPrn:Say(nLin,0700,"TOTAL A RECEBER: "+transform(nTotParc-nTotEntr, "@E 999,999,999.99"),oFont1)
	nLin += nEsp
Endif
IF nVerba > 0 .Or. nVerbaExt > 0
	oPrn:Say(nLin,0010,"PERCENTUAL VERBA DE REPASSE: "+Transform(nVerba, "@E 999.99")+" % ",oFont1)
	oPrn:Say(nLin,0750,"PERCENTUAL VERBA DE EXTRA: "+Transform(nVerbaExt, "@E 999.99")+" % ",oFont1)
	nLin += nEsp
endif


If	nLin >= MaxLin
	oPrn:EndPage()
	oPrn:StartPage()
	nLin	:=	fImpCab(nLin,_nMedTri,_nMedMes,_nMedDia,_nMedUlt,cPed,.f.)
End


//Calculo de media aritmetica do MIX e do Markup
nLL		:= U_OR16BCLB(nTotParc * (1 - (nVerba + nVerbaExt) / 100), nTotCusto)
nLB		:= U_OR16BCLB(nTotParc, nTotCusto)
nTotMkp := nTotParc / nTotCusto

oPrn:Say(nLin,0010,"LL. " +Transform(nLL, "@E 9999.99"),oFont1)
oPrn:Say(nLin,0700,"LB. " +Transform(nLb, "@E 9999.99"),oFont1)
oPrn:Say(nLin,1510,"MAR. "+Transform(nTotMkp, "@E 999.99"),oFont1)

if nSimBahia>0
	nLin+=nEsp
	nTotParc-=nSimBahia
	oPrn:Say(nLin,0010,"Total SimBahia " +Transform(nSimBahia, "@E 999,999,999.99"),oFont1)
	oPrn:Say(nLin,0700,"Vlr Pedido - SimBahia: " +Transform(nTotParc, "@E 999,999,999.99"),oFont1)
	nLin+=nEsp
	nLL		:= U_OR16BCLB(nTotParc * (1 - (nVerba + nVerbaExt) / 100), nTotCusto)
	nLB		:= U_OR16BCLB(nTotParc+nSimBahia, nTotCusto)
	nTotMkp := nTotParc / nTotCusto
	oPrn:Say(nLin,0010,"LL. " +Transform(nLL, "@E 9999.99"),oFont1)
	oPrn:Say(nLin,0700,"LB. " +Transform(nLb, "@E 9999.99"),oFont1)
	oPrn:Say(nLin,1510,"MAR. "+Transform(nTotMkp, "@E 999.99"),oFont1)
Endif


/*
nLin += nEsp
oPrn:Say(nLin,0010,"OBSERVACAO: " + IIF(QRY->C5_XDESPRO == '1', "Desconto Incondicional", iif(QRY->C5_XDESPRO == '2', "Desconto Condicional", "Sem Desconto")),oFont1)
*/
***************************************************************************

dbselectarea("ORTR020_R")
//nLin += nEsp

oPrn:Say(nLin,0000,repl("_",limite),oFont1)

nLin += nEsp

If	nLin >= MaxLin
	oPrn:EndPage()
	oPrn:StartPage()
	nLin	:=	fImpCab(nLin,_nMedTri,_nMedMes,_nMedDia,_nMedUlt,cPed,.f.)
End

//oPrn:Say(nLin,0010,"VEND. "+_cNreduz,oFont1) //12
//oPrn:Say(nLin,0400,"COMPRADOR: "+If( !Empty(_cComprado), _cComprado, "NAO CADASTRADO"),oFont1) //1

// Retirei para resolver o erro de profile que estava dando na unidade 02
//FUNCAO PARA GRAVAR O NOME DE USUARIO

If at("@",_cUsuar) > 0
	PswOrder(1)
	If PswSeek(substr(EMBARALHA(_cUsuar,1),3,8),.T.)
		cUsuario := PswRet()[1][2]
	Else
		cUsuario := substr(EMBARALHA(_cUsuar,1),1,15)
	endif
Else
	cUsuario := substr(EMBARALHA(_cUsuar,1),1,15)
Endif

oPrn:Say(nLin,0010,"MEDIA TRIM. COMPRAS:"+Transform(_nMedTri,"@E 999,999.99")+ "  LL "+Transform(_nMixTri,"@E 9999.99"),oFont1) //4 e 5
oPrn:Say(nlin,1300,"VENDA ULT. MES FECHADO:"+Transform(_nMedMes,"@E 999,999.99")+ "  LL "+Transform(_nMixMes,"@E 9999.99"),oFont1) //6 e 7
If alltrim(cUsuario) = ""
	cUsuario := "SISTEMA"
	oPrn:Say(nLin,2600,"IMPORTAÇÃO AUTOMÁTICA",oFont1)   //2
Else
	oPrn:Say(nLin,2600,"QUEM TIROU O PEDIDO: "+cUsuario,oFont1)   //2
endif

nLin += nEsp

If	nLin >= MaxLin
	oPrn:EndPage()
	oPrn:StartPage()
	nLin	:=	fImpCab(nLin,_nMedTri,_nMedMes,_nMedDia,_nMedUlt,cPed,.f.)
End

oPrn:Say(nLin,0010,"VENDA ULT. 30 DIAS :"+Transform(_nMedUlt,"@E 999,999.99")+ "  LL "+Transform(_nMixult,"@E 9999.99"),oFont1) //8 e 9
oPrn:Say(nLin,1300,"VENDA DIA DA DIGITAÇÃO:"+Transform(_nMedDia,"@E 999,999.99")+ "  LL "+Transform(_nMixDia,"@E 9999.99"),oFont1) //10 e 11
oPrn:Say(nLin,2600,"ULT.RENOVACAO: "+SUBSTR(_dDtren,7,2)+"/"+SUBSTR(_dDtren,5,2)+"/"+SUBSTR(_dDtren,1,4),oFont1) //3

//DBSELECTAREA("QRY")

nLin += nEsp
oPrn:Say(nLin,0010,"SITUACAO: "+_cSituac,oFont1) //13
oPrn:Say(nLin,1300,"PED.FICHA:  "+PADR(_cPedficha,7),oFont1) //22
oPrn:Say(nLin,2600,"NEGOCIACAO: "+_cNegoc,oFont1) //16

nLin += nEsp

If	nLin >= MaxLin
	oPrn:EndPage()
	oPrn:StartPage()
	nLin	:=	fImpCab(nLin,_nMedTri,_nMedMes,_nMedDia,_nMedUlt,cPed,.f.)
End

oPrn:Say(nLin,0010,"TABELA: "+_cTabela + " / "+_cXrefTab,oFont1) //14

if _cXduplic == "S"
	aCond:=condicao(1300,_cCondicao,0,dDatabase,0)
	cPrazo:=""
	for i:=1 to len(aCond)
		cPrazo+=strzero(aCond[i,1]-dDataBase,3)
		if i < len(aCond)
			cPrazo+=","
		endif
	next
	oPrn:Say(nLin,0645,"PRAZO MEDIO: "+_cPrazomed,oFont1) // 18
	oPrn:Say(nLin,1300,"PRAZO: "+Alltrim(cPrazo),oFont1) //17
else
	oPrn:Say(nLin,0645,"PRAZO MEDIO: XXX",oFont1) //18
	oPrn:Say(nLin,1300,"PRAZO: SEM VALOR COMERCIAL",oFont1) // 17
endif
oPrn:Say(nlin,2600,"TIPO PAG: "+_cTpPag,oFont1) //24
nLin += nEsp

oPrn:Say(nLin,0010,"CODIGO LM:  "+Transform(_cCodLM ,"@E 999,999,999.99"),oFont1) //19
oPrn:Say(nLIn,1300,"CODIGO DAR: "+Transform(_cCodDAR,"@E 999,999,999.99"),oFont1) //20
oPrn:Say(nLIn,2600,"CODIGO LA:  "+Transform(_cCodLA ,"@E 999,999,999.99"),oFont1) //21
nLin += nEsp

If	nLin >= MaxLin
	oPrn:EndPage()
	oPrn:StartPage()
	nLin	:=	fImpCab(nLin,_nMedTri,_nMedMes,_nMedDia,_nMedUlt,cPed,.f.)
End

If !Empty(_cPedCli)
	oPrn:Say(nLin,0010,"ORDEM DE COMPRA: "+_cPedCli,oFont1) //22
	nLin += nEsp
EndIf

nLin	:=	ImpAvaliacao(cCodCli,cLojaCli,nLin)
//oPrn:Line(nLin+25,0000,nLin+25,3400)
********************************************************
nLin += nEsp

If	nLin >= MaxLin
	oPrn:EndPage()
	oPrn:StartPage()
	nLin	:=	fImpCab(nLin,_nMedTri,_nMedMes,_nMedDia,_nMedUlt,cPed,.f.)
End

if !empty(cmsgadi) .and. ascan(aMenNota,cMsgAdi)==0
	aadd(aMenNota,cmsgadi)
endif
//Início SSI 9225 - Thais
If cEmpAnt == '24'
	//Início SSI 10813
	If !Empty(_cPedCli)
		aadd(aMenNota,"ORDEM DE COMPRA: "+_cPedCli)
	EndIf
	//Fim SSI 10813
	if !empty(_cMsgQOri) .and. ascan(aMenNota,_cMsgQOri)==0
		aadd(aMenNota,"Segue quantidade do item abaixo que constava no Pedido de Compra alterado por conveniência da CIA")
		aadd(aMenNota,_cMsgQOri)
	endif
EndIf
//Fim SSI 9225 - Thais
for i:=1 to Len(aMenNota)
	
	If	nLin >= MaxLin
		oPrn:EndPage()
		oPrn:StartPage()
		nLin	:=	fImpCab(nLin,_nMedTri,_nMedMes,_nMedDia,_nMedUlt,cPed,.f.)
	End
	
	if len(alltrim(aMenNota[i]))>0
		cMenAux:=aMENNOTA[i]
		while !empty(cMenAux)
			oPrn:Say(nLin,0010,substr(cMenAux,1,163),oFont1)
			cMenAux:=alltrim(substr(cMenAux,164))
			nLin += nEsp
		enddo
	endif
next
If	Len(AllTrim(_cOBSCOB)) >= Limite
	//	nLin += nEsp
	oPrn:Say(nLin,0010,SubStr(AllTrim(_cOBSCOB),1,Limite),oFont1)		// DRT  - Qtd de Duplicatas vencidas - Terceiros   //XQTDDPV
	nLin += nEsp
	oPrn:Say(nLin,0010,SubStr(AllTrim(_cOBSCOB),Limite+1,Len(AllTrim(_cOBSCOB))),oFont1)		// DRT  - Qtd de Duplicatas vencidas - Terceiros   //XQTDDPV
	nLin += nEsp
Else
	//	nLin += nEsp
	oPrn:Say(nLin,0010,AllTrim(_cOBSCOB),oFont1)		// DRT  - Qtd de Duplicatas vencidas - Terceiros   //XQTDDPV
	nLin += nEsp
Endif

If	nLin >= MaxLin
	oPrn:EndPage()
	oPrn:StartPage()
	nLin	:=	fImpCab(nLin,_nMedTri,_nMedMes,_nMedDia,_nMedUlt,cPed,.f.)
End

If ORTR020_R->C5_TRANSP <> " "
	dbselectarea("SA4")
	dbOrderNickName("PSA41")
	if dbseek(xFilial("SA4")+ORTR020_R->C5_TRANSP)
		oPrn:Say(nlin,0010,SA4->A4_COD+" "+SA4->A4_NOME,oFont1)
		nLin += nEsp
		oPrn:Say(nlin,0010,SA4->A4_END+" "+SA4->A4_CGC,oFont1)
		nLin += nEsp
	endif
endif
if !empty(ALLTRIM(_cTelemk))
	oPrn:Say(nLin,0010,"T.M.: " + ALLTRIM(_cTelemk),oFont1)
	nLin += nEsp
endif
// --- PEDIDOS DESMEMBRADOS
// --- Fabio Costa - 07/02/17
_cDesmembra := fGetDesm(_cPedido)
if !empty(_cDesmembra)
	if lImpNag
		oPrn:Say(nLin,0010,"PEDIDOS AGRUPADOS NESSA NEGOCIAÇÃO : ",oFont1)
	Else
		oPrn:Say(nLin,0010,"PEDIDOS DA NEGOCIAÇÃO : ",oFont1)
	Endif
	nLin += nEsp
	oPrn:Say(nLin,0010,_cDesmembra,oFont1)
	nLin += nEsp
endif
// --- !>
If	_cMenLib	<>	" "
	oPrn:Say(nLin,0010,"MOTIVO PARA VENDA FORA DA COMERCIALIZACAO:",oFont1)
	nLin += nEsp
	oPrn:Say(nLin,0010,_cMenLib,oFont1)
	nLin += nEsp
Endif
If	_nQtdDp		>	0
	oPrn:Say(nLin,0010,"CLIENTE COM "+Alltrim(Str(_nQtdDp))+" DUPLICATA(S) VENCIDA(S)",oFont1)
	nLin += nEsp
Endif
If	_nQtdPen	>	0
	oPrn:Say(nLin,0010,"CLIENTE COM "+Alltrim(Str(_nQtdPen))+" PENDENCIA(S) VENCIDA(S)",oFont1)
	nLin += nEsp
Endif

// Add Marcio William
nLin	:=	fImpRisco(nLin,nTotEsp,_nVlrUPME,nTotParc,_lRiscoDesc)
//nLin += nEsp

// ------------------------------------------------------------------
// [ SSI 10901 - inicio ]
// ------------------------------------------------------------------
////Início SSI 9675
//If cEmpAnt == '24'
//	If !Empty(_cA1Msg)
//		nLin += nEsp
//		oPrn:Say(nLin,0010,_cA1Msg,oFont1)
//	EndIf
//EndIf
////Fim SSI 9675
// ------------------------------------------------------------------
If cEmpAnt == '24'
	If !Empty(alltrim(_cA1Msg))
		nLin += nEsp
		oPrn:Say(nLin,0010,ALLTRIM(POSICIONE('SM4',1,XFILIAL('SM4')+ALLTRIM(_cA1Msg),'M4_FORMULA')),oFont1)
	EndIf
EndIf
// ------------------------------------------------------------------
// [ SSI 10901 - fim ]
// ------------------------------------------------------------------

// ==========================
// MARKETPLACE GRUPO MARTINS
If _cTipo == '5'
	nLin += nEsp
	oPrn:Say(nLin,0010,"PEDIDO DE MARKETPLACE EMITIDO POR:" + _cNfantasi ,oFont1)
	nLin += nEsp
Endif
// ==========================

// SE O PEDIDO TIVER DATA DA LIBERAÇÃO DEVERÁ SAIR INFORMAÇÕES REFERENTE AO PEDIDO SENAO DEVERA SAIR OS DADOS ABAIXO.
IF  EMPTY(dDtLib)
	//	oPrn:Say(nLin,0010,"DATA                  HORA                       VISTO",oFont1)
	oPrn:Say(nLin,0000,replicate("_",limite),oFont1)
	nLin += nEsp2
	oPrn:Say(nLin,0010,"GER. VENDAS                            ADM. VENDAS                            PROGRAMACAO  NºCARGA:____________      CADASTRO  |__| LIBERADO  |__| CANCELADO",oFont1)
	nLin += nEsp2
	oPrn:Say(nLin,0010,"_____/_____/______    _____:_____      _____/_____/______    _____:_____      _____/_____/______    _____:_____      _____/_____/_______    _____:_____",oFont1)
	nLin += nEsp2
	oPrn:Say(nLin,0010,"_________________________________      _________________________________      _________________________________      __________________________________",oFont1)
	nLin += nEsp
	oPrn:Say(nLin,0000,replicate("_",limite),oFont1)
	
	/*
	oPrn:Say(nLin,0010,"        SETOR                                            DATA                     HORA                       VISTO",oFont1)
	nLin += nEsp
	oPrn:Line(nLin,0000,nLin,3400)
	oPrn:Line(nLin+10,0000,nLin+10,3400)
	nLin += nEsp
	oPrn:Say(nLin,0020,"GER. VENDAS",oFont1)
	nLin += nEsp
	oPrn:Say(nLin,0010," AUTORIZADO PRECO/PRAZO                                  _____/_____/_____        _____:_____                ______________________________",oFont1)
	nLin += nEsp
	oPrn:Say(nLin,0010,repl("_",limite),oFont1)
	nLin += nEsp
	oPrn:Say(nLin,0020,"ADM. VENDAS",oFont1)
	nLin += nEsp
	oPrn:Say(nLin,0010," ASSISTENTE DE VENDAS                                    _____/_____/_____        _____:_____                ______________________________",oFont1)
	nLin += nEsp
	oPrn:Say(nLin,0010,repl("_",limite),oFont1)
	nLin += nEsp
	oPrn:Say(nLin,0010,"CADASTRO                                                 |__| LIBERADO                   |__| CANCELADO",oFont1)
	nLin += nEsp
	oPrn:Say(nLin,0010,"RECEBI",oFont1)
	nLin += nEsp
	oPrn:Say(nLin,0010,"_____/_____/_____     _____:_____     ______________     _____/_____/_____        _____:_____                ______________________________",oFont1)
	nLin += nEsp
	oPrn:Say(nLin,0010,repl("_",limite),oFont1)
	nLin += nEsp
	oPrn:Say(nLin,0020,"PROGRAMACAO",oFont1)
	nLin += nEsp
	oPrn:Say(nLin,0010," No. CARGA:___________________                           _____/_____/_____        _____:_____                ______________________________",oFont1)
	*/
	
	nLin += nEsp
	oPrn:Say(nLin,0010,"ATENCAO: ESTE PEDIDO NAO PODE SEGUIR O PROCESSO SEM O PREENCHIMENTO DE TODOS OS CAMPOS ACIMA, EXCETO O PRIMEIRO ONDE SO SE FAZ",oFont1)
	nLin += nEsp
	oPrn:Say(nLin,0010,"NECESSARIO CASO A CONDICAO DE COMERCIALIZACAO NAO SEJA PADRAO.",oFont1)
ELSE
	nLin += nEsp
	oPrn:Say(nLin,0000,repl("_",limite),oFont1)
	oPrn:Say(nLin,0010,"CLASSIFICAÇÃO : ORIGINAL",oFont1)
	nlin += nEsp
	if alltrim(cXoper) == '99'
		oPrn:Say(nLin,0010,"DATA DO CANCELAMENTO : ",oFont1)
		oPrn:Say(nlin,0500,dtoc(dDtLib),oFont1)
		oPrn:Say(nlin,0650,substr(cMotCan,1,100),oFont1)
		oPrn:Say(nlin,2400,"DATA DA LIBERAÇÃO    : ",oFont1)
		oPrn:Say(nlin,3000,"  /  /  ",oFont1)
		nLin += nEsp
	else
		oPrn:Say(nlin,0010,"DATA DA LIBERAÇÃO    : ",oFont1)
		oPrn:Say(nlin,0500,dtoc(dDtLib),oFont1)
	endif
	
	oPrn:Say(nlin,0800,"DATA DA PROGRAMAÇÃO  : ",oFont1)
	oPrn:Say(nlin,1300,dtoc(dDtPrev),oFont1)
	oPrn:Say(nLin,1600,"DATA DA SAÍDA        : ",oFont1)
	oPrn:Say(nLin,2100,dtoc(dDtSai),oFont1)
	nLin += nEsp
	oPrn:Say(nlin,0010,"NÚMERO DO TQ         : ",oFont1)
	oPrn:Say(nLin,0500,Posicione("SE3",5,xFilial("SE3")+_cPedido,"E3_XNUMGER"),oFont1)
	oPrn:Say(nLin,0800,"NÚMERO DA CARGA      : ",oFont1)
	oPrn:Say(nLin,1300,cCarga,oFont1)
	oPrn:Say(nLin,1600,"NOTA FISCAL          : ",oFont1)
	oPrn:Say(nLin,2100,cNota,oFont1)
endif
oPrn:Say(nLin,0000,replicate("_",limite),oFont1)
nLin += nEsp
if lMsg
	If	nLin >= MaxLin
		oPrn:EndPage()
		oPrn:StartPage()
		nLin := fImpCab(nLin,_nMedTri,_nMedMes,_nMedDia,_nMedUlt,cPed,.f.)
	End
	
	IF EMPTY(MSGFISC1)
		oPrn:Say(nLin,0010,"M. FISCAL1: ",oFont1)
	ELSE
		oPrn:Say(nLin,0010,"M. FISCAL1: " + ALLTRIM(POSICIONE("SM4",1,XFILIAL("SM4")+ALLTRIM(MSGFISC1),"M4_DESCR")),oFont1)
	ENDIF
	IF EMPTY(msgFisc2)
		oPrn:Say(nLin,1000,"M. FISCAL2: ",oFont1)
	ELSE
		oPrn:Say(nLin,1000,"M. FISCAL2: " + ALLTRIM(POSICIONE("SM4",1,XFILIAL("SM4")+ALLTRIM(msgFisc2),"M4_DESCR")),oFont1)
	ENDIF
	IF EMPTY(msgFisc3)
		oPrn:Say(nLin,2000,"M. FISCAL3: ",oFont1)
	ELSE
		oPrn:Say(nLin,2000,"M. FISCAL3: " + ALLTRIM(POSICIONE("SM4",1,XFILIAL("SM4")+ALLTRIM(msgFisc3),"M4_DESCR")),oFont1)
	ENDIF
	nLin += nEsp
	oPrn:Say(nLin,0010,"M. P/ NOTA: " + ALLTRIM(MSGNOTA),oFont1)
	oPrn:Say(nLin,2000,"M. NOTA1: "   + ALLTRIM(MSGNFE1),oFont1)
	nLin += nEsp
	oPrn:Say(nLin,0010,"M. NOTA2: "   + ALLTRIM(MSGNFE2),oFont1)
	oPrn:Say(nLin,2000,"M. NOTA3: "   + ALLTRIM(MSGNFE3),oFont1)
EndIf

//ZERAR TOTALIZADORES


nTotParc := 0
nTotProds:= 0
nTotEsp  := 0
nTotDesc := 0
nTotPeca := 0
nTotMkp  := 0
nTotMix  := 0

//=====================================================================================================================================
//        SETOR                                         DATA              HORA                          VISTO
//=====================================================================================================================================
//    GER. VENDAS
//
// AUTORIZADO PRECO/PRAZO                         _____/_____/_____    _____:_____          ______________________________
//-------------------------------------------------------------------------------------------------------------------------------------
//    ADM. VENDAS
//
// ASSISTENTE DE VENDAS                           _____/_____/_____    _____:_____          ______________________________
//-------------------------------------------------------------------------------------------------------------------------------------
//    CADASTRO                                          |__| LIBERADO               |__| CANCELADO
//
//RECEBI
//_____/_____/_____   _____:_____  ______________ _____/_____/_____    _____:_____          ______________________________
//-------------------------------------------------------------------------------------------------------------------------------------
//    PROGRAMACAO
//
// No. CARGA:___________________                  _____/_____/_____    _____:_____          ______________________________
//=====================================================================================================================================
//ATENCAO: ESTE PEDIDO NAO PODE SEGUIR O PROCESSO SEM O PREENCHIMENTO DE TODOS OS CAMPOS ACIMA, EXCETO O PRIMEIRO ONDE SO SE FAZ
//NECESSARIO CASO A CONDICAO DE COMERCIALIZACAO NAO SEJA PADRAO
//01234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789
//          10        20        30        40        50        60        70        80        90        100       110       120       130
Return(nLin)

*******************************************************************************
* Programa....: ImpAvaliacao                                                  *
* Programador.: Marcos Furtado                                                *
* Finalidade..: Imprime Avaliacao                                             *
*                                                                             *
* Data........: 01/02/06                                                      *
*******************************************************************************
* Alterado por:                                                               *
* Motivo......:                                                               *
* Data........:                                                               *
*******************************************************************************

Static Function ImpAvaliacao(cCliente,cLoja,nLinha)

Local aArea     := GetArea()


If	nLin >= MaxLin
	oPrn:EndPage()
	oPrn:StartPage()
	nLinha	:=	fImpCab(nLin,_nMedTri,_nMedMes,_nMedDia,_nMedUlt,cPed,.f.)
End

dbselectarea("SA1")
dbOrderNickName("PSA11")
dbseek(xFilial("SA1")+cCliente+cLoja)
oPrn:Say(nLinha,0010,"B:  ",oFont1)
oPrn:Say(nLinha,0100,STRZERO(SA1->A1_XQTDCOM,5),oFont1)    	//PICTURE "9,999" // B    - Qtd de Compras
oPrn:Say(nLinha,0400,"C:  ",oFont1)
oPrn:Say(nLinha,0450,STRZERO(SA1->A1_XQTDCAN,5),oFont1)   	//PICTURE "9,999" // C    - Qtd de Cancelamento - Falta Conceito
oPrn:Say(nLinha,0700,"T:  ",oFont1)
oPrn:Say(nLinha,0750,STRZERO(SA1->A1_XQTDTRO,5),oFont1) 		//PICTURE "9,999" // T    - Qtd de Trocas
oPrn:Say(nLinha,1000,"D:  ",oFont1)
oPrn:Say(nLinha,1050,STRZERO(SA1->A1_XQTDDEV,5),oFont1)   	//PICTURE "9,999" // D    - Qtd de Devolucoes
oPrn:Say(nLinha,1300,"R:  ",oFont1)
oPrn:Say(nLinha,1350,STRZERO(SA1->A1_XQTDCHS,5),oFont1)  		//PICTURE "9,999" // R    - Qtd de Cheques sem fundos - proprios
oPrn:Say(nLinha,1625,"RT: ",oFont1)
oPrn:Say(nLinha,1700,STRZERO(SA1->A1_XQTDCTS,5),oFont1)  		//PICTURE "9,999" // RT   - Qtd de Cheques sem fundos - Terceiros
oPrn:Say(nLinha,1950,"P:  ",oFont1)
oPrn:Say(nLinha,2000,STRZERO(SA1->A1_XQTDPRG,5),oFont1)   	//PICTURE "9,999" // P    - Qtd de Prorrgação    //XQTDPRG
oPrn:Say(nLinha,2250,"DR: ",oFont1)
oPrn:Say(nLinha,2300,STRZERO(SA1->A1_XQTDPRO,5),oFont1) 		//PICTURE "9,999" // DRQ  - td de Duplicatas vencidas - proprios   //XQTDPRO
oPrn:Say(nLinha,2700,"DRT:",oFont1)
oPrn:Say(nLinha,2800,STRZERO(SA1->A1_XQTDDPV,5),oFont1)		//PICTURE "9,999" // DRT  - Qtd de Duplicatas vencidas - Terceiros   //XQTDDPV

If	nLin >= MaxLin
	oPrn:EndPage()
	oPrn:StartPage()
	nLin	:=	fImpCab(nLin,_nMedTri,_nMedMes,_nMedDia,_nMedUlt,cPed,.f.)
End

/* REMOVIDO A PEDIDO DO SR RUBENS
_cQry	:=	"SELECT Z4_HIST01 "
_cQry	+=	"FROM "+RetSqlName("SZ4")
_cQry	+=	" WHERE Z4_FILIAL = '"+xFilial("SZ4")+"' AND Z4_CLIENTE = '"+SA1->A1_COD+"' AND Z4_LOJA = '"+SA1->A1_LOJA+"' AND D_E_l_E_T_ = ' ' AND Z4_GRUPO IN ('09','11') AND ROWNUM = 1 "
_cQry	+=	" ORDER BY Z4_DATA DESC"

TcQuery _cQry Alias "QRY2" New


DbSelectArea("QRY2")
nLinha += nEsp


If	Len(AllTrim(QRY2->Z4_HIST01)) >= Limite
oPrn:Say(nLinha,0010,SubStr(AllTrim(QRY2->Z4_HIST01),1,Limite),oFont1)		// DRT  - Qtd de Duplicatas vencidas - Terceiros   //XQTDDPV
nLinha += nEsp
oPrn:Say(nLinha,0010,SubStr(AllTrim(QRY2->Z4_HIST01),Limite+1,Len(AllTrim(QRY2->Z4_HIST01))),oFont1)		// DRT  - Qtd de Duplicatas vencidas - Terceiros   //XQTDDPV
Else
oPrn:Say(nLinha,0010,AllTrim(QRY2->Z4_HIST01),oFont1)		// DRT  - Qtd de Duplicatas vencidas - Terceiros   //XQTDDPV
Endif
QRY2->(DbCloseArea())
*/

//nLinha += nEsp
dbselectarea("SA1")
nLinha := fImpSerasa(SA1->A1_XCODCOM,nLinha)

RestArea(aArea)
Return(nLinha)

*************************************************************
Static Function fImpCab(nLin,nMedTri,nMedMes,nMedDia,nMedUlt,cPed,lTit)
*************************************************************


Private aUsuario := {}
Private cUsuario := ""

nLin := 50

//	oPrn:Say(nLin,0010,"PEDIDO DE CIRCULACAO INTERNA: "+ _cPedido                    ,oFont1) // 2 e 8
oPrn:Say(nLin,0010,"PEDIDO DE CIRCULACAO INTERNA: "+ _cPedido + ' - ' + _cSituac ,oFont1) // 2 e 8

//  oPrn:Say(nLin,1000,"No.PEDIDO: "                   + _cPedido        ,oFont1) // 8
oPrn:Say(nLin,1520,"ZONA ENTREGA: "+alltrim(_cZona)   ,oFont1) // 1
//oPrn:Say(nLin,1415,alltrim(_cZona)		                            ,oFont1) // 1
oPrn:Say(nLin,2750,"EMISSÃO: "                     + _dDigit         ,oFont1)
//  oPrn:Say(nLin,2600,"DIGITAÇÃO: "                   + _dDigit         ,oFont1)
//  oPrn:Say(nLin,2600,"Hora: "                        + time()          ,oFont1) // 4
nLin += nEsp

//  oPrn:Say(nLin,1500,"____________________________"                    ,oFont1)
oPrn:Line(nLin,0010,nLin,0585)

// ------------------------------------------------------------------
//  [ SSI 13227 - inicio ]
// ------------------------------------------------------------------
////  GLM: George: 12/12/2012: Inclusao da inscricao estadual
//	If SA1->(DbSeek(xFilial("SA1")+_cClilj))
//		oPrn:Say(nLin,0010,"NOME FANTASIA: " + AllTrim(SA1->A1_NREDUZ),oFont1) // 9
////		oPrn:Say(nLin,1500,"IE: "            + alltrim(SA1->A1_INSCR ),oFont1)
//	EndIf
// ------------------------------------------------------------------
//if !empty(alltrim(ORTR020_R->A1_NREDUZ))
//	oPrn:Say(nLin,0010,"NOME FANTASIA: " + AllTrim(ORTR020_R->A1_NREDUZ),oFont1) // 9
//else
If SA1->(DbSeek(xFilial("SA1")+_cClilj))
	oPrn:Say(nLin,0010,"NOME FANTASIA: " + AllTrim(SA1->A1_NREDUZ),oFont1) // 9
	//			oPrn:Say(nLin,1500,"IE: "            + alltrim(SA1->A1_INSCR ),oFont1)
EndIf
//endif
// ------------------------------------------------------------------
//  [ SSI 13227 - fim ]
// ------------------------------------------------------------------

oPrn:Say(nLin,1000,"R. SOCIAL: "      + _cClient,oFont1) // 5
oPrn:Say(nLin,2160,"TIPO: "           + _cTipo  ,oFont1) // 6
oPrn:Say(nLin,2750,"IMPRESSÃO: "      +  DTOC(dDataBase),oFont1) // 3
/*
If _nCount > 1
oPrn:Say(nLin,3000,"REDE - ",oFont1) //22
Endif
If _cCliesp == "S"
oPrn:Say(nLin,3150,"C.ESPECIAL",oFont1)  //22
Endif
*/
nLin += nEsp

oPrn:Say(nLin,0010,"ENDERECO: "  + _cEndereco               ,oFont1) // 11
oPrn:Say(nLin,2160,"CANAL: "     + _cNicho  ,oFont1) // 6
oPrn:Say(nLin,2750,"HORA IMPRESSÃO: " + time()  ,oFont1) // 4
nLin += nEsp       						// Joni Fujiyama - 29/07/2019 - SIS CI 022 Adm/CPD
oPrn:Say(nLin,0010,"BAIRRO: "    + _cBairro                 ,oFont1) // 15		// Joni Fujiyama - 29/07/2019 - SIS CI 022 Adm/CPD
oPrn:Say(nLin,1000,"MUNICIPIO: " + _cMunic+" - "+_cUf       ,oFont1) // 16,17	// Joni Fujiyama - 29/07/2019 - SIS CI 022 Adm/CPD
//oPrn:Say(nLin,1000,"BAIRRO: "    + _cBairro                 ,oFont1) // 15	// Joni Fujiyama - 29/07/2019 - SIS CI 022 Adm/CPD
//oPrn:Say(nLin,2160,"MUNICIPIO: " + _cMunic+" - "+_cUf       ,oFont1) // 16,17	// Joni Fujiyama - 29/07/2019 - SIS CI 022 Adm/CPD
If ORTR020_R->C5_CLIENTE <> ORTR020_R->C5_CLIENT
   oPrn:Say(nLin,2160,"CLI.FAT.: " + ORTR020_R->A1_COD+"-"+substr(ORTR020_R->A1_NOME,1,35),oFont1)
Endif
nLin += nEsp

oPrn:Say(nLin,0010,"KM: "        + Transform(_nKM,"@Z 9999"),oFont1) // 19
oPrn:Say(nLin,0300,"Frete: "     + _cFrete                  ,oFont1) // 21
//	oPrn:Say(nLin,1000,"PERIODO EM QUE O CLIENTE DESEJA A ENTREGA DO PEDIDO:   "+_dPeriodo,oFont1) //20
if(len(alltrim(_cCgc)))==14
	oPrn:Say(nLin,1000,"CNPJ: "                                 ,oFont1)
	oPrn:Say(nLin,1100,TRANSFORM(_cCgc,PESQPICT("SA1","A1_CGC")),oFont1)
ELSE
	oPrn:Say(nLin,1000,"CPF: "                                  ,oFont1)
	oPrn:Say(nLin,1100,transform(_cCgc, "@R 999.999.999-99")    ,oFont1)
ENDIF
oPrn:Say(nLin,2160,"CEP: "	          +_cCep    ,oFont1) // 18
oPrn:Say(nLin,2750,"TEL.: "      + _cTel                    ,oFont1) // 12

nLin += nEsp

oPrn:Say(nLin,0010,"VEND. "       +           _cNreduz                                  ,oFont1) // 12
oPrn:Say(nLin,1000,"COMPRADOR: "  + If(!Empty(_cComprado), _cComprado, "NAO CADASTRADO"),oFont1) //  1
oPrn:Say(nLin,2160,"ITINERARIO: " +           _cItinera                                 ,oFont1) // 15
oPrn:Say(nLin,2750,"PEDIDO FEIRAO : " +_cPfeirao,oFont1) //  7

If _nCount > 1
	oPrn:Say(nLin,2750,"REDE - "   ,oFont1) // 22
Endif

If _cCliesp == "S"
	oPrn:Say(nLin,3050,"C.ESPECIAL",oFont1) // 22
Endif
nLin += nEsp
oPrn:Say(nLin,0010,"PERIODO EM QUE O CLIENTE DESEJA A ENTREGA DO PEDIDO:   "+_dPeriodo,oFont1) // 20
oPrn:Say(nLin,2160,"CLIENTE EXCLUSIVO ORTOBOM: " + _cCli100 ,oFont1) // 20


//	SUBSTR(ORTR020_R->C5_XENTREG,7,2)+"/"+SUBSTR(ORTR020_R->C5_XENTREG,5,2)+"/"+SUBSTR(ORTR020_R->C5_XENTREG,1,4)

******************************************************************************
//	Mudou de posição. deverá ser impresso logo depois dos itens do pedido
/***
oPrn:Say(nLin,0000,repl("_",limite),oFont1)
nLin += nEsp
oPrn:Say(nLin,0010,"COMPRADOR: "+If( !Empty(ORTR020_R->A1_CONTATO), ORTR020_R->A1_CONTATO, "NAO CADASTRADO"),oFont1)

//FUNCAO PARA GRAVAR O NOME DE USUARIO
If at("@",ORTR020_R->C5_USERLGI) > 0
PswOrder(1)
PswSeek(substr(EMBARALHA(ORTR020_R->C5_USERLGI,1),3,8),.T.)
aUsuario := PswRet()
if len(aUsuario)>0 .and. len(aUsuario[1])>1
cUsuario := aUsuario[1][2]
else
cUsuario := substr(EMBARALHA(ORTR020_R->C5_USERLGI,1),1,15)
endif
Else
cUsuario := substr(EMBARALHA(ORTR020_R->C5_USERLGI,1),1,15)
Endif

@ nLin, 40 psay "OPERADOR: "+cUsuario       //Substr(EMBARALHA(ORTR020_R->C5_USERLGI,1),1,15)
***/
//aMedTri:=u_fMedTri(ORTR020_R->C5_CLIENTE,ORTR020_R->C5_LOJACLI)   /// alterei aki
//nMedTri:=aMedTri[1]
// alterado em 19/06/2009 por marcio conforme solicitado.
/*
cQuery:=" SELECT ROUND(SUM(C6_QTDVEN * C6_XPRUNIT / M2_MOEDA5), 2) VALORUPME,    	"
cQuery+="        ROUND(SUM(C6_QTDVEN * C6_XPRUNIT), 2) VALPED			"
cQuery+="          FROM "+RetSQLName("SC6")+" SC6, "+RetSQLName("SC5")+" SC5, "+RetSQLName("SM2")+" SM2        "
cQuery+="         WHERE SC5.D_E_L_E_T_ = ' '                                        "
cQuery+="           AND SM2.D_E_L_E_T_ = ' '                                        "
cQuery+="           AND SC6.D_E_L_E_T_ = ' '                                        "
cQuery+="           AND M2_DATA = TO_CHAR(SYSDATE, 'YYYYMMDD')                      "
cQuery+="           AND C5_FILIAL = '"+xFilial("SC5")+"'                            "
cQuery+="           AND C6_FILIAL = '"+xFilial("SC6")+"'                            "
cQuery+="           AND C5_NUM = C6_NUM  					 						 "
cQuery+="           AND C5_NUM = '"+ORTR020_R->C5_NUM+"'                                  "
MemoWrit("C:\ORTA032Valped.SQL",cQuery)
TCQUERY cQuery ALIAS "VALPED" NEW
dbselectarea("VALPED")
dbgotop()
nPedUPME:= VALPED->VALORUPME
nValPed := VALPED->VALPED
dbCloseArea()
aadd(aMedTri,nPedUpme)
if aMedTri[1]>aMedTri[2]
if aMedTri[1]>aMedTri[3]
nMedTri:=aMedTri[1]
else
nMedTri:=aMedTri[3]
endif
else
if aMedTri[2]>aMedTri[3]
nMedTri:=aMedTri[2] 8
else
nMedTri:=aMedTri[3]
endif
endif
*/
/***
@ nLin, 090  psay 	"ULT.RENOVACAO: "+SUBSTR(ORTR020_R->Z5_DTREN,7,2)+"/"+SUBSTR(ORTR020_R->Z5_DTREN,5,2)+"/"+SUBSTR(ORTR020_R->Z5_DTREN,1,4)
nLin += nEsp
@ nLin, 001  Psay	"MEDIA TRIM. COMPRAS:"+Transform(nMedTri,"@E 999,999.99")+ "  LB "+Transform(_nMixTri,"@E 9999.99")
@ nlin, 045  Psay   "VENDA ULT. MES FECHADO:"    +Transform(nMedMes,"@E 999,999.99")+ "  LB "+Transform(_nMixMes,"@E 9999.99")
@ nLin, 093  Psay	"VENDA ULT. 30 DIAS:"+Transform(nMedUlt,"@E 999,999.99")+ "  LB "+Transform(_nMixult,"@E 9999.99")
@ nLin, 136  Psay	"VENDA DIA DA DIGITAÇÃO:"   +Transform(nMedDia,"@E 999,999.99")+ "  LB "+Transform(_nMixDia,"@E 9999.99")
DBSELECTAREA("ORTR020_R")
nLin += nEsp
@ nLin, 01  psay "VEND. "+ORTR020_R->A3_NREDUZ
nLin += nEsp
@ nLin, 01  psay "TABELA: "+ORTR020_R->C5_TABELA + " / "+ORTR020_R->C5_XREFTAB
@ nLin, 40  psay "ITINERARIO: "+ORTR020_R->ZH_ITINER

@ nLin, 080 psay "SITUACAO: "+alltrim(GetAdvFVal('SX5','X5_DESCRI',xFilial('SX5')+'DJ'+ORTR020_R->C5_XOPER,1,'')) Picture "@!"
@ nLin, 120 psay "NEGOCIACAO: "+ORTR020_R->C5_XORDCOM

nLin += nEsp
***/

// alterado conforme solicitacao em 29/04/09
/*
if alltrim(ORTR020_R->C5_XOPER) == "02" .OR. alltrim(ORTR020_R->C5_XOPER) == "03"
@ nLin, 80 psay "SITUACAO: TROCA "
elseif alltrim(ORTR020_R->C5_XOPER) == "05"
@ nLin, 80 psay "SITUACAO: BRINDE "       // Por Cleverson, em 09/06/2006
elseif alltrim(ORTR020_R->C5_XOPER) == "06"
@ nLin, 80 psay "SITUACAO: NORMAL - "+ORTR020_R->C5_TIPO
else
@ nLin, 80 psay "SITUACAO: NORMAL "
endif
nLin += nEsp
*/

// alterado conforme solicitacao em 29/04/09

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica o tipo do pedido³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
/*_cTipo:=""
if QRY->C5_TIPO='N'
_cTipo:="NORMAL"
elseif QRY->C5_XDESPRO='C'
_cTipo:="COMP. PRECOS"
elseif QRY->C5_XDESPRO='I'
_cTipo:="COMP. ICMS"
elseif QRY->C5_XDESPRO='P'
_cTipo:="COMP. IPI"
elseif QRY->C5_XDESPRO='D'
_cTipo:="DEVOLUÇAO"
elseif QRY->C5_XDESPRO='B'
_cTipo:="FORNECEDOR"
endif

/* Marcio  -   28/04/09

if QRY->C5_TIPO='N'
_cTipo:="NORMAL"
elseif QRY->C5_TIPO='C'
_cTipo:="COMP. PRECOS"
elseif QRY->C5_TIPO='I'
_cTipo:="COMP. ICMS"
elseif QRY->C5_TIPO='P'
_cTipo:="COMP. IPI"
elseif QRY->C5_TIPO='D'
_cTipo:="DEVOLUÇAO"
elseif QRY->C5_TIPO='B'
_cTipo:="FORNECEDOR"
endif
*/

/*
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica o tipo de desconto³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
_cDesconto:=""
if QRY->C5_XDESPRO='1'
_cDesconto:="Item"
elseif QRY->C5_XDESPRO='2'
_cDesconto:="Nota"
else
_cDesconto:="Sem Desconto"
endif
*/
// alterado conforme solicitacao  - 29/04/09

//@ nLin, 001 psay "TP. PEDIDO: "+alltrim(_cTipo) Picture "@!"
//@ nLin, 040 psay "OPERAÇAO: "+alltrim(GetAdvFVal('SX5','X5_DESCRI',xFilial('SX5')+'DJ'+QRY->C5_XOPER,1,'')) Picture "@!"

//@ nLin, 001 psay "TP. PAGTO: "+alltrim(GetAdvFVal('SX5','X5_DESCRI',xFilial('SX5')+'Z4'+QRY->C5_XTPPGT,1,'')) Picture "@!"
//	nLin += nEsp                                       2

//if QRY->F4_DUPLIC == "S"
/***
if QRY->F4_XDUPLIC == "S"
aCond:=condicao(1000,QRY->C5_CONDPAG,0,dDatabase,0)
cPrazo:=""
for i:=1 to len(aCond)
cPrazo+=strzero(aCond[i,1]-dDataBase,3)
if i < len(aCond)
cPrazo+=","
endif
next
@ nLin, 01 psay "PRAZO: "+Alltrim(cPrazo)
@ nLin, 80 psay "PRAZO MEDIO: "+QRY->C5_XPRZMED
else
@ nLin, 01 psay "PRAZO: SEM VALOR COMERCIAL"
@ nLin, 80 psay "PRAZO MEDIO: XXX"
endif
nLin += nEsp
@ nLin, 01 psay "CODIGO LM:  "+Transform(QRY->Z5_LIMTOT*_nVlrUPME	,"@E 99,999,999")
@ nLIn, 40 psay "CODIGO DAR: "+Transform(QRY->LIMCONS				,"@E 99,999,999")
@ nLIn, 80 psay "CODIGO LA:  "+Transform(QRY->Z5_LIMAUTO*_nVlrUPME	,"@E 99,999,999")
nLin += nEsp
@ nLin, 01 psay "PED.FICHA:  "+PADR(QRY->C5_XPEDFIC,7)
@ nLIn, 40 psay "TIPO CLIENTE: "
if ALLTRIM(QRY->C5_TIPOCLI) == "F"
@ nLIn, 54 psay "CONSUMIDOR FINAL"
ELSEIF ALLTRIM(QRY->C5_TIPOCLI) == "L"
@ nLIn, 54 psay "PROPRIEDADE RURAL"
ELSEIF ALLTRIM(QRY->C5_TIPOCLI) == "R"
@ nLIn, 54 psay "REVENDEDOR"
ELSEIF ALLTRIM(QRY->C5_TIPOCLI) == "S"
@ nLIn, 54 psay "SOLIDARIO"
ELSEIF ALLTRIM(QRY->C5_TIPOCLI) == "X"
@ nLIn, 54 psay "EXPORTACAO/IMPORTACAO"
ENDIF
@ nlin, 80 psay "TIPO PAG: "+Alltrim(substr(POSICIONE("SX5",1,xFilial("SX5")+"Z4"+QRY->C5_XTPPGT,"X5_DESCRI"),1,40))
@ nLin, 130 psay alltrim(QRY->C5_XDESPRO) Picture "@!"
//@ nLin, 40 psay "PED.SAC  :  "+PADR(QRY->C5_XTALSAC,6)
***/

oPrn:Say(nLin,0000,replicate("_",limite),oFont1)
//	oPrn:Line(nLin,0010,nLin,3400)
nLin += nEsp

If lTit
	oPrn:Say(nLin,2270    ,"PR.TABELA"    ,oFont1)
	oPrn:Say(nLin,2675+120,"DESC.EXTRAP. ",oFont1)
	
	nLin += nEsp
	oPrn:Say(nLin,0010   ,"CODIGO",oFont1)
	//		oPrn:Say(nLin,0275-60,"QTD"   ,oFont1) SSI 5957 - Thais
	oPrn:Say(nLin,0275-20,"QTD-"+ORTR020_R->B1_UM   ,oFont1)
	
	If !cEmpAnt $ ('21')		//SSI 66915
		If !cEmpAnt $ ('24')
			//			oPrn:Say(nLin,0400-20,iif(ORTR020_R->b1_xmodelo>='000023',"QTDKG","QTDM3"),oFont1) SSI 5957 - Thais
			//oPrn:Say(nLin,0400-20,iif(ORTR020_R->b1_xmodelo>='000023',"QTDKG","QTDM3"),oFont1)
			oPrn:Say(nLin,0400+20,"QTD-"+ORTR020_R->B1_SEGUM,oFont1)
		Else
			//			oPrn:Say(nLin,0400-20,"QTDM3",oFont1) SSI 5957 - Thais
			oPrn:Say(nLin,0400+20,"QTD-M3",oFont1)
		EndIf
	EndIf
	
	//		oPrn:Say(nLin,0600-20,"DENOMINACAO",oFont1) SSI 5957 - Thais
	//oPrn:Say(nLin,0600-20,"DENOMINACAO",oFont1)
	oPrn:Say(nLin,0600-40,"DENOMINACAO",oFont1)
	if cEmpAnt == "24"
		oPrn:Say(nLin,1100+45-80,"C.FISCAL"   ,oFont1)
	else
		oPrn:Say(nLin,1100+25,"C.FISCAL"   ,oFont1)
	endif
	//oPrn:Say(nLin,1300+30,"MEDIDAS M,D,C,M"    ,oFont1)
	if cEmpAnt == "24"
		//oPrn:Say(nLin,1300+30-80,"ESP  COMP LARG CHAN"    ,oFont1)
		
		// Norma técnica NT-1.00/00- Nomenclatura - Revisada em junho/2000.
		// A nomenclatura e ordem correta são: Largura x Comprimento x Espessura x Sanfona.
		// SSI 24935 - FABIO COSTA - 10/05/2016
		oPrn:Say(nLin,1300+30-100,"LARG  COMP  ESPE SANF"    ,oFont1)
	else
		oPrn:Say(nLin,1300+10,"ALT   COMP  LARG"    ,oFont1)
	endif
	oPrn:Say(nLin,1670   ,"MAR."       ,oFont1)
	oPrn:Say(nLin,1775   ,"PR.UNIT."   ,oFont1)
	
	if ORTR020_R->B1_XMODELO=="000014" // MANTA
		oPrn:Say(nLin,1950,"PRECO M",oFont1)
	else
		oPrn:Say(nLin,1990,"PR.TAB.",oFont1)
	endif
	
	oPrn:Say(nLin,2175,"F"       ,oFont1)
	oPrn:Say(nLin,2215,"Q"       ,oFont1)
	oPrn:Say(nLin,2290,"C/DESC"  ,oFont1)
	oPrn:Say(nLin,2470,"PR.TOTAL",oFont1)
	
	nsoma := 0
	
	If cEmpAnt $ ('24')	.Or. AllTrim(_cTipo) $ "1"
		oPrn:Say(nLin,2425+220," PESO KG",oFont1)
		nsoma := 200
	ENDIF
	
	oPrn:Say(nLin,2735+nsoma,"VLR."                    ,oFont1)
	oPrn:Say(nLin,2885+nsoma,"%"                       ,oFont1)
	// -----[ SSI 8893 - Inicio ]----------------------------------------
	//		oPrn:Say(nLin,2925+nsoma,"TES"                     ,oFont1)
	//		oPrn:Say(nLin,3050+nsoma,"IPI"                     ,oFont1)
	// ------------------------------------------------------------------
	oPrn:Say(nLin,2955+nsoma,'TES'                     ,oFont1)
	oPrn:Say(nLin,3040+nsoma,'IPI'                     ,oFont1)
	oPrn:Say(nLin,3120+nsoma,'PLiq'                    ,oFont1)
	// -----[ SSI 8893 - Fim ]-------------------------------------------
	oPrn:Say(nLin,3220+nsoma,iif(lCom,"COMISSAO","")+"",oFont1)
	oPrn:Say(nLin,0000      ,repl("_",limite)          ,oFont1)
	nLin += nEsp
	
	// 		SSI 8893 - Gus
	
Endif

Return(nLin)

/**********************************************************************************************************/
/* FUNCAO PARE RETORNARA A MEDIA DE COMPRA TRIMESTRAL , MENSAL E DIARIO DO GRUPO DO CLIENTE               */
/**********************************************************************************************************/
******************************************
STATIC FUNCTION FPRAZO(CDATA,CCLI,CLOJA)
******************************************
LOCAL CQUERY	:= ""
Local aRet		:={}

Local nX		:= 0
Local dDia		:= CToD('  /  /  ')
Local dTriDe	:= CToD('  /  /  ')
Local dTriAte	:= CToD('  /  /  ')
Local dCurDe	:= CToD('  /  /  ')
Local dCurAte	:= CToD('  /  /  ')
Local dMesDe	:= CToD('  /  /  ')
Local dMesAte	:= CToD('  /  /  ')

dDia	:= SToD(CDATA)

dTriDe	:= FirstDay(dDia)
For nX := 1 To 3
	dTriDe	:= FirstDay(dTriDe - 1)
Next nX
dTriAte	:= FirstDay(dDia) - 1

dCurDe	:= dDia - 30
dCurAte	:= dDia

dMesAte	:= FirstDay(dDia) - 1
dMesDe	:= FirstDay(dMesAte)

cQuery	:= " SELECT SA1.A1_XCODCOM, "
cQuery	+= "        SUM(CASE "
cQuery	+= "              WHEN C5_EMISSAO BETWEEN '"+DToS(dTriDe)+"' AND '"+DToS(dTriAte)+"' AND "
cQuery	+= "                   C5_XOPER <> '05' THEN "
cQuery	+= "               (C6_QTDVEN - NVL(D2_QTDEDEV, 0)) * C6_XPRUNIT / M2_MOEDA5 "
cQuery	+= "              ELSE "
cQuery	+= "               0 "
cQuery	+= "            END) AS TRIM_VL, "
cQuery	+= "        SUM(CASE "
cQuery	+= "              WHEN C5_EMISSAO BETWEEN '"+DToS(dTriDe)+"' AND '"+DToS(dTriAte)+"' AND "
cQuery	+= "                   C5_XOPER <> '05' THEN "
cQuery	+= "               (((C6_QTDVEN - NVL(D2_QTDEDEV, 0)) * "
cQuery	+= "               (C6_XPRUNIT * (100 - (C5_XVERREP + C5_XVEREXT) ) / 100))-C6_XFEILOJ) / M2_MOEDA5 "
cQuery	+= "              ELSE "
cQuery	+= "               0 "
cQuery	+= "            END) AS TRIM_MIX, "
cQuery	+= "        SUM(CASE "
cQuery	+= "              WHEN C5_EMISSAO BETWEEN '"+DToS(dTriDe)+"' AND '"+DToS(dTriAte)+"' THEN "
cQuery	+= "               (C6_QTDVEN - NVL(D2_QTDEDEV, 0)) * C6_XCUSTO / M2_MOEDA5 "
cQuery	+= "              ELSE "
cQuery	+= "               0 "
cQuery	+= "            END) AS TRIM_CUSTO, "
cQuery	+= "        SUM(CASE "
cQuery	+= "              WHEN C5_EMISSAO BETWEEN '"+DToS(dCurDe)+"' AND '"+DToS(dCurAte)+"' AND "
cQuery	+= "                   C5_XOPER <> '05' THEN "
cQuery	+= "               (C6_QTDVEN - NVL(D2_QTDEDEV, 0)) * C6_XPRUNIT / M2_MOEDA5 "
cQuery	+= "              ELSE "
cQuery	+= "               0 "
cQuery	+= "            END) AS CUR_VL, "
cQuery	+= "        SUM(CASE "
cQuery	+= "              WHEN C5_EMISSAO BETWEEN '"+DToS(dCurDe)+"' AND '"+DToS(dCurAte)+"' AND "
cQuery	+= "                   C5_XOPER <> '05' THEN "
cQuery	+= "               (((C6_QTDVEN - NVL(D2_QTDEDEV, 0)) * "
cQuery	+= "               (C6_XPRUNIT * (100 - (C5_XVERREP + C5_XVEREXT)) / 100))-C6_XFEILOJ) / M2_MOEDA5 "
cQuery	+= "              ELSE "
cQuery	+= "               0 "
cQuery	+= "            END) AS CUR_MIX, "
cQuery	+= "        SUM(CASE "
cQuery	+= "              WHEN C5_EMISSAO BETWEEN '"+DToS(dCurDe)+"' AND '"+DToS(dCurAte)+"' THEN "
cQuery	+= "               (C6_QTDVEN - NVL(D2_QTDEDEV, 0)) * C6_XCUSTO / M2_MOEDA5 "
cQuery	+= "              ELSE "
cQuery	+= "               0 "
cQuery	+= "            END) AS CUR_CUSTO, "
cQuery	+= "        SUM(CASE "
cQuery	+= "              WHEN C5_EMISSAO BETWEEN '"+DToS(dMesDe)+"' AND '"+DToS(dMesAte)+"' AND "
cQuery	+= "                   C5_XOPER <> '05' THEN "
cQuery	+= "               (C6_QTDVEN - NVL(D2_QTDEDEV, 0)) * C6_XPRUNIT / M2_MOEDA5 "
cQuery	+= "              ELSE "
cQuery	+= "               0 "
cQuery	+= "            END) AS MES_VL, "
cQuery	+= "        SUM(CASE "
cQuery	+= "              WHEN C5_EMISSAO BETWEEN '"+DToS(dMesDe)+"' AND '"+DToS(dMesAte)+"' AND "
cQuery	+= "                   C5_XOPER <> '05' THEN "
cQuery	+= "               (((C6_QTDVEN - NVL(D2_QTDEDEV, 0)) * "
cQuery	+= "               (C6_XPRUNIT * (100 - (C5_XVERREP + C5_XVEREXT)) / 100))-C6_XFEILOJ) / M2_MOEDA5 "
cQuery	+= "              ELSE "
cQuery	+= "               0 "
cQuery	+= "            END) AS MES_MIX, "
cQuery	+= "        SUM(CASE "
cQuery	+= "              WHEN C5_EMISSAO BETWEEN '"+DToS(dMesDe)+"' AND '"+DToS(dMesAte)+"' THEN "
cQuery	+= "               (C6_QTDVEN - NVL(D2_QTDEDEV, 0)) * C6_XCUSTO / M2_MOEDA5 "
cQuery	+= "              ELSE "
cQuery	+= "               0 "
cQuery	+= "            END) AS MES_CUS, "
cQuery	+= "        SUM(CASE "
cQuery	+= "              WHEN C5_EMISSAO = '"+DToS(dDia)+"' AND C5_XOPER <> '05' THEN "
cQuery	+= "               (C6_QTDVEN - NVL(D2_QTDEDEV, 0)) * C6_XPRUNIT / M2_MOEDA5 "
cQuery	+= "              ELSE "
cQuery	+= "               0 "
cQuery	+= "            END) AS DIA_VL, "
cQuery	+= "        SUM(CASE "
cQuery	+= "              WHEN C5_EMISSAO = '"+DToS(dDia)+"' AND C5_XOPER <> '05' THEN "
cQuery	+= "               (((C6_QTDVEN - NVL(D2_QTDEDEV, 0)) * "
cQuery	+= "               (C6_XPRUNIT * (100 - (C5_XVERREP + C5_XVEREXT)) / 100))-C6_XFEILOJ) / M2_MOEDA5 "
cQuery	+= "              ELSE "
cQuery	+= "               0 "
cQuery	+= "            END) AS DIA_MIX, "
cQuery	+= "        SUM(CASE "
cQuery	+= "              WHEN C5_EMISSAO = '"+DToS(dDia)+"' THEN "
cQuery	+= "               (C6_QTDVEN - NVL(D2_QTDEDEV, 0)) * C6_XCUSTO / M2_MOEDA5 "
cQuery	+= "              ELSE "
cQuery	+= "               0 "
cQuery	+= "            END) AS DIA_CUSTO "
cQuery	+= "   FROM "+RetSqlName("SC5")+" SC5, "
cQuery	+= "        "+RetSqlName("SC6")+" SC6, "
cQuery	+= "        "+RetSqlName("SA1")+" SA1, "
cQuery	+= "        "+RetSqlName("SA1")+" GRU, "
cQuery	+= "        "+RetSqlName("SM2")+" SM2, "
cQuery	+= "        "+RetSqlName("SD2")+" SD2, "
cQuery	+= "        "+RetSqlName("SZH")+" SZH "
cQuery	+= "  WHERE SC5.D_E_L_E_T_ = ' ' "
cQuery	+= "    AND SC6.D_E_L_E_T_ = ' ' "
cQuery	+= "    AND SA1.D_E_L_E_T_ = ' ' "
cQuery	+= "    AND SD2.D_E_L_E_T_(+) = ' ' "
cQuery	+= "    AND GRU.D_E_L_E_T_ = ' ' "
cQuery	+= "    AND SM2.D_E_L_E_T_ = ' ' "
cQuery	+= "    AND SZH.D_E_L_E_T_ = ' ' "
cQuery	+= "    AND SC5.C5_FILIAL = '"+xFilial("SC5")+"' "
cQuery	+= "    AND SC6.C6_FILIAL = '"+xFilial("SC6")+"' "
cQuery	+= "    AND SA1.A1_FILIAL = '"+xFilial("SA1")+"' "
cQuery	+= "    AND SD2.D2_FILIAL(+) = '"+xFilial("SD2")+"' "
cQuery	+= "    AND GRU.A1_FILIAL = '"+xFilial("SA1")+"' "
cQuery	+= "    AND SZH.ZH_FILIAL = '"+xFilial("SZH")+"' "
cQuery	+= "    AND SC5.C5_NUM = C6_NUM "
cQuery	+= "    AND SC5.C5_CLIENTE = GRU.A1_COD "
cQuery	+= "    AND SC5.C5_LOJACLI = GRU.A1_LOJA "
cQuery	+= "    AND GRU.A1_XCODCOM = SA1.A1_XCODCOM "
cQuery	+= "    AND SA1.A1_XCODCOM = '"+POSICIONE("SA1",1,XFILIAL("SA1")+cCli,"A1_XCODCOM")+"' "
cQuery	+= "    AND GRU.A1_COD = SA1.A1_COD "
cQuery	+= "    AND GRU.A1_LOJA = SA1.A1_LOJA "
cQuery	+= "    AND SA1.A1_LOJA = '"+cLoja+"' "
cQuery	+= "    AND D2_PEDIDO(+) = C6_NUM "
cQuery	+= "    AND D2_ITEM(+) = C6_ITEM "
cQuery	+= "    AND D2_COD(+) = C6_PRODUTO "
cQuery	+= "    AND SC5.C5_XOPER IN "
cQuery	+= "        ('01', '04', '05', '10', '11', '14', '15', '16', '20', '21', '19', '26', '27', '99') "
cQuery	+= "    AND SC5.C5_XTPSEGM IN ('1', '2', '5', '6', 'M', 'I') "
cQuery	+= "    AND C5_EMISSAO BETWEEN '"+DToS(dTriDe)+"' AND '"+DToS(dDia)+"' "
cQuery	+= "    AND SC5.C5_XOPERAN <> '99' "
cQuery	+= "    AND SC5.C5_XMOTCAN IN ('98', '  ') "
cQuery	+= "    AND SZH.ZH_CLIENTE = SC5.C5_CLIENTE "
cQuery	+= "    AND SZH.ZH_LOJA = SC5.C5_LOJACLI "
cQuery	+= "    AND SZH.ZH_VEND = SC5.C5_VEND1 "
cQuery	+= "    AND SZH.ZH_SEGMENT = SC5.C5_XTPSEGM "
cQuery	+= "    AND M2_DATA = SC5.C5_EMISSAO "
cQuery	+= "    AND M2_MOEDA5 > 0 "
cQuery	+= "  GROUP BY SA1.A1_XCODCOM "
cQuery	+= "  ORDER BY 1 "
//MemoWrit("C:\ORTR020_p.sql",cQuery)
U_ORTQUERY(cQuery, "ORTR020_P")
//MpSysOpenQuery(cQuery, "ORTR020_P")

dbSelectArea("ORTR020_P")

aAdd(aRet,0)
aAdd(aRet,0)
aAdd(aRet,0)
aAdd(aRet,0)
aAdd(aRet,0)
aAdd(aRet,0)
aAdd(aRet,0)
aAdd(aRet,0)

If !(ORTR020_P->(EOF()))
	nMixTri := U_OR16BCLB(ORTR020_P->TRIM_MIX, ORTR020_P->TRIM_CUSTO)
	nMixCur := U_OR16BCLB(ORTR020_P->CUR_MIX, ORTR020_P->CUR_CUSTO)
	nMixMes := U_OR16BCLB(ORTR020_P->MES_MIX, ORTR020_P->MES_CUS)
	nMixDia := U_OR16BCLB(ORTR020_P->DIA_MIX, ORTR020_P->DIA_CUSTO)
	
	aRet[01]	:= Round(ORTR020_P->TRIM_VL / 3, 2)
	aRet[02]	:= Round(ORTR020_P->CUR_VL, 2)
	aRet[03]	:= Round(ORTR020_P->MES_VL, 2)
	aRet[04]	:= Round(ORTR020_P->DIA_VL, 2)
	aRet[05]	:= nMixTri
	aRet[06]	:= nMixCur
	aRet[07]	:= nMixMes
	aRet[08]	:= nMixDia
EndIf

ORTR020_P->(dbCloseArea())
dbSelectArea("SC5")

Return(aRet)

/********************************************************
//Função para Impressão das analises de risco do pedido
********************************************************/

Static Function fImpRisco(nLin,nTotEsp,_nVlrUPME,nTotParc,_lRiscoDesc)
local criscos := ""

If	nLin >= MaxLin
	oPrn:EndPage()
	oPrn:StartPage()
	nLin	:=	fImpCab(nLin,_nMedTri,_nMedMes,_nMedDia,_nMedUlt,cPed,.f.)
	//	nLin	:= 50
End

//Espaço excessivo
If nTotEsp	>	740
	//	nLin += nEsp
	//oPrn:Say(nLin,0010,"PEDIDO DE RISCO: Espaco Excessivo",oFont1)
	criscos += "Espaco Excessivo, "
	//lcont1 := .t.
Endif

//Data Entrega
If _cDtEntreg <> ' '
	//	nLin += nEsp
	//oPrn:Say(nLin,iif(lcont1,1000,0010),"PEDIDO DE RISCO: Data de Entrega",oFont1)
	criscos += "Data de Entrega, "
	lcont2 := .t.
Endif

//Credito Estourado
If (_nLimTot*_nVlrUPME)	<	_nLimAut
	//nLin += nEsp
	//	if !lcont1 .and. !lcont2
	//oPrn:Say(nLin,0010,"PEDIDO DE RISCO: Credito Estourado",oFont1)
	criscos += "Credito Estourado, "
	//	Endif
	/*
	if (lcont1 .and. !lcont2) .or.(!lcont1 .and. lcont2)
	oPrn:Say(nLin,1000,"PEDIDO DE RISCO: Credito Estourado",oFont1)
	Endif
	if lcont1 .and. lcont2
	oPrn:Say(nLin,2000,"PEDIDO DE RISCO: Credito Estourado",oFont1)
	Endif
	*/
Endif

//nLin += nEsp

//Valor do Pedido
If (nTotParc	/	_nVlrUPME)	>	2500
	//nLin += nEsp
	//	oPrn:Say(nLin,0010,"PEDIDO DE RISCO: Valor do Pedido",oFont1)
	criscos += "Valor do Pedido, "
	//	lcont3 := .t.
Endif

//Desconto Excessivo
If	_lRiscoDesc	=	.T.
	//nLin += nEsp
	//oPrn:Say(nLin,iif(lcont3,1000,0010),"PEDIDO DE RISCO: Desconto Excessivo",oFont1)
	criscos += "Desconto Excessivo, "
Endif

If lDescAutGer
	criscos += "## DESCONTO AUTORIZADO PELA GERÊNCIA ##, "
EndIf

oPrn:Say(nLin,0010,"PEDIDO DE RISCO: " + SUBSTR(AllTrim(criscos),1,len(AllTrim(criscos))-1),oFont1)

Return(nLin)


**************************
static function Digpedido
**************************

Local I


Local   cImage      := "logorto3.jpg"
Private cpedido 	:= Space(7)
Private dDataDe     :=	CTOD("")
Private dDataAte	:=	CTOD("")
Private dDtDevol	 := CTOD("  /  /  ")
Private cclide 		:= Space(6) //SSI 3230
Private ccliate 	:= Space(6) //SSI 3230
Private oCMC7
Private oDtDe
Private oCom,oPedImp,oPedUni   := Nil
private lcom          := .F.
private lMsg          := .F.
Private lPedImp       := .F.
Private lImpNeg       := .F.
Private lImpNag       := .F.
Private lPedUni       := .F.
Private oDtAte
Private oDtDevol
Private oMultiChq
Private oCliDe
Private oCliAte
Private aHeader      := {}
Private aCols        := {}
Private aCampos      := {}

// Variaveis Private da Funcao
Private _oDlg				// Dialog Principal
// Variaveis que definem a Acao do Formulario
Private VISUAL := .F.
Private INCLUI := .F.
Private ALTERA := .F.
Private DELETA := .F.
Private oFigura1

Define Font oFontGrd Name "Arial" Size 0,-12 Bold

dDtDevol	 := dDataBase

aCampos := {  "C5_NUM"   }

For I:= 1 to Len(aCampos)
	DbSelectArea("SX3")
	DbSetOrder(2)//NAO TROCAR
	If DbSeek(aCampos[I])
		Aadd(aHeader,{X3Titulo(), X3_CAMPO, X3_PICTURE,X3_TAMANHO, ;
		X3_DECIMAL,X3_VLDUSER, X3_USADO, X3_TIPO, X3_ARQUIVO, X3_CONTEXT} )
	EndIf
Next

aAdd(aCols,Array(Len(aHeader)+1))
For I:= 1 to Len(aHeader)
	//	aCols[1,I] := CriaVar(aHeader[I,2])
Next
aCols[1,Len(aHeader)+1] := .F.


DEFINE MSDIALOG _oDlg TITLE "Digitacao dos Numeros dos Pedidos" FROM 181,230 TO 566,916 PIXEL

//Início SSI 3230
If cEmpAnt $ ('24')
	@ 004,004 TO 061,343 LABEL "** P_E_D_I_D_O_S **" PIXEL OF _oDlg
Else
	//Fim SSI 3230
	@ 004,004 TO 073,343 LABEL "** P_E_D_I_D_O_S **" PIXEL OF _oDlg
EndIf //SSI 3230

@ 016,010 Say "Pedido" Size 070,008 COLOR CLR_BLUE Font oFontGrd PIXEL OF _oDlg

@ 014,050 MsGet oCMC7 Var cpedido F3 "SC5" Size 140,010 Valid (fPrchChq()) COLOR CLR_BLACK Font oFontGrd PIXEL OF _oDlg

@ 012,200 CheckBox  oCom Var lCom PROMPT "Comissao" Size 76,10 COLOR CLR_BLUE Font oFontGrd Pixel OF _oDlg
@ 023,200 CheckBox  oCom Var lMsg PROMPT "Msg para NF" Size 76,10 COLOR CLR_BLUE Font oFontGrd Pixel OF _oDlg
@ 034,200 CheckBox  oImpNeg Var lImpNeg PROMPT "Todos Ped.Neg." Size 76,10 COLOR CLR_BLUE Font oFontGrd Pixel OF _oDlg
@ 045,200 CheckBox  oImpNAg Var lImpNAg PROMPT "Negociacao Agr." Size 76,10 COLOR CLR_BLUE Font oFontGrd Pixel OF _oDlg

if !cEmpAnt $ ('22|23|24')
	@ 056,200 CheckBox  oPedImp Var lPedImp PROMPT "Ped. Importados" Size 76,10 COLOR CLR_BLUE Font oFontGrd Pixel OF _oDlg
endif


@ 032,010 Say "Data de" Size 070,008 COLOR CLR_BLUE Font oFontGrd PIXEL OF _oDlg

@ 030,050 MsGet oDtDe Var dDataDe Size 050,010 COLOR CLR_BLACK Font oFontGrd PIXEL OF _oDlg

@ 032,110 Say "Data Ate" Size 070,008 COLOR CLR_BLUE Font oFontGrd PIXEL OF _oDlg

@ 030,140 MsGet oDtAte Var dDataAte Size 050,010 COLOR CLR_BLACK Font oFontGrd PIXEL OF _oDlg

//Início SSI 3230
If cEmpAnt $ ('24')
	
	@ 048,010 Say "Cliente de" Size 070,008 COLOR CLR_BLUE Font oFontGrd PIXEL OF _oDlg
	
	@ 046,050 MsGet oCliDe Var cclide Size 050,010 COLOR CLR_BLACK Font oFontGrd F3 "SA1" PIXEL OF _oDlg
	
	@ 048,105 Say "Cliente Ate" Size 070,008 COLOR CLR_BLUE Font oFontGrd PIXEL OF _oDlg
	
	@ 046,140 MsGet oCliAte Var ccliate Size 050,010 COLOR CLR_BLACK Font oFontGrd F3 "SA1" PIXEL OF _oDlg
	
EndIf
//Fim SSI 3230

if cEmpAnt $ ('22|24')
	@ 056,200 CheckBox  oPedUni Var lPedUni PROMPT "Ped. Unidades" Size 76,10 COLOR CLR_BLUE Font oFontGrd Pixel OF _oDlg
endif

//Início SSI 3230
If cEmpAnt $ ('24')
	@ 065,004 TO 170,342 MULTILINE DELETE object oMultiChq
Else
	//Fim SSI 3230
	@ 072,004 TO 170,342 MULTILINE DELETE object oMultiChq
EndIf //SSI 3230

//	@ 177,260 Button "&Confirma" Size 037,014 Action(fCancBxChq(),Close(_oDlg)) Font oFontGrd PIXEL OF _oDlg
@ 177,260 Button "&Confirma" Size 037,014 Action(Close(_oDlg),fImp()) Font oFontGrd PIXEL OF _oDlg

@ 177,304 Button "Ca&ncela" Size 037,014 Action(Close(_oDlg)) Font oFontGrd PIXEL OF _oDlg

//@ 010,220 BITMAP oFigura1 RESOURCE "logosiga.bmp" SIZE 070,014 PIXEL ADJUST NOBORDER OF _oDlg
//@ 010,260 BITMAP oFigura1 RESOURCE "logoempty.bmp" SIZE 065,017 PIXEL ADJUST NOBORDER OF _oDlg
//oFigura1:bGotFocus := { || SetFocus(oDtDevol:hWnd) }

//@ 010,260 REPOSITORY oFigura1 SIZE 065,025 OF _oDlg PIXEL BORDER
//oFigura1:lAutoSize := .T.
//oFigura1:LoadBitmap(cImage)
//oFigura1:bGotFocus := { || SetFocus(oDtDevol:hWnd) }

@ 012,260 Jpeg FILE cImage Size 100,300 PIXEL BORDER OF _oDlg oBject oFigura1
oFigura1:lAutoSize := .T.

ACTIVATE MSDIALOG _oDlg CENTERED
return(acols)



Static Function fPrchChq()
**************************
Local aArea     := GetArea()

*-------------------------------------------------------------*
* Alterado por| Fagner Oliveira da Silva  | Data | 06/04/2013 *
*-------------------------------------------------------------*
* Este trecho do programa foi Alterado a pedido do DUPIM em   *
* atendimento ao SSI-27230. Foi feita uma validação para não  *
* permitir que pedidos do segmento 3 ou 4 sejam impressos.    *
*-------------------------------------------------------------*
* INICIO *
dbselectarea("SC5")
dbsetorder(1)
if !empty(cPedido) .and. !dbseek(xFilial("SC5")+cPedido)
	dbsetorder(6)
	if !dbseek(xFilial("SC5")+cPedido)
		MsgBox("Pedido Inexistente")
		oCMC7:SetFocus()
		cpedido := SPACE(7)
		oCMC7:Refresh()
		oMultiChq:Refresh()
		Return(.F.)
	else
		cPedido:=SC5->C5_NUM
	endif
	dbsetorder(1)
endif


//Adicionado regra que permite a impressao dos segmentos 3 e 4 para a empresa 02.
//Solicitado pelo DUPIM
//If _cSegm $ '3|4'

If SC5->C5_XTPSEGM $ '3|4' .And. cEmpAnt <> "02" .and. POSICIONE("SA1",1,xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,"A1_EST")<>"EX"
	if SC5->C5_XOPER <> "08" .AND. SC5->C5_XOPER < "20" .AND. SC5->C5_EMISSAO > ctod("18/03/2013") .and.   !(alltrim(cUserName)$('dupim'))
		ApMsgInfo("Tipo de segmento do pedido de venda inválido para impressão! Para segmento 3 e 4 utiliza o Pedido Mãe.")
		oCMC7:SetFocus()
		cpedido := SPACE(7)
		oCMC7:Refresh()
		oMultiChq:Refresh()
		Return(.F.)
	endif
EndIf
* FIM *

If !Empty(cpedido)
	
	@ 030,050 MsGet oDtDe 	Var dDataDe 	Size 050,010 COLOR CLR_BLACK Font oFontGrd PIXEL OF _oDlg WHEN .F.
	@ 030,140 MsGet oDtAte 	Var dDataAte 	Size 050,010 COLOR CLR_BLACK Font oFontGrd PIXEL OF _oDlg WHEN .F.
	//Início SSI 3230
	If cEmpAnt $ ('24')
		@ 046,050 MsGet oCliDe 	Var cclide 	Size 050,010 COLOR CLR_BLACK Font oFontGrd PIXEL OF _oDlg WHEN .F.
		@ 046,140 MsGet oCliAte Var ccliate 	Size 050,010 COLOR CLR_BLACK Font oFontGrd PIXEL OF _oDlg WHEN .F.
	EndIf
	//Fim SSI 3230
	
	oDtDe:Refresh()
	oDtAte:Refresh()
	
	//	cRetCmc7 := U_fValCMC7(cCMC7)
	//    If cRetCmc7 = 0
	//		MsgBox("Numero de CMC7 invalido. Verifique!","Atencao","ALERT")
	//		oCMC7:SetFocus()
	//		Return
	//	EndIf
	//  *39906142*0015064245*406141080769*
	If Len(aCols) = 1 .And. Empty(aCols[1][1])
		aCols[1][1]  := cpedido  //Substr(cCMC7,2,3)
		//		aCols[1][2]  := Substr(cCMC7,5,4)
		//		aCols[1][3]  := Substr(cCMC7,27,6)
		//		aCols[1][4]  := Substr(cCMC7,14,6)
		//		aCols[1][5]  := cCMC7
	Else
		nPosChq := aScan(aCols,{|x| x[1] = cpedido})     //x[5] = cpedido})   //cCMC7})
		If nPosChq > 0 //.And. aCols[nPosChq][Len(aHeader)+1] = .F.
			If aCols[nPosChq][Len(aHeader)+1] = .F.
				MsgBox("Este Pedido ja foi digitado. Verifique!","Atencao","ALERT")
			Else
				MsgBox("Este Pedido ja foi digitado e encontra-se marcado como DELETADO na listagem abaixo. Verifique!","Atencao","ALERT")
			EndIf
			oCMC7:SetFocus()
			Return
		EndIf
		//		Aadd(aCols,{Substr(cCMC7,2,3),;
		//		            Substr(cCMC7,5,4),;
		//		            Substr(cCMC7,27,6),;
		//		            Substr(cCMC7,14,6),;
		//		            cCMC7,;
		//		            .F.})
		Aadd(aCols,{cPedido,;
		.F.})
	EndIf
	
	oCMC7:SetFocus()
	cpedido := SPACE(7)
	oMultiChq:Refresh()
Else
	oMultiChq:Refresh()
EndIf

RestArea(aArea)
Return


*************************************
Static Function fImpSerasa(cGrupo,nLinha)
*************************************
Local aVetSer:= {}
Local cObs:= ""

If	nLin >= MaxLin
	oPrn:EndPage()
	oPrn:StartPage()
	nLin	:=	fImpCab(nLin,_nMedTri,_nMedMes,_nMedDia,_nMedUlt,cPed,.f.)
End

oFont:= TFont():New("Arial",,14,,.T.)

cQuery:= " SELECT Z4_CLIENTE,Z4_LOJA,A1_NOME,Z4_DATA,Z4_GRUPO,X5_DESCRI,Z4_INFORM,Z4_HIST01, Z4_HIST02,Z4_HIST03, "
cQuery+= "        Z4_OCORREN,Z4_VALTOT,Z4_DTDE,Z4_DTATE,Z4_SERASA,Z4_FORNEC,Z4_SITUAC,Z4_DESDE,Z4_VALUCOM,Z4_DTUCOM, "
cQuery+= "        Z4_VALMCOM,Z4_DTMCOM,Z4_VALVEN,Z4_VLRVENC,Z4_ATRASO,Z4_PGTO,Z4_LIMAUT,Z4_QTDCH,Z4_QTDREN,Z4_QTDPROT,Z4_PRZMED, "
cQuery+= "        (CASE WHEN Z4_PGTO LIKE '%CHQ%' THEN 1 ELSE 0 END) CH,    "
cQuery+= "		  (CASE WHEN Z4_PGTO LIKE '%DP%' THEN 1 ELSE 0 END) DP,     "
cQuery+= "		  (CASE WHEN Z4_PGTO LIKE '%TERC%' THEN 1 ELSE 0 END) TERC, "
cQuery+= "		  (CASE WHEN Z4_PGTO LIKE '%CARTAO%' THEN 1 ELSE 0 END) CC "
cQuery+= "  FROM SIGA."+RETSQLNAME("SZ4")+" SZ4, "+RETSQLNAME("SA1")+" SA1, "+RETSQLNAME("SX5")+" SX5 "
cQuery+= " WHERE Z4_CLIENTE = A1_COD  "
cQuery+= "   AND Z4_LOJA = A1_LOJA    "
cQuery+= "   AND X5_TABELA(+) = 'ZP'	  "
cQuery+= "   AND Z4_GRUPO = X5_CHAVE(+)  "
cQuery+= "   AND A1_XCODCOM = '"+cGrupo+"'"
cQuery+= "   AND Z4_GRUPO in ('09','17','18','19','20','21','22','23','24','25','26','27','28','29','30','31') "
cQuery+= "   AND SZ4.D_E_L_E_T_ = ' ' "
cQuery+= "   AND SA1.D_E_L_E_T_ = ' ' "
cQuery+= "   AND SX5.D_E_L_E_T_(+) = ' ' "
cQuery+= "   AND X5_FILIAL(+) = '  '     "
cQuery+= "   AND Z4_FILIAL = '"+xFilial("SZ4")+"' "
cQuery+= "   AND A1_FILIAL = '"+xFilial("SA1")+"' "
cQuery+= "   ORDER BY Z4_DATA DESC        "
U_FUSERMWRITE("ORTR020(Serasa).sql",cQuery)
If Select("HIS") > 0;HIS->(DbCloseArea());Endif
TcQuery cQuery Alias "HIS" New

dbselectarea("HIS")
cData:= HIS->Z4_DATA
while !eof()
	aAdd(aVetSer,{HIS->Z4_GRUPO,; //Grupo
	HIS->Z4_OCORREN,;  //Ocorrencias
	HIS->Z4_VALTOT,; //VALOR TOTAL
	STOD(HIS->Z4_DTDE),; //Data de
	STOD(HIS->Z4_DTATE),; //Data ate
	Substr(HIS->Z4_DTDE,5,2)+"/"+Substr(HIS->Z4_DTDE,1,4),;	//Relacionamento mais antigo
	iif(HIS->Z4_OCORREN=1,"1","2")}) //Habilitado ou Ativo (Rec. Fed e Sintegra)
	cObs:= HIS->Z4_HIST01
	DBSKIP()
	if cData <> HIS->Z4_DATA
		EXIT
	endif
enddo

dbselectarea("HIS")
DBCLOSEAREA()

nPos17:= Ascan(aVetSer,{|X| ALLTRIM(x[1]) == "17"})
nPos18:= Ascan(aVetSer,{|X| ALLTRIM(x[1]) == "18"})
nPos19:= Ascan(aVetSer,{|X| ALLTRIM(x[1]) == "19"})
nPos20:= Ascan(aVetSer,{|X| ALLTRIM(x[1]) == "20"})
nPos21:= Ascan(aVetSer,{|X| ALLTRIM(x[1]) == "21"})
nPos22:= Ascan(aVetSer,{|X| ALLTRIM(x[1]) == "22"})
nPos23:= Ascan(aVetSer,{|X| ALLTRIM(x[1]) == "23"})
nPos24:= Ascan(aVetSer,{|X| ALLTRIM(x[1]) == "24"})
nPos25:= Ascan(aVetSer,{|X| ALLTRIM(x[1]) == "25"})
nPos26:= Ascan(aVetSer,{|X| ALLTRIM(x[1]) == "26"})
nPos27:= Ascan(aVetSer,{|X| ALLTRIM(x[1]) == "27"})
nPos28:= Ascan(aVetSer,{|X| ALLTRIM(x[1]) == "28"})
nPos29:= Ascan(aVetSer,{|X| ALLTRIM(x[1]) == "29"})
nPos30:= Ascan(aVetSer,{|X| ALLTRIM(x[1]) == "30"})
nPos31:= Ascan(aVetSer,{|X| ALLTRIM(x[1]) == "31"}) //RELACIONAMENTO MAIS ANTIGO

nLinha += nEsp
//oPrn:Say(nLinha,0010,"S E R A S A   U L T I M A   D A T A = "+DTOC(STOD(cData)),oFont1)
//nLinha += nEsp
if nPos26 > 0
	/*	@ nLinha, 000 PSAY "Pontualidade - (QTDE): "+Transform(aVetSer[nPos26,2],"@E 999,999")+" (%): "+Transform(aVetSer[nPos26,3],"@E 999,999")
	nLinha += nEsp
	@ nLinha, 000 PSAY "Atrasos      | 8-15 (%):"+Transform(aVetSer[nPos27,3],"@E 999.99")+;
	"| 16-30 (%):"+Transform(aVetSer[nPos28,3],"@E 999.99")+;
	"| 31-60 (%):"+Transform(aVetSer[nPos29,3],"@E 999.99")+;
	"| + 60 (%):"+Transform(aVetSer[nPos30,3],"@E 999.99")
	nLinha += nEsp
	@ nLinha, 000 PSAY "RELACIONAMENTO MAIS ANTIGO (MES/ANO) : "+Transform(aVetSer[nPos31,6],"@! 99/9999")
	nLinha += nEsp
	@ nLinha, 000 PSAY "RESTRIÇÃO COM SÓCIOS (OBSERVAÇÕES)   : "+Substr(cObs,1,100)
	nLinha += nEsp*/
	//@ nLinha, 000 PSAY "REFIN Ocorrencias .......: "+Transform(aVetSer[nPos17,2],"@E 999,999")
	if nPos17>0 .and. nPos18>0
		oPrn:Say(nLinha,0010,"NEGATIVAÇÕES SERASA: "+STRZERO(aVetSer[nPos17,2]+aVetSer[nPos18,2],5),oFont1)
	else
		oPrn:Say(nLinha,0010,"NEGATIVAÇÕES SERASA: 00000",oFont1)
	endif
	//	@ nLinha, 025 PSAY "Valor Total : "+Transform(aVetSer[nPos17,3],"@E 999,999,999.99")
	//	@ nLinha, 065 PSAY "Periodo de: " +DTOC(aVetSer[nPos17,4])+" Periodo Ate:"+DTOC(aVetSer[nPos17,5])
	//	nLinha += nEsp
	//	@ nLinha, 000 PSAY "PEFIN Ocorrencias .......: "+Transform(aVetSer[nPos18,2],"@E 999,999")
	//	@ nLinha, 015 PSAY "PEFIN: "+STRZERO(aVetSer[nPos18,2],5)
	//	@ nLinha, 025 PSAY "Valor Total : "+Transform(aVetSer[nPos18,3],"@E 999,999,999.99")
	//	@ nLinha, 065 PSAY "Periodo de: " +DTOC(aVetSer[nPos18,4])+" Periodo Ate:"+DTOC(aVetSer[nPos18,5])
	//	nLinha += nEsp
	//	@ nLinha, 000 PSAY "PROTESTOS Ocorrencias ...: "+Transform(aVetSer[nPos19,2],"@E 999,999")
	if nPos19>0
		oPrn:Say(nLinha,0700,"PROT.: "+STRZERO(aVetSer[nPos19,2],5),oFont1)
	else
		oPrn:Say(nLinha,0700,"PROT.: 00000"+STRZERO(aVetSer[nPos19,2],5),oFont1)
	endif
	//	@ nLinha, 025 PSAY "Valor Total : "+Transform(aVetSer[nPos19,3],"@E 999,999,999.99")
	//	@ nLinha, 065 PSAY "Periodo de: " +DTOC(aVetSer[nPos19,4])+" Periodo Ate:"+DTOC(aVetSer[nPos19,5])
	//	nLinha += nEsp
	//	@ nLinha, 000 PSAY "CH.S/FUNDO Ocorrencias ..: "+Transform(aVetSer[nPos20,2],"@E 999,999")
	if nPos20>0
		oPrn:Say(nLinha,1100,"CH.S/F:"+STRZERO(aVetSer[nPos20,2],5),oFont1)
	else
		oPrn:Say(nLinha,1100,"CH.S/F:00000",oFont1)
	endif
	//	@ nLinha, 025 PSAY "Valor Total : "+Transform(aVetSer[nPos20,3],"@E 999,999,999.99")
	//	@ nLinha, 065 PSAY "Periodo de: " +DTOC(aVetSer[nPos20,4])+" Periodo Ate:"+DTOC(aVetSer[nPos20,5])
	//	nLinha += nEsp
	//	@ nLinha, 000 PSAY "DIVIDA VENC. Ocorrencias : "+Transform(aVetSer[nPos21,2],"@E 999,999")
	if nPos21>0
		oPrn:Say(nLinha,1500,"DIV.VENC.:"+STRZERO(aVetSer[nPos21,2],5),oFont1)
	else
		oPrn:Say(nLinha,1500,"DIV.VENC.:00000",oFont1)
	endif
	//	@ nLinha, 025 PSAY "Valor Total : "+Transform(aVetSer[nPos21,3],"@E 999,999,999.99")
	//	@ nLinha, 065 PSAY "Periodo de: " +DTOC(aVetSer[nPos21,4])+" Periodo Ate:"+DTOC(aVetSer[nPos21,5])
	//	nLinha += nEsp
	//	@ nLinha, 000 PSAY "AÇAO JUD. Ocorrencias ...: "+Transform(aVetSer[nPos22,2],"@E 999,999")
	if nPos22>0
		oPrn:Say(nLinha,1900,"AÇAO JUD.:"+STRZERO(aVetSer[nPos22,2],5),oFont1)
	else
		oPrn:Say(nLinha,1900,"AÇAO JUD.:00000",oFont1)
	endif
	//	@ nLinha, 025 PSAY "Valor Total : "+Transform(aVetSer[nPos22,3],"@E 999,999,999.99")
	//	@ nLinha, 065 PSAY "Periodo de: " +DTOC(aVetSer[nPos22,4])+" Periodo Ate:"+DTOC(aVetSer[nPos22,5])
	//	nLinha += nEsp
	//	@ nLinha, 000 PSAY "RECHEQUE Ocorrencias ....: "+Transform(aVetSer[nPos23,2],"@E 999,999")
	if nPos23>0
		oPrn:Say(nLinha,2300,"RECHEQUE :"+STRZERO(aVetSer[nPos23,2],5),oFont1)
	else
		oPrn:Say(nLinha,2300,"RECHEQUE :00000",oFont1)
	endif
	//	@ nLinha, 025 PSAY "Valor Total : "+Transform(aVetSer[nPos23,3],"@E 999,999,999.99")
	//	@ nLinha, 065 PSAY "Periodo de: " +DTOC(aVetSer[nPos23,4])+" Periodo Ate:"+DTOC(aVetSer[nPos23,5])
	//	nLinha += nEsp                        z
	//	@ nLinha, 000 PSAY "SINTEGRA (Habilitado): "+iif(aVetSer[nPos24,7]=="1","SIM","NAO")
	//	@ nLinha, 050 PSAY "RECEITA FEDERAL (Ativo): "+iif(aVetSer[nPos25,7]=="1","SIM","NAO")
	if nPos24>0
		oPrn:Say(nLinha,2700,"SINTEGRA :"+iif(aVetSer[nPos24,7]=="1","SIM","NAO"),oFont1)
	else
		oPrn:Say(nLinha,2700,"SINTEGRA :NAO",oFont1)
	endif
	if nPos25>0
		oPrn:Say(nLinha,3000,"REC. FED.:"+iif(aVetSer[nPos25,7]=="1","SIM","NAO"),oFont1)
	else
		oPrn:Say(nLinha,3000,"REC. FED.:NAO",oFont1)
	endif
	oPrn:Say(nLinha,0000,replicate("_",limite),oFont1)
endif
return nLinha

*-------------------------------------*
Static Function UltRenCad(cCod,cLoja)
*-------------------------------------*
Local aArea 	:= GetArea()
Local cQuery	:= ""
Local cData		:= ""

cQuery	:= "SELECT MAX(DECODE(Z4_GRUPO, '09', Z4_DATA, NULL)) AS ULTRECAD"
cQuery	+= "  FROM siga."+RetSqlName("SZ4")+" SZ4      "
cQuery	+= " WHERE D_E_L_E_T_ = ' '     "
cQuery	+= "   AND Z4_CLIENTE = '"+ cCod + "'"
cQuery	+= "   AND Z4_LOJA    = '"+ cLoja+ "'"

If Select("URC") > 0
	URC->(DbCloseArea())
Endif
TcQuery cQuery Alias "URC" New

While URC->(!eof())
	cData := URC->ULTRECAD
	URC->( DbSkip() )
EndDo

URC->(DbCloseArea())

RestArea(aArea)
return cData

*************************************
*Busca Quantidade Original do Pedido*
* SSI 9225 - Thais					*
*************************************
Static Function fQtdOri(_cPedOri, _cUnidOri)
Local _aAreaOri := GetArea() //SSI 9632
Local _cMsg := ""
Local _cQryOri := ""
Local _nQtdPed := 0
Local _DbCon := 'PROD'

If alltrim(_cUnidOri) $ ('18')
	_DbCon := 'DB03'
ElseIf alltrim(_cUnidOri) $ ('05|25')
	_DbCon := 'DB05'
ElseIf alltrim(_cUnidOri) $ ('07|23|24')
	_DbCon := ''
ElseIf alltrim(_cUnidOri) $ ('26')
	_DbCon := 'DB11'
ElseIf alltrim(_cUnidOri) $ ('21|22')
	_DbCon := 'PROD'
ElseIf alltrim(_cUnidOri) $ ('A2')
	_DbCon := 'DB02'	
Else
	_DbCon := 'DB'+_cUnidOri
EndIf

_cQryOri := " SELECT C6_PRODUTO, SB1.B1_UM MEDORI,  UMATU.B1_UM MEDATU, C7_QUANT QTDORI, C6_QTDVEN QTDATU, C5_NUM "
_cQryOri += " FROM SIGA."+RETSQLNAME("SC5")+" SC5, SIGA."+RETSQLNAME("SC6")+" SC6, "
_cQryOri += " SIGA.SC7"+_cUnidOri+"0"+IIF(!Empty(_DbCon),"@"+_DbCon,"")+" SC7, "
_cQryOri += " SIGA.SB1"+_cUnidOri+"0"+IIF(!Empty(_DbCon),"@"+_DbCon,"")+" SB1, "
_cQryOri += " SIGA."+RETSQLNAME("SB1")+" UMATU "
_cQryOri += " WHERE C5_FILIAL = '"+xFilial("SC5")+"' "
_cQryOri += " AND C6_FILIAL = '"+xFilial("SC6")+"' "
_cQryOri += " AND C7_FILIAL = '"+xFilial("SC7")+"' "
_cQryOri += " AND SB1.B1_FILIAL = '"+xFilial("SB1")+"' "
_cQryOri += " AND UMATU.B1_FILIAL = '"+xFilial("SB1")+"' "
_cQryOri += " AND SB1.D_E_L_E_T_ = ' ' "
_cQryOri += " AND UMATU.D_E_L_E_T_ = ' ' "
_cQryOri += " AND SC7.D_E_L_E_T_ = ' ' "
_cQryOri += " AND SC5.D_E_L_E_T_ = ' ' "
_cQryOri += " AND SC6.D_E_L_E_T_ = ' ' "
_cQryOri += " AND C5_NUM = C6_NUM "
_cQryOri += " AND UMATU.B1_COD = C6_PRODUTO "
_cQryOri += " AND C5_XUNORI <> ' ' "
_cQryOri += " AND C6_PRODUTO = SB1.B1_FABRIC "
_cQryOri += " AND SB1.B1_COD = C7_PRODUTO "
_cQryOri += " AND C5_XPEDCLI = C7_NUM "
_cQryOri += " AND C5_NUM = '"+_cPedido+"' "

If Select("QORI") > 0
	QORI->(DbCloseArea())
Endif
TcQuery _cQryOri Alias "QORI" New

While QORI->(!eof())
	
	If Alltrim(QORI->MEDORI) <> Alltrim(QORI->MEDATU)
		
		If alltrim(QORI->MEDATU) == 'ML'
			_nQtdPed := QORI->QTDORI/1000
			_nQtdOri := QORI->QTDATU
		ElseIf alltrim(QORI->MEDORI) == 'ML'
			_nQtdPed := QORI->QTDORI
			_nQtdOri := QORI->QTDATU/1000
		Else
			_nQtdPed := QORI->QTDORI
			_nQtdOri := QORI->QTDATU
		EndIf
		
	Else
		
		_nQtdPed := QORI->QTDORI
		_nQtdOri := QORI->QTDATU
		
	EndIf
	
	If _nQtdPed <>  _nQtdOri
		
		If Empty(_cMsg)
			_cMsg :=    "Código: " +Alltrim(QORI->C6_PRODUTO)+" - Quantidade: "+alltrim(transform(_nQtdPed, "@E 99999.999"))
		Else
			_cMsg += " / Código: " +Alltrim(QORI->C6_PRODUTO)+" - Quantidade: "+alltrim(transform(_nQtdPed, "@E 99999.999"))
		EndIf
		
	EndIf
	
	
	QORI->( DbSkip() )
EndDo

QORI->(DbCloseArea())
If !(Empty(_DbCon))
	TCSQLExec("ALTER SESSION CLOSE DATABASE LINK "+_DbCon)
EndIf

RestArea(_aAreaOri) //SSI 9632

Return _cMsg


// ******************************
// 12/04/16 - FABIO COSTA
Static Function fMedida(cMedida)
Local aRet := separa(upper(alltrim(cMedida)),"X")
Local cRet := cMedida

if len(aRet) == 3
	if cEmpAnt == "24"
		_cM1 := Alltrim(Transform(val(aRet[1])/100  ,"@E 9.99")) // largura
		_cM2 := Alltrim(Transform(val(aRet[2])/100  ,"@E 9.999")) // comprimento
		_cM3 := Alltrim(Transform(val(aRet[3])/10000,"@E 9.999")) // altura
		//cRet := padr(aRet[3],4) + " " + padr(aRet[2],4) + " " + padr(aRet[1],4) //_cM3 + " " + _cM2 + " " + _cM1
		// Norma técnica NT-1.00/00- Nomenclatura - Revisada em junho/2000.
		// A nomenclatura e ordem correta são: Largura x Comprimento x Espessura x Sanfona.
		// SSI 24935 - FABIO COSTA - 10/05/2016
		If len(aRet[1]) > 3 //.And. substr(aRet[1],4,1) <> 0
			//_cM1 := Alltrim(STRZERO(val(aRet[1])/10,5.1)) // largura
			cRet := padr(Alltrim(STRZERO(val(aRet[1])/10,5,1)),5) + " " + padr(aRet[2],4) + " " + padr(aRet[3],4)
		Else
			cRet := padr(aRet[1],4) + " " + padr(aRet[2],4) + " " + padr(aRet[3],4)
		EndIF
		
	else
		if cEmpAnt == "09"
			_cM1 := Alltrim(Transform(val(aRet[1])/10000,"@E 99.9999")) // altura
		else
			_cM1 := Alltrim(Transform(val(aRet[1])/10000,"@E 99.999")) // altura
		endif
		_cM2 := Alltrim(Transform(val(aRet[2])/1000 ,"@E  9.999" )) // comprimento
		_cM3 := Alltrim(Transform(val(aRet[3])/1000 ,"@E  9.999" )) // largura
		if cEmpAnt=="22"
			cRet := _cM3 + " " + _cM2 + " " + _cM1
		Else
			cRet := _cM1 + " " + _cM2 + " " + _cM3
		Endif
	endif
endif

Return cRet

// RETORNA A LISTA DE PEDIDOS GERADOS A PARTIR DESTE PEDIDO
Static Function fGetDesm(_cPed)
Local cRet := ""
Local cQry := ""

IF !EMPTY (_cDesmeORI)
	cRet += ALLTRIM(_cDesmeORI)+iif("GERADO ATRAV" $ _cDesmeOBS,"*","")+", "
Endif

cQry := "SELECT DISTINCT C5_NUM,C5_XOBSCAN	"
cQry += "  FROM SIGA."+RETSQLNAME("SC5")+" SC5      "
cQry += " WHERE C5_FILIAL = '"+xFilial("SC5")+"'    "
cQry += "   AND D_E_L_E_T_ = ' '    "
IF !EMPTY (_cDesmeORI)
	cQry += "   AND C5_XPEDDES = '"+_cDesmeORI+"' "
else
	cQry += "   AND C5_XPEDDES = '"+_cPed+"' "
endif
cQry += "   ORDER BY C5_NUM "

U_ORTQUERY(cQry, "R020DESM")
//MpSysOpenQuery(cQry,"R020DESM")

While R020DESM->(!EOF())
	cRet += ALLTRIM(R020DESM->C5_NUM)+iif("GERADO ATRAV" $ _cDesmeOBS,"*","")+", "
	R020DESM->( DbSkip() )
EndDo

IF !EMPTY(cRet)
	cRet :=	Alltrim(cRet)
	cRet := SUBSTR(cRet,0, Len(cRet)-1)
ENDIF

IF EMPTY(_cDesmeORI) .and. !EMPTY(cRet)
	cRet := ALLTRIM(_cPed)+iif("GERADO ATRAV" $ _cDesmeOBS,"*","")+", " + cRet
Endif

R020DESM->(DbCloseArea())

Return cRet



// RETORNA AS OBSERVAÇÕES MESMO QUE TENHA SIDO DESMEMBRADO
Static Function fGetOBS(_cPed)
Local cRet := ""
Local cQry := ""

cQry := "SELECT DISTINCT C6_NUM, C6_ITEM, C6_XOBS	"
cQry += "  FROM SIGA."+RETSQLNAME("SC6")+" SC6      "
cQry += " WHERE C6_FILIAL = '"+xFilial("SC6")+"'    "
cQry += "   AND D_E_L_E_T_ = ' '    "
cQry += "   AND C6_NUM = '"+_cPed+"' "
cQry += "   ORDER BY C6_ITEM "

U_ORTQUERY(cQry, "R020OBS")
//MpSysOpenQuery(cQry,"R020OBS")

While R020OBS->(!EOF())
	cRet += ALLTRIM(R020OBS->C6_XOBS)+" "
	R020OBS->( DbSkip() )
EndDo

R020OBS->(DbCloseArea())

Return cRet



Static Function gvaria(cRef)
_nvaria := 0
_cRef 	:= Upper(alltrim(cRef))

If cEmpAnt $ "23"
	If _cRef == "A"
		_nvaria	:= 0.00
	ElseIf _cRef == "B"
		_nvaria	:= 0.05
	ElseIf _cRef == "C"
		_nvaria	:= 0.10
	ElseIf _cRef == "D"
		_nvaria	:= 0.15
	ElseIf _cRef == "E"
		_nvaria	:= 0.20
	ElseIf _cRef == "F"
		_nvaria	:= 0.25
	ElseIf _cRef == "G"
		_nvaria	:= 0.30
	ElseIf _cRef == "H"
		_nvaria	:= 0.35
	ElseIf _cRef == "I"
		_nvaria	:= 0.40
	EndIf
Else
	if _cRef == "B"
		_nvaria := 0.05
	endif
	if _cRef == "C"
		_nvaria := 0.1
	endif
	if _cRef == "D"
		_nvaria := 0.15
	endif
	if _cRef $ "EN"
		_nvaria := 0.2
	endif
	if _cRef == "F"
		_nvaria := 0.25
	endif
	if _cRef == "G"
		_nvaria := 0.3
	endif
	if _cRef == "H"
		_nvaria := 0.35
	endif
	if _cRef == "I"
		_nvaria := 0.4
	endif
EndIf

return _nvaria
