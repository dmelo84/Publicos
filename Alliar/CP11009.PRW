#Include "Protheus.Ch"
#Include "rwmake.Ch"
#INCLUDE "TOPCONN.CH"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "FWMBROWSE.CH"      
#INCLUDE 'TBICONN.CH'


Static lPosZA3 := .T.

/* - FWMVCDEF
MODEL_OPERATION_INSERT para inclusão;
MODEL_OPERATION_UPDATE para alteração;
MODEL_OPERATION_DELETE para exclusão.
*/

#DEFINE D_TITULO 'Layout Extrato Adquirentes'
#DEFINE D_ROTINA 'CP11009' 



/*/{Protheus.doc} CP11009
Regras para Regra de expedição
@author Augusto Ribeiro | www.compila.com.br
@since 31/03/2016
@version 6
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
User function CP11009() 
//Local oBrowse  
Local cQuery 		:= ""

Private c_CODCLI		:= ""
Private c_LOJACLI		:= ""

Private _LCOPIA		:= .F.
Private aUserAccess := {}  
Private lTeste


oBrowse := FWMBrowse():New()
oBrowse:SetAlias('ZC0')                         
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
±±ºPrograma  ³ CP11009  ºAutor  ³Augusto Ribeiro     º Data ³ 07/01/2011  º±±
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
±±ºPrograma  ³ CP11009  ºAutor  ³Augusto Ribeiro     º Data ³ 19/11/2013  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ 	Definicoes do Model                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/  
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oStruZC0 := FWFormStruct( 1, 'ZC0', /*bAvalCampo*/,/*lViewUsado*/ )
Local oStruZC9 := FWFormStruct( 1, 'ZC9', /*bAvalCampo*/,/*lViewUsado*/ )
Local oModel   


// Cria o objeto do Mod elo de Dados
oModel := MPFormModel():New(D_ROTINA+'MODEL', /*bPreValidacao*/,   /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )
//oModel := MPFormModel():New('ATEC204MODEL', /*bPreValidacao*/, { |oMdl| COMP011POS( oMdl ) }, /*bCommit*/, /*bCancel*/ )

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'ZC0CABEC', /*cOwner*/, oStruZC0, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
oModel:AddGrid( 'ZC9ITENS', 'ZC0CABEC', oStruZC9,  /*LINPRE*/, /*LINPOS*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )


// Faz relaciomaneto entre os compomentes do model                                                                           
oModel:SetRelation( 'ZC9ITENS',		{{ 'ZC9_FILIAL', 'XFILIAL("ZC9")' }, { 'ZC9_CODADQ', 'ZC0_CODADQ' }, { 'ZC9_TIPREG', 'ZC0_TIPREG' } }, ZC9->(IndexKey(1)) )//'ZC9_FILIAL+ZC9_CODADQ+ZC9_TIPREG' )   


// Indica que é opcional ter dados informados na Grid
// oModel:GetModel( 'ZA6SERV' ):SetOptional(.T.) //| Removido Serviços Executados - Sol. Adriano


// Adiciona a descricao do Modelo de Dados
oModel:SetDescription(D_TITULO)

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'ZC0CABEC' ):SetDescription( 'Roteiro de Calculo lote de Cobrança' )      
oModel:GetModel( 'ZC9ITENS' ):SetDescription( 'Itens Roteiro de Calculo' )
/// oModel:GetModel( 'ZA6SERV' ):SetDescription( 'Serviços' ) //| Removido Serviços Executados - Sol. Adriano
      
      
     
// Liga a validação da ativacao do Modelo de Dados
//oModel:SetVldActivate( { |oModel,cAcao| U_FAT01VLD('MODEL_ACTIVE', oModel) } )

Return oModel


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ CP11009  ºAutor  ³Augusto Ribeiro     º Data ³ 07/01/2011  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ 	Definicoes da View                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/  
Static Function ViewDef()
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   := FWLoadModel( D_ROTINA )
// Cria a estrutura a ser usada na View
Local oStruZC0 := FWFormStruct( 2, 'ZC0' )
Local oStruZC9 := FWFormStruct( 2, 'ZC9' )

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
oView:AddField( 'VIEW_ZC0', oStruZC0, 'ZC0CABEC' )
oView:AddGrid( 'VIEW_ZC9', oStruZC9, 'ZC9ITENS' )


// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'SUPERIOR'	, 30 )
oView:CreateHorizontalBox( 'INFERIOR'	, 70) 	          

//oView:CreateHorizontalBox( 'RIGHT_SUP1'	, 80,'RIGHT_SUP') 	
//oView:CreateHorizontalBox( 'RIGHT_SUP2'	, 20,'RIGHT_SUP')
                                          


// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_ZC0', 'SUPERIOR')
oView:SetOwnerView( 'VIEW_ZC9', 'INFERIOR')


// Define campos que terao Auto Incremento
oView:AddIncrementField( 'VIEW_ZC9', 'ZC9_ITEM' )


//oView:AddOtherObject("ABAIXO_CAL", {|oPanel| U_FAT01BCAL(oPanel)})
//oView:SetOwnerView("ABAIXO_CAL",'RIGHT_SUP2')



// Criar novo botao na barra de botoes no antigo Enchoice Bar            
//oView:AddUserButton( 'Imprimir', 'IMPRESSAO', { |oView| U_RTEC001(oView,.T.) } )
//oView:AddUserButton( 'Gera calendario', 'CALENDARIO', { |oView| ALTER("TESTE") } )

// Liga a identificacao do componente
oView:EnableTitleView('VIEW_ZC0','Layout')
oView:EnableTitleView('VIEW_ZC9','Itens do Layout')


// Liga a Edição de Campos na FormGrid
//oView:SetViewProperty( 'VIEW_ZA5'		, "ENABLEDGRIDDETAIL", { 60 } )   


//oView:SetFieldAction(  'ZC9_CODPRO',  {  |oView,  cIDView,  cField,  xValue| TIPOMED(  oView,  cIDView, cField, xValue ) } )

oView:SetCloseOnOk({||.T.})
  
Return oView




/*/{Protheus.doc} FT180CPO
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
User Function FT180CPO(cCampo, cTipo)
Local lRet := .T.
Local nPosCpo, nI
Local oModel := FWModelActive()
Local nOperation := oModel:GetOperation()
Local aAreaZC0 := {}
Local aCenarios, nTamTip, cCombo, aOpcX1, aAux, cVal, cDesc, aAuxCombo

Default cCampo		:= ''
Default cTipo		:= "V"

cCampo := alltrim(cCampo)

/*-------------------
  VALIDACAO
--------------------*/
IF cTipo == "V"


	IF cCampo == "ZC0_CODTEC" 

		DBSELECTAREA("Z69")
		Z69->(DBSETORDER(1)) //| 
		Z69->(DBGOTOP())
		aOpcX1	:=	{}
		WHILE Z69->(!EOF())
		
			IF Z69->Z69_MSBLQL <> '1'
				aadd(aOpcX1, {Z69->Z69_CODADQ, ALLTRIM(Z69->Z69_DESCRI)})
				//AADD(aSimples, ALLTRIM(Z69->Z69_DESCRI))
				//MvParDef	+= Z69->Z69_CODADQ
			ENDIF
			Z69->(DBSKIP()) 
		ENDDO
		Z69->(DBGOTOP())
		
		M->ZC0_CODTEC	:= BrowX1("Tecnologias",aOpcX1)
		
		oModel:GetModel("ZC0CABEC"):LoadValue("ZC0_CODTEC", M->ZC0_CODTEC)
		
		
	ELSEIF cCampo == "ZC0_TIPCON"
	
		
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
			 			
			M->ZC0_TIPCON := BrowX1("Tipo Contrato",aOpcX1)
		
			oModel:GetModel("ZC0CABEC"):LoadValue("ZC0_TIPCON", M->ZC0_TIPCON)			 			
			 			
			
		ENDIF

			
	ENDIF
	
	
/*-------------------
 MODO DE EDICAO - WHEN
--------------------*/
ELSEIF cTipo == "W"

	
ENDIF


Return(lRet)





/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ FT180LOK  ºAutor  ³Augusto Ribeiro    º Data ³ 19/11/2013  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ 	Validacao de linha dos Models.                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/  
User Function FT180LOK(cModel, oModel, nLine, cAction, cField)
Local lRet	:= .F.
Local oModFull := oModel:GetModel() //| Busca Model completa
Local oModeZC9 	:= oModFull:GetModel('ZC9ITENS')
Local cMsgAviso, nI, nY, nX, nTotLen, aRetAux
Local aColsEmp		:= {}
Local cTIPMED, cCodPro, oModeZA6, nLenZA6, nZA6Atu

//Local aSaveLine	:= FWSaveRows()
Local nLenZC9, nZC9Atu, cPerA, cPerB
Local nZC9Mod		:= 0
Local cMsgErro	:= ""

DEFAULT cAction := ""


cAction := ALLTRIM(cAction)
IF cModel == "LPOS_ZC9ITENS"

	/*------------------------------------------------
		REALIZA VALIDACAO DO VOLUME MININO
		SOMENTE PODE POSSUIR VALORES DO TIPO TARIFA
	
	lRet	:= VldVolMin(oModel)
	IF !lRet
		Help(" ",1,"VOL.MIN",,"Para utilização do recurso volume minino, a 'FAIXAS E VALORES' somente pode possuir itens do TIPO "+x3combo("ZA3_TIPO","2")+;
			" Por favor verifique.",4,5)	
	ELSE
	
		lRet := .F.
	
		DBSELECTAREA("ZB3")
		ZB3->(DBSETORDER(1)) //| ZB3_FILIAL+ZB3_CODORI
		IF ZB3->(DBSEEK(xfilial("ZB3")+oModel:GetValue("ZC9_CODORI")))
		
			IF  ZB3->(ZB3_CODGER+ZB3_LOJGER) == oModel:GetValue("ZC9_CODCLI")+oModel:GetValue("ZC9_LOJA")
				lRet := .T.
			ELSE
				Help(" ",1,"Gerador",,"Gerador não pertence a Origem selecionada.",4,5)			
			ENDIF
		ELSE
			Help(" ",1,"Origem",,"Origem nao encontrada.",4,5)		
		ENDIF	
		
	ENDIF
	--------------------------------------------------*/
	lRet := .T.
	
ELSE
	lRet	:= .T.
ENDIF


Return(lRet)



          
/*/{Protheus.doc} SelMult
Seleciona multiplas opcoes no parametro
@author Augusto Ribeiro | www.compila.com.br
@since 28/10/2016
@version 6
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/        
//
Static Function SelMult()

Local cTitulo	:= "Tecnologias"
Local lRet 		:= .F.
Local MvPar
Local MvParDef	:=""

Private aSimples :={}
l1Elem := .F.

cAlias := Alias() 					 // Salva Alias Anterior

MvPar:=&(Alltrim(ReadVar()))		 // Carrega Nome da Variavel do Get em Questao
mvRet:=Alltrim(ReadVar())			 // Iguala Nome da Variavel ao Nome variavel de Retorno

/*
aSimples := {;
			"Provento",; 	//	1
			"Desconto",;	//  2
			"Base"}  		//	3
MvParDef:="123"
*/

DBSELECTAREA("Z69")
Z69->(DBSETORDER(1)) //| 
Z69->(DBGOTOP())
MvParDef	:= ""
WHILE Z69->(!EOF())

	IF Z69->Z69_MSBLQL <> '1'

		AADD(aSimples, ALLTRIM(Z69->Z69_DESCRI))
		MvParDef	+= Z69->Z69_CODADQ
	ENDIF
	Z69->(DBSKIP()) 
ENDDO
Z69->(DBGOTOP())


While !lRet
	IF f_Opcoes(@MvPar,cTitulo,aSimples,MvParDef,,,l1Elem,3)  // Chama funcao f_Opcoes
		&MvRet := mvpar                                                                          // Devolve Resultado
	EndIF
	If !empty(mvpar)
		lRet := .T.
	Endif
Enddo

dbSelectArea(cAlias) 								 // Retorna Alias

Return( MvParDef )      




//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿    
//³ AUGUSTO RIBEIRO                                             ³   
//³                                                             ³
//³ Monta Pequeno Browser da Pergunta, permitindo que o usuário ³
//³selecione mais de uma opção.                                 ³
//³ Recebe Array com os elementos                               ³
//³ Retorna: ****                                               ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Static Function BrowX1(cTitBrw,aOpcoes)
Local BrowX1
Local MvPar
Local MvParDef	:=	""
Local l1Elem   	:=	Nil      
Local lTipoRet	:= 	.T.  
//Local cFilBack	:= cFilAnt

Private _aFilial:=	{}
Private aSit	:= 	{}

l1Elem 			:= 	If (l1Elem = Nil , .F. , .T.)

DEFAULT lTipoRet	:= .T.
DEFAULT BrowX1 		:= "Selecione"
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
	
	//cFilAnt	:= cFilBack 	// Retorna a empresa
	
Return( mvpar )
