#include 'protheus.ch'
#include 'parmtype.ch'
#include "FWMVCDef.ch"

/*/{Protheus.doc} FSESTC01
Tela para visualização da tabela SZ9
Posicao estoque Pleres

@author claudiol
@since 24/02/2016
@version undefined

@type function
/*/
user function FSESTC01()

Private cCadastro	:= "Posição Estoque Pleres"
Private oBrowse	:= Nil

oBrowse := FwMBrowse():New()
oBrowse:SetAlias("SZ9")
oBrowse:SetDescription(cCadastro)
oBrowse:DisableSaveConfig() 			
oBrowse:DisableConfig() 				
oBrowse:ForceQuitButton()
oBrowse:SetMenuDef( "FSESTC01" )
oBrowse:Activate()

Return


/*/{Protheus.doc} ModelDef
ModelDef

@author claudiol
@since 03/03/2016
@version undefined

@type function
/*/
Static Function ModelDef()

Local	oStruSZ9	:= FWFormStruct(1, "SZ9")
Local	oModel		:= MPFormModel():New("MSZ9",,{|| })

oModel:AddFields("SZ9MASTER", /*cOwner*/, oStruSZ9)
oModel:SetPrimaryKey( {} )
oModel:SetDescription(cCadastro)
oModel:GetModel("SZ9MASTER"):SetDescription(cCadastro)  
 	
Return oModel


/*/{Protheus.doc} ViewDef
ViewDef

@author claudiol
@since 03/03/2016
@version undefined

@type function
/*/
Static Function ViewDef()

Local oModel 	:= FWLoadModel( "FSESTC01" )
Local oStruSZ9:= FWFormStruct( 2, "SZ9" ) 
Local oView	:= Nil

oView:= FWFormView():New()
oView:SetModel(oModel)

oView:AddField("VIEW_SZ9", oStruSZ9, "SZ9MASTER")
oView:CreateHorizontalBox("TELA", 100)
oView:EnableTitleView("VIEW_SZ9")
oView:SetOwnerView("VIEW_SZ9", "TELA")
		
Return oView


/*/{Protheus.doc} MenuDef
MenuDef
@author claudiol
@since 03/03/2016
@version undefined

@type function
/*/
Static Function MenuDef()

Local aRotina	:= {}

ADD OPTION aRotina Title 'Visualizar' 	Action 'VIEWDEF.FSESTC01' OPERATION 2 ACCESS 0

Return aRotina
