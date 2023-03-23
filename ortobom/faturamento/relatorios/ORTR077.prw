/*
*---------------------------------------------------------------------------*
* Programa....: ORTR077                                            09.02.09 *
* Programador.: Jose Carlos Noronha                                         *
* Finalidade..: Relatório de Pedidos em Carteira                            *
* Data........: 24/07/06                                                    *
* Propriedade.: Ortobom Colchoes                                            *
* Alteraçao: Conversao para tmsprint - Fábio Santos - TecnoSum - 14/05/2013 *
*---------------------------------------------------------------------------*
* Henrique - 28/05/2014 - SSI 1365                                          *
* 1)Na coluna ZONA CIDADE separar ZONA da CIDADE                            *
*   Na coluna ZONA irá ter o número da zona de entrega,na qual a cidade que *
*   está cadastrada e a coluna CIDADE a região onde o cliente é cadastrado. *
* 2)Na coluna ULT.CARG está sendo relacionado a data que houve  programação *
*   para a zona sendo correto constar a data para a cidade que refere-se ao *
*   pedido. Ex.: o cliente na cidade Rio de janeiro está cadastrado na Zona *
*   02, porém a última programação para esta cidade (rio de janeiro) foi  a *
*   24 dias atrás (01/05/14), mas para a zona 02 tivemos programação  a  01 *
*   dia atrás(25/05/14), a coluna ULT.CARG a data que entra hoje é 25/05 e  *
*   o correto é para constar a data 01/05.                                  *
*---------------------------------------------------------------------------*
* Décio - 16/08/2017 - SSI 50008                                            *
* inclusao do parâmetro em tela "tipo de bloqueio"                          *
*---------------------------------------------------------------------------*
* Vagner Almeida - 27/08/2021 - SSI 123386                                  *
* Solicitante: Marco Aurelio						                        *
* Objetivo: Solicito que seja incluído no Relatório ORTR077 – Relório de    *    						                        				*
* 			Pedidos em Carteira a opção de exportar em CSV.					*
*---------------------------------------------------------------------------*
* Vagner Almeida - 16/09/2021 - SSI 123499                                  *
* Solicitante: Marco Aurelio						                        *
* Objetivo: Solicito que seja incluído no relatório ORTR077 – Pedidos em    *    						                        				*
* 		    Carteira, o parâmetro de desconto SIMBAHIA (SIM ou NÃO).		*
* 		    Sendo assim, ao optar pelo desconto, o relatório trará o valor 	*
* 		    líquido do pedido que possua o respectivo desconto.				*
*---------------------------------------------------------------------------*
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ ORTR077   º Autor ³ Márcio Sobreira   º Data ³  21/03/2018 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Novo parametro para Filtro de Pedidos de outras unidades   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Faturamento				                                  º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
*/
#INCLUDE "PROTHEUS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOTVS.CH"
*----------------------*
User Function ORTR077(cRPC,cNRot,cInfRet)
*----------------------*

// Rogerio Carvalho 25/06/2019 : Planilha Medias Programacoes
// Criacao dos parametros :
// cRPC (S/N) - se relatorio esta sendo chamado via RPC
// cInfret 	  - tipo de informação a ser retornada
Default cRPC		 := "N"
Default cNRot		 := ""
Default cInfRet		 := ""
// Fim Rogerio Carvalho 25/06/2019

Private _cRpc		 := cRpc
Private _cNRot		 := cNRot
Private _cInfRet	 := cInfRet
Private _nTotTotal	 := 0

Private Cabec1       := ""
Private Cabec2       := ""

Private titulo       := "Relatorio de Pedidos em Carteira"
Private cDesc1       := "ESTE MAPA DEVE SER GERADO PELO ADMINISTRADOR PARA QUE O SECRETARIO POSSA DAR RESPOSTA SOBRE O STATUS DOS PEDIDOS"

Private oPrn,oFont,oFontM,oFont2
Private cHora 	   	:= Time()
Private nLin       	:= 0
Private nPag	   	:= 0
Private nCol	   	:= 10
Private cNomFil		:= ""

Private nomeprog     := "ORTR077"
Private wnrel        := "ORTR077"
Private cPerg        := "ORTR77X___"

Private nVez         := 1

Private x
Private _aProd		:= {}
Private dEstCan     := {}
Private _aProdT		:= {}
Private _nPos		:=  0

Private _aResumo	:= {}
Private _aResumoB	:= {} //Vinicius Lança - 25/03/19
Private _aResumo2   := {}
Private _aResumo2B  := {} //Vinicius Lança - 25/03/19
Private _aResumo3	:= {}
Private _aResumo3B	:= {} //Vinicius Lança - 25/03/19
Private aCliente    := {} // Array para vendedores
Private aClienteB   := {} // Array para vendedores
Private _aPedProb	:= {}
Private _aSegmento  := {}
Private _aModelos   := {}
Private _aProdTatr  := {}
Private _aSegFiMix  := {}
Private _aPedAt     := {}
Private _aPedzer    := {}
Private _aTOper     := {} // Array total por operação
Private _aTSOper    := {} // Array total por segmento/operação
Private _aTCSOper   := {} // Array total por Canal/segmento/operação
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
Private cOpr		:= ""

Private aRentSeg30	:= {0,0,0,0}
Private aRtSeg3060  := {0,0,0,0}
Private aRentSeg60	:= {0,0,0,0}
Private aRent30     := {0,0,0,0}
Private aRent3060	:= {0,0,0,0}
Private aRent60		:= {0,0,0,0}
Private aRentTot	:= {0,0,0,0}
Private aDistSeg	:= {0,0,0,0,0}
Private nTotCart	:= 0
Private cSeg 		:= ""

Private cNumsc      := ""
Private cDtSol      := ""
Private cDtEnt      := ""

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
Private cCom        := ""
Private nDias       := 0
Private nVTotVend   := 0
Private nVTotEsp    := 0
Private cAuxNomV	:= ""
Private cTpSegm     := " "
Private Usuario     := RetCodUsr()
Private aOpc        :={{"Industrial"},{"Comercial"},{"Loja"},{"Loja Exclusiva"},{"Site"},{"Geral"},{"Comercial Exclusiva"}}
Private nMV_PAR05   := 0

Private lBahia
Private lpag 		:= .T.
Private _lRpc		:= .F.

If cEmpAnt $ "21|22|24"
	return(u_ortr077b(cRPC,cNRot,cInfRet))
Endif

If _cRpc <> "S"
	ValidPerg(cPerg)
	If !Pergunte(cPerg,.T.)
		Return
	Endif
Endif

If _cRpc == "S" .and. _cNRot =="ORTPMPRG"  // se relatorio foi chamado por RPC
	_lRpc := .T.
	MV_PAR01 := "      "
	MV_PAR02 := "  "
	MV_PAR03 := "ZZZZZZ"
	MV_PAR04 := "ZZ"
	MV_PAR05 := "Geral"
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
	MV_PAR23 := "  /  /    "
	MV_PAR24 := Iif(MV_PAR11 == 1, " ", "99") //"99" //SSI-105463 - Vagner Almeida - 17/12/2020
	MV_PAR25 := 1
	MV_PAR26 := 2
	MV_PAR27 := 1
	MV_PAR28 := 1
	MV_PAR29 := 1
	MV_PAR30 := 1
	MV_PAR31 := 1
	MV_PAR32 := 1
	MV_PAR33 := 1
	MV_PAR34 := " "
	MV_PAR35 := 1
	MV_PAR36 := 1
	MV_PAR37 := 1
	MV_PAR38 := 1
	MV_PAR39 := " "
	MV_PAR40 := " "
	MV_PAR41 := 1 //3	//SSI-105463 - Vagner Almeida - 17/12/2020
	MV_PAR42 := " "
	MV_PAR43 := 1	
	MV_PAR44 := 2
	MV_PAR45 := 3
	//SSI-105463 - Vagner Almeida - 17/12/2020 - Início
	MV_PAR46 := " "  
	MV_PAR47 := "ZZZZZ"
	//SSI-105463 - Vagner Almeida - 17/12/2020 - Final
	/* SSI 113374 */
	MV_PAR48 := 1
	MV_PAR49 := 1
	/* SSI 113374 */
	MV_PAR50 := 1	//SSI-123386 - Vagner Almeida - 30/08/2021
	MV_PAR51 := 1	//SSI-123499 - Vagner Almeida - 13/09/2021
Endif

nMV_PAR05:=aScan(aOpc,{|x| x[1] == AllTrim(MV_PAR05)})

If _cRpc <> "S"
	IF !Empty( MV_PAR34 )
		While !( SubStr( MV_PAR34 , 1 , 1 ) $ "G" )
			IF !MsgYesNo( "Código do Gerente Informado Inválido. Redigitar?" , "Atenção" )
				Return
			EndIF
			Pergunte(cPerg,.T.)
		End While
	EndIF
Endif

dbSelectArea("SC5")
SC5->( dbOrderNickName("PSC51") )

If _cRpc <> "S"
	IF !Empty( MV_PAR34 )
		While !( SubStr( MV_PAR34 , 1 , 1 ) $ "G" )
			IF !MsgYesNo( "Código do Gerente Informado Inválido. Redigitar?" , "Atenção" )
				Return
			EndIF
			Pergunte(cPerg,.T.)
		End While
		IF !Empty( MV_PAR34 )
			TITULO += "( Gerente: " + MV_PAR34 + " " + AllTrim( Posicione("SA3",1,xFilial("SA3")+MV_PAR34,"A3_NREDUZ" ) + " " ) + ")"
		EndIF
	EndIF
Endif

oFont	:= TFont():New('Courier new',, 09,, .T.,,,,,.F.,.F.)
oFontM	:= TFont():New('Courier new',, 10,, .T.,,,,,.F.,.F.)
oFont2	:= TFont():New('Courier new',, 08,, .T.,,,,,.F.,.F.)
oFont3	:= TFont():New('Courier new',, 07,, .T.,,,,,.F.,.F.)

dbSelectArea("SM0")
dbSeek(cEmpAnt)
cNomFil := SM0->M0_FILIAL

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta a interface padrao com o usuario...                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If _cRpc <> "S"
	/*
	oPrn := TMSPrinter():New( titulo )
	oPrn:Setup()
	
	oPrn:SetLandscape()   // Modo Paisagem
	oPrn:SetPaperSize(09) // Formato A4
	*/
	oPrn := TReport():New(FunName(),Titulo,,{|oPrn| GeraRel(oPrn)},Titulo)

	oPrn:SetLandscape()
	oPrn:SetEdit(.T.)         	// Bloqueia personalizar
	oPrn:NoUserFilter()       	// nao permite criar FIltro de usuario
	oPrn:Opage:nPaperSize = 9   // Ajuste para o papel A4
	oPrn:HideHeader()
	oPrn:HideFooter()
	oPrn:PrintDialog()
	/*
	if !oPrn:Cancel()
		Processa( {|| GeraRel(@oPrn) }, "Aguarde...", "Gerando Relatório...",.T.)
		
		//oPrn:Preview()
		//oPrn:End()
	EndIf
	*/
Elseif _cRpc == "S"
	_lRpc := .T.
	//alert("RPC")
	//oPrn := TReport():New("ORTR077",Titulo,,{|oPrn| GeraRel(oPrn)},"MAPA DE VALORES DAS CARGAS")
	//oPrn := TMSPrinter():New( titulo )
	GeraRel(@oPrn)
	
	//oPrn:SetEdit(.F.)
	//oPrn:Print(.f.)
	If _cRpc == "S" .and. alltrim(_cNRot) == "ORTPMPRG" .and. alltrim(_cInfRet) == "CARTGER"
		Return _nTotTotal
	Endif
Endif

FreeObj(oPrn)
oPrn := Nil

Return

*****************************
Static Function GeraRel(oPrn)
*****************************

Local cQuery
Local nVez        := 1
Local _cProds	  := ""
Local _cNicho	  := ""
Local _cSegm	  := 0
Local _nTotReg    := 0
Private nValor    := 0
Private nZcont    := 0
Private	_lPedProb := .F.
Private aRota	  := {}
Private nEsp	  := 50
Private nFatPos, nX
Private nFatPosII := 0

Private _nIndic	  := 0
Private _aPProd   := {}
Private nTotPeso  := 0
Private nTotPesoB := 0

Private aLinha	  := {} //SSI-123386 - Vagner Almeida - 30/08/2021
Private aDetalhe  := {} //SSI-123386 - Vagner Almeida - 30/08/2021

If MV_PAR43 = 2
	nFatPos := 180
Else
	nFatPos := 0
EndIf

IF MV_PAR48 = 2
	nFatPosII := 160
ENDIF

nTxUpme	:= Posicione("SM2",1,DToS(dDataBase),"M2_MOEDA5")

// Henrique - 28/05/2014 - SSI 1365
//cQuery :="SELECT A1_XROTA, MAX(ZQ_DTPREVE) DTPREVE "

cQuery :="SELECT ZH_VEND, ZH_ITINER, MAX(ZQ_DTEMBAR) DTPREVE "
cQuery += "  FROM Siga."+RetSQLName("SZQ")+" SZQ, Siga."+RetSQLName("SC5")+" SC5, Siga."+RetSQLName("SZH")+" SZH "
cQuery += " WHERE SZQ.D_E_L_E_T_ = ' '   "
cQuery += "   AND SC5.D_E_L_E_T_ = ' '   "
cQuery += "   AND SZH.D_E_L_E_T_ = ' '   "
cQuery += "   AND ZQ_TPCARGA <> 'R' "   //NAO CONSIDERA CARGA RETIRA
cQuery += "   AND C5_XOPER <> '04' "   //NAO CONSIDERA CARGA NAO REPOR

cQuery += "   AND C5_XNICHO BETWEEN '"+mv_par46+"' AND '"+mv_par47+"' "//Add Gabriel Rezende 08/01/2021

cQuery += "   AND ZQ_EMBARQ = C5_XEMBARQ   "
cQuery += "   AND C5_CLIENTE = ZH_CLIENTE    "
cQuery += "   AND C5_LOJACLI = ZH_LOJA   "
cQuery += "   AND C5_XTPSEGM = ZH_SEGMENT   "
cQuery += "   AND C5_XOPER <> '04'  "   //SSI 10322 - Marcos Furtado
cQuery += "   AND ZQ_FILIAL = '"+xFilial("SZQ")+"'  "
cQuery += "   AND C5_FILIAL = '"+xFilial("SC5")+"'  "
cQuery += "   AND ZH_FILIAL = '"+xFilial("SZH")+"'  "

If cEmpAnt == "21"  // Henrique - 16/03/2021
   cQuert+= "  AND C5_NUM Not In (Select C5_XPEDCLI From Siga.SC5210)"
EndIf

// Henrique - 28/05/2014 - SSI 1365
//cQuery += " GROUP BY A1_XROTA         "

cQuery += " GROUP BY ZH_VEND, ZH_ITINER    "
cQuery += " ORDER BY 1, 2                   "
memowrit("c:\ortr077reg.sql",cQuery)

If Select("TSC5") > 0
	dbSelectArea("TSC5")
	TSC5->(DbCloseArea())
EndIf
TCQUERY cQuery ALIAS "TSC5" NEW

dbselectarea("TSC5")
TSC5->( dbGoTop() )
do while TSC5->( !eof() )
	// Henrique - 28/05/2014 - SSI 1365
	//	TSC5->( aadd(aRota,{alltrim(A1_XROTA),DTPREVE}) )
	TSC5->( aadd(aRota,{alltrim(ZH_VEND)+alltrim(ZH_ITINER),DTPREVE}) )
	TSC5->( dbskip() )
enddo

//aSort(aRota,,,{|x,y| x[2]>y[2]})

TSC5->( dbclosearea() )
cQuery := " SELECT (CASE WHEN C5_XOPER = '17' OR C5_XOPER = '02' OR C5_XOPER = '03'  THEN 0 ELSE 1 END) ORDT, "
cQuery += "	(TO_DATE("+Dtos(dDataBase)+",'YYYYMMDD')- TO_DATE(C5_EMISSAO,'YYYYMMDD')) ORDD, SA1.A1_COD, SA1.A1_LOJA, SA1E.A1_NOME A1_NOMEE, SA1.A1_NOME, SA1.A1_MUN, "
cQuery += "	SA1.A1_BAIRRO,SA1.A1_XTIPO,SA1.A1_XCLIEXC, ZH_ITINER, C5_VEND1, SA1.A1_CGC, SA1.A1_XMOTBLQ, SA1E.A1_XMOTBLQ A1_XMOTBLQE, "
cQuery += "	(SELECT SZ3.Z3_DESC               "
cQuery += "	   FROM SIGA."+RetSqlName('SZ3')+" SZ3 "
cQuery += "	  WHERE Z3_CODIGO = SA1.A1_XROTA  "
If !empty(MV_PAR52)
	cQuery += " and SA1.A1_XROTA >='"+MV_PAR52+"'" //DMS|| SSI - 126242
	cQuery += " and SA1.A1_XROTA <='"+iif(empty(MV_PAR53),"ZZZZZZ",MV_PAR53)+"'" //DMS|| SSI - 126242
endif
cQuery += "	    AND SZ3.D_E_L_E_T_ = ' '      "
cQuery += "	    AND SZ3.Z3_FILIAL = '"+xFilial("SZ3")+"') ZONAV, "
//cQuery += "NVL(A3_NREDUZ,'SEM VENDEDOR') A3_NREDUZ, C5_NUM, C5_TABELA, C5_XOPER, C5_CLIENTE, " SSI 7169
cQuery += "NVL(SA3.A3_NREDUZ,'SEM VENDEDOR') A3_NREDUZ, C5_NUM, C5_TABELA, C5_XOPER, C5_CLIENTE, "
cQuery += "       (SELECT (CASE WHEN COUNT(*) > 0 THEN '1' ELSE '0' END) "
cQuery += "          FROM SIGA."+RETSQLNAME("SZE")
cQuery += "         WHERE D_E_L_E_T_ = ' ' "
cQuery += "           AND ZE_FILIAL = '"+xFilial("SZE")+"'"
cQuery += "           AND ZE_PEDIDO = C5_NUM "
cQuery += "           AND ZE_USUARIO = ' ' "
cQuery += "           AND ZE_AUTORIZ IN ('BLQMIX','BLQBRD','BLQPZM')) REGCOM, "

cQuery += "       (SELECT (CASE WHEN COUNT(*) > 0 THEN '1' ELSE '0' END) "
cQuery += "          FROM SIGA."+RETSQLNAME("SZE")
cQuery += "         WHERE D_E_L_E_T_ = ' '  "
cQuery += "           AND ZE_FILIAL = '"+xFilial("SZE")+"'"
cQuery += "           AND ZE_PEDIDO = C5_NUM "
cQuery += "           AND ZE_USUARIO = ' ' "
cQuery += "           AND ZE_AUTORIZ IN ('BLQDEB','BLQPEN','BLQSOC','BLQCOM','BLQPRZ','BLQPNV','BLQPDC')) REGCOB, "
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
cQuery += "        (SELECT (CASE WHEN COUNT(*) > 0 THEN '1' ELSE '0' END) "
cQuery += "          FROM SIGA."+RETSQLNAME("SZE")
cQuery += "         WHERE D_E_L_E_T_ = ' '   "
cQuery += "           AND ZE_FILIAL = '"+xFilial("SZE")+"' "
cQuery += "           AND ZE_PEDIDO = C5_NUM  "
cQuery += "           AND ZE_USUARIO = ' ' "
cQuery += "           AND ZE_AUTORIZ NOT IN ('BLQMIX','BLQBRD','BLQPZM','BLQSBM','BLQREP','BLQDEB','BLQPEN','BLQSOC','BLQCOM')) FABCOB, "
cQuery += " C5_EMISSAO, SA1.A1_XQTDLP,SA1.A1_XQTDCHS,SA1.A1_XQTDCTS,SA1.A1_XQTDPRG,SA1.A1_XQTDPRO, SA1.A1_XQTDPEN,SA1.A1_XROTA,SA1.A1_XCIDADE, "
cQuery += " C5_XPERENT,SA1.A1_XQTDPRM, C5_XDTLIB, C5_XTPSEGM, C5_XEMBARQ, C5_XNPVORT, "
cQuery += " SUM((DECODE(B1_XMODELO,'000008',C6_UNSVEN,'000018',C6_UNSVEN,C6_QTDVEN) * B1_XESPACO)/DECODE(C5_XTPCOMP,'V',3,'C',2,1)) AS ESPACO, C5_XENTREG, "   //SSI 19244
cQuery += "          (TO_DATE(TO_CHAR(SYSDATE,'YYYYMMDD'),'YYYYMMDD') - TRUNC(TO_DATE(CASE "
cQuery += "         WHEN C5_XENTREG <> ' ' THEN "
cQuery += "          C5_XENTREG "
cQuery += "         ELSE        "
cQuery += "          CASE WHEN C5_XESTCAN <> '        ' THEN C5_XESTCAN ELSE C5_EMISSAO END "
cQuery += "       END, 'YYYYMMDD'))) DIAS, "   //ELSE TO_DATE("+Dtos(dDataBase)+", 'YYYYMMDD') - TO_DATE(C5_EMISSAO, 'YYYYMMDD') END) DIAS, "
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

//SSI-123499 - Vagner Almeida - 16/09/2021 - Inicio
If MV_PAR51 == 2 .and. (cEmpAnt $ '07|23|24') 
	cQuery+="    (CASE                                                                       "
	cQuery+="         WHEN C5_XTPSEGM = '3' AND C5_XOPER <> '07' AND C5_XOPER <> '08' THEN   "
	cQuery+="          SUM(((C6_XPRUNIT - ((C6_XGUELTA + C6_XRESSAR) * C6_XPRUNIT / 100))) * "
	cQuery+="              C6_QTDVEN - C6_XFEILOJ)                               "
	cQuery+="         ELSE                                          "
	cQuery+="          SUM(CASE                                     "
	cQuery+="         WHEN C5_XOPER = '07' OR C5_XOPER = '08' THEN "
	cQuery+="          C6_PRCVEN  * C6_QTDVEN  - C6_XFEILOJ "
	cQuery+="         ELSE                    "
	cQuery+="          C6_XPRUNIT * C6_QTDVEN  - C6_XFEILOJ "
	cQuery+="       END)"
	cQuery+="       END) AS TOTPED, "
Else
//SSI-123499 - Vagner Almeida - 16/09/2021 - Final
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
	cQuery+="       END)"
	cQuery+="       END) AS TOTPED, "
EndIf //SSI-123499 - Vagner Almeida - 16/09/2021

cQuery+="          SUM("
cQuery+="          C6_XCUSTO * C6_QTDVEN  "
cQuery+="       ) AS CUSTPED, "

//Adicionado por Bruno para Calculo da Rentabilidade
cQuery += " (SELECT SUM(C6_QTDVEN * (CASE WHEN C5_XOPER = '07' THEN C6_PRCVEN  ELSE  C6_XPRUNIT   END)) FROM SIGA."+RetSQLName("SC6")+" WHERE D_E_L_E_T_ = ' ' "
cQuery += " AND C6_FILIAL = '"+ xFilial("SC6") + "'"+" AND C6_NUM = C5_NUM AND C6_PRODUTO LIKE '407095%') TERC, "
cQuery += " C5_XMIX, "
//Fim
cQuery += " C5_XENTREF, C5_XOPER , sum((select SUM(B2_QATU) "
cQuery += "                           from SIGA."+RetSQLName("SB2") + " SB2 WHERE D_E_L_E_T_ = ' ' AND B2_QATU > 0 "
cQuery += "                            AND B2_COD = C6_PRODUTO AND B2_LOCAL = '18')) QTDEST , C5_XESTCAN, C5_XUNORI, C5_XPEDCLX, "
If MV_PAR13 = 2 .Or.	mv_par18	=	2  .or. mv_par20 = 2
	cQuery += "  C6_PRODUTO, C6_DESCRI, C6_QTDVEN, BM_XSUBGRU, "
	cQuery += " (CASE WHEN B1_XMODELO = ' ' THEN 'NAO CADASTRADO' ELSE B1_XMODELO END) B1_XMODELO, B1_XMED,B1_XPERSON, "
Endif
If MV_PAR43 = 2
	cQuery += "ID_SISLOJA, "
EndIf
/* SSI 113374 */
If MV_PAR48 = 2
	cQuery += "C5_XTALSAC, "
EndIf
/* SSI 113374 */

cQuery += "MAX((SELECT MAX(ENDENT.PEDIDO) FROM SIGA."
cQuery += RetSQLName("SZ2") + " SZ2, SIGA.ENDENT ENDENT "
cQuery += " WHERE SZ2.D_E_L_E_T_ = ' ' "
cQuery += " AND Z2_FILIAL = '" + xFilial("SZ2") + "'"
cQuery += " AND C6_NUM = Z2_NUMPED "
cQuery += " AND C6_CLI = Z2_CLIENTE "
cQuery += " AND C6_PRODUTO = Z2_PRODUTO "
cQuery += " AND Z2_PEDIDO = ENDENT.PEDIDO "
cQuery += " AND ENDENT.COD = Z2_CLIENTE "
cQuery += " AND ENDENT.UN = '" + cEmpAnt + "')) PEDIDO, "
cQuery += " C5_XNICHO "
cQuery += " FROM SIGA." + RetSQLName("SC6") + " SC6, SIGA."
cQuery += RetSQLName("SB1") + " SB1, SIGA."
cQuery += RetSQLName("SA1") + " SA1, SIGA."
cQuery += RetSQLName("SA1") + " SA1E, SIGA."
cQuery += RetSQLName("SA3") + " SA3, SIGA."
cQuery += RetSQLName("SC5") + " SC5, SIGA."
cQuery += RetSQLName("SZH") + " SZH, SIGA."
cQuery += RetSQLName("SA3") + " GPR, SIGA."   //SSI 7169
cQuery += RetSQLName("SBM") + " SBM,  SIGA.CARTEIRA"+cEmpAnt+"0 "
If MV_PAR43 = 2
	cQuery += ", SIGA.TROCASISLOJA TROCASISLOJA  "
EndIf
cQuery += " WHERE B1_GRUPO = BM_GRUPO    "
cQuery += " AND SC5.R_E_C_N_O_ = REC     "
cQuery += " AND SA3.A3_COD(+) = C5_VEND1    "
IF !Empty(MV_PAR34)
	cQuery += " AND SA3.A3_GEREN = '"+MV_PAR34+"'"
EndIF
cQuery += " AND SC5.C5_NUM = C6_NUM      "
If MV_PAR43 = 2
	cQuery += " AND SC5.C5_NUM = TROCASISLOJA.PEDIDO      "
	cQuery += " AND SC5.C5_COTACAO IN ('ORT425','OR425J')      "
EndIf
If MV_PAR44 == 1
	cQuery += " AND C5_XOPER <> '23'     "
ELSE
	If MV_PAR44 == 3
		cQuery += " AND C5_XOPER = '23'     "
	EndIf
EndIf
If cEmpAnt = '03'
	If MV_PAR45 == 1
	
		 cQuery += "AND SA1.A1_XOPLOG IN (' ','1') " 
	     /*cQuery += " AND NOT EXISTS (SELECT ENDENT.PEDIDO FROM "
         cQuery += RetSQLName("SZ2") + " SZ2, ENDENT ENDENT "
         cQuery += " WHERE SZ2.D_E_L_E_T_ = ' ' "
         cQuery += " AND Z2_FILIAL = '" + xFilial("SZ2") + "'"
         cQuery += " AND C6_NUM = Z2_NUMPED "
         cQuery += " AND C6_CLI = Z2_CLIENTE "
         cQuery += " AND C6_PRODUTO = Z2_PRODUTO "
         cQuery += " AND Z2_PEDIDO = ENDENT.PEDIDO "
         cQuery += " AND ENDENT.COD = Z2_CLIENTE "
        cQuery += " AND ENDENT.UN = '" + cEmpAnt + "') "*/
	ElseIf MV_PAR45 == 2
		 cQuery += "AND SA1.A1_XOPLOG = '2'" 
	     /*cQuery += " AND EXISTS (SELECT ENDENT.PEDIDO FROM "
         cQuery += RetSQLName("SZ2") + " SZ2, ENDENT ENDENT "
         cQuery += " WHERE SZ2.D_E_L_E_T_ = ' ' "
         cQuery += " AND Z2_FILIAL = '" + xFilial("SZ2") + "'"
         cQuery += " AND C6_NUM = Z2_NUMPED "
         cQuery += " AND C6_CLI = Z2_CLIENTE "
         cQuery += " AND C6_PRODUTO = Z2_PRODUTO "
         cQuery += " AND Z2_PEDIDO = ENDENT.PEDIDO "
         cQuery += " AND ENDENT.COD = Z2_CLIENTE "
        cQuery += " AND ENDENT.UN = '" + cEmpAnt + "') "*/
	EndIf
EndIf
cQuery += " AND C5_CLIENTE = C6_CLI      "
cQuery += " AND C5_LOJACLI = C6_LOJA     "
cQuery += " AND B1_COD = C6_PRODUTO      "
cQuery += " AND ZH_CLIENTE (+)= C5_CLIENTE  "
cQuery += " AND ZH_LOJA  (+)= C5_LOJACLI    "
cQuery += " AND ZH_VEND  (+)= C5_VEND1      "
cQuery += " AND ZH_SEGMENT(+)= C5_XTPSEGM   "
cQuery += " AND SA1.A1_COD = C5_CLIENT     "
cQuery += " AND SA1E.A1_COD (+)= C5_XCLITRO "
cQuery += " AND SA1.A1_LOJA = C5_LOJACLI     "
cQuery += " AND SA1E.A1_LOJA (+)= C5_XLOJATR "
cQuery += " AND C5_XEMBARQ = ' '"
cQuery += " AND C6_NOTA = ' '   "
//cQuery += " AND SX5.X5_TABELA = 'ZA'  	  "
//cQuery += " AND SX.X5_TABELA(+) = 'ZD'    "

cQuery += "   AND C5_XNICHO BETWEEN '"+mv_par46+"' AND '"+mv_par47+"' "

*'Pedidos de outras unidades - Márcio Sobreira -----------------------------------------------'*
If MV_PAR41 == 2 // Origem (13)
	cQuery += " AND C5_XOPER NOT IN ('20','21','99') "   //Não lista pedidos "Não repor" e "Cancelados"
Else
	cQuery += " AND C5_XOPER NOT IN ('13','20','21','99') "   //Não lista pedidos "Não repor" e "Cancelados"
Endif
*'--------------------------------------------------------------------------------------------'*

cQuery += " AND C5_XACERTO	=	' '      " /**********/
//LUCIANO - SSI 26736 - Imprimir razoes agrupadas
IF MV_PAR36 <> 2
	cQuery += " AND C5_CLIENTE between '" + MV_PAR01 + "' and '" + MV_PAR03 + "'"
	cQuery += " AND C5_LOJACLI between '" + MV_PAR02 + "' and '" + MV_PAR04 + "'"
ELSE
	cQuery += " AND C5_CLIENTE IN	(SELECT A1_COD "
	cQuery += "							 FROM SIGA."+RetSQLName("SA1")+" SA11 "
	cQuery += "							 WHERE A1_XCODGRU IN (SELECT A1_XCODGRU "
	cQuery += "												  FROM SIGA."+RetSQLName("SA1")+" SA12 "
	cQuery += "												  WHERE A1_COD between '" + MV_PAR01 + "' and '" + MV_PAR03 + "')

	if !Empty(MV_PAR52)
		cQuery += " and A1_XROTA >='"+MV_PAR52+"' " //DMS|| SSI - 126242
		cQuery += " and SA1.A1_XROTA <='"+iif(empty(MV_PAR53),"ZZZZZZ",MV_PAR53)+"'" //DMS|| SSI - 126242
	endif

	cQuery += ")"
Endif
//Fim - SSI 26736 - Imprimir razoes agrupadas

cQuery += " AND C5_TABELA BETWEEN '" + MV_PAR06 + "' AND '" + MV_PAR07 + "'"
cQuery += " AND C5_VEND1 between '" + MV_PAR08 + "' and '" + MV_PAR09 + "'"

&& Henrique - 08/05/2014 - SSI 1207
&&If MV_PAR05 <> 5 .AND. MV_PAR05 <> 7
&&	cQuery += " AND C5_XTPSEGM = '" + STRZERO(MV_PAR05,1) + "'"
&&Endif
If nMV_PAR05 <> 6 .AND. nMV_PAR05 <> 7
	cSgmto:=IIf(nMV_PAR05==5,"8",StrZero(nMV_PAR05,1))
	cQuery += " AND C5_XTPSEGM = '" + cSgmto + "'"	
Endif

If nMV_PAR05 == 7
	cQuery += " AND C5_XTPSEGM = '2' AND SA1.A1_XCLIEXC = '1'"
Endif


If MV_PAR10 = 1
	cQuery += " AND B1_COD NOT LIKE '407095%' "                        // NAO LISTA TERCEIROS
Else
	If MV_PAR12 = 2
		cQuery += " AND B1_COD LIKE '407095%' "                       // LISTA SOMENTE TERCEIROS SE O PARAMETRO 9 FOR IGUAL A 2 (SIM)
	Endif
Endif

IF MV_PAR25 = 2 .OR. MV_PAR26 = 2 .OR. MV_PAR27 = 2 .OR. MV_PAR28 = 2 .OR. MV_PAR29 = 2 .OR. MV_PAR30 = 2 .OR. MV_PAR31 = 2 .OR. MV_PAR32 = 2 .OR. MV_PAR33 = 2 .or. MV_PAR44>1
	cOpr := "("
	If MV_PAR25 = 2
		cOpr += "'02','03','17',"                 // TROCAS
	Endif
	If MV_PAR26 = 2
		cOpr += "'01','12','13','10',"            // NORMAL    // incluido no dia 27/08/12 - autorizado pelo avilton, charles e crus - WFA
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
		cOpr += "'04',"                           // CONSERTO
	Endif
	
	If MV_PAR33 = 2
		cOpr += "'06','24','25','27',"            // CONSERTO
	Endif
	
	*'Pedidos de outras unidades - Márcio Sobreira -----------------------------------------------'*
	If MV_PAR41 = 3
		cOpr += "'14',"                 // ORIGEM (DE)
	Endif
	If MV_PAR41 = 2
		cOpr += "'13',"                 // DESTINO (PARA)
	Endif
	*'--------------------------------------------------------------------------------------------------'*
	If MV_PAR44 = 2
		cOpr += "'23',"                 // DESTINO (PARA)
	Endif
	If MV_PAR44 = 3
		cOpr := "('23')"                 // DESTINO (PARA)
	Endif
	
	cOpr := SUBSTR(cOpr,1,LEN(COPR)-1)
	cQuery += "AND C5_XOPER IN "+cOpr+")"
ENDIF

If MV_PAR15 = 2
	cQuery += " AND C5_XENTREF <> ' ' AND C5_XTPSEGM != '8'"   // C/DATA ENTREGA (SITE DEVE SER SEMPRE CONSIDERADO LIVRE
ElseIf MV_PAR15 = 3
	cQuery += " AND (C5_XENTREF = ' ' OR C5_XTPSEGM = '8')"    // S/DATA ENTREGA (SITE DEVE SER SEMPRE CONSIDERADO LIVRE
Endif      
If mv_par16 = 2
	cQuery += " AND C5_XDTLIB <> ' ' AND C5_XQUAREN != '1' "                             // LIBERADOS
ElseIf mv_par16 = 3
	cQuery += " AND C5_XDTLIB = ' ' AND C5_XQUAREN != '1' "                              // NAO LIBERADOS
ElseIf mv_par16 = 4
	cQuery += " AND C5_XQUAREN = '1' "							   // QUARENTENA
Endif
If mv_par17 = 2
	cQuery += " AND C5_XTPSEGM IN ('3','4') "	 				 // Só Lojas
ElseIf mv_par17 = 3
	cQuery += " AND C5_XTPSEGM NOT IN ('3','4') "                     // Sem Lojas
EndIf

cQuery += " AND SC6.D_E_L_E_T_ = ' ' "
//cQuery += " AND SZE.D_E_L_E_T_(+) = ' ' "
cQuery += " AND SB1.D_E_L_E_T_ = ' ' "
cQuery += " AND SA1.D_E_L_E_T_ = ' ' "
cQuery += " AND SA1E.D_E_L_E_T_ (+)= ' ' "
cQuery += " AND SA3.D_E_L_E_T_(+) = ' ' "
cQuery += " AND GPR.D_E_L_E_T_(+) = ' ' "   //SSI 7169
cQuery += " AND SC5.D_E_L_E_T_ = ' ' "
cQuery += " AND SZH.D_E_L_E_T_ (+)= ' ' "
cQuery += " AND SBM.D_E_L_E_T_ = ' ' "
cQuery += " AND C6_FILIAL = '" + xFilial("SC6") + "'"
cQuery += " AND B1_FILIAL = '" + xFilial("SB1") + "'"
cQuery += " AND SA1.A1_FILIAL = '" + xFilial("SA1") + "'"
cQuery += " AND SA1E.A1_FILIAL (+)= '" + xFilial("SA1") + "'"
//cQuery += " AND A3_FILIAL(+) = '" + xFilial("SA3") + "'"   SSI 7169
cQuery += " AND SA3.A3_FILIAL(+) = '" + xFilial("SA3") + "'"
cQuery += " AND GPR.A3_FILIAL(+) = '" + xFilial("SA3") + "'"   //SSI 7169
cQuery += " AND C5_FILIAL = '" + xFilial("SC5") + "'"
cQuery += " AND ZH_FILIAL (+)= '" + xFilial("SZH") + "'"
cQuery += " AND BM_FILIAL = '" + xFilial("SBM") + "'"

cQuery += "   AND C5_XNICHO BETWEEN '"+mv_par46+"' AND '"+mv_par47+"' "

If MV_PAR43 = 2
	cQuery += " AND TROCASISLOJA.UNIDADE(+) = '" + cEmpAnt + "'"
	cQuery += " AND TROCASISLOJA.FILIAL(+) = '" + xFilial("SC5") + "' "
	cQuery += " AND TROCASISLOJA.LOJA_COD(+) = C5_CLIENTE "
EndIf
If MV_PAR43 = 2
	If cEmpAnt == '26'
		cQuery += " AND FILIAL in ('  ','02')"
	Else
		cQuery += " AND FILIAL = '" + xFilial("SC5") + "'"
	Endif
EndIf
//Início SSI 7169
If !Empty(MV_PAR39)
	cQuery += " AND SA1.A1_XORIENT = '" + MV_PAR39 + "'"
EndIf
cQuery += " AND GPR.A3_COD (+)= SA1.A1_XORIENT "
If !Empty(MV_PAR40)
	cQuery += " AND GPR.A3_SUPER = '" + MV_PAR40 + "'"
EndIf
//Fim SSI 7169

If !Empty(MV_PAR42)
	cQuery += " AND UPPER(SA1.A1_BAIRRO) = ('" + UPPER(MV_PAR42) + "') "
EndIf

//cQuery += " AND SZE.ZE_FILIAL(+) = '" + xFilial("SZE") + "'"
cQuery += " GROUP BY SA1.A1_COD, SA1.A1_LOJA, SA1.A1_NOME,SA1E.A1_NOME, SA1.A1_MUN, SA1.A1_BAIRRO, SA1.A1_XROTA, SA1.A1_XBLQDOC, SA1.A1_XCLIEXC,SA1.A1_XTIPO,ZH_ITINER, "
//cQuery += " C5_VEND1, A3_NREDUZ, C5_NUM, C5_TABELA, C5_XOPER, C5_EMISSAO,SA1.A1_XQTDLP,SA1.A1_XQTDCHS,SA1.A1_XQTDCTS,SA1.A1_XQTDPRG, "   SSI 7169
cQuery += " C5_VEND1, SA3.A3_NREDUZ, C5_NUM, C5_TABELA, C5_XOPER, C5_EMISSAO,SA1.A1_XQTDLP,SA1.A1_XQTDCHS,SA1.A1_XQTDCTS,SA1.A1_XQTDPRG, "
cQuery += " SA1.A1_XQTDPRO,SA1.A1_XQTDPEN, SA1.A1_XQTDPRM,SA1.A1_XROTA,SA1.A1_XCIDADE,SA1.A1_XCLIEXC, C5_XPERENT, C5_XDTLIB, C5_XTPSEGM,  C5_XNPVORT, "
cQuery += " C5_XEMBARQ,  C5_XENTREG, C5_XENTREF, C5_XMIX, C5_XOPER, C5_CLIENTE, SA1.A1_CGC, SA1.A1_XMOTBLQ, SA1E.A1_XMOTBLQ, C5_XESTCAN, C5_XUNORI, C5_XPEDCLX, C5_XNICHO "

If MV_PAR13 = 2 .Or.	mv_par18	=	2  .or. mv_par20 = 2
	cQuery += " , C6_PRODUTO, C6_DESCRI, C6_QTDVEN, B1_XMODELO, C5_XEMBARQ, "
	cQuery += " BM_XSUBGRU, B1_XPERSON, B1_XMED, C5_XENTREG, C5_XENTREF, C5_XOPER "
Endif
If MV_PAR43 = 2
	cQuery += " , ID_SISLOJA  "
ENDiF
/* SSI 113374 */
If MV_PAR48 = 2
	cQuery += " , C5_XTALSAC "
EndIf
/* SSI 113374 */

cQuery += " UNION ALL "

cQuery += "SELECT (CASE "
cQuery += "         WHEN C5_XOPER = '17' OR C5_XOPER = '02' OR C5_XOPER = '03' THEN "
cQuery += "          0       "
cQuery += "         ELSE     "
cQuery += "          1       "
cQuery += "       END) ORDT, "
cQuery += "       (TO_DATE("+Dtos(dDataBase)+", 'YYYYMMDD') - TO_DATE(C5_EMISSAO, 'YYYYMMDD')) ORDD, "
cQuery += "        A2_COD A1_COD,    "
cQuery += "        A2_LOJA A1_LOJA,      "
cQuery += "        ' ' A1_NOMEE,     "
cQuery += "        A2_NOME A1_NOME,      "
cQuery += "        A2_MUN A1_MUN,       "
cQuery += "        A2_BAIRRO A1_BAIRRO,    "
cQuery += "        ' ' A1_XTIPO,     "
cQuery += "		   ' ' A1_XCLIEXC,	 "
cQuery += "        ZH_ITINER,        "
cQuery += "        C5_VEND1,         "
cQuery += "        ' ' A1_CGC,       "
cQuery += "        ' ' A1_XMOTBLQ,	 "
cQuery += "        ' ' A1_XMOTBLQE,	 "
cQuery += "	       ' ' ZONAV,        "
cQuery += "        NVL(A3_NREDUZ, 'SEM VENDEDOR') A3_NREDUZ, "
cQuery += "        C5_NUM,           "
cQuery += "        C5_TABELA,        "
cQuery += "        C5_XOPER,         "
cQuery += "        C5_CLIENTE,       "
cQuery += "        (SELECT (CASE     "
cQuery += "                  WHEN COUNT(*) > 0 THEN "
cQuery += "                   '1'      "
cQuery += "                  ELSE      "
cQuery += "                   '0'      "
cQuery += "                END)        "
cQuery += "           FROM SIGA."+RetSqlName("SZE")+ "  "
cQuery += "          WHERE D_E_L_E_T_ = ' '   "
cQuery += "            AND ZE_FILIAL = '"+xFilial("SZE")+"'   "
cQuery += "            AND ZE_PEDIDO = C5_NUM "
cQuery += "            AND ZE_USUARIO = ' ' "
cQuery += "            AND ZE_AUTORIZ IN ('BLQMIX', 'BLQBRD', 'BLQPZM')) REGCOM, "
cQuery += "        (SELECT (CASE   "
cQuery += "                  WHEN COUNT(*) > 0 THEN "
cQuery += "                   '1'           "
cQuery += "                  ELSE           "
cQuery += "                   '0'           "
cQuery += "                END)             "
cQuery += "           FROM SIGA."+RetSqlName("SZE")+"      "
cQuery += "          WHERE D_E_L_E_T_ = ' ' "
cQuery += "            AND ZE_FILIAL = '"+xFilial("SZE")+"' "
cQuery += "            AND ZE_PEDIDO = C5_NUM "
cQuery += "            AND ZE_USUARIO = ' ' "
cQuery += "            AND ZE_AUTORIZ IN ('BLQDEB', 'BLQPEN', 'BLQSOC', 'BLQCOM', 'BLQPRZ', 'BLQPNV', 'BLQPDC')) REGCOB, "
cQuery += "        RPAD('', 30) AS REGLOJ, "
cQuery += "       (SELECT (CASE "
cQuery += "                 WHEN COUNT(*) > 0 THEN "
cQuery += "                  '1'         "
cQuery += "                 ELSE         "
cQuery += "                  '0'         "
cQuery += "               END)           "
cQuery += "          FROM SIGA."+RetSqlName("SZE")+"    "
cQuery += "         WHERE D_E_L_E_T_ = ' '   "
cQuery += "           AND ZE_FILIAL = '"+xFilial("SZE")+"'   "
cQuery += "           AND ZE_PEDIDO = C5_NUM "
cQuery += "           AND ZE_USUARIO = ' '   "
cQuery += "           AND ZE_AUTORIZ NOT IN  "
cQuery += "               ('BLQMIX', 'BLQBRD', 'BLQPZM', 'BLQSBM', 'BLQREP', 'BLQDEB', "
cQuery += "                'BLQPEN', 'BLQSOC', 'BLQCOM')) FABCOB, "
cQuery += "       C5_EMISSAO,   "
cQuery += "       0 A1_XQTDLP,  "
cQuery += "       0 A1_XQTDCHS, "
cQuery += "       0 A1_XQTDCTS, "
cQuery += "       0 A1_XQTDPRG, "
cQuery += "       0 A1_XQTDPRO, "
cQuery += "       0 A1_XQTDPEN, "
cQuery += "       ' ' A1_XROTA, "
cQuery += "       ' ' A1_XCIDADE,"
cQuery += "       C5_XPERENT,   "
cQuery += "       0 A1_XQTDPRM, "
cQuery += "       C5_XDTLIB,  "
cQuery += "       C5_XTPSEGM, "
cQuery += "       C5_XEMBARQ, "
cQuery += "       C5_XNPVORT, "
cQuery += "       SUM((C6_QTDVEN * B1_XESPACO) / DECODE(C5_XTPCOMP, 'V', 3, 'C', 2, 1)) AS ESPACO, "
cQuery += "       C5_XENTREG, "
//cQuery += "       (CASE       "
//cQuery += "         WHEN C5_XDTLIB <> ' ' THEN "
cQuery += "          (TO_DATE(TO_CHAR(SYSDATE,'YYYYMMDD'),'YYYYMMDD') - TRUNC(TO_DATE(CASE "
cQuery += "         WHEN C5_XENTREG <> ' ' THEN "
cQuery += "          C5_XENTREG "
cQuery += "         ELSE        "
cQuery += "          CASE WHEN C5_XESTCAN <> '        ' THEN C5_XESTCAN ELSE C5_EMISSAO END "
cQuery += "       END, 'YYYYMMDD'))) DIAS, "   //ELSE TO_DATE("+Dtos(dDataBase)+", 'YYYYMMDD') - TO_DATE(C5_EMISSAO, 'YYYYMMDD') END) DIAS, "

//SSI-123499 - Vagner Almeida - 16/09/2021 - Inicio
If MV_PAR51 == 2 .and. (cEmpAnt $ '07|23|24') 
	cQuery += "       (CASE          "
	cQuery += "         WHEN C5_XTPSEGM = '3' AND C5_XOPER <> '07' AND C5_XOPER <> '08' THEN    "
	cQuery += "          SUM(((C6_XPRUNIT - ((C6_XGUELTA + C6_XRESSAR) * C6_XPRUNIT / 100))) *  "
	cQuery += "              C6_QTDVEN - C6_XFEILOJ )                              "
	cQuery += "         ELSE                                         "
	cQuery += "          SUM(CASE                                    "
	cQuery += "         WHEN C5_XOPER = '07' OR C5_XOPER = '08' THEN "
	cQuery += "          C6_PRCVEN  * C6_QTDVEN - C6_XFEILOJ         "
	cQuery += "         ELSE                                  "
	cQuery += "          C6_XPRUNIT * C6_QTDVEN - C6_XFEILOJ         "
	cQuery += "       END) END) AS TOTPED,                    "
Else
//SSI-123499 - Vagner Almeida - 16/09/2021 - Final
	cQuery += "       (CASE          "
	cQuery += "         WHEN C5_XTPSEGM = '3' AND C5_XOPER <> '07' AND C5_XOPER <> '08' THEN    "
	cQuery += "          SUM(((C6_XPRUNIT - ((C6_XGUELTA + C6_XRESSAR) * C6_XPRUNIT / 100))) *  "
	cQuery += "              C6_QTDVEN)                              "
	cQuery += "         ELSE                                         "
	cQuery += "          SUM(CASE                                    "
	cQuery += "         WHEN C5_XOPER = '07' OR C5_XOPER = '08' THEN "
	cQuery += "          C6_PRCVEN * C6_QTDVEN                "
	cQuery += "         ELSE                                  "
	cQuery += "          C6_XPRUNIT * C6_QTDVEN               "
	cQuery += "       END) END) AS TOTPED,                    "
EndIf //SSI-123499 - Vagner Almeida - 16/09/2021 

cQuery+="          SUM("
cQuery+="          C6_XCUSTO * C6_QTDVEN  "
cQuery+="       ) AS CUSTPED, "

cQuery += "       (SELECT SUM(C6_QTDVEN * (CASE           "
cQuery += "                     WHEN C5_XOPER = '07' THEN "
cQuery += "                      C6_PRCVEN   "
cQuery += "                     ELSE         "
cQuery += "                      C6_XPRUNIT  "
cQuery += "                   END))        "
cQuery += "          FROM SIGA."+RETSQLNAME("SC6")+" SC6 "
cQuery += "         WHERE D_E_L_E_T_ = ' ' "
cQuery += "           AND C6_FILIAL = '"+xFilial("SC6")+"' "
cQuery += "           AND C6_NUM = C5_NUM  "
cQuery += "           AND C6_PRODUTO LIKE '407095%') TERC, "
cQuery += "       C5_XMIX,                             "
cQuery += "       C5_XENTREF,                          "
cQuery += "       C5_XOPER,                            "
cQuery += "       sum((select SUM(B2_QATU)             "
cQuery += "             from SIGA."+RETSQLNAME("SB2")+" SB2 "
cQuery += "            WHERE D_E_L_E_T_ = ' '          "
cQuery += "              AND B2_QATU > 0               "
cQuery += "              AND B2_COD = C6_PRODUTO       "
cQuery += "              AND B2_LOCAL = '18')) QTDEST, "
cQuery += "       C5_XESTCAN, C5_XUNORI, C5_XPEDCLX,   "
If MV_PAR13 = 2 .Or.	mv_par18	=	2  .or. mv_par20 = 2
	cQuery += " C6_PRODUTO, C6_DESCRI, C6_QTDVEN, BM_XSUBGRU, "
	cQuery += " (CASE WHEN B1_XMODELO = ' ' THEN 'NAO CADASTRADO' ELSE B1_XMODELO END) B1_XMODELO, B1_XMED,B1_XPERSON, "
Endif
If MV_PAR43 = 2
	cQuery += " ID_SISLOJA, "
EndIf
/* SSI 113374 */
If MV_PAR48 = 2
	cQuery += "C5_XTALSAC, "
EndIf
/* SSI 113374 */

cQuery += "     ' ' ENDENT, C5_XNICHO  "
cQuery += "  FROM SIGA."+RETSQLNAME("SC6")+" SC6, "
cQuery += "       SIGA."+RETSQLNAME("SB1")+" SB1, "
cQuery += "       SIGA.SA2030 SA2, "
cQuery += "       SIGA."+RETSQLNAME("SA3")+" SA3, "
cQuery += "       SIGA."+RETSQLNAME("SC5")+" SC5, "
cQuery += "       SIGA."+RETSQLNAME("SZH")+" SZH, "
cQuery += "       SIGA."+RETSQLNAME("SBM")+" SBM, "
cQuery += "       SIGA.CARTEIRA"+cEmpAnt+"0       "
If MV_PAR43 = 2
	cQuery += ", SIGA.TROCASISLOJA TROCASISLOJA "
EndIf
cQuery += " WHERE B1_GRUPO = BM_GRUPO        "
cQuery += "   AND SC5.R_E_C_N_O_ = REC       "
cQuery += "   AND SA3.A3_COD(+) = C5_VEND1   "
IF !Empty(MV_PAR34)
	cQuery += " AND SA3.A3_GEREN = '"+MV_PAR34+"'"
EndIF
cQuery += "   AND SC5.C5_NUM = C6_NUM        "
If MV_PAR43 = 2
	cQuery += " AND SC5.C5_NUM = TROCASISLOJA.PEDIDO      "
	cQuery += " AND SC5.C5_COTACAO IN ('ORT425','OR425J')      "
EndIf
cQuery += "   AND C5_CLIENTE = C6_CLI        "
cQuery += "   AND C5_LOJACLI = C6_LOJA       "
cQuery += "   AND B1_COD = C6_PRODUTO        "
cQuery += "   AND ZH_CLIENTE(+) = C5_CLIENTE "
cQuery += "   AND ZH_LOJA(+) = C5_LOJACLI    "
cQuery += "   AND ZH_VEND(+) = C5_VEND1      "
cQuery += "   AND ZH_SEGMENT(+) = C5_XTPSEGM "
cQuery += "   AND SA2.A2_COD = C5_CLIENTE  "
cQuery += "   AND SA2.A2_LOJA = C5_LOJACLI "
cQuery += "   AND C5_XEMBARQ = ' '   "
cQuery += "   AND C6_NOTA = ' '      "

*'Pedidos de outras unidades - Márcio Sobreira -----------------------------------------------'*
If MV_PAR41 == 2 // Origem (13)
	cQuery += "   AND C5_XOPER NOT IN ('20', '21', '99') "
Else
	cQuery += "   AND C5_XOPER NOT IN ('13', '20', '21', '99') "
Endif
*'--------------------------------------------------------------------------------------------'*

cQuery += "   AND C5_XACERTO = ' '  "
//LUCIANO - SSI 26736 - Imprimir razoes agrupadas
IF MV_PAR36 <> 2
	cQuery += " AND C5_CLIENTE between '" + MV_PAR01 + "' and '" + MV_PAR03 + "'"
	cQuery += " AND C5_LOJACLI between '" + MV_PAR02 + "' and '" + MV_PAR04 + "'"
ELSE
	cQuery += " AND C5_CLIENTE IN	(SELECT A1_COD "
	cQuery += "							 FROM SIGA."+RetSQLName("SA1")+" SA11 "
	cQuery += "							 WHERE A1_XCODGRU IN (SELECT A1_XCODGRU "
	cQuery += "														 FROM SIGA."+RetSQLName("SA1")+" SA12 "
	cQuery += "												       WHERE A1_COD between '" + MV_PAR01 + "' and '" + MV_PAR03 + "'))"
Endif
//Fim - SSI 26736 - Imprimir razoes agrupadas
cQuery += "   AND C5_TABELA BETWEEN '" + MV_PAR06 + "' AND '" + MV_PAR07 + "'"
cQuery += "   AND C5_VEND1 between '" + MV_PAR08 + "' and '" + MV_PAR09 + "'"
cQuery += "   AND C5_TIPO IN ('B','D')    "

If nMV_PAR05 == 1		//SSI 126496
	cQuery += "  AND C5_XTPSEGM IN ('1','5','M','I') "
EndIf

&& Henrique - 08/05/2014 - SSI 1207
&&If MV_PAR05 <> 5 .AND. MV_PAR05 <> 7
&&	cQuery += " AND C5_XTPSEGM = '" + STRZERO(MV_PAR05,1) + "'"
&&Endif
If nMV_PAR05 <> 6 .AND. nMV_PAR05 <> 7 .AND. nMV_PAR05 <> 1
	cSgmto:=IIf(nMV_PAR05==5,"8",StrZero(nMV_PAR05,1))
	cQuery += " AND C5_XTPSEGM = '" + cSgmto + "'"	
Endif
If nMV_PAR05 == 7
	cQuery += " AND C5_XTPSEGM = '2'"
EndIf

If MV_PAR10 = 1
	cQuery += " AND B1_COD NOT LIKE '407095%' "                        // NAO LISTA TERCEIROS
Else
	If MV_PAR12 = 2
		cQuery += " AND B1_COD LIKE '407095%' "                       // LISTA SOMENTE TERCEIROS SE O PARAMETRO 9 FOR IGUAL A 2 (SIM)
	Endif
Endif

IF MV_PAR25 = 2 .OR. MV_PAR26 = 2 .OR. MV_PAR27 = 2 .OR. MV_PAR28 = 2 .OR. MV_PAR29 = 2 .OR. MV_PAR30 = 2 .OR. MV_PAR31 = 2 .OR. MV_PAR32 = 2 .OR. MV_PAR33 = 2
	cOpr := "("
	If MV_PAR25 = 2
		cOpr += "'02','03','17',"                 // TROCAS
	Endif
	If MV_PAR26 = 2
		cOpr += "'01','12','13','10',"            // NORMAL// incluido no dia 27/08/12 - autorizado pelo avilton, charles e crus - WFA
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
		cOpr += "'04',"                           // CONSERTO
	Endif
	If MV_PAR33 = 2
		cOpr += "'06','24','25','27',"            // CONSERTO
	Endif
	
	*'Pedidos de outras unidades - Márcio Sobreira -----------------------------------------------'*
	If MV_PAR41 = 3
		cOpr += "'14',"                 // ORIGEM (DE)
	Endif
	If MV_PAR41 = 2
		cOpr += "'13',"                 // DESTINO (PARA)
	Endif
	*'--------------------------------------------------------------------------------------------------'*
	
	cOpr := SUBSTR(cOpr,1,LEN(COPR)-1)
	cQuery += "AND C5_XOPER IN "+cOpr+")"
ENDIF

If MV_PAR15 = 2
	cQuery += " AND C5_XENTREF <> ' ' AND C5_XTPSEGM != '8'"   	// C/DATA ENTREGA (SITE DEVE SER SEMPRE CONSIDERADO LIVRE
ElseIf MV_PAR15 = 3
	cQuery += " AND (C5_XENTREF = ' ' OR C5_XTPSEGM = '8')"    	// S/DATA ENTREGA (SITE DEVE SER SEMPRE CONSIDERADO LIVRE
Endif      
If mv_par16 = 2
	cQuery += " AND C5_XDTLIB <> ' '  AND C5_XQUAREN != '1' "  	// LIBERADOS
ElseIf mv_par16 = 3
	cQuery += " AND C5_XDTLIB = ' '  AND C5_XQUAREN != '1' "   	// NAO LIBERADOS
ElseIf mv_par16 = 4
	cQuery += " AND C5_XQUAREN = '1' "							// QUARENTENA
Endif
If mv_par17 = 2
	cQuery += " AND C5_XTPSEGM IN ('3','4') "	 			 			// Só Lojas
ElseIf mv_par17 = 3
	cQuery += " AND C5_XTPSEGM NOT IN ('3','4') "                    		// Sem Lojas
EndIf
If MV_PAR44 == 1
	cQuery += " AND C5_XOPER <> '23'     "
ELSE
	If MV_PAR44 == 3
		cQuery += " AND C5_XOPER = '23'     "
	EndIf
EndIf
cQuery += "   AND SC6.D_E_L_E_T_ = ' '    "
cQuery += "   AND SB1.D_E_L_E_T_ = ' '    "
cQuery += "   AND SA2.D_E_L_E_T_ = ' '    "
cQuery += "   AND SA3.D_E_L_E_T_(+) = ' ' "
cQuery += "   AND SC5.D_E_L_E_T_ = ' '    "
cQuery += "   AND SZH.D_E_L_E_T_(+) = ' ' "
cQuery += "   AND SBM.D_E_L_E_T_ = ' ' "
cQuery += "   AND C6_FILIAL = '"+xFilial("SC6")+"'"
cQuery += "   AND B1_FILIAL = '"+xFilial("SB1")+"'"
cQuery += "   AND SA2.A2_FILIAL = '"+xFilial("SA2")+"'"
cQuery += "   AND A3_FILIAL(+) = '"+xFilial("SA3")+"'"
cQuery += "   AND C5_FILIAL = '"+xFilial("SC5")+"'"
cQuery += "   AND ZH_FILIAL(+) = '"+xFilial("SZH")+"'"
cQuery += "   AND BM_FILIAL = '"+xFilial("SBM")+"'"

cQuery += "   AND C5_XNICHO BETWEEN '"+mv_par46+"' AND '"+mv_par47+"' "

If MV_PAR43 = 2
	cQuery += "   AND TROCASISLOJA.UNIDADE(+) = '" + cEmpAnt + "'"
	cQuery += "   AND TROCASISLOJA.FILIAL(+) = '02' "
	cQuery += "   AND TROCASISLOJA.LOJA_COD(+) = C5_CLIENTE "
EndIf
cQuery += " GROUP BY SA2.A2_COD, SA2.A2_LOJA, SA2.A2_NOME, SA2.A2_MUN, SA2.A2_BAIRRO, ZH_ITINER, C5_VEND1, A3_NREDUZ, C5_NUM, C5_TABELA, C5_XOPER, C5_EMISSAO, C5_XPERENT, "
cQuery += "          C5_XDTLIB, C5_XTPSEGM, C5_XNPVORT, C5_XEMBARQ, C5_XENTREG, C5_XENTREF, C5_XMIX, C5_XOPER, C5_CLIENTE, "
cQuery += "          C5_XESTCAN, C5_XUNORI, C5_XPEDCLX, C6_PRODUTO, C6_DESCRI, C6_QTDVEN, B1_XMODELO, C5_XEMBARQ, BM_XSUBGRU, B1_XPERSON, "
cQuery += "          B1_XMED, C5_XENTREG, C5_XENTREF, C5_XOPER , C5_XNICHO "

If MV_PAR43 = 2
	cQuery += ", ID_SISLOJA "
EndIf
/* SSI 113374 */
If MV_PAR48 = 2
	cQuery += " , C5_XTALSAC "
EndIf
/* SSI 113374 */

If mv_par16 = 3
//	cQuery += "ORDER BY C5_XUNORI, C5_EMISSAO ASC "
	If mv_par21==2 
		cQuery += "ORDER BY C5_XUNORI, A3_NREDUZ, ORDT, DIAS DESC "  		// Joni Fujiyama - 13/08/2020
	ELSE
		cQuery += "ORDER BY C5_XUNORI, C5_EMISSAO ASC " 						// Joni Fujiyama - 13/08/2020
	ENDIF
Else
	If mv_par21==2 .AND. mv_par22 ==1
//		cQuery += "ORDER BY ORDT, DIAS DESC, C5_XUNORI, A3_NREDUZ "  			// Joni Fujiyama - 13/08/2020
		cQuery += "ORDER BY C5_XUNORI, A3_NREDUZ, ORDT, DIAS DESC "
	Elseif mv_par21==1 .AND. mv_par22 ==2 
		cQuery += "ORDER BY ORDT, C5_XUNORI, ZONAV, DIAS DESC "  				// Joni Fujiyama - 13/08/2020
//		cQuery += "ORDER BY C5_XUNORI, ZONAV, ORDT, DIAS DESC "
	ElseIf  mv_par21==2 .AND. mv_par22 ==2 
//		cQuery += "ORDER BY ORDT, DIAS DESC, C5_XUNORI, ZONAV, A3_NREDUZ"  		// Joni Fujiyama - 13/08/2020
		cQuery += "ORDER BY C5_XUNORI, ZONAV, A3_NREDUZ, ORDT, DIAS DESC "
	Else
		cQuery += "ORDER BY ORDT, DIAS DESC, C5_XUNORI "  						// Joni Fujiyama - 13/08/2020
//		cQuery += "ORDER BY C5_XUNORI, ORDT, DIAS DESC "
	Endif
EndIf

If	MV_PAR14	=	1
	cQuery += ", C5_NUM DESC"
Else  
	If	MV_PAR14	=	1
		//		cQuery += ", "+Iif(MV_PAR14 = 2,"SA1E.A1_NOME","SA1.A1_NOME")+",C5_NUM DESC"
	Else
		cQuery += ",A1_BAIRRO,C5_NUM DESC"
	Endif
Endif

memowrit("c:\ortr077.sql",cQuery)
If Select("TSC5") > 0
	dbSelectArea("TSC5")
	TSC5->(DbCloseArea())
EndIf
TCQUERY cQuery ALIAS "TSC5" NEW

DbSelectArea("TSC5")
If !_lRpc
	ProcRegua(RecCount())
Endif

_cVend     := TSC5->C5_VEND1
_cVendedor := TSC5->C5_VEND1 + "-" + TSC5->A3_NREDUZ
_cRoteiro  := TSC5->ZH_ITINER
cAuxNomV   := TSC5->A3_NREDUZ
nGCli      := 0
nVTotPed   := 0
nVTotPedB  := 0
nVTotSimBA := 0 //SSI-123499 - Vagner Almeida - 20/09/2021
nTot_D     := 0
nTot_B     := 0
nTot_T     := 0
nTot_N     := 0
nTot_NBA   := 0
nTotLE     := 0
nTotVI 	   := 0
nTot_C     := 0
nTotPed    := 0
nTotEsp    := 0
nTotEspB   := 0
nTotCEnt   := 0
nTotRP     := 0
nPed       := 0   // total geral de pedidos
nPedBA     := 0   // total geral de pedidos da Bahia
nTroc      := 0   // total geral de trocas
nTrocM8    := 0   // trocas com mais de 8 dias
nVendM8    := 0   // vendas com mais de 8 dias
nVendM15   := 0   // vendas com mais de 15 dias
nATrEnt    := 0   // atraso na entrega
nATrLib    := 0   // atraso na liberacao
nTotNFat   := 0   // total nao faturado
x := 0

cOpl       := " "
cExcl	   := " "	

nLin := fImpCab("1",.T., oPrn)

Set Century Off

Do While TSC5->( !Eof() )
	If !_lRpc
		IncProc()
	endif
	_nIndic += 1
	
	if TSC5->TOTPED = 0
		DbSelectArea("TSC5")
		TSC5->( dbskip() )
		Loop
	endif
	
	If MV_PAR11 = 2 		//.and. DDATABASE-STOD(C5_EMISSAO) = 0             				// somente em atraso
//		IF TSC5->( MV_PAR14 = 2 .AND. DDATABASE-STOD(C5_EMISSAO) <= Val(mv_par24) )			// Joni Fujiyama - Acesso: 17/08/2020 
		IF TSC5->( MV_PAR14 = 2 .AND. DIAS <= Val(mv_par24) ) 
			DbSelectArea("TSC5")
			TSC5->( dbskip() )
			Loop
		Endif
		
		IF TSC5->( C5_XOPER == "02" .OR. C5_XOPER == "03" .OR. C5_XOPER == "17" )
//			IF TSC5->( DDATABASE-STOD(C5_EMISSAO) <= Val(mv_par24) )						// Joni Fujiyama - Acesso: 17/08/2020
			IF TSC5->DIAS <= Val(mv_par24) 
				DbSelectArea("TSC5")
				TSC5->( dbskip() )
				Loop
			ENDIF
		ELSE
//			IF TSC5->( DDATABASE-STOD(C5_EMISSAO) <= Val(mv_par24) ) //< 15					// Joni Fujiyama - Acesso: 17/08/2020
			IF TSC5->DIAS <= Val(mv_par24)  
				DbSelectArea("TSC5")
				TSC5->( dbskip() )
				Loop
			ENDIF
		ENDIF
	Endif
	
	DbSelectArea("TSC5")
	
	cCdcm := " "
	
	IF TSC5->C5_XOPER = '02'		.Or.	TSC5->C5_XOPER = '03'	.Or.	TSC5->C5_XOPER = '17'
		IF ALLTRIM(TSC5->A1_XMOTBLQE) == '02'
			cCdcm := "R/"
		ENDIF
	ELSE
		IF ALLTRIM(TSC5->A1_XMOTBLQ) == '02'
			cCdcm := "R/"
		ENDIF
	ENDIF
	
	
	IF TSC5->C5_XDTLIB = " "
		
		cCob := ALLTRIM(TSC5->REGCOB)
		ccom := ALLTRIM(TSC5->REGCOM)
		
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
	If MV_PAR43 = 2
		_cAssTec := AllTrim(Str(TSC5->ID_SISLOJA))
	Else
		_cAssTec := ""
	EndIf
	// SSI 30208
	/* SSI 113374 */
	If MV_PAR48 = 2
		_cIDOrt := AllTrim(TSC5->C5_XTALSAC)
	Else
		_cIDOrt := ""
	EndIf
	/* SSI 113374 */
	nPeso := FscGetPeso(cNum)
	nMix  := FscGetMix(cNum)
	//--
	cPOrt   := TSC5->C5_XNPVORT
	cOper   := BuscStat(TSC5->C5_XOPER)
	dLib    := TSC5->C5_XDTLIB
	cNomV   := TSC5->A3_NREDUZ
	dEstCan := TSC5->C5_XESTCAN
    cOpl    := TSC5->PEDIDO
    cExcl   := TSC5->A1_XCLIEXC
	
	If TSC5->C5_XOPER = '02'		.Or.	TSC5->C5_XOPER = '03'	.Or.	TSC5->C5_XOPER = '17'
		cNomC :=	TSC5->A1_NOMEE
	Else
		cNomC :=	TSC5->A1_NOME
	Endif       
	
	IF EMPTY(cOpl)
		cOpl := 'N'
	ELSE 
		cOpl := 'S'
	EndIf
	
	IF EMPTY(cExcl) .OR. TSC5->A1_XCLIEXC = '2'
		cExcl := ' '
	ELSE 
		cExcl := 'S'
	EndIf
	
	If	Empty(cNomC)
		cNomC :=	TSC5->A1_NOME
	Endif
	
	dEmi  := TSC5->C5_EMISSAO
	
	&& Henrique - 28/05/2014 - SSI 1365
	&&	cRota := TSC5->A1_XROTA
	&&	cCid  := Iif(MV_PAR14 = 2,Iif(SM0->M0_CODIGO == "05" .Or. SM0->M0_CODIGO == "15", TSC5->A1_MUN, TSC5->A1_BAIRRO),TSC5->A1_MUN)
	lBahia := iif(TSC5->C5_XUNORI = '07',.T.,.F.) //Alterado - Vinicius Lança - 22/03/2019
	cZN_CIDADE:=Posicione("SZN",1,xFilial("SZN")+TSC5->A1_XCIDADE,"ZN_CIDADE")
	cCid  := Iif(MV_PAR14 = 2,Iif(SM0->M0_CODIGO == "05" .Or. SM0->M0_CODIGO == "15", cZN_CIDADE, TSC5->A1_BAIRRO),cZN_CIDADE)
	cBairr:= TSC5->A1_BAIRRO
	cRota := AllTrim(TSC5->C5_VEND1)+AllTrim(TSC5->ZH_ITINER)
	cZona := AllTrim(TSC5->A1_XROTA)
	cTab  := TSC5->C5_TABELA
	cEntr := TSC5->C5_XENTREG
	cEntrF:= TSC5->C5_XENTREF
	cItin := TSC5->ZH_ITINER
	cZonaV:= TSC5->ZONAV
	nDias := TSC5->DIAS
	
	//  Henrique - 28/05/2014 - SSI 1365
	//	nPos:=ascan(aRota,{|x| x[1]==cZona})
	nPos:=ascan(aRota,{|x| x[1]==cRota})
	if nPos > 0
		cUltEmb:=aRota[nPos,2]
	else
		cUltEmb:=space(08)
	Endif
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
	// Somente pedidos com restricao
	If MV_PAR35 = 2 .and. ("R" $ cLib .Or. "M" $ cLib .Or. "C" $ cLib .Or. "D" $ cLib .Or. "P" $ cLib)
		TSC5->( DbSkip() )
		loop
	EndIf
	
	If MV_PAR35 = 3 .and. !("R" $ cLib .Or. "M" $ cLib .Or. "C" $ cLib .Or. "D" $ cLib .Or. "P" $ cLib)
		TSC5->( DbSkip() )
		loop
	EndIf
	
	//---> inicio ssi 50008  ---  4a.coluna do relátorio (CD/CM) associada com a 3a.coluna (LIB)
	
	//	if cnum = '669706'
	//	   alert (clib + "/" + ccob + "/" + ccom)
	//  endif
	
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
	
	//08/01/2021 - Solicitação de Rubens devido Sr. Julio, de totalizar por Operação - Início
	//Totalizado canal / segmento / Operação 28/01
	_nPosCan := aScan(_aTCSOper,{|x| x[1]==TSC5->C5_XNICHO})
	If _nPosCan == 0		
		aAdd(_aTCSOper,{TSC5->C5_XNICHO}) 	
		aAdd(_aTCSOper[aScan(_aTCSOper,{|x| x[1] == TSC5->C5_XNICHO })],{TSC5->C5_XTPSEGM})
		aAdd(_aTCSOper[aScan(_aTCSOper,{|x| x[1] == TSC5->C5_XNICHO })][2],{TSC5->C5_XOPER,TSC5->TOTPED})
	Else
		_nPosSeg := 0
		For nX := 2 to Len(_aTCSOper[_nPosCan])
			If aScan(_aTCSOper[_nPosCan][nX],TSC5->C5_XTPSEGM) > 0
				_nPosSeg := nX
				Exit
			EndIf
		Next nX
		If _nPosSeg == 0
			aAdd(_aTCSOper[_nPosCan],{TSC5->C5_XTPSEGM})
			For nX := 2 to Len(_aTCSOper[_nPosCan])
				If aScan(_aTCSOper[_nPosCan][nX],TSC5->C5_XTPSEGM) > 0
					_nPosSeg := nX
					Exit
				EndIf
			Next nX
			aAdd(_aTCSOper[_nPosCan][_nPosSeg],{TSC5->C5_XOPER,TSC5->TOTPED})
		Else
			_nPosOp := 0
			For nX := 2 to Len(_aTCSOper[_nPosCan][_nPosSeg])
				If aScan(_aTCSOper[_nPosCan][_nPosSeg][nX],TSC5->C5_XOPER) > 0
					_nPosOp := nX
					Exit
				EndIf
			Next nX
			If _nPosOp == 0
				aAdd(_aTCSOper[_nPosCan][_nPosSeg],{TSC5->C5_XOPER,TSC5->TOTPED})
			Else
				_aTCSOper[_nPosCan][_nPosSeg][_nPosOp][2]:= _aTCSOper[_nPosCan][_nPosSeg][_nPosOp][2]+TSC5->TOTPED
			EndIf
		EndIf
	EndIf	
	
	//08/01/2021 - Solicitação de Rubens devido Sr. Julio, de totalizar por Operação - Início
	//Totalizado segmento / Operação
	_nPosSeg := aScan(_aTSOper,{|x| x[1]==TSC5->C5_XTPSEGM})
	If _nPosSeg == 0		
		aAdd(_aTSOper,{TSC5->C5_XTPSEGM}) 	
		aAdd(_aTSOper[aScan(_aTSOper,{|x| x[1] == TSC5->C5_XTPSEGM })],{TSC5->C5_XOPER,TSC5->TOTPED})
	Else
		_nPosOp := 0
		For nX := 2 to Len(_aTSOper[_nPosSeg])
			If aScan(_aTSOper[_nPosSeg][nX],TSC5->C5_XOPER) > 0
				_nPosOp := nX
				Exit
			EndIf
		Next nX
		If _nPosOp == 0
			aAdd(_aTSOper[_nPosSeg],{TSC5->C5_XOPER,TSC5->TOTPED})
		Else
			_aTSOper[_nPosSeg][_nPosOp][2]:= _aTSOper[_nPosSeg][_nPosOp][2]+TSC5->TOTPED
		EndIf
	EndIf
	
	//Totaliza Operação
	_nPos := aScan(_aTOper,{|x| x[1]==TSC5->C5_XOPER})
	If	_nPos	==	0
		aAdd(_aTOper,{TSC5->C5_XOPER,TSC5->TOTPED})
	Else
		_aTOper[_nPos,2] += TSC5->TOTPED
	EndIf
	//08/01/2021 - Solicitação de Rubens devido Sr. Julio, de totalizar por Operação - Fim

	If MV_PAR13 = 2 .Or. mv_par18 = 2
		DbSelectArea("TSC5")
		Do While TSC5->( !EOF() .and. C5_NUM = cNum )
			
			//Alterado Vincius Lança - 25/03/2019
			if TSC5->C5_XUNORI <> '07'
				
				If !Empty(TSC5->A1_CGC) .And. SubStr(TSC5->C5_VEND1,1,1) == "C"
					_nPos	:=	aScan(_aResumo3,{|x| x[1]==TSC5->C5_VEND1})
					If	_nPos	==	0
						aAdd(_aResumo3,{TSC5->C5_VEND1,PADR(TSC5->A3_NREDUZ,15),TSC5->ESPACO,TSC5->TOTPED})
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
				
				if _nPos = 0
					aAdd(aCliente,{TSC5->A1_COD,TSC5->A1_CGC,TSC5->A1_XTIPO,TSC5->ESPACO,TSC5->TOTPED})
				else
					aCliente[_nPos][5]	:=		aCliente[_nPos][5]	+	TSC5->TOTPED
					aCliente[_nPos][4]	:=		aCliente[_nPos][4]	+	TSC5->ESPACO
				endif
				
				nVTotPed   := nVTotPed + TSC5->TOTPED
			else
				
				If !Empty(TSC5->A1_CGC) .And. SubStr(TSC5->C5_VEND1,1,1) == "C"
					_nPos	:=	aScan(_aResumo3B,{|x| x[1]==TSC5->C5_VEND1})
					If	_nPos	==	0
						aAdd(_aResumo3B,{TSC5->C5_VEND1,PADR(TSC5->A3_NREDUZ,15),TSC5->ESPACO,TSC5->TOTPED})
					Else
						_aResumo3B[_nPos,3]	+=	TSC5->ESPACO
						_aResumo3B[_nPos,4]	+=	TSC5->TOTPED
					EndIf
				EndIf
				
				_nPos	:=	aScan(_aResumoB,{|x| Alltrim(x[1])==Alltrim(cZona+cItin)})
				
				If	_nPos	=	0
					AADD(_aResumoB,{Alltrim(TSC5->A1_XROTA)+Alltrim(TSC5->ZH_ITINER),Alltrim(TSC5->A1_XROTA),Alltrim(TSC5->ZH_ITINER),TSC5->ESPACO,TSC5->TOTPED,Alltrim(TSC5->A1_XROTA)})
				Else
					_aResumoB[_nPos][4]	:=	_aResumoB[_nPos][4]	+	TSC5->ESPACO
					_aResumoB[_nPos][5]	:=	_aResumoB[_nPos][5]	+	TSC5->TOTPED
				Endif
				
				_nPos := aScan(aClienteB,{|x| x[1] == TSC5->A1_COD})
				
				if _nPos = 0
					aAdd(aClienteB,{TSC5->A1_COD,TSC5->A1_CGC,TSC5->A1_XTIPO,TSC5->ESPACO,TSC5->TOTPED})
				else
					aClienteB[_nPos][5]	:=		aClienteB[_nPos][5]	+	TSC5->TOTPED
					aClienteB[_nPos][4]	:=		aClienteB[_nPos][4]	+	TSC5->ESPACO
				endif
				
				nTotEspB    += TSC5->ESPACO
				nVTotPedB   := nVTotPedB + TSC5->TOTPED
			endif
			
			nTotEsp    += TSC5->ESPACO
			nTotPed    += TSC5->TOTPED

			If !Empty(cEntr) .or. !Empty(cEntrF)
				nTotCEnt	+=	TSC5->TOTPED
			Endif
			
			cTpSegm    := TSC5->C5_XTPSEGM
			
			If MV_PAR13 = 2
				//Incrementa Array para impressão dos produtos a cada pedido do relatório
				//IF Ascan(_aProd,LEFT(TSC5->C6_DESCRI,20)) = 0
				//	AADD(_aProd,LEFT(TSC5->C6_DESCRI,20))
				//Endif
				IF Ascan(_aProd,TSC5->C6_DESCRI) = 0
					AADD(_aProd,TSC5->C6_DESCRI)
				Endif
			Endif
			
			If mv_par18 = 2
				//Incrementa Array para impressão do resumo de produtos no fim do relatório
				_nPT	:=	Ascan(_aProdT,{|aVal|aVal[1]==Alltrim(TSC5->C6_PRODUTO)})
				
				IF _nPT = 0
					AADD(_aProdT,{AllTrim(TSC5->C6_PRODUTO),AllTrim(TSC5->C6_DESCRI),AllTrim(TSC5->B1_XMED),TSC5->C6_QTDVEN, TSC5->QTDEST, {}, dDataBase, dDataBase })
					_nPT	:= Len(_aProdT)
					//					AADD(_aProdT,{AllTrim(TSC5->C6_PRODUTO),AllTrim(TSC5->C6_DESCRI),AllTrim(TSC5->B1_XMED),TSC5->C6_QTDVEN, TSC5->SUBG, TSC5->MODELO})
				Else
					_aProdT[_nPT][4]	+=	TSC5->C6_QTDVEN
				Endif
				
				If AScan(_aProdT[_nPT][6], TSC5->C5_NUM) == 0
					aAdd(_aProdT[_nPT][6], TSC5->C5_NUM)
				EndIf
				
				If AllTrim(TSC5->C5_XOPER) $ "03|17" .And. !Empty(SToD(TSC5->C5_EMISSAO)) .And. SToD(TSC5->C5_EMISSAO) < _aProdT[_nPT][7]
					_aProdT[_nPT][7]	:= SToD(TSC5->C5_EMISSAO)
				EndIf
				
				If AllTrim(TSC5->C5_XOPER) $ "01" .And. !Empty(SToD(TSC5->C5_EMISSAO)) .And. SToD(TSC5->C5_EMISSAO) < _aProdT[_nPT][8]
					_aProdT[_nPT][8]	:= SToD(TSC5->C5_EMISSAO)
				EndIf
			Endif
			
			If /*mv_par18 = 2 .AND.*/ MV_PAR11 = 2 //.AND. DDATABASE-STOD(C5_EMISSAO) <= Val(mv_par24)
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
			if mv_par20 = 2
				//Incrementa array para impressao da Listagem de Segmentos
				_nSeg	:= Ascan(_aSegmento,{|aVal|aVal[1]==Alltrim(TSC5->BM_XSUBGRU)})
				_nMod	:= Ascan(_aModelos,{|aVal|aVal[1]==Alltrim(TSC5->B1_XMODELO)})
				_nSegM	:= Ascan(_aSegFiMix,{|aVal|aVal[1]==Alltrim(TSC5->A1_XTIPO)})
				
				if _nSegM = 0
					AADD(_aSegFiMix,{AllTrim(TSC5->A1_XTIPO),AllTrim(posicione("SZA",1,xFilial("SZA")+TSC5->A1_XTIPO,"ZA_DESC" )),TSC5->C6_QTDVEN,TSC5->TOTPED, TSC5->C5_XMIX})
				else
					_aSegFiMix[_nSegM][3] += TSC5->C6_QTDVEN
					_aSegFiMix[_nSegM][4] += TSC5->TOTPED
					_aSegFiMix[_nSegM][5] += TSC5->CUSTPED // MIX
				endif
				
				if _nSeg = 0
					AADD(_aSegmento,{AllTrim(TSC5->BM_XSUBGRU),AllTrim(posicione("SX5",1,xFilial("SX5")+"ZA"+TSC5->BM_XSUBGRU,"X5_DESCRI" )),TSC5->C6_QTDVEN,TSC5->TOTPED})
				else
					_aSegmento[_nSeg][3] += TSC5->C6_QTDVEN
					_aSegmento[_nSeg][4] += TSC5->TOTPED
				endif
				
				if _nMod = 0
					AADD(_aModelos,{AllTrim(TSC5->B1_XMODELO),AllTrim(posicione("SX5",1,xFilial("SX5")+"ZD"+TSC5->B1_XMODELO,"X5_DESCRI" )),TSC5->C6_QTDVEN,TSC5->TOTPED})
				else
					_aModelos[_nMod][3] += TSC5->C6_QTDVEN
					_aModelos[_nMod][4] += TSC5->TOTPED
				endif
			endif
			
			//Calculo do total das carteiras por perido: 30, 30 e 60 e maior que 60
			nTotDias:= STOD(TSC5->C5_XENTREF) - DDATABASE
			xOper:= TSC5->C5_XOPER
			If TSC5->C5_XTPSEGM == '2'
				aDistSeg[1] += TSC5->TOTPED
			ElseIf TSC5->C5_XTPSEGM ==  '1'
				aDistSeg[2] += TSC5->TOTPED
			ElseIf TSC5->C5_XTPSEGM == '3' .Or. TSC5->C5_XTPSEGM == '4'
				aDistSeg[3] += TSC5->TOTPED
			ElseIf TSC5->C5_XTPSEGM == '8'
				aDistSeg[4] += TSC5->TOTPED
			Else
				aDistSeg[5] += TSC5->TOTPED
			EndIf
			if (nTotDias <= 30) //.and. (xOper=='01' .or. xOper=='04' .or. xOper=='13' ))
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
			elseif (nTotDias > 30 .and. nTotDias<=60)//  .and. (xOper=='01' .or. xOper=='04' .or. xOper=='13' ))
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
			elseif (nTotDias > 60) //.and. (xOper=='01' .or. xOper=='04' .or. xOper=='13' ))
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
			
			TSC5->( DbSkip() )
		Enddo
		
	Else
		
		DbSelectArea("TSC5")
		Do While TSC5->( !EOF() .and. C5_NUM = cNum )
			
			//Alterado Vincius Lança - 25/03/2019
			if TSC5->C5_XUNORI <> '07'
				
				If !Empty(TSC5->A1_CGC) .And. SubStr(TSC5->C5_VEND1,1,1) == "C"
					_nPos	:=	aScan(_aResumo3,{|x| x[1]==TSC5->C5_VEND1})
					If	_nPos	==	0
						aAdd(_aResumo3,{TSC5->C5_VEND1,PADR(TSC5->A3_NREDUZ,15),TSC5->ESPACO,TSC5->TOTPED})
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
				if _nPos = 0
					aAdd(aCliente,{TSC5->A1_COD,TSC5->A1_CGC,TSC5->A1_XTIPO,TSC5->ESPACO,TSC5->TOTPED})
				else
					aCliente[_nPos][5]	:= 	aCliente[_nPos][5]		+	TSC5->TOTPED
					aCliente[_nPos][4]	:=	aCliente[_nPos][4]		+	TSC5->ESPACO
				endif
				
				nTotEsp  += TSC5->ESPACO
				nVTotPed  := nVTotPed + TSC5->TOTPED
			else
				
				If !Empty(TSC5->A1_CGC) .And. SubStr(TSC5->C5_VEND1,1,1) == "C"
					_nPos	:=	aScan(_aResumo3B,{|x| x[1]==TSC5->C5_VEND1})
					If	_nPos	==	0
						aAdd(_aResumo3B,{TSC5->C5_VEND1,PADR(TSC5->A3_NREDUZ,15),TSC5->ESPACO,TSC5->TOTPED})
					Else
						_aResumo3B[_nPos,3]	+=	TSC5->ESPACO
						_aResumo3B[_nPos,4]	+=	TSC5->TOTPED
					EndIf
				EndIf
				
				_nPos	:=	aScan(_aResumoB,{|x| Alltrim(x[1])==Alltrim(cZona+cItin)})
				
				If	_nPos	=	0
					AADD(_aResumoB,{Alltrim(TSC5->A1_XROTA)+Alltrim(TSC5->ZH_ITINER),Alltrim(TSC5->A1_XROTA),Alltrim(TSC5->ZH_ITINER),TSC5->ESPACO,TSC5->TOTPED,Alltrim(TSC5->A1_XROTA)})
				Else
					_aResumoB[_nPos][4]	:=	_aResumoB[_nPos][4]	+	TSC5->ESPACO
					_aResumoB[_nPos][5]	:=	_aResumoB[_nPos][5]	+	TSC5->TOTPED
				Endif
				_nPos := aScan(aClienteB,{|x| x[1] == TSC5->A1_COD})
				if _nPos = 0
					aAdd(aClienteB,{TSC5->A1_COD,TSC5->A1_CGC,TSC5->A1_XTIPO,TSC5->ESPACO,TSC5->TOTPED})
				else
					aClienteB[_nPos][5]	:= 	aClienteB[_nPos][5]		+	TSC5->TOTPED
					aClienteB[_nPos][4]	:=	aClienteB[_nPos][4]		+	TSC5->ESPACO
				endif
				
				nTotEspB  += TSC5->ESPACO
				nVTotPedB  := nVTotPedB + TSC5->TOTPED
				
			endif
			//Fim Alteração - Vinicius Lança
			
			nTotPed  += TSC5->TOTPED
			
			If !Empty(cEntr) .or. !Empty(cEntrF)
				nTotCEnt	+=	TSC5->TOTPED
			Endif
			
			cTpSegm    := TSC5->C5_XTPSEGM
			
			//Calculo do total das carteiras por perido: 30, 30 e 60 e maior que 60
			nTotDias:= STOD(TSC5->C5_XENTREF) - DDATABASE
			xOper:= TSC5->C5_XOPER
			
			if (nTotDias <= 30)// .and. (xOper=='01' .or. xOper=='04' .or. xOper=='13' ))
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
			elseif ((nTotDias > 30 .and. nTotDias<=60))//  .and. (xOper=='01' .or. xOper=='04' .or. xOper=='13' ))
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
			elseif (nTotDias > 60)// .and. (xOper=='01' .or. xOper=='04' .or. xOper=='13' ))
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
			
			DbSelectArea("TSC5")
			TSC5->( dbskip() )
			
		EndDo
	Endif
	
	If nLin > 2300
		nLin := fImpCab("1",.F.,oPrn)
	EndIf
	
	// Imprime o total por vendendor
	If MV_PAR21 = 2
		If cAuxNomV <>  cNomV
			nLin += nEsp
			oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:GetWidth()-50 )
			oPrn:Say(nLin,0060,"TOTAL VENDEDOR "+cAuxNomV+" ..............................................................................................................." + TRANSFORM(nVTotVend,"@E 99,999,999.99")+SPACE(15)+"TOTAL ESPACO: "+TRANSFORM(nVTotEsp,"@E 99,999,999.99"), oFont2)
			nLin += nEsp*2
			cAuxNomV := cNomV
			nVTotVend:= nTotPed
			nVTotEsp:=nTotEsp
		Else
			nVTotVend+= nTotPed
			nVTotEsp+=nTotEsp
		EndIf
	EndIf
	
	if lBahia .and. lpag
		If !_lRpc
			oPrn:Box(nLin-5,0050, nLin-5+50, oPrn:GetWidth()-50 )
			oPrn:Say(nLin,0060,"TOTAL GERAL            ..........................................................................................",oFont2)
			oPrn:Say(nLin,2275,TRANSFORM(nVTotPed,"@E 99,999,999.99"),oFont2)
			IF MV_PAR37 <> 1
				oPrn:Say(nLin,3000,Transform(nTotPeso,"@E 999,999.99"), oFont2)
			EndIf
			
			//Pula pagina para bahia
			nLin := fImpCab("1", .F., oPrn)
			lpag := .F.
		Endif
	endif
	If !_lRpc
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:GetWidth()-52 )
	endif
	
	// Indice / pedido
	/*
	oPrn:Line(nLin-5,  145, nLin-5+50,  145 ) // INDICE PEDIDO
	oPrn:Line(nLin-5,  200+100, nLin-5+50,  200+100 ) // PEDIDO LIB
	oPrn:Line(nLin-5,  290+100, nLin-5+50,  290+100 ) // LIB CD/CM
	oPrn:Line(nLin-5,  450+120, nLin-5+50,  450+120 ) // CD/CM EMISSAO
	oPrn:Line(nLin-5,  650+100, nLin-5+50,  650+100 ) // EMISSAO LIBERACAO
	oPrn:Line(nLin-5,  850+100, nLin-5+50,  850+100 ) // LIBERACAO REVALID
	oPrn:Line(nLin-5, 1030+090, nLin-5+50, 1030+090 ) // REVALID DIAS
	oPrn:Line(nLin-5, 1123+100, nLin-5+50, 1123+100 ) // DIAS ENTREGA
	oPrn:Line(nLin-5, 1520+100, nLin-5+50, 1520+100 ) // ENTREGA TP
	oPrn:Line(nLin-5, 1585+100, nLin-5+50, 1585+100 ) // TP SEG
	oPrn:Line(nLin-5, 1660+100, nLin-5+50, 1660+100 ) // SEG VEND
	oPrn:Line(nLin-5, 1984-20+090, nLin-5+50, 1984-20+090 ) // VEND CLIENTE
	oPrn:Line(nLin-5, 2265-20+100, nLin-5+50, 2265-20+100 ) // CLIENTE VLR
	oPrn:Line(nLin-5, 2465-20+100, nLin-5+50, 2465-20+100 ) // VLR ZONA
	oPrn:Line(nLin-5, 2812-40-30, nLin-5+50, 2812-40-30 ) // ZONA CIDADE BAIRRO 2852
	oPrn:Line(nLin-5, 2960-40-30, nLin-5+50, 2960-40-30 ) // BAIRRO ULT CARG
	oPrn:Line(nLin-5, 3090-40-30, nLin-5+50, 3090-40-30 ) // ULT.CARG ESPACOS
	oPrn:Line(nLin-5, 3225-45-30, nLin-5+50, 3225-45-30 ) // ESPACOS ROT
	oPrn:Line(nLin-5, 3290-60-30, nLin-5+50, 3290-60-30 ) // ROT TAB
	*/
	If !_lRpc
		oPrn:Line(nLin-5,  145, nLin-5+50,  145 ) // INDICE PEDIDO
		oPrn:Line(nLin-5,  200+100, nLin-5+50,  200+100 ) // PEDIDO LIB
		If MV_PAR43 = 2
			oPrn:Line(nLin-5,  300, nLin-5+50,  300 ) // ASSIST. TECNICA
		EndIf
		/* SSI 113374 */
		If MV_PAR48 = 2
			oPrn:Line(nLin-5,  300+nFatPos, nLin-5+50,  300+nFatPos ) // ID ORTOBOM
		EndIf
		/* SSI 113374 */
		oPrn:Line(nLin-5,  200+100+nFatPos+nFatPosII, nLin-5+50,  200+100+nFatPos+nFatPosII ) // PEDIDO LIB
		oPrn:Line(nLin-5,  290+080+nFatPos+nFatPosII, nLin-5+50,  290+080+nFatPos+nFatPosII ) // LIB CD/CM
		oPrn:Line(nLin-5,  450+040+nFatPos+nFatPosII, nLin-5+50,  450+040+nFatPos+nFatPosII ) // CD/CM EMISSAO
		oPrn:Line(nLin-5,  650+020+nFatPos+nFatPosII, nLin-5+50,  650+020+nFatPos+nFatPosII ) // EMISSAO LIBERACAO
		oPrn:Line(nLin-5,  850-020+nFatPos+nFatPosII, nLin-5+50,  850-020+nFatPos+nFatPosII ) // LIBERACAO REVALID
		oPrn:Line(nLin-5,  980-000+nFatPos+nFatPosII, nLin-5+50,  980-000+nFatPos+nFatPosII ) // REVALID DIAS
		oPrn:Line(nLin-5, 1060+000+nFatPos+nFatPosII, nLin-5+50, 1060+000+nFatPos+nFatPosII ) // DIAS ENTREGA
		oPrn:Line(nLin-5, 1370+000+nFatPos+nFatPosII, nLin-5+50, 1370+000+nFatPos+nFatPosII ) // ENTREGA TP
		oPrn:Line(nLin-5, 1420+010+nFatPos+nFatPosII, nLin-5+50, 1420+010+nFatPos+nFatPosII ) // TP SEG
		oPrn:Line(nLin-5, 1485+000+nFatPos+nFatPosII, nLin-5+50, 1485+000+nFatPos+nFatPosII ) // SEG VEND
		/* SSI 113374 Adicionado If/Else */
		If MV_PAR48 = 2 .and. MV_PAR43 = 2
			oPrn:Line(nLin-5, 1710+000+nFatPos+nFatPosII, nLin-5+50, 1710+000+nFatPos+nFatPosII ) // VEND CLIENTE
		Else		
			oPrn:Line(nLin-5, 1740+000+nFatPos+nFatPosII, nLin-5+50, 1740+000+nFatPos+nFatPosII ) // VEND CLIENTE
		EndIf
		/* SSI 113374 */
		/* SSI 113374 Adicionado If/Else */
		If MV_PAR48 = 2 .and. MV_PAR43 = 2
			oPrn:Line(nLin-5, 1970+000+nFatPos+nFatPosII, nLin-5+50, 1970+000+nFatPos+nFatPosII ) // CLIENTE VLR
		Else		
			oPrn:Line(nLin-5, 2010+000+nFatPos+nFatPosII, nLin-5+50, 2010+000+nFatPos+nFatPosII ) // CLIENTE VLR
		EndIf
		/* SSI 113374 */
		oPrn:Line(nLin-5, 2195+000+nFatPos+nFatPosII, nLin-5+50, 2195+000+nFatPos+nFatPosII ) // VLR ZONA
		oPrn:Line(nLin-5, 2405+000+nFatPos+nFatPosII, nLin-5+50, 2405+000+nFatPos+nFatPosII ) // ZONA CIDADE BAIRRO 2852
		/* SSI 113374 Adicionado If/Else */
		If MV_PAR43 = 2 .and. MV_PAR48 = 2
			oPrn:Line(nLin-5, 2690+000+nFatPos+nFatPosII, nLin-5+50, 2690+000+nFatPos+nFatPosII ) // BAIRRO ULT CARG
		ElseIf MV_PAR43 = 1 .and. MV_PAR48 = 2
			oPrn:Line(nLin-5, 2730+000+nFatPos+nFatPosII, nLin-5+50, 2730+000+nFatPos+nFatPosII ) // BAIRRO ULT CARG
		Else
			oPrn:Line(nLin-5, 2820+000+nFatPos+nFatPosII, nLin-5+50, 2820+000+nFatPos+nFatPosII ) // BAIRRO ULT CARG
		EndIf
		oPrn:Line(nLin-5, 3000+000+nFatPos+nFatPosII, nLin-5+50, 3000+000+nFatPos+nFatPosII ) // ULT.CARG ESPACOS
		/*
		If MV_PAR43 = 1
			oPrn:Line(nLin-5, 3225-45-30+nFatPos+nFatPosII, nLin-5+50, 3225-45-30+nFatPos+nFatPosII ) // ESPACOS ROT
			oPrn:Line(nLin-5, 3240+000+nFatPos+nFatPosII, nLin-5+50, 3240+000+nFatPos+nFatPosII ) // ROT TAB
		EndIf
		*/
		If MV_PAR43 = 1 .and. MV_PAR48 = 1
			oPrn:Line(nLin-5, 3225-45-30+nFatPos+nFatPosII, nLin-5+50, 3225-45-30+nFatPos+nFatPosII ) // ESPACOS ROT
			oPrn:Line(nLin-5, 3240+000+nFatPos+nFatPosII, nLin-5+50, 3240+000+nFatPos+nFatPosII ) // ROT TAB
		EndIf
		oPrn:Line(nLin-5, 3000+000+nFatPos+nFatPosII+320, nLin-5+50, 3000+000+nFatPos+nFatPosII+320 ) // coluna opl
		oPrn:Line(nLin-5, 3000+000+nFatPos+nFatPosII+380, nLin-5+50, 3000+000+nFatPos+nFatPosII+380 ) // coluna Exclusivo
		/*
		//oPrn:Line(nLin-5, 2912-40-30, nLin-5+50, 2912-40-30 ) // ZONA CIDADE ULT.CARG
		oPrn:Line(nLin-5, 2912-40-90, nLin-5+50, 2912-40-90 ) // ZONA CIDADE ULT.CARG
		//oPrn:Line(nLin-5, 3090-40-30, nLin-5+50, 3090-40-30 ) // ULT.CARG ESPACOS
		oPrn:Line(nLin-5, 3090-40-90, nLin-5+50, 3090-40-90 ) // ULT.CARG ESPACOS
		//oPrn:Line(nLin-5, 3248-45-30, nLin-5+50, 3248-45-30 ) // ESPACOS ROT
		oPrn:Line(nLin-5, 3248-45-90, nLin-5+50, 3248-45-90 ) // ESPACOS ROT
		//oPrn:Line(nLin-5, 3240, nLin-5+50, 3240 ) // ROT TAB
		oPrn:Line(nLin-5, 3298-45-90, nLin-5+50, 3298-45-90 ) // ROT TAB
		*/
		
		//oPrn:Line(nLin-5, 2852-40-30, nLin-5+50, 2852-40-30 ) // NOVA LINHA BAIRRO
		//oPrn:Line(nLin-5, 3060-40-30, nLin-5+50, 3060-40-30 ) // ZONA CIDADE ULT.CARG
		//oPrn:Line(nLin-5, 3220-40-30, nLin-5+50, 3220-40-30 ) // ULT.CARG ESPACOS
		//oPrn:Line(nLin-5, 3380-45-30, nLin-5+50, 3380-45-30 ) // ESPACOS ROT
		//oPrn:Line(nLin-5, 3460-60-30, nLin-5+50, 3460-60-30 ) // ROT TAB
		
		//oPrn:Line(nLin-5, 3163, nLin-5+50, 3240 ) // BAIRRO
		
		aDetalhe  := {} //SSI-123386 - Vagner Almeida - 30/08/2021

		//oPrn:Say ( nLin, 60,"******   S          19/04/13  19/04/13 19/04/13  25  08/05/13 a 08/05/13  N  3  ADERVAL PALOMBO ORTOMART COMER 12.329,73 000007-RIO DE JANEIRO 16/05/13  24,940  A  017", oFont2)
		oPrn:Say(nLin,0060,Transform(_nIndic, "@E 9999"), oFont2) // num
		oPrn:Say(nLin,0150,cNum+Iif(_lPedProb = .T.,"*",""), oFont2)  //pedido

		aAdd(aDetalhe, Transform(_nIndic, "@E 9999")) 		//SSI-123386 - Vagner Almeida - 30/08/2021
		aAdd(aDetalhe, cNum+Iif(_lPedProb = .T.,"*","") ) 	//SSI-123386 - Vagner Almeida - 30/08/2021


		If MV_PAR43 = 2
			oPrn:Say(nLin,0320,_cAssTec, oFont2)  //Assist. Tecnica                                                                                                                                    
			aAdd(aDetalhe, _cAssTec ) 			  //SSI-123386 - Vagner Almeida - 30/08/2021
		EndIf
		/* SSI 113374 */
		IF MV_PAR48 = 2
			oPrn:Say(nLin,0320+nFatPos,_cIDOrt, oFont2)  //ID Ortobom
			aAdd(aDetalhe, _cIDOrt ) 			  		 //SSI-123386 - Vagner Almeida - 30/08/2021
		EndIf
		/* SSI 113374 */
		oPrn:Say(nLin,0320+nFatPos+nFatPosII,cLib, oFont2)   //lib
		aAdd(aDetalhe, cLib ) 			  		 			 //SSI-123386 - Vagner Almeida - 30/08/2021
		
		IF MV_PAR37 == 1
			oPrn:Say(nLin,0430+nFatPos+nFatPosII,cCdcm, oFont3)  //cd/cm
			aAdd(aDetalhe, cCdcm ) 			  		 			 //SSI-123386 - Vagner Almeida - 30/08/2021
		Else
			oPrn:Say(nLin,0375+nFatPos+nFatPosII,cCdcm+" "+AllTrim(Transform(nMix  ,"@E 9999.99")), oFont3)  //cd/cm
			aAdd(aDetalhe, cCdcm + " " + AllTrim(Transform(nMix,"@E 9999.99") )) 			  		 			 //SSI-123386 - Vagner Almeida - 30/08/2021
		EndIf
		
		oPrn:Say(nLin,0525+nFatPos+nFatPosII,DtoC(STOD(dEmi)), oFont2) //dt emissao
		oPrn:Say(nLin,0685+nFatPos+nFatPosII,DtoC(STOD(dLib)), oFont2) //dt liberação  // 0765
		oPrn:Say(nLin,3335+nFatPos+nFatPosII,cOpl, oFont2) //Operador Logistico
		oPrn:Say(nLin,3415+nFatPos+nFatPosII,cExcl, oFont2) //Cliente Exclusivo S/N
		//SSI-123386 - Vagner Almeida - 30/08/2021 - Inicio		
		aAdd(aDetalhe, DtoC(STOD(dEmi)) )
		aAdd(aDetalhe, DtoC(STOD(dLib)) )
		//SSI-123386 - Vagner Almeida - 30/08/2021 - Final		
		If !empty(dEstCan)
			oPrn:Say(nLin,0844+nFatPos+nFatPosII,DtoC(STOD(dEstCan)), oFont2) // revalid
			aAdd(aDetalhe, DtoC(STOD(dEstCan)) ) 			  		 		  //SSI-123386 - Vagner Almeida - 30/08/2021
		//SSI-123386 - Vagner Almeida - 30/08/2021 - Inicial
		Else
			aAdd(aDetalhe, "")
		//SSI-123386 - Vagner Almeida - 30/08/2021 - Final
		Endif
		
		If MV_PAR16 = 3 // Solicitação do sr. Sergio - SSI 3966 em 13/08/14
			If empty(cEntr)
				If Empty(dEstCan)
					oPrn:Say(nLin,0990+nFatPos+nFatPosII,Transform(ddatabase - STOD(dEmi), "@E 9999"), oFont2)
					aAdd(aDetalhe, Transform(ddatabase - STOD(dEmi), "@E 9999") ) 			  		 		  //SSI-123386 - Vagner Almeida - 30/08/2021
				Else
					oPrn:Say(nLin,0990+nFatPos+nFatPosII,Transform(ddatabase - STOD(dEstCan), "@E 9999"), oFont2)
					aAdd(aDetalhe, Transform(ddatabase - STOD(dEstCan), "@E 9999") ) 		  		 		  //SSI-123386 - Vagner Almeida - 30/08/2021
				Endif
			Else
				_nTotDias := iif(ddatabase - STOD(cEntr) < 0,0,ddatabase - STOD(cEntr))
				oPrn:Say(nLin,0990+nFatPos+nFatPosII,Transform(_nTotDias, "@E 9999"), oFont2) // Márcio Sobreira - Solicitação Santanna - 30-05-19
				aAdd(aDetalhe, Transform(_nTotDias, "@E 9999") ) 		    		 		  //SSI-123386 - Vagner Almeida - 30/08/2021
			Endif
			
		Else
			oPrn:Say(nLin,0990+nFatPos+nFatPosII,Transform(iif(nDias < 0,0,nDias), "@E 9999"), oFont2)
			aAdd(aDetalhe, Transform(iif(nDias < 0,0,nDias), "@E 9999")) 		    		 //SSI-123386 - Vagner Almeida - 30/08/2021
		Endif
		/* SSI 113374 Adicionado If/Else */
		/*
		If mv_par22 ==2 //.AND. !EMPTY(mv_par23)
			
			//If cEntr < dtos(mv_par23)
			//	oPrn:Say(nLin,1225,"LIVRE", oFont2)
			//Else
			oPrn:Say(nLin,1080+nFatPos+nFatPosII,DtoC(STOD(cEntr)), oFont3)
			If !empty(cEntr)
				oPrn:Say(nLin,1200+nFatPos+nFatPosII,"a", oFont3)
				oPrn:Say(nLin,1230+nFatPos+nFatPosII,Iif(Empty(cEntrF),"LIVRE",DtoC(STOD(cEntrF))), oFont3)
			EndIf
			//Endif
		Else
			oPrn:Say(nLin,1080+nFatPos+nFatPosII,Iif(Empty(cEntr),"LIVRE",DtoC(STOD(cEntr))), oFont3)
			
			If !empty(cEntr)
				oPrn:Say(nLin,1200+nFatPos+nFatPosII,"a", oFont3)
				oPrn:Say(nLin,1230+nFatPos+nFatPosII,Iif(Empty(cEntrF),"LIVRE",DtoC(STOD(cEntrF))), oFont3)
			EndIf
		EndIf
		*/
		If MV_PAR49 = 1
			If mv_par22 ==2 //.AND. !EMPTY(mv_par23)
				
				//If cEntr < dtos(mv_par23)
				//	oPrn:Say(nLin,1225,"LIVRE", oFont2)
				//Else
				oPrn:Say(nLin,1080+nFatPos+nFatPosII,DtoC(STOD(cEntr)), oFont3)
				If !empty(cEntr)
					oPrn:Say(nLin,1200+nFatPos+nFatPosII,"a", oFont3)
					oPrn:Say(nLin,1230+nFatPos+nFatPosII,Iif(Empty(cEntrF),"LIVRE",DtoC(STOD(cEntrF))), oFont3)
					aAdd(aDetalhe, DtoC(STOD(cEntr)) + " a " + Iif(Empty(cEntrF),"LIVRE",DtoC(STOD(cEntrF)) )) //SSI-123386 - Vagner Almeida - 30/08/2021
				//SSI-123386 - Vagner Almeida - 30/08/2021 - Inicio
				Else
					aAdd(aDetalhe, DtoC(STOD(cEntr)) ) 		    		 		  
				//SSI-123386 - Vagner Almeida - 30/08/2021 - Final
				EndIf
				//Endif
			Else
				oPrn:Say(nLin,1080+nFatPos+nFatPosII,Iif(Empty(cEntr),"LIVRE",DtoC(STOD(cEntr))), oFont3)
				
				If !empty(cEntr)
					oPrn:Say(nLin,1200+nFatPos+nFatPosII,"a", oFont3)
					oPrn:Say(nLin,1230+nFatPos+nFatPosII,Iif(Empty(cEntrF),"LIVRE",DtoC(STOD(cEntrF))), oFont3)
					aAdd(aDetalhe, DtoC(STOD(cEntr)) + " a " + Iif(Empty(cEntrF),"LIVRE",DtoC(STOD(cEntrF)) )) //SSI-123386 - Vagner Almeida - 30/08/2021
				//SSI-123386 - Vagner Almeida - 30/08/2021 - Inicio
				Else
					aAdd(aDetalhe, Iif(Empty(cEntr),"LIVRE",DtoC(STOD(cEntr)))) 		    		 		  
				//SSI-123386 - Vagner Almeida - 30/08/2021 - Final
				EndIf
			EndIf
		Else
			oPrn:Say(nLin,1080+nFatPos+nFatPosII,iif(Empty(cEntr),"__/__/__",DtoC(STOD(cEntr))), oFont3)
			aAdd(aDetalhe, iif(Empty(cEntr),"__/__/__",DtoC(STOD(cEntr)) )) 		    		 		  //SSI-123386 - Vagner Almeida - 30/08/2021
		EndIf
		/* SSI 113374 */
		oPrn:Say(nLin,1390+nFatPos+nFatPosII,cOper, oFont2)
		oPrn:Say(nLin,1450+nFatPos+nFatPosII,cTpSegm, oFont2)
		/* SSI 113374 */
		//SSI-123386 - Vagner Almeida - 30/08/2021 - Inicio
		aAdd(aDetalhe, cOper   ) 		    		 		  
		aAdd(aDetalhe, cTpSegm ) 		    		 		  
		//SSI-123386 - Vagner Almeida - 30/08/2021 - Final		
		If MV_PAR43 = 2 .and. MV_PAR48 = 2
			oPrn:Say(nLin,1470+nFatPos+nFatPosII,LEFT(cNomV,13), oFont2)
			oPrn:Say(nLin,1740+nFatPos+nFatPosII,LEFT(cNomC,13), oFont2)
			//SSI-123386 - Vagner Almeida - 30/08/2021 - Inicio
			aAdd(aDetalhe, cNomV ) 		    		 		  
			aAdd(aDetalhe, cNomC ) 		    		 		  
			//SSI-123386 - Vagner Almeida - 30/08/2021 - Final		
		Else
			oPrn:Say(nLin,1510+nFatPos+nFatPosII,LEFT(cNomV,13), oFont2)
			oPrn:Say(nLin,1780+nFatPos+nFatPosII,LEFT(cNomC,13), oFont2)
			//SSI-123386 - Vagner Almeida - 30/08/2021 - Inicio
			aAdd(aDetalhe, cNomV ) 		    		 		  
			aAdd(aDetalhe, cNomC ) 		    		 		  
			//SSI-123386 - Vagner Almeida - 30/08/2021 - Final		
		EndIf
		/* SSI 113374 */
		//oPrn:Say(nLin,1510+nFatPos,"VEND", oFont2)

		oPrn:Say(nLin,1992+nFatPos+nFatPosII,Transform(nTotPed,"@E 9,999,999.99"), oFont2, 60, ,1)
		aAdd(aDetalhe, Transform(nTotPed,"@E 9,999,999.99") )	//SSI-123386 - Vagner Almeida - 30/08/2021 		    		 		  

		//Alterado - Vinicius Lança - 22/03/2019
		If lBahia
			nTotPesoB += nPeso
			oPrn:Say ( nLin, 2210+nFatPos+nFatPosII,'BAHIA - ' + substr(Alltrim(cZona),4,3), oFont3)
		Else
			nTotPeso += nPeso
			oPrn:Say ( nLin, 2210+nFatPos+nFatPosII,substr(Alltrim(cZona),4,3) + "-" + Alltrim(LEFT(cCid,07)), oFont2)
		Endif
		&& Henrique - 28/05/2014 - SSI 1365
		&&	oPrn:Say(nLin,2210,Alltrim(LEFT(cCid,13)), oFont2)
		
		/* SSI 113374 Adicionado If/Else */
		If MV_PAR43 = 2 .and. MV_PAR48 = 2
			oPrn:Say(nLin,2390+nFatPos+nFatPosII, Alltrim(LEFT(cBairr,28)), oFont2) // bairro 2805
		Else
			oPrn:Say(nLin,2420+nFatPos+nFatPosII, Alltrim(LEFT(cBairr,28)), oFont2) // bairro 2805
		EndIf
		
		//SSI-123386 - Vagner Almeida - 30/08/2021 - Inicio
		If lBahia
			aAdd(aDetalhe, 'BAHIA - ' + substr(Alltrim(cZona), 4,3) + "-" + cBairr )
		Else
			aAdd(aDetalhe, AllTrim(cZona) + "-" + AllTrim(cCid) + "-" + AllTrim(cBairr))	
		EndIf
		//SSI-123386 - Vagner Almeida - 30/08/2021 - Final		
		
		/* SSI 113374 */
		/* SSI 113374 Adicionado If/Else */
		If MV_PAR43 = 2 .and. MV_PAR48 = 2
			oPrn:Say(nLin,2730+nFatPos+nFatPosII,DtoC(STOD(cUltEmb)), oFont2)
			aAdd(aDetalhe, DtoC(STOD(cUltEmb)) )	//SSI-123386 - Vagner Almeida - 30/08/2021 		    		 		  
		ElseIf MV_PAR43 = 1 .and. MV_PAR48 = 2
			oPrn:Say(nLin,2770+nFatPos+nFatPosII,DtoC(STOD(cUltEmb)), oFont2)
			aAdd(aDetalhe, DtoC(STOD(cUltEmb)) )	//SSI-123386 - Vagner Almeida - 30/08/2021 		    		 		  
		Else
			oPrn:Say(nLin,2860+nFatPos+nFatPosII,DtoC(STOD(cUltEmb)), oFont2) // 2850			
			aAdd(aDetalhe, DtoC(STOD(cUltEmb)) )	//SSI-123386 - Vagner Almeida - 30/08/2021 		    		 		  
		EndIf
		//2730
		/* SSI 113374 */
		IF MV_PAR37 == 1
			oPrn:Say(nLin,3010+nFatPos+nFatPosII,Transform(nTotEsp,"@E 9,999.99"), oFont2) // 2965
			aAdd(aDetalhe, Transform(nTotEsp,"@E 9,999.99") )	//SSI-123386 - Vagner Almeida - 30/08/2021 		    		 		  
		Else
			oPrn:Say(nLin,3010+nFatPos+nFatPosII,Transform(nPeso  ,"@E 9,999.99"), oFont2)
			aAdd(aDetalhe, Transform(nPeso  ,"@E 9,999.99") )	//SSI-123386 - Vagner Almeida - 30/08/2021 		    		 		  
		EndIf
		//Alterado Vinicius Lança - 26/03/19
		If lBahia
			oPrn:Say(nLin,3180+nFatPos+nFatPosII,"BA", oFont2)// 3165
			aAdd(aDetalhe, "BA" )	//SSI-123386 - Vagner Almeida - 30/08/2021 		    		 		  
		Else
			/* SSI 113374 Adicionado If */
			If MV_PAR48 = 1
				oPrn:Say(nLin,3180+nFatPos+nFatPosII,cItin, oFont2) // 3165
				aAdd(aDetalhe, cItin )	//SSI-123386 - Vagner Almeida - 30/08/2021 		    		 		  
			EndIf
			/* SSI 113374 */
		EndIf
		//Fim
		/* SSI 113374 Adicionado If */
		If MV_PAR48 = 1
			oPrn:Say(nLin,3270+nFatPos+nFatPosII,cTab, oFont2) // 3250
			aAdd(aDetalhe, cTab )	//SSI-123386 - Vagner Almeida - 30/08/2021 		    		 		  
		EndIf
		/* SSI 113374 */
	EndIf

	//Gera Linhas Para Aquivo CSV
	//SSI-123386 - Vagner Almeida - 30/08/2021 - Inicio
	aAdd(aDetalhe, cOpl             )
	aAdd(aDetalhe, cExcl            )
	aAdd(aLinha, aDetalhe)
	//SSI-123386 - Vagner Almeida - 30/08/2021 - Final

	AADD(_aPProd,{ _nIndic,cNum+Iif(_lPedProb = .T.,"*",""),_aProd })
	
	nLin += nEsp
	If lBahia
		nPedBA++ // total geral de pedidos Bahia
	Else
		nPed++ // total geral de pedidos
	EndIf
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
	ElseIf cOper = "N"
		if cTpSegm == "4"
			nTotLe += nTotPed
		else
			IF lBahia
				nTot_NBA += nTotPed
			else
				nTot_N += nTotPed
			endif
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
nLin += nEsp

If nLin + nEsp * 6  > 2300 
	nLin := fImpCab("1",.F.,oPrn)
EndIf
If !_lRpc
	oPrn:Box(nLin-5,0050, nLin-5+50, oPrn:GetWidth()-51 )  
endif
If !_lRpc
	If lBahia
		oPrn:Say(nLin,0060,"TOTAL GERAL BA         ..........................................................................................",oFont2)
		oPrn:Say(nLin,2010,TRANSFORM(nVTotPedB,"@E 99,999,999.99"),oFont2)
		IF MV_PAR37 <> 1
			oPrn:Say(nLin,3000,Transform(nTotPesoB,"@E 999,999.99"), oFont2)
		EndIf
	else
		oPrn:Say(nLin,0060,"TOTAL GERAL            ..........................................................................................",oFont2)
		oPrn:Say(nLin,2010,TRANSFORM(nVTotPed,"@E 99,999,999.99"),oFont2)

		IF MV_PAR37 <> 1
			oPrn:Say(nLin,3000,Transform(nTotPeso,"@E 999,999.99"), oFont2) 
		EndIf
	endif
	
	nLin += nEsp*2
	
	oPrn:Say(nLin,0060,"LEGENDA SEGMENTOS:",oFont2)
	nLin += nEsp
	oPrn:Say(nLin,0060,"1 - INDUSTRIAL | 2 - COMERCIAL  |  3 - LOJAS  |  4 - LOJAS EXCLUSIVAS  |  5 - ORTOCLASS INDUSTRIAL  |  6 - ORTOCLASS COMERCIAL | 8 - VENDA SITE", oFont2)
	nLin += nEsp
	oPrn:Say(nLin,0060,"LEGENDA LIBERAÇÃO:",oFont2)
	nLin += nEsp
	oPrn:Say(nLin,0060,"S - LIBERADO SIM | R - AGUARDANDO LIBERAÇÃO REGIONAL | N - NÃO LIBERADO | M - BLOQUEADO FALTA ENTREGA MALOTE | C - CANCLAMENTO LOJA | D - FALTA DE DOCUMENTO", oFont2)
	nLin += nEsp
	oPrn:Say(nLin,0060,"P - FALTA BALANÇO COM PAGAMENTO EM NOTA PROMISSÓRIA NÃO ASSINADA", oFont2)
	nLin += nEsp
	oPrn:Say(nLin,0060,"LEGENDA TIPO:",oFont2)
	nLin += nEsp
	oPrn:Say(nLin,0060,"N - VENDA | T - TROCA | B - BRINDE | D - DEMONSTRAÇÃO | R - REPOSIÇÃO | C - CONSERTO | Q - VENDA DE INSUMOS | M - MAQUETE", oFont2)
	nLin := nLin + 20
endif
// Imprime os produtos
If MV_PAR13 = 2
	nLin := fImpCab("P", .F., oPrn)
	
	For c	:=	1	To	Len(_aPProd)
		If nLin > 2200
			nLin := fImpCab("P", .F., oPrn)
		Endif
		If !_lRpc
			oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:GetWidth()-52 )  
			oPrn:Line(nLin-5,  145, nLin-5+50,  145 ) // INDICE PEDIDO
			oPrn:Line(nLin-5,  200+100, nLin-5+50,  200+100 ) // PEDIDO LIB
			
			oPrn:Say(nLin,0060,Transform(_aPProd[c][1], "@E 9999"), oFont2)
			oPrn:Say(nLin,0150,_aPProd[c][2], oFont2)
		endif
		If MV_PAR13 = 2 .And. Len(_aPProd[c][3]) > 0
			If !_lRpc
				oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:GetWidth()-52 ) 
			endif
			_cProds := ""
			If Len(_aPProd[c][3]) < 3
				_cProds := ""
				For a	:=	1	To	Len(_aPProd[c][3])
					_cProds += AllTrim(_aPProd[c][3][a]) + ", "
				Next
				If !_lRpc
					oPrn:Say(nLin,0350,LEFT(AllTrim(_cProds), Len(AllTrim(_cProds))-1), oFont2)
				endif
				nLin += nEsp
			Else
				For a	:=	1	To	Len(_aPProd[c][3])
					_cProds += AllTrim(_aPProd[c][3][a]) + ", "
					nZcont += 1
					
					if nZcont = 3 .or. a == Len(_aPProd[c][3])
						_cProds := AllTrim(_cProds)
						If !_lRpc
							oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:GetWidth()-50 ) 
							oPrn:Say(nLin,0350,LEFT(AllTrim(_cProds), Len(AllTrim(_cProds))-1), oFont2)
						endif
						_cProds := ""
						nZcont 	:= 0
						nLin += nEsp
					EndIf
				Next
			EndIf
		Else
			nLin += nEsp
		Endif
	Next
EndIf

// INICIA OUTRO MODELO

nLin := fImpCab("V", .F., oPrn)
aSort(_aResumo3,,,{|x,y| x[4]>y[4]})
aSort(_aResumo3B,,,{|x,y| x[4]>y[4]})

_nTotEsp:=0
_nTotVal:=0
For c	:=	1	To	Len(_aResumo3)
	
	If nLin > (2200 - 5*nEsp)
		nLin := fImpCab("V",.F.,oPrn)
	Endif
	If !_lRpc
		oPrn:Box( nLin-5,0050,nLin-5+50,1370)
		oPrn:Line(nLin-5,0270,nLin-5+50,0270)
		oPrn:Line(nLin-5,0710,nLin-5+50,0710)
		oPrn:Line(nLin-5,1040,nLin-5+50,1040)
		
		oPrn:Line(nLin-5+50,1430,nLin-5+50,oPrn:GetWidth()-75) 
		
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
If !_lRpc
	oPrn:Box( nLin-5,0050,nLin-5+50,1370)
	oPrn:Say(nLin,0060,"TOTAL..........:", oFont2)
	oPrn:Say(nLin,0765,Transform(_nTotEsp, "@E 9,999,999.999"), oFont2)//TOTAL DOS ESPACOS
	oPrn:Say(nLin,1095,Transform(_nTotVal, "@E 9,999,999.999"), oFont2)//TOTAL DOS VALORES
endif
//Alterado Vincius Lança - 25/03/2019
_nTotEsp:=0
_nTotVal:=0

nLin := fImpCab("VB",.F.,oPrn)

For c	:=	1	To	Len(_aResumo3B)
	
	If nLin > (2200 - 5*nEsp)
		nLin := fImpCab("VB",.F.,oPrn)
	Endif
	If !_lRpc
		oPrn:Box( nLin-5,0050,nLin-5+50,1370)
		oPrn:Line(nLin-5,0270,nLin-5+50,0270)
		oPrn:Line(nLin-5,0710,nLin-5+50,0710)
		oPrn:Line(nLin-5,1040,nLin-5+50,1040)
		
		oPrn:Line(nLin-5+50,1430,nLin-5+50,oPrn:GetWidth()-75) 
		
		//Imprime linha negrito para separar vendedores com menos de 1000 UPME
		If _aResumo3B[c][4] < (1000*nTxUpme)
			If c == 1 .Or. _aResumo3B[c-1][4] > (1000*nTxUpme)
				oPrn:Line(nLin-7,0050,nLin-7,1370)
				oPrn:Line(nLin-3,0050,nLin-3,1370)
			EndIf
		EndIf
		
		If !Empty(_aResumo3B[c][1])
			oPrn:Say(nLin,0060,AllTrim(_aResumo3B[c][1]), oFont2)//C5_VEND1
		Endif
		
		If !Empty(_aResumo3B[c][2])
			oPrn:Say(nLin,0280,AllTrim(_aResumo3B[c][2]), oFont2)//A3_NREDUZ
		Endif
		
		oPrn:Say(nLin,0765,Transform(_aResumo3B[c][3], "@E 9,999,999.999"), oFont2)//TRB->ESPACO
		oPrn:Say(nLin,1095,Transform(_aResumo3B[c][4], "@E 9,999,999.999"), oFont2)//TRB->VALOR
	endif
	_nTotEsp+=_aResumo3B[c][3]
	_nTotVal+=_aResumo3B[c][4]
	
	nLin += nEsp
Next
If !_lRpc
	oPrn:Box( nLin-5,0050,nLin-5+50,1370)
	oPrn:Say(nLin,0060,"TOTAL..........:", oFont2)
	oPrn:Say(nLin,0765,Transform(_nTotEsp, "@E 9,999,999.999"), oFont2)//TOTAL DOS ESPACOS
	oPrn:Say(nLin,1095,Transform(_nTotVal, "@E 9,999,999.999"), oFont2)//TOTAL DOS VALORES
endif
nLin += nEsp * 2
_nTotEsp:=0
_nTotVal:=0

// INICIA OUTRO MODELO -- TOTAL DE ZONA VEND E INTI

nLin := fImpCab("4", .F., oPrn)
aSort(_aResumo,,,{|x,y| x[1]>y[1]})
aSort(aCliente,,,{|x,y| x[5]>y[5]})
//Vinicius Lança - 25/03/2019
aSort(_aResumoB,,,{|x,y| x[1]>y[1]})
aSort(aClienteB,,,{|x,y| x[5]>y[5]})

_nTotEsp:=0
_nTotVal:=0
For c	:=	1	To	Len(_aResumo)
	
	If nLin > 2200
		nLin := fImpCab("4",.F.,oPrn)
	Endif
	If !_lRpc
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:GetWidth()-2140 ) 
		oPrn:Line(nLin-5,  270, nLin-5+50,  270 ) //
		oPrn:Line(nLin-5,  460, nLin-5+50,  460 ) //
		oPrn:Line(nLin-5,  850, nLin-5+50,  850 ) //
		
		If _aResumo[c][2] <> ""
			oPrn:Say(nLin,0060,AllTrim(_aResumo[c][2]), oFont2)//TRB->ZONA
		Endif
		
		If _aResumo[c][3] <> ""
			oPrn:Say(nLin,0325,AllTrim(_aResumo[c][3]), oFont2)//TRB->ITIN
		Endif
		
		oPrn:Say(nLin,0575,Transform(_aResumo[c][4], "@E 9,999,999.999"), oFont2)//TRB->ESPACO
		oPrn:Say(nLin,0975,Transform(_aResumo[c][5], "@E 9,999,999.999"), oFont2)//TRB->VALOR
	endif
	_nTotEsp+=_aResumo[c][4]
	_nTotVal+=_aResumo[c][5]
	
	nLin += nEsp
Next
If !_lRpc
	oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:GetWidth()-2140 ) 
	oPrn:Say(nLin,0060,"TOTAL............:", oFont2)
	oPrn:Say(nLin,3000,Transform(nTotEsp,"@E 9,999.99"), oFont2)
	oPrn:Say(nLin,0975,Transform(_nTotVal, "@E 9,999,999.999"), oFont2)//TOTAL DOS VALORRES
endif
_nTotEsp:=0
_nTotVal:=0

//Alterado Vinicius Lança - 25/03/2019
nLin := fImpCab("4B",.F.,oPrn)

For c	:=	1	To	Len(_aResumoB)
	
	If nLin > 2200
		nLin := fImpCab("4B",.F.,oPrn)
	Endif
	If !_lRpc
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:GetWidth()-2140 ) 
		oPrn:Line(nLin-5,  270, nLin-5+50,  270 ) //
		oPrn:Line(nLin-5,  460, nLin-5+50,  460 ) //
		oPrn:Line(nLin-5,  850, nLin-5+50,  850 ) //
		
		If _aResumoB[c][2] <> ""
			oPrn:Say(nLin,0060,AllTrim(_aResumoB[c][2]), oFont2)//TRB->ZONA
		Endif
		
		If _aResumoB[c][3] <> ""
			oPrn:Say(nLin,0325,AllTrim(_aResumoB[c][3]), oFont2)//TRB->ITIN
		Endif
		
		oPrn:Say(nLin,0575,Transform(_aResumoB[c][4], "@E 9,999,999.999"), oFont2)//TRB->ESPACO
		oPrn:Say(nLin,0975,Transform(_aResumoB[c][5], "@E 9,999,999.999"), oFont2)//TRB->VALOR
	endif
	_nTotEsp+=_aResumoB[c][4]
	_nTotVal+=_aResumoB[c][5]
	
	nLin += nEsp
Next
If !_lRpc
	oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:GetWidth()-2140 ) 
	oPrn:Say(nLin,0060,"TOTAL............:", oFont2)
	oPrn:Say(nLin,3000,Transform(nTotEsp,"@E 9,999.99"), oFont2)
	oPrn:Say(nLin,0975,Transform(_nTotVal, "@E 9,999,999.999"), oFont2)//TOTAL DOS VALORRES
endif
nLin += nEsp * 2
_nTotEsp:=0
_nTotVal:=0

//If !EMPTY(mv_par23)
fEspaco()                // preenche  o array com as zonas de entrega e os espacos
/*
oPrn:Line(nLin  , 50, nLin  , oPrn:GetWidth()-50 )
oPrn:Line(nLin+2, 50, nLin+2, oPrn:GetWidth()-50 )
oPrn:Line(nLin+4, 50, nLin+4, oPrn:GetWidth()-50 )

nLin += nEsp

oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:GetWidth()-950 )
oPrn:Line(nLin-5,  265, nLin-5+50,  265 )
oPrn:Line(nLin-5,  655, nLin-5+50,  655 )
oPrn:Line(nLin-5, 1010, nLin-5+50, 1010 )
oPrn:Line(nLin-5, 1390, nLin-5+50, 1390 )
oPrn:Line(nLin-5, 1700, nLin-5+50, 1700 )
oPrn:Line(nLin-5, 2060, nLin-5+50, 2060 )
oPrn:Line(nLin-5, 2400, nLin-5+50, 2400 )

oPrn:Say ( nLin   , 60,"ZONA           ESPAÇOS LIVRE      VALOR LIVRE    ESPAÇOS FUTURO     VALOR FUTURO     ESPAÇOS TOTAL     VALOR TOTAL     DIAS", oFont2)

nLin += nEsp
*/
//Total de espaços
nLin := fImpCab("9",.F.,oPrn)
aSort(_aResumo2,,,{|x,y| x[1]<y[1]})
aSort(_aResumo2B,,,{|x,y| x[1]<y[1]})

For d	:=	1	To	Len(_aResumo2)
	If nLin > 2200
		nLin := fImpCab("9",.F.,oPrn)
	Endif
	If !_lRpc
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:GetWidth()-825) 
		oPrn:Line(nLin-5,  265, nLin-5+50,  265 )
		oPrn:Line(nLin-5,  655, nLin-5+50,  655 )
		oPrn:Line(nLin-5, 1010, nLin-5+50, 1010 )
		oPrn:Line(nLin-5, 1390, nLin-5+50, 1390 )
		oPrn:Line(nLin-5, 1700, nLin-5+50, 1700 )
		oPrn:Line(nLin-5, 2060, nLin-5+50, 2060 )
		oPrn:Line(nLin-5, 2400, nLin-5+50, 2400 )
		
		oPrn:Say(nLin,0060,Iif(EMPTY(_aResumo2[d][1]), " ", _aResumo2[d][1]), oFont2)
		oPrn:Say(nLin,0375,Transform(_aResumo2[d][4], "@E 99,999,999.99"), oFont2)
		oPrn:Say(nLin,0730,Transform(_aResumo2[d][5], "@E 99,999,999.99"), oFont2)
		oPrn:Say(nLin,1105,Transform(_aResumo2[d][6], "@E 99,999,999.99"), oFont2)
		oPrn:Say(nLin,1420,Transform(_aResumo2[d][7], "@E 99,999,999.99"), oFont2)
		
		oPrn:Say(nLin,1775,Transform(_aResumo2[d][2], "@E 99,999,999.99"), oFont2)
		oPrn:Say(nLin,2125,Transform(_aResumo2[d][3], "@E 99,999,999.99"), oFont2)
		oPrn:Say(nLin,2475,Transform( (dDatabase - stod( _aResumo2[d][8] ) ), "@E 999"), oFont2)
	endif
	nEspTot      := nEspTot + _aResumo2[d][2]
	nValtot      := nValtot + _aResumo2[d][3]
	nEspLivreG   := nEspLivreG + _aResumo2[d][4]
	nTotLivreG   := nTotLivreG + _aResumo2[d][5]
	nEspFutG     := nEspFutG + _aResumo2[d][6]
	nTotFutG     := nTotFutG + _aResumo2[d][7]
	nLin += nEsp
Next
If !_lRpc
	oPrn:Box(nLin-5, 50, nLin-5+50, oPrn:GetWidth()-825) 
	oPrn:Say(nLin,0060,"Total===>", oFont2)
	oPrn:Say(nLin,0375,Transform(nEspLivreG, "@E 99,999,999.99"), oFont2)
	oPrn:Say(nLin,0730,Transform(nTotLivreG, "@E 99,999,999.99"), oFont2)
	oPrn:Say(nLin,1105,Transform(nEspFutG  , "@E 99,999,999.99"), oFont2)
	oPrn:Say(nLin,1420,Transform(nTotFutG  , "@E 99,999,999.99"), oFont2)
	oPrn:Say(nLin,1775,Transform(nEspTot   , "@E 99,999,999.99"), oFont2)
	oPrn:Say(nLin,2125,Transform(nValtot   , "@E 99,999,999.99"), oFont2)
	nLin += nEsp*2
endif
nEspLivreG := 0
nTotLivreG := 0
nEspFutG   := 0
nTotFutG   := 0
nEspTot    := 0
nValtot    := 0

//Alterado Vincius Lança - 25/03/2019
nLin := fImpCab("9B",.F.,oPrn)

For d	:=	1	To	Len(_aResumo2B)
	If nLin > 2200
		nLin := fImpCab("9B",.F.,oPrn)
	Endif
	If !_lRpc
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:GetWidth()-825) 
		oPrn:Line(nLin-5,  265, nLin-5+50,  265 )
		oPrn:Line(nLin-5,  655, nLin-5+50,  655 )
		oPrn:Line(nLin-5, 1010, nLin-5+50, 1010 )
		oPrn:Line(nLin-5, 1390, nLin-5+50, 1390 )
		oPrn:Line(nLin-5, 1700, nLin-5+50, 1700 )
		oPrn:Line(nLin-5, 2060, nLin-5+50, 2060 )
		oPrn:Line(nLin-5, 2400, nLin-5+50, 2400 )
		
		oPrn:Say(nLin,0060,Iif(EMPTY(_aResumo2B[d][1]), " ", _aResumo2B[d][1]), oFont2)
		oPrn:Say(nLin,0375,Transform(_aResumo2B[d][4], "@E 99,999,999.99"), oFont2)
		oPrn:Say(nLin,0730,Transform(_aResumo2B[d][5], "@E 99,999,999.99"), oFont2)
		oPrn:Say(nLin,1105,Transform(_aResumo2B[d][6], "@E 99,999,999.99"), oFont2)
		oPrn:Say(nLin,1420,Transform(_aResumo2B[d][7], "@E 99,999,999.99"), oFont2)
		
		oPrn:Say(nLin,1775,Transform(_aResumo2B[d][2], "@E 99,999,999.99"), oFont2)
		oPrn:Say(nLin,2125,Transform(_aResumo2B[d][3], "@E 99,999,999.99"), oFont2)
		oPrn:Say(nLin,2475,Transform( (dDatabase - stod( _aResumo2B[d][8] ) ), "@E 999"), oFont2)
	endif
	nEspTot      := nEspTot + _aResumo2B[d][2]
	nValtot      := nValtot + _aResumo2B[d][3]
	nEspLivreG   := nEspLivreG + _aResumo2B[d][4]
	nTotLivreG   := nTotLivreG + _aResumo2B[d][5]
	nEspFutG     := nEspFutG + _aResumo2B[d][6]
	nTotFutG     := nTotFutG + _aResumo2B[d][7]
	nLin += nEsp
Next
If !_lRpc
	oPrn:Box(nLin-5, 50, nLin-5+50, oPrn:GetWidth()-825) 
	oPrn:Say(nLin,0060,"Total===>", oFont2)
	oPrn:Say(nLin,0375,Transform(nEspLivreG, "@E 99,999,999.99"), oFont2)
	oPrn:Say(nLin,0730,Transform(nTotLivreG, "@E 99,999,999.99"), oFont2)
	oPrn:Say(nLin,1105,Transform(nEspFutG  , "@E 99,999,999.99"), oFont2)
	oPrn:Say(nLin,1420,Transform(nTotFutG  , "@E 99,999,999.99"), oFont2)
	oPrn:Say(nLin,1775,Transform(nEspTot   , "@E 99,999,999.99"), oFont2)
	oPrn:Say(nLin,2125,Transform(nValtot   , "@E 99,999,999.99"), oFont2)
	nLin += nEsp*2
	//ENDIF
endif

//If nLin	>	2200
nLin := fImpCab("--", .F., oPrn)
//Endif

nTotNFat := FNAOFAT()
TOTSUBGRU()
If !_lRpc
	oPrn:Say(nLin, 60,Space(10)+"TOTAL DE DEMONSTRACAO.......................................................... ", oFont2)
	oPrn:Say(nLin, 60,Space(90)+Transform(nTot_D   , "@E 99,999,999.99"), oFont2)
	
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
	//Alterado Vinicius Lança - 22/03/19
	nLin += nEsp
	oPrn:Say ( nLin , 60,Space(10)+"TOTAL DE VENDAS BAHIA.......................................................... ", oFont2)
	oPrn:Say ( nLin , 60,Space(90)+Transform(nTot_NBA , "@E 99,999,999.99"), oFont2)
	// Vinicius Lança
	nLin += nEsp
	oPrn:Say ( nLin , 60,Space(10)+"TOTAL C/ DT.ENTREGA............................................................ ", oFont2)
	oPrn:Say ( nLin , 60,Space(90)+Transform(nTotCEnt , "@E 99,999,999.99"), oFont2)
	
	nLin += nEsp
	oPrn:Say ( nLin , 60,Space(10)+"TOTAL PROG. NÃO FATURADO....................................................... ", oFont2)
	oPrn:Say ( nLin , 60,Space(90)+Transform(nTotNFat , "@E 99,999,999.99"), oFont2)
	
	nLin += nEsp*2
	oPrn:Say ( nLin , 60,Space(10)+"TOTAL GERAL DE PEDIDOS.........................................................", oFont2)
	oPrn:Say ( nLin , 60,Space(90)+Transform(nPed , "@E 9,999,999,999"), oFont2)
	
	//Alterado Vinicius Lança - 22/03/19
	nLin += nEsp
	oPrn:Say ( nLin , 60,Space(10)+"TOTAL GERAL DE PEDIDOS BAHIA...................................................", oFont2)
	oPrn:Say ( nLin , 60,Space(90)+Transform(nPedBA , "@E 9,999,999,999"), oFont2)
	//Vinicius Lança
	
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
endif
nLin += nEsp*2

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
	//	@ nLin,00 Psay "CODIGO         DENOMINACAO                                        MEDIDAS             CARTEIRA   ESTOQUE   RESULTADO   SOLICITADO    SOLICITACOES COMPRA   DATA SOLICITACAO      DATA PREVISTA ENTREGA"
	
	For i	:=	1	To	Len(_aProdT)
		If nLin > 2200
			nLin := fImpCab("3", .F., oPrn)
		EndIf
		If !_lRpc
			oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:GetWidth()-50 ) 
			oPrn:Line(nLin-5,  265, nLin-5+50,  265 )   // CODIGO DENOMINACAO
			oPrn:Line(nLin-5,  1100, nLin-5+50,  1100 ) // DENOMINACAO MEDIDAS
			oPrn:Line(nLin-5,  1405, nLin-5+50,  1405 ) // MEDIDAS CARTEIRA
			oPrn:Line(nLin-5,  1600, nLin-5+50,  1600 ) // CARTEIRA ESTQ
			oPrn:Line(nLin-5,  1720, nLin-5+50,  1720 ) // ESTQ RESULT
			oPrn:Line(nLin-5,  1885, nLin-5+50,  1885 ) // RESULT SOLICITADO
			oPrn:Line(nLin-5,  2115, nLin-5+50,  2115 ) // SOL.COMPRA DT.SOLICITACAO DT.PREV.ENTREGA
			oPrn:Line(nLin-5,  2830, nLin-5+50,  2830 ) // PEDIDOS
			oPrn:Line(nLin-5,  2965, nLin-5+50,  2965 ) // ULT TR.
			oPrn:Line(nLin-5,  3115, nLin-5+50,  3115 ) // ULT PD.
			oPrn:Line(nLin-5,  3265, nLin-5+50,  3265 ) //
			
			oPrn:Say(nLin,0060, alltrim( _aProdT[i][1] ), oFont2) 						 //codigo
			oPrn:Say(nLin,0275,SUBSTR(alltrim( _aProdT[i][2] ), 1, 40), oFont2)          //denominacao
			oPrn:Say(nLin,1110,alltrim( _aProdT[i][3] ), oFont2)                         //medidas
			oPrn:Say(nLin,1475,TransForm(_aProdT[i][4],"@E 99999"), oFont2)              //carteira
			
			oPrn:Say(nLin,1600,TransForm(_aProdT[i][5],"@E 99999"), oFont2)              //estoque
			oPrn:Say(nLin,1750,TransForm(_aProdT[i][5]-_aProdT[i][4],"@E 99999"), oFont2)//resultado
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
			QRY->( dbCloseArea() )
		EndIf
		
		TCQUERY cQry ALIAS "QRY" NEW
		dbSelectArea("QRY")
		
		While QRY->( !EOF() )
			nSolicit := qry->solicit
			QRY->( dbskip() )
		end
		dbSelectArea("QRY")
		QRY->( dbCloseArea() )
		If !_lRpc
			oPrn:Say(nLin,2000,TransForm(nSolicit,"@E 99999"), oFont2) //solicitado
			
			oPrn:Say(nLin,2840,Transform(Len(_aProdT[i][6]), "@E 999,999"),oFont2)
			oPrn:Say(nLin,2975,Transform(dDataBase-_aProdT[i][7], "@E 999,999"),oFont2)
			oPrn:Say(nLin,3125,Transform(dDataBase-_aProdT[i][8], "@E 999,999"),oFont2)
		endif
		cQry :=	"select c7_num, c7_emissao, c7_datprf "
		cQry +=	"  from "+retsqlname("SC7")+" "
		cQry +=	" where d_e_l_e_t_ = ' '      "
		cQry +=	"   and c7_filial = '"+xFilial("SC7")+"' "
		cQry +=	"   and c7_produto = '"+_aProdT[i][1]+"'"
		cQry +=	"   and c7_residuo = ' '      "
		cQry +=	"   and c7_quant > c7_quje    "
		If Select("QRY") > 0
			dbSelectArea("QRY")
			QRY->( dbCloseArea() )
		EndIf
		
		TCQUERY cQry ALIAS "QRY" NEW
		dbSelectArea("QRY")
		cNumsc := ""
		cDtSol := ""
		cDtEnt := ""
		
		While QRY->( !EOF() )
			//			if ncont = 12    //limite de solicitacoes por linha
			if ncont = 1    //limite de solicitacoes por linha
				If !_lRpc
					oPrn:Box(nLin-5, 50, nLin-5+50, oPrn:GetWidth()-50 ) 
					oPrn:Say(nLin,2125,cNumsc, oFont2)
					// =-=
					oPrn:Say(nLin,2390,cDtSol, oFont2)
					oPrn:Say(nLin,2665,cDtEnt, oFont2)
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
		If !_lRpc
			oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:GetWidth()-50 ) 
			oPrn:Say(nLin,2125,cNumsc, oFont2)
			
			oPrn:Say(nLin,2390,cDtSol, oFont2)
			oPrn:Say(nLin,2665,cDtEnt, oFont2)
		endif
		nQTotProd += _aProdT[i][4]
		nLin += nEsp
		cNumsc := ""
		nCont  := 0
	Next
	If !_lRpc
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:GetWidth()-50 ) 
		oPrn:Say(nLin,1110,"Totalizador ==>>", oFont2)
		oPrn:Say(nLin,1475,TransForm(nQTotProd,"@E 999999"), oFont2)
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
	//Endif
	
	lImp := .T.
	
	For i	:=	1	To	Len(_aProdTatr)
		If nLin > 2200 //.and. x= 1
			nLin := fImpCab("A", .F., oPrn)
		EndIf
		If nCont > 9  .AND. lSeglin = .F.
			If !_lRpc
				oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:GetWidth()-50 )
				oPrn:Line(nLin-5,  265, nLin-5+50,  265 ) // CODIGO DENOMINACAO
				oPrn:Line(nLin-5,  1100, nLin-5+50,  1100 ) // DENOMINACAO MEDIDAS
				oPrn:Line(nLin-5,  1405, nLin-5+50,  1405 ) // MEDIDAS CARTEIRA
				
				oPrn:Say(nLin,0060,alltrim(cProd), oFont2)
				oPrn:Say(nLin,0275,SUBSTR(alltrim(cDesc), 1, 40), oFont2)
				oPrn:Say(nLin,1110,alltrim(cMed), oFont2)
				oPrn:Say(nLin,1425,alltrim(substr(cPed,1, len(cPed)-2)), oFont2)
			endif
			cPed := ""
			nCont := 0
			
			nLin += nEsp
			
			lImp := .F.
			lSeglin := .T.
		Elseif nCont > 9  .AND. lSeglin = .T.
			If !_lRpc
				oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:GetWidth()-50 )
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
			If !_lRpc
				If lImp = .T. .AND. lSeglin = .T. .AND. cPed <> ' '
					oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:GetWidth()-50 )
					oPrn:Say(nLin,1425,alltrim(substr(cPed,1, len(cPed)-2)), oFont2)
					nLin += nEsp
				ELSEIF lImp = .T. .AND. cPed <> ' '
					oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:GetWidth()-50 )
					oPrn:Line(nLin-5,  265, nLin-5+50,  265 ) // CODIGO DENOMINACAO
					oPrn:Line(nLin-5,  1100, nLin-5+50,  1100 ) // DENOMINACAO MEDIDAS
					oPrn:Line(nLin-5,  1405, nLin-5+50,  1405 ) // MEDIDAS CARTEIRA
					
					oPrn:Say(nLin,0060,alltrim(cProd), oFont2)
					oPrn:Say(nLin,0275,SUBSTR(alltrim(cDesc), 1, 40), oFont2)
					oPrn:Say(nLin,1110,alltrim(cMed), oFont2)
					oPrn:Say(nLin,1425,alltrim(substr(cPed,1, len(cPed)-2)), oFont2)
					
					nLin += nEsp
				Endif
			endif
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
	If !_lRpc
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:GetWidth()-50 )
		oPrn:Line(nLin-5,  265, nLin-5+50,  265 ) // CODIGO DENOMINACAO
		oPrn:Line(nLin-5,  1100, nLin-5+50,  1100 ) // DENOMINACAO MEDIDAS
		oPrn:Line(nLin-5,  1405, nLin-5+50,  1405 ) // MEDIDAS CARTEIRA
		
		oPrn:Say(nLin,0060, alltrim(cProd), oFont2)
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
	If !_lRpc
		oPrn:Say(nLin,0060,"Total Pedidos em Atraso ==>>",oFont2)
		oPrn:Say(nLin,1425,TransForm(Len(_aPedAt),"@E 9999"),oFont2)
	endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Imprime Segmentos    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If mv_par20 = 2
	
	nLin := fImpCab("5", .F., oPrn)
	aSort(_aSegmento,,,{|x,y| x[1]<y[1]})
	aSort(_aModelos,,,{|x,y| x[1]<y[1]})
	aSort(_aSegFiMix,,,{|x,y| x[1]<y[1]})
	
	nTotQTd  := 0
	nTotTotal:= 0
	
	For i	:=	1	To	Len(_aModelos)
		If nLin > 2200
			nLin := fImpCab("5", .F., oPrn)
			nLin += nEsp
			If !_lRpc
				oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:GetWidth()-2375)
				oPrn:Say(nLin,0125,"Por Modelo de Produtos", oFont2)
				nLin += nEsp
				
				oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:GetWidth()-2375)
				oPrn:Line(nLin-5,  385, nLin-5+50,  385 ) //
				oPrn:Line(nLin-5,  605, nLin-5+50,  605 ) //
				
				oPrn:Say(nLin,0060,"Grupo", oFont2)
				oPrn:Say(nLin,0400,"Quantidade", oFont2)
				oPrn:Say(nLin,0800,"Valor", oFont2)
			endif
			nLin += nEsp
		ELSE
			IF I == 1
				If !_lRpc
					nLin += nEsp
					oPrn:Box(nLin-5, 50, nLin-5+50, oPrn:GetWidth()-2375)
					oPrn:Say(nLin,0125,"Por Modelo de Produtos", oFont2)
					nLin += nEsp
					
					oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:GetWidth()-2375)
					oPrn:Line(nLin-5,  385, nLin-5+50,  385 ) //
					oPrn:Line(nLin-5,  605, nLin-5+50,  605 ) //
					
					oPrn:Say(nLin,0060,"Grupo", oFont2)
					oPrn:Say(nLin,0400,"Quantidade", oFont2)
					oPrn:Say(nLin,0800,"Valor", oFont2)
					nLin += nEsp
				endif
			ENDIF
		EndIf
		
		If !_lRpc
			oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:GetWidth()-2375)
			oPrn:Line(nLin-5,  385, nLin-5+50,  385 ) //
			oPrn:Line(nLin-5,  605, nLin-5+50,  605 ) //
			
			oPrn:Say(nLin,0060,_aModelos[i][2], oFont2)
			oPrn:Say(nLin,0400,TransForm(round(_aModelos[i][3],2),"@E 9,999,999"), oFont2)
			oPrn:Say(nLin,0675,TransForm(round(_aModelos[i][4],2),"@E 9,999,999,999.99"), oFont2)
			nLin += nEsp
		endif
		
		nTotQTD   += round(_aModelos[i][3],2)
		nTotTotal += round(_aModelos[i][4],2)
	next
	
	If !_lRpc
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:GetWidth()-2375)
		nLin += nEsp
		
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:GetWidth()-2375)
		oPrn:Line(nLin-5,  385, nLin-5+50,  385 ) //
		oPrn:Line(nLin-5,  605, nLin-5+50,  605 ) //
		
		oPrn:Say(nLin,0060," *** TOTAL *** ", oFont2)
		oPrn:Say(nLin,0400,TransForm(nTOTQTD,"@E 9,999,999"), oFont2)
		oPrn:Say(nLin,0675,TransForm(nTOTTOTAL,"@E 9,999,999,999.99"), oFont2)
	endif
	
	nLin += nEsp*2
	nTotQTd  := 0
	nTotTotal:= 0
	For i	:=	1	To	Len(_aSegmento)
		If nLin > 2200
			nLin := fImpCab("5", .F., oPrn)
			nLin += nEsp
			
			If !_lRpc
				oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:GetWidth()-2375)
				oPrn:Say(nLin,0125,"Por Grupo de Produtos", oFont2)
				nLin += nEsp
				
				oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:GetWidth()-2375)
				oPrn:Line(nLin-5,  385, nLin-5+50,  385 ) //
				oPrn:Line(nLin-5,  605, nLin-5+50,  605 ) //
				
				oPrn:Say(nLin,0060,"Modelo", oFont2)
				oPrn:Say(nLin,0400,"Quantidade", oFont2)
				oPrn:Say(nLin,0800,"Valor", oFont2)
			endif
			nLin += nEsp
		ELSE
			IF I == 1
				If !_lRpc
					oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:GetWidth()-2375)
					oPrn:Say(nLin,0125,"Por Grupo de Produtos", oFont2)
					nLin += nEsp
					
					oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:GetWidth()-2375)
					oPrn:Line(nLin-5,  385, nLin-5+50,  385 ) //
					oPrn:Line(nLin-5,  605, nLin-5+50,  605 ) //
					
					oPrn:Say(nLin,0060,"Grupo", oFont2)
					oPrn:Say(nLin,0400,"Quantidade", oFont2)
					oPrn:Say(nLin,0800,"Valor", oFont2)
					nLin += nEsp
				endif
			ENDIF
		EndIf
		If !_lRpc
			oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:GetWidth()-2375)
			oPrn:Line(nLin-5,  385, nLin-5+50,  385 ) //
			oPrn:Line(nLin-5,  605, nLin-5+50,  605 ) //
			
			oPrn:Say(nLin,0060,_aSegmento[i][2], oFont2)
			oPrn:Say(nLin,0400,TransForm(round(_aSegmento[i][3],2),"@E 9,999,999"), oFont2)
			oPrn:Say(nLin,0675,TransForm(round(_aSegmento[i][4],2),"@E 9,999,999,999.99"), oFont2)
		endif
		nTotQTD   += round(_aSegmento[i][3],2)
		nTotTotal += round(_aSegmento[i][4],2)
		nLin += nEsp
	Next
	If !_lRpc
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:GetWidth()-2375)
		nLin += nEsp
		
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:GetWidth()-2375)
		oPrn:Line(nLin-5,  385, nLin-5+50,  385 ) //
		oPrn:Line(nLin-5,  605, nLin-5+50,  605 ) //
		
		oPrn:Say(nLin,0060," *** TOTAL *** ", oFont2)
		oPrn:Say(nLin,0400,TransForm(nTOTQTD,"@E 9,999,999"), oFont2)
		oPrn:Say(nLin,0675,TransForm(nTOTTOTAL,"@E 9,999,999,999.99"), oFont2)
		nLin += nEsp
	endif
	nTotQTd  := 0
	nTotTotal:= 0
	nCusTotal:= 0
	
	////////////
	For i	:=	1	To	Len(_aSegFiMix)
		If nLin > 2200
			nLin := fImpCab("5", .F., oPrn)
			nLin += nEsp
			If !_lRpc
				oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:GetWidth()-2375+350)
				oPrn:Say(nLin,0125,"Por Segmento Comercial", oFont2)
				nLin += nEsp
				
				oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:GetWidth()-2375+350)
				oPrn:Line(nLin-5,  385, nLin-5+50,  385 ) //
				oPrn:Line(nLin-5,  605, nLin-5+50,  605 ) //
				oPrn:Line(nLin-5,  960, nLin-5+50,  960 ) //
				
				oPrn:Say(nLin,0060,"Segmento", oFont2)
				oPrn:Say(nLin,0400,"Quantidade", oFont2)
				oPrn:Say(nLin,0800,"Financeiro", oFont2)
				oPrn:Say(nLin,1200,"Mix", oFont2)
			endif
			nLin += nEsp
		ELSE
			IF I == 1
				If !_lRpc
					nLin += nEsp
					oPrn:Box(nLin-5, 50, nLin-5+50, oPrn:GetWidth()-2375+350)
					oPrn:Say(nLin,0125,"Por Segmento Comercial", oFont2)
					nLin += nEsp
					
					oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:GetWidth()-2375+350)
					oPrn:Line(nLin-5,  385, nLin-5+50,  385 ) //
					oPrn:Line(nLin-5,  605, nLin-5+50,  605 ) //
					oPrn:Line(nLin-5,  960, nLin-5+50,  960 ) //
					
					oPrn:Say(nLin,0060,"Segmento", oFont2)
					oPrn:Say(nLin,0400,"Quantidade", oFont2)
					oPrn:Say(nLin,0800,"Financeiro", oFont2)
					oPrn:Say(nLin,1200,"Mix", oFont2)
					nLin += nEsp
				endif
			ENDIF
		EndIf
		If !_lRpc
			oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:GetWidth()-2375+350)
			oPrn:Line(nLin-5,  385, nLin-5+50,  385 ) //
			oPrn:Line(nLin-5,  605, nLin-5+50,  605 ) //
			oPrn:Line(nLin-5,  960, nLin-5+50,  960 ) //
			
			oPrn:Say(nLin,0060,_aSegFiMix[i][2], oFont2)
			oPrn:Say(nLin,0400,TransForm(round(_aSegFiMix[i][3],2),"@E 9,999,999"), oFont2)
			oPrn:Say(nLin,0675,TransForm(round(_aSegFiMix[i][4],2),"@E 9,999,999,999.99"), oFont2)
			oPrn:Say(nLin,1000,TransForm(round((_aSegFiMix[i][4]-_aSegFiMix[i][5])/_aSegFiMix[i][4],2),"@E 9,999,999,999.99"), oFont2)
			nLin += nEsp
		endif
		nTotQTD   += round(_aSegFiMix[i][3],2)
		nTotTotal += round(_aSegFiMix[i][4],2)
		nCusTotal += round(_aSegFiMix[i][5],2)
	next
	If !_lRpc
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:GetWidth()-2375+350)
		nLin += nEsp
		
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:GetWidth()-2375+350)
		oPrn:Line(nLin-5,  385, nLin-5+50,  385 ) //
		oPrn:Line(nLin-5,  605, nLin-5+50,  605 ) //
		oPrn:Line(nLin-5,  960, nLin-5+50,  960 ) //
		
		oPrn:Say(nLin,0060," *** TOTAL *** ", oFont2)
		oPrn:Say(nLin,0400,TransForm(nTOTQTD,"@E 9,999,999"), oFont2)
		oPrn:Say(nLin,0675,TransForm(nTOTTOTAL,"@E 9,999,999,999.99"), oFont2)
		oPrn:Say(nLin,1000,TransForm((nTOTTOTAL-nCUSTOTAL)/nTOTTOTAL ,"@E 9,999,999,999.99"), oFont2)
	endif
	nLin += nEsp*2
	nTotQTd  := 0
	nTotTotal:= 0
	///////////
	
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?
//³Imprime RESUMO DE CARTEIRA POR PERIODO³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ?

nLin := fImpCab("6", .F., oPrn)
If !_lRpc
	oPrn:Box(nLin-5, 50, nLin-5+50, oPrn:GetWidth()-1600 )
	oPrn:Say(nLin,0060,"CARTEIRA PARA OS PROXIMOS 30 DIAS                    ==>>      " + Transform(nCart30d,"@E 99,999,999.99"), oFont2)
	nLin += nEsp
	
	oPrn:Box(nLin-5, 50, nLin-5+50, oPrn:GetWidth()-1600 )
	oPrn:Say(nLin,0060,"CARTEIRA ENTRE OS PROXIMOS 31 : 60 DIAS              ==>>      " + Transform(nCart3060d,"@E 99,999,999.99"), oFont2)
	nLin += nEsp
	
	oPrn:Box(nLin-5, 50, nLin-5+50, oPrn:GetWidth()-1600 )
	oPrn:Say(nLin,0060,"CARTEIRA APOS OS PROXIMOS 60 DIAS                    ==>>      " + Transform(nCartM60d,"@E 99,999,999.99"), oFont2)
	nLin += nEsp*2
endif
aRentTot[1]:= (aRent30[1]+aRent30[2]+aRent30[3]+aRent30[4])/(aRentSeg30[1]+aRentSeg30[2]+aRentSeg30[3]+aRentSeg30[4])//(aRent30[1]/aRentSeg30[1])+(aRent30[2]/aRentSeg30[2])+(aRent30[3]/aRentSeg30[3])+(aRent30[4]/aRentSeg30[4])
aRentTot[2]:= (aRent3060[1]+aRent3060[2]+aRent3060[3]+aRent3060[4])/(aRtSeg3060[1]+aRtSeg3060[2]+aRtSeg3060[3]+aRtSeg3060[4])//(aRent3060[1]/aRentSeg3060[1])+(aRent3060[2]/aRentSeg3060[2])+(aRent3060[3]/aRentSeg3060[3])+(aRent3060[4]/aRentSeg3060[4])
aRentTot[3]:= (aRent60[1]+aRent60[2]+aRent60[3]+aRent60[4])/(aRentSeg60[1]+aRentSeg60[2]+aRentSeg60[3]+aRentSeg60[4])//(aRent60[1]/aRentSeg60[1])+(aRent60[2]/aRentSeg60[2])+(aRent60[3]/aRentSeg60[3])+(aRent60[4]/aRentSeg60[4])

If !_lRpc
	oPrn:Box(nLin-5, 50, nLin-5+50, oPrn:GetWidth()-1600)
	oPrn:Say(nLin,0060,"RENTABILIDADE", oFont2)
	nLin += nEsp
	
	oPrn:Box( nLin-5,0050,nLin-5+50,oPrn:GetWidth()-1600)
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
	oPrn:Box( nLin-5,0050,nLin-5+50,oPrn:GetWidth()-1600)
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
	oPrn:Box( nLin-5,0050,nLin-5+50,oPrn:GetWidth()-1600)
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
	oPrn:Box( nLin-5,0050,nLin-5+50,oPrn:GetWidth()-1600)
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
	oPrn:Box( nLin-5,0050,nLin-5+50,oPrn:GetWidth()-1600)
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
	oPrn:Say(nLin,1520,Transform(((aRent30[1]+aRent3060[1]+aRent60[1])+(aRent30[2]+aRent3060[2]+aRent60[2])+(aRent30[3]+aRent3060[3]+aRent60[3])+(aRent30[4]+aRent3060[4]+aRent60[4]))/((aRentSeg30[1]+aRtSeg3060[1]+aRentSeg60[1])+(aRentSeg30[2]+aRtSeg3060[2]+aRentSeg60[2])+(aRentSeg30[3]+aRtSeg3060[3]+aRentSeg60[3])+(aRentSeg30[4]+aRtSeg3060[4]+aRentSeg60[4])), "@E 99,999,999.99"), oFont2)


	nLin += nEsp * 2

	oPrn:Box(nLin-5, 50, nLin-5+50, oPrn:GetWidth()-1600)
	oPrn:Say(nLin,0060,"TOTAL POR SEGMENTO", oFont2)
	nLin += nEsp
	
	oPrn:Box( nLin-5,0050,nLin-5+50,oPrn:GetWidth()-1600)
	oPrn:Line(nLin-5,0270,nLin-5+50,0270) // comercial
	oPrn:Line(nLin-5,0590,nLin-5+50,0590) // industrual
	oPrn:Line(nLin-5,0890,nLin-5+50,0890) // loja
	oPrn:Line(nLin-5,1190,nLin-5+50,1190) // site
	oPrn:Line(nLin-5,1490,nLin-5+50,1490) // outros
	
	oPrn:Say(nLin,0275,"COMERCIAL", oFont2)
	oPrn:Say(nLin,0595,"INDUSTRIAL", oFont2)
	oPrn:Say(nLin,0895,"LOJA", oFont2)
	oPrn:Say(nLin,1195,"SITE", oFont2)
	oPrn:Say(nLin,1495,"OUTROS", oFont2)
	
	nLin += nEsp

	oPrn:Box( nLin-5,0050,nLin-5+50,oPrn:GetWidth()-1600)
	oPrn:Line(nLin-5,0270,nLin-5+50,0270) // comercial
	oPrn:Line(nLin-5,0590,nLin-5+50,0590) // industrual
	oPrn:Line(nLin-5,0890,nLin-5+50,0890) // loja
	oPrn:Line(nLin-5,1190,nLin-5+50,1190) // site
	oPrn:Line(nLin-5,1490,nLin-5+50,1490) // outros

	oPrn:Say(nLin,0060,"VALOR", oFont2)
	oPrn:Say(nLin,0320,Transform(aDistSeg[1], "@E 99,999,999.99"), oFont2) //comercial
	oPrn:Say(nLin,0620,Transform(aDistSeg[2], "@E 99,999,999.99"), oFont2) //industrial
	oPrn:Say(nLin,0920,Transform(aDistSeg[3], "@E 99,999,999.99"), oFont2) //loja
	oPrn:Say(nLin,1220,Transform(aDistSeg[4], "@E 99,999,999.99"), oFont2) //site
	oPrn:Say(nLin,1520,Transform(aDistSeg[5], "@E 99,999,999.99"), oFont2) //outros
	
	nLin += nEsp
	oPrn:Box( nLin-5,0050,nLin-5+50,oPrn:GetWidth()-1600)
	oPrn:Line(nLin-5,0270,nLin-5+50,0270) // comercial
	oPrn:Line(nLin-5,0590,nLin-5+50,0590) // industrual
	oPrn:Line(nLin-5,0890,nLin-5+50,0890) // loja
	oPrn:Line(nLin-5,1190,nLin-5+50,1190) // terceiros
	oPrn:Line(nLin-5,1490,nLin-5+50,1490) // total

	nTotCart := nCart30d+nCart3060d+nCartM60d
	
	oPrn:Say(nLin,0060,"PERC.(%)", oFont2)
	oPrn:Say(nLin,0320,Transform((aDistSeg[1]/nTotCart)*100, "@E 99,999,999.99"), oFont2) //comercial
	oPrn:Say(nLin,0620,Transform((aDistSeg[2]/nTotCart)*100, "@E 99,999,999.99"), oFont2) //industrial
	oPrn:Say(nLin,0920,Transform((aDistSeg[3]/nTotCart)*100, "@E 99,999,999.99"), oFont2) //loja
	oPrn:Say(nLin,1220,Transform((aDistSeg[4]/nTotCart)*100, "@E 99,999,999.99"), oFont2) //site
	oPrn:Say(nLin,1520,Transform((aDistSeg[5]/nTotCart)*100, "@E 99,999,999.99"), oFont2) //outros

endif
If _cRpc == "S" .and. _cNRot == "ORTPMPRG" .and. _cInfRet == "CARTGER"
	//_nTotTotal := aRentTot[1]+aRentTot[2]+aRentTot[3]
	_nTotTotal := nCart30d+nCart3060d+nCartM60d
	If !_lRpc
		oPrn:Cancel()
	endif
Endif
If !_lRpc
	
	// RESUMO DOS 30 MAIORES CLIENTES
	nLin := fImpCab("7", .F., oPrn)
	oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:GetWidth()-1460)
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
	nTotal:=0
	if len(aCliente) > 30 // mudança de 10 para 30 por solicitação do Sr. David Menezes 2021-02-12
		nMax:=30
	else
		nMax:=len(aCliente)
	endif
	
	for i:=1 to nMax
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:GetWidth()-1460)
		oPrn:Line(nLin-5,  0470, nLin-5+50, 0470 ) //
		oPrn:Line(nLin-5,  0885, nLin-5+50, 0885 ) //
		oPrn:Line(nLin-5,  1250, nLin-5+50, 1250 ) //
		oPrn:Line(nLin-5,  1550, nLin-5+50, 1550 ) //
		
		oPrn:Say(nLin,0060,substr(Posicione("SA1",1,xFilial("SA1")+aCliente[i][1],"SA1->A1_NOME"),1,19), oFont2)	//cliente
		if len(aCliente[i][2])>13
			oPrn:Say (nLin,0500,Transform(Alltrim(aCliente[i][2]),"@R 99.999.999/9999-99"), oFont2)	//cnpj
		else
			oPrn:Say(nLin,0500,Transform(Alltrim(aCliente[i][2]),"@R 999.999.999-99"), oFont2) //cpf
		endif
		
		oPrn:Say(nLin,1175,Transform(alltrim(aCliente[i][3]),"@E 99"), oFont2) // segmento
		oPrn:Say(nLin,1325,Transform(aCliente[i][4],"@E 999,999,999"), oFont2) // espaços
		oPrn:Say(nLin,1635,Transform(aCliente[i][5],"@E 99,999,999,999"), oFont2) //valor
		
		nTotal+=aCliente[i][5]
		nLin += nEsp
	next
	
	oPrn:Box(nLin-5, 50, nLin-5+50, oPrn:GetWidth()-1460)
	oPrn:Say(nLin,0060," *** TOTAL *** ", oFont2)
	oPrn:Say(nLin,1635,Transform(nTotal,"@E 99,999,999,999"), oFont2)
	
	nLin += nEsp*2
	oPrn:Say(nLin,0060,"LEGENDA SEGMENTOS:", oFont2)
	nLin += nEsp
	oPrn:Say(nLin,0060,"1 - INDUSTRIAL | 2 - COMERCIAL  |  3 - LOJAS  |  4 - LOJAS EXCLUSIVAS  |  5 - ORTOCLASS INDUSTRIAL  |  6 - ORTOCLASS COMERCIAL", oFont2)
endif

If !_lRpc
	
	// RESUMO DAS OPERAÇÕES POR SEGUIMENTO - 08/01/2021 - Solicitação Rubens
	nLin := fImpCab("SGOP", .F., oPrn)
	nLinN := nLin + nEsp
	//QUADRO 1	
	oPrn:Box( nLin-5, 0050, nLin-5+50, oPrn:GetWidth()-1920)
	oPrn:Line(nLin-5, 0460, nLin-5+50, 0460 )
	oPrn:Line(nLin-5, 0770, nLin-5+50, 0770 )
	oPrn:Line(nLin-5, 1170, nLin-5+50, 1170 )
		
	oPrn:Say(nLin,0060,"CANAL", oFont2)
	oPrn:Say(nLin,0480,"SEGMENTO", oFont2)
	oPrn:Say(nLin,0790,"OPERAÇÃO", oFont2)
	oPrn:Say(nLin,1180,"VALOR TOTAL", oFont2)
	
	//QUADRO 2
	oPrn:Box( nLin-5, oPrn:GetWidth()-1920, nLin-5+50, oPrn:GetWidth()-810)
	oPrn:Line(nLin-5, 1870, nLin-5+50, 1870 )
	oPrn:Line(nLin-5, 2370, nLin-5+50, 2370 )
	//oPrn:Line(nLin-5, 2970, nLin-5+50, 2970 )
	
	oPrn:Say(nLin,1600,"SEGMENTO", oFont2)
	oPrn:Say(nLin,1880,"OPERAÇÃO", oFont2)
	oPrn:Say(nLin,2420,"VALOR TOTAL", oFont2)

	//QUADRO 3
	oPrn:Box(nLin-5,  oPrn:GetWidth()-810, nLin-5+50, oPrn:GetWidth()-060)
	oPrn:Line(nLin-5,3000, nLin-5+50, 3000 )
	
	oPrn:Say(nLin,2710,"OPERAÇÃO", oFont2)
	oPrn:Say(nLin,3120,"VALOR TOTAL", oFont2)

	nLin += nEsp
	nTotal:=0

	ASORT(_aTCSOper, , , { | x,y | x[1] < y[1] } )

	for i:=1 to Len(_aTCSOper)
		If i != 1
			oPrn:Box( nLin-5, 0050, nLin-5+50, oPrn:GetWidth()-1880)
			oPrn:Say(nLin,0060,"Total Canal: " + Transform(alltrim(_cNicho),"@E 99999"), oFont2) // Nicho
			oPrn:Say(nLin,0400," - " + AllTrim(Posicione("SZ0",1,xFilial("SZ0")+'CM'+_cNicho,"Z0_DESCRI")), oFont2) // operação
			oPrn:Say(nLin,1220,Transform(_nTotReg,"@E 999,999,999.99"), oFont2) // valor
			nLin += nEsp
		EndIf
		_nTotReg := 0
		For y := 2 to Len(_aTCSOper[i])
			For k := 2 to Len(_aTCSOper[i][y])
				oPrn:Box( nLin-5, 0050, nLin-5+50, oPrn:GetWidth()-1880)
				oPrn:Line(nLin-5, 0460, nLin-5+50, 0460 )
				oPrn:Line(nLin-5, 0770, nLin-5+50, 0770 )
				oPrn:Line(nLin-5, 1170, nLin-5+50, 1170 )

				oPrn:Say(nLin,0060,Transform(alltrim(_aTCSOper[i][1]),"@E 99999"), oFont2) // Nicho
				oPrn:Say(nLin,0110," - " + AllTrim(Posicione("SZ0",1,xFilial("SZ0")+'CM'+_aTCSOper[i][1],"Z0_DESCRI")), oFont2) // operação
				oPrn:Say(nLin,0470,Transform(alltrim(_aTCSOper[i][y][1]),"@E 9"), oFont2) // Segmento
				oPrn:Say(nLin,0473," - " + SubStr(Posicione("SZA",1,xFilial("SZA")+alltrim(_aTCSOper[i][y][1]),AllTrim("ZA_DESC")),1,12), oFont2) // operação
				oPrn:Say(nLin,0790,Transform(alltrim(_aTCSOper[i][y][k][1]),"@E 99"), oFont2) // operação
				oPrn:Say(nLin,0815," - " + SubStr(Posicione("SX5",1,xFilial("SX5")+'DJ'+alltrim(_aTCSOper[i][y][k][1]),AllTrim("X5_DESCRI")),1,19), oFont2) // operação
				oPrn:Say(nLin,1220,Transform(_aTCSOper[i][y][k][2],"@E 999,999,999.99"), oFont2) // valor
				
				_nTotReg += _aTCSOper[i][y][k][2]
				_cNicho := _aTCSOper[i][1]
				nLin += nEsp
			Next k
		Next y
	Next i

	If !Empty(_cNicho) .Or. _nTotReg > 0
		oPrn:Box( nLin-5, 0050, nLin-5+50, oPrn:GetWidth()-1880)
		oPrn:Say(nLin,0060,"Total Canal: " + Transform(alltrim(_cNicho),"@E 99999"), oFont2) // Nicho
		oPrn:Say(nLin,0400," - " + AllTrim(Posicione("SZ0",1,xFilial("SZ0")+'CM'+_cNicho,"Z0_DESCRI")), oFont2) // operação
		oPrn:Say(nLin,1220,Transform(_nTotReg,"@E 999,999,999.99"), oFont2) // valor
	EndIf

	ASORT(_aTSOper, , , { | x,y | x[1] < y[1] } )
	nLin := nLinN
	_nTotReg := 0

	For i:=1 to Len(_aTSOper)
		If i != 1
			oPrn:Box( nLin-5, 1570, nLin-5+50, oPrn:GetWidth()-760)
			oPrn:Say(nLin,1600,"Total Segmento: " + Transform(alltrim(_cSegm),"@E 9"), oFont2) // segmento
			oPrn:Say(nLin,1870," - " +  Posicione("SZA",1,xFilial("SZA")+alltrim(_cSegm),AllTrim("ZA_DESC")), oFont2) // operação
			oPrn:Say(nLin,2375,Transform(_nTotReg,"@E 999,999,999.99"), oFont2) // valor
			nLin += nEsp
		EndIf
		_nTotReg := 0
		For y := 2 to Len(_aTSOper[i])
			oPrn:Box( nLin-5, 1570, nLin-5+50, oPrn:GetWidth()-760)
			oPrn:Line(nLin-5, 1870, nLin-5+50, 1870 )
			oPrn:Line(nLin-5, 2370, nLin-5+50, 2370 )
			//oPrn:Line(nLin-5, 2970, nLin-5+50, 2970 )
			
			oPrn:Say(nLin,1600,Transform(alltrim(_aTSOper[i][1]),"@E 9"), oFont2) // Segmento
			oPrn:Say(nLin,1615," - " + SubStr(Posicione("SZA",1,xFilial("SZA")+alltrim(_aTSOper[i][1]),AllTrim("ZA_DESC")),1,12), oFont2) // segmento
			oPrn:Say(nLin,1875,Transform(alltrim(_aTSOper[i][y][1]),"@E 99"), oFont2) // operação
			oPrn:Say(nLin,1910," - " + SubStr(Posicione("SX5",1,xFilial("SX5")+'DJ'+alltrim(_aTSOper[i][y][1]),AllTrim("X5_DESCRI")),1,19), oFont2) // operação
			oPrn:Say(nLin,2375,Transform(_aTSOper[i][y][2],"@E 999,999,999.99"), oFont2) // valor
			_nTotReg += _aTSOper[i][y][2]
			_cSegm := _aTSOper[i][1]
			nLin += nEsp
		Next y
	Next i
	
	If !Empty(_cSegm) .Or. _nTotReg > 0
		oPrn:Box( nLin-5, 1570, nLin-5+50, oPrn:GetWidth()-760)
		oPrn:Say(nLin,1600,"Total Segmento: " + Transform(alltrim(_cSegm),"@E 9"), oFont2) // Nicho
		oPrn:Say(nLin,1870," - " +  Posicione("SZA",1,xFilial("SZA")+alltrim(_cSegm),AllTrim("ZA_DESC")), oFont2) // operação
		oPrn:Say(nLin,2375,Transform(_nTotReg,"@E 999,999,999.99"), oFont2) // valor
	EndIf

	// RESUMO DAS OPERAÇÕES - 08/01/2021 - Solicitação Rubens
		
	nTotal:=0

	nLin := nLinN
	for i:=1 to Len(_aTOper)
		oPrn:Box( nLin-5, 2700, nLin-5+50, oPrn:GetWidth()-060)
		oPrn:Line(nLin-5, 3000, nLin-5+50, 3000 )
		
		oPrn:Say(nLin,2720,Transform(alltrim(_aTOper[i][1]),"@E 99"), oFont2) // operação
		oPrn:Say(nLin,2737," - " + SubStr(Posicione("SX5",1,xFilial("SX5")+'DJ'+alltrim(_aTOper[i][1]),AllTrim("X5_DESCRI")),1,12), oFont2) // operação
		oPrn:Say(nLin,3100,Transform(_aTOper[i][2],"@E 999,999,999.99"), oFont2) // valor
		
		nLin += nEsp
	next


endif

DbSelectArea("TSC5")
TSC5->( DbCloseArea() )
Set Century On

//SSI-123386 - Vagner Almeida - 30/08/2021 - Inicio
	If Len( aLinha ) > 0 .and. mv_par50 == 2
		GeraCSV( aLinha )
	EndIf
//SSI-123386 - Vagner Almeida - 30/08/2021 - Final

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
ElseIf xOper = "25" //SSI 22201
	cOper := "M" // MAQUETE SSI 22201
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
//Aadd(aRegs,{cPerg,"05","Tipo de Cliente               ","","","MV_CH5","N",20,0,0,"C","","mv_par05","Industrial","","","","","Comercial","","","","","Loja","","","","","Loja Exclusiva","","","","","Geral","","","","",""})
Aadd(aRegs,{cPerg,"05","Tipo de Cliente               ","","","MV_CH5","C",20,0,0,"G","U_fVlR077()","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aRegs,{cPerg,"06","Tabela De                     ","","","MV_CH6","C",3,0,0,"G","","mv_par06","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aRegs,{cPerg,"07","Tabela Ate                    ","","","MV_CH7","C",3,0,0,"G","","mv_par07","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aRegs,{cPerg,"08","Vendedor de                   ","","","MV_CH8","C",6,0,0,"G","","MV_PAR08","","","","","","","","","","","","","","","","","","","","","","","","","SA3",""})
Aadd(aRegs,{cPerg,"09","Vendedor até                  ","","","MV_CH9","C",6,0,0,"G","","MV_PAR09","","","","","","","","","","","","","","","","","","","","","","","","","SA3",""})
aAdd(aRegs,{cPerg,"10","Listar Pedidos de Terceiros   ","","","MV_CHA","N",1,0,0,"C","","MV_PAR10","Nao","","","","","Sim","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"11","Somente Pedidos em Atraso     ","","","MV_CHB","N",1,0,0,"C","","MV_PAR11","Nao","","","","","Sim","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"12","Somente Pedidos de Terceiros  ","","","MV_CHC","N",1,0,0,"C","","MV_PAR12","Nao","","","","","Sim","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"13","Listar Produtos               ","","","MV_CHD","N",1,0,0,"C","","MV_PAR13","Nao","","","","","Sim","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"14","(Trocas) Ordenado por         ","","","MV_CHE","N",1,0,0,"C","","MV_PAR14","Cliente","","","","","Bairro","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"15","Ped.c/ Data de Entrega		  ","","","MV_CHF","N",1,0,0,"C","","MV_PAR15","Todos","","","","","Somente","","","","","Exceto","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"16","Status do Pedido              ","","","MV_CHG","N",1,0,0,"C","","MV_PAR16","Geral","","","","","Liberados","","","","","Não Liberados","","","","","Quarentena","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"17","Em Lojas                      ","","","MV_CHH","N",1,0,0,"C","","MV_PAR17","Geral","","","","","Só Lojas ","","","","","Sem Lojas","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"18","Listar Res.Produtos           ","","","MV_CHI","N",1,0,0,"C","","MV_PAR18","Nao","","","","","Sim","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"19","Listar Rel.Prob.Cadastrais    ","","","MV_CHJ","N",1,0,0,"C","","MV_PAR19","Nao","","","","","Sim","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"20","Listar por segmento  		  ","","","MV_CHK","N",1,0,0,"C","","MV_PAR20","Nao","","","","","Sim","","","","","","","","","","","","","","","","","","","",""})
aAdd(aRegs,{cPerg,"21","Ordena por vendedores         ","","","MV_CHL","N",1,0,0,"C","","MV_PAR21","Nao","","","","","Sim","","","","","","","","","","","","","","","","","","","",""})
Aadd(aRegs,{cPerg,"22","Lista por Zona  	          ","","","MV_CHM","N",1,0,0,"C","","MV_PAR22","Nao","","","","","Sim","","","","","","","","","","","","","","","","","","","",""})
Aadd(aRegs,{cPerg,"23","Data Futura a Partir de       ","","","MV_CHN","D",8,0,0,"G","","MV_PAR23","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aRegs,{cPerg,"24","Dias em Atraso     	          ","","","MV_CHO","C",2,0,0,"G","","MV_PAR24","","","","","","","","","","","","","","","","","","","","","","","","","",""})
Aadd(aRegs,{cPerg,"25","Listar Pedidos de Troca       ","","","MV_CHP","N",1,0,0,"C","","MV_PAR25","Nao","","","","","Sim","","","","","","","","","","","","","","","","","","","",""})
Aadd(aRegs,{cPerg,"26","Listar Pedidos Normais        ","","","MV_CHQ","N",1,0,0,"C","","MV_PAR26","Nao","","","","","Sim","","","","","","","","","","","","","","","","","","","",""})
Aadd(aRegs,{cPerg,"27","Listar Pedidos de Quimico     ","","","MV_CHR","N",1,0,0,"C","","MV_PAR27","Nao","","","","","Sim","","","","","","","","","","","","","","","","","","","",""})
Aadd(aRegs,{cPerg,"28","Listar Pedidos de Demostracao ","","","MV_CHS","N",1,0,0,"C","","MV_PAR28","Nao","","","","","Sim","","","","","","","","","","","","","","","","","","","",""})
Aadd(aRegs,{cPerg,"29","Listar Pedidos de Reposicao   ","","","MV_CHT","N",1,0,0,"C","","MV_PAR29","Nao","","","","","Sim","","","","","","","","","","","","","","","","","","","",""})
Aadd(aRegs,{cPerg,"30","Listar Pedidos de Bonificacao ","","","MV_CHU","N",1,0,0,"C","","MV_PAR30","Nao","","","","","Sim","","","","","","","","","","","","","","","","","","","",""})
Aadd(aRegs,{cPerg,"31","Listar Pedidos de Conserto    ","","","MV_CHV","N",1,0,0,"C","","MV_PAR31","Nao","","","","","Sim","","","","","","","","","","","","","","","","","","","",""})
Aadd(aRegs,{cPerg,"32","Listar Pedidos de Nao Repor   ","","","MV_CHW","N",1,0,0,"C","","MV_PAR32","Nao","","","","","Sim","","","","","","","","","","","","","","","","","","","",""})
Aadd(aRegs,{cPerg,"33","Listar Outros                 ","","","MV_CHX","N",1,0,0,"C","","MV_PAR33","Nao","","","","","Sim","","","","","","","","","","","","","","","","","","","",""})
Aadd(aRegs,{cPerg,"34","Gerente                       ","","","MV_CHY","C",6,0,0,"G","","MV_PAR34","","","","","","","","","","","","","","","","","","","","","","","","","SA3",""})
Aadd(aRegs,{cPerg,"35","Somente Pedidos:              ","","","MV_CHZ","N",1,0,0,"C","","MV_PAR35","Todos"  ,"","","","","Sem Restricao","","","","","Com Restriçao","","","","","","","","","","","","","","",""})
Aadd(aRegs,{cPerg,"36","Agrupa Clientes 			  ","","","MV_CAA","N",1,0,0,"C","","MV_PAR36","Nao","","","","","Sim","","","","","","","","","","","","","","","","","","","",""})
Aadd(aRegs,{cPerg,"37","Exibir MIX e KG?    		  ","","","MV_CAB","N",1,0,0,"C","","MV_PAR37","Nao","","","","","Sim","","","","","","","","","","","","","","","","","","","",""})
Aadd(aRegs,{cPerg,"38","Tipo de Bloqueio              ","","","mv_ch38","N" ,01,0,0,"C","","MV_PAR38","Nenhuma opção","","","","","Cobranca","","","","","Comercial","","","","","Cobr e Come","","","","","","","","","",""})
Aadd(aRegs,{cPerg,"39","Gerente Prático               ","","","MV_CAC","C",6,0,0,"G","","MV_PAR39","","","","","","","","","","","","","","","","","","","","","","","","","SA3",""}) //SSI 7169
Aadd(aRegs,{cPerg,"40","Assessor                      ","","","MV_CAD","C",6,0,0,"G","","MV_PAR40","","","","","","","","","","","","","","","","","","","","","","","","","SA3",""}) //SSI 7169

*'Pedidos de outras unidades - Márcio Sobreira -----------------------------------------------'*
Aadd(aRegs,{cPerg,"41","Listar Outras Unidades        ","","","mv_ch41","N" ,01,0,0,"C","","MV_PAR41","Nenhum","","","","","Origem","","","","","Destino","","","","","","","","","","","","","","",""})
*'--------------------------------------------------------------------------------------------------'*

Aadd(aRegs,{cPerg,"42","Filtrar por Bairro            ","","","mv_ch42","C",10,0,0,"G","","mv_par42","","","","","","","","","","","","","","",""  ,"","","","","","","","","","",""})

/* PARÂMETRO PARA IMPRESSÃO DE ASSISTÊNCIA TÉCNICA PARA USO DO SAC - SOLICITAÇÃO SR. ELOI 14/08/2019  */
Aadd(aRegs,{cPerg,"43","Imp. Num. Assist. Tec.       ","","","MV_CAE","N",1,0,0,"C","","MV_PAR43","Nao","","","","","Sim","","","","","","","","","","","","","","","","","","","",""})
/* PARÂMETRO PARA IMPRESSÃO DE ASSISTÊNCIA TÉCNICA PARA USO DO SAC - SOLICITAÇÃO SR. ELOI 14/08/2019*/
Aadd(aRegs,{cPerg,"44","Remessa por conta e ordem    ","","","MV_CH44","N",1,0,0,"C","","MV_PAR44","Nao","","","","","Sim","","","","","Somente","","","","","","","","","","","","","","",""})

/* IMPRESSAO DE OPERADOR LOGÍSTICO - SSI 85327 */
Aadd(aRegs,{cPerg,"45","Imprime apenas Op. Log.    ","","","MV_CH45","N",1,0,0,"C","","MV_PAR45","Nao","","","","","Sim","","","","","Ambos","","","","","","","","","","","","","","",""})
/* IMPRESSAO DE OPERADOR LOGÍSTICO - SSI 85327 */

//Aadd(aRegs,{cPerg,"38","Gerente Prático"	          ,"","","MV_CAC","C",6,0,0,"G","","MV_PAR38","","","","","","","","","","","","","","","","","","","","","","","","","SA3",""}) //SSI 7169
//Aadd(aRegs,{cPerg,"39","Assessor"		  			      ,"","","MV_CAD","C",6,0,0,"G","","MV_PAR39","","","","","","","","","","","","","","","","","","","","","","","","","SA3",""}) //SSI 7169

Aadd(aRegs,{cPerg,"46","Canal de                   ","","","MV_CAF","C",5,0,0,"G","","MV_PAR46","","","","","","","","","","","","","","","","","","","","","","","","","SZ0CM",""})
Aadd(aRegs,{cPerg,"47","Canal até                  ","","","MV_CAG","C",5,0,0,"G","","MV_PAR47","","","","","","","","","","","","","","","","","","","","","","","","","SZ0CM",""})

/* SSI 113374 */
Aadd(aRegs,{cPerg,"48","Imp. Num. ID Ortobom       ","","","MV_CAE","N",1,0,0,"C","","MV_PAR48","Nao","","","","","Sim","","","","","","","","","","","","","","","","","","","",""})
Aadd(aRegs,{cPerg,"49","Prev. Entreg.		       ","","","MV_CAE","N",1,0,0,"C","","MV_PAR49","Nao","","","","","Sim","","","","","","","","","","","","","","","","","","","",""})
/* SSI 113374 */

//SSI-123386 - Vagner Almeida - 30/08/2021 - Inicio
Aadd(aRegs,{cPerg,"50","Gerar Arquivo CSV?		   ","","","MV_CAH","N",1,0,0,"C","","MV_PAR50","Nao","","","","","Sim","","","","","","","","","","","","","","","","","","","",""})
//SSI-123386 - Vagner Almeida - 30/08/2021 - Final

//SSI-123499 - Vagner Almeida - 13/09/2021 - Inicio
Aadd(aRegs,{cPerg,"51","Desconto SIMBAHIA?		   ","","","MV_CAI","N",1,0,0,"C","","MV_PAR51","Nao","","","","","Sim","","","","","","","","","","","","","","","","","","","",""})
//SSI-123499 - Vagner Almeida - 13/09/2021 - Final

// SSI - 126242 Diogo Melo 30/12/2021
Aadd(aRegs,{cPerg,"52","ROTA De                      ","","","MV_CHJ","C",6,0,0,"G","","MV_PAR52","","","","","","","","","","","","","","","","","","","","","","","","","SZ3",""})
Aadd(aRegs,{cPerg,"53","ROTA Ate                     ","","","MV_CHL","C",6,0,0,"G","","MV_PAR53","","","","","","","","","","","","","","","","","","","","","","","","","SZ3",""})
// SSI - 126242 Diogo Melo 30/12/2021

//Cria 8Pergunta
DbSelectArea("SX1")
dbSetOrder(1)//NAO TROCAR
If dbSeek(PadR(cPerg,10)+"05")
	&&do while cPerg==SX1->X1_GRUPO
	If Empty(SX1->X1_VALID)
		If RecLock("SX1",.F.)
			SX1->(DbDelete())
			SX1->(MsUnlock())
		EndIf
		SX1->(DbSkip())
	EndIf
	&&enddo
endif

cPerg := U_AjustaSx1(cPerg,aRegs)

RestArea( aAreaAtu )
Return(.T.)

***********************
User Function fVlR077()
***********************

Local oDlg1

oDlg1 := MSDialog():New( 088,232,290,722,"Selecionar Segmento",,,.F.,,,,,,.T.,,,.T. )
oDlg1:bInit := {||EnchoiceBar(oDlg1,{|| (MV_PAR05:=oListBox1:AARRAY[oListBox1:nAt,1]),nMV_PAR05:=aScan(aOpc,{|x| x[1] == AllTrim(MV_PAR05)}),oDlg1:End()},{||oDlg1:End() },.F.,{})}
oGrp2 := TGroup():New( 013,001,103,244,"",oDlg1,CLR_BLACK,CLR_WHITE,.T.,.F. )
@ 015,003 ListBox oListBox1 Fields ;
HEADER "Segmento";
Size 238,080 Of oGrp2 Pixel;
ColSizes 80 ;
On DBLCLICK fSaiR077(oDlg1)

oListBox1:SetArray(aOpc)
oListBox1:bLine := {|| {aOpc[oListBox1:nAt,1]}}

oDlg1:Activate(,,,.T.)
nMV_PAR05:=aScan(aOpc,{|x| x[1] == AllTrim(MV_PAR05)})
Return(.T.)

*******************************
Static Function fSaiR077(oDlg1)
*******************************

MV_PAR05 :=oListBox1:AARRAY[oListBox1:nAt,1]
nMV_PAR05:=oListBox1:nAt
oDlg1:End()

Return(.T.)

*---------------------------------*
Static Function fImpCab(cTp, lPrimeira, oPrn)
*---------------------------------*

nPag	+= 1
nCol	:= 0
cCol 	:= Space(0)
nEsp	:= 50

If !_lRpc
	If !lPrimeira
		oPrn:EndPage()
	EndIf
	oPrn:StartPage()
	
	//oPrn:Box ( [ nRow], [ nCol], [ nBottom], [ nRight] )
	oPrn:Box( 50, 50, 200, oPrn:GetWidth()-55 ) 
	oPrn:Box( 49, 49, 199, oPrn:GetWidth()-54 ) 
	
	// Lado Esquerdo
	oPrn:Say ( 085, 95, "Hora: " + cHora + " - (" + nomeprog + ")"     , oFontM)
	oPrn:Say ( 125, 95, "Empresa: " + cEmpAnt + " / Filial: " + cNomFil, oFontM)
	
	// Centro
	oPrn:Say ( 110 , 1200, Upper(titulo), oFontM)
	
	// Lado Direito
	nTam := Len("Emissão:" + Dtos(Date())) + 300
	oPrn:Say ( 085, oPrn:GetWidth()-nTam, "Folha: " + AllTrim(Str(nPag)), oFontM) 
	oPrn:Say ( 125, oPrn:GetWidth()-nTam, "Emissão:" + DtoC(Date()), oFontM) 
	
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
	Elseif MV_PAR16 = 4
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
	
	IF nMV_PAR05 = 1
		oPrn:Say ( nLin, 060, Space(098) + "Tipo de Cliente : Industrial", oFont2)
	ELSEIF nMV_PAR05 = 2
		oPrn:Say ( nLin, 060, Space(098) + "Tipo de Cliente : Comercial", oFont2)
	ELSEIF nMV_PAR05 = 3
		oPrn:Say ( nLin, 060, Space(098) + "Tipo de Cliente : Loja", oFont2)
	ELSEIF nMV_PAR05 = 4
		oPrn:Say ( nLin, 060, Space(098) + "Tipo de Cliente : Loja Exclusiva", oFont2)
	ELSEIF nMV_PAR05 = 5
		oPrn:Say ( nLin, 060, Space(098) + "Tipo de Cliente : Site", oFont2)
	ELSEIF nMV_PAR05 = 7
		oPrn:Say ( nLin, 060, Space(098) + "Tipo de Cliente : Comercial Exc.", oFont2)
	ELSE
		oPrn:Say ( nLin, 060, Space(098) + "Tipo de Cliente : Geral", oFont2)
	ENDIF

	IF MV_PAR11 = 1
		oPrn:Say ( nLin, 060, Space(133) + "Somente Pedidos em Atraso : NAO "	, oFont2)
	Else
		oPrn:Say ( nLin, 060, Space(133) + "Somente Pedidos em Atraso : SIM "	, oFont2)
	Endif
	
	nLin += nEsp

	oPrn:Say ( nLin, 060, "Canal: "+Alltrim(MV_PAR46)+" - "+AllTrim(Posicione("SZ0",1,xFilial("SZ0")+'CM'+MV_PAR46,"Z0_DESCRI"))+" ate "+Alltrim(MV_PAR47)+" - "+AllTrim(Posicione("SZ0",1,xFilial("SZ0")+'CM'+MV_PAR47,"Z0_DESCRI")), oFont2)

	nLin += nEsp
	oPrn:Say ( nLin, 060, Space(000) + "Vendedor de : " + MV_PAR08 + " ate " + MV_PAR09	, oFont2)
	oPrn:Say ( nLin, 060, Space(038) + "Cliente  de : " + MV_PAR01 + " ate " + MV_PAR03, oFont2)
	If MV_PAR43 = 1 //SOLICITACAO ELOI 14/08/2019
		oPrn:Say ( nLin, 060, Space(082) + "Tabela de : " + MV_PAR06 + " ate " + MV_PAR07		, oFont2)
	EndIf
	
	//LUCIANO - SSI 26736 - Imprimir razoes agrupadas
	If MV_PAR36 <> 2
		oPrn:Say ( nLin, 060, Space(115) + "Clientes Agrupados : NAO ", oFont2)
	Else
		oPrn:Say ( nLin, 060, Space(115) + "Clientes Agrupados : SIM ", oFont2)
	Endif
	//Fim - SSI 26736 - Imprimir razoes agrupadas
	
	If MV_PAR38 = 1
		oPrn:Say ( nLin, 060, Space(150) + "Tipo de bloqueio : Nenhum", oFont2)
	Elseif MV_PAR38 = 2
		oPrn:Say ( nLin, 060, Space(150) + "Tipo de bloqueio : Cobranca ", oFont2)
	Elseif MV_PAR38 = 3
		oPrn:Say ( nLin, 060, Space(150) + "Tipo de bloqueio : Comercial ", oFont2)
	else
		oPrn:Say ( nLin, 060, Space(150) + "Tipo de bloqueio : Cobranca/Comercial ", oFont2)
	Endif
	
	If empty(alltrim(MV_PAR42))
		oPrn:Say ( nLin, 090, Space(180) + "Bairro : Todos", oFont2)
	Else
		oPrn:Say ( nLin, 090, Space(180) + "Bairro : "+MV_PAR42, oFont2)
	Endif
	
	oPrn:Say ( nLin, 350, Space(180) + "Desconto Bahia : " + Iif(MV_PAR51 == 1,"Nao","Sim"), oFont2) //SSI-123499 - Vagner Almeida - 13/09/2021
	
	
	nLin += nEsp
	oPrn:Line(nLin  , 50, nLin  , oPrn:GetWidth()-50 ) // oPrn:GetWidth()
	oPrn:Line(nLin+2, 50, nLin+2, oPrn:GetWidth()-50 ) // oPrn:GetWidth()
	oPrn:Line(nLin+4, 50, nLin+4, oPrn:GetWidth()-50 ) // oPrn:GetWidth()
	
	nLin += nEsp
	If cTp == "1"
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:GetWidth()-52 ) // oPrn:GetWidth()
		oPrn:Line(nLin-5,  145, nLin-5+50,  145 ) // INDICE PEDIDO
		If MV_PAR43 = 2
			oPrn:Line(nLin-5,  300, nLin-5+50,  300 ) // ASSIST. TECNICA
		EndIf
		/* SSI 113374 */
		If MV_PAR48 = 2
			oPrn:Line(nLin-5,  300+nFatPos, nLin-5+50,  300+nFatPos ) // ID ORTOBOM
		EndIf
		/* SSI 113374 */
		oPrn:Line(nLin-5,  200+100+nFatPos+nFatPosII, nLin-5+50,  200+100+nFatPos+nFatPosII ) // PEDIDO LIB
		oPrn:Line(nLin-5,  290+080+nFatPos+nFatPosII, nLin-5+50,  290+080+nFatPos+nFatPosII ) // LIB CD/CM
		oPrn:Line(nLin-5,  450+040+nFatPos+nFatPosII, nLin-5+50,  450+040+nFatPos+nFatPosII ) // CD/CM EMISSAO
		oPrn:Line(nLin-5,  650+020+nFatPos+nFatPosII, nLin-5+50,  650+020+nFatPos+nFatPosII ) // EMISSAO LIBERACAO
		oPrn:Line(nLin-5,  850-020+nFatPos+nFatPosII, nLin-5+50,  850-020+nFatPos+nFatPosII ) // LIBERACAO REVALID
		oPrn:Line(nLin-5,  980-000+nFatPos+nFatPosII, nLin-5+50,  980-000+nFatPos+nFatPosII ) // REVALID DIAS
		oPrn:Line(nLin-5, 1060+000+nFatPos+nFatPosII, nLin-5+50, 1060+000+nFatPos+nFatPosII ) // DIAS ENTREGA
		oPrn:Line(nLin-5, 1370+000+nFatPos+nFatPosII, nLin-5+50, 1370+000+nFatPos+nFatPosII ) // ENTREGA TP
		oPrn:Line(nLin-5, 1420+010+nFatPos+nFatPosII, nLin-5+50, 1420+010+nFatPos+nFatPosII ) // TP SEG
		oPrn:Line(nLin-5, 1485+000+nFatPos+nFatPosII, nLin-5+50, 1485+000+nFatPos+nFatPosII ) // SEG VEND
		/* SSI 113374 Adicionado If/Else */
		If MV_PAR48 = 2 .and. MV_PAR43 = 2
			oPrn:Line(nLin-5, 1710+000+nFatPos+nFatPosII, nLin-5+50, 1710+000+nFatPos+nFatPosII ) // VEND CLIENTE
		Else
			oPrn:Line(nLin-5, 1740+000+nFatPos+nFatPosII, nLin-5+50, 1740+000+nFatPos+nFatPosII ) // VEND CLIENTE
		EndIf
		/* SSI 113374 */
		If MV_PAR48 = 2 .and. MV_PAR43 = 2
			oPrn:Line(nLin-5, 1980+000+nFatPos+nFatPosII, nLin-5+50, 1980+000+nFatPos+nFatPosII ) // CLIENTE VLR
		Else
			oPrn:Line(nLin-5, 2010+000+nFatPos+nFatPosII, nLin-5+50, 2010+000+nFatPos+nFatPosII ) // CLIENTE VLR
		EndIf
		oPrn:Line(nLin-5, 2195+000+nFatPos+nFatPosII, nLin-5+50, 2195+000+nFatPos+nFatPosII ) // VLR ZONA
		//	oPrn:Line(nLin-5, 2912-40-30, nLin-5+50, 2912-40-30 ) // ZONA CIDADE ULT.CARG
		//	oPrn:Line(nLin-5, 3090-40-30, nLin-5+50, 3090-40-30 ) // ULT.CARG ESPACOS
		//	oPrn:Line(nLin-5, 3248-45-30, nLin-5+50, 3248-45-30 ) // ESPACOS ROT
		//	oPrn:Line(nLin-5, 3330-60-30, nLin-5+50, 3330-60-30 ) // ROT TAB
		
		oPrn:Line(nLin-5, 2405+000+nFatPos+nFatPosII, nLin-5+50, 2405+000+nFatPos+nFatPosII ) // ZONA CIDADE BAIRRO
		/* SSI 113374 Adicionado If/Else */
		If MV_PAR48 = 1
			oPrn:Line(nLin-5, 2820+000+nFatPos+nFatPosII, nLin-5+50, 2820+000+nFatPos+nFatPosII ) // BAIRRO ULT.CARG
		ElseIf MV_PAR48 = 2 .and. MV_PAR43 = 2
			oPrn:Line(nLin-5, 2710+000+nFatPos+nFatPosII, nLin-5+50, 2710+000+nFatPos+nFatPosII ) // BAIRRO ULT.CARG
		Else
			oPrn:Line(nLin-5, 2730+000+nFatPos+nFatPosII, nLin-5+50, 2730+000+nFatPos+nFatPosII ) // BAIRRO ULT.CARG
		EndIf
		/* SSI 113374 */
		oPrn:Line(nLin-5, 3000+000+nFatPos+nFatPosII, nLin-5+50, 3000+000+nFatPos+nFatPosII ) // ULT.CARG ESPACOS
		oPrn:Line(nLin-5, 3000+000+nFatPos+nFatPosII, nLin-5+50, 3000+000+nFatPos+nFatPosII ) // ROT
		oPrn:Line(nLin-5, 3320+000+nFatPos+nFatPosII, nLin-5+50, 3320+000+nFatPos+nFatPosII ) // TAB 
		oPrn:Line(nLin-5, 3380+000+nFatPos+nFatPosII, nLin-5+50, 3380+000+nFatPos+nFatPosII ) // OPL

		/*
		If MV_PAR43 = 1
			oPrn:Line(nLin-5, 3225-45-30, nLin-5+50, 3225-45-30 ) // ESPACOS ROT
			oPrn:Line(nLin-5, 3240+000, nLin-5+50, 3240+000 ) // ROT TAB
		EndIf
		*/
		If MV_PAR43 = 1 .and. MV_PAR48 = 1
			oPrn:Line(nLin-5, 3225-45-30, nLin-5+50, 3225-45-30 ) // ESPACOS ROT
			oPrn:Line(nLin-5, 3240+000, nLin-5+50, 3240+000 ) // ROT TAB
		EndIf
		oPrn:Say(nLin,0060,"NUM.", oFont2)
		oPrn:Say(nLin,0150,"PEDIDO", oFont2)
		If MV_PAR43 = 2
			oPrn:Say(nLin,0325,"ASS. TEC.", oFont2)
		EndIf
		/* SSI 113374 */
		If MV_PAR48 = 2
			oPrn:Say(nLin,0325+nFatPos,"ID ORT.", oFont2)
		EndIf
		/* SSI 113374 */
		oPrn:Say(nLin,0325+nFatPos+nFatPosII,"LIB", oFont2)
		IF MV_PAR37 == 1
			oPrn:Say(nLin,0405+nFatPos+nFatPosII,"CD/CM ", oFont2)
		Else
			oPrn:Say(nLin,0425-20+nFatPos+nFatPosII,"CD/CM MIX", oFont2)
		EndIf
		oPrn:Say(nLin,0525+nFatPos+nFatPosII,"EMISSAO", oFont2)
		oPrn:Say(nLin,0675+nFatPos+nFatPosII,"LIBERACAO", oFont2)
		oPrn:Say(nLin,0850+nFatPos+nFatPosII,"REVALID", oFont2)
		oPrn:Say(nLin,1000+nFatPos+nFatPosII,"DIAS", oFont2)
		/* SSI 113374 */
		//oPrn:Say(nLin,1090+nFatPos+nFatPosII,"ENTREGA", oFont2)
		If MV_PAR49 = 1
			oPrn:Say(nLin,1090+nFatPos+nFatPosII,"ENTREGA", oFont2)
		Else
			oPrn:Say(nLin,1090+nFatPos+nFatPosII,"PRE. ENT.", oFont2)
		EndIf
		/* SSI 113374 */
		oPrn:Say(nLin,1390+nFatPos+nFatPosII,"TP", oFont2)
		oPrn:Say(nLin,1440+nFatPos+nFatPosII,"SEG", oFont2)
		oPrn:Say(nLin,1510+nFatPos+nFatPosII,"VEND", oFont2)		
		oPrn:Say(nLin,1780+nFatPos+nFatPosII,"CLIENTE", oFont2)
		oPrn:Say(nLin,2055+nFatPos+nFatPosII,"VALOR", oFont2)
		oPrn:Say(nLin,2205+nFatPos+nFatPosII,"ZONA CIDADE", oFont2)		
		oPrn:Say(nLin,2425+nFatPos+nFatPosII,"BAIRRO", oFont2)	// 2800		
		oPrn:Say(nLin,3330+nFatPos+nFatPosII,"OPL", oFont2)
		oPrn:Say(nLin,3400+nFatPos+nFatPosII,"EXC", oFont2)
		//oPrn:Say(nLin,2850,"CARGA ROT", oFont2)
		/* SSI 113374 Adicionado If/Else */
		If MV_PAR43 = 2 .and. MV_PAR48 = 2
			oPrn:Say(nLin,2730+nFatPos+nFatPosII,"CARGA ROT", oFont2)
		ElseIf MV_PAR43 = 1 .and. MV_PAR48 = 2
			oPrn:Say(nLin,2770+nFatPos+nFatPosII,"CARGA ROT", oFont2)
		Else
			oPrn:Say(nLin,2860+nFatPos+nFatPosII,"CARGA ROT", oFont2)
		EndIf
		/* SSI 113374 */
		IF MV_PAR37 == 1
			//oPrn:Say(nLin,3025,"ESPACOS", oFont2)
			If MV_PAR43 = 2 .and. MV_PAR48 = 2
				oPrn:Say(nLin,3005+nFatPos+nFatPosII,"ESPACOS", oFont2)
			Else
				oPrn:Say(nLin,3035+nFatPos+nFatPosII,"ESPACOS", oFont2)
			EndIf
		Else
			oPrn:Say(nLin,3050+nFatPos+nFatPosII,"KG", oFont2)
		EndIf
		/*
		If MV_PAR43 = 1 //SOLICITACAO ELOI 14/08/2019
			//oPrn:Say(nLin,3175,"ROT", oFont2)
			oPrn:Say(nLin,3170+nFatPos+nFatPosII,"ROT", oFont2)
			//oPrn:Say(nLin,3250,"TAB", oFont2)
			oPrn:Say(nLin,3250+nFatPos+nFatPosII,"TAB", oFont2)
		EndIf
		*/
		If MV_PAR43 = 1 .and. MV_PAR48 = 1
			//oPrn:Say(nLin,3175,"ROT", oFont2)
			oPrn:Say(nLin,3170+nFatPos+nFatPosII,"ROT", oFont2)
			//oPrn:Say(nLin,3250,"TAB", oFont2)
			oPrn:Say(nLin,3250+nFatPos+nFatPosII,"TAB", oFont2)
		EndIf

	ElseIf cTp == "2"
		
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:GetWidth()-50 )
		oPrn:Line(nLin-5,  200, nLin-5+50,  200 ) // PEDIDO LIB
		
		oPrn:Say(nLin,0060,"PEDIDO", oFont2)
		oPrn:Say(nLin,0225,"PROBLEMAS NO SISTEMA DE CADASTRO", oFont2)
		
	ElseIf cTp == "3"
		
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:GetWidth()-50 )
		oPrn:Line(nLin-5,  265, nLin-5+50,  265 ) // CODIGO DENOMINACAO
		oPrn:Line(nLin-5,  1100, nLin-5+50,  1100 ) // DENOMINACAO MEDIDAS
		oPrn:Line(nLin-5,  1405, nLin-5+50,  1405 ) // MEDIDAS CARTEIRA
		oPrn:Line(nLin-5,  1600, nLin-5+50,  1600 ) // CARTEIRA ESTQ
		oPrn:Line(nLin-5,  1720, nLin-5+50,  1720 ) // ESTQ RESULT
		oPrn:Line(nLin-5,  1885, nLin-5+50,  1885 ) // RESULT SOLICITADO
		oPrn:Line(nLin-5,  2120, nLin-5+50,  2120 ) // SOL.COMPRA DT.SOLICITACAO DT.PREV.ENTREGA
		oPrn:Line(nLin-5,  2830, nLin-5+50,  2830 ) // PEDIDOS
		oPrn:Line(nLin-5,  2965, nLin-5+50,  2965 ) // ULT TR.
		oPrn:Line(nLin-5,  3115, nLin-5+50,  3115 ) // ULT PD.
		oPrn:Line(nLin-5,  3265, nLin-5+50,  3265 ) //
		
		oPrn:Say(nLin,0060,"CODIGO",oFont2)
		oPrn:Say(nLin,0275,"DENOMINACAO",oFont2)
		oPrn:Say(nLin,1110,"MEDIDAS",oFont2)
		oPrn:Say(nLin,1420,"CARTEIRA",oFont2)
		oPrn:Say(nLin,1610,"ESTQ",oFont2)
		oPrn:Say(nLin,1725,"RESULT",oFont2)
		oPrn:Say(nLin,1900,"SOLICITADO",oFont2)
		oPrn:Say(nLin,2125,"SOL.COMPRA DT.SOLICITACAO DT.PREV.ENTREGA",oFont2)
		oPrn:Say(nLin,2840,"PEDIDOS",oFont2)
		oPrn:Say(nLin,2975,"DIAS TR",oFont2)
		oPrn:Say(nLin,3125,"DIAS PN",oFont2)
		
	ElseIf cTp == "V"
		
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
		
	ElseIf cTp == "VB"
		
		oPrn:Say(nLin,065,"BAHIA", oFont2)
		
		nLin += nEsp
		
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
		
	ElseIf cTp == "4"
		
		oPrn:Box( nLin-5,0050,nLin-5+50,oPrn:GetWidth()-2140)
		oPrn:Line(nLin-5,0270,nLin-5+50,0270) //
		oPrn:Line(nLin-5,0460,nLin-5+50,0460) //
		oPrn:Line(nLin-5,0850,nLin-5+50,0850) //
		
		oPrn:Say(nLin,0060,"ZONA  VEND",oFont2)
		oPrn:Say(nLin,0300,"ITIN."     ,oFont2)
		oPrn:Say(nLin,0575,"ESPACOS"   ,oFont2)
		oPrn:Say(nLin,0975,"VALOR"     ,oFont2)
		
	ElseIf cTp == "4B"
		
		oPrn:Say(nLin,065,"BAHIA", oFont2)
		
		nLin += nEsp
		
		oPrn:Box( nLin-5,0050,nLin-5+50,oPrn:GetWidth()-2140)
		oPrn:Line(nLin-5,0270,nLin-5+50,0270) //
		oPrn:Line(nLin-5,0460,nLin-5+50,0460) //
		oPrn:Line(nLin-5,0850,nLin-5+50,0850) //
		
		oPrn:Say(nLin,0060,"ZONA  VEND",oFont2)
		oPrn:Say(nLin,0300,"ITIN."     ,oFont2)
		oPrn:Say(nLin,0575,"ESPACOS"   ,oFont2)
		oPrn:Say(nLin,0975,"VALOR"     ,oFont2)
		
	ElseIf cTp == "5"
		
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:GetWidth()-50 )
		oPrn:Say(nLin,0060,"SEGMENTOS", oFont2)
		
	ElseIf cTp == "P"
		
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:GetWidth()-50 )
		oPrn:Line(nLin-5,  145, nLin-5+50,  145 ) // INDICE PEDIDO
		oPrn:Line(nLin-5,  200+100, nLin-5+50,  200+100 ) // PEDIDO LIB
		
		oPrn:Say(nLin,0060,"NUM.",oFont2)
		oPrn:Say(nLin,0150,"PEDIDO",oFont2)
		oPrn:Say(nLin,0350,"PRODUTOS",oFont2)
		
	ElseIf cTp == "7"
		
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:GetWidth()-1460)
		//oPrn:Say(nLin,0060,"                                  10 Maiores Clientes                                  ", oFont2)
		oPrn:Say(nLin,0060,"                                  30 Maiores Clientes                                  ", oFont2)
		
	ElseIf cTp == "8"
		
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:GetWidth()-50 )
		oPrn:Line(nLin-5,  310, nLin-5+50,  265 ) // PEDIDO LIB
		
		oPrn:Say(nLin,60,"ZONA DE ENTREGA        ESPACOS          VALOR", oFont2)
		
	Elseif cTp == "9"
		
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:GetWidth()-825 )
		oPrn:Line(nLin-5,  265, nLin-5+50,  265 )
		oPrn:Line(nLin-5,  655, nLin-5+50,  655 )
		oPrn:Line(nLin-5, 1010, nLin-5+50, 1010 )
		oPrn:Line(nLin-5, 1390, nLin-5+50, 1390 )
		oPrn:Line(nLin-5, 1700, nLin-5 +50, 1700 )
		oPrn:Line(nLin-5, 2060, nLin-5+50, 2060 )
		oPrn:Line(nLin-5, 2400, nLin-5+50, 2400 )
		
		oPrn:Say(nLin,0060,"ZONA", oFont2)
		oPrn:Say(nLin,0375,"ESPAÇOS LIVRE", oFont2)
		oPrn:Say(nLin,0780,"VALOR LIVRE", oFont2)
		oPrn:Say(nLin,1075,"ESPAÇOS FUTURO", oFont2)
		oPrn:Say(nLin,1445,"VALOR FUTURO", oFont2)
		oPrn:Say(nLin,1775,"ESPAÇOS TOTAL", oFont2)
		oPrn:Say(nLin,2175,"VALOR TOTAL", oFont2)
		oPrn:Say(nLin,2450,"DIAS", oFont2)
		
		/*
		oPrn:Say(nLin,0375,Transform(_aResumo2[d][4], "@E 99,999,999.99"), oFont2)
		oPrn:Say(nLin,0730,Transform(_aResumo2[d][5], "@E 99,999,999.99"), oFont2)
		oPrn:Say(nLin,1105,Transform(_aResumo2[d][6], "@E 99,999,999.99"), oFont2)
		oPrn:Say(nLin,1420,Transform(_aResumo2[d][7], "@E 99,999,999.99"), oFont2)
		
		oPrn:Say(nLin,1775,Transform(_aResumo2[d][2], "@E 99,999,999.99"), oFont2)
		oPrn:Say(nLin,2125,Transform(_aResumo2[d][3], "@E 99,999,999.99"), oFont2)
		oPrn:Say(nLin,2475,Transform( (dDa
		ase - stod( _aResumo2[d][8] ) ), "@E 999"), oFont2)
		*/
	Elseif cTp == "9B"
		
		oPrn:Say(nLin,65,"BAHIA", oFont2)
		
		nLin += nEsp
		
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:GetWidth()-825 )
		oPrn:Line(nLin-5,  265, nLin-5+50,  265 )
		oPrn:Line(nLin-5,  655, nLin-5+50,  655 )
		oPrn:Line(nLin-5, 1010, nLin-5+50, 1010 )
		oPrn:Line(nLin-5, 1390, nLin-5+50, 1390 )
		oPrn:Line(nLin-5, 1700, nLin-5+50, 1700 )
		oPrn:Line(nLin-5, 2060, nLin-5+50, 2060 )
		oPrn:Line(nLin-5, 2400, nLin-5+50, 2400 )
		
		oPrn:Say(nLin,0060,"ZONA", oFont2)
		oPrn:Say(nLin,0375,"ESPAÇOS LIVRE", oFont2)
		oPrn:Say(nLin,0780,"VALOR LIVRE", oFont2)
		oPrn:Say(nLin,1075,"ESPAÇOS FUTURO", oFont2)
		oPrn:Say(nLin,1445,"VALOR FUTURO", oFont2)
		oPrn:Say(nLin,1775,"ESPAÇOS TOTAL", oFont2)
		oPrn:Say(nLin,2175,"VALOR TOTAL", oFont2)
		oPrn:Say(nLin,2450,"DIAS", oFont2)
		
	ElseIf cTp == "A"
		
		oPrn:Box( nLin-5, 50, nLin-5+50, oPrn:GetWidth()-50 )
		oPrn:Line(nLin-5,  265, nLin-5+50,  265 ) // CODIGO DENOMINACAO
		oPrn:Line(nLin-5,  1100, nLin-5+50,  1100 ) // DENOMINACAO MEDIDAS
		oPrn:Line(nLin-5,  1405, nLin-5+50,  1405 ) // MEDIDAS CARTEIRA
		
		oPrn:Say(nLin,0060,"CODIGO",oFont2)
		oPrn:Say(nLin,0275,"DENOMINACAO",oFont2)
		oPrn:Say(nLin,1110,"MEDIDAS",oFont2)
		oPrn:Say(nLin,1425,"PEDIDOS",oFont2)
		
	ElseIf cTp == "SGOP"
		
		oPrn:Box(nLin-5, 50, nLin-5+50, oPrn:GetWidth()-1920)
		oPrn:Say(nLin,450,"Total por Canal/Segmento/Operaçao", oFont2)
		
		oPrn:Box(nLin-5, oPrn:GetWidth()-1920, nLin-5+50, oPrn:GetWidth()-810)
		oPrn:Say(nLin,1980,"Total por Segmento/Operaçao", oFont2)

		oPrn:Box(nLin-5, oPrn:GetWidth()-810, nLin-5+50, oPrn:GetWidth()-060)
		oPrn:Say(nLin,2930,"Total por Operaçao", oFont2)
	
	Endif
endif
nLin += nEsp
x := 0
Return(nLin)

Static Function fImpPedProb(_aPedProb)
**************************************
//"RESUMO DOS PEDIDOS COM PROBLEMAS CADASTRAIS"
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
	If !_lRpc
		oPrn:Box( nLin-5, 50, nLin-5+100, oPrn:GetWidth()-50 )
		oPrn:Line(nLin-5,  200, nLin-5+100,  200 ) // PEDIDO L
		
		oPrn:Say(nLin,0060,_aPedProb[y][8], oFont2)
		oPrn:Say(nLin,0225,cTexto, oFont2)
		nLin += nEsp
		oPrn:Say(nLin,0225,cTexto2, oFont2)
		nLin += nEsp
	endif
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

*'Pedidos de outras unidades - Márcio Sobreira -----------------------------------------------'*
If MV_PAR41 == 2 // Origem (DE)
	cQry += "   AND C5_XOPER NOT IN ('20', '21', '99')   "
Else
	cQry += "   AND C5_XOPER NOT IN ('13', '20', '21', '99')   "
Endif
*'--------------------------------------------------------------------------------------------'*
//cQry += "   AND C5_XACERTO = ' '
//cQry += "   AND ZQ_DTEMBAR = TO_CHAR(SYSDATE, 'YYYYMMDD')

memowrit("c:\ORTR077nf.sql",cQry)
IF select("QRY") > 0
	DBSELECTAREA("QRY")
	QRY->( DBCLOSEAREA() )
ENDIF

TCQUERY cQry ALIAS "QRY" NEW
DBSELECTAREA("QRY")

NTOT := QRY->TOT

DBSELECTAREA("QRY")
QRY->( DBCLOSEAREA() )

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
cQuery += " AND SA1.A1_COD = C5_CLIENT     "
cQuery += " AND SA1E.A1_COD (+)= C5_XCLITRO "
cQuery += " AND SA1.A1_LOJA = C5_LOJACLI     "
cQuery += " AND SA1E.A1_LOJA (+)= C5_XLOJATR "
cQuery += " AND C5_XEMBARQ = ' '"
cQuery += " AND C6_NOTA = ' '   "

*'Pedidos de outras unidades - Márcio Sobreira -----------------------------------------------'*
If MV_PAR41 == 2 // Origem (DE)
	cQuery += " AND C5_XOPER NOT IN ('20','21','99') "  //Não lista pedidos "Não repor" e "Cancelados"
Else
	cQuery += " AND C5_XOPER NOT IN ('13','20','21','99') "  //Não lista pedidos "Não repor" e "Cancelados"
Endif

cQuery += " AND C5_XACERTO	=	' '      " /**********/
//LUCIANO - SSI 26736 - Imprimir razoes agrupadas
IF MV_PAR36 <> 2
	cQuery += " AND C5_CLIENTE between '" + MV_PAR01 + "' and '" + MV_PAR03 + "'"
	cQuery += " AND C5_LOJACLI between '" + MV_PAR02 + "' and '" + MV_PAR04 + "'"
ELSE
	cQuery += " AND C5_CLIENTE IN	(SELECT A1_COD "
	cQuery += "							 FROM "+RetSQLName("SA1")+" SA11 "
	cQuery += "							 WHERE A1_XCODGRU IN (SELECT A1_XCODGRU "
	cQuery += "														 FROM "+RetSQLName("SA1")+" SA12 "
	cQuery += "												       WHERE A1_COD between '" + MV_PAR01 + "' and '" + MV_PAR03 + "'))"
Endif
//Fim - SSI 26736 - Imprimir razoes agrupadas
cQuery += " AND C5_TABELA BETWEEN '" + MV_PAR06 + "' AND '" + MV_PAR07 + "'"
cQuery += " AND C5_VEND1 between '" + MV_PAR08 + "' and '" + MV_PAR09 + "'"

&& Henrique - 08/05/2014 - SSI 1207
&&If MV_PAR05 <> 5
&&	cQuery += " AND C5_XTPSEGM = '" + STRZERO(MV_PAR05,1) + "'"
&&Endif
If nMV_PAR05 <> 6
	cSgmto:=IIf(nMV_PAR05==5,"8",StrZero(nMV_PAR05,1))
	cQuery += " AND C5_XTPSEGM = '" + cSgmto + "'"
Endif

If MV_PAR10 = 1
	cQuery += " AND B1_COD NOT LIKE '407095%' "                       // NAO LISTA TERCEIROS
Else
	If MV_PAR12 = 2
		cQuery += " AND B1_COD LIKE '407095%' "                      // LISTA SOMENTE TERCEIROS SE O PARAMETRO 9 FOR IGUAL A 2 (SIM)
	Endif
Endif

IF MV_PAR25 = 2 .OR. MV_PAR26 = 2 .OR. MV_PAR27 = 2 .OR. MV_PAR28 = 2 .OR. MV_PAR29 = 2 .OR. MV_PAR30 = 2 .OR. MV_PAR31 = 2 .OR. MV_PAR32 = 2 .OR. MV_PAR33 = 2
	cOpr := "("
	If MV_PAR25 = 2
		cOpr += "'02','03','17',"                 // TROCAS
	Endif
	If MV_PAR26 = 2
		cOpr += "'01','12','13','10', "                 // NORMAL// incluido no dia 27/08/12 - autorizado pelo avilton, charles e crus - WFA
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
		cOpr += "'04',"                           // CONSERTO
	Endif
	If MV_PAR33 = 2
		cOpr += "'06','24','25','27',"                           // CONSERTO
	Endif
	
	*'Pedidos de outras unidades - Márcio Sobreira -----------------------------------------------'*
	If MV_PAR41 = 3
		cOpr += "'14',"                 // ORIGEM (DE)
	Endif
	If MV_PAR41 = 2
		cOpr += "'13',"                 // DESTINO (PARA)
	Endif
	*'--------------------------------------------------------------------------------------------------'*
	
	cOpr := SUBSTR(cOpr,1,LEN(COPR)-1)
	cQuery += "AND C5_XOPER IN "+cOpr+")"
ENDIF

If MV_PAR15 = 2
	cQuery += " AND C5_XENTREF <> ' ' AND C5_XTPSEGM != '8'"   // C/DATA ENTREGA (SITE DEVE SER SEMPRE CONSIDERADO LIVRE
ElseIf MV_PAR15 = 3
	cQuery += " AND (C5_XENTREF = ' ' OR C5_XTPSEGM = '8')"    // S/DATA ENTREGA (SITE DEVE SER SEMPRE CONSIDERADO LIVRE
Endif      
If mv_par16 = 2
	cQuery += " AND C5_XDTLIB <> ' '  AND C5_XQUAREN != '1'  "                            // LIBERADOS
ElseIf mv_par16 = 3
	cQuery += " AND C5_XDTLIB = ' '  AND C5_XQUAREN != '1'  "                             // NAO LIBERADOS
ElseIf mv_par16 = 4
	cQuery += " AND C5_XQUAREN = '1' "                            // QUARENTENA
Endif
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
//TCQUERY cQuery ALIAS "TQRY" NEW
RETURN

static function fEspaco()
***********************
Local cQry := ""

cQry := " SELECT A1_XROTA, "
cQry += "       SUM(CASE WHEN C5_XENTREF <= '"+DTOS(DDATABASE)+"' "
cQry += "           THEN (C6_QTDVEN * B1_XESPACO) / DECODE(C5_XTPCOMP, 'V', 3, 'C', 2, 1) "
cQry += "           ELSE 0 END) ESPLIVRE, "
cQry += "       SUM(CASE WHEN C5_XENTREF <= '"+DTOS(DDATABASE)+"' "
cQry += "           THEN (DECODE(C5_XOPER,'07',C6_PRCVEN,'08',C6_PRCVEN,C6_XPRUNIT)- "
cQry += "            DECODE(C5_XTPSEGM,'3',((C6_XGUELTA + C6_XRESSAR) * C6_XPRUNIT / 100),0))*C6_QTDVEN "
cQry += "           ELSE 0 END) TOTLIVRE, "
cQry += "       SUM(CASE WHEN C5_XENTREF > '"+DTOS(DDATABASE)+"' "
cQry += "           THEN (C6_QTDVEN * B1_XESPACO) / DECODE(C5_XTPCOMP, 'V', 3, 'C', 2, 1) "
cQry += "           ELSE 0 END) ESPFUT, "
cQry += "       SUM(CASE WHEN C5_XENTREF > '"+DTOS(DDATABASE)+"' "
cQry += "           THEN (DECODE(C5_XOPER,'07',C6_PRCVEN,'08',C6_PRCVEN,C6_XPRUNIT)- "
cQry += "            DECODE(C5_XTPSEGM,'3',((C6_XGUELTA + C6_XRESSAR) * C6_XPRUNIT / 100),0))*C6_QTDVEN "
cQry += "           ELSE 0 END) TOTFUT, "
cQry += "       SUM((C6_QTDVEN * B1_XESPACO) / DECODE(C5_XTPCOMP, 'V', 3, 'C', 2, 1)) AS ESPACO, "
cQry += "       SUM((DECODE(C5_XOPER,'07',C6_PRCVEN,'08',C6_PRCVEN,C6_XPRUNIT)- "
cQry += "            DECODE(C5_XTPSEGM,'3',((C6_XGUELTA + C6_XRESSAR) * C6_XPRUNIT / 100),0))*C6_QTDVEN) TOTPED, "
cQry += "       MIN(C5_EMISSAO) ULTPEDROTA ,C5_XUNORI "
cQry += "  FROM "+RETSQLNAME("SC5")+ " SC5, "
cQry += "       "+RETSQLNAME("SC6")+ " SC6, "
cQry += "       "+RETSQLNAME("SB1")+ " SB1, "
cQry += "       "+RETSQLNAME("SA1")+ " SA1,  CARTEIRA"+cEmpAnt+"0 "
cQry += " WHERE C5_NUM = C6_NUM  "
cQry += "   AND SC5.R_E_C_N_O_ = REC "
cQry += "   AND C6_PRODUTO = B1_COD "
cQry += "   AND C5_CLIENT = A1_COD "
cQry += "   AND SA1.A1_LOJA = C5_LOJACLI "
cQry += "   AND SA1.A1_COD = C5_CLIENT  "
cQry += "   AND SC5.D_E_L_E_T_ = ' ' "
cQry += "   AND SC6.D_E_L_E_T_ = ' ' "
cQry += "   AND SB1.D_E_L_E_T_ = ' ' "
cQry += "   AND SA1.D_E_L_E_T_ = ' ' "
cQry += "   AND C5_FILIAL = '"+xFilial("SC5")+"'"
cQry += "   AND C6_FILIAL = '"+xFilial("SC6")+"'"
cQry += "   AND B1_FILIAL = '"+xFilial("SB1")+"'"
cQry += "   AND A1_FILIAL = '"+xFilial("SA1")+"'"
cQry += "   AND C5_NOTA = ' ' "
cQry += "   AND C5_XACERTO = ' ' "
cQry += "   AND C5_XEMBARQ = ' ' "

*'Pedidos de outras unidades - Márcio Sobreira -----------------------------------------------'*
If MV_PAR41 == 2 // Origem (13)
	cQry += "   AND C5_XOPER NOT IN ('20', '21', '99') "
Else
	cQry += "   AND C5_XOPER NOT IN ('13', '20', '21', '99') "
Endif
//LUCIANO - SSI 26736 - Imprimir razoes agrupadas
IF MV_PAR36 <> 2
	cQry += " AND C5_CLIENTE between '" + MV_PAR01 + "' and '" + MV_PAR03 + "'"
	cQry += " AND C5_LOJACLI between '" + MV_PAR02 + "' and '" + MV_PAR04 + "'"
ELSE
	cQry += " AND C5_CLIENTE IN	(SELECT A1_COD "
	cQry += "							 FROM "+RetSQLName("SA1")+" SA11 "
	cQry += "							 WHERE A1_XCODGRU IN (SELECT A1_XCODGRU "
	cQry += "												   FROM "+RetSQLName("SA1")+" SA12 "
	cQry += "												   WHERE A1_COD between '" + MV_PAR01 + "' and '" + MV_PAR03 + "')

	if !empty(MV_PAR52)
		cQuery += " and A1_XROTA >='"+MV_PAR52+"' " //DMS|| SSI - 126242
		cQuery += " and SA1.A1_XROTA <='"+iif(empty(MV_PAR53),"ZZZZZZ",MV_PAR53)+"'" //DMS|| SSI - 126242
	endif

	cQry +=                       ") "
Endif
//Fim - SSI 26736 - Imprimir razoes agrupadas
cQry += "   AND C5_TABELA BETWEEN '" + MV_PAR06 + "' AND '" + MV_PAR07 + "'"
cQry += "   AND C5_VEND1 between '" + MV_PAR08 + "' and '" + MV_PAR09 + "'"
&& Henrique - 08/05/2014 - SSI 1207
&&If MV_PAR05 <> 5
&&	cQuery += " AND C5_XTPSEGM = '" + STRZERO(MV_PAR05,1) + "'"
&&Endif
If nMV_PAR05 <> 6
	cSgmto:=IIf(nMV_PAR05==5,"8",StrZero(nMV_PAR05,1))
	cQry += " AND C5_XTPSEGM = '" + cSgmto + "'"
Endif
if !Empty(cOpr)
	cQry += "   AND C5_XOPER IN "+cOpr+")"
EndIf

If MV_PAR15 = 2
	cQry += " AND C5_XENTREF <> ' ' AND C5_XTPSEGM != '8'"   // C/DATA ENTREGA (SITE DEVE SER SEMPRE CONSIDERADO LIVRE
ElseIf MV_PAR15 = 3
	cQry += " AND (C5_XENTREF = ' ' OR C5_XTPSEGM = '8')"    // S/DATA ENTREGA (SITE DEVE SER SEMPRE CONSIDERADO LIVRE
Endif      
If mv_par16 = 2
	cQry += " AND C5_XDTLIB <> ' '  AND C5_XQUAREN != '1'  "                            // LIBERADOS
ElseIf mv_par16 = 3
	cQry += " AND C5_XDTLIB = ' '  AND C5_XQUAREN != '1'  "                             // NAO LIBERADOS
ElseIf mv_par16 =4
	cQry += " AND C5_XQUAREN = '1' "                            // QUARENTENA
Endif
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
cQry += " GROUP BY A1_XROTA ,C5_XUNORI "
cQry += " ORDER BY 1  "

If Select("QRY") > 0
	dbSelectArea("QRY")
	QRY->( dbCloseArea() )
EndIf
memowrit("c:\ortr077fe.sql",cQry)
TCQUERY cQry ALIAS "QRY" NEW
dbSelectArea("QRY")

While QRY->( !EOF() )
	//Alterado Vinicius Lança - 25/03/2019
	if QRY->C5_XUNORI == '07'
		QRY->( AADD(_aResumo2B,{Alltrim(A1_XROTA),ESPACO,TOTPED,EspLivre,TotLivre,EspFut,TotFut,ULTPEDROTA}) )
	else
		QRY->( AADD(_aResumo2,{Alltrim(A1_XROTA),ESPACO,TOTPED,EspLivre,TotLivre,EspFut,TotFut,ULTPEDROTA}) )
	endif
	
	QRY->( dbskip() )
end

dbSelectarea("QRY")
QRY->( DBCLOSEAREA() )

DBSELECTAREA("TSC5")

RETURN

// PEGA O MIX DO PEDIDO
Static Function FscGetMix(cNumPed)
Local aArea		:= GetArea()
Local cQuery	:= ""
Local nMix		:= 0

cQuery	:= "SELECT SUM(100 * (C6_XPRUNIT - C6_XCUSTO) / C6_XPRUNIT) AS MIXCALC FROM "
cQuery	+= RetSqlName("SC6") + " SC6 "
cQuery	+= "WHERE "
cQuery  += "   SC6.C6_NUM = '" + cNumPed +"'"
cQuery  += "   AND SC6.D_E_L_E_T_ = ' '		"
cQuery  += "   AND SC6.C6_FILIAL  = '"+xFilial("SC6")+"'"
cQuery  += "   AND SC6.C6_XPRUNIT > 0		"
cQuery  += "   AND SC6.C6_XCUSTO  > 0  "

memowrit("c:\getmix.sql",cQuery)
TCQUERY cQuery ALIAS "GMIX" NEW
dbselectarea("GMIX")

if GMIX->( !eof() )
	nMix += GMIX->MIXCALC
endif

GMIX->( dbclosearea() )

RestArea( aArea )
Return nMix

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

//************************************************************************************************************

//if MV_PAR38==1                   //Comercial
//	cQuery+="         AND SZE.ZE_AUTORIZ IN ('BLQMIX','BLQBRD','BLQPZM','BLQREP')                         "
//	cQuery+="         AND C5_XOPER NOT IN  ('13','99','08','09','98')                                   "
//Elseif MV_PAR38==2 			   //cobranca
//	cQuery+="         AND SZE.ZE_AUTORIZ IN ('BLQDEB', 'BLQPEN','BLQSOC','BLQCOM','BLQRCM','BLQPNV','BLQPDC','BLQPRZ')        "
//	cQuery+="         AND C5_XOPER NOT IN ('02','03','05','06','08','09','13','99','98')                "
//Elseif MV_PAR38==3		       //ambos
//	cQuery+="         AND SZE.ZE_AUTORIZ IN ('BLQMIX','BLQBRD','BLQPZM', 'BLQREP''BLQDEB', 'BLQPEN','BLQSOC','BLQCOM','BLQRCM','BLQPNV','BLQPDC','BLQPRZ' )                         "
//	cQuery+="         AND C5_XOPER NOT IN ('13','99','08','09','98' '02','03','05','06' ) "
//endif

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
	Local cArquivo	:= 'C:\TEMP\ORTR077_' + DTOS(date()) + 	subst(time(),1,2) + ;
															subst(time(),4,2) + ;
															subst(time(),7,2) + '.csv'
	
	MakeDir('C:\TEMP')
	
	nHandle := fCreate(cArquivo, 0)
	If nHandle == -1
		MsgStop('Erro ao criar arquivo: ' + AllTrim(Str(fError())))
		Return
	Endif
	
	cCabec 	:= 'NUM.'
	cCabec 	+= ';PEDIDO'

	If MV_PAR43 == 2
		cCabec 	+= ";ASS. TEC."
	EndIf

	If MV_PAR48 = 2
		cCabec 	+= ";ID ORT."
	EndIf

	cCabec 	+= ";LIB"
	
	IF MV_PAR37 == 1
		cCabec 	+= ";CD/CM "
	Else
		cCabec 	+= ";CD/CM MIX"
	EndIf

	cCabec 	+= ";EMISSAO"
	cCabec 	+= ";LIBERACAO"
	cCabec 	+= ";REVALID"
	cCabec 	+= ";DIAS"

	If MV_PAR49 = 1
		cCabec 	+= ";ENTREGA"
	Else
		cCabec 	+= ";PRE. ENT."
	EndIf
	
	cCabec 	+= ";TP"
	cCabec 	+= ";SEG"
	cCabec 	+= ";VEND"
	cCabec 	+= ";CLIENTE"
	cCabec 	+= ";VALOR"
	cCabec 	+= ";ZONA-CIDADE-BAIRRO"

	If MV_PAR43 = 2 .and. MV_PAR48 = 2
		cCabec 	+= ";CARGA ROT"
	ElseIf MV_PAR43 = 1 .and. MV_PAR48 = 2
		cCabec 	+= ";CARGA ROT"
	Else
		cCabec 	+= ";CARGA ROT"
	EndIf

	IF MV_PAR37 == 1
		If MV_PAR43 = 2 .and. MV_PAR48 = 2
			cCabec 	+= ";ESPACOS"
		Else
			cCabec 	+= ";ESPACOS"
		EndIf
	Else
		cCabec 	+= ";KG"
	EndIf

	If MV_PAR43 = 1 .and. MV_PAR48 = 1
		cCabec 	+= ";ROT"
		cCabec 	+= ";TAB"
	EndIf

	cCabec 	+= ";OPL"
	cCabec 	+= ";EXC"

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

