#Include "Protheus.Ch"
#Include "rwmake.Ch"
#Include "TopConn.Ch"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "FWMBROWSE.CH"      


//| TABELA
#DEFINE D_ALIAS 'ZD1'
#DEFINE D_TITULO 'Fila Integrador'
#DEFINE D_ROTINA 'CP12001'
#DEFINE D_MODEL 'ZD1MODEL'
#DEFINE D_MODELMASTER 'ZD1MASTER'
#DEFINE D_VIEWMASTER 'VIEW_ZD1'

/*/{Protheus.doc} ${CP12001}
Modelo 1 MVC
@author Augusto Ribeiro | www.compila.com.br
@since 02/11/2013 
@version 1.0
@example
(examples)
@see (links_or_references)
/*/  
User Function CP12001(aParam)
Local oBrowse

oBrowse := FWMBrowse():New()
oBrowse:SetAlias(D_ALIAS)
oBrowse:SetDescription(D_TITULO)

oBrowse:AddLegend( "ZD1_STATUS=='1'", "BR_AMARELO"  , "Pendente"  )
oBrowse:AddLegend( "ZD1_STATUS=='2'", "BR_AZUL"  , "Dependencia"  )
oBrowse:AddLegend( "ZD1_STATUS=='3'", "BR_VERDE"  , "Processado"  )
oBrowse:AddLegend( "ZD1_STATUS=='4'", "BR_VERMELHO"  , "Falha"  )
oBrowse:AddLegend( "ZD1_STATUS=='5'", "BR_CINZA"  , "Desconsiderado"  )


//oBrowse:SetFilterDefault( "ZA0_TIPO=='C'" )
//oBrowse:SetFilterDefault( "Empty(ZA0_DTAFAL)" )
oBrowse:DisableDetails()

oBrowse:Activate()

Return NIL

        
/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � CP12001  �Autor  �Augusto Ribeiro     � Data � 07/01/2012  ���
�������������������������������������������������������������������������͹��
���Desc.     � 	Botoes do MBrowser                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/  
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE 'Pesquisar'  ACTION 'PesqBrw'             OPERATION 1 ACCESS 0
ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.'+D_ROTINA OPERATION 2 ACCESS 0
ADD OPTION aRotina TITLE 'Incluir'    ACTION 'VIEWDEF.'+D_ROTINA OPERATION 3 ACCESS 0
ADD OPTION aRotina TITLE 'Alterar'    ACTION 'VIEWDEF.'+D_ROTINA OPERATION 4 ACCESS 0
ADD OPTION aRotina TITLE 'Excluir'    ACTION 'VIEWDEF.'+D_ROTINA OPERATION 5 ACCESS 0
ADD OPTION aRotina TITLE 'Reprocessar'  ACTION 'U_CP121MNU("PROCESSAR")' OPERATION 4 ACCESS 0 // 'U_CP12PROC(ZD1->ZD1_CODFIL, , ZD1->ZD1_CODIGO, .T.)' OPERATION 4 ACCESS 0
ADD OPTION aRotina TITLE 'Rep. TODOS'   ACTION 'U_CP121MNU("REP_TODOS")' OPERATION 4 ACCESS 0
ADD OPTION aRotina TITLE 'Reg. Excel'   ACTION 'U_CP121MNU("REG_EXCEL")' OPERATION 4 ACCESS 0
//ADD OPTION aRotina TITLE 'Imprimir'   ACTION 'VIEWDEF.CP12001' OPERATION 8 ACCESS 0
//ADD OPTION aRotina TITLE 'Copiar'     ACTION 'VIEWDEF.CP12001' OPERATION 9 ACCESS 0
Return aRotina




/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � CP12001  �Autor  �Augusto Ribeiro     � Data � 07/01/2011  ���
�������������������������������������������������������������������������͹��
���Desc.     � 	Definicoes do Model                                       ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/  
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oStruct := FWFormStruct( 1, D_ALIAS, /*bAvalCampo*/,/*lViewUsado*/ )
//Local oStruZG7 := FWFormStruct( 1, 'ZG7', /*bAvalCampo*/,/*lViewUsado*/ )
Local oModel   

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New(D_MODEL, /*bPreValidacao*/, /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )

// Adiciona ao modelo uma estrutura de formul�rio de edi��o por campo
oModel:AddFields( D_MODELMASTER, /*cOwner*/, oStruct, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )  

// Adiciona ao modelo uma estrutura de formul�rio de edi��o por grid
//oModel:AddGrid( 'ZG7DETAIL', 'ZK7MASTER', oStruZG7, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

// Faz relaciomaneto entre os compomentes do model
//oModel:SetRelation( 'ZG7DETAIL', { { 'ZG7_FILIAL', 'ZK7_FILIAL' }, { 'ZG7_CODIGO', 'ZK7_CODIGO' } }, 'ZG7_FILIAL + ZG7_CODIGO' )

// Liga o controle de nao repeticao de linha
//oModel:GetModel( 'ZG7DETAIL' ):SetUniqueLine( { 'ZG7_CHAVE' } )

// Indica que � opcional ter dados informados na Grid
//oModel:GetModel( 'ZG7DETAIL' ):SetOptional(.T.)


// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( D_TITULO )

// Adiciona a descricao do Componente do Modelo de Dados
//oModel:GetModel( 'ZK7MASTER' ):SetDescription( 'Cadastro de fun��o de representantes' )
//oModel:GetModel( 'ZG7DETAIL' ):SetDescription( 'Config. Sistemas Protheus Connector'  )

// Liga a valida��o da ativacao do Modelo de Dados
//oModel:SetVldActivate( { |oModel| COMP011ACT( oModel ) } )

Return oModel


/*���������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � CP12001  �Autor  �Augusto Ribeiro     � Data � 07/01/2011  ���
�������������������������������������������������������������������������͹��
���Desc.     � 	Definicoes da View                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
���������������������������������������������������������������������������*/  
Static Function ViewDef()
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   := FWLoadModel( D_ROTINA )
// Cria a estrutura a ser usada na View
Local oStruct := FWFormStruct( 2, D_ALIAS )
//Local oStruZK7 := FWFormStruct( 2, 'ZK7', { |cCampo| COMP11STRU(cCampo) } )
Local oView   

//Local oStruCSW := FWFormStruct( 1, 'CSW', /*bAvalCampo*/, /*lViewUsado*/ ) 
//Local oModel

//oStruCSW:RemoveField( 'CSW_ENT' )

//oModel:SetPrimaryKey({"ZK7_CODIGO"})

// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados ser� utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( D_VIEWMASTER, oStruct, D_MODELMASTER )
                                                     
// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'SUPERIOR' , 100 )    

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( D_VIEWMASTER, 'SUPERIOR' )

oView:SetCloseOnOk({||.T.})

  

// Define campos que terao Auto Incremento
//oView:AddIncrementField( 'VIEW_ZG7', 'ZG7_ITEM' )


// Criar novo botao na barra de botoes no antigo Enchoice Bar
// oView:AddUserButton( 'Inclui Linha', 'CLIPS', { |oView| VldDados() } )

// Liga a identificacao do componente
//oView:EnableTitleView('VIEW_ZG7','UNIDADES')                    

// Liga a Edi��o de Campos na FormGrid
//oView:SetViewProperty( 'VIEW_ZG7', "ENABLEDGRIDDETAIL", { 60 } )

Return oView




/*/{Protheus.doc} CP121MNU
Chamadas de Menu para Fila Integrador
@author Augusto Ribeiro | www.compila.com.br
@since 29/10/2016
@version 6
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/  
User Function CP121MNU(cAcao)
Local oView 		:= FWViewActive()
Local cMsgAviso		:= ""
Local aRetAux, nQtdeArq
Local aRet			:= {.T.,""}
Local cQuery
Local nCount		:= 0
Local aAreaZCA		:= ZCA->(GETAREA())

IF cAcao == "REG_EXCEL"

	IF !EMPTY(ZD1->ZD1_ALIAS) .AND. !EMPTY(ZD1->ZD1_RECALI)
		
		cQuery := " SELECT * FROM  "+RetSqlName(ZD1->ZD1_ALIAS)+CRLF
		cQuery += " WHERE R_E_C_N_O_ =  "+ALLTRIM(STR(ZD1->ZD1_RECALI))+CRLF
	
		U_CPXSQLXLS(cQuery,.T.)		
	
	ENDIF
	
ELSEIF cAcao == "REP_TODOS"


	cMsgAviso	:= " Esta rotina realiza processamento TODOS os registros pendentes."+CRLF
	cMsgAviso	+= "da fila ["+ZD1->ZD1_CODFIL+"]."+CRLF+CRLF
	cMsgAviso	+= "Deseja continuar ?"+CRLF
	
	nOpcAviso	:= AVISO("Processa Fila", cMsgAviso,{"Processar", "Cancelar"},2)
			
	IF nOpcAviso == 1 
		
		Processa({|| U_CP12PROC(ZD1->ZD1_CODFIL, , , ) }, "Processando... ")
		
		RESTAREA(aAreaZCA)
	ENDIF
		
ELSEIF cAcao == "PROCESSAR"

	aRetAux	:= U_CP12PROC(ZD1->ZD1_CODFIL, , ZD1->ZD1_CODIGO, .T.)
	IF !(aRetAux[1])
		AVISO("Falha ao processar registro Fila", aRetAux[2],{"OK"},2)		
	ENDIF
	
ENDIF


Return(aRet[1])

