#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
//-------------------------------------------------------------------
/*{Protheus.doc} ALCTBA01
Contabilizacao dos Registros Integrados pelo Senior

@author Guilherme.Santos
@since 20/09/2016
@version P12
*/
//-------------------------------------------------------------------
User Function ALCTBA01()
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
	
	ADD OPTION aRotina TITLE "Incluir"		ACTION "VIEWDEF.ALCTBA01"	OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE "Alterar"		ACTION "VIEWDEF.ALCTBA01"	OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE "Excluir"		ACTION "VIEWDEF.ALCTBA01"	OPERATION 5 ACCESS 0

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
	Local oModel 		:= MPFormModel():New("X_ALCTBA01", /*{|oModel| fPreMod(oModel)}*/, {|oModel| fPostMod(oModel)}, /*{|oModel| fCommit(oModel)}*/, /*{|oModel| fCancel(oModel)}*/)
	Local oStrCab 	:= FWFormStruct(1, "SZD")
	Local oStrDet		:= FWFormStruct(1, "SZC")
	
	oModel:AddFields("HEADER", NIL, oStrCab)
	oModel:AddGrid("DETAIL", "HEADER", oStrDet)

	oModel:GetModel("HEADER"):SetDescription("Contabilização Integração Senior")
	oModel:SetDescription("Contabilização Integração Senior")

	oModel:SetRelation("DETAIL", {{"ZC_FILIAL","xFilial('SZC')"}, {"ZC_IDTRAN", "ZD_IDTRAN"}}, SZC->(IndexKey(1)))

	oModel:SetPrimaryKey({"ZC_FILIAL", "ZC_IDTRAN", "ZC_IDSEN"})

	oModel:GetModel("HEADER"):GetStruct():SetProperty("*", MODEL_FIELD_WHEN, {|| .F.})
	oModel:GetModel("DETAIL"):GetStruct():SetProperty("*", MODEL_FIELD_WHEN, {|| .F.})
	
Return oModel
//-------------------------------------------------------------------
/*{Protheus.doc} ViewDef
Definicao da View

@author Guilherme.Santos
@since 20/09/2016
@version P12
*/
//-------------------------------------------------------------------
Static Function ViewDef()
	Local oModel	:= FWLoadModel("ALCTBA01")
	Local oView	:= FWFormView():New()
	Local oStrCab	:= FWFormStruct(2, "SZD")
	Local oStrDet	:= FWFormStruct(2, "SZC")

	oView:SetModel(oModel)

	oView:AddField("VIEW_HEADER"	, oStrCab, "HEADER")
	oView:AddGrid("VIEW_DETAIL"		, oStrDet, "DETAIL")

	oView:CreateHorizontalBox("SUPERIOR"	, 30)
	oView:CreateHorizontalBox("INFERIOR"	, 70)

	oView:SetOwnerView("VIEW_HEADER", "SUPERIOR")
	oView:SetOwnerView("VIEW_DETAIL", "INFERIOR")
	
Return oView
//-------------------------------------------------------------------
/*{Protheus.doc} fPostMod
Validacao antes da Confirmacao do Model

@author Guilherme.Santos
@since 20/09/2016
@version P12
*/
//-------------------------------------------------------------------
Static Function fPostMod(oModel)
	Local cStatus		:= oModel:GetModel("HEADER"):GetValue("ZD_STATUS")
	Local lRetorno	:= .T.
	/*
	-----------------------------------------------------------------------------------------------------
		Nao permite alterar ou excluir movimentos processados
	-----------------------------------------------------------------------------------------------------	
	*/
	If oModel:GetOperation() == MODEL_OPERATION_UPDATE .OR. oModel:GetOperation() == MODEL_OPERATION_DELETE
		If cStatus == "2"
			lRetorno := .F.
			Help("", 1, "PREMOD", NIL, "Movimentos já processados.", 4, 1)
		EndIf
	EndIf

Return lRetorno
