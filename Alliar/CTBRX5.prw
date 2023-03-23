/*
linha 852 ta lendo o arquivo temporario pronto

CtbXGerRaz - monta struct do arq temporario e 
             invoca:

-> CtbXQryRaz
-> CtbXRazao  ->CtbXGrvRAZ


quem faz reclock no arquivo temporario: CtbXGrvRAZ   CtbXGrvNoMov  CtbXQryRaz(chama: CtbXGrvNoMov)
	
*/

#Include "CTBR400.Ch"
#Include "PROTHEUS.Ch"
#INCLUDE "FILEIO.CH"
#DEFINE TAM_VALOR  20
#DEFINE TAM_CONTA   17
#DEFINE AJUST_CONTA  25//10

Static lFWCodFil := .T. 
Static cTpValor  := "D"
Static __cSegOfi := ""   


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ CTBRX5  ³ Autor ³ Cicero J. Silva   	³ Data ³ 04.08.06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Balancete Centro de Custo/Conta         			 		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ CTBR400()    											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ Nenhum       											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso 		 ³ SIGACTB      											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function CTBRX5(cContaIni, cContaFim, dDataIni, dDataFim, cMoeda, cSaldos,;
				 cBook, lCusto, cCustoIni, cCustoFim, lItem, cItemIni, cItemFim,;
				 lClVl, cClvlIni, cClvlFim,lSaltLin,cMoedaDesc,aSelFil )


Local aArea := GetArea()
Local aCtbMoeda		:= {}

Local cArqTmp		:= "" 
Local lOk := .T.
Local lExterno		:= .F. 
//|Local lImpRazR4	:= TRepInUse()
local lMantem   := .T. 
Local lTodasFil 	:= .F.

PRIVATE cTipoAnt	:= ""
PRIVATE cPerg	 	:= "4CTBRX"//"CTR400"
PRIVATE nomeProg  	:= "CTBR400"  
PRIVATE nSldTransp	:= 0 // Esta variavel eh utilizada para calcular o valor de transporte
PRIVATE oReport   
PRIVATE nLin		:= 0    
PRIVATE nLinha		:= 6  
PRIVATE nTipoRel    := 0
Private nmeulinha := 0
Private nSaldo1 := 0
Private nSaldo2 := 0 
DEFAULT lCusto		:= .F.
DEFAULT lItem		:= .F.
DEFAULT lCLVL		:= .F.
DEFAULT lSaltLin	:= .T.
DEFAULT cMoedaDesc  := cMoeda // RFC - 18/01/07 | BOPS 103653
DEFAULT aSelFil		:= {}

cTpValor := Alltrim(GetMV("MV_TPVALOR"))
__cSegOfi  := SuperGetMV("MV_SEGOFI",,"0")   

lOk := AMIIn(34)		// Acesso somente pelo SIGACTB
		
If lOk

	AjustaSX1(cPerg)
	
	If !lExterno
		While lMantem
			If Pergunte(/*"CTR400"*/cPerg, .T.)
				If Empty(mv_par05)
					ALert ("Informe a Moeda")
					Loop
				EndIf
				
				If Empty(mv_par06)
					ALert ("Informe o tipo saldo")
					Loop				
				EndIf
				
				lOk     := .T.
				lMantem := .F.
			Else	
				lOk     := .F.
				lMantem := .F.
			EndIf
			
			
		End
	Endif
Endif


If lOk
		lCusto	:= .F.
		lItem	:= .F.
		lCLVL	:= .F.
		// Se aFil nao foi enviada, exibe tela para selecao das filiais
		If lOk .And. mv_par09 == 1 .And. Len( aSelFil ) <= 0
				aSelFil := AdmGetFil(@lTodasFil)
	
			If Len( aSelFil ) <= 0
				lOk := .F.
			EndIf 
		EndIf
	
Endif   
	

If lOk
    aCtbMoeda  	:= CtbMoeda(MV_PAR05) // Moeda?
    If Empty( aCtbMoeda[1] )
			Help(" ",1,"NOMOEDA")
		    lOk := .F.
	Endif
  
Endif 

If lOk

	U_ACTBRXA400R4(aCtbMoeda,lCusto,lItem,lCLVL,@cArqTmp,aSelFil,lTodasFil )
		
	/*
	If lImpRazR4 
		U_ACTBRXA400R4(aCtbMoeda,lCusto,lItem,lCLVL,@cArqTmp,aSelFil,lTodasFil )
	Else
		U_ACTBRXB400R3( cContaIni, cContaFim, dDataIni, dDataFim, cMoeda, cSaldos,;
					cBook, lCusto, cCustoIni, cCustoFim, lItem, cItemIni, cItemFim,;
					lClVl, cClvlIni, cClvlFim,lSaltLin,cMoedaDesc,aSelFil ) // Executa versão anterior do fonte
	EndIf
	*/
	
Endif

If Select("cArqTmp") > 0
		dbSelectArea("cArqTmp")
		Set Filter To
		dbCloseArea()

		If Select("cArqTmp") == 0
			FErase(cArqTmp+GetDBExtension())
			FErase(cArqTmp+OrdBagExt())
		EndIf
EndIf	

RestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ CTBRXA400R4 º Autor ³                    º Data ³  15/09/09  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Impressao do relatorio em R4                                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGACTB                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function ACTBRXA400R4(aCtbMoeda,lCusto,lItem,lCLVL,cArqTmp,aSelFil,lTodasFil )
	
oReport := ReportDef(aCtbMoeda,lCusto,lItem,lCLVL,@cArqTmp,aSelFil,lTodasFil)
oReport:PrintDialog()
             
oReport := Nil

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FazVlr    º Autor ³                    º Data ³  15/09/09  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Impressao do relatorio em R4                                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGACTB                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function FazVlr(nDecimais, cPicture, lPrintZero)
Local cStr := ""

If (cArqTmp->LANCDEB > 0)
	cStr := xValorCTB(cArqTmp->LANCDEB,,,TAM_VALOR,nDecimais,.F.,cPicture,"1",,,,,,lPrintZero,.F.  ,  .F.)
EndIf

If (cArqTmp->LANCCRD > 0)
	cStr := xValorCTB  (cArqTmp->LANCCRD     ,  ,       ,TAM_VALOR,nDecimais,.F.,cPicture,"2", , , , , ,lPrintZero,.F.  ,  .T.) 
	//alert (cStr)            
EndIf

If (cArqTmp->LANCDEB == 0 .And. cArqTmp->LANCCRD == 0)
	cStr := xValorCTB(0,,,TAM_VALOR,nDecimais,.F.,cPicture,"1",,,,,,lPrintZero,.F.  ,  .F.) 
EndIf

return cStr



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FazSld1Vlr    º Autor ³                    º Data ³  15/09/09  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Impressao do relatorio em R4                                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGACTB                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function FazSld1Vlr(nDecimais, cPicture, lPrintZero)
Local cStr := ""

cStr := "Total Débito: " + xValorCTB(nSaldo1,,,TAM_VALOR,nDecimais,.F.,cPicture,"1",,,,,,lPrintZero,.F.  ,  .F.)

return cStr


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FazSld2Vlr    º Autor ³                    º Data ³  15/09/09  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³Impressao do relatorio em R4                                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGACTB                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function FazSld2Vlr(nDecimais, cPicture, lPrintZero)
Local cStr := ""

cStr := "Total Crébito: " + xValorCTB  (nSaldo2     ,  ,       ,TAM_VALOR,nDecimais,.F.,cPicture,"2", , , , , ,lPrintZero,.F.  ,  .T.) 

return cStr

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ ReportDef º Autor ³ Cicero J. Silva    º Data ³  01/08/06  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Definicao do objeto do relatorio personalizavel e das      º±±
±±º          ³ secoes que serao utilizadas                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ aCtbMoeda  - Matriz ref. a moeda                           º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ SIGACTB                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ReportDef(aCtbMoeda,lCusto,lItem,lCLVL,cArqTmp,aSelFil,lTodasFil)

Local oReport
Local oSection1		//Conta
Local oSection1_1  	// Totalizador da Conta
Local oSection2
Local oSection3
Local cDesc1		:= STR0001	//"Este programa ir  imprimir o Raz„o Contabil,"
Local cDesc2		:= STR0002	// "de acordo com os parametros solicitados pelo"
Local cDesc3		:= STR0003	// "usuario."
Local titulo		:= STR0006 	//"Emissao do Razao Contabil"
Local cNormal		:= ""

Local aTamConta	:= TAMSX3("CT1_CONTA")
Local aTamCusto	:=  TAMSX3("CT3_CUSTO")
Local nTamConta	:= Len(CriaVar("CT1_CONTA"))
Local nTamHist	:= If(cPaisLoc$"CHI|ARG",29,40)
Local nTamItem	:= Len(CriaVar("CTD_ITEM"))
Local nTamCLVL	:= Len(CriaVar("CTH_CLVL"))
Local nTamLote	:= Len(CriaVar("CT2_LOTE")+CriaVar("CT2_SBLOTE")+CriaVar("CT2_DOC")+CriaVar("CT2_LINHA"))
Local nTamData	:= 10

Local lAnalitico	:= .T.

Local lPrintZero	:= .T.
Local lSalto		:= .F. 

Local cSayCusto	:= CtbSayApro("CTT")
Local cSayItem		:= CtbSayApro("CTD")
Local cSayClVl		:= CtbSayApro("CTH")

Local nDigitAte		:= 0
Local aSetOfBook 	:= CTBSetOf(''/*mv_par07*/)// Set Of Books	
Local cPicture 	:= aSetOfBook[4]
Local cDescMoeda 	:= aCtbMoeda[2]
Local nDecimais 	:= DecimalCTB(aSetOfBook,mv_par05)// Moeda
Local nTamFilial 	:= IIf( lFWCodFil, FWGETTAMFILIAL, TamSx3( "CT2_FILIAL" )[1] )                
Local nCount := 0
Local nCount2 := 0  

nTipoRel := 1 // Tipo de Relatorio sempre Analitico 

aTamCusto[1]	:= 20
nTamItem		:= 20
nTamCLVL		:= 20

If mv_par08 == 3 						//// SE O PARAMETRO DO CODIGO ESTIVER PARA IMPRESSAO
	nTamConta := Len(CT1->CT1_CODIMP)	//// USA O TAMANHO DO CAMPO CODIGO DE IMPRESSAO
Else
	If nTipoRel == 1 // se analitico 
		
			nTamConta := 40						// Tamanho disponivel no relatorio para imprimir
		
	EndIf		
Endif
	
oReport := TReport():New(nomeProg,titulo,cPerg, {|oReport| ReportPrint(oReport,aCtbMoeda,aSetOfBook,cPicture,cDescMoeda,nDecimais,nTamConta,lAnalitico,lCusto,lItem,lCLVL,cArqTmp,aSelFil,lTodasFil)},cDesc1+cDesc2+cDesc3)

//Habilitado o parametro de personalização porém,
// não será permitido a alteração das sections
IF GETNEWPAR("MV_CTBPOFF",.T.)
	oReport:SetEdit(.F.)
ENDIF
  
oReport:SetTotalInLine(.F.)
oReport:EndPage(.T.)
//alert ('end page')
If nTipoRel == 1 // Analitico
	oReport:SetLandScape(.T.)
Else
	oReport:SetPortrait(.T.)
EndIf
    
// oSection2
oSection2 := TRSection():New(oReport,"Custo"/*"STR0044"*/,{"cArqTmp","CT2"},/*aOrder*/,/*lLoadCells*/,/*lLoadOrder*/,,,,,,.F.)	//"Custo"
oSection2:SetReadOnly()       
oSection2:SetEdit(.F.)

TRCell():New(oSection2,"FILIAL"		,""		  ,STR0058,/*Picture*/,15,/*lPixel*/,/*{|| }*/)// "FILIAL"
TRCell():New(oSection2,"DATAL"	    ,"cArqTmp",STR0019,/*Picture*/,15,/*lPixel*/,/*{|| }*/,/*"LEFT"*/,,/*"LEFT"*/,,,.F.)	// "DATA"
TRCell():New(oSection2,"DOCUMENTO"	,"cArqTmp",STR0034,/*Picture*/,If(nTamLote < 20, 20,nTamLote),/*lPixel*/,{|| cArqTmp->LOTE+cArqTmp->SUBLOTE+cArqTmp->DOC+cArqTmp->LINHA },/*"LEFT"*/,,/*"LEFT"*/,,,.F.)// "LOTE/SUB/DOC/LINHA"
TRCell():New(oSection2,"HISTORICO"	,""		  ,STR0035,/*Picture*/,nTamHist+5	,/*lPixel*/,{|| cArqTmp->HISTORICO},/*"LEFT"*/,.T.,"LEFT",,,.F.)// "HISTORICO"	
TRCell():New(oSection2,"CONTA"	    ,"cArqTmp","CONTA",/*Picture*/,24,/*lPixel*/,/*{|| }*/,/*"LEFT"*/,,/*"LEFT"*/,,,.F.)// "XPARTIDA"
TRCell():New(oSection2,"XPARTIDA"	,"cArqTmp","CONTRA PARTIDA",/*Picture*/,24,/*lPixel*/,/*{|| }*/,/*"LEFT"*/,,/*"LEFT"*/,,,.F.)// "XPARTIDA"
TRCell():New(oSection2,"ITEM"	 	,"cArqTmp","ITEM",/*Picture*/,24,/*lPixel*/,/*{|| }*/,/*"LEFT"*/,,/*"LEFT"*/,,,.F.)
TRCell():New(oSection2,"ITEMC"	 	,"cArqTmp","ITEM_CONTRA_PARTIDA",/*Picture*/,24,/*lPixel*/,/*{|| }*/,/*"LEFT"*/,,/*"LEFT"*/,,,.F.)

TRCell():New(oSection2,"CLANCDEB"	,"cArqTmp","VALOR",/*Picture*/,TAM_VALOR,/*lPixel*/, {||FazVlr(nDecimais, cPicture, lPrintZero)},/*"RIGHT"*/,,"CENTER",,,.F.)// "CREDITO"



oSection2:Cell("FILIAL"):lHeaderSize	:= .F.
oSection2:Cell("DATAL"):lHeaderSize	:= .F.

oSection2:Cell("DOCUMENTO"):lHeaderSize	:= .F.
oSection2:Cell("HISTORICO"):lHeaderSize	:= .F.
oSection2:Cell("CONTA"):lHeaderSize	:= .F.
oSection2:Cell("ITEM"):lHeaderSize	:= .F.
oSection2:Cell("XPARTIDA"):lHeaderSize	:= .F.

oSection2:Cell("CLANCDEB"):lHeaderSize	:= .F.


//*************************************************************
// Tratamento do campo SEGOFI para Chile e Argentina          *
// Caso o relatorio seja resumido imprime na coluna historico *
// Caso seja analitico imprime em uma nova coluna.            *
//*************************************************************

//****************************************
// Oculta campos para relatorio resumido *
//****************************************

//********************************
// Imprime linha saldo anterior  *
//********************************

//--------------------------------------------------------------------------------------
oSection1_1 := TRSection():New(oReport,STR0050,/*{"cArqTmp","CT2"}*/,/*aOrder*/,/*lLoadCells*/,/*lLoadOrder*/)

TRCell():New(oSection1_1,"SALDO1","cArqTmp","",/*Picture*/,TAM_VALOR + 20,/*lPixel*/,{|| FazSld1Vlr(nDecimais, cPicture, lPrintZero) },"RIGHT",,"RIGHT")
TRCell():New(oSection1_1,"SALDO2","cArqTmp","",/*Picture*/,TAM_VALOR + 20,/*lPixel*/,{|| FazSld2Vlr(nDecimais, cPicture, lPrintZero)},"RIGHT",,"RIGHT")


//TRCell():New(oSection2,"CLANCDEB"	,"cArqTmp","VALOR",/*Picture*/,TAM_VALOR,/*lPixel*/, {||FazVlr(nDecimais, cPicture, lPrintZero)},/*"RIGHT"*/,,"CENTER",,,.F.)// "CREDITO"

oSection1_1:SetHeaderSection(.F.)  
oSection1_1:SetReadOnly()          
oSection1_1:SetEdit(.F.)
//--------------------------------------------------------------------------------------

           

nTamDesc := Len(STR0016)+nTamConta+65



     
oReport:ParamReadOnly() 

Return oReport

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ReportPrintº Autor ³ Cicero J. Silva    º Data ³  14/07/06  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Definicao do objeto do relatorio personalizavel e das      º±±
±±º          ³ secoes que serao utilizadas                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                            º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function ReportPrint(oReport,aCtbMoeda,aSetOfBook,cPicture,cDescMoeda,nDecimais,nTamConta,lAnalitico,lCusto,lItem,lCLVL,cArqTmp,aSelFil,lTodasFil)

Local oSection2		:= oReport:Section(1)//oReport:Section(2)
Local oSection1_1	:= oReport:Section(2)

Local cFiltro		:= oSection2:GetAdvplExp()

Local cSayCusto		:= CtbSayApro("CTT")
Local cSayItem		:= CtbSayApro("CTD")
Local cSayClVl		:= CtbSayApro("CTH")    
Local aTamCusto		:= TAMSX3("CT3_CUSTO")

Local aSaldo		:= {}
Local aSaldoAnt		:= {}

Local cContaIni		:= mv_par01 // da conta
Local cContaFIm		:= mv_par02 // ate a conta 
Local cMoeda		:= mv_par05 // Moeda
Local cSaldo		:= mv_par06/*busca de saldos*/ // tipo de Saldos



Local cCustoIni		:= "" // Do Centro de Custo
Local cCustoFim		:= ""
Local cItemIni		:= "" 
Local cItemFim		:= "" 
Local cCLVLIni		:= ""
Local cCLVLFim		:= ""
Local cContaAnt		:= ""
Local cFilLsAnt	    := ""
Local nTamRdz       := 0
Local nTamRdy       := 0
Local cDescConta	:= ""
Local cCodRes		:= ""
Local cResCC		:= ""
Local cResItem		:= ""
Local cResCLVL		:= ""
Local cDescSint		:= ""
Local cContaSint	:= ""
Local cNormal 		:= ""

Local xConta		:= ""

Local cSepara1		:= ""
Local cSepara2		:= ""
Local cSepara3		:= ""
Local cSepara4		:= ""
Local cMascara1		:= ""
Local cMascara2		:= ""
Local cMascara3		:= ""
Local cMascara4		:= ""

Local dDataAnt		:= CTOD("  /  /  ")
Local dDataIni		:= mv_par03 // da data
Local dDataFim		:= mv_par04 // Ate a data

Local nTotDeb		:= 0
Local nTotCrd		:= 0
Local nTotGerDeb	:= 0
Local nTotGerCrd	:= 0
Local nVlrDeb		:= 0
Local nVlrCrd		:= 0
Local nCont			:= 0
Local nTotTransp	:= 0

Local lNoMov		:= Iif(mv_par07==1,.T.,.F.) // Imprime conta sem movimento?
Local lSldAnt		:= Iif(mv_par07==3,.T.,.F.) // Imprime conta sem movimento?
Local lJunta		:= .F.
Local lPrintZero	:= .T.
Local lImpLivro		:= .t.
Local lImpTermos	:= .f.
Local lEmissUnica	:= If(GetNewPar("MV_CTBQBPG","M") == "M",.T.,.F.)			/// U=Quebra única (.F.) ; M=Multiplas quebras (.T.)
Local lSldAntCta	:= .F.
Local lSldAntCC		:= .F.
Local lSldAntIt  	:= .F.
Local lSldAntCv  	:= .F.

Local cMoedaDesc	:= iif( Empty( mv_par05/*mv_par10*/ ) , cMoeda , mv_par05 ) // RFC - 18/01/07 | BOPS 103653
Local nMaxLin   	:= 999999

Local lResetPag		:= .T.
Local m_pag			:= 1 // controle de numeração de pagina
Local l1StQb		:= .T.  
Local nPagIni		:= 1
Local nPagFim		:= 999999
Local nReinicia		:= 1
Local nBloco		:= 0
Local nBlCount		:= 1
Local cEspFil		:= ""
Local cFilSTR   	:= ""
Local cMasc 		:= ""
Local aMasc			:= {}
Local nMascFor		:= 0
Local nPosMV		:= 0
Local nAte	 		:= Len(alltrim(mv_par09))
Local nX    
Local lEmiteSaldo := .F.

cCustoFim		:= padr(cCustoFim, TAMSX3("CT3_CUSTO")[1], "Z")
cItemFim		:= padr(cItemFim , TAMSX3("CTD_ITEM")[1], "Z")
cCLVLFim		:= padr(cCLVLFim , TAMSX3("CTH_CLVL")[1], "Z")




aTamCusto[1] := 25

//Limitação de linhas para impressão do relatório.
If oReport:GetOrientation() == 1 .And. nMaxLin > 75 //Retrato
	//Alert("Atenção. Para esta versão do relatório, o número de linhas não pode ser maior que 75.")
	nMaxLin := 75 
ElseIf oReport:GetOrientation() == 2 .And. nMaxLin > 58 //Paisagem
	//Alert("Atenção. Para esta versão do relatório, o número de linhas não pode ser maior que 58.")
	nMaxLin := 58 
EndIf




// Mascara da Conta
cMascara1 := IIf (Empty(aSetOfBook[2]),GetMv("MV_MASCARA"),RetMasCtb(aSetOfBook[2],@cSepara1) )



//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Impressao de Termo / Livro                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


lImpLivro:=.t.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Titulo do Relatorio                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If oReport:Title() == oReport:cRealTitle //If Type("NewHead")== "U" 
	
	Titulo	:=	STR0007	//"RAZAO ANALITICO EM "
	Titulo += 	cDescMoeda + STR0009 + DTOC(dDataIni) +;	// "DE"
				STR0010 + DTOC(dDataFim) + CtbTitSaldo('1'/*mv_par06*/)	// "ATE"
Else
	Titulo := oReport:Title()  //NewHead
EndIf     

oReport:SetTitle(Titulo)   

oReport:SetCustomText( {|| FazCtCGCCabTR(,,,,,dDataFim,oReport:Title(),,,,,oReport,.T.,@lResetPag,@nPagIni,@nPagFim,@nReinicia,@m_pag,@nBloco,@nBlCount,.T.,mv_par03) } )
oSection2:SetHeaderPage(.T.)


oSection2:OnPrintLine  ( {|| CTR400Maxl(@nMaxLin,.F.,.F.)} )	  	  
oSection1_1:OnPrintLine( {|| CTR400Maxl(@nMaxLin,.F.,.F.)} )	  

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta Arquivo Temporario para Impressao   					 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
MsgMeter({|	oMeter, oText, oDlg, lEnd | U_PACTBXGerRaz(	oMeter,oText,oDlg,lEnd,@cArqTmp,cContaIni,cContaFim,cCustoIni,cCustoFim,;
							cItemIni,cItemFim,cCLVLIni,cCLVLFim,cMoeda,dDataIni,dDataFim,;
							aSetOfBook,lNoMov,cSaldo,lJunta,"1",lAnalitico,,,cFiltro,lSldAnt,aSelFil) },;
				STR0018,;		// "Criando Arquivo Tempor rio..."
				STR0006)		// "Emissao do Razao"				

dbSelectArea("cArqTmp")
dbGoTop()
	  	  
oReport:SetMeter( RecCount() )
oReport:NoUserFilter()


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Impressao do Saldo Anterior do Centro de Custo³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
/*
oSection1_1:Cell("SALDO1"):SetBlock( {|| FazSld1Vlr } )
oSection1_1:Cell("SALDO2"):SetBlock( {||  } )

oSection1_1:Cell("SALDO1"):HideHeader() 
oSection1_1:Cell("SALDO2"):HideHeader() 

oSection1_1:setLinesBefore(0)
*/

nSaldo1 := 0
nSaldo2 := 0
If lImpLivro
	If cArqTmp->(EoF())              
		// Atencao ### "Nao existem dados para os parâmetros especificados."
		Aviso(STR0047,STR0048,{"Ok"})
		Return
	Else
		  	  
//		oReport:Init() 
		While lImpLivro .And. cArqTmp->(!Eof()) .And. !oReport:Cancel()
		   	  	  
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³INICIO DA 1a SECAO             ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		    If oReport:Cancel()
		    	Exit
		    EndIf        
		   
			If lSldAntCC
				aSaldo    := SaldTotCT3(cCustoIni,cCustoFim,cArqTmp->CONTA,cArqTmp->CONTA,cArqTmp->DATAL,cMoeda,cSaldo,aSelFil)	
				aSaldoAnt := SaldTotCT3(cCustoIni,cCustoFim,cArqTmp->CONTA,cArqTmp->CONTA,dDataIni,cMoeda,cSaldo,aSelFil)
			ElseIf lSldAntIt
				aSaldo    := SaldTotCT4(cItemIni,cItemFim,cCustoIni,cCustoFim,cArqTmp->CONTA,cArqTmp->CONTA,cArqTmp->DATAL,cMoeda,cSaldo,aSelFil)	
				aSaldoAnt := SaldTotCT4(cItemIni,cItemFim,cCustoIni,cCustoFim,cArqTmp->CONTA,cArqTmp->CONTA,dDataIni,cMoeda,cSaldo,aSelFil)
			ElseIf lSldAntCv
				aSaldo    := SaldTotCTI(cClVlIni,cClVlFim,cItemIni,cItemFim,cCustoIni,cCustoFim,cArqTmp->CONTA,cArqTmp->CONTA,cArqTmp->DATAL,cMoeda,cSaldo,aSelFil)	
				aSaldoAnt := SaldTotCTI(cClVlIni,cClVlFim,cItemIni,cItemFim,cCustoIni,cCustoFim,cArqTmp->CONTA,cArqTmp->CONTA,dDataIni,cMoeda,cSaldo,aSelFil)
			Else 					
				aSaldo 		:= SaldoCT7Fil(cArqTmp->CONTA,cArqTmp->DATAL,cMoeda,cSaldo,,,,aSelFil,,lTodasFil)	
				aSaldoAnt	:= SaldoCT7Fil(cArqTmp->CONTA,dDataIni,cMoeda,cSaldo,"CTBR400",,,aSelFil,,lTodasFil)	
			EndIf

			If f180Fil(lNoMov,aSaldo,dDataIni,dDataFim)
				dbSkip()
				Loop
			EndIf
	  	  
			// Conta Sintetica	
			
			cContaSint := U_AACtrx400Sint(cArqTmp->CONTA,@cDescSint,cMoeda,@cDescConta,@cCodRes,cMoedaDesc)
			cNormal := CT1->CT1_NORMAL
			

			xConta := AllTrim(cArqTmp->(FILIAL)) + ' ' + STR0016 //"CONTA - "	

			If mv_par08 == 1							// Imprime Cod Normal
				xConta += EntidadeCTB(cArqTmp->CONTA,0,0,nTamConta,.F.,cMascara1,cSepara1,,,,,.F.)
				
			Else
				dbSelectArea("CT1")
				dbSetOrder(1)
				MsSeek(xFilial("CT1")+cArqTMP->CONTA,.F.)
				If mv_par08 == 3						// Imprime Codigo de Impressao
					xConta += EntidadeCTB(CT1->CT1_CODIMP,0,0,nTamConta,.F.,cMascara1,cSepara1,,,,,.F.)
				Else										// Caso contrário usa codigo reduzido
					xConta += EntidadeCTB(CT1->CT1_RES,0,0,nTamConta,.F.,cMascara1,cSepara1,,,,,.F.)
				EndIf
			
				cDescConta := &("CT1->CT1_DESC" + cMoedaDesc )
			Endif

			If nTipoRel == 3 // Resumido 
				xConta +=  " - " + Left(cDescConta,30)
			Else
				xConta +=  " - " + Left(cDescConta,40)
			Endif

			nSaldoAtu := aSaldoAnt[6]                                           
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³FIM DA 1a SECAO³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³INICIO DA 2a SECAO³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			dbSelectArea("cArqTmp")
			cContaAnt:= cArqTmp->CONTA//<-- report print
			cFilLsAnt:= cArqTmp->FILIAL
			dDataAnt	:= CTOD("  /  /  ")

			oSection2:Init()                            
			
			Do While cArqTmp->(!Eof() /*.And. CONTA == cContaAnt   .And. cFilLsAnt == cArqTmp->FILIAL */  ) .And. !oReport:Cancel()   
				  	  
			    If oReport:Cancel()
			    	Exit
			    EndIf        
				
				If dDataAnt <> cArqTmp->DATAL   
				
							
					dDataAnt := cArqTmp->DATAL    
				EndIf	
				
					nSaldo1 += cArqTmp->LANCDEB
					nSaldo2 += cArqTmp->LANCCRD
					lEmiteSaldo := .T.
					nSaldoAtu 	:= nSaldoAtu - cArqTmp->LANCDEB + cArqTmp->LANCCRD
					nTotDeb		+= cArqTmp->LANCDEB
					nTotCrd		+= cArqTmp->LANCCRD
					nTotGerDeb	+= cArqTmp->LANCDEB
					nTotGerCrd	+= cArqTmp->LANCCRD			
					
					dbSelectArea("cArqTmp")				

				    If mv_par08 == 1							// Imprime Cod Normal
				    		oSection2:Cell("CONTA"):SetBlock( { ||  (  EntidadeCTB(cArqTmp->CONTA ,0,0,nTamConta,.F.,cMascara1,cSepara1,,,,,.F.)) } )
					Else
							dbSelectArea("CT1")
							dbSetOrder(1)
							MsSeek(xFilial("CT1")+cArqTMP->CONTA,.F.)
						
							
							If mv_par08 == 3						// Imprime Codigo de Impressao
								oSection2:Cell("CONTA"):SetBlock( { ||   (  EntidadeCTB(CT1->CT1_CODIMP ,0,0,nTamConta,.F.,cMascara1,cSepara1,,,,,.F.)) } )
							
							Else
								oSection2:Cell("CONTA"):SetBlock( { ||   (  EntidadeCTB(CT1->CT1_RES ,0,0,nTamConta,.F.,cMascara1,cSepara1,,,,,.F.)) } )
																	// Caso contrário usa codigo reduzido
							EndIf
						
					Endif
//====================================================================================================================
	   					   				
					If mv_par08 == 1 // Impr Cod (Normal/Reduzida/Cod.Impress)
						oSection2:Cell("XPARTIDA"):SetBlock( { ||   ( EntidadeCTB(cArqTmp->XPARTIDA,0,0,nTamConta,.F.,cMascara1,cSepara1,,,,,.F.)) } )
					ElseIf mv_par08 == 3
						oSection2:Cell("XPARTIDA"):SetBlock( { ||   (  EntidadeCTB(CT1->CT1_CODIMP,0,0,nTamConta,.F.,cMascara1,cSepara1,,,,,.F.  )) } )
					Else
						dbSelectArea("CT1")
						dbSetOrder(1)
						MsSeek(xFilial("CT1")+cArqTmp->XPARTIDA,.F.)
						oSection2:Cell("XPARTIDA"):SetBlock( { || (  EntidadeCTB(CT1->CT1_RES,0,0,TAM_CONTA,.F.,cMascara1,cSepara1,,,,,.F.    )) } )
					Endif
				  	
					oSection2:Cell("Filial"):SetBlock( { ||   cArqTmp->FILORI } )
					
					nMeuLinha += 1	
					
					oSection2:PrintLine() 
			     	
					nSldTransp := nSaldoAtu // Valor a Transportar - 1

				    oReport:IncMeter()

					// Procura complemento de historico e imprime
				  	dbSelectArea("cArqTmp")  
					dbSkip()
	   			
			EndDo //cArqTmp->(!Eof()) .And. cArqTmp->CONTA == cContaAnt

 			oSection2:Finish()   
 		
           	nSldTransp  := 0
			nSaldoAtu   := 0
			nTotDeb	    := 0
			nTotCrd	    := 0                              
 			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³FIM DA 2a SECAO³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
		EndDo //lImpLivro .And. !cArqTmp->(Eof()) 

		
	EndIf 
EndIf 

If lEmiteSaldo

oSection1_1:Init()
oSection1_1:PrintLine()
oSection1_1:Finish()
EndIf
	  	  
dbselectArea("CT2")
If !Empty(dbFilter())
	  	  
	dbClearFilter()
Endif
	  	  
Return  //LANCDEB

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CTR400MaxLºAutor  ³                    º Data ³  25/05/09   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³														      º±±
±±º          ³						                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CTBR400                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/

Static Function CTR400MaxL(nMaxLin, lQuebra, lTotConta) 

Local oSection2		

Local lSalLin 		:= .F.//IIf(mv_par31==1,.T.,.F.)//"Salta linha entre contas?"  
   
   	  	  
   oSection2		:= oReport:Section(1)
   


//---------------------------------------------------------
// Custo e Data
//---------------------------------------------------------
If oSection2:Printing() // removi -> .And. ( oSection4 != Nil .And. !oSection4:Printing() )
	nLinha += 1
Endif

//---------------------------------------------------------
// Totalizador - A Transportar / De Transporte
//---------------------------------------------------------
If nLinha > nMaxLin
 
	If nSldTransp != 0
	
    nMeuLinha := 0
		oReport:EndPage()
		

		nLinha := 7
		// Exibir conta / descricao em todo inicio de pagina

		oReport:SkipLine()
	
    Else
    	nMeuLinha := 0
    	oReport:EndPage()
    	
    	nLinha := 6
    Endif	
Endif          
  
Return Nil
    


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³f180Fil   ºAutor  ³Cicero J. Silva     º Data ³  24/07/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ CTBR400                                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Static Function f180Fil(lNoMov,aSaldo,dDataIni,dDataFim)

Local lDeixa	:= .F.

	If !lNoMov //Se imprime conta sem movimento
		If aSaldo[6] == 0 .And. cArqTmp->LANCDEB ==0 .And. cArqTmp->LANCCRD == 0 
			lDeixa	:= .T.
		Endif	
	Endif             
	
	If lNoMov .And. aSaldo[6] == 0 .And. cArqTmp->LANCDEB ==0 .And. cArqTmp->LANCCRD == 0 
		If CtbExDtFim("CT1") 			
			dbSelectArea("CT1") 
			dbSetOrder(1) 
			If MsSeek(xFilial()+cArqTmp->CONTA)
				If !CtbVlDtFim("CT1",dDataIni) 		
					lDeixa	:= .T.
	            EndIf                                   
	            
	            If !CtbVlDtIni("CT1",dDataFim)
					lDeixa	:= .T.
	            EndIf                                   

		    EndIf
		EndIf
	EndIf

	dbSelectArea("cArqTmp")

Return (lDeixa)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ CTBRXB400R3³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 05.02.01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Emiss„o do Raz„o                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ CTBRXB400R3()                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function ACTBRXB400R3(	cContaIni, cContaFim, dDataIni, dDataFim, cMoeda, cSaldos,;
					cBook, lCusto, cCustoIni, cCustoFim, lItem, cItemIni, cItemFim,;
					lClVl, cClvlIni, cClvlFim,lSaltLin,cMoedaDesc,aSelFil )

Local aCtbMoeda	:= {}
Local WnRel			:= "CTBR400"
Local cDesc1		:= STR0001	//"Este programa ir  imprimir o Raz„o Contabil,"
Local cDesc2		:= STR0002	// "de acordo com os parametros solicitados pelo"
Local cDesc3		:= STR0003	// "usuario."
Local cString		:= "CT2"
Local titulo		:= STR0006 	//"Emissao do Razao Contabil"
Local lAnalitico 	:= .T.
Local lRet			:= .T.
Local lExterno		:= cContaIni <> Nil
Local nTamLinha	:= 220
Local nTamConta		:= 22

Local cSepara1		:= ""

DEFAULT lCusto		:= .F.
DEFAULT lItem		:= .F.
DEFAULT lCLVL		:= .F.
DEFAULT lSaltLin	:= .T.
DEFAULT cMoedaDesc  := cMoeda
DEFAULT aSelFil 		:= {}

Private aReturn	:= { STR0004, 1,STR0005, 2, 2, 1, "", 1 }  //"Zebrado"###"Administracao"
Private nomeprog	:= "CTBR400"
Private aLinha		:= {}
Private nLastKey	:= 0
Private cPerg		:= "CTR400"
Private Tamanho 	:= "G"
Private lSalLin		:= .T.

lAnalitico	:= .T.//( mv_par06 == 1 )
nTamLinha	:= If( lAnalitico, 220, 132)  

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se usa Set Of Books -> Conf. da Mascara / Valores   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aSetOfBook := CTBSetOf(''/*mv_par07*/)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Carrega as informacoes da moeda³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aCtbMoeda  	:= CtbMoeda(MV_PAR05)

// Mascara da Conta
If Empty(aSetOfBook[2])
	cMascara1 := GetMv("MV_MASCARA")
Else
	cMascara1	:= RetMasCtb(aSetOfBook[2],@cSepara1)
	//A mascara sera considerada no tamanho da conta somente com a mascara da configuracao de livros. 
	//Quando nao tiver configuracao de livros, o relatorio podera ser impresso em formato retrato e, caso 
	//nao haja espaco para a impressao do codigo da conta (contra-partida), esse codigo sera truncado.
	nTamConta	:= nTamConta+Len(ALLTRIM(cSepara1))	
EndIf               

If (lAnalitico .And. (!lCusto .And. !lItem .And. !lCLVL) .And. nTamConta <= 22) .Or. ! lAnalitico 
	Tamanho := "M"
	nTamLinha := 132
EndIf	

wnrel := SetPrint(cString,wnrel,,@titulo,cDesc1,cDesc2,cDesc3,.F.,"",,Tamanho)

If nLastKey = 27
	Set Filter To
	Return
Endif

SetDefault(aReturn,cString)

If nLastKey = 27
	Set Filter To
	Return
Endif

RptStatus({|lEnd| U_ADCTRX400Imp(@lEnd,wnRel,cString,aSetOfBook,lCusto,lItem,lCLVL,;
	   	lAnalitico,Titulo,nTamlinha,aCtbMoeda, nTamConta,aSelFil)})
Return 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o    ³CTRX400Imp ³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 05/02/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o ³ Impressao do Razao                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Sintaxe   ³CtrX400Imp(lEnd,wnRel,cString,aSetOfBook,lCusto,lItem,;      ³±±
±±³           ³          lCLVL,Titulo,nTamLinha,aCtbMoeda)                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Retorno   ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso       ³ SIGACTB                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ lEnd       - A‡ao do Codeblock                             ³±±
±±³           ³ wnRel      - Nome do Relatorio                             ³±±
±±³           ³ cString    - Mensagem                                      ³±±
±±³           ³ aSetOfBook - Array de configuracao set of book             ³±±
±±³           ³ lCusto     - Imprime Centro de Custo?                      ³±±
±±³           ³ lItem      - Imprime Item Contabil?                        ³±±
±±³           ³ lCLVL      - Imprime Classe de Valor?                      ³±± 
±±³           ³ Titulo     - Titulo do Relatorio                           ³±±
±±³           ³ nTamLinha  - Tamanho da linha a ser impressa               ³±± 
±±³           ³ aCtbMoeda  - Moeda                                         ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function ADCTRX400Imp(lEnd,WnRel,cString,aSetOfBook,lCusto,lItem,lCLVL,lAnalitico,Titulo,nTamlinha,aCtbMoeda,nTamConta,aSelFil)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aSaldo		:= {}
Local aSaldoAnt	:= {}
Local aColunas 
Local nTamRdz   := 0
Local nTamRdy   := 0
Local cArqTmp
Local cSayCusto	:= CtbSayApro("CTT")
Local cSayItem		:= CtbSayApro("CTD")
Local cSayClVl		:= CtbSayApro("CTH")

Local cDescMoeda
Local cMascara1
Local cMascara2
Local cMascara3
Local cMascara4
Local cPicture
Local cSepara1		:= ""
Local cSepara2		:= ""
Local cSepara3		:= ""
Local cSepara4		:= ""
Local cSaldo		:= mv_par06//para o tipo de saldo 
Local cContaIni	:= mv_par01
Local cContaFIm	:= mv_par02
Local cCustoIni	:= ""//mv_par13
Local cCustoFim	:= ""//mv_par14
Local cItemIni		:= ""//mv_par16
Local cItemFim		:= ""//mv_par17
Local cCLVLIni		:= ""//mv_par19
Local cCLVLFim		:= ""//mv_par20
Local cContaAnt	:= ""
Local cFilLsAnt	:= ""
Local cDescConta	:= ""
Local cCodRes		:= ""
Local cResCC		:= ""
Local cResItem		:= ""
Local cResCLVL		:= ""
Local cDescSint	:= ""
Local cMoeda		:= mv_par05
Local cContaSint	:= ""
Local cNormal 		:= ""

Local dDataAnt		:= CTOD("  /  /  ")
Local dDataIni		:= mv_par03
Local dDataFim		:= mv_par04

Local lNoMov		:= Iif(mv_par07==1,.T.,.F.)
Local lSldAnt		:= Iif(mv_par07==3,.T.,.F.)
Local lJunta		:= .F.
Local lSalto		:= .F.
Local lFirst		:= .T.
Local lImpLivro		:= .t.
Local lImpTermos	:= .f.
Local lPrintZero	:= .T.

Local nDecimais
Local nTotDeb		:= 0
Local nTotCrd		:= 0
Local nTotGerDeb	:= 0
Local nTotGerCrd	:= 0
Local nPagIni		:= 1//mv_par22
Local nReinicia 	:= 1//mv_par24
Local nPagFim		:= 999999//mv_par23
Local nVlrDeb		:= 0
Local nVlrCrd		:= 0
Local nCont			:= 0
Local l1StQb 		:= .T.
Local lQbPg			:= .F.
Local lEmissUnica	:= If(GetNewPar("MV_CTBQBPG","M") == "M",.T.,.F.)			/// U=Quebra única (.F.) ; M=Multiplas quebras (.T.)
Local lNewPAGFIM	:= If(nReinicia > nPagFim,.T.,.F.)
Local LIMITE		:= If(TAMANHO=="G",220,If(TAMANHO=="M",132,80))
Local nInutLin		:= 1
Local nMaxLin   	:= 999999//mv_par32
Local lAchouReg := .F.
Local nBloco		:= 0
Local nBlCount		:= 0

Local lSldAntCta	:= .T.// Iif(mv_par33 == 1, .T.,.F.)
Local lSldAntCC	:= .F.//Iif(mv_par33 == 2, .T.,.F.)
Local lSldAntIt  	:= .F.//Iif(mv_par33 == 3, .T.,.F.)
Local lSldAntCv  	:= .F.//Iif(mv_par33 == 4, .T.,.F.)
Local cMoedaDesc	:= iif( Empty( /*mv_par10*/mv_par05 ) , cMoeda , mv_par05)
Local nTotDoDeb := 0
Local nTotDoCred := 0

cCustoFim		:= padr(cCustoFim, TAMSX3("CT3_CUSTO")[1], "Z")
cItemFim		:= padr(cItemFim , TAMSX3("CTD_ITEM")[1], "Z")
cCLVLFim		:= padr(cCLVLFim , TAMSX3("CTH_CLVL")[1], "Z")



nMaxLin := 60


nTipoRel := 1//mv_par06
	
lSalLin	:= .F.//If(mv_par31 ==1 ,.T.,.F.)
m_pag   := 1

//alert ("usar em minha base") 
xCtbQbPg(.T.,@nPagIni,@nPagFim,@nReinicia,@m_pag,@nBloco,@nBlCount,.T.)		/// FUNCAO PARA TRATAMENTO DA QUEBRA //.T. INICIALIZA VARIAVEIS

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para Impressao do Cabecalho e Rodape    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cbtxt    := SPACE(10)
cbcont   := 0
li       := 80

cDescMoeda 	:= Alltrim(aCtbMoeda[2])
nDecimais 	:= DecimalCTB(aSetOfBook,cMoeda)

// Mascara da Conta
If Empty(aSetOfBook[2])
	cMascara1 := GetMv("MV_MASCARA")
Else
	cMascara1	:= RetMasCtb(aSetOfBook[2],@cSepara1)
EndIf               


cPicture 	:= aSetOfBook[4]

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Titulo do Relatorio                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Type("NewHead")== "U"
	IF nTipoRel == 1 //lAnalitico
		Titulo	:=	STR0007	//"RAZAO ANALITICO EM "
	ElseIf nTipoRel == 2 // Resumido
		Titulo	:=	STR0054	//"RAZAO RESUMIDO EM "
	Else  // Sintetico
		Titulo	:=	STR0008	//"RAZAO SINTETICO EM "
	EndIf
	Titulo += 	cDescMoeda + STR0009 + DTOC(dDataIni) +;	// "DE"
				STR0010 + DTOC(dDataFim) + CtbTitSaldo(mv_par06)	// "ATE"
Else
	Titulo := NewHead
EndIf


#DEFINE 	COL_NUMERO 			1
#DEFINE 	COL_HISTORICO		2
#DEFINE 	COL_CONTRA_PARTIDA	3
#DEFINE 	COL_CENTRO_CUSTO 	4
#DEFINE 	COL_ITEM_CONTABIL 	5
#DEFINE 	COL_CLASSE_VALOR  	6 
#DEFINE 	COL_VLR_DEBITO		7
#DEFINE 	COL_VLR_CREDITO		8
#DEFINE 	COL_VLR_SALDO  		9
#DEFINE 	TAMANHO_TM       	10
#DEFINE 	COL_VLR_TRANSPORTE  11

If mv_par08 == 3 						//// SE O PARAMETRO DO CODIGO ESTIVER PARA IMPRESSAO
	nTamConta := Len(CT1->CT1_CODIMP)	//// USA O TAMANHO DO CAMPO CODIGO DE IMPRESSAO
Endif



If nTipoRel == 2 //Relatorio Resumido
	lCusto := .F.
	lItem  := .F.
	lCLVL  := .F.
Else 	//Relatorio Sintetico
	lCusto := .F.
	lItem  := .F.
	lCLVL  := .F.
EndIf


Cabec1 := " "
Cabec2 := "FILIAL        DATA        LOTE+SUB_LOTE+DOC+LINHA   CONTA           C/PARTIDA       HISTORICO                              VALOR"
m_pag := 1//mv_par22


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Arquivo Temporario para Impressao   					 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ



If IsBlind()
	U_PACTBXGerRaz(,,,,@cArqTmp,cContaIni,cContaFim,cCustoIni,cCustoFim,;
	cItemIni,cItemFim,cCLVLIni,cCLVLFim,cMoeda,dDataIni,dDataFim,;
	aSetOfBook,lNoMov,cSaldo,lJunta,"1",lAnalitico,,,aReturn[7],lSldAnt,aSelFil,.T./*lExterno*/,;
	STR0018,;		// "Criando Arquivo Tempor rio..."
	STR0006)		// "Emissao do Razao"
Else
	MsgMeter({|	oMeter, oText, oDlg, lEnd | ;
	U_PACTBXGerRaz(oMeter,oText,oDlg,lEnd,@cArqTmp,cContaIni,cContaFim,cCustoIni,cCustoFim,;
	cItemIni,cItemFim,cCLVLIni,cCLVLFim,cMoeda,dDataIni,dDataFim,;
	aSetOfBook,lNoMov,cSaldo,lJunta,"1",lAnalitico,,,aReturn[7],lSldAnt,aSelFil)},;
	STR0018,;		// "Criando Arquivo Tempor rio..."
	STR0006)		// "Emissao do Razao"
EndIf
		
dbSelectArea("CT2")

If !Empty(dbFilter())
	dbClearFilter()
Endif

dbSelectArea("cArqTmp")
SetRegua(RecCount())
dbGoTop()




//Se tiver parametrizado com Plano Gerencial, exibe a mensagem que o Plano Gerencial
//nao esta disponivel e sai da rotina.
If cArqTmp->(RecCount()) == 0 .And. !Empty(aSetOfBook[5])
	dbCloseArea()
	FErase(cArqTmp+GetDBExtension())
	FErase(cArqTmp+OrdBagExt())
	Return
EndIf


While lImpLivro .And. !cArqTmp->(Eof())
	
	IF lEnd
		@Prow()+1,0 PSAY STR0015  //"***** CANCELADO PELO OPERADOR *****"
		Exit
	EndIF
	
	IncRegua()
	
	If lSldAntCC
		aSaldo    := SaldTotCT3(cCustoIni,cCustoFim,cArqTmp->CONTA,cArqTmp->CONTA,cArqTmp->DATAL,cMoeda,cSaldo,aSelFil)
		aSaldoAnt := SaldTotCT3(cCustoIni,cCustoFim,cArqTmp->CONTA,cArqTmp->CONTA,dDataIni,cMoeda,cSaldo,aSelFil)
	ElseIf lSldAntIt
		aSaldo    := SaldTotCT4(cItemIni,cItemFim,cCustoIni,cCustoFim,cArqTmp->CONTA,cArqTmp->CONTA,cArqTmp->DATAL,cMoeda,cSaldo,aSelFil)
		aSaldoAnt := SaldTotCT4(cItemIni,cItemFim,cCustoIni,cCustoFim,cArqTmp->CONTA,cArqTmp->CONTA,dDataIni,cMoeda,cSaldo,aSelFil)
	ElseIf lSldAntCv
		aSaldo    := SaldTotCTI(cClVlIni,cClVlFim,cItemIni,cItemFim,cCustoIni,cCustoFim,cArqTmp->CONTA,cArqTmp->CONTA,cArqTmp->DATAL,cMoeda,cSaldo,aSelFil)
		aSaldoAnt := SaldTotCTI(cClVlIni,cClVlFim,cItemIni,cItemFim,cCustoIni,cCustoFim,cArqTmp->CONTA,cArqTmp->CONTA,dDataIni,cMoeda,cSaldo,aSelFil)
	Else
		aSaldo 		:= SaldoCT7Fil(cArqTmp->CONTA,cArqTmp->DATAL,cMoeda,cSaldo,,,,aSelFil)
		aSaldoAnt	:= SaldoCT7Fil(cArqTmp->CONTA,dDataIni,cMoeda,cSaldo,"CTBR400",,,aSelFil)
	EndIf
	
	If !lNoMov //Se imprime conta sem movimento
		If aSaldo[6] == 0 .And. cArqTmp->LANCDEB ==0 .And. cArqTmp->LANCCRD == 0
			dbSelectArea("cArqTmp")
	
			dbSkip()
			Loop
		Endif
	Endif
	
	If lNomov .And. aSaldo[6] == 0 .And. cArqTmp->LANCDEB ==0 .And. cArqTmp->LANCCRD == 0
		If CtbExDtFim("CT1")
			dbSelectArea("CT1")
			dbSetOrder(1)
			If MsSeek(xFilial()+cArqTmp->CONTA)
				If !CtbVlDtFim("CT1",dDataIni)
					dbSelectArea("cArqTmp")
					
					dbSkip()
					Loop
				EndIf
				
				If !CtbVlDtIni("CT1",dDataFim)
					dbSelectArea("cArqTmp")
	
					dbSkip()
					Loop
				EndIf
				
			EndIf
			dbSelectArea("cArqTmp")
		EndIf
	EndIf
	
	
	nSaldoAtu:= 0
	nTotDeb	:= 0
	nTotCrd	:= 0
	
	// Conta Sintetica
	
	cContaSint := U_AACtrx400Sint(cArqTmp->CONTA,@cDescSint,cMoeda,@cDescConta,@cCodRes,cMoedaDesc)
	cNormal := CT1->CT1_NORMAL
	
	
	// Conta Analitica
	
	nTamRdy := 9+nTamConta+AJUST_CONTA + nTamRdz + Len( ("- " + Left(cDescConta,30)  ) ) + Len ("    " + STR0033)
	
	
	
	nSaldoAtu := aSaldoAnt[6]                                           
	li += 1         
	
	dbSelectArea("cArqTmp")
	cContaAnt:= cArqTmp->CONTA   //<----na funcao
	cFilLsAnt:= cArqTmp->FILIAL
	dDataAnt	:= CTOD("  /  /  ")
	                              
	
	While cArqTmp->(!Eof()) .And. cArqTmp->CONTA == cContaAnt .And. cFilLsAnt == cArqTmp->FILIAL
	
		//=====  salto de pagina ====================================================================================================	
		If li > nMaxLin

	
			If lSalLin
				li++//COL_VLR_SALDO
			EndIf
			
	
			xCtbQbPg(.F.,@nPagIni,@nPagFim,@nReinicia,@m_pag,@nBloco,@nBlCount,.T.)		/// FUNCAO PARA TRATAMENTO DA QUEBRA //.T. INICIALIZA VARIAVEIS

			xCtCGCCabec(lItem,lCusto,lCLVL,Cabec1,Cabec2,dDataFim,Titulo,lAnalitico,"1",Tamanho)
            @li,001 PSAY Cabec2
            li += 1 
			lQbPg := .T.
		EndIf
		//=========================================================================================================
	
		// Imprime os lancamentos para a conta                          

		If li == 35
			li := 35
		EndIf
		
		@li,001 PSAY /*alltrim(STR(li)) + ' ' + */cArqTmp->FILIAL
		@li,015 PSAY cArqTmp->DATAL 
		@li,027 PSAY cArqTmp->LOTE+cArqTmp->SUBLOTE+cArqTmp->DOC+cArqTmp->LINHA// cArqTmp->LOTE+cArqTmp->SUBLOTE+cArqTmp->DOC+cArqTmp->LINHA

		If mv_par08 == 1							// Imprime Cod Normal
			EntidadeCTB(       cArqTmp->CONTA    ,li,     53   ,nTamConta+AJUST_CONTA,.F.,cMascara1,cSepara1)
			
		Else
			dbSelectArea("CT1")
			dbSetOrder(1)
			MsSeek(xFilial("CT1")+cArqTMP->CONTA,.F.)
		
			
			If mv_par08 == 3						// Imprime Codigo de Impressao
				EntidadeCTB(     CT1->CT1_CODIMP ,li,      53,nTamConta+AJUST_CONTA,.F.,cMascara1,cSepara1)
			Else										// Caso contrário usa codigo reduzido
				EntidadeCTB(     CT1->CT1_RES    ,li,      53,nTamConta+AJUST_CONTA,.F.,cMascara1,cSepara1)
			EndIf
		
		Endif
			
		
			nSaldoAtu 	:= nSaldoAtu - cArqTmp->LANCDEB + cArqTmp->LANCCRD
			nTotDeb		+= cArqTmp->LANCDEB
			nTotCrd		+= cArqTmp->LANCCRD
			nTotGerDeb	+= cArqTmp->LANCDEB
			nTotGerCrd	+= cArqTmp->LANCCRD			
			
			dbSelectArea("CT1")
			dbSetOrder(1)
			MsSeek(xFilial("CT1")+cArqTmp->XPARTIDA)
			cCodRes := CT1->CT1_RES
			dbSelectArea("cArqTmp")

			nTamRdz := 0
			
			// historico complementar da linha (deve-se imprimir na proxima linha)
			cHistComp := Subs(cArqTmp->HISTORICO,41)

			If mv_par08 == 1
			
				EntidadeCTB(cArqTmp->XPARTIDA,li,70, nTamConta ,.F.,cMascara1 ,cSepara1)
			ElseIf mv_par08 == 3
				EntidadeCTB(CT1->CT1_CODIMP  ,li,70,nTamConta,.F., cMascara1 ,cSepara1)				
			Else
				EntidadeCTB(CT1->CT1_RES     ,li,70,17,.F., cMascara1 ,cSepara1)				
			Endif                              
			
			@li,86 PSAY Subs(cArqTmp->HISTORICO,1,40)
			
			If cArqTmp->LANCDEB > 0
				xValorCTB(  (cArqTmp->LANCDEB    ),li,110 	, 20,nDecimais,.F.,cPicture,"1", , , , , ,lPrintZero,.T.,.F.)
				nTotDoDeb += cArqTmp->LANCDEB


			EndIf
			
			If cArqTmp->LANCCRD > 0
				xValorCTB( ( cArqTmp->LANCCRD   ),li,110	, 20,nDecimais,.F.,cPicture      ,"2", , , , , ,lPrintZero,.T.,.T.)
				nTotDoCred += cArqTmp->LANCCRD
			EndIf
			
			If cArqTmp->LANCDEB == 0 .And. cArqTmp->LANCCRD == 0
				xValorCTB( ( 0   ),li,110	, 20,nDecimais,.F.,cPicture,"2", , , , , ,lPrintZero,.T.,.F.)
			EndIf
				
			dbSelectArea("cArqTmp")
			dbSkip()			

		dbSelectArea("cArqTmp")
		//dbSkip()  
		li++
	EndDo//------>   cContaAnt
    //==========================================================================
    li -= 1
    
	    
	//=====   controla salto de pagina =================
	If li > nMaxLin
   
		If lSalLin
			li++
		EndIf
	
		xCtbQbPg(.F.,@nPagIni,@nPagFim,@nReinicia,@m_pag,@nBloco,@nBlCount,.T.)		/// FUNCAO PARA TRATAMENTO DA QUEBRA //.T. INICIALIZA VARIAVEIS

		xCtCGCCabec(lItem,lCusto,lCLVL,Cabec1,Cabec2,dDataFim,Titulo,lAnalitico,"1",Tamanho)
		@li,001 PSAY Cabec2
        li += 1 
		
		If !lFirst
			lQbPg := .T.
		Else
			lFirst := .F.                                
		Endif
	
   EndIf

	
	dbSelectArea("cArqTMP")
EndDo
	
li += 1 
xValorctb(  nTotDoDeb,li,80 	, 20,nDecimais,.F.,cPicture,"1", , , , , ,lPrintZero,.T.,.F.,"Total Débito")

li += 1 
xValorCTB( nTotDoCred,li,80	, 20,nDecimais,.F.,cPicture      ,"2", , , , , ,lPrintZero,.T.,.T.,"Total Crédito")
			
	
If aReturn[5] = 1
	Set Printer To
	Commit
	Ourspool(wnrel)
End

If lImpLivro
	dbSelectArea("cArqTmp")
	Set Filter To
	dbCloseArea()
	If Select("cArqTmp") == 0
		FErase(cArqTmp+GetDBExtension())
		FErase(cArqTmp+OrdBagExt())
	EndIf
Endif

dbselectArea("CT2")

MS_FLUSH()

Return//ccontaant  //<----na funcao  LaNALITICO  SALDO ANTERI         lIMplivro    aReturn

//-------------------------------------------------------------------
/*{Protheus.doc} CtbXGerRaz
Cria Arquivo Temporario para imprimir o Razao

@author Alvaro Camillo Neto

@param	oMeter = Objeto oMeter                                      
@param	oText = Objeto oText                                       
@param	oDlg = Objeto oDlg                                        
@param	lEnd = Acao do Codeblock                                  
@param	cArqTmp = Arquivo temporario                                 
@param	cContaIni = Conta Inicial                                      
@param	cContaFim = Conta Final                                        
@param	cCustoIni = C.Custo Inicial                                    
@param	cCustoFim = C.Custo Final                                      
@param	cItemIni = Item Inicial                                       
@param	cItemFim = Cl.Valor Inicial                                   
@param	cCLVLIni = Cl.Valor Final                                     
@param	cCLVLFim = Moeda                                              
@param	cMoeda = Data Inicial                                       
@param	dDataIni = Data Final                                         
@param	dDataFim = Matriz aSetOfBook                                  
@param	aSetOfBook = Indica se imprime movimento zerado ou nao.         
@param	lNoMov = Tipo de Saldo                                      
@param	lJunta = Indica se junta CC ou nao.                         
@param	lJunta = Tipo do lancamento                                 
@param	lAnalit = Indica se imprime analitico ou sintetico           
@param	c2Moeda = Indica moeda 2 a ser incluida no relatorio       
@param cUFilter= Conteudo Txt com o Filtro de Usuario (CT2)       
   
@version P12
@since   20/02/2014
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------
User Function PACtbXGerRaz(oMeter,oText,oDlg,lEnd,cArqTmp,cContaIni,cContaFim,cCustoIni,cCustoFim,;
						cItemIni,cItemFim,cCLVLIni,cCLVLFim,cMoeda,dDataIni,dDataFim,;
						aSetOfBook,lNoMov,cSaldo,lJunta,cTipo,lAnalit,c2Moeda,;
						nTipo,cUFilter,lSldAnt,aSelFil,lExterno)

Local aTamConta	:= TAMSX3("CT1_CONTA")
Local aTamCusto	:= TAMSX3("CTT_CUSTO") 
Local aTamVal	:= TAMSX3("CT2_VALOR")
Local aCtbMoeda	:= {}
Local aSaveArea := GetArea()                       
Local aCampos
Local cChave
Local nTamHist	:= Len(CriaVar("CT2_HIST"))
Local nTamItem	:= Len(CriaVar("CTD_ITEM"))
Local nTamCLVL	:= Len(CriaVar("CTH_CLVL"))
Local nDecimais	:= 0    
Local cMensagem		:= STR0030// O plano gerencial nao esta disponivel nesse relatorio. 
Local lCriaInd := .F.
Local nTamFilial 	:= IIf( lFWCodFil, FWGETTAMFILIAL, TamSx3( "CT2_FILIAL" )[1] )
Local cArqTmp := "cArqTmp"
Local oTempTable

DEFAULT c2Moeda := ""
DEFAULT nTipo	:= 1
DEFAULT cUFilter:= ""
DEFAULT lSldAnt	:= .F.
DEFAULT aSelFil := {}   
DEFAULT lExterno := .F.


oTempTable := FWTemporaryTable():New(cArqTmp)

If TcSrvType() != "AS/400" .And. cTipo == "1" .And. FunName() == 'CTBR400' .And. TCGetDb() $ "MSSQL7/MSSQL"
	DEFAULT cUFilter	:= ".T."
Else
	DEFAULT cUFilter	:= ""	
Endif


// Retorna Decimais
aCtbMoeda := CTbMoeda(cMoeda)
nDecimais := aCtbMoeda[5]
                
aCampos :={	{ "CONTA"		, "C", aTamConta[1], 0 },;  		// Codigo da Conta
			{ "XPARTIDA"   	, "C", aTamConta[1] , 0 },;		// Contra Partida
			{ "TIPO"       	, "C", 01			, 0 },;			// Tipo do Registro (Debito/Credito/Continuacao)
			{ "LANCDEB"		, "N", aTamVal[1]+2, nDecimais },; // Debito
			{ "LANCCRD"		, "N", aTamVal[1]+2	, nDecimais },; // Credito
			{ "SALDOSCR"	, "N", aTamVal[1]+2, nDecimais },; 			// Saldo
			{ "TPSLDANT"	, "C", 01, 0 },; 					// Sinal do Saldo Anterior => Consulta Razao
			{ "TPSLDATU"	, "C", 01, 0 },; 					// Sinal do Saldo Atual => Consulta Razao			
			{ "HISTORICO"	, "C", nTamHist   	, 0 },;			// Historico
			{ "CCUSTO"		, "C", aTamCusto[1], 0 },;			// Centro de Custo
			{ "ITEM"		, "C", nTamItem		, 0 },;			// Item Débito
			{ "ITEMC"		, "C", nTamItem		, 0 },;			// Item  Crédito
			{ "CLVL"		, "C", nTamCLVL		, 0 },;			// Classe de Valor
			{ "DATAL"		, "D", 10			, 0 },;			// Data do Lancamento
			{ "LOTE" 		, "C", 06			, 0 },;			// Lote
			{ "SUBLOTE" 	, "C", 03			, 0 },;			// Sub-Lote
			{ "DOC" 		, "C", 06			, 0 },;			// Documento
			{ "LINHA"		, "C", 03			, 0 },;			// Linha
			{ "SEQLAN"		, "C", 03			, 0 },;			// Sequencia do Lancamento
			{ "SEQHIST"		, "C", 03			, 0 },;			// Seq do Historico
			{ "EMPORI"		, "C", 02			, 0 },;			// Empresa Original
			{ "FILORI"		, "C", nTamFilial	, 0 },;			// Filial Original
			{ "NOMOV"		, "L", 01			, 0 },;			// Conta Sem Movimento
			{ "FILIAL"		, "C", nTamFilial	, 0 }} // Filial do sistema

If !Empty(__cSegOfi) .And. __cSegOfi != "0"
	Aadd(aCampos,{"SEGOFI","C",TamSx3("CT2_SEGOFI")[1],0})
EndIf
If ! Empty(c2Moeda)
	Aadd(aCampos, { "LANCDEB_1"	, "N", aTamVal[1]+2, nDecimais }) // Debito
	Aadd(aCampos, { "LANCCRD_1"	, "N", aTamVal[1]+2, nDecimais }) // Credito
	Aadd(aCampos, { "TXDEBITO"	, "N", aTamVal[1]+2, 6 }) // Taxa Debito
	Aadd(aCampos, { "TXCREDITO"	, "N", aTamVal[1]+2, 6 }) // Taxa Credito
Endif
																	
// Se o arquivo temporario de trabalho esta aberto

oTemptable:SetFields(aCampos)
oTempTable:Create()

/*
If ( Select ( "cArqTmp" ) > 0 )
	cArqTmp->(dbCloseArea())
EndIf
*/

/*
cArqTmp := CriaTrab(aCampos, .T.)
dbUseArea( .T.,, cArqTmp, "cArqTmp", .F., .F. )
*/

lCriaInd := .T.

DbSelectArea("cArqTmp")

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria Indice Temporario do Arquivo de Trabalho 1.             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//If cTipo == "1"			// Razao por Conta

	cChave   := "FILIAL+DTOS(DATAL)+CONTA+LOTE+SUBLOTE+DOC+LINHA+EMPORI+FILORI"

dbSelectArea("cArqTmp")

If lCriaInd
	IndRegua("cArqTmp",cArqTmp,cChave,,,STR0017)  //"Selecionando Registros..."
	dbSelectArea("cArqTmp")
	//dbSetIndex(cArqTmp+OrdBagExt())
Endif	
dbSetOrder(1)
                                                                                        
If !Empty(aSetOfBook[5])
	MsgAlert(cMensagem)	
	Return
EndIf                   

//CT2->(dbGotop())

If cTipo == "1" /*.And. FunName() == 'CTBR400' */ .And. TCGetDb() $ "MSSQL7/MSSQL"  
	U_ACtbXQryRaz(oMeter,oText,oDlg,lEnd,cContaIni,cContaFim,cCustoIni,cCustoFim,;
		cItemIni,cItemFim,cCLVLIni,cCLVLFim,cMoeda,dDataIni,dDataFim,;
		aSetOfBook,lNoMov,cSaldo,lJunta,cTipo,c2Moeda,cUFilter,lSldAnt,aSelFil,lExterno)
Else
	
	//o cTIpo é sempre 1, jamais passara neste ponto:
	// Monta Arquivo para gerar o Razao
	U_ACtbXRazao(oMeter,oText,oDlg,lEnd,cContaIni,cContaFim,cCustoIni,cCustoFim,;
		cItemIni,cItemFim,cCLVLIni,cCLVLFim,cMoeda,dDataIni,dDataFim,;
		aSetOfBook,lNoMov,cSaldo,lJunta,cTipo,c2Moeda,nTipo,cUFilter,lSldAnt,aSelFil,lExterno)
	
EndIf



RestArea(aSaveArea)

Return cArqTmp

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o    ³CtbXRazao  ³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 05/02/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o ³Realiza a "filtragem" dos registros do Razao                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe    ³CtbXRazao(oMeter,oText,oDlg,lEnd,cContaIni,cContaFim,		   ³±±
±±³			  ³cCustoIni,cCustoFim, cItemIni,cItemFim,cCLVLIni,cCLVLFim,   ³±±
±±³			  ³cMoeda,dDataIni,dDataFim,aSetOfBook,lNoMov,cSaldo,lJunta,   ³±±
±±³			  ³cTipo)                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno    ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso       ³ SIGACTB                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ ExpO1 = Objeto oMeter                                  @param	       ³ ExpO2 = Objeto oText                                       ³±±
±±³           ³ ExpO3 = Objeto oDlg                                        ³±±
±±³           ³ ExpL1 = Acao do Codeblock                                  ³±±
±±³           ³ ExpC2 = Conta Inicial                                      ³±±
±±³           ³ ExpC3 = Conta Final                                        ³±±
±±³           ³ ExpC4 = C.Custo Inicial                                    ³±±
±±³           ³ ExpC5 = C.Custo Final                                      ³±±
±±³           ³ ExpC6 = Item Inicial                                       ³±±
±±³           ³ ExpC7 = Cl.Valor Inicial                                   ³±±
±±³           ³ ExpC8 = Cl.Valor Final                                     ³±±
±±³           ³ ExpC9 = Moeda                                              ³±±
±±³           ³ ExpD1 = Data Inicial                                       ³±±
±±³           ³ ExpD2 = Data Final                                         ³±±
±±³           ³ ExpA1 = Matriz aSetOfBook                                  ³±±
±±³           ³ ExpL2 = Indica se imprime movimento zerado ou nao.         ³±±
±±³           ³ ExpC10= Tipo de Saldo                                      ³±±
±±³           ³ ExpL3 = Indica se junta CC ou nao.                         ³±±
±±³           ³ ExpC11= Tipo do lancamento                                 ³±±
±±³           ³ c2Moeda = Indica moeda 2 a ser incluida no relatorio       ³±±
±±³           ³ cUFilter= Conteudo Txt com o Filtro de Usuario (CT2)       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function ACtbXRazao(oMeter,oText,oDlg,lEnd,cContaIni,cContaFim,cCustoIni,cCustoFim,;
					  	cItemIni,cItemFim,cCLVLIni,cCLVLFim,cMoeda,dDataIni,dDataFim,;
					  	aSetOfBook,lNoMov,cSaldo,lJunta,cTipo,c2Moeda,nTipo,cUFilter,lSldAnt,aSelFil,lExterno)

Local cCpoChave		:= ""
Local cTmpChave		:= ""
Local cContaI			:= ""
Local cContaF			:= ""
Local cCustoI			:= ""
Local cCustoF			:= ""
Local cValid			:= ""
Local cItemI			:= ""
Local cItemF			:= ""
Local cClVlI			:= ""
Local cClVlF			:= ""
Local cVldEnt			:= ""
Local cAlias			:= ""
Local lUFilter		:= !Empty(cUFilter)			//// SE O FILTRO DE USUÁRIO NÃO ESTIVER VAZIO - TEM FILTRO DE USUÁRIO
Local cFilMoeda		:= ""
Local cAliasCT2		:= "CT2"
Local bCond			:= {||.T.}
Local cQryFil			:= '' // variavel de condicional da query
Local cTmpCT2Fil		
Local cQuery			:= ""
Local cOrderBy		:= ""
Local nI				:= 0
Local aStru			:= {}
Local nRange			:= 0
Local cContaRang		:= ""
Local cCentroRang		:= ""
Local cItemRang		:= ""
Local cClasRang		:= ""
Local cQryTemp		:= ""
Local cAliasTemp		:= GetNextAlias()
Local cFil_Save
Local nX


DEFAULT cUFilter := ".T."
DEFAULT lSldAnt	 := .F.
DEFAULT aSelFil  := {}
DEFAULT lExterno := .F.

SaveInter()//Usado o Save Inter para salvar as Variaveis


nRange := 1
	

cQryFil := " CT2_FILIAL " + GetRngFil( aSelFil ,"CT2", .T., @cTmpCT2Fil)

cCustoI	:= CCUSTOINI
cCustoF	:= CCUSTOFIM
cContaI	:= CCONTAINI
cContaF	:= CCONTAFIM
cItemI		:= CITEMINI
cItemF		:= CITEMFIM
cClvlI		:= CCLVLINI
cClVlF 	:= CCLVLFIM



If !Empty(c2Moeda)
	cFilMoeda	:= " (CT2_MOEDLC = '" + cMoeda + "' OR "
	cFilMoeda	+= " CT2_MOEDLC = '" + c2Moeda + "') "
Else
	cFilMoeda	:= " CT2_MOEDLC = '" + cMoeda + "' "
EndIf

If !lExterno
	oMeter:nTotal := CT1->(RecCount())
Endif


//If cTipo == "1"
	dbSelectArea("CT2")
	dbSetOrder(2)
	//Verificando se foi selecionado o tipo Range e se ja esta preenchido
	If(nRange == 2)
	
		If(!Empty(cContaRang))
		
			cValid := cContaRang
		
		EndIf	
		If(!Empty(cCentroRang))
		
			cVldEnt := cCentroRang 
		
		EndIf	
		If(!Empty(cItemRang))
			
			If(!Empty(cVldEnt))
			
				cVldEnt += " AND " 
			EndIf
			cVldEnt += cItemRang 
		
		EndIf	
		if(!Empty(cClasRang))
			If(!Empty(cVldEnt))
			
				cVldEnt += " AND " 
			EndIf
			cVldEnt +=  cClasRang
			
		EndIf
	Else
	
		cValid	:= 	"CT2_DEBITO>='" + cContaIni + "'" +;
			"AND CT2_DEBITO<='" + cContaFim + "'"
		cVldEnt := 	"CT2_CCD>='" + cCustoIni + "'" +;
			"AND CT2_CCD<='" + cCustoFim + "'" +;
			"AND CT2_ITEMD>='" + cItemIni + "'" +;
			"AND CT2_ITEMD<='" + cItemFim + "'" +;
			"AND CT2_CLVLDB>='" + cClVlIni + "'" +;
			"AND CT2_CLVLDB<='" + cClVlFim + "'"
	EndIf
	cOrderBy:= " CT2_FILIAL, CT2_DEBITO, CT2_DATA "

cAliasCT2	:= "cAliasCT2"

cQuery	:= " SELECT * "
cQuery	+= " FROM " + RetSqlName("CT2")
cQuery	+= " WHERE " + cQryFil + " AND "
If(!Empty(cValid))
	cQuery	+= cValid + " AND "
EndIf
cQuery	+= " CT2_DATA >= '" + DTOS(dDataIni) + "' AND "
cQuery	+= " CT2_DATA <= '" + DTOS(dDataFim) + "' AND "
If(!Empty(cVldEnt))
	cQuery	+= cVldEnt+ " AND "
EndIf
cQuery	+= cFilMoeda + " AND "
cQuery	+= " CT2_TPSALD = '"+ cSaldo + "'"
cQuery	+= " AND (CT2_DC = '1' OR CT2_DC = '3')"
cQuery   += " AND CT2_VALOR <> 0 "
cQuery	+= " AND D_E_L_E_T_ = ' ' "
cQuery	+= " ORDER BY "+ cOrderBy
cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasCT2,.T.,.F.)
aStru := CT2->(dbStruct())

For ni := 1 to Len(aStru)
	If aStru[ni,2] != 'C'
		TCSetField(cAliasCT2, aStru[ni,1], aStru[ni,2],aStru[ni,3],aStru[ni,4])
	Endif
Next ni

If lUFilter					//// ADICIONA O FILTRO DEFINIDO PELO USUÁRIO SE NÃO ESTIVER EM BRANCO
	If !Empty(cVldEnt)
		cVldEnt  += " AND "			/// SE JÁ TIVER CONTEUDO, ADICIONA "AND"
		cVldEnt  += cUFilter				/// ADICIONA O FILTRO DE USUÁRIO
	EndIf
EndIf

If (!lUFilter) .or. Empty(cUFilter)
	cUFilter := ".T."
EndIf

dbSelectArea(cAliasCT2)
While !Eof()
	If &cUFilter
		U_ACtbXGrvRAZ(lJunta,cMoeda,cSaldo,"1",c2Moeda,cAliasCT2,nTipo)
		dbSelectArea(cAliasCT2)
	EndIf
	dbSkip()
EndDo
If ( Select ( "cAliasCT2" ) <> 0 )
	dbSelectArea ( "cAliasCT2" )
	dbCloseArea ()
Endif




// ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
// ³ Obt‚m os creditos³
// ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//If cTipo == "1"
	dbSelectArea("CT2")
	dbSetOrder(3)

cVldEnt := ""
cValid  :=	 ""

//If cTipo == "1"
	If(nRange == 2)
	
		If(!Empty(cContaRang))		
			cValid := STRTRAN(cContaRang,'CT2_DEBITO','CT2_CREDIT')
		EndIf	

		If(!Empty(cCentroRang))		
			cVldEnt := STRTRAN(cCentroRang,'CT2_CCD','CT2_CCC') 		
		EndIf	
		If(!Empty(cItemRang))
			If(!Empty(cVldEnt))
				cVldEnt += " AND " 
			EndIf			
			cVldEnt += STRTRAN(cItemRang,'CT2_ITEMD','CT2_ITEMC') 	
		EndIf	
		if(!Empty(cClasRang))
			If(!Empty(cVldEnt))
				cVldEnt += " AND " 
			EndIf			
			cVldEnt+= STRTRAN(cClasRang,'CT2_CLVLDB','CT2_CLVLCR')			
		EndIf
	
	Else
	
		cValid	:= 	"CT2_CREDIT>='" + cContaIni + "'" +;
			"AND CT2_CREDIT<='" + cContaFim + "'"
		cVldEnt :=	"CT2_CCC>='" + cCustoIni + "'" +;
			"AND CT2_CCC<='" + cCustoFim + "'" +;
			"AND CT2_ITEMC>='" + cItemIni + "'" +;
			"AND CT2_ITEMC<='" + cItemFim + "'" +;
			"AND CT2_CLVLCR>='" + cClVlIni + "'" +;
			"AND CT2_CLVLCR<='" + cClVlFim + "'"
	
	EndIf
	cOrderBy:= " CT2_FILIAL, CT2_CREDIT, CT2_DATA "

cAliasCT2	:= "cAliasCT2"

cQuery	:= " SELECT * "
cQuery	+= " FROM " + RetSqlName("CT2")
cQuery	+= " WHERE " + cQryFil + " AND "
If(!Empty(cValid))	
	cQuery	+= cValid + " AND "
EndIf
cQuery	+= " CT2_DATA >= '" + DTOS(dDataIni) + "' AND "
cQuery	+= " CT2_DATA <= '" + DTOS(dDataFim) + "' AND "
If(!Empty(cVldEnt))
	cQuery	+= cVldEnt+ " AND "
EndIf
cQuery	+= cFilMoeda + " AND "
cQuery	+= " CT2_TPSALD = '"+ cSaldo + "' AND "
cQuery	+= " (CT2_DC = '2' OR CT2_DC = '3') AND "
cQuery	+= " CT2_VALOR <> 0 AND "
cQuery	+= " D_E_L_E_T_ = ' ' "
cQuery	+= " ORDER BY "+ cOrderBy
cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasCT2,.T.,.F.)

aStru := CT2->(dbStruct())

For ni := 1 to Len(aStru)
	If aStru[ni,2] != 'C'
		TCSetField(cAliasCT2, aStru[ni,1], aStru[ni,2],aStru[ni,3],aStru[ni,4])
	Endif
Next ni


If lUFilter					//// ADICIONA O FILTRO DEFINIDO PELO USUÁRIO SE NÃO ESTIVER EM BRANCO
	If !Empty(cVldEnt)
		cVldEnt  += " AND "			/// SE JÁ TIVER CONTEUDO, ADICIONA "AND"
		cVldEnt  += cUFilter				/// ADICIONA O FILTRO DE USUÁRIO
	EndIf
EndIf

If (!lUFilter) .or. Empty(cUFilter)
	cUFilter := ".T."
EndIf

dbSelectArea(cAliasCT2)
While !Eof()
	If &cUFilter
		U_ACtbXGrvRAZ(lJunta,cMoeda,cSaldo,"2",c2Moeda,cAliasCT2,nTipo)
		dbSelectArea(cAliasCT2)
	EndIf
	dbSkip()
EndDo

If ( Select ( "cAliasCT2" ) <> 0 )
	dbSelectArea ( "cAliasCT2" )
	dbCloseArea ()
Endif



If lNoMov .or. lSldAnt

	If Len(aSelFil) == 0 .OR. (Len(aSelFil)==1 .And. aSelFil[1]==cFilAnt)
	
		//If cTipo == "1"
			
			cQryTemp := " SELECT CT1_CONTA FROM " + RetSqlName('CT1') + " WHERE CT1_FILIAL = '" + xFilial("CT1") + "'"
			cQryTemp += " AND CT1_CLASSE = '2' AND D_E_L_E_T_ = ' '"
			
			If(!Empty(cContaRang) .And. nRange == 2)
			
				cQryTemp += " AND " + STRTRAN(cContaRang,'CT2_DEBITO','CT1_CONTA')
			
			Else
			
				cQryTemp += " AND CT1_CONTA >= '"+cContaI+ "' AND CT1_CONTA <= '" + cContaF + "'"
			
			EndIf
			
			cQryTemp += " ORDER BY "+ SqlOrder( CT1->(IndexKey(3)) )
			cCpoChave := "CT1_CONTA"
			cTmpChave := "CONTA"
			
		dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryTemp),cAliasTemp,.T.,.F.)
		
		
		cAlias := cAliasTemp
		
		While ! Eof()
		
			dbSelectArea("cArqTmp")
			cKey2Seek	:= &(cAlias + "->" + cCpoChave)
			If !DbSeek(cKey2Seek)
				If lNoMov
					U_FACtbXGrvNoMov(cKey2Seek,dDataIni,cTmpChave)
				ElseIf cTipo == "1"		/// SOMENTE PARA O RAZAO POR CONTA
					/// TRATA OS DADOS PARA A PERGUNTA "IMPRIME CONTA SEM MOVIMENTO" = "NAO C/ SLD.ANT."
					If SaldoCT7Fil(cKey2Seek,dDataIni,cMoeda,cSaldo,'CTBR400')[6] <> 0 .and. cArqTMP->CONTA <> cKey2Seek
						/// SE TIVER SALDO ANTERIOR E NÃO TIVER MOVIMENTO GRAVADO
						U_FACtbXGrvNoMov(cKey2Seek,dDataIni,cTmpChave)
					Endif
				EndIf
			Endif
			DbSelectArea(cAlias)
			DbSkip()
		EndDo
		
		DbSelectArea(cAlias)
		DbClearFil()

	Else

		//salvar cfilant
		cFil_Save := cFilAnt
			
		For nX := 1 to Len(aSelFil)
			
			cFilAnt := aSelFil[nX]

				
				cQryTemp := " SELECT CT1_CONTA FROM " + RetSqlName('CT1') + " WHERE CT1_FILIAL = '" + xFilial("CT1") + "'"
				cQryTemp += " AND CT1_CLASSE = '2' AND D_E_L_E_T_ = ' '"
				
				If(!Empty(cContaRang) .And. nRange == 2)
				
					cQryTemp += " AND " + STRTRAN(cContaRang,'CT2_DEBITO','CT1_CONTA')
				
				Else
				
					cQryTemp += " AND CT1_CONTA >= '"+cContaI+ "' AND CT1_CONTA <= '" + cContaF + "'"
				
				EndIf
				
				cQryTemp += " ORDER BY "+ SqlOrder( CT1->(IndexKey(3)) )
				cCpoChave := "CT1_CONTA"
				cTmpChave := "CONTA"
			
			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQryTemp),cAliasTemp,.T.,.F.)
			
			
			cAlias := cAliasTemp
			
			While ! Eof()
			
				dbSelectArea("cArqTmp")
				cKey2Seek	:= &(cAlias + "->" + cCpoChave)
				If !DbSeek(cKey2Seek)
					If lNoMov
						U_FACtbXGrvNoMov(cKey2Seek,dDataIni,cTmpChave)
					ElseIf cTipo == "1"		/// SOMENTE PARA O RAZAO POR CONTA
						/// TRATA OS DADOS PARA A PERGUNTA "IMPRIME CONTA SEM MOVIMENTO" = "NAO C/ SLD.ANT."
						If SaldoCT7Fil(cKey2Seek,dDataIni,cMoeda,cSaldo,'CTBR400')[6] <> 0 .and. cArqTMP->CONTA <> cKey2Seek
							/// SE TIVER SALDO ANTERIOR E NÃO TIVER MOVIMENTO GRAVADO
							U_FACtbXGrvNoMov(cKey2Seek,dDataIni,cTmpChave)
						Endif
					EndIf
				Endif
				DbSelectArea(cAlias)
				DbSkip()
			EndDo
			
			DbSelectArea(cAlias)
			DbClearFil()
			DbSelectArea(cAlias)
			dbCloseArea()

		NEXT //nX := 1 to Len(aSelFil)
	
		//restaurar cfilant
		cFilAnt := cFil_Save 

	EndIf
	
Endif

RestInter()
CtbTmpErase(cTmpCT2Fil)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o    ³CtbXGrvRaz ³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 05/02/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o ³Grava registros no arq temporario - Razao                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe    ³CtbXGrvRaz(lJunta,cMoeda,cSaldo,cTipo)                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno    ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso       ³ SIGACTB                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ ExpL1 = Se Junta CC ou nao                                 ³±±
±±³           ³ ExpC1 = Moeda                                              ³±±
±±³           ³ ExpC2 = Tipo de saldo                                      ³±±
±±            ³ ExpC3 = Tipo do lancamento                                 ³±±
±±³           ³ c2Moeda = Indica moeda 2 a ser incluida no relatorio       ³±±
±±³           ³ cAliasQry = Alias com o conteudo selecionado do CT2        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function ACtbXGrvRAZ(lJunta,cMoeda,cSaldo,cTipo,c2Moeda,cAliasCT2,nTipo)

Local cConta
Local cContra
Local cCusto
Local cItem
Local cIContraaugusto
Local cCLVL
Local cChave   	:= ""
Local lFind   	:= .F.
Local lImpCPartida := GetNewPar("MV_IMPCPAR",.T.) // Se .T.,     IMPRIME Contra-Partida para TODOS os tipos de lançamento (Débito, Credito e Partida-Dobrada),
                                                  // se .F., NÃO IMPRIME Contra-Partida para NENHUM   tipo  de lançamento.
DEFAULT cAliasCT2	:= "CT2"

If !Empty(c2Moeda)
//	If cTipo == "1"
		cChave	:=	(cAliasCT2)->(CT2_DEBITO+DTOS(CT2_DATA)+CT2_LOTE+CT2_SBLOTE+CT2_DOC+CT2_LINHA+CT2_EMPORI+CT2_FILORI)
	
EndIf

	cConta 	:= (cAliasCT2)->CT2_DEBITO
	cContra	:= (cAliasCT2)->CT2_CREDIT
	cCusto	:= (cAliasCT2)->CT2_CCD
	cItem	:= (cAliasCT2)->CT2_ITEMD
	ciContra:= (cAliasCT2)->CT2_ITEMC
	cCLVL	:= (cAliasCT2)->CT2_CLVLDB

dbSelectArea("cArqTmp")
dbSetOrder(1)	
If !Empty(c2Moeda) 
	If MsSeek(cChave,.F.) 
   		While !Eof() .and.!lFind
			lFind := cCusto==cArqTmp->CCUSTO.and.cItem==cArqTmp->ITEM.and.cCLVL==cArqTmp->CLVL  
			if !lFind
				dbSkip()
			EndIf			
		EndDo
		Reclock("cArqTmp",!lFind)
	Else
		RecLock("cArqTmp",.T.)		
	EndIf
Else
	RecLock("cArqTmp",.T.)
EndIf


Replace FILIAL		With (cAliasCT2)->CT2_FILIAL
Replace DATAL		With (cAliasCT2)->CT2_DATA
Replace TIPO		With cTipo
Replace LOTE		With (cAliasCT2)->CT2_LOTE
Replace SUBLOTE		With (cAliasCT2)->CT2_SBLOTE
Replace DOC			With (cAliasCT2)->CT2_DOC
Replace LINHA		With (cAliasCT2)->CT2_LINHA
Replace CONTA		With cConta

If lImpCPartida
	Replace XPARTIDA	With cContra
EndIf

Replace CCUSTO		With cCusto
Replace ITEM		With cItem
Replace ITEMC		With cIContra
Replace CLVL		With cCLVL
Replace HISTORICO	With (cAliasCT2)->CT2_HIST
Replace EMPORI		With (cAliasCT2)->CT2_EMPORI
Replace FILORI		With (cAliasCT2)->CT2_FILORI
Replace SEQHIST		With (cAliasCT2)->CT2_SEQHIST
Replace SEQLAN		With (cAliasCT2)->CT2_SEQLAN
Replace NOMOV		With .F.							// Conta com movimento

If !Empty(__cSegOfi) .And. __cSegOfi != "0"
	Replace SEGOFI With (cAliasCT2)->CT2_SEGOFI// Correlativo para Chile
EndIf


If Empty(c2Moeda)	//Se nao for Razao em 2 Moedas

		Replace LANCDEB	With LANCDEB + (cAliasCT2)->CT2_VALOR

Else	//Se for Razao em 2 Moedas
	If (nTipo = 1 .Or. nTipo = 3) .And. (cAliasCT2)->CT2_MOEDLC = cMoeda //Se Imprime Valor na Moeda ou ambos

			Replace LANCDEB With (cAliasCT2)->CT2_VALOR	

	EndIf

	If LANCDEB_1 <> 0 .And. LANCDEB <> 0 
		Replace TXDEBITO  	With LANCDEB_1 / LANCDEB		
	Endif                                               
	If LANCCRD_1 <> 0 .And. LANCCRD <> 0
		Replace TXCREDITO 	With LANCCRD_1 / LANCCRD
	EndIf	
	If (cAliasCT2)->CT2_DC == "3"
		Replace TIPO	With cTipo
	Else
		Replace TIPO 	With (cAliasCT2)->CT2_DC
	EndIf			
EndIf

If nTipo = 1 .And. (LANCDEB + LANCCRD) = 0
	DbDelete()

Endif
If ! Empty(c2Moeda) .And. LANCDEB + LANCDEB_1 + LANCCRD + LANCCRD_1 = 0
	DbDelete()
Endif
MsUnlock()

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o    ³CtbXGrvNoMov ³ Autor ³ Pilar S. Albaladejo ³ Data ³ 05/02/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o ³Grava registros no arq temporario sem movimento.            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe    ³CtbXGrvNoMov(cConta)                                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno    ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso       ³ SIGACTB                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ cConteudo = Conteudo a ser gravado no campo chave de acordo³±±
±±³           ³             com o razao impresso                           ³±±
±±³           ³ dDataL = Data para verificacao do movimento da conta       ³±±
±±³           ³ cCpoChave = Nome do campo para gravacao no temporario      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function FACtbXGrvNoMov(cConteudo,dDataL,cCpoTmp)

dbSelectArea("cArqTmp")
dbSetOrder(1)	

RecLock("cArqTmp",.T.)      

Replace &(cCpoTmp)	With cConteudo

If cCpoTmp = "CONTA"
	Replace FILIAL      With ''//xFilial( 'CT2' )  <--------se a conta nao tem movimento em nenhuma das filiais selecionadas o sistema deixara o campo filial em branco
	Replace HISTORICO		With STR0021		//"CONTA SEM MOVIMENTO NO PERIODO"
ElseIf cCpoTmp = "CCUSTO"
	Replace FILIAL      With ''//xFilial( 'CT2' )  <--------se a conta nao tem movimento em nenhuma das filiais selecionadas o sistema deixara o campo filial em branco
	Replace HISTORICO		With Upper(AllTrim(CtbSayApro("CTT"))) + " "  + STR0026	//"SEM MOVIMENTO NO PERIODO"
ElseIf cCpoTmp = "ITEM"
	Replace FILIAL      With ''//xFilial( 'CT2' )  <--------se a conta nao tem movimento em nenhuma das filiais selecionadas o sistema deixara o campo filial em branco
	Replace HISTORICO		With Upper(AllTrim(CtbSayApro("CTD"))) + " "  + STR0026	//"SEM MOVIMENTO NO PERIODO"
ElseIf cCpoTmp = "CLVL"
	Replace FILIAL      With ''//xFilial( 'CT2' )  <--------se a conta nao tem movimento em nenhuma das filiais selecionadas o sistema deixara o campo filial em branco
	Replace HISTORICO		With Upper(AllTrim(CtbSayApro("CTH"))) + " "  + STR0026	//"SEM MOVIMENTO NO PERIODO"
Else
	Replace FILIAL      With xFilial( 'CT2' ) 

Endif



Replace DATAL 			WITH dDataL 
// Grava filial do sistema para uso no relatorio


If cCpoTmp = "CONTA"
	Replace FILORI		With ''
ElseIf cCpoTmp = "CCUSTO"
	Replace FILORI		With ''
ElseIf cCpoTmp = "ITEM"
	Replace FILORI		With ''
ElseIf cCpoTmp = "CLVL"
	Replace FILORI		With ''
Else
	Replace FILORI		With cFilAnt  
Endif


MsUnlock()


Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o    ³CtrX400Sint³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 05/02/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o ³Imprime conta sintetica da conta do razao                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe    ³CtrX400Sint( cConta,cDescSint,cMoeda,cDescConta,cCodRes	   ³±±
±±³		      |		   	 , cMoedaDesc)									   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno    ³Conta Sintetic		                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso       ³ SIGACTB                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ ExpC1 = Conta                                              ³±±
±±³           ³ ExpC2 = Descricao da Conta Sintetica                       ³±±
±±³           ³ ExpC3 = Moeda       oswaldo                                       ³±±
±±³           ³ ExpC4 = Descricao da Conta                                 ³±±
±±³           ³ ExpC5 = Codigo reduzido                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function AACtrX400Sint(cConta,cDescSint,cMoeda,cDescConta,cCodRes,cMoedaDesc)

Local aSaveArea := GetArea()

Local nPosCT1					//Guarda a posicao no CT1
Local cContaPai	:= ""
Local cContaSint	:= ""

// seta o default da descrição da moeda para a moeda corrente
Default cMoedaDesc := cMoeda
If !Empty(cConta)

	dbSelectArea("CT1")
	dbSetOrder(1)
	If dbSeek(xFilial("CT1")+cConta)
		nPosCT1 	:= Recno()
		cDescConta  := &("CT1->CT1_DESC" + cMoedaDesc )
	
		If Empty( cDescConta )
			cDescConta  := CT1->CT1_DESC01
		Endif
	
		cCodRes		:= CT1->CT1_RES
		cContaPai	:= CT1->CT1_CTASUP
	
		If dbSeek(xFilial("CT1")+cContaPai)
			cContaSint 	:= CT1->CT1_CONTA
			cDescSint	:= &("CT1->CT1_DESC" + cMoedaDesc )
	
			If Empty(cDescSint)
				cDescSint := CT1->CT1_DESC01
			Endif
		EndIf	
	
		dbGoto(nPosCT1)
	EndIf	

EndIf

RestArea(aSaveArea)

Return cContaSint

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³ Fun‡…o    ³CtbXQryRaz ³ Autor ³ Simone Mie Sato       ³ Data ³ 22/01/04 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Descri‡…o ³Realiza a "filtragem" dos registros do Razao                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe    ³CtbXQryRaz(oMeter,oText,oDlg,lEnd,cContaIni,cContaFim,	   ³±±
±±³			  ³	cCustoIni,cCustoFim, cItemIni,cItemFim,cCLVLIni,cCLVLFim,  ³±±
±±³			  ³	cMoeda,dDataIni,dDataFim,aSetOfBook,lNoMov,cSaldo,lJunta,  ³±±
±±³			  ³	cTipo)                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno    ³Nenhum                                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso       ³ SIGACTB                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros ³ ExpO1 = Objeto oMeter                                      ³±±
±±³           ³ ExpO2 = Objeto oText                                       ³±±
±±³           ³ ExpO3 = Objeto oDlg                                        ³±±
±±³           ³ ExpL1 = Acao do Codeblock                                  ³±±
±±³           ³ ExpC2 = Conta Inicial                                      ³±±
±±³           ³ ExpC3 = Conta Final                                        ³±±
±±³           ³ ExpC4 = C.Custo Inicial                                    ³±±
±±³           ³ ExpC5 = C.Custo Final                                      ³±±
±±³           ³ ExpC6 = Item Inicial                                       ³±±
±±³           ³ ExpC7 = Cl.Valor Inicial                                   ³±±
±±³           ³ ExpC8 = Cl.Valor Final                                     ³±±
±±³           ³ ExpC9 = Moeda                                              ³±±
±±³           ³ ExpD1 = Data Inicial                                       ³±±
±±³           ³ ExpD2 = Data Final                                         ³±±
±±³           ³ ExpA1 = Matriz aSetOfBook                                  ³±±
±±³           ³ ExpL2 = Indica se imprime movimento zerado ou nao.         ³±±
±±³           ³ ExpC10= Tipo de Saldo                                      ³±±
±±³           ³ ExpL3 = Indica se junta CC ou nao.                         ³±±
±±³           ³ ExpC11= Tipo do lancamento                                 ³±±
±±³           ³ c2Moeda = Indica moeda 2 a ser incluida no relatorio       ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function ACtbXQryRaz(oMeter,oText,oDlg,lEnd,cContaIni,cContaFim,cCustoIni,cCustoFim,;
				  cItemIni,cItemFim,cCLVLIni,cCLVLFim,cMoeda,dDataIni,dDataFim,;
				  aSetOfBook,lNoMov,cSaldo,lJunta,cTipo,c2Moeda,cUFilter,lSldAnt,aSelFil,lExterno)

Local aSaveArea := GetArea()
Local nMeter	:= 0
Local cQuery	:= ""
Local aTamVlr	:= TAMSX3("CT2_VALOR")     
Local lNoMovim	:= .F.
Local cContaAnt	:= ""//<-- sem uso
Local cCampUSU	:= ""
local aStrSTRU	:= {}
Local nStr			:= 0
Local cQryFil		:= '' // variavel de condicional da query
Local lImpCPartida := GetNewPar( "MV_IMPCPAR" , .T.)	// Se .T.,     IMPRIME Contra-Partida para TODOS os tipos de lançamento (Débito, Credito e Partida-Dobrada),
														// se .F., NÃO IMPRIME Contra-Partida para NENHUM   tipo  de lançamento.
Local cContaRang		:= ""
Local cCentroRang		:= ""
Local cItemRang		:= ""
Local cClasRang		:= ""
Local nRange			:= 0
Local cTmpCT2Fil

DEFAULT lSldAnt 	:= .F.
DEFAULT aSelFil 	:= {} 
DEFAULT lExterno	:= .F.
SaveInter()//Usado o Save Inter para salvar as Variaveis

	nRange := 1


// trataviva para o filtro de multifiliais 
cQryFil := " CT2.CT2_FILIAL " + GetRngFil( aSelFil, "CT2", .T., @cTmpCT2Fil )

If !lExterno 
	oMeter:SetTotal(CT2->(RecCount()))
	oMeter:Set(0)
Endif

cQuery	:= " SELECT CT2_FILIAL FILIAL, CT1_CONTA CONTA, ISNULL(CT2_CCD,'') CUSTO,ISNULL(CT2_ITEMD,'') ITEM,ISNULL(CT2_ITEMC,'') XPARTITEM, ISNULL(CT2_CLVLDB,'') CLVL, ISNULL(CT2_DATA,'') DDATA, ISNULL(CT2_TPSALD,'') TPSALD, "	
cQuery	+= " ISNULL(CT2_DC,'') DC, ISNULL(CT2_LOTE,'') LOTE, ISNULL(CT2_SBLOTE,'') SUBLOTE, ISNULL(CT2_DOC,'') DOC, ISNULL(CT2_LINHA,'') LINHA, ISNULL(CT2_CREDIT,'') XPARTIDA, ISNULL(CT2_HIST,'') HIST, ISNULL(CT2_SEQHIS,'') SEQHIS, ISNULL(CT2_SEQLAN,'') SEQLAN, '1' TIPOLAN, "	

////////////////////////////////////////////////////////////
//// TRATAMENTO PARA O FILTRO DE USUÁRIO NO RELATORIO
////////////////////////////////////////////////////////////
cCampUSU  := ""										//// DECLARA VARIAVEL COM OS CAMPOS DO FILTRO DE USUÁRIO
If !Empty(cUFilter)									//// SE O FILTRO DE USUÁRIO NAO ESTIVER VAZIO
	aStrSTRU := CT2->(dbStruct())				//// OBTEM A ESTRUTURA DA TABELA USADA NA FILTRAGEM
	nStruLen := Len(aStrSTRU)						
	For nStr := 1 to nStruLen                       //// LE A ESTRUTURA DA TABELA 
		cCampUSU += aStrSTRU[nStr][1]+","			//// ADICIONANDO OS CAMPOS PARA FILTRAGEM POSTERIOR
	Next
Endif
cQuery += cCampUSU									//// ADICIONA OS CAMPOS NA QUERY

////////////////////////////////////////////////////////////
cQuery  += " ISNULL(CT2_VALOR,0) VALOR, ISNULL(CT2_EMPORI,'') EMPORI, ISNULL(CT2_FILORI,'') FILORI"       
If !Empty(__cSegOfi) .And. __cSegOfi != "0"
	cQuery	+= ", ISNULL(CT2_SEGOFI,'') SEGOFI"
EndIf

cQuery += " FROM "+ RetSqlName("CT1") + " CT1 LEFT JOIN " + RetSqlName("CT2") + " CT2 "
cQuery += " ON " + cQryFil

cQuery	+= " AND CT2.CT2_DEBITO = CT1.CT1_CONTA"  
cQuery  += " AND CT2.CT2_DATA >= '"+DTOS(dDataIni)+ "' AND CT2.CT2_DATA <= '"+DTOS(dDataFim)+"'"
If(nRange == 2)
	
		If(!Empty(cCentroRang))
		
			cQuery += " AND " + cCentroRang
		
		EndIf	
		If(!Empty(cClasRang))
			
			cQuery += " AND " + cClasRang 
		
		EndIf	
		if(!Empty(cItemRang))
		
			cQuery+= " AND " + cItemRang
			
		EndIf
	
Else

	cQuery  += " AND CT2.CT2_CCD >= '" + cCustoIni + "' AND CT2.CT2_CCD <= '" + cCustoFim +"'"
	cQuery  += " AND CT2.CT2_ITEMD >= '" + cItemIni + "' AND CT2.CT2_ITEMD <= '"+ cItemFim +"'"
	cQuery  += " AND CT2.CT2_CLVLDB >= '" + cClvlIni + "' AND CT2.CT2_CLVLDB <= '" + cClVlFim +"'"
	
EndIf
cQuery  += " AND CT2.CT2_TPSALD = '"+ cSaldo + "'"
cQuery	+= " AND CT2.CT2_MOEDLC = '" + cMoeda +"'"
cQuery  += " AND (CT2.CT2_DC = '1' OR CT2.CT2_DC = '3') "
cQuery  += " AND CT2_VALOR <> 0 "
cQuery	+= " AND CT2.D_E_L_E_T_ = ' ' "	
cQuery	+= " WHERE CT1.CT1_FILIAL = '"+xFilial("CT1")+"' "
cQuery	+= " AND CT1.CT1_CLASSE = '2' "
If(!Empty(cContaRang) .And. nRange == 2)

	cQuery += "AND " + STRTRAN(cContaRang,'CT2_DEBITO','CT1_CONTA') 
	
Else

	cQuery	+= " AND CT1.CT1_CONTA >= '"+ cContaIni+"' AND CT1.CT1_CONTA <= '"+cContaFim+"'"
	
Endif
cQuery	+= " AND CT1.D_E_L_E_T_ = '' "

cQuery	+= " UNION "

cQuery	+= " SELECT CT2_FILIAL FILIAL, CT1_CONTA CONTA, ISNULL(CT2_CCC,'') CUSTO, ISNULL(CT2_ITEMC,'') ITEM,ISNULL(CT2_ITEMD,'') XPARTITEM, ISNULL(CT2_CLVLCR,'') CLVL, ISNULL(CT2_DATA,'') DDATA, ISNULL(CT2_TPSALD,'') TPSALD, "	
cQuery	+= " ISNULL(CT2_DC,'') DC, ISNULL(CT2_LOTE,'') LOTE, ISNULL(CT2_SBLOTE,'')SUBLOTE, ISNULL(CT2_DOC,'') DOC, ISNULL(CT2_LINHA,'') LINHA, ISNULL(CT2_DEBITO,'') XPARTIDA, ISNULL(CT2_HIST,'') HIST, ISNULL(CT2_SEQHIS,'') SEQHIS, ISNULL(CT2_SEQLAN,'') SEQLAN, '2' TIPOLAN, "	

////////////////////////////////////////////////////////////
//// TRATAMENTO PARA O FILTRO DE USUÁRIO NO RELATORIO
////////////////////////////////////////////////////////////
cCampUSU  := ""										//// DECLARA VARIAVEL COM OS CAMPOS DO FILTRO DE USUÁRIO
If !Empty(cUFilter)									//// SE O FILTRO DE USUÁRIO NAO ESTIVER VAZIO
	aStrSTRU := CT2->(dbStruct())				//// OBTEM A ESTRUTURA DA TABELA USADA NA FILTRAGEM
	nStruLen := Len(aStrSTRU)						
	For nStr := 1 to nStruLen                       //// LE A ESTRUTURA DA TABELA 
		cCampUSU += aStrSTRU[nStr][1]+","			//// ADICIONANDO OS CAMPOS PARA FILTRAGEM POSTERIOR
	Next
Endif

cQuery += cCampUSU									//// ADICIONA OS CAMPOS NA QUERY

cQuery  += " ISNULL(CT2_VALOR,0) VALOR, ISNULL(CT2_EMPORI,'') EMPORI, ISNULL(CT2_FILORI,'') FILORI"              
If !Empty(__cSegOfi) .And. __cSegOfi != "0"
	cQuery	+= ", ISNULL(CT2_SEGOFI,'') SEGOFI"
EndIf
cQuery += " FROM "+RetSqlName("CT1")+ ' CT1 LEFT JOIN '+ RetSqlName("CT2") + ' CT2 '
cQuery += " ON " + cQryFil

cQuery	+= " AND CT2.CT2_CREDIT =  CT1.CT1_CONTA "
cQuery  += " AND CT2.CT2_DATA >= '"+DTOS(dDataIni)+ "' AND CT2.CT2_DATA <= '"+DTOS(dDataFim)+"'"
If(nRange == 2)
	If(!Empty(cCentroRang))
		
		cQuery += " AND " + STRTRAN(cCentroRang,'CT2_CCD','CT2_CCC') 
		
	EndIf	
	If(!Empty(cClasRang))
			
		cQuery += " AND " + STRTRAN(cClasRang,'CT2_CCD','CT2_CCC') 
		
	EndIf	
	if(!Empty(cItemRang))
		
		cQuery+= " AND " + STRTRAN(cItemRang,'CT2_ITEMD','CT2_ITEMC')
			
	EndIf
Else

	cQuery  += " AND CT2.CT2_CCC >= '" + cCustoIni + "' AND CT2.CT2_CCC <= '" + cCustoFim +"'"
	cQuery  += " AND CT2.CT2_ITEMC >= '" + cItemIni + "' AND CT2.CT2_ITEMC <= '"+ cItemFim +"'"
	cQuery  += " AND CT2.CT2_CLVLCR >= '" + cClvlIni + "' AND CT2.CT2_CLVLCR <= '" + cClVlFim +"'"
	
EndIf

cQuery  += " AND CT2.CT2_TPSALD = '"+ cSaldo + "'"
cQuery	+= " AND CT2.CT2_MOEDLC = '" + cMoeda +"'"
cQuery  += " AND (CT2.CT2_DC = '2' OR CT2.CT2_DC = '3') "
cQuery  += " AND CT2_VALOR <> 0 "
cQuery	+= " AND CT2.D_E_L_E_T_ = ' ' "	
cQuery	+= " WHERE CT1.CT1_FILIAL = '"+xFilial("CT1")+"' "
cQuery	+= " AND CT1.CT1_CLASSE = '2' "
If(!Empty(cContaRang) .And. nRange == 2)

	cQuery += "AND " + STRTRAN(cContaRang,'CT2_DEBITO','CT1_CONTA') 
	
Else

	cQuery	+= " AND CT1.CT1_CONTA >= '"+ cContaIni+"' AND CT1.CT1_CONTA <= '"+cContaFim+"'"
		
Endif

cQuery	+= " AND CT1.D_E_L_E_T_ = ''"	            
If FunName() <> "CTBR440"
	cQuery  += " ORDER BY CONTA, DDATA"
EndIf
cQuery := ChangeQuery(cQuery)		   

If Select("cArqCT2") > 0
	dbSelectArea("cArqCT2")
	dbCloseArea()
Endif

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"cArqCT2",.T.,.F.)

TcSetField("cArqCT2","CT2_VLR"+cMoeda,"N",aTamVlr[1],aTamVlr[2])
TcSetField("cArqCT2","DDATA","D",8,0)

If !Empty(cUFilter)									//// SE O FILTRO DE USUÁRIO NAO ESTIVER VAZIO
	For nStr := 1 to nStruLen                       //// LE A ESTRUTURA DA TABELA 
		If aStrSTRU[nStr][2] <> "C" .and. cArqCT2->(FieldPos(aStrSTRU[nStr][1])) > 0
			TcSetField("cArqCT2",aStrSTRU[nStr][1],aStrSTRU[nStr][2],aStrSTRU[nStr][3],aStrSTRU[nStr][4])
		EndIf
	Next
Endif
 			
dbSelectarea("cArqCT2")

dbSelectarea("cArqCT2")
If Empty(cUFilter)
	cUFilter := ".T."
Endif						

While !Eof()                                              
	If Empty(cArqCT2->DDATA) //Se nao existe movimento 
		cContaAnt	:= cArqCT2->CONTA	
		dbSkip()
		If Empty(cArqCT2->DDATA) .And. cContaAnt == cArqCT2->CONTA
			lNoMovim	:= .T.
		EndIf
	Endif        
	
	If &("cArqCT2->("+cUFilter+")")						
		If lNoMovim
			If lNoMov  
				If CtbExDtFim("CT1")							
					dbSelectArea("CT1")
					dbSetOrder(1) 
					If MsSeek(xFilial()+cArqCT2->CONTA)
						If CtbVlDtFim("CT1",dDataIni) 
							U_FACtbXGrvNoMov(cArqCT2->CONTA,dDataIni,"CONTA")	//Esta sendo passado "CONTA" fixo, porque essa funcao esta sendo 									
						EndIf												//chamada somente para o CTBR400
					EndIf				
				Else
					U_FACtbXGrvNoMov(cArqCT2->CONTA,dDataIni,"CONTA")	//Esta sendo passado "CONTA" fixo, porque essa funcao esta sendo 				
				EndIf												//chamada somente para o CTBR400
			ElseIf lSldAnt 
				If SaldoCT7Fil(cArqCT2->CONTA,dDataIni,cMoeda,cSaldo,'CTBR400')[6] <> 0 .and. cArqTMP->CONTA <> cArqCT2->CONTA																							
					U_FACtbXGrvNoMov(cArqCT2->CONTA,dDataIni,"CONTA")	
				Endif			
			EndIf
		Else
			RecLock("cArqTmp",.T.)		    	
		    Replace FILIAL		With cArqCT2->FILIAL
		    Replace DATAL		With cArqCT2->DDATA
			Replace TIPO		With cArqCT2->DC
			Replace LOTE		With cArqCT2->LOTE
			Replace SUBLOTE	With cArqCT2->SUBLOTE
			Replace DOC		With cArqCT2->DOC
			Replace LINHA		With cArqCT2->LINHA
			Replace CONTA		With cArqCT2->CONTA			
			Replace CCUSTO		With cArqCT2->CUSTO
			Replace ITEM		With cArqCT2->ITEM
			Replace ITEMC		With cArqCT2->XPARTITEM
			Replace CLVL		With cArqCT2->CLVL
			
			

			If lImpCPartida
				Replace XPARTIDA	With cArqCT2->XPARTIDA
			EndIf		

			Replace HISTORICO	With cArqCT2->HIST
			Replace EMPORI		With cArqCT2->EMPORI
			Replace FILORI		With cArqCT2->FILORI
			Replace SEQHIST		With cArqCT2->SEQHIS
			Replace SEQLAN		With cArqCT2->SEQLAN

			If !Empty(__cSegOfi) .And. __cSegOfi != "0"
				Replace SEGOFI With cArqCT2->SEGOFI // Correlativo para Chile
			EndIf
	
			If cArqCT2->TIPOLAN = '1'
				Replace LANCDEB	With LANCDEB + cArqCT2->VALOR
			EndIf
			If cArqCT2->TIPOLAN = '2'
				Replace LANCCRD	With LANCCRD + cArqCT2->VALOR
			EndIf	
			MsUnlock()
		Endif         
	EndIf
	lNoMovim	:= .F.	
	dbSelectArea("cArqCT2")	
	dbSkip()
	nMeter++ 
	
	If !lExterno
		oMeter:Set(nMeter)		
	Endif
		
Enddo	

CtbTmpErase(cTmpCT2Fil) 
RestArea(aSaveArea)
RestInter()
Return//cContaAnt	//<-- sem uso




/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CtbQbPg   ºAutor  ³Marcos S. Lobo      º Data ³  12/02/03   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Controla a quebra de pagina dos relatorios SIGACTB          º±±
±±º          ³quando possuem os parametros de PAG.INICAL-FINAL-REINICIAR  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametro1³ lNewVars  = (.T.=Inicializa variaveis/.F.=Trata Quebra)    º±±
±±º         2³ nPagIni 	 = Pagina Inicial do relatorio.               	  º±±
±±º         3³ nPagFim 	 = Pagina Final do relatorio               	 	  º±±
±±º         4³ nReinicia = Pagina ao Reiniciar do relatorio               º±±
±±º         5³ m_pag 	 = Numero da pagina usada na Cabec()              º±±
±±º         6³ nBloco    = Bloco de paginas (intervalo de quebra)		  º±±
±±º         7³ nBlCount  = Contador de páginas (zerado na qebra de bloco) º±±
±±º         8³ l1StQb    = Indica se irá efetuar uma unica quebra         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function xCtbQbPg(lNewVars,nPagIni,nPagFim,nReinicia,m_pag,nBloco,nBlCount,l1StQb)

Local lEmissUnica := If( GetNewPar( "MV_CTBQBPG" , "M" ) == "M" , .T. , .F. ) /// U=Quebra unica (.F.) ; M=Multiplas quebras (.T.)

///As variáveis nPagIni,nPagFim,nReinicia,m_pag,nBloco,nBlCount devem ser declaradas na rotina chamadora
///e na chamada desta função como @<parametro> para obter o retorno após as alterações de conteúdo desta função.
DEFAULT lNewVars := .F.

If lEmissUnica
	If lNewVars					/// INICIALIZA AS VARIAVEIS
		nBloco		:= ( nPagFim + 1 ) - nPagIni 				/// (PAG. FIM + 1) - PAG. INICIAL - BLOCO DE PAG. PARA IMPRESSAO
		m_pag		:= nPagIni
	Else						/// NAO INICIALIZA - TRATA A QUEBRA DE PAGINA

 	nBlCount++

 	If nBlCount > nBloco 							/// SE A QUANTIDADE DE PAGINAS IMPRESSAO FOR IGUAL AO BLOCO DEFINIDO

		If nReinicia > nPagFim						/// SE A PAG. DE REINICIO FOR MAIOR QUE A PAGINA FINAL (ATUAL)
			nUltPg	  := m_pag						/// GUARDA A ULTIMA PAG. IMPRESSA
			m_pag 	  := nReinicia					/// REINICIA A NUMERACAO DE PAG. (m_pag atual ainda não foi)
			nPagFim   := nReinicia+nBloco 			/// DEFINE O NOVO NUMERO DA PAGINA FIM
			nReinicia := nPagFim+(nReinicia-nUltPg)	/// DEFINE A PROX. PAG. AO REINICIAR PELA DIFERENCA COM  FINAL
		Else										/// SE A PAG. DE REINICIO FOR MENOR OU IGUAL A PAGINA FINAL                                                                
			m_pag := nReinicia						/// SO REINICIA A NUMERACAO DE PAG.
		Endif

		nBlCount := 1   
	EndIf
  	 
Endif    
ELSE 
	IF lNewVars
		m_pag := nPagIni
	Endif    
	
  	If m_pag > nPagFim .and. l1stQb
		m_pag := nReinicia
		l1StQb := .F.
	Endif 

ENDIF
	
lNewVars := .F.

Return

Static Function xCtCGCCabec(lItem,lCusto,lCLVL,Cabec1,Cabec2,dDataFim,Titulo,lAnalitico,cTipo,Tamanho,lCtrlPage,dDtEmis)
Local lCTCABR3	:= ExistBlock("CTCABR3")                  

DEFAULT Tamanho := "G"
DEFAULT lCtrlPage	:= .F. // Controla a numeração de pagina 
DEFAULT dDtEmis	:= MsDate()

SX3->( DbSetOrder(2) )
SX3->( MsSeek( "A1_CGC" , .T. ))

If cTipo == '1'
	Tamanho := Iif(((lItem .Or. lCusto .Or. lCLVL) .And. lAnalitico),"G",Tamanho)
	nTam    := Iif(lItem .Or. lCusto .Or. lCLVL .or. Tamanho == "G", 218, 130)

Endif

RptFolha := GetNewPar( "MV_CTBPAG" , RptFolha )

If SM0->( Eof() )
	SM0->( MsSeek( cEmpAnt + cFilAnt , .T. ))
Endif

If lCtrlPage 
//	m_pag := m_pag - 1 // volta a numeração de pagina, alterada pela rotina "CABEC()"
//alert ('ente novo')
	// Renato F. Campos
	// faz o controle de numeração de pagina
	// as variaveis deverão ser declaradas no relatorio como private
	xCtbQbPg( @lNewVars, @nPagIni, @nPagFim, @nReinicia, @m_pag, @nBloco, @nBlCount, @l1StQb )
Endif

aCabec := {	"__LOGOEMP__",;
			Left(Padc(AllTrim(SM0->M0_NOMECOM),nTam),nTam-Len(RptFolha+" "+ TRANSFORM(m_pag,'999999')+ "  "))+;
			RptFolha+" "+ TRANSFORM(m_pag,'999999')+ "  ",;
			' '/*Left(Padc(Transform(Alltrim(SM0->M0_CGC),alltrim(SX3->X3_PICTURE)),nTam),nTam-Len(RptDtRef+" "+DTOC(dDataBase)))*/+RptDtRef+" "+DTOC(dDataBase),;
			Pad("SIGA /"+NomeProg+"/v."+cVersao + Padc(Trim(Titulo),nTam-(Len("SIGA /"+NomeProg+"/v."+cVersao))-If(__SetCentury(),19,17)),nTam),;
			RptHora+" "+time() + PadL(RptEmiss+ " " + Dtoc(dDtEmis),nTam-Len(RptHora+" "+time()))}



If cTipo == '1' //Se for Razao			
      
	Cabec(Titulo,Cabec1,cabec2,nomeprog,tamanho,Iif(lItem .Or. lCusto .Or. lCLVL .or. aReturn[4]==1,GetMv("MV_COMP"),		GetMv("MV_NORM")), aCabec )

Endif
		
Return



/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ValorCTB   ³ Autor ³ Pilar S Albaladejo    ³ Data ³ 15.12.99 		     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Imprime O Valor                                             			 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ValorCtb(nSaldo,nLin,nCol,nTamanho,nDecimais,lSinal,cPicture,;         ³±±
±±³          ³						cTipo,cConta,lGraf,oPrint)					  	 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.   .                                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                  			 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 = Valor                            	                 		 ³±±
±±³          ³ ExpN2 = Numero da Linha                                   		     ³±±
±±³          ³ ExpN3 = Numero da Coluna                                  		     ³±±
±±³          ³ ExpN4 = Tamanho                                           		     ³±±
±±³          ³ ExpN5 = Numero de Decimais											 ³±±
±±³          ³ ExpL1 = Se devera ser impresso com sinal ou nao.          		     ³±±
±±³          ³ ExpC1 = Picture                                           		     ³±±
±±³          ³ ExpC2 = Tipo                                              		     ³±±
±±³          ³ ExpC3 = Conta                                             		     ³±±
±±³          ³ ExpL2 = Se eh grafico ou nao                              		     ³±±
±±³          ³ ExpO1 = Objeto oPrint                                     		     ³±±
±±³          ³ ExpC4 = Tipo do sinal utilizado                           		     ³±±
±±³          ³ ExpC5 = Identificar [USADO em modo gerencial]             		     ³±±
±±³          ³ ExpL3 = Imprime zero                                      		     ³±±
±±³          ³ ExpL4 = Se .F., ao inves de imprimir retornara o valor como caracter³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function xValorCtb(	nSaldo,nLin,nCol,nTamanho,nDecimais,lSinal,cPicture,;
					cTipo,cConta,lGraf,oPrint,cTipoSinal, cIdentifi,lPrintZero,lSay, lSimCred, cTextAdic)

Local aSaveArea	:= GetArea()
Local cImpSaldo := ""
Local lDifZero	:= .T.
Local lInformada:= .T.
Local cCharSinal:= ""
Local nIdx      := 0
Local nIdxNew      := 0
Local cNewChar  := ""
Local lPrimeiroBranco := .F.
Local cNewImpSaldo    := ""
Local cAuxImpSaldo := ''

Default cTextAdic := ""
		    	
lPrintZero := Iif(lPrintZero==Nil,.T.,lPrintZero)

// Nao imprime o valor 0,00
If !lPrintZero
	If (Int(nSaldo*100)/100) == 0
		lDifZero := .F.			// O saldo nao eh diferente de zero
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tipo D -> Default (D/C)												  ³
//³ Tipo S -> Imprime saldo com sinal									  ³
//³ Tipo P -> Imprime saldo entre parenteses (qdo. negativo)	  ³
//³ Tipo C -> So imprime "C" (o "D" nao e impresso)              ³
//³ Tipo N -> Imprime saldo com sinal (-) se o saldo for credor³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFAULT cTipoSinal := GetMV("MV_TPVALOR")       // Assume valor default

DEFAULT lSay := .T.
Default lSimCred := .F.

cTipo 		:= Iif(cTipo == Nil, Space(1), cTipo)
nDecimais	:= Iif(nDecimais==Nil,GetMv("MV_CENT"),nDecimais)

dbSelectArea("CT1")
dbSetOrder(1)

If !Empty(cConta) .And. Empty(cTipo)
	If MsSeek(cFilial+cConta)
		cTipo := CT1->CT1_NORMAL
	Endif
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Retorna a picture. Caso nao exista espaco, retira os pontos  ³
//³ separadores de dezenas, centenas e milhares 					  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Empty(cPicture)
	If cTipoSinal $ "D/C"
		cPicture := TmContab(Abs(nSaldo),nTamanho,nDecimais)
	Else
		cPicture := TmContab(nSaldo,nTamanho,nDecimais)
	EndIf
	lInformada  := .F.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³* Alguns valores, apesar de  terem sinal devem ser impressos  ³
//³ sem sinal (lSinal). Ex: valores de colunas Debito e Credito  ³
//³* Se estiver com a opcao de lingua estrangeira (lEstrang) a   ³
//³ picture sera invertida para exibir valores: 999,999,999.99   ³
//³* O tipo de sinal "D" - default nao leva em consideracao a    ³
//³ a natureza da conta. Dessa forma valores negativos serao	  ³
//³ impressos sem sinal, e ao seu lado "D" (Devedor) e valores   ³
//³ positivos terao um "C" (Credito) impresso ao seu lado.       ³
//³* O tipo de Sinal "P" - Parenteses, imprimira valores de saldo³
//³  invertidos da condicao normal da conta entre parenteses.	  ³
//³* O tipo de Sinal "S" - Sinal, imprimira valores de saldo in- ³
//³  vertidos da condicao normal da conta com sinal - 			  ³
//³EXEMPLOS  -  EXEMPLOS  -  EXEMPLOS	-	EXEMPLOS  - EXEMPLOS   ³
//³Cond Normal 	Saldo 	Default      Sinal   Parenteses		  ³
//³	D			   -1000	   1000 D 		 1000		 1000			  	  ³
//³	D				 1000 	1000 C		-1000 	(1000)			  ³
//³	C				-1000 	1000 D		-1000 	(1000)			  ³
//³	C				 1000 	1000 C		 1000 	 1000 			  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

// So imprime valor se for diferente de zero!
If lDifZero
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Neste caso (Default), nao importa a natureza da conta! Saldos³
	//³ devedores serao impressos com "D" e credores com "C".        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	// Neste caso, nao importa a natureza da conta!!
	If cTipoSinal == "D" .Or. cTipoSinal == "C" .Or. cTipoSinal == "N"			// D(Default) ou C(so Credito)
		If !lInformada
			cPicture := "@E " + cPicture
		Endif
		If lSinal
			If nSaldo < 0
				If lGraf
					If cTipoSinal == "D"
						cCharSinal := Iif(cPaisLoc<>"MEX","D","C")
					EndIf
				Else
					// No Tipo C -> so sao impressos os "C´s"
					If cTipoSinal == "D"
						cCharSinal := Iif(cPaisLoc<>"MEX","D","C")
					EndIf
				Endif
			ElseIf nSaldo > 0
				If lGraf
					If cIdentifi # Nil .And. cIdentifi $ "34"
						If cTipoSinal == "D"
							cCharSinal := Iif(cPaisLoc<>"MEX","C","A")
						EndIf
					Else
						cCharSinal := Iif(cPaisLoc<>"MEX","C","A")
					Endif
				Else
					cCharSinal := Iif(cPaisLoc<>"MEX","C","A")
				Endif
			EndIf
			cCharSinal := " "+cCharSinal
		EndIf
		
		//Se o parametro MV_TPVALOR == "N" => nao considera a condicao normal da conta.
		//So imprime sinal (-) se o saldo for credor.
		If cTipoSinal == "N"
			
			If lSinal
				cImpSaldo := Transform(nSaldo*(-1),cPicture)
			Else
				cImpSaldo := Transform(ABS(nSaldo),cPicture)
			EndIf
			
			
		Else
			cImpSaldo := Transform(Abs(nSaldo),cPicture)+cCharSinal
			
			
		EndIf
		
		If lGraf
			If cIdentifi # Nil .And. cIdentifi $ "34"
			
				If !Empty(cTextAdic)
					cImpSaldo := cTextAdic + ": " + cImpSaldo
				EndIf
				
				If cIdentifi == "3" .And. Type("oCouNew08N") <> "U"
					oPrint:Say(nLin,nCol,cImpSaldo,oCouNew08N)
				Else
					oPrint:Say(nLin,nCol,cImpSaldo,oCouNew08S)
				EndIf
			Else
			
				If !Empty(cTextAdic)
					cImpSaldo := cTextAdic + ": " + cImpSaldo
				EndIf
			
				oPrint:Say(nLin,nCol,cImpSaldo,oFont08)
			Endif
		ElseIf lSay
		    If lSimCred
		    
		    	nIdxNew         := 0
		    	nIdx            := Len(cImpSaldo)
		    	cNewChar        := ""
		    	lPrimeiroBranco := .F.	
		    	cNewImpSaldo    := ""
		    	
		    	If nIdx > 0
			    	While nIdx > 0
			    		
			    		cNewChar := substr(cImpSaldo,nIdx,1)
			    		
			    		If Empty(cNewChar)
			    			lPrimeiroBranco := .T.
			    			exit//identificou posicao em branco imediata antes do numero
			    		EndIf 	
			    		
			    		nIdx -= 1
			    	End	
		    	
			    	For nIdxNew := 1 to Len(cImpSaldo)
			    	
			    		If nIdxNew == nIdx
			    			cNewImpSaldo += "-"
			    		Else
			    			cNewImpSaldo += substr(cImpSaldo, nIdxNew, 1)
			    		EndIf
			    	Next
			    	
			    	cImpSaldo := cNewImpSaldo
			    	
					If !Empty(cTextAdic)
						cImpSaldo := cTextAdic + ": " + cImpSaldo
					EndIf
		    	EndIf
		    	
		    	
		    	
		    	
		    	@ nLin, nCol pSay (cImpSaldo) 
			Else
				If !Empty(cTextAdic)
					cImpSaldo := cTextAdic + ": " + cImpSaldo
				EndIf
				@ nLin, nCol pSay cImpSaldo
			EndIf
			
		Endif
		
	Else
		//Utiliza conceito de conta estourada e a conta eh redutora.
		If Select("cArqTmp") > 0 .And. cArqTmp->(FieldPos("ESTOUR")) <> 0 .And.  cArqTmp->ESTOUR == "1"
			If cTipo == "1" 								// Conta Devedora
				If cTipoSinal == "S"              			// Sinal
					If !lSinal
						nSaldo := Abs(nSaldo)
					EndIf
					If !lInformada
						cPicture := "@E " + cPicture
					EndIf
					If lGraf
						cImpSaldo := Transform(nSaldo,cPicture)
						If cIdentifi # Nil .And. cIdentifi $ "34"
						
							If !Empty(cTextAdic)
								cImpSaldo := cTextAdic + ": " + cImpSaldo
							EndIf
							
							If cIdentifi == "3" .And. Type("oCouNew08N") <> "U"
								oPrint:Say(nLin,nCol,cImpSaldo,oCouNew08N)
							Else
								oPrint:Say(nLin,nCol,cImpSaldo,oCouNew08S)
							EndIf
						Else
						
							If !Empty(cTextAdic)
								cImpSaldo := cTextAdic + ": " + cImpSaldo
							EndIf
							
							oPrint:Say(nLin,nCol,cImpSaldo,oFont08)
						Endif
					ElseIf lSay
						@ nLin, nCol PSAY nSaldo Picture cPicture
					Else
					
							
						cImpSaldo := Transform(nSaldo,cPicture)
					Endif
				ElseIf (cTipoSinal) == "P"              	// Parenteses
					If !lSinal
						nSaldo := Abs(nSaldo)
					EndIf
					
					If !lInformada
						cPicture := "@E( " + cPicture
					EndIf
					If lGraf
						cImpSaldo := Transform(nSaldo,cPicture)
						If cIdentifi # Nil .And. cIdentifi $ "34"
						
							If !Empty(cTextAdic)
								cImpSaldo := cTextAdic + ": " + cImpSaldo
							EndIf
							
							If cIdentifi == "3" .And. Type("oCouNew08N") <> "U"
								oPrint:Say(nLin,nCol,cImpSaldo,oCouNew08N)
							Else
								oPrint:Say(nLin,nCol,cImpSaldo,oCouNew08S)
							EndIf
						Else
						
							If !Empty(cTextAdic)
								cImpSaldo := cTextAdic + ": " + cImpSaldo
							EndIf
							
							oPrint:Say(nLin,nCol,cImpSaldo,oFont08)
						Endif
					ElseIf lSay
						@ nLin, nCol pSay nSaldo Picture cPicture
					Else
					
							
						cImpSaldo := Transform(nSaldo,cPicture)
					Endif
				EndIf
			Else
				If (cTipoSinal) == "S"                  	// Sinal
					If lSinal
						nSaldo := nSaldo * (-1)
					Else
						nSaldo := Abs(nSaldo)
					EndIf
					If !lInformada
						cPicture := "@E " + cPicture
					EndIf
					If lGraf
						cImpSaldo := Transform(nSaldo,cPicture)
						
						If !Empty(cTextAdic)
							cImpSaldo := cTextAdic + ": " + cImpSaldo
						EndIf
						
						If cIdentifi # Nil .And. cIdentifi $ "34"
							If cIdentifi == "3" .And. Type("oCouNew08N") <> "U"
								oPrint:Say(nLin,nCol,cImpSaldo,oCouNew08N)
							Else
								oPrint:Say(nLin,nCol,cImpSaldo,oCouNew08S)
							EndIf
						Else
							oPrint:Say(nLin,nCol,cImpSaldo,oFont08)
						Endif
						
					ElseIf lSay
						@ nLin, nCol PSAY nSaldo Picture cPicture
					Else
							
						cImpSaldo := Transform(nSaldo,cPicture)
					Endif
				ElseIf (cTipoSinal) == "P"              // Parenteses
					If lSinal
						nSaldo := nSaldo * (-1)
					Else
						nSaldo := Abs(nSaldo)
					EndIf
					If !lInformada
						cPicture := "@E( " + cPicture
					EndIf
					If lGraf
						cImpSaldo := Transform(nSaldo,cPicture)			// Debito
						If cIdentifi # Nil .And. cIdentifi $ "34"
						
							If !Empty(cTextAdic)
								cImpSaldo := cTextAdic + ": " + cImpSaldo
							EndIf
							If cIdentifi == "3" .And. Type("oCouNew08N") <> "U"
								oPrint:Say(nLin,nCol,cImpSaldo,oCouNew08N)
							Else
								oPrint:Say(nLin,nCol,cImpSaldo,oCouNew08S)
							EndIf
						Else
							If !Empty(cTextAdic)
								cImpSaldo := cTextAdic + ": " + cImpSaldo
							EndIf
							oPrint:Say(nLin,nCol,cImpSaldo,oFont08)
						Endif
					ElseIf lSay
						@ nLin, nCol pSay nSaldo Picture cPicture
					Else
					
							
						cImpSaldo := Transform(nSaldo,cPicture)
					Endif
				EndIf
			EndIf
		Else	//Se nao utiliza conceito de conta estourada
			If cTipo == "1" 								// Conta Devedora
				If cTipoSinal == "S"              			// Sinal
					If lSinal
						nSaldo := nSaldo * (-1)
					Else
						nSaldo := Abs(nSaldo)
					EndIf
					If !lInformada
						cPicture := "@E " + cPicture
					EndIf
					If lGraf
						cImpSaldo := Transform(nSaldo,cPicture)
						If cIdentifi # Nil .And. cIdentifi $ "34"
						
							If !Empty(cTextAdic)
								cImpSaldo := cTextAdic + ": " + cImpSaldo
							EndIf
							
							If cIdentifi == "3" .And. Type("oCouNew08N") <> "U"
								oPrint:Say(nLin,nCol,cImpSaldo,oCouNew08N)
							Else
								oPrint:Say(nLin,nCol,cImpSaldo,oCouNew08S)
							EndIf
						Else
						
							If !Empty(cTextAdic)
								cImpSaldo := cTextAdic + ": " + cImpSaldo
							EndIf
							oPrint:Say(nLin,nCol,cImpSaldo,oFont08)
						Endif
					ElseIf lSay
						If !Empty(cTextAdic)
							@ nLin, nCol PSAY cTextAdic + ": "
							@ nLin, nCol+Len(cTextAdic)+3 PSAY  nSaldo Picture cPicture
						Else
							@ nLin, nCol PSAY  nSaldo Picture cPicture
						ENdIf
					Else
					
						cImpSaldo := Transform(nSaldo,cPicture)
					Endif
				ElseIf (cTipoSinal) == "P"              	// Parenteses
					If lSinal
						nSaldo := nSaldo * (-1) 		  		// a Picture so exibe parenteses para numeros negativos
					Else
						nSaldo := Abs(nSaldo)
					EndIf
					
					If !lInformada
						cPicture := "@E( " + cPicture
					EndIf
					If lGraf
						cImpSaldo := Transform(nSaldo,cPicture)
						
						If !Empty(cTextAdic)
							cImpSaldo := cTextAdic + ": " + cImpSaldo
						EndIf
						
						If cIdentifi # Nil .And. cIdentifi $ "34"
							If cIdentifi == "3" .And. Type("oCouNew08N") <> "U"
								oPrint:Say(nLin,nCol,cImpSaldo,oCouNew08N)
							Else
								oPrint:Say(nLin,nCol,cImpSaldo,oCouNew08S)
							EndIf
						Else
						
						
							If !Empty(cTextAdic)
								cImpSaldo := cTextAdic + ": " + cImpSaldo
							EndIf
							
							oPrint:Say(nLin,nCol,cImpSaldo,oFont08)
						Endif
					ElseIf lSay
							
						If !Empty(cTextAdic)
							@ nLin, nCol PSAY cTextAdic + ": "
							@ nLin, nCol+Len(cTextAdic)+3 PSAY  nSaldo Picture cPicture
						Else
							@ nLin, nCol PSAY  nSaldo Picture cPicture
						ENdIf
						
					Else
						cImpSaldo := AllTrim(Transform(nSaldo,cPicture))
					Endif
				EndIf
			Else
				If (cTipoSinal) == "S"                  	// Sinal
					If !lSinal .And. cTipo == "2" 			// Conta Credora
						nSaldo := Abs(nSaldo)
					EndIf
					If !lInformada
						cPicture := "@E " + cPicture
					EndIf
					If lGraf
						cImpSaldo := Transform(nSaldo,cPicture)
						
						if !Empty(cTextAdic)
							cImpSaldo := cTextAdic + ": " + cImpSaldo
						EndIf
						
						If cIdentifi # Nil .And. cIdentifi $ "34"
							If cIdentifi == "3" .And. Type("oCouNew08N") <> "U"
								oPrint:Say(nLin,nCol,cImpSaldo,oCouNew08N)
							Else
								oPrint:Say(nLin,nCol,cImpSaldo,oCouNew08S)
							EndIf
						Else
							oPrint:Say(nLin,nCol,cImpSaldo,oFont08)
						Endif
					ElseIf lSay
						cAuxImpSaldo := Transform(nSaldo, cPicture)  //<--------------------------------------------------------------------------------------
						
						nIdxNew         := 0
				    	nIdx            := Len(Transform(nSaldo, cPicture))
				    	cNewChar        := ""
				    	lPrimeiroBranco := .F.	
				    	cNewImpSaldo    := ""
				    	
				    	If nIdx > 0
					    	While nIdx > 0
					    		
					    		cNewChar := substr(cAuxImpSaldo,nIdx,1)
					    		
					    		If Empty(cNewChar)
					    			lPrimeiroBranco := .T.
					    			exit//identificou posicao em branco imediata antes do numero
					    		EndIf 	
					    		
					    		nIdx -= 1
					    	End	
				    	
					    	For nIdxNew := 1 to Len(cAuxImpSaldo)
					    	
					    		If nIdxNew == nIdx
					    			If lSImCred
					    				cNewImpSaldo += "-"
					    			Else
					    				cNewImpSaldo += " "
					    			ENdIf
					    		Else
					    			cNewImpSaldo += substr(cAuxImpSaldo, nIdxNew, 1)
					    		EndIf
					    	Next
					    	
						EndIf
		    	
		    
						If !Empty(cTextAdic)
							@ nLin, nCol PSAY cTextAdic + ": "
							
//--->								@ nLin, nCol PSAY  "-"
                                
							@ nLin, nCol+Len(cTextAdic)+3 PSAY   cNewImpSaldo //  nSaldo Picture cPicture
							
							
						Else
							@ nLin, nCol PSAY " "
							
//--->							@ nLin, nCol PSAY  "- "
								
							@ nLin, nCol PSAY  cNewImpSaldo //Picture cPicture
						EndIf
						
					Else
						cImpSaldo := Transform(nSaldo,cPicture)
					Endif
					
				ElseIf (cTipoSinal) == "P"              // Parenteses
					If !lSinal .And. cTipo == "2" 			// Conta Credora
						nSaldo := Abs(nSaldo)
					EndIf
					If !lInformada
						cPicture := "@E( " + cPicture
					EndIf
					If lGraf
						cImpSaldo := Transform(nSaldo,cPicture)			// Debito
						If cIdentifi # Nil .And. cIdentifi $ "34"
						
						
							If !Empty(cTextAdic)
								cImpSaldo := cTextAdic + ": " + cImpSaldo
							EndIf
							
							If cIdentifi == "3" .And. Type("oCouNew08N") <> "U"
								oPrint:Say(nLin,nCol,cImpSaldo,oCouNew08N)
							Else
								oPrint:Say(nLin,nCol,cImpSaldo,oCouNew08S)
							EndIf
						Else
							If !Empty(cTextAdic)
								cImpSaldo := cTextAdic + ": " + cImpSaldo
							EndIf
							oPrint:Say(nLin,nCol,cImpSaldo,oFont08)
						Endif
					ElseIf lSay
						If !Empty(cTextAdic)
							@ nLin, nCol PSAY cTextAdic + ": "
							@ nLin, nCol+Len(cTextAdic)+3 PSAY  nSaldo Picture cPicture
						Else
							@ nLin, nCol pSay nSaldo Picture cPicture
						EndIf
						
					Else
						cImpSaldo := Transform(nSaldo,cPicture)
						
					 
					Endif
				EndIf
			EndIf
		EndIf
	EndIf
EndIf
RestArea(aSaveArea)

If lSay
	Return
Else
	
	If lSimCred .And. lPrimeiroBranco == .F.
		    
		nIdxNew         := 0
		nIdx            := Len(cImpSaldo)
		cNewChar        := ""
		lPrimeiroBranco := .F.	
		cNewImpSaldo    := ""
		    	
		If nIdx > 0
			    	While nIdx > 0
			    		
			    		cNewChar := substr(cImpSaldo,nIdx,1)
			    		
			    		If Empty(cNewChar)
			    			lPrimeiroBranco := .T.
			    			exit//identificou posicao em branco imediata antes do numero
			    		EndIf 	
			    		
			    		nIdx -= 1
			    	End	
		    	
			    	For nIdxNew := 1 to Len(cImpSaldo)
			    	
			    		If nIdxNew == nIdx
			    			cNewImpSaldo += "-"
			    		Else
			    			cNewImpSaldo += substr(cImpSaldo, nIdxNew, 1)
			    		EndIf
			    	Next
			    	
			    	cImpSaldo := cNewImpSaldo
		EndIf
	ENdIf
	
	
	If Empty( cImpSaldo )
		If lPrintZero
			cImpSaldo := Transform(nSaldo,cPicture)
		EndIf
	EndIf
	Return cImpSaldo
EndIf

return


 /*
AjustaSX1
monta perguntas

@author TOTVS
@since 09/12/2014
@version 1.0
*/
Static Function AjustaSX1(cPerg)


PutSx1(cPerg, "01", "Conta De?", "Conta De?", "Conta De?",                   "mv_ch1", "C", 20, 0, 0, "G", "", "CT1", "", "", "MV_PAR01", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", , , )
PutSx1(cPerg, "02", "Conta Ate?", "Conta Ate?", "Conta Ate?",                "mv_ch2", "C", 20, 0, 0, "G", "", "CT1", "", "", "MV_PAR02", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", , , )
PutSx1(cPerg, "03", "Data De", "Data De", "Data De",                         "mv_ch3", "D", 08, 0, 0, "G", "", "", "", "", "MV_PAR03", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", , , )
PutSx1(cPerg, "04", "Data Ate", "Data Ate", "Data Ate",                      "mv_ch4", "D", 08, 0, 0, "G", "", "", "", "", "MV_PAR04", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", , , )
PutSx1(cPerg, "05", "Moeda?", "Moeda?", "Moeda?",                            "mv_ch5", "C", 2, 0, 0, "G", "", "CTO", "", "", "MV_PAR05", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", , , )
PutSX1(cPerg, "06", "Tipo Saldo", "Tipo Saldo", "Tipo Saldo",    "MV_CH6", "C", 1, 0, 1, "G", "", "SLW", "", "", "MV_PAR06", "", "", "", "", "", "", "")
PutSX1(cPerg, "07", "Conta Sem Movto", "Conta Sem Movto", "Conta Sem Movto", "MV_CH7", "N", 1, 0, 1, "C", "", "", "", "", "MV_PAR07", "Sim", "Sim", "Sim", "", "Não", "Não", "Não")
PutSX1(cPerg, "08", "Impr Cod Conta", "Impr Cod Conta", "Impr Cod Conta",    "MV_CH8", "N", 1, 0, 1, "C", "", "", "", "", "MV_PAR08", "Normal", "Normal", "Normal", "", "Reduzido", "Reduzido", "Reduzido")
PutSX1(cPerg, "09", "Seleciona Filiais", "Seleciona Filiais", "Seleciona Filiais",                   "MV_CH9", "N", 1, 0, 1, "C", "", "", "", "", "MV_PAR09", "Sim", "Sim", "Sim", "", "Não", "Não", "Não")


return


Static Function FazCtCGCCabTR(lItem,lCusto,lCLVL,Cabec1,Cabec2,dDataFim,Titulo,lAnalitico,cTipo,Tamanho,aCab,oReport,lCtrlPage,lNewVars,nPagIni,nPagFim,nReinicia,nPag,nBloco,nBlCount,l1StQb,dDataIni)

Local cNmEmp   
Local cChar			:= chr(160)  // caracter dummy para alinhamento do cabeçalho
Local lCTCABR4		:= ExistBlock("CTCABR4")
Local cCodigo       := Alltrim(SM0->M0_CGC)
Local nAno   	    := ""
Local lCtbr520      := FunName() == "CTBR520"
Local lCtbr047      := FunName() == "CTBR047"
Local lCtbr510      := FunName() == "CTBR510" 
Local lCtbr700      := FunName() == "CTBR700"
Local cFormato      := ""
Local cDoc			 

DEFAULT aCab 		:= {}
DEFAULT lCtrlPage	:= .F. // Controla a numeração de pagina
DEFAULT lNewVars	:= .F.
DEFAULT nPagIni		:= 1
DEFAULT nPagFim		:= 99999
DEFAULT nReinicia	:= 1
DEFAULT nPag		:= 1
DEFAULT nBloco		:= 1
DEFAULT nBlCount	:= 0
DEFAULT l1StQb		:= .F. 
DEFAULT dDataIni    := cTod('01/01/04')

SX3->( DbSetOrder(2) )
SX3->( MsSeek( "A1_CGC" , .t.))

If SM0->(Eof())                                
	SM0->( MsSeek( cEmpAnt + cFilAnt , .T. ))
Endif

RptFolha := GetNewPar( "MV_CTBPAG" , RptFolha )

Aadd( aCab, AllTrim( SM0->M0_NOMECOM ))
Aadd( aCab, AllTrim( titulo ) )

If cPaisLoc == "BRA" 
	If Len(cCodigo)>11 
		Aadd( aCab, '')//Transform( Alltrim( SM0->M0_CGC ), alltrim("@R 99.999.999/9999-99")))
		cDoc := aCab[3]
	Else
		Aadd( aCab, '')//Transform( Alltrim( SM0->M0_CGC ), alltrim("@R 999.999.999-99")))
		cDoc := aCab[3]
	EndIf
Else
	Aadd( aCab, '')//Transform( Alltrim( SM0->M0_CGC ), alltrim( SX3->X3_PICTURE )))
	cDoc := aCab[3]
EndIf

If lCtrlPage
	nPag++

	// Renato F. Campos
	// faz o controle de numeração de pagina
	// as variaveis deverão ser declaradas no relatorio como private
	CtbQbPg( @lNewVars, @nPagIni, @nPagFim, @nReinicia, @nPag, @nBloco, @nBlCount, @l1StQb )

	oReport:SetPageNumber( nPag )
Endif

//Protecao para NomeProg nao declarada
If type( 'NomeProg' ) == 'U'
	NomeProg := FunName()
EndIf


//****************************************************
// Ponto de Entrada para Manipular o Nome da Empresa *
//  nos relatorios do CTB.                           *
//****************************************************
If !ExistBlock("CTBCABRAZ")
	cNmEmp	:= AllTrim( SM0->M0_NOMECOM )
Else 
	cNmEmp	:= AllTrim( Execblock( "CTBCABRAZ" , .F.,.F. ) )
Endif

aCabec := {	"__LOGOEMP__"; 
		  , cChar + "         " + cNmEmp ;
		  + "         " + cChar + RptFolha+ TRANSFORM(oReport:Page(),'999999');
          , cChar + "         " + cDoc;
          + "         " + cChar + RptDtRef + " " + DTOC(dDataBase);
          , "SIGA /" + NomeProg + "/v." + cVersao ;
          + "         " + cChar + AllTrim(titulo) ;
          + "         " + cChar;
          , RptHora + " " + time() ;
          + "         " + cChar + RptEmiss + " " + Dtoc(MsDate()) }

//Ponto de Entrada para customizacao do cabecalho
If lCTCABR4
	aCabec := ExecBlock("CTCABR4",.F.,.F.)
Endif         

Return aCabec