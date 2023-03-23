#INCLUDE "protheus.ch"
#INCLUDE "TOPCONN.CH"



//| POSIÇÕES DO ARRAY

#DEFINE PLERES_CNPJ 			1
#DEFINE PLERES_NOME_EMP			2
#DEFINE PLERES_DATA_REF			3
#DEFINE PLERES_COD_ESPECIAL 	4
#DEFINE PLERES_NOME_ESP			5

#DEFINE PLERES_VALOR			6
#DEFINE PLERES_VLR_PRO_ACU		7
#DEFINE PLERES_FILIAL			8

/*
#DEFINE PLERES_VLR_PRO_ACU		6
#DEFINE PLERES_VLR_PRO_MES		7
#DEFINE PLERES_FILIAL			8
*/

//|VALORES FIXADOS

#DEFINE PLERES_ZC_TIPO		"3"
#DEFINE PLERES_ZC_CTADEB	"4202010001"
#DEFINE PLERES_ZC_CTACRD	"2101020001"
#DEFINE PLERES_ZC_CCD		"90101"
#DEFINE PLERES_ZC_CCC		"90101"



//+--------------------------------------------------------------------+
//| Rotina | MBRWMOD3| Autor | ARNALDO RAYMUNDO JR. |Data | 01.01.2007 |
//+--------------------------------------------------------------------+
//| Descr. | EXEMPLO DE UTILIZACAO DA MODELO3().                       |
//+--------------------------------------------------------------------+
//| Uso    | CURSO DE ADVPL                                            |
//+--------------------------------------------------------------------+

User Function ALCTBA03()

	Private cCadastro 	:= "Contabilização Integração Terceiro"
	Private aRotina 	:= {}
	Private cDelFunc 	:= ".T." // Validacao para a exclusao. Pode-se utilizar ExecBlock
	Private cAlias 		:= "SZD"

	AADD(aRotina,{ "Pesquisa"			,"AxPesqui"			,0,1})
	AADD(aRotina,{ "Visualizar"			,"U_Visual"			,0,2})
	AADD(aRotina,{ "Processar"	 		,"U_AL03CTBP(6)"	,0,3})
	AADD(aRotina,{ "Exclui" 			,"U_AL03CTBP(7)"	,0,4})
	AADD(aRotina,{ "Importar Pleres" 	,"U_ALCTBIMP()"		,0,3})

	dbSelectArea(cAlias)
	dbSetOrder(1)
	mBrowse( 6,1,22,75,cAlias)

Return


/*/{Protheus.doc} Visual
//Função responsável pela visualização dos registros de SZC e SZD.
@author marcos.aleluia
@since 07/11/2016
@version undefined
@param cAlias, characters, descricao
@param nReg, numeric, descricao
@param nOpcx, numeric, descricao
@type function
/*/
User Function Visual(cAlias,nReg,nOpcx)

	Local cTitulo := "Contabilização Integração Senior"
	Local cAliasE := "SZD"
	Local cAliasG := "SZC"
	Local cLinOk  := "AllwaysTrue()"
	Local cTudOk  := "AllwaysTrue()"
	Local cFieldOk:= "AllwaysTrue()"
	Local aCposE  := {}
	Local nUsado, nX  := 0


	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Opcoes de acesso para a Modelo 3                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Do Case
	Case nOpcx==3; nOpcE:=3 ; nOpcG:=3    // 3 - "INCLUIR"
	Case nOpcx==4; nOpcE:=3 ; nOpcG:=3    // 4 - "ALTERAR"
	Case nOpcx==2; nOpcE:=2 ; nOpcG:=2    // 2 - "VISUALIZAR"
	Case nOpcx==5; nOpcE:=2 ; nOpcG:=2	  // 5 - "EXCLUIR"
	EndCase

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria variaveis M->????? da Enchoice                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	RegToMemory("SZD",(nOpcx==3 .or. nOpcx==4 )) // Se for inclusao ou alteracao permite alterar o conteudo das variaveis de memoria

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria aHeader e aCols da GetDados                              ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nUsado:=0
	dbSelectArea("SX3")
	dbSetOrder(1)
	dbSeek("SZC")
	aHeader:={}
	//hfp While !Eof().And.(x3_arquivo=="SZC")
	While !Eof().And.(   SX3->(FIELDGET(FIELDPOS("X3_ARQUIVO"))) == "SZC") //hfp
		/*
		If Alltrim(x3_campo)=="C6_ITEM"
		dbSkip()
		Loop
		Endif
	*/
		If X3USO(SX3->(FIELDGET(FIELDPOS("X3_USADO")))).And. cNivel >= SX3->(FIELDGET(FIELDPOS("X3_NIVEL")))
			nUsado:=nUsado+1
			Aadd(aHeader,{ ;
				TRIM(SX3->(FIELDGET(FIELDPOS("X3_TITULO")))),;
				SX3->(FIELDGET(FIELDPOS("X3_CAMPO"))),;
				SX3->(FIELDGET(FIELDPOS("X3_PICTURE"))),;
				SX3->(FIELDGET(FIELDPOS("X3_TAMANHO"))),;
				SX3->(FIELDGET(FIELDPOS("X3_DECIMAL"))),;
				"AllwaysTrue()",;
				SX3->(FIELDGET(FIELDPOS("X3_USADO"))), SX3->(FIELDGET(FIELDPOS("X3_TIPO"))),;
				SX3->(FIELDGET(FIELDPOS("X3_ARQUIVO"))),;
				SX3->(FIELDGET(FIELDPOS("X3_CONTEXT"))) } )
		Endif
		dbSkip()
	End

	If nOpcx==3 // Incluir
		aCols:={Array(nUsado+1)}
		aCols[1,nUsado+1]:=.F.
		For nX:=1 to nUsado
			aCols[1,nX]:=CriaVar(aHeader[nX,2])
		Next
	Else
		aCols:={}
		dbSelectArea("SZC")
		dbSetOrder(1)
		dbSeek(xFilial()+M->ZD_IDTRAN)
		While !eof() .and. ZC_IDTRAN == M->ZD_IDTRAN .and. ZC_FILIAL == M->ZD_FILIAL
			AADD(aCols,Array(nUsado+1))
			For nX:=1 to nUsado
				aCols[Len(aCols),nX]:=FieldGet(FieldPos(aHeader[nX,2]))
			Next
			aCols[Len(aCols),nUsado+1]:=.F.
			dbSkip()
		End
	Endif

	If Len(aCols)>0
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Executa a Modelo 3                                           ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		aCposE := {"ZD_IDTRAN", "ZD_STATUS", "ZD_LOTE", "ZD_SUBLOTE", "ZD_DOCTO", "ZD_DTINC", "ZD_HRINC", "ZD_DTPROC", "ZD_HRPROC", "ZD_USRPRO","ZD_ANOMES"}

		lRetMod3 := Modelo3(cTitulo, cAliasE, cAliasG, aCposE, cLinOk, cTudOk,;
			nOpcE, nOpcG,cFieldOk)
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Executar processamento                                       ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lRetMod3
			Aviso("Modelo3()","Confirmada operacao!",{"Ok"})
		Endif
	Endif

Return


//-------------------------------------------------------------------
/*{Protheus.doc} AL03CTBP
Rotina de Procesamento ou Estorno dos Movimentos Contabeis

@author Guilherme Santos
@since 04/10/2016
@version P12
*/
//-------------------------------------------------------------------
User Function AL03CTBP(nOpcao)
	Local aArea		:= GetArea()
	Local cFilBkp		:= cFilAnt
	Local cPerg		:= "U_ALCTBA02"
	Local cQuery		:= ""
	Local cTabQry		:= GetNextAlias()
	Local lRetorno	:= .T.

	Private _cFileLog
	Private _cLogPath
	Private _Handle

	//AjustaSX1()

	If MsgYesNo("Esta Rotina efetuará o " + If(nOpcao == 6, "Processamento", "Cancelamento") + " dos Movimentos Contábeis. Confirma a Execução?")

		If Pergunte(cPerg, .T.)

			cQuery += " SELECT 	SZD.ZD_FILIAL, " + CRLF
			cQuery += "			SZD.ZD_IDTRAN" + CRLF
			cQuery += " FROM 		"+RetSqlName("SZD")+" SZD" + CRLF
			cQuery += " WHERE 		SZD.ZD_FILIAL BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "'" + CRLF
			cQuery += " AND		SZD.ZD_IDTRAN BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "'" + CRLF

			IF VALTYPE(MV_PAR05) == "N"
				MV_PAR05 := ALLTRIM(STR(MV_PAR05))
			ENDIF

			cQuery += " AND		SZD.ZD_SISTEMA = '" + MV_PAR05 + "' " + CRLF

			Do Case
			Case nOpcao == 6
				cQuery += "AND		SZD.ZD_STATUS <> '2'" + CRLF
			Case nOpcao == 7
				cQuery += "AND		SZD.ZD_STATUS <> '1'" + CRLF
			EndCase

			cQuery += "AND		SZD.D_E_L_E_T_ = ''" + CRLF

			MemoWrite(GetTempPath(.T.) + "AL03CTBP.SQL", cQuery)


			cQuery := ChangeQuery(cQuery)

			DbUseArea(.T., "TOPCONN", TcGenQry(NIL, NIL, cQuery), cTabQry, .T., .T.)

			IF nOpcao == 6
				fGrvLog(1,"Iniciando gravação de Log. "+TIME()+". "+ DToC(ddatabase)  )
			ENDIF

			While !(cTabQry)->(Eof())
				DbSelectArea("SZD")
				DbSetOrder(1)		//ZD_FILIAL, ZD_IDTRAN

				If SZD->(DbSeek((cTabQry)->ZD_FILIAL + (cTabQry)->ZD_IDTRAN))

					cFilAnt := (cTabQry)->ZD_FILIAL

					Do Case
					Case nOpcao == 6
						//Contabilizacao
						//						U_AL03GRAV(6, (cTabQry)->ZD_IDTRAN)	// Alterado Aleluia 271016
						Processa({|lEnd| U_AL03GRAV(6, (cTabQry)->ZD_FILIAL, (cTabQry)->ZD_IDTRAN)},"Contabilizando","Aguarde Contabilizando ...",.F.) 	// Alterado Aleluia 271016

					Case nOpcao == 7
						//Exclui
						//						FEDelCtb((cTabQry)->ZD_FILIAL, (cTabQry)->ZD_IDTRAN)	// Alterado Aleluia 271016
						Processa({|lEnd| FEDelCtb((cTabQry)->ZD_FILIAL, (cTabQry)->ZD_IDTRAN)},"Excluindo contabilização","Aguarde fazendo favor ...",.F.)	// Alterado Aleluia 271016

					EndCase
				EndIf

				(cTabQry)->(DbSkip())
			End

			IF nOpcao == 6
				fGrvLog(3,"Fim da Gravação . "+TIME()+". "+ DToC(ddatabase))
			ENDIF

		EndIf
	EndIf

	If Select(cTabQry) > 0
		(cTabQry)->(DbCloseArea())
	EndIf

	RestArea(aArea)
	cFilAnt := cFilBkp

	MsgInfo("Fim do processamento!")

Return lRetorno

User Function TST_CTBT()
	U_AL03GRAV(6, "00101MG0002", "201901000001")
Return()

//-------------------------------------------------------------------
/*{Protheus.doc} AL02GRAV
Gravacao da Contabilizacao ou do Estorno

@author Guilherme Santos
@since 04/10/2016
@version P12
*/
//-------------------------------------------------------------------
User Function AL03GRAV(nOpcao, cfiltr ,cIDTran)
	Local cArquivo	:= ""
	Local cCTBSen	:= SuperGetMV("ES_CTBSEN", .F., "511")		//Lancamento Contabil para a Integracao com o Senior
	Local cLote		:= ""
	Local cSeek		:= ""
	Local nHdlPrv	:= 0
	Local nTotal	:= 0
	Local lAglut	:= .F.
	Local lDigita	:= .F.
	Local lRetorno 	:= .T.
	Local nCont		:= 0
	Local nTotReg	:= 0
	Local nRec		:= 0
	Local cDocCtf	:= ""

	Local aCab      := {}
	Local aItem     := {}
	Local aItAux    := {}
	Local aLinha    := {}
	Local cMsgErro	:= ""
	Local nTotErr	:= 0
	Local nTtAcer	:= 0

	Local aRet	:= { .F.,""}
	Local aRetAux	:= {}
	Local cRetAux	:= ""

	Local cQryAtu	:= ""
	Local dDBaseAnt	:= ""

	Private lMsErroAuto     := .F.
	Private lMsHelpAuto     := .T.
	Private CTF_LOCK        := 0
	Private lSubLote        := .T.

	DbSelectArea("SZC")
	SZC->(DbSetOrder(1))		//ZC_FILIAL, ZC_IDTRAN
	SZC->(DBGOTOP())

	If SZC->(DbSeek(cfiltr + cIDTran))


		// Guarda a RECNO do registro
		nRec := SZC->( RECNO() )

//		// Conta quantos registros serão processados
//		While !SZC->(Eof()) .AND. cfiltr + cIDTran == SZC->ZC_FILIAL + SZC->ZC_IDTRAN			
//			nTotReg ++
//			SZC->( dbSkip() )		
//		enddo

		// Define tamanho da régua de processamento
//		ProcRegua(nTotReg)

		// Vai para o incio da tabela
		SZC->( dbGoTop() )

		// Posiciona o registro novamente
		SZC->( dbGoTo( nRec ) )

		DBSELECTAREA("SZD")
		SZD->(DBSETORDER(1)) //|
		IF SZD->(DBSEEK(SZC->ZC_FILIAL+SZC->ZC_IDTRAN))

			IF ALLTRIM(SZD->ZD_SISTEMA) $ "1|2" //| GESPLAN |
				cLote	:= ALLTRIM(SZD->ZD_LOTE)
			ELSE

				//Busca lote contabil
				SX5->(dbSetOrder(1)) //X5_FILIAL+X5_TABELA+X5_CHAVE
				If SX5->(MsSeek(xFilial("SX5") + "09PLE"))
					cLote := AllTrim(X5Descri())
				Else
					cLote := "PLE "
				EndIf

				//Executa um execblock
				If At(UPPER("EXEC"),X5Descri()) > 0 .OR. At(Upper("U_"),SX5->(FIELDGET(FIELDPOS("X5_DESCRI")))) > 0
					cLote	:= &(X5Descri())
				EndIf

			ENDIF
		ENDIF

		cSeek 		:= SZC->ZC_FILIAL + Substr(DtoS(SZC->ZC_DTLANC), 1, 6)
		cArquivo	:= ""
		nTotal		:= 0

		Begin Transaction

			DBSELECTAREA("CT1")
			CT1->(DBSETORDER(1))

			DBSELECTAREA("CTF")
			CTF->(DBSETORDER(1))

			cQryAtu += " SELECT ZC_FILIAL, "+ CRLF
			cQryAtu += " 	ZC_DTLANC , "+ CRLF
			cQryAtu += " 	ZC_TIPO   , "+ CRLF
			cQryAtu += " 	ZC_CTACRD , "+ CRLF
			cQryAtu += " 	ZC_CTADEB , "+ CRLF
			cQryAtu += " 	ZC_CCD    , "+ CRLF
			cQryAtu += " 	ZC_CCC    , "+ CRLF
//			cQryAtu += " 	ZC_IDSEN  , "+ CRLF
			cQryAtu += " 	ZC_IDTRAN , "+ CRLF
			cQryAtu += " 	ZC_STATUS , "+ CRLF
			cQryAtu += " 	ZC_TPREG  ,	"+ CRLF

			IF ALLTRIM(SZD->ZD_SISTEMA) == "3"//|Pleres|
				cQryAtu += " 	SUM(ZC_VALOR) AS ZC_VALOR, "+ CRLF
				cQryAtu += " 	SUM(ZC_VLRACUM) AS ZC_VLRACUM "+ CRLF
			ELSE
				cQryAtu += " 	ZC_VALOR , "+ CRLF
				cQryAtu += " 	ZC_VLRACUM, "+ CRLF
				cQryAtu += " 	ZC_HIST, "+ CRLF
				cQryAtu += " 	R_E_C_N_O_ AS RECSZC  "+ CRLF
			ENDIF

			cQryAtu += " FROM "+Retsqlname("SZC")+" "+ CRLF

			cQryAtu += " WHERE D_E_L_E_T_ = '' "+ CRLF
			cQryAtu += " 	AND ZC_FILIAL = '"+ cfiltr +"' "+ CRLF
			cQryAtu += " 	AND ZC_IDTRAN = '"+ cIDTran +"' "+ CRLF
			cQryAtu += " 	AND ZC_STATUS  = '1' "+ CRLF

			IF ALLTRIM(SZD->ZD_SISTEMA) == "3"//|Pleres|
				cQryAtu += " GROUP BY ZC_FILIAL,  "+ CRLF
				cQryAtu += " 	ZC_DTLANC ,  "+ CRLF
				cQryAtu += " 	ZC_TIPO   ,  "+ CRLF
				cQryAtu += " 	ZC_CTADEB , "+ CRLF
				cQryAtu += " 	ZC_CTACRD , "+ CRLF
				cQryAtu += " 	ZC_CCD    , "+ CRLF
				cQryAtu += " 	ZC_CCC    , "+ CRLF
				//			cQryAtu += " 	ZC_IDSEN  , "+ CRLF
				cQryAtu += " 	ZC_IDTRAN , "+ CRLF
				cQryAtu += " 	ZC_STATUS,	"+ CRLF
				cQryAtu += " 	ZC_TPREG	"+ CRLF
			ENDIF

			If Select("QRYSZC") > 0
				QRYSZC->(DbCloseArea())
			EndIf

			MemoWrite(GetTempPath(.T.) + "AL03GRAV.SQL", cQryAtu)


			dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQryAtu),'QRYSZC')



			WHILE QRYSZC->(!EOF())
				nTotReg ++

				QRYSZC->(DBSKIP())
			ENDDO

			ProcRegua(nTotReg)

			QRYSZC->(DBGOTOP())

			dDtCont	:= STOD(QRYSZC->ZC_DTLANC)
			/*------------------------------------------------------ Augusto Ribeiro | 07/11/2019 - 7:27:43 PM
				Altera database para sistema pleres
			
			IF ALLTRIM(SZD->ZD_SISTEMA) == "3"
				dDBaseAnt	:= DDATABASE
				DDATABASE	:= STOD(QRYSZC->ZC_DTLANC)
			ENDIF
			------------------------------------------------------------------------------------------*/
			//Cabecalho da contabilizacao
			nHdlPrv	:= HeadProva(cLote, "ALCTBA02", Substr(cUserName, 1, 6), @cArquivo, .F.)
			
			
			While QRYSZC->(!Eof())
	
				nCont ++

				IncProc(LTRIM(TRANSFORM(nCont/nTotReg*100,"999")+"% Concluído..."))

				DBSELECTAREA("CT2")
				CT2->(DBSETORDER(1))

				aCab := {}
				
				//|Atribui Numero de documento com base no Lote|
				cDocCtf	:= xDocCTF(cfiltr, IIF( ALLTRIM(SZD->ZD_SISTEMA) == "3", STOD(QRYSZC->ZC_DTLANC), DDATABASE ), cLote, "001" )//STRZERO( seconds() ,6)
				
				
				Debito    := QRYSZC->ZC_CTADEB
				Credito   := QRYSZC->ZC_CTACRD

				IF ALLTRIM(SZD->ZD_SISTEMA) == "3"//|Pleres|
					IF QRYSZC->ZC_TPREG == "1"
						Historico := "RECEITA DE  PRODUCAO COMPETENCIA - " + SUBST(QRYSZC->ZC_IDTRAN,5,2) + " " + LEFT(QRYSZC->ZC_IDTRAN, 4) 
					ELSE
						Historico := UPPER(alltrim(X3COMBO("ZC_TPREG", QRYSZC->ZC_TPREG))) + " COMPETENCIA - " + SUBST(QRYSZC->ZC_IDTRAN,5,2) + " " + LEFT(QRYSZC->ZC_IDTRAN, 4)
					ENDIF
				ELSE
					Historico := UPPER(ALLTRIM(QRYSZC->ZC_HIST))
				ENDIF
				
				ItemD     := ""
				ItemC     := ""
				Valor     := QRYSZC->ZC_VALOR 
										
				/*----------------------------------------
					28/03/2019 - Jonatas Oliveira - Compila
					Valida se conta contabil permite CC
				------------------------------------------*/
				IF CT1->( DBSEEK( XFILIAL("CT1") + QRYSZC->ZC_CTADEB )) .AND. CT1->CT1_ACCUST == "1"
					CustoD    := QRYSZC->ZC_CCD
				ELSE
					CustoD    := ""	
				ENDIF
				
				IF CT1->( DBSEEK( XFILIAL("CT1") + QRYSZC->ZC_CTACRD )) .AND. CT1->CT1_ACCUST == "1"
					CustoC    := QRYSZC->ZC_CCC
				ELSE
					CustoC    := ""
				ENDIF
				
			DocSun    := ""

				nTotal += DetProva(nHdlPrv,cCTBSen,"LP0001",cLote) // Linha de Detalhe 		 
				
				QRYSZC->(DbSkip())
		EndDo
			
			
			//Rodape da contabilizacao
			RodaProva(nHdlPrv, nTotal)

			//cA100Incl(	cArquivo,nHdlPrv,nOpcx,cLoteContabil,lDigita,lAglut,cOnLine,;
					//     dData,dReproc,aFlagCTB,aDadosProva,aSeqDiario,aTpSaldo,lSimula,cTabCTK,cTabCT2)
			//cA100Incl(cCTBSen, nHdlPrv, 3, cLote, lDigita, .F.,,STOD("20190512"))
		IF ALLTRIM(SZD->ZD_SISTEMA) == "3"
				cA100Incl(cCTBSen, nHdlPrv, 3, cLote, lDigita, .F.,,dDtCont)
		ELSE
				cA100Incl(cCTBSen, nHdlPrv, 3, cLote, lDigita, .F.)
		ENDIF

			/*------------------------------------------------------ Augusto Ribeiro | 07/11/2019 - 7:29:12 PM
				Restaura data base
			
		IF ALLTRIM(SZD->ZD_SISTEMA) == "3"
				DDATABASE	:= dDBaseAnt
		ENDIF
			------------------------------------------------------------------------------------------*/

			//Atualiza o Status da SZD Apos a Gravacao dos Lancamentos
			RecLock("SZD", .F.)
				SZD->ZD_STATUS := "2"
				SZD->ZD_LOTE := cLote
				SZD->ZD_SUBLOTE := CT2->CT2_SBLOTE
				SZD->ZD_DOCTO := CT2->CT2_DOC
				SZD->ZD_DTPROC := dDataBase
				SZD->ZD_HRPROC := Left(time(), 5)
				SZD->ZD_USRPRO := cUserName
			MsUnlock()
			
			SZC->(DBGOTOP())
		If SZC->(DbSeek(cfiltr + cIDTran))
			WHILE SZC->(!EOF()) .AND. SZC->(ZC_FILIAL + ZC_IDTRAN) == QRYSZC->(ZC_FILIAL + ZC_IDTRAN)
				IF SZC->ZC_STATUS == "1"
					
						DBSELECTAREA("SZC")
						
						SZC->(RecLock("SZC",.F.))
							SZC->ZC_STATUS := "2"//|Sucesso|					
						SZC->(MsUnLock())
									
				ENDIF
					
					SZC->(DBSKIP())
			ENDDO
		Endif
		 	
	End Transaction
		
EndIf

Return lRetorno



//-------------------------------------------------------------------
/*{Protheus.doc} AjustaSX1
Ajuste das Perguntas no SX1

@author Guilherme Santos
@since 04/10/2016
@version P12


Static Function AjustaSX1()
	Local nXX		:= 0
	Local aPerg	:= {}
	Local cPerg	:= "U_ALCTBA02"

	Aadd(aPerg, {"Filial Inicial"		, "C", 11, 00, "G", "", "", "", "", "", "SM0"})
	Aadd(aPerg, {"Filial Final"			, "C", 11, 00, "G", "", "", "", "", "", "SM0"})

	Aadd(aPerg, {"ID Transacao Inicial" , "C", 30, 00, "G", "", "", "", "", "", ""})
	Aadd(aPerg, {"ID Transacao Final"	, "C", 30, 00, "G", "", "", "", "", "", ""})
	Aadd(aPerg, {"Sistema"				, "C", 30, 00, "C", "Gesplan", "Senior", "Pleres", "", "", ""})
	

	For nXX := 1 To Len(aPerg)
		If !SX1->(Dbseek(cPerg + StrZero(nXX, 2)))
			Reclock("SX1", .T.)
			SX1->X1_GRUPO 		:= cPerg
			SX1->X1_ORDEM			:= StrZero(nXX, 2)
			SX1->X1_VARIAVL		:= "mv_ch" + Chr(nXX + 96)
			SX1->X1_VAR01			:= "MV_PAR" + StrZero(nXX, 02)
			SX1->X1_PRESEL		:= 1
			SX1->X1_PERGUNT		:= aPerg[ nXX , 01 ]
			SX1->X1_TIPO 			:= aPerg[ nXX , 02 ]
			SX1->X1_TAMANHO		:= aPerg[ nXX , 03 ]
			SX1->X1_DECIMAL		:= aPerg[ nXX , 04 ]
			SX1->X1_GSC  			:= aPerg[ nXX , 05 ]
			SX1->X1_DEF01			:= aPerg[ nXX , 06 ]
			SX1->X1_DEF02			:= aPerg[ nXX , 07 ]
			SX1->X1_DEF03			:= aPerg[ nXX , 08 ]
			SX1->X1_DEF04			:= aPerg[ nXX , 09 ]
			SX1->X1_DEF05			:= aPerg[ nXX , 10 ]
			SX1->X1_F3   			:= aPerg[ nXX , 11 ]
			SX1->(MsUnlock())
		EndIf
	Next nXX

Return NIL
*/
//-------------------------------------------------------------------



//------------------------------------------------------------------- 
/*/{Protheus.doc} FEDelCtb
Deleta Contabilizacao

@author 	Alex T. de Souza
@since 	11/01/2016 
@version 	P11
@obs  
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------                             
Static Function FEDelCtb( cFil, cIdTran )
	Local aCab			:= {}
	Local aTotItem		:= {}
	Local cAlias		:= GetNextAlias()
	Local aArea			:= SZD->( GetArea() )
	Local aAreaSCZ		:= SCZ->( GetArea() )
	Local nTotReg		:= 0
	Local nCont			:= 0
	Local cMsgProc		:= ""
	Local lVldTps 	:= GETMV("MV_CTBCTG",.T.,.F.) // Habilita validação por amarração entre calendário x moeda x tipo de saldo
	Local lDataOk, cHelpDt
	Local aRetDel		:= { .T. , ""}

	Private lMsErroAuto := .F.

	CT2->( DbSetOrder(1) )
	SZD->( dbSetOrder(1) )
	SZC->( dbSetOrder(1) )

	cQry := " SELECT "+CRLF
	cQry += " R_E_C_N_O_ RECCT2 "+CRLF
	cQry += " FROM "+CRLF
	cQry += " "+RetSqlName("CT2")+" "+CRLF
	cQry += " WHERE "+CRLF
	cQry += " D_E_L_E_T_ = '' "+CRLF
	cQry += " AND CT2_FILIAL = '"+cFil+"' "+CRLF
	cQry += " AND CT2_ORIGEM = '"+cIdTran+"' "

	DbUseArea(.T., "TOPCONN", TcGenQry(NIL, NIL, cQry), cAlias, .T., .T.)

	MemoWrite(GetTempPath(.T.) + "FEDelCtb.SQL", cQry)

	// Conta os registros da consulta
	//	(cAlias)->( dbEval( {|| nTotReg ++ } ) )

	// Vai para o primeiro registro da consulta
	//	(cAlias)->( dbGoTop() )

	// Define o tamanho da régua
	ProcRegua( 1/*nTotReg*/ )

	//CtbValiDt(nOpc,dData,lHelp,cTpSaldo,lVldTps,aProcesso,cHelp)
	IF ! (cAlias)->( EOF() )
		CT2->(DBgoto( (cAlias)->RECCT2 ))
		lDataOk 	:= vldCalCtb(CT2->CT2_FILIAL, CT2->CT2_DATA)
	ELSE
		lDataOk := .T.
	ENDIF
	IF lDataOk

		while ! (cAlias)->( EOF() )

			nCont ++

			IncProc("Processando...")

			CT2->(DBgoto( (cAlias)->RECCT2 ))

			aCab		:= {}
			aTotItem	:= {}

			Pergunte("CTB102",.F.)
			//		cMsgProc := Ct102EstLt(5,CT2->CT2_DATA,CT2->CT2_LOTE,CT2->CT2_SBLOTE,CT2->CT2_DOC,CT2->CT2_VALOR)
			aRetDel := Ct102EstLt(5,CT2->CT2_DATA,CT2->CT2_LOTE,CT2->CT2_SBLOTE,CT2->CT2_DOC,CT2->CT2_VALOR)

			//		aCab := {;
				//					{"dDataLanc",CT2->CT2_DATA	,NIL},;
				//					{"cLote"	,CT2->CT2_LOTE	,NIL},;
				//					{"cSubLote"	,CT2->CT2_SBLOTE,NIL},;
				//					{"cDoc"		,CT2->CT2_DOC   ,NIL};
				//				}
			//
			////		Aadd(aTotItem, 	{;
				////						{"CT2_LINHA"	,CT2->CT2_LINHA		,NIL},;
				////						{"LINPOS"		,"CT2_LINHA"		,CT2->CT2_LINHA};
				////						})
			//
			//		aTotItem := {;
				//						{"LINPOS"		,"CT2_LINHA"		,CT2->CT2_LINHA},;
				//						{"AUTDELETA"	,"S"				,Nil };
				//					}
			//
			//
			////		MSExecAuto({|x,y,Z| Ctba102(x,y,Z)},aCab,aTotItem,5)
			//		MSExecAuto( {|X,Y,Z| CTBA102(X,Y,Z)} ,aCab ,aTotItem, 5)


			(cAlias)->( dbSkip() )

		EndDo
		//	ALERT(cMsgProc)
		If aRetDel[1] //empty(cMsgProc)

			if SZD->( MsSeek( cFil + cIdTran ) )
				Reclock( "SZD" , .F. )
				SZD->ZD_STATUS 	:= "1"
				//			SZD->ZD_LOTE 	:= ""
				//			SZD->ZD_SUBLOTE := ""
				SZD->ZD_DOCTO := ""
				SZD->ZD_DTPROC := CTOD("  /  /  ")
				SZD->ZD_HRPROC := ""
				SZD->ZD_USRPRO := ""
				SZD->(MsUnlock())
			endif

			SZC->(DBGOTOP())

			IF SZC->(DBSEEK(cFil + cIdTran))
				WHILE SZC->(!EOF()) .AND. cFil + cIdTran == SZC->(ZC_FILIAL + ZC_IDTRAN)
					SZC->(RecLock("SZC",.F.))
					SZC->ZC_STATUS := "1"
					SZC->(MsUnLock())

					SZC->(DBSKIP())
				ENDDO
			ENDIF

		Endif

		RestArea( aAreaSCZ )
		RestArea( aArea )
	ELSE
		FwHelpShow("CTB","CTB","Calendario Contabil não esta aberto.","Abrir o calendário contábil antes de executar esta operação.")

	Endif

	RestArea( aAreaSCZ )
	RestArea( aArea )

	if select(cAlias) > 0
		(cAlias)->( dbCloseArea() )
	endif

Return()


/*/{Protheus.doc} ALCTBIMP
Importação dos dados contábeis do Pleres
@author Fabio Sales | www.compila.com.br
@since 31/10/2018
@version version
@see (links_or_references)
/*/

USER FUNCTION ALCTBIMP()

	Begin transaction

		Processa({||ALCTBIMP()}, "[ IMPORTANDO CONTABILIZAÇÃO ]"+CRLF, "Chamando Tela de parâmetros ...", .T. )

	End Transaction

RETURN(.T.)



/*/{Protheus.doc} ALCTBIMP
Importação dos dados contábeis do Pleres
@author Fabio Sales | www.compila.com.br
@since 31/10/2018
@version version
@see (links_or_references)
/*/

STATIC FUNCTION ALCTBIMP()

	Local cPerg		:= "ALCTBIMP"
	Local nMes		:= 0
	Local clUser	:= "" // GetMV("AL_APIPUSR",.f.,"fluig")
	Local clPassword:= "" // GetMV("AL_APIPPAS",.f.,"12345")
	Local clURL		:= "" // GetMV("AL_APIPLER",.f.,"http://35.199.77.179:8081")
	Local clPath	:= "/api/relatorios/Producaocontabil"
	Local aHeader 	:= {}
	Local oJson		:= Nil
	Local aFilSel, nI, nY, nJ
	Local nPerISS		:= 0
	Local nPerCOF		:= 0
	Local nPerPIS		:= 0
	Local nPerGlosa		:= 0
	Local cCtaCred		:= ""
	Local cCtaDeb		:= ""
	Local cCCustD		:= ""
	Local cCCustC		:= ""
	Local cExistD		:= ""
	Local aExistD		:= {}
	Local cDomAux		:= ""
	Local cIDSen		:= ""

	Local nTotMes	:= 0
	Local nTotAcu	:= 0

	Local _cCnpj		:= ""
	Local _cMsgVaz		:= ""
	Local cDtIni		:= ""
	Local cCodEsp		:= ""
	Local _cCnpjA		:= ""
	Local cLote			:= ""
	Local clDominio		:= ""
	Local cCCGlosa		:= ""
	Local cCDGlosa		:= ""
	Local cCTCGlos		:= ""
	Local cCTDGlos		:= ""

	Local cCCPIS		:= ""
	Local cCDPIS		:= ""
	Local cCTPISC		:= ""
	Local cCTPISD		:= ""

	Local cCCCOF		:= ""
	Local cCDCOF		:= ""
	Local cCTCOFC		:= ""
	Local cCTCOFD		:= ""

	Local cCCISS		:= ""
	Local cCDISS		:= ""
	Local cCTISSC		:= ""
	Local cCTISSD		:= ""

	nTotSZD			:= SZD->(FCOUNT())
	nTotSZC			:= SZC->(FCOUNT())

	CreateSx1(cPerg)

	IF Pergunte(cPerg,.T.,"IMPORTAÇÃO DA CONTABILIZAÇÃO PRODUÇÃO PLERES")


		/*------------------------------------------------------ 
		Retorna Filiais para Processamento
		----------------------------------------------------------*/
		aFilSel	:= MultFil() 

		IF !empty(aFilSel)


			//| Ordena Array |
			aSort(aFilSel,,,{ |x,y| x[1] < y[1]})

			/*------------------------------------------------------ Augusto Ribeiro | 20/11/2018 - 4:39:45 PM
			For para buscar parametro por Filial
			------------------------------------------------------------------------------------------*/
			DBSELECTAREA("SZD")
			SZD->(DBSETORDER(3)) //| ZD_FILIAL + ZD_ANOMES

			//| Verifica se existe a competência importada para o domínio em questão.						


				For nY := 1 to Len(aFilSel)
				cDomAux := ""
				/*----------------------------------------
					25/06/2019 - Jonatas Oliveira - Compila
					Busca o Dominio no Cadastro de Empresas
					Customizado
				------------------------------------------*/
				DBSELECTAREA("SZK")
				SZK->(DBSETORDER(1)) //| 
					IF SZK->( DBSEEK( SM0->M0_CODIGO + aFilSel[nY,1] ))
						IF !EMPTY(SZK->ZK_XCODDOM)
						
						cDomAux	:= ALLTRIM(POSICIONE("SX5",1,XFILIAL("SX5")+"ZL"+SZK->ZK_XCODDOM ,"X5_DESCRI"))
						ConOut("ALCTBA03 - Dominio SZK 2 - "+ cDomAux + " Filial " + aFilSel[nY,1])
						ENDIF
					ENDIF
				
					IF EMPTY(cDomAux)
					cDomAux	:= SuperGetMv("AL_APIPDOM",.F.,"", aFilSel[nY,1])
					ConOut("ALCTBA03 - Dominio Parametro 2 - "+ cDomAux + " Filial " + aFilSel[nY,1])
					ENDIF
				 
					IF SZD->(DBSEEK(MV_PAR01 + cDomAux ))

						IF EMPTY(cExistD)
						cExistD := cDomAux
						ELSE
							If !(cDomAux $ cExistD )
							cExistD += ";" + cDomAux
							Endif
						ENDIF

					ENDIF

				cDomAux := ""
				Next nY

				IF !EMPTY(cExistD)
				aExistD := STRTOKARR( cExistD , ";" )

				clMsg:= "A competência " + MV_PAR01 + " já existe para o domínio abaixo " //+ clDominio
				clMsg+= ", Deseja reimportar para as filiais que estão com status pendente?" + CRLF

					For nW := 1 To  Len(aExistD)
					clMsg += aExistD[nW] + CRLF
					Next nW

					IF  AVISO("Já existe",clMsg,{"Sim","Não"}, 3, ,, , .T.,  ) == 2
					Return(.T.)									
					ENDIF

				ENDIF

				FOR nY := 1 to LEN(aFilSel)
				clDominio := ""

				/*------------------------------------------------------ Augusto Ribeiro | 21/11/2018 - 9:20:53 AM
				Busca os parametros da Filial
				------------------------------------------------------------------------------------------*/
				clUser		:= SuperGetMv("AL_APIPUSR",.f.,"fluig", aFilSel[nY,1])
				clPassword	:= SuperGetMv("AL_APIPPAS",.f.,"12345", aFilSel[nY,1])
				clURL		:= SuperGetMv("AL_APIPLER",.f.,"http://35.199.77.179:8081", aFilSel[nY,1])	
				
				/*----------------------------------------
					25/06/2019 - Jonatas Oliveira - Compila
					Busca o Dominio no Cadastro de Empresas
					Customizado
				------------------------------------------*/
				DBSELECTAREA("SZK")
				SZK->(DBSETORDER(1)) //| 
					IF SZK->( DBSEEK( SM0->M0_CODIGO + aFilSel[nY,1] ))
						IF !EMPTY(SZK->ZK_XCODDOM)
						clDominio	:= ALLTRIM(POSICIONE("SX5",1,XFILIAL("SX5")+"ZL"+SZK->ZK_XCODDOM ,"X5_DESCRI"))
						ConOut("ALCTBA03 - Dominio SZK 1 - "+ clDominio + " Filial " + aFilSel[nY,1])
						ENDIF
					ENDIF
				
					IF EMPTY(clDominio)
					
					clDominio	:= SuperGetMv("AL_APIPDOM",.F.,"", aFilSel[nY,1] )
					ConOut("ALCTBA03 - Dominio Parametro 1 - "+ clDominio+ " Filial " + aFilSel[nY,1])
					ENDIF
				
				nPerGlosa 	:= SuperGetMv("AL_PLEPGLO",.f.,0, aFilSel[nY,1])
				nPerISS		:= SuperGetMv("AL_PLEPISS",.f.,0, aFilSel[nY,1])
				nPerCOF		:= SuperGetMv("AL_PLEPCOF",.f.,0, aFilSel[nY,1])
				nPerPIS		:= SuperGetMv("AL_PLEPPIS",.f.,0, aFilSel[nY,1])	
				
					IF EMPTY(clDominio)
					_cMsgVaz += " Dominio vazio [AL_APIPDOM] na filial " + aFilSel[nY,1] + CRLF
					LOOP 
					ENDIF


				
				DBSELECTAREA("SZK")
				SZK->(DBSETORDER(1))
				
				//| Validações básicas do Parâmetro.			
					IF !EMPTY(MV_PAR01) .AND. LEN(ALLTRIM(MV_PAR01)) == 6

					nMes	:= VAL(Right(MV_PAR01,2))

						IF nMes > 0 .AND.  nMes < 13
						cDtIni 	:= "01" + "/" + Right(MV_PAR01,2) + "/" + Left(MV_PAR01,4)

						//					dtIni	:= "01" + "/" + Right(MV_PAR01,2) + "/" + Left(MV_PAR01,4)	
						dtIni	:= Left(MV_PAR01,4) + "-" + Right(MV_PAR01,2) + "-01"  	

						//					dtFim	:= Left(dtoc(LastDay(ctod(dtIni))),2)								
						//					dtFim	:= dtFim + "/" + Right(MV_PAR01,2) + "/" + Left(MV_PAR01,4)
						dtFim	:= Left(MV_PAR01,4) + "-" + Right(MV_PAR01,2) + "-" + Left(dtoc(LastDay(ctod(cDtIni))),2)

						aHeader	:= {}			
						Aadd(aHeader, "dominio: " + clDominio)	
						Aadd(aHeader, "usuario: " + clUser)
						Aadd(aHeader, "senha: " + clPassword )

							IF !EMPTY(MV_PAR02)
							//						Aadd(aHeader, "cnpj: " + Transform(MV_PAR02, PesqPict("SA1","A1_CGC") ) )
							_cCnpj 	:= ',"cnpj": ' + '"' + Transform(MV_PAR02, PesqPict("SA1","A1_CGC") ) + '"'
							ELSE
								IF SZK->(DBSEEK("01" + ALLTRIM(aFilSel[nY,1]) ))
								_cCnpj 	:= ',"cnpj": ' + '"' + Transform(SZK->ZK_CGC, PesqPict("SA1","A1_CGC") ) + '"'
								ENDIF
							ENDIF
						
						
						/*
							IF !EMPTY(MV_PAR03) .AND. EMPTY(MV_PAR02)
								IF SZK->(DBSEEK("01" + ALLTRIM(aFilSel[nY,1]) ))
								_cCnpj 	:= ',"cnpj": ' + '"' + Transform(SZK->ZK_CGC, PesqPict("SA1","A1_CGC") ) + '"' 
//							ELSE 
//								_cCnpj 	:= ',"cnpjraiz": ' + '"' + Transform(ALLTRIM(MV_PAR03), "@R 99.999" ) + '"'
								ENDIF
							//						Aadd(aHeader, "cnpjraiz: " + Transform(MV_PAR02, Transform(SE2->E2_DECRESC,"@E 99.999.999") ) )
							ENDIF
						*/

							//| ### Adicionar aqui o CNPJ conforme parametro nov a ser criado no Pleres |
							cParGet	:= 'parametros: {"dt_inicio":"'+ dtIni +'","dt_fim":"' + dtFim  + '"' + _cCnpj + '}'
							ConOut("ALCTBIMP - Header " + cParGet)
							Aadd(aHeader, cParGet)


						/*------------------------------------------------------ Augusto Ribeiro | 10/05/2019 - 2:50:10 PM
							Retry de 5 tentativas com intervalo de 3 seguntos entre elas
						------------------------------------------------------------------------------------------*/
							FOR nR := 1 to 5
							
							
							ConOut("ALCTBIMP - URL " + clURL)
							ConOut("ALCTBIMP - Path " + clPath)
							
							olJsonGet := FWRest():New(clURL)
							olJsonGet:nTimeOut 	 := 600
							
							olJsonGet:setPath(clPath)
						
							alret	:= {.f.,""}
								IF olJsonGet:Get(aHeader)
								alret[1] := .T.
								alret[2] := olJsonGet:GetResult()
								EXIT
								ELSE
								alret[2] := olJsonGet:GetLastError()
								ConOut("ALCTBIMP - Erro " + alret[2])
								MsgRun("Tentativa "+alltrim(str(nR))+" "+clDominio+" "+_cCnpj, "Retray",{||SLEEP(3000)})
								ENDIF
							NEXT NR
						
						
						//|Faz a chamada da API					
						//alRet := U_ALJSGET(clURL,aHeader,clPath)
							IF !(alret[1])
							CONOUT("ALCTBIMP", alret[2])
							ENDIF

							IF alret[1]

							clJson	:= alRet[2]

							//|Simulação de um volume maior de dados e com retorno de filiais diferentes. 
							//|clJson := '[{"CNPJ":"42.771.949/0001-35","NOME_EMPRESA":"AXIAL","DATA_REFERENCIA":"2018-11-06T02:12:25.923","COD_ESPECIALIDADE":"22","ESPECIALIDADE":"TESTE SALES","VALOR_PRODUCAO_MES":null,"VALOR_PRODUCAO_ACUMULADO":null},{"CNPJ":"42.771.949/0001-35","NOME_EMPRESA":"AXIAL","DATA_REFERENCIA":"2018-11-06T02:12:25.923","COD_ESPECIALIDADE":"21","ESPECIALIDADE":"RESSONANCIA 4","VALOR_PRODUCAO_MES":null,"VALOR_PRODUCAO_ACUMULADO":null},{"CNPJ":"42.771.949/0001-35","NOME_EMPRESA":"AXIAL","DATA_REFERENCIA":"2018-11-06T02:12:25.923","COD_ESPECIALIDADE":"29","ESPECIALIDADE":"RESSONANCIA 25354","VALOR_PRODUCAO_MES":100,"VALOR_PRODUCAO_ACUMULADO":100},{"CNPJ":"42.771.949/0002-16","NOME_EMPRESA":"AXIAL","DATA_REFERENCIA":"2018-11-06T02:12:25.923","COD_ESPECIALIDADE":"21","ESPECIALIDADE":"RESSONANCIA","VALOR_PRODUCAO_MES":null,"VALOR_PRODUCAO_ACUMULADO":null},{"CNPJ":"42.771.949/0002-16","NOME_EMPRESA":"AXIAL","DATA_REFERENCIA":"2018-11-06T02:12:25.923","COD_ESPECIALIDADE":"21","ESPECIALIDADE":"RESSONANCIA","VALOR_PRODUCAO_MES":250,"VALOR_PRODUCAO_ACUMULADO":null},{"CNPJ":"42.771.949/0016-11","NOME_EMPRESA":"AXIAL","DATA_REFERENCIA":"2018-11-06T02:12:25.923","COD_ESPECIALIDADE":"21","ESPECIALIDADE":"RESSONANCIA","VALOR_PRODUCAO_MES":null,"VALOR_PRODUCAO_ACUMULADO":null},{"CNPJ":"70.943.550/0001-20","NOME_EMPRESA":"AXIAL","DATA_REFERENCIA":"2018-11-06T02:12:25.923","COD_ESPECIALIDADE":"21","ESPECIALIDADE":"RESSONANCIA","VALOR_PRODUCAO_MES":null,"VALOR_PRODUCAO_ACUMULADO":null}]'

								IF FWJsonDeserialize(clJson,@oJson)

								alJson := {}


								clFil:= ""

								ProcRegua(Len(oJson))	

									For nI:= 1 To Len(oJson) step 1

									IncProc("Analisando competência para o Domínio "+ clDominio +"... ")

									clCnpj := strtran(strtran(strtran(oJson[nI]:cnpj,"/",""),".",""),"-","")

									//| Pega as filiais para exclusão

									DBSELECTAREA("SM0")								
									aAreaSM0 := SM0->(GetArea())	
									SM0->(DBGOTOP())  

										IF aScan(aFilSel	, {|x| Alltrim(x[3]) == Alltrim(clCnpj) })  > 0

											WHILE SM0->(!EOF())

												IF ALLTRIM(clCnpj) == ALLTRIM(SM0->M0_CGC)
												//										AADD(alJson,{oJson[nI]:cnpj, oJson[nI]:NOME_UNIDADE,oJson[nI]:DATA_REFERENCIA,oJson[nI]:COD_ESPECIALIDADE,oJson[nI]:ESPECIALIDADE,oJson[nI]:VALOR_PRODUCAO_MES,oJson[nI]:VALOR_PRODUCAO_ACUMULADO,SM0->M0_CODFIL})

												AADD(alJson,{ 	oJson[nI]:cnpj,; 
																oJson[nI]:NOME_UNIDADE,;
																oJson[nI]:DATA_REFERENCIA,;
																IIF(VALTYPE(oJson[nI]:COD_ESPECIALIDADE) == "N",STR( oJson[nI]:COD_ESPECIALIDADE ), oJson[nI]:COD_ESPECIALIDADE),;
																oJson[nI]:NOME_ESPECIALIDADE,;
																oJson[nI]:VALOR_PRODUCAO_TOTAL,;
																oJson[nI]:VALOR_PRODUCAO_ACUMULADA,;
																SM0->M0_CODFIL })

												//										AADD( alJson,{ oJson[nI]:cnpj,; 
												//													   oJson[nI]:NOME_UNIDADE,;
												//													   oJson[nI]:DATA_REFERENCIA,;
												//													   oJson[nI]:COD_ESPECIALIDADE,;
												//													   oJson[nI]:ESPECIALIDADE,;
												//													   oJson[nI]:VALOR_PRODUCAO_TOTAL,;
												//													   SM0->M0_CODFIL })

													IF EMPTY(clFil)
													clFil += "('" + SM0->M0_CODFIL + "'"
													ELSE
													clFil += ",'" + SM0->M0_CODFIL + "'"
													ENDIF

												EXIT										
												ENDIF

											SM0->(DBSKIP())
											ENDDO
										ENDIF
									RestArea(aAreaSM0)

									Next nI

									IF !EMPTY(clFil)
									clFil += ")"
									ELSE
									clFil := "('')"
									ENDIF
								//| Ordena o Array por filial e especialidade

								ASORT(alJson, , , { | x,y | x[PLERES_CNPJ] + x[PLERES_COD_ESPECIAL]  < y[PLERES_CNPJ] + y[PLERES_COD_ESPECIAL]} )																		

								//| Verifica se já existe a competencia importada para este domínio.

								DBSELECTAREA("SZD")
								SZD->(DBSETORDER(3)) //| ZD_FILIAL + ZD_ANOMES

								//| Verifica se existe a competência importada para o domínio em questão.						

									IF SZD->(DBSEEK(MV_PAR01 + clDominio))

									Processa({||Exclui(MV_PAR01,clDominio,clFil)}, "[EXCLUSÃO DE COMPETÊNCIA]"+CRLF, "Excluindo competências pendentes ...", .T. )

									ENDIF

								//| realiza a Importação.

								clCGC := ""							
								ProcRegua(Len(alJson))	
								nTotMes	:= 0
								nTotAcu	:= 0
								cIdTrans	:=  MV_PAR01 + "000000"

									IF LEN(alJson) > 0
										For nJ := 1 To Len(alJson)



										cCtaCred		:= ""
										cCtaDeb			:= ""
										cCCustC			:= ""
										cCCustD			:= ""

										IncProc("Importando dados contábeis... ")
										/*---------------------------------------
										Realiza a TROCA DA FILIAL CORRENTE 
										-----------------------------------------*/
										_cCodEmp 	:= SM0->M0_CODIGO
										_cCodFil	:= SM0->M0_CODFIL
										_cFilNew	:= ALLTRIM(alJson[nJ,PLERES_FILIAL] )//| CODIGO DA FILIAL DE DESTINO 

											IF _cCodEmp+_cCodFil <> _cCodEmp+_cFilNew
											CFILANT := _cFilNew
											opensm0(_cCodEmp+CFILANT)
											ENDIF

											IF clCGC <> alJson[nJ,PLERES_FILIAL]
											cIDSen := STRZERO(0,TAMSX3("ZC_IDSEN")[1])

											DBSELECTAREA("SZD")
											SZD->(DBSETORDER(2))

												IF SZD->(!DBSEEK(ALLTRIM(alJson[nJ,PLERES_FILIAL] ) + MV_PAR01))

												nIDSen := 0

												RegToMemory("SZD", .T., .F.)

												M->ZD_FILIAL	:= alJson[nJ,PLERES_FILIAL]
												M->ZD_IDTRAN	:= SOMA1(cIdTrans)
												M->ZD_DTINC		:= dDatabase
												M->ZD_HRINC		:= Time()
												M->ZD_DOMINIO	:= clDominio
												M->ZD_ANOMES	:= MV_PAR01
												M->ZD_SISTEMA	:= "3"
												
												//Busca lote contabil
												SX5->(dbSetOrder(1)) //X5_FILIAL+X5_TABELA+X5_CHAVE
													If SX5->(MsSeek(xFilial("SX5") + "09PLE"))
													cLote := AllTrim(X5Descri())
													Else
													cLote := "PLE "
													EndIf
								
												//Executa um execblock			
													If At(UPPER("EXEC"),X5Descri()) > 0 .OR. At(Upper("U_"),SX5->(FIELDGET(FIELDPOS("X5_DESCRI")))) > 0
													cLote	:= &(X5Descri())
													EndIf

												M->ZD_LOTE	:= cLote
												
												RecLock("SZD", .T.)

													For nI := 1 To nTotSZD
													cNameCpo	:= ALLTRIM(SZD->(FIELDNAME(nI)))
													FieldPut(nI, M->&(cNameCpo) )
													Next nI

												SZD->(MsUnLock())

												ConfirmSx8()

												llItens := .T.

												ELSE

												llItens := .F.

												ENDIF

											ENDIF

											//| Verifica se deve gravar os itens.
											//										IF llItens	

											/*----------------------------------------
												02/01/2019 - Jonatas Oliveira - Compila
												Busca contas de Credito e Debito na 
												tabela Especialidade Conta Contabil
												------------------------------------------
											*/
											DBSELECTAREA("Z07")
											Z07->(DBSETORDER(1))

											IF Z07->(DBSEEK(XFILIAL("Z07") + ALLTRIM(alJson[nJ, PLERES_COD_ESPECIAL])))

												cCtaCred		:= Z07->Z07_CREDIT
												cCtaDeb			:= Z07->Z07_DEBITO

												cCCustC			:= Z07->Z07_CCC
												cCCustD			:= Z07->Z07_CCD
											ELSE
												cCtaCred		:= PLERES_ZC_CTADEB
												cCtaDeb			:= PLERES_ZC_CTACRD

												cCCustC			:= U_FSCustoFil(SZD->ZD_FILIAL)
												cCCustD			:= U_FSCustoFil(SZD->ZD_FILIAL)

												IF EMPTY(cCCustC)
													cCCustC			:= PLERES_ZC_CCC
												ENDIF

												IF EMPTY(cCCustD)
													cCCustD			:= PLERES_ZC_CCD
												ENDIF
											ENDIF


											/*----------------------------------------
											02/01/2019 - Jonatas Oliveira - Compila
											Busca Centro de Custo pela Filial
											------------------------------------------*/
											DBSELECTAREA("CTT")
											CTT->(DBSETORDER(6))//|CTT_FILIAL+CTT_XEMPFI|

											//	cCCustC			:= U_FSCustoFil(SZD->ZD_FILIAL)
											//	cCCustD			:= U_FSCustoFil(SZD->ZD_FILIAL)
											//	IF EMPTY(cCCustC)
											//	cCCustC			:= PLERES_ZC_CCC
											//	ENDIF 
											// IF EMPTY(cCCustD)
											//	cCCustD			:= PLERES_ZC_CCD
											//	ENDIF 

											RegToMemory("SZC", .T., .F.)

											cIDSen := SOMA1(cIDSen)
											nIDSen++
											M->ZC_FILIAL	:= SZD->ZD_FILIAL
											M->ZC_IDTRAN	:= SZD->ZD_IDTRAN
											M->ZC_IDSEN		:= cIDSen
											M->ZC_DTLANC	:= LastDay(Stod(MV_PAR01 + "01"))		
											//20180201															
											M->ZC_TIPO		:= PLERES_ZC_TIPO								
											M->ZC_CTADEB	:= cCtaDeb
											M->ZC_CTACRD	:= cCtaCred
											M->ZC_CCD		:= cCCustD//PLERES_ZC_CCD
											M->ZC_CCC		:= cCCustC//PLERES_ZC_CCC				
											M->ZC_VALOR		:= IF (VALTYPE(alJson[nJ,PLERES_VALOR])<>"N" ,0,alJson[nJ,PLERES_VALOR])
											nTotMes			+= M->ZC_VALOR //| Base de calculo para linhas de impostos |

//											M->ZC_VLRACUM	:= ROUND(IIF(VALTYPE(alJson[nJ,PLERES_VLR_PRO_ACU])<>"N" ,0,alJson[nJ,PLERES_VLR_PRO_ACU]), 2)
											nTotAcu			+= M->ZC_VLRACUM //| Base de calculo para linhas de impostos |
											
											cCodEsp	:=  FwNoAccent(ALLTRIM(RemovChar(alJson[nJ,PLERES_COD_ESPECIAL])))
											M->ZC_HIST		:= cCodEsp + "-" + ALLTRIM(POSICIONE("SX5",1,XFILIAL("SX5")+"ZX" + cCodEsp ,"X5_DESCRI"))//FwNoAccent(ALLTRIM(RemovChar(alJson[nJ,PLERES_NOME_ESP])))			
											M->ZC_STATUS	:= "1"
											RecLock("SZC", .T.)

											For nI := 1 To nTotSZC

												cNameCpo	:= ALLTRIM(SZC->(FIELDNAME(nI)))
												FieldPut(nI, M->&(cNameCpo) )

											Next nI

											SZC->(MsUnLock())

//										ENDIF

										/*---------------------------------------
										Restaura FILIAL  
										-----------------------------------------*/
											IF _cCodEmp+_cCodFil <> _cCodEmp+_cFilNew
											CFILANT := _cCodFil
											opensm0(_cCodEmp+CFILANT)			 			
											ENDIF

										clCGC := alJson[nJ,PLERES_FILIAL]

										Next nJ



									/*------------------------------------------------------ Augusto Ribeiro | 21/11/2018 - 9:35:08 AM
									Gera linhas de 
									- ISS
									- COFINS
									- PIS
									- GLOSA
									------------------------------------------------------------------------------------------*/
										IF nTotMes > 0
									
										/*----------------------------------------
											02/01/2019 - Jonatas Oliveira - Compila
											Busca contas de Credito e Debito na 
											tabela Especialidade Conta Contabil
										------------------------------------------*/
										DBSELECTAREA("Z07")
										Z07->(DBSETORDER(1))

											IF Z07->(DBSEEK( SZD->ZD_FILIAL + "GLO"))
											cCCGlosa	:= Z07->Z07_CCC
											cCDGlosa	:= Z07->Z07_CCD
											cCTCGlos	:= Z07->Z07_CREDIT
											cCTDGlos	:= Z07->Z07_DEBITO
											ELSE
											cCCGlosa	:= PLERES_ZC_CCC
											cCDGlosa	:= PLERES_ZC_CCD
											cCTCGlos	:= PLERES_ZC_CTACRD
											cCTDGlos	:= PLERES_ZC_CTADEB												
											ENDIF
										
											IF Z07->(DBSEEK( SZD->ZD_FILIAL + "PIS"))
											cCCPIS	:= Z07->Z07_CCC
											cCDPIS	:= Z07->Z07_CCD
											cCTPISC	:= Z07->Z07_CREDIT
											cCTPISD	:= Z07->Z07_DEBITO											
											ELSE
										
											cCCPIS	:= PLERES_ZC_CCC
											cCDPIS	:= PLERES_ZC_CCD
											cCTPISC	:= PLERES_ZC_CTACRD
											cCTPISD	:= PLERES_ZC_CTADEB												
											ENDIF

											IF Z07->(DBSEEK( SZD->ZD_FILIAL + "COF"))
											cCCCOF	:= Z07->Z07_CCC
											cCDCOF	:= Z07->Z07_CCD
											cCTCOFC	:= Z07->Z07_CREDIT
											cCTCOFD	:= Z07->Z07_DEBITO											
											ELSE
											cCCCOF	:= PLERES_ZC_CCC
											cCDCOF	:= PLERES_ZC_CCD
											cCTCOFC	:= PLERES_ZC_CTACRD
											cCTCOFD	:= PLERES_ZC_CTADEB												
											ENDIF
										
											IF Z07->(DBSEEK( SZD->ZD_FILIAL + "ISS"))
											cCCISS	:= Z07->Z07_CCC
											cCDISS	:= Z07->Z07_CCD
											cCTISSC	:= Z07->Z07_CREDIT
											cCTISSD	:= Z07->Z07_DEBITO											
											ELSE
											cCCISS	:= PLERES_ZC_CCC
											cCDISS	:= PLERES_ZC_CCD
											cCTISSC	:= PLERES_ZC_CTACRD
											cCTISSD	:= PLERES_ZC_CTADEB												
											ENDIF
											
											
										/*---------------------------------------
										Realiza a TROCA DA FILIAL CORRENTE 
										-----------------------------------------*/
										_cCodEmp 	:= SM0->M0_CODIGO
										_cCodFil	:= SM0->M0_CODFIL
										_cFilNew	:= SZD->ZD_FILIAL //| CODIGO DA FILIAL DE DESTINO 

											IF _cCodEmp+_cCodFil <> _cCodEmp+_cFilNew
											CFILANT := _cFilNew
											opensm0(_cCodEmp+CFILANT)
											ENDIF

											IF nPerISS > 0

											RegToMemory("SZC", .T., .F.)

											nIDSen++
											cIDSen := SOMA1(cIDSen)
											/*
											Z07_cCCPIS
											Z07_CCDPCC
											Z07_CCCGLO
											Z07_CCDGLO
											*/

												M->ZC_FILIAL	:= SZD->ZD_FILIAL
												M->ZC_IDTRAN	:= SZD->ZD_IDTRAN
												M->ZC_IDSEN		:= cIDSen
												M->ZC_DTLANC	:= LastDay(Stod(MV_PAR01 + "01"))
												M->ZC_TIPO		:= PLERES_ZC_TIPO
												M->ZC_CTADEB	:= cCTISSD
												M->ZC_CTACRD	:= cCTISSC
												M->ZC_CCD		:= cCDISS
												M->ZC_CCC		:= cCCISS
												M->ZC_VALOR		:= nTotMes * (nPerISS/100)
												M->ZC_VLRACUM	:= nTotAcu * (nPerISS/100)
												M->ZC_HIST		:= "ISS" //alJson[nJ,PLERES_COD_ESPECIAL] + "-" + alJson[nJ,PLERES_NOME_ESP]
												M->ZC_TPREG		:= "2"

												RecLock("SZC", .T.)

												For nI := 1 To nTotSZC
													cNameCpo	:= ALLTRIM(SZC->(FIELDNAME(nI)))
													FieldPut(nI, M->&(cNameCpo) )
												Next nI

												SZC->(MsUnLock())
											ENDIF


											IF nPerCOF > 0

												RegToMemory("SZC", .T., .F.)

												nIDSen++
												cIDSen := SOMA1(cIDSen)

												M->ZC_FILIAL	:= SZD->ZD_FILIAL
												M->ZC_IDTRAN	:= SZD->ZD_IDTRAN
												M->ZC_IDSEN		:= cIDSen
												M->ZC_DTLANC	:= LastDay(Stod(MV_PAR01 + "01"))
												M->ZC_TIPO		:= PLERES_ZC_TIPO
												M->ZC_CTADEB	:= cCTCOFD
												M->ZC_CTACRD	:= cCTCOFC
												M->ZC_CCD		:= cCDCOF
												M->ZC_CCC		:= cCCCOF
												M->ZC_VALOR		:= nTotMes * (nPerCOF/100)
												M->ZC_VLRACUM	:= nTotAcu * (nPerCOF/100)
												M->ZC_HIST		:= "COFINS" //alJson[nJ,PLERES_COD_ESPECIAL] + "-" + alJson[nJ,PLERES_NOME_ESP]
												M->ZC_TPREG		:= "3"
												RecLock("SZC", .T.)

												For nI := 1 To nTotSZC
													cNameCpo	:= ALLTRIM(SZC->(FIELDNAME(nI)))
													FieldPut(nI, M->&(cNameCpo) )
												Next nI

												SZC->(MsUnLock())
											ENDIF


											IF nPerPIS > 0

												RegToMemory("SZC", .T., .F.)

												nIDSen++

												cIDSen := SOMA1(cIDSen)

												M->ZC_FILIAL	:= SZD->ZD_FILIAL
												M->ZC_IDTRAN	:= SZD->ZD_IDTRAN
												M->ZC_IDSEN		:= cIDSen
												M->ZC_DTLANC	:= LastDay(Stod(MV_PAR01 + "01"))
												M->ZC_TIPO		:= PLERES_ZC_TIPO
												M->ZC_CTADEB	:= cCTPISD
												M->ZC_CTACRD	:= cCTPISC
												M->ZC_CCD		:= cCDPIS
												M->ZC_CCC		:= cCCPIS
												M->ZC_VALOR		:= nTotMes * (nPerPIS/100)
												M->ZC_VLRACUM	:= nTotAcu * (nPerPIS/100)
												M->ZC_HIST		:= "PIS" //alJson[nJ,PLERES_COD_ESPECIAL] + "-" + alJson[nJ,PLERES_NOME_ESP]
												M->ZC_TPREG		:= "4"

												RecLock("SZC", .T.)

												For nI := 1 To nTotSZC
													cNameCpo	:= ALLTRIM(SZC->(FIELDNAME(nI)))
													FieldPut(nI, M->&(cNameCpo) )
												Next nI

												SZC->(MsUnLock())
											ENDIF


											IF nPerGlosa > 0

												RegToMemory("SZC", .T., .F.)

												cIDSen := SOMA1(cIDSen)

												nIDSen++
												M->ZC_FILIAL	:= SZD->ZD_FILIAL
												M->ZC_IDTRAN	:= SZD->ZD_IDTRAN
												M->ZC_IDSEN		:= cIDSen
												M->ZC_DTLANC	:= LastDay(Stod(MV_PAR01 + "01"))
												M->ZC_TIPO		:= PLERES_ZC_TIPO
												M->ZC_CTADEB	:= cCTDGlos
												M->ZC_CTACRD	:= cCTCGlos
												M->ZC_CCD		:= cCDGlosa
												M->ZC_CCC		:= cCCGlosa
												M->ZC_VALOR		:= nTotMes * (nPerGlosa/100)
												M->ZC_VLRACUM	:= nTotAcu * (nPerGlosa/100)
												M->ZC_HIST		:= "GLOSA" //alJson[nJ,PLERES_COD_ESPECIAL] + "-" + alJson[nJ,PLERES_NOME_ESP]
												M->ZC_TPREG		:= "5"

												RecLock("SZC", .T.)

												For nI := 1 To nTotSZC
													cNameCpo	:= ALLTRIM(SZC->(FIELDNAME(nI)))
													FieldPut(nI, M->&(cNameCpo) )
												Next nI

												SZC->(MsUnLock())
											ENDIF


										/*---------------------------------------
										Restaura FILIAL  
										-----------------------------------------*/
											IF _cCodEmp+_cCodFil <> _cCodEmp+_cFilNew
											CFILANT := _cCodFil
											opensm0(_cCodEmp+CFILANT)			 			
											ENDIF



										ENDIF
									ELSE
									_cMsgVaz += " Não existem dados. CNPJ " + _cCnpj + CRLF
									//								Aviso("Aviso","Não existem dados. Favor verificar os parametros." ,{"OK"},1)
									ENDIF
								ELSE

								Aviso("Aviso","Dados de retorno inválidos " + alret[2],{"OK"},1)	   

								ENDIF

							ELSE
							Aviso("Aviso","Tente novamente mais tarde serv pleres indisponível ["+clDominio+"]" + CRLF + alret[2] + CRLF + cParGet,{"OK"},2)
							Endif

						ELSE
						Aviso("Parâmetro Inválido","Digite ano e Mês válidos no formato AAAAMM",{"OK"},1)
						ENDIF

					ELSE

					Aviso("Parâmetro Inválido","Digite ano e Mês válidos no formato AAAAMM",{"OK"},1)

					ENDIF
				NEXT nY

			ELSE

			Aviso("Parâmetro Inválido","Nenhuma filial selecionada",{"OK"},1)

			ENDIF

			IF !EMPTY(_cMsgVaz)
			_cMsgVaz += "Favor verificar os parametros."
			Aviso("Aviso",_cMsgVaz ,{"OK"},1)
			ENDIF

		ENDIF

RETURN()


/*/{Protheus.doc} AjustaSx1
Cria as perguntas na SX1
@author Fabio Sales | www.compila.com.br
@since 05/11/2018
@version 1.0
/*/

Static Function CreateSx1(cPerg)

	Local aArea := GetArea()

	xPutSX1( cPerg, "01","Infome o Ano Mes(AAAAMM)"	,"","","mv_ch1","C",06,0,0,"G","",""	,"","","mv_par01",""		,""			,""			,"","","","","","","","","","","","","",,, )
	xPutSX1( cPerg, "02","CNPJ"						,"","","mv_ch2","C",14,0,0,"G","",""	,"","","mv_par02",""		,""			,""			,"","","","","","","","","","","","","",,, )
	xPutSX1( cPerg, "03","Raiz Filial"				,"","","mv_ch3","C",05,0,0,"G","",""	,"","","mv_par03",""		,""			,""			,"","","","","","","","","","","","","",,, )
//	xPutSx1( cPerg, "04","Sistema"					,"","","mv_ch4","N",01,0,0,"C","",""	,"","","mv_par04","Pleres"	,"Pleres"	,"Pleres"	,"","","","","","","","","","","","","",,, )

	RestArea(aArea)

Return()


/*/{Protheus.doc} xPutSX1
Ajusta Perguntas - SX1
@author Fabio Sales | www.compila.com.br
@since 05/11/2018
@version 1.0
/*/

Static Function xPutSX1(cGrupo,cOrdem,cPergunt,cPerSpa,cPerEng,cVar,;
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

	// Ajusta o tamanho do grupo. Ajuste emergencial para validaÃ§Ã£o dos fontes.
	// RFC - 15/03/2007
	cGrupo := PadR( cGrupo , Len( SX1->(FIELDGET(FIELDPOS("X1_GRUPO"))) ) , " " )

	If !( DbSeek( cGrupo + cOrdem ))

		cPergunt	:= If(! "?" $ cPergunt .And. ! Empty(cPergunt),Alltrim(cPergunt)+" ?",cPergunt)
		cPerSpa		:= If(! "?" $ cPerSpa  .And. ! Empty(cPerSpa) ,Alltrim(cPerSpa) +" ?",cPerSpa)
		cPerEng		:= If(! "?" $ cPerEng  .And. ! Empty(cPerEng) ,Alltrim(cPerEng) +" ?",cPerEng)

		Reclock( "SX1" , .T. )

		SX1->(FIELDGET(FIELDPOS("X1_GRUPO")))		:= cGrupo
		SX1->(FIELDGET(FIELDPOS("X1_ORDEM")))   	:= cOrdem
		SX1->(FIELDGET(FIELDPOS("X1_PERGUNT")))   := cPergunt
		SX1->(FIELDGET(FIELDPOS("X1_PERSPA")))   	:= cPerSpa
		SX1->(FIELDGET(FIELDPOS("X1_PERENG")))   	:= cPerEng
		SX1->(FIELDGET(FIELDPOS("X1_VARIAVL")))   := cVar
		SX1->(FIELDGET(FIELDPOS("X1_TIPO"))) 		:= cTipo
		SX1->(FIELDGET(FIELDPOS("X1_TAMANHO")))	:= nTamanho
		SX1->(FIELDGET(FIELDPOS("X1_DECIMAL"))) 	:=nDecimal
		SX1->(FIELDGET(FIELDPOS("X1_PRESEL")))		:=   nPresel
		SX1->(FIELDGET(FIELDPOS("X1_GSC")))   		:= cGSC
		SX1->(FIELDGET(FIELDPOS("X1_VALID")))   	:=  cValid
		SX1->(FIELDGET(FIELDPOS("X1_VAR01")))   	:= cVar01
		SX1->(FIELDGET(FIELDPOS("X1_F3")))   		:= cF3
		SX1->(FIELDGET(FIELDPOS("X1_GRPSXG")))   	:= cGrpSxg
		If Fieldpos("X1_PYME") > 0
			If cPyme != Nil
				SX1->(FIELDGET(FIELDPOS("X1_PYME")))	:= cPyme
			Endif
		Endif
		SX1->(FIELDGET(FIELDPOS("X1_CNT01")))  := cCnt01

		If cGSC == "C"                   // Mult Escolha
			SX1->(FIELDGET(FIELDPOS("X1_DEF01")))   	:= cDef01
			SX1->(FIELDGET(FIELDPOS("X1_DEFSPA1")))	:= cDefSpa1
			SX1->(FIELDGET(FIELDPOS("X1_DEFENG1")))   := cDefEng1

			SX1->(FIELDGET(FIELDPOS("X1_DEF02")))   	:= cDef02
			SX1->(FIELDGET(FIELDPOS("X1_DEFSPA2")))	:= cDefSpa2
			SX1->(FIELDGET(FIELDPOS("X1_DEFENG2")))   := cDefEng2

			SX1->(FIELDGET(FIELDPOS("X1_DEF03")))   	:= cDef03
			SX1->(FIELDGET(FIELDPOS("X1_DEFSPA3")))   := cDefSpa3
			SX1->(FIELDGET(FIELDPOS("X1_DEFENG3")))   := cDefEng3

			SX1->(FIELDGET(FIELDPOS("X1_DEF04")))   	:= cDef04
			SX1->(FIELDGET(FIELDPOS("X1_DEFSPA4")))   := cDefSpa4
			SX1->(FIELDGET(FIELDPOS("X1_DEFENG4")))   := cDefEng4

			SX1->(FIELDGET(FIELDPOS("X1_DEF05")))   	:= cDef05
			SX1->(FIELDGET(FIELDPOS("X1_DEFSPA5")))   := cDefSpa5
			SX1->(FIELDGET(FIELDPOS("X1_DEFENG5")))   := cDefEng5
		Endif

		SX1->(FIELDGET(FIELDPOS("X1_HELP")))	:= cHelp

		/*
		===> ANTIGO.  RETIRAR DEPOIS QUE OK

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

		*/
		PutSX1Help(cKey,aHelpPor,aHelpEng,aHelpSpa)

		MsUnlock()
	Else

		lPort := ! "?" $ SX1->(FIELDGET(FIELDPOS("X1_PERGUNT")))  .And. ! Empty(SX1->(FIELDGET(FIELDPOS("X1_PERGUNT")))  )
		lSpa  := ! "?" $ SX1->(FIELDGET(FIELDPOS("X1_PERSPA")))   .And. ! Empty(SX1->(FIELDGET(FIELDPOS("X1_PERSPA"))) )
		lIngl := ! "?" $ SX1->(FIELDGET(FIELDPOS("X1_PERENG")))   .And. ! Empty(SX1->(FIELDGET(FIELDPOS("X1_PERENG"))) )

		If lPort .Or. lSpa .Or. lIngl
			If lPort
				SX1->(FIELDGET(FIELDPOS("X1_PERGUNT")))  := Alltrim(SX1->(FIELDGET(FIELDPOS("X1_PERGUNT")))  )+" ?"
			EndIf

			If lSpa
				SX1->(FIELDGET(FIELDPOS("X1_PERSPA")))  := Alltrim(SX1->(FIELDGET(FIELDPOS("X1_PERSPA"))) ) +" ?"
			EndIf

			If lIngl
				SX1->(FIELDGET(FIELDPOS("X1_PERENG")))  := Alltrim(SX1->(FIELDGET(FIELDPOS("X1_PERENG"))) ) +" ?"
			EndIf
			SX1->(MsUnLock())
		EndIf
	Endif

	RestArea( aArea )

Return


/*/{Protheus.doc} Exclui
Filtra os registros para exclusão.
@author Fabio Sales | www.compila.com.br
@since 06/11/2018
@version 1.0
/*/


STATIC FUNCTION Exclui(AnoMes,Domain,filiais)

	Local clQry		:= ""
	Local nlTotal	:= 0
	Local alAreaSZD := SZD->(GetArea())

	Default AnoMes := "AAAAMM"
	Default Domain := "xxxxxx"
	Default filiais:= "('')"

	clQry := " SELECT R_E_C_N_O_ AS REC FROM SZD010 "
	clQry += " WHERE ZD_ANOMES ='" + AnoMes + "' "
	clQry += " 		AND ZD_DOMINIO = '" + Domain + "' "
	clQry += " 		AND ZD_FILIAL IN "+ filiais +" "
	clQry += " 		AND ZD_STATUS = '1' "
	clQry += " 		AND D_E_L_E_T_ ='' "

	IF SELECT("EXCSZD") <> 0
		EXCSZD->(DBCLOSEAREA())
	ENDIF

	TCQUERY clQry NEW ALIAS "EXCSZD"


	dbSelectArea("EXCSZD")

	EXCSZD->(DBGoTop())
	EXCSZD->( dbEval( {|| nlTotal++ } ) )
	EXCSZD->(DBGoTop())
	ProcRegua(nlTotal)

	WHILE !EXCSZD->(EOF())

		IncProc("Efetuando Exclusão...")

		DBSELECTAREA("SZD")
		SZD->(DBGOTO(EXCSZD->REC))

		clFilial := SZD->ZD_FILIAL
		clIdTran := SZD->ZD_IDTRAN

		RecLock("SZD",.F.)
		SZD->(dbDelete())
		SZD->(MsUnLock())

		DBSELECTAREA("SZC")
		SZC->(DBSETORDER(1))
		IF SZC->(DBSEEK(clFilial + clIdTran))

			WHILE !SZC->(EOF()) .AND. SZC->ZC_FILIAL==clFilial .AND. SZC->ZC_IDTRAN == clIdTran

				RecLock("SZC",.F.)
				SZC->(dbDelete())
				SZC->(MsUnLock())

				SZC->(DBSKIP())
			ENDDO

		ENDIF

		EXCSZD->(DBSKIP())
	ENDDO

	RestArea(alAreaSZD)

Return()




/*/{Protheus.doc} SM0CNPJ
Retorna Array com filiais, nome e CNPJ
@author Augusto Ribeiro | www.compila.com.br
@since 20/11/2018
@version undefined
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function SM0CNPJ()
	Local aRet		:= {}
	Local cQuery	:= ""
	Local nI, aAreaSM0


	DBSELECTAREA("SM0")
	aAreaSM0	:= SM0->(GETAREA())

	SM0->(DBGOTOP())

	WHILE SM0->(!EOF())

		IF !EMPTY(MV_PAR02)

			IF ALLTRIM(MV_PAR02) == ALLTRIM(SM0->M0_CGC)
				AADD(aRet, {SM0->M0_CODFIL, SM0->M0_FILIAL, SM0->M0_CGC})
			ENDIF

		ELSEIF !EMPTY(MV_PAR03)

			IF ALLTRIM(MV_PAR03) $ LEFT(ALLTRIM(SM0->M0_CODFIL), 5)
				AADD(aRet, {SM0->M0_CODFIL, SM0->M0_FILIAL, SM0->M0_CGC})
			ENDIF

		ELSE
			AADD(aRet, {SM0->M0_CODFIL, SM0->M0_FILIAL, SM0->M0_CGC})
		ENDIF

		SM0->(DBSKIP())
	ENDDO

	RestArea(aAreaSM0)

Return(aRet)








/*/{Protheus.doc} MultFil
Apresenta Multi-Seleção para filiais
@author Augusto Ribeiro | www.compila.com.br
@since 20/11/2018
@version undefined
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function MultFil()
	Local aRet		:= {}
	Local aFilSM0	:= {}
	Local nI, uVarRet
	Local cOpcoes	:= ""
	Local aOpcoes	:= {}
	Local cTitulo := "Filiais"
	Local cF3	 := ""

	aFilSM0	:= SM0CNPJ()

	IF LEN(aFilSM0) > 0
		//| Ordena Array |
		aSort(aFilSM0,,,{ |x,y| x[1] < y[1]})

		nTamKey		:= len(aFilSM0[1,1])
		nElemRet    := len(aFilSM0)

		FOR nI := 1 to nElemRet

			aadd(aOpcoes,aFilSM0[nI,1]+"-"+alltrim(aFilSM0[nI,2])+"-"+alltrim(aFilSM0[nI,3]))

		Next nI



		//------------------------------------------------------------------------------------------------
		// Executa f_Opcoes para Selecionar ou Mostrar os Registros Selecionados
		IF f_Opcoes(    @uVarRet    ,;    //Variavel de Retorno
			cTitulo     ,;    //Titulo da Coluna com as opcoes
			@aOpcoes    ,;    //Opcoes de Escolha (Array de Opcoes)
			@cOpcoes    ,;    //String de Opcoes para Retorno
			NIL         ,;    //Nao Utilizado
			NIL         ,;    //Nao Utilizado
			.F.         ,;    //Se a Selecao sera de apenas 1 Elemento por vez
			nTamKey     ,;    //Tamanho da Chave
			nElemRet    ,;    //No maximo de elementos na variavel de retorno
			.T.         ,;    //Inclui Botoes para Selecao de Multiplos Itens
			.F.         ,;    //Se as opcoes serao montadas a partir de ComboBox de Campo ( X3_CBOX )
			NIL         ,;    //Qual o Campo para a Montagem do aOpcoes
			.F.         ,;    //Nao Permite a Ordenacao
			.F.         ,;    //Nao Permite a Pesquisa
			.T.         ,;    //Forca o Retorno Como Array
			cF3          ;    //Consulta F3
			)



			IF !EMPTY(uVarRet)
				aRet	:= {}
				FOR nI := 1 to len(uVarRet)

					AADD(aRet, StrTokArr2( uVarRet[nI], "-" , .T.))

				Next nI
			ENDIF
		endif
	ENDIF
Return(aRet)





/*---------------------------------------------------
AUGUSTO RIBEIRO                                  

Recebe String separa por caracter "X"            
ou Numero de Caractres para "quebra" _nCaracX)   
Retorna String pronta para IN em selects         
Ex.: Retorn: ('A','C','F')                       

PARAMETROS:  _cString, _cCaracX                  
------------------------------------------*/
Static Function INQuery(_cString, _cCaracX, _nCaracX)
	Local _cRet	:= ""
	Local _cString, _cCaracX, _nCaracX, nY
	Local _aString	:= {}
	Default	_nCaracX := 0

	/*---------------------------------------------------
	Valida Informacoes Basicas ³
	---------------------------------------------------*/
	IF !EMPTY(_cString) .AND. (!EMPTY(_cCaracX) .OR. _nCaracX > 0)

		nString	:= LEN(_cString)



		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Utiliza Separacao por Numero de Caracteres ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		IF _nCaracX > 0
			FOR nY := 1 TO nString STEP _nCaracX

				AADD(_aString, SUBSTR(_cString,nY, _nCaracX) )

			Next nY

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Utiliza Separacao por caracter especifico ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		ELSE
			_aString	:= WFTokenChar(_cString, _cCaracX)
		ENDIF

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta String para utilizar com IN em querys³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		_cRet	+=  "('"
		FOR _nI := 1 TO Len(_aString)
			IF _nI > 1
				_cRet	+= ",'"
			ENDIF
			_cRet += ALLTRIM(_aString[_nI])+"'"
		Next _nI
		_cRet += ") "

	ENDIF

Return(_cRet)



/*/{Protheus.doc} RemovChar
Remove caracter especial  
@author Augusto Ribeiro | www.compila.com.br
@since 05/03/2019
@version 1.0
/*/
STATIC Function RemovChar(cRet)
	Local cRet

	cRet	:= upper(cRet)

	cRet	:= STRTRAN(cRet,"Ã‡","C")
	cRet	:= STRTRAN(cRet,"ÃÂÂÇÍ","C")
	cRet	:= STRTRAN(cRet,"ÂÆÆ","")
	cRet	:= STRTRAN(cRet,"Á","A")
	cRet	:= STRTRAN(cRet,"É","E")
	cRet	:= STRTRAN(cRet,"Í","I")
	cRet	:= STRTRAN(cRet,"Ó","O")
	cRet	:= STRTRAN(cRet,"Ú","U")
	cRet	:= STRTRAN(cRet,"À","A")
	cRet	:= STRTRAN(cRet,"È","E")
	cRet	:= STRTRAN(cRet,"Ì","I")
	cRet	:= STRTRAN(cRet,"Ò","O")
	cRet	:= STRTRAN(cRet,"Ù","U")
	cRet	:= STRTRAN(cRet,"Ã","A")
	cRet	:= STRTRAN(cRet,"Õ","O")
	cRet	:= STRTRAN(cRet,"Ä","A")
	cRet	:= STRTRAN(cRet,"Ë","E")
	cRet	:= STRTRAN(cRet,"Ï","I")
	cRet	:= STRTRAN(cRet,"Ö","O")
	cRet	:= STRTRAN(cRet,"Ü","U")
	cRet	:= STRTRAN(cRet,"Â","A")
	cRet	:= STRTRAN(cRet,"Ê","E")
	cRet	:= STRTRAN(cRet,"Î","I")
	cRet	:= STRTRAN(cRet,"Ô","O")
	cRet	:= STRTRAN(cRet,"Û","U")
	cRet	:= STRTRAN(cRet,"Ç","C")
	cRet	:= STRTRAN(cRet,"º"," ")
	cRet	:= STRTRAN(cRet,"-","")
	cRet	:= STRTRAN(cRet,".","")
	cRet	:= STRTRAN(cRet,"R$","")
	cRet	:= STRTRAN(cRet,"NULL","")
	cRet	:= STRTRAN(cRet,"ƒ","")
	cRet	:= STRTRAN(cRet,"^M","")




Return(cRet)



/*/{Protheus.doc} fGrvLog
Realiza a Criação, Gravacao, Apresentacao do Log de acordo com o Pametro passado
@author www.compila.com.br
@param _nOpc, N, 1= Cria Arquivo de Log, 2= Grava Log, 3 = Apresenta Log
@param _cTxtLog, C, Log a ser gravado 
/*/
Static Function fGrvLog(_nOpc, _cTxtLog)
	Local _lRet	:= Nil
	Local _nOpc, _cTxtLog
	Local _EOL	:= chr(13)+chr(10)

	Default _nOpc		:= 0
	Default _cTxtLog 	:= ""
	_cTxtLog += _EOL
	Do Case
	Case _nOpc == 1
		_cFileLog	 	:= Criatrab(,.F.)
		_cLogPath		:= AllTrim(GetTempPath())+_cFileLog+".txt"
		_Handle			:= FCREATE(_cLogPath,0)	//| Arquivo de Log
		IF !EMPTY(_cTxtLog)
			FWRITE (_Handle, _cTxtLog)
		ENDIF

	Case _nOpc == 2
		IF !EMPTY(_cTxtLog)
			FWRITE (_Handle, _cTxtLog)
		ENDIF

	Case _nOpc == 3
		IF !EMPTY(_cTxtLog)
			FWRITE (_Handle, _cTxtLog)
		ENDIF
		FCLOSE(_Handle)
		WINEXEC("NOTEPAD "+_cLogPath)
	EndCase

Return(_lRet)




Static Function Ct102EstLt(nOpc,dDataLanc,cLote,cSubLote,cDoc,nTotInf)

	Local aSaveArea	:= GetArea()
	Local aCampos		:= {}
	Local aAltera		:= {}
	Local aQuais		:= {}
	Local aAuxQuais 	:= {}
	Local aDocRej		:= {} // Documentos rejeitados

	Local cArq1		:= ""
	Local cArq2		:= ""
	Local cLinha	:= Replicate("0",Len(CT2->CT2_LINHA)-1)+"1"
	Local cLinhaAlt	:= Replicate("0",Len(CT2->CT2_LINHA)-1)+"1"
	Local cCadastro	:= "Estorno de lancamento por lote"
	Local cVarQ 	:= "  "
	Local cChave	:= ""
	Local cChaveOri	:= ""
	Local cDescInc	:= ""

	Local aRet		:= { .T. , ""}

	Local dDtIniEst	:= dDataLanc
	Local dDtFimEst	:= dDataLanc
	Local cLoteIni	:= cLote
	Local cLoteFim	:= cLote
	Local cSbLotIni	:= cSubLote
	Local cSbLotFim	:= cSubLote
	Local cDocIni	:= cDoc
	Local cDocFim	:= cDoc
	Local lDataOri	:= .T.
	Local dDataEst	:= CTOD("  /  /  ")
	Local cLoteEst	:= cLote
	Local cSubLtEst	:= cSubLote
	Local cDocEst	:= cDoc
	Local lDataOk 	:= .T.
	Local cTpSaldo	:= ""

	Local nLinha	:= 1
	Local CTF_LOCK	:= 0
	Local nOpca
	Local nCont		:= 0
	Local nContDoc	:= 0

	Local lContinua	:= .T.
	Local lFirst	:= .T.
	Local lRpcOk	:= .T.
	Local lRet		:= .T.
	Local lOk		:= .T.

	Local dDataOri	:= CTOD("  /  /  ")
	Local nSomaPos	:= 0
	Local cLoteOri	:= '      '
	Local cSbloteOri:= '   '
	Local cDocOri	:= '      '

	Local oOk 		:= LoadBitmap( GetResources(), "LBOK")
	Local oNo 		:= LoadBitmap( GetResources(), "LBNO")
	Local oDlg
	Local oQual

	Local cModoClr	:= Alltrim(GetNewPar("MV_CTBAPLA","1"))	//"1"=Inativo,"2"=Pergunta,"3"=Automatico c/Alertas,"4"=Automático sem alertas
	Local lVldTps 	:= GETMV("MV_CTBCTG",.T.,.F.) // Habilita validação por amarração entre calendário x moeda x tipo de saldo

	Local dDataAux 	:= CTOD(" / / ")
	Local cDocAux 	:= ""
	Local cLoteAux 	:= ""
	Local cSubLtAux 	:= ""
	Local lImpRel

	Private lImpRel := .F.

	Private oDescEnt,oDig,oDeb,oCred,oGetDB
	Private OPCAO

	Private aHeader	:= {}
	Private aColsP	:= {}
	Private __aCT2LC:= {}

	Private __lCusto	:= CtbMovSaldo("CTT")
	Private __lItem		:= CtbMovSaldo("CTD")
	Private __lCLVL		:= CtbMovSaldo("CTH")

//Se não for para gerar o lançamento de estorno na mesma data do lançamento original,será gerado
//na data preenchida na pergunta "Data dos lanc. estorno"
	If !lDataOri
		dDataEst	:= dDataLanc
	EndIf

//Criar arquivo de trabalho para relatorio de inconsistencia. 
//Ct102CrRel()

	If lVldTps
		cQuery := " SELECT CT2_FILIAL,CT2_DATA,CT2_LOTE,CT2_SBLOTE,CT2_DOC,CT2_TPSALD, MIN(R_E_C_N_O_) MINRECNO "
	Else
		cQuery := " SELECT CT2_FILIAL,CT2_DATA,CT2_LOTE,CT2_SBLOTE,CT2_DOC, MIN(R_E_C_N_O_) MINRECNO "
	EndIf
	cQuery += " FROM "+RetSqlName("CT2")
	cQuery += " WHERE CT2_FILIAL = 	'"+xFilial("CT2")+"' "

	cQuery += "   AND CT2_DATA 	 = '"+DTOS(dDataLanc)+"' "


	cQuery += "   AND CT2_LOTE 	 = '"+cLote+"' "
	cQuery += "   AND CT2_SBLOTE = '"+cSubLote+"' "
	cQuery += "   AND CT2_DOC 	 = '"+cDoc+"' "

// filtra os lancamentos complementares
	If CTBLCUso()
		cQuery += "   AND CT2_ROTINA <> '__CTBLC__ '"
	Endif

	cQuery += "   AND D_E_L_E_T_ = ' ' "
	If lVldTps
		cQuery += "   GROUP BY CT2_FILIAL,CT2_DATA,CT2_LOTE,CT2_SBLOTE,CT2_DOC,CT2_TPSALD"
		cQuery += "   ORDER BY CT2_FILIAL,CT2_DATA,CT2_LOTE,CT2_SBLOTE,CT2_DOC,CT2_TPSALD"
	Else
		cQuery += "   GROUP BY CT2_FILIAL,CT2_DATA,CT2_LOTE,CT2_SBLOTE,CT2_DOC"
		cQuery += "   ORDER BY CT2_FILIAL,CT2_DATA,CT2_LOTE,CT2_SBLOTE,CT2_DOC"
	EndIf

	cQuery := ChangeQuery(cQuery)

	If Select("CT2ESTLT") > 0
		dbSelectArea("CT2ESTLT")
		dbCloseArea()
	EndIf

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),"CT2ESTLT",.T.,.T.)

	TcSetField("CT2ESTLT","CT2_DATA","D",8					  ,0)
	TcSetField("CT2ESTLT","MINRECNO","N",17 				  ,0)

	dbSelectArea("CT2ESTLT")

	While CT2ESTLT->(!Eof())

		dbSelectArea("CT2")
		CT2->(dbGoto(CT2ESTLT->MINRECNO))

		If lVldTps
			cTpSaldo := CT2->CT2_TPSALD
		Else
			cTpSaldo := ""
		EndIf

		//Se for para gerar o lançamento de estorno na mesma data do lançamento original
		If nOpc == 5  //exclusao

			dDataEst	:= CT2->CT2_DATA
			lDataOk 	:= CtbValiDt(nOpc,dDataEst,,cTpSaldo,lVldTps)

		ElseIf 	nOpc == 6  //estorno

			If lDataOri
				dDataEst	:= CT2->CT2_DATA
				lDataOk 	:= CtbValiDt(nOpc,dDataEst,,cTpSaldo,lVldTps)
			Else
				dDataEst	:= mv_par10
				lDataOk 	:= CtbValiDt(nOpc,dDataEst,,cTpSaldo,lVldTps)
			EndIf

		EndIf

		//Verificação da Data.
		Aadd(aQuais,{.T.,DTOC(CT2->CT2_DATA)+SPACE(1)+CT2->CT2_LOTE+SPACE(1)+CT2->CT2_SBLOTE+SPACE(1)+CT2->CT2_DOC})

		CT2ESTLT->(dbSkip())
	EndDo

	For nContDoc := 1 To Len(aQuais)
		If aScan(aDocRej,{ | Doc | Doc == aQuais[nContDoc][2] } ) <= 0
			Aadd(aAuxQuais,{.T.,aQuais[nContDoc][2]})
		EndIf
	Next nContDoc

	aQuais := aAuxQuais

	dbSelectArea("CT2ESTLT")
	dbCloseArea()


//Monta LISTBOX com os lotes/docs escolhidos pelo usuario para serem estornados. 
	If Len(aQuais) > 0 .And. VldCaplote(dDataLanc,cLote,cSubLote,cDoc,nOpc)

		nOpca := 1

		If nOpca == 1

			If ExistBlock("VCTB102EST") // opção de validação do estorno do lançamento
				If ! ExecBlock("VCTB102EST",.F.,.F.,{dDataLanc,cLote,cSubLote,cDoc,nTotInf})
					Return .F.
				EndIF
			EndIf

			//Criar arquivo de trabalhO TMP => alimentar GETDB
			aCampos := Ctb105Head(@aAltera)
			Ctb105Cria(aCampos,@cArq1,@cArq2)

			ProcRegua( Len(aQuais) )

			For nCont	:= 1 to Len(aQuais)
				IncProc( "Processando Lançamento Nº.: " + aQuais[nCont][2] )

				If aQuais[nCont][1]
					dDataOri	:= CTOD(Subs(aQuais[nCont][2],1,10))

					nSomaPos := 0
					If ( Len( Dtoc( dDataOri ) ) == 10 ) // data com 10 posicoes ( xx/xx/xxxx )
						nSomaPos := 2	// seto a variavel de soma para 2
					Endif

					cLoteOri	:= Subs( aQuais[nCont][2], 10 + nSomaPos, 6 )
					cSbloteOri	:= Subs( aQuais[nCont][2], 17 + nSomaPos, 3 )
					cDocOri		:= Subs( aQuais[nCont][2], 21 + nSomaPos, 6 )

					cChaveOri	:= xFilial( "CT2" ) + DTOS( dDataOri ) + cLoteOri + cSbloteOri + cDocOri    // chave de busca do documento contabil

					//Se for para gerar o lançamento de estorno na mesma data do lançamento original
					If lDataOri
						dDataEst	:= dDataOri
					EndIf

					dbSelectArea("CT2")
					dbSetOrder(1)
					If MsSeek(cChaveOri)
						cLoteOri	:= ''
						cSbloteOri	:= ''
						cDocOri		:= ''

						If ExistBlock("CTB102ESTL")
							lOk := ExecBlock("CTB102ESTL",.F.,.F.,{nOpc})
						EndIf

						If lOk
							cLoteOri	:= CT2->CT2_LOTE
							cSbLoteOri	:= CT2->CT2_SBLOTE
							cDocOri		:= CT2->CT2_DOC

							//Verificar se existe alguma entidade bloqueada do documento
							//O nOpc eh passado como 5 de proposito, para entrar na validacao.
							If nOpc ==5 .Or. (nOpc == 6 .And. CtbTmpBloq(dDataOri,cLoteOri,cSbLoteOri,cDocOri,5,.F.))

								If  CtbVldLP(dDataOri,cLoteOri,cSbLoteOri,cDocOri,nOpc,.F.)

									If nOpc == 6	//Se for estorno de lançamento contabil por lote
										lContinua := Ctb102Carr(nOpc,@dDataEst,cLoteEst,cSubLtEst,cDocEst,@cLinhaAlt)
									Else
										lContinua := Ctb102Carr(nOpc,CT2->CT2_DATA,CT2->CT2_LOTE,CT2->CT2_SBLOTE,CT2->CT2_DOC,@cLinhaAlt)
									EndIf

									//Validacao das entidades contábeis => estorno de lançamentos contábeis
									//Na exclusão, nao verifica.
									If nOpc == 6
										lRpcOk	:= CTB105Rpc(.F.)
									Else
										lRpcOk	:= .T.
									EndIf

									If lRpcOK

										If ExistBlock("ANCTB102GR")
											ExecBlock("ANCTB102GR",.F.,.F.,{ nOpc,dDataEst,cLoteEst,cSubLtEst,cDocEst }  )
										Endif

										If nOpc == 6
											Ctb102PxEst( @dDataEst,@cLoteEst,@cSubLtEst,@cDocEst,@CTF_LOCK )

											CTBGrava(nOpc,dDataEst,cLoteEst,cSubLtEst,cDocEst,.F.,"",__lCusto,__lItem,__lCLVL,nTotInf,'CTBA102',,,cEmpAnt,cFilAnt)

											aRet[1] 	:= .T.
											//aRet[2] 	:= STR0082 + space(1)+STR0008+":"+DTOC(dDataEst)+space(1)+STR0009+":"+cLoteEst+space(1)+STR0083+":"+cSubLtEst+space(1)+STR0010+":"+cDocEst//"Estorno gerado com sucesso."
											//cDescInc	:= STR0082 + space(1)+STR0008+":"+DTOC(dDataEst)+space(1)+STR0009+":"+cLoteEst+space(1)+STR0083+":"+cSubLtEst+space(1)+STR0010+":"+cDocEst//"Estorno gerado com sucesso."
											cDescInc	:= "STR0082" + space(1)+"STR0008"+":"+DTOC(dDataEst)+space(1)+"STR0009"+":"+cLoteEst+space(1)+"STR0083"+":"+cSubLtEst+space(1)+"STR0010"+":"+cDocEst//"Estorno gerado com sucesso."
											aRet[2] 	:= cDescInc
										Else
											//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
											//³ BOPS 00000117527 - Tratamento para nao repetir as mensagens de confir ³
											//³ mação de exclusão para cada documento na função CT2ClearLA()          ³
											//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
											cModoClr := "4"

											dDataAux 	:= CT2->CT2_DATA
											cLoteAux 	:= CT2->CT2_LOTE
											cSubLtAux 	:= CT2->CT2_SBLOTE
											cDocAux 	:= CT2->CT2_DOC

											CTBGrava(nOpc,dDataAux,cLoteAux,cSubLtAux,cDocAux,.F.,"",__lCusto,__lItem,__lCLVL,nTotInf,'CTBA102',,,cEmpAnt,cFilAnt,,,,cModoClr)
//								   		cDescInc	:= "Exclusão realizada com sucesso." //"Exclusão realizada com sucesso."								   		

											//Envia a mensagem única de Exclusão
											CT102EAI( dDataAux, cLoteAux, cSubLtAux, cDocAux )
										EndIf
										//Grava no arq. de trabalho que o estorno foi gerado com sucesso.
//									Ct102GrInc(DTOC(dDataOri),cLoteOri,cSbLoteOri,cDocOri,cDescInc)
									Else
										cDescInc	:= "Verificar se as entidades contábeis estão corretas." //"Verificar se as entidades contábeis estão corretas."
										aRet[1] 	:= .F.
										aRet[2] 	:= "Verificar se as entidades contábeis estão corretas."
										//Grava no arq. de trabalho que o estorno foi gerado com sucesso.
										If nOpc == 6
											Ct102GrInc(DTOC(dDataOri),cLoteOri,cSbLoteOri,cDocOri,cDescInc)
										Else
											Ct102GrInc(DTOC(CT2->CT2_DATA),CT2->CT2_LOTE,CT2->CT2_SBLOTE,CT2->CT2_DOC,cDescInc)
										EndIf
									EndIf
									dbSelectArea("TMP")
									If TMP->(RecCount()) > 0
										TMP->(DbCloseArea())
										FErase( cArq1+GetDBExtension() )
										Ferase( cArq1+OrdBagExt() )
										Ferase( cArq2+OrdBagExt() )
										cArq1 := ""
										cArq2 := ""
										Ctb105Cria(aCampos,@cArq1,@cArq2)
									EndIf

									If ExistBlock("DPCTB102GR")
										ExecBlock("DPCTB102GR",.F.,.F.,{ nOpc,dDataEst,cLoteEst,cSubLtEst,cDocEst } )
									Endif
								Else
									aRet[1] 	:= .F.
									aRet[2] 	:= "Lançcamentos de apuração nao poderão ser excluidos ou estornados. "
									cDescInc	:= "Lançcamentos de apuração nao poderão ser excluidos ou estornados. "//Lançcamentos de apuração nao poderão ser excluidos ou estornados.
									//Grava no arq. de trabalho que o estorno foi gerado com sucesso.
//								Ct102GrInc(DTOC(dDataOri),cLoteOri,cSbLoteOri,cDocOri,cDescInc)
								EndIf
							Else
								aRet[1] 	:= .F.
								aRet[2] 	:= "Verificar se alguma das entidades conta´beis está bloqueada."
								cDescInc	:= "Verificar se alguma das entidades conta´beis está bloqueada." //"Verificar se alguma das entidades conta´beis está bloqueada."
								//Grava no arq. de trabalho que o estorno foi gerado com sucesso.
//							Ct102GrInc(DTOC(dDataOri),cLoteOri,cSbLoteOri,cDocOri,cDescInc)
							EndIf
						Endif
					EndIf
				EndIf
			Next

			dbSelectArea( "TMP" )
			dbCloseArea()

		/*
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Lancamento de complementar³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
			If CTBLCUso()
				If (Type("__aCT2LC") == "A") .And. !Empty(__aCT2LC)
				CTBLCGerLC()
				Endif
			Endif
				
			If Select("cArq1") = 0
			FErase( cArq1+GetDBExtension() )
			Ferase( cArq1+OrdBagExt() )
			Ferase( cArq2+OrdBagExt() )
			EndIf
		
		DeleteObject(oOk)
		DeleteObject(oNo)
		EndIf
	EndIf

	
	
		
RestArea(aSaveArea)

Return(aRet)


Static Function Ct102GrInc(dData,cLote,cSubLote,cDoc,cDescInc)
                                
Local aSaveArea:= GetArea()	

dbSelectArea("TRB") 
Reclock("TRB",.T.)	
TRB->DDATA		:= dData
TRB->LOTE		:= cLote
TRB->SUBLOTE	:= cSubLote
TRB->DOC		:=	cDoc
TRB->DESCINC	:=	cDescInc
MsUnlock()

RestArea(aSaveArea)

Return	

/*/{Protheus.doc} xDocCTF
Busca o proximo Documento de acordo com os parametros
@author Jonatas Oliveira | www.compila.com.br
@since 29/03/2019
@version 1.0
/*/
Static Function xDocCTF(_cfiltr, _dDataBase, _cLote, _cSubLot)
	Local cRet		:= "000000"
	Local cQuery	:= ""

	cQuery += " SELECT MAX(CTF_DOC) AS DOC "+CRLF
	cQuery += " FROM  " +Retsqlname("CTF") + " CNF "+CRLF
	cQuery += " WHERE D_E_L_E_T_ = '' "+CRLF
	cQuery += " 	AND CTF_FILIAL = '"+_cfiltr+"' "+CRLF
	cQuery += " 	AND CTF_DATA = '"+DTOS(_dDataBase)+"' "+CRLF
	cQuery += " 	AND CTF_LOTE = '"+_cLote+"' "+CRLF
	cQuery += " 	AND CTF_SBLOTE = '"+_cSubLot+"' "+CRLF

	If Select("QRYCTF") > 0
		QRYCTF->(DbCloseArea())
	EndIf

	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),'QRYCTF')

	IF QRYCTF->( !EOF())
		cRet 	:= SOMA1(QRYCTF->DOC)
	ENDIF

Return(cRet)


/*/{Protheus.doc} vldCalCtb
Verifica se calendario contabil esta aberto
@author Augusto Ribeiro | www.compila.com.br
@since 09/11/2019
@version version
@param param
@return lRet, .t. = aberto, .f. = fechado
@example
(examples)
@see (links_or_references)
/*/
Static Function vldCalCtb(cFilCal, dDtMov)
	Local lRet	:= .F.

	cQuery := " SELECT CTG_CALEND "+CRLF
	cQuery += " FROM "+RetSqlName("CTG")+" CTG "+CRLF

	//hfp - Compila
	// juncao para o novo modelo e reconher o CQD (Processos)
	cQuery += "		INNER JOIN "+RetSqlName("CQD")+"  CQD ON  CQD.D_E_L_E_T_ = '' "+CRLF
	cQuery += "			AND  CQD_FILIAL ='"+left(cFilCal,5)+"' AND CQD_PROC = 'CTB001' "+CRLF 
	cQuery += "			AND  CQD_CALEND = CTG_CALEND AND CQD_EXERC = CTG_EXERC  "+CRLF
	cQuery += "			AND CQD_PERIOD = CTG_PERIOD  AND CQD_STATUS = '1' "+CRLF
	//
	cQuery += " WHERE CTG_FILIAL = '"+left(cFilCal,5)+"' "+CRLF
	cQuery += " AND '"+DTOS(dDtMov)+"' BETWEEN CTG_DTINI AND CTG_DTFIM "+CRLF
	cQuery += " AND CTG_STATUS = '1' "+CRLF
	cQuery += " AND CTG.D_E_L_E_T_ = '' "+CRLF

	If Select("TCAL") > 0
		TCAL->(DbCloseArea())
	EndIf

	DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TCAL",.F., .T.)


	IF TCAL->(!EOF())
		lRet	:= .T.
	ENDIF


	TCAL->(DbCloseArea())

Return(lRet)


