#Include "Ctbr040.Ch"
#Include "PROTHEUS.Ch"       

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



/*/{Protheus.doc} ZCTBR040
Customização sobre relatorio padrão incluindo campo FILIAL
@author Augusto Ribeiro | www.compila.com.br
@since 30/08/2017
@version undefined
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ Ctbr040	³ Autor ³ Pilar S Albaladejo	³ Data ³ 12.09.00 ³±±
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
USER FUNCTION ZCTBR040()
Private titulo		:= ""
Private nomeprog	:= "ZCTBR040" 

cTpValor := Alltrim(GetMV("MV_TPVALOR"))    

//cTpValor := GetMV("MV_TPVALOR")
//cTpValor := alltrim(cTpValor)

ZCTBR040R4()

//Limpa os arquivos temporários 
CTBGerClean()

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o	 ³ CTBR040R4 ³ Autor³ Daniel Sakavicius		³ Data ³ 01/08/06 ³±±
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
Static Function ZCTBR040R4(wnRel)
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
Local CREPORT		:= "ZCTBR040"
Local CTITULO		:= STR0006				   			// "Emissao do Relat. Conf. Dig. "
Local CDESC			:= OemToAnsi(STR0001)+OemToAnsi(STR0002)+OemToAnsi(STR0003)			// "Este programa ira imprimir o Relatorio para Conferencia"
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
If ! ct040Valid( mv_par06 )
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
oSection1  := TRSection():New( oReport, STR0027, {"cArqTmp","CT1"},, .F., .F.,,,,,,,,,0 ) //"Plano de contas"

TRCell():New( oSection1, "FILIAL"	,,'EMP-FIL'/*Titulo*/	,/*Picture*/, 12 /*Tamanho*/, /*lPixel*/, /*CodeBlock*/, /*"LEFT"*/,,/*"LEFT"*/,,,.F.)

TRCell():New( oSection1, "CONTA"	,,STR0028/*Titulo*/	,/*Picture*/, nTamConta+1 /*Tamanho*/, /*lPixel*/, /*CodeBlock*/, /*"LEFT"*/,,/*"LEFT"*/,,,.F.)
TRCell():New( oSection1, "DESCCTA"  ,,STR0029/*Titulo*/	,/*Picture*/, aTamDesc[1]/*Tamanho*/, /*lPixel*/,/*CodeBlock*/,  /*"LEFT"*/,.T.,/*"LEFT"*/,,,.F.)

TRCell():New( oSection1, "SALDOANT" ,,STR0030/*Titulo*/	,/*Picture*/, TAM_VALOR+2 /*Tamanho*/, /*lPixel*/, /*CodeBlock*/, /*"RIGHT"*/,,"RIGHT",,,.F.)
TRCell():New( oSection1, "SALDODEB" ,,STR0031/*Titulo*/	,/*Picture*/, TAM_VALOR+2 /*Tamanho*/, /*lPixel*/, /*CodeBlock*/, /*"RIGHT"*/,,"RIGHT",,,.F.)
TRCell():New( oSection1, "SALDOCRD" ,,STR0032/*Titulo*/	,/*Picture*/, TAM_VALOR+2 /*Tamanho*/, /*lPixel*/, /*CodeBlock*/, /*"RIGHT"*/,,"RIGHT",,,.F.)
TRCell():New( oSection1, "MOVIMENTO",,STR0033/*Titulo*/	,/*Picture*/, TAM_VALOR+2 /*Tamanho*/, /*lPixel*/, /*CodeBlock*/, /*"RIGHT"*/,,"RIGHT",,,.F.)
TRCell():New( oSection1, "SALDOATU" ,,STR0034/*Titulo*/	,/*Picture*/, TAM_VALOR+2 /*Tamanho*/, /*lPixel*/, /*CodeBlock*/, /*"RIGHT"*/,,"RIGHT",,,.F.)

TRPosition():New( oSection1, "CT1", 1, {|| xFilial( "CT1" ) + cArqTMP->CONTA })

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
If ! ct040Valid( mv_par06 )
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
		cMensagem	:= STR0025	//"Favor preencher os parametros Grupos Receitas/Despesas e "
		cMensagem	+= STR0026	//"Data Sld Ant. Receitas/Desp. "
		MsgAlert(cMensagem,STR0035)	 //"Ignora Sl Ant.Rec/Des"
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

If Upper( AllTrim( oReport:Title() ) ) == Upper( AllTrim( oReport:cRealTitle ) )
	IF mv_par05 == 1
		Titulo:=	OemToAnsi(STR0009)	//"BALANCETE DE VERIFICACAO SINTETICO DE "
	ElseIf mv_par05 == 2
		Titulo:=	OemToAnsi(STR0006)	//"BALANCETE DE VERIFICACAO ANALITICO DE "
	ElseIf mv_par05 == 3
		Titulo:=	OemToAnsi(STR0017)	//"BALANCETE DE VERIFICACAO DE "
	EndIf
	Titulo += 	DTOC(mv_par01) + OemToAnsi(STR0007) + Dtoc(mv_par02) + ;
			OemToAnsi(STR0008) + cDescMoeda + CtbTitSaldo(mv_par10)           
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
	ZCTGerPlan(oMeter, oText, oDlg, @lEnd,@cArqTmp,;
				mv_par01,mv_par02,"CT7","",mv_par03,mv_par04,,,,,,,mv_par08,;
				mv_par10,aSetOfBook,mv_par12,mv_par13,mv_par14,mv_par15,;
				.F.,.F.,mv_par11,,lImpAntLP,dDataLP,nDivide,lVlrZerado,,,,,,,,,,,,,,lImpSint,cFilUser,lRecDesp0,;
				cRecDesp,dDtZeraRD,,,,,,,cMoedaDsc,,aSelFil) 
				
Else
	MsgMeter({|	oMeter, oText, oDlg, lEnd | ;
					ZCTGerPlan(oMeter, oText, oDlg, @lEnd,@cArqTmp,;
					mv_par01,mv_par02,"CT7","",mv_par03,mv_par04,,,,,,,mv_par08,;
					mv_par10,aSetOfBook,mv_par12,mv_par13,mv_par14,mv_par15,;
					.F.,.F.,mv_par11,,lImpAntLP,dDataLP,nDivide,lVlrZerado,,,,,,,,,,,,,,lImpSint,cFilUser,lRecDesp0,;
					cRecDesp,dDtZeraRD,,,,,,,cMoedaDsc,,aSelFil)},;
					OemToAnsi(OemToAnsi(STR0015)),;  //"Criando Arquivo Tempor rio..."
					OemToAnsi(STR0003))  				//"Balancete Verificacao"
EndIf                                                          


nCount := cArqTmp->(RecCount())//treport


cArqTmp->(DbGoTop())
cChave := "FILIAL+CONTA"  //alliar

//IndRegua("cArqTmp",cArqTmp,cChave,,,'STR0017')  //"Selecionando Registros..."
//dbSelectArea('cArqTmp')

//DbClearIndex()

//dbSetIndex(cArqTmp+OrdBagExt())

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
	
	oSection1:Cell("FILIAL"):SetBlock(  {|| cArqTmp->FILIAL } )
	//oSection1:Cell("FILIAL"):SetBlock(  {|| "TESTE01" } )
	
	If lNormal
		oSection1:Cell("CONTA"):SetBlock( {|| zEntidadeCTB(cArqTmp->FILIAL,cArqTmp->CONTA,000,000,045,.F.,cMascara,cSeparador,,,.F.,,.F.,lNormal)} )
	Else
		oSection1:Cell("CONTA"):SetBlock( {|| zEntidadeCTB(cArqTmp->FILIAL,If(cArqTmp->TIPOCONTA == "2",cArqTmp->CTARES,cArqTmp->CONTA),000,000,045,.F.,,cSeparador,cAlias,,.F.,,.F.,lNormal)} )
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
	
		oBrkGrupo := TRBreak():New(oSection1, { || cArqTmp->GRUPO },{|| STR0020+" "+ RTrim( Upper(AllTrim(cGrupo) )) + " )" },,,.T.)	//	" T O T A I S "
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
	oBrkGeral := TRBreak():New(oSection1, { || cArqTmp->(!Eof()) },{|| STR0011 },,,.F.)	//	" T O T A I S "

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

	oSection1:OnPrintLine( {|| 	U_ZCTR040OnPrint( lPula, lQbConta, nMaxLin, @cTipoAnt, @nLinReport, @cGrupoAnt ) } )
           
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
±±ºPrograma  ³CTR040OnPrint ºAutor ³ Gustavo Henrique º Data ³ 07/02/07   º±±
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
User Function ZCTR040OnPrint( lPula, lQbConta, nMaxLin, cTipoAnt, nLinReport )
                                                                        
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



/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³CT040Valid³ Autor ³ Pilar S. Albaladejo   ³ Data ³ 24.07.00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Valida Perguntas                                           ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³Ct040Valid(cSetOfBook)                                      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ .T./.F.                                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Generico                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpC1 = Codigo da Config. Relatorio                        ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

Function Ct040Valid(cSetOfBook)

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
/*/

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





//-------------------------------------------------------------------
/*/{Protheus.doc} CtGerPlan
Gerar Arquivo Temporario para Balancetes. 

@author Alvaro Camillo Neto

@param oMeter       Controle da regua 
@param oText        Controle da regua 
@param oDlg         Janela            
@param lEnd         Controle da regua @param > finalizar
@param cArqTmp      Arquivo temporario            
@param dDataIni     Data Inicial de Processamento 
@param dDataFim     Data Final de Processamento   
@param cAlias       Alias do Arquivo              
@param cIdent       Identificador do arquivo a ser processado
@param cContaIni    Conta Inicial                            
@param cContaFim	 Conta Final                                
@param cCCIni       Centro de Custo Inicial                  
@param cCCFim       Centro de Custo Final                    
@param cItemIni     Item Inicial                             
@param cItemFim     Item Final                               
@param cClvlIni     Classe de Valor Inicial                  
@param cClvlFim     Classe de Valor Final                    
@param cMoeda       Moeda	                                   
@param cSaldos      Tipos de Saldo a serem processados      
@param aSetOfBook   Matriz de configuracao de livros        
@param cSegmento    Indica qual o segmento sera filtrado    
@param cSegIni      Conteudo Inicial do segmento            
@param cSegFim      Conteudo Final do segmento              
@param cFiltSegm    Filtra por Segmento   		             
@param lNImpMov     Se Imprime Entidade sem movimento        
@param lImpConta    Se Imprime Conta                         
@param nGrupo       Grupo                                    
@param cHeader      Identifica qual a Entidade Principal     
@param lImpAntLP    Se imprime lancamentos Lucros e Perdas   
@param dDataLP      Data da ultima Apuracao de Lucros e Perdas       
@param nDivide      Divide valores por (100,1000,1000000)            
@param lVlrZerado   Grava ou nao valores zerados no arq temporario    
@param cFiltroEnt   Entidade Gerencial que servira de filtro dentro   
              		 de outra Entidade Gerencial. Ex.: Centro de Custo 
              		 sendo filtrado por Item Contabil (CTH)            
@param cCodFilEnt   Codigo da Entidade Gerencial utilizada como filtro
@param cSegmentoG   Filtra por Segmento Gerencial (CC/Item ou ClVl)    
@param cSegIniG     Segmento Gerencial Inicial                         
@param cSegFimG     Segmento Gerencial Final                           
@param cFiltSegmG   Segmento Gerencial Contido em                      
@param lUsGaap      Se e Balancete de Conversao de moeda               
@param cMoedConv    Moeda para a qual buscara o criterio de conversao  
              		 no Pl.Contas                                       
@param cConsCrit    Criterio de conversao utilizado: 1@param Diario, 2@param Medio,
              		 3@param Mensal, 4@param Informada, 5@param Plano de Contas           
@param dDataConv    Data de Conversao                                  
@param nTaxaConv    Taxa de Conversao                                  
@param aGeren       Matriz que armazena os compositores do Pl. Ger.    
			       	 para efetuar o filtro de relatorio.                
@param lImpMov      Nao utilizado                                      
@param lImpSint     Se atualiza sinteticas                             
@param cFilUSU      Filtro informado pelo usuario                      
@param lRecDesp0    Se imprime saldo anterior do periodo anterior      
               		zerado                                             
@param cRecDesp     Grupo de receitas e despesas                       
@param dDtZeraRD    Data de zeramento de receitas e despesas           
@param lImp3Ent     Se e Balancete C.Custo / Conta / Item              
@param lImp4Ent     Se e Balancete por CC x Cta x Item x Cl.Valor      
@param lImpEntGer   Se e Balancete de Entidade (C.Custo/Item/Cl.Vlr    
               		por Entid. Gerencial)                              
@param lFiltraCC    Se considera o filtro das perguntas para C.Custo   
@param lFiltraIt    Se considera o filtro das perguntas para Item      
@param lFiltraCV    Se considera o filtro das perguntas para Cl.Valor  
@param cMoedaDsc    Codigo da moeda para descricao das entidades       
@param lMovPeriodo  Se imprime movimento do periodo anterior           
@param aSelFil      Array de filiais                                   
@param dDtCorte     Data de Corte para calculo do saldo anterior       
@param lPlGerSint   Imprime visao gerencial sintetica? Padrao .F.      
@param lConsSaldo   Consolida saldo ? Padrao .F.                       
@param lCompEnt     Consolida saldo entre entidades? Padrao .F.        
@param cArqAux      Arquivo auxiliar permitindo a recursividade        
@param lUsaNmVis    Usa nome da visao gerencial ? Padrao .F.           
@param cNomeVis     Nome da visao gerencial (retorno, passar por ref.) 
@param lCttSint     Indica se imprime ou não C.Custo Sintéticos	       
@param cQuadroCTB   CODIGO DO QUADRO CONTABIL                          
@param aEntidades   Array com as entidades de inicio e fim   	       
        				 Ex. {'Cta Ent. 05 Inicio','Cta. Ent. 05 Final'}  	         
@param cCodEntidade Codigo da Entidade                      	         

   
@version P12
@since   20/02/2014
@return  Nil
@obs	 
/*/
//-------------------------------------------------------------------

Static Function ZCTGerPlan(	oMeter,oText,oDlg,lEnd,cArqtmp,dDataIni,dDataFim,cAlias,cIdent,cContaIni,cContaFim,;
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
Local nTamCt	:= aTamConta[1]

Local cEntid_de		:= ""
Local cEntid_ate	:= ""
Local lEntSint		:= .F.  

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

If lMovPeriodo
	Aadd(aCampos, { "MOVPERANT"		, "N" , 17			, nDecimais }) 	// Saldo Periodo Anterior
EndIf

///// TRATAMENTO PARA ATUALIZAÇÃO DE SALDO BASE
//Se os saldos basicos nao foram atualizados na dig. lancamentos
If !lAtSldBase
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
	If nGrupo == 1
		cChave 	:= "CONTA+GRUPO"		
		aChave	:= {"CONTA","GRUPO"}
		
		//cChave 	:= "FILIAL+CONTA+GRUPO"		
		//aChave	:= {"FILIAL","CONTA","GRUPO"}
	Else									// Indice por Grupo -> Totaliza por grupo	
		//cChave 	:= "CONTA"
		//aChave	:= {"CONTA"}
		
		cChave	:= "FILIAL+CONTA"
		aChave  := {"FILIAL","CONTA"}		
	EndIf	
	
	//Se nao tiver plano gerencial.
	If Empty(aSetOfBook[5])
		/// EXECUTA QUERY RETORNANDO A ESTRUTURA E SALDOS NO ALIAS TRBTMP
		If cFilUsu == ".T."
			cFilUsu := ""
		EndIf
		ZCT7BlnQry(dDataIni,dDataFim,cAlias,cEntidIni,cEntidFim,cMoeda,;
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
				cChave	:= "FILIAL+CONTA"
				aChave  := {"FILIAL","CONTA"}
				//cChave	:= "CONTA"
				//aChave  := {"CONTA"}
			EndIf
		Else
			cChave	:= "FILIAL+CONTA"
			aChave  := {"FILIAL","CONTA"}		
			//cChave	:= "CONTA"
			//aChave  := {"CONTA"}
		EndIF
	EndIf
Endif

If Empty( aCampos )
	ConOut("Erro na criacao da tabela temporaria")
Return .F.
EndIf

//-------------------
//Criação do objeto
//-------------------
__oTempTable := FWTemporaryTable():New(cArqAux)
__oTempTable:SetFields( aCampos )

lCriaInd := .T.
__oTempTable:AddIndex("T1ORD1", aChave)
If !Empty(aSetOfBook[5])				// Indica qual o Plano Gerencial Anexado
	__oTempTable:AddIndex("T1ORD2", {"ORDEM"})
Endif

If Ascan(aCampos,{|x|Upper(Alltrim(x[1])) == "ORDEMPRN"}) > 0
	__oTempTable:AddIndex("T1ORD3", {"ORDEMPRN"})
	If cAlias == "CT7" .OR. cAlias == "CT3"
		__oTempTable:AddIndex("T1ORD4", {"SUPERIOR","CONTA"})
	ElseIf cAlias == "CTU"
		If cIdent == "CTT"
			__oTempTable:AddIndex("T1ORD4", {"CCSUP","CUSTO"})
		ElseIf cIdent == "CTD"
			__oTempTable:AddIndex("T1ORD4", {"ITSUP","ITEM"})
		ElseIf cIdent == "CTH"
			__oTempTable:AddIndex("T1ORD4", {"CLSUP","CLVL"})
		EndIf
	EndIf
EndIf	
//------------------
//Criação da tabela
//------------------
__oTempTable:Create()

cTableNam1 		:= __oTempTable:GetRealName()
	
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
/*
	cArqInd	:= CriaTrab(Nil, .F.)//impressao sem ser treport passa por aqui
	IndRegua(cArqAux,cArqInd,cChave,,,OemToAnsi('STR0001'))  //"Selecionando Registros..."
	
	If !Empty(aSetOfBook[5])				// Indica qual o Plano Gerencial Anexado
		cArqTmp1 := CriaTrab(, .F.)
		IndRegua(cArqAux,cArqTmp1,"ORDEM",,,OemToAnsi('STR0001'))  //"Selecionando Registros..."
	Endif
	*/
	dbSelectArea(cArqAux)
	/*
	DbClearIndex()
	dbSetIndex(cArqInd+OrdBagExt())
	
	If !Empty(aSetOfBook[5])				// Indica qual o Plano Gerencial Anexado
		dbSetIndex(cArqTmp1+OrdBagExt())
	Endif
	*/
Endif

If FunName() <> "CTBR195" .or. (FunName() == "CTBR195" .and. !lImpAntLP)
	//// SE FOR DEFINIÇÃO TOP
	If TcSrvType() != "AS/400" .and. lTemQuery .and. Select("TRBTMP") > 0 	/// E O ALIAS TRBTMP ESTIVER ABERTO (INDICANDO QUE A QUERY FOI EXECUTADA)
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
		
		dbGoTop()						/// POSICIONA NO 1º REGISTRO DO TMP
		While TRBTMP->(!Eof())			/// REPLICA OS DADOS DA QUERY (TRBTMP) PARA P/ O TEMPORARIO EM DISCO
			
			//Se nao considera apuracao de L/P sera verificado na propria query
			dbSelectArea("TRBTMP")
			If !lVlrZerado .And. lImpAntLP
				If TRBTMP->((SALDOANTDB - SLDLPANTDB) - (SALDOANTCR - SLDLPANTCR)) == 0 .And. ;
						TRBTMP->(SALDODEB-MOVLPDEB) == 0 .And. TRBTMP->(SALDOCRD-MOVLPCRD) == 0
					dbSkip()
					Loop
				EndIf
			ElseIf !lVlrZerado
				If TRBTMP->(SALDOANTDB - SALDOANTCR) == 0 .And. TRBTMP->SALDODEB == 0 .And. TRBTMP->SALDOCRD == 0
					dbSkip()
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
							If lCT1EXDTFIM .AND. type( 'TRBTMP->CT1DTEXSF' ) # 'U'
								IF !Empty(TRBTMP->CT1DTEXSF) .And. (dDataIni > TRBTMP->CT1DTEXSF)
									dbSelectArea("TRBTMP")
									dbSkip()
									Loop
								EndIf
							EndIf
						Endif
						
						If cAlias == "CT3" .Or. ( cAlias == "CTU" .And. cIdent == "CTT")  .Or. ( cAlias == "CTI" .And. lImp4Ent)
							If lCTTEXDTFIM .and. type( 'TRBTMP->CTTDTEXSF' ) # 'U'
								If !Empty(TRBTMP->CTTDTEXSF) .And. (dDataIni > TRBTMP->CTTDTEXSF)
									dbSelectArea("TRBTMP")
									dbSkip()
									Loop
								EndIf
							Endif
						EndIf
						
						If cAlias == "CT4" .Or. ( cAlias == "CTU" .And. cIdent == "CTD") .Or. ( cAlias == "CTI" .And. lImp4Ent)
							If lCTDEXDTFIM .AND. type( 'TRBTMP->CTDDTEXSF' ) # 'U'
								IF !Empty(TRBTMP->CTDDTEXSF) .And. (dDataIni > TRBTMP->CTDDTEXSF)
									dbSelectArea("TRBTMP")
									dbSkip()
									Loop
								EndIf
							EndIf
						Endif
						
						If cAlias == "CTI"	.Or. ( cAlias == "CTU" .And. cIdent == "CTH")
							If lCTHEXDTFIM .AND. type( 'TRBTMP->CTHDTEXSF' ) # 'U'
								If !Empty(TRBTMP->CTHDTEXSF) .And. (dDataIni > TRBTMP->CTHDTEXSF)
									dbSelectArea("TRBTMP")
									dbSkip()
									Loop
								Endif
							EndIf
						EndIf
					EndIf
				Else
					If (SALDOANTDB  == 0 .And. SALDOANTCR  == 0 .And. SALDODEB == 0 .And. SALDOCRD == 0)
						If cAlias $ "CT7/CT3/CT4/CTI" .AND. type( 'TRBTMP->CT1DTEXSF' ) # 'U'
							If lCT1EXDTFIM .AND. !Empty(TRBTMP->CT1DTEXSF) .And. (dDataIni > TRBTMP->CT1DTEXSF)
								dbSelectArea("TRBTMP")
								dbSkip()
								Loop
							EndIf
						EndIf
						
						If cAlias == "CT3" .Or. ( cAlias == "CTU" .And. cIdent == "CTT") .Or. ( cAlias == "CTI" .And. lImp4Ent)
							If lCTTEXDTFIM .AND. type( 'TRBTMP->CTTDTEXSF' ) # 'U'
								IF !Empty(TRBTMP->CTTDTEXSF) .And. (dDataIni > TRBTMP->CTTDTEXSF)
									dbSelectArea("TRBTMP")
									dbSkip()
									Loop
								Endif
							EndIf
						EndIf
						
						If cAlias == "CT4" .Or. ( cAlias == "CTU" .And. cIdent == "CTD")  .Or. ( cAlias == "CTI" .And. lImp4Ent)
							If lCTDEXDTFIM .AND. type( 'TRBTMP->CTDDTEXSF' ) # 'U'
								IF !Empty(TRBTMP->CTDDTEXSF) .And. (dDataIni > TRBTMP->CTDDTEXSF)
									dbSelectArea("TRBTMP")
									dbSkip()
									Loop
								EndIf
							Endif
						EndIf
						
						If cAlias == "CTI"	.Or. ( cAlias == "CTU" .And. cIdent == "CTH")
							If lCTHEXDTFIM .AND. type( 'TRBTMP->CTHDTEXSF' ) # 'U'
								IF !Empty(TRBTMP->CTHDTEXSF) .And. (dDataIni > TRBTMP->CTHDTEXSF)
									dbSelectArea("TRBTMP")
									dbSkip()
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
							dbSkip()
							Loop
						EndIf
					Else
						If Substr(cCodigo,nPos,nDigitos) < Alltrim(cSegIni) .Or. ;
								Substr(cCodigo,nPos,nDigitos) > Alltrim(cSegFim)
							dbSkip()
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
								dbSkip()
								Loop
							EndIf
						Else
							If Substr(cCodGer,nPosG,nDigitosG) < Alltrim(cSegIniG) .Or. ;
								Substr(cCodGer,nPosG,nDigitosG) > Alltrim(cSegFimG)
								dbSkip()
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
					If lImpConta .or. cAlias == "CT7"
						If Empty(TRBTMP->DESCCTA) .AND. TRBTMP->(FieldPos( "DESCCTA01" )) > 0 .AND. !Empty(TRBTMP->DESCCTA01)
							(cArqAux)->DESCCTA	:= TRBTMP->DESCCTA01
						EndIf
					EndIf
					
					If cAlias == "CT4"
						If !lImp3Ent
							If cMoeda <> '01' .And. Empty(TRBTMP->DESCITEM)
								(cArqAux)->DESCITEM	:= TRBTMP->DESCIT01
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
					
					(cArqAux)->SALDOANT	:= (cArqAux)->(SALDOANTCR - SALDOANTDB)
					(cArqAux)->SALDOATUDB	:= (cArqAux)->(SALDOANTDB + SALDODEB)
					(cArqAux)->SALDOATUCR	:= (cArqAux)->(SALDOANTCR) + (cArqAux)->(SALDOCRD)
					(cArqAux)->SALDOATU	:= (cArqAux)->(SALDOATUCR - SALDOATUDB)
					(cArqAux)->MOVIMENTO	:= (cArqAux)->(SALDOCRD   - SALDODEB)
				Else
					nSaldoCrt := 0
					
					If lImpAntLP .And. nCampoLP > 0
						IF Type( "(cArqAux)->SLLPATCTDB" ) # "U" .AND.Type( "(cArqAux)->SLLPATCTCR" ) # "U"
							nSaldoCrt := ((cArqAux)->SLLPATCTDB - (cArqAux)->SLLPATCTCR)
						Endif
						
						(cArqAux)->SALDOANTDB	:= (cArqAux)->((SALDOANTDB - SLDLPANTDB) ) + iif( nSaldoCrt > 0 , Abs( nSaldoCrt ) , 0 )
						(cArqAux)->SALDOANTCR	:= (cArqAux)->((SALDOANTCR - SLDLPANTCR) ) + iif( nSaldoCrt < 0 , Abs( nSaldoCrt ) , 0 )
						(cArqAux)->SALDODEB		-= TRBTMP->MOVLPDEB
						(cArqAux)->SALDOCRD		-= TRBTMP->MOVLPCRD
					Else
						IF Type( "(cArqAux)->SLDANTCTDB" ) # "U" .AND.Type( "(cArqAux)->SLDANTCTCR" ) # "U"
							nSaldoCrt := ((cArqAux)->SLDANTCTDB - (cArqAux)->SLDANTCTCR)
						Endif
						
						(cArqAux)->SALDOANTDB	:= (cArqAux)->(SALDOANTDB) + iif( nSaldoCrt > 0 , Abs( nSaldoCrt ) , 0 )
						(cArqAux)->SALDOANTCR	:= (cArqAux)->(SALDOANTCR) + iif( nSaldoCrt < 0 , Abs( nSaldoCrt ) , 0 )
					EndIf
					
					(cArqAux)->SALDOANT	:= (cArqAux)->(SALDOANTCR - SALDOANTDB)
					(cArqAux)->SALDOATUDB	:= (cArqAux)->(SALDOANTDB + SALDODEB)
					(cArqAux)->SALDOATUCR	:= (cArqAux)->(SALDOANTCR + SALDOCRD)
					(cArqAux)->SALDOATU	:= (cArqAux)->(SALDOATUCR - SALDOATUDB)
					(cArqAux)->MOVIMENTO	:= (cArqAux)->(SALDOCRD   - SALDODEB)
					
				Endif
				
				
				//Se imprime saldo anterior do periodo anterior zerado, verificar o saldo atual da data de zeramento.
				If ( lImpConta .Or. cAlias == "CT7") .And. lRecDesp0 .And. Subs(TRBTMP->CONTA,1,1) $ cRecDesp
					
					If cAlias == "CT7" .Or. ( cAlias == "CT3" .And. cHeader == "CT1" )
						aSldRecDes	:= SaldoCT7Fil(TRBTMP->CONTA,dDtZeraRD,cMoeda,cSaldos,'CTBXFUN',.F.,nil,aSelFil,nil,lTodasFil)
					ElseIf cAlias == "CT3" .And. cHeader == "CTT"
						aSldRecDes	:= SaldoCT3Fil(TRBTMP->CONTA,TRBTMP->CUSTO,dDtZeraRD,cMoeda,cSaldos,'CTBXFUN',.F.,Nil,aSelFil,lTodasFil)
					ElseIf cAlias == "CT4" .And. cHeader == "CTD"
						cCusIni		:= ""
						cCusFim		:= Repl("Z",aTamCC[1])
						aSldRecDes	:= SaldTotCT4(TRBTMP->ITEM,TRBTMP->ITEM,cCusIni,cCusFim,TRBTMP->CONTA,TRBTMP->CONTA,dDtZeraRD,cMoeda,cSaldos,aSelFil,,,,,,,,lTodasFil)
					Elseif cAlias == "CTI" .And. cHeader == "CTH"
						cCusIni		:= ""
						cCusFim		:= Repl("Z",aTamCC[1])
						
						cItIni  	:= ""
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
			//Atualizacao de sinteticas para codebase e topconnect
			If lImpSint	//Se atualiza sinteticas
				CtCtEntSup(oMeter,oText,oDlg,cAlias,lNImpMov,cMoeda)
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
					zCtContaSup(oMeter,oText,oDlg,lNImpMov,cMoeda,cMoedaDsc)
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
		If cAlias == "CT7" .OR. cAlias == "CT3"
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
	lImpConta,nPos,nPosG,nDigitos,nDigitosG,cSegmento, cSegmentoG, cSegIni, cSegIniG, cSegFim, cSegFimG,  cFiltSegm, cFiltSegmG, @__oTempTbPLRef)
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



//-------------------------------------------------------------------
/*{Protheus.doc} CtbSXNatCta
Retorna a natureza da conta

@author Alvaro Camillo Neto

@param cConta	  Conta contabil                         
   

@version P12
@since   20/02/2014
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------
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





//-------------------------------------------------------------------
/*{Protheus.doc} CT7BlnQry
Retorna alias TRBTMP com a composição dos saldos Conta 

Redirecionada para a rotina CQ0BlnQry()

@author Alvaro Camillo Neto
   
@version P12
@since   20/02/2014
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------
Static Function ZCT7BlnQry(dDataIni,dDataFim,cAlias,cContaIni,cContaFim,cMoeda,cTpSald,aSetOfBook,lImpMov,lVlrZerado,lImpAntLP,dDataLP,cFilUsu,cMoedaDsc,aSelFil,dDtCorte,lTodasFil,aTmpFil)

	ZCQ0BlnQry(@dDataIni,@dDataFim,@cContaIni,@cContaFim,@cMoeda,@cTpSald,@aSetOfBook,@lImpMov,@lVlrZerado,@lImpAntLP,@dDataLP,@cFilUsu,@cMoedaDsc,@aSelFil,@dDtCorte,@lTodasFil,@aTmpFil)

Return


//-------------------------------------------------------------------
/*{Protheus.doc} CQ0BlnQry
Retorna alias TRBTMP com a composição dos saldos Conta 

@author Alvaro Camillo Neto

@param cConta 	Conta Contábil
@param cCCusto 	Centro de Custo
@param cItem 		Item contábil
@param cClasse 	Classe Contábil
@param cIdent 	Identificador da Tabela
@param dData 		Data do Saldo
@param cMoeda		Moeda                                            
@param cTpSald 	Tipo de Saldo 
@param cTipo   	Tipo de data 1- Data do saldo - 2 - Data de Apuração                       

   
@version P12
@since   20/02/2014
@return  Nil
@obs	 
*/
//-------------------------------------------------------------------
STATIC Function ZCQ0BlnQry(dDataIni,dDataFim,cContaIni,cContaFim,cMoeda,cTpSald,aSetOfBook,lImpMov,lVlrZerado,lImpAntLP,dDataLP,cFilUsu,cMoedaDsc,aSelFil,dDtCorte,lTodasFil,aTmpFil)
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
Local cFilSel	:=  ""

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
	cQryFilMes := " CQ0_FILIAL " + GetRngFil( aSelFil, "CQ0", .T., @cTmpFilMes )
	aAdd(aTmpFil, cTmpFilMes)
	cQryFilDia := " CQ1_FILIAL " + GetRngFil( aSelFil, "CQ1", .T., @cTmpFilDia )
	aAdd(aTmpFil, cTmpFilDia)
	
	
	cFilSel := GetRngFil( aSelFil, "CQ1", .T., @cTmpFilDia )	
Endif

cQuery := " 	SELECT * FROM ( " + CRLF

cQuery += " SELECT  SM0.M0_CODFIL ALLIAR, CT1_CONTA CONTA,CT1_NORMAL NORMAL, CT1_RES CTARES, " + CRLF
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
		//cQuery += " AND "+cQryFilDia + CRLF
		cQuery		+= " AND CQ1.CQ1_FILIAL = SM0.M0_CODFIL " + CRLF //| ALLIAR|
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
		//cQuery += " AND "+cQryFilDia + CRLF
		cQuery		+= " AND CQ1.CQ1_FILIAL = SM0.M0_CODFIL " + CRLF //| ALLIAR|
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
		//cQuery += " AND "+cQryFilDia + CRLF
		cQuery		+= " AND CQ1.CQ1_FILIAL = SM0.M0_CODFIL " + CRLF //| ALLIAR|
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
			//cQuery += " AND "+cQryFilDia + CRLF
			cQuery		+= " AND CQ1.CQ1_FILIAL = SM0.M0_CODFIL " + CRLF //| ALLIAR|
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
			//cQuery += " AND "+cQryFilDia + CRLF
			cQuery		+= " AND CQ1.CQ1_FILIAL = SM0.M0_CODFIL " + CRLF //| ALLIAR|
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
			//cQuery += " AND "+cQryFilDia + CRLF
			cQuery		+= " AND CQ1.CQ1_FILIAL = SM0.M0_CODFIL " + CRLF //| ALLIAR|
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
		//cQuery += " AND "+cQryFilDia + CRLF
		cQuery		+= " AND CQ1.CQ1_FILIAL = SM0.M0_CODFIL " + CRLF //| ALLIAR|
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
		//cQuery += " AND "+cQryFilDia + CRLF
		cQuery		+= " AND CQ1.CQ1_FILIAL = SM0.M0_CODFIL " + CRLF //| ALLIAR|
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
		//cQuery += " AND "+cQryFilDia + CRLF
		cQuery		+= " AND CQ1.CQ1_FILIAL = SM0.M0_CODFIL " + CRLF //| ALLIAR|
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
			//cQuery += " AND "+cQryFilDia + CRLF]
			cQuery		+= " AND CQ1.CQ1_FILIAL = SM0.M0_CODFIL " + CRLF //| ALLIAR|
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
			//cQuery += " AND "+cQryFilDia + CRLF
			cQuery		+= " AND CQ1.CQ1_FILIAL = SM0.M0_CODFIL " + CRLF //| ALLIAR|
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
			//cQuery += " AND "+cQryFilDia + CRLF
			cQuery		+= " AND CQ1.CQ1_FILIAL = SM0.M0_CODFIL " + CRLF //| ALLIAR|
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
cQuery +=                " FROM "+RetSqlName("CQ1")+" CQ1" + CRLF
cQuery +=                " WHERE  "  + CRLF

cQuery +=                " ARQ.CT1_CONTA	= CQ1_CONTA " + CRLF
cQuery +=                " AND CQ1_MOEDA = '"+cMoeda+"' " + CRLF
cQuery +=                " AND CQ1_TPSALD = '"+cTpSald+"' " + CRLF
cQuery +=                " AND CQ1_DATA >= '"+DTOS(dDataIni)+"'  " + CRLF
cQuery +=                " AND CQ1_DATA <= '"+DTOS(dDataFim)+"' " + CRLF
cQuery +=                " AND CQ1.D_E_L_E_T_ = '' " + CRLF
If !lTodasFil
	//cQuery += " AND "+cQryFilDia + CRLF
	cQuery		+= " AND CQ1.CQ1_FILIAL = SM0.M0_CODFIL " + CRLF //| ALLIAR|
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
		//cQuery += " AND "+cQryFilDia + CRLF
		cQuery		+= " AND CQ1.CQ1_FILIAL = SM0.M0_CODFIL " + CRLF //| ALLIAR|
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
	//cQuery += " AND "+cQryFilDia + CRLF
	cQuery		+= " AND CQ1.CQ1_FILIAL = SM0.M0_CODFIL " + CRLF //| ALLIAR|
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
		//cQuery += " AND "+cQryFilDia + CRLF
		cQuery		+= " AND CQ1.CQ1_FILIAL = SM0.M0_CODFIL " + CRLF //| ALLIAR|
	Endif
	
	cQuery +=            " ) " + CRLF
	cQuery += " MOVLPCRD " + CRLF
EndIf

cQuery += " 	FROM "+RetSqlName("CT1")+" ARQ " + CRLF

//| alliar |
cQuery += " 	INNER JOIN SIGAMAT SM0 " + CRLF
IF !EMPTY(cFilSel)
	cQuery += " 		ON M0_CODFIL "+cFilSel + CRLF
ENDIF
//| alliar |

cQuery += " 	WHERE ARQ.CT1_FILIAL = '"+xFilial("CT1")+"' " + CRLF
cQuery += " 	AND ARQ.CT1_CONTA BETWEEN '"+cContaIni+"' AND '"+cContaFim+"' " + CRLF
cQuery += " 	AND ARQ.CT1_CLASSE = '2' "     + CRLF

If !Empty(aSetOfBook[1]) .And. Empty(aSetOfBook[11]) .And. Empty(aSetOfBook[12])   										// SE HOUVER CODIGO DE CONFIGURAÇÃO DE LIVROS
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

MemoWrite(GetTempPath(.T.) + "ZCTBR040.SQL", cQuery)		

//cQuery := ChangeQuery(cQuery)

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
Static Function ZEntidadeCTB(cFilTemporario, cEntidade,nLinha,nColuna,nTam,lPosiciona,cMascara,cSeparador,cAlias,nOrder,lGraf,oPrint,lSay)

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







/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³CtContaSup ³Autor  ³ Simone Mie Sato       ³ Data ³ 22.08.03 		     ³±±
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
Static Function zCtContaSup(oMeter,oText,oDlg,lNImpMov,cMoeda,cMoedaDsc)							
		
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

DEFAULT cMoedaDsc	:= '01'

nSaldoAnt	:= SALDOANT
nSaldoAtu	:= SALDOATU
nSaldoDeb	:= SALDODEB
nSaldoCrd	:= SALDOCRD
nMovimento	:= MOVIMENTO			
		
nSaldoAtuD	:= SALDOATUDB
nSaldoAtuC	:= SALDOATUCR


// Grava sinteticas
dbSelectArea("cArqTmp")	
dbGoTop()  
If ValType(oMeter) == "O"
	oMeter:SetTotal(cArqTmp->(RecCount()))
	oMeter:Set(0)
EndIf

While !Eof()

	If cArqTmp->TIPOCONTA == "1"
		dbSkip()
		Loop
	EndIf
	cFilAll	:= ""
	
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
		
	cContaSup 	:= cArqTmp->SUPERIOR
	cFilAll		:= cArqTmp->FILIAL
	
	If Empty(cContaSup)
		dbSelectArea("cArqTmp")
		Replace NIVEL1 With .T.
		dbSelectArea("CT1")
	EndIf		
	MsSeek(xFilial()+cContaSup)
		
	While !Eof() .And. CT1->CT1_FILIAL == xFilial() .and. cFilAll == cArqTmp->FILIAL

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
			
		If !MsSeek(cFilAll+cContaSup)
			dbAppend()
			Replace FILIAL		With cFilAll //cArqTmp->(FILIAL)
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
	dbSelectArea("cArqTmp")
	dbGoto(nRegTmp)
	dbSkip()
	nMeter++
	If nMeter%1000 = 0
		If ValType(oMeter) == "O"	
	   		oMeter:Set(nMeter)						
	  	EndIF
  	EndIf
EndDo
	
    	
RestArea(aSaveArea)

Return