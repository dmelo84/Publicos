#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
//-------------------------------------------------------------------
/*{Protheus.doc} ALTMKA04
Cadastro de Pacientes

@author Guilherme Santos
@since 23/12/2016
@version P12
*/
//-------------------------------------------------------------------
User Function ALTMKA04()
	Local oBrowse:= FWMBrowse():New()

	oBrowse:SetAlias("AC4")
	oBrowse:SetMenuDef("ALTMKA04")
	oBrowse:SetDescription("Cadastro de Pacientes")
	oBrowse:DisableDetails()
	oBrowse:ForceQuitButton()
	oBrowse:DisableReport()
	oBrowse:Activate()

Return NIL
//-------------------------------------------------------------------
/*{Protheus.doc} MenuDef
Definicao das Opcoes de Menu

@author Guilherme Santos
@since 23/12/2016
@version P12
*/
//-------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina TITLE "Pesquisar"	ACTION "PesqBrw"		OPERATION 0							ACCESS 0 //"Pesquisar"
	ADD OPTION aRotina TITLE "Visualizar"	ACTION "U_A04MANUT"		OPERATION MODEL_OPERATION_VIEW		ACCESS 0 //"Visualizar"
	ADD OPTION aRotina TITLE "Incluir"		ACTION "U_A04MANUT"		OPERATION MODEL_OPERATION_INSERT	ACCESS 0 //"Incluir"
	ADD OPTION aRotina TITLE "Alterar"		ACTION "U_A04MANUT"		OPERATION MODEL_OPERATION_UPDATE	ACCESS 0 //"Alterar"

Return aRotina
//-------------------------------------------------------------------
/*{Protheus.doc} A04MANUT
Chamada das Rotinas de Manutencao

@author Guilherme.Santos
@since 23/12/2016
@version P12
*/
//-------------------------------------------------------------------
User Function A04MANUT(cAlias, nReg, nOpcao)
	Private INCLUI := .F.
	Private ALTERA := .F.
	Private VISUAL := .F.
	Private EXCLUI := .F.

	Do Case
	Case nOpcao == 2		//Visualizacao
		RegToMemory(cAlias, .F., .F.)
		VISUAL := .T.
		FWExecView("Visualização"	, "ALTMKA04", MODEL_OPERATION_VIEW		, NIL, {|| .T.})
	Case nOpcao == 3		//Inclusao
		RegToMemory(cAlias, .T. , .T.)
		INCLUI := .T.
		FWExecView("Inclusão"		, "ALTMKA04", MODEL_OPERATION_INSERT	, NIL, {|| .T.})
	Case nOpcao == 4		//Alteracao
		RegToMemory(cAlias, .F. , .T.)
		ALTERA := .T.
		FWExecView("Alteração"		, "ALTMKA04", MODEL_OPERATION_UPDATE	, NIL, {|| .T.})
	Case nOpcao == 5		//Exclusao
		RegToMemory(cAlias, .F. , .F.)
		EXCLUI := .T.
		FWExecView("Exclusão"		, "ALTMKA04", MODEL_OPERATION_DELETE	, NIL, {|| .T.})
	EndCase

Return NIL
//-------------------------------------------------------------------
/*{Protheus.doc} ModelDef
Definicao do Modelo de Dados

@author Guilherme Santos
@since 23/12/2016
@version P12
*/
//-------------------------------------------------------------------
Static Function ModelDef()
	Local bCancel		:= {|oModel| fCancel(oModel)}
	Local bPosMod		:= {|oModel| fPosMod(oModel)}

	Local bLoadSU5		:= {|oGridMod, lCopy| fLoadSU5(oGridMod, lCopy)}
	Local bLineSU5		:= {|oGridMod, nLinha, cAcao, cCampo, xNewValue, xOldValue| fLineSU5(oGridMod, nLinha, cAcao, cCampo, xNewValue, xOldValue)}

	Local bLoadAC8		:= {|oGridMod, lCopy| fLoadAC8(oGridMod, lCopy)}

	Local oModel 		:= MPFormModel():New("X_ALTMKA04", /*bPreMod*/, bPosMod, /*bCommit*/, bCancel)

	Local oStrAC4		:= FWFormStruct(1, "AC4")
	Local oStrSU5		:= FWFormStruct(1, "SU5")
	Local oStrAC8		:= FWFormStruct(1, "AC8")

	//Ajuste do Codigo do Contato
	oStrSU5:SetProperty("U5_CODCONT", MODEL_FIELD_WHEN, {|| .F.})
	oStrSU5:SetProperty("U5_CODCONT", MODEL_FIELD_INIT, {|| U_TKMXCNT()})

	//Componentes do Modelo
	oModel:AddFields("AC4HEADER", NIL, oStrAC4, /*bPreHeader*/)
	oModel:AddGrid("SU5DETAIL", "AC4HEADER", oStrSU5, bLineSU5, /*bLinePost*/, /*bPre*/, /*bLinePost*/, bLoadSU5)
	oModel:AddGrid("AC8DETAIL", "AC4HEADER", oStrAC8, /*bLineAC8*/, /*bLinePost*/, /*bPre*/, /*bLinePost*/, /*bLoadAC8*/)

	//Descricoes do Modelo
	oModel:SetDescription("Cadastro de Pacientes")
	oModel:GetModel("AC4HEADER"):SetDescription("Paciente")
	oModel:GetModel("SU5DETAIL"):SetDescription("Contatos")
	oModel:GetModel("AC8DETAIL"):SetDescription("Paciente x Contato")

	oModel:GetModel("SU5DETAIL"):SetUniqueLine({"U5_CODCONT"})

	oModel:GetModel("SU5DETAIL"):SetOptional(.T.)
	oModel:GetModel("AC8DETAIL"):SetOptional(.T.)

Return oModel
//-------------------------------------------------------------------
/*{Protheus.doc} ViewDef
Definicao da View

@author Guilherme Santos
@since 23/12/2016
@version P12
*/
//-------------------------------------------------------------------
Static Function ViewDef()
	Local oModel		:= FWLoadModel("ALTMKA04")
	Local oView			:= FWFormView():New()
	Local oStrAC4		:= FWFormStruct(2, "AC4")
	Local oStrSU5		:= FWFormStruct(2, "SU5")
	
	oView:SetModel(oModel)

	oView:AddField("VIEW_AC4HEADER", oStrAC4, "AC4HEADER")
	oView:AddGrid("VIEW_DETAIL", oStrSU5, "SU5DETAIL")

	oView:CreateHorizontalBox("SUPERIOR", 50)
	oView:CreateHorizontalBox("INFERIOR", 50)

	oView:SetOwnerView("VIEW_AC4HEADER", "SUPERIOR")
	oView:SetOwnerView("VIEW_DETAIL", "INFERIOR")

Return oView
//-------------------------------------------------------------------
/*{Protheus.doc} fCancel
Acionado ao Cancelar a Gravacao

@author Guilherme Santos
@since 23/12/2016
@version P12
*/
//-------------------------------------------------------------------
Static Function fCancel(oModel)
	Local lRetorno := .T.

	While GetSX8Len() > 0
		RollBackSXE()
	End

Return lRetorno
//-------------------------------------------------------------------
/*{Protheus.doc} fPosMod
Validacao do Model (TudoOk)

@author Guilherme.Santos
@since 23/12/2016
@version P12
*/
//-------------------------------------------------------------------
Static Function fPosMod(oModel)
	Local lRetorno 	:= .T.
	Local nLinha	:= 0
	Local nPosCon	:= 0

	Local cFilRel	:= FWxFilial("AC8")
	Local cFilEnt	:= FWxFilial("SU5")
	Local cCodEnt	:= oModel:GetModel("AC4HEADER"):GetValue("AC4_PARTNE")
	Local cEntida	:= "AC4"

	Local oModAC8	:= oModel:GetModel("AC8DETAIL")
	Local oModSU5	:= oModel:GetModel("SU5DETAIL")

	cCodEnt += Space(TamSX3("AC8_CODENT")[1] - Len(cCodEnt))

	For nLinha := 1 to oModSU5:Length()
		oModSU5:GoLine(nLinha)
		
		If !oModSU5:IsDeleted(nLinha)
			If Empty(oModSU5:GetValue("U5_CONTAT"))
				oModSU5:DeleteLine()
				//RollBackSX8()
			Else
				If oModSU5:IsInserted(nLinha) .OR. oModSU5:IsUpdated(nLinha)
					//Busca na AC8 pela Chave
					nPosCon := MTFindMVC(oModAC8, {{"AC8_FILIAL", FWxFilial("AC8")}, {"AC8_CODCON", oModSU5:GetValue("U5_CODCONT")}, {"AC8_ENTIDA", cEntida}, {"AC8_CODENT", cCodEnt}})
		
					If nPosCon == 0
						If oModAC8:Length() == 1 .AND. oModAC8:GetLine() == 1 .AND. Empty(oModAC8:GetValue("AC8_CODCON"))
							nPosCon := 1
						Else
							nPosCon := oModAC8:AddLine()
						EndIf
		
						oModAC8:GoLine(nPosCon)
						
						oModAC8:LoadValue("AC8_FILIAL", FWxFilial("AC8"))
						oModAC8:LoadValue("AC8_CODCON", oModSU5:GetValue("U5_CODCONT"))
						oModAC8:LoadValue("AC8_ENTIDA", cEntida)
						oModAC8:LoadValue("AC8_CODENT", cCodEnt)
					EndIf
				EndIf
			EndIf
		EndIf
	Next nLinha

Return lRetorno
//-------------------------------------------------------------------
/*{Protheus.doc} fLoadSU5
Carrega os Dados da Grid para Edicao

@author Guilherme.Santos
@since 23/12/2016
@version P12
*/
//-------------------------------------------------------------------
Static Function fLoadSU5(oSubMod, lCopy)
	Local aLinha	:= {}
	Local aLoadMod 	:= {}		//Retornar Array no Formato dos Campos da Grid
	Local cQuery	:= ""
	Local cTabQry	:= GetNextAlias()
	Local nCampo	:= 0
	
	//Campos para consultar sx3	
	Local nX3RELACAO := SX3->(FIELDPOS("X3_RELACAO"))
	Local nX3CAMPO := SX3->(FIELDPOS("X3_CAMPO"))
	
	
	cQuery += "SELECT	SU5.U5_FILIAL" + CRLF
	cQuery += ",		SU5.U5_CODCONT" + CRLF
	cQuery += "FROM		" + RetSqlName("AC8") + " AC8" + CRLF
	cQuery += "			INNER JOIN" + CRLF
	cQuery += "			" + RetSqlName("SU5") + " SU5" + CRLF
	cQuery += "			ON	AC8.AC8_FILIAL = '" + xFilial("AC8") + "'" + CRLF
	cQuery += "			AND AC8.AC8_FILENT = SU5.U5_FILIAL" + CRLF
	cQuery += "			AND AC8.AC8_ENTIDA = 'AC4'" + CRLF
	cQuery += "			AND AC8.AC8_CODENT = '" + AC4->AC4_PARTNE + "'" + CRLF
	cQuery += "			AND	AC8.AC8_CODCON = SU5.U5_CODCONT" + CRLF
	cQuery += "			AND AC8.D_E_L_E_T_ = ''" + CRLF
	cQuery += "ORDER BY SU5.U5_FILIAL, SU5.U5_CODCONT" + CRLF
	
	cQuery := ChangeQuery(cQuery)
		
	DbUseArea(.T., "TOPCONN", TcGenQry(NIL, NIL, cQuery), cTabQry, .T., .T.)
		
	While !(cTabQry)->(Eof())
		aLinha := {}

		//Posicionar na SU5
		DbSelectArea("SU5")
		DbSetOrder(1)		//U5_FILIAL, U5_CODCONT
		
		If SU5->(DbSeek((cTabQry)->U5_FILIAL + (cTabQry)->U5_CODCONT))
			For nCampo := 1 to Len(oSubMod:aHeader)
				If oSubMod:aHeader[nCampo][10] == "R"
					Aadd(aLinha, &("SU5->" + AllTrim(oSubMod:aHeader[nCampo][02])))
				Else
					DbSelectArea("SX3")
					DbSetOrder(2)		//X3_CAMPO

					If SX3->(DbSeek(oSubMod:aHeader[nCampo][02])) .AND. !Empty(SX3->(FIELDGET(nX3RELACAO)))
						Aadd(aLinha, &(SX3->(FIELDGET(nX3RELACAO))))
					Else
						Aadd(aLinha, CreateVar(SX3->(FIELDGET(nX3CAMPO))))
					EndIf
				EndIf
			Next nCampo

			Aadd(aLoadMod, {SU5->(Recno()), AClone(aLinha)})
		EndIf

		(cTabQry)->(DbSkip())
	End
	
	If Select(cTabQry) > 0
		(cTabQry)->(DbCloseArea())
	EndIf

Return aLoadMod
//-------------------------------------------------------------------
/*{Protheus.doc} fLoadAC8
Carrega os Dados da Grid para Edicao

@author Guilherme.Santos
@since 23/12/2016
@version P12
*/
//-------------------------------------------------------------------
Static Function fLoadAC8(oSubMod, lCopy)
	Local aLinha	:= {}
	Local aLoadMod 	:= {}		//Retornar Array no Formato dos Campos da Grid
	Local cQuery	:= ""
	Local cTabQry	:= GetNextAlias()
	Local nCampo	:= 0
	
	//Campos para consultar sx3	
	Local nX3RELACAO := SX3->(FIELDPOS("X3_RELACAO"))
	Local nX3CAMPO := SX3->(FIELDPOS("X3_CAMPO"))
	
	cQuery += "SELECT	AC8.AC8_FILIAL" + CRLF
	cQuery += ",		AC8.AC8_CODCON" + CRLF
	cQuery += ",		AC8.AC8_ENTIDA" + CRLF
	cQuery += ",		AC8.AC8_FILENT" + CRLF
	cQuery += ",		AC8.AC8_CODENT" + CRLF
	cQuery += ",		AC8.R_E_C_N_O_ REGAC8" + CRLF
	cQuery += "FROM		" + RetSqlName("AC8") + " AC8" + CRLF
	cQuery += "			INNER JOIN" + CRLF
	cQuery += "			" + RetSqlName("SU5") + " SU5" + CRLF
	cQuery += "			ON	AC8.AC8_FILIAL = '" + xFilial("AC8") + "'" + CRLF
	cQuery += "			AND AC8.AC8_FILENT = SU5.U5_FILIAL" + CRLF
	cQuery += "			AND AC8.AC8_ENTIDA = 'AC4'" + CRLF
	cQuery += "			AND AC8.AC8_CODENT = '" + AC4->AC4_PARTNE + "'" + CRLF
	cQuery += "			AND	AC8.AC8_CODCON = SU5.U5_CODCONT" + CRLF
	cQuery += "			AND AC8.D_E_L_E_T_ = ''" + CRLF
	cQuery += "ORDER BY AC8_FILIAL, AC8_CODCON, AC8_ENTIDA, AC8_FILENT, AC8_CODENT, AC8.R_E_C_N_O_" + CRLF
	
	cQuery := ChangeQuery(cQuery)
		
	DbUseArea(.T., "TOPCONN", TcGenQry(NIL, NIL, cQuery), cTabQry, .T., .T.)
		
	While !(cTabQry)->(Eof())
		aLinha := {}

		//Posicionar na AC8
		DbSelectArea("AC8")
		DbSetOrder(1)		//AC8_FILIAL, AC8_CODCON, AC8_ENTIDA, AC8_FILENT, AC8_CODENT
		
		If AC8->(DbSeek((cTabQry)->AC8_FILIAL + (cTabQry)->AC8_CODCON + (cTabQry)->AC8_ENTIDA + (cTabQry)->AC8_FILENT + (cTabQry)->AC8_CODENT))

			For nCampo := 1 to Len(oSubMod:aHeader)
				If oSubMod:aHeader[nCampo][10] == "R"
					Aadd(aLinha, &("AC8->" + AllTrim(oSubMod:aHeader[nCampo][02])))
				Else
					DbSelectArea("SX3")
					DbSetOrder(2)		//X3_CAMPO

					If SX3->(DbSeek(oSubMod:aHeader[nCampo][02])) .AND. !Empty(SX3->(FIELDGET(X3_RELACAO)))
						Aadd(aLinha, &(SX3->(FIELDGET(X3_RELACAO))))
					Else
						Aadd(aLinha, CreateVar(SX3->(FIELDGET(nX3CAMPO))))
					EndIf
				EndIf
			Next nCampo

			Aadd(aLoadMod, {AC8->(Recno()), AClone(aLinha)})
		EndIf

		(cTabQry)->(DbSkip())
	End
	
	If Select(cTabQry) > 0
		(cTabQry)->(DbCloseArea())
	EndIf

Return aLoadMod
//-------------------------------------------------------------------
/*{Protheus.doc} fLineSU5
Validacao antes da Edicao da Linha da Grid

@author Guilherme.Santos
@since 23/12/2016
@version P12
@param oGridMod 	Objeto da Grid
@param nLinha 		Linha atual da Grid
@param cAcao		Identificacao da Acao executada
@param cCampo		Campo onde a Acao foi executada
@param xNewValue	Novo Valor atribuido ao Campo
@param xOldValue	Valor anterior do Campo
*/
//-------------------------------------------------------------------
Static Function fLineSU5(oGridMod, nLinha, cAcao, cCampo, xNewValue, xOldValue)
	Local lRetorno := .T.

	Do Case
	Case cAcao == "DELETE"
		Do Case 
		Case oGridMod:IsInserted(nLinha)
			RollBackSXE()
		Otherwise
			lRetorno := .F.
		EndCase
	EndCase

Return lRetorno
