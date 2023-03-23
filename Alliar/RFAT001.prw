#include "PROTHEUS.CH"
#include "RWMAKE.CH"
#include "MATR968.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"  

#DEFINE PATH_LOGO "\logotipos\"




/*/{Protheus.doc} RFAT001 (MATR968)
Impressao do RPS - Recibo Provisorio de Servicos - referente
ao processo da Nota Fiscal Eletronica de Sao Paulo. 
Impressao grafica - sem integracao com word. 
@author Augusto Ribeiro | www.compila.com.br
@since 08/03/2017
@version undefined
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
//User Function RFATX01(nRecSF2, cFilNf, cNota, cSerie, cFullPath)
User Function RFAT001(nRecSF2, cFilNf, cNota, cSerie, cFullPath)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define Variaveis                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local wnrel
Local tamanho	:= "G"
Local titulo	:= STR0001 //"Impressão RPS"
Local cDesc1	:= STR0002 //"Impressão do Recibo Provisório de Serviços - RPS"
Local cDesc2	:= " "
Local cDesc3	:= " "
Local cTitulo	:= ""
Local cErro		:= ""
Local cSolucao	:= ""

Local lPrinter	:= .T.
Local lOk		:= .F.
Local aSays		:= {}, aButtons := {}, nOpca := 0
Local nDevice		:= IMP_PDF //IMP_SPOOL
//GetRemoteType -1 = Job, Web ou Working Thread (Sem remote); 1 = Ambiente Microsoft Windows ou 2 = Ambiente Linux/Unix.
Local cPathTemp		//:= GetTempPath(GetRemoteType()==1) //"C:\TEMP\"//GetSrvProfString( 'RootPath', '' )+"\" //GetTempPath(.F.) //| Busca temporario do APP Server|
//Local cPathTemp		:= GetTempPath(.T.) //"C:\TEMP\"//GetSrvProfString( 'RootPath', '' )+"\" //GetTempPath(.F.) //| Busca temporario do APP Server|
Local cFileName		:= "RPS_"+DTOS(DATE())+"_"+STRTRAN(TIME(),":","")+".PDF"  //"RPS_"+DTOS(DATE())+"_"+STRTRAN(TIME(),":","")+".PDF"

Local wnrel   := "MATR968"
Local cString := "SF2"
Local lEnd		:= .F.		
Local _cCodEmp, _cCodFil, _cFilNew
Local cFSemaf
Local nHSemaf := 0
Local nI
Local nTrySemaf	:= 10 

Private nomeprog := "MATR968"
Private nLastKey := 0
Private cPerg

Private oPrint
Private lRelAuto 	:= .F.

Private cAnexo		:= ""

Default nRecSF2		:= 0 
Default cFilNf		:= ""
Default cNota		:= ""
Default cSerie		:= ""




IF nRecSF2 > 0 .OR. (!EMPTY(cFilNf) .AND. !EMPTY(cNota) .AND. !EMPTY(cSerie))
 	lRelAuto	:= .T.
 	
 	
	/*------------------------------------------------------ Augusto Ribeiro | 28/08/2017 - 10:17:48 AM
		Adiciona semaforo de Processamento para evitar gerar arquivos com o mesmo nome
		quando processos forem automáticos
	------------------------------------------------------------------------------------------*/
	cFSemaf	:= cFileName
	nI	:= 0
	WHILE nHSemaf <= 0
	 	nI++
	 	IF nI  >= nTrySemaf
	 		CONOUT("### RFAT001 | NÃO FOI POSSIVEL ABRIR O SEMAFORO")
	 		RETURN(cAnexo)
	 	ENDIF
	 	/*--------------------------
	 		Abre Semaforo
	 	---------------------------*/
		nHSemaf	:= U_CPXSEMAF("A", cFSemaf)	
		IF nHSemaf <= 0
			SLEEP(1000)
			
			cFileName	:= "RPS_"+DTOS(DATE())+"_"+STRTRAN(TIME(),":","")+".PDF"
			cFSemaf		:= cFileName
		ENDIF
	ENDDO

	
	
 	/*------------------------------------------------------ Augusto Ribeiro | 06/06/2017 - 9:10:16 PM
 		GetRemoteType -1 = Job, Web ou Working Thread (Sem remote); 1 = Ambiente Microsoft Windows ou 2 = Ambiente Linux/Unix.
 	------------------------------------------------------------------------------------------*/
 	IF GetRemoteType() == -1
 		CONOUT("### RFAT001 | EXECUÇÃO VIA JOB "+DTOC(DDATABASE)+" "+TIME())
 		cPathTemp	:= "\data\temp\"
 	ELSE
 		cPathTemp	:= GetTempPath(.T.)
 	ENDIF
 	
 	DBSELECTAREA("SF2")
 	SF2->(DBSETORDER(1))//|F2_FILIAL+F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA+F2_FORMUL+F2_TIPO|
 	
 	IF nRecSF2 > 0
 		SF2->(DBGOTO(nRecSF2))
 	ELSE
 		IF SF2->(!DBSEEK(cFilNf+cNota+cSerie ))
 			Return
 			
 		ENDIF 
 	ENDIF 


	/*---------------------------------------
		Realiza a TROCA DA FILIAL CORRENTE 
	-----------------------------------------*/
	_cCodEmp 	:= SM0->M0_CODIGO
	_cCodFil	:= SM0->M0_CODFIL
	_cFilNew	:= SF2->F2_FILIAL //| CODIGO DA FILIAL DE DESTINO 
	
	IF _cCodEmp+_cCodFil <> _cCodEmp+_cFilNew
		CFILANT := _cFilNew
		opensm0(_cCodEmp+CFILANT)
	ENDIF
	
ENDIF 


/*--------------------------
	FULLPATH
---------------------------*/
Default cFullPath	:= "\data\temp\"+cFileName  


cString := "SF2"
wnrel   := "MATR968"
cPerg   := "MTR968"

//AjustaSX1()

IF !lRelAuto
	Pergunte(cPerg,.F.)
	
	AADD(aSays,STR0002) //"Impressão do Recibo Provisório de Serviços - RPS"
	
	AADD(aButtons, { 5,.T.,{|| Pergunte(cPerg,.T. ) } } )
	AADD(aButtons, { 1,.T.,{|| nOpca := 1, FechaBatch() }} )
	AADD(aButtons, { 2,.T.,{|| nOpca := 0, FechaBatch() }} )
	
	FormBatch( Titulo, aSays, aButtons,, 160 )
	
	
	If nOpca == 0
		Return
	EndIf

ENDIF



//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Configuracoes para impressao grafica³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nDevice			:= IMP_PDF
lAdjustToLegacy 	:= .T.


lDisabeSetup	:= .F.
lViewPDF		:= .T.	

IF !(lRelAuto)
	oPrint    := FWMSPrinter():New(cFileName			, IMP_PDF	,lAdjustToLegacy ,  , lDisabeSetup	,,,,, .F. ,, lViewPDF,  )
	oPrint:SetPortrait()
	oPrint:setPaperSize(9) 
	oPrint:setDevice(IMP_PDF)
	//oPrint:StartPage()
ELSE
	lDisabeSetup	:= .T.
	lViewPDF		:= .F.
	lServer			:= .T.
	cPathInServer	:= cPathTemp
		
	//oPrint:= FWMSPrinter():New(cFileName, nDevice, , , lDisabeSetup, , , ,, , , lViewPDF,  )
	oPrint:= FWMSPrinter():New(cFileName, nDevice,, cPathInServer, lDisabeSetup,,,, lServer,,, lViewPDF,)
	oPrint:SetPortrait() // ou SetLandscape()
	oPrint:SetPaperSize(9)
	oPrint:setDevice(IMP_PDF)
	oPrint:cPathPDF := cPathTemp
	
	
ENDIF 
				// Papel A4

If nLastKey = 27
	dbClearFilter()
	Return
Endif

IF lRelAuto 
	MV_PAR01  := SF2->F2_EMISSAO
	MV_PAR02  := SF2->F2_EMISSAO
	MV_PAR03  := SF2->F2_CLIENTE
	MV_PAR04  := SF2->F2_CLIENTE
	MV_PAR05  := SF2->F2_DOC
	MV_PAR06  := SF2->F2_DOC
	MV_PAR07  := 1
	MV_PAR08  := 1
ENDIF 

//RptStatus({|lEnd| Mt968Print(@lEnd,wnRel,cString)},Titulo)
IF Mt968Print(@lEnd,wnRel,cString)

	oPrint:EndPage()  // Finaliza a página
	
	IF !lRelAuto
		oPrint:Preview() // Visualiza impressao grafica antes de imprimir
	ELSE
		oPrint:Print()
			
		IF FILE(cPathTemp+cFileName)
			IF ALLTRIM(UPPER(cPathTemp+cFileName)) <>  ALLTRIM(UPPER(cFullPath))
				__CopyFile(cPathTemp+cFileName , cFullPath)
			ENDIF
			
			cAnexo := cFullPath			
		ELSE
			Help(" ",1,"RPSIMP",," Falha na impressao da nota fiscal." ,4,5)
		ENDIF
		
	ENDIF
ELSE
	Help(" ",1,"RPSIMP",," Nenhuma Nota Fiscal encontrada." ,4,5)
ENDIF



IF nRecSF2 > 0 .OR. (!EMPTY(cFilNf) .AND. !EMPTY(cNota) .AND. !EMPTY(cSerie))
	/*---------------------------------------
		Restaura FILIAL  
	-----------------------------------------*/
	IF _cCodEmp+_cCodFil <> _cCodEmp+_cFilNew
		CFILANT := _cCodFil
		opensm0(_cCodEmp+CFILANT)			 			
	ENDIF   
 	
ENDIF 


/*------------------------------------------------------ Augusto Ribeiro | 28/08/2017 - 10:35:02 AM
	Fecha Semaforo
------------------------------------------------------------------------------------------*/
IF nHSemaf > 0
	U_CPXSEMAF("F", cFSemaf, nHSemaf)
ENDIF	
 
 

Return(cAnexo)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Mt968Print³ Autor ³ Mary C. Hergert       ³ Data ³ 03/08/06 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Chamada do Processamento do Relatorio                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MATR968                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function Mt968Print(lEnd,wnRel,cString)
Local lRet			:= .T.
Local aAreaRPS		:= {}
Local aPrintServ	:= {}
Local aPrintObs		:= {}
Local aTMS			:= {}
Local aItensSD2     := {}

Local cServ			:= ""
Local cDescrServ	:= ""
Local cCNPJCli		:= ""
Local cTime			:= ""
Local lNfeServ		:= AllTrim(SuperGetMv("MV_NFESERV",.F.,"1")) == "1"
Local cLogo			:= ""
Local cServPonto	:= ""
Local cObsPonto		:= ""
Local cAliasSF3		:= "SF3"
Local cCli			:= ""
Local cIMCli		:= ""
Local cEndCli		:= ""
Local cBairrCli		:= ""
Local cCepCli		:= ""
Local cMunCli		:= ""
Local cCodMun		:= ""
Local cUFCli		:= ""
Local cEmailCli		:= ""
Local cCampos		:= ""
Local cDescrBar     := SuperGetMv("MV_DESCBAR",.F.,"")
Local cCodServ      := ""
Local cF3_NFISCAL   := ""
Local cF3_SERIE     := ""
Local cF3_SERIEV    := "" //série de visualização
Local cF3_CLIEFOR   := ""
Local cF3_LOJA      := ""
Local cF3_EMISSAO   := ""
Local cKey          := ""
Local cObsRio       := ""
Local cLogAlter     := GetNewPar("MV_LOGRPS","") // caminho+nome do logotipo alternativo  
Local cTotImp       := ""
Local cFontImp      := ""

Local lCampBar      := !Empty(cDescrBar) .And. SB1->(FieldPos(cDescrBar)) > 0
Local lDescrNFE		:= ExistBlock("MTDESCRNFE")
Local lObsNFE		:= ExistBlock("MTOBSNFE")
Local lCliNFE		:= ExistBlock("MTCLINFE")
Local lPEImpRPS		:= ExistBlock("MTIMPRPS")
Local lDescrBar     := GetNewPar("MV_DESCSRV",.F.)
Local lImpRPS		:= .T.

Local nValDed       := 0
Local nTOTAL        := 0
Local nDEDUCAO      := 0
Local nBASEISS      := 0
Local nALIQISS      := 0
Local nVALISS       := 0
Local nDescIncond   := 0
Local nValLiq       := 0
Local nVlContab     := 0
Local nValDesc      := 0
Local nAliqPis      := 0
Local nAliqCof      := 0
Local nAliqCSLL     := 0
Local nAliqIR       := 0
Local nAliqINSS     := 0
Local nValPis       := 0
Local nValCof       := 0
Local nValCSLL      := 0
Local nValIR        := 0
Local nValINSS      := 0
Local cNatureza     := ""
Local cRecIss       := ""
Local cRecCof       := ""
Local cRecPis       := ""
Local cRecIR        := ""
Local cRecCsl       := ""
Local cRecIns		:= ""
Local cTitulo		:= "RECIBO PROVISÓRIO DE SERVIÇOS - RPS" 
Local nCopias		:= mv_par07
Local nLinIni		:= 225
Local nColIni		:= 225
Local nColFim		:= 2175
Local nLinFim		:= 2975
Local nX			:= 1
Local nY			:= 1
Local nLinha		:= 0
Local nCentro		:= nColFim - nColIni
Local cCNPJIntSer	:= ""
Local cCliIntSer	:= ""
Local cMunPreSer	:= ""
Local cNroInsObr	:= ""
Local cValAprTri	:= ""
Local nValCOFINS	:= 0
Local nValIRPF		:= 0
Local nValCred		:= 0

Local oFont10 	:= TFont():New("Courier New",10,10,,.F.,,,,.T.,.F.)	//Normal s/negrito
Local oFont10n	:= TFont():New("Courier New",10,10,,.T.,,,,.T.,.F.)	//Negrito
Local oFont12n	:= TFont():New("Courier New",12,12,,.T.,,,,.T.,.F.)	//Negrito
Local oFont14n	:= TFont():New("Courier New",14,14,,.T.,,,,.T.,.F.)	//Negrito
Local oFont09 	:= TFont():New("Courier New",9,9,,.F.,,,,.T.,.F.)	//Normal s/negrito
Local oFont09n	:= TFont():New("Courier New",9,9,,.T.,,,,.T.,.F.)	//Negrito

Local oFontA08	:= TFont():New("Arial",08,08,,.F.,,,,.T.,.F.)	//Normal s/negrito
Local oFontA08n := TFont():New("Arial",08,08,,.T.,,,,.T.,.F.)	//Negrito
Local oFontA09	:= TFont():New("Arial",09,09,,.F.,,,,.T.,.F.)	//Normal s/negrito
Local oFontA09n := TFont():New("Arial",09,09,,.T.,,,,.T.,.F.)	//Negrito
Local oFontA10	:= TFont():New("Arial",10,10,,.F.,,,,.T.,.F.)	//Normal s/negrito
Local oFontA10n := TFont():New("Arial",10,10,,.T.,,,,.T.,.F.)	//Negrito
Local oFontA11	:= TFont():New("Arial",11,11,,.F.,,,,.T.,.F.)	//Normal s/negrito
Local oFontA11n := TFont():New("Arial",11,11,,.T.,,,,.T.,.F.)	//Negrito
Local oFontA12	:= TFont():New("Arial",12,12,,.F.,,,,.T.,.F.)	//Normal s/negrito
Local oFontA12n := TFont():New("Arial",12,12,,.T.,,,,.T.,.F.)	//Negrito
Local oFontA13	:= TFont():New("Arial",13,13,,.F.,,,,.T.,.F.)	//Normal s/negrito
Local oFontA13n := TFont():New("Arial",13,13,,.T.,,,,.T.,.F.)	//Negrito
Local oFontA14	:= TFont():New("Arial",14,14,,.F.,,,,.T.,.F.)	//Normal s/negrito
Local oFontA14n := TFont():New("Arial",14,14,,.T.,,,,.T.,.F.)	//Negrito
Local oFontA16	:= TFont():New("Arial",16,16,,.F.,,,,.T.,.F.)	//Normal s/negrito
Local oFontA16n := TFont():New("Arial",16,16,,.T.,,,,.T.,.F.)	//Negrito
Local oFontA18	:= TFont():New("Arial",18,18,,.F.,,,,.T.,.F.)	//Normal s/negrito
Local oFontA18n := TFont():New("Arial",18,18,,.T.,,,,.T.,.F.)	//Negrito
Local oFontA20  := TFont():New("Arial",20,20,,.F.,,,,.T.,.F.)	//Normal s/negrito
Local oFontA20n := TFont():New("Arial",20,20,,.T.,,,,.T.,.F.)	//Negrito
Local cSelect   := ""

#IFDEF TOP
	Local cQuery    := ""
#ELSE 
	Local cChave    := ""
	Local cFiltro   := ""
#ENDIF

Private lRecife     := Iif(GetNewPar("MV_ESTADO","xx") == "PE" .And. Upper(Alltrim(SM0->M0_CIDENT)) == "RECIFE",.T.,.F.)
Private lJoinville  := Iif(GetNewPar("MV_ESTADO","xx") == "SC" .And. Upper(Alltrim(SM0->M0_CIDENT)) == "JOINVILLE",.T.,.F.)
Private lSorocaba   := Iif(GetNewPar("MV_ESTADO","xx") == "SP" .And. Upper(Alltrim(SM0->M0_CIDENT)) == "SOROCABA",.T.,.F.)
Private lRioJaneiro := Iif(GetNewPar("MV_ESTADO","xx") == "RJ" .And. Upper(Alltrim(SM0->M0_CIDENT)) == "RIO DE JANEIRO",.T.,.F.)
Private lBhorizonte := Iif(GetNewPar("MV_ESTADO","xx") == "MG" .And. Upper(Alltrim(SM0->M0_CIDENT)) == "BELO HORIZONTE",.T.,.F.)
Private lPaulista   := Iif(GetNewPar("MV_ESTADO","xx") == "SP" .And. Upper(Alltrim(SM0->M0_CIDENT)) == "SAO PAULO",.T.,.F.)

dbSelectArea("SF3")
dbSetOrder(6)

#IFDEF TOP

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Campos que serao adicionados a query somente se existirem na base³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
    cCampos := " ,F3_ISSMAT "

	If lRecife
    	cCampos += " ,F3_CNAE "
	Endif
	/*
	If Empty(cCampos)
		cCampos := "%%"
	Else
		cCampos := "% " + cCampos + " %"
	Endif
	*/
	If TcSrvType()<>"AS/400"

		lQuery		:= .T.
		cAliasSF3	:= GetNextAlias()

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se imprime ou nao os documentos cancelados³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If mv_par08 == 2
			cQuery := "% SF3.F3_DTCANC = '' AND %"
		Else
			cQuery := "%%"
		Endif

		cSelect:= "%"
		cSelect+= "F3_FILIAL,F3_ENTRADA,F3_EMISSAO,F3_NFISCAL,F3_SERIE," 
		cSelect+= "" + "F3_CLIEFOR,F3_PDV,"
		cSelect+= "F3_LOJA,F3_ALIQICM,F3_BASEICM,F3_VALCONT,F3_TIPO,F3_VALICM,F3_ISSSUB,F3_ESPECIE,"
		cSelect+= "F3_DTCANC,F3_CODISS,F3_OBSERV,F3_NFELETR,F3_EMINFE,F3_CODNFE,F3_CREDNFE, F3_ISENICM "+cCampos
		cSelect+= "%"

		BeginSql Alias cAliasSF3
			COLUMN F3_ENTRADA AS DATE
			COLUMN F3_EMISSAO AS DATE
			COLUMN F3_DTCANC AS DATE
			COLUMN F3_EMINFE AS DATE
			SELECT %Exp:cSelect%

			FROM %table:SF3% SF3

			WHERE SF3.F3_FILIAL = %xFilial:SF3% AND
				SF3.F3_CFO >= '5' AND
				SF3.F3_ENTRADA >= %Exp:mv_par01% AND
				SF3.F3_ENTRADA <= %Exp:mv_par02% AND
				SF3.F3_TIPO = 'S' AND
				SF3.F3_CODISS <> %Exp:Space(TamSX3("F3_CODISS")[1])% AND
				SF3.F3_CLIEFOR >= %Exp:mv_par03% AND
				SF3.F3_CLIEFOR <= %Exp:mv_par04% AND
				SF3.F3_NFISCAL >= %Exp:mv_par05% AND
				SF3.F3_NFISCAL <= %Exp:mv_par06% AND
				%Exp:cQuery%
				SF3.%NotDel%

			ORDER BY SF3.F3_ENTRADA,SF3.F3_SERIE,SF3.F3_NFISCAL,SF3.F3_TIPO,SF3.F3_CLIEFOR,SF3.F3_LOJA
		EndSql

		dbSelectArea(cAliasSF3)
	Else

#ENDIF
		cArqInd := CriaTrab(NIL,.F.)
		cChave  := "DTOS(F3_ENTRADA)+F3_SERIE+F3_NFISCAL+F3_TIPO+F3_CLIEFOR+F3_LOJA+F3_CNAE"
		cFiltro := "F3_FILIAL == '" + xFilial("SF3") + "' .And. "
		cFiltro += "F3_CFO >= '5" + SPACE(LEN(F3_CFO)-1) + "' .And. "
		cFiltro += "DtOs(F3_ENTRADA) >= '" + Dtos(mv_par01) + "' .And. "
		cFiltro += "DtOs(F3_ENTRADA) <= '" + Dtos(mv_par02) + "' .And. "
		cFiltro += "F3_TIPO == 'S' .And. F3_CODISS <> '" + Space(Len(F3_CODISS)) + "' .And. "
		cFiltro += "F3_CLIEFOR >= '" + mv_par03 + "' .And. F3_CLIEFOR <= '" + mv_par04 + "' .And. "
		cFiltro += "F3_NFISCAL >= '" + mv_par05 + "' .And. F3_NFISCAL <= '" + mv_par06 + "'"
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Verifica se imprime ou nao os documentos cancelados³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If mv_par08 == 2
			cFiltro	+= " .And. Empty(F3_DTCANC)"
		Endif

		IndRegua(cAliasSF3,cArqInd,cChave,,cFiltro,STR0006)  //"Selecionando Registros..."
		#IFNDEF TOP
			DbSetIndex(cArqInd+OrdBagExt())
		#ENDIF
		(cAliasSF3)->(dbGotop())
		SetRegua(LastRec())

#IFDEF TOP
	Endif
#ENDIF


IF (cAliasSF3)->(!Eof())

	
	If lSorocaba
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Imprime os RPS gerados de acordo com o numero de copias selecionadas³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		While (cAliasSF3)->(!Eof())
	
			ProcRegua(LastRec())
			If Interrupcao(@lEnd)
				Exit
			Endif
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Busca o SF2 para verificar NF Cupom nao sera processada     ³
			//³e valor da Carga Tributária - Lei 12.741			           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cTotImp := ""
			cFontImp:= ""
	
			SF2->(dbSetOrder(1))
			If SF2->(dbSeek(xFilial("SF2")+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_SERIE+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA))
				If !Empty(SF2->F2_NFCUPOM)
					(cAliasSF3)->(dbSKip())
					Loop
				Endif
	
				//Lei Transparência - 12.741
				cTotImp := Iif(SF2->F2_TOTIMP > 0,"Valor Aproximado dos Tributos: R$ "+Alltrim(Transform(SF2->F2_TOTIMP,"@E 999,999,999,999.99")+"."),"")
	
				//Busca a fonte da Carga Tributária - Lei Transparência - 12.741
				SB1->(dbSetOrder(1))
				SD2->(dbSetOrder(3))
				If SD2->(dbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA))
					If (SB1->(MsSeek(xFilial("SB1")+SD2->D2_COD)))
						cFontImp:= Iif(!Empty(cTotImp) .And. "IBPT" $ AlqLeiTran("SB1","SBZ")[2],"Fonte: "+AlqLeiTran("SB1","SBZ")[2],"")
					EndIf
				EndIf
			Endif
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Ponto de entrada para verificar se esse RPS deve ser impresso ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aAreaRPS := (cAliasSF3)->(GetArea())
			lImpRPS	 := .T.
			If lPEImpRPS
				lImpRPS := Execblock("MTIMPRPS",.F.,.F.,{(cAliasSF3)->F3_NFISCAL,(cAliasSF3)->F3_SERIE,(cAliasSF3)->F3_CLIEFOR,(cAliasSF3)->F3_LOJA})
			Endif
			RestArea(aAreaRPS)
	
			If !lImpRPS
				(cAliasSF3)->(dbSKip())
				Loop
			EndIf
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Busca a descricao do codigo de servicos³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cDescrServ := ""
			dbSelectArea("SX3")
			dbSetOrder(2)
			If dbSeek("BZ_CODISS")
				If Alltrim(SX3->(FIELDGET(FIELDPOS("X3_F3")))) == "60"
					SX5->(dbSetOrder(1))
					If SX5->(dbSeek(xFilial("SX5")+"60"+(cAliasSF3)->F3_CODISS))
						cDescrServ := SX5->(FIELDGET(FIELDPOS("X5_DESCRI")))
					Endif
				ElseIf Alltrim(SX3->(FIELDGET(FIELDPOS("X3_F3")))) == "CCQ"
					dbSelectArea("CCQ")
					CCQ->(dbSetOrder(1))
					If CCQ->(dbSeek(xFilial("CCQ")+(cAliasSF3)->F3_CODISS))
						cDescrServ := CCQ->CCQ_DESC
					Endif
				EndIf
			Else
				SX5->(dbSetOrder(1))
				If SX5->(dbSeek(xFilial("SX5")+"60"+(cAliasSF3)->F3_CODISS))
					cDescrServ := SX5->(FIELDGET(FIELDPOS("X5_DESCRI")))
				Endif
			EndIf
			If lDescrBar
				SF2->(dbSetOrder(1))
				SD2->(dbSetOrder(3))
				SB1->(dbSetOrder(1))
				If SF2->(dbSeek(xFilial("SF2")+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_SERIE+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA))
					If SD2->(dbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA))
						If (SB1->(MsSeek(xFilial("SB1")+SD2->D2_COD)))
							cDescrServ := If (lCampBar,SB1->(AllTrim(&cDescrBar)),cDescrServ)
						Endif
					Endif
				Endif
			Endif
	
			If !Empty(cCodServ)
				cCodServ += " / "
			EndIf
	
			cCodServ += Alltrim((cAliasSF3)->F3_CODISS) + " - " + alltrim(cDescrServ)
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Busca o pedido para discriminar os servicos prestados no documento³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cServ := ""
			If lNfeServ
				SC6->(dbSetOrder(4))
				SC5->(dbSetOrder(1))
				If SC6->(dbSeek(xFilial("SC6")+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_SERIE))
					dbSelectArea("SX5")
					SX5->(dbSetOrder(1))
					If SC5->(dbSeek(xFilial("SC5")+SC6->C6_NUM)) .And. dbSeek(xFilial("SX5")+"60"+PadR(AllTrim((cAliasSF3)->F3_CODISS),6))
						cServ := AllTrim(SC5->(FIELDGET(FIELDPOS("C5_MENNOTA"))))+CHR(13)+CHR(10)+" | "+AllTrim(SubStr(SX5->(FIELDGET(FIELDPOS("X5_DESCRI"))),1,55))
					Endif
				Endif
			Else
				dbSelectArea("SX5")
				SX5->(dbSetOrder(1))
				If dbSeek(xFilial("SX5")+"60"+PadR(AllTrim((cAliasSF3)->F3_CODISS),6))
					cServ := AllTrim(SubStr(SX5->(FIELDGET(FIELDPOS("X5_DESCRI"))),1,55))
				Endif
			Endif
	
			If Empty(cServ)
				cServ := cCodServ
			Endif
	
			//Lei Transparência
			If !Empty(cTotImp)
				cServ += CHR(13)+CHR(10)+cTotImp+cFontImp
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Ponto de entrada para compor a descricao a ser apresentada³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aAreaRPS	:= (cAliasSF3)->(GetArea())
			cServPonto	:= ""
			If lDescrNFE
				cServPonto := Execblock("MTDESCRNFE",.F.,.F.,{(cAliasSF3)->F3_NFISCAL,(cAliasSF3)->F3_SERIE,(cAliasSF3)->F3_CLIEFOR,(cAliasSF3)->F3_LOJA})
			Endif
			RestArea(aAreaRPS)
			If !(Empty(cServPonto))
				cServ := cServPonto
			Endif
			aPrintServ	:= M968Discri(cServ,10,1400)		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica o Cliente/Fornecedor do documento³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cCNPJCli := ""
			SA1->(dbSetOrder(1))
			If SA1->(dbSeek(xFilial("SA1")+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA))
				If RetPessoa(SA1->A1_CGC) == "F"
					cCNPJCli := Transform(SA1->A1_CGC,"@R 999.999.999-99")
				Else
					cCNPJCli := Transform(SA1->A1_CGC,"@R 99.999.999/9999-99")
				Endif
				cCli		:= SA1->A1_NOME
				cIMCli		:= SA1->A1_INSCRM
				cEndCli		:= SA1->A1_END
				cBairrCli	:= SA1->A1_BAIRRO
				cCepCli		:= SA1->A1_CEP
				cMunCli		:= SA1->A1_MUN
				cCodMun		:= SA1->A1_COD_MUN
				cUFCli		:= SA1->A1_EST
				cEmailCli	:= SA1->A1_EMAIL
			Else
				(cAliasSF3)->(dbSKip())
				Loop
			Endif
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Funcao que retorna o endereco do solicitante quando houver integracao com TMS³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If IntTms()
				aTMS := TMSInfSol((cAliasSF3)->F3_FILIAL,(cAliasSF3)->F3_NFISCAL,(cAliasSF3)->F3_SERIE)
				If Len(aTMS) > 0
					cCli		:= aTMS[04]
					If RetPessoa(Alltrim(aTMS[01])) == "F"
						cCNPJCli := Transform(Alltrim(aTMS[01]),"@R 999.999.999-99")
					Else
						cCNPJCli := Transform(Alltrim(aTMS[01]),"@R 99.999.999/9999-99")
					Endif
					cIMCli		:= aTMS[02]
					cEndCli		:= aTMS[05]
					cBairrCli	:= aTMS[06]
					cCepCli		:= aTMS[09]
					cMunCli		:= aTMS[07]
					cUFCli		:= aTMS[08]
					cEmailCli	:= aTMS[10]
				Endif
			Endif
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Ponto de entrada para trocar o cliente a ser impresso.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lCliNFE
				aMTCliNfe := Execblock("MTCLINFE",.F.,.F.,{(cAliasSF3)->F3_NFISCAL,(cAliasSF3)->F3_SERIE,(cAliasSF3)->F3_CLIEFOR,(cAliasSF3)->F3_LOJA})
				// O ponto de entrada somente e utilizado caso retorne todas as informacoes necessarias
				If Len(aMTCliNfe) >= 12
					cCli		:= aMTCliNfe[01]
					cCNPJCli	:= aMTCliNfe[02]
					If RetPessoa(cCNPJCli) == "F"
						cCNPJCli := Transform(cCNPJCli,"@R 999.999.999-99")
					Else
						cCNPJCli := Transform(cCNPJCli,"@R 99.999.999/9999-99")
					Endif
					cIMCli		:= aMTCliNfe[03]
					cEndCli		:= aMTCliNfe[04]
					cBairrCli	:= aMTCliNfe[05]
					cCepCli		:= aMTCliNfe[06]
					cMunCli		:= aMTCliNfe[07]
					cUFCli		:= aMTCliNfe[08]
					cEmailCli	:= aMTCliNfe[09]
				Endif
			Endif
	
			cF3_NFISCAL := (cAliasSF3)->F3_NFISCAL
			cF3_SERIE   := (cAliasSF3)->F3_SERIE
			cF3_SERIEV  := (cAliasSF3)->&(SerieNfId("SF3",3,"F3_SERIE"))
			cF3_CLIEFOR := (cAliasSF3)->F3_CLIEFOR
			cF3_LOJA    := (cAliasSF3)->F3_LOJA
			cF3_EMISSAO := (cAliasSF3)->F3_EMISSAO
	
			nTOTAL   += (cAliasSF3)->F3_VALCONT
			nDEDUCAO += (cAliasSF3)->F3_ISSSUB + (cAliasSF3)->F3_ISSMAT
			nBASEISS += (cAliasSF3)->F3_BASEICM
			nALIQISS := (cAliasSF3)->F3_ALIQICM
			nVALISS  += (cAliasSF3)->F3_VALICM
	
			cKey := (cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_SERIE+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA
	
			(cAliasSF3)->(dbSkip())
	
			If  cKey <> (cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_SERIE+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA .Or. ((cAliasSF3)->(Eof()))
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Obtendo os Valores de PIS/COFINS/CSLL/IR/INSS da NF de saida                             ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				SF2->(dbSetOrder(1))
				If SF2->(dbSeek(xFilial("SF2")+cKey))
					nValPis  := SF2->F2_VALPIS 
					nValCof  := SF2->F2_VALCOFI
					nValINSS := SF2->F2_VALINSS
					nValIR   := SF2->F2_VALIRRF
					nValCSLL := SF2->F2_VALCSLL
				Endif
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Obtendo as aliquotas de PIS/COFINS/CSLL/IR/INSS atraves da natureza da NF de saida       ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				SE1->(dbSetOrder(2))
				If SE1->(dbSeek(xFilial("SE1")+cF3_CLIEFOR+cF3_LOJA+cF3_SERIE+cF3_NFISCAL))
					While SE1->(!Eof()) .And. SE1->E1_FILIAL+SE1->E1_CLIENTE+SE1->E1_LOJA+SE1->E1_PREFIXO+SE1->E1_NUM == xFilial("SF3")+cF3_CLIEFOR+cF3_LOJA+cF3_SERIE+cF3_NFISCAL
						If SE1->E1_TIPO == MVNOTAFIS
							cNatureza := SE1->E1_NATUREZ
							Exit
						EndIf
						SE1->(dbSKip())
					EndDo
					SED->(dbSetOrder(1))
					If SED->(dbSeek(xFilial("SDE")+cNatureza))
						nAliqPis  := Iif( nValPis  > 0 , Iif( SED->ED_PERCPIS > 0 , SED->ED_PERCPIS , SuperGetMv("MV_TXPIS"  )) , 0 )
						nAliqCof  := Iif( nValCof  > 0 , Iif( SED->ED_PERCCOF > 0 , SED->ED_PERCCOF , SuperGetMv("MV_TXCOFIN")) , 0 )
						nALiqINSS := Iif( nValINSS > 0 , SED->ED_PERCINS , 0 )
						nAliqIR   := Iif( nValIR   > 0 , Iif( SED->ED_PERCIRF > 0 , SED->ED_PERCIRF , SuperGetMV("MV_ALIQIRF")) , 0 )
						nALiqCSLL := Iif( nValCSLL > 0 , Iif( SED->ED_PERCCSL > 0 , SED->ED_PERCCSL , SuperGetMv("MV_TXCSLL" )) , 0 )
					EndIf
				Else
					nAliqPis  := Iif( nValPis  > 0 , SuperGetMv("MV_TXPIS"  ) , 0 )
					nAliqCof  := Iif( nValCof  > 0 , SuperGetMv("MV_TXCOFIN") , 0 )
					nAliqIR   := Iif( nValIR   > 0 , SuperGetMV("MV_ALIQIRF") , 0 )
					nALiqCSLL := Iif( nValCSLL > 0 , SuperGetMv("MV_TXCSLL" ) , 0 )
				EndIf
	
				aItensSD2 := {}
				SD2->(dbSetOrder(3))
				SB1->(dbSetOrder(1))
				If SD2->(dbSeek(xFilial("SD2")+cKey))
					Do While SD2->(!Eof()) .And. SD2->D2_FILIAL+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA == xFilial("SD2")+cKey                      
						SB1->(MsSeek(xFilial("SB1")+SD2->D2_COD))
						aAdd(aItensSD2,{SD2->D2_ITEM,SB1->B1_DESC,SD2->D2_QUANT,SD2->D2_PRCVEN,SD2->D2_TOTAL})  
						SD2->(dbSkip())
					EndDo
				Endif
	
				ASort(aItensSD2,,,{|x,y| x[1]  < y[1] })
	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Relatorio Grafico:                                                                                      ³
				//³* Todas as coordenadas sao em pixels	                                                                   ³
				//³* oPrint:Line - (linha inicial, coluna inicial, linha final, coluna final)Imprime linha nas coordenadas ³
				//³* oPrint:Say(Linha,Coluna,Valor,Picture,Objeto com a fonte escolhida)		                           ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				For nX := 1 to nCopias
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ SESSAO - CABECALHO DO RPS - LOGOTIPO - NUMERO E EMISSAO                                                ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					//oPrint:SayBitmap(0110,0170, GetSrvProfString("Startpath","")+"SOROCABA.BMP" ,2350,1800) // o arquivo com o logo deve estar abaixo do rootpath (mp10\system)
					oPrint:StartPage()
					
					cLogoPrint	:= U_alLogo(cF3_NFISCAL, "RPS_")
					//ALERT(cLogoPrint)
					oPrint:SayBitmap(0110,0170, cLogoPrint ,2350,1800) // o arquivo com o logo deve estar abaixo do rootpath (mp10\system)
					PrintBox( 0080,0080,3350,2330)
					PrintLine(0220,1850,0220,2330)
					PrintLine(0080,1850,0360,1850)
					PrintBox( 0080,0080,3350,2330)
					oPrint:Say(0120,0850,"Prefeitura de Sorocaba",oFontA13n)
					oPrint:Say(0180,0850,"Secretaria de Finanças",oFontA13n)
					oPrint:Say(0250,0500,"RECIBO PROVISÓRIO DE SERVIÇOS - RPS",oFontA16n)
					oPrint:Say(0100,1860,"Número do RPS",oFontA10)
					oPrint:Say(0160,1950,PadC(Alltrim(Alltrim(cF3_NFISCAL) + Iif(!Empty(cF3_SERIEV)," / " + Alltrim(cF3_SERIEV),"")),15),oFontA10n)
					oPrint:Say(0235,1860,"Data de Emissão",oFontA10)
					oPrint:Say(0300,1950,PadC(cF3_EMISSAO,15),oFontA10n)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ SESSAO - PRESTADOR DE SERVICOS                                                                         ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					PrintLine(0360,0080,0360,2330)
					oPrint:Say(0370,0965,"PRESTADOR DE SERVIÇOS",oFontA10n)
					oPrint:Say(0410,0100,"Nome/Razão Social:",oFontA08)
					oPrint:Say(0410,0370,PadR(Alltrim(SM0->M0_NOMECOM),40),oFontA08n)
					oPrint:Say(0455,0100,"CNPJ:",oFontA08)
					oPrint:Say(0455,1640,"Inscrição Mobiliária: ",oFontA08)
					oPrint:Say(0455,0265,PadR(Transform(SM0->M0_CGC,"@R 99.999.999/9999-99"),50),oFontA08n)
					oPrint:Say(0455,1950,PadR(Alltrim(SM0->M0_INSCM),50),oFontA08n)
					oPrint:Say(0505,0100,"Endereço: ",oFontA08)
					oPrint:Say(0505,0265,PadR(Alltrim(SM0->M0_ENDENT),50) + " - Bairro: " + PadR(Alltrim(Alltrim(SM0->M0_BAIRENT) + " - CEP: " + Transform(SM0->M0_CEPENT,"@R 99999-999")),50) ,oFontA08n)
					oPrint:Say(0555,0100,"Município: ",oFontA08)
					oPrint:Say(0555,1050,"UF: ",oFontA08)
					oPrint:Say(0555,0265,PadR(Alltrim(SM0->M0_CIDENT),50),oFontA08n)
					oPrint:Say(0555,1120,PadR(Alltrim(SM0->M0_ESTENT),50),oFontA08n)				
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ SESSAO - TOMADOR DE SERVICOS                                                                           ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					PrintLine(0600,0080,0600,2330)
					oPrint:Say(0610,0990,"TOMADOR DE SERVIÇOS",oFontA10n)
					oPrint:Say(0650,0100,"Nome/Razão Social:",oFontA08)
					oPrint:Say(0650,0370,PadR(Alltrim(cCli),40),oFontA08n)
					oPrint:Say(0695,0100,"CNPJ/CPF:",oFontA08)
					oPrint:Say(0695,0265,PadR(cCNPJCli,50),oFontA08n)
					oPrint:Say(0745,0100,"Endereço: ",oFontA08)
					oPrint:Say(0745,0265,PadR(Alltrim(cEndCli),50) + " - Bairro: " + PadR(Alltrim(Alltrim(cBairrCli) + " - CEP: " + Transform(cCepCli,"@R 99999-999")),50) ,oFontA08n)
					oPrint:Say(0795,0100,"Município: ",oFontA08)
					oPrint:Say(0795,1050,"UF: ",oFontA08)
					oPrint:Say(0795,1250,"E-mail: ",oFontA08)
					oPrint:Say(0795,0265,PadR(Alltrim(cMunCli),50),oFontA08n)
					oPrint:Say(0795,1120,PadR(Alltrim(cUFCli),50),oFontA08n)
					oPrint:Say(0795,1350,PadR(Alltrim(cEmailCli),50),oFontA08n)
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ SESSAO - DESCRIMINACAO DOS SERVICOS                                                                    ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					PrintLine(0845,0080,0845,2330)
					oPrint:Say(0855,0940,"DISCRIMINAÇÃO DOS SERVIÇOS",oFontA10n)
					PrintLine(0905,0080,0905,2330)
					oPrint:Say(0915,0100,"Descrição:",oFontA08)
					nLinha	:= 0950
					For nY := 1 to Len(aPrintServ)
						If nY > 10
							Exit
						Endif
						oPrint:Say(nLinha,0100,Alltrim(aPrintServ[nY]),oFontA08)
						nLinha 	:= nLinha + 39
					Next nY
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ SESSAO - ITENS DO RPS 25 ITEMS POR RPS SEGUNDO O WEB-SERVICES DA NFS-E                                 ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					PrintLine(1335,0080,1335,2330)
					PrintLine(1335,1450,2645,1450)
					PrintLine(1335,1640,2645,1640)
					PrintLine(1335,1950,2645,1950)
					oPrint:Say(1345,0100,"Item",oFontA08)
					oPrint:Say(1345,1470,"Quantidade",oFontA08)
					oPrint:Say(1345,1660,"Valor Unitário",oFontA08)
					oPrint:Say(1345,1970,"Valor Total",oFontA08)
					nLinha	:= 1390
					For nY := 1 to Len(aItensSD2)
						If nY > 25
							Exit
						Endif
						oPrint:Say(nLinha,0100,PadR(aItensSD2[nY][01] + "    " + aItensSD2[nY][02],100),oFontA09)
						oPrint:Say(nLinha,1470,Transform(aItensSD2[nY][03], PesqPict("SD2","D2_QUANT" )),oFontA09)
						oPrint:Say(nLinha,1710,Transform(aItensSD2[nY][04], PesqPict("SD2","D2_PRCVEN")),oFontA09)
						oPrint:Say(nLinha,2020,Transform(aItensSD2[nY][05], PesqPict("SD2","D2_TOTAL" )),oFontA09)		
						nLinha 	:= nLinha + 45
					Next nY
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ SESSAO - PIS / COFINS / INSS / IR / CSLL                                                               ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					PrintLine(2645,0080,2645,2330)
					PrintLine(2645,0530,2765,0530)
					PrintLine(2645,0980,2765,0980)
					PrintLine(2645,1430,2765,1430)
					PrintLine(2645,1880,2765,1880)
					oPrint:Say(2665,0210,"PIS("   +Transform(nAliqPis, "@E 99.99") +"%):" ,oFontA09)
					oPrint:Say(2665,0640,"COFINS("+Transform(nAliqCof, "@E 99.99") +"%):" ,oFontA09)
					oPrint:Say(2665,1090,"INSS("  +Transform(nAliqINSS,"@E 99.99") +"%):" ,oFontA09)
					oPrint:Say(2665,1580,"IR("    +Transform(nAliqIR  ,"@E 99.99") +"%):" ,oFontA09)
					oPrint:Say(2665,2000,"CSLL("  +Transform(nAliqCSLL,"@E 99.99") +"%):" ,oFontA09)
	
					oPrint:Say(2710,0230,"R$ " + Transform(nValPis ,PesqPict("SF3","F3_VALICM")),oFontA10n) 
					oPrint:Say(2710,0675,"R$ " + Transform(nValCof ,PesqPict("SF3","F3_VALICM")),oFontA10n) 
					oPrint:Say(2710,1125,"R$ " + Transform(nValINSS,PesqPict("SF3","F3_VALICM")),oFontA10n) 
					oPrint:Say(2710,1575,"R$ " + Transform(nValIR  ,PesqPict("SF3","F3_VALICM")),oFontA10n) 
					oPrint:Say(2710,2020,"R$ " + Transform(nValCSLL,PesqPict("SF3","F3_VALICM")),oFontA10n) 
	
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ SESSAO - VALOR TOTAL DO RPS                                                                            ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					PrintLine(2765,0080,2765,2330)
					oPrint:Say(2795,1050,"VALOR TOTAL DO RPS =",oFontA11n)
					oPrint:Say(2795,2050,"R$ " + Transform(nTOTAL,PesqPict("SF3","F3_VALCONT")),oFontA11n)
	
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ SESSAO - RODAPE - VALOR TODAL DE DEDUCOES - BASE DE CALCULO - ALIQUOTA - VALOR DO ISS                  ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					PrintLine(2855,0080,2855,2330)
					PrintLine(2855,0642,2980,0642)
					PrintLine(2855,1204,2980,1204)
					PrintLine(2855,1766,2980,1766)
	
					oPrint:Say(2865,0100,"VL. Total Deduções:",oFontA09)
					oPrint:Say(2865,0662,"Base de Cálculo:"   ,oFontA09)
					oPrint:Say(2865,1224,"Alíquota:"          ,oFontA09)
					oPrint:Say(2865,1786,"Valor do ISS:"      ,oFontA09)
	
					oPrint:Say(2920,0360,"R$ " + Transform(nDEDUCAO,PesqPict("SF3","F3_BASEICM")),oFontA10n)
					oPrint:Say(2920,0890,"R$ " + Transform(nBASEISS,PesqPict("SF3","F3_BASEICM")),oFontA10n)
					oPrint:Say(2920,1640,Transform(nALIQISS,PesqPict("SF3","F3_ALIQICM"))+"%",oFontA10n)
					oPrint:Say(2920,2020,"R$ " + Transform(nVALISS ,PesqPict("SF3","F3_VALICM" )),oFontA10n)
	
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ SESSAO - INFORMACOES IMPORTANTES                                                                       ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					PrintLine(2980,0080,2980,2330)
					oPrint:Say(2990,0920,"INFORMAÇÕES IMPORTANTES",oFontA10n)
					oPrint:Say(3035,0100,"Este recibo Provisório de Serviços - RPS não é válido como documento fiscal. O prestador do serviço, no prazo de até 5 (cinco) dias da emissão deste RPS, deverá",oFontA08)
					oPrint:Say(3075,0100,"substituí-lo por uma Nota Fiscal de Serviços Eletrônica.",oFontA08)
					oPrint:Say(3170,0100,"* Valores para Alíquota e Valor de ISSQN serão calculados de acordo com o movimento econômico com base na tabela de faixa de faturamento.",oFontA08)
					If nCopias > 1 .And. nX < nCopias
						oPrint:EndPage()
					Endif
				Next nX
				cCodServ := ""
				cServ    := ""
				nTotal   := 0
				nDeducao := 0
				nBaseISS := 0
				nValISS  := 0
			EndIf
			If !((cAliasSF3)->(Eof()))
				oPrint:EndPage()
			Endif
		Enddo
	Else
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Imprime os RPS gerados de acordo com o numero de copias selecionadas³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		While (cAliasSF3)->(!Eof())
			ProcRegua(LastRec())
			If Interrupcao(@lEnd)
				Exit
			Endif
			
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Analisa Deducoes do ISS  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nValDed := (cAliasSF3)->F3_ISSSUB 
			nValDed += (cAliasSF3)->F3_ISSMAT
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Valor contabil ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nVlContab := (cAliasSF3)->F3_VALCONT
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Busca o SF2 para verificar o horario de emissao do documento e Lei da Transparência³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			SF2->(dbSetOrder(1))
			cTime   := ""
			cTotImp := ""
			cFontImp:= ""
	
			If SF2->(dbSeek(xFilial("SF2")+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_SERIE+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA))
				cTime := Transform(SF2->F2_HORA,"@R 99:99")
				//Lei Transparência - 12.741
				cTotImp := Iif( SF2->F2_TOTIMP > 0,"Valor Aproximado dos Tributos: R$ "+Alltrim(Transform(SF2->F2_TOTIMP,"@E 999,999,999,999.99")+"."),"")
				//Busca a fonte da Carga Tributária - Lei Transparência - 12.741
				SB1->(dbSetOrder(1))
				SD2->(dbSetOrder(3))
				If SD2->(dbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA))
					If (SB1->(MsSeek(xFilial("SB1")+SD2->D2_COD)))
						cFontImp:= Iif(!Empty(cTotImp) .And. "IBPT" $ AlqLeiTran("SB1","SBZ")[2],"Fonte: "+AlqLeiTran("SB1","SBZ")[2],"")
					EndIf
				EndIf
				cValAprTri := Iif(SF2->F2_TOTIMP>0, Transform(SF2->F2_TOTIMP,"@E 999,999,999,999.99")+"/"+AlqLeiTran("SB1","SBZ")[2], "")
				// NF Cupom nao sera processada
				If !Empty(SF2->F2_NFCUPOM)
					(cAliasSF3)->(dbSKip())
					Loop
				Endif
			Endif
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Ponto de entrada para verificar se esse RPS deve ser impresso ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aAreaRPS := (cAliasSF3)->(GetArea())
			lImpRPS	 := .T.
			If lPEImpRPS
				lImpRPS := Execblock("MTIMPRPS",.F.,.F.,{(cAliasSF3)->F3_NFISCAL,(cAliasSF3)->F3_SERIE,(cAliasSF3)->F3_CLIEFOR,(cAliasSF3)->F3_LOJA})
			Endif
			RestArea(aAreaRPS)
			If !lImpRPS
				(cAliasSF3)->(dbSKip())
				Loop
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Busca a descricao do codigo de servicos³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cDescrServ := ""
			dbSelectArea("SX3")
			dbSetOrder(2)
			If dbSeek("BZ_CODISS")
				If Alltrim(SX3->(FIELDGET(FIELDPOS("X3_F3")))) == "60"
					SX5->(dbSetOrder(1))
					If SX5->(dbSeek(xFilial("SX5")+"60"+(cAliasSF3)->F3_CODISS))
						cDescrServ := SX5->(FIELDGET(FIELDPOS("X5_DESCRI")))
					Endif
				ElseIf Alltrim(SX3->(FIELDGET(FIELDPOS("X3_F3")))) == "CCQ"
					dbSelectArea("CCQ")
					CCQ->(dbSetOrder(1))
					If CCQ->(dbSeek(xFilial("CCQ")+(cAliasSF3)->F3_CODISS))
						cDescrServ := CCQ->CCQ_DESC
					Endif
				EndIf
			Else
				SX5->(dbSetOrder(1))
				If SX5->(dbSeek(xFilial("SX5")+"60"+(cAliasSF3)->F3_CODISS))
					cDescrServ := SX5->(FIELDGET(FIELDPOS("X5_DESCRI")))
				Endif
			EndIf
			If lDescrBar
				SF2->(dbSetOrder(1))
				SD2->(dbSetOrder(3))
				SB1->(dbSetOrder(1))
				If SF2->(dbSeek(xFilial("SF2")+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_SERIE))
					If SD2->(dbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA))
						If (SB1->(MsSeek(xFilial("SB1")+SD2->D2_COD)))
							cDescrServ := If (lCampBar,SB1->(AllTrim(&cDescrBar)),cDescrServ)
						Endif
					Endif
				Endif
			Endif
			If lRecife
				cCodAtiv := Alltrim((cAliasSF3)->F3_CNAE)
			Else
				cCodServ := Alltrim((cAliasSF3)->F3_CODISS) + " - " + cDescrServ
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Busca o pedido para discriminar os servicos prestados no documento³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cServ := ""
			If lNfeServ
				SC6->(dbSetOrder(4))
				SC5->(dbSetOrder(1))
				If SC6->(dbSeek(xFilial("SC6")+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_SERIE))
					dbSelectArea("SX5")
					SX5->(dbSetOrder(1))
					If SC5->(dbSeek(xFilial("SC5")+SC6->C6_NUM)) .And. dbSeek(xFilial("SX5")+"60"+PadR(AllTrim((cAliasSF3)->F3_CODISS),6))
						cServ := AllTrim(SC5->C5_MENNOTA)+CHR(13)+CHR(10)+" | "+AllTrim(SubStr(SX5->(FIELDGET(FIELDPOS("X5_DESCRI"))),1,55))
						cNroInsObr := SC5->C5_OBRA
					Endif
				Endif
			Else
				dbSelectArea("SX5")
				SX5->(dbSetOrder(1))
				If dbSeek(xFilial("SX5")+"60"+PadR(AllTrim((cAliasSF3)->F3_CODISS),6))
					cServ := AllTrim(SubStr(SX5->(FIELDGET(FIELDPOS("X5_DESCRI"))),1,55))
				Endif
			Endif
			If Empty(cServ)
				cServ := cDescrServ
			Endif
			//Lei Transparência
			If !Empty(cTotImp) .And. !lPaulista
				cServ += CHR(13)+CHR(10)+cTotImp+cFontImp
			EndIf
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Ponto de entrada para compor a descricao a ser apresentada³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aAreaRPS	:= (cAliasSF3)->(GetArea())
			cServPonto	:= ""
			If lDescrNFE
				cServPonto := Execblock("MTDESCRNFE",.F.,.F.,{(cAliasSF3)->F3_NFISCAL,(cAliasSF3)->F3_SERIE,(cAliasSF3)->F3_CLIEFOR,(cAliasSF3)->F3_LOJA})
			Endif
			RestArea(aAreaRPS)
			If !(Empty(cServPonto))
				cServ := cServPonto
			Endif
			aPrintServ	:= Mtr968Mont(cServ,13,999)
			If lRioJaneiro
				cObsRio := ""
				nDescIncond := 0
				SF2->(dbSetOrder(1))
				SD2->(dbSetOrder(3))
				If SF2->(dbSeek(xFilial("SF2")+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_SERIE))
					If SD2->(dbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA))
						SF4->(DbSetOrder(1))
						If SF4->(dbSeek(xFilial("SF4")+SD2->D2_TES))
							If SF2->F2_DESCONT > 0
								If SF4->F4_DESCOND == "1"
									cObsRio := " Deconto Condic. de (R$) "
									cObsRio += Alltrim(Transform(SF2->F2_DESCONT,"@ze 9,999,999,999,999.99"))
								Else
									nDescIncond := SF2->F2_DESCONT
								EndIf
							EndIf
						EndIf
					Endif
				Endif
			Endif
			cObserv := Alltrim((cAliasSF3)->F3_OBSERV) + Iif(!Empty((cAliasSF3)->F3_OBSERV)," | ","")
			cObserv += Iif(!Empty((cAliasSF3)->F3_PDV) .And. Alltrim((cAliasSF3)->F3_ESPECIE) == "CF",STR0042 + " | ","")
			If lRioJaneiro
				cObsRio += "'Obrigatória a conversão em Nota Fiscal de Serviços Eletrônica – NFS-e – NOTA CARIOCA em até vinte dias.'" + " | "
			EndIf
			aAreaRPS := (cAliasSF3)->(GetArea())
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Ponto de entrada para complementar as observacoes a serem apresentadas³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cObsPonto	:= ""
			If lObsNFE
				cObsPonto := Execblock("MTOBSNFE",.F.,.F.,{(cAliasSF3)->F3_NFISCAL,(cAliasSF3)->F3_SERIE,(cAliasSF3)->F3_CLIEFOR,(cAliasSF3)->F3_LOJA})
			Endif
			RestArea(aAreaRPS)
			cObserv 	:= cObserv + cObsPonto
			cObserv 	:= cObserv + cObsRio
			aPrintObs	:= Mtr968Mont(cObserv,11,675)		
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verifica o cLiente/fornecedor do documento³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			cCNPJCli := ""
			cRecIss  := ""
			SA1->(dbSetOrder(1))
			If SA1->(dbSeek(xFilial("SA1")+(cAliasSF3)->F3_CLIEFOR+(cAliasSF3)->F3_LOJA))
				If RetPessoa(SA1->A1_CGC) == "F"
					cCNPJCli := Transform(SA1->A1_CGC,"@R 999.999.999-99")
				Else
					cCNPJCli := Transform(SA1->A1_CGC,"@R 99.999.999/9999-99")
				Endif
				cCli		:= SA1->A1_NOME
				cIMCli		:= SA1->A1_INSCRM
				cEndCli		:= SA1->A1_END
				cBairrCli	:= SA1->A1_BAIRRO
				cCepCli		:= SA1->A1_CEP
				cMunCli		:= SA1->A1_MUN
				cCodMun		:= SA1->A1_COD_MUN
				cUFCli		:= SA1->A1_EST
				cEmailCli	:= SA1->A1_EMAIL
				cRecIss     := SA1->A1_RECISS
				cRecCof     := SA1->A1_RECCOFI
				cRecPis     := SA1->A1_RECPIS
				cRecIR      := SA1->A1_RECIRRF
				cRecCsl     := SA1->A1_RECCSLL
				cRecIns     := SA1->A1_RECINSS
			Else
				(cAliasSF3)->(dbSKip())
				Loop
			Endif
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Funcao que retorna o endereco do solicitante quando houver integracao com TMS³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If IntTms()
				aTMS := TMSInfSol((cAliasSF3)->F3_FILIAL,(cAliasSF3)->F3_NFISCAL,(cAliasSF3)->F3_SERIE)
				If Len(aTMS) > 0
					cCli		:= aTMS[04]
					If RetPessoa(Alltrim(aTMS[01])) == "F"
						cCNPJCli := Transform(Alltrim(aTMS[01]),"@R 999.999.999-99")
					Else
						cCNPJCli := Transform(Alltrim(aTMS[01]),"@R 99.999.999/9999-99")
					Endif
					cIMCli		:= aTMS[02]
					cEndCli		:= aTMS[05]
					cBairrCli	:= aTMS[06]
					cCepCli		:= aTMS[09]
					cMunCli		:= aTMS[07]
					cUFCli		:= aTMS[08]
					cEmailCli	:= aTMS[10]
				Endif
			Endif
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Ponto de entrada para trocar o cliente a ser impresso.³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lCliNFE
				aMTCliNfe := Execblock("MTCLINFE",.F.,.F.,{(cAliasSF3)->F3_NFISCAL,(cAliasSF3)->F3_SERIE,(cAliasSF3)->F3_CLIEFOR,(cAliasSF3)->F3_LOJA})
				// O ponto de entrada somente e utilizado caso retorne todas as informacoes necessarias
				If Len(aMTCliNfe) >= 12
					cCli		:= aMTCliNfe[01]
					cCNPJCli	:= aMTCliNfe[02]
					If RetPessoa(cCNPJCli) == "F"
						cCNPJCli := Transform(cCNPJCli,"@R 999.999.999-99")
					Else
						cCNPJCli := Transform(cCNPJCli,"@R 99.999.999/9999-99")
					Endif
					cIMCli		:= aMTCliNfe[03]
					cEndCli		:= aMTCliNfe[04]
					cBairrCli	:= aMTCliNfe[05]
					cCepCli		:= aMTCliNfe[06]
					cMunCli		:= aMTCliNfe[07]
					cUFCli		:= aMTCliNfe[08]
					cEmailCli	:= aMTCliNfe[09]
				Endif
			Endif
			If lBhorizonte .Or. lPaulista
				nValDed     := 0
				nValDesc    := 0
				nDescIncond := 0
				nValLiq     := 0
				nVALISS     := 0
				nValPis     := 0
				nValCof     := 0
				nValCSLL    := 0
				nValIR      := 0
				nValINSS	:= 0
				SF2->(dbSetOrder(1))
				SD2->(dbSetOrder(3))
				If SF2->(dbSeek(xFilial("SF2")+(cAliasSF3)->F3_NFISCAL+(cAliasSF3)->F3_SERIE))
					If SD2->(dbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA))
						While SD2->(!Eof()) .And. xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA==xFilial("SD2")+SD2->D2_DOC+SD2->D2_SERIE+SD2->D2_CLIENTE+SD2->D2_LOJA
							If Alltrim(SD2->D2_CODISS) == Alltrim((cAliasSF3)->F3_CODISS) 
								SF4->(DbSetOrder(1))		
								If SF4->(dbSeek(xFilial("SF4")+SD2->D2_TES))
									nValLiq  += SD2->D2_TOTAL
									nVALISS  += SD2->D2_VALISS
									nValPis  := SD2->D2_VALPIS
									nValCof  := SD2->D2_VALCOF
									nValCSLL := SD2->D2_VALCSL
									nValIR   := SD2->D2_VALIRRF
									nValINSS := SD2->D2_VALINS
									nValDesc := SD2->D2_DESCON
									If SF4->F4_DESCOND <> "1"
										nDescIncond := nValDesc
									EndIf
									If SF4->F4_AGREG == "D"
										nValDesc += SD2->D2_DESCICM
										nValLiq -= SD2->D2_DESCICM
										//Acrescenta o ISS no valor Contábil, pois o ISS foi deduzido na emissão da NF e
										//para a impressão correta do RPS é necessario soma-lo
										//nVlContab é impresso como valor da mercadoria para Belo Horizonte
										nVlContab := nVlContab + SD2->D2_DESCICM
									Endif
									nValDed += SD2->( D2_ABATISS + D2_ABATMAT )
								EndIf
							Endif
							SD2->(dbSkip())
						Enddo 
					Endif 
				EndIf
				nRetFeder   := 0
				If cRecIss == "1"
					nValLiq := nValLiq - nValISS
				EndIf
				If cRecCof == "S"
					nValLiq    := nValLiq - nValCof
					nRetFeder  := nRetFeder + nValCof
				EndIf
				If cRecPis == "S"
					nValLiq := nValLiq - nValPis
					nRetFeder  := nRetFeder + nValPis
				EndIf
				If cRecCsl == "S"
					nValLiq := nValLiq - nValCsll
					nRetFeder  := nRetFeder + nValCsll
				EndIf
				If cRecIr == "1"
					nValLiq := nValLiq - nValIR
					nRetFeder  := nRetFeder + nValIR
				Endif
				If cRecIns == "S"
					nValLiq := nValLiq - nValINSS
					nRetFeder  := nRetFeder + nValINSS
				EndIf
			Endif
	
			If lJoinville
				SF2->(dbSetOrder(1))
				SB1->(dbSetOrder(1))
				SD2->(dbSetOrder(3))
				If SF2->(dbSeek(xFilial("SF2")+(cAliasSF3)->(F3_NFISCAL+F3_SERIE)))
					If SD2->(dbSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA))
						If (SB1->(MsSeek(xFilial("SB1")+SD2->D2_COD)))
							nValBase	:= Iif (Empty((cAliasSF3)->F3_BASEICM),(cAliasSF3)->F3_ISENICM,(cAliasSF3)->F3_BASEICM)
							nAliquota	:= SB1->B1_ALIQISS
						Endif
					EndIf
				EndIf
			Endif
	
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Relatorio Grafico:                                                                                      ³
			//³* Todas as coordenadas sao em pixels	                                                                   ³
			//³* oPrint:Line - (linha inicial, coluna inicial, linha final, coluna final)Imprime linha nas coordenadas ³
			//³* oPrint:Say(Linha,Coluna,Valor,Picture,Objeto com a fonte escolhida)		                           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			For nX := 1 to nCopias
				
				oPrint:StartPage()
			
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Box no tamanho do RPS³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				oPrint:Line(nLinIni,nColIni,nLinIni,nColFim)
				oPrint:Line(nLinIni,nColIni,nLinFim,nColIni)
				oPrint:Line(nLinIni,nColFim,nLinFim,nColFim)
				oPrint:Line(nLinFim,nColIni,nLinFim,nColFim)
	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Dados da empresa emitente do documento³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				//O arquivo com o logo deve estar abaixo do rootpath (mp8\system)
				If Empty(cLogAlter)
					cLogo := FisxLogo("1")
				Else
					cLogo := cLogAlter
				EndIf
				
				cLogo	:= U_alLogo(SM0->M0_CODFIL,"RPS_")
				//ALERT(cLogo)
	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Título do Documento  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				oPrint:Say(180,nCentro/2-len(cTitulo),cTitulo,oFont14n)
				oPrint:SayBitmap(280,nColIni+10,cLogo,350,350)
				oPrint:Line(nLinIni,1800,612,1800)
				oPrint:Line(354,1800,354,nColFim)
				oPrint:Line(483,1800,483,nColFim)
				oPrint:Line(612,nColIni,612,nColFim)
				
				nLinha	:= 265
				oPrint:Say(nLinha,730,PadC(Alltrim(SM0->M0_NOMECOM),40),oFont12n)
				nLinha += 60
				oPrint:Say(nLinha,680,PadC(Alltrim(SM0->M0_ENDENT),50),oFont10)
				nLinha += 50
				oPrint:Say(nLinha,680,PadC(Alltrim(Alltrim(SM0->M0_BAIRENT) + " - " + Transform(SM0->M0_CEPENT,"@R 99999-999")),50),oFont10)
				nLinha += 50
				oPrint:Say(nLinha,680,PadC(Alltrim(SM0->M0_CIDENT) + " - " + Alltrim(SM0->M0_ESTENT),50),oFont10)
				nLinha += 50
				oPrint:Say(nLinha,680,PadC(Alltrim(STR0013) + Alltrim(SM0->M0_TEL),50),oFont10) // Telefone:
				nLinha += 50
				oPrint:Say(nLinha,680,PadC(Alltrim(STR0014) + Transform(SM0->M0_CGC,"@R 99.999.999/9999-99"),50),oFont10) // C.N.P.J.::
				nLinha += 50
				oPrint:Say(nLinha,680,PadC(Alltrim(STR0015) + Alltrim(SM0->M0_INSCM),50),oFont10) // I.M.:
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Informacoes sobre a emissao do RPS³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nLinha	:= 260
				oPrint:Say(nLinha,1830,PadC(Alltrim(STR0016),15),oFont10n) // "Número/Série RPS"
				nLinha += 45
				oPrint:Say(nLinha,1830,PadC(Alltrim(Alltrim((cAliasSF3)->F3_NFISCAL) + Iif(!Empty((cAliasSF3)->F3_SERIE)," / " + Alltrim((cAliasSF3)->F3_SERIE),"")),15),oFont10)
				nLinha += 85
				oPrint:Say(nLinha,1830,PadC(Alltrim(STR0017),15),oFont10n) // "Data Emissão"
				nLinha += 45
				oPrint:Say(nLinha,1830,PadC((cAliasSF3)->F3_EMISSAO,15),oFont10)
				nLinha += 90
				oPrint:Say(nLinha,1830,PadC(Alltrim(STR0018),15),oFont10n) // "Hora Emissão"
				nLinha += 45
				oPrint:Say(nLinha,1830,PadC(Alltrim(cTime),15),oFont10)
				
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Dados do destinatario³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nLinha	:= 650
				nSalto	:= 50
				oPrint:Say(nLinha,nCentro/2-len("DADOS DO DESTINATÁRIO"),"DADOS DO DESTINATÁRIO",oFont12n) // "DADOS DO DESTINATÁRIO"
				nLinha	+= nSalto+20
				oPrint:Say(nLinha,250,"Nome/Razão Social:",oFont10n) // "Nome/Razão Social:"
				oPrint:Say(nLinha,750,Alltrim(cCli),oFont10)
				nLinha	+= nSalto
				oPrint:Say(nLinha,250,"C.P.F./C.N.P.J.:",oFont10n) // "C.P.F./C.N.P.J.:"
				oPrint:Say(nLinha,750,Alltrim(cCNPJCli),oFont10)
				nLinha	+= nSalto
				oPrint:Say(nLinha,250,"Inscrição Municipal:",oFont10n) // "Inscrição Municipal:"
				oPrint:Say(nLinha,750,Alltrim(cIMCli),oFont10)
				nLinha	+= nSalto
				oPrint:Say(nLinha,250,"Endereço:",oFont10n) // "Endereço:"
				oPrint:Say(nLinha,750,Alltrim(cEndCli) + " - " + Alltrim(cBairrCli) ,oFont10)
				nLinha	+= nSalto			
				oPrint:Say(nLinha,250,"CEP:",oFont10n) // "CEP:"
				oPrint:Say(nLinha,750,Transform(cCepCli,"@R 99999-999"),oFont10)
				nLinha	+= nSalto
				oPrint:Say(nLinha,250,"Município:",oFont10n) // "Município:"
				oPrint:Say(nLinha,750,Alltrim(cMunCli),oFont10)			
				oPrint:Say(nLinha,1800,"UF:",oFont10n) // "UF:"
				oPrint:Say(nLinha,1900,Alltrim(cUFCli),oFont10)
				nLinha	+= nSalto
				oPrint:Say(nLinha,250,"E-mail:",oFont10n) // "E-mail:"
				oPrint:Say(nLinha,750,Alltrim(cEmailCli),oFont10)
				
				
				
				oPrint:Line(1105,nColIni,1105,nColFim)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Dados do intermediario de serviço³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				nLinha	:= 1160
				oPrint:Say(nLinha,nCentro/2-len("INTERMEDIÁRIO DE SERVIÇOS"),"INTERMEDIÁRIO DE SERVIÇOS",oFont12n) // "INTERMEDIÁRIO DE SERVIÇOS"
				nLinha	+= 50
				oPrint:Say(nLinha,250,"C.P.F./C.N.P.J.:",oFont10n) // "C.P.F./C.N.P.J.:"
				oPrint:Say(nLinha,950,"Nome/Razão Social:",oFont10n) // "Nome/Razão Social:"
				oPrint:Say(nLinha,520,Alltrim(cCNPJIntSer),oFont10)
				oPrint:Say(nLinha,1255,Alltrim(cCliIntSer),oFont10)
				
				oPrint:Line(1235,nColIni,1235,nColFim)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Discriminacao dos Servicos ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				oPrint:Say(1280,nCentro/2-len("DISCRIMINAÇÃO DOS SERVIÇOS"),"DISCRIMINAÇÃO DOS SERVIÇOS",oFont12n) // "DISCRIMINAÇÃO DOS SERVIÇOS"
				
				nLinha	:= 1330
				For nY := 1 to Len(aPrintServ)
					If nY > 15
						Exit
					Endif
					oPrint:Say(nLinha,250,Alltrim(aPrintServ[nY]),oFont10)
					nLinha 	:= nLinha + 45
				Next
				
				nLinha	:= 1920 //1865
				oPrint:Line(nLinha,nColIni,nLinha,nColFim)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Valores da prestacao de servicos³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !lBhorizonte
					oPrint:Say(nLinha-20,nColIni,PadC(Alltrim("Valores da prestacao de servicos")+" R$ "+AllTrim(Transform(nVlContab,"@E 999,999,999.99")),100) ,oFont12n) 
					//nLinha+= 60
					//oPrint:Line(nLinha,nColIni,1950,nColFim)
				EndIf
	
	
				
				nLinha	+= 50
				If lRecife
					oPrint:Say(1965,250,Alltrim("Código do Serviço"),oFont10n) // "Código do Serviço"
					oPrint:Say(2005,250,Alltrim(cCodAtiv),oFont10)
				ElseIf lBhorizonte
					oPrint:Say(nLinha,250,Alltrim("Código do Serviço"),oFont10n) // "Código do Serviço"
					oPrint:Say(nLinha,620,Alltrim(cCodServ),oFont10)
				ElseIf lPaulista
					oPrint:Line(1922,582,1990,582)// (  , , , )
					oPrint:Line(1922,972,1990,972)
					oPrint:Line(1922,1372,1990,1372)
					oPrint:Line(1922,1772,1990,1772)
					oPrint:Say(1965,250,Alltrim("INSS (R$)"),oFont10n) // "INSS (R$)"
					oPrint:Say(1960,280,Transform(nValINSS,"@E 999,999,999.99"),oFont10)
					oPrint:Say(1965,600,Alltrim("IRPF (R$)"),oFont10n) // "IRPF (R$)"
					oPrint:Say(1960,670,Transform(nValIR,"@E 999,999,999.99"),oFont10)
					oPrint:Say(1965,1000,Alltrim("CSLL (R$)"),oFont10n) // "CSLL (R$)"
					oPrint:Say(1960,1070,Transform(nValCSLL,"@E 999,999,999.99"),oFont10)
					oPrint:Say(1965,1400,Alltrim("COFINS (R$)"),oFont10n) // "COFINS (R$)"
					oPrint:Say(1960,1470,Transform(nValCof,"@E 999,999,999.99"),oFont10)
					oPrint:Say(1965,1800,Alltrim("PIS/PASEP (R$)"),oFont10n) // "PIS/PASEP (R$)"
					oPrint:Say(1960,1870,Transform(nValPis,"@E 999,999,999.99"),oFont10)
					oPrint:Say(2055,250,Alltrim("Código do Serviço"),oFont10n) // "Código do Serviço"
					oPrint:Say(2100,250,Alltrim(cCodServ),oFont10)
					oPrint:Line(2120,nColIni,2120,nColFim) 
				Else
					oPrint:Say(nLinha,250,Alltrim("Código do Serviço"),oFont10n) // "Código do Serviço"
					nLinha	+=  50
					oPrint:Say(nLinha,250,Alltrim(cCodServ),oFont10)
				EndIf
	
				nLinha	+= 20
				oPrint:Line(nLinha,nColIni,nLinha,nColFim)
				/*
				If lBhorizonte
					oPrint:Line(nLinha,nColIni,nLinha,nColFim)
				ElseIf lPaulista
					oPrint:Line(2145,nColIni,2145,nColFim)
				Else
					oPrint:Line(nLinha,nColIni,nLinha,nColFim)
				EndIf
				*/
				
				
				If lRioJaneiro
					oPrint:Line(2050,632,2150,632)
					oPrint:Line(2050,979,2150,979)
					oPrint:Line(2050,1446,2150,1446)
					oPrint:Line(2050,1736,2150,1736)
					oPrint:Say(2065,250,Alltrim("Total deduções (R$)"),oFont09n) // "Total deduções (R$)"
					oPrint:Say(2105,320,Transform(nValDed,"@E 999,999,999.99"),oFont09)        
					oPrint:Say(2065,647,Alltrim("Desc.Incond. (R$)"),oFont09n) // "Desc.Incond. (R$)"
					oPrint:Say(2105,667,Transform(nDescIncond,"@E 999,999,999.99"),oFont09)
					oPrint:Say(2065,1014,Alltrim("Base de cálculo (R$)"),oFont09n) // "Base de cálculo (R$)"
					oPrint:Say(2105,1134,Transform((cAliasSF3)->F3_BASEICM,"@E 999,999,999.99"),oFont09)
					oPrint:Say(2065,1484,Alltrim("Alíquota (%)"),oFont09n) // "Alíquota (%)"
					oPrint:Say(2105,1584,Transform((cAliasSF3)->F3_ALIQICM,"@E 999.99"),oFont09)
					oPrint:Say(2065,1791,Alltrim("Valor do ISS (R$)"),oFont09n) // "Valor do ISS (R$)"
					oPrint:Say(2105,1881,Transform((cAliasSF3)->F3_VALICM,"@E 999,999,999.99"),oFont09)
					oPrint:Line(2150,nColIni,2150,nColFim)
				ElseIf lBhorizonte
					nLinha	+= 50
					oPrint:Say(nLinha,250,Alltrim("Valor dos serviços: "),oFont09n) // "Valor dos serviços"
					oPrint:Say(nLinha,920,Transform(nVlContab,"@E 999,999,999.99"),oFont09)        
					oPrint:Say(nLinha,1250,Alltrim("Valor dos serviços: "),oFont09n) // "Valor dos serviços"
					oPrint:Say(nLinha,1870,Transform(nVlContab,"@E 999,999,999.99"),oFont09)
					nLinha	+= 50        
					
					oPrint:Say(nLinha,250,Alltrim("(-)Descontos: "),oFont09n) // "Descontos"
					oPrint:Say(nLinha,920,Transform(nValDesc,"@E 999,999,999.99"),oFont09)        
					oPrint:Say(nLinha,1250,Alltrim("(-)Deduçoes: "),oFont09n) // "Deduções"
					oPrint:Say(nLinha,1870,Transform(nValDed,"@E 999,999,999.99"),oFont09) 
					nLinha	+= 50
					       
					oPrint:Say(nLinha,250,Alltrim("(-)Ret.Federais: "),oFont09n) // "Ret.Federais"
					oPrint:Say(nLinha,920,Transform(nRetFeder,"@E 999,999,999.99"),oFont09)        
					oPrint:Say(nLinha,1250,Alltrim("(-)Desc.Incond.: "),oFont09n) // "Desc.Incod"
					oPrint:Say(nLinha,1870,Transform(nDescIncond,"@E 999,999,999.99"),oFont09)   
					nLinha	+= 50
					     
					oPrint:Say(nLinha,250,Alltrim("(-)ISS Ret.: "),oFont09n) // "ISS Ret."
					oPrint:Say(nLinha,920,Transform(IIf(cRecIss=="1",nValISS,0),"@E 999,999,999.99"),oFont09)        
					oPrint:Say(nLinha,1250,Alltrim("(=)Base Cálc.: "),oFont09n) // "Base Cálc."
					oPrint:Say(nLinha,1870,Transform((cAliasSF3)->F3_BASEICM,"@E 999,999,999.99"),oFont09)
					nLinha	+= 50
					        
					oPrint:Say(nLinha,250,Alltrim("Valor Liq.: "),oFont09n) // "Valor Liq."
					oPrint:Say(nLinha,920,Transform(nValLiq,"@E 999,999,999.99"),oFont09)        
					oPrint:Say(nLinha,1250,Alltrim("Alíquota: "),oFont09n) // "Alíquota"
					oPrint:Say(nLinha,1988,Transform((cAliasSF3)->F3_ALIQICM,"@E 999.99"),oFont09)  
					nLinha	+= 50
					      
					oPrint:Say(nLinha,1250,Alltrim("(=)Valor ISS: "),oFont09n) // "Valor ISS"
					oPrint:Say(nLinha,1870,Transform((cAliasSF3)->F3_VALICM,"@E 999,999,999.99"),oFont09)    
					nLinha	+= 60
					    
					oPrint:Say(nLinha,250,"PIS:" ,oFont09)
					oPrint:Say(nLinha,285,Transform(nValPis ,PesqPict("SF3","F3_VALICM")),oFont09) 
					oPrint:Say(nLinha,630,"COFINS:" ,oFont09)
					oPrint:Say(nLinha,690,Transform(nValCof ,PesqPict("SF3","F3_VALICM")),oFont09) 
					oPrint:Say(nLinha,1005,"IR:" ,oFont09)
					oPrint:Say(nLinha,1035,Transform(nValIR  ,PesqPict("SF3","F3_VALICM")),oFont09) 
					oPrint:Say(nLinha,1380,"CSLL:" ,oFont09)
					oPrint:Say(nLinha,1410,Transform(nValCSLL,PesqPict("SF3","F3_VALICM")),oFont09) 
					oPrint:Say(nLinha,1755,"INSS:" ,oFont09)
					oPrint:Say(nLinha,1785,Transform(nValINSS,PesqPict("SF3","F3_VALICM")),oFont09)
					
					nLinha	+= 90				
					oPrint:Say(nLinha,nColIni,PadC(Alltrim("INFORMAÇÕES SOBRE A NOTA FISCAL ELETRÔNICA"),75),oFont10n) // "INFORMAÇÕES SOBRE A NOTA FISCAL ELETRÔNICA"
					
					nLinha	+= 20
					oPrint:Line(nLinha,nColIni,nLinha,nColFim)
					oPrint:Line(nLinha,712,nLinha,712)
					oPrint:Line(nLinha,1070,nLinha,1070)
					oPrint:Line(nLinha,1686,nLinha,1686)
					
					nLinha	+= 40
					oPrint:Say(nLinha,250,Alltrim("Número"),oFont09n) // "Número"
					oPrint:Say(nLinha,737,Alltrim("Emissão"),oFont09n) // "Emissão"
					oPrint:Say(nLinha,1094,Alltrim("Código Verificação"),oFont09n) // "Código Verificação"
					oPrint:Say(nLinha,1711,Alltrim("Crédito IPTU"),oFont09n) // "Crédito IPTU"
					
					nLinha	+= 40
					//oPrint:Say(nLinha,250,Padl(StrZero(Year((cAliasSF3)->F3_EMISSAO),4)+"/"+(cAliasSF3)->F3_NFELETR,14),oFont09)				
					oPrint:Say(nLinha,250,alltrim((cAliasSF3)->F3_NFELETR),oFont09)
					oPrint:Say(nLinha,737,Padl(Transform(dToC((cAliasSF3)->F3_EMINFE),"@d"),14),oFont09)
					//oPrint:Say(nLinha,1094,alltrim((cAliasSF3)->F3_CODNFE),oFont09)
					oPrint:Say(nLinha,1094, alltrim(if(EMPTY(SF2->F2_XCVNFS), (cAliasSF3)->F3_CODNFE, SF2->F2_XCVNFS) ),oFont09)				
					oPrint:Say(nLinha,1831,Transform((cAliasSF3)->F3_CREDNFE,"@E 999,999,999.99"),oFont09)
					
					nLinha	+= 40
					oPrint:Line(nLinha,nColIni,nLinha,nColFim)
					nLinha	:= 2530
					For nY := 1 to Len(aPrintObs)
						If nY > 11
							Exit
						Endif
						oPrint:Say(nLinha,250,Alltrim(aPrintObs[nY]),oFont09)
						nLinha 	:= nLinha + 50
					Next
				ElseIf lPaulista
					cMunPreSer := UfCodIBGE(cUFCli)+cCodMun
					oPrint:Line(2120,582,2245,582)
					oPrint:Line(2120,972,2245,972)
					oPrint:Line(2120,1372,2245,1372)
					oPrint:Line(2120,1772,2245,1772)
					oPrint:Say(2160,250,Alltrim("Total deduções (R$)"),oFont10n) // "Total deduções (R$)"
					oPrint:Say(2200,280,Transform(nValDed,"@E 999,999,999.99"),oFont10)	
					oPrint:Say(2160,600,Alltrim("Base de cálculo (R$)"),oFont10n) // "Base de cálculo (R$)"
					oPrint:Say(2200,670,Transform((cAliasSF3)->F3_BASEICM,"@E 999,999,999.99"),oFont10)
					oPrint:Say(2160,1000,Alltrim("Alíquota (%)"),oFont10n) // "Alíquota (%)"
					oPrint:Say(2200,1070,Transform((cAliasSF3)->F3_ALIQICM,"@E 999,999,999.99"),oFont10)
					oPrint:Say(2160,1400,Alltrim("Valor do ISS (R$)"),oFont10n) // "Valor do ISS (R$)"
					oPrint:Say(2200,1470,Transform((cAliasSF3)->F3_VALICM,"@E 999,999,999.99"),oFont10)
					oPrint:Say(2160,1800,Alltrim("Crédito (R$)"),oFont10n) // "Crédito (R$)"
					oPrint:Say(2200,1870,Transform(nValCred,"@E 999,999,999.99"),oFont10)
					oPrint:Line(2245,nColIni,2245,nColFim)
					//oPrint:Line(2245,920,2345,920)
					//oPrint:Line(2245,1400,2345,1400)
					oPrint:Say(2280,250,Alltrim("Municipio da Prestação do Serviço"),oFont10n) //"Municipio da Prestação do Serviço"
					oPrint:Say(2320,250,cMunPreSer,oFont10)
					oPrint:Say(2280,940,Alltrim("Número da Inscrição da Obra"),oFont10n) //"Número da Inscrição da Obra"
					oPrint:Say(2320,940,cNroInsObr,oFont10)
					oPrint:Say(2280,1425,Alltrim("Valor Aproximado dos Tributos/Fonte"),oFont10n) //"Valor Aproximado dos Tributos/Fonte"
					oPrint:Say(2320,1425,cValAprTri,oFont10)
					oPrint:Line(2345,nColIni,2345,nColFim)
				Else
					oPrint:Line(nLinha,712,nLinha+130,712)
					oPrint:Line(nLinha,1199,nLinha+130,1199)
					oPrint:Line(nLinha,1686,nLinha+130,1686)
					nLinha	+= 35
					
		
					oPrint:Say(nLinha,250,Alltrim("Total deduções (R$)"),oFont10n) // "Total deduções (R$)"
					oPrint:Say(nLinha,737,Alltrim("Base de cálculo (R$)"),oFont10n) // "Base de cálculo (R$)"
					oPrint:Say(nLinha,1224,Alltrim( "Alíquota (%)"),oFont10n) // "Alíquota (%)"
					oPrint:Say(nLinha,1711,Alltrim("Valor do ISS (R$)"),oFont10n) // "Valor do ISS (R$)"
					
					nLinha	+= 50
					oPrint:Say(nLinha,370,Transform(nValDed,"@E 999,999,999.99"),oFont10)				
					oPrint:Say(nLinha,857,Iif(lJoinville,Transform(nValBase,"@E 999,999,999.99"),Transform((cAliasSF3)->F3_BASEICM,"@E 999,999,999.99")),oFont10)				
					oPrint:Say(nLinha,1344,Iif(lJoinville,Transform(nAliquota,"@E 999,999,999.99"),Transform((cAliasSF3)->F3_ALIQICM,"@E 999,999,999.99")),oFont10)				
					oPrint:Say(nLinha,1831,Transform((cAliasSF3)->F3_VALICM,"@E 999,999,999.99"),oFont10)
					nLinha+=45
					oPrint:Line(nLinha,nColIni,nLinha,nColFim)
				EndIf
	
				nLinha	+= 40
				If !(lBhorizonte .Or. lPaulista)
				
					oPrint:Say(nLinha,nCentro/2-len("INFORMAÇÕES SOBRE A NOTA FISCAL ELETRÔNICA"),"INFORMAÇÕES SOBRE A NOTA FISCAL ELETRÔNICA",oFont12n) // "INFORMAÇÕES SOBRE A NOTA FISCAL ELETRÔNICA"
					nLinha +=  60
					
					oPrint:Line(nLinha,nColIni,nLinha,nColFim)
					oPrint:Line(nLinha,712,nLinha+120,712)
					oPrint:Line(nLinha,1070,nLinha+120,1070)
					oPrint:Line(nLinha,1686,nLinha+120,1686)
					nLinha += 35
					
					oPrint:Say(nLinha,250,Alltrim("Número"),oFont10n) // "Número"
					oPrint:Say(nLinha,737,Alltrim("Emissão"),oFont10n) // "Emissão"				
					oPrint:Say(nLinha,1094,Alltrim("Código Verificação"),oFont10n) // "Código Verificação"				
					oPrint:Say(nLinha,1711,Alltrim("Crédito IPTU"),oFont10n) // "Crédito IPTU"
					nLinha += 50 				
					
					//oPrint:Say(nLinha,370,Padl(StrZero(Year((cAliasSF3)->F3_EMISSAO),4)+"/"+(cAliasSF3)->F3_NFELETR,14),oFont10)
					oPrint:Say(nLinha,250,alltrim((cAliasSF3)->F3_NFELETR),oFont10)
					oPrint:Say(nLinha,737,Padl(Transform(dToC((cAliasSF3)->F3_EMINFE),"@d"),14),oFont10)
					oPrint:Say(nLinha,1094,alltrim(if(EMPTY(SF2->F2_XCVNFS), (cAliasSF3)->F3_CODNFE, SF2->F2_XCVNFS) ),oFont10)
					oPrint:Say(nLinha,1831,Transform((cAliasSF3)->F3_CREDNFE,"@E 999,999,999.99"),oFont10)
					nLinha += 35
					
	
					
					oPrint:Line(nLinha,nColIni,nLinha,nColFim)
				Endif
	
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Outras Informacoes³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If !lBhorizonte
					nLinha	:= 2430
					oPrint:Say(nLinha,nCentro/2-len("OUTRAS INFORMAÇÕES"),"OUTRAS INFORMAÇÕES",oFont12n) // "OUTRAS INFORMAÇÕES"
					nLinha	+= 90
					For nY := 1 to Len(aPrintObs)
						If nY > 11
							Exit
						Endif
						oPrint:Say(nLinha,250,Alltrim(aPrintObs[nY]),oFont10)
						nLinha	:= nLinha + 50
					Next
					oPrint:Line(1850,nColIni,1850,nColFim)
				EndIF
				If nCopias > 1 .And. nX < nCopias
					oPrint:EndPage()
				Endif
			Next
			(cAliasSF3)->(dbSkip())
			If !((cAliasSF3)->(Eof()))
				oPrint:EndPage()
			Endif
		Enddo
	EndIf
ELSE
	lRet	:= .f.
ENDIF

If !lQuery
	RetIndex("SF3")
	dbClearFilter()
	Ferase(cArqInd+OrdBagExt())
Else
	dbSelectArea(cAliasSF3)
	(cAliasSF3)->(dbCloseArea())
Endif

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MTR948Str ºAutor  ³Mary Hergert        º Data ³ 03/08/2006  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Montar o array com as strings a serem impressas na descr.   º±±
±±º          ³dos servicos e nas observacoes.                             º±±
±±º          ³Se foi uma quebra forcada pelo ponto de entrada, e          º±±
±±º          ³necessario manter a quebra. Caso contrario, montamos a linhaº±±
±±º          ³de cada posicao do array a ser impressa com o maximo de     º±±
±±º          ³caracteres permitidos.                                      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³Array com os campos da query                                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³cString: string completa a ser impressa                     º±±
±±º          ³nLinhas: maximo de linhas a serem impressas                 º±±
±±º          ³nTotStr: tamanho total da string em caracteres              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³MATR968                                                     º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/ 
Static Function Mtr968Mont(cString,nLinhas,nTotStr)

Local aAux		:= {}
Local aPrint	:= {}

Local cMemo		:= ""
Local cAux		:= ""

Local nX		:= 1
Local nY		:= 1
Local nPosi		:= 1

cString := SubStr(cString,1,nTotStr)

For nY := 1 to Min(MlCount(cString,86),nLinhas)

	cMemo := MemoLine(cString,86,nY)

	// Monta a string a ser impressa ate a quebra
	Do While .T.
		nPosi 	:= At("|",cMemo)
		If nPosi > 0
			Aadd(aAux,{SubStr(cMemo,1,nPosi-1),.T.})
			cMemo 	:= SubStr(cMemo,nPosi+1,Len(cMemo))
		Else
			If !Empty(cMemo)
				Aadd(aAux,{cMemo,.F.})
			Endif
			Exit
		Endif
	Enddo
Next

For nY := 1 to Len(aAux)
	cMemo := ""
	If aAux[nY][02]
		Aadd(aPrint,aAux[nY][01])
	Else
		cMemo += Alltrim(aAux[nY][01]) + Space(01)
		Do While !aAux[nY][02]
			nY += 1
			If nY > Len(aAux)
				Exit
			Endif
			cMemo += Alltrim(aAux[nY][01]) + Space(01)
		Enddo
		For nX := 1 to Min(MlCount(cMemo,86),nLinhas)
			cAux := MemoLine(cMemo,86,nX)
			Aadd(aPrint,cAux)
		Next
	Endif
Next

Return(aPrint)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³M968Discri³ Autor ³Alexandre Inacio Lemes ³ Data ³27/05/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monta um array com a string quebrada em linhas com o tamanho³±±
±±³          ³da capacidade de impressao da linha utilizado RPS Sorocaba  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MATR968                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function M968Discri(cString,nLinhas,nTotStr)

Local aAux		:= {}
Local aPrint	:= {}

Local cMemo		:= ""
Local cAux		:= ""

Local nX		:= 1
Local nY		:= 1
Local nPosi		:= 1

cString := SubStr(cString,1,nTotStr)

For nY := 1 to Min(MlCount(cString,130),nLinhas)

	cMemo := MemoLine(cString,130,nY)

	// Monta a string a ser impressa ate a quebra
	Do While .T.
		nPosi	:= At("|",cMemo)
		If nPosi > 0
			Aadd(aAux,{SubStr(cMemo,1,nPosi-1),.T.})
			cMemo	:= SubStr(cMemo,nPosi+1,Len(cMemo))
		Else
			If !Empty(cMemo)
				Aadd(aAux,{cMemo,.F.})
			Endif
			Exit
		Endif
	Enddo
Next

For nY := 1 to Len(aAux)
	cMemo := ""
	If aAux[nY][02]
		Aadd(aPrint,aAux[nY][01])
	Else
		cMemo += Alltrim(aAux[nY][01]) + Space(01)
		Do While !aAux[nY][02]
			nY += 1
			If nY > Len(aAux)
				Exit
			Endif
			cMemo += Alltrim(aAux[nY][01]) + Space(01)
		Enddo
		For nX := 1 to Min(MlCount(cMemo,130),nLinhas)
			cAux := MemoLine(cMemo,130,nX) 
			Aadd(aPrint,cAux)
		Next
	Endif
Next

Return(aPrint)

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PrintBox  ³ Autor ³Alexandre Inacio Lemes ³ Data ³27/05/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao para "ENGROSSAR" a espessura das linhas do BOX atrave³±±
±±³          ³s do deslocamento dos pixels pelo for next                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MATR968                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function PrintBox(nPosY,nPosX,nAltura,nTamanho)

Local nX := 0

For nX := 1 To 5
	oPrint:Box(nPosY+nX,nPosX+nX,nAltura+nX,nTamanho+nX)
Next nX

Return

/*/
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³PrintLine ³ Autor ³Alexandre Inacio Lemes ³ Data ³27/05/2011³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao para "ENGROSSAR" a espessura das linhas do PrintLine ³±±
±±³          ³Atraves do deslocamento dos pixels pelo for next            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³MATR968                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function PrintLine(nPosY,nPosX,nAltura,nTamanho)

Local nX := 0

For nX := 1 To 5
	oPrint:Line(nPosY+nX,nPosX+nX,nAltura+nX,nTamanho+nX)
Next nX

Return

