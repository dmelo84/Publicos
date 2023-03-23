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


/*------------------------------------------------------------|  Augusto Ribeiro - 14/02/2015
	CAMPOS COMBOS
	Defines visam facilitar futuras manutencoes
-------------------------------------------------------------------------------------------*/
//| --------- ZA0_PERFIL -------------
#DEFINE ZA0_PERFIL_USUARIO	"1"   
#DEFINE ZA0_PERFIL_ADMIN	"2"
#define CRLF Chr(13) + Chr(10)

//| --------- ZAF_STATUS -------------
#DEFINE ZAF_STATUS_RASCUNHO	"1"   
#DEFINE ZAF_STATUS_PENDENTE	"2"
#DEFINE ZAF_STATUS_APROVADO	"3"
#DEFINE ZAF_STATUS_REVISAO	"4"
#DEFINE ZAF_STATUS_RECUSADO	"5"
#DEFINE ZAF_STATUS_PAGO		"6"

//| --------- ZA7_TIPAPR -------------
#DEFINE ZA7_TIPAPR_PADRAO	"1"   
#DEFINE ZA7_TIPAPR_AUTO		"2"

//| --------- ZA7_COMPRO -------------
#DEFINE ZA7_COMPRO_OBRIGATORIO	"1"   
#DEFINE ZA7_COMPRO_OPCIONAL		"2"

//| Id aprovador automatico
#DEFINE IDAPROVA_AUTO		"AUTOMA"

#DEFINE D_TITULO 'Reembolso de Despesas'     
#DEFINE D_ROTINA 'CP07001' 

/*/{Protheus.doc} CP07001
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
User function CP07001() 

Local cListUsr := __cUserID
//Local oBrowse  
PRIVATE _LCOPIA	:= .F.
Private _lVlrUni	:= .T.

Private xRetCon

//SetKey ( VK_F12, {|| ALERT("TESTE F12")} ) 

DBSELECTAREA("ZA0")
ZA0->(DBSETORDER(1)) //| ZA0_FILIAL, ZA0_CODIGO
IF ZA0->(DBSEEK(xfilial("ZA0")+__CUSERID)) 

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias('ZAF')                         
	//oBrowse:SetMenuDef( "ATEC204" )                   // Define de onde virao os botoes deste browse
	oBrowse:SetDescription(D_TITULO)
	
	IF ZA0->ZA0_PERFIL <> ZA0_PERFIL_ADMIN
	
			
		DBSELECTAREA("ZAE")
		ZAE->(DBSETORDER(1)) //| 

		IF ZAE->(DBSEEK(xfilial("ZAE"))) 
			
			//cListUsr	:= __cUserID /* Diogo - Desativei esta variavel para que o programa */ 
			                         /* carregue o usuário logado */
									 /* ou os usuários listados na tabela ZA0 */

			WHILE ZAE->(!EOF()) .and. ZAE->ZAE_CODIGO == ZA0->ZA0_CODIGO
			
				
				cListUsr	+= "/"+ZAE->ZAE_USRVIN			
			
				ZAE->(DBSKIP()) 
			ENDDO
				
		ENDIF	
		
		oBrowse:SetFilterDefault( "ZAF_CODUSR $ '"+cListUsr+"'" )	

	ENDIF
	
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
	
	//1=Rascunho;2=Pendente Aprov.;3=Aprovado;4=Em Revisao;5=Recusado;6=Pago
		
	oBrowse:AddLegend( "ZAF->ZAF_STATUS == '1'", "BR_CINZA", 			X3COMBO("ZAF_STATUS", ZAF_STATUS_RASCUNHO))
	oBrowse:AddLegend( "ZAF->ZAF_STATUS == '2'", "BR_AMARELO",			X3COMBO("ZAF_STATUS", ZAF_STATUS_PENDENTE))
	oBrowse:AddLegend( "ZAF->ZAF_STATUS == '3'", "BR_VERDE", 			X3COMBO("ZAF_STATUS", ZAF_STATUS_APROVADO))
	//oBrowse:AddLegend( "ZA1->ZA1_STATUS == '4'", "BR_BRANCO", 		X3COMBO("ZA1_STATUS", ZA1_STATUS_REVISAO))
	oBrowse:AddLegend( "ZAF->ZAF_STATUS == '5'", "BR_VERMELHO", 		X3COMBO("ZAF_STATUS", ZAF_STATUS_RECUSADO))
	oBrowse:AddLegend( "ZAF->ZAF_STATUS == '6'", "BR_VERDE_ESCURO",	X3COMBO("ZAF_STATUS", ZAF_STATUS_PAGO))
	
	//oBrowse:DisableDetails()
	
	oBrowse:Activate()	
	
ELSE
	FwHelpShow(,"Acesso Negado","Usuario não localizado.","Contate o administrador do sistema. Verifique o cadastro do usuário na rotina 'Cad. Usuários Reembolso' [ZA0].")
ENDIF


Return NIL

        
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ CP07001  ºAutor  ³Augusto Ribeiro     º Data ³ 07/01/2011  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ 	Botoes do MBrowser                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/  

Static Function MenuDef()
Local aRotina := {}


ADD OPTION aRotina TITLE 'Pesquisar'  ACTION 'PesqBrw'             OPERATION 1 ACCESS 0
ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.'+D_ROTINA OPERATION 2 ACCESS 0                         
ADD OPTION aRotina TITLE 'Incluir'    ACTION  'U_CP701MNU("INCLUI")' OPERATION 3 ACCESS 0  	
ADD OPTION aRotina TITLE 'Alterar'    ACTION 'VIEWDEF.'+D_ROTINA OPERATION 4 ACCESS 0
ADD OPTION aRotina TITLE 'Excluir'    ACTION 'VIEWDEF.'+D_ROTINA OPERATION 5 ACCESS 0
ADD OPTION aRotina TITLE 'Copiar'     ACTION 'VIEWDEF.'+D_ROTINA OPERATION 9 ACCESS 0
ADD OPTION aRotina TITLE 'Imprimir'   ACTION 'VIEWDEF.'+D_ROTINA OPERATION 8 ACCESS 0
//ADD OPTION aRotina TITLE 'TESTE'     ACTION 'U_FAT01TST()' OPERATION 9 ACCESS 0
ADD OPTION aRotina TITLE 'Legenda'  ACTION 'eval(oBrowse:aColumns[1]:GetDoubleClick())'             OPERATION 1 ACCESS 0


// ADD OPTION aRotina TITLE 'Amarra B.I.'  ACTION 'U_EST02MNU("AMARRA")' OPERATION 2 ACCESS 0
Return aRotina


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ EST02MNU  ºAutor  ³Augusto Ribeiro     º Data ³ 07/01/2011  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Fucao para identificacao do botao utilizado                º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/  
User Function CP701MNU(cAcao)
Local nRetAux
//Local oView 	:= FWViewActive()
//Local oModFull	:= FWModelActive()
//| Forca execução do set val

IF cAcao == "INCLUI"
	
	_LCOPIA	:= .F.
	
	nRetAux := FWExecView(D_TITULO,D_ROTINA,  MODEL_OPERATION_INSERT,,  {|| .T. } )
	/*
	WHILE nRetAux == 0
		//ALERT("OK")
		
		IF  AVISO("Copiar ultimo registro", "Deseja incluir um novo registro a partir de uma cópia do registro recem gravado ?", {"Sim", "Não"},1) == 1
			_LCOPIA	:= .T.	
			nRetAux := FWExecView(D_TITULO,D_ROTINA,  9,,  {|| .T. } ) //| Inicia Copia do Registro 
			_LCOPIA	:= .F.
		ELSE 
			nRetAux := 1
		ENDIF
	ENDDO
	*/
ENDIF

Return()



/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ CP07001  ºAutor  ³Augusto Ribeiro     º Data ³ 19/11/2013  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ 	Definicoes do Model                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/  
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oStruZAF := FWFormStruct( 1, 'ZAF', /*bAvalCampo*/,/*lViewUsado*/ )
Local oStruZAG := FWFormStruct( 1, 'ZAG', /*bAvalCampo*/,/*lViewUsado*/ )
Local oStruZA3 := FWFormStruct( 1, 'ZA3', /*bAvalCampo*/,/*lViewUsado*/ )
Local oModel   

Local bVldPosFull	:= { |oModel| VLDMODEL('MODEL_POS', oModel) }
Local bLPREZA3	:= { |oModel, nLine, cAction, cField| VldLinOK('LPRE_ZA3', oModel, nLine, cAction, cField ) }
Local bLPOSZA3	:= { |oModel, nLine, cAction, cField| VldLinOK('LPOS_ZA3', oModel, nLine, cAction, cField ) }

// Ativa edição dos compos
oStruZAF:SetProperty("ZAF_VLRUNI", MODEL_FIELD_WHEN   , {|| U_CP701CPO("ZAF_VLRUNI", "W") })

// Cria o objeto do Mod elo de Dados
oModel := MPFormModel():New(D_ROTINA+'MODEL', /*bPreValidacao*/, bVldPosFull /*bPosValidacao*/, { |oModel| GRVMODEL(oModel) }  /*bCommit*/, /*bCancel*/ )
//oModel := MPFormModel():New('ATEC204MODEL', /*bPreValidacao*/,/*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'ZAFCABEC', /*cOwner*/, oStruZAF, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
oModel:AddGrid( 'ZAGCOMPROV', 'ZAFCABEC', oStruZAG, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
oModel:AddGrid( 'ZA3VINCULO', 'ZAFCABEC', oStruZA3, bLPREZA3/*bLinePre*/, bLPOSZA3/*bLinePost*/, /*bPreVal*/, /*bPosVal*/,  /*BLoad*/ )

//oModel:AddGrid( 'ZA3VALEMP', 'ZA2ITENS', oStruZA3, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )


// Faz relaciomaneto entre os compomentes do model                                                                           
oModel:SetRelation( 'ZAGCOMPROV',	{{ 'ZAG_FILIAL', 'XFILIAL("ZAG")' }, { 'ZAG_CODIGO', 'ZAF_CODIGO' }} ,  ZAG->(IndexKey(1)) )//'ZA2_FILIAL+ZA2_CODIGO' )   
oModel:SetRelation( 'ZA3VINCULO',	{{ 'ZA3_FILIAL', 'XFILIAL("ZA3")' }, { 'ZA3_CODIGO', 'ZAF_CODIGO' }} ,  ZA3->(IndexKey(1)) )

//oModel:SetRelation( 'ZA3VALEMP',	{{ 'ZA3_FILIAL', 'ZA1_FILIAL' }, { 'ZA3_CODIGO', 'ZA1_CODIGO' } , { 'ZA3_REV', 'ZA1_REV' }},"ZA3_FILIAL+ZA3_CODIGO+ZA3_REV" )


// Liga o controle de nao repeticao de linha
oModel:GetModel( 'ZAGCOMPROV' ):SetUniqueLine( { 'ZAG_ITEM' } )
oModel:GetModel( 'ZA3VINCULO' ):SetUniqueLine( { 'ZA3_ALIAS'} )


// Indica que é opcional ter dados informados na Grid
// oModel:GetModel( 'ZA6SERV' ):SetOptional(.T.) //| Removido Serviços Executados - Sol. Adriano


// Adiciona a descricao do Modelo de Dados
oModel:SetDescription(D_TITULO)

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'ZAFCABEC' ):SetDescription( 'Despesa' )      
oModel:GetModel( 'ZAGCOMPROV' ):SetDescription( 'Comprovantes' )
oModel:GetModel( 'ZA3VINCULO' ):SetDescription( 'Vínculos' )

/// oModel:GetModel( 'ZA6SERV' ):SetDescription( 'Serviços' ) //| Removido Serviços Executados - Sol. Adriano
      
      
oModel:GetModel( 'ZAGCOMPROV' ):SetOptional(.T.)
oModel:GetModel( 'ZA3VINCULO' ):SetOptional(.T.)         
       
// Liga a validação da ativacao do Modelo de Dados
oModel:SetVldActivate( { |oModel,cAcao| U_CP701VLD('MODEL_ACTIVE', oModel) } )
oModel:SetActivate( {|oModel| SetKey ( VK_F12, {||  U_CP701BTN('VISUALIZA_1')} ) ,U_CP701ZA3(oModel)} )

Return oModel


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ CP07001  ºAutor  ³Augusto Ribeiro     º Data ³ 07/01/2011  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ 	Definicoes da View                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/  
Static Function ViewDef()
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   := FWLoadModel( D_ROTINA )
// Cria a estrutura a ser usada na View
Local oStruZAF := FWFormStruct( 2, 'ZAF' )
Local oStruZAG := FWFormStruct( 2, 'ZAG' )
Local oStruZA3 := FWFormStruct( 2, 'ZA3' )
Local nOperation := oModel:GetOperation()
Local oView   

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_ZAF', oStruZAF, 'ZAFCABEC' )
oView:AddGrid( 'VIEW_ZAG', oStruZAG, 'ZAGCOMPROV' )
oView:AddGrid( 'VIEW_ZA3', oStruZA3, 'ZA3VINCULO' )



// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'TOP'	, 60 )
oView:CreateHorizontalBox( 'BOTTOM'	, 40) 	          
oView:CreateVerticalBox( 'LEFT_TOP'		, 60,'TOP')
oView:CreateVerticalBox( 'RIGHT_TOP'		, 40,'TOP')
oView:CreateVerticalBox( 'LEFT_BOT'		, 100,'BOTTOM')
   

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_ZAF', 'LEFT_TOP')
oView:SetOwnerView( 'VIEW_ZA3', 'LEFT_BOT')
oView:SetOwnerView( 'VIEW_ZAG', 'RIGHT_TOP')


// Define campos que terao Auto Incremento
oView:AddIncrementField( 'VIEW_ZAG', 'ZAG_ITEM' )
oView:AddIncrementField( 'VIEW_ZA3', 'ZA3_ITEM' )

//oView:AddOtherObject("ABAIXO_CAL", {|oPanel| U_FAT01BCAL(oPanel)})
//oView:SetOwnerView("ABAIXO_CAL",'RIGHT_SUP2')


// Criar novo botao na barra de botoes no antigo Enchoice Bar            
oView:AddUserButton( 'Visualizar Comprovante (F12)', 'Visualizar Comprov.', { |oView| U_CP701BTN('VISUALIZA_1', oView) } )
oView:AddUserButton( 'Copiar Comprovantes', 'Copiar Comprov.', { |oView| U_CP701BTN('COPIA_COMPROV', oView) } )
//oView:AddUserButton( 'Gera calendario', 'CALENDARIO', { |oView| ALTER("TESTE") } )

// Liga a identificacao do componente
oView:EnableTitleView('VIEW_ZAF')
oView:EnableTitleView('VIEW_ZAG')
oView:EnableTitleView('VIEW_ZA3')


// Liga a Edição de Campos na FormGrid
//oView:SetViewProperty( 'VIEW_ZA5' , "ENABLEDGRIDDETAIL", { 60 } )   


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

oView:SetFieldAction(  'ZAF_CODPRO',  {  |oView,  cIDView,  cField,  xValue| FAction(  oView,  cIDView, cField, xValue ) } )
oView:SetFieldAction(  'ZAF_CODNAT',  {  |oView,  cIDView,  cField,  xValue| FAction(  oView,  cIDView, cField, xValue ) } )
//oView:SetFieldAction(  'ZA1_QTDE',  {  |oView,  cIDView,  cField,  xValue| FAction(  oView,  cIDView, cField, xValue ) } )

oView:SetCloseOnOk({||.T.})
 
 //SetKey ( VK_F12, {||  U_CP701BTN('VISUALIZA_1')} )
 
Return oView






/*/{Protheus.doc} CP701VLD
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
User Function CP701VLD(cModel, oModel)
Local lRet			:= .F.
Local cMsgErro	:= ""
Local nOperation := oModel:GetOperation()
Local LCOPIA		:= oModel:ACONTROLS[4] == 6
Local aRetAux

Default cModel	:= ""

IF cModel == "MODEL_ACTIVE"

	//| Regras para COPIA
	IF LCOPIA
		//| Somente permite copia de registros pertencentes ao usuario. 
		aRetAux	:= PermUsr(ZAF->ZAF_CODUSR)
	
		IF !(aRetAux[1])
			cMsgErro	:= "Este registro pertence a um usuario que não esta vinculado as seus acessos. " // Somente é permitido realizar a cópia de lançamentos realizados pelo próprio usuário."
		ELSE
			DBSELECTAREA("ZA0")
			ZA0->(DBSETORDER(1)) //| ZA0_FILIAL, ZA0_CODIGO
			IF ZA0->(DBSEEK(xfilial("ZA0")+ZAF->ZAF_CODUSR))
		
				IF ZAF->ZAF_CODREG <> ZA0->ZA0_CODREG
					cMsgErro	:= "Este registro não pode ser copiado. Regra de reembolso definida para o usuário foi alterada."
				ENDIF
			ENDIF
		ENDIF
		
		//| BloqueiA registro para alteracao caso ja esteja Aprovado ou Reprovado
	ELSEIF nOperation == MODEL_OPERATION_UPDATE .OR. nOperation == MODEL_OPERATION_DELETE
	
	
		IF !(ZAF->ZAF_STATUS == ZAF_STATUS_RASCUNHO .OR.;
			ZAF->ZAF_STATUS == ZAF_STATUS_PENDENTE .OR.;
			ZAF->ZAF_STATUS == ZAF_STATUS_REVISAO)
			
			cMsgErro	:= "Este registro não pode ser alterado. Registro com status "+alltrim(X3COMBO("ZAF_STATUS",ZAF->ZAF_STATUS))
			
		ELSEIF ZAF->ZAF_CODUSR <> __CUSERID
		
			aRetAux	:= PermUsr(ZAF->ZAF_CODUSR)
		
			DBSELECTAREA("ZA0")
			ZA0->(DBSETORDER(1)) //| ZA0_FILIAL, ZA0_CODIGO
			IF ZA0->(DBSEEK(xfilial("ZA0")+__CUSERID)) 
				
				IF ZA0->ZA0_PERFIL <> ZA0_PERFIL_ADMIN
					
					IF !(aRetAux[1])
					 	cMsgErro	:= "Acesso negado, Este registro pertence a outro usuário. Verifique cadastro do usuario. [ZA0_PERFIL]."
					ENDIF
				ENDIF
			ELSE
	 			cMsgErro	:= "Acesso negado, Este registro pertence a outro usuário. Verifique cadastro do usuario. [ZA0_PERFIL]."									
			ENDIF		
		ENDIF
	
	ENDIF
ENDIF


IF EMPTY(cMsgErro)
	lRet	:= .T.
ELSE
	lRet	:= .F.
	Help(" ",1,cModel,,cMsgErro,4,5)
	
ENDIF

Return(lRet)





/*/{Protheus.doc} CP701CPO
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
User Function CP701CPO(cCampo, cTipo)
Local lRet := .T.
Local nPosCpo, nAux
Local oModFull 	:= FWModelActive()
Local oModeZAF
Local cQry := ""
Local cAlias := getNextAlias()
Local loadValor := 0 //DMS

Default cCampo		:= ''
Default cTipo		:= "V"

cCampo := alltrim(cCampo)

/*-------------------------------------
  VALIDACAO
--------------------------------------*/
IF cTipo == "V"

	oModeZAF		:= oModFull:GetModel('ZAFCABEC')
	
	IF cCampo == "ZAF_CODPRO"
		lRet	:= U_CP701SB1(M->ZAF_CODPRO)
	
	ELSEIF cCampo == "ZAF_CODNAT"
		lRet	:= U_CP701SED(M->ZAF_CODNAT)
				
	ELSEIF cCampo == "ZAF_VLRUNI" .or. cCampo == "ZAF_QTDE" .or. cCampo == "ZAF_VLRTOT"
		
		/* DMS - Diogo Melo*/
		cQry += "Select ZA5_CODIGO, ZA5_DESC, ZA5_TABPRE, ZA7_CODNAT, ZA7_DESNAT, ZA7_TIPLIM, ZA7_LIMLAN" +CRLF
		cQry += "FROM "+retSqlName("ZA5")+" ZA5" +CRLF
		cQry += "INNER JOIN "+retSqlName("ZA7")+" ZA7"+CRLF
		cQry += "ON ZA5_FILIAL = ZA7_FILIAL "+CRLF
		cQry += "AND ZA5_CODIGO = ZA7_CODIGO "+CRLF
		cQry += "WHERE ZA5.D_E_L_E_T_ != '*' "+CRLF
		cQry += "AND ZA7.D_E_L_E_T_ != '*' " +CRLF
		cQry += "AND ZA5_CODIGO ='"+oModeZAF:GetValue("ZAF_CODREG")+"'"+CRLF
		cQry += "AND ZA7_CODNAT ='"+oModeZAF:GetValue("ZAF_CODNAT")+"'"+CRLF
		cQry += "ORDER BY ZA7.R_E_C_N_O_ desc"

		nStatus := TCSqlExec(cQry)

    if (nStatus < 0)
        conout("TCSQLError() " + TCSQLError())
        Msginfo("TCSQLError() " + TCSQLError())
        Return
    endif

    If select(cAlias) > 0
        cAlias->(dbCloseArea())
    EndIf

    TCQuery (cQry) ALIAS cAlias NEW

    if cAlias->(!EOF())

		cValor   := TRANSFORM(cAlias->ZA7_LIMLAN, "@E 999,999.99") 
		nQtde    := oModeZAF:GetValue("ZAF_QTDE")
		nValUnit := oModeZAF:GetValue("ZAF_VLRUNI")

		if cAlias->ZA7_TIPLIM == '2'
			if nQtde > cAlias->ZA7_LIMLAN
				FWAlertWarning("Quantidade acima do permitido "+Alltrim(cValor)+" na regra de reebolso", "Regra")	
				lRet := .F.
			endIf
		endIf
		
		if cAlias->ZA7_TIPLIM == '1'
			if nQtde * nValUnit > cAlias->ZA7_LIMLAN
				FWAlertWarning("Valor acima do permitido "+"R$ "+Alltrim(cValor)+" na regra de reebolso", "Regra")	
				lRet := .F.
			endIf
		Endif
		
	else
	//	FWAlertWarning("Codigo da natureza não definido na regra de reembolso", "Regra")
		loadValor := oModeZAF:GetValue("ZAF_QTDE") * oModeZAF:GetValue("ZAF_VLRUNI")
		oModeZAF:loadValue("ZAF_VLRTOT",loadValor)
		lRet	:= .T.
	endIf
	cAlias->(dbCloseArea())
	/**/
	//Array para consulta de itens
		nAux := ValTabela(oModeZAF:GetValue("ZAF_CODREG"), oModeZAF:GetValue("ZAF_CODPRO"), oModeZAF:GetValue("ZAF_CODNAT"))

		IF nAux > 0 .AND. nAux <> M->ZAF_VLRUNI
			//FwHelpShow(,"ZA1_VLRUNI","O Valor unitário não pode ser alterado. Produto com valor fixo definido na tabela de preço - Reembolso de Despesa.","Verifique o valor digitado.")
			if oModeZAF:GetValue("ZAF_VLRTOT") > 0
				lRet := .T.
			else
				lRet	:= .F.
				Help(" ",1,"ZAF_VLRUNI",,"O Valor unitário não pode ser alterado. Despesa com valor fixo definido na tabela de preço - Reembolso de Despesa.",4,5)
			endif
		ENDIF
		
	ELSEIF cCampo == "ZAF_VLRTOT"
	
		cCodUser	:= oModeZAF:GetValue("ZAF_CODUSR")	
		cCodReg	    := oModeZAF:GetValue("ZAF_CODREG")
		cCodProd	:= oModeZAF:GetValue("ZAF_CODPRO")
		cCodNat	    := oModeZAF:GetValue("ZAF_CODNAT")
		nVlrDesp	:= M->ZAF_VLRTOT
		dDataDesp	:= oModeZAF:GetValue("ZAF_DTDESP")
		cDespDesc	:= oModeZAF:GetValue("ZAF_CODIGO")
	
		aRet		:= LimDesp(cCodUser, cCodReg, cCodProd, cCodNat, nVlrDesp, dDataDesp, cDespDesc )
		
		IF !(aRet[1])
			lRet	:= .F.
			//FwHelpShow(,"ZA1_VLRTOT",aRet[2],"Contate o Administrador do sistema.")
			Help(" ",1,"ZAF_VLRTOT",,aRet[2],4,5)
		ELSEIF aRet[3]
		
			// 1=Bloq. Inclusao;2=Notifica Usuario;3=Notifica Aprovador
			IF aRet[4] <> "3"		
				IF aRet[4] == "1"
					lRet	:= .F.
				ENDIF		
				//FwHelpShow(,"ZA1_VLRTOT",aRet[2],"Verifique o valor digitado.")
				Help(" ",1,"ZAF_VLRTOT",,aRet[2],4,5)
			ENDIF		
		ENDIF
		
	ELSEIF cCampo == "ZAF_CODUSR"
	
		aRetAux	:= PermUsr(M->ZAF_CODUSR)
		IF !(aRetAux[1])
			Help(" ",1,"ZAF_CODUSR",,aRetAux[2],4,5)
			lRet		:= .F.
		ENDIF
		
	ENDIF
	
	
/*--------------------------------------
 MODO DE EDICAO - WHEN
---------------------------------------*/
ELSEIF cTipo == "W"

	IF cCampo == "ZAF_VLRUNI" //.or. cCampo == "ZAF_ZAF_VLRTOT"
	
		oModeZAF	:= oModFull:GetModel('ZAFCABEC')
		nAux		:= ValTabela(oModeZAF:GetValue("ZAF_CODREG"), oModeZAF:GetValue("ZAF_CODPRO"), oModeZAF:GetValue("ZAF_CODNAT"))
		IF nAux > 0
			lRet := .F.
			oModeZAF:loadValue("ZAF_VLRUNI",nAux )
		ENDIF	
	
	//ElseIf cCampo == "ZAF_QTDE"

		loadValor := oModeZAF:GetValue("ZAF_QTDE") * oModeZAF:GetValue("ZAF_VLRUNI")

		if loadValor > 0
			oModeZAF:loadValue("ZAF_VLRTOT",loadValor)
			//lRet := .F.
		endif

	ENDIF	

ENDIF


Return(lRet)






/*/{Protheus.doc} CP701GAT
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
  
User Function CP701GAT(cCampo, cContra)
Local xRet
Local oView
Local oModFull, oModeZAF

Default cCampo := "" 

cCampo := alltrim(cCampo)

                                                          

IF cCampo == "ZAF_CODPRO" .AND. cContra == "ZAF_VLRUNI"
	
	
	oModFull	:= FWModelActive()
	oModeZAF	:= oModFull:GetModel('ZAFCABEC')

	xRet		:= ValTabela(oModeZAF:GetValue("ZAF_CODREG"), M->ZAF_CODPRO, M->ZAF_CODNAT)
ENDIF


Return(xRet)



/*/{Protheus.doc} ValTabela
Busca valor do produto de acordo com o codigo da regra (se existir na tabela de preço)
@author Augusto Ribeiro | www.compila.com.br
@since 22/01/2015
@version 1.0
@param cCodRegra, C, Codigo da Regra
@param cCodProd, C, Codigo do Produto
@param cCodNat, C, Codigo da Natureza
@return nRet, Valor do Item (Caso nao exista retorna Zero)
/*/
Static Function ValTabela(cCodRegra, cCodProd, cCodNat)
Local nRet := 0 

IF !EMPTY(cCodRegra)

	DBSELECTAREA("ZA5") 
	ZA5->(DBSETORDER(1)) 
	IF ZA5->(DBSEEK(xfilial("ZA5")+cCodRegra)) 	

		IF !EMPTY(ZA5->ZA5_TABPRE)
	
			DBSELECTAREA("ZAB")
			IF !EMPTY(cCodProd)
				
				ZAB->(DBSETORDER(2)) //| ZAB_FILIAL+ZAB_CODIGO+ZAB_CODPRO
				IF ZAB->(DBSEEK(xfilial("ZAB")+ZA5->ZA5_TABPRE+cCodProd))
					nRet	:= ZAB->ZAB_VALOR
				ENDIF 					
				
			ELSEIF !EMPTY(cCodNat)

				ZAB->(DBSETORDER(3)) //| ZAB_FILIAL+ZAB_CODIGO+ZAB_CODNAT
				IF ZAB->(DBSEEK(xfilial("ZAB")+ZA5->ZA5_TABPRE+cCodNat))
					nRet	:= ZAB->ZAB_VALOR
				ENDIF 		
			ENDIF
			
		ENDIF
	ENDIF
	
ENDIF

Return(nRet)





/*/{Protheus.doc} CP701CON
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
User Function CP701CON()
Local lRetAux, cAliasTab, cIndChv, cCpoDesc, cConsPad
Local lRet			:= .F.
Local oModFull	:= FWModelActive()
Local oModeZA3	:= oModFull:GetModel('ZA3VINCULO')
Local oModeZAF	:= oModFull:GetModel('ZAFCABEC')
Local oView		:= FWViewActive()



DBSELECTAREA("ZA8")
ZA8->(DBSETORDER(2)) //| ZA8_FILIAL, ZA8_CODIGO, ZA8_ALIAS, R_E_C_N_O_, D_E_L_E_T_
IF ZA8->(DBSEEK(xfilial("ZA8")+oModeZAF:GetValue("ZAF_CODREG")+oModeZA3:GetValue("ZA3_ALIAS") )) 
	
	cAliasTab	:= ZA8->ZA8_ALIAS
	cIndChv	:= ZA8->ZA8_INDCHV
	cCpoDesc	:= ZA8->ZA8_CPODES
	cConsPad	:= ZA8->ZA8_CONPAD
	
	lRetAux := ConPad1(,,,cConsPad,,,.F. )
	 
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

ENDIF

Return(lRet)






/*/{Protheus.doc} CP701DES
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
User Function CP701DES(cCodReg, cAliasTab, nRecno)
Local cRet := ""

//| ### REVISAR
IF !EMPTY(cCodReg) .AND. !EMPTY(cAliasTab) .AND. !EMPTY(nRecno)


	DBSELECTAREA("ZA8")
	ZA8->(DBSETORDER(2)) //| ZA8_FILIAL, ZA8_CODIGO, ZA8_ALIAS, R_E_C_N_O_, D_E_L_E_T_
	IF ZA8->(DBSEEK(xfilial("ZA8")+cCodReg+cAliasTab))
	
		cCpoDesc	:= ZA8->ZA8_CPODES
	
		DBSELECTAREA(cAliasTab)
		DBGOTO(nRecno)

		cRet		:= FieldGet(FieldPos(cCpoDesc))

	ENDIF	

ENDIF

Return(cRet)




/*/{Protheus.doc} CP701CAQ
Consulta padrão (Customizada) para localizacao do arquivo na maquina do usuario | SXB:  CP0702
@author Augusto Ribeiro | www.compila.com.br
@since 10/12/2014
@version 1.0
@return ${lRet}, ${Selecionou Arquivo = true}
@example
(examples)
@see (links_or_references)
/*/  
User Function CP701CAQ()

Local cType			:= "*.*"

xRetCon	:= cGetFile(cType, "Selecione um Arquivo... "+Subs(cType,1,7),,,.T.,GETF_NETWORKDRIVE+GETF_LOCALHARD+GETF_LOCALFLOPPY,.F. ) // "Selecione arquivo "

Return !Empty(xRetCon)


/*/{Protheus.doc} VLDMODEL
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
Local oModeZAF, oModeZAG, oModeZA3
Local nI, nTotLen, nTotAtiva
Local cNomeArq, cDirLixo, cFullOrig, cFullDest
Local cCodUser, cCodReg, cCodProd, cCodNat, nVlrDesp, dDataDesp, cDespDesc
Local oView

Default cModel	:= ""

/*DMS - Diogo Melo Criação de diretório*/
Makedir('\data_reembolso\') //Mudar para paramento
Makedir('\data_reembolso\comprovantes\') //Mudar para parametro
/**/

IF cModel == "MODEL_POS"

	oModeZAF := oModel:GetModel("ZAFCABEC")
	oModeZAG := oModel:GetModel("ZAGCOMPROV")
	
	/*------------------------------------------------------------|  Augusto Ribeiro - 18/02/2015
		\/ COMPROVANTES \/ 
	-------------------------------------------------------------------------------------------*/	
	nTotLen	:= oModeZAG:Length()
	//| Caso registro esteja vazio, realiza exclusao
	FOR nI := 1 TO nTotLen
		oModeZAG:GoLine(nI)
		IF EMPTY(oModeZAG:GetValue("ZAG_ARQUIV"))			
			oModeZAG:DeleteLine()
		ENDIF		
	NEXT nI	 	
	nTotAtiva	:= oModeZAG:Length(.T.)
	
	cCodUser	:= oModeZAF:GetValue("ZAF_CODUSR")	
	cCodReg	    := oModeZAF:GetValue("ZAF_CODREG")
	cCodProd	:= oModeZAF:GetValue("ZAF_CODPRO")
	cCodNat	    := oModeZAF:GetValue("ZAF_CODNAT")
	nVlrDesp	:= oModeZAF:GetValue("ZAF_VLRTOT")
	dDataDesp	:= oModeZAF:GetValue("ZAF_DTDESP")
	cDespDesc	:= oModeZAF:GetValue("ZAF_CODIGO")

	
	//| Busca informacoes da obrigatoriedade de preenchimeto dos comprovantes para o produto
	aRetAux	:= LimDesp(cCodUser, cCodReg, cCodProd, cCodNat, nVlrDesp, dDataDesp, cDespDesc ) //{lRet, cMsgErro, lExcedeu, cTipoRestri, cTipoAprov, cComprov}
	
	IF aRetAux[1]
		
		//| Verifica se existem linhas que não estao deletas
		IF nTotAtiva > 0  
			
			FOR nI := 1 TO nTotLen
				
				nZAGARQFIS	:= TAMSX3("ZAG_ARQFIS")[1]
				
				oModeZAG:GoLine( nI )
				
				If oModeZAG:IsDeleted()
					/*---------------------------------------------------------------------------------------
						Para exclusao, apaga arquivo fisico caso exista
					------------------------------------------------------------------------------------------*/
					IF !EMPTY(oModeZAG:GetValue("ZAG_ARQFIS"))
							
						cDirLixo	:= U_CP07002G("20", "DIRLIXEIRA")
							
						__CopyFile(ALLTRIM(oModeZAG:GetValue("ZAG_ARQFIS")), cDirLixo+NomeArq(oModeZAG:GetValue("ZAG_ARQFIS")) )
						FErase(ALLTRIM(oModeZAG:GetValue("ZAG_ARQFIS")))
						
						oModeZAG:LoadValue("ZAG_ARQUIV")
						oModeZAG:LoadValue("ZAG_ARQFIS")
					ENDIF
							
				ELSE
						
					IF oModeZAG:IsUpdated() .OR. oModeZAG:IsInserted() 
					
					
						/*------------------------------------------------------------|  Augusto Ribeiro - 18/02/2015
							Realiza copia dos comprovantes para o servidor.
						-------------------------------------------------------------------------------------------*/
					
						cFullOrig	:= alltrim(oModeZAG:GetValue("ZAG_ARQUIV"))
					
						//| Verifica se caminho completo do arquivo foi informado.
						IF AT("\", cFullOrig) > 0					
							
							//| Verifica se arquivo de origem existe
							IF FILE(cFullOrig)
							
								cNomeArq	:= NomeArq(cFullOrig) //| Retira somente nome do arquivo do caminho completo					 
								cNovoNome	:= NovoNome(oModeZAF:GetValue("ZAF_CODIGO"), oModeZAG:GetValue("ZAG_ITEM"), cNomeArq) //| Altera nome para padrao de armazenamento
								cDirDest	:= DirSave(oModeZAF:GetValue("ZAF_DTREG")) //| Retornar/Criar caminho onde será armazenado o comprovante de acordo com a data informada.
								
								cFullDest	:= ALLTRIM(cDirDest+cNovoNome)
								nFullDest := LEN(cFullDest)
			
								//| Verifica se nome do arquivo nao ultrapassou o tamanho máximo
								IF nFullDest <= nZAGARQFIS
								
								
									//| Caso arquivo fisico ja esteja gravado e seja alterado, 
									//| move arquivo antigo para lixeira	
									IF !EMPTY(oModeZAG:GetValue("ZAG_ARQFIS")) .AND.;
											ALLTRIM(oModeZAG:GetValue("ZAG_ARQFIS")) <>  cFullDest
											
										cDirLixo	:= U_CP07002G("20", "DIRLIXEIRA")
											
										__CopyFile(ALLTRIM(oModeZAG:GetValue("ZAG_ARQFIS")), cDirLixo+NomeArq(oModeZAG:GetValue("ZAG_ARQFIS")) )
										FErase(ALLTRIM(oModeZAG:GetValue("ZAG_ARQFIS")))
									ENDIF
									
																
									MSGRUN( "Copiando Arquivo "+cNomeArq, "Armazenando comprovantes", {|| __CopyFile(cFullOrig, cFullDest) })
									IF FILE(cFullDest)
										oModeZAG:SetValue("ZAG_ARQUIV", cNovoNome)
										oModeZAG:SetValue("ZAG_ARQFIS", cFullDest)							
									ELSE 
										cMsgErro := "Falha na copia do arquivo["+cFullOrig+"]"
									ENDIF
								ELSE
									cMaxNome	:= alltrim(str( (nZAGARQFIS-LEN(cDirDest))-1 ))
								
									//FwHelpShow("Nome Arquivo Invalido",,"O nome do arquivo ultrapassa o limite de ["+cMaxNome+"] caracteres","Renomeie o arquivo antes de processeguir")
									cMsgErro	:= "O nome do arquivo ultrapassa o limite de ["+cMaxNome+"] caracteres."
								ENDIF
							ELSE
								cMsgErro	:= "Arquivo não encontrado ["+cFullOrig+"]"
							ENDIF
						 
						//| Caso Arquivo fisico já esteja gravado e nome do arquivo de origem seja diferente
						//| do armazenado, atualiza com nome do arquivo armazenado.				 
						ELSEIF !EMPTY(oModeZAG:GetValue("ZAG_ARQFIS"))
							oModeZAG:SetValue("ZAG_ARQUIV", NomeArq(oModeZAG:GetValue("ZAG_ARQFIS")))
						ELSE 
							cMsgErro	:= "Arquivo não encontrado ["+cFullOrig+"]"
						ENDIF			
					ENDIF
				Endif		
			NEXT nI
		
		ELSEIF  nTotAtiva <= 0 .AND. aRetAux[6] == ZA7_COMPRO_OBRIGATORIO
			cMsgErro	:= "Preenchimento dos comprovantes é obrigatório"
		ENDIF
	ELSE
		cMsgErro	:= "Falha na verifica da regra para este produto. Erro "+aRetAux[2]
	ENDIF	
	/*------------------------------------------------------------|  Augusto Ribeiro - 18/02/2015
		/\ COMPROVANTES /\ 		
	-------------------------------------------------------------------------------------------*/
	
ENDIF


IF EMPTY(cMsgErro)
	lRet	:= .T.
ELSE
	lRet	:= .F.

	//Help(" ",1,cModel,,cMsgErro,4,5)
	if nOperation == 3
		Alert(cMsgErro)
		lRet := MsgNoYes("Deseja incluir o reembolso sem comprovante de despesa?",cModel)
	endIf

	if nOperation == 5
		lRet := MsgNoYes(cMsgErro+" ."+"Confirma a deleção?",cModel)
	endIf

	oView	:= FWViewActive()
	oView:Refresh()	
ENDIF


Return(lRet)





/*/{Protheus.doc} NomeArq
Retorna nome do arquivo com a extensão
@author Augusto Ribeiro | www.compila.com.br
@since 09/01/2015
@version 1.0
@param ${cFullPath}, ${c}, ${Caminho completo do arquivo}
@return ${cRet}, ${Nome do Arquivo sem extensão }
/*/
Static Function NomeArq(cFullPath)
Local cRet	:= ""
Local nPosBar

cFullPath	:= ALLTRIM(cFullPath)
nPosBar	:= rat("\",cFullPath)

IF nPosBar > 0
	cRet := SUBSTR(cFullPath, nPosBar+1, LEN(cFullPath)-nPosBar )
ENDIF

Return(cRet)



/*/{Protheus.doc} NovoNome
Altera nome do arquivo para seguir padrao para cada item.
@author Augusto Ribeiro | www.compila.com.br
@since 12/01/2015
@version 1.0
@param ${cCodigo}, ${c}, ${Codigo do reembolso de despesa}
@param ${cItem}, ${c}, ${Item do reembolso de despesa}
@param ${cArquivo}, ${c}, ${Nome do arquivo do reembolso}
@return ${cRet}, ${Novo nome do arquivo seguindo padrao de armazenamento}
/*/
Static Function NovoNome(cCodigo, cItem, cArquivo)
Local cRet	:= ""

IF !EMPTY(cCodigo) .AND. !EMPTY(cItem) .AND. !EMPTY(cArquivo)
	cRet	:= LOWER(cCodigo+"_"+cItem+"_"+STRTRAN(cArquivo," ","_"))
ENDIF


Return(cRet)



/*/{Protheus.doc} DirSave
Retornar/Criar caminho onde será armazenado o comprovante de acordo com a data informada.
@author Augusto Ribeiro | www.compila.com.br
@since 14/01/2015
@version 1.0
@param ${dDataRef}, ${D}, ${Data de referencia - Utilizado para criar o diretorio onde ser armazenado o arquivo}
@return ${cRet}, ${Caminho de destino no arquivo}
/*/
Static Function DirSave(dDataRef)
Local cRet			:= U_CP07002G("20", "DIRCOMPROV")
Local cAnoMes, cDirComp, cCurDir, nAux

IF !EMPTY(dDataRef)


	cAnoMes	:= LEFT(DTOS(dDataRef),6)
	cDirComp	:= cRet+cAnoMes+"\"
	
	IF ExistDir(cDirComp)
		cRet	:= cDirComp
	ELSE

		cCurDir	:= CurDir()
		CurDir(cRet)
		
		nAux	:= MakeDir(cAnoMes)
		IF nAux == 0
			cRet	:= cDirComp
		ELSE
			CONOUT("### CP07001.PRW [DirSave] | Nao foi possivel criar o diretorio ["+cAnoMes+"]. Cod. Erro: "+alltrim(str(FError())) )
		ENDIF
		
		
		//| Rollback no diretorio corrente
		IF LEFT(cCurDir,1) <> "\"
			cCurDir	:= "\"+cCurDir
		ENDIF		
		CurDir(cCurDir) 
	ENDIF 
	
ENDIF


Return(cRet)




/*/{Protheus.doc} CP701ZA3
Carrega dados no GRID quando inclusao
@author Augusto Ribeiro | www.compila.com.br
@since 17/01/2015
@version 1.0
@param ${oModel}, ${O}, ${Objeto model}
@return ${aRet}, ${Array com dados do GRID}
/*/
//User Function CP07LZA3(oModFull)
User Function CP701ZA3(oModFull)
Local aRet			:= {}
Local aLoadSD1	:= {}
Local nTotLen, nI, lAdd
Local cItem			:= Replicate("0",tamsx3("ZA8_ITEM")[1])
Local oModeZAF 		:= oModFull:GetModel("ZAFCABEC") 
Local oModeZAG 		:= oModFull:GetModel("ZAGCOMPROV")
Local oModeZA3 		:= oModFull:GetModel("ZA3VINCULO") 

Local nOperation 		:= oModFull:GetOperation()
 
//| Determina se trata-se de uma copia
Local LCOPIA		:= oModFull:ACONTROLS[4] == 6

IF _LCOPIA
	LCOPIA	:= .T.
ENDIF


IF nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE
	//| Habilita inclusao de novas linhas
	oModeZA3:lInsertLine	:= .T.
	
	cCodReg	:= oModeZAF:GetValue("ZAF_CODREG")
	
	DBSELECTAREA("ZA8")
	ZA8->(DBSETORDER(3)) //| ZA8_FILIAL, ZA8_CODIGO, ZA8_TIPO, ZA8_ALIAS, R_E_C_N_O_, D_E_L_E_T_
	IF ZA8->(DBSEEK(xfilial("ZA8")+cCodReg))
	
		nRecZA8	:= ZA8->(recno())
		IF !(LCOPIA) .AND. nOperation == MODEL_OPERATION_INSERT
		
			/*---------------------------------------------------------------------------------------
				PRIMEIRO LOOP
				Adiciona linhas vazias, foi divido em 2 loops por causa de validacoes
				padroes do MVC  
			------------------------------------------------------------------------------------------*/ 
			nI	:= 0
			WHILE ZA8->(!EOF()) .AND. ZA8->ZA8_CODIGO == cCodReg
				nI++	
				IF nI > 1
					oModeZA3:AddLine()
				ENDIF
	
					
				ZA8->(DBSKIP()) 
			ENDDO
			
			
			ZA8->(DBGOTO(nRecZA8))
			nI	:= 0
			WHILE ZA8->(!EOF()) .AND. ZA8->ZA8_CODIGO == cCodReg
				nI++
				
				oModeZA3:GoLine(nI)
				
				oModeZA3:SetValue("ZA3_ALIAS", ZA8->ZA8_ALIAS)
				oModeZA3:SetValue("ZA3_INDCHV", ZA8->ZA8_INDCHV)
				
				//| Opcional
				IF ZA8->ZA8_TIPO == "2" 
					oModeZA3:DeleteLine()			
				ENDIF
						
				ZA8->(DBSKIP()) 
			ENDDO
			
		/*---------------------------
			QUANDO ALTERACAO
			Inclui somente itens faltantes
		---------------------------*/
		ELSEIF LCOPIA .OR. nOperation == MODEL_OPERATION_UPDATE
		
			WHILE ZA8->(!EOF()) .AND. ZA8->ZA8_CODIGO == cCodReg

				nTotLen	:= oModeZA3:Length()
				lAdd		:= .T.
				FOR nI := 1 to nTotLen
					oModeZA3:GoLine(nI)
					IF oModeZA3:GetValue("ZA3_ALIAS") == ZA8->ZA8_ALIAS
						lAdd	:= .F.
						EXIT
					ENDIF	
				NEXT nI 
				
				//| Adiciona itens faltantes
				IF lAdd
					oModeZA3:AddLine()
					oModeZA3:SetValue("ZA3_ALIAS", ZA8->ZA8_ALIAS)
					oModeZA3:SetValue("ZA3_INDCHV", ZA8->ZA8_INDCHV)
					
					//| Opcional
					IF ZA8->ZA8_TIPO == "2" 
						oModeZA3:DeleteLine()			
					ENDIF				
				ENDIF
										
				ZA8->(DBSKIP()) 
			ENDDO		

	
		ENDIF
		oModeZA3:GoLine(1)
	ENDIF
	
	//| Bloquei inclusao de novas linhas		
	oModeZA3:SetNoInsertLine()		
	
	
	
	/*---------------------------------------------------------------------------------------
		COPIA - ZERA CAMPOS
	------------------------------------------------------------------------------------------*/
	IF LCOPIA
	
		oModeZAF:LoadValue("ZAF_DTDESP", 	CRIAVAR("ZAF_DTDESP",.T.))
		oModeZAF:LoadValue("ZAF_CODPRO", 	CRIAVAR("ZAF_CODPRO",.T.))
		oModeZAF:LoadValue("ZAF_DESPRO", 	CRIAVAR("ZAF_DESPRO",.T.))
		oModeZAF:LoadValue("ZAF_CODNAT", 	CRIAVAR("ZAF_CODNAT",.T.))
		oModeZAF:LoadValue("ZAF_DESNAT", 	CRIAVAR("ZAF_DESNAT",.T.))
		oModeZAF:LoadValue("ZAF_QTDE", 		CRIAVAR("ZAF_QTDE",.T.))
		oModeZAF:LoadValue("ZAF_UM", 		CRIAVAR("ZAF_UM",.T.))
		oModeZAF:LoadValue("ZAF_VLRUNI", 	CRIAVAR("ZAF_VLRUNI",.T.))
		oModeZAF:LoadValue("ZAF_VLRTOT", 	CRIAVAR("ZAF_VLRTOT",.T.))
		oModeZAF:LoadValue("ZAF_STATUS", 	CRIAVAR("ZAF_STATUS",.T.))
		oModeZAF:LoadValue("ZAF_CODUSR", 	CRIAVAR("ZAF_CODUSR",.T.))

		//oModeZA2:DeActivate()
		
			oModeZAG:aCols           := {}
			oModeZAG:aDataModel      := {}
			oModeZAG:InitLine()		
		
		//oModeZA2:Activate()

		/*
		FOR nI := 1 TO oModeZA2:Length()
			oModeZA2:GoLine(nI)
			oModeZA2:DeleteLine()	
		NEXT nI
		*/
		
	ENDIF
ENDIF

	
Return(NIL)


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FAT01LOK  ºAutor  ³Augusto Ribeiro    º Data ³ 19/11/2013  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ 	Validacao de linha dos Models.                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/


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
Local oModeZAF	 	:= oModFull:GetModel('ZAFCABEC')
Local oModeZA3	 	:= oModFull:GetModel('ZA3VINCULO')
Local aArea, nTamDesc, nTamZA3D

DEFAULT cAction := ""


cAction := ALLTRIM(cAction)

IF cModel == "LPRE_ZA3"


	IF cAction == "DELETE"
	
		DBSELECTAREA("ZA8")
		ZA8->(DBSETORDER(2)) //| ZA8_FILIAL, ZA8_CODIGO, ZA8_ALIAS, R_E_C_N_O_, D_E_L_E_T_
		IF ZA8->(DBSEEK(xfilial("ZA8")+oModeZAF:GetValue("ZAF_CODREG")+oModeZA3:GetValue("ZA3_ALIAS") )) 
			
			IF ZA8->ZA8_TIPO == '1' //| Obrigatorio
				Help(" ",1,"LPRE_ZA3",,"Esta registro é de preenchimento obrigatório",4,5)
				lRet	:= .F.
			ENDIF
		ENDIF
			
	ENDIF

ELSEIF cModel == "LPOS_ZA3"

	IF !(oModeZA3:IsDeleted())
	
		//| Valida se nao ocorreu alteracao na descricao
		IF !EMPTY(oModeZA3:GetValue("ZA3_RECREG"))
		
			DBSELECTAREA("ZA8")
			ZA8->(DBSETORDER(2)) //| ZA8_FILIAL, ZA8_CODIGO, ZA8_ALIAS, R_E_C_N_O_, D_E_L_E_T_
			IF ZA8->(DBSEEK(xfilial("ZA8")+oModeZAF:GetValue("ZAF_CODREG")+oModeZA3:GetValue("ZA3_ALIAS") )) 
				
				//aArea	:= GetArea()
				
				nTamDesc	:= tamSX3(ZA8->ZA8_CPODES)[1]
				nTamZA3D	:= tamSX3("ZA3_DESC")[1]
				
				IF nTamDesc > nTamZA3D
					nTamDesc := nTamZA3D
				ENDIF
				
			
				DBSELECTAREA(oModeZA3:GetValue("ZA3_ALIAS"))
				DBGOTO(oModeZA3:GetValue("ZA3_RECREG"))			
				IF LEFT(ALLTRIM(oModeZA3:GetValue("ZA3_DESC")),nTamDesc) <> LEFT(ALLTRIM(FieldGet(FieldPos(ZA8->ZA8_CPODES))),nTamDesc)
				
					Help(" ",1,"LPOS_ZA3",,"O Registro informado no campo ["+RetTitle("ZA3_DESC")+"], diverge da Chave do Registro. Por favor sempre utilizar a consulta (F3) para selecionar o registro desejado.s",4,5)
					lRet	:= .F.
				ENDIF
											
				//RestArea(aArea)
			ENDIF
		ENDIF
	ENDIF

ENDIF


Return(lRet)




/*/{Protheus.doc} CP701SB1
Consulta padrão (Customizada) do cadastro de produtos.| SXB:  CP0703
Caso Parametro cCodProd <> nil, nao apresenta consulta, porem executa query
para identificar se o produto esta dentro do regra
Realiza validacao para identificar se produto esta dentro da regra
@author Augusto Ribeiro | www.compila.com.br
@since 09/12/2014
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/  
User Function CP701SB1(cCodProd)
Local lRet			:= .F.
Local oModFull	:= FWModelActive()
Local oModeZAF	:= oModFull:GetModel('ZAFCABEC')
Local oView		:= FWViewActive()
Local cGrpAll		:= PADL("*",TAMSX3("ZA7_CODGRP")[1])
Local cProdAll	:= PADL("*",TAMSX3("ZA7_CODPRO")[1])
Local cQuery		:= ""
//| Alias da entidade utilizada para identificacao da despesa
//Local cDespRef	:= U_CP07002G("20", "ALIASDESP", "SED")


cQuery		:= " SELECT B1_COD, B1_DESC, B1_UM, ISNULL(BM_DESC,'') AS BM_DESC, SB1.R_E_C_N_O_ AS TAB_RECNO "+CRLF
cQuery		+= " FROM "+RetSqlName("SB1")+" SB1 "+CRLF
cQuery		+= " LEFT JOIN "+RetSqlName("SBM")+" SBM "+CRLF
cQuery		+= " 	ON BM_FILIAL = '"+XFILIAL("SBM")+"' "+CRLF
cQuery		+= " 	AND BM_GRUPO = B1_GRUPO "+CRLF
cQuery		+= " 	AND SBM.D_E_L_E_T_ = '' "+CRLF
cQuery		+= " 	WHERE SB1.B1_FILIAL =  '"+XFILIAL("SB1")+"' "+CRLF
cQuery		+= " 	AND SB1.D_E_L_E_T_ = '' "+CRLF
cQuery		+= " 	AND EXISTS (SELECT ZA7_CODIGO "+CRLF
cQuery		+= " 				FROM "+RetSqlName("ZA7")+" ZA7 "+CRLF
cQuery		+= " 				WHERE ZA7.ZA7_FILIAL = '"+XFILIAL("ZA7")+"' "+CRLF
cQuery		+= " 				AND ZA7.ZA7_CODIGO = '"+oModeZAF:GetValue("ZAF_CODREG")+"' "+CRLF
cQuery		+= " 				AND ZA7.ZA7_CODGRP IN ('*', SB1.B1_GRUPO) "+CRLF
cQuery		+= " 				AND ZA7.ZA7_CODPRO IN ('*', SB1.B1_COD) "+CRLF
cQuery		+= " 				AND ZA7.D_E_L_E_T_ = '') "+CRLF

IF EMPTY(cCodProd)

	cQuery		+= " 	AND (B1_COD LIKE '#CAMPO_BUSCA#%'  "+CRLF
	cQuery		+= " 		OR  "+CRLF
	cQuery		+= " 		B1_DESC LIKE '#CAMPO_BUSCA#%' ) "+CRLF

	IF U_CPXCPAD("Cadastro de Produtos", "SB1", cQuery, /*aBtnAdd*/ )
		lRet	:= .T.
		oView:Refresh()
	ENDIF


/*---------------------------------------------------------------------------------------
	VALIDA CADASTRO DE PRODUTOS. 
------------------------------------------------------------------------------------------*/
ELSE

	cQuery		+= " AND SB1.B1_COD = '"+ALLTRIM(cCodProd)+"' "
	
	If Select("TAUX") > 0
		TAUX->(DbCloseArea())
	EndIf
	
	DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TAUX",.F., .T.)						
	
	IF TAUX->(!EOF())
		lRet := .T.
	ENDIF	

	TAUX->(DbCloseArea())
	
ENDIF

Return(lRet)




/*/{Protheus.doc} CP701SED
Consulta padrão (Customizada) do cadastro de natureza.| SXB:  CP0704
Caso Parametro cCodNat <> nil, nao apresenta consulta, porem executa query
para identificar se o produto esta dentro do regra
Realiza validacao para identificar se produto esta dentro da regra
@author Augusto Ribeiro | www.compila.com.br
@since 26/01/2015
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/  
User Function CP701SED(cCodNat)
Local lRet		:= .F.
Local oView		:= FWViewActive()
Local oModFull	:= FWModelActive()
Local oModeZAF	:= oModFull:GetModel('ZAFCABEC')
Local cNatAll		:= PADL("*",TAMSX3("ZA7_CODNAT")[1])
Local cQuery		:= ""
//| Alias da entidade utilizada para identificacao da despesa
//Local cDespRef	:= U_CP07002G("20", "ALIASDESP", "SED")


cQuery		:= " 	SELECT ED_CODIGO, ED_DESCRIC, SED.R_E_C_N_O_ AS TAB_RECNO  "+CRLF
cQuery		+= " 	FROM "+RetSqlName("SED")+" SED  "+CRLF
cQuery		+= " 	WHERE ED_FILIAL = '"+XFILIAL("SED")+"'  "+CRLF
cQuery		+= " 	AND SED.D_E_L_E_T_ = ''  "+CRLF
cQuery		+= " 	AND EXISTS (SELECT ZA7_CODIGO "+CRLF
cQuery		+= " 				FROM "+RetSqlName("ZA7")+" ZA7 "+CRLF
cQuery		+= " 				WHERE ZA7.ZA7_FILIAL = '"+XFILIAL("ZA7")+"' "+CRLF
cQuery		+= " 				AND ZA7.ZA7_CODIGO = '"+oModeZAF:GetValue("ZAF_CODREG")+"' "+CRLF
cQuery		+= " 				AND ZA7.ZA7_CODNAT IN ('*', SED.ED_CODIGO) "+CRLF
cQuery		+= " 				AND ZA7.D_E_L_E_T_ = '') "+CRLF
cQuery		+= " 	OR EXISTS (SELECT ZAB_CODNAT "+CRLF
cQuery		+= " 				FROM "+RetSqlName("ZAB")+" ZAB "+CRLF
cQuery		+= " 				WHERE ZAB.ZAB_FILIAL = '"+XFILIAL("ZAB")+"' "+CRLF
cQuery		+= " 				AND ZAB.ZAB_CODZA7 = '"+oModeZAF:GetValue("ZAF_CODREG")+"' "+CRLF
cQuery		+= " 				AND ZAB.ZAB_CODNAT IN ('*', SED.ED_CODIGO) "+CRLF
cQuery		+= " 				AND ZAB.D_E_L_E_T_ = '') "+CRLF

IF EMPTY(cCodNat)

	cQuery		+= " 	AND (ED_CODIGO LIKE '#CAMPO_BUSCA#%'  "+CRLF
	cQuery		+= " 		OR  "+CRLF
	cQuery		+= " 		ED_DESCRIC LIKE '#CAMPO_BUSCA#%' ) "+CRLF

	IF U_CPXCPAD("Cadastro de Naturezas", "SED", cQuery, /*aBtnAdd*/ )
		lRet	:= .T.
		oView:Refresh()
	ENDIF


/*---------------------------------------------------------------------------------------
	VALIDA CADASTRO DE PRODUTOS. 
------------------------------------------------------------------------------------------*/
ELSE

	cQuery		+= " AND SED.ED_CODIGO = '"+ALLTRIM(cCodNat)+"' "
	
	If Select("TAUX") > 0
		TAUX->(DbCloseArea())
	EndIf
	
	DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TAUX",.F., .T.)						
	
	IF TAUX->(!EOF())
		lRet := .T.
	ENDIF	

	TAUX->(DbCloseArea())
	
ENDIF

Return(lRet)




/*/{Protheus.doc} LimDesp
Valida se valor esta dentro do limite estabelecido na Regra de Reembolso de Despesa(preenchimento)
@author Augusto Ribeiro | www.compila.com.br
@since 21/01/2015
@version 1.0
@param cCodReg, C, Cod. Regra de reembols
@param cCodProd, C, Cod. do Produto
@param cCodNat, C, Cod. da Natureza
@param nVlrDesp, N, Valor Despesa
@param dDataDesp, D, Data da despesa a ser utilizada como referencia para conferencia dos limitis diarios/mensal.
@param cDespDesc, C, Codigo da Despesa a ser desconsiderada na soma dos valores diario/mensal ja lancados.
@return aRet, {lRet, cMsgErro, lExcedeu, cTipoRestri, cTipoAprov, cComprov} | lRet= Rotina Processada com Sucesso, cMsgErro=Mensagem de erro/advertecia, lExcedeu, cTipoRestri (1=Bloq. Inclusao;2=Notifica Usuario;3=Notifica Aprovador), cTipoAprov= 1=Padrão;2=Automatica, cComprov 1=Obrigatorio;2=Opcional
@example
(examples)
@see (links_or_references)
/*/
Static Function LimDesp(cCodUser, cCodReg, cCodProd, cCodNat, nVlrDesp, dDataDesp, cDespDesc )

Local nVlrLanc	:= 0
Local nVlrDia		:= 0
Local nVlrMes		:= 0
Local cNatOK		:= ""
Local cProdOK		:= ""
Local cGrpOK		:= ""
Local cGrpProd	:= ""

Local lRet			:= .T.
Local cMsgErro	:= ""
Local lExcedeu	:= .F.
Local cTipoRest 	:= "" //| 1=Bloq. Inclusao;2=Notifica Usuario;3=Notifica Aprovador
Local cTipoAprov	:= ""
Local cComprov	:= ""
Local cParteA	:= ""
Local cParteB	:= ""
//| Alias da entidade utilizada para identificacao da despesa
Local cDespRef	:= U_CP07002G("20", "ALIASDESP", "SED")

Local aRet			:= {lRet, cMsgErro, lExcedeu, cTipoRest, cTipoAprov, cComprov}

Default nVlrDesp	:= 0
Default cDespDesc	:= ""

	
IF  !EMPTY(cCodUser) .AND. !EMPTY(cCodReg) .AND. !EMPTY(dDataDesp) .AND. (!EMPTY(cCodProd) .OR. !EMPTY(cCodNat))

	/*---------------------------------------------------------------------------------------
		VERIFIA SE EXISTE ALGUM RESTRICAO EXPLICITA PARA O PRODUTO 
	------------------------------------------------------------------------------------------*/
	DBSELECTAREA("ZA7")
	
	//| Validacao por PRODUTO/GRUPO PRODUTO
	IF cDespRef == "SB1" .AND. !EMPTY(cCodProd) 
	
		ZA7->(DBSETORDER(3)) //| ZA7_FILIAL, ZA7_CODIGO, ZA7_CODPRO, R_E_C_N_O_, D_E_L_E_T_
		IF ZA7->(DBSEEK(xfilial("ZA7")+cCodReg+cCodProd)) 
			
			nVlrLanc	:= ZA7->ZA7_LIMLAN 
			nVlrDia	:= ZA7->ZA7_LIMDIA
			nVlrMes	:= ZA7->ZA7_LIMMES
			
			cTipoRest	:= ZA7->ZA7_RESTRI
			cTipoAprov	:= ZA7->ZA7_TIPAPR
			cComprov	:= ZA7->ZA7_COMPRO
			cProdOK	:= ZA7->ZA7_CODPRO
		ELSE
			cGrpProd	:= POSICIONE("SB1",1,XFILIAL("SB1")+cCodProd, "B1_GRUPO")		
			cGrpProd	:= PADR(cGrpProd, TAMSX3("ZA7_CODGRP")[1])
				
			/*---------------------------------------------------------------------------------------
				VERIFIA SE EXISTE ALGUM RESTRICAO EXPLICITA PARA O GRUPO PRODUTO 
			------------------------------------------------------------------------------------------*/			
			DBSELECTAREA("ZA7")
			ZA7->(DBSETORDER(2)) //|ZA7_FILIAL, ZA7_CODIGO, ZA7_CODGRP, ZA7_CODPRO, R_E_C_N_O_, D_E_L_E_T_ 	
			IF ZA7->(DBSEEK(xfilial("ZA7")+cCodReg+cGrpProd+"*")) .AND. !EMPTY(cGrpProd)
				nVlrLanc	:= ZA7->ZA7_LIMLAN 
				nVlrDia	:= ZA7->ZA7_LIMDIA
				nVlrMes	:= ZA7->ZA7_LIMMES
				
				cTipoRest	:= ZA7->ZA7_RESTRI
				cTipoAprov	:= ZA7->ZA7_TIPAPR
				cComprov	:= ZA7->ZA7_COMPRO
				cGrpOK		:= ZA7->ZA7_CODGRP
			ELSE 
		
				/*---------------------------------------------------------------------------------------
					VERIFIA SE EXISTE ALGUM RESTRICAO GERAL - TODO OS GRUPOS E TODOS OS PRODUTOS  
				------------------------------------------------------------------------------------------*/		
				cGrpProd	:= PADR("*", TAMSX3("ZA7_CODGRP")[1])
				DBSELECTAREA("ZA7")
				ZA7->(DBSETORDER(2)) //| ZA7_FILIAL, ZA7_CODIGO, ZA7_CODGRP, ZA7_CODPRO, R_E_C_N_O_, D_E_L_E_T_ 	
				IF ZA7->(DBSEEK(xfilial("ZA7")+cCodReg+cGrpProd+"*"))
					nVlrLanc	:= ZA7->ZA7_LIMLAN 
					nVlrDia	:= ZA7->ZA7_LIMDIA
					nVlrMes	:= ZA7->ZA7_LIMMES	
					
					cTipoRest	:= ZA7->ZA7_RESTRI
					cTipoAprov	:= ZA7->ZA7_TIPAPR
					cComprov	:= ZA7->ZA7_COMPRO
				ENDIF					
			ENDIF			
		ENDIF
	
	ELSEIF cDespRef == "SED" .AND. !EMPTY(cCodNat)
	
		ZA7->(DBSETORDER(4)) //| ZA7_FILIAL+ZA7_CODIGO+ZA7_CODNAT 
		IF ZA7->(DBSEEK(xfilial("ZA7")+cCodReg+cCodNat)) 
			nVlrLanc	:= ZA7->ZA7_LIMLAN 
			nVlrDia	    := ZA7->ZA7_LIMDIA
			nVlrMes	    := ZA7->ZA7_LIMMES	
			cNatOK		:= ZA7->ZA7_CODNAT
			
			cTipoRest	:= ZA7->ZA7_RESTRI		
			cTipoAprov	:= ZA7->ZA7_TIPAPR
			cComprov	:= ZA7->ZA7_COMPRO
		ELSEIF ZA7->(DBSEEK(xfilial("ZA7")+cCodReg+"*"))
			nVlrLanc	:= ZA7->ZA7_LIMLAN 
			nVlrDia	:= ZA7->ZA7_LIMDIA
			nVlrMes	:= ZA7->ZA7_LIMMES	
			
			cTipoRest	:= ZA7->ZA7_RESTRI	
			cTipoAprov	:= ZA7->ZA7_TIPAPR
			cComprov	:= ZA7->ZA7_COMPRO	
		ENDIF		
	ENDIF


	IF !EMPTY(cTipoRest)
		//| Verifica se excedeu o limite por lancamento
		
		IF nVlrLanc > 0 .AND. nVlrDesp > nVlrLanc
			lExcedeu	:= .T.
			cMsgErro	:= "Valor excede o valor limite por lançamento."
		
		//| Verifica se excedeu o limite diario ou mensal
		ELSEIF nVlrDia > 0 .OR. nVlrMes > 0
		
			cParteA	:= " FROM "+RetSqlName("ZAF")+" ZAF "+CRLF
			
			
			//| PRODUTO
			IF cDespRef == "SB1"
			
				cParteA	+= " INNER JOIN "+RetSqlName("SB1")+" SB1 "+CRLF
				cParteA	+= " 	ON SB1.B1_FILIAL = '"+XFILIAL("SB1")+"' "+CRLF
				cParteA	+= " 	AND SB1.B1_COD = ZAF_CODPRO "+CRLF
				IF !EMPTY(cGrpOK)			
					cParteA	+= " 	AND SB1.B1_GRUPO = '"+cGrpOK+"' "+CRLF
				ENDIF
				cParteA	+= " 	AND SB1.D_E_L_E_T_ = '' "+CRLF
				cParteA	+= " WHERE ZAF_FILIAL = '"+XFILIAL("ZAF")+"' "+CRLF
				cParteA	+= " AND ZAF_CODUSR = '"+cCodUser+"' "+CRLF
				cParteA	+= " AND ZAF.D_E_L_E_T_ = '' "+CRLF
				IF !EMPTY(cProdOK)
					cParteA	+= " AND ZAF_CODPRO = '"+cProdOK+"' "+CRLF
				ENDIF		
				IF !EMPTY(cDespDesc)
					cParteA	+= " 	AND ZAF_CODIGO <> '"+cDespDesc+"'  "+CRLF
				ENDIF			
				
				cParteB		:= ""
				IF EMPTY(cProdOK) .AND. EMPTY(cGrpOK) 
					cParteB	:= " AND NOT EXISTS (SELECT ZA7_CODIGO "+CRLF
					cParteB	+= " 				FROM "+RetSqlName("ZA7")+" ZA7 "+CRLF
					cParteB	+= " 				WHERE ZA7_FILIAL = '"+XFILIAL("ZA7")+"' "+CRLF
					cParteB	+= " 				AND ZA7_CODIGO = '"+cCodReg+"' "+CRLF
					cParteB	+= " 				AND (ZA7.ZA7_CODGRP = SB1.B1_GRUPO "+CRLF
					cParteB	+= " 				OR ZA7.ZA7_CODPRO = SB1.B1_COD) "+CRLF
					cParteB	+= " 				AND ZA7.D_E_L_E_T_ = '') "+CRLF		
				ENDIF
				
				
			//| NATUREZA
			ELSEIF cDespRef == "SED"
			
				cParteA	+= " WHERE ZAF_FILIAL = '"+XFILIAL("ZAF")+"' "+CRLF
				cParteA	+= " AND ZAF_CODUSR = '"+cCodUser+"' "+CRLF
				cParteA	+= " AND ZAF.D_E_L_E_T_ = '' "+CRLF
				IF !EMPTY(cNatOK)
					cParteA	+= " AND ZAF_CODNAT = '"+cNatOK+"' "+CRLF
				ENDIF		
				IF !EMPTY(cDespDesc)
					cParteA	+= " 	AND ZAF_CODIGO <> '"+cDespDesc+"'  "+CRLF
				ENDIF
			
				
			ENDIF
		
		
			cQuery		:= " SELECT SUM(TOTDIA) AS TOTDIA, SUM(TOTMES) AS TOTMES
			cQuery		+= " FROM (
			cQuery		+= " SELECT ISNULL(SUM(ZAF_VLRTOT),0) AS TOTDIA, 0 AS TOTMES "+CRLF
			cQuery		+= cParteA			
			cQuery		+= " AND ZAF_DTDESP = '"+DTOS(dDataDesp)+"' "+CRLF
			cQuery		+= cParteB			
			cQuery		+= " UNION ALL "+CRLF
			cQuery		+= " SELECT 0 AS TOTDIA, ISNULL(SUM(ZAF_VLRTOT),0)  AS TOTMES "+CRLF
			cQuery		+= cParteA		
			cQuery		+= " AND ZAF_DTDESP BETWEEN '"+LEFT(DTOS(dDataDesp),6)+"01' AND '"+LEFT(DTOS(dDataDesp),6)+STRZERO(DAY(LASTDAY(dDataDesp)),2)+"' "+CRLF
			cQuery		+= cParteB
			cQuery		+= " ) A "

			
			If Select("TLIM") > 0
				TLIM->(DbCloseArea())
			EndIf
			
			DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TLIM",.F., .T.)						
						
			IF TLIM->(!EOF())
				IF nVlrDia > 0 .AND. TLIM->TOTDIA > nVlrDia
					 lExcedeu	:= .T.
					cMsgErro	:= "Valor excede o valor limite diario."
				ENDIF				
				IF nVlrMes > 0 .AND. TLIM->TOTMES > nVlrMes
					lExcedeu	:= .T.
					cMsgErro	:= "Valor excede o valor limite mensal."					
				ENDIF
			ENDIF	
			
			TLIM->(DbCloseArea())
		
		ENDIF
	ELSE
		lRet		:= .F.
		cMsgErro	:= "Não foi localizada regra para esta Despesa. Por favor contate o administrador do sistema."		 
	ENDIF

ELSE
	lRet		:= .F.
	cMsgErro	:= "Parametros Invalidos [LimDesp]"
ENDIF


aRet	:= {lRet, cMsgErro, lExcedeu, cTipoRest, cTipoAprov, cComprov}

Return(aRet)






/*/{Protheus.doc} FAction
Field Action da View
@author Augusto Ribeiro | www.compila.com.br
@since 22/01/2015
@version 1.0
@param ${param}, ${param_type}, ${param_descr}
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function  FAction(oView,  cIDView,  cField,  xValue)
Local oModFull 	:= oView:GetModel()
Local oModeZAF, nAux

oModeZAF	:= oModFull:GetModel('ZAFCABEC')

IF cField == "ZAF_CODPRO"
	
	nAux	:= ValTabela(oModeZAF:GetValue("ZAF_CODREG"), oModeZAF:GetValue("ZAF_CODPRO"), oModeZAF:GetValue("ZAF_CODNAT")) 
	_lVlrUni	:= .T.
	oModeZAF:SetValue("ZAF_VLRUNI", nAux)

	IF nAux > 0
		_lVlrUni	:= .F.
	ENDIF
	
ELSEIF cField == "ZAF_CODNAT" 	
	
	nAux	:= ValTabela(oModeZAF:GetValue("ZAF_CODREG"), oModeZAF:GetValue("ZAF_CODPRO"), oModeZAF:GetValue("ZAF_CODNAT")) 
	_lVlrUni	:= .T.
	oModeZAF:SetValue("ZAF_VLRUNI", nAux)

	IF nAux > 0
		_lVlrUni	:= .F.
	ENDIF
	
	
ENDIF

oView:Refresh() 

Return NIL





/*/{Protheus.doc} CP701BTN
Chamada de botoes da enchoice bar
@author Augusto Ribeiro | www.compila.com.br
@since 23/01/2015
@version 1.0
@param cBtn, C, Botao pressionado
@param oView, O, Objeto da View [Default: FWViewActive()]
@return ${return}, ${return_description}
/*/
User Function CP701BTN(cBtn, oView)
Local oView, nTotLen
Local oModFull
Local cPathDest, cPathArq
Local nI := 0


IF VALTYPE(oView) <> "O"
	oView	:= FWViewActive()
ENDIF

//| Visualizacao do arquivo onde o cursor esta posicionado
IF cBtn == "VISUALIZA_1"

	oModFull	:= oView:GetModel()
	oModeZAG	:= oModFull:GetModel("ZAGCOMPROV")
	
	cPathArq	:= oModeZAG:GetValue("ZAG_ARQUIV")

	IF !EMPTY(cPathArq)
		IF AT(":", cPathArq) > 0
			VisArq(cPathArq)
		ELSEIF !EMPTY(oModeZAG:GetValue("ZAG_ARQFIS"))
			VisArq(oModeZAG:GetValue("ZAG_ARQFIS"))
		ENDIF
	ENDIF
	
ELSEIF cBtn = "COPIA_COMPROV"


	IF	AVISO("Copia de comprovantes", "Todos os comprovantes serão copiados para sua estação de trabalho. "+CRLF+CRLF+"Deseja Continuar ?", {"Sim", "Não"},2) == 1

		//cPathDest	:= cGetFile("*.*", "Selecione o diretorio... ",,,.F.,GETF_NETWORKDRIVE+GETF_LOCALHARD+GETF_LOCALFLOPPY,.F. ) // "Selecione arquivo "
		
		cPathDest	:= cGetFile( '*.*' , 'TOTOS (*.*)', 1, 'C:\', .F., nOR( GETF_LOCALHARD, GETF_NETWORKDRIVE, GETF_RETDIRECTORY ),.F., .T. )
		IF !EMPTY(cPathDest)
			oModFull	:= oView:GetModel()
			oModeZAG	:= oModFull:GetModel("ZAGCOMPROV")
		
			nTotLen	:= oModeZAG:Length()
			FOR nI := 1 TO nTotLen
				
				oModeZAG:GoLine( nI )
				If !(oModeZAG:IsDeleted())
				
					cPathArq	:= oModeZAG:GetValue("ZAG_ARQUIV")
				
					IF !EMPTY(cPathArq)
						IF AT(":", cPathArq) == 0
							cPathArq	:= oModeZAG:GetValue("ZAG_ARQFIS")
						ENDIF
						
						__CopyFile(cPathArq , alltrim(cPathDest)+NomeArq(cPathArq))
					ENDIF				
				ENDIF			
			
			NEXT nI
			oModeZAG:GoLine(1)
		ENDIF
	ENDIF

ENDIF 

Return()


/*/{Protheus.doc} VisArq
Visualiza Arquivo 
COPIA PARA MAQUINA DO USUARIO E ABRE O ARQUIVO
@author Augusto Ribeiro | www.compila.com.br
@since 23/01/2015
@version 1.0
@param ${param}, ${param_type}, ${param_descr}
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function VisArq(cPathArq) 
Local cPathTemp	:= ""
Local cPathOrig	:= ""

   
     
IF !EMPTY(cPathArq) .AND. FILE(cPathArq)     
	
	
	IF AT(":", cPathArq) > 0
		cPathTemp	:= cPathArq
	ELSE
		cPathTemp	:=  GetTempPath(.T.)
		cPathTemp	+= NomeArq(cPathArq)
		
		__CopyFile(cPathArq , cPathTemp)
	ENDIF
	
	IF FILE(cPathTemp)
		WinExec("Explorer "+cPathTemp)
	ELSE		
		FwHelpShow(,"Arquivo inválido","Arquivo não encontrado.","Verifique se o arquivo realmente encontra-se em ["+cPathTemp+"]")
	ENDIF
  
  ELSE
	FwHelpShow(,"Arquivo inválido","Arquivo não encontrado.")
ENDIF

Return()



/*/{Protheus.doc} GRVMODEL
Grava Parametros
@author Augusto Ribeiro | www.compila.com.br
@since 14/02/2015
@version 1.0
@param oModel,O, Model
@return lRet, Retorno Aprovacao
@example
(examples)
@see (links_or_references)
/*/
Static Function GRVMODEL(oModFull)
Local lRet				:= .T.
Local aRetAux			:= {}
Local oModeZAF		:= oModFull:GetModel('ZAFCABEC')
 
Local cCodUser		:= oModeZAF:GetValue("ZAF_CODUSR")	
Local cCodReg		:= oModeZAF:GetValue("ZAF_CODREG")
Local cCodProd		:= oModeZAF:GetValue("ZAF_CODPRO")
Local cCodNat		:= oModeZAF:GetValue("ZAF_CODNAT")
Local nVlrDesp		:= oModeZAF:GetValue("ZAF_VLRTOT")
Local dDataDesp		:= oModeZAF:GetValue("ZAF_DTDESP")
Local cDespDesc		:= oModeZAF:GetValue("ZAF_CODIGO")

//| Busca informacao se o produto possui aprovacao automatica
aRetAux		:= LimDesp(cCodUser, cCodReg, cCodProd, cCodNat, nVlrDesp, dDataDesp, cDespDesc )



BEGIN TRANSACTION

FWFormCommit( oModFull )

/*------------------------------------------------------------|  Augusto Ribeiro - 14/02/2015
	Gera APROVACAO AUTOMATICA do reembolso
-------------------------------------------------------------------------------------------*/
IF aRetAux[5] == ZA7_TIPAPR_AUTO
	
	aRetAux	:= U_CP0706AP(, ZAF->(RECNO()), IDAPROVA_AUTO, "A")

	//| Notifica usuario POREM NAO RESTRINGI A INCLUSAO.	
	IF !(aRetAux[1])
		FwHelpShow(,"APROVA AUTO","Falha na aprovação automatica. ERRO: "+ALLTRIM(aRetAux[2]),"Contate o administrador.")
	ENDIF
ENDIF


END TRANSACTION
	
Return(lRet)




/*/{Protheus.doc} PermUsr
Verifica se usuario possui permissao para realizar lancamento com o codigo de usuario informado
@author Augusto Ribeiro | www.compila.com.br
@since 17/02/2017
@version 6
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function PermUsr(cCodUsr)
Local aRet		:= {.F., ""}
Local cQuery	:= ""
Local nI


Default cCodUsr	:= ""

DBSELECTAREA("ZA0")
ZA0->(DBSETORDER(1)) //| 
IF ZA0->(DBSEEK(xfilial("ZA0")+cCodUsr)) 
	
	IF ALLTRIM(cCodUsr) <> ALLTRIM(__CUSERID)
	
		DBSELECTAREA("ZAE")
		ZAE->(DBSETORDER(2)) //| 
		IF ZAE->(!DBSEEK(xfilial("ZAE")+ALLTRIM(__CUSERID)+cCodUsr)) 
			aRet[2] := 	"Acesso Negado. Você não possui permissão para realizar lançamentos para este usuário"
		ENDIF
	ENDIF
	
ELSE 

	aRet[2] := 	"Codigo do usuário não localiizado"				
ENDIF
	
	
	
IF EMPTY(aRet[2])
	aRet[1]	:= .T.
ENDIF

	
Return(aRet)



