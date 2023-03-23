#Include "protheus.ch"
#Include "rwmake.ch"
#Include "topconn.ch"
#Include "tbiconn.ch"

#Define AL_LEFT     0  //Alinha Texto a Esquerda(padrão)
#Define AL_RIGHT    1  //Alinha Texto a Direita
#Define AL_CENTER   2  //Alinha Texto no Centro
#Define MARGIN      0  //Margem da area de sangria da pagina.
#DEFINE LINE_HEIGHT	50 //Altura da Linha

#Define c_eol CHR(13) + CHR(10)


/*/
*****************************************************************************
* Programas Contidos neste Fonte                                            *
*****************************************************************************
* User Functions                                                            *
*---------------------------------------------------------------------------*
* u_OrtR021()                                                                 *
*---------------------------------------------------------------------------*
* Static Functions                                                          *
*---------------------------------------------------------------------------*
* RunReport()    | ValidPerg()    | ImpRodap()     |                        *
*****************************************************************************
* Tabelas Utilizadas (SC5, SC6)                                            *
*****************************************************************************
* Parametros:                                                               *
*****************************************************************************

*****************************************************************************
*+-------------------------------------------------------------------------+*
*|Funcao      | OrtR021  | Autor |  Cesar Dupim                            |*
*+------------+------------------------------------------------------------+*
*|Data        | 15.03.2006                                                 |*
*+------------+------------------------------------------------------------+*
*|Descricao   | Romaneio de Cargas Interno                                 |*
*|            |                                                            |*
*+-------------------------------------------------------------------------+*
*|Alterado por|					         | Data |			               |*
*+-------------------------------------------------------------------------+*
*|Descricao   |									                           |*
*+-------------------------------------------------------------------------+*
*****************************************************************************
*+-------------------------------------------------------------------------+*
*|Alterado por|Luciana Rosa                                                |*
*|Data        |24/01/2021												   |*
*+-------------------------------------------------------------------------+*
*|Motivo 	  |SSI N.: 118885                          					   |*
*|       	  |Incluir: ADICIONAR NA DESCRIÇÃO DOS PRODUTOS QUANDO 		   |*
*|       	  |SOB-MEDIDA A ABREVIAÇÃO SM E DEIXAR OS RESPECTIVOS PRODUTOS |*
*|            |NEGRITO NO RELATÓRIO DA PROGRAMAÇÃO DIÁRIA                  |*
*+-------------------------------------------------------------------------+*
*****************************************************************************

/*/
User Function ORTR021()  

	Private aAliasTmp	:= Array(0)

	//Chama a funcao para impressao do Relatorio
	ORTR021()

	//Fecha as Areas de Trabalho Temporaria
	aEval( aAliasTmp , { |cAlias| IF( ( Select( cAlias ) > 0 ) , (cAlias)->( dbCloseArea() ) , NIL ) } )

Return( NIL )

*-----------------------*
Static Function ORTR021()
*-----------------------*
Local cPict			:= ""
Local imprime		:= .T.
Local aOrd 			:= {"Codigo(Carga+Produto)","Segmento(Carga+Segmento)","Rota(Carga+Rota)"}
Local oTRSection

Private titulo 		:= "ROMANEIO DE CARGAS INTERNO"
Private _aEmbComp	:= {}
Private	__lPid 		:= .F.
Private __lNPid 	:= .F.
Private cDesc1 		:= "USUARIO              : ENCARREGADO DE ACERTO, SEPARADORES E EXPEDIDORES. "
Private cDesc2 		:= "OBJETIVO             : ACOMPANHAR O CARREGAMENTO DOS PRODUTOS VERIFICANDO SE NÃO HOUVE FALTA. "
Private cDesc3 		:= "PERIODO DE UTILIZACAO: DIÁRIO.                                    "
Private limite 		:= 132
Private tamanho 	:= "G"
Private nomeprog 	:= FunName()
Private nTipo 		:= 15
Private aReturn 	:= {"Zebrado", 1, "Administracao", 2, 2, 1, "", 1}
Private nLastKey 	:= 0
Private cPerg 		:= NomeProg
Private cString 	:= "SC5"
Private cEmb 		:=""
Private nC6_PRUNIT	:=0
Private cPID 		:=""
Private nTotEsp 	:=0
Private nTotPec 	:=0
Private nTotPes 	:=0
Private _cEmbNPid1 	:= _cEmbNPid2	:=	" "
Private cCodPro 	:= ""
Private cDescri 	:= ""
Private cMedida 	:= ""
Private cSobMed 	:= " "
Private nQtdVen 	:= 0
Private nChanfr 	:= 0
Private cPerson 	:= ""
Private lFim		:= .f.
/* SSI 108141 */
Private nPctCarg1	:= 0
Private nPctCarg2	:= 0 
Private nCapCarg	:= 0
/* SSI 108141 */
Private oPrn
Private nPag 		:= 1
Private nMaxV 		:= 0
Private nMaxH 		:= 0
Private nLin 		:= 0
Private oFont 		:= TFont():New("Courier New",, 12,, .F.)
Private oFontn		:= TFont():New("Courier New",, 11,, .T.) //LLR
Private oFont2		:= TFont():New("Courier New",, 11,, .F.)
Private oFontDet	:= TFont():New("Courier New",, 09,, .F.)
Private cNomFil 	:= ""
Private cCGC2PG 	:= "" // ssi 5711

dbSelectArea("SM0")
dbSeek(cEmpAnt+cFilAnt)
cNomFil := SM0->M0_FILIAL

ValidPerg(cPerg,.T.)

SC6->( DbOrderNickName("PSC61") )

If nLastKey == 27
	Return
EndIf

nTipo := IIf(aReturn[4] == 1, 15, 18)

oPrn 		:= TReport():New( NomeProg , Titulo , /*cPerg*/ , { || RunReport() } , NomeProg )
oPrn:nOrder	:= mv_par06

//Para Carregas as Ordens faz-se necessaria uma TRSection
oTRSection			:= TRSection():New( @oPrn , @Titulo , @cString , @aOrd )
oTRSection:SetOrder(oPrn:nOrder)
oPrn:HideHeader()
oPrn:HideFooter()
oPrn:SetEdit(.F.)		  //Desabilta o Botao Personalizar
oPrn:NoUserFilter()		  //Nao Permite Filtro de Usuario
oPrn:PrintDialog()		  //Mostra Tela para Configuração do Relatório

oPrn	:= FreeObj( oPrn )

Return

/*/
*******************************************************************************
* Funcao : RUNREPORT   * Autor : Cesar Dupim             * Data : 15/03/2006  *
*******************************************************************************
* Descricao : Funcao auxiliar chamada pela RPTSTATUS. A funcao RPTSTASUS      *
*             monta a janela com a regua de processamento do relatorio.       *
*******************************************************************************
* Uso       : OrtR021                                                         *
*******************************************************************************
/*/
Static Function RunReport()

Local aEstru 		 := {}

Local cQuery 		 := ""
Local cHEmissao 	 := ""
Local cA1CGC
Local cCidade
Local cGRPCGC
Local cCGCDesc
Local cCGCRDesc
Local cGRPCGCDesc
Local cLine

Local nTotal		
Local nOrder		 := oPrn:aSection[1]:GetOrder()
//Local nA1OrdCGC		 := RetOrder("SA1","A1_FILIAL+A1_CGC")
Local nGRPCGC		 := 0
Local nQtdCGC		 := 0
Local nVlrCGC		 := 0
Local nTotCGC		 := 0
Local nQtdGRPCGC	 := 0
Local nVlrGRPCGC	 := 0
Local nTotGRPCGC	 := 0
                     
Local lPrnVal		 := ( MV_PAR04 == 2 )
Local lQuebraCGC	 := ( MV_PAR07 == 2 )

Private nA1OrdCGC	 := RetOrder("SA1","A1_FILIAL+A1_CGC")
Private cSpace001	 := Space(001)
Private cSpace006	 := Space(006)
Private cSpace009	 := Space(009)
Private cSpace012	 := Space(012)
Private cSpace013	 := Space(013)
Private cSpace014	 := Space(014)
Private cSpace017	 := Space(017)
Private cSpace020	 := Space(020)
Private cSpace030	 := Space(030)
Private cSpace031	 := Space(040)
Private cSpace035	 := Space(074)
Private cSpace051	 := Space(059)
Private cSpace052	 := Space(110)
Private cSpace053	 := Space(105)
Private cSpace057	 := Space(160)
Private cSpace060	 := Space(069)
Private cSpace065	 := Space(180)
Private cSpace075	 := Space(120)


Private cSA1Filial	 := xFilial("SA1")
Private cSB1Filial	 := xFilial("SB1")
Private cSBMFilial	 := xFilial("SBM")
Private cSC5Filial	 := xFilial("SC5")
Private cSC6Filial	 := xFilial("SC6")
Private cSZQFilial	 := xFilial("SZQ") 

Private cSA1Table	 := RetSQLName("SA1")
Private cSB1Table	 := RetSQLName("SB1")
Private cSBMTable	 := RetSQLName("SBM")
Private cSC5Table	 := RetSQLName("SC5")
Private cSC6Table	 := RetSQLName("SC6")
Private cSZQTable	 := RetSQLName("SZQ")

Private cULine005	 := Replicate("_",005)

Private cdMVPar03	 := Dtos(mv_par03)

Private lSTerceiros	 := ( mv_par05 == 2 )
Private lNTerceiros	 := .NOT.( lSTerceiros )

Private aBox1   	 := {       0700, 1500,   2300}
Private aCab1		 := {"OPERADOR:" , "EXPEDIDOR:"}

Private aBox2   	 := {  0015,         0700,        0900,     1100,       1300,         1500,        1700,     1900,       2100, 2300}
Private aCab2		 := {"ITEM", "PESO BRUTO", "PESO LIQ.", "VOLUME", "MILHEIRO", "PESO BRUTO", "PESO LIQ.", "VOLUME", "MILHEIRO"}

// -[ SSI 11578 - inicio ]-------------------------------------------
private cPedidos     := ''
private cZonaCod     := ''
private cZonaDes	 := ''
private aArea        := ''
// -[ SSI 11578 - fim ]----------------------------------------------

If cEmpAnt == "24"
	cSpace052	 := Space(056)
Endif
	
SC6->(DbOrderNickName("PSC61"))

If Empty(mv_par01)
	mv_par01 := "000001"
EndIf

_mv_par01 := SubStr(mv_par01, 2, 5)
IF Empty(StrTran(Upper(AllTrim(mv_par02)),"Z",""))
	mv_par02 := Replicate("Z",Len(mv_par02))
EndIF
_mv_par02 := SubStr(mv_par02, 2, 5)

IF ( lQuebraCGC )
	cQuery := "SELECT GRP_CGC, A1_CGC, EMB, B1_DESC,"+c_eol+"	B1_XCODBAS,         (CASE           WHEN B1_XCODBAS =' ' THEN           ' '           ELSE           'SM'  END) DESC01, "+c_eol+" C6_DESCRI, B1_COD, B1_XPERSON, B1_XCHANFR, B1_XMED,C6_PRUNIT, SUM(C6_QTDVEN) QTDVEN, DECODE(SUBSTR(B1_COD,1,1),'4',2,'2',1,0) ORDENA, " //SSI 13369
Else
	cQuery := "SELECT EMB, B1_DESC,"+c_eol+"	B1_XCODBAS,         (CASE           WHEN B1_XCODBAS =' ' THEN           ' '           ELSE           'SM'  END) DESC01, "+c_eol+" C6_DESCRI, B1_COD, B1_XPERSON, B1_XMED, B1_XCHANFR, C6_PRUNIT, SUM(C6_QTDVEN) QTDVEN, DECODE(SUBSTR(B1_COD,1,1),'4',2,'2',1,0) ORDENA, " //SSI 13369
EndIf

cQuery += "SUM(ESPACO) ESPACO, SUM(PESO) AS PESO, PID, ZQ_DTPREVE, '         ' CHAVE, BM_XSUBGRU, A1_XROTA, C5_XTPPGT, C5_XOPER "+c_eol+" FROM (" +c_eol

If	mv_par01	<	'500000'

	IF ( lQuebraCGC )
		cQuery += " SELECT "+c_eol+" (CASE A1_PESSOA WHEN 'J' THEN SUBSTR(A1_CGC,1,08) ELSE A1_CGC END) GRP_CGC , A1_CGC, SUBSTR(C5_XEMBARQ,2,5) AS EMB, B1_COD, B1_DESC,"+c_eol+"	B1_XCODBAS,         (CASE           WHEN B1_XCODBAS =' ' THEN           ' '           ELSE           'SM'  END) DESC01, "+c_eol+"  C6_DESCRI,B1_XPERSON, B1_XMED, B1_XCHANFR, C6_PRUNIT, SUM(DECODE(B1_XMODELO,'000008',C6_UNSVEN,C6_QTDVEN)) C6_QTDVEN, " +c_eol  //SSI 13369
	Else
		cQuery += " SELECT  "+c_eol+" SUBSTR(C5_XEMBARQ,2,5) AS EMB, B1_COD, B1_DESC,"+c_eol+"	B1_XCODBAS,         (CASE           WHEN B1_XCODBAS =' ' THEN           ' '           ELSE           'SM'  END) DESC01, "+c_eol+"  C6_DESCRI,B1_XPERSON, B1_XMED, B1_XCHANFR,C6_PRUNIT, SUM(DECODE(B1_XMODELO,'000008',C6_UNSVEN,C6_QTDVEN)) C6_QTDVEN, " +c_eol  //SSI 13369
	EndIf

	cQuery += " ZQ_DTPREVE, SUM(DECODE(B1_XMODELO,'000008',C6_UNSVEN,C6_QTDVEN)*B1_XESPACO) ESPACO, SUM(C6_QTDVEN*B1_PESO) AS PESO, " +c_eol
	cQuery += " SUBSTR(C5_XEMBARQ,1,1) PID, 'P' TPEMB, BM_XSUBGRU, A1_XROTA, C5_XOPER, " +c_eol//SSI 100079
	cQuery += " (SELECT DISTINCT X5_DESCRI FROM SIGA." + RETSQLNAME("SX5") + " SX5 WHERE D_E_L_E_T_ = ' ' and X5_FILIAL = '"+xFilial("SX5")+"' AND X5_TABELA = 'Z4' AND X5_CHAVE = SC5.C5_XTPPGT) AS C5_XTPPGT " +c_eol
	cQuery += " FROM SIGA." + cSB1Table + " SB1, "+c_eol+" SIGA." + cSC5Table + " SC5, "+c_eol+" SIGA." + cSC6Table + " SC6, "+c_eol+" SIGA." + cSBMTable + " SBM, "+c_eol+" SIGA." + cSZQTable + " SZQ, "+c_eol+" SIGA." + cSA1Table + " SA1 "  +c_eol
	cQuery += " WHERE SB1.D_E_L_E_T_ = ' ' " +c_eol
	cQuery += "   AND SC5.D_E_L_E_T_ = ' ' " +c_eol
	cQuery += "   AND SC6.D_E_L_E_T_ = ' ' " +c_eol
	cQuery += "   AND SZQ.D_E_L_E_T_ = ' ' " +c_eol
	cQuery += "   AND SBM.D_E_L_E_T_ = ' ' " +c_eol
	cQuery += "   AND C5_NUM = C6_NUM " +c_eol
	cQuery += "   AND C6_PRODUTO = B1_COD " +c_eol
	cQuery += "   AND C5_XEMBARQ = ZQ_EMBARQ " +c_eol
	cQuery += "   AND C5_CLIENTE = A1_COD(+) " +c_eol
	cQuery += "   AND C5_LOJACLI = A1_LOJA(+) " +c_eol
	cQuery += "   AND SA1.D_E_L_E_T_(+) = ' ' " +c_eol
	cQuery += "   AND A1_FILIAL(+) = '" + cSA1Filial + "' " +c_eol
	cQuery += "   AND B1_FILIAL = '" + cSB1Filial + "' "  +c_eol
	cQuery += "   AND C5_FILIAL = '" + cSC5Filial + "' "  +c_eol
	cQuery += "   AND C6_FILIAL = '" + cSC6Filial + "' "  +c_eol
	cQuery += "   AND ZQ_FILIAL = '" + cSZQFilial + "' "  +c_eol
	cQuery += "   AND BM_FILIAL = '" + cSBMFilial + "' "  +c_eol
	cQuery += "   AND ZQ_DTPREVE = '" + cdMVPar03 + "' "  +c_eol
	cQuery += "   AND C5_XEMBARQ	<	'500000' "
	cQuery += "   AND SUBSTR(C5_XEMBARQ,2,5) BETWEEN '" + _mv_par01 + "' AND '" + _mv_par02 + "'"  +c_eol
	cQuery += "   AND C5_XEMBARQ <> ' ' "  +c_eol
	cQuery += "   AND C6_BLQ <> 'R' "  +c_eol
	cQuery += "   AND BM_GRUPO = B1_GRUPO  "  +c_eol
	cQuery += "   AND ZQ_EMBCOMP = ' ' "  +c_eol

	If ( lSTerceiros )
		cQuery += "   AND B1_COD LIKE '407095%' "
	EndIf

	IF ( lQuebraCGC )
		cQuery += " GROUP BY A1_CGC, C5_XEMBARQ , B1_DESC,B1_XCODBAS, C6_DESCRI, B1_XPERSON,B1_XMED, ZQ_DTPREVE, B1_COD, C6_PRUNIT,BM_XSUBGRU, A1_XROTA, A1_PESSOA, B1_XCHANFR, C5_XTPPGT, C5_XOPER " +c_eol //SSI 13369
	Else
		cQuery += " GROUP BY C5_XEMBARQ , B1_DESC, B1_XCODBAS, C6_DESCRI, B1_XPERSON,B1_XMED, ZQ_DTPREVE, B1_COD, C6_PRUNIT,BM_XSUBGRU, A1_XROTA,  B1_XCHANFR, C5_XTPPGT, C5_XOPER " +c_eol //SSI 13369
	EndIF

	cQuery += " UNION ALL " +c_eol

EndIf

If	mv_par02	> '500000'

	IF ( lQuebraCGC )
		cQuery += " SELECT (CASE A1_PESSOA WHEN 'J' THEN SUBSTR(A1_CGC,1,08) ELSE A1_CGC END) GRP_CGC , A1_CGC, SUBSTR(C5_XEMBARQ,2,5) AS EMB, B1_COD, B1_DESC ,"+c_eol+"	B1_XCODBAS,         (CASE           WHEN B1_XCODBAS =' ' THEN           ' '           ELSE           'SM'  END) DESC01, "+c_eol+" C6_DESCRI, B1_XPERSON, B1_XMED,  B1_XCHANFR, C6_PRUNIT,SUM(DECODE(B1_XMODELO,'000008',C6_UNSVEN,C6_QTDVEN)) C6_QTDVEN, " //SSi 13369
	Else
		cQuery += " SELECT SUBSTR(C5_XEMBARQ,2,5)  AS EMB, B1_COD, B1_DESC ,"+c_eol+"	B1_XCODBAS,         (CASE           WHEN B1_XCODBAS =' ' THEN           ' '           ELSE           'SM'  END) DESC01, "+c_eol+" C6_DESCRI,B1_XPERSON, B1_XMED,  B1_XCHANFR, C6_PRUNIT,SUM(DECODE(B1_XMODELO,'000008',C6_UNSVEN,C6_QTDVEN)) C6_QTDVEN, " //SSI 13369
	EndIF

	cQuery += " ZQ_DTPREVE, SUM(DECODE(B1_XMODELO,'000008',C6_UNSVEN,C6_QTDVEN)*B1_XESPACO) ESPACO, SUM(C6_QTDVEN*B1_PESO) AS PESO, " +c_eol
	cQuery += " TO_CHAR(TO_NUMBER(SUBSTR(C5_XEMBARQ,1,1))-5) PID, 'N' TPEMB, BM_XSUBGRU, A1_XROTA, C5_XOPER, " +c_eol //SSI 100079
	cQuery += " (SELECT DISTINCT X5_DESCRI FROM "+c_eol+" SIGA." + RETSQLNAME("SX5") + " SX5 WHERE D_E_L_E_T_ = ' ' and X5_FILIAL = '"+xFilial("SX5")+"' AND X5_TABELA = 'Z4' AND X5_CHAVE = SC5.C5_XTPPGT) AS C5_XTPPGT " +c_eol
	cQuery += " FROM SIGA." + cSB1Table + " SB1, "+c_eol+" SIGA." + cSC5Table + " SC5, "+c_eol+" SIGA." + cSC6Table + " SC6, "+c_eol+" SIGA." + cSBMTable + " SBM,"+c_eol+" SIGA." + cSZQTable + " SZQ, SIGA." + cSA1Table + " SA1 " +c_eol
	cQuery += " WHERE SB1.D_E_L_E_T_ = ' ' " +c_eol
	cQuery += "   AND SC5.D_E_L_E_T_ = ' ' " +c_eol
	cQuery += "   AND SC6.D_E_L_E_T_ = ' ' " +c_eol
	cQuery += "   AND SZQ.D_E_L_E_T_ = ' ' " +c_eol
	cQuery += "   AND SBM.D_E_L_E_T_ = ' ' " +c_eol
	cQuery += "   AND SA1.D_E_L_E_T_(+) = ' ' " +c_eol
	cQuery += "   AND C5_CLIENTE = A1_COD(+) " +c_eol
	cQuery += "   AND C5_LOJACLI = A1_LOJA(+) " +c_eol
	cQuery += "   AND A1_FILIAL(+) = '" + cSA1Filial + "' " +c_eol
	cQuery += "   AND C5_NUM = C6_NUM " +c_eol
	cQuery += "   AND C6_PRODUTO = B1_COD " +c_eol
	cQuery += "   AND C5_XEMBARQ = ZQ_EMBARQ " +c_eol
	cQuery += "   AND C5_FILIAL = '" + cSC5Filial + "' " +c_eol
	cQuery += "   AND C6_FILIAL = '" + cSC6Filial + "' " +c_eol
	cQuery += "   AND ZQ_FILIAL = '" + cSZQFilial + "' " +c_eol
	cQuery += "   AND BM_FILIAL = '" + cSBMFilial + "' " +c_eol
	cQuery += "   AND B1_FILIAL = '" + cSB1Filial + "' " +c_eol
	cQuery += "   AND BM_GRUPO = B1_GRUPO " +c_eol
	cQuery += "   AND ZQ_DTPREVE = '" + cdMVPar03 + "' " +c_eol
	cQuery += "   AND C5_XEMBARQ	>=	'500000' "  +c_eol
	cQuery += "   AND SUBSTR(C5_XEMBARQ,2,5) BETWEEN '" + _mv_par01 + "' AND '" + _mv_par02 + "'" +c_eol
	cQuery += "   AND C5_XEMBARQ <> ' ' " +c_eol
	cQuery += "   AND C6_BLQ <> 'R' " +c_eol
	cQuery += "   AND ZQ_EMBCOMP = ' ' " +c_eol

	If ( lSTerceiros )
		cQuery += "   AND B1_COD LIKE '407095%' " +c_eol
	EndIf

	IF ( lQuebraCGC )
		cQuery += " GROUP BY A1_CGC, C5_XEMBARQ, B1_COD, B1_DESC ,B1_XCODBAS,  C6_DESCRI,B1_XPERSON,B1_XMED, ZQ_DTPREVE, C6_PRUNIT,BM_XSUBGRU, A1_XROTA, A1_PESSOA, B1_XCHANFR, C5_XTPPGT, C5_XOPER " +c_eol //SSI 13369
	Else
		cQuery += " GROUP BY C5_XEMBARQ, B1_COD, B1_DESC , B1_XCODBAS,  C6_DESCRI,B1_XPERSON,B1_XMED, ZQ_DTPREVE, C6_PRUNIT,BM_XSUBGRU, A1_XROTA, B1_XCHANFR, C5_XTPPGT,C5_XOPER " +c_eol //SSI 13369
	EndIF

	cQuery += " UNION ALL " +c_eol

EndIf

If	mv_par01	< '500000'

	IF ( lQuebraCGC )
		cQuery += " SELECT (CASE A1_PESSOA WHEN 'J' THEN SUBSTR(A1_CGC,1,08) ELSE A1_CGC END) GRP_CGC , A1_CGC, SUBSTR(ZQ_EMBCOMP,2,5) AS EMB, B1_COD, B1_DESC ,"+c_eol+"	B1_XCODBAS,         (CASE           WHEN B1_XCODBAS =' ' THEN           ' '           ELSE           'SM'  END) DESC01, "+c_eol+" C6_DESCRI,B1_XPERSON, B1_XMED,  B1_XCHANFR, C6_PRUNIT,SUM(DECODE(B1_XMODELO,'000008',C6_UNSVEN,C6_QTDVEN)) C6_QTDVEN, " //SSi 13369
	Else
		cQuery += " SELECT SUBSTR(ZQ_EMBCOMP,2,5) AS EMB, B1_COD, B1_DESC , "+c_eol+"	B1_XCODBAS,         (CASE           WHEN B1_XCODBAS =' ' THEN           ' '           ELSE           'SM'  END) DESC01, "+c_eol+" C6_DESCRI,B1_XPERSON, B1_XMED, B1_XCHANFR, C6_PRUNIT,SUM(DECODE(B1_XMODELO,'000008',C6_UNSVEN,C6_QTDVEN)) C6_QTDVEN, " //SSi 13369
	EndIF

	cQuery += " ZQ_DTPREVE, SUM(DECODE(B1_XMODELO,'000008',C6_UNSVEN,C6_QTDVEN)*B1_XESPACO) ESPACO, SUM(C6_QTDVEN*B1_PESO) AS PESO, "
	cQuery += " SUBSTR(ZQ_EMBCOMP,1,1) PID, 'N' TPEMB, BM_XSUBGRU, A1_XROTA, C5_XOPER, " //SSI 100079"
	cQuery += " (SELECT DISTINCT X5_DESCRI FROM SIGA." + RETSQLNAME("SX5") + " SX5 WHERE D_E_L_E_T_ = ' ' and X5_FILIAL = '"+xFilial("SX5")+"' AND X5_TABELA = 'Z4' AND X5_CHAVE = SC5.C5_XTPPGT) AS C5_XTPPGT "
	cQuery += " FROM SIGA." + cSB1Table + " SB1, SIGA." + cSC5Table + " SC5, SIGA." + cSC6Table + " SC6, SIGA." + cSBMTable + " SBM, SIGA." + cSZQTable + " SZQ, SIGA." + cSA1Table + " SA1 "
	cQuery += " WHERE SB1.D_E_L_E_T_ = ' ' " +c_eol
	cQuery += "   AND SC5.D_E_L_E_T_ = ' ' " +c_eol
	cQuery += "   AND SC6.D_E_L_E_T_ = ' ' " +c_eol
	cQuery += "   AND SZQ.D_E_L_E_T_ = ' ' " +c_eol
	cQuery += "   AND SBM.D_E_L_E_T_ = ' ' " +c_eol
	cQuery += "   AND SA1.D_E_L_E_T_(+) = ' ' " +c_eol
	cQuery += "   AND C5_CLIENTE = A1_COD(+) " +c_eol
	cQuery += "   AND C5_LOJACLI = A1_LOJA(+) " +c_eol
	cQuery += "   AND A1_FILIAL(+) = '" + cSA1Filial + "' " +c_eol
	cQuery += "   AND C5_NUM = C6_NUM " +c_eol
	cQuery += "   AND C6_PRODUTO = B1_COD " +c_eol
	cQuery += "   AND C5_XEMBARQ = ZQ_EMBARQ " +c_eol
	cQuery += "   AND C5_XEMBARQ <> ' ' " +c_eol
	cQuery += "   AND C5_FILIAL = '" + cSC5Filial + "' " +c_eol
	cQuery += "   AND C6_FILIAL = '" + cSC6Filial + "' " +c_eol
	cQuery += "   AND ZQ_FILIAL = '" + cSZQFilial + "' " +c_eol
	cQuery += "   AND BM_FILIAL = '" + cSBMFilial + "' " +c_eol
	cQuery += "   AND B1_FILIAL = '" + cSB1Filial + "' " +c_eol
	cQuery += "   AND BM_GRUPO = B1_GRUPO " +c_eol
	cQuery += "   AND ZQ_DTPREVE = '" + cdMVPar03 + "' " +c_eol
	cQuery += "   AND ZQ_EMBCOMP < '500000' " +c_eol
	cQuery += "   AND SUBSTR(ZQ_EMBCOMP,2,5) BETWEEN '" + _mv_par01 + "' AND '" + _mv_par02 + "'" +c_eol
	cQuery += "   AND ZQ_EMBCOMP <> ' ' " +c_eol
    cQuery += "   AND C6_BLQ <> 'R' " +c_eol
 
	If ( lSTerceiros ) 
		cQuery += "   AND B1_COD LIKE '407095%' " +c_eol
	Endif 

	IF ( lQuebraCGC )
		cQuery += " GROUP BY A1_CGC, ZQ_EMBCOMP,B1_COD, B1_DESC , B1_XCODBAS,  C6_DESCRI,B1_XPERSON,B1_XMED, ZQ_DTPREVE, C6_PRUNIT,BM_XSUBGRU, A1_XROTA, A1_PESSOA, B1_XCHANFR, C5_XTPPGT, C5_XOPER " +c_eol //SSI 13369
	Else
		cQuery += " GROUP BY ZQ_EMBCOMP,B1_COD, B1_DESC , B1_XCODBAS,  C6_DESCRI,B1_XPERSON,B1_XMED, ZQ_DTPREVE, C6_PRUNIT,BM_XSUBGRU, A1_XROTA, B1_XCHANFR, C5_XTPPGT, C5_XOPER " +c_eol //SSI 13369
	EndIF

	If	mv_par02	> '500000'
		cQuery += " UNION ALL " +c_eol
	EndIf

EndIf

If	mv_par02	> '500000'

	IF ( lQuebraCGC )
		cQuery += " SELECT (CASE A1_PESSOA WHEN 'J' THEN SUBSTR(A1_CGC,1,08) ELSE A1_CGC END) GRP_CGC , A1_CGC, SUBSTR(ZQ_EMBCOMP,2,5) AS EMB, B1_COD, B1_DESC ,"+c_eol+"	B1_XCODBAS,         (CASE           WHEN B1_XCODBAS =' ' THEN           ' '           ELSE           'SM'  END) DESC01, "+c_eol+"  C6_DESCRI,B1_XPERSON, B1_XMED, B1_XCHANFR, C6_PRUNIT,SUM(DECODE(B1_XMODELO,'000008',C6_UNSVEN,C6_QTDVEN)) C6_QTDVEN, " //SSI 13369
	Else
		cQuery += " SELECT SUBSTR(ZQ_EMBCOMP,2,5) AS EMB, B1_COD, B1_DESC ,"+c_eol+"	B1_XCODBAS,         (CASE           WHEN B1_XCODBAS =' ' THEN           ' '           ELSE           'SM'  END) DESC01, "+c_eol+"  C6_DESCRI,B1_XPERSON, B1_XMED, B1_XCHANFR,C6_PRUNIT, SUM(DECODE(B1_XMODELO,'000008',C6_UNSVEN,C6_QTDVEN)) C6_QTDVEN, " //SSI 13369
	EndIF

	cQuery += " ZQ_DTPREVE, SUM(DECODE(B1_XMODELO,'000008',C6_UNSVEN,C6_QTDVEN)*B1_XESPACO) ESPACO, SUM(C6_QTDVEN*B1_PESO) AS PESO, " +c_eol
	cQuery += " TO_CHAR(TO_NUMBER(SUBSTR(ZQ_EMBCOMP,1,1))-5) PID, 'N' TPEMB, BM_XSUBGRU, A1_XROTA, C5_XOPER, " +c_eol //SSI 100079 
	cQuery += " (SELECT DISTINCT X5_DESCRI FROM SIGA." + RETSQLNAME("SX5") + " SX5 WHERE D_E_L_E_T_ = ' ' and X5_FILIAL = '"+xFilial("SX5")+"' AND X5_TABELA = 'Z4' AND X5_CHAVE = SC5.C5_XTPPGT) AS C5_XTPPGT " +c_eol
	cQuery += " FROM SIGA." + cSB1Table + " SB1, SIGA." + cSC5Table + " SC5, SIGA." + cSC6Table + " SC6, SIGA." + cSBMTable + " SBM, SIGA." + cSZQTable + " SZQ, SIGA." + cSA1Table + " SA1 " +c_eol
	cQuery += " WHERE SB1.D_E_L_E_T_    = ' ' " +c_eol
	cQuery += "   AND SC5.D_E_L_E_T_    = ' ' " +c_eol
	cQuery += "   AND SC6.D_E_L_E_T_    = ' ' " +c_eol
	cQuery += "   AND SZQ.D_E_L_E_T_    = ' ' " +c_eol
	cQuery += "   AND SBM.D_E_L_E_T_    = ' ' " +c_eol
	cQuery += "   AND SA1.D_E_L_E_T_(+) = ' ' " +c_eol
	cQuery += "   AND C5_CLIENTE        = A1_COD(+) " +c_eol
	cQuery += "   AND C5_LOJACLI        = A1_LOJA(+) " +c_eol
	cQuery += "   AND A1_FILIAL(+)      = '" + cSA1Filial + "' " +c_eol
	cQuery += "   AND C5_NUM            = C6_NUM " +c_eol
	cQuery += "   AND C6_PRODUTO        = B1_COD " +c_eol
	cQuery += "   AND C5_XEMBARQ        = ZQ_EMBARQ " +c_eol
	cQuery += "   AND C5_FILIAL         = '" + cSC5Filial + "' " +c_eol
	cQuery += "   AND C6_FILIAL         = '" + cSC6Filial + "' " +c_eol
	cQuery += "   AND ZQ_FILIAL         = '" + cSZQFilial + "' " +c_eol
	cQuery += "   AND BM_FILIAL         = '" + cSBMFilial + "' " +c_eol
	cQuery += "   AND B1_FILIAL         = '" + cSB1Filial + "' " +c_eol
	cQuery += "   AND BM_GRUPO          = B1_GRUPO " +c_eol
	cQuery += "   AND ZQ_DTPREVE        = '" + cdMVPar03 + "' " +c_eol
	cQuery += "   AND ZQ_EMBCOMP	   >=	'500000' " +c_eol
	cQuery += "   AND SUBSTR(ZQ_EMBCOMP,2,5) BETWEEN '" + _mv_par01 + "' AND '" + _mv_par02 + "' " +c_eol
	cQuery += "   AND C5_XEMBARQ <> ' ' " +c_eol
    cQuery += "   AND C6_BLQ <> 'R' " +c_eol

	If ( lSTerceiros )
		cQuery += "   AND B1_COD LIKE '407095%' " +c_eol
	EndIf

	If ( lQuebraCGC )
		cQuery += " GROUP BY A1_CGC, ZQ_EMBCOMP, B1_COD, B1_DESC, B1_XCODBAS, C6_DESCRI, B1_XPERSON, B1_XMED, ZQ_DTPREVE, C6_PRUNIT,BM_XSUBGRU, A1_XROTA, A1_PESSOA, B1_XCHANFR, C5_XTPPGT, C5_XOPER " +c_eol //SSI 13369
	Else
		cQuery += " GROUP BY ZQ_EMBCOMP, B1_COD, B1_DESC, B1_XCODBAS, C6_DESCRI, B1_XPERSON, B1_XMED, ZQ_DTPREVE, C6_PRUNIT,BM_XSUBGRU, A1_XROTA, B1_XCHANFR, C5_XTPPGT, C5_XOPER " +c_eol //SSI 13369
	EndIF

Endif

cQuery += ") A "

IF ( lQuebraCGC )
	cQuery += " GROUP BY GRP_CGC , A1_CGC, EMB, B1_COD, B1_DESC, B1_XCODBAS,  C6_DESCRI, B1_XPERSON, B1_XMED, PID, ZQ_DTPREVE, C6_PRUNIT,BM_XSUBGRU, A1_XROTA, B1_XCHANFR, C5_XTPPGT, C5_XOPER "+c_eol //SSI 13369
Else
	cQuery += " GROUP BY EMB, B1_COD, B1_DESC, B1_XCODBAS,  C6_DESCRI, B1_XPERSON, B1_XMED, PID, ZQ_DTPREVE, C6_PRUNIT,BM_XSUBGRU, A1_XROTA, B1_XCHANFR, C5_XTPPGT, C5_XOPER " +c_eol //SSI 13369
EndIf	

If ( nOrder == 3 )	//Rota(Carga+Rota)

	IF ( lQuebraCGC )
		cQuery += " ORDER BY EMB, A1_XROTA, GRP_CGC , A1_CGC , ORDENA, B1_COD "
	Else
		cQuery += " ORDER BY EMB, A1_XROTA, B1_COD "
	EndIF

ElseIf ( nOrder == 2 )	//Segmento(Carga+Segmento)

	IF ( lQuebraCGC )
		cQuery += " ORDER BY EMB, GRP_CGC , A1_CGC , ORDENA, B1_COD "
	Else
		cQuery += " ORDER BY EMB, ORDENA, B1_COD "
	EndIF

ElseIF ( nOrder == 1 ) //Codigo(Carga+Produto)

	IF ( lQuebraCGC )
		cQuery += " ORDER BY EMB, B1_DESC, C6_DESCRI, GRP_CGC , A1_CGC " //SSI 13369
	Else
		cQuery += " ORDER BY EMB, B1_DESC, C6_DESCRI " //SSI 13369
	EndIF

EndIf

//#IFDEF ORTOBOM_DEBUG
	MemoWrit("C:\ORTR021.SQL", cQuery)
//#ENDIF

If .NOT.(dbQuery(cQuery,"QRY"))
	MsgBox("Nao ha Dados a serem impressos para este relatorio", "Aviso", "INFO")
	Return
EndIf

If ( lPrnVal )
	Limite := 132
Else
	Limite := 80
EndIf

cLine := Replicate("-",Limite)

lImp := .F.
ntot := 0.00
aRota := {}

SB1->( DbOrderNickName("PSB11") )

oPrn:IncMeter(0)

nMaxV := oPrn:PageHeight()
nMaxV -= ( 3 * LINE_HEIGHT ) //Margem para impressao de Todas as Linhas na Laser
nMaxH := oPrn:PageWidth()

SetPageBreak()

cEmb := QRY->EMB
nC6_PRUNIT:=QRY->C6_PRUNIT

While QRY->( !Eof() )

	oPrn:IncMeter()
	If ( oPrn:Cancel() )
		ImpLine("*** CANCELADO PELO OPERADOR ***")
		Exit
	Endif                      
	// ssi 5711
	If cEmpAnt == "24"
		//cCGC2PG	:= QRY->A1_CGC 
	endif
	If .NOT.( cEmb == QRY->EMB )
		If ( lNTerceiros )
			RodaPe(1)
		Else
			cEmb := QRY->EMB
			cPid := QRY->PID
			RodaPe(2)
		EndIf
		aSize( aRota , 0 )
	EndIf
	

	cEmb := QRY->EMB
	cPid := QRY->PID
    nC6_PRUNIT:=QRY->C6_PRUNIT

	cCodPro := SubStr(QRY->B1_COD, 1, 10)
	//Início SSI 13369
	//cDescri := QRY->B1_DESC
	IF SUBSTR(QRY->C6_DESCRI,1,LEN(ALLTRIM(QRY->B1_DESC)))<> ALLTRIM(QRY->B1_DESC)
		cDescri := QRY->C6_DESCRI
	ELSE
		cDescri := QRY->B1_DESC
	ENDIF
	//Fim SSI 13369	
	cMedida := QRY->B1_XMED
	nQtdVen += QRY->QTDVEN
	cPerson := QRY->B1_XPERSON
	cSobMed := QRY->DESC01

	If !( AllTrim( QRY->C5_XOPER ) $ "04/23" ) //SSI 100079

		nTotEsp += QRY->ESPACO
	EndIf

	nTotPec += QRY->QTDVEN
	nTotPes += QRY->PESO
	cTpPgt  := QRY->C5_XTPPGT
	nChanfr := QRY->B1_XCHANFR

    nValorCust:=QRY->C6_PRUNIT

	/* SSI 108141 */
	If cEmpAnt == "05"
		nPctCarg1:= Round(((nTotEsp * 100) / 280),2)
		nPctCarg2:= Round(((nTotEsp * 100) / 790),2)
	ElseIf cEmpAnt == "06"
		/* SSI 114940 */
		nPctCarg1:= Round(((nTotEsp * 100) / 250),2)
		nPctCarg2:= Round(((nTotEsp * 100) / 820),2)
		/* SSI 114940 */
	EndIf
	/* SSI 108141 */

	If lQuebraCGC //SSI 12124	
	// -[ SSI 11578 - inicio ]-------------------------------------------
		aArea    := GetArea()
	    cZonaCod := QRY->A1_XROTA
		cPedidos := ''
	// -[ zona ]---------------------------------------------------------
		DbSelectArea('SZ3')
		dbOrderNickName('CSZ31')
		if DbSeek(xFilial('SZ3') + QRY->A1_XROTA )
		    cZonaDes := SZ3->Z3_DESC
		else
		    cZonaDes := 'Não encontrado!'
		endif  
	// -[ pedidos ]------------------------------------------------------
		DbSelectArea('SA1')
		dbOrderNickName('PSA13')
		if DbSeek(xFilial('SA1') + QRY->A1_CGC )
			DbSelectArea('SC5')
			dbOrderNickName('CSC55')
			if DbSeek(xFilial('SC5') + alltrim(QRY->PID) + QRY->EMB )
				do while SC5->C5_XEMBARQ == alltrim(QRY->PID) + QRY->EMB
					if SC5->C5_CLIENTE == SA1->A1_COD
						DbSelectArea('SC6')
						dbOrderNickName('PSC62')
						if DbSeek(xFilial('SC6') + QRY->B1_COD + SC5->C5_NUM )
							if !empty(alltrim(cPedidos))
								cPedidos += ', '
							endif
							cPedidos += SC5->C5_NUM
						endif
					endif
					SC5->(DbSkip())
				enddo
			endif
		endif
		RestArea( aArea )
	EndIf //SSI 12124
// -[ SSI 11578 - fim ]----------------------------------------------

	ChkPgBreak()

	IF ( lQuebraCGC )

		nQtdCGC		+= QRY->QTDVEN
		IF .NOT.( cA1CGC == QRY->A1_CGC )
			cA1CGC		:= QRY->A1_CGC                                                  
			cCGC2PG	    := QRY->A1_CGC // 5711
			cCGCDesc	:= Posicione("SA1",nA1OrdCGC,cSA1Filial+cA1CGC,"A1_NOME")
			cCGCRDesc	:= Posicione("SA1",nA1OrdCGC,cSA1Filial+cA1CGC,"A1_NREDUZ")
			cCidade  	:= Posicione("SA1",nA1OrdCGC,cSA1Filial+cA1CGC,"A1_MUN")
			//cCidade  	:= Posicione("SZN",nA1OrdCGC,cSA1Filial+cA1CGC,"ZN_CIDADE")
			ImpLine(cSpace001+"CGC         : "+cA1CGC+" : " +cCGCDesc,,,, 0,,,, .F.)
			IncLine(2)
		EndIF
		IF .NOT.(cGRPCGC==QRY->GRP_CGC)
			cGRPCGC		:= QRY->GRP_CGC
			cGRPCGCDesc	:= Posicione("SA1",nA1OrdCGC,cSA1Filial+cGRPCGC,"A1_NREDUZ")
			IF Empty( cGRPCGCDesc )
				cGRPCGCDesc := cCGCRDesc
			EndIF
		EndIF
		nQtdGRPCGC	+= nQtdCGC
	EndIF

	If Len(aRota) == 0 .Or. aScan(aRota, QRY->A1_XROTA) == 0
		aAdd(aRota, QRY->A1_XROTA)
	EndIf

	QRY->(DbSkip())

	If QRY->( B1_COD <> cCodPro .or. cEmb <> QRY->EMB .or. (cEmpAnt=="21" .AND. nC6_PRUNIT # QRY->C6_PRUNIT) .OR. ( lQuebraCGC .and. .NOT.(cA1CGC==A1_CGC) ) )

		IF ( lQuebraCGC )
			IF QRY->( .NOT.(cA1CGC==A1_CGC) .and. (cGRPCGC==GRP_CGC) )
				++nGRPCGC
			EndIF	                  
		EndIF
		If cSobMed	<> "  " //llr
			oprn:Say(nLin,0010,cCodPro,oFontn)
			oprn:Say(nLin,0230,SubStr(cDescri, 1, 30),oFontn)
			oprn:Say(nLin,0840,SubStr(cSobMed, 1, 04),oFontn)
			oprn:Say(nLin,0900,cMedida,oFontn)
			If cEmpAnt == "21" //&& Henrique - 05/02/2019 SSI 74675
 			   oprn:Say(nLin,1350,Transform(nQtdVen,"@E 999,999.999"),oFontn,100,,,1)
 	    	Else
 	    	   oprn:Say(nLin,1350,Transform(nQtdVen, iif(cEmpAnt=="24",Tm(nQtdVen, 9, 3),Tm(nQtdVen, 5, 0))),oFontn,100,,,1)
 	    	EndIf

			IF SB1->( DbSeek( cSB1Filial + cCodPro , .F. ) )
					oprn:Say(nLin,1550,SB1->B1_UM,oFontn) 

					//Edilson Leal 16/09/2020 - Inclui Quantidade 2 UM - SSI 102334 - INICIO
 			        oprn:Say(nLin,1870,Transform(If(SB1->B1_TIPCONV=="D",nQtdVen/SB1->B1_CONV,If(SB1->B1_TIPCONV=="M",nQtdVen*SB1->B1_CONV,0)),"@E 999,999.999999"),oFontn,100,,,1)           
					oprn:Say(nLin,1880,SB1->B1_SEGUM,oFontn) 
					//Edilson Leal 16/09/2020 - Quantidade 2 UM - SSI 102334 - FIM

			EndIF
		else
			oprn:Say(nLin,0010,cCodPro,oFont)
			oprn:Say(nLin,0230,SubStr(cDescri, 1, 30),oFont)
			oprn:Say(nLin,0840,SubStr(cSobMed, 1, 04),oFont)
			oprn:Say(nLin,0900,cMedida,oFont)
			If cEmpAnt == "21"// && Henrique - 05/02/2019 SSI 74675
 			   oprn:Say(nLin,1350,Transform(nQtdVen,"@E 999,999.999"),oFont,100,,,1)
 	    	Else
 	    	   oprn:Say(nLin,1350,Transform(nQtdVen, iif(cEmpAnt=="24",Tm(nQtdVen, 9, 3),Tm(nQtdVen, 5, 0))),oFont,100,,,1)
 	    	EndIf

			 IF SB1->( DbSeek( cSB1Filial + cCodPro , .F. ) )
				oprn:Say(nLin,1550,SB1->B1_UM,oFont) 

				//Edilson Leal 16/09/2020 - Inclui Quantidade 2 UM - SSI 102334 - INICIO
 		        oprn:Say(nLin,1870,Transform(If(SB1->B1_TIPCONV=="D",nQtdVen/SB1->B1_CONV,If(SB1->B1_TIPCONV=="M",nQtdVen*SB1->B1_CONV,0)),"@E 999,999.999999"),oFont,100,,,1)         
				oprn:Say(nLin,1880,SB1->B1_SEGUM,oFont) 
				//Edilson Leal 16/09/2020 - Quantidade 2 UM - SSI 102334 - FIM
			EndIF

		EndIf

//		oprn:Say(nLin,1420,cTpPgt,oFont)

		if !Empty(nChanfr)
//			oprn:Say(nLin,2220,Transform(nChanfr, iif(cEmpAnt=="24",Tm(nChanfr, 6, 3),Tm(nChanfr, 6, 3))),oFont)
//			oPrn:Say(nLin,2150,TransForm(nChanfr, "@E 999.999" ),oFont)
			oPrn:Say(nLin,1300,TransForm(nChanfr, "@E 999.999" ),oFont,100,,,1)
		endIF

		If ( lPrnVal )
			cCodigo := cCodPro
			If cEmpAnt # "21"
			   IF SB1->( DbSeek( cSB1Filial + cCodigo , .F. ) )
				  nValorCust := SB1->B1_CUSTD
			   Else
				  nValorCust := 0
			   EndIF
			EndIf
			If cSobMed	<> "  "//llr
				oPrn:Say(nLin,2100,TransForm(nValorCust, "@E 999,999.99"),oFontn,100,,,1)
				nTotal	:= (nValorCust * nQtdVen)
				oPrn:Say(nLin,2300,TransForm(nTotal, "@E 99,999,999.99" ),oFontn,100,,,1)
				nTot += nTotal
			Else
				oPrn:Say(nLin,2100,TransForm(nValorCust, "@E 999,999.99"),oFont,100,,,1)
				nTotal	:= (nValorCust * nQtdVen)
				oPrn:Say(nLin,2300,TransForm(nTotal, "@E 99,999,999.99" ),oFont,100,,,1)
				nTot += nTotal
			EndIf
			IF ( lQuebraCGC )
				nVlrCGC		+= nValorCust
				nTotCGC		+= nTotal
				nVlrGRPCGC	+= nVlrCGC
				nTotGRPCGC	+= nTotCGC
			EndIF	

		EndIf
		
		If !Empty(cPerson)
			IncLine()
			ImpLine(cSpace012 + cPerson,,,, 0,,,, .F.)
		EndIf

		IF ( lQuebraCGC )
			IF .NOT.(cA1CGC==QRY->A1_CGC)
				IncLine(3)                
				oPrn:Say(nLin,0010,SubStr("CIDADE : "+cCidade,1,52),oFont)
				oprn:Say(nLin,0900,"TOTAL : ",oFont)
				oPrn:Say(nLin,1350,Transform(nQtdCGC, iif(cEmpAnt=="24",Tm(nQtdCGC, 9, 3),Tm(nQtdCGC, 5, 0))),oFont,100,,,1)
				nQtdCGC	:= 0
				
// -------------[ SSI 11578 - inicio ]-------------------------------
				IncLine(3)
				oPrn:Say(nLin,0010,'ZONA : '      + cZonaCod + ' - ' + cZonaDes ,oFont)
				oprn:Say(nLin,0840,'PEDIDO(S) : ' + cPedidos                    ,oFont)
// -------------[ SSI 11578 - fim ]----------------------------------

				IF ( lPrnVal )
					oPrn:Say(nLin,2100,TransForm(nVlrCGC, "@E 999,999.99"),oFont,100,,,1)
					oPrn:Say(nLin,2300,TransForm(nTotCGC, "@E 99,999,999.99" ),oFont,100,,,1)
					nVlrCGC	:= 0
					nTotCGC	:= 0
				EndIF
				IncLine()
			EndIF
			IF .NOT.(cGRPCGC==QRY->GRP_CGC)
				IF ( nGRPCGC > 1 )
					IncLine()                 
					oPrn:Say(nLin,0010,SubStr("TOTAL GRUPO : "+cGRPCGC+" : "+cGRPCGCDesc,1,52),oFont)
					oPrn:Say(nLin,1200,Transform(nQtdGRPCGC, iif(cEmpAnt=="24",Tm(nQtdGRPCGC, 9, 3),Tm(nQtdGRPCGC, 5, 0))),oFont)
					IF ( lPrnVal )
						oPrn:Say(nLin,2100,TransForm(nVlrGRPCGC, "@E 999,999.99"),oFont,100,,,1)
						oPrn:Say(nLin,2300,TransForm(nTotGRPCGC, "@E 99,999,999.99" ),oFont,100,,,1)
					EndIF
				EndIF
				nGRPCGC	   := 0
				nQtdGRPCGC := 0
				nVlrGRPCGC := 0
				nTotGRPCGC := 0
				IncLine(2)
				ImpLine(cLine ,,,, 0,,,, .F.)
				IncLine()
			ENDIF
		EndIF

		nQtdVen := 0
		IncLine()

	EndIf

End Do

IncLine()

If !Empty(cEmb)
	If ( lSTerceiros )
		RodaPe(3)
	Else
		RodaPe(1)
	EndIf
EndIf

Return

/*/
*******************************************************************************
* Funcao : RodaPe      * Autor : Cesar Dupim             * Data : 20/03/2006  *
*******************************************************************************
* Descricao : Funcao auxiliar para impressao do rodapé do relatório           *
*******************************************************************************
* Uso       : OrtR021                                                         *
*******************************************************************************
/*/
Static Function RodaPe(nTipo)

Local cQryRoda	:= ""
Local cCli 		:= ""
Local nCol 		:= 1
Local nRotas	:= Len(aRota)
Local i			:= " "
Local _i		:= " "
Local nCont		:= " "

Default nTipo :=	1
lFim	:= .F.
If (nTot > 0)
	ChkPgBreak(6)
    If cEmpAnt == "21"
       ImpLine(Space(130)+"SOMATORIO DOS ITENS -->" + TransForm(nTot, "@E 9999,999,999.99" ),,,, 0,,,, .F.)
       nTot:=0
    Else
      ImpLine(Space(065) + TransForm(nTot, "@E 99,999,999.99" ),,,, 0,,,, .F.)
    EndIf
	IncLine(2)
Else
	ChkPgBreak(3)
EndIf

If cEmpAnt == "05"
	oPrn:Say(nLin,0010,"TOTAL ESPACO: " + AllTrim(Transform(nTotEsp, "@E 999,999")),oFont)
	/* SSI 108141 */
	oPrn:Say(nLin,0400,"OCUPAÇÃO: " + AllTrim(Transform(nPctCarg1, "@E 999,999")) + "% (280) | " + AllTrim(Transform(nPctCarg2, "@E 999,999")) + "% (790)",oFont)
	/* SSI 108141 */
	oPrn:Say(nLin,1050,"TOTAL DE PECAS: " + AllTrim(iif(cEmpAnt=="24",Transform(nTotPec, "@E 999,999.999"),Transform(nTotPec, "@E 999,999"))),oFont)
	oPrn:Say(nLin,1455,"TOTAL PESO: " + AllTrim(Transform(nTotPes, "@E 999,999,999.99")),oFont)
ElseIf cEmpAnt == "06"
	oPrn:Say(nLin,0010,"TOTAL ESPACO: " + AllTrim(Transform(nTotEsp, "@E 999,999")),oFont)
	/* SSI 108141 */
	oPrn:Say(nLin,0400,"OCUPAÇÃO: " + AllTrim(Transform(nPctCarg1, "@E 999,999")) + "% (250) | " + AllTrim(Transform(nPctCarg2, "@E 999,999")) + "% (820)",oFont)
	/* SSI 108141 */
	oPrn:Say(nLin,1050,"TOTAL DE PECAS: " + AllTrim(iif(cEmpAnt=="24",Transform(nTotPec, "@E 999,999.999"),Transform(nTotPec, "@E 999,999"))),oFont)
	oPrn:Say(nLin,1455,"TOTAL PESO: " + AllTrim(Transform(nTotPes, "@E 999,999,999.99")),oFont)
Else
	oPrn:Say(nLin,0010,"TOTAL ESPACO: " + AllTrim(Transform(nTotEsp, "@E 999,999")),oFont)
	oPrn:Say(nLin,0800,"TOTAL DE PECAS: " + AllTrim(iif(cEmpAnt=="24",Transform(nTotPec, "@E 999,999.999"),Transform(nTotPec, "@E 999,999"))),oFont)
	oPrn:Say(nLin,1600,"TOTAL PESO: " + AllTrim(Transform(nTotPes, "@E 999,999,999.99")),oFont)
EndIF


If (nRotas > 0)
	IncLine(2)
	ChkPgBreak(1+nRotas)
	oPrn:Say(nLin,0010,"ROTEIROS: ",oFont)
	nCol := 220
	For i := 1 To nRotas
		oPrn:Say(nLin,nCol,aRota[i],oFont)
		nCol += 140
	Next
EndIf

If	nTipo == 1
	cQryRoda := " SELECT DISTINCT C5_CLIENTE, C5_NUM , C5_XTPSEGM "
	cQryRoda += " FROM SIGA." + cSC5Table + " SC5, SIGA." + cSZQTable + " SZQ "
	cQryRoda += " WHERE SC5.D_E_L_E_T_ = ' ' AND SZQ.D_E_L_E_T_ = ' ' AND C5_FILIAL = '" + cSC5Filial + "' AND ZQ_FILIAL = '" + cSZQFilial + "' "
	cQryRoda += " AND ZQ_EMBARQ = C5_XEMBARQ AND (SUBSTR(ZQ_EMBARQ,2,5) = '" + AllTrim(cEmb) + "' OR SUBSTR(ZQ_EMBCOMP,2,5) = '" + AllTrim(cEmb) + "') "
	cQryRoda += " AND ZQ_DTPREVE = '" + cdMVPar03 + "' " //SSI 9432
	cQryRoda += " ORDER BY C5_CLIENTE, C5_NUM , C5_XTPSEGM "
	
	#IFDEF ORTOBOM_DEBUG
		MemoWrit("C:\RODAPE.SQL", cQryRoda)
	#ENDIF	
	
	dbQuery(cQryRoda,'RODAPE')

	IncLine()

	While RODAPE->(!Eof())
		If nCol > 2000 .or. cCli <> RODAPE->C5_CLIENTE
			IncLine()
			nCol := 180
			If RODAPE->C5_XTPSEGM $ "2#3"
				oPrn:Say(nLin,0010,RODAPE->C5_CLIENTE,oFont)
			Else
				oPrn:Say(nLin,0010,"000000",oFont)
			EndIf
			cCli := RODAPE->C5_CLIENTE
		EndIf
		oPrn:Say(nLin,nCol,SubStr(RODAPE->C5_NUM, 1, 3) + "." + SubStr(RODAPE->C5_NUM, 4, 3),oFont)
		nCol += 180
		RODAPE->(Dbskip())
	End

	IncLine(2)

	ImpLine(cSpace001 + "COMPLEMENTO ",,,, 0,,,, .T.)

	If	__lNPid .And. __lPid
		ImpLine(cSpace013 + Str(Val(cPID) + 5, 1) + cEMB,,,, 0,,,, .T.)
	EndIf
	
	_cQuery := "SELECT ZQ_EMBARQ FROM SIGA." + cSZQTable + " WHERE ZQ_FILIAL = '" + cSZQFilial + "' AND D_E_L_E_T_ = ' ' AND ZQ_EMBCOMP LIKE  '%" + AllTrim(cEMB) + "' "
	
	#IFDEF ORTOBOM_DEBUG
		MemoWrit("C:\QRYCOMP.SQL", _cQuery)
	#ENDIF	

	dbQuery(_cQuery,"QRYCOMP")

	_aEmbComp := {}
	
	While QRYCOMP->(!Eof())
		nPos := aScan(_aEmbComp, { |x| x[1] == QRYCOMP->ZQ_EMBARQ})
		If	nPos == 0
			aAdd(_aEmbComp, {QRYCOMP->ZQ_EMBARQ})
		EndIf
		QRYCOMP->(DbSkip())
	End
	
	For _i := 1 To Len(_aEmbComp)
		ImpLine(Space(pCol()) + " - " + _aEmbComp[_i, 1],,,, 0,,,, .F.)
	Next
	
	IncLine()

	ChkPgBreak(9)

	ImpLine(cSpace001 + "CARGA COMPLETA: (  ) SIM   (  ) NAO",,,, 2,,,, .T.)
	ImpLine(cSpace001 + "CONFERENTE (Nome) : ___________________________________ Ass.:_________________",,,, 2,,,, .T.)
	ImpLine(cSpace001 + "DATA CONFERENCIA : ____/____/_______ HORA FINALIZACAO : ____________"          ,,,, 2,,,, .T.)
	ImpLine(cSpace001 + "HORA DO RECEBIMENTO DO ROMANEIO PELO EXPEDIDOR: _________"                     ,,,, 2,,,, .T.)
	ImpLine(cSpace001 + "EXPEDIDOR: ____________________________________________ Ass.:_________________",,,, 2,,,, .T.)

	IncLine()

	ImpLine(cSpace001 + "HORA DO INICIO DO CARREGAMENTO: " + cULine005 + ":" + cULine005,,,, 2,,,, .T.)
	ImpLine(cSpace001 + "HORA DO FINAL  DO CARREGAMENTO: " + cULine005 + ":" + cULine005,,,, 2,,,, .T.)
	ImpLine(cSpace001 + "DURACAO DO CARREGAMENTO.......: " + cULine005 + ":" + cULine005,,,, 2,,,, .T.)

	SetPageBreak()
	
	nTotEsp := 0
	nTotPec := 0
	nTotPes := 0
ElseIf nTipo == 2
	IncLine(2)
	nTotEsp := 0
	nTotPec := 0
	nTotPes := 0
	
	__lPid := .F.
	__lNPid := .F.
	
	If	mv_par01	< '5' .And.	mv_par02	> '5'

		__cQuery	:=	" SELECT (CASE WHEN SUBSTR(ZQ_EMBARQ,1,1) < '5' THEN COUNT(ZQ_EMBARQ) ELSE 0 END) PID, "
		__cQuery	+=	" (CASE WHEN SUBSTR(ZQ_EMBARQ,1,1) > '5' THEN COUNT(ZQ_EMBARQ) ELSE 0 END) NPID "

		__cQuery	+=	" FROM SIGA." + cSZQTable + " WHERE ZQ_FILIAL = '" + cSZQFilial + "' AND D_E_L_E_T_ = ' ' AND SUBSTR(ZQ_EMBARQ,2,5) = '" + AllTrim(cEmb) + "' GROUP BY ZQ_EMBARQ "
		
		#IFDEF ORTOBOM_DEBUG
			MemoWrit("C:\TEMB.SQL", __cQuery)
		#ENDIF	
		
		dbQuery(__cQuery,"TEMB")

		While TEMB->(!Eof())
			If TEMB->PID > 0
				__lPid := .T.
			ElseIf TEMB->NPID > 0
				__lNPid := .T.
			EndIf
			TEMB->(DbSkip())
		End

	ElseIf mv_par01 < '5' .And. mv_par02 < '5'
		__lPid	:=	.T.
	ElseIf mv_par01 >	'5' .And. mv_par02 >	'5'
		__lNPid :=	.T.
	EndIf
	
	ChkPgBreak(8)

	If	!__lPid	.And.	__lNPid
		oPrn:Say(nLin,0010,"NUM. CARGA: " + AllTrim(Str(Val(cPid) + 5)) + AllTrim(cEmb),oFont)
	Else
		oPrn:Say(nLin,0010,"NUM. CARGA: " + AllTrim(cPid) + AllTrim(cEmb),oFont)
	EndIf

	//ImpLine(cSpace030 + "      DATA EMBARQUE: " + SubStr(QRY->ZQ_DTPREVE, 7, 2) + "/" + SubStr(QRY->ZQ_DTPREVE, 5, 2) + "/" + SubStr(QRY->ZQ_DTPREVE, 1, 4),,,, 0,,,, .F.)
	ImpLine(cSpace030 + "      DATA PREV. EMBARQUE: " + SubStr(QRY->ZQ_DTPREVE, 7, 2) + "/" + SubStr(QRY->ZQ_DTPREVE, 5, 2) + "/" + SubStr(QRY->ZQ_DTPREVE, 1, 4),,,, 0,,,, .F.)

	IncLine(2)

	ImpLine(cSpace001 + "CODIGO",,,, 0,,,, .F.)
	ImpLine(cSpace020 + "DENOMINACAO",,,, 0,,,, .F.)
	ImpLine(cSpace031 + "SM",,,, 0,,,, .F.)
	ImpLine(cSpace052 + "MEDIDAS",,,, 0,,,, .F.)
	ImpLine(cSpace057 + "QUANT.",,,, 1,,,, .F.)
	//ImpLine(cSpace052 + "        UM",,,, 1,,,, .F.)

	IncLine(2)	

EndIf

If MV_PAR08==2

	nLin:=4000
	lFim := .F.
	ImpCab()
	ImpCabec()
	//IMPRIME OS DADOS DA LINHA DE DETALHES
    
	// ssi 5711
	if cEmpAnt == "24"    
	    		
		cRDesc	:= Alltrim(Posicione("SA1",nA1OrdCGC,cSA1Filial+cCGC2PG,"A1_NOME"))
		cRCOD	:= Alltrim(Posicione("SA1",nA1OrdCGC,cSA1Filial+cCGC2PG,"A1_COD"))					
		ImpLine(cSpace001+"CLIENTE:  : " + cRCOD + " - " + cRDesc  ,,,, 0,,,, .F.)
		IncLine(2)
	endif
	
	
	For nCont := 1 To Len(aCab1)
		oPrn:Say(nLin+(LINE_HEIGHT/2),aBox1[nCont]+10, TRANSFORM((aCab1[nCont]), "@!"), oFontdet,,,, 0)
		oPrn:Box(nLin,aBox1[nCont], nLin+(LINE_HEIGHT+(LINE_HEIGHT/2)), aBox1[nCont+1])
	Next
	nLin+=LINE_HEIGHT+(LINE_HEIGHT/2)
	For nCont := 1 To Len(aCab2)
		oPrn:Say(nLin+(LINE_HEIGHT/2),aBox2[nCont]+10, TRANSFORM((aCab2[nCont]), "@!"), oFontdet,,,, 0)
		oPrn:Box(nLin,aBox2[nCont], nLin+(LINE_HEIGHT+(LINE_HEIGHT/2)), aBox2[nCont+1])
	Next
	While nLin+LINE_HEIGHT < nMaxV
		nLin+=LINE_HEIGHT+(LINE_HEIGHT/2)
		For nCont := 1 To Len(aCab2)
			oPrn:Box(nLin,aBox2[nCont], nLin+(LINE_HEIGHT+(LINE_HEIGHT/2)), aBox2[nCont+1])
		Next
	End

EndIf
	
Return

//
Static Function ImpCabec()

oPrn:Box(nLin,0005,nLin+200,2330)
IncLine()
oPrn:Say(nLin,0010,"HORA: " + Time() + " - (" + Nomeprog + ")",oFont2)
oPrn:Say(nLin,2015,"No FOLHA: " + strzero(nPag,3,0),oFont2)

IncLine()
oPrn:Say(nLin,1000,titulo,oFont2)

oPrn:Say(nLin,0010,"EMPRESA: "+CEMPANT + " / Filial: " + substr(cNomFil,1,2),oFont2)
oPrn:Say(nLin,1925,"EMISSAO: "+dtoc(ddatabase),oFont2)
IncLine(2)

/*	oPrn:Say(nlin,0010,"USUARIO               : GERENCIA FINANCEIRA, ACERTO, CAIXA.",oFont1)
	nLin += nEsp
	oPrn:Say(nlin,0010,"OBJETIVO               : ACOMPANHAR DIARIAMENTE O ACERTO DAS CARGAS, FECHAMENTO DOS MOVIMENTOS E PRAZO DO RECEBIMENTO.",oFont1)
	nLin += nEsp
	oPrn:Say(nlin,0010,"PERIODO DE UTILIZACAO  : DIARIO.",oFont1)	
	nLin += nEsp*2*/


oPrn:Line(nLin,0005,nLin,2300)

oPrn:Say(nlin,0010,"USUARIO                : ENCARREGADO DE ACERTO, SEPARADORES E EXPEDIDORES.",oFont2)
IncLine()
oPrn:Say(nlin,0010,"OBJETIVO               : ACOMPANHAR O CARREGAMENTO DOS PRODUTOS VERIFICANDO SE NÃO HOUVE FALTA.",oFont2)
IncLine()
oPrn:Say(nlin,0010,"PERIODO DE UTILIZAÇÃO  : DIÁRIO.",oFont2)	
IncLine()

//	ImpLine(cSpace001 + "DATA CONFERENCIA : ____/____/_______ HORA FINALIZACAO : ____________"          ,,,, 2,,,, .T.)
IncLine()
oPrn:Line(nLin,0005,nLin,2300)
IncLine()

cHEmissao := "HORA EMISSAO: " + Time()

ImpLine(cSpace001 + "RQO - 09/004",,,, 1,,,, .T.)
//ImpLine(cSpace001 + "RQO - 09/004" + Iif(lSTerceiros, cSpace009, cSpace014) + " ROMANEIO DE CARGAS INTERNO" + IIf(lSTerceiros, " - TERCEIRIZADO", "") + IIf(lSTerceiros, cSpace006, cSpace017) + "PAG.: " + StrZero(nPag, 3),,,, 1,,,, .T.)

__lPid := .F.
__lNPid := .F.

If	mv_par01	< '5' .And.	mv_par02	> '5'
	__cQuery	:=	" SELECT (CASE WHEN SUBSTR(ZQ_EMBARQ,1,1) < '5' THEN COUNT(ZQ_EMBARQ) ELSE 0 END) PID, "
	__cQuery	+=	" (CASE WHEN SUBSTR(ZQ_EMBARQ,1,1) > '5' THEN COUNT(ZQ_EMBARQ) ELSE 0 END) NPID "
	__cQuery	+=	" FROM SIGA." + cSZQTable + " WHERE ZQ_FILIAL = '" + cSZQFilial + "' AND D_E_L_E_T_ = ' ' AND SUBSTR(ZQ_EMBARQ,2,5) = '" + AllTrim(cEmb) + "' GROUP BY ZQ_EMBARQ "

	#IFDEF ORTOBOM_DEBUG
		MemoWrit("C:\TEMB.SQL", __cQuery)
	#ENDIF	

	dbQuery(__cQuery,"TEMB")

	While TEMB->(!Eof())
		If TEMB->PID > 0
			__lPid :=	.T.
		ElseIf TEMB->NPID > 0
			__lNPid :=	.T.
		EndIf
		TEMB->(DbSkip())
	End

ElseIf mv_par01 <	'5' .And. mv_par02 <	'5'
	__lPid :=	.T.
ElseIf mv_par01 >	'5' .And. mv_par02 >	'5'
	__lNPid :=	.T.
EndIf

//ImpLine(cSpace001 + "DATA EMISSAO: " + Dtoc(dDataBase) + " - " + cHEmissao + " - " + "DATA EMBARQUE: " + SubStr(QRY->ZQ_DTPREVE, 7, 2) + "/" + SubStr(QRY->ZQ_DTPREVE, 5, 2) + "/" + SubStr(QRY->ZQ_DTPREVE, 1, 4),,,, 0,,,, .F.)
ImpLine(cSpace001 + "DATA EMISSAO: " + Dtoc(dDataBase) + " - " + cHEmissao + " - " + "DATA PREV. EMBARQUE: " + SubStr(QRY->ZQ_DTPREVE, 7, 2) + "/" + SubStr(QRY->ZQ_DTPREVE, 5, 2) + "/" + SubStr(QRY->ZQ_DTPREVE, 1, 4),,,, 0,,,, .F.)
IncLine()
If	!__lPid	.And.	__lNPid	
	ImpLine(cSpace001 + "NUM. CARGA: " + AllTrim(Str(Val(cPid) + 5)) + AllTrim(cEmb),,,, 0,,,, .F.)
Else
	ImpLine(cSpace001 + "NUM. CARGA: " + AllTrim(cPid) + AllTrim(cEmb),,,, 0,,,, .F.)
EndIf
IncLine(2)

If !lFim
	oprn:Say(nLin,0010,"CODIGO",oFont)
	oprn:Say(nLin,0230,"DENOMINACAO",oFont)
	oprn:Say(nLin,0840,"SM",oFont)
	oprn:Say(nLin,0900,"MEDIDAS",oFont)
	if cEmpAnt=="24"
		oprn:Say(nLin,1300,"SANFONA",oFont)
	EndIf
	oprn:Say(nLin,1350,"QUANT.",oFont)
	oprn:Say(nLin,1550,"UM",oFont)
	oprn:Say(nLin,1700,"QTD_2UM",oFont)
	//oprn:Say(nLin,1690,"2UM",oFont)

	oprn:Say(nLin,2000,"VLR UNIT",oFont)
	oprn:Say(nLin,2200,"TOTAL",oFont)	

	IncLine()
Endif

Return
                 

/* ====================================================== *
* Rotina: ImpCab | Autor: Bruno Azevedo | Data: 28/11/11 *
* ------------------------------------------------------ *
* Desc. : Imprime cabeçalho do relatório corrente.       *
* ====================================================== */
Static Function ImpCab()

Local lRet := ImpBreak()

If (lRet)
	oPrn:EndPage()
	oPrn:StartPage()
	nPag := oPrn:Page()
	nLin := oPrn:Row()
	IncLine(1,.F.)
EndIf

Return(lRet)

Static Function ImpBreak()
Return( ( nLin+LINE_HEIGHT >= nMaxV ) )

Static Function SetPageBreak()
	IncLine(nMaxV+1,.F.)
Return( ImpBreak() )

/*
======================================================= *
* Rotina: ImpLine | Autor: Bruno Azevedo | Data: 29/11/11 *
* ------------------------------------------------------- *
* Desc. : Engine de impressão de linhas, controlando as   *
*         quebras necessárias por registro impresso.      *
* ======================================================= */
/* Alt...: Bruno Azevedo                  | Data: 01/12/11 *
* ------------------------------------------------------- *
* Desc. : Melhorias necessárias para o relatório corrente *
========================================================
*/
Static Function ImpLine(uLinePrt, oFontPrt, nNewLine, nMaxLine, nAlign, nPosH, uBrush, lBreak, lQuebra)

Local lRet := .T.
Local nTmpLins := 0
Local nLines := 0
Local nIdx := 0
Local nPrt := 0
Local cLinType := ''
Local aLinePrt := {}
Local aBrush := {}
Local nLinePrt

Static __uBrush

Default uLinePrt := {}
Default oFontPrt := oFont
Default nNewLine := 1
Default lBreak := .F.
Default nMaxLine := IIf(oPrn:GetOrientation() == 1, 110, 150)
Default nAlign := AL_LEFT
Default nPosH := 0

IF ( uBrush == NIL )
	IF ( __uBrush == NIL )
		__uBrush   	:= { TBrush():New( NIL , CLR_WHITE ) , TBrush():New( NIL , RGB(225,225,225) ) }
	EndIF
	uBrush   		:= __uBrush
EndIF

cLinType := ValType(uLinePrt)
aLinePrt := IIf(cLinType == "A", uLinePrt, {uLinePrt})
nLinePrt := Len(aLinePrt)
aBrush   := IIf(ValType(uBrush) == "A", uBrush, {uBrush})

For nPrt := 1 To nLinePrt
	nTmpLins := MlCount(aLinePrt[nPrt], IIf(lBreak, nMaxLine, Len(aLinePrt[nPrt])))
	nLines := IIf(nLines >= nTmpLins, nLines, nTmpLins)
Next

For nIdx := 1 To nLines
	If (lBreak)
		oPrn:FillRect({(nLin - 3), 0, ((nLinePrt*LINE_HEIGHT) + nLin), nMaxH}, aBrush[(2 - Mod(nIdx, 2))])
	EndIf
	For nPrt := 1 To nLinePrt
		oPrn:Say(nLin, nPosH, MemoLine(aLinePrt[nPrt], IIf(lBreak, nMaxLine, Len(aLinePrt[nPrt])), nIdx), oFontPrt,, CLR_BLACK,, nAlign)
		If (lQuebra)
			IncLine()
		EndIf
	Next
Next

IncLine((LINE_HEIGHT*(nNewLine-1)))

IF .NOT.( uBrush == __uBrush )
	For nIdx := 1 To Len(aBrush)
	    aBrush[nIdx]:End()
	Next nIdx
EndIF

Return(lRet)  

Static Function ChkPgBreak(nLPrn)
	DEFAULT nLPrn := 0
	IF ((nLin+(LINE_HEIGHT*nLPrn))>=(nMaxV-nLPrn))
		SetPageBreak()
	EndIF
	IF ( ImpCab() )
		ImpCabec()
	EndIF
Return( NIL )

Static Function IncLine( nLines , lChkPgBreak )
	DEFAULT nLines 		:= 1
	DEFAULT lChkPgBreak	:= .T.
	nLin+=(LINE_HEIGHT*nLines)
	IF ( lChkPgBreak )
		ChkPgBreak()
	EndIF	
Return(nLin)

//Chamada a TCQuery com verificação de Area em uso
Static Function dbQuery( cQuery , cAlias )
	IF ( Select( @cAlias ) > 0 )
		( cAlias )->( dbCloseArea() )
	EndIF
	TCQUERY ( cQuery ) ALIAS ( cAlias ) NEW
	IF ( aScan( aAliasTmp , { |e| ( e == cAlias ) } ) == 0 )
		aAdd( aAliasTmp , cAlias )
	EndIF	
Return( .NOT.( ( cAlias )->( Bof() .and. Eof() ) ) )

/*
	Programa	: ORTR021
	Funcao		: ValidPerg
	Autor		: Marinaldo de Jesus [http://www.blacktdn.com.br]
	Data		: 02/07/2012
	Descrição	: Verifica as Perguntas a serem utilizadas no Programa
	Sintaxe		: Chamada padrao para programas em "RdMake".
	Uso			: Generico
	Obs.		: 

-------------------------------------------------------------------------
			ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             
-------------------------------------------------------------------------
Programador		|Data      |Motivo Alteracao
-------------------------------------------------------------------------
                |DD/MM/YYYY|
-------------------------------------------------------------------------*/
Static Function ValidPerg(cPerg,lShowPerg)

	Local aPerg		:= Array(0)
	Local aGrpSXG


	Local cOrdem	:= Replicate("0", Len( SX1->X1_ORDEM ) )
	Local cGRPSXG	:= ""

	Local cX1Tipo
	Local cPicSXG

	Local cMvCH		:= "MV_CH0"
	Local cMVPar	:= "MV_PAR00" 

	Local nTamSXG	:= 0
	Local nDecSXG	:= 0

	cPerg			:= Padr( cPerg , Len( SX1->X1_GRUPO ) )

	//01 - "Da Carga........:?"
	cOrdem		:= __Soma1( cOrdem )
	cMvCH		:= __Soma1( cMvCH )
	cMVPar		:= __Soma1( cMVPar )
	cGRPSXG		:= ""
	aGRPSXG		:= SXGSize(cGRPSXG,X3Tamanho("ZQ_EMBARQ"),X3Decimal("ZQ_EMBARQ"),X3Picture("ZQ_EMBARQ"))
	nTamSXG		:= aGRPSXG[1]
	nDecSXG		:= aGRPSXG[2]
	cPicSXG		:= aGRPSXG[3]
	cX1Tipo		:= X3Tipo("ZQ_EMBARQ")
	AddPerg(@aPerg,cPerg,cOrdem,"X1_PERGUNT","Da Carga........:?")
	AddPerg(@aPerg,cPerg,cOrdem,"X1_VARIAVL",cMvCH)
	AddPerg(@aPerg,cPerg,cOrdem,"X1_TIPO",cX1Tipo)
	AddPerg(@aPerg,cPerg,cOrdem,"X1_TAMANHO",nTamSXG)
	AddPerg(@aPerg,cPerg,cOrdem,"X1_DECIMAL",nDecSXG)
	AddPerg(@aPerg,cPerg,cOrdem,"X1_GSC","G")
	AddPerg(@aPerg,cPerg,cOrdem,"X1_VAR01",cMVPar)
	AddPerg(@aPerg,cPerg,cOrdem,"X1_F3","SZQ")
	AddPerg(@aPerg,cPerg,cOrdem,"X1_PYME","S")
	AddPerg(@aPerg,cPerg,cOrdem,"X1_GRPSXG",cGRPSXG)
	AddPerg(@aPerg,cPerg,cOrdem,"X1_PICTURE",cPicSXG)

	//02 - "Ate Carga........:?"
	cOrdem		:= __Soma1( cOrdem )
	cMvCH		:= __Soma1( cMvCH )
	cMVPar		:= __Soma1( cMVPar )
	cGRPSXG		:= ""
	aGRPSXG		:= SXGSize(cGRPSXG,X3Tamanho("ZQ_EMBARQ"),X3Decimal("ZQ_EMBARQ"),X3Picture("ZQ_EMBARQ"))
	nTamSXG		:= aGRPSXG[1]
	nDecSXG		:= aGRPSXG[2]
	cPicSXG		:= aGRPSXG[3]
	cX1Tipo		:= X3Tipo("ZQ_EMBARQ")
	AddPerg(@aPerg,cPerg,cOrdem,"X1_PERGUNT","Ate Carga........:?")
	AddPerg(@aPerg,cPerg,cOrdem,"X1_VARIAVL",cMvCH)
	AddPerg(@aPerg,cPerg,cOrdem,"X1_TIPO",cX1Tipo)
	AddPerg(@aPerg,cPerg,cOrdem,"X1_TAMANHO",nTamSXG)
	AddPerg(@aPerg,cPerg,cOrdem,"X1_DECIMAL",nDecSXG)
	AddPerg(@aPerg,cPerg,cOrdem,"X1_GSC","G")
	AddPerg(@aPerg,cPerg,cOrdem,"X1_VAR01",cMVPar)
	AddPerg(@aPerg,cPerg,cOrdem,"X1_F3","SZQ")
	AddPerg(@aPerg,cPerg,cOrdem,"X1_PYME","S")
	AddPerg(@aPerg,cPerg,cOrdem,"X1_GRPSXG",cGRPSXG)
	AddPerg(@aPerg,cPerg,cOrdem,"X1_PICTURE",cPicSXG)

	//03 - "Data Carga......:?"
	cOrdem		:= __Soma1( cOrdem )
	cMvCH		:= __Soma1( cMvCH )
	cMVPar		:= __Soma1( cMVPar )
	cGRPSXG		:= ""
	aGRPSXG		:= SXGSize(cGRPSXG,X3Tamanho("ZQ_DTEMBAR"),X3Decimal("ZQ_DTEMBAR"),X3Picture("ZQ_DTEMBAR"))
	nTamSXG		:= aGRPSXG[1]
	nDecSXG		:= aGRPSXG[2]
	cPicSXG		:= aGRPSXG[3]
	cX1Tipo		:= X3Tipo("ZQ_DTEMBAR")
	AddPerg(@aPerg,cPerg,cOrdem,"X1_PERGUNT","Data Carga......:?")
	AddPerg(@aPerg,cPerg,cOrdem,"X1_VARIAVL",cMvCH)
	AddPerg(@aPerg,cPerg,cOrdem,"X1_TIPO",cX1Tipo)
	AddPerg(@aPerg,cPerg,cOrdem,"X1_TAMANHO",nTamSXG)
	AddPerg(@aPerg,cPerg,cOrdem,"X1_DECIMAL",nDecSXG)
	AddPerg(@aPerg,cPerg,cOrdem,"X1_GSC","G")
	AddPerg(@aPerg,cPerg,cOrdem,"X1_VAR01",cMVPar)
	AddPerg(@aPerg,cPerg,cOrdem,"X1_PYME","S")
	AddPerg(@aPerg,cPerg,cOrdem,"X1_GRPSXG",cGRPSXG)
	AddPerg(@aPerg,cPerg,cOrdem,"X1_PICTURE",cPicSXG)

	//04 - "Emite Valor ....:?"
	cOrdem		:= __Soma1( cOrdem )
	cMvCH		:= __Soma1( cMvCH )
	cMVPar		:= __Soma1( cMVPar )
	cGRPSXG		:= ""
	aGRPSXG		:= SXGSize(cGRPSXG,1,0,"")
	nTamSXG		:= aGRPSXG[1]
	nDecSXG		:= aGRPSXG[2]
	cPicSXG		:= aGRPSXG[3]
	cX1Tipo		:= "N"
	AddPerg(@aPerg,cPerg,cOrdem,"X1_PERGUNT","Emite Valor ....:?")
	AddPerg(@aPerg,cPerg,cOrdem,"X1_VARIAVL",cMvCH)
	AddPerg(@aPerg,cPerg,cOrdem,"X1_TIPO",cX1Tipo)
	AddPerg(@aPerg,cPerg,cOrdem,"X1_TAMANHO",nTamSXG)
	AddPerg(@aPerg,cPerg,cOrdem,"X1_DECIMAL",nDecSXG)
	AddPerg(@aPerg,cPerg,cOrdem,"X1_GSC","C")
	AddPerg(@aPerg,cPerg,cOrdem,"X1_VAR01",cMVPar)
	AddPerg(@aPerg,cPerg,cOrdem,"X1_DEF01","Nao")
	AddPerg(@aPerg,cPerg,cOrdem,"X1_DEF02","Sim")
	AddPerg(@aPerg,cPerg,cOrdem,"X1_PYME","S")
	AddPerg(@aPerg,cPerg,cOrdem,"X1_GRPSXG",cGRPSXG)
	AddPerg(@aPerg,cPerg,cOrdem,"X1_PICTURE",cPicSXG)

	//05 - "Somente Terceirizado?"
	cOrdem		:= __Soma1( cOrdem )
	cMvCH		:= __Soma1( cMvCH )
	cMVPar		:= __Soma1( cMVPar )
	cGRPSXG		:= ""
	aGRPSXG		:= SXGSize(cGRPSXG,1,0,"")
	nTamSXG		:= aGRPSXG[1]
	nDecSXG		:= aGRPSXG[2]
	cPicSXG		:= aGRPSXG[3]
	cX1Tipo		:= "N"
	AddPerg(@aPerg,cPerg,cOrdem,"X1_PERGUNT","Somente Terceirizado?")
	AddPerg(@aPerg,cPerg,cOrdem,"X1_VARIAVL",cMvCH)
	AddPerg(@aPerg,cPerg,cOrdem,"X1_TIPO",cX1Tipo)
	AddPerg(@aPerg,cPerg,cOrdem,"X1_TAMANHO",nTamSXG)
	AddPerg(@aPerg,cPerg,cOrdem,"X1_DECIMAL",nDecSXG)
	AddPerg(@aPerg,cPerg,cOrdem,"X1_GSC","C")
	AddPerg(@aPerg,cPerg,cOrdem,"X1_VAR01",cMVPar)
	AddPerg(@aPerg,cPerg,cOrdem,"X1_DEF01","Nao")
	AddPerg(@aPerg,cPerg,cOrdem,"X1_DEF02","Sim")
	AddPerg(@aPerg,cPerg,cOrdem,"X1_PYME","S")
	AddPerg(@aPerg,cPerg,cOrdem,"X1_GRPSXG",cGRPSXG)
	AddPerg(@aPerg,cPerg,cOrdem,"X1_PICTURE",cPicSXG)

	//06 - "Ordena por?"
	cOrdem		:= __Soma1( cOrdem )
	cMvCH		:= __Soma1( cMvCH )
	cMVPar		:= __Soma1( cMVPar )
	cGRPSXG		:= ""
	aGRPSXG		:= SXGSize(cGRPSXG,1,0,"")
	nTamSXG		:= aGRPSXG[1]
	nDecSXG		:= aGRPSXG[2]
	cPicSXG		:= aGRPSXG[3]
	cX1Tipo		:= "N"
	AddPerg(@aPerg,cPerg,cOrdem,"X1_PERGUNT","Ordena por?")
	AddPerg(@aPerg,cPerg,cOrdem,"X1_VARIAVL",cMvCH)
	AddPerg(@aPerg,cPerg,cOrdem,"X1_TIPO",cX1Tipo)
	AddPerg(@aPerg,cPerg,cOrdem,"X1_TAMANHO",nTamSXG)
	AddPerg(@aPerg,cPerg,cOrdem,"X1_DECIMAL",nDecSXG)
	AddPerg(@aPerg,cPerg,cOrdem,"X1_GSC","C")
	AddPerg(@aPerg,cPerg,cOrdem,"X1_VAR01",cMVPar)
	AddPerg(@aPerg,cPerg,cOrdem,"X1_DEF01","Codigo")
	AddPerg(@aPerg,cPerg,cOrdem,"X1_DEF02","Segmento")
	AddPerg(@aPerg,cPerg,cOrdem,"X1_DEF03","Rota")
	AddPerg(@aPerg,cPerg,cOrdem,"X1_PYME","S")
	AddPerg(@aPerg,cPerg,cOrdem,"X1_GRPSXG",cGRPSXG)
	AddPerg(@aPerg,cPerg,cOrdem,"X1_PICTURE",cPicSXG)

	//07 - "Quebra por CGC?"
	cOrdem		:= __Soma1( cOrdem )
	cMvCH		:= __Soma1( cMvCH )
	cMVPar		:= __Soma1( cMVPar )
	cGRPSXG		:= ""
	aGRPSXG		:= SXGSize(cGRPSXG,1,0,"")
	nTamSXG		:= aGRPSXG[1]
	nDecSXG		:= aGRPSXG[2]
	cPicSXG		:= aGRPSXG[3]
	cX1Tipo		:= "N"
	AddPerg(@aPerg,cPerg,cOrdem,"X1_PERGUNT","Quebra por CGC?")
	AddPerg(@aPerg,cPerg,cOrdem,"X1_VARIAVL",cMvCH)
	AddPerg(@aPerg,cPerg,cOrdem,"X1_TIPO",cX1Tipo)
	AddPerg(@aPerg,cPerg,cOrdem,"X1_TAMANHO",nTamSXG)
	AddPerg(@aPerg,cPerg,cOrdem,"X1_DECIMAL",nDecSXG)
	AddPerg(@aPerg,cPerg,cOrdem,"X1_GSC","C")
	AddPerg(@aPerg,cPerg,cOrdem,"X1_VAR01",cMVPar)
	AddPerg(@aPerg,cPerg,cOrdem,"X1_DEF01","Nao")
	AddPerg(@aPerg,cPerg,cOrdem,"X1_DEF02","Sim")
	AddPerg(@aPerg,cPerg,cOrdem,"X1_PYME","S")
	AddPerg(@aPerg,cPerg,cOrdem,"X1_GRPSXG",cGRPSXG)
	AddPerg(@aPerg,cPerg,cOrdem,"X1_PICTURE",cPicSXG)

	//08 - "Imprime grade ?"
	cOrdem		:= __Soma1( cOrdem )
	cMvCH		:= __Soma1( cMvCH )
	cMVPar		:= __Soma1( cMVPar )
	cGRPSXG		:= ""
	aGRPSXG		:= SXGSize(cGRPSXG,1,0,"")
	nTamSXG		:= aGRPSXG[1]
	nDecSXG		:= aGRPSXG[2]
	cPicSXG		:= aGRPSXG[3]
	cX1Tipo		:= "N"
	AddPerg(@aPerg,cPerg,cOrdem,"X1_PERGUNT","Imprime grade ?")
	AddPerg(@aPerg,cPerg,cOrdem,"X1_VARIAVL",cMvCH)
	AddPerg(@aPerg,cPerg,cOrdem,"X1_TIPO",cX1Tipo)
	AddPerg(@aPerg,cPerg,cOrdem,"X1_TAMANHO",nTamSXG)
	AddPerg(@aPerg,cPerg,cOrdem,"X1_DECIMAL",nDecSXG)
	AddPerg(@aPerg,cPerg,cOrdem,"X1_GSC","C")
	AddPerg(@aPerg,cPerg,cOrdem,"X1_VAR01",cMVPar)
	AddPerg(@aPerg,cPerg,cOrdem,"X1_DEF01","Nao")
	AddPerg(@aPerg,cPerg,cOrdem,"X1_DEF02","Sim")
	AddPerg(@aPerg,cPerg,cOrdem,"X1_PYME","S")
	AddPerg(@aPerg,cPerg,cOrdem,"X1_GRPSXG",cGRPSXG)
	AddPerg(@aPerg,cPerg,cOrdem,"X1_PICTURE",cPicSXG)

	PutSX1(@cPerg,@aPerg)

Return(Pergunte(cPerg,lShowPerg))

/*
	Programa	: ORTR021
	Funcao		: PutSX1
	Autor		: Marinaldo de Jesus [http://www.blacktdn.com.br]
	Data		: 02/07/2012
	Descrição	: Adiciona e/ou Remove Perguntas utilizadas no Programa
	Sintaxe		: Chamada padrao para programas em "RdMake".
	Uso			: Generico
	Obs.		: 

-------------------------------------------------------------------------
			ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             
-------------------------------------------------------------------------
Programador		|Data      |Motivo Alteracao
-------------------------------------------------------------------------
                |DD/MM/YYYY|
-------------------------------------------------------------------------*/
Static Procedure PutSX1(cPerg,aPerg)

	Local cKeySeek

	Local lFound
	Local lAddNew

	Local nBL
	Local nEL		:= Len( aPerg )

	Local nAT
	Local nField
	Local nFields
	Local nAtField

	Local __nGrupo	:= 1
	Local __nOrdem	:= 2
	Local __nField	:= 3

	Local uCNT

	SX1->( dbSetOrder( 1 ) ) //X1_GRUPO+X1_ORDEM

	cPerg			:= Padr( cPerg , Len( SX1->X1_GRUPO ) )

	SX1->( dbGoTop() )
	SX1->( dbSeek( cPerg , .F. ) )

	While SX1->( !Eof() .and. X1_GRUPO == cPerg )
		nAT 		:= SX1->( aScan( aPerg , { |x| (  ( x[__nGrupo] == X1_GRUPO ) .and. ( x[__nOrdem] == X1_ORDEM ) ) } ) )
		lFound	:= ( nAT > 0 )
		IF !( lFound )
			IF SX1->( RecLock( "SX1" , .F. ) )	
				SX1->( dbDelete() )
				SX1->( MsUnLock() )
			EndIF
		EndIF
		SX1->( dbSkip() )
	End While

	For nBL := 1 To nEL
		cKeySeek	:= aPerg[nBL][__nGrupo]
		cKeySeek	+= aPerg[nBL][__nOrdem]
		lFound	:= SX1->( dbSeek( cKeySeek , .T. ) )
		lAddNew	:= !( lFound )
		IF SX1->( RecLock( "SX1" , lAddNew ) )
			nFields := Len( aPerg[nBL][__nField] )
			For nField := 1 To nFields
				nAtField := aPerg[nBL][__nField][nField][4]
				lChange	:= ( aPerg[nBL][__nField][nField][3] .and. ( nAtField > 0 ) )
				IF ( lChange )
					uCNT	:= aPerg[nBL][__nField][nField][2]
					SX1->( FieldPut( nAtField , uCNT ) )
				EndIF
			Next nField
			SX1->( MsUnLock() )
		EndIF
	Next nBL

Return

/*
	Programa	: ORTR021
	Funcao		: AddPerg
	Autor		: Marinaldo de Jesus [http://www.blacktdn.com.br]
	Data		: 02/07/2012
	Descrição	: Adiciona Informacoes do compo
	Sintaxe		: Chamada padrao para programas em "RdMake".
	Uso			: Generico
	Obs.		: 

-------------------------------------------------------------------------
			ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             
-------------------------------------------------------------------------
Programador		|Data      |Motivo Alteracao
-------------------------------------------------------------------------
                |DD/MM/YYYY|
-------------------------------------------------------------------------*/
Static Procedure AddPerg(aPerg,cGrupo,cOrdem,cField,uCNT)

	Local bEval

	Local nAT
	Local nATField

	Local __nGrupo	:= 1
	Local __nOrdem	:= 2
	Local __nField	:= 3

	Static aX1Fields
	Static __cX1Fields

	IF !( Type("cEmpAnt") == "C" )
		Private cEmpAnt := ""
	EndIF

	IF ( ( aX1Fields == NIL ) .or. !( __cX1Fields == cEmpAnt ) )
		__cX1Fields := cEmpAnt
		aX1Fields	:= {;
									{ "X1_GRUPO" 	, NIL , .T. , 0 },;
									{ "X1_ORDEM" 	, NIL , .T. , 0 },;
									{ "X1_PERGUNT"	, NIL , .T. , 0 },;
									{ "X1_PERSPA" 	, NIL , .T. , 0 },;
									{ "X1_PERENG" 	, NIL , .T. , 0 },;
									{ "X1_VARIAVL"	, NIL , .T. , 0 },;
									{ "X1_TIPO" 	, NIL , .T. , 0 },;
									{ "X1_TAMANHO" 	, NIL , .T. , 0 },;
									{ "X1_DECIMAL" 	, NIL , .T. , 0 },;
									{ "X1_PRESEL" 	, NIL , .F. , 0 },;
									{ "X1_GSC" 		, NIL , .T. , 0 },;
									{ "X1_VALID" 	, NIL , .T. , 0 },;
									{ "X1_VAR01" 	, NIL , .T. , 0 },;
									{ "X1_DEF01" 	, NIL , .T. , 0 },;
									{ "X1_DEFSPA1" 	, NIL , .T. , 0 },;
									{ "X1_DEFENG1" 	, NIL , .T. , 0 },;
									{ "X1_CNT01" 	, NIL , .F. , 0 },;
									{ "X1_VAR02" 	, NIL , .T. , 0 },;
									{ "X1_DEF02" 	, NIL , .T. , 0 },;
									{ "X1_DEFSPA2" 	, NIL , .T. , 0 },;
									{ "X1_DEFENG2" 	, NIL , .T. , 0 },;
									{ "X1_CNT02" 	, NIL , .F. , 0 },;
									{ "X1_VAR03" 	, NIL , .T. , 0 },;
									{ "X1_DEF03" 	, NIL , .T. , 0 },;
									{ "X1_DEFSPA3" 	, NIL , .T. , 0 },;
									{ "X1_DEFENG3" 	, NIL , .T. , 0 },;
									{ "X1_CNT03" 	, NIL , .F. , 0 },;
									{ "X1_VAR04" 	, NIL , .T. , 0 },;
									{ "X1_DEF04" 	, NIL , .T. , 0 },;
									{ "X1_DEFSPA4" 	, NIL , .T. , 0 },;
									{ "X1_DEFENG4" 	, NIL , .T. , 0 },;
									{ "X1_CNT04" 	, NIL , .F. , 0 },;
									{ "X1_VAR05" 	, NIL , .T. , 0 },;
									{ "X1_DEF05" 	, NIL , .T. , 0 },;
									{ "X1_DEFSPA5" 	, NIL , .T. , 0 },;
									{ "X1_DEFENG5" 	, NIL , .T. , 0 },;
									{ "X1_CNT05" 	, NIL , .F. , 0 },;
									{ "X1_F3" 		, NIL , .T. , 0 },;
									{ "X1_PYME" 	, NIL , .T. , 0 },;
									{ "X1_GRPSXG" 	, NIL , .T. , 0 },;
									{ "X1_HELP" 	, NIL , .T. , 0 },;
									{ "X1_PICTURE" 	, NIL , .T. , 0 },;
									{ "X1_IDFIL" 	, NIL , .T. , 0 };
							}

			bEval := { |x,y|;
									nATField 		:= FieldPos(aX1Fields[y][1]),;
									aX1Fields[y][2]	:= GetValType(ValType(FieldGet(nATField))),;
									aX1Fields[y][4]	:= nATField,;
			         }
 		
			SX1->(aEval(aX1Fields,bEval))

		EndIf

		nAT := aScan( aPerg , { |x| ( ( x[1] == cGrupo ) .and. ( x[2] == cOrdem ) ) } ) 

		IF ( nAT == 0 )
			aAdd( aPerg , { cGrupo , cOrdem , aClone( aX1Fields ) } )
			nAT := Len( aPerg )
		EndIF

		cField		:= Upper( AllTrim( cField ) )
		nATField	:= aScan( aPerg[nAT][3] , { |e| ( e[1] == cField ) } )

		IF ( nATField > 0 )

			aPerg[nAT][__nField][nATField][2]	:= uCNT

			nATField	:= aScan( aPerg[nAT][3] , { |e| ( e[1] == "X1_GRUPO" ) } )
			IF ( nATField > 0 )
				aPerg[nAT][__nField][nATField][2]	:= cGrupo
			EndIF

			nATField	:= aScan( aPerg[nAT][3] , { |e| ( e[1] == "X1_ORDEM" ) } )
			IF ( nATField > 0 )
				aPerg[nAT][__nField][nATField][2]	:= cOrdem
			EndIF	

		EndIF

Return

/*
	Programa	: ORTR021
	Funcao		: SXGSize
	Autor		: Marinaldo de Jesus [http://www.blacktdn.com.br]
	Data		: 02/07/2012
	Descrição	: Obtem Informações do Grupo em SXG (Size e Picture)
	Sintaxe		: Chamada padrao para programas em "RdMake".
	Uso			: Generico
	Obs.		: 

-------------------------------------------------------------------------
			ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             
-------------------------------------------------------------------------
Programador		|Data      |Motivo Alteracao
-------------------------------------------------------------------------
                |DD/MM/YYYY|
-------------------------------------------------------------------------*/
Static Function SXGSize( cGRPSXG , nSize , nDec , cPicture )

	Local cSXGPict

	Local nSXGDec
	Local nSXGSize

	DEFAULT nSize		:= 0
	DEFAULT nDec		:= 0
	DEFAULT cPicture	:= ""

	IF !Empty( cGRPSXG )

		SXG->( dbSetOrder( 1 ) ) //XG_GRUPO
		
		lFound			:= SXG->( MsSeek( cGRPSXG , .F. ) )
		
		IF ( lFound )
			nSXGSize	:= SXG->XG_SIZE
			cSXGPict	:= SXG->XG_PICTURE	
		Else
			cSXGPict	:= cPicture
			nSXGSize	:= nSize
		EndIF
		
		nSXGDec			:= nDec

	Else

		nSXGSize		:= nSize
		nSXGDec			:= nDec
		cSXGPict		:= cPicture

	EndIF

Return( { nSXGSize , nSXGDec , cSXGPict } )

/*
	Programa	: ORTR021
	Funcao		: X3Tamanho()
	Autor		: Marinaldo de Jesus [http://www.blacktdn.com.br]
	Data		: 02/07/2012
	Descrição	: Obtem o Tamanho do campo 
	Sintaxe		: Chamada padrao para programas em "RdMake".
	Uso			: Generico
	Obs.		: 

-------------------------------------------------------------------------
			ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             
-------------------------------------------------------------------------
Programador		|Data      |Motivo Alteracao
-------------------------------------------------------------------------
                |DD/MM/YYYY|
-------------------------------------------------------------------------*/
Static Function X3Tamanho(cField)
	Local nTamanho		:= GetSx3Cache(@cField,"X3_TAMANHO")
	DEFAULT nTamanho	:= 0
Return(nTamanho)

/*
	Programa	: ORTR021
	Funcao		: X3Decimal()
	Autor		: Marinaldo de Jesus [http://www.blacktdn.com.br]
	Data		: 02/07/2012
	Descrição	: Obtem a Decimal do campo 
	Sintaxe		: Chamada padrao para programas em "RdMake".
	Uso			: Generico
	Obs.		: 

-------------------------------------------------------------------------
			ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             
-------------------------------------------------------------------------
Programador		|Data      |Motivo Alteracao
-------------------------------------------------------------------------
                |DD/MM/YYYY|
-------------------------------------------------------------------------*/
Static Function X3Decimal(cField)
	Local nDecimal		:= GetSx3Cache(@cField,"X3_DECIMAL")
	DEFAULT nDecimal	:= 0
Return(nDecimal)

/*
	Programa	: ORTR021
	Funcao		: X3Picture
	Autor		: Marinaldo de Jesus [http://www.blacktdn.com.br]
	Data		: 02/07/2012
	Descrição	: Obtem a Picture do Campo
	Sintaxe		: Chamada padrao para programas em "RdMake".
	Uso			: Generico
	Obs.		: 

-------------------------------------------------------------------------
			ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             
-------------------------------------------------------------------------
Programador		|Data      |Motivo Alteracao
-------------------------------------------------------------------------
                |DD/MM/YYYY|
-------------------------------------------------------------------------*/
Static Function X3Picture(cField)
	Local cPicture		:= GetSx3Cache(@cField,"X3_PICTURE")
	DEFAULT cPicture	:= ""
	cPicture			:= AllTrim(cPicture)
Return(cPicture)

/*
	Programa	: ORTR021
	Funcao		: X3Picture
	Autor		: Marinaldo de Jesus [http://www.blacktdn.com.br]
	Data		: 02/07/2012
	Descrição	: Obtem a Picture do Campo
	Sintaxe		: Chamada padrao para programas em "RdMake".
	Uso			: Generico
	Obs.		: 

-------------------------------------------------------------------------
			ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             
-------------------------------------------------------------------------
Programador		|Data      |Motivo Alteracao
-------------------------------------------------------------------------
                |DD/MM/YYYY|
-------------------------------------------------------------------------*/
Static Function X3Tipo(cField)
	Local cTipo			:= GetSx3Cache(cField,"X3_TIPO")
	DEFAULT cTipo		:= ""
	cTipo				:= AllTrim(cTipo)
Return(cTipo)
