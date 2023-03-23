#INCLUDE "FINA330.CH"
#INCLUDE "PROTHEUS.CH"
#include "FWMVCDEF.CH"

Static __PesqList
Static aRLocks
Static l330Auto  := .F.
Static lFWCodFil := .T.
Static lRatFields
Static dLastPcc  := CTOD("22/06/2015")
Static nReg330 := 20

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ Fina330	³ Autor ³ Mauricio Pequim Jr.   ³ Data ³ 22/09/97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Compensação entre títulos e adiantamentos 			  	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Fina330()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Gen‚rico 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function ZFina330(nPosArotina,lExecAuto)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Vari veis 		 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local lPanelFin := IsPanelFin()
Local nSavRec	:= Recno()
Local cBrwExp	:= NIL
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Vetor com Condicoes para a legenda da mBrowse ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
 
Private aRotina := MenuDef()
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³                PARAMETROS  	                    ³
//³                              	                 ³
//³ MV_PAR01 : Considera Loja  Sim/Nao          	  ³
//³ MV_PAR02 : Considera Cliente     Original/Outros ³
//³ MV_PAR03 : Do Cliente                            ³
//³ MV_PAR04 : Ate Cliente                           ³
//³ MV_PAR05 : Compensa Titulos Transferidos S/[N]   ³
//³ MV_PAR06 : Calcula Comissao sobre valores de NCC ³
//³ MV_PAR07 : Mostra Lancto Contabil                ³
//³ MV_PAR08 : Considera abatimentos para compensar  ³
//³ MV_PAR09 : Contabiliza On-Line                   ³
//³ MV_PAR10 : Considera Filiais abaixo              ³
//³ MV_PAR11 : Filial De                             ³
//³ MV_PAR12 : Filial Ate                            ³
//³ MV_PAR13 : Calcula Comissao sobre valores de RA  ³
//³ MV_PAR14 : Reutiliza taxas informadas            ³
//³ Atencao: ao criar mais parametros nesta rotina   ³
//³ observe na funcao fa330comp() logo abaixo que    ³
//³ e necessario setar os defaults caso a chamada    ³
//³ venha de outro programa. (ex.: cOrigem=MATA465)) ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define o cabe‡alho da tela de baixas				³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE cCadastro := STR0005  //"Compensa‡„o de Titulos a Receber"
PRIVATE cLote			// Utilizado para Contabilizacao
PRIVATE VALOR 	:= 0 	// Utilizada para Contabilizacao
PRIVATE VALORMF 	:= 0 	// Utilizada para Contabilizacao
PRIVATE VALOR7 	:= 0 	// Utilizada para Contabilizacao
PRIVATE VALOR8 	:= 0 	// Utilizada para Contabilizacao
Private lOracle	:= "ORACLE"$Upper(TCGetDB())

PRIVATE nTamTit := TamSX3("E1_PREFIXO")[1]+TamSX3("E1_NUM")[1]+TamSX3("E1_PARCELA")[1]
PRIVATE nTamTip := TamSX3("E1_TIPO")[1]
PRIVATE nTamLoj := TamSX3("E1_LOJA")[1]
Private aTxMoedas	:=	{}
Private cCodDiario	:= ""
Default nPosArotina := 0
Default lExecAuto	:= .F.
Default lRatFields := cPaisLoc == "BRA"

l330Auto := lExecAuto

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica o numero do Lote 							³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LoteCont( "FIN" )
SetKey (VK_F12,{|a,b| AcessaPerg("FIN330",.T.)})

If ExistBlock("FA330FLT")
	ExecBlock("FA330FLT",.F.,.F.)
Endif

Pergunte("FIN330",.F.)

//Garanto a criacao / abertura do SFQ fora da transacao
//Necessária para a verificacao posterior dos campos de impostos da Lei 10925
dbSelectArea('SFQ')

If nPosArotina > 0
	dbSelectArea('SE1')
	bBlock := &( "{ |a,b,c,d,e,f,g,h| " + aRotina[ nPosArotina,2 ] + "(a,b,c,d,e,f,g,h) }" )
	Eval( bBlock, Alias(), (Alias())->(Recno()),nPosArotina,/*oDlgPae*/,/*cLoteFat*/,/*cOrigem*/,/*aNumLay*/,l330Auto)
					//cAlias,  cCampo					,nOpcE,	oDlgPae,		cLoteFat,	 cOrigem,		aNumLay,	lAutomato

Else
	dbSelectArea("SE1")
	dbSetOrder(1)
	dbSeek(xFilial())

	// Ponto de entrada para incluir botoes na rotina
	If ExistBlock( "FA330MNU" )
		aRotina := ExecBlock( "FA330MNU", .F., .F., { aRotina } )
	EndIf

	// Ponto de entrada para retornar uma expressao SQL para filtro
	// no mBrowse sem que a opcao de filtro do usuario seja desabilitado.
	cBrwExp	:= NIL
	If ExistBlock( "FA330FBRW" )
		cBrwExp := ExecBlock( "FA330FBRW", .F., .F. )
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Endere‡a a Fun‡„o de BROWSE				³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	mBrowse( 6, 1,22,75,"SE1",,,,,,Fa330Leg(),,,,,,,, cBrwExp /* 19-SQL Filter */ )
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Recupera a Integridade dos dados		³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
SetKey (VK_F12)
dbSelectArea("SE1")
DbClearFilter()
dbSetOrder(1)
dbGoTo( nSavRec )

Return(.T.)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ Fa330Comp³ Autor ³ Mauricio Pequim Jr.   ³ Data ³ 18/04/94 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Marca‡„o dos titulos para compensa‡„o					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ Fa330Comp() 												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Gen‚rico 												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function fA330Comp(cAlias,cCampo,nOpcE,oDlgPae,cLoteFat,cOrigem,aNumLay, lAutomato)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Vari veis 				 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local lPanelFin		:= IsPanelFin()
Local nTotal		:= 0
Local nHdlPrv		:= 0
Local nValorComp	:= 0
Local nSeq			:= 0
Local nValBX		:= 0			// Valor da baixa na moeda 1
Local nValBX2		:= 0			// Valor da baixa na moeda do tit principal
Local nX
Local nI
Local cAdiantamento
Local cDadosTitulo
Local cArquivo
Local cPadrao	:= "596"
Local lContabil	:= .F.
Local lPadrao
Local lDigita
Local dEmissao	:= SE1->E1_EMISSAO
Local lMarcado	:= .F.
Local aBaixas	:= {}
Local nTotAbat	:= 0
Local nTotAbtIni	:= 0		//Abatimento do titulo de Partida
Local nTotAbtAux	:= 0
Local nTitIni	:= SE1->(Recno())
Local nDecs		:= 2
Local nSalTit	:= 0
Local nDecs1	:= MsDecimais(1)
Local oOk		:= LoadBitmap( GetResources(), "LBOK" )
Local oNo		:= LoadBitmap( GetResources(), "LBNO" )
Local cVarQ		:= "  "
Local oTitulo
Local oDlg
Local lFa330Cmp	:= ExistBlock( "FA330CMP" )
Local nSldReal	:= 0
Local oGet01
Local nLinha	:= 0
Local nTit		:= 0
Local nA		:= 0
Local cKeyAbt	:= ""
Local nSe1Rec	:= 0
Local nAcresc	:= 0
Local nDecres	:= 0
Local nIndexAtu	:= SE1->(IndexOrd())
Local nVlrCompe // Criadaa para exibir o conteudo do Help correto quando o usuario
					 // pressionar F1 sobre o campo
Local aSize		:= {}
Local lDeleted	:= .F.
Local lfa330Bx	:= Existblock("FA330BX")
Local oPanel
Local aArea		:={}
Local lACAtivo	:= GetNewPar("MV_ACATIVO", .F.) //Verifica se o cliente utiliza o modulo Educacional
Local lVldDtFin	:= .T.
Local aDiario	:= {}

//Controla o Pis Cofins e Csll na baixa  (1-Retem PCC na Baixa ou 2-Retem PCC na Emissão(default) )
Local lPccBxCr	:= FPccBxCr()
//Controla IRPJ na baixa
Local lIrPjBxCr	:= FIrPjBxCr()
Local nPropIR	:= 1
Local nTotIrAbt	:=0
Local nLoop		:= 0
LOCAL nSalvRec	:= SE1->(Recno())
Local lAplVlMin := .T.
Local nVlMinImp := GetNewPar("MV_VL10925",5000)
Local nTotCsAbt	:= 0
Local nTotPisAbt	:= 0
Local	nTotCofAbt	:= 0
Local aImpPcc		:= {0,0,0}

//Retencao do ISS pela emissao (1) ou baixa (2)
Local nTotIssAbt	:= 0
Local lCalcIssBx 	:= !Empty( SE5->( FieldPos( "E5_VRETISS" ) ) ) .and. !Empty( SE1->( FieldPos( "E1_SEQBX"   ) ) ) .and. ;
						!Empty( SE1->( FieldPos( "E1_TRETISS" ) ) ) .and. GetNewPar("MV_MRETISS","1") == "2"

Local nTotAdto		:= 0
Local lBaixaAbat	:= .F.
Local nVlrBaixa	:= 0
Local lBxCec		:= .F.
Local lBxLiq		:= .F.
Local nParciais	:= 0
Local nTamSeq		:= TamSX3("E5_SEQ")[1]
Local cSequencia	:= Replicate("0",nTamSeq)
Local nRecnoRA		:= 0
Local lF330BOTON 	:= ExistBlock("F330BOTON")


Local lOkTitAb	:= .F.
Local lCompRa	:=	.F.
Local nPropPcc	:=	0
Local nRegRa	:=	0

Local nPOs			:=  0
Local lPropRA 		:= SuperGetMv("MV_COMPCR",,.F.) //Verifica se vai proporcionalizar quando RA para NF.
Local nPisRaRet 	:= nCofRaRet := nCslRaRet := nBaseImp := nValImp := 0
Local nSabTPis  	:=  nSabTCof :=  nSabTCsl := 0
Local lTipBxCP  	:= .F.
Local lSigaLoja 	:= .F.
//Local cFilComp		:=	xFilial("SE1")
//Controle de abatimento
Local lTitpaiSE1 	:= .T.
Local nOrdTitPai	:= 0
Local cTipo	 		:= ""
Local bWhile 		:= {|| !EOF() .And. E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA==xFilSE1+cKeyAbt}
Local nRecOri		:= SE1->(Recno())

//Impostos gerados pela rotina de Borderô de Recebimento de Imposto (FINA061).
Local	nPisFina061	:=	0
Local	nCofFina061	:=	0
Local	nCslFina061	:=	0
Local	nIrfFina061	:=	0  
Local nOrdSE5	:=	0
Local nRegSE5	:=	0
Local nPropImp	:= 0
Local nProp		:= 0
Local lPropBx  := SuperGetMv("MV_PROPBX",.F.,"2") == "1"
Local lSaldoNf	:= .T.
Local nIrrfParc := 0
Local nValTit	:= 0
Local nRecTit	:= 0
Local dDiaPcc		:= dDatabase
Local nOldVal	:= 0
Local nTotComp  := 0 // variavel para controle do total compensado	
/* GESTAO - inicio */
Local oBtFilial	:= Nil
/* GESTAO - fim */
Local aAlt     := {}
Local aPcc		:= Array(4)
Local nValIrf	:= 0
Local lBq10925	:= SuperGetMV("MV_BQ10925",,"2") == "1"
Local nTotalTit	:= 0
Local nTotTit	:= 0
Local nTotalVal	:= 0
Local nTotPis	:= 0
Local nTotCof	:= 0
Local nTotCsll	:= 0
Local lContabiliza	:= .F.
Local lOldPCC	:= .T.
Local nAltVal	:= 0
Local nVTit		:= 0
Local aParcsNFs := {}

Default cOrigem :=""
DEFAULT aNumLay := {}
Default lAutomato := .F.


PRIVATE nPosPis		:= 14		//Posicao Pis na Tela
PRIVATE nPosCof		:= 15		//Posicao Cofins na Tela
PRIVATE nPosCsl		:= 16		//Posicao Csll na Tela
PRIVATE nPosIrf		:= 17		//Posicao IRRF na Tela
PRIVATE cTipoOr		:= SE1->E1_TIPO
PRIVATE nPosBPCC 		:= 24
PRIVATE nPosBPCR 		:= 25
PRIVATE nPosBIRF 		:= 26
PRIVATE aTitulos	:={}
PRIVATE aRecNo 		:= {}
PRIVATE aRegSE1 	:= {}
PRIVATE aBaixaSE5 	:= {}
PRIVATE	cPrefixo 	:= SE1->E1_PREFIXO
PRIVATE	cNum		:= SE1->E1_NUM
PRIVATE	cTipoTit 	:= SE1->E1_TIPO
PRIVATE	cCliente 	:= SE1->E1_CLIENTE
PRIVATE	cLoja 		:= SE1->E1_LOJA
PRIVATE	cSaldo		:= CriaVar("E1_SALDO")
PRIVATE	nValor		:= CriaVar("E1_SALDO")
PRIVATE	cParcela 	:= SE1->E1_PARCELA
PRIVATE	nMoeda		:= SE1->E1_MOEDA
PRIVATE	dBaixa		:= dDataBase
PRIVATE	nTxMoeda	:= SE1->E1_TXMOEDA
PRIVATE	nValTot		:= 0
PRIVATE	nSeqBx 		:= 0
PRIVATE	nPosSaldo	:=0
PRIVATE	nPosValor	:=0
PRIVATE	cBanco		:= Criavar("E1_PORTADO")
Private lCredito 	:= .F.
Private nPosATit 	:= 0
Private aFlagCTB 	:= {}
Private lUsaFlag 	:= SuperGetMV( "MV_CTBFLAG" , .T. /*lHelp*/, .F. /*cPadrao*/)
Private aImpIR		:= {}     //array que armazena o IR na baixa
//PCC Baixa CR
PRIVATE nPis 		:= 0
PRIVATE nCofins   	:= 0
PRIVATE nCsll		:= 0
PRIVATE nIss		:= 0
PRIVATE nInss		:= 0
PRIVATE aDadosRef 	:=  {0,0,0,0,0,0,0} //Array(7)
PRIVATE aDadosRet 	:=  {0,0,0,0,0,0,0} //Array(7)
PRIVATE nVlRetPis	:= 0
PRIVATE nVlRetCof	:= 0
PRIVATE nVlRetCsl	:= 0
PRIVATE nDiferImp	:= 0
PRIVATE nValRec		:= 0
PRIVATE nOldValRec	:= 0
PRIVATE lRetParc  	:= .T.
PRIVATE nIrrf 	  	:= 0
PRIVATE ntotIrbx  	:= 0
PRIVATE nIndVld   	:= 0
PRIVATE nRecVld   	:= 0
PRIVATE nValCorCM 	:= 0
PRIVATE nTotImpbx  	:= 0 //Total de impostos calculados na baixa, quando posiciona !lCredito
Private aDadosRA1 	:= {{},{},{},{},{},{},{},{},{},{},{}}
Private lRaRtImp  	:= FRaRtImp()       //Define se ha retencao de impostos PCC/IRPJ no R.A
Private nValAbat	:= 0
PRIVATE lNcc			:= SE1->E1_TIPO $ MV_CRNEG
PRIVATE lF330SE5      := Existblock("F330SE5")
PRIVATE aRecSe5     := {}
PRIVATE nValPis		:= 0
PRIVATE nValCofins	:= 0
PRIVATE nValCsll	:= 0
PRIVATE nAbatRa		:= 0
Private nSldNF	:= 0
Private nAbatNf		:= 0
PRIVATE nValorNf	:= 0
PRIVATE lF330DESC	:= ExistBlock("F330DESC")
PRIVATE lDESC		:= .F.
PRIVATE nDesFin 	:= 0
PRIVATE nDescP		:= 0
PRIVATE nDescD		:= 0
Private nValorRa	:= 0
Private nSldRa		:= 0
//***Reestruturacao SE5***
Private nPisBaseR 	:= 0
Private nCofBaseR	:= 0
Private nCslBaseR 	:= 0
Private nPisBaseC 	:= 0
Private nCofBaseC 	:= 0
Private nCslBaseC 	:= 0
Private nIrfBase	:= 0

//***Reestruturacao SE5***

/* GESTAO - inicio */
Private aSelFil		:= {}
/* GESTAO - fim */

If cOrigem == "LOJA800"
   nValor   :=  nVlrComp
EndIf

nVlrCompe	:= nValor

If dDataBase > dLastPcc
	nVlMinImp	:= 0
EndIf
aPcc[1]	:= .F.

If SE1->E1_TIPO $ MVRECANT+"/"+MV_CRNEG .or. cOrigem =="MATA465"
	lCredito := .T.
Endif

If !FA330Lock(,SE1->(Recno()))
	Return
Endif

aArea:=GetArea()

aPcc[1]	:= .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se vier do mata465 ou da LOCXNF, forca os valores dos parametros ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cOrigem == "MATA465"
	MV_PAR07 := mv_par03		// Mostra Lancto Contabil
	MV_PAR09 := mv_par05		// Contabiliza On-Line
	MV_PAR01 := 1 				// Considera Loja  Sim/Nao
	MV_PAR02 := 1 				// Considera Cliente Original/Outros
	MV_PAR03 :=	SE1->E1_CLIENTE // Do Cliente
	MV_PAR04 :=	SE1->E1_CLIENTE // Ate Cliente
	MV_PAR05 := 2				// Compensa Titulos Transferidos S/[N]
	MV_PAR06 := 2				// Calcula Comissao sobre valores de NCC
	MV_PAR08 := 2				//Considera abatimentos para compensar
	MV_PAR10 := 2				//Considera Filiais abaixo
	MV_PAR11 := Space( TamSX3( "E2_FILIAL" )[1] )	    //Filial De
	MV_PAR12 := Replicate("Z",TamSX3("E2_FILIAL")[1])  //Filial Ate
	MV_PAR13 := 1				// Calcula Comissao sobre valores de RA
	MV_PAR14 := 2				// Reutiliza taxas informadas
    // obs.: nao eh necessario voltar aos valores originais no final, pois a
    // propria MATA465 recompoe os valores dos mv_parxx depois da chamada fa330comp()
ElseIf cOrigem == "COMPENSANCC"
	Pergunte("FIN330",.F.)
	MV_PAR03 := SE1->E1_CLIENTE  		// Do Cliente
	MV_PAR04 := SE1->E1_CLIENTE 		// Ate Cliente

	dbSelectArea("SE1")
Endif

If Type("MV_PAR02")<>'N'
	MV_PAR02 := 1 				// Considera Cliente Original/Outros
EndIf

//Caso considere diferentes clientes
If MV_PAR02 == 2
	nPosPis := 17
	nPosCof := 18
	nPosCsl := 19
	nPosIrf :=	20
	nPosBPCC := 27
	nPosBPCR := 28
	nPosBIRF := 29
Endif

RestArea(aArea)


If ExistBlock("F330DTFIN")
	lVldDtFin := ExecBlock("F330DTFIN",.F.,.F.)
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se data do movimento n„o ‚ menor que data limite de ³
//³ movimentacao no financeiro    							 	  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lVldDtFin .and. !DtMovFin(,,"2")
	Return
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ N„o permite que t¡tulos j  baixados possam ser acessados. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If SE1->E1_SALDO <= 0
	Help(" ",1,"FA330JABAI")
	Return (.T.)
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Caso titulos originados pelo SIGALOJA estejam nas carteiras :  ³
//³I = Carteira Caixa Loja                                        ³
//³J = Carteira Caixa Geral                                       ³
//³Nao permitir esta operacao, pois ele precisa ser transferido   ³
//³antes pelas rotinas do SIGALOJA.                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Upper(AllTrim(SE1->E1_SITUACA)) $ "I|J" .AND. Upper(AllTrim(SE1->E1_ORIGEM)) $ "LOJA010|LOJA701|FATA701"
	Help(" ",1,"NOUSACLJ")
	Return
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Titulos provisorios nao sao compensaveis como titulo principal.        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If cTipoTit $ MVPROVIS
	Help(" ",1,"NOCMPPROV",,STR0042+chr(13)+STR0043,1,0 )   //"Nao é permitida a compensacao a partir de"###"um titulo provisorio"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Recupera a Integridade dos dados     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SE1")
	dbSetOrder(nIndexAtu)
	DeleteObject(oOk)
	DeleteObject(oNo)
	FA330aUnlock()
	Return (.T.)
Endif

//ANGOLA|BRASIL - Nao permitir compensar titulos de adiantamento relacionados a pedido
#IFDEF TOP
	If cPaisLoc $ "ANG|BRA"
		If FinAdtSld( "R", SE1->( E1_CLIENTE + E1_LOJA + E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO ) )
			Help(" ",1,"ADTXPED",,STR0062,1,0)		//"Adiantamento relacionado a um pedido somente poderá ser utilizado no relacionamento com pedidos"
			Return (.T.)
		Endif
	Endif
#ENDIF

//-----------------------------------------------------------
// Nao permite compensar recebimentos antecipados originados
// de faturas de adiantamentos. Req. Manejo de Anticipo
//-----------------------------------------------------------
If cPaisLoc == "MEX" .And. X3Usado("ED_OPERADT")
	If SE1->E1_TIPO == Substr(MVRECANT,1,3) .And.;
		Upper(Alltrim(SE1->E1_ORIGEM)) == "FINA087A" .And.;
		GetAdvFVal("SED","ED_OPERADT",xFilial("SED")+SE1->E1_NATUREZ,1,"") == "1"

		Help(" ",1,"VLDTITRA",,STR0065,1,0) //"Processo não permitido para recebimento antecipado gerado de fatura de adiantamento."
		Return (.T.)

	EndIf
EndIf

//PCREQ-3782 - Bloqueio por situação de cobrança
If !(F023VerBlq("1","0007",SE1->E1_SITUACA,.T.))
	Return (.T.)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Estrutura aTxMoedas         ³
//³ [1] -> Nome Moeda          	³
//³ [2] -> Taxa a Ser Utilizada	³
//³ [3] -> Picture          	³
//³ [4] -> Taxa do dia atual    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Type("aTxMoedas") <> "A"  .Or. MV_PAR14 == 2
	aTxMoedas:={}
EndIf

If Len(aTxMoedas) == 0
	Aadd(aTxMoedas,{"",1,PesqPict("SM2","M2_MOEDA1"),1})

	For nA := 2	To MoedFin()
		cMoedaTx :=	Str(nA,IIf(nA <= 9,1,2))
		If !Empty(GetMv("MV_MOEDA"+cMoedaTx))
			nVlMoeda := RecMoeda(dDataBase,nA)
			Aadd(aTxMoedas,{GetMv("MV_MOEDA"+cMoedaTx),nVlMoeda,PesqPict("SM2","M2_MOEDA"+cMoedaTx),nVlMoeda })
		Else
			Exit
		Endif
	Next
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa a gravacao dos lancamentos do SIGAPCO          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PcoIniLan("000016")

While .T.
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Titulo a ser compensado			 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nOpca  :=0
	If SE1->E1_MOEDA > 1
		If SE1->E1_TXMOEDA > 0 .and. Empty(SE1->E1_DTVARIA)
			nTxMoeda	 := SE1->E1_TXMOEDA
		EndIf
	Else
		nTxMoeda	 := RecMoeda(dDatabase,SE1->E1_MOEDA)
	EndIf
	If cPaisLoc =="ARG"		
		nTxMoeda := RecMoeda(dDatabase,SE1->E1_MOEDA)                       
	EndIf

	// DESCONTO FINANCEIRO do Título a ser compensado (NF/DP)
	If !lCredito .And. lF330DESC
		lDESC:= ExecBlock("F330DESC",.F.,.F.)
		If lDESC
			nDesFin:= IIf(SE1->E1_DESCFIN > 0 .And. SE1->E1_VENCREA-dBaixa >= SE1->E1_DIADESC .and. SE1->E1_DESCONT == 0,SE1->E1_VALOR * (SE1->E1_DESCFIN/100),0)
			nDescP := nDesFin
		EndIf
	EndIf

	If mv_par08 == 1 .Or. lRaRtImp
		nTotAbtIni 	:= SumAbatRec(cPrefixo,cNum,cParcela,SE1->E1_MOEDA,"S",dBaixa,,,@nTotCsAbt,@nTotPisAbt,@nTotCofAbt,,,,@nTotIssAbt)

		If lIrPjBxCr .And. !lRaRtImp .And. !lCredito
	   		nIrrf:=FCaIrBxCR(nValRec,,(SE1->E1_VALOR <> SE1->E1_SALDO.AND. lRaRtImp))
		EndIf

		If !lCalcIssBx .And. !lCredito
			If lPropBx
				If SE1->(E1_SALDO != E1_VALOR)  // Sofreu baixa parcial 
					nTotIssAbt := (SE1->E1_SALDO/SE1->E1_VALOR) * nTotIssAbt
				Else
					nTotIssAbt := 0
				EndIf
			EndIf
		EndIf

		nSaldo := (SE1->E1_SALDO - If(!lRaRtImp .Or. (!lNcc .And. mv_par08 == 1),nTotAbtIni,0) + If( lPropBx,nTotIssAbt,0)  + SE1->E1_SDACRES - SE1->E1_SDDECRE - nDesFin)
	ELSE
		nSaldo := SE1->E1_SALDO + SE1->E1_SDACRES - SE1->E1_SDDECRE - nDesFin
	Endif

	//Verifica se o titulo já possui impostos gerados pela rotina de Borderô de Recebimento de Imposto (FINA061).
	nPisFina061	:=	0
	nCofFina061	:=	0
	nCslFina061	:=	0
	nIrfFina061	:=	0
	VALOR7 		:= 0
	VALOR8 		:= 0
	nRegSE5	:=	SE5->(Recno())
	If lPccBxCr .And. lIrPjBxCr 
		dbSelectArea("SE5")
		SE5->(dbSetOrder(2)) //FILIAL + TIPODOC + PREFIXO + NUMERO + PARCELA + TIPO
		If SE5->(DBSeek(xFilial("SE5")+"BA"+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO))
			While !SE5->(Eof()) .and. SE5->E5_FILIAL==xFilial("SE5") .And. ;
				SE5->E5_TIPODOC+SE5->E5_PREFIXO+SE5->E5_NUMERO+SE5->E5_PARCELA+SE5->E5_TIPO=="BA"+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO		
			
				If ("FINA061" $ Subst(SE5->E5_HISTOR,1,7)) .And. SE5->E5_MOTBX $ "PCC_IRF"						
					If Alltrim(SE5->E5_MOTBX) == "PCC"
					   nPisFina061	+= SE5->E5_VRETPIS
					   nCofFina061	+=	SE5->E5_VRETCOF
					   nCslFina061	+= SE5->E5_VRETCSL
					ElseIf Alltrim(SE5->E5_MOTBX) == "IRF"
					   nIrfFina061	+= SE5->E5_VRETIRF
					Endif
				Endif					
				SE5->(DbSkip())		
		   Enddo
		Endif
	Endif
	SE5->(Dbgoto(nRegSE5))

   If (nPisFina061+nCofFina061+nCslFina061+nIrfFina061)> 0 .And. mv_par08 = 2
   		nSaldo	+= nPisFina061+nCofFina061+nCslFina061+nIrfFina061		
	Endif			 
	
	If !lCredito
		nAcresc := SE1->E1_SDACRES
		nDecres := SE1->E1_SDDECRE
		VALOR7 +=  nDecres
		VALOR8 +=  nAcresc
	EndIf

	nRecno := SE1->(Recno())

	cDadostitulo := SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO

	If (lPccBxCR .or. lIRPJBxCr) .And. lRaRtImp .AND. !lNcc
   		If lCredito
   			aAdd(aDadosRA1[1],SE1->(recno()))
   		Else
   			aAdd(aDadosRA1[2],SE1->(recno()))
   		EndIf
   	EndIf

	////////////////////
	//PCC Baixa CR
	//Se PCC Baixa CR e nao houver abatimento de impostos
	If cPaisLoc == "BRA" .and. (lPccBxCr .or. lIrPjBxCr) .and. (nTotCsAbt+nTotPisAbt+nTotCofAbt == 0)
		If (SE1->E1_VALOR > SE1->E1_SALDO) .And. Empty(SE1->E1_TIPOLIQ)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Procura pelas baixas deste titulo ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			lTipBxCP := lRaRtImp
			aBaixa := Sel070Baixa( "VL /V2 /BA /RA /CP /LJ /" + MV_CRNEG, SE1->E1_PREFIXO,SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO,;
				@nTotAdto, @lBaixaAbat, SE1->E1_CLIENTE, SE1->E1_LOJA, @nVlrBaixa, , @lBxCec, @lBxLiq ,@lSigaloja ,@lTipBxCP)

			For nX := 1 To Len(aBaixaSE5)
				nParciais += aBaixaSE5[nX][8]
			   If lPccBxCR .And. lRaRtImp // somar impostos PCC
			     nParciais += aBaixaSE5[nX][18]+aBaixaSE5[nX][19]+aBaixaSE5[nX][20]+aBaixaSE5[nX][30] +aBaixaSE5[nX][32]+aBaixaSE5[nX][33]
			   Endif
			   nIss +=aBaixaSE5[nX][32]
			   nInss+=aBaixaSE5[nX][33]
			Next
			nParciais += nTotAdto
		Else
			nParciais 	:= SE1->E1_VALOR-SE1->E1_SALDO
		Endif

			If MVRECANT $ SE1->E1_TIPO
			nParciais 	:= SE1->E1_VALOR-SE1->E1_SALDO
		Endif

		If (!lRartImp .and. mv_par08 == 1 .and. SE1->E1_TIPO == MVNOTAFIS .and. !lBq10925) .or. (lPropBx .and. ((!lRartImp .and. mv_par08 == 2) .or. lRartImp) .and. !lCredito)
			nParciais 	:= SE1->E1_VALOR-SE1->E1_SALDO
		EndIf
		
		If SE1->E1_SDDECRE <> SE1->E1_DECRESC
			nParciais += ( SE1->E1_DECRESC - SE1->E1_SDDECRE )
		EndIf
		
		nValRec := SE1->E1_VALOR - nParciais
		nOldVal	:= nValrec		
		If dDataBase <= dLastPcc
			//chama a f070TotMes para preencher o array aDadosRet
				f070TotMes(dBaixa,.T.)
		Else
			If SE1->E1_TIPO <> MVRECANT //.or. (SE1->E1_TIPO == MVRECANT .AND. !lRartImp .and. mv_par08 == 1) 
			
				aPcc		:= newMinPcc(dBaixa,nValRec,SE1->E1_NATUREZ,"R",SE1->E1_CLIENTE+SE1->E1_LOJA)
				nPis		:= 	aPcc[2]
				nCofins		:=	aPcc[3]
				nCsll		:=  aPcc[4]
				nPisCalc	:= nPis
				nPisBaseC	:= SE1->E1_SALDO	
				nPisBaseR 	:= SE1->E1_SALDO
				nCofCalc	:= nCofins	
				nCofBaseC	:= SE1->E1_SALDO
				nCofBaseR 	:= SE1->E1_SALDO
				nCslCalc	:= nCsll	
				nCslBaseC	:= SE1->E1_SALDO
				nCslBaseR 	:= SE1->E1_SALDO
			EndIf
			aPcc[1]		:= .T.
		EndIf
		If lRartImp 
			//Se lRartImp, retoma o valor de nValRec, alterado pela TotMes
			nValRec := SE1->E1_VALOR - nParciais
		ElseIf !lRartImp .and. aDadosRet[1] < nVlMinImp .and. ( aDadosRet[1] + nSaldo > nVlMinImp ) .and. lPccBxCr
			nValRec := nSaldo
		EndIf

		If lRartImp .And. lPccBxCr .and. SE1->E1_TIPO <> MVRECANT
			nPropPCC	:= SE1->E1_SALDO/SE1->E1_BASEPIS
			If dDataBase <= dLastPcc	
				nPis		:= SE1->E1_PIS * nPropPCC
				nCofins		:= SE1->E1_COFINS * nPropPCC
				nCsll		:= SE1->E1_CSLL * nPropPCC
			EndIf
			If MV_PAR08==1
	 			nIss		:= SE1->E1_ISS - nIss
				nInss		:= SE1->E1_INSS - nInss
			Else
				nIss		:= SE1->E1_ISS * nPropPCC
				nInss		:= SE1->E1_INSS * nPropPCC
			Endif
		EndIf
		
			If !lCredito
				nIrrf := FCaIrBxCR(nValRec+If(lRaRtImp .and. SE1->E1_TIPO $ MVRECANT,nPis+nCofins+nCsll+nIrrf,0),,lRaRtImp)
			EndIf	
		 	If (nPosIr:=ascan(aImpIR,{|x| x[2]=SE1->(REcno())}))=0
				aAdd(aImpIR,{nIrrf,SE1->(Recno())})
				nPosIr := Len( aImpIR )
			else
				aImpIR[nPosIr][1]:= nIrrf
			EndIf
		If lIrPjBxCr        
			nIrrf := nIrrf * (nValRec / SE1->E1_BASEIRF)
		EndIf

		If !aPcc[1]
			If aDadosRet[1] <= nVlMinImp .and. ( aDadosRet[1] + nSaldo > nVlMinImp ) .and. !lRaRtImp .and. lPccBxCr .and. SE1->E1_TIPO <> MVRECANT
				nValPis		:= SE1->E1_PIS
				nValCofins 	:= SE1->E1_COFINS
				nValCsll	:= SE1->E1_CSLL
				nValorNf	:= SE1->E1_VALOR
			Elseif aDadosRet[1] <= nVlMinImp .and. ( aDadosRet[1] + nSaldo <= nVlMinImp ) .and. !lRaRtImp .and. lPccBxCr .and. SE1->E1_TIPO <> MVRECANT
				nProp	:= (aDadosRet[1] + SE1->E1_SALDO) / SE1->E1_VALOR
				nValPis	:= SE1->E1_PIS * nProp
				nValCofins := SE1->E1_COFINS * nProp
				nValCsll	:= SE1->E1_CSLL * nProp
				nValorNf	:= SE1->E1_VALOR
			ElseIf aDadosRet[1] > nVlMinImp .and. ( aDadosRet[1] + nSaldo > nVlMinImp ) .and. !lRaRtImp .and. lPccBxCr .and. SE1->E1_TIPO <> MVRECANT
				nValPis	:= SE1->E1_PIS
				nValCofins := SE1->E1_COFINS
				nValCsll	:= SE1->E1_CSLL
				nValorNf	:= SE1->E1_VALOR
				nSldNf		:= SE1->E1_SALDO
			EndIf
		EndIf
		If SE1->E1_TIPO == MVRECANT
			nValorRA	:= SE1->E1_VALOR
			nSldRa		:= SE1->E1_SALDO
		EndIf
		//Caso o titulo de partida possua PCC, diminuo do saldo a compensar
		If nPis+nCofins+nCsll+nIrrf > 0  .And.  SE1->E1_TIPO <> MV_CRNEG  .and. SE1->E1_TIPO <> MVRECANT //.AND. MV_PAR08==1
			aImpPcc [1] := nPis
			aImpPcc [2] := nCofins
			aImpPcc [3] := nCsll
			If MV_PAR08 == 1 .And. ( aDadosRet[1] + nSaldo > nVlMinImp )
				//somente abate o imposto se teve retenção minima
				If lRaRtImp				
					nSaldo -= (nPis+nCofins+nCsll+nIrrf)
				Else
					If lPccBxCr
						nSaldo -= nPis+nCofins+nCsll
					EndIf
					If lIrPjBxCr
						nSaldo -= nIrrf
					EndIf
				EndIf
			Endif
			If MV_PAR08 == 2 .and. lRaRtImp .and. aPcc[1]
				nSaldo -= (nPis+nCofins+nCsll+nIrrf)
			EndIf
			If nIrrf > 0
			 	If (nPosIr:=ascan(aImpIR,{|x| x[2]=SE1->(Recno())}))=0
					aAdd(aImpIR,{nIrrf,SE1->(Recno())})
					nPosIr := Len( aImpIR )
				else
					aImpIR[nPosIr][1]:= nIrrf
				EndIf
			Endif
		Endif
	ElseIf lIrPjBxCr .And. !lRaRtImp
		nSaldo -= nIrrf
	Endif


	If nPis+nCofins+nCsll+nIrrf > 0  .And.  SE1->E1_TIPO <> MV_CRNEG .And.  SE1->E1_TIPO <> MVRECANT
		If !lRartImp .Or. (lRaRtImp .And. aDadosRet[1] > nVlMinImp ) .AND. MV_PAR08 == 2
			nValRec -= (nPis+nCofins+nCsll+nIrrf+nIss+nInss) 
			//nTotImpbx := SE1->E1_VALOR - ( nParciais + nSaldo) 
			nTotImpbx+= (nPis+nCofins+nCsll+nIrrf+nIss+nInss)
		Endif
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Se for chamada da mata465 , nao mostrar a janela de parametros   ³
	//³ e forçar o valor de nOpca con valor 1. (Loc. Arg.).              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cOrigem!="MATA465"
		If lPanelFin  //Chamado pelo Painel Financeiro
			oPanelDados := FinWindow:GetVisPanel()
			oPanelDados:FreeChildren()
			aDim := DLGinPANEL(oPanelDados)
			DEFINE MSDIALOG oDlg OF oPanelDados:oWnd FROM 0,0 To 0,0 PIXEL STYLE nOR( WS_VISIBLE, WS_POPUP )
			oDlg:Move(aDim[1],aDim[2],aDim[4]-aDim[2], aDim[3]-aDim[1])

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Observacao Importante quanto as coordenadas calculadas abaixo: ³
			//³ -------------------------------------------------------------- ³
			//³ a funcao DlgWidthPanel() retorna o dobro do valor da area do	 ³
			//³ painel, sendo assim este deve ser dividido por 2 antes da sub- ³
			//³ tracao e redivisao por 2 para a centralizacao. 					 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nEspLarg := ((DlgWidthPanel(oPanelDados)/2) - 225) /2
			nEspLin  := 0

	   Else
	   	nEspLarg := 0
	   	nEspLin  := 0
	   	DEFINE MSDIALOG oDlg FROM	88,	31 TO 275,525 TITLE STR0036 PIXEL  //"Compensa‡„o de Adiantamentos"
	   Endif

	   oDlg:lMaximized := .F.
		oPanel := TPanel():New(0,0,'',oDlg,, .T., .T.,, ,20,20)
		oPanel:Align := CONTROL_ALIGN_ALLCLIENT

	   @ 000+nEspLin, 002+nEspLarg TO 030+nEspLin, 245+nEspLarg OF oPanel	PIXEL
		@ 031+nEspLin, 002+nEspLarg TO 062+nEspLin, 245+nEspLarg OF oPanel	PIXEL

		@ 015+nEspLin, 006+nEspLarg MSGET cPrefixo							SIZE 19, 10 OF oPanel PIXEL
		@ 015+nEspLin, 032+nEspLarg MSGET cNum VALID !EMPTY(cNum)		SIZE 70, 10 OF oPanel PIXEL
		@ 015+nEspLin, 105+nEspLarg MSGET cParcela							SIZE 20, 10 OF oPanel PIXEL

		If !lCredito
			@ 015+nEspLin, 129+nEspLarg MSGET cTipoTit PICTURE "@!" VALID !Empty(cTipoTit) .AND.;
				!cTipoTit $ MVABATIM .AND. ;
				!(cTipoTit $ MVRECANT+"/"+MV_CRNEG) SIZE 12, 10 OF oPanel PIXEL
		Else
			@ 015+nEspLin, 129+nEspLarg MSGET cTipoTit PICTURE "@!" VALID !Empty(cTipoTit) .AND.;
				!cTipoTit $ MVABATIM .AND. ;
				(cTipoTit $ MVRECANT+"/"+MV_CRNEG) SIZE 12, 10 OF oPanel PIXEL
		Endif
		@ 015+nEspLin, 155+nEspLarg MSGET cCliente F3 "SA1" Valid fa330Cli()	SIZE 70, 10 OF oPanel PIXEL HASBUTTON
		@ 015+nEspLin, 226+nEspLarg MSGET cLoja	 Valid Fa330Loja() SIZE 16, 10 OF oPanel PIXEL

		@ 047+nEspLin, 006+nEspLarg MSGET nSaldo When .F. 	Picture "@E 9999,999,999.99" SIZE 50, 10 OF oPanel PIXEL
		@ 047+nEspLin, 060+nEspLarg MSGET nMoeda when .F.					SIZE 18, 10 OF oPanel PIXEL
		@ 047+nEspLin, 085+nEspLarg MSGET nVlrCompe			Picture "@E 9999,999,999.99";
			Valid nVlrCompe >= 0 .AND. STR(nVlrCompe,17,2) <= STR(nSaldo,17,2) ;
			SIZE 52, 10 OF oPanel PIXEL HASBUTTON
		@ 047+nEspLin, 142+nEspLarg MSGET dBaixa	   Valid dBaixa >= SE1->E1_EMISSAO;
			SIZE 48, 10 OF oPanel PIXEL HASBUTTON

		@ 007+nEspLin, 006+nEspLarg SAY STR0006  SIZE 21, 7 OF oPanel PIXEL  //"Prefixo"
		@ 007+nEspLin, 032+nEspLarg SAY STR0007  SIZE 22, 7 OF oPanel PIXEL  //"N£mero"
		@ 006+nEspLin, 105+nEspLarg SAY STR0008  SIZE 23, 7 OF oPanel PIXEL  //"Parcela"
		@ 006+nEspLin, 129+nEspLarg SAY STR0009  SIZE 14, 7 OF oPanel PIXEL  //"Tipo"
		@ 006+nEspLin, 155+nEspLarg SAY STR0010  SIZE 34, 7 OF oPanel PIXEL  //"Cliente   "
		@ 006+nEspLin, 226+nEspLarg SAY STR0011  SIZE 14, 7 OF oPanel PIXEL  //"Loja"
		@ 038+nEspLin, 006+nEspLarg SAY STR0012  SIZE 34, 7 OF oPanel PIXEL  //"Saldo"
		@ 038+nEspLin, 060+nEspLarg SAY STR0013  SIZE 21, 7 OF oPanel PIXEL  //"Moeda"
		@ 038+nEspLin, 085+nEspLarg SAY STR0014  SIZE 55, 7 OF oPanel PIXEL  //"Valor a compensar"
		@ 038+nEspLin, 142+nEspLarg SAY STR0015  SIZE 45, 7 OF oPanel PIXEL  //"Data da Baixa"

		If UsaSeqCor()
			SX3->(DbSetorder(2))
			SX3->(DbSeek("E5_DIACTB"))
			cCodDiario  := Criavar("E5_DIACTB",.T.)
			cTitDiar :=  AllTrim(X3TITULO())
			@ 038+nEspLin, 195+nEspLarg SAY cTitDiar SIZE 45, 7 OF oPanel PIXEL
			@ 047+nEspLin, 195+nEspLarg MSGET cCodDiario F3 "CVL" SIZE 20, 10 OF oPanel Valid VldCodSeq( cCodDiario ) When CtbWdia() PIXEL HASBUTTON
			SX3->(DbSetorder(1))
		Endif

		If lPanelFin  //Chamado pelo Painel Financeiro
			aButtonTxt := {}
			AADD(aButtonTxt,{STR0037,STR0037, {||Fa330SetMo()}})

			ACTIVATE MSDIALOG oDlg ON INIT FaMyBar(oDlg,;
			{|| If(Fa330TudOk(nVlrCompe),(nOpca:=1,oDLg:End()),)},;
			{|| oDlg:End()},,aButtonTxt)

	   Else
			@ 068+nEspLin, 005+nEspLarg BUTTON STR0037 SIZE 50,18 ACTION (Fa330SetMo()) OF oPanel PIXEL //Taxas Moedas

			/* GESTAO - inicio */
			DEFINE SBUTTON Var oBtFilial FROM 68,162 TYPE 05 ACTION { || aSelFil := Fa330Fil() } ENABLE OF oPanel
					oBtFilial:cCaption := STR0070		//"Filiais"
					oBtFilial:cToolTip := STR0071		//"Seleciona filiais"
			/* GESTAO - fim */

			DEFINE SBUTTON FROM 68, 190 TYPE 1 ENABLE ACTION (If(Fa330TudOk(nVlrCompe),(nOpca:=1,oDLg:End()),)) OF oPanel
			DEFINE SBUTTON FROM 68, 218 TYPE 2 ENABLE ACTION oDlg:End() OF oPanel

			If !lAutomato
				ACTIVATE MSDIALOG oDlg CENTERED
			Else
				If FindFunction("GetParAuto")
					
					aRetAuto := GetParAuto("FINA330TestCase")
					
					If aRetAuto[1,1,2]
						cPrefixo   := aRetAuto[1,1,1]
					EndIf
					
					If aRetAuto[1,2,2]
						cNum       := aRetAuto[1,2,1]
					EndIf
					
					If aRetAuto[1,3,2]
						cParcela   := aRetAuto[1,3,1]
					EndIf
					
					If aRetAuto[1,4,2]
						cTipoTit   := aRetAuto[1,4,1]
					EndIf
					
					If aRetAuto[1,5,2]
						cCliente   := aRetAuto[1,5,1]
					EndIf
					
					If aRetAuto[1,6,2]
						cLoja      := aRetAuto[1,6,1]
					EndIf
					
					If aRetAuto[1,7,2]
						nVlrCompe  := aRetAuto[1,7,1]
					EndIf
					
					If aRetAuto[1,8,2]
						dBaixa     := aRetAuto[1,8,1] 
					EndIf

					If Fa330TudOk(nVlrCompe)
						nOpca := 1
					EndIf	
				EndIf
			EndIf

		Endif
	Else
		nOpca	:=	1
	Endif
	IF nOpca == 0
		dbSelectArea(cAlias)
		dbSetOrder(nIndexAtu)
		deleteObject(oOk)
		deleteObject(oNo)
		FA330aUnlock()
		Return
	Endif
	DbSelectArea("SE1")
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Os valores exibidos em tela o serao na Moeda 1   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lPccBxCr
		nPropImp	:= nVlrCompe/SE1->E1_BASEPIS
		If dDataBase <= dLastPcc
			nPis		:= SE1->E1_PIS * nPropImp
			nCofins		:= SE1->E1_COFINS * nPropImp
			nCsll		:= SE1->E1_CSLL * nPropImp
			nIrrf		:= SE1->E1_IRRF * nPropImp
		Else
			If nVlrCompe>0
				aPcc		:= newMinPcc(dBaixa,nVlrCompe,SE1->E1_NATUREZ,"R",SE1->E1_CLIENTE+SE1->E1_LOJA)
			Else
				If dBaixa <> dDatabase .and. SE1->E1_TIPO <> MVRECANT //Alterou a data de baixa e nao alterou o valor
					aPcc		:= newMinPcc(dBaixa,nOldVal,SE1->E1_NATUREZ,"R",SE1->E1_CLIENTE+SE1->E1_LOJA)
				EndIf
			EndIf
			If Len(aPcc) > 2	
				nPis		:= 	aPcc[2]
				nCofins		:=	aPcc[3]
				nCsll		:=  aPcc[4]
				nPisCalc	:= nPis
				nPisBaseC	:= Iif(nVlrCompe	> 0,nVlrCompe ,nOldVal)
				nPisBaseR 	:= Iif(nVlrCompe	> 0,nVlrCompe ,nOldVal)
				nCofCalc	:= nCofins	
				nCofBaseC	:= Iif(nVlrCompe	> 0,nVlrCompe ,nOldVal)
				nCofBaseR 	:= Iif(nVlrCompe	> 0,nVlrCompe ,nOldVal)
				nCslCalc	:= nCsll	
				nCslBaseC	:= Iif(nVlrCompe	> 0,nVlrCompe ,nOldVal)
				nCslBaseR 	:= Iif(nVlrCompe	> 0,nVlrCompe ,nOldVal)
				
				
			EndIf
			If cPaisLoc == "BRA"
				nIrrf := nIrrf * (Iif(nVlrCompe	> 0,nVlrCompe ,nOldVal) / SE1->E1_BASEIRF)
			EndIf
		EndIf
		If dBaixa <> dDatabase .and. SE1->E1_TIPO <> MVRECANT //Alterou a data de baixa e nao alterou o valor
			If nPis+nCofins+nCsll+nIrrf > 0  .And.  SE1->E1_TIPO <> MV_CRNEG .And.  SE1->E1_TIPO <> MVRECANT 
				If !lRartImp .Or. (lRaRtImp .And. aDadosRet[1] > nVlMinImp ) .AND. MV_PAR08 == 2
					nValRec	:= nOldVal
					nValRec -= (nPis+nCofins+nCsll+nIrrf+nIss+nInss) 
					nTotImpbx := (nPis+nCofins+nCsll+nIrrf+nIss+nInss)   
					nSaldo	:= SE1->E1_SALDO - nPis-nCofins-nCsll    
					If nVlrCompe == 0 .and. !lIrPjBxCr
						nSaldo	:= nSaldo - SE1->E1_IRRF 
					EndIf        
				EndIf	
			Endif
		EndIf

	nValor := nVlrCompe
		If	nVlrCompe > 0 .and. nVlrCompe - nPis - nCofins - nCsll - nIrrf > 0 
			If !(!lRartimp .and. mv_par08 == 2)
				nValor 		:= nValor - nPis - nCofins - nCsll - nIrrf
			EndIf
		EndIf
	Else
		nValor := nVlrCompe
	EndIf
	nValComp := nValor
	nValIrf		:= nIrrf
	Processa({ || Fa330Tit(dEmissao,cOrigem,lCredito,aNumLay)})  // Monta a Matriz com as compensacoes validas
	If Len(aTitulos) == 0
		Help(" ",1,"NOTITSEL")
		DeleteObject(oOk)
		DeleteObject(oNo)
		FA330aUnlock()
		Exit
	Endif

	nQtdTit := 0	 // quantidade de titulos,mostrado no rodape do browse
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Titulos a compensar         ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nOpca := 0
	If cOrigem $ "MATA465#COMPENSANCC"
		cLote	:=	cLoteFat
	Endif
	aSize := MsAdvSize(,.F.,400)
	DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL
	oDLg:lMaximized := .T.
	oPanel := TPanel():New(0,0,'',oDlg,, .T., .T.,, ,20,20,.T.,.T. )
	oPanel:Align := CONTROL_ALIGN_TOP
	
	@003,005 Say STR0073 + Pad(Getmv("MV_SIMB"+Alltrim(STR(nMoeda))),4)  PIXEL Of oPanel  // "Compensaçäo de Titulos - Valores expressos em "

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Montando cabecalho do list box³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If cPaisLoc == "BRA"
		If mv_par02 == 2
			@ 1.0,1.0 LISTBOX oTitulo	VAR cVarQ Fields;
				HEADER "",STR0006,;  //"Prefixo"
				STR0007,;  //"N£mero"
				STR0008,;  //"Parcela"
				STR0009,;  //"Tipo"
				STR0011,;  //"Loja"
				STR0016,;  //"Saldo do t¡tulo"
				STR0017,;   //"Valor compensado"
				STR0064,;   //"Limite de compensação"
				STR0049,; //"Acréscimos"
				STR0050,; //"Decréscimos"
				STR0046,;  //"Cliente/Loja"
				STR0041,;  //"Nome do Cliente"
				Rtrim(RetTitle("A1_CGC")),; //"CGC do Cliente"
				Rtrim(RetTitle("E1_HIST")),; //Historico
				RetTitle("E1_FILIAL"),; //FILIAL
				RetTitle("E1_PIS"),;
				RetTitle("E1_COFINS"),;
				RetTitle("E1_CSLL"),;
				RetTitle("E1_IRRF");
				COLSIZES 12,GetTextWidth(0,"BBBBB"),GetTextWidth(0,"BBBBBBB"),;
				GetTextWidth(0,"BBBB"),GetTextWidth(0,"BBB"),GetTextWidth(0,"BBB"),;
				GetTextWidth(0,"BBBBBBBBB"),GetTextWidth(0,"BBBBBBBBB"),;
				GetTextWidth(0,"BBBBBBBBB"),GetTextWidth(0,"BBBBBBBBB"),;
				GetTextWidth(0,"BBBBBBBBB"),GetTextWidth(0,"BBBBBBBBB"),;
				GetTextWidth(0,"BBBBBBBBB"),GetTextWidth(0,"BBBBBBBBBBBBBBBBBBBB"),GetTextWidth(0,REPLICATE("B",IIf( lFWCodFil, FWGETTAMFILIAL, 2 ))),;
  				GetTextWidth(0,"BBBBBB"),GetTextWidth(0,"BBBBBB"),GetTextWidth(0,"BBBBBB");
				SIZE 293,54.5 ON DBLCLICK (aTitulos:= u_FA330Troca(oTitulo:nAt,aTitulos,oGet01,,@oTitulo),oTitulo:Refresh()) NOSCROLL

				oTitulo:SetArray(aTitulos)
				oTitulo:bLine := { || {If(aTitulos[oTitulo:nAt,8],oOk,oNo),;
					aTitulos[oTitulo:nAt,1],;//Prefixo
					aTitulos[oTitulo:nAt,2],;//Numero
					aTitulos[oTitulo:nAt,3],;//Parcela
					aTitulos[oTitulo:nAt,4],;//Tipo
					aTitulos[oTitulo:nAt,5],;//Loja
					aTitulos[oTitulo:nAt,6],;//Saldo do Titulo
					If(aTitulos[oTitulo:nAt,8],aTitulos[oTitulo:nAt,7],Transform(0,PesqPict("SE1","E1_SALDO"))),;//Saldo Compensar
					aTitulos[oTitulo:nAt,25],;//Limite de Compensacao
					aTitulos[oTitulo:nAt,13],;//Acréscimos
					aTitulos[oTitulo:nAt,14],;//Decréscimos
					aTitulos[oTitulo:nAt,10],;//CLiente+Loja
					aTitulos[oTitulo:nAt,11],;//Nome CLiente
					aTitulos[oTitulo:nAt,12],;//CGC
					aTitulos[oTitulo:nAt,15],;//Historico
					aTitulos[oTitulo:nAt,16],;//FIlial
					aTitulos[oTitulo:nAt,17],;//Pis
					aTitulos[oTitulo:nAt,18],;//Cofins
					aTitulos[oTitulo:nAt,19],;//Csll
					aTitulos[oTitulo:nAt,20]}}//Irrf

		Else
			@ 1.0,1.0 LISTBOX oTitulo	VAR cVarQ Fields;
				HEADER "",;
				STR0006,;  //"Prefixo"
				STR0007,;  //"N£mero"
				STR0008,;  //"Parcela"
				STR0009,;  //"Tipo"
				STR0011,;  //"Loja"
				STR0016,;  //"Saldo do t¡tulo"
				STR0017,;   //"Valor compensado"
				STR0064,;   //"Limite de compensação"
				STR0049,; //"Acréscimos"
				STR0050,; //"Decréscimos"
				Rtrim(RetTitle("E1_HIST")),; //Historico
				RetTitle("E1_FILIAL"),; //FILIAL
				RetTitle("E1_PIS"),;
				RetTitle("E1_COFINS"),;
				RetTitle("E1_CSLL"),;
				RetTitle("E1_IRRF");
				COLSIZES 12,GetTextWidth(0,"BBBBB"),GetTextWidth(0,"BBBBBBB"),;
				GetTextWidth(0,"BBBB"),GetTextWidth(0,"BBB"),GetTextWidth(0,"BBB"),;
				GetTextWidth(0,"BBBBBBBBB"),GetTextWidth(0,"BBBBBBBBB"),;
				GetTextWidth(0,"BBBBBBBBB"),GetTextWidth(0,"BBBBBBBBB"),;
			   GetTextWidth(0,"BBBBBBBBBBBBBBBBBBBB"),GetTextWidth(0,REPLICATE("B",IIf( lFWCodFil, FWGETTAMFILIAL, 2 ))),;
  				GetTextWidth(0,"BBBBBB"),GetTextWidth(0,"BBBBBB"),GetTextWidth(0,"BBBBBB"),;
				SIZE 293,54.5 ON DBLCLICK (aTitulos:= u_FA330Troca(oTitulo:nAt,@aTitulos,oGet01,,@oTitulo),oTitulo:Refresh()) NOSCROLL

				oTitulo:SetArray(aTitulos)
				oTitulo:bLine := { || {If(aTitulos[oTitulo:nAt,8],oOk,oNo),;//Flag
					aTitulos[oTitulo:nAt,1],;//Prefixo
					aTitulos[oTitulo:nAt,2],;//Numero
					aTitulos[oTitulo:nAt,3],;//Parcela
					aTitulos[oTitulo:nAt,4],;//Tipo
					aTitulos[oTitulo:nAt,5],;//Loja
					aTitulos[oTitulo:nAt,6],;//Saldo do Titulo
					If(aTitulos[oTitulo:nAt,8],aTitulos[oTitulo:nAt,7],Transform(0,PesqPict("SE1","E1_SALDO"))),;//Valor Compensado
					aTitulos[oTitulo:nAt,22],;//Limite de Compensacao
					aTitulos[oTitulo:nAt,10],;//Acrescimos
					aTitulos[oTitulo:nAt,11],;//Decréscimos
					aTitulos[oTitulo:nAt,12],;//Historico
					aTitulos[oTitulo:nAt,13],;//Filial
					aTitulos[oTitulo:nAt,14],;//Pis
					aTitulos[oTitulo:nAt,15],;//Cofins
					aTitulos[oTitulo:nAt,16],;//Csll
					aTitulos[oTitulo:nAt,17]}}//Irrf

		Endif
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Se na listagem de titulos nao considerar o cliente original do titulo selecionado, mostra o cgc |
		//|e o nome dos clientes referentes a cada titulo (MV_PAR02==2)                                    |
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If MV_PAR02 == 2
			//Adiciona Nome e CGC do cliente ao cabecalho
			@ 1.0,1.0 LISTBOX oTitulo	VAR cVarQ Fields;
				HEADER "",STR0006,;  //"Prefixo"
				STR0007,;  //"N£mero"
				STR0008,;  //"Parcela"
				STR0009,;  //"Tipo"
				STR0011,;  //"Loja"
				STR0016,;  //"Saldo do t¡tulo"
				STR0017,;   //"Valor compensado"
				STR0048,; //"Acréscimos"
				STR0049,; //"Decréscimos"
				STR0038,;   //"Moeda"
				STR0039,;   //"Emissao"
				STR0041,;  //"Nome do Cliente"
				Rtrim(RetTitle("A1_CGC")),; //"CGC do Cliente"
				Rtrim(RetTitle("E1_HIST")),; //Historico
				RetTitle("E1_FILIAL"); //FILIAL
				COLSIZES 12,GetTextWidth(0,"BBBBB"),GetTextWidth(0,"BBBBBBB"),;
				GetTextWidth(0,"BBBB"),GetTextWidth(0,"BBB"),;
				GetTextWidth(0,"BBB"), GetTextWidth(0,"BBBBBBBBB"),;
				GetTextWidth(0,"BBBBBBBBB"),GetTextWidth(0,"BBBBB"),;
				GetTextWidth(0,"BBBBBBBB"),GetTextWidth(0,"BBBBBBBBB"),GetTextWidth(0,"BBBBBBBBB"),;
				GetTextWidth(0,"BBBBBBBBBBBBBBBBBBBB"),GetTextWidth(0,"BBBBBBBBBBBBBB"), GetTextWidth(0,"BBBBBBBBBBBBBBBBBBBB"),GetTextWidth(0,REPLICATE("B",IIf( lFWCodFil, FWGETTAMFILIAL, 2 )));
				SIZE 293,54.5 ON DBLCLICK (aTitulos:= u_FA330Troca(oTitulo:nAt,@aTitulos,oGet01,,@oTitulo),oTitulo:Refresh()) NOSCROLL
			oTitulo:SetArray(aTitulos)
			oTitulo:bLine := { || {If(aTitulos[oTitulo:nAt,8],oOk,oNo),;
				aTitulos[oTitulo:nAt,1],aTitulos[oTitulo:nAt,2],;
				aTitulos[oTitulo:nAt,3],aTitulos[oTitulo:nAt,4],;
				aTitulos[oTitulo:nAt,5],aTitulos[oTitulo:nAt,6],;
				If(aTitulos[oTitulo:nAt,8],aTitulos[oTitulo:nAt,7],Transform(0,PesqPict("SE1","E1_SALDO"))),aTitulos[oTitulo:nAt,13],;
				aTitulos[oTitulo:nAt,14],aTitulos[oTitulo:nAt,9],;
				aTitulos[oTitulo:nAt,10],aTitulos[oTitulo:nAt,11],;
				aTitulos[oTitulo:nAt,12], aTitulos[oTitulo:nAt,15],aTitulos[oTitulo:nAt,16]}}
			//---
		Else
			//Considera o cliente original do titulo seleionado, nao mostra o nome do cliente
			@ 1.0,1.0 LISTBOX oTitulo	VAR cVarQ Fields;
				HEADER "",STR0006,;  //"Prefixo"
				STR0007,;  //"N£mero"
				STR0008,;  //"Parcela"
				STR0009,;  //"Tipo"
				STR0011,;  //"Loja"
				STR0016,;  //"Saldo do t¡tulo"
				STR0017,;   //"Valor compensado"
				STR0048,; //"Acréscimos"
				STR0049,; //"Decréscimos"
				STR0038,;   //"Moeda"
				STR0039,;   //"Emissao"
				RetTitle("E1_FILIAL"); //FILIAL
				COLSIZES 12,GetTextWidth(0,"BBBBB"),GetTextWidth(0,"BBBBBBB"),;
				GetTextWidth(0,"BBBB"),GetTextWidth(0,"BBB"),GetTextWidth(0,"BBB"),;
				GetTextWidth(0,"BBBBBBBBB"),GetTextWidth(0,"BBBBBBBBB"),;
				GetTextWidth(0,"BBBBBBBBB"),GetTextWidth(0,"BBBBBBBBB"),;
				GetTextWidth(0,"BBBBB"),GetTextWidth(0,"BBBBBBBB"),GetTextWidth(0,REPLICATE("B",IIf( lFWCodFil, FWGETTAMFILIAL, 2 )));
				SIZE 293,54.5 ON DBLCLICK (aTitulos:= u_FA330Troca(oTitulo:nAt,@aTitulos,oGet01,,@oTitulo),oTitulo:Refresh()) NOSCROLL
				oTitulo:SetArray(aTitulos)
				oTitulo:bLine := { || {If(aTitulos[oTitulo:nAt,8],oOk,oNo),;
				aTitulos[oTitulo:nAt,1],aTitulos[oTitulo:nAt,2],;
				aTitulos[oTitulo:nAt,3],aTitulos[oTitulo:nAt,4],;
				aTitulos[oTitulo:nAt,5],aTitulos[oTitulo:nAt,6],;
				If(aTitulos[oTitulo:nAt,8],aTitulos[oTitulo:nAt,7],Transform(0,PesqPict("SE1","E1_SALDO"))),aTitulos[oTitulo:nAt,11],;
				aTitulos[oTitulo:nAt,12],aTitulos[oTitulo:nAt,9],;
				aTitulos[oTitulo:nAt,10],aTitulos[oTitulo:nAt,13]}}
			//---
		EndIf
		//----
	EndIf
	If cPaisLoc == "BRA" .and. lCredito .and. (lPccBxCr .or. lIrPjBxCr)
		oTitulo:bHeaderClick := {|oObj,nCol| If( nCol==1, u_FA330Troca(oTitulo:nAt,@aTitulos,oGet01,.T.,@oTitulo),Nil), oTitulo:Refresh(),oGet01:Refresh()}
	Else
		oTitulo:bHeaderClick := {|oObj,nCol| If( nCol==1, fMarkAll(@aTitulos, @nValTot),Nil), oTitulo:Refresh(),oGet01:Refresh()}
	Endif
	oTitulo:Align := CONTROL_ALIGN_ALLCLIENT
	//---

	@  4, 353 SAY STR0045 PIXEL OF oPanel SIZE 70,7
	@  4, 403 MSGET oGet01 VAR nValTot PICTURE "@E 999,999,999.99" WHEN .F. PIXEL OF oPanel SIZE 70,7

	If ExistBlock("F330ATLIS")
		ExecBlock("F330ATLIS",.F.,.F., { @oPanel , 1, nValTot , nValor } )
	EndIf

	If !lPanelFin  //Chamado pelo Painel Financeiro

		oPanel2 := TPanel():New(0,0,'',oDlg, oDlg:oFont, .T., .T.,, ,20,20,.T.,.T. )
		oPanel2:Align := CONTROL_ALIGN_BOTTOM

	   @  4, 08  BUTTON STR0044 SIZE 50,11 ACTION (F330Invert(lPccBxCr,oTitulo,oGet01)) OF oPanel2 PIXEL
		@  4, 65  BUTTON STR0001 SIZE 50,11 ACTION PesqListBox(@oTitulo,aTitulos) OF oPanel2 PIXEL

		If lF330BOTON
		   	ExecBlock("F330BOTON",.F.,.F.)
   		EndIf

		DEFINE SBUTTON FROM 4,325 TYPE 1 ACTION (nValor := nVlrCompe,nOpca := 1,IF(Fa330OK(),oDlg:End(),nOpca:=0)) ENABLE OF oPanel2 PIXEL
		If cOrigem != "LOJA800"
		   DEFINE SBUTTON FROM 4,360 TYPE 2 ACTION oDlg:End() ENABLE OF oPanel2 PIXEL
		EndIf

   Else
	  	aButtonTxt := {}
		AADD(aButtonTxt,{STR0061,STR0044, {||F330Invert(lPccBxCr,oTitulo,oGet01)}})
		AADD(aButtonTxt,{STR0001,STR0001, {||PesqListBox(@oTitulo,aTitulos)}})
   Endif

	If lPanelFin  //Chamado pelo Painel Financeiro
	   If cOrigem != "LOJA800"
		   ACTIVATE MSDIALOG oDlg ON INIT (oTitulo:Refresh(), FaMyBar(oDlg,;
		   	{||nValor := nVlrCompe,nOpca := 1,IF(Fa330OK(),oDlg:End(),nOpca:=0)},;
				{||oDlg:End()},,aButtonTxt))
		Else
		   ACTIVATE MSDIALOG oDlg ON INIT (oTitulo:Refresh(), FaMyBar(oDlg,;
		   	{||nValor := nVlrCompe,nOpca := 1,IF(Fa330OK(),oDlg:End(),nOpca:=0)},;
				,,aButtonTxt))
		Endif
	Else
		If !lAutomato
			ACTIVATE MSDIALOG oDlg CENTERED ON INIT (oTitulo:Refresh())
		Else
			If FindFunction("GetParAuto")

				aRetAuto := GetParAuto("FINA330TestCase")

				For nX := 1 to Len(aTitulos)
					For nI := 1 to Len (aRetAuto[2])
						If aTitulos[nX,1] == Padr(aRetAuto[2,nI,1],Len(aTitulos[nX,1])) .AND. ;//Prefixo
   						   aTitulos[nX,2] == Padr(aRetAuto[2,nI,2],Len(aTitulos[nX,2])) .AND. ;//Titulo
   						   aTitulos[nX,3] == Padr(aRetAuto[2,nI,3],Len(aTitulos[nX,3])) .AND. ;//Parcela
   						   aTitulos[nX,4] == Padr(aRetAuto[2,nI,4],Len(aTitulos[nX,4]))        //Tipo

							aTitulos[nX,8] := .T.
						Else
							aTitulos[nX,8] := .F.
						EndIf
					Next nI
				Next nX
			
				nOpcA := 1
			EndIf
		EndIf    
	Endif


	If nOpcA == 1
		If lFa330Cmp
			ExecBlock("FA330Cmp",.F.,.F.)
		Endif
		nValTot := 0
		nValor  := IIf( nValor !=0 , 0 , nValor )

		For nX:=1 to Len(aTitulos)
			If aTitulos[nX,8]
				nValtot+=Fa330VTit(aTitulos[nX,7])
				If lCredito .and. lRartImp .and. lPccBxCr 
					nValTot	-= Fa330VTit(aTitulos[nX,14])
					nValTot	-= Fa330VTit(aTitulos[nX,15])
					nValTot	-= Fa330VTit(aTitulos[nX,16])
				EndIf
					Endif
		Next nX
		
		If nValTot == 0
			Help(" ",1,"NOTITSEL")
			Loop
		EndIf
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se o Vlr. Informado e'igual ao calculado.      ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If Str(nValtot,17,2) != Str(nValor,17,2) .and. nValor != 0;
				.and. nOpca == 1
			Help(" ",1,"FA330COMP")
			SE1->(dbGoto(nRecOri))
			Loop
		Endif
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica se o Vlr. Informado e'compativel com o Saldo.  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		nValor := nValTot
		If Str(nValor,17,2) > Str(nSaldo,17,2)
			Help(" ",1,"FA330IVAL")
			Exit
		EndIf
		DbSelectArea("SE1")
		nOrdSE1	:= IndexOrd()
		dbGotop()
		lPadrao:=VerPadrao(cPadrao)
		VALOR := 0
		ABATIMENTO := 0
		aRegSE1 := {}
		aBaixaSE5 := {}
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Inicio da prote‡„o via TTS							³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		If cPaisLoc == "BRA"
			For nX := 1 To Len( aTitulos )
				If	aTitulos[nX,8] 
					nVTit += Fa330VTit( aTitulos[ nX , 7 ] )
				EndIf
			Next nX
		EndIf
		
		Begin Transaction	
		For nTit := 1 to Len(aTitulos)
	  		nPosATit := nTit  // Variavel de posicao do titulo no array
			If MV_PAR02 == 2
				nPos := 25
			Else
				nPos := 22
			Endif
			If aTitulos[nTit,8]
				lMarcado := .T.
			Endif
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Caso o titulo esteja selecionado para compensa‡„o...    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			IF lMarcado
				lMarcado := .F.
				IF lPadrao .and. !lContabil .and. mv_par09 == 1
					nTotal := 0
					lContabil := .t.
					nHdlPrv := HeadProva( cLote,;
					                      "ZFINA330",;
					                      Substr( cUsuario, 7, 6 ),;
					                      @cArquivo )
				Endif
				dbSelectArea("SE1")
				dbGoTo(aRecNo[nTit])

				aAdd(aRegSE1, aRecNo[nTit])
				cAdiantamento := E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_LOJA
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Caso exista PCC e os impostos estejam sendo considerados³
				//³na compensacao, somar o valor do abatimento ao valor da ³
				//³compensacao, para desconsiderar o abatimento PCC        ³
				//³FNC - 00000003895/2008								   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If (nTotCsAbt + nTotPisAbt + nTotCofAbt) # 0 .AND. MV_PAR08 == 2
					If (SE1->E1_TIPO == MV_CRNEG) .and. (SE1->E1_SALDO > aTitulos[nTit,9]) .AND. ((aTitulos[nTit,9]+nTotAbtIni) == F330SldPri(nRecNo))
						//Se o abatimento for composto por algo alem do PCC por ex. um AB-
						If Str(nTotAbtIni,17,2) # Str((nTotCsAbt + nTotPisAbt + nTotCofAbt),17,2)
							//Somar apenas o abatimento a ser desconsiderado (PCC) na compensacao
							aTitulos[nTit,9] := aTitulos[nTit,9] + (nTotCsAbt + nTotPisAbt + nTotCofAbt)
						Else
							//Somar todo o abatimento (formado pelo PCC)
							aTitulos[nTit,9] := aTitulos[nTit,9] + nTotAbtIni
						Endif
					EndIf
				Endif
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Valor da baixa na moeda 1 					  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If cPaisLoc == "BRA"
					nValBx := aTitulos[nTit,9]
					
					If mv_par02 == 1
						nAcresc := Fa330VTit(aTitulos[nTit,10])
						nDecres := Fa330VTit(aTitulos[nTit,11])
					Else
						nAcresc := Fa330VTit(aTitulos[nTit,13])
						nDecres := Fa330VTit(aTitulos[nTit,14])
						
					EndIf
					
						
				Else
					nValBx := Fa330VTit(aTitulos[nTit,7])
               		
					If mv_par02 == 1
						nAcresc := Fa330VTit(aTitulos[nTit,11])
						nDecres := Fa330VTit(aTitulos[nTit,12])
					Else
						nAcresc := Fa330VTit(aTitulos[nTit,13])
						nDecres := Fa330VTit(aTitulos[nTit,14])
					Endif
						
				Endif
				IF lPadrao
					If cPaisLoc == "BRA"
						nValorComp += Round(NoRound(xMoeda(nValBX,nMoeda,1,,3,Fa330Tx2(nMoeda,nTxMoeda)),3),2)
					Else
						nValorComp += xMoeda(nValBX,nMoeda,1,aTitulos[nTit,10],,Fa330Tx2(nMoeda,nTxMoeda))
					EndIf
				EndIf
				nAbatNf := SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",SE1->E1_MOEDA,,SE1->E1_CLIENTE,,SE1->E1_FILIAL)
				nIrrfParc := 0				
				If dDatabase >= dLastPcc
					//Pega o Vlr recebido do tit correto.
					nValRec := Fa330VTit( aTitulos[ nTit , 9 ] )
					If !lRartImp .AND. MV_PAR08 == 1 .and. (aPcc[2] == 0 .or. aPcc[2] == Nil .or. (SE1->E1_TIPO == MVRECANT .and. SE1->E1_SALDO < nValRec) ) 
	  					nRecTit	:= recno()
	  					If nRecTit == Iif(mv_par02 == 1,aTitulos[nTit][20],aTitulos[nTit][23]) .and.;
	  						Iif(mv_par02 == 1,Val(StrTran(aTitulos[nTit][14],",",".")),Val(StrTran(aTitulos[nTit][17],",","."))) <> 0
							If nValRec + SE1->(E1_PIS+SE1->E1_COFINS+SE1->E1_CSLL) + IiF(lIrPjBxCr,nIrrf,0) + nAbatNf == SE1->E1_VALOR // Baixa Total - (Sem BX parciais)
		  						If ValType(aTitulos[nTit,nPosPis]) == "C"
		  							If mv_par02 == 1
				  						nPis		:= Val(StrTran(aTitulos[nTit][14],",", "."))		  				
										nCofins	    := Val(StrTran(aTitulos[nTit][15],",", "."))
										nCsll		:= Val(StrTran(aTitulos[nTit][16],",", "."))
									Else
										nPis		:= Val(StrTran(aTitulos[nTit][17],",","."))		  				
										nCofins	    := Val(StrTran(aTitulos[nTit][18],",","."))
										nCsll		:= Val(StrTran(aTitulos[nTit][19],",","."))
									EndIf							
								Else
									nPis		:= 	aTitulos[nTit][14]		  				
									nCofins		:=	aTitulos[nTit][15]
									nCsll		:=  aTitulos[nTit][16]
								Endif
							Else // sivaldo
							
												
								/*------------------------------------------------------ Sivaldo/Augusto Ribeiro | 19/07/2017 - 16:07:20 PM
									Correção Paleativo PCC base diferenciada
								------------------------------------------------------------------------------------------*/
								IF SE1->E1_VALOR <> SE1->E1_BASEPIS					
									IF ((SE1->(E1_VALOR - E1_IRRF - E1_CSLL - E1_COFINS - E1_PIS))  - nValRec) <= 0.05 
										nValRec	:= SE1->E1_BASEPIS				
									ELSE 
									    IF 	SE1->E1_VALOR > SE1->E1_SALDO
										    _nPropBase	:= (SE1->E1_BASEPIS * 100)/ SE1->E1_VALOR
										    nValRec		:=  nValRec *(_nPropBase / 100)
										ELSE
										    nValRec	:= SE1->E1_BASEPIS	
										ENDiF
										
									ENDIF
								ENDIF
				
								aPcc    := newMinPcc(dBaixa,nValRec,SE1->E1_NATUREZ,"R",SE1->E1_CLIENTE+SE1->E1_LOJA)
								nPis		:= 	aPcc[2]
								nCofins		:=	aPcc[3]
								nCsll		:=  aPcc[4]
								nPisCalc	:= nPis
								nPisBaseC	:= nPisBaseR	:= nValRec
								nCofCalc	:= nCofins
								nCofBaseC	:= nCofBaseR	:= nValRec
								nCslCalc	:= nCsll
								nCslBaseC	:= nCslBaseR	:= nValRec
							EndIf
						Else
							nVTit	:= 0
							For nX:=1 to Len(aTitulos) // verifica todos os títulos ja marcados
								If	aTitulos[nX,8] 
									nVTit+=Fa330VTit(aTitulos[nX,7])
								Endif
							Next
							aAreaParc	:= GetArea()
							dbGoto(nRecno)
							If !lCredito //SE1->E1_TIPO == MVNOTAFIS 
								aDadosBx := retBxTit("R",SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_TIPO,SE1->E1_CLIENTE,SE1->E1_LOJA,"01","PIS")
								If nVtit == SE1->E1_VALOR - Iif(!lPccBxCr,0,SE1->(E1_PIS + E1_COFINS + SE1->E1_CSLL)) - Iif(!lIrPjBxCr, 0, SE1->E1_IRRF) - Iif(!lCalcIssBx, 0, SE1->E1_ISS) - SE1->E1_INSS - nTotAbtIni ;
									.and. (nTotalTit + aTitulos[nTit,9]) == SE1->E1_VALOR - Iif(!lPccBxCr,0,SE1->(E1_PIS + E1_COFINS + SE1->E1_CSLL)) - Iif(!lIrPjBxCr, 0, SE1->E1_IRRF) - Iif(!lCalcIssBx, 0, SE1->E1_ISS) - SE1->E1_INSS - nTotAbtIni 
									nAltVal := SE1->E1_VALOR - nTotalTit// se os titulos ja marcados + o titulo do momento for igual o liquido, deve calcular pelo restante do saldo.
								Else
									If aDadosBx[1] + aTitulos[nTit,9] == SE1->E1_VALOR - SE1->E1_PIS - SE1->E1_COFINS - SE1->E1_CSLL - SE1->E1_IRRF - SE1->E1_ISS - SE1->E1_INSS
										nAltVal	:= SE1->E1_VALOR - aDadosBx[1]
									Else
										nAltVal	:= aTitulos[nTit,9]
									EndIf
								EndIf
								nTotalTit += nValBx
								
								aPcc		:= newMinPcc(dBaixa,nAltVal,SE1->E1_NATUREZ,"R",SE1->E1_CLIENTE+SE1->E1_LOJA)
								nPis		:= 	aPcc[2]
								nCofins		:=	aPcc[3]
								nCsll		:=  aPcc[4]
								nPisCalc	:= nPis
								nPisBaseC	:= nAltVal	
								nPisBaseR 	:= nAltVal
								nCofCalc	:= nCofins	
								nCofBaseC	:= nAltVal
								nCofBaseR 	:= nAltVal
								nCslCalc	:= nCsll	
								nCslBaseC	:= nAltVal
								nCslBaseR 	:= nAltVal
							EndIf
							RestArea(aAreaParc)
						EndIf
						If !lIrPjBxCr
							nIrrf	:= SE1->E1_IRRF
						EndIf
						
					ElseIf !lRartImp .AND. MV_PAR08 == 1 .and. SE1->E1_TIPO == MVRECANT
						aAreaParc	:= GetArea()
						dbGoto( nRecno )
						If !SE1->E1_TIPO $  MVRECANT + "|" + MV_CRNEG 
							If nVtit == SE1->E1_VALOR - Iif(!lPccBxCr,0,SE1->(E1_PIS + E1_COFINS + SE1->E1_CSLL)) - Iif(!lIrPjBxCr, 0, SE1->E1_IRRF) - Iif(!lCalcIssBx, 0, SE1->E1_ISS) - SE1->E1_INSS - nTotAbtIni ;
								.and. (nTotalTit + aTitulos[nTit,9]) == SE1->E1_VALOR - Iif(!lPccBxCr,0,SE1->(E1_PIS + E1_COFINS + SE1->E1_CSLL)) - Iif(!lIrPjBxCr, 0, SE1->E1_IRRF) - Iif(!lCalcIssBx, 0, SE1->E1_ISS) - SE1->E1_INSS - nTotAbtIni
								nAltVal := SE1->E1_VALOR - nTotalTit// se os titulos ja marcados + o titulo do momento for igual o liquido, deve calcular pelo restante do saldo.
							ElseIf nPosIr > 0
								nAltVal	:= Iif(MV_PAR08==1,(nValTot+ Iif(!lIrPjBxCr,0,aImpIR[nPosIr][1])+aImpPcc[1]+aImpPcc[2]+aImpPcc[3]+nTotAbtIni),aTitulos[nTit,9])
							Else
								nAltVal	:= Iif(MV_PAR08==1,(nValTot + aImpPcc[1]+aImpPcc[2]+aImpPcc[3]+nTotAbtIni),aTitulos[nTit,9])
							EndIf
							nTotalTit += nValBx
							If (SE1->E1_SALDO - (nValRec+nPis+nCofins+nCsll + Iif(lIrPjBxCr, 0, SE1->E1_IRRF) + If(lCalcIssBx, 0, SE1->E1_ISS) + SE1->E1_INSS))  <> 0 
								If lPccBxCr .And. nAltVal > nValBx .And. nValBx < nSaldo .And. ( nParciais == 0 .Or. NoRound( Abs( nSaldo - nValBx ) , 2 ) <> 0.01 )
									nAltVal := Iif( nValRec > nValBx , nValRec , nValBx )
								ElseIf lPccBxCr .And. nParciais > 0 .And. ( nValBx == nSaldo .Or. NoRound( Abs( nSaldo - nValBx ) , 2 ) <= 0.05 )
									nAltVal := SE1->E1_VALOR - nParciais
								EndIf
								
								aPcc := newMinPcc( dBaixa ,nAltVal , SE1->E1_NATUREZ , "R" , SE1->E1_CLIENTE + SE1->E1_LOJA )
								nPis    := aPcc[2]
								nCofins := aPcc[3]
								nCsll   := aPcc[4]
								nPisCalc	:= nPis
								nPisBaseC	:= nAltVal	
								nPisBaseR 	:= nAltVal
								nCofCalc	:= nCofins	
								nCofBaseC	:= nAltVal
								nCofBaseR 	:= nAltVal
								nCslCalc	:= nCsll	
								nCslBaseC	:= nAltVal
								nCslBaseR 	:= nAltVal

							EndIf
						EndIf
						RestArea(aAreaParc)
						If !lIrPjBxCr
							nIrrf	:= SE1->E1_IRRF
						//ElseIf lCredito .and. !lIrPjBxCr .and. !lRartimp
						//	nIrrf := 0	
						EndIf
					EndIf
				Else
					//Se for RA 
					If !lCredito .and. !lRartImp .and.  nValRec <> nOldValRec .and. aDadosret[1] <= nVlMinImp .and. (nValRec + aDadosret[1]) <= nVlMinImp .and. nValPis > 0
						nPis		:= (nValPis * (nValrec/ SE1->E1_VALOR))
						nCofins		:= (nValCofins * (nValrec/ SE1->E1_VALOR))
						nCsll		:= (nValCsll * (nValrec/ SE1->E1_VALOR))
					ElseIf !lCredito .and. !lRartImp .and. nValRec <> nOldValRec .and. (nValRec + aDadosret[1]) > nVlMinImp .and. nValPis > 0
						nPis		:= aDadosRet[2] + (nValPis * (nValrec/nValorNf)) //SE1->E1_VALOR))
						nCofins		:= aDadosRet[3] + (nValCofins * (nValrec/nValorNf))// SE1->E1_VALOR))
						nCsll		:= aDadosRet[4] + (nValCsll * (nValrec/nValorNf))// SE1->E1_VALOR))
					EndIf
					
					//Se for NF				
					If lCredito .and. !lRartImp .AND. aDadosret[1] <= nVlMinImp .and. (nValRec + aDadosret[1]) <= nVlMinImp
						If nValRec + nAbatNf == nOldValRec
							nPis		:= (SE1->E1_PIS * ((nValrec + nAbatNf)/ SE1->E1_VALOR))
							nCofins		:= (SE1->E1_COFINS * ((nValrec + nAbatNf)/ SE1->E1_VALOR))
							nCsll		:= (SE1->E1_CSLL * ((nValrec + nAbatNf)/ SE1->E1_VALOR))
						Else
							nPis		:= (SE1->E1_PIS * (nValrec/ SE1->E1_VALOR))
							nCofins		:= (SE1->E1_COFINS * (nValrec/ SE1->E1_VALOR))
							nCsll		:= (SE1->E1_CSLL * (nValrec/ SE1->E1_VALOR))
						EndIf
					ElseIf 	lCredito .and. !lRartImp .and. lPccBxCr .and. mv_par08 == 1 .and. aDadosret[1] <= nVlMinImp .and. aDadosret[1] + nValRec > nVlMinImp .and. SE1->E1_SALDO <> nValRec +nAbatNf + nPis + nCofins + nCsll
						nPis		:= aDadosRet[2] + nPis
						nCofins		:= aDadosRet[3] + nCofins
						nCsll		:= aDadosRet[4] + nCsll
					ElseIf lCredito .and. !lRaRtImp .and. mv_par08 == 1 .and. lPccBxCr .and. nPis+nCofins+nCsll+nIrrf > 0 .AND. aDadosret[1] > nVlMinImp .and. SE1->E1_SALDO <> SE1->E1_VALOR .and. nValPis > 0
						If (mv_par02 == 2 .AND. AllTrim(atitulos[1][7]) == Alltrim(atitulos[1][25])) .or. (mv_par02 == 1 .AND. nPisFina061 == 0 .and. AllTrim(atitulos[1][7]) == Alltrim(atitulos[1][22])) 
						nPis		:= (nValPis * (SE1->E1_SALDO/ SE1->E1_VALOR))
						nCofins		:= (nValCofins * (SE1->E1_SALDO/ SE1->E1_VALOR))
						nCsll		:= (nValCsll * (SE1->E1_SALDO/ SE1->E1_VALOR))
						EndIf
					ElseIf lCredito .and. !lRartImp .and. lPccBxCr .and. mv_par08 == 2 .and. aDadosret[1] <= nVlMinImp .and. aDadosret[1] + nValRec > nVlMinImp .and. SE1->E1_SALDO <> nValRec +nAbatNf + nPis + nCofins + nCsll
						nPis		:= aDadosRet[2] + (SE1->E1_PIS * (nValrec/ SE1->E1_VALOR))
						nCofins		:= aDadosRet[3] + (SE1->E1_COFINS * (nValrec/ SE1->E1_VALOR))
						nCsll		:= aDadosRet[4] + (SE1->E1_CSLL * (nValrec/ SE1->E1_VALOR))
					ElseIf lCredito .and. !lRartImp .and. lPccBxCr .and. mv_par08 == 2 .and. aDadosret[1] > nVlMinImp .and. SE1->E1_SALDO <> nValRec +nAbatNf + nPis + nCofins + nCsll
						nPis		:= (SE1->E1_PIS * (nValrec/ SE1->E1_VALOR))
						nCofins		:= (SE1->E1_COFINS * (nValrec/ SE1->E1_VALOR))
						nCsll		:= (SE1->E1_CSLL * (nValrec/ SE1->E1_VALOR))
					EndIf
				EndIf
				
				//Definindo o conteudo que sera gravado no campo E1_TITPAI do abatimento, caso exista e a baixa seja integral
				If !lCredito
					cDadosTitulo := cPrefixo + cNum + cParcela + cTipoOr + cCliente + cLoja
				Else
					cDadosTitulo := SE1->(E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO + E1_CLIENTE + E1_LOJA)
				Endif
				dbSelectArea("SE1")
				dbGoTo(nRecNo)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Guardo dados do titulo principal para utilizar   ³
				//³ no historico da contabiliza‡Æo                   ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				STRLCTPAD := SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Valor da Baixa na moeda do titulo principal 	  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If cPaisLoc == "BRA"
					nValBx2 := aTitulos[nTit,9]
					If lPccBxCr .and. nValor <> nSaldo .and. nPis > 0 .and. !lRaRtImp .and. mv_par08 == 1  .and.;
					(nValBx2 + (nPis + nCofins + nCsll) + nIrrf <> Iif(MV_PAR02==1 ,aTitulos[nTit,21],aTitulos[nTit][24])	.or.;
					(nValBx2 + nAbatNf == Iif(MV_PAR02==1,aTitulos[nTit][21],aTitulos[nTit][24])))
						If !lBq10925 .or. (nOldValRec == nValRec .and.  nValRec == aTitulos[nTit,9])
							nValBx2 := nValBx2 - (nPis + nCofins + nCsll) - Iif(lIrPjBxCr,nIrrf,0)
						EndIf					
						//If !lCredito
							nValBx	:= nValBx2
						//EndIf
						If nSaldo - aTitulos[nTit,9] - nPis - nCofins - nCsll - Iif(lIrPjBxCr,nIrrf,nAbatNf) == 0
							nValBx2 := aTitulos[nTit,9]
							nValBx	:= nValBx2
						ElseIf nValor - nIrrf == nValBx
							nValBx2 := aTitulos[nTit,9]
							nValBx	:= nValBx2
						EndIf
					Endif

					
					If mv_par02 == 1
						nAcresc := Fa330VTit(aTitulos[nTit,10])
						nDecres := Fa330VTit(aTitulos[nTit,11])
					Else
						nAcresc := Fa330VTit(aTitulos[nTit,13])
						nDecres := Fa330VTit(aTitulos[nTit,14])
					Endif
					
					If SE1->E1_TIPO $ MVRECANT+"/"+MV_CRNEG
						VALOR7 +=  nDecres
						VALOR8 +=  nAcresc
					EndIf 
					nPropPcc	:=	nRegRa	:=	0
					/////////////////
					//PCC Baixa CR
				   	If lCredito .and. lPccBxCr .and. lRaRtImp .and. !aPcc[1]
						nPis 	:= Fa330VTit(aTitulos[nTit,nPosPis])
						nCofins := Fa330VTit(aTitulos[nTit,nPosCof])
						nCsll 	:= Fa330VTit(aTitulos[nTit,nPosCsl])
					Endif
				Else
					nValBx2 := Fa330VTit(aTitulos[nTit,7])
					If lCredito
					If mv_par02 == 1
						nAcresc := Fa330VTit(aTitulos[nTit,11])
						nDecres := Fa330VTit(aTitulos[nTit,12])
					Else
						nAcresc := Fa330VTit(aTitulos[nTit,13])
						nDecres := Fa330VTit(aTitulos[nTit,14])
					Endif
					EndIf
				Endif

				nValIrf	:= nIrrf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Efetiva gravacao da compensacao SE1/SE5           ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lCredito .And. !lRaRtImp
					If lIrPjBxCr .And. Len(aImpIr) >= 1
					  	nPosIr := aScan(aImpIR,{|x| x[2]=aTitulos[nTit,nReg330]})    
					  	If nPosIr > 0 .And. aImpIR[nPosIr][1] > 0
					  		nIrrf:=Iif(lIrPjBxCr,aImpIR[nPosIr][1],0)
						Elseif lIrPjBxCr .And. Len(aImpIr)>1 .And. nTit<=len(aImpIr) .And. nPosIr>0
							nIrrf:= FReCalIRB(aImpIr,nValBx2,nPosIr)
						EndIf
					Else
						nIrrf:=0
					EndIf
					If cPaisLoc == "BRA"  
						If MV_PAR08 == 1 .Or. lRaRtImp

							If MV_PAR02 <> 2
								If Val(StrTran(StrTran(aTitulos[nTit,22],".",""),",",".")) != aTitulos[nTit,9]
									nPropIr := aTitulos[nTit,9]/aTitulos[nTit,(nPos-1)]
								Else
									nPropIr := 1
								EndIf
							Else
								nPropIr:= aTitulos[nTit,9]/aTitulos[nTit,24]
							EndIf             
						
							nIrrf := nIrrf * nPropIr
					
						Endif
					Endif	
					ntotIrbx:= nIrrf
				ElseIf lIrPjBxCr .And. Len(aImpIr)>=1 .And. !lRaRtImp
					nPosIr := aScan(aImpIR,{|x| x[2]=SE1->(REcno())})
					If nPosIr > 0  
						If lPccBxCr .and. nValTot==SE1->E1_SALDO
					   	 	nIrrf:= FReCalIRB(aImpIr,Iif(MV_PAR08==1,(nValTot+aImpIR[nPosIr][1]+aImpPcc[1]+aImpPcc[2]+aImpPcc[3]+nTotAbtIni),nValTot),nPosIr)
					  	Elseif lPccBxCr .and. nSaldo == nValTot
					  		nIrrf:= FReCalIRB(aImpIr,Iif(MV_PAR08==1,(nValTot+aImpIR[nPosIr][1]+aImpPcc[1]+aImpPcc[2]+aImpPcc[3]+nTotAbtIni),nValTot),nPosIr)
					  	Elseif nSaldo == nValTot
					  		nIrrf:= FReCalIRB(aImpIr,Iif(MV_PAR08==1,(nValTot+aImpIR[nPosIr][1]+nTotAbtIni),nValTot),nPosIr)
					  	Else //indica quem o valor foi digitado
					  		nIrrf:= FReCalIRB(aImpIr,nValTot,nPosIr)
					  	EndIF
				  	EndIf
				   	ntotIrbx := nIrrf
				Else
				   If lIrPjBxCr .AND. !(SE1->E1_TIPO $ MVRECANT+"/"+MV_CRNEG )
	              	If SE1->E1_IRRF>0
							nIrrf:=FCaIrBxCR(SE1->E1_SALDO)
						EndIf

						ntotIrbx:= nIrrf
					Else
						nAbatNf := SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",SE1->E1_MOEDA,,SE1->E1_CLIENTE,,SE1->E1_FILIAL)
				  	 	nIrrf:=0
						ntotIrbx:= nIrrf
					EndIf
				
			  	EndIf

				If aPcc[1] .and. nValIrf <> nIrrf
					nIrrf	:= nValIrf
				EndIf					
				If lRartImp .And. lPccBxCr .and. !lNcc .and. !aPcc[1]
				   nPis		:= Fa330VTit(aTitulos[nTit,nPosPis])
				   nCofins	:= Fa330VTit(aTitulos[nTit,nPosCof])
				   nCsll	:= Fa330VTit(aTitulos[nTit,nPosCsl])
				   nIrrf	:= Fa330VTit(aTitulos[nTit,nPosIrf])
				   nIss	 	:=  aDadosRA1[10,nTit]
				   nInss	:=  aDadosRA1[11,nTit]
				Endif

				If !lRartImp .and. lPccBxCr .and. !lCredito .and. aImpPcc[1] <> nPis .and. MV_PAR08==2
					aImpPcc [1] := nPis		
					aImpPcc [2] := nCofins
					aImpPcc [3] := nCsll
				EndIf
				If lCredito .and. !lNCC
					nPisBaseR 	:= Fa330VTit(aTitulos[nTit,nPosBPCR])
					nPisBaseC 	:= Fa330VTit(aTitulos[nTit,nPosBPCC])
					nCofBaseR 	:= Fa330VTit(aTitulos[nTit,nPosBPCR])
					nCofBaseC 	:= Fa330VTit(aTitulos[nTit,nPosBPCC])
					nCslBaseR 	:= Fa330VTit(aTitulos[nTit,nPosBPCR])
					nCslBaseC 	:= Fa330VTit(aTitulos[nTit,nPosBPCC])
					nIrfBase	:= Fa330VTit(aTitulos[nTit,nPosBIRF])
					If nPis > 0 .and. nPisBaseR == 0
						nPisCalc	:= nPis
						nPisBaseC	:= nValBx+nPis+nCofins+nCsll	
						nPisBaseR 	:= nPisBaseC
						nCofCalc	:= nCofins	
						nCofBaseC	:= nPisBaseC
						nCofBaseR 	:= nPisBaseC
						nCslCalc	:= nCsll	
						nCslBaseC	:= nPisBaseC
						nCslBaseR 	:= nPisBaseC
					EndIf
				Endif

				U_Fa330Grv(lPadrao,If(cPaisLoc == "BRA" .and. lCredito .and. aTitulos[nTit,9] < aTitulos[nTit,(nPos-1)],nValBx,nValBx2),cAdiantamento,StrZero(nSeq,nTamSeq),aRecno[nTit],@aBaixas,cOrigem,lCredito,mv_par09,nAcresc,nDecres,;
							aBaixaSE5,nTotAbtIni,aImpPcc,@cSequencia,cDadosTitulo,nIrrf,ntotIrbx, If(lRaRtImp,nIss,0), If(lRaRtImp,nInss,0),aTitulos[nTit,4] $ MV_CRNEG .Or. lNcc, nDescP, nDescD, @nIrrfParc)

				//Acerta o saldo do título, somente para compensações parciais
				If !lCredito .And. !lRaRtImp .And. MV_PAR08 == 1 .And. SE1->E1_TIPO <> MV_CRNEG .And. SE1->E1_TIPO <> MVRECANT
					If lPccBxCr .And. ( nPis + nCofins + nCsll > 0 ) .And. ( SE1->E1_SALDO - ( nPis + nCofins + nCsll ) > 0 )
						If aDadosret[1] <= nVlMinImp .and. aDadosRet[1]+nValRec > nVlMinImp .and. nValRec == nOldValRec .and. nValrec==nValBx
							Reclock("SE1")
							SE1->E1_SALDO -= nPis + nCofins + nCsll
							MsUnlock()
						EndIf
					EndIf
					//If lIrPjBxCr .And. nIrrfParc > 0 .And. ( SE1->E1_SALDO - nIrrfParc >= 0 )
						//Reclock("SE1")
						//SE1->E1_SALDO += nIrrfParc
						//MsUnlock()
					//EndIf
				ElseIf !lCredito .And. lRartImp .and. lPccBxCr .And. ( nPis + nCofins + nCsll > 0 ) 
					If ( SE1->E1_SALDO - ( nPis + nCofins + nCsll ) > 0 ) .and. nValRec <> nOldValRec
						Reclock("SE1")
						SE1->E1_SALDO -= nPis + nCofins + nCsll
						MsUnlock()
					EndIf
				ElseIf lCredito .and. !lRaRtImp .And. MV_PAR08 == 1 .And. SE1->E1_TIPO <> MV_CRNEG .and. aDadosRet[1]+nValRec > nVlMinImp
					If lPccBxCr .And. ( nPis + nCofins + nCsll > 0 )  .and. nValRec+nPis+nCofins+nCsll+nAbatRa <> nSldNF .and. !lPropBx //.AND. (nValor == nSaldo .or. nValor+nPis+nCofins+nCsll+nAbatNF == nSaldo)
						If SE1->E1_SALDO <> 0
							Reclock("SE1")
							//SE1->E1_SALDO += nPis + nCofins + nCsll 
							If nAbatNf > 0 .and. SE1->E1_SALDO - nAbatNf == 0
								SE1->E1_SALDO -= SE1->E1_SALDO
							EndIf
							MsUnlock()
						EndIf
					EndIf
				ElseIf lCredito .and. !lRaRtImp .And. MV_PAR08 == 2 .and. lPccBxCr .And. ( nPis + nCofins + nCsll > 0 ) .and. !lPropBx .and. !lNcc 
					SE1->E1_SALDO += nPis + nCofins + nCsll + nIrrf
				EndIf
				If SE1->E1_SALDO == 0
					nValorNf	:= 0
				EndIf
				If lCredito .and. lRartImp .and. nIrrf > 0 .and. lIrPjBxCr .and. SE1->E1_SALDO > 0
					SE1->E1_SALDO -= nIrrf
				EndIf
				If lPropBx .and. !lCredito  .and. ((SE1->E1_SALDO > 0 .and. mv_par08 == 1) .or. mv_par08 == 2)
					If lRartImp
						nImp	:= SE1->E1_PIS + SE1->E1_COFINS + SE1->E1_CSLL + SE1->E1_IRRF + SE1->E1_INSS + SE1->E1_ISS
						nVal	:= (SE1->E1_VALOR * nValRec)/(SE1->E1_VALOR - nImp)
					Else
						nVal	:= nValRec
					EndIf
					aImp	:= FpropCR(SE1->E1_VALOR, SE1->E1_PIS, SE1->E1_COFINS, SE1->E1_CSLL, SE1->E1_IRRF, SE1->E1_INSS, SE1->E1_ISS, nVal)
					If !lRartImp
						SE1->E1_VALLIQ -= (aImp[1][1]+aImp[1][2]+aImp[1][3]+aImp[1][4]+aImp[1][5]+aImp[1][6]) //NF
						If lPccBxCr
							SE1->E1_VALLIQ -= (nPis+nCofins+nCsll)
						EndIf
						If lIrPjBxCr
							SE1->E1_VALLIQ -= (nIrrf)
						EndIf
					EndIf
				ElseIf lPropBx .and. mv_par08 = 1 .and. !lCredito .and. SE1->E1_SALDO == 0
					lSaldoNf	:= .F.
				EndIf

							
				aadd( aAlt,{ STR0080,'','','',STR0081 +  Alltrim(Transform(nValBx2,PesqPict("SE5","E5_VALOR"))) })   
				///chamada da Função que cria o Histórico de Cobrança
				FinaCONC(aAlt)
				
						/*
				Atualiza o status do titulo no SERASA */
				If cPaisLoc == "BRA"
					If !(SE1->E1_TIPO $ MVRECANT+"/"+MV_CRNEG)
						If SE1->E1_SALDO <= 0
							cChaveTit := xFilial("SE1") + "|" +;
										SE1->E1_PREFIXO	+ "|" +;
										SE1->E1_NUM		+ "|" +;
										SE1->E1_PARCELA	+ "|" +;
										SE1->E1_TIPO		+ "|" +;
										SE1->E1_CLIENTE	+ "|" +;
										SE1->E1_LOJA
							cChaveFK7 := FINGRVFK7("SE1",cChaveTit)
							F770BxRen("1","CMP1",cChaveFK7)
						Endif
					Endif
				Endif

				For nX:= 1 To len(aBaixas)
					If aBaixas[nX][1][4] $ MVRECANT + "/" + MV_CRNEG
						nRecnoRa:= aBaixas[nX][1][3]
						lCompRa	:= .T.
					EndIf
					If lUsaFlag
						aAdd( aFlagCTB, {"E5_LA", "S", "SE5", aBaixas[nX][1][3], 0, 0, 0} )
					EndIf
				Next nX

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Posiciona no adiantamento para contabiliza‡„o    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dbSelectArea("SE1")
				dbGoTo(aRecNo[nTit])
				If mv_par08 == 1 .and. !lRaRtImp // .and. lCredito 
					nTotAbat := SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",SE1->E1_MOEDA,,SE1->E1_CLIENTE,,SE1->E1_FILIAL)
				Else
					nTotAbat := 0
				Endif
				
				If lPropBx .and. lCredito .AND. SE1->E1_SALDO > 0
					nImp	:= SE1->E1_PIS + SE1->E1_COFINS + SE1->E1_CSLL + SE1->E1_IRRF + SE1->E1_INSS + SE1->E1_ISS
					nVal	:= (SE1->E1_VALOR * nValor)/(SE1->E1_VALOR - nImp)
					If nVal <> SE1->E1_SALDO .and. !lRartImp
						nVal	:= nValor
						lSaldoNf	:= .F.
					EndIf
					aImp	:= FpropCR(SE1->E1_VALOR, SE1->E1_PIS, SE1->E1_COFINS, SE1->E1_CSLL, SE1->E1_IRRF, SE1->E1_INSS, SE1->E1_ISS, nVal)
					If !lSaldoNf .and. (!lRartImp .and. mv_par08 == 1)
						SE5->E5_VALOR -= (aImp[1][1]+aImp[1][2]+aImp[1][3]+aImp[1][4]+aImp[1][5]+aImp[1][6])
						If lPccBxCr
							SE5->E5_VALOR -= (nPis+nCofins+nCsll)
						EndIf
						If lIrPjBxCr
							SE5->E5_VALOR -= (nIrrf)
						EndIf
					EndIf
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Acerta o saldo do adiantamento	 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				Reclock("SE1")
				If cPaisLoc == "BRA"
					If nValBx == Fa330VTit(aTitulos[nTit,6])
						SE1->E1_SALDO := 0
						SE1->E1_DESCONT := nDescD
						SE1->E1_SDACRES := 0
						SE1->E1_SDDECRE := 0
					Else
						//Na Compensacao de RA para NF posso ter impostos gerados e devem ser abatidos no valor do SALDO.
						If SE1->E1_TIPO = 'NF' .AND. lCompRa .and. !lNcc
							nTotAbat	+= (nPis + nCofins + nCsll+ Iif(!lIrPjBxCr,0,nIrrf) )
						Endif

						// Verifica se o titulo já possui impostos gerados pela rotina de Borderô de Recebimento de Imposto (FINA061).
						nPisFina061	:=	0
						nCofFina061	:=	0
						nCslFina061	:=	0
						nIrfFina061	:=	0
						nRegSE5	:=	SE5->(Recno())
						nOrdSE5	:=	SE5->(IndexOrd())		
						If lPccBxCr .And. lIrPjBxCr 
							dbSelectArea("SE5")
							SE5->(dbSetOrder(2)) //FILIAL + TIPODOC + PREFIXO + NUMERO + PARCELA + TIPO
							If SE5->(DBSeek(xFilial("SE5")+"BA"+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO))
								While !SE5->(Eof()) .and. SE5->E5_FILIAL==xFilial("SE5") .And. ;
									SE5->E5_TIPODOC+SE5->E5_PREFIXO+SE5->E5_NUMERO+SE5->E5_PARCELA+SE5->E5_TIPO=="BA"+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO		
								
									If ("FINA061" $ Subst(SE5->E5_HISTOR,1,7)) .And. SE5->E5_MOTBX $ "PCC_IRF"						
										If Alltrim(SE5->E5_MOTBX) == "PCC"
										   nPisFina061	+= SE5->E5_VRETPIS
										   nCofFina061	+= SE5->E5_VRETCOF
										   nCslFina061	+= SE5->E5_VRETCSL
										ElseIf Alltrim(SE5->E5_MOTBX) == "IRF"
										   nIrfFina061	+= SE5->E5_VRETIRF
										Endif
									Endif					
									SE5->(DbSkip())		
							   Enddo
							Endif
						Endif
						SE5->(Dbgoto(nRegSE5))
						SE5->(Dbsetorder(nOrdSE5))										
						
						If (nPisFina061+nCofFina061+nCslFina061+nIrfFina061)> 0 .And. mv_par08 = 2 .And.;
								 SE1->E1_TIPO <> MV_CRNEG  .and. SE1->E1_TIPO <> MVRECANT 
						 	SE1->E1_SALDO	+=	(nPisFina061+nCofFina061+nCslFina061+nIrfFina061)
						Else
							nPisFina061	:=	0
							nCofFina061	:=	0
							nCslFina061	:=	0
							nIrfFina061	:=	0													 	
						Endif

						If SE1->E1_DECRESC >0 .OR. SE1->E1_ACRESC >0
						SE1->E1_SALDO	-= Round(Noround(xMoeda(nValBx-nAcresc+nDecres,nMoeda,SE1->E1_MOEDA,,3,Fa330Tx2(nMoeda,nTxMoeda),Fa330Tx2(SE1->E1_MOEDA,SE1->E1_TXMOEDA)),3),2)
						SE1->E1_SDACRES	-= Round(Noround(xMoeda(nAcresc               ,nMoeda,SE1->E1_MOEDA,,3,Fa330Tx2(nMoeda,nTxMoeda),Fa330Tx2(SE1->E1_MOEDA,SE1->E1_TXMOEDA)),3),2)
						SE1->E1_SDDECRE	-= Round(Noround(xMoeda(nDecres               ,nMoeda,SE1->E1_MOEDA,,3,Fa330Tx2(nMoeda,nTxMoeda),Fa330Tx2(SE1->E1_MOEDA,SE1->E1_TXMOEDA)),3),2)
						Else
							If lPccBxCr .AND. !lRaRtImp .AND. aDadosret[1] < nVlMinImp .and. aDadosRet[1]+nValor > nVlMinImp .and. lCredito .and. !lPropBx
								If nTotAbat > 0
								SE1->E1_SALDO	-= Round(Noround(xMoeda(nValBx+nTotAbat,nMoeda,SE1->E1_MOEDA,,3,Fa330Tx2(nMoeda,nTxMoeda),Fa330Tx2(SE1->E1_MOEDA,SE1->E1_TXMOEDA)),3),2)
								Else
								SE1->E1_SALDO	-= Round(Noround(xMoeda(nValBx+nPis+nCofins+nCsll+nIrrf+nIss+nTotAbat,nMoeda,SE1->E1_MOEDA,,3,Fa330Tx2(nMoeda,nTxMoeda),Fa330Tx2(SE1->E1_MOEDA,SE1->E1_TXMOEDA)),3),2)
								EndIf
							Else
								SE1->E1_SALDO	-= Round(Noround(xMoeda(nValBx,nMoeda,SE1->E1_MOEDA,,3,Fa330Tx2(nMoeda,nTxMoeda),Fa330Tx2(SE1->E1_MOEDA,SE1->E1_TXMOEDA)),3),2)
							EndIf
						EndIf
					Endif
					SE1->E1_VALLIQ := xMoeda(nValBx,SE1->E1_MOEDA,1,,nDecs1+1,Fa330TxMd(SE1->E1_MOEDA,SE1->E1_TXMOEDA))
					If !(STR(SE1->E1_SALDO,17,2) ==  STR(nTotAbat,17,2)  )
					   
					  IF (SE1->E1_SALDO - val(STR(nTotAbat,17,2)  ))<= 0.05
						   SE1->E1_SALDO := 0
					  EndIf
					Else  
					  SE1->E1_SALDO := 0
					Endif
					
					SE1->E1_MOVIMEN := dDatabase
		
					If lPropBx .and. !lRartImp .and. !lCredito 
						If  lSaldoNf
							If mv_par08 == 1 
								SE1->E1_SALDO	+= (aImp[1][1]+aImp[1][2]+aImp[1][3]+aImp[1][4]+aImp[1][5]+aImp[1][6])
							EndIf
							SE1->E1_VALLIQ -= (aImp[1][1]+aImp[1][2]+aImp[1][3]+aImp[1][4]+aImp[1][5]+aImp[1][6]) //RA
							If lPccBxCr
								SE1->E1_VALLIQ -= (nPis+nCofins+nCsll)
							EndIf
							If lIrPjBxCr
								SE1->E1_VALLIQ -= (nIrrf)
							EndIf
						EndIf
					EndIf
					If lPropBx .and. ((mv_par08 == 1 .and. !lRartImp) .or. lRartImp) .and. lCredito
						If !(SE1->E1_VALLIQ == SE5->E5_VALOR)
							SE1->E1_VALLIQ -= (aImp[1][1]+aImp[1][2]+aImp[1][3]+aImp[1][4]+aImp[1][5]+aImp[1][6])
							If lPccBxCr
							SE1->E1_VALLIQ -= (nPis+nCofins+nCsll)
							EndIf
							If lIrPjBxCr
							SE1->E1_VALLIQ -= (nIrrf)
							EndIf
						EndIf	
						If lSaldoNf					
							SE1->E1_SALDO -= (aImp[1][1]+aImp[1][2]+aImp[1][3]+aImp[1][4]+aImp[1][5]+aImp[1][6])
							If lPccBxCr
								SE1->E1_SALDO -= (nPis+nCofins+nCsll)
							EndIf
							If lIrPjBxCr
								SE1->E1_SALDO -= (nIrrf)
							EndIf
						EndIf
					EndIf 

					/////////////////
					//PCC Baixa CR
					If nMoeda == 1
						If lCredito .and. lPccBxCr .and. SE1->E1_SALDO > 0 .and. aDadosret[1] <= nVlMinImp .and. aDadosRet[1]+nValRec > nVlMinImp // .and. nSaldo == nValRec
								If (nPisFina061+nCofFina061+nCslFina061+nIrfFina061)== 0 
									//SE1->E1_SALDO -= Iif(aTitulos[nTit,4] $ MV_CRNEG .Or. lNcc,0,nIrrf)
									If lPccBxCr .and. aDadosret[1] <= nVlMinImp .and. ((!lRaRtImp .and. mv_par08 == 1 .and. !lBq10925) .or. (lRartimp .and. mv_par08==1))
										If nValRec+nPis+nCofins+nCsll == nValBx+nPis+nCofins+nCsll
											SE1->E1_SALDO -= (nPis+nCofins+nCsll+nIrrf)
										Else
											SE1->E1_SALDO += nPis+nCofins+nCsll
										EndIf
									ElseIf lPccBxCr .and. !lRaRtImp .and. mv_par08 == 1 .and. lBq10925 .and. !lNCC 
										SE1->E1_SALDO -= (nPis+nCofins+nCsll)
										If !lIrPjBxCr .and. (SE1->E1_SALDO - nIrrf == 0 .or. SE1->E1_SALDO - nIrrf <= 0.05) //problemas de arredondamento 
											SE1->E1_SALDO -= nIrrf
											SE1->E1_SALDO := Iif(SE1->E1_SALDO <= 0.05,0,SE1->E1_SALDO)
										EndIf	
										If	nAbatNf > 0 .and. (SE1->E1_SALDO - nAbatNf) == 0
											SE1->E1_SALDO -= nAbatNf
										EndIf
									ElseIf lPccBxCr .and. aDadosret[1] <= nVlMinImp .and. lRartimp .and. mv_par08==2 
										SE1->E1_SALDO -= nPis+nCofins+nCsll
									Endif 
									If lRaRtImp
										SE1->E1_SALDO -= (nIss+nInss)
									Endif				
								Endif	
						ElseIf !lCredito .and. lPccBxCr .and. SE1->E1_SALDO > 0 .and. aDadosRet[1]+nValRec > nVlMinImp	
							If (nPisFina061+nCofFina061+nCslFina061+nIrfFina061)== 0
								If lPccBxCr .and. nPis+nCofins+nCsll > 0 .and. nValorNf <> 0 .and. !lRaRtImp .and. mv_par08 == 1
									SE1->E1_SALDO += (nPis+nCofins+nCsll)
								Endif
								If lPccBxCr .and. nPis+nCofins+nCsll > 0 .and. lRartImp .and. lCredito
									SE1->E1_SALDO -= (nPis+nCofins+nCsll)
								ElseIf lPccBxCr .and. nPis+nCofins+nCsll > 0 .and. !lRartImp .and. mv_par08 == 1 .and. !SE1->E1_TIPO $ MV_CRNEG   
									SE1->E1_SALDO -= (nPis+nCofins+nCsll)
									If !lIrPjBxCr .AND. nAbatNf > 0 .and. (SE1->E1_SALDO - nAbatNf) == 0
										SE1->E1_SALDO -= nAbatNf
									Elseif lIrPjBxCr 
										SE1->E1_SALDO -= nIrrf
									EndIf
								ElseIf lPccBxCr .and. nPis+nCofins+nCsll > 0 .and. !lRartImp .and. mv_par08 == 2
									SE1->E1_SALDO += (nPis+nCofins+nCsll)
									If lIrPjBxCr 
										SE1->E1_SALDO += nIrrf
									ElseIf nAbatNf > 0 .and. nOldValRec == nValRec
										SE1->E1_SALDO += nAbatNf
									EndIf
								EndIf
								If lRaRtImp .and. !lPropBx 
									SE1->E1_SALDO -= (nIss+nInss)
								Endif	
							EndIf
						ElseIf !lCredito .and. !lRaRtImp .And. MV_PAR08 == 2 .And. ( nPis + nCofins + nCsll > 0 ) .and. !lPropBx .and. !SE1->E1_TIPO $ MV_CRNEG
							If lPccBxCr 
								SE1->E1_SALDO += nPis + nCofins + nCsll 
							EndIf  
							If lIrPjBxCr
								SE1->E1_SALDO += nIrrf
							ElseIf SE1->E1_SALDO - nPis - nCofins - nCsll == 0
								SE1->E1_SALDO += nAbatNf
							Endif
						Endif
					EndIf

				Else
					If nValBx == Fa330VTit(aTitulos[nTit,6])
						SE1->E1_SALDO := 0
						SE1->E1_SDACRES := 0
						SE1->E1_SDDECRE := 0
					Else
						nDecs := MsDecimais(SE1->E1_MOEDA)
						nSalTit := SE1->E1_SALDO - Round(xMoeda(nValBx-nAcresc+nDecres,nMoeda,SE1->E1_MOEDA,dDatabase,nDecs+1,aTxMoedas[nMoeda][2],aTxMoedas[SE1->E1_MOEDA][2]),nDecs)
						SE1->E1_SALDO   := Iif(nSalTit <= 0,0,nSalTit)
					EndIf
					SE1->E1_MOVIMEN := dDatabase
					SE1->E1_VALLIQ  += nValBx
				EndIf								
				SE1->E1_BAIXA := dBaixa
				SE1->E1_STATUS:= IIF(SE1->E1_STATUS != "R",Iif(SE1->E1_SALDO > 0.01,"A","B"),"R")
				MsUnlock()
				nSE1Rec := SE1->(Recno())
				cKeyAbt := SE1->(E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA)
				cTipo:= SE1->E1_TIPO
				xFilSE1  := SE1->E1_FILIAL
				// Efetua a baixa dos titulos de abatimento
				If lCredito .AND. SE1->E1_SALDO - nTotAbat <= 0   //Se nao for titulo de adiantamento
					//atualiza status do adiantamento de viagem
					If (ALLTRIM(SE1->E1_ORIGEM) == "FINA677")
						FINATURES(SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA),.T.,SE1->E1_ORIGEM,"R")
					Endif
					If Select("__SE1") == 0
						SumAbatRec("","","",1,"")
					Endif
					dbSelectArea("__SE1")
					__SE1->(dbSetOrder(2))
					__SE1->(dbSeek(xFilSE1+cKeyAbt))
					If lTitpaiSE1
				 		If (nOrdTitPai:= OrdTitpai()) > 0
	   						DbSetOrder(nOrdTitPai)
							If	DbSeek(xFilSE1+Subs(cAdiantamento,1,nTamTit+nTamTip)+__SE1->E1_CLIENTE+__SE1->E1_LOJA)
								bWhile := {|| !Eof() .And. E1_FILIAL + ALLTRIM(E1_TITPAI) == xFilSE1 + Alltrim(Subs(cAdiantamento,1,nTamTit+nTamTip)+__SE1->E1_CLIENTE+__SE1->E1_LOJA)}
							Else
						   		__SE1->(dbSetOrder(2))
								__SE1->(dbSeek(xFilSE1+cKeyAbt))
							Endif
						Endif
					Endif

					While Eval(bWhile)
						If lTitpaiSE1
							If (  alltrim(E1_TITPAI)!=Alltrim(Subs(cAdiantamento,1,nTamTit+nTamTip)+__SE1->E1_CLIENTE+__SE1->E1_LOJA )) .and. !Empty(E1_TITPAI)
								DbSkip()
								Loop
							EndIf
						EndIf
							 IF E1_TIPO $ MVABATIM+"/"+MVIRABT+"/"+MVINABT+"/"+MVPIABT+"/"+ MVCFABT+"/"+MVCSABT

								RecLock("__SE1")
								If !lPropBx 
								Replace E1_SALDO	With 0
								Else
									Do Case
										Case E1_TIPO $ MVPIABT .and. !lPccBxCr
											Replace E1_SALDO	With (E1_SALDO - aImp[1][1])
										Case E1_TIPO $ MVCFABT .and. !lPccBxCr
											Replace E1_SALDO	With (E1_SALDO - aImp[1][2])
										Case E1_TIPO $ MVCSABT .and. !lPccBxCr
											Replace E1_SALDO	With (E1_SALDO - aImp[1][3])
										Case E1_TIPO $ MVIRABT .and. !lIrPjBxCr
											Replace E1_SALDO	With (E1_SALDO - aImp[1][4]) 
										Case E1_TIPO $ MVINABT 				
											Replace E1_SALDO	With (E1_SALDO - aImp[1][5])
										Case E1_TIPO $ MVISABT   				
											Replace E1_SALDO	With (E1_SALDO - aImp[1][6])	
									EndCase
								EndIf
								Replace E1_BAIXA	With If(E1_BAIXA <= dBaixa, dBaixa, E1_BAIXA)
								Replace E1_STATUS  With "B"
								Replace E1_MOVIMEN With dDataBase
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³Gravar o titulo que baixou o AB- para evitar estornos de ³
								//³abatimentos baixados por outras rotinas. Evita que um AB-³
								//³baixado pelo FINA070 / 110 seja estornado indevidamente  ³
								//³pelo FINA330, que gera erro na composicao do saldo do    ³
								//³titulo principal com abatimento.                         ³
								//³Gravar SEMPRE NCC/RA para identificar a baixa do AB-     ³
								//³pela rotina FINA330										³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								If !Empty(cDadostitulo)
									If Empty(E1_TITPAI)
										Replace E1_TITPAI	With cDadosTitulo
									EndIf
								Else
									Replace E1_TITPAI	With ""
								Endif

								MsUnlock()
							Endif
						dbSkip()
					Enddo
					__SE1->(dbSetOrder(1))
				Endif
				dbSelectArea("SE1")
				dbGoto(nSE1Rec)
				
							/*
				Atualiza o status do titulo no SERASA */
				If cPaisLoc == "BRA"
					If !(SE1->E1_TIPO $ MVRECANT+"/"+MV_CRNEG)
						If SE1->E1_SALDO <= 0
							cChaveTit := xFilial("SE1") + "|" +;
										SE1->E1_PREFIXO + "|" +;
										SE1->E1_NUM		+ "|" +;
										SE1->E1_PARCELA + "|" +;
										SE1->E1_TIPO	+ "|" +;
										SE1->E1_CLIENTE + "|" +;
										SE1->E1_LOJA
							cChaveFK7 := FINGRVFK7("SE1",cChaveTit)
							F770BxRen("1","CMP1",cChaveFK7)
						Endif
					Endif
				Endif
				
				VALOR2 := 0
				VALOR3 := 0
				VALOR4 := 0
				VALOR5 := 0
				VALOR6 := 0
				If lPropBx .and. lCredito .And. cPaisLoc == "BRA"
					If !lPccBxCr
						SE5->E5_VRETPIS	:= aImp[1][1]
						SE5->E5_VRETCOF	:= aImp[1][2]
						SE5->E5_VRETCSL	:= aImp[1][3]
					EndIf
					If !lIrPjBxCr
						SE5->E5_VRETIRF	:= aImp[1][4]
					EndIf
					SE5->E5_VRETINS	:= aImp[1][5]
					SE5->E5_VRETISS	:= aImp[1][6]
				EndIf
				If lCredito .and. !lPropBx
					If cPaisLoc == "BRA" .and. lPccBxCr
						If EMPTY(SE5->E5_PRETPIS)
							VALOR3 := SE5->E5_VRETPIS
						ENDIF
						If EMPTY(SE5->E5_PRETCOF)
							VALOR4 := SE5->E5_VRETCOF
						Endif
						If EMPTY(SE5->E5_PRETCSL)
							VALOR5 := SE5->E5_VRETCSL
						Endif
					Endif

					If 	lIrPjBxCr
						VALOR2 := SE5->E5_VRETPIS
					EndIf  

					dbSelectArea("SE1")
					dbGoto(nSE1Rec)
				Endif

				IF lPadrao .and. mv_par09 == 1
					nTotal += DetProva( nHdlPrv,;
					                    cPadrao,;
					                    "ZFINA330",;
					                    cLote,;
					                    /*nLinha*/,;
					                    /*lExecuta*/,;
					                    /*cCriterio*/,;
					                    /*lRateio*/,;
					                    /*cChaveBusca*/,;
					                    /*aCT5*/,;
					                    /*lPosiciona*/,;
					                    @aFlagCTB,;
					                    {"SE5",nRecnoRA}/*aTabRecOri*/,;
					                    /*aDadosProva*/ )
				Endif

				VALOR2 := 0
				VALOR3 := 0
				VALOR4 := 0
				VALOR5 := 0
				VALOR6 := 0
				VALOR7 := 0
				VALOR8 := 0
				aPcc := {}
				aPcc		:= Array(4)
				
				dbSelectArea ("SE1")
				dbSetOrder(1)

				If lfa330Bx
					Execblock("FA330BX",.f.,.f.)
				Endif
			Endif
		Next
		If lF330SE5 
			ExecBlock("F330SE5",.F.,.F.,{aRecSe5})
		EndIf     						
		nRegSE5 := SE5->(Recno())
		nRegSE1 := SE1->(Recno())
		If GetMv("MV_COMISCR") == "S" .and. GetMv("MV_TPCOMIS") == "O"
			dbSelectArea("SE1")
			dbSetOrder(2)
			dbGoto(nRecNo)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se calcula comissao sobre valores       ³
			//³ de NCC ou RA que compuseram a compenca‡Æo Receb. ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If mv_par06 == 2 .Or. mv_par13 == 2
				For nLinha:= Len(aBaixas) to 1 Step -1
					lDeleted := .F.
					// Verifica se ha a 5 dimensao na matriz de valores baixados
					If Len(aBaixas[nLinha][1]) >= 5
						If mv_par06 == 2
							If MV_CRNEG $ SubStr(aBaixas[nLinha][1][5],nTamTit+1,nTamTip)
								ADEL(aBaixas,nLinha)
								ASIZE(aBaixas,Len(aBaixas)-1)
								lDeleted := .T.
							Endif
						Endif
						If mv_par13 == 2 .And. !lDeleted
							If MVRECANT $ SubStr(aBaixas[nLinha][1][5],nTamTit+1,nTamTip)
								ADEL(aBaixas,nLinha)
								ASIZE(aBaixas,Len(aBaixas)-1)
							Endif
						Endif
					Endif
				Next
			Endif
						
			// Nunca calcular comissão sobre títulos de Crédito (NCC/RA)
			For nLinha:= Len(aBaixas) to 1 Step -1	
				If aBaixas[nLinha][1][4] $ MV_CRNEG +"\"+ MVRECANT
					ADEL(aBaixas,nLinha)
					ASIZE(aBaixas,Len(aBaixas)-1)
				EndIf
			Next
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Calcula comissao, se houver vendedor		  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Len(aBaixas) > 0
				AeVal(aBaixas,{|x|Fa440CalcB(x,.T.,.T.,"FINA070")})
				Pergunte("FIN330",.F.)		//Restauracao de valor das perguntas
			EndIf
		Endif

		//PCC Baixa CR
		If cPaisLoc == "BRA" .and. lPccBxCr .and. !lCredito
			If lIrPjBxCr
				VALOR2 := nIrrf //SE1->E1_IRRF
			EndIf	
			If lPccBxCr
				If EMPTY(SE5->E5_PRETPIS)
					VALOR3 := nPis //SE5->E5_VRETPIS
				ENDIF
				If EMPTY(SE5->E5_PRETCOF)
					VALOR4 := nCofins//SE5->E5_VRETCOF
				Endif	
				If EMPTY(SE5->E5_PRETCSL)				
					VALOR5 := nCsll //SE5->E5_VRETCSL
				Endif
			EndIf	

		Endif

		If lPadrao .and. mv_par09 == 1

			SE5->(dbGoBottom())
			SE5->(dbSkip())
			SE1->(dbGoBottom())
			SE1->(dbSkip())
			VALOR := nValorComp
			IF nMoeda>1
				VALORMF := xMoeda(nValorComp,nMoeda,1,dDatabase,nDecs1+1,aTxMoedas[nMoeda][2],nDecs1)
			Endif
			Variacao := nValCorCM
			nSldReal := Round(NoRound(xMoeda(nSaldo,nMoeda,1,,3,Fa330TxMd(nMoeda,0)),3),2)
			ABATIMENTO := IIF(STR(nSldReal,17,2) == STR(nValorComp,17,2),nTotAbat,0)
			REGVALOR := nRecno		// Variavel para usu rio reposicionar o registro do RA
			nTotal += DetProva( nHdlPrv,;
			                    cPadrao,;
			                    "ZFINA330",;
			                    cLote,;
			                    /*nLinha*/,;
			                    /*lExecuta*/,;
			                    /*cCriterio*/,;
			                    /*lRateio*/,;
			                    /*cChaveBusca*/,;
			                    /*aCT5*/,;
			                    /*lPosiciona*/,;
			                    @aFlagCTB,;
			                    /*aTabRecOri*/,;
			                    /*aDadosProva*/ )

			RodaProva(  nHdlPrv,;
						nTotal)

			If UsaSeqCor()
				For nX := 1 To Len(aBaixaSE5)
					AAdd(aDiario,{"SE5",aBaixaSE5[nX],cCodDiario,"E5_NODIA","E5_DIACTB"})
				Next nX
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Envia para Lan‡amento Cont bil							  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			lDigita := IIF( mv_par07 == 1,.t., .f. )
			cA100Incl( cArquivo,;
			           nHdlPrv,;
			           3,;
			           cLote,;
			           lDigita,;
			           .F.,;
			           /*cOnLine*/,;
			           /*dData*/,;
			           /*dReproc*/,;
			           @aFlagCTB,;
			           /*aDadosProva*/,;
			           aDiario )
			aFlagCTB := {}  // Limpa o coteudo apos a efetivacao do lancamento

			VALORMF:= 0
			VALOR  := 0
			VALOR2 := 0
			VALOR3 := 0
			VALOR4 := 0
			VALOR5 := 0
			VALOR6 := 0
			VALOR7 := 0
			VALOR8 := 0

		Endif
		SE5->(dbGoTo(nRegSE5))
		SE1->(dbGoTo(nRegSE1))

		//integracao com modulo PCO
		(nRecno, aRegSE1, aBaixaSE5)

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Final  da protecao via TTS	                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		End Transaction

		If lACAtivo
			ACFina070() // Realiza as consequencias de uma baixa de titulo com o modulo Gestao Educacional ativo.
		Endif

	Endif
	Exit
EndDo

cPrefixo := CriaVar("E1_PREFIXO")
cNum		:= CriaVar("E1_NUM")
cTipoTit := CriaVar("E1_TIPO")
cCliente := CriaVar("E1_CLIENTE")
cLoja 	:= CriaVar("E1_LOJA")
cSaldo	:= CriaVar("E1_SALDO")
nValor	:= CriaVar("E1_SALDO")
cParcela := CriaVar("E1_PARCELA")
nMoeda	:= 1
nValor	:= 0
nValTot	:= 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Finaliza a gravacao dos lancamentos do SIGAPCO            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PcoFinLan("000016")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Recupera a Integridade dos dados		³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SE1")
dbSetOrder(nIndexAtu)
dbGoTo(nTitIni)

DeleteObject(oOk)
DeleteObject(oNo)
FA330aUnlock()
Return (.T.)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ fa330Cli ³ Autor ³ Mauricio Pequim Jr.   ³ Data ³ 21/03/94 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica validade do Cliente								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ fa330Cli()												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FINA330													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fa330Cli( )
Local cAlias := Alias( )
dbSelectArea("SA1")
dbSeek(xFilial("SA1")+cCliente)
IF !Found()
	Help(" ",1,"A330CLI")
	Return .F.
Else
	cLoja:=Iif(Empty(cLoja),SA1->A1_LOJA,cLoja)
EndIF
dbSelectArea(cAlias)
Return .T.

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ fa330Loja³ Autor ³ Mauricio Pequim Jr.   ³ Data ³ 21/03/94 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Verifica validade da Loja do Cliente						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ fa330Loja() 												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FINA330													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static FuncTion fa330Loja()
LOCAL cAlias:=Alias()
LOCAL nOrdSe1 := 0
LOCAL lRet := .T.

//PCREQ-3782 - Bloqueio por situação de cobrança
Local cLstCart := FN022LSTCB(1,'0007')	//Lista das situacoes de cobranca (Carteira)
Local cLstNoBlq := FN022LSTCB(6,'0007')	//Lista das situacoes de cobranca (Não bloqueadas para determinado processo)

dbSelectArea("SA1")
dbSeek(xFilial()+cCliente+cLoja)
IF !Found()
	Help(" ",1,"A330LOJA")
	lRet := .F.
Endif
If lRet
	dbSelectArea("SE1")
	nOrdSe1 := IndexOrd()
	dbSetOrder(2)
	If dbSeek(xFilial()+cCliente+cLoja+cPrefixo+cNum+cParcela+cTipoTit)
		If mv_par05 == 2 .and. !(E1_SITUACA $ cLstCart)
			Help(" ",1,"F330CARTE")
			lRet := .F.

		//PCREQ-3782 - Bloqueio por situação de cobrança
		ElseIf !(E1_SITUACA $ cLstNoBlq)
			Help(" ",1,"F330BLOQD",,STR0079,1,0)	//"Não é possível realizar a operação pois o título se encontra em situação de cobrança que não permite manutenção ou movimento financeiro do titulo."
			lRet := .F.
		Endif
	Else
		Help(" ",1,"NOTIT")
		lRet := .F.
	Endif
	dbSetOrder(nOrdSe1)
Endif

dbSelectArea(cAlias)

Return lRet

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Fa330Tit	³ Autor ³ Mauricio Pequim Jr.   ³ Data ³ 22/09/97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Gera Tabela com os titulos 								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Fina330													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
STATIC Function Fa330Tit(dEmissao,cOrigem,lCredito,aNumLay)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Salva a Integridade dos dados de Entrada 						  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL cSavArea := alias()
Local cAliasSE1:= "SE1"
LOCAL lMarca	:=.T.
LOCAL lF330RIO  := ExistBlock("F330RIO")
Local lQuery    := .F.
LOCAL nSavOrd	:= IndexOrd()
LOCAL nRecNo	:= RecNo()
LOCAL nTotComp	:=0
LOCAL nVlBasico :=0
Local nDecs     := MsDecimais(nMoeda)
Local bWhile    := {|| .T.}
LOCAL nRecEmp  := SM0->(RecNo())
LOCAL cEmpAnt  := SM0->M0_CODIGO
LOCAL cFilDe
LOCAL cFilAte
Local cCgcClie, cNomclie
Local nX := 0
Local nPosNumLay:= 0
Local lFa330Qry := Existblock("FA330QRY")
Local cOrdemSE1
Local lTitRAMex	:= cPaisLoc == "MEX" .And. X3Usado("ED_OPERADT") //Define se o titulo de RA esta disponivel - Manejo de Anticipo
Local lPropRA 	:= SuperGetMv("MV_COMPCR",,.F.)                     //Verifica se vai proporcionalizar quando RA para NF.
Local lPccBxCr	:= FPccBxCr()								    	//Controla o Pis Cofins e Csll na baixa  (1-Retem PCC na Baixa ou 2-Retem PCC na Emissão(default) )
Local lIrPjBxCr	:= FIrPjBxCr()									   //Controla IRPJ na baixa
Local lAdiciona := .T.
Local nPisRaRet := nCofRaRet := nCslRaRet := nSaldoProp := 0
Local lLiq      := .F.
Local aOldBaixaSE5
Local aBxSE5		:= {}
LOCAL nTotAdto		:= 0
Local lBaixaAbat	:= .F.
Local nVlrBaixa		:= 0
Local lBxCec		:= .F.
Local lBxLiq		:= .F.
Local x				:= 0
Local aImpPccIr		:= { SE5->E5_VRETPIS, SE5->E5_VRETCOF, SE5->E5_VRETCSL, SE5->E5_VRETIRF }
Local nSaldoNF		:= 0
Local nTotIrAbt		:= 0
Local nVlMinImp		:= GetNewPar("MV_VL10925",5000)
Local nTotCsAbt		:= 0
Local nTotPisAbt	:= 0
Local nTotCofAbt	:= 0
Local nPccBxCr		:= 0
Local lAplVlMin		:= .T.
Local nValorPcc		:= 0
Local aCamposKey	:= {}
Local nValLim 		:= 0 //Limite de Compensacao
Local nImp          := 0 //Valor dos Imposto (proporcao)
Local nProp         := 0 //proporcao da baixa
Local nValProp      := 0

//--- Tratamento Gestao Corporativa
Local lGestao   := Iif( lFWCodFil, FWSizeFilial() > 2, .F. )	// Indica se usa Gestao Corporativa
//
Local cFilFwSE1 := IIF( lGestao, FwFilial("SE1") , xFilial("SE1") )
Local lSE1Exclusivo := .F.
Local nMoedaP		:= 1
Local nMoedaD		:= 1
Local nTaxaP		:= 0
Local nTaxaD		:= 0
Local cSep	:=	IIf("|"$MV_CRNEG,"|",",")
Local nPosVlrLim := 0
Local lNcc			:= SE1->E1_TIPO $ MV_CRNEG 
Local lNcc2			:= .F.
//Impostos gerados pela rotina de Borderô de Recebimento de Imposto (FINA061).
Local	nPisFina061	:=	0
Local	nCofFina061	:=	0
Local	nCslFina061	:=	0
Local	nIrfFina061	:=	0     
Local nOrdSE5		:=	0
Local nRegSE5		:=	0
Local aDadRetAux	:= {}
/* GESTAO - inicio */
Local cTmpSE1Fil	:= ""
Local aTmpSE1Fil	:= {}
/* GESTAO - fim */
Local aPcc			:= Array(4)
Local nValRec2	:= 0

//PCREQ-3782 - Bloqueio por situação de cobrança
Local cLstCart := FN022LSTCB(1,'0007')	//Lista das situacoes de cobranca (Carteira)
Local cLstNoBlq := FN022LSTCB(6,'0007')	//Lista das situacoes de cobranca (Não bloqueadas para determinado processo)

#IFDEF TOP

	Local cQuery   := ""
	Local cAliasSA1:= "SA1"
	Local aStruQry := {}
	Local cUserKey	:= SE1->(IndexKey())
	Local cSelect	:= "E1_FILIAL,E1_PREFIXO,E1_NUM,E1_PARCELA,E1_IRRF,E1_MOEDA,E1_TIPO,E1_SALDO,E1_EMISSAO,E1_CLIENTE,E1_LOJA,E1_NOMCLI,E1_SDACRES,E1_SDDECRE,E1_HIST,E1_PIS,E1_COFINS,E1_CSLL,E1_TXMOEDA,E1_VLCRUZ,E1_BASEPIS,E1_BASECOF,E1_BASECSL,E1_VALOR,E1_FILORIG"

	//Incluo na chave do select os campos do usuario que possam estar na chave de indice.
	//Exemplo: Cliente possui uma chave de indice E1_FILIAL,E1_MSFIL,E1_NUM,E1_PARCELA
	//				Como o E1_MSFIL nao esta na expressao do SELECT padrao ele adiciona o campo
	//				evitando error.log
	aCamposKey := STRTOKARR(cUserKey,"+")
#ENDIF

aPcc[1]	:= .F.

If ValType(nPis) <> "N"
	nPis	:= 0
EndIf

If ValType(nCofins) <> "N"
	nCofins	:= 0
EndIf

If ValType(nCsll) <> "N"
	nCsll	:= 0
EndIf

If ValType(nIrrf) <> "N"
	nIrrf	:= 0
EndIf
	
If lGestao
	If !Empty(cFilFwSE1)
		lSE1Exclusivo := .T.
    EndIf
Else
	If !Empty(xFilial("SE1"))
		lSE1Exclusivo := .T.
	EndIf
EndIf

aPcc[1]	:= .F.
If dDataBase >= dLastPcc
	nVlMinImp	:= 0
EndIf

If MV_PAR08==1 .OR. lRaRtImp
	nTotAbat := If(Type("nTotAbat") != "N",SumAbatRec( SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_MOEDA, "S"  ,dBaixa,,@nTotIrAbt,@nTotCsAbt,@nTotPisAbt,@nTotCofAbt,),nTotAbat)
Else
	nTotAbat :=If(Type("nTotAbat") != "N",0,nTotAbat)
Endif
nValComp := If(Type("nValComp") != "N",0,nValComp)

For nX := 1 to Len(aCamposKey)
	If AT("STR(",UPPER(aCamposKey[nX])) > 0
		aCamposKey[nX] := Substr(aCamposKey[nX], AT("(",aCamposKey[nX])+1, AT(",",aCamposKey[nX])-AT("(",aCamposKey[nX])-1)
	ElseIf AT("(",aCamposKey[nX]) > 0 .Or. AT(")",aCamposKey[nX]) > 0 //Removo da String potenciais chamadas de funcao
		aCamposKey[nX] := Substr(aCamposKey[nX], AT("(",aCamposKey[nX])+1, AT(")",aCamposKey[nX])-AT("(",aCamposKey[nX])-1)
	EndIf
	If !(aCamposKey[nX] $ cSelect)
		cSelect += ","+aCamposKey[nX]
	Endif
Next

dBaixa := If (Type("dBaixa") != "D",dDataBase,dBaixa)

//Verificar ou nao o limite de 5000 para Pis cofins Csll
// 1 = Verifica o valor minimo de retencao
// 2 = Nao verifica o valor minimo de retencao
If SE1->E1_APLVLMN == "2"
	lAplVlMin := .F.
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de Entrada permite alterar o indice que sera aplicado no Markbrowse ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("FA330ORD")
	dbSetOrder(ExecBlock("FA330ORD",.F.,.F.))
Endif
cOrdemSE1 := SE1->(IndexKey())
SE1->(dbSetOrder(1))

If cOrigem == "COMPENSANCC"
	mv_par10 := 2
EndIf
If mv_par10 == 2
	cFilDe := cFilAnt
	cFilAte:= cFilAnt
Else
	cFilDe := mv_par11
	cFilAte:= mv_par12
Endif


#IFDEF TOP
	If TcSrvType() <> "AS/400"

		dbSelectArea("SX3")
		dbSetOrder(2)

		MsSeek("E1_SALDO")
		aadd(aStruQry,{"E1_SALDO",SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})

		MsSeek("E1_EMISSAO")
		aadd(aStruQry,{"E1_EMISSAO",SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})

		MsSeek("E1_MOEDA")
		aadd(aStruQry,{"E1_MOEDA",SX3->X3_TIPO,SX3->X3_TAMANHO,SX3->X3_DECIMAL})

		dbSelectArea("SE1")
		dbSetOrder(2)

		lQuery    := .T.
		cAliasSE1 := "QRYSE1"
		cAliasSA1 := "QRYSE1"

		cQuery := "SELECT DISTINCT "+cSelect+","
		cQuery += "SE1.R_E_C_N_O_ RECSE1, A1_CGC FROM "
		cQuery += RetSqlName("SE1") + " SE1 LEFT JOIN "
		cQuery += RetSqlName("SA1") + " SA1 ON (SE1.E1_LOJA = SA1.A1_LOJA) AND (SE1.E1_CLIENTE = SA1.A1_COD) "

		If lTitRAMex //Manejo de Anticipo - Mexico
			cQuery += " LEFT JOIN " + RetSqlName("SED") + " SED ON SE1.E1_NATUREZ = SED.ED_CODIGO "
		EndIf

		cQuery += " WHERE "
		If dDatabase >= dLastPcc .and. lRaRtImp .And. lRatFields .and. !(SE1->E1_TIPO $ MV_CRNEG) .and. lPccBxCr
			cQuery += "EXISTS "
			cQuery += "(select ED_CODIGO, ED_DESCRIC ,ED_CALCCSL , ED_CALCCOF, "
			cQuery += " ED_CALCPIS, ED_PERCCSL, ED_PERCCOF, ED_PERCPIS FROM "+RetSqlName("SED")+ " "
			cQuery += " WHERE ED_CALCCSL = 'S' AND ED_PERCCSL > 0 AND ED_CALCCOF = 'S' AND ED_PERCCOF > 0 "
			cQuery += " AND ED_CALCPIS = 'S' AND ED_PERCPIS > 0 AND D_E_L_E_T_ = ' ' ) AND "
		EndIf
		/* GESTAO - inicio */
		If !Empty(aSelFil)
			cQuery += "SE1.E1_FILIAL " + GetRngFil( aSelFil, "SE1", .T., @cTmpSE1Fil) + " AND "
			Aadd(aTmpSE1Fil,cTmpSE1Fil)
		Else
			cQuery += "SE1.E1_FILIAL = '"+ xFilial("SE1")+"' AND "
		Endif
		/* GESTAO - fim */

		If mv_par02 == 1
			cQuery += "SE1.E1_CLIENTE = '"+cCliente+"' AND "
		Else
			cQuery += "SE1.E1_CLIENTE >= '"+mv_par03+"' AND "
			cQuery += "SE1.E1_CLIENTE <= '"+mv_par04+"' AND "
		Endif
		If mv_par01 == 1 .And. mv_par02 == 1
			cQuery += "SE1.E1_LOJA = '"+cLoja+"' AND "
		Endif

		If lRaRtImp .And. lRatFields .and. !(SE1->E1_TIPO $ MV_CRNEG)
			If !lCredito
				cQuery +="( ( "
			Endif
			If dDatabase < dLastPcc
			If lPccBxCr
				If SE1->E1_PIS>0
					cQuery += " E1_PIS > 0 AND "
				Else
					cQuery += " E1_PIS = 0 AND "
				Endif
				If SE1->E1_COFINS>0
					cQuery += " E1_COFINS > 0 AND "
				Else
					cQuery += " E1_COFINS = 0 AND "
				Endif
				If SE1->E1_CSLL>0
					cQuery += " E1_CSLL > 0 AND "
				Else
					cQuery += " E1_CSLL = 0 AND "
				Endif

			Endif
			EndIf
			If lIrPjBxCr
				If SE1->E1_IRRF>0
					cQuery += " E1_IRRF > 0 AND "
				Else
					cQuery +=" E1_IRRF = 0 AND "
				Endif
			Endif
			If !lCredito .And. cPaisLoc == "BRA"
				If SE1->E1_ISS>0
					cQuery += " E1_PRISS > 0 AND "
				Else
					cQuery += " E1_PRISS = 0 AND "
				Endif
				If SE1->E1_INSS>0
					cQuery += " E1_PRINSS > 0 AND "
				Else
					cQuery += " E1_PRINSS = 0 AND "
				Endif
			ElseIf cPaisLoc == "BRA"
				If SE1->E1_PRISS>0
					cQuery += " E1_ISS > 0 AND "
				Else
					cQuery += " E1_ISS = 0 AND "
				Endif
				If SE1->E1_PRINSS>0
					cQuery += " E1_INSS > 0 AND "
				Else
					cQuery += " E1_INSS = 0 AND "
				Endif
			Endif
			If !lCredito
				cQuery +=  " E1_TIPO IN "+ FormatIn(MVRECANT,",") + ") OR "
				cQuery +=  " E1_TIPO IN "+ FormatIn(MV_CRNEG,",") + ") AND "
			Endif

		Endif
		If mv_par05 == 2
			cQuery += "(SE1.E1_SITUACA IN "+FormatIN(cLstCart,"|")+" OR "
		Else	
			//PCREQ-3782 - Bloqueio por situação de cobrança
			cQuery += "(SE1.E1_SITUACA IN "+FormatIn(cLstNoBlq,'|')+" OR "
		Endif
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Caso titulos originados pelo SIGALOJA estejam nas carteiras :  ³
		//³I = Carteira Caixa Loja                                        ³
		//³J = Carteira Caixa Geral                                       ³
		//³Nao permitir a selecao destes titulos                          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		cQuery += "SE1.E1_SITUACA NOT IN ('I','J')) AND "

		If cPaisLoc <> "BRA"
			If lCredito
				cQuery += "SE1.E1_TIPO NOT IN " + FormatIn( MV_CRNEG+cSep+MVRECANT,cSep) + " AND "
			Else
				cQuery += "SE1.E1_TIPO IN " + FormatIn( MV_CRNEG+cSep+MVRECANT,cSep) + " AND "
			Endif
		Else
			If lCredito
				cQuery += "SE1.E1_TIPO NOT IN " + FormatIn( MV_CRNEG+cSep+MVRECANT+cSep+MVPROVIS,cSep) + " AND "
			Else
				If (cTipoTit $ MVRECANT .And. cTipoTit $ MV_CRNEG )
					cQuery += " (SE1.E1_TIPO NOT IN " + FormatIn(MVRECANT,",") + " OR  "
					cQuery += "SE1.E1_TIPO NOT IN " + FormatIn( MV_CRNEG,cSep) + ") AND "
				ElseIf !(cTipoTit $ MVRECANT) .And. !(cTipoTit $ MV_CRNEG )
					cQuery += " ( SE1.E1_TIPO IN " + FormatIn(MVRECANT,",") + " OR  "
					cQuery += "SE1.E1_TIPO IN " + FormatIn( MV_CRNEG,cSep) + ") AND "
				Endif
			Endif
		Endif

		cQuery += "SE1.E1_TIPO NOT IN " + FormatIn(MVABATIM,"|") + " AND "
		cQuery += "SE1.E1_SALDO > 0 AND "
		cQuery += "SE1.E1_EMISSAO <= '"+DtoS(dDatabase)+ "' AND "
		cQuery += "SE1.D_E_L_E_T_ = ' ' AND "

		/* GESTAO - inicio */
		If !Empty(aSelFil)
			cQuery += "SA1.A1_FILIAL " + GetRngFil( aSelFil, "SA1", .T., @cTmpSE1Fil) + " AND "
			Aadd(aTmpSE1Fil,cTmpSE1Fil)
		Else
			cQuery += "SA1.A1_FILIAL = '"+ xFilial("SA1")+"' AND "
		Endif
		/* GESTAO - fim */

		cQuery += "SA1.D_E_L_E_T_ = ' ' "

		If lTitRAMex //Manejo de Anticipo - Mexico. Tratamento para nao exibir titulo de RA provenientes de notas de adiantamento.

			/* GESTAO - inicio */
			If !Empty(aSelFil)
				cQuery += " AND SED.ED_FILIAL " + GetRngFil( aSelFil, "SED", .T., @cTmpSE1Fil)
				Aadd(aTmpSE1Fil,cTmpSE1Fil)
			Else
				cQuery += "	AND SED.ED_FILIAL = '" + XFilial("SED") + "'"
			Endif
			/* GESTAO - fim */
			cQuery += " AND SED.D_E_L_E_T_	= '' "
			cQuery += "	AND SE1.E1_TIPO		<> '" + Substr(MVRECANT,1,3) + "'" //"RA" no Mexico
			cQuery += "	AND SE1.E1_ORIGEM	<> 'FINA087A' AND "
			cQuery += " SE1.D_E_L_E_T_ = ' ' "
			cQuery += "	AND SED.ED_OPERADT	<> '1' AND " //Operacao de adiantamento igual a SIM
			cQuery += " SE1.E1_SALDO > 0 AND "
			cQuery += " SE1.D_E_L_E_T_ = ' ' AND "
			If mv_par02 == 2
		   		cQuery += "SE1.E1_CLIENTE = '"+cCliente+"'"
	   		Else
		   		cQuery += "SE1.E1_CLIENTE >= '"+mv_par03+"' AND "
		   		cQuery += "SE1.E1_CLIENTE <= '"+mv_par04+"'"
	   		Endif
	   	EndIf
	   	
		cQuery += "ORDER BY " + SqlOrder(cOrdemSE1)

		If lFa330Qry
			cQuery := Execblock("FA330QRY",.f.,.f.,{ cQuery }  )			// permite manipualção das query
		Endif

		cQuery := ChangeQuery(cQuery)
 		dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasSE1,.f.,.t.)

		For nX := 1 To Len(aStruQry)
			If ( aStruQry[nX][2] <> "C" )
				TcSetField(cAliasSE1,aStruQry[nX][1],aStruQry[nX][2],aStruQry[nX][3],aStruQry[nX][4])
			EndIf
		Next nX


		bWhile := {|| (cAliasSE1)->(!Eof()) }

		ProcRegua((cAliasSE1)->(Reccount()),STR0032 )

	Else

#ENDIF

			dbSelectArea(cAliasSE1)
			dbSetOrder(2)
			cFilAnt := IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL )

			dbSeek( xFilial()+If(MV_PAR02==1,cCliente,"")+If(MV_PAR01==1 .and. MV_PAR02 == 1,cLoja,""), .T.)

			bWhile := { || !Eof() .and. (cAliasSE1)->E1_FILIAL == xFilial() .And.;
							If(MV_PAR02==1,(cAliasSE1)->E1_CLIENTE == cCliente,(cAliasSE1)->E1_CLIENTE <= mv_par04)  .and. ;
							If(MV_PAR01==1 .AND. MV_PAR02 == 1 ,(cAliasSE1)->E1_LOJA == cLoja,.T.) }

			ProcRegua(SE1->(Reccount())/IIf(mv_par02==2,1,SA1->(Reccount()) ),STR0032 )


#IFDEF TOP
	Endif
#ENDIF

/* GESTAO - inicio */
If !lQuery
	dbSelectArea("SM0")
	dbSeek(cEmpAnt+cFilDe,.T.)
Endif
/* GESTAO - fim */

aTitulos := {}
aRecNo := {}

While lQuery .Or. (!Eof() .and. M0_CODIGO == cEmpAnt .and. IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL ) <= cFilAte)

	dbSelectArea(cAliasSE1)
	If !lQuery
		dbSetOrder(2)
	Endif
	cFilAnt := IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL )
	If !lQuery
		dbSeek( xFilial()+If(MV_PAR02==1,cCliente,"")+If(MV_PAR01==1 .and. MV_PAR02 == 1,cLoja,""), .T.)
   Endif

	nIndVld:=IndexOrd()
	nRecVld:=SE1->(Recno())

	While Eval(bWhile)

	   	IncProc()

		If lQuery
		   //acertar cFilAnt de acordo com (cAliasSE1)->(E1_FILIAL) pois esta variavel tem que estar correta
		   // quando chamar a funcao SumAbatRec

		   /* GESTAO - inicio */
			If !Empty((cAliasSE1)->E1_FILORIG)
				cFilAnt := (cAliasSE1)->E1_FILORIG
			Else
				cFilAnt := (cAliasSE1)->E1_FILIAL
			EndIf
		   /* GESTAO - fim */
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ PONTO DE ENTRADA F330RIO                                      ³
		//³ Tratamento de "filtragem" de titulos de adiantamento a serem  ³
		//³ considerados ou nÆo no array dos adiantamentos a serem compen-³
		//³ sados. Retorno l¢gico.                                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		IF lF330RIO
			If !(ExecBlock("F330RIO",.F.,.F.))
				dbSkip()
				Loop
			Endif
		Endif

		//**********************************************************//
		//* Posiciona o TÍTULO para uso na sumabatrec()  *//
		//**********************************************************//
		dbselectArea("SE1")


		If lQuery
			SE1->(dbSetOrder(1))//E1_FILIAL+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO
			SE1->(dbSeek((cAliasSE1)->(E1_FILIAL) + (cAliasSE1)->(E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO)))
		EndIf
		dbselectArea(cAliasSE1)

		If !lQuery

			If MV_PAR02	== 2 .and. (SE1->E1_CLIENTE < mv_par03 .or. SE1->E1_CLIENTE > mv_par04)
				dbSkip()
				Loop
			EndIf

			If E1_TIPO $ MVABATIM .or. ;
				If(mv_par05 == 2 , !(E1_SITUACA $ cLstCart), !(E1_SITUACA $ cLstNoBlq)) ;
				.or. E1_SALDO == 0 ;
				.or. E1_EMISSAO > dDataBase
				dbSkip()
				Loop
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Caso titulos originados pelo SIGALOJA estejam nas carteiras :  ³
			//³I = Carteira Caixa Loja                                        ³
			//³J = Carteira Caixa Geral                                       ³
			//³Nao permitir a selecao destes titulos                          ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If Upper(AllTrim(SE1->E1_ORIGEM)) $ "LOJA010|LOJA701|FATA701" .AND. Upper(AllTrim(SE1->E1_SITUACA)) $ "I|J"
				(cAliasSE1)->(dbSkip())
				Loop
			Endif
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Vindo do Mata465 vai filtrar so os Tipos compensaveis             ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		If !lQuery

			If cPaisLoc <> "BRA"
				If lCredito
					If E1_TIPO$MV_CRNEG+"/"+MVRECANT
						dbSkip()
						Loop
					EndIf
				Else
					If !(E1_TIPO$MV_CRNEG+"/"+MVRECANT)
						dbSkip()
						Loop
					EndIf
				Endif
			Else
				If lCredito
					If E1_TIPO$MV_CRNEG+"/"+MVRECANT+"/"+MVPROVIS
						dbSkip()
						Loop
					EndIf
				Else
					If ( 	cTipoTit $ MVRECANT .And. E1_TIPO $ MVRECANT .And. ;
						cTipoTit $ MV_CRNEG .And. E1_TIPO $ MV_CRNEG .Or.  ;
						!cTipoTit $ MVRECANT .And. !E1_TIPO $ MVRECANT .And. ;
						!cTipoTit $ MV_CRNEG .And. !E1_TIPO $ MV_CRNEG )
						dbSkip()
						Loop
					Endif
				Endif
			Endif

		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Na finalizacao do Lay-Away, seleciona somente os titulos gerados  ³
		//³ pela emissao do mesmo - Loc. EUA|POR                              ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If cOrigem == "LOJA800"
		   nPosNumLay  := Ascan(aNumLay,AllTrim((cAliasSE1)->E1_NUM))
		   If nPosNumLay == 0 .And. Len(aNumLay) > 0
		       dbSkip()
			   Loop
		   EndIf
		EndIf

		//ANGOLA|BRASIL - Nao permitir compensar titulos de adiantamento relacionado a pedido
		#IFDEF TOP
			If cPaisLoc $ "ANG|BRA"
				FIE->(dbSetOrder(2))
				If FIE->(MsSeek(xFilial("FIE")+"R"+(cAliasSE1)->(E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO)))
					(cAliasSE1)->(dbSkip())
					Loop
				Endif
			Endif
		#ENDIF

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Mexico - Manejo de Anticipo              ³
		//³ Tratamento para nao exibir titulo de RA  ³
		//³ provenientes de notas de adiantamento    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !lQuery .And. lTitRAMex
			If Upper(Alltrim(SE1->E1_Origem)) $ "FINA087A" .And.;
				SE1->E1_TIPO == Substr(MVRECANT,1,3) .And.;
				GetAdvFVal("SED","ED_OPERADT",xFilial("SED")+SE1->E1_NATUREZ,1,"") == "1"
				(cAliasSE1)->(dbSkip())
				Loop
			EndIf
		EndIf

		//Situacao de cobranca que impede movimentacao
		If lCredito
			If !(F023VerBlq("1","0007",SE1->E1_SITUACA,.F.))
				(cAliasSE1)->(dbSkip())
				Loop
			EndIf
		EndIf
		
		nDesFin := 0
		// Desconto FINANCEIRO - Compensação
		If lCredito .And. lF330DESC
			lDESC := ExecBlock("F330DESC",.F.,.F.)
			If lDESC
				nDesFin:= IIf(SE1->E1_DESCFIN > 0 .And. SE1->E1_VENCREA-dBaixa >= SE1->E1_DIADESC .and. SE1->E1_DESCONT == 0,SE1->E1_VALOR * (SE1->E1_DESCFIN/100),0)
				nDescD := nDesFin
			EndIf	
		EndIf

		nVlBasico := IIf (nValor = 0 , nSaldo , nValor)
		nValRec		:= IIf (nValor = 0 , nSaldo , nValor)
		nOldValRec	:= nSaldo
		lMarca	:=	.F.

	   If ( nVlBasico > nTotComp .or. nTotComp == 0 )  .And. Fa330Lock(, If(lQuery,( cAliasSE1)->RECSE1,(cAliasSE1)->(RecNo())),.F.) .and. !((cAliasSE1)->E1_TIPO $ MV_CRNEG)
			lMarca := .T.		// marca para vers„o WIN
			nValPre := IIF (nTotComp == 0 , nVlBasico, nVlBasico - nTotComp)
			If cPaisLoc == "BRA"

				If (mv_par08 == 1 .OR. (lRaRtImp .and. !lNcc))  .and.   !((cAliasSE1)->E1_TIPO $ MVRECANT+"/"+MV_CRNEG )
					nTotCsAbt	:= 0
					nTotPisAbt	:= 0
					nTotCofAbt	:= 0
					nTotIrAbt	:= 0
					nTotAbat := SumAbatRec((cAliasSE1)->E1_PREFIXO,(cAliasSE1)->E1_NUM,(cAliasSE1)->E1_PARCELA,(cAliasSE1)->E1_MOEDA,"S",dBaixa,,@nTotIrAbt,@nTotCsAbt,@nTotPisAbt,@nTotCofAbt)

                 If lIrPjBxCr
                    	If lCredito .and. (cAliasSE1)->E1_IRRF>0  .and. !lNcc
							nIrrf:= FCaIrBxCR(SE1->E1_SALDO)
			  				If (nPosIr:=ascan(aImpIR,{|x| x[2]=SE1->(REcno())}))=0
				  		 		aAdd(aImpIR,{nIrrf,SE1->(Recno())})
				  		 		nPosIr := Len( aImpIR )
			   				else
				  				aImpIR[nPosIr][1]:= nIrrf
			   				EndIf
			   				//nTotIrAbt+=nIrrf
							//nTotAbat+=nIrrf 
                     EndIf
					EndIf
					
	
					//Se PCC Baixa CR e nao houver abatimento de impostos
					If cPaisLoc == "BRA" .and. ((lPccBxCR .And. !lRartimp) .and. (nTotCsAbt+nTotPisAbt+nTotCofAbt == 0)) .or. ;
						(lRartimp .and. (cAliasSE1)->(E1_PIS + E1_CSLL + E1_COFINS) == 0)

						//Se PCC Baixa CR e a compensação partiu de um adiantamento
						//Os titulos nao serao pre-selecionados.
						//Isto se da para que a cada titulo marcado, seja realizado o cálculo do PCC
						lMarca := .F. //
					Endif
				Else
				   If lIrPjBxCr .AND. !((cAliasSE1)->E1_TIPO $ MVRECANT+"/"+MV_CRNEG )
                    	If lCredito .AND. (cAliasSE1)->E1_IRRF > 0
							nIrrf:=FCaIrBxCR(SE1->E1_SALDO)
							If (nPosIr:=ascan(aImpIR,{|x| x[2]=SE1->(REcno())}))=0
					  			aAdd(aImpIR,{nIrrf,SE1->(Recno())})
					  			nPosIr := Len( aImpIR )
				   			else
					  			aImpIR[nPosIr][1]:= nIrrf
			   				EndIf
						EndIf
	     			Else
	     		   		nTotAbat := 0
					EndIf
				Endif
				//Se PCC Baixa CR e nao houver abatimento de impostos
				If cPaisLoc == "BRA" .and. lPccBxCR .and. (nTotCsAbt+nTotPisAbt+nTotCofAbt == 0) .And. !lRartimp .and. lCredito
				//Se PCC Baixa CR e a compensação partiu de um adiantamento
				//Os titulos nao serao pre-selecionados.
				//Isto se da para que a cada titulo marcado, seja realizado o cálculo do PCC
					lMarca := .F.

				Endif
				
				If dDataBase < dLastPcc
					If nPis <> E1_PIS .and. nCofins <> E1_COFINS .and. nCsll <> E1_CSLL .and. nIrrf <> E1_IRRF  // Garantir a integridade do valor dos impostos 
						nPis    := aImpPccIr[1]
						nCofins := aImpPccIr[2]
						nCsll   := aImpPccIr[3]
						nIrrf   := aImpPccIr[4]
					Endif
				EndIf
				
				If lMarca
					nValComp := Iif (nValpre > Round(NoRound(xMoeda((cAliasSE1)->E1_SALDO - nTotAbat +(cAliasSE1)->E1_SDACRES-(cAliasSE1)->E1_SDDECRE,(cAliasSE1)->E1_MOEDA,nMoeda,,3,Fa330Tx2((cAliasSE1)->E1_MOEDA,(cAliasSE1)->E1_TXMOEDA),Fa330Tx2(nMoeda,nTxMoeda)),3),2) , ;
										xMoeda((cAliasSE1)->E1_SALDO - nTotAbat+(cAliasSE1)->E1_SDACRES-(cAliasSE1)->E1_SDDECRE,(cAliasSE1)->E1_MOEDA,nMoeda,,5,Fa330Tx2((cAliasSE1)->E1_MOEDA,(cAliasSE1)->E1_TXMOEDA),Fa330Tx2(nMoeda,nTxMoeda)),;
										nVlBasico-nTotComp)
				Else
					nValComp := 0
				Endif
			Else
	 	       nValComp := Iif (nValPre > xMoeda((cAliasSE1)->E1_SALDO+(cAliasSE1)->E1_SDACRES-(cAliasSE1)->E1_SDDECRE,(cAliasSE1)->E1_MOEDA,nMoeda,dDatabase,,aTxMoedas[E1_MOEDA][2],aTxMoedas[nMoeda][2]),;
			                Round(xMoeda((cAliasSE1)->E1_SALDO+(cAliasSE1)->E1_SDACRES-(cAliasSE1)->E1_SDDECRE,(cAliasSE1)->E1_MOEDA,nMoeda,dDatabase,nDecs+1,aTxMoedas[E1_MOEDA][2],aTxMoedas[nMoeda][2]),nDecs),;
						    nVlBasico-nTotComp)
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ PONTO DE ENTRADA F330CMP                                      ³
			//³ Tratamento de valor a ser compensado em determinado titulo 	³
			//³ permitindo que o usuario possa calcular o valor do titulo NDF ³
			//³ ou PA a ser compensado.                                       ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			IF ExistBlock("F330CMP")
				nValComp:= ExecBlock("F330CMP",.F.,.F.)
			Endif
			nTotComp += nValComp
		Else
			If cPaisLoc == "BRA"
				If (mv_par08 == 1 .OR. lRaRtImp)  .and.   !((cAliasSE1)->E1_TIPO $ MVRECANT+"/"+MV_CRNEG )
					nTotCsAbt	:= 0
					nTotPisAbt	:= 0
					nTotCofAbt	:= 0
					nTotIrAbt   := 0
					nTotAbat := SumAbatRec((cAliasSE1)->E1_PREFIXO,(cAliasSE1)->E1_NUM,(cAliasSE1)->E1_PARCELA,(cAliasSE1)->E1_MOEDA,"S",dBaixa,,@nTotIrAbt,@nTotCsAbt,@nTotPisAbt,@nTotCofAbt)
					If lNcc .and. lRaRtImp .and. ((cAliasSE1)->E1_VALOR > (cAliasSE1)->E1_SALDO)
						aOldBaixaSE5 := aClone(aBaixaSE5)
						aBaixaSE5:= {}
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Soma a proporcionalização de iss e inss ao nValrec ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						aBxSE5 := Sel070Baixa( "VL /V2 /BA /RA /CP /LJ /"+MV_CRNEG,(cAliasSE1)->E1_PREFIXO,(cAliasSE1)->E1_NUM,(cAliasSE1)->E1_PARCELA,;
					   							(cAliasSE1)->E1_TIPO,@nTotAdto,@lBaixaAbat,(cAliasSE1)->E1_CLIENTE,;
												(cAliasSE1)->E1_LOJA,@nVlrBaixa,,@lBxCEC,@lBxLiq,,.T.)
						For x := 1 To Len(aBaixaSE5)
					 		nTotAbat -= aBaixaSE5[x][32]+aBaixaSE5[x][33]
						Next
						aBaixaSE5 := aClone(aOldBaixaSE5)
					EndIf

				Else
					nTotAbat := 0
				Endif
			EndIf
			lMarca := .F.		// desmarca para vers„o WIN
			nValComp := 0
			nValPre := nVlBasico
		EndIf
		nValLim := 0
		If cPaisLoc == "BRA"

			// Moeda de Partida
			nMoedaP := (cAliasSE1)->E1_MOEDA
			nTaxaP	:= (cAliasSE1)->E1_TXMOEDA
			// Moeda de Destino
			nMoedaD := nMoeda		
			nTaxaD	:= nTxMoeda
			
			nVAlSld:= (cAliasSE1)->(E1_SALDO+E1_SDACRES-E1_SDDECRE) - nDesFin
			
			If nMoedaP <> nMoedaD
				nValSld  	:= Round(xMoeda(nValSld,nMoedaP,nMoedaD,dDatabase,nDecs+1,Fa330Tx2(nMoedaP,nTaxaP),Fa330Tx2(nMoedaD,nTaxaD)),nDecs)
			EndIf

			If (lPccBxCr .or. lIRPJBxCr).And. lRaRtImp .and. !lNcc

				If lCredito
					aAdd(aDadosRA1[2],(cAliasSE1)->RecSe1)
				Else
					aAdd(aDadosRA1[1],(cAliasSE1)->RecSe1)
				EndIf
				aAdd(aDadosRA1[9],lMarca)
				
				
				If dDatabase >= dLastPcc 
					If lRartImp .and. lCredito
						aPcc		:=	newMinPcc(dBaixa,SE1->E1_SALDO,SE1->E1_NATUREZ,"R",SE1->E1_CLIENTE+SE1->E1_LOJA)
					EndIf
				EndIf
				
				If u_F330RaRtIm(@aDadosRA1)
					nValLim 	:= If(aDadosRA1[7][len(aDadosRA1[7])]>nVlBasico,nVlBasico,aDadosRA1[7][len(aDadosRA1[7])])
					nTotComp	-= nValComp
					If !(nTotComp + If(aDadosRA1[8][len(aDadosRA1[8])]>nVlBasico,nVlBasico,aDadosRA1[8][len(aDadosRA1[8])]) > nVlBasico) 
					nValComp 	:= If(aDadosRA1[8][len(aDadosRA1[8])]>nVlBasico,nVlBasico,aDadosRA1[8][len(aDadosRA1[8])])
					EndIf
					nTotComp	+= nValComp
				EndIf
				
				If dDatabase >= dLastPcc .and. lRartImp .and. lCredito
					If aPcc[1]
						nPis		:= 	aPcc[2]
						nCofins		:=	aPcc[3]
						nCsll		:=  aPcc[4]
					EndIf
					aDadosRA1[3][len(aDadosRA1[7])]	:= nPis
					aDadosRA1[4][len(aDadosRA1[7])]	:= nCofins
					aDadosRA1[5][len(aDadosRA1[7])]	:= nCsll
					If lCredito .and. lRartImp //.and. mv_par08 == 2
						If aDadosRA1[7][len(aDadosRA1[7])]<nVlBasico 
							If nValLim + nPis + nCofins + nCsll <> SE1->E1_SALDO //somente deve descontar os impostos quando o valor estiver bruto
								nValLim		:= nValLim - nPis - nCofins - nCsll
								nValComp	:= nValLim
							EndIf
						EndIf
					EndIf
				EndIf
					
								
				If nMoedaP <> nMoedaD
					nValLim	:= Iif(nSaldo>nVAlSld,nVAlSld,nSaldo) 					    
					nTotComp	-= nValComp
					nValComp 	:= nValLim
					nTotComp	+= nValComp
				EndIf

			Else
				If (!lRaRtImp .and. mv_par08 == 1 .and. lPccBxCr .and. SE1->E1_TIPO <> MVRECANT)
					If dDataBase < dLastPcc
						f070TotMes( dBaixa , .T. )
					EndIf
				EndIf
				If dDataBase < dLastPcc
		  			If !lRaRtImp .and. lPccBxCr .and. (cAliasSE1)->E1_TIPO <> MVRECANT .and. nPis+nCofins+nCsll+nIrrf > 0 .AND. aDadosret[1] <= nVlMinImp 
		  				If nSldRa > SE1->E1_SALDO 
		  					nProp		:= (SE1->E1_SALDO) / SE1->E1_VALOR
		  				Else
		  					nProp		:= nSldRa/SE1->E1_VALOR
		  				EndIf
		  				If nProp <> 0
							nValPis		:= SE1->E1_PIS * nProp
							nValCofins	:= SE1->E1_COFINS * nProp
							nValCsll	:= SE1->E1_CSLL * nProp
							If (nSldRa >= SE1->E1_SALDO .and. aDadosRet[1]+SE1->E1_SALDO > nVlMinImp) .or. (nSldRa <= SE1->E1_SALDO .and. aDadosRet[1]+nSldRa > nVlMinImp)  
								nPis		:= aDadosRet[2] + nValPis 
								nCofins		:= aDadosRet[3] + nValCofins
								nCsll		:= aDadosRet[4] + nValCsll
							Else
								nPis		:= nValPis 
								nCofins		:= nValCofins
								nCsll		:= nValCsll
							EndIf
						EndIf 	
						nValLim 	:= Iif( nSaldo > (nVAlSld -nPis - nCofins - nCsll-nTotAbat) , (nVAlSld - nPis - nCofins - nCsll - nTotAbat) , Iif (aDadosRet[1]+nSaldo <= nVlMinImp, nSaldo, (nSaldo - nPis - nCofins - nCsll - nTotAbat)) )
					ElseIf !lRaRtImp .and. lPccBxCr .and. (cAliasSE1)->E1_TIPO <> MVRECANT .and. nPis+nCofins+nCsll+nIrrf > 0 .AND. aDadosret[1] > nVlMinImp .and. SE1->E1_SALDO <> SE1->E1_VALOR
						nValPis		:= nPis
						nValCofins	:= nCofins
						nValCsll	:= nCsll
						nPis		:= (nValPis * (SE1->E1_SALDO/ SE1->E1_VALOR))
						nCofins		:= (nValCofins * (SE1->E1_SALDO/ SE1->E1_VALOR))
						nCsll		:= (nValCsll * (SE1->E1_SALDO/ SE1->E1_VALOR))	
						nValLim 	:= Iif( nSaldo > (nVAlSld -nPis - nCofins - nCsll-nTotAbat) , (nVAlSld - nPis - nCofins - nCsll - nTotAbat) , (nSaldo - nPis - nCofins - nCsll - nTotAbat) )
						nAbatRa		:= nTotAbat
						nSldNF		:= SE1->E1_SALDO
					ElseIf !lRaRtImp .or. (lRaRtImp .and. (cAliasSE1)->(E1_PIS + E1_CSLL + E1_COFINS) == 0)
						If nValComp > 0 .and. (nSaldo <> nValComp)
							nPis	:= aDadosRet[2] + ((nValComp * nValPis)/nValorNf) 
							nCofins	:= aDadosRet[3] + ((nValComp * nValCofins)/nValorNf)
							nCsll	:= aDadosRet[4] + ((nValComp * nValCsll)/nValorNf)
		  					nValLim := Iif(!lRartImp,Max(nVAlSld , nValComp),Iif( nValComp > nVAlSld , nVAlSld , nValComp ))
		  				Else
		  					If nValPis > 0 .AND. aDadosret[1] <= nVlMinImp .and. aDadosRet[1]+nValComp <= nVlMinImp
		  						nPis	:= nValPis
		  						nCofins	:= nValCofins
		  						nCsll	:= nValCsll
		  					EndIf
		  					If lCredito
		  						nAbatNf	:= nTotAbat
		  					EndIf
		  					nValLim := Iif( nSaldo > nVAlSld , nVAlSld , nSaldo )
		  				EndIf
		  			EndIf
		  		Else
	  				If lCredito .and. mv_par08 == 2 .and. !lRartImp .and. nValSld+nPis+nCofins+nCsll <= SE1->E1_SALDO
	  					nValSld	+= nPis+nCofins+nCsll
	  				EndIf
	  				nValRec2 := Iif(nValRec < SE1->E1_SALDO,nValRec,SE1->E1_SALDO)
	  				If !(!lCredito .and. !lRartImp)
	  					aPcc		:= newMinPcc(dBaixa,nValRec2,SE1->E1_NATUREZ,"R",SE1->E1_CLIENTE+SE1->E1_LOJA)
		  				nPis		:=	aPcc[2]
						nCofins     :=	aPcc[3]
						nCsll		:= aPcc[4]
						nPisCalc	:= nPis
						nPisBaseC	:= nValRec2	
						nPisBaseR 	:= nValRec2
						nCofCalc	:= nCofins	
						nCofBaseC	:= nValRec2
						nCofBaseR 	:= nValRec2
						nCslCalc	:= nCsll	
						nCslBaseC	:= nValRec2
						nCslBaseR 	:= nValRec2
				
						If !lIrPjBxCr
							nIrrf	:= SE1->E1_IRRF
						EndIf
	  				EndIf
					//If lCredito .and. mv_par08 == 1 .and. !lRartImp // descontas após o calculo dos impostos, para que seja considerado o novo valor
	  					//nValSld	-= nPis+nCofins+nCsll+nIrrf
	  				//EndIf
				nValLim:= Iif(nSaldo>nVAlSld,nVAlSld,nSaldo)
		  		EndIf
	  			If SE1->E1_TIPO <> MVRECANT .And. nValLim > SE1->E1_SALDO-nTotAbat .And. MV_PAR08 == 1
				    // Só faz a subtração do nValLim se o mesmo não ficar negativo
					If nValLim - nTotAbat >= 0
						nValLim -= nTotAbat
						If ( SE1->E1_SALDO - nTotAbat - iif(lPccBxCr,nPis + nCofins + nCsll, 0 ) ) > nValLim
							nValLim := ( SE1->E1_SALDO - nTotAbat )
						EndIf
					// Se não subtrair o valor em nTotBat, verifica se o saldo atual do titulo esta inferior ao nValLim
					ElseIf ( SE1->E1_SALDO - nTotAbat ) < nValLim
						nValLim := ( SE1->E1_SALDO - nTotAbat )
					EndIf

					If !lRaRtImp
						If !aPcc[1]
						If ValType( aDadosRet ) == "A" 
							aDadRetAux := aClone( aDadosRet )
						EndIf

							f070TotMes( dBaixa , .T. )
						//Retorna os valores originais
						aDadosRet  := aClone( aDadRetAux )
	
								nPis       := aImpPccIr[1]
						nCofins    := aImpPccIr[2]
						nCsll      := aImpPccIr[3]
								nIrrf      := aImpPccIr[4]
								
	
						aDadRetAux := {}
					EndIf

				EndIf
			EndIf

			Endif  
            			
			If nSaldoProp == 0
			   nSaldoProp := nValComp
			Endif

		   	lAdiciona := .T.

			//Verifica se o titulo já possui impostos gerados pela rotina de Borderô de Recebimento de Imposto (FINA061).
			nPisFina061	:=	0
			nCofFina061	:=	0
			nCslFina061	:=	0
			nIrfFina061	:=	0
			nRegSE5		:=	SE5->(Recno())
			nOrdSE5		:=	SE5->(IndexOrd())		
			If lPccBxCr .Or. lIrPjBxCr                                                                                               			
				dbSelectArea("SE5")
				SE5->(dbSetOrder(2)) //FILIAL + TIPODOC + PREFIXO + NUMERO + PARCELA + TIPO
				If SE5->(DBSeek(xFilial("SE5")+"BA"+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO))
					While !SE5->(Eof()) .and. SE5->E5_FILIAL==xFilial("SE5") .And. ;
						SE5->E5_TIPODOC+SE5->E5_PREFIXO+SE5->E5_NUMERO+SE5->E5_PARCELA+SE5->E5_TIPO=="BA"+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO		
				
						If ("FINA061" $ Subst(SE5->E5_HISTOR,1,7)) .And. SE5->E5_MOTBX $ "PCC_IRF"						
							If Alltrim(SE5->E5_MOTBX) == "PCC"
							   nPisFina061	+= SE5->E5_VRETPIS
							   nCofFina061	+=	SE5->E5_VRETCOF
							   nCslFina061	+= SE5->E5_VRETCSL
							ElseIf Alltrim(SE5->E5_MOTBX) == "IRF"
							   nIrfFina061	+= SE5->E5_VRETIRF
							Endif
						Endif					
						SE5->(DbSkip())		
			   	Enddo
				Endif
			Endif
	   		SE5->(Dbgoto(nRegSE5))
			SE5->(Dbsetorder(nOrdSE5))													                  

			If (nPisFina061+nCofFina061+nCslFina061+nIrfFina061)> 0  
				//Caso o titulo possua bordero de recebimento de imposto gerado na rotina FINA061 devo recompor base no caso de não abater os impostos
				//ou  abater os impostos e tiver compensando de RA para NF. Senão devo zerar as variaveis para não afetar o processamento.
				//If ( mv_par08 == 1 .And. (SE1->E1_TIPO = MVRECANT .Or. SE1->E1_TIPO = MV_CRNEG)) 
			  	If  mv_par08 == 1 
					nPisFina061	:=	0
					nCofFina061	:=	0
					nCslFina061	:=	0
					nIrfFina061	:=	0
				Endif		
			Endif					
			lNcc2 := (cAliasSE1)->E1_TIPO $ MV_CRNEG   
      		
      		If lRaRtImp .And. lPccBxCr .and. !lNcc .and. lCredito
               	nSaldoNF := (cAliasSE1)->E1_SALDO - aDadosRA1[3][Len(aDadosRA1[3])] - aDadosRA1[4][Len(aDadosRA1[4])] - aDadosRA1[5][Len(aDadosRA1[5])]
            Else
               	nSaldoNF := (cAliasSE1)->E1_SALDO 
            Endif
	        
			If MV_PAR02 == 2 // Considera Cliente == Não
			   DBSelectArea("SA1")
			   nIndexSA1 := IndexOrd()
			   nPosSA1   := Recno()
				DBSetOrder(1)
			   DBSeek(xFilial()+(cAliasSE1)->E1_CLIENTE+(cAliasSE1)->E1_LOJA)
				dbSelectArea(cAliasSE1)
				If lF330DESC
					lDESC := ExecBlock("F330DESC",.F.,.F.)
					If lDESC
						nDesFin:= IIf(SE1->E1_DESCFIN > 0 .And. SE1->E1_VENCREA-dBaixa >= SE1->E1_DIADESC .and. SE1->E1_DESCONT == 0,SE1->E1_VALOR * (SE1->E1_DESCFIN/100),0)
					EndIf
				EndIf
				
				If lAdiciona
				    AADD(aTitulos,{;
						(cAliasSE1)->E1_PREFIXO,;
						(cAliasSE1)->E1_NUM,;
						(cAliasSE1)->E1_PARCELA,;
						(cAliasSE1)->E1_TIPO,;
						(cAliasSE1)->E1_LOJA,;
						Transform(xMoeda((nSaldoNF+ nPisFina061+nCofFina061+nCslFina061+nIrfFina06)+(cAliasSE1)->E1_SDACRES-Iif(nProp>0,(nImp*nProp),0)-(cAliasSE1)->E1_SDDECRE- Iif(  Type("nTotAbat") <> "N" .OR. MV_PAR08== 2 ,0,nTotAbat) - nDesFin,(cAliasSE1)->E1_MOEDA,nMoeda,,5,Fa330Tx2(nMoedaP,nTaxaP),Fa330Tx2(nMoedaD,nTaxaD)),"@E 9999,999,999.99"),; //06
						Transform(nValComp + nPisFina061+nCofFina061+nCslFina061+nIrfFina061, "@E 9999,999,999.99"),; //07
						lMarca,;
						nValComp + nPisFina061+nCofFina061+nCslFina061+nIrfFina061,; //09
						(cAliasSE1)->(E1_CLIENTE)+"-"+(cAliasSE1)->(E1_LOJA),;
						(cAliasSE1)->E1_NOMCLI,;
						Transform(SA1->A1_CGC,Substr(PicPes(SA1->A1_PESSOA),1,at("%",PicPes(SA1->A1_PESSOA))-1)),;
						Transform(xMoeda((cAliasSE1)->E1_SDACRES,(cAliasSE1)->E1_MOEDA,nMoeda,,5,Fa330TxMd((cAliasSE1)->E1_MOEDA,(cAliasSE1)->E1_TXMOEDA),Fa330Tx2(nMoeda,nTxMoeda)),"@E 9999,999,999.99"),;
						Transform(xMoeda((cAliasSE1)->E1_SDDECRE,(cAliasSE1)->E1_MOEDA,nMoeda,,5,Fa330TxMd((cAliasSE1)->E1_MOEDA,(cAliasSE1)->E1_TXMOEDA),Fa330Tx2(nMoeda,nTxMoeda)),"@E 9999,999,999.99"),;
						(cAliasSE1)->E1_HIST,;
						(cAliasSE1)->E1_FILIAL,;
						Transform(nValorPcc,"@E 9999,999,999.99"),;
						Transform(nValorPcc,"@E 9999,999,999.99"),;
						Transform(nValorPcc,"@E 9999,999,999.99"),;
						Transform(nValorPcc,"@E 9999,999,999.99"),;
						Transform(nValorPcc,"@E 9999,999,999.99"),;
						Transform(nValorPcc,"@E 9999,999,999.99"),;
						If(lQuery,( cAliasSE1)->RECSE1,(cAliasSE1)->(RecNo())),;
						(cAliasSE1)->E1_SALDO + nPisFina061+nCofFina061+nCslFina061+nIrfFina061,; 
						Transform(nValLim,"@E 9999,999,999.99"),;
															(cAliasSE1)->E1_VALOR,; //26
															Transform(nValorPcc,"@E 9999,999,999.99"),;//27 base calculo PCC
															Transform(nValorPcc,"@E 9999,999,999.99"),;//28 Base Retenção PCC
															Transform(nValorPcc,"@E 9999,999,999.99")}) //29 Base de calculo e retenção do IRF

					nLin:=Len(aTitulos)
					nReg330 := 23 // Posição 23 do aTitulos
					If lRaRtImp .And. (lPccBxCr .or. lIRPJBxCr) .and. !lNcc
						If aDadosRet[1]> nVlMinImp
   						aTitulos[nLin][nPosPis]:= Transform(aDadosRA1[3][nLin]   ,X3Picture("E1_PIS"))
						aTitulos[nLin][nPosCof]:= Transform(aDadosRA1[4][nLin]   ,X3Picture("E1_COFINS"))
						aTitulos[nLin][nPosCsl]:= Transform(aDadosRA1[5][nLin]   ,X3Picture("E1_CSLL"))
						aTitulos[nLin][nPosIrf]:= Transform(aDadosRA1[6][nLin]   ,X3Picture("E1_IRRF"))
						EndIf
						aTitulos[nLin][nPosBPCC]:= Transform(aDadosRA1[7][nLin]   ,X3Picture("E1_VALOR"))
						aTitulos[nLin][nPosBPCR]:= Transform(aDadosRA1[8][nLin]   ,X3Picture("E1_VALOR"))
						
						If Type("oTitulo") == "O"
							oTitulo:aArray:=aTitulos
      						oTitulo:Refresh()
						Endif
					Endif

					SA1->(DBSetOrder(nIndexSA1))
					SA1->(DBGoto(nPosSA1))
				Endif
			Else	// MV_PAR02 <> 2 // Considera Cliente == Sim
			    If lAdiciona

				    aAdd(aTitulos,{(cAliasSE1)->E1_PREFIXO,;		//01
						(cAliasSE1)->E1_NUM,;						//02
						(cAliasSE1)->E1_PARCELA,;					//03
						(cAliasSE1)->E1_TIPO,;						//04
						(cAliasSE1)->E1_LOJA,;						//05
						Transform(xMoeda(nSaldoNF+(cAliasSE1)->E1_SDACRES-Iif(nProp>0,(nImp*nProp),0)-(cAliasSE1)->E1_SDDECRE- Iif(  Type("nTotAbat") <> "N" .OR. MV_PAR08== 2,0,nTotAbat) - nDesFin,(cAliasSE1)->E1_MOEDA,nMoeda,,5,Fa330Tx2(nMoedaP,nTaxaP),Fa330Tx2(nMoedaD,nTaxaD)),"@E 9999,999,999.99"),; //06
						Transform(nValComp,"@E 9999,999,999.99"),;//07
						lMarca,;										//08
						nValComp + nPisFina061+nCofFina061+nCslFina061+nIrfFina061,;										//09
						Transform(xMoeda((cAliasSE1)->E1_SDACRES,(cAliasSE1)->E1_MOEDA,nMoeda,,5,Fa330Tx2((cAliasSE1)->E1_MOEDA,(cAliasSE1)->E1_TXMOEDA),Fa330Tx2(nMoeda,nTxMoeda)),"@E 9999,999,999.99"),; //10
						Transform(xMoeda((cAliasSE1)->E1_SDDECRE,(cAliasSE1)->E1_MOEDA,nMoeda,,5,Fa330Tx2((cAliasSE1)->E1_MOEDA,(cAliasSE1)->E1_TXMOEDA),Fa330Tx2(nMoeda,nTxMoeda)),"@E 9999,999,999.99"),; //11
						(cAliasSE1)->E1_HIST,;						//12
						(cAliasSE1)->E1_FILIAL,;						//13
						Transform(nValorPcc,"@E 9999,999,999.99"),;//PCC Baixa CR - Pis 		//14	
						Transform(nValorPcc,"@E 9999,999,999.99"),;//PCC Baixa CR - Cofins 	//15
						Transform(nValorPcc,"@E 9999,999,999.99"),;//PCC Baixa CR - Csll		//16
						Transform(nValorPcc,"@E 9999,999,999.99"),;//PCC Baixa CR - Irrf		//17	
						Transform(nValorPcc,"@E 9999,999,999.99"),;								//18
						Transform(nValorPcc,"@E 9999,999,999.99"),;								//19
						If(lQuery,( cAliasSE1)->RECSE1,(cAliasSE1)->(RecNo())),;				//20
						(cAliasSE1)->E1_SALDO + nPisFina061+nCofFina061+nCslFina061+nIrfFina061,;														//21
						Transform(nValLim  + nPisFina061+nCofFina061+nCslFina061+nIrfFina061,"@E 9999,999,999.99"),;//Limite de Compensacao  //22
						(cAliasSE1)->E1_VALOR,;//23
						Transform(nValorPcc,"@E 9999,999,999.99"),;//24 base calculo PCC
						Transform(nValorPcc,"@E 9999,999,999.99"),;//25 Base Retenção PCC
						Transform(nValorPcc,"@E 9999,999,999.99")}) //26 Base de calculo e retenção do IRF

					nlin := Len(aTitulos)
					nReg330 := 20 // Posição 20 do aTitulos
					If lRaRtImp .And. (lPccBxCr .or. lIRPJBxCr) .and. !lNcc
						aTitulos[nLin][nPosPis]:= Transform(aDadosRA1[3][nLin]   ,X3Picture("E1_PIS"))
						aTitulos[nLin][nPosCof]:= Transform(aDadosRA1[4][nLin]   ,X3Picture("E1_COFINS"))
						aTitulos[nLin][nPosCsl]:= Transform(aDadosRA1[5][nLin]   ,X3Picture("E1_CSLL"))
						aTitulos[nLin][nPosIrf]:= Transform(aDadosRA1[6][nLin]   ,X3Picture("E1_IRRF"))
						aTitulos[nLin][6] := Transform(xMoeda(aDadosRA1[7][nLin],(cAliasSE1)->E1_MOEDA,nMoeda,,5,Fa330Tx2(nMoedaP,nTaxaP),Fa330Tx2(nMoedaD,nTaxaD)),"@E 9999,999,999.99")
					Endif
			    Endif
			Endif
			If ExistBlock("FI330ALT")
				aTitulos:=ExecBlock("FI330ALT",.F.,.F.,{aTitulos})
			EndIF
		Else	// cPaisLoc <> "BRA"
	      //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	      //³Se na listagem de titulos nao considerar o cliente original do titulo selecionado, mostra o cgc |
	      //|e o nome dos clientes refrentes a cada titulo (MV_PAR02==2)                                     |
	      //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		   If MV_PAR02 == 2
		       //Posiciona arquivo de clientes para buscar o CGC e Nome

			   DBSelectArea("SA1")
			   nIndexSA1 := IndexOrd()
			   nPosSA1   := Recno()
	           DBSetOrder(1)
			   DBSeek(xFilial()+(cAliasSE1)->E1_CLIENTE+(cAliasSE1)->E1_LOJA)
			   cCgcClie := SA1->A1_CGC
			   cNomClie := SA1->A1_NOME

     	   	   DBSetOrder(nIndexSA1)
     	   	   DBGoto(nPosSA1)

	     	   //---
	     	   DBSelectArea(cAliasSE1)
				If nValLim==0
					If (cAliasSE1)->E1_SALDO>=nSaldo
						nValLim:= nSaldo
						nValComp:= If(lMarca,nSaldo,nValComp)
					Else
						nValLim:= (cAliasSE1)->E1_SALDO
						nValComp:= If(lMarca,nValComp,(cAliasSE1)->E1_SALDO)
					Endif
				Endif

				aAdd(aTitulos,{(cAliasSE1)->E1_PREFIXO,;
									(cAliasSE1)->E1_NUM,;
									(cAliasSE1)->E1_PARCELA,;
									(cAliasSE1)->E1_TIPO,;
									(cAliasSE1)->E1_LOJA,;
									Transform(Round(xMoeda((cAliasSE1)->E1_SALDO+(cAliasSE1)->E1_SDACRES-(cAliasSE1)->E1_SDDECRE,(cAliasSE1)->E1_MOEDA,nMoeda,(cAliasSE1)->E1_EMISSAO,nDecs+1,aTxMoedas[(cAliasSE1)->E1_MOEDA][2],aTxMoedas[nMoeda][2]),nDecs),PesqPict("SE1","E1_SALDO")),;
									Transform(nValComp,PesqPict("SE1","E1_SALDO")),;
									lMarca,;
									(cAliasSE1)->E1_MOEDA,;
									(cAliasSE1)->E1_EMISSAO,;
									cNomClie,;
									Transform(cCgcClie,PesqPict("SA1","A1_CGC")),;
									Transform(xMoeda((cAliasSE1)->E1_SDACRES,(cAliasSE1)->E1_MOEDA,nMoeda,,5),"@E 9999,999,999.99"),;
							     	Transform(xMoeda((cAliasSE1)->E1_SDDECRE,(cAliasSE1)->E1_MOEDA,nMoeda,,5),"@E 9999,999,999.99"),;
	       	               			(cAliasSE1)->E1_HIST,;
							      	(cAliasSE1)->E1_FILIAL,;
									Transform(xMoeda(nValLim,nMoeda,nMoeda,,5,Fa330Tx2((cAliasSE1)->E1_MOEDA,(cAliasSE1)->E1_TXMOEDA),Fa330Tx2(nMoeda, nTxMoeda)),"@E 9999,999,999.99")})//Limite de Compensacao


	       	   //Reposiciona arquivo de clientes
	      	   //---
	       Else
	       
	       		// Moeda de Partida
				nMoedaP := (cAliasSE1)->E1_MOEDA
				// Moeda de Destino
				nMoedaD := nMoeda
				
   				If nValLim==0
					If (cAliasSE1)->E1_SALDO>=nSaldo
						nValLim:= nSaldo
						nValComp:= If(lMarca,nValComp,nSaldo)

					Else
						nValLim:= (cAliasSE1)->E1_SALDO
						nValComp:= If(lMarca,nValComp,(cAliasSE1)->E1_SALDO)

					Endif
				Endif

				nVAlSld := (cAliasSE1)->(E1_SALDO+E1_SDACRES-E1_SDDECRE) - nDesFin  
				
				aAdd(aTitulos,{(cAliasSE1)->E1_PREFIXO,;
	       	                  (cAliasSE1)->E1_NUM,;
	       	                  (cAliasSE1)->E1_PARCELA,;
	       	                  (cAliasSE1)->E1_TIPO,;
	       	                  (cAliasSE1)->E1_LOJA,;
	       	                  Transform(Round(xMoeda((cAliasSE1)->E1_SALDO,(cAliasSE1)->E1_MOEDA,nMoeda,(cAliasSE1)->E1_EMISSAO,nDecs+1,aTxMoedas[(cAliasSE1)->E1_MOEDA][2],aTxMoedas[nMoeda][2]),nDecs),PesqPict("SE1","E1_SALDO")),;
	       	                  Transform(nValComp,PesqPict("SE1","E1_SALDO")),;
	       	                  lMarca,;
	       	                  (cAliasSE1)->E1_MOEDA,;
	       	                  (cAliasSE1)->E1_EMISSAO,;
							  Transform(xMoeda((cAliasSE1)->E1_SDACRES,(cAliasSE1)->E1_MOEDA,nMoeda,,5),"@E 9999,999,999.99"),;
							  Transform(xMoeda((cAliasSE1)->E1_SDDECRE,(cAliasSE1)->E1_MOEDA,nMoeda,,5),"@E 9999,999,999.99"),;
	       	           	      (cAliasSE1)->E1_FILIAL,;
  							  Transform(xMoeda(nValLim,nMoeda,nMoeda,,5,Fa330Tx2((cAliasSE1)->E1_MOEDA,(cAliasSE1)->E1_TXMOEDA),Fa330Tx2(nMoeda, nTxMoeda)),"@E 9999,999,999.99")})//Limite de Compensacao


			EndIf
	       //---
		EndIf
		If lAdiciona
			aAdd(aRecNo,If(lQuery,(cAliasSE1)->RECSE1,(cAliasSE1)->(RecNo())))
		EndIf
		(cAliasSE1)->(dbSkip())
	Enddo
	If !lQuery
		dbSelectArea("SM0")
		dbSkip()
		If Empty( cFilFwSE1 )
			Exit
		Endif
	Else
		Exit
	Endif
EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Recupera a Integridade dos dados	  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SM0")
dbGoto(nRecEmp)
cFilAnt := IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL )

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Atualiza valor total dos t¡tulos - Windows	 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nValTot := 0
For nX := 1 to Len(aTitulos)
	If aTitulos[nX,8]
		nValtot += Fa330VTit(aTitulos[nX,7])
	Endif
Next

If lQuery
	/* GESTAO - inicio */
	If !Empty(aTmpSE1Fil)
  		For nX := 1 TO Len(aTmpSE1Fil)
			CtbTmpErase(aTmpSE1Fil[nX])
	    Next
	Endif
	/* GESTAO - fim */
	dbSelectArea(cAliasSE1)
	dbCloseArea()
	dbSelectArea("SE1")
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Recupera a Integridade dos dados	  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea(cSavArea)
dbSetOrder(nSavOrd)
dbGoto(nRecNo)

Return( aTitulos )
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Fa330VTit ³ Autor ³ Mauricio Pequim Jr.   ³ Data ³ 22/09/97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna o saldo ou valor do titulo a ser compensado		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Fina330													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Fa330VTit(aTitulo,cTipoTit,cValor)
LOCAL nValor
cValor := IIF (cValor == NIL,aTitulo,cValor)
If ValType(cValor)=="N"
	nValor := cValor
Else
	nValor := DesTrans(cValor)
Endif
Return nValor

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ FA330Desc³ Autor ³ Wagner Xavier 		³ Data ³ 01/09/94 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Cancelar a Compensa‡„o de Adiantamentos.					  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ FA330Desc() 												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FINA330													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FA330Desc( cAlias, nReg, nOpc )
Local lPanelFin := IsPanelFin()
Local nOpcA 		:= 0         		// Indica se a Compesa‡ao sera efetuada
Local dBaixa		:= SE1->E1_BAIXA	// Data da Baixa
Local lCancelou 	:= .F.				// Indica se foi realmente cancelado
Local aRegistros 	:= {}             // Guarda os registros do SE5 a serem cancelados
Local cDocumento  := ""             // Guarda o RA/NCC que efetuou a Bx.
local cArquivo    := ""             // Utilizado na Contabilizacao
local nTotal		:=0               // Utilizado na Contabilizacao
local nHdlPrv		:=0               // Utilizado na Contabilizacao
local cPadrao		:="588"           // Utilizado na Contabilizacao
local lPadrao		:=.F.					// Utilizado na Contabilizacao
Local lFirst		:=.F.					// Utilizado na Contabilizacao
Local cLojaCmp		:= ""             // Util. para Comp. de Lojas diferentes
local nOrdSE1		:= SE1->(IndexOrd())
local nRegSE1     := 0              // Guarda o Registro do SE1
local nRegSE5     := 0              // Guarda o Registro do SE5
Local lMarcado		:=.F.             // Indica se o item foi marcado
Local nMoeda      := 0              // Moeda do Titulo Principal (SE1)
Local cAdiantamento						// Guarda o RA/NCC que efetuou a Bx.
Local nVlrAbat    := 0
Local aBaixas     := {}             // Guarda as baixas do SE5 para cancelar comissao
Local oDlg
Local oOk		:= LoadBitmap( GetResources(), "LBOK" )
Local oNo		:= LoadBitmap( GetResources(), "LBNO" )
Local oTitulo
Local nDecs       := 2
Local nTxMoeda    := 0
Local nDecs1      := MsDecimais(1)
Local	aDoctosSE5  := {}
Local nSaldoComp  := 0
Local aArea:={}
Local cChaveSE1
Local nValCtb := 0		// Valor total a ser contabilizado (VALOR)
Local nI := 0
Local nLaco := 0
Local nTotAbat := 0
Local nSE1Rec := 0
Local cKeyAbt := 0
Local nAcresc := 0		//Acrescimo do titulo de adiantamento
Local nDecres := 0		//Decrescimo do titulo de adiantamento
Local nTitAcres := 0		//Acrescimo do titulo principal
Local nTitDecre := 0		//Decrescimo do titulo principal
Local aSE5 := {}
Local nX := 0
Local nY := 0
Local nT := 0
Local lAchou := .F.
Local cCliAdt := ""
Local cLojAdt := ""
Local lF330FLTC := ExistBlock("F330FLTC")
Local nRecnoSE1 := SE1->(RECNO())
Local lImpComp := SuperGetMv("MV_IMPCMP",,"2") == "1"
Local lIsNcc	:= .F.
//Compensacao de contas a receber, nao necessita verificar o parametro MV_BX10925
Local lPCCBaixa := (cPaisLoc == "BRA")

Local lRaRtImp  := FRaRtImp()     //Define se ha retencao de impostos PCC/IRPJ no R.A
Local aSize			:= {}
Local oPanel
Local lDigita
LOCAL lACAtivo 		:= GetNewPar("MV_ACATIVO", .F.) //Verifica se o cliente utiliza o modulo Educacional
Local aAcValores	:= {}
Local aAcLayout		:= {}
Local cAcTitulo		:= ""
Local cAcPrefixo	:= ""
Local cAcNumero		:= ""
Local cAcParcela	:= ""
Local cAcTipo		:= ""

Local aDiario		:=	{}
Local lVldDtFin		:= .T.
Local aFlagCTB		:= {}
Local lUsaFlag		:= SuperGetMV( "MV_CTBFLAG" , .T. /*lHelp*/, .F. /*cPadrao*/)
Local lAtusalImp	:= .F.

//Controla o Pis Cofins e Csll na baixa  (1-Retem PCC na Baixa ou 2-Retem PCC na Emissão(default) )
Local lPccBxCr	:= FPccBxCr()
//Controla IRPJ na baixa
Local lIrPjBxCr		:= FIrPjBxCr()
Local nPis		:= 0
Local nCofins	:= 0
Local nCsll		:= 0
Local nInss		:= 0
Local nCtbInss		:= 0
Local aTitulosTMP	:= {}
Local nPos			:= 0
Local aTamChav		:= {}
Local cREGAnt 		:= ""
Local cREG 			:= ""
Local aLstDOC		:= {}
Local cChaveE1Adt := ""
Local cChaveE5Adt := ""
Local aAreaE5Adt
Local aAreaE1Adt
Local aAdtVen  := {}
Local lAdtVen  := .F.
Local aTipos   := {}
Local cTipos   := ""
Local cTipoAux := ""
Local lVinculo := .F.
Local lF330Exclui
Local lF330ESE5   := ExistBlock( "F330ESE5" )
Local lF330ExComp := ExistBlock( "F330EXCOMP" )
Local lFi330Est   := ExistBlock( "FI330EST" )
Local l330DESC    := ExistBlock("F330DESC")
Local lDESC       := .F.
Local lRetAuto	:= .T.
Local cChavePai	:= ''
Local cChaveImp	:= ''
Local aDtMov	:=	{}
Local lPccComp 	:= .T.
Local aAreaSE5	:=	{}
Local cChaveSE5	:=	''
Local lBxCanc	:= .T.
Local nDescP	:= 0
Local nDescD	:= 0
Local nIrrfPac := 0
Local nSaldoBx	:= 0
Local nVlNewPis := nVlNewCof := nVlNewCsl := nPosTit := nVlNewIrf := 0

//--- Tratamento Gestao Corporativa
Local lGestao   := Iif( lFWCodFil, FWSizeFilial() > 2, .F. )	// Indica se usa Gestao Corporativa
Local cFilFwSE1 := lGestao .And. FwFilial("SE1")
Local cAliasCmp	:= GetNextAlias()
Local aDadosX	:=  {}
Local cFilCred	:=  ""
Local lUnidNeg := Iif( lFWCodFil, FWSizeFilial() > 2, .F. )	// Indica se usa Gestao Corporativa
Local cFilSe1	:=	xFilial("SE1")
Local cTrabalho :=""
Local aCampos	:= {}
Local lLjOrigem := Alltrim(Upper(FunName())) $ "LOJA140|LOJA701" .OR. Alltrim(SE1->E1_ORIGEM) $ "LOJA701|FRTA010|LOJA720" //indica se eh executada por alguma rotina do SIGALOJA/FRT

//Controle de abatimento
Local nOrdTitPai:=0
Local lTitpaiSE1 := (nOrdTitPai:= OrdTitpai()) > 0
Local cTipo := ""
Local bWhile := {|| !EOF() .And. E1_FILIAL+E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA==cFilSE1+cKeyAbt}
Local bWhile2 := {|| (cFilSE1+cPrefixo+cNum+cParcela == SE1->E1_FILIAL+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA ) .OR. (Alltrim(SE1->E1_TITPAI) == Alltrim(cChavePai))}
Local lSE1Exclusivo := .F.
Local cFilOld := cFilAnt
// Variaveis para o Novo Modelo de Gravacao do Movimento Bancario
Local aAreaAnt := {}
Local oModelMov := nil //FWLoadModel("FINM010")
Local oSubFK1
Local cLog := ""
Local lRet := .T.
Local cCamposE5 := ""
//Impostos gerados pela rotina de Borderô de Recebimento de Imposto (FINA061).
Local	nPisFina061	:=	0
Local	nCofFina061	:=	0
Local	nCslFina061	:=	0
Local	nIrfFina061	:=	0  
Local nOrdSE5	:=	0
Local nVlPis	:= 0
Local nVlCof	:= 0
Local nVlCsll	:= 0
Local nVlIrrf	:=	0
Local nVlNf	:= 	0
Local lPropBx  := SuperGetMv("MV_PROPBX",.F.,"2") == "1"
Local nAbat		:=  0
Local lBQ10925	:= SuperGetMV("MV_BQ10925",,"2") == "1" .And. !lRaRtImp
Local aBaixa := {}
LOCAL nTotAdto		:= 0
Local lBaixaAbat	:= .F.
Local nVlrBaixa		:= 0
Local lBxCec		:= .F.
Local lBxLiq		:= .F.
Local lbxPos		:= .F.
Local lExistFJU := FindFunction("FinGrvEx")
Local lContabiliza	:= .F.
Local lF070TRAVA		:= ExistBlock("F070TRAVA")
Local lGrvSa1			:= .T.

PRIVATE aTitulos	:={}
PRIVATE cPrefixo	:= SE1->E1_PREFIXO
PRIVATE cNum		:= SE1->E1_NUM
PRIVATE cTipoTit	:= SE1->E1_TIPO
PRIVATE cCliente	:= SE1->E1_CLIENTE
PRIVATE cLoja		:= SE1->E1_LOJA
PRIVATE cParcela	:= SE1->E1_PARCELA
PRIVATE cTipodoc	:= "  "
PRIVATE lCredito	:= .F.
PRIVATE cTipodc		:= " "
PRIVATE nValTit		:= 0
PRIVATE aBaixaSE5 	:= {}
//Guardando a chave do titulo pai.
cChavePai	:= SE1->(E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO + E1_CLIENTE + E1_LOJA)

If lGestao
	If !Empty(cFilFwSE1)
		lSE1Exclusivo := .T.
    EndIf
Else
	If !Empty(xFilial("SE1"))
		lSE1Exclusivo := .T.
	EndIf
EndIf

If !FA330Lock(,SE1->(Recno()))
	Return
Endif

If (ALLTRIM(SE1->E1_ORIGEM) == "FINA677") .and. !(FINVERRES(SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA),SE1->E1_ORIGEM, "R"))
	Help(" " , 1 , "FAVIAGEM")
	Return
Endif

If ExistBlock("F330DTFIN")
	lVldDtFin := ExecBlock("F330DTFIN",.F.,.F.)
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se data do movimento n„o ‚ menor que data limite de ³
//³ movimentacao no financeiro    										  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lVldDtFin .and. !DtMovFin(,,"2")
	Return(.F.)
Endif

If lF070TRAVA
   	lGrvSa1 := ExecBlock("F070TRAVA", .F., .F.)
Endif

If SE1->E1_TIPO $MV_CRNEG+"/"+MVRECANT
	cTipodoc := "BA"
	lCredito:= .T.
	cTipodc:="CP"
	lIsNcc := SE1->E1_TIPO $ MV_CRNEG
Else
	cTipodoc := "CP"
	cTipodc:="BA"
Endif
If Substr(SE1->E1_TIPO,3,1) == "-"
  If !l330Auto
	 Help(" ",1,"FA030INVAL")
  Endif
  lRetAuto := .F.
  Return lRetAuto
EndIf

//-----------------------------------------------------------
// Nao permite compensar recebimentos antecipados originados
// de faturas de adiantamentos. Req. Manejo de Anticipo
//-----------------------------------------------------------
If cPaisLoc == "MEX" .And. X3Usado("ED_OPERADT")
	If SE1->E1_TIPO == Substr(MVRECANT,1,3) .And.;
		Upper(Alltrim(SE1->E1_ORIGEM)) == "FINA087A" .And.;
		GetAdvFVal("SED","ED_OPERADT",xFilial("SED")+SE1->E1_NATUREZ,1,"") == "1"

		Help(" ",1,"VLDTITRA",,STR0065,1,0) //"Processo não permitido para recebimento antecipado gerado de fatura de adiantamento."
		Return (.F.)

	EndIf
EndIf

If Select("__SE1") == 0
	SumAbatRec("","","",1,"")
Endif

While ( .T. )
	aTitulos   := {}
	aRegistros := {}
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Titulo a ser cancelado a compensa‡„o		 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nOpca := 0

	If !l330Auto
		If lPanelfin
			oPanelDados := FinWindow:GetVisPanel()
			oPanelDados:FreeChildren()
			aDim := DLGinPANEL(oPanelDados)
			DEFINE MSDIALOG oDlg OF oPanelDados:oWnd FROM 0,0 To 0,0 PIXEL STYLE nOR( WS_VISIBLE, WS_POPUP )

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Observacao Importante quanto as coordenadas calculadas abaixo: ³
			//³ -------------------------------------------------------------- ³
			//³ a funcao DlgWidthPanel() retorna o dobro do valor da area do	 ³
			//³ painel, sendo assim este deve ser dividido por 2 antes da sub- ³
			//³ tracao e redivisao por 2 para a centralizacao. 					 ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nEspLarg := ((DlgWidthPanel(oPanelDados)/2) - 225) /2
			nEspLin  := 20
	   Else
	   	nEspLarg := 0
	   	nEspLin  := 2
			DEFINE MSDIALOG oDlg FROM	88,31 TO 187,525 TITLE STR0019 PIXEL  //"Compensa‡„o CR"
		Endif
		oDlg:lMaximized := .F.
		oPanel := TPanel():New(0,0,'',oDlg,, .T., .T.,, ,20,20)
		oPanel:Align := CONTROL_ALIGN_ALLCLIENT

	   @ 000+nEspLin, 002+nEspLarg TO 030+nEspLin, 245+nEspLarg OF oPanel	PIXEL

		@ 014+nEspLin, 006+nEspLarg MSGET cPrefixo							SIZE 19, 10 OF oPanel PIXEL
		@ 014+nEspLin, 032+nEspLarg MSGET cNum 	 Valid !Empty(cNum)	SIZE 70, 10 OF oPanel PIXEL
		@ 014+nEspLin, 105+nEspLarg MSGET cParcela							SIZE 20, 10 OF oPanel PIXEL
		@ 014+nEspLin, 129+nEspLarg MSGET cTipoTit  Picture "@!" Valid  !Empty(cTipoTit) .And.;
			Subs(cTipoTit,3)!="-" SIZE 16, 10 OF oPanel PIXEL
		@ 014+nEspLin, 155+nEspLarg MSGET cCliente F3 "SA1" Valid fa330Cli() SIZE 70, 10 OF oPanel Hasbutton PIXEL
		@ 014+nEspLin, 226+nEspLarg MSGET cLoja	Valid Fa330Loja() 	SIZE 16, 10 OF oPanel PIXEL

		@ 006+nEspLin, 006+nEspLarg SAY STR0006  SIZE 21, 7 OF oPanel PIXEL  //"Prefixo"
		@ 006+nEspLin, 032+nEspLarg SAY STR0007  SIZE 22, 7 OF oPanel PIXEL  //"N£mero"
		@ 006+nEspLin, 105+nEspLarg SAY STR0008  SIZE 23, 7 OF oPanel PIXEL  //"Parcela"
		@ 006+nEspLin, 129+nEspLarg SAY STR0009  SIZE 14, 7 OF oPanel PIXEL  //"Tipo"
		@ 006+nEspLin, 155+nEspLarg SAY STR0025  SIZE 34, 7 OF oPanel PIXEL  //"Cliente   "
		@ 006+nEspLin, 226+nEspLarg SAY STR0011  SIZE 14, 7 OF oPanel PIXEL  //"Loja"

		If lPanelFin  //Chamado pelo Painel Financeiro
			oDlg:Move(aDim[1],aDim[2],aDim[4]-aDim[2], aDim[3]-aDim[1])
			ACTIVATE MSDIALOG oDlg ON INIT FaMyBar(oDlg,;
			{||nOpca:=1,oDLg:End()},;
			{||nOpca:=0,oDlg:End()})

	   Else
			DEFINE SBUTTON FROM 34, 190 TYPE 1 ENABLE ACTION (nOpca:=1,oDLg:End()) OF oDlg
			DEFINE SBUTTON FROM 34, 218 TYPE 2 ENABLE ACTION oDlg:End() OF oDlg
			ACTIVATE MSDIALOG oDlg CENTERED

		Endif

		If lFi330Est .And. nOpca == 1
			nOpca := ExecBlock("FI330EST",.F.,.F.,{ nOpc, { cPrefixo, cNum, cParcela, cTipoTit, cCliente, cLoja }})
			If ValType(nOpca) != "N"
				nOpca := 0
			EndIf
		EndIf

		If ( nOpca == 0 )
			DeleteObject(oOk)
			DeleteObject(oNo)

			Exit
		Endif

	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o t¡tulo existe. 	³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SE1")
	dbSetOrder(2)
	dbSeek(xFilial("SE1")+cCliente+cLoja+cPrefixo+cNum+cParcela+cTipoTit)
	If !Found()
	  If !l330Auto
		 Help(" ",1,"NOTIT")
	  Endif
	  DeleteObject(oOk)
	  DeleteObject(oNo)
	  FA330aUnlock()
	  lRetAuto := .F.
	  Exit
	Endif
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se o t¡tulo nao foi compensado.  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ( SE1->E1_SALDO == SE1->E1_VALOR ) .and. ;
		(SE1->E1_ACRESC == SE1->E1_SDACRES) .and. ;
		(SE1->E1_DECRESC == SE1->E1_SDDECRE)

		If ! l330Auto
		  Help(" ",1,"A330NAOCOMP")
		Endif

		DeleteObject(oOk)
		DeleteObject(oNo)
		lRetAuto := .F.
		Exit //Loop

	EndIf

	//ANGOLA - Nao permitir compensar titulos de adiantamento relacionado a pedido
	#IFDEF TOP
		If cPaisLoc == "ANG"
			FIE->(dbSetOrder(2))
			If FIE->(MsSeek(xFilial("FIE")+"R"+SE1->(E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO)))
				Help(" ",1,"NOCANCMP",,STR0063,1,0)
				DeleteObject(oOk)
				DeleteObject(oNo)
				Loop
			Endif
		Endif
	#ENDIF

	nMoeda 		:= SE1->E1_MOEDA 				// Moeda do tit original
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Guardo dados do titulo principal para utilizar   ³
	//³ no historico da contabiliza‡Æo                   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	STRLCTPAD := SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Procura a filial em que este titulo foi compensado ³
	//³ quando compensacao multifiliais                    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	#IFDEF TOP
	#ELSE
		aTam:=TamSX3("E5_FILIAL")
		AADD(aCampos,{"E5_FILIAL"  ,"C",aTam[1],aTam[2]})
		cTrabalho := CriaTrab(aCampos)
	#ENDIF
	F330PsqFil(SE1->E1_FILORIG,cPrefixo,cNum,cParcela,SE1->E1_CLIENTE,SE1->E1_LOJA,cTipoTit,"R",cTipoDoc,cAliasCmp,@cTrabalho)


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Procura adiantamentos do titulo original para      ³
	//³ montar lista de titulos compensados para apresentar³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	DbSelectArea(cAliasCmp)
	While (cAliasCmp)->( !EOF() )
		dbSelectArea("SE5")
		dbSetOrder(2)
		dbSeek( (cAliasCmp)->( E5_FILIAL ) + cTipoDoc+cPrefixo+cNum+cParcela+cTipoTit)
		While (!Eof() .and. (cAliasCmp)->( E5_FILIAL ) == SE5->E5_FILIAL .And.	;
				SE5->E5_TIPODOC == cTipoDoc .And. 				;
				SE5->E5_PREFIXO == cPrefixo .And.				;
				SE5->E5_NUMERO == cNum .And.					;
				SE5->E5_PARCELA == cParcela )

			If (SE5->E5_MOTBX != "CMP" .Or. SE5->E5_RECPAG != "R" )
				dbSkip()
				Loop
			Endif

			//Verifica se tem baixa cancelada
			If TemBxCanc(SE5->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ),.T.,SE5->E5_FILIAL)
				SE5->(dbskip())
				Loop
			EndIf

			aBaixaSE5 := {}
			lbxPos := .F.
			//verifica se houve baixa posteriores
			aBaixa := Sel070Baixa( "VL /V2 /BA /RA /CP /LJ /" + MV_CRNEG, SE5->E5_PREFIXO,SE5->E5_NUMERO, SE5->E5_PARCELA, SE5->E5_TIPO,;
				@nTotAdto, @lBaixaAbat, SE5->E5_CLIFOR, SE5->E5_LOJA, @nVlrBaixa, , @lBxCec, @lBxLiq , ,.T.)

			For nX := 1 to len(aBaixaSE5)
				If aBaixaSE5[nX][29] == "CMP"
						Loop						
				ElseIf aBaixaSE5[nX][9] > SE5->E5_SEQ
					If aBaixaSE5[nX][18]+aBaixaSE5[nX][19]+aBaixaSE5[nX][20]+aBaixaSE5[nX][30] > 0
						HELP(" ",1, "FINIMPBX" )
						lbxPos := .T.
						Exit						
					EndIf 
				EndIf
			Next nXad
			
			If lbxPos
				SE5->(DbSkip())
				Loop
			EndIf	
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica Cliente se considerar Cliente Original 		³
			//³ na selecao de titulos 									³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If mv_par02 == 1 .and.  SE5->E5_CLIFOR != SE1->E1_CLIENTE
				dbSkip( )
				Loop
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica loja caso considere loja na selecao de titulos	  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If mv_par01 == 1 .and. mv_par02 == 1 .and.  SE5->E5_LOJA != SE1->E1_LOJA
				dbSkip( )
				Loop
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se a baixa e anterior a data do sistema    	  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If SE5->E5_DATA >dDatabase
				dbSkip( )
				Loop
			EndIf

			//ANGOLA - Nao permitir compensar titulos de adiantamento relacionado a pedido
			#IFDEF TOP
				If cPaisLoc == "ANG"
					FIE->(dbSetOrder(2))
					If FIE->(MsSeek(xFilial("FIE")+"R"+SE5->(E5_CLIFOR+E5_LOJA+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO)))
						dbSkip()
						Loop
					Endif
				Endif
			#ENDIF

			#IFDEF TOP
				If cPaisLoc == "BRA"
					// se estorno da compensacao nao estah partindo do titulo de credito
					If !lCredito
						If SE1->E1_ORIGEM = "MATA460" .and. !lCredito//SE1->E1_TIPO = MVNOTAFIS
							// checa se condicao de pagamento eh relacionado com adiantamento
							If FaNfsRAdt(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_CLIENTE,SE1->E1_LOJA,SE1->E1_EMISSAO)
								lAdtVen := .T.
								// checa se eh a primeira baixa para o titulo principal, pois a primeira baixa eh realizada no momento da geracao do documento de saida, quando hah adiantamento relacionado ao documento.
								If FaBxEmisDoc(SE5->E5_FILIAL,SE5->E5_PREFIXO,SE5->E5_NUMERO,SE5->E5_PARCELA,SE5->E5_CLIFOR,SE5->E5_LOJA,SE5->E5_TIPO,SE5->E5_DATA,SE5->E5_SEQ,"R",SE5->E5_DOCUMEN)
									dbSelectArea("SE5")
									aAdd(aAdtVen,{SE5->E5_DATA,SE5->E5_VALOR,SE5->E5_CLIFOR,SE5->E5_LOJA,SE5->E5_SEQ}) // grava array com registros que foram compensados no momento da geracao do documento de saida e que nao podem ser excluidos na compensacao do Fina330. Grava campos que sao iguais entre o registro principal da baixa e o do adiantamento.
									dbSkip()
									Loop
								Endif
							Endif
						Endif
					// se estorno da compensacao estah partindo do titulo de credito
					Else
						// posiciona no titulo principal e na baixa principal para checar se eh adiantamento e se esta baixa foi gerada no momento da emissao do documento de saida.
						aAreaE5Adt := SE5->(GetArea())
						If lLjOrigem .Or. Empty(SE5->E5_FORNADT)	//executada por alguma rotina do SIGALOJA/FRT
							cChaveE5Adt := SE5->E5_FILIAL+cTipoDc+Subs(SE5->E5_DOCUMEN,1,nTamTit+nTamTip)+dTos(SE5->E5_DATA)+IIf(Empty(SE5->E5_FORNADT),SE5->(E5_CLIFOR+E5_LOJA+E5_SEQ),SE5->(E5_FORNADT+E5_LOJAADT+E5_SEQ))
						Else
							cChaveE5Adt := SE5->E5_FILIAL+cTipoDc+Subs(SE5->E5_DOCUMEN,1,nTamTit+nTamTip)+dTos(SE5->E5_DATA)+SE5->(E5_FORNADT+E5_LOJAADT+E5_SEQ)
						EndIf
						aAreaE1Adt := SE1->(GetArea())
						If lLjOrigem .Or. Empty(SE5->E5_FORNADT)	//executada por alguma rotina do SIGALOJA/FRT
							cChaveE1Adt := SE5->E5_FILIAL+IIf(Empty(SE5->E5_FORNADT),SE5->(E5_CLIFOR+E5_LOJA), SE5->(E5_FORNADT+E5_LOJAADT))+Subs(SE5->E5_DOCUMEN,1,nTamTit+nTamTip)
						Else
							cChaveE1Adt := SE5->E5_FILIAL+SE5->(E5_FORNADT+E5_LOJAADT)+Subs(SE5->E5_DOCUMEN,1,nTamTit+nTamTip)
						EndIf
						// posiciona no titulo principal
						SE1->(dbSetOrder(2))
						If SE1->(dbSeek(cChaveE1Adt))

							If (ALLTRIM(SE1->E1_ORIGEM) == "FINA677") .and. !(FINVERRES(SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA),SE1->E1_ORIGEM, "R"))
								SE5->(dbskip())
								Loop
						 	Endif
							// posiciona na baixa principal
							SE5->(dbSetOrder(2))
							If SE5->(dbSeek(cChaveE5Adt))
								If SE1->E1_ORIGEM = "MATA460" .and. !lCredito//SE1->E1_TIPO = MVNOTAFIS
									// checa se condicao de pagamento eh relacionado com adiantamento
									If FaNfsRAdt(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_CLIENTE,SE1->E1_LOJA,SE1->E1_EMISSAO)
										lAdtVen := .T.
										// checa se eh a primeira baixa para o titulo principal, pois a primeira baixa eh realizada no momento da geracao do documento de saida, quando hah adiantamento relacionado ao documento.
										If FaBxEmisDoc(SE5->E5_FILIAL,SE5->E5_PREFIXO,SE5->E5_NUMERO,SE5->E5_PARCELA,SE5->E5_CLIFOR,SE5->E5_LOJA,SE5->E5_TIPO,SE5->E5_DATA,SE5->E5_SEQ,"R",SE5->E5_DOCUMEN)
											RestArea(aAreaE1Adt)
											RestArea(aAreaE5Adt)
											dbSelectArea("SE5")
											aAdd(aAdtVen,{SE5->E5_DATA,SE5->E5_VALOR,SE5->E5_CLIFOR,SE5->E5_LOJA,SE5->E5_SEQ}) // grava array com registros que foram compensados no momento da geracao do documento de saida e que nao podem ser excluidos na compensacao do Fina330.
											dbSkip()
											Loop
										Endif
									Endif
								Endif
								
								
								
								aBaixaSE5 := {}
								lbxPos := .F.
								//verifica se houve baixa posteriores
								aBaixa := Sel070Baixa( "VL /V2 /BA /RA /CP /LJ /" + MV_CRNEG, SE5->E5_PREFIXO,SE5->E5_NUMERO, SE5->E5_PARCELA, SE5->E5_TIPO,;
									@nTotAdto, @lBaixaAbat, SE5->E5_CLIFOR, SE5->E5_LOJA, @nVlrBaixa, , @lBxCec, @lBxLiq , ,.T.)
					
								For nX := 1 to len(aBaixaSE5)
									If aBaixaSE5[nX][29] == "CMP"
											Loop						
									ElseIf aBaixaSE5[nX][9] > SE5->E5_SEQ
										If aBaixaSE5[nX][18]+aBaixaSE5[nX][19]+aBaixaSE5[nX][20]+aBaixaSE5[nX][30] > 0
											HELP(" ",1, "FINIMPBX" )
											lbxPos := .T.
											
											Exit						
										EndIf 
									EndIf
								Next nX
								If lbxPos
									SE5->(DBskip())
									Loop
								EndIf
								
								
							Endif
						Endif
						RestArea(aAreaE1Adt)
						RestArea(aAreaE5Adt)
						dbSelectArea("SE5")
					Endif
				Endif
			#ENDIF

			//Ponto de entrada para dispensar do cancelamento
			If lF330FLTC .and. ExecBlock("F330FLTC",.F.,.F.)
				dbSkip( )
				Loop
			Endif

			If lLjOrigem 	//executada por alguma rotina do SIGALOJA/FRT
				If Empty(SE5->E5_FORNADT)
		  			aAdd(aLstDOC,{xFilial("SE5"),SE5->E5_DOCUMEN,DTOS(SE5->E5_DATA) })
		  		Else
		  			aAdd(aLstDOC,{SE5->E5_FILIAL,SE5->E5_DOCUMEN,DTOS(SE5->E5_DATA)+SE5->E5_FORNADT+SE5->E5_LOJAADT+SE5->E5_SEQ })
		  		EndIf
		  	ElseIf 	Empty(SE5->E5_FORNADT)
		  		aAdd(aLstDOC,{xFilial("SE5"),SE5->E5_DOCUMEN,DTOS(SE5->E5_DATA)+SE5->E5_CLIFOR+SE5->E5_LOJA+SE5->E5_SEQ })
			Else
		  		aAdd(aLstDOC,{SE5->E5_FILIAL,SE5->E5_DOCUMEN,DTOS(SE5->E5_DATA)+SE5->E5_FORNADT+SE5->E5_LOJAADT+SE5->E5_SEQ })
	  		EndIf

			dbSelectArea( "SE5" )
			dbSkip()
		Enddo

		dbSelectArea( cAliasCmp )
		(cAliasCmp)->( dbSkip() )

	Enddo
	
	If (Alltrim(SE5->E5_ORIGEM) $ "MATA410") .and. lAdtVen
		Alert(STR0082)
		Exit
	Endif	

	If Len(aLstDOC) == 0
	  If !l330Auto
		 Help(" ",1,"NOTITSEL")
	  Endif
	  DeleteObject(oOk)
	  DeleteObject(oNo)
	  FA330aUnlock()
	  lRetAuto := .F.
	  Exit
	Endif

	If SE1->E1_TIPO $MV_CRNEG+"/"+MVRECANT
		cTipodoc := "CP"
	Else
		cTipodoc := "BA"
	Endif

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Procura adiantamentos do titulo original para      ³
	//³ montar lista de apresentacao                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

	dbSelectArea("SE5")
	SE5->(dbSetOrder(2))	//E5_FILIAL, E5_TIPODOC, E5_PREFIXO, E5_NUMERO, E5_PARCELA, E5_TIPO, E5_DATA, E5_CLIFOR, E5_LOJA, E5_SEQ
	For nI := 1 to Len(aLstDOC)
		SE5->(dbSeek(aLstDoc[nI][1] + cTipoDoc + Substr(aLstDoc[nI][2],1,nTamTit+nTamTip) + Iif(!lLjOrigem .or. Len(aLstDoc[nI][3]) > 10,aLstDoc[nI][3],"") ))
		If (lF330ESE5)
			//-- Ponto de entrada para que o registro na SE5 seja posicionado corretamente
			//-- quando existir diferenças no tamanho dos campos envolvidos no indice do SEEK.
			ExecBlock("F330ESE5",.F.,.F.,{aLstDOC,cTipoDoc,nTamTit,nTamTip,nI})
		EndIf
   		While SE5->(! Eof() .AND. SE5->E5_FILIAL == aLstDoc[nI][1] .AND.	;
					E5_TIPODOC + E5_PREFIXO + E5_NUMERO + E5_PARCELA+E5_TIPO == cTipoDoc + Substr(aLstDoc[nI][2],1,nTamTit+nTamTip) .AND. ;
					SubStr(DTOS(SE5->E5_DATA)+SE5->(E5_CLIFOR+E5_LOJA+E5_SEQ), 1, Len(aLstDoc[nI][3]) ) == aLstDoc[nI][3] )

			// se for compensacao gerado no momento da geracao do documento de saida, nao pode ser excluido na compensacao do Fina330.
			#IFDEF TOP
				If lAdtVen
					If aScan(aAdtVen,{|x| x[1] = SE5->E5_DATA .and. ;
					x[2] = SE5->E5_VALOR .and. ;
					x[3] = SE5->E5_CLIFOR .and. ;
					x[4] = SE5->E5_LOJA.and. ;
					x[5] = SE5->E5_SEQ}) > 0
						dbSkip()
						Loop
					Endif
				Endif
			#ENDIF

			If (SE5->E5_MOTBX != "CMP" .Or. SE5->E5_RECPAG != "R")
				dbSkip( )
				Loop
			Endif

			//Verifica se tem baixa cancelada-
			If TemBxCanc(SE5->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ),.T.,SE5->E5_FILIAL)
				SE5->(dbskip())
				Loop
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica Cliente se considerar Cliente Original 			³
			//³ na selecao de titulos 												³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If mv_par02 == 1 .and.  SE5->E5_CLIFOR != SE1->E1_CLIENTE
				dbSkip( )
				Loop
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica loja caso considere loja na selecao de titulos	  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If mv_par01 == 1 .and. mv_par02 == 1 .and.  SE5->E5_LOJA != SE1->E1_LOJA
				dbSkip( )
				Loop
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se a baixa e posterior a data do sistema    	  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If SE5->E5_DATA >dDatabase
				dbSkip( )
				Loop
			EndIf

			//ANGOLA - Nao permitir compensar titulos de adiantamento relacionado a pedido
			#IFDEF TOP
				If cPaisLoc == "ANG"
					FIE->(dbSetOrder(2))
					If FIE->(MsSeek(xFilial("FIE")+"R"+SE5->(E5_CLIFOR+E5_LOJA+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO)))
						dbSkip()
						Loop
					Endif
				Endif
			#ENDIF

			//Ponto de entrada para dispensar do cancelamento
			If lF330FLTC .and. ExecBlock("F330FLTC",.F.,.F.)
				dbSkip( )
				Loop
			Endif

			If cTipoTit $ MV_CRNEG + "/" + MVRECANT
				If (lIsNCC .AND. !Substr(SE5->E5_DOCUMEN,nTamTit+1,nTamTip) $ MV_CRNEG) .OR. (!lIsNCC .AND. !Substr(SE5->E5_DOCUMEN,nTamTit+1,nTamTip) $ MVRECANT)
			 		SE5->(dbSkip())
					Loop
				Else
					If Substr(SE5->E5_DOCUMEN,1,nTamTit) # SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA)
						SE5->(dbSkip())
						Loop
					Endif
				Endif
			Endif

			If !(cTipoTit $ MV_CRNEG + "/" + MVRECANT)
				IF Substr(SE5->E5_DOCUMEN,1,nTamTit+nTamTip+nTamLoj) != cPrefixo+cNum+cParcela+cTipoTit+cLoja
					SE5->(dbSkip())
					Loop
				Endif
			Endif

			nOrdSE1	:= SE1->(IndexOrd())
			nRegSE1	:= SE1->(Recno())
			nTAbat := SumAbatRec(cPrefixo,cNum,cParcela,SE1->E1_MOEDA,"V",dBaixa)
		
			If lPccBxCr
				nTAbat += FA330RetPCC(cPrefixo,cNum,cParcela,SE1->E1_MOEDA,dBaixa)
			EndIf
			
			If lIrPjBxCr .And. !lRartimp
				nTAbat += SE1->E1_IRRF
			EndIf		  	
			SE1->(dbSetOrder(nOrdSE1))
			SE1->(dbGoto(nRegSE1))
//			If !lRartimp .And. lIrPjBxCr 
//				nTAbat += FA330RetIRF(cPrefixo,cNum,cParcela,SE1->E1_MOEDA,dBaixa)
//			EndIf

			nVlLiqTit:= SE1->E1_VALOR - nTAbat		// Valor do titulo - Abatimentos
			Aadd( aTitulos,{ SE5->E5_PREFIXO,;
				SE5->E5_NUMERO,;
				SE5->E5_PARCELA,;
				SE5->E5_TIPO,;
				SE5->E5_LOJA,;
				DtoC(SE5->E5_DATA),;
				Substr(SE5->E5_DOCUMEN,1,nTamTit),;
				SE5->E5_SEQ,;
				Transform(nVlLiqTit,"@E 9999,999,999.99"),;
				Transform(SE5->E5_VLMOED2,"@E 9999,999,999.99"),;
				.T.,;
		    	SE1->E1_FILIAL,;
		    	SE5->E5_FILIAL })
			dbSelectArea( "SE5" )
			dbSkip()
		Enddo
	Next nI
	
	If (Alltrim(SE5->E5_ORIGEM) $ "MATA410") .and. (SE5->E5_TIPO $ MVRECANT)
		Alert(STR0082)
		Exit
	Endif	

	If Len(aTitulos) == 0
	  If !l330Auto
		 Help(" ",1,"NOTITSEL")
	  Endif
	  DeleteObject(oOk)
	  DeleteObject(oNo)
	  FA330aUnlock()
	  lRetAuto := .F.
	  Exit
	Else
		//Remove titulos duplicados, caso existam
		// Primeiro ordena o array para que a lógica faça mais sentido
		aSort( aTitulos , , , { |a,b| a[1]+a[2]+a[3]+a[4]+a[6]+a[8] > b[1]+b[2]+b[3]+b[4]+b[6]+b[8] } )
		If Len(aTitulos) > 1
			For nI := Len(aTitulos) to 1 Step -1
				For nX := 1 to Len(aTitulos[nI])
			   		cREG += IIf(!cValtoChar(nX) $ "6,11",IIf(ValType(aTitulos[nI,nX]) # "C",cValtoChar(aTitulos[nI,nX]),aTitulos[nI,nX]),"")
				Next nX
				If cREGAnt == cREG
					aTitulos[nI,11] := .F.
				Endif
    			cREGAnt := cREG
       			cREG := ""
			Next nI
			For nI := 1 to Len(aTitulos)
				If aTitulos[nI,11]
					aAdd(aTitulosTMP,aTitulos[nI])
					If !DtMovFin(CtoD(aTitulosTMP[Len(aTitulosTMP)][06]),.F.,"2")
						aTitulosTMP[Len(aTitulosTMP)][11] := .F.
					Endif
				Endif
			Next nI
			aTitulos := aClone(aTitulosTMP)
			aTitulosTMP := Array(0)
		Else
			If !DtMovFin(CtoD(aTitulos[Len(aTitulos)][06]),.F.,"2")
				aTitulos[Len(aTitulos)][11] := .F.
			Endif
		Endif
	Endif

	nOpcA := 0
	If !l330Auto

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Mostra Titulos Compensados			 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aSize := MsAdvSize(,.F.,400)
		DEFINE MSDIALOG oDlg TITLE cCadastro From aSize[7],0 to aSize[6],aSize[5] of oMainWnd PIXEL
		oDLg:lMaximized := .T.

		@ 01.0,.5 LISTBOX oTitulo VAR cVarQ Fields;
			HEADER "",	STR0006,;  //"Prefixo"
			STR0007,;  //"N£mero"
			STR0008,;  //"Parcela"
			STR0009,;  //"Tipo"
			STR0011,;  //"Loja"
			STR0020,;  //"Data"
			STR0021,;  //"Documento"
			STR0022,;  //"Seq"
			STR0023,;  //"Valor do t¡tulo"
			STR0017 ;  //"Valor compensado"
			COLSIZES 12,GetTextWidth(0,"BBBBB")	,;
			GetTextWidth(0,"BBBBBBBBB")		   ,;
			GetTextWidth(0,"BBBBB")					,;
			GetTextWidth(0,"BBB")					,;
			GetTextWidth(0,"BBB")					,;
			GetTextWidth(0,"BBBBBB")				,;
			GetTextWidth(0,"BBBBBBBBBB")  		,;
			GetTextWidth(0,"BBB")					,;
			GetTextWidth(0,"BBBBBBBBBB")			,;
			GetTextWidth(0,"BBBBBBBBBB")			;
			SIZE 293,54.5 ON DBLCLICK (aTitulos := FA330marca(oTitulo:nAt,aTitulos,nOpc),oTitulo:Refresh())NOSCROLL

		oTitulo:bHeaderClick := {|oObj,nCol| If( nCol==1, fMarkAll(@aTitulos,,.T.),Nil), oTitulo:Refresh()}

		oTitulo:SetArray(aTitulos)
		oTitulo:bLine := { || {If(aTitulos[oTitulo:nAt,11],oOk,oNo),;
			aTitulos[oTitulo:nAt,1],aTitulos[oTitulo:nAt,2],;
			aTitulos[oTitulo:nAt,3],aTitulos[oTitulo:nAt,4],;
			aTitulos[oTitulo:nAt,5],aTitulos[oTitulo:nAt,6],;
			aTitulos[oTitulo:nAt,7],aTitulos[oTitulo:nAt,8],;
			aTitulos[oTitulo:nAt,9],aTitulos[oTitulo:nAt,10]}}

		oTitulo:Align := CONTROL_ALIGN_ALLCLIENT
		//---
		oPanel := TPanel():New(0,0,'',oDlg, oDlg:oFont, .T., .T.,, ,20,20,.T.,.T. )
		oPanel:Align := CONTROL_ALIGN_BOTTOM

		If lPanelFin  //Chamado pelo Painel Financeiro
			ACTIVATE MSDIALOG oDlg ON INIT FaMyBar(oDlg,;
			{||nOpca:=1,oDLg:End()},;
			{||nOpca:=0,oDlg:End()})
	   Else
			DEFINE SBUTTON FROM 4,325 TYPE 1 ACTION (nOpca := 1,oDlg:End())  ENABLE OF oPanel PIXEL
			DEFINE SBUTTON FROM 4,360 TYPE 2 ACTION (nOpca := 0,oDlg:End())  ENABLE OF oPanel PIXEL
			ACTIVATE MSDIALOG oDlg CENTERED ON INIT (oTitulo:Refresh())
			If ( nOpca == 0 )
				DeleteObject(oOk)
				DeleteObject(oNo)
				Exit
			Endif
		Endif
	Else
		nOpcA := 1
	EndIf

	If ( nOpcA == 1 )

		//Desinvertendo a selecao NF-Antecipacao
		If SE1->E1_TIPO $MV_CRNEG+"/"+MVRECANT
			cTipodoc := "BA"
		Else
			cTipodoc := "CP"
		Endif
		aTitulosTMP := aClone(aTitulos)
		aTitulos := Array(0)
		aAdd(aTamChav,TamSX3("E5_PREFIXO")[1])
		aAdd(aTamChav,TamSX3("E5_NUMERO")[1])
		aAdd(aTamChav,TamSX3("E5_PARCELA")[1])

		(cAliasCmp)->(DbGoTop())
		DbSelectArea(cAliasCmp)
		While (cAliasCmp)->( !EOF() )
			dbSelectArea("SE5")
			SE5->(dbSetOrder(2))
			SE5->(dbSeek((cAliasCmp)->( E5_FILIAL ) + cTipoDoc + cPrefixo + cNum + cParcela + cTipoTit))
	       	While !SE5->(Eof()) .AND. (cAliasCmp)->( E5_FILIAL ) == SE5->E5_FILIAL .AND.	;
				SE5->E5_TIPODOC == cTipoDoc .AND. ;
				SE5->E5_PREFIXO == cPrefixo .AND. ;
				SE5->E5_NUMERO == cNum .AND. ;
				SE5->E5_PARCELA == cParcela

				// se for compensacao gerado no momento da geracao do documento de saida, nao pode ser excluido na compensacao do Fina330.
				#IFDEF TOP
					If lAdtVen
						If aScan(aAdtVen,{|x| x[1] = SE5->E5_DATA .and. ;
						x[2] = SE5->E5_VALOR .and. ;
						x[3] = SE5->E5_CLIFOR .and. ;
						x[4] = SE5->E5_LOJA.and. ;
						x[5] = SE5->E5_SEQ}) > 0
							dbSkip()
							Loop
						Endif
					Endif
				#ENDIF

				If (SE5->E5_MOTBX != "CMP" .Or. SE5->E5_RECPAG != "R")
					dbSkip( )
					Loop
				Endif

				//Verifica se tem baixa cancelada
				If TemBxCanc(SE5->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ),.T., SE5->E5_FILIAL)
					SE5->(dbskip())
					Loop
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica Cliente se considerar Cliente Original 			³
				//³ na selecao de titulos 												³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If mv_par02 == 1 .and.  SE5->E5_CLIFOR != SE1->E1_CLIENTE
					dbSkip()
					Loop
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica loja caso considere loja na selecao de titulos	  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If mv_par01 == 1 .and. mv_par02 == 1 .and.  SE5->E5_LOJA != SE1->E1_LOJA
					dbSkip( )
					Loop
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Verifica se a baixa e anterior a data do sistema    	  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If SE5->E5_DATA >dDatabase
					dbSkip( )
					Loop
				EndIf

				//Lista de tipos de Adiantamento e Notas de Crédito
				cTipos := MV_CRNEG + "," + MVRECANT
				nT := 0 //Step do nX

				For nX := 1 To Len(cTipos)

					For nY := nX to Len(cTipos)
						If IsAlpha(SubStr(cTipos,nY,1))
							cTipoAux += SubStr(cTipos,nY,1)
							nT++
						Else
							Exit
						Endif
					Next nY

					If Len(aTipos) == 0 .Or. aScan(aTipos,{|x| x == cTipoAux}) == 0
						aAdd(aTipos, cTipoAux)
					Endif

					cTipoAux := ""
					nX += nT
					nT := 0

				Next nX

				If !cTipoTit $ cTipos	//Nota fiscal
					//Caso seja uma NF vinculada a uma NCC ou RA
					For nX := 1 to Len(aTipos)
						If aTipos[nX] $ SE5->E5_DOCUMEN
							lVinculo := .T.
							Exit
						Endif
					Next nX

					If lVinculo
						If aScan(aTitulosTMP,{|x|(AllTrim(x[4]) $ cTipos) .AND. ;		//Tipo
							x[1] == Substr(SE5->E5_DOCUMEN,1,aTamChav[1]) .AND. ;				//Prefixo
							x[2] == Substr(SE5->E5_DOCUMEN,aTamChav[1]+1,aTamChav[2]) .AND. ;	//Numero
							x[3] == Substr(SE5->E5_DOCUMEN,aTamChav[1]+aTamChav[2]+1,aTamChav[3]) .AND. ;	//Parcela
							x[8] == SE5->E5_SEQ .AND. x[11] == .T. .and. x[13]==SE5->E5_FILIAL}) == 0												//Selecionado
							SE5->(dbSkip())
							Loop
						Endif
					Endif
				Else        //Antecipacao
					//Caso o titulo original seja de atencipacao e o tipo do registro atual seja diferente, sair
					If SE5->E5_TIPO # cTipoTit
						SE5->(dbSkip())
						Loop
					Else
						If aScan(aTitulosTMP,{|x| 	x[1] == Substr(SE5->E5_DOCUMEN,1,aTamChav[1]) .AND.;
							 x[2] == Substr(SE5->E5_DOCUMEN,aTamChav[1]+1,aTamChav[2]) .AND.;
							 x[3] == Substr(SE5->E5_DOCUMEN,aTamChav[1]+aTamChav[2]+1,aTamChav[3]) .AND.;
	 						 x[8] == SE5->E5_SEQ .AND. x[11]==.T. .and. x[13]==SE5->E5_FILIAL}) == 0
							SE5->(dbSkip())
							Loop
						Endif
					Endif
				Endif
				nOrdSE1	:= SE1->(IndexOrd())
				nRegSE1	:= SE1->(Recno())
				nTAbat := SumAbatRec(cPrefixo,cNum,cParcela,SE1->E1_MOEDA,"V",dBaixa)
				nTAbat += Iif(lIrPjBxCr, SE5->E5_VRETIRF,0)
				SE1->(dbSetOrder(nOrdSE1))
				SE1->(dbGoto(nRegSE1))
				nVlLiqTit:= SE1->E1_VALOR - nTAbat		// Valor do titulo - Abatimentos
				aDtMov	:=	{}
				aDtMov	:= {'','','','','',Dtoc(SE5->E5_DATA)}

				aAdd(aTitulos,{SE5->E5_PREFIXO,;
					SE5->E5_NUMERO,;
					SE5->E5_PARCELA,;
					SE5->E5_TIPO,;
					SE5->E5_LOJA,;
					DtoC(SE5->E5_DATA),;
					Substr(SE5->E5_DOCUMEN,1,nTamTit),;
					SE5->E5_SEQ,;
					Transform(nVlLiqTit,"@E 9999,999,999.99"),;
					Transform(SE5->E5_VLMOED2,"@E 9999,999,999.99"),;
					Iif(Fa330VldDt(aDtMov,nOpc),.T.,.F.),;
	 				    SE1->E1_FILIAL,;
	 				    SE5->E5_FILIAL})
				aAdd(aRegistros, SE5->(Recno()))
				SE5->(dbSkip())
			Enddo
			(cAliasCmp)->(dbSkip())
		Enddo

  		(cAliasCmp)->(DbCloseArea())
      	#IFDEF TOP
      	#ELSE
      	If cTrabalho <> Nil
			Ferase(cTrabalho+GetDBExtension())
			Ferase(cTrabalho+OrdBagExt())
		EndIf
		#ENDIF


  		IF lF330ExComp
			lF330Exclui := (ExecBlock( "F330EXCOMP", .F., .F.,{aTitulos,aRegistros,nOpc}))
			If lF330Exclui = .F.
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Recupera a Integridade dos dados           ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dbSelectArea( "SE1" )
				dbSetOrder( 1 )
				dbSelectArea( "SE5" )
				dbSetOrder( 1 )
				dbGoTo( nReg )
				DeleteObject(oOk)
				DeleteObject(oNo)
				FA330aUnlock()
				Return
			Endif
		Endif

		Begin Transaction

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Inicializa a gravacao dos lancamentos do SIGAPCO          ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		PcoIniLan("000016")

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Volta o valor aos RAs/NCCs	³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SE5")
		dbSetOrder( 2 )
		nRegSE1 := SE1->(Recno())
		nValorBaix := 0
		nValBaix2 := 0
		nValCtb	:= 0
		lPadrao := VerPadrao(cPadrao)
		If lPadrao
			lFirst := .T.
		EndIf

		For nLaco := 1 to Len(aRegistros)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Para saber se o titulo foi selecionado para estorno eh  |
			//³ necessario analisar o titulo no vetor aTitulosTMP pois a|
			//| flag do vetor aTitulos foi refeita e somente o vetor    |
			//| aTitulosTMP possui a flag informada pelo operador na    |
			//| interface grafica.(Projeto MPE)-Correcao Estorno Parcial|
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nPosTit := aScan(aTitulosTMP,{ |x| Alltrim(x[7]) + Alltrim(x[8]) ==  Alltrim(aTitulos[nLaco,1]+aTitulos[nLaco,2]+aTitulos[nLaco,3]) + Alltrim(aTitulos[nLaco,8]) .and. x[1]+x[2]+x[3] == aTitulos[nLaco,7] .AND. x[13] == aTitulos[nLaco,13]})
			If nPosTit > 0
				lMarcado :=  ( aTitulosTMP[nPosTit,11] .And. aTitulos[nLaco,11] )
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Caso o titulo esteja selecionado para compensa‡„o...    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If ( lMarcado )
				lMarcado := .F.
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ So monta o cabecalho do LP se acha pelo menos um³
				//³ registro marcado 										 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lFirst
					nHdlPrv := HeadProva( cLote,;
					                      "ZFINA330",;
					                      Substr( cUsuario, 7, 6 ),;
					                      @cArquivo )

					VALOR := 0
					lFirst:= .F.
				EndiF
				dbSelectArea("SE5")
				dbGoTo(aRegistros[nLaco])
				cDocumento	:= SubStr(SE5->E5_DOCUMEN,1,nTamTit+nTamTip)
				cSeq			:= SE5->E5_SEQ
				If lLjOrigem .Or. Empty(SE5->E5_FORNADT)	//executada por alguma rotina do SIGALOJA/FRT
					cCliAdt		:= Iif(Empty(SE5->E5_FORNADT) ,SE5->E5_CLIFOR,SE5->E5_FORNADT)
					cLojAdt		:= Iif(Empty(SE5->E5_LOJAADT), SE5->E5_LOJA, SE5->E5_LOJAADT)
				Else
					cCliAdt		:= SE5->E5_FORNADT
					cLojAdt		:= SE5->E5_LOJAADT
				EndIf
				//Acrescimos e Decrescimos do titulo principal
				If SE5->E5_VLJUROS > 0 .And. SE1->E1_ACRESC > 0
					nTitAcres	+= Round(NoRound(xMoeda(SE5->E5_VLJUROS,1,nMoeda,SE5->E5_DATA,3,,Fa330TxMd(nMoeda,SE5->E5_TXMOEDA,.T.)),3),2)
				Endif
				If SE5->E5_VLDESCO > 0 .And. SE1->E1_DECRESC > 0
					nTitDecre	+= Round(NoRound(xMoeda(SE5->E5_VLDESCO,1,nMoeda,SE5->E5_DATA,3,,Fa330TxMd(nMoeda,SE5->E5_TXMOEDA,.T.)),3),2)
				Endif
				
				//Desconto Financeiro do titulo principal
				If l330DESC
					lDESC := ExecBlock("F330DESC",.F.,.F.)
					If SE5->E5_VLDESCO > 0 .And. lDESC
						nDescP := IIf(SE1->E1_DESCFIN > 0 .And. SE1->E1_VENCREA-SE5->E5_DATA >= SE1->E1_DIADESC .and. SE1->E1_DESCONT != 0,SE1->E1_VALOR * (SE1->E1_DESCFIN/100),0)
					EndIf
				EndIf
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Localiza o t¡tulo RA/NCC correspondente			 ³
				//³ Para cancelar a baixa									 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Inicializa a chave de pesquisa com  ³
				//³ a filial padrÆo. Caso seja utilizada³
				//³ compensa‡Æo em outras filiais, ir   ³
				//³ utilizar-se do campo E5_FILORIG.    ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				cChaveSe1 := xFilial("SE1")+SubStr( SE5->E5_DOCUMEN ,1,nTamTit+nTamTip )
				If !Empty(SE5->E5_FILORIG) .And. ( !Empty( cFilFwSE1 ) .OR. !Empty( xFilial("SE1") ) )
					aDadosX := GetInfSE5(SE5->E5_DOCUMEN)
	                If (cTipoTit != aDadosX[4] .And. aDadosX[4] $ MV_CRNEG+"/"+MVRECANT) .OR. (cTipoTit $ MV_CRNEG+"/"+MVRECANT)
	    				cFilCred := FaPesqBx2(SE5->E5_FILIAL,aDadosX[1],aDadosX[2],aDadosX[3],cCliAdt,cLojAdt,aDadosX[4],SE5->E5_DATA,SE5->E5_SEQ,"R",SE5->E5_DOCUMEN,cTipoDc)
	    			Else
		      			cFilCred := FaPesqBx2(SE5->E5_FILIAL,aDadosX[1],aDadosX[2],aDadosX[3],SE5->E5_CLIFOR,aDadosX[5],aDadosX[4],SE5->E5_DATA,SE5->E5_SEQ,"R",SE5->E5_DOCUMEN,cTipoDc)
	    			EndIf
	    			If !Empty( cFilFwSE1 )
						cChaveSe1 := cFilCred+SubStr( SE5->E5_DOCUMEN ,1,nTamTit+nTamTip )
					Else
						cFilOld := cFilAnt
						cFilAnt := cFilCred
						cFilCred := xFilial("SE1")
						cChaveSe1 := cFilCred+SubStr( SE5->E5_DOCUMEN ,1,nTamTit+nTamTip )
						cFilAnt := cFilOld
					EndIf
				Endif

				aDoctosSE5 := {}
				dbSelectArea("SE1")
				dbSetOrder(1)
				dbSeek(cChaveSe1)
				lAchou := .F.
				// Localiza titulo referente ao cliente correto
				While !Eof() .And. Left(&(IndexKey()), Len(cChaveSe1)) == cChaveSe1
					// Encontrou o titulo do cliente
					If !Empty(cCliAdt) .and. mv_par02 == 1
						If (cCliAdt == SE1->E1_CLIENTE .And. ;
								cLojAdt == SE1->E1_LOJA)
							lAchou := .T.
							Exit
						EndIf
					Else
						lAchou := .T.
						Exit
					Endif
					DbSkip()
				Enddo

				// Se encontrou o titulo referente ao cliente correto, desfaz a compensacao
				If lAchou
					if lAcAtivo
						//verifica se permite realizar o estorno da compensação do titulo no GE
						If !AcFinCanc1()
							Exit
						EndIf
					EndIf
					nSaldoBx := SE1->E1_SALDO
					cAdiantamento := Substr(SE5->E5_DOCUMEN,1,nTamTit+nTamTip)
					cLojaCmp      := If( Empty(Substr(SE5->E5_DOCUMEN,nTamTit+nTamTip+1,nTamLoj)),;
												SE5->E5_LOJA,Substr(SE5->E5_DOCUMEN,nTamTit+nTamTip+1,nTamLoj))

					If !lRartImp .And. !lCredito .And. ( MV_PAR08 == 1 .Or. lBq10925 ) .And. lIrPjBxCr 
						nIrrfPac += SE5->E5_VRETIRF
					EndIf

					RecLock("SE1", .F.)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ a Verificacao da moeda ‚ feita para que caso o  ³
					//³ RA tenha moeda diferente do titulo principal, 	 ³
					//³ volte o valor correto ao saldo.               	 ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

					nSe5Rec := SE5->( RECNO() )

					If lRartImp .And. lPccBaixa
					   nValPcc := 0
					   nValPcc := SE5->(E5_VRETPIS+E5_VRETCOF+E5_VRETCSL)
					Endif

					SE5->( dbSetOrder(7) )
					SE5->( dbSeek(aTitulos[nLaco][13]+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO+SE1->E1_CLIENTE+SE1->E1_LOJA+cSeq) )
					
					//Desconto Financeiro do titulo principal
					If l330DESC
						lDESC := ExecBlock("F330DESC",.F.,.F.)
						If SE5->E5_VLDESCO > 0 .And. lDESC
							nDescD := IIf(SE1->E1_DESCFIN > 0 .And. SE1->E1_VENCREA-SE5->E5_DATA >= SE1->E1_DIADESC .and. SE1->E1_DESCONT != 0,SE1->E1_VALOR * (SE1->E1_DESCFIN/100),0)
						EndIf
					EndIf

					VALOR3 := 0
					VALOR4 := 0
					VALOR5 := 0
					VALOR6 := 0
					VALOR7 := 0
					VALOR8 := 0

					If cPaisLoc == "BRA"
						//Se o cancelamento da compensacao NAO partiu do Titulo de Credito
						If !lCredito
							lIsNcc := SE5->E5_TIPO $ MV_CRNEG
						Else
							// Desfaz comissoes calculadas para adiantamentos ou notas de credito
							If (MV_PAR06 == 1 .And. Substr(SE5->E5_DOCUMEN,nTamTit+1,nTamTip) $ MV_CRNEG) .Or.;
								(MV_PAR13 == 1 .And. Substr(SE5->E5_DOCUMEN,nTamTit+1,nTamTip) $ MVRECANT)
								aadd(aBaixas,{SE5->E5_MOTBX,SE5->E5_SEQ,SE5->(Recno())})
							Endif
						Endif

						If lPropBx .and. lCredito .And. cPaisLoc == "BRA" 
							If !lPccBxCr
								nAbat	+= SE5->E5_VRETPIS + SE5->E5_VRETCOF + SE5->E5_VRETCSL 
								nVretPis	:= SE5->E5_VRETPIS
								nVretCof	:= SE5->E5_VRETCOF
								nVretCsl	:= SE5->E5_VRETCSL
							EndIf
							If	!lIrPjBxCr
								nAbat	+= SE5->E5_VRETIRF
								nVretIrf	:= SE5->E5_VRETIRF 
							EndIf
							nAbat		+= SE5->E5_VRETINS + SE5->E5_VRETISS
							nVretIns	:= SE5->E5_VRETINS
							nVretiss	:= SE5->E5_VRETISS
						EndIf
						
						//Cancelamento partiu de um adiantamento
						If lImpComp .and. lIsNcc .and. lPccBaixa
							nRecnoSE1 := IIF(!lCredito, nRecnoSE1,SE1->(RECNO()))
							//Acerto valor dos impostos - Tecnofibras
							F330ActImp(nRecnoSE1,SE5->E5_VALOR,0,0,.F.,lCredito,0)
						Endif

						RecLock("SE1", .F.)

						//******************************************
						// Caso o titulo esteja totalmente baixado *
						// recupera os impostos para o saldo.      *
						//******************************************
						nTotAbat := 0
						cFilOld := cFilAnt
						If lCredito .and. SE1->E1_SALDO==0
						    If lSE1Exclusivo
						   		cFilAnt := SE1->E1_FILIAL
						    Else
						   		If lGestao
						   			nRecSM0 := SM0->(Recno())
									If "E" $ FWSM0Layout() .Or. "U" $ FWSM0Layout()  //se tem empresa ou unidade de negocio no layout
										If ! ( Alltrim( SE1->E1_FILIAL ) $ cFilAnt )
											SM0->( dbGoTop() )
											While SM0->(!Eof() .and. M0_CODIGO == cEmpAnt .and. IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL ) <= "ZZZZZZ")
												cFilAnt := IIf( lFWCodFil, FWGETCODFILIAL, SM0->M0_CODFIL )
												If Alltrim(SE1->E1_FILIAL) $ cFilAnt
													Exit
												EndIf
												SM0->( dbSkip() )
											EndDo
										EndIf
									EndIf
									SM0->( dbGoto(nRecSM0) )
								EndIf
						    EndIf
							//Tratamento de retorno do Pis Cofins - Tecnofibras
							If !lRaRtImp .OR. lIsNCC
								nTotAbat := SumAbatRec(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_MOEDA,"V",dBaixa)
							Else
								nTotAbat := 0
							Endif
						EndIf
						cFilAnt := cFilOld
						If (lIrPjBxCr .and. SE1->E1_SALDO==0) .or. SE5->E5_VRETIRF > 0
							nTotAbat+= SE5->E5_VRETIRF
						EndIf
						If lPccBaixa
							If SE5->E5_TIPO <> MVRECANT .AND. SE5->E5_TIPO <> MV_CRNEG .AND. ( lRaRtImp .Or. lBQ10925 )
								nTotAbat+= SE5->E5_VRETPIS + SE5->E5_VRETCOF + SE5->E5_VRETCSL
							Endif
				  		EndIf
					  	If lRaRtImp .and. lCredito
					  		nTotAbat+= SE5->E5_PRISS + SE5->E5_PRINSS
					  	Endif
						If lRartimp .And. lPccBxCr
							nVlNewPis += (  SE5->E5_VRETPIS )
							nVlNewCof += (  SE5->E5_VRETCOF )
							nVlNewCsl += (  SE5->E5_VRETCSL )
							nVlNewIrf += (  SE5->E5_VRETIRF )
						Endif
						
						If lPropBx .and. lCredito
							If mv_par08 == 2 .and. !lRartImp
								SE1->E1_SALDO += SE5->E5_VALOR
							Else
								SE1->E1_SALDO += SE5->E5_VALOR + nAbat
							EndIf
						ElseIf (SE1->E1_MOEDA > 1 .AND. nMoeda == 1) .or. (SE1->E1_MOEDA == 1 .AND. nMoeda > 1) .or. (SE1->E1_MOEDA > 1 .AND. nMoeda > 1) // nMoeda > 1
							SE1->E1_SALDO += SE5->E5_VLMOED2 + nTotAbat
						ElseIf (!lRartImp .and. MV_PAR08 == 2)
							SE1->E1_SALDO += SE5->E5_VALOR
						Else
							SE1->E1_SALDO += SE5->E5_VALOR + nTotAbat
						EndIf
						If (SE1->E1_VALOR+SE1->E1_ACRESC-SE1->E1_DECRESC) < (SE1->E1_SALDO+SE1->E1_SDACRES-SE1->E1_SDDECRE)
							SE1->E1_SALDO := SE1->E1_VALOR
						Endif
						nTotAbat := 0
						//Verifica se o titulo já possui impostos gerados pela rotina de Borderô de Recebimento de Imposto (FINA061).
						nPisFina061	:=	0
						nCofFina061	:=	0
						nCslFina061	:=	0
						nIrfFina061	:=	0
						nVAbat		:=  0
						nRegSE5	:=	SE5->(Recno())
						nOrdSE5	:=	SE5->(IndexOrd())		
					
						If SE1->E1_TIPO <> MVRECANT .AND. SE1->E1_TIPO <> MV_CRNEG .And. (lPccBxCr .Or. lIrPjBxCr)
							dbSelectArea("SE5")
							SE5->(dbSetOrder(2)) //FILIAL + TIPODOC + PREFIXO + NUMERO + PARCELA + TIPO
							If SE5->(DBSeek(xFilial("SE5")+"BA"+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO))
								While !SE5->(Eof()) .and. SE5->E5_FILIAL==xFilial("SE5") .And. ;
									SE5->E5_TIPODOC+SE5->E5_PREFIXO+SE5->E5_NUMERO+SE5->E5_PARCELA+SE5->E5_TIPO=="BA"+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO		
								
									If ("FINA061" $ Subst(SE5->E5_HISTOR,1,7)) .And. SE5->E5_MOTBX $ "PCC_IRF"						
										If Alltrim(SE5->E5_MOTBX) == "PCC"
										   nPisFina061	+= SE5->E5_VRETPIS
										   nCofFina061	+=	SE5->E5_VRETCOF
										   nCslFina061	+= SE5->E5_VRETCSL
										ElseIf Alltrim(SE5->E5_MOTBX) == "IRF"
										   nIrfFina061	+= SE5->E5_VRETIRF
										Endif
									Endif					
									SE5->(DbSkip())		
							   Enddo
							Endif
						Endif
					   SE5->(Dbgoto(nRegSE5))
						SE5->(Dbsetorder(nOrdSE5))														   					   												
						
						//Cancelamento partiu de um adiantamento
						If lCredito
							/////////////////////
							//PCC Baixa CR          to do
							//Retorna para o saldo do titulo o valor retido do PCC
							If cPaisLoc == "BRA" .and. lPccBxCr .and. !lIsNcc
								nVlNf	:= SE1->E1_VALOR
								If EMPTY(SE5->E5_PRETPIS)
									If !(mv_par08 == 2 .and. !lRartImp) .and. nTotAbat <> 0
									SE1->E1_SALDO += SE5->E5_VRETPIS
									EndIf
									VALOR3 := SE5->E5_VRETPIS
									nVlPis	+= SE5->E5_VRETPIS
								EndIf
								If EMPTY(SE5->E5_PRETCOF)
									If !(mv_par08 == 2 .and. !lRartImp) .and. nTotAbat <> 0
									SE1->E1_SALDO += SE5->E5_VRETCOF
									EndIf
									VALOR4 := SE5->E5_VRETCOF
									nVlCof	+= SE5->E5_VRETCOF
								Endif
								If EMPTY(SE5->E5_PRETCSL)
									If !(mv_par08 == 2 .and. !lRartImp) .and. nTotAbat <> 0				
									SE1->E1_SALDO += SE5->E5_VRETCSL
									EndIf
									VALOR5 := SE5->E5_VRETCSL
									nVlCsll	+= SE5->E5_VRETCSL
								Endif
								If EMPTY(SE5->E5_PRETIRF)
									nVlIrrf	+= SE5->E5_VRETIRF
								EndIf							
							    VALOR6 := SE1->E1_INSS
								//cancelar SFQ
								//Escluir titulos PCC
								FaDelSFQCR()
							Endif
							
								/*
							Atualiza o status do titulo no SERASA */
							If cPaisLoc == "BRA"
								If nSaldoBx == 0
								cChaveTit := xFilial("SE1")	+ "|" +;
											SE1->E1_PREFIXO	+ "|" +;
											SE1->E1_NUM		+ "|" +;
											SE1->E1_PARCELA	+ "|" +;
											SE1->E1_TIPO		+ "|" +;
											SE1->E1_CLIENTE	+ "|" +;
											SE1->E1_LOJA
								cChaveFK7 := FINGRVFK7("SE1",cChaveTit)
								F770BxRen("3","",cChaveFK7)
							Endif
							Endif

							If (SE1->E1_VALOR+SE1->E1_ACRESC-SE1->E1_DECRESC) < (SE1->E1_SALDO+SE1->E1_SDACRES-SE1->E1_SDDECRE)
								SE1->E1_SALDO := SE1->E1_VALOR
							Endif

						Endif
						//QUESTAO DE ARREDONDAMENTO
						If ABS(SE1->E1_VALOR - xMoeda(SE5->E5_VLMOED2,nMoeda,SE1->E1_MOEDA,SE5->E5_DATA,3) - (nTotAbat + nDecres - nAcresc + nDescD)) <= 0.0099999
							SE1->E1_SALDO := SE1->E1_VALOR
						Endif
						SE1->E1_VALLIQ:= 0
						If (nPisFina061+nCofFina061+nCslFina061+nIrfFina061)> 0 
					   	//O Pcc neste momento já foi subtraido do valor do saldo faltando somente o IR.
					   	If mv_par08 = 2
						   	SE1->E1_SALDO	-= (nIrfFina061+nPisFina061+nCofFina061+nCslFina061)
						   Endif	
					   	SE1->E1_VALLIQ	+= nPisFina061+nCofFina061+nCslFina061+nIrfFina061		
						Endif																																		
					Else
						If (MV_PAR06 == 1 .And. Substr(SE5->E5_DOCUMEN,nTamTit+1,nTamTip) $ MV_CRNEG) .Or.;
							(MV_PAR13 == 1 .And. Substr(SE5->E5_DOCUMEN,nTamTit+1,nTamTip) $ MVRECANT)
								aadd(aBaixas,{{SE5->E5_MOTBX,SE5->E5_SEQ,SE5->(Recno())}})
						Endif
						RecLock("SE1", .F.)
						nDecs := MsDecimais(nMoeda)
						nTxMoeda := Round(SE5->E5_VALOR/SE5->E5_VLMOED2,2)
						If  Empty(SE5->E5_MOEDA)
							SE1->E1_SALDO  += Round(xMoeda(SE5->E5_VLMOED2,nMoeda,SE1->E1_MOEDA,SE5->E5_DATA,nDecs+1,nTxMoeda),nDecs)
							SE1->E1_VALLIQ -= Round(xMoeda(SE5->E5_VLMOED2,nMoeda,1,SE5->E5_DATA,nDecs1+1,nTxMoeda),nDecs1)
					    Else
							SE1->E1_VALLIQ:= 0
					    	If (SE1->E1_MOEDA > 1 .AND. nMoeda == 1) .or. (SE1->E1_MOEDA == 1 .AND. nMoeda > 1) .or. (SE1->E1_MOEDA > 1 .AND. nMoeda > 1) // nMoeda > 1
								SE1->E1_SALDO += SE5->E5_VLMOED2
							Else
								SE1->E1_SALDO += SE5->E5_VALOR
							Endif
					    EndIf
					    If  nMoeda <> SE1->E1_MOEDA   .And.  Abs(SE1->E1_SALDO - SE1->E1_VALOR) == 0.01
							SE1->E1_SALDO := SE1->E1_VALOR
						EndIf
					EndIf
					
					SE5->( dbGoto(nSE5Rec) )
					
					If SUBSTR(SE5->E5_LA,1,1) == "S"
		      			nValCtb += SE5->E5_VALOR
					Endif
					nValorBaix	  += SE5->E5_VALOR + nTitDecre - nTitAcres + nDescD
					nValBaix2	  += SE5->E5_VLMOED2 + Round(NoRound(xMoeda(SE5->E5_VLDESCO - SE5->E5_VLJUROS,1,nMoeda,SE5->E5_DATA,3,,Fa330TxMd(nMoeda,nTxMoeda)),3),2)

					If lImpComp .and. lPccBaixa
						If !lCredito .and. SE1->E1_SALDO == 0
							nValorBaix	+= SE5->E5_VRETPIS + SE5->E5_VRETCOF + SE5->E5_VRETCSL
							nValBaix2	+= SE5->E5_VRETPIS + SE5->E5_VRETCOF + SE5->E5_VRETCSL
						Endif
					Endif
					If lIrPjBxCr .or. SE5->E5_VRETIRF > 0
						If SE5->E5_TIPO <> MVRECANT .AND. SE5->E5_TIPO <> MV_CRNEG .AND. (MV_PAR08 == 1 .or.lRaRtImp)
					   		nVlrAbat	+= SE5->E5_VRETIRF
					   		nVAbat :=  SE5->E5_VRETIRF
						Endif
					EndIf
					If lPccBaixa
						If SE5->E5_TIPO <> MVRECANT .AND. SE5->E5_TIPO <> MV_CRNEG .AND. ( lRaRtImp .Or. lBq10925 )
					   		nVlrAbat	+= SE5->E5_VRETPIS + SE5->E5_VRETCOF + SE5->E5_VRETCSL
					   		nVAbat += SE5->E5_VRETPIS + SE5->E5_VRETCOF + SE5->E5_VRETCSL	
					   		If !lRartImp .and. mv_par08 == 2 .and. SE1->E1_SALDO <> SE1->E1_VALOR
					   			SE1->E1_SALDO -= nVlrAbat
					   		ElseIf !lRartImp .and. mv_par08 == 1 .and. SE1->E1_SALDO <> SE1->E1_VALOR //.and. lCredito
					   			SE1->E1_SALDO += nVAbat
					   			If !lIrPjBxCr .and. nTabat > 0 .and. (SE1->E1_SALDO - SE5->E5_VALOR - nVlrAbat - nTabat == 0 .or. SE1->E1_SALDO + nTabat == SE1->E1_VALOR)
				   				 SE1->E1_SALDO += nTabat
				   			EndIf
					   		EndIf
						Endif
					EndIf
					If lPropBx .and. !lCredito .And. cPaisLoc == "BRA"
						If !lPccBxCr
							nAbat	+= SE5->E5_VRETPIS + SE5->E5_VRETCOF + SE5->E5_VRETCSL 
							nVretPis	:= SE5->E5_VRETPIS
							nVretCof	:= SE5->E5_VRETCOF
							nVretCsl	:= SE5->E5_VRETCSL
						EndIf
						If	!lIrPjBxCr
							nAbat	+= SE5->E5_VRETIRF
							nVretIrf	:= SE5->E5_VRETIRF 
						EndIf
						nAbat		+= SE5->E5_VRETINS + SE5->E5_VRETISS
						nVretIns	:= SE5->E5_VRETINS
						nVretiss	:= SE5->E5_VRETISS
					EndIf
					If lRaRtImp
						nVlrAbat	+= SE5->E5_PRISS + SE5->E5_PRINSS
					Endif

					SE1->(MsUnlock())
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Grava lançamento no PCO ref titulo compensado apos canc. da compensacao   ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					PCODetLan("000016","02","ZFINA330") //alteracao do titulo compensado

					nSe1Rec := SE1->(RECNO())
					cKeyAbt := SE1->(E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA)
					cFilSe1 := SE1->E1_FILIAL
					cTipo:= SE1->E1_TIPO
					//Atualiza o status de viagem
					If (ALLTRIM(SE1->E1_ORIGEM) == "FINA677")
						FINATURES(SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA),.F.,SE1->E1_ORIGEM,"R")
					Endif
					aAreaSE5 	:= SE5->(GetArea())
					aAreaSE1		:=	SE1->(GetArea())
					
					//Cancelamento da baixa dos abatimentos do titulo principal
					//quando cancelamento partiu do titulo de adiantamento
					If lCredito   //Se nao for titulo de adiantamento
						dbSelectArea("__SE1")
						__SE1->(dbSetOrder(2))
						__SE1->(dbSeek(cFilSE1+cKeyAbt))
						If lTitpaiSE1
  							__SE1->(DbSetOrder(nOrdTitPai))
							If	DbSeek(cChaveSe1+__SE1->E1_CLIENTE+__SE1->E1_LOJA)
								bWhile := {|| !Eof() .And. E1_FILIAL + Trim(E1_TITPAI) == Trim(cChaveSe1+__SE1->E1_CLIENTE+__SE1->E1_LOJA) }
							Else
					   			__SE1->(dbSetOrder(2))
					 			__SE1->(dbSeek(cFilSe1+cKeyAbt))
							Endif
						Endif

						While Eval(bWhile)
							If lTitpaiSE1
								If !Empty(E1_TITPAI) .and.  (  trim(E1_TITPAI)!=trim(cAdiantamento+__SE1->E1_CLIENTE+__SE1->E1_LOJA) )
									DbSkip()
									Loop
								EndIf
							EndIf

							lPccComp := .T. //Verificando IR,INSS e ISS gerados na emissao ou PCC gerado na compensacao.
							If lPccBaixa
								aAreaSE5 	:= SE5->(GetArea())
								aAreaSE1		:=	SE1->(GetArea())

								cChaveSE5	:= xFilial("SE5") + If(SE1->E1_TIPO $ "COF/CSL/PIS","CP",Subst(SE1->E1_TITPAI,14,2)) + Subst(SE1->E1_TITPAI,1,3) + Subst(SE1->E1_TITPAI,4,9) +Subst(SE1->E1_TITPAI,13,1)
								If SE5->(dbSeek(cChaveSE5))
									IF SE1->E1_TIPO $ "IR-/IN-/IS-" .AND. Alltrim(SE1->E1_SEQBX) <> Alltrim(SE5->E5_SEQ)
						  	  			lPccComp := .F.
									ElseIf SE1->E1_TIPO $ "COF/CSL/PIS" .AND. lPccBaixa //PCC gerado na compensacao.
										lBxCanc	:= TemBxCanc(SE5->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ),.T.,SE5->E5_FILIAL)
										If (lBxCanc .AND. Alltrim(SE1->E1_SEQBX) == Alltrim(SE5->E5_SEQ)) //.OR. (!lBxCanc .AND. Alltrim(SE1->E1_SEQBX) <> Alltrim(SE5->E5_SEQ))
							 				lPccComp := .F.
							 			Endif
									Endif
								Endif

								SE5->(RestArea(aAreaSE5))
								SE1->(RestArea(aAreaSE1))
							Endif

							If (((__SE1->E1_TIPO $ "IR-|IN-|IS-|CF-|CS-|PI-" .AND. lPccBaixa .AND. lPccComp) .OR. __SE1->E1_TIPO $ MVABATIM ) .And. Alltrim(__SE1->E1_CLIENTE+__SE1->E1_LOJA) == Alltrim(SE1->E1_CLIENTE+SE1->E1_LOJA))
								//Tornar o abatimento aberto novamente somente caso o abatimento tenha sido baixado pela rotina

									nVlrAbat += E1_VALOR
									RecLock("__SE1")
									
									If !lPropBx
									Replace E1_SALDO	With E1_VALOR
									Else
										Do Case
											Case E1_TIPO $ MVPIABT .and. !lPCCBaixa
												Replace E1_SALDO	With (E1_SALDO + nVretPis)
											Case E1_TIPO $ MVCFABT .and. !lPCCBaixa 
												Replace E1_SALDO	With (E1_SALDO + nVretCof)
											Case E1_TIPO $ MVCSABT .and. !lPCCBaixa
												Replace E1_SALDO	With (E1_SALDO + nVretCsl)
											Case E1_TIPO $ MVIRABT .and. !lIrPjBxCr
												Replace E1_SALDO	With (E1_SALDO + nVretIrf)
											Case E1_TIPO $ MVINABT 				
												Replace E1_SALDO	With (E1_SALDO + nVretIns)
											Case E1_TIPO $ MVISABT   				
												Replace E1_SALDO	With (E1_SALDO + nVretIss)
										EndCase
									EndIf
									Replace E1_BAIXA	With CtoD("  /  /  ")
									Replace E1_STATUS	With "A"
									Replace E1_VALLIQ  With 0
									MsUnlock()
							Endif
							dbSkip()
						Enddo
						__SE1->(dbSetOrder(1))
					Endif
					If lAcAtivo
						//Realiza a consequencia do cancelamento da baixa do titulo no GE
						AcFinCanc2()
					EndIf
					dbSelectArea("SE1")
					dbGoto(nSE1Rec)
					// Trecho irá deletar o titulo do IRF quando selecionada os titulos de adianamento para estorno
					If lIrPjBxCr .And. !lRartImp // .and. SE1->E1_TIPO <> MVRECANT .AND. SE1->E1_TIPO <> MV_CRNEG
	  					FaDelSFQCR()
					Endif
					dbSelectArea("SE1")
					dbGoto(nSE1Rec)

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Deleta a baixa do SE5	-  RA		³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					dbSelectArea("SE5")
					dbSetOrder(2)

					If (dbSeek(aTitulos[nLaco][13]+cTipodc+cDocumento))
						While ( 	!Eof() .And. SE5->E5_FILIAL == aTitulos[nLaco][13] .And. ;
								cDocumento ==	SE5->E5_PREFIXO+SE5->E5_NUMERO+;
								SE5->E5_PARCELA+SE5->E5_TIPO )
							If (  cSeq == SE5->E5_SEQ .And. cLojaCmp == SE1->E1_LOJA .And. ;
									SE1->E1_CLIENTE == SE5->E5_CLIFOR .and. ;
									Substr(SE5->E5_DOCUMEN,1,nTamTit+nTamTip)==cPrefixo+cNum+cParcela+cTipoTit )
								AADD(aDoctosSE5,{SE5->E5_DOCUMEN,SE1->E1_CLIENTE,SE1->E1_LOJA,SE5->E5_SEQ})

								//Atualiza dados do Cliente - Adiantamento
								dbSelectArea("SA1")
								DbSetOrder(1)
								If dbSeek(xFilial("SA1")+SE5->E5_CLIFOR+SE5->E5_LOJA)
									If lGrvSa1	
										RecLock("SA1")
										nSaldoComp:=Round(xMoeda(SE5->E5_VLMOED2,nMoeda,SE1->E1_MOEDA,SE5->E5_DATA,nDecs+1,Fa330TxMd(nMoeda,nTxMoeda),Fa330TxMd(SE1->E1_MOEDA,nTxMoeda)),nDecs)
										If SE1->E1_TIPO $ MVRECANT +"/"+ MV_CRNEG
											AtuSalDup("-",nSaldoComp,nMoeda,SE1->E1_TIPO,,SE1->E1_EMISSAO)
										Else
						   		   			AtuSalDup("+",nSaldoComp,nMoeda,SE1->E1_TIPO,,SE1->E1_EMISSAO)
		   								EndIf
									EndIf
								EndIf

								//Dados do titulo de adiantamento
								dbSelectArea("SE1")
								dbGoto(nSE1Rec)
								RecLock("SE1")
								nAcresc := Round(NoRound(xMoeda(SE5->E5_VLJUROS,1,SE1->E1_MOEDA,SE5->E5_DATA,3,,Fa330TxMd(SE1->E1_MOEDA,SE5->E5_TXMOEDA,.T.)),3),2)
								nDecres := Round(NoRound(xMoeda(SE1->E1_DECRESC,1,SE1->E1_MOEDA,SE5->E5_DATA,3,,Fa330TxMd(SE1->E1_MOEDA,SE5->E5_TXMOEDA,.T.)),3),2)
								SE1->E1_SALDO += nDecres - nAcresc + nDescD
								//QUESTAO DE ARREDONDAMENTO
								If ABS(SE1->E1_VALOR - xMoeda(SE5->E5_VLMOED2,nMoeda,SE1->E1_MOEDA,SE5->E5_DATA,3) - (nTotAbat + nDecres - nAcresc + nDescD)) <= 0.0099999 .AND. !lLjOrigem
									If (nPisFina061+nCofFina061+nCslFina061+nIrfFina061) == 0
									SE1->E1_SALDO := SE1->E1_VALOR
								Endif
								Endif
								SE1->E1_STATUS:= IIF(SE1->E1_STATUS != "R",Iif(SE1->E1_SALDO > 0.01,"A","B"),"R")
								If SE1->E1_DECRESC >0 .or. SE1->E1_ACRESC >0
								SE1->E1_SDACRES += nAcresc
								SE1->E1_SDDECRE += nDecres
								EndIf
								
								// Desconto Financeiro
								SE1->E1_DESCONT -= nDescD
								
								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³ So limpa a data da baixa se nao houver mais 	 ³
								//³ nenhum movimento para este titulo					 ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								If NoRound( SE1->E1_VALOR, 2 ) == NoRound( SE1->E1_SALDO, 2 )
									SE1->E1_BAIXA := CtoD("  /  /  ")
								EndIf
								If lIrPjBxCr// .and. SE1->E1_TIPO <> MVRECANT .AND. SE1->E1_TIPO <> MV_CRNEG
			  				   		FaDelSFQCR()
								Endif
								MsUnlock()
								//Atualiza o status de viagem

								// Desfaz comissoes calculadas para adiantamentos ou notas de credito
								If (MV_PAR06 == 1 .And. Substr(SE5->E5_DOCUMEN,nTamTit+1,nTamTip) $ MV_CRNEG) .Or.;
									(MV_PAR13 == 1 .And. Substr(SE5->E5_DOCUMEN,nTamTit+1,nTamTip) $ MVRECANT) 
									If cPaisLoc<>"BRA"
										aadd(aBaixas,{{SE5->E5_MOTBX,SE5->E5_SEQ,SE5->(Recno())}})
									else
										aadd(aBaixas,{SE5->E5_MOTBX,SE5->E5_SEQ,SE5->(Recno())})
									Endif
								Endif
								
								If nOpc == 4  //Exclusao

									SE5->(DbSelectarea("SE5"))
									Fin330ExCM(SE5->E5_FILIAL, SE5->E5_SEQ)

								endif
								oModelBA := FWLoadModel("FINM010")
								//Posiciona a FK1 para mandar a operação de alteração com base no registro posicionado da SE5
								If AllTrim( SE5->E5_TABORI ) == "FK1"
									dbSelectArea( "FK1" )
									FK1->( DbSetOrder( 1 ) )
									If MsSeek( xFilial("FK1") + SE5->E5_IDORIG )
										
										oModelBA:SetOperation( 4 ) //Alteração
										oModelBA:Activate()
										oModelBA:SetValue( "MASTER", "E5_GRV", .T. ) //Habilita gravação SE5
										//E5_OPERACAO 1 = Altera E5_SITUACA da SE5 para 'C' e gera estorno na FK1
										//E5_OPERACAO 2 = Altera E5_TIPODOC da SE5 para 'ES' e gera estorno na FK1
										//E5_OPERACAO 3 = Deleta da SE5 e gera estorno na FK1
										//if nOpc <> 4 // se não for para deletar definir um hitorico para o Estorno
										//	oSubFK1 := oModelMov:GetModel("FK1DETAIL")
										//	oSubFK1:SetValue( "FK1_HISTOR", STR0055)
										//ENDIF
										//Manda o campo LA com o valor de 2 Caracteres, para manter a gravação original na E5
										cCamposE5 := '{'
										cCamposE5 += "{'E5_Data', dDataBase}"
										
										If !Empty( SE5->( FieldPos( "E5_MSEXP" ) ) ) 
											cCamposE5 += ",{'E5_MSEXP', ''}"
										EndIf
										
										If MV_PAR09 == 1 .and. !lUsaFlag
											cCamposE5 += ",{'E5_LA', 'S"  + SubStr( SE5->E5_LA, 2, 1 ) + "'}"
										Endif

										If UsaSeqCor()
											cCamposE5 += ",{'E5_NODIA', ''}"
										endif
										cCamposE5 += "}"
										
										oSubFKA := oModelBA:GetModel( "FKADETAIL" )
										oSubFKA:SeekLine( { {"FKA_IDORIG", SE5->E5_IDORIG } } )
										
										oModelBA:SetValue( "MASTER", "E5_CAMPOS", cCamposE5 ) //Informa os campos da SE5 que serão gravados indepentes de FK1
										oModelBA:SetValue( "MASTER", "E5_OPERACAO",If(nOpc == 4, 3, 2) ) //E5_OPERACAO 3 = Deleta da SE5 e gera estorno na FK1
										oModelBA:SetValue( "MASTER", "HISTMOV" , STR0055 )
            
										If oModelBA:VldData()
									       	oModelBA:CommitData()
									       	SE5->(dbGoto(oModelBA:GetValue( "MASTER", "E5_RECNO" )))
									       	if nOpc <> 4
	       										If MV_PAR09 == 1 .and. lUsaFlag
													aAdd( aFlagCTB, {"E5_LA", "S", "SE5", SE5->(RECNO()), 0, 0, 0} )
												EndIf

  								  				If UsaSeqCor()
					 								AAdd(aDiario,{"SE5",SE5->(RECNO()),SE5->E5_DIACTB,"E5_NODIA","E5_DIACTB"})
				  								EndIf
                                            endif
										Else
											lRet := .F.
										    cLog := cValToChar(oModelBA:GetErrorMessage()[4]) + ' - '
									    	cLog += cValToChar(oModelBA:GetErrorMessage()[5]) + ' - '
	    							   		cLog += cValToChar(oModelBA:GetErrorMessage()[6])
							       			Help( ,,"M330VALID",,cLog, 1, 0 )
										EndIf
									EndIf
								Endif
								oModelBA:DeActivate()
								oModelBA:Destroy()
								oModelBA:=nil	

								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³ Grava lançamento no PCO ref canc. baixa do titulo compensado (Mov.Bancaria-SE5) ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								If nOpc == 4
									PCODetLan("000016","06","ZFINA330")
								Endif
							EndIF
							dbSkip()
						EndDo
					Endif
					DbSelectArea("SE1")
					SE1->(DbSetOrder(1))
					
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Restaura o t¡tulo abatimento qdo houver    ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If SE1->(dbSeek(xFilial("SE1")+cPrefixo+cNum+cParcela,.F.))
					    			/*
						Atualiza o status do titulo no SERASA */
						If cPaisLoc == "BRA"
							If !lCredito
								If SE1->E1_SALDO == 0
								cChaveTit := xFilial("SE1")	+ "|" +;
											SE1->E1_PREFIXO	+ "|" +;
											SE1->E1_NUM		+ "|" +;
											SE1->E1_PARCELA	+ "|" +;
											SE1->E1_TIPO		+ "|" +;
											SE1->E1_CLIENTE	+ "|" +;
											SE1->E1_LOJA
								cChaveFK7 := FINGRVFK7("SE1",cChaveTit)
								F770BxRen("3","",cChaveFK7)
							Endif
						Endif
						Endif
						If lTitpaiSE1
					 		If (nOrdTitPai:= OrdTitpai()) > 0
	   							SE1->(DbSetOrder(nOrdTitPai))
								If	SE1->(DbSeek(xFilial("SE1")+cChavePai))
									bWhile2 := {|| !Eof() .And. E1_FILIAL +Trim(E1_TITPAI) == xFilial("SE1")+If(!lcredito,trim(cChavePai), cChaveSE1)}
								Else
									SE1->(DbSetOrder(1))
								Endif
							Endif
						Else
							cFilSE1 := xFilial("SE1")
						Endif
						DbSelectArea("SE1")
						While Eval(bWhile2)

							If lTitpaiSE1
								If !Empty(E1_TITPAI).and. (alltrim(E1_TITPAI)!=If(!lcredito,alltrim(cChavePai), cChaveSE1))
									SE1->(DbSkip())
									Loop
								EndIf
							EndIf

							lPccComp := .T. //Verificando IR,INSS e ISS gerados na emissao ou PCC gerado na compensacao.
							If lPccBaixa
								aAreaSE5 	:= SE5->(GetArea())
								aAreaSE1	:=	SE1->(GetArea())

								cChaveSE5	:= xFilial("SE5") + If(SE1->E1_TIPO $ "COF/CSL/PIS","CP",Subst(SE1->E1_TITPAI,14,2)) + Subst(SE1->E1_TITPAI,1,3) + Subst(SE1->E1_TITPAI,4,9) +Subst(SE1->E1_TITPAI,13,1)
								If SE5->(dbSeek(cChaveSE5))
									IF SE1->E1_TIPO $ "IR-/IN-/IS-" .AND. Alltrim(SE1->E1_SEQBX) <> Alltrim(SE5->E5_SEQ)
						  	  			lPccComp := .F.
									ElseIf SE1->E1_TIPO $ "COF/CSL/PIS" .AND. lPccBaixa //PCC gerado na compensacao.
										lBxCanc	:= TemBxCanc(SE5->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ),.T.)
										If (lBxCanc .AND. Alltrim(SE1->E1_SEQBX) == Alltrim(SE5->E5_SEQ)) //.OR. (!lBxCanc .AND. Alltrim(SE1->E1_SEQBX) <> Alltrim(SE5->E5_SEQ))
							 				lPccComp := .F.
							 			Endif
									Endif
								Endif

								SE5->(RestArea(aAreaSE5))
								SE1->(RestArea(aAreaSE1))
							Endif

							If (((SE1->E1_TIPO $ "COF/CSL/PIS/IR-/IN-/IS-/CF-/CS-/PI-/" .AND. lPccBaixa .AND. lPccComp) .OR. E1_TIPO $ MVABATIM ) .And. Alltrim(cCliente+cLoja) == Alltrim(SE1->E1_CLIENTE+SE1->E1_LOJA))
									//Tornar o abatimento aberto novamente somente caso o abatimento tenha sido baixado pela rotina
									If cSeq <> SE1->E1_SEQBX .and. !Empty(SE1->E1_SEQBX)
										SE1->(dbSkip())
										Loop
									Endif

										//Caso os impostos do PCC e IR sejam gerados na baixa devo exclui-los.
										If SE1->E1_TIPO $ ("COF/CSL/PIS") .AND. lPccBxCr
											If lExistFJU
												FingrvEx("R")
											EndIf	
										
											RecLock("SE1")
											dbDelete()
											MsUnlock()
										Else
											RecLock("SE1")
											If !lPropBx
											SE1->E1_SALDO := SE1->E1_VALOR
											Else
												Do Case
													Case SE1->E1_TIPO $ MVPIABT .and. !lPccBxCr
														SE1->E1_SALDO	+= nVretPis
													Case SE1->E1_TIPO $ MVCFABT .and. !lPccBxCr  
														SE1->E1_SALDO	+= nVretCof
													Case SE1->E1_TIPO $ MVCSABT .and. !lPccBxCr
														SE1->E1_SALDO	+= nVretCsl
													Case SE1->E1_TIPO $ MVIRABT .and. !lIrPjBxCr
														SE1->E1_SALDO	+= nVretIrf
													Case SE1->E1_TIPO $ MVINABT 				
														SE1->E1_SALDO	+= nVretIns
													Case SE1->E1_TIPO $ MVISABT   				
														SE1->E1_SALDO	+= nVretIss
												EndCase
											EndIf
											SE1->E1_VALLIQ:= 0
											If NoRound( SE1->E1_VALOR, 2 ) == NoRound( SE1->E1_SALDO, 2 )
												SE1->E1_BAIXA := CtoD("  /  /  ")
												nVlrAbat += SE1->E1_VALOR
											Else
												nVlrAbat += SE1->E1_VALOR-SE1->E1_SALDO
											EndIf
											SE1->E1_STATUS:= Iif(SE1->E1_SALDO > 0.01,"A","B")
											MsUnlock()
										Endif
							EndIf
							dbSelectArea("SE1")
							dbSkip()
						EndDo
					Endif
				Else
					Exit
				EndIf

				dbSelectArea("SE1")
				dbGoto(nSE1Rec)

				dbSelectArea("SE5")
				dbGoTo(aRegistros[nLaco])
				// Desfaz comissoes calculadas para adiantamentos ou notas de credito
				If (MV_PAR06 == 1 .And. Substr(SE5->E5_DOCUMEN,nTamTit+1,nTamTip) $ MV_CRNEG) .Or.;
					(MV_PAR13 == 1 .And. Substr(SE5->E5_DOCUMEN,nTamTit+1,nTamTip) $ MVRECANT)
					If cPaisLoc<>"BRA"
						aadd(aBaixas,{{SE5->E5_MOTBX,SE5->E5_SEQ,SE5->(Recno())}})
					else
						aadd(aBaixas,{SE5->E5_MOTBX,SE5->E5_SEQ,SE5->(Recno())})
					Endif
				Endif

				IF lPadrao .and. SUBSTR(SE5->E5_LA,1,1) == "S"
					nTotal += DetProva( nHdlPrv,;
					                    cPadrao,;
					                    "ZFINA330",;
					                    cLote,;
					                    /*nLinha*/,;
					                    /*lExecuta*/,;
					                    /*cCriterio*/,;
					                    /*lRateio*/,;
					                    /*cChaveBusca*/,;
					                    /*aCT5*/,;
					                    /*lPosiciona*/,;
					                    @aFlagCTB,;
					                    /*aTabRecOri*/,;
					                    /*aDadosProva*/ )
				EndIF

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³  Apaga registro da movimenta‡„o  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				dbSelectArea("SE5")

				If lACAtivo
					If E5_TIPO == "NCC"
						ACFina070(aTitulos[1][1], aTitulos[1][2], aTitulos[1][3], aTitulos[1][4]) // Realiza as consequencias de uma baixa de titulo com o modulo Gestao Educacional ativo.
					EndIf
				EndIf
				If E5_TIPO == "NF "
					AADD(aDoctosSE5,{SE5->E5_DOCUMEN,SE5->E5_CLIFOR,SE5->E5_LOJA,SE5->E5_SEQ})
				EndIf

				/////////////////////
				//PCC Baixa CR
				//Obtem valor dos impostos PCC retidos na compensacao
				If cPaisLoc == "BRA" .and. lPccBxCr .and. !lIsNcc .and. !lCredito
					If EMPTY(SE5->E5_PRETPIS)
						nPis += SE5->E5_VRETPIS
					ENDIF
					If EMPTY(SE5->E5_PRETCOF)
						nCofins += SE5->E5_VRETCOF
					Endif
					If EMPTY(SE5->E5_PRETCSL)
						nCsll += SE5->E5_VRETCSL
					Endif
					nInss += SE1->E1_INSS
					nCtbInss += SE1->E1_INSS
					//Excluir relacionamentos SFP
					//Exclui titulos gerados
					FaDelSFQCR()
				Endif

				If nOpc == 4  //Exclusao 
					Fin330ExCM(SE5->E5_FILIAL, SE5->E5_SEQ)
				Endif

 				oModelCP := FWLoadModel("FINM010")
				//Posiciona a FK1 para mandar a operação de alteração com base no registro posicionado da SE5
				If AllTrim( SE5->E5_TABORI ) == "FK1"
					aAreaAnt := GetArea()
					dbSelectArea( "FK1" )
					FK1->( DbSetOrder( 1 ) )
					If MsSeek( xFilial("FK1") + SE5->E5_IDORIG )
						oModelCP:SetOperation( MODEL_OPERATION_UPDATE ) //Alteração
						oModelCP:Activate()
						//Posiciona a FKA com base no IDORIG da SE5 posicionada
            			oSubFKA := oModelCP:GetModel( "FKADETAIL" )
						oSubFKA:SeekLine( { {"FKA_IDORIG", SE5->E5_IDORIG } }) 

						oModelCP:SetValue( "MASTER", "E5_GRV", .T. ) //Habilita gravação SE5
						//E5_OPERACAO 1 = Altera E5_SITUACA da SE5 para 'C' e gera estorno na FK1
						//E5_OPERACAO 2 = Altera E5_TIPODOC da SE5 para 'ES' e gera estorno na FK1
						//E5_OPERACAO 3 = Deleta da SE5 e gera estorno na FK1
                        if nOpc <> 4
							//Manda o campo LA com o valor de 2 Caracteres, para manter a gravação original na E5
							cCamposE5 := '{'  
							cCamposE5 += "{'E5_DATA', dDataBase}"
							
							If !Empty( SE5->( FieldPos( "E5_MSEXP" ) ) ) 
								cCamposE5 += ",{'E5_MSEXP', ''}"
							EndIf
														
							If MV_PAR09 == 1 .and. !lUsaFlag
								cCamposE5 += ",{'E5_LA', 'S"  + SubStr( SE5->E5_LA, 2, 1 ) + "'}"
							EndIf

							If UsaSeqCor()
								cCamposE5 += ",{'E5_NODIA', ''}"
							endif          
							cCamposE5 += '}'
							
						endif	
						oModelCP:SetValue( "MASTER", "E5_CAMPOS", cCamposE5 ) //Informa os campos da SE5 que serão gravados indepentes de FK1
						oModelCP:SetValue( "MASTER", "E5_OPERACAO",If(nOpc == 4, 3, 2) ) //E5_OPERACAO 3 = Deleta da SE5 e gera estorno na FK1
						oModelCP:SetValue( "MASTER", "HISTMOV" , STR0055 )
            
					
						If oModelCP:VldData()
					       	oModelCP:CommitData()
					       	SE5->(dbGoto(oModelCP:GetValue( "MASTER", "E5_RECNO" )))
					       	if nOpc <> 4
	    						If MV_PAR09 == 1 .and. lUsaFlag                          
									aAdd( aFlagCTB, {"E5_LA", "S", "SE5", SE5->(RECNO()) , 0, 0, 0} )
								EndIf
    	
  		  						If UsaSeqCor()
									AAdd(aDiario,{"SE5",SE5->(RECNO()),SE5->E5_DIACTB,"E5_NODIA","E5_DIACTB"})
								EndIf

					   			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³ PONTO DE ENTRADA NA ALTERACAO DO HISTORICO NA SE5 NO ESTORNO         ³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
            					If ExistBlock( "F330AE5E" )
            					   ExecBlock("F330AE5E",.F.,.F.)
               					EndIf

                            endif
						Else
							lRet := .F.
					    	cLog := cValToChar(oModelCP:GetErrorMessage()[4]) + ' - '
				    		cLog += cValToChar(oModelCP:GetErrorMessage()[5]) + ' - '
	    		  			cLog += cValToChar(oModelCP:GetErrorMessage()[6])
			   				Help( ,,"M330VALID",,cLog, 1, 0 )
						Endif
					Endif
					RestArea(aAreaAnt)
				Endif
				oModelCP:DeActivate()
				oModelCP:Destroy()
				oModelCP:=nil	
				

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Grava lançamento no PCO ref canc. baixa do titulo compensado (Mov.Bancaria-SE5) ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				PCODetLan("000016","06","ZFINA330") 
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ PONTO DE ENTRADA DE VALIDACAO DE EXCLUSAO/ESTORNO ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
          		If ExistBlock( "F330VEEX" )
            	    ExecBlock("F330VEEX",.F.,.F.,{nOpc})
        	    EndIf
				lCancelou := .T.
          	endif

		Next nLaco
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se foi gerado comiss„o e caso tenha sido, exclui     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If cPaisLoc<>"BRA"
			AeVal(aBaixas,{|x|Fa440DeleB(x,.F.,.F.,"ZFINA330")})
		Else
			Fa440DeleB(aBaixas,.F.,.F.,"ZFINA330")
		EndIF
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ PONTO DE ENTRADA NA EXCLUSAO ANTES DA CONTABILIZACAO         ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (ExistBlock( "FA330EAC" ) )
			ExecBlock("FA330EAC",.F.,.F.)
		EndIf
		If lPadrao .and. lCancelou .and. !lFirst .and. nValCtb > 0
			VALOR  := nValCtb
			VALOR3 := nPis
			VALOR4 := nCofins
			VALOR5 := nCsll
			VALOR6 := nInss
			VALOR6 := nCtbInss
			VALOR7 := nTitDecre
			VALOR8 := nTitAcres 

			dbSelectArea("SE1")
			dbGoBottom()
			dbSkip()
			dbSelectArea("SE5")
			dbGoBottom()
			dbSkip()
			nTotal += DetProva( nHdlPrv,;
			                    cPadrao,;
			                    "ZFINA330",;
			                    cLote,;
			                    /*nLinha*/,;
			                    /*lExecuta*/,;
			                    /*cCriterio*/,;
			                    /*lRateio*/,;
			                    /*cChaveBusca*/,;
			                    /*aCT5*/,;
			                    /*lPosiciona*/,;
			                    @aFlagCTB,;
			                    /*aTabRecOri*/,;
			                    /*aDadosProva*/ )

			RodaProva(  nHdlPrv,;
						nTotal)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Envia para Lan‡amento Cont bil                      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			lDigita := IIF( mv_par07 == 1,.t., .f. )
			cA100Incl( cArquivo,;
			           nHdlPrv,;
			           3,;
			           cLote,;
			           lDigita,;
			           .F.,;
			           /*cOnLine*/,;
			           /*dData*/,;
			           /*dReproc*/,;
			           @aFlagCTB,;
			           /*aDadosProva*/,;
			           aDiario )
			aFlagCTB := {}  // Limpa o coteudo apos a efetivacao do lancamento

			dbSelectArea("SE1")
			dbGoTo(nRegSE1)
			dbSelectArea("SE5")
			dbGoTo(nRegSE5)
		EndiF

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Volta valor do titulo.		 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nValorBaix # 0 .or. nTitDecre # 0 .or. nTitAcres # 0 .or. nDescP # 0
			SE5->(dbGoTo(nRegSE5))
			SE1->(dbGoTo(nRegSE1))
			//Verifica se o titulo já possui impostos gerados pela rotina de Borderô de Recebimento de Imposto (FINA061).
			nPisFina061	:=	0
			nCofFina061	:=	0
			nCslFina061	:=	0
			nIrfFina061	:=	0
			nRegSE5	:=	SE5->(Recno())
			nOrdSE5	:=	SE5->(IndexOrd())		
					
			If SE1->E1_TIPO <> MVRECANT .AND. SE1->E1_TIPO <> MV_CRNEG .And. (lPccBxCr .Or. lIrPjBxCr)
				dbSelectArea("SE5")
				SE5->(dbSetOrder(2)) //FILIAL + TIPODOC + PREFIXO + NUMERO + PARCELA + TIPO
				If SE5->(DBSeek(xFilial("SE5")+"BA"+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO))
					While !SE5->(Eof()) .and. SE5->E5_FILIAL==xFilial("SE5") .And. ;
							SE5->E5_TIPODOC+SE5->E5_PREFIXO+SE5->E5_NUMERO+SE5->E5_PARCELA+SE5->E5_TIPO=="BA"+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO		
								
						If ("FINA061" $ Subst(SE5->E5_HISTOR,1,7)) .And. SE5->E5_MOTBX $ "PCC_IRF"						
							If Alltrim(SE5->E5_MOTBX) == "PCC"
							   nPisFina061	+= SE5->E5_VRETPIS
							   nCofFina061	+=	SE5->E5_VRETCOF
							   nCslFina061	+= SE5->E5_VRETCSL
							ElseIf Alltrim(SE5->E5_MOTBX) == "IRF"
							   nIrfFina061	+= SE5->E5_VRETIRF
							Endif
						Endif					
						SE5->(DbSkip())		
					Enddo
				Endif
			Endif						
			
			Reclock("SE1")

			If !lCredito .And. SE1->E1_SALDO == 0 .and. !lPropBx
				SE1->E1_SALDO += Iif((mv_par08==1.OR. lRaRtImp),nVlrAbat,0)
				If !(!lRartImp .and. mv_par08 == 1 .and. !lBq10925)
					lAtusalImp := .T.
				Endif
			Endif
			SE1->E1_SALDO  += nValBaix2
			If SE1->E1_VALOR - SE1->E1_SALDO <= 0.05 //problemas de arredondamento
				SE1->E1_SALDO := SE1->E1_VALOR
			Endif
			SE1->E1_VALLIQ := 0
			SE1->E1_SDDECRE += nTitDecre
			SE1->E1_SDACRES += nTitAcres
			SE1->E1_DESCONT -= nDescP
			//SE1->E1_BAIXA := CtoD("  /  /  ")
			nTotAbat := SumAbatRec(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_MOEDA,"V",dBaixa)
			If STR(SE1->(E1_VALOR - E1_SALDO),17,2) == STR(nTotAbat,17,2) .and. !lRaRtImp
				SE1->E1_SALDO += nTotAbat
			Endif

			If nValBaix2 + nVlPis + nVlCof + nVlCsll == nVlNf .and. lCredito .and. !lRartImp
				SE1->E1_SALDO += (nVlPis + nVlCof + nVlCsll)
			ElseIf mv_par08 == 1 .AND. !lRartImp .and. SE1->E1_SALDO+nVlPis + nVlCof + nVlCsll + nVlIrrf == SE1->E1_VALOR
				SE1->E1_SALDO += (nVlPis + nVlCof + nVlCsll + nVlIrrf)
			ElseIf lCredito .AND.  mv_par08 == 2 .and. !lRartimp
				SE1->E1_SALDO -= (nVlPis + nVlCof + nVlCsll + nVlIrrf)
			ElseIf nValBaix2 + nVlPis + nVlCof + nVlCsll + nVlrAbat == nVlNf .and. lCredito .and. !lRartImp
				SE1->E1_SALDO += (nVlPis + nVlCof + nVlCsll + nVlrAbat)
			ElseIf lCredito .and. !lRartimp .and. mv_par08 == 1 .and. lBq10925
				SE1->E1_SALDO += (nVlPis + nVlCof + nVlCsll )
			endIf
			
			If lPropBx .and. nAbat >0 .and. !lCredito .and. ((!lRartImp .and. mv_par08 == 1) .or. (lRartImp)) 
				SE1->E1_SALDO	+= nAbat
			EndIF	

			/////////////////////
			//PCC Baixa CR
			//Retorna para o saldo do titulo o valor retido do PCC
			If lPccBaixa .and. !lIsNcc .and. !lCredito .AND. !lAtusalImp .and. mv_par08 == 1
				SE1->E1_SALDO += nPis+nCofins+nCsll
				If SE1->E1_VALOR - SE1->E1_SALDO == 0.01 //problemas de arredondamento
					SE1->E1_SALDO := SE1->E1_VALOR
				Endif
			Endif
		  	If (lIrPjBxCr .or. lPccBaixa) .AND. ( lRartImp .Or. lBQ10925 ) .and. !lCredito .AND. !lAtusalImp .and. !lPropBx 
				If nPis+nCofins+nCsll+SE1->E1_IRRF <> nVlrAbat .and. lIrPjBxCr //Ir na baixa
				SE1->E1_SALDO += nVlrAbat
			EndIf
			ElseIf !lIrPjBxCr .and. lPccBaixa .and. !lRartImp .and. lBQ10925 .and. lCredito .and. !lAtusalImp .and. SE1->E1_SALDO < SE1->E1_VALOR
				SE1->E1_SALDO += nVlrAbat
			EndIf

			If (nPisFina061+nCofFina061+nCslFina061+nIrfFina061)> 0 
				If mv_par08 = 2
				  	SE1->E1_SALDO	-= nPisFina061+nCofFina061+nCslFina061+nIrfFina061		
				Endif  	
		  		SE1->E1_VALLIQ	+= nPisFina061+nCofFina061+nCslFina061+nIrfFina061		
			Endif																				

			If !lAtusalImp
				SE1->E1_SALDO += nIrrfPac
			EndIf

			SE1->E1_STATUS:= IIF(SE1->E1_STATUS != "R",Iif(SE1->E1_SALDO > 0.01,"A","B"),"R")
			If SE1->E1_SALDO > SE1->E1_VALOR		// garantir que o saldo nao seja maior
				Replace E1_SALDO With E1_VALOR
			Endif
			If NoRound( SE1->E1_VALOR, 2 ) == NoRound( SE1->E1_SALDO, 2 )
				SE1->E1_BAIXA := CtoD("  /  /  ")
			EndIf

			MsUnlock()
			If (ALLTRIM(SE1->E1_ORIGEM) == "FINA677")
				FINATURES(SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA),.F.,SE1->E1_ORIGEM,"R")
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Grava lançamento no PCO ref titulo principal apos a cancelamento   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			PCODetLan("000016","01","ZFINA330")

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Atualiza Saldo do Cliente /  DP/NF  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aArea:=GetArea()
			dbSelectArea("SA1")
			DbSetOrder(1)
			If dbSeek(xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA)
				If lGrvSa1
					RecLock("SA1")
					nSaldoComp:=Round(xMoeda(nValBaix2,nMoeda,SE1->E1_MOEDA,SE5->E5_DATA,nDecs+1,Fa330TxMd(nMoeda,nTxMoeda),Fa330TxMd(SE1->E1_MOEDA,nTxMoeda)),nDecs)
					If lCredito
						AtuSalDup("-",nSaldoComp,nMoeda,SE1->E1_TIPO,,SE1->E1_EMISSAO)
					Else
			   		   AtuSalDup("+",nSaldoComp,nMoeda,SE1->E1_TIPO,,SE1->E1_EMISSAO)
	  				EndIf
					MsUnlock()
				EndIf
			EndIf
			RestArea(aArea)
			SE1->(dbGoTo(nRegSE1))

		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ PONTO DE ENTRADA 															 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (ExistBlock( "FA330EXC" ) )
			ExecBlock("FA330EXC",.F.,.F.)
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Finaliza a gravacao dos lancamentos do SIGAPCO            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		PcoFinLan("000016")

		End Transaction
		Exit
	Endif
Enddo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Restaura o valor da l330Auto para False³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
l330Auto := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Recupera a Integridade dos dados           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea( "SE1" )
dbSetOrder( 1 )
dbSelectArea( "SE5" )
dbSetOrder( 1 )
dbGoTo( nReg )
DeleteObject(oOk)
DeleteObject(oNo)
FA330aUnlock()
Return lRetAuto
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Fa330Marca³ Autor ³ Alice Y Yamamoto 	    ³ Data ³ 08/04/97 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Marca os itens a serem excluidos 						  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Fa330Marca												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function fa330Marca(nIt,aArray,nOpc)

If (aArray[nIt,11] )
	aArray[nIt,11] := .F.
Else
	If Fa330VldDt(aArray[nIt],nOpc)
		aArray[nIt,11] := .T.
	Endif
Endif

Return aArray


/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Fa330OK	³ Autor ³ Marcos Patricio		  ³ Data ³ 19/12/95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Confirma a marcacao dos titulos para compensacao.			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Fa330OK																	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FA330OK()
Local lMarcado := .T.,nX
Local lRet	:=	.F.
Local aAreaSE1 := {}
//Quando chamada da MATA465 se nao existe nada marcado da erro
If cPaisLoc <> "BRA"
	lMarcado	:=	.F.
	For nX	:=1 	To Len(aTitulos)
		If aTitulos[nX][8]
			//Forcar a saida do FOR
			lMarcado	:=	.T.
			nX	:=	Len(aTitulos)+1
		Endif
	Next
Endif
If lMarcado
	lRet	:=	MsgYesNo(STR0024,STR0018)
Else
	MsgAlert(STR0040,STR0018)
	lRet	:=	.F.
Endif

If ExistBlock("Fa330Vld") .and. lRet
	aAreaSE1 := SE1->(GetArea())
	SE1->(DbSetOrder(nIndVld))
	SE1->(DbGoTo(nRecVld))
	lRet := ExecBlock("Fa330Vld")
	RestArea(aAreaSE1)
EndIf

If UsaSeqCor()
	If !CTBvldDiario(cCodDiario,dDataBase)
		Return(.f.)
	EndIf
EndIf


Return lRet  //"Confirma marca‡„o de T¡tulos ?"###"Aten‡„o"
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Fa330Troca³ Autor ³ Marcos Patricio		³ Data ³ 19/12/95 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Troca o flag para marcado ou nao,aceitando valor.		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Fa330Troca												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function FA330Troca(nIt,aArray,oGet,lTodos,oTitulo)

Local oDlg
Local nOpca    := 0
Local nX       := 0
Local nAcresc  := 0
Local nY	   := 0
Local xy       := 0
Local nVezes   := 1
Local nOldIt   := nIt
//Controla IRPJ na baixa
Local lIrPjBxCr:= FIrPjBxCr()
Local lPccBxCr	:= FPccBxCr()
Local nPosIr	:=0
Local cLimite  := ''
Local nValOld  :=0
Local nPos 	   := 0
LOCAL nTotAbat := 0
Local aAreaSE1 := SE1->(GetArea())
Local nItem	:= 0
Local nRecOu	:= 0
Local nItemRA	:= 0
Local nItemOu	:= 0
Local lNcc		:= SE1->E1_TIPO $ MV_CRNEG
Local nVlMinImp := GetNewPar("MV_VL10925",5000)
Local nAltVal	:= 0
Local nPcc := 0
Local lBq10925	:= SuperGetMV("MV_BQ10925",,"2") == "1"
Local nVTit		:= 0
Local aArrAux		:= {}
Local nVlAbt		:= 0
Local lMSal		:= .F.
Local cOldVl		:= 0
Local nVlrSldPcc	:= 0
DEFAULT lTodos := .F.

If dDataBase >= dLastPcc
	nVlMinImp	:= 0
EndIf

If MV_PAR02 == 2
	nPos := 25
Else
	nPos := 22
Endif
If cPaisLoc == "BRA"
	cValor  := Fa330VTit(aTitulos[nIt,6 ])
	cSaldo  := Fa330VTit(aTitulos[nIt,nPos ])//Limite de Compensação
	cSalTit := Fa330VTit(aTitulos[nIt,6 ])
	cLimite := Fa330VTit(aTitulos[nIt,nPos]) //Limite de Compensação
	nVezes  := If(lTodos,Len(aArray),1)
	If mv_par02 == 1
		nAcresc := Fa330VTit(aTitulos[nIt,10])
	Else
		nAcresc := Fa330VTit(aTitulos[nIt,13])
	Endif
	If (lPccBxCr .or.lIRPJBxCr) .And. lRaRtImp
		cValor  := Fa330VTit(aTitulos[nIt,22])
	EndIf
Else
	cValor  := Fa330VTit(aTitulos[nIt,6 ])
	If mv_par02 == 1
		cSaldo  := Fa330VTit(aTitulos[nIt,14])
	Else
		cSaldo  := Fa330VTit(aTitulos[nIt,17])
	EndIf
	cSalTit := Fa330VTit(aTitulos[nIt,6 ])
	nVezes  := If(lTodos,Len(aArray),1)
Endif

nValtot := 0
nVlComp := 0

For xy := 1 to Len(aTitulos)
	If aTitulos[xy,8] .And. xy <> nIt
		nVlComp += Fa330VTit(aTitulos[xy,7])
	EndIf
Next

cSaldo := Iif(cSaldo > nSaldo - nVlComp,nSaldo - nVlComp,cSaldo)
nValOld	:= cSaldo
For nY := 1 to nVezes

	If nVezes > 1
		nIt := nY
		cValor  := Fa330VTit(aTitulos[nIt,6])
		cSaldo  := Fa330VTit(aTitulos[nIt, If( cPaisLoc == "BRA", nPos, 14 ) ])
		cLimite := Fa330VTit(aTitulos[nIt,nPos])
		
		If (lPccBxCr .or.lIRPJBxCr) .And. lRaRtImp
			cValor  := Fa330VTit(aTitulos[nIt,22])
		EndIf
	Endif

	aArray[nIt,8] := !aArray[nIt,8]

	If (lPccBxCr .or. lIRPJBxCr) .And. lRaRtImp .AND. !lNcc
  		aDadosRA1[9][nIt] := !aDadosRA1[9][nIt]
 	Endif


	If aArray[nIt,8]

		If FA330Lock(aArray[nIt,1]+aArray[nIt,2]+aArray[nIt,3]+aArray[nIt,4],,,aArray[nIt,Iif(MV_PAR02== 2, 16,13)])

			If !lTodos
				If cPaisLoc == "BRA"
					If aArray[nIt,4] $ MV_CRNEG .and. (mv_par08 == 1 .OR. lRaRtImp)
						F330VALNCC(@aArray,nIt, cValor < cLimite, .T.)
						cSaldo  := nSaldo - nVlComp
					Endif
					If cSaldo >= aArray[nIt,(nPos-1)]
						cLimite := Fa330VTit(aArray[nIt,nPos]) //Limite de Compensação
						cValor	:= Fa330VTit(aArray[nIt,nPos]) //Limite de Compensação
					Else
						If !lNcc .or. (lNCC .and. cValor > cSaldo)
							cLimite := cSaldo
						//	cValor	:= cSaldo
						Endif
					Endif
					If cLimite < cValor
						cValor	:= cLimite
					EndIf
					
					If lPccBxCr .And. !lRartimp .And. SE1->E1_TIPO $ MVRECANT
						aArrAux 	:= aClone(aArray)
						nVlAbt 	:= SomaAbat(aArray[nIt][1],aArray[nIt][2],aArray[nIt][3],"R",,,SE1->E1_CLIENTE,,aArray[nIt][13])
						nVlrSldPcc  :=  DesTrans( aArray[nIt][nPos] )
						u_F330CalcPCC(nIt,aArrAux,@nVlrSldPcc,cValor < cLimite)
						If lBq10925 //Pcc Bruto 
							If ( cValor + ( DesTrans(aArrAux[nIt][nPosPis]) + DesTrans(aArrAux[nIt][nPosCof]) + DesTrans(aArrAux[nIt][nPosCsl]) ) ) > Val(Replace(Replace(aArrAux[nIt][6],".", "" ), ",", "."))//Verifica se é maior que Saldo do titulo							
								if ( cValor + ( DesTrans(aArrAux[nIt][nPosPis]) + DesTrans(aArrAux[nIt][nPosCof]) + DesTrans(aArrAux[nIt][nPosCsl]) ) ) - Val(Replace(Replace(aArrAux[nIt][6],".", "" ), ",", ".")) > 0.05 
									cValor     := ( nVlrSldPcc - ( DesTrans(aArrAux[nIt][nPosPis]) + DesTrans(aArrAux[nIt][nPosCof]) + DesTrans(aArrAux[nIt][nPosCsl]) ) )
									lMSal      := .T.
									nVlrSldPcc := DesTrans( aArray[nIt][nPos] )
								endIf
							EndIf  
						Else //Pcc Liquido
							If cValor > ( nVlrSldPcc - ( DesTrans(aArrAux[nIt][nPosPis]) + DesTrans(aArrAux[nIt][nPosCof]) + DesTrans(aArrAux[nIt][nPosCsl]) ) )
								cValor     := ( nVlrSldPcc - ( DesTrans(aArrAux[nIt][nPosPis]) + DesTrans(aArrAux[nIt][nPosCof]) + DesTrans(aArrAux[nIt][nPosCsl]) ) )
								lMSal      := .T.
								nVlrSldPcc := DesTrans( aArray[nIt][nPos] )
							EndIf
						EndIf
						If lIrPjBxCr 
					   		nIrrf := FCaIrBxCR(nVlrSldPcc,,(SE1->E1_VALOR <> SE1->E1_SALDO .And. lRaRtImp ) )
					   		aArray[nIt,nPosIrf] := Transf(nIrrf,PesqPict("SE1","E1_IRRF"))  
					   		aTitulos[nIt,nPosIrf]:= Transf(nIrrf,PesqPict("SE1","E1_IRRF")) 
							cValor := cValor - Val(StrTran(Replace(aArray[nIt][nPosIrf],".",""),",","."))
							aArray[nIt,nPosBIRF] := Transform(nVlrSldPcc,"@E 99,999,999.99")
							
						EndIf
						
					EndIf
				Endif

				DEFINE MSDIALOG oDlg FROM  80,100 TO 180,400 TITLE STR0048 PIXEL Style DS_MODALFRAME //"Compensa‡„o CR"

				@ -3, 2 TO 22, 128 OF oDlg	PIXEL
				@ 7, 68 MSGET cValor Picture "@E 9999,999,999.99" VALID cValor <= cSaldo  .And. cValor > 0 .And. ;
				                                                        cValor >= nAcresc   ;
				                                                        SIZE 54, 10 OF oDlg PIXEL hasbutton
				@ 8, 9 SAY STR0014  SIZE 54, 7 OF oDlg PIXEL  //"Valor a compensar"

				If aArray[nIt,4] $ MV_CRNEG .Or. lNcc    

					@ 21, 2 SAY STR0072  SIZE 120, 60 OF oDlg PIXEL //"Ao selecionar esse titulo os impostos calculados na baixa serão desconsiderados"

				Endif

				DEFINE SBUTTON FROM 37, 71 TYPE 1 ENABLE ACTION (nOpca:=1,If((cValor <= cSaldo  .AND. cValor > 0 .AND. cValor >= nAcresc .AND. If(cPaisLoc== "BRA", cValor<=cLimite, cValor <= cSalTit)),oDLg:End(),nOpca:=0)) OF oDlg
				DEFINE SBUTTON FROM 37, 99 TYPE 2 ENABLE ACTION oDlg:End() OF oDlg

				ACTIVATE MSDIALOG oDlg
			Else
				nOpca := 1
			Endif
			If lMSal
				cOldVl := cValor
				cValor := nVlrSldPcc
			Endif
			If 	nOpca == 0
				aArray[nIt,8] := .F.
				If lRaRtImp .And. !lNcc
					aDadosRA1[9][nIt] := .F.
				EndIf
				If aArray[nIt,4] $ MV_CRNEG .and. (mv_par08 == 1 .OR. lRaRtImp) .And. !Empty( cLimite )
					F330VALNCC(@aArray,nIt, cValor < cLimite, .F.)
					cSaldo  := nSaldo - nVlComp
					cLimite := Fa330VTit(aTitulos[nIt,nPos]) //Limite de Compensação
				EndIf
			Endif
			IF	nOpca == 1
			
				If lCredito .And. SE1->E1_TIPO == MV_CRNEG
					dbSelectArea("SE1")
					If MV_PAR02 == 2
						dbGoTo(aArray[nIt,23])
					Else
				   		dbGoTo(aArray[nIt,20])
				    Endif
					nValAbat := SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",SE1->E1_MOEDA,,SE1->E1_CLIENTE,,SE1->E1_FILIAL)
					RestArea(aAreaSE1)
				EndIf
			
				//Pcc Baixa CR
				//Caso a compensacao tenha partido de um Adiantamento
				If lCredito .And. (SE1->E1_TIPO <> MV_CRNEG) .And. !lRaRtImp .And. cPaisLoc == "BRA"
					dbSelectArea("SE1")
					If MV_PAR02 == 2
						dbGoTo(aArray[nIt,23])
					Else
				   		dbGoTo(aArray[nIt,20])
				    Endif
					If mv_par08 == 1 .OR. lRaRtImp
						nTotAbat := SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",SE1->E1_MOEDA,,SE1->E1_CLIENTE,,SE1->E1_FILIAL)
						nValAbat	:= nTotAbat
					Else
						nTotAbat := 0
					Endif
					
					If lRartimp .and. (!(cValor+nPis+nCofins+nCsll == SE1->E1_SALDO) .or. (dDatabase >= dLastPcc .and. !lOldPcc))
						u_F330CalcPCC(nIt,aArray,@cValor+If(cValor==cSalTit,nTotAbat,0),cValor < cLimite)
					EndIf
					nOldValRec	:= nValOld
					If cValor > cLimite
						cValor := cLimite
					EndIf
					If dDatabase <= dLastPcc
						If !lRaRtImp .and. mv_par08 == 1 .and. lPccBxCr .and. SE1->E1_TIPO <> MVRECANT .and. nPis+nCofins+nCsll+nIrrf > 0 .AND. aDadosret[1] < nVlMinImp .and. aDadosRet[1]+nValRec > nVlMinImp
		  					nProp	:= (aDadosret[1]+ nValRec) / nSaldo
							nPis	:= SE1->E1_PIS * nProp
							nCofins := SE1->E1_COFINS * nProp
							nCsll	:= SE1->E1_CSLL * nProp
						EndIf
					EndIf
				EndIf
				If cPaisLoc == "BRA"
					aArray[nIt,9] := Iif(lMSal .And. cValor > cOldVl,cOldVl,cValor)
					
					If lIrPjBxCr .and. lCredito .and.  (SE1->E1_TIPO <> MV_CRNEG) 
							If MV_PAR02 == 2
								nIrrf := Val(StrTran(Replace(aArray[nIt][nPosIrf],".",""),",","."))//FCaIrBxCR(aArray[nIt,9],aArray[nIt,23])
								If (nPosIr := aScan(aImpIR,{|x| x[2] == aArray[nIt,23]})) == 0
									aAdd(aImpIR,{nIrrf,aArray[nIt,23]})
									nPosIr := Len( aImpIR )								
								Else
									aImpIR[nPosIr][1] := nIrrf
								EndIf
							Else
								nIrrf := Val(StrTran(Replace(aArray[nIt][nPosIrf],".",""),",","."))//FCaIrBxCR(aArray[nIt,9],aArray[nIt,20])
								If (nPosIr := aScan(aImpIR,{|x| x[2] == aArray[nIt,20]})) == 0
									aAdd(aImpIR,{nIrrf,aArray[nIt,20]})
									nPosIr := Len( aImpIR )
								Else
									aImpIR[nPosIr][1] := nIrrf
								EndIf
							EndIf
							
					EndIf

					If (lPccBxCr .or.lIRPJBxCr) .And. lRaRtImp .and. !lNcc
						dbSelectArea("SE1")
						If MV_PAR02 == 2
							dbGoTo(aArray[nIt,23])
						Else
				   			dbGoTo(aArray[nIt,20])
				    	Endif
						If lCredito
							nItemOU := aScan(aDadosRA1[2],{|x| x==SE1->(Recno())})
						Else
							nItemRA := aScan(aDadosRA1[1],{|x| x==SE1->(Recno())})
						EndIf
				        If !(aArray[nIt,4] $ MV_CRNEG)
							If u_F330RaRtIm(@aDadosRA1,cValor,nItemRA,nItemOu, cValor < cLimite )
								If lCredito
									nAltVal	:= cValor
									If nAltVal+nPis+nCofins+nCsll == SE1->E1_SALDO 
										nAltVal	:= nAltVal+nPis+nCofins+nCsll
									ElseIf nAltVal+aDadosRA1[3][nItemOU]+aDadosRA1[4][nItemOU]+aDadosRA1[5][nItemOU] == SE1->E1_SALDO
										nAltVal	:= nAltVal+aDadosRA1[3][nItemOU]+aDadosRA1[4][nItemOU]+aDadosRA1[5][nItemOU]
									EndIf
									If dDataBase >= dLastPcc
										If cValor <> cLimite 
											aPcc	:= newMinPcc(dbaixa,nAltVal,SE1->E1_NATUREZ,"R",SE1->E1_CLIENTE+SE1->E1_LOJA)
											nPis	:= 	aPcc[2]
											nCofins	:=	aPcc[3]
											nCsll	:=  aPcc[4]
											nPisCalc	:= nPis
											nPisBaseC	:= nAltVal	
											nPisBaseR 	:= nAltVal
											nCofCalc	:= nCofins	
											nCofBaseC	:= nAltVal
											nCofBaseR 	:= nAltVal
											nCslCalc	:= nCsll	
											nCslBaseC	:= nAltVal
											nCslBaseR 	:= nAltVal
											
											If lIrPjBxCr .And. cPaisLoc == "BRA"
												nIrrf	:= nIrrf * (nAltVal / SE1->E1_BASEIRF)
											EndIf
										EndIf
										aArray[nIt,nPosPis]		:= aDadosRA1[3][nItemOu]	:= nPis
										aArray[nIt,nPosCof]		:= aDadosRA1[4][nItemOu]	:= nCofins
										aArray[nIt,nPosCsl] 	:= aDadosRA1[5][nItemOu]	:= nCsll
									Else
									aArray[nIt,nPosPis]:=Transf(aDadosRA1[3][nItemOu],PesqPict("SE1","E1_PIS"))
									aArray[nIt,nPosCof]:=Transf(aDadosRA1[4][nItemOu],PesqPict("SE1","E1_COFINS"))
									aArray[nIt,nPosCsl]:=Transf(aDadosRA1[5][nItemOu],PesqPict("SE1","E1_CSLL"))
									EndIf
									aArray[nIt,nPosIrf]:=Transf(aDadosRA1[6][nItemOu],PesqPict("SE1","E1_IRRF"))
									If dDataBase < dLastPcc
									If cValor < cLimite
										cValor := cValor - (aDadosRA1[3][nItemOu]+aDadosRA1[4][nItemOu]+aDadosRA1[5][nItemOu]+aDadosRA1[6][nItemOu];
															+aDadosRA1[10][nItemOu]+aDadosRA1[11][nItemOu])
										EndIf
									Else
										If cValor < cLimite
											cValor := cValor - (nPis+nCofins+nCsll)
											If lIrPjBxCr
												cValor	:= cValor - nIrrf
											EndIf
										EndIf
									EndIf
								Else
									nAltVal	:= cValor
									If nAltVal+nPis+nCofins+nCsll == SE1->E1_SALDO 
										nAltVal	:= nAltVal+nPis+nCofins+nCsll
									ElseIf nAltVal+aDadosRA1[3][nItemRA]+aDadosRA1[4][nItemRA]+aDadosRA1[5][nItemRA] == SE1->E1_SALDO
										nAltVal	:= nAltVal+aDadosRA1[3][nItemRA]+aDadosRA1[4][nItemRA]+aDadosRA1[5][nItemRA]
									EndIf
									If dDataBase >= dLastPcc
										If cValor <> cLimite 
											aPcc	:= newMinPcc(dbaixa,nAltVal,SE1->E1_NATUREZ,"R",SE1->E1_CLIENTE+SE1->E1_LOJA)
											nPis	:= 	aPcc[2]
											nCofins	:=	aPcc[3]
											nCsll	:=  aPcc[4]
											nPisCalc	:= nPis
											nPisBaseC	:= nAltVal
											nPisBaseR 	:= nAltVal
											nCofCalc	:= nCofins	
											nCofBaseC	:= nAltVal
											nCofBaseR 	:= nAltVal
											nCslCalc	:= nCsll	
											nCslBaseC	:= nAltVal
											nCslBaseR 	:= nAltVal
											
											If lIrPjBxCr .And. cPaisLoc == "BRA"
												nIrrf	:= nIrrf * (nAltVal / SE1->E1_BASEIRF)
											EndIf
										EndIf
										aArray[nIt,nPosPis]		:= aDadosRA1[3][nItemRA]	:= nPis
										aArray[nIt,nPosCof]		:= aDadosRA1[4][nItemRA]	:= nCofins
										aArray[nIt,nPosCsl] 	:= aDadosRA1[5][nItemRA]	:= nCsll
								Else
									aArray[nIt,nPosPis]:=Transf(aDadosRA1[3][nItemRA],PesqPict("SE1","E1_PIS"))
									aArray[nIt,nPosCof]:=Transf(aDadosRA1[4][nItemRA],PesqPict("SE1","E1_COFINS"))
									aArray[nIt,nPosCsl]:=Transf(aDadosRA1[5][nItemRA],PesqPict("SE1","E1_CSLL"))
									EndIf
									aArray[nIt,nPosIrf]:=Transf(aDadosRA1[6][nItemRA],PesqPict("SE1","E1_IRRF"))
									If dDataBase < dLastPcc
									If cValor < cLimite
								   		cValor := cValor - (aDadosRA1[3][nItemRA]+aDadosRA1[4][nItemRA]+aDadosRA1[5][nItemRA]+aDadosRA1[6][nItemRA];
															+aDadosRA1[10][nItemRA]+aDadosRA1[11][nItemRA])
									Endif
									Else
										If cValor < cLimite
											cValor := cValor - (nPis+nCofins+nCsll)
											If lIrPjBxCr
												cValor	:= cValor - nIrrf
											EndIf
										EndIf
									EndIf
								EndIf
								aArray[nIt,9] := cValor
							EndIf
						Endif
					EndIf
				EndIf
				
				If lPccBxCr .And. !lRaRtImp //.and. (cValor <> cSaldo .or. nValrec <> cLimite)
					nTotAbat := SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",SE1->E1_MOEDA,,SE1->E1_CLIENTE,,SE1->E1_FILIAL)
					If ((cValor <= cLimite .and. SE1->E1_SALDO - nPis -nCofins - nCsll - nTotAbat <> cValor) .Or.;
								(SE1->(E1_PIS+E1_CSLL+E1_COFINS) > 0 .And. (nPis+nCofins+nCsll) == 0 .And. cValor <= cLimite .And. mv_par08 == 1))//essa cond ocorre quando os tít são marca indiv, removido a seleç e depois selec todos.
						For nX:=1 to Len(aArray) // verifica todos os títulos ja marcados
							If	aArray[nX,8] 
								nVTit+=Fa330VTit(aArray[nX,7])
							Endif
						Next
						If lMSal
							cValor	:= cOldVl
						EndIf
						If nVtit + cValor == SE1->E1_VALOR - SE1->E1_PIS - SE1->E1_COFINS - SE1->E1_CSLL - nTotAbat
							nAltVal := SE1->E1_SALDO - nVtit // se os titulos ja marcados + o titulo do momento for igual o liquido, deve calcular pelo restante do saldo.
						Else
							nAltVal := Iif(MV_PAR08==1, (cValor + Iif(lIrPjBxCr, SE1->E1_IRRF, 0) + If(lTodos, 0, SE1->(E1_PIS+SE1->E1_COFINS+SE1->E1_CSLL)) + nTotAbat), cValor)
						EndIf
						
						If (aArray[nIt,4] $ MV_CRNEG .and.  SE1->E1_SALDO - nTotAbat == cValor) .or. (lNCC .and.  SE1->E1_SALDO - nValAbat == cValor ) 
							//baixa total
							nAltVal := SE1->E1_SALDO
						EndIf	
						
						If dDataBase >= dLastPcc
						
							/*------------------------------------------------------ Augusto Ribeiro | 18/07/2017 - 2:49:20 PM
								Correção Paleativo PCC base diferenciada
							------------------------------------------------------------------------------------------*/
							IF SE1->E1_VALOR <> SE1->E1_BASEPIS					
								IF (SE1->E1_VALOR   - nAltVal) <= 0.05
									 nAltVal	:= SE1->E1_BASEPIS				
								ELSE 
									IF 	SE1->E1_VALOR > SE1->E1_SALDO
										_nPropBase	:= (SE1->E1_BASEPIS * 100)/ SE1->E1_VALOR
										nAltVal		:=  nValRec *(_nPropBase / 100)
									ELSE
										nAltVal	:= SE1->E1_BASEPIS	
									ENDiF
								ENDIF
							ENDIF
						
							aPcc	:= newMinPcc(dBaixa,nAltVal,SE1->E1_NATUREZ,"R",SE1->E1_CLIENTE+SE1->E1_LOJA)
							nPis	:= 	aPcc[2]
							nCofins	:=	aPcc[3]
							nCsll	:=  aPcc[4]
														
							nPisCalc	:= nPis
							nPisBaseC	:= nAltVal	
							nPisBaseR 	:= nAltVal
							nCofCalc	:= nCofins	
							nCofBaseC	:= nAltVal
							nCofBaseR 	:= nAltVal
							nCslCalc	:= nCsll	
							nCslBaseC	:= nAltVal
							nCslBaseR 	:= nAltVal
							
							If lIrPjBxCr .And. cPaisLoc == "BRA"
								nIrrf	:= nIrrf * (nAltVal / SE1->E1_BASEIRF)
							EndIf
						EndIf
						If !lBq10925
							cValor := cValor - nPis - nCofins - nCsll - Iif (lIrPjBxCr,nIrrf,0)
						EndIf
					
						aArray[nIt,nPosPis]	:= Transf(nPis,PesqPict("SE1","E1_PIS"))
						aArray[nIt,nPosCof]	:= Transf(nCofins,PesqPict("SE1","E1_COFINS"))
						aArray[nIt,nPosCsl]	:= Transf(nCsll,PesqPict("SE1","E1_CSLL"))					
					EndIf
				EndIf
				
				If lTodos .And. lPccBxCr .And. !lRaRtImp .And. mv_par08 == 1
					aArray[nIt,7]		:=Transf((cValor-nPis-nCofins-nCsll),PesqPict("SE1","E1_SALDO"))
					//Vld para ñ gerar mov.diferentes
					cValor := If(lBq10925, Val(StrTran(aArray[nIt,7], ".", "")), cValor) 
					aArray[nIt,9] := cValor					 
				Else				
					aArray[nIt,7] := Transf(cValor,PesqPict("SE1","E1_SALDO"))
				EndIf
				
				aArray[nIt,9]		:=cValor
				aArray[nIt,nPosPis]	:=Transf(nPis,PesqPict("SE1","E1_PIS"))
				aArray[nIt,nPosCof]	:=Transf(nCofins,PesqPict("SE1","E1_COFINS"))
				aArray[nIt,nPosCsl]	:=Transf(nCsll,PesqPict("SE1","E1_CSLL"))
				aArray[nIt,nPosBPCC]:=Transf(nAltVal,PesqPict("SE1","E1_CSLL"))
				aArray[nIt,nPosBPCR]:=Transf(nAltVal,PesqPict("SE1","E1_CSLL"))
				
				If cValor <> nValRec // cvalor é uma variavel numerica
					nValRec	:= cValor
				EndIf
			Endif
	    Else
			aArray[nIt,8] := !aArray[nIt,8]
			If aArray[nIt,4] $ MV_CRNEG
				F330VALNCC(@aArray,nIt, cValor < cLimite, .F.)
			Endif
		Endif
	Else
		If  !aArray[nIt,8]
			aArray[nIt,7]:=Transf(0,PesqPict("SE1","E1_SALDO"))
			If cPaisLoc == "BRA"
				aArray[nIt,9] := 0
				If lCredito
					dbSelectArea("SE1")
					If MV_PAR02 == 2
						dbGoTo(aArray[nIt,23])
					Else
				   		dbGoTo(aArray[nIt,20])
				    Endif
					If mv_par08 == 1 .OR. lRaRtImp
						nTotAbat := SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",SE1->E1_MOEDA,,SE1->E1_CLIENTE)
					Else
						nTotAbat := 0
					Endif

					u_F330CalcPCC(nIt,aArray,@cValor+If(cValor==cSalTit,nTotAbat,0),cValor < cLimite)
				Endif
				If lIrPjBxCr .and. lCredito
					nIrrf:=FCaIrBxCR(aArray[nIt,9])
					If (nPosIr:=ascan(aImpIR,{|x| x[2]=SE1->(REcno())}))=0
						aAdd(aImpIR,{nIrrf,SE1->(Recno())})
						nPosIr := Len( aImpIR )
					else
						aImpIR[nPosIr][1]:= nIrrf
					EndIf
				EndIf
			Endif
		Endif

		FA330UnLock(aArray[nIt,1]+aArray[nIt,2]+aArray[nIt,3]+aArray[nIt,4],,aArray[nIt,Iif(MV_PAR02== 2, 16,13)])

	Endif
	//If lMSal .And. Val(StrTran(Replace(aArray[nIt][6],".",""),",",".")) > cOldVl // lMSal .And. cValor > cOldVl
		//aArray[nIt][6] 	:= Transform(cOldVl,"@E 999,999,999,999.99")
		//aArray[nIt][7]	:= Transf(cOldVl,PesqPict("SE1","E1_SALDO"))
		//cValor	:= cOldVl
	//EndIf
Next

For nX:=1 to Len(aArray)
	If	aArray[nX,8]
		nValtot+=Fa330VTit(aArray[nX,7])
	Endif
Next

nIt := nOldIt

If oGet != Nil
	oGet:Refresh()
Endif

If ExistBlock("F330ATLIS")
	ExecBlock("F330ATLIS",.F.,.F., {  , 2 , nValTot, nValor } )
EndIf  

RestArea(aAreaSE1)
Return aArray

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³Fa330SetMo³ Autor ³ Fernando Machima      ³ Data ³ 19/02/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Tela de taxas de moedas                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Fa330SetMo												  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Fa330SetMo()
Local oDlg
Local nLenMoedas	:= Len(aTxMoedas)
Local nI            := 1
Local nLinTelaF  							//altura da tela de fora
Local nLinTelaD								// altura da tela de dentro
Local nLinButton
Local aSay := {}
Local aGet := {}
Local cBlKMoeda

nLinTelaD	:=  05 + ((nLenMoedas-1) * 16)			// altura da tela de dentro	-> 14-tamanho de cada linha -> 5-sobra em cima e em baixo
nLinTelaF  	:= 200 + ((nLenMoedas-1) * 30.5) + 50	// altura da tela de fora -> 200-onde comecou a tela -> 30,5-equivalente por linha -> 35-botao e sobras da tela

nLinButton  :=  03 + nLinTelaD

If nLenMoedas > 1
	DEFINE MSDIALOG oDlg From 200,0 TO nLinTelaF,230 TITLE STR0037 PIXEL  //Taxas Moedas
		@ 005,005  To nLinTelaD,110 OF oDlg PIXEL

		For nI := 1 To nLenMoedas-1
			cBlKMoeda := "{|| aTxMoedas["+AllTrim(Str(ni+1))+",1]}"
			aAdd(aSay, TSay():New(1+(ni*12),010,&cBlKMoeda,oDlg,,, .F., .F., .T.,.T.,,,,, .F., .F., .F., .F.))
		    aAdd(aGet, TGet():New((ni*12)-2,060,&("{|x| If(x <> NIL,aTxMoedas["+AllTRim(Str(ni+1))+",2] := x,aTxMoedas["+Str(ni+1)+",2])}"),oDlg,45,,aTxMoedas[nI+1,3],,,,,,,.T.,,,,.F.,.T.,,.F.,.F.,,,,.F.,,.T.))
		Next nI

	DEFINE  SButton FROM (nLinTelaD + 5),80 TYPE 1 Action (oDlg:End() ) ENABLE OF oDlg  PIXEL

	ACTIVATE MSDIALOG oDlg CENTERED
Else
	Help("",1,"NoMoneda")
Endif
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºRotina    ³Fa330TudOkºAutor  ³Claudio D. de Souza º Data ³  29/11/01   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Validar os campos informados na compensacao                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Fina330                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Fa330TudOk(nVlrCompe)

Local lRet := .T.
Default nVlrCompe := 0

Do Case
Case EMPTY(cNum)
	lRet := .F.
Case !fa330Cli()
	lRet := .F.
Case !Fa330Loja()
	lRet := .F.
Case !(nValor >= 0 .AND. STR(nValor,17,2) <= STR(nSaldo,17,2))
	lRet := .F.
Case !(dBaixa >= SE1->E1_EMISSAO)
	lRet := .F.
Case !lCredito
	If Empty(cTipoTit) .Or.	!(!cTipoTit $ MVABATIM .AND. 	!(cTipoTit $ MVRECANT+"/"+MV_CRNEG))
		lRet := .F.
	Endif
Case lCredito
	If Empty(cTipoTit) .Or. !(!cTipoTit $ MVABATIM .AND. (cTipoTit $ MVRECANT+"/"+MV_CRNEG))
		lRet := .F.
	Endif

EndCase

//Possibilita novas validacoes
If ExistBlock("F300VALID")
	lRet := ExecBlock	("F300VALID",.F.,.F.,nVlrCompe)
EndIf

REturn lRet


Static Function fMarkAll(aTit, nValor, lEstorno)

Local nI := 0
Local nPosMarca := 8
Local bReturn:=.T.

Default lEstorno := .F.

nPosMarca := Iif( lEstorno, 11, nPosMarca )

If Len(aTit) > 0
	For nI := 1 to Len(aTit)
		If !aTit[nI,nPosMarca]
			bReturn:=.F.
			If !lEstorno
				aTit[nI][7]:= aTit[nI][22]
			EndIf
		EndIf
	Next
EndIf

If lEstorno
	aEval(@aTit, {|e| e[nPosMarca] := !bReturn } )
Else
	nValTot := 0
	aEval(@aTit, {|e|	e[nPosMarca] := !bReturn, ;
						If(e[nPosMarca],(If(Fa330VTit(e[7])=0,e[7]:=e[6],Nil),nValTot += Fa330VTit(e[7]),;
						Iif(cPaisLoc=="BRA",e[9]:=DesTrans(e[7]), IIf( MV_PAR02==02, e[12]:=DesTrans(e[7]), .T.))),;
						(e[7]:=Transf(0,"@E 9999,999,999.99"), Iif(cPaisloc=="BRA",e[9]:=DesTrans(e[7]),IIf( MV_PAR02==02, e[12]:=e[7], e[11]:=e[7]) )))})
EndIf

Return bReturn


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Fa330Leg   ³ Autor ³ Mauricio Pequim Jr   ³ Data ³ 20.07.04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Cria uma janela contendo a legenda da mBrowse              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FINA330                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Fa330Leg(nReg)
Local uRetorno := .T.
Local aLegenda := {	{"ENABLE"		, 	STR0051	},; //"Titulo nao Compensado"
				   	{"DISABLE"		, 	STR0052	},; //"Titulo Compensado Totalmente"
					{"BR_AZUL"		,  STR0053	}} //"Titulo Compensado Parcialmente"


If nReg = Nil	// Chamada direta da funcao onde nao passa, via menu Recno eh passado
	uRetorno := {}
	Aadd(uRetorno, {'E1_SALDO =  0', aLegenda[2][1]})			// Titulo Compensado Totalmente
	Aadd(uRetorno, {'E1_SALDO =  E1_VALOR', aLegenda[1][1]}) // Titulo nao Compensado
	Aadd(uRetorno, {'E1_SALDO <> 0', aLegenda[3][1]})			// Titulo Compensado Parcialmente
Else
	BrwLegenda(cCadastro,STR0047,aLegenda)  //"Legenda"
Endif

Return uRetorno

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PesqListBox³ Autor ³ Edson Maricate       ³ Data ³ 09.02.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Monta uma pesquisa de texto em um listBox.                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Geral                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function PesqListBox(oListBox,aListBox)

Local nFound
Local aParam	:= {}

PRIVATE mv_par01 // Declara as variaveis private para não conflitar com as variaveis da pergunte
PRIVATE mv_par02
PRIVATE mv_par03

If ParamBox( { { 1,STR0001 ,Padr(__PesqList,200),"@" 	 ,""  ,""    ,"" ,120 ,.T. },;
				{5,STR0056,.F.,90,,.F.},;
				{5,STR0057,.F.,90,,.F.} }, STR0001 , aParam, , , , , , , , .F. )

	__PesqList := aParam[1]
	If aParam[2]
		If aParam[3]
			nFound := aScan(aListBox,{|x| aScan(x,{|x| AllTrim(aParam[1])$AllTrim(x) } )>0 },oListBox:nAt+1)
		Else
			nFound := aScan(aListBox,{|x| aScan(x,{|x| AllTrim(aParam[1])$AllTrim(x) } )>0 })
		EndIf
	Else
		If aParam[3]
			nFound := aScan(aListBox,{|x| aScan(x,{|x| UPPER(AllTrim(aParam[1]))$UPPER(AllTrim(x)) } )>0 },oListBox:nAt+1)
		Else
			nFound := aScan(aListBox,{|x| aScan(x,{|x| UPPER(AllTrim(aParam[1]))$UPPER(AllTrim(x)) } )>0 })
		EndIf
	EndIf
	If nFound <= 0
		Aviso(STR0058, STR0059,{"Ok"},2)
	Else
		oListBox:nAt := nFound
		oListBox:Refresh()
	EndIf

EndIf


Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Fa330IntPco ºAutor ³Paulo Carnelossi    º Data ³  22/11/06  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³funcao que gera os lancamentos no sigapco (PcoDetLan())     º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function Fa330IntPco(nRecSE1, aRecnoSE1, aBaixasSE5)
Local aArea := GetArea()
Local aAreaSE1 := SE1->(GetArea())
Local aAreaSE5 := SE5->(GetArea())
Local nX

If SuperGetMV("MV_PCOINTE",.F.,"2")=="1"

	dbSelectArea("SE1")
	dbGoto(nRecSE1) //titulo principal apos a compensacao

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Grava lançamento no PCO ref titulo principal apos a compensacao    ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	PCODetLan("000016","01","ZFINA330")

	For nX := 1 TO Len(aRecnoSE1) // ARRAY COM REGISTROS TITULOS COMPENSADOS

		//grava lcto ref. titulo compensado
		dbSelectArea("SE1")
		dbGoto(aRecnoSE1[nX])
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Grava lançamento no PCO ref titulo compensado apos a compensacao   ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		PCODetLan("000016","02","ZFINA330")

		//grava lctos das baixas referente titulo principal e titulo compensado
		dbSelectArea("SE5")
		If Len(aBaixasSE5) > 0
			dbGoto(aBaixasSE5[(nX*2)-1])
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Grava lançamento no PCO ref baixa (Mov.Bancaria-SE5) do titulo principal apos a compensacao   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			PCODetLan("000016","03","ZFINA330")

			dbGoto(aBaixasSE5[(nX*2)])
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Grava lançamento no PCO ref baixa do titulo compensado (Mov.Bancaria-SE5)  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			PCODetLan("000016","04","ZFINA330")
		EndIf

	Next

EndIf

RestArea(aAreaSE5)
RestArea(aAreaSE1)
RestArea(aArea)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Ana Paula N. Silva     ³ Data ³23/11/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³		1 - Pesquisa e Posiciona em um Banco de Dados     ³±±
±±³          ³    2 - Simplesmente Mostra os Campos                       ³±±
±±³          ³    3 - Inclui registros no Bancos de Dados                 ³±±
±±³          ³    4 - Altera o registro corrente                          ³±±
±±³          ³    5 - Remove o registro corrente do Banco de Dados        ³±±
±±³          ³5. Nivel de acesso                                          ³±±
±±³          ³6. Habilita Menu Funcional                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()
Local lFA330LIB := Existblock("FA330LIB")
Local aRetorno  := {}
Local aRotina   := { {STR0001,"AxPesqui"  , 0 , 1,,.F. },;  // "Pesquisar"
	                  {STR0002,"AxVisual"  , 0 , 2 },;        // "Visualizar"
	                  {STR0003,"U_Fa330Comp" , 0 , 4 },;        // "Compensar"
 	                  {STR0004,"Fa330Desc" , 0 , 4 },;        // "Excluir"
                  	{STR0054,"Fa330Desc" , 0 , 4 },;        //"Estornar"
                  	{STR0047 , "Fa330Leg"  ,0,2, ,.F.} }    //"Legenda"

 If lFA330LIB
  aRetorno := ExecBlock("FA330LIB",.F.,.F.,{aRotina})
  aRotina  := AClone(aRetorno)
 Endif

Return(aRotina)


//------------------------------------------------------------------------------------------------------------------------------------------------

Static Function FA330aUnlock()
Local aArea := GetArea()
If aRLocks == Nil
	aRLocks:={}
Endif
//**********************************************
// Retirado para permitir utilizacao de rotina *
// automatica dentro de transacao no banco     *
//**********************************************
//AEval(aRLocks,{|x,y| SE1->(MsRUnlock(x))})
AEval(aRLocks,{|x,y| SE1->(DbGoTo(x)),MsUnLock() })
aRLocks:={}
RestArea(aArea)
Return

//------------------------------------------------------------------------------------------------------------------------------------------------


Static Function FA330Unlock(cChave,nRecno,cfilorig)
Local aArea
Local nPosRec
If aRLocks == Nil
	aRLocks:={}
Endif
If nRecno <> Nil
	SE1->(MsGoto(nRecno))
Else
	aArea	:=	getArea()
	SE1->(DbSetOrder(1))
	SE1->(MsSeek(cfilorig+cChave))
Endif

//**********************************************
// Retirado para permitir utilizacao de rotina *
// automatica dentro de transacao no banco     *
// **********************************************
//SE1->(MsRUnlock(SE1->(Recno())))
SE1->(MsUnlock())


If (nPosRec:=Ascan(aRLOCKS,SE1->(REcno()))) > 0
	Adel(aRlocks,nPosRec)
	aSize(aRlocks,Len(aRlocks)-1)
Endif

If aArea <> Nil
	RestArea(aArea)
Endif

Return

//------------------------------------------------------------------------------------------------------------------------------------------------

Static Function FA330Lock(cChave,nRecno,lHelp,cfilOrig)
Local aArea
Local lRet	:=	.F.
DEFAULT lHelp	:=	.T.

If aRLocks == Nil
	aRLocks:={}
Endif

If nRecno <> Nil
	SE1->(MsGoto(nRecno))
Else
	aArea	:=	SE1->(getArea())
	SE1->(DbSetOrder(1))
	SE1->(MsSeek(cfilorig+cChave))
Endif

//**********************************************
// Retirado para permitir utilizacao de rotina *
// automatica dentro de transacao no banco     *
// **********************************************
//If SE1->(MsRLock())
If  SE1->(RecLock("SE1",.F.))
	AAdd(aRLocks, SE1->(Recno()))
	lRet	:=	.T.
ElseIf lHelp
	MsgAlert(STR0060)
Endif
If aArea <> Nil
	RestArea(aArea)
Endif

Return lRet


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FinA330T   ³ Autor ³ Marcelo Celi Marques ³ Data ³ 27.03.08 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Chamada semi-automatica utilizado pelo gestor financeiro   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FINA330                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FinA330T(aParam)

	cRotinaExec := "ZFINA330"
	ReCreateBrow("SE1",FinWindow)
	FinA330(aParam[1])
	FinVisual(FinWindow:cAliasFile,FinWindow,(FinWindow:cAliasFile)->(Recno()),.T.)
	ReCreateBrow("SE1",FinWindow)
	dbSelectArea("SE1")

	INCLUI := .F.
	ALTERA := .F.

Return .T.

//------------------------------------------------------------------------------------------------------------------------------------------------

Static Function F330SldPri(nRecNo)
Local aArea := SE1->(GetArea())
Local nSaldo := 0

SE1->(DbGoTo(nRecNo))
nSaldo := SE1->E1_SALDO

RestArea(aArea)

Return nSaldo

//------------------------------------------------------------------------------------------------------------------------------------------------

User Function F330CalcPCC(nIt,aArray,cValor, lAltValor)

Local nPosPis := 14		//Posicao Pis na Tela
Local nPosCof := 15		//Posicao Cofins na Tela
Local nPosCsl := 16		//Posicao Csll na Tela
Local nPVRPis := 17		//Posicao Valor Retido Pis na Tela
Local nPVRCof := 18		//Posicao Valor Retido Cofins na Tela
Local nPVRCsl := 19		//Posicao Valor Retido Csll na Tela
Local nPosRec := 20		//Posicao Recno na Tela
Local nPisJaRet := 0
Local nPisARet := 0
Local nCofJaRet := 0
Local nCofARet := 0
Local nCslJaRet := 0
Local nCslARet := 0
Local nX	:= 0
Local cRetCli := "1"
Local lPccBxCr	:= FPccBxCr()
Local nPropPcc	:= 0
Local nVlrTitSel	:= 0  
Local nValPcc	:= 0  
Local ni	:= 0    
Local nRecTit	:= 0
Local nTotAdto		:= 0
Local lBaixaAbat	:= .F.
Local nVlrBaixa		:= 0
Local lBxCec		:= .F.
Local lBxLiq		:= .F.
Local lSigaloja		:= .F.
Local lTipBxCP  	:= .F.
Local nTAbt			:= 0
Default lAltValor := .F.

If cPaisLoc == "BRA" .and. lPccBxCr
	//Caso considere diferentes clientes
	If MV_PAR02 == 2
		nPosPis := 17
		nPosCof := 18
		nPosCsl := 19
		nPVRPis := 20		//Posicao Valor Retido Pis na Tela
		nPVRCof := 21		//Posicao Valor Retido Cofins na Tela
		nPVRCsl := 22		//Posicao Valor Retido Csll na Tela
		nPosRec := 23
		nPosBPCC := 27
		nPosBPCR := 28
	Endif

	SE1->(DbGoTo(aArray[nIt,nPosRec]))
	nValrec := cValor 	//Esta variaves esta numerica apesar da notacao.
	nOldValRec := 	nValRec

	cRetCli := Iif(Empty(SA1->A1_ABATIMP),"1",SA1->A1_ABATIMP)

	If aArray[nIt,8]
		If cRetCli == "1"  //Calculo do sistema
			nValRecAtu := nValRec
			For nX := nIt To Len(aArray)
				If	aArray[nX,8]
					nValRec   += Fa330VTit(aArray[nX,7])
					If mv_par08 == 2
						nValRec   += Fa330VTit(aArray[nX,nPosPis])
						nValRec   += Fa330VTit(aArray[nX,nPosCof])
						nValRec   += Fa330VTit(aArray[nX,nPosCsl])
						nPisJaRet += Fa330VTit(aArray[nX,nPosPis])
						nPisARet  += Fa330VTit(aArray[nX,nPVRPis])
						nCofJaRet += Fa330VTit(aArray[nX,nPosCof])
						nCofARet  += Fa330VTit(aArray[nX,nPVRCof])
						nCslJaRet += Fa330VTit(aArray[nX,nPosCsl])
						nCslARet  += Fa330VTit(aArray[nX,nPVRCsl])
					EndIf
				EndIf
			
				If (Len(aArray) > nX)
					If aArray[(nX+1),8]
						Exit
					EndIf
				EndIf			
			Next

			nVlrTitSel := nValRec
			If ( nPisJaRet + nCofJaRet + nCslJaRet ) > 0
				nValRec    := nOldValRec
			EndIf
			
			aBaixa := Sel070Baixa( "VL /V2 /BA /RA /CP /LJ /" + MV_CRNEG, SE1->E1_PREFIXO,SE1->E1_NUM, SE1->E1_PARCELA, SE1->E1_TIPO,;
				@nTotAdto, @lBaixaAbat, SE1->E1_CLIENTE, SE1->E1_LOJA, @nVlrBaixa, , @lBxCec, @lBxLiq ,@lSigaloja ,@lTipBxCP)
			
			nTAbt	:= SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",SE1->E1_MOEDA,,SE1->E1_CLIENTE,,SE1->E1_FILIAL)
			
			If dDataBase < dLastPcc
				f070TotMes(dBaixa,.T.)
			Else
				If lAltValor
					nValPcc	:= nValRec
				Else
					nValPcc	:= SE1->E1_VALOR - nTotAdto
				EndIf	
				
				/*------------------------------------------------------ Augusto Ribeiro | 18/07/2017 - 2:49:20 PM -- 
					Correção Paleativo PCC base diferenciada - primeira passagem na seleção do titulo					
				------------------------------------------------------------------------------------------*/
				IF SE1->E1_VALOR <> SE1->E1_BASEPIS					
					IF ((SE1->(E1_VALOR - E1_IRRF - E1_CSLL - E1_COFINS - E1_PIS))  - nValRec) <= 0.05 
						nValPcc	:= SE1->E1_BASEPIS				
					ELSE 
					 	IF 	SE1->E1_VALOR > SE1->E1_SALDO
							_nPropBase	:= (SE1->E1_BASEPIS * 100)/ SE1->E1_VALOR
							nValPcc		:=  nValRec *(_nPropBase / 100)
						ELSE
							nValPcc	:= SE1->E1_BASEPIS	
						ENDiF
					ENDIF
				ENDIF
				
				
				aPcc		:= newMinPcc(dBaixa,nValPcc,SE1->E1_NATUREZ,"R",SE1->E1_CLIENTE+SE1->E1_LOJA)
				nPis	:= aPcc[2]
				nCofins	:= aPcc[3]
				nCsll	:= aPcc[4]
				If !lAltValor .and. !lRartimp .and. mv_par08 == 1 .and. !lCredito /*SE1->E1_TIPO == MVNOTAFIS*/ .and. (SE1->E1_SALDO - Iif(lPccBxCr,0,nPis - nCofins - nCsll) - nTAbt <> nValRec )//.and. SE1->E1_SALDO - nPis - nCofins - nCsll - nTAbt == SE1->E1_SALDO) // compensado pelo valor liquido 
					nValPcc	:= nValRec
					aPcc		:= newMinPcc(dBaixa,nValPcc,SE1->E1_NATUREZ,"R",SE1->E1_CLIENTE+SE1->E1_LOJA)
					nPis	:= aPcc[2]
					nCofins	:= aPcc[3]
					nCsll	:= aPcc[4]
				EndIf
				//Reestruturacao SE5 - Para gravação das tabelas FK3 e FK4
				nPisCalc	:= nPis
				nPisBaseC	:= nValPcc	
				nPisBaseR 	:= nValPcc
				nCofCalc	:= nCofins	
				nCofBaseC	:= nValPcc
				nCofBaseR 	:= nValPcc
				nCslCalc	:= nCsll	
				nCslBaseC	:= nValPcc
				nCslBaseR 	:= nValPcc
			EndIf
			nValRec    	:= nVlrTitSel
			nOldvalRec	:= nVlrTitSel

			If dDataBase < dLastPcc
				If ( MV_PAR08 == 1 .Or. lRaRtImp ) .And. ( lAltValor .Or. nValRecAtu < SE1->E1_SALDO );
					 .And. (!lRaRtImp .And. (nValRecAtu+(nCofins+nCsll+nPis+nIrrf+nTAbt))< SE1->E1_SALDO)
					nPropPcc := (nValRecAtu*(nCofins+nCsll+nPis))/SE1->E1_VLCRUZ
					nPropPcc := (nPropPcc/ (nCofins+nCsll+nPis) )
					nPis	:= Round(NoRound(SE1->E1_PIS * nPropPCC,3),2)
					nCofins	:= Round(NoRound(SE1->E1_COFINS * nPropPCC,3),2)
					nCsll	:= Round(NoRound(SE1->E1_CSLL * nPropPCC,3),2)
					nPisBaseR 	:= Round(NoRound(SE1->E1_BASEPIS * nPropPCC,3),2)
					nPisBaseC 	:= Round(NoRound(SE1->E1_BASEPIS * nPropPCC,3),2)

				nValRec := nValRecAtu
				Else
					nValRec := nValRecAtu
					nPis := nPis + nPisARet - nPisJaRet
					nCofins := nCofins + nCofARet - nCofJaRet
					nCsll := nCsll + nCslARet - nCslJaRet
				EndIf
			EndIf

		ElseIf cRetCli == "2"	//Sempre calcula
			nPropPcc := nValrec/SE1->E1_VLCRUZ
			nPis		:= Round(NoRound(SE1->E1_PIS * nPropPCC,3),2)
			nCofins	    := Round(NoRound(SE1->E1_COFINS * nPropPCC,3),2)
			nCsll		:= Round(NoRound(SE1->E1_CSLL * nPropPCC,3),2)
			nPisBaseR 	:= Round(NoRound(SE1->E1_BASEPIS * nPropPCC,3),2)
			nPisBaseC 	:= Round(NoRound(SE1->E1_BASEPIS * nPropPCC,3),2)
			nVlRetPis	:= nPis
			nVlRetCof	:= nCofins
			nVlRetCsl	:= nCsll
			nValRec	-= (nPis+nCofins+nCsll)
		Else
			nPis		:= 0
			nCofins	:= 0
			nCsll		:= 0
			nVlRetPis:= 0
			nVlRetCof:= 0
			nVlRetCsl:= 0
		Endif
	Else
		nPis		:= 0
		nCofins	:= 0
		nCsll		:= 0
		nVlRetPis:= 0
		nVlRetCof:= 0
		nVlRetCsl:= 0
	Endif

	cValor	:= nValRec
	
	If mv_par08 == 1
		aArray[nIt,nPosPis] := Transform(nPis,"@E 99,999,999.99")
		aArray[nIt,nPosCof] := Transform(nCofins,"@E 99,999,999.99")
		aArray[nIt,nPosCsl] := Transform(nCsll,"@E 99,999,999.99")
	EndIf
	
	aArray[nIt,nPosBPCC] := Transform(nPisBaseC,"@E 99,999,999.99")
	aArray[nIt,nPosBPCR] := Transform(nPisBaseR,"@E 99,999,999.99")
	
	If MV_PAR02 == 2
		aArray[nIt,nPVRPis] := Transform(nVlRetPis,"@E 99,999,999.99")
		aArray[nIt,nPVRCof] := Transform(nVlRetCof,"@E 99,999,999.99")
		aArray[nIt,nPVRCsl] := Transform(nVlRetCsl,"@E 99,999,999.99")
	Endif
	
	For ni := 1 To Len(aTitulos)
		nRecTit	:= recno()
		If ValType(aTitulos[ni,20]) <> "C"
			If nRecTit == aTitulos[ni][20]
				aTitulos[ni][14]	:= aArray[nIt,nPosPis]
				aTitulos[ni][15]	:= aArray[nIt,nPosCof]
				aTitulos[ni][16]	:= aArray[nIt,nPosCsl]
			EndIf
		EndIf
	Next		
Endif

Return


//------------------------------------------------------------------------------------------------------------------------------------------------


Static Function F330GrvSFQ(cSequencia,nRecnoSE1)

Local nLoop		 := 0
Local nVlMinImp	 := GetNewPar("MV_VL10925",5000)
Local aRecnos	 := {}
Local cModRetPIS := SA1->A1_ABATIMP
Local nBaseRet	 := 0
Local lAplVlMin	 := .T.
Local nTamSeq	 := TamSX3("FQ_SEQORI")[1]
Local lPccBxCr	:= FPccBxCr()
Local nTit			:= 0
Local lIrPjBxCr		:= FIrPjBxCr()
Local lRaRtImp  	:= FRaRtImp()
Local lPropBx  := SuperGetMv("MV_PROPBX",.F.,"2") == "1"
// Variaveis para o Model de Alteração do SE5
Local aAreaFKs := {}
Local oModelCP := nil//FWLoadModel("FINM010")
Local oModelBA := nil//FWLoadModel("FINM010")
Local oSubFK1
Local oSubFK3
Local oSubFK4
Local cCamposE5 := ""
Local lRet := .T.
Local aImpostos := {}
Local nX
Local nSalvRec := SE1->(Recno())
Local oModelMov := Nil

DEFAULT cSequencia := Replicate("0",nTamSeq)
DEFAULT nRecnoSE1	:= 0

nIss     := If(Type("nIss") != "N",0,nIss)
nIrrf    := If(Type("nIrrf") != "N",0,nIrrf)
nValComp := If(Type("nValComp") != "N",0,nValComp)
nValLiq  := If(Type("nValLiq") != "N",0,nValLiq)
dBaixa	:= If(Type("dBaixa") != "D",dDataBase,dBaixa)
nTotAbat := If(Type("nTotAbat") != "N",SumAbatRec( SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,SE1->E1_MOEDA, "S"  ,dBaixa,,@nTotIrAbt,@nTotCsAbt,@nTotPisAbt,@nTotCofAbt,),nTotAbat)
nDescont := If(Type("nDescont") != "N",0,nDescont)
nMulta   := If(Type("nMulta") != "N",0,nMulta)
nJuros   := If(Type("nJuros") != "N",0,nJuros)
nAcresc  := If(Type("nAcresc") != "N",0,nAcresc)
nDecresc := If(Type("nDecresc") != "N",0,nDecresc)
lRetParc := If(Type("lRetParc") != "L",.T.,lRetParc)

nBaseRet		:= nValRec+nDescont+nTotAbat-nJuros-nMulta

If dDatabase >= dLastPcc
	nVlMinImp	:= 0
EndIf

//Verificar ou nao o limite de 5000 para Pis cofins Csll
// 1 = Verifica o valor minimo de retencao
// 2 = Nao verifica o valor minimo de retencao
If SE1->E1_APLVLMN == "2"
	lAplVlMin := .F.
Endif

If nRecnoSE1 > 0 .AND. AllTrim(cSequencia) != Replicate("0",nTamSeq)

	//Posiciona a FK1 para mandar a operação de alteração com base no registro posicionado da SE5
	If AllTrim( SE5->E5_TABORI ) == "FK1"
		aAreaFKs := GetArea()
		dbSelectArea( "FK1" )
		FK1->( DbSetOrder( 1 ) )
		If MsSeek( xFilial("FK1") + SE5->E5_IDORIG )
		//Manda o campo LA com o valor de 2 Caracteres, para manter a gravação original na E5
			SE1->(dbGoto(nRecnoSE1))
	   		cCamposE5:= "{"
   			cCamposE5+= "{'E5_VRETPIS', "+cValtoChar(nPis)+"}"
   			cCamposE5+= ",{'E5_VRETCOF', "+cValtoChar(nCofins)+"}"
    		cCamposE5+= ",{'E5_VRETCSL', "+cValtoChar(nCsll)+"}"
    		cCamposE5+= ",{'E5_VRETIRF', "+cValtoChar(nIrrf)+"}"
	   		cCamposE5+= "}"

			oModelMov := FWLoadModel("FINM010")
			oModelMov:SetOperation( 4 ) //Alteração
			oModelMov:Activate()
			oModelMov:SetValue( "MASTER", "E5_GRV", .T. ) //Habilita gravação de SE5
			oModelMov:SetValue( "MASTER", "E5_CAMPOS", cCamposE5 ) //Informa os campos da SE5 que serão gravados indepentes de FK1

			//Dados Contábeis
   			oSubFK1 := oModelMov:GetModel("FK1DETAIL")
   			oSubFK3 := oModelMov:GetModel("FK3DETAIL")
   			oSubFK4 := oModelMov:GetModel("FK4DETAIL")
   			      
   			//cIDFK1 := oSubFK1:GetValue("FK1_IDFK1")
   			cIDFK1 := FWUUIDV4()
			//------------------------------------------------------
			// Grava os valores agregados ao titulo no totalizador 
			//------------------------------------------------------
			//Reestruturacao SE5
			//aImpostos[1] = codigo imposto
			//aImpostos[2] = imposto calculado
			//aImpostos[3] = natureza
			//aImpostos[4] = cIdFK4															
			//aImpostos[5] = imposto retido
			//aImpostos[6] = base calculado
			//aImpostos[7] = base retencao 
			aadd(aImpostos,{"PIS" ,nPis ,		SuperGetMV("MV_PISNAT")		,"", nPis    , nPisBaseC, nPisBaseR})
			aadd(aImpostos,{"COF" ,nCofins ,	SuperGetMV("MV_COFINS")		,"", nCofins , nCofBaseC, nCofBaseR})
			aadd(aImpostos,{"CSL" ,nCsll ,		SuperGetMV("MV_CSLL")  		,"", nCsll   , nCslBaseC , nCslBaseR})
							
			//Grava FK3 E/OU FK4
			For nX := 1 to Len(aImpostos)
				//Gravar FK4 se os valores de PCC forem maiores que zero IMPOSTOS
				If aImpostos[nX][2] > 0
                       
					cIdFK4 := ""
					If aImpostos[nX][5] > 0   //Houve retencao
						cIdFK4:= GetSx8Num('FK4', 'FK4_IDFK4')
						aImpostos[nX,4] := cIdFK4

						//Guardo o IDFK4 do IRF para usar posteriormente
						If aImpostos[nX,1] == "IRF"
							cIdFk4IR := cIdFK4
						Endif

               		Endif
	                        
					If !oSubFK3:IsEmpty()
						//Inclui a quantidade de linhas necessárias
						oSubFK3:AddLine()		
						
						//Vai para linha criada
						oSubFK3:GoLine( oSubFK3:Length() )	
					Endif	
		
					//---------------------------------------------
					// Grava Imposto calculado
					//---------------------------------------------
					oSubFK3:SetValue( "FK3_IDFK3" , GetSx8Num('FK3', 'FK3_IDFK3'))
					oSubFK3:SetValue( "FK3_DATA"  , dDataBase )
					oSubFK3:SetValue( "FK3_ORIGEM", FunName() )
					oSubFK3:SetValue( "FK3_IMPOS" , aImpostos[nX][1] )
					oSubFK3:SetValue( "FK3_RECPAG", "R" )
					oSubFK3:SetValue( "FK3_MOEDA" , "01" )
					oSubFK3:SetValue( "FK3_VALOR" , aImpostos[nX][2] )
					oSubFK3:SetValue( "FK3_NATURE", aImpostos[nX][3] )
					oSubFK3:SetValue( "FK3_FILORI", SE1->E1_FILORIG  )
					oSubFK3:SetValue( "FK3_BASIMP", aImpostos[nX][6] )
					oSubFK3:SetValue( "FK3_IDORIG", cIdFK1 )
					oSubFK3:SetValue( "FK3_TABORI", "FK1") 
                 oSubFK3:SetValue( "FK3_IDRET" , aImpostos[nx,4] )       
		
					//---------------------------------------------
					// Grava Imposto Retido
					//---------------------------------------------
					If aImpostos[nX][5] > 0   //Houve retencao
						If !oSubFK4:IsEmpty()
							//Inclui a quantidade de linhas necessárias
							oSubFK4:AddLine()		
						
							//Vai para linha criada
							oSubFK4:GoLine( oSubFK4:Length() )	
						Endif	
	
						oSubFK4:SetValue( "FK4_IDFK4" , aImpostos[nx,4])
						oSubFK4:SetValue( "FK4_DATA"  , dDataBase )
						oSubFK4:SetValue( "FK4_ORIGEM", FunName() )
						oSubFK4:SetValue( "FK4_IMPOS" , aImpostos[nx,1] )
						oSubFK4:SetValue( "FK4_RECPAG", "R" )
						oSubFK4:SetValue( "FK4_MOEDA" , "01" )
						oSubFK4:SetValue( "FK4_VALOR" , aImpostos[nX,5] )
						oSubFK4:SetValue( "FK4_NATURE", aImpostos[nX,3])
						oSubFK4:SetValue( "FK4_FILORI", SE1->E1_FILORIG )
						oSubFK4:SetValue( "FK4_BASIMP", aImpostos[nX][7] )
					Endif					
				Endif
			Next

			If oModelMov:VldData()
       	   		oModelMov:CommitData()
   	   			   	SE5->(dbGoto(oModelMov:GetValue( "MASTER", "E5_RECNO" )))
			Else
	       	lRet := .F.
		   	 	cLog := cValToChar(oModelMov:GetErrorMessage()[4]) + ' - '
		   	 	cLog += cValToChar(oModelMov:GetErrorMessage()[5]) + ' - '
		   	 	cLog += cValToChar(oModelMov:GetErrorMessage()[6])
       		Help( ,,"M010VALID",,cLog, 1, 0 )
 			Endif
			oModelMov:DeActivate()
			oModelMov:Destroy()
			oModelMov:= nil
		Else //Se não achou o registro na FK1
			lRet := .F.
		Endif
		RestArea(aAreaFKs)
	Else //Se a origem do registro posicionado não for FK1
		lRet := .F.
	Endif

	Do Case
	Case cModRetPIS == "1"
		If (aDadosRet[ 1 ] + nValRec > nVlMinImp) .or. !lAplVlMin
			If (!lRaRtImp .and. !(SE5->E5_TIPO == MVRECANT) .and. aDadosRet[ 1 ] + nValRec > nVlMinImp)
			nSalvRec := SE5->( Recno() )
			lRetParc := .T.

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Exclui a Marca de "pendente recolhimento" dos demais registros   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If aDadosRet[1] > 0
				aRecnos := aClone( aDadosRet[ 6 ] )

				cPrefOri  := SE5->E5_PREFIXO
				cNumOri   := SE5->E5_NUMERO
				cParcOri  := SE5->E5_PARCELA
				cTipoOri  := SE5->E5_TIPO
				cCfOri    := SE5->E5_CLIFOR
				cLojaOri  := SE5->E5_LOJA

				For nLoop := 1 to Len( aRecnos )

					SE5->( dbGoto( aRecnos[ nLoop ] ) )

					RecLock( "SE5", .F. )

					If !Empty(SE5->E5_PRETPIS) .And. !Empty(SE5->E5_PRETCOF) .And. !Empty(SE5->E5_PRETCSL)
						SE5->E5_PRETPIS := "2"
						SE5->E5_PRETCOF := "2"
						SE5->E5_PRETCSL := "2"
					EndIf

					SE5->( MsUnlock() )

					If nSalvRec <> aRecnos[ nLoop ]
						dbSelectArea("SFQ")
						RecLock("SFQ",.T.)
						SFQ->FQ_FILIAL  := xFilial("SFQ")
						SFQ->FQ_ENTORI  := "E1B"
						SFQ->FQ_PREFORI := cPrefOri
						SFQ->FQ_NUMORI  := cNumOri
						SFQ->FQ_PARCORI := cParcOri
						SFQ->FQ_TIPOORI := cTipoOri
						SFQ->FQ_CFORI   := cCfOri
						SFQ->FQ_LOJAORI := cLojaOri
						SFQ->FQ_SEQORI  := cSequencia

						SFQ->FQ_ENTDES  := "E1B"
						SFQ->FQ_PREFDES := SE5->E5_PREFIXO
						SFQ->FQ_NUMDES  := SE5->E5_NUMERO
						SFQ->FQ_PARCDES := SE5->E5_PARCELA
						SFQ->FQ_TIPODES := SE5->E5_TIPO
						SFQ->FQ_CFDES   := SE5->E5_CLIFOR
						SFQ->FQ_LOJADES := SE5->E5_LOJA
						SFQ->FQ_SEQDES  := SE5->E5_SEQ

						//Grava a filial de destino
						SFQ->FQ_FILDES := SE5->E5_FILIAL

						MsUnlock()
					Endif
 				Next nLoop
			EndIf
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Retorna do ponteiro do SE1 para a parcela         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			SE5->( MsGoto( nSalvRec ) )
			//Reclock( "SE5", .F. )
		Else
			If nVlRetPis + nVlRetCof + nVlRetCsl > 0
				//Posiciona a FK1 para mandar a operação de alteração com base no registro posicionado da SE5
				If AllTrim( SE5->E5_TABORI ) == "FK1"
					aAreaFKs := GetArea()
					dbSelectArea( "FK1" )
					FK1->( DbSetOrder( 1 ) )
					If MsSeek( xFilial("FK1") + SE5->E5_IDORIG )
						//Manda o campo LA com o valor de 2 Caracteres, para manter a gravação original na E5
						cCamposE5:= "{"
						cCamposE5+= "{'E5_VRETPIS',"+Str(nVlRetPis)+"}"
						cCamposE5+= ",{'E5_VRETCOF',"+Str(nVlRetCof)+"}"
						cCamposE5+= ",{'E5_VRETCSL',"+Str(nVlRetCsl)+"}"
						cCamposE5+= ",{'E5_PRETPIS', '1'}"
						cCamposE5+= ",{'E5_PRETCOF', '1'}"
						cCamposE5+= ",{'E5_PRETCSL', '1'}"
						cCamposE5+= "}"
						oModelMov:SetOperation( 4 ) //Alteração
						oModelMov:Activate()
						oModelMov:SetValue( "MASTER", "E5_GRV", .T. ) //Habilita gravação de SE5
						oModelMov:SetValue( "MASTER", "E5_CAMPOS", cCamposE5 ) //Informa os campos da SE5 que serão gravados indepentes de FK1
						
						
  						If oModelMov:VldData()
      	   					oModelMov:CommitData()
							SE5->(dbGoto(oModelMov:GetValue( "MASTER", "E5_RECNO" )))
						Else
       						lRet := .F.
	   				 		cLog := cValToChar(oModelMov:GetErrorMessage()[4]) + ' - '
	   	 					cLog += cValToChar(oModelMov:GetErrorMessage()[5]) + ' - '
	   	 					cLog += cValToChar(oModelMov:GetErrorMessage()[6])
   							Help( ,,"M030VALID",,cLog, 1, 0 )
						Endif
						
						oModelMov:DeActivate()
						oModelMov:Destroy()
						oModelMov:= nil
					Else //Se não achou o registro na FK1
						lRet := .F.
					Endif
					RestArea(aAreaFKs)
				Else //Se a origem do registro posicionado não for FK1
					lRet := .F.
				Endif
	
			EndIf
			lRetParc := .F.

		EndIf

	Case cModRetPIS == "2"
		lRetParc := .T.

	Case cModRetPIS == "3"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Grava a Marca de "pendente recolhimento" dos demais registros    ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nVlRetPis + nVlRetCof + nVlRetCsl > 0
			//Posiciona a FK1 para mandar a operação de alteração com base no registro posicionado da SE5
			If AllTrim( SE5->E5_TABORI ) == "FK1"
				aAreaFKs := GetArea()
				dbSelectArea( "FK1" )
				FK1->( DbSetOrder( 1 ) )
				If MsSeek( xFilial("FK1") + SE5->E5_IDORIG )
					//Manda o campo LA com o valor de 2 Caracteres, para manter a gravação original na E5
					cCamposE5:= "{"
					cCamposE5+= "{'E5_VRETPIS',"+Str(nVlRetPis)+"}"
					cCamposE5+= ",{'E5_VRETCOF',"+Str(nVlRetCof)+"}"
					cCamposE5+= ",{'E5_VRETCSL',"+Str(nVlRetCsl)+"}"
					cCamposE5+= ",{'E5_PRETPIS', '1'}"
					cCamposE5+= ",{'E5_PRETCOF', '1'}"
					cCamposE5+= ",{'E5_PRETCSL', '1'}"
					cCamposE5+= "}"
					oModelMov:SetOperation( 4 ) //Alteração
					oModelMov:Activate()
					oModelMov:SetValue( "MASTER", "E5_GRV", .T. ) //Habilita gravação de SE5
					oModelMov:SetValue( "MASTER", "E5_CAMPOS", cCamposE5 ) //Informa os campos da SE5 que serão gravados indepentes de FK1
					
					
					If oModelMov:VldData()
   	   					oModelMov:CommitData()
						SE5->(dbGoto(oModelMov:GetValue( "MASTER", "E5_RECNO" )))

					Else
   						lRet := .F.
   				 		cLog := cValToChar(oModelMov:GetErrorMessage()[4]) + ' - '
   	 					cLog += cValToChar(oModelMov:GetErrorMessage()[5]) + ' - '
   	 					cLog += cValToChar(oModelMov:GetErrorMessage()[6])
						Help( ,,"M030VALID",,cLog, 1, 0 )
					Endif
					oModelMov:DeActivate()
					oModelMov:Destroy()
					oModelMov:= nil
				Else //Se não achou o registro na FK1
					lRet := .F.
				Endif
				RestArea(aAreaFKs)
			Else //Se a origem do registro posicionado não for FK1
				lRet := .F.
			Endif

		EndIf
		lRetParc := .F.
	EndCase

	//Grava os titulos de PCC Baixa CR
	//Gravo os titulos de impostos Pis Cofins Csll quando controlados pela baixa
	If lRetParc .And. !lRaRtImp
		//nPis	:= SE5->E5_VRETPIS
		//nCofins	:= SE5->E5_VRETCOF
		//nCsll	:= SE5->E5_VRETCSL
		//nIrrf   := SE5->E5_VRETIRF
		FGrvPccRec(@nPis,@nCofins,@nCsll,nRecnoSE1,.F.,lRetParc,@cSequencia,"FINA070",SE1->E1_MOEDA)
	Endif

    If lRaRtImp .And. !SE5->E5_TIPO $ MVRECANT .And. (lPccBxCr  .or. lIRPJBxCr)
		If Len(aDadosRA1[2]) ==1
			nTit := 0
		Else
			nTit := aScan(aDadosRA1[2],{|x| x=nRecnoSE1})
		EndIf
		If nTit == 0
			For nTit := 1 to Len(aDadosRA1[1])
				If aDadosRA1[9][nTit]
					//Posiciona a FK1 para mandar a operação de alteração com base no registro posicionado da SE5
					If AllTrim( SE5->E5_TABORI ) == "FK1"
						aAreaFKs := GetArea()
						dbSelectArea( "FK1" )
						FK1->( DbSetOrder( 1 ) )
						If MsSeek( xFilial("FK1") + SE5->E5_IDORIG )
							//Manda o campo LA com o valor de 2 Caracteres, para manter a gravação original na E5
							cCamposE5:= "{"
   							cCamposE5+= "{'E5_VRETPIS', "+Str(aDadosRA1[3][nTit])+"}"
   							cCamposE5+= ",{'E5_VRETCOF', "+Str(aDadosRA1[4][nTit])+"}"
    						cCamposE5+= ",{'E5_VRETCSL', "+Str(aDadosRA1[5][nTit])+"}"
    						cCamposE5+= ",{'E5_VRETIRF', "+Str(aDadosRA1[6][nTit])+"}"

    						If aDadosRA1[3][nTit]+aDadosRA1[4][nTit]+aDadosRA1[5][nTit]>0
					  			cCamposE5+= ",{'E5_PRETPIS', '7'}"
    							cCamposE5+= ",{'E5_PRETCOF', '7'}"//Retido no RA
					  			cCamposE5+= ",{'E5_PRETCSL', '7'}"//Retido no RA
							Endif
							If aDadosRA1[6][nTit]>0
						   		cCamposE5+= ",{'E5_PRETIRF', '7'}"//Retido no RA
				 			Endif
				 			If lRaRtImp .And. cPaisLoc == "BRA"
				 				cCamposE5+= ",{'E5_PRISS', "+Str(aDadosRA1[10][nTit])+"}"
				 				cCamposE5+= ",{'E5_PRINSS', "+Str(aDadosRA1[11][nTit])+"}"
				 			Endif          
				 			cCamposE5+= "}"
				 			
							oModelMov := FWLoadModel("FINM010")
							oModelMov:SetOperation( 4 ) //Alteração
							oModelMov:Activate()
							oModelMov:SetValue( "MASTER", "E5_GRV", .T. ) //Habilita gravação de SE5
							oModelMov:SetValue( "MASTER", "E5_CAMPOS", cCamposE5 ) //Informa os campos da SE5 que serão gravados indepentes de FK1

							If oModelMov:VldData()
       	   					oModelMov:CommitData()
							   	SE5->(dbGoto(oModelMov:GetValue( "MASTER", "E5_RECNO" )))
	       					oModelMov:DeActivate()
							Else
	       					lRet := .F.
		   				 		cLog := cValToChar(oModelMov:GetErrorMessage()[4]) + ' - '
		   	 					cLog += cValToChar(oModelMov:GetErrorMessage()[5]) + ' - '
		   	 					cLog += cValToChar(oModelMov:GetErrorMessage()[6])

	       					If !lF330Auto  //Se não for rotina automatica
	       						Help( ,,"M030VALID",,cLog, 1, 0 )
       						Endif
							Endif
							oModelMov:DeActivate()
							oModelMov:Destroy()
							oModelMov:= nil
						Else //Se não achou o registro na FK1
							lRet := .F.
						Endif
						RestArea(aAreaFKs)
					Else //Se a origem do registro posicionado não for FK1
						lRet := .F.
					Endif
					aDadosRA1[9][nTit]:= .F.
					Exit
				Endif
			Next nTit
		Else
			If aDadosRA1[9][nTit]

				If AllTrim( SE5->E5_TABORI ) == "FK1"
					aAreaFKs := GetArea()
					dbSelectArea( "FK1" )
					FK1->( DbSetOrder( 1 ) )
					If MsSeek( xFilial("FK1") + SE5->E5_IDORIG )
						//Manda o campo LA com o valor de 2 Caracteres, para manter a gravação original na E5
						cCamposE5:= "{"
						cCamposE5+= "{'E5_VRETPIS', "+Str(aDadosRA1[3][nTit])+"}"
						cCamposE5+= ",{'E5_VRETCOF', "+Str(aDadosRA1[4][nTit])+"}"
   						cCamposE5+= ",{'E5_VRETCSL', "+Str(aDadosRA1[5][nTit])+"}"
   						cCamposE5+= ",{'E5_VRETIRF', "+Str(aDadosRA1[6][nTit])+"}"
   						If aDadosRA1[3][nTit]+aDadosRA1[4][nTit]+aDadosRA1[5][nTit]>0
				  			cCamposE5+= ",{'E5_PRETPIS', '7'}"
   							cCamposE5+= ",{'E5_PRETCOF', '7'}"//Retido no RA
				  			cCamposE5+= ",{'E5_PRETCSL, '7'}"//Retido no RA
						Endif
						If aDadosRA1[6][nTit]>0
					   		cCamposE5+= ",{'E5_PRETIRF', '7'}"//Retido no RA
			 			Endif
			 			If lRaRtImp .And. cPaisLoc == "BRA"
			 				cCamposE5+= ",{'E5_PRISS', "+Str(aDadosRA1[10][nTit])+"}"
			 				cCamposE5+= ",{'E5_PRINSS', "+Str(aDadosRA1[11][nTit])+"}"
			 			Endif
						cCamposE5+= "}"

						oModelMov := FWLoadModel("FINM010")
						oModelMov:SetOperation( 4 ) //Alteração
						oModelMov:Activate()
						oModelMov:SetValue( "MASTER", "E5_GRV", .T. ) //Habilita gravação de SE5
						oModelMov:SetValue( "MASTER", "E5_CAMPOS", cCamposE5 ) //Informa os campos da SE5 que serão gravados indepentes de FK1

						If oModelMov:VldData()
   	   						oModelMov:CommitData()
						   	SE5->(dbGoto(oModelMov:GetValue( "MASTER", "E5_RECNO" )))
						Else
       					lRet := .F.
	   				 		cLog := cValToChar(oModelMov:GetErrorMessage()[4]) + ' - '
	   	 					cLog += cValToChar(oModelMov:GetErrorMessage()[5]) + ' - '
	   	 					cLog += cValToChar(oModelMov:GetErrorMessage()[6])

       					If !lF330Auto  //Se não for rotina automatica
       						Help( ,,"M030VALID",,cLog, 1, 0 )
      						Endif
						Endif
						oModelMov:DeActivate()
						oModelMov:Destroy()
						oModelMov:= nil
					Else //Se não achou o registro na FK1
						lRet := .F.
					Endif
					RestArea(aAreaFKs)
				Else //Se a origem do registro posicionado não for FK1
					lRet := .F.
				Endif

			Endif
		EndIf
	Endif

Endif

Return

//--------------------------------------------------------------------------

Static Function FaDelSFQCR()

Local nI := 0
Local aRecSE5 := {}
Local lPccBxCr	:= FPccBxCr()
//Controla IRPJ na baixa
Local lIrPjBxCr		:= FIrPjBxCr()
Local aArea := GetArea()
Local nRecSE5 := 0
Local aSE1Area := SE1->(GetArea())
//  Variaveis de Uso do Model
Local aAreaFKs := {}
Local oModelMov := nil //FWLoadModel("FINM010")
Local oSubFK1
Local cCamposE5 := ""
Local lRet := .T.

Private lRaRtImp  	:= FRaRtImp()       //Define se ha retencao de impostos PCC/IRPJ no R.A

If cPaisLoc == "BRA" .and. lPccBxCR
	nRecSe5  := SE5->(RecNo())

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Exclui os registros de relacionamentos do SFQ                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aRecSE5 := FImpDelTit("E1B",SE5->E5_PREFIXO,SE5->E5_NUMERO,SE5->E5_PARCELA,SE5->E5_TIPO,SE5->E5_CLIFOR,SE5->E5_LOJA,SE5->E5_SEQ)
	For nI := 1 to Len(aRecSE5)
		SE5->(MSGoto(aRecSE5[nI]))

		If AllTrim( SE5->E5_TABORI ) == "FK1"
			aAreaFKs := GetArea()
			dbSelectArea( "FK1" )
			FK1->( DbSetOrder( 1 ) )
			If MsSeek( xFilial("FK1") + SE5->E5_IDORIG )
				//Manda o campo LA com o valor de 2 Caracteres, para manter a gravação original na E5
				cCamposE5 := "{"
				cCamposE5 += "{'E5_PRETPIS', '1'}"
				cCamposE5 += ",{'E5_PRETCOF', '1'}"
				cCamposE5 := ",{'E5_PRETCSL', '1'} }"
				oModelMov := FWLoadModel("FINM010")
				oModelMov:SetOperation( 4 ) //Alteração
				oModelMov:Activate()
				oModelMov:SetValue( "MASTER", "E5_GRV", .T. ) //Habilita gravação de SE5
				oModelMov:SetValue( "MASTER", "E5_CAMPOS", cCamposE5 ) //Informa os campos da SE5 que serão gravados indepentes de FK1

				//Dados Contábeis
		   		oSubFK1 := oModelMov:GetModel("FK1DETAIL")

				If oModelMov:VldData()
       				oModelMov:CommitData()
	       			oModelMov:DeActivate()
				Else
	       			lRet := .F.
		   			cLog := cValToChar(oModelMov:GetErrorMessage()[4]) + ' - '
		   			cLog += cValToChar(oModelMov:GetErrorMessage()[5]) + ' - '
		   			cLog += cValToChar(oModelMov:GetErrorMessage()[6])

       				Help( ,,"M100VALID",,cLog, 1, 0 )
				Endif

			Else //Se não achou o registro na FK1
				lRet := .F.
			Endif
			RestArea(aAreaFKs)
		Else //Se a origem do registro posicionado não for FK1
			lRet := .F.
		Endif

	Next
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Exclui os registros de relacionamentos do SFQ                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SE5->(dbGoto(nRecSe5))
	FImpDelSFQ("E1B",SE5->E5_PREFIXO,SE5->E5_NUMERO,SE5->E5_PARCELA,SE5->E5_TIPO,SE5->E5_CLIFOR,SE5->E5_LOJA,SE5->E5_SEQ)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Apaga os registros de impostos gerados na Baixa                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !lIrPjBxCr .And. !lRartimp
		F070DelTxBx(SE1->E1_FILIAL)
	EndIf

EndIf
If cPaisLoc == "BRA" .and. lIrPjBxCr
	nRecSe5  := SE5->(RecNo())

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Exclui os registros de relacionamentos do SFQ                               ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aRecSE5 := FImpDelTit("E5B",SE5->E5_PREFIXO,SE5->E5_NUMERO,SE5->E5_PARCELA,SE5->E5_TIPO,SE5->E5_CLIFOR,SE5->E5_LOJA,SE5->E5_SEQ)
	For nI := 1 to Len(aRecSE5)
		SE5->(MSGoto(aRecSE5[nI]))

		If AllTrim( SE5->E5_TABORI ) == "FK1"
			aAreaFKs := GetArea()
			dbSelectArea( "FK1" )
			FK1->( DbSetOrder( 1 ) )
			If MsSeek( xFilial("FK1") + SE5->E5_IDORIG )
				//Manda o campo LA com o valor de 2 Caracteres, para manter a gravação original na E5
				cCamposE5 := "{{'E5_PRETIRF', '1'}}"
				oModelMov := FWLoadModel("FINM010")
				oModelMov:SetOperation( 4 ) //Alteração
				oModelMov:Activate()
				oModelMov:SetValue( "MASTER", "E5_GRV", .T. ) //Habilita gravação de SE5
				oModelMov:SetValue( "MASTER", "E5_CAMPOS", cCamposE5 ) //Informa os campos da SE5 que serão gravados indepentes de FK1

				//Dados Contábeis
		   		oSubFK1 := oModelMov:GetModel("FK1DETAIL")

				If oModelMov:VldData()
       				oModelMov:CommitData()
	       			oModelMov:DeActivate()
				Else
	       			lRet := .F.
		   			cLog := cValToChar(oModelMov:GetErrorMessage()[4]) + ' - '
		   			cLog += cValToChar(oModelMov:GetErrorMessage()[5]) + ' - '
		   			cLog += cValToChar(oModelMov:GetErrorMessage()[6])
       				Help( ,,"M100VALID",,cLog, 1, 0 )
				Endif

			Else //Se não achou o registro na FK1
				lRet := .F.
			Endif
			RestArea(aAreaFKs)
		Else //Se a origem do registro posicionado não for FK1
			lRet := .F.
		Endif

	Next
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Exclui os registros de relacionamentos do SFQ                                ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	SE5->(dbGoto(nRecSe5))
	FImpDelSFQ("E5B",SE5->E5_PREFIXO,SE5->E5_NUMERO,SE5->E5_PARCELA,SE5->E5_TIPO,SE5->E5_CLIFOR,SE5->E5_LOJA,SE5->E5_SEQ)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Apaga os registros de impostos gerados na Baixa                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If SE1->E1_TIPO == MVRECANT .OR. SE1->E1_TIPO == MV_CRNEG .And. !lRartImp
			dbSelectArea("SE1")
			dbSetorder(1)
			Seek(xfilial("SE1")+SE5->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO))
			F070DelTxBx(SE1->E1_FILIAL)
	Else
			If !lRartimp
			 F070DelTxBx(SE1->E1_FILIAL)
			Endif
	EndIf
EndIf
RestArea(aArea)
RestArea(aSE1Area)

Return

//--------------------------------------------------------------------------------

Static Function F330Invert(lPccBxCr,oTitulo,oGet01)

nValTot := 0

If (cPaisLoc == "BRA" .and. lPccBxCr .and. lCredito) .Or. cPaisLoc <> "BRA"
	aTitulos:= u_FA330Troca(oTitulo:nAt,aTitulos,oGet01,.T.)
Else
 	aEval(aTitulos, {|e| IIf(!e[8].And.Fa330Lock(e[1]+e[2]+e[3]+e[4],,,Iif(MV_PAR02== 2, e[16],e[13]),.F.), (e[8] := .T.) , If(e[8], (Fa330UnLock(e[1]+e[2]+e[3]+e[4],,Iif(MV_PAR02== 2, e[16],e[13]),.F.),e[8] := .F. ),Nil)       ), If(e[8],(If(Fa330VTit(e[7])=0,e[7]:=e[6],Nil),nValTot += Fa330VTit(e[7]),e[9]:=DesTrans(e[7])),(e[7]:=Transf(0,"@E 9999,999,999.99"), e[9]:=e[7]))})
Endif

oTitulo:Refresh()
oGet01:Refresh()

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FaNfsRAdt   ³ Autor ³Totvs                ³ Data ³10.05.2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Checa se condicao de pagamento do documento de saida usa    ³±±
±±³          ³adiantamento.                                               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1: Indica se Condicao de Pagamento gera Adiantamento    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Prefixo do titulo                                    ³±±
±±³          ³ExpC2: Numero do titulo                                     ³±±
±±³          ³ExpC3: Codigo do cliente                                    ³±±
±±³          ³ExpC4: Loja do cliente                                      ³±±
±±³          ³ExpD5: Data de Emissao do Documento                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FaNfsRAdt(cPrefixo,cNum,cCliente,cLoja,dDataEmis)

Local aArea := GetArea()
Local cQ := ""
Local lRet := .F.

cQ	:= "SELECT F2_COND "
cQ += "FROM "+RetSqlName("SF2")+" "
cQ += "WHERE F2_FILIAL = '"+xFilial("SF2")+"' "
cQ += "AND F2_PREFIXO = '"+cPrefixo+"' "
cQ += "AND F2_DUPL = '"+cNum+"' "
cQ += "AND F2_CLIENTE = '"+cCliente+"' "
cQ += "AND F2_LOJA = '"+cLoja+"' "
cQ += "AND F2_EMISSAO = '"+dTos(dDataEmis)+"' "
cQ += "AND D_E_L_E_T_= ' ' "

cQ := ChangeQuery(cQ)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQ),"TRBSF2",.T.,.T.)

If !Eof()
	If A410UsaAdi(TRBSF2->F2_COND)
		lRet := .T.
	Endif
Endif

TRBSF2->(dbCloseArea())

RestArea(aArea)

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FaBxEmisDoc ³ Autor ³Totvs                ³ Data ³10.05.2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Checa se a compensacao do titulo foi gerada no momento da   ³±±
±±³          ³emissao do documento.Parametros devem ser o do titulo       ³±±
±±³          ³principal (Tipo de titulo = MVNOTAFIS).                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1: Indica se a Compensacao foi realizada na geracao do  ³±±
±±³          ³Documento                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Filial do SE5                                        ³±±
±±³          ³ExpC2: Prefixo do titulo                                    ³±±
±±³          ³ExpC3: Numero do titulo                                     ³±±
±±³          ³ExpC4: Parcela do titulo                                    ³±±
±±³          ³ExpC5: Cliente/Fornecedor do titulo                         ³±±
±±³          ³ExpC6: Loja do titulo                                       ³±±
±±³          ³ExpC7: Tipo da baixa                                        ³±±
±±³          ³ExpD8: Data de emissao do titulo                            ³±±
±±³          ³ExpC9: Sequencia da baixa                                   ³±±
±±³          ³ExpC10: Carteira da baixa "R"/"P"                           ³±±
±±³          ³ExpC11: Numero do documento                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Esta rotina eh usada no contas a receber a pagar.           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FaBxEmisDoc(cFilSE5,cPrefixo,cNum,cParcela,cCliFor,cLoja,cTipo,dDataE,cSeq,cCarteira,cDocumen)

Local aArea := GetArea()
Local cQ := ""
Local lRet := .F.
Local nCountFR3 := 0
Local nTamPref := IIf(cCarteira = "R",TamSX3("E1_PREFIXO")[1],IIf(cCarteira = "P",TamSX3("E2_PREFIXO")[1],0))
Local nTamNum := IIf(cCarteira = "R",TamSX3("E1_NUM")[1],IIf(cCarteira = "P",TamSX3("E2_NUM")[1],0))
Local nTamParc := IIf(cCarteira = "R",TamSX3("E1_PARCELA")[1],IIf(cCarteira = "P",TamSX3("E2_PARCELA")[1],0))

// localiza quantas vezes o adiantamento foi utilizado neste documento de saida
cQ	:= "SELECT COUNT(*) AS NREG "
cQ += "FROM "+RetSqlName("FR3")+" "
cQ += "WHERE FR3_FILIAL = '"+xFilial("FR3")+"' "
cQ += "AND FR3_CART = '"+cCarteira+"' "
cQ += "AND FR3_DATAE = '"+dTos(dDataE)+"' "
cQ += "AND FR3_NUM = '"+Subs(cDocumen,nTamPref+1,nTamNum)+"' "
cQ += "AND FR3_PREFIX = '"+Subs(cDocumen,1,nTamPref)+"' "
cQ += "AND FR3_PARCEL = '"+Subs(cDocumen,nTamPref+nTamNum+1,nTamParc)+"' "
If cCarteira = "R"
	cQ += "AND FR3_CLIENT = '"+cCliFor+"' "
Elseif cCarteira = "P"
	cQ += "AND FR3_FORNEC = '"+cCliFor+"' "
Endif
cQ += "AND FR3_LOJA = '"+cLoja+"' "
If cCarteira = "R"
	cQ += "AND FR3_TIPO IN "+FormatIn(MVRECANT,"/")+" "
Elseif cCarteira = "P"
	cQ += "AND FR3_TIPO IN "+FormatIn(MVPAGANT,"/")+" "
Endif
cQ += "AND FR3_DOC = '"+cNum+"' "
cQ += "AND EXISTS( SELECT * " // busca somente os registros que tenham o mesmo documento que estah sendo comparado, para evitar problema de titulos com mais de uma parcela, gerando divergencia na comparacao entre as parcelas.
cQ += "	FROM "+RetSqlName("FR3")+" "
cQ += "	WHERE FR3_FILIAL = '"+xFilial("FR3")+"' "
cQ += "	AND FR3_CART = '"+cCarteira+"' "
cQ += "	AND FR3_DATAE = '"+dTos(dDataE)+"' "
cQ += "	AND FR3_NUM = '"+cNum+"' "
cQ += "	AND FR3_PREFIX = '"+cPrefixo+"' "
cQ += "	AND FR3_PARCEL = '"+cParcela+"' "
If cCarteira = "R"
	cQ += "	AND FR3_CLIENT = '"+cCliFor+"' "
Elseif cCarteira = "P"
	cQ += "	AND FR3_FORNEC = '"+cCliFor+"' "
Endif
cQ += "	AND FR3_LOJA = '"+cLoja+"' "
cQ += "	AND FR3_TIPO = '"+MVNOTAFIS+"' "
cQ += "	AND FR3_DOC = '"+cNum+"' "
cQ += "	AND D_E_L_E_T_= ' ') "
cQ += "AND D_E_L_E_T_= ' ' "

cQ := ChangeQuery(cQ)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQ),"TRBFR3",.T.,.T.)

nCountFR3 := TRBFR3->NREG

TRBFR3->(dbCloseArea())

If !Empty(nCountFR3)
	// localiza as baixa para o titulo principal por ordem de sequencia, para comparar com a quantidade de baixas ocorridas no momento da geracao do documento
	cQ	:= "SELECT R_E_C_N_O_ AS SE5RECNO,E5_PREFIXO,E5_NUMERO,E5_PARCELA,E5_TIPO,E5_CLIFOR,E5_LOJA,E5_SEQ "
	cQ += "FROM "+RetSqlName("SE5")+" "
	cQ += "WHERE E5_FILIAL = '"+cFilSE5+"' "
	cQ += "AND E5_RECPAG = '"+cCarteira+"' "
	cQ += "AND E5_SITUACA <> 'C' "
	cQ += "AND E5_DATA = '"+dTos(dDataE)+"' "
	cQ += "AND E5_NUMERO = '"+cNum+"' "
	cQ += "AND E5_PREFIXO = '"+cPrefixo+"' "
	cQ += "AND E5_PARCELA = '"+cParcela+"' "
	cQ += "AND E5_CLIFOR = '"+cCliFor+"' "
	cQ += "AND E5_LOJA = '"+cLoja+"' "
	cQ += "AND E5_TIPO = '"+cTipo+"' "
	cQ += "AND E5_MOTBX = 'CMP' "
	cQ += "AND E5_TIPODOC = 'CP' "
	cQ += "AND D_E_L_E_T_= ' ' "
	cQ += "AND E5_DOCUMEN = '"+cDocumen+"' " // considera somente as baixas que usaram este mesmo documento, ou seja, as baixas deste adiantamento
	cQ += "ORDER BY E5_FILIAL,E5_SEQ "

	cQ := ChangeQuery(cQ)

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQ),"TRBSE5",.T.,.T.)

	While !Eof()
		If Empty(nCountFR3)
			Exit
		Endif
		If TemBxCanc(TRBSE5->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ),.T.)
			dbSkip()
			Loop
		Endif
		nCountFR3--
		// se sequencia da baixa for igual a do parametro, esta baixa foi efetuado junto com a emissao do documento
		If TRBSE5->E5_SEQ = cSeq
			lRet := .T.
		Endif
		dbSkip()
	Enddo

	TRBSE5->(dbCloseArea())
Endif

RestArea(aArea)

Return(lRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Fa330VldDtºAutor  ³ Clovis Magenta     º Data ³  13/01/11   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Consiste MV_DATAFIN antes de cancelar baixa/compensação  	º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Fa330VldDt(aArray, nOpc)
Local lRet := .T.
DEFAULT nOpc := 5

If lRet .and. SuperGetMv("MV_BXDTFIN",,"1") == "2"
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ A data da baixa deve ser passada como parametro, pois tanto ³
	//³ o cancelamento como a exclusao devem ser validados pela     ³
	//³ data de baixa e nao pela data base do sistema.              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IF nOpc == 4  //Exclusao
		lRet := DtMovFin(CtoD(aArray[06]),!l330Auto,"2")
	Else
		lRet := DtMovFin( ,!l330Auto,"2")
	Endif


Endif

Return lRet


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Fa330TxMd  ³ Autor ³ Cristiano Denardi    ³ Data ³ 05.04.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Busca Taxa em aTxMoedas e verifica se foi trocada          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FINA330                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Fa330TxMd( nMoeda2, nTx ,lAcrDes)

Local lExistTxMd	:= Type("aTxMoedas")#"U" .And. Len(aTxMoedas) > 0

Default nTx			:= 0
Default nMoeda2 	:= 0
Default lAcrDes		:= .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Estrutura aTxMoedas         ³
//³ [1] -> Nome Moeda          	³
//³ [2] -> Taxa a Ser Utilizada	³
//³ [3] -> Picture          	³
//³ [4] -> Taxa do dia atual    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If nMoeda2 > 0 .And. lExistTxMd .AND. (nMoeda2<>SE1->E1_MOEDA)
	If aTxMoedas[nMoeda2][2] <> aTxMoedas[nMoeda2][4] .and. (aTxMoedas[nMoeda2][2]<>0)
		nTx := aTxMoedas[nMoeda2][2]
	Elseif (nTx <> aTxMoedas[nMoeda2][4]) .and. (aTxMoedas[nMoeda2][4]<>0)
		nTx := aTxMoedas[nMoeda2][4]
	Endif
ELSEIF (nMoeda2==SE1->E1_MOEDA)
	// se a moeda do titulo principal é 2 e a do titulo posicionado tb, nao convertemos pois os valores serao expressos em U$
	If !lAcrDes
		nTx := 1
	Endif
Endif

Return( nTx )

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Fa330Tx2  ³ Autor ³ Clovis Magenta       ³ Data ³ 31.08.11 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Busca Taxa em aTxMoedas e verifica se foi trocada          ³±±
±±³Descri‡…o ³ Funcao copiada da Fa340TxMd pois a Fa330TxMd() nao obtem   ³±±
±±³Descri‡…o ³ resultado satisfatorio para alguns casos de conversao      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FINXATU                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Fa330Tx2( nMoeda2, nTx )

Local lExistTxMd	:= Type("aTxMoedas")#"U" .And. Len(aTxMoedas) > 0
Default nTx			:= 0
Default nMoeda2 		:= 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Estrutura aTxMoedas         ³
//³ [1] -> Nome Moeda          	³
//³ [2] -> Taxa a Ser Utilizada	³
//³ [3] -> Picture          	³
//³ [4] -> Taxa do dia atual    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ/

// Esta função só deve ser chamada pela rotina de compensação a pagar
If nMoeda2 > 0 .And. lExistTxMd
	If aTxMoedas[nMoeda2][2] <> aTxMoedas[nMoeda2][4] .and. (aTxMoedas[nMoeda2][2]<>0)
		nTx := aTxMoedas[nMoeda2][2]
	ElseIf (nTx == 0)
		nTx := aTxMoedas[nMoeda2][4]
	Endif
Endif

Return( nTx )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³Fin330ExCMºAutor  ³Clovis Magenta      º Data ³  07/02/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Função que excluirá o registro de correção monetaria na SE5 º±±
±±º          ³ ao excluir uma compensacao                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Fin330ExCM(cFilCmp, cSequen)
Local aArea 	:= GetArea()
Local aAreaSE5 	:= SE5->( GetArea() )
Local cChave	:= ""
// Variaveis do Model SE5
Local aAreaAnt := {}
Local oModelMov := nil //FWLoadModel("FINM010")
Local cLog := ""
Local lRet := .T.
Local nRecSE5 := 0

DEFAULT cFilCmp := xFilial("SE5")
DEFAULT cSequen := SE5->E5_SEQ

SE5->(DbSetorder(7))
If SE5->( DbSeek(cFilCmp+SE5->E5_PREFIXO+SE5->E5_NUMERO+SE5->E5_PARCELA+SE5->E5_TIPO) )
	cChave := cFilCmp+SE5->E5_PREFIXO+SE5->E5_NUMERO+SE5->E5_PARCELA+SE5->E5_TIPO

	While cChave == SE5->(E5_FILIAL + E5_PREFIXO + E5_NUMERO + E5_PARCELA + E5_TIPO )
		If SE5->E5_TIPODOC $ "VM;CM" .AND. cSequen == SE5->E5_SEQ

			nRecSE5 := SE5->(Recno())
			
			//Posiciona a FK1 para mandar a operação de alteração com base no registro posicionado da SE5
			If AllTrim( SE5->E5_TABORI ) == "FK1"
				aAreaAnt := GetArea()
				dbSelectArea( "FK1" )
				FK1->( DbSetOrder( 1 ) )
				If MsSeek( xFilial("FK1") + SE5->E5_IDORIG )
					oModelMov := FWLoadModel("FINM010")
					oModelMov:SetOperation( 4 ) //Alteração
					oModelMov:Activate()
					oModelMov:SetValue( "MASTER", "E5_GRV", .T. ) //Habilita gravação SE5
					//E5_OPERACAO 1 = Altera E5_SITUACA da SE5 para 'C' e gera estorno na FK1
					//E5_OPERACAO 2 = Altera E5_TIPODOC da SE5 para 'ES' e gera estorno na FK1
					//E5_OPERACAO 3 = Deleta da SE5 e gera estorno na FK1
					oModelMov:SetValue( "MASTER", "E5_OPERACAO", 3 ) //E5_OPERACAO 3 = Deleta da SE5 e gera estorno na FK1

					If oModelMov:VldData()
				       	oModelMov:CommitData()
				       	oModelMov:DeActivate()
					Else
						lRet := .F.
					    cLog := cValToChar(oModelMov:GetErrorMessage()[4]) + ' - '
					    cLog += cValToChar(oModelMov:GetErrorMessage()[5]) + ' - '
					    cLog += cValToChar(oModelMov:GetErrorMessage()[6])

	      	 			If !lF330Auto
	       					Help( ,,"M030VALID",,cLog, 1, 0 )
       	  				Endif
					Endif
				Endif
				RestArea(aAreaAnt)
			 Endif
			 SE5->(dbGoto(nRecSE5))
		EndIf
		SE5->(DbSkip())
	EndDo
Endif

RestArea(aAreaSE5)
RestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FINA330   ºAutor  ³Pâmela Bernardo     º Data ³  03/20/12   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Função para recalcular o IR antes da geração do titulo de IRFº±±
±±º          ³na compensaçãdo de comtas a receber                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Fina330                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FReCalIRB (aImpIr,nValTot,nTit)

//Controla IRPJ na baixa
Local lIrPjBxCr		:= FIrPjBxCr()
Local nPropIR		:=0
Local aAreaSE1 		:= SE1->(GetArea())


If cPaisLoc == "BRA" .and. lIrPjBxCr .and. !lCredito
	nIrrf:=FCaIrBxCR(nValTot)
	If (nPosIr:=ascan(aImpIR,{|x| x[2]=SE1->(REcno())}))=0
		aAdd(aImpIR,{nIrrf,SE1->(Recno())})
		nPosIr := Len( aImpIR )
	else
		aImpIR[nPosIr][1]:= nIrrf
	EndIf

Endif

If cPaisLoc == "BRA" .and. lIrPjBxCr .and. lCredito .and. Valtype(aImpIr) == "A" //porporciona o calculo do IR quando não alcança o valor minimo de retenção 
	SE1->(MSGoto(aImpIr[nTit][2]))
	nPropIR := nValTot/SE1->E1_VLCRUZ
	nIrrf:= Round(NoRound(SE1->E1_IRRF * nPropIR,3),2)
	nIRFBase := Round(NoRound(SE1->E1_BASEIRF * nPropIR,3),2)
EndIf

RestArea(aAreaSE1)

Return nIrrf

Static Function F330PsqFil(cFilSE1,cPrefixo,cNum,cParcela,cCliFor,cLoja,cTipo,cCarteira,cTipoDoc, cAliasCmp,cTrabalho)

Local aArea 	:= GetArea()
Local cQryAux 	:= ""

#IFDEF TOP
	cQryAux	:= "SELECT DISTINCT E5_FILIAL "
	cQryAux += "FROM "+RetSqlName("SE5")+" "
	cQryAux += "WHERE E5_RECPAG = '"+cCarteira+"' "
	cQryAux += "AND E5_SITUACA <> 'C' "
	cQryAux += "AND E5_NUMERO   = '"+cNum+"' "
	cQryAux += "AND E5_PREFIXO  = '"+cPrefixo+"' "
	cQryAux += "AND E5_PARCELA  = '"+cParcela+"' "
	cQryAux += "AND E5_CLIFOR   = '"+cCliFor+"' "
	cQryAux += "AND E5_LOJA     = '"+cLoja+"' "
	If !Empty(cFilSE1) .And. cPaisLoc == "BRA"
		cQryAux += "AND E5_FILORIG  = '"+cFilSE1+"' "
	EndIf
	cQryAux += "AND E5_MOTBX    = 'CMP' "
	cQryAux += "AND E5_TIPODOC  = '"+cTipoDoc+"' "
	cQryAux += "AND D_E_L_E_T_  = ' ' "
	cQryAux += "ORDER BY E5_FILIAL "

	cQryAux := ChangeQuery(cQryAux)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryAux),cAliasCmp,.T.,.T.)
#ELSE
	dbSelectArea('SE5')
	dbUseArea(.T.,,cTrabalho,cAliasCmp,.F.,.F.)
	dbCreateInd(cTrabalho, "E5_FILIAL", {||E5_FILIAL})
	dbSelectArea("SE5")
	SE5-> ( dbSetOrder ( 1 ) ) //FILIAL+DTOS(DATA)+BANCO+AGENCIA+CONTA+NUMCHEQ
	SE5->( dbGoTop() )
	Do While ( SE5->(!Eof()))
		if E5_FILIAL == cFilLop
			SE5->(Dbskip())
			Loop
        Endif
		If SE5->E5_RECPAG != cCarteira
			SE5->(Dbskip())
			Loop
	   Endif
       If SE5->E5_SITUACA == "C"
			SE5->(Dbskip())
			Loop
	   Endif
       If SE5->E5_NUMERO != cNum
			SE5->(Dbskip())
			Loop
	   Endif
       If SE5->E5_PREFIXO != cPrefixo
			SE5->(Dbskip())
			Loop
	   Endif
       If SE5->E5_PARCELA != cParcela
			SE5->(Dbskip())
			Loop
	   Endif
       If SE5->E5_CLIFOR != cCliFor
			SE5->(Dbskip())
			Loop
	   Endif
       If SE5->E5_LOJA != cLoja
			SE5->(Dbskip())
			Loop
	   Endif
       If AllTrim(SE5->E5_FILORIG) != AllTrim(cFilSE1)
			SE5->(Dbskip())
			Loop
	   Endif
       If SE5->E5_MOTBX != "CMP"
			SE5->(Dbskip())
			Loop
	   Endif
       If SE5->E5_TIPODOC != cTipoDoc
			SE5->(Dbskip())
			Loop
	   Endif
		RecLock (cAliasCmp, .T. )
		(cAliasCmp) ->	E5_FILIAL		:= SE5 -> E5_FILIAL
		cFilLop := SE5 -> E5_FILIAL
		(cAliasCmp) -> (MsUnlock( ))
		SE5->(dbSkip())
	EndDo

#ENDIF

(cAliasCmp)->( dbGoTop() )


RestArea(aArea)

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³GetInfSE5 ³ Autor ³Clovis Magenta         ³ Data ³26.10.2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Pega as informações da SE5->E5_DOCUMEN e divide em partes   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³aSE5: Array com as informações do SE5->E5_DOCUMEN           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cDoc: SE5->E5_DOCUMEN                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function GetInfSE5(cDoc)
Local nPrefixo 	:= TamSX3("E1_PREFIXO")[1]
Local nNum		:= TamSX3("E1_NUM")[1]
Local nParcel	:= TamSX3("E1_PARCELA")[1]
Local nTipo		:= TamSX3("E1_TIPO")[1]
Local nLoja		:= TamSX3("E1_LOJA")[1]
Local nCont		:= 1
Local aSE5		:= {}
Local nx		:= 0

Default cDoc := ""

For nX:=1 to 6
    Do Case
    	Case nX == 1
			Aadd(aSE5,substr(cDoc,1,nPrefixo ) )
			nCont += nPrefixo
    	Case nX == 2
			Aadd(aSE5,substr(cDoc,nCont,nNum ) )
			nCont += nNum
    	Case nX == 3
			Aadd(aSE5,substr(cDoc,nCont,nParcel ) )
			nCont += nParcel
    	Case nX == 4
			Aadd(aSE5,substr(cDoc,nCont,nTipo ) )
			nCont += nTipo
     	Case nX == 5
			Aadd(aSE5,substr(cDoc,nCont,nLoja ) )
	EndCase

Next nX

Return aSE5


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FaPesqBx2 ³ Autor ³Felipe Cunha            ³ Data ³19.10.2012³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Checa se a compensacao do titulo foi gerada no momento da   ³±±
±±³          ³emissao do documento.Parametros devem ser o do titulo       ³±±
±±³          ³principal (Tipo de titulo = MVNOTAFIS).                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpL1: Indica se a Compensacao foi realizada na geracao do  ³±±
±±³          ³Documento                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ExpC1: Filial do SE5                                        ³±±
±±³          ³ExpC2: Prefixo do titulo                                    ³±±
±±³          ³ExpC3: Numero do titulo                                     ³±±
±±³          ³ExpC4: Parcela do titulo                                    ³±±
±±³          ³ExpC5: Cliente/Fornecedor do titulo                         ³±±
±±³          ³ExpC6: Loja do titulo                                       ³±±
±±³          ³ExpC7: Tipo da baixa                                        ³±±
±±³          ³ExpD8: Data de emissao do titulo                            ³±±
±±³          ³ExpC9: Sequencia da baixa                                   ³±±
±±³          ³ExpC10: Carteira da baixa "R"/"P"                           ³±±
±±³          ³ExpC11: Numero do documento                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Observacao³Esta rotina eh usada no contas a receber a pagar.           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
STATIC Function FaPesqBx2(cFilSE5,cPrefixo,cNum,cParcela,cCliFor,cLoja,cTipo,dDataE,cSeq,cCarteira,cDocumen,cTipoDoc)

Local aArea 	:= GetArea()
Local cQryAux 	:= ""
Local cFilorig 	:= ''
Local aCampos	:= {}
Local cTrabalho	:= ""


// localiza as baixa para o titulo principal por ordem de sequencia, para comparar com a quantidade de baixas ocorridas no momento da geracao do documento
#IFDEF TOP
	cQryAux	:= "SELECT E5_FILORIG, E5_FILIAL "
	cQryAux += "FROM "+RetSqlName("SE5")+" "
	cQryAux += "WHERE E5_SEQ = '"+cSeq+"' "
	cQryAux += "AND E5_RECPAG   = '"+cCarteira+"' "
	cQryAux += "AND E5_SITUACA <> 'C' "
	cQryAux += "AND E5_DATA 	= '"+dTos(dDataE)+"' "
	cQryAux += "AND E5_NUMERO   = '"+cNum+"' "
	cQryAux += "AND E5_PREFIXO  = '"+cPrefixo+"' "
	cQryAux += "AND E5_PARCELA  = '"+cParcela+"' "
	cQryAux += "AND E5_CLIFOR   = '"+cCliFor+"' "
	cQryAux += "AND E5_LOJA     = '"+cLoja+"' "
	cQryAux += "AND E5_MOTBX    = 'CMP' "
	cQryAux += "AND E5_TIPODOC  = '"+cTipoDoc+"' "
	cQryAux += "AND D_E_L_E_T_  = ' ' "
	cQryAux += "ORDER BY E5_FILIAL,E5_SEQ "
	cQryAux := ChangeQuery(cQryAux)
	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryAux),"__TRBSE5",.T.,.T.)
 #ELSE

	dbSelectArea('SE5')
	aTam:=TamSX3("E5_FILORIG")
	AADD(aCampos,{"E5_FILORIG"  ,"C",aTam[1],aTam[2]})
	cTrabalho := CriaTrab(aCampos)
	dbUseArea(.T.,,cTrabalho,"__TRBSE5",.F.,.F.)
	dbCreateInd(cTrabalho, "E5_FILORIG", {||E5_FILORIG})
	dbSelectArea("SE5")
	SE5-> ( dbSetOrder ( 1 ) ) //FILIAL+DTOS(DATA)+BANCO+AGENCIA+CONTA+NUMCHEQ
	SE5->( dbGoTop() )
	Do While ( SE5->(!Eof()))
		if E5_SEQ != cSeq
			SE5->(Dbskip())
			Loop
        Endif
		If SE5->E5_RECPAG != cCarteira
			SE5->(Dbskip())
			Loop
	   Endif
       If SE5->E5_SITUACA == "C"
			SE5->(Dbskip())
			Loop
	   Endif
       If SE5->E5_DATA != dDataE
			SE5->(Dbskip())
			Loop
	   Endif
       If SE5->E5_NUMERO != cNum
			SE5->(Dbskip())
			Loop
	   Endif
       If SE5->E5_PREFIXO != cPrefixo
			SE5->(Dbskip())
			Loop
	   Endif
       If SE5->E5_PARCELA != cParcela
			SE5->(Dbskip())
			Loop
	   Endif
       If SE5->E5_CLIFOR != cCliFor
			SE5->(Dbskip())
			Loop
	   Endif
       If SE5->E5_LOJA != cLoja
			SE5->(Dbskip())
			Loop
	   Endif
       If SE5->E5_MOTBX != "CMP"
			SE5->(Dbskip())
			Loop
	   Endif
       If SE5->E5_TIPODOC != cTipoDoc
			SE5->(Dbskip())
			Loop
	   Endif
		RecLock ("__TRBSE5", .T. )
		__TRBSE5 ->	E5_FILORIG		:= SE5 -> E5_FILORIG
		__TRBSE5 -> (MsUnlock( ))
		SE5->(dbSkip())
	EndDo



#ENDIF
If __TRBSE5->(!EOF())
	If Empty( __TRBSE5->E5_FILORIG ) .And. cPaisLoc == "MEX"
		cFilorig := __TRBSE5->E5_FILIAL
	Else
		cFilorig := __TRBSE5->E5_FILORIG
	EndIF
EndIf

__TRBSE5->(DbCloseArea())
RestArea(aArea)
If cTrabalho <> Nil .and. !Empty(cTrabalho)
	Ferase(cTrabalho+GetDBExtension())
	Ferase(cTrabalho+OrdBagExt())
EndIf

Return(cFilorig)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FINA330   ºAutor  ³TOTVS          º Data ³  05/15/13  	 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³  Acumula os impostos para compor o aTitulos                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ FINA330                                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

User Function F330RaRtIm(aDadosRA1,cValDig,nItemRA,nItemOU, lAltValor)

Local aArea	  		:= GetArea()
Local lRet			:= .T.
Local nBaseRA  		:= 0
Local nSaldoRA 		:= 0
Local nPisRA		:= 0
Local nCofRA		:= 0
Local nCslRA		:= 0
Local nIrfRA		:= 0
Local nBaseOU  		:= 0
Local nSaldoOU 		:= 0
Local nPisOU		:= 0
Local nCofOU		:= 0
Local nCslOU		:= 0
Local nIrfOU		:= 0
Local nPrIsRA		:= 0     // Provisionamento de ISS e INSS
Local nPrIsOU		:= 0     // Provisionamento de ISS e INSS
Local nPrInRA		:= 0     // Provisionamento de ISS e INSS
Local nPrInOU		:= 0     // Provisionamento de ISS e INSS
Local nTxConv		:= 1
Local nTxSaldo		:= 1
Local ni 			:= 0
Local nItLcRA		:= 0
Local nItLcOU		:= 0
Local nSaldoCMP		:= 0
Local nProp			:= 1
Local nVlMinImp	:= GetNewPar("MV_VL10925",5000)

Default cValDig	:= 0
Default nItemRA	:= 0
Default nItemOU	:= 0
Default lAltValor := .F.

If nItemRA <> 0
	nItLcRA := nItemRA
Else
	nItLcRA := Len(aDadosRA1[1])
EndIf

If aDadosRA1[1][nItLcRA] <> 0
	SE1->(dbGoto(aDadosRA1[1][nItLcRA]))
	If SE1->E1_SALDO <> SE1->E1_VALOR //indica que houve baixa parcial
		nProp := SE1->E1_SALDO/SE1->E1_VALOR
	Endif
	nBaseRA 	:= SE1->E1_BASEIRF * nProp
	nSaldoRA 	:= SE1->E1_SALDO
	If lRaRtImp .And. cPaisLoc == "BRA"
		nSaldoRA += (SE1->E1_PRISS * nProp)+ (SE1->E1_PRINSS* nProp)
		nPrIsRA  := SE1->E1_PRISS * nProp
		nPrInRA	 := SE1->E1_PRINSS * nProp
	Endif

	If lCredito
		nSaldoCmp := SE1->E1_SALDO
	EndIf

	If cValDig <> 0 .and. cValDig <> nSaldoRA .and. lAltValor
		nSaldoRA := cValdig
	EndIf

	SE5->(dbSetOrder(2))
	SE5->(dbSeek( xFilial("SE5")+"RA"+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO))
	While (SE5->(!Eof()) .and. xFilial("SE5") == SE5->E5_FILIAL .And.	;
			SE5->E5_TIPODOC == "RA" .And. 				;
			SE5->E5_PREFIXO == SE1->E1_PREFIXO .And.				;
			SE5->E5_NUMERO == SE1->E1_NUM .And.					;
			SE5->E5_PARCELA == SE1->E1_PARCELA )

		If SE5->E5_RECPAG != "R"
			SE5->(dbSkip())
			Loop
		Endif

		//Verifica se tem baixa cancelada
		If TemBxCanc(SE5->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ),.T.,SE5->E5_FILIAL)
			SE5->(dbskip())
			Loop
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Verifica Cliente 	³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If SE5->E5_CLIFOR != SE1->E1_CLIENTE
			SE5->(dbSkip( ))
			Loop
		EndIf

		If SE5->E5_PRETPIS <> " "
			nPisRA		:= 0
		Else
			nPisRA		:= SE5->E5_VRETPIS * nProp
		EndIf
		If SE5->E5_PRETCSL <> " "
			nCslRA		:= 0
		Else
			nCslRA		:= SE5->E5_VRETCSL* nProp
		EndIf
		If SE5->E5_PRETCOF <> " "
			nCofRA		:= 0
		Else
			nCofRA		:= SE5->E5_VRETCOF* nProp
		EndIf
		If SE5->E5_PRETIRF <> " "
			nIrfRA		:= 0
		Else
			nIrfRA		:= SE5->E5_VRETIRF	* nProp
		EndIf

		Exit

	Enddo

	If Len(aDadosRA1[8]) > 0 .and. lCredito
		For ni := 1 to Len(aDadosRA1[8])
			nSaldoCmp -= aDadosRA1[8][ni]
		Next ni
	EndIf

	If (nSaldoRa+nPisRA+nCofRA+nCslRA+nIrfRA) <> nBaseRA .and. nBaseRA <> 0
		nTxSaldo	:= nSaldoRA/nBaseRA//-(nPisRA+nCofRA+nCslRA+nIrfRA)))
		nPisRA		:= Round(nPisRA*nTxSaldo,2)
		nCofRA		:= Round(nCofRA*nTxSaldo,2)
		nCslRA		:= Round(nCslRA*nTxSaldo,2)
		nIrfRA		:= Round(nIrfRA*nTxSaldo,2)
		nPrIsRA		:= Round(nPrIsRA*nTxSaldo,2)
		nPrInRA		:= Round(nPrInRA*nTxSaldo,2)
		nBaseRA		:= nSaldoRa//+nPisRA+nCofRA+nCslRA+nIrfRA+nPrIsRA+nPrInRA)
	EndIf

	If nItemOU <> 0
		nItLcOU := nItemOU
	Else
		nItLcOU := Len(aDadosRA1[2])
	EndIf

	If lRaRtImp .and. !lAltValor .And. cPaisLoc == "BRA"
		nSaldoRA -= (SE1->E1_PRISS*nProp)+ (SE1->E1_PRINSS *nProp)
	Endif
	nProp:=1
	If aDadosRA1[2][nItLcOU] <> 0 
		SE1->(dbGoto(aDadosRA1[2][nItLcOU]))
		If SE1->E1_SALDO <> SE1->E1_VALOR //indica que houve baixa parcial
			nProp := SE1->E1_SALDO/SE1->E1_BASEIRF
		Endif
		nBaseOU 	:= SE1->E1_BASEIRF * nProp
		If MV_PAR08 == 1
		nSaldoOU	:= SE1->E1_SALDO-(SE1->(E1_PIS+E1_COFINS+E1_CSLL+E1_IRRF)*nProp)
		Else
			nSaldoOU	:= SE1->E1_SALDO
		Endif
		nPisOU		:= SE1->E1_PIS * nProp
		nCofOU		:= SE1->E1_COFINS * nProp
		nCslOU		:= SE1->E1_CSLL * nProp
		nIrfOU		:= SE1->E1_IRRF * nProp
		If lRaRtImp
			nSaldoOU -= ((SE1->E1_ISS * nProp)+ (SE1->E1_INSS * nProp))
			nPrIsOU	 := SE1->E1_ISS * nProp
			nPrInOU	 := SE1->E1_INSS * nProp
		Endif

		If !lCredito
			nSaldoCmp := SE1->E1_SALDO-SE1->(E1_PIS+E1_COFINS+E1_CSLL+E1_IRRF)
		EndIf

		If cValDig <> 0 .and. cValDig <> nSaldoOU
			nSaldoOU := cValdig
		EndIf

		If Len(aDadosRA1[8]) > 0 .and. !lCredito
			For ni := 1 to Len(aDadosRA1[8])
				nSaldoCmp -= aDadosRA1[8][ni]
			Next ni
		EndIf

		If lCredito
			nTxConv 	:= (nBaseOU/nBaseRA)
		Else
			nTxConv 	:= (nBaseRA/nBaseOU)
		EndIf
		If nTxConv > 1
			nTxConv = 1
		EndIf
		If lCredito
			nPisOU		:= If(nPisRA<>0,Round(nPisRA * nTxConv,2),Round(nPisOU * nTxConv,2))
			nCofOU		:= If(nCofRA<>0,Round(nCofRA * nTxConv,2),Round(nCofOU * nTxConv,2))
			nCslOU		:= If(nCslRA<>0,Round(nCslRA * nTxConv,2),Round(nCslOU * nTxConv,2))
			nIrfOU		:= If(nIrfRa<>0,Round(nIrfRA * nTxConv,2),Round(nIrfOU * nTxConv,2))
			nPrIsOU		:= If(nPrIsRA<>0,Round(nPrIsRA * nTxConv,2),Round(nPrIsOU * nTxConv,2))
			nPrInOU		:= If(nPrInRA<>0,Round(nPrInRA * nTxConv,2),Round(nPrInOU * nTxConv,2))
		Else
			nPisRA		:= If(nPisOU<>0,Round(nPisOU * nTxConv,2),Round(nPisRA * nTxConv,2))
			nCofRA		:= If(nCofOU<>0,Round(nCofOU * nTxConv,2),Round(nCofRA * nTxConv,2))
			nCslRA		:= If(nCslOU<>0,Round(nCslOU * nTxConv,2),Round(nCslRA * nTxConv,2))
			nIrfRA		:= If(nIrfOU<>0,Round(nIrfOU * nTxConv,2),Round(nIrfRA * nTxConv,2))
			nPrIsRA		:= If(nPrIsOU<>0,Round(nPrIsOU * nTxConv,2),Round(nPrIsRA * nTxConv,2))
			nPrInRA		:= If(nPrInOU<>0,Round(nPrInOU * nTxConv,2),Round(nPrInRA * nTxConv,2))
		EndIf
	Else
		lRet := .F.
	EndIf
Else
	lRet := .F.
EndIf

If lRet

	If lCredito
		If nItemOU <> 0
			aDadosRA1[3][nItLcOU] := nPisOU
			aDadosRA1[4][nItLcOU] := nCofOU
			aDadosRA1[5][nItLcOU] := nCslOU
			aDadosRA1[6][nItLcOU] := nIrfOU
			aDadosRA1[7][nItLcOU] := nSaldoOU
			aDadosRA1[8][nItLcOU] := If(aDadosRA1[7][nItLcOU]>nSaldoRA,nSaldoRA,aDadosRA1[7][nItLcOU])
			aDadosRA1[10][nItLcOU]:= nPrIsRA
			aDadosRA1[11][nItLcOU]:= nPrInRA

		Else
			aAdd(aDadosRA1[3],nPisOU)
			aAdd(aDadosRA1[4],nCofOU)
			aAdd(aDadosRA1[5],nCslOU)
			aAdd(aDadosRA1[6],nIrfOU)
			aAdd(aDadosRA1[7],nSaldoOU)
			aAdd(aDadosRA1[8],If(aDadosRA1[7][Len(aDadosRA1[7])]>nSaldoRA,nSaldoRA,aDadosRA1[7][Len(aDadosRA1[7])]))
			aAdd(aDadosRA1[10],nPrIsRA)
			aAdd(aDadosRA1[11],nPrInRA)
		EndIf
	Else
		If nItemRA <> 0
			aDadosRA1[3][nItLcRA] := nPisRA
			aDadosRA1[4][nItLcRA] := nCofRA
			aDadosRA1[5][nItLcRA] := nCslRA
			aDadosRA1[6][nItLcRA] := nIrfRA
			aDadosRA1[7][nItLcRA] := nSaldoRA
			aDadosRA1[8][nItLcRA] := If(aDadosRA1[7][nItLcRA]>nSaldoOU,nSaldoOU,aDadosRA1[7][nItLcRA])
			aDadosRA1[10][nItLcRA]:= nPrIsRA
			aDadosRA1[11][nItLcRA]:= nPrInRA

		Else
			aAdd(aDadosRA1[3],nPisRA)
			aAdd(aDadosRA1[4],nCofRA)
			aAdd(aDadosRA1[5],nCslRA)
			aAdd(aDadosRA1[6],nIrfRA)
			aAdd(aDadosRA1[7],nSaldoRA)
			aAdd(aDadosRA1[8],If(aDadosRA1[7][Len(aDadosRA1[7])]>nSaldoOU,nSaldoOU,aDadosRA1[7][Len(aDadosRA1[7])]))
			aAdd(aDadosRA1[10],nPrIsRA)
			aAdd(aDadosRA1[11],nPrInRA)

		EndIf
	EndIf


EndIf

RestArea(aArea)

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FA330Fil  ºAutor  ³Microsiga           ºFecha ³ 08/07/2013  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Permite determinar as filias para selecao dos titulos       º±±
±±º          ³para liquidacao.                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function Fa330Fil()
Local aRet	:= {}

If MsgYesNo(STR0066 + " " + STR0067 + CRLF + CRLF + STR0068 + CRLF + CRLF + STR0069,STR0018)
		//"Serão selecionados somente os títulos das filiais escolhidas." + " " + "Se nenhuma for escolhida serão considerados somente os da filial corrente." + CRLF + CRLF + "Importante: Algumas entidades, como clientes, bancos etc, podem possuir um código na filial A, porém na filial B, esse mesmo código não necessariamente representa a mesma entidade." + CRLF + CRLF + "Deseja continuar com a seleção de filiais?"
	aRet := AdmGetFil(.F.,.T.,"SE1")
Else
	aRet := {}
Endif
Return(Aclone(aRet))


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FINA330   ºAutor  TOTVS		         º Data ³  07/23/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Recompor Valor de compensação, nSaldo, limite de compensaçãoº±±
±±º          ³ quando marcado uma NCC para compensação                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ FINA330                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function F330VALNCC(aArray, nX, lAltValor, lSoma)

Local nProp:= 0
Local nLim := 0
Local nPos := 0
Local nImpBx := 0

DEFAULT nX 			:= 1
DEFAULT lAltValor 	:= .F.
DEFAULT aArray		:= {}
DEFAULT lSoma		:= .F.

If MV_PAR02 == 2
	nPos := 25
Else
	nPos := 22
Endif
If MV_PAR08 == 1
	nImpBx := nTotImpbx-nIss-nInss
Else
	nImpBx := nTotImpbx
Endif

If lAltValor
	nProp:=  aTitulos[nX,9]/SE1->E1_VALOR
Else
    If aArray[nX,(nPos+1)]< SE1->E1_VALOR
		nProp:= aTitulos[nX,(nPos+1)]/SE1->E1_VALOR
	Else
		nProp:=  1
	Endif
Endif
If lSoma
	nLim := Fa330VTit(aArray[nX,nPos])
	nSaldo+= nImpBx * nProp
	nLim += nImpBx * nProp
	If nLim <= aArray[nX,(nPos-1)]
		aArray[nX,nPos]:= Transf(nLim,PesqPict("SE1","E1_SALDO"))
	Endif

Else
	nLim := Fa330VTit(aArray[nX,nPos])
	nSaldo-= nImpBx * nProp
	nLim -= nImpBx * nProp
	If nLim <= aArray[nX,(nPos-1)]
		aArray[nX,nPos]:= Transf(nLim,PesqPict("SE1","E1_SALDO"))
	Endif
Endif
return

//	Função	| FA330RetPCC()
//	Autor	| Pedro Pereira Lima
//	Data	| 21/01/2014
//	Uso		| Utilizada para retornar o valor total dos títulos de impostos PIS, COFINS e CSLL gerados na baixa
//	-		| e que estão com o campo E1_TIPO preenchido como "COF", "CSL" e "PIS", ao invés de "CF-", "CS-" e "PI-"
Static Function FA330RetPCC(cPrefixo,cNum,cParcela,nMoeda,dData)
Local lTitpaiSE1	:= SE1->(FieldPos("E1_TITPAI")) > 0
Local cFilAbat		:= xFilial("SE1")
Local bWhile		:= {|| !Eof() .And. E1_FILIAL == cFilAbat .And. E1_PREFIXO == cPrefixo .And. E1_NUM == cNum .And. E1_PARCELA == cParcela}
Local nTotImp		:= 0
Local cCampo		:= "E1_VALOR"
Local cCliLj		:= SE1->(E1_CLIENTE+E1_LOJA)
Local cTipo			:= SE1->E1_TIPO
Local aArea			:= GetArea()
Local lRaRtImp  	:= FRaRtImp()

Default cPrefixo	:= ""
Default cNum		:= ""
Default cParcela	:= ""
Default nMoeda		:= 0
Default dData		:= dDataBase

If Empty(cPrefixo) .And. Empty(cNum) .And. Empty(cParcela)
	RestArea(aArea)
	Return nTotImp
EndIf

DbSelectArea("SE1")

If lTitpaiSE1 
	If  (nOrdTitPai:= OrdTitpai()) > 0
		DbSetOrder(nOrdTitPai)
		If	DbSeek(xFilial("SE1")+cPrefixo+cNum+cParcela+cTipo+cCliLj)   
			bWhile := {|| !Eof() .And. E1_FILIAL + AllTrim(E1_TITPAI) ==  cFilAbat+Alltrim(cPrefixo+cNum+cParcela+cTipo+cCliLj)}
		Else
			DbSetOrder(1)
			DbSeek(cFilAbat+cPrefixo+cNum+cParcela)
		Endif
	Endif
Endif

While Eval(bWhile)
	If lTitpaiSE1
		If !Empty(E1_TITPAI) .And. (Alltrim(E1_TITPAI) != Alltrim(cPrefixo+cNum+cParcela+cTipo+cCliLj))
			DbSkip()
			Loop
		EndIf
	EndIf
	
	If E1_CLIENTE+E1_LOJA == cCliLj .And. !(lRartimp .And. cTipo $ MVRECANT)
		If E1_TIPO $ "COF|CSL|PIS"
			nTotImp += xMoeda(&cCampo,E1_MOEDA,nMoeda,dData,,,0)
		EndIf
	EndIf
	
	DbSkip()
	
EndDo

RestArea(aArea)
Return nTotImp  

//-------------------------------------------------------------------
/*/{Protheus.doc} FA330RetIRF
Utilizada para retornar o valor total dos títulos de impostos IRF gerados na baixa
e que estão com o campo E1_TIPO preenchido como IRF, ao invés de "IRF-"

@author Caique Bispo Ferreira

@since 29/07/2014
@version 1.0
/*/
//-------------------------------------------------------------------

Static Function FA330RetIRF(cPrefixo,cNum,cParcela,nMoeda,dData)
Local nTotImp		:= 0
Local aArea		:= GetArea()
Local cQuery		:= ""
Local cCliLj		:= SE1->(E1_CLIENTE+E1_LOJA)
Local cTipo		:= SE1->E1_TIPO

Default cPrefixo	:= ""
Default cNum		:= ""
Default cParcela	:= ""
Default nMoeda	:= 0
Default dData		:= dDataBase

If Empty(cPrefixo) .And. Empty(cNum) .And. Empty(cParcela)
	RestArea(aArea)
	Return nTotImp
EndIf

cQuery := " SELECT E1_MOEDA, E1_VALOR  "
cQuery += " FROM  " + RetSqlName("SE1") + " SE1 "
cQuery += " WHERE E1_TITPAI = '" + (cPrefixo+cNum+cParcela+cTipo+cCliLj)+ "'  AND E1_TIPO = 'IRF' AND D_E_L_E_T_ = ' ' " 

//* Verifica se a Query Existe, se existir fecha
If Select("TSE1") > 0
	dbSelectArea("TSE1")
	DbCloseArea()
EndIf

//* Cria a Query e da Um Apelido
dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TSE1",.F.,.T.)

dbSelectArea("TSE1")
dbGotop()
Do While TSE1->(!Eof())
	
	TCSetField("TSE1", "E1_VALOR" ,"N", 16, 2)
	TCSetField("TSE1", "E1_MOEDA" ,"N", 2, 0)
	
	nTotImp += xMoeda(TSE1->E1_VALOR,TSE1->E1_MOEDA,nMoeda,dData,,,0)
	dbSkip()
Enddo

If Select("TSE1") > 0
	dbSelectArea("TSE1")
	DbCloseArea()
EndIf

RestArea(aArea)
Return nTotImp  



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±                                                                         ±±
±±            Funcoes retiradas do arquivo FINXATU.PRX                     ±±
±±                                                                         ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ fA330Grv ³ Autor ³ Valter G. Nogueira Jr.³ Data ³ 21/03/94 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Fun‡„o utilizada para atualizar a baixa efetuada			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ fA330Grv(lPadrao) 													  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FinA330																	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function fA330Grv(lPadrao,nValor,cAdiantamento,cSeq,nRegCmp,aBaixas,cOrigem,lCredito,nContab,;
						nAcresc,nDecres,aBaixaSE5,nTotAbto,aImpPcc,cSequencia,cDadosTitulo,nIrrf,ntotIrbx,nPrIss, nPrInss, lNcc, nDescP, nDescD, nIrrfParc )

Local nSaldo		:= 0
Local nSalvRec		:= 0
Local nAtraso		:= 0
Local nTitAcres	:= SE1->E1_SDACRES		//Acrescimo do titulo principal
Local nTitDecre	:= SE1->E1_SDDECRE		//Decrescimo do titulo principal
Local nVlMinImp 	:= GetNewPar("MV_VL10925",5000)
Local lRaRtImp	:= FRaRtImp()
//Controla o Pis Cofins e Csll na baixa (1-Retem PCC na Baixa ou 2-Retem PCC na Emissão(default))
Local lPccBxCr	:= FPccBxCr()
//Controla IRPJ na baixa
Local lIrPjBxCr	:= FIrPjBxCr()
Local cCliente	:= ""
Local cLoja		:= ""
Local lOkTitAb	:= .F.
Local nTamSeq		:= TamSX3("E5_SEQ")[1]
Local nDecs1 		:= MsDecimais(1)
Local nVrAbat		:= 0
Local lFina330  	:= IsInCallStack("ZFINA330")
Local lCompRa		:=	.F.
//Controle de abatimento
Local lTitpaiSE1	:= .T.
Local cTipo 		:= ""
Local nOrdTitPai	:= 0
Local bWhile		:= {|| !EOF() .And. E1_FILIAL==xFilial("SE1") .And. E1_PREFIXO=cPrefixo	.And.	E1_NUM==cNum .And. E1_PARCELA==cParcela .And. E1_CLIENTE==cCliente .And. E1_LOJA==cLoja}
Local cTipoAux	:= ""
Local xFilSE1		:= SE1->E1_FILIAL
//Impostos gerados pela rotina de Borderô de Recebimento de Imposto (FINA061).
Local nPisFina061	:=	0
Local nCofFina061	:=	0
Local nCslFina061	:=	0
Local nIrfFina061	:=	0
Local nRegSE5		:=	0
Local nOrdSE5		:=	0
Local nRegAtu		:=	0
Local nX			:=	0
Local nPosRec     := 0
Local aPcc		:= Array(4)
Local ntitulo1	:= 0
Local ni	:= 0
Local nValBaixa	:= 0
Local aAreaSE	:= {}
Local cChave
Local nPropPCC	:= 0
Local lPropBx  := SuperGetMv("MV_PROPBX",.F.,"2") == "1"
Local aImp		:= {}
Local lCalcIssBx :=  GetNewPar("MV_MRETISS","1") == "2"

DEFAULT cOrigem		:= "  "
DEFAULT lCredito	:= .F.
DEFAULT nContab	:= 1			//1=Sim, 2=Nao
DEFAULT nAcresc	:= 0
DEFAULT nDecres	:= 0
DEFAULT aBaixaSE5	:= {}
DEFAULT nTotAbto	:= SumAbatRec(cPrefixo,cNum,cParcela,SE1->E1_MOEDA,"S",dBaixa)
DEFAULT aImpPcc	:= {0,0,0}
DEFAULT cSequencia	:= Replicate("0",nTamSeq)
DEFAULT nIrrf	:= 0     
DEFAULT	ntotIrbx:= 0    
DEFAULT nPrIss		:= 0 // Provisionamento do INSS e ISS no RA
DEFAULT nPrInss		:= 0 // Provisionamento do INSS e ISS no RA
DEFAULT lNcc		:= .F.
DEFAULT nDescP  := 0
DEFAULT nDescD  := 0
DEFAULT nIrrfParc := 0

aPcc[1]	:= .F.

If dDataBase >= dLastPcc
	nVlMinImp	:= 0
EndIf

nDescP := If(Type("nDescP") != "N",0,nDescP)
nDescD := If(Type("nDescD") != "N",0,nDescD)

// Conversão de valores para garantir que o saldo será abatido conforme moeda do titulo
// Podemos compensar titulos de moedas diferentes, o que causa atenção nas atualizações de saldos

nValor 	:= xMoeda(nValor,nMoeda,SE1->E1_MOEDA,,nDecs1+1,Fa330Tx2(SE1->E1_MOEDA,SE1->E1_TXMOEDA))
nVrAbat	:=	nTotAbto

If !lNcc

	nTotAbto += iif(lPccBxCr,nPis+nCofins+nCsll,0) 
	nTotAbto -= iif(lRartImp .and. lCredito,nPis+nCofins+nCsll,0)
	nTotAbto += iif(lIrPjBxCr .and. !lCredito,nIrrf,0)

Endif
/*If lCredito .and. lRaRtImp 

	nValor:= nValor -  nTotAbto // abato do valor de baixa apenas os impostos calculados no momento da compensação

endIf */

nRegSE5	:=	SE5->(Recno())
nOrdSE5	:=	SE5->(IndexOrd())	
	
If SE1->E1_TIPO <> MVRECANT .AND. SE1->E1_TIPO <> MV_CRNEG .And. (lPccBxCr .Or. lIrPjBxCr)
	dbSelectArea("SE5")
	SE5->(dbSetOrder(2)) //FILIAL + TIPODOC + PREFIXO + NUMERO + PARCELA + TIPO
	
	If SE5->(DBSeek(xFilial("SE5")+"BA"+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO))
		While !SE5->(Eof()) .and. SE5->E5_FILIAL==xFilial("SE5") .And. ;
			SE5->E5_TIPODOC+SE5->E5_PREFIXO+SE5->E5_NUMERO+SE5->E5_PARCELA+SE5->E5_TIPO=="BA"+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO		
		
			If ("FINA061" $ Subst(SE5->E5_HISTOR,1,7)) .And. SE5->E5_MOTBX $ "PCC_IRF"						
				If Alltrim(SE5->E5_MOTBX) == "PCC"
				   nPisFina061	+= SE5->E5_VRETPIS
				   nCofFina061	+=	SE5->E5_VRETCOF
				   nCslFina061	+= SE5->E5_VRETCSL
				ElseIf Alltrim(SE5->E5_MOTBX) == "IRF"
				   nIrfFina061	+= SE5->E5_VRETIRF
				Endif
			Endif					
			SE5->(DbSkip())		
	   Enddo
	Endif
Endif
SE5->(Dbgoto(nRegSE5))
SE5->(Dbsetorder(nOrdSE5))

If ((SE1->E1_SALDO + nTitAcres - nTitDecre - If((mv_par08 == 1.OR. lRaRtImp) .and. !lCredito,nTotAbto,0)) - nValor) <= 0.00999
	nSaldo:= (SE1->E1_SALDO + nTitAcres - nTitDecre - nDescP - If(((mv_par08 == 1 .AND. !lPccBxCr) .OR. lRaRtImp),nTotAbto,0) ) - nValor	// moeda do tit principal
Else
  If (nPisFina061+nCofFina061+nCslFina061+nIrfFina061)> 0 .And. mv_par08 == 2 .And. Alltrim(Upper(FunName())) == "ZFINA330"
		nSaldo:= SE1->E1_SALDO - (nValor - nTitAcres + nTitDecre) - nDescP   	// moeda do tit principal  
		If nSaldo > 0.009999
			nSaldo += (nPisFina061+nCofFina061+nCslFina061+nIrfFina061)
		Endif
  Else  
  		nSaldo:= SE1->E1_SALDO - (nValor	 - nTitAcres + nTitDecre) - nDescP	// moeda do tit principal
  Endif	
Endif    

If !lCredito .and. (!lRartimp .and. mv_par08 == 1) .and. !lNcc
	nSaldo:= SE1->E1_SALDO - (nValor	 - nTitAcres + nTitDecre + nPrIss + nPrInss) - nDescP
	If (nSaldo > 0 .and. lIrPjBxCr) .or. lPropBx 
		nSaldo -= nIrrf
	Endif
	If (nSaldo > 0 .and. lPccBxCr) .or. lPropBx
		nSaldo -= ( nPis + nCofins + nCsll)
	Endif
	If lPropBx .and. nIss > 0 .and. nPrIss == 0
		nSaldo -= nIss
	ElseIf nSaldo > 0 .and. lCalcIssBx .and. !lPropBx
		nSaldo -= nIss
	EndIf
	// Não será usado o nTotAbto, pois o valor do ISS e INSS deverá ser considerado em todas as compensações devido ao provisionamento
EndIf

nSaldo := Iif(nSaldo <= 0.05  .and. nMoeda > 1 /*0.009999*/,0,nSaldo)
cSeq 	:= IIf(cSeq == Nil,PadL("1",nTamSeq,"0"),cSeq)	

RecLock("SE1")

Replace E1_SALDO	  With nSaldo
Replace E1_BAIXA	  With If(E1_BAIXA <= dBaixa, dBaixa, E1_BAIXA)
Replace E1_LOTE	  	  With cLote
Replace E1_MOVIMEN    With dBaixa
Replace E1_DESCONT    With nDescP
Replace E1_MULTA	  With 0
Replace E1_JUROS	  With 0
Replace E1_CORREC     With 0

If cPaisLoc == "BRA"
	Replace E1_VALLIQ   With xMoeda(nValor,SE1->E1_MOEDA,1,,nDecs1+1,Fa330Tx2(SE1->E1_MOEDA,0))
Else
	E1_VALLIQ   += nValor 
EndIf

Replace E1_STATUS   With IIF(E1_STATUS != "R",Iif(E1_SALDO >= 0.01,"A","B"),"R")
Replace E1_SDDECRE  With E1_SDDECRE - nTitDecre
Replace E1_SDACRES  With E1_SDACRES - nTitAcres

SE1->(MsUnlock())

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ PONTO DE ENTRADA NA ALTERACAO DO HISTORICO NA SE1                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock( "F330AHE1" )
   ExecBlock("F330AHE1",.F.,.F.)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se h  ponto de entrada 	³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistBlock("FA330SE1")
	Execblock("FA330SE1",.F.,.F.)
Endif

cNumero	:= E1_NUM
cPrefixo := E1_PREFIXO
cParcela := E1_PARCELA
cCliente := E1_CLIENTE
cLoja	 := E1_LOJA
cTipoTit := ""
nSalvRec	:= SE1->(RecNo())

If ! ( SE1->E1_TIPO $ MVRECANT+"/"+MV_CRNEG ) .and. nSaldo > 0
	nTotAbat := SumAbatRec(cPrefixo,cNumero,cParcela,1,"S")
Else
	nTotAbat := 0
EndIf

RecLock("SE1")
If cPaisLoc == "BRA" .and. lPccBxCr .and. !lCredito
	If dDataBase < dLastPcc
	If (if(nSaldo==0 .and. nTotAbto > nVrAbat,Str(nTotAbto-nVrAbat,16,2),Str(nSaldo,16,2))=Str(aImpPcc[1]+aImpPcc[2]+aImpPcc[3],16,2));
		.or. (nSaldo==0 .and. (Str(nTotAbto-nVrAbat,16,2))>(Str(aImpPcc[1]+aImpPcc[2]+aImpPcc[3],16,2))) ;
		.or. (nSaldo == nTotAbat)
		nPis 	:= aImpPcc[1] //entra aki para gravar na baixa tota l não proporcionaliza // analisar
		nCofins := aImpPcc[2]
		nCsll	:= aImpPcc[3]
		nPisBaseR 	:= Round(NoRound(nCsll * 100,3),2)//trecho retirado do FA070TOTMES
		nPisBaseC 	:= Round(NoRound(nCsll * 100,3),2)// no calculo do PCC na função F330CalcPCC não considera cumulatividade, portanto a mesma base de calculo é a de retenção
		nCofBaseR 	:= Round(NoRound(nCsll * 100,3),2)
		nCofBaseC 	:= Round(NoRound(nCsll * 100,3),2)
		nCslBaseR 	:= Round(NoRound(nCsll * 100,3),2)
		nCslBaseC 	:= Round(NoRound(nCsll * 100,3),2)
		
	Else	
		If (MV_PAR08==1 .OR. lRaRtImp) .and. !lNcc
				If lRARtImp .and. !lNcc
						If Len(aTitulos) > 0
							ntitulo1 += nValor+nPis+nCofins+nCsll+nIrrf+nIss+nInss
							nPropPcc := (ntitulo1 / SE1->E1_VALOR)
						Else
							nPropPcc := nPis/SE1->E1_PIS
						EndIf
				ElseIf !lRARtImp .and. !lNcc
					If aDadosret[1] <= nVlMinImp .and. aDadosret[1] + nValor > nVlMinImp .and. lPccBxCr .and. (!lIrPjBxCr .or. SE1->E1_ISS > 0)
						If nValPis > 0 
				nPropPcc := nPis/SE1->E1_PIS
			Else
							nPropPcc	:= (aDadosRet[1] + nValor + nPis + nCofins + nCsll)/(nValor + nPis + nCofins + nCsll)
						EndIf
					ElseIf aDadosret[1] < nVlMinImp .and. aDadosret[1] + nValor > nVlMinImp .and. lPccBxCr 
						nPropPcc	:=  (aDadosret[1] + nValor + nTotAbto)/(nValor + nTotAbto)	
					ElseIf nValor > nVlMinImp
					nPropPcc := nValor/SE1->E1_VLCRUZ
					ElseIf aDadosret[1] <= nVlMinImp .and. aDadosret[1] + nValor <= nVlMinImp .and. lPccBxCr .and. (!lIrPjBxCr .or. SE1->E1_ISS > 0)
						nPropPcc	:= nPis/SE1->E1_PIS
					ElseIf (aDadosret[1] > nVlMinImp .and. aDadosret[1] + nValor > nVlMinImp) .and. lPccBxCr .and. (!lIrPjBxCr .or. SE1->E1_ISS > 0)
					nPropPcc := nValor/SE1->E1_VLCRUZ
				Else
						nPropPcc := 0
				EndIf
				Else
					nPropPcc := (nValor*nTotAbto)/SE1->E1_VLCRUZ     // é aqui o ntotabto está 0 pq é NCC
					nPropPcc := (nPropPcc/nTotAbto)
			EndIf
		Else
				If !lRARtImp .and. mv_par08 == 2 .and. aDadosret[1] <= nVlMinImp .and. aDadosret[1] + nValor > nVlMinImp .and. lPccBxCr .and. (!lIrPjBxCr .or. SE1->E1_ISS > 0)
					nPropPcc := (aDadosret[1] + nValor )/(SE1->E1_VLCRUZ)
				ElseIf nValor > nVlMinImp .or. aDadosret[1] + nValor > nVlMinImp 
			nPropPcc := nValor/SE1->E1_VLCRUZ
				Else 
					nPropPcc := 0
				Endif
		Endif
	       If Str(nSaldo,16,2)<>Str(nPis+nCofins+nCsll+nTotAbat,16,2)
			nPis		:= Round(NoRound(SE1->E1_PIS * nPropPCC,3),2)
			nCofins		:= Round(NoRound(SE1->E1_COFINS * nPropPCC,3),2)
			nCsll		:= Round(NoRound(SE1->E1_CSLL * nPropPCC,3),2)
			nPisBaseR 	:= Round(NoRound(SE1->E1_BASEPIS * nPropPCC,3),2)
			nPisBaseC 	:= Round(NoRound(SE1->E1_BASEPIS * nPropPCC,3),2)
			nCofBaseR 	:= Round(NoRound(SE1->E1_BASECOF * nPropPCC,3),2)
			nCofBaseC 	:= Round(NoRound(SE1->E1_BASECOF * nPropPCC,3),2)
			nCslBaseR 	:= Round(NoRound(SE1->E1_BASECSL * nPropPCC,3),2)
			nCslBaseC 	:= Round(NoRound(SE1->E1_BASECSL * nPropPCC,3),2)
			
			aImpPcc[1] -= nPis
			aImpPcc[2] -= nCofins
			aImpPcc[3] -= nCsll
			
		Endif
		If lIrPjBxCr
			If MV_PAR08 == 1 .And. !lRaRtImp .And. nIrrf == nSaldo//Ultima baixa considera o restante de IRRF
				nIRFBase  := Round(NoRound(SE1->E1_BASEIRF * nPropPCC,3),2)
			Else 
				nIrrf		:= Round(NoRound(SE1->E1_IRRF * nPropPCC,3),2)
				nIRFBase  := Round(NoRound(SE1->E1_BASEIRF * nPropPCC,3),2)
			EndIf
		Endif
			aAreaSE := GetArea()
			DbSelectArea("SFQ")
			SFQ->(dbSetOrder(1))
			For ni := 1 to Len(aTitulos)
			cChave := aTitulos[ni,1]+aTitulos[ni,2]+aTitulos[ni,3]+aTitulos[ni,4] // prefixo+numero+parcela+tipo
			If SFQ->(DbSeek(xFilial("SFQ")+'E1B'+cChave))
				While !SFQ->(Eof()) .and. FQ_PREFORI+FQ_NUMORI+FQ_PARCORI+FQ_TIPOORI == cChave
				nPis	:= nPis + SFQ->FQ_SABTPIS
				nCofins	:= nCofins + SFQ->FQ_SABTCOF
				nCsll	:= nCsll + SFQ->FQ_SABTCSL
				SFQ->(DbSkip())
				EndDo
			EndIf
			Next ni
			RestArea(aAreaSE)
			aImpPcc[1] -= nPis
			aImpPcc[2] -= nCofins
			aImpPcc[3] -= nCsll			
	Endif
    Else
    	/*If nPis == 0 .And.  Empty(SE1->E1_NUMBOR) .and. !lRartImp
			aPcc		:= newMinPcc(dDataBase,nValRec,SE1->E1_NATUREZ,"R",SE1->E1_CLIENTE+SE1->E1_LOJA)
			nPis		:= 	aPcc[2]
			nCofins		:=	aPcc[3]
			nCsll		:=  aPcc[4]
			
			nPisCalc	:= nPis
			nPisBaseC	:= nValRec	
			nPisBaseR 	:= nValRec
			nCofCalc	:= nCofins	
			nCofBaseC	:= nValRec
			nCofBaseR 	:= nValRec
			nCslCalc	:= nCsll	
			nCslBaseC	:= nValRec
			nCslBaseR 	:= nValRec
			
		EndIf*/
	EndIf
    If (MV_PAR08==1 .OR. lRaRtImp) .AND. !lNcc
    	nRegAtu := SE1->(Recno())
    	SE1->(DbGoTo(nRegCmp))
    	If SE1->E1_VALOR + SE1->(E1_PIS+E1_COFINS+E1_CSLL) > SE1->E1_BASEPIS
			SE1->(DbGoTo(nRegAtu))
			If lIrPjBxCr
				E1_SALDO -= nIrrf
			EndIf
		Else
			SE1->(DbGoTo(nRegAtu))
		EndIf			
	Endif
    //If !lRaRtImp .AND. !lNcc .and. mv_par08 == 1 .and. SE1->E1_SALDO > 0 
    	//nRegAtu := SE1->(Recno())
    		//SE1->(DbGoTo(nRegAtu))
			//E1_SALDO -= nPis+nCofins+nCsll+nIrrf

	//Endif
	E1_STATUS := IIF(E1_STATUS != "R","B","R")
	
Endif

IF (Str(nSaldo,16,2)=Str(nTotAbat,16,2) .or. Str(nSaldo,16,2)=Str(nPis+nCofins+nCsll+nTotAbat,16,2).And. mv_par08 == 1 .and. ( (!lRaRtImp .and. !lCredito) .or. lRaRtImp )) .or.;  
(Str(nSaldo,16,2)=Str(SE1->(E1_PIS+E1_COFINS+E1_CSLL),16,2) .And. mv_par08 == 2 .and. lRaRtImp )
	REPLACE E1_SALDO With 0 
	Replace E1_STATUS   With IIF(E1_STATUS != "R","B","R")
EndIf
SE1->(MsUnlock())

//atualiza status do adiantamento de viagem
If SE1->E1_SALDO==0 .AND. (ALLTRIM(SE1->E1_ORIGEM) == "FINA677")
	FINATURES(SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA),.T.,SE1->E1_ORIGEM,"R")
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava um registro para cada Movimenta‡„o Banc ria 			  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

SE1->(dbGoTo(nSalvRec))
FA330Mov(lPadrao,nValor,cAdiantamento,cSeq,nRegCmp,@abaixas,cOrigem,lCredito,nContab,nAcresc,nDecres,nTitAcres,nTitDecre,aBaixaSE5,nTotAbto,@cSequencia, lNcc)
SE1->(dbGoTo(nSalvRec))

If SE1->E1_TIPO $ MVRECANT .AND. lFina330
	lCompRa	:=	.T.
EndIf

If ! ( SE1->E1_TIPO $ MVRECANT+"/"+MV_CRNEG ) .OR. (lCompRa .AND. SE1->E1_TIPO $ MVRECANT)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Baixar titulos de abatimento se for baixa total					³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SE1")
	If E1_SALDO = 0 .or. lPropBx	//.OR. ( lCompRA .And. lCredito .AND. SE1->E1_TIPO $ MVRECANT)
		If lPropBx .and. !lCredito
			If (E1_SALDO == 0 .AND. MV_PAR08 == 1) .or. lRartImp
				nImp	:= SE1->E1_PIS + SE1->E1_COFINS + SE1->E1_CSLL + SE1->E1_IRRF + SE1->E1_INSS + SE1->E1_ISS
				nVal	:= (SE1->E1_VALOR * nValor)/(SE1->E1_VALOR - nImp)
			Else
				nVal	:= nValor
			EndIf
			aImp	:= FpropCR(SE1->E1_VALOR, SE1->E1_PIS, SE1->E1_COFINS, SE1->E1_CSLL, SE1->E1_IRRF, SE1->E1_INSS, SE1->E1_ISS, nVal)
		EndIf
		cTipo := If( lCompRA .And. lCredito, cTipoAux, SE1->E1_TIPO )
		SE1->(dbSetOrder(2))
		SE1->(dbSeek(xFilSE1+cCliente+cLoja+cPrefixo+cNum+cParcela))
		If lTitpaiSE1
	 		If (nOrdTitPai:= OrdTitpai()) > 0
				SE1->(DbSetOrder(nOrdTitPai))
				If	DbSeek(xFilSE1+cPrefixo+cNumero+cParcela+cTipo+cCliente+cLoja)
					bWhile := {|| !Eof() .And. E1_FILIAL + Trim(E1_TITPAI) == xFilSE1+Trim(cPrefixo+cNumero+cParcela+cTipo+cCliente+cLoja) }
				Else
					SE1->(dbSetOrder(2))
					SE1->(dbSeek(xFilial("SE1")+cCliente+cLoja+cPrefixo+cNum+cParcela))
				Endif
			Endif
		Endif

		While Eval(bWhile)
			If lTitpaiSE1
				If !Empty(SE1->E1_TITPAI) .and. (Alltrim(SE1->E1_TITPAI) != Alltrim(cPrefixo+cNumero+cParcela+cTipo+cCliente+cLoja) )
					SE1->(DbSkip())
					Loop
				EndIf
			EndIf

			IF If(lCompRa,E1_TIPO,SE1->E1_TIPO) $ If(lPccBxCr,"COF/CSL/PIS/IR-/IN-/IS-/FE-/FB-/AB-",(MVABATIM+"/"+MVIRABT+"/"+MVINABT+"/"+MVPIABT+"/"+MVCFABT+"/"+MVCSABT))

				RecLock("SE1")
					If !lPropBx 
				Replace E1_SALDO 	With 0
					Else
						Do Case
							Case E1_TIPO $ MVPIABT .and. !lPccBxCr
								Replace E1_SALDO	With (E1_SALDO - aImp[1][1])
							Case E1_TIPO $ MVCFABT .and. !lPccBxCr
								Replace E1_SALDO	With (E1_SALDO - aImp[1][2])
							Case E1_TIPO $ MVCSABT .and. !lPccBxCr
								Replace E1_SALDO	With (E1_SALDO - aImp[1][3])
							Case E1_TIPO $ MVIRABT .and. !lIrPjBxCr
								Replace E1_SALDO	With (E1_SALDO - aImp[1][4]) 
							Case E1_TIPO $ MVINABT 				
								Replace E1_SALDO	With (E1_SALDO - aImp[1][5])
							Case E1_TIPO $ MVISABT   				
								Replace E1_SALDO	With (E1_SALDO - aImp[1][6])	
						EndCase
					EndIf
				Replace E1_BAIXA 	With If(E1_BAIXA <= dBaixa, dBaixa, E1_BAIXA)
				Replace E1_LOTE		With cLote
				Replace E1_MOVIMEN	With dBaixa
				Replace E1_PORTADO	With cBanco
				Replace E1_STATUS   With IIF(E1_STATUS != "R",Iif(E1_SALDO >= 0.01,"A","B"),"R")

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Gravar o titulo que baixou o AB- para evitar estornos de ³
				//³abatimentos baixados por outras rotinas. Evita que um AB-³
				//³baixado pelo FINA070 / 110 seja estornado indevidamente  ³
				//³pelo FINA330, que gera erro na composicao do saldo do    ³
				//³titulo principal com abatimento.                         ³
				//³Gravar SEMPRE NCC/RA para identificar a baixa do AB-     ³
				//³pela rotina FINA330										³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !Empty(cDadostitulo)
					If Empty(E1_TITPAI)
						Replace E1_TITPAI	With cDadosTitulo
					EndIf
				Else
					Replace E1_TITPAI	With ""
				Endif
				SE1->(MsUnlock())
			EndIf
			SE1->(dbSkip())
		EndDo
		SE1->(DbSetOrder(1))
	EndIf
	SE1->(dbGoto( nSalvRec ))
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Posiciona no registro de natureza 	 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SED")
	SED->(dbSeek(xFilial("SED")+SE1->E1_NATUREZ))

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza campo de maior atrazo no Cadastro de Clientes     		  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SA1")
	SA1->(DbSetOrder(1))
	SA1->(dbSeek(xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA))
	RecLock("SA1")
	nAtraso := dBaixa-SE1->E1_VENCTO
	If nAtraso > 1
		IF Dow(SE1->E1_VENCTO) == 1 .Or. Dow(SE1->E1_VENCTO) == 7
			IF Dow(dBaixa) == 2 .and. nAtraso <= 2
				nAtraso := 0
			EndIF
		EndIF
		nAtraso:=IIF(nAtraso<0,0,nAtraso)
		If SA1->A1_MATR < nAtraso
			Replace A1_MATR With nAtraso
		EndIf
	Endif
	SA1->(MsUnlock())
ElseIf cPaisLoc == "BRA"
	//Baixar titulos de abatimento se for baixa total do(s) título(s) selecionado(s) no array aTitulos
	dbSelectArea("SE1")
	If Funname() == "ZFINA330" .Or. Funname() == "FINA740" .or. Funname() == "ZFINA330"
		If MV_PAR02 == 1
			nPosRec := 20
		Else
			nPosRec := 23
		EndIf	 
	EndIf	
	For nX := 1 To Len(aTitulos)
		DbSelectArea("SE1")
		SE1->(DbGoTo(aTitulos[nX][nPosRec]))		
		xFilSE1		:= SE1->E1_FILIAL
		cNumero		:= SE1->E1_NUM
		cPrefixo 	:= SE1->E1_PREFIXO
		cParcela 	:= SE1->E1_PARCELA
		cCliente 	:= SE1->E1_CLIENTE
		cLoja	 	:= SE1->E1_LOJA
				
		If (SE1->E1_SALDO - aTitulos[nX][09]) == 0 //Baixa total	
			cTipo:= If( lCompRA .And. lCredito, cTipoAux, SE1->E1_TIPO )
			dbSetOrder(2)
			dbSeek(xFilSE1+cCliente+cLoja+cPrefixo+cNumero+cParcela) 
			If lTitpaiSE1 
		 		If FindFunction("OrdTitpai") .and. (nOrdTitPai:= OrdTitpai()) > 0
					DbSetOrder(nOrdTitPai)
					If	DbSeek(xFilSE1+cPrefixo+cNumero+cParcela+cTipo+cCliente+cLoja)
						bWhile := {|| !Eof() .And. E1_FILIAL + Trim(E1_TITPAI) == xFilSE1+Trim(cPrefixo+cNumero+cParcela+cTipo+cCliente+cLoja) }
					Else
						dbSetOrder(2)		
						dbSeek(xFilial("SE1")+cCliente+cLoja+cPrefixo+cNumero+cParcela)
					Endif
				Endif
			Endif
			
			While Eval(bWhile)                         
				If lTitpaiSE1
					If !Empty(E1_TITPAI) .and. (Alltrim(E1_TITPAI)!=Alltrim(cPrefixo+cNumero+cParcela+cTipo+cCliente+cLoja) )
						DbSkip()
						Loop
					EndIf
				EndIf        
				
				IF If(lCompRa,E1_TIPO,SE1->E1_TIPO) $ If(lPccBxCr,"COF/CSL/PIS/IR-/IN-/IS-/FE-/FB-",(MVABATIM+"/"+MVIRABT+"/"+MVINABT+"/"+MVPIABT+"/"+MVCFABT+"/"+MVCSABT)) 								
	
						RecLock("SE1")
						Replace E1_SALDO 	With 0
						Replace E1_BAIXA 	With If(E1_BAIXA <= dBaixa, dBaixa, E1_BAIXA)
						Replace E1_LOTE		With cLote
						Replace E1_MOVIMEN	With dBaixa
						Replace E1_PORTADO	With cBanco
						Replace E1_STATUS   With IIF(E1_STATUS != "R",Iif(E1_SALDO >= 0.01,"A","B"),"R")
					
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³Gravar o titulo que baixou o AB- para evitar estornos de ³
						//³abatimentos baixados por outras rotinas. Evita que um AB-³
						//³baixado pelo FINA070 / 110 seja estornado indevidamente  ³
						//³pelo FINA330, que gera erro na composicao do saldo do    ³
						//³titulo principal com abatimento.                         ³
						//³Gravar SEMPRE NCC/RA para identificar a baixa do AB-     ³
						//³pela rotina FINA330										³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						If SE1->(FieldPos("E1_TITPAI")) # 0
							If !Empty(cDadostitulo)
								If Empty(E1_TITPAI)
									Replace E1_TITPAI	With cDadosTitulo 
								EndIf
							Else
								Replace E1_TITPAI	With ""
							Endif
						Endif
						MsUnlock()
	
				EndIf
				dbSelectArea( "SE1" )
				dbSkip( )
			EndDo
			DbSetOrder(1)
		Else
			Loop
		EndIf
		dbGoto( nSalvRec )
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Posiciona no registro de natureza 	 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SED")
		dbSeek(xFilial("SED")+SE1->E1_NATUREZ)
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza campo de maior atrazo no Cadastro de Clientes     		  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		dbSelectArea("SA1")
		DbSetOrder(1)
		dbSeek(xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA)
		RecLock("SA1")
		nAtraso:=dBaixa-SE1->E1_VENCTO
		If nAtraso > 1
			IF Dow(SE1->E1_VENCTO) == 1 .Or. Dow(SE1->E1_VENCTO) == 7
				IF Dow(dBaixa) == 2 .and. nAtraso <= 2
					nAtraso := 0
				EndIF
			EndIF
			nAtraso:=IIF(nAtraso<0,0,nAtraso)
			If SA1->A1_MATR < nAtraso
				Replace A1_MATR With nAtraso
			EndIf
		Endif
		MsUnlock()
	Next nX
	SE1->(dbGoto(nSalvRec))	
EndIf
dbSelectArea("SE1")
SE1->(dbSetOrder(1))

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o	 ³ FA330Mov ³ Autor ³ Valter G. Nogueira Jr.³ Data ³ 21/03/94 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Grava registros referentes a compensacao de titulos		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ FA330Mov(ExpC1,ExpN2)                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ FINA330                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FA330Mov(lPadrao,nValor,cAdiantamento,cSeq,nRegCmp,aBaixas,cOrigem,lCredito,nContab,;
								 nAcresc,nDecres,nTitAcres,nTitDecre,aBaixaSE5,nTotAbto,cSequencia, lNcc)
Local nTamSeq			:= TamSX3("E5_SEQ")[1]
Local cAlias			:= Alias()
LOCAL cDocOriginal	:= SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO+SE1->E1_LOJA
LOCAL nRecSe1			:= SE1->(RecNo())
LOCAL nValorReal		:= 0
Local cSeqPrc 		:= Replicate("0",nTamSeq)
Local cSeqAdt 		:= Replicate("0",nTamSeq)
LOCAL nDecs1			:= MsDecimais(1)
LOCAL aArea			:= {}
LOCAL cFilOrig		:= ''
LOCAL cCliOri			:= ''
LOCAL cLojaOri		:= ''
LOCAL cCliAdt			:= ''
LOCAL cLojaAdt		:= ''
Local lImpComp		:= SuperGetMv("MV_IMPCMP",,"2") == "1"
Local lIsNcc			:= .F.
Local nValPis			:= 0
Local nValCof			:= 0
Local nValCSL			:= 0
local nRecImp			:= 0
//Compensacao de contas a receber, nao necessita verificar o parametro MV_BX10925
Local lPCCBaixa		:= (cPaisLoc == "BRA")
//Controla o Pis Cofins e Csll na baixa (1-Retem PCC na Baixa ou 2-Retem PCC na Emissão(default))
Local lPccBxCr		:= FPccBxCr()
Local lRaRtImp		:= FRaRtImp()
//Controla IRPJ na baixa
Local lIrPjBxCr		:= FIrPjBxCr() 
local nPropIR :=0
local nIR	  :=0 //variavel q irá armazenar no valor proporcional do IR
Local lMultFil  := ExistBlock("SE5MTFIL") // CRIADO PARA MANIPULAR A FILIAL NO MOVIMENTO BANCARIO
Local aAreaSE5	:= {}
Local nVlReal:= 0

//Impostos gerados pela rotina de Borderô de Recebimento de Imposto (FINA061).
Local	nPisFina061	:=	0
Local	nCofFina061	:=	0
Local	nCslFina061	:=	0
Local	nIrfFina061	:=	0
Local nRegSE5	:=	0
Local	nOrdSE5	:=	0
/*
 * Reestrutura das tabelas do processo de movimento bancário
 */
Local oModelBxR		:= FWLoadModel("FINM010") //Model de baixas a receber
Local oSubFK1		:= Nil	//BAIXAS A RECEBER
Local oSubFK6		:= Nil	//Valores complementares
Local cLog 			:= ""
Local cChaveFK7		:= ""
Local cCamposE5		:= ""
Local lRet 			:= .T.
Local oSubFKA		:= Nil						//Baixas a receber para atualização de retenção

/*
 * Dados da tabela auxiliar com o código do título a receber (SE1)
 */
Local cChaveTit		:= 	xFilial("SE1")	+ "|" +; 
						SE1->E1_PREFIXO		+ "|" +;
						SE1->E1_NUM			+ "|" +;
						SE1->E1_PARCELA		+ "|" +;
						SE1->E1_TIPO			+ "|" +;
						SE1->E1_CLIENTE		+ "|" +;
						SE1->E1_LOJA
		
Local cFilSE5			:= FWxFilial('SE5')
Local cIdFK1			:= ''
Local cHistMov			:= ''
Local cTpDoc			:= ''
Local lBq10925  		:= SuperGetMv("MV_BQ10925",.F.,"2") == "2"

DEFAULT lCredito		:= .F.
DEFAULT nContab			:= 1
DEFAULT nAcresc			:= 0
DEFAULT nDecres			:= 0
DEFAULT aBaixaSE5		:= {}
DEFAULT nTotAbto		:= 0
DEFAULT cSequencia	:= Replicate("0",nTamSeq)
DEFAULT lNcc		:= .F.


PRIVATE nCm			:= 0
PRIVATE cMotBx		:= "CMP"
PRIVATE l330Mov1		:= ExistBlock("SE5FI330")
PRIVATE l330Mov2		:= ExistBlock("SE5FI331")

//Posiciono no titulo de adiantamento
dbSelectArea("SE1")
SE1->(dbSetOrder(1))
SE1->(dbGoTo(nRegCmp))
cFilOrig	 	:= SE1->E1_FILIAL
nValorReal		:= Round(NoRound(xMoeda(nValor,nMoeda,1,,nDecs1+1,Fa330Tx2(nMoeda,nTxMoeda)),3),nDecs1+1)
cCliAdt		:= SE1->E1_CLIENTE
cLojaAdt		:= SE1->E1_LOJA

If nDescD == 0
	// Desconto FINANCEIRO - Compensação
	If lF330DESC
		lDESC := ExecBlock("F330DESC",.F.,.F.)
		If lDESC
			nDescD:= IIf(SE1->E1_DESCFIN > 0 .And. SE1->E1_VENCREA-dBaixa >= SE1->E1_DIADESC .and. SE1->E1_DESCONT == 0,SE1->E1_VALOR * (SE1->E1_DESCFIN/100),0)
		EndIf
	EndIf
EndIf

If !lCredito
	lIsNcc := SE1->E1_TIPO $ MV_CRNEG   //Verifico se o titulo de adiantamento é um NCC
Endif

If cPaisLoc <> "BRA" .And. Type("aTxMoedas")#"U" .And. FunName() <> "ZFINA330"
	nValorReal := xMoeda(nValor,nMoeda,1,dDatabase,nDecs1+1,aTxMoedas[nMoeda][2],nDecs1)
EndIf
cSeqAdt := FaNxtSeqBx()  // Sequencia da baixa do adiantamento + 1

SE1->(dbGoTo(nRecSe1))
cSeqPrc	:= FaNxtSeqBx()  // Sequencia da baixa do titulo + 1
cCliOri	:= SE1->E1_CLIENTE
cLojaOri	:= SE1->E1_LOJA

If lCredito
	lIsNcc := SE1->E1_TIPO $ MV_CRNEG   //Verifico se o titulo de adiantamento é um NCC
Endif

cSequencia := IIf(cSeqAdt > cSeqPrc,cSeqAdt,cSeqPrc)

dbSelectArea("SE5")
SE5->(dbSetOrder(1))

If nValor != 0
	oModelBxR		:= FWLoadModel("FINM010") 
	oModelBxR:SetOperation( MODEL_OPERATION_INSERT ) //Inclusao
	oModelBxR:Activate()		
	oModelBxR:SetValue( "MASTER", "E5_GRV", .T. ) //Informa se vai gravar SE5 ou não
	oModelBxR:SetValue( "MASTER", "NOVOPROC", .T. ) //Informa que a inclusão será feita com um novo número de processo	
	//Define os campos que não existem nas FKs e que serão gravados apenas na E5, para que a gravação da E5 continue igual  
	cCamposE5:="{"
	cCamposE5 += "{'E5_FILIAL'		,'" + cFilSE5 			+ "'}"
	cCamposE5 += ",{'E5_PREFIXO'	,'" +  SE1->E1_PREFIXO	+ "'}"
	cCamposE5 += ",{'E5_NUMERO'		,'" +  SE1->E1_NUM		+ "'}"
	cCamposE5 += ",{'E5_PARCELA'	,'" +  SE1->E1_PARCELA	+ "'}"
	cCamposE5 += ",{'E5_CLIENTE'	,'" +  SE1->E1_CLIENTE	+ "'}"
	cCamposE5 += ",{'E5_CLIFOR'		,'" +  SE1->E1_CLIENTE	+ "'}"
	cCamposE5 += ",{'E5_LOJA'		,'" +  SE1->E1_LOJA		+ "'}"
	cCamposE5 += ",{'E5_BENEF'		,'" + StrTran(SE1->E1_NOMCLI,"'","")+ "'}"
	cCamposE5 += ",{'E5_TIPO'		,'" +  SE1->E1_TIPO		+ "'}"
	cCamposE5 += ",{'E5_DTDIGIT'	, STOD('" + DTOS(dDataBase) + "')}"
	cCamposE5 += ",{'E5_DTDISPO'	, STOD('" + DTOS(dBaixa) + "')}"
	cCamposE5 += ",{'E5_SITCOB'		,'" + SE1->E1_SITUACA + "' }"

	/*
	 * Ponto de Entrada para permitir a manipulação da filial no movimento bancario
	 */
	If ! lMultFil
		cCamposE5 += ",{'E5_FILIAL'		,'" + xFilial("SE5") + "' } "
	Else
		cCamposE5 += ",{'E5_FILIAL'		,'" + ExecBlock("SE5MTFIL",.F.,.F.,cFilAnt) + "' } "
	EndIf

	cCamposE5 += ",{'E5_LA'			,'" +  IIF(lPadrao .and. nContab == 1,"S","N") + "'}"	
	cChaveFK7	:= FINGRVFK7("SE1", cChaveTit)
	cIdFK1		:= FWUUIDV4()

	/*
	 * Dados da baixa a receber
	 */
	oSubFK1 := oModelBxR:GetModel( "FK1DETAIL" )
	oSubFKA := oModelBxR:GetModel( "FKADETAIL" )
	oSubFK6 := oModelBxR:GetModel( "FK6DETAIL" )

	If !oSubFKA:IsEmpty()
		oSubFKA:AddLine()
	EndIf
	
	oSubFKA:SetValue( "FKA_IDORIG"	, cIdFK1 )
	oSubFKA:SetValue( "FKA_TABORI"	, 'FK1')
	
	If !oSubFK1:IsEmpty()
		oSubFK1:AddLine()
	EndIf

	oSubFK1:SetValue( "FK1_DATA"	, dBaixa )		
	oSubFK1:SetValue( "FK1_NATURE"	, SE1->E1_NATUREZ )
	oSubFK1:SetValue( "FK1_RECPAG"	, "R" )
	oSubFK1:SetValue( "FK1_HISTOR"	, cHistMov )
	oSubFK1:SetValue( "FK1_MOTBX"	, "CMP")
	oSubFK1:SetValue( "FK1_ORIGEM"	, FunName() )
	oSubFK1:SetValue( "FK1_SEQ"		, cSequencia )
	oSubFK1:SetValue( "FK1_DOC"		, SE1->E1_NUMBOR )
	oSubFK1:SetValue( "FK1_IDDOC"	, cChaveFK7 )
	oSubFK1:SetValue( "FK1_TPDOC"	, cTpDoc )	
	oSubFK1:SetValue( "FK1_CCUSTO"	, SE1->E1_CCUSTO )	
	oSubFK1:SetValue( "FK1_FILORI"	, SE1->E1_FILORIG )
	oSubFK1:SetValue( "FK1_VALOR"	, nValorReal )
	oSubFK1:SetValue( "FK1_VLMOE2"	, Round(NoRound(xMoeda(nValor   ,nMoeda,SE1->E1_MOEDA,,3,Fa330Tx2(nMoeda,nTxMoeda),Fa330Tx2(SE1->E1_MOEDA,SE1->E1_TXMOEDA)),3),2) )
	oSubFK1:SetValue( "FK1_SITCOB"	, SE1->E1_SITUACA )
	oSubFK1:SetValue( "FK1_MOEDA"	, StrZero(nMoeda,2) )
	oSubFK1:SetValue( "FK1_LOTE"	, cLote )
	oSubFK1:SetValue( "FK1_DOC"		, cAdiantamento )
	oSubFK1:SetValue( "FK1_LA"		, IIF(lPadrao .and. nContab == 1,"S","N") )
	
	If nTitAcres <> 0
		If !oSubFK6:IsEmpty()
			oSubFK6:AddLine()
		EndIf
		oSubFK6:SetValue( 'FK6_GRVSE5'  , .F.)		
		oSubFK6:SetValue( 'FK6_IDFK6'	, GetSxEnum('FK6','FK6_IDFK6') )											
		oSubFK6:SetValue( 'FK6_TABORI'	, 'FK1' )
		oSubFK6:SetValue( 'FK6_TPDOC'	, 'JR' )
		oSubFK6:SetValue( 'FK6_VALCAL'	, Round(NoRound(xMoeda(nTitAcres,nMoeda,1,,3,Fa330Tx2(nMoeda,0)),3),2) )	
		oSubFK6:SetValue( 'FK6_VALMOV'	, Round(NoRound(xMoeda(nTitAcres,nMoeda,1,,3,Fa330Tx2(nMoeda,0)),3),2) )
		oSubFK6:SetValue( 'FK6_RECPAG'	, "R" )
		oSubFK6:SetValue( 'FK6_IDORIG'	, cIdFK1 )
		oSubFK6:SetValue( 'FK6_HISTOR'	, OemToAnsi(STR0049) ) //ACRESCIMO

		
		cCamposE5 += ",{'E5_VLJUROS'," + Str(Round(NoRound(xMoeda(nTitAcres,nMoeda,1,,3,Fa330Tx2(nMoeda,0)),3),2)) + " }"
	EndIf
	
	If nTitDecre+nDescP <> 0
		If !oSubFK6:IsEmpty()
			oSubFK6:AddLine()
		EndIf
		oSubFK6:SetValue( 'FK6_GRVSE5'  , .F.)		
		oSubFK6:SetValue( 'FK6_IDFK6'	, GetSxEnum('FK6','FK6_IDFK6') )											
		oSubFK6:SetValue( 'FK6_TABORI'	, 'FK1' )
		oSubFK6:SetValue( 'FK6_TPDOC'	, 'DC' )
		oSubFK6:SetValue( 'FK6_VALCAL'	, Round(NoRound(xMoeda(nTitDecre+nDescP,nMoeda,1,,3,Fa330Tx2(nMoeda,0)),3),2) )	
		oSubFK6:SetValue( 'FK6_VALMOV'	, Round(NoRound(xMoeda(nTitDecre+nDescP,nMoeda,1,,3,Fa330Tx2(nMoeda,0)),3),2) )
		oSubFK6:SetValue( 'FK6_RECPAG'	, "R" )
		oSubFK6:SetValue( 'FK6_IDORIG'	, cIdFK1 )
		oSubFK6:SetValue( 'FK6_HISTOR'	, OemToAnsi(STR0050) ) //DECRESCIMO
		oSubFK6:SetValue( 'FK6_TPDESC'	, Iif(SE1->E1_TPDESC == 'C', '1', '2') )
		
		cCamposE5 += ",{'E5_VLDESCO'," + Str(Round(NoRound(xMoeda(nTitDecre+nDescP,nMoeda,1,,3,Fa330Tx2(nMoeda,0)),3),2)) + " }"
		cCamposE5 += ",{'E5_VLDECRE'," + Str(Round(NoRound(xMoeda(nTitDecre,nMoeda,1       ,,3,Fa330Tx2(nMoeda,0)),3),2)) + " }"
	EndIf
	
	nValEstrang := Round(NoRound(xMoeda(nValor   ,nMoeda,SE1->E1_MOEDA,,3,Fa330Tx2(nMoeda,0),Fa330Tx2(SE1->E1_MOEDA,SE1->E1_TXMOEDA)),3),2)
	FA070CORR(  (nValor-nAcresc+nDecres)  ,Fa330Tx2(SE1->E1_MOEDA,SE1->E1_TXMOEDA))
	nTxMoed1		:=	nTxMoed2	:=	nValEmis	:=	nValBax	:=	nValCm :=	0

	nValCorCM += nCM // variavel para contabilização da CM do titulo principal (atribuirá na variavel VALOR4).

	// Grava o valor de correção monetária no SE5 para ser visualizado na consulta
	If cPaisLoc == "MEX" .And. SE5->E5_MOEDA <> "1" .And. FunName() == "ZFINA330"
		nTxCor		:= Iif(SE1->E1_TXMOEDA > 0, SE1->E1_TXMOEDA, RecMoeda(SE1->E1_EMISSAO, SE1->E1_MOEDA))
		nValOrig	:= Round(xMoeda(nValorReal,nMoeda,1,,,nTxCor),2)
		nValAtu	:= Round(xMoeda(nValorReal,nMoeda,1,,,aTxMoedas[nMoeda][2]),2)
		
		If nValAtu - nValOrig <> 0
			If !oSubFK6:IsEmpty()
				oSubFK6:AddLine()
			EndIf	
			oSubFK6:SetValue( 'FK6_GRVSE5'  , .F.)			
			oSubFK6:SetValue( 'FK6_IDFK6'	, GetSxEnum('FK6','FK6_IDFK6') )											
			oSubFK6:SetValue( 'FK6_TABORI'	, 'FK1' )
			oSubFK6:SetValue( 'FK6_TPDOC'	, 'CM' )
			oSubFK6:SetValue( 'FK6_VALCAL'	, nValAtu - nValOrig )	
			oSubFK6:SetValue( 'FK6_VALMOV'	, nValAtu - nValOrig )
			oSubFK6:SetValue( 'FK6_RECPAG'	, "P" )
			oSubFK6:SetValue( 'FK6_IDORIG'	, cIdFK1 )
			
			If SE1->E1_TIPO $ MVRECANT+"/"+MV_CRNEG
				oSubFK6:SetValue( 'FK6_HISTOR'	, OemToAnsi(STR0075) ) //CORREC.DE ADIANTAMENTO
			Else
				oSubFK6:SetValue( 'FK6_HISTOR'	, OemToAnsi(STR0076) ) //"Correcao Monet s/Receb.Titulo" 
			EndIf
			cCamposE5 += ",{'E5_VLCORRE'," + Str(nValAtu - nValOrig )+ " }"
		EndIf
	Else
		If cPaisLoc == "BRA" .And. SE1->E1_MOEDA > 1 .And. nValCm >0 .And. FunName() == "ZFINA330"
			If !oSubFK6:IsEmpty()
				oSubFK6:AddLine()
			EndIf
			oSubFK6:SetValue( 'FK6_GRVSE5'  , .F.)		
			oSubFK6:SetValue( 'FK6_IDFK6'	, GetSxEnum('FK6','FK6_IDFK6') )											
			oSubFK6:SetValue( 'FK6_TABORI'	, 'FK1' )
			oSubFK6:SetValue( 'FK6_TPDOC'	, 'CM' )
			oSubFK6:SetValue( 'FK6_VALCAL'	, Round(nValCm, nDecs1) )	
			oSubFK6:SetValue( 'FK6_VALMOV'	, Round(nValCm, nDecs1) )
			oSubFK6:SetValue( 'FK6_RECPAG'	, "P" )
			oSubFK6:SetValue( 'FK6_IDORIG'	, cIdFK1 )
			
			If SE1->E1_TIPO $ MVRECANT+"/"+MV_CRNEG
				oSubFK6:SetValue( 'FK6_HISTOR'	, OemToAnsi(STR0075) ) //CORREC.DE ADIANTAMENTO
			Else
				oSubFK6:SetValue( 'FK6_HISTOR'	, OemToAnsi(STR0076) ) //CORREC. MONET S/ RECEBTO
			EndIf
			cCamposE5 += ",{'E5_VLCORRE'," + Str(Round(nValCm, nDecs1)) + " }"
	   	ElseIf nCm <> 0
	   		If !oSubFK6:IsEmpty()
				oSubFK6:AddLine()
			EndIf
			oSubFK6:SetValue( 'FK6_GRVSE5'  , .T.)		
			oSubFK6:SetValue( 'FK6_IDFK6'	, GetSxEnum('FK6','FK6_IDFK6') )											
			oSubFK6:SetValue( 'FK6_TABORI'	, 'FK1' )
			oSubFK6:SetValue( 'FK6_TPDOC'	, 'CM' )
			oSubFK6:SetValue( 'FK6_VALCAL'	, Round(nCm, nDecs1) )	
			oSubFK6:SetValue( 'FK6_VALMOV'	, Round(nCm, nDecs1) )
			oSubFK6:SetValue( 'FK6_RECPAG'	, "P" )
			oSubFK6:SetValue( 'FK6_IDORIG'	, cIdFK1 )
			
			If SE1->E1_TIPO $ MVRECANT+"/"+MV_CRNEG
				oSubFK6:SetValue( 'FK6_HISTOR'	, OemToAnsi(STR0075) ) //CORREC.DE ADIANTAMENTO
			Else
				oSubFK6:SetValue( 'FK6_HISTOR'	, OemToAnsi(STR0076) ) //CORREC. MONET S/ RECEBTO
			EndIf
			cCamposE5 += ",{'E5_VLCORRE'," + Str(Round(nCm, nDecs1)) + " }"
		Endif
	EndIf

	If lCredito
		oSubFK1:SetValue( "FK1_HISTOR"	, OemToAnsi(STR0077)) //"Baixa por Compensacao"
		oSubFK1:SetValue( "FK1_TPDOC"	, "BA" )
	Else
		oSubFK1:SetValue( "FK1_HISTOR"	, OemToAnsi(If(lIsNcc,STR0078,STR0036)) ) //"Compensação Nota de Crédito"//"Compens. Adiantamento
		oSubFK1:SetValue( "FK1_TPDOC"	, "CP" )
	Endif

	If !lPccBxCr
		//Acerto valor dos impostos - Tecnofibras
		If lImpComp .and. lIsNcc .and. lPccBaixa
			nRecImp := IIF(lCredito,nRegCmp,nRecSE1)
			F330ActImp(nRecImp,nValorReal,@nValPis,@nValCof,.T.,lCredito,@nValCsl,nTotAbto)
			//Gravo Valores dos impostos no SE5 (ja locado)
			cCamposE5 += ",{'E5_VRETPIS' ,  "+cValToChar(nValPis)+"}"																		
			cCamposE5 += ",{'E5_VRETCOF' , "+cValToChar(nValCof)+"}"
			cCamposE5 += ",{'E5_VRETCSL' , "+cValToChar(nValCsl)+" }"
		Endif			
	Endif

	// alimenta o VRET do pcc na compensacao NCC mas nao gera o titulo, para
	//que este valor nao seja calculado na baixa do restante.
	If !lCredito .and. lIsNcc .and. lPccBaixa 
		cCamposE5 += ",{'E5_VRETPIS' , "+cValToChar(nPis)+"}"																		
		cCamposE5 += ",{'E5_VRETCOF' , "+cValToChar(nCofins)+"}"
		cCamposE5 += ",{'E5_VRETCSL' , "+cValToChar(nCsll)+"}"
		cCamposE5 += ",{'E5_PRETPIS' , '7' }"
		cCamposE5 += ",{'E5_PRETCOF' , '7' }"
		cCamposE5 += ",{'E5_PRETCSL' , '7' }"  
	EndiF		
	

	/*
	 * Grava fornecedor do titulo no movimento do PA, para ser utilizado no
	 * cancelamento da compensacao, quando se utiliza PA de outros fornecedores
	 * para compensar.
	 */
	cCamposE5 += ",{'E5_FORNADT' , '" + cCliAdt + "' } "
	cCamposE5 += ",{'E5_LOJAADT' , '" + cLojaAdt + "' } "

	If l330Mov1
		ExecBlock("SE5FI330",.f.,.f.)
	EndIf

	If cPaisLoc == "BRA"
		oSubFK1:SetValue( "FK1_TXMOED" , Fa330Tx2( nMoeda, nValorReal/Round(NoRound(xMoeda(nValor   ,nMoeda,SE1->E1_MOEDA,,3,Fa330Tx2(nMoeda,0),Fa330Tx2(SE1->E1_MOEDA,SE1->E1_TXMOEDA)),3),2) ) )
	ElseIf cPaisLoc == "MEX" .And.  Type("aTxMoedas")#"U"  .And. nMoeda > 1
		oSubFK1:SetValue( "FK1_TXMOED" , aTxMoedas[nMoeda][2] )
	Endif

	cCamposE5 += " } "
	oModelBxR:SetValue( "MASTER", "E5_CAMPOS", cCamposE5 )

	If oModelBxR:VldData()
		oModelBxR:CommitData()
		aAdd(aBaixas,{{"CMP",cSequencia,SE5->(Recno()),SE1->E1_TIPO,cAdiantamento}})
		oModelBxR:DeActivate()
	Else
		lRet := .F.
		cLog := cValToChar(oModelBxR:GetErrorMessage()[MODEL_MSGERR_IDFIELDERR]) + ' - '
		cLog += cValToChar(oModelBxR:GetErrorMessage()[MODEL_MSGERR_ID]) + ' - '
		cLog += cValToChar(oModelBxR:GetErrorMessage()[MODEL_MSGERR_MESSAGE])         	
		Help( ,,"FA330MOV01",,cLog, 1, 0 )   
	EndIf

	//Carregando dados bancarios caso seja necessario gravar o registro da diferenca cambial.
	cBcoSE5	:=	SE5->E5_BANCO
	cAgSE5	:=	SE5->E5_AGENCIA
	cCtSE5	:=	SE5->E5_CONTA
	cLoteSE5	:=	SE5->E5_LOTE
	

	//Verifica se o titulo já possui impostos gerados pela rotina de Borderô de Recebimento de Imposto (FINA061).
	nPisFina061	:=	0
	nCofFina061	:=	0
	nCslFina061	:=	0
	nIrfFina061	:=	0
	nRegSE5	:=	SE5->(Recno())
	nOrdSE5	:=	SE5->(IndexOrd())		
	If SE1->E1_TIPO <> MVRECANT .AND. SE1->E1_TIPO <> MV_CRNEG .And. (lPccBxCr .Or. lIrPjBxCr) 
		dbSelectArea("SE5")
		SE5->(dbSetOrder(2)) //FILIAL + TIPODOC + PREFIXO + NUMERO + PARCELA + TIPO
		If SE5->(DBSeek(xFilial("SE5")+"BA"+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO))
			While !SE5->(Eof()) .and. SE5->E5_FILIAL==xFilial("SE5") .And. ;
				SE5->E5_TIPODOC+SE5->E5_PREFIXO+SE5->E5_NUMERO+SE5->E5_PARCELA+SE5->E5_TIPO=="BA"+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO		
			
				If ("FINA061" $ Subst(SE5->E5_HISTOR,1,7)) .And. SE5->E5_MOTBX $ "PCC_IRF"						
					If Alltrim(SE5->E5_MOTBX) == "PCC"
					   nPisFina061	+= SE5->E5_VRETPIS
					   nCofFina061	+=	SE5->E5_VRETCOF
					   nCslFina061	+= SE5->E5_VRETCSL
					ElseIf Alltrim(SE5->E5_MOTBX) == "IRF"
					   nIrfFina061	+= SE5->E5_VRETIRF
					Endif
				Endif					
				SE5->(DbSkip())		
		   Enddo
		Endif
	Endif
   SE5->(Dbgoto(nRegSE5))
	SE5->(Dbsetorder(nOrdSE5))	
	If cPaisLoc == "BRA" .and. lIrPjBxCr .and. !lCredito .And. !lNcc .And. nIrfFina061 == 0	 .And. !lRaRtImp
		FGrvIrRec(@nIrrf,nRecSe1,.F.,cSequencia,"FINA070",SE1->E1_MOEDA)
		SE1->(dbGoTo(nRecSe1))
		FGSFQIRCR(nIrrf,nIRFBase,cSequencia)
	Endif

	/*
	 * PCC Baixa CR
	 * Grava relacionamento no SFQ
	 * Grava titulos PIS/COF/CSL no SE1
	 */
	SE5->(Dbgoto(nRegSE5))
	If cPaisLoc == "BRA" .and. lPccBxCr .and. !lCredito .and. !lNcc
		F330GrvSFQ(cSequencia,nRecSe1)
	Endif

	/*
	 * PONTO DE ENTRADA NA ALTERACAO DO HISTORICO NA SE5 NA INCLUSAO
	 */
	If ExistBlock( "F330AE5I" )
	   ExecBlock("F330AE5I",.F.,.F.)
	EndIf

	// Grava valor da correcao no titulo, para contabilizacao
	RecLock("SE1")
  	If cPaisLoc == "BRA" .And. SE1->E1_MOEDA > 1 .And. nValCm<>0 .And. FUNNAME() $ "ZFINA330#FINA740"
		SE1->E1_CORREC := Round(nValCm, nDecs1)
	Else
		SE1->E1_CORREC := Round(nCm, nDecs1)
	Endif
	SE1->(MsUnlock())
	
			

	// Atualizar saldo do cliente
	aArea		:= GetArea()
	nVlReal	:= nValorReal - nTitAcres + nTitDecre
	
	dbSelectArea("SA1")
	SA1->(DbSetOrder(1))
	If dbSeek(xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA)
		RecLock("SA1")
		If lCredito
			AtuSalDup("+",nVlReal,1,SE1->E1_TIPO,,SE1->E1_EMISSAO)
		Else
			AtuSalDup("-",nVlReal,1,SE1->E1_TIPO,,SE1->E1_EMISSAO)
	 	EndIf
		SA1->(MsUnlock())
	EndIf
	RestArea(aArea)

	/*
	 * Baixa a Compensacao
	 */
	If ( !Empty(cAdiantamento) )
		dbSelectArea("SE1")
		SE1->(dbSetOrder(1))
		SE1->(dbGoto(nRegCmp))
		oModelBxR 	:= FWLoadModel("FINM010") 
		oModelBxR:SetOperation( MODEL_OPERATION_INSERT ) //Inclusao
		oModelBxR:Activate()		
		oModelBxR:SetValue( "MASTER", "E5_GRV", .T. ) //Informa se vai gravar SE5 ou não
		oModelBxR:SetValue( "MASTER", "NOVOPROC", .T. ) //Informa que a inclusão será feita com um novo número de processo	
		/*
		 * Dados da baixa a receber
		 */
		oSubFK1 := oModelBxR:GetModel( "FK1DETAIL" )
		oSubFKA := oModelBxR:GetModel( "FKADETAIL" )
		oSubFK6 := oModelBxR:GetModel( "FK6DETAIL" )
		
		//Define os campos que não existem nas FKs e que serão gravados apenas na E5, para que a gravação da E5 continue igual
		
		cCamposE5 := " { "
		cCamposE5 += "{'E5_FILIAL'		,'" + cFilSE5 + "'}"
		cCamposE5 += ",{'E5_PREFIXO'	,'" +  SE1->E1_PREFIXO+ "'}"
		cCamposE5 += ",{'E5_NUMERO'		,'" +  SE1->E1_NUM + "'}"
		cCamposE5 += ",{'E5_PARCELA'	,'" +  SE1->E1_PARCELA + "'}"
		cCamposE5 += ",{'E5_CLIENTE'	,'" +  SE1->E1_CLIENTE + "'}"
		cCamposE5 += ",{'E5_CLIFOR'		,'" +  SE1->E1_CLIENTE + "'}"
		cCamposE5 += ",{'E5_LOJA'		,'" +  SE1->E1_LOJA + "'}"
		cCamposE5 += ",{'E5_BENEF'		,'" +  StrTran(SE1->E1_NOMCLI,"'","")+ "'}"
		cCamposE5 += ",{'E5_TIPO'		,'" +  SE1->E1_TIPO + "'}"
		cCamposE5 += ",{'E5_DTDIGIT'	, STOD('" + DTOS(dDataBase) + "')}"
		cCamposE5 += ",{'E5_DTDISPO'	, STOD('" + DTOS(dBaixa) + "')}"
		
		cChaveTit	:= 	xFilial("SE1")	+ "|" +;
						SE1->E1_PREFIXO	+ "|" +;
						SE1->E1_NUM		+ "|" +;
						SE1->E1_PARCELA	+ "|" +;
						SE1->E1_TIPO		+ "|" +;
						SE1->E1_CLIENTE	+ "|" +;
						SE1->E1_LOJA
						
		cChaveFK7	:= FINGRVFK7("SE1", cChaveTit)
		
		cIdFK1		:= FWUUIDV4()
		
		If !oSubFKA:IsEmpty()
			oSubFKA:AddLine()
		EndIf
	
		oSubFKA:SetValue( "FKA_IDORIG"	, cIdFK1 )
		oSubFKA:SetValue( "FKA_TABORI"	, 'FK1')

		If !oSubFK1:IsEmpty()
			oSubFK1:AddLine()
		EndIf
	
		oSubFK1:SetValue( "FK1_DATA"	, dBaixa )		
		oSubFK1:SetValue( "FK1_NATURE"	, SE1->E1_NATUREZ )
		oSubFK1:SetValue( "FK1_RECPAG"	, "R" )
		oSubFK1:SetValue( "FK1_HISTOR"	, cHistMov )
		oSubFK1:SetValue( "FK1_MOTBX"	, "CMP")
		oSubFK1:SetValue( "FK1_ORIGEM"	, FunName() )
		oSubFK1:SetValue( "FK1_SEQ"		, cSequencia )
		oSubFK1:SetValue( "FK1_DOC"		, cDocOriginal )
		oSubFK1:SetValue( "FK1_IDDOC"	, cChaveFK7 )
		oSubFK1:SetValue( "FK1_TPDOC"	, cTpDoc )	
		oSubFK1:SetValue( "FK1_CCUSTO"	, SE1->E1_CCUSTO )	
		oSubFK1:SetValue( "FK1_FILORI"	, SE1->E1_FILORIG )
		oSubFK1:SetValue( "FK1_VALOR"	, nValorReal )
		oSubFK1:SetValue( "FK1_VLMOE2"	, Round(NoRound(xMoeda(nValor   ,nMoeda,SE1->E1_MOEDA,,3,Fa330Tx2(nMoeda,nTxMoeda),Fa330Tx2(SE1->E1_MOEDA,SE1->E1_TXMOEDA)),3),2) )
		oSubFK1:SetValue( "FK1_SITCOB"	, SE1->E1_SITUACA )
		oSubFK1:SetValue( "FK1_MOEDA"   , StrZero(nMoeda,2) )
		oSubFK1:SetValue( "FK1_LA"		, IIF(lPadrao .and. nContab == 1,"S","N") )
				
		If lCredito
			oSubFK1:SetValue( "FK1_HISTOR"	, OemToAnsi(STR0077) ) //"Baixa por Compensacao"
			oSubFK1:SetValue( "FK1_TPDOC"	, "CP" )
		Else
			oSubFK1:SetValue( "FK1_HISTOR"	, OemToAnsi(STR0036) ) //"Compens. Adiantamento"
			oSubFK1:SetValue( "FK1_TPDOC"	, "BA" )
		Endif
		
		oSubFK1:SetValue( "FK1_LOTE"  , cLote )
		/*
		 * Ponto de Entrada para permitir a manipulação da filial no movimento bancario
		 */
		If ! lMultFil
			cCamposE5 += ",{'E5_FILIAL'		,'" + xFilial("SE5") + "' } "
		Else
			cCamposE5 += ",{'E5_FILIAL'		,'" + ExecBlock("SE5MTFIL",.F.,.F.,cFilAnt)+"' } "
		Endif
	
		cCamposE5 += ",{'E5_LA'		,'" +  IIF(lPadrao .and. nContab == 1,"S","N") + "'}"

		If !lPccBxCr
			//Acerto valor dos impostos - Tecnofibras
			If lImpComp .and. lIsNcc .and. lPccBaixa
				//Gravo Valores dos impostos no SE5 (ja locado)
				cCamposE5 += ",{'E5_VRETPIS' , "+cValToChar(nValPis)+"}"																		
				cCamposE5 += ",{'E5_VRETCOF' , "+cValToChar(nValCof)+"}"
				cCamposE5 += ",{'E5_VRETCSL' , "+cValToChar(nValCsl)+"}"  
			EndIf
		EndIf

		// alimenta o VRET do pcc na compensacao NCC mas nao gera o titulo, para
		//que este valor nao seja calculado na baixa do restante.
		If lCredito .and. lIsNcc .and. lPccBaixa
				cCamposE5 += ",{'E5_VRETPIS' , "+cValToChar(nPis)+"}"																		
				cCamposE5 += ",{'E5_VRETCOF' , "+cValToChar(nCofins)+"}"
				cCamposE5 += ",{'E5_VRETCSL' , "+cValToChar(nCsll)+"}"
				cCamposE5 += ",{'E5_PRETPIS' , '7' }"
				cCamposE5 += ",{'E5_PRETCOF' , '7' }"
				cCamposE5 += ",{'E5_PRETCSL' , '7' }"  
		EndiF			
		If nAcresc <> 0
			If !oSubFK6:IsEmpty()
				oSubFK6:AddLine()
			EndIf
			oSubFK6:SetValue( 'FK6_GRVSE5'  , .F.)		
			oSubFK6:SetValue( 'FK6_IDFK6'	, GetSxEnum('FK6','FK6_IDFK6') )											
			oSubFK6:SetValue( 'FK6_TABORI'	, 'FK1' )
			oSubFK6:SetValue( 'FK6_TPDOC'	, 'JR' )
			oSubFK6:SetValue( 'FK6_VALCAL'	, Round(NoRound(xMoeda(nAcresc,nMoeda,1,,3,Fa330Tx2(nMoeda,0)),3),2) )	
			oSubFK6:SetValue( 'FK6_VALMOV'	, Round(NoRound(xMoeda(nAcresc,nMoeda,1,,3,Fa330Tx2(nMoeda,0)),3),2) )
			oSubFK6:SetValue( 'FK6_RECPAG'	, "R" )
			oSubFK6:SetValue( 'FK6_IDORIG'	, cIdFK1 )
			oSubFK6:SetValue( 'FK6_HISTOR'	, OemToAnsi(STR0049) ) //ACRESCIMO

			
			cCamposE5 += ",{'E5_VLJUROS'," + Str(Round(NoRound(xMoeda(nAcresc,nMoeda,1,,3,Fa330Tx2(nMoeda,0)),3),2)) + " }"	
		EndIf
		
		If nDecres+nDescD <> 0
			If !oSubFK6:IsEmpty()
				oSubFK6:AddLine()
			EndIf
			oSubFK6:SetValue( 'FK6_GRVSE5'  , .F.)		
			oSubFK6:SetValue( 'FK6_IDFK6'	, GetSxEnum('FK6','FK6_IDFK6') )											
			oSubFK6:SetValue( 'FK6_TABORI'	, 'FK1' )
			oSubFK6:SetValue( 'FK6_TPDOC'	, 'DC' )
			oSubFK6:SetValue( 'FK6_VALCAL'	, Round(NoRound(xMoeda(nDecres+nDescD,nMoeda,1,,3,Fa330Tx2(nMoeda,0)),3),2) )	
			oSubFK6:SetValue( 'FK6_VALMOV'	, Round(NoRound(xMoeda(nDecres+nDescD,nMoeda,1,,3,Fa330Tx2(nMoeda,0)),3),2) )
			oSubFK6:SetValue( 'FK6_RECPAG'	, "R" )
			oSubFK6:SetValue( 'FK6_IDORIG'	, cIdFK1 )
			oSubFK6:SetValue( 'FK6_HISTOR'	, OemToAnsi(STR0050) ) //DECRESCIMO
			oSubFK6:SetValue( 'FK6_TPDESC'	, Iif(SE1->E1_TPDESC == 'C', '1', '2') )
		
			cCamposE5 += ",{'E5_VLDESCO'," + Str(Round(NoRound(xMoeda(nDecres+nDescD,nMoeda,1,,3,Fa330Tx2(nMoeda,0)),3),2)) + " }"
			cCamposE5 += ",{'E5_VLDECRE'," + Str(Round(NoRound(xMoeda(nDecres		  ,nMoeda,1,,3,Fa330Tx2(nMoeda,0)),3),2)) + " }"				
		EndIf
					
		nValEstrang := Round(NoRound(xMoeda(nValor   ,nMoeda,SE1->E1_MOEDA,,3,Fa330Tx2(nMoeda,0),Fa330Tx2(SE1->E1_MOEDA,SE1->E1_TXMOEDA)),3),2) 
		FA070CORR( nValor-nAcresc+nDecres ,Fa330Tx2(SE1->E1_MOEDA,SE1->E1_TXMOEDA))

		// Grava o valor de correção monetária no SE5 para ser visualizado na consulta
		If Val(SE5->E5_MOEDA) <> 1 .And. FUNNAME() $ "ZFINA330#FINA740"
			If nCm <> 0
				If !oSubFK6:IsEmpty()
					oSubFK6:AddLine()
				EndIf
				oSubFK6:SetValue( 'FK6_GRVSE5'  , .T.)		
				oSubFK6:SetValue( 'FK6_IDFK6'	, GetSxEnum('FK6','FK6_IDFK6') )											
				oSubFK6:SetValue( 'FK6_TABORI'	, 'FK1' )
				oSubFK6:SetValue( 'FK6_TPDOC'	, 'CM' )
				oSubFK6:SetValue( 'FK6_VALCAL'	, nCm)	
				oSubFK6:SetValue( 'FK6_VALMOV'	, nCm )
				oSubFK6:SetValue( 'FK6_RECPAG'	, "R" )
				oSubFK6:SetValue( 'FK6_IDORIG'	, cIdFK1 )
				
				If SE1->E1_TIPO $ MVRECANT+"/"+MV_CRNEG
					oSubFK6:SetValue( 'FK6_HISTOR'	, OemToAnsi(STR0075) ) //CORREC.DE ADIANTAMENTO
				Else
					oSubFK6:SetValue( 'FK6_HISTOR'	, OemToAnsi(STR0076) ) //CORREC. MONET S/ RECEBTO
				EndIf
				cCamposE5 += ",{'E5_VLCORRE'," + Str(nCm) + " }"	
			EndIf
		EndIf
		
		
		// Grava fornecedor do titulo no movimento do PA, para ser utilizado no
		// cancelamento da compensacao, quando se utiliza PA de outros fornecedores
		// para compensar.
		cCamposE5 += ",{'E5_FORNADT' , '" + cCliAdt + "' } "
		cCamposE5 += ",{'E5_LOJAADT' , '" + cLojaAdt + "' } "

		If l330Mov2
			ExecBlock("SE5FI331",.f.,.f.)
		Endif
		
		If cPaisLoc == "BRA"
			oSubFK1:SetValue( "FK1_TXMOED" , Fa330Tx2( nMoeda, nValorReal/Round(NoRound(xMoeda(nValor   ,nMoeda,SE1->E1_MOEDA,,3,Fa330Tx2(nMoeda,0),Fa330Tx2(SE1->E1_MOEDA,SE1->E1_TXMOEDA)),3),2) ) )
		ElseIf cPaisLoc == "MEX" .And.  Type("aTxMoedas")#"U"  .And. nMoeda > 1
			oSubFK1:SetValue( "FK1_TXMOED" , aTxMoedas[nMoeda][2] )
		EndIf
		
		cCamposE5 += " } "
	
		oModelBxR:SetValue( "MASTER", "E5_CAMPOS", cCamposE5 )
		If oModelBxR:VldData()
			oModelBxR:CommitData()
			aAdd(aBaixas,{{"CMP",cSequencia,SE5->(Recno()),SE1->E1_TIPO,cAdiantamento}})
			oModelBxR:DeActivate()
		Else
			lRet := .F.
			cLog := cValToChar(oModelBxR:GetErrorMessage()[MODEL_MSGERR_IDFIELDERR]) + ' - '
			cLog += cValToChar(oModelBxR:GetErrorMessage()[MODEL_MSGERR_ID]) + ' - '
			cLog += cValToChar(oModelBxR:GetErrorMessage()[MODEL_MSGERR_MESSAGE])         	
			Help( ,,"FA330MOV02",,cLog, 1, 0 )   
		EndIf
		
		nTxMoed1	:=	nTxMoed2	:=	nValEmis	:=	nValBax	:=	nValCm:=	0

		//Carregando dados bancarios caso seja necessario gravar o registro da diferenca cambial.
		cBcoSE5		:=	SE5->E5_BANCO
		cAgSE5		:=	SE5->E5_AGENCIA
		cCtSE5		:=	SE5->E5_CONTA
		cLoteSE5	:=	SE5->E5_LOTE

		//Verifica se o titulo já possui impostos gerados pela rotina de Borderô de Recebimento de Imposto (FINA061).
		nPisFina061	:=	0
		nCofFina061	:=	0
		nCslFina061	:=	0
		nIrfFina061	:=	0
		nRegSE5	:=	SE5->(Recno())
		nOrdSE5	:=	SE5->(IndexOrd())		
		If SE1->E1_TIPO <> MVRECANT .AND. SE1->E1_TIPO <> MV_CRNEG .And. lPccBxCr .And. lIrPjBxCr                                                                                               			
			dbSelectArea("SE5")
			SE5->(dbSetOrder(2)) //FILIAL + TIPODOC + PREFIXO + NUMERO + PARCELA + TIPO
			If SE5->(DBSeek(xFilial("SE5")+"BA"+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO))
				While !SE5->(Eof()) .and. SE5->E5_FILIAL==xFilial("SE5") .And. ;
					SE5->E5_TIPODOC+SE5->E5_PREFIXO+SE5->E5_NUMERO+SE5->E5_PARCELA+SE5->E5_TIPO=="BA"+SE1->E1_PREFIXO+SE1->E1_NUM+SE1->E1_PARCELA+SE1->E1_TIPO		
				
					If ("FINA061" $ Subst(SE5->E5_HISTOR,1,7)) .And. SE5->E5_MOTBX $ "PCC_IRF"						
						If Alltrim(SE5->E5_MOTBX) == "PCC"
						   nPisFina061	+= SE5->E5_VRETPIS
						   nCofFina061	+=	SE5->E5_VRETCOF
						   nCslFina061	+= SE5->E5_VRETCSL
						ElseIf Alltrim(SE5->E5_MOTBX) == "IRF"
						   nIrfFina061	+= SE5->E5_VRETIRF
						Endif
					Endif					
					SE5->(DbSkip())		
					
			   Enddo
			Endif
		Endif
	   SE5->(Dbgoto(nRegSE5))
		SE5->(Dbsetorder(nOrdSE5))				
		
		If lIrPjBxCr .And. lCredito .And. !lRaRtImp .and. !lNcc .And. nIrfFina061 == 0 	
			FGrvIrRec(@nIrrf,nRegCmp,.F.,cSequencia,"FINA070",SE1->E1_MOEDA)
			FGSFQIRCR(nIrrf,nIRFBase,cSequencia)
		EndIf

		aAreaSE5 := SE5->(GetArea()) //para efeito de acerto no posicio. da SE5 na contabil.
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Gravando diferenca cambial			                                     ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		
		
		aBaixaSE5 := FIM010RSE5()
		
		RestArea(aAreaSE5)

		/////////////////////
		// PCC Baixa CR
		// Grava relacionamento no SFQ
		// Grava titulos PIS/COF/CSL no SE1
		If cPaisLoc == "BRA" .and. (lPccBxCr .or. lIrPjBxCr) .and. lCredito .and. !lNcc
			F330GrvSFQ(cSequencia,nRegCmp)
		Endif

		// Grava valor da correcao no titulo, para contabilizacao
		SE1->(RecLock("SE1"))
		If cPaisLoc == "BRA" .And. SE1->E1_MOEDA > 1 .And. nValCm <>0 .And. FUNNAME() $ "ZFINA330#FINA740"
			SE1->E1_CORREC := Round(nValCm, nDecs1)
		Else
			SE1->E1_CORREC := nCm
		Endif
		SE1->(MsUnlock())
		
		// Atualizar saldo do cliente
		nVlReal	:= nValorReal - nAcresc + nDecres
		aArea		:= GetArea()
		dbSelectArea("SA1")
		SA1->(DbSetOrder(1))
		If SA1->(dbSeek(xFilial("SA1")+SE1->E1_CLIENTE+SE1->E1_LOJA))
			SA1->(RecLock("SA1"))
			If lCredito
				AtuSalDup("-",nVlReal,1,SE1->E1_TIPO,,SE1->E1_EMISSAO)
			Else
				AtuSalDup("+",nVlReal,1,SE1->E1_TIPO,,SE1->E1_EMISSAO)
			EndIf
			SA1->(MsUnlock())
		EndIf
		RestArea(aArea)
	Endif
EndIf
dbSelectArea(cAlias)
Return .T.


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³F330ActImp  ³ Autor ³Mauricio Pequim Jr.. ³ Data ³ 11.11.05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Acerta valores dos impostos na compensacao CR com NCC.     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ FINA330                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Static Function F330ActImp(nRecSE1,nValorReal,nValPis,nValCof,lBaixa,lCredito,nValCsl,nTotAbto)

Local nProporcao := 0
Local cKeySe1 := ""
Local aArea  := GetArea()
Local nTotAbt := 0
Local nTotAbImp := 0
Local nSe5Rec := 0   

//Controle de abatimento
Local lTitpaiSE1 := .T.
Local nOrdTitPai:=0
Local cTitPai	:=""
Local bWhile:= {||!EOF() .And.MsSeek(xFilial("SE1")+cKeySE1)}  

Default nValPis := 0
Default nValCof := 0
Default nValCsl := 0
Default lBaixa  := .T.

If Select("__SE1") == 0
	SumAbatRec("","","",1,"")
Endif

DbSelectArea("__SE1")
dbSetOrder(2)
dbGoto(nRecSe1)  //posiciono no titulo pai no SE1

//Verifico valor dos abatimentos antes de proporcionalizar
nTotAbImp := 0
nTotAbt  := SumAbatRec(__SE1->E1_PREFIXO,__SE1->E1_NUM,__SE1->E1_PARCELA,__SE1->E1_MOEDA,"V",dDataBase,@nTotAbImp) 
nTotAbt	 -= nTotAbImp 	

DbSelectArea("__SE1")
dbSetOrder(2)
dbGoto(nRecSe1)  //posiciono no titulo pai no SE1

nSe5Rec := SE5->( RECNO() )

aValor:=Baixas(__SE1->E1_NATUREZ,__SE1->E1_PREFIXO,__SE1->E1_NUM,__SE1->E1_PARCELA,__SE1->E1_TIPO,__SE1->E1_MOEDA,"R",__SE1->E1_CLIENTE,dDataBase,__SE1->E1_LOJA)

SE5->( dbGoto(nSE5Rec) )

nProporcao := nValorReal / (__SE1->E1_SALDO-nTotAbt+aValor[5] )

cKeySE1 := __SE1->(E1_CLIENTE+E1_LOJA+E1_PREFIXO+E1_NUM+E1_PARCELA)	  
cTitPai	:= __SE1->(E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_CLIENTE+E1_LOJA)	 

If lBaixa
	//Se for a baixa que zera o saldo, a proporcao do imposto deverá ser igual a 1 para que seja
	//feita a compensacao correta
	If __SE1->E1_SALDO == 0
		nProporcao := 1
		nValPis := __SE1->E1_PIS
		nValCof := __SE1->E1_COFINS
		nValCsl := __SE1->E1_CSLL
	Else
		nValPis := ((__SE1->E1_PIS+aValor[14]) * nProporcao)
		nValCof := ((__SE1->E1_COFINS+aValor[15]) * nProporcao)
		nValCsl := ((__SE1->E1_CSLL+aValor[18]) * nProporcao)
	Endif
Else
	nValPis := se5->e5_vretpis
	nValCof := se5->e5_vretcof
	nValCsl := se5->e5_vretcsl
Endif

If nValPis+nValCof+nValCsl > 0
	//Acerto o valor dos impostos no titulo principal
	RecLock("__SE1")
	If lBaixa
		__SE1->E1_PIS -= nValPis
		__SE1->E1_COFINS -= nValCof
		__SE1->E1_CSLL -= nValCsl
	Else
		__SE1->E1_PIS += nValPis
		__SE1->E1_COFINS += nValCof
		__SE1->E1_CSLL += nValCsl
	Endif
	MsUnLock()
	
	//Acerto os valores dos titulos de impostos
	If lTitpaiSE1
 		 If (nOrdTitPai:= OrdTitpai()) > 0
			DbSetOrder(nOrdTitPai)
			If	DbSeek(xFilial("SE1")+cTitPai)    
			  	bWhile  := {|| !Eof() .And. Alltrim(__SE1->E1_TITPAI) == Alltrim(cTitPai)}   
			Else
				 	__SE1->(dbSetOrder(2))    
			Endif
		Endif
	Endif
	
	While Eval(bWhile)
	
	//Pis    
		If __SE1->E1_TIPO $ MVPIABT
			If lBaixa
				RecLock("__SE1")
				__SE1->E1_VALOR -= nValPis
				__SE1->E1_SALDO := __SE1->E1_VALOR
				__SE1->E1_VLCRUZ := __SE1->E1_VALOR
				MsUnlock()
			Else
				RecLock("__SE1")
				__SE1->E1_VALOR += nValPis
				__SE1->E1_SALDO := __SE1->E1_VALOR
				__SE1->E1_VLCRUZ := __SE1->E1_VALOR
				MsUnlock()
			Endif
		Endif
	
		//Cofins 
		
		If __SE1->E1_TIPO $ MVCFABT
			If lBaixa
				RecLock("__SE1")
				__SE1->E1_VALOR -= nValCof
				__SE1->E1_SALDO := __SE1->E1_VALOR
				__SE1->E1_VLCRUZ := __SE1->E1_VALOR
				MsUnlock()
			Else
				RecLock("__SE1")
				__SE1->E1_VALOR += nValCof
				__SE1->E1_SALDO := __SE1->E1_VALOR
				__SE1->E1_VLCRUZ := __SE1->E1_VALOR
				MsUnlock()
			Endif
		Endif
		
		//CSLL
		If __SE1->E1_TIPO $ MVCSABT
			If lBaixa
				RecLock("__SE1")
				__SE1->E1_VALOR -= nValCsl
				__SE1->E1_SALDO := __SE1->E1_VALOR
				__SE1->E1_VLCRUZ := __SE1->E1_VALOR
				MsUnlock()
			Else
				RecLock("__SE1")
				__SE1->E1_VALOR += nValCsl
				__SE1->E1_SALDO := __SE1->E1_VALOR
				__SE1->E1_VLCRUZ := __SE1->E1_VALOR
				MsUnlock()
			Endif
		Endif  
		__SE1->( DbSkip() )
	Enddo
EndIf

RestArea(aArea)

Return .T.