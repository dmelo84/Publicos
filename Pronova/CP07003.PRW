#Include "Protheus.Ch"
#Include "rwmake.Ch"
#Include "TopConn.Ch"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "FWMBROWSE.CH"      


//| TABELA
#DEFINE D_ALIAS 'ZA0'
#DEFINE D_TITULO 'Cadastro de Usuarios - Reembolso de Depesas'
#DEFINE D_ROTINA 'CP07003'
#DEFINE D_MODEL 'ZA0MODEL'
#DEFINE D_MODELMASTER 'ZA0MASTER'
#DEFINE D_VIEWMASTER 'VIEW_ZA0'


/*/{Protheus.doc} ${CP07003}
Modelo 1 MVC
@author Augusto Ribeiro | www.compila.com.br
@since 15/01/2015
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
User Function CP07003(aParam)
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetAlias(D_ALIAS)
oBrowse:SetDescription(D_TITULO)

//oBrowse:AddLegend( "ZA0_TIPO=='I'", "BLUE"  , "Interprete"  )
//oBrowse:SetFilterDefault( "ZA0_TIPO=='C'" )
//oBrowse:SetFilterDefault( "Empty(ZA0_DTAFAL)" )
// UsrExist(M->CN9_USUAVA)
oBrowse:DisableDetails()

oBrowse:Activate()

Return NIL

        
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ CP07003  บAutor  ณAugusto Ribeiro     บ Data ณ 07/01/2012  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ 	Botoes do MBrowser                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/  
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE 'Pesquisar'  ACTION 'PesqBrw'             OPERATION 1 ACCESS 0
ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.'+D_ROTINA OPERATION 2 ACCESS 0
ADD OPTION aRotina TITLE 'Incluir'    ACTION 'VIEWDEF.'+D_ROTINA OPERATION 3 ACCESS 0
ADD OPTION aRotina TITLE 'Alterar'    ACTION 'VIEWDEF.'+D_ROTINA OPERATION 4 ACCESS 0
ADD OPTION aRotina TITLE 'Excluir'    ACTION 'VIEWDEF.'+D_ROTINA OPERATION 5 ACCESS 0
//ADD OPTION aRotina TITLE 'Reprocessar'   ACTION 'U_PCON04RP()' OPERATION 4 ACCESS 0
ADD OPTION aRotina TITLE 'Imprimir'   ACTION 'VIEWDEF.CP07003' OPERATION 8 ACCESS 0
//ADD OPTION aRotina TITLE 'Copiar'     ACTION 'VIEWDEF.CP07003' OPERATION 9 ACCESS 0
Return aRotina




/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ CP07003  บAutor  ณAugusto Ribeiro     บ Data ณ 07/01/2011  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ 	Definicoes do Model                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/  
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oStruct := FWFormStruct( 1, D_ALIAS, /*bAvalCampo*/,/*lViewUsado*/ )
Local oStruZAE := FWFormStruct( 1, 'ZAE', /*bAvalCampo*/,/*lViewUsado*/ )
//Local oStruZG7 := FWFormStruct( 1, 'ZG7', /*bAvalCampo*/,/*lViewUsado*/ )
Local oModel   

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New(D_MODEL, /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

// Adiciona ao modelo uma estrutura de formulแrio de edi็ใo por campo
oModel:AddFields( D_MODELMASTER, /*cOwner*/, oStruct, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
oModel:AddGrid( 'ZAEITEM', D_MODELMASTER, oStruZAE, /*bLinePre*/{|oGrid| u_vldCampo(oGrid)}, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )  

// Adiciona ao modelo uma estrutura de formulแrio de edi็ใo por grid
//oModel:AddGrid( 'ZG7DETAIL', 'ZK7MASTER', oStruZG7, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

// Faz relaciomaneto entre os compomentes do model
//oModel:SetRelation( 'ZG7DETAIL', { { 'ZG7_FILIAL', 'ZK7_FILIAL' }, { 'ZG7_CODIGO', 'ZK7_CODIGO' } }, 'ZG7_FILIAL + ZG7_CODIGO' )
oModel:SetRelation( 'ZAEITEM',	{{ 'ZAE_FILIAL', 'XFILIAL("ZAE")' }, { 'ZAE_CODIGO', 'ZA0_CODIGO' }} ,  ZAE->(IndexKey(1)) )

// Liga o controle de nao repeticao de linha
//oModel:GetModel( 'ZG7DETAIL' ):SetUniqueLine( { 'ZG7_CHAVE' } )

// Indica que ้ opcional ter dados informados na Grid
oModel:GetModel( 'ZAEITEM' ):SetOptional(.T.)


// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( D_TITULO )

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'ZAEITEM' ):SetDescription( 'Usuarios Vinculados' )
//oModel:GetModel( 'ZK7MASTER' ):SetDescription( 'Cadastro de fun็ใo de representantes' )
//oModel:GetModel( 'ZG7DETAIL' ):SetDescription( 'Config. Sistemas Protheus Connector'  )

// Liga a valida็ใo da ativacao do Modelo de Dados
//oModel:SetVldActivate( { |oModel| COMP011ACT( oModel ) } )

Return oModel


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ CP07003  บAutor  ณAugusto Ribeiro     บ Data ณ 07/01/2011  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ 	Definicoes da View                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/  
Static Function ViewDef()
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   := FWLoadModel( D_ROTINA )
// Cria a estrutura a ser usada na View
Local oStruct := FWFormStruct( 2, D_ALIAS )
Local oStruZAE := FWFormStruct( 2, 'ZAE' )
//Local oStruZK7 := FWFormStruct( 2, 'ZK7', { |cCampo| COMP11STRU(cCampo) } )
Local oView   

//Local oStruCSW := FWFormStruct( 1, 'CSW', /*bAvalCampo*/, /*lViewUsado*/ ) 
//Local oModel

//oStruCSW:RemoveField( 'CSW_ENT' )

//oModel:SetPrimaryKey({"ZK7_CODIGO"})

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados serแ utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( D_VIEWMASTER, oStruct, D_MODELMASTER )
oView:AddGrid( 'VIEW_ZAE', oStruZAE, 'ZAEITEM' )
                                                     
// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'SUPERIOR' , 40 )    
oView:CreateHorizontalBox( 'INFERIOR' , 60 )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( D_VIEWMASTER, 'SUPERIOR' )
oView:SetOwnerView( "VIEW_ZAE", 'INFERIOR' )

oView:SetCloseOnOk({||.T.})

  

// Define campos que terao Auto Incremento
oView:AddIncrementField( 'VIEW_ZAE', 'ZAE_ITEM' )


// Criar novo botao na barra de botoes no antigo Enchoice Bar
// oView:AddUserButton( 'Inclui Linha', 'CLIPS', { |oView| VldDados() } )

// Liga a identificacao do componente
//oView:EnableTitleView('VIEW_ZG7','UNIDADES')                    

// Liga a Edi็ใo de Campos na FormGrid
//oView:SetViewProperty( 'VIEW_ZG7', "ENABLEDGRIDDETAIL", { 60 } )

Return oView


/*Valida็ใo de Campos*/

/*/{Protheus.doc} nomeStaticFunction
    (long_description)
    @type  Static Function
    @author user
    @since 21/10/2021
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/


user Function vldCampo(oGrid)

Local oModel   := FwModelActive()
Local cCodigo  := oGrid:GetValue('ZAE_USRVIN')
Local cCodret  := Iif(type("acporet[1]") != "U", acporet[1],"")

If !empty(cCodret)
     oGrid:loadValue("ZAE_NOME", UsrRetName(cCodret) )
else
    If !empty(cCodigo)
        oGrid:loadValue("ZAE_NOME", UsrRetName(cCodigo) )
    Endif
endif
    
Return .T.
