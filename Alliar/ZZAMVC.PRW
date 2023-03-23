#Include "Protheus.Ch"
#Include "rwmake.Ch"
#INCLUDE "TOPCONN.CH"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "FWMBROWSE.CH"
#INCLUDE 'TBICONN.CH'

#DEFINE D_ALIAS 'ZZA'
#DEFINE D_TITULO 'Indicador de Clientes'
#DEFINE D_ROTINA 'ZZAMVC'
#DEFINE D_MODEL 'ZZAMODEL'
#DEFINE D_MODELMASTER 'ZZAMASTER'
#DEFINE D_VIEWMASTER 'VIEW_ZZA'
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ ZZAMVC   บAutor  ณMateus Hengle       บ Data ณ 04/08/2018  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Tela de cadastro em MVC                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/  
User Function ZZAMVC(aParam)

Local oBrowse
oBrowse := FWMBrowse():New()
oBrowse:SetAlias(D_ALIAS)
oBrowse:SetDescription(D_TITULO)
oBrowse:DisableDetails()
oBrowse:Activate()
Return


///////////////////////////////////////////////////////
// MenuDef ////////////////////////////////////////////
/////////////////////////////////////////////////////// 
Static Function MenuDef()
Local aRotina := {}
ADD OPTION aRotina TITLE 'Pesquisar'  ACTION 'PesqBrw'             OPERATION 1 ACCESS 0
ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.'+D_ROTINA OPERATION 2 ACCESS 0
ADD OPTION aRotina TITLE 'Incluir'    ACTION 'VIEWDEF.'+D_ROTINA OPERATION 3 ACCESS 0
ADD OPTION aRotina TITLE 'Alterar'    ACTION 'VIEWDEF.'+D_ROTINA OPERATION 4 ACCESS 0
ADD OPTION aRotina TITLE 'Excluir'    ACTION 'VIEWDEF.'+D_ROTINA OPERATION 5 ACCESS 0 
Return aRotina


///////////////////////////////////////////////////////
// ModelDef //////////////////////////////////////////
/////////////////////////////////////////////////////// 
Static Function ModelDef()
Local oStruct := FWFormStruct( 1, D_ALIAS, /*bAvalCampo*/,/*lViewUsado*/ )
Local oModel   
oModel := MPFormModel():New(D_MODEL, /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )
oModel:AddFields( D_MODELMASTER, /*cOwner*/, oStruct, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )  
//oModel:SetPrimaryKey({'ZZA_FILIAL','ZZA_CODCLI','ZZA_LOJA'})
oModel:SetDescription( D_TITULO )



Return oModel


///////////////////////////////////////////////////////
// ViewDef ////////////////////////////////////////////
/////////////////////////////////////////////////////// 
Static Function ViewDef()
Local oModel   := FWLoadModel( D_ROTINA )
Local oStruct := FWFormStruct( 2, D_ALIAS )
Local oView   
oView := FWFormView():New()
oView:SetModel( oModel )
oView:AddField( D_VIEWMASTER, oStruct, D_MODELMASTER )
oView:CreateHorizontalBox( 'SUPERIOR' , 100 )    
oView:SetOwnerView( D_VIEWMASTER, 'SUPERIOR' )

//|Grupos
oStruct:AddGroup( 'GRUPO01', ''								, '', 1 )
oStruct:AddGroup( 'GRUPO02', 'Tributos Especificos'			, '', 2 )

oStruct:SetProperty( '*'		  , MVC_VIEW_GROUP_NUMBER, 'GRUPO01' )

oStruct:SetProperty( 'ZZA_XTRIBE' , MVC_VIEW_GROUP_NUMBER, 'GRUPO02' )
oStruct:SetProperty( 'ZZA_XTEPIS' , MVC_VIEW_GROUP_NUMBER, 'GRUPO02' )
oStruct:SetProperty( 'ZZA_XTECOF' , MVC_VIEW_GROUP_NUMBER, 'GRUPO02' )
oStruct:SetProperty( 'ZZA_XTECSL' , MVC_VIEW_GROUP_NUMBER, 'GRUPO02' )
oStruct:SetProperty( 'ZZA_XTEIRF' , MVC_VIEW_GROUP_NUMBER, 'GRUPO02' )
oStruct:SetProperty( 'ZZA_XTEINS' , MVC_VIEW_GROUP_NUMBER, 'GRUPO02' )
oStruct:SetProperty( 'ZZA_XBSPIS' , MVC_VIEW_GROUP_NUMBER, 'GRUPO02' )
oStruct:SetProperty( 'ZZA_XBSCOF' , MVC_VIEW_GROUP_NUMBER, 'GRUPO02' )
oStruct:SetProperty( 'ZZA_XBSCSL' , MVC_VIEW_GROUP_NUMBER, 'GRUPO02' )
oStruct:SetProperty( 'ZZA_XBSIRF' , MVC_VIEW_GROUP_NUMBER, 'GRUPO02' )
oStruct:SetProperty( 'ZZA_XBSINS' , MVC_VIEW_GROUP_NUMBER, 'GRUPO02' )
oStruct:SetProperty( 'ZZA_XALPIS' , MVC_VIEW_GROUP_NUMBER, 'GRUPO02' )
oStruct:SetProperty( 'ZZA_XALCOF' , MVC_VIEW_GROUP_NUMBER, 'GRUPO02' )
oStruct:SetProperty( 'ZZA_XALCSL' , MVC_VIEW_GROUP_NUMBER, 'GRUPO02' )
oStruct:SetProperty( 'ZZA_XALIRF' , MVC_VIEW_GROUP_NUMBER, 'GRUPO02' )
oStruct:SetProperty( 'ZZA_XALINS' , MVC_VIEW_GROUP_NUMBER, 'GRUPO02' )

oView:SetCloseOnOk({||.T.})

Return oView   

