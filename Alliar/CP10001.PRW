#Include "Protheus.Ch"
#Include "rwmake.Ch"
#INCLUDE "TOPCONN.CH"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "FWMBROWSE.CH"      
#INCLUDE 'TBICONN.CH'



/* - FWMVCDEF
MODEL_OPERATION_INSERT para inclusão;
MODEL_OPERATION_UPDATE para alteração;
MODEL_OPERATION_DELETE para exclusão.
*/

#DEFINE D_TITULO 'Simple Export'
#DEFINE D_ROTINA 'CP10001' 


/*/{Protheus.doc} CP10001
Simple Export - Cadastro de Consultas
@author Augusto Ribeiro | www.compila.com.br
@since 31/03/2016
@version 6
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
User function CP10001() 
//Local oBrowse  
Local cQuery 		:= ""

oBrowse := FWMBrowse():New()
oBrowse:SetAlias('Z40')                         
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
±±ºPrograma  ³ CP10001  ºAutor  ³Augusto Ribeiro     º Data ³ 07/01/2011  º±±
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
ADD OPTION aRotina TITLE 'TESTAR CONSULTA'     ACTION 'U_CP101BTN("JSON")' OPERATION 9 ACCESS 0

Return aRotina







/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ CP10001  ºAutor  ³Augusto Ribeiro     º Data ³ 19/11/2013  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ 	Definicoes do Model                                       º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/  
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oStruZ40 := FWFormStruct( 1, 'Z40', /*bAvalCampo*/,/*lViewUsado*/ )
Local oStruZ41 := FWFormStruct( 1, 'Z41', /*bAvalCampo*/,/*lViewUsado*/ )
Local oModel   


// Cria o objeto do Mod elo de Dados
oModel := MPFormModel():New(D_ROTINA+'MODEL', /*bPreValidacao*/,   /*bPosValidacao*/, /*bCommit*/, /*bCancel*/ )
//oModel := MPFormModel():New('ATEC204MODEL', /*bPreValidacao*/, { |oMdl| COMP011POS( oMdl ) }, /*bCommit*/, /*bCancel*/ )

// Adiciona ao modelo uma estrutura de formulário de edição por campo
oModel:AddFields( 'Z40CABEC', /*cOwner*/, oStruZ40, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )
oModel:AddGrid( 'Z41ITENS', 'Z40CABEC', oStruZ41,  /*LINPRE*/, /*LINPOS*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )


// Faz relaciomaneto entre os compomentes do model                                                                           
oModel:SetRelation( 'Z41ITENS',		{{ 'Z41_FILIAL', 'XFILIAL("Z41")' }, { 'Z41_CODIGO', 'Z40_CODIGO' } }, Z41->(IndexKey(1)) )//'Z41_FILIAL+Z41_CODIGO' )   


// Indica que é opcional ter dados informados na Grid
// oModel:GetModel( 'ZA6SERV' ):SetOptional(.T.) //| Removido Serviços Executados - Sol. Adriano


// Adiciona a descricao do Modelo de Dados
oModel:SetDescription(D_TITULO)

// Adiciona a descricao do Componente do Modelo de Dados
oModel:GetModel( 'Z40CABEC' ):SetDescription( 'Consulta' )      
oModel:GetModel( 'Z41ITENS' ):SetDescription( 'Parametros' )
/// oModel:GetModel( 'ZA6SERV' ):SetDescription( 'Serviços' ) //| Removido Serviços Executados - Sol. Adriano
      
      
     
// Liga a validação da ativacao do Modelo de Dados
//oModel:SetVldActivate( { |oModel,cAcao| U_FAT01VLD('MODEL_ACTIVE', oModel) } )

Return oModel


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ CP10001  ºAutor  ³Augusto Ribeiro     º Data ³ 07/01/2011  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ 	Definicoes da View                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/  
Static Function ViewDef()
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   := FWLoadModel( D_ROTINA )
// Cria a estrutura a ser usada na View
Local oStruZ40 := FWFormStruct( 2, 'Z40' )
Local oStruZ41 := FWFormStruct( 2, 'Z41' )

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
oView:AddField( 'VIEW_Z40', oStruZ40, 'Z40CABEC' )
oView:AddGrid( 'VIEW_Z41', oStruZ41, 'Z41ITENS' )


// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'SUPERIOR'	, 60 )
oView:CreateHorizontalBox( 'INFERIOR'	, 40) 	          

//oView:CreateHorizontalBox( 'RIGHT_SUP1'	, 80,'RIGHT_SUP') 	
//oView:CreateHorizontalBox( 'RIGHT_SUP2'	, 20,'RIGHT_SUP')
                                          


// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( 'VIEW_Z40', 'SUPERIOR')
oView:SetOwnerView( 'VIEW_Z41', 'INFERIOR')


// Define campos que terao Auto Incremento
oView:AddIncrementField( 'VIEW_Z41', 'Z41_ITEM' )


//oView:AddOtherObject("ABAIXO_CAL", {|oPanel| U_FAT01BCAL(oPanel)})
//oView:SetOwnerView("ABAIXO_CAL",'RIGHT_SUP2')



// Criar novo botao na barra de botoes no antigo Enchoice Bar            
//oView:AddUserButton( 'Imprimir', 'IMPRESSAO', { |oView| U_RTEC001(oView,.T.) } )
//oView:AddUserButton( 'Gera calendario', 'CALENDARIO', { |oView| ALTER("TESTE") } )

// Liga a identificacao do componente
oView:EnableTitleView('VIEW_Z40')
oView:EnableTitleView('VIEW_Z41')


// Liga a Edição de Campos na FormGrid
//oView:SetViewProperty( 'VIEW_ZA5'		, "ENABLEDGRIDDETAIL", { 60 } )   


//oView:SetFieldAction(  'Z41_CODPRO',  {  |oView,  cIDView,  cField,  xValue| TIPOMED(  oView,  cIDView, cField, xValue ) } )

oView:SetCloseOnOk({||.T.})
  
Return oView




/*/{Protheus.doc} CP101CPO
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
User Function CP101CPO(cCampo, cTipo)
Local lRet := .T.
Local nPosCpo, nI
Local oModel := FWModelActive()
Local nOperation := oModel:GetOperation()
Local aAreaZ40 := {}
Local aCenarios, nTamTip, cCombo, aOpcX1, aAux, cVal, cDesc, aAuxCombo

Default cCampo		:= ''
Default cTipo		:= "V"

cCampo := alltrim(cCampo)

/*-------------------
  VALIDACAO
--------------------*/
IF cTipo == "V"


	IF cCampo == "Z40_CODTEC" 

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
		
		M->Z40_CODTEC	:= BrowX1("Tecnologias",aOpcX1)
		
		oModel:GetModel("Z40CABEC"):LoadValue("Z40_CODTEC", M->Z40_CODTEC)
		
		
	ELSEIF cCampo == "Z40_TIPCON"
	
		
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
			 			
			M->Z40_TIPCON := BrowX1("Tipo Contrato",aOpcX1)
		
			oModel:GetModel("Z40CABEC"):LoadValue("Z40_TIPCON", M->Z40_TIPCON)			 			
			 			
			
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
±±ºPrograma  ³ CP101LOK  ºAutor  ³Augusto Ribeiro    º Data ³ 19/11/2013  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ 	Validacao de linha dos Models.                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/  
User Function CP101LOK(cModel, oModel, nLine, cAction, cField)
Local lRet	:= .F.
Local oModFull := oModel:GetModel() //| Busca Model completa
Local oModeZ41 	:= oModFull:GetModel('Z41ITENS')
Local cMsgAviso, nI, nY, nX, nTotLen, aRetAux
Local aColsEmp		:= {}
Local cTIPMED, cCodPro, oModeZA6, nLenZA6, nZA6Atu

//Local aSaveLine	:= FWSaveRows()
Local nLenZ41, nZ41Atu, cPerA, cPerB
Local nZ41Mod		:= 0
Local cMsgErro	:= ""

DEFAULT cAction := ""


cAction := ALLTRIM(cAction)
IF cModel == "LPOS_Z41ITENS"

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
		IF ZB3->(DBSEEK(xfilial("ZB3")+oModel:GetValue("Z41_CODORI")))
		
			IF  ZB3->(ZB3_CODGER+ZB3_LOJGER) == oModel:GetValue("Z41_CODCLI")+oModel:GetValue("Z41_LOJA")
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
		MvParDef	+= Z69->Z69_CODIGO
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



/*/{Protheus.doc} CP101BTN
Realiza Teste da Consulta cadastra
@author Augusto Ribeiro | www.compila.com.br
@since 23/06/2017
@version version
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
User Function CP101BTN(cOpc)
Local aRet		:= {.F., ""}
Local cQuery	:= ""
Local nI

IF cOpc == "JSON"
	tstCons()
ENDIF

	
Return(aRet)





/*/{Protheus.doc} tstCons
Testa Consulta cadastrada
@author Augusto Ribeiro | www.compila.com.br
@since 28/06/2017
@version undefined
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function tstCons()
Local oDlg,oGet1,oSBtn1, oSBtn2,oSBtn3
Local oErro := ErrorBlock({|e| FwHelpShow("Erro na Consulta","Erro na Consulta", IIF(VALTYPE(e:Description)=="C", e:Description,"Erro na consulta cadastrada"),"Verifique a Query e parametros") })
Local oFLabels 		:= TFont():New("Verdana",,014,,.T.,,,,,.F.,.F.)

Private cQryDlg

Begin Sequence	

oDlg := MSDIALOG():Create()
oDlg:cName := "oDlg"
oDlg:cCaption := "COMPILA SIMPLE EXPORTE | Testar Consulta"
oDlg:nLeft := 0
oDlg:nTop := 0
oDlg:nWidth := 534
oDlg:nHeight := 350//277
oDlg:lShowHint := .F.
oDlg:lCentered := .T.

oSepLogo	:= ""
@ 5, 145 BITMAP oSepLogo RESOURCE "COMPLOGO.PNG" PIXEL SIZE 111,30 OF oDlg NOBORDER
//oSepLogo:align := CONTROL_ALIGN_LEFT
oSepLogo:lStretch := .T.

oLblSql := ""
@ 30, 5 SAY oLblSql PROMPT "JSON de Consulta" SIZE 100, 012 OF oDlg FONT oFLabels COLORS RGB(32,32,32), 16777215 PIXEL

oGet1 := TMultiGet():Create(oDlg)
oGet1:cName := "oGet1"
oGet1:nLeft := 9
oGet1:nTop := 80 //30 //11
oGet1:nWidth := 504
oGet1:nHeight := 179
oGet1:lShowHint := .F.
oGet1:lReadOnly := .F.
oGet1:Align := 0
oGet1:cVariable := "cQryDlg"
oGet1:bSetGet := {|u| If(PCount()>0,cQryDlg:=u,cQryDlg) }
oGet1:lVisibleControl := .T.



oSBtn2 := SBUTTON():Create(oDlg)
oSBtn2:cName := "oSBtn2"
oSBtn2:cCaption := "QUERY"
oSBtn2:nLeft := 300 
oSBtn2:nTop := 265 //237//207
oSBtn2:nWidth := 70
oSBtn2:nHeight := 22
oSBtn2:lShowHint := .F.
oSBtn2:lReadOnly := .F.
oSBtn2:Align := 0
oSBtn2:lVisibleControl := .T.
oSBtn2:nType := 1              
//oSBtn2:bAction := {||ExecSql()}
oSBtn2:bAction := {|| execTeste(cQryDlg, "QUERY")}


oSBtn3 := SBUTTON():Create(oDlg)
oSBtn3:cName := "oSBtn3"
oSBtn3:cCaption := "JSON"
oSBtn3:nLeft := 382 
oSBtn3:nTop := 265 //237//207
oSBtn3:nWidth := 70
oSBtn3:nHeight := 22
oSBtn3:lShowHint := .F.
oSBtn3:lReadOnly := .F.
oSBtn3:Align := 0
oSBtn3:lVisibleControl := .T.
oSBtn3:nType := 1              
//oSBtn2:bAction := {||ExecSql()}
oSBtn3:bAction := {|| execTeste(cQryDlg, "JSON")}





oSBtn1 := SBUTTON():Create(oDlg)
oSBtn1:cName := "oSBtn1"
oSBtn1:cCaption := "Cancelar"
oSBtn1:nLeft := 462 
oSBtn1:nTop := 265 //237//207
oSBtn1:nWidth := 70
oSBtn1:nHeight := 22
oSBtn1:lShowHint := .F.
oSBtn1:lReadOnly := .F.
oSBtn1:Align := 0
oSBtn1:lVisibleControl := .T.
oSBtn1:nType := 2        
oSBtn1:bAction := {||oDlg:End()}



oDlg:Activate()


End Sequence

ErrorBlock(oErro)

Return Nil




/*/{Protheus.doc} execTeste
Executa teste da consulta a partir do Json passado.

@author Augusto Ribeiro | www.compila.com.br
@since 28/06/2017
@version undefined
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function execTeste(cJson, cParam)
Local aRetAux	:= {}

Default cJson	:= ""
Default cParam	:= ""

aRetAux	:= U_CP10WSJSON(cJson, cParam)
IF aRetAux[1] == 200
	
	AVISO("Resultado do Teste",aRetAux[3],{"Fechar"},3, "SUCESSO",,,.T.)
ELSE
	AVISO("Resultado do Teste",aRetAux[2],{"Fechar"},3, "FALHA",,,.T.)
ENDIF


Return()




