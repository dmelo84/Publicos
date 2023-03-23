#Include "Protheus.Ch"
#Include "rwmake.Ch"
#INCLUDE "TOPCONN.CH"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "FWMBROWSE.CH"      


Static lPosZA3 := .T.

/* - FWMVCDEF
MODEL_OPERATION_INSERT para inclusão;
MODEL_OPERATION_UPDATE para alteração;
MODEL_OPERATION_DELETE para exclusão.
*/

#DEFINE D_TITULO 'Cadastro de Visitadoras'
#DEFINE D_ROTINA 'ATMK001' 



/*/{Protheus.doc} ATMK001
Cadastro de Visitadoras
@author Augusto Ribeiro | www.compila.com.br
@since 29/08/2017
@version 6
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
User function ATMK001() 
//Local oBrowse  
Local cQuery 		:= ""

Private c_CODCLI		:= ""
Private c_LOJACLI		:= ""

Private _LCOPIA		:= .F.
Private aUserAccess := {}  
Private lTeste


oBrowse := FWMBrowse():New()
oBrowse:SetAlias('Z03')                         
//oBrowse:SetMenuDef( "ATEC204" )                   // Define de onde virao os botoes deste browse
oBrowse:SetDescription(D_TITULO)

    
    
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


//oBrowse:DisableDetails()
	
oBrowse:Activate()

Return NIL

        
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ ATMK001  ºAutor  ³Augusto Ribeiro     º Data ³ 07/01/2011  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ 	Botoes do MBrowser                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/  
Static Function MenuDef()
Local aRotina := {}


ADD OPTION aRotina TITLE 'Pesquisar'  ACTION 'PesqBrw'             OPERATION 1 ACCESS 0
ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.'+D_ROTINA OPERATION 2 ACCESS 0                         
ADD OPTION aRotina TITLE 'Incluir'  ACTION 'VIEWDEF.'+D_ROTINA OPERATION 3 ACCESS 0  	
ADD OPTION aRotina TITLE 'Alterar'    ACTION 'VIEWDEF.'+D_ROTINA OPERATION 4 ACCESS 0
ADD OPTION aRotina TITLE 'Excluir'    ACTION 'VIEWDEF.'+D_ROTINA OPERATION 5 ACCESS 0
ADD OPTION aRotina TITLE 'Imprimir'   ACTION 'VIEWDEF.'+D_ROTINA OPERATION 8 ACCESS 0
ADD OPTION aRotina TITLE 'Copiar'     ACTION 'VIEWDEF.'+D_ROTINA OPERATION 9 ACCESS 0
//ADD OPTION aRotina TITLE 'TESTE'     ACTION 'U_FAT01TST()' OPERATION 9 ACCESS 0

Return aRotina







/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ ATMK001  ºAutor  ³Augusto Ribeiro     º Data ³ 19/11/2013  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ 	Definicoes do Model                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/  
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oStruZ03 := FWFormStruct( 1, 'Z03', /*bAvalCampo*/,/*lViewUsado*/ )
Local oStruZ04 := FWFormStruct( 1, 'Z04', /*bAvalCampo*/,/*lViewUsado*/ )
Local oModel   


// Cria o objeto do Mod elo de Dados
oModel := MPFormModel():New(D_ROTINA+'MODEL', /*bPreValidacao*/,   /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )
//oModel := MPFormModel():New('ATEC204MODEL', /*bPreValidacao*/, { |oMdl| COMP011POS( oMdl ) }, /*bCommit*/, /*bCancel*/ )

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'Z03CABEC', /*cOwner*/, oStruZ03, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
//oModel:AddGrid( 'Z04ITENS', 'Z03CABEC', oStruZ04,  /*LINPRE*/, /*LINPOS*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )


// Faz relaciomaneto entre os compomentes do model                                                                           
//oModel:SetRelation( 'Z04ITENS',		{{ 'Z04_FILIAL', 'XFILIAL("Z04")' }, { 'Z04_CODVIS', 'Z03_CODVIS' } }, Z04->(IndexKey(1)) )//'Z04_FILIAL+Z04_CODIGO' )   


// Indica que é opcional ter dados informados na Grid
//oModel:GetModel( 'Z04ITENS' ):SetOptional(.T.) 

//oModel:GetModel( 'Z04ITENS' ):SetUniqueLine( { 'Z04_CODMED', 'Z04_LOJAME' } )

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription(D_TITULO)

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'Z03CABEC' ):SetDescription( 'Cadastro Visitadora' )      
//oModel:GetModel( 'Z04ITENS' ):SetDescription( 'Médicos vinculados' )
/// oModel:GetModel( 'ZA6SERV' ):SetDescription( 'Serviços' )
      
 oModel:SetPrimaryKey( { "Z03_FILIAL", "Z03_CODVIS" } )     
 
// Liga a validação da ativacao do Modelo de Dados
//oModel:SetVldActivate( { |oModel,cAcao| U_FAT01VLD('MODEL_ACTIVE', oModel) } )

Return oModel


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ ATMK001  ºAutor  ³Augusto Ribeiro     º Data ³ 07/01/2011  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ 	Definicoes da View                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/  
Static Function ViewDef()
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   := FWLoadModel( D_ROTINA )
// Cria a estrutura a ser usada na View
Local oStruZ03 := FWFormStruct( 2, 'Z03' )
//Local oStruZ04 := FWFormStruct( 2, 'Z04' )

Local nOperation := oModel:GetOperation()
Local oView   

//Local oStruCSW := FWFormStruct( 1, 'CSW', /*bAvalCampo*/, /*lViewUsado*/ ) 
//Local oModel
                                   

//oStruCSW:RemoveField( 'CSW_ENT' )
                        
// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados será utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( 'VIEW_Z03', oStruZ03, 'Z03CABEC' )
//oView:AddGrid( 'VIEW_Z04', oStruZ04, 'Z04ITENS' )


// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'SUPERIOR'	, 100 )
//oView:CreateHorizontalBox( 'INFERIOR'	, 70) 	          

//oView:CreateHorizontalBox( 'RIGHT_SUP1'	, 80,'RIGHT_SUP') 	
//oView:CreateHorizontalBox( 'RIGHT_SUP2'	, 20,'RIGHT_SUP')
                                          


// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_Z03', 'SUPERIOR')
//oView:SetOwnerView( 'VIEW_Z04', 'INFERIOR')


// Define campos que terao Auto Incremento
//oView:AddIncrementField( 'VIEW_Z04', 'Z04_ITEM' )


//oView:AddOtherObject("ABAIXO_CAL", {|oPanel| U_FAT01BCAL(oPanel)})
//oView:SetOwnerView("ABAIXO_CAL",'RIGHT_SUP2')



// Criar novo botao na barra de botoes no antigo Enchoice Bar            
//oView:AddUserButton( 'Imprimir', 'IMPRESSAO', { |oView| U_RTEC001(oView,.T.) } )
//oView:AddUserButton( 'Gera calendario', 'CALENDARIO', { |oView| ALTER("TESTE") } )

// Liga a identificacao do componente
oView:EnableTitleView('VIEW_Z03')
//oView:EnableTitleView('VIEW_Z04')


// Liga a Edição de Campos na FormGrid
//oView:SetViewProperty( 'VIEW_ZA5'		, "ENABLEDGRIDDETAIL", { 60 } )   


//oView:SetFieldAction(  'Z04_CODPRO',  {  |oView,  cIDView,  cField,  xValue| TIPOMED(  oView,  cIDView, cField, xValue ) } )

oView:SetCloseOnOk({||.T.})
  
Return oView




/*/{Protheus.doc} ATMK1CPO
Validacao de usuários
@author Augusto Ribeiro | www.compila.com.br
@since 28/10/16
@version version
@param cCampo C, Nome do Campo
@param cTipo, C,  V = Validacao, W = When 
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/  
User Function ATMK1CPO(cCampo, cTipo)
Local lRet := .T.
Local nPosCpo, nI
Local oModel := FWModelActive()
Local nOperation := oModel:GetOperation()
Local aAreaZ03 := {}
Local aCenarios, nTamTip, cCombo, aOpcX1, aAux, cVal, cDesc, aAuxCombo

Default cCampo		:= ''
Default cTipo		:= "V"

cCampo := alltrim(cCampo)

/*-------------------
  VALIDACAO
--------------------*/
IF cTipo == "V"


	IF cCampo == "Z03_CODTEC" 

		DBSELECTAREA("Z69")
		Z69->(DBSETORDER(1)) //| 
		Z69->(DBGOTOP())
		aOpcX1	:=	{}
		WHILE Z69->(!EOF())
		
			IF Z69->Z69_MSBLQL <> '1'
				aadd(aOpcX1, {Z69->Z69_CODIGO, ALLTRIM(Z69->Z69_DESCRI)})
				//AADD(aSimples, ALLTRIM(Z69->Z69_DESCRI))
				//MvParDef	+= Z69->Z69_CODIGO
			ENDIF
			Z69->(DBSKIP()) 
		ENDDO
		Z69->(DBGOTOP())
		
		M->Z03_CODTEC	:= BrowX1("Tecnologias",aOpcX1)
		
		oModel:GetModel("Z03CABEC"):LoadValue("Z03_CODTEC", M->Z03_CODTEC)
		
		
	ELSEIF cCampo == "Z03_TIPCON"
	
		
		DBSELECTAREA("SX3")
		SX3->(DBSETORDER(2)) //| 
		IF SX3->(DBSEEK("Z63_TIPCON")) 

	
		
			nTamTip := SX3->(FIELDGET(FIELDPOS("X3_TAMANHO")))		
			cCombo  := alltrim(SX3->(FIELDGET(FIELDPOS("X3_CBOX"))))
			
			aAuxCombo := StrTokArr(cCombo, ";")
			aOpcX1	:=	{}
			FOR nI := 1 TO LEN(aAuxCombo)
				
				aAux	:= StrTokArr(aAuxCombo[nI],"=")
				cVal	:= ALLTRIM(aAux[1])
				cDesc	:= ALLTRIM(aAux[2])
				
				aadd(aOpcX1, { cVal, cDesc})
			
			NEXT nI				
			 			
			M->Z03_TIPCON := BrowX1("Tipo Contrato",aOpcX1)
		
			oModel:GetModel("Z03CABEC"):LoadValue("Z03_TIPCON", M->Z03_TIPCON)			 			
			 			
			
		ENDIF

			
	ENDIF
	
	
/*-------------------
 MODO DE EDICAO - WHEN
--------------------*/
ELSEIF cTipo == "W"

	
ENDIF


Return(lRet)









/*/{Protheus.doc} ATMK1ADD
Vincula Cadastro do Médico a Visitadora
@author Augusto Ribeiro | www.compila.com.br
@since 18/09/2017
@version undefined
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
User Function ATMK1ADD(cIdVisit, cCodMed, cLojaMe)
Local aRet	:= {.F., ""}
lOCAL cItem	:= "000"

IF !EMPTY(cIdVisit) .AND. !EMPTY(cCodMed) .AND. !EMPTY(cLojaMe)
	
	DBSELECTAREA("Z03")
	Z03->(DBSETORDER(1)) //| 
	IF Z03->(DBSEEK(xfilial("Z03")+cIdVisit)) 
		
		
		DBSELECTAREA("Z04")
		Z04->(DBSETORDER(1)) //| 
		IF Z04->(DBSEEK(xfilial("Z04")+cIdVisit)) 
			WHILE Z04->(!EOF()) .AND. Z04->Z04_CODVIS == cIdVisit
				
				cItem	:= Z04->Z04_ITEM
				
				Z04->(DBSKIP()) 
			ENDDO		
		ENDIF
		
		RegToMemory("Z04", .T.)
		BEGIN TRANSACTION 
		
		RecLock("Z04", .T.)
		
		M->Z04_CODVIS	:= cIdVisit
		M->Z04_ITEM		:= soma1(cItem)
		M->Z04_CODMED	:= cCodMed
		M->Z04_LOJAME	:= cLojaMe
		
		nTotCpo	:= Z04->(FCOUNT()) 
		For nI := 1 To nTotCpo
			cNameCpo	:= ALLTRIM(Z04->(FIELDNAME(nI)))
			FieldPut(nI, M->&(cNameCpo) )
		Next nI
		
		Z04->(MsUnLock())		
		
		
		END TRANSACTION 
	
		
	ELSE
		aRet[2]	:= "Codigo da Visitadora não encontrato"
	ENDIF
ELSE
	aRet[2]	:= "Parametros invalidos."
ENDIF

Retur() 


