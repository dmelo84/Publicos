#Include "ctbr040.Ch"
          
#Include "PROTHEUS.Ch"       
#INCLUDE "FILEIO.CH"


#DEFINE 	COL_SEPARA1			1
#DEFINE 	COL_CONTA 			2
#DEFINE 	COL_SEPARA2			3
#DEFINE 	COL_DESCRICAO		4
#DEFINE 	COL_SEPARA3			5
#DEFINE 	COL_SALDO_ANT    	6
#DEFINE 	COL_SEPARA4			7
#DEFINE 	COL_VLR_DEBITO   	8
#DEFINE 	COL_SEPARA5			9 
#DEFINE 	COL_VLR_CREDITO  	10
#DEFINE 	COL_SEPARA6			11
#DEFINE 	COL_MOVIMENTO 		12
#DEFINE 	COL_SEPARA7			13                                                                                       
#DEFINE 	COL_SALDO_ATU 		14
#DEFINE 	COL_SEPARA8			15   
#DEFINE 	TAM_VALOR			20   

Static cTpValor  := "D"
STATIC lFWCodFil := FindFunction("FWCodFil")

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ XCtbr040	³ Autor ³ Pilar S Albaladejo	³ Data ³ 12.09.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Balancete Analitico Sintetico Modelo 1			 		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Ctbr040()                               			 		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ Nenhum       											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso    	 ³ Generico     											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function XCtbr040()
Local lImpBalR4		:= TRepInUse()
Private cTeste := '' 
Private titulo		:= ""
Private nomeprog	:= "CTBR040" 
Private cStrPulp := ''
Private nStrNroPulp := 0

cTpValor := Alltrim(GetMV("MV_TPVALOR"))    
	
If lImpBalR4
		
		U_XACTBR040R4()
Else
		U_XBCTBR040R3()
		
EndIf
	
//Limpa os arquivos temporários 
CTBGerClean()

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ XACTBR040R4 ³ Autor³ Daniel Sakavicius		³ Data ³ 01/08/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Balancete Analitico Sintetico Modelo 1 - R4                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe	 ³ CTBR040R4												  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SIGACTB                                    				  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function XACTBR040R4(wnRel)
Local nQuadro		:= 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Interface de impressao                                                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

Private aQuadro		:= { "","","","","","","",""}              
Private aSelFil		:= {} 
Private n_pagini	:= 0

Default wnRel		:= "" 	 

For nQuadro :=1 To Len(aQuadro)
	aQuadro[nQuadro] := Space(Len(CriaVar("CT1_CONTA")))
Next	

CtbCarTxt()

Pergunte("CTR040",.F.)

oReport := ReportDef(wnRel)

If Valtype( oReport ) == 'O'
	If ! Empty( oReport:uParam )
		Pergunte( oReport:uParam, .F. )
	EndIf	
	
	oReport:PrintDialog()      
Endif
	
oReport := Nil

Return                                

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportDef ³ Autor ³ Daniel Sakavicius		³ Data ³ 28/07/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Esta funcao tem como objetivo definir as secoes, celulas,   ³±±
±±³          ³totalizadores do relatorio que poderao ser configurados     ³±±
±±³          ³pelo relatorio.                                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ SIGACTB                                    				  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ReportDef(wnRel)
local aArea	   		:= GetArea()   
Local CREPORT		:= "CTBR040"
Local CTITULO		:= "Emissao do Relat. Conf. Dig. " //'STR0006'				   			// "Emissao do Relat. Conf. Dig. "
Local CDESC			:= "Este programa ira imprimir o Relatorio para Conferencia"//OemToAnsi('STR0001')+OemToAnsi('STR0002')+OemToAnsi('STR0003')			// "Este programa ira imprimir o Relatorio para Conferencia"
Local cPerg	   		:= "CTR040" 
Local CCOLBAR		:= "|"                   
Local aTamConta		:= TAMSX3("CT1_CONTA")    
Local aTamVal		:= TAMSX3("CT2_VALOR")
Local aTamDesc		:= {40}  
Local cPictVal 		:= PesqPict("CT2","CT2_VALOR")
Local nDecimais		:= 0
Local cMascara		:= ""
Local cSeparador	:= ""
Local nTamConta		:= 20
Local aSetOfBook	:= {}
Local nMaskFator 	:= 1 

Default wnRel		:= ""

// Efetua a pergunta antes de montar a configuração do relatorio, afim de poder definir o layout a ser impresso
Pergunte( "CTR040" , .T. )

If mv_par30 == 1 .And. Len( aSelFil ) <= 0  .And. !IsBlind()
	aSelFil := AdmGetFil()
	If Len( aSelFil ) <= 0
		Return
	EndIf 
EndIf
	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se usa Set Of Books + Plano Gerencial (Se usar Plano³
//³ Gerencial -> montagem especifica para impressao)	    	  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ! U_ct040XValid( mv_par06 )
	Return .F.
Else
   aSetOfBook := CTBSetOf( mv_par06 )
Endif

cMascara := RetMasCtb( aSetOfBook[2], @cSeparador )

If ! Empty( cMascara )
	nTamConta := aTamConta[1] + ( Len( Alltrim( cMascara ) ) / 2 )
Else
	nTamConta := aTamConta[1]
EndIf

cPicture := aSetOfBook[4]

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao do componente de impressao                                      ³
//³                                                                        ³
//³TReport():New                                                           ³
//³ExpC1 : Nome do relatorio                                               ³
//³ExpC2 : Titulo                                                          ³
//³ExpC3 : Pergunte                                                        ³
//³ExpB4 : Bloco de codigo que sera executado na confirmacao da impressao  ³
//³ExpC5 : Descricao                                                       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

//"Este programa tem o objetivo de emitir o Cadastro de Itens Classe de Valor "
//"Sera impresso de acordo com os parametros solicitados pelo"
//"usuario"
oReport	:= TReport():New( cReport,Capital(CTITULO),cPerg, { |oReport| Pergunte(cPerg , .F. ), If(! ReportPrint( oReport, wnRel ), oReport:CancelPrint(), .T. ) }, CDESC ) 
oReport:ParamReadOnly()

//Habilitado o parametro de personalização porém,
// não será permitido a alteração das sections
IF GETNEWPAR("MV_CTBPOFF",.T.)
	oReport:SetEdit(.F.)
ENDIF	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Criacao da secao utilizada pelo relatorio                               ³
//³                                                                        ³
//³TRSection():New                                                         ³
//³ExpO1 : Objeto TReport que a secao pertence                             ³
//³ExpC2 : Descricao da seçao                                              ³
//³ExpA3 : Array com as tabelas utilizadas pela secao. A primeira tabela   ³
//³        sera considerada como principal para a seção.                   ³
//³ExpA4 : Array com as Ordens do relatório                                ³
//³ExpL5 : Carrega campos do SX3 como celulas                              ³
//³        Default : False                                                 ³
//³ExpL6 : Carrega ordens do Sindex                                        ³
//³        Default : False                                                 ³
//³                                                                        ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oSection1  := TRSection():New( oReport, 'STR0027', {"cArqTmp","CT1"},, .F., .F.,,,,,,,,,0 ) //"Plano de contas"

TRCell():New( oSection1, "FILIAL"	,,'EMP-FIL'/*Titulo*/	,/*Picture*/, nTamConta /*Tamanho*/, /*lPixel*/, /*CodeBlock*/, /*"LEFT"*/,,/*"LEFT"*/,,,.F.)

TRCell():New( oSection1, "CONTA"	,,'CONTA'/*Titulo*/	,/*Picture*/, nTamConta /*Tamanho*/, /*lPixel*/, /*CodeBlock*/, /*"LEFT"*/,,/*"LEFT"*/,,,.F.)
TRCell():New( oSection1, "DESCCTA"  ,,'DESCRICAO'/*Titulo*/	,/*Picture*/, aTamDesc[1]/*Tamanho*/, /*lPixel*/,/*CodeBlock*/,  /*"LEFT"*/,.T.,/*"LEFT"*/,,,.F.)

TRCell():New( oSection1, "SALDOANT" ,,'SALDO ANTERIOR'/*Titulo*/	,/*Picture*/, TAM_VALOR+2 /*Tamanho*/, /*lPixel*/, /*CodeBlock*/, /*"RIGHT"*/,,  "LEFT",,,.F.)
TRCell():New( oSection1, "SALDODEB" ,,'VALOR DEBITO'/*Titulo*/	,/*Picture*/, TAM_VALOR+2 /*Tamanho*/, /*lPixel*/, /*CodeBlock*/, /*"RIGHT"*/,,"LEFT",,,.F.)
TRCell():New( oSection1, "SALDOCRD" ,,'VALOR CREDITO'/*Titulo*/	,/*Picture*/, TAM_VALOR+2 /*Tamanho*/, /*lPixel*/, /*CodeBlock*/, /*"RIGHT"*/,,"LEFT",,,.F.)
TRCell():New( oSection1, "MOVIMENTO",,'MOVIMENTO PERIODO'/*Titulo*/	,/*Picture*/, TAM_VALOR+2 /*Tamanho*/, /*lPixel*/, /*CodeBlock*/, /*"RIGHT"*/,,"LEFT",,,.F.)
TRCell():New( oSection1, "SALDOATU" ,,'SALDO ATUAL'/*Titulo*/	,/*Picture*/, TAM_VALOR+2 /*Tamanho*/, /*lPixel*/, /*CodeBlock*/, /*"RIGHT"*/,,"LEFT",,,.F.)

TRPosition():New( oSection1, "CT1", 1, {|| xFilial( "CT1" ) + cArqTMP->CONTA })

oSection1:Cell("FILIAL"):lHeaderSize		:= .F.

oSection1:Cell("CONTA"):lHeaderSize		:= .F.
oSection1:Cell("DESCCTA"):lHeaderSize	:= .F. 
oSection1:Cell("SALDOANT"):lHeaderSize	:= .F.
oSection1:Cell("SALDODEB"):lHeaderSize	:= .F.
oSection1:Cell("SALDOCRD"):lHeaderSize	:= .F.
oSection1:Cell("MOVIMENTO"):lHeaderSize	:= .F.
oSection1:Cell("SALDOATU"):lHeaderSize	:= .F.  

oSection1:SetTotalInLine(.F.)          
oSection1:SetTotalText('') //STR0011) //"T O T A I S  D O  P E R I O D O: "
oSection1:SetEdit(.F.)

Return( oReport )

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ReportPrint³ Autor ³ Daniel Sakavicius	³ Data ³ 28/07/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Imprime o relatorio definido pelo usuario de acordo com as  ³±±
±±³          ³secoes/celulas criadas na funcao ReportDef definida acima.  ³±±
±±³          ³Nesta funcao deve ser criada a query das secoes se SQL ou   ³±±
±±³          ³definido o relacionamento e filtros das tabelas em CodeBase.³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ReportPrint(oReport)                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³EXPO1: Objeto do relatório                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function ReportPrint( oReport, wnRel )  
local cCHave := ""
Local oSection1 	:= oReport:Section(1) 
Local lExterno		:= .F.   
Local aSetOfBook	:= {}
Local dDataFim 		:= mv_par02
Local lFirstPage	:= .T.
Local lJaPulou		:= .F.
Local lRet			:= .T.
Local lPrintZero	:= (mv_par18==1)
Local lPula			:= (mv_par17==1) 
Local lNormal		:= (mv_par19==1)
Local lVlrZerado	:= (mv_par07==1)
Local lQbGrupo		:= (mv_par11==1) 
Local lQbConta		:= (mv_par11==2)
Local l132			:= .T.
Local nDecimais		:= 0
Local nDivide		:= 1
Local nTotDeb		:= 0
Local nTotCrd		:= 0
Local nTotMov		:= 0
Local nGrpDeb		:= 0
Local nGrpCrd		:= 0                     
Local cSegAte   	:= mv_par21
Local nDigitAte		:= 0
Local lImpAntLP		:= (mv_par22 == 1)
Local dDataLP		:= mv_par23
Local lImpSint		:= Iif(mv_par05=1 .Or. mv_par05 ==3,.T.,.F.)
Local lRecDesp0		:= (mv_par25 == 1)
Local lImpMov		:= (mv_par16 == 1)
Local cRecDesp		:= mv_par26
Local dDtZeraRD		:= mv_par27
Local n				:= 0
Local oMeter		:= Nil
Local oText			:= Nil
Local oDlg			:= Nil
Local oBreak		:= Nil
Local lImpPaisgm	:= .F.	
Local nMaxLin   	:= mv_par28
Local cMoedaDsc		:= mv_par29
Local aCtbMoeda		:= {}
Local aCtbMoedadsc	:= {}
Local CCOLBAR		:= "|"                   
Local cTipoAnt		:= ""
Local cGrupoAnt		:= ""
Local cArqTmp		:= ""
Local Tamanho		:= "M"
Local cSeparador	:= ""
Local aTamVal		:= TAMSX3("CT2_VALOR")
Local oTotGerDeb	:= Nil		
Local oTotGerCrd	:= Nil 
Local oTotGerMov	:= Nil
Local oTotGrpMov	:= Nil
Local cPicture		:= ""
Local cContaSint	:= ""
Local cBreak		:= "2"
Local cGrupo		:= ""
Local nTotGerDeb	:= 0
Local nTotGerCrd	:= 0
Local nTotGerMov	:= 0
Local nCont			:= 0
Local cFilUser		:= ""
Local nMasc			:= 0
Local cMasc			:= ""  
Local lEnd			:= .F.
Local dDataRef		:= Ctod("//")
Private lCncFIlial := .F.
Private nLinReport	:= 9

Default wnRel		:= ""
     
n_pagini 	  := MV_PAR09

If oReport:nDevice == 5 .OR. oReport:nDevice == 3 
	oSection1:Cell("SALDOANT"):SetAlign("RIGHT")  
	oSection1:Cell("SALDODEB"):SetAlign("RIGHT")
	oSection1:Cell("SALDOCRD"):SetAlign("RIGHT")
	oSection1:Cell("MOVIMENTO"):SetAlign("RIGHT")  
	oSection1:Cell("SALDOATU"):SetAlign("RIGHT")     
Endif 


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se usa Set Of Books + Plano Gerencial (Se usar Plano³
//³ Gerencial -> montagem especifica para impressao)	    	  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ! U_ct040XValid( mv_par06 )
	Return .F.
Else
   aSetOfBook := CTBSetOf(mv_par06)
Endif

If mv_par20 == 2			// Divide por cem
	nDivide := 100
ElseIf mv_par20 == 3		// Divide por mil
	nDivide := 1000
ElseIf mv_par20 == 4		// Divide por milhao
	nDivide := 1000000
EndIf	     

aSetOfBook[9] := nDivide

If lRet
	aCtbMoeda := CtbMoeda( mv_par08 , nDivide )

	If Empty(aCtbMoeda[1])                       
		Help(" ",1,"NOMOEDA")
		lRet := .F.
		Return lRet
	Endif

    // validação da descrição da moeda
	if lRet .And. ! Empty( mv_par29 ) .and. mv_par29 <> nil
		aCtbMoedadsc := CtbMoeda( mv_par29 , nDivide )

		If Empty( aCtbMoedadsc[1] )                       
    		Help( " " , 1 , "NOMOEDA")
	        lRet := .F.
    	    Return lRet
	    Endif
	Endif
Endif

If lRet
	If (mv_par25 == 1) .and. ( Empty(mv_par26) .or. Empty(mv_par27) )
		cMensagem	:= "Favor preencher os parametros Grupos Receitas/Despesas e "
		cMensagem	+= "Data Sld Ant. Receitas/Desp. "
		MsgAlert(cMensagem,'Ignora Sl Ant.Rec/Des')	 //"Ignora Sl Ant.Rec/Des"
		lRet    	:= .F.	
	    Return lRet
    EndIf
EndIf

aCtbMoeda  	:= CtbMoeda(mv_par08,nDivide)                

cDescMoeda 	:= Alltrim(aCtbMoeda[2])
nDecimais 	:= DecimalCTB(aSetOfBook,mv_par08)

If Empty(aSetOfBook[2])
	cMascara := GetMv("MV_MASCARA")
Else
	cMascara 	:= RetMasCtb(aSetOfBook[2],@cSeparador)
EndIf
cPicture 		:= aSetOfBook[4]

lPrintZero	:= Iif(mv_par18==1,.T.,.F.)

If oReport:Title() == oReport:cRealTitle
	IF mv_par05 == 1
		Titulo:=	OemToAnsi('BALANCETE DE VERIFICACAO SINTETICO DE ')	//"BALANCETE DE VERIFICACAO SINTETICO DE "
	ElseIf mv_par05 == 2
		Titulo:=	OemToAnsi('BALANCETE DE VERIFICACAO ANALITICO DE ')	//"BALANCETE DE VERIFICACAO ANALITICO DE "
	ElseIf mv_par05 == 3
		Titulo:=	OemToAnsi('BALANCETE DE VERIFICACAO DE ')	//"BALANCETE DE VERIFICACAO DE "
	EndIf
	Titulo += 	DTOC(mv_par01) + ' Ate '/*OemToAnsi('STR0007')*/ + Dtoc(mv_par02) + ;
			/*OemToAnsi('STR0008')*/ ' Moeda ' + cDescMoeda + CtbTitSaldo(mv_par10)           
Else
	Titulo := oReport:Title()
Endif

oReport:SetPageNumber( mv_par09 )

If wnRel == "CTBR041"
	dDataRef := MV_PAR01
Else
	dDataRef := MV_PAR02
Endif

oReport:SetCustomText( {|| nCtCGCCabTR(dDataFim,titulo,oReport,dDataRef)})

cFilUser := oSection1:GetAdvplExpr("CT1")    
If Empty(cFilUser)
	cFilUser := ".T."
EndIf	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Arquivo Temporario para Impressao			  		     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
            


If lExterno  .or. IsBlind()

	u_xCTGerPlan(oMeter, oText, oDlg, @lEnd,@cArqTmp,;
				mv_par01,mv_par02,"CT7","",mv_par03,mv_par04,,,,,,,mv_par08,;
				mv_par10,aSetOfBook,mv_par12,mv_par13,mv_par14,mv_par15,;
				.F.,.F.,mv_par11,,lImpAntLP,dDataLP,nDivide,lVlrZerado,,,,,,,,,,,,,,lImpSint,cFilUser,lRecDesp0,;
				cRecDesp,dDtZeraRD,,,,,,,cMoedaDsc,,aSelFil) 
				
Else
	MsgMeter({|	oMeter, oText, oDlg, lEnd | ;
					u_xCTGerPlan(oMeter, oText, oDlg, @lEnd,@cArqTmp,;
					mv_par01,mv_par02,"CT7","",mv_par03,mv_par04,,,,,,,mv_par08,;
					mv_par10,aSetOfBook,mv_par12,mv_par13,mv_par14,mv_par15,;
					.F.,.F.,mv_par11,,lImpAntLP,dDataLP,nDivide,lVlrZerado,,,,,,,,,,,,,,lImpSint,cFilUser,lRecDesp0,;
					cRecDesp,dDtZeraRD,,,,,,,cMoedaDsc,,aSelFil)},;
					OemToAnsi(OemToAnsi("Criando Arquivo Temporario...")),;  //"Criando Arquivo Temporario..."
					OemToAnsi("Balancete Verificacao"))  				//"Balancete Verificacao"
EndIf                                                          


nCount := cArqTmp->(RecCount())//treport
/*
cArqTmp->(DbGoTop())
cChave := "FILIAL+CONTA"  //alliar

IndRegua("cArqTmp",cArqTmp,cChave,,,'STR0017')  //"Selecionando Registros..."
dbSelectArea('cArqTmp')

DbClearIndex()

dbSetIndex(cArqTmp+OrdBagExt())
*/
oReport:SetMeter(nCont)

lRet := !(nCount == 0 .And. !Empty(aSetOfBook[5]))

If lRet
	      
	// Verifica Se existe filtragem Ate o Segmento
  	If ! Empty( cSegAte )
		
		//Efetua tratamento da mascara para consegui efetuar o controle do segmento 
		For nMasc := 1 to Len( cMascara )
			
			cMasc += SubStr( cMascara,nMasc,1 )
			
		Next nMasc
	
	
		nDigitAte := CtbRelDig( cSegAte, cMasc ) 	

		oSection1:SetFilter( 'Len(Alltrim(cArqTmp->CONTA)) <= ' + alltrim( Str( nDigitAte )) )  
	EndIf	 

	cArqTmp->(dbGoTop())
	
	oSection1:Cell("FILIAL"):SetBlock(  {||cArqTmp->FILIAL } )
	
	If lNormal
		oSection1:Cell("CONTA"):SetBlock( {|| xEntidadeCTB(cArqTmp->FILIAL,cArqTmp->CONTA,000,000,045,.F.,cMascara,cSeparador,,,.F.,,.F.,lNormal)} )
	Else
		oSection1:Cell("CONTA"):SetBlock( {|| xEntidadeCTB(cArqTmp->FILIAL,If(cArqTmp->TIPOCONTA == "2",cArqTmp->CTARES,cArqTmp->CONTA),000,000,045,.F.,,cSeparador,cAlias,,.F.,,.F.,lNormal)} )
	EndIf	
	
	oSection1:Cell("DESCCTA"):SetBlock( { || cArqTMp->DESCCTA } )
	If cTpValor != "P"	
	  	oSection1:Cell("SALDOANT"):SetBlock( { || ValorCTB(cArqTmp->SALDOANT,,,TAM_VALOR-2,nDecimais,.T.,cPicture,cArqTmp->NORMAL,,,,,,lPrintZero,.F.) } )
	  	oSection1:Cell("SALDODEB"):SetBlock( { || ValorCTB(cArqTmp->SALDODEB,,,TAM_VALOR,nDecimais,.F.,cPicture,"1",,,,,,lPrintZero,.F.) } )
	  	oSection1:Cell("SALDOCRD"):SetBlock( { || ValorCTB(cArqTmp->SALDOCRD,,,TAM_VALOR,nDecimais,.F.,cPicture,"2",,,,,,lPrintZero,.F.) } )
	    oSection1:Cell("SALDOATU"):SetBlock( { || ValorCTB(cArqTmp->SALDOATU,,,TAM_VALOR-2,nDecimais,.T.,cPicture,cArqTmp->NORMAL,,,,,,lPrintZero,.F.) } )	    
	Else	
	  	oSection1:Cell("SALDOANT"):SetBlock( { || PadL(ValorCTB(cArqTmp->SALDOANT,,,TAM_VALOR-2,nDecimais,.T.,cPicture,cArqTmp->NORMAL,,,,,,lPrintZero,.F.),TAM_VALOR) } )
	  	oSection1:Cell("SALDODEB"):SetBlock( { || PadL(ValorCTB(cArqTmp->SALDODEB,,,TAM_VALOR,nDecimais,.F.,cPicture,"1",,,,,,lPrintZero,.F.),TAM_VALOR) } )
	  	oSection1:Cell("SALDOCRD"):SetBlock( { || PadL(ValorCTB(cArqTmp->SALDOCRD,,,TAM_VALOR,nDecimais,.F.,cPicture,"2",,,,,,lPrintZero,.F.),TAM_VALOR) } )
	    oSection1:Cell("SALDOATU"):SetBlock( { || PadL(ValorCTB(cArqTmp->SALDOATU,,,TAM_VALOR-2,nDecimais,.T.,cPicture,cArqTmp->NORMAL,,,,,,lPrintZero,.F.),TAM_VALOR) } )
	EndIf
	
	//	 Imprime Movimento
  	If !lImpMov   
  		oSection1:Cell("MOVIMENTO"):SetSize(0)
 		oSection1:Cell("MOVIMENTO"):Disable()
 	ElseIf cTpValor != "P"
 		oSection1:Cell("MOVIMENTO"):SetBlock( { || ValorCTB(cArqTmp->MOVIMENTO,,,TAM_VALOR-2,nDecimais,.T.,cPicture,cArqTmp->NORMAL,,,,,, lPrintZero,.F.) } )
 	Else
 		oSection1:Cell("MOVIMENTO"):SetBlock( { || PadL(ValorCTB(cArqTmp->MOVIMENTO,,,TAM_VALOR-2,nDecimais,.T.,cPicture,cArqTmp->NORMAL,,,,,, lPrintZero,.F.),TAM_VALOR) } ) 	
 	EndIf

	If lQbGrupo

		//*********************************
		// Total por Grupo do relatorio   *
		//*********************************
	
		oBrkGrupo := TRBreak():New(oSection1, { || cArqTmp->GRUPO },{|| 'STR0020'+" "+ RTrim( Upper(AllTrim(cGrupo) )) + " )" },,,.T.)	//	" T O T A I S "
	  	oBrkGrupo:OnBreak( { |x| cGrupo := x, If(cArqTmp->(Eof()),oBrkGrupo:lPageBreak := .F.,.T.)} )
	
		oTotGrpDeb := TRFunction():New(oSection1:Cell("SALDODEB"),,"SUM",oBrkGrupo/*oBreak*/,/*Titulo*/,/*cPicture*/,;
			{ || Iif(cArqTmp->TIPOCONTA="1",0,cArqTmp->SALDODEB) },.F.,.F.,.F.,oSection1)
		oTotGrpDeb:Disable()		
				
		oTotGrpCrd := TRFunction():New(oSection1:Cell("SALDOCRD"),,"SUM",oBrkGrupo/*oBreak*/,/*Titulo*/,/*cPicture*/,;
			{ || Iif(cArqTmp->TIPOCONTA="1",0,cArqTmp->SALDOCRD) },.F.,.F.,.F.,oSection1)
		oTotGrpCrd:Disable() 
		
		If cTpValor != "P"	
			TRFunction():New(oSection1:Cell("SALDODEB"),,"ONPRINT",oBrkGrupo/*oBreak*/,/*Titulo*/,/*cPicture*/,;
				{ || ValorCTB(oTotGrpDeb:GetValue(),,,TAM_VALOR,nDecimais,.F.,cPicture,"1",,,,,,lPrintZero,.F.) },.F.,.F.,.F.,oSection1 )
	
			TRFunction():New(oSection1:Cell("SALDOCRD"),,"ONPRINT",oBrkGrupo/*oBreak*/,/*Titulo*/,/*cPicture*/,;
				{ || ValorCTB(oTotGrpCrd:GetValue(),,,TAM_VALOR,nDecimais,.F.,cPicture,"2",,,,,,lPrintZero,.F.) },.F.,.F.,.F.,oSection1 )
		Else
			TRFunction():New(oSection1:Cell("SALDODEB"),,"ONPRINT",oBrkGrupo/*oBreak*/,/*Titulo*/,/*cPicture*/,;
				{ || PadL(ValorCTB(oTotGrpDeb:GetValue(),,,TAM_VALOR,nDecimais,.F.,cPicture,"1",,,,,,lPrintZero,.F.),TAM_VALOR) },.F.,.F.,.F.,oSection1 )
	
			TRFunction():New(oSection1:Cell("SALDOCRD"),,"ONPRINT",oBrkGrupo/*oBreak*/,/*Titulo*/,/*cPicture*/,;
				{ || PadL(ValorCTB(oTotGrpCrd:GetValue(),,,TAM_VALOR,nDecimais,.F.,cPicture,"2",,,,,,lPrintZero,.F.),TAM_VALOR) },.F.,.F.,.F.,oSection1 )		
		EndIf
                                                             
	 	If !lImpMov   	 	
	 	 	oTotGrpMov := TRFunction():New(oSection1:Cell("MOVIMENTO"),,"SUM", oBrkGrupo,/*Titulo*/,/*cPicture*/,;
			{ || Iif(cArqTmp->TIPOCONTA="1",0,(cArqTmp->SALDOCRD - cArqTmp->SALDODEB)) },.F.,.F.,.F.,oSection1)
		   	oTotGrpMov:Disable()  
   	  
			If cTpValor != "P"	
	 			TRFunction():New(oSection1:Cell("MOVIMENTO"),,"ONPRINT",oBrkGrupo/*oBreak*/,/*Titulo*/,/*cPicture*/,;
	 			{ || ValorCTB(oTotGrpMov:GetValue(),,,TAM_VALOR-2,nDecimais,.T.,cPicture,If(Round(NoRound(oTotGrpMov:GetValue(),3),2) < 0, "1","2"),,,,,,lPrintZero,.F.)},.F.,.F.,.F.,oSection1) 
	 		Else
	 			TRFunction():New(oSection1:Cell("MOVIMENTO"),,"ONPRINT",oBrkGrupo/*oBreak*/,/*Titulo*/,/*cPicture*/,;
	 			{ || PadL(ValorCTB(oTotGrpMov:GetValue(),,,TAM_VALOR-2,nDecimais,.T.,cPicture,If(Round(NoRound(oTotGrpMov:GetValue(),3),2) < 0, "1","2"),,,,,,lPrintZero,.F.),TAM_VALOR)},.F.,.F.,.F.,oSection1) 	 		 			
	 		EndIf
		Endif		
	EndIf

	//******************************
	// Total Geral do relatorio    *
	//******************************
	oBrkGeral := TRBreak():New(oSection1, { || cArqTmp->(!Eof()) },{|| " T O T A I S " },,,.F.)	//	" T O T A I S "

	// Totaliza
	oTotGerDeb := TRFunction():New(oSection1:Cell("SALDODEB"),,"SUM",/*oBreak*/,/*Titulo*/,/*cPicture*/,;
		{ || Iif(cArqTmp->TIPOCONTA="1",0,cArqTmp->SALDODEB) },.F.,.F.,.F.,oSection1)
   	oTotGerDeb:Disable()

	oTotGerCrd := TRFunction():New(oSection1:Cell("SALDOCRD"),,"SUM",/*oBreak*/,/*Titulo*/,/*cPicture*/,;
		{ || Iif(cArqTmp->TIPOCONTA="1",0,cArqTmp->SALDOCRD) },.F.,.F.,.F.,oSection1)
   	oTotGerCrd:Disable()     

                    
	If cTpValor != "P"	
	    TRFunction():New(oSection1:Cell("SALDODEB"),,"ONPRINT",oBrkGeral/*oBreak*/,/*Titulo*/,/*cPicture*/,;
	  		{ || ValorCTB(oTotGerDeb:GetValue(),,,TAM_VALOR,nDecimais,.F.,cPicture,"1",,,,,,lPrintZero,.F.) },.F.,.F.,.F.,oSection1)
		                    		
	 	TRFunction():New(oSection1:Cell("SALDOCRD"),,"ONPRINT",oBrkGeral/*oBreak*/,/*Titulo*/,/*cPicture*/,;
	 		{ || ValorCTB(oTotGerCrd:GetValue(),,,TAM_VALOR,nDecimais,.F.,cPicture,"2",,,,,,lPrintZero,.F.)},.F.,.F.,.F.,oSection1) 
	Else	 		
	    TRFunction():New(oSection1:Cell("SALDODEB"),,"ONPRINT",oBrkGeral/*oBreak*/,/*Titulo*/,/*cPicture*/,;
	  		{ || PadL(ValorCTB(oTotGerDeb:GetValue(),,,TAM_VALOR,nDecimais,.F.,cPicture,"1",,,,,,lPrintZero,.F.),TAM_VALOR) },.F.,.F.,.F.,oSection1)
		                    		
	 	TRFunction():New(oSection1:Cell("SALDOCRD"),,"ONPRINT",oBrkGeral/*oBreak*/,/*Titulo*/,/*cPicture*/,;
	 		{ || PadL(ValorCTB(oTotGerCrd:GetValue(),,,TAM_VALOR,nDecimais,.F.,cPicture,"2",,,,,,lPrintZero,.F.),TAM_VALOR)},.F.,.F.,.F.,oSection1) 
	EndIf

 	If lImpMov  
 	 	oTotGerMov := TRFunction():New(oSection1:Cell("MOVIMENTO"),,"SUM",/*oBreak*/,/*Titulo*/,/*cPicture*/,;
			{ || Iif(cArqTmp->TIPOCONTA="1",0,(cArqTmp->SALDOCRD - cArqTmp->SALDODEB)) },.F.,.F.,.F.,oSection1)
	   	oTotGerMov:Disable()  
   	  
		If cTpValor != "P"	
 			TRFunction():New(oSection1:Cell("MOVIMENTO"),,"ONPRINT",oBrkGeral/*oBreak*/,/*Titulo*/,/*cPicture*/,;
 				{ || ValorCTB(oTotGerMov:GetValue(),,,TAM_VALOR-2,nDecimais,.T.,cPicture,If(Round(NoRound(oTotGerMov:GetValue(),3),2) < 0, "1","2"),,,,,,lPrintZero,.F.)},.F.,.F.,.F.,oSection1) 
 		Else
 			TRFunction():New(oSection1:Cell("MOVIMENTO"),,"ONPRINT",oBrkGeral/*oBreak*/,/*Titulo*/,/*cPicture*/,;
 				{ || Padl(ValorCTB(oTotGerMov:GetValue(),,,TAM_VALOR-2,nDecimais,.T.,cPicture,If(Round(NoRound(oTotGerMov:GetValue(),3),2) < 0, "1","2"),,,,,,lPrintZero,.F.),TAM_VALOR)},.F.,.F.,.F.,oSection1)  		
 		EndIf
    Endif

	oSection1:OnPrintLine( {|| 	U_CXTR040OnPrint( lPula, lQbConta, nMaxLin, @cTipoAnt, @nLinReport, @cGrupoAnt ) } )
           
	oSection1:Print()

	If mv_par24 ==1     
	    oReport:Section(1):SetHeaderSection(.F.)                                                       
		ImpQuadro(Tamanho,X3USO("CT2_DCD"),dDataFim,mv_par08,aQuadro,cDescMoeda,oReport:ClassName(),(If (lImpAntLP,dDataLP,cTod(""))),cPicture,nDecimais,lPrintZero,mv_par10,oReport)
	EndIf	

EndIf     

dbSelectArea("cArqTmp")
Set Filter To
dbCloseArea()
If Select("cArqTmp") == 0
	FErase(cArqTmp+GetDBExtension())
	FErase(cArqTmp+OrdBagExt())
EndIF	

Return .T.

  
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³CXTR040OnPrint ºAutor ³ Gustavo Henrique º Data ³ 07/02/07   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Executa acoes especificadas nos parametros do relatorio,   º±±
±±º          ³ antes de imprimir cada linha.                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³ EXPL1 - Indicar se deve saltar linha entre conta sintetica º±±
±±º          ³ EXPL2 - Indicar se deve quebrar pagina por conta           º±±
±±º          ³ EXPN3 - Informar o total de linhas por pagina do balancete º±±
±±º          ³ EXPC4 - Guardar o tipo da conta impressa (sint./analitica) º±±
±±º          ³ EXPN5 - Guardar linha atual do relatorio para validacao    º±±
±±º          ³         com o valor do parametro EXPN3.                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ EXPL1 - Indicar se deve imprimir a linha (.T.)             º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Contabilidade Gerencial                                    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function CXTR040OnPrint( lPula, lQbConta, nMaxLin, cTipoAnt, nLinReport )
                                                                        
Local lRet := .T.
Local dDataFim := mv_par02            

// Verifica salto de linha para conta sintetica (mv_par17)
If lPula .And. (cTipoAnt == "1" .Or. (cArqTmp->TIPOCONTA == "1" .And. cTipoAnt == "2"))
	oReport:SkipLine()
EndIf	

// Verifica quebra de pagina por conta (mv_par11)
If lQbConta .And. cArqTmp->NIVEL1
	oReport:EndPage()
	nLinReport := 9
	Return
EndIf	

// Verifica numero maximo de linhas por pagina (mv_par28)
If ! Empty(nMaxLin)
	CTR040MaxL(nMaxLin,@nLinReport)
EndIf	

cTipoAnt := cArqTmp->TIPOCONTA

If mv_par05 == 1		// Apenas sinteticas
	lRet := (cArqTmp->TIPOCONTA == "1")
	nCtCGCCabTR(dDataFim,titulo,oReport)
ElseIf mv_par05 == 2	// Apenas analiticas
	lRet := (cArqTmp->TIPOCONTA == "2")
	nCtCGCCabTR(dDataFim,titulo,oReport)  
EndIf

Return lRet


/*
------------------------------------------------------------------------- RELEASE 3 -------------------------------------------------------------------------------
*/



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ XBCtbr040R3³ Autor ³ Pilar S Albaladejo	³ Data ³ 12.09.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Balancete Analitico Sintetico Modelo 1			 		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Ctbr040()                               			 		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno	 ³ Nenhum       											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso    	 ³ Generico     											  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum													  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function XBCtbR040R3(wnRel)

Local aSetOfBook
Local aCtbMoeda	:= {}
LOCAL cDesc1 		:= "Este programa ira imprimir o Balancete de Verificacao Modelo 1 (80 Colunas), a"//OemToAnsi('STR0001')	//"Este programa ira imprimir o Balancete de Verificacao Modelo 1 (80 Colunas), a"
LOCAL cDesc2 		:= "conta e impressa limitando-se a 20 caracteres e sua descricao 30 caracteres,"//OemToansi('STR0002')   //"conta e impressa limitando-se a 20 caracteres e sua descricao 30 caracteres,"
LOCAL cDesc3		:= "os valores impressao sao saldo anterior, debito, credito e saldo atual do periodo."//OemToansi('STR0016')   //"os valores impressao sao saldo anterior, debito, credito e saldo atual do periodo."
LOCAL cString		:= "CT1"
Local cTitOrig		:= ""
Local lRet			:= .T.
Local nDivide		:= 1
Local lExterno 	:= .F.
Local nQuadro
Local lPerg			:= .T.
PRIVATE nLastKey 	:= 0
PRIVATE cPerg	 	:= "CTR040"
PRIVATE aLinha		:= {}
PRIVATE nomeProg  	:= "CTBR040"
PRIVATE titulo 		:= OemToAnsi("Balancete Verificacao") 	//"Balancete de Verificacao"
Private aSelFil		:= {} 

Default wnRel := ""

lExterno := !Empty(wnRel)

If ! lExterno
	PRIVATE Tamanho		:= "M"
	PRIVATE aReturn 	:= { OemToAnsi('Zebrado'), 1,OemToAnsi('Administracao'), 2, 2, 1, "",1 }  //"Zebrado"###"Administracao"
EndIf

cTitOrig	:= titulo

If ( !AMIIn(34) )		// Acesso somente pelo SIGACTB
	Return
EndIf

li	:= 60 //80 



Private aQuadro := { "","","","","","","",""}              

For nQuadro :=1 To Len(aQuadro)
	aQuadro[nQuadro] := Space(Len(CriaVar("CT1_CONTA")))
Next	

CtbCarTxt()

Pergunte("CTR040",.F.)


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variaveis utilizadas para parametros								  ³
//³ mv_par01				// Data Inicial                  	  		  ³
//³ mv_par02				// Data Final                        		  ³
//³ mv_par03				// Conta Inicial                         	  ³
//³ mv_par04				// Conta Final  							  ³
//³ mv_par05				// Imprime Contas: Sintet/Analit/Ambas   	  ³
//³ mv_par06				// Set Of Books				    		      ³
//³ mv_par07				// Saldos Zerados?			     		      ³
//³ mv_par08				// Moeda?          			     		      ³
//³ mv_par09				// Pagina Inicial  		     		    	  ³
//³ mv_par10				// Saldos? Reais / Orcados	/Gerenciais   	  ³
//³ mv_par11				// Quebra por Grupo Contabil?		    	  ³
//³ mv_par12				// Filtra Segmento?					    	  ³
//³ mv_par13				// Conteudo Inicial Segmento?		   		  ³
//³ mv_par14				// Conteudo Final Segmento?		    		  ³
//³ mv_par15				// Conteudo Contido em?				    	  ³
//³ mv_par16				// Imprime Coluna Mov ?				    	  ³
//³ mv_par17				// Salta linha sintetica ?			    	  ³
//³ mv_par18				// Imprime valor 0.00    ?			    	  ³
//³ mv_par19				// Imprimir Codigo? Normal / Reduzido  		  ³
//³ mv_par20				// Divide por ?                   			  ³
//³ mv_par21				// Imprimir Ate o segmento?			   		  ³
//³ mv_par22				// Posicao Ant. L/P? Sim / Nao         		  ³
//³ mv_par23				// Data Lucros/Perdas?                 		  ³
//³ mv_par24				// Imprime Quadros Contábeis?				  ³		
//³ mv_par25				// Rec./Desp. Anterior Zeradas?				  ³		
//³ mv_par26				// Grupo Receitas/Despesas?      			  ³		
//³ mv_par27				// Data de Zeramento Receita/Despesas?		  ³		
//³ mv_par28                // Num.linhas p/ o Balancete Modelo 1		  ³ 
//³ mv_par29				// Descricao na moeda?						  ³		
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If ! lExterno  	
	Pergunte("CTR040",.T.)  
    
	If mv_par30 == 1 .And. Len( aSelFil ) <= 0 .And. !IsBlind()
		aSelFil := AdmGetFil()
		If Len( aSelFil ) <= 0
			Return
		EndIf 
	EndIf

	wnrel	:= "CTBR040"            //Nome Default do relatorio em Disco
	wnrel := SetPrint(cString,wnrel,,@titulo,cDesc1,cDesc2,cDesc3,.F.,"",,Tamanho)  

Endif 

If wnRel == "CTBR110"
	If mv_par30 == 1 .And. Len( aSelFil ) <= 0 .And. !IsBlind()
		aSelFil := AdmGetFil()
		If Len( aSelFil ) <= 0
			Return
		EndIf 
	EndIf
Endif

If nLastKey == 27
	Set Filter To
	Return
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se usa Set Of Books + Plano Gerencial (Se usar Plano³
//³ Gerencial -> montagem especifica para impressao)		     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !U_ct040XValid(mv_par06)
	lRet := .F.
Else
   aSetOfBook := CTBSetOf(mv_par06)
Endif

If mv_par20 == 2			// Divide por cem
	nDivide := 100
ElseIf mv_par20 == 3		// Divide por mil
	nDivide := 1000
ElseIf mv_par20 == 4		// Divide por milhao
	nDivide := 1000000
EndIf	

If lRet
	aCtbMoeda  	:= CtbMoeda(mv_par08,nDivide)
	If Empty(aCtbMoeda[1])                       
      Help(" ",1,"NOMOEDA")
      lRet := .F.
   Endif
Endif

If lRet
	If (mv_par25 == 1) .and. ( Empty(mv_par26) .or. Empty(mv_par27) )
		cMensagem	:= 'Favor preencher os parametros Grupos Receitas/Despesas e '	//"Favor preencher os parametros Grupos Receitas/Despesas e "
		cMensagem	+= 'Data Sld Ant. Receitas/Desp. '	//"Data Sld Ant. Receitas/Desp. "
		MsgAlert(cMensagem,"Ignora Sl Ant.Rec/Des")	
		lRet    	:= .F.	
    EndIf
EndIf

If !lRet
	Set Filter To
	Return
EndIf


If !lExterno .And. ( mv_par16 == 1 .Or. ( mv_par16 == 2 .And.	aReturn[4] == 2 ))	//Se nao imprime coluna mov. e eh paisagem
	tamanho := "G"
EndIf	

If nLastKey == 27
	Set Filter To
	Return
Endif

RptStatus({|lEnd| U_CYTR040Imp(@lEnd,wnRel,cString,aSetOfBook,aCtbMoeda,nDivide,lExterno,cTitorig)})

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Program   ³CYTR040IMP ³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 24.07.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Imprime relatorio -> Balancete Verificacao Modelo 1        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CTR040Imp(lEnd,WnRel,cString,aSetOfBook,aCtbMoeda)          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ Nenhum                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ lEnd       - A‡ao do Codeblock                             ³±±
±±³          ³ WnRel      - T¡tulo do relat¢rio                           ³±±
±±³          ³ cString    - Mensagem                                      ³±±
±±³          ³ aSetOfBook - Matriz ref. Config. Relatorio                 ³±±
±±³          ³ aCtbMoeda  - Matriz ref. a moeda                           ³±±
±±³          ³ nDivide    - Valor para divisao de valores                 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function CYTR040Imp(lEnd,WnRel,cString,aSetOfBook,aCtbMoeda,nDivide,lExterno,cTitOrig)

Local aColunas		:= {}
LOCAL CbTxt			:= Space(10)
Local CbCont		:= 0
LOCAL limite		:= 132
Local cabec1   	:= ""
Local cabec2   	:= ""
Local cSeparador	:= ""
Local cPicture
Local cDescMoeda
Local cCodMasc
Local cMascara
Local cGrupo		:= ""
Local cArqTmp
Local dDataFim 	:= mv_par02
Local lFirstPage	:= .T.
Local lJaPulou		:= .F.
Local lPrintZero	:= Iif(mv_par18==1,.T.,.F.)
Local lPula			:= Iif(mv_par17==1,.T.,.F.) 
Local lNormal		:= Iif(mv_par19==1,.T.,.F.)
Local lVlrZerado	:= Iif(mv_par07==1,.T.,.F.)
Local l132			:= .T.
Local nDecimais
Local nTotDeb		:= 0
Local nTotCrd		:= 0
Local nTotMov		:= 0
Local nGrpDeb		:= 0
Local nGrpCrd		:= 0                     
Local cSegAte   	:= mv_par21
Local nDigitAte	:= 0
Local lImpAntLP	:= Iif(mv_par22 == 1,.T.,.F.)
Local dDataLP		:= mv_par23
Local lImpSint		:= Iif(mv_par05=1 .Or. mv_par05 ==3,.T.,.F.)
Local lRecDesp0		:= Iif(mv_par25==1,.T.,.F.)
Local cRecDesp		:= mv_par26
Local dDtZeraRD		:= mv_par27
Local n
Local oMeter
Local oText
Local oDlg
Local lImpPaisgm	:= .F.	
Local nMaxLin   	:= iif( mv_par28 > 58 , 58 , mv_par28 )
Local cMoedaDsc		:= mv_par29
Local nMasc			:= 0 
Local cMasc			:= ""
Local dDataOld 		:= dDataBase
Private lCncFIlial := .T.

cDescMoeda 	:= Alltrim(aCtbMoeda[2])
nDecimais 	:= DecimalCTB(aSetOfBook,mv_par08)

if !lExterno // Chamado THZFJJ - Se não for chado por outro relatorio trocar a data 
	dDataBase := dDataFim
endif
	
If Empty(aSetOfBook[2])
	cMascara := GetMv("MV_MASCARA")
Else
	cMascara 	:= RetMasCtb(aSetOfBook[2],@cSeparador)
EndIf
cPicture 		:= aSetOfBook[4]

If mv_par16 == 2 .And. !lExterno .And. 	aReturn[4] == 2	//Se nao imprime coluna mov. e eh paisagem
	lImpPaisgm	:= .T.
	limite		:= 220
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Carrega titulo do relatorio: Analitico / Sintetico			  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Alltrim(Titulo) == Alltrim(cTitorig) // Se o titulo do relatorio nao foi alterado pelo usuario
	IF mv_par05 == 1
		Titulo:=	OemToAnsi('BALANCETE DE VERIFICACAO SINTETICO DE ')	//"BALANCETE DE VERIFICACAO SINTETICO DE "
	ElseIf mv_par05 == 2
		Titulo:=	OemToAnsi('BALANCETE DE VERIFICACAO ANALITICO DE ')	//"BALANCETE DE VERIFICACAO ANALITICO DE "
	ElseIf mv_par05 == 3
		Titulo:=	OemToAnsi('BALANCETE DE VERIFICACAO DE ')	//"BALANCETE DE VERIFICACAO DE "
	EndIf
EndIf	
Titulo += 	DTOC(mv_par01) + /*OemToAnsi('STR0007')*/' Ate ' + Dtoc(mv_par02) + ;
			' Moeda '/*OemToAnsi('STR0008')*/ + cDescMoeda + CtbTitSaldo(mv_par10)
			
If nDivide > 1			
	Titulo += " (" + OemToAnsi('STR0021') + Alltrim(Str(nDivide)) + ")"
EndIf	

If mv_par16 == 1 .And. ! lExterno		// Se imprime saldo movimento do periodo

	//cabec1 := "|  CODIGO                |  D  E  S  C  R  I  C  A  O                                 |   SALDO ANTERIOR         |    DEBITO     |    CREDITO   | MOVIMENTO DO PERIODO |   SALDO ATUAL    |"
	cabec1 :=   "| EMP-FIL + CODIGO            |   D  E  S  C  R  I  C  A  O                    |   SALDO ANTERIOR         |    DEBITO        |     CREDITO       | MOVIMENTO DO PERIODO          |   SALDO ATUAL                     |"
	
	tamanho := "G"
	limite	:= 220        
	l132	:= .F.
Else	  
	If lImpPaisgm		//Se imprime em formato paisagem
		cabec1 := 'STR0022'  //"|  CODIGO                     |      D E S C R I C A O                          |        SALDO ANTERIOR             |           DEBITO             |            CREDITO                |         SALDO ATUAL               |"
	Else	

		cabec1 := "|  CODIGO               |   D  E  S  C  R  I  C  A  O    | SLD ANTERIOR |      DEBITO    |      CREDITO   |   SALDO ATUAL     |"
	EndIf
Endif

If ! lExterno
	SetDefault(aReturn,cString,,,Tamanho,If(Tamanho="G",2,1))
Endif

If l132
	If lImpPaisgm
		aColunas := { 000,001, 030, 032, 080,086-5, 116-5, 118-5, 147-5, 151-5, 183-5, , ,187-5,219-5}
	Else	
		aColunas := { 000,001, 024, 025, 057,058-5, 077-5, 078-5, 094-5, 095-5, 111-5, , , 112-5, 131-5 }
	EndIf
Else                   
	aColunas :=     { 000,001, 030, 032, 080,082-5, 112-5, 114-5, 131-5, 133-5, 151-5, 153-5, 183-5,185-5,219-5}
Endif

If ! lExterno
	m_pag := mv_par09
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta Arquivo Temporario para Impressao							  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lExterno  .or. IsBlind()
	U_xCTGerPlan(oMeter, oText, oDlg, @lEnd,@cArqTmp,;
				mv_par01,mv_par02,"CT7","",mv_par03,mv_par04,,,,,,,mv_par08,;
				mv_par10,aSetOfBook,mv_par12,mv_par13,mv_par14,mv_par15,;
				.F.,.F.,mv_par11,,lImpAntLP,dDataLP,nDivide,lVlrZerado,,,,,,,,,,,,,,lImpSint,aReturn[7],lRecDesp0,;
				cRecDesp,dDtZeraRD,,,,,,,cMoedaDsc,,aSelFil)
Else
  
	MsgMeter({|	oMeter, oText, oDlg, lEnd | ;
					U_xCTGerPlan(oMeter, oText, oDlg, @lEnd,@cArqTmp,;
					mv_par01,mv_par02,"CT7","",mv_par03,mv_par04,,,,,,,mv_par08,;
					mv_par10,aSetOfBook,mv_par12,mv_par13,mv_par14,mv_par15,;
					.F.,.F.,mv_par11,,lImpAntLP,dDataLP,nDivide,lVlrZerado,,,,,,,,,,,,,,lImpSint,aReturn[7],lRecDesp0,;
					cRecDesp,dDtZeraRD,,,,,,,cMoedaDsc,,aSelFil)},;
					OemToAnsi(OemToAnsi("Criando Arquivo Temporario...")),;  //"Criando Arquivo Temporario..."
					OemToAnsi("Balancete Verificacao"))  				//"Balancete Verificacao"
EndIf

// Verifica Se existe filtragem Ate o Segmento
If !Empty(cSegAte)
	
	//Efetua tratamento da mascara para consegui efetuar o controle do segmento 
	For nMasc := 1 to Len( cMascara )
			
		cMasc += SubStr( cMascara,nMasc,1 )
			
	Next nMasc


	nDigitAte := CtbRelDig(cSegAte,cMasc) 	
	
EndIf				

dbSelectArea("cArqTmp")
dbGoTop()

SetRegua(RecCount())

cGrupo := GRUPO
cArqTmp->(DbGoTop())



	
While !Eof()
	If lEnd
		@Prow()+1,0 PSAY OemToAnsi('STR0010')   //"***** CANCELADO PELO OPERADOR *****"
		Exit
	EndIF

	IncRegua()

	******************** "FILTRAGEM" PARA IMPRESSAO *************************

	If mv_par05 == 1					// So imprime Sinteticas
		If TIPOCONTA == "2"
			dbSkip()
			
			Loop
		EndIf
	ElseIf mv_par05 == 2				// So imprime Analiticas
		If TIPOCONTA == "1"
			dbSkip()
			Loop
		EndIf
	EndIf

	//Filtragem ate o Segmento ( antigo nivel do SIGACON)		
	If !Empty(cSegAte)
		If Len(Alltrim(CONTA)) > nDigitAte
			dbSkip()
			Loop
		Endif
	EndIf
	

	************************* ROTINA DE IMPRESSAO *************************

	If mv_par11 == 1 							// Grupo Diferente - Totaliza e Quebra
		If cGrupo != GRUPO
			
			
			@li,00 PSAY REPLICATE("-",limite)
			li+=2
			@li,00 PSAY REPLICATE("-",limite)
			li++
			@li,aColunas[COL_SEPARA1] PSAY "|"
			@li,39 PSAY OemToAnsi('STR0020') + cGrupo + ") : "  		//"T O T A I S  D O  G R U P O: "       
			@li,aColunas[COL_SEPARA4] PSAY "|"
			ValorCTB(nGrpDeb,li,aColunas[COL_VLR_DEBITO],16,nDecimais,.F.,cPicture,"1", , , , , ,lPrintZero)
			@li,aColunas[COL_SEPARA5] PSAY "|"
			ValorCTB(nGrpCrd,li,aColunas[COL_VLR_CREDITO],16,nDecimais,.F.,cPicture,"2", , , , , ,lPrintZero)
			@li,aColunas[COL_SEPARA6] PSAY "|"
			@li,aColunas[COL_SEPARA8] PSAY "|"
			li++      
			li		:= 60
			cGrupo	:= GRUPO
			nGrpDeb	:= 0
			nGrpCrd	:= 0		
		EndIf		

	ElseIf  mv_par11 == 2
		If NIVEL1				// Sintetica de 1o. grupo
			li := 60
		EndIf
	EndIf

	IF li > nMaxLin
		If !lFirstPage
			@Prow()+1,00 PSAY	Replicate("-",limite)
		EndIf
	
			
		CtCGCCabec(,,,Cabec1,Cabec2,dDataFim,Titulo,,"2",Tamanho,,dDataOld)
		lFirstPage := .F.
	EndIf

	@ li,aColunas[COL_SEPARA1] 		PSAY "|"
	If lNormal
		If TIPOCONTA == "2" 		// Analitica -> Desloca 2 posicoes
			If l132
				xEntidadeCTB(cArqTmp->FILIAL,CONTA,li,aColunas[COL_CONTA],21,.F.,cMascara,cSeparador)			
			Else
				xEntidadeCTB(cArqTmp->FILIAL,CONTA,li,aColunas[COL_CONTA],27,.F.,cMascara,cSeparador)
			EndIf
		Else	                                              
			If l132
				
				xEntidadeCTB(cArqTmp->FILIAL,CONTA,li,aColunas[COL_CONTA],23,.F.,cMascara,cSeparador)
			Else           
				xEntidadeCTB(cArqTmp->FILIAL,CONTA,li,aColunas[COL_CONTA],29,.F.,cMascara,cSeparador)
			EndIf			
		EndIf	
	Else
		If TIPOCONTA == "2"		// Analitica -> Desloca 2 posicoes
			@li,aColunas[COL_CONTA] PSAY AllTrim(cArqTmp->FILIAL) + " " + Alltrim(CTARES)
		Else
			@li,aColunas[COL_CONTA] PSAY AllTrim(cArqTmp->FILIAL) + " " + Alltrim(CONTA)
		EndIf						
	EndIf	

	@ li,aColunas[COL_SEPARA2] 		PSAY "|"

	If !l132
		@ li,aColunas[COL_DESCRICAO] 	PSAY Substr(DESCCTA,1,43)
	Else		
		@ li,aColunas[COL_DESCRICAO] 	PSAY Substr(DESCCTA,1,25)
	Endif	

	@ li,aColunas[COL_SEPARA3]		PSAY "|"
	ValorCTB(SALDOANT,li,aColunas[COL_SALDO_ANT],17,nDecimais,.T.,cPicture,NORMAL, , , , , ,lPrintZero)

	@ li,aColunas[COL_SEPARA4]		PSAY "|"
	ValorCTB(SALDODEB,li,aColunas[COL_VLR_DEBITO],16,nDecimais,.F.,cPicture,NORMAL, , , , , ,lPrintZero)

	@ li,aColunas[COL_SEPARA5]		PSAY "|"
	ValorCTB(SALDOCRD,li,aColunas[COL_VLR_CREDITO],16,nDecimais,.F.,cPicture,NORMAL, , , , , ,lPrintZero)
	
	@ li,aColunas[COL_SEPARA6]		PSAY "|"

	If !l132
		ValorCTB(MOVIMENTO,li,aColunas[COL_MOVIMENTO],17,nDecimais,.T.,cPicture,NORMAL, , , , , ,lPrintZero)
		@ li,aColunas[COL_SEPARA7] PSAY "|"	
	Endif
	ValorCTB(SALDOATU,li,aColunas[COL_SALDO_ATU],17,nDecimais,.T.,cPicture,NORMAL, , , , , ,lPrintZero)

	@ li,aColunas[COL_SEPARA8] PSAY "|"
	
	//If MsgNoYes( "abortar ?"  )
	//	exit
	//endIf
	
	
	lJaPulou := .F.
	
	If lPula .And. TIPOCONTA == "1"				// Pula linha entre sinteticas
	
		If mv_par16 == 2
			li++
			@ li,aColunas[COL_SEPARA1] PSAY "|"
			@ li,aColunas[COL_SEPARA2] PSAY "|"
			@ li,aColunas[COL_SEPARA3] PSAY "|"	
			@ li,aColunas[COL_SEPARA4]-1 PSAY "|"
			@ li,aColunas[COL_SEPARA5]-1 PSAY "|"
			@ li,aColunas[COL_SEPARA6]-1 PSAY "|"
			If !l132  
				@ li,aColunas[COL_SEPARA7]-1 PSAY "|"
				@ li,aColunas[COL_SEPARA8]-1 PSAY "|"
			Else
				@ li,aColunas[COL_SEPARA8]-1 PSAY "|"
			EndIf	
		Else
			li++
			@ li,aColunas[COL_SEPARA1] PSAY "|"
			@ li,aColunas[COL_SEPARA2] PSAY "|"
			@ li,aColunas[COL_SEPARA3] PSAY "|"	
			@ li,aColunas[COL_SEPARA4]-1 PSAY "|"
			@ li,aColunas[COL_SEPARA5]-1 PSAY "|"
			@ li,aColunas[COL_SEPARA6]-1 PSAY "|"
			If !l132  
				@ li,aColunas[COL_SEPARA7]-1 PSAY "|"
				@ li,aColunas[COL_SEPARA8]-1 PSAY "|"
			Else
				@ li,aColunas[COL_SEPARA8]-1 PSAY "|"
			endif
		EndIf
		
		li++
		lJaPulou := .T.
	Else
		li++
	EndIf			

	************************* FIM   DA  IMPRESSAO *************************

	If mv_par05 == 1					// So imprime Sinteticas - Soma Sinteticas
		If TIPOCONTA == "1"
			If NIVEL1
				nTotDeb += SALDODEB
				nTotCrd += SALDOCRD
				nGrpDeb += SALDODEB
				nGrpCrd += SALDOCRD
			EndIf
		EndIf
	Else									// Soma Analiticas
		If Empty(cSegAte)				//Se nao tiver filtragem ate o nivel
			If TIPOCONTA == "2"
				nTotDeb += SALDODEB
				nTotCrd += SALDOCRD
				nGrpDeb += SALDODEB
				nGrpCrd += SALDOCRD
			EndIf
		Else							//Se tiver filtragem, somo somente as sinteticas
			If TIPOCONTA == "1"
				If NIVEL1
					nTotDeb += SALDODEB
					nTotCrd += SALDOCRD
					nGrpDeb += SALDODEB
					nGrpCrd += SALDOCRD
				EndIf 
			EndIf	
    	Endif			
	EndIf
 
	dbSkip()       
	If lPula .And. TIPOCONTA == "1" 			// Pula linha entre sinteticas
		If !lJaPulou
			@ li,aColunas[COL_SEPARA1] PSAY "|"
			@ li,aColunas[COL_SEPARA2] PSAY "|"
			@ li,aColunas[COL_SEPARA3] PSAY "|"	
			@ li,aColunas[COL_SEPARA4]-1 PSAY "|"
			@ li,aColunas[COL_SEPARA5]-1 PSAY "|"
			@ li,aColunas[COL_SEPARA6]-1 PSAY "|"
			If !l132  
				@ li,aColunas[COL_SEPARA7]-1 PSAY "|"
				@ li,aColunas[COL_SEPARA8]-1 PSAY "|"
			Else
				@ li,aColunas[COL_SEPARA8]-1 PSAY "|"
			EndIf	
			li++
		EndIf	
	EndIf		
EndDO


	
//IF li != 80 .And. !lEnd
IF li <= 58 .OR. li >= 58 .And. !lEnd
	IF li > nMaxLin
		@Prow()+1,00 PSAY	Replicate("-",limite)
		CtCGCCabec(,,,Cabec1,Cabec2,dDataFim,Titulo,,"2",Tamanho,,dDataOld)
		li++
	End
	If mv_par11 == 1							// Grupo Diferente - Totaliza e Quebra
		If cGrupo != GRUPO .Or. Eof()
			@li,00 PSAY REPLICATE("-",limite)
			li++
			@li,aColunas[COL_SEPARA1] PSAY "|"
			@li,39 PSAY OemToAnsi("T O T A I S  D O  G R U P O: ") + cGrupo + ") : "  		//"T O T A I S  D O  G R U P O: "
			@li,aColunas[COL_SEPARA4] PSAY "|"
			ValorCTB(nGrpDeb,li,aColunas[COL_VLR_DEBITO],16,nDecimais,.F.,cPicture,"1", , , , , ,lPrintZero)
			@li,aColunas[COL_SEPARA5] PSAY "|"
			ValorCTB(nGrpCrd,li,aColunas[COL_VLR_CREDITO],16,nDecimais,.F.,cPicture,"2", , , , , ,lPrintZero)
			@li,aColunas[COL_SEPARA6] PSAY "|"
			If !l132
				nTotMov := nTotMov + (nGrpCrd - nGrpDeb)
				If Round(NoRound(nTotMov,3),2) < 0
					ValorCTB(nTotMov,li,aColunas[COL_MOVIMENTO],17,nDecimais,.T.,cPicture,"1", , , , , ,lPrintZero)
				ElseIf Round(NoRound(nTotMov,3),2) > 0
					ValorCTB(nTotMov,li,aColunas[COL_MOVIMENTO],17,nDecimais,.T.,cPicture,"2", , , , , ,lPrintZero)
                EndIf
				@ li,aColunas[COL_SEPARA7] PSAY "|"	
			Endif
			@li,aColunas[COL_SEPARA8] PSAY "|"
			li++
			@li,00 PSAY REPLICATE("-",limite)
			li+=2
		EndIf		
	EndIf

	@li,00 PSAY REPLICATE("-",limite)
	li++
	@li,aColunas[COL_SEPARA1] PSAY "|"
	@li,39 PSAY OemToAnsi(" T O T A I S ")  		//"T O T A I S  D O  M E S : "
	@li,aColunas[COL_SEPARA4] PSAY "|"
	ValorCTB(nTotDeb,li,aColunas[COL_VLR_DEBITO],16,nDecimais,.F.,cPicture,"1", , , , , ,lPrintZero)
	@li,aColunas[COL_SEPARA5] PSAY "|"
	ValorCTB(nTotCrd,li,aColunas[COL_VLR_CREDITO],16,nDecimais,.F.,cPicture,"2", , , , , ,lPrintZero)
	@li,aColunas[COL_SEPARA6] PSAY "|"
 	If !l132	
		nTotMov := nTotMov + (nTotCrd - nTotDeb)
		If Round(NoRound(nTotMov,3),2) < 0
			ValorCTB(nTotMov,li,aColunas[COL_MOVIMENTO],17,nDecimais,.T.,cPicture,"1", , , , , ,lPrintZero)
		ElseIf Round(NoRound(nTotMov,3),2) > 0
			ValorCTB(nTotMov,li,aColunas[COL_MOVIMENTO],17,nDecimais,.T.,cPicture,"2", , , , , ,lPrintZero)
		EndIf
		@li,aColunas[COL_SEPARA7] PSAY "|"	
	EndIf		                                
	@li,aColunas[COL_SEPARA8] PSAY "|"
	li++
	@li,00 PSAY REPLICATE("-",limite)
	li++
	@li,0 PSAY " "

	IF lExterno 
		If (li + 3) < 60 
			@57,00 PSAY __PrtfatLine()
  		  	@58,01 Psay 'Totvs '   //  "Microsiga Software S/A"
 		   	If Tamanho == "M"
   		 		@58,100 Psay "Hora Termino: " + " " + Time()      //"Hora Termino: "
   	 		ElseIf Tamanho == "G"
	   		 	@58,190 Psay "Hora Termino: "+ " "+ Time()  //"Hora Termino: "
    		Else
	    		@58,050 Psay "Hora Termino: "+ " "+ Time()	   //"Hora Termino: "
			EndIf               
			@59,00 PSAY __PrtfatLine()
		EndIf	
	Endif
	Set Filter To
EndIF

If mv_par24 ==1
	ImpQuadro(Tamanho,X3USO("CT2_DCD"),dDataFim,mv_par08,aQuadro,cDescMoeda,nomeprog,(If (lImpAntLP,dDataLP,cTod(""))),cPicture,nDecimais,lPrintZero,mv_par10)
EndIf	
	
If aReturn[5] = 1 .And. ! lExterno
	Set Printer To
	Commit
	Ourspool(wnrel)
EndIf

dbSelectArea("cArqTmp")
Set Filter To
dbCloseArea() 
If Select("cArqTmp") == 0
	FErase(cArqTmp+GetDBExtension())
	FErase(cArqTmp+OrdBagExt())
EndIF	
dbselectArea("CT2")

If ! lExterno
	MS_FLUSH()
Endif

dDataBase := dDataOld 

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³CT040XValid³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 24.07.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida Perguntas                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Ct040XValid(cSetOfBook)                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T./.F.                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo da Config. Relatorio                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
User Function Ct040XValid(cSetOfBook)

Local aSaveArea:= GetArea()
Local lRet		:= .T.	

If !Empty(cSetOfBook)
	dbSelectArea("CTN")
	dbSetOrder(1)
	If !dbSeek(xfilial()+cSetOfBook)
		aSetOfBook := ("","",0,"","")
		Help(" ",1,"NOSETOF")
		lRet := .F.
	EndIf
EndIf
	
RestArea(aSaveArea)

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ CTR040MAXL ºAutor ³ Eduardo Nunes Cirqueira º Data ³  31/01/07 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Baseado no parametro MV_PAR28 ("Num.linhas p/ o Balancete      º±±
±±º          ³ Modelo 1"), cujo conteudo esta na variavel "nMaxLin", controla º±±
±±º          ³ a quebra de pagina no TReport                                  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                             º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function CTR040MaxL(nMaxLin,nLinReport)

nLinReport++

If nLinReport > nMaxLin
	oReport:EndPage()
	nLinReport := 10
EndIf

Return Nil
                                                                          

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ nCtCGCCabTR  º Autor ³ Fabio Jadao Caires      º Data ³ 31/01/07º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Chama a funcao padrao CtCGCCabTR reiniciando o contador de      º±±
±±º          ³ linhas para o controle do relatorio.                            º±±
±±º          ³                                                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                              º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
STATIC FUNCTION nCtCGCCabTR(dDataFim,titulo,oReport,dDataRef)
Local dDataold		:= Ctod("//")
Local cTexto		:= ""

Default dDataRef	:= dDataBase

nLinReport := 10                                  
oReport:SetPageNumber(n_pagini)
oReport:OnPageBreak({|| n_pagini += 1})                                                    
nLinReport := 10

dDataOld := dDataBase
dDataBase := dDataRef
cTexto := CtCGCCabTR(,,,,,dDataFim,titulo,,,,,oReport,,,,,,,,,,MV_PAR01)
dDataBase := dDataOld
Return(cTexto)



//log auxiliar para debug de performance em fase de testes
static Function Log99(cStrPulp,cTxt)
Local cFileOper
Local nHandleCr

/*If AllTrim(cStrPulp) == "DEBUG"
	return
EndIf*/


return
cFIleOpen :=  "C:\para RH\JAC e CAMILA\ENTREGAS\Relatorios Antonio\Balancete\Nova pasta\99__" + cStrPulp + ".txt"//cLogCompleto + "\log_bol_po.txt"
nHandleCr := fopen( cFileOpen  , FO_READWRITE + FO_SHARED )
         
if nHandleCr  == -1
	nHandleCr := FCreate(cFileOpen)//esta função cria o arquivo automaticamente sempre no protheus_data\system
else                 
	fseek(nHandleCr, 0, FS_END)
EndIf		

		   
FWrite(nHandleCr, cTxt + Chr(13) + CHr(10))
		
FClose(nHandleCr) 
return      


//log auxiliar para debug de performance em fase de testes
static Function LogProcesso(cTxt)
Local cFIleOpen :=  "C:\para RH\JAC e CAMILA\Relatorios Antonio\Balancete\meu040.txt"//cLogCompleto + "\log_bol_po.txt"
Local nHandleCr := fopen( cFileOpen  , FO_READWRITE + FO_SHARED )
         
if nHandleCr  == -1
	nHandleCr := FCreate(cFileOpen)//esta função cria o arquivo automaticamente sempre no protheus_data\system
else                 
	fseek(nHandleCr, 0, FS_END)
EndIf		

		   
FWrite(nHandleCr, cTxt + Chr(13) + CHr(10))
		
FClose(nHandleCr) 
return      

static Function Log33Processo(cTxt)
Local cFIleOpen :=  "C:\para RH\JAC e CAMILA\Relatorios Antonio\Balancete\tmp_query.txt"//cLogCompleto + "\log_bol_po.txt"
Local nHandleCr := fopen( cFileOpen  , FO_READWRITE + FO_SHARED )
         
if nHandleCr  == -1
	nHandleCr := FCreate(cFileOpen)//esta função cria o arquivo automaticamente sempre no protheus_data\system
else                 
	fseek(nHandleCr, 0, FS_END)
EndIf		

		   
FWrite(nHandleCr, cTxt + Chr(13) + CHr(10))
		
FClose(nHandleCr) 
return      

static Function Log34Processo(cTxt)
Local cFIleOpen :=  "C:\para RH\JAC e CAMILA\Relatorios Antonio\Balancete\no_trab_mesmo.txt"//cLogCompleto + "\log_bol_po.txt"
Local nHandleCr := fopen( cFileOpen  , FO_READWRITE + FO_SHARED )
         
if nHandleCr  == -1
	nHandleCr := FCreate(cFileOpen)//esta função cria o arquivo automaticamente sempre no protheus_data\system
else                 
	fseek(nHandleCr, 0, FS_END)
EndIf		

		   
FWrite(nHandleCr, cTxt + Chr(13) + CHr(10))
		
FClose(nHandleCr) 
return      

//log auxiliar para debug de performance em fase de testes
static Function Log2Processo(cTxt)
Local cFIleOpen :=  "C:\para RH\JAC e CAMILA\Ambiente de desenvolvimento Renata 02-12-15\evidencias de testes\NEWmeu040.txt"//cLogCompleto + "\log_bol_po.txt"
Local nHandleCr := fopen( cFileOpen  , FO_READWRITE + FO_SHARED )
         
if nHandleCr  == -1
	nHandleCr := FCreate(cFileOpen)//esta função cria o arquivo automaticamente sempre no protheus_data\system
else                 
	fseek(nHandleCr, 0, FS_END)
EndIf		

		   
FWrite(nHandleCr, cTxt + Chr(13) + CHr(10))
		
FClose(nHandleCr) 
return      



User Function xCTGerPlan(	oMeter,oText,oDlg,lEnd,cArqtmp,dDataIni,dDataFim,cAlias,cIdent,cContaIni,cContaFim,;
					cCCIni,cCCFim,cItemIni,cItemFim,cClvlIni,cClVlFim,cMoeda,cSaldos,aSetOfBook,cSegmento,;
					cSegIni,cSegFim,cFiltSegm,lNImpMov,lImpConta,nGrupo,cHeader,lImpAntLP,dDataLP,;
					nDivide,lVlrZerado,cFiltroEnt,cCodFilEnt,cSegmentoG,cSegIniG,cSegFimG,cFiltSegmG,;
					lUsGaap,cMoedConv,cConsCrit,dDataConv,nTaxaConv,aGeren,lImpMov,lImpSint,cFilUSU,lRecDesp0,;
					cRecDesp,dDtZeraRD,lImp3Ent,lImp4Ent,lImpEntGer,lFiltraCC,lFiltraIt,lFiltraCV,cMoedaDsc,;
					lMovPeriodo,aSelFil,dDtCorte,lPlGerSint,lConsSaldo,lCompEnt,cArqAux,lUsaNmVis,cNomeVis,lCttSint,;
					lTodasFil,cQuadroCTB,aEntidades,cCodEntidade,lDemDRE , dFinalA)

Local aTamConta		:= TAMSX3("CT1_CONTA")
Local aTamCtaRes	:= TAMSX3("CT1_RES")
Local aTamCC        := TAMSX3("CTT_CUSTO")
Local aTamCCRes 	:= TAMSX3("CTT_RES")
Local aTamItem  	:= TAMSX3("CTD_ITEM")
Local aTamItRes 	:= TAMSX3("CTD_RES")
Local aTamClVl  	:= TAMSX3("CTH_CLVL")
Local aTamCvRes 	:= TAMSX3("CTH_RES")
Local aTamVal		:= TAMSX3("CT2_VALOR")

Local aCtbMoeda		:= {}
Local aSaveArea 	:= GetArea()
Local aCampos
Local cChave
Local nTamCta 		:= Len(CriaVar("CT1->CT1_DESC"+cMoeda))
Local nTamItem		:= Len(CriaVar("CTD->CTD_DESC"+cMoeda))
Local nTamCC  		:= Len(CriaVar("CTT->CTT_DESC"+cMoeda))
Local nTamClVl		:= Len(CriaVar("CTH->CTH_DESC"+cMoeda))
Local nTamGrupo		:= Len(CriaVar("CT1->CT1_GRUPO"))
Local nDecimais		:= 0
Local cCodigo		:= ""
Local cCodGer		:= ""
Local cEntidIni		:= ""
Local cEntidFim		:= ""
Local cEntidIni1	:= ""
Local cEntidFim1	:= ""
Local cEntidIni2	:= ""
Local cEntidFim2	:= ""
Local cArqTmp1		:= ""
Local cMascaraG 	:= ""
Local lCusto		:= CtbMovSaldo("CTT")//Define se utiliza C.Custo
Local lItem 		:= CtbMovSaldo("CTD")//Define se utiliza Item
Local lClVl			:= CtbMovSaldo("CTH")//Define se utiliza Cl.Valor
Local lAtSldBase	:= Iif(GetMV("MV_ATUSAL")== "S",.T.,.F.)
Local lAtSldCmp		:= Iif(GetMV("MV_SLDCOMP")== "S",.T.,.F.)
Local nInicio		:= Val(cMoeda)
Local nFinal		:= Val(cMoeda)
Local nCampoLP		:= 0
Local cFilDe		:= xFilial(cAlias)
Local cFilAte		:= xFilial(cAlias), nOrdem := 1
Local cCodMasc		:= ""
Local cMensagem		:= OemToAnsi(STR0002)// O plano gerencial ainda nao esta disponivel nesse relatorio.
Local nPos			:= 0
Local nCont			:= 0
Local lTemQuery		:= .F.
Local nX
Local lCriaInd		:= .F.
Local nTamFilial 	:= IIf( lFWCodFil, FWGETTAMFILIAL, 2 )
Local lCT1EXDTFIM	:= CtbExDtFim("CT1")
Local lCTTEXDTFIM	:= CtbExDtFim("CTT")
Local lCTDEXDTFIM	:= CtbExDtFim("CTD")
Local lCTHEXDTFIM	:= CtbExDtFim("CTH")

Local nSlAntGap		:= 0	// Saldo Anterior
Local nSlAntGapD	:= 0	// Saldo anterior debito
Local nSlAntGapC	:= 0	// Saldo anterior credito
Local nSlAtuGap		:= 0	// Saldo Atual
Local nSlAtuGapD	:= 0	// Saldo Atual debito
Local nSlAtuGapC	:= 0	// Saldo Atual credito
Local nSlDebGap		:= 0	// Saldo Debito
Local nSlCrdGap		:= 0	// Saldo Credito

Local aEntidIni		:= {}
Local aEntidFim		:= {}

Local aStruTmp		:= {}
Local lTemQry		:= .F.
Local nTrb			:= 0

Local nDigitos		:= 0
Local nMeter		:= 0
Local nPosG			:= 0
Local nDigitosG		:= 0
Local aAreaAnt		:= Nil

Local _lCtbIsCube	:= FindFunction( "CtbIsCube" ) .And. CtbIsCube()
Local aTmpFil		:= {}

Local cMvPar01Ant	:= mv_par01

Local cTableNam1 	:= ""
Local aChave		:= {}
Local nTamCt		:= aTamConta[1]

Local cEntid_de		:= ""
Local cEntid_ate	:= ""
Local lEntSint		:= .F.

Local lCT1DTEXSF 	:= .F.
Local lCTTDTEXSF 	:= .F.
Local lCTDDTEXSF 	:= .F.
Local lCTHDTEXSF 	:= .F.
Local lSLDANTCTDB 	:= .F. 
Local lSLDANTCTCR 	:= .F.
Local lSLLPATCTDB 	:= .F.
Local lSLLPATCTCR 	:= .F.

//Variaveis para atualizar a regua desde as rotinas de geracao do arquivo temporario
Private oMeter1 		:= oMeter
Private oText1 		:= oText
Private cPlanoRef	:= aSetOfBook[11]
Private cVersao		:= aSetOfBook[12]

DEFAULT lConsSaldo   := .F.
DEFAULT lPlGerSint   := .F.
DEFAULT cSegmentoG 	:= ""
DEFAULT lUsGaap		:=.F.
DEFAULT cMoedConv	:= ""
DEFAULT	cConsCrit	:= ""
DEFAULT dDataConv	:= CTOD("  /  /  ")
DEFAULT nTaxaConv	:= 0
DEFAULT lImpSint	:= .T.
DEFAULT lImpMov		:= .T.
DEFAULT cSegmento	:= ""
DEFAULT cFilUsu		:= ".T."
DEFAULT lRecDesp0	:= .F.
DEFAULT cRecDesp 	:= ""
DEFAULT dDtZeraRD	:= CTOD("  /  /  ")
DEFAULT lImp3Ent	:= .F.
DEFAULT lImp4Ent	:= .F.
DEFAULT lImpEntGer	:= .F.
DEFAULT lImpConta	:= .T.
DEFAULT lFiltraCC	:= .F.
DEFAULT lFiltraIt	:= .F.
DEFAULT lFiltraCV	:= .F.
DEFAULT cMoedaDsc	:= '01'
DEFAULT lMovPeriodo := .F.
DEFAULT aSelFil 	:= {}
DEFAULT dDtCorte 	:= CTOD("  /  /  ")
DEFAULT lCompEnt	:= .F.
DEFAULT cArqAux		:= "cArqTmp"
DEFAULT cArqTmp 	:= ""
DEFAULT lUsaNmVis	:= .F.
DEFAULT lCttSint	:= .F.
DEFAULT cQuadroCTB:= ""
DEFAULT lTodasFil   := .F.
DEFAULT aEntidades  := {}
DEFAULT cCodEntidade:= ""
DEFAULT lDemDRE:=.F.
DEFAULT dFinalA 	:= CTOD("  /  /  ")


If FunName() == "CTBR561" .Or. FunName() == "CTBR502"
	nTamCta := 100
Endif

__aTmpTCFil	:=	{}

If lRecDesp0 .And. ( Empty(cRecDesp) .Or. Empty(dDtZeraRD) )
	lRecDesp0 := .F.
EndIf

cIdent		:=	Iif(cIdent == Nil,'',cIdent)
nGrupo		:=	Iif(nGrupo == Nil,2,nGrupo)
cHeader		:= Iif(cHeader == Nil,'',cHeader)
cFiltroEnt	:= Iif(cFiltroEnt == Nil,"",cFiltroEnt)
cCodFilEnt	:= Iif(cCodFilEnt == Nil,"",cCodFilEnt)
Private nMin			:= 0
Private nMax			:= 0

// Retorna Decimais
aCtbMoeda := CTbMoeda(cMoeda)
nDecimais := aCtbMoeda[5]
dMinData := CTOD("")

//Se utiliza o plano referencial, desconsidera os filtros das entidades dos relatórios.
If !Empty(cPlanoRef) .And. !Empty(cVersao)
	//Se o relatório não possuir conta, o plano referencial e a versão serão desconsiderados.
	//Será considerado cód. config. livros em branco.
	If cAlias $ "CTU/CTV/CTW/CTX/CTY/CVY" .Or. FunName() == "CTBR245"
		Help("  ",1,"CTBNOPLREF",,STR0048,1,0) //"Plano referencial não disponível nesse relatório. O relatório será processado desconsiderando a configuração de livros."
		cPlanoRef		:= ""
		cVersao			:= ""
		//aSetOfBook[1]	:= ""
		aSetOfBook		:= CTBSetOf("")
	Else
		cContaIni	:= Space(aTamConta[1])
		cContaFim	:= Replicate("Z",aTamConta[1])
		lRecDesp0	:= .F.
	EndIf
Endif


If ExistBlock("ESPGERPLAN")
	ExecBlock("ESPGERPLAN",.F.,.F.,{oMeter,oText,oDlg,lEnd,cArqtmp,dDataIni,dDataFim,cAlias,cIdent,cContaIni,cContaFim,;
		cCCIni,cCCFim,cItemIni,cItemFim,cClvlIni,cClVlFim,cMoeda,cSaldos,aSetOfBook,cSegmento,cSegIni,;
		cSegFim,cFiltSegm,lNImpMov,lImpConta,nGrupo,cHeader,lImpAntLP,dDataLP,nDivide,lVlrZerado,;
		cFiltroEnt,cCodFilEnt,cSegmentoG,cSegIniG,cSegFimG,cFiltSegmG,lUsGaap,cMoedConv,;
		cConsCrit,dDataConv,nTaxaConv,aGeren,lImpMov,lImpSint,cFilUSU,lRecDesp0,;
		cRecDesp,dDtZeraRD,lImp3Ent,lImp4Ent,lImpEntGer,lFiltraCC,lFiltraIt,lFiltraCV,aSelFil,dDtCorte,cQuadroCTB })


		Return(cArqTmp)
EndIf

If cAlias == 'CTY'	//Se for Balancete de 2 Entidades filtrando pela 3a Entidade.
	aCampos := {{ "ENTID1"		, "C", aTamConta[1], 0 },;  			// Codigo da Conta
	{ "ENTRES1"	, "C", aTamCtaRes[1],0 },;  			// Codigo Reduzido da Conta
	{ "DESCENT1"	, "C", nTamCta		, 0 },;  			// Descricao da Conta
	{ "TIPOENT1"  	, "C", 01			, 0 },;				// Centro de Custo Analitico / Sintetico
	{ "ENTSUP1"	, "C", aTamCC[1]	, 0 },;				// Codigo do Centro de Custo Superior
	{ "ENTID2"		, "C", aTamCC[1]	, 0 },; 	 		// Codigo do Centro de Custo
	{ "ENTRES2"	, "C", aTamCCRes[1], 0 },;  			// Codigo Reduzido do Centro de Custo
	{ "DESCENT2"	, "C", nTamCC		, 0 },;  			// Descricao do Centro de Custo
	{ "TIPOENT2"	, "C", 01			, 0 },;				// Item Analitica / Sintetica
	{ "ENTSUP2"	, "C", aTamItem[1]	, 0 },; 			// Codigo do Item Superior
	{ "NORMAL"		, "C", 01			, 0 },;				// Situacao
	{ "SALDOANT"	, "N", aTamVal[1]+2, nDecimais},; 		// Saldo Anterior
	{ "SALDOANTDB"	, "N", aTamVal[1]+2	, nDecimais},; 		// Saldo Anterior Debito
	{ "SALDOANTCR"	, "N", aTamVal[1]+2	, nDecimais},; 		// Saldo Anterior Credito
	{ "SALDODEB"	, "N", aTamVal[1]+2	, nDecimais },;  	// Debito
	{ "SALDOCRD"	, "N", aTamVal[1]+2	, nDecimais },;  	// Credito
	{ "SALDOATU"	, "N", aTamVal[1]+2, nDecimais },;  	// Saldo Atual
	{ "SALDOATUDB"	, "N", aTamVal[1]+2	, nDecimais },;  	// Saldo Atual Debito
	{ "SALDOATUCR"	, "N", aTamVal[1]+2	, nDecimais },;  	// Saldo Atual Credito
	{ "MOVIMENTO"	, "N", aTamVal[1]+2	, nDecimais },;  	// Movimento do Periodo
	{ "ORDEM"		, "C", 10			, 0 },;				// Ordem
	{ "GRUPO"		, "C", nTamGrupo	, 0 },;				// Grupo Contabil
	{ "IDENTIFI"	, "C", 01			, 0 },;
		{ "TOTVIS"		, "C", 01			, 0 },;
		{ "SLDENT"		, "C", 01			, 0 },;
		{ "FATSLD"		, "C", 01			, 0 },;
		{ "VISENT"		, "C", 01			, 0 },;
		{ "NIVEL1"		, "L", 01			, 0 }}				// Logico para identificar se eh de nivel 1 -> usado como totalizador do relatorio

ElseIf cAlias == 'CVY'	//Se for Balancete por cubo contabil

	aCampos := { { "ECX"		, "C", aTamConta[1], 0 },;  			// Codigo da Conta
	{ "ECXSUP"		, "C", aTamConta[1], 0 },;				// Conta Superior
	{ "ECXNORMAL"	, "C", 01			, 0 },;				// Situacao
	{ "ECXRES"		, "C", aTamCtaRes[1], 0 },;  			// Codigo Reduzido da Conta
	{ "ECXDESC"	, "C", nTamCta		, 0 },;  			// Descricao da Conta
	{ "ECY"		, "C", aTamCC[1]	, 0 },; 	 		// Codigo do Centro de Custo
	{ "ECYSUP"		, "C", aTamConta[1], 0 },;				// Conta Superior
	{ "ECYNORMAL"	, "C", 01			, 0 },;				// Situacao
	{ "ECYRES"		, "C", aTamCCRes[1], 0 },;  			// Codigo Reduzido do Centro de Custo
	{ "ECYDESC" 	, "C", nTamCC		, 0 },;  			// Descricao do Centro de Custo
	{ "SALDOANT"	, "N", aTamVal[1]+2	, nDecimais},; 		// Saldo Anterior
	{ "SALDOANTDB"	, "N", aTamVal[1]+2	, nDecimais},; 		// Saldo Anterior Debito
	{ "SALDOANTCR"	, "N", aTamVal[1]+2	, nDecimais},; 		// Saldo Anterior Credito
	{ "SALDODEB"	, "N", aTamVal[1]+2	, nDecimais },;  	// Debito
	{ "SALDOCRD"	, "N", aTamVal[1]+2	, nDecimais },;  	// Credito
	{ "SALDOATU"	, "N", aTamVal[1]+1	, nDecimais },;  	// Saldo Atual
	{ "SALDOATUDB"	, "N", aTamVal[1]+2	, nDecimais },;  	// Saldo Atual Debito
	{ "SALDOATUCR"	, "N", aTamVal[1]+2	, nDecimais },;  	// Saldo Atual Credito
	{ "MOVIMENTO"	, "N", aTamVal[1]+2	, nDecimais },;  	// Movimento do Periodo
	{ "TIPOECX"	, "C", 01			, 0 },;				// Conta Analitica / Sintetica
	{ "TIPOECY"  	, "C", 01			, 0 },;				// Centro de Custo Analitico / Sintetico
	{ "ORDEM"		, "C", 10			, 0 },;				// Ordem
	{ "GRUPO"		, "C", nTamGrupo	, 0 },;				// Grupo Contabil
	{ "IDENTIFI"	, "C", 01			, 0 },;
		{ "TOTVIS"		, "C", 01			, 0 },;
		{ "SLDENT"		, "C", 01			, 0 },;
		{ "FATSLD"		, "C", 01			, 0 },;
		{ "VISENT"		, "C", 01			, 0 },;
		{ "ESTOUR" 	, "C", 01			, 0 },;			 	//Define se a conta esta estourada ou nao
	{ "NIVEL1"		, "L", 01			, 0 },;
		{ "NATCTA"     , "C", 02           , 0 }}             //NATCTA -campo de natureza da conta para relatorio CTBR047

	// totalizador do relatorio
Else
	If !Empty(cPlanoRef) .And. !Empty(cVersao)
		nTamCt	:= 70
	Else
		nTamCt	:= aTamConta[1]
	Endif
	aCampos := { { "CONTA"		, "C", nTamCt, 0 },;  			// Codigo da Conta
	{ "SUPERIOR"	, "C", nTamCt, 0 },;				// Conta Superior
	{ "NORMAL"		, "C", 01			, 0 },;				// Situacao
	{ "CTARES"		, "C", aTamCtaRes[1], 0 },;  			// Codigo Reduzido da Conta
	{ "DESCCTA"	, "C", nTamCta		, 0 },;  			// Descricao da Conta
	{ "CUSTO"		, "C", aTamCC[1]	, 0 },; 	 		// Codigo do Centro de Custo
	{ "CCRES"		, "C", aTamCCRes[1], 0 },;  			// Codigo Reduzido do Centro de Custo
	{ "DESCCC" 	, "C", nTamCC		, 0 },;  			// Descricao do Centro de Custo
	{ "ITEM"		, "C", aTamItem[1]	, 0 },; 	 		// Codigo do Item
	{ "ITEMRES" 	, "C", aTamItRes[1], 0 },;  			// Codigo Reduzido do Item
	{ "DESCITEM" 	, "C", nTamItem		, 0 },;  			// Descricao do Item
	{ "CLVL"		, "C", aTamClVl[1]	, 0 },; 	 		// Codigo da Classe de Valor
	{ "CLVLRES"	, "C", aTamCVRes[1], 0 },; 		 	// Cod. Red. Classe de Valor
	{ "DESCCLVL"   , "C", nTamClVl		, 0 },;  			// Descricao da Classe de Valor
	{ "SALDOANT"	, "N", aTamVal[1]+2	, nDecimais},; 		// Saldo Anterior
	{ "SALDOANTDB"	, "N", aTamVal[1]+2	, nDecimais},; 		// Saldo Anterior Debito
	{ "SALDOANTCR"	, "N", aTamVal[1]+2	, nDecimais},; 		// Saldo Anterior Credito
	{ "SALDODEB"	, "N", aTamVal[1]+2	, nDecimais },;  	// Debito
	{ "SALDOCRD"	, "N", aTamVal[1]+2	, nDecimais },;  	// Credito
	{ "SALDOATU"	, "N", aTamVal[1]+1	, nDecimais },;  	// Saldo Atual
	{ "SALDOATUDB"	, "N", aTamVal[1]+2	, nDecimais },;  	// Saldo Atual Debito
	{ "SALDOATUCR"	, "N", aTamVal[1]+2	, nDecimais },;  	// Saldo Atual Credito
	{ "MOVIMENTO"	, "N", aTamVal[1]+2	, nDecimais },;  	// Movimento do Periodo
	{ "TIPOCONTA"	, "C", 01			, 0 },;				// Conta Analitica / Sintetica
	{ "TIPOCC"  	, "C", 01			, 0 },;				// Centro de Custo Analitico / Sintetico
	{ "TIPOITEM"	, "C", 01			, 0 },;				// Item Analitica / Sintetica
	{ "TIPOCLVL"	, "C", 01			, 0 },;				// Classe de Valor Analitica / Sintetica
	{ "CCSUP"		, "C", aTamCC[1]	, 0 },;				// Codigo do Centro de Custo Superior
    { "CCNORMAL"  	, "C", 01			, 0 },;				// Situacao
	{ "ITSUP"		, "C", aTamItem[1]	, 0 },;				// Codigo do Item Superior
    { "ITNORMAL"  	, "C", 01			, 0 },;				// Situacao
	{ "CLSUP"	    , "C", aTamClVl[1] , 0 },;				// Codigo da Classe de Valor Superior
    { "CLNORMAL"  	, "C", 01			, 0 },;				// Situacao
	{ "ORDEM"		, "C", 10			, 0 },;				// Ordem
	{ "GRUPO"		, "C", nTamGrupo	, 0 },;				// Grupo Contabil
	{ "IDENTIFI"	, "C", 01			, 0 },;
		{ "TOTVIS"		, "C", 01			, 0 },;
		{ "SLDENT"		, "C", 01			, 0 },;
		{ "FATSLD"		, "C", 01			, 0 },;
		{ "VISENT"		, "C", 01			, 0 },;
		{ "ESTOUR" 	, "C", 01			, 0 },;			 	//Define se a conta esta estourada ou nao
	{ "NIVEL1"		, "L", 01			, 0 },;
		{ "NATCTA"     , "C", 02           , 0 }}             //NATCTA -campo de natureza da conta para relatorio CTBR047
	// Logico para identificar se
	// eh de nivel 1 -> usado como
	// totalizador do relatorio]

	If _lCtbIsCube
		aAreaAnt := GetArea()
		DbSelectArea('CT0')
		DbSetOrder(1)
		If DbSeek( xFilial('CT0') + '05' )
			While CT0->(!Eof()) .And. CT0->CT0_FILIAL == xFilial('CT0')

				AADD( aCampos,{ "CODENT"+CT0->CT0_ID	, "C", TamSx3(CT0->CT0_CPOCHV)[1]	, 0 } )
				AADD( aCampos,{ "DESCENT"+CT0->CT0_ID  	, "C", TamSx3(CT0->CT0_CPODSC)[1]	, 0 } )
				AADD( aCampos,{ "TIPOENT"+CT0->CT0_ID  	, "C", 01	, 0 } )

				CT0->(DbSkip())
			EndDo
		EndIf
		RestArea(aAreaAnt)
	EndIf

	// Usado no mutacoes de patrimonio liquido inclui campo que alem da descricao da entidade
	// Que esta no DESCCTA tem tambem a descricao da conta inicial CTS_CT1INI
	If 	Type("lTRegCts") # "U" .And. ValType(lTRegCts) = "L" .And. lTRegCts
		Aadd(aCampos, { "DESCORIG"	, "C", nTamCta		, 0 } )	// Descricao da Origem do Valor
	Endif
	Aadd( aCampos, { "DESCCONT", "C", 200, 0 } ) //Descrição da origem do valor
EndIf

Aadd(aCampos, { "FILIAL"	, "C", nTamFilial, 0 } )	// Cria Filial do Sistema

If CTS->(FieldPos("CTS_COLUNA")) > 0
	Aadd(aCampos, { "COLUNA"   	, "N", 01			, 0 })
EndIf

If 	Type("dSemestre") # "U" .And. ValType(dSemestre) = "D"
	Aadd(aCampos, { "SALDOSEM"	, "N", 17		, nDecimais }) 	// Saldo semestre
Endif

If Type("dPeriodo0") # "U" .And. ValType(dPeriodo0) = "D"
	Aadd(aCampos, { "SALDOPER"	, "N", 17		, nDecimais }) 	// Saldo Periodo determinado
	Aadd(aCampos, { "MOVIMPER"	, "N", 17		, nDecimais }) 	// Saldo Periodo determinado
Endif

If Type("lComNivel") # "U" .And. ValType(lComNivel) = "L"
	Aadd(aCampos, { "NIVEL"   	, "N", 02			, 0 })		// Nivel hieraquirco - Quanto maior mais analitico
Endif

If ( cAlias = "CT7" .And. SuperGetMv("MV_CTASUP") = "S" ) .Or. ;
		( cAlias = "CT3" .And. SuperGetMv("MV_CTASUP") = "S" ) .Or. ;
		(cAlias == "CTU" .And. cIdent == "CTT" .And. GetNewPar("MV_CCSUP","")  == "S")  .Or. ;
		(cAlias == "CTU" .And. cIdent == "CTD" .And. GetNewPar("MV_ITSUP","") == "S") .Or. ;
		(cAlias == "CTU" .And. cIdent == "CTH" .And. GetNewPar("MV_CLSUP","") == "S")
	Aadd(aCampos, { "ORDEMPRN" 	, "N", 06			, 0 })		// Ordem para impressao
Endif

If cPaisLoc =="RUS"
	Aadd(aCampos, { "INIBALANCE"		, "N" , 17			, nDecimais })
EndIf

If lMovPeriodo
	Aadd(aCampos, { "MOVPERANT"		, "N" , 17			, nDecimais }) 	// Saldo Periodo Anterior
EndIf

///// TRATAMENTO PARA ATUALIZAÇÃO DE SALDO BASE
//Se os saldos basicos nao foram atualizados na dig. lancamentos
If !lAtSldBase .And. !__IsCtbJob
	dIniRep := ctod("")
	If Need2Reproc(dDataFim,cMoeda,cSaldos,@dIniRep)
		//Chama Rotina de Atualizacao de Saldos Basicos.
		oProcess := MsNewProcess():New({|lEnd|	CTBA190(.T.,dIniRep,dDataFim,cFilAnt,cFilAnt,cSaldos,.T.,cMoeda) },"","",.F.)
		oProcess:Activate()
	EndIf
Endif

//// TRATAMENTO PARA ATUALIZAÇÃO DE SALDOS COMPOSTOS ANTES DE EXECUTAR A QUERY DE FILTRAGEM
Do Case
Case cAlias == 'CTU'
	//Verificar se tem algum saldo a ser atualizado por entidade
	If cIdent == "CTT"
		cOrigem := 	'CT3'
	ElseIf cIdent == "CTD"
		cOrigem := 	'CT4'
	ElseIf cIdent == "CTH"
		cOrigem := 	'CTI'
	Else
		cOrigem := 	'CTI'
	Endif
Case cAlias == 'CTV'
	cOrigem := "CT4"
	//Verificar se tem algum saldo a ser atualizado
Case cAlias == 'CTW'
	cOrigem		:= 'CTI'	/// HEADER POR CLASSE DE VALORES
	//Verificar se tem algum saldo a ser atualizado
Case cAlias == 'CTX'
	cOrigem		:= 'CTI'
EndCase

Do Case
	/************************************
	Consulta saldo pelo cubo contabil
	//************************************/
Case cAlias  == "CVY"
	cEntidIni	:= cContaIni
	cEntidFim	:= cContaFim
	cCodMasc	:= aSetOfBook[2]
	cChave 		:= "ECX+ECY"
	aChave  	:= {"ECX","ECY"}

	//Se nao tiver plano gerencial.
	If Empty(aSetOfBook[5])
		/// EXECUTA QUERY RETORNANDO A ESTRUTURA E SALDOS NO ALIAS TRBTMP
		If cFilUsu == ".T."
			cFilUsu := ""
		EndIf
		CtbRunCube(dDataIni,dDataFim,cAlias,cEntidIni,cEntidFim,cCCIni,cCCFim,cMoeda,;
			cSaldos,aSetOfBook,lImpMov,lVlrZerado,lImpAntLp,dDataLP,cFilUsu,cMoedaDsc,aSelFil,dDtCorte,lTodasFil,aTmpFil)

		If Empty(cFilUSU)
			cFILUSU := ".T."
		Endif
		lTemQuery := .T.
	Endif


Case cAlias  == "CT7"
	cEntidIni	:= cContaIni
	cEntidFim	:= cContaFim
	cCodMasc		:= aSetOfBook[2]
	/*
	If nGrupo == 1
		cChave 	:= "CONTA+GRUPO"
		aChave	:= {"CONTA","GRUPO"}
	Else									// Indice por Grupo -> Totaliza por grupo
		cChave 	:= "CONTA"
		aChave	:= {"CONTA"}
	EndIf
	*/
	//| ALLIAR \/ |
	If nGrupo == 1
		cChave 	:= "FILIAL+CONTA+GRUPO"
		aChave	:= {"FILIAL","CONTA","GRUPO"}
	Else									// Indice por Grupo -> Totaliza por grupo
		cChave 	:= "FILIAL+CONTA"
		aChave	:= {"FILIAL","CONTA"}
	EndIf	
	//| ALLIAR /\ |	


	//Se nao tiver plano gerencial.
	If Empty(aSetOfBook[5])
		/// EXECUTA QUERY RETORNANDO A ESTRUTURA E SALDOS NO ALIAS TRBTMP
		If cFilUsu == ".T."
			cFilUsu := ""
		EndIf
		
		PrepTemporaria(aSelFil)  // Alliar
		U_XCT7BlnQry(dDataIni,dDataFim,cAlias,cEntidIni,cEntidFim,cMoeda,;
			cSaldos,aSetOfBook,lImpMov,lVlrZerado,lImpAntLp,dDataLP,cFilUsu,cMoedaDsc,aSelFil,dDtCorte,lTodasFil,aTmpFil)
		If Empty(cFilUSU)
			cFILUSU := ".T."
		Endif
		lTemQuery := .T.
	Endif


Case cAlias == 'CT3'
	cEntidIni	:= cCCIni
	cEntidFim	:= cCCFim

	If lImpConta
		If cHeader == "CT1"
			cChave		:= "CONTA+CUSTO"
			aChave		:=  {"CONTA","CUSTO"}
			cCodMasc	:= aSetOfBook[6]
		Else
			If nGrupo == 2
				cChave   := "CUSTO+CONTA"
				aChave   := {"CUSTO","CONTA"}
			Else									// Indice por Grupo -> Totaliza por grupo
				cChave 	:= "CUSTO+CONTA+GRUPO"
				aChave  := {"CUSTO","CONTA","GRUPO"}
			EndIf
			cCodMasc	:= aSetOfBook[2]
			cMascaraG	:= aSetOfBook[6]
			lEntSint	:= lCttSint
			cEntid_de	:= cEntidIni
			cEntid_ate	:= cEntidFim
		Endif
	Else		//Balancete de Centro de Custo (filtrando por conta)
		cChave		:= "CUSTO"
		aChave   	:= {"CUSTO"}
		cCodMasc:= aSetOfBook[6]
	EndIf


	If  Empty(aSetOfBook[5])
		If cFilUsu == ".T."
			cFilUsu := ""
		EndIf
		If lImpConta
			IF !lCompEnt
				/// EXECUTA QUERY RETORNANDO A ESTRUTURA E SALDOS NO ALIAS TRBTMP
				CT3BlnQry(dDataIni,dDataFim,cAlias,cContaIni,cContaFim,cCCIni,cCCFim,cMoeda,;
					cSaldos,aSetOfBook,lImpMov,lVlrZerado,lImpAntLp,dDataLP,cFilUSU,aSelFil,lTodasFil,aTmpFil)
			Else
				/// EXECUTA QUERY RETORNANDO A ESTRUTURA E SALDOS NO ALIAS TRBTMP
				CT3BlnQryC(dDataIni,dDataFim,cAlias,cContaIni,cContaFim,cCCIni,cCCFim,cMoeda,;
					cSaldos,aSetOfBook,lImpMov,lVlrZerado,lImpAntLp,dDataLP,cFilUSU,aSelFil,,aTmpFil)
			Endif
		Else
			Ct3Bln1Ent(dDataIni,dDataFim,cAlias,cContaIni,cContaFim,cCCIni,cCCFim,cMoeda,;
				cSaldos,aSetOfBook,lImpMov,lVlrZerado,lImpAntLP,dDataLP,cFilUsu,;
				lRecDesp0,cRecDesp,dDtZeraRD,aSelFil,lTodasFil,aTmpFil)
		EndIf
		lTemQuery := .T.
		If Empty(cFilUSU)
			cFILUSU := ".T."
		Endif
	EndIf


Case cAlias =='CT4'
	If lImp3Ent	//Balancete CC / Conta / Item
		If cHeader == "CTT"
			If  Empty(aSetOfBook[5])
				If cFilUsu == ".T."
					cFilUsu := ""
				EndIf
				/// EXECUTA QUERY RETORNANDO A ESTRUTURA E SALDOS NO ALIAS TRBTMP
				CT4Bln3Ent(dDataIni,dDataFim,cAlias,cContaIni,cContaFim,cCCIni,cCCFim,cItemIni,cItemFim,cMoeda,;
					cSaldos,aSetOfBook,lImpMov,lVlrZerado,lImpAntLp,dDataLP,cFilUSU,aSelFil,lTodasFil,aTmpFil)
				lTemQuery := .T.
				If Empty(cFilUSU)
					cFILUSU := ".T."
				Endif
			EndIf

			cEntidIni	:= cCCIni
			cEntidFim	:= cCCFim
			cChave		:= "CUSTO+CONTA+ITEM"
			//cChave		:= "(cArqTmpAnt)->CUSTO+cContaRef+(cArqTmpAnt)->CUSTO"
			aChave 		:= {"CUSTO","CONTA","ITEM"}
			cCodMasc	:= aSetOfBook[2]
		EndIf
	Else
		cEntidIni	:= cItemIni
		cEntidFim	:= cItemFim
		If lImpConta
			If cHeader == "CT1"	//Se for for Balancete Conta x Item
				cChave			:= "CONTA+ITEM"
				aChave   		:= {"CONTA","ITEM"}
				cCodMasc		:= aSetOfBook[7]
			Else
				cChave   		:= "ITEM+CONTA"
				aChave   		:= {"ITEM","CONTA"}
				cCodMasc		:= aSetOfBook[2]
				cMascaraG		:= aSetOfBook[7]
				lEntSint		:= lCttSint
				cEntid_de		:= cEntidIni
				cEntid_ate		:= cEntidFim
			EndIf
		Else	//Balancete de Item filtrando por conta
			cChave			:= "ITEM"
			aChave  	 	:= {"ITEM"}
			cCodMasc		:= aSetOfBook[7]
		EndIf

		If  Empty(aSetOfBook[5])
			If cFilUsu == ".T."
				cFilUsu := ""
			EndIf
			If lImpConta
				/// EXECUTA QUERY RETORNANDO A ESTRUTURA E SALDOS NO ALIAS TRBTMP
				CT4BlnQry(dDataIni,dDataFim,cAlias,cContaIni,cContaFim,cItemIni,cItemFim,cMoeda,;
					cSaldos,aSetOfBook,lImpMov,lVlrZerado,lImpAntLp,dDataLP,cFilUSU,aSelFil,lTodasFil,aTmpFil)
			Else
				Ct4Bln1Ent(dDataIni,dDataFim,cAlias,cContaIni,cContaFim,cCCIni,cCCFim,cItemIni,cItemFim,;
					cMoeda,cSaldos,aSetOfBook,lImpMov,lVlrZerado,lImpAntLP,dDataLP,cFilUsu,;
					lRecDesp0,cRecDesp,dDtZeraRD,aSelFil,lTodasFil,aTmpFil)
			EndIf
			lTemQuery := .T.
			If Empty(cFilUSU)
				cFILUSU := ".T."
			Endif
		EndIf

	EndIf
Case cAlias == 'CTI'
	If lImp4Ent	//Balancete CC x Cta x Item x Cl.Valor
		If cHeader == "CTT"

			If  Empty(aSetOfBook[5]) .and. !lImpAntLP
				If cFilUsu == ".T."
					cFilUsu := ""
				EndIf
				/// EXECUTA QUERY RETORNANDO A ESTRUTURA E SALDOS NO ALIAS TRBTMP
				CTIBln4Ent(dDataIni,dDataFim,cAlias,cContaIni,cContaFim,cCCIni,cCCFim,cItemIni,cItemFim,;
					cClVlIni,cClVlFim,cMoeda,cSaldos,aSetOfBook,lImpMov,lVlrZerado,lImpAntLp,dDataLP,aSelFil,lTodasFil,aTmpFil)
				lTemQuery := .T.
				If Empty(cFilUSU)
					cFILUSU := ".T."
				Endif
			EndIf
			cChave		:= "CUSTO+CONTA+ITEM+CLVL"
			aChave   	:= {"CUSTO","CONTA","ITEM","CLVL"}
			cEntidIni	:= cCCIni
			cEntidFim	:= cCCFim
			cCodMasc	:= aSetOfBook[2]
		EndIf
	Else
		cEntidIni	:= cClVlIni
		cEntidFim	:= cClvlFim

		lEntSint	:= lCttSint
		cEntid_de	:= cEntidIni
		cEntid_ate	:= cEntidFim

		If lImpConta
			If cHeader == "CT1"
				cChave		:= "CONTA+CLVL"
				aChave   	:= {"CONTA","CLVL"}
				cCodMasc	:= aSetOfBook[2]
			Else
				cChave   	:= "CLVL+CONTA"
				aChave   	:= {"CLVL","CONTA"}
				cCodMasc		:= aSetOfBook[2]
				cMascaraG		:= aSetOfBook[8]
			EndIf

			If Empty(aSetOfBook[5])
				If cFilUsu == ".T."
					cFilUsu := ""
				EndIf
				/// EXECUTA QUERY RETORNANDO A ESTRUTURA E SALDOS NO ALIAS TRBTMP
				CTIBlnQry(dDataIni,dDataFim,cAlias,cContaIni,cContaFim,cClVlIni,cClVlFim,cMoeda,;
					cSaldos,aSetOfBook,lImpMov,lVlrZerado,lImpAntLp,dDataLP,cFilUSU,aSelFil,lTodasFil,aTmpFil)
				lTemQuery := .T.
				If Empty(cFilUSU)
					cFILUSU := ".T."
				Endif
			EndIf
		Else	//Balancete de Cl.Valor filtrando por conta
			cChave   := "CLVL"
			aChave   := {"CLVL"}
			cCodMasc := aSetOfBook[8]
			If  Empty(aSetOfBook[5])
				If cFilUsu == ".T."
					cFilUsu := ""
				EndIf
				CtIBln1Ent(dDataIni,dDataFim,cAlias,cContaIni,cContaFim,cCCIni,cCCFim,cItemIni,cItemFim,;
					cClVlIni,cClVlFim,cMoeda,cSaldos,aSetOfBook,lImpMov,lVlrZerado,lImpAntLP,dDataLP,cFilUsu,;
					lRecDesp0,cRecDesp,dDtZeraRD,aSelFil,lTodasFil,aTmpFil)
				lTemQuery := .T.
				If Empty(cFilUSU)
					cFILUSU := ".T."
				Endif
			EndIf
		EndIf
	EndIf
Case cAlias == 'CTU'
	If cIdent == 'CTT'
		cEntidIni	:= cCCIni
		cEntidFim	:= cCCFim
		cChave		:= "CUSTO"
		aChave  	:= {"CUSTO"}
		cCodMasc		:= aSetOfBook[6]
	ElseIf cIdent == 'CTD'
		cEntidIni	:= cItemIni
		cEntidFim	:= cItemFim
		cChave   	:= "ITEM"
		aChave   	:= {"ITEM"}
		cCodMasc		:= aSetOfBook[7]
	ElseIf cIdent == 'CTH'
		cEntidIni	:= cClVlIni
		cEntidFim	:= cClvlFim
		cChave  	:= "CLVL"
		aChave   	:= {"CLVL"}
		cCodMasc		:= aSetOfBook[8]
	Endif

	If  Empty(aSetOfBook[5])
		/// EXECUTA QUERY RETORNANDO A ESTRUTURA E SALDOS NO ALIAS TRBTMP
		If cFilUsu == ".T."
			cFilUsu := ""
		EndIf
		CTUBlnQry(dDataIni,dDataFim,cAlias,cIdent,cEntidIni,cEntidFim,cMoeda,cSaldos,aSetOfBook,lImpMov,lVlrZerado,lImpAntLP,dDataLP,cFilUsu,aSelFil,lTodasFil,aTmpFil)
		lTEmQuery := .T.
		If Empty(cFilUSU)
			cFILUSU := ".T."
		Endif
	EndIf
Case cAlias == 'CTV'
	If cHeader == 'CTT'
		cChave   	:= "CUSTO+ITEM"
		aChave   	:= {"CUSTO","ITEM"}
		cEntidIni1	:= cCCIni
		cEntidFim1	:= cCCFim
		cEntidIni2	:= cItemIni
		cEntidFim2	:= cItemFim
	ElseIf cHeader == 'CTD'
		cChave   	:= "ITEM+CUSTO"
		aChave   	:= {"ITEM","CUSTO"}
		cEntidIni1	:= cItemIni
		cEntidFim1	:= cItemFim
		cEntidIni2	:= cCCIni
		cEntidFim2	:= cCCFim
	EndIf
Case cAlias == 'CTW'
	If cHeader	== 'CTT'
		cChave   	:= "CUSTO+CLVL"
		aChave   	:= {"CUSTO","CLVL"}
		cEntidIni1	:=	cCCIni
		cEntidFim1	:=	cCCFim
		cEntidIni2	:=	cClVlIni
		cEntidFim2	:=	cClVlFim
	ElseIf cHeader == 'CTH'
		cChave   	:= "CLVL+CUSTO"
		aChave   	:= {"CLVL","CUSTO"}
		cEntidIni1	:=	cClVlIni
		cEntidFim1	:=	cClVlFim
		cEntidIni2	:=	cCCIni
		cEntidFim2	:=	cCCFim
	EndIf
Case cAlias == 'CTX'
	If cHeader == 'CTD'
		cChave  	:= "ITEM+CLVL"
		aChave		:=  {"ITEM","CLVL"}
		cEntidIni1	:= 	cItemIni
		cEntidFim1	:= 	cItemFim
		cEntidIni2	:= 	cClVlIni
		cEntidFim2	:= 	cClVlFim
	ElseIf cHeader == 'CTH'
		cChave  	:= "CLVL+ITEM"
		aChave		:= {"CLVL","ITEM"}
		cEntidIni1	:= 	cClVlIni
		cEntidFim1	:= 	cClVlFim
		cEntidIni2	:= 	cItemIni
		cEntidFim2	:= 	cItemFim
	EndIf
Case cAlias	== 'CTY'
	cChave			:="ENTID1+ENTID2"
	aChave			:= {"ENTID1","ENTID2"}
	If cHeader == 'CTT' .And. cFiltroEnt == 'CTD'
		cEntidIni1	:= cCCIni
		cEntidFim1	:= cCCFim
		cEntidIni2	:= cClVlIni
		cEntidFim2	:= cClvlFim
	ElseIf cHeader == 'CTT' .And. cFiltroEnt == 'CTH'
		cEntidIni1	:= cCCIni
		cEntidFim1	:= cCCFim
		cEntidIni2	:= cItemIni
		cEntidFim2	:= cItemFim
	ElseIf cHeader == 'CTD' .And. cFiltroEnt == 'CTT'
		cEntidIni1	:= cItemIni
		cEntidFim1	:= cItemFim
		cEntidIni2	:= cClVlIni
		cEntidFim2	:= cClVlFim
	ElseIf cHeader == 'CTD' .And. cFiltroEnt == 'CTH'
		cEntidIni1	:= cItemIni
		cEntidFim1	:= cItemFim
		cEntidIni2	:= cCCIni
		cEntidFim2	:= cCCFim
	ElseIf cHeader == 'CTH' .And. cFiltroEnt == 'CTT'
		cEntidIni1	:= cClVlIni
		cEntidFim1	:= cClVlFim
		cEntidIni2	:= cItemIni
		cEntidFim2	:= cItemFim
	ElseIf cHeader == 'CTH' .And. cFiltroEnt == 'CTD'
		cEntidIni1	:= cClVlIni
		cEntidFim1	:= cClVlFim
		cEntidIni2	:= cCCIni
		cEntidFim2	:= cCCFim
	EndIf
EndCase

If !Empty(aSetOfBook[5])				// Indica qual o Plano Gerencial Anexado
	If cAlias $ "CT3/CT4/CTI"		//Se for Balancete Entidade/Entidade Gerencial
		Do Case
		Case cAlias == "CT3"
			cChave	:= "CUSTO+CONTA"
			aChave  := {"CUSTO","CONTA"}
		Case cAlias == "CT4"
			cChave	:= "ITEM+CONTA"
			aChave  := {"ITEM","CONTA"}
		Case cAlias == "CTI"
			cChave	:= "CLVL+CONTA"
			aChave  := {"CLVL","CONTA"}
		EndCase
	ElseIf cAlias = 'CTU'
		Do Case
		Case cIdent = 'CTT'
			cChave	:= "CUSTO"
			aChave  := {"CUSTO"}
		Case cIdent = 'CTD'
			cChave	:= "ITEM"
			aChave  := {"ITEM"}
		Case cIdent = 'CTH'
			cChave	:= "CLVL"
			aChave  := {"CLVL"}
		EndCase
	ElseIf cAlias  == "CVY"
		cChave := "ECX+ECY"
		aChave  := {"ECX","ECY"}
	Else
		If _lCtbIsCube
			If !Empty(cCodEntidade)
				cChave	:= "CODENT"+cCodEntidade
				aChave  := {"CODENT",cCodEntidade}
			Else
				cChave	:= "CONTA"
				aChave  := {"CONTA"}
			EndIf
		Else
			cChave	:= "CONTA"
			aChave  := {"CONTA"}
		EndIF
	EndIf
Endif

If Empty( aCampos )
	ConOutR("Erro na criacao da tabela temporaria")
Return .F.
EndIf

//-------------------
//Criação do objeto
//-------------------
_oTempTable := FWTemporaryTable():New(cArqAux)
_oTempTable:SetFields( aCampos )

lCriaInd := .T.
_oTempTable:AddIndex("1", aChave)
If !Empty(aSetOfBook[5])				// Indica qual o Plano Gerencial Anexado
	_oTempTable:AddIndex("2", {"ORDEM"})
Endif

If Ascan(aCampos,{|x|Upper(Alltrim(x[1])) == "ORDEMPRN"}) > 0
	_oTempTable:AddIndex("3", {"ORDEMPRN"})
	If cAlias == "CT7" .OR. cAlias == "CT3"
		If Alltrim(Upper(FunName())) == "CTBR180"
			_oTempTable:AddIndex("4", {"CUSTO","SUPERIOR","CONTA"})
		Else
			_oTempTable:AddIndex("4", {"SUPERIOR","CONTA"})
		EndIf
	ElseIf cAlias == "CTU"
		If cIdent == "CTT"
			_oTempTable:AddIndex("4", {"CCSUP","CUSTO"})
		ElseIf cIdent == "CTD"
			_oTempTable:AddIndex("4", {"ITSUP","ITEM"})
		ElseIf cIdent == "CTH"
			_oTempTable:AddIndex("4", {"CLSUP","CLVL"})
		EndIf
	EndIf
EndIf
//------------------
//Criação da tabela
//------------------
_oTempTable:Create()

cTableNam1 		:= _oTempTable:GetRealName()

DbSelectarea(cArqAux)
cchave:="FILIAL+CONTA"    //alliar  <---------------------------------------------

If !Empty(cPlanoRef) .Or. !Empty(cVersao)
	If !VldPlRef(aSetOfBook[1],cPlanoRef, cVersao)
		Return(cArqTmp)
	EndIf
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria Indice Temporario do Arquivo de Trabalho 1.             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lCriaInd
	dbSelectArea(cArqAux)
Endif

If FunName() <> "CTBR195" .or. (FunName() == "CTBR195" .and. !lImpAntLP)

	If lTemQuery .and. Select("TRBTMP") > 0 	/// E O ALIAS TRBTMP ESTIVER ABERTO (INDICANDO QUE A QUERY FOI EXECUTADA)
		If !Empty(cSegmento)
			If Len(aSetOfBook) == 0 .or. Empty(aSetOfBook[1])
				Help("CTN_CODIGO")
				Return(cArqTmp)
			Endif
			dbSelectArea("CTM")
			dbSetOrder(1)
			If MsSeek(xFilial()+cCodMasc)
				While !Eof() .And. CTM->CTM_FILIAL == xFilial() .And. CTM->CTM_CODIGO == cCodMasc
					nPos += Val(CTM->CTM_DIGITO)
					If CTM->CTM_SEGMEN == strzero(val(cSegmento),2)
						nPos -= Val(CTM->CTM_DIGITO)
						nPos ++
						nDigitos := Val(CTM->CTM_DIGITO)
						Exit
					EndIf
					dbSkip()
				EndDo
			Else
				Help("CTM_CODIGO")
				Return(cArqTmp)
			EndIf
		EndIf

		If !Empty(cMascaraG) .And. ;
		((cAlias == "CT3" .And. cHeader == "CTT") .Or. (cAlias == "CT4" .And. cHeader == "CTD") .Or.(cAlias == "CTI" .And. cHeader == "CTH"))
			If !Empty(cSegmentoG)
				dbSelectArea("CTM")
				dbSetOrder(1)
				If MsSeek(xFilial()+cMascaraG)
					While !Eof() .And. CTM->CTM_FILIAL == xFilial() .And. CTM->CTM_CODIGO == cMascaraG
						nPosG += Val(CTM->CTM_DIGITO)
						If CTM->CTM_SEGMEN == cSegmentoG
							nPosG -= Val(CTM->CTM_DIGITO)
							nPosG ++
							nDigitosG := Val(CTM->CTM_DIGITO)
							Exit
						EndIf
						dbSkip()
					EndDo
				EndIf
			EndIf
		EndIf

		dbSelectArea("TRBTMP")
		aStruTMP := dbStruct()			/// OBTEM A ESTRUTURA DO TMP

		nCampoLP	 := Ascan(aStruTMP,{|x| x[1]=="SLDLPANTDB"})
		dbSelectArea("TRBTMP")
		If ValType(oMeter) == "O"
			oMeter:SetTotal(TRBTMP->(RecCount()))
			oMeter:Set(0)
		EndIf
		
		lCT1DTEXSF := Type('TRBTMP->CT1DTEXSF') <> 'U'
		lCTTDTEXSF := Type('TRBTMP->CTTDTEXSF') <> 'U'
		lCTDDTEXSF := Type('TRBTMP->CTDDTEXSF') <> 'U'
		lCTHDTEXSF := Type('TRBTMP->CTHDTEXSF') <> 'U'
		
		lSLDANTCTDB := Type('(cArqAux)->SLDANTCTDB') <> 'U' 
		lSLDANTCTCR := Type('(cArqAux)->SLDANTCTCR') <> 'U'
		lSLLPATCTDB := Type('(cArqAux)->SLLPATCTDB') <> 'U'
		lSLLPATCTCR := Type('(cArqAux)->SLLPATCTCR') <> 'U'

		
		dbGoTop() // POSICIONA NO 1º REGISTRO DO TMP
		While TRBTMP->(!Eof())			/// REPLICA OS DADOS DA QUERY (TRBTMP) PARA P/ O TEMPORARIO EM DISCO

			//Se nao considera apuracao de L/P sera verificado na propria query
			dbSelectArea("TRBTMP")
			If !lVlrZerado .And. lImpAntLP
				If TRBTMP->((SALDOANTDB - SLDLPANTDB) - (SALDOANTCR - SLDLPANTCR)) == 0 .And. ;
						TRBTMP->(SALDODEB-MOVLPDEB) == 0 .And. TRBTMP->(SALDOCRD-MOVLPCRD) == 0
					TRBTMP->(dbSkip())
					Loop
				EndIf
			ElseIf !lVlrZerado
				If TRBTMP->(SALDOANTDB - SALDOANTCR) == 0 .And. TRBTMP->SALDODEB == 0 .And. TRBTMP->SALDOCRD == 0
					TRBTMP->(dbSkip())
					Loop
				EndIf
			EndIf

			//Verificacao da  Data Final de Existencia da Entidade somente se imprime saldo zerado
			// e se realemten nao tiver saldo e movimento para a entidade. Caso tenha algum movimento
			//ou saldo devera imprimir.
			If lVlrZerado
				If lImpAntLP
					If ((SALDOANTDB - SLDLPANTDB) == 0 .And. (SALDOANTCR - SLDLPANTCR) == 0 .And. ;
							(SALDODEB-MOVLPDEB) == 0 .And. (SALDOCRD-MOVLPCRD) == 0)
						//Se a data de existencia final  da entidade estiver preenchida e a data inicial do
						//relatorio for maior, nao ira imprimir a entidade.
						If  cAlias $ "CT7/CT3/CT4/CTI"
							If lCT1EXDTFIM .And. lCT1DTEXSF
								IF !Empty(TRBTMP->CT1DTEXSF) .And. (dDataIni > TRBTMP->CT1DTEXSF)
									dbSelectArea("TRBTMP")
									TRBTMP->(dbSkip())
									Loop
								EndIf
							EndIf
						Endif

						If cAlias == "CT3" .Or. ( cAlias == "CTU" .And. cIdent == "CTT")  .Or. ( cAlias == "CTI" .And. lImp4Ent)
							If lCTTEXDTFIM .And. lCTTDTEXSF
								If !Empty(TRBTMP->CTTDTEXSF) .And. (dDataIni > TRBTMP->CTTDTEXSF)
									dbSelectArea("TRBTMP")
									TRBTMP->(dbSkip())
									Loop
								EndIf
							Endif
						EndIf

						If cAlias == "CT4" .Or. ( cAlias == "CTU" .And. cIdent == "CTD") .Or. ( cAlias == "CTI" .And. lImp4Ent)
							If lCTDEXDTFIM .And. lCTDDTEXSF
								IF !Empty(TRBTMP->CTDDTEXSF) .And. (dDataIni > TRBTMP->CTDDTEXSF)
									dbSelectArea("TRBTMP")
									TRBTMP->(dbSkip())
									Loop
								EndIf
							EndIf
						Endif

						If cAlias == "CTI"	.Or. ( cAlias == "CTU" .And. cIdent == "CTH")
							If lCTHEXDTFIM .And. lCTHDTEXSF
								If !Empty(TRBTMP->CTHDTEXSF) .And. (dDataIni > TRBTMP->CTHDTEXSF)
									dbSelectArea("TRBTMP")
									TRBTMP->(dbSkip())
									Loop
								Endif
							EndIf
						EndIf
					EndIf
				Else
					If (SALDOANTDB  == 0 .And. SALDOANTCR  == 0 .And. SALDODEB == 0 .And. SALDOCRD == 0)
						If cAlias $ "CT7/CT3/CT4/CTI" .And. lCT1DTEXSF
							If lCT1EXDTFIM .AND. !Empty(TRBTMP->CT1DTEXSF) .And. (dDataIni > TRBTMP->CT1DTEXSF)
								dbSelectArea("TRBTMP")
								TRBTMP->(dbSkip())
								Loop
							EndIf
						EndIf

						If cAlias == "CT3" .Or. ( cAlias == "CTU" .And. cIdent == "CTT") .Or. ( cAlias == "CTI" .And. lImp4Ent)
							If lCTTEXDTFIM .And. lCTTDTEXSF
								IF !Empty(TRBTMP->CTTDTEXSF) .And. (dDataIni > TRBTMP->CTTDTEXSF)
									dbSelectArea("TRBTMP")
									TRBTMP->(dbSkip())
									Loop
								Endif
							EndIf
						EndIf

						If cAlias == "CT4" .Or. ( cAlias == "CTU" .And. cIdent == "CTD")  .Or. ( cAlias == "CTI" .And. lImp4Ent)
							If lCTDEXDTFIM .And. lCTDDTEXSF
								IF !Empty(TRBTMP->CTDDTEXSF) .And. (dDataIni > TRBTMP->CTDDTEXSF)
									dbSelectArea("TRBTMP")
									TRBTMP->(dbSkip())
									Loop
								EndIf
							Endif
						EndIf

						If cAlias == "CTI"	.Or. ( cAlias == "CTU" .And. cIdent == "CTH")
							If lCTHEXDTFIM .And. lCTHDTEXSF
								IF !Empty(TRBTMP->CTHDTEXSF) .And. (dDataIni > TRBTMP->CTHDTEXSF)
									dbSelectArea("TRBTMP")
									TRBTMP->(dbSkip())
									Loop
								EndIf
							Endif
						EndIf
					EndIf
				EndIf
			EndIf

			If cAlias == "CTU"
				Do Case
				Case cIdent	== "CTT"
					cCodigo	:= TRBTMP->CUSTO
				Case cIdent	== "CTD"
					cCodigo	:= TRBTMP->ITEM
				Case cIdent	== "CTH"
					cCodigo	:= TRBTMP->CLVL
				EndCase
			Else
				If lImpConta .Or. cAlias == "CT7"
					If cHeader == "CT1"
						If cAlias == "CT4"
							cCodigo	:= TRBTMP->ITEM
						ElseIf cAlias == "CT3"
							cCodigo	:= TRBTMP->CUSTO
						EndIf
					Else
						cCodigo	:= TRBTMP->CONTA
					EndIf
				Else
					If cAlias == "CT3"
						cCodigo	:= TRBTMP->CUSTO
					ElseIf cAlias == "CT4"
						cCodigo	:= TRBTMP->ITEM
					ElseIf cAlias == "CTI"
						cCodigo	:= TRBTMP->CLVL
					EndIf
				EndIf
				If cAlias == "CT3" .And. cHeader == "CTT"
					cCodGer	:= TRBTMP->CUSTO
				ElseIf cAlias == "CT4" .And. cHeader == "CTD"
					cCodGer	:= TRBTMP->ITEM
				ElseIf cAlias == "CTI" .And. cHeader == "CTH"
					cCodGer	:= TRBTMP->CLVL
				EndIf
			EndIf

			If Empty(cPlanoRef) .Or. Empty(cVersao)	//Verifica o segmento somente se nao for com plano referencial.
				If !Empty(cSegmento)
					If Empty(cSegIni) .And. Empty(cSegFim) .And. !Empty(cFiltSegm)
						If  !(Substr(cCodigo,nPos,nDigitos) $ (cFiltSegm) )
							TRBTMP->(dbSkip())
							Loop
						EndIf
					Else
						If Substr(cCodigo,nPos,nDigitos) < Alltrim(cSegIni) .Or. ;
								Substr(cCodigo,nPos,nDigitos) > Alltrim(cSegFim)
							TRBTMP->(dbSkip())
							Loop
						EndIf
					Endif
				EndIf


				//Caso faca filtragem por segmento gerencial,verifico se esta dentro
				//da solicitacao feita pelo usuario.
				If ( cAlias == "CT3" .And. cHeader == "CTT" ) .Or. ( cAlias == "CT4" .And. cHeader == "CTD" ) .Or.  ;
						 ( cAlias == "CTI" .And. cHeader == "CTH" )
					If !Empty(cSegmentoG)
						If Empty(cSegIniG) .And. Empty(cSegFimG) .And. !Empty(cFiltSegmG)
							If  !(Substr(cCodGer,nPosG,nDigitosG) $ (cFiltSegmG) )
								TRBTMP->(dbSkip())
								Loop
							EndIf
						Else
							If Substr(cCodGer,nPosG,nDigitosG) < Alltrim(cSegIniG) .Or. ;
								Substr(cCodGer,nPosG,nDigitosG) > Alltrim(cSegFimG)
								TRBTMP->(dbSkip())
								Loop
							EndIf
						Endif
					EndIf
				EndIf
			EndIf

			If &("TRBTMP->("+cFILUSU+")")
				RecLock(cArqAux,.T.)

				For nTRB := 1 to Len(aStruTMP)
					Field->&(aStruTMP[nTRB,1]) := TRBTMP->&(aStruTMP[nTRB,1])
					If Subs(aStruTmp[nTRB][1],1,6) $ "SALDODEB/SALDOCRD/SALDOANTDB/SALDOANTCR/SLDLPANTCR/SLDLPANTDB/MOVLPDEB/MOVLPCRD" .And. nDivide > 0
						Field->&(aStruTMP[nTRB,1])	:=((TRBTMP->&(aStruTMP[nTRB,1])))/ndivide
					EndIf
				Next
				
				
				//(cArqAux)->FILIAL	:= cFilAnt
				(cArqAux)->FILIAL	:= TRBTMP->(ALLIAR)  //cFilAnt
		
				//Log34Processo ((cArqAux)->FILIAL + " " + (cArqAux)->CONTA )
		
				
				If cAlias	== "CTU"
					Do Case
					Case cIdent	== "CTT"
						If Empty(TRBTMP->DESCCC)
							(cArqAux)->DESCCC		:= TRBTMP->DESCCC01
						EndIf
					Case cIdent == "CTD"
						If Empty(TRBTMP->DESCITEM)
							(cArqAux)->DESCITEM	:= TRBTMP->DESCIT01
						EndIf
					Case cIdent == "CTH"
						If Empty(TRBTMP->DESCCLVL)
							(cArqAux)->DESCCLVL	:= TRBTMP->DESCCV01
						EndIf
					EndCase
				Else
					If FwIsInCallStack('CTBR140')
						CT1->(dbSetOrder(1))
						If CT1->(dbSeek(xFilial("CT1")+TRBTMP->CONTA))
							(cArqAux)->DESCCTA := CT1->CT1_DESC01
						Else
							(cArqAux)->DESCCTA := " "
						EndIf						  
					Else
						If lImpConta .or. cAlias == "CT7"
							If Empty(TRBTMP->DESCCTA) .AND. TRBTMP->(FieldPos( "DESCCTA01" )) > 0 .AND. !Empty(TRBTMP->DESCCTA01)
								(cArqAux)->DESCCTA	:= TRBTMP->DESCCTA01
							EndIf
						EndIf
					EndIf
					
					If cAlias == "CT4"
						If !lImp3Ent
							If FwIsInCallStack('CTBR140')
								CTD->(dbSetOrder(1))
								If CTD->(dbSeek(xFilial("CTD")+TRBTMP->ITEM))
									(cArqAux)->DESCITEM	:= CTD->CTD_DESC01
								Else
									(cArqAux)->DESCITEM	:= " "
								EndIf
							Else
								If cMoeda <> '01' .And. Empty(TRBTMP->DESCITEM)
									(cArqAux)->DESCITEM	:= TRBTMP->DESCIT01
								EndIf
							EndIf
						EndIf

						If lImp3Ent	//Balancete CC / Conta / Item
							If Empty(TRBTMP->DESCCC)
								(cArqAux)->DESCCC	:= TRBTMP->DESCCC01
							EndIf

							If TRBTMP->ALIAS == 'CT4'
								If Empty(TRBTMP->DESCITEM)
									(cArqAux)->DESCITEM	:= TRBTMP->DESCIT01
								EndIf
							EndIf
						EndIf
					EndIf

					If cAlias == "CTI" .And. lImp4Ent
						If !Empty(CLVL)
							If Empty(TRBTMP->DESCCLVL)
								(cArqAux)->DESCCLVL	:= TRBTMP->DESCCV01
							EndIf
						EndiF

						If !Empty(ITEM)
							If Empty(TRBTMP->DESCITEM)
								(cArqAux)->DESCITEM	:= TRBTMP->DESCIT01
							EndIf
						Endif

						If !Empty(CUSTO)
							If Empty(TRBTMP->DESCCC)
								(cArqAux)->DESCCC		:= TRBTMP->DESCCC01
							EndIf
						EndIf
					EndIf
				EndIf

				//Se for Relatorio US Gaap
				If lUsGaap

					nSlAntGap	:= TRBTMP->(SALDOANTDB - SALDOANTCR)	// Saldo Anterior
					nSlAntGapD	:= TRBTMP->(SALDOANTDB)					// Saldo anterior debito
					nSlAntGapC	:= TRBTMP->(SALDOANTCR)					// Saldo anterior credito
					nSlAtuGap	:= TRBTMP->((SALDOANTDB+SALDODEB)- (SALDOANTCR+SALDOCRD))	// Saldo Atual
					nSlAtuGapD	:= TRBTMP->(SALDOANTDB+SALDODEB)					// Saldo Atual debito
					nSlAtuGapC	:= TRBTMP->(SALDOANTCR+SALDOCRD)					// Saldo Atual credito

					nSlDebGap	:= TRBTMP->((SALDOANTDB+SALDODEB) - SALDOANTDB)		// Saldo Debito
					nSlCrdGap	:= TRBTMP->((SALDOANTCR+SALDOCRD) - SALDOANTCR)		// Saldo Credito

					If cConsCrit == "5"	//Se for Criterio do Plano de Contas
						cCritPlCta	:= Ctr045Med(cMoedConv)
					EndIf

					If cConsCrit $ "123" .Or. (cConsCrit == "5" .And. cCritPlCta $ "123")
						If cConsCrit == "5"
							(cArqAux)->SALDOANT	:= CtbConv(cCritPlCta,dDataConv,cMoedConv,nSlAntGap)
							(cArqAux)->SALDOANTDB	:= CtbConv(cCritPlCta,dDataConv,cMoedConv,nSlAntGapD)
							(cArqAux)->SALDOANTCR	:= CtbConv(cCritPlCta,dDataConv,cMoedConv,nSlAntGapC)
							(cArqAux)->SALDOATU	:= CtbConv(cCritPlCta,dDataConv,cMoedConv,nSlAtuGap)
							(cArqAux)->SALDOATUDB	:= CtbConv(cCritPlCta,dDataConv,cMoedConv,nSlAtuGapD)
							(cArqAux)->SALDOATUCR	:= CtbConv(cCritPlCta,dDataConv,cMoedConv,nSlAntGapC)
							(cArqAux)->SALDODEB	:= CtbConv(cCritPlCta,dDataConv,cMoedConv,nSlDebGap)
							(cArqAux)->SALDOCRD	:= CtbConv(cCritPlCta,dDataConv,cMoedConv,nSlCrdGap)
						Else
							(cArqAux)->SALDOANT	:= CtbConv(cConsCrit,dDataConv,cMoedConv,nSlAntGap)
							(cArqAux)->SALDOANTDB	:= CtbConv(cConsCrit,dDataConv,cMoedConv,nSlAntGapD)
							(cArqAux)->SALDOANTCR	:= CtbConv(cConsCrit,dDataConv,cMoedConv,nSlAntGapC)
							(cArqAux)->SALDOATU	:= CtbConv(cConsCrit,dDataConv,cMoedConv,nSlAtuGap)
							(cArqAux)->SALDOATUDB	:= CtbConv(cConsCrit,dDataConv,cMoedConv,nSlAtuGapD)
							(cArqAux)->SALDOATUCR	:= CtbConv(cConsCrit,dDataConv,cMoedConv,nSlAntGapC)
							(cArqAux)->SALDODEB	:= CtbConv(cConsCrit,dDataConv,cMoedConv,nSlDebGap)
							(cArqAux)->SALDOCRD	:= CtbConv(cConsCrit,dDataConv,cMoedConv,nSlCrdGap)
						EndIf
					ElseIf cConsCrit == "4" .Or. (cConsCrit == "5" .And. cCritPlCta == "4")
						(cArqAux)->SALDOANT	:= nSlAntGap/nTaxaConv
						(cArqAux)->SALDOANTDB	:= nSlAntGapD/nTaxaConv
						(cArqAux)->SALDOANTCR	:= nSlAntGapC/nTaxaConv
						(cArqAux)->SALDOATU	:= nSlAtuGap/nTaxaConv
						(cArqAux)->SALDOATUDB	:= nSlAtuGapD/nTaxaConv
						(cArqAux)->SALDOATUCR	:= nSlAtuGapC/nTaxaConv
						(cArqAux)->SALDODEB	:= nSlDebGap/nTaxaConv
						(cArqAux)->SALDOCRD	:= nSlCrdGap/nTaxaConv
					EndIf
				EndIf

				If Empty( dDtCorte )
					If nCampoLP > 0
						(cArqAux)->SALDOANTDB	-= TRBTMP->SLDLPANTDB
						(cArqAux)->SALDOANTCR	-= TRBTMP->SLDLPANTCR
						(cArqAux)->SALDODEB		-= TRBTMP->MOVLPDEB
						(cArqAux)->SALDOCRD		-= TRBTMP->MOVLPCRD
					EndIf

					(cArqAux)->SALDOANT	 	:= (cArqAux)->(SALDOANTCR - SALDOANTDB)
					(cArqAux)->SALDOATUDB	:= (cArqAux)->(SALDOANTDB + SALDODEB)
					(cArqAux)->SALDOATUCR	:= (cArqAux)->(SALDOANTCR) + (cArqAux)->(SALDOCRD)
					(cArqAux)->SALDOATU		:= (cArqAux)->(SALDOATUCR - SALDOATUDB)
					(cArqAux)->MOVIMENTO	:= (cArqAux)->(SALDOCRD   - SALDODEB)
				Else
					nSaldoCrt := 0

					If lImpAntLP .And. nCampoLP > 0
						If lSLLPATCTDB .And. lSLLPATCTCR
							nSaldoCrt := ((cArqAux)->SLLPATCTDB - (cArqAux)->SLLPATCTCR)
						EndIf

						(cArqAux)->SALDOANTDB	:= (cArqAux)->((SALDOANTDB - SLDLPANTDB) ) + iif( nSaldoCrt > 0 , Abs( nSaldoCrt ) , 0 )
						(cArqAux)->SALDOANTCR	:= (cArqAux)->((SALDOANTCR - SLDLPANTCR) ) + iif( nSaldoCrt < 0 , Abs( nSaldoCrt ) , 0 )
						(cArqAux)->SALDODEB		-= TRBTMP->MOVLPDEB
						(cArqAux)->SALDOCRD		-= TRBTMP->MOVLPCRD
					Else
						If lSLDANTCTDB .And. lSLDANTCTCR
							nSaldoCrt := ((cArqAux)->SLDANTCTDB - (cArqAux)->SLDANTCTCR)
						EndIf

						(cArqAux)->SALDOANTDB	:= (cArqAux)->(SALDOANTDB) + iif( nSaldoCrt > 0 , Abs( nSaldoCrt ) , 0 )
						(cArqAux)->SALDOANTCR	:= (cArqAux)->(SALDOANTCR) + iif( nSaldoCrt < 0 , Abs( nSaldoCrt ) , 0 )
					EndIf

					(cArqAux)->SALDOANT		:= (cArqAux)->(SALDOANTCR - SALDOANTDB)
					(cArqAux)->SALDOATUDB	:= (cArqAux)->(SALDOANTDB + SALDODEB)
					(cArqAux)->SALDOATUCR	:= (cArqAux)->(SALDOANTCR + SALDOCRD)
					(cArqAux)->SALDOATU		:= (cArqAux)->(SALDOATUCR - SALDOATUDB)
					(cArqAux)->MOVIMENTO	:= (cArqAux)->(SALDOCRD   - SALDODEB)

				Endif


				//Se imprime saldo anterior do periodo anterior zerado, verificar o saldo atual da data de zeramento.
				If ( lImpConta .Or. cAlias == "CT7") .And. lRecDesp0 .And. Subs(TRBTMP->CONTA,1,1) $ cRecDesp

					If cAlias == "CT7" .Or. ( cAlias == "CT3" .And. cHeader == "CT1" )
						aSldRecDes	:= SaldoCT7Fil(TRBTMP->CONTA,dDtZeraRD,cMoeda,cSaldos,'CTBXFUN',.F.,nil,aSelFil,nil,lTodasFil)
					ElseIf cAlias == "CT3" .And. cHeader == "CTT"
						aSldRecDes	:= SaldoCT3Fil(TRBTMP->CONTA,TRBTMP->CUSTO,dDtZeraRD,cMoeda,cSaldos,'CTBXFUN',.F.,Nil,aSelFil,lTodasFil)
					ElseIf cAlias == "CT4" .And. cHeader == "CTD"
						cCusIni		:= Space(aTamCC[1])
						cCusFim		:= Repl("Z",aTamCC[1])
						aSldRecDes	:= SaldTotCT4(TRBTMP->ITEM,TRBTMP->ITEM,cCusIni,cCusFim,TRBTMP->CONTA,TRBTMP->CONTA,dDtZeraRD,cMoeda,cSaldos,aSelFil,,,,,,,,lTodasFil)
					Elseif cAlias == "CTI" .And. cHeader == "CTH"
						cCusIni		:= SPace(aTamCC[1])
						cCusFim		:= Repl("Z",aTamCC[1])

						cItIni  	:= Space(aTamItem[1])
						cItFim   	:= Repl("z",aTamItem[1])

						aSldRecDes := SaldTotCTI(TRBTMP->CLVL,TRBTMP->CLVL,cItIni,cItFim,cCusIni,cCusFim,;
							TRBTMP->CONTA,TRBTMP->CONTA,dDtZeraRD,cMoeda,cSaldos,aSelFil,,,,,,,,lTodasFil)
					EndIf

					If nDivide > 1
						For nCont := 1 To Len(aSldRecDes)
							aSldRecDes[nCont] := Round(NoRound((aSldRecDes[nCont]/nDivide),3),2)
						Next nCont
					EndIf

					nSldRDAtuD	:=	aSldRecDes[4]
					nSldRDAtuC	:=	aSldRecDes[5]
					nSldAtuRD	:= nSldRDAtuC - nSldRDAtuD

					(cArqAux)->SALDOANT		-= nSldAtuRD
					(cArqAux)->SALDOANTDB	-= nSldRDAtuD
					(cArqAux)->SALDOANTCR	-= nSldRDAtuC
					(cArqAux)->SALDOATU		-= nSldAtuRD
					(cArqAux)->SALDOATUDB	-= nSldRDAtuD
					(cArqAux)->SALDOATUCR	-= nSldRdAtuC
				EndIf

				IF (cArqAux)->( FieldPos( "NATCTA" ) ) > 0;
				.AND.	(cAlias == "CT3" .AND. cHeader $ "CT1|CTT");
				.OR.	(cAlias == "CT4" .And. cHeader == "CTD");
				.OR.	(cAlias == "CTI" .And. cHeader == "CTH");
				.OR.	cAlias == "CT7"
					(cArqAux)->NATCTA := CtbSXNatCta(TRBTMP->CONTA)   // Faz retorno do campo CT1_NATCTA
				Endif

				(cArqAux)->(MsUnlock())
			EndIf
			TRBTMP->(dbSkip())
			nMeter++
			if nMeter%1000 = 0
				If ValType(oMeter) == "O"
					oMeter:Set(nMeter)
				EndIf
			Endif
		Enddo

		dbSelectArea("TRBTMP")
		dbCloseArea()					/// FECHA O TRBTMP (RETORNADO DA QUERY)
		lTemQry := .T.
	Endif
EndIf

dbSelectArea(cArqAux)
dbSetOrder(1)

If cAlias $ 'CT3/CT4/CTI' //Se imprime CONTA+ ENTIDADE
	If !Empty(aSetOfBook[5])
		If !lImpConta	//Se for balancete de 1 entidade filtrada por conta
			If cAlias == "CT3"
				cIdent	:= "CTT"
			ElseIf cAlias == "CT4"
				cIdent	:= "CTD"
			ElseIf cAlias == "CTI"
				cIdent 	:= "CTH"
			EndIf
			// Monta Arquivo Lendo Plano Gerencial
			// Neste caso a filtragem de entidades contabeis é desprezada!
			CtbPlGeren(	oMeter,oText,oDlg,lEnd,dDataIni,dDataFim,cMoeda,aSetOfBook,"CTU",;
				cIdent,lImpAntLP,dDataLP,lVlrZerado,cEntidIni,cEntidFim,aGeren,lImpSint,lRecDesp0,cRecDesp,dDtZeraRD,,cSaldos,lPlGerSint,lConsSaldo,,lUsaNmVis,@cNomeVis)
			dbSetOrder(2)
		Else
			If lImpEntGer	//Se for balancete de Entidade (C.Custo/Item/Cl.Vlr por Entid. Gerencial)
				CtPlEntGer(	oMeter,oText,oDlg,lEnd,dDataIni,dDataFim,cMoeda,aSetOfBook,cAlias,cHeader,;
					lImpAntLP,dDataLP,lVlrZerado,cEntidIni,cEntidFim,cContaIni,cContaFim,;
					cCCIni,cCCFim,cItemIni,cItemFim,cClVlIni,cClVlFim,lImpSint,;
					lRecDesp0,cRecDesp,dDtZeraRD,nDivide,lFiltraCC,lFiltraIt,lFiltraCV, cSaldos )
			Else
				MsgAlert(cMensagem)
				Return
			EndIf
		EndIf
	Else
		If cHeader == "CT1"	//Se for Balancete Conta/Entidade
			//Atualizacao de sinteticas
			If lImpSint	//Se atualiza sinteticas
				CtCtEntSup(oMeter,oText,oDlg,cAlias,lNImpMov,cMoeda)
				If AllTrim(funname()) $ "CTBR140/CTBR145"
					CtContaSup(oMeter,oText,oDlg,lNImpMov,cMoeda,cMoedaDsc)
				Endif
			EndIf
		Else
			If !lImp3Ent	.And. !lImp4Ent //Se não for Balancete CC / Conta / Item
				If lImpConta


					If lImpSint	//Se atualiza sinteticas
						CtEntCtSup(oMeter,oText,oDlg,cAlias,lNImpMov,cMoeda,,cEntidIni,cEntidFim,lCttSint)
					EndIf

				Else
					If lImpSint
						If cAlias == "CT3"
							cIdent := "CTT"
						ElseIf cAlias == "CT4"
							cIdent := "CTD"
						ElseIf cAlias == "CTI"
							cIdent := "CTH"
						EndIf
						CtbCTUSup(oMeter,oText,oDlg,lNImpMov,cMoeda,cIdent)
					EndIf

				EndIf
			Else	//Se for Balancete CC / Conta / Item
				If lImp3Ent
					If lImpSint
						Ctb3CtaSup(oMeter,oText,oDlg,cAlias,lNImpMov,cMoeda,cHeader)
					Endif
				ElseIf cAlias == "CTI" .And. lImp4Ent .And. cHeader == "CTT"

					If  lImpAntLP
						CtbCta3Ent(oMeter,oText,oDlg,lEnd,dDataIni,dDataFim,cContaIni,;
							cContaFim,cCCIni,cCCFim,cItemIni,cItemFim,cClvlIni,cClVlFim,cMoeda,;
							cSaldos,aSetOfBook,nTamCta,cSegmento,cSegIni,cSegFim,cFiltSegm,lNImpMov,cAlias,cHeader,;
							lCusto,lItem,lClvl,lAtSldBase,nInicio,nFinal,cFilDe,cFilAte,lImpAntLP,dDataLP,;
							nDivide,lVlrZerado)
					EndIf
					If lImpSint
						Ctb4CtaSup(oMeter,oText,oDlg,cAlias,lNImpMov,cMoeda,cHeader)
					Endif
				EndIf
			EndIf
		EndIf
	EndIf
Else
	If cAlias $ 'CTU/CT7' .Or. (!Empty(aSetOfBook[5]) .And. Empty(cAlias))		//So Imprime Entidade ou demonstrativos
		If !Empty(aSetOfBook[5])				// Indica qual o Plano Gerencial Anexado
			// Monta Arquivo Lendo Plano Gerencial
			// Neste caso a filtragem de entidades contabeis é desprezada!
			CtbPlGeren(	oMeter,oText,oDlg,lEnd,dDataIni,dDataFim,cMoeda,aSetOfBook,cAlias,;
				cIdent,lImpAntLP,dDataLP,lVlrZerado,cEntidIni,cEntidFim,aGeren,lImpSint,lRecDesp0,cRecDesp,dDtZeraRD,;
				lMovPeriodo,cSaldos,lPlGerSint,lConsSaldo, cArqAux, lUsaNmVis,@cNomeVis,aSelfil,cQuadroCTB,lDemDRE , dFinalA)
			dbSetOrder(2)
		Else
			//Se nao for for Top Connect
			If lImpSint	//Se atualiza sinteticas
				Do Case
				Case cAlias =="CT7"
					//Atualizacao de sinteticas para codebase e topconnect
					xCtContaSup(aSelfil,oMeter,oText,oDlg,lNImpMov,cMoeda,cMoedaDsc)//<------------- aqui ----- alliar
				Case cAlias == "CTU"
					CtbCTUSup(oMeter,oText,oDlg,lNImpMov,cMoeda,cIdent)
				EndCase
			EndIf
		EndIf
	Else    	//Imprime Relatorios com 2 Entidades
		If !Empty(aSetOfBook[5])
			MsgAlert(cMensagem)
			Return
		Else
			If cAlias == 'CTY'		//Se for Relatorio de 2 Entidades filtrado pela 3a Entidade
				Ct2EntFil(oMeter,oText,oDlg,lEnd,dDataIni,dDataFim,cEntidIni1,cEntidFim1,cEntidIni2,;
					cEntidFim2,cHeader,cMoeda,cSaldos,aSetOfBook,cSegmento,cSegIni,cSegFim,cFiltSegm,;
					lNImpMov,cAlias,lCusto,lItem,lClVl,lAtSldBase,lAtSldCmp,nInicio,nFinal,;
					cFilDe,cFilAte,lImpAntLP,dDataLP,nDivide,lVlrZerado,cFiltroEnt,cCodFilEnt,aSelFil,lTodasFil)
			ElseIf  cAlias <> 'CVY'
				CtEntComp(oMeter,oText,oDlg,lEnd,dDataIni,dDataFim,cEntidIni1,cEntidFim1,cEntidIni2,;
					cEntidFim2,cHeader,cMoeda,cSaldos,aSetOfBook,cSegmento,cSegIni,cSegFim,cFiltSegm,;
					lNImpMov,cAlias,lCusto,lItem,lClVl,lAtSldBase,lAtSldCmp,nInicio,nFinal,;
					cFilDe,cFilAte,lImpAntLP,dDataLP,nDivide,lVlrZerado,cFiltroEnt,cCodFilEnt,cFilUsu,aSelFil,lTodasFil,aTmpFil)
			EndIf
		EndIf
	Endif
EndIf

dbSelectArea(cArqAux)

If FieldPos("ORDEMPRN") > 0

	dbSelectArea(cArqAux)
	DbSetOrder(1)
	DbGoTop()
	While ! Eof()
	
		If Alltrim(Upper(FunName())) == "CTBR180"
			If Empty(SUPERIOR)
				CtGerSup(CONTA, @nOrdem, cAlias,,CUSTO)
			EndIf
	
		ElseIf cAlias == "CT7" .OR. cAlias == "CT3"
			If Empty(SUPERIOR)
				CtGerSup(CONTA, @nOrdem, cAlias)
			EndIf
		ElseIf cAlias == "CTU"
			If cIdent == "CTT"
				If Empty(CCSUP)
					CtGerSup(CUSTO, @nOrdem,"CTU","CTT")
				EndIf
			ElseIf cIdent == "CTD"
				If Empty(ITSUP)
					CtGerSup(ITEM, @nOrdem,"CTU","CTD")
				EndIf
			ElseIf cIdent == "CTH"
				If Empty(CLSUP)
					CtGerSup(CLVL, @nOrdem,"CTU","CTH")
				Endif
			EndIf
		EndIf
		DbSkip()
		
	Enddo
	DbSetOrder(2)
	
Endif
//Se utiliza plano referencial
If !Empty(cPlanoRef) .And. !Empty(cVersao)

	If IsBlind()
		mv_par01	:= ""
	Else
		Pergunte("CTBPLREF2",.T.)
		MakeSqlExpr("CTBPLREF2")
	EndIf
	cArqTmp	:= CtGerPlRef(cTableNam1,cArqTmp,cChave,aChave,aCampos,cPlanoRef,cVersao,lImpSint,lNimpMOv,lImp3Ent,lImp4Ent,cArqAux,cAlias,cHeader,cMoeda,,cEntid_de,cEntid_Ate,lEntSint,;
	lImpConta,nPos,nPosG,nDigitos,nDigitosG,cSegmento, cSegmentoG, cSegIni, cSegIniG, cSegFim, cSegFimG,  cFiltSegm, cFiltSegmG, @_oTempTbPLRef)
	mv_par01	:= cMvPar01Ant


EndIf

CTDelTmpFil()
For nX := 1 TO Len(aTmpFil)
	CtbTmpErase(aTmpFil[nX])
Next


RestArea(aSaveArea)

If Select(cArqTmp)> 0
	cArqTmp->(dbGoTop())
EndIf

Return cArqTmp



Static Function CtbSXNatCta(cConta) 
Local aArea 		:= GetArea()
Local aAreaCT1	:= CT1->(GetArea())
Local cNatCTa		:= ""

dbSelectArea("CT1")
CT1->(dbSetOrder(1))// CT1_FILIAL + CT1_CONTA

If CT1->(MsSeek(xFilial("CT1") + cConta))
	cNatCTa := CT1->CT1_NATCTA
EndIf


RestArea(aAreaCT1)
RestArea(aArea)
Return cNatCTa



User Function XCT7BlnQry(dDataIni,dDataFim,cAlias,cContaIni,cContaFim,cMoeda,cTpSald,aSetOfBook,lImpMov,lVlrZerado,lImpAntLP,dDataLP,cFilUsu,cMoedaDsc,aSelFil,dDtCorte,lTodasFil,aTmpFil)

U_XCQ0BlnQry(@dDataIni,@dDataFim,@cContaIni,@cContaFim,@cMoeda,@cTpSald,@aSetOfBook,@lImpMov,@lVlrZerado,@lImpAntLP,@dDataLP,@cFilUsu,@cMoedaDsc,@aSelFil,@dDtCorte,@lTodasFil,@aTmpFil)

Return



User Function XCQ0BlnQry(dDataIni,dDataFim,cContaIni,cContaFim,cMoeda,cTpSald,aSetOfBook,lImpMov,lVlrZerado,lImpAntLP,dDataLP,cFilUsu,cMoedaDsc,aSelFil,dDtCorte,lTodasFil,aTmpFil)
Local cQuery			:= ""
Local aAreaQry		:= GetArea()		/// array com a posição no arquivo original
Local aTamVlr			:= TAMSX3("CT2_VALOR")
Local cCampUSU		:= ""
Local aStrSTRU		:= {}
Local nStruLen		:= 0
Local nStr				:= 1
Local lCT1EXDTFIM		:= CtbExDtFim("CT1")
Local cQryFilDia		:= ""
Local cQryFilMes		:= ""
Local cTmpFilDia
Local cTmpFilMes

DEFAULT lImpAntLP := .F.
DEFAULT dDataLP	  := CTOD("  /  /  ")
DEFAULT cMoedaDsc := '01'
DEFAULT aSelFil	:= {}
DEFAULT dDtCorte  := CTOD("  /  /  ")
DEFAULT lTodasFil := .F.
DEFAULT aTmpFil	:= {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Tratativa para o filtro de filiais           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !lTodasFil
	cQryFilMes := " CQ0_FILIAL = SZ8.Z8_FILAL" //+ U_xGetRngFil( aSelFil, "CQ0", .T., @cTmpFilMes )
	// cQryFilMes := " CQ0_FILIAL " + U_xGetRngFil( aSelFil, "CQ0", .T., @cTmpFilMes )   // Alliar
	aAdd(aTmpFil, cTmpFilMes)
	
	cQryFilDia := " CQ1_FILIAL = SZ8.Z8_FILAL " //+ U_xGetRngFil( aSelFil, "CQ1", .T., @cTmpFilDia )   // Alliar
	//cQryFilDia := " CQ1_FILIAL  " + U_xGetRngFil( aSelFil, "CQ1", .T., @cTmpFilDia )
	aAdd(aTmpFil, cTmpFilDia)
Endif

cQuery := " 	SELECT * FROM ( " + CRLF

//cQuery += " SELECT  CT1_CONTA CONTA,CT1_NORMAL NORMAL, CT1_RES CTARES, " + CRLF   // Alliar
cQuery += " SELECT SZ8.Z8_FILAL ALLIAR, CT1_CONTA CONTA,CT1_NORMAL NORMAL, CT1_RES CTARES, " + CRLF


cQuery += " 	CT1_CTASUP SUPERIOR, CT1_CLASSE TIPOCONTA, CT1_GRUPO GRUPO," + CRLF

If CT1->( FieldPos( "CT1_NATCTA" ) ) > 0
	cQuery += " CT1_NATCTA NATCTA, " + CRLF
Endif

If lCT1EXDTFIM
	cQuery += "     CT1_DTEXSF CT1DTEXSF, " + CRLF
EndIf

//TRATAMENTO PARA O FILTRO DE USUÁRIO NO RELATORIO
cCampUSU  := ""										//// DECLARA VARIAVEL COM OS CAMPOS DO FILTRO DE USUÁRIO
If ! Empty(cFILUSU)									//// SE O FILTRO DE USUÁRIO NAO ESTIVER VAZIO
	aStrSTRU := CT1->(dbStruct())				    //// OBTEM A ESTRUTURA DA TABELA USADA NA FILTRAGEM
	nStruLen := Len(aStrSTRU)
	
	For nStr := 1 to nStruLen                       //// LE A ESTRUTURA DA TABELA
		cCampUSU += aStrSTRU[nStr][1]+","			//// ADICIONANDO OS CAMPOS PARA FILTRAGEM POSTERIOR
	Next
Endif

cQuery += cCampUSU									//// ADICIONA OS CAMPOS NA QUERY

If CtbUso("CT1_DESC"+cMoedaDsc)  .And. !Empty(cMoedaDsc)
	If cMoedaDsc = '01'
		cQuery += "		CT1_DESC01 DESCCTA "   + CRLF
	Else
		cQuery += "		CT1_DESC"+cMoedaDsc+" DESCCTA, CT1_DESC01 DESCCTA01 "    + CRLF
	EndIf
Else
	If cMoeda == '01'
		cQuery += "		CT1_DESC01 DESCCTA "   + CRLF
	Else
		cQuery += "		CT1_DESC"+cMoeda+" DESCCTA, CT1_DESC01 DESCCTA01  "    + CRLF
	EndIf
EndIf

// Saldo Anterior
//data de corte para calculo do saldo anterior - Usado em Portugal³
If ! Empty( dDtCorte ) .And. Valtype( dDtCorte ) == 'D'
	cQuery += " ,( " + CRLF
	cQuery +=      " SELECT SUM(CQ1_DEBITO) SALDOANTDB " + CRLF
	cQuery +=      " FROM "+RetSqlName("CQ1")+" CQ1 " + CRLF
	cQuery +=      " WHERE "
	
	cQuery +=      " ARQ.CT1_CONTA	= CQ1_CONTA " + CRLF
	cQuery +=      " AND CQ1_MOEDA = '"+cMoeda+"' " + CRLF
	cQuery +=      " AND CQ1_TPSALD = '"+cTpSald+"' " + CRLF
	cQuery +=      " AND CQ1_DATA >=  '"+DTOS(dDtCorte)+"' " + CRLF
	cQuery +=      " AND CQ1_DATA <  '"+DTOS(dDataIni)+"' " + CRLF
	cQuery +=      " AND CQ1.D_E_L_E_T_ = '' " + CRLF
	If !lTodasFil
		cQuery += " AND " + cQryFilDia + CRLF
	Endif
	cQuery +=      " ) " + CRLF
	cQuery +=   " SALDOANTDB " + CRLF
	
	cQuery += " ,( " + CRLF
	cQuery +=      " SELECT SUM(CQ1_DEBITO) SLDANTCTDB " + CRLF
	cQuery +=      " FROM "+RetSqlName("CQ1")+" CQ1 " + CRLF
	cQuery +=      " WHERE "
	
	cQuery +=      " ARQ.CT1_CONTA	= CQ1_CONTA " + CRLF
	cQuery +=      " AND CQ1_MOEDA = '"+cMoeda+"' " + CRLF
	cQuery +=      " AND CQ1_TPSALD = '"+cTpSald+"' " + CRLF
	cQuery +=      " AND CQ1_DATA <  '"+DTOS(dDtCorte)+"' " + CRLF
	cQuery +=      " AND CQ1.D_E_L_E_T_ = '' " + CRLF
	If !lTodasFil
		cQuery += " AND "+cQryFilDia + CRLF
	Endif
	cQuery +=      " ) " + CRLF
	cQuery += "  SLDANTCTDB "   + CRLF
	
Else
	cQuery += " ,( " + CRLF
	cQuery +=      " SELECT SUM(CQ1_DEBITO) SALDOANTDB " + CRLF
	cQuery +=      " FROM "+RetSqlName("CQ1")+" CQ1 " + CRLF
	cQuery +=      " WHERE "
	cQuery +=      "  ARQ.CT1_CONTA	= CQ1_CONTA " + CRLF
	cQuery +=      " AND CQ1_MOEDA = '"+cMoeda+"' " + CRLF
	cQuery +=      " AND CQ1_TPSALD = '"+cTpSald+"' " + CRLF
	cQuery +=      " AND CQ1_DATA <  '"+DTOS(dDataIni)+"' " + CRLF
	cQuery +=      " AND CQ1.D_E_L_E_T_ = '' " + CRLF
	If !lTodasFil
		cQuery += " AND "+ cQryFilDia + CRLF
	Endif
	cQuery +=      " ) " + CRLF
	cQuery +=   " SALDOANTDB " + CRLF
EndIf



If lImpAntLP
	//data de corte para calculo do saldo anterior - Usado em Portugal³
	If ! Empty( dDtCorte ) .And. Valtype( dDtCorte ) == 'D'
		
		cQuery +=   " ,( " + CRLF
		cQuery +=           " SELECT SUM(CQ1_DEBITO) SLDLPANTDB " + CRLF
		cQuery +=           " FROM "+RetSqlName("CQ1")+" CQ1" + CRLF
		cQuery +=           " WHERE  "  + CRLF
		
		cQuery +=           "  ARQ.CT1_CONTA	= CQ1_CONTA " + CRLF
		cQuery +=           " AND CQ1_MOEDA = '"+cMoeda+"' " + CRLF
		cQuery +=           " AND CQ1_TPSALD = '"+cTpSald+"' " + CRLF
		cQuery +=           " AND CQ1_DATA >=  '"+DTOS(dDtCorte)+"' " + CRLF
		cQuery +=           " AND CQ1_DATA <  '"+DTOS(dDataIni)+"' " + CRLF
		cQuery +=           " AND CQ1_LP = 'Z' AND ((CQ1_DTLP <> ' ' AND CQ1_DTLP >= '"+DTOS(dDataLP)+"') OR (CQ1_DTLP = '' AND CQ1_DATA >= '"+DTOS(dDataLP)+"')) " + CRLF
		If !lTodasFil
			cQuery += " AND "+cQryFilDia + CRLF
		Endif
		cQuery +=           " AND CQ1.D_E_L_E_T_ = ''	" + CRLF
		cQuery +=        " ) " + CRLF
		cQuery +=       " SLDLPANTDB " + CRLF
		
		cQuery +=   " ,( " + CRLF
		cQuery +=           " SELECT SUM(CQ1_DEBITO) SLLPATCTDB " + CRLF
		cQuery +=           " FROM "+RetSqlName("CQ1")+" CQ1" + CRLF
		cQuery +=           " WHERE  "  + CRLF
		
		cQuery +=           "  ARQ.CT1_CONTA	= CQ1_CONTA " + CRLF
		cQuery +=           " AND CQ1_MOEDA = '"+cMoeda+"' " + CRLF
		cQuery +=           " AND CQ1_TPSALD = '"+cTpSald+"' " + CRLF
		cQuery +=           " AND CQ1_DATA <  '"+DTOS(dDtCorte)+"' " + CRLF
		cQuery +=           " AND CQ1_LP = 'Z' AND ((CQ1_DTLP <> ' ' AND CQ1_DTLP >= '"+DTOS(dDataLP)+"') OR (CQ1_DTLP = '' AND CQ1_DATA >= '"+DTOS(dDataLP)+"')) " + CRLF
		If !lTodasFil
			cQuery += " AND "+cQryFilDia + CRLF
		Endif
		cQuery +=           " AND CQ1.D_E_L_E_T_ = ''	" + CRLF
		cQuery +=        " ) " + CRLF
		cQuery +=       " SLLPATCTDB " + CRLF
		
	Else
		cQuery +=   " ,( " + CRLF
		cQuery +=           " SELECT SUM(CQ1_DEBITO) SLDLPANTDB " + CRLF
		cQuery +=           " FROM "+RetSqlName("CQ1")+" CQ1" + CRLF
		cQuery +=           " WHERE  "  + CRLF
		
		cQuery +=           "  ARQ.CT1_CONTA	= CQ1_CONTA " + CRLF
		cQuery +=           " AND CQ1_MOEDA = '"+cMoeda+"' " + CRLF
		cQuery +=           " AND CQ1_TPSALD = '"+cTpSald+"' " + CRLF
		cQuery +=           " AND CQ1_DATA <  '"+DTOS(dDataIni)+"' " + CRLF
		cQuery +=           " AND CQ1_LP = 'Z' AND ((CQ1_DTLP <> ' ' AND CQ1_DTLP >= '"+DTOS(dDataLP)+"') OR (CQ1_DTLP = '' AND CQ1_DATA >= '"+DTOS(dDataLP)+"')) " + CRLF
		If !lTodasFil
			cQuery += " AND "+cQryFilDia + CRLF
		Endif
		cQuery +=           " AND CQ1.D_E_L_E_T_ = '' " + CRLF
		cQuery +=        " ) " + CRLF
		cQuery +=       " SLDLPANTDB " + CRLF
	EndIf
EndIf


//data de corte para calculo do saldo anterior - Usado em Portugal³
If ! Empty( dDtCorte ) .And. Valtype( dDtCorte ) == 'D'
	cQuery += " ,( " + CRLF
	cQuery +=      " SELECT SUM(CQ1_CREDIT) SALDOANTCR " + CRLF
	cQuery +=      " FROM "+RetSqlName("CQ1")+" CQ1 " + CRLF
	cQuery +=      " WHERE "
	cQuery +=      "  ARQ.CT1_CONTA	= CQ1_CONTA " + CRLF
	cQuery +=      " AND CQ1_MOEDA = '"+cMoeda+"' " + CRLF
	cQuery +=      " AND CQ1_TPSALD = '"+cTpSald+"' " + CRLF
	cQuery +=      " AND CQ1_DATA >=  '"+DTOS(dDtCorte)+"' " + CRLF
	cQuery +=      " AND CQ1_DATA <  '"+DTOS(dDataIni)+"' " + CRLF
	cQuery +=      " AND CQ1.D_E_L_E_T_ = '' " + CRLF
	If !lTodasFil
		cQuery += " AND "+cQryFilDia + CRLF
	Endif
	cQuery +=      " ) " + CRLF
	cQuery +=   " SALDOANTCR " + CRLF
	
	cQuery += " ,( " + CRLF
	cQuery +=      " SELECT SUM(CQ1_CREDIT) SLDANTCTCR " + CRLF
	cQuery +=      " FROM "+RetSqlName("CQ1")+" CQ1 " + CRLF
	cQuery +=      " WHERE "
	cQuery +=      " ARQ.CT1_CONTA	= CQ1_CONTA " + CRLF
	cQuery +=      " AND CQ1_MOEDA = '"+cMoeda+"' " + CRLF
	cQuery +=      " AND CQ1_TPSALD = '"+cTpSald+"' " + CRLF
	cQuery +=      " AND CQ1_DATA <  '"+DTOS(dDtCorte)+"' " + CRLF
	cQuery +=      " AND CQ1.D_E_L_E_T_ = '' " + CRLF
	If !lTodasFil
		cQuery += " AND "+cQryFilDia + CRLF
	Endif
	cQuery +=      " ) " + CRLF
	cQuery += "  SLDANTCTCR "   + CRLF
Else
	cQuery += " ,( " + CRLF
	cQuery +=      " SELECT SUM(CQ1_CREDIT) SALDOANTCR " + CRLF
	cQuery +=      " FROM "+RetSqlName("CQ1")+" CQ1 " + CRLF
	cQuery +=      " WHERE "
	
	cQuery +=      "  ARQ.CT1_CONTA	= CQ1_CONTA " + CRLF
	cQuery +=      " AND CQ1_MOEDA = '"+cMoeda+"' " + CRLF
	cQuery +=      " AND CQ1_TPSALD = '"+cTpSald+"' " + CRLF
	cQuery +=      " AND CQ1_DATA <  '"+DTOS(dDataIni)+"' " + CRLF
	cQuery +=      " AND CQ1.D_E_L_E_T_ = '' " + CRLF
	If !lTodasFil
		cQuery += " AND "+cQryFilDia + CRLF
	Endif
	cQuery +=      " ) " + CRLF
	cQuery +=   " SALDOANTCR " + CRLF
EndIf

If lImpAntLP

	//data de corte para calculo do saldo anterior - Usado em Portugal³
	If ! Empty( dDtCorte ) .And. Valtype( dDtCorte ) == 'D'
		
		cQuery +=   " ,( " + CRLF
		cQuery +=           " SELECT SUM(CQ1_CREDIT) SLDLPANTCR " + CRLF
		cQuery +=           " FROM "+RetSqlName("CQ1")+" CQ1" + CRLF
		cQuery +=           " WHERE  "  + CRLF
		cQuery +=           " ARQ.CT1_CONTA	= CQ1_CONTA " + CRLF
		cQuery +=           " AND CQ1_MOEDA = '"+cMoeda+"' " + CRLF
		cQuery +=           " AND CQ1_TPSALD = '"+cTpSald+"' " + CRLF
		cQuery +=           " AND CQ1_DATA >=  '"+DTOS(dDtCorte)+"' " + CRLF
		cQuery +=           " AND CQ1_DATA <  '"+DTOS(dDataIni)+"' " + CRLF
		cQuery +=           " AND CQ1_LP = 'Z' AND ((CQ1_DTLP <> ' ' AND CQ1_DTLP >= '"+DTOS(dDataLP)+"') OR (CQ1_DTLP = '' AND CQ1_DATA >= '"+DTOS(dDataLP)+"')) " + CRLF
		If !lTodasFil
			cQuery += " AND "+cQryFilDia + CRLF
		Endif
		cQuery +=           " AND CQ1.D_E_L_E_T_ = '' " + CRLF
		cQuery +=        " ) " + CRLF
		cQuery +=       " SLDLPANTCR " + CRLF
		
		cQuery +=   " ,( " + CRLF
		cQuery +=           " SELECT SUM(CQ1_CREDIT) SLLPATCTCR " + CRLF
		cQuery +=           " FROM "+RetSqlName("CQ1")+" CQ1" + CRLF
		cQuery +=           " WHERE  "  + CRLF
		
		cQuery +=           " ARQ.CT1_CONTA	= CQ1_CONTA " + CRLF
		cQuery +=           " AND CQ1_MOEDA = '"+cMoeda+"' " + CRLF
		cQuery +=           " AND CQ1_TPSALD = '"+cTpSald+"' " + CRLF
		cQuery +=           " AND CQ1_DATA <  '"+DTOS(dDtCorte)+"' " + CRLF
		cQuery +=           " AND CQ1_LP = 'Z' AND ((CQ1_DTLP <> ' ' AND CQ1_DTLP >= '"+DTOS(dDataLP)+"') OR (CQ1_DTLP = '' AND CQ1_DATA >= '"+DTOS(dDataLP)+"')) " + CRLF
		If !lTodasFil
			cQuery += " AND "+cQryFilDia + CRLF
		Endif
		cQuery +=           " AND CQ1.D_E_L_E_T_ = ''" + CRLF
		cQuery +=        " ) " + CRLF
		cQuery +=       " SLLPATCTCR " + CRLF
	Else
		cQuery +=   ", ( " + CRLF
		cQuery +=           " SELECT SUM(CQ1_CREDIT) SLDLPANTCR " + CRLF
		cQuery +=           " FROM "+RetSqlName("CQ1")+" CQ1" + CRLF
		cQuery +=           " WHERE  "  + CRLF
		cQuery +=           " ARQ.CT1_CONTA	= CQ1_CONTA " + CRLF
		cQuery +=           " AND CQ1_MOEDA = '"+cMoeda+"' " + CRLF
		cQuery +=           " AND CQ1_TPSALD = '"+cTpSald+"' " + CRLF
		cQuery +=           " AND CQ1_DATA <  '"+DTOS(dDataIni)+"' " + CRLF
		cQuery +=           " AND CQ1_LP = 'Z' AND ((CQ1_DTLP <> ' ' AND CQ1_DTLP >= '"+DTOS(dDataLP)+"') OR (CQ1_DTLP = '' AND CQ1_DATA >= '"+DTOS(dDataLP)+"')) " + CRLF
		If !lTodasFil
			cQuery += " AND "+cQryFilDia + CRLF
		Endif
		cQuery +=           " AND CQ1.D_E_L_E_T_ = ''	" + CRLF
		cQuery +=        " ) " + CRLF
		cQuery +=       " SLDLPANTCR " + CRLF
	EndIf
EndIf


lMesmoMes := Month(dDataIni) == Month(dDataFim) .And. Year(dDataIni) == Year(dDataFim)
// ---------------------------  Saldo Atual ------------------------------------------------------------
cQuery +=       " ,( " + CRLF
cQuery +=                " SELECT SUM(CQ1_DEBITO) SALDODEB " + CRLF
cQuery +=                " FROM "+ RetSqlName("CQ1")+" CQ1" + CRLF
cQuery +=                " WHERE  "  + CRLF

cQuery +=                " ARQ.CT1_CONTA	= CQ1_CONTA " + CRLF
cQuery +=                " AND CQ1_MOEDA = '"+cMoeda+"' " + CRLF
cQuery +=                " AND CQ1_TPSALD = '"+cTpSald+"' " + CRLF
cQuery +=                " AND CQ1_DATA >= '"+DTOS(dDataIni)+"'  " + CRLF
cQuery +=                " AND CQ1_DATA <= '"+DTOS(dDataFim)+"' " + CRLF
cQuery +=                " AND CQ1.D_E_L_E_T_ = '' " + CRLF


If !lTodasFil
	cQuery += " AND "+cQryFilDia + CRLF
Endif
cQuery +=            " ) " + CRLF
cQuery += " SALDODEB " + CRLF

If lImpAntLP
	cQuery +=       " ,( " + CRLF
	cQuery +=                " SELECT SUM(CQ1_DEBITO) MOVLPDEB " + CRLF
	cQuery +=                " FROM "+RetSqlName("CQ1")+" CQ1" + CRLF
	cQuery +=                " WHERE  "  + CRLF
	cQuery +=                " ARQ.CT1_CONTA	= CQ1_CONTA " + CRLF
	cQuery +=                " AND CQ1_MOEDA = '"+cMoeda+"' " + CRLF
	cQuery +=                " AND CQ1_TPSALD = '"+cTpSald+"' " + CRLF
	cQuery +=                " AND CQ1_DATA >= '"+DTOS(dDataIni)+"'  " + CRLF
	cQuery +=                " AND CQ1_DATA <= '"+DTOS(dDataFim)+"' " + CRLF
	cQuery +=                " AND CQ1_LP = 'Z' AND ((CQ1_DTLP <> ' ' AND CQ1_DTLP >= '"+DTOS(dDataLP)+"') OR (CQ1_DTLP = '' AND CQ1_DATA >= '"+DTOS(dDataLP)+"'))"		 + CRLF
	cQuery +=                " AND CQ1.D_E_L_E_T_ = '' " + CRLF
	If !lTodasFil
		cQuery += " AND "+cQryFilDia + CRLF
	Endif
	cQuery +=            " ) " + CRLF
	cQuery += " MOVLPDEB " + CRLF
EndIf


cQuery +=       ", ( " + CRLF
cQuery +=                " SELECT SUM(CQ1_CREDIT) SALDOCRD " + CRLF
cQuery +=                " FROM "+RetSqlName("CQ1")+" CQ1" + CRLF
cQuery +=                " WHERE  "  + CRLF
cQuery +=                " ARQ.CT1_CONTA	= CQ1_CONTA " + CRLF
cQuery +=                " AND CQ1_MOEDA = '"+cMoeda+"' " + CRLF
cQuery +=                " AND CQ1_TPSALD = '"+cTpSald+"' " + CRLF
cQuery +=                " AND CQ1_DATA >= '"+DTOS(dDataIni)+"'  " + CRLF
cQuery +=                " AND CQ1_DATA <= '"+DTOS(dDataFim)+"' " + CRLF
cQuery +=                " AND CQ1.D_E_L_E_T_ = '' " + CRLF
If !lTodasFil
	cQuery += " AND "+cQryFilDia + CRLF
Endif

cQuery +=            " ) " + CRLF
cQuery += " SALDOCRD " + CRLF

If lImpAntLP
	
	cQuery +=       " ,( " + CRLF
	cQuery +=                " SELECT SUM(CQ1_CREDIT) MOVLPCRD " + CRLF
	cQuery +=                " FROM "+RetSqlName("CQ1")+" CQ1" + CRLF
	cQuery +=                " WHERE  "  + CRLF
	cQuery +=                " ARQ.CT1_CONTA	= CQ1_CONTA " + CRLF
	cQuery +=                " AND CQ1_MOEDA = '"+cMoeda+"' " + CRLF
	cQuery +=                " AND CQ1_TPSALD = '"+cTpSald+"' " + CRLF
	cQuery +=                " AND CQ1_DATA >= '"+DTOS(dDataIni)+"'  " + CRLF
	cQuery +=                " AND CQ1_DATA <= '"+DTOS(dDataFim)+"' " + CRLF
	cQuery +=                " AND CQ1_LP = 'Z' AND ((CQ1_DTLP <> ' ' AND CQ1_DTLP >= '"+DTOS(dDataLP)+"') OR (CQ1_DTLP = '' AND CQ1_DATA >= '"+DTOS(dDataLP)+"'))"		 + CRLF
	cQuery +=                " AND CQ1.D_E_L_E_T_ = '' " + CRLF
	If !lTodasFil
		cQuery += " AND "+cQryFilDia + CRLF
	Endif
	
	cQuery +=            " ) " + CRLF
	cQuery += " MOVLPCRD " + CRLF
EndIf

//cQuery += " 	FROM "+ RetSqlName("CT1")+" ARQ "  + CRLF  // Alliar
cQuery += " 	FROM "+RetSqlName("CT1")+" ARQ, " + RetSqlName('SZ8') + " SZ8 " + CRLF


cQuery += " 	WHERE ARQ.CT1_FILIAL = '"+xFilial("CT1")+"' " + CRLF
cQuery += " 	AND ARQ.CT1_CONTA BETWEEN '"+cContaIni+"' AND '"+cContaFim+"' " + CRLF
//cQuery += " 	AND ARQ.CT1_CLASSE = '2' " 	+ CRLF    // Alliar
cQuery += " 	AND ARQ.CT1_CLASSE = '2'  	AND ARQ.CT1_CONTA  = SZ8.Z8_CONTA AND SZ8.Z8_USER = '" + cUserName +"'"   + CRLF


If !Empty(aSetOfBook[1])										// SE HOUVER CODIGO DE CONFIGURAÇÃO DE LIVROS
	cQuery += " 	AND ARQ.CT1_BOOK LIKE '%"+aSetOfBook[1]+"%' " + CRLF  // FILTRA SOMENTE CONTAS DO MESMO SETOFBOOKS
Endif

cQuery += " 	AND ARQ.D_E_L_E_T_ = ' ' " + CRLF
cQuery += " 	) SALDOARQ " + CRLF

If !lVlrZerado .And. !lImpAntLP	//Se considerar posicao anterior LP sera verificado na gravacao do arquivo de trabalho
	cQuery += " 	WHERE " + CRLF
	cQuery += " 	( " + CRLF
	cQuery += " 	SALDOANTDB-SALDOANTCR <> 0 " + CRLF
	cQuery += " 	OR " + CRLF
	cQuery += " 	SALDODEB <> 0 " + CRLF
	cQuery += " 	OR " + CRLF
	cQuery += " 	SALDOCRD <> 0 " + CRLF
	cQuery += " 	) " + CRLF
Endif

cQuery += " ORDER BY ALLIAR, CONTA "    // Alliar

cQuery := ChangeQuery(cQuery)

If Select("TRBTMP") > 0
	dbSelectArea("TRBTMP")
	dbCloseArea()
Endif

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"TRBTMP",.T.,.F.)

TcSetField("TRBTMP","SALDOANTDB","N",aTamVlr[1],aTamVlr[2])
TcSetField("TRBTMP","SALDOANTCR","N",aTamVlr[1],aTamVlr[2])
TcSetField("TRBTMP","SALDODEB","N",aTamVlr[1],aTamVlr[2])
TcSetField("TRBTMP","SALDOCRD","N",aTamVlr[1],aTamVlr[2])

If lCT1EXDTFIM
	TCSetField("TRBTMP","CT1DTEXSF","D",8,0)
	TCSetField("TRBTMP","CT1_DTEXSF","D",8,0)
	TCSetField("TRBTMP","CT1_DTEXIS","D",8,0)
	TCSetField("TRBTMP","CT1_DTBLIN","D",8,0)
	TCSetField("TRBTMP","CT1_DTBLFI","D",8,0)
EndIf

If lImpAntLP
	TcSetField("TRBTMP","SLDLPANTDB","N",aTamVlr[1],aTamVlr[2])
	TcSetField("TRBTMP","SLDLPANTCR","N",aTamVlr[1],aTamVlr[2])
	TcSetField("TRBTMP","MOVLPDEB","N",aTamVlr[1],aTamVlr[2])
	TcSetField("TRBTMP","MOVLPCRD","N",aTamVlr[1],aTamVlr[2])
EndIf


//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³data de corte para calculo do saldo anterior - Usado em Portugal³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ! Empty( dDtCorte )
	TcSetField("TRBTMP","SLDANTCTDB","N",aTamVlr[1],aTamVlr[2])
	TcSetField("TRBTMP","SLDANTCTCR","N",aTamVlr[1],aTamVlr[2])
	
	If lImpAntLP
		TcSetField("TRBTMP","SLLPATCTDB","N",aTamVlr[1],aTamVlr[2])
		TcSetField("TRBTMP","SLLPATCTCR","N",aTamVlr[1],aTamVlr[2])
	Endif
Endif
RestArea(aAreaQry)

Return



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GetRngFil ºAutor  ³Renato F. Campos    º Data ³  08/25/08   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Retorna a expressão correta                                º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function xGetRngFil( xSelFil , cAlias, lTmpFil, cTmpFil, nLimTmp )
Local cRetorno 		:= ""
Local aArea			:= GetArea()
Local nX			:= 0
Local aStruct 		:= {}
Local nTamFil 		
Local lGestao		
Local aModoComp 	:= {}
Local lExclusivo 	:= .F.
Local cFilCpy
Local cAtualxFil

Default lTmpFil := .F.
Default nLimTmp := 50

nTamFil 		:= CtbTamSXG("033",2)  //grupo ; tamanho padrao

lGestao		:= Iif( lFWCodFil, ( LEN(CT2->CT2_FILIAL) > 2 ), .F. )	// Indica se usa Gestao Corporativa


If lFWCodFil .And. lGestao
	aAdd(aModoComp, FWModeAccess(cAlias,1) )
	aAdd(aModoComp, FWModeAccess(cAlias,2) )
	aAdd(aModoComp, FWModeAccess(cAlias,3) )
	lExclusivo := Ascan(aModoComp, 'E') > 0
Else
	dbSelectArea(cAlias)
	lExclusivo := !Empty(xFilial(cAlias))
EndIf

If Valtype(xSelFil) == "A"
	If lExclusivo //cAlias em modo exclusivo
		If lTmpFil .And. Len(xSelFil) > nLimTmp //50 //SOMENTE ACIMA DE 50 FILIAIS CRIA ARQUIVO TEMPORARIO NO BANCO
			//cria arquivo temporario no banco de Dados que contera as filiais
			cTmpFil := CriaTrab(,.F.)
			CtbTmpErase(cTmpFil)
			aStruct:= {}
			aAdd(aStruct, { "TMPFIL", "C", nTamFil, 0 } ) 
			MsCreate(cTmpFil,aStruct, "TOPCONN")
			Sleep(1000)
			dbUseArea(.T., "TOPCONN",cTmpFil,cTmpFil/*cAlias*/,.T.,.F.)
			// Cria o indice temporario
			IndRegua(cTmpFil/*cAlias*/,cTmpFil+"A","TMPFIL",,)
			If lFWCodFil .And. lGestao
				cFilCpy := cFilAnt
				//laco para percorrer todas as filiais selecionadas
				For nX := 1 to Len(xSelFil)
					cFilAnt := xSelFil[nX]
					dbSelectArea(cAlias)
					cAtualxFil := xFilial(cAlias)
					dbSelectArea(cTmpFil)
					//popula arquivo temporario no banco
					If !Empty(cAtualxFil) .And. !dbSeek(cAtualxFil)
						RecLock(cTmpFil, .T.)
						(cTmpFil)->TMPFIL := cAtualxFil
						MsUnlock()
					EndIf
				Next nX                      
				//restaura empresa/filial posicionada antes do laco
				cFilAnt := cFilCpy
			Else
				//popula arquivo temporario no banco
				For nX := 1 to Len(xSelFil)
					RecLock(cTmpFil, .T.)
					(cTmpFil)->TMPFIL := xSelFil[nX]
					MsUnlock()
				Next nX                      
			EndIf
			cRetorno := "IN ( SELECT TMPFIL FROM " + cTmpFil + " ) "
		ElseIf Len(xSelFil) > 1
			If lFWCodFil .And. lGestao
				cFilCpy := cFilAnt
				For nX := 1 to Len(xSelFil)
					cFilAnt := xSelFil[nX]
					dbSelectArea(cAlias)
					cAtualxFil := xFilial(cAlias)
					cRetorno += cAtualxFil + "\" 	
				Next nX                      
				cRetorno := Left(cRetorno, Len(cRetorno) - 1 )
				cRetorno := "IN " + FormatIn(cRetorno,"\") + " "
				cFilAnt := cFilCpy
			Else
				For nX := 1 to Len(xSelFil)
					cRetorno += xSelFil[nX] + "\" 	
				Next nX                      
				cRetorno := Left(cRetorno, Len(cRetorno) - 1 )
				cRetorno := "IN " + FormatIn(cRetorno,"\") + " "
			EndIf
		Else
			If lFWCodFil .And. lGestao
				cFilCpy := cFilAnt
				If Len(xSelFil) > 0
					cFilAnt := xSelFil[1]
				EndIf
				dbSelectArea(cAlias)
				cAtualxFil := xFilial(cAlias)
				cRetorno := " = '" + cAtualxFil + "' " 				
				cFilAnt := cFilCpy
			Else
				If Len(xSelFil) > 0
					cRetorno := " = '" + xSelFil[1] + "' " 	
				Else
					cRetorno := " = '" + xFilial(cAlias) + "' " 	
				EndIf
			EndIf
		EndIf
	Else
		//cAlias em modo compartilhado	
		dbSelectArea(cAlias)
		cRetorno := " = '" + xFilial(cAlias) + "' " 	
	EndIf
	
Else
	cRetorno := " = '" + xFilial(cAlias,xSelFil) + "' "
EndIf          

RestArea(aArea)

	
RETURN cRetorno




Static function PrepTemporaria(aSelFil)
Local	cquery := "DELETE FROM " + RetSqlName('SZ8') + " WHERE Z8_USER = '" + cUserName + "' "
Local nIndx := 1
TCSQLExec(cQuery)


DbSelectArea("CT1")
DbSetOrder(1)


For nIndx := 1 to Len(aSelFil)
	CT1->(DbGotop())
	
	While ( CT1->(!Eof()) )
		
		Reclock('SZ8',.T.)
		SZ8->Z8_CONTA  := CT1->CT1_CONTA
		SZ8->Z8_FILAL  := aSelFil[nIndx] 
		SZ8->Z8_FILIAL := Fwxfilial('SZ8') 
		SZ8->Z8_USER   := cUserName
		MsUnLock()
		 
		CT1->(DbSkip())
	End
Next
 
 
return 


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³xCtContaSup ³Autor  ³ Simone Mie Sato       ³ Data ³ 22.08.03 		     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Atualizacao de sinteticas de conta =>relatorios             			 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³CtContaSup()															 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Nenhum                                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                  			 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ lNImpMov = Se imprime entidades sem movimento		               	 ³±±
±±³          ³ cMoeda	= Moeda                              	              		 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function xCtContaSup(aMyFilial, oMeter,oText,oDlg,lNImpMov,cMoeda,cMoedaDsc)							
		
Local aSaveArea	:= GetArea()				
Local cContaSup	:= ""
Local cDesc		:= ""
Local nSaldoAnt	:= 0
Local nSaldoAtu	:= 0
Local nSaldoDeb	:= 0
Local nSaldoCrd	:= 0
Local nMovimento:= 0
Local nSaldoAntD:= 0
Local nSaldoAntC:= 0
Local nSaldoAtuD:= 0
Local nsaldoAtuC:= 0
Local nReg   	:= 0
Local nRegTmp	:= 0
Local nMeter	:= 0
Local lSemestre 	:= FieldPos("SALDOSEM") > 0		// Saldo por semestre
Local lPeriodo0		:= FieldPos("SALDOPER") > 0		// Saldo dois periodos anteriores
Local cNatCta	:= "" 
Local nInd := 0

DEFAULT cMoedaDsc	:= '01'

nSaldoAnt	:= SALDOANT
nSaldoAtu	:= SALDOATU
nSaldoDeb	:= SALDODEB
nSaldoCrd	:= SALDOCRD
nMovimento	:= MOVIMENTO			
		
nSaldoAtuD	:= SALDOATUDB
nSaldoAtuC	:= SALDOATUCR


For nInd := 1 to Len(aMyFilial)

// Grava sinteticas
dbSelectArea("cArqTmp")	
dbGoTop()  
If ValType(oMeter) == "O"
	oMeter:SetTotal(cArqTmp->(RecCount()))
	oMeter:Set(0)
EndIf


While !Eof()

	If AllTrim(cArqTmp->FILIAL) == AllTrim(aMyFilial[nInd])
	
		//Log99 ( "DEBUG",         " (loop pai)   filial: " + carqtmp->FILIAL +    "conta: " + carqtmp->conta + " " + cArqTmp->TIPOCONTA + " "  + carqtmp->superior + " " + carqtmp->desccta + " -> " + STR(carqtmp->saldoantdb) + " " + STR(carqtmp->saldoantcr) + " " + STR(carqtmp->saldodeb) )
		
		If cArqTmp->TIPOCONTA == "1"
			dbSkip()
		//	Log99("DEBUG","Skip <---")
			Loop
		EndIf
		
		nRegTmp	:= Recno()
		nSaldoAnt	:= SALDOANT
		nSaldoAtu	:= SALDOATU
		nSaldoDeb	:= SALDODEB
		nSaldoCrd	:= SALDOCRD
		nMovimento	:= MOVIMENTO					
		nSaldoAtuD	:= SALDOATUDB
		nSaldoAtuC	:= SALDOATUCR
	
		dbSelectArea("CT1")
		dbSetOrder(1)
			
		cContaSup := cArqTmp->SUPERIOR
		
	//	Log99("DEBUG","cArqTmp->SUPERIOR: " + cContaSup + " nRegTmp: " + STR(nRegTmp))
		
		If Empty(cContaSup)
			dbSelectArea("cArqTmp")
			Replace NIVEL1 With .T.
			dbSelectArea("CT1")
		EndIf		
		MsSeek(xFilial()+cContaSup)
nVamp := 0
			
		While !Eof() .And. CT1->CT1_FILIAL == xFilial()
				/*
	nVamp += 1			
			
			Log99("DEBUG"," "  )
			Log99("DEBUG"," "  )
			Log99("DEBUG","loop interno...   nVamp = " + STR(nVamp ) +   " nVaiSoma = " + STR(nVaiSoma)  )
			
		    Log99 ( "DEBUG",         " loop interno filial: " + carqtmp->FILIAL +    "conta: " + carqtmp->conta + " " + cArqTmp->TIPOCONTA + " "  + carqtmp->superior + " " + carqtmp->desccta + " -> " + STR(carqtmp->saldoantdb) + " " + STR(carqtmp->saldoantcr) + " " + STR(carqtmp->saldodeb) )
		*/
			If Empty(cMoedaDsc)
				cDesc := &("CT1->CT1_DESC"+cMoeda)
			Else
				cDesc := &("CT1->CT1_DESC"+cMoedaDsc)
			EndIf
			
			If Empty(cDesc)		// Caso nao preencher descricao da moeda selecionada
				cDesc := CT1->CT1_DESC01
			Endif
	
	   		dbSelectArea("cArqTmp")
			dbSetOrder(1)
	
			If cArqTmp->( FieldPos( "NATCTA" ) ) > 0
				cNatCta := cArqTmp->NATCTA
			EndIf
				
				
		//	Log99("DEBUG","loop interno... SEEK na: " + cContaSup)
			If !MsSeek(cArqTmp->FILIAL + cContaSup)
				dbAppend()
			
			    
			
			    Replace FILIAL      with aMyFilial[nInd]
				Replace CONTA		With cContaSup
				Replace SUPERIOR	With CT1->CT1_CTASUP
				Replace DESCCTA		With cDesc
				Replace TIPOCONTA	With CT1->CT1_CLASSE
				Replace CTARES    	With CT1->CT1_RES
				Replace NORMAL   	With CT1->CT1_NORMAL
				Replace GRUPO		With CT1->CT1_GRUPO
				If cArqTmp->( FieldPos( "NATCTA" ) ) > 0			
					Replace NATCTA		With cNatCta
				EndIf
				
	//			Log99("DEBUG","loop interno... inseri a linha >>> Filial " +  carqtmp->FILIAL +    "conta: " + carqtmp->conta + " " + cArqTmp->TIPOCONTA + " "  + carqtmp->superior)
			
			EndIf    
	
			Replace	SALDOANT 	With SALDOANT 	+ nSaldoAnt
			Replace SALDOANTDB  With SALDOANTDB + nSaldoAntD
			Replace SALDOANTCR	With SALDOANTCR + nSaldoAntC
			Replace SALDOATU 	With SALDOATU 	+ nSaldoAtu
			Replace SALDOATUDB	With SALDOATUDB	+ nSaldoAtuD
			Replace SALDOATUCR	With SALDOATUCR + nsaldoAtuC
			Replace SALDODEB 	With SALDODEB 	+ nSaldoDeb
			Replace SALDOCRD 	With SALDOCRD 	+ nSaldoCrd
	
			If !lNImpMov
				Replace MOVIMENTO With MOVIMENTO + nMovimento
			Endif
	
			If lSemestre		// Saldo por semestre
				Replace SALDOSEM With SALDOSEM 	+ nSaldoSEM
			Endif
	
	   		If lPeriodo0		// Saldo dois periodos anteriores
				Replace SALDOPER With SALDOPER 	+ nSaldoSEM
			Endif
			
			dbSelectArea("CT1")
			cContaSup := CT1->CT1_CTASUP
			If Empty(CT1->CT1_CTASUP)
				dbSelectArea("cArqTmp")
				Replace NIVEL1 With .T.
				dbSelectArea("CT1")
				Exit
			EndIf		
			MsSeek(xFilial()+cContaSup)
		EndDo
		/*
		Log99("DEBUG","sai do loop interno... ")
			
			
		Log99("DEBUG","loop interno... volta no " + " nRegTmp: " + STR(nRegTmp))
		
		nVaiSoma += 1
	
	*/	
		dbSelectArea("cArqTmp")
		dbGoto(nRegTmp)
		
		
	ENdIf
	
	dbSkip()
	nMeter++
	If nMeter%1000 = 0
		If ValType(oMeter) == "O"	
	   		oMeter:Set(nMeter)						
	  	EndIF
  	EndIf
  	
EndDo


Next 
	
RestArea(aSaveArea)



Return




//****************************************************************
//*			VALIDACOES DA DATA
//*			COMUM A CTBA105 E CTBA050
//****************************************************************
/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³EntidadeCTB³ Autor ³ Pilar S Albaladejo    ³ Data ³ 15.12.99 		     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Imprime a Entidade Contabil                                 			 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³EntidadeCTB(cEntidade,nLinha,nColuna,nTam,lPosiciona,cMascara,         ³±±
±±³          ³cSeparador,cAlias,nOrder,lGraf,oPrint)CtbDtComp(nOpc,dData,cMoeda)     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³.T.   .                                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                  			 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo da Entidade               	                 		 ³±±
±±³          ³ ExpN1 = Numero da Linha                                   		     ³±±
±±³          ³ ExpN2 = Numero da Coluna                                  		     ³±±
±±³          ³ ExpN3 = Tamanho                                           		     ³±±
±±³          ³ ExpL1 = Se precisa procurar no arquivo de cadastro        		     ³±±
±±³          ³ ExpC2 = Codigo da Mascara                                 		     ³±±
±±³          ³ ExpC3 = separador                                         		     ³±±
±±³          ³ ExpC4 = Alias                                             		     ³±±
±±³          ³ ExpN4 = Ordem                                             		     ³±±
±±³          ³ ExpL2 = Se eh relatorio grafico										 ³±±
±±³          ³ ExpO1 = Objeto oPrint                                     		     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function XEntidadeCTB(cFilTemporario, cEntidade,nLinha,nColuna,nTam,lPosiciona,cMascara,cSeparador,cAlias,nOrder,lGraf,oPrint,lSay)

Local aSaveArea := GetArea()
Local aTamEntid
Local cEntEmp	:= ""

DEFAULT lSay := .T.

If cAlias == "CT1"
	aTamEntid := TamSx3("CT1_CONTA")
	If lPosiciona
		dbSelectArea("CT1")
		dbSetOrder(nOrder)
		MsSeek(xFilial()+cEntidade)
	EndIf
ElseIf cAlias == "CTT"
	aTamEntid := TamSX3("CTT_CUSTO")
	If lPosiciona
		dbSelectArea("CTT")
		dbSetOrder(nOrder)
		MsSeek(xFilial()+cEntidade)
	EndIf
ElseIf cAlias == "CTD"
	aTamEntid := TamSX3("CTD_ITEM")
	If lPosiciona
		dbSelectArea("CT1")
		dbSetOrder(nOrder)
		MsSeek(xFilial()+cEntidade)
	EndIf
ElseIf cAlias == "CTH"
	aTamEntid := TamSX3("CTH_CLVL")
	If lPosiciona
		dbSelectArea("CTH")
		dbSetOrder(1)
		MsSeek(xFilial()+cEntidade)
	EndIf
EndIf		
	
If lSay
	If lGraf
		If lCncFIlial
			cEntEmp := Alltrim(cFilTemporario) + " " + xMascaraCTB(cEntidade,cMascara,nTam,cSeparador,cAlias)
		Else
			cEntEmp := xMascaraCTB(cEntidade,cMascara,nTam,cSeparador,cAlias)
		EndIf
		
		oPrint:Say(nLinha,nColuna,cEntEmp,oFont08 )	
	Else
		If lCncFIlial
			@ nLinha, nColuna pSay  Alltrim(cFilTemporario) + " " + xMascaraCTB(cEntidade,cMascara,nTam,cSeparador,cAlias)
		Else
			@ nLinha, nColuna pSay  xMascaraCTB(cEntidade,cMascara,nTam,cSeparador,cAlias)
		EndIf
		
	Endif
Else
	RestArea(aSaveArea)	
	If lCncFIlial
		Return( Alltrim(cFilTemporario) + " " + xMascaraCTB(cEntidade,cMascara,nTam,cSeparador,cAlias) )
	Else
		Return( xMascaraCTB(cEntidade,cMascara,nTam,cSeparador,cAlias) )
	EndIf
EndIf

RestArea(aSaveArea)

Return .T.


/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³MascaraCTB ³ Autor ³ Pilar S Albaladejo    ³ Data ³ 15.12.99 		     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³Retorna a entidade com a mascara                            			 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³MascaraCTB(Codigo,cMascara,nTamanho,cSeparador)                        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³cCodigo                                                                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                  			 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo da Entidade                	                 		 ³±±
±±³          ³ ExpC2 = Mascara                           	                 		 ³±±
±±³          ³ ExpN1 = Tamanho                           	                 		 ³±±
±±³          ³ ExpC3 = Separador                         	                 		 ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
static Function xMascaraCTB(cCodigo,cMascara,nTamanho,cSeparador,cAlias)

Local cCodLido := AllTrim ( cCodigo )
Local cCaracter:= ""
Local cPosicao	:= ""
Local cCodMasc	:= ""
Local nTamPos	:= 0
Local nTam		:= 0
Local nCont		:= 0
Local nNivel	:= 0
Local nPosicao := 0

If !Empty(cMascara) .And. !Empty(cSeparador)
	nTamanho 	:= IIF( nTamanho == NIL,;
					 Len ( cCodigo ) + IIF(Len ( cMascara ) == 0, 0, Len ( cMascara )- 1), ;
					 nTamanho)

	cCodigo			:= AllTrim(cCodigo)	
	If (Len(cSeparador)+Len(cCodigo)) > nTamanho
		nTam 			:= (Len(cSeparador)+Len(cCodigo)) - nTamanho
		cSeparador 	:= Substr(cSeparador,1,(Len(cSeparador)-nTam))
	EndIf

	For nNivel = 1 to Len ( cMascara ) Step 2
		nPosicao += Val ( Substr ( cMascara, nNivel, 2 ) ) + 1
		nCont++
		cCaracter := Substr(cSeparador,nCont,1)
		If ( nPosicao <= Len ( cCodigo ) )
			cCodigo := Stuff ( cCodigo, nPosicao, 0, cCaracter)
		End
	Next
Else
	// Manter compatibilidade com versao anterior do fonte.
	cCodigo		:= AllTrim ( cCodigo )
	If (cMascara == Nil .And. cAlias != Nil)
		If cAlias == "CT1"
			cMascara := GetMv("MV_MASCARA")
		ElseIf cAlias == "CTT"
			cMascara := GetMv("MV_MASCCUS")
		EndIf		
	EndIf
	cMascara 	:= Iif(cMascara == NIL,GetMV("MV_MASCARA"),cMascara)
	cSeparador  := Iif(cSeparador == Nil .Or. Empty(cSeparador),Repl(".", Len(cMascara) - 1),cSeparador)
	nTamanho 	:= IIF( nTamanho == NIL,;
					 Len ( cCodigo ) + IIF(Len ( cMascara ) == 0, 0, Len ( cMascara )- 1), ;
					 nTamanho)
                        
	If !Empty(cMascara) .And. !Empty(cCodigo)
	    	    // For nNivel := IIF(cMascara >= "10",Len(cCodLido),1) to Len(cCodLido)
	    For nNivel := 1 to Len(cCodLido)
	    		cPosicao := Substr(cMascara,nNivel,1)
			
			If 65 <= ASC(cPosicao) .And. ASC(cPosicao) <= 90
			   nTamPos := ASC(cPosicao)-55	
			ElseIf 97 <= ASC(cPosicao) .And. ASC(cPosicao) <= 122
			   nTamPos := ASC(cPosicao)-81
			Else 
			   nTamPos := Val(cPosicao)    
			EndIf
			
			cCodMasc += Left(cCodLido,nTamPos)
			cCodLido := Substr(cCodLido,nTamPos+1)
			If ! Empty(cCodLido)
				cCodMasc += Substr(cSeparador,nNivel,1)
			Endif
		Next
	    cCodigo := cCodMasc + cCodLido
	EndIf
EndIf

cCodigo := PadR ( cCodigo, nTamanho )

Return ( cCodigo )
