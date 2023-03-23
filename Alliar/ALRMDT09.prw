#INCLUDE "PROTHEUS.CH"

#DEFINE XPROC		"ALRMDT09"
//-------------------------------------------------------------------
/*{Protheus.doc} ALRMDT09
Relatorio de Vacinacao por Periodo (MDTR900)

@author Guilherme Santos
@since 05/05/2016
@version P12
*/
//-------------------------------------------------------------------
User Function ALRMDT09()
	Local cPerg := "MDTR900   "

	If IsBlind()
		MDT09PROC(cPerg)
	Else
		MsAguarde({|| MDT09PROC(cPerg)}, "Processando Listagem de Vacinas a Realizar...")	
	EndIf

Return NIL
//-------------------------------------------------------------------
/*{Protheus.doc} MDT09Proc
Processamento do Relatorio

@author Guilherme Santos
@since 15/05/2016
@version P12
*/
//-------------------------------------------------------------------
Static Function MDT09Proc(cPerg)
	Local cPathRel	:= ""
	Local cFileRel	:= ""
	Local aCardData	:= {}
	Local cProcesso	:= XPROC
	Local cRetWS		:= ""
	Local cRetFtp		:= ""
	Local nMesRel		:= If(Month(Date()) + 1 > 12, 1, Month(Date()) + 1)
	Local nAnoRel		:= If(nMesRel == 1, Year(Date()) + 1, Year(Date()))
	Local dDataIni	:= CtoD("01/" + AllTrim(Str(nMesRel)) + "/" + AllTrim(Str(nAnoRel)))
	Local dDataFin	:= CtoD("")

	Do Case
		Case AllTrim(Str(nMesRel)) == "2"
			//Ano Bissexto
			If Mod(nAnoRel, 4) == 0 .AND. Mod(nAnoRel, 100) == 0 .AND. Mod(nAnoRel, 400) == 0
				dDataFin := CtoD("29/" + AllTrim(Str(nMesRel)) + "/" + AllTrim(Str(nAnoRel)))
			Else
				dDataFin := CtoD("28/" + AllTrim(Str(nMesRel)) + "/" + AllTrim(Str(nAnoRel)))
			EndIf
		Case AllTrim(Str(nMesRel)) $ "|4|6|9|11|"
			dDataFin := CtoD("30/" + AllTrim(Str(nMesRel)) + "/" + AllTrim(Str(nAnoRel)))
		Otherwise
			dDataFin := CtoD("31/" + AllTrim(Str(nMesRel)) + "/" + AllTrim(Str(nAnoRel)))
	EndCase

	Pergunte(cPerg, .F.)

	MV_PAR01 := Space(Len(MV_PAR01))				//  De Vacina ?				
	MV_PAR02 := Replicate("Z", Len(MV_PAR02))		//  Ate Vacina ?				
	MV_PAR03 := Space(Len(MV_PAR03))				//  De Ficha Medica ?			
	MV_PAR04 := Replicate("Z", Len(MV_PAR04))		//  Ate Ficha Medica ?		
	MV_PAR05 := Space(Len(MV_PAR05))				//  De Centro de Custo ?		
	MV_PAR06 := Replicate("Z", Len(MV_PAR06))		//  Ate Centro de Custo ?		
	MV_PAR07 := dDataIni								//  De Data Vacina ?			
	MV_PAR08 := dDataFin								//  Ate Data Vacina ?			
	MV_PAR09 := 2										//  Listar Vacinas ? 1-Aplicadas;2=Pendentes;3=Nao quer ser vacinado;4=Todos			
	MV_PAR10 := Replicate("Z", Len(MV_PAR10))		//  Situacao Func. ? Todos			

	//Gravacao do Arquivo de Trabalho
	TRBgrava()

	If TRB->(Eof())
		U_ALRXLOG("Sem dados para impressão.", .F., XPROC)
	Else
		U_ALRXLOG("Imprimindo Relatorio", .F., XPROC)

		//Impressao do Relatorio
		If MDT09IMP(@cPathRel, @cFileRel, cPerg)
			If U_MDTXFFTP(cPathRel, cFileRel, @cRetFtp)
				//Monta Formulário para Início da Tarefa
				U_ALRXCRD(@aCardData, "M0_CODIGO"			, SM0->M0_CODIGO					, XPROC)
				U_ALRXCRD(@aCardData, "M0_NOME"				, SM0->M0_NOME					, XPROC)
				U_ALRXCRD(@aCardData, "M0_CODFIL"			, AllTrim(SM0->M0_CODFIL)		, XPROC)
				U_ALRXCRD(@aCardData, "M0_FILIAL"			, SM0->M0_FILIAL					, XPROC)
				U_ALRXCRD(@aCardData, "login"				, SuperGetMv("MV_ECMUSER")		, XPROC)
				U_ALRXCRD(@aCardData, "colleagueName"		, SuperGetMv("MV_ECMUSER")		, XPROC)
				U_ALRXCRD(@aCardData, "papelResponsavel"	, ""								, XPROC)

				U_ALRXLOG("Arquivo enviado com Sucesso ao Ftp do Fluig", .F., XPROC)
				U_ALRXLOG("Iniciando o Processo no Fluig.", .F., XPROC)

				//Inicia o Processo no Fluig
				U_ALRXFLG(aCardData, "ListagemDeVacinas", 11, @cRetWS, cFileRel)

				U_ALRXLOG(@cRetWS, .F., XPROC)
			EndIf

			U_ALRXLOG(@cRetFtp, .F., XPROC)
		Else	
			//Erro na Impressao
			U_ALRXLOG("Erro na Impressão.", .F., XPROC)
		EndIf
	EndIf
	
	If Select("TRB") > 0
		TRB->(DbCloseArea())
	EndIf

	If File(cPathRel + cFileRel)
		FErase(cPathRel + cFileRel)
	EndIf

	//Gravacao do Arquivo de Log
	U_ALRXLOG("", .T., XPROC)

Return NIL

//-------------------------------------------------------------------
/*{Protheus.doc} MDT09IMP
Impressao do Relatorio

@author Guilherme Santos
@since 14/05/2016
@version P12
*/
//-------------------------------------------------------------------
Static Function MDT09IMP(cPathRel, cFileRel, cPerg)
	Local lRetorno	:= .T.
	Local oReport		:= uPrintPDF():New(XPROC, "Listagem de Vacinas", "\spool\", "TRB", cPerg, 1, .T.)

	Local cFormula 	:= "TRB->NOMVAC + '-' + TRB->NUMCON"

	oReport:SetField("VACINA", 	"Nome Vacina| Programa", Len(TRB->NOMVAC) + Len(TRB->NUMCON), .F., "", .T., cFormula)

	oReport:SetField("NUMFIC", 	"Ficha Med.",			Len(TRB->NUMFIC), 	.F., "", .F.)
	oReport:SetField("NOMFIC", 	"Nome",				Len(TRB->NOMFIC), 	.F., "", .F.)

	oReport:SetField("CC", 		"CC", 					10, 					.F., "", .F.)
	oReport:SetField("NOMCC", 	"Descr.", 				Len(TRB->NOMCC),		.F., "", .F.)
	oReport:SetField("FUNCAO", 	"Funcao", 				Len(TRB->FUNCAO)+1, 	.F., "", .F.)
	oReport:SetField("NOMFUN", 	"Descr.", 				Len(TRB->NOMFUN)+1, 	.F., "", .F.)
	oReport:SetField("DOSE", 	"Dose", 				Len(TRB->DOSE)+3, 	.F., "", .F.)
	oReport:SetField("DTPREV", 	"Dt.Prev.", 			09,						.F., "", .F.)
	oReport:SetField("APLICA", 	"Aplica", 				Len(TRB->APLICA),		.F., "", .F.)

	If oReport:Print()
		cPathRel := oReport:GetPathServer()
		cFileRel := oReport:GetFileName()

		If !IsBlind()
			Aviso(XPROC, "Relatorio Impresso com Sucesso.", {"Fechar"})
		EndIf
	Else
		lRetorno := .F.
		If !IsBlind()
			Aviso(XPROC, "Erro durante a Impressao do Relatorio.", {"Fechar"})
		EndIf
	EndIf

Return lRetorno	
//-------------------------------------------------------------------
/*{Protheus.doc} TRBGrava
Geracao do Arquivo de Trabalho

@author Guilherme Santos
@since 15/05/2016
@version P12
*/
//-------------------------------------------------------------------
Static Function TRBgrava()
	Local cIndex := ""
	Local cChave := ""
	Local cFiltro
	Local lCC
	Local cSituac := ""
	
	Local aDBF := {}
	Local vIND := {}  

	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Filtra os registros da tabela TL9³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	********************************
	dbSelectArea( "TL9" )
	dbSetOrder( 1 )
	
	cIndex := CriaTrab("TL9",.F.)
	cChave := IndexKey()	//"TL9_FILIAL + TL9_NUMFIC + DTOS(TL9_DTPREV) + TL9_VACINA"
	cFiltro := 'TL9->TL9_FILIAL =="' + xFilial("TL9")  + '".And.'
	cFiltro += 'TL9->TL9_VACINA >="' + MV_PAR01 + '".And.'
	cFiltro += 'TL9->TL9_VACINA <="' + MV_PAR02 + '".And.'
	cFiltro += 'TL9->TL9_NUMFIC >="' + MV_PAR03 + '".And.'
	cFiltro += 'TL9->TL9_NUMFIC <="' + MV_PAR04 + '".And.'
	If mv_par09 == 1  //Aplicadas
		cFiltro += 'TL9->TL9_INDVAC == "1" .And. '
	ElseIf mv_par09 == 2  //Pendentes
		cFiltro += '(TL9->TL9_INDVAC == "2" .Or. Empty(TL9->TL9_INDVAC)) .and. '
	ElseIf mv_par09 == 3  //Nao quer ser vacinado
		cFiltro += 'TL9->TL9_INDVAC == "3" .And. '
	Endif
	cFiltro += 'DtoS(TL9->TL9_DTPREV) >="' + DtoS(MV_PAR07) + '".And.'
	cFiltro += 'DtoS(TL9->TL9_DTPREV) <="' + DtoS(MV_PAR08) +  '"'
	
	INDREGUA("TL9", cIndex, cChave, , cFiltro, "Filtrando os registros, aguarde...", .F.)  //"Filtrando os registros, aguarde..."
	nIndex := RetIndex("TL9")
	
	cExtIndex := OrdBagExt()
	
	dbSelectArea( "TL9" )
	
	********************************
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Cria arquivo temporario³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aDBF :=	{ 	{ "VACINA" , "C", 10, 0 },;
					{ "NOMVAC" , "C", TamSX3("TL6_NOMVAC")[1], 0},;
					{ "NUMCON" , "C", TamSX3("TL9_NUMCON")[1], 0},;
					{ "NUMFIC" , "C", 09, 0 },;
					{ "NOMFIC" , "C", TamSX3("TM0_NOMFIC")[01], 0},;
					{ "CC"     , "C", 10, 0 },;
					{ "NOMCC"  , "C", TamSX3("CTT_DESC01")[01], 0},;
					{ "FUNCAO" , "C", 05, 0 },;
					{ "NOMFUN" , "C", TamSX3("RJ_DESC")[1], 0 },;
					{ "DOSE"   , "C", TamSX3("TL9_DOSE")[1], 0 },;
					{ "DTPREV" , "D", 08, 0 },;
					{ "APLICA" , "C", 35, 0 } }
	
	Aadd( vIND, "VACINA + NUMFIC + DtoS(DTPREV)" )  //Indices
	
	cArqTrab := NGCRIATRB( aDBF, vIND, "TRB" )  //Cria arquivo temporario
	
	********************************
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Grava os dados no arquivo temporario³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	
	dbSelectArea( "TL9" )
	dbSetOrder( nIndex + 1 )
	dbGoTop()
	
	ProcRegua( 10 )
	
	While !Eof()
		
		IncProc()
		
		dbSelectArea( "TM0" )
		dbSetOrder( 1 )
		dbSeek( xFilial("TM0") + TL9->TL9_NUMFIC )
		
		lCC := .T.
		If !Empty(TM0->TM0_CC) .And. Empty(TM0->TM0_MAT)
			If (TM0->TM0_CC < mv_par05) .OR. (TM0->TM0_CC > mv_par06)
				dbSelectArea( "TL9" )
				dbSkip()
				Loop
			Endif
			lCC := .F.
		Endif
		
		DbSelectArea( "SRA" )
		DbSetOrder( 1 )
		DbSeek( xFilial("SRA") + TM0->TM0_MAT )
		
		If lCC .And. ( (SRA->RA_CC < mv_par05) .OR. (SRA->RA_CC > mv_par06) )
			DbSelectArea( "TL9" )
			DbSkip()
			Loop
		Endif
		
		//-------------------------------------------------------------
		// Filtro pela situação do funcionário.
		//-------------------------------------------------------------
		cSituac := If( Empty( MV_PAR10 ),Space(1),AllTrim( MV_PAR10 ) )
		If cSituac != "ZZZZZZ" .And. SRA->RA_SITFOLH != cSituac
			DbSelectArea("TL9")
			DbSkip()
			Loop									
		EndIf		
		
		TRB->(dbAppend())
		TRB->VACINA := TL9->TL9_VACINA
		TRB->NOMVAC := Posicione("TL6", 1, xFilial("TL6") + TL9->TL9_VACINA, "TL6_NOMVAC")
		TRB->NUMCON := TL9->TL9_NUMCON
		TRB->NUMFIC := TL9->TL9_NUMFIC
		TRB->NOMFIC := TM0->TM0_NOMFIC
		If !lCC
			TRB->CC := AllTrim(TM0->TM0_CC)
		Else
			TRB->CC := AllTrim(SRA->RA_CC)
		Endif
		TRB->NOMCC	:= Posicione("CTT", 1, xFilial("CTT") + TRB->CC, "CTT_DESC01")
		TRB->FUNCAO := SRA->RA_CODFUNC
		TRB->NOMFUN := Posicione("SRJ", 1, xFilial("SRJ") + SRA->RA_CODFUNC, "RJ_DESC")
		TRB->DOSE   := TL9->TL9_DOSE
		TRB->DTPREV := TL9->TL9_DTPREV
		If TL9->TL9_INDVAC == "1"
			TRB->APLICA := "SIM"
		ElseiF TL9->TL9_INDVAC == "2" .OR. EMPTY(TL9->TL9_INDVAC)
			TRB->APLICA := "NÃO"
		ElseIf TL9->TL9_INDVAC == "3"
			TRB->APLICA := "FUNCIONÁRIO NÃO QUER SER VACINADO"
		Else
			TRB->APLICA := ""
		Endif
		
		dbSelectArea( "TL9" )
		dbSkip()
	End
	
	Ferase( cIndex + cExtIndex ) // Deleta indice

Return .T.     

