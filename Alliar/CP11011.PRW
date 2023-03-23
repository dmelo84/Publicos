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
#DEFINE MOTBX_NORMAL "NOR"
#DEFINE MOTBX_TAXA "TXC"

#DEFINE D_PICTURE_VLR "@E 99,999,999.99"
#DEFINE D_PICTURE_VLRT "@E 99,999,999,999.99"


#DEFINE NOME_SEMAFORO "CP11011"


#DEFINE D_TITULO 'Baixa Manual Cart„o de CrÈdito'
#DEFINE D_ROTINA 'CP11011' 

#DEFINE D_PERG "CP11011"
#DEFINE D_PERG2 "CP11011A"
#DEFINE D_PERGB "CP11011B"


/*--------------------------
	LISTBOX Extrato
---------------------------*/
#DEFINE D_NAOSELECIONADO 0
#DEFINE D_SELECIONADO 1
#DEFINE D_CONCILIADO 2
#DEFINE D_TAXA 3
//#DEFINE D_CONCILIADO_AUTO 4
#DEFINE D_RECEB_ANTECIPADO 4


/*--------------------------
	OPCOES RADIO
---------------------------*/
//#DEFINE OPCAO_CONCILIACAO 1
//#DEFINE OPCAO_TAXA 2
#DEFINE OPCAO_BAIXA 1
#DEFINE OPCAO_MOVIMENTO_BANCARIO 2
#DEFINE OPCAO_RECEB_ANTECIPADO 3



/*-----------------------------------------------------------------
	TIPO OPERACAO | ZCB - Mov. Unificado x Financeiro SE1, SE5
------------------------------------------------------------------*/
#DEFINE ZCB_TPOPER_BAIXA 			"1"
#DEFINE ZCB_TPOPER_MOV_BANCARIO 	"2"
#DEFINE ZCB_TPOPER_ESTORNO			"3"



/*-----------------------------------------------------------------
	STATUS | ZCA Mov. Unificado
------------------------------------------------------------------*/
#DEFINE ZCA_STATUS_PENDENTE			"1"
#DEFINE ZCA_STATUS_PARCIAL 			"2"
#DEFINE ZCA_STATUS_CONCLUIDO 		"3"
#DEFINE ZCA_STATUS_INCONSISTENCIA 	"4"
#DEFINE ZCA_STATUS_FALHA 			"5"
#DEFINE ZCA_STATUS_DESCONSIDERADO	"6"


/*--------------------------
	RAZAO STATUS
---------------------------*/
#DEFINE RAZ_NAO_LOCALIZADO		"001" //| TITULO NAO LOCALIZADO |
#DEFINE RAZ_JA_BAIXADO 			"002" //| TITULO JA BAIXADO |
#DEFINE RAZ_DIVERGENCIA_SALDO 	"003" //| SALDO DO TITULO DIVERGENTE DO MOVIMENTO ADQUIRENTE |
#DEFINE RAZ_CONTA_NAO_LOCAZ		"004" //| CONTA NAO LOCALIZADA NO CADASTRO DE BANCOS [E6_XCONCAR]                                             |
#DEFINE RAZ_PV_NAO_FATURADO		"005" //| TITULO NAO LOCALIZADO

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
//Static nTotMA	:= 0



/*/{Protheus.doc} CP11011
Conciliador banc·rio
@author Augusto Ribeiro | www.compila.com.br
@since 31/03/2016
@version 6
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
User function CP11011()
Private lSelConc	:= .T.
Private	lSelTaxa	:= .F.

Private oFList		:= TFont():New("Courier New",, 15, , .F., , , , .F., .F.) // Regular
//Private nZB2VALOR, nZB2DATA, nZCARECNO, nZB2DESC, nMACONCI, nZB2SE5
Private nZCAVBRUTO, nZCASALDO, nZCADTPAG, nZCADTVEN, nZCARECNO, nZCACODAUT, nMACONCI, nZB2SE5
//Private nE5VALOR, nE5DTDISPO, nE5HISTOR, nE1FILIAL, nE5NATUREZ, nE5CCUSTO, nSE1RECNO, nSE1ZCA, nCRCONCI
Private nE1FILIAL, nE1EMISSAO, nE1SALDO, nE1VALOR, nE1NATUREZ, nE1CCUSTO, nSE1RECNO, nSE1ZCA, nCRCONCI, nAJUSTE, nE1PORTADO, nE1AGEDEP, nE1CONTA, nE1CLIENTE, nE1LOJA

Private oTotMA, oTotCon, oTotTaxa, oTotCR, cTotalMv, oGetTeste
Private oSelMA, cSelMA, oSelCR, cSelCR, cGetTeste
Private oPaneRod	:= nil
Private aDim		:= {}

Private	nSaldoMA	:= 0 //| Saldo do movimento|
Private	nSaldoCR	:= 0 //| Saldo do movimento|

/*------------------------------------------------------ Augusto Ribeiro | 25/01/2017 - 3:48:38 PM
Variaveis utilizadas no controle de multipla selecoes .
Relacionamento N para N

------------------------------------------------------------------------------------------*/
Private nMarkConc	:= 1 
Private nTotMACon	:= 0
Private nTotCRCon	:= 0


/*--------------------------
	PARAMETROS 
---------------------------*/
Private cpFilDe, cpFilAte, cpBanco, cpAg, cpConta, dpDtTrDe, dpDtTrAte, cpCodAdq, cpModalid, cpStatZCA, cpRazStat
Private c1FilDe, c1FilAte, c1DtDe, c1DtAte, c1DtVDe, c1DtVAte, c1Prefixo, c1Forma, c1CodCli, c1Loja, c1UnVAte, c1UnVDe

/*--------------------------
	LISTBOX EXTRATO
---------------------------*/
Private oLbxMA		:= Nil
Private aCpoEX		:= {}
Private aDadosMA	:= {}
Private aHeadEx		:= {}
Private lVazioEx	:= .T.
//| Variaveis para Ordenacao da coluna|
Private lAllExt		:= .F.
Private nAntExt		:= 0
Private	nDadosMA	:= 0

/*---------------------------------
	LISTBOX MOVIMENTO BANCARIO
----------------------------------*/
Private oLbxCR		:= Nil
Private aCpoCR		:= {}
Private aDadosCR	:= {}
Private aHeadMv		:= {}
Private lVazioMv	:= .T.
//| Variaveis para Ordenacao da coluna|
Private lAllMv		:= .F.
Private nAntMv		:= 0
Private	nDadosCR	:= 0

/*------------------------------------------------------ Augusto Ribeiro | 26/12/2016 - 5:55:21 PM
	Variaveis para controle da seleÁ„o da conciliaÁ„o
------------------------------------------------------------------------------------------*/
Private aSelMA	:= {}
Private aSelCR	:= {} 

Private nTolera	:= 0 //| para consiliaÁao|

Private nConcTaxa := OPCAO_BAIXA //| 1=Concilia, 2=Taxa Selecao de movimento para consiliaÁ„o ou TAXA|

Private nTotMA	:= 0
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


	cpBanco		:= MV_PAR01
	cpAg		:= MV_PAR02
	cpConta		:= MV_PAR03	
	dtCredDe	:= MV_PAR04
	dtCredAte	:= MV_PAR05	
	//dpDtTrDe	:= MV_PAR06
	//dpDtTrAte	:= MV_PAR07	
	cpCodAdq	:= MV_PAR06
	cpModalid	:= MV_PAR07
	cpStatZCA	:= MV_PAR08
	cpRazStat	:= MV_PAR09

	IF  PERGUNTE(D_PERGB ,.T.)
	
		c1FilDe		:= MV_PAR01
		c1FilAte	:= MV_PAR02
		c1DtVDe		:= MV_PAR03	
		c1DtVAte	:= MV_PAR04		
		c1DtDe		:= MV_PAR05	
		c1DtAte		:= MV_PAR06					
		//c1Prefixo	:= MV_PAR07
		c1Forma		:= MV_PAR07
		c1CodCli	:= MV_PAR08
		c1Loja		:= MV_PAR09
		c1UnVDe		:= MV_PAR10
		c1UnVAte	:= MV_PAR11
		//nSaldoCR	:= SaldoCR(cpBanco, cpAg, cpConta, dpDtTrAte)
		//nSaldoMA	:= SaldoMA(cpBanco, cpAg, cpConta, dpDtTrAte)
		
		FWExecView("Baixa Manual Cart„o Credito",  D_ROTINA,  3,  /*oDlg*/,  /*bCloseOnOk*/,  /*bOk*/, /* nPercReducao*/, /*aEnableButtons*/,  /*bCancel*/ )// == 0
		/*
		IF lExecConc
			ConcAuto()
		ENDIF
		IIF(lExecConc, ConcAuto(), .F.)
		*/
	ENDIF
ENDIF


Return NIL

        
/*‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥ CP11011  ∫Autor  ≥Augusto Ribeiro     ∫ Data ≥ 07/01/2011  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ 	Botoes do MBrowser                                        ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/  
Static Function MenuDef()
Local aRotina := {}


ADD OPTION aRotina TITLE 'Pesquisar'  ACTION 'PesqBrw'             OPERATION 1 ACCESS 0
ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.'+D_ROTINA OPERATION 2 ACCESS 0                         
ADD OPTION aRotina TITLE 'Incluir'  ACTION 'VIE7DEF.'+D_ROTINA OPERATION 3 ACCESS 0  	
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
±±∫Programa  ≥ CP11010  ∫Autor  ≥Augusto Ribeiro     ∫ Data ≥ 07/01/2011  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ 	Definicoes do Model                                       ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/  
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oStruct := FWFormStruct( 1, "ZCA", /*bAvalCampo*/,/*lViewUsado*/ )
Local oStruZCB := FWFormStruct( 1, "ZCB", /*bAvalCampo*/,/*lViewUsado*/ )
//Local oStruZG7 := FWFormStruct( 1, 'ZG7', /*bAvalCampo*/,/*lViewUsado*/ )
Local oModel   

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New('ZCAMODEL', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

// Adiciona ao modelo uma estrutura de formul·rio de ediÁ„o por campo
oModel:AddFields( "ZCAMASTER", /*cOwner*/, oStruct, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )  

// Adiciona ao modelo uma estrutura de formul·rio de ediÁ„o por grid
oModel:AddGrid( 'ZCBITEM', "ZCAMASTER", oStruZCB, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

// Faz relaciomaneto entre os compomentes do model
oModel:SetRelation( 'ZCBITEM', { { 'ZCB_FILIAL', 'XFILIAL("ZCB")' }, { 'ZCB_CODMOV', 'ZCA_CODIGO' } }, ZCB->(IndexKey(2)) ) //| ZCB_FILIAL, ZCB_CODMOV, ZCB_ALIAS, ZCB_RECALI, R_E_C_N_O_, D_E_L_E_T_|

// Liga o controle de nao repeticao de linha
//oModel:GetModel( 'ZG7DETAIL' ):SetUniqueLine( { 'ZG7_CHAVE' } )

// Indica que È opcional ter dados informados na Grid
//oModel:GetModel( 'ZG7DETAIL' ):SetOptional(.T.)


// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( D_TITULO )

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( "ZCAMASTER" ):SetDescription( 'Movimento Adquirente (unificado)' )
oModel:GetModel( 'ZCBITEM' ):SetDescription( 'Titulos/Movimento Financeiro'  )

// Liga a validaÁ„o da ativacao do Modelo de Dados
//oModel:SetVldActivate( { |oModel| COMP011ACT( oModel ) } )

oModel:SetActivate( {|oModel| SetKey ( VK_F5, {||   U_CP1111BTN('EFETIVA') } ),;
								SetKey ( VK_F7, {||  U_CP1111BTN('DESCONTO') } ),;
								SetKey ( VK_F8, {||  U_CP1111BTN('ADQUIRENTE') } ),;
								SetKey ( VK_F9, {||  U_CP1111BTN('TITULO') } ) })
								


Return oModel


/*/{Protheus.doc} ViewDef
Definicoes da View  
@author Augusto Ribeiro | www.compila.com.br
@since 21/10/2017
@version 6
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/  
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


oView:AddOtherObject("EXTRATO"		, {|oPanel| U_CP1111MA("C",@oLbxMA,@aCpoEx,@aHeadEx, @aDadosMA, oPanel)  })
oView:AddOtherObject("MOVIMENTO"	, {|oPanel| U_CP1111CR("C",@oLbxCR,@aCpoCR,@aHeadMv, @aDadosCR, oPanel)  })


// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'EXTRATO', 'LEFT_SUP')
oView:SetOwnerView( 'MOVIMENTO', 'RIGHT_SUP')

// Define campos que terao Auto Incremento
//oView:AddIncrementField( 'VIEW_ZEH', 'ZEH_CODITE' )

oView:AddOtherObject("RODAPE", {|oPanel| ListTot(oPanel)})
oView:SetOwnerView("RODAPE",'INFERIOR')



// Criar novo botao na barra de botoes no antigo Enchoice Bar            
oView:AddUserButton( 'Parametros de Filtro.', 'Parametros Filtro', { |oView| U_CP1111BTN('PERG_FILTRO', oView) } )
oView:AddUserButton( 'Parametros do Conciliador. F10', 'Parametros Conciliador ', { |oView| U_CP1111BTN('PERG_CONC', oView) } )
oView:AddUserButton( 'Conc. Autom·tica', 'Conc. Autom·tica', { |oView| U_CP1111BTN('CONC_AUTO', oView) } )
//oView:AddUserButton( 'Transferencia Mov. Bancario. F11', 'Transferencia', { |oView| U_CP1111BTN('TRANSF', oView) } )
oView:AddUserButton( 'Efetivar Baixa/ConciliaÁ„o. F5', 'Efetivar Baixa/ConciliaÁ„o', { |oView| U_CP1111BTN('EFETIVA', oView) } )
oView:AddUserButton( 'Aplicar Desconto. F7', 'Aplicar Desconto', { |oView| U_CP1111BTN('DESCONTO', oView) } )
oView:AddUserButton( 'Visualizar Mov. Adquirente. F8', 'Visualizar Adquirente', { |oView| U_CP1111BTN('ADQUIRENTE', oView) } )
oView:AddUserButton( 'Visualizar titulo. F9', 'Visualizar titulo', { |oView| U_CP1111BTN('TITULO', oView) } )


//oView:AddUserButton( 'Gerar RA. F8', 'Gerar RA', { |oView| U_CP1111BTN('GERA_RA', oView) } )

//oView:AddUserButton( 'FunÁıes Contas a Pagar', 'FunÁıes Contas a Pagar', { |oView| U_CP1111BTN('FCP', oView) } )
//oView:AddUserButton( 'FunÁıes Contas a Receber', 'FunÁıes Contas a Receber', { |oView| U_CP1111BTN('FCR', oView) } )

//oView:AddUserButton( 'Parametros do Conciliador', 'Parametros', { |oView| U_CP1111BTN('PARAMETROS', oView) } )

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


/*/{Protheus.doc} CP1111MA
Montas Listbox com dados do Movimento das adquirentes Unificado
@author Augusto Ribeiro | www.compila.com.br
@since 26/12/2016
@version 6
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
//User Function CP902LEX(cOpcList, oLbxMA, aCpoHeader, aHeader, aDados, oPanel )
User Function CP1111MA(cOpcList, oLbxMA, aCpoHeader, aHeader, aDados, oPanel )
Local lRet			:= .T.
Local aVlrCor		:= {} 


Private aCpoHeader

Default	cOpcList	:= "C"

Default aCpoHeader	:= {} 
Default aHeader		:= {} 
Default aDados		:= {}

Default	oLbxMA		:= NIL
Default	oPanel		:= NIL

//IF cOpcList	== "A"
	aRetAux	:= qMovUnif() 
	aDadosMA	:= {}
	//IF aRetAux[1]
		aCpoEX		:= aRetAux[2]
		aHeadEx	:= aRetAux[3]
		aDadosMA	:= aRetAux[4]
		//nDadosMA	:= len(aDadosMA[1])


			
		lRet	:= .T.
	
	//ELSE
		//Help(" ",1,"VAZIO",,"N„o existem registros no periodo selecionado.",4,5)
		//lVazio := .t.
	//	ENDIF




aCpoHeader		:= aCpoEX
aHeader			:= aHeadEx
aDados			:= aDadosMA
//aDadosLbx		:= aClone(aDadoTit)	

	lVazioEx := empty(aDadosMA)

	MontLis(cOpcList, @oLbxMA, @aCpoHeader, @aHeader, @aDados, @oPanel)

Return()


/*/{Protheus.doc} MontLis
Monta Interface de seleÁ„o
@author Jonatas Oliveira | www.compila.com.br
@since 14/04/2016
@version 1.0
/*/
Static Function MontLis(cOpcList, oLbxMA, aCpoHeader, aHeader, aDados, oPanel)

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

	Private oDlgMain	:= NIL

	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	//≥ cOpcList | C = Cria, A = Atualiza ≥
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	IF cOpcList == "C"
	
		

		@ 3, 5 SAY oLblSolicita PROMPT "Movimento Adquirentes" SIZE 150, 012 OF oPanel FONT oFLabels COLORS RGB(56,141,191), 16777215 PIXEL
		@ 12,0 LISTBOX oLbxMA FIELDS HEADER ;
		FONT oFList;   
		" ", "Campos" ;                                                                                                    
		SIZE (oPanel:nClientWidth/2)-5,(oPanel:nClientHeight/2)-12 OF oPanel PIXEL ON  dblClick(SelMA(@oLbxMA), ListTot(), oLbxMA:Refresh())

		oLbxMA:aheaders := aHeader			   
		oLbxMA:BHEADERCLICK	:= { |oObj,nCol| OrdExt( oObj,nCol, .T.) }		
	ENDIF
	
	/*
	@  250, 40 		SAY oLblSolicita PROMPT "Total " 		SIZE 50, 014 OF oDlgMain FONT oFGrpCpo COLORS 128, 16777215 PIXEL
	oTotalP := TGet():Create( oDlgMain,{|| CalcTot("TP", @aDadoMain)},250, 40	, 050,009,D_PICTURE_VLRT,,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,cTotalP,,,, )
	*/
	IF EMPTY(aDados)
	
	
		/*------------------------------------------------------ Augusto Ribeiro | 02/11/2017 - 4:49:06 PM
			Monta Array Vazio para n„o dar erro na interface
		------------------------------------------------------------------------------------------*/
		aDados	:= {{}}
		aadd(aDados[1], .F.)
		aadd(aDados[1], 0)
		
		FOR nI := 3 to len(aHeader)
		
			IF nI == nZCASALDO .OR.;
				nI == nZCAVBRUTO
				aadd(aDados[1], 0)
			ELSE
		
				aadd(aDados[1], '')
			ENDIF
		NEXT nI
	ENDIF   
	
		oLbxMA:nAt	:= 1
	
		oLbxMA:SetArray( aDados )  
		//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
		//≥ Cria string com Bloco de Codigo ≥
		//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
		//	cBCodLin	:= "LoadBitmap( GetResources(), aDados[oLbxMA:nAt,"+alltrim(str(nP04STATUS))+"] ) "
		
		/*
		#DEFINE D_NAOSELECIONADO 0
		#DEFINE D_SELECIONADO 1
		#DEFINE D_CONCILIADO 2
		#DEFINE D_TAXA 3
		#DEFINE D_CONCILIADO_AUTO 4
		*/
		//oAzul
		
	
		cBCodLin	:= "Iif(aDados[oLbxMA:nAt,1],oOk,oNo), Iif(aDados[oLbxMA:nAt,2]==2,oVerde,Iif(aDados[oLbxMA:nAt,2]==3,oAzul, Iif(aDados[oLbxMA:nAt,2]==1,oAmarelo , Iif(aDados[oLbxMA:nAt,2]==4, oBranco, oCinza))))"
		//cBCodLin	:= "IIF(ALLTRIM(aDados[oLbxMA:nAt,nP04STATUS]) == alltrim(X3COMBO('P04_STATUS','4')), oNo, Iif(aDados[oLbxMA:nAt,1],oOk,oNo))"
	
	
		For nI := 3 To LEN(aHeader)
			IF nI > 1
				cBCodLin	+=", "
			endif
			cI	:= alltrim(str(nI))
			
			IF ALLTRIM(aCpoHeader[nI]) $ "ZCA_VBRUTO/ZCA_VTAXA/ZCA_VLIQ/ZCA_SALDO"
				cBCodLin	+= "Transform(aDados[oLbxMA:nAt,"+cI+"], '"+D_PICTURE_VLR+"')"
			ELSE
				cBCodLin	+= "aDados[oLbxMA:nAt,"+cI+"]"		
			ENDIF
			
		Next nI	
	
		
	
		cBCodLin	:= "oLbxMA:bLine := {|| {"+cBCodLin+"}}"
		&(cBCodLin)    
	     


	oLbxMA:Refresh()

	
	nSaldoMA	:= SaldoMA()

Return    






/*/{Protheus.doc} qMovUnif
Busca registros do movimento unificado
@author Augusto Ribeiro | www.compila.com.br
@since 16/04/2016
@version 6
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function qMovUnif()
Local aCpoHeader	:= {} 
Local aHeader		:= {} 
Local aDados		:= {}
Local aRet			:= {.F., aCpoHeader, aHeader, aDados}
//Local cAbatim		:= alltrim(MVABATIM) + "|" + alltrim(MVRECANT) + "|" + alltrim(MV_CRNEG)
Local nCpoQry		:= 0
Local nY, nI, cForma, aRetAux
Local cQuery		:= ""
Local cDigConta		:= ""
Local cMsgWarn		:= ""
Local cContaCart	:= ""
Local cFlCtaIni		:= ""
Local cFlCtaFim		:= ""
Local cCtaConc		:= ""

cQuery += "  SELECT ZCA_DTPAG,   "+CRLF
cQuery += "  		ZC1.ZC1_DESC,  "+CRLF
cQuery += "  		ZCA.ZCA_SALDO,  "+CRLF
cQuery += "  		ZCA.ZCA_CODAUT,  "+CRLF
cQuery += "  		ZCA.ZCA_VBRUTO,  "+CRLF
cQuery += "  		ZCA.ZCA_VTAXA,  "+CRLF
cQuery += "  		ZCA.ZCA_VLIQ,  "+CRLF
cQuery += "  		ZCA_CARMAS,  "+CRLF
cQuery += "  		ZCA.ZCA_NUMPAC,  "+CRLF
cQuery += "  		ZCA.ZCA_QTDPAR,  "+CRLF
cQuery += "  		ZCA.ZCA_DTVEND,  "+CRLF
cQuery += "  		ZCA.ZCA_BANCO,  "+CRLF
cQuery += "  		ZCA.ZCA_AGENC,  "+CRLF
cQuery += "  		ZCA.ZCA_CONTA,  "+CRLF
cQuery += "  		ZCA.ZCA_CODIGO,  "+CRLF
cQuery += "  		ZCA.R_E_C_N_O_ AS ZCA_RECNO  "+CRLF
cQuery += "  FROM "+RetSqlName("ZCA")+" ZCA "+CRLF
cQuery += "  INNER JOIN "+RetSqlName("ZC1")+" ZC1 "+CRLF
cQuery += "  	ON ZC1.ZC1_FILIAL = ''  "+CRLF
cQuery += "  	AND ZC1.ZC1_CODIGO = ZCA_CODADQ  "+CRLF
cQuery += "  	AND ZC1.D_E_L_E_T_ = ''  "+CRLF
cQuery += "  WHERE ZCA_FILIAL = ''  "+CRLF
cQuery += "  AND ZCA_SALDO > 0 "+CRLF
//cQuery += "  AND ZCA_CODRAZ <> '"+RAZ_PV_NAO_FATURADO+"'  "+CRLF
cQuery += "  AND ZCA_STATUS NOT IN  ('"+ZCA_STATUS_CONCLUIDO+"','"+ZCA_STATUS_DESCONSIDERADO+"') "+CRLF
IF !EMPTY(cpBanco)
	cQuery += "  AND ZCA_BANCO = '"+cpBanco+"' "+CRLF
ENDIF
IF !EMPTY(cpAg)
	cQuery += "  AND ZCA_AGENC = '"+cpAg+"' "+CRLF
ENDIF

cFlCtaIni := LEFT(c1FilDe,5)
cFlCtaFim := LEFT(c1FilAte,5)


IF !EMPTY(cpConta)

	cpConta		:= ALLTRIM(cpConta)

	/*------------------------------------------------------ Augusto Ribeiro | 02/11/2017 - 4:07:23 PM
		Busca numero da conta da adquirente
	------------------------------------------------------------------------------------------*/
	DBSELECTAREA("SA6")
	SA6->(DbOrderNickName("CONTACART")) //| A6_COD, A6_AGENCIA, A6_XCONCAR, R_E_C_N_O_, D_E_L_E_T_
	IF SA6->(DBSEEK(cpBanco+cpAg))
	
	 	WHILE SA6->(!EOF()) .AND. SA6->(A6_COD+A6_AGENCIA) == cpBanco+cpAg
	 		IF EMPTY(c1FilDe)
		 		IF ALLTRIM(SA6->A6_NUMCON) == cpConta
		 			cContaCart	:= SA6->A6_XCONCAR
		 			EXIT
		 		ENDIF
	 		ELSE
		 		/*----------------------------------------
					20/11/2017 - Jonatas Oliveira - Compila
					Com base na pergunta de filial busca as 
					contas pertinentes ‡ ela 
				------------------------------------------*/
	 			IF ALLTRIM(SA6->A6_FILIAL) >=  cFlCtaIni .AND. ALLTRIM(SA6->A6_FILIAL) <= cFlCtaFim
	 				IF !EMPTY(SA6->A6_XCONCAR) .AND. !SA6->A6_XCONCAR $ cCtaConc
						IF !EMPTY(cCtaConc)
							cCtaConc += "|"	
						ENDIF
										 
						cCtaConc +=  SA6->A6_XCONCAR 
					ENDIF 
	 			ENDIF 
	 			
	 		ENDIF 
	 		SA6->(DBSKIP())
	 	ENDDO
	ELSE
		cMsgWarn	:= "Banco, agencia e conta n„o localizada. Conta informada ser· DESCONSIDERADA no filtro."		
	ENDIF	
	
ELSE
	/*----------------------------------------
		20/11/2017 - Jonatas Oliveira - Compila
		Com base na pergunta de filial busca as 
		contas pertinentes ‡ ela 
	------------------------------------------*/
	IF !EMPTY(c1FilDe)
	
		DBSELECTAREA("SA6")
		SA6->(DBSETORDER(1))
		SA6->(DBGOTOP())
		
		WHILE SA6->(!EOF()) 
			
			IF !EMPTY(SA6->A6_XCONCAR) .AND. ALLTRIM(SA6->A6_FILIAL) >=  cFlCtaIni .AND. ALLTRIM(SA6->A6_FILIAL) <= cFlCtaFim .AND. !SA6->A6_XCONCAR $ 	cCtaConc
				IF !EMPTY(cCtaConc)
					cCtaConc += "|"	
				ENDIF
					 
				cCtaConc +=  SA6->A6_XCONCAR				  
			ENDIF 
			
		 	SA6->(DBSKIP())
		ENDDO
		
	ENDIF 
ENDIF

IF !EMPTY(cCtaConc)
	cQuery += "  AND ZCA_CONTA IN  "+INQuery(cCtaConc,"|")
	
	
	cMsgWarn	:= "ATEN«√O: Somente ser„o listados Movimentos da Adquirente no qual pertencerem as contas existentes nas Filiais selecionadas."
		
ELSEIF !EMPTY(cContaCart)
	cQuery += "  AND ZCA_CONTA = '"+cContaCart+"' "+CRLF
ELSEIF !EMPTY(c1FilDe) .AND. EMPTY(cCtaConc)
	cMsgWarn	:= "A filial selecionada n„o possui 'Conta Cart„o' vinculada no castro de bancos. Filial/Conta ser· DESCONSIDERADA no filtro."
ENDIF	

IF !EMPTY(cMsgWarn)
	MSGALERT(cMsgWarn,"Conta")
ENDIF

cQuery += "  AND ZCA_DTPAG BETWEEN '"+DTOS(dtCredDe)+"' AND  '"+DTOS(dtCredAte)+"' "+CRLF
//cQuery += "  AND ZCA_DTVEND BETWEEN '"+DTOS(dpDtTrDe)+"' AND  '"+DTOS(dpDtTrAte)+"' "+CRLF

IF !EMPTY(cpCodAdq)
	cpCodAdq	:= alltrim(cpCodAdq)
	cQuery += "  AND ZCA_CODADQ IN  "+INQuery(cpCodAdq, ,3)
ENDIF

IF ALLTRIM(cpModalid) <> "****"
	cpModalid	:= ALLTRIM(cpModalid)	
	cForma		:= ""
	
	IF RIGHT(cpModalid,1) == "T"
		cForma	+= " "
	ENDIF	
	
	IF SUBSTR(cpModalid,1,1) == "1"
		cForma	+= "D"
	ENDIF
	
	IF SUBSTR(cpModalid,2,1) == "2" .OR. SUBSTR(cpModalid,3,1) == "3"
		cForma	+= "C"
		
		IF SUBSTR(cpModalid,2,2) == "2*"
			cQuery += " AND ZCA.ZCA_QTDPAR <= 1 "+CRLF
		ELSEIF SUBSTR(cpModalid,2,2) == "*3"
			cQuery += " AND ZCA.ZCA_QTDPAR > 1 "+CRLF
		ENDIF
	ENDIF	
	
	IF !EMPTY(cForma)
		cQuery += " AND ZCA.ZCA_FORMA IN "+INQuery(cForma, ,1)
	ENDIF
	
ENDIF	

cpStatZCA := ALLTRIM(STRTRAN(cpStatZCA,"*"))

IF !EMPTY(cpStatZCA)
	cQuery += " AND ZCA.ZCA_STATUS IN "+INQuery(cpStatZCA, ,1)
ENDIF

IF !EMPTY(cpRazStat)
	cQuery += " AND ZCA.ZCA_CODRAZ = '"+ cpRazStat +"' "+CRLF
ENDIF
 
cQuery += "  AND ZCA.D_E_L_E_T_ = ''  "+CRLF

IF !(ISBLIND())
	MemoWrite(GetTempPath(.T.) + "CP11011_qMovUnif.SQL", cQuery)
ENDIF

If Select("TQRY") > 0
	TQRY->(DbCloseArea())
EndIf

dbUseArea(.T.,"TOPCONN",TCGenQRY(,,cQuery),'TQRY')

TCSetField("TQRY","ZCA_DTPAG","D",08,00)
TCSetField("TQRY","ZCA_DTVEND","D",08,00)

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
aadd(aCpoHeader, "ZCA_RECNO")
aadd(aCpoHeader, "EXCONCI")


//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Variaveis de posionamento dos campos ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
nZCAVBRUTO		:=  Ascan(aCpoHeader,"ZCA_VBRUTO")
nZCASALDO		:=  Ascan(aCpoHeader,"ZCA_SALDO")
nZCADTPAG		:=  Ascan(aCpoHeader,"ZCA_DTPAG")
nZCADTVEN		:=  Ascan(aCpoHeader,"ZCA_DTVEND")
nZCARECNO		:=  Ascan(aCpoHeader,"ZCA_RECNO")
nZCACODAUT		:=  Ascan(aCpoHeader,"ZCA_CODAUT")
nMACONCI		:=  Ascan(aCpoHeader,"EXCONCI")


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
		
			cVlrCpo	:= TQRY->(FIELDGET(nY))
			IF VALTYPE(cVlrCpo) =="C"
				cVlrCpo := ALLTRIM(cVlrCpo)
			ENDIF
	  		aadd(aLinha, cVlrCpo)

		Next nY	 
		aadd(aLinha, 0) //| EXCONCI |
		
		
		AADD(aDados, aLinha)
	

		TQRY->(DBSKIP())
	ENDDO   
	
	//nZCARECNO	:= LEN(aDados[1])

	
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
			IF  nConcTaxa == OPCAO_MOVIMENTO_BANCARIO //| tAXA|
				lAllExt	:= !(lAllExt)
				
				FOR nI :=  1 TO LEN(oLbxAux:aArray)
					IF lAllExt <> oLbxAux:aArray[nI,1]
						oLbxAux:nAt	:= nI
						SelMA(@oLbxAux)
					ENDIF
				Next nY
	
				//aEval(oLbxAux:aArray, {|x| x[1] := lAllExt} )
				nAntExt := nCol
			endif

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



/*/{Protheus.doc} CP1111CR
Montas Listbox com dados do Contas a Receber
@author Augusto Ribeiro | www.compila.com.br
@since 26/12/2016
@version 6
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
//User Function CP902LMV(cOpcList, oLbxCR, aCpoHeader, aHeader, aDados, oPanel )
User Function CP1111CR(cOpcList, oLbxCR, aCpoHeader, aHeader, aDados, oPanel )
Local lRet			:= .T.
Local aVlrCor		:= {} 


Private aCpoHeader

Default	cOpcList	:= "C"

Default aCpoHeader	:= {} 
Default aHeader		:= {} 
Default aDados		:= {}

Default	oLbxCR		:= NIL
Default	oPanel		:= NIL


//IF cOpcList	== "A"
	aRetAux		:= qMovimen() 
	aDadosCR	:= {}
	//IF aRetAux[1]
		aCpoCR		:= aRetAux[2]
		aHeadMv		:= aRetAux[3]
		aDadosCR	:= aRetAux[4]
		nDadosCR	:= 0
		IF !EMPTY(aDadosCR)
			nDadosCR	:= len(aDadosCR[1])
		ENDIF

			
		lRet	:= .T.
	
	//ELSE
		//Help(" ",1,"VAZIO",,"N„o existem registros no periodo selecionado.",4,5)
		//lVazio	:= .T.
	//ENDIF




aCpoHeader		:= aCpoCR
aHeader			:= aHeadMV
aDados			:= aDadosCR
//aDadosLbx		:= aClone(aDadoTit)	
lVazioMv := empty(aDadosCR)

ListMov(cOpcList, @oLbxCR, @aCpoHeader, @aHeader, @aDados, @oPanel)
IF !(lVazioMv) .AND. !(lVazioEx) 
	
	/*
	IF VALTYPE(oLbxMA) == "O"
		oLbxMA:lVisibleControl := .T.
	ENDIF	
	IF VALTYPE(oLbxCR) == "O"
		oLbxCR:lVisibleControl := .T.
	ENDIF	
	*/
ELSE
/*
	IF VALTYPE(oLbxMA) == "O"
		oLbxMA:lVisibleControl := .F.
	ENDIF	
	IF VALTYPE(oLbxCR) == "O"
		oLbxCR:lVisibleControl := .F.
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
Static Function ListMov(cOpcList, oLbxCR, aCpoHeader, aHeader, aDados, oPanel)

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

	Private oDlgMain	:= NIL
	

	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	//≥ cOpcList | C = Cria, A = Atualiza ≥
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	IF cOpcList == "C"
	
		

		@ 3, 5 SAY oLblSolicita PROMPT "Contas a Receber" SIZE 120, 012 OF oPanel FONT oFLabels COLORS RGB(56,141,191), 16777215 PIXEL
		@ 12,0 LISTBOX oLbxCR FIELDS HEADER ;
		" ", "Campos" ;   
		FONT oFList;                                                                                                 
		SIZE (oPanel:nClientWidth/2)-5,(oPanel:nClientHeight/2)-12 OF oPanel PIXEL ON  dblClick()

		oLbxCR:aheaders := aHeader			   
		oLbxCR:BHEADERCLICK	:= { |oObj,nCol| OrdMv( oObj,nCol, .T.) }	
		
		//oLbxCR:bLDblClick := { |nRow,nCol,nFlags| EditLBoxCBox(@oLbxCR) }	
		oLbxCR:bLDblClick := { |nRow,nCol,nFlags| dbClickMv(@nRow,@nCol,@nFlags) }
		
				
	ENDIF
	
	IF EMPTY(aDados)
		aDados	:= {{}}
		aadd(aDados[1], .F.)
		aadd(aDados[1], 0)
		
		FOR nI := 3 to len(aCpoCR)
		
			IF EMPTY(RetTitle(aCpoCR[nI]))
				xVlrAux	:= 0
			ELSE
				xVlrAux	:= CRIAVAR(aCpoCR[nI],.F.)
			ENDIF
			aadd(aDados[1], xVlrAux)
		NEXT nI
	ENDIF   
	
		
	oLbxCR:nAt	:= 1
	
	

	/*
	@  250, 40 		SAY oLblSolicita PROMPT "Total " 		SIZE 50, 014 OF oDlgMain FONT oFGrpCpo COLORS 128, 16777215 PIXEL
	oTotalP := TGet():Create( oDlgMain,{|| CalcTot("TP", @aDadoMain)},250, 40	, 050,009,D_PICTURE_VLRT,,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,cTotalP,,,, )
	*/
	oLbxCR:SetArray( aDados )  
	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	//≥ Cria string com Bloco de Codigo ≥
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	//cBCodLin	:= "Iif(aDados[oLbxCR:nAt,1],oOk,oNo)" //", Iif(aDados[oLbxCR:nAt,2]==2,oVerde,Iif(aDados[oLbxCR:nAt,2]==1,oAmarelo ,oCinza))"
	cBCodLin	:= "Iif(aDados[oLbxCR:nAt,1],oOk,oNo), Iif(aDados[oLbxCR:nAt,2]==2,oVerde,Iif(aDados[oLbxCR:nAt,2]==3,oAzul, Iif(aDados[oLbxCR:nAt,2]==1,oAmarelo , Iif(aDados[oLbxCR:nAt,2]==4, oBranco, oCinza))))"		
	

	For nI := 3 To LEN(aHeader)
		IF nI > 1
			cBCodLin	+=", "
		endif
		cI	:= alltrim(str(nI))
		
		IF ALLTRIM(aCpoHeader[nI]) $ "E1_VALOR/E1_SALDO/AJUSTE"
			cBCodLin	+= "Transform(aDados[oLbxCR:nAt,"+cI+"], '"+D_PICTURE_VLR+"')"
		ELSE
			cBCodLin	+= "aDados[oLbxCR:nAt,"+cI+"]"		
		ENDIF
		
	Next nI	

	cBCodLin	:= "oLbxCR:bLine := {|| {"+cBCodLin+"}}"
	&(cBCodLin)            

	
	oLbxCR:Refresh()
	
	
	nSaldoCR	:= SaldoCR()	

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
Local cCpoTitle		:= ""

cQuery := " SELECT E1_FILIAL, "+CRLF
cQuery += " 		E1_EMISSAO, "+CRLF
cQuery += " 		E1_VENCTO, "+CRLF
cQuery += " 		E1_SALDO, "+CRLF
cQuery += " 		E1_VALOR, "+CRLF
cQuery += " 		E1_XFORMPG, "+CRLF
cQuery += " 		E1_CLIENTE, "+CRLF
cQuery += " 		E1_LOJA, "+CRLF
cQuery += " 		A1_NOME, "+CRLF
cQuery += " 		E1_NUM, "+CRLF
cQuery += " 		E1_XCODAUT, "+CRLF
//cQuery += " 		E1_XBAND, "+CRLF
cQuery += " 		ZC2_DESC AS BANDEIRA, "+CRLF
cQuery += " 		E1_PREFIXO, "+CRLF
cQuery += " 		E1_NUM, "+CRLF
cQuery += " 		E1_PARCELA, "+CRLF
cQuery += " 		E1_TIPO, "+CRLF
cQuery += " 		E1_NATUREZ, "+CRLF
cQuery += " 		E1_CCUSTO, "+CRLF
cQuery += " 		0 AS AJUSTE, "+CRLF
cQuery += " 		E1_PORTADO,  "+CRLF
cQuery += " 		E1_AGEDEP, "+CRLF
cQuery += " 		E1_CONTA,  "+CRLF
cQuery += " 		E1_NFELETR,  "+CRLF
cQuery += " 		SE1.R_E_C_N_O_ AS SE1_RECNO "+CRLF
cQuery += " FROM "+RetSqlName("SE1")+" SE1 "+CRLF
cQuery += " INNER JOIN  "+RetSqlName("SA1")+" SA1 "+CRLF
cQuery += " 	ON A1_COD = E1_CLIENTE "+CRLF
cQuery += " 	AND A1_LOJA = E1_LOJA "+CRLF
cQuery += " 	AND SA1.D_E_L_E_T_ = '' "+CRLF
cQuery += " LEFT JOIN "+RetSqlName("ZC2")+" ZC2 "+CRLF
cQuery += " 	ON ZC2_FILIAL = '' "+CRLF
cQuery += " 	AND ZC2_CODIGO = E1_XBAND "+CRLF
cQuery += " 	AND ZC2.D_E_L_E_T_ = '' "+CRLF
cQuery += " WHERE E1_FILIAL BETWEEN '"+c1FilDe+"' AND '"+c1FilAte+"' "+CRLF
cQuery += " AND E1_XUNVALC BETWEEN '"+c1UnVDe+"' AND '"+c1UnVAte+"' "+CRLF
cQuery += " AND E1_TIPO NOT IN ('RA') "+CRLF
cQuery += " AND E1_EMISSAO BETWEEN '"+DTOS(c1DtDe)+"' AND '"+DTOS(c1DtAte)+"' "+CRLF
cQuery += " AND E1_VENCTO BETWEEN '"+DTOS(c1DtVDe)+"' AND '"+DTOS(c1DtVAte)+"' "+CRLF
/*
IF !EMPTY(c1Prefixo)
	cQuery += " AND E1_PREFIXO = '"+c1Prefixo+"' " 
ENDIF
*/
IF !EMPTY(c1Forma)
	c1Forma	:= ALLTRIM(c1Forma)
	IF RIGHT(c1Forma,2) == "VZ"
		c1Forma	+= "  "
	ENDIF
	
	cQuery += " AND E1_XFORMPG IN "+INQuery(c1Forma, ,2)
ENDIF

IF !EMPTY(c1CodCli)
	cQuery += " AND SE1.E1_CLIENTE = '"+c1CodCli+"' "
ENDIF
IF !EMPTY(c1Loja)
	cQuery += " AND SE1.E1_LOJA = '"+c1Loja+"' "
ENDIF


cQuery += " AND SE1.E1_SALDO > 0 "+CRLF
cQuery += " AND SE1.D_E_L_E_T_ = '' "+CRLF

IF !(ISBLIND())
	MemoWrite(GetTempPath(.T.) + "CP11011_qMovimen.SQL", cQuery)
ENDIF	

If Select("TQRY") > 0
	TQRY->(DbCloseArea())
EndIf

dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),'TQRY')

TCSetField("TQRY","E1_EMISSAO","D",08,00)
TCSetField("TQRY","E1_VENCTO","D",08,00)

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
		cCpoTitle	:= ALLTRIM(RetTitle(FieldName(nY)))
		IF EMPTY(cCpoTitle)
			cCpoTitle	:= FieldName(nY)
		ENDIF
		aadd(aHeader,cCpoTitle)	
		aadd(aCpoHeader,FieldName(nY))
	//ENDIF 
Next nY	
aadd(aCpoHeader,"SE1_RECNO")
aadd(aCpoHeader,"SE1ZCA")
aadd(aCpoHeader,"MVCONCI")


//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Variaveis de posionamento dos campos ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
nE1FILIAL		:=  Ascan(aCpoHeader,"E1_FILIAL")
nE1EMISSAO		:=  Ascan(aCpoHeader,"E1_EMISSAO")
nE1SALDO		:=  Ascan(aCpoHeader,"E1_SALDO")
nE1VALOR		:=  Ascan(aCpoHeader,"E1_VALOR")
nE1NATUREZ		:=  Ascan(aCpoHeader,"E1_NATUREZ")
nE1CCUSTO		:=  Ascan(aCpoHeader,"E1_CCUSTO")
nSE1RECNO		:=  Ascan(aCpoHeader,"SE1_RECNO")
nAJUSTE			:=  Ascan(aCpoHeader,"AJUSTE")
nE1PORTADO		:=  Ascan(aCpoHeader,"E1_PORTADO")
nE1AGEDEP		:=  Ascan(aCpoHeader,"E1_AGEDEP")
nE1CONTA		:=  Ascan(aCpoHeader,"E1_CONTA")
nE1CLIENTE		:=  Ascan(aCpoHeader,"E1_CLIENTE")
nE1LOJA			:=  Ascan(aCpoHeader,"E1_LOJA")
nSE1ZCA			:=  Ascan(aCpoHeader,"SE1ZCA")

nCRCONCI		:=  Ascan(aCpoHeader,"MVCONCI")


//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Monta aDados ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ 
IF TQRY->(!EOF())

	WHILE TQRY->(!EOF())

		//| Tratativa para lista titulos que n„o possuem nf eletronica preenchido
		IF SUPERGETMV("FS_FILBXNF",.F.,.F., TQRY->E1_FILIAL)
			If Empty(TQRY->E1_NFELETR) 
				TQRY->(DBSKIP())
				LOOP
			ENDIF
		ENDIF
	
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
		aadd(aLinha, 0) // SE1ZCA
		aadd(aLinha, 0) //| MVCONCI |
		
		AADD(aDados, aLinha)
	

		TQRY->(DBSKIP())
	ENDDO   

	//nSE1ZCA 	:= len(aDados[1])
	//nSE1RECNO	:= nSE1ZCA-1

		
	
	aRet[1]	:= .T.
	aRet[2]	:= aCpoHeader
	aRet[3]	:= aHeader
	aRet[4]	:= aDados

ELSE
 	aRet[1]	:= .F.
ENDIF                  

nSaldoCR	:= SaldoCR()
	
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
Static Function OrdMv(oLbxAux, nCol, lMark)
	Default lMark	:= .F.

	//lMarkAll	:= .F. 
	
	If	nCol > 0

		//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
		//≥ Marca/Desmarca Registrios ≥
		//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
		IF nCol == nAntMv
			aSort(oLbxAux:aArray,,,{ |x,y| x[nCol] < y[nCol] })
			nAntMv := 0
		Else
			aSort(oLbxAux:aArray,,,{ |x,y| x[nCol] > y[nCol] })
			nAntMv := nCol
		EndIf

		oLbxAux:Refresh()


	EndIf

Return()


/*/{Protheus.doc} SelMA
Double Click Movimento Adquirentes
@author Augusto Ribeiro | www.compila.com.br
@since 26/12/2016
@version version
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function SelMA(oLbxAux)
Local nPosAux, nI
Local nMarkAnt	:= 0
Local cRAFil, cRACodCli, cRALoja, cRABanco, cRAAg, cRAConta

IF !(lVazioEx)
	/*-----------------------------
		CONCILIACAO DE MOVIMENTOS
	------------------------------*/
	IF nConcTaxa == OPCAO_BAIXA .AND. aDadosMA[oLbxAux:nAt,2] <> D_TAXA
		
		
		/*--------------------------
			REMOVENDO SELECAO
		---------------------------*/
		IF aDadosMA[oLbxAux:nAt,1]
			IF aDadosMA[oLbxAux:nAt,2] == D_CONCILIADO //.OR.  aDadosMA[oLbxAux:nAt,2] == D_CONCILIADO_AUTO
				nMarkAnt	:= aDadosMA[oLbxAux:nAt,nMACONCI]
			ENDIF
		 	aDadosMA[oLbxAux:nAt,1] 		:= .F.
		 	aDadosMA[oLbxAux:nAt,2] 		:= D_NAOSELECIONADO
		 	aDadosMA[oLbxAux:nAt,nMACONCI] 	:= 0
		 	nTotMACon 						:= nTotMACon - aDadosMA[oLbxAux:nAt,nZCASALDO]
		 	
		 	
		 	IF !EMPTY(nMarkAnt)
		 		DesmConc(nMarkAnt)
		 	ENDIF
		 	
		ELSE
		
			nPosAux := aScan(aDadosMA, { |x| x[2] ==  D_SELECIONADO})
			
			IF nPosAux == 0 
			
		
			/*
			IF ((nTotMACon > 0 .OR. nTotCRCon > 0) .and. aDadosMA[oLbxAux:nAt,nZCAVBRUTO] > 0 ) .OR.;
				((nTotMACon < 0 .OR. nTotCRCon < 0) .and. aDadosMA[oLbxAux:nAt,nZCAVBRUTO] < 0 ) .OR.;
				nTotMACon == 0 .and. nTotCRCon == 0
			*/
				/*--------------------------
					SELECIONANDO
				---------------------------*/		
				aDadosMA[oLbxAux:nAt,1] 		:= .T.
				aDadosMA[oLbxAux:nAt,2] 		:= D_SELECIONADO
				aDadosMA[oLbxAux:nAt,nMACONCI] 	:= nMarkConc
				nTotMACon 						:= nTotMACon + aDadosMA[oLbxAux:nAt,nZCASALDO]
				
			//endif
			ELSE
				FwHelpShow("ONLYONE","ONLYONE","Somente um registro de Movimento da Adquirente pode ser selecionado por vez.")
			ENDIF
		
		ENDIF
		
		/*--------------------------
			Conferencia dos valores selecionados
			e alteracao do status
		---------------------------*/
		ConfVlr()
	
	/*-----------------------------
		IDENTIFICA«√O DE TAXAS
	------------------------------*/	
	ELSEIF nConcTaxa == OPCAO_MOVIMENTO_BANCARIO .AND. (aDadosMA[oLbxAux:nAt,2] == D_TAXA .OR. aDadosMA[oLbxAux:nAt,2] == D_NAOSELECIONADO)
	
		IF aDadosMA[oLbxAux:nAt,1]
		 	aDadosMA[oLbxAux:nAt,1] 	:= .F.
		 	aDadosMA[oLbxAux:nAt,2] 	:= D_NAOSELECIONADO
		 	
		 	
		 	nPosAux	:=  aScan(aDadosCR, { |x| x[nSE1ZCA] ==  aDadosMA[oLbxAux:nAt, nZCARECNO]})
		 	IF nPosAux > 0
		 		aDel(aDadosCR, nPosAux)
		 		aSize(aDadosCR, LEN(aDadosCR)-1)
		 		oLbxCR:nAt	:= 1
		 	ENDIF
		 	
		 
		 ELSEIF !(aDadosMA[oLbxAux:nAt,1])
	 	 	aDadosMA[oLbxAux:nAt,1] 	:= .T.
	 	 	aDadosMA[oLbxAux:nAt,2] 	:= D_TAXA
	 	 
	 	 	/*------------------------------------------------------ Augusto Ribeiro | 30/12/2016 - 10:51:14 AM
	 	 		CRIA REGISTRO NA TABELA DE MOVIMENTOS.
	 	 	------------------------------------------------------------------------------------------*/
	 	 	aLinha	:= {}
	 	 	FOR nI := 1 TO LEN(aCpoCR)
	 	 		xValor	:= NIL
	 	 		IF aCpoCR[nI] == "MARK"
	 	 			xValor	:= .F.
	 	 		ELSEIF aCpoCR[nI] == "LEGENDA"
	 	 			xValor	:= aDadosMA[oLbxAux:nAt,2] 	 			
	 	 		ELSEIF aCpoCR[nI] == "E1_FILIAL"
	 	 			xValor	:= CRIAVAR("E1_FILIAL",.F.)
	 	 			xValor	:= PADR(cFILMVPAR, LEN(xValor))
	 	 		ELSEIF aCpoCR[nI] == "E1_EMISSAO"
	 	 			xValor	:= aDadosMA[oLbxAux:nAt,nZCADTPAG]
	 	 		ELSEIF aCpoCR[nI] == "E1_VALOR"
	 	 			xValor	:= aDadosMA[oLbxAux:nAt,nZCASALDO]
	 	 		ELSEIF aCpoCR[nI] == "E1_CCUSTO"
	 	 			xValor	:= CRIAVAR("E1_CCUSTO",.F.)
	 	 			xValor	:= PADR(cCTTMVPAR , LEN(xValor))
	 	 		ELSEIF aCpoCR[nI] == "E1_NATUREZ"
	 	 			xValor	:= CRIAVAR("E1_NATUREZ",.F.)
	 	 			xValor	:= PADR(cSEDMVPAR, LEN(xValor))
	 	 		ELSEIF aCpoCR[nI] == "SE1ZCA"
	 	 			xValor	:= aDadosMA[oLbxAux:nAt,nZCARECNO]
	 	 		ELSEIF aCpoCR[nI] == "E1_SALDO" .OR.;
	 	 		 		aCpoCR[nI] == "MVCONCI" .OR.;
	 	 				aCpoCR[nI] == "SE1_RECNO" .OR.;
	 	 				aCpoCR[nI] == "AJUSTE"
	 	 			xValor	:= 0
	 	 		ENDIF
	 	 		
	 	 		aadd(aLinha, xValor)
	 	 	NEXT nI
	 	 	
	 	 	aadd(aDadosCR, aLinha)
	 	 	oLbxCR:nAt	:= len(aDadosCR)//| Posiciona no registro adicionado. | 
	 	 	SelCR(@oLbxCR, .T. )
	 	 	
	 	 	
	 	 	
	 	 	
		ENDIF
		
	/*-----------------------------
		IDENTIFICACAO - GERA RA
	------------------------------*/	
	ELSEIF nConcTaxa == OPCAO_RECEB_ANTECIPADO .AND. (aDadosMA[oLbxAux:nAt,2] == D_RECEB_ANTECIPADO .OR. aDadosMA[oLbxAux:nAt,2] == D_NAOSELECIONADO)
	
		IF aDadosMA[oLbxAux:nAt,1]
		 	aDadosMA[oLbxAux:nAt,1] 	:= .F.
		 	aDadosMA[oLbxAux:nAt,2] 	:= D_NAOSELECIONADO
		 	
		 	
		 	nPosAux	:=  aScan(aDadosCR, { |x| x[nSE1ZCA] ==  aDadosMA[oLbxAux:nAt, nZCARECNO]})
		 	IF nPosAux > 0
		 		aDel(aDadosCR, nPosAux)
		 		aSize(aDadosCR, LEN(aDadosCR)-1)
		 		oLbxCR:nAt	:= 1
		 	ENDIF
		 	
		 
		 ELSEIF !(aDadosMA[oLbxAux:nAt,1])
		 
		 	aRetAux	:= ParamRA()
		 
		 	IF aRetAux[1]
		 		
		 		cRAFil		:= aRetAux[3,1]
		 		cRACodCli	:= aRetAux[3,2]
		 		cRALoja		:= aRetAux[3,3]
		 		
		 		/*------------------------------------------------------ Augusto Ribeiro | 16/11/2017 - 2:03:51 PM
		 			Busca banco, agencia e conta
		 		------------------------------------------------------------------------------------------*/
		 		ZCA->(DBGOTO(aDadosMA[oLbxAux:nAt,nZCARECNO]))
		 		
		 		aRetBco		:= U_CP11BCO(ZCA->ZCA_BANCO, ZCA->ZCA_AGENC, ZCA->ZCA_CONTA)
		 		IF LEN(aRetBco) > 0
			 		
			 		cRABanco	:= aRetBco[1]
			 		cRAAg		:= aRetBco[2]
			 		cRAConta	:= aRetBco[3]
			 	
			 	 	aDadosMA[oLbxAux:nAt,1] 	:= .T.
			 	 	aDadosMA[oLbxAux:nAt,2] 	:= D_RECEB_ANTECIPADO
			 	 
			 	 	/*------------------------------------------------------ Augusto Ribeiro | 30/12/2016 - 10:51:14 AM
			 	 		CRIA REGISTRO NA TABELA DE MOVIMENTOS.
			 	 	------------------------------------------------------------------------------------------*/
			 	 	aLinha	:= {}
			 	 	FOR nI := 1 TO LEN(aCpoCR)
			 	 		xValor	:= NIL
			 	 		IF aCpoCR[nI] == "MARK"
			 	 			xValor	:= .T.
			 	 		ELSEIF aCpoCR[nI] == "LEGENDA"
			 	 			xValor	:= aDadosMA[oLbxAux:nAt,2] 	 			
			 	 		ELSEIF aCpoCR[nI] == "E1_FILIAL"
			 	 			xValor	:= cRAFil
			 	 		ELSEIF aCpoCR[nI] == "E1_TIPO"
			 	 			xValor	:= "RA"
			 	 		ELSEIF aCpoCR[nI] == "E1_EMISSAO"
			 	 			xValor	:= aDadosMA[oLbxAux:nAt,nZCADTPAG]
			 	 		ELSEIF aCpoCR[nI] == "E1_VALOR"
			 	 			xValor	:= aDadosMA[oLbxAux:nAt,nZCASALDO]
			 	 		ELSEIF aCpoCR[nI] == "E1_CCUSTO"
			 	 			xValor	:= CRIAVAR("E1_CCUSTO",.F.)
			 	 			xValor	:= PADR(cCTTMVPAR , LEN(xValor))
			 	 		ELSEIF aCpoCR[nI] == "E1_NATUREZ"
			 	 			xValor	:= CRIAVAR("E1_NATUREZ",.F.)
			 	 			xValor	:= PADR(cSEDMVPAR, LEN(xValor))
						ELSEIF aCpoCR[nI] == "E1_PORTADO"
							xValor	:= cRABanco
						ELSEIF aCpoCR[nI] == "E1_AGEDEP"					
							xValor	:= cRAAg
						ELSEIF aCpoCR[nI] == "E1_CONTA"
							xValor	:= cRAConta
						ELSEIF aCpoCR[nI] == "E1_CLIENTE"
							xValor	:= cRACodCli
						ELSEIF aCpoCR[nI] == "E1_LOJA"		 	 			
			 	 			xValor	:= cRALoja
						ELSEIF aCpoCR[nI] == "A1_NOME"		 	 			
			 	 			xValor	:= ALLTRIM(POSICIONE("SA1",1,XFILIAL("SA1")+cRACodCli+cRALoja,"A1_NOME"))	 	 			
			 	 		ELSEIF aCpoCR[nI] == "SE1ZCA"
			 	 			xValor	:= aDadosMA[oLbxAux:nAt,nZCARECNO]			 	 			
			 	 		ELSEIF aCpoCR[nI] == "E1_SALDO" .OR.;
			 	 		 		aCpoCR[nI] == "MVCONCI" .OR.;
			 	 				aCpoCR[nI] == "SE1_RECNO" .OR.;
			 	 				aCpoCR[nI] == "AJUSTE"
			 	 			xValor	:= 0
			 	 		ENDIF
			 	 		
			 	 		aadd(aLinha, xValor)
			 	 	NEXT nI
			 	 	
			 	 	aadd(aDadosCR, aLinha)
			 	 	oLbxCR:nAt	:= len(aDadosCR)//| Posiciona no registro adicionado. | 
			 	 	SelCR(@oLbxCR, .T. )
			 	 ELSE
			 	 	FwHelpShow("nA6XCONCAR","CONTA NAO LOCALIZADA NO CADASTRO DE BANCOS [E6_XCONCAR]" )
			 	 ENDIF
		 	 ENDIF
		ENDIF		
	ENDIF
ENDIF


oLbxCR:Refresh()

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
Static Function SelCR(oLbxAux, lForceMark)
Local nI, nVlrMov, nDif, nPosAux
Local nPosAux, nPosEx	
Local nMarkAnt	:= 0

Default lForceMark	:= .f.


nPosEx := aScan(aDadosMA, { |x| x[2] ==  D_SELECIONADO})



/*-----------------------------
	CONCILIACAO DE MOVIMENTOS
------------------------------*/
IF nConcTaxa == OPCAO_BAIXA
	
	
	/*--------------------------
		REMOVENDO SELECAO
	---------------------------*/	
	IF aDadosCR[oLbxAux:nAt,1]
		
		IF aDadosCR[oLbxAux:nAt,2] == D_CONCILIADO //.OR.  aDadosCR[oLbxAux:nAt,2] == D_CONCILIADO_AUTO
			nMarkAnt	:= aDadosCR[oLbxAux:nAt,nCRCONCI]
		ENDIF		
		aDadosCR[oLbxAux:nAt,1] 		:= .F.
		aDadosCR[oLbxAux:nAt,2] 		:= D_NAOSELECIONADO
		aDadosCR[oLbxAux:nAt,nCRCONCI] 	:= 0
		aDadosCR[oLbxAux:nAt,nAJUSTE] 	:= 0
		nTotCRCon 						:= nTotCRCon - aDadosCR[oLbxAux:nAt,nE1SALDO]
		
	 	IF !EMPTY(nMarkAnt)
	 		DesmConc(nMarkAnt)
	 	ENDIF	 	
	ELSE
		/*
		IF ((nTotMACon > 0 .OR. nTotCRCon > 0) .and. aDadosCR[oLbxAux:nAt,nE1SALDO] > 0 ) .OR.;
			((nTotMACon < 0 .OR. nTotCRCon < 0) .and. aDadosCR[oLbxAux:nAt,nE1SALDO] < 0 ) .OR.;
			nTotMACon == 0 .and. nTotCRCon == 0
			*/
			/*--------------------------
				SELECIONANDO
			---------------------------*/		
			aDadosCR[oLbxAux:nAt,1] 		:= .T.
			aDadosCR[oLbxAux:nAt,2] 		:= D_SELECIONADO
			aDadosCR[oLbxAux:nAt,nCRCONCI] 	:= nMarkConc
			nTotCRCon 						:= nTotCRCon + aDadosCR[oLbxAux:nAt,nE1SALDO]
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
ELSEIF nConcTaxa == OPCAO_MOVIMENTO_BANCARIO

	IF aDadosCR[oLbxAux:nAt,1]
		nPosAux	:=  aScan(aDadosMA, { |x| x[nZCARECNO] ==  aDadosCR[oLbxAux:nAt, nSE1ZCA]})
		
		
		IF nPosAux > 0
		 	Help(" ",1,"SELECAO",,"Este registro n„o pode ser desmarcado pois esta vinculado a um registro de taxa da Adquirente. Desmarque o item do 'Movimmento Adquirente' antes de continuar",4,5)
		 	oLbxMA:nAt	:= nPosAux
		ENDIF
	ELSE
		nPosEx := aScan(aDadosMA, { |x| x[2] ==  D_SELECIONADO})
		IF !EMPTY(nPosEx) .or. lForceMark
			aDadosCR[oLbxAux:nAt,1] 		:= .T.
			aDadosCR[oLbxAux:nAt,nSE1ZCA]	:=  aDadosMA[oLbxMA:nAt,nZCARECNO]	
		ELSE
		 	Help(" ",1,"SELECAO",,"Este registro n„o pode ser desmarcado pois esta vinculado a um registro de taxa da Adquirente. Desmarque o item do 'Movimmento Adquirente' antes de continuar",4,5)
		 	IF nPosEx > 0
		 		oLbxMA:nAt	:= nPosEx
		 	ENDIF		
		ENDIF	
	ENDIF

ENDIF

oLbxMA:Refresh()

oView	:= FWViewActive()

oView:Refresh()

Return()





/*/{Protheus.doc} CP1111BTN
Chamada de botoes da enchoice bar
@author Augusto Ribeiro | www.compila.com.br
@since 29/12/2016
@version 1.0
@param cBtn, C, Botao pressionado
@param oView, O, Objeto da View [Default: FWViewActive()]
@return ${return}, ${return_description}
/*/
User Function CP1111BTN(cBtn, oView)
Local oView, nTotLen
Local oModFull
Local cPathDest, cPathArq


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
	
	cpBanco		:= MV_PAR01
	cpAg		:= MV_PAR02
	cpConta		:= MV_PAR03	
	dtCredDe	:= MV_PAR04
	dtCredAte	:= MV_PAR05	
	cpCodAdq	:= MV_PAR06
	cpModalid	:= MV_PAR07
	cpStatZCA	:= MV_PAR08
	cpRazStat	:= MV_PAR09
	
		IF  PERGUNTE(D_PERGB ,.T.)
		
			c1FilDe		:= MV_PAR01
			c1FilAte	:= MV_PAR02
			c1DtVDe		:= MV_PAR03	
			c1DtVAte	:= MV_PAR04		
			c1DtDe		:= MV_PAR05	
			c1DtAte		:= MV_PAR06					
			c1Forma		:= MV_PAR07
			c1CodCli	:= MV_PAR08
			c1Loja		:= MV_PAR09
			c1UnVDe		:= MV_PAR10
			c1UnVAte	:= MV_PAR11

		ENDIF
		
		fAtualiza()
	ENDIF
	
ELSEIF cBtn== "CONC_AUTO"

	/*------------------------------------------------------ Augusto Ribeiro | 29/12/2016 - 3:52:43 PM
		Realiza a conciliaÁ„o autom·tica dos itens listados
	------------------------------------------------------------------------------------------*/
	Processa({|| ConcAuto() }, "ConciliaÁ„o Autom·tica... ")
	
	
ELSEIF cBtn== "EFETIVA"

	IF AVISO("Efetiva Baixa/Mov. Bancario", "Ser„o efetivadostodos os movimentos selecionados. "+CRLF+;
									"Deseja continuar ?", {"Sim", "N„o"},2) == 1
	
		Processa({|| fEfetiva() }, "Efetivando Baixas/Mov. Bancario... ")
	ENDIF
	
ELSEIF cBtn== "DESCONTO"
	
	AplicaDesc()

ELSEIF cBtn== "GERA_RA"	
	

ELSEIF cBtn== "TRANSF"	
	fTransf()
	
ELSEIF cBtn== "FCP"	

	FINA750()
	//bWindowInit := { || __Execute( "FINA750()" , "xxxxxxxxxxxxxxxxxxxx" , "FINA750" , "SIGAFIN" , "SIGAFIN", 1 , .T. ) }
	//EVAL(bWindowInit)
	
	fAtualiza()

ELSEIF cBtn== "FCR"

	FINA740()
	//bWindowInit := { || __Execute( "FINA740()" , "xxxxxxxxxxxxxxxxxxxx" , "FINA740" , "SIGAFIN" , "SIGAFIN", 1 , .T. ) }
	//EVAL(bWindowInit)	
	
	fAtualiza()
ELSEIF cBtn=="ADQUIRENTE"
	
	VisulAdq()

ELSEIF cBtn=="TITULO"
	
	VisulTit()
	
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
	
	@  7, 5 		SAY oLblSolicita PROMPT "Mov. Adquirentes"				SIZE 70, 024 OF oPanelr FONT oFGrpCpo COLORS 128, 16777215 PIXEL
	oTotMA := TGet():Create( oPanelr,{|| CalcTot("ADQUIRENTE") },5, 070	, 050,009,D_PICTURE_VLRT,,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,cTotalA,,,, )

	@  20, 5		SAY oLblSolicita PROMPT "Selecionado"				SIZE 50, 024 OF oPanelr FONT oFGrpCpo COLORS 128, 16777215 PIXEL
	oSelMA := TGet():Create( oPanelr,{|| CalcTot("SELECIONADO_MA") },19, 070	, 050,009,D_PICTURE_VLRT,,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,cSelMA,,,, )
		
		
	//@  7, 100 		SAY oLblSolicita PROMPT "Vencidos" 				SIZE 50, 024 OF oPanelr FONT oFGrpCpo COLORS 128, 16777215 PIXEL
	//oTotVenc := TGet():Create( oPanelr,{|| 3},5, 130	, 050,009,D_PICTURE_VLR,,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,cTotalS,,,, )
	
	@  7, nPosCentro-60 		SAY oLblSolicita PROMPT "Conciliado" 				SIZE 50, 024 OF oPanelr FONT oFGrpCpo COLORS 128, 16777215 PIXEL
	oTotCon:= TGet():Create( oPanelr,{|| CalcTot("CONCILIADO")},5, nPosCentro-10	, 050,009,D_PICTURE_VLRT,,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,cTotalC,,,, )

	@  20, nPosCentro-60 		SAY oLblSolicita PROMPT "Mov.Bancario" 				SIZE 50, 024 OF oPanelr FONT oFGrpCpo COLORS 128, 16777215 PIXEL
	oTotTaxa:= TGet():Create( oPanelr,{|| CalcTot("TAXA")},17, nPosCentro-10	, 050,009,D_PICTURE_VLRT,,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,cTotalD,,,, )	
		
		
	//oCheck1 := TCheckBox():New(07,nPosCentro+50,'CheckBox 001',{|| SelChek("CONCILIA")},oPanelr,100,210,,,,,,,,.T.,,,)
   	//oCheck2 := TCheckBox():New(18,nPosCentro+50,'CheckBox 002',{|| SelChek("TAXA")},oPanelr,100,210,,,,,,,,.T.,,,)		
		
   	//oCheck1 := TCheckBox():New(07,nPosCentro+50,'CheckBox 001',{|| lSelConc},oPanelr,100,210,,,,,,,,.T.,,,)
   	//oCheck2 := TCheckBox():New(18,nPosCentro+50,'CheckBox 002',{|| lSelTaxa},oPanelr,100,210,,,,,,,,.T.,,,)
   	
   	
   	aRadio := {'Concilia','Mov.Bancario','Receb.Antecipado'}
  // 	oRadio := TRadMenu():Create (oPanelr,,07,nPosCentro+50,aItens,,,,,,,,100,12,,,,.T.)
  //	oRadio := TRadMenu():New (07,nPosCentro+50,aItens,,oPanelr,,,,,,,,100,12,,,,.T.)
  	oRadio:= tRadMenu():New(7,nPosCentro+50,aRadio,{|u|if(PCount()>0,nConcTaxa:=u,nConcTaxa)},oPanelr,,,,,,,,140,8,,,,.T.)  
   	//oRadio:bSetGet := {|u|Iif(PCount()==0,nRadio,nRadio:=u)}
				
		
	//@ 7,010 Radio _oResp Var _xResp 3D Size _nLrg,_nAlt Prompt "Sim","N„o" Of _oDlgResp Pixel		
		
		
	@  7, nPosFim-130  		SAY oLblSolicita PROMPT "Contas a Receber"		SIZE 70, 190 OF oPanelr FONT oFGrpCpo COLORS 128, 16777215 PIXEL
	oTotCR := TGet():Create( oPanelr,{|| CalcTot("CONTAS_RECEBER")},5, nPosFim-60	, 050,009,D_PICTURE_VLRT,,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,cTotalMv,,,, )

	@  20, nPosFim-130  		SAY oLblSolicita PROMPT "Selecionado"		SIZE 50, 190 OF oPanelr FONT oFGrpCpo COLORS 128, 16777215 PIXEL
	oSelCR := TGet():Create( oPanelr,{|| CalcTot("SELECIONADO_CR")},19, nPosFim-60	, 050,009,D_PICTURE_VLRT,,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,cSelCR,,,, )
	
	
	/*
	@  20, 120		SAY oLblSolicita PROMPT "Acrescimo: "			SIZE 50, 024 OF oPanelr FONT oFGrpCpo COLORS 128, 16777215 PIXEL		
	oTotalP := TGet():Create( oPanelr,{|| CalcTot("ACRESS", @aDadoTit)},20, 120	, 050,009,D_PICTURE_VLRT,,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,cTotalS,,,, )
	*/
	//oPanelr:nClientWidth -5  //(oPanelr:nClientHeight/2)-12	
	
ELSE

	cTotalA		:= CalcTot("ADQUIRENTE")
	cSelMA		:= CalcTot("SELECIONADO_MA")
	cTotalC		:= CalcTot("CONCILIADO")
	cTotalD		:= CalcTot("TAXA")
	cTotalMv	:= CalcTot("CONTAS_RECEBER")
	cSelCR		:= CalcTot("SELECIONADO_CR")


	/*--------------------------
		Atualiza total conciliado
	
	nTotConc	:= 0
	FOR nI := 1 to LEN(aDadosMA)
		IF aDadosMA[nI,2] == D_CONCILIADO
			nTotConc += aDadosMA[nI, nZB2VALOR]
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
		
oTotMA:CtrlRefresh()
oTotCon:CtrlRefresh()
oTotTaxa:CtrlRefresh()
oTotCR:CtrlRefresh()
oSelMA:CtrlRefresh()
oSelCR:CtrlRefresh()
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
	
	
	
	FOR nI := 1 to LEN(aDadosMA)
		IF aDadosMA[nI,2] == D_CONCILIADO
			nRet += aDadosMA[nI, nZCASALDO]
		ENDIF
	NEXT nI
	
ELSEIF cOpc == "ADQUIRENTE"//"EXTRATO"
	
	nRet	:= nSaldoMA//| Saldo do EXTRATO|7
	/*
	FOR nI := 1 to LEN(aDadosMA)
		IF aDadosMA[nI,2] == D_CONCILIADO .OR. aDadosMA[nI,2] == D_TAXA
			nRet += aDadosMA[nI, nZB2VALOR]
		ENDIF
	NEXT nI	
	*/
	
ELSEIF cOpc == "CONTAS_RECEBER"//"MOVIMENTO"

	nRet	:= nSaldoCR //| Saldo do movimento|
	/*
	FOR nI := 1 to LEN(aDadosCR)
		IF aDadosCR[nI, 1]
			nRet += aDadosCR[nI, nE1SALDO]
		ENDIF
	NEXT nI	
	*/
ELSEIF cOpc == "TAXA"
	FOR nI := 1 to LEN(aDadosMA)
		IF aDadosMA[nI,2] == D_TAXA
			nRet += aDadosMA[nI, nZCASALDO]
		ENDIF
	NEXT nI
	
ELSEIF cOpc == "SELECIONADO_MA"//"SELECIONADO_EX"
	FOR nI := 1 to LEN(aDadosMA)
		IF aDadosMA[nI,1]
			nRet += aDadosMA[nI, nZCASALDO]
		ENDIF
	NEXT nI	
	
ELSEIF cOpc == "SELECIONADO_CR"//"SELECIONADO_MV"
	FOR nI := 1 to LEN(aDadosCR)
		IF aDadosCR[nI,1]
			nRet += aDadosCR[nI, nE1SALDO]
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
Local nAbat 	:= 0

nConcTaxa	:= 1 
lISelec		:= .F.

IF !EMPTY(aDadosMA) .AND. !EMPTY(aDadosCR)

	nQtdEx	:= LEN(aDadosMA)
	nQtdMv	:= LEN(aDadosCR)

	ProcRegua(nQtdEx)
	
	aSort(aDadosMA,,,{ |x,y| x[nZCASALDO] < y[nZCASALDO]})
	aSort(aDadosCR,,,{ |x,y| x[nE1SALDO] < y[nE1SALDO]})
	
	nAuxMv	:= 1
	FOR nI := 1 to nQtdEx
		IncProc("Conciliando automaticamente..")
		
		IF empty(aDadosMA[nI, nZCADTPAG])
			LOOP
		ENDIF
	
		nAuxMv	:= aScan(aDadosCR, { |x| x[nE1SALDO] ==  aDadosMA[nI,nZCASALDO]})
		IF nAuxMv > 0
			FOR nMv := nAuxMv TO nQtdMv
				
				IF !(aDadosCR[nMv, 1] .OR. aDadosMA[nI, 1]) .AND. aDadosMA[nI, nZCADTVEN] <= aDadosCR[nMv, nE1EMISSAO] .AND. aDadosMA[nI, nZCADTPAG] >= aDadosCR[nMv, nE1EMISSAO] 			
					
					SE1->(DbGoTo(aDadosCR[nMv, nSE1RECNO]))
					nAbat   := 0
					nAbat   := SomaAbat(SE1->E1_PREFIXO, SE1->E1_NUM, SE1->E1_PARCELA, "R", SE1->E1_MOEDA, dDataBase, SE1->E1_CLIENTE, SE1->E1_LOJA, xFilial("SE1", SE1->E1_FILORIG), dDataBase, SE1->E1_TIPO)
					nDif	:= aDadosMA[nI, nZCASALDO] - (aDadosCR[nMv, nE1SALDO]+nAbat) //nVlrExtr - nVlrMov
					IF nTolera >= nDif .and. (nTolera*-1) <=  nDif

						oLbxMA:nAt	:= nI							
						SelMA(@oLbxMA) //| Seleciona Item|
						ListTot()
						oLbxMA:Refresh()
						
						oLbxCR:nAt	:= nMv
						dbClickMv(nMv, 1)
						//SelCR(@oLbxCR) //| Seleciona Item|
						
						EXIT
					ENDIF	
				ENDIF
			NEXT nMv
		ENDIF
		
	NEXT nI
ENDIF
	

oLbxMA:nAt	:= 1
oLbxCR:nAt	:= 1

//| Restore do parametro |
lISelec	:= lAuxSel

oLbxMA:Refresh()
oLbxCR:Refresh()

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
IF !(EMPTY(aDadosCR[oLbxCR:nAt, nE1EMISSAO])) //| N„o realiza acao sobre registro vazio|

	/* ### EDI«√O DA LINHA DO LISTBOX 

	IF EMPTY(aDadosCR[oLbxCR:nAt, nSE1RECNO]) .and. (nCol == nE5HISTOR) //.OR. nCol == nE5NATUREZ .OR. nCol == nE5CCUSTO) 
		//IF EMPTY(aDadosCR[oLbxCR:nAt, nSE1RECNO])
			EditHist(@oLbxCR, nCol)
	//	ENDIF
	else
		SelCR(@oLbxCR)
		ListTot()
		oLbxCR:Refresh()
	ENDIF
	*/
	
	SelCR(@oLbxCR)
	ListTot()
	oLbxCR:Refresh()	
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
Local nPosMv
Local nI, nY, dDataAnt
Local nDadosCR	:= len(aDadosCR)
Local aRecSE5	:= {}
Local lRetConc	:= .f.
Local nQtdeTaxa	:= 0
Local nMaxTaxa	:= GETMV("CP11_GELAN",.F., 20) //| Quantidade Maxima de lanÁamentos |

Local nLoopMA, nTotMA
Local nLoopCR, nTotCR
Local nLastnY	:= 1	
Local nIdConc	:= 1
Local aRegMA	:= {}
Local aRegCR	:= {}
Local nRecZCA
Local aRetBco	:= {}
Local lVldMarca := SuperGetMV("AL_VLDMCR",.F.,.F.)
Local lMarca 	:= .T.	
Local aRetAux 

ProcRegua(len(aDadosMA))


/*------------------------------------------------------ Augusto Ribeiro | 13/01/2017 - 10:14:33 AM
	Trava de seguranÁa para evitar que usuario gere numero excessivo de lanÁamentos incorretamente
------------------------------------------------------------------------------------------*/
For nI := 1 to Len(aDadosMA)
	IF aDadosMA[nI, 1] .AND. aDadosMA[nI, 2] == D_TAXA
		nQtdeTaxa++
	ENDIF	
Next nI

IF nQtdeTaxa <= nMaxTaxa
	
	
	/*------------------------------------------------------ Augusto Ribeiro | 25/01/2017 - 6:11:28 PM
	
		CONCILIA«√O
		Realiza BAIXA dos titulos
	
	------------------------------------------------------------------------------------------*/	
	DBSELECTAREA("ZCA")
	DBSELECTAREA("SE5")
	
	aSort(aDadosMA,,,{ |x,y| x[nMACONCI] > y[nMACONCI] })
	aSort(aDadosCR,,,{ |x,y| x[nCRCONCI] > y[nCRCONCI] })
	
	nLoopMA	:= 1
	nLoopCR	:= 1
	nTotMA	:= len(aDadosMA)
	nTotCR	:= len(aDadosCR)
	WHILE  IIF(nLoopMA <= nTotMA, aDadosMA[nLoopMA, nMACONCI] > 0, .F.) 
		IncProc("Conciliando..")
		aRegMA	:= {}
		aRegCR	:= {}
		
		nRecZCA	:= 0
		
		
		
		IF aDadosMA[nLoopMA, 2] == D_CONCILIADO
			
			nIdConc	:= aDadosMA[nLoopMA, nMACONCI]
			nRecZCA	:= aDadosMA[nLoopMA, nZCARECNO]
			/*
			WHILE  IIF(nLoopMA <= nTotMA, aDadosMA[nLoopMA, nMACONCI] == nIdConc,.F.) 
				AADD(aRegMA, aDadosMA[nLoopMA, nZCARECNO])
				nLoopMA++
			ENDDO
			*/
			
			
			//WHILE IIF(nLoopCR <= nTotCR, aDadosCR[nLoopCR, nCRCONCI] == nIdConc, .F.) 
			WHILE nLoopCR <= nTotCR 
				IF aDadosCR[nLoopCR, nCRCONCI] == nIdConc
					AADD(aRegCR, {aDadosCR[nLoopCR, nSE1RECNO], aDadosCR[nLoopCR, nAJUSTE]})
				ENDIF
				nLoopCR++
				IF nLoopCR <= nTotCR 
					IF aDadosCR[nLoopCR, nCRCONCI] < nIdConc
						EXIT
					ENDIF
				ENDIF
			ENDDO		
			
			/*------------------------------------------------------ Augusto Ribeiro | 25/01/2017 - 6:08:14 PM
				Grava conciliaÁ„o
			------------------------------------------------------------------------------------------*/
			IF !EMPTY(nRecZCA) .AND. !EMPTY(aRegCR)
				IF lVldMarca
					lMarca := vldMarca(nRecZCA,aRegCR)
				ENDIF	

				IF lMarca
					
					aRetAux	:= U_CP11BAIX(nRecZCA, aRegCR)
					IF !(aRetAux[1])
						//Help(" ",1,"EFETIVA",,"Prefixo: "+SE1->PREFIXO+" Num. Tit.: "+SE1->E1_NUM+" Parcela: "+SE1->E1_PARCELA+". "+aRetAux[2],4,5)
						aRet[2] += "Prefixo: "+SE1->E1_PREFIXO+CRLF
						aRet[2] += "Num. Tit.: "+SE1->E1_NUM+CRLF
						aRet[2] += "Parcela: "+SE1->E1_PARCELA+CRLF+CRLF
						aRet[2] += aRetAux[2]+CRLF+CRLF
						
						//aRet[2] := aRetAux[2]+". "
						//EXIT
					ENDIF
				ENDIF
			ELSE 
				IF EMPTY(aRet[2])
					aRet[2] := "Erro indeterminado [CP11011 fEfetiva()]"
				ENDIF
				EXIT
			ENDIF
		//ELSE
			//nLoopMA++
		ENDIF
		
		nLoopMA++
	ENDDO
	

	


	IF EMPTY(aRet[2])
		/*------------------------------------------------------ Augusto Ribeiro | 25/01/2017 - 6:11:28 PM
		
		 	RECEBIMENTO ANTECIPADO
			Gera RA no financeiro
		
		------------------------------------------------------------------------------------------*/		
		ProcRegua(len(aDadosMA))
	
		DBSELECTAREA("ZCA")
		aSort(aDadosCR,,,{ |x,y| x[nSE1ZCA] < y[nSE1ZCA] })
		
		DBSELECTAREA("SE1")
		for nI := 1 to Len(aDadosMA)
			IncProc("Conciliando..")
			
			IF aDadosMA[nI, 1]	.and. aDadosMA[nI, 2] == D_RECEB_ANTECIPADO
			
				nPosMv	:= aScan(aDadosCR, { |x| x[nSE1ZCA] ==  aDadosMA[nI,nZCARECNO]})

				/*------------------------------------------------------ Augusto Ribeiro | 03/11/2017 - 5:14:34 PM
					Gera Recebimento antecipado
				------------------------------------------------------------------------------------------*/
				aRetAux	:= U_CP11MVRA(aDadosMA[nI,nZCARECNO], aDadosCR[nPosMv, nE1FILIAL], aDadosCR[nPosMv, nE1CLIENTE], aDadosCR[nPosMv, nE1LOJA])
				
				IF !(aRetAux[1])
					aRet[1]	:= .F.
					aRet[2]	:= aRetAux[2]+". "					
					EXIT
				ENDIF			
			endif
		next nY	
	
	


		IF EMPTY(aRet[2])
					
			/*------------------------------------------------------ Augusto Ribeiro | 25/01/2017 - 6:11:28 PM
			
				LANCAMENTOS 
				Gera LanÁamentos na MOVIMENTACAO BANC¡RIA
			
			------------------------------------------------------------------------------------------*/
			ProcRegua(len(aDadosMA))
			DBSELECTAREA("ZCA")
			aSort(aDadosCR,,,{ |x,y| x[nSE1ZCA] < y[nSE1ZCA] })
			
			DBSELECTAREA("SE1")
			for nI := 1 to Len(aDadosMA)
				IncProc("Conciliando..")
				
				IF aDadosMA[nI, 1]	.and. aDadosMA[nI, 2] == D_TAXA
				
					nPosMv	:= aScan(aDadosCR, { |x| x[nSE1ZCA] ==  aDadosMA[nI,nZCARECNO]})
	
					/*------------------------------------------------------ Augusto Ribeiro | 03/11/2017 - 5:14:34 PM
						Gera movimento banc·rio e vincula ZCB
					------------------------------------------------------------------------------------------*/
					aRetAux	:= U_CP11MOVB(aDadosCR[nPosMv, nE1FILIAL], aDadosMA[nI,nZCARECNO], aDadosCR[nPosMv, nE1NATUREZ], aDadosCR[nPosMv, nE1CCUSTO])
					
					IF !(aRetAux[1])
						aRet[1]	:= .F.
						aRet[2]	:= aRetAux[2]+"."					
						EXIT
					ENDIF			
				endif
			next nY
		ENDIF
	ENDIF

	//| Atualiza toda a interface|
	fAtualiza()
else
	aRet[2]	:= "Limite de lanÁamentos a serem criados na movimentaÁ„o banc·ria excedido. Somente È permitido efetivar ["+alltrim(str(nMaxTaxa))+"][SX6 CP11_GELAN]"
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
Local nI

	
	

	U_CP1111MA("A",@oLbxMA,@aCpoEx,@aHeadEx, @aDadosMA)
	//oLbxMA:nAt	:= 1
	U_CP1111CR("A",@oLbxCR,@aCpoCR,@aHeadMv, @aDadosCR)
	//oLbxCR:nAt	:= 1

	//nSaldoMA	:= SaldoMA(cpBanco, cpAg, cpConta, dpDtTrAte)	
	//nSaldoCR	:= SaldoCR(cpBanco, cpAg, cpConta, dpDtTrAte)
	
/*	
	CalcTot("EXTRATO")	
	oTotMA:CtrlRefresh()
	
	CalcTot("MOVIMENTO")
	oTotCon:CtrlRefresh()
	*/
	ListTot()	
	
	nMarkConc	:= 1 
	nTotMACon	:= 0
	nTotCRCon	:= 0

	
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




/*/{Protheus.doc} SaldoCR
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
Static Function SaldoCR()
Local nRet		:= 0
Local cQuery	:= "" 
Local nSaldoAtu	:= 0
Local nSaldoIni	:= 0
	
/*------------------------------------------------------ Augusto Ribeiro | 21/10/2017 - 2:58:12 PM
	Calcula Saldo do SE1
------------------------------------------------------------------------------------------*/
nRet	:= 0
For nI := 1 to len(aDadosCR)
	nRet	+= aDadosCR[nI,nE1SALDO]
NEXT nI

Return(nRet)






/*/{Protheus.doc} SaldoMA
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
Static Function SaldoMA()
Local nRet		:= 0
Local cQuery	:= "" 
Local nSaldoZB2	:= 0
Local nSaldoIni	:= 0
Local dSaldoIni	:= ctod('  /  /  ')

Local cDigConta	:= ""


	/*------------------------------------------------------ Augusto Ribeiro | 21/10/2017 - 2:58:12 PM
		Calcula Saldo do Movimento da Adquirente
	------------------------------------------------------------------------------------------*/
	IF !EMPTY(aDadosMA)
		For nI := 1 to len(aDadosMA)
			nRet	+= aDadosMA[nI,nZCASALDO]
		NEXT nI
	ENDIF
	
Return(nRet)





/*/{Protheus.doc} CP11011MODEL
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
USER FUNCTION CP11011MODEL()
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
Local nSelMA	:= 0
Local nSelCR	:= 0
Local nTotMA	:= 0
Local nTotCR	:= 0
Local nDif
Local aMAMark	:= {}
Local aCRMark	:= {}
Local nVlrTol	:= 0


for nI:= 1 to Len(aDadosMA)
	IF aDadosMA[nI, 2] == D_SELECIONADO
		nTotMA	+= aDadosMA[nI, nZCASALDO]
		aadd(aMAMark,nI)	
	ENDIF 	
next nI


for nI:= 1 to Len(aDadosCR)
	IF aDadosCR[nI, 2] == D_SELECIONADO
		
		//| Busca tolerancia|
		IF nVlrTol == 0
			nVlrTol	:= SUPERGETMV("CP11_BXTOL",.F.,0.05, aDadosCR[nI, nE1FILIAL])
		ENDIF
		
		nTotCR	+= aDadosCR[nI, nE1SALDO]+aDadosCR[nI, nAJUSTE]
		aadd(aCRMark,nI)	
	ENDIF 	
next nI

/*------------------------------------------------------ Augusto Ribeiro | 15/11/2017 - 6:45:20 PM
	Caso esteja dentro da tolerancia, permite seleÁ„o e altera  status para CONCILIADO
------------------------------------------------------------------------------------------*/
nDif	:= nTotMA-nTotCR
IF nDif == 0 .OR.;
 	(nDif < 0 .AND. nDif >= (nVlrTol*-1)) .OR.;
 	(nDif > 0 .AND. nDif <= nVlrTol)
 
 
	FOR nI:= 1 to Len(aMAMark)
		aDadosMA[aMAMark[nI], 2]	:= D_CONCILIADO	
		nSelMA++	
	NEXT nI
	 
	FOR nI:= 1 to Len(aCRMark)
		aDadosCR[aCRMark[nI], 2]	:= D_CONCILIADO
		nSelCR++
	NEXT nI	 
	
	/*------------------------------------------------------ Augusto Ribeiro | 15/11/2017 - 7:45:25 PM
		Registra valor de Ajuste
	------------------------------------------------------------------------------------------*/ 
	IF nDif <> 0
		aDadosCR[aCRMark[LEN(aCRMark)], nAJUSTE]	:= nDif
	ENDIF
 
	nMarkConc++
	
	oLbxMA:Refresh()
	oLbxCR:Refresh() 
ENDIF

//IF nTotMACon == nTotCRCon
//	for nI:= 1 to Len(aDadosMA)
//		IF aDadosMA[nI, nMACONCI] == nMarkConc
//			aDadosMA[nI, 2]	:= D_CONCILIADO	
//			nSelMA++		
//		ENDIF		
//	next nI
//	
//	for nI:= 1 to Len(aDadosCR)
//		IF aDadosCR[nI, nCRCONCI] == nMarkConc
//
//			/*------------------------------------------------------ Augusto Ribeiro | 15/02/2017 - 4:34:27 PM
//				Recurso de Auto Conciliacao - Registros da mesma origem
//			------------------------------------------------------------------------------------------*/
//			IF nSelMA == 0
//				aDadosCR[nI, 2]	:= D_CONCILIADO_AUTO
//			ELSE
//				aDadosCR[nI, 2]	:= D_CONCILIADO	
//			ENDIF
//		
//			
//			nSelCR++
//		ENDIF		
//	next nI	
//
//	/*------------------------------------------------------ Augusto Ribeiro | 15/02/2017 - 4:34:27 PM
//		Recurso de Auto Conciliacao - Registros da mesma origem
//	------------------------------------------------------------------------------------------*/	
//	IF nSelCR == 0 .AND. nSelMA >= 2
//		for nI:= 1 to Len(aDadosMA)
//			IF aDadosMA[nI, nMACONCI] == nMarkConc
//				aDadosMA[nI, 2]	:= D_CONCILIADO_AUTO		
//			ENDIF		
//		next nI
//	ENDIF
//	
//	
//	nMarkConc++
//	
//	oLbxMA:Refresh()
//	oLbxCR:Refresh()
//
//ENDIF

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
for nI:= 1 to Len(aDadosMA)
	IF aDadosMA[nI, nMACONCI] == nMarkAnt
		
		IF aDadosMA[nI, 2]	== D_CONCILIADO //.OR. aDadosMA[nI, 2] == D_CONCILIADO_AUTO
			aDadosMA[nI, 2]			:= D_SELECIONADO
			aDadosMA[nI, nMACONCI]	:= nMarkConc
		ENDIF		
	ENDIF	
	
	/*--------------------------
		Recalcula valor selecionado
	---------------------------*/
	IF aDadosMA[nI, nMACONCI] == nMarkConc
		nTotAux	+= aDadosMA[nI, nZCASALDO]
	ENDIF
		
next nI
nTotMACon	:= nTotAux


nTotAux	:= 0
for nI:= 1 to Len(aDadosCR)
	IF aDadosCR[nI, nCRCONCI] == nMarkAnt
		
		IF aDadosCR[nI, 2]	== D_CONCILIADO //.OR. aDadosCR[nI, 2] == D_CONCILIADO_AUTO 
			aDadosCR[nI, 2]			:= D_SELECIONADO
			aDadosCR[nI, nCRCONCI]	:= nMarkConc
		ENDIF		
	ENDIF	
	
	/*--------------------------
		Recalcula valor selecionado
	---------------------------*/
	IF aDadosCR[nI, nCRCONCI] == nMarkConc
		nTotAux	+= aDadosCR[nI, nE1SALDO]
	ENDIF
		
next nI
nTotCRCon	:= nTotAux




oLbxMA:Refresh()
oLbxCR:Refresh()


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




/*/{Protheus.doc} CP1111X1
(long_description)
@author Jonatas Oliveira | www.compila.com.br
@since 21/10/2017
@version 6
@param cTipo, 1=Adquirentes;2=Modalidade
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
User Function CP1111X1(cTipo)
	Local _cRet	:= ""
	Local aCartoes	:= {}
	Local cTitBrw	:= ""
	Local aArea		:= GetArea()
	Local aAreaZC1	:= ZC1->(GetArea())
	Local cStatus	:= ""
	Local aAux		:= {}
	Local nI		:= 0 
	Local nY		:= 0 
	
	IF cTipo == "1"
	
		DBSELECTAREA("ZC1")
		ZC1->(DBSETORDER(1))
		ZC1->(DBGOTOP())
		
		WHILE ZC1->(!EOF())
			Aadd(aCartoes,{ZC1->ZC1_CODIGO,ZC1->ZC1_DESC})
			
			ZC1->(DBSKIP())
		ENDDO
		
		cTitBrw := 	"Adquirentes"
		
	ELSEIF cTipo == "2"
	
		//|cart„o de dÈbito, crÈdito ‡ vista, crÈdito parcelado|
		Aadd(aCartoes,{"1","Cart„o de dÈbito"})
		Aadd(aCartoes,{"2","CrÈdito ‡ Vista"})
		Aadd(aCartoes,{"3","CrÈdito Parcelado"})
		Aadd(aCartoes,{"T","Taxa/Ajustes"})
		
		cTitBrw := 	"Modalidade"
		
	ELSEIF cTipo == "3"	
	
		Aadd(aCartoes,{"CD","Cart„o de dÈbito"})
		Aadd(aCartoes,{"CC","CrÈdito de CrÈdito"})
		Aadd(aCartoes,{"FT","Fatura"})
		Aadd(aCartoes,{"DH","Dinheiro"})
		Aadd(aCartoes,{"VZ","Vazio"})
		
		cTitBrw := 	"Forma de Pagamento"		
			
	ELSEIF cTipo == "4"
				
		//1=Pendente;2=Proc. Parcial;3=Concluido;4=Inconsistencia;5=Falha --ZCA_STATUS
		
		Aadd(aCartoes,{"1","Pendente"})
		Aadd(aCartoes,{"2","Proc. Parcial"})		
		Aadd(aCartoes,{"3","Concluido"})
		Aadd(aCartoes,{"4","Inconsistencia"})
		Aadd(aCartoes,{"5","Falha"})

		
		cTitBrw := 	"Status"
			
	ELSEIF cTipo == "5"	
		
		DBSELECTAREA("SX3")
		SX3->(dbSetOrder(2))
	
		If SX3->(dbSeek( "ZCA_STATUS" )  ) 			
			aAux := StrTokArr( X3Cbox() , ";" )
			
			For nI := 1 To Len(aAux)
				nY 		:= AT("=",aAux[nI] )
				cStatus := LEFT(aAux[nI] , nY-1  )
				
				IF cStatus != "3"
					Aadd(aCartoes,{ LEFT(aAux[nI] , nY-1  ),SUBSTR(aAux[nI] , nY + 1 , LEN(aAux[nI])  )})
				ENDIF 
			Next nI
			
		EndIf
		
	ENDIF 
	
	_cRet := BrowX1(cTitBrw, aCartoes)
	
	RestArea(aAreaZC1)
	RestArea(aArea)
	
Return(_cRet)


/*/{Protheus.doc} BrowX1
Monta Pequeno Browser da Pergunta, permitindo que o usu·rio
selecione mais de uma opÁ„o.
Recebe Array com os elementos  
Retorna: **** 
@version 1.0
/*/
Static Function BrowX1(cTitBrw,aOpcoes)
	Local BrowX1
	Local MvPar
	Local MvParDef	:=	""
	Local l1Elem   	:=	Nil
	Local lTipoRet	:= 	.T.
	Local cFilBack	:= cFilAnt
	Local nI
	Private _aFilial:=	{}
	Private aSit	:= 	{}

	l1Elem 			:= 	If (l1Elem = Nil , .F. , .T.)

	DEFAULT lTipoRet	:= .T.
	DEFAULT BrowX1 		:= "Selecione " + cTitBrw
	DEFAULT aOpcoes		:= {}

	IF LEN(aOpcoes) == 0
		Return
	ENDIF

	cAlias 			:= Alias() 					 // Salva Alias Anterior

	IF lTipoRet
		MvPar:=&(Alltrim(ReadVar()))		 // Carrega Nome da Variavel do Get em Questao
		mvRet:=Alltrim(ReadVar())			 // Iguala Nome da Variavel ao Nome variavel de Retorno
	EndIF


	For nI := 1 To LEN(aOpcoes)

		aadd(aSit, aOpcoes[nI,1]+" - "+aOpcoes[nI,2])
		MvParDef += aOpcoes[nI,1]
	Next nI



	// Tamanho dos caracters de retorno (Ex.: 04)
	nTam := LEN(aOpcoes[1,1])
	lComboBox := .T.
	IF lTipoRet
		IF f_Opcoes(@MvPar,BrowX1,aSit,MvParDef,12,49,l1Elem,nTam)	// Chama funcao f_Opcoes
			&MvRet := mvpar                                   			// Devolve Resultado
		EndIF
	EndIF

	dbSelectArea(cAlias) 	 // Retorna Alias

	cFilAnt	:= cFilBack 	// Retorna a empresa

Return( IF( lTipoRet , .T. , MvParDef ) )


//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ AUGUSTO RIBEIRO                                  ≥   
//≥                                                  ≥
//≥ Recebe String separa por caracter "X"            ≥
//≥ ou Numero de Caractres para "quebra" _nCaracX)   ≥
//≥ Retorna String pronta para IN em selects         ≥
//≥ Ex.: Retorn: ('A','C','F')                       ≥
//≥                                                  ≥
//≥ PARAMETROS:  _cString, _cCaracX                  ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
Static Function INQuery(_cString, _cCaracX, _nCaracX)
Local _cRet	:= ""                  
Local _cString, _cCaracX, _nCaracX, nY
Local _aString	:= {}                            
Default	_nCaracX := 0                   
                                                                  
	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	//≥Valida Informacoes Basicas ≥
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
    IF !EMPTY(_cString) .AND. (!EMPTY(_cCaracX) .OR. _nCaracX > 0)
                                
    	nString	:= LEN(_cString)
    	
		

		//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
		//≥ Utiliza Separacao por Numero de Caracteres ≥
		//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
		IF _nCaracX > 0
			FOR nY := 1 TO nString STEP _nCaracX
			
				AADD(_aString, SUBSTR(_cString,nY, _nCaracX) )
			
			Next nY
			
		//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
		//≥ Utiliza Separacao por caracter especifico ≥
		//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
		ELSE
			_aString	:= WFTokenChar(_cString, _cCaracX)		
		ENDIF
	                


		//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
		//≥ Monta String para utilizar com IN em querys≥
		//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
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



/*/{Protheus.doc} CP1111CB
Realiza o cancelamento de baixa 
@author Jonatas Oliveira | www.compila.com.br
@since 08/11/2017
@version 1.0
/*/
User Function CP1111CB()
Local cMsgAviso := ""
Local nOpcAviso	:= 0 
Local cQuery	:= ""
/*
cMsgAviso	:= "Esta rotina realiza a CANCELAR todos os movimentos baixados."+CRLF
cMsgAviso	+= ""+CRLF+CRLF
cMsgAviso	+= "Deseja Continuar ?"

nOpcAviso	:= AVISO("CANCELAR Baixa", cMsgAviso,{"SIM", "N√O"},2)
*/
nOpcAviso	:= 1
IF nOpcAviso == 1

	cQuery := " SELECT TOP 1 ZCB.R_E_C_N_O_ as ZCB_RECNO "+CRLF
	cQuery += " FROM "+RetSqlName("ZCB")+" ZCB "+CRLF
	cQuery += " WHERE ZCB_TPOPER = '1' "+CRLF
	cQuery += " AND D_E_L_E_T_ = '' "+CRLF
	
	If Select("TSQL") > 0
		TSQL->(DbCloseArea())
	EndIf
	
	DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TSQL",.F., .T.)						

	
	
	WHILE TSQL->(!EOF())
	
		CANCBXCR(TSQL->ZCB_RECNO)
	
		TSQL->(DBSKIP()) 
	ENDDO	


	
ENDIF 	

	
	
	
	
Return

/*/{Protheus.doc} CANCBXCR
Processa o cancelamento
@author Jonatas Oliveira | www.compila.com.br
@since 08/11/2017
@version 1.0
/*/
Static Function CANCBXCR(nRecZCB)
Local aTitulo	:= {}
Local _cCodEmp	:= ""
Local _cCodFil	:= ""
Local _cFilNew	:= ""	
Local cCodZCB	:= ""
Local lBaixou	:= .F.

DBSELECTAREA("ZCB")
ZCB->(DBGOTO(nRecZCB))

DBSELECTAREA("SE1")
SE1->(DBSETORDER(1))

WHILE ZCB->(!EOF()) //.AND. cCodZCB == ZCB->ZCB_CODIGO

	IF ALLTRIM(ZCB->ZCB_ALIAS) == "SE1"
	
		SE1->(DBGOTO(ZCB->ZCB_RECALI))
		
		_cCodEmp 	:= SM0->M0_CODIGO
		_cCodFil	:= SM0->M0_CODFIL
		_cFilNew	:= SE1->E1_FILIAL //| CODIGO DA FILIAL DE DESTINO 
		
		IF _cCodEmp+_cCodFil <> _cCodEmp+_cFilNew
			CFILANT := _cFilNew
			opensm0(_cCodEmp+CFILANT)
		ENDIF
		
		aTitulo := {}
		
				
		AADD(aTitulo,{"E1_FILIAL" 	,SE1->E1_FILIAL			, Nil})	// 01
		AADD(aTitulo,{"E1_PREFIXO" 	,SE1->E1_PREFIXO		, Nil})	// 01
		AADD(aTitulo,{"E1_NUM"     	,SE1->E1_NUM			, Nil})	// 02
		AADD(aTitulo,{"E1_PARCELA" 	,SE1->E1_PARCELA		, Nil})	// 03
		AADD(aTitulo,{"E1_TIPO"    	,SE1->E1_TIPO			, Nil})	// 04
		AADD(aTitulo,{"E1_MOEDA"   	,SE1->E1_MOEDA			, Nil})	// 05
		AADD(aTitulo,{"E1_TXMOEDA"	,SE1->E1_TXMOEDA		, Nil})	// 06
		AADD(aTitulo,{"E1_CLIENTE"	,SE1->E1_CLIENTE		, Nil})	// 06
		AADD(aTitulo,{"E1_LOJA"		,SE1->E1_LOJA			, Nil})	// 06
		
		
		lMSHelpAuto := .T. //.F. // para nao mostrar os erro na tela
		lMSErroAuto := .F. //.F. // inicializa como falso, se voltar verdadeiro e' que deu erro	
		/*
		aTitulo := {	{"E1_PREFIXO"  	,SE1->E1_PREFIXO       	   		,Nil    },;
						{"E1_NUM"      	,SE1->E1_NUM            		,Nil    },;
						{"E1_PARCELA"  	,SE1->E1_PARCELA        		,Nil    },;
						{"E1_TIPO"     	,SE1->E1_TIPO               	,Nil    },;
						{"E1_CLIENTE"  	,SE1->E1_CLIENTE               	,Nil    },;
						{"E1_LOJA"  	,SE1->E1_LOJA               	,Nil    }}
			*/
		dDatabase := SE1->E1_BAIXA
		
		lMsErroAuto := .F.
		
		
		DBSELECTAREA("SE5")
		//MSExecAuto({|x,y| Fina070(x,y)},aTitulo,6)
		
		lBaixou := Fina070(aTitulo,5) 
		
		IF lMsErroAuto
			MOSTRAERRO()
			ALERT("FALHA NA BAIXA")
		ENDIF 
		/*
		lMSHelpAuto := .T. //.F. // para nao mostrar os erro na tela
		lMSErroAuto := .F. //.F. // inicializa como falso, se voltar verdadeiro e' que deu erro	

		//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
		//≥Executa o Cancelamento da Baixa do Titulo                         ≥
		//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
		MSExecAuto({|x,y| FINA070(x,y)},aTitulo,5)
		
		If 	lMsErroAuto
			MostraErro()
		EndIf
		*/
		
		/*---------------------------------------
		Restaura FILIAL  
		-----------------------------------------*/
		IF _cCodEmp+_cCodFil <> _cCodEmp+_cFilNew
			CFILANT := _cCodFil
			opensm0(_cCodEmp+CFILANT)			 			
		ENDIF 	
		
	ENDIF 

	ZCB->(DBSKIP())
ENDDO 
	
Return()





/*/{Protheus.doc} AplicaDesc
 Aplica Desconto Especial sobre o titulo conforme parametro CP11_BXMTO
@author Augusto Ribeiro | www.compila.com.br
@since 16/11/2017
@version 6
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function AplicaDesc()
Local nPosMA, nMASaldo, nDifSaldo, nI, nCRSaldo
Local nTSelCR

IF aDadosCR[oLbxCR:nAt, nSE1RECNO]

	IF EMPTY(aDadosCR[oLbxCR:nAt, nAJUSTE])
	
		nPerDesc	:= SUPERGETMV("CP11_BXMTO",.F.,3, aDadosCR[oLbxCR:nAt, nE1FILIAL])
		
		IF nPerDesc > 0
		
		
			/*-----------------------------------------------
				Busca registro do movimento da adquirente
			-----------------------------------------------*/
			nPosMA	:= aScan(aDadosMA, { |x| x[nMACONCI] ==  nMarkConc})
			IF nPosMA > 0
			
				//nCRCONCI
				
				nTSelCR		:= 0
				nPosMaior	:= 0
				nValMaior	:= 0
				FOR nI := 1 to len(aDadosCR)
					IF aDadosCR[nI, nCRCONCI] == nMarkConc
						nTSelCR	+= aDadosCR[nI, nE1SALDO]
						
						IF nValMaior < aDadosCR[nI, nE1SALDO]
							nPosMaior	:= nI
							nValMaior	:= aDadosCR[nI, nE1SALDO]
						ENDIF
						IF aDadosCR[nI, nAJUSTE] > 0
							FwHelpShow("INVALIDO","INVALIDO","Um ou mais registro selecionados j· possuem um desconto especificado.")
							oLbxCR:nAt	:= nPosMaior //| Posiciona no registro que recebeu o desconto.|
							
							oLbxMA:Refresh()
							oLbxCR:Refresh() 								
							
							RETURN()
						ENDIF
					ENDIF 
				NEXT nI			
			
			
				nMASaldo	:= aDadosMA[nPosMA, nZCASALDO]
				//nCRSaldo	:= aDadosCR[oLbxCR:nAt, nE1SALDO]
				IF nPosMaior > 0 
					nCRSaldo	:= aDadosCR[nPosMaior, nE1SALDO]
				ELSE
					nCRSaldo := 0 
				ENDIF 
				
				
				
				
				//nVlrPerc	:= nCRSaldo*(nPerDesc/100)
				nVlrPerc	:= nTSelCR*(nPerDesc/100)
				IF nVlrPerc <= nCRSaldo
				
					
					nDifSaldo	:= nMASaldo-nTSelCR
					
					IF nDifSaldo <> 0
						IF IIF(nDifSaldo > 0, nDifSaldo <= nVlrPerc, nDifSaldo >= (nVlrPerc*-1)) 
							aDadosCR[nPosMaior, nAJUSTE]	:= nDifSaldo
							
							ConfVlr()
							
							oLbxCR:nAt	:= nPosMaior //| Posiciona no registro que recebeu o desconto.|
							
							oLbxMA:Refresh()
							oLbxCR:Refresh() 					
						ELSE
							FwHelpShow("CP11_BXMTO","CP11_BXMTO","Desconto necess·rio excede o limite de "+alltrim(str(nPerDesc))+"% R$ "+alltrim(Transform(nVlrPerc, D_PICTURE_VLR))+"." )
						ENDIF
					ENDIF
				ELSE
					FwHelpShow("INVALIDO","INVALIDO","Desconto necess·rio ultrapassa o valor do titulo.")				
				ENDIF
			ELSE
				FwHelpShow("MOV.ADQ","MOV.ADQ","Por favor selecione primeiramente o movimento correspondente da adquirente." )
			ENDIF
		ELSE
			FwHelpShow("CP11_BXMTO","CP11_BXMTO","Nenhum desconto pode ser aplicado, parametro CP11_BXMTO vazio.")
		ENDIF
	ELSE
		FwHelpShow("INVALIDO","INVALIDO","Este registro j· possui um desconto especificado.")	
	ENDIF

ELSE

	FwHelpShow("NAO SELEC","NAO SELEC","Registro posicionado n„o esta selecionado")
	
ENDIF


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
//Parametros para Filtrar Cliente
Private aParams:={}
Private aRetPar:={}



AADD(aParams,{1,"Filial",PADR("",TAMSX3("E1_FILIAL")[1]),,"","SM0","",30,.F.,})
AADD(aParams,{1,"Cliente",PADR("",TAMSX3("A1_COD")[1]),,"","SA1","",30,.F.,})
AADD(aParams,{1,"Loja",PADR("",TAMSX3("A1_LOJA")[1]),,"","","",30,.F.,})

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

/*/{Protheus.doc} VisulAdq
Visualiza o Mov. Adquirente
@author Jonatas Oliveira | www.compila.com.br
@since 20/11/2017
@version 1.0
/*/
Static Function VisulAdq()
	Local aArea		:= GetArea()
	Local aAreaZCA	:= ZCA->(GetArea())
	
	IF aDadosMA[oLbxMA:nAt, nZCARECNO]
	
	
		DBSELECTAREA("ZCA")
		ZCA->(DBGOTO(aDadosMA[oLbxMA:nAt,nZCARECNO]))
		
		FWExecView("Visualizar","CP11010", 1,, {|| .T. })
	
	ELSE
	
		FwHelpShow("NAO LOCALIZ","NAO LOCALIZ","Registro posicionado n„o foi localizado")
		
	ENDIF
	
	RestArea(aAreaZCA)
	RestArea(aArea)
	
Return()


/*/{Protheus.doc} VisulTit
Visualiza Titulo Contas ‡ Receber
@author Jonatas Oliveira | www.compila.com.br
@since 20/11/2017
@version 1.0
/*/
Static Function VisulTit()

	Local _cCodEmp	:= ""
	Local _cCodFil	:= ""
	Local _cFilNew	:= ""	
	Local aArea		:= GetArea()
	Local aAreaSE1	:= SE1->(GetArea())
	
	
	IF aDadosCR[oLbxCR:nAt, nSE1RECNO]
		DBSELECTAREA("SE1")
		
		SE1->(DBGOTO(aDadosCR[oLbxCR:nAt, nSE1RECNO] )) 
		
		_cCodEmp 	:= SM0->M0_CODIGO
		_cCodFil	:= SM0->M0_CODFIL
		_cFilNew	:= SE1->E1_FILIAL //| CODIGO DA FILIAL DE DESTINO 
		
		IF _cCodEmp+_cCodFil <> _cCodEmp+_cFilNew
			CFILANT := _cFilNew
			opensm0(_cCodEmp+CFILANT)
		ENDIF
	
		//MaMakeView( "SE1" )
		FINA040(NIL,2) 
		/*---------------------------------------
		Restaura FILIAL  
		-----------------------------------------*/
		IF _cCodEmp+_cCodFil <> _cCodEmp+_cFilNew
			CFILANT := _cCodFil
			opensm0(_cCodEmp+CFILANT)			 			
		ENDIF 	
		
	
	ELSE
	
		FwHelpShow("NAO LOCALIZ","NAO LOCALIZ","Registro posicionado n„o foi localizado")
		
	ENDIF
	
	RestArea(aAreaSE1)
	RestArea(aArea)
Return()


/*/{Protheus.doc} vldMarca
	
	Valida se a marca do tÌtulo corresponde com a marca da conta banc·ria

	@type  Static Function
	@author Julio Teixeira - Compila
	@since 18/05/2020
	@version 12
	@param nRecZCA, aRegE1
	@return lRet
/*/
Static Function vldMarca(nRecZCA,aRegE1)

Local lRet := .T.
Local aArea := GetArea()
Local cMarcaSA6 := ""
Local nX := 1
Local cMarcaSE1 := ""

Default nRecZCA := 0
Default aRegE1 := {}	

DbSelectArea("ZCA")
ZCA->(DbGoTo(nRecZCA))

DbSelectArea("SA6")
SA6->(DbOrderNickName("CONTACART")) 
If SA6->(DbSeek(ZCA->ZCA_BANCO+Padr(ZCA->ZCA_AGENC,TamSx3("A6_AGENCIA")[1])+ZCA->ZCA_CONTA))
	cMarcaSA6 := SA6->A6_XCODMAR

	DbSelectArea("SE1")

	For nX := 1 to len(aRegE1)
		SE1->(DbGoTo(aRegE1[nX][1]))
		cMarcaSE1 := U_GetMarca(SE1->E1_FILORIG)
		If Alltrim(cMarcaSA6) != Alltrim(cMarcaSE1)
			Help(" ",1,"Marca",,"Marca da filial da conta, Banco:"+SA6->A6_COD+", Ag: "+SA6->A6_AGENCIA+", Conta: "+SA6->A6_XCONCAR+", Marca: "+cMarcaSA6+;
			", diverge da marca da filial do titulo, Filial: "+SE1->E1_FILORIG+", Prefixo: "+SE1->E1_PREFIXO+", N˙mero: "+SE1->E1_NUM+" Marca: "+cMarcaSE1, 1, 0 )
			lRet := .F.
			Exit
		Endif		
	Next nX
Endif

RestArea(aArea)

Return lRet
