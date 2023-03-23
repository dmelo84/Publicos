#Include "Protheus.Ch"
#Include "rwmake.Ch"
#Include "TopConn.Ch"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "FWMBROWSE.CH"      

/*-----------------------------------------------------------------
	STATUS | ZCA Mov. Unificado
------------------------------------------------------------------*/
#DEFINE ZCA_STATUS_PENDENTE			"1"
#DEFINE ZCA_STATUS_PARCIAL 			"2"
#DEFINE ZCA_STATUS_CONCLUIDO 		"3"
#DEFINE ZCA_STATUS_INCONSISTENCIA 	"4"
#DEFINE ZCA_STATUS_FALHA 			"5"
#DEFINE ZCA_STATUS_DESCONSIDERADO	"6"


/*-----------------------------------------------------------------
	Status de Processamento tabelas ZC5, ZC6, ZC7, ZC8
------------------------------------------------------------------*/
#DEFINE ZC__STATUS_PENDENTE  "1"
#DEFINE ZC__STATUS_PROCESSADO  "2"
#DEFINE ZC__STATUS_DESCONSIDERADO "3"



/*-----------------------------------------------------------------
	Status de Processamento do Arquivo 1=Pendente;2=Proc. Parcial;3=Processado
	
------------------------------------------------------------------*/
#DEFINE ZC4_STATUS_PENDENTE  "1"
#DEFINE ZC4_STATUS_PARCIAL  "2"
#DEFINE ZC4_STATUS_PROCESSADO "3"




//| TABELA
#DEFINE D_ALIAS 'ZCA'
#DEFINE D_TITULO 'Movimento Cartoes Unificado'
#DEFINE D_ROTINA 'CP11010'
#DEFINE D_MODEL 'ZCAMODEL'
#DEFINE D_MODELMASTER 'ZCAMASTER'
#DEFINE D_VIEWMASTER 'VIEW_ZCA'

/*/{Protheus.doc} ${CP11010}
Modelo 1 MVC
@author Augusto Ribeiro | www.compila.com.br
@since 02/11/2013 
@version 1.0
@example
(examples)
@see (links_or_references)
/*/  
User Function CP11010(aParam)
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetAlias(D_ALIAS)
oBrowse:SetDescription(D_TITULO)

oBrowse:AddLegend( "ZCA_STATUS=='1'", "BR_AMARELO"  , "Pendente"  )
oBrowse:AddLegend( "ZCA_STATUS=='2'", "BR_AZUL"  , "Proc. Parcial"  )
oBrowse:AddLegend( "ZCA_STATUS=='3'", "BR_VERDE"  , "Concluido"  )
oBrowse:AddLegend( "ZCA_STATUS=='4'", "BR_LARANJA"  , "Inconsistencia"  )
oBrowse:AddLegend( "ZCA_STATUS=='5'", "BR_VERMELHO"  , "Falha"  )
oBrowse:AddLegend( "ZCA_STATUS=='6'", "BR_CINZA"  , "Desconsiderado"  )
//oBrowse:SetFilterDefault( "ZA0_TIPO=='C'" )
//oBrowse:SetFilterDefault( "Empty(ZA0_DTAFAL)" )
oBrowse:DisableDetails()

oBrowse:Activate()

Return NIL

        
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ CP11010  ºAutor  ³Augusto Ribeiro     º Data ³ 07/01/2012  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ 	Botoes do MBrowser                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/  
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE 'Pesquisar'  ACTION 'PesqBrw'             OPERATION 1 ACCESS 0
ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.'+D_ROTINA OPERATION 2 ACCESS 0
ADD OPTION aRotina TITLE 'Baixa Manual'   ACTION 'U_CP11011()' OPERATION 3 ACCESS 0
ADD OPTION aRotina TITLE 'Baixa Automática'   ACTION 'U_CP1110MN("BAIXA_AUTOMATICA")' OPERATION 3 ACCESS 0
ADD OPTION aRotina TITLE 'Desconsiderar'   ACTION 'U_CP1110MN("DESCONSIDERAR")' OPERATION 3 ACCESS 0
//ADD OPTION aRotina TITLE 'Incluir'    ACTION 'VIEWDEF.'+D_ROTINA OPERATION 3 ACCESS 0
//ADD OPTION aRotina TITLE 'Alterar'    ACTION 'VIEWDEF.'+D_ROTINA OPERATION 4 ACCESS 0
//ADD OPTION aRotina TITLE 'Excluir'    ACTION 'VIEWDEF.'+D_ROTINA OPERATION 5 ACCESS 0
//ADD OPTION aRotina TITLE 'Reprocessar'   ACTION 'U_PCON04RP()' OPERATION 4 ACCESS 0
ADD OPTION aRotina TITLE 'Imprimir'   ACTION 'VIEWDEF.'+D_ROTINA OPERATION 8 ACCESS 0
//ADD OPTION aRotina TITLE 'Copiar'     ACTION 'VIEWDEF.CP11010' OPERATION 9 ACCESS 0
Return aRotina




/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ CP11010  ºAutor  ³Augusto Ribeiro     º Data ³ 07/01/2011  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ 	Definicoes do Model                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/  
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oStruct := FWFormStruct( 1, D_ALIAS, /*bAvalCampo*/,/*lViewUsado*/ )
Local oStruZCB := FWFormStruct( 1, "ZCB", /*bAvalCampo*/,/*lViewUsado*/ )
//Local oStruZG7 := FWFormStruct( 1, 'ZG7', /*bAvalCampo*/,/*lViewUsado*/ )
Local oModel   

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New(D_MODEL, /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( D_MODELMASTER, /*cOwner*/, oStruct, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )  

// Adiciona ao modelo uma estrutura de formulário de edição por grid
oModel:AddGrid( 'ZCBITEM', D_MODELMASTER, oStruZCB, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

// Faz relaciomaneto entre os compomentes do model
oModel:SetRelation( 'ZCBITEM', { { 'ZCB_FILIAL', 'XFILIAL("ZCB")' }, { 'ZCB_CODMOV', 'ZCA_CODIGO' } }, ZCB->(IndexKey(2)) ) //| ZCB_FILIAL, ZCB_CODMOV, ZCB_ALIAS, ZCB_RECALI, R_E_C_N_O_, D_E_L_E_T_|

// Liga o controle de nao repeticao de linha
//oModel:GetModel( 'ZG7DETAIL' ):SetUniqueLine( { 'ZG7_CHAVE' } )

// Indica que é opcional ter dados informados na Grid
//oModel:GetModel( 'ZG7DETAIL' ):SetOptional(.T.)


// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( D_TITULO )

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( D_MODELMASTER ):SetDescription( 'Movimento Adquirente (unificado)' )
oModel:GetModel( 'ZCBITEM' ):SetDescription( 'Titulos/Movimento Financeiro'  )

// Liga a validação da ativacao do Modelo de Dados
//oModel:SetVldActivate( { |oModel| COMP011ACT( oModel ) } )

Return oModel


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ CP11010  ºAutor  ³Augusto Ribeiro     º Data ³ 07/01/2011  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ 	Definicoes da View                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/  
Static Function ViewDef()
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   := FWLoadModel( D_ROTINA )
// Cria a estrutura a ser usada na View
Local oStruct := FWFormStruct( 2, D_ALIAS )
Local oStruZCB := FWFormStruct( 2, "ZCB" )
Local oView   

//Local oStruCSW := FWFormStruct( 1, 'CSW', /*bAvalCampo*/, /*lViewUsado*/ ) 
//Local oModel

//oStruCSW:RemoveField( 'CSW_ENT' )

//oModel:SetPrimaryKey({"ZK7_CODIGO"})

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( D_VIEWMASTER, oStruct, D_MODELMASTER )
oView:AddGrid( 'VIEW_ZCB', oStruZCB, 'ZCBITEM' )
                                                     
// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'SUPERIOR' , 65 )
oView:CreateHorizontalBox( 'INFERIOR' , 35 )    

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( D_VIEWMASTER, 'SUPERIOR' )
oView:SetOwnerView( 'VIEW_ZCB', 'INFERIOR' )

oView:SetCloseOnOk({||.T.})

  

// Define campos que terao Auto Incremento
//oView:AddIncrementField( 'VIEW_ZG7', 'ZG7_ITEM' )


// Criar novo botao na barra de botoes no antigo Enchoice Bar
 oView:AddUserButton( 'Visualizar Item', 'CLIPS', { |oView| CP1110VI() } )

// Liga a identificacao do componente
oView:EnableTitleView(D_VIEWMASTER)                   
oView:EnableTitleView('VIEW_ZCB')

// Liga a Edição de Campos na FormGrid
//oView:SetViewProperty( 'VIEW_ZG7', "ENABLEDGRIDDETAIL", { 60 } )

Return oView





/*/{Protheus.doc} CP1110MN
Chamadas de Menu para Faturamento
@author Augusto Ribeiro | www.compila.com.br
@since 29/10/2016
@version 6
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/  
User Function CP1110MN(cAcao)
Local oView 		:= FWViewActive()
Local cMsgAviso		:= ""
Local nHSemafaro	:= 0
Local aRetAux, nQtdeArq
Local aRet			:= {.T.,""}
//Local lRet			:= .T.
Local cArq			:= "" 
Local aArqTXT		:= {}
Local cQuery
Local nCount		:= 0
Local aAreaZCA		:= ZCA->(GETAREA())
Local cPathTemp
Local cPerg			:= 'CP11010'
Local lReproc, cStatus,cCodBand, cCodAdq, dDtVdIni, dDtVdFim, dDtPgIni, dPgFim 

IF cAcao == "BAIXA_AUTOMATICA"

	cMsgAviso	:= "Esta rotina realiza a processa todos os movimentos com status pendente e realiza a baixa"+CRLF
	cMsgAviso	+= "dos titulos."+CRLF+CRLF
	cMsgAviso	+= "Deseja Continuar ?"
	
	nOpcAviso	:= AVISO("Baixa Automatica", cMsgAviso,{"Parametros", "Processar", "Cancelar"},2)
	
	
	
	IF nOpcAviso == 1	                                                                                 
	
		PERGUNTE(cPerg,.T.)
		U_CP1110MN("BAIXA_AUTOMATICA")
		
	ELSEIF nOpcAviso == 2
	
		PERGUNTE(cPerg,.F.)
		
		lReproc		:= (MV_PAR01 == 1)
		cStatus		:= ""
		cCodBand 	:= MV_PAR02
		cCodAdq 	:= MV_PAR03
		dDtVdIni 	:= MV_PAR04
		dDtVdFim 	:= MV_PAR05
		dDtPgIni 	:= MV_PAR06
		dPgFim	 	:= MV_PAR07 
			
		Processa({|| aRetAux	:= U_CP11BXAT(lReproc, cStatus,cCodBand, cCodAdq, dDtVdIni, dDtVdFim, dDtPgIni, dPgFim) }, "Processando... ")
	
		
		
		IF !(aRetAux[1]) .AND. !EMPTY(aRetAux[2])
			AVISO("Log de Processamento",aRetAux[2],{"Fechar"},3, "",,,.T.)	
		ENDIF
			       
	ENDIF		
	
	
	
	
	
ELSEIF cAcao == "DESCONSIDERAR"

	
	IF ZCA->ZCA_STATUS == ZCA_STATUS_PENDENTE .OR.;
		ZCA->ZCA_STATUS == ZCA_STATUS_INCONSISTENCIA  .OR.;
		ZCA->ZCA_STATUS == ZCA_STATUS_FALHA
	
		cMsgAviso	:= "Deseja marcar o registro selecionado como 'DESCONSIDERADO' ?"+CRLF
		cMsgAviso	+= CRLF+CRLF
		cMsgAviso	+= "Deseja Continuar ?"
		
		nOpcAviso	:= AVISO("Desconsiderar", cMsgAviso,{"SIM", "NÃO"},2)
		
		IF nOpcAviso == 1	                                                                                 
			reclock("ZCA",.F.)
				ZCA->ZCA_STATUS	:= ZCA_STATUS_DESCONSIDERADO
				ZCA->ZCA_DTPROC	:= DATE()
				ZCA->ZCA_HRPROC	:= TIME()
			MSUNLOCK()
		ENDIF		
	ELSE
		FwHelpShow("DESCONS","DESCONS","Acesso negado. Verifique o status do registro selecionado.")
	ENDIF
		
ENDIF


Return(.T.)




/*/{Protheus.doc} CP1110IN
Inclusao de registros na tabela de movimento unificado ZCA
@author Augusto Ribeiro | www.compila.com.br
@since 14/10/2017
@version 6
@param aDadoMov, Dados do movimento a ser gravado.
@param cAliExt, Alias do Extrato de onde foi obtido os dados e sera utilizado para gravação da tabela de rastreabilidade.
@param aRecExt, Recno dos Registros do Extratode onde foi obtido os dados e sera utilizado para gravação da tabela de rastreabilidade.
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
User Function CP1110IN(aDadoMov, cAliExt, aRecExt)
Local aRet		:= {.F., ""}
Local cQuery	:= ""
Local nI, aRetAux, aDadoZCC
Local cMsgErro	:= ""
Local lValidOK	:= .F.
Local nVlrTaxa	:= 0

Local nCODADQ, nVLIQ, nBANCO, nAGENC, nCONTA, nSALDO, nVTAXA


/*------------------------------------------------------ Augusto Ribeiro | 14/10/2017 - 9:22:59 AM
	VALIDACOES
------------------------------------------------------------------------------------------*/
nCODADQ	:= aScan(aDadoMov, { |x| AllTrim(x[1]) == "ZCA_CODADQ" })
nVLIQ	:= aScan(aDadoMov, { |x| AllTrim(x[1]) == "ZCA_VLIQ" })
nSALDO	:= aScan(aDadoMov, { |x| AllTrim(x[1]) == "ZCA_SALDO" })
nVTAXA	:= aScan(aDadoMov, { |x| AllTrim(x[1]) == "ZCA_VTAXA" })
nBANCO	:= aScan(aDadoMov, { |x| AllTrim(x[1]) == "ZCA_BANCO" })
nAGENC	:= aScan(aDadoMov, { |x| AllTrim(x[1]) == "ZCA_AGENC" })
nCONTA	:= aScan(aDadoMov, { |x| AllTrim(x[1]) == "ZCA_CONTA" })



IF EMPTY(nCODADQ)
	cMsgErro	+= "ZCA_CODADQ não preenchido."+CRLF
ENDIF
IF EMPTY(nVLIQ)
	cMsgErro	+= "ZCA_VLIQ não preenchido."+CRLF
ELSE

	IF !EMPTY(nVTAXA)
		nVlrTaxa	:= aDadoMov[nVTAXA,2]
	ENDIF

	/*-----------------------------------------------------
		SEMPRE alimenta SALDO com valor liquido + taxa
	------------------------------------------------------*/
	IF EMPTY(nSALDO)
		AADD(aDadoMov,{"ZCA_SALDO", aDadoMov[nVLIQ,2]+(nVlrTaxa*-1)})
	ELSE
		aDadoMov[nSALDO,2]	:= aDadoMov[nVLIQ,2]+(nVlrTaxa*-1)
	ENDIF
	
	//AADD(aDadoMov,{"ZCA_SALDO", aDadoMov[nVLIQ,2]})
	
ENDIF
IF EMPTY(nBANCO)
	cMsgErro	+= "ZCA_BANCO não preenchido."+CRLF
ENDIF
IF EMPTY(nAGENC)
	cMsgErro	+= "ZCA_AGENC não preenchido."+CRLF
ENDIF
IF EMPTY(nCONTA)
	cMsgErro	+= "ZCA_CONTA não preenchido."+CRLF
ENDIF


IF EMPTY(cAliExt)
	cMsgErro	+= "Tabela (ALIAS) de referencia ao extrato da adquirente nao informado."+CRLF
ENDIF
IF EMPTY(aRecExt)
	cMsgErro	+= "Registros (RECNOS) de referencia ao extrato da adquirente nao informado."+CRLF
ENDIF	


/*------------------------------------------------------ Augusto Ribeiro | 14/10/2017 - 9:22:59 AM
	GRAVACAO DOS REGISTROS
------------------------------------------------------------------------------------------*/	
IF EMPTY(cMsgErro)

	BEGIN TRANSACTION 
	
		/*------------------------------------------------------ Augusto Ribeiro | 14/10/2017 - 9:38:28 AM
			MOVIMENTO UNIFICADO 
		------------------------------------------------------------------------------------------*/
		aRetAux	:= U_CPXGRV("ZCA", 1, aDadoMov, .T., 3)
	
		IF aRetAux[1]
		
			/*------------------------------------------------------ Augusto Ribeiro | 14/10/2017 - 9:37:58 AM
				GRAVACAO DA ZCC - Rastreabilidade da origem dos registros mov. unificado
			------------------------------------------------------------------------------------------*/
			DBSELECTAREA(cAliExt)
			FOR nI := 1 TO Len(aRecExt)
				

				DBSELECTAREA(cAliExt)
				(cAliExt)->(DBGOTO(aRecExt[nI]))
				
				Reclock(cAliExt, .F.)
					FIELDPUT(FIELDPOS(cAliExt+"_STATUS"), ZC__STATUS_PROCESSADO )
				MSUNLOCK()
				
				/*------------------------------------------------------ Augusto Ribeiro | 18/10/2017 - 2:52:33 PM
					Tabela de Vinculo entre Movimento Extrato x Movimento Unificado
				------------------------------------------------------------------------------------------*/
				aDadoZCC	:= {}
				AADD(aDadoZCC, {"ZCC_CODMOV", ZCA->ZCA_CODIGO})
				AADD(aDadoZCC, {"ZCC_ALIAS", cAliExt})
				AADD(aDadoZCC, {"ZCC_CODEXT", (cAliExt)->(FIELDGET(FIELDPOS(cAliExt+"_CODIGO"))) })
				AADD(aDadoZCC, {"ZCC_RECALI", aRecExt[nI]})
				
				aRetAux	:= U_CPXGRV("ZCC", 1, aDadoZCC, .T., 3)
				
				IF !(aRetAux[1])
					DISARMTRANSACTION()
					cMsgErro	:= aRetAux[2]+"."//| Concatena ponto para evitar falso positivo carro erro venha vazio|
					EXIT
				ENDIF
				
			NEXT nI
			
			
		ELSE
			DISARMTRANSACTION()
			cMsgErro	:= aRetAux[2]+"." //| Concatena ponto para evitar falso positivo carro erro venha vazio|
		ENDIF
	

	END TRANSACTION 		

ENDIF


IF EMPTY(cMsgErro)
	aRet[1]	:= .T. 
ELSE
	aRet[2]	:= cMsgErro
ENDIF

	
Return(aRet)


/*/{Protheus.doc} CP1110VI
Função para visualizar titulos e Movimento Bancario
@author Jonatas Oliveira | www.compila.com.br
@since 04/11/2017
@version 1.0
/*/
Static Function CP1110VI()	
	Local _cCodEmp	:= ""
	Local _cCodFil	:= ""
	Local _cFilNew	:= ""	
	Local oModFull 	:= FWModelActive()
	Local oModItem 	:= oModFull:GetModel('ZCBITEM')
	Local nRecno	:= 0  
	Local cTipo		:= ""

	
	Private CCADASTRO := ""
	PRIVATE aButtons  := {}
	
	IF oModItem:GetValue("ZCB_ALIAS") == "SE1"
		cTipo 	:= "1"
		nRecno 	:= oModItem:GetValue("ZCB_RECALI")
		
	ELSEIF 	oModItem:GetValue("ZCB_ALIAS") == "SE5"
		cTipo 	:= "2"
		nRecno 	:= oModItem:GetValue("ZCB_RECALI")
		
	ENDIF
	
	DBSELECTAREA("SE1")
	  
	IF !EMPTY(oModItem:GetValue("ZCB_ALIAS"))
		IF cTipo == "1"
			CCADASTRO := "Contas a Receber"		
			
		
	
			SE1->(DBGOTO(nRecno )) 
			
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
	
		ELSEIF cTipo =="2"
			SE5->(DBGOTO(nRecno )) 
			
			CCADASTRO := "Movimento Bancario"		
			
			AxVisual('SE5',nRecno,2,,,,,aButtons)
			
		ENDIF 
	ELSE
		Help("CP1110VI",1,"Registros de Pesquisa. " ,,"Não existem registros à serem pesquisados. ",4,5)	
	ENDIF 
Return()
