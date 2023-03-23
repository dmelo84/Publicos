#Include "Protheus.Ch"
#Include "rwmake.Ch"
#Include "TopConn.Ch"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "FWMBROWSE.CH"


//| TABELA
#DEFINE D_ALIAS 'Z07'
#DEFINE D_TITULO 'Especialidade Conta Contabil'
#DEFINE D_ROTINA 'ALCTBA04'
#DEFINE D_MODEL 'Z07MODEL'
#DEFINE D_MODELMASTER 'Z07MASTER'
#DEFINE D_VIEWMASTER 'VIEW_Z07'

/*/{Protheus.doc} ALCTBA04
Cadastro de vinculo entre Código da especialidade conta contábil
@author Jonatas Oliveira | www.compila.com.br
@since 02/01/2019
@version 1.0
/*/
User Function ALCTBA04(aParam)
	Local oBrowse
	
	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias(D_ALIAS)
	oBrowse:SetDescription(D_TITULO)
	
	oBrowse:DisableDetails()
	
	oBrowse:Activate()
	
Return NIL

/*/{Protheus.doc} MenuDef
Botoes do MBrowser
@author Jonatas Oliveira | www.compila.com.br
@since 02/01/2019
@version 1.0
/*/
Static Function MenuDef()
	Local aRotina := {}
	
	ADD OPTION aRotina TITLE 'Pesquisar'  ACTION 'PesqBrw'           OPERATION 1 ACCESS 0
	ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.'+D_ROTINA OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE 'Incluir'    ACTION 'VIEWDEF.'+D_ROTINA OPERATION 3 ACCESS 0
	ADD OPTION aRotina TITLE 'Alterar'    ACTION 'VIEWDEF.'+D_ROTINA OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE 'Excluir'    ACTION 'VIEWDEF.'+D_ROTINA OPERATION 5 ACCESS 0
	ADD OPTION aRotina TITLE 'Imprimir'   ACTION 'VIEWDEF.'+D_ROTINA OPERATION 8 ACCESS 0
Return aRotina

/*/{Protheus.doc} ModelDef
Definicoes do Model
@author Jonatas Oliveira | www.compila.com.br
@since 02/01/2019
@version 1.0
/*/
Static Function ModelDef()
	// Cria a estrutura a ser usada no Modelo de Dados
	Local oStruct := FWFormStruct( 1, D_ALIAS, /*bAvalCampo*/,/*lViewUsado*/ )
	//Local oStruZG7 := FWFormStruct( 1, 'ZG7', /*bAvalCampo*/,/*lViewUsado*/ )
	Local oModel
	
	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New(D_MODEL, /*bPreValidacao*/, /*bPosValidacao*/,  /*bCommit*/ , /*bCancel*/ )
	
	// Adiciona ao modelo uma estrutura de formulário de edição por campo
	oModel:AddFields( D_MODELMASTER, /*cOwner*/, oStruct, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
	
	// Adiciona ao modelo uma estrutura de formulário de edição por grid
	//oModel:AddGrid( 'ZG7DETAIL', 'ZK7MASTER', oStruZG7, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
	
	// Faz relaciomaneto entre os compomentes do model
	//oModel:SetRelation( 'ZG7DETAIL', { { 'ZG7_FILIAL', 'ZK7_FILIAL' }, { 'ZG7_CODIGO', 'ZK7_CODIGO' } }, 'ZG7_FILIAL + ZG7_CODIGO' )
	
	// Liga o controle de nao repeticao de linha
	//oModel:GetModel( 'ZG7DETAIL' ):SetUniqueLine( { 'ZG7_CHAVE' } )
	
	// Indica que é opcional ter dados informados na Grid
	//oModel:GetModel( 'ZG7DETAIL' ):SetOptional(.T.)
		
	// Adiciona a descricao do Modelo de Dados
	oModel:SetDescription( D_TITULO )
	
	// Adiciona a descricao do Componente do Modelo de Dados
	//oModel:GetModel( 'ZK7MASTER' ):SetDescription( 'Cadastro de função de representantes' )
	//oModel:GetModel( 'ZG7DETAIL' ):SetDescription( 'Config. Sistemas Protheus Connector'  )
	
	// Liga a validação da ativacao do Modelo de Dados
	//oModel:SetVldActivate( { |oModel| COMP011ACT( oModel ) } )
	
Return oModel

/*/{Protheus.doc} ViewDef
Definicoes da View
@author Jonatas Oliveira | www.compila.com.br
@since  02/01/2019
@version 1.0
/*/
Static Function ViewDef()
	// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
	Local oModel   := FWLoadModel( D_ROTINA )
	// Cria a estrutura a ser usada na View
	Local oStruct := FWFormStruct( 2, D_ALIAS )
	//Local oStruZK7 := FWFormStruct( 2, 'ZK7', { |cCampo| COMP11STRU(cCampo) } )
	Local oView
	
	//Local oStruCSW := FWFormStruct( 1, 'CSW', /*bAvalCampo*/, /*lViewUsado*/ )
	//Local oModel
	
	//oStruCSW:RemoveField( 'CSW_ENT' )
	
	//oModel:SetPrimaryKey({"ZK7_CODIGO"})
	
	// Cria o objeto de View
	oView := FWFormView():New()
	
	// Define qual o Modelo de dados será utilizado
	oView:SetModel( oModel )
	
	//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
	oView:AddField( D_VIEWMASTER, oStruct, D_MODELMASTER )
	
	// Criar um "box" horizontal para receber algum elemento da view
	oView:CreateHorizontalBox( 'SUPERIOR' , 100 )
	
	// Relaciona o ID da View com o "box" para exibicao
	oView:SetOwnerView( D_VIEWMASTER, 'SUPERIOR' )
	
	oView:SetCloseOnOk({||.T.})
		
	// Define campos que terao Auto Incremento
	//oView:AddIncrementField( 'VIEW_ZG7', 'ZG7_ITEM' )
	
	// Criar novo botao na barra de botoes no antigo Enchoice Bar
	// oView:AddUserButton( 'Inclui Linha', 'CLIPS', { |oView| VldDados() } )
	
	// Liga a identificacao do componente
	//oView:EnableTitleView('VIEW_ZG7','UNIDADES')
	
	// Liga a Edição de Campos na FormGrid
	//oView:SetViewProperty( 'VIEW_ZG7', "ENABLEDGRIDDETAIL", { 60 } )
	
Return oView
