#Include "Protheus.Ch"
//#Include "rwmake.Ch"
#INCLUDE "TOPCONN.CH"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "FWMBROWSE.CH"      
#INCLUDE 'TBICONN.CH'
#INCLUDE "fileio.ch"

/* - FWMVCDEF
MODEL_OPERATION_INSERT para inclus„o;
MODEL_OPERATION_UPDATE para alteraÁ„o;
MODEL_OPERATION_DELETE para exclus„o.
MODEL_OPERATION_VIEW para visualizacao.
*/


#DEFINE D_PICTURE_VLR "@E 99,999,999.99"
#DEFINE D_PICTURE_VLRT "@E 99,999,999,999.99"


#DEFINE NOME_SEMAFORO "CP09002"


#DEFINE D_TITULO 'ConciliaÁ„o Banc·ria'
#DEFINE D_ROTINA 'CP09002' 

#DEFINE D_PERG "CP09002"
#DEFINE D_PERG2 "CP09002A"


/*--------------------------
	LISTBOX Extrato
---------------------------*/
#DEFINE D_NAOSELECIONADO 0
#DEFINE D_SELECIONADO 1
#DEFINE D_CONCILIADO 2
#DEFINE D_TAXA 3
#DEFINE D_CONCILIADO_AUTO 4



/*--------------------------
	OPCOES RADIO
---------------------------*/
#DEFINE OPCAO_CONCILIACAO 1
#DEFINE OPCAO_TAXA 2



/*------------------------------------------------------ Augusto Ribeiro | 29/12/2016 - 10:26:08 AM
	PAMETROS DE USUABILIDADE
------------------------------------------------------------------------------------------*/
Static lISelec		:= .F.
Static lExecConc	:= .F.
Static cSEDMVPAR	:= ""
Static cCTTMVPAR	:= ""


/*--------------------------
	TOTAIS RODAPE
---------------------------*/
//Static nTotEx	:= 0



/*/{Protheus.doc} CP09002
Conciliador banc·rio
@author Augusto Ribeiro | www.compila.com.br
@since 31/03/2016
@version 6
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
User function CP09002()
Private lSelConc	:= .T.
Private	lSelTaxa	:= .F.

Private oFList		:= TFont():New("Courier New",, 15, , .F., , , , .F., .F.) // Regular
Private nZB2VALOR, nZB2DATA, nZB2RECNO, nZB2DESC, nEXCONCI, nZB2SE5
Private nE5VALOR, nE5DTDISPO, nE5HISTOR, nE5FILIAL, nE5NATUREZ, nE5CCUSTO, nSE5RECNO, nSE5ZB2, nMVCONCI


Private oTotEx, oTotCon, oTotTaxa, oTotMv, cTotalMv, oGetTeste
Private oSelEx, cSelEx, oSelMv, cSelMv, cGetTeste
Private oPaneRod	:= nil
Private aDim		:= {}

Private	nSaldoEx	:= 0 //| Saldo do movimento|
Private	nSaldoMv	:= 0 //| Saldo do movimento|

/*------------------------------------------------------ Augusto Ribeiro | 25/01/2017 - 3:48:38 PM
Variaveis utilizadas no controle de multipla selecoes .
Relacionamento N para N

------------------------------------------------------------------------------------------*/
Private nMarkConc	:= 1 
Private nTotExCon	:= 0
Private nTotMvCon	:= 0


/*--------------------------
	PARAMETROS 
---------------------------*/
Private cpFilDe, cpFilAte, cpBanco, cpAg, cpConta, dpDtMvDe, dpDtMvAte, npTpMov		

/*--------------------------
	LISTBOX EXTRATO
---------------------------*/
Private oLbxEx		:= Nil
Private aCpoEX		:= {}
Private aDadosEx	:= {}
Private aHeadEx		:= {}
Private lVazioEx	:= .T.
//| Variaveis para Ordenacao da coluna|
Private lAllExt		:= .F.
Private nAntExt		:= 0
Private	nDadosEx	:= 0

/*---------------------------------
	LISTBOX MOVIMENTO BANCARIO
----------------------------------*/
Private oLbxMv		:= Nil
Private aCpoMv		:= {}
Private aDadosMv	:= {}
Private aHeadMv		:= {}
Private lVazioMv	:= .T.
//| Variaveis para Ordenacao da coluna|
Private lAllMv		:= .F.
Private nAntMv		:= 0
Private	nDadosMv	:= 0

/*------------------------------------------------------ Augusto Ribeiro | 26/12/2016 - 5:55:21 PM
	Variaveis para controle da seleÁ„o da conciliaÁ„o
------------------------------------------------------------------------------------------*/
Private aSelEx	:= {}
Private aSelMv	:= {} 

Private nTolera	:= 0 //| para consiliaÁao|

Private nConcTaxa := OPCAO_CONCILIACAO //| 1=Concilia, 2=Taxa Selecao de movimento para consiliaÁ„o ou TAXA|

Private nTotEx	:= 0
Private lVazio	:= .F.


/*-------------------------------
	PARAMETROS DE USUABILIDADE
--------------------------------*/
PERGUNTE(D_PERG2,.F.)
lISelec		:= (MV_PAR01==1)
lExecConc	:= (MV_PAR02==1)
cFILMVPAR	:= MV_PAR03
cSEDMVPAR	:= MV_PAR04
cCTTMVPAR	:= MV_PAR05

IF PERGUNTE(D_PERG ,.T.)

	cpFilDe		:= MV_PAR01
	cpFilAte	:= MV_PAR02
	cpBanco		:= MV_PAR03
	cpAg		:= MV_PAR04
	cpConta		:= MV_PAR05
	dpDtMvDe	:= MV_PAR06
	dpDtMvAte	:= MV_PAR07
	npTpMov		:= MV_PAR08


	nSaldoMv	:= SaldoMv(cpBanco, cpAg, cpConta, dpDtMvAte)
	nSaldoEx	:= SaldoEx(cpBanco, cpAg, cpConta, dpDtMvAte)
	
	FWExecView("ConciliaÁ„o Bancaria",  D_ROTINA,  3,  /*oDlg*/,  /*bCloseOnOk*/,  /*bOk*/, /* nPercReducao*/, /*aEnableButtons*/,  /*bCancel*/ )// == 0
	/*
	IF lExecConc
		ConcAuto()
	ENDIF
	IIF(lExecConc, ConcAuto(), .F.)
	*/
ENDIF


Return NIL

        
/*‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥ CP09002  ∫Autor  ≥Augusto Ribeiro     ∫ Data ≥ 07/01/2011  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ 	Botoes do MBrowser                                        ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/  
Static Function MenuDef()
Local aRotina := {}


ADD OPTION aRotina TITLE 'Pesquisar'  ACTION 'PesqBrw'             OPERATION 1 ACCESS 0
ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.'+D_ROTINA OPERATION 2 ACCESS 0                         
ADD OPTION aRotina TITLE 'Incluir'  ACTION 'VIEWDEF.'+D_ROTINA OPERATION 3 ACCESS 0  	
//ADD OPTION aRotina TITLE 'Conciliar Banco'  ACTION 'U_CP902MNU("CONCILIAR")' OPERATION 3 ACCESS 0
//ADD OPTION aRotina TITLE 'Alterar'    ACTION 'VIEWDEF.'+D_ROTINA OPERATION 4 ACCESS 0
//ADD OPTION aRotina TITLE 'Excluir'    ACTION 'VIEWDEF.'+D_ROTINA OPERATION 5 ACCESS 0
ADD OPTION aRotina TITLE 'Imprimir'   ACTION 'VIEWDEF.'+D_ROTINA OPERATION 8 ACCESS 0
//ADD OPTION aRotina TITLE 'Copiar'     ACTION 'VIEWDEF.'+D_ROTINA OPERATION 9 ACCESS 0
//ADD OPTION aRotina TITLE 'TESTE'     ACTION 'U_FAT01TST()' OPERATION 9 ACCESS 0

Return aRotina







/*‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥ CP09002  ∫Autor  ≥Augusto Ribeiro     ∫ Data ≥ 19/11/2013  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ 	Definicoes do Model                                       ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/  
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oStruZB1 := FWFormStruct( 1, 'ZB1', /*bAvalCampo*/,/*lViewUsado*/ )
Local oStruZB2 := FWFormStruct( 1, 'ZB2', /*bAvalCampo*/,/*lViewUsado*/ )

Local oModel   


// Cria o objeto do Mod elo de Dados
oModel := MPFormModel():New(D_ROTINA+'MODEL', /*bPreValidacao*/,   /*bPosValidacao*/,  /*bCommit*/, /*bCancel*/ )
//oModel := MPFormModel():New('ATEC204MODEL', /*bPreValidacao*/, { |oMdl| COMP011POS( oMdl ) }, /*bCommit*/, /*bCancel*/ )

// Adiciona ao modelo uma estrutura de formul·rio de ediÁ„o por campo
oModel:AddFields( 'ZB1ARQUIVO', /*cOwner*/, oStruZB1, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
oModel:AddGrid( 'ZB2EXTRATO', 'ZB1ARQUIVO', oStruZB2,  /*LINPRE*/, /*LINPOS*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )


// Faz relaciomaneto entre os compomentes do model                                                                           
oModel:SetRelation( 'ZB2EXTRATO',		{{ 'ZB2_FILIAL', 'XFILIAL("ZB2")' }, { 'ZB2_CODARQ', 'ZB1_CODIGO' } }, ZB2->(IndexKey(3)) ) //| ZB2_FILIAL+ZB2_CODARQ+ZB2_CODIGO 
 


// Indica que È opcional ter dados informados na Grid
 //oModel:GetModel( 'ZB1ARQUIVO' ):SetOptional(.T.) //| Removido ServiÁos Executados - Sol. Adriano
 //oModel:GetModel( 'ZB2EXTRATO' ):SetOptional(.T.) //| Removido ServiÁos Executados - Sol. Adriano
  

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription(D_TITULO)

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'ZB1ARQUIVO' ):SetDescription( 'Arquivo' )
oModel:GetModel( 'ZB2EXTRATO' ):SetDescription( 'Extrato' )      


/// oModel:GetModel( 'ZA6SERV' ):SetDescription( 'ServiÁos' ) //| Removido ServiÁos Executados - Sol. Adriano
      
// Liga a validaÁ„o da ativacao do Modelo de Dados
//oModel:SetVldActivate( { |oModel,cAcao| U_FAT01VLD('MODEL_ACTIVE', oModel) } )

oModel:SetActivate( {|oModel| SetKey ( VK_F5, {||  U_CP901BTN('EFETIVA') } ),;
								SetKey ( VK_F8, {||  U_CP901BTN('MOV_BANC') } ),;
								SetKey ( VK_F9, {||  U_CP901BTN('GERA_RA') } ),;
								SetKey ( VK_F10, {||  U_CP901BTN('PERG_CONC') } ),;
								SetKey ( VK_F11, {|| U_CP901BTN('TRANSF')} ) }) //,U_CP701ZA3(oModel)} )

Return oModel


/*‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥ CP09002  ∫Autor  ≥Augusto Ribeiro     ∫ Data ≥ 07/01/2011  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ 	Definicoes da View                                        ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/  
Static Function ViewDef()
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   := FWLoadModel( D_ROTINA )
// Cria a estrutura a ser usada na View
Local oStruZB1 := FWFormStruct( 2, 'ZB1' )
Local oStruZB2 := FWFormStruct( 2, 'ZB2' )
Local oView   

//Local oStruCSW := FWFormStruct( 1, 'CSW', /*bAvalCampo*/, /*lViewUsado*/ ) 
//Local oModel
                                   

//oStruCSW:RemoveField( 'CSW_ENT' )
                        
// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados ser· utilizado
oView:SetModel( oModel )

//oView:AddField( 'VIEW_ZB1', oStruZB1, 'ZB1ARQUIVO' )
//oView:AddGrid( 'VIEW_ZB2', oStruZB2, 'ZB2EXTRATO' )
				

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'SUPERIOR'	, 85 )
oView:CreateHorizontalBox( 'INFERIOR'	, 15) 	  

oView:CreateVerticalBox( 'LEFT_SUP'		, 50,'SUPERIOR')
oView:CreateVerticalBox( 'RIGHT_SUP'	, 50,'SUPERIOR')


oView:AddOtherObject("EXTRATO"		, {|oPanel| U_CP902LEX("C",@oLbxEx,@aCpoEx,@aHeadEx, @aDadosEx, oPanel)  })
oView:AddOtherObject("MOVIMENTO"	, {|oPanel| U_CP902LMV("C",@oLbxMv,@aCpoMv,@aHeadMv, @aDadosMv, oPanel)  })


// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'EXTRATO', 'LEFT_SUP')
oView:SetOwnerView( 'MOVIMENTO', 'RIGHT_SUP')

//CP902LEX
//CP902LMV

// Define campos que terao Auto Incremento
//oView:AddIncrementField( 'VIEW_ZEH', 'ZEH_CODITE' )

oView:AddOtherObject("RODAPE", {|oPanel| ListTot(oPanel)})
oView:SetOwnerView("RODAPE",'INFERIOR')



// Criar novo botao na barra de botoes no antigo Enchoice Bar            
oView:AddUserButton( 'Parametros de Filtro.', 'Parametros Filtro', { |oView| U_CP901BTN('PERG_FILTRO', oView) } )
oView:AddUserButton( 'Parametros do Conciliador. F10', 'Parametros Conciliador (F12) ', { |oView| U_CP901BTN('PERG_CONC', oView) } )
oView:AddUserButton( 'Conc. Autom·tica', 'Conc. Autom·tica', { |oView| U_CP901BTN('CONC_AUTO', oView) } )
oView:AddUserButton( 'Transferencia Mov. Bancario. F11', 'Transferencia', { |oView| U_CP901BTN('TRANSF', oView) } )
oView:AddUserButton( 'Efetivar ConciliaÁ„o. F5', 'Efetivar ConciliaÁ„o', { |oView| U_CP901BTN('EFETIVA', oView) } )
oView:AddUserButton( 'Movimenta Bancaria. F8', 'Movimenta Bancaria', { |oView| U_CP901BTN('MOV_BANC', oView) } )

oView:AddUserButton( 'FunÁıes Contas a Pagar', 'FunÁıes Contas a Pagar', { |oView| U_CP901BTN('FCP', oView) } )
oView:AddUserButton( 'FunÁıes Contas a Receber', 'FunÁıes Contas a Receber', { |oView| U_CP901BTN('FCR', oView) } )

oView:AddUserButton( 'Gerar RA. F9', 'Gerar RA', { |oView| U_CP901BTN('GERA_RA', oView) } )

//oView:AddUserButton( 'Parametros do Conciliador', 'Parametros', { |oView| U_CP901BTN('PARAMETROS', oView) } )

//oView:AddUserButton( 'Gera calendario', 'CALENDARIO', { |oView| ALTER("TESTE") } )

// Liga a identificacao do componente
//oView:EnableTitleView('VIEW_ZEG','Lote de Faturamento')
//oView:EnableTitleView('VIEW_ZEH','Itens do Lote')
//oView:EnableTitleView('LEFT_SUP', "Extrato Banc·rio")
//oView:EnableTitleView('RIGHT_SUP', "Movimento Banc·rio")
//oView:EnableTitleView('VIEW_ZB2')
	
	
	// Liga a EdiÁ„o de Campos na FormGrid
	//oView:SetViewProperty( 'VIEW_ZA5'		, "ENABLEDGRIDDETAIL", { 60 } )   


//oView:SetFieldAction(  'ZEG_DTINI',  {  |oView,  cIDView,  cField,  xValue| FAction(  oView,  cIDView, cField, xValue ) } )

//oView:SetCloseOnOk({||.T.})
  
  //oView:SetViewAction( 'REFRESH', {|| IIF(lExecConc, ConcAuto(), .F.), lExecConc := .F., .T.})
 // oView:Refresh()
 
 	//oView:SetViewAction( 'REFRESH' ,{ |oView| alert("teste") } )
Return oView


/*/{Protheus.doc} CP902LEX
Montas Listbox com dados do EXTRATO
@author Augusto Ribeiro | www.compila.com.br
@since 26/12/2016
@version 6
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
User Function CP902LEX(cOpcList, oLbxEx, aCpoHeader, aHeader, aDados, oPanel )
Local lRet			:= .T.
Local aVlrCor		:= {} 


Private aCpoHeader

Default	cOpcList	:= "C"

Default aCpoHeader	:= {} 
Default aHeader		:= {} 
Default aDados		:= {}

Default	oLbxEx		:= NIL
Default	oPanel		:= NIL

//IF cOpcList	== "A"
	aRetAux	:= qExtrato() 
	aDadosEx	:= {}
	//IF aRetAux[1]
		aCpoEX		:= aRetAux[2]
		aHeadEx	:= aRetAux[3]
		aDadosEx	:= aRetAux[4]
		//nDadosEx	:= len(aDadosEx[1])


			
		lRet	:= .T.
	
	//ELSE
		//Help(" ",1,"VAZIO",,"N„o existem registros no periodo selecionado.",4,5)
		//lVazio := .t.
	//	ENDIF




aCpoHeader		:= aCpoEX
aHeader			:= aHeadEx
aDados			:= aDadosEx
//aDadosLbx		:= aClone(aDadoTit)	

	lVazioEx := empty(aDadosEx)

	MontLis(cOpcList, @oLbxEx, @aCpoHeader, @aHeader, @aDados, @oPanel)

Return()


/*/{Protheus.doc} MontLis
Monta Interface de seleÁ„o
@author Jonatas Oliveira | www.compila.com.br
@since 14/04/2016
@version 1.0
/*/
Static Function MontLis(cOpcList, oLbxEx, aCpoHeader, aHeader, aDados, oPanel)

	Local cBCodLin		:= ""   
	Local oOk 	     	:= LoadBitmap( GetResources(), "LBOK" )
	Local oNo   	   	:= LoadBitmap( GetResources(), "LBNO" )
	Local oVerde   	   	:= LoadBitmap( GetResources(), "BR_VERDE" )
	Local oAmarelo   	:= LoadBitmap( GetResources(), "BR_AMARELO" )
	Local oAzul   		:= LoadBitmap( GetResources(), "BR_AZUL" )
	Local oCinza   	   	:= LoadBitmap( GetResources(), "BR_CINZA" )
	Local oBranco   	:= LoadBitmap( GetResources(), "BR_BRANCO" )
	Local oFLabels 		:= TFont():New("Verdana",,018,,.T.,,,,,.F.,.F.)
	Local oFGrpCpo 		:= TFont():New("Verdana",,016,,.F.,,,,,.F.,.F.)
	Local nI

	Private oDlgMain	:= NIL

	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	//≥ cOpcList | C = Cria, A = Atualiza ≥
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	IF cOpcList == "C"
	
		

		@ 3, 5 SAY oLblSolicita PROMPT "Extrato" SIZE 50, 012 OF oPanel FONT oFLabels COLORS RGB(56,141,191), 16777215 PIXEL
		@ 12,0 LISTBOX oLbxEx FIELDS HEADER ;
		FONT oFList;   
		" ", "Campos" ;                                                                                                    
		SIZE (oPanel:nClientWidth/2)-5,(oPanel:nClientHeight/2)-12 OF oPanel PIXEL ON  dblClick(SelEx(@oLbxEx), ListTot(), oLbxEx:Refresh())

		oLbxEx:aheaders := aHeader			   
		oLbxEx:BHEADERCLICK	:= { |oObj,nCol| OrdExt( oObj,nCol, .T.) }		
	ENDIF
	
	/*
	@  250, 40 		SAY oLblSolicita PROMPT "Total " 		SIZE 50, 014 OF oDlgMain FONT oFGrpCpo COLORS 128, 16777215 PIXEL
	oTotalP := TGet():Create( oDlgMain,{|| CalcTot("TP", @aDadoMain)},250, 40	, 050,009,D_PICTURE_VLRT,,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,cTotalP,,,, )
	*/
	IF EMPTY(aDados)
		aDados	:= {{}}
		aadd(aDados[1], .F.)
		aadd(aDados[1], 0)
		
		FOR nI := 3 to len(aHeader)
			aadd(aDados[1], '')
		NEXT nI
	ENDIF   
	
		oLbxEx:nAt	:= 1
	
		oLbxEx:SetArray( aDados )  
		//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
		//≥ Cria string com Bloco de Codigo ≥
		//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
		//	cBCodLin	:= "LoadBitmap( GetResources(), aDados[oLbxEx:nAt,"+alltrim(str(nP04STATUS))+"] ) "
		
		/*
		#DEFINE D_NAOSELECIONADO 0
		#DEFINE D_SELECIONADO 1
		#DEFINE D_CONCILIADO 2
		#DEFINE D_TAXA 3
		#DEFINE D_CONCILIADO_AUTO 4
		*/
		//oAzul
		
	
		cBCodLin	:= "Iif(aDados[oLbxEx:nAt,1],oOk,oNo), Iif(aDados[oLbxEx:nAt,2]==2,oVerde,Iif(aDados[oLbxEx:nAt,2]==3,oAzul, Iif(aDados[oLbxEx:nAt,2]==1,oAmarelo , Iif(aDados[oLbxEx:nAt,2]==4, oBranco, oCinza))))"
		//cBCodLin	:= "IIF(ALLTRIM(aDados[oLbxEx:nAt,nP04STATUS]) == alltrim(X3COMBO('P04_STATUS','4')), oNo, Iif(aDados[oLbxEx:nAt,1],oOk,oNo))"
	
	
		For nI := 3 To LEN(aHeader)
			IF nI > 1
				cBCodLin	+=", "
			endif
			cI	:= alltrim(str(nI))
			
			IF ALLTRIM(aCpoHeader[nI]) $ "ZB2_VALOR"
				cBCodLin	+= "Transform(aDados[oLbxEx:nAt,"+cI+"], '"+D_PICTURE_VLR+"')"
			ELSE
				cBCodLin	+= "aDados[oLbxEx:nAt,"+cI+"]"		
			ENDIF
			
		Next nI	
	
		
	
		cBCodLin	:= "oLbxEx:bLine := {|| {"+cBCodLin+"}}"
		&(cBCodLin)    
	     


	oLbxEx:Refresh()

Return    






/*/{Protheus.doc} qExtrato
Busca registros do extrato que ainda n„o foram conciliados
@author Augusto Ribeiro | www.compila.com.br
@since 16/04/2016
@version 6
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function qExtrato()
Local aCpoHeader	:= {} 
Local aHeader		:= {} 
Local aDados		:= {}
Local aRet			:= {.F., aCpoHeader, aHeader, aDados}
//Local cAbatim		:= alltrim(MVABATIM) + "|" + alltrim(MVRECANT) + "|" + alltrim(MV_CRNEG)
Local nCpoQry		:= 0
Local nY, nI
Local cQuery		:= ""
Local cDigConta		:= ""


cQuery	:= " SELECT ZB2_DATA, ZB2_VALOR, ZB2_DESC, ZB2.R_E_C_N_O_ AS  ZB2_RECNO "+CRLF
cQuery	+= " FROM "+RetSqlName("ZB2")+" ZB2 "+CRLF
cQuery	+= " WHERE ZB2_DATA BETWEEN '"+DTOS(dpDtMvDe)+"' AND '"+DTOS(dpDtMvAte)+"' "+CRLF
cQuery	+= " AND ZB2_BANCO = '"+cpBanco+"' "+CRLF

cQuery	+= " AND ZB2_AGENC = '"+cpAg+"' "+CRLF
cQuery	+= " AND ZB2_CONTA =  '"+cpConta+"' "+CRLF

//cQuery	+= " AND ZB2_AGENC = '"+PADL(MV_PAR02,"0",TAMSX3("ZB2_AGENC")[1])+"' "+CRLF
//cQuery	+= " AND ZB2_CONTA =  '"+PADL(MV_PAR03,"0",TAMSX3("ZB3_AGENC")[1])+"' "+CRLF
cQuery	+= " AND ZB2_DTCONC = '' "+CRLF

IF MV_PAR08 == 1	
	cQuery += " AND ZB2_VALOR > 0 "+CRLF
ELSEIF MV_PAR08 == 2
	cQuery += " AND ZB2_VALOR < 0"+CRLF	
ENDIF

cQuery	+= " AND ZB2.D_E_L_E_T_ = '' "+CRLF

MemoWrite(GetTempPath(.T.) + "CP09002_qExtrato.SQL", cQuery)

If Select("TQRY") > 0
	TQRY->(DbCloseArea())
EndIf

dbUseArea(.T.,"TOPCONN",TCGenQRY(,,cQuery),'TQRY')

TCSetField("TQRY","ZB2_DATA","D",08,00)

nCpoQry	:= TQRY->(FCOUNT()) 

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Monta aHeader ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ 
aadd(aHeader,"")
aadd(aHeader,"")                      
aadd(aCpoHeader,"MARK")
aadd(aCpoHeader,"LEGENDA")
For nY := 1 To nCpoQry-1   
/*
	IF QRY->(FieldName(nY)) == "VLRCORR"	     
		aadd(aHeader,"Valor Corrigido")	
		aadd(aCpoHeader,FieldName(nY))
	ELSEIF QRY->(FieldName(nY)) == "VLRMUL"
		aadd(aHeader,"Valor Multa")	
		aadd(aCpoHeader,FieldName(nY))
	ELSEIF QRY->(FieldName(nY)) == "VLRJUR"
		aadd(aHeader,"Valor Juros")	
		aadd(aCpoHeader,FieldName(nY))
	ELSEIF QRY->(FieldName(nY)) == "CNPJZTX"
		aadd(aHeader,"CNPJ Zatix")	
		aadd(aCpoHeader,FieldName(nY))				
	ELSEIF QRY->(FieldName(nY)) == "BANCO"
		aadd(aHeader,"Banco")	
		aadd(aCpoHeader,FieldName(nY))
	ELSE
	*/
	
		aadd(aHeader,ALLTRIM(RetTitle(FieldName(nY))))	
		aadd(aCpoHeader,FieldName(nY))
	//ENDIF 
Next nY	
aadd(aCpoHeader, "ZB2_RECNO")
aadd(aCpoHeader, "EXCONCI")


//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Variaveis de posionamento dos campos ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
nZB2VALOR		:=  Ascan(aCpoHeader,"ZB2_VALOR")
nZB2DATA		:=  Ascan(aCpoHeader,"ZB2_DATA")
nZB2DESC		:=  Ascan(aCpoHeader,"ZB2_DESC")
nZB2RECNO		:=  Ascan(aCpoHeader,"ZB2_RECNO")
nEXCONCI		:=  Ascan(aCpoHeader,"EXCONCI")


/*
nP04STATUS	:=  Ascan(aCpoHeader,"P04_STATUS")    
nP04ARQUIV	:=  Ascan(aCpoHeader,"P04_ARQUIV")
nP04RECNO	:=  Ascan(aCpoHeader,"P04_RECNO") 
*/

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Monta aDados ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ 
IF TQRY->(!EOF())

	
	
	
	WHILE TQRY->(!EOF())
	
		aLinha	:= {}
		aadd(aLinha, .F.) //|MARK|
		aadd(aLinha, 0) //| LEGENDA|
		For nY := 1 To nCpoQry      
			aadd(aLinha, TQRY->(FIELDGET(nY)))
		Next nY	 
		aadd(aLinha, 0) //| EXCONCI |
		
		
		AADD(aDados, aLinha)
	

		TQRY->(DBSKIP())
	ENDDO   
	
	//nZB2RECNO	:= LEN(aDados[1])

	
	aRet[1]	:= .T.
	aRet[2]	:= aCpoHeader
	aRet[3]	:= aHeader
	aRet[4]	:= aDados

ELSE
 	aRet[1]	:= .F.
ENDIF                  

TQRY->(DbCloseArea())

Return (aRet)






/*‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥ OrdExt   ∫Autor  ≥ Augusto Ribeiro	 ∫ Data ≥  12/03/11   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥  Orderna Coluna que o usuario realizar o click ou          ∫±±
±±∫          ≥Marca/Desmarca todos os registros selecionados              ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/
Static Function OrdExt(oLbxAux, nCol, lMark)
Local nI 
	Default lMark	:= .F.

	//lMarkAll	:= .F. 
	
	If	nCol > 0

		//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
		//≥ Marca/Desmarca Registrios ≥
		//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
		If nCol == 1
			//IF  nConcTaxa == OPCAO_TAXA //| tAXA|
				lAllExt	:= !(lAllExt)
				
				FOR nI :=  1 TO LEN(oLbxAux:aArray)
					IF lAllExt <> oLbxAux:aArray[nI,1]
						oLbxAux:nAt	:= nI
						SelEx(@oLbxAux)
					ENDIF
				Next nY
	
				//aEval(oLbxAux:aArray, {|x| x[1] := lAllExt} )
				nAntExt := nCol
			//endif

			//oTotal:Refresh()
			//oTotSel:Refresh()
			//oTotalP:Refresh()
			//oTotSelP:Refresh()
		ELSEIF nCol == nAntExt
			aSort(oLbxAux:aArray,,,{ |x,y| x[nCol] < y[nCol] })
			nAntExt := 0
		Else
			aSort(oLbxAux:aArray,,,{ |x,y| x[nCol] > y[nCol] })
			nAntExt := nCol
		EndIf

		oLbxAux:Refresh()

	EndIf

Return()



/*/{Protheus.doc} CP902LMV
Montas Listbox com dados do Movimento Bancario
@author Augusto Ribeiro | www.compila.com.br
@since 26/12/2016
@version 6
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
User Function CP902LMV(cOpcList, oLbxMv, aCpoHeader, aHeader, aDados, oPanel )
Local lRet			:= .T.
Local aVlrCor		:= {} 


Private aCpoHeader

Default	cOpcList	:= "C"

Default aCpoHeader	:= {} 
Default aHeader		:= {} 
Default aDados		:= {}

Default	oLbxMv		:= NIL
Default	oPanel		:= NIL


//IF cOpcList	== "A"
	aRetAux		:= qMovimen() 
	aDadosMv	:= {}
	//IF aRetAux[1]
		aCpoMv		:= aRetAux[2]
		aHeadMv		:= aRetAux[3]
		aDadosMv	:= aRetAux[4]
		nDadosMv	:= 0
		IF !EMPTY(aDadosMv)
			nDadosMv	:= len(aDadosMv[1])
		ENDIF

			
		lRet	:= .T.
	
	//ELSE
		//Help(" ",1,"VAZIO",,"N„o existem registros no periodo selecionado.",4,5)
		//lVazio	:= .T.
	//ENDIF




aCpoHeader		:= aCpoMV
aHeader			:= aHeadMV
aDados			:= aDadosMV
//aDadosLbx		:= aClone(aDadoTit)	
lVazioMv := empty(aDadosMv)

ListMov(cOpcList, @oLbxMv, @aCpoHeader, @aHeader, @aDados, @oPanel)
IF !(lVazioMv) .AND. !(lVazioEx) 
	
	/*
	IF VALTYPE(oLbxEx) == "O"
		oLbxEx:lVisibleControl := .T.
	ENDIF	
	IF VALTYPE(oLbxMv) == "O"
		oLbxMv:lVisibleControl := .T.
	ENDIF	
	*/
ELSE
/*
	IF VALTYPE(oLbxEx) == "O"
		oLbxEx:lVisibleControl := .F.
	ENDIF	
	IF VALTYPE(oLbxMv) == "O"
		oLbxMv:lVisibleControl := .F.
	ENDIF
*/
ENDIF 

Return()


/*/{Protheus.doc} MontLis
Monta Interface de seleÁ„o
@author Jonatas Oliveira | www.compila.com.br
@since 14/04/2016
@version 1.0
/*/
Static Function ListMov(cOpcList, oLbxMv, aCpoHeader, aHeader, aDados, oPanel)

	Local cBCodLin		:= ""   
	Local oOk 	     	:= LoadBitmap( GetResources(), "LBOK" )
	Local oNo   	   	:= LoadBitmap( GetResources(), "LBNO" )
	Local oVerde   	   	:= LoadBitmap( GetResources(), "BR_VERDE" )
	Local oAmarelo   	:= LoadBitmap( GetResources(), "BR_AMARELO" )
	Local oAzul   		:= LoadBitmap( GetResources(), "BR_AZUL" )
	Local oCinza   	   	:= LoadBitmap( GetResources(), "BR_CINZA" )
	Local oBranco   	:= LoadBitmap( GetResources(), "BR_BRANCO" )
	Local oFLabels 		:= TFont():New("Verdana",,018,,.T.,,,,,.F.,.F.)
	Local oFGrpCpo 		:= TFont():New("Verdana",,016,,.F.,,,,,.F.,.F.)
	Local nI
	
	Private oDlgMain	:= NIL
	

	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	//≥ cOpcList | C = Cria, A = Atualiza ≥
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	IF cOpcList == "C"
	
		

		@ 3, 5 SAY oLblSolicita PROMPT "Sistema" SIZE 50, 012 OF oPanel FONT oFLabels COLORS RGB(56,141,191), 16777215 PIXEL
		@ 12,0 LISTBOX oLbxMv FIELDS HEADER ;
		" ", "Campos" ;   
		FONT oFList;                                                                                                 
		SIZE (oPanel:nClientWidth/2)-5,(oPanel:nClientHeight/2)-12 OF oPanel PIXEL ON  dblClick()

		oLbxMv:aheaders := aHeader			   
		oLbxMv:BHEADERCLICK	:= { |oObj,nCol|  OrdMv( oObj,nCol, .T.) }	
		
		//oLbxMv:bLDblClick := { |nRow,nCol,nFlags| EditLBoxCBox(@oLbxMv) }	
		oLbxMv:bLDblClick := { |nRow,nCol,nFlags| dbClickMv(@nRow,@nCol,@nFlags) }
		
				
	ENDIF
	
	IF EMPTY(aDados)
		aDados	:= {{}}
		aadd(aDados[1], .F.)
		aadd(aDados[1], 0)
		
		FOR nI := 3 to len(aCpoMv)
		
			IF EMPTY(RetTitle(aCpoMv[nI]))
				xVlrAux	:= 0
			ELSE
				xVlrAux	:= CRIAVAR(aCpoMv[nI],.F.)
			ENDIF
			aadd(aDados[1], xVlrAux)
		NEXT nI
	ENDIF   
	
		
	oLbxMv:nAt	:= 1
	
	

	/*
	@  250, 40 		SAY oLblSolicita PROMPT "Total " 		SIZE 50, 014 OF oDlgMain FONT oFGrpCpo COLORS 128, 16777215 PIXEL
	oTotalP := TGet():Create( oDlgMain,{|| CalcTot("TP", @aDadoMain)},250, 40	, 050,009,D_PICTURE_VLRT,,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,cTotalP,,,, )
	*/
	oLbxMv:SetArray( aDados )  
	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	//≥ Cria string com Bloco de Codigo ≥
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	//cBCodLin	:= "Iif(aDados[oLbxMv:nAt,1],oOk,oNo)" //", Iif(aDados[oLbxMv:nAt,2]==2,oVerde,Iif(aDados[oLbxMv:nAt,2]==1,oAmarelo ,oCinza))"
	cBCodLin	:= "Iif(aDados[oLbxMv:nAt,1],oOk,oNo), Iif(aDados[oLbxMv:nAt,2]==2,oVerde,Iif(aDados[oLbxMv:nAt,2]==3,oAzul, Iif(aDados[oLbxMv:nAt,2]==1,oAmarelo , Iif(aDados[oLbxMv:nAt,2]==4, oBranco, oCinza))))"		
	

	For nI := 3 To LEN(aHeader)
		IF nI > 1
			cBCodLin	+=", "
		endif
		cI	:= alltrim(str(nI))
		
		IF ALLTRIM(aCpoHeader[nI]) $ "E5_VALOR"
			cBCodLin	+= "Transform(aDados[oLbxMv:nAt,"+cI+"], '"+D_PICTURE_VLR+"')"
		ELSE
			cBCodLin	+= "aDados[oLbxMv:nAt,"+cI+"]"		
		ENDIF
		
	Next nI	

	cBCodLin	:= "oLbxMv:bLine := {|| {"+cBCodLin+"}}"
	&(cBCodLin)            

	
	oLbxMv:Refresh()

Return    






/*/{Protheus.doc} qMovimen
Busca registros da movimentaÁ„o Banc·ria
@author Augusto Ribeiro | www.compila.com.br
@since 16/04/2016
@version 6
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function qMovimen()
Local aCpoHeader	:= {} 
Local aHeader		:= {} 
Local aDados		:= {}
Local aRet			:= {.F., aCpoHeader, aHeader, aDados}
//Local cAbatim		:= alltrim(MVABATIM) + "|" + alltrim(MVRECANT) + "|" + alltrim(MV_CRNEG)
Local nCpoQry		:= 0
Local nY, nI
Local cQuery		:= "" 


cQuery := " SELECT  E5_DTDISPO,  "+CRLF
cQuery += " 	CASE WHEN E5_RECPAG = 'R' THEN E5_VALOR ELSE E5_VALOR*-1 END AS E5_VALOR,  "+CRLF
cQuery += " 	E5_HISTOR, E5_FILIAL, E5_NATUREZ, E5_CCUSTO, SE5.R_E_C_N_O_ as SE5_RECNO "+CRLF
cQuery += " FROM "+RetSqlName("SE5")+" SE5 "+CRLF
cQuery += " WHERE E5_FILIAL BETWEEN '"+cpFilDe+"' AND '"+cpFilAte+"' "
cQuery += " AND E5_DTDISPO BETWEEN '"+DTOS(dpDtMvDe)+"' AND '"+DTOS(dpDtMvAte)+"' "+CRLF
cQuery += " AND E5_BANCO = '"+cpBanco+"' "+CRLF
cQuery += " AND E5_AGENCIA = '"+cpAg+"' "+CRLF
cQuery += " AND E5_CONTA = '"+cpConta+"' "+CRLF
//cQuery += " AND E5_TIPODOC NOT IN ('JR','DC') "+CRLF
cQuery += " AND (E5_TIPODOC NOT IN ('JR','DC','MT','')  OR  ( (E5_TIPODOC = '' AND E5_LOTE = ''))) "+CRLF
cQuery += " AND E5_RECONC ='' "+CRLF
cQuery += " AND E5_SITUACA <> 'C' "+CRLF
cQuery += " AND UPPER(E5_HISTOR) NOT LIKE 'BX RET CNAB LOTE:%' "+CRLF
IF MV_PAR08 == 1
	cQuery += " AND E5_RECPAG = 'R' "+CRLF
ELSEIF MV_PAR08 == 2
	cQuery += " AND E5_RECPAG = 'P' "+CRLF	
ENDIF
cQuery += " AND D_E_L_E_T_ = '' "+CRLF
cQuery += " ORDER BY E5_DATA, SE5.R_E_C_N_O_ "+CRLF


MemoWrite(GetTempPath(.T.) + "CP09002_qMovimen.SQL", cQuery)	

If Select("TQRY") > 0
	TQRY->(DbCloseArea())
EndIf

dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),'TQRY')

TCSetField("TQRY","E5_DTDISPO","D",08,00)

nCpoQry	:= TQRY->(FCOUNT()) 

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Monta aHeader ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ 
aadd(aHeader,"")
aadd(aHeader,"")                      
aadd(aCpoHeader,"MARK")
aadd(aCpoHeader,"LEGENDA")
//aadd(aCpoHeader,"")
For nY := 1 To nCpoQry-1   
/*
	IF QRY->(FieldName(nY)) == "VLRCORR"	     
		aadd(aHeader,"Valor Corrigido")	
		aadd(aCpoHeader,FieldName(nY))
	ELSEIF QRY->(FieldName(nY)) == "VLRMUL"
		aadd(aHeader,"Valor Multa")	
		aadd(aCpoHeader,FieldName(nY))
	ELSEIF QRY->(FieldName(nY)) == "VLRJUR"
		aadd(aHeader,"Valor Juros")	
		aadd(aCpoHeader,FieldName(nY))
	ELSEIF QRY->(FieldName(nY)) == "CNPJZTX"
		aadd(aHeader,"CNPJ Zatix")	
		aadd(aCpoHeader,FieldName(nY))				
	ELSEIF QRY->(FieldName(nY)) == "BANCO"
		aadd(aHeader,"Banco")	
		aadd(aCpoHeader,FieldName(nY))
	ELSE
	*/
	
		aadd(aHeader,ALLTRIM(RetTitle(FieldName(nY))))	
		aadd(aCpoHeader,FieldName(nY))
	//ENDIF 
Next nY	
aadd(aCpoHeader,"SE5_RECNO")
aadd(aCpoHeader,"SE5ZB2")
aadd(aCpoHeader,"MVCONCI")


//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Variaveis de posionamento dos campos ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
nE5DTDISPO		:=  Ascan(aCpoHeader,"E5_DTDISPO")
nE5VALOR		:=  Ascan(aCpoHeader,"E5_VALOR")
nE5HISTOR		:=  Ascan(aCpoHeader,"E5_HISTOR")
nE5FILIAL		:=  Ascan(aCpoHeader,"E5_FILIAL")
nE5NATUREZ		:=  Ascan(aCpoHeader,"E5_NATUREZ")
nE5CCUSTO		:=  Ascan(aCpoHeader,"E5_CCUSTO")

nSE5RECNO		:=  Ascan(aCpoHeader,"SE5_RECNO")
nSE5ZB2			:=  Ascan(aCpoHeader,"SE5ZB2")

nMVCONCI		:=  Ascan(aCpoHeader,"MVCONCI")


//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Monta aDados ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ 
IF TQRY->(!EOF())

	
	
	
	WHILE TQRY->(!EOF())
	
		aLinha	:= {}
		aadd(aLinha, .F.)
		aadd(aLinha, 0) //| LEGENDA|
		For nY := 1 To nCpoQry      
			aadd(aLinha, TQRY->(FIELDGET(nY)))
		Next nY	 
		
		/*------------------------------------------------------ Augusto Ribeiro | 27/12/2016 - 11:19:35 AM
			Ultimo registro indica o RECNO do extrato 
			no qual esta vinculado
		------------------------------------------------------------------------------------------*/
		aadd(aLinha, 0) // SE5ZB2
		aadd(aLinha, 0) //| MVCONCI |
		
		AADD(aDados, aLinha)
	

		TQRY->(DBSKIP())
	ENDDO   

	//nSE5ZB2 	:= len(aDados[1])
	//nSE5RECNO	:= nSE5ZB2-1

		
	
	aRet[1]	:= .T.
	aRet[2]	:= aCpoHeader
	aRet[3]	:= aHeader
	aRet[4]	:= aDados

ELSE
 	aRet[1]	:= .F.
ENDIF                  


Return (aRet)




/*/{Protheus.doc} OrdMv
Orderna Coluna que o usuario realizar o click ou  Marca/Desmarca todos os registros selecionados  
@author aribeiro
@since 12/03/2011
@version 6
@example
(examples)
@see (links_or_references)
/*/
Static Function OrdMv(oLbxAux, nCol, lMark)
Local nI	:= 0
Default lMark	:= .F.


	Processa({ || OrdMvP( oLbxAux,nCol, lMark)}, "Selecionando Registros..." )
	
Return()

/*/{Protheus.doc} OrdMvP
(long_description)
@author Augusto Ribeiro | www.compila.com.br
@since 12/01/2018
@version version
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/	
Static Function OrdMvP(oLbxAux, nCol, lMark)
Local nI	:= 0
Default lMark	:= .F.

	
	//lMarkAll	:= .F. 
	
	If	nCol > 0

		//-------------------------------
		//  Marca/Desmarca Registrios 
		//-------------------------------
		If nCol == 1
		
			ProcRegua(LEN(oLbxAux:aArray))  
			
		
			IF  nConcTaxa == OPCAO_CONCILIACAO 
				lAllMv	:= !(lAllMv)
				
				FOR nI :=  1 TO LEN(oLbxAux:aArray)
				
					IncProc("Selecionando.. ")
				
					IF lAllMv <> oLbxAux:aArray[nI,1]
						oLbxAux:nAt	:= nI
						//SelEx(@oLbxAux)
						dbClickMv(nI,1)
					ENDIF
				Next nY
	
				//aEval(oLbxAux:aArray, {|x| x[1] := lAllExt} )
				nAntExt := nCol
			endif		
		
		
		ELSEIF nCol == nAntMv
			aSort(oLbxAux:aArray,,,{ |x,y| x[nCol] < y[nCol] })
			nAntMv := 0
		Else
			aSort(oLbxAux:aArray,,,{ |x,y| x[nCol] > y[nCol] })
			nAntMv := nCol
		EndIf

		oLbxAux:Refresh()


	EndIf

Return()


/*/{Protheus.doc} SelEx
Double Click Extrato
@author Augusto Ribeiro | www.compila.com.br
@since 26/12/2016
@version version
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function SelEx(oLbxAux)
Local nPosAux, nI
Local nMarkAnt	:= 0

IF !(lVazioEx)
	/*-----------------------------
		CONCILIACAO DE MOVIMENTOS
	------------------------------*/
	IF nConcTaxa == OPCAO_CONCILIACAO .AND. aDadosEx[oLbxAux:nAt,2] <> D_TAXA
		
		
		/*--------------------------
			REMOVENDO SELECAO
		---------------------------*/
		IF aDadosEx[oLbxAux:nAt,1]
			IF aDadosEx[oLbxAux:nAt,2] == D_CONCILIADO .OR.  aDadosEx[oLbxAux:nAt,2] == D_CONCILIADO_AUTO
				nMarkAnt	:= aDadosEx[oLbxAux:nAt,nEXCONCI]
			ENDIF
		 	aDadosEx[oLbxAux:nAt,1] 		:= .F.
		 	aDadosEx[oLbxAux:nAt,2] 		:= D_NAOSELECIONADO
		 	aDadosEx[oLbxAux:nAt,nEXCONCI] 	:= 0
		 	nTotExCon 						:= nTotExCon - aDadosEx[oLbxAux:nAt,nZB2VALOR]
		 	
		 	
		 	IF !EMPTY(nMarkAnt)
		 		DesmConc(nMarkAnt)
		 	ENDIF
		 	
		ELSE
			/*
			IF ((nTotExCon > 0 .OR. nTotMvCon > 0) .and. aDadosEx[oLbxAux:nAt,nZB2VALOR] > 0 ) .OR.;
				((nTotExCon < 0 .OR. nTotMvCon < 0) .and. aDadosEx[oLbxAux:nAt,nZB2VALOR] < 0 ) .OR.;
				nTotExCon == 0 .and. nTotMvCon == 0
			*/
				/*--------------------------
					SELECIONANDO
				---------------------------*/		
				aDadosEx[oLbxAux:nAt,1] 		:= .T.
				aDadosEx[oLbxAux:nAt,2] 		:= D_SELECIONADO
				aDadosEx[oLbxAux:nAt,nEXCONCI] 	:= nMarkConc
				nTotExCon 						:= nTotExCon + aDadosEx[oLbxAux:nAt,nZB2VALOR]
				
			//endif
		ENDIF
		
		/*--------------------------
			Conferencia dos valores selecionados
			e alteracao do status
		---------------------------*/
		ConfVlr()
	
	/*-----------------------------
		IDENTIFICA«√O DE TAXAS
	------------------------------*/	
	ELSEIF nConcTaxa == OPCAO_TAXA .AND. (aDadosEx[oLbxAux:nAt,2] == D_TAXA .OR. aDadosEx[oLbxAux:nAt,2] == D_NAOSELECIONADO)
	
		IF aDadosEx[oLbxAux:nAt,1]
		 	aDadosEx[oLbxAux:nAt,1] 	:= .F.
		 	aDadosEx[oLbxAux:nAt,2] 	:= D_NAOSELECIONADO
		 	
		 	
		 	nPosAux	:=  aScan(aDadosMv, { |x| x[nSE5ZB2] ==  aDadosEx[oLbxAux:nAt, nZB2RECNO]})
		 	IF nPosAux > 0
		 		aDel(aDadosMv, nPosAux)
		 		aSize(aDadosMv, LEN(aDadosMv)-1)
		 		oLbxMv:nAt	:= 1
		 	ENDIF
		 	
		 
		 ELSEIF !(aDadosEx[oLbxAux:nAt,1])
	 	 	aDadosEx[oLbxAux:nAt,1] 	:= .T.
	 	 	aDadosEx[oLbxAux:nAt,2] 	:= D_TAXA
	 	 
	 	 	/*------------------------------------------------------ Augusto Ribeiro | 30/12/2016 - 10:51:14 AM
	 	 		CRIA REGISTRO NA TABELA DE MOVIMENTOS.
	 	 	------------------------------------------------------------------------------------------*/
	 	 	aLinha	:= {}
	 	 	FOR nI := 1 TO LEN(aCpoMv)
	 	 		xValor	:= NIL
	 	 		IF aCpoMv[nI] == "MARK"
	 	 			xValor	:= .F.
	 	 		ELSEIF aCpoMv[nI] == "LEGENDA"
	 	 			xValor	:= aDadosEx[oLbxAux:nAt,2] 	 			
	 	 		ELSEIF aCpoMv[nI] == "E5_DTDISPO"
	 	 			xValor	:= aDadosEx[oLbxAux:nAt,nZB2DATA]
	 	 		ELSEIF aCpoMv[nI] == "E5_VALOR"
	 	 			xValor	:= aDadosEx[oLbxAux:nAt,nZB2VALOR]
	 	 		ELSEIF aCpoMv[nI] == "E5_HISTOR"
	 	 			xValor	:= aDadosEx[oLbxAux:nAt,nZB2DESC]
	 	 		ELSEIF aCpoMv[nI] == "E5_FILIAL"
	 	 			xValor	:= CRIAVAR("E5_FILIAL",.F.) 	 			
	 	 			xValor	:= PADR(cFILMVPAR, LEN(xValor))
	 	 		ELSEIF aCpoMv[nI] == "E5_CCUSTO"
	 	 			xValor	:= CRIAVAR("E5_CCUSTO",.F.)
	 	 			xValor	:= PADR(cCTTMVPAR , LEN(xValor))
	 	 		ELSEIF aCpoMv[nI] == "E5_NATUREZ"
	 	 			xValor	:= CRIAVAR("E5_NATUREZ",.F.)
	 	 			xValor	:= PADR(cSEDMVPAR, LEN(xValor))
	 	 		ELSEIF aCpoMv[nI] == "SE5_RECNO"
	 	 			xValor	:= 0
	 	 		ELSEIF aCpoMv[nI] == "SE5ZB2"
	 	 			xValor	:= aDadosEx[oLbxAux:nAt,nZB2RECNO]
	 	 		ELSEIF aCpoMv[nI] == "MVCONCI"
	 	 			xValor	:= 0
	 	 		ENDIF
	 	 		
	 	 		aadd(aLinha, xValor)
	 	 	NEXT nI
	 	 	
	 	 	aadd(aDadosMv, aLinha)
	 	 	oLbxMv:nAt	:= len(aDadosMv)//| Posiciona no registro adicionado. | 
	 	 	SelMov(@oLbxMv, .T. )
	 	 	
		ENDIF
	ENDIF
ENDIF


oLbxMv:Refresh()

Return()

/*/{Protheus.doc} SelMov
Double Click Extrato
@author Augusto Ribeiro | www.compila.com.br
@since 26/12/2016
@version version
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function SelMov(oLbxAux, lForceMark)
Local nI, nVlrMov, nDif, nPosAux
Local nPosAux, nPosEx	
Local nMarkAnt	:= 0

Default lForceMark	:= .f.


nPosEx := aScan(aDadosEx, { |x| x[2] ==  D_SELECIONADO})



/*-----------------------------
	CONCILIACAO DE MOVIMENTOS
------------------------------*/
IF nConcTaxa == OPCAO_CONCILIACAO
	
	
	/*--------------------------
		REMOVENDO SELECAO
	---------------------------*/	
	IF aDadosMv[oLbxAux:nAt,1]
		
		IF aDadosMv[oLbxAux:nAt,2] == D_CONCILIADO .OR.  aDadosMv[oLbxAux:nAt,2] == D_CONCILIADO_AUTO
			nMarkAnt	:= aDadosMv[oLbxAux:nAt,nMVCONCI]
		ENDIF		
		aDadosMv[oLbxAux:nAt,1] 		:= .F.
		aDadosMv[oLbxAux:nAt,2] 		:= D_NAOSELECIONADO
		aDadosMv[oLbxAux:nAt,nMVCONCI] 	:= 0
		nTotMvCon 						:= nTotMvCon - aDadosMv[oLbxAux:nAt,nE5VALOR]
		
	 	IF !EMPTY(nMarkAnt)
	 		DesmConc(nMarkAnt)
	 	ENDIF	 	
	ELSE
		/*
		IF ((nTotExCon > 0 .OR. nTotMvCon > 0) .and. aDadosMv[oLbxAux:nAt,nE5VALOR] > 0 ) .OR.;
			((nTotExCon < 0 .OR. nTotMvCon < 0) .and. aDadosMv[oLbxAux:nAt,nE5VALOR] < 0 ) .OR.;
			nTotExCon == 0 .and. nTotMvCon == 0
			*/
			/*--------------------------
				SELECIONANDO
			---------------------------*/		
			aDadosMv[oLbxAux:nAt,1] 		:= .T.
			aDadosMv[oLbxAux:nAt,2] 		:= D_SELECIONADO
			aDadosMv[oLbxAux:nAt,nMVCONCI] 	:= nMarkConc
			nTotMvCon 						:= nTotMvCon + aDadosMv[oLbxAux:nAt,nE5VALOR]
		//ENDIF
			
	ENDIF
		
	/*--------------------------
		Conferencia dos valores selecionados
		e alteracao do status
	---------------------------*/
	ConfVlr()

/*-----------------------------
	IDENTIFICA«√O DE TAXAS
------------------------------*/	
ELSEIF nConcTaxa == OPCAO_TAXA

	IF aDadosMv[oLbxAux:nAt,1]
		nPosAux	:=  aScan(aDadosEx, { |x| x[nZB2RECNO] ==  aDadosMv[oLbxAux:nAt, nSE5ZB2]})
		
		
		IF nPosAux > 0
		 	Help(" ",1,"SELECAO",,"Este registro n„o pode ser desmarcad pois esta vinculado a um registro de taxa do extrato. Desmarque o item do extrato antes de continuar",4,5)
		 	oLbxEx:nAt	:= nPosEx
		ENDIF
	ELSE
		nPosEx := aScan(aDadosEx, { |x| x[2] ==  D_SELECIONADO})
		IF !EMPTY(nPosEx) .or. lForceMark
			aDadosMv[oLbxAux:nAt,1] 		:= .T.
			aDadosMv[oLbxAux:nAt,nSE5ZB2]	:=  aDadosEx[oLbxEx:nAt,nZB2RECNO]	
		ELSE
		 	Help(" ",1,"SELECAO",,"Este registro n„o pode ser desmarcad pois esta vinculado a um registro de taxa do extrato. Desmarque o item do extrato antes de continuar",4,5)
		 	IF nPosEx > 0
		 		oLbxEx:nAt	:= nPosEx
		 	ENDIF		
		ENDIF	
	ENDIF

ENDIF

oLbxEx:Refresh()

oView	:= FWViewActive()

oView:Refresh()

Return()





/*/{Protheus.doc} CP901BTN
Chamada de botoes da enchoice bar
@author Augusto Ribeiro | www.compila.com.br
@since 29/12/2016
@version 1.0
@param cBtn, C, Botao pressionado
@param oView, O, Objeto da View [Default: FWViewActive()]
@return ${return}, ${return_description}
/*/
User Function CP901BTN(cBtn, oView)
Local oView, nTotLen
Local oModFull, aRetAux
Local cPathDest, cPathArq
Local _cCodEmp, _cCodFil, _cFilNew

Local cRAFil := ""
Local cRACodCli	:= ""
Local cRALoja := ""
Local cRAHist := ""

IF VALTYPE(oView) <> "O"
	oView	:= FWViewActive()
ENDIF

//| Visualizacao do arquivo onde o cursor esta posicionado
IF cBtn == "PERG_CONC"
	
	PERGUNTE(D_PERG2,.T.)
	lISelec		:= (MV_PAR01==1)
	lExecConc	:= (MV_PAR02==1)
	cFILMVPAR	:= MV_PAR03
	cSEDMVPAR	:= MV_PAR04
	cCTTMVPAR	:= MV_PAR05

ELSEIF cBtn == "PERG_FILTRO"

	IF PERGUNTE(D_PERG,.T.)	
	
		cpFilDe		:= MV_PAR01
		cpFilAte	:= MV_PAR02
		cpBanco		:= MV_PAR03
		cpAg		:= MV_PAR04
		cpConta		:= MV_PAR05
		dpDtMvDe	:= MV_PAR06
		dpDtMvAte	:= MV_PAR07
		npTpMov		:= MV_PAR08
	
	
		fAtualiza()
	ENDIF
	
ELSEIF cBtn== "CONC_AUTO"

	/*------------------------------------------------------ Augusto Ribeiro | 29/12/2016 - 3:52:43 PM
		Realiza a conciliaÁ„o autom·tica dos itens listados
	------------------------------------------------------------------------------------------*/
	Processa({|| ConcAuto() }, "ConciliaÁ„o Autom·tica... ")
	
	
ELSEIF cBtn== "EFETIVA"

	IF AVISO("Efetiva ConciliaÁ„o", "Ser· efetivado a conciliaÁ„o de todos os movimentos selecionado."+CRLF+;
									"Deseja continuar ?", {"Sim", "N„o"},2) == 1
	
		Processa({|| fEfetiva() }, "Efetivando ConciliaÁ„o... ")
	ENDIF
	
ELSEIF cBtn== "TRANSF"	
	fTransf()
	
ELSEIF cBtn== "FCP"	

	FINA750()
	//bWindowInit := { || __Execute( "FINA750()" , "xxxxxxxxxxxxxxxxxxxx" , "FINA750" , "SIGAFIN" , "SIGAFIN", 1 , .T. ) }
	//EVAL(bWindowInit)
	
	fAtualiza()


ELSEIF cBtn== "MOV_BANC"


	IF LEN(aDadosMv) > 0

		IF aDadosMv[oLbxMv:nAt, nSE5RECNO] > 0
			
			CCADASTRO	:= "Movimento Bancario"
		
			DBSELECTAREA("SE5")
			SE5->(DBGOTO(aDadosMv[oLbxMv:nAt, nSE5RECNO]))
			
	 		/*---------------------------------------
				Realiza a TROCA DA FILIAL CORRENTE 
			-----------------------------------------*/
			_cCodEmp 	:= SM0->M0_CODIGO
			_cCodFil	:= SM0->M0_CODFIL
			_cFilNew	:= SE5->E5_FILIAL 
			
			IF _cCodEmp+_cCodFil <> _cCodEmp+_cFilNew
				CFILANT := _cFilNew
				opensm0(_cCodEmp+CFILANT)
			ENDIF
						
			
			AxVisual('SE5',aDadosMv[oLbxMv:nAt, nSE5RECNO],2)

			/*---------------------------------------
				Restaura FILIAL  
			-----------------------------------------*/
			IF _cCodEmp+_cCodFil <> _cCodEmp+_cFilNew
				CFILANT := _cCodFil
				opensm0(_cCodEmp+CFILANT)			 			
			ENDIF   			
		ENDIF
	
	ENDIF

ELSEIF cBtn== "FCR"

	FINA740()
	//bWindowInit := { || __Execute( "FINA740()" , "xxxxxxxxxxxxxxxxxxxx" , "FINA740" , "SIGAFIN" , "SIGAFIN", 1 , .T. ) }
	//EVAL(bWindowInit)	
	
	fAtualiza()
	
ELSEIF cBtn == "GERA_RA"

	IF aDadosEX[oLbxEx:nAt,nZB2VALOR] > 0

		aRetAux	:= ParamRA()
		
		If len(aRetAux) > 0 .AND. LEN(aRetAux[3]) > 0
			cRAFil		:= aRetAux[3,1]
			cRACodCli	:= aRetAux[3,2]
			cRALoja		:= aRetAux[3,3]	
			cRAHist     := aRetAux[3,4]	

			IF !EMPTY(cRAFil) .AND. !EMPTY(cRACodCli) .AND. !EMPTY(cRALoja) 
				/*------------------------------------------------------ Augusto Ribeiro | 03/11/2017 - 5:14:34 PM
					Gera Recebimento antecipado
				------------------------------------------------------------------------------------------*/
				//aRetAux	:= U_CP09MVRA(aDadosEX[oLbxEx:nAt,nZB2RECNO], aDadosCR[nPosMv, nE1FILIAL], aDadosCR[nPosMv, nE1CLIENTE], aDadosCR[nPosMv, nE1LOJA])
				aRetAux	:= U_CP09MVRA(aDadosEX[oLbxEx:nAt,nZB2RECNO], cRAFil, cRACodCli, cRALoja, cRAHist)
				
				IF aRetAux[1]
					fAtualiza()
				ELSE
					aRetAux[2]	:= aRetAux[2]+"."					
					ALERT(aRetAux[2])
				ENDIF	
			ENDIF
		Endif	
	ELSE
		ALERT("Item posicionado deve possuir valor maior que 0")
	ENDIF
		
ENDIF 

Return()







/*/{Protheus.doc} ListTot
Atualiza Totalizadores da Interface
@author Jonatas Oliveira | www.compila.com.br
@since 31/03/2016
@version 1.0
/*/
Static Function ListTot(oPanelr)
Local cBCodLin		:= ""   
Local oOk 	     	:= LoadBitmap( GetResources(), "LBOK" )
Local oNo   	   	:= LoadBitmap( GetResources(), "LBNO" )
Local oFLabels 		:= TFont():New("MS Sans Serif",,022,,.F.,,,,,.F.,.F.)
Local aVlrCor		:= {} 
Local oFGrpCpo := TFont():New("Verdana",,016,,.F.,,,,,.F.,.F.)
Local nI		:= 1

Private oDlgMTot	:= NIL

Private cTotalS	:= ""
Private cTotalA	:= ""
Private cTotalB	:= ""
Private cTotalC	:= ""
Private cTotalD	:= ""
Private cTotalE	:= ""
Private nTotalA	:= 0

IF !EMPTY(oPanelr)

	oPaneRod	:= @oPanelr
	nPosCentro	:= (oPanelr:nClientWidth/4)
	nPosFim		:= (oPanelr:nClientWidth/2)
	
	//@  200, 200		SAY oLblSolicita PROMPT "Acrescimo: "				SIZE 50, 024 OF oPanelr FONT oFGrpCpo COLORS 128, 16777215 PIXEL	
	
	//@  230, 120 		SAY oLblSolicita PROMPT "" 					SIZE 50, 024 OF oPanelr FONT oFGrpCpo COLORS 128, 16777215 PIXEL
	//oTotAcres := TGet():Create( oPanelr,{|| 1},230, 200	, 050,009,D_PICTURE_VLR,,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,cTotalS,,,, )
	
	@  7, 5 		SAY oLblSolicita PROMPT "Extrato"				SIZE 50, 024 OF oPanelr FONT oFGrpCpo COLORS 128, 16777215 PIXEL
	oTotEx := TGet():Create( oPanelr,{|| CalcTot("EXTRATO") },5, 050	, 050,009,D_PICTURE_VLRT,,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,cTotalA,,,, )

	@  20, 5		SAY oLblSolicita PROMPT "Selecionado"				SIZE 50, 024 OF oPanelr FONT oFGrpCpo COLORS 128, 16777215 PIXEL
	oSelEx := TGet():Create( oPanelr,{|| CalcTot("SELECIONADO_EX") },19, 050	, 050,009,D_PICTURE_VLRT,,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,cSelEx,,,, )
		
		
	//@  7, 100 		SAY oLblSolicita PROMPT "Vencidos" 				SIZE 50, 024 OF oPanelr FONT oFGrpCpo COLORS 128, 16777215 PIXEL
	//oTotVenc := TGet():Create( oPanelr,{|| 3},5, 130	, 050,009,D_PICTURE_VLR,,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,cTotalS,,,, )
	
	@  7, nPosCentro-50 		SAY oLblSolicita PROMPT "Conciliado" 				SIZE 50, 024 OF oPanelr FONT oFGrpCpo COLORS 128, 16777215 PIXEL
	oTotCon:= TGet():Create( oPanelr,{|| CalcTot("CONCILIADO")},5, nPosCentro-10	, 050,009,D_PICTURE_VLRT,,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,cTotalC,,,, )

	@  20, nPosCentro-50 		SAY oLblSolicita PROMPT "LanÁamento" 				SIZE 50, 024 OF oPanelr FONT oFGrpCpo COLORS 128, 16777215 PIXEL
	oTotTaxa:= TGet():Create( oPanelr,{|| CalcTot("TAXA")},17, nPosCentro-10	, 050,009,D_PICTURE_VLRT,,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,cTotalD,,,, )	
		
		
	//oCheck1 := TCheckBox():New(07,nPosCentro+50,'CheckBox 001',{|| SelChek("CONCILIA")},oPanelr,100,210,,,,,,,,.T.,,,)
   	//oCheck2 := TCheckBox():New(18,nPosCentro+50,'CheckBox 002',{|| SelChek("TAXA")},oPanelr,100,210,,,,,,,,.T.,,,)		
		
   	//oCheck1 := TCheckBox():New(07,nPosCentro+50,'CheckBox 001',{|| lSelConc},oPanelr,100,210,,,,,,,,.T.,,,)
   	//oCheck2 := TCheckBox():New(18,nPosCentro+50,'CheckBox 002',{|| lSelTaxa},oPanelr,100,210,,,,,,,,.T.,,,)
   	
   	
   	aRadio := {'Concilia','LanÁamento'}
  // 	oRadio := TRadMenu():Create (oPanelr,,07,nPosCentro+50,aItens,,,,,,,,100,12,,,,.T.)
  //	oRadio := TRadMenu():New (07,nPosCentro+50,aItens,,oPanelr,,,,,,,,100,12,,,,.T.)
  	oRadio:= tRadMenu():New(7,nPosCentro+50,aRadio,{|u|if(PCount()>0,nConcTaxa:=u,nConcTaxa)},oPanelr,,,,,,,,140,8,,,,.T.)  
   	//oRadio:bSetGet := {|u|Iif(PCount()==0,nRadio,nRadio:=u)}
				
		
	//@ 7,010 Radio _oResp Var _xResp 3D Size _nLrg,_nAlt Prompt "Sim","N„o" Of _oDlgResp Pixel		
		
		
	@  7, nPosFim-100  		SAY oLblSolicita PROMPT "Sistema"		SIZE 50, 190 OF oPanelr FONT oFGrpCpo COLORS 128, 16777215 PIXEL
	oTotMv := TGet():Create( oPanelr,{|| CalcTot("MOVIMENTO")},5, nPosFim-60	, 050,009,D_PICTURE_VLRT,,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,cTotalMv,,,, )

	@  20, nPosFim-107  		SAY oLblSolicita PROMPT "Selecionado"		SIZE 50, 190 OF oPanelr FONT oFGrpCpo COLORS 128, 16777215 PIXEL
	oSelMv := TGet():Create( oPanelr,{|| CalcTot("SELECIONADO_MV")},19, nPosFim-60	, 050,009,D_PICTURE_VLRT,,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,cSelMv,,,, )
	
	
	/*
	@  20, 120		SAY oLblSolicita PROMPT "Acrescimo: "			SIZE 50, 024 OF oPanelr FONT oFGrpCpo COLORS 128, 16777215 PIXEL		
	oTotalP := TGet():Create( oPanelr,{|| CalcTot("ACRESS", @aDadoTit)},20, 120	, 050,009,D_PICTURE_VLRT,,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,cTotalS,,,, )
	*/
	//oPanelr:nClientWidth -5  //(oPanelr:nClientHeight/2)-12	
	
ELSE

	cTotalA		:= CalcTot("EXTRATO")
	cSelEx		:= CalcTot("SELECIONADO_EX")
	cTotalC		:= CalcTot("CONCILIADO")
	cTotalD		:= CalcTot("TAXA")
	cTotalMv	:= CalcTot("MOVIMENTO")
	cSelMv		:= CalcTot("SELECIONADO_MV")


	/*--------------------------
		Atualiza total conciliado
	
	nTotConc	:= 0
	FOR nI := 1 to LEN(aDadosEx)
		IF aDadosEx[nI,2] == D_CONCILIADO
			nTotConc += aDadosEx[nI, nZB2VALOR]
		ENDIF
	NEXT nI
	IF !EMPTY(oTotCon)
		oTotCon:cText := nTotConc
		oTotCon:Refresh()
		oPaneRod:Refresh()
		
		oView	:= FWViewActive()
		oView	:= oView
	ENDIF
	---------------------------*/


	//oTotalP:cText	:= '10'
	
ENDIF
		
oTotEx:CtrlRefresh()
oTotCon:CtrlRefresh()
oTotTaxa:CtrlRefresh()
oTotMv:CtrlRefresh()
oSelEx:CtrlRefresh()
oSelMv:CtrlRefresh()
Return




/*/{Protheus.doc} CalcTot
(long_description)
@author Augusto Ribeiro | www.compila.com.br
@since 29/12/2016
@version 6
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function CalcTot(cOpc)
Local nRet	:= 0
Local nI	:= 0

Default cOpc	:= "CONCILIADO"

/*--------------------------
	Atualiza total conciliado
---------------------------*/
IF cOpc == "CONCILIADO"
	
	
	
	FOR nI := 1 to LEN(aDadosEx)
		IF aDadosEx[nI,2] == D_CONCILIADO
			nRet += aDadosEx[nI, nZB2VALOR]
		ENDIF
	NEXT nI
	
ELSEIF cOpc == "EXTRATO"
	
	nRet	:= nSaldoEx//| Saldo do EXTRATO|7
	/*
	FOR nI := 1 to LEN(aDadosEx)
		IF aDadosEx[nI,2] == D_CONCILIADO .OR. aDadosEx[nI,2] == D_TAXA
			nRet += aDadosEx[nI, nZB2VALOR]
		ENDIF
	NEXT nI	
	*/
	
ELSEIF cOpc == "MOVIMENTO"

	nRet	:= nSaldoMv //| Saldo do movimento|
	
	FOR nI := 1 to LEN(aDadosMv)
		IF aDadosMv[nI, 1]
			nRet += aDadosMv[nI, nE5VALOR]
		ENDIF
	NEXT nI	
	
ELSEIF cOpc == "TAXA"
	FOR nI := 1 to LEN(aDadosEx)
		IF aDadosEx[nI,2] == D_TAXA
			nRet += aDadosEx[nI, nZB2VALOR]
		ENDIF
	NEXT nI
	
ELSEIF cOpc == "SELECIONADO_EX"
	FOR nI := 1 to LEN(aDadosEx)
		IF aDadosEx[nI,1]
			nRet += aDadosEx[nI, nZB2VALOR]
		ENDIF
	NEXT nI	
	
ELSEIF cOpc == "SELECIONADO_MV"
	FOR nI := 1 to LEN(aDadosMv)
		IF aDadosMv[nI,1]
			nRet += aDadosMv[nI, nE5VALOR]
		ENDIF
	NEXT nI	
			
		
ENDIF

Return(nRet)







/*/{Protheus.doc} ConcAuto
Realiiza a ConciliaÁ„o autom·tica dos itens passados.
@author Augusto Ribeiro | www.compila.com.br
@since 29/12/2016
@version 6
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function ConcAuto()
Local nRet		:= 0
Local nI		:= 0
Local nMv		:= 0
Local lAuxSel	:= lISelec //| Backup do parametro| 
Local nQtdEx	:= 0
Local nQtdMv	:= 0

nConcTaxa	:= 1 
lISelec		:= .F.

IF !EMPTY(aDadosEx) .AND. !EMPTY(aDadosMv)

	nQtdEx	:= LEN(aDadosEx)
	nQtdMv	:= LEN(aDadosMv)

	ProcRegua(nQtdEx)
	
	aSort(aDadosEx,,,{ |x,y| x[nZB2DATA] < y[nZB2DATA]})
	aSort(aDadosMv,,,{ |x,y| x[nE5DTDISPO] < y[nE5DTDISPO]})
	
	nAuxMv	:= 1
	FOR nI := 1 to nQtdEx
		IncProc("Conciliando automaticamente..")
		
		IF empty(aDadosEx[nI, nZB2DATA])
			LOOP
		ENDIF
	
		nAuxMv	:= aScan(aDadosMv, { |x| x[nE5DTDISPO] ==  aDadosEx[nI,nZB2DATA]})
		IF nAuxMv > 0
			FOR nMv := nAuxMv TO nQtdMv
				
				IF !(aDadosMv[nMv, 1])			
					IF  aDadosMv[nMv, nE5DTDISPO] == aDadosEx[nI, nZB2DATA]
					
						nDif	:=  aDadosEx[nI, nZB2VALOR] - aDadosMv[nMv, nE5VALOR] //nVlrExtr - nVlrMov
						IF nTolera >= nDif .and. (nTolera*-1) <=  nDif
						
							oLbxEx:nAt	:= nI							
							SelEx(@oLbxEx) //| Seleciona Item|
							ListTot()
							oLbxEx:Refresh()
							
							oLbxMv:nAt	:= nMv
							dbClickMv(nMv, 1)
							//SelMov(@oLbxMv) //| Seleciona Item|
							
							EXIT
						endif	
					ELSEIF aDadosMv[nMv, nE5DTDISPO] > aDadosEx[nI, nZB2DATA]
						EXIT			
					ENDIF
				ENDIF
				
			NEXT nMv
		ENDIF
		
	
	NEXT nI
ENDIF
	

oLbxEx:nAt	:= 1
oLbxMv:nAt	:= 1

//| Restore do parametro |
lISelec	:= lAuxSel

oLbxEx:Refresh()
oLbxMv:Refresh()

Return(nRet)




/*/{Protheus.doc} SelModo
(long_description)
@author Augusto Ribeiro | www.compila.com.br
@since 29/12/2016
@version 6
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function SelChek(cOpc)
Local lRet := .F.
IF cOpc == "CONCILIA"

	IF !(lSelConc)
		lSelConc	:= .t.
		lSelTaxa	:= .f.
	
		lRet	:= lSelConc
	endif
ELSEIF cOpc == "TAXA"

	IF !(lSelTaxa)
		lSelConc	:= .f.
		lSelTaxa	:= .t.
	
		lRet	:= lSelTaxa
	endif

ENDIF

Return(lRet)




/*/{Protheus.doc} dbClickMv
Realiza aÁ„o no double click do ListBox MOVIMENTOS
@author Augusto Ribeiro | www.compila.com.br
@since 03/01/2017
@version 6
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function dbClickMv(nRow,nCol,nFlags)

Default nRow := 0
Default nCol := 0
Default nFlags := 0

//IF !(lVazioMv)
IF !(EMPTY(aDadosMv[oLbxMv:nAt, nE5DTDISPO])) //| N„o realiza acao sobre registro vazio|

	IF EMPTY(aDadosMv[oLbxMv:nAt, nSE5RECNO]) .and. (nCol == nE5HISTOR) //.OR. nCol == nE5NATUREZ .OR. nCol == nE5CCUSTO) 
		//IF EMPTY(aDadosMv[oLbxMv:nAt, nSE5RECNO])
			EditHist(@oLbxMv, nCol)
	//	ENDIF
	else
		SelMov(@oLbxMv)
		ListTot()
		oLbxMv:Refresh()
	ENDIF
ENDIF
Return()




/*/
	Funcao:		EditLBoxCBox
	Autor:		Marinaldo de Jesus
	Data:		02/10/2011
	Descricao:	Permite Adicionar um ComboBox Editavel em uma ListBox
	Sintaxe:	EditLBoxCBox( oListBox , aCTTBloqBox , nColPos )
/*/
//Static Function EditLBoxCBox( oListBox ,  nColPos )
Static Function EditHist( oListBox ,  nColPos )
Local aDim
Local oDlg
Local oComboBox
//Local bSetGet	:= {  |u| oListBox:aArray[oListBox:nAT][nColPos] := u }
Local bSetGet	:=  { |u| IF( oListBox:nAT > 0,														;
										IF( PCount() == 0,													;
											oListBox:aArray[oListBox:nAT][nColPos],							;
											oListBox:aArray[oListBox:nAT][nColPos] := u 	;
										),																	;
									NIL																		;
								 )																			;
							}

GetCellRect( @oListBox , @aDim )	//Obtenho as Coordenadas da Celula
DEFINE MSDIALOG oDlg FROM 0,0 TO 0,0 STYLE nOR( WS_VISIBLE , WS_POPUP ) PIXEL WINDOW oListBox:oWnd


	oGetTeste := TGet():Create( oDlg,bSetGet   ,5,060, 050,009,"@!",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,oListBox:aArray[oListBox:nAT][nColPos],,,, )
	//oTGet2    := TGet():Create( oDlg,{||cTGet2},14,01,096,009,"@!"           ,,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,cTGet2,,,, )
	
	oGetTeste:move(aDim[1], aDim[2], aDim[4]-aDim[2], aDim[3]-aDim[1])


	oGetTeste:Move( -2 , -2 , ( ( aDim[ 4 ] - aDim[ 2 ] ) + 4 ) , ( ( aDim[ 3 ] - aDim[ 1 ] ) + 4 ) )
	
	oDlg:Move( aDim[1] , aDim[2] , ( aDim[4]-aDim[2] ) , ( aDim[3]-aDim[1] ) )
	@ 0, 0 BUTTON oBtn PROMPT "" SIZE 0,0 OF oDlg
	oBtn:bGotFocus	:= { || oDlg:nLastKey := VK_RETURN , oDlg:End(0) }
ACTIVATE MSDIALOG oDlg

Return( NIL )




/*/{Protheus.doc} fEfetiva
Efetiva ConciliaÁ„o
@author Augusto Ribeiro | www.compila.com.br
@since 04/01/2017
@version 6
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function fEfetiva()
Local aRet	:= {.f., ""}
Local nPosMv, aRetAux
Local nI, nY, dDataAnt
Local nDadosMv	:= len(aDadosMv)
Local aRecSE5	:= {}
Local lRetConc	:= .f.
Local nQtdeTaxa	:= 0
Local nMaxTaxa	:= GETMV("CP9_GELANC",.F., 20) //| Quantidade Maxima de lanÁamentos |

Local nLoopEx, nTotEx
Local nLoopMv, nTotMv
Local nLastnY	:= 1	
Local nIdConc	:= 1
Local aRegEx	:= {}
Local aRegMv	:= {}
	
ProcRegua(len(aDadosEx))


/*------------------------------------------------------ Augusto Ribeiro | 13/01/2017 - 10:14:33 AM
	Trava de seguranÁa para evitar que usuario gere numero excessivo de lanÁamentos incorretamente
------------------------------------------------------------------------------------------*/
For nI := 1 to Len(aDadosEx)
	IF aDadosEx[nI, 1] .AND. aDadosEx[nI, 2] == D_TAXA
		nQtdeTaxa++
	ENDIF	
Next nI

IF nQtdeTaxa <= nMaxTaxa
	
	
	/*------------------------------------------------------ Augusto Ribeiro | 25/01/2017 - 6:11:28 PM
	
		CONCILIA«√O
		Realiza conciliaÁ„o no SE5 e ZB2 (EXTRATO BANCARIO)
	
	------------------------------------------------------------------------------------------*/	
	DBSELECTAREA("ZB2")
	DBSELECTAREA("SE5")
	
	aSort(aDadosEx,,,{ |x,y| x[nEXCONCI] > y[nEXCONCI] })
	aSort(aDadosMv,,,{ |x,y| x[nMVCONCI] > y[nMVCONCI] })
	
	nLoopEx	:= 1
	nLoopMv	:= 1
	nTotEx	:= len(aDadosEx)
	nTotMv	:= len(aDadosMv)
	IF !lVazioEx	
		WHILE  IIF(nLoopEx <= nTotEx, aDadosEx[nLoopEx, nEXCONCI] > 0, .F.) 
			IncProc("Conciliando..")
			aRegEx	:= {}
			aRegMv	:= {}
			
			IF aDadosEx[nLoopEx, 2] == D_CONCILIADO
				
				nIdConc	:= aDadosEx[nLoopEx, nEXCONCI]
				WHILE  IIF(nLoopEx <= nTotEx, aDadosEx[nLoopEx, nEXCONCI] == nIdConc,.F.) 
					AADD(aRegEx, aDadosEx[nLoopEx, nZB2RECNO])
					nLoopEx++
				ENDDO
				
				
				//WHILE IIF(nLoopMv <= nTotMv, aDadosMv[nLoopMv, nMVCONCI] == nIdConc, .F.) 
				WHILE nLoopMv <= nTotMv 
					IF aDadosMv[nLoopMv, nMVCONCI] == nIdConc
						AADD(aRegMv, aDadosMv[nLoopMv, nSE5RECNO])
					ENDIF
					nLoopMv++
					IF nLoopMv <= nTotMv 
						IF aDadosMv[nLoopMv, nMVCONCI] < nIdConc
							EXIT
						ENDIF
					ENDIF
				ENDDO		
				
				/*------------------------------------------------------ Augusto Ribeiro | 25/01/2017 - 6:08:14 PM
					Grava conciliaÁ„o
				------------------------------------------------------------------------------------------*/
				IF !EMPTY(aRegEx) .AND. !EMPTY(aRegMv)
					aRetAux	:= U_CP09CONC(aRegMv, aRegEx) // Rotina j· possui Begin Transaction
					IF !(aRetAux[1])
						aRet[2] := aRetAux[2]
						EXIT
					ENDIF
				ENDIF
			ELSE
				nLoopEx++
			ENDIF
			ENDDO
		
		
		/*------------------------------------------------------ Augusto Ribeiro | 15/02/2017 - 5:47:47 PM
			Auto ConciliaÁ„o
		------------------------------------------------------------------------------------------*/
		nLoopEx	:= 1
		nLoopMv	:= 1
		WHILE  IIF(nLoopEx <= nTotEx, aDadosEx[nLoopEx, nEXCONCI] > 0, .F.) 
			aRegEx	:= {}
			aRegMv	:= {}
			
			IF aDadosEx[nLoopEx, 2] == D_CONCILIADO_AUTO

				nIdConc	:= aDadosEx[nLoopEx, nEXCONCI]
				WHILE  IIF(nLoopEx <= nTotEx, aDadosEx[nLoopEx, nEXCONCI] == nIdConc,.F.) 
					AADD(aRegEx, aDadosEx[nLoopEx, nZB2RECNO])
					nLoopEx++
				ENDDO		
			
			
				/*------------------------------------------------------ Augusto Ribeiro | 25/01/2017 - 6:08:14 PM
					Grava conciliaÁ„o
				------------------------------------------------------------------------------------------*/
				IF !EMPTY(aRegEx)
					aRetAux	:= U_CP09CONC(aRegMv, aRegEx) // Rotina j· possui Begin Transaction
					IF !(aRetAux[1])
						aRet[2] := aRetAux[2]
						EXIT
					ENDIF
				ENDIF	
			ELSE
				nLoopEx++
			ENDIF
			
		ENDDO
	endif
	
	
	WHILE  IIF(nLoopMv <= nTotMv, aDadosMv[nLoopMv, nMVCONCI] > 0, .F.)
	 	aRegEx	:= {}
		aRegMv	:= {}
		
		IF aDadosMv[nLoopMv, 2] == D_CONCILIADO_AUTO

			nIdConc	:= aDadosMv[nLoopMv, nMVCONCI]
			WHILE IIF(nLoopMv <= nTotMv, aDadosMv[nLoopMv, nMVCONCI] == nIdConc, .F.) 
				AADD(aRegMv, aDadosMv[nLoopMv, nSE5RECNO])
				nLoopMv++
			ENDDO			
		
		
			/*------------------------------------------------------ Augusto Ribeiro | 25/01/2017 - 6:08:14 PM
				Grava conciliaÁ„o
			------------------------------------------------------------------------------------------*/
			IF !EMPTY(aRegMv)
				aRetAux	:= U_CP09CONC(aRegMv, aRegEx) // Rotina j· possui Begin Transaction
				IF !(aRetAux[1])
					aRet[2] := aRetAux[2]
					EXIT
				ENDIF
			ENDIF	
		ELSE
			nLoopMv++
		ENDIF
		
	ENDDO
		
	
	
	
	
	
	/*------------------------------------------------------ Augusto Ribeiro | 25/01/2017 - 6:11:28 PM
	
		LANCAMENTOS 
		Gera LanÁamentos
	
	------------------------------------------------------------------------------------------*/	
	IF EMPTY(aRet[2])
		ProcRegua(len(aDadosEx))
	
	
		DBSELECTAREA("ZB2")
		aSort(aDadosMv,,,{ |x,y| x[nSE5ZB2] < y[nSE5ZB2] })
		
		DBSELECTAREA("SE5")
		for nI := 1 to Len(aDadosEx)
			IncProc("Conciliando..")
			
			IF aDadosEx[nI, 1]	.and. aDadosEx[nI, 2] == D_TAXA
					
				nPosMv	:= aScan(aDadosMv, { |x| x[nSE5ZB2] ==  aDadosEx[nI,nZB2RECNO]})
		 	
		 		/*---------------------------------------
					Realiza a TROCA DA FILIAL CORRENTE 
				-----------------------------------------*/
				_cCodEmp 	:= SM0->M0_CODIGO
				_cCodFil	:= SM0->M0_CODFIL
				_cFilNew	:= aDadosMv[nPosMv, nE5FILIAL] //| CODIGO DA FILIAL DE DESTINO 
				
				IF _cCodEmp+_cCodFil <> _cCodEmp+_cFilNew
					CFILANT := _cFilNew
					opensm0(_cCodEmp+CFILANT)
				ENDIF
				
				//| Altera data para gerar movimentacao|
				dDataAnt	:= DDATABASE
				DDATABASE	:= aDadosMv[nPosMv, nE5DTDISPO]
		 	
				BEGIN TRANSACTION
				
		 		/*--------------------------
		 			Gera movimento bancario
		 		---------------------------*/
		 		aRetAux	:= U_CP09INC5(aDadosMv[nPosMv, nE5VALOR], aDadosMv[nPosMv, nE5HISTOR], cpBanco, cpAg, cpConta, aDadosMv[nPosMv, nE5NATUREZ], aDadosMv[nPosMv, nE5CCUSTO])
	 		
		 		IF aRetAux[1]
		 			aRegMv	:= {SE5->(recno())}
		 			aRegEx	:= {aDadosEx[nI,nZB2RECNO]}
		 			
					/*------------------------------------------------------ Augusto Ribeiro | 25/01/2017 - 6:08:14 PM
						Grava conciliaÁ„o
					------------------------------------------------------------------------------------------*/
					IF !EMPTY(aRegEx) .AND. !EMPTY(aRegMv)
						aRetAux	:= U_CP09CONC(aRegMv, aRegEx) // Rotina j· possui Begin Transaction
						IF !(aRetAux[1])
							DISARMTRANSACTION()
							aRet[2] := aRetAux[2]
							//EXIT
						ENDIF
					ENDIF		 			

		 		ELSE
		 			aRet[2] += aRetAux[2]+CRLF
		 		Endif
		 		
		 		END TRANSACTION
		 	
		 		//| Restaura a Data|
		 		DDATABASE	:= dDataAnt
						 	
				
				/*---------------------------------------
					Restaura FILIAL  
				-----------------------------------------*/
				IF _cCodEmp+_cCodFil <> _cCodEmp+_cFilNew
					CFILANT := _cCodFil
					opensm0(_cCodEmp+CFILANT)			 			
				ENDIF   			
				
				
				IF !EMPTY(aRet[2])
					EXIT
				ENDIF
			
			endif
		next nY
	ENDIF

	//| Atualiza toda a interface|
	fAtualiza()
else
	aRet[2]	:= "Limite de lanÁamentos a serem criados na movimentaÁ„o banc·ria excedido. Somente È permitido efetivar ["+alltrim(str(nMaxTaxa))+"][SX6 AL_CP9LANC]"
endif


IF !EMPTY(aRet[2])
	Help(" ",1,"EFETIVA",,aRet[2],4,5)
else
	aRet[1]	:= .T.
ENDIF

Return(aRet)




/*/{Protheus.doc} fAtualiza
Atualiza TODA a interface
@author Augusto Ribeiro | www.compila.com.br
@since 04/01/2017
@version 6
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function fAtualiza()

	nSaldoMv	:= SaldoMv(cpBanco, cpAg, cpConta, dpDtMvAte)
	nSaldoEx	:= SaldoEx(cpBanco, cpAg, cpConta, dpDtMvAte)

	U_CP902LEX("A",@oLbxEx,@aCpoEx,@aHeadEx, @aDadosEx)
	//oLbxEx:nAt	:= 1
	U_CP902LMV("A",@oLbxMv,@aCpoMv,@aHeadMv, @aDadosMv)
	//oLbxMv:nAt	:= 1
	
/*	
	CalcTot("EXTRATO")	
	oTotEx:CtrlRefresh()
	
	CalcTot("MOVIMENTO")
	oTotCon:CtrlRefresh()
	*/
	ListTot()	
	
	nMarkConc	:= 1 
	nTotExCon	:= 0
	nTotMvCon	:= 0

	
	//oView	:= FWViewActive()
	//oView:Refresh()

Return()




/*/{Protheus.doc} fTransf
Atalho para rotina de transferencia
@author Augusto Ribeiro | www.compila.com.br
@since 04/01/2017
@version 6
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function fTransf()
Local dDtAnt	:= dDataBase


//Parametros para Filtrar Cliente
Private aParams:={}
Private aRetPar:={}


//Parametros da ficha de opcional
AADD(aParams,{1,"Data Transf.",cToD(SPACE(08)),,"","","",90,.F.,})

If ParamBox(aParams,"Parametros",@aRetPar)

	dDataBase	:= aRetPar[1]

	/*------------------------------------------------------ Augusto Ribeiro | 04/01/2017 - 7:08:10 AM
		Rotina padr„o de transferencia
	------------------------------------------------------------------------------------------*/
	FINA100()
	//fa100tran()
	//bWindowInit := { || __Execute( "fa100tran()" , "xxxxxxxxxxxxxxxxxxxx" , "FINA100" , "SIGAFIN" , "SIGAFIN", 1 , .T. ) }
	//EVAL(bWindowInit)	
	
	//| Atualiza interface|
	fAtualiza()

	dDataBase	:= dDtAnt
Endif       


Return()




/*/{Protheus.doc} SaldoMv
Retorna saldo do banco
@author Augusto Ribeiro | www.compila.com.br
@since 04/01/2017
@version version
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function SaldoMv(cBanco, cAgencia, cConta, dDataMV)
Local nRet		:= 0
Local cQuery	:= "" 
Local nSaldoAtu	:= 0
Local nSaldoIni	:= 0


CalcSldIni( @nSaldoAtu, @nSaldoIni, cBanco, cAgencia, cConta, dDataMV)

nRet	:= nSaldoAtu


/*
dDataMV	:= dDataMV-1

cQuery := " SELECT SUM(E8_SALRECO) AS E8_SALRECO "+CRLF
cQuery += " FROM "+RetSqlName("SE8")+" SE8 "+CRLF
cQuery += " INNER JOIN  "+RetSqlName("SA6")+" SA6 "+CRLF
cQuery += " 	ON A6_COD =   '"+cBanco+"' "+CRLF
cQuery += " 	AND A6_AGENCIA = '"+cAg+"' "+CRLF
cQuery += " 	AND A6_NUMCON = '"+cConta+"' "+CRLF
cQuery += " 	AND E8_FILIAL LIKE RTRIM(A6_FILIAL)+'%' "+CRLF
cQuery += " 	AND A6_COD = E8_BANCO "+CRLF
cQuery += " 	AND A6_AGENCIA = E8_AGENCIA "+CRLF
cQuery += " 	AND A6_NUMCON = E8_CONTA "+CRLF
cQuery += " 	AND A6_BLOCKED <> '1' "+CRLF
cQuery += " 	AND SA6.D_E_L_E_T_ = '' "+CRLF
cQuery += " WHERE E8_DTSALAT = (SELECT TOP 1 SE8B.E8_DTSALAT	 "+CRLF
cQuery += " 					FROM "+RetSqlName("SE8")+" SE8B "+CRLF
cQuery += " 					INNER JOIN  "+RetSqlName("SA6")+" SA6B "+CRLF
cQuery += " 						ON SA6B.A6_COD =  '"+cBanco+"' "+CRLF
cQuery += " 						AND SA6B.A6_AGENCIA = '"+cAg+"' "+CRLF
cQuery += " 						AND SA6B.A6_NUMCON = '"+cConta+"' "+CRLF
cQuery += " 						AND SE8B.E8_FILIAL LIKE RTRIM(SA6B.A6_FILIAL)+'%' "+CRLF
cQuery += " 						AND SA6B.A6_COD = SE8B.E8_BANCO "+CRLF
cQuery += " 						AND SA6B.A6_AGENCIA = SE8B.E8_AGENCIA "+CRLF
cQuery += " 						AND SA6B.A6_NUMCON = SE8B.E8_CONTA "+CRLF
cQuery += " 						AND SA6B.A6_BLOCKED <> '1' "+CRLF
cQuery += " 						AND SE8B.E8_DTSALAT <= '"+DTOS(dDataMV)+"' "+CRLF
cQuery += "							AND SE8B.E8_SALRECO > 0 "+CRLF
cQuery += " 						AND SA6B.D_E_L_E_T_ = '' "+CRLF
cQuery += " 				ORDER BY SE8B.E8_DTSALAT DESC) "+CRLF
cQuery += " AND SE8.D_E_L_E_T_ = '' "+CRLF

MemoWrite(GetTempPath(.T.) + "CP09002_SaldoMov.SQL", cQuery)

If Select("TSALDO") > 0
	TSALDO->(DbCloseArea())
EndIf

DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TSALDO",.F., .T.)						

IF TSALDO->(!EOF())
	 nRet	:= TSALDO->E8_SALRECO
ENDIF	


TSALDO->(DbCloseArea())

*/


Return(nRet)






/*/{Protheus.doc} SaldoEx
Retorna saldo do extrato bancario
@author Augusto Ribeiro | www.compila.com.br
@since 04/01/2017
@version version
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function SaldoEx(cBanco, cAg, cConta, dDataMV)
Local nRet		:= 0
Local cQuery	:= "" 
Local nSaldoZB2	:= 0
Local nSaldoIni	:= 0
Local dSaldoIni	:= ctod('  /  /  ')

Local cDigConta	:= ""



cQuery := " SELECT TOP 1 ZB4_DATA, ZB4_SALDO  "+CRLF
cQuery += " FROM "+RetSqlName("ZB4")+" ZB4 WITH(NOLOCK) "+CRLF
cQuery += " WHERE ZB4_BANCO = '"+cBanco+"' "+CRLF
cQuery += " AND ZB4_AGENC = '"+cAg+"' "+CRLF
cQuery += " AND ZB4_CONTA  = '"+cConta+"' "+CRLF
cQuery += " AND ZB4_DATA <= '"+DTOS(dDataMV)+"' "+CRLF
cQuery += " AND ZB4.D_E_L_E_T_ = '' "+CRLF
cQuery += " ORDER BY ZB4_DATA DESC "+CRLF


//MemoWrite(GetTempPath(.T.) + "CP09002_SaldoExB.SQL", cQuery)

If Select("TSALDOEX") > 0
	TSALDOEX->(DbCloseArea())
EndIf

DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TSALDOEX",.F., .T.)						

IF TSALDOEX->(!EOF())
	 nSaldoIni	:= TSALDOEX->ZB4_SALDO
	 dSaldoIni	:= stod(TSALDOEX->ZB4_DATA)
ENDIF	


TSALDOEX->(DbCloseArea())


cQuery := " SELECT ISNULL(SUM(ZB2_VALOR),0) AS SALDO "+CRLF
cQuery += " FROM "+RetSqlName("ZB2")+" ZB2 WITH(NOLOCK) "+CRLF
//cQuery += "  WHERE ZB2_BANCO = '"+PADL(cBanco,TAMSX3("ZB2_BANCO")[1],"0")+"' "+CRLF
cQuery += " WHERE ZB2_BANCO = '"+cBanco+"' "+CRLF
cQuery	+= " AND ZB2_AGENC = '"+cAg+"' "+CRLF
cQuery	+= " AND ZB2_CONTA = '"+cConta+"' "+CRLF
IF !EMPTY(dSaldoIni)
	cQuery	+= " AND ZB2_DATA > '"+DTOS(dSaldoIni)+"' "+CRLF
ENDIF
cQuery	+= " AND ZB2_DATA <= '"+DTOS(dDataMV)+"' "+CRLF
//cQuery += " AND ZB2_DTCONC <> '' "+CRLF
cQuery += " AND ZB2.D_E_L_E_T_ = '' "+CRLF


MemoWrite(GetTempPath(.T.) + "CP09002_SaldoExc.SQL", cQuery)


If Select("TSALDOEX") > 0
	TSALDOEX->(DbCloseArea())
EndIf

DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TSALDOEX",.F., .T.)						

IF TSALDOEX->(!EOF())
	 nSaldoZB2	:= TSALDOEX->SALDO
ENDIF	


TSALDOEX->(DbCloseArea())


nRet	:= nSaldoZB2+nSaldoIni

Return(nRet)




/*/{Protheus.doc} CP09002MODEL
 Pontos de entrada padroes do MVC
@author Augusto Ribeiro | www.compila.com.br
@since 14/01/2017
@version 6
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
USER FUNCTION CP09002MODEL()
Local aParam     := PARAMIXB
Local xRet       := .T.
Local oObj       := ''
Local cIdPonto   := ''
Local cIdModel   := ''
Local lIsGrid    := .F.
 
Local nLinha     := 0
Local nQtdLinhas := 0
Local cMsg       := ''
Local lAux
 
 
If aParam <> NIL
      
	oObj       := aParam[1]
	cIdPonto   := aParam[2]
	cIdModel   := aParam[3]
	  
	IF cIdPonto == "BUTTONBAR"
	
		/*--------------------------
			Executa conciliaÁ„o automatica na aberturaw
		---------------------------*/
		IF lExecConc
			lAux	:= lISelec
			lISelec	:= .f.
			
			Processa({|| ConcAuto()}, "ConciliaÁ„o Autom·tica... ")
			
			lISelec	:= lAux
		ENDIF
	ENDIF    	
ENDIF
       
      


Return(xRet)




/*/{Protheus.doc} ConfVlr
Confere valores selecionados no extrato e movimento.
Caso ambos sejam iguais, altera legenda do extrato e 
avanÁa nMarkConc
@author Augusto Ribeiro | www.compila.com.br
@since 25/01/2017
@version 6
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function ConfVlr()
LOCAL nI
Local nSelEx	:= 0
Local nSelMv	:= 0

IF nTotExCon == nTotMvCon
	IF !lVazioEx
		for nI:= 1 to Len(aDadosEx)
			IF aDadosEx[nI, nEXCONCI] == nMarkConc
				aDadosEx[nI, 2]	:= D_CONCILIADO	
				nSelEx++		
			ENDIF		
		next nI
	ENDIF
	
	for nI:= 1 to Len(aDadosMv)
		IF aDadosMv[nI, nMVCONCI] == nMarkConc

			/*------------------------------------------------------ Augusto Ribeiro | 15/02/2017 - 4:34:27 PM
				Recurso de Auto Conciliacao - Registros da mesma origem
			------------------------------------------------------------------------------------------*/
			IF nSelEx == 0
				aDadosMv[nI, 2]	:= D_CONCILIADO_AUTO
			ELSE
				aDadosMv[nI, 2]	:= D_CONCILIADO	
			ENDIF
		
			
			nSelMv++
		ENDIF		
	next nI	

	/*------------------------------------------------------ Augusto Ribeiro | 15/02/2017 - 4:34:27 PM
		Recurso de Auto Conciliacao - Registros da mesma origem
	------------------------------------------------------------------------------------------*/	
	IF nSelMv == 0 .AND. nSelEx >= 2
		IF !lVazioEx
			for nI:= 1 to Len(aDadosEx)
				IF aDadosEx[nI, nEXCONCI] == nMarkConc
					aDadosEx[nI, 2]	:= D_CONCILIADO_AUTO		
				ENDIF		
			next nI
		ENDIF
	ENDIF
	
	
	nMarkConc++
	
	oLbxEx:Refresh()
	oLbxMv:Refresh()

ENDIF

Return()





/*/{Protheus.doc} DesmConc
Desmarcar Registros marcados como conciliado
@author Augusto Ribeiro | www.compila.com.br
@since 25/01/2017
@version 6
@param nMarkAnt, IDMark do conciliado desmarcado
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function DesmConc(nMarkAnt)
LOCAL nI
Local nTotAux

nTotAux	:= 0
IF !lVazioEx
	for nI:= 1 to Len(aDadosEx)
		IF aDadosEx[nI, nEXCONCI] == nMarkAnt
			
			IF aDadosEx[nI, 2]	== D_CONCILIADO .OR. aDadosEx[nI, 2] == D_CONCILIADO_AUTO
				aDadosEx[nI, 2]			:= D_SELECIONADO
				aDadosEx[nI, nEXCONCI]	:= nMarkConc
			ENDIF		
		ENDIF	
		
		/*--------------------------
			Recalcula valor selecionado
		---------------------------*/
		IF aDadosEx[nI, nEXCONCI] == nMarkConc
			nTotAux	+= aDadosEx[nI, nZB2VALOR]
		ENDIF
			
	next nI
endif
nTotExCon	:= nTotAux


nTotAux	:= 0
for nI:= 1 to Len(aDadosMv)
	IF aDadosMv[nI, nMVCONCI] == nMarkAnt
		
		IF aDadosMv[nI, 2]	== D_CONCILIADO .OR. aDadosMv[nI, 2] == D_CONCILIADO_AUTO 
			aDadosMv[nI, 2]			:= D_SELECIONADO
			aDadosMv[nI, nMVCONCI]	:= nMarkConc
		ENDIF		
	ENDIF	
	
	/*--------------------------
		Recalcula valor selecionado
	---------------------------*/
	IF aDadosMv[nI, nMVCONCI] == nMarkConc
		nTotAux	+= aDadosMv[nI, nE5VALOR]
	ENDIF
		
next nI
nTotMvCon	:= nTotAux




oLbxEx:Refresh()
oLbxMv:Refresh()


Return()






/*
‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥FINR470   ∫Autor  ≥ Rodrigo Oliveira   ∫ Data ≥  09/11/15   ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ FunÁ„o para c·lculo do saldo inicial de banco compart.     ∫±±
±±∫          ≥ e saldo exclusivo                                          ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ
*/

Static Function CalcSldIni(nSaldoAtu, nSaldoIni, cBanco, cAgencia, cConta, dDataSaldo) 

Local cSaldo 	:= GetNextAlias()
Local cQry		:= ""
Local nMoeda	:= 1
Local cFl 		:= ""
Local nSld		:= 0
Local nSlRec	:= 0
///dDataSaldo	:= dDataSaldo+1
cQry := " SELECT E8_FILIAL, E8_BANCO, E8_AGENCIA, E8_CONTA, E8_DTSALAT, E8_SALATUA, E8_SALRECO "
cQry += " FROM " + RetSqlName("SE8") + " SE8 " 
cQry += " WHERE E8_BANCO 	= '" + cBanco + "' "
cQry += " AND E8_AGENCIA 	= '" + cAgencia + "' "
cQry += " AND E8_CONTA 		= '" + cConta + "' "
cQry += " AND E8_DTSALAT	< '" + DTOS(dDataSaldo) + "' "
cQry += " AND D_E_L_E_T_ = '' "
cQry += " ORDER BY E8_FILIAL, E8_DTSALAT DESC "

dbUseArea(.T., "TOPCONN", TCGenQry(,,cQry), cSaldo, .T., .T.)

(cSaldo)->(DbGoTop())

cFl 	:= (cSaldo)->E8_FILIAL
nSld	:= (cSaldo)->E8_SALATUA
nSlRec	:= (cSaldo)->E8_SALRECO

While !Eof()
	
	If (cSaldo)->E8_FILIAL != cFl
		nSld	+= (cSaldo)->E8_SALATUA
		nSlRec	+= (cSaldo)->E8_SALRECO
		cFl 	:= (cSaldo)->E8_FILIAL
	EndIf
	DbSkip()	
EndDo
 
(cSaldo)->(DbCloseArea())


	nSaldoAtu:=Round(xMoeda(nSlRec,1,1,SE8->E8_SALATUA),2)
	nSaldoIni:=Round(xMoeda(nSlRec,1,1,SE8->E8_DTSALAT),2)

Return()






/*/{Protheus.doc} ParamRA
Parametros para geraÁ„o do RA
@author Augusto Ribeiro | www.compila.com.br
@since 16/11/2017
@version 6
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function ParamRA()
Local aRet	:= {.f.,"",{}}
Local nI
//Parametros para Filtrar Cliente
Private aParams:={}
Private aRetPar:={}



AADD(aParams,{1,"Filial",PADR("",TAMSX3("E1_FILIAL")[1]),,"","SM0","",,.F.,})
AADD(aParams,{1,"Cliente",PADR("",TAMSX3("A1_COD")[1]),,"","SA1","",,.F.,})
AADD(aParams,{1,"Loja",PADR("",TAMSX3("A1_LOJA")[1]),,"","","",,.F.,})
AADD(aParams,{1,"HistÛrico",PADR("",TAMSX3("E1_HIST")[1]),,"","","",100,.F.,})
/*
//Parametros da ficha de opcional
//| |         1   2                  3           4 5  6    7  8           9
aAdd(aParams,{1,"Banco Destino"			,Space(nBco)	, , ,"SA6", ,		,.T.})
aAdd(aParams,{1,"Agencia Destino"		,Space(nAg)		, , ,     , ,		,.T.})
aAdd(aParams,{1,"Conta Destino"			,Space(nCC)		, , ,     , ,		,.T.})
aAdd(aParams,{1,"Natureza"		,Space(nNat)		, , ,"SED", ,		,.T.})
//aAdd(aParams,{1,"Historico"		,Space(nHist)	, , ,     , ,nHist		,.T.})
aAdd(aParams,{1,"Tipo Lanc"		,Space(nTpLanc)	, , ,"14" , ,	,.T.})
*/

If ParamBox(aParams,"Parametros para inclus„o do RA",@aRetPar)

	FOR nI := 1 TO len(aRetPar)
		IF EMPTY(aRetPar[nI])
			aRet[2]	:= "Todos os parametros s„o de preenchimento obrigatÛrio."
			EXIT
		ENDIF
	NEXT nI
ELSE
	aRet[2]	:= "Todos os parametros s„o de preenchimento obrigatÛrio.."
Endif

IF EMPTY(aRet[2])
	aRet[1]	:= .t.
	aRet[3]	:= aRetPar
endif


Return(aRet)





/*/{Protheus.doc} CP11MVRA
Gera movimento RA com base no movimento unificado ZCA passado
@author Augusto Ribeiro | www.compila.com.br
@since 16/11/2017
@version version
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
User Function CP09MVRA(nRecZB2, cFilRA, cCodCli, cLoja, cHist)
Local aRet		:= {.F., ""}
Local cQuery	:= ""
Local nI
Local aRetRA	:= {}
Local cNumRA, aRetBco
Local nVlrAjus, nVlrRA

IF !EMPTY(nRecZB2) .AND.;
 	!EMPTY(cFilRA) .AND.;
 	!EMPTY(cCodCli) .AND.;
 	!EMPTY(cLoja)


	DBSELECTAREA("ZB2")
	ZB2->(DBGOTO(nRecZB2))
	
	cNumRA		:= RIGHT(ALLTRIM(ZB2->ZB2_CODIGO), 9)

	
	BEGIN TRANSACTION
	
	aRetRA	:= U_CP09RA(cFilRA, cNumRA, cCodCli, cLoja, ZB2->ZB2_VALOR, ZB2->ZB2_DATA, cpBanco, cpAg, cpConta, cHist)
	
	IF aRetRA[1]
		
		aRet[1]	:= .T.
	ELSE
		aRet[2] := aRetRA[2]+"." 			
	ENDIF
	
	END TRANSACTION

ELSE
	aRet[2] := "Parametros inv·lidos. [CP11MVRA]"
ENDIF	
	
	
Return(aRet)





/*/{Protheus.doc} CP11RA
Inclui RA no Contas a Receber
@author Augusto Ribeiro | www.compila.com.br
@since 15/11/2017
@version 6
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
User Function CP09RA(cFilRA, cNumRA, cCodCli, cLoja, nValor, dData, cBanco, cAgenc, cConta, cHist)
Local aRet		:= {.F., "", 0}
Local aTtAuto	:= {}
Local dDataAnt	:= dDataBase
Local _cFilNew, cPref, cNatRA
Local cAutoLog, cMemo

Default cHist := ""

IF !EMPTY(cFilRA) .AND.;
	!EMPTY(cNumRA) .AND.;
	!EMPTY(cCodCli) .AND.;
	!EMPTY(cLoja) .AND.;
	!EMPTY(nValor) .AND.;
	!EMPTY(dData) .AND.;
	!EMPTY(cBanco) .AND.;
	!EMPTY(cAgenc) .AND.;
	!EMPTY(cConta) 
	
	//| Normaliza para n„o dar erro na execauto|
	cBanco	:= PADR(alltrim(cBanco),TAMSX3("E1_PORTADO")[1])
	cAgenc	:= PADR(alltrim(cAgenc),TAMSX3("E1_AGEDEP")[1])
	cConta	:= PADR(alltrim(cConta),TAMSX3("E1_CONTA")[1])

	/*---------------------------------------
		Realiza a TROCA DA FILIAL CORRENTE 
	-----------------------------------------*/
	_cCodEmp 	:= SM0->M0_CODIGO
	_cCodFil	:= xfilial("SE1")
	_cFilNew	:= PADR(cFilRA,12) //| CODIGO DA FILIAL DE DESTINO 
	
	IF _cCodEmp+_cCodFil <> _cCodEmp+_cFilNew
		CFILANT := _cFilNew
		opensm0(_cCodEmp+CFILANT)
	ENDIF	

	
	DBSELECTAREA("SE1")
	SE1->(DBSETORDER(1))
	SE1->(DBSEEK(CFILANT))
	IF LEN(ALLTRIM(cFilRA)) < 12
		cFilRA	:= SE1->E1_FILIAL
	ENDIF
	
	
	cPref		:= "FIN" //SUPERGETMV("CP11_RAPRE",.F.,"")
	cNatRA		:= "11010006" //SUPERGETMV("CP11_RANAT",.F.,"")

	dDataBase	:= dData
	
	AADD(aTtAuto , {"E1_FILIAL"		, cFilRA											, NIL})						
	AADD(aTtAuto , {"E1_PREFIXO"	, cPref												, NIL})
	AADD(aTtAuto , {"E1_NUM"    	, cNumRA											, NIL})	
	AADD(aTtAuto , {"E1_TIPO"   	, "RA"												, NIL})
	AADD(aTtAuto , {"E1_PORTADO"  	, cBanco											, NIL})
	AADD(aTtAuto , {"E1_AGEDEP"  	, cAgenc											, NIL})
	AADD(aTtAuto , {"E1_CONTA"  	, cConta											, NIL})	
	AADD(aTtAuto , {"E1_NATUREZ"	, cNatRA											, NIL})
	AADD(aTtAuto , {"E1_VENCTO" 	, DDATABASE											, NIL})
	AADD(aTtAuto , {"E1_VENCREA"	, DataValida(DDATABASE,.T.)							, NIL})
	AADD(aTtAuto , {"E1_VENCORI"	, DataValida(DDATABASE,.T.)							, NIL})
	AADD(aTtAuto , {"E1_EMISSAO"	, dDataBase											, NIL})
	AADD(aTtAuto , {"E1_EMIS1"		, dDataBase											, NIL})
	AADD(aTtAuto , {"E1_CLIENTE"	, cCodCli											, NIL})
	AADD(aTtAuto , {"E1_LOJA"   	, cLoja												, NIL})
	AADD(aTtAuto , {"E1_VALOR"  	, nValor											, NIL})
	AADD(aTtAuto , {"E1_HIST"    	, cHist 											, NIL})

	//AADD(aTtAuto , {"E1_ORIGEM"  	, "AFIN081"			
	
	lMSHelpAuto := .T. //.F. // para nao mostrar os erro na tela
	lMSErroAuto := .F. //.F. // inicializa como falso, se voltar verdadeiro e' que deu erro

	MsExecAuto( { |x,y| FINA040(x,y)} , aTtAuto, 3)  // 3 - Inclusao, 4 - AlteraÁ„o, 5 - Exclus„o
	
	If lMsErroAuto
		//MostraErro()
		cAutoLog	:= alltrim(NOMEAUTOLOG())

		cMemo := STRTRAN(MemoRead(cAutoLog),'"',"")
		cMemo := STRTRAN(cMemo,"'","")

		//| Apaga arquivo de Log
		Ferase(cAutoLog)

		//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
		//≥ Le Log da Execauto e retorna mensagem amigavel ≥
		//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
		aRet[2] := U_CPXERRO(cMemo)

		IF EMPTY(aRet[2])
			aRet[2]	:= alltrim(cMemo)
		ENDIF

		DisarmTransaction()		
	ELSE
		aRet[1] 	:= .T.
		aRet[3] 	:=  SE1->(RECNO())		
	ENDIF	
	
	
	/*---------------------------------------
		Restaura FILIAL  
	-----------------------------------------*/
	IF _cCodEmp+_cCodFil <> _cCodEmp+_cFilNew
		CFILANT := _cCodFil
		opensm0(_cCodEmp+CFILANT)			 			
	ENDIF	
	
	//| Restaura database |
	dDataBase	:= dDataAnt
ELSE
	aRet[2]	:= "Parametros Invalidos [CP11GRA]"
ENDIF

 
Return(aRet)



