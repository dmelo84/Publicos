#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
//-------------------------------------------------------------------
/*{Protheus.doc} ALCTBA02
Contabilizacao dos Registros Integrados pelo Senior

@author Guilherme.Santos
@since 20/09/2016
@version P12
*/
//-------------------------------------------------------------------
User Function ALCTBA02()
	Local oBrowse	:= FWMBrowse():New()

	

	oBrowse:SetAlias("SZD")
	oBrowse:SetMenuDef("ALCTBA02")
	oBrowse:SetDescription("Contabilização Integração Senior")

	oBrowse:Activate()
Return NIL
//-------------------------------------------------------------------
/*{Protheus.doc} MenuDef
Definicao das Opcoes de Menu

@author Guilherme.Santos
@since 20/09/2016
@version P12
*/
//-------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina TITLE "Visualizar"	ACTION "VIEWDEF.ALCTBA01"	OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE "Processar" 	ACTION "U_AL02CTBP(6)" 		OPERATION 6 ACCESS 0
	ADD OPTION aRotina TITLE "Estornar"  	ACTION "U_AL02CTBP(7)" 		OPERATION 7 ACCESS 0

Return aRotina
//-------------------------------------------------------------------
/*{Protheus.doc} ModelDef
Definicao do Modelo de Dados

@author Guilherme.Santos
@since 20/09/2016
@version P12
*/
//-------------------------------------------------------------------
Static Function ModelDef()
	Local oModel := FWLoadModel("ALCTBA01")
Return oModel
//-------------------------------------------------------------------
/*{Protheus.doc} AL02CTBP
Rotina de Procesamento ou Estorno dos Movimentos Contabeis

@author Guilherme Santos
@since 04/10/2016
@version P12
*/
//-------------------------------------------------------------------
User Function AL02CTBP(nOpcao)
	Local aArea		:= GetArea()
	Local cFilBkp		:= cFilAnt
	Local cPerg		:= "U_ALCTBA02"
	Local cQuery		:= ""
	Local cTabQry		:= GetNextAlias()
	Local lRetorno	:= .T.

	If MsgYesNo("Esta Rotina efetuará o " + If(nOpcao == 6, "Processamento", "Estorno") + " dos Movimentos Contábeis. Confirma a Execução?")

		If Pergunte(cPerg, .T.)

			cQuery += "SELECT 	SZD.ZD_FILIAL, " + CRLF
			cQuery += "			SZD.ZD_IDTRAN" + CRLF
			cQuery += "FROM 		"+RetSqlName("SZD")+" SZD" + CRLF
			cQuery += "WHERE 		SZD.ZD_FILIAL BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "'" + CRLF
			cQuery += "AND		SZD.ZD_IDTRAN BETWEEN '" + MV_PAR03 + "' AND '" + MV_PAR04 + "'" + CRLF

			Do Case
				Case nOpcao == 6
					cQuery += "AND		SZD.ZD_STATUS <> '2'" + CRLF
				Case nOpcao == 7
					cQuery += "AND		SZD.ZD_STATUS <> '1'" + CRLF
			EndCase

			cQuery += "AND		SZD.D_E_L_E_T_ = ''" + CRLF

			cQuery := ChangeQuery(cQuery)

			DbUseArea(.T., "TOPCONN", TcGenQry(NIL, NIL, cQuery), cTabQry, .T., .T.)

			While !(cTabQry)->(Eof())
				DbSelectArea("SZD")
				DbSetOrder(1)		//ZD_FILIAL, ZD_IDTRAN

				If SZD->(DbSeek((cTabQry)->ZD_FILIAL + (cTabQry)->ZD_IDTRAN))

					cFilAnt := (cTabQry)->ZD_FILIAL

					Do Case
						Case nOpcao == 6
						//Contabilizacao
						U_AL02GRAV(6, (cTabQry)->ZD_IDTRAN)	// Alterado Aleluia 271016

						Case nOpcao == 7
						//Estorno
						U_AL02GRAV(7, (cTabQry)->ZD_IDTRAN)	// Alterado Aleluia 271016

					EndCase
				EndIf

				(cTabQry)->(DbSkip())
			End
		EndIf
	EndIf

	If Select(cTabQry) > 0
		(cTabQry)->(DbCloseArea())
	EndIf

	RestArea(aArea)
	cFilAnt := cFilBkp

	MsgInfo("Fim do processamento!")

Return lRetorno
//-------------------------------------------------------------------
/*{Protheus.doc} AL02GRAV
Gravacao da Contabilizacao ou do Estorno

@author Guilherme Santos
@since 04/10/2016
@version P12
*/
//-------------------------------------------------------------------
User Function AL02GRAV(nOpcao, cIDTran)
	Local cArquivo	:= ""
	Local cCTBSen	:= SuperGetMV("ES_CTBSEN", .F., "511")		//Lancamento Contabil para a Integracao com o Senior
	Local cLote		:= ""
	Local cSeek		:= ""
	Local nHdlPrv	:= 0
	Local nTotal	:= 0
	Local lAglut	:= .F.
	Local lDigita	:= .F.
	Local lRetorno 	:= .T.


	DbSelectArea("SZC")
	DbSetOrder(1)		//ZC_FILIAL, ZC_IDTRAN

	If SZC->(DbSeek(xFilial("SZC") + cIDTran))
		Begin Transaction
			//Busca lote contabil
			SX5->(dbSetOrder(1)) //X5_FILIAL+X5_TABELA+X5_CHAVE
			If SX5->(MsSeek(xFilial("SX5") + "09GPE"))
				cLote := AllTrim(X5Descri())
			Else
				cLote := "GPE "
			EndIf		

			//Executa um execblock			
			If At(UPPER("EXEC"),X5Descri()) > 0 .OR. At(Upper("U_"),SX5->(FIELDGET(FIELDPOS("X5_DESCRI")))) > 0
				cLote	:= &(X5Descri())
			EndIf				

			cSeek 		:= SZC->ZC_FILIAL + Substr(DtoS(SZC->ZC_DTLANC), 1, 6)
			cArquivo	:= ""
			nTotal		:= 0

			//Cabecalho da contabilizacao
			nHdlPrv	:= HeadProva(cLote, "ALCTBA02", Substr(cUserName, 1, 6), @cArquivo, .F.)


			While !SZC->(Eof()) .AND. xFilial("SZC") + cIDTran == SZC->ZC_FILIAL + SZC->ZC_IDTRAN

				Debito    := SZC->ZC_CTADEB
				Credito   := SZC->ZC_CTACRD
				Historico := SZC->ZC_HIST
				ItemD     := ""
				ItemC     := ""
				Valor     := SZC->ZC_VALOR 
				CustoD    := SZC->ZC_CCD
				CustoC    := SZC->ZC_CCC
				DocSun    := ""			

				nTotal += DetProva(nHdlPrv,cCTBSen,"LP0001",cLote) // Linha de Detalhe 

				//Detalhe da contabilizacao
				/*If SZC->ZC_VALOR > 0
				nTotal += DetProva(nHdlPrv, cCTBSen cCTBSen01, "ALCTBA02", cLote,,,,, cSeek)	// Alterado Aleluia 271016	
				Else
				nTotal += DetProva(nHdlPrv, cCTBSen cCTBSen02, "ALCTBA02", cLote,,,,, cSeek) // Alterado Aleluia 271016
				Endif*/

				SZC->(DbSkip())
			End

			//Rodape da contabilizacao
			RodaProva(nHdlPrv, nTotal)

			//			cA100Incl(cArquivo, nHdlPrv, 3, cLote, lDigita, lAglut)
			cA100Incl(cCTBSen, nHdlPrv, 3, cLote, lDigita, .F.)

			//Atualiza o Status da SZD Apos a Gravacao dos Lancamentos
			RecLock("SZD", .F.)
			SZD->ZD_STATUS := "2"
			SZD->ZD_LOTE		:= cLote
			MsUnlock()

			//TODO - BUSCAR LOTE, SUBLOTE E GRAVAR NA SZC


		End Transaction
	EndIf

Return lRetorno
