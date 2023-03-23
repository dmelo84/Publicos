#Include "Protheus.Ch"
#Include "rwmake.Ch"
#include "TOTVS.CH"
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
#DEFINE CRLF chr(13) + chr(10)

/*------------------------------------------------------------|  Augusto Ribeiro - 14/02/2015
	CAMPOS COMBOS
	Defines visam facilitar futuras manutencoes
-------------------------------------------------------------------------------------------*/
//| --------- ZA0_PERFIL -------------
#DEFINE ZA0_PERFIL_USUARIO	"1"   
#DEFINE ZA0_PERFIL_ADMIN	"2"


//| --------- ZA1_STATUS -------------
#DEFINE ZAF_STATUS_RASCUNHO	"1"   
#DEFINE ZAF_STATUS_PENDENTE	"2"
#DEFINE ZAF_STATUS_APROVADO	"3"
#DEFINE ZAF_STATUS_REVISAO	"4"
#DEFINE ZAF_STATUS_RECUSADO	"5"
#DEFINE ZAF_STATUS_PAGO		"6"


//| --------- ZA7_TIPAPR -------------
#DEFINE ZA7_TIPAPR_PADRAO	"1"   
#DEFINE ZA7_TIPAPR_AUTO		"2"

//| Id aprovador automatico
#DEFINE IDAPROVA_AUTO		"AUTOMA"


#DEFINE D_TITULO 'Aprovação Reembolso de Despesa'     
#DEFINE D_ROTINA 'CP07006' 

/*/{Protheus.doc} CP07006
Interface para aprovação do reembolso de despesa 
@author Augusto Ribeiro | www.compila.com.br
@since 27/01/2014
@version 1.0
@return ${return}, ${return_description}
/*/
User function CP07006() 
//Local oBrowse  
PRIVATE _LCOPIA	:= .F.
Private xRetCon
Private oLbxMain,aHeadZAF, aDadoZAF, nColAnt
Private nZAFVLRTOT, nZAFCODIGO
Private cObsReprov	:= ""
Private cPerg			:= "CP0706"



//dbselectarea("ZA1")
//ZA1->(DBGoBottom())

//nRetAux := FWExecView(D_TITULO,D_ROTINA,  MODEL_OPERATION_INSERT,,  {|| .T. } )

/*
oBrowse := FWMBrowse():New()
oBrowse:SetAlias('ZAA')                         
//oBrowse:SetMenuDef( "ATEC204" )                   // Define de onde virao os botoes deste browse
oBrowse:SetDescription(D_TITULO)
  

//oBrowse:DisableDetails()

oBrowse:Activate()
*/
//oBrowse:New()


AjustSX1(cPerg)

IF PERGUNTE(cPerg, .T.)

	// (oPanel, cOpcList, oLbxMain,aHeader, aDados, nRecZA1)
	nRecZAF	:= 0
	IF ListAprov(,"V",,,, @nRecZAF)

		DBSELECTAREA("ZAF")
		ZAF->(DBGOTO(nRecZAF))	
		
		nRetAux := FWExecView(D_TITULO,D_ROTINA,  MODEL_OPERATION_VIEW,,  {|| .T. } )
	ENDIF
ENDIF

Return NIL

        
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ CP07006  ºAutor  ³Augusto Ribeiro     º Data ³ 07/01/2011  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ 	Botoes do MBrowser                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/  

Static Function MenuDef()
Local aRotina := {}


ADD OPTION aRotina TITLE 'Pesquisar' 	ACTION 'PesqBrw'             OPERATION 1 ACCESS 0
ADD OPTION aRotina TITLE 'Visualizar'	ACTION 'VIEWDEF.'+D_ROTINA OPERATION 2 ACCESS 0                         
ADD OPTION aRotina TITLE 'Incluir' 	    ACTION  'VIEWDEF.'+D_ROTINA OPERATION 3 ACCESS 0  	
ADD OPTION aRotina TITLE 'Alterar'		ACTION 'VIEWDEF.'+D_ROTINA OPERATION 4 ACCESS 0
ADD OPTION aRotina TITLE 'Excluir'		ACTION 'VIEWDEF.'+D_ROTINA OPERATION 5 ACCESS 0
ADD OPTION aRotina TITLE 'Copiar'		ACTION 'VIEWDEF.'+D_ROTINA OPERATION 9 ACCESS 0
ADD OPTION aRotina TITLE 'Imprimir'	ACTION 'VIEWDEF.'+D_ROTINA OPERATION 8 ACCESS 0
//ADD OPTION aRotina TITLE 'TESTE'     ACTION 'U_FAT01TST()' OPERATION 9 ACCESS 0
ADD OPTION aRotina TITLE 'Legenda'  ACTION 'eval(oBrowse:aColumns[1]:GetDoubleClick())'             OPERATION 1 ACCESS 0


// ADD OPTION aRotina TITLE 'Amarra B.I.'  ACTION 'U_EST02MNU("AMARRA")' OPERATION 2 ACCESS 0
Return aRotina



/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ CP07006  ºAutor  ³Augusto Ribeiro     º Data ³ 19/11/2013  º±±
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

// Cria o objeto do Mod elo de Dados
oModel := MPFormModel():New(D_ROTINA+'MODEL',  /*bPreValidacao*/, bVldPosFull /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )
//oModel := MPFormModel():New('ATEC204MODEL', /*bPreValidacao*/,/*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'ZAFCABEC', /*cOwner*/, oStruZAF, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
oModel:AddGrid( 'ZAGCOMPROV', 'ZAFCABEC', oStruZAG, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )
oModel:AddGrid( 'ZA3VINCULO', 'ZAFCABEC', oStruZA3, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/,  /*BLoad*/ )

// Adiciona modelo de contador. 
// AddCalc(cId , cOwner , cIdForm , cIdField , cIdCalc , cOperation , bCond , bInitValue , cTitle , bFormula , nTamanho, nDecimal)
oModel:AddCalc( 'CP0706_CALC', 'ZAFCABEC', 'ZA3VINCULO', 'ZA3_RECREG', 'TOTALDESP', 'FORMULA', /*bCond */, /*bInitValue*/ , 'Total Depesas' , {|oModel| CampoCalc("DESPESA",aHeadZAF, aDadoZAF) }, 9 /*nTamanho*/, 2/*nDecimal*/)
oModel:AddCalc( 'CP0706_CALC', 'ZAFCABEC', 'ZA3VINCULO', 'ZA3_RECREG', 'TOTALAPROV', 'FORMULA', /*bCond */, /*bInitValue*/ , 'Total Selecionado' , {|oModel| CampoCalc("APROVADO",aHeadZAF, aDadoZAF) }, 9 /*nTamanho*/, 2/*nDecimal*/)



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
oModel:GetModel( 'ZA3VINCULO' ):SetDescription( 'Vinculos' )

//oModel:GetModel( 'ZA2COMPROV' ):SetOptional(.T.)
oModel:GetModel( 'ZA3VINCULO' ):SetOptional(.T.)         
       
// Liga a validação da ativacao do Modelo de Dados
//oModel:SetVldActivate( { |oModel,cAcao| U_CP701VLD('MODEL_ACTIVE', oModel) } )
oModel:SetActivate( {|oModel| SetKey ( VK_F12, {||  U_CP701BTN('VISUALIZA_1')} ) ,U_CP701ZA3(oModel)} )

Return oModel


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ CP07006  ºAutor  ³Augusto Ribeiro     º Data ³ 07/01/2011  º±±
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

//Local oStruCSW := FWFormStruct( 1, 'CSW', /*bAvalCampo*/, /*lViewUsado*/ ) 
//Local oModel

oStruZA3:RemoveField( 'ZA3_INDCHV' )                                   
oStruZA3:RemoveField( 'ZA3_RECREG' )
                        
// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

// Cria o objeto de Estrutura 
oCpoCalc := FWCalcStruct( oModel:GetModel( 'CP0706_CALC') )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddOtherObject("LIST_APROV", {|oPanel| ListAprov(oPanel, "C", @oLbxMain, @aHeadZAF, @aDadoZAF) })
oView:AddGrid( 'VIEW_ZAG', oStruZAG, 'ZAGCOMPROV' )
oView:AddGrid( 'VIEW_ZA3', oStruZA3, 'ZA3VINCULO' )

oView:AddField( 'VIEW_CALC', oCpoCalc, 'CP0706_CALC' )
oView:AddOtherObject("BUTTON", {|oPanel| BtnTail(oPanel) })


// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'TOP' , 60 )
oView:CreateHorizontalBox( 'BOTTOM' , 30) 	          
oView:CreateHorizontalBox( 'TAIL' , 10)


oView:CreateVerticalBox( 'LEFT_TOP'			, 70,'TOP')
oView:CreateVerticalBox( 'RIGHT_TOP'		, 30,'TOP')
oView:CreateVerticalBox( 'LEFT_BOTTOM'			, 70,'BOTTOM')
oView:CreateVerticalBox( 'RIGHT_BOTTOM'		, 30,'BOTTOM')
//oView:CreateVerticalBox( 'LEFT_TAIL'			, 70,'TAIL')
//oView:CreateVerticalBox( 'RIGHT_TAIL'			, 30,'TAIL')   


// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'LIST_APROV', 'LEFT_TOP')
oView:SetOwnerView( "BUTTON"  , 'RIGHT_TOP' )
oView:SetOwnerView( 'VIEW_ZA3', 'LEFT_BOTTOM')
oView:SetOwnerView( 'VIEW_ZAG', 'RIGHT_BOTTOM')
oView:SetOwnerView( "VIEW_CALC"  , 'TAIL' )


// Define campos que terao Auto Incremento
oView:AddIncrementField( 'VIEW_ZAG', 'ZAG_ITEM' )
oView:AddIncrementField( 'VIEW_ZA3', 'ZA3_ITEM' )

//oView:AddOtherObject("ABAIXO_CAL", {|oPanel| U_FAT01BCAL(oPanel)})
//oView:SetOwnerView("ABAIXO_CAL",'RIGHT_SUP2')



// Criar novo botao na barra de botoes no antigo Enchoice Bar            
oView:AddUserButton( 'Visualizar Comprovante (F12)', 'Visualizar Comprov.', { |oView| U_CP701BTN('VISUALIZA_1', oView) } )
oView:AddUserButton( 'Copiar Comprovantes', 'Copiar Comprov.', { |oView| U_CP701BTN('COPIA_COMPROV', oView) } )

// Liga a identificacao do componente
oView:EnableTitleView('LIST_APROV', "Despesas Pendentes de Aprovação")
oView:EnableTitleView('BUTTON', "Aprovar / Reprovar")
oView:EnableTitleView('VIEW_ZAG')
oView:EnableTitleView('VIEW_ZA3')
//oView:EnableTitleView('VIEW_CALC','Totalizadores')


// Liga a Edição de Campos na FormGrid
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

/*/{Protheus.doc} CP706VLD
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
User Function CP706VLD(cModel, oModel)
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

/*/{Protheus.doc} CP706CPO
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
User Function CP706CPO(cCampo, cTipo)
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
	//	lRet	:= U_CP706SB1(M->ZAA_CODPRO)
	
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

/*/{Protheus.doc} CP706GAT
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
  
User Function CP706GAT(cCampo, cContra)
Local xRet

Default cCampo := "" 

cCampo := alltrim(cCampo)

IF cCampo == "ZAA_CODPRO" .AND. cContra == "ZAA_VLRUNI"


	xRet	:= 0
//	xRet	:= POSICIONE("SB1",1,XFILIAL("SB1")+ , "B1_UM" )

ENDIF


Return(xRet)

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

/*/{Protheus.doc} ListAprov
Lista reembolsos pendentes de aprovacao
@author Augusto Ribeiro | www.compila.com.br
@since 27/01/2015
@version 1.0
@param oPanel,  O, Objeto onde sera criado o listbox
@param cOpcList, C, C=CRIA, A=ATUALIZA, V=VALIDA SE EXISTE DADOS
@param oLbxMain,  O, ListBox (passada por referencia)
@param aHeader,  A, Heaer (passada por referencia)
@param aDados,  A, Dados (passada por referencia)
@return lRet, L, .T.=ExisteDados ,.F.=Não existe dados
/*/
Static Function ListAprov(oPanel, cOpcList, oLbxMain,aHeader, aDados, nRecZAF)
Local lRet		:= .T.
Local cQuery	:= "" 
Local aCpoHeader
Local cBCodLin	:= ""  
Local oOk 	     	:= LoadBitmap( GetResources(), "LBOK" )
Local oNo   	   	:= LoadBitmap( GetResources(), "LBNO" )
Local nLinIni
Local cDespRef	:= U_CP07002G("20", "ALIASDESP", "SED")
Local cFieldName, xConteudo, nY
Local nRecZAF	:= 0

aCpoHeader	:= {} 
aHeader	:= {} 
aDados		:= {}

cQuery	:= ""
IF cDespRef == "SED"
	cQuery	+= " SELECT ZAF_CODIGO, ZAF_DTDESP, ZAF_CODUSR, '' AS ZAF_NOMUSR, ZAF_CODIGO, ZAF_CODNAT , SED.ED_DESCRIC AS DESCDEP, ZAF_VLRTOT, ZAF.R_E_C_N_O_ AS ZAF_RECNO "+CRLF
ELSEIF  cDespRef == "SB1"
	cQuery	+= " SELECT ZAF_CODIGO, ZAF_DTDESP, ZAF_CODUSR, '' AS ZAF_NOMUSR, ZAF_CODIGO, ZAF_CODPRO , SB1.B1_DESC AS DESCDEP, ZAF_VLRTOT, ZAF.R_E_C_N_O_ AS ZAF_RECNO "+CRLF
ENDIF

cQuery	+= " FROM "+RetSqlName("ZAF")+" ZAF "+CRLF
cQuery	+= " INNER JOIN "+RetSqlName("ZA6")+" ZA6 "+CRLF
cQuery	+= " 	ON ZA6_FILIAL = '"+xFilial("ZAF")+"'"+CRLF
cQuery	+= " 	AND ZA6_CODIGO = ZAF_CODREG "+CRLF
cQuery	+= " AND ZA6_CODUSR = '"+__CUSERID+"' "+CRLF
cQuery	+= " 	AND ZA6.D_E_L_E_T_ != '*' "+CRLF

IF cDespRef == "SED"
	cQuery	+= " INNER JOIN "+RetSqlName("SED")+" SED "+CRLF
	cQuery	+= " 	ON ED_FILIAL = '"+XFILIAL("SED")+"' "+CRLF
	cQuery	+= " 	AND ED_CODIGO = ZAF_CODNAT "+CRLF
	cQuery	+= " 	AND SED.D_E_L_E_T_ != '*' "+CRLF
ELSEIF cDespRef == "SB1"
	cQuery	+= " INNER JOIN "+RetSqlName("SB1")+" SB1 "+CRLF
	cQuery	+= " 	ON SB1.B1_FILIAL = '"+XFILIAL("SB1")+"' "+CRLF
	cQuery	+= " 	AND SB1.B1_COD = ZAF_CODPRO "+CRLF
	cQuery	+= " 	AND SB1.D_E_L_E_T_ != '*' "+CRLF
ENDIF

cQuery	+= " WHERE ZAF_FILIAL = '' "+CRLF
cQuery	+= " AND ZAF_CODUSR <> '' "+CRLF 
cQuery	+= " AND ZAF_CODUSR BETWEEN '"+MV_PAR01+"' AND '"+MV_PAR02+"' "+CRLF
	if !empty(MV_PAR03) .or. !empty(MV_PAR04)
		cQuery	+= " AND ZAF_DTDESP BETWEEN '"+DTOS(MV_PAR03)+"' AND '"+DTOS(MV_PAR04)+"' "+CRLF
	endif
cQuery	+= " AND ZAF_STATUS = '"+ZAF_STATUS_PENDENTE+"' "+CRLF
cQuery	+= " AND ZAF.D_E_L_E_T_ != '*' "+CRLF
cQuery	+= " AND NOT EXISTS (SELECT ZAC_CODIGO "+CRLF 
cQuery	+= " 					FROM "+RetSqlName("ZAC")+" ZAC "+CRLF
cQuery	+= " 					WHERE ZAC_FILIAL  = ZAF_FILIAL "+CRLF
cQuery	+= " 					AND ZAC_CODIGO = ZAF_CODIGO "+CRLF
cQuery	+= " 					AND ZAC_NIVEL = ZA6_NIVEL "+CRLF
cQuery	+= " 					AND ZAC.D_E_L_E_T_  != '*') "+CRLF



If Select("QRY") > 0
	QRY->(DbCloseArea())
EndIf
          
MSGRUN("Busca clientes....","SQL" ,		{|| dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),'QRY') } )

TCSetField("QRY","ZAF_DTDESP","D",08,00)					


//| Somente valida se existem dados.
 
IF cOpcList == "V"
	IF QRY->(EOF())
		FwHelpShow(,"VAZIO","Não existem dados a serem exibidos.","Por favor verifique os parametros informados") 
		return(.f.)
	ELSE
		return(.T.)
	ENDIF
ENDIF



//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ cOpcList | C = Cria, A = Atualiza ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
IF cOpcList == "C"

	nLinIni	:= 13
	
	nWidth		:= (oPanel:nWidth*0.50)-2
	nHeight	:= (oPanel:nHeight*0.50)-nLinIni-2

	@ nLinIni,1 LISTBOX oLbxMain FIELDS HEADER ;
	   " ", "Campos" ;                                                                                                    
	   SIZE nWidth,nHeight  OF oPanel  PIXEL .T. ON dblClick( aDados[oLbxMain:nAt,1] := !aDados[oLbxMain:nAt,1] , ReCalc(oLbxMain))
	   
	oLbxMain:aheaders := aHeader		   

	oLbxMain:BHEADERCLICK	:= { |oObj,nCol| U_CPXORDH( oObj,nCol,.T.), PosModel(@oLbxMain,@aHeader, @aDados), oLbxMain:Refresh() }
	
	oLbxMain:bChange := {|| PosModel(@oLbxMain,@aHeader, @aDados), oLbxMain:Refresh() }			
	
ENDIF

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta aHeader ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ	
aDados	:= {}
aLinha	:= {}		

aadd(aHeader,"")                  
aadd(aCpoHeader,"")  
aadd(aLinha, .F.)
For nY := 1 To QRY->(FCOUNT())         

	cCpoNome	:= FieldName(nY)
	cCpoTitle	:= alltrim(RetTitle(cCpoNome))


	IF cCpoNome == "CODDESP"
		aadd(aHeader, "Cod.Despesa" )
	ELSEIF cCpoNome == "DESCDEP"
		aadd(aHeader, "Despesa" )
	ELSEIF cCpoNome == "ZAF_RECNO"		
		aadd(aHeader, "ID Registro" )
	ELSE
		aadd(aHeader,cCpoTitle)
	ENDIF

   	//aadd(aHeader,cCpoTitle )
	aadd(aCpoHeader,cCpoNome)
	
	IF EMPTY(cCpoTitle)		
		aadd(aLinha, "" )
	ELSE                                              				
		aadd(aLinha, CRIAVAR(cCpoNome,.F.) )
	ENDIF		
	
Next nY	

oLbxMain:aheaders := aHeader
//AADD(aDados, aLinha)		

IF QRY->(!EOF()) 

	// DBSELECTAREA("ZA1")
	// ZA1->(DBGOTO(QRY->ZA1_RECNO))
	
	nRecZAF	:= QRY->ZAF_RECNO
	
	
	/*
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta aHeader ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aadd(aHeader,"")                  
	aadd(aCpoHeader,"") 
	For nY := 1 To QRY->(FCOUNT())         
	   	aadd(aHeader,ALLTRIM(RetTitle(FieldName(nY))))
		aadd(aCpoHeader,FieldName(nY))
	Next nY
	*/	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Variaveis de posionamento dos campos ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	nZAFVLRTOT		:= Ascan(aCpoHeader,"ZAF_VLRTOT")
	nZAFCODIGO		:= 	Ascan(aCpoHeader,"ZAF_CODIGO")
	
	/*
	nP04CODCLI	:=  Ascan(aCpoHeader,"P04_CODCLI")
	*/	
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Monta aDados ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aDados	:= {}
	WHILE QRY->(!EOF())
		aLinha	:= {}
		aadd(aLinha, .F.)
		For nY := 1 To QRY->(FCOUNT())      

			cFieldName	:= ALLTRIM(FieldName(nY))
			xConteudo	:= QRY->&(cFieldName)

			IF VALTYPE(xConteudo) == "C"     
			
				IF cFieldName == "ZAF_NOMUSR"
					aadd(aLinha, ALLTRIM(UsrFullName(QRY->ZAF_CODUSR)) )
				ELSE
					aadd(aLinha, ALLTRIM(xConteudo) )
				ENDIF
			ELSE                                              				
				aadd(aLinha, xConteudo )
			ENDIF
		Next nY	 
		
	 	AADD(aDados, aLinha)
	 	
		QRY->(DBSKIP())
	ENDDO
ENDIF 


IF VALTYPE(oLbxMain) == "O"
	
	oLbxMain:SetArray( aDados )  
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria string com Bloco de Codigo ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cBCodLin	:= ""
	
	cBCodLin	:= "Iif(aDados[oLbxMain:nAt,1],oOk,oNo)"	
	For nI := 2 To LEN(aHeader)
		IF nI > 1
			cBCodLin	+=", "
		endif
	   cBCodLin	+= "aDados[oLbxMain:nAt,"+alltrim(str(nI))+"]"
	Next nI	

	IF EMPTY(aDados)
		oLbxMain:bLine	:= {|| }
	ELSE
		cBCodLin	:= "oLbxMain:bLine := {|| {"+cBCodLin+"}}"
		&(cBCodLin)
	ENDIF  
	
	oLbxMain:Refresh()  
ENDIF

Return(lRet)



/*/{Protheus.doc} PosModel
Posiciona Model ZA1 de acordo com o RECNO posicinado no ListBox
@author Augusto Ribeiro | www.compila.com.br
@since 28/01/2015
@version 1.0
@param oLbxAux, O, Objeto ListBox
@param aHeader, A, Header do ListBox
@param aDados, A, Dados do ListBox
@return ${return}, ${return_description}
/*/
Static Function PosModel(oLbxAux,aHeader, aDados)
Local nRecZAF
Local oView
Local oModFull

IF !EMPTY(aDados)

	nRecZAF	:= aDados[oLbxAux:nAT,len(aHeader)]
	ZAF->(DBGOTO(nRecZAF))
	
	
	
	oModFull	:= FWModelActive()
	oModFull:DeActivate()
	oModFull:Activate()
	
	oView	:= FWViewActive()
	oView:Refresh()
	//oView:DeActivate(.T.)
	//oView:Activate()
	
	//SetFocus(oLbxMain:hParent)
	SetFocus(oLbxMain:hWnd)
			
ENDIF

Return()



/*/{Protheus.doc} CampoCalc
Funcao que atualiza campos calculados
@author Augusto Ribeiro | www.compila.com.br
@since 28/01/2015
@version 1.0
@param cOpcCalc, C, Opcao de Calculo | DESPESA, APROVADO
@param aHeader, A, Header do ListBox
@param aDados, A, Dados do ListBox
@return ${return}, ${return_description}
/*/
Static Function CampoCalc(cOpcCalc,aHeader, aDados)
Local nRet := 0
Local nTotReg, nI

Default cOpcCalc	:= ""

IF !EMPTY(aDados) .AND. !EMPTY(nZAFVLRTOT)
	nTotReg	:= len(aDados)	
	FOR nI := 1 TO nTotReg
		IF cOpcCalc == "DESPESA"
			nRet += aDados[nI,nZAFVLRTOT]
		ELSEIF cOpcCalc == "APROVADO"
			IF aDados[nI, 1]
				nRet += aDados[nI,nZAFVLRTOT]
			ENDIF
		ENDIF
	Next nI
	

endif

Return(nRet)



/*/{Protheus.doc} ReCalc
 Recalcul valores dos campos calculados após selecionar um novo item
@author Augusto Ribeiro | www.compila.com.br
@since 31/01/2015
@version 1.0
/*/
Static Function ReCalc(oLbxMain)

oModFull	:= FWModelActive()
oModFull:DeActivate()
oModFull:Activate()

oView	:= FWViewActive()
oView:Refresh()
	
SetFocus(oLbxMain:hWnd)
	
Return()



/*/{Protheus.doc} btnTail
Cria botões no rodapé.
APROVA e REPROVA
@author Augusto Ribeiro | www.compila.com.br
@since 31/01/2015
@version 1.0
@param oPanel,  O, Objeto onde sera criado o listbox
/*/
Static Function btnTail(oPanel)
Local oBtn1,oBtn2, nTop, nLeft
Local oCpoOBS, cCpoOBS

//SButton(): New ( [ nTop], [ nLeft], [ nType], [ bAction], [ oWnd], [ lEnable], [ cMsg], [ bWhen] )
//oBtn1	:= SButton():New( 1, 1, 1, {|| ALERT("APROVA") }, oPanel, .T., "APROVAR", )
//oBtn1	:= SButton():New( 10, 20, 2, {|| ALERT("REPROVA") }, oPanel, .T., "REPROVAR", )
	//TButton(): Create ( [ oWnd], [ nRow], [ nCol], [ cCaption], [ bAction], [ nWidth], [ nHeight], [ uParam8], [ oFont], [ uParam10], [ lPixel], [ uParam12], [ cMsg], [ uParam14], [ bWhen], [ bValid], [ uParam17] )

aRetTst	:=	 FWGetDialogSize(oPanel)

nTop	:= 15
nLeft	:= 6

nLeftB	:= aRetTst[4] * 0.115

oSay:= TSay():New(nTop, nLeft ,{||RetTitle("ZAC_OBSREC")},oPanel,,,,,,.T.,CLR_BLACK,CLR_WHITE,200,20)

nTop	:= nTop+8

oBtn1 := TButton():Create(oPanel, nTop, nLeftB, "APROVAR", {|| Processa({|| AprovRep(@aDadoZAF,"A") }, "Processando... ")  }, 40, 12, , /*[ oFont]*/, , .T., , "Aprovar despesas selecionadas", , /*[bWhen]*/, /*[bValid]*/)
oBtn2 := TButton():Create(oPanel, nTop+68, nLeftB, "REPROVAR", {||  Processa({|| AprovRep(@aDadoZAF,"R", @cObsReprov) }, "Processando... ") }, 40, 12, , /*[ oFont]*/, , .T., , "Reprova despesas selecionadas", , /*[bWhen]*/, /*[bValid]*/)



// TMultiGet(): Create ( [ oWnd], [ bSetGet], [ nRow], [ nCol], [ nWidth], [ nHeight], [ oFont], [ lHScroll], [ nClrFore], [ nClrBack], [ uParam11], [lPixel], [ uParam13], [ uParam14], [ bWhen], [ uParam16], [ uParam17], [ lReadOnly], [ bValid], [ uParam20], [ uParam21], [ lNoBorder], [ lVScroll], [cLabelText] ,[nLabelPos], [oLabelFont], [nLabelColor]  ) --> oObjeto
oCpoOBS	:= TMultiget():Create(oPanel,{|u|if(Pcount()>0,cObsReprov:=u,cObsReprov)} ,nTop,nLeft, /*120*/ nLeftB-20, 80 ,/*[ oFont]*/,/* [ lHScroll]*/,/*[ nClrFore]*/,/*[ nClrBack]*/,/*[ uParam11]*/,.T.)

//oCpoOBS	:= TMultiget():Create(oDlg,{|u|if(Pcount()>0,cTexto2:=u,cTexto2)},92,01,;                           260,92,,,,,,.T.)



Return(.T.)



/*/{Protheus.doc} CP0706AP
Realiza APROVACAO do reembolso de despesa
@author Augusto Ribeiro | www.compila.com.br
@since 31/01/2015
@version 1.0
@param cCodDesp, C, Codigo da Despesa 
@param nRecDesc, N, Recno da despessa
@param cIDAprov, C, Codigo do Aprovador (* __cUserID)
@param cOper, C, A=APROVA, R=REPROVA
@param cMsgReprova, C, Motivo da Recusa descrito
@return aRet, {lRet, cMsgErro}
/*/
User Function CP0706AP(cCodDesp, nRecDesc, cIDAprov, cOper, cMsgReprova)
Local aRet			:= {.F., ""}
Local lPosZAF		:= .f.
Local aLogAprov	:= {}	 
Local aRetAux, lAltStatus
Local cZA6TIPO, cZA6NIVEL, cZA6CODIGO, ZA6ITEM
Local aInfo := {}

Default cIDAprov		:= __cUserID
Default cMsgReprova	:= ""


IF (!EMPTY(cCodDesp) .OR. !EMPTY(nRecDesc)) .and. !empty(cOper)
	
	lPosZAF	:= .F.
	
	DBSELECTAREA("ZAF")
	ZAF->(DBSETORDER(1))
	IF !EMPTY(nRecDesc)
		ZAF->(DBGOTO(nRecDesc))
	
		lPosZAF	:= .T.
	ELSEIF ZAF->(DBSEEK(xfilial("ZAF")+cCodDesp))
		lPosZAF	:= .T.
	ENDIF
	
	
	IF lPosZAF	
		
		DBSELECTAREA("ZAC")
		ZAC->(DBSETORDER(2)) //| ZAC_FILIAL+ZAC_CODIGO+ZAC_CODUSR
		IF ZAC->(!DBSEEK(xfilial("ZAC")+ZAF->ZAF_CODIGO+cIDAprov)) .OR. cIDAprov == IDAPROVA_AUTO
	
			//| Verifica saldo disponivel para o Aprovador
			//nSaldo	:= U_CP0706SD(cIDAprov, ZA1->ZA1_CODREG)
			//U_CP0706SD(cIDAprov, cCodReg)
			
			DBSELECTAREA("ZA6")
			ZA6->(DBSETORDER(2)) //| ZA6_FILIAL+ZA6_CODIGO+ZA6_CODUSR
			IF ZA6->(DBSEEK(xfilial("ZA6")+ZAF->ZAF_CODREG+cIDAprov)) .OR. cIDAprov == IDAPROVA_AUTO
			
				//| Dados do aprovador ou aprovador automatico
				IF cIDAprov == IDAPROVA_AUTO 
					cZA6TIPO		:= "2" //| Aprova
					cZA6NIVEL		:= ""
					cZA6CODIGO		:= ""
					ZA6ITEM		    := ""
					
				ELSE
					cZA6TIPO		:= ZA6->ZA6_TIPO
					cZA6NIVEL		:= ZA6->ZA6_NIVEL
					cZA6CODIGO		:= ZA6->ZA6_CODIGO
					ZA6ITEM		    := ZA6->ZA6_ITEM			
				ENDIF
				
				
				
				
				
				BEGIN TRANSACTION
				
				
				aadd(aLogAprov, {"ZAC_CODIGO",	ZAF->ZAF_CODIGO})
				aadd(aLogAprov, {"ZAC_ITEM",	ItemZAC(ZAF->ZAF_CODIGO) })
				aadd(aLogAprov, {"ZAC_TIPO", 	cZA6TIPO })
				aadd(aLogAprov, {"ZAC_CODUSR",	cIDAprov })
				aadd(aLogAprov, {"ZAC_NIVEL", 	cZA6NIVEL})
				IF !EMPTY(cMsgReprova)
					aadd(aLogAprov, {"ZAC_OBSREC",	cMsgReprova})
				ENDIF
				aadd(aLogAprov, {"ZAC_CODREG", cZA6CODIGO})
				aadd(aLogAprov, {"ZAC_ITEAPR", ZA6ITEM })
				
				aRetAux	:= U_CPXGRV("ZAC", 1, aLogAprov)
				
				IF aRetAux[1]
				
				
					IF cOper == "R"
						RECLOCK("ZAF",.F.)
							ZAF->ZAF_STATUS := ZAF_STATUS_RECUSADO 
						MSUNLOCK()
					ELSE

						
						IF cIDAprov == IDAPROVA_AUTO
							lAltStatus		:= .T.						
						ELSE
							/*---------------------------------------------------------------------------------------
								VERIFICA SE EXISTEM MAIS APROVACOES A SEREM REALIZADAS. 
								CASO, NAO = ALTERA STATUS PARA APROVADO 
							------------------------------------------------------------------------------------------*/
							DBSELECTAREA("ZA6")
							ZA6->(DBSETORDER(3)) //| ZA6_FILIAL+ZA6_CODIGO+ZA6_NIVEL
							IF ZA6->(DBSEEK(xfilial("ZA6")+ZAF->ZAF_CODREG+cZA6NIVEL)) 
								lAltStatus		:= .T.
								WHILE ZA6->(!EOF()) .AND. ZA6->ZA6_CODIGO == ZAF->ZAF_CODREG
								
									IF ZA6->ZA6_NIVEL > cZA6NIVEL
										lAltStatus	:= .F.
										EXIT
									ENDIF
								
									ZA6->(DBSKIP()) 
								ENDDO
							ENDIF
						ENDIF
						
						//| Altera o status do registro de Reembolso de Despesa
						IF lAltStatus
							RECLOCK("ZAF",.F.)
								ZAF->ZAF_STATUS := ZAF_STATUS_APROVADO //| 1=Rascunho;2=Pendente Aprov.;3=Aprovado;4=Em Revisao;5=Recusado
							MSUNLOCK()
						ENDIF
														
					ENDIF
				ELSE
					DISARTRANSCTION()
					aRet[2]	:= ALLTRIM(aRetAux[2])+". [CP0706AP]"
				ENDIF
								
				END TRANSACTION
				
				aRet[1]	:= .T.

				/*Diogo - Envio de email WF*/
				If cOper = "R"	

				aAdd(aInfo,cCodDesp)
				aAdd(aInfo,cMsgReprova)
				
					u_oSndMail(/*cFrom*/, /*cBody*/, /*cSubJect*/, /*cTo*/, /*cCC*/, /*cBCC*/, /*cFileAttach*/,aInfo )
				endIf
				/**/

			ELSE
				aRet[2]	:= "Usuario ["+alltrim(cIDAprov)+"] não é um aprovador para a regra ["+ZAF->ZAF_CODREG+"]. [CP0706AP]"		
			ENDIF
		ELSE
			aRet[2]	:= "O usuário ["+cIDAprov+"] já aprovou este item. [CP0706AP]"
		ENDIF
	ELSE		
		aRet[2]	:= "Despesa não localizada. [CP0706AP]"
	ENDIF	
ELSE
	aRet[2]	:= "Parametros inválidos. [CP0706AP]"
ENDIF

Return(aRet)




/*/{Protheus.doc} ItemZAC
Retorna Codigo do proximo item do historico de aprovação por despesa.
@author Augusto Ribeiro | www.compila.com.br
@since 31/01/2015
@version 1.0
@param cCodDesp, C, Codigo da Despesa
/*/
Static Function ItemZAC(cCodDesp)
Local cItem	:= "001"


DBSELECTAREA("ZAC")
ZAC->(DBSETORDER(1))
IF ZAC->(DBSEEK(XFILIAL("ZAC")+cCodDesp))
	
	WHILE ZAC->(!EOF()) .AND. ZAC->ZAC_CODIGO == cCodDesp
	
		cItem	:= ZAC->ZAC_ITEM
	
		ZAC->(DBSKIP()) 
	ENDDO
	
	cItem	:= SOMA1(cItem)
ENDIF


Return(cItem)


/*/{Protheus.doc} AprovRep
Aprova/Reprova itens selecionados no ListMark
@author Augusto Ribeiro | www.compila.com.br
@since 31/01/2015
@version 1.0
@param aDadosLbx, C, Array do ListMark
@param cOper, C, A=APROVA, R=REPROVA
@example
(examples)
@see (links_or_references)
/*/
Static Function AprovRep(aDadosLbx, cOper, cMsgReprova)
Local nI
Local nTotSel := 0
Local nPosRecno, aRetAux
Local aPosArray	:= {}
Local cMsgProc	:= ""
Local cLogErro	:= ""
Local cMsgReprova, cMsgAviso
Local aGerTit := {}
Local aDadoZAD := {}
Local cMsgErro := ""


IF !EMPTY(aDadosLbx) .AND. !EMPTY(cOper)

	cMsgReprova	:= ALLTRIM(cMsgReprova)
	
	nPosRecno	:= LEN(aDadosLbx[1])
	nPosIdDes   := aScan(aHeadZAF,"Cod. Despesa")
	/*DMS - Diogo Melo*/
	aGerTit := aClone(aDadosLbx)
	/**/
	IF nPosRecno > 0
	
		IF cOper == "A"
			cMsgProc	:= "Aprovando despesas..."
		ELSEIF cOper == "R"
			cMsgProc	:= "Reprovando despesas..."
		ENDIF
	
	
		/*---------------------------------------------------------------------------------------
			Armazena posicao do Array onde esta selecionado o registro 
		------------------------------------------------------------------------------------------*/
		FOR nI := 1 to LEN(aDadosLbx)
		
			IF aDadosLbx[nI, 1]
				AADD(aPosArray, nI) 
				nTotSel++
			ENDIF
		NEXT nI
		
		
		IF nTotSel > 0
			
			//| Verifica se o motivo da reprova foi preenchido.  
			IF cOper == "R" .and. EMPTY(cMsgReprova)
				FwHelpShow(,"OBRIGATORIO","Para reprovação das despesas selecionadas, é obrigatório o preenchimento do campo "+RetTitle("ZAC_OBSREC"), "" )
			ELSE
			
				cMsgAviso	:= "Todos os itens selecionados serão "+IIF(cOper=="A","APROVADOS", "REPROVADOS")+CRLF+CRLF+"Deseja Continuar ?"
				
				IF AVISO(IIF(cOper=="A","APROVAR", "REPROVAR"),cMsgAviso	, {"Sim", "Não"},1) == 1
					
					
					ProcRegua(nTotSel)
					
					FOR nI := 1 to LEN(aPosArray)
						IncProc(cMsgProc)
					
						aRetAux	:= U_CP0706AP(aDadosLbx[aPosArray[nI], nPosIdDes], aDadosLbx[aPosArray[nI], nPosRecno], __cUserID, cOper, cMsgReprova)
						
						IF !(aRetAux[1])
							cLogErro	:= "DESP: "+aDadosLbx[aPosArray[nI], nZAFCODIGO]+" | Erro: "+aRetAux[2]
						ENDIF
						
					NEXT nI
		
					
					IF !(EMPTY(cLogErro))
						cLogErro	:= "LOG DE ERRO"+CRLF+CRLF+ cLogErro
						
						AVISO("Log de Erro", cLogErro, {"Fechar"},3, "Um ou mais itens não foram aprovados. Por favor verifique o logs abaixo.")
					ENDIF
					
					//| Atualiza ListMark
					ListAprov(, "A", @oLbxMain, @aHeadZAF, @aDadoZAF)
					PosModel(@oLbxMain,@aHeadZAF, @aDadoZAF)
					
					IF cOper=="R"
						cMsgReprova	:= ""
					ENDIF
					/**/
					IF cOper=="A"
						//| Verifica se existe natureza FIXA cadastrada
						cNatureza	:= U_CP07002G("20", "NATUREZFIX", "")
						
						/*DMS - Diogo Melo */
						IF !EMPTY(cNatureza)

								BEGIN TRANSACTION 
								
								for n:=1 to len(aGerTit)
									/*------------------------------------------------------------|  Augusto Ribeiro - 11/02/2015
										GERA TITULO NO FINANCEIRO
									-------------------------------------------------------------------------------------------*/
									if aGerTit[n][1]
									
										aRetTit := u_GeraFin(ZA0->ZA0_CODFOR, ZA0->ZA0_LOJFOR, aGerTit[n][8], cNatureza, ZA5->ZA5_CONPAG)
									
										IF aRetTit[1]
											/*------------------------------------------------------------|  Augusto Ribeiro - 11/02/2015
												Grava tabela dos lotes de cobrança gerados							
											-------------------------------------------------------------------------------------------*/
											dbSelectArea("ZAD")
											ZAD->(dbSetOrder(2))

											if !ZAD->(dbSeek(xFilial("ZAD")+aGerTit[n][2]))
												
												RecLock("ZAD",.t.)
													Replace ZAD_CODIGO with GETSXENUM("ZAD","ZAD_CODIGO")
													Replace	ZAD->ZAD_CODDES with aGerTit[n][2]
													Replace	ZAD->ZAD_CODUSR with __cUserID
													Replace	ZAD->ZAD_FILTIT with SE2->E2_FILIAL
													Replace	ZAD->ZAD_PRETIT  with SE2->E2_PREFIXO
													Replace	ZAD->ZAD_NUMTIT with SE2->E2_NUM
													Replace	ZAD->ZAD_PARTIT with SE2->E2_PARCELA
													Replace	ZAD->ZAD_TIPTIT with SE2->E2_TIPO
													Replace	ZAD->ZAD_VENCTO with SE2->E2_VENCTO
													Replace	ZAD->ZAD_CODFOR with SE2->E2_FORNECE
													Replace	ZAD->ZAD_LOJFOR with SE2->E2_LOJA
												MsUnlock()

												ConfirmSX8()
												//	
												DBSELECTAREA("ZAF")
												ZAF->(DBSETORDER(1))
											
													//| Altera Status da Despesa
													IF ZAF->(DBSEEK(XFILIAL("ZAF")+ZAD->ZAD_CODDES))
														RecLock("ZAF", .F.)
															ZAF->ZAF_STATUS	:= ZAF_STATUS_PAGO
														MSUNLOCK()
													ELSE
														DISARMTRANSACTION()
														cMsgErro	:= "Despesa nao localizada. Codigo ["+ZAD->ZAD_CODDES+"]"
														lAbort	:= .T.
													ENDIF
											ELSE
													DISARMTRANSACTION()
													cMsgErro	:= "Falha na gravacao do lote de pagamento [ZAD]"
													lAbort	:= .T.
											ENDIF
										ELSE
											DISARMTRANSACTION()
											cMsgErro	:= "Falha na geração do titulo. "+aRetTit[2]
											Help(" ",1,"GRVDADOS",,cMsgErro,4,5)
											lRet	:= .F.
											lAbort	:= .T.
										ENDIF
									endIf
								next
									
								END TRANSACTION
								 
					    ELSE
							cMsgErro	:= "Natureza nao informada. Verifique a natureza amarrada ao produto ou parametro [NATUREZFIX] no configuradar de customização"
						ENDIF
						/**/
					ENDIF
				endif
			ENDIF
		ELSE
			FwHelpShow(,"VAZIO","Nenhum Item foi selecionado","Por favor selecione as despesas antes de acessar esta rotina.")
		ENDIF
	ENDIF
	If !empty(cMsgErro)
		FWAlertError(cMsgErro, "Erro na transação.")
	endIf
ENDIF


Return()



/*/{Protheus.doc} AjustSX1
Cria perguntas no SX1
@author Augusto Ribeiro | www.compila.com.br
@since 31/01/2015
@version 1.0
@param cPerg, C, nome da pergunta que será criada
/*/
Static Function AjustSX1(cPerg)

Local aArea := GetArea()
Local aHelpPor	:= {}
Local aHelpEng	:= {}
Local aHelpSpa	:= {}

aAdd( aHelpEng, "  ")
aAdd( aHelpSpa, "  ")

aHelpPor := {} ; Aadd( aHelpPor, "Informe o Código do usuário.")
xPutSx1( cPerg, "01","Usuário de:"	,"","","mv_ch1","C",6,0,0,"G","","ZA0","","","mv_par01","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa )

aHelpPor := {} ; Aadd( aHelpPor, "Informe o Código do usuário.")
xPutSx1( cPerg, "02","Usuário até"	,"","","mv_ch2","C",6,0,0,"G","NaoVazio","ZA0","","","mv_par02","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa )

aHelpPor := {} ; Aadd( aHelpPor, "Data Despesa De")
xPutSx1( cPerg, "03","Data Despesa De","","","mv_ch3","D",08,0,0,"G","","","","","mv_par03","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa )

aHelpPor := {} ; Aadd( aHelpPor, "Data Despesa Ate")
xPutSx1( cPerg, "04","Data Despesa Ate","","","mv_ch4","D",08,0,0,"G","","","","","mv_par04","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa )

Return()




/*/{Protheus.doc} xPutSX1
Ajusta Perguntas - SX1
@author Fabio Sales | www.compila.com.br
@since 05/11/2018
@version 1.0
/*/

Static Function xPutSX1(cGrupo,cOrdem,cPergunt,cPerSpa,cPerEng,cVar,;
	cTipo ,nTamanho,nDecimal,nPresel,cGSC,cValid,;
	cF3, cGrpSxg,cPyme,;
	cVar01,cDef01,cDefSpa1,cDefEng1,cCnt01,;
	cDef02,cDefSpa2,cDefEng2,;
	cDef03,cDefSpa3,cDefEng3,;
	cDef04,cDefSpa4,cDefEng4,;
	cDef05,cDefSpa5,cDefEng5,;
	aHelpPor,aHelpEng,aHelpSpa,cHelp, cPicture)

	Local aArea := GetArea()
	Local cKey
	Local lPort := .f.
	Local lSpa  := .f.
	Local lIngl := .f. 

	cKey  := "P." + AllTrim( cGrupo ) + AllTrim( cOrdem ) + "."

	cPyme    := Iif( cPyme           == Nil, " ", cPyme        )
	cF3      := Iif( cF3             == NIl, " ", cF3          )
	cGrpSxg  := Iif( cGrpSxg  == Nil, " ", cGrpSxg      )
	cCnt01   := Iif( cCnt01          == Nil, "" , cCnt01       )
	cHelp := Iif( cHelp            == Nil, "" , cHelp        )

	dbSelectArea( "SX1" )
	dbSetOrder( 1 )

	// Ajusta o tamanho do grupo. Ajuste emergencial para validaÃ§Ã£o dos fontes.
	// RFC - 15/03/2007
	cGrupo := PadR( cGrupo , Len( SX1->X1_GRUPO ) , " " )

	If !( DbSeek( cGrupo + cOrdem ))

		cPergunt	:= If(! "?" $ cPergunt .And. ! Empty(cPergunt),Alltrim(cPergunt)+" ?",cPergunt)
		cPerSpa		:= If(! "?" $ cPerSpa  .And. ! Empty(cPerSpa) ,Alltrim(cPerSpa) +" ?",cPerSpa)
		cPerEng		:= If(! "?" $ cPerEng  .And. ! Empty(cPerEng) ,Alltrim(cPerEng) +" ?",cPerEng)

		Reclock( "SX1" , .T. )

		Replace X1_GRUPO   With cGrupo
		Replace X1_ORDEM   With cOrdem
		Replace X1_PERGUNT With cPergunt
		Replace X1_PERSPA  With cPerSpa
		Replace X1_PERENG  With cPerEng
		Replace X1_VARIAVL With cVar
		Replace X1_TIPO    With cTipo
		Replace X1_TAMANHO With nTamanho
		Replace X1_DECIMAL With nDecimal
		Replace X1_PRESEL  With nPresel
		Replace X1_GSC     With cGSC
		Replace X1_VALID   With cValid

		Replace X1_VAR01   With cVar01

		Replace X1_F3      With cF3
		Replace X1_GRPSXG  With cGrpSxg

		If Fieldpos("X1_PYME") > 0
			If cPyme != Nil
				Replace X1_PYME With cPyme
			Endif
		Endif

		Replace X1_CNT01   With cCnt01

		If cGSC == "C"                   // Mult Escolha
			Replace X1_DEF01   With cDef01
			Replace X1_DEFSPA1 With cDefSpa1
			Replace X1_DEFENG1 With cDefEng1

			Replace X1_DEF02   With cDef02
			Replace X1_DEFSPA2 With cDefSpa2
			Replace X1_DEFENG2 With cDefEng2

			Replace X1_DEF03   With cDef03
			Replace X1_DEFSPA3 With cDefSpa3
			Replace X1_DEFENG3 With cDefEng3

			Replace X1_DEF04   With cDef04
			Replace X1_DEFSPA4 With cDefSpa4
			Replace X1_DEFENG4 With cDefEng4

			Replace X1_DEF05   With cDef05
			Replace X1_DEFSPA5 With cDefSpa5
			Replace X1_DEFENG5 With cDefEng5
		Endif

		Replace X1_HELP  With cHelp

		PutSX1Help(cKey,aHelpPor,aHelpEng,aHelpSpa)

		SX1->X1_PICTURE				:= cPicture

		MsUnlock()
	Else

		lPort := ! "?" $ X1_PERGUNT .And. ! Empty(SX1->X1_PERGUNT)
		lSpa  := ! "?" $ X1_PERSPA  .And. ! Empty(SX1->X1_PERSPA)
		lIngl := ! "?" $ X1_PERENG  .And. ! Empty(SX1->X1_PERENG)

		If lPort .Or. lSpa .Or. lIngl
			If lPort 
				SX1->X1_PERGUNT:= Alltrim(SX1->X1_PERGUNT)+" ?"
			EndIf

			If lSpa 
				SX1->X1_PERSPA := Alltrim(SX1->X1_PERSPA) +" ?"
			EndIf

			If lIngl
				SX1->X1_PERENG := Alltrim(SX1->X1_PERENG) +" ?"
			EndIf
			SX1->(MsUnLock())
		EndIf
	Endif
	
	

	RestArea( aArea )

Return


