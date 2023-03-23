#Include "Protheus.Ch"
#Include "rwmake.Ch"
#INCLUDE "TOPCONN.CH"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "FWMBROWSE.CH"      
#INCLUDE 'TBICONN.CH'


/* - FWMVCDEF
MODEL_OPERATION_INSERT para inclusใo;
MODEL_OPERATION_UPDATE para altera็ใo;
MODEL_OPERATION_DELETE para exclusใo.
MODEL_OPERATION_VIEW para exclusใo.
*/

#DEFINE D_TITULO 'Tabela de Pre็o - Reembolso de Despesas'     
#DEFINE D_ROTINA 'CP07005' 

/*/{Protheus.doc} CP07005
Tabela de Pre็o, Reembolso de Despesa - Interface utilizada pelo usuario 
@author Augusto Ribeiro | www.compila.com.br
@since 21/01/2014
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
User function CP07005() 
//Local oBrowse  
PRIVATE _LCOPIA	:= .F.


Private xRetCon

 



oBrowse := FWMBrowse():New()
oBrowse:SetAlias('ZAA')                         
//oBrowse:SetMenuDef( "ATEC204" )                   // Define de onde virao os botoes deste browse
oBrowse:SetDescription(D_TITULO)

    
    

/*
oBrowse:AddLegend( "ZA4->ZA4_STATUS == 'AC00'", "BR_BRANCO", "Nใo Atribuํdo" )
oBrowse:AddLegend( "ZA4->ZA4_STATUS == 'AC01'", "BR_AMARELO", "Pendente CEF" )
oBrowse:AddLegend( "ZA4->ZA4_STATUS == 'AC02'", "BR_PRETO", "Compras" )
oBrowse:AddLegend( "ZA4->ZA4_STATUS == 'AC03'", "BR_MARROM", "Quarterizado" )
oBrowse:AddLegend( "ZA4->ZA4_STATUS == 'AC04'", "BR_PINK", "Or็amento" )
oBrowse:AddLegend( "ZA4->ZA4_STATUS == 'AC05'", "BR_CINZA", "Em Execu็ใo" )
oBrowse:AddLegend( "ZA4->ZA4_STATUS == 'AC06'", "BR_LARANJA", "A Agendar" )
oBrowse:AddLegend( "ZA4->ZA4_STATUS == 'AC07'", "BR_AZUL", "Agendado" )
oBrowse:AddLegend( "ZA4->ZA4_STATUS == 'AC08'", "BR_VERMELHO", "Pendente PSAA" )
oBrowse:AddLegend( "ZA4->ZA4_STATUS == 'AC09'", "BR_VERDE_ESCURO", "Fechado Sem Homologa็ใo" )
oBrowse:AddLegend( "ZA4->ZA4_STATUS == 'AC10'", "BR_VERDE", "Fechado Com Homologa็ใo" )
*/


//oBrowse:DisableDetails()

oBrowse:Activate()

Return NIL

        
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ CP07005  บAutor  ณAugusto Ribeiro     บ Data ณ 07/01/2011  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ 	Botoes do MBrowser                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/  

Static Function MenuDef()
Local aRotina := {}


ADD OPTION aRotina TITLE 'Pesquisar' 	ACTION 'PesqBrw'             OPERATION 1 ACCESS 0
ADD OPTION aRotina TITLE 'Visualizar'	ACTION 'VIEWDEF.'+D_ROTINA OPERATION 2 ACCESS 0                         
ADD OPTION aRotina TITLE 'Incluir' 	ACTION  'VIEWDEF.'+D_ROTINA OPERATION 3 ACCESS 0  	
ADD OPTION aRotina TITLE 'Alterar'		ACTION 'VIEWDEF.'+D_ROTINA OPERATION 4 ACCESS 0
ADD OPTION aRotina TITLE 'Excluir'		ACTION 'VIEWDEF.'+D_ROTINA OPERATION 5 ACCESS 0
ADD OPTION aRotina TITLE 'Copiar'		ACTION 'VIEWDEF.'+D_ROTINA OPERATION 9 ACCESS 0
ADD OPTION aRotina TITLE 'Imprimir'	ACTION 'VIEWDEF.'+D_ROTINA OPERATION 8 ACCESS 0
//ADD OPTION aRotina TITLE 'TESTE'     ACTION 'U_FAT01TST()' OPERATION 9 ACCESS 0
ADD OPTION aRotina TITLE 'Legenda'  ACTION 'eval(oBrowse:aColumns[1]:GetDoubleClick())'             OPERATION 1 ACCESS 0


// ADD OPTION aRotina TITLE 'Amarra B.I.'  ACTION 'U_EST02MNU("AMARRA")' OPERATION 2 ACCESS 0
Return aRotina



/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ CP07005  บAutor  ณAugusto Ribeiro     บ Data ณ 19/11/2013  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ 	Definicoes do Model                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/  
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oStruZAA := FWFormStruct( 1, 'ZAA', /*bAvalCampo*/,/*lViewUsado*/ )
Local oStruZAB := FWFormStruct( 1, 'ZAB', /*bAvalCampo*/,/*lViewUsado*/ )
Local oModel   

Local bVldPosFull	:= { |oModel| VLDMODEL('MODEL_POS', oModel) }
Local bLPREZA3	:= { |oModel, nLine, cAction, cField| VldLinOK('LPRE_ZA3', oModel, nLine, cAction, cField ) }
Local bLPOSZA3	:= { |oModel, nLine, cAction, cField| VldLinOK('LPOS_ZA3', oModel, nLine, cAction, cField ) }
Local bLinePre := {|oModel| LinePreGrid(oModel)} //DMS - Valida็ใo de campo da Grid


// Cria o objeto do Mod elo de Dados
oModel := MPFormModel():New(D_ROTINA+'MODEL',  /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )
//oModel := MPFormModel():New('ATEC204MODEL', /*bPreValidacao*/,/*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

// Adiciona ao modelo uma estrutura de formulแrio de edi็ใo por campo
oModel:AddFields( 'ZAACABEC', /*cOwner*/, oStruZAA, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
oModel:AddGrid( 'ZABITEM', 'ZAACABEC', oStruZAB, bLinePre, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

// Faz relaciomaneto entre os compomentes do model                                                                           
oModel:SetRelation( 'ZABITEM',	{{ 'ZAB_FILIAL', 'XFILIAL("ZAB")' }, { 'ZAB_CODIGO', 'ZAA_CODIGO' }} ,  ZAB->(IndexKey(1)) )//'ZAB_FILIAL+ZAB_CODIGO' )   

//oModel:SetRelation( 'ZA3VALEMP',	{{ 'ZA3_FILIAL', 'ZAA_FILIAL' }, { 'ZA3_CODIGO', 'ZAA_CODIGO' } , { 'ZA3_REV', 'ZAA_REV' }},"ZA3_FILIAL+ZA3_CODIGO+ZA3_REV" )


// Liga o controle de nao repeticao de linha
oModel:GetModel( 'ZABITEM' ):SetUniqueLine( { 'ZAB_ITEM' } )


// Indica que ้ opcional ter dados informados na Grid
// oModel:GetModel( 'ZA6SERV' ):SetOptional(.T.) //| Removido Servi็os Executados - Sol. Adriano

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription(D_TITULO)

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'ZAACABEC' ):SetDescription( 'Tabela de Pre็o' )      
oModel:GetModel( 'ZABITEM' ):SetDescription( 'Itens' )

/// oModel:GetModel( 'ZA6SERV' ):SetDescription( 'Servi็os' ) //| Removido Servi็os Executados - Sol. Adriano
      
      
//oModel:GetModel( 'ZABCOMPROV' ):SetOptional(.T.)
//oModel:GetModel( 'ZA3VINCULO' ):SetOptional(.T.)         
       
// Liga a valida็ใo da ativacao do Modelo de Dados
// oModel:SetVldActivate( { |oModel,cAcao| U_CP705VLD('MODEL_ACTIVE', oModel) } )
// oModel:SetActivate( {|oModel| U_CP07LZA3(oModel)} )

Return oModel

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ CP07005  บAutor  ณAugusto Ribeiro     บ Data ณ 07/01/2011  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ 	Definicoes da View                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/  
Static Function ViewDef()
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   := FWLoadModel( D_ROTINA )
// Cria a estrutura a ser usada na View
Local oStruZAA := FWFormStruct( 2, 'ZAA' )
Local oStruZAB := FWFormStruct( 2, 'ZAB' )
Local nOperation := oModel:GetOperation()
Local oView   

//Local oStruCSW := FWFormStruct( 1, 'CSW', /*bAvalCampo*/, /*lViewUsado*/ ) 
//Local oModel
                                   
//oStruCSW:RemoveField( 'CSW_ENT' )
                        
// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados serแ utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_ZAA', oStruZAA, 'ZAACABEC' )
oView:AddGrid( 'VIEW_ZAB', oStruZAB, 'ZABITEM' )


// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'TOP' , 20 )
oView:CreateHorizontalBox( 'BOTTOM' , 80) 	          
   

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_ZAA', 'TOP')
oView:SetOwnerView( 'VIEW_ZAB', 'BOTTOM')


// Define campos que terao Auto Incremento
oView:AddIncrementField( 'VIEW_ZAB', 'ZAB_ITEM' )

//oView:AddOtherObject("ABAIXO_CAL", {|oPanel| U_FAT01BCAL(oPanel)})
//oView:SetOwnerView("ABAIXO_CAL",'RIGHT_SUP2')



// Criar novo botao na barra de botoes no antigo Enchoice Bar            
//oView:AddUserButton( 'Imprimir', 'IMPRESSAO', { |oView| U_RTEC001(oView,.T.) } )
//oView:AddUserButton( 'Gera calendario', 'CALENDARIO', { |oView| ALTER("TESTE") } )

// Liga a identificacao do componente
//oView:EnableTitleView('VIEW_ZAA')
//oView:EnableTitleView('VIEW_ZAB')


// Liga a Edi็ใo de Campos na FormGrid
//oView:SetViewProperty( 'VIEW_ZA5'		, "ENABLEDGRIDDETAIL", { 60 } )   

/*
oView:SetFieldAction(  'ZAA_DATINI',  {  |oView,  cIDView,  cField,  xValue|  GERACAL(  oView,  cIDView, cField, xValue ) } )
oView:SetFieldAction(  'ZAA_DATFIM',  {  |oView,  cIDView,  cField,  xValue|  GERACAL(  oView,  cIDView, cField, xValue ) } )
oView:SetFieldAction(  'ZAA_PERMED',  {  |oView,  cIDView,  cField,  xValue|  GERACAL(  oView,  cIDView, cField, xValue ) } )
oView:SetFieldAction(  'ZAA_FORMPG',  {  |oView,  cIDView,  cField,  xValue|  GERACAL(  oView,  cIDView, cField, xValue , .F.) } )
oView:SetFieldAction(  'ZAA_DINIME',  {  |oView,  cIDView,  cField,  xValue|  GERACAL(  oView,  cIDView, cField, xValue ) } )

oView:SetFieldAction(  'ZAB_FORMPG',  {  |oView,  cIDView,  cField,  xValue| GERACAL(  oView,  cIDView, cField, xValue ) } )
oView:SetFieldAction(  'ZAB_TIPMED',  {  |oView,  cIDView,  cField,  xValue| TIPOMED(  oView,  cIDView, cField, xValue ) } )
oView:SetFieldAction(  'ZAB_CODPRO',  {  |oView,  cIDView,  cField,  xValue| TIPOMED(  oView,  cIDView, cField, xValue ) } )
*/

oView:SetCloseOnOk({||.T.})
  
Return oView

/*/{Protheus.doc} CP705VLD
  Valida็๕es de LinOK, Pre e P๓s do MVC
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
User Function CP705VLD(cModel, oModel)
Local lRet	:= .F.
Local nOperation := oModel:GetOperation()
Local oModeZAA, oModeZA5, oModeZA6
Local cNextrev, cQuery
Local nY, nI, nLenMod, nLinAtu, nTotLen
Local cMsgErro	:= ""

IF cModel == "MODEL_ACTIVE"
	lRet	:= .T.
ELSE
	lRet	:= .T.
ENDIF


Return(lRet)

/*/{Protheus.doc} CP705CPO
User function para validacao dos fontes
@author Augusto Ribeiro | www.compila.com.br
@since 08/12/2014
@version 1.0
@param ${cCampo}, ${C}, ${Nome do Campo}
@param ${cTipo}, ${C}, ${cTipo: V = Validacao, W = When}
@return ${lRet}, ${Logico}
@example
(examples)
@see (links_or_references)
/*/  
User Function CP705CPO(cCampo, cTipo)
Local lRet := .T.
Local nPosCpo
Local oModFull 		:= FWModelActive()
Local oModeZAA

Default cCampo		:= ''
Default cTipo		:= "V"

cCampo := alltrim(cCampo)

/*-------------------------------------
  VALIDACAO
--------------------------------------*/
IF cTipo == "V"


	IF cCampo == "ZAA_CODPRO"
	//	lRet	:= U_CP705SB1(M->ZAA_CODPRO)
	
	ENDIF
	
	
/*--------------------------------------
 MODO DE EDICAO - WHEN
---------------------------------------*/
ELSEIF cTipo == "W"

	IF cCampo == "ZAA_CODIGO"

		//| INCLUSAO DIFERNETE DE COPIA
		//IF !(nOperation == MODEL_OPERATION_INSERT .AND. oModel:ACONTROLS[4] == 3)
			//lRet	:= .F.			
		//ENDIF	
	ENDIF	

ENDIF


Return(lRet)

/*/{Protheus.doc} CP705GAT
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
  
User Function CP705GAT(cCampo, cContra)
Local xRet

Default cCampo := "" 

cCampo := alltrim(cCampo)

IF cCampo == "ZAA_CODPRO" .AND. cContra == "ZAA_VLRUNI"


	xRet	:= 0
//	xRet	:= POSICIONE("SB1",1,XFILIAL("SB1")+ , "B1_UM" )

ENDIF


Return(xRet)



/*/{Protheus.doc} VLDMODEL
Reliza valida็๕es da modelo de acordo envento enviado
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
Local oModeZAA, oModeZAB, oModeZA3
Local nI, nTotLen

Local cNomeArq, cDirLixo, cFullOrig, cFullDest

Default cModel	:= ""


IF cModel == "MODEL_POS"

	

ENDIF


IF EMPTY(cMsgErro)
	lRet	:= .T.
ELSE
	lRet	:= .F.
	Help(" ",1,cModel,,cMsgErro,4,5)
	
ENDIF


Return(lRet)




/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ FAT01LOK  บAutor  ณAugusto Ribeiro    บ Data ณ 19/11/2013  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ 	Validacao de linha dos Models.                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/


/*/{Protheus.doc} VldLinOK
  Validacao de linha dos Models. 
  @author Augusto Ribeiro | www.compila.com.br
  @since 17/01/2015
  @version 1.0
  @param ${cModel}, ${C}, ${Model que esta validando}
  @param ${oModel}, ${O}, ${Objeto Model}
  @param ${nLine}, ${N}, ${Numero da Linha}
  @param ${cAction}, ${C}, ${param_descr}
  @param ${cField}, ${C}, ${cField}
  @return ${lRet}, ${Logico}
  /*/  
Static Function VldLinOK(cModel, oModel, nLine, cAction, cField)
Local lRet				:= .T.
Local oModFull 		:= oModel:GetModel() //| Busca Model completa
Local oModeZAA	 	:= oModFull:GetModel('ZAACABEC')
Local oModeZA3	 	:= oModFull:GetModel('ZABITEM')
Local aArea

DEFAULT cAction := ""


cAction := ALLTRIM(cAction)

IF cModel == "LPRE_ZA3"


ENDIF


Return(lRet)

/*Valida็ใo de campo da Grid
 Diogo Melo               */

static function linePreGrid(oModel)

Local oModelAlt  := FwModelActive() 
Local nLinha     := oModel:nLine
//Local nPosCampo  := Ascan(oModel:aHeader,{|x| Alltrim(x[2]) == "ZAB_CODNAT"} )
Local cConteudo := oModel:getValue('ZAB_CODNAT',nLinha)

//if oModel:aHeader[nposCampo][2] == "ZAB_CODNAT"
	if !empty(cConteudo)
		cDesNat := Posicione("SED",1,xFilial("SED")+cConteudo,"ED_DESCRIC")
		oModelAlt:loadValue('ZABITEM','ZAB_DESNAT',alltrim(cDesNat))
	endIf
//endIf

return .t.

