#Include "FINR470.CH"
#include "PROTHEUS.CH"
#DEFINE REC_NAO_CONCILIADO	1
#DEFINE REC_CONCILIADO		2
#DEFINE PAG_NAO_CONCILIADO	3
#DEFINE PAG_CONCILIADO		4

Static lFWCodFil := .T.
Static lE5TXMoeda
Static cSM0Leiaute	:= ALLTRIM(FWSM0Layout())
Static lGestao := ('E' $ cSM0Leiaute .or. 'U' $ cSM0Leiaute)	// Indica se usa Gestao Corporativa

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FINR470  ³ Autor ³ Adrianne Furtado      ³ Data ³ 10/08/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Extrato Banc rio.		 					              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ FINR470(void)                                              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador³ Data   ³ BOPS   ³  Motivo da Alteracao                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³M.Camargo  ³29/07/14³TPYEZ0  ³Se modifica línea 29 para usar mv_par10  ³±±
±±³           ³        ³        ³solo para brasil.                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Jose Glez  ³29/05/17³MMI-5099³Se reajusta el orden para el informe     ³±±
±±³           ³        ³        ³FINR470 por RECNO.                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

User Function xFINR470()
Local lExec		:= .T.

/*
Verifica se o ambiente esta configurada para as rotina de "modelo II" */
If cPaisLoc == "ARG"
	lExec := FinModProc()
Else
	lExec := .T.
Endif
If lExec
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Interface de impressao                                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	oReport := ReportDef()
	If !Empty(oReport:uParam) .AND. !isblind()
		Pergunte(oReport:uParam,.F.)
	EndIf
	oReport:PrintDialog()
Endif
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportDef ³ Autor ³ Adrianne Furtado      ³ Data ³10/08/06  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³A funcao estatica ReportDef devera ser criada para todos os ³±±
±±³          ³relatorios que poderao ser agendados pelo usuario.          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpO1: Objeto do relatório                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportDef()

Local oReport
Local oBanco
Local oMovBanc
Local nTamChave	 := TamSX3("E5_PREFIXO")[1]+TamSX3("E5_NUMERO")[1]+TamSX3("E5_PARCELA")[1] + 3


AjustSX1("XFIN470")

Pergunte("XFIN470",.F.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao do componente de impressao                                      ³
//³                                                                        ³
//³TReport():New                                                           ³
//³ExpC1 : Nome do relatorio                                               ³
//³ExpC2 : Titulo                                                          ³
//³ExpC3 : Pergunte                                                        ³
//³ExpB4 : Bloco de codigo que sera executado na admin		 da impressao  ³
//³ExpC5 : Descricao                                                       ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//"EXTRATO BANCARIO"
//"Este programa ir  emitir o relat¢rio de movimenta‡”es" "banc rias em ordem de data. Poder  ser utilizado para""conferencia de extrato."
oReport := TReport():New("XFINR470",STR0004,"XFIN470", {|oReport| ReportPrint(oReport)},STR0001+" "+STR0002+" "+STR0003)

//desabilita o botao GESTAO CORPORATIVA do relatório
oReport:SetUseGC(.f.)

oBanco := TRSection():New(oReport,STR0035,{"SA6"},/*[Ordem]*/ )//"Dados Bancarios"
TRCell():New(oBanco,"A6_COD" 		,"SA6",STR0008,,23,.F.)//"BANCO"
//TRCell():New(oBanco,"A6_AGENCIA"	,"SA6",STR0009) //"   AGENCIA "
//TRCell():New(oBanco,"A6_NUMCON"	,"SA6",STR0010)//"   CONTA "
//TRCell():New(oBanco,"SALDOINI"	,		,STR0034,,20,,)//"SALDO INICIAL"

oMovBanc := TRSection():New(oBanco,STR0036,{"SE5"})//"Movimentos Bancarios"
TRCell():New(oMovBanc,"E5_FILIAL"	,"SE5","FILIAL"	,,36,,{|| ALLTRIM(E5_FILIAL)})
TRCell():New(oMovBanc,"E5_DTDISPO" ,"SE5",STR0025	,/*Picture*/,13,/*lPixel*/,{|| DtoC(E5_DTDISPO)}) //"DATA"
TRCell():New(oMovBanc,"E5_HISTOR"	,"SE5",STR0026	,,TamSX3("E5_HISTOR")[1]+3,,{|| SubStr(E5_HISTOR,1,TamSX3("E5_HISTOR")[1])})//"OPERACAO"
TRCell():New(oMovBanc,"E5_NUMCHEQ"	,"SE5",STR0027	,,36,,{|| If(Len(Alltrim(E5_DOCUMEN)) + Len(Alltrim(E5_NUMCHEQ)) > 35,;  //"DOCUMENTO"
	Alltrim(SUBSTR(E5_DOCUMEN,1,20)) + If(!empty(Alltrim(E5_DOCUMEN)),"-"," ") + Alltrim(E5_NUMCHEQ ),;
	If(Empty(E5_NUMCHEQ),E5_DOCUMEN,E5_NUMCHEQ))})

TRCell():New(oMovBanc,"E5_BENEF"	,"SE5","BENEFICIARIO"	,,36,,{|| ALLTRIM(E5_BENEF)})
	
TRCell():New(oMovBanc,"PREFIXO/TITULO"	,"SE5",STR0028	,,nTamChave+5,,{|| If(E5_TIPODOC="CH",ChecaTp(E5_NUMCHEQ+E5_BANCO+E5_AGENCIA+E5_CONTA),;
	E5_PREFIXO+If(Empty(E5_PREFIXO)," ","-")+E5_NUMERO+; //"PREFIXO/TITULO"
	If(Empty(E5_PARCELA)," ","-")+E5_PARCELA)})

TRCell():New(oMovBanc,"E5_VALOR-ENTRAD","SE5",STR0029	,,20)//"ENTRADAS"
TRCell():New(oMovBanc,"E5_VALOR-SAIDA" ,"SE5",STR0030	,,20)//"SAIDAS"

TRCell():New(oMovBanc,"E5_TIPO"	,"SE5","TIPO TITULO"	,,36)

TRCell():New(oMovBanc,"E5_BANCO"	,"SE5","BANCO"	,,36)
TRCell():New(oMovBanc,"E5_AGENCIA"	,"SE5","AGENCIA"	,,36)
TRCell():New(oMovBanc,"E5_CONTA"	,"SE5","CONTA"	,,36)


//TRCell():New(oMovBanc,"SALDO ATUAL"		,"SE5",STR0031	,,20,,{|| nSaldoAtu})//"SALDO ATUAL"
//TRCell():New(oMovBanc,"CANCEL" ,"SE5",STR0048,,15)//"CANCELADO"
//TRCell():New(oMovBanc,"TAXA"	,,STR0037,,12)//"CONCILIADOS"
TRCell():New(oMovBanc,"x-CONCILIADOS"	,"SE5",STR0016,,3)//"CONCILIADOS"

oTotal := TRSection():New(oMovBanc,STR0032,{"SE5"},/*[Ordem]*/ )//"Totais"

//TRCell():New(oTotal,"DESCRICAO",,STR0033 ,,30,,)//"DESCRICAO"
//TRCell():New(oTotal,"NAOCONC"  ,,STR0015 ,,20,,)//"NAO CONCILIADOS"
//TRCell():New(oTotal,"CONC"		 ,,STR0016 ,,20,,)//"CONCILIADOS"
//TRCell():New(oTotal,"TOTAL" 	 ,,STR0017 ,,20,,)//"TOTAL"

oTotal:SetLeftMargin(35)

Return(oReport)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportPrint³ Autor ³ Adrianne Furtado      ³ Data ³27.06.2006³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³A funcao estatica ReportDef devera ser criada para todos os  ³±±
±±³          ³relatorios que poderao ser agendados pelo usuario.           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ExpO1: Objeto do relatório                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportPrint(oReport)

Local oBanco	:= oReport:Section(1)
Local oMovBanc	:= oReport:Section(1):Section(1)
Local oTotal	:= oReport:Section(1):Section(1):Section(1)
Local cAlias
Local lAllFil	:= .F.
Local cChave	:= ""
Local cAliasSA6	:= "SA6"
Local cAliasSE5	:= "SE5"
Local cSql1		:= ""
Local nMoeda	:= GetMv("MV_CENT")             
Local lSpbInUse	:= SpbInUse()
Local nSaldoAtu	:= 0
Local cTabela14	:= ""
Local nCol		:= 0
Local aRecon 	:= {}
Local nTotEnt	:= 0
Local nTotSaida	:= 0
Local nLimCred	:= 0
Local nRecebNCon:= 0
Local nRecebConc:= 0
Local cPictVlr	:=	tm(SE5->E5_VALOR,15,nMoeda)
Local aTotais := {}
Local nLinReport 	:= 8
Local nLinPag		:= 55//mv_par08
Local cExpMda		:= ""
Local nCont 		:= 0
Local cCampos 		:= ""
Local nTaxa 		:= 0
Local lMultSld    	:= FXMultSld()
Local lMsmMoeda   	:= .F.
Local cAliasTmp
Local cFilSE5 := IIf(lGestao, FwFilial("SE5"), xFilial("SE5"))
Local cFilSE8 := IIf(lGestao, FWFilial("SE8"), xFilial("SE8"))
Local	nSaldoIni	:=0
Local aAreaSE5
Local nTamFilSA6 := Len(Alltrim(xFilial("SA6")))
Local lDvc			:= oReport:nDevice == 4
Local lMoedBco	:= SuperGetMv("MV_MOEDBCO",,.F.)
Local nMoedTit	:= 1
Local nReceber   	:= 0
Local cQryR		:= ""
Local lMoedaMov := .T.

Local lOracle := "ORACLE"$Upper(TCGetDB())
Local cDBtype := Alltrim(Upper(TCGetDB()))
Local cNulo	:= ""
Local aEstrut  := {}
Local aFil	   := FWAllFilial()
Local cAuxLay  := cSM0Leiaute
Local cAux  := ""
Local nx:=0
Local ny:=0
Local bMultbx
Local bPagar
Local bReceber

Private nTxMoedBc := 0
Private nMoedaBco := 1

AAdd( aRecon, {0,0,0,0} )

//If !Empty(mv_par08)
//	nLinPag := IIf(MV_PAR08>=89,89,MV_PAR08)
//Else
//	nLinPag := 89
//EndIf

//dbSelectArea("SA6")
//dbSetOrder(1)
//IF !(dbSeek(cFilial+mv_par01+mv_par02+mv_par03))
//	Help(" ",1,"BCONOEXIST")
//Return
//EndIF

nMoedaBco	:=	1

// Carrega a tabela 14
cTabela14 := FR470Tab14()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Saldo de Partida 											 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SE8")
dbSetOrder(1)

//If /*IIF( cPaisLoc $ "BRA" ,Mv_par10 == 2,.T.) .AND.*/ FWModeAccess("SA6",3,) == 'C' .and. FWModeAccess("SE8",3,) == 'E' // recompor saldo por Banco
//	CalcSldIni(@nSaldoAtu, @nSaldoIni)
//Else
//	dbSeek(xFilial("SE8")+mv_par01+mv_par02+mv_par03+Dtos(mv_par04),.T.)   // filial + banco + agencia + conta
//	dbSkip(-1)
//
//	IF E8_FILIAL != xFilial("SE8") .Or. E8_BANCO!=mv_par01 .or. E8_AGENCIA!=mv_par02 .or. E8_CONTA!=mv_par03 .or. BOF() .or. EOF()
//		nSaldoAtu:=0
//		nSaldoIni:=0
//	Else
//		If mv_par07 == 1  //Todos
//			nSaldoAtu:=Round(xMoeda(E8_SALATUA,nMoedaBco,mv_par06,SE8->E8_DTSALAT),nMoeda)
//			nSaldoIni:=Round(xMoeda(E8_SALATUA,nMoedaBco,mv_par06,SE8->E8_DTSALAT),nMoeda)
//		ElseIf mv_par07 == 2 //Conciliados
//			nSaldoAtu:=Round(xMoeda(E8_SALRECO,nMoedaBco,mv_par06,SE8->E8_DTSALAT),nMoeda)
//			nSaldoIni:=Round(xMoeda(E8_SALRECO,nMoedaBco,mv_par06,SE8->E8_DTSALAT),nMoeda)
//		ElseIf mv_par07 == 3	//Nao Conciliados
//			nSaldoAtu:=Round(xMoeda(E8_SALATUA-E8_SALRECO,nMoedaBco,mv_par06,SE8->E8_DTSALAT),nMoeda)
//			nSaldoIni:=Round(xMoeda(E8_SALATUA-E8_SALRECO,nMoedaBco,mv_par06,SE8->E8_DTSALAT),nMoeda)
//		Endif
//	Endif
//EndIf

If ExistBlock("F470ALLF")
	lAllFil := ExecBlock("F470ALLF",.F.,.F.,{lAllFil})
EndIf
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Filtragem do relatório                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cAlias := GetNextAlias()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Transforma parametros Range em expressao SQL                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MakeSqlExpr(oReport:uParam)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Query do relatório      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oBanco:BeginQuery()

cOrder  := "%E5_DTDISPO,E5_BANCO,E5_AGENCIA,E5_CONTA,E5_NUMCHEQ,E5_DOCUMEN,SE5.R_E_C_N_O_,E5_PREFIXO,E5_NUMERO%"
If !lAllFil
	If lGestao	 .AND.  FWModeAccess("SE5",3) == "E" .AND.  FWModeAccess("SE5",2) == "E" ;
				.AND. FWModeAccess("SE8",3) == "C" .AND. FWModeAccess("SA6",3) == "C"  
		cSql1	 := "( "
		For ny:=1 to Len(cAuxLay)
			If SUBSTR(cAuxLay,ny,1) == "E" // Carrega array com layout para empresa
				aadd(aEstrut, SUBSTR(cAuxLay,ny,1))
			Endif
			If SUBSTR(cAuxLay,ny,1) == "U" // Carrega array com layout para unidade de negócio
				aadd(aEstrut, SUBSTR(cAuxLay,ny,1))
			Endif	
		next	
		For nx:= 1 to len(aFil)
			cAux:= SUBSTR(xFilial("SE5"),1,Len(aEstrut)) // Carrega Empresa + Unidade de Negócio
				cAux:= cAux +	aFil[nx]  // Adiciona Filial
				cSql1	+=	"E5_FILIAL = '" + cAux + "'" 
				If nx < len(aFil)
					cSql1	+=	 " OR "
				Else
					cSql1	+=	 " ) and "
					exit
				Endif
				cAux:= ""	
		next 		
		If Empty(cFilSE5) .and. !Empty(cFilSE8)
			cSql1	+=	"E5_FILORIG = '" + xFilial("SE8") + "'" + " AND "
		Endif		
	Else 
		cSql1	:=	"E5_FILIAL = '" + xFilial("SE5") + "'" + " AND "   
		If Empty(cFilSE5) .and. !Empty(cFilSE8)
			cSql1	+=	"E5_FILORIG = '" + xFilial("SE8") + "'" + " AND "
		Endif
	Endif
EndIf

//cSql1	+=	" E5_FILIAL BETWEEN  '" + mv_par01 + "' AND '" + mv_par02 + "' AND "
If lSpbInuse
	cSql1	+=	" E5_DTDISPO >=  '"     + DTOS(mv_par03) + "' AND"
	cSql1	+=	" ((E5_DTDISPO <= '"+ DTOS(mv_par04) + "') OR "
	cSql1	+=	"  (E5_DTDISPO >= '"+ DTOS(mv_par04) + "' AND "
	cSql1	+=	"  (E5_DATA    >= '"+ DTOS(mv_par03) + "' AND "
	cSql1	+=	"   E5_DATA    <= '"+ DTOS(mv_par04) + "'))) AND"
Else
	cSql1	+=	" E5_DTDISPO >= '" + DTOS(mv_par03) + "' AND"
	cSql1	+=	" E5_DTDISPO <= '" + DTOS(mv_par04) + "' AND"
EndIf
//If mv_par07 == 2
//	cSql1	+=	" E5_RECONC <> ' ' AND "
//ElseIf mv_par07 == 3
//	cSql1	+=	" E5_RECONC = ' ' AND "
//EndIf

cSql1 := " ( E5_DTDISPO BETWEEN '" + DTOS(mv_par03) + "' AND '" + DTOS(mv_par04) + "' ) AND  "

ConOut("xFINR470 " + cSql1 )
cSql1 := "%"+cSql1+"%"
cCampos := "E5_FILIAL,  E5_DTDISPO,	E5_HISTOR,	E5_NUMCHEQ, E5_BENEF,	E5_DOCUMEN, E5_PREFIXO, E5_NUMERO, E5_PARCELA, E5_TIPODOC, E5_FILORIG, "
cCampos += "E5_RECPAG, 	E5_VALOR, 	E5_MOEDA, 	E5_VLMOED2, E5_CLIFOR, 	E5_LOJA, 	E5_RECONC, E5_TIPO, E5_SEQ, E5_SITUACA,"
cCampos += "SE5.R_E_C_N_O_ REGSE5, "

//Necessario incluir alguns campos de acordo com a alteracao realizada para a exibicao no relatorio dos dados corretos
//de um titulo a pagar quando baixado como normal e com cheque.
cCampos += "E5_BANCO, E5_AGENCIA, E5_CONTA, "

cCampos += "A6_FILIAL, 	A6_COD, 	A6_NREDUZ, 	A6_AGENCIA, A6_NUMCON, A6_LIMCRED"
cCampos += ", E5_TXMOEDA "
cCampos := "%"+cCampos+"%"

cExpMda	:= "%E5_MOEDA NOT IN " + FormatIn(cTabela14+"/DO","/") + "%"

BeginSql Alias cAlias
	Select	%Exp:cCampos%
	FROM 	%table:SE5% SE5
	LEFT JOIN %table:SA6% SA6 ON
	(LEFT(E5_FILIAL , 5) = A6_FILIAL AND 
	E5_BANCO 	= A6_COD AND
	E5_AGENCIA	= A6_AGENCIA AND
	E5_CONTA 	= A6_NUMCON)
	WHERE 	%Exp:cSql1%
	A6_FILIAL 	between %Exp:LEFT(mv_par01,5)% AND %Exp:LEFT(mv_par02, 5)%  AND 
	E5_BANCO 	between  %Exp:mv_par05% AND %Exp:mv_par06% AND 
//	E5_AGENCIA 	= %Exp:mv_par02% AND
//	E5_CONTA 	= %Exp:mv_par03% AND
	E5_TIPODOC NOT IN ('DC','JR','MT','CM','D2','J2','M2','V2','C2','CP','TL','BA','I2','EI','VA') AND
	( E5_TIPODOC <> 'VL' OR E5_TIPO <> 'VP' ) AND
	NOT (E5_TIPODOC = 'ES' AND E5_RECPAG = 'P' AND E5_MOTBX = 'CMP') AND 
	NOT (E5_MOEDA IN ('C1','C2','C3','C4','C5','CH') AND E5_NUMCHEQ = '               ' AND (E5_TIPODOC NOT IN('TR','TE'))) AND
	NOT (E5_TIPODOC IN ('TR','TE') AND ((E5_NUMCHEQ BETWEEN '*              ' AND '*ZZZZZZZZZZZZZZ') OR (E5_DOCUMEN BETWEEN '*                ' AND '*ZZZZZZZZZZZZZZZZ' ))) AND
	NOT (E5_TIPODOC IN ('TR','TE') AND E5_NUMERO = '      ' AND %Exp:cExpMda% ) AND
	E5_VALOR   <> 0 AND
	NOT(E5_NUMCHEQ BETWEEN '*              ' AND '*ZZZZZZZZZZZZZZ') AND//NOT LIKE '*%' AND
	SE5.%notDel% AND
	SA6.%notDel%
	ORDER BY %exp:cOrder%
EndSql
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Metodo EndQuery ( Classe TRSection )                                    ³
//³Prepara o relatório para executar o Embedded SQL.                       ³
//³ExpA1 : Array com os parametros do tipo Range                           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oBanco:EndQuery(/*Array com os parametros do tipo Range*/)

oMovBanc:SetParentQuery()

cAliasSA6	:= cAlias
cAliasSE5 	:= cAlias

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Inicio da impressao do fluxo do relatório                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

cMoeda := Upper(GetMv("MV_MOEDA1"))

//nTxMoeda := If(nTxMoedBc > 1, nTxMoedBc,RecMoeda(iif(1==1,dDataBase,(cAliasSE5)->E5_DTDISPO),mv_par06))
nTxMoeda := If(nTxMoedBc > 1, nTxMoedBc,RecMoeda( dDataBase ,1))
If alltrim(oReport:title()) == alltrim (STR0004)
	oReport:SetTitle(OemToAnsi(STR0007 + " " + DTOC(mv_par03) + STR0040 + Dtoc(mv_par04) + STR0039 + cMoeda))//"EXTRATO BANCARIO ENTRE "
Endif
oMovBanc:Cell("E5_VALOR-ENTRAD"	):SetPicture(tm(E5_VALOR,20,nMoeda))
oMovBanc:Cell("E5_VALOR-SAIDA"	):SetPicture(tm(E5_VALOR,20,nMoeda))
//oMovBanc:Cell("TAXA"	):SetPicture(tm(E5_VALOR,12,nMoeda))
//oMovBanc:Cell("SALDO ATUAL"		):SetPicture(tm(E5_VALOR,20,nMoeda))

If lMultSld .And. !Empty((cAliasSE5)->E5_TXMOEDA)
	If (cAliasSE5)->E5_RECPAG == "P"
		lMsmMoeda := Posicione("SE2",1,xFilial("SE2")+(cAliasSE5)->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO),"E2_MOEDA") == 1
	Else
		lMsmMoeda := Posicione("SE1",1,xFilial("SE1")+(cAliasSE5)->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO),"E1_MOEDA") == 1
	EndIf
EndIf

If !lMoedBco
	bMultbx:= {|| Round(xMoeda(F470VlMoeda(cAliasSE5);
		,Iif((cPaisLoc <> "BRA" .And. ((cAliasSE5)->E5_TIPODOC $ MVRECANT+"|ES") .and. Empty((cAliasSE5)->E5_MOEDA)) ,1, nMoedaBco );
		,1;
		,dDataBase;
		,nMoeda + 1;
		,IIf(lMultSld,  IIF(1 == 1, RecMoeda(dDatabase, nMoedaBco ), TxMoeda(cAliasSE5, nMoedaBco) ) 	,	Iif(nTxMoedBc > 1 .And. cPaisLoc <> "BRA",nTxMoedBc, if(cPaisLoc=="BRA",RecMoeda((cAliasSE5)->E5_DTDISPO,1),nTxMoedBc)));
		,IIf(lMultSld,IIf(!lMsmMoeda,RecMoeda(IIf(1==1,dDataBase,(cAliasSE5)->E5_DTDISPO),1),(cAliasSE5)->E5_TXMOEDA),Iif(nTxMoedBc > 1 .And. cPaisLoc <> "BRA",nTxMoedBc, if(cPaisLoc=="BRA",RecMoeda((cAliasSE5)->E5_DTDISPO,1),nTxMoeda))));
		,nMoeda)}
		
Else
	bMultbx:= {|| IIF(!Empty((cAliasSE5)->(E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO)),; // IF - Título Financeiro
			IIF( VerMoed(1, @nMoedTit) , (cAliasSE5)->E5_VALOR,;
			Round(xMoeda( Iif(VerMoed(nMoedaBco, @nMoedTit,Iif(lMoedBco,.F.,.T.)), E5_VALOR, E5_VLMOED2),;
			nMoedTit,;
			1,;
			IIF(1==1,dDataBase,E5_DTDISPO),;  
				IIF(1 == 1, RecMoeda(dDatabase, nMoedTit), TxMoeda(cAlias, nMoedTit))),nMoeda)),; // Else - Movimentação Financeira
				Round(xMoeda(F470VlMoeda(cAliasSE5);
				,Iif((cPaisLoc <> "BRA" .And. ((cAliasSE5)->E5_TIPODOC $ MVRECANT+"|ES") .and. Empty((cAliasSE5)->E5_MOEDA)) ,1, nMoedaBco );
				,1;
				,iif(1==1,dDataBase,(cAliasSE5)->E5_DTDISPO);
				,nMoeda + 1;
				,IIf(lMultSld,  IIF(1 == 1, RecMoeda(dDatabase, nMoedaBco ), TxMoeda(cAliasSE5, nMoedaBco) ) 	,	Iif(nTxMoedBc > 1 .And. cPaisLoc <> "BRA",nTxMoedBc, if(cPaisLoc=="BRA",RecMoeda((cAliasSE5)->E5_DTDISPO,1),nTxMoedBc)));
				,IIf(lMultSld,IIf(!lMsmMoeda,RecMoeda(IIf(1==1,dDataBase,(cAliasSE5)->E5_DTDISPO),1),(cAliasSE5)->E5_TXMOEDA),Iif(nTxMoedBc > 1 .And. cPaisLoc <> "BRA",nTxMoedBc, if(cPaisLoc=="BRA",RecMoeda((cAliasSE5)->E5_DTDISPO,1),nTxMoeda))));
				,nMoeda))}
Endif
                                             //Executo o bloco bMultbx  
bReceber:= {||If((cAliasSE5)->E5_RECPAG == "R", Eval(bMultbx) , Iif(lDvc, 0, nil))}	
bPagar  := {||If((cAliasSE5)->E5_RECPAG == "P", Eval(bMultbx) , Iif(lDvc, 0, nil))}
//oMovBanc:Cell("SALDO ATUAL"		):SetBlock({|| nSaldoAtu += If((cAliasSE5)->E5_SITUACA == "C",0,Eval(bMultbx) * (If((cAliasSE5)->E5_RECPAG == 'R',1,-1)))})
oMovBanc:Cell("E5_VALOR-ENTRAD"  ):SetBlock(bReceber)			 
oMovBanc:Cell("E5_VALOR-SAIDA"   ):SetBlock(bPagar)
//oMovBanc:Cell("CANCEL"   		 ):SetBlock({||If((cAliasSE5)->E5_SITUACA == "C","x"," ")})
		
//oMovBanc:Cell("CANCEL"			):SetAlign("CENTER")
oMovBanc:Cell("E5_VALOR-ENTRAD"	):SetHeaderAlign("RIGHT")
oMovBanc:Cell("E5_VALOR-SAIDA"	):SetHeaderAlign("RIGHT")
//oMovBanc:Cell("SALDO ATUAL"		):SetHeaderAlign("RIGHT")
//oMovBanc:Cell("CANCEL"			):SetHeaderAlign("RIGHT")
//oMovBanc:Cell("TAXA"		    ):SetHeaderAlign("CENTER")
oMovBanc:Cell("x-CONCILIADOS"		):SetBlock({|| Iif(Empty((cAliasSE5)->E5_RECONC), " ", "x")})
oMovBanc:Cell("x-CONCILIADOS"		):SetTitle("")

//If cPaisLoc <> "BRA"
//	If cPaisLoc<>"ANG"
//		If 1 <> nMoedaBco .And. 1 > 1
//			oMovBanc:Cell("TAXA"):SetBlock({||If(nTxMoedBc > 1, nTxMoedBc, RecMoeda(iif(1==1,dDataBase,E5_DTDISPO),1))})
//		Else
//			oMovBanc:Cell("TAXA"):Disable()
//		EndIf
//	Else
//		If 1 <> nMoedaBco
//			If nMoedaBco>1
//				oMovBanc:Cell("TAXA"):SetBlock({||If(nTxMoedBc > 1, nTxMoedBc, RecMoeda(E5_DTDISPO,nMoedaBco))})
//			Else
//				oMovBanc:Cell("TAXA"):SetBlock({||If(nTxMoedBc > 1, nTxMoedBc, IIf(!lMsmMoeda,RecMoeda(E5_DTDISPO,1),(cAliasSE5)->E5_TXMOEDA))})
//			EndIf
//		Else
//			oMovBanc:Cell("TAXA"):Disable()
//		EndIf
//	EndIf
//Else
//	oMovBanc:Cell("TAXA"):Disable()
//EndIf

oBanco:SetLineStyle()

If cPaisLoc == "BRA"
	If (cAliasSA6)->(A6_LIMCRED) == 0 .And. !Empty(SA6->A6_LIMCRED)		
		nLimCred := SA6->A6_LIMCRED		
	Else
		nLimCred := (cAliasSA6)->(A6_LIMCRED)
	EndIf
Else
	If SA6->A6_MOEDA <> 1 .and. SA6->A6_MOEDA == 1
		nLimCred := (cAliasSA6)->(A6_LIMCRED)
	Else
		nLimCred := xMoeda((cAliasSA6)->A6_LIMCRED,SA6->A6_MOEDA,1,dDataBase)
	EndIf
EndIf

//oBanco:Init()
//
//oBanco:Cell("SALDOINI"):SetBlock( { || Transform(nSaldoIni,tm(nSaldoIni,16,nMoeda)) } )
//oBanco:Cell("SALDOINI"):SetHeaderAlign("RIGHT")

oMovBanc:OnPrintLine( {|| F470LinPag(nLinPag, @nLinReport)})

(cAliasSE5)->(dbEval({|| nCont++}))
(cAliasSE5)->(dbGoTop())

If (cAliasSE5)->(Eof())
	oReport:OnPageBreak( { || F470LinPag( nLinPag, @nLinReport,.T.) } )
//	oBanco:Cell("A6_COD"):SetBlock( {|| SA6->A6_COD +" - "+AllTrim(SA6->A6_NREDUZ)} )
//	oBanco:Cell("A6_AGENCIA"):SetBlock( {|| SA6->A6_AGENCIA } )
//	oBanco:Cell("A6_NUMCON"):SetBlock( {|| SA6->A6_NUMCON } )
//	oBanco:PrintLine()
	oMovBanc:Init()
	oMovBanc:PrintLine()
	oMovBanc:Finish()	
Else
//	oBanco:Cell("A6_COD"):SetBlock( {|| (cAliasSA6)->A6_COD +" - "+AllTrim((cAliasSA6)->A6_NREDUZ)} )
//	oReport:OnPageBreak( { || oBanco:PrintLine(), F470LinPag( nLinPag, @nLinReport,.T.) } )
EndIf

oReport:SetMeter(nCont)

While !oReport:Cancel() .And. (cAliasSE5)->(!Eof())

	If oReport:Cancel()
		Exit
	EndIf

//	If oBanco:Cancel()
//		Exit
//	EndIf

	lFirst := .T.

	oMovBanc:Init()
	While !oReport:Cancel() .And. !(cAliasSE5)->(Eof())
		If oReport:Cancel()
			Exit
		EndIf

		oReport:IncMeter()

// Posiciona no correspondente SE5 para permitir configuracoes condicionais de colunas
		SE5->( dbGoTo( (cAliasSE5)->REGSE5 ) )

// Em ambiente Mexico a informacao Troco nao esta sendo processada
		If (cAliasSE5)->E5_MOEDA=="TC" .and. cPaisLoc=="MEX"
			dbSkip()
			Loop
		Endif

		nTxMoedBc 	:= 0

		If (cAliasSE5)->E5_TIPODOC=="ES"
			aAreaSE5 := (cAliasSE5)->( GetArea() )
			cAliasTmp  :=Alias()
			cChave     := (cAliasSE5)->(E5_FILIAL+E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA+E5_SEQ)

			DbSelectArea("SE5")
			DbSetOrder(7)
			DbGoTop()

			If DbSeek(cChave)
				If SE5->E5_TIPODOC=="V2"
					RestArea( aAreaSE5 )
					DbSelectArea(cAliasTmp)
					(cAliasSE5)->(dbSkip())
					Loop
				EndIf
			EndIf
			RestArea( aAreaSE5 )
			DbSelectArea(cAliasTmp)

		EndIf

		If cPaisloc<>"BRA"
			nTaxa := TxMoeda(cAliasSE5, nMoedaBco)
			If 1 == 1
				nTxMoedBc := 0 //RecMoeda(dDatabase,nMoedaBco)
			Else
				nTxMoedBc := nTaxa
			Endif
		EndIf

		oMovBanc:PrintLine()
		If (cAliasSE5)->E5_SITUACA <> "C"
			If lMoedBco  
				If Empty((cAliasSE5)->E5_RECONC) .AND. (cAliasSE5)->E5_RECPAG == "R"	
					aRecon[1][REC_NAO_CONCILIADO] += EVAL(bReceber)
				ElseIf E5_RECPAG == "R"
					aRecon[1][REC_CONCILIADO] += EVAL(bReceber) 
				ElseIf Empty( E5_RECONC ) .AND. E5_RECPAG == "P"
					aRecon[1][PAG_NAO_CONCILIADO] += EVAL(bPagar)
				ElseIf E5_RECPAG == "P"
					aRecon[1][PAG_CONCILIADO] += EVAL(bPagar)
				Endif
			Else
				If Empty((cAliasSE5)->E5_RECONC) .AND. (cAliasSE5)->E5_RECPAG == "R"	
					aRecon[1][REC_NAO_CONCILIADO] += EVAL(bReceber)
				ElseIf E5_RECPAG == "R"
					aRecon[1][REC_CONCILIADO] += EVAL(bReceber) 
				ElseIf Empty( E5_RECONC ) .AND. E5_RECPAG == "P"
					aRecon[1][PAG_NAO_CONCILIADO] += EVAL(bPagar)
				ElseIf E5_RECPAG == "P"
					aRecon[1][PAG_CONCILIADO] += EVAL(bPagar)
				Endif
			EndIf
		EndIf

		(cAliasSE5)->(dbSkip())
	EndDo
	oMovBanc:Finish()
	oReport:SkipLine()
EndDo
//oBanco:Finish()

//AADD( aTotais ,{STR0014,,,nSaldoIni})//"SALDO INICIAL...........: "
//AADD( aTotais ,{STR0018,aRecon[1][REC_NAO_CONCILIADO],aRecon[1][REC_CONCILIADO],aRecon[1][REC_NAO_CONCILIADO] +  aRecon[1][REC_CONCILIADO]})//"ENTRADAS NO PERIODO.....: "
//AADD( aTotais ,{STR0019,aRecon[1][PAG_NAO_CONCILIADO],aRecon[1][PAG_CONCILIADO],aRecon[1][PAG_NAO_CONCILIADO] +  aRecon[1][PAG_CONCILIADO] })//"SAIDAS NO PERIODO ......: "
//AADD( aTotais ,{STR0021,,,nLimCred})//"LIMITE DE CREDITO.......: "
//AADD( aTotais ,{STR0020,,,nSaldoAtu += nLimCred})//"SALDO ATUAL ............: "

//oTotal:Init()
//
//oTotal:Cell("DESCRICAO"):HideHeader()
//oTotal:Cell("NAOCONC"):SetHeaderAlign("CENTER")
//oTotal:Cell("CONC"):SetHeaderAlign("CENTER")
//oTotal:Cell("TOTAL"):SetHeaderAlign("CENTER")

If lDvc
	oMovBanc:Cell("E5_DTDISPO"		):Hide()
	oMovBanc:Cell("E5_HISTOR"		):Hide()
	oMovBanc:Cell("E5_NUMCHEQ"		):Hide()
	oMovBanc:Cell("PREFIXO/TITULO"	):Hide()
	oMovBanc:Cell("E5_VALOR-ENTRAD"	):Hide()
	oMovBanc:Cell("E5_VALOR-SAIDA" 	):Hide()
//	oMovBanc:Cell("SALDO ATUAL"		):Hide()
EndIf

//For nX := 1 to 5
//	oTotal:Cell("DESCRICAO"):SetBlock( { || aTotais[nX][1] } )
//	oTotal:Cell("NAOCONC")	:SetBlock( { || If(nX == 2 .Or. nX == 3,Transform(aTotais[nX][2],tm(aTotais[nX][2],16,nMoeda)),"")} )
//	oTotal:Cell("CONC") 		:SetBlock( { || If(nX == 2 .Or. nX == 3,Transform(aTotais[nX][3],tm(aTotais[nX][3],16,nMoeda)),"")} )
//	oTotal:Cell("TOTAL")		:SetBlock( { || Transform(aTotais[nX][4],tm(aTotais[nX][4],16,nMoeda))} )
//	If nX == 2 .Or. nX == 5
//		oReport:SkipLine()
//	EndIf
//	oTotal:PrintLine()
//Next nX

oReport:Title(STR0004)
//oTotal:Finish()

Return NIL

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  | F470VlMoeda  ºAutor ³ TOTVS            º Data ³ 09/06/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Retorno o campo de valor a ser utilizado para conversão    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ cAliasSE5												  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ nVlMoeda = Retorna o campo E5_VALOR ou E5_VLMOED2          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ FINR470                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function F470VlMoeda(cAliasSE5)
	Local nVlMoeda:=0
	Local cMoeda

	cMoeda := Iif((cPaisLoc<>"BRA" .And. ((cAliasSE5)->E5_TIPODOC $ MVRECANT+"|ES") .And. Empty((cAliasSE5)->E5_MOEDA)),1, nMoedaBco )

If cPaisLoc $ "ARG|COL|DOM|EQU|MEX|VEN|PAR" //Gravaçao do SE5 nas rotinas localizadas são diferentes do Brasil.
	If cMoeda <> 1
		If (1 == 1) .OR. (1 == cMoeda)
			nVlMoeda := (cAliasSE5)->E5_VALOR
		Else
			If (cAliasSE5)->E5_VLMOED2 > 0
				nVlMoeda := (cAliasSE5)->E5_VLMOED2
			Else
				nVlMoeda := (cAliasSE5)->E5_VALOR
			EndIf
		EndIf
	Else
		nVlMoeda := (cAliasSE5)->E5_VALOR
	EndIf

Else
	nVlMoeda := (cAliasSE5)->E5_VALOR
Endif

Return (nVlMoeda)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  | F470LinPag   ºAutor ³ Marcio Menon	  º Data ³ 29/06/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Faz a quebra de pagina de acordo com o parametro "Linhas   º±±
±±º          ³ por Pagina?" (mv_par08)                                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ EXPL1 - Numero maximo de linhas definido no relatorio      º±±
±±º          ³ EXPL2 - Contador de linhas impressas no relatorio          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ nil                                                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ FINR470                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function F470LinPag(nLinPag, nLinReport,lLimpa)
Default lLimpa := .F.

If lLimpa
	nLinReport := 9
Else
	nLinReport++
	
	If nLinReport > (nLinPag + 8)
		oReport:EndPage()
		nLinReport := 9
	EndIf
EndIf

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ TxMoeda  ºAutor  ³ Microsiga          º Data ³  31/10/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Retorna taxa da moeda do movimento de transferencia caso   º±±
±±º          ³ tenha sido informada. Caso contrario retorna a taxa do     º±±
±±º          ³ cadastro de moedas (SM2)									  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ EXPN1 - Taxa da moeda do movimento ou SM2.                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ FINR470                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function TxMoeda( cAliasSE5, nMoedaBco )

Local aArea	:= GetArea()
Local nTaxa	:= 0
Local cNum		:= (cAliasSE5)->E5_NUMCHEQ
Default lE5TXMoeda := .T.

If !Empty(cNum)
	SE5->(dbSetOrder(10))
	SE5->(MsSeek(xFilial("SE5")+cNum))
	If 1 == 1 // Taxa do dia
		nTaxa := RecMoeda(dDatabase,1)
	ElseIf lE5TXMoeda .And. (cAliasSE5)->E5_TXMOEDA == 1 .And.;
			Val((cAliasSE5)->E5_MOEDA) == 1
		nTaxa := RecMoeda((cAliasSE5)->E5_DTDISPO,1)
	ElseIf lE5TXMoeda .And. !Empty((cAliasSE5)->E5_TXMOEDA)
		nTaxa := (cAliasSE5)->E5_TXMOEDA
	ElseIf (caliasSE5) -> E5_TIPODOC == "TE" .OR. (((cAliasSE5)->E5_TIPO $ MVPAGANT+MVRECANT) .and. 1 <> Val((cAliasSE5)->E5_MOEDA))
		nTaxa := RecMoeda((cAliasSE5)->E5_DTDISPO,nMoedaBco)
	ElseIf (caliasSE5) -> E5_TIPODOC == "TR" .And. 1 <> Val((cAliasSE5)->E5_MOEDA)
		nTaxa := RecMoeda((cAliasSE5)->E5_DTDISPO,nMoedaBco)	
	Else
		nTaxa := RecMoeda((cAliasSE5)->E5_DTDISPO,1)
	EndIf
Else
	If 1 == 1
		nTaxa := RecMoeda(dDatabase,nMoedaBco)
	ElseIf lE5TXMoeda .And. !Empty((cAliasSE5)->E5_TXMOEDA) .And. ( Val((cAliasSE5)->E5_MOEDA) == nMoedaBco .or. (cAliasSE5)->E5_TIPO $ MVPAGANT+MVRECANT ) // QUANDO É ADIANTAMENTO O CAMPO E5_MOEDA FICA EM BRANCO
		nTaxa := (cAliasSE5)->E5_TXMOEDA
	Elseif lE5TXMoeda .And. !Empty((cAliasSE5)->E5_TXMOEDA) .And. ( nMoedaBco <> 1 .and. (cAliasSE5)->E5_TXMOEDA > 0)
		nTaxa := (cAliasSE5)->E5_TXMOEDA //Caso de moeda contratada. Ou seja, valor da taxa da moeda fornecido por exemplo em cta a receber ou movimento bancario a receber.
	Else
		nTaxa := RecMoeda((cAliasSE5)->E5_DTDISPO,IIF(nMoedaBco > 1 , nMoedaBco, 1))
	EndIf
EndIf

RestArea( aArea )

Return( nTaxa )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FINR470   ºAutor  ³ Gustavo Henrique   º Data ³  15/09/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Carrega e retorna moedas da tabela 14                      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FR470Tab14()

	Local cTabela14 := ""

SX5->(DbSetOrder(1))
SX5->(MsSeek(xFilial("SX5")+"14"))
While SX5->(!Eof()) .And. SX5->X5_TABELA == "14"
	cTabela14 += (Alltrim(SX5->X5_CHAVE) + "/")
	SX5->(DbSkip())
End
cTabela14 += If(cPaisLoc=="BRA","","/$ ")
If cPaisLoc == "BRA"
	cTabela14 := SubStr( cTabela14, 1, Len(cTabela14) - 1 )
EndIf

Return cTabela14


	/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ChecaTp    ³ Autor ³ Andrea Verissimo      ³ Data ³14/12/2010³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³Essa funcao retorna os dados do arquivo SEF para movimentos  ³±±
±±³          ³bancarios do tipo CH.                                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³prefixo, titulo e parcela do arquivo SEF.                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ campos Nro Cheque, Banco, Agencia e Conta do arquivo SE5.   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ChecaTp(cChaveTp)
Local cRetorno := ""
Local cChavSef := ""
Local aArea    := GetArea()
Local nSoma := 0

If(E5_TIPODOC="CH")
	cChavSef := (xFilial("SE5")+cChaveTp)
	SEF->(dbSetOrder(4))
	If SEF->(Dbseek(cChavSef))
		dbSelectArea("SEF")
		While !EOF() .and. (EF_FILIAL+EF_NUM+EF_BANCO+EF_AGENCIA+EF_CONTA) = cChavSef .and. nSoma <= 1
			If !Empty(EF_TIPO)
				nSoma++
				cRetorno := EF_PREFIXO+If(Empty(EF_PREFIXO)," ","-")+EF_TITULO+If(Empty(EF_PARCELA)," ","-")+EF_PARCELA
			Endif
			SEF->(Dbskip())
		Enddo
	Else
		cChavSef := (E5_FILORIG+cChaveTp)
		dbSelectArea("SEF")
		SEF->(dbSetOrder(4))
		SEF->(Dbseek(cChavSef))
		While !EOF() .and. (EF_FILIAL+EF_NUM+EF_BANCO+EF_AGENCIA+EF_CONTA) = cChavSef .and. nSoma <= 1
			If !Empty(EF_TIPO)
				nSoma++
				cRetorno := EF_PREFIXO+If(Empty(EF_PREFIXO)," ","-")+EF_TITULO+If(Empty(EF_PARCELA)," ","-")+EF_PARCELA
			Endif
			SEF->(Dbskip())
		Enddo
	EndIf

	If nSoma > 1
		cRetorno := "   "
		nSoma := 0
	Endif

	dbCloseArea()
	RestArea(aArea)
	nSoma := 0
EndIf

Return (cRetorno)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FINR470   ºAutor  ³ Rodrigo Oliveira   º Data ³  14/04/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Verifica se a moeda do título é dif. da moeda do bco       º±±
±±º          ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function VerMoed(nMoedaBco, nMoedTit,lConvert)

Local aArea	:= GetArea()
Local lRet := .T.
Local lMoedBco	:= SuperGetMv("MV_MOEDBCO",,.F.)
Local cChaveSe5	:= E5_PREFIXO+E5_NUMERO+E5_PARCELA+E5_TIPO+E5_CLIFOR+E5_LOJA 

Default lConvert := .T. 


If E5_RECPAG == "P" .AND. E5_TIPODOC!="ES"
	nMoedTit 	:= Posicione("SE2",1,xFilial("SE2")+(cChaveSe5),"E2_MOEDA")
Else
	nMoedTit 	:= Posicione("SE1",1,xFilial("SE1")+(cChaveSe5),"E1_MOEDA")
EndIf

If lMoedBco .and. lConvert 
	If E5_MOEDA <> str(nMoedTit) // se permitir baixar titulo com moeda diferente do banco 
		nMoedTit:= val(E5_MOEDA) // considera moeda da baixa 
	Endif
Endif 

If Empty(nMoedTit)
	lRet := .T.	
Else 
	lRet := Iif(nMoedTit == 0, lRet, (nMoedTit == nMoedaBco)) 
EndIf

RestArea(aArea)

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FINR470   ºAutor  ³ Rodrigo Oliveira   º Data ³  09/11/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Função para cálculo do saldo inicial de banco compart.     º±±
±±º          ³ e saldo exclusivo                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

//Static Function CalcSldIni(nSaldoAtu, nSaldoIni) 
//
//Local cSaldo 	:= GetNextAlias()
//Local cQry		:= ""
//Local nMoeda	:= GetMv("MV_CENT"+(IIF(1 > 1 , STR(1,1),"")))
//Local cFl 		:= ""
//Local nSld		:= 0
//Local nSlRec	:= 0
//Local lOracle := "ORACLE"$Upper(TCGetDB())
//
//cQry := " SELECT E8_FILIAL, E8_BANCO, E8_AGENCIA, E8_CONTA, E8_DTSALAT, E8_SALATUA, E8_SALRECO "
//cQry += " FROM " + RetSqlName("SE8") + " SE8 " 
//cQry += " WHERE E8_BANCO 	= '" + mv_par01 + "' "
//cQry += " AND E8_AGENCIA 	= '" + mv_par02 + "' "
//cQry += " AND E8_CONTA 		= '" + mv_par03 + "' "
//cQry += " AND E8_DTSALAT		< '" + DTOS(mv_par03) + "' "
//If lOracle
//	cQry += " AND D_E_L_E_T_ != '*' "
//Else
//	cQry += " AND D_E_L_E_T_ = '' "
//EndIf
//cQry += " ORDER BY E8_FILIAL, E8_DTSALAT DESC "
//
//dbUseArea(.T., "TOPCONN", TCGenQry(,,cQry), cSaldo, .T., .T.)
//
//(cSaldo)->(DbGoTop())
//
//cFl 	:= (cSaldo)->E8_FILIAL
//nSld	:= (cSaldo)->E8_SALATUA
//nSlRec	:= (cSaldo)->E8_SALRECO
//
//While !Eof()
//	
//	If (cSaldo)->E8_FILIAL != cFl
//		nSld	+= (cSaldo)->E8_SALATUA
//		nSlRec	+= (cSaldo)->E8_SALRECO
//		cFl 	:= (cSaldo)->E8_FILIAL
//	EndIf
//	DbSkip()	
//EndDo
// 
//(cSaldo)->(DbCloseArea())
//
//If mv_par07 == 1  //Todos
//	nSaldoAtu:=Round(xMoeda(nSld,nMoedaBco,mv_par06,SE8->E8_DTSALAT),nMoeda)
//	nSaldoIni:=Round(xMoeda(nSld,nMoedaBco,mv_par06,SE8->E8_DTSALAT),nMoeda)
//ElseIf mv_par07 == 2 //Conciliados
//	nSaldoAtu:=Round(xMoeda(nSlRec,nMoedaBco,mv_par06,SE8->E8_DTSALAT),nMoeda)
//	nSaldoIni:=Round(xMoeda(nSlRec,nMoedaBco,mv_par06,SE8->E8_DTSALAT),nMoeda)
//ElseIf mv_par07 == 3	//Nao Conciliados
//	nSaldoAtu:=Round(xMoeda(nSld - nSlRec,nMoedaBco,mv_par06,SE8->E8_DTSALAT),nMoeda)
//	nSaldoIni:=Round(xMoeda(nSld - nSlRec,nMoedaBco,mv_par06,SE8->E8_DTSALAT),nMoeda)
//Endif
//
//Return

//C:\Fontes\Compila\AjustSx1.prw
/*/{Protheus.doc} AjustSX1
Ajusta Perguntas - SX1
@author Jonatas Oliveira | www.compila.com.br
@since 19/07/2018
@version 1.0
/*/
Static Function AjustSX1(cPerg)
	Local aArea := GetArea()
	Local aHelpPor	:= {}
	Local aHelpEng	:= {}
	Local aHelpSpa	:= {}
	
	aAdd( aHelpEng, "  ")
	aAdd( aHelpSpa, "  ")
	
	aHelpPor := {} ; Aadd( aHelpPor, "De Filial")
	xPutSX1(cPerg	,"01","De Filial?"		 			,"De Filial?"					,"De Filial?"					,"mv_ch1","C",11,00,0,"G","			"	,"SM0"		,""	,"","mv_par01",""			,"","","",""		,"","",""		,"","","","","","","","",aHelpPor,aHelpEng,aHelpSpa )
	
	aHelpPor := {} ; Aadd( aHelpPor, "Ate Filial")
	xPutSX1(cPerg	,"02","Ate Filial?"					,"Ate Filial?"					,"Ate Filial?"					,"mv_ch2","C",11,00,0,"G","NaoVazio	"	,"SM0"		,""	,"","mv_par02",""			,"","","",""		,"","",""		,"","","","","","","","",aHelpPor,aHelpEng,aHelpSpa )
	
	aHelpPor := {} ; Aadd( aHelpPor, "De Data")
	xPutSX1(cPerg	,"03","De Data?"		 			,"De Data?"						,"De Data?"						,"mv_ch3","D",8 ,00,0,"G","NaoVazio"	,""			,""	,"","mv_par03",""			,"","","",""		,"","",""		,"","","","","","","","",aHelpPor,aHelpEng,aHelpSpa )
	
	aHelpPor := {} ; Aadd( aHelpPor, "Ate Data")
	xPutSX1(cPerg	,"04","Ate Data?"					,"Ate Data?"					,"Ate Data?"					,"mv_ch4","D",8 ,00,0,"G","NaoVazio	"	,""			,""	,"","mv_par04",""			,"","","",""		,"","",""		,"","","","","","","","",aHelpPor,aHelpEng,aHelpSpa )

	aHelpPor := {} ; Aadd( aHelpPor, "De Banco")
	xPutSX1(cPerg	,"05","De Banco?"		 			,"De Banco?"					,"De Banco?"					,"mv_ch5","C",3 ,00,0,"G",""			,"SA6"		,""	,"","mv_par05",""			,"","","",""		,"","",""		,"","","","","","","","",aHelpPor,aHelpEng,aHelpSpa )
	
	aHelpPor := {} ; Aadd( aHelpPor, "Ate Banco")
	xPutSX1(cPerg	,"06","Ate Banco?"					,"Ate Banco?"					,"Ate Banco?"					,"mv_ch6","C",3 ,00,0,"G","NaoVazio	"	,"SA6"		,""	,"","mv_par06",""			,"","","",""		,"","",""		,"","","","","","","","",aHelpPor,aHelpEng,aHelpSpa )
				
Return()

/*/{Protheus.doc} xPutSX1
Ajusta Perguntas - SX1
@author Jonatas Oliveira | www.compila.com.br
@since 19/07/2018
@version 1.0
/*/
Static Function xPutSX1(   cGrupo,cOrdem,cPergunt,cPerSpa,cPerEng,cVar,;
					       cTipo ,nTamanho,nDecimal,nPresel,cGSC,cValid,;
					       cF3, cGrpSxg,cPyme,;
					       cVar01,cDef01,cDefSpa1,cDefEng1,cCnt01,;
					       cDef02,cDefSpa2,cDefEng2,;
					       cDef03,cDefSpa3,cDefEng3,;
					       cDef04,cDefSpa4,cDefEng4,;
					       cDef05,cDefSpa5,cDefEng5,;
					       aHelpPor,aHelpEng,aHelpSpa,cHelp)

	Local aArea := GetArea()
	Local cKey
	Local lPort := .f.
	Local lSpa  := .f.
	Local lIngl := .f. 

	cKey  := "P." + AllTrim( cGrupo ) + AllTrim( cOrdem ) + "."
	
	cPyme    := Iif( cPyme           == Nil, " ", cPyme        )
	cF3      := Iif( cF3             == NIl, " ", cF3          )
	cGrpSxg  := Iif( cGrpSxg  == Nil, " ", cGrpSxg      )
	cCnt01   := Iif( cCnt01          == Nil, "" , cCnt01       )
	cHelp := Iif( cHelp            == Nil, "" , cHelp        )
	
	dbSelectArea( "SX1" )
	dbSetOrder( 1 )
	
	// Ajusta o tamanho do grupo. Ajuste emergencial para validação dos fontes.
	// RFC - 15/03/2007
	cGrupo := PadR( cGrupo , Len( SX1->X1_GRUPO ) , " " )
	
	If !( DbSeek( cGrupo + cOrdem ))
	
		cPergunt:= If(! "?" $ cPergunt .And. ! Empty(cPergunt),Alltrim(cPergunt)+" ?",cPergunt)
		cPerSpa      := If(! "?" $ cPerSpa  .And. ! Empty(cPerSpa) ,Alltrim(cPerSpa) +" ?",cPerSpa)
		cPerEng      := If(! "?" $ cPerEng  .And. ! Empty(cPerEng) ,Alltrim(cPerEng) +" ?",cPerEng)
		
		Reclock( "SX1" , .T. )
		
		Replace X1_GRUPO   With cGrupo
		Replace X1_ORDEM   With cOrdem
		Replace X1_PERGUNT With cPergunt
		Replace X1_PERSPA  With cPerSpa
		Replace X1_PERENG  With cPerEng
		Replace X1_VARIAVL With cVar
		Replace X1_TIPO    With cTipo
		Replace X1_TAMANHO With nTamanho
		Replace X1_DECIMAL With nDecimal
		Replace X1_PRESEL  With nPresel
		Replace X1_GSC     With cGSC
		Replace X1_VALID   With cValid
		
		Replace X1_VAR01   With cVar01
		
		Replace X1_F3      With cF3
		Replace X1_GRPSXG  With cGrpSxg
		
		If Fieldpos("X1_PYME") > 0
			If cPyme != Nil
				Replace X1_PYME With cPyme
			Endif
		Endif
			
		Replace X1_CNT01   With cCnt01
		
		If cGSC == "C"                   // Mult Escolha
			Replace X1_DEF01   With cDef01
			Replace X1_DEFSPA1 With cDefSpa1
			Replace X1_DEFENG1 With cDefEng1
			
			Replace X1_DEF02   With cDef02
			Replace X1_DEFSPA2 With cDefSpa2
			Replace X1_DEFENG2 With cDefEng2
			
			Replace X1_DEF03   With cDef03
			Replace X1_DEFSPA3 With cDefSpa3
			Replace X1_DEFENG3 With cDefEng3
			
			Replace X1_DEF04   With cDef04
			Replace X1_DEFSPA4 With cDefSpa4
			Replace X1_DEFENG4 With cDefEng4
			
			Replace X1_DEF05   With cDef05
			Replace X1_DEFSPA5 With cDefSpa5
			Replace X1_DEFENG5 With cDefEng5
		Endif
			
		Replace X1_HELP  With cHelp
		
		PutSX1Help(cKey,aHelpPor,aHelpEng,aHelpSpa)
		
		MsUnlock()
	Else
		
		lPort := ! "?" $ X1_PERGUNT .And. ! Empty(SX1->X1_PERGUNT)
		lSpa  := ! "?" $ X1_PERSPA  .And. ! Empty(SX1->X1_PERSPA)
		lIngl := ! "?" $ X1_PERENG  .And. ! Empty(SX1->X1_PERENG)
		
		If lPort .Or. lSpa .Or. lIngl
			If lPort 
				SX1->X1_PERGUNT:= Alltrim(SX1->X1_PERGUNT)+" ?"
			EndIf
			
			If lSpa 
				SX1->X1_PERSPA := Alltrim(SX1->X1_PERSPA) +" ?"
			EndIf
			
			If lIngl
				SX1->X1_PERENG := Alltrim(SX1->X1_PERENG) +" ?"
			EndIf
			SX1->(MsUnLock())
		EndIf
	Endif
	
	RestArea( aArea )

Return