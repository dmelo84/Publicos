#Include "Protheus.Ch"
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

#DEFINE NOME_SEMAFORO "AFIN001"

#DEFINE D_TITULO 'Conciliador DDA'
#DEFINE D_ROTINA 'AFIN001' 

#DEFINE D_PERG "AFIN001"
#DEFINE D_PERG2 "AFIN001A"
#DEFINE D_PERGB "AFIN001B"


/*--------------------------
	LISTBOX Extrato
---------------------------*/
#DEFINE D_NAOSELECIONADO 0
#DEFINE D_SELECIONADO 1
#DEFINE D_CONCILIADO 2
//#DEFINE D_TAXA 3
#DEFINE D_CODBAR 3
//#DEFINE D_CONCILIADO_AUTO 4
#DEFINE D_RECEB_ANTECIPADO 4


/*--------------------------
	OPCOES RADIO
---------------------------*/
//#DEFINE OPCAO_CONCILIACAO 1
//#DEFINE OPCAO_TAXA 2
#DEFINE OPCAO_CONCILIA_DDA 1
#DEFINE OPCAO_GERA_CNAB 2
#DEFINE OPCAO_RECEB_ANTECIPADO 3


/*------------------------------------------------------ Augusto Ribeiro | 29/12/2016 - 10:26:08 AM
	PAMETROS DE USUABILIDADE
------------------------------------------------------------------------------------------*/
Static lISelec		:= .F.
Static lExecConc	:= .F.
Static cSEDMVPAR	:= ""
Static cCTTMVPAR	:= ""
Static lProcPA		:= .F. 

/*--------------------------
	TOTAIS RODAPE
---------------------------*/
//Static nTotDDA	:= 0



/*/{Protheus.doc} AFIN001
Conciliador banc·rio
@author Augusto Ribeiro | www.compila.com.br
@since 31/03/2016
@version 6
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/ 
User function AFIN001()
Private lSelConc	:= .T.
Private	lSelTaxa	:= .F.

Private oFList		:= TFont():New("Courier New",, 15, , .F., , , , .F., .F.) // Regular
//Private nZB2VALOR, nZB2DATA, nFIGRECNO, nZB2DESC, nDDACONCI, nZB2SE5
//Private nZCAVBRUTO, nZCASALDO, nZCADTPAG, nZCADTVEND, nFIGRECNO, nZCACODAUT, nDDACONCI, nZB2SE5
//Private nFIGFILIAL, nFIGFORNEC, nFIGLOJA, nFIGCNPJ, nFIGVALOR, nDDACONCI, nFIGRECNO, nFIGVENCTO

//substituÌda linha acima pela abaixo [Mauro Nagata, www.compila.com.br, 20200925]
Private nFIGFILIAL, nFIGFORNEC, nFIGLOJA, nFIGCNPJ, nFIGVALOR, nDDACONCI, nFIGRECNO, nFIGVENCTO, nFIGTITULO
//Private nE1FILIAL, nE1EMISSAO, nE2SALDO, nE1VALOR, nE1NATUREZ, nE1CCUSTO, nSE2RECNO, nSE2FIG, nCPCONCI, nAJUSTE, nE1PORTADO, nE1AGEDEP, nE1CONTA, nE1CLIENTE, nE1LOJA

//Private nE2FILIAL, nE2EMISSAO, nE2VENCTO, nE2SALDO, nE2VALOR, nSE2RECNO, nSE2FIG, nCPCONCI, nAJUSTE, nE2FORNECE, nA2CGC, nE2LOJA, nE2CODBAR
//substituÌda linha acima pela abaixo [Mauro Nagata, www.compila.com.br, 20200925]
Private nE2FILIAL, nE2EMISSAO, nE2VENCTO, nE2SALDO, nE2VALOR, nSE2RECNO, nSE2FIG, nCPCONCI, nAJUSTE, nE2FORNECE, nA2CGC, nE2LOJA, nE2CODBAR, nE2TITULO

Private oTotMA, oTotCon, oTotTaxa, oTotCR, cTotalMv, oGetTeste
Private oSelDDA, cSelDDA, oSelCP, cSelCP, cGetTeste
Private oPaneRod	:= nil
Private aDim		:= {}

Private	nSaldoDDA	:= 0 //| Saldo do movimento|
Private	nSaldoCP	:= 0 //| Saldo do movimento|

/*------------------------------------------------------ Augusto Ribeiro | 25/01/2017 - 3:48:38 PM
Variaveis utilizadas no controle de multipla selecoes .
Relacionamento N para N

------------------------------------------------------------------------------------------*/
Private nMarkConc		:= 1 
Private nTotDDACon	:= 0
Private nTotCPCon		:= 0


/*--------------------------
	PARAMETROS 
---------------------------*/
Private cpFilDe, cpFilAte, cpBanco, cpAg, cpConta, dpDtTrDe, dpDtTrAte, cpCodAdq, cpModalid, cpStatZCA, cpRazStat
Private c1FilDe, c1FilAte, c1DtDe, c1DtAte, c1DtVDe, c1DtVAte, c1Prefixo, c1Forma, c1CodCli, c1Loja, n1StTit

/*--------------------------
	LISTBOX EXTRATO
---------------------------*/
Private oLbxDDA	:= Nil
Private aCpoEX		:= {}
Private aDadosDDA	:= {}
Private aHeadEx	:= {}
Private lVazioEx	:= .T.
//| Variaveis para Ordenacao da coluna|
Private lAllExt	:= .F.
Private nAntExt	:= 0
Private	nDadosMA	:= 0

/*---------------------------------
	LISTBOX MOVIMENTO BANCARIO
----------------------------------*/
Private oLbxCP		:= Nil
Private aCpoCP		:= {}
Private aDadosCP	:= {}
Private aHeadMv	:= {}
Private lVazioMv	:= .T.

//| Variaveis para Ordenacao da coluna|
Private lAllMv		:= .F.
Private nAntMv		:= 0
Private	nDadosCR	:= 0

/*------------------------------------------------------ Augusto Ribeiro | 26/12/2016 - 5:55:21 PM
	Variaveis para controle da seleÁ„o da conciliaÁ„o
------------------------------------------------------------------------------------------*/
Private aSelDDA	:= {}
Private aSelCP		:= {} 
Private nTolera	:= 0 							//| para consiliaÁao|
Private nConcTaxa := OPCAO_CONCILIA_DDA 	//| 1=Concilia, 2=Taxa Selecao de movimento para consiliaÁ„o ou TAXA|
Private nTotDDA	:= 0
Private lVazio		:= .F.


/*-------------------------------
	PARAMETROS DE USUABILIDADE
--------------------------------*/
Pergunte( D_PERG2, .F. )
cGrvCNAB		:= AllTrim(MV_PAR01)

If Pergunte(D_PERG ,.T.)

	cFilDe		:= MV_PAR01
	cFilAte		:= MV_PAR02
	cForDe		:= MV_PAR03
	cForAte		:= MV_PAR04	
	cLojaDe		:= MV_PAR05
	cLojaAte		:= MV_PAR06	
	//cConsVenc	:= MV_PAR07
	dVencDe		:= MV_PAR07
	dVencAte		:= MV_PAR08
	dProcDe		:= MV_PAR09
	dProcAte		:= MV_PAR10

	If  Pergunte( D_PERGB , .T. )
	
		c1FilDe		:= MV_PAR01
		c1FilAte		:= MV_PAR02
		c1DtVDe		:= MV_PAR03	
		c1DtVAte		:= MV_PAR04		
		c1DtDe		:= MV_PAR05	
		c1DtAte		:= MV_PAR06					
		n1StTit		:= MV_PAR07
		
		/*
		c1Forma		:= MV_PAR07
		c1CodCli		:= MV_PAR08
		c1Loja		:= MV_PAR09
		*/
	
		//nSaldoCP	:= SaldoCP(cpBanco, cpAg, cpConta, dpDtTrAte)
		//nSaldoDDA	:= SaldoDDA(cpBanco, cpAg, cpConta, dpDtTrAte)
		
		FWExecView("ConciliaÁ„o DDA",  D_ROTINA,  3,  /*oDlg*/,  /*bCloseOnOk*/,  /*bOk*/, /* nPercReducao*/, /*aEnableButtons*/,  /*bCancel*/ )// == 0
		/*
		If lExecConc
			ConcAuto()
		EndIf
		IIF(lExecConc, ConcAuto(), .F.)
		*/
	EndIf
EndIf


Return NIL

        
/*‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹‹
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±…ÕÕÕÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÀÕÕÕÕÕÕ—ÕÕÕÕÕÕÕÕÕÕÕÕÕª±±
±±∫Programa  ≥ AFIN001  ∫Autor  ≥Augusto Ribeiro     ∫ Data ≥ 07/01/2011  ∫±±
±±ÃÕÕÕÕÕÕÕÕÕÕÿÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕ ÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕπ±±
±±∫Desc.     ≥ 	Botoes do MBrowser                                        ∫±±
±±»ÕÕÕÕÕÕÕÕÕÕœÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕÕº±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂﬂ*/  
Static Function MenuDef()
Local aRotina := {}


ADD OPTION aRotina TITLE 'Pesquisar' 	ACTION 'PesqBrw'  	        	OPERATION 1 ACCESS 0
ADD OPTION aRotina TITLE 'Visualizar'	ACTION 'VIEWDEF.' + D_ROTINA 	OPERATION 2 ACCESS 0                         
ADD OPTION aRotina TITLE 'Incluir'  	ACTION 'VIE7DEF.' + D_ROTINA 	OPERATION 3 ACCESS 0  	
//ADD OPTION aRotina TITLE 'Conciliar Banco'  ACTION 'U_CP902MNU("CONCILIAR")' OPERATION 3 ACCESS 0
//ADD OPTION aRotina TITLE 'Alterar'   ACTION 'VIEWDEF.' + D_ROTINA 	OPERATION 4 ACCESS 0
//ADD OPTION aRotina TITLE 'Excluir'   ACTION 'VIEWDEF.' + D_ROTINA 	OPERATION 5 ACCESS 0
ADD OPTION aRotina TITLE 'Imprimir'   	ACTION 'VIEWDEF.' + D_ROTINA 	OPERATION 8 ACCESS 0
//ADD OPTION aRotina TITLE 'Copiar'    ACTION 'VIEWDEF.' + D_ROTINA 	OPERATION 9 ACCESS 0
//ADD OPTION aRotina TITLE 'TESTE'     ACTION 'U_FAT01TST()' 			OPERATION 9 ACCESS 0

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
Local oStruct 		:= FWFormStruct( 1, "SC5", /*bAvalCampo*/,/*lViewUsado*/ )
//Local oStruZCB 	:= FWFormStruct( 1, "SC6", /*bAvalCampo*/,/*lViewUsado*/ )
//Local oStruZG7 	:= FWFormStruct( 1, 'ZG7', /*bAvalCampo*/,/*lViewUsado*/ )
Local oModel   

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New('SC5MODEL', /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

// Adiciona ao modelo uma estrutura de formul·rio de ediÁ„o por campo
oModel:AddFields( "SC5MASTER", /*cOwner*/, oStruct, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )  

// Adiciona ao modelo uma estrutura de formul·rio de ediÁ„o por grid
//oModel:AddGrid( 'SC6ITEM', "SC5MASTER", oStruZCB, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

// Faz relaciomaneto entre os compomentes do model
//oModel:SetRelation( 'SC6ITEM', { { 'C6_FILIAL', 'XFILIAL("SC6")' }, { 'C6_NUM', 'C5_NUM' } }, SC6->(IndexKey(1)) ) //| ZCB_FILIAL, ZCB_CODMOV, ZCB_ALIAS, ZCB_RECALI, R_E_C_N_O_, D_E_L_E_T_|

// Liga o controle de nao repeticao de linha
//oModel:GetModel( 'ZG7DETAIL' ):SetUniqueLine( { 'ZG7_CHAVE' } )

// Indica que È opcional ter dados informados na Grid
//oModel:GetModel( 'ZG7DETAIL' ):SetOptional(.T.)

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( D_TITULO )

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( "SC5MASTER" ):SetDescription( 'Movimento dda (unificado)' )
//oModel:GetModel( 'SC6ITEM' ):SetDescription( 'Titulos/Movimento Financeiro'  )

// Liga a validaÁ„o da ativacao do Modelo de Dados
//oModel:SetVldActivate( { |oModel| COMP011ACT( oModel ) } )
/*
oModel:SetActivate( {|oModel| SetKey ( VK_F5, {||   U_AFIN01BTN('EFETIVA') } ),;
										SetKey ( VK_F7, {||  U_AFIN01BTN('DESCONTO') } ),;
										SetKey ( VK_F8, {||  U_AFIN01BTN('ADQUIRENTE') } ),;
										SetKey ( VK_F9, {||  U_AFIN01BTN('TITULO') } ) })
*/				
oModel:SetActivate( {|oModel| SetKey ( VK_F5, { ||  U_AFIN01BTN('EFETIVA') } ),;
										SetKey ( VK_F9, { ||  U_AFIN01BTN('TITULO') } ) } )
*/												

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
oView:CreateHorizontalBox( 'INFERIOR'	, 15 ) 	  

oView:CreateVerticalBox( 'LEFT_SUP'		, 50,'SUPERIOR' )
oView:CreateVerticalBox( 'RIGHT_SUP'	, 50,'SUPERIOR' )

oView:AddOtherObject( "EXTRATO"			, { |oPanel| U_AFIN01DD( "C", @oLbxDDA, @aCpoEx, @aHeadEx, @aDadosDDA, oPanel )  } )
oView:AddOtherObject( "MOVIMENTO"		, { |oPanel| U_AFIN01CP( "C", @oLbxCP, @aCpoCP, @aHeadMv, @aDadosCP, oPanel )  } )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'EXTRATO'		, 'LEFT_SUP')
oView:SetOwnerView( 'MOVIMENTO'	, 'RIGHT_SUP')

// Define campos que terao Auto Incremento
//oView:AddIncrementField( 'VIEW_ZEH', 'ZEH_CODITE' )

oView:AddOtherObject( "RODAPE"	, { |oPanel| ListTot(oPanel) } )
oView:SetOwnerView( "RODAPE"	, 'INFERIOR' )

// Criar novo botao na barra de botoes no antigo Enchoice Bar            
oView:AddUserButton( 'Parametros de Filtro.'				, 'Parametros Filtro'			, { |oView| U_AFIN01BTN('PERG_FILTRO', oView) } )
oView:AddUserButton( 'Parametros do Conciliador. F10'	, 'Parametros Conciliador '	, { |oView| U_AFIN01BTN('PERG_CONC', oView) } )
oView:AddUserButton( 'Conc. Autom·tica'					, 'Conc. Autom·tica'				, { |oView| U_AFIN01BTN('CONC_AUTO', oView) } )
//oView:AddUserButton( 'Transferencia Mov. Bancario. F11', 'Transferencia'				, { |oView| U_AFIN01BTN('TRANSF', oView) } )
oView:AddUserButton( 'Efetivar Baixa/ConciliaÁ„o. F5'	, 'Efetivar Baixa/ConciliaÁ„o', { |oView| U_AFIN01BTN('EFETIVA', oView) } )
//oView:AddUserButton( 'Aplicar Desconto. F7'			, 'Aplicar Desconto'				, { |oView| U_AFIN01BTN('DESCONTO', oView) } )
//oView:AddUserButton( 'Visualizar Mov. Adquirente. F8', 'Visualizar Adquirente'		, { |oView| U_AFIN01BTN('ADQUIRENTE', oView) } )
oView:AddUserButton( 'Visualizar titulo. F9'				, 'Visualizar titulo'			, { |oView| U_AFIN01BTN('TITULO', oView) } )
oView:AddUserButton( 'Alterar titulo. '					, 'Alterar titulo'				, { |oView| U_AFIN01BTN('TITULO_ALTERA', oView) } )

//oView:AddUserButton( 'Gerar RA. F8'						, 'Gerar RA'						, { |oView| U_AFIN01BTN('GERA_RA', oView) } )

//oView:AddUserButton( 'FunÁıes Contas a Pagar'			, 'FunÁıes Contas a Pagar'		, { |oView| U_AFIN01BTN('FCP', oView) } )
//oView:AddUserButton( 'FunÁıes Contas a Receber'		, 'FunÁıes Contas a Receber'	, { |oView| U_AFIN01BTN('FCR', oView) } )

//oView:AddUserButton( 'Parametros do Conciliador'		, 'Parametros'						, { |oView| U_AFIN01BTN('PARAMETROS', oView) } )

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






/*/{Protheus.doc} AFIN01DD
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
//User Function CP902LEX(cOpcList, oLbxDDA, aCpoHeader, aHeader, aDados, oPanel )
User Function AFIN01DD( cOpcList, oLbxDDA, aCpoHeader, aHeader, aDados, oPanel )
Local lRet				:= .T.
Local aVlrCor			:= {} 

Private aCpoHeader

Default	cOpcList		:= "C"
Default aCpoHeader	:= {} 
Default aHeader		:= {} 
Default aDados			:= {}
Default	oLbxDDA		:= NIL
Default	oPanel		:= NIL

//If cOpcList	== "A"
aRetAux		:= qMovDDA() 
aDadosDDA	:= {}
//If aRetAux[1]
aCpoEX		:= aRetAux[2]
aHeadEx		:= aRetAux[3]
aDadosDDA	:= aRetAux[4]
//nDadosMA	:= Len(aDadosDDA[1])
lRet			:= .T.
	
//Else
//Help(" ",1,"VAZIO",,"N„o existem registros no periodo selecionado.",4,5)
//lVazio := .t.
//	EndIf

aCpoHeader	:= aCpoEX
aHeader		:= aHeadEx
aDados		:= aDadosDDA
//aDadosLbx	:= aClone(aDadoTit)	
lVazioEx 	:= Empty( aDadosDDA )

MontLis( cOpcList, @oLbxDDA, @aCpoHeader, @aHeader, @aDados, @oPanel )

Return()


/*/{Protheus.doc} MontLis
Monta Interface de seleÁ„o
@author Jonatas Oliveira | www.compila.com.br
@since 14/04/2016
@version 1.0
/*/
Static Function MontLis(cOpcList, oLbxDDA, aCpoHeader, aHeader, aDados, oPanel)

	Local cBCodLin		:= ""   
	Local oOk 	     	:= LoadBitmap( GetResources(), "LBOK" )
	Local oNo   	   := LoadBitmap( GetResources(), "LBNO" )
	Local oVerde   	:= LoadBitmap( GetResources(), "BR_VERDE" )
	Local oAmarelo   	:= LoadBitmap( GetResources(), "BR_AMARELO" )
	Local oAzul   		:= LoadBitmap( GetResources(), "BR_AZUL" )
	Local oCinza   	:= LoadBitmap( GetResources(), "BR_CINZA" )
	Local oBranco   	:= LoadBitmap( GetResources(), "BR_BRANCO" )
	Local oFLabels 	:= TFont():New("Verdana",,018,,.T.,,,,,.F.,.F.)
	Local oFGrpCpo 	:= TFont():New("Verdana",,016,,.F.,,,,,.F.,.F.)

	Private oDlgMain	:= NIL

	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	//≥ cOpcList | C = Cria, A = Atualiza ≥
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	If cOpcList == "C"
	
		@ 3, 5 SAY oLblSolicita PROMPT "Movimento DDA" SIZE 150, 012 OF oPanel FONT oFLabels COLORS RGB(56,141,191), 16777215 PIXEL
		@ 12,0 LISTBOX oLbxDDA FIELDS HEADER ;
		FONT oFList;   
		" ", "Campos" ;                                                                                                    
		SIZE (oPanel:nClientWidth/2)-5,(oPanel:nClientHeight/2)-12 OF oPanel PIXEL ON  dblClick(SelDDA(@oLbxDDA), ListTot(), oLbxDDA:Refresh())

		oLbxDDA:aheaders 		:= aHeader			   
		oLbxDDA:BHEADERCLICK	:= { |oObj,nCol| OrdExt( oObj,nCol, .T.) }		
	EndIf
	
	/*
	@  250, 40 		SAY oLblSolicita PROMPT "Total " 		SIZE 50, 014 OF oDlgMain FONT oFGrpCpo COLORS 128, 16777215 PIXEL
	oTotalP := TGet():Create( oDlgMain,{|| CalcTot("TP", @aDadoMain)},250, 40	, 050,009,D_PICTURE_VLRT,,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,cTotalP,,,, )
	*/
	If Empty(aDados)
	
		/*------------------------------------------------------ Augusto Ribeiro | 02/11/2017 - 4:49:06 PM
			Monta Array Vazio para n„o dar erro na interface
		------------------------------------------------------------------------------------------*/
		aDados	:= {{}}
		aAdd(aDados[1], .F.)
		aAdd(aDados[1], 0)
		
		For nI := 3 To Len(aHeader)
		
			If nI == nFIGVALOR
				aAdd(aDados[1], 0)
			Else
		
				aAdd(aDados[1], '')
			EndIf
		Next nI
	EndIf   
	
		oLbxDDA:nAt	:= 1
	
		oLbxDDA:SetArray( aDados )  
		//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
		//≥ Cria string com Bloco de Codigo ≥
		//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
		//	cBCodLin	:= "LoadBitmap( GetResources(), aDados[oLbxDDA:nAt,"+AllTrim(str(nP04STATUS))+"] ) "
		
		/*
		#DEFINE D_NAOSELECIONADO 0
		#DEFINE D_SELECIONADO 1
		#DEFINE D_CONCILIADO 2
		#DEFINE D_CODBAR 3
		#DEFINE D_CONCILIADO_AUTO 4
		*/
		//oAzul
		
	
		cBCodLin	:= "Iif(aDados[oLbxDDA:nAt,1],oOk,oNo), Iif(aDados[oLbxDDA:nAt,2]==2,oVerde,Iif(aDados[oLbxDDA:nAt,2]==3,oAzul, Iif(aDados[oLbxDDA:nAt,2]==1,oAmarelo , Iif(aDados[oLbxDDA:nAt,2]==4, oBranco, oCinza))))"
		//cBCodLin	:= "IIF(AllTrim(aDados[oLbxDDA:nAt,nP04STATUS]) == AllTrim(X3COMBO('P04_STATUS','4')), oNo, Iif(aDados[oLbxDDA:nAt,1],oOk,oNo))"
	
	
		For nI := 3 To Len(aHeader)
			If nI > 1
				cBCodLin	+=", "
			EndIf
			cI	:= AllTrim(str(nI))
			
			If AllTrim(aCpoHeader[nI]) $ "FIG_VALOR"
				cBCodLin	+= "Transform(aDados[oLbxDDA:nAt,"+cI+"], '"+D_PICTURE_VLR+"')"
			Else
				cBCodLin	+= "aDados[oLbxDDA:nAt,"+cI+"]"		
			EndIf
			
		Next nI	
	
		cBCodLin	:= "oLbxDDA:bLine := {|| {"+cBCodLin+"}}"
		&(cBCodLin)    
	     
	oLbxDDA:Refresh()

	nSaldoDDA	:= SaldoDDA()

Return    






/*/{Protheus.doc} qMovDDA
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
Static Function qMovDDA()
Local aCpoHeader	:= {} 
Local aHeader		:= {} 
Local aDados		:= {}
Local aRet			:= {.F., aCpoHeader, aHeader, aDados}
//Local cAbatim	:= AllTrim(MVABATIM) + "|" + AllTrim(MVRECANT) + "|" + AllTrim(MV_CRNEG)
Local nCpoQry		:= 0
Local nY, nI, cForma, aRetAux
Local cQuery		:= ""
Local cDigConta	:= ""
Local cMsgWarn		:= ""
Local cContaCart	:= ""
Local cFlCtaIni	:= ""
Local cFlCtaFim	:= ""
Local cCtaConc		:= ""


cQuery := " SELECT FIG_FILIAL, FIG_VENCTO, FIG_VALOR, FIG_CNPJ, FIG_NOMFOR, FIG_FORNEC, FIG_LOJA, FIG_TITULO, FIG_TIPO, FIG_CODBAR,FIG_DATA, R_E_C_N_O_ AS FIG_RECNO "+CRLF
cQuery += " FROM 	"+RetSqlName("FIG")+" FIG WITH(NOLOCK) "												+ CRLF
cQuery += " WHERE FIG_FILIAL 		BETWEEN '" + cFilDe+"'			AND '" + cFilAte  + "' "		+ CRLF
cQuery += " 		AND FIG_FORNEC BETWEEN '" + cForDe+"' 			AND '" + cForAte  + "' "		+ CRLF
cQuery += " 		AND FIG_LOJA 	BETWEEN '" + cLojaDe+"' 		AND '" + cLojaAte + "' "		+ CRLF
cQuery += " 		AND FIG_VENCTO BETWEEN '" + dtos(dVencDe)+"' AND '" + dtos(dVencAte) + "' "+ CRLF
cQuery += " 		AND FIG_DATA 	BETWEEN '" + dtos(dProcDe)+"' AND '" + dtos(dProcAte) + "' "+ CRLF
cQuery += " 		AND FIG_CONCIL 		= '2' "																+ CRLF
cQuery += " 		AND FIG_FORNEC 		<> ''  "																+ CRLF
cQuery += " 		AND FIG.D_E_L_E_T_ 	<> '*' "																

If !(ISBLIND())
	MemoWrite(GetTempPath(.T.) + "AFIN001_qMovDDA.SQL", cQuery)
EndIf

If Select("TQRY") > 0
	TQRY->(DbCloseArea())
EndIf

dbUseArea(.T.,"TOPCONN",TCGenQRY(,,cQuery),'TQRY')

TCSetField("TQRY","FIG_DATA","D",08,00)
TCSetField("TQRY","FIG_VENCTO","D",08,00)

nCpoQry	:= TQRY->(FCOUNT()) 

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Monta aHeader ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ 
aAdd( aHeader,		"" )
aAdd( aHeader,		"" )                      
aAdd( aCpoHeader,	"MARK" )
aAdd( aCpoHeader,	"LEGENDA" )

For nY := 1 To nCpoQry-1   
/*
	If QRY->(FieldName(nY)) == "VLRCORR"	     
		aAdd(aHeader,"Valor Corrigido")	
		aAdd(aCpoHeader,FieldName(nY))
	ElseIf QRY->(FieldName(nY)) == "VLRMUL"
		aAdd(aHeader,"Valor Multa")	
		aAdd(aCpoHeader,FieldName(nY))
	ElseIf QRY->(FieldName(nY)) == "VLRJUR"
		aAdd(aHeader,"Valor Juros")	
		aAdd(aCpoHeader,FieldName(nY))
	ElseIf QRY->(FieldName(nY)) == "CNPJZTX"
		aAdd(aHeader,"CNPJ Zatix")	
		aAdd(aCpoHeader,FieldName(nY))				
	ElseIf QRY->(FieldName(nY)) == "BANCO"
		aAdd(aHeader,"Banco")	
		aAdd(aCpoHeader,FieldName(nY))
	Else
	*/
		aAdd(aHeader,AllTrim(RetTitle(FieldName(nY))))	
		aAdd(aCpoHeader,FieldName(nY))
	//EndIf 
Next nY	
aAdd(aCpoHeader, "FIG_RECNO")
aAdd(aCpoHeader, "EXCONCI")


//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Variaveis de posionamento dos campos ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
nFIGFILIAL		:=  Ascan( aCpoHeader, "FIG_FILIAL"	)
nFIGFORNEC		:=  Ascan( aCpoHeader, "FIG_FORNEC"	)
nFIGLOJA			:=  Ascan( aCpoHeader, "FIG_LOJA" 	)
nFIGCNPJ			:=  Ascan( aCpoHeader, "FIG_CNPJ" 	)
nFIGVENCTO		:=  Ascan( aCpoHeader, "FIG_VENCTO" )
nFIGVALOR		:=  Ascan( aCpoHeader, "FIG_VALOR" 	)
nFIGRECNO		:=  Ascan( aCpoHeader, "FIG_RECNO" 	)
nDDACONCI		:=  Ascan( aCpoHeader, "EXCONCI" 	)
//incluÌda linha abaixo [Mauro Nagata, www.compila.com.br, 20200925]
nFIGTITULO		:=  Ascan( aCpoHeader, "FIG_TITULO" )

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Monta aDados ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ 
If TQRY->(!Eof())

	
	
	
	Do While TQRY->(!Eof())
	
		aLinha	:= {}
		aAdd(aLinha, .F.) //|MARK|
		aAdd(aLinha, 0) //| LEGENDA|
		For nY := 1 To nCpoQry    
		
			cVlrCpo	:= TQRY->(FIELDGET(nY))
			If ValType(cVlrCpo) =="C"
				cVlrCpo := AllTrim(cVlrCpo)
			EndIf
	  		aAdd(aLinha, cVlrCpo)

		Next nY	 
		aAdd(aLinha, 0) //| EXCONCI |
			
		aAdd(aDados, aLinha)
	
		TQRY->(DbSkip())
	EndDo   
	
	//nFIGRECNO	:= Len(aDados[1])

	aRet[1]	:= .T.
	aRet[2]	:= aCpoHeader
	aRet[3]	:= aHeader
	aRet[4]	:= aDados

Else
 	aRet[1]	:= .F.
EndIf                  

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
		//If nCol == 1
		/*
			If  nConcTaxa == OPCAO_GERA_CNAB //| tAXA|
				lAllExt	:= !(lAllExt)
				
				For nI :=  1 To Len(oLbxAux:aArray)
					If lAllExt <> oLbxAux:aArray[nI,1]
						oLbxAux:nAt	:= nI
						SelDDA(@oLbxAux)
					EndIf
				Next nY
	
				//aEval(oLbxAux:aArray, {|x| x[1] := lAllExt} )
				nAntExt := nCol
			EndIf
			*/

			//oTotal:Refresh()
			//oTotSel:Refresh()
			//oTotalP:Refresh()
			//oTotSelP:Refresh()
		If nCol == nAntExt
			aSort(oLbxAux:aArray,,,{ |x,y| x[nCol] < y[nCol] })
			nAntExt := 0
		Else
			aSort(oLbxAux:aArray,,,{ |x,y| x[nCol] > y[nCol] })
			nAntExt := nCol
		EndIf

		oLbxAux:Refresh()

	EndIf

Return()



/*/{Protheus.doc} AFIN01CP
Montas Listbox com dados do Contas a Pagar
@author Augusto Ribeiro | www.compila.com.br
@since 26/12/2016
@version 6
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
//User Function CP902LMV(cOpcList, oLbxCP, aCpoHeader, aHeader, aDados, oPanel )
User Function AFIN01CP(cOpcList, oLbxCP, aCpoHeader, aHeader, aDados, oPanel )
Local lRet			:= .T.
Local aVlrCor		:= {} 

Private aCpoHeader

Default	cOpcList	:= "C"
Default aCpoHeader	:= {} 
Default aHeader		:= {} 
Default aDados			:= {}
Default	oLbxCP		:= NIL
Default	oPanel		:= NIL


//If cOpcList	== "A"
	aRetAux	:= qMovimen() 
	aDadosCP	:= {}
	//If aRetAux[1]
		aCpoCP	:= aRetAux[2]
		aHeadMv	:= aRetAux[3]
		aDadosCP	:= aRetAux[4]
		nDadosCR	:= 0
		If !Empty(aDadosCP)
			nDadosCR	:= Len(aDadosCP[1])
		EndIf

		lRet	:= .T.
	
	//Else
		//Help(" ",1,"VAZIO",,"N„o existem registros no periodo selecionado.",4,5)
		//lVazio	:= .T.
	//EndIf

aCpoHeader	:= aCpoCP
aHeader		:= aHeadMV
aDados		:= aDadosCP
//aDadosLbx	:= aClone(aDadoTit)	
lVazioMv 	:= Empty(aDadosCP)

ListMov(cOpcList, @oLbxCP, @aCpoHeader, @aHeader, @aDados, @oPanel)
If !(lVazioMv) .And. !(lVazioEx) 
	
	/*
	If ValType(oLbxDDA) == "O"
		oLbxDDA:lVisibleControl := .T.
	EndIf	
	If ValType(oLbxCP) == "O"
		oLbxCP:lVisibleControl := .T.
	EndIf	
	*/
Else
/*
	If ValType(oLbxDDA) == "O"
		oLbxDDA:lVisibleControl := .F.
	EndIf	
	If ValType(oLbxCP) == "O"
		oLbxCP:lVisibleControl := .F.
	EndIf
*/
EndIf 

Return()


/*/{Protheus.doc} MontLis
Monta Interface de seleÁ„o
@author Jonatas Oliveira | www.compila.com.br
@since 14/04/2016
@version 1.0
/*/
Static Function ListMov(cOpcList, oLbxCP, aCpoHeader, aHeader, aDados, oPanel)

	Local cBCodLin		:= ""   
	Local oOk 	     	:= LoadBitmap( GetResources(), "LBOK" )
	Local oNo   	  	:= LoadBitmap( GetResources(), "LBNO" )
	Local oVerde     	:= LoadBitmap( GetResources(), "BR_VERDE" )
	Local oAmarelo   	:= LoadBitmap( GetResources(), "BR_AMARELO" )
	Local oAzul   		:= LoadBitmap( GetResources(), "BR_AZUL" )
	Local oCinza     	:= LoadBitmap( GetResources(), "BR_CINZA" )
	Local oBranco   	:= LoadBitmap( GetResources(), "BR_BRANCO" )
	Local oFLabels 	:= TFont():New("Verdana",,018,,.T.,,,,,.F.,.F.)
	Local oFGrpCpo 	:= TFont():New("Verdana",,016,,.F.,,,,,.F.,.F.)

	Private oDlgMain	:= NIL
	

	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	//≥ cOpcList | C = Cria, A = Atualiza ≥
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	If cOpcList == "C"
	
		@ 3, 5 SAY oLblSolicita PROMPT "Contas a Pagar" SIZE 120, 012 OF oPanel FONT oFLabels COLORS RGB(56,141,191), 16777215 PIXEL
		@ 12,0 LISTBOX oLbxCP FIELDS HEADER ;
		" ", "Campos" ;   
		FONT oFList;                                                                                                 
		SIZE (oPanel:nClientWidth/2)-5,(oPanel:nClientHeight/2)-12 OF oPanel PIXEL ON  dblClick()

		oLbxCP:aheaders := aHeader			   
		oLbxCP:BHEADERCLICK	:= { |oObj,nCol| OrdMv( oObj,nCol, .T.) }	
		
		//oLbxCP:bLDblClick := { |nRow,nCol,nFlags| EditLBoxCBox(@oLbxCP) }	
		oLbxCP:bLDblClick := { |nRow,nCol,nFlags| dbClickMv(@nRow,@nCol,@nFlags) }
					
	EndIf
	
	If Empty(aDados)
		aDados	:= {{}}
		aAdd(aDados[1], .F.)
		aAdd(aDados[1], 0)
		
		For nI := 3 To Len(aCpoCP)
		
			If Empty(RetTitle(aCpoCP[nI]))
				xVlrAux	:= 0
			Else
				xVlrAux	:= CRIAVAR(aCpoCP[nI],.F.)
			EndIf
			aAdd(aDados[1], xVlrAux)
		Next nI
	EndIf   
		
	oLbxCP:nAt	:= 1
	
	

	/*
	@  250, 40 		SAY oLblSolicita PROMPT "Total " 		SIZE 50, 014 OF oDlgMain FONT oFGrpCpo COLORS 128, 16777215 PIXEL
	oTotalP := TGet():Create( oDlgMain,{|| CalcTot("TP", @aDadoMain)},250, 40	, 050,009,D_PICTURE_VLRT,,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,cTotalP,,,, )
	*/
	oLbxCP:SetArray( aDados )  
	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	//≥ Cria string com Bloco de Codigo ≥
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
	//cBCodLin	:= "Iif(aDados[oLbxCP:nAt,1],oOk,oNo)" //", Iif(aDados[oLbxCP:nAt,2]==2,oVerde,Iif(aDados[oLbxCP:nAt,2]==1,oAmarelo ,oCinza))"
	cBCodLin	:= "Iif(aDados[oLbxCP:nAt,1],oOk,oNo), Iif(aDados[oLbxCP:nAt,2]==2,oVerde,Iif(aDados[oLbxCP:nAt,2]==3,oAzul, Iif(aDados[oLbxCP:nAt,2]==1,oAmarelo , Iif(aDados[oLbxCP:nAt,2]==4, oBranco, oCinza))))"		
	

	For nI := 3 To Len(aHeader)
		If nI > 1
			cBCodLin	+=", "
		EndIf
		cI	:= AllTrim(str(nI))
		
		If AllTrim(aCpoHeader[nI]) $ "E2_VALOR/E2_SALDO/AJUSTE"
			cBCodLin	+= "Transform(aDados[oLbxCP:nAt,"+cI+"], '"+D_PICTURE_VLR+"')"
		Else
			cBCodLin	+= "aDados[oLbxCP:nAt,"+cI+"]"		
		EndIf
		
	Next nI	

	cBCodLin	:= "oLbxCP:bLine := {|| {"+cBCodLin+"}}"
	&(cBCodLin)            

	
	oLbxCP:Refresh()
	
	
	nSaldoCP	:= SaldoCP()	

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
//Local cAbatim	:= AllTrim(MVABATIM) + "|" + AllTrim(MVRECANT) + "|" + AllTrim(MV_CRNEG)
Local nCpoQry		:= 0
Local nY, nI
Local cQuery		:= "" 
Local cCpoTitle	:= ""

cQuery := " SELECT 	E2_FILIAL, "																									+	CRLF
cQuery += " 			E2_VENCTO, "																									+	CRLF
cQuery += " 			E2_VALOR, "																										+	CRLF
cQuery += " 			A2_CGC, "																										+	CRLF
cQuery += " 			A2_NOME, "																										+	CRLF
cQuery += " 			E2_FORNECE, "																									+	CRLF
cQuery += " 			E2_LOJA, "																										+	CRLF
cQuery += " 			E2_NUM, "																										+	CRLF
cQuery += " 			E2_PREFIXO, "																									+	CRLF
cQuery += " 			E2_NUM, "																										+	CRLF
cQuery += " 			E2_PARCELA, "																									+	CRLF
cQuery += " 			E2_TIPO, "																										+	CRLF
//cQuery += " 			E1_NATUREZ, "																									+	CRLF
//cQuery += " 			E1_CCUSTO, "																									+	CRLF
cQuery += " 			E2_CODBAR, "																									+	CRLF
cQuery += " 			E2_EMISSAO, "																									+	CRLF
cQuery += " 			E2_SALDO, "																										+	CRLF
cQuery += " 			0 AS AJUSTE, "																									+	CRLF
cQuery += " 			SE2.R_E_C_N_O_ AS SE2_RECNO "																				+	CRLF
cQuery += " FROM 		" + RetSqlName("SE2") + " SE2 "																			+	CRLF
cQuery += " INNER 	JOIN " + RetSqlName("SA2") + " SA2 "																	+	CRLF
cQuery += " 			ON	A2_COD 					= E2_FORNECE "																	+	CRLF
cQuery += " 				AND A2_LOJA 			= E2_LOJA "																		+	CRLF
cQuery += " 				AND A2_TIPO 			= 'J' "																			+	CRLF
cQuery += " 				AND SA2.D_E_L_E_T_ 	= '' "																			+	CRLF
cQuery += " WHERE 	E2_FILIAL 			BETWEEN '" + c1FilDe + "'	AND '" + c1FilAte+"' "							+	CRLF
cQuery += " 			AND E2_FORNECE		BETWEEN '" + cForDe + "'	AND '" + cForAte+"' "							+	CRLF
cQuery += " 			AND E2_LOJA 		BETWEEN '" + cLojaDe + "'	AND '" + cLojaAte+"' "							+	CRLF
//cQuery += " 			AND E2_TIPO = 'NF'  "																						+	CRLF
cQuery += " 			AND E2_TIPO 		IN ( 'DP','BOL','NF','FAT','FT','TX' ) "										+	CRLF
cQuery += " 			AND E2_EMISSAO 	BETWEEN '" + DTOS( c1DtDe ) + "'		AND '" + DTOS(c1DtAte) + "' "		+	CRLF
cQuery += " 			AND E2_VENCTO 		BETWEEN '" + DTOS( c1DtVDe ) + "' 	AND '" + DTOS(c1DtVAte) + "' "	+	CRLF
cQuery += " 			AND SE2.E2_NUMBOR	= '' "																					+	CRLF
cQuery += " 			AND SE2.E2_SALDO 	> 0 "																						+	CRLF
If n1StTit == 1	
	cQuery += " 		AND E2_CODBAR = '' " 																						+	CRLF
ElseIf n1StTit == 2
	cQuery += " 		AND E2_CODBAR <> '' "																						+	CRLF
EndIf
cQuery += " 			AND SE2.D_E_L_E_T_ <> '*' "																				+	CRLF

If !(ISBLIND())
	MemoWrite( GetTempPath(.T.) + "AFIN001_qMovimen.SQL", cQuery)
EndIf	

If Select( "TQRY" ) > 0
	TQRY->( DbCloseArea() )
EndIf


DbUseArea( .T., "TOPCONN", TCGenQry( , , cQuery ), 'TQRY' )

TCSetField( "TQRY", "E2_EMISSAO", "D", 08, 00 )
TCSetField( "TQRY", "E2_VENCTO", "D", 08, 00 )

nCpoQry	:= TQRY->( FCOUNT() ) 

//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Monta aHeader ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ 
aAdd( aHeader, "" )
aAdd( aHeader, "" )                      
aAdd( aCpoHeader, "MARK" )
aAdd( aCpoHeader, "LEGENDA" )
//aAdd(aCpoHeader,"")
For nY := 1 To nCpoQry - 1   

		cCpoTitle	:= AllTrim( RetTitle( FieldName(nY) ) )
		If Empty( cCpoTitle )
			cCpoTitle	:= FieldName(nY)
		EndIf
		aAdd( aHeader, cCpoTitle )	
		aAdd( aCpoHeader, FieldName(nY) )
	//EndIf 
Next nY	
aAdd( aCpoHeader, "SE2_RECNO" )
aAdd( aCpoHeader, "SE2FIG")
aAdd( aCpoHeader, "MVCONCI")


//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Variaveis de posionamento dos campos ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
nE2FILIAL	:= Ascan( aCpoHeader,"E2_FILIAL" )
nE2EMISSAO	:= Ascan( aCpoHeader,"E2_EMISSAO" )
nE2VENCTO	:= Ascan( aCpoHeader,"E2_VENCTO" )
nE2SALDO		:= Ascan( aCpoHeader,"E2_SALDO" )
nE2VALOR		:= Ascan( aCpoHeader,"E2_VALOR" )
nSE2RECNO	:= Ascan( aCpoHeader,"SE2_RECNO" )
nAJUSTE		:= Ascan( aCpoHeader,"AJUSTE" )
nE2FORNECE	:= Ascan( aCpoHeader,"E2_FORNECE" )
nE2LOJA		:= Ascan( aCpoHeader,"E2_LOJA" )
nE2CODBAR	:= Ascan( aCpoHeader,"E2_CODBAR" )
nA2CGC		:= Ascan( aCpoHeader,"A2_CGC" )
nSE2FIG		:= Ascan( aCpoHeader,"SE2FIG" )
nCPCONCI		:= Ascan( aCpoHeader,"MVCONCI" )
//incluÌda linha abaixo [Mauro Nagata, www.compila.com.br, 20200925]
nE2TITULO	:= Ascan( aCpoHeader,"E2_NUM" )


//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
//≥ Monta aDados ≥
//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ 
If TQRY->(!Eof())

	Do While TQRY->(!Eof())
	
		aLinha	:= {}
		aAdd(aLinha, .F.)
		//aAdd(aLinha, 0) //| LEGENDA|
				
		If !Empty(TQRY->(FIELDGET(FIELDPOS("E2_CODBAR"))))
			aAdd(aLinha, D_CODBAR) //| LEGENDA|
		Else
			aAdd(aLinha, 0) //| LEGENDA|
		EndIf
		
		
		For nY := 1 To nCpoQry
			aAdd(aLinha, TQRY->(FIELDGET(nY)))
		Next nY	 
		
		/*------------------------------------------------------ Augusto Ribeiro | 27/12/2016 - 11:19:35 AM
			Ultimo registro indica o RECNO do extrato 
			no qual esta vinculado
		------------------------------------------------------------------------------------------*/
		aAdd(aLinha, 0) // SE2FIG
		aAdd(aLinha, 0) //| MVCONCI |
		
		aAdd(aDados, aLinha)
	

		TQRY->(DbSkip())
	EndDo   

	//nSE2FIG 	:= Len(aDados[1])
	//nSE2RECNO	:= nSE2FIG-1
	
	aRet[1]	:= .T.
	aRet[2]	:= aCpoHeader
	aRet[3]	:= aHeader
	aRet[4]	:= aDados

Else
 	aRet[1]	:= .F.
EndIf                  

nSaldoCP	:= SaldoCP()
	
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
		If nCol == 1
		
			If  nConcTaxa == OPCAO_GERA_CNAB //| tAXA|
				lAllExt	:= !(lAllExt)
				
				For nI :=  1 To Len(oLbxAux:aArray)
					If oLbxAux:aArray[nI,2] == D_CODBAR
						If lAllExt <> oLbxAux:aArray[nI,1]
							oLbxAux:nAt	:= nI
							SelCP(@oLbxAux)
						EndIf
					EndIf
				Next nY
	
				//aEval(oLbxAux:aArray, {|x| x[1] := lAllExt} )
				nAntExt := nCol
				oLbxAux:Refresh()
			Else 
				//FwHelpShow("AFIN001","AFIN001","Selecionar todos somente disponivel quando opcao GERA CNAB selecionada")
				//substituÌda linha acima pela abaixo [Mauro Nagata, www.compila.com.br, 20200925]
				FwHelpShow("AFIN001","AFIN001","Para selecionar TODOS somente est· disponÌvel, quando opÁ„o GERA CNAB est· selecionada")
			EndIf		
			
		ElseIf nCol == nAntMv
			aSort(oLbxAux:aArray,,,{ |x,y| x[nCol] < y[nCol] })
			nAntMv := 0
		Else
			aSort(oLbxAux:aArray,,,{ |x,y| x[nCol] > y[nCol] })
			nAntMv := nCol
		EndIf

		oLbxAux:Refresh()

	EndIf

Return()


/*/{Protheus.doc} SelDDA
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
Static Function SelDDA( oLbxAux )
Local nPosAux, nI
Local nMarkAnt	:= 0
Local cRAFil, cRACodCli, cRALoja, cRABanco, cRAAg, cRAConta, nPosCP

If !( lVazioEx )
	/*-----------------------------
		CONCILIACAO DE MOVIMENTOS
	------------------------------*/
	If nConcTaxa == OPCAO_CONCILIA_DDA 
	
		If aDadosDDA[ oLbxAux:nAt, 2 ] <> D_CODBAR
					
			/*--------------------------
				REMOVENDO SELECAO
			---------------------------*/
			If aDadosDDA[ oLbxAux:nAt, 1 ]
			
				nPosCP := aScan( aDadosCP, { |x| x[2] ==  D_SELECIONADO } )
			
			
				/*------------------------------------------------------ Augusto Ribeiro | 01/05/2018 - 11:10:39 AM
					Caso exista alguma registro selecionado nos movimentos DDA 
					Desmarca registro antes de desmarcar Mov.
				------------------------------------------------------------------------------------------*/
				If nPosCP > 0
					oLbxCP:nAt	:= nPosCP							
					SelCP(@oLbxCP) //| Seleciona Item|
					ListTot()
					oLbxCP:Refresh()			
				EndIf			
				
				If aDadosDDA[oLbxAux:nAt,2] == D_CONCILIADO //.OR.  aDadosDDA[oLbxAux:nAt,2] == D_CONCILIADO_AUTO
					nMarkAnt	:= aDadosDDA[oLbxAux:nAt,nDDACONCI]
				EndIf
			 	aDadosDDA[oLbxAux:nAt,1] 				:= .F.
			 	aDadosDDA[oLbxAux:nAt,2] 				:= D_NAOSELECIONADO
			 	aDadosDDA[oLbxAux:nAt,nDDACONCI] 	:= 0
			 	nTotDDACon 									:= nTotDDACon - aDadosDDA[oLbxAux:nAt,nFIGVALOR]
			 	
			 	
			 	If !Empty(nMarkAnt)
			 		DesmConc(nMarkAnt)
			 	EndIf
			 	
			Else
			
				nPosAux := aScan(aDadosDDA, { |x| x[2] ==  D_SELECIONADO})

				If nPosAux == 0 
					
					nPosAux := aScan(aDadosCP, { |x| x[2] ==  D_SELECIONADO})
				

					/*---------------------------------------------
						Valida se registro pode ser selecionado
					----------------------------------------------*/
					aRetAux	:= vldTol(oLbxAux:nAt, nPosAux)
					If aRetAux[1]
				
					
						/*
						If ((nTotDDACon > 0 .OR. nTotCPCon > 0) .And. aDadosDDA[oLbxAux:nAt,nZCAVBRUTO] > 0 ) .OR.;
							((nTotDDACon < 0 .OR. nTotCPCon < 0) .And. aDadosDDA[oLbxAux:nAt,nZCAVBRUTO] < 0 ) .OR.;
							nTotDDACon == 0 .And. nTotCPCon == 0
						*/
							/*--------------------------
								SELECIONANDO
							---------------------------*/		
							aDadosDDA[oLbxAux:nAt,1] 				:= .T.
							aDadosDDA[oLbxAux:nAt,2] 				:= D_SELECIONADO
							aDadosDDA[oLbxAux:nAt,nDDACONCI] 	:= nMarkConc
							nTotDDACon 									:= nTotDDACon + aDadosDDA[oLbxAux:nAt,nFIGVALOR]
							
						//EndIf
					Else 
						FwHelpShow("AFIN001","AFIN001",aRetAux[2])					
					EndIf
				Else
					FwHelpShow("ONLYONE","ONLYONE","Somente um registro de Movimento da Adquirente pode ser selecionado por vez.")
				EndIf
			
			EndIf
			
			/*--------------------------
				Conferencia dos valores selecionados
				e alteracao do status
			---------------------------*/
			ConfVlr()
		Else
			FwHelpShow("AFIN001","Seleciona DDA","Movimento n„o pode ser selecionado pois j· possui codigo de barras. " )		
		EndIf
	
	
	/*-----------------------------
		IDENTIFICA«√O DE TAXAS
	------------------------------*/	
	Else
		FwHelpShow("AFIN001","Seleciona DDA","Somentes Titulos 'Contas a Pagar' podem ser selecionados quando a opcao 'Gera Cnab Pagar' esta selecionada." )	
	EndIf
EndIf


oLbxCP:Refresh()

Return()

/*/{Protheus.doc} SelCP
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
Static Function SelCP(oLbxAux, lForceMark)
Local nI, nVlrMov, nDif, nPosAux
Local nPosAux, nPosEx, lSelAux, cMsgErro, nDif
Local nMarkAnt	:= 0
Local nVlrTol	:= SuperGetMV("AL_TOLDDA", .f., 1)
Local aRetAux, nPosAux

Default lForceMark	:= .f.

nPosEx := aScan(aDadosDDA, { |x| x[2] ==  D_SELECIONADO})

/*-----------------------------
	CONCILIACAO DE MOVIMENTOS
------------------------------*/
If nConcTaxa == OPCAO_CONCILIA_DDA 
	
	If aDadosCP[oLbxAux:nAt,2] <> D_CODBAR	
		
		/*--------------------------
			REMOVENDO SELECAO
		---------------------------*/	
		If aDadosCP[oLbxAux:nAt,1]
		
			/*------------------------------------------------------ Augusto Ribeiro | 01/05/2018 - 11:10:39 AM
				Caso exista alguma registro selecionado nos movimentos DDA 
				Desmarca registro antes de desmarcar Mov.
			------------------------------------------------------------------------------------------*/
			If nPosEx > 0
				oLbxDDA:nAt	:= nPosEx							
				SelDDA(@oLbxDDA) //| Seleciona Item|
				ListTot()
				oLbxDDA:Refresh()			
			EndIf

			
			If aDadosCP[oLbxAux:nAt,2] == D_CONCILIADO //.OR.  aDadosCP[oLbxAux:nAt,2] == D_CONCILIADO_AUTO
				nMarkAnt	:= aDadosCP[oLbxAux:nAt,nCPCONCI]
			EndIf		
			aDadosCP[oLbxAux:nAt,1] 			:= .F.
			aDadosCP[oLbxAux:nAt,2] 			:= D_NAOSELECIONADO
			aDadosCP[oLbxAux:nAt,nCPCONCI] 	:= 0
			aDadosCP[oLbxAux:nAt,nAJUSTE] 	:= 0
			nTotCPCon 								:= nTotCPCon - aDadosCP[oLbxAux:nAt,nE2SALDO]
			
		 	If !Empty(nMarkAnt)
		 		DesmConc(nMarkAnt)
		 	EndIf
		
		//ElseIf nPosEx <= 0
			//Help(" ",1,"SELECAO",,"Primeiro selecione um movimento DDA para ent„o selecionar o titulo do Contas a Pagar.",4,5)
		Else
		

			/*---------------------------------------------
				Valida se registro pode ser selecionado
			----------------------------------------------*/
			aRetAux	:= vldTol(nPosEx, oLbxAux:nAt)
			If aRetAux[1]
				
				/*--------------------------
					SELECIONANDO
				---------------------------*/		
				aDadosCP[oLbxAux:nAt,1] 			:= .T.
				aDadosCP[oLbxAux:nAt,2] 			:= D_SELECIONADO
				aDadosCP[oLbxAux:nAt,nCPCONCI] 	:= nMarkConc
				nTotCPCon 								:= nTotCPCon + aDadosCP[oLbxAux:nAt,nE2SALDO]
			Else
				Help(" ",1,"SELECAO",,aRetAux[2],4,5)
			EndIf
				
		EndIf
			
		/*--------------------------
			Conferencia dos valores selecionados
			e alteracao do status
		---------------------------*/
		ConfVlr()
	Else 
		Help(" ",1,"SELECAO",,"Registro n„o pode ser selecionado pois j· possui codigo de barras vinculado. Verifique se a opÁ„o Gera CNAB Pagar esta selecionada.",4,5)
	EndIf
	
	
/*-----------------------------
	IDENTIFICA«√O DE TAXAS
------------------------------*/	
ElseIf nConcTaxa == OPCAO_GERA_CNAB


	If aDadosCP[oLbxAux:nAt,2] == D_CODBAR
		
		aDadosCP[oLbxAux:nAt,1]	:= !(aDadosCP[oLbxAux:nAt,1]) 
		
		/*
		If aDadosCP[oLbxAux:nAt,1] 
			nPosAux	:=  aScan(aDadosDDA, { |x| x[nFIGRECNO] ==  aDadosCP[oLbxAux:nAt, nSE2FIG]})
			
			
			If nPosAux > 0
			 	Help(" ",1,"SELECAO",,"Este registro n„o pode ser desmarcado pois esta vinculado a um registro de taxa da Adquirente. Desmarque o item do 'Movimmento Adquirente' antes de continuar",4,5)
			 	oLbxDDA:nAt	:= nPosAux
			EndIf
		Else
			nPosEx := aScan(aDadosDDA, { |x| x[2] ==  D_SELECIONADO})
			If !Empty(nPosEx) .or. lForceMark
				aDadosCP[oLbxAux:nAt,1] 		:= .T.
				aDadosCP[oLbxAux:nAt,nSE2FIG]	:=  aDadosDDA[oLbxDDA:nAt,nFIGRECNO]	
			Else
			 	Help(" ",1,"SELECAO",,"Este registro n„o pode ser desmarcado pois esta vinculado a um registro de taxa da Adquirente. Desmarque o item do 'Movimmento Adquirente' antes de continuar",4,5)
			 	If nPosEx > 0
			 		oLbxDDA:nAt	:= nPosEx
			 	EndIf		
			EndIf	
		EndIf
		*/
	Else 
		Help(" ",1,"SELECAO",,"Registro n„o pode ser selecionado pois N√O possui codigo de barras vinculado. Verifique se a opÁ„o Gera CNAB Pagar esta selecionada.",4,5)
	EndIf

EndIf

oLbxDDA:Refresh()

oView	:= FWViewActive()

oView:Refresh()

Return()





/*/{Protheus.doc} AFIN01BTN
Chamada de botoes da enchoice bar
@author Augusto Ribeiro | www.compila.com.br
@since 29/12/2016
@version 1.0
@param cBtn, C, Botao pressionado
@param oView, O, Objeto da View [Default: FWViewActive()]
@return ${return}, ${return_description}
/*/
User Function AFIN01BTN(cBtn, oView)
Local oView, nTotLen
Local oModFull
Local cPathDest, cPathArq


If ValType(oView) <> "O"
	oView	:= FWViewActive()
EndIf

//| Visualizacao do arquivo onde o cursor esta posicionado
If cBtn == "PERG_CONC"
	
	Pergunte(D_PERG2,.T.)
	cGrvCNAB		:= AllTrim(MV_PAR01)

ElseIf cBtn == "PERG_FILTRO"

	If Pergunte(D_PERG,.T.)	
	
		cFilDe		:= MV_PAR01
		cFilAte		:= MV_PAR02
		cForDe		:= MV_PAR03
		cForAte		:= MV_PAR04	
		cLojaDe		:= MV_PAR05
		cLojaAte		:= MV_PAR06	
		//cConsVenc	:= MV_PAR07
		dVencDe		:= MV_PAR07
		dVencAte		:= MV_PAR08
		dProcDe		:= MV_PAR09
		dProcAte		:= MV_PAR10
	
		If  Pergunte(D_PERGB ,.T.)
		
			c1FilDe		:= MV_PAR01
			c1FilAte		:= MV_PAR02
			c1DtVDe		:= MV_PAR03	
			c1DtVAte		:= MV_PAR04		
			c1DtDe		:= MV_PAR05	
			c1DtAte		:= MV_PAR06		
			n1StTit		:= MV_PAR07			
			//c1Forma	:= MV_PAR07
			//c1CodCli	:= MV_PAR08
			//c1Loja		:= MV_PAR09

		EndIf
		
		fAtualiza()
	EndIf
	
ElseIf cBtn== "CONC_AUTO"

	/*------------------------------------------------------ Augusto Ribeiro | 29/12/2016 - 3:52:43 PM
		Realiza a conciliaÁ„o autom·tica dos itens listados
	------------------------------------------------------------------------------------------*/
	Processa({|| ConcAuto() }, "ConciliaÁ„o Autom·tica... ")
	
	
ElseIf cBtn== "EFETIVA"

	If AVISO(	"Efetiva conciliaÁ„o/gera Cnab", "Ser„o efetivadostodos os movimentos selecionados. "	+	CRLF +;
					"Pasta onde sera grava o arquivo CNAB de pgto."														+	CRLF +;
					cGrvCNAB																									+CRLF	+	CRLF +;
					"Deseja continuar ?", { "Sim", "N„o" }, 2 ) == 1
	
		Processa( { || fEfetiva() }, "Conciliando/Gerando Cnab... " )
	EndIf
	
ElseIf cBtn == "TITULO" .OR. cBtn == "TITULO_ALTERA"
	
	VisulTit( iif( cBtn == "TITULO_ALTERA", 4, 2 ) )
	
EndIf 

Return(.T.)







/*/{Protheus.doc} ListTot
Atualiza Totalizadores da Interface
@author Jonatas Oliveira | www.compila.com.br
@since 31/03/2016
@version 1.0
/*/
Static Function ListTot(oPanelr)
Local cBCodLin		:= ""   
Local oOk 	     	:= LoadBitmap( GetResources(), "LBOK" )
Local oNo   	  	:= LoadBitmap( GetResources(), "LBNO" )
Local oFLabels 	:= TFont():New("MS Sans Serif",,022,,.F.,,,,,.F.,.F.)
Local aVlrCor		:= {} 
Local oFGrpCpo 	:= TFont():New("Verdana",,016,,.F.,,,,,.F.,.F.)
Local nI				:= 1

Private oDlgMTot	:= NIL
Private cTotalS	:= ""
Private cTotalA	:= ""
Private cTotalB	:= ""
Private cTotalC	:= ""
Private cTotalD	:= ""
Private cTotalE	:= ""
Private nTotalA	:= 0

If !Empty(oPanelr)

	oPaneRod	:= @oPanelr
	nPosCentro	:= (oPanelr:nClientWidth/4)
	nPosFim		:= (oPanelr:nClientWidth/2)
	
	//@  200, 200		SAY oLblSolicita PROMPT "Acrescimo: "				SIZE 50, 024 OF oPanelr FONT oFGrpCpo COLORS 128, 16777215 PIXEL	
	
	//@  230, 120 		SAY oLblSolicita PROMPT "" 							SIZE 50, 024 OF oPanelr FONT oFGrpCpo COLORS 128, 16777215 PIXEL
	//oTotAcres := TGet():Create( oPanelr,{|| 1},230, 200	, 050,009,D_PICTURE_VLR,,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,cTotalS,,,, )
	
	@  7, 5	SAY oLblSolicita PROMPT "Mov. Adquirentes"					SIZE 70, 024 OF oPanelr FONT oFGrpCpo COLORS 128, 16777215 PIXEL
	oTotMA	:= TGet():Create( oPanelr,{|| CalcTot("ADQUIRENTE") },5, 070	, 050,009,D_PICTURE_VLRT,,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,cTotalA,,,, )

	@ 20, 5	SAY oLblSolicita PROMPT "Selecionado"							SIZE 50, 024 OF oPanelr FONT oFGrpCpo COLORS 128, 16777215 PIXEL
	oSelDDA 	:= TGet():Create( oPanelr,{|| CalcTot("SELECIONADO_DDA") },19, 070	, 050,009,D_PICTURE_VLRT,,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,cSelDDA,,,, )
		
		
	//@  7, 100 		SAY oLblSolicita PROMPT "Vencidos" 					SIZE 50, 024 OF oPanelr FONT oFGrpCpo COLORS 128, 16777215 PIXEL
	//oTotVenc := TGet():Create( oPanelr,{|| 3},5, 130	, 050,009,D_PICTURE_VLR,,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,cTotalS,,,, )
	
	@  7, nPosCentro-60 		SAY oLblSolicita PROMPT "Conciliado" 		SIZE 50, 024 OF oPanelr FONT oFGrpCpo COLORS 128, 16777215 PIXEL
	oTotCon:= TGet():Create( oPanelr,{|| CalcTot("CONCILIADO")},5, nPosCentro-10	, 050,009,D_PICTURE_VLRT,,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,cTotalC,,,, )

	//@  20, nPosCentro-60 		SAY oLblSolicita PROMPT "Mov.Bancario" SIZE 50, 024 OF oPanelr FONT oFGrpCpo COLORS 128, 16777215 PIXEL
	//oTotTaxa:= TGet():Create( oPanelr,{|| CalcTot("TAXA")},17, nPosCentro-10	, 050,009,D_PICTURE_VLRT,,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,cTotalD,,,, )	
		
		
	//oCheck1 := TCheckBox():New(07,nPosCentro+50,'CheckBox 001',{|| SelChek("CONCILIA")},oPanelr,100,210,,,,,,,,.T.,,,)
   		
   	//oCheck1 := TCheckBox():New(07,nPosCentro+50,'CheckBox 001',{|| lSelConc},oPanelr,100,210,,,,,,,,.T.,,,)
   	//oCheck2 := TCheckBox():New(18,nPosCentro+50,'CheckBox 002',{|| lSelTaxa},oPanelr,100,210,,,,,,,,.T.,,,)
   	
   	
   	aRadio := {'Concilia','Gera Cnab Pagar'}
  // 	oRadio := TRadMenu():Create (oPanelr,,07,nPosCentro+50,aItens,,,,,,,,100,12,,,,.T.)
  //	oRadio := TRadMenu():New (07,nPosCentro+50,aItens,,oPanelr,,,,,,,,100,12,,,,.T.)
  	oRadio:= tRadMenu():New(7,nPosCentro+50,aRadio,{|u|if(PCount()>0,nConcTaxa:=u,nConcTaxa)},oPanelr,,,,,,,,140,8,,,,.T.)  
   	//oRadio:bSetGet := {|u|Iif(PCount()==0,nRadio,nRadio:=u)}
				
		
	//@ 7,010 Radio _oResp Var _xResp 3D Size _nLrg,_nAlt Prompt "Sim","N„o" Of _oDlgResp Pixel		
		
		
	@  7, nPosFim-130  SAY oLblSolicita PROMPT "Contas a Receber"	SIZE 70, 190 OF oPanelr FONT oFGrpCpo COLORS 128, 16777215 PIXEL
	oTotCR := TGet():Create( oPanelr,{|| CalcTot("CONTAS_RECEBER")},5, nPosFim-60	, 050,009,D_PICTURE_VLRT,,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,cTotalMv,,,, )

	@ 20, nPosFim-130 SAY oLblSolicita PROMPT "Selecionado"			SIZE 50, 190 OF oPanelr FONT oFGrpCpo COLORS 128, 16777215 PIXEL
	oSelCP := TGet():Create( oPanelr,{|| CalcTot("SELECIONADO_CP")},19, nPosFim-60	, 050,009,D_PICTURE_VLRT,,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,cSelCP,,,, )
	
	
	/*
	@ 20, 120			SAY oLblSolicita PROMPT "Acrescimo: "			SIZE 50, 024 OF oPanelr FONT oFGrpCpo COLORS 128, 16777215 PIXEL		
	oTotalP := TGet():Create( oPanelr,{|| CalcTot("ACRESS", @aDadoTit)},20, 120	, 050,009,D_PICTURE_VLRT,,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,cTotalS,,,, )
	*/
	//oPanelr:nClientWidth -5  //(oPanelr:nClientHeight/2)-12	
	
Else

	cTotalA	:= CalcTot(	"ADQUIRENTE"	)
	cSelDDA	:= CalcTot(	"SELECIONADO_DDA"	)
	cTotalC	:= CalcTot(	"CONCILIADO"	)
	cTotalD	:= CalcTot(	"TAXA"	)
	cTotalMv	:= CalcTot(	"CONTAS_RECEBER"	)
	cSelCP	:= CalcTot(	"SELECIONADO_CP"	)


	/*--------------------------
		Atualiza total conciliado
	
	nTotConc	:= 0
	For nI := 1 To Len(aDadosDDA)
		If aDadosDDA[nI,2] == D_CONCILIADO
			nTotConc += aDadosDDA[nI, nZB2VALOR]
		EndIf
	Next nI
	If !Empty(oTotCon)
		oTotCon:cText := nTotConc
		oTotCon:Refresh()
		oPaneRod:Refresh()
		
		oView	:= FWViewActive()
		oView	:= oView
	EndIf
	---------------------------*/


	//oTotalP:cText	:= '10'
	
EndIf
		
oTotMA:CtrlRefresh()
oTotCon:CtrlRefresh()
//oTotTaxa:CtrlRefresh()
oTotCR:CtrlRefresh()
oSelDDA:CtrlRefresh()
oSelCP:CtrlRefresh()
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
If cOpc == "CONCILIADO"
	
	
	
	For nI := 1 To Len(aDadosDDA)
		If aDadosDDA[nI,2] == D_CONCILIADO
			nRet += aDadosDDA[nI, nFIGVALOR]
		EndIf
	Next nI
	
ElseIf cOpc == "ADQUIRENTE"//"EXTRATO"
	
	nRet	:= nSaldoDDA//| Saldo do EXTRATO|7
	/*
	For nI := 1 To Len(aDadosDDA)
		If aDadosDDA[nI,2] == D_CONCILIADO .OR. aDadosDDA[nI,2] == D_CODBAR
			nRet += aDadosDDA[nI, nZB2VALOR]
		EndIf
	Next nI	
	*/
	
ElseIf cOpc == "CONTAS_RECEBER"//"MOVIMENTO"

	nRet	:= nSaldoCP //| Saldo do movimento|
	/*
	For nI := 1 To Len(aDadosCP)
		If aDadosCP[nI, 1]
			nRet += aDadosCP[nI, nE2SALDO]
		EndIf
	Next nI	
	*/
ElseIf cOpc == "TAXA"
	For nI := 1 To Len(aDadosDDA)
		If aDadosDDA[nI,2] == D_CODBAR
			nRet += aDadosDDA[nI, nFIGVALOR]
		EndIf
	Next nI
	
ElseIf cOpc == "SELECIONADO_DDA"//"SELECIONADO_EX"
	For nI := 1 To Len(aDadosDDA)
		If aDadosDDA[nI,1]
			nRet += aDadosDDA[nI, nFIGVALOR]
		EndIf
	Next nI	
	
ElseIf cOpc == "SELECIONADO_CP"//"SELECIONADO_MV"
	For nI := 1 To Len(aDadosCP)
		If aDadosCP[nI,1]
			nRet += aDadosCP[nI, nE2SALDO]
		EndIf
	Next nI	
			
EndIf

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
Local nRet			:= 0
Local nI				:= 0
Local nMv			:= 0
Local lAuxSel		:= lISelec //| Backup do parametro| 
Local nQtdDDA		:= 0
Local nQtdMv		:= 0
Local nDiasConc	:= 1	//| Quantidade de dias para considerar para conciliaÁ„o autom·tica|
Local nVlrTol		:= SuperGetMV("AL_TOLDDA", .F., 1)

nConcTaxa			:= 1 
lISelec				:= .F.

If !Empty(aDadosDDA) .And. !Empty(aDadosCP)

	nQtdDDA	:= Len( aDadosDDA )
	nQtdMv	:= Len( aDadosCP )

	ProcRegua( nQtdDDA )
	
	
	aSort( aDadosDDA,,,	{ | x, y | x[ nFIGCNPJ ] < y[ nFIGCNPJ ] } )
	aSort( aDadosCP,,,	{ | x, y | x[ nA2CGC ] < y[ nA2CGC ] } )
	
	nPosCP := 1
	For nI := 1 To nQtdDDA
		
		If aDadosDDA[ nI, 2 ] <> D_NAOSELECIONADO
			LOOP
		EndIf
		
		For nMv	:= nPosCP To nQtdMv
			
			If LEFT(aDadosCP[nMv, nA2CGC],8) < LEFT(aDadosDDA[nI, nFIGCNPJ],8)
				nPosCP	:= nMv //| Continua da onde parou |		
				LOOP
			EndIf 
		

			If aDadosCP[ nMv, 2 ] == D_NAOSELECIONADO
				If LEFT( aDadosCP[ nMv, nA2CGC ], 8 ) == LEFT( aDadosDDA[nI, nFIGCNPJ ], 8 )
					If aDadosCP[ nMv, nE2VENCTO ] == aDadosDDA[ nI, nFIGVENCTO ]

						//incluÌda linha abaixo [Mauro Nagata, www.compila.com.br, 20200925]	
						//If aDadosCP[ nMv, nE2TITULO ] == aDadosDDA[ nI, nFIGTITULO ]
						//substituÌda linha acima pelo bloco abaixo [Mauro Nagata, www.compila.com.br, 20200929]
						cSE2Tit 	:= AllTrim( aDadosCP[ nMv, nE2TITULO ] )
						nSE2Tit	:= Val( StrTran( cSE2Tit, " ", "" ) )

						cFIGTit	:= AllTrim( aDadosDDA[ nI, nFIGTITULO ] )
						nFIGTit	:= Val( StrTran( cFIGTit, " ", "" ) )
						
						If nSE2Tit = nFIGTit
						//fim bloco [Mauro Nagata, www.compila.com.br, 20200929]
							nDif	:=  aDadosCP[ nMv, nE2VALOR ] - aDadosDDA[ nI, nFIGVALOR ]
							If nDIf == 0 .OR.;
								( nDIf < 0 .And. nDIf >= ( nVlrTol * -1 ) ) .OR.;
								( nDIf > 0 .And. nDIf <= nVlrTol )
							
								oLbxDDA:nAt	:= nI							
								SelDDA( @oLbxDDA ) //| Seleciona Item|
								ListTot()
								oLbxDDA:Refresh()
								
								oLbxCP:nAt	:= nMv
								dbClickMv( nMv, 1 )
								//SelCP(@oLbxCP) //| Seleciona Item|
								
								Exit					 	
							 EndIf
						 //incluÌda linha abaixo [Mauro Nagata, www.compila.com.br, 20200925]
						 EndIf
					EndIf			
				ElseIf LEFT( aDadosCP[ nMv, nA2CGC ], 8 ) > LEFT( aDadosDDA[ nI, nFIGCNPJ ], 8 ) 
					Exit
				EndIf
			EndIf
		Next nMv
		
	
	Next nI
	
	//| Ordena Listbox pela coluna de status|
	OrdExt(oLbxCP, 2)
	oLbxCP:Refresh()
	
	OrdMv(oLbxDDA, 2)
	oLbxDDA:Refresh()

	/*
	
	aSort(aDadosDDA,,,{ |x,y| x[nZCADTVEND] < y[nZCADTVEND]})
	aSort(aDadosCP,,,{ |x,y| x[nE1EMISSAO] < y[nE1EMISSAO]})
	
	nAuxMv	:= 1
	For nI := 1 To nQtdEx
		IncProc("Conciliando automaticamente..")
		
		If Empty(aDadosDDA[nI, nZCADTVEND])
			LOOP
		EndIf
		
		
		//*------------------------------------------------------ Augusto Ribeiro | 03/04/2018 - 3:09:10 PM
		//	Quantidade de Dias para conciliaÁ„o
		//------------------------------------------------------------------------------------------
		nDiasAux	:= 0
		If nDiasConc > 0
			For nY := 1 To nDiasConc
				nDiasAux	:= nY
				nAuxMv		:= aScan(aDadosCP, { |x| x[nE1EMISSAO] ==  aDadosDDA[nI,nZCADTVEND]+nDiasAux})
			Next nY
		Else
			nAuxMv	:= aScan(aDadosCP, { |x| x[nE1EMISSAO] ==  aDadosDDA[nI,nZCADTVEND]})
		EndIf
		
		
		
		If nAuxMv > 0
			For nMv := nAuxMv To nQtdMv
				
				If !(aDadosCP[nMv, 1])			
					If  aDadosCP[nMv, nE1EMISSAO] == aDadosDDA[nI, nZCADTVEND]+nDiasAux
					
						nDif	:=  aDadosDDA[nI, nFIGVALOR] - aDadosCP[nMv, nE2SALDO] //nVlrExtr - nVlrMov
						
						
						//*------------------------------------------------------ Augusto Ribeiro | 03/04/2018 - 2:57:16 PM
						//	Tolerancia
						// ------------------------------------------------------------------------------------------
						nTolera	:= 0
						If nTolera == 0
							nTolera	:= SUPERGETMV("CP11_BXTOL",.F.,0.05, aDadosCP[nI, nE1FILIAL])
						EndIf						
						
						If nTolera >= nDIf .And. (nTolera*-1) <=  nDif
						
							oLbxDDA:nAt	:= nI							
							SelDDA(@oLbxDDA) //| Seleciona Item|
							ListTot()
							oLbxDDA:Refresh()
							
							oLbxCP:nAt	:= nMv
							dbClickMv(nMv, 1)
							//SelCP(@oLbxCP) //| Seleciona Item|
							
							Exit
						EndIf	
					ElseIf aDadosCP[nMv, nE1EMISSAO] > aDadosDDA[nI, nZCADTVEND]+nDiasAux
						Exit			
					EndIf
				EndIf
				
			Next nMv
		EndIf
		
	
	Next nI
	
	
	*/
EndIf
	

oLbxDDA:nAt	:= 1
oLbxCP:nAt	:= 1

//| Restore do parametro |
lISelec		:= lAuxSel

oLbxDDA:Refresh()
oLbxCP:Refresh()

Return(nRet)




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

Default nRow 	:= 0
Default nCol	:= 0
Default nFlags := 0

//If !(lVazioMv)
If !(Empty(aDadosCP[oLbxCP:nAt, nE2EMISSAO])) //| N„o realiza acao sobre registro vazio|

	/* ### EDI«√O DA LINHA DO LISTBOX 

	If Empty(aDadosCP[oLbxCP:nAt, nSE2RECNO]) .And. (nCol == nE5HISTOR) //.OR. nCol == nE5NATUREZ .OR. nCol == nE5CCUSTO) 
		//If Empty(aDadosCP[oLbxCP:nAt, nSE2RECNO])
			EditHist(@oLbxCP, nCol)
	//	EndIf
	Else
		SelCP(@oLbxCP)
		ListTot()
		oLbxCP:Refresh()
	EndIf
	*/
	
	SelCP(@oLbxCP)
	ListTot()
	oLbxCP:Refresh()	
EndIf
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
DEFINE MSDIALOG oDlg FROM 0,0 To 0,0 STYLE nOR( WS_VISIBLE , WS_POPUP ) PIXEL WINDOW oListBox:oWnd


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
Local aRet			:= { .f., "", "" }
Local aRetArq		:= { .f., "", "" }
Local aRetBor		:= { .f., "", "" }
Local nPosMv, aRetAux
Local nI, nY, dDataAnt
Local nDadosCR		:= Len(aDadosCP)
Local aRecSE5		:= {}
Local lRetConc		:= .f.
Local nQtdeTaxa	:= 0

Local nLoopMA, nTotDDA
Local nLoopCP, nTotCP
Local nLastnY		:= 1	
Local nIdConc		:= 1
Local aRegDDA		:= {}
Local aRegCP		:= {}
Local nRecFIG
Local aRetBco		:= {}
Local aGeraCnab	:= {}
Local aCodFor		:= {}
Local Prossegue, lPAAberto, nPosFor

Private cFile		:= ""
Private cNumBor	:= ""
//Private aNumBorG:= {}
Private aArqGer	:= {}
	
ProcRegua(Len(aDadosDDA))


	aCodFor	:= {}
	For nI := 1 To Len(aDadosCP)

		If aDadosCP[nI, 1] .And. aDadosCP[nI, 2] == D_CODBAR
		
		 	/*------------------------------------------------------ Augusto Ribeiro | 07/05/2018 - 11:32:49 AM
		 		Armazena fornecedores para verificar se possui RA em aberto
		 	------------------------------------------------------------------------------------------*/
		 	lPAAberto	:= .F.
		 	nPosFor	:= aScan(aCodFor, { |x| x[1]+x[2] == aDadosCP[nI, nE2FORNECE]+aDadosCP[nI, nE2LOJA] })
		 	If nPosFor <= 0
		 	
		 		lPAAberto	:= PAAberto(aDadosCP[ nI, nE2FORNECE], aDadosCP[ nI, nE2LOJA])
		 	
		 		aAdd(aCodFor, {aDadosCP[ nI, nE2FORNECE], aDadosCP[ nI, nE2LOJA], lPAAberto})
		 	Else
		 		lPAAberto	:= aCodFor[nPosFor,3]
		 	EndIf
		 	 	
		 	If !(lProcPA) .And. lPAAberto
		 		oLbxCP:nAt	:= nI
		 		//| Desmarca o registro |
		 		SelCP(@oLbxCP) //| Seleciona Item|
		 	Else
		 		aAdd( aGeraCnab, { aDadosCP[ nI, nE2FILIAL] ,aDadosCP[ nI, nSE2RECNO], IIF(LEFT( aDadosCP[ nI, nE2CODBAR],3 ) == "341", "30","31")  } )
		 	EndIf
		EndIf
	Next nI 
		
	lProssegue	:= .T.
	If !Empty(aCodFor)
		oLbxCP:nAt	:= 1
		oLbxCP:Refresh()
		
		If lProcPA
			lProssegue	:= .T.
		Else
			Aviso(	"Pagamento Antecipado"," Alguns fornecedores com Pagamento antecipado em aberto foram autom·ticamente desmarcados."+ CRLF+  ;
						"Necess·rio analisar estes registros antes de seguir.", {"OK"},2) //<> 1
			lProssegue	:= .F.
			lProcPA		:= .T.
			
		EndIf	
	EndIf

	If lProssegue
		lProcPA	:= .F.
	
		/*------------------------------------------------------ Augusto Ribeiro | 25/01/2017 - 6:11:28 PM
		
			CONCILIA«√O
			Concilia movimentos DDA
		
		------------------------------------------------------------------------------------------*/	
		DbSelectArea("FIG")
		DbSelectArea("SE2")
		
		aSort(aDadosDDA,,,{ |x,y| x[nDDACONCI] > y[nDDACONCI] })
		aSort(aDadosCP,,,{ |x,y| x[nCPCONCI] > y[nCPCONCI] })
		
		nLoopMA	:= 1
		nLoopCP	:= 1
		nTotDDA	:= Len(aDadosDDA)
		nTotCP	:= Len(aDadosCP)
		Do While  IIF(nLoopMA <= nTotDDA, aDadosDDA[nLoopMA, nDDACONCI] > 0, .F.) 
			IncProc("Conciliando..")
			aRegDDA	:= {}
			aRegCP	:= {}
			nRecFIG	:= 0
				
			If aDadosDDA[nLoopMA, 2] == D_CONCILIADO
				
				nIdConc	:= aDadosDDA[nLoopMA, nDDACONCI]
				nRecFIG	:= aDadosDDA[nLoopMA, nFIGRECNO]
				/*
				Do While  IIF(nLoopMA <= nTotDDA, aDadosDDA[nLoopMA, nDDACONCI] == nIdConc,.F.) 
					aAdd(aRegDDA, aDadosDDA[nLoopMA, nFIGRECNO])
					nLoopMA++
				EndDo
				*/
				
				//WHILE IIF(nLoopCP <= nTotCP, aDadosCP[nLoopCP, nCPCONCI] == nIdConc, .F.) 
				Do While nLoopCP <= nTotCP 
					If aDadosCP[nLoopCP, nCPCONCI] == nIdConc
						aAdd(aRegCP, {aDadosCP[nLoopCP, nSE2RECNO], aDadosCP[nLoopCP, nAJUSTE]})
					EndIf
					nLoopCP++
					If nLoopCP <= nTotCP 
						If aDadosCP[nLoopCP, nCPCONCI] < nIdConc
							Exit
						EndIf
					EndIf
				EndDo		
				
				/*------------------------------------------------------ Augusto Ribeiro | 25/01/2017 - 6:08:14 PM
					Grava conciliaÁ„o
				------------------------------------------------------------------------------------------*/
				If !Empty(nRecFIG) .And. !Empty(aRegCP)
				
					//| aRegCP | Sempre existira somente 1 registros
					aRetAux	:= U_AFIN01CB(nRecFIG, aRegCP[1,1])
					If !(aRetAux[1])				
					 	aRet[2]	+=  aRetAux[2]
					EndIf
	
				Else 
					If Empty(aRet[2])
						aRet[2] := "Erro indeterminado [AFIN001 fEfetiva()]"
					EndIf
					Exit
				EndIf
			
	
			EndIf
			
			nLoopMA++
		EndDo

	
		/*------------------------------------------------------ Augusto Ribeiro | 24/04/2018 - 11:23:39 AM
			Gera CNAB de Pagamentos 
		------------------------------------------------------------------------------------------*/
		If !Empty(aGeraCnab) 
		
			/*------------------------------------------------------ Augusto Ribeiro | 24/04/2018 - 11:45:30 AM
				Gera Bordero
			------------------------------------------------------------------------------------------*/
			/*
			Aviso("Pasta Arquivo"," Informe a Pasta para salvar o arquivo. "+ CRLF+ ;
					"ObrigatÛrio a seleÁ„o da Pasta para geraÁ„o do BorderÙ", {"Selec Pasta"},3)
				 											
			cFile	 := AllTrim(cGetFile('Pasta','Selecione a pasta',0,,.F.,GETF_LOCALHARD+GETF_RETDIRECTORY,.T.)	)
			*/
			
			cFile	:= AllTrim(cGrvCNAB)
			If !Empty(cFile)
				
				If Right(cFile,1) <> "\"
					cFile	:= cFile+"\"
				EndIf
			
				aRetBor := U_AFIN01GB(aGeraCnab)
				aRet[1] := .T.
				
				/*----------------------------------------
					30/04/2018 - Jonatas Oliveira - Compila
					Gera arquivo SISPAG
				------------------------------------------*/		
				/*If aRetBor[1]
					aRetArq := U_AFIN006(cNumBor, cNumBor, SUPERGETMV("AL_ARQSISP"	,.F.	, "itau.pag"	, CFILANT), cFile + cNumBor + DTOS(DDATABASE) + ".REM")
					aRet[1] := .T.
				EndIf 
				*/
				If !Empty(aArqGer) 
					aRet[3] := "Filial      | BorderÙ | Arquivo" + CRLF
					
					For nI := 1 To Len(aArqGer)
	
						aRet[3] += aArqGer[nI] + CRLF
					Next nI 
				EndIf 
				
			Else
				aRet[2] := "OperaÁ„o cancelada pelo usu·rio."
				//Help(" ",1,"EFETIVA",,"OperaÁ„o cancelada pelo usu·rio.",4,5)
			EndIf 
		EndIf
		
		If lProssegue
			//| Atualiza toda a interface|
			fAtualiza()
		EndIf
	EndIf

If !Empty(aRet[2])  //!aRet[1] //!Empty(aRet[2])
	Help(" ",1,"EFETIVA",,aRet[2],4,5)
Else
	If !Empty(aRet[3])
		AVISO("Processamento concluÌdo.",aRet[3],{"Fechar"} , 3, 	,,	,.T.)
	EndIf
EndIf

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

	U_AFIN01DD("A",@oLbxDDA,@aCpoEx,@aHeadEx, @aDadosDDA)
	//oLbxDDA:nAt	:= 1
	U_AFIN01CP("A",@oLbxCP,@aCpoCP,@aHeadMv, @aDadosCP)
	//oLbxCP:nAt	:= 1

	//nSaldoDDA	:= SaldoDDA(cpBanco, cpAg, cpConta, dpDtTrAte)	
	//nSaldoCP	:= SaldoCP(cpBanco, cpAg, cpConta, dpDtTrAte)
	
/*	
	CalcTot("EXTRATO")	
	oTotMA:CtrlRefresh()
	
	CalcTot("MOVIMENTO")
	oTotCon:CtrlRefresh()
	*/
	ListTot()	
	
	nMarkConc	:= 1 
	nTotDDACon	:= 0
	nTotCPCon	:= 0

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
aAdd(aParams,{1,"Data Transf.",cToD(SPACE(08)),,"","","",90,.F.,})

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
EndIf       

Return()




/*/{Protheus.doc} SaldoCP
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
Static Function SaldoCP()
Local nRet			:= 0
Local cQuery		:= "" 
Local nSaldoAtu	:= 0
Local nSaldoIni	:= 0
	
/*------------------------------------------------------ Augusto Ribeiro | 21/10/2017 - 2:58:12 PM
	Calcula Saldo do SE1
------------------------------------------------------------------------------------------*/
nRet	:= 0
For nI := 1 To Len(aDadosCP)
	nRet	+= aDadosCP[nI,nE2SALDO]
Next nI

Return(nRet)






/*/{Protheus.doc} SaldoDDA
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
Static Function SaldoDDA()
Local nRet			:= 0
Local cQuery		:= "" 
Local nSaldoZB2	:= 0
Local nSaldoIni	:= 0
Local dSaldoIni	:= ctod('  /  /  ')
Local cDigConta	:= ""

	/*------------------------------------------------------ Augusto Ribeiro | 21/10/2017 - 2:58:12 PM
		Calcula Saldo do Movimento da Adquirente
	------------------------------------------------------------------------------------------*/
	If !Empty(aDadosDDA)
		For nI := 1 To Len(aDadosDDA)
			nRet	+= aDadosDDA[nI,nFIGVALOR]
		Next nI
	EndIf
	
Return(nRet)





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
Local nSelDDA	:= 0
Local nSelCP	:= 0
Local nTotDDA	:= 0
Local nTotCP	:= 0
Local nDif
Local aDDAMark	:= {}
Local aCRMark	:= {}
Local nVlrTol	:= SuperGetMV("AL_TOLDDA", .f., 1)
Local nDDAMark	:= 0
Local nCPMark	:= 0

/*------------------------------------------------------ Augusto Ribeiro | 18/04/2018 - 7:57:46 PM
	Verifica Registro do DDA
------------------------------------------------------------------------------------------*/
For nI:= 1 To Len(aDadosDDA)
	If aDadosDDA[nI, 2] == D_SELECIONADO
		nTotDDA	+= aDadosDDA[nI, nFIGVALOR]
		nDDAMark	:= nI
		Exit
	EndIf 	
Next nI

/*------------------------------------------------------ Augusto Ribeiro | 18/04/2018 - 7:59:29 PM
	Verifica registro do Contas a Pagar
------------------------------------------------------------------------------------------*/
For nI:= 1 To Len(aDadosCP)
	If aDadosCP[nI, 2] == D_SELECIONADO
		nTotCP	+= aDadosCP[nI, nE2VALOR]+aDadosCP[nI, nAJUSTE]
		nCPMark	:= nI	
		Exit
	EndIf 	
Next nI

/*------------------------------------------------------ Augusto Ribeiro | 15/11/2017 - 6:45:20 PM
	Caso esteja dentro da tolerancia, permite seleÁ„o e altera  status para CONCILIADO
------------------------------------------------------------------------------------------*/
If nDDAMark > 0 .And. nCPMark > 0
	nDif	:= nTotDDA-nTotCP
	If nDIf == 0 .OR.;
	 	(nDIf < 0 .And. nDIf >= (nVlrTol*-1)) .OR.;
	 	(nDIf > 0 .And. nDIf <= nVlrTol)
	 		
		aDadosDDA[nDDAMark, 2]	:= D_CONCILIADO	
		nSelDDA++	
	
		aDadosCP[nCPMark, 2]	:= D_CONCILIADO
		nSelCP++
	
		/*------------------------------------------------------ Augusto Ribeiro | 15/11/2017 - 7:45:25 PM
			Registra valor de Ajuste
		------------------------------------------------------------------------------------------*/ 
		If nDIf <> 0
			aDadosCP[nCPMark, nAJUSTE]	:= nDif
		EndIf
	 
		nMarkConc++
		
		oLbxDDA:Refresh()
		oLbxCP:Refresh() 
	EndIf
EndIf

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
For nI:= 1 To Len(aDadosDDA)
	If aDadosDDA[nI, nDDACONCI] == nMarkAnt
		
		If aDadosDDA[nI, 2]	== D_CONCILIADO //.OR. aDadosDDA[nI, 2] == D_CONCILIADO_AUTO
			aDadosDDA[nI, 2]				:= D_SELECIONADO
			aDadosDDA[nI, nDDACONCI]	:= nMarkConc
		EndIf		
	EndIf	
	
	/*--------------------------
		Recalcula valor selecionado
	---------------------------*/
	If aDadosDDA[nI, nDDACONCI] == nMarkConc
		nTotAux	+= aDadosDDA[nI, nFIGVALOR]
	EndIf
		
Next nI
nTotDDACon	:= nTotAux


nTotAux	:= 0
For nI:= 1 To Len(aDadosCP)
	If aDadosCP[nI, nCPCONCI] == nMarkAnt
		
		If aDadosCP[nI, 2]	== D_CONCILIADO //.OR. aDadosCP[nI, 2] == D_CONCILIADO_AUTO 
			aDadosCP[nI, 2]			:= D_SELECIONADO
			aDadosCP[nI, nCPCONCI]	:= nMarkConc
		EndIf		
	EndIf	
	
	/*--------------------------
		Recalcula valor selecionado
	---------------------------*/
	If aDadosCP[nI, nCPCONCI] == nMarkConc
		nTotAux	+= aDadosCP[nI, nE2SALDO]
	EndIf
		
Next nI
nTotCPCon	:= nTotAux

oLbxDDA:Refresh()
oLbxCP:Refresh()

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
cQry := " SELECT	E8_FILIAL, E8_BANCO, E8_AGENCIA, E8_CONTA, E8_DTSALAT, E8_SALATUA, E8_SALRECO "
cQry += " FROM 	" + RetSqlName("SE8") + " SE8 " 
cQry += " WHERE 	E8_BANCO 			= '" + cBanco 		+ "' "
cQry += " 			AND E8_AGENCIA 	= '" + cAgencia 	+ "' "
cQry += " 			AND E8_CONTA 		= '" + cConta 		+ "' "
cQry += " 			AND E8_DTSALAT		< '" + DTOS(dDataSaldo) + "' "
cQry += " 			AND D_E_L_E_T_ 	<> '*' "
cQry += " ORDER BY	E8_FILIAL, E8_DTSALAT DESC "

dbUseArea(.T., "TOPCONN", TCGenQry(,,cQry), cSaldo, .T., .T.)

(cSaldo)->(DbGoTop())

cFl 		:= (cSaldo)->E8_FILIAL
nSld		:= (cSaldo)->E8_SALATUA
nSlRec	:= (cSaldo)->E8_SALRECO

Do While !Eof()
	
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
	Local MvParDef		:=	""
	Local l1Elem   	:=	Nil
	Local lTipoRet		:= .T.
	Local cFilBack		:= cFilAnt
	Local nI
	Private _aFilial	:=	{}
	Private aSit		:= {}
	l1Elem 				:= If (l1Elem = Nil , .F. , .T.)

	DEFAULT lTipoRet	:= .T.
	DEFAULT BrowX1 	:= "Selecione " + cTitBrw
	DEFAULT aOpcoes	:= {}

	If Len(aOpcoes) == 0
		Return
	EndIf

	cAlias 			:= Alias() 					 // Salva Alias Anterior

	If lTipoRet
		MvPar := &(AllTrim(ReadVar()))		 // Carrega Nome da Variavel do Get em Questao
		mvRet := AllTrim(ReadVar())			 // Iguala Nome da Variavel ao Nome variavel de Retorno
	EndIf

	For nI := 1 To Len(aOpcoes)

		aAdd(aSit, aOpcoes[nI,1]+" - "+aOpcoes[nI,2])
		MvParDef += aOpcoes[nI,1]
	Next nI



	// Tamanho dos caracters de retorno (Ex.: 04)
	nTam 			:= Len(aOpcoes[1,1])
	lComboBox 	:= .T.
	If lTipoRet
		If f_Opcoes(@MvPar,BrowX1,aSit,MvParDef,12,49,l1Elem,nTam)	// Chama funcao f_Opcoes
			&MvRet := mvpar                                   			// Devolve Resultado
		EndIf
	EndIf

	DbSelectArea(cAlias) 	 // Retorna Alias

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
Local _cRet		:= ""                  
Local _cString, _cCaracX, _nCaracX, nY
Local _aString	:= {}                            

Default	_nCaracX := 0                   
                                                                  
	//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
	//≥Valida Informacoes Basicas ≥
	//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
    If !Empty(_cString) .And. (!Empty(_cCaracX) .OR. _nCaracX > 0)
                                
    	nString	:= Len(_cString)

		//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
		//≥ Utiliza Separacao por Numero de Caracteres ≥
		//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
		If _nCaracX > 0
			For nY := 1 To nString STEP _nCaracX
			
				aAdd(_aString, Substr(_cString,nY, _nCaracX) )
			
			Next nY
			
		//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
		//≥ Utiliza Separacao por caracter especifico ≥
		//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
		Else
			_aString	:= WFTokenChar(_cString, _cCaracX)		
		EndIf
	                


		//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
		//≥ Monta String para utilizar com IN em querys≥
		//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
		_cRet	+=  "('"		
		For _nI := 1 To Len(_aString)
			If _nI > 1
				_cRet	+= ",'"
			EndIf
			_cRet += AllTrim(_aString[_nI])+"'"	
		Next _nI
		_cRet += ") "  
		
	EndIf

Return(_cRet) 











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



aAdd(	aParams, {1, "Filial",	PADR("",TAMSX3("E1_FILIAL")[1]),	,"","SM0","",30,.F.,})
aAdd(	aParams, {1, "Cliente",	PADR("",TAMSX3("A1_COD")[1]),		,"","SA1","",30,.F.,})
aAdd(	aParams, {1, "Loja",		PADR("",TAMSX3("A1_LOJA")[1]),	,"","","",30,.F.,})

If ParamBox(aParams,"Parametros para inclus„o do RA",@aRetPar)

	For nI := 1 To Len(aRetPar)
		If Empty(aRetPar[nI])
			aRet[2]	:= "Todos os parametros s„o de preenchimento obrigatÛrio."
			Exit
		EndIf
	Next nI
Else
	aRet[2]	:= "Todos os parametros s„o de preenchimento obrigatÛrio.."
EndIf

If Empty(aRet[2])
	aRet[1]	:= .t.
	aRet[3]	:= aRetPar
EndIf

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
	
	If aDadosDDA[oLbxDDA:nAt, nFIGRECNO]
	
		DbSelectArea("ZCA")
		ZCA->(DbGoTo(aDadosDDA[oLbxDDA:nAt,nFIGRECNO]))
		
		FWExecView("Visualizar","CP11010", 1,, {|| .T. })
	
	Else
	
		FwHelpShow("NAO LOCALIZ","NAO LOCALIZ","Registro posicionado n„o foi localizado")
		
	EndIf
	
	RestArea(aAreaZCA)
	RestArea(aArea)
	
Return()


/*/{Protheus.doc} VisulTit
Visualiza Titulo Contas ‡ Receber
@author Jonatas Oliveira | www.compila.com.br
@since 20/11/2017
@version 1.0
/*/
Static Function VisulTit(nOpc)

	Local _cCodEmp	:= ""
	Local _cCodFil	:= ""
	Local _cFilNew	:= ""	
	Local aArea		:= GetArea()
	Local aAreaSE2	:= SE2->(GetArea())
	
	PRIVATE aDadosImp := Array(3) 
	
	Default nOpc := 2
	
	
	If aDadosCP[oLbxCP:nAt, nSE2RECNO]
		DbSelectArea("SE2")
		
		SE2->(DbGoTo(aDadosCP[oLbxCP:nAt, nSE2RECNO] )) 
		RegToMemory("SE2", .F., .T.)
		
		_cCodEmp	:= SM0->M0_CODIGO
		_cCodFil	:= SM0->M0_CODFIL
		_cFilNew	:= SE2->E2_FILIAL //| CODIGO DA FILIAL DE DESTINO 
		
		If _cCodEmp+_cCodFil <> _cCodEmp+_cFilNew
			CFILANT := _cFilNew
			opensm0(_cCodEmp+CFILANT)
		EndIf
	
		//MaMakeView( "SE1" )
		//FINA050(NIL,2)
		If nOpc == 2
			FA050Visua("SE2",SE2->(RECNO()),nOpc)
		ElseIf nOpc == 4	
			nModulo := 06 
			FA050Alter("SE2",SE2->(RECNO()),nOpc)
		EndIf
		 
		/*---------------------------------------
			Restaura FILIAL  
		-----------------------------------------*/
		If _cCodEmp+_cCodFil <> _cCodEmp+_cFilNew
			CFILANT := _cCodFil
			opensm0(_cCodEmp+CFILANT)			 			
		EndIf 	
		
		//| Atualiza Interface |
		fAtualiza()
	Else
	
		FwHelpShow("NAO LOCALIZ","NAO LOCALIZ","Registro posicionado n„o foi localizado")
		
	EndIf
	
	RestArea(aAreaSE2)
	RestArea(aArea)
Return()

/*/{Protheus.doc} AFIN01CB
Grava cÛdigo de barras no SE1
@author Augusto Ribeiro | www.compila.com.br
@since 20/04/2018
@version undefined
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
User Function AFIN01CB(nRecDDA, nRecSE2)
Local aRet		:= {.F., ""}
Local cTitSE2	:= ""

If !Empty(nRecDDA) .And. !Empty(nRecSE2)
	
	BEGIN TRANSACTION
		
	/*------------------------------------------------------ Augusto Ribeiro | 20/04/2018 - 6:26:45 PM
	\/ 
	\/	Trecho extraido do Fonte FINA260 (Melhorias adicionadas.)
	\/ 
	------------------------------------------------------------------------------------------*/
	DbSelectArea("FIG")
	DbGoTo(nRecDDA)	
	
	DbSelectArea("SE2")
	DbGoTo(nRecSE2)
	
	If Empty(SE2->E2_CODBAR)
		If RecLock("SE2",.F.)
			
			/*------------------------------------------------------ Augusto Ribeiro | 10/05/2018 - 2:24:36 PM
				Liberar Titulo ao conciliar
			------------------------------------------------------------------------------------------*/
			If Empty(SE2->E2_DATALIB)
				SE2->E2_DATALIB	:= DDATABASE
				SE2->E2_USUALIB	:= CUSERNAME
				SE2->E2_STATLIB 	:= '03'
			EndIf
		
			SE2->E2_CODBAR	:= FIG->FIG_CODBAR
			cTitSE2			:= SE2->E2_FILIAL 	+ "|"	+;
									SE2->E2_PREFIXO 	+ "|"	+;
									SE2->E2_NUM			+ "|"	+;
									SE2->E2_PARCELA	+ "|"	+;
									SE2->E2_TIPO		+ "|"	+;
									SE2->E2_FORNECE	+ "|"	+;
									SE2->E2_LOJA		+ "|"
	
			/*------------------------------------------------------------------------------------------ 
				Ponto de Entrada para gravacao complementar SE2
			------------------------------------------------------------------------------------------*/
			If ExistBlock("FA260GRSE2")
				ExecBlock("FA260GRSE2",.F.,.F.)
			EndIf
			MsUnLock()
		
			DbSelectArea("FIG")
			DbGoTo(nRecDDA)
			If RecLock("FIG",.F.)
				FIG->FIG_DDASE2	:= cTitSE2		//Chave do SE2 com o qual foi conciliado
				FIG->FIG_CONCIL	:= "1" 			//Conciliado
				FIG->FIG_DTCONC	:= dDatabase	//Data da Conciliacao
				FIG->FIG_USCONC	:= cUsername	//Usuario responsavel pela conciliacao
		
				/*--------------------------
					Ponto de Entrada para gravacao complementar FIG
				---------------------------*/
				If ExistBlock("FA260GRFIG")
					ExecBlock("FA260GRFIG",.F.,.F.)
				EndIf
				MsUnLock()
			EndIf
			
			aRet[1]	:= .T.
		Else
			aRet[2]	:= "N„o foi possivel alterar o titulo posicionado ["+SE2->E2_FILIAL+"|"+;
									SE2->E2_PREFIXO	+	"|"	+;
									SE2->E2_NUM+"|"				+;
									SE2->E2_PARCELA	+	"|"	+;
									SE2->E2_TIPO+"|"				+;
									SE2->E2_FORNECE	+	"|"	+;
									SE2->E2_LOJA					+"]"
		EndIf
	Else
		aRet[2]	:= "Titulo ja possiu codigo de barras [" + SE2->E2_FILIAL + "|" +;
									SE2->E2_PREFIXO + "|" 	+;
									SE2->E2_NUM+"|"			+;
									SE2->E2_PARCELA + "|"	+;
									SE2->E2_TIPO+"|"			+;
									SE2->E2_FORNECE + "|"	+;
									SE2->E2_LOJA+"]"
	EndIf
	
	/*------------------------------------------------------ Augusto Ribeiro | 20/04/2018 - 6:26:45 PM
	/\ 
	/\ Trecho extraido do Fonte FINA260
	/\ 
	------------------------------------------------------------------------------------------*/	
		
	
	END TRANSACTION
Else
	aRet[2]	:= "Parametros Inv·lidos"
EndIf

Return(aRet)





/*/{Protheus.doc} AFIN01GB
Gera Bordero e CNAB a Pagar
@author Augusto Ribeiro | www.compila.com.br
@since 24/04/2018
@version undefined
@param aRECSE2, {cFilial, cRecSE2}
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
User Function AFIN01GB(aRECSE2)
Local aRet			:= { .f., "", ""}
Local nI				:= 0
Local cFilAux, cOldPort240 , cTpPgto
Local lEA_ORIGEM 	:= IIf (SEA->( ColumnPos( "EA_ORIGEM" ) ) > 0, .T., .F.)
Local lF240TBor	:= ExistBlock("F240TBOR")
Local lFinVDoc, cNomeCnab		    

DbSelectArea("SE2")


If !Empty(aRECSE2) 


	//| Ordena or filial |
	aSort(aRECSE2,,,{ |x,y| (x[1] + x[1]) + (x[ 3] + x[3])   < ( y[1] + y[1] ) + ( y[3] + y[3] ) })


	BEGIN TRANSACTION
	
	cFilAux	:= ""
	cTpPgto	:= ""
	For nI := 1 To Len(aRECSE2)
	
		cFilAux	:= aRECSE2[nI, 1]
		cTpPgto 	:= aRECSE2[nI, 3]
		
		/*---------------------------------------
			Realiza a TROCA DA FILIAL CORRENTE 
		-----------------------------------------*/
		_cCodEmp := SM0->M0_CODIGO
		_cCodFil	:= SM0->M0_CODFIL
		_cFilNew	:= cFilAux //| CODIGO DA FILIAL DE DESTINO 
		
		If _cCodEmp+_cCodFil <> _cCodEmp+_cFilNew
			CFILANT := _cFilNew
			opensm0(_cCodEmp+CFILANT)
		EndIf
		
		lFinVDoc		:= IIF(GetNewPar("MV_FINVDOC","2")=="1",.T.,.F.)		//Controle de validacao de documentos obrigatorios    
		
		// Verifica numero do ultimo Bordero Gerado                     		
		DbSelectArea("SX6")
		cNumBor := Soma1(Pad(GetMV("MV_NUMBORP"),Len(SE2->E2_NUMBOR)),Len(SE2->E2_NUMBOR))
		Do While !MayIUseCode( "E2_NUMBOR"+SX6->(FIELDGET(FIELDPOS("X6_FIL")))+cNumBor)  //verifica se esta na memoria, sendo usado
			cNumBor := Soma1(cNumBor)										// busca o proximo numero disponivel 
		EndDo   				
				
//		aRetAux	:= ParamBor(cNumBor)
		
		
		
//		cPort240	:= aRetAux[1]
//		cAgen240	:= aRetAux[2]
//		cConta240	:= aRetAux[3]
//		cModPgto	:= aRetAux[4]
//		cTipoPag	:= aRetAux[5]
		
	 	Do While iif(nI <= Len(aRECSE2),  cFilAux == aRECSE2[ nI, 1]  , .F.) 
		
			SE2->(MSGOTO(aRECSE2[nI, 2] ))
			
			cTpPgto := aRECSE2[nI, 3]
				
			aRetAux	:= ParamBor(cNumBor)
	
			If !Empty(aRetAux)
			
				cPort240		:= aRetAux[1]
				cAgen240		:= aRetAux[2]
				cConta240	:= aRetAux[3]
				cModPgto		:= aRetAux[4]
				cTipoPag		:= aRetAux[5]
				
				cOldPort240 := SE2->E2_PORTADO	// Guarda o portador anterior para envia-lo ao PE
				// F240TBOR, caso o usuario nao queira que seja
				// alterado o portador
				DbSelectArea("SEA")
				RecLock("SEA",.T. )
				Replace 	EA_FILIAL  With xFilial("SEA"),;
				EA_PORTADO With cPort240			,;
				EA_AGEDEP  With cAgen240			,;
				EA_NUMCON  With cConta240			,;
				EA_NUMBOR  With cNumBor				,;
				EA_DATABOR With dDataBase			,;
				EA_PREFIXO With SE2->E2_PREFIXO	,;
				EA_NUM     With SE2->E2_NUM		,;
				EA_PARCELA With SE2->E2_PARCELA	,;
				EA_TIPO    With SE2->E2_TIPO		,;
				EA_FORNECE With SE2->E2_FORNECE	,;
				EA_LOJA	  With SE2->E2_LOJA		,;
				EA_CART    With "P"					,;
				EA_MODELO  With cModPgto			,;
				EA_TIPOPAG With cTipoPag			,;
				EA_FILORIG With SE2->E2_FILORIG												

				If lEA_ORIGEM				
					Replace EA_ORIGEM  With "FINA240"
				EndIf								
		
				MsUnLock()
				FKCOMMIT()
		
				RecLock("SE2",.F.)
				Replace E2_NUMBOR  With cNumBor
				Replace E2_PORTADO With cPort240
				MsUnLock( )
				FKCOMMIT()
				
				//Envio de e-mail pela rotina de checklist de documentos obrigatorios
				If lFinVDoc
					CN062ValDocs("06",.F.,.T.)
				EndIf
		
				//Abro o SE2 com outro Alias se o mesmo n„o estiver aberto
				If Select("__SE2") == 0
				   ChkFile("SE2",.F.,"__SE2")
				Else
			  	   DbSelectArea("__SE2")
				EndIf
		
				//Gravo o numero do bordero em todos os titulos de abatimentos
				__SE2->(dbSetOrder(1))
				__SE2->(MsSeek(xFilial("SE2")+SE2->(E2_PREFIXO+E2_NUM+E2_PARCELA)))
				Do While !Eof() .And. __SE2->E2_FILIAL==xFilial("SE2") .And. __SE2->E2_PREFIXO == SE2->E2_PREFIXO .And.;
						__SE2->E2_NUM == SE2->E2_NUM .And. __SE2->E2_PARCELA == SE2->E2_PARCELA
					If __SE2->E2_TIPO $ MVABATIM .And. __SE2->E2_FORNECE == SE2->E2_FORNECE
						RecLock("__SE2")
						Replace E2_NUMBOR  With cNumBor
						Replace E2_PORTADO With cPort240
						MsUnLock()
						FKCOMMIT()
					EndIf
					DbSkip()
				EndDo
				
				DbSelectArea("SE2")
				
				If lF240TBor
					ExecBlock("F240TBOR",.f.,.f.,{cOldPort240,cPort240})
				EndIf
				
//				aRet		:= { .T., "", "BorderÙ Gerado - " + cNumBor + " Filial " + xFilial("SEA") + CRLF }
				aRet		:= { .T., "", cNumBor }
				
//				aAdd(aNumBorG,cNumBor )
			EndIf 
			
			
			
			nI++
			
			If nI >  Len(aRECSE2) .or. (cTpPgto != aRECSE2[ nI, 3] .OR.  cFilAux != aRECSE2[ nI, 1])
			
				//⁄ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒø
				//≥ Grava o numero do bordero atualizado                         ≥
				//≥ Utilize sempre GetMv para posicionar o SX6. NÑo use SEEK !!! ≥
				//¿ƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒƒŸ
				DbSelectArea( "SX6" )
				GetMv( "MV_NUMBORP" )
				// Garante que o numero do bordero seja sempre superior ao numero anterior
				If __Language == "SPANISH" .And. SX6->(FIELDGET(FIELDPOS("X6_CONTSPA"))) < cNumbor
					RecLock( "SX6" , .F. )
					SX6->(FIELDGET(FIELDPOS("X6_CONTSPA"))) := cNumbor
					MsUnLock()	
				ElseIf SX6->(FIELDGET(FIELDPOS("X6_CONTEUD"))) < cNumbor
					RecLock( "SX6" , .F. )
					SX6->(FIELDPUT(FIELDPOS("X6_CONTEUD"),cNumbor)) 
					MsUnLock()
				EndIf
				
				/*----------------------------------------
					30/04/2018 - Jonatas Oliveira - Compila
					Gera arquivo SISPAG
				------------------------------------------*/
				cNomeCnab	:= LEFT(cUserName,1)+Right(AllTrim(cNumbor),4)+Right(DTOS(DDATABASE),2)
				cRemess 		:= U_AFIN006(cNumBor, cNumBor, SUPERGETMV("AL_ARQSISP"	,.F.	, "itau.pag"	, CFILANT), cFile + cNomeCnab + ".REM")
								
				aAdd(aArqGer,  CFILANT + " | " + cNumBor +  "  | " + cRemess )
				
				cNumBor := soma1(cNumBor)
			EndIf  
		EndDo
		nI-- //| Para compensar a o avanco Do While e FOR|


		/*---------------------------------------
			Restaura FILIAL  
		-----------------------------------------*/
		If _cCodEmp+_cCodFil <> _cCodEmp+_cFilNew
			CFILANT := _cCodFil
			opensm0(_cCodEmp+CFILANT)			 			
		EndIf   
	
	Next nI

	END TRANSACTION
	
EndIf

Return(aRet)




/*/{Protheus.doc} ParamBor
Busca parametros de para geracao do bordero
@author Augusto Ribeiro | www.compila.com.br
@since 24/04/2018
@version undefined
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function ParamBor(cNumbor)
Local aRet			:= {}
Local nOpc			:= 0
Local lBlqBor		:= .T.
Local cPort240, cAgen240, cConta240, cModPgto, cTipoPag, cMoeda240, cContrato, aMoedas
//Local oPanel, oDlg, nEspLarg, nEspLin

aMoedas 		:= GetMoedas()
cContrato	:= CriaVar("E9_NUMERO")
cMoeda240	:= "1"
cModPgto  	:= IIF(LEFT(SE2->E2_CODBAR,3) == "341" , "30", "31" )
cTipoPag 	:= SUPERGETMV("AL_TIPDDA"	,.F.	,"20"		, CFILANT)
cPort240  	:= SUPERGETMV("AL_BCODDA"	,.F.	,"341"		, CFILANT)
cAgen240 	:= SUPERGETMV("AL_AGENDDA"	,.F.	,"7475"		, CFILANT)
cConta240	:= SUPERGETMV("AL_CTADDA"	,.F.	,"05722"	, CFILANT)
	

//nEspLarg := 2
//nEspLin  := 2
//DEFINE MSDIALOG oDlg FROM  15,6 To 219,404 TITLE AllTrim(SM0->M0_CODFIL)+"-"+AllTrim(SM0->M0_FILIAL) PIXEL  //"Borderìs de Pagamentos"
//
//
//oDlg:lMaximized := .F.
//oPanel := TPanel():New(0,0,'',oDlg,, .T., .T.,, ,20,20)
//oPanel:Align := CONTROL_ALIGN_ALLCLIENT
//
//@ 00+nEspLin, nEspLarg To 29+nEspLin, 196+nEspLarg OF oPanel  PIXEL
//@ 34+nEspLin, nEspLarg To 63+nEspLin, 196+nEspLarg OF oPanel  PIXEL
//@ 68+nEspLin, nEspLarg To 97+nEspLin, 196+nEspLarg OF oPanel  PIXEL
//
//nEspLarg := nEspLarg -1
//
//@ 06+nEspLin, 009+nEspLarg SAY "Numero"	   SIZE 23, 7 OF oPanel PIXEL  //"N£mero"
///*
//@ 06+nEspLin, 045+nEspLarg SAY STR0016		SIZE 32, 7 OF oPanel PIXEL  //"Vencto de"
//@ 06+nEspLin, 090+nEspLarg SAY STR0017		SIZE 32, 7 OF oPanel PIXEL  //"AtÇ"
//@ 06+nEspLin, 135+nEspLarg SAY STR0018		SIZE 53, 7 OF oPanel PIXEL  //"Limite Valor"
//*/
//@ 40+nEspLin, 009+nEspLarg SAY "Banco"			SIZE 23, 7 OF oPanel PIXEL  //"Banco"
//@ 40+nEspLin, 045+nEspLarg SAY "Agencia"		SIZE 32, 7 OF oPanel PIXEL  //"Agància"
//@ 40+nEspLin, 085+nEspLarg SAY "Conta"			SIZE 32, 7 OF oPanel PIXEL  //"Conta"
//@ 40+nEspLin, 151+nEspLarg SAY "Contrato"		SIZE 53, 7 OF oPanel PIXEL  //"Contrato"
//@ 73+nEspLin, 009+nEspLarg SAY "Moeda"			SIZE 23, 7 OF oPanel PIXEL  //"Moeda"
//@ 73+nEspLin, 063+nEspLarg SAY "Modelo"			SIZE 22, 7 OF oPanel PIXEL  //"Modelo"
//@ 73+nEspLin, 097+nEspLarg SAY "Tipo Pagto"		SIZE 32, 7 OF oPanel PIXEL  //"Tipo Pagto"
//       
//If ExistBlock("F240BOR")
//	lBlqBor:= ExecBlock("F240BOR",.F.,.F.,{lBlqBor})
//EndIf
//
////Linha 1
//@ 15+nEspLin, 009+nEspLarg MSGET cNumBor         		SIZE 32, 10 OF oPanel PIXEL ;
//Picture "@!" Valid If(nOpc<>0,!Empty(cNumBor).And.FA240Num(cNumBor),.T.) when lBlqBor
///*
//@ 15+nEspLin, 045+nEspLarg MSGET dVenIni240        	SIZE 45, 10 OF oPanel PIXEL  HASBUTTON
//@ 15+nEspLin, 090+nEspLarg MSGET dVenFim240        	SIZE 45, 10 OF oPanel PIXEL  HASBUTTON ;
//												Valid   If(nOpc<>0,FA240DATA(dVenIni240,dVenFim240),.T.)
//@ 15+nEspLin, 135+nEspLarg MSGET nLimite         		SIZE 60, 10 OF oPanel PIXEL HASBUTTON ;
//												Picture "@E 999,999,999,999.99"  Valid If(nOpc<>0,nLimite >= 0,.T.) 
////Linha 2
//*/
//@ 49+nEspLin,   9+nEspLarg MSGET cPort240        		SIZE 10, 10 OF oPanel PIXEL HASBUTTON ;
//Picture "@!"  ;
//F3 "SA6";    
//Valid F240VldBco(@cPort240,@cAgen240,@cConta240)
//
//@ 49+nEspLin,  45+nEspLarg MSGET cAgen240        		SIZE 26, 10 OF oPanel PIXEL Picture "@!"  ;
//												Valid CarregaSA6(@cPort240,@cAgen240,,.T.)
//@ 49+nEspLin,  85+nEspLarg MSGET cConta240       		SIZE 62, 10 OF oPanel PIXEL Picture "@!"  ;
//												Valid CarregaSA6(@cPort240,@cAgen240,@cConta240,.T.,,.T.)
//@ 49+nEspLin, 151+nEspLarg MSGET cContrato       		SIZE 42, 10 OF oPanel PIXEL Picture "@S3"
//
////Linha 3
//@ 82+nEspLin, 009+nEspLarg MSCOMBOBOX oCbx VAR cMoeda240 ITEMS aMoedas SIZE 46, 13 OF oPanel PIXEL ;
//			 Valid F240VldMd(cPort240,cAgen240,cConta240,Val(cMoeda240))
//@ 82+nEspLin, 063+nEspLarg MSGET cModPgto        		SIZE 25, 10 OF oPanel PIXEL Picture "@!"  Valid If(nOpc<>0,ExistCpo("SX5", + "58" + cModPgto),.T.) F3 "58" HASBUTTON
//@ 82+nEspLin, 097+nEspLarg MSGET cTipoPag        		SIZE 25, 10 OF oPanel PIXEL Picture "@!"  Valid If(nOpc<>0,ExistCpo("SX5", + "59" + cTipoPag),.T.) F3 "59" HASBUTTON
//
//
//DEFINE SBUTTON FROM 83, 140 TYPE 1 ENABLE OF oPanel ACTION (cVar:=cMoeda240, nOpc:=1, Iif(F240TudoOk(oDlg),oDlg:End(),nOpc:=0))
//DEFINE SBUTTON FROM 83, 170 TYPE 2 ENABLE OF oPanel ACTION oDlg:End() 
//
//ACTIVATE MSDIALOG oDlg CENTERED

//If nOpc == 1
aRet	:= {cPort240, cAgen240, cConta240, cModPgto, cTipoPag}
//EndIf

Return(aRet)



/*/{Protheus.doc} GetMoedas
Obter as moedas utilizadas pelo sistema  
Parametros: 
Nenhum
Retorno:   
aRet[n] = Codigo da moeda + Descricao 
@author Marcel Borges Ferreira 
@since 28/09/06
@version undefined
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function GetMoedas()
Local aRet     := {}
Local aArea    := GetArea()
Local aAreaSx6 := Sx6->(GetArea())
Local cFilSx6
Local nX6VAR 	:= SX6->(FIELDPOS("X6_VAR"))
Local nX6FIL 	:= SX6->(FIELDPOS("X6_FIL"))

	

// Inicializa array com as moedas existentes.						  
GetMv("MV_MOEDA1")
cFilSx6 := SX6->(FIELDGET(FIELDPOS("X6_FIL")))
Do While Substr(SX6->(FIELDGET(nX6VAR)),1,8) == "MV_MOEDA" .And. ;
			SX6->(!Eof()) .And. SX6->(FIELDGET(nX6FIL)) == cFilSx6
	If Substr(SX6->(FIELDGET(nX6VAR)),9,1) != "P" .And. Substr(SX6->(FIELDGET(nX6VAR)),9,2) != "CM" // Desconsiderar plural e MV_MOEDACM
		aAdd( aRet, StrZero(Val(Substr(SX6->(FIELDGET(nX6VAR)),9,2)),2) + " " + GetMv(SX6->(FIELDGET(nX6VAR))) )
	EndIf
	SX6->(DbSkip())
EndDo
ASort(aRet)
Sx6->(RestArea(aAreaSx6))
RestArea(aArea)

Return aRet





/*/{Protheus.doc} vldTol
Verifica Tolerancia para selecao do registro
@author Augusto Ribeiro | www.compila.com.br
@since 30/04/2018
@version undefined
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function vldTol(nPosDDA, nPosCP)
Local aRet		:= {.T., ""}
Local nVlrTol	:= SuperGetMV("AL_TOLDDA", .F., 1)
Local nDif

If nPosDDA > 0 .And. nPosCP > 0
		
	If left(aDadosCP[nPosCP,nA2CGC],8) == left(aDadosDDA[nPosDDA,nFIGCNPJ],8) .And.;
		aDadosCP[nPosCP,nE2VENCTO] == aDadosDDA[nPosDDA,nFIGVENCTO]		
		
		//incluÌda linha abaixo [Mauro Nagata, www.compila.com.br, 20200925]	
		//If aDadosCP[ nPosCP, nE2TITULO ] == aDadosDDA[ nPosDDA, nFIGTITULO ]
		//substituÌda linha acima pelo bloco abaixo [Mauro Nagata, www.compila.com.br, 20200929]
		cSE2Tit 	:= AllTrim( aDadosCP[ nPosCP, nE2TITULO ] )
		nSE2Tit	:= Val( StrTran( cSE2Tit, " ", "" ) )

		cFIGTit	:= AllTrim( aDadosDDA[ nPosDDA, nFIGTITULO ] )
		nFIGTit	:= Val( StrTran( cFIGTit, " ", "" ) )
		
		If nSE2Tit = nFIGTit
		//fim bloco [Mauro Nagata, www.compila.com.br, 20200929]

			nDif	:=  aDadosCP[nPosCP, nE2VALOR] - aDadosDDA[nPosDDA, nFIGVALOR]
			If nDIf == 0 .OR.;
					(nDIf < 0 .And. nDIf >= (nVlrTol*-1)) .OR.;
					(nDIf > 0 .And. nDIf <= nVlrTol)
			Else
				aRet[1]		:= .F.
				aRet[2]		:= "Valor divergente acima da tolerancia ["+AllTrim(STR(nVlrTol))+"]"
			EndIf						

		//incluÌda linha abaixo [Mauro Nagata, www.compila.com.br, 20200925]	
		EndIf						
	Else
		aRet[1]		:= .F.
		aRet[2]		:= "Fornecedor ou Vencimento divergente. Verifique o registro selecionado"
	EndIf
				
EndIf


Return(aRet)







/*/{Protheus.doc} PAAberto
Verifica se existe PA em aberto.
@author Augusto Ribeiro | www.compila.com.br
@since 07/05/2018
@version undefined
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function PAAberto(cCodFor, cLoja)
Local lRet	:= .F.
Local cQuery	:= ""


cQuery := " SELECT	TOP 1 E2_NUM "										+	CRLF
cQuery += " FROM 		"+RetSqlName("SE2")+" SE2 with(nolock )"	+	CRLF
cQuery += " WHERE 	E2_TIPO 			= 'PA' "							+	CRLF
cQuery += " 			AND E2_FORNECE	= '"+cCodFor+"' "				+	CRLF
cQuery += " 			AND E2_LOJA 	= '"+cLoja+"' "				+	CRLF
cQuery += " 			AND E2_SALDO 	> 0 "								+	CRLF
cQuery += " 			AND SE2.D_E_L_E_T_  <> '*' "+CRLF


If Select("TMPPA") > 0
	TMPPA->(DbCloseArea())
EndIf

DBUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), "TMPPA",.F., .T.)						


If TMPPA->(!Eof())
	lRet	:= .T.
EndIf	

TMPPA->(DbCloseArea())
	
Return(lRet)


