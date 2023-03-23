#Include "Protheus.Ch"
#Include "rwmake.Ch"
#INCLUDE "TOPCONN.CH"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "FWMBROWSE.CH"      
#INCLUDE 'TBICONN.CH'


/* - FWMVCDEF
MODEL_OPERATION_INSERT para inclusão;
MODEL_OPERATION_UPDATE para alteração;
MODEL_OPERATION_DELETE para exclusão.
MODEL_OPERATION_VIEW para exclusão.
*/

#DEFINE D_TITULO 'Regra - Reembolso de Despesas'     
#DEFINE D_ROTINA 'CP07004' 


/*/{Protheus.doc} ${CP07004}
Reembolso de Despesa - Interface utilizada pelo usuario para 
realizar lancamentos.
@author Augusto Ribeiro | www.compila.com.br
@since 08/12/2014
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
User function CP07004() 
//Local oBrowse  
Local cQuery 		:= ""

Private c_CODCLI		:= ""
Private c_LOJACLI		:= ""

Private xRetCon

Private _LCOPIA		:= .F.
 



oBrowse := FWMBrowse():New()
oBrowse:SetAlias('ZA5')                         
//oBrowse:SetMenuDef( "ATEC204" )                   // Define de onde virao os botoes deste browse
oBrowse:SetDescription(D_TITULO)

    
    

/*
oBrowse:AddLegend( "ZA4->ZA4_STATUS == 'AC00'", "BR_BRANCO", "Não Atribuído" )
oBrowse:AddLegend( "ZA4->ZA4_STATUS == 'AC01'", "BR_AMARELO", "Pendente CEF" )
oBrowse:AddLegend( "ZA4->ZA4_STATUS == 'AC02'", "BR_PRETO", "Compras" )
oBrowse:AddLegend( "ZA4->ZA4_STATUS == 'AC03'", "BR_MARROM", "Quarterizado" )
oBrowse:AddLegend( "ZA4->ZA4_STATUS == 'AC04'", "BR_PINK", "Orçamento" )
oBrowse:AddLegend( "ZA4->ZA4_STATUS == 'AC05'", "BR_CINZA", "Em Execução" )
oBrowse:AddLegend( "ZA4->ZA4_STATUS == 'AC06'", "BR_LARANJA", "A Agendar" )
oBrowse:AddLegend( "ZA4->ZA4_STATUS == 'AC07'", "BR_AZUL", "Agendado" )
oBrowse:AddLegend( "ZA4->ZA4_STATUS == 'AC08'", "BR_VERMELHO", "Pendente PSAA" )
oBrowse:AddLegend( "ZA4->ZA4_STATUS == 'AC09'", "BR_VERDE_ESCURO", "Fechado Sem Homologação" )
oBrowse:AddLegend( "ZA4->ZA4_STATUS == 'AC10'", "BR_VERDE", "Fechado Com Homologação" )
*/


//oBrowse:DisableDetails()

oBrowse:Activate()

Return NIL

        
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ CP07004  ºAutor  ³Augusto Ribeiro     º Data ³ 07/01/2011  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ 	Botoes do MBrowser                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/  

Static Function MenuDef()
Local aRotina := {}


ADD OPTION aRotina TITLE 'Pesquisar'  ACTION 'PesqBrw'             OPERATION 1 ACCESS 0
ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.'+D_ROTINA OPERATION 2 ACCESS 0                         
ADD OPTION aRotina TITLE 'Incluir'  ACTION 'VIEWDEF.'+D_ROTINA OPERATION 3 ACCESS 0  	
ADD OPTION aRotina TITLE 'Alterar'    ACTION 'VIEWDEF.'+D_ROTINA OPERATION 4 ACCESS 0
ADD OPTION aRotina TITLE 'Excluir'    ACTION 'VIEWDEF.'+D_ROTINA OPERATION 5 ACCESS 0
ADD OPTION aRotina TITLE 'Copiar'     ACTION 'VIEWDEF.'+D_ROTINA OPERATION 9 ACCESS 0
ADD OPTION aRotina TITLE 'Imprimir'   ACTION 'VIEWDEF.'+D_ROTINA OPERATION 8 ACCESS 0
//ADD OPTION aRotina TITLE 'TESTE'     ACTION 'U_FAT01TST()' OPERATION 9 ACCESS 0
ADD OPTION aRotina TITLE 'Legenda'  ACTION 'eval(oBrowse:aColumns[1]:GetDoubleClick())'             OPERATION 1 ACCESS 0


Return aRotina




/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ CP07004  ºAutor  ³Augusto Ribeiro     º Data ³ 19/11/2013  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ 	Definicoes do Model                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/  
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oStruZA5 := FWFormStruct( 1, 'ZA5', /*bAvalCampo*/,/*lViewUsado*/ )
Local oStruZA6 := FWFormStruct( 1, 'ZA6', /*bAvalCampo*/,/*lViewUsado*/ )
Local oStruZA7 := FWFormStruct( 1, 'ZA7', /*bAvalCampo*/,/*lViewUsado*/ )
Local oStruZA8 := FWFormStruct( 1, 'ZA8', /*bAvalCampo*/,/*lViewUsado*/ )
Local oModel   

Local bVldPosFull	:= { |oModel| VLDMODEL('MODEL_POS', oModel) }
Local bLinePre := {|oModel| linePreGrid(oModel)}


// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New(D_ROTINA+'MODEL', /*bPreValidacao*/, bVldPosFull /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )
//oModel := MPFormModel():New('ATEC204MODEL', /*bPreValidacao*/,/*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'ZA5CABEC', /*cOwner*/, oStruZA5, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
oModel:AddGrid( 'ZA6APROV', 'ZA5CABEC', oStruZA6, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
oModel:AddGrid( 'ZA7PREENC', 'ZA5CABEC', oStruZA7, bLinePre, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
oModel:AddGrid( 'ZA8VINCULO', 'ZA5CABEC', oStruZA8, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )


//oModel:AddGrid( 'ZA3VALEMP', 'ZA2ITENS', oStruZA3, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )


// Faz relaciomaneto entre os compomentes do model                                                                           
oModel:SetRelation( 'ZA6APROV',		{{ 'ZA6_FILIAL', 'XFILIAL("ZA6")' }, { 'ZA6_CODIGO', 'ZA5_CODIGO' }} ,  ZA6->(IndexKey(1)) )   
oModel:SetRelation( 'ZA7PREENC',	{{ 'ZA7_FILIAL', 'XFILIAL("ZA7")' }, { 'ZA7_CODIGO', 'ZA5_CODIGO' }} ,  ZA7->(IndexKey(1)) )
oModel:SetRelation( 'ZA8VINCULO',	{{ 'ZA8_FILIAL', 'XFILIAL("ZA8")' }, { 'ZA8_CODIGO', 'ZA5_CODIGO' }} ,  ZA8->(IndexKey(1)) )


//oModel:SetRelation( 'ZA3VALEMP',	{{ 'ZA3_FILIAL', 'ZA1_FILIAL' }, { 'ZA3_CODIGO', 'ZA1_CODIGO' } , { 'ZA3_REV', 'ZA1_REV' }},"ZA3_FILIAL+ZA3_CODIGO+ZA3_REV" )


// Liga o controle de nao repeticao de linha
oModel:GetModel( 'ZA6APROV' ):SetUniqueLine( { 'ZA6_ITEM' } )
oModel:GetModel( 'ZA7PREENC' ):SetUniqueLine( { 'ZA7_ITEM' } )
oModel:GetModel( 'ZA8VINCULO' ):SetUniqueLine( { 'ZA8_ITEM' } )



// Indica que é opcional ter dados informados na Grid
// oModel:GetModel( 'ZA6SERV' ):SetOptional(.T.) //| Removido Serviços Executados - Sol. Adriano


// Adiciona a descricao do Modelo de Dados
oModel:SetDescription(D_TITULO)

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'ZA5CABEC' ):SetDescription( 'Regra - Reembolso de Despesa' )      
oModel:GetModel( 'ZA6APROV' ):SetDescription( 'Aprovadores' )
oModel:GetModel( 'ZA7PREENC' ):SetDescription( 'Preenchimento' )
oModel:GetModel( 'ZA8VINCULO' ):SetDescription( 'Referências' )

     
//oModel:GetModel( 'ZA2COMPROV' ):SetOptional(.T.)
//oModel:GetModel( 'ZA3VINCULO' ):SetOptional(.T.)         
       
// Liga a validação da ativacao do Modelo de Dados
//oModel:SetVldActivate( { |oModel,cAcao| U_CP704VLD('MODEL_ACTIVE', oModel) } )

Return oModel


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ CP07004  ºAutor  ³Augusto Ribeiro     º Data ³ 07/01/2011  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ 	Definicoes da View                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/  
Static Function ViewDef()
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   := FWLoadModel( D_ROTINA )
// Cria a estrutura a ser usada na View
Local oStruZA5 := FWFormStruct( 2, 'ZA5')
Local oStruZA6 := FWFormStruct( 2, 'ZA6')
Local oStruZA7 := FWFormStruct( 2, 'ZA7')
Local oStruZA8 := FWFormStruct( 2, 'ZA8')
Local nOperation := oModel:GetOperation()
Local oView   

//Local oStruCSW := FWFormStruct( 1, 'CSW', /*bAvalCampo*/, /*lViewUsado*/ ) 
//Local oModel
                                   

//oStruCSW:RemoveField( 'CSW_ENT' )
                        
// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_ZA5', oStruZA5, 'ZA5CABEC' )
oView:AddGrid( 'VIEW_ZA6', oStruZA6, 'ZA6APROV' )
oView:AddGrid( 'VIEW_ZA7', oStruZA7, 'ZA7PREENC' )
oView:AddGrid( 'VIEW_ZA8', oStruZA8, 'ZA8VINCULO' )


// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'TOP'	, 30 )
oView:CreateHorizontalBox( 'BOTTOM'	, 70)

// Cria Folder na view
oView:CreateFolder( 'PASTAS' ,'BOTTOM')
// Cria pastas nas folders
oView:AddSheet( 'PASTAS', 'ABA01', 'Aprovadores' )
oView:AddSheet( 'PASTAS', 'ABA02', 'Preenchimento')
oView:AddSheet( 'PASTAS', 'ABA03', 'Referências')

oView:CreateHorizontalBox( 'BOX_ABA01'  , 100,,, 'PASTAS', 'ABA01' )
oView:CreateHorizontalBox( 'BOX_ABA02'  , 100,,, 'PASTAS', 'ABA02' )
oView:CreateHorizontalBox( 'BOX_ABA03'  , 100,,, 'PASTAS', 'ABA03' )

 	          
//oView:CreateVerticalBox( 'RIGHT_BOT'		, 40,'BOTTOM')
//oView:CreateHorizontalBox( 'RIGHT_SUP1'	, 80,'RIGHT_SUP') 	
//oView:CreateHorizontalBox( 'RIGHT_SUP2'	, 20,'RIGHT_SUP')
                                          
/*
// Cria Folder na view
oView:CreateFolder( 'PASTAS' ,'INFERIOR')
// Cria pastas nas folders
oView:AddSheet( 'PASTAS', 'ABA01', 'Valores' )
oView:AddSheet( 'PASTAS', 'ABA02', 'Controle'      )

// Criar um "box" horizontal Dentro das Abas
oView:CreateVerticalBox( 'LEFT_AB1'  , 60,,, 'PASTAS', 'ABA01' ) 
oView:CreateVerticalBox( 'RIGHT_AB2'  , 40,,, 'PASTAS', 'ABA01' ) 
oView:CreateHorizontalBox( 'VEND'  , 100,,, 'PASTAS', 'ABA02' )
*/


// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_ZA5', 'TOP')
oView:SetOwnerView( 'VIEW_ZA6', 'BOX_ABA01')
oView:SetOwnerView( 'VIEW_ZA7', 'BOX_ABA02')
oView:SetOwnerView( 'VIEW_ZA8', 'BOX_ABA03')


// Define campos que terao Auto Incremento
oView:AddIncrementField( 'VIEW_ZA6', 'ZA6_ITEM' )
oView:AddIncrementField( 'VIEW_ZA7', 'ZA7_ITEM' )
oView:AddIncrementField( 'VIEW_ZA8', 'ZA8_ITEM' )

//oView:AddOtherObject("ABAIXO_CAL", {|oPanel| U_FAT01BCAL(oPanel)})
//oView:SetOwnerView("ABAIXO_CAL",'RIGHT_SUP2')



// Criar novo botao na barra de botoes no antigo Enchoice Bar            
//oView:AddUserButton( 'Imprimir', 'IMPRESSAO', { |oView| U_RTEC001(oView,.T.) } )
//oView:AddUserButton( 'Gera calendario', 'CALENDARIO', { |oView| ALTER("TESTE") } )

// Liga a identificacao do componente
/*
oView:EnableTitleView('VIEW_ZA1')
oView:EnableTitleView('VIEW_ZA2')
oView:EnableTitleView('VIEW_ZA3')
*/

// Liga a Edição de Campos na FormGrid
//oView:SetViewProperty( 'VIEW_ZA5'		, "ENABLEDGRIDDETAIL", { 60 } )   

/*
oView:SetFieldAction(  'ZA1_DATINI',  {  |oView,  cIDView,  cField,  xValue|  GERACAL(  oView,  cIDView, cField, xValue ) } )
oView:SetFieldAction(  'ZA1_DATFIM',  {  |oView,  cIDView,  cField,  xValue|  GERACAL(  oView,  cIDView, cField, xValue ) } )
oView:SetFieldAction(  'ZA1_PERMED',  {  |oView,  cIDView,  cField,  xValue|  GERACAL(  oView,  cIDView, cField, xValue ) } )
oView:SetFieldAction(  'ZA1_FORMPG',  {  |oView,  cIDView,  cField,  xValue|  GERACAL(  oView,  cIDView, cField, xValue , .F.) } )
oView:SetFieldAction(  'ZA1_DINIME',  {  |oView,  cIDView,  cField,  xValue|  GERACAL(  oView,  cIDView, cField, xValue ) } )

oView:SetFieldAction(  'ZA2_FORMPG',  {  |oView,  cIDView,  cField,  xValue| GERACAL(  oView,  cIDView, cField, xValue ) } )
oView:SetFieldAction(  'ZA2_TIPMED',  {  |oView,  cIDView,  cField,  xValue| TIPOMED(  oView,  cIDView, cField, xValue ) } )
oView:SetFieldAction(  'ZA2_CODPRO',  {  |oView,  cIDView,  cField,  xValue| TIPOMED(  oView,  cIDView, cField, xValue ) } )
*/

oView:SetCloseOnOk({||.T.})
  
Return oView






/*/{Protheus.doc} ${CP704VLD}
  Validações de LinOK, Pre e Pós do MVC
  @author Augusto Ribeiro | www.compila.com.br
  @since 08/12/2014
  @version 1.0
  @param ${cModel}, ${c}, ${Chave para validacaos}
  @param ${oModel}, ${O}, ${Objeto Model}
  @return ${return}, ${return_description}
  @example
  (examples)
  @see (links_or_references)
  /*/  
User Function CP704VLD(cModel, oModel)
Local lRet	:= .F.
Local nOperation := oModel:GetOperation()
Local oModeZAF, oModeZA5, oModeZA6
Local cNextrev, cQuery
Local aAreaZAF
Local nY, nI, nLenMod, nLinAtu, nTotLen
Local cMsgErro	:= ""


IF oModel:ACONTROLS[4] == 7
	_LCOPIA	:= .T.
ELSE
	_LCOPIA	:= .F.
ENDIF 



IF cModel == "MODEL_ACTIVE"
	lRet	:= .T.
ELSE
	lRet	:= .T.
ENDIF


Return(lRet)






/*/{Protheus.doc} ${CP704CPO}
User function para validacao dos fontes
@author Augusto Ribeiro | www.compila.com.br
@since 08/12/2014
@version 1.0
@param ${cCampo}, ${C}, ${Nome do Campo}
@param ${cTipo}, ${C}, ${cTipo: V = Validacao, W = When, I = Inicializar Padrao}
@param ${aParamAdd}, ${A}, ${Parametros adicionais}
@return ${xRet}, ${Tipo de Retorno depende da operacao e tipo de campo quando inicializar padrao}
@example
(examples)
@see (links_or_references)
/*/  
User Function CP704CPO(cCampo, cTipo, aParamAdd)
Local xRet
Local cCodUser
Local nPosCpo
Local oModel 		:= FWModelActive()
Local nOperation	:= oModel:GetOperation()
Local aAreaZAF 	:= {}

Default cCampo		:= ''
Default cTipo			:= "V"
Default aParamAdd		:= {}

cCampo := alltrim(cCampo)

/*-------------------------------------
 	VALIDACAO
--------------------------------------*/
IF cTipo == "V"
	//| Default
	xRet	:= .T.

	IF cCampo == "ZA5_CONPAG"
	
		//aTeste		:= Condicao(100,"003",0,dDataBase,0)
		
	ENDIF
	
	
/*--------------------------------------
	MODO DE EDICAO - WHEN
---------------------------------------*/
ELSEIF cTipo == "W"
	//| Default
	xRet	:= .T.

	IF cCampo == "ZAF_CODIGO"

		//| INCLUSAO DIFERENTE DE COPIA
		IF !(nOperation == MODEL_OPERATION_INSERT .AND. oModel:ACONTROLS[4] == 3)
			xRet	:= .F.			
		ENDIF	
	ENDIF	
	

/*--------------------------------------
	INICIALIZADOR PADRAO 
---------------------------------------*/
ELSEIF cTipo == "I"
	//| Default
	xRet	:= CRIAVAR(cCampo, .F.)

	IF cCampo == "ZAF_CODREG"
	
		IF !EMPTY(aParamAdd)
			cCodUser	:= aParamAdd[1]
		ELSE
			cCodUser	:= __CUSERID
		ENDIF
		
		DBSELECTAREA("ZA0")
		ZA0->(DBSETORDER(1)) //| ZA0_FILIAL, ZA0_CODIGO
		IF ZA0->(DBSEEK(xfilial("ZA0")+cCodUser)) 
			xRet	:= ZA0->ZA0_CODREG 				
		ENDIF
		
	ENDIF
	
ENDIF


Return(xRet)






/*/{Protheus.doc} ${CP704GAT}
 Funcao para execucao de gatilho          
@author Augusto Ribeiro | www.compila.com.br
@since 08/12/2014
@version 1.0
@param ${cCampo}, ${C}, ${Campo}
@param ${cContra}, ${C}, ${Campo Contra Dominio}
@return ${xRet}, ${Retorno do tipo indefinido pois depende o campo contra domino}
@example
(examples)
@see (links_or_references)
/*/
  
User Function CP704GAT(cCampo, cContra)
Local xRet

Default cCampo := "" 

cCampo := alltrim(cCampo)

IF cCampo == "ZAF_CODPRO" .AND. cContra == "ZAF_VLRUNI"


	xRet	:= 1
//	xRet	:= POSICIONE("SB1",1,XFILIAL("SB1")+ , "B1_UM" )

ENDIF


Return(xRet)


/*/{Protheus.doc} ${CP704CON}
Consulta padrão (Customizada) | SXB:  CP0701
@author Augusto Ribeiro | www.compila.com.br
@since 09/12/2014
@version 1.0
@param ${param}, ${param_type}, ${param_descr}
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/  
User Function CP704CON()
Local cRet			:= ""
Local lRetAux, cAliasTab, cIndChv, cCpoDesc, cConsPad
Local lRet			:= .F.
Local oModFull	:= FWModelActive()
Local oModeZA3	:= oModFull:GetModel('ZA3VINCULO')
Local oView		:= FWViewActive()



//| ### REVISAR
cAliasTab	:= "SA1"
cIndChv	:= "1"
cCpoDesc	:= "A1_NOME"
cConsPad	:= "SA1"


lRetAux := ConPad1(,,,cConsPad,"A1_COD",,.F. )
 
 If lRetAux
			
	//cChvReg	:= &("SA1->("+SA1->(IndexKey(1))+")")
	//nRecReg	:= SA1->(RECNO())
	
	
	
	dbSelectArea(cAliasTab)
	xRetCon	:= FieldGet(FieldPos(cCpoDesc))
	
	oModeZA3:LoadValue("ZA3_INDCHV", cIndChv)	
	oModeZA3:LoadValue("ZA3_CHVREG", &(cAliasTab+"->("+IndexKey(1)+")")) 
	oModeZA3:LoadValue("ZA3_RECREG", RECNO())
	
	
	//ALERT(cChvReg)
	//ALERT(nRecReg)
	
	oView:Refresh()
	
	lRet	:= .T.
 EndiF

Return(lRet)

/*/{Protheus.doc} ${CP704DES}
Retorna Descricao do registro conforme configuracao da Regra
@author Augusto Ribeiro | www.compila.com.br
@since 10/12/2014
@version 1.0
@param ${cCodRegra}, ${C}, ${Codigo da Regra de reembolso}
@param ${cAliasTab}, ${C}, ${Alias da Tabela de Vinculo / Referencia}
@param ${nRecno}, ${N}, ${Recno do Registro}
@return ${cRet}, ${Retorno do campo descricao cadastrado na regra de reembolso}
@example
(examples)
@see (links_or_references)
/*/  
User Function CP704DES(cCodRegra, cAliasTab, nRecno)
Local cRet := ""

//| ### REVISAR
IF !EMPTY(cCodRegra) .AND. !EMPTY(cAliasTab) .AND. !EMPTY(nRecno)  

	DBSELECTAREA(cAliasTab)
	DBGOTO(nRecno)
	
	cCpoDesc	:= "A1_NOME"
	cRet		:= FieldGet(FieldPos(cCpoDesc))
	

ENDIF

Return(cRet)



/*/{Protheus.doc} ${VLDMODEL}
Reliza validações da modelo de acordo envento enviado
@author Augusto Ribeiro | www.compila.com.br
@since 09/01/2015
@version 1.0
@param ${cModel}, ${c}, ${Nome da Model e envento a ser validado}
@param ${oModel}, ${o}, ${Model MAIN do MVC}
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function VLDMODEL(cModel, oModel)
Local lRet			:= .F.
Local cMsgErro	:= ""
Local nOperation := oModel:GetOperation()
Local oModeZAF, oModeZA2, oModeZA3
Local nI, nTotLen

Local cNomeArq, cDirLixo, cFullOrig, cFullDest

Default cModel	:= ""


IF oModel:ACONTROLS[4] == 7
	_LCOPIA	:= .T.
ELSE
	_LCOPIA	:= .F.
ENDIF 

IF cModel == "MODEL_POS"

	//Incluir validação de linha

ENDIF

IF EMPTY(cMsgErro)
	lRet	:= .T.
ELSE
	lRet	:= .F.
	Help(" ",1,cModel,,cMsgErro,4,5)
	
ENDIF


Return(lRet)

static function linePreGrid(oModel)

Local oModelAlt  := FwModelActive() 
Local nLinha     := oModel:nLine
//Local nPosCampo  := Ascan(oModel:aHeader,{|x| Alltrim(x[2]) == "ZA7_CODNAT"} )
Local cConteudo  := oModel:getValue('ZA7_CODNAT',nLinha)
Local lRet := .T.

//if oModel:aHeader[nposCampo][2] == "ZA7_CODNAT"
	if !empty(cConteudo)
		cDesNat := Posicione("SED",1,xFilial("SED")+cConteudo,"ED_DESCRIC")
		oModelAlt:loadValue('ZA7PREENC','ZA7_DESNAT',cDesNat)
	endIf
//endif

return lRet

