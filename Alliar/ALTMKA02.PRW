#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
//-------------------------------------------------------------------
/*{Protheus.doc} ALTMKA02
Cadastro de Grupo x Unidade

@author Guilherme Santos
@since 22/11/2016
@version P12
*/
//-------------------------------------------------------------------
User Function ALTMKA02()
	Local oBrowse:= FWMBrowse():New()

	oBrowse:SetAlias("SZF")
	oBrowse:SetMenuDef("ALTMKA02")
	oBrowse:SetDescription("Cadastro de Grupo x Unidade")
	oBrowse:DisableDetails()
	oBrowse:ForceQuitButton()
	oBrowse:DisableReport()
	oBrowse:Activate()

Return NIL
//-------------------------------------------------------------------
/*{Protheus.doc} MenuDef
Definicao das Opcoes de Menu

@author Guilherme Santos
@since 22/11/2016
@version P12
*/
//-------------------------------------------------------------------
Static Function MenuDef()
	Local aRotina := {}

	ADD OPTION aRotina TITLE "Pesquisar" 	ACTION "PesqBrw"			OPERATION 0							ACCESS 0 //"Pesquisar"
	ADD OPTION aRotina TITLE "Visualizar" 	ACTION "VIEWDEF.ALTMKA02"	OPERATION MODEL_OPERATION_VIEW		ACCESS 0 //"Visualizar"
	ADD OPTION aRotina TITLE "Incluir" 		ACTION "VIEWDEF.ALTMKA02"	OPERATION MODEL_OPERATION_INSERT	ACCESS 0 //"Incluir"
	ADD OPTION aRotina TITLE "Alterar" 		ACTION "VIEWDEF.ALTMKA02"	OPERATION MODEL_OPERATION_UPDATE	ACCESS 0 //"Alterar"
	ADD OPTION aRotina TITLE "Excluir" 		ACTION "VIEWDEF.ALTMKA02"	OPERATION MODEL_OPERATION_DELETE	ACCESS 0 //"Excluir"

Return aRotina
//-------------------------------------------------------------------
/*{Protheus.doc} ModelDef
Definicao do Modelo de Dados

@author Guilherme Santos
@since 22/11/2016
@version P12
*/
//-------------------------------------------------------------------
Static Function ModelDef()
	Local bCommit		:= {|oModel| fCommit(oModel)}
	Local bPosMod		:= {|oModel| fPosMod(oModel)}
	Local bPreMod		:= {|oModel| fPreMod(oModel)}
	Local bCancel		:= {|oModel| fCancel(oModel)}

	Local oModel 		:= MPFormModel():New("X_ALTMKA02", bPreMod, bPosMod, bCommit, bCancel)
	Local oStrCab		:= FWFormStruct(1, "SZF")

	oModel:AddFields("HEADER", NIL, oStrCab)
	oModel:GetModel("HEADER"):SetDescription("Cadastro de Grupo x Unidade")
	oModel:SetDescription("Cadastro de Grupo x Unidade")

Return oModel
//-------------------------------------------------------------------
/*{Protheus.doc} ViewDef
Definicao da View

@author Guilherme Santos
@since 22/11/2016
@version P12
*/
//-------------------------------------------------------------------
Static Function ViewDef()
	Local oModel		:= FWLoadModel("ALTMKA02")
	Local oView			:= FWFormView():New()
	Local oStrCab		:= FWFormStruct(2, "SZF")

	oView:SetModel(oModel)
	oView:AddField("VIEW_HEADER", oStrCab, "HEADER")
	oView:CreateHorizontalBox("SUPERIOR", 100)
	oView:SetOwnerView("VIEW_HEADER", "SUPERIOR")

Return oView
//-------------------------------------------------------------------
/*{Protheus.doc} fCommit
Rotina de Gravacao do MVC

@author Guilherme Santos
@since 22/11/2016
@version P12
*/
//-------------------------------------------------------------------
Static Function fCommit(oModel)
	Local lRetorno := oModel:CommitData()
Return lRetorno
//-------------------------------------------------------------------
/*{Protheus.doc} fPosMod
Pos Validacao do Model (TudoOk) 

@author Guilherme Santos
@since 22/11/2016
@version P12
*/
//-------------------------------------------------------------------
Static Function fPosMod(oModel)
	Local lRetorno := .T.
Return lRetorno
//-------------------------------------------------------------------
/*{Protheus.doc} fPreMod
Pre Validacao do Model (Antes de Carregar) 

@author Guilherme Santos
@since 22/11/2016
@version P12
*/
//-------------------------------------------------------------------
Static Function fPreMod(oModel)
	Local lRetorno := .T.
Return lRetorno
//-------------------------------------------------------------------
/*{Protheus.doc} fCancel
Acionado ao Cancelar a Gravacao

@author Guilherme Santos
@since 22/11/2016
@version P12
*/
//-------------------------------------------------------------------
Static Function fCancel(oModel)
	Local lRetorno := .T.
Return lRetorno
