#Include "Protheus.Ch"
#Include "rwmake.Ch"
#include "TOTVS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "FWMBROWSE.CH"      
#INCLUDE 'TBICONN.CH'


//| ZA1_STATUS
#DEFINE ZAF_STATUS_RASCUNHO	"1"   
#DEFINE ZAF_STATUS_PENDENTE	"2"
#DEFINE ZAF_STATUS_APROVADO	"3"
#DEFINE ZAF_STATUS_REVISAO	"4"
#DEFINE ZAF_STATUS_RECUSADO	"5"
#DEFINE ZAF_STATUS_PAGO		"6"

//| 1=Rascunho;2=Pendente Aprov.;3=Aprovado;4=Em Revisao;5=Recusado

/* - FWMVCDEF
MODEL_OPERATION_INSERT para inclus„o;
MODEL_OPERATION_UPDATE para alteraÁ„o;
MODEL_OPERATION_DELETE para exclus„o.
MODEL_OPERATION_VIEW para exclus„o.
*/

#DEFINE D_TITULO 'Integra Pagamentos | Reembolso de Despesa'     
#DEFINE D_ROTINA 'CP07007' 

/*/{Protheus.doc} CP07007
Interface para aprovaÁ„o do reembolso de despesa 
@author Augusto Ribeiro | www.compila.com.br
@since 27/01/2014
@version 1.0
@return ${return}, ${return_description}
/*/
User function CP07007() 
//Local oBrowse  
PRIVATE _LCOPIA	:= .F.
Private xRetCon
Private oLbxMain,aHeadZAF, aDadoZAF, nColAnt
Private nZAFVLRTOT, nZAFCODIGO, nZAFCODUSR, nZAFCODNAT, nZAFCODPRO
Private cPerg		:= "CP0707"


dbselectarea("ZAF")
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

	IF ListAprov(,"V")	
		nRetAux := FWExecView(D_TITULO,D_ROTINA,  MODEL_OPERATION_UPDATE,,  {|| .T. } )
	ENDIF
ENDIF

Return NIL

        
/*‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥ CP07007  ∫Autor  ≥Augusto Ribeiro     ∫ Data ≥ 07/01/2011  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ 	Botoes do MBrowser                                        ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/  

Static Function MenuDef()
Local aRotina := {}


ADD OPTION aRotina TITLE 'Pesquisar' 	ACTION 'PesqBrw'             OPERATION 1 ACCESS 0
ADD OPTION aRotina TITLE 'Visualizar'	ACTION 'VIEWDEF.'+D_ROTINA OPERATION 2 ACCESS 0                         
ADD OPTION aRotina TITLE 'Incluir' 	ACTION  'VIEWDEF.'+D_ROTINA OPERATION 3 ACCESS 0  	
ADD OPTION aRotina TITLE 'Alterar'		ACTION 'VIEWDEF.'+D_ROTINA OPERATION 4 ACCESS 0
//ADD OPTION aRotina TITLE 'Excluir'		ACTION 'VIEWDEF.'+D_ROTINA OPERATION 5 ACCESS 0
//ADD OPTION aRotina TITLE 'Copiar'		ACTION 'VIEWDEF.'+D_ROTINA OPERATION 9 ACCESS 0
//ADD OPTION aRotina TITLE 'Imprimir'	ACTION 'VIEWDEF.'+D_ROTINA OPERATION 8 ACCESS 0
//ADD OPTION aRotina TITLE 'TESTE'     ACTION 'U_FAT01TST()' OPERATION 9 ACCESS 0
//ADD OPTION aRotina TITLE 'Legenda'  ACTION 'eval(oBrowse:aColumns[1]:GetDoubleClick())'             OPERATION 1 ACCESS 0


// ADD OPTION aRotina TITLE 'Amarra B.I.'  ACTION 'U_EST02MNU("AMARRA")' OPERATION 2 ACCESS 0
Return aRotina



/*‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥ CP07007  ∫Autor  ≥Augusto Ribeiro     ∫ Data ≥ 19/11/2013  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ 	Definicoes do Model                                       ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/  
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oStruZAF := FWFormStruct( 1, 'ZAF', /*bAvalCampo*/,/*lViewUsado*/ )
Local oStruZA3 := FWFormStruct( 1, 'ZA3', /*bAvalCampo*/,/*lViewUsado*/ )
Local oModel
Local lRetGrv	:= .F.

Local bVldPosFull	:= { |oModel| VLDMODEL('MODEL_POS', oModel) }
Local bLPREZA3	:= { |oModel, nLine, cAction, cField| VldLinOK('LPRE_ZA3', oModel, nLine, cAction, cField ) }
Local bLPOSZA3	:= { |oModel, nLine, cAction, cField| VldLinOK('LPOS_ZA3', oModel, nLine, cAction, cField ) }
Local bGrvDados	:=  { |oModel| PROCESSA({|| lRetGrv := GRVDADOS(oModel) },"Processando... "), lRetGrv} 

// Cria o objeto do Mod elo de Dados
oModel := MPFormModel():New(D_ROTINA+'MODEL',  /*bPreValidacao*/, bVldPosFull /*bPosValidacao*/, bGrvDados /*bCommit*/, /*bCancel*/ )
//oModel := MPFormModel():New('ATEC204MODEL', /*bPreValidacao*/,/*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

// Adiciona ao modelo uma estrutura de formul·rio de ediÁ„o por campo
oModel:AddFields( 'ZAFCABEC', /*cOwner*/, oStruZAF, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
oModel:AddGrid( 'ZA3VINCULO', 'ZAFCABEC', oStruZA3, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/,  /*BLoad*/ )

// Adiciona modelo de contador. 
// AddCalc(cId , cOwner , cIdForm , cIdField , cIdCalc , cOperation , bCond , bInitValue , cTitle , bFormula , nTamanho, nDecimal)
oModel:AddCalc( 'CP0707_CALC', 'ZAFCABEC', 'ZA3VINCULO', 'ZA3_RECREG', 'TOTALAPROV', 'FORMULA', /*bCond */, /*bInitValue*/ , 'Total' , {|oModel| CampoCalc("TOTAL",aHeadZAF, aDadoZAF) }, 9 /*nTamanho*/, 2/*nDecimal*/)



// Faz relaciomaneto entre os compomentes do model                                                                           
oModel:SetRelation( 'ZA3VINCULO',	{{ 'ZA3_FILIAL', 'XFILIAL("ZA3")' }, { 'ZA3_CODIGO', 'ZAF_CODIGO' }} ,  ZA3->(IndexKey(1)) )

/// Liga o controle de nao repeticao de linha
oModel:GetModel( 'ZA3VINCULO' ):SetUniqueLine( { 'ZA3_ALIAS'} )


// Indica que È opcional ter dados informados na Grid
// oModel:GetModel( 'ZA6SERV' ):SetOptional(.T.) //| Removido ServiÁos Executados - Sol. Adriano


// Adiciona a descricao do Modelo de Dados
oModel:SetDescription(D_TITULO)

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'ZAFCABEC' ):SetDescription( 'Despesa' )      
oModel:GetModel( 'ZA3VINCULO' ):SetDescription( 'Vinculos' )

//oModel:GetModel( 'ZA2COMPROV' ):SetOptional(.T.)
oModel:GetModel( 'ZA3VINCULO' ):SetOptional(.T.)         
       
// Liga a validaÁ„o da ativacao do Modelo de Dados
//oModel:SetVldActivate( { |oModel,cAcao| U_CP701VLD('MODEL_ACTIVE', oModel) } )

Return oModel


/*‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥ CP07007  ∫Autor  ≥Augusto Ribeiro     ∫ Data ≥ 07/01/2011  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ 	Definicoes da View                                        ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/  
Static Function ViewDef()
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   := FWLoadModel( D_ROTINA )
// Cria a estrutura a ser usada na View
Local oStruZAF := FWFormStruct( 2, 'ZAF' )
Local oStruZA3 := FWFormStruct( 2, 'ZA3' )
Local nOperation := oModel:GetOperation()
Local oView   

//Local oStruCSW := FWFormStruct( 1, 'CSW', /*bAvalCampo*/, /*lViewUsado*/ ) 
//Local oModel

oStruZA3:RemoveField( 'ZA3_INDCHV' )                                   
oStruZA3:RemoveField( 'ZA3_RECREG' )
                        
// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados ser· utilizado
oView:SetModel( oModel )

// Cria o objeto de Estrutura 
oCpoCalc := FWCalcStruct( oModel:GetModel( 'CP0707_CALC') )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddOtherObject("LIST_APROV", {|oPanel| ListAprov(oPanel, "C", @oLbxMain, @aHeadZAF, @aDadoZAF) })
//oView:AddGrid( 'VIEW_ZA2', oStruZA2, 'ZA2COMPROV' )
//oView:AddGrid( 'VIEW_ZA3', oStruZA3, 'ZA3VINCULO' )

oView:AddField( 'VIEW_CALC', oCpoCalc, 'CP0707_CALC' )
//oView:AddOtherObject("BUTTON", {|oPanel| BtnTail(oPanel) })


// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'TOP' , 90 )
oView:CreateHorizontalBox( 'TAIL' , 10)

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'LIST_APROV', 'TOP')
oView:SetOwnerView( "VIEW_CALC"  , 'TAIL' )

// Define campos que terao Auto Incremento
//oView:AddIncrementField( 'VIEW_ZA2', 'ZA2_ITEM' )
//oView:AddIncrementField( 'VIEW_ZA3', 'ZA3_ITEM' )

//oView:AddOtherObject("ABAIXO_CAL", {|oPanel| U_FAT01BCAL(oPanel)})
//oView:SetOwnerView("ABAIXO_CAL",'RIGHT_SUP2')



// Criar novo botao na barra de botoes no antigo Enchoice Bar            
//oView:AddUserButton( 'Visualizar Comprovante (F12)', 'Visualizar Comprov.', { |oView| U_CP701BTN('VISUALIZA_1', oView) } )
//oView:AddUserButton( 'Copiar Comprovantes', 'Copiar Comprov.', { |oView| U_CP701BTN('COPIA_COMPROV', oView) } )

// Liga a identificacao do componente
oView:EnableTitleView('LIST_APROV', "Despesas Aprovadas")
//oView:EnableTitleView('VIEW_ZA2')
//oView:EnableTitleView('VIEW_ZA3')
//oView:EnableTitleView('VIEW_CALC','Totalizadores')


// Liga a EdiÁ„o de Campos na FormGrid
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
@return lRet, L, .T.=ExisteDados ,.F.=N„o existe dados
/*/
Static Function ListAprov(oPanel, cOpcList, oLbxMain,aHeader, aDados)
Local lRet		:= .T.
Local cQuery	:= "" 
Local aCpoHeader
Local cBCodLin	:= ""  
Local oOk 	     	:= LoadBitmap( GetResources(), "LBOK" )
Local oNo   	   	:= LoadBitmap( GetResources(), "LBNO" )
Local nLinIni
Local cDespRef	:= U_CP07002G("20", "ALIASDESP", "SED")
Local cFieldName, xConteudo, nY, nI

aCpoHeader	:= {} 
aHeader	:= {} 
aDados		:= {}

cQuery	:= ""
IF cDespRef == "SED"
	cQuery	+= "SELECT ZAF_CODIGO, ZAF_DTDESP, MAX(ZAC_DTAPRO) AS ZAC_DTAPRO, ZAF_CODIGO, ZAF_CODUSR, '' AS ZAF_NOMUSR, ZAF_CODNAT, SED.ED_DESCRIC AS DESCDEP, ZAF_VLRTOT, ZAF.R_E_C_N_O_ AS ZAF_RECNO  "+CRLF
ELSEIF  cDespRef == "SB1"
	cQuery	+= "SELECT ZAF_CODIGO, ZAF_DTDESP, MAX(ZAC_DTAPRO) AS ZAC_DTAPRO, ZAF_CODIGO, ZAF_CODUSR, '' AS ZAF_NOMUSR, ZAF_CODPRO, SB1.B1_DESC AS DESCDEP, ZAF_VLRTOT, ZAF.R_E_C_N_O_ AS ZAF_RECNO  "+CRLF
ENDIF

cQuery	+= " FROM "+RetSqlName("ZAF")+" ZAF "+CRLF
cQuery	+= " INNER JOIN "+RetSqlName("ZAC")+" ZAC "+CRLF
cQuery	+= " 	ON ZAC_FILIAL = ZAF_FILIAL "+CRLF
cQuery	+= " 	AND ZAC_CODIGO = ZAF_CODIGO "+CRLF
cQuery	+= " 	AND ZAC_DTAPRO BETWEEN '"+DTOS(MV_PAR03)+"' AND '"+DTOS(MV_PAR04)+"' "+CRLF
cQuery	+= " 	AND ZAC.D_E_L_E_T_ = '' "+CRLF

IF cDespRef == "SED"
	cQuery	+= " INNER JOIN "+RetSqlName("SED")+" SED "+CRLF
	cQuery	+= " 	ON ED_FILIAL = '"+XFILIAL("SED")+"' "+CRLF
	cQuery	+= " 	AND ED_CODIGO = ZAF_CODNAT "+CRLF
	cQuery	+= " 	AND SED.D_E_L_E_T_ = '' "+CRLF
ELSEIF cDespRef == "SB1"
	cQuery	+= " INNER JOIN "+RetSqlName("SB1")+" SB1 "+CRLF
	cQuery	+= " 	ON SB1.B1_FILIAL = '"+XFILIAL("SB1")+"' "+CRLF
	cQuery	+= " 	AND SB1.B1_COD = ZAF_CODPRO "+CRLF
	cQuery	+= " 	AND SB1.D_E_L_E_T_ = '' "+CRLF
ENDIF

cQuery	+= " WHERE ZAF_FILIAL = '' "+CRLF
cQuery	+= " AND ZAF_CODUSR <> '' "+CRLF 
cQuery	+= " AND ZAF_CODUSR BETWEEN '"+MV_PAR05+"' AND '"+MV_PAR06+"' "+CRLF
cQuery	+= " AND ZAF_DTDESP BETWEEN '"+DTOS(MV_PAR01)+"' AND '"+DTOS(MV_PAR02)+"' "+CRLF
cQuery	+= " AND ZAF_STATUS = '"+ZAF_STATUS_APROVADO+"' "+CRLF
cQuery	+= " AND ZAF.D_E_L_E_T_ = '' "+CRLF



IF cDespRef == "SED"
	cQuery	+= "GROUP BY ZAF_CODIGO, ZAF_DTDESP, ZAF_CODIGO, ZAF_CODUSR, ZAF_CODNAT, SED.ED_DESCRIC,  ZAF_VLRTOT, ZAF.R_E_C_N_O_ "+CRLF
ELSEIF  cDespRef == "SB1"
	cQuery	+= "GROUP BY ZAF_CODIGO, ZAF_DTDESP, ZAF_CODIGO, ZAF_CODUSR, ZAF_CODPRO, SB1.B1_DESC,  ZAF_VLRTOT, ZAF.R_E_C_N_O_"+CRLF
ENDIF


If Select("QRY") > 0
	QRY->(DbCloseArea())
EndIf
          
MSGRUN("Buscan clientes....","SQL" ,		{|| dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),'QRY') } )

TCSetField("QRY","ZAF_DTDESP","D",08,00)					
TCSetField("QRY","ZAC_DTAPRO","D",08,00)


//| Somente valida se existem dados.
 
IF cOpcList == "V"
	IF QRY->(EOF())
		FwHelpShow(,"VAZIO","N„o existem dados a serem exibidos.","Por favor verifique os parametros informados") 
		return(.f.)
	ELSE
		return(.T.)
	ENDIF
ENDIF



//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ cOpcList | C = Cria, A = Atualiza ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
IF cOpcList == "C"

	nLinIni	:= 13
	
	nWidth		:= (oPanel:nWidth*0.50)-2
	nHeight	:= (oPanel:nHeight*0.50)-nLinIni-2

	@ nLinIni,1 LISTBOX oLbxMain FIELDS HEADER ;
	   " ", "Campos" ;                                                                                                    
	   SIZE nWidth,nHeight  OF oPanel  PIXEL .T. ON dblClick( aDados[oLbxMain:nAt,1] := !aDados[oLbxMain:nAt,1] , ReCalc(oLbxMain))
	   
	oLbxMain:aheaders := aHeader		   

	oLbxMain:BHEADERCLICK	:= { |oObj,nCol| U_CPXORDH( oObj,nCol,.T.), PosModel(@oLbxMain,@aHeader, @aDados), oLbxMain:Refresh(), iif(nCol==1,ReCalc(oLbxMain),.t.) }
	
	oLbxMain:bChange := {|| PosModel(@oLbxMain,@aHeader, @aDados), oLbxMain:Refresh() }			
	
ENDIF

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Monta aHeader ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ	
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

	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	//≥ Variaveis de posionamento dos campos ≥
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	nZAFVLRTOT		:=  Ascan(aCpoHeader,"ZAF_VLRTOT")
	nZAFCODIGO		:= 	Ascan(aCpoHeader,"ZAF_CODIGO")
	nZAFCODUSR		:= 	Ascan(aCpoHeader,"ZAF_CODUSR")
	nZAFCODNAT		:= 	Ascan(aCpoHeader,"ZAF_CODNAT")
	nZAFCODPRO		:= 	Ascan(aCpoHeader,"ZAF_CODPRO")
	
	/*
	nP04CODCLI	:=  Ascan(aCpoHeader,"P04_CODCLI")
	*/	
	
	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	//≥ Monta aDados ≥
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
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
	
	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	//≥ Cria string com Bloco de Codigo ≥
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
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
Local nValTotZAF := 0
Local n := 0

IF !EMPTY(aDados)

	nRecZAF	:= aDados[oLbxAux:nAT,len(aHeader)]
	ZAF->(DBGOTO(nRecZAF))
	
	oModFull:= FWModelActive()
	oModFull:DeActivate()
	oModFull:Activate()

	/* DMS - Diogo Melo */
	for n := 1 to len(aDadoZAF)

		if aDadoZAF[n][1] 
			nValTotZAF += aDadoZAF[n][9]
		endIf 

	next
    oModFull:loadValue('CP0707_CALC','TOTALAPROV', nValTotZAF)
	/**/

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
		IF cOpcCalc == "TOTAL" .AND. aDados[nI, 1]
			nRet += aDados[nI,nZAFVLRTOT]
		ENDIF
	Next nI

endif

Return(nRet)



/*/{Protheus.doc} ReCalc
 Recalcul valores dos campos calculados apÛs selecionar um novo item
@author Augusto Ribeiro | www.compila.com.br
@since 31/01/2015
@version 1.0
/*/
Static Function ReCalc(oLbxMain)
Local oModeZAF
Local nValTotZAF := 0
Local n := 0
oModFull := FWModelActive()
oModFull:DeActivate()
oModFull:Activate()

for n := 1 to len(aDadoZAF)

	if aDadoZAF[n][1] 
    	nValTotZAF += aDadoZAF[n][9]
	endIf 
next

oModFull:loadValue('CP0707_CALC','TOTALAPROV', nValTotZAF)

oView	:= FWViewActive()
oView:Refresh()

/*---------------------------------------------------------------------------------------
	Forca Model a identicar Flag como Alteracao, caso contrario ao clicacar no OK
	sistem apresenta "Formulario n„o alterado, nao precisa ser salvo."  
 ------------------------------------------------------------------------------------------*/
oModFull:lModify	:= .T.
oView:lModify	:= .T.
	
SetFocus(oLbxMain:hWnd)
	
Return()


/*/{Protheus.doc} VLDMODEL
Reliza validaÁıes da modelo de acordo envento enviado
@author Augusto Ribeiro | www.compila.com.br
@since 09/01/2015
@version 1.0
@param ${cModel}, ${c}, ${Nome da Model e envento a ser validado}
@param oModel, O, Model MAIN do MVC
@return lRet, Retorno Logico
@example
(examples)
@see (links_or_references)
/*/
Static Function VLDMODEL(cModel, oModel)
Local lRet			:= .F.
Local cMsgErro	:= ""
Local nI, nTotLen, nPosRec
Local cItem		:= "000"
Local aDados		:= {}

Default cModel	:= ""


IF cModel == "MODEL_POS"

//oLbxMain,aHeadZA1, aDadoZA1

	
	IF !EMPTY(aDadoZAF)
		FOR nI := 1 to Len(aDadoZAF)
		
			IF 	aDadoZAF[nI,1]
				lRet	:= .T.
				EXIT
			ENDIF		
		NEXT nI
		
		IF !(lRet)
			cMsgErro	:= "Nenhum registro esta selecionado. Por favor selecione as despesas que deseja integrar os pagamentos."
		ENDIF		
	ELSE
		cMsgErro	:= "Nenhum registro esta selecionado. Por favor selecione as despesas que deseja integrar os pagamentos."
	ENDIF
ENDIF


IF EMPTY(cMsgErro)
	lRet	:= .T.
ELSE
	lRet	:= .F.
	Help(" ",1,cModel,,cMsgErro,4,5)
ENDIF


Return(lRet)



/*/{Protheus.doc} GRVDADOS
Realiza a integraÁao com financeiro/folha dos reembolso de depesas
que serao pagos.
@author Augusto Ribeiro | www.compila.com.br
@since 05/02/2015
@version 1.0
@param oModel, O, Model MAIN do MVC
@return lRet, Retorno Logico
/*/
Static Function GRVDADOS(oModel)
Local lRet			:= .F.
Local cMsgErro	:= ""
Local cItem		:= "000"
Local cDespRef	:= U_CP07002G("20", "ALIASDESP", "SED")
Local cTpAgrupa	:= U_CP07002G("20", "AGRUPATITU", "NAOAGRUPA") //| [NAOAGRUPA, DESPESA, USUARIO]
Local aDadoZAD	:= {}
Local aLinZAD		:= {}
Local nI, nY, nIAux, nPosRec, nTotLen
Local nValTitulo  
Local cCodLote, cProdNat, cNatureza
Local aRetTit, aVencto
Local lAbort		:= .F.



IF !EMPTY(aDadoZAF)
	
	DBSELECTAREA("ZAF")
	//Private oLbxMain,aHeadZA1, aDadoZA1, nColAnt
	nPosRec	:= len(aHeadZAF) ///| Posicao do Recno do ZA1
	nTotLen	:= Len(aDadoZAF) //| Total de Registros
	
	cCodLote	:= GETSXENUM("ZAD","ZAD_CODIGO")
	
	
		//| Orderna
	IF cDespRef == "SED"
		aSort(aDadoZAF,,,{ |x,y| x[nZAFCODUSR]+x[nZAFCODNAT] < y[nZAFCODUSR]+y[nZAFCODNAT] })
		nProdNat	:= nZAFCODNAT
	ELSEIF cDespRef == "SB1"
		aSort(aDadoZAF,,,{ |x,y| x[nZAFCODUSR]+x[nZAFCODPRO] < y[nZAFCODUSR]+y[nZAFCODPRO] })
		nProdNat	:= nZAFCODPRO	
	ENDIF
	
	nTotLen	:= Len(aDadoZAF)
	
	
	/*---------------------------------------------------------------------------------------
		Count para PROCREGUA
	------------------------------------------------------------------------------------------*/
	nTotRegua	:= 0
	FOR nI := 1 to nTotLen
		IF 	aDadoZAF[nI,1]
			nTotRegua++
		ENDIF
	NEXT nI 
	
	
	ProcRegua(nTotRegua)
	FOR nI := 1 to nTotLen
	
		IncProc("Gerando Contas a Pagar..")
		
		//| Verifica se o registro foi marcado.
		IF 	aDadoZAF[nI,1]
			
			nValTitulo	:= 0
			cProdNat	:= ""
			aDadoZAD	:= {}
					
			nIAux		:= nI			
			FOR nI := nIAux  to nTotLen
				
				
				//| Verifica se o registro foi marcado.
				IF 	aDadoZAF[nI,1]				
					
					cItem		:= soma1(cItem)
					
					ZAF->(DBGOTO(aDadoZAF[nI,nPosRec]))
					
					IF cDespRef == "SED"
						cProdNat	:= ZAF->ZAF_CODNAT
					ELSEIF cDespRef == "SB1"
						cProdNat	:= ZAF->ZAF_CODPRO
					ENDIF
					
					cCodUser	:= ZAF->ZAF_CODUSR
					
					
					aLinZAD		:= {}			
					AADD(aLinZAD, {"ZAD_CODIGO"	, cCodLote })
					AADD(aLinZAD, {"ZAD_ITEM"	, cItem })
					AADD(aLinZAD, {"ZAD_CODDES"	, ZAF->ZAF_CODIGO })
					AADD(aLinZAD, {"ZAD_CODUSR"	, ZAF->ZAF_CODUSR })
					AADD(aDadoZAD, aLinZAD)
					
					nValTitulo		+= ZAF->ZAF_VLRTOT
					
					
					/*---------------------------------------------------------------------------------------
						Controla QUEBRA (Forma de agrupamento) para geracao do Titulo
					------------------------------------------------------------------------------------------*/
					IF nI+1<= nTotLen
					
						//| Quebra por usu·rio independa da opcao parametrizada.
						IF aDadoZAF[nI+1, nZAFCODUSR] <> cCodUser .OR.  cTpAgrupa == "NAOAGRUPA"
							EXIT
						ELSE 
						
							IF cTpAgrupa == "DESPESA" .AND. alltrim(aDadoZAF[nI+1, nProdNat]) <> alltrim(cProdNat)
								EXIT
							ENDIF	
						ENDIF
					ENDIF
					
				ENDIF
				
			NEXT nI
		
		
			/*---------------------------------------------------------------------------------------
				GERA titulo e historico da pagamentos  
			------------------------------------------------------------------------------------------*/ 
			IF nValTitulo > 0
			
				DBSELECTAREA("ZA0")
				ZA0->(DBSETORDER(1)) //| 
				IF ZA0->(DBSEEK(xfilial("ZA0")+cCodUser)) 
	
					IF !EMPTY(ZA0->ZA0_CODFOR) .AND. !EMPTY(ZA0->ZA0_LOJFOR)
					
						
						DBSELECTAREA("ZA5")
						ZA5->(DBSETORDER(1)) //| 
						IF ZA5->(DBSEEK(xfilial("ZA5")+ZA0->ZA0_CODREG )) 
							
							//| Verifica se existe natureza FIXA cadastrada
							cNatureza	:= U_CP07002G("20", "NATUREZFIX", "")
							
							IF EMPTY(cNatureza)
								IF cDespRef == "SED"
									cNatureza	:= cProdNat
								ELSEIF cDespRef == "SB1"
									//| ADICIONAR BUSCA DA NATUREZA PARA CADASTRO DE FORNECEDOR
									cNatureza	:= "" 
								ENDIF
							ENDIF
												
				
							IF !EMPTY(cNatureza)

								BEGIN TRANSACTION 

								/*------------------------------------------------------------|  Augusto Ribeiro - 11/02/2015
									GERA TITULO NO FINANCEIRO
								-------------------------------------------------------------------------------------------*/
								aRetTit := u_GeraFin(ZA0->ZA0_CODFOR, ZA0->ZA0_LOJFOR, nValTitulo, cNatureza, ZA5->ZA5_CONPAG)
								
								IF aRetTit[1]
									/*------------------------------------------------------------|  Augusto Ribeiro - 11/02/2015
										Grava tabela dos lotes de cobranÁa gerados							
									-------------------------------------------------------------------------------------------*/
									DBSELECTAREA("ZAF")
									ZAF->(DBSETORDER(1))
									FOR nY	:= 1 to len(aDadoZAD)
										
										//| Dados do Titulo
										AADD(aDadoZAD[nY], {"ZAD_FILTIT", SE2->E2_FILIAL})
										AADD(aDadoZAD[nY], {"ZAD_PRETIT", SE2->E2_PREFIXO})
										AADD(aDadoZAD[nY], {"ZAD_NUMTIT", SE2->E2_NUM})
										AADD(aDadoZAD[nY], {"ZAD_PARTIT", SE2->E2_PARCELA})
										AADD(aDadoZAD[nY], {"ZAD_TIPTIT", SE2->E2_TIPO})
										AADD(aDadoZAD[nY], {"ZAD_VENCTO", SE2->E2_VENCTO})
										AADD(aDadoZAD[nY], {"ZAD_CODFOR", SE2->E2_FORNECE})
										AADD(aDadoZAD[nY], {"ZAD_LOJFOR", SE2->E2_LOJA})
										
										//| Insere registro na ZAD 
										aRetAux	:= U_CPXGRV("ZAD", 1, aDadoZAD[nY], .T.)

										IF aRetAux[1]
										
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
									NEXT nY
								
								ELSE
								 	DISARMTRANSACTION()
									cMsgErro	:= "Falha na geraÁ„o do titulo. "+aRetTit[2]
									lAbort	:= .T.
								ENDIF
								
								END TRANSACTION
								
								//| Cancela OperaÁ„o
								IF lAbort
									FWAlertError(cMsgErro, "Erro na transaÁ„o.")
									EXIT
								ENDIF 
							ELSE
								cMsgErro	:= "Natureza nao informada. Verifique a natureza amarrada ao produto ou parametro [NATUREZFIX] no configuradar de customizaÁ„o"
							ENDIF
						ELSE
							cMsgErro	:= "Regra de reembolso n„o localizada. ["+ZA0->ZA0_CODREG+"] "
						ENDIF
					ELSE
						cMsgErro	:= "Usuario nao possui fornecedor vinculado ao seu cadastro [ZA0]. Verifique o cadastro do usu·rio."					
					ENDIF
				ELSE 
					cMsgErro	:= "Usuario ["+cCodUser+"] nao localizado no cadastro de usuarios reembolso [ZA0]"
				ENDIF
			ELSE
				cMsgErro	:= "Valor do titulo a ser gerado inv·lido. Valor igual a ZERO."
			ENDIF
			
		ENDIF		
	NEXT nI
	
	ConfirmSX8()
	
ELSE
	cMsgErro	:= "Nenhum registro esta selecionado. Por favor selecione as despesas que deseja integrar os pagamentos."
ENDIF


IF EMPTY(cMsgErro)
	lRet	:= .T.
ELSE
	lRet	:= .F.
	Help(" ",1,"GRVDADOS",,cMsgErro,4,5)
ENDIF


Return(lRet)



//| GeraFin(ZA0->ZA0_CODFOR, ZA0->ZA0_LOJFOR, nValTitulo, cNatureza, aVencto[1,1])

/*/{Protheus.doc} GeraFin
Gera titulos no financeiro
@author Augusto Ribeiro | www.compila.com.br
@since 06/02/2015
@version 1.0
@param cCodFor, C, Codigo do Fornecedor 
@param cLojaFor, C, Loja do Fornecedor
@param nValor, N, Valor do Titulo
@param cCodNat, C, Codigo da Natureza do Financeiro
@param cCondPag, C, Condicao de Pagamento
@return aRet, {lOK, cMsgErro, aChaveTitulo{cFilial, cPrefixo, cNum, cParcela, cTipo, cCodFor, cLoja} }
/*/
user Function GeraFin(cCodFor, cLojaFor, nValor, cCodNat, cCondPag)
Local aRet		:= {.F., "", {}}	
Local aTitulo	:= {}
Local aVencto	:= {}
Local cFilTit, cPrefixo, cTipo
Local _cCodEmp, _cCodFil
Local cAutoLog, cMemo, cMsgErro

IF !EMPTY(cCodFor) .AND. !EMPTY(nValor) .AND. !EMPTY(cCodNat).AND. !EMPTY(cCondPag)  

	//cFilTit	:= U_CP07002G("20", "E2_FILIAL" , "") //Esta linha desposiciona a filial e da erro no tipo
	cFilTit     := xFilial("SE2")
	cPrefixo	:= U_CP07002G("20", "E2_PREFIXO", "")
	cTipo		:= Padr(U_CP07002G("20", "E2_TIPO",    ""),tamsx3("E2_TIPO")[1])
	cCodResu	:= U_CP07002G("20", "E2_CODRESU", "") //| ###GJ |


	IF !EMPTY(cFilTit) .AND. !EMPTY(cTipo)
	
		/*-----------------------------------
		 	Posiciona na Filial
		-----------------------------------*/
		_cCodEmp 	:= SM0->M0_CODIGO
		_cCodFil	:= SM0->M0_CODFIL
		
	//	IF _cCodEmp+_cCodFil <> _cCodEmp+cFilTit
			//CFILANT := cFilTit /* DMS - Este comando estava errado, diposicionando a filial.	Assim batia na SX5 e n„o achava o TIPO */
	//		opensm0(_cCodEmp+CFILANT)
	//	ENDIF
		
		
		//| Busca data de vencimento de acordo com a regra cadastrada 
		//| para o usuario 
		aVencto	:=  Condicao(nValor,cCondPag,0,dDataBase,0)		
		cNumero :=  NumTit(cFilTit, cPrefixo, cTipo)
		cCodReemb := if(Valtype(ZAF->ZAF_CODIGO) == "C",ZAF->ZAF_CODIGO, "" )
		
		AADD(aTitulo,{"E2_PREFIXO" 	,cPrefixo			, Nil})
		AADD(aTitulo,{"E2_NUM"     	,cNumero            , Nil})
		AADD(aTitulo,{"E2_PARCELA" 	,space(TamSx3("E2_PARCELA")[1])	, Nil})
		AADD(aTitulo,{"E2_TIPO"    	,cTipo				, Nil})
		//AADD(aTitulo,{"E2_PORTADO",					, Nil})	
		AADD(aTitulo,{"E2_FORNECE"	,cCodFor			, Nil})	
		AADD(aTitulo,{"E2_LOJA"    	,cLojaFor			, Nil})
		AADD(aTitulo,{"E2_NATUREZ"  ,cCodNat			, Nil})
		AADD(aTitulo,{"E2_EMISSAO"  ,dDatabase          , NIL})		
		AADD(aTitulo,{"E2_VENCTO"	,aVencto[1,1]		, Nil})
		AADD(aTitulo,{"E2_VENCREA"  ,dDatabase          , NIL})
		AADD(aTitulo,{"E2_VALOR"	,nValor			    , Nil})
		AADD(aTitulo,{"E2_CODRESU"  ,cCodResu			, Nil})  //| ###GJ |
		AADD(aTitulo,{"E2_REEMB"    ,cCodReemb			, Nil})  
	
		//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
		//≥Executa o Cancelamento da Baixa do Titulo                         ≥
		//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
		lMsErroAuto	:= .F.
		MSExecAuto({|x,y,z| Fina050(x,y,z)},aTitulo,,3) 
	
		If 	lMsErroAuto   
			cAutoLog	:= alltrim(NOMEAUTOLOG())
			cMemo := STRTRAN(MemoRead(cAutoLog),'"',"")
			cMemo := STRTRAN(cMemo,"'","") 
		                
			//| Apaga arquivo de Log
			Ferase(cAutoLog)     
			
			aRet[2]	:= "Falha ao Gerar Titulo: "+  U_CPXERRO(cMemo)
			//Msginfo("Falha ao Gerar Titulo: "+  U_CPXERRO(cMemo))
		ELSE

			aRet[1]	:= .T.
			// DMS - Diogo Melo 29/09/2021
			dbselectArea("ZAF")
			if ZAF->(dbSeek(xFilial("ZAF")+cCodReemb))
				RecLock("ZAF",.F.)
					Replace ZAF->ZAF_PREFIX with SE2->E2_PREFIXO
					Replace ZAF->ZAF_NUM with SE2->E2_NUM
				MsUnlock()
			endIF
			ZAF->(dbCloseArea())
			//			
			FWAlertSuccess("Titulo com o Prefixo: "+cPrefixo+" e Numero: "+cNumero+" foi gerado com sucesso!","GeraÁ„o de Titulo a Pagar")
		EndIf
		

		 /*-----------------------------------
		 	Restaura Filial
		-----------------------------------*/
		IF _cCodEmp+_cCodFil <> _cCodEmp+cFilTit
			CFILANT := _cCodFil
			opensm0(_cCodEmp+CFILANT)			 			
		ENDIF  			
	ELSE
		aRet[2]	:= "Parametros inv·lidos [E2_FILIAL, E2_PREFIXO, E2_TIPO].[GeraFin]"
	ENDIF
ELSE
	aRet[2]	:= "Parametros inv·lidos [E2_FORNECE, E2_VALOR, E2_NATUREZ, COND.PAGTO].[GeraFin]"
ENDIF



Return(aRet)





/*/{Protheus.doc} NumTit
Busca proximo Numero do Titulo
@author Augusto Ribeiro | www.compila.com.br
@since 10/02/2015
@version 1.0
@param cFilTit, C, Filial do Titulo
@param cPrefixo, C, Prefixo 
@param cTipo, C, Tipo
@return cNumTit, Numero do Titulo
/*/
Static Function NumTit(cFilTit, cPrefixo, cTipo)
Local cRet		:= ""
Local cQuery	:= ""

Default cPrefixo	:= ""

IF !EMPTY(cFilTit) .AND. !EMPTY(cPrefixo)

	cQuery	:= " SELECT ISNULL(MAX(E2_NUM), '') AS E2_NUM "
	cQuery	+= " FROM "+RetSqlName("SE2")+" SE2 "
	cQuery	+= " WHERE E2_FILIAL = '"+cFilTit+"' "
	cQuery	+= " AND E2_PREFIXO = '"+cPrefixo+"' "
	cQuery	+= " AND E2_TIPO = '"+cTipo+"' "
	cQuery	+= " AND SE2.D_E_L_E_T_ = '' "
		
		
	If Select("TNUM") > 0
		TNUM->(DbCloseArea())
	EndIf
	
	DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TNUM",.F., .T.)						
	
	IF TNUM->(!EOF())
		IF EMPTY(TNUM->E2_NUM)
			cRet	:= STRZERO(1,TAMSX3("E2_NUM")[1])
		ELSE 
			cRet	:= SOMA1(TNUM->E2_NUM)
		ENDIF
	ENDIF

	TNUM->(DbCloseArea())

ENDIF



Return(cRet)





/*/{Protheus.doc} AjustSX1
Cria perguntas no SX1
@author Augusto Ribeiro | www.compila.com.br
@since 31/01/2015
@version 1.0
@param cPerg, C, nome da pergunta que ser· criada
/*/
Static Function AjustSX1(cPerg)

Local aArea := GetArea()
Local aHelpPor	:= {}
Local aHelpEng	:= {}
Local aHelpSpa	:= {}

aAdd( aHelpEng, "  ")
aAdd( aHelpSpa, "  ")

aHelpPor := {} ; Aadd( aHelpPor, "Data Despesa De")
xPutSx1( cPerg, "01","Data Despesa De","","","mv_ch1","D",08,0,0,"G","","","","","mv_par01","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa )

aHelpPor := {} ; Aadd( aHelpPor, "Data Despesa Ate")
xPutSx1( cPerg, "02","Data Despesa Ate","","","mv_ch2","D",08,0,0,"G","","","","","mv_par02","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa )

aHelpPor := {} ; Aadd( aHelpPor, "Data AprovaÁ„o De")
xPutSx1( cPerg, "03","Data AprovaÁ„o De","","","mv_ch3","D",08,0,0,"G","","","","","mv_par03","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa )

aHelpPor := {} ; Aadd( aHelpPor, "Data Despesa Ate")
xPutSx1( cPerg, "04","Data AprovaÁ„o Ate","","","mv_ch4","D",08,0,0,"G","","","","","mv_par04","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa )

aHelpPor := {} ; Aadd( aHelpPor, "Informe o CÛdigo do usu·rio.")
xPutSx1( cPerg, "05","Usu·rio de:"	,"","","mv_ch5","C",6,0,0,"G","","ZA0","","","mv_par05","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa )

aHelpPor := {} ; Aadd( aHelpPor, "Informe o CÛdigo do usu·rio.")
xPutSx1( cPerg, "06","Usu·rio atÈ"	,"","","mv_ch6","C",6,0,0,"G","NaoVazio","ZA0","","","mv_par06","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa )
/*
aHelpPor := {} ; Aadd( aHelpPor, "Informe o CÛdigo do Aprovador.")
xPutSx1( cPerg, "07","Aprovador de:"	,"","","mv_ch7","C",6,0,0,"G","","ZA0","","","mv_par07","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa )

aHelpPor := {} ; Aadd( aHelpPor, "Informe o CÛdigo do Aprovador.")
xPutSx1( cPerg, "08","Aprovador atÈ"	,"","","mv_ch8","C",6,0,0,"G","NaoVazio","ZA0","","","mv_par08","","","","","","","","","","","","","","","","",aHelpPor,aHelpEng,aHelpSpa )
*/

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

	// Ajusta o tamanho do grupo. Ajuste emergencial para valida√ß√£o dos fontes.
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


