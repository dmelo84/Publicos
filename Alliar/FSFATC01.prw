#Include "Protheus.ch"
#Include "FWMVCDef.ch"

/*/{Protheus.doc} FSFATC01
Visualiza tabela SZ7 

@type function
@author Alex Teixeira de Souza
@since 15/01/2016
@version 1.0
@param 
@return ${aRet}, ${Codigo do erro, Descricao do Erro}
@example
(examples)
@see (links_or_references)
/*/
User Function FSFATC01()
Local oBrowse 	:= FWMBrowse():New()
Local aRotBkp		:= aRotina 

aRotina := {}

oBrowse:SetAlias("SZ7")
oBrowse:SetDescription("Formas de pagamento do pedido de venda")
oBrowse:SetMenuDef("FSFATC01")
oBrowse:SetAmbiente(.F.)
oBrowse:DisableDetails()
oBrowse:SetFilterDefault( "SZ7->Z7_FILIAL == '"+SC5->C5_FILIAL+"' .AND. SZ7->Z7_PEDIDO = '"+SC5->C5_NUM+"' " )
oBrowse:Activate()

aRotina := aRotBkp	

Return(Nil)


/*/{Protheus.doc} MENUDEF
Menus da Rotina

@author Alex T. Soiza
@since 19/01/2016
@version 1.0
@param 
@return aRotina
@example  
/*/
//------------------------------------------------------------------- 
Static Function MenuDef()

Local aRotina := {}

ADD OPTION aRotina Title 'Visualizar' 	Action 'VIEWDEF.FSFATC01' OPERATION 2 ACCESS 0
ADD OPTION aRotina Title 'Imprimir' 	Action 'VIEWDEF.FSFATC01' OPERATION 8 ACCESS 0

Return(aRotina)

/*/{Protheus.doc} MODELDEF
Modelos da Rotina

@author Alex T. Soiza
@since 19/01/2016
@version 1.0
@param 
@return oModel
@example  
/*/
//------------------------------------------------------------------- 
Static Function ModelDef()

Local oModel		:= MPFormModel():New('FATC01FS')
Local oStruct 	:= FWFormStruct(1,"SZ7" )

oModel:AddFields('SZ7MASTER',,oStruct) 
oModel:SetPrimaryKey({'Z7_FILIAL','Z7_PEDIDO'})

Return(oModel) 

/*/{Protheus.doc} VIEWDEF
Objeto de inteface

@author Alex T. Soiza
@since 19/01/2016
@version 1.0
@param 
@return oView
@example  
/*/
//-------------------------------------------------------------------
Static Function ViewDef()

Local oView 		:= FWFormView():New()
Local oModel		:= FWLoadModel('FSFATC01')
Local oStruct 	:= FWFormStruct(2,"SZ7") 
 
oView:SetModel(oModel)

oView:AddField('VIEW_SZ7',oStruct,'SZ7MASTER')
oView:CreateHorizontalBox('TELA',100)
oView:SetOwnerView('VIEW_SZ7','TELA')

Return(oView)