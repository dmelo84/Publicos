#Include "Protheus.Ch"
#Include "rwmake.Ch"
#INCLUDE "TOPCONN.CH"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "FWMBROWSE.CH"
#INCLUDE 'TBICONN.CH'
#include 'parmtype.ch'
#INCLUDE "RPTDEF.CH"

//| TABELA
#DEFINE D_ALIAS 'Z05'
#DEFINE D_TITULO 'Programação de Visitas'
#DEFINE D_ROTINA 'ALVISIT'
#DEFINE D_MODEL 'Z05MODEL'
#DEFINE D_MODELMASTER 'Z05MASTER'
#DEFINE D_VIEWMASTER 'VIEW_Z05'


/*/{Protheus.doc} ALVISIT2
Programação de visitas
@author Jonatas Oliveira | www.compila.com.br
@since 30/04/2017
@version 1.0
/*/
User Function ALVISIT2()

	U_ALVISIT("Z05_CODVIS== __CUSERID")

	/*
	Local oBrowse

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias(D_ALIAS)
	oBrowse:SetDescription(D_TITULO)

	// Definição da legenda
	//1=Prevista;2=Programada;3=Finalizada
	oBrowse:AddLegend( "Z05_STATUS=='1'", "BR_VERDE"	, "Prevista" )
	oBrowse:AddLegend( "Z05_STATUS=='2'", "BR_AMARELO"	, "Programada" )
	oBrowse:AddLegend( "Z05_STATUS=='3'", "BR_VERMELHO"	, "Finalizada" )

	oBrowse:SetFilterDefault( "Z05_CODVIS== __CUSERID")

	oBrowse:DisableDetails()

	oBrowse:SetMenuDef("ALVISIT")

	oBrowse:Activate()
	*/
Return NIL

/*/{Protheus.doc} ALVISIT
Programação de visitas
@author Jonatas Oliveira | www.compila.com.br
@since 30/04/2017
@version 1.0
/*/
User Function ALVISIT(_cFiltro)
	Local oBrowse
	Private lVisitad	:= .F.
	
	Private c_CODCLI		:= ""
Private c_LOJACLI		:= ""

Private _LCOPIA		:= .F.
Private aUserAccess := {}  
Private lTeste

Private aDadoMain	:= {}



//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta List Solicitacao de Compras ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ 
Private aHeadTit	:= {}   
Private AHEADTOT	:= {}       

Private aDadoTit	:= {}
Private ADADOTOT	:= {}
Private aDadosLbx	:= {}   

Private oLbxTit		:= Nil
Private OLBXTOT		:= Nil

Private aCpoTit		:= {}

Private nColAnt		:= 0

Private nPosVlrc		:= 0
Private nPVlrMul		:= 0
Private nPVlrJur		:= 0
Private nRecnoE1		:= 0
Private nPosSald		:= 0
Private nPosVenc		:= 0  
Private nPosFil			:= 0 
Private nPosPref		:= 0 
Private nPosNum			:= 0 
Private nPosNFe			:= 0 
Private nPosNat			:= 0 
Private nPosEmis		:= 0   
Private nPosVlAc		:= 0 
Private nPosVlDe		:= 0
Private nPosParc		:= 0
Private nPosTipo		:= 0
Private nPosPort		:= 0
Private nPosBanc		:= 0 	 



Private lMarkAll		:= .F.

Private oTotal		:= NIL
Private oTotSel		:= NIL
Private oTotalP		:= NIL
Private oTotSelP	:= NIL
	
	IF !EMPTY(_cFiltro)
		lVisitad	:= .T.
	ENDIF

	oBrowse := FWMBrowse():New()
	oBrowse:SetAlias(D_ALIAS)
	oBrowse:SetDescription(D_TITULO)

	// Definição da legenda
	//1=Prevista;2=Programada;3=Finalizada
	oBrowse:AddLegend( "Z05_STATUS=='1'", "BR_VERDE"	, "Prevista" )
	oBrowse:AddLegend( "Z05_STATUS=='2'", "BR_AMARELO"	, "Programada" )
	oBrowse:AddLegend( "Z05_STATUS=='3'", "BR_VERMELHO"	, "Finalizada" )

	IF !EMPTY(_cFiltro)
		//_cFiltro := "ZMF_STATUS=='+_cFiltro+' "

		oBrowse:SetFilterDefault( _cFiltro)
	ENDIF

	oBrowse:SetMenuDef("ALVISIT")

	oBrowse:DisableDetails()

	oBrowse:Activate()

Return NIL

/*/{Protheus.doc} MenuDef
Botoes do MBrowser
@author Jonatas Oliveira | www.compila.com.br
@since 30/04/2017
@version 1.0
/*/
Static Function MenuDef()
	Local aRotina := {}

	//ADD OPTION aRotina TITLE 'Pesquisar'  			ACTION 'PesqBrw'           	OPERATION 1 ACCESS 0
	ADD OPTION aRotina TITLE 'Pesquisar'  			ACTION 'PesqBrw'           	OPERATION 1 ACCESS 0
	ADD OPTION aRotina TITLE 'Visualizar' 			ACTION 'VIEWDEF.'+D_ROTINA 	OPERATION 2 ACCESS 0
	ADD OPTION aRotina TITLE 'Incluir'    			ACTION 'VIEWDEF.'+D_ROTINA 	OPERATION 3 ACCESS 0
	//ADD OPTION aRotina TITLE 'Alterar'    			ACTION 'VIEWDEF.'+D_ROTINA 	OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE 'Alterar'    			ACTION 'U_ALVISAL()' 		OPERATION 4 ACCESS 0
	ADD OPTION aRotina TITLE 'Excluir'    			ACTION 'U_ALVISEX()' 		OPERATION 5 ACCESS 0
	ADD OPTION aRotina TITLE 'Fechar Roteiro'   	ACTION 'Processa({|| U_ALVISRT()},"Fechando Roteiro")' 		OPERATION 6 ACCESS 0	
	ADD OPTION aRotina TITLE 'Imprimir'   			ACTION 'VIEWDEF.'+D_ROTINA 	OPERATION 8 ACCESS 0
Return aRotina

/*/{Protheus.doc} ModelDef
Definicoes do Model
@author Jonatas Oliveira | www.compila.com.br
@since 30/04/2017
@version 1.0
/*/
Static Function ModelDef()
	// Cria a estrutura a ser usada no Modelo de Dados
	Local oStruZ05 := FWFormStruct( 1, D_ALIAS, /*bAvalCampo*/,/*lViewUsado*/ )
//	Local oStruZ52 := FWFormStruct( 1, D_ALIAS, /*bAvalCampo*/,/*lViewUsado*/ )
	Local oModel

	// Cria o objeto do Modelo de Dados
	oModel := MPFormModel():New(D_MODELMASTER, /*bPreValidacao*/, /*bPosValidacao*/,  /*bCommit*/ , /*bCancel*/ )

	// Adiciona ao modelo uma estrutura de formulário de edição por campo
	oModel:AddFields( D_MODELMASTER, /*cOwner*/, oStruZ05, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
//	oModel:AddGrid( 'Z05ITEM', D_MODELMASTER, oStruZ52, /*bPreValidacao*/,{||.T.}, /*bPreVal*/,	{||.T.}, /*BLoad*/ )

	// Faz relaciomaneto entre os compomentes do model
//	oModel:SetRelation( 'Z05ITEM', {{ 'Z05_CODVIS', 'Z05_CODVIS' } }, Z05->(IndexKey(2)) )//'Z01_FILIAL+Z01_CODIGO+Z01_ITEM'

	// Liga o controle de nao repeticao de linha
	//oModel:GetModel( 'ZG7DETAIL' ):SetUniqueLine( { 'ZG7_CHAVE' } )

	// Indica que é opcional ter dados informados na Grid
//	oModel:GetModel( 'Z05ITEM' ):SetOptional(.T.)

	// Adiciona a descricao do Modelo de Dados
	oModel:SetDescription( D_TITULO )

//	oModel:GetModel( 'Z05ITEM' ):SetOnlyQuery ( .T. )


Return oModel

/*/{Protheus.doc} ViewDef
Definicoes da View
@author Jonatas Oliveira | www.compila.com.br
@since  30/04/2017
@version 1.0
/*/
Static Function ViewDef()
	// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
	Local oModel   := FWLoadModel( D_ROTINA )
	// Cria a estrutura a ser usada na View
	Local oStruZ05 := FWFormStruct( 2, D_ALIAS )
//	Local oStruZ52 := FWFormStruct( 2, D_ALIAS )

	Local nOperation := oModel:GetOperation()
	Local oView, cOrdemCpo, nI
	Local aCpoView 	:= {}

	// Cria o objeto de View
	oView := FWFormView():New()

	// Define qual o Modelo de dados será utilizado
	oView:SetModel( oModel )

	//aadd(aCpoView, 'Z05_CODIGO')
	//aadd(aCpoView, 'Z05_DTREG')
	//aadd(aCpoView, 'Z05_CODVIS')
	//aadd(aCpoView, 'Z05_USUAR')
	aadd(aCpoView, 'Z05_DTPREV')
	aadd(aCpoView, 'Z05_HRPREV')
	aadd(aCpoView, 'Z05_HRFIMP')
	aadd(aCpoView, 'Z05_STATUS')
	aadd(aCpoView, 'Z05_NOME')
	aadd(aCpoView, 'Z05_ESPECI')
	aadd(aCpoView, 'Z05_EMAIL')
	aadd(aCpoView, 'Z05_ENDER')
	aadd(aCpoView, 'Z05_DTIN')
	aadd(aCpoView, 'Z05_HRIN')
	aadd(aCpoView, 'Z05_DTFIM')
	aadd(aCpoView, 'Z05_HRFIM')
	
//	dbselectarea("Z05")
//	aCpoZ05	:= aClone(oStruZ52:aFields)
//	FOR nI := 1 to LEN(aCpoZ05)
//		IF ascan(aCpoView, alltrim(aCpoZ05[nI,1])) <= 0 // .and.
//			oStruZ52:RemoveField(aCpoZ05[nI,1])
//		ENDIF
//	NEXT nI
//
//	cOrdemCpo	:= "00"
//	FOR nI := 1 to LEN(aCpoView)
//		cOrdemCpo	:= SOMA1(cOrdemCpo)
//		oStruZ52:SetProperty( aCpoView[nI] , 	MVC_VIEW_ORDEM  , cOrdemCpo)
//	NEXT nI



	//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
	oView:AddField( D_VIEWMASTER, oStruZ05, D_MODELMASTER )
//	oView:AddGrid( 'OTHER_PANEL', oStruZ52, 'Z05ITEM' )
	oView:AddOtherObject("OTHER_PANEL"	, {|oPanel| U_ALVISLIS("C",@oLbxTit,@aCpoTit,@aHeadTit, @aDadoTit, oPanel, nOperation)  })

	// Criar um "box" horizontal para receber algum elemento da view
	oView:CreateVerticalBox( 'ESQUERDA' , 60 )
	oView:CreateVerticalBox( 'DIREITA' 	, 40 )

	// Relaciona o ID da View com o "box" para exibicao
	oView:SetOwnerView( D_VIEWMASTER, 'ESQUERDA' )
	oView:SetOwnerView( 'OTHER_PANEL'	, 'DIREITA' )
	
	oPanel := NIL 

	/*--------------------------
		Campos grid
	---------------------------*/
//	oStruZ52:SetProperty( '*'				, MVC_VIEW_CANCHANGE  , .F. )
	
	
	

	oStruZ05:SetProperty( '*'				, MVC_VIEW_CANCHANGE  , .F. )
	
	oStruZ05:SetProperty(  'Z05_DTPREV'	,  MVC_VIEW_CANCHANGE  , .T. )
	//oStruZ05:SetProperty(  'Z05_VISITA'	,  MVC_VIEW_CANCHANGE  , .T. )
	IF !lVisitad
		oStruZ05:SetProperty(  'Z05_CODVIS'	,  MVC_VIEW_CANCHANGE  , .T. )
	ENDIF 	
	oStruZ05:SetProperty(  'Z05_HRPREV'	,  MVC_VIEW_CANCHANGE  , .T. )
	oStruZ05:SetProperty(  'Z05_HRFIMP'	,  MVC_VIEW_CANCHANGE  , .T. )

	oStruZ05:SetProperty(  'Z05_CODMED'	,  MVC_VIEW_CANCHANGE  , .T. )
	oStruZ05:SetProperty(  'Z05_LOJAME'	,  MVC_VIEW_CANCHANGE  , .T. )
	/*
	oStruZ05:SetProperty(  'Z05_CRM'	,  MVC_VIEW_CANCHANGE  , .T. )
	oStruZ05:SetProperty(  'Z05_UFCRM'	,  MVC_VIEW_CANCHANGE  , .T. )
	oStruZ05:SetProperty(  'Z05_SEGMEN'	,  MVC_VIEW_CANCHANGE  , .T. )
	oStruZ05:SetProperty(  'Z05_NOME'	,  MVC_VIEW_CANCHANGE  , .T. )
	oStruZ05:SetProperty(  'Z05_ESPECI'	,  MVC_VIEW_CANCHANGE  , .T. )
	oStruZ05:SetProperty(  'Z05_EMAIL'	,  MVC_VIEW_CANCHANGE  , .T. )
	*/
	oStruZ05:SetProperty(  'Z05_ENDER'	,  MVC_VIEW_CANCHANGE  , .T. )
	oStruZ05:SetProperty(  'Z05_BAIRRO'	,  MVC_VIEW_CANCHANGE  , .T. )
	oStruZ05:SetProperty(  'Z05_MUNIC'	,  MVC_VIEW_CANCHANGE  , .T. )
	oStruZ05:SetProperty(  'Z05_UF'		,  MVC_VIEW_CANCHANGE  , .T. )
	oStruZ05:SetProperty(  'Z05_CEP'	,  MVC_VIEW_CANCHANGE  , .T. )
	oStruZ05:SetProperty(  'Z05_COMPL'	,  MVC_VIEW_CANCHANGE  , .T. )

	//|Gatilhos
	oView:SetFieldAction(  'Z05_DTPREV'	,  {  |oView,  cIDView,  cField,  xValue|  GITECTR(  oView,  cIDView, cField, xValue ) } )
//	oView:SetFieldAction(  'Z05_VISITA'	,  {  |oView,  cIDView,  cField,  xValue|  GITECTR(  oView,  cIDView, cField, xValue ) } )

	oView:SetFieldAction(  'Z05_CODMED'	,  {  |oView,  cIDView,  cField,  xValue|  GITECTR(  oView,  cIDView, cField, xValue ) } )
	oView:SetFieldAction(  'Z05_LOJAME'	,  {  |oView,  cIDView,  cField,  xValue|  GITECTR(  oView,  cIDView, cField, xValue ) } )
	oView:SetFieldAction(  'Z05_CODVIS'	,  {  |oView,  cIDView,  cField,  xValue|  GITECTR(  oView,  cIDView, cField, xValue ) } )

	//|Grupos
	oStruZ05:AddGroup( 'GRUPO01', 'Dados da Visita - Previsto'	, '', 1 )
	oStruZ05:AddGroup( 'GRUPO02', 'Médico' 						, '', 2 )
	oStruZ05:AddGroup( 'GRUPO03', 'Dados da Visita - Realizado'	, '', 3 )
	oStruZ05:AddGroup( 'GRUPO04', 'Detalhamento da Visita'		, '', 4 )

	oStruZ05:SetProperty( 'Z05_CODIGO'	, MVC_VIEW_GROUP_NUMBER, 'GRUPO01' )
	oStruZ05:SetProperty( 'Z05_DTREG'	, MVC_VIEW_GROUP_NUMBER, 'GRUPO01' )
	oStruZ05:SetProperty( 'Z05_USUAR'	, MVC_VIEW_GROUP_NUMBER, 'GRUPO01' )
	oStruZ05:SetProperty( 'Z05_CODVIS'	, MVC_VIEW_GROUP_NUMBER, 'GRUPO01' )
	//oStruZ05:SetProperty( 'Z05_NOMEVI'	, MVC_VIEW_GROUP_NUMBER, 'GRUPO01' )
	oStruZ05:SetProperty( 'Z05_VISITA'	, MVC_VIEW_GROUP_NUMBER, 'GRUPO01' )
	oStruZ05:SetProperty( 'Z05_DTPREV'	, MVC_VIEW_GROUP_NUMBER, 'GRUPO01' )
	oStruZ05:SetProperty( 'Z05_HRPREV'	, MVC_VIEW_GROUP_NUMBER, 'GRUPO01' )
	oStruZ05:SetProperty( 'Z05_HRFIMP'	, MVC_VIEW_GROUP_NUMBER, 'GRUPO01' )
	oStruZ05:SetProperty( 'Z05_STATUS'	, MVC_VIEW_GROUP_NUMBER, 'GRUPO01' )

	oStruZ05:SetProperty( 'Z05_CODMED'	, MVC_VIEW_GROUP_NUMBER, 'GRUPO02' )
	oStruZ05:SetProperty( 'Z05_LOJAME'  , MVC_VIEW_GROUP_NUMBER, 'GRUPO02' )
	oStruZ05:SetProperty( 'Z05_CRM'		, MVC_VIEW_GROUP_NUMBER, 'GRUPO02' ) 
	oStruZ05:SetProperty( 'Z05_UFCRM'   , MVC_VIEW_GROUP_NUMBER, 'GRUPO02' )
	oStruZ05:SetProperty( 'Z05_SEGMEN'  , MVC_VIEW_GROUP_NUMBER, 'GRUPO02' )
	oStruZ05:SetProperty( 'Z05_NOME'    , MVC_VIEW_GROUP_NUMBER, 'GRUPO02' )
	oStruZ05:SetProperty( 'Z05_ESPECI'  , MVC_VIEW_GROUP_NUMBER, 'GRUPO02' )
	oStruZ05:SetProperty( 'Z05_EMAIL'   , MVC_VIEW_GROUP_NUMBER, 'GRUPO02' )
	oStruZ05:SetProperty( 'Z05_ENDER'   , MVC_VIEW_GROUP_NUMBER, 'GRUPO02' )
	oStruZ05:SetProperty( 'Z05_BAIRRO'  , MVC_VIEW_GROUP_NUMBER, 'GRUPO02' )
	oStruZ05:SetProperty( 'Z05_MUNIC'   , MVC_VIEW_GROUP_NUMBER, 'GRUPO02' )
	oStruZ05:SetProperty( 'Z05_UF'      , MVC_VIEW_GROUP_NUMBER, 'GRUPO02' )
	oStruZ05:SetProperty( 'Z05_CEP'     , MVC_VIEW_GROUP_NUMBER, 'GRUPO02' )
	oStruZ05:SetProperty( 'Z05_COMPL'   , MVC_VIEW_GROUP_NUMBER, 'GRUPO02' )

	oStruZ05:SetProperty( 'Z05_DTIN'	, MVC_VIEW_GROUP_NUMBER, 'GRUPO03' )
	oStruZ05:SetProperty( 'Z05_HRIN'    , MVC_VIEW_GROUP_NUMBER, 'GRUPO03' )
	oStruZ05:SetProperty( 'Z05_LATIIN'  , MVC_VIEW_GROUP_NUMBER, 'GRUPO03' )
	oStruZ05:SetProperty( 'Z05_LONGIN'  , MVC_VIEW_GROUP_NUMBER, 'GRUPO03' )
	oStruZ05:SetProperty( 'Z05_ENDIN'   , MVC_VIEW_GROUP_NUMBER, 'GRUPO03' )
	
	oStruZ05:SetProperty( 'Z05_DTFIM'   , MVC_VIEW_GROUP_NUMBER, 'GRUPO03' )
	oStruZ05:SetProperty( 'Z05_HRFIM'   , MVC_VIEW_GROUP_NUMBER, 'GRUPO03' )
	oStruZ05:SetProperty( 'Z05_LATIFI'  , MVC_VIEW_GROUP_NUMBER, 'GRUPO03' )
	oStruZ05:SetProperty( 'Z05_LONGFI'  , MVC_VIEW_GROUP_NUMBER, 'GRUPO03' )
	oStruZ05:SetProperty( 'Z05_ENDFI'   , MVC_VIEW_GROUP_NUMBER, 'GRUPO03' )

	oStruZ05:SetProperty( 'Z05_REUNIA'	, MVC_VIEW_GROUP_NUMBER, 'GRUPO04' )
	oStruZ05:SetProperty( 'Z05_REUMED'  , MVC_VIEW_GROUP_NUMBER, 'GRUPO04' )
	oStruZ05:SetProperty( 'Z05_REUSEC'  , MVC_VIEW_GROUP_NUMBER, 'GRUPO04' )
	oStruZ05:SetProperty( 'Z05_FEEDB'   , MVC_VIEW_GROUP_NUMBER, 'GRUPO04' )
	oStruZ05:SetProperty( 'Z05_DETALH'  , MVC_VIEW_GROUP_NUMBER, 'GRUPO04' )
	oStruZ05:SetProperty( 'Z05_IDFLUI'  , MVC_VIEW_GROUP_NUMBER, 'GRUPO04' )
	oStruZ05:SetProperty( 'Z05_CLINIC'  , MVC_VIEW_GROUP_NUMBER, 'GRUPO04' )

	oView:EnableTitleView('OTHER_PANEL','Programação Visitas do Mês')

	oView:SetCloseOnOk({||.T.})

Return oView


/*/{Protheus.doc} GITECTR
Preenche demais campos como Gatilho via SetFieldAction
@author Jonatas Oliveira | www.compila.com.br
@since 30/04/2017
@version 1.0
/*/
Static Function GITECTR( oView,  cIDView, cField, xValue)
	Local lOk		:= .F.
	Local oModFull 	:= oView:GetModel()
	Local oModItem 	:= oModFull:GetModel('OTHER_PANEL')
	Local oModZ05 	:= oModFull:GetModel('Z05MASTER')
	Local cMsgAviso
	Local nY		:= 0
	Local nTotLen	:= 0
	Local nI 		:= 0
	Local aColsEmp	:= {}
	Local _aRecnoSe1:= {}
	Local nLinAdd	:= 0
	Local nTotRec 	:= 0
	Local nTotBaix	:= 0
	Local nSaldoBx	:= 0 
	Local nZA2Mod		:= 0

	Local nSaldo 	:= 0 
	Local nAbatim 	:= 0 
	Local nVistDia	:= 0 
	Local nMinVisit	:= GetMv("CMP_VISIT",.F.,7)
	Local cUserAux	:= ""
	Local aAreaZ05	:= {}
	Local dDtIni 
	Local dDtFim

	IF ALLTRIM(cField) == "Z05_DTPREV" .OR. ALLTRIM(cField) == "Z05_CODVIS"
		
		oPanel := NIL 
		
		DBSELECTAREA("Z05")
		aAreaZ05	:= Z05->(GETAREA())
		
		IF !EMPTY(oModZ05:GetValue("Z05_DTPREV")) .AND. !EMPTY(oModZ05:GetValue("Z05_CODVIS")) // .AND. Z05->(DBSEEK(oModZ05:GetValue("Z05_VISITA")))			
			U_ALVISLIS("A",@oLbxTit,@aCpoTit,@aHeadTit, @aDadoTit,oPanel , 1 ,oModZ05:GetValue("Z05_CODVIS"),  oModZ05:GetValue("Z05_DTPREV"))			
		ENDIF 
		
		RestArea(aAreaZ05)
	ENDIF


	IF ALLTRIM(cField) == "Z05_CODMED" .OR. ALLTRIM(cField) == "Z05_LOJAME"
		DBSELECTAREA("ACH")
		ACH->(DBSETORDER(1))//|ACH_FILIAL+ACH_CODIGO+ACH_LOJA|
		IF ACH->(DBSEEK(XFILIAL("ACH") + oModZ05:GetValue("Z05_CODMED") + oModZ05:GetValue("Z05_LOJAME") )) 

			oModZ05:SetValue("Z05_CRM"		,   ACH->ACH_XCRM  )
			oModZ05:SetValue("Z05_UFCRM"	, 	ACH->ACH_XCRMUF)
			oModZ05:SetValue("Z05_SEGMEN"	, 	POSICIONE("AOV",1, XFILIAL("AOV") + ACH->ACH_CODSEG ,"AOV_DESSEG"))
			oModZ05:SetValue("Z05_NOME"		,   ACH->ACH_RAZAO )
			oModZ05:SetValue("Z05_ESPECI"	, 	ACH->ACH_XESP01)
			oModZ05:SetValue("Z05_EMAIL"	,  	ACH->ACH_EMAIL )
			oModZ05:SetValue("Z05_ENDER"	,  	ACH->ACH_END   )
			oModZ05:SetValue("Z05_BAIRRO"	, 	ACH->ACH_BAIRRO)
			oModZ05:SetValue("Z05_MUNIC"	,  	ACH->ACH_CIDADE)
			oModZ05:SetValue("Z05_UF"		,   ACH->ACH_EST   )
			oModZ05:SetValue("Z05_CEP"		,   ACH->ACH_CEP   )
			oModZ05:SetValue("Z05_COMPL"	,  	ACH->ACH_XCOMPL)
			
			IF EMPTY(ACH->ACH_XCLINI)
				oModZ05:SetValue("Z05_CLINIC"	,  	"2")
			ELSE
				oModZ05:SetValue("Z05_CLINIC"	,  	ACH->ACH_XCLINI)
			ENDIF 	

		ENDIF 

	ENDIF 

	IF ALLTRIM(cField) == "Z05_CODVIS" 
		cUserAux 	:= __CUSERID 
		__CUSERID 	:=  oModZ05:GetValue("Z05_CODVIS")

		//oModItem:SetValue("Z05_VISITA"	, ALLTRIM(CUSERNAME))
		oModZ05:SetValue("Z05_VISITA"	, Alltrim(UsrFullName(__CUsErid)) )

		__CUSERID	:= cUserAux

	ENDIF 

//	oModItem:GoLine(1)

	oView:Refresh()

Return NIL


/*/{Protheus.doc} ALVISRT
Realiza o fechamento de roteiro do periodo Informado
@author Jonatas Oliveira | www.compila.com.br
@since 24/05/2017
@version 1.0
/*/
User Function ALVISRT()
	Local dDtFech	:= CTOD("  /  /  ")
	Local dDtFech2	:= CTOD("  /  /  ")
	Local cVisita	:= ""
	Local BOK		:= {|| (.T.)}
	Local aParamBox := {}

	Local cQuery	:= ""
	Local cQuery2	:= ""
	Local dDatAux	:= CTOD("  /  /  ")

	Local nMinVisit	:= GetMv("CMP_VISIT",.F.,7)
	Local lContinua	:= .T.
	Local nPosFim	:= 0 

	Local cUserFluig	:= ""//"wup8xo28mbi97c6z1486642982794"//"pi95ivdr2izqc7xk1486642915182"
	Local nTaskDest		:= 10 
	Local cComments		:= "teste"
	Local lComplete		:= .T.
	Local lManager		:= .F.
	Local aCardData		:= {}
	Local aRetFluig		:= {}
	Local aRetProc		:= {}
	Local cMailVis		:= ""
	Local lMenosVis		:= .f.

	Local cloginF		:=  ""//"diego.humberto.compila.com.br.1" //Retorno WS posição 3
	Local cIDProc		:= 	"Registro Presencial de Visita"

	Private aRParam		:= {}

	aAdd(aParamBox,{1,"Data De "  	,Ctod(Space(8))	,"","NAOVAZIO()"	,""		,""	,50	,.F.})
	aAdd(aParamBox,{1,"Data Até "  	,Ctod(Space(8))	,"","NAOVAZIO()"	,""		,""	,50	,.F.})
	IF lVisitad
		aAdd(aParamBox,{1,"Visitante"	,__CUSERID		,"","NAOVAZIO()"	,"Z03"	,".F."	,0	,.F.})
	ELSE
		aAdd(aParamBox,{1,"Visitante"	,Space(6)		,"","NAOVAZIO()"	,"Z03"	,""	,0	,.F.})
	ENDIF

	If ParamBox(aParamBox,"Informe os Dados abaixo",@aRParam)
		dDtFech 	:= aRParam[01]
		dDtFech2 	:= aRParam[02]
		cVisita		:= aRParam[03]
	Endif

	cQuery += " SELECT R_E_C_N_O_ AS RECZ05 "
	cQuery += " FROM "+Retsqlname("Z05")+" "
	cQuery += " WHERE D_E_L_E_T_ = '' "
	cQuery += " 	AND Z05_DTPREV BETWEEN '"+ DTOS(dDtFech) +"' AND '"+ DTOS(dDtFech2) +"' "
	cQuery += " 	AND Z05_CODVIS = '"+ ALLTRIM(cVisita) +"' "
	cQuery += " 	AND Z05_STATUS = '1' "

	If Select("QRYEXC") > 0
		QRYEXC->(DbCloseArea())
	EndIf

	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),'QRYEXC')

	IF QRYEXC->(!EOF())
		DBSELECTAREA("Z05")

		cQuery2 += " SELECT Z05_DTPREV , COUNT(*) AS QTDVIST "
		cQuery2 += " FROM "+Retsqlname("Z05")+" "
		cQuery2 += " WHERE D_E_L_E_T_ = ''  "
		cQuery2 += " 	AND Z05_DTPREV BETWEEN '"+ DTOS(dDtFech) +"' AND '"+ DTOS(dDtFech2) +"' "
		cQuery2 += " 	AND Z05_CODVIS = '"+ ALLTRIM(cVisita) +"'  "
		cQuery2 += " GROUP BY Z05_DTPREV "
		cQuery2 += " HAVING COUNT(*) < 5 "

		If Select("QRYVST") > 0
			QRYVST->(DbCloseArea())
		EndIf

		dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery2),'QRYVST')

		IF QRYVST->(!EOF())
			lMenosVis := .T.

			cMenVisit := "Ainda não atingiu o agendamento minimo de visitas no(s) dia(s) "+CRLF

			WHILE QRYVST->(!EOF())
				cMenVisit	+= DTOC(STOD(QRYVST->Z05_DTPREV)) + " " + ALLTRIM(STR(QRYVST->QTDVIST)) + " de " + ALLTRIM(STR(nMinVisit)) + " ." +CRLF

				QRYVST->(DBSKIP())
			ENDDO

		ENDIF 

		IF lMenosVis
			nPosFim := AVISO("Qtde. Visitas", cMenVisit + " Deseja Continuar ? ",{"SIM","NÃO"}, 2)
		ELSE
			nPosFim := 1
		ENDIF 

		IF nPosFim == 1

			DBSELECTAREA("ACH")
			ACH->(DBSETORDER(1))//|ACH_FILIAL+ACH_CODIGO+ACH_LOJA |

			WHILE QRYEXC->(!EOF())

				Z05->(DBGOTO(QRYEXC->RECZ05))


				//oModFull 	:= oObj:GetModel()
				//oModZ05 	:= oModFull:GetModel('Z05MASTER')
				cMailVis		:= ALLTRIM(UsrRetMail(cVisita)) 
				aRetFluig		:= U_cpIdFlg(cMailVis)	

				cUserFluig	:= aRetFluig[3][1] //"wup8xo28mbi97c6z1486642982794"//"pi95ivdr2izqc7xk1486642915182"
				nTaskDest	:= 10 
				cComments	:= "teste"
				lComplete	:= .T.
				lManager	:= .F.
				aCardData	:= {}

				IF !EMPTY(cUserFluig)

					//oModZ05:GetValue("Z05_EMAIL")

					ACH->(DBSEEK(XFILIAL("ACH") + Z05->(Z05_CODMED + Z05_LOJAME) ))

					Aadd(aCardData, {"colleagueID"				,  aRetFluig[3][1]    	})
					Aadd(aCardData, {"login"                    ,  aRetFluig[3][2]    	})
					Aadd(aCardData, {"id_dtVisita"              ,  Z05->Z05_DTPREV		})
					Aadd(aCardData, {"id_dtregistro"            ,  DTOC(DDATABASE)    	})
					Aadd(aCardData, {"id_inicio"                ,  Z05->Z05_HRPREV   	})
					Aadd(aCardData, {"id_fim"                   ,  Z05->Z05_HRFIMP   	})
					Aadd(aCardData, {"txtCrm"              	 	,  ACH->ACH_XCRM   		})
					Aadd(aCardData, {"id_crmZoom"               ,  ACH->ACH_XCRM   		})
					Aadd(aCardData, {"txt_crmUF"                ,  ACH->ACH_XCRMUF    	})
					Aadd(aCardData, {"txt_segmento"             ,  ACH->ACH_XESP01   	})
					Aadd(aCardData, {"txt_nomeMedico"           ,  ACH->ACH_RAZAO    	})
					Aadd(aCardData, {"txt_enderecoMedico"       ,  Z05->Z05_ENDER   	})
					Aadd(aCardData, {"txt_bairroMedico"         ,  Z05->Z05_BAIRRO   	})
					Aadd(aCardData, {"txt_municipioMedico"      ,  Z05->Z05_MUNIC    	})
					Aadd(aCardData, {"txt_ufMedico"             ,  Z05->Z05_UF    		})
					Aadd(aCardData, {"txt_cepMedico"            ,  Z05->Z05_CEP   		})					
					Aadd(aCardData, {"txt_ddd"            		,  ACH->ACH_DDD   		})
					Aadd(aCardData, {"txt_tel"	            	,  ACH->ACH_TEL   		})					
					Aadd(aCardData, {"txt_complementoMedico"    ,  Z05->Z05_COMPL 		})
					Aadd(aCardData, {"txt_emailMedico"    		,  ACH->ACH_EMAIL 		})
					Aadd(aCardData, {"txt_nomeUsuario"          ,  aRetFluig[3][2]    	})
					Aadd(aCardData, {"colleagueName"            ,  aRetFluig[3][2]    	})
					Aadd(aCardData, {"txt_clinicaMedico"        ,  Z05->Z05_CLINIC    	})
					Aadd(aCardData, {"txt_clinicaCheckOut"      ,  Z05->Z05_CLINIC    	})

					aRetProc := u_cpVisit(cIDProc, cUserFluig, nTaskDest, cComments, lComplete, lManager, aCardData)

					IF aRetProc[1] .AND. !EMPTY(aRetProc[3])
						Z05->(RecLock("Z05",.F.))
						Z05->Z05_STATUS := "2"
						Z05->Z05_IDFLUI := aRetProc[3]
						Z05->(MsUnLock())

					ELSE
						Help(" ",1,"ALVISIT",,"Falha na integração com o Fluig. " + ALLTRIM(aRetProc[2]) ,4,5)
						xRet := .F.
					ENDIF 

				ELSE
					Help(" ",1,"ALVISIT",,"Falha na integração com o Fluig. Visitador(a) não localizado no Fluig" ,4,5)
					xRet := .F.
				ENDIF 

				QRYEXC->(DBSKIP())

			ENDDO
		ELSE	
			Help(" ",1,"Fech de Roteiro",,"Abortado pelo Usuário." ,4,5)
		ENDIF 
	ELSE
		Help(" ",1,"Fech de Roteiro",,"Não existem roteiros à serem fechados conforme os parametros informados" ,4,5)

	ENDIF 

Return()


/*/{Protheus.doc} ALVISAL
Alteração de visita 
@author Jonatas Oliveira | www.compila.com.br
@since 24/05/2017
@version 1.0
/*/
User Function ALVISAL()

	IF Z05->Z05_STATUS != "1" 
		AVISO("ATENCAO","Não foi possivel Alterar. Status " + X3COMBO("Z05_STATUS",Z05->Z05_STATUS),{"Fechar"}, 2)		
	ELSE
		FWExecView('Alteração',D_ROTINA,  MODEL_OPERATION_UPDATE,,  {|| .T. } )
	ENDIF  

Return()

/*/{Protheus.doc} ALVISEX
Exclusão de visita
@author Jonatas Oliveira | www.compila.com.br
@since 09/05/2018
@version 1.0
/*/
User Function ALVISEX()

	IF Z05->Z05_STATUS != "1" 
		AVISO("ATENCAO","Não foi possivel Excluir. Status " + X3COMBO("Z05_STATUS",Z05->Z05_STATUS),{"Fechar"}, 2)		
	ELSE
		FWExecView('Alteração',D_ROTINA,  MODEL_OPERATION_DELETE,,  {|| .T. } )
	ENDIF  

Return()

/*/{Protheus.doc} Z05MASTER
Pontos de entrada da rotina 
@author Jonatas Oliveira | www.compila.com.br
@since 26/05/2017
@version 1.0
/*/
User Function Z05MASTER()
	Local aParam := PARAMIXB
	Local xRet := .T.
	Local oObj := ''
	Local cIdPonto := ''
	Local cIdModel := ''
	Local lIsGrid := .F.
	Local nLinha := 0
	Local nQtdLinhas := 0
	Local cMsg := ''

	Local oModFull 	
	Local oModZ05

	Local cUserFluig	:= ""//"wup8xo28mbi97c6z1486642982794"//"pi95ivdr2izqc7xk1486642915182"
	Local nTaskDest		:= 10 
	Local cComments		:= "teste"
	Local lComplete		:= .T.
	Local lManager		:= .F.
	Local aCardData		:= {}
	Local aRetFluig		:= {}
	Local aRetProc		:= {}
	Local cMailVis		:= ALLTRIM(UsrRetMail(__CUSERID))

	Local cloginF		:=  ""//"diego.humberto.compila.com.br.1" //Retorno WS posição 3
	Local cIDProc		:= 	"RegistroPresencialdeVisita"
	Local cMsgHlp		:= ""
	Local cQuery 		:= ""
	Local nOperation 	:= 0
	Local lContinua		:= .F.

	If aParam <> NIL

		oObj := aParam[1]
		cIdPonto := aParam[2]
		cIdModel := aParam[3]
		lIsGrid := ( Len( aParam ) > 3 )

		If cIdPonto == 'MODELCOMMITNTTS'
			//ApMsgInfo('Chamada apos a gravação total do modelo e fora da transação (MODELCOMMITNTTS).' + CRLF + 'ID ' + cIdModel)

		ElseIf cIdPonto == 'MODELCANCEL'
			//ApMsgInfo('Chamada no botao cancelar (MODELCANCEL).' + CRLF + 'ID ' + cIdModel)
		ElseIf cIdPonto == "MODELPOS"

			oModFull 	:= oObj:GetModel()
			oModZ05 	:= oModFull:GetModel('Z05MASTER')

			nOperation 	:= oModFull:GetOperation()
			
			IF !EMPTY(oModZ05:GetValue("Z05_CODVIS"))
				
				IF nOperation == 3//|Inclusão|
					IF FUNNAME() <> "RPC"
						IF oModZ05:GetValue("Z05_DTPREV") < DDATABASE
							cMsgHlp	+= "A data prevista não pode ser menor que a data atual. " +CRLF	
							//Help(" ",1,"ALVISIT",,"A data prevista não pode ser menor que a data atual. " ,4,5)
							xRet := .F.	
						ENDIF 
					ENDIF
					 
					IF VAL(STRTRAN(oModZ05:GetValue("Z05_HRFIMP"),":","") ) < VAL(STRTRAN(oModZ05:GetValue("Z05_HRPREV"),":","") )
						cMsgHlp	+= "A Fim Previsto não pode ser menor que o Inicio Previsto. " +CRLF	
						xRet := .F.	
					ENDIF 
					
					IF EMPTY(oModZ05:GetValue("Z05_HRIN")  )
	
						cQuery += " SELECT * "
						cQuery += " FROM "+Retsqlname("Z05")+" "
						cQuery += " WHERE D_E_L_E_T_ = '' "
		
						cQuery += " 	AND Z05_DTPREV = '"+ DTOS(oModZ05:GetValue("Z05_DTPREV")) +"' "
		
						cQuery += " 	AND ((Z05_HRPREV BETWEEN '"+ oModZ05:GetValue("Z05_HRPREV") +"' AND '"+ oModZ05:GetValue("Z05_HRFIMP") +"' ) "
						cQuery += " 	OR (Z05_HRFIMP BETWEEN '"+ oModZ05:GetValue("Z05_HRPREV") +"' AND '"+ oModZ05:GetValue("Z05_HRFIMP") +"' ) "
						cQuery += " 	OR (Z05_HRPREV < '"+ oModZ05:GetValue("Z05_HRPREV") +"' AND Z05_HRFIMP >   '"+ oModZ05:GetValue("Z05_HRFIMP") +"')) "
						cQuery += " 	AND Z05_CODVIS = '"+ oModZ05:GetValue("Z05_CODVIS") +"' "
						//cQuery += " 	AND Z05_STATUS = '1' "
						
					ELSE
						cQuery += " SELECT * "
						cQuery += " FROM "+Retsqlname("Z05")+" "
						cQuery += " WHERE D_E_L_E_T_ = '' "
		
						cQuery += " 	AND Z05_DTIN = '"+ DTOS(oModZ05:GetValue("Z05_DTIN")) +"' "
		
						cQuery += " 	AND ((Z05_HRIN BETWEEN '"+ oModZ05:GetValue("Z05_HRIN") +"' AND '"+ oModZ05:GetValue("Z05_HRFIM") +"' ) "
						cQuery += " 	OR (Z05_HRFIM  BETWEEN '"+ oModZ05:GetValue("Z05_HRIN") +"' AND '"+ oModZ05:GetValue("Z05_HRFIM") +"' ) "
						cQuery += " 	OR (Z05_HRIN < '"+ oModZ05:GetValue("Z05_HRIN") +"' AND Z05_HRFIM  >   '"+ oModZ05:GetValue("Z05_HRFIM") +"')) "
						cQuery += " 	AND Z05_CODVIS = '"+ oModZ05:GetValue("Z05_CODVIS") +"' "
					ENDIF 
					If Select("QRYHR") > 0
						QRYHR->(DbCloseArea())
					EndIf
	
					dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),'QRYHR')
	
					IF QRYHR->(!EOF())
						cMsgHlp	+= "Existem conflitos de horarios com outro agendamento." +CRLF	
						xRet := .F.
					ENDIF 
	
					IF !EMPTY(cMsgHlp) 
						Help(" ",1,"ALVISIT",,cMsgHlp ,4,5)
					ENDIF
					/*	
					ELSEIF nOperation == 4//|Alteração|
	
					IF oModZ05:GetValue("Z05_STATUS") == "3"					
					cMsgHlp	+= "Status " + X3COMBO("Z05_STATUS", oModZ05:GetValue("Z05_STATUS") )+ " não permite alteração." + CRLF	
					xRet := .F.
					ENDIF 
					*/
				ENDIF 
			ELSE
				cMsgHlp	+= "Codigo de Visitadora não Preenchido" +CRLF	
				xRet := .F.
			
			ENDIF 
		Endif
	Endif 	 

Return(xRet)

/*/{Protheus.doc} ALVISIA
Rotina para gravação via ExecAuto
@author Jonatas Oliveira | www.compila.com.br
@since 02/06/2017
@version 1.0
@param cAliasImp, C, Alias
@param nIndice, n, Indice
@param aDados, a, Dados
@param nOper, n, Operacao - 3- Inclusão, 4- Alteração, 5- Exclusão
@param cModel, C, Modelo de dados
@return aRet, {.F., ""}
/*/
User Function ALVISIA(cAliasImp, nIndice, aDados, nOper,cModel, cChvReg)
	Local aRet		:= {.F., ""}
	local cWarn		:= ""
	Local oModel, oAux, oStruct
	Local nI		:= 0
	Local nPos 		:= 0
	Local lRet 		:= .T.
	Local aAux    	:= {}
	Local aCampos	:= {}
	Local lContinua	:= .T.



	dbSelectArea( cAliasImp )
	dbSetOrder( nIndice )

	oModFull := FWLoadModel( cModel )
	oModFull:SetOperation( nOper )
	oModFull:Activate()

	oModel 		:= oModFull:GetModel( cAliasImp + 'MASTER' )
	oStruct 	:= oModel:GetStruct()

	aCampos  	:= oStruct:GetFields()

	IF nOper == 4//|Alteração|
		IF DBSEEK(cChvReg)


			IF oModel:GetValue("Z05_STATUS") == "3"					
				aRet[1] := .F.
				aRet[2] := "Status " + X3COMBO("Z05_STATUS", oModel:GetValue("Z05_STATUS") )+ " não permite alteração." + CRLF	
				
				lContinua := aRet[1]
			ENDIF 			
		ENDIF 
	ENDIF 
	
	IF lContinua
		//| Atribui Valores ao Model|
		For nI := 1 To Len( aDados )
			// Verifica se os campos passados existem na estrutura do modelo
			//If ( nPos := aScan(aDados,{|x| AllTrim( x[1] )== AllTrim(aCampos[nI][3]) } ) ) > 0
			If ( nPos := aScan(aCampos,{|x| AllTrim( x[3] )== AllTrim(aDados[nI][1]) } ) ) > 0
	
				// È feita a atribuição do dado ao campo do Model
				If !( lAux := oModel:SetValue(aDados[nI][1], aDados[nI][2] ) )
					// Caso a atribuição não possa ser feita, por algum motivo (validação, por 	exemplo)
					// o método SetValue retorna .F.
	
					cWarn	+= aCampos[nI][1]+"- Não foi possivel atribuir valor a este campo"
				EndIf
			ELSE
				cWarn	+= aCampos[nI][1]+"- Não encontrado na entidade "+cAliasImp 
			EndIf
		Next nI
	
		If oModFull:VldData() 
			// Se o dados foram validados faz-se a gravação efetiva dos dados (commit)
			IF oModFull:CommitData()
				aRet	:= {.T., cWarn}
			ELSE
				aRet[2]	:= oModFull:GetErrorMessage()[6]
			ENDIF
		ELSE
	
			aErro := oModFull:GetErrorMessage()
			// A estrutura do vetor com erro é:
			// [1] identificador (ID) do formulário de origem
			// [2] identificador (ID) do campo de origem
			// [3] identificador (ID) do formulário de erro
			// [4] identificador (ID) do campo de erro
			// [5] identificador (ID) do erro
			// [6] mensagem do erro
			// [7] mensagem da solução
			// [8] Valor atribuído
			// [9] Valor anterior
	
	
			aRet[2]	:=  aErro[4]+"-"+aErro[6]
		EndIf
	ENDIF
	 
	oModFull:DeActivate()


Return(aRet)


User Function TSTEXVIS()
	Local ADADOS	:= {}
	Local cMsgDeta	:= ""

	_cEmp		:= "01"
	_cFilial	:= "00101MG0001"//"00101MG0001"//"00303MG0001"

	PREPARE ENVIRONMENT EMPRESA _cEmp FILIAL _cFilial

	cMsgDeta += "Visita Realizado com sucesso."+ CRLF 
	cMsgDeta += "Medico prestativo."+ CRLF
	cMsgDeta += "Atende em mais de um consultorio."+ CRLF

	AADD(aDados, {"Z05_STATUS"		, "3"					, .F.})	//1=Prevista;2=Programada;3=Finalizada
	AADD(aDados, {"Z05_DTIN"		, CTOD("31/05/2017")	, .F.})
	AADD(aDados, {"Z05_HRIN"		, "19:15"				, .F.})
	AADD(aDados, {"Z05_LATIIN"		, "-23,5587"			, .F.})
	AADD(aDados, {"Z05_LONGIN"		, "-46,659"				, .F.})
	AADD(aDados, {"Z05_DTFIM"		, CTOD("31/05/2017")	, .F.})
	AADD(aDados, {"Z05_HRFIM"		, "19:30"				, .F.})
	AADD(aDados, {"Z05_LATIFI"		, "-23,5587"			, .F.})
	AADD(aDados, {"Z05_LONGFI"		, "-46,659"				, .F.})
	AADD(aDados, {"Z05_REUNIA"		, "1"					, .F.})//|1=Sim;2=Nao|
	AADD(aDados, {"Z05_REUNMED"		, "1"					, .F.})//|1=MEDICO;2=SECRETARIA|
	AADD(aDados, {"Z05_REUNSEC"		, "1"					, .F.})//|1=MEDICO;2=SECRETARIA|
	AADD(aDados, {"Z05_FEEDB"		, "4"					, .F.})//|1=Pessimo;2=Ruim;3=Regular;4=Bom;5=Otimo|
	AADD(aDados, {"Z05_DETALH"		, cMsgDeta				, .F.})

	U_ALVISIA("Z05", 3, aDados, 4,"ALVISIT", "73698")
	//U_ALVISIA("Z05", 3, aDados, 4,"Z05MODEL", "73698")

	RESET ENVIRONMENT 

Return()




/*/{Protheus.doc} ACHFilter
Realiza filtro de medicos por visitadora
@author Jonatas Oliveira | www.compila.com.br
@since 27/10/2017
@version 1.0
/*/
User Function ACHFilter()
	Local cRet		:= ""
	Local cQuery	:= ""
	Local nPosRet   
	Local cUltRev	:= ""
	Local cRetAux	:= ""
	
	cDescCons	:= "Medicos"
	cAliasCon	:= "ACH"                              


	cQuery	+= " SELECT Z04_CODMED "+CRLF
	cQuery	+= " FROM "+Retsqlname("Z04")+" Z04 "+CRLF
	
	cQuery	+= " INNER JOIN "+Retsqlname("ACH")+" ACH "+CRLF
	cQuery	+= " 	ON ACH_FILIAL = '' "+CRLF
	cQuery	+= " 	AND Z04_CODMED = ACH_CODIGO "+CRLF
	cQuery	+= " 	AND ACH.D_E_L_E_T_ = '' "+CRLF
	cQuery	+= " WHERE Z04.D_E_L_E_T_ = '' "+CRLF
//	cQuery	+= " 	AND Z04_CODVIS = '"+M->Z05_CODVIS+"' "+CRLF
	
	
	If Select("QRYMED") > 0
		QRYMED->(DbCloseArea())
	EndIf
	
	dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),'QRYMED')
	
	WHILE QRYMED->(!EOF())
	 	
	 	cRetAux += QRYMED->Z04_CODMED 
	 	
	 	QRYMED->(DBSKIP())
	ENDDO
	
	cRetAux := INQuery(cRetAux, , 8) 
	
	cRet 	:= 	"@ACH_CODIGO IN " + cRetAux

Return(cRet)



//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ AUGUSTO RIBEIRO                                  ³
//³                                                  ³
//³ Recebe String separa por caracter "X"            ³
//³ ou Numero de Caractres para "quebra" _nCaracX)   ³
//³ Retorna String pronta para IN em selects         ³
//³ Ex.: Retorn: ('A','C','F')                       ³
//³                                                  ³
//³ PARAMETROS:  _cString, _cCaracX                  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function INQuery(_cString, _cCaracX, _nCaracX)
	Local _cRet	:= ""
	Local _cString, _cCaracX, _nCaracX, nY, _nI
	Local _aString	:= {}
	Default	_nCaracX := 0

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Valida Informacoes Basicas ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	IF !EMPTY(_cString) .AND. (!EMPTY(_cCaracX) .OR. _nCaracX > 0)

		nString	:= LEN(_cString)



		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Utiliza Separacao por Numero de Caracteres ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		IF _nCaracX > 0
			FOR nY := 1 TO nString STEP _nCaracX

				AADD(_aString, SUBSTR(_cString,nY, _nCaracX) )

			Next nY

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Utiliza Separacao por caracter especifico ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		ELSE
			_aString	:= WFTokenChar(_cString, _cCaracX)
		ENDIF



		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Monta String para utilizar com IN em querys³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		_cRet	+=  "('"
		FOR _nI := 1 TO Len(_aString)
			IF _nI > 1
				_cRet	+= ",'"
			ENDIF
			_cRet += ALLTRIM(_aString[_nI])+"'"
		Next _nI
		_cRet += ") "

	ENDIF

Return(_cRet)


User Function TSTVISIT()


DBSELECTAREA("Z05")
Z05->(DBSETORDER(1))
Z05->(DBGOTOP())


DBSELECTAREA("ACH")
ACH->(DBSETORDER(7))

WHILE Z05->(!EOF())
	IF ACH->(DBSEEK(XFILIAL("ACH") +  ALLTRIM(Z05->Z05_CRM)))
		Z05->(RecLock("Z05",.F.))
			Z05->Z05_CRM	:=  ACH->ACH_XCRM  		
			Z05->Z05_UFCRM	:= 	ACH->ACH_XCRMUF		
			Z05->Z05_SEGMEN	:= 	POSICIONE("AOV",1, XFILIAL("AOV") + ACH->ACH_CODSEG ,"AOV_DESSEG")
			Z05->Z05_NOME	:=  ACH->ACH_RAZAO 		
			Z05->Z05_ESPECI	:= 	ACH->ACH_XESP01		
			Z05->Z05_EMAIL	:=  ACH->ACH_EMAIL 		
			Z05->Z05_ENDER	:=  ACH->ACH_END   		
			Z05->Z05_BAIRRO	:= 	ACH->ACH_BAIRRO		
			Z05->Z05_MUNIC	:=  ACH->ACH_CIDADE		
			Z05->Z05_UF		:=  ACH->ACH_EST   		
			Z05->Z05_CEP	:=  ACH->ACH_CEP   		
			Z05->Z05_COMPL	:=  ACH->ACH_XCOMPL					
		Z05->(MsUnLock())
	ENDIF 
	
	Z05->(DBSKIP())
ENDDO 

Return()
/*/{Protheus.doc} ALVISLIS
Lista Programação de Visitas do Mes 
@author Jonatas Oliveira | www.compila.com.br
@since 22/04/2019
@version 1.0
/*/
User Function ALVISLIS(cOpcList, oLbxTit, aCpoHeader, aHeader, aDados, oPanel, _nOperation, cCodVis, dDatPrev )
Local lRet			:= .T.
Local aVlrCor		:= {} 


//Private lMarkAll	:= .F.
Private aCpoHeader
Private cCdoVis		:= ""

	

Default	cOpcList	:= "C"

Default aCpoHeader	:= {} 
Default aHeader		:= {} 
Default aDados		:= {}

Default	oLbxTit		:= NIL
Default	oPanel		:= NIL
Default	_nOperation	:= 1

Default cCodVis 	:= Z05->Z05_CODVIS
Default dDatPrev 	:= dDataBase

aRetAux	:= U_ALVISGET(cCodVis,dDatPrev)

IF aRetAux[1]
	aCpoTit		:= aRetAux[2]
	aHeadTit	:= aRetAux[3]
	aDadoTit	:= aRetAux[4]
	

			
	lRet	:= .T.
ELSE
//	Help(" ",1,"VAZIO",,"Não existem titulos em aberto para negociação.",4,5)
ENDIF

IF cOpcList	== "C"
//	aRetAux	:= U_ALVISGET(SA1->A1_COD,SA1->A1_LOJA) //\ {.F., aCpoHeader, aHeader, aDados)
	IF _nOperation == 1
		aRetAux	:= U_ALVISGET(Z05->Z05_CODVIS, dDataBase)
	ELSE
		aRetAux	:= U_ALVISGET(M->Z05_CODVIS,M->Z05_DTPREV)
	ENDIF 
	IF aRetAux[1]
		aCpoTit		:= aRetAux[2]
		aHeadTit	:= aRetAux[3]
		aDadoTit	:= aRetAux[4]
	
				
		lRet	:= .T.
	ENDIF
ENDIF

aCpoHeader		:= aCpoTit
aHeader			:= aHeadTit
aDados			:= aDadoTit
    
/*----------------------------------------
	22/04/2019 - Jonatas Oliveira - Compila
	Monta aDadosLbx 
------------------------------------------*/         
IF !empty(aDadoTit)
	MontLis(cOpcList, @oLbxTit, @aCpoHeader, @aHeader, @aDados, @oPanel)
ENDIF 

Return()

/*/{Protheus.doc} ALVISGET
Query para apresentação dos dados Programação de Visitas do Mes 
@author Jonatas Oliveira | www.compila.com.br
@since 22/04/2019
@version 1.0
/*/
User Function ALVISGET(cCodVis,dDataVis)
Local aCpoHeader	:= {} 
Local aHeader		:= {} 
Local aDados		:= {}
Local aRet			:= {.F., aCpoHeader, aHeader, aDados}	
Local cQuery		:= "" 
Local dDtIni	:= FirstDay(dDataVis)
Local dDtFim	:= LastDay(dDataVis)
 
cQuery	:= " SELECT Z05_DTPREV, "
cQuery	+= " 	Z05_HRPREV, "
cQuery	+= " 	Z05_HRFIMP, "
cQuery	+= " 	Z05_STATUS, "
cQuery	+= " 	Z05_NOME  , "
cQuery	+= " 	Z05_ESPECI, "
cQuery	+= " 	Z05_EMAIL , "
cQuery	+= " 	Z05_ENDER , "
cQuery	+= " 	Z05_DTIN  , "
cQuery	+= " 	Z05_HRIN  , "
cQuery	+= " 	Z05_DTFIM , "
cQuery	+= " 	Z05_HRFIM ,"
cQuery	+= " 	Z05_CODVIS ,"
cQuery	+= " 	Z05_VISITA "
  
cQuery	+= " FROM "+Retsqlname("Z05")+" Z05 with(nolock) "

cQuery	+= " WHERE Z05_CODVIS = '"+ cCodVis +"' "
cQuery	+= " 	AND Z05_DTPREV BETWEEN '"+ DTOS(dDtIni) +"' AND '"+ DTOS(dDtFim) +"' "
cQuery	+= " 	AND D_E_L_E_T_ = '' "

cQuery	+= " ORDER BY Z05_DTPREV, Z05_HRPREV "



If Select("QRY") > 0
	QRY->(DbCloseArea())
EndIf

dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),'QRY')

TCSetField("QRY","Z05_DTPREV","D",08,00)
TCSetField("QRY","Z05_DTIN","D",08,00)
TCSetField("QRY","Z05_DTFIM","D",08,00)

 
/*----------------------------------------
	22/04/2019 - Jonatas Oliveira - Compila
	Monta aHeader
------------------------------------------*/

For nY := 1 To QRY->(FCOUNT())   


	aadd(aHeader,ALLTRIM(RetTitle(FieldName(nY))))	
	aadd(aCpoHeader,FieldName(nY))
 
Next nY	


/*----------------------------------------
	22/04/2019 - Jonatas Oliveira - Compila
	Monta aDados
------------------------------------------*/ 
IF QRY->(!EOF())

	nTotalA	:= 0
	
	WHILE QRY->(!EOF())

		aLinha	:= {}
		
		For nY := 1 To QRY->( FCOUNT())  
		    IF ALLTRIM(QRY->( FieldName( nY ))) == "Z05_STATUS"
		    	aadd(aLinha, X3COMBO("Z05_STATUS", QRY->(FIELDGET(nY))))
		    ELSE
		    	aadd(aLinha, QRY->(FIELDGET(nY)))
			ENDIF 
		Next nY	 

		
		AADD(aDados, aLinha)


		QRY->(DBSKIP())
	ENDDO   

	
	aRet[1]	:= .T.
	aRet[2]	:= aCpoHeader
	aRet[3]	:= aHeader
	aRet[4]	:= aDados

ELSE
 	aLinha	:= {}
	For nY := 1 To QRY->(FCOUNT())      
		aadd(aLinha, QRY->(FIELDGET(nY)))
	Next nY	 
	
	AADD(aDados, aLinha)
	
	aRet[1]	:= .T.
	aRet[2]	:= aCpoHeader
	aRet[3]	:= aHeader
	aRet[4]	:= aDados
	
ENDIF                  


Return (aRet)

/*/{Protheus.doc} MontLis
Monta Interface de seleção
@author Jonatas Oliveira | www.compila.com.br
@since 14/04/2016
@version 1.0
/*/
Static Function MontLis(cOpcList, oLbxTit, aCpoHeader, aHeader, aDados, oPanel)

	Local cBCodLin		:= ""   
	Local oOk 	     	:= LoadBitmap( GetResources(), "LBOK" )
	Local oNo   	   	:= LoadBitmap( GetResources(), "LBNO" )
	Local oFLabels 		:= TFont():New("Verdana",,018,,.T.,,,,,.F.,.F.)
	Local oFGrpCpo 		:= TFont():New("Verdana",,016,,.F.,,,,,.F.,.F.)

	Private oDlgMain	:= NIL

	
	/*----------------------------------------
		22/04/2019 - Jonatas Oliveira - Compila
		cOpcList | C = Cria, A = Atualiza
	------------------------------------------*/
	IF cOpcList == "C"
	
		

		@ 3, 5 SAY oLblSolicita PROMPT "" SIZE 150, 012 OF oPanel FONT oFLabels COLORS CLR_BLUE, 16777215 PIXEL
		@ 3,0 LISTBOX oLbxTit FIELDS HEADER ;
		" ", "Campos" ;                                                                                                    
		SIZE (oPanel:nClientWidth/2)-10,(oPanel:nClientHeight/2)-45 OF oPanel 

		oLbxTit:aheaders := aHeader			   
		//lMarkAll	:= .F.
//		oLbxTit:BHEADERCLICK	:= { |oObj,nCol| AFIN68H( oObj,nCol, .T.) }		
	ENDIF

	/*
	@  250, 40 		SAY oLblSolicita PROMPT "Total " 		SIZE 50, 014 OF oDlgMain FONT oFGrpCpo COLORS 128, 16777215 PIXEL
	oTotalP := TGet():Create( oDlgMain,{|| CalcTot("TP", @aDadoMain)},250, 40	, 050,009,D_PICTURE_VLRT,,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,cTotalP,,,, )
	*/
	oLbxTit:SetArray( aDados )  
	
	/*----------------------------------------
		22/04/2019 - Jonatas Oliveira - Compila
		Cria string com Bloco de Codigo
	------------------------------------------*/
	//	cBCodLin	:= "LoadBitmap( GetResources(), aDados[oLbxTit:nAt,"+alltrim(str(nP04STATUS))+"] ) "
	//	cBCodLin	:= "Iif(aDados[oLbxTit:nAt,1],oOk,oNo)"
	//cBCodLin	:= "IIF(ALLTRIM(aDados[oLbxTit:nAt,nP04STATUS]) == alltrim(X3COMBO('P04_STATUS','4')), oNo, Iif(aDados[oLbxTit:nAt,1],oOk,oNo))"

	For nI := 1 To LEN(aHeader)
		IF nI > 1
			cBCodLin	+=", "
		endif
		cI	:= alltrim(str(nI))
		
		cBCodLin	+= "aDados[oLbxTit:nAt,"+cI+"]"	
		
	Next nI	

	cBCodLin	:= "oLbxTit:bLine := {|| {"+cBCodLin+"}}"
	&(cBCodLin)            


	oLbxTit:Refresh()

Return    