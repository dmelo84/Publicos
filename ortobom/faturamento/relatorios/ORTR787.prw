#INCLUDE "PROTHEUS.CH"
#include "Rwmake.ch"
#include "TopConn.ch"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³NOVO5     º Autor ³ AP6 IDE            º Data ³  21/03/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Codigo gerado pelo AP6 IDE.                                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP6 IDE                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±Alterado porÍ	 Vagner Almeida          Í Data Í     03/05/21            º±±
±±------------Í--------------------------Í------Í-------------------------º±±
±± Descricao  Í	SSI: 115540       		  								  º±±
±±            Í      Solicito que seja incluído no relatório ORTR787 um   º±±
±±            Í      dropdown no final dos parâmetros do relatório, com a º±±
±±            Í      pergunta, IMPRIMIR EM CSV. SIM ou NÃO.               º±±
±± Claudio    Í	SSI: 115540       		  								  º±±
±± Rocha      Í      Solicito que o potencial dos clientes (ORTR 787) sejaº±±
±± 18/05/21   Í		 incluído na proposta de negócio(ORTA 715).			  º±±
±±			  Í		 Deve constar o potencial do cliente em peças e a     º±±
±±			  Í		 compra realizada na proposta e a compra acumulada do º±±
±±			  Í		 trimestre.              							  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
/**********************/
User Function ORTR787()
/**********************/

	Private cQuery 		:= ""
	Private aRelator 	:={}
	Private nomeprog 	:= "ORTR787"
	Private cPerg    	:= "ORTR787"
	Private oPrn,oFont,oFontM,oFont2
	Private cNomFil	 	:= ""
	Private ctitulo  	:= "Participação no Potencial de Clientes"
	Private cDesc1   	:= "Este Mapa deve ser gerado para Gerir a equipe de vendas e verificar a participação em cima do potencial dos clientes."
	Private cHora 	   	:= Time()
	Private nLin       	:= 0
	Private nPag	   	:= 0
	Private nCol	   	:= 10
	Private nVez        := 1
	Private nEsp		:= 30
	Private aTotGer		:= {}
	Private aTGeral		:= {}
	//SSI-115540 - Vagner Almeida - 30/04/2021 - Início
	Private aLinha		:= {} 
	Private aLinhaSem	:= {} 
	//SSI-115540 - Vagner Almeida - 30/04/2021 - Final

	Private _cAgrupa	:= ""

	ValidPerg(cPerg)
	Pergunte(cPerg, .T.)

	oFont	:= TFont():New('Courier new',, 09,, .T.,,,,,.F.,.F.)
	oFontM	:= TFont():New('Courier new',, 10,, .T.,,,,,.F.,.F.)
	oFont2	:= TFont():New('Courier new',, 08,, .T.,,,,,.F.,.F.)
	oFont3	:= TFont():New('Courier new',, 07,, .T.,,,,,.F.,.F.)

	dbSelectArea("SM0")
	dbSeek(cEmpAnt)
	cNomFil := SM0->M0_FILIAL

	oPrn := TMSPrinter():New( ctitulo )
	oPrn:Setup()

	oPrn:SetPortrait()   // Modo Retrato
	oPrn:SetPaperSize(09) // Formato A4

	if !oPrn:Canceled()
		Processa( {|| GeraRel(@oPrn) }, "Aguarde...", "Gerando Relatório...",.T.)
		oPrn:Preview()
		oPrn:End()
	EndIf
	
Return()

/*****************************/
Static Function GeraRel(oPrn)
/*****************************/
	
	local nY, nX

	_cNicho := ""
	_cDescN := ""
	_cAgrIn := ""
	_nVenda := 0
	
	cModTrav:="" // Henrique - 10/03/2021 - SSI 112560
	If !cEmpAnt == '21' 
		cModTrav := ",'000028', '000029'" //tratamento de modelo pois, na Ortofio, esses modelos não são Travesseiro e sim Tecido.
	EndIf

	/* CODIGO DE AGRUPA
	1 - Colchão
	2 - Base
	3 - Cabeceira
	4 - Travesseiro
	5 - Espuma
	6 - Tecido
	7 - Manta
	8 - Molas
	9 - Plastico
	*/
/*
	If MV_PAR12 == 1 //SINTÉTICO
		cQuery := " SELECT  count(proposta) as proposta,C5_VEND1, NOMEVEND, CODGER, NOMEGER, C5_XNICHO, AGRUPA, SUM(C6_QTDVEN) AS VENDA, SUM(C6_UNSVEN) AS VENDA2UN, SUM(ZZE_QUANT) AS ZZE_QUANT, SUM(TRIMESTRE) AS TRIMESTRE  "
		cQuery += "  FROM (SELECT 0 as proposta,C5_VEND1, A3.A3_NOME NOMEVEND, A3GER.A3_COD CODGER, A3GER.A3_NOME NOMEGER,                "
	Else //ANALÍTICO
		cQuery := " SELECT count(proposta) as proposta,C5_VEND1,NOMEVEND, C5_XNICHO, AGRUPA, CODGER, NOMEGER, C5_CLIENTE, SUM(C6_QTDVEN) AS VENDA, SUM(C6_UNSVEN) AS VENDA2UN, SUM(ZZE_QUANT) AS ZZE_QUANT, SUM(TRIMESTRE) AS TRIMESTRE "
		cQuery += "  FROM (SELECT 0 as proposta,C5_VEND1, A3.A3_NOME NOMEVEND, A3GER.A3_COD CODGER, A3GER.A3_NOME NOMEGER, C5_CLIENTE,    "
	EndIf
	cQuery += "               CASE                                                                                          "
	cQuery += "                 WHEN B1_XMODELO IN ('000002', '000003', '000004', '000005') THEN                            "
	cQuery += "                  '1'                                                                                        "
	cQuery += "                 WHEN B1_TIPO = 'PA' AND B1_DESC LIKE 'CONJUG%' THEN                                         "
	cQuery += "                  '1'                                                                                        "
	cQuery += "                 WHEN B1_XMODELO IN ('000001', '000021') THEN                                                "
	cQuery += "                  '2'                                                                                        "
	cQuery += "                 WHEN B1_TIPO = 'PA' AND B1_DESC LIKE 'CABECE%' THEN                                         "
	cQuery += "                  '3'                                                                                        "
	cQuery += "                 WHEN B1_XMODELO IN                                                                          "
	cQuery += "                      ('000006', '000017', '000019'"+cModTrav+") THEN                                        "
	cQuery += "                  '4'                                                                                        "
	cQuery += "                 WHEN B1_XMODELO IN ('000008', '000009', '000010', '000011',                                 "
	cQuery += "                       '000012', '000018') THEN                                                              "
	cQuery += "                  '5'                                                                                        "
	cQuery += "                 WHEN B1_TIPO = 'PA' AND                                                                     "
	cQuery += "                      B1_GRUPO IN ('2343', '2344', '2345', '2353', '3530',                                   "
	cQuery += "                       '3637', '5020', '5070', '6644', '6645') THEN                                          "
	cQuery += "                  '6'                                                                                        "
	cQuery += "                 WHEN B1_XMODELO IN ('000014') THEN                                                          "
	cQuery += "                  '7'                                                                                        "
	cQuery += "                 WHEN B1_XMODELO IN                                                                          "
	cQuery += "                      ('000022', '000023', '000024', '000025', '000026',                                     "
	cQuery += "                       '000027', '000028', '000033', '000034', '000035',                                     "
	cQuery += "                       '000036', '000037', '000038', '000039', '000040',                                     "
	cQuery += "                       '000041', '000042', '000043', '000123', '000124',                                     "
	cQuery += "                       '000125', '000126', '000127', '000128', '000129',                                     "
	cQuery += "                       '000130', '000131', '000132', '000133', '000134',                                     "
	cQuery += "                       '000135', '000136', '000137', '000138', '000139',                                     "
	cQuery += "                       '000140', '000141', '000142', '000143', '000145',                                     "
	cQuery += "                       '000146', '000148', '001023', '001024', '001025',                                     "
	cQuery += "                       '001026', '001027', '001028', '001123', '001124',                                     "
	cQuery += "                       '001125', '001126', '001127', '001128', '001129',                                     "
	cQuery += "                       '001130', '001131', '001144', '001147') THEN                                          "
	cQuery += "                  '9'                                                                                        "
	cQuery += "                 WHEN SUBSTR(B1_XMODELO,1,2)='24' THEN                                                       "
	cQuery += "                  '9'                                                                                        "
	cQuery += "               END AS AGRUPA,                                                                                "
	cQuery += "               C5_XNICHO,                                                                                    "
	//cQuery += "               C6_QTDVEN, mudança para tratar peso quando for Espuma                                       "
	cQuery += "               CASE WHEN B1_XMODELO IN ('000008', '000009', '000010',										" 
	cQuery += "               '000012', '000018') THEN																		"
	cQuery += "               		C6_QTDVEN * B1_PESO 																	"
	cQuery += "               WHEN SUBSTR(B1_XMODELO, 1, 2) = '24' AND B1_XMODELO <> '240007' THEN							"
	cQuery += "               		C6_UNSVEN																				"
	cQuery += "               ELSE																							"
	cQuery += "               		C6_QTDVEN																				"
	cQuery += "               END C6_QTDVEN,																				"
	cQuery += "               C6_UNSVEN, 0 AS ZZE_QUANT,                                                                     "
	cQuery += "               0 AS TRIMESTRE                                                                     "
	cQuery += "          FROM " + RetSQLName("SC5") + " C5, " + RetSQLName("SC6") + " C6, " + RetSQLName("SB1") + " B1,     "
	cQuery += "               " + RetSQLName("SA3") + " A3, " + RetSQLName("SA3") + " A3GER, " + RetSQLName("SZH") + " ZH   "
	cQuery += "         WHERE C5.D_E_L_E_T_ = ' '                                                                           "
	cQuery += "           AND C6.D_E_L_E_T_ = ' '                                                                           "
	cQuery += "           AND B1.D_E_L_E_T_ = ' '                                                                           "
	cQuery += "           AND A3.D_E_L_E_T_ = ' '                                                                           "
	cQuery += "           AND A3GER.D_E_L_E_T_(+) = ' '                                                                     "
	cQuery += "           AND ZH.D_E_L_E_T_ = ' '                                                                           "
	cQuery += "           AND C5_FILIAL          = '"+xFilial("SC5")+"'                                                     "
	cQuery += "           AND C6_FILIAL          = '"+xFilial("SC6")+"'                                                     "
	cQuery += "           AND B1_FILIAL          = '"+xFilial("SB1")+"'                                                     "
	cQuery += "           AND A3.A3_FILIAL       = '"+xFilial("SA3")+"'                                                     "
	cQuery += "           AND A3GER.A3_FILIAL(+) = '"+xFilial("SA3")+"'                                                     "
	cQuery += "           AND ZH_FILIAL          = '"+xFilial("SZH")+"'                                                     "
	cQuery += "           AND C5_NUM = C6_NUM                                                                               "
	cQuery += "           AND C5_CLIENTE = C6_CLI                                                                           "
	cQuery += "           AND C5_LOJACLI = C6_LOJA                                                                          "
	cQuery += "           AND B1_COD = C6_PRODUTO                                                                           "
	cQuery += "           AND C5_CLIENTE = ZH_CLIENTE                                                                       "
	cQuery += "           AND C5_LOJACLI = ZH_LOJA                                                                          "
	cQuery += "           AND C5_XTPSEGM = ZH_SEGMENT                                                                       "
	cQuery += "           AND A3.A3_COD = C5_VEND1                                                                          "
	cQuery += "           AND A3.A3_GEREN = A3GER.A3_COD(+)                                                                 "
	cQuery += "           AND C5_XTPSEGM IN ('1', '2', '5', '6')                                                            "
	//cQuery += "           AND C5_XOPER IN ('01', '14')                                                                      "
	cQuery += "           AND C5_XOPER IN  ('01','04','05','10','11','14','15','16','20','21','19','26','27') "
	cQuery += "           AND C5_EMISSAO      BETWEEN '"+DtoS(MV_PAR01)+"' AND '"+DtoS(MV_PAR02)+"'                         "
	If MV_PAR11 == 2 //Liberado
		cQuery += "       AND C5_XDTLIB <> ' '                                                                              "
	ElseIf MV_PAR11 == 3 //Faturado
		cQuery += "       AND C5_NOTA <> ' '                                                                                "
	ElseIf MV_PAR11 == 4 //Acertado
		cQuery += "       AND C5_XDTFECH <> ' '                                                                             "
	End
	cQuery += "           AND A3GER.A3_COD(+) BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"'                                     "
	cQuery += "           AND C5_VEND1        BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"'                                     "
	cQuery += "           AND ZH_ITINER       BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"'                                     "
	cQuery += "           AND C5_XNICHO       BETWEEN '"+MV_PAR09+"' AND '"+MV_PAR10+"'                                     "

	//claudio rocha inicio 
	
	cQuery += "         UNION                                                                                               "

	If MV_PAR12 == 1 //SINTÉTICO
		cQuery += "         SELECT C5_XPRONUM as proposta,C5_VEND1,        A3.A3_NOME NOMEVEND,        A3GER.A3_COD CODGER,        A3GER.A3_NOME NOMEGER, "	
	Else //ANALÍTICO
		cQuery += "         SELECT C5_XPRONUM as proposta,C5_VEND1,  A3.A3_NOME NOMEVEND, A3GER.A3_COD CODGER, A3GER.A3_NOME NOMEGER,C5_CLIENTE, "
	EndIf
	cQuery += "               CASE                                                                                          "
	cQuery += "                 WHEN B1_XMODELO IN ('000002', '000003', '000004', '000005') THEN                            "
	cQuery += "                  '1'                                                                                        "
	cQuery += "                 WHEN B1_TIPO = 'PA' AND B1_DESC LIKE 'CONJUG%' THEN                                         "
	cQuery += "                  '1'                                                                                        "
	cQuery += "                 WHEN B1_XMODELO IN ('000001', '000021') THEN                                                "
	cQuery += "                  '2'                                                                                        "
	cQuery += "                 WHEN B1_TIPO = 'PA' AND B1_DESC LIKE 'CABECE%' THEN                                         "
	cQuery += "                  '3'                                                                                        "
	cQuery += "                 WHEN B1_XMODELO IN                                                                          "
	cQuery += "                      ('000006', '000017', '000019'"+cModTrav+") THEN                                        "
	cQuery += "                  '4'                                                                                        "
	cQuery += "                 WHEN B1_XMODELO IN ('000008', '000009', '000010', '000011',                                 "
	cQuery += "                       '000012', '000018') THEN                                                              "
	cQuery += "                  '5'                                                                                        "
	cQuery += "                 WHEN B1_TIPO = 'PA' AND                                                                     "
	cQuery += "                      B1_GRUPO IN ('2343', '2344', '2345', '2353', '3530',                                   "
	cQuery += "                       '3637', '5020', '5070', '6644', '6645') THEN                                          "
	cQuery += "                  '6'                                                                                        "
	cQuery += "                 WHEN B1_XMODELO IN ('000014') THEN                                                          "
	cQuery += "                  '7'                                                                                        "
	cQuery += "                 WHEN B1_XMODELO IN                                                                          "
	cQuery += "                      ('000022', '000023', '000024', '000025', '000026',                                     "
	cQuery += "                       '000027', '000028', '000033', '000034', '000035',                                     "
	cQuery += "                       '000036', '000037', '000038', '000039', '000040',                                     "
	cQuery += "                       '000041', '000042', '000043', '000123', '000124',                                     "
	cQuery += "                       '000125', '000126', '000127', '000128', '000129',                                     "
	cQuery += "                       '000130', '000131', '000132', '000133', '000134',                                     "
	cQuery += "                       '000135', '000136', '000137', '000138', '000139',                                     "
	cQuery += "                       '000140', '000141', '000142', '000143', '000145',                                     "
	cQuery += "                       '000146', '000148', '001023', '001024', '001025',                                     "
	cQuery += "                       '001026', '001027', '001028', '001123', '001124',                                     "
	cQuery += "                       '001125', '001126', '001127', '001128', '001129',                                     "
	cQuery += "                       '001130', '001131', '001144', '001147') THEN                                          "
	cQuery += "                  '9'                                                                                        "
	cQuery += "                 WHEN SUBSTR(B1_XMODELO,1,2)='24' THEN                                                       "
	cQuery += "                  '9'                                                                                        "
	cQuery += "               END AS AGRUPA,                                                                                "
	cQuery += "               C5_XNICHO,                                                                                    "
	cQuery += "               0 AS C6_QTDVEN,																				"
	cQuery += "               0 AS C6_UNSVEN, 0 AS ZZE_QUANT ,
	cQuery += "               C6_QTDVEN AS TRIMESTRE	                                                                                    "
	cQuery += "          FROM " + RetSQLName("SC5") + " C5, " + RetSQLName("SC6") + " C6, " + RetSQLName("SB1") + " B1,     "
	cQuery += "               " + RetSQLName("SA3") + " A3, " + RetSQLName("SA3") + " A3GER, " + RetSQLName("SZH") + " ZH   "
	cQuery += "         WHERE C5.D_E_L_E_T_ = ' '                                                                           "
	cQuery += "           AND C6.D_E_L_E_T_ = ' '                                                                           "
	cQuery += "           AND B1.D_E_L_E_T_ = ' '                                                                           "
	cQuery += "           AND A3.D_E_L_E_T_ = ' '                                                                           "
	cQuery += "           AND A3GER.D_E_L_E_T_(+) = ' '                                                                     "
	cQuery += "           AND ZH.D_E_L_E_T_ = ' '                                                                           "
	cQuery += "           AND C5_FILIAL          = '"+xFilial("SC5")+"'                                                     "
	cQuery += "           AND C6_FILIAL          = '"+xFilial("SC6")+"'                                                     "
	cQuery += "           AND B1_FILIAL          = '"+xFilial("SB1")+"'                                                     "
	cQuery += "           AND A3.A3_FILIAL       = '"+xFilial("SA3")+"'                                                     "
	cQuery += "           AND A3GER.A3_FILIAL(+) = '"+xFilial("SA3")+"'                                                     "
	cQuery += "           AND ZH_FILIAL          = '"+xFilial("SZH")+"'                                                     "
	cQuery += "           AND C5_NUM = C6_NUM                                                                               "
	cQuery += "           AND C5_CLIENTE = C6_CLI                                                                           "
	cQuery += "           AND C5_LOJACLI = C6_LOJA                                                                          "
	cQuery += "           AND B1_COD = C6_PRODUTO                                                                           "
	cQuery += "           AND C5_CLIENTE = ZH_CLIENTE                                                                       "
	cQuery += "           AND C5_LOJACLI = ZH_LOJA                                                                          "
	cQuery += "           AND C5_XTPSEGM = ZH_SEGMENT                                                                       "
	cQuery += "           AND A3.A3_COD = C5_VEND1                                                                          "
	cQuery += "           AND A3.A3_GEREN = A3GER.A3_COD(+)                                                                 "
	cQuery += "           AND C5_XTPSEGM IN ('1', '2', '5', '6')                                                            "
	cQuery += "           AND C5_XOPER IN  ('01','04','05','10','11','14','15','16','20','21','19','26','27') "
	//cQuery += "           AND C5_XOPER IN ('01', '14')                            

	nDIAS 		:= FIRSTDAY(MV_PAR01)-1
	NDIASpER 	:= FIRSTDAY(NDIAS) -90
	
	cQuery += "           AND C5_EMISSAO      BETWEEN '"+DtoS(NDIASpER)+"' AND '"+DtoS(nDIAS)+"'                         "
	If MV_PAR11 == 2 	 //Liberado
		cQuery += "       AND C5_XDTLIB <> ' '                                                                              "
	ElseIf MV_PAR11 == 3 //Faturado
		cQuery += "       AND C5_NOTA <> ' '                                                                                "
	ElseIf MV_PAR11 == 4 //Acertado
		cQuery += "       AND C5_XDTFECH <> ' '                                                                             "
	End
	cQuery += "           AND A3GER.A3_COD(+) BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"'                                     "
	cQuery += "           AND C5_VEND1        BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"'                                     "
	cQuery += "           AND ZH_ITINER       BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"'                                     "
	cQuery += "           AND C5_XNICHO       BETWEEN '"+MV_PAR09+"' AND '"+MV_PAR10+"'                                     "
	
	//claudio rocha fim
/*
	cQuery += "         UNION                                                                                               "

	If MV_PAR12 == 1 //SINTÉTICO
		cQuery += "         SELECT proposta,C5_VEND1,  NOMEVEND,  CODGER,    NOMEGER,   AGRUPA,    C5_XNICHO, C6_QTDVEN, C6_UNSVEN, ZZE_QUANT, 0 AS TRIMESTRE "
		cQuery += "           FROM (SELECT 0 as proposta,A3.A3_COD AS C5_VEND1,    A3.A3_NOME AS NOMEVEND,   A3GER.A3_COD AS CODGER,   A3GER.A3_NOME AS NOMEGER, ZZE_AGRUPA AS AGRUPA,     ZZE_NICHO AS C5_XNICHO,   0 AS C6_QTDVEN, 0 AS C6_UNSVEN, SUM(ZZE_QUANT) ZZE_QUANT, 0 AS TRIMESTRE"
	Else //ANALÍTICO
		cQuery += "         SELECT proposta,C5_VEND1,  NOMEVEND, CODGER,    NOMEGER, C5_CLIENTE,   AGRUPA,    C5_XNICHO, C6_QTDVEN, C6_UNSVEN, ZZE_QUANT, 0 AS TRIMESTRE  "
		cQuery += "           FROM (SELECT 0 as proposta, A3.A3_COD AS C5_VEND1,    A3.A3_NOME AS NOMEVEND,  A3GER.A3_COD AS CODGER,   A3GER.A3_NOME AS NOMEGER, ZH_CLIENTE AS C5_CLIENTE, ZZE_AGRUPA AS AGRUPA,     ZZE_NICHO AS C5_XNICHO,   0 AS C6_QTDVEN,   0 AS C6_UNSVEN,  SUM(ZZE_QUANT) ZZE_QUANT, 0 AS TRIMESTRE "
	EndIf
	cQuery += "                   FROM " + RetSQLName("ZZE") + " ZZE,                                                       "
	cQuery += "                        " + RetSQLName("SZH") + " ZH,                                                        "
	cQuery += "                        " + RetSQLName("SA3") + " A3,                                                        "
	cQuery += "                        " + RetSQLName("SA3") + " A3GER,                                                     "
	cQuery += "                        " + RetSQLName("SA1") + " A1                                                         "
	cQuery += "                  WHERE ZZE.D_E_L_E_T_ = ' '                                                                 "
	cQuery += "                    AND ZH.D_E_L_E_T_ = ' '                                                                  "
	cQuery += "                    AND A1.D_E_L_E_T_ = ' '                                                                  "
	cQuery += "                    AND ZZE_FILIAL = '"+xFilial("ZZE")+"'                                                    "
	cQuery += "                    AND ZH_FILIAL = '"+xFilial("SZH")+"'                                                     "
	cQuery += "                    AND A1_FILIAL = '"+xFilial("SA1")+"'                                                     "
	cQuery += "                    AND A3.A3_FILIAL = '"+xFilial("SA3")+"'                                                  "
	cQuery += "                    AND A3GER.A3_FILIAL(+) = '"+xFilial("SA3")+"'                                            "
	cQuery += "                    AND ZZE_CODCLI = ZH_CLIENTE                                                              "
	cQuery += "                    AND A1_COD     = ZH_CLIENTE                                                              "
	cQuery += "                    AND A1_MSBLQL != '1'                                                                     "
	cQuery += "                    AND A3.D_E_L_E_T_ = ' '                                                                  "
	cQuery += "                    AND A3GER.D_E_L_E_T_(+) = ' '                                                            "
	cQuery += "                    AND A3.A3_COD = ZH_VEND                                                                  "
	cQuery += "                    AND A3.A3_GEREN = A3GER.A3_COD(+)                                                        "
	cQuery += "                    AND A3GER.A3_COD(+) BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"'                            "
	cQuery += "                    AND ZZE_NICHO       BETWEEN '"+MV_PAR09+"' AND '"+MV_PAR10+"'                            "
	cQuery += "                    AND ZH_VEND         BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"'                            "
    cQuery += "                    AND ZH_ITINER       BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"'                                     "
	cQuery += "                  GROUP BY A3.A3_COD,                                                                        "
	cQuery += "                           A3.A3_NOME,                                                                       "
	If MV_PAR12 == 2 //ANALÍTICO
		cQuery += "                           ZH_CLIENTE,                                                                     "
	EndIf
	cQuery += "                           A3GER.A3_COD,                                                                     "
	cQuery += "                           A3GER.A3_NOME,                                                                    "
	cQuery += "                           ZZE_AGRUPA,                                                                       "
	cQuery += "                           ZZE_NICHO)                                                                        "
*/
/*
	cQuery += "           )                                                                                                 "
	cQuery += " WHERE AGRUPA IS NOT NULL                                                                                    "

	If MV_PAR12 == 1 //SINTÉTICO
		cQuery += " GROUP BY C5_VEND1, NOMEVEND, C5_XNICHO, AGRUPA,CODGER, NOMEGER 							                "
		cQuery += " ORDER BY CODGER, C5_VEND1, C5_XNICHO, AGRUPA                                                            "
	Else
		cQuery += " GROUP BY C5_VEND1, NOMEVEND, C5_XNICHO, AGRUPA,CODGER, NOMEGER, C5_CLIENTE                              "
		cQuery += " ORDER BY CODGER, C5_VEND1, C5_CLIENTE, C5_XNICHO, AGRUPA                                                "
	EndIf
*/
	//somatoria geral
	If MV_PAR12 == 1 //SINTÉTICO
		cQuery := " SELECT  SUM(PROPOSTA) as proposta	,C5_VEND1, NOMEVEND, CODGER, NOMEGER, 	C5_XNICHO, AGRUPA, SUM(VENDA) AS VENDA, SUM(VENDA2UN) AS VENDA2UN, SUM(ZZE_QUANT) AS ZZE_QUANT, SUM(TRIMESTRE) AS TRIMESTRE  "
//		cQuery += "  FROM (SELECT 0 as proposta,C5_VEND1, A3.A3_NOME NOMEVEND, A3GER.A3_COD CODGER, A3GER.A3_NOME NOMEGER,                "
	Else //ANALÍTICO
		cQuery := " SELECT SUM(PROPOSTA) as proposta	,C5_VEND1, NOMEVEND, CODGER, NOMEGER,	C5_XNICHO, AGRUPA,  SUM(VENDA) AS VENDA, SUM(VENDA2UN) AS VENDA2UN, SUM(ZZE_QUANT) AS ZZE_QUANT, SUM(TRIMESTRE) AS TRIMESTRE,C5_CLIENTE "
		//cQuery += "  FROM (SELECT 0 as proposta,C5_VEND1, A3.A3_NOME NOMEVEND, A3GER.A3_COD CODGER, A3GER.A3_NOME NOMEGER, C5_CLIENTE,    "
	EndIf
		cQuery += " FROM ( "
       
		//somatoria colchoes
		cQuery += "SELECT PROPOSTA, "
       	cQuery += "C5_VEND1, "
		cQuery += "NOMEVEND, "		   
       	cQuery += "CODGER, "
        cQuery += "NOMEGER, "
       	cQuery += "C5_XNICHO, "
		cQuery += "AGRUPA, "
        cQuery += "SUM(QTDVEN) AS VENDA, "
        cQuery += "SUM(C6_UNSVEN) AS VENDA2UN, "
        cQuery += "SUM(ZZE_QUANT) AS ZZE_QUANT, "
        cQuery += "SUM(TRIMESTRE) AS TRIMESTRE   "    

		If MV_PAR12 == 2 //analitico
			cQuery += " ,C5_CLIENTE "
		EndIf
       
       
 		cQuery += "FROM (                        "

 		cQuery += "SELECT 0 as PROPOSTA,PRUNIT , QTDVEN , OTPCOL , TPSEGM , OPER ,  PRZMED , CUSTO , B1_XCODBAS , VERBREP, GUELTA, RESSARC, DECODE(B1_XLARG,1.28,'C',1.38,'C',1.58,'C',1.80,'C',1.86,'C',1.93,'C',0.78,'S',0.88,'S',0.60,'B','X') TP_MED, "
        cQuery += " C5_VEND1, "
        cQuery += " A3.A3_NOME NOMEVEND, "
        cQuery += " A3GER.A3_COD CODGER, "
        cQuery += " A3GER.A3_NOME NOMEGER, "
        cQuery += " C5_CLIENTE, "
        cQuery += " CASE WHEN B1_XMODELO IN ('000002','000003','000004','000005')  "
        cQuery += "           THEN '1' "
        cQuery += "      WHEN B1_TIPO = 'PA' AND B1_DESC LIKE 'CONJUG%' "
        cQuery += "           THEN '1' "
/*        cQuery += "      WHEN B1_XMODELO IN ('000001','000021') "
        cQuery += "           THEN '2' "
        cQuery += "      WHEN B1_TIPO = 'PA' AND B1_DESC LIKE 'CABECE%' "
        cQuery += "           THEN '3' "
        cQuery += "      WHEN B1_XMODELO IN ('000006','000017','000019'"+cModTrav+") " 
        cQuery += "           THEN '4' "
        cQuery += "      WHEN B1_XMODELO IN ('000008','000009','000010','000011','000012','000018') "
        cQuery += "           THEN '5' "
        cQuery += "      WHEN B1_TIPO = 'PA' AND B1_GRUPO IN ('2343','2344','2345','2353','3530','3637','5020','5070','6644','6645') "
        cQuery += "           THEN '6' "
        cQuery += "      WHEN B1_XMODELO IN ('000014') "
        cQuery += "           THEN '7' "
        cQuery += "      WHEN B1_XMODELO IN ('000022','000023','000024','000025','000026','000027','000028','000033','000034','000035','000036','000037','000038','000039','000040','000041','000042','000043','000123','000124','000125','000126','000127','000128','000129','000130','000131','000132','000133','000134','000135','000136','000137','000138','000139','000140','000141','000142','000143','000145','000146','000148','001023','001024','001025','001026','001027','001028','001123','001124','001125','001126','001127','001128','001129','001130','001131','001144','001147') "
        cQuery += "           THEN '9' "
        cQuery += "      WHEN SUBSTR(B1_XMODELO,1,2)='24' "
        cQuery += "           THEN '9'   "*/
        cQuery += "      END AS AGRUPA, "
        cQuery += "  C5_XNICHO, "
        cQuery += " CASE WHEN B1_XMODELO IN ('000008','000009','000010','000012','000018') "
        cQuery += "           THEN C6_QTDVEN * B1_PESO WHEN SUBSTR(B1_XMODELO,1,2) = '24' AND B1_XMODELO <> '240007'  "
        cQuery += "           THEN C6_UNSVEN "
        cQuery += "      ELSE QTDVEN "
        cQuery += "      END C6_QTDVEN, "
        cQuery += " C6_UNSVEN, "
        cQuery += " 0 as ZZE_QUANT, "
        cQuery += " 0 AS TRIMESTRE "

		cQuery += " FROM " + RetSQLName("SC5") + " C5  , " + RetSQLName("SB1") + " B1 , " + RetSQLName("SA3") + " A3 , " + RetSQLName("SA3") + " A3GER , " + RetSQLName("SZH") + " ZH, " + RetSQLName("SC6") + " C6 ,V_MIX"+CEMPANT+"0 MIX "
		cQuery += " WHERE  C5.D_E_L_E_T_ = ' '  "
		cQuery += " AND C6.D_E_L_E_T_ = ' ' "
		cQuery += " AND B1.D_E_L_E_T_ = ' ' "
		cQuery += " AND A3.D_E_L_E_T_ = ' ' "
		cQuery += " AND A3GER.D_E_L_E_T_(+) = ' ' "
		cQuery += " AND ZH.D_E_L_E_T_ = ' ' "

		cQuery += "           AND C5_FILIAL          = '"+xFilial("SC5")+"'                                                     "
		cQuery += "           AND C6_FILIAL          = '"+xFilial("SC6")+"'                                                     "
		cQuery += "           AND B1_FILIAL          = '"+xFilial("SB1")+"'                                                     "
		cQuery += "           AND A3.A3_FILIAL       = '"+xFilial("SA3")+"'                                                     "
		cQuery += "           AND A3GER.A3_FILIAL(+) = '"+xFilial("SA3")+"'                                                     "
		cQuery += "           AND ZH_FILIAL          = '"+xFilial("SZH")+"'                                                     "


		cQuery += " AND C5_NUM = C6_NUM "
		cQuery += " AND C5_CLIENTE = C6_CLI "
		cQuery += " AND C5_LOJACLI = C6_LOJA "
		cQuery += " AND B1_COD = C6_PRODUTO "
		cQuery += " AND C5_CLIENTE = ZH_CLIENTE "
		cQuery += " AND C5_LOJACLI = ZH_LOJA "
		cQuery += " AND C5_XTPSEGM = ZH_SEGMENT "
		cQuery += " AND A3.A3_COD = C5_VEND1 "
		cQuery += " AND A3.A3_GEREN = A3GER.A3_COD(+) "
		cQuery += " AND C5_EMISSAO BETWEEN '"+DtoS(MV_PAR01)+"' AND '"+DtoS(MV_PAR02)+"'                         "

		If MV_PAR11 == 2 //Liberado
			cQuery += "       AND C5_XDTLIB <> ' '     "                                                                         "
		ElseIf MV_PAR11 == 3 //Faturado
			cQuery += "       AND C5_NOTA <> ' '        "                                                                        "
		ElseIf MV_PAR11 == 4 //Acertado
			cQuery += "       AND C5_XDTFECH <> ' '      "                                                                       "
		End

		cQuery += "           AND A3GER.A3_COD(+) BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"'                                     "
		cQuery += "           AND C5_VEND1        BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"'                                     "
		cQuery += "           AND ZH_ITINER       BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"'                                     "
		cQuery += "           AND C5_XNICHO       BETWEEN '"+MV_PAR09+"' AND '"+MV_PAR10+"'                                     "

		cQuery += " AND  C6_PRODUTO = COD AND C6_NUM = NUM AND C6_CLI = CLIENTE "
		
		cQuery += " AND OPER in ('01','04','05','10','11','14','15','16','20','21','19','26','27')  "
		cQuery += " AND TPSEGM  IN ('2','1')  "
		cQuery += " AND EMISSAO BETWEEN '"+DtoS(MV_PAR01)+"' AND '"+DtoS(MV_PAR02)+"'                         "
		cQuery += " AND OMODLEO  IN ('001','002','003')  "
		cQuery += " AND NICHO BETWEEN '"+MV_PAR09+"' AND '"+MV_PAR10+"'                                     "

		cQuery += " ) "
 
   		cQuery += " WHERE  AGRUPA IS NOT NULL "
   		

		If MV_PAR12 == 1 //SINTÉTICO
			cQuery += " GROUP BY PROPOSTA,C5_VEND1, NOMEVEND, C5_XNICHO, AGRUPA,CODGER, NOMEGER "
		Else
			cQuery += " GROUP BY PROPOSTA,C5_VEND1, NOMEVEND, C5_XNICHO, AGRUPA,CODGER, NOMEGER, C5_CLIENTE                            "
		EndIf


		cQuery += " union "

        //somatoria componentes
		cQuery += " SELECT PROPOSTA, "
        cQuery += " C5_VEND1, "
        cQuery += " NOMEVEND, "
		cQuery += " CODGER, "
		cQuery += " NOMEGER, "
        cQuery += " C5_XNICHO, "
        cQuery += " AGRUPA, "
        
        

        cQuery += " SUM(QTDVEN) AS VENDA, "
        cQuery += " SUM(C6_UNSVEN) AS VENDA2UN, "
        cQuery += " SUM(ZZE_QUANT) AS ZZE_QUANT, "
        cQuery += " SUM(TRIMESTRE) AS TRIMESTRE   "    

		If MV_PAR12 == 2 //analitico
			cQuery += " ,C5_CLIENTE "
		EndIf
       
       
		cQuery += " FROM (                        "

 		cQuery += " SELECT 0 as PROPOSTA,PRUNIT ,  OTPCOL , TPSEGM , OPER ,  PRZMED , CUSTO , B1_XCODBAS , VERBREP, GUELTA, RESSARC, DECODE(B1_XLARG,1.28,'C',1.38,'C',1.58,'C',1.80,'C',1.86,'C',1.93,'C',0.78,'S',0.88,'S',0.60,'B','X') TP_MED, "
        cQuery += " C5_VEND1, "
        cQuery += " A3.A3_NOME NOMEVEND, "
        cQuery += " A3GER.A3_COD CODGER, "
        cQuery += " A3GER.A3_NOME NOMEGER, "
        cQuery += " C5_CLIENTE, "
        cQuery += " CASE  "
        cQuery += " WHEN B1_XMODELO IN ('000001','000021') "
        cQuery += " THEN '2' "
        cQuery += " WHEN B1_TIPO = 'PA' AND B1_DESC LIKE 'CABECE%' "
        cQuery += " THEN '3' "
        cQuery += " WHEN B1_XMODELO IN ('000017','000028','000029') "//('000017'"+cModTrav+") "  //('000006','000017'"+cModTrav+") " 
        cQuery += " THEN '4' "
        cQuery += " WHEN B1_XMODELO IN ('000008','000009','000010','000011','000012','000018')  "
        cQuery += " THEN '5' "
        cQuery += " WHEN B1_TIPO = 'PA' AND B1_GRUPO IN ('2343','2344','2345','2353','3530','3637','5020','5070','6644','6645') "
        cQuery += " THEN '6' "
        cQuery += " WHEN B1_XMODELO IN ('000014') "
        cQuery += " THEN '7' "
        cQuery += " WHEN B1_XMODELO IN ('000022','000023','000024','000025','000026','000027','000028','000033','000034','000035','000036','000037','000038','000039','000040','000041','000042','000043','000123','000124','000125','000126','000127','000128','000129','000130','000131','000132','000133','000134','000135','000136','000137','000138','000139','000140','000141','000142','000143','000145','000146','000148','001023','001024','001025','001026','001027','001028','001123','001124','001125','001126','001127','001128','001129','001130','001131','001144','001147')  "
        cQuery += " THEN '9' "
        cQuery += " WHEN SUBSTR(B1_XMODELO,1,2)='24' "
        cQuery += " THEN '9'  "
        cQuery += " END AS AGRUPA, "

        cQuery += " C5_XNICHO, "

        cQuery += " CASE WHEN B1_XMODELO IN ('000008','000009','000010','000012','000018',   '000011','000013') " //('000008','000009','000010','000012','000018') "
        cQuery += " THEN C6_QTDVEN * B1_PESO WHEN SUBSTR(B1_XMODELO,1,2) = '24' AND B1_XMODELO <> '240007' "
        cQuery += " THEN C6_UNSVEN "
        cQuery += " ELSE QTDVEN "
        cQuery += " END QTDVEN, "

        cQuery += " C6_UNSVEN, "
        cQuery += " 0 as ZZE_QUANT, "
        cQuery += " 0 AS TRIMESTRE "

		cQuery += " FROM " + RetSQLName("SC5") + " C5  , " + RetSQLName("SB1") + " B1 , " + RetSQLName("SA3") + " A3 , " + RetSQLName("SA3") + " A3GER , " + RetSQLName("SZH") + " ZH, " + RetSQLName("SC6") + " C6 ,V_MIX"+CEMPANT+"0 MIX "
		cQuery += " WHERE       C5.D_E_L_E_T_ 		= ' ' "
		cQuery += " 		AND C6.D_E_L_E_T_ 		= ' ' "
		cQuery += " 		AND B1.D_E_L_E_T_ 		= ' ' "
		cQuery += " 		AND A3.D_E_L_E_T_ 		= ' ' "
		cQuery += " 		AND A3GER.D_E_L_E_T_(+) = ' ' "
		cQuery += " 		AND ZH.D_E_L_E_T_ 		= ' ' "

		cQuery += "         AND C5_FILIAL          	= '"+xFilial("SC5")+"'                                                     "
		cQuery += "         AND C6_FILIAL          	= '"+xFilial("SC6")+"'                                                     "
		cQuery += "         AND B1_FILIAL          	= '"+xFilial("SB1")+"'                                                     "
		cQuery += "         AND A3.A3_FILIAL       	= '"+xFilial("SA3")+"'                                                     "
		cQuery += "         AND A3GER.A3_FILIAL(+) 	= '"+xFilial("SA3")+"'                                                     "
		cQuery += "         AND ZH_FILIAL          	= '"+xFilial("SZH")+"'                                                     "

		cQuery += " 		AND C5_NUM 				= C6_NUM "
		cQuery += " 		AND C5_CLIENTE 			= C6_CLI "
		cQuery += " 		AND C5_LOJACLI 			= C6_LOJA "
		cQuery += " 		AND B1_COD 				= C6_PRODUTO "
		cQuery += " 		AND C5_CLIENTE 			= ZH_CLIENTE "
		cQuery += " 		AND C5_LOJACLI 			= ZH_LOJA "
		cQuery += " 		AND C5_XTPSEGM 			= ZH_SEGMENT "
		cQuery += " 		AND A3.A3_COD 			= C5_VEND1 "
		cQuery += " 		AND A3.A3_GEREN 		= A3GER.A3_COD(+) "
		//cQuery += " AND C5_XTPSEGM IN ('1', '2', '5', '6') "
		//cQuery += " AND C5_XOPER IN ('01', '14') "
		cQuery += " 		AND C5_EMISSAO 			BETWEEN '"+DtoS(MV_PAR01)+"' AND '"+DtoS(MV_PAR02)+"'                         "

		If MV_PAR11 == 2 //Liberado
			cQuery += "     AND C5_XDTLIB 			<> ' ' "                                                                              "
		ElseIf MV_PAR11 == 3 //Faturado
			cQuery += "     AND C5_NOTA 			<> ' '    "                                                                            "
		ElseIf MV_PAR11 == 4 //Acertado
			cQuery += "     AND C5_XDTFECH 			<> ' '  "                                                                           "
		End

		cQuery += "         AND A3GER.A3_COD(+)	 	BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"'                                     "
		cQuery += "         AND C5_VEND1        	BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"'                                     "
		cQuery += "         AND ZH_ITINER       	BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"'                                     "
		cQuery += "         AND C5_XNICHO       	BETWEEN '"+MV_PAR09+"' AND '"+MV_PAR10+"'                                     "


		cQuery += " 		AND  C6_PRODUTO 		= COD AND C6_NUM = NUM AND C6_CLI = CLIENTE "
		cQuery += " 		AND EMISSAO 			BETWEEN '"+DtoS(MV_PAR01)+"' AND '"+DtoS(MV_PAR02)+"'                         "
		cQuery += " 		AND NICHO 				BETWEEN '"+MV_PAR09+"' AND '"+MV_PAR10+"'                                     "
		cQuery += "  		AND OPER 				in ('01','04','05','10','11','14','15','16','20','21','19','26','27')  "
		cQuery += "  		AND TPSEGM 				IN ('2','1') "

 		cQuery += " ) "
 
   		cQuery += " WHERE  AGRUPA IS NOT NULL "

		If MV_PAR12 == 1 //SINTÉTICO
			cQuery += " GROUP BY PROPOSTA,C5_VEND1, NOMEVEND, C5_XNICHO, AGRUPA,CODGER, NOMEGER  "
		Else
			cQuery += " GROUP BY PROPOSTA,C5_VEND1, NOMEVEND, C5_XNICHO, AGRUPA,CODGER, NOMEGER, C5_CLIENTE    "
		EndIf

		cQuery += " UNION  "

        //somatoria trimestre e proposta           
		cQuery += " SELECT COUNT(C5_XPRONUM) AS PROPOSTA, "
        cQuery += " C5_VEND1, "
        cQuery += " NOMEVEND, "
		cQuery += " CODGER, "
		cQuery += " NOMEGER, "
        cQuery += " C5_XNICHO, "
        cQuery += " AGRUPA, "
        cQuery += " SUM(VENDA) AS VENDA, "
        cQuery += " SUM(C6_UNSVEN) AS VENDA2UN, "
        cQuery += " SUM(ZZE_QUANT) AS ZZE_QUANT, "
        cQuery += " SUM(TRIMESTRE) AS TRIMESTRE   "    

		If MV_PAR12 == 2 //analitico
			cQuery += " ,C5_CLIENTE "
		EndIf

		cQuery += " FROM (                        "

		cQuery += " SELECT C5_XPRONUM , "
        cQuery += " C5_VEND1, "
        cQuery += " A3.A3_NOME NOMEVEND, "
        cQuery += " A3GER.A3_COD CODGER, "
        cQuery += " A3GER.A3_NOME NOMEGER, "
        cQuery += " C5_CLIENTE, "
        cQuery += " CASE WHEN B1_XMODELO IN ('000002','000003','000004','000005') THEN '1' WHEN B1_TIPO = 'PA' AND B1_DESC LIKE 'CONJUG%' THEN '1' WHEN B1_XMODELO IN ('000001','000021') THEN '2' WHEN B1_TIPO = 'PA' AND B1_DESC LIKE 'CABECE%' THEN '3' WHEN B1_XMODELO IN ('000006','000017','000019','000028','000029') THEN '4' WHEN B1_XMODELO IN ('000008','000009','000010','000011','000012','000018') THEN '5' WHEN B1_TIPO = 'PA' AND B1_GRUPO IN ('2343','2344','2345','2353','3530','3637','5020','5070','6644','6645') THEN '6' WHEN B1_XMODELO IN ('000014') THEN '7' WHEN B1_XMODELO IN ('000022','000023','000024','000025','000026','000027','000028','000033','000034','000035','000036','000037','000038','000039','000040','000041','000042','000043','000123','000124','000125','000126','000127','000128','000129','000130','000131','000132','000133','000134','000135','000136','000137','000138','000139','000140','000141','000142','000143','000145','000146','000148','001023','001024','001025','001026','001027','001028','001123','001124','001125','001126','001127','001128','001129','001130','001131','001144','001147') THEN '9' WHEN SUBSTR(B1_XMODELO,1,2)='24' THEN '9' END AS AGRUPA, "
/*
        cQuery += " CASE WHEN B1_XMODELO IN ('000002','000003','000004','000005')  "
        cQuery += "           THEN '1' "
        cQuery += "      WHEN B1_TIPO = 'PA' AND B1_DESC LIKE 'CONJUG%' "
        cQuery += "           THEN '1' "

        cQuery += " WHEN B1_XMODELO IN ('000001','000021') "
        cQuery += " THEN '2' "
        cQuery += " WHEN B1_TIPO = 'PA' AND B1_DESC LIKE 'CABECE%' "
        cQuery += " THEN '3' "
        cQuery += " WHEN B1_XMODELO IN ('000017','000028','000029') "//('000017'"+cModTrav+") "  //('000006','000017'"+cModTrav+") " 
        cQuery += " THEN '4' "
        cQuery += " WHEN B1_XMODELO IN ('000008','000009','000010','000011','000012','000018')  "
        cQuery += " THEN '5' "
        cQuery += " WHEN B1_TIPO = 'PA' AND B1_GRUPO IN ('2343','2344','2345','2353','3530','3637','5020','5070','6644','6645') "
        cQuery += " THEN '6' "
        cQuery += " WHEN B1_XMODELO IN ('000014') "
        cQuery += " THEN '7' "
        cQuery += " WHEN B1_XMODELO IN ('000022','000023','000024','000025','000026','000027','000028','000033','000034','000035','000036','000037','000038','000039','000040','000041','000042','000043','000123','000124','000125','000126','000127','000128','000129','000130','000131','000132','000133','000134','000135','000136','000137','000138','000139','000140','000141','000142','000143','000145','000146','000148','001023','001024','001025','001026','001027','001028','001123','001124','001125','001126','001127','001128','001129','001130','001131','001144','001147')  "
        cQuery += " THEN '9' "
        cQuery += " WHEN SUBSTR(B1_XMODELO,1,2)='24' "
        cQuery += " THEN '9'  "
        cQuery += " END AS AGRUPA, "
*/

        cQuery += " C5_XNICHO, "
        cQuery += " 0 AS VENDA, "
        cQuery += " 0 AS C6_UNSVEN, "
        cQuery += " 0 AS ZZE_QUANT, "
        cQuery += " C6_QTDVEN AS TRIMESTRE"
		cQuery += " FROM " + RetSQLName("SC5") + " C5  , " + RetSQLName("SB1") + " B1 , " + RetSQLName("SA3") + " A3 , " + RetSQLName("SA3") + " A3GER , " + RetSQLName("SZH") + " ZH, " + RetSQLName("SC6") + " C6 "
		//cQuery += " FROM " + RetSQLName("SC5") + " C5  , " + RetSQLName("SB1") + " B1 , " + RetSQLName("SA3") + " A3 , " + RetSQLName("SA3") + " A3GER , " + RetSQLName("SZH") + " ZH, " + RetSQLName("SC6") + " C6 ,V_MIX"+CEMPANT+"0 MIX "
		cQuery += " WHERE  C5.D_E_L_E_T_ = ' ' "
		cQuery += " AND C6.D_E_L_E_T_ = ' ' "
		cQuery += " AND B1.D_E_L_E_T_ = ' ' "
		cQuery += " AND A3.D_E_L_E_T_ = ' ' "
		cQuery += " AND A3GER.D_E_L_E_T_(+) = ' ' "
		cQuery += " AND ZH.D_E_L_E_T_ = ' ' "

		cQuery += "           AND C5_FILIAL          = '"+xFilial("SC5")+"'                                                     "
		cQuery += "           AND C6_FILIAL          = '"+xFilial("SC6")+"'                                                     "
		cQuery += "           AND B1_FILIAL          = '"+xFilial("SB1")+"'                                                     "
		cQuery += "           AND A3.A3_FILIAL       = '"+xFilial("SA3")+"'                                                     "
		cQuery += "           AND A3GER.A3_FILIAL(+) = '"+xFilial("SA3")+"'                                                     "
		cQuery += "           AND ZH_FILIAL          = '"+xFilial("SZH")+"'                                                     "

		cQuery += " AND C5_NUM = C6_NUM "
		cQuery += " AND C5_CLIENTE = C6_CLI "
		cQuery += " AND C5_LOJACLI = C6_LOJA "
		cQuery += " AND B1_COD = C6_PRODUTO "
		cQuery += " AND C5_CLIENTE = ZH_CLIENTE "
		cQuery += " AND C5_LOJACLI = ZH_LOJA "
		cQuery += " AND C5_XTPSEGM = ZH_SEGMENT "
		cQuery += " AND A3.A3_COD = C5_VEND1 "
		cQuery += " AND A3.A3_GEREN = A3GER.A3_COD(+) "
		cQuery += " AND C5_XTPSEGM IN ('1', '2', '5', '6') "
		cQuery += " AND C5_XOPER IN ('01', '14') "

		nDIAS 		:= FIRSTDAY(MV_PAR01)-1
		NDIASpE1 	:= NDIAS -90
		nDiasPer	:= FIRSTDAY(NDIASpE1)

		cQuery += " AND C5_EMISSAO      BETWEEN '"+DtoS(NDIASpER)+"' AND '"+DtoS(nDIAS)+"'                         "

		If MV_PAR11 == 2 //Liberado
			cQuery += "       AND C5_XDTLIB <> ' ' "                                                                              "
		ElseIf MV_PAR11 == 3 //Faturado
			cQuery += "       AND C5_NOTA <> ' '    "                                                                            "
		ElseIf MV_PAR11 == 4 //Acertado
			cQuery += "       AND C5_XDTFECH <> ' '  "                                                                           "
		End

		cQuery += "           AND A3GER.A3_COD(+) BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"'                                     "
		cQuery += "           AND C5_VEND1        BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"'                                     "
		cQuery += "           AND ZH_ITINER       BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"'                                     "
		cQuery += "           AND C5_XNICHO       BETWEEN '"+MV_PAR09+"' AND '"+MV_PAR10+"'                                     "
/*
		cQuery += " 		AND  C6_PRODUTO 		= COD AND C6_NUM = NUM AND C6_CLI = CLIENTE "
		cQuery += " 		AND EMISSAO 			BETWEEN '"+DtoS(NDIASpER)+"' AND '"+DtoS(nDIAS)+"'                         "
		cQuery += " 		AND NICHO 				BETWEEN '"+MV_PAR09+"' AND '"+MV_PAR10+"'                                     "
		cQuery += "  		AND OPER 				in ('01','04','05','10','11','14','15','16','20','21','19','26','27')  "
		cQuery += "  		AND TPSEGM 				IN ('2','1') "
*/

		cQuery += "  )
 
   		cQuery += " WHERE  AGRUPA IS NOT NULL "

		If MV_PAR12 == 1 //SINTÉTICO
			cQuery += " GROUP BY C5_VEND1,NOMEVEND,CODGER,NOMEGER,C5_XNICHO,AGRUPA							                "
		Else
			cQuery += " GROUP BY C5_VEND1,NOMEVEND,CODGER,NOMEGER,C5_XNICHO,AGRUPA, C5_CLIENTE                          "
		EndIf

	cQuery += "         UNION                                                                                               "
	
	//somatoria potencial
/*
	If MV_PAR12 == 1 //SINTÉTICO
		cQuery += "  SELECT proposta,C5_VEND1,  NOMEVEND,  CODGER,    NOMEGER,  C5_XNICHO, AGRUPA,     SUM(C6_QTDVEN) AS VENDA,SUM(C6_UNSVEN) AS VENDA2UN, SUM(ZZE_QUANT) AS ZZE_QUANT, 0 AS TRIMESTRE "
		cQuery += "    FROM (SELECT 0 as proposta,A3.A3_COD AS C5_VEND1,    A3.A3_NOME AS NOMEVEND,   A3GER.A3_COD AS CODGER,   A3GER.A3_NOME AS NOMEGER, ZZE_AGRUPA AS AGRUPA,     ZZE_NICHO AS C5_XNICHO,   0 AS C6_QTDVEN, 0 AS C6_UNSVEN,  ZZE_QUANT, 0 AS TRIMESTRE"
	Else //ANALÍTICO
		cQuery += "   SELECT proposta,C5_VEND1,  NOMEVEND, CODGER,    NOMEGER,  C5_XNICHO, AGRUPA,     SUM(C6_QTDVEN) AS VENDA,SUM(C6_UNSVEN) AS VENDA2UN, SUM(ZZE_QUANT) AS ZZE_QUANT, 0 AS TRIMESTRE , C5_CLIENTE "
		cQuery += "     FROM (SELECT 0 as proposta, A3.A3_COD AS C5_VEND1,    A3.A3_NOME AS NOMEVEND,  A3GER.A3_COD AS CODGER,   A3GER.A3_NOME AS NOMEGER, ZH_CLIENTE AS C5_CLIENTE, ZZE_AGRUPA AS AGRUPA,     ZZE_NICHO AS C5_XNICHO,   0 AS C6_QTDVEN,   0 AS C6_UNSVEN,   ZZE_QUANT, 0 AS TRIMESTRE "
	EndIf
	
	cQuery += "                   FROM " + RetSQLName("ZZE") + " ZZE,                                                       "
	cQuery += "                        " + RetSQLName("SZH") + " ZH,                                                        "
	cQuery += "                        " + RetSQLName("SA3") + " A3,                                                        "
	cQuery += "                        " + RetSQLName("SA3") + " A3GER,                                                     "
	cQuery += "                        " + RetSQLName("SA1") + " A1                                                         "
	cQuery += "                  WHERE ZZE.D_E_L_E_T_ = ' '                                                                 "
	cQuery += "                    AND ZH.D_E_L_E_T_ = ' '                                                                  "
	cQuery += "                    AND A1.D_E_L_E_T_ = ' '                                                                  "
	cQuery += "                    AND ZZE_FILIAL = '"+xFilial("ZZE")+"'                                                    "
	cQuery += "                    AND ZH_FILIAL = '"+xFilial("SZH")+"'                                                     "
	cQuery += "                    AND A1_FILIAL = '"+xFilial("SA1")+"'                                                     "
	cQuery += "                    AND A3.A3_FILIAL = '"+xFilial("SA3")+"'                                                  "
	cQuery += "                    AND A3GER.A3_FILIAL(+) = '"+xFilial("SA3")+"'                                            "
	cQuery += "                    AND ZZE_CODCLI = ZH_CLIENTE                                                              "
	cQuery += "                    AND A1_COD     = ZH_CLIENTE                                                              "
	cQuery += "                    AND A1_MSBLQL != '1'                                                                     "
	cQuery += "                    AND A3.D_E_L_E_T_ = ' '                                                                  "
	cQuery += "                    AND A3GER.D_E_L_E_T_(+) = ' '                                                            "
	cQuery += "                    AND A3.A3_COD = ZH_VEND                                                                  "
	cQuery += "                    AND A3.A3_GEREN = A3GER.A3_COD(+)                                                        "
	cQuery += "                    AND A3GER.A3_COD(+) BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"'                            "
	cQuery += "                    AND ZZE_NICHO       BETWEEN '"+MV_PAR09+"' AND '"+MV_PAR10+"'                            "
	cQuery += "                    AND ZH_VEND         BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"'                            "
    cQuery += "                    AND ZH_ITINER       BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"' )                                    "
                                                                     "

	If MV_PAR12 == 1 //SINTÉTICO
		cQuery += " GROUP BY PROPOSTA,C5_VEND1,NOMEVEND,CODGER,NOMEGER,C5_XNICHO,AGRUPA  							                "
		cQuery += " ORDER BY CODGER, C5_VEND1, C5_XNICHO, AGRUPA                                                            "
	Else
		cQuery += " GROUP BY PROPOSTA,C5_VEND1,NOMEVEND,CODGER,NOMEGER,C5_XNICHO,AGRUPA , C5_CLIENTE                              "
		cQuery += " ORDER BY CODGER, C5_VEND1, C5_CLIENTE, C5_XNICHO, AGRUPA                                                "
	EndIf

*/


	If MV_PAR12 == 1 //SINTÉTICO
		cQuery += "         SELECT proposta,C5_VEND1,  NOMEVEND,  CODGER,    NOMEGER,  C5_XNICHO, AGRUPA,     C6_QTDVEN AS VENDA, C6_UNSVEN AS VENDA2UN, ZZE_QUANT, 0 AS TRIMESTRE "
		cQuery += "           FROM (SELECT 0 as proposta,A3.A3_COD AS C5_VEND1,    A3.A3_NOME AS NOMEVEND,   A3GER.A3_COD AS CODGER,   A3GER.A3_NOME AS NOMEGER, ZZE_AGRUPA AS AGRUPA,     ZZE_NICHO AS C5_XNICHO,   0 AS C6_QTDVEN, 0 AS C6_UNSVEN, SUM(ZZE_QUANT) ZZE_QUANT, 0 AS TRIMESTRE"
	Else //ANALÍTICO
		cQuery += "         SELECT proposta,C5_VEND1,  NOMEVEND, CODGER,    NOMEGER, C5_XNICHO, AGRUPA,       C6_QTDVEN AS VENDA, C6_UNSVEN AS VENDA2UN, ZZE_QUANT, 0 AS TRIMESTRE, C5_CLIENTE  "
		cQuery += "           FROM (SELECT 0 as proposta, A3.A3_COD AS C5_VEND1,    A3.A3_NOME AS NOMEVEND,  A3GER.A3_COD AS CODGER,   A3GER.A3_NOME AS NOMEGER, ZH_CLIENTE AS C5_CLIENTE, ZZE_AGRUPA AS AGRUPA,     ZZE_NICHO AS C5_XNICHO,   0 AS C6_QTDVEN,   0 AS C6_UNSVEN,  SUM(ZZE_QUANT) ZZE_QUANT, 0 AS TRIMESTRE "
	EndIf
	cQuery += "                   FROM " + RetSQLName("ZZE") + " ZZE,                                                       "
	cQuery += "                        " + RetSQLName("SZH") + " ZH,                                                        "
	cQuery += "                        " + RetSQLName("SA3") + " A3,                                                        "
	cQuery += "                        " + RetSQLName("SA3") + " A3GER,                                                     "
	cQuery += "                        " + RetSQLName("SA1") + " A1                                                         "
	cQuery += "                  WHERE ZZE.D_E_L_E_T_ = ' '                                                                 "
	cQuery += "                    AND ZH.D_E_L_E_T_ = ' '                                                                  "
	cQuery += "                    AND A1.D_E_L_E_T_ = ' '                                                                  "
	cQuery += "                    AND ZZE_FILIAL = '"+xFilial("ZZE")+"'                                                    "
	cQuery += "                    AND ZH_FILIAL = '"+xFilial("SZH")+"'                                                     "
	cQuery += "                    AND A1_FILIAL = '"+xFilial("SA1")+"'                                                     "
	cQuery += "                    AND A3.A3_FILIAL = '"+xFilial("SA3")+"'                                                  "
	cQuery += "                    AND A3GER.A3_FILIAL(+) = '"+xFilial("SA3")+"'                                            "
	cQuery += "                    AND ZZE_CODCLI = ZH_CLIENTE                                                              "
	cQuery += "                    AND A1_COD     = ZH_CLIENTE                                                              "
	cQuery += "                    AND A1_MSBLQL != '1'                                                                     "
	cQuery += "                    AND A3.D_E_L_E_T_ = ' '                                                                  "
	cQuery += "                    AND A3GER.D_E_L_E_T_(+) = ' '                                                            "
	cQuery += "                    AND A3.A3_COD = ZH_VEND                                                                  "
	cQuery += "                    AND A3.A3_GEREN = A3GER.A3_COD(+)                                                        "
	cQuery += "                    AND A3GER.A3_COD(+) BETWEEN '"+MV_PAR03+"' AND '"+MV_PAR04+"'                            "
	cQuery += "                    AND ZZE_NICHO       BETWEEN '"+MV_PAR09+"' AND '"+MV_PAR10+"'                            "
	cQuery += "                    AND ZH_VEND         BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"'                            "
    cQuery += "                    AND ZH_ITINER       BETWEEN '"+MV_PAR07+"' AND '"+MV_PAR08+"'                                     "
	cQuery += "                  GROUP BY A3.A3_COD,                                                                        "
	cQuery += "                           A3.A3_NOME,                                                                       "
	If MV_PAR12 == 2 //ANALÍTICO
		cQuery += "                           ZH_CLIENTE,                                                                     "
	EndIf
	cQuery += "                           A3GER.A3_COD,                                                                     "
	cQuery += "                           A3GER.A3_NOME,                                                                    "
	cQuery += "                           ZZE_AGRUPA,                                                                       "
	cQuery += "                           ZZE_NICHO)                                                                        "
	
		cQuery += " ) "
		cQuery += " WHERE AGRUPA IS NOT NULL  

		If MV_PAR12 == 1 //SINTÉTICO
			cQuery += " GROUP BY C5_VEND1, NOMEVEND, C5_XNICHO, AGRUPA,CODGER, NOMEGER 							                "
			cQuery += " ORDER BY CODGER, C5_VEND1, C5_XNICHO, AGRUPA                                                            "
		Else
			cQuery += " GROUP BY C5_VEND1, NOMEVEND, C5_XNICHO, AGRUPA,CODGER, NOMEGER, C5_CLIENTE                              "
			cQuery += " ORDER BY CODGER, C5_VEND1, C5_CLIENTE, C5_XNICHO, AGRUPA                                                "
		EndIf


	cQuery := ChangeQuery(cQuery)

	memowrite("C:\ORTR787.SQL",cQuery)

	If Select("QRY") > 0
		dbSelectArea("QRY")
		QRY->(DbCloseArea())
	EndIf

	nLin := fImpCab(.T., oPrn)

	TcQuery cQuery Alias "QRY" New

	nLin += nEsp

	QRY->(dbGoTop())

	_cVend 		:= ""
	_cGer 		:= ""
	_cCliente 	:= ""

	nLin += nEsp

	While !QRY->(EOF())

		//		If cEmpAnt $ '24'
		//			_nVenda := QRY->VENDA2UN
		//		Else
		_nVenda := QRY->VENDA
		//		EndIf
		If MV_PAR12 == 1 //SINTÉTICO

			If QRY->CODGER <> _cGER
				If Len(aTotGer) > 0
					fPSemPed("",_cVend,_cNicho,SubsTr(_cAgrIn,1,Len(_cAgrIn)-1))
					oPrn:Say(nLin,0060,"Totais Gerente: " + _cGer + ' - ' + AllTrim(_cNomeGer), oFont2)
					nLin += nEsp+nEsp
					_cNicho := ""
					For nX := 1 to Len(aTotGer)
						oPrn:Say(nLin,0760,aTotGer[nX][1], oFont2) //Nicho
						For nY := 2 to Len(aTotGer[nX])
							oPrn:Say(nLin,1195,aTotGer[nX][nY][1], oFont2) //Agrupamento
							oPrn:Say(nLin,1480,AllTrim(Str(Round(aTotGer[nX][nY][2],2))), oFont2) //Qtd Venda
							oPrn:Say(nLin,1680,AllTrim(Str(Round(aTotGer[nX][nY][3],2))), oFont2) //Potencial
							oPrn:Say(nLin,1880,AllTrim(Str(Round(aTotGer[nX][nY][4],2))), oFont2) //trimestre
							oPrn:Say(nLin,2080,AllTrim(Str(Round(aTotGer[nX][nY][5],2))), oFont2) //proposta
							oPrn:Say(nLin,2270,IIF(aTotGer[nX][nY][3]>0,AllTrim(Str(Round(aTotGer[nX][nY][2]/aTotGer[nX][nY][3]*100,2)))+"%","0%"), oFont2) //Participação						
							nLin += nEsp
						Next nY
					Next nX
				EndIf
				aTotGer := {}
				nLin += nEsp
			EndIf

			If QRY->C5_VEND1 <> _cVend
				If !Empty(_cNicho)
					fPSemPed("",_cVend,_cNicho,SubsTr(_cAgrIn,1,Len(_cAgrIn)-1))
					_cAgrIn := ""
				EndIf
				oPrn:Say(nLin,0060,"Vendedor: "+QRY->C5_VEND1 + ' - ' + SubStr(QRY->NOMEVEND,1,20), oFont2)
				oPrn:Line(nLin  , 50, nLin  , oPrn:nHorzRes()-50 )
			ElseIf _cNicho <> QRY->C5_XNICHO
				If !Empty(_cNicho)
					fPSemPed("",_cVend,_cNicho,SubsTr(_cAgrIn,1,Len(_cAgrIn)-1))
					_cAgrIn := ""
				EndIf
			EndIf

			cQuery2 := "SELECT SUM(ZZE_QUANT) ZZE_QUANT                                    "
			cQuery2 += " FROM (SELECT ZZE_CODCLI, ZZE_NICHO, ZZE_AGRUPA, ZZE_QUANT         "
			cQuery2 += "         FROM "+RetSqlName("ZZE")+" ZZE, "+RetSqlName("SZH")+" ZH, "
			cQuery2 += "        "+RetSqlName("SA1")+" A1                                   "
			cQuery2 += "        WHERE ZZE.D_E_L_E_T_ = ' '                                 "
			cQuery2 += "          AND ZH.D_E_L_E_T_ = ' '                                  "
			cQuery2 += "          AND A1.D_E_L_E_T_ = ' '                                  "
			cQuery2 += "          AND ZZE_FILIAL = '"+xFilial("ZZE")+"'                    "
			cQuery2 += "          AND ZH_FILIAL = '"+xFilial("SZH")+"'                     "
			cQuery2 += "          AND A1_FILIAL = '"+xFilial("SA1")+"'                     "
			cQuery2 += "          AND ZZE_CODCLI = ZH_CLIENTE                              "
			cQuery2 += "          AND A1_COD     = ZH_CLIENTE                              "
			cQuery2 += "          AND A1_MSBLQL != '1'                                     "
			cQuery2 += "          AND ZZE_AGRUPA = '"+QRY->AGRUPA+"'                       "
			cQuery2 += "          AND ZZE_NICHO = '"+QRY->C5_XNICHO+"'                     "
			cQuery2 += "          AND ZH_VEND = '"+QRY->C5_VEND1+"'                        "
			cQuery2 += "        GROUP BY ZZE_CODCLI, ZZE_NICHO, ZZE_AGRUPA, ZZE_QUANT)     "

			cQuery2 := ChangeQuery(cQuery2)

			memowrite("C:\ORTR787_2.SQL",cQuery2)

			If Select("QRY2") > 0
				dbSelectArea("QRY2")
				QRY2->(DbCloseArea())
			EndIf

			TcQuery cQuery2 Alias "QRY2" New

			If QRY2->(EOF())
				_nPoten := 0
			Else
				_nPoten := QRY2->ZZE_QUANT
			EndIf

			_cNicho := IIF(!Empty(QRY->C5_XNICHO),QRY->C5_XNICHO,"     ")
			_cDescN := IIF(!Empty(QRY->C5_XNICHO)," - " + AllTrim(Posicione("SZ0",1,xFilial("SZ0")+'CM'+QRY->C5_XNICHO,"Z0_DESCRI"))," Sem classificação")

			If !(AllTrim("'" + QRY->AGRUPA + "',") $ _cAgrIn)
				_cAgrIn += "'" + QRY->AGRUPA + "'," 
			EndIf
			_cAgrupa := fNomeAgr(QRY->AGRUPA)

			oPrn:Say(nLin,0760,AllTrim(_cNicho + _cDescN)											, oFont2)
			oPrn:Say(nLin,1195,_cAgrupa																, oFont2)
			oPrn:Say(nLin,1480,AllTrim(Str(Round(_nVenda,2)))										, oFont2)
			oPrn:Say(nLin,1680,AllTrim(Str(Round(_nPoten,2)))										, oFont2)
			oPrn:Say(nLin,1880,AllTrim(Str(Round(QRY->TRIMESTRE,2)))								, oFont2)
			oPrn:Say(nLin,2080,AllTrim(Str(Round(QRY->PROPOSTA,2)))									, oFont2)
			oPrn:Say(nLin,2270,IIf(_nPoten > 0, AllTrim(Str(Round(_nVenda/_nPoten*100,2)))+"%","0%"), oFont2)

			/*********** TOTAIS DO GERENTE **********/
			nPosNic := aScan(aTotGer,{|x| x[1] == AllTrim(_cNicho + _cDescN) })		
			If nPosNic == 0
				aAdd(aTotGer,{AllTrim(_cNicho + _cDescN)})
				aAdd(aTotGer[aScan(aTotGer,{|x| x[1] == AllTrim(_cNicho + _cDescN) })],{_cAgrupa,_nVenda,_nPoten,QRY->TRIMESTRE,QRY->PROPOSTA})
			Else
				nPosAgr := 0
				For nX := 2 to Len(aTotGer[nPosNic])
					If aScan(aTotGer[nPosNic][nX],_cAgrupa) > 0
						nPosAgr := nX
						Exit
					EndIf
				Next nX
				If nPosAgr == 0
					aAdd(aTotGer[nPosNic],{_cAgrupa,_nVenda,_nPoten,QRY->TRIMESTRE,QRY->PROPOSTA})
				Else
					aTotGer[nPosNic][nPosAgr][2]:= aTotGer[nPosNic][nPosAgr][2]+_nVenda
					aTotGer[nPosNic][nPosAgr][3]:= aTotGer[nPosNic][nPosAgr][3]+_nPoten
					aTotGer[nPosNic][nPosAgr][4]:= aTotGer[nPosNic][nPosAgr][4]+QRY->TRIMESTRE
					aTotGer[nPosNic][nPosAgr][5]:= aTotGer[nPosNic][nPosAgr][5]+QRY->PROPOSTA
				EndIf
			EndIf
			/******* TOTAIS GERAIS *********/
			nPosNic := aScan(aTGeral,{|x| x[1] == AllTrim(_cNicho + _cDescN) })		
			If nPosNic == 0
				aAdd(aTGeral,{AllTrim(_cNicho + _cDescN)})
				aAdd(aTGeral[aScan(aTGeral,{|x| x[1] == AllTrim(_cNicho + _cDescN) })],{_cAgrupa,_nVenda,_nPoten,qry->trimestre,QRY->PROPOSTA})
			Else
				nPosAgr := 0
				For nX := 2 to Len(aTGeral[nPosNic])
					If aScan(aTGeral[nPosNic][nX],_cAgrupa) > 0
						nPosAgr := nX
						Exit
					EndIf
				Next nPosAgr
				If nPosAgr == 0
					aAdd(aTGeral[nPosNic],{_cAgrupa,_nVenda,_nPoten,qry->trimestre,QRY->PROPOSTA})
				Else
					aTGeral[nPosNic][nPosAgr][2]:= aTGeral[nPosNic][nPosAgr][2]+_nVenda
					aTGeral[nPosNic][nPosAgr][3]:= aTGeral[nPosNic][nPosAgr][3]+_nPoten
					aTGeral[nPosNic][nPosAgr][4]:= aTGeral[nPosNic][nPosAgr][4]+QRY->TRIMESTRE
					aTGeral[nPosNic][nPosAgr][5]:= aTGeral[nPosNic][nPosAgr][5]+QRY->PROPOSTA

				EndIf
			EndIf

			_cVend 		:= QRY->C5_VEND1
			_cGer 		:= QRY->CODGER
			_cNomeGer 	:= QRY->NOMEGER
			_cAgrupa 	:= fNomeAgr(QRY->AGRUPA)
			nLin 		+= nEsp+nEsp

			//SSI-115540 - Vagner Almeida - 03/05/2021 - Inicio
			aAdd( aLinha, { QRY->CODGER		,; 
			                QRY->NOMEGER	,; 
			                QRY->C5_VEND1	,; 
			                QRY->NOMEVEND	,;
							"",;
							"",;
			                _cNicho + _cDescN,; 
			                _cAgrupa,;
							AllTrim(Str(Round(_nVenda,2))),;
							AllTrim(Str(qry->trimestre)),;
							AllTrim(Str(QRY->PROPOSTA)),;
							AllTrim(Str(Round(_nPoten,2))),;
							IIf(_nPoten > 0, AllTrim(Str(Round(_nVenda/_nPoten*100,2)))+"%","0%");
		                   })
			//SSI-115540 - Vagner Almeida - 03/05/2021 - Inicio

		Else //ANALÍTICO
			If QRY->CODGER <> _cGER
				If Len(aTotGer) > 0
					fPSemPed(_cCliente,_cVend,_cNicho,SubsTr(_cAgrIn,1,Len(_cAgrIn)-1))
					oPrn:Say(nLin,0060,"Totais Gerente: " + _cGER + ' - ' + _cNomeGer, oFont2)
					nLin += nEsp+nEsp
					_cNicho := ""
					_cDescN := ""
					For nX := 1 to Len(aTotGer)
						oPrn:Say(nLin,0760,aTotGer[nX][1], oFont2) //Nicho
						For nY := 2 to Len(aTotGer[nX])
							oPrn:Say(nLin,1195,aTotGer[nX][nY][1], oFont2) //Agrupamento
							oPrn:Say(nLin,1480,AllTrim(Str(Round(aTotGer[nX][nY][2],2))), oFont2) //Qtd Venda
							oPrn:Say(nLin,1680,AllTrim(Str(Round(aTotGer[nX][nY][3],2))), oFont2) //Potencial
							oPrn:Say(nLin,1880,AllTrim(Str(Round(aTotGer[nX][nY][4],2))), oFont2) //trimestre
							oPrn:Say(nLin,2080,AllTrim(Str(Round(aTotGer[nX][nY][5],2))), oFont2) //PROPOSTA
							oPrn:Say(nLin,2270,IIF(aTotGer[nX][nY][3]>0,AllTrim(Str(Round(aTotGer[nX][nY][2]/aTotGer[nX][nY][3]*100,2)))+"%","0%"), oFont2) //Participação						
							nLin += nEsp+nEsp
						Next nY
					Next nX
				EndIf
				aTotGer := {}
				nLin += nEsp
			EndIf

			If QRY->C5_VEND1 <> _cVend
				oPrn:Say(nLin,0060,"Vendedor: "+QRY->C5_VEND1 + ' - ' + SubStr(QRY->NOMEVEND,1,25), oFont2)
				oPrn:Line(nLin  , 50, nLin  , oPrn:nHorzRes()-50 )
			EndIf
			nLin += nEsp
			If QRY->C5_CLIENTE <> _cCliente
				If !Empty(_cNicho)
					fPSemPed(_cCliente,_cVend,_cNicho,SubsTr(_cAgrIn,1,Len(_cAgrIn)-1))
				EndIf
				oPrn:Say(nLin,0060,"Cliente: "+QRY->C5_CLIENTE + ' - ' + SubStr(Posicione("SA1",1,xFilial("SA1")+QRY->C5_CLIENTE+"01","A1_NOME"),1,25), oFont2)
				oPrn:Line(nLin  , 50, nLin  , oPrn:nHorzRes()-50 )
			EndIf

			cQuery2 := "SELECT SUM(ZZE_QUANT) ZZE_QUANT                                    "
			cQuery2 += " FROM (SELECT ZZE_CODCLI, ZZE_NICHO, ZZE_AGRUPA, ZZE_QUANT         "
			cQuery2 += "         FROM "+RetSqlName("ZZE")+" ZZE, "+RetSqlName("SZH")+" ZH  "
			cQuery2 += "        WHERE ZZE.D_E_L_E_T_ = ' '                                 "
			cQuery2 += "          AND ZH.D_E_L_E_T_ = ' '                                  "
			cQuery2 += "          AND ZZE_FILIAL = '"+xFilial("ZZE")+"'                    "
			cQuery2 += "          AND ZH_FILIAL = '"+xFilial("SZH")+"'                     "
			cQuery2 += "          AND ZZE_CODCLI = '"+QRY->C5_CLIENTE+"'                   "
			cQuery2 += "          AND ZZE_CODCLI = ZH_CLIENTE                              "
			cQuery2 += "          AND ZZE_AGRUPA = '"+QRY->AGRUPA+"'                       "
			cQuery2 += "          AND ZZE_NICHO = '"+QRY->C5_XNICHO+"'                     "
			cQuery2 += "          AND ZH_VEND = '"+QRY->C5_VEND1+"'                        "
			cQuery2 += "        GROUP BY ZZE_CODCLI, ZZE_NICHO, ZZE_AGRUPA, ZZE_QUANT)     "

			cQuery2 := ChangeQuery(cQuery2)

			memowrite("C:\ORTR787_2.SQL",cQuery2)

			If Select("QRY2") > 0
				dbSelectArea("QRY2")
				QRY2->(DbCloseArea())
			EndIf

			TcQuery cQuery2 Alias "QRY2" New

			If QRY2->(EOF())
				_nPoten := 0
			Else
				_nPoten := QRY2->ZZE_QUANT
			EndIf

			//_cNicho := IIF(!Empty(QRY->C5_XNICHO),QRY->C5_XNICHO + " - " + AllTrim(Posicione("SZ0",1,xFilial("SZ0")+'CM'+QRY->C5_XNICHO,"Z0_DESCRI"))," Sem classificação")
			_cNicho := IIF(!Empty(QRY->C5_XNICHO),QRY->C5_XNICHO,"     ")
			_cDescN := IIF(!Empty(QRY->C5_XNICHO)," - " + AllTrim(Posicione("SZ0",1,xFilial("SZ0")+'CM'+QRY->C5_XNICHO,"Z0_DESCRI"))," Sem classificação")

			If !(AllTrim("'" + QRY->AGRUPA + "',") $ _cAgrIn)
				_cAgrIn += "'" + QRY->AGRUPA + "'," 
			EndIf
			_cAgrupa := fNomeAgr(QRY->AGRUPA)
			oPrn:Say(nLin,0760,AllTrim(_cNicho + _cDescN)											, oFont2)
			oPrn:Say(nLin,1195,_cAgrupa																, oFont2)
			oPrn:Say(nLin,1480,AllTrim(Str(Round(_nVenda,2)))										, oFont2)
			oPrn:Say(nLin,1680,AllTrim(Str(Round(_nPoten,2)))										, oFont2)
			oPrn:Say(nLin,1880,AllTrim(Str(Round(QRY->TRIMESTRE,2)))								, oFont2)
			oPrn:Say(nLin,2080,AllTrim(Str(Round(QRY->PROPOSTA,2)))									, oFont2)
			oPrn:Say(nLin,2270,IIf(_nPoten > 0, AllTrim(Str(Round(_nVenda/_nPoten*100,2)))+"%","0%"), oFont2)

			/*********** TOTAIS DO GERENTE **********/
			nPosNic := aScan(aTotGer,{|x| x[1] == AllTrim(_cNicho + _cDescN) })		
			If nPosNic == 0
				aAdd(aTotGer,{AllTrim(_cNicho + _cDescN)})
				aAdd(aTotGer[aScan(aTotGer,{|x| x[1] == AllTrim(_cNicho + _cDescN) })],{_cAgrupa,_nVenda,_nPoten,QRY->TRIMESTRE,QRY->PROPOSTA})
				/******* TOTAIS GERAIS *********/
				nPosNic := aScan(aTGeral,{|x| x[1] == AllTrim(_cNicho + _cDescN) })		
				If nPosNic == 0
					aAdd(aTGeral,{AllTrim(_cNicho + _cDescN)})
					aAdd(aTGeral[aScan(aTGeral,{|x| x[1] == AllTrim(_cNicho + _cDescN) })],{_cAgrupa,_nVenda,_nPoten,QRY->TRIMESTRE,QRY->PROPOSTA})
				Else
					nPosAgr := 0
					For nX := 2 to Len(aTGeral[nPosNic])
						If aScan(aTGeral[nPosNic][nX],_cAgrupa) > 0
							nPosAgr := nX
							Exit
						EndIf
					Next nPosAgr
					If nPosAgr == 0
						aAdd(aTGeral[nPosNic],{_cAgrupa,_nVenda,_nPoten,QRY->TRIMESTRE,QRY->PROPOSTA})
					Else
						aTGeral[nPosNic][nPosAgr][2]:= aTGeral[nPosNic][nPosAgr][2]+_nVenda
						aTGeral[nPosNic][nPosAgr][3]:= aTGeral[nPosNic][nPosAgr][3]+_nPoten
						aTGeral[nPosNic][nPosAgr][4]:= aTGeral[nPosNic][nPosAgr][4]+QRY->TRIMESTRE
						aTGeral[nPosNic][nPosAgr][5]:= aTGeral[nPosNic][nPosAgr][5]+QRY->PROPOSTA

					EndIf
				EndIf

			Else
				nPosAgr := 0
				For nX := 2 to Len(aTotGer[nPosNic])
					If aScan(aTotGer[nPosNic][nX],_cAgrupa) > 0
						nPosAgr := nX
						Exit
					EndIf
				Next nPosAgr
				If nPosAgr == 0
					aAdd(aTotGer[nPosNic],{_cAgrupa,_nVenda,_nPoten,QRY->TRIMESTRE,QRY->PROPOSTA})
				Else
					aTotGer[nPosNic][nPosAgr][2]:= aTotGer[nPosNic][nPosAgr][2]+_nVenda
					aTotGer[nPosNic][nPosAgr][3]:= aTotGer[nPosNic][nPosAgr][3]+_nPoten
					aTotGer[nPosNic][nPosAgr][4]:= aTotGer[nPosNic][nPosAgr][4]+QRY->TRIMESTRE
					aTotGer[nPosNic][nPosAgr][5]:= aTotGer[nPosNic][nPosAgr][5]+QRY->PROPOSTA

				EndIf

				/******* TOTAIS GERAIS *********/
				nPosNic := aScan(aTGeral,{|x| x[1] == AllTrim(_cNicho + _cDescN) })		
				If nPosNic == 0
					aAdd(aTGeral,{AllTrim(_cNicho + _cDescN)})
					aAdd(aTGeral[aScan(aTGeral,{|x| x[1] == AllTrim(_cNicho + _cDescN) })],{_cAgrupa,_nVenda,_nPoten,qry->trimestre,QRY->PROPOSTA})
				Else
					nPosAgr := 0
					For nX := 2 to Len(aTGeral[nPosNic])
						If aScan(aTGeral[nPosNic][nX],_cAgrupa) > 0
							nPosAgr := nX
							Exit
						EndIf
					Next nPosAgr
					If nPosAgr == 0
						aAdd(aTGeral[nPosNic],{_cAgrupa,_nVenda,_nPoten,qry->trimestre,QRY->PROPOSTA})
					Else
						aTGeral[nPosNic][nPosAgr][2]:= aTGeral[nPosNic][nPosAgr][2]+_nVenda
						aTGeral[nPosNic][nPosAgr][3]:= aTGeral[nPosNic][nPosAgr][3]+_nPoten
						aTGeral[nPosNic][nPosAgr][4]:= aTGeral[nPosNic][nPosAgr][4]+QRY->TRIMESTRE
						aTGeral[nPosNic][nPosAgr][5]:= aTGeral[nPosNic][nPosAgr][5]+QRY->PROPOSTA

					EndIf
				EndIf

			EndIf
			_cVend 		:= QRY->C5_VEND1
			_cGer 		:= QRY->CODGER
			_cNomeGer 	:= QRY->NOMEGER
			_cCliente 	:= QRY->C5_CLIENTE
			nLin 		+= nEsp+nEsp

			//SSI-115540 - Vagner Almeida - 03/05/2021 - Inicio
			aAdd( aLinha, { QRY->CODGER,; 
			                QRY->NOMEGER,; 
			                QRY->C5_VEND1,; 
			                QRY->NOMEVEND,;
							QRY->C5_CLIENTE,;
							Posicione("SA1",1,xFilial("SA1")+QRY->C5_CLIENTE+"01","A1_NOME"),;
			                _cNicho + _cDescN,; 
			                _cAgrupa,;
							AllTrim(Str(Round(_nVenda,2))),;
							AllTrim(Str(Round(_nPoten,2))),;
							AllTrim(Str(qry->trimestre)) ,;
							AllTrim(Str(QRY->PROPOSTA))	 ,;
							IIf(_nPoten > 0, AllTrim(Str(Round(_nVenda/_nPoten*100,2)))+"%","0%");
		                   })
			//SSI-115540 - Vagner Almeida - 03/05/2021 - Inicio

		Endif

		QRY->(DbSkip())
		If nLin > 3200
			nLin := fImpCab(.F.,oPrn)
		EndIf
	End
	oPrn:Line(nLin  , 50, nLin  , oPrn:nHorzRes()-50 )
	nLin += nEsp
	oPrn:Say(nLin,0060,"Totais Gerente: " + _cGer+ ' - ' + AllTrim(Posicione("SA3",1,xFilial("SA3")+_cGer,"A3_NOME")), oFont2)
	nLin += nEsp
	oPrn:Line(nLin  , 50, nLin  , oPrn:nHorzRes()-50 )	
	//IMPRIME TOTAL GERENTE FINAL
	aSort(aTotGer, , , { | x,y | x[1] < y[1] } )
	For nX := 1 to Len(aTotGer)
		oPrn:Say(nLin,0760,aTotGer[nX][1], oFont2) //Nicho
		If nLin > 3200
			nLin := fImpCab(.F.,oPrn)
		EndIf
		For nY := 2 to Len(aTotGer[nX])
			oPrn:Say(nLin,1195,aTotGer[nX][nY][1], oFont2) //Agrupamento
			oPrn:Say(nLin,1480,AllTrim(Str(Round(aTotGer[nX][nY][2],2))), oFont2) //Qtd Venda
			oPrn:Say(nLin,1680,AllTrim(Str(Round(aTotGer[nX][nY][3],2))), oFont2) //Potencial
			oPrn:Say(nLin,1880,AllTrim(Str(Round(aTotGer[nX][nY][4],2))), oFont2) //trimestre
			oPrn:Say(nLin,2080,AllTrim(Str(Round(aTotGer[nX][nY][5],2))), oFont2) //PROPOSTA
			oPrn:Say(nLin,2270,IIF(aTotGer[nX][nY][3]>0,AllTrim(Str(Round(aTotGer[nX][nY][2]/aTotGer[nX][nY][3]*100,2)))+"%","0%"), oFont2) //Participação						
			nLin += nEsp+nEsp
			If nLin > 3200
				nLin := fImpCab(.F.,oPrn)
			EndIf
		Next nY
	Next nX
	oPrn:Line(nLin  , 50, nLin  , oPrn:nHorzRes()-50 )
	nLin += nEsp
	//IMPRIME TOTAL UNIDADE
	oPrn:Say(nLin,0060,"Total Geral Unidade C-"+cEmpAnt+" - " + cNomFil , oFont2)
	nLin += nEsp
	oPrn:Line(nLin  , 50, nLin  , oPrn:nHorzRes()-50 )
	aSort(aTGeral, , , { | x,y | x[1] < y[1] } )
	For nX := 1 to Len(aTGeral)
		If nLin > 3200
			nLin := fImpCab(.F.,oPrn)
		EndIf
		oPrn:Say(nLin,0760,aTGeral[nX][1], oFont2) //Nicho
		For nY := 2 to Len(aTGeral[nX])
			If nLin > 3200
				nLin := fImpCab(.F.,oPrn)
			EndIf
			oPrn:Say(nLin,1195,aTGeral[nX][nY][1], oFont2) //Agrupamento
			
			oPrn:Say(nLin,1480,AllTrim(Transform(aTGeral[nX][nY][2],"@E 9,999,999")), oFont2) //Qtd Venda
			//oPrn:Say(nLin,1480,AllTrim(Str(Round(aTGeral[nX][nY][2],2))), oFont2) //Qtd Venda
			oPrn:Say(nLin,1680,AllTrim(Str(Round(aTGeral[nX][nY][3],2))), oFont2) //Potencial
			oPrn:Say(nLin,1880,AllTrim(Str(Round(aTGeral[nX][nY][4],2))), oFont2) //TRIMESTRE
			oPrn:Say(nLin,2080,AllTrim(Str(Round(aTGeral[nX][nY][5],2))), oFont2) //PROPOSTA
			oPrn:Say(nLin,2270,IIF(aTGeral[nX][nY][3]>0,AllTrim(Str(Round(aTGeral[nX][nY][2]/aTGeral[nX][nY][3]*100,2)))+"%","0%"), oFont2) //Participação						
			nLin += nEsp+nEsp
		Next nY
	Next nX
	oPrn:Line(nLin  , 50, nLin  , oPrn:nHorzRes()-50 )
	
	If MV_PAR13 = 2
		fImpSCad()
	EndIf
	
	QRY->(DbCloseArea())
	//QRY2->(DbCloseArea())

	//SSI-115540 - Vagner Almeida - 03/05/2021 - Início
	If MV_PAR14 == 2
		GeraCSV( aLinha )
	EndIf
	//SSI-115540 - Vagner Almeida - 03/05/2021 - Início

Return()

/*********************************************/
Static Function fImpCab(lPrimeira, oPrn)
/*********************************************/

	nPag	+= 1
	nCol	:= 0
	cCol 	:= Space(0)

	If !lPrimeira
		oPrn:EndPage()
	EndIf
	oPrn:StartPage()

	//oPrn:Box ( [ nRow], [ nCol], [ nBottom], [ nRight] )
	oPrn:Box( 50, 50, 200, oPrn:nHorzRes()-55 )
	oPrn:Box( 49, 49, 199, oPrn:nHorzRes()-54 )

	// Lado Esquerdo
	oPrn:Say ( 085, 95, "Hora: " 	+ cHora + " - (" 			+ nomeprog + ")"    , oFontM)
	oPrn:Say ( 125, 95, "Empresa: " + cEmpAnt + " / Filial: " 	+ cNomFil			, oFontM)

	// Centro
	oPrn:Say ( 110 , 830, Upper(ctitulo), oFontM)

	// Lado Direito
	nTam := 		oPrn:GetTextWidth ( 	"Emissão:" 	+ Dtos(Date())		, oFontM ) + 165
	oPrn:Say ( 085, oPrn:nHorzRes()-nTam, 	"Folha: " 	+ AllTrim(Str(nPag)), oFontM)
	oPrn:Say ( 125, oPrn:nHorzRes()-nTam, 	"Emissão:" 	+ DtoC(Date())		, oFontM)

	nLin	:= 210

	If nVez = 1
		oPrn:Say ( nLin, 060, cDesc1  , oFont2)
		nLin += nEsp
		nVez++
	EndIf

	If MV_PAR11 = 1
		oPrn:Say ( nLin, 060, "Status dos Pedidos : GERAL " 	, oFont2)
	Elseif MV_PAR11 = 2
		oPrn:Say ( nLin, 060, "Status dos Pedidos : LIBERADOS " , oFont2)
	Elseif MV_PAR11 = 3
		oPrn:Say ( nLin, 060, "Status dos Pedidos : FATURADO " 	, oFont2)
	Elseif MV_PAR11 = 4
		oPrn:Say ( nLin, 060, "Status dos Pedidos : ACERTADO " 	, oFont2)
	Endif

	nLin += nEsp

	oPrn:Say ( nLin, 060, 			"Período: "	+DtoC(MV_PAR01)+" ate "+DtoC(MV_PAR02)	, oFont2)
	//oPrn:Say ( nLin, 060, Space(50)+"Gerente: "	+iif(Empty(MV_PAR03),'<branco>',MV_PAR07)+" ate "+MV_PAR04, oFont2)
	//oPrn:Say ( nLin, 060, Space(95)+"Vendedor: "+iif(Empty(MV_PAR05),'<branco>',MV_PAR07)+" ate "+MV_PAR06, oFont2)
	oPrn:Say ( nLin, 060, Space(50)+"Gerente: "	+iif(Empty(MV_PAR03),'<branco>',MV_PAR03)+" ate "+MV_PAR04				, oFont2)
	oPrn:Say ( nLin, 060, Space(95)+"Vendedor: "+iif(Empty(MV_PAR05),'<branco>',MV_PAR05)+" ate "+MV_PAR06				, oFont2)

	nLin += nEsp
	_ctxtcanal := ""
	If !Empty(MV_PAR09)
		_ctxtcanal += Alltrim(MV_PAR09)+" - "+AllTrim(Posicione("SZ0",1,xFilial("SZ0")+'CM'+MV_PAR09,"Z0_DESCRI")) + " até "
	Else
		_ctxtcanal += '<branco> ate '
	EndIf
	If SubStr(MV_PAR10,1,1) = '0' 
		_ctxtcanal += Alltrim(MV_PAR10)+" - "+AllTrim(Posicione("SZ0",1,xFilial("SZ0")+'CM'+MV_PAR10,"Z0_DESCRI"))
	Else
		_ctxtcanal += Alltrim(MV_PAR10)
	EndIf
	oPrn:Say ( nLin, 060, "Roteiro: "+iif(Empty(MV_PAR07),'<branco>',MV_PAR07)+" ate "+MV_PAR08, oFont2)
	oPrn:Say ( nLin, 060, Space(50)+"Canal: "+ _ctxtcanal, oFont2)

	If MV_PAR12 == 1
		oPrn:Say ( nLin, 060, Space(115) + "Tipo: Sintético", oFont2)
	Else
		oPrn:Say ( nLin, 060, Space(115) + "Tipo: Analítico", oFont2)
	Endif
	nLin += nEsp
	oPrn:Line(nLin  , 50, nLin  , oPrn:nHorzRes()-50 )
	oPrn:Line(nLin+2, 50, nLin+2, oPrn:nHorzRes()-50 )
	oPrn:Line(nLin+4, 50, nLin+4, oPrn:nHorzRes()-50 )
	nLin += 15
	oPrn:Say(nLin,0760,"Canal"			, oFont2)
	oPrn:Say(nLin,1195,"Tipo"			, oFont2)
	oPrn:Say(nLin,1465,"Qtd em Peças"	, oFont2)
	oPrn:Say(nLin,1665,"Qtd Potencial"	, oFont2)
	oPrn:Say(nLin,1865,"Trimestre"		, oFont2)
	oPrn:Say(nLin,2065,"Proposta"		, oFont2)
	oPrn:Say(nLin,2265,"% Cumprido"		, oFont2)

	x := 0
	If !lPrimeira
		oPrn:Line(nLin  , 50, nLin  , oPrn:nHorzRes()-50 )
		nLin += nEsp+nEsp
		oPrn:Line(nLin  , 50, nLin  , oPrn:nHorzRes()-50 )
	EndIf
Return(nLin)

/***************************/
Static Function ValidPerg()
/***************************/

	Local aAreaAtu := GetArea()
	Local aRegs    := {}

	Aadd(aRegs,{cPerg,"01","Data de:              ","","","MV_CH1","D",8,0,0,"G","","MV_PAR01","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	Aadd(aRegs,{cPerg,"02","Data até:             ","","","MV_CH2","D",8,0,0,"G","","MV_PAR02","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	Aadd(aRegs,{cPerg,"03","Gerente de:           ","","","MV_CH3","C",6,0,0,"G","","MV_PAR03","","","","","","","","","","","","","","","","","","","","","","","","","SA3",""})
	Aadd(aRegs,{cPerg,"04","Gerente até:          ","","","MV_CH4","C",6,0,0,"G","","MV_PAR04","","","","","","","","","","","","","","","","","","","","","","","","","SA3",""})
	Aadd(aRegs,{cPerg,"05","Vendedor de:          ","","","MV_CH5","C",6,0,0,"G","","MV_PAR05","","","","","","","","","","","","","","","","","","","","","","","","","SA3",""})
	Aadd(aRegs,{cPerg,"06","Vendedor até:         ","","","MV_CH6","C",6,0,0,"G","","MV_PAR06","","","","","","","","","","","","","","","","","","","","","","","","","SA3",""})
	Aadd(aRegs,{cPerg,"07","Roteiro de:    	      ","","","MV_CH7","C",1,0,0,"G","","MV_PAR07","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	Aadd(aRegs,{cPerg,"08","Roteiro até:   	      ","","","MV_CH8","C",1,0,0,"G","","MV_PAR08","","","","","","","","","","","","","","","","","","","","","","","","","","",""})	
	Aadd(aRegs,{cPerg,"09","Canal de:             ","","","MV_CH9","C",5,0,0,"G","","MV_PAR09","","","","","","","","","","","","","","","","","","","","","","","","","SZ0CM",""})
	Aadd(aRegs,{cPerg,"10","Canal até:            ","","","MV_CHA","C",5,0,0,"G","","MV_PAR10","","","","","","","","","","","","","","","","","","","","","","","","","SZ0CM",""})
	Aadd(aRegs,{cPerg,"11","Tipo de Pedido:       ","","","MV_CHB","N",1,0,0,"C","","MV_PAR11","Digitado","","","","","Liberado","","","","","Faturado","","","","","Acertado","","","","","","","","","",""})
	Aadd(aRegs,{cPerg,"12","Imprime Analítico?    ","","","MV_CHC","N",1,0,0,"C","","MV_PAR12","Nao","","","","","Sim","","","","","","","","","","","","","","","","","","","",""})	
	Aadd(aRegs,{cPerg,"13","Imprime sem cadastro? ","","","MV_CHD","N",1,0,0,"C","","MV_PAR13","Nao","","","","","Sim","","","","","","","","","","","","","","","","","","","",""})
	//SSI-115540 - Vagner Almeida - 29/04/2021 - Inicio
	Aadd(aRegs,{cPerg,"14","Gerar Arquivo CSV?    ","","","MV_CHE","N",1,0,0,"C","","MV_PAR14","Nao","","","","","Sim","","","","","","","","","","","","","","","","","","","",""})
	//SSI-115540 - Vagner Almeida - 29/04/2021 - Inicio

	//Cria Pergunta
	cPerg := U_AjustaSx1(cPerg,aRegs)

	RestArea( aAreaAtu )

Return(.T.)

Static Function fPSemPed(_cCliente,_cVend,_cNicho,_cAgrIn)

	local nX

	If MV_PAR12 == 1 //SINTÉTICO
		cQuery3 := "SELECT ZZE_AGRUPA, SUM(ZZE_QUANT) ZZE_QUANT                        "
		cQuery3 += " FROM (SELECT ZZE_CODCLI, ZZE_NICHO, ZZE_AGRUPA, ZZE_QUANT         "
		cQuery3 += "         FROM "+RetSqlName("ZZE")+" ZZE, "+RetSqlName("SZH")+" ZH  "
		cQuery3 += "        WHERE ZZE.D_E_L_E_T_ = ' '                                 "
		cQuery3 += "          AND ZH.D_E_L_E_T_ = ' '                                  "
		cQuery3 += "          AND ZZE_FILIAL = '  '                                    "
		cQuery3 += "          AND ZH_FILIAL = ' '                                      "
		cQuery3 += "          AND ZZE_CODCLI = ZH_CLIENTE                              "
		cQuery3 += "          AND ZZE_AGRUPA NOT IN ("+_cAgrIn+")                      "
		cQuery3 += "          AND ZZE_NICHO = '"+_cNicho+"'			                   "
		cQuery3 += "          AND ZH_VEND = '"+_cVend+"' 		                       "
		cQuery3 += "        GROUP BY ZZE_CODCLI, ZZE_NICHO, ZZE_AGRUPA, ZZE_QUANT)     "
		cQuery3 += " GROUP BY ZZE_AGRUPA											   "
		cQuery3 += " ORDER BY ZZE_AGRUPA											   "

		cQuery3 := ChangeQuery(cQuery3)

		memowrite("C:\ORTR787_3.SQL",cQuery3)

		If Select("QRY3") > 0
			dbSelectArea("QRY3")
			QRY3->(DbCloseArea())
		EndIf

		TcQuery cQuery3 Alias "QRY3" New

		While !QRY3->(EOF())
			_nPoten := QRY3->ZZE_QUANT
			_cDescN := IIF(!Empty(_cNicho)," - " + AllTrim(Posicione("SZ0",1,xFilial("SZ0")+'CM'+_cNicho,"Z0_DESCRI"))," Sem classificação") 

			_cAgrupa := fNomeAgr(QRY3->ZZE_AGRUPA)

			oPrn:Say(nLin,0760,AllTrim(_cNicho + _cDescN)			, oFont2)
			oPrn:Say(nLin,1195,_cAgrupa								, oFont2)
			oPrn:Say(nLin,1480,AllTrim(Str(Round(0,2)))				, oFont2)
			oPrn:Say(nLin,1680,AllTrim(Str(Round(_nPoten,2)))		, oFont2)
			oPrn:Say(nLin,1880,AllTrim(Str(Round(QRY->TRIMESTRE,2))), oFont2)
			oPrn:Say(nLin,2080,AllTrim(Str(Round(QRY->PROPOSTA,2)))	, oFont2)
			oPrn:Say(nLin,2270,"0%", oFont2)

			/*********** TOTAIS DO GERENTE **********/
			nPosNic := aScan(aTotGer,{|x| x[1] == AllTrim(_cNicho + _cDescN) })		
			If nPosNic == 0
				aAdd(aTotGer,{AllTrim(_cNicho + _cDescN)})
				aAdd(aTotGer[aScan(aTotGer,{|x| x[1] == AllTrim(_cNicho + _cDescN) })],{_cAgrupa,0,_nPoten,QRY->TRIMESTRE,QRY->PROPOSTA})
			Else
				nPosAgr := 0
				For nX := 2 to Len(aTotGer[nPosNic])
					If aScan(aTotGer[nPosNic][nX],_cAgrupa) > 0
						nPosAgr := nX
						Exit
					EndIf
				Next nX
				If nPosAgr == 0
					aAdd(aTotGer[nPosNic],{_cAgrupa,0,_nPoten,QRY->TRIMESTRE,QRY->PROPOSTA})
				Else
					aTotGer[nPosNic][nPosAgr][3]:= aTotGer[nPosNic][nPosAgr][3]+_nPoten
				EndIf
			EndIf
			/******* TOTAIS GERAIS *********/
			nPosNic := aScan(aTGeral,{|x| x[1] == AllTrim(_cNicho + _cDescN) })		
			If nPosNic == 0
				aAdd(aTGeral,{AllTrim(_cNicho + _cDescN)})
				aAdd(aTGeral[aScan(aTGeral,{|x| x[1] == AllTrim(_cNicho + _cDescN) })],{_cAgrupa,0,_nPoten,qry->trimestre,QRY->PROPOSTA})
			Else
				nPosAgr := 0
				For nX := 2 to Len(aTGeral[nPosNic])
					If aScan(aTGeral[nPosNic][nX],_cAgrupa) > 0
						nPosAgr := nX
						Exit
					EndIf
				Next nPosAgr
				If nPosAgr == 0
					aAdd(aTGeral[nPosNic],{_cAgrupa,0,_nPoten,qry->trimestre,QRY->PROPOSTA})
				Else
					aTGeral[nPosNic][nPosAgr][3]:= aTGeral[nPosNic][nPosAgr][3]+_nPoten
				EndIf
			EndIf
			nLin += nEsp+nEsp
			QRY3->(DbSkip())
			If nLin > 3200
				nLin := fImpCab(.F.,oPrn)
			EndIf
		EndDo
		QRY3->(DbCloseArea())
	Else //Analítico
		cQuery3 := "SELECT ZZE_CODCLI,ZZE_AGRUPA,SUM(ZZE_QUANT) ZZE_QUANT                                    "
		cQuery3 += " FROM (SELECT ZZE_CODCLI, ZZE_NICHO, ZZE_AGRUPA, ZZE_QUANT         "
		cQuery3 += "         FROM "+RetSqlName("ZZE")+" ZZE, "+RetSqlName("SZH")+" ZH  "
		cQuery3 += "        WHERE ZZE.D_E_L_E_T_ = ' '                                 "
		cQuery3 += "          AND ZH.D_E_L_E_T_ = ' '                                  "
		cQuery3 += "          AND ZZE_FILIAL = '  '                                    "
		cQuery3 += "          AND ZH_FILIAL = ' '                                      "
		cQuery3 += "          AND ZZE_CODCLI = '"+_cCliente+"'                   "
		cQuery3 += "          AND ZZE_CODCLI = ZH_CLIENTE                              "
		cQuery3 += "          AND ZZE_AGRUPA NOT IN ("+_cAgrIn+")                      "
		cQuery3 += "          AND ZZE_NICHO = '"+_cNicho+"'			                   "
		cQuery3 += "          AND ZH_VEND = '"+_cVend+"' 		                       "
		cQuery3 += "        GROUP BY ZZE_CODCLI, ZZE_NICHO, ZZE_AGRUPA, ZZE_QUANT)     "
		cQuery3 += "  GROUP BY ZZE_CODCLI, ZZE_AGRUPA								   "
		cQuery3 += "  ORDER BY ZZE_CODCLI, ZZE_AGRUPA								   "
		cQuery3 := ChangeQuery(cQuery3)

		memowrite("C:\ORTR787_3.SQL",cQuery3)

		If Select("QRY3") > 0
			dbSelectArea("QRY3")
			QRY3->(DbCloseArea())
		EndIf

		TcQuery cQuery3 Alias "QRY3" New

		While !QRY3->(EOF())
			_nPoten := QRY3->ZZE_QUANT
			_cDescN := IIF(!Empty(_cNicho)," - " + AllTrim(Posicione("SZ0",1,xFilial("SZ0")+'CM'+_cNicho,"Z0_DESCRI"))," Sem classificação") 

			_cAgrupa := fNomeAgr(QRY3->ZZE_AGRUPA)

			oPrn:Say(nLin,0760,AllTrim(_cNicho + _cDescN)			, oFont2)
			oPrn:Say(nLin,1195,_cAgrupa								, oFont2)
			oPrn:Say(nLin,1480,"0"									, oFont2)
			oPrn:Say(nLin,1580,AllTrim(Str(Round(_nPoten,2)))		, oFont2)
			oPrn:Say(nLin,1880,AllTrim(Str(Round(QRY->TRIMESTRE,2))), oFont2)
			oPrn:Say(nLin,2080,AllTrim(Str(Round(QRY->PROPOSTA,2)))	, oFont2)
			oPrn:Say(nLin,2270,"0%", oFont2)

			/*********** TOTAIS DO GERENTE **********/
			nPosNic := aScan(aTotGer,{|x| x[1] == AllTrim(_cNicho + _cDescN) })		
			If nPosNic == 0
				aAdd(aTotGer,{AllTrim(_cNicho + _cDescN)})
				aAdd(aTotGer[aScan(aTotGer,{|x| x[1] == AllTrim(_cNicho + _cDescN) })],{_cAgrupa,"0",_nPoten,QRY->TRIMESTRE,QRY->PROPOSTA})
			Else
				nPosAgr := 0
				For nX := 2 to Len(aTotGer[nPosNic])
					If aScan(aTotGer[nPosNic][nX],_cAgrupa) > 0
						nPosAgr := nX
						Exit
					EndIf
				Next nPosAgr
				If nPosAgr == 0
					aAdd(aTotGer[nPosNic],{_cAgrupa,0,_nPoten,QRY->TRIMESTRE,QRY->PROPOSTA})
				Else
					aTotGer[nPosNic][nPosAgr][3]:= aTotGer[nPosNic][nPosAgr][3]+_nPoten
				EndIf

				/******* TOTAIS GERAIS *********/
				nPosNic := aScan(aTGeral,{|x| x[1] == AllTrim(_cNicho + _cDescN) })		
				If nPosNic == 0
					aAdd(aTGeral,{AllTrim(_cNicho + _cDescN)})
					aAdd(aTGeral[aScan(aTGeral,{|x| x[1] == AllTrim(_cNicho + _cDescN) })],{_cAgrupa,0,_nPoten,qry->trimestre,QRY->PROPOSTA})
				Else
					nPosAgr := 0
					For nX := 2 to Len(aTGeral[nPosNic])
						If aScan(aTGeral[nPosNic][nX],_cAgrupa) > 0
							nPosAgr := nX
							Exit
						EndIf
					Next nPosAgr
					If nPosAgr == 0
						aAdd(aTGeral[nPosNic],{_cAgrupa,0,_nPoten,qry->trimestre,QRY->PROPOSTA})
					Else
						aTGeral[nPosNic][nPosAgr][3]:= aTGeral[nPosNic][nPosAgr][3]+_nPoten
					EndIf
				EndIf
			EndIf
			nLin += nEsp+nEsp
			QRY3->(DbSkip())
			If nLin > 3200
				nLin := fImpCab(.F.,oPrn)
			EndIf
		EndDo
		QRY3->(DbCloseArea())
	EndIf
Return()

Static Function fImpSCad()

	cQuery4 := " SELECT ZH_CLIENTE, A1_NOME, A1_CGC, ZH_NICHO                      "
	cQuery4 += "   FROM " + RetSQLName("SZH") + " ZH, " + RetSQLName("Sa1") + " A1 "
	cQuery4 += "  WHERE ZH.D_E_L_E_T_ = ' '                                        "
	cQuery4 += "    AND A1.D_E_L_E_T_ = ' '                                        "
	cQuery4 += "    AND ZH_FILIAL = '"+xFilial("SZH")+"'                           "
	cQuery4 += "    AND ZH_NICHO BETWEEN '"+MV_PAR09+"' AND '"+MV_PAR10+"'         "
	cQuery4 += "    AND ZH_VEND  BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"'         "
	cQuery4 += "    AND ZH_MSBLQL != '1'                                           "
	cQuery4 += "    AND A1_MSBLQL != '1'                                           "
	cQuery4 += "    AND A1_PESSOA = 'J'                                            "
	cQuery4 += "    AND A1_FILIAL = '"+xFilial("SA1")+"'                           "
	cQuery4 += "    AND A1_COD = ZH_CLIENTE                                        "
	cQuery4 += "    AND ZH_SEGMENT IN ('1','2')                                    "
	cQuery4 += "    AND NOT EXISTS (SELECT 'X'                                     "
	cQuery4 += "           FROM  " + RetSQLName("ZZE") + "  ZZE                    "
	cQuery4 += "          WHERE ZZE.D_E_L_E_T_ = ' '                               "
	cQuery4 += "            AND ZZE_FILIAL = '"+xFilial("ZZE")+"'                  "
	cQuery4 += "            AND ZZE_NICHO = ZH_NICHO                               "
	cQuery4 += "            AND ZZE_CODCLI = ZH_CLIENTE)                           "
	cQuery4 += "    AND NOT EXISTS (SELECT 'X'                                     "
	cQuery4 += "           FROM  " + RetSQLName("SC5") + " C5                      "
	cQuery4 += "          WHERE C5.D_E_L_E_T_ = ' '                                "
	cQuery4 += "            AND C5_FILIAL = '"+xFilial("SC5")+"'                   "
	cQuery4 += "            AND C5_XNICHO = ZH_NICHO                               "
	cQuery4 += "            AND C5_CLIENTE = ZH_CLIENTE                            "
	cQuery4 += "            AND C5_XTPSEGM = ZH_SEGMENT)                           "
	cQuery4 += " GROUP BY ZH_CLIENTE, A1_NOME, A1_CGC, ZH_NICHO                    "
	cQuery4 += " ORDER BY ZH_CLIENTE                                               "

	cQuery4 := ChangeQuery(cQuery4)

	memowrite("C:\ORTR787_4.SQL",cQuery4)

	If Select("QRY4") > 0
		dbSelectArea("QRY4")
		QRY4->(DbCloseArea())
	EndIf

	TcQuery cQuery4 Alias "QRY4" New

	Lin := fImpCab(.F.,oPrn)
	oPrn:Say(nLin,060, "CLIENTES SEM CADASTRO E SEM PEDIDO", oFontM)
	nLin+=nEsp+nEsp
	While !QRY4->(EOF())

		_cNicho := AllTrim(QRY4->ZH_NICHO) 
		_cDescN := IIF(!Empty(_cNicho)," - " + AllTrim(Posicione("SZ0",1,xFilial("SZ0")+'CM'+_cNicho,"Z0_DESCRI"))," Sem classificação")
		_cDados := "Cliente: " + QRY4->ZH_CLIENTE + " - " + QRY4->A1_NOME + " - " + TRANSFORM(QRY4->A1_CGC,"@R 999.999.999/9999-99")

		oPrn:Say(nLin,060, AllTrim(_cDados + _cNicho + _cDescN) , oFont2)

		nLin += nEsp
		QRY4->(DbSkip())
		If nLin > 3300
			nLin := fImpCab(.F.,oPrn)
			oPrn:Say(nLin,060, "CLIENTES SEM CADASTRO E SEM PEDIDO", oFontM)
			nLin+=nEsp+nEsp
		EndIf
		
		aAdd( aLinhaSem, { 	QRY4->ZH_CLIENTE,;
							QRY4->A1_NOME,;
							TRANSFORM(QRY4->A1_CGC,"@R 999.999.999/9999-99"),;
							_cNicho + _cDescN;
						} )
		
	EndDo
	QRY4->(DbCloseArea())

Return()

Static Function fNomeAgr(_cCodAgr) 

	Do Case 
		Case _cCodAgr = '1'
		_cAgrupa := "Colchão"
		Case _cCodAgr = '2'
		_cAgrupa := "Base"
		Case _cCodAgr = '3'
		_cAgrupa := "Cabeceira"
		Case _cCodAgr = '4'
		_cAgrupa := "Travesseiro"
		Case _cCodAgr = '5'
		_cAgrupa := "Espuma"
		Case _cCodAgr = '6'
		_cAgrupa := "Tecido"
		Case _cCodAgr = '7'
		_cAgrupa := "Manta"
		Case _cCodAgr = '8'
		_cAgrupa := "Mola"
		Case _cCodAgr = '9'
		_cAgrupa := "Plastico"
	EndCase

Return(_cAgrupa)

/*----------------------------------------------*
 | Func:  GeraCSV()                				|
 | Autor: Vagner Almeida 						|
 | Data:  29/04/2021              				|
 | Desc:  Participação no Potencial de Clientes	|
 | Parâmetro(s) Recebido(s) : Nenhum			|
 | Parâmetro(s) Retornado(s): Nemhum 			|
 *----------------------------------------------*/
Static Function GeraCSV()

	Local nHandle	:= 0
	Local cLinha	:= ''
	Local nI		:= 0
	Local cArquivo	:= 'C:\TEMP\ORTR787_' + DTOS(date()) + 	subst(time(),1,2) + ;
															subst(time(),4,2) + ;
															subst(time(),7,2) + '.csv'
	
	MakeDir('C:\TEMP')
	
	nHandle := fCreate(cArquivo, 0)
	If nHandle == -1
		MsgStop('Erro ao criar arquivo: ' + AllTrim(Str(fError())))
		Return
	Endif
	
   	fWrite(nHandle, "Codigo Gte.;Nome Gerente;Codigo Vend.;Nome Vendedor;Codigo Cli.;Nome Cliente;Canal;Tipo;Qtd em Peças;Qtd Potencial;Trimestre;Proposta;% Cumprido" + CHR(13) + CHR(10))
	

	For nI := 1 to Len( aLinha ) 
		
		cLinha := ''
		cLinha += aLinha[nI][01] 	+ ';'
		cLinha += aLinha[nI][02] 	+ ';'
		cLinha += aLinha[nI][03] 	+ ';'
		cLinha += aLinha[nI][04] 	+ ';'
		cLinha += aLinha[nI][05] 	+ ';'
		cLinha += aLinha[nI][06] 	+ ';'
		cLinha += aLinha[nI][07] 	+ ';'
		cLinha += aLinha[nI][08]	+ ';'
		cLinha += aLinha[nI][09]  	+ ';'
		cLinha += aLinha[nI][10]  	+ ';'
		cLinha += aLinha[nI][11]  	+ ';'
		cLinha += aLinha[nI][12]  	+ ';'
		cLinha += aLinha[nI][13]  	+ ';'		
	
		fWrite(nHandle,cLinha + CHR(13) + CHR(10))

	Next nI
/*
	//Gera para Clientes sem Cadastro
	If MV_PAR13 == 2

		For nI := 1 to 10
			
			cLinha := ''
			cLinha += ''	+ ';'
			cLinha += ''	+ ';'
			cLinha += ''	+ ';'
			cLinha += ''	+ ';'
			cLinha += ''	+ ';'
			cLinha += ''	+ ';'
			cLinha += ''	+ ';'
			cLinha += ''	+ ';'
			cLinha += ''	+ ';'
			cLinha += ''	+ ';'
			cLinha += ''	+ ';'
			cLinha += ''	+ ';'
			cLinha += ''	+ ';'
		
			fWrite(nHandle,cLinha + CHR(13) + CHR(10))
	
		Next nI

		fWrite(nHandle, "Codigo.;Nome Cliente;CNPJ;Canal" + CHR(13) + CHR(10))

		For nI := 1 to Len( aLinhaSem ) 
			
			cLinha := ''
			cLinha += aLinhaSem[nI][01] 	+ ';'
			cLinha += aLinhaSem[nI][02] 	+ ';'
			cLinha += aLinhaSem[nI][03] 	+ ';'
			cLinha += aLinhaSem[nI][04] 	+ ';'
		
			fWrite(nHandle,cLinha + CHR(13) + CHR(10))
	
		Next nI
	
	EndIf
*/
	fClose(nHandle)
	
	MsgAlert("Pasta: 'C:\TEMP' " +  Chr(13) + Chr(10) + "Arquivo: " + Substr( cArquivo,9), "Arquivo Gerado!" )
	
Return()


