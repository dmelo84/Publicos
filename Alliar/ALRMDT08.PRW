#INCLUDE "PROTHEUS.CH"

#DEFINE XPROC		"ALRMDT08"
//-------------------------------------------------------------------
/*{Protheus.doc} ALRMDT08
Relatorio de Listagem de Exames a Realizar

@author Guilherme Santos
@since 06/05/2016
@version P12
*/
//-------------------------------------------------------------------
User Function ALRMDT08()
	Local cPerg			:= "U_ALRMDT08"


	If IsBlind()
		MDT08PROC(cPerg)
	Else
		MsAguarde({|| MDT08PROC(cPerg)}, "Processando Listagem de Exames a Realizar...")	
	EndIf
Return NIL
//-------------------------------------------------------------------
/*{Protheus.doc} MDT08PROC
Impressao do Relatorio

@author Guilherme Santos
@since 06/05/2016
@version P12
*/
//-------------------------------------------------------------------
Static Function MDT08PROC(cPerg)
	Local aTotal450	:= {}
	Local nTotal450	:= 0
	Local cPathRel	:= ""
	Local cFileRel	:= ""
	Local aCardData	:= {}
	Local cProcesso	:= "ALRMDT08"
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

	//Perguntas do Relatorio
	Pergunte(cPerg, .F.)
	
	MV_PAR01 := Space(Len(MV_PAR01))								//01  De PCMSO            ?
	MV_PAR02 := Replicate("Z", Len(MV_PAR02))						//02  Até PCMSO           ?
	MV_PAR03 := Space(Len(MV_PAR03))								//03  De  Exame           ?
	MV_PAR04 := Replicate("Z", Len(MV_PAR04))						//04  Ate Exame           ?
	MV_PAR05 := dDataIni												//05  De  Data Programac. ?
	MV_PAR06 := dDataFin												//06  Ate Data Programac. ?
	MV_PAR07 := Space(Len(MV_PAR07))								//07  De  Centro de Custo ?
	MV_PAR08 := Replicate("Z", Len(MV_PAR08))						//08  Ate Centro de Custo ?
	MV_PAR09 := 2														//09  Imprimir Todos      ? 1=Todos;2=Não Realizados;3=Realizados
	MV_PAR10 := 1														//10  Classificar por     ? 1=Ficha,Exame,data;2=Exame,Data;3=Nome,Exame,data;4=C.Cus,Func,Data;5=Data,Ficha,Exam
	MV_PAR11 := 2														//11  Listar Demitidos    ? 1=Nao;2=Sim
	MV_PAR12 := 2														//12  Listar Totalizador  ? 1=Sim;2=Nao
	MV_PAR13 := 1														//13  Tipo de Relatorio   ? 1=Analitico;2=Sintetico
	MV_PAR14 := cFilAnt												//14  De Filial           ?
	MV_PAR15 := cFilAnt												//15  Ate Filial          ?

	//Criacao do TRB para geracao do Relatorio
	MDT08TRB(@aTotal450, @nTotal450)

	If TRB->(Eof())
		U_ALRXLOG("Sem dados para impressão.", .F., XPROC)
	Else
		U_ALRXLOG("Imprimindo Relatorio", .F., XPROC)

		//Impressao do Relatorio
		If MDT08IMP(aTotal450, nTotal450, @cPathRel, @cFileRel, cPerg)
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
				U_ALRXFLG(aCardData, "ListagemDeExames", 11, @cRetWS, cFileRel)

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
/*{Protheus.doc} MDT08TRB
Função responsavel pela montagem da TRB e por trazer os registros

@author Guilherme Santos
@since 10/05/2016
@version P12
*/
//-------------------------------------------------------------------
Static Function MDT08TRB(aTotal450, nTotal450)
	Local aAreaSM0 	:= SM0->(GetArea())
	Local aDBF			:= {}
	Local aINDEX		:= {}
	Local aFilRelat 	:= {}

	Local cArqTrab	:= ""
	Local nXYZ			:= 0
	Local nPosCC		:= 0
	Local nTotExam 	:= 0
	Local nTotNaoR 	:= 0
	Local nTotAtra 	:= 0
	Local nTotReal 	:= 0
	Local lTMW_Filial	:= Empty(xFilial("TMW")) .AND. !Empty(xFilial("SRA"))		//Indica se o PCMSO é para varias filiais
	Local lRetorno 	:= .T.
	
	Default aTotal450	:= {}
	Default nTotal450	:= 0

	//------------------------------------------------------------
	//  Define o Indice conforme a classificacao selecionada.    -
	//------------------------------------------------------------
	AADD(aDBF, { "FILFUN"  , "C" , TamSX3("TMW_FILIAL")[1], 0 })
	AADD(aDBF, { "FICHA"   , "C" , 09, 0 })
	AADD(aDBF, { "MAT"     , "C" , 06, 0 })
	AADD(aDBF, { "NOME"    , "C" , 30, 0 })
	AADD(aDBF, { "EXAME"   , "C" , If(TamSX3("TM4_EXAME")[1] < 1, 6, TAMSX3("TM4_EXAME")[1]), 0 })
	AADD(aDBF, { "NOMEXA"  , "C" , 30, 0 })
	AADD(aDBF, { "DTREAL"  , "D" , 08, 0 })
	AADD(aDBF, { "DTPROG"  , "D" , 08, 0 })
	AADD(aDBF, { "CC"      , "C" , TamSX3("CTT_CUSTO")[1], 0 })
	AADD(aDBF, { "NOMCC"   , "C" , TamSX3("CTT_DESC01")[1], 0 })
	AADD(aDBF, { "CODFUN"  , "C" , TamSX3("RJ_FUNCAO")[1], 0 })
	AADD(aDBF, { "NOMEFUN" , "C" , 24, 0 })
	AADD(aDBF, { "PCMSO"   , "C" , 06, 0 })
	
	//cArqTrab := CriaTrab(aDBF)
	//Use (cArqTrab) NEW Exclusive Alias TRB
	
	If MV_PAR10 == 1
		aINDEX := {"PCMSO+FILFUN+FICHA+EXAME+DTOS(DTPROG)" }
	Elseif MV_PAR10 == 2
		aINDEX := {"PCMSO+FILFUN+EXAME+DTOS(DTPROG)+FICHA" }
	Elseif MV_PAR10 == 3
		aINDEX := {"PCMSO+FILFUN+NOME+EXAME+DTOS(DTPROG)"}
	Elseif MV_PAR10 == 4
		aINDEX := {"PCMSO+FILFUN+CC+CODFUN+DTOS(DTPROG)"}
	Else
		aINDEX := {"PCMSO+FILFUN+DTOS(DTPROG)+FICHA+EXAME"}
	Endif
	
	//Cria TRB
	cArqTrab := NGCRIATRB(aDBF, aINDEX, "TRB")
	
	If MV_PAR13 == 2
		MV_PAR12 := 2
		MV_PAR10 := 1
	Endif
	
	nTotExam := 0
	nTotNaoR := 0
	nTotAtra := 0
	nTotReal := 0
	
	If lTMW_Filial .AND. !Empty(xFilial("TM5"))
		aAreaSM0 := SM0->(GetArea())
		dbSelectArea("SM0")
		dbGoTop()
		If Empty(Mv_par14)
			dbSeek(cEmpAnt)
		Else
			dbSeek(cEmpAnt+Mv_par14)
		Endif
		While !Eof() .and. SM0->M0_CODIGO == cEmpAnt .and. SM0->M0_CODFIL <= Mv_par15
			aAdd( aFilRelat , FWCodFil())
			dbSkip()
		End
		RestArea(aAreaSM0)
	Else
		aAdd( aFilRelat , FWCodFil())
	EndIf
	
	dbSelectArea("TM5")
	
	For nXYZ := 1 To Len(aFilRelat)
		
		dbSelectArea("TM5")
		dbSetOrder(03)
		dbSeek(xFilial("TM5", aFilRelat[nXYZ]) + MV_PAR01, .T.)
		While !Eof() .AND. TM5->TM5_FILIAL == xFilial('TM5', aFilRelat[nXYZ]) .and. TM5->TM5_PCMSO <= MV_PAR02
			
			If !Empty(TM5->TM5_FILFUN)
				If lTMW_Filial
					If TM5->TM5_FILFUN < Mv_par14 .or. TM5->TM5_FILFUN > Mv_par15
						dbSelectArea("TM5")
						dbskip()
						Loop
					Endif
				Else
					If TM5->TM5_FILFUN <> aFilRelat[nXYZ]
						dbSelectArea("TM5")
						dbskip()
						Loop
					Endif
				Endif
			Endif
			
			If mv_par09 == 1 .OR. mv_par09 == 2 .AND. EMPTY(TM5->TM5_DTRESU) .Or. mv_par09 == 3 .AND. !EMPTY(TM5->TM5_DTRESU)
				
				If  TM5->TM5_EXAME   >= MV_PAR03               .AND.;
						TM5->TM5_EXAME   <= MV_PAR04               .AND.;
						TM5->TM5_DTPROG  >= MV_PAR05               .AND.;
						TM5->TM5_DTPROG  <= MV_PAR06               .AND.;
						TM5->TM5_CC      >= MV_PAR07               .AND.;
						TM5->TM5_CC      <= MV_PAR08
					
					If mv_par11 == 1
						DbSelectArea("SRA")
						DbSetOrder(01)
						DbSeek(xFilial("SRA",TM5->TM5_FILFUN)+ TM5->TM5_MAT)
						If !Empty(SRA->RA_DEMISSA) .or. SRA->RA_SITFOLHA == "D"
							dbSelectArea("TM5")
							dbskip()
							Loop
						EndIf
					EndIf
					
					DbSelectArea("TM0")
					DbSetOrder(01)
					DbSeek(xFilial("TM0",TM5->TM5_FILFUN)+TM5->TM5_NUMFIC)
					
					DbSelectArea("TM4")
					DbSetOrder(01)
					DbSeek(xFilial("TM4",TM5->TM5_FILFUN)+ TM5->TM5_EXAME)
					
					DbSelectArea("SRJ")
					DbSetOrder(01)
					DbSeek(xFilial("SRJ",TM5->TM5_FILFUN)+ TM5->TM5_CODFUN)
					
					DbSelectArea("TMW")
					DbSetOrder(01)
					DbSeek(xFilial("TMW")+ TM5->TM5_PCMSO)
					
					TRB->(DbAppend())
					TRB->FILFUN  := TM5->TM5_FILFUN
					TRB->FICHA   := TM5->TM5_NUMFIC
					TRB->MAT     := TM5->TM5_MAT
					TRB->NOME    := SUBSTR(TM0->TM0_NOMFIC,1,30)
					TRB->EXAME   := TM5->TM5_EXAME
					TRB->NOMEXA  := SUBSTR(TM4->TM4_NOMEXA,1,30)
					TRB->DTREAL  := TM5->TM5_DTRESU
					TRB->DTPROG  := TM5->TM5_DTPROG
					TRB->CC      := TM5->TM5_CC
					TRB->NOMCC   := Posicione("CTT", 1, xFilial("CTT") + TRB->CC, "CTT_DESC01")
					TRB->CODFUN  := TM5->TM5_CODFUN
					TRB->NOMEFUN := SRJ->RJ_DESC
					TRB->PCMSO   := TM5->TM5_PCMSO
					
					If mv_par12 == 1
						nPosCC := aScan( aTotal450 ,{|x| x[1]+x[2]+x[6] == TRB->CC + TRB->CODFUN + TRB->FILFUN })
						If nPosCC == 0
							dbSelectArea("CTT")
							dbSetOrder(1)
							dbSeek( xFilial("CTT", TM5->TM5_FILFUN) + TRB->CC )
							aADD( aTotal450 , { 	TRB->CC , ;
													TRB->CODFUN , ;
													1 , ;
													Substr( TRB->NOMEFUN, 1, 30) ,;
													Substr( CTT->CTT_DESC01, 1, 30),;
													TRB->FILFUN } )
						Else
							aTotal450[nPosCC, 3] ++
						Endif
						nTotal450 ++
					Endif
					If mv_par13 == 2
						nTotExam++
						If Empty(TM5->TM5_DTRESU)
							If TM5->TM5_DTPROG < dDataBase
								nTotAtra++
							Else
								nTotNaoR++
							Endif
						Else
							nTotReal++
						Endif
					Endif
				ENDIF
			EndIf
			dbSelectArea("TM5")
			dbskip()
		End
	Next nXYZ
	
Return lRetorno
//-------------------------------------------------------------------
/*{Protheus.doc} MDT08IMP
Impressao do Relatorio

@author Guilherme Santos
@since 10/05/2016
@version P12
*/
//-------------------------------------------------------------------
Static Function MDT08IMP(aTotal450, nTotal450, cPathRel, cFileRel, cPerg)
	Local lRetorno	:= .T.
	Local oReport		:= uPrintPDF():New("ALRMDT08", "Listagem de Exames", "\spool\", "TRB", cPerg, 1, .T.)

	oReport:SetField("PCMSO", 	"PCMSO", 				Len(TRB->PCMSO), 		.F., "", .T.)
	oReport:SetField("FILFUN", 	"Filial", 				Len(TRB->FILFUN), 	.F., "", .F.)
	oReport:SetField("FICHA", 	"Ficha",				Len(TRB->FICHA), 		.F., "", .F.)
	oReport:SetField("MAT", 		"Matr.", 				Len(TRB->MAT), 		.F., "", .F.)
	oReport:SetField("NOME", 	"Nome", 				Len(TRB->NOME), 		.F., "", .F.)
	oReport:SetField("EXAME",	"Exame", 				Len(TRB->EXAME), 		.F., "", .F.)
	oReport:SetField("NOMEXA", 	"Nome Exame", 		Len(TRB->NOMEXA), 	.F., "", .F.)
	oReport:SetField("DTREAL", 	"Dt.Realiz.", 		09,						.F., "", .F.)
	oReport:SetField("DTPROG", 	"Dt.Progr.", 			09,						.F., "", .F.)
	oReport:SetField("CC", 		"CC", 					10, 					.F., "", .F.)
	oReport:SetField("NOMCC", 	"Descr.", 				Len(TRB->NOMCC),		.F., "", .F.)
//	oReport:SetField("CODFUN", 	"Cod.Fun.", 			Len(TRB->CODFUN)+1, 	.F., "", .F.)
//	oReport:SetField("NOMEFUN",	"Nome Fun.", 			Len(TRB->NOMEFUN), 	.F., "", .F.)

	If oReport:Print()
		cPathRel := oReport:GetPathServer()
		cFileRel := oReport:GetFileName()

		If !IsBlind()
			Aviso("ALRMDT08", "Relatorio Impresso com Sucesso.", {"Fechar"})
		EndIf
	Else
		lRetorno := .F.
		If !IsBlind()
			Aviso("ALRMDT08", "Erro durante a Impressao do Relatorio.", {"Fechar"})
		EndIf
	EndIf

Return lRetorno	
