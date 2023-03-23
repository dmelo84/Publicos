#Include "Protheus.Ch"
#Include "rwmake.Ch"
#Include "TopConn.Ch"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "FWMBROWSE.CH"      

/* - FWMVCDEF
MODEL_OPERATION_INSERT para inclusใo;
MODEL_OPERATION_UPDATE para altera็ใo;
MODEL_OPERATION_DELETE para exclusใo.
MODEL_OPERATION_VIEW para visualizacao.
*/


//| TABELA
#DEFINE D_ALIAS 'ZB2'
#DEFINE D_TITULO 'Extrado Bancแrio OFX'
#DEFINE D_ROTINA 'CP09004'
#DEFINE D_MODEL 'ZB2MODEL'
#DEFINE D_MODELMASTER 'ZB2MASTER'
#DEFINE D_VIEWMASTER 'VIEW_ZB2'

/*/{Protheus.doc} ${CP09004}
Modelo 1 MVC
@author Augusto Ribeiro | www.compila.com.br
@since 02/11/2013 
@version 1.0
@example
(examples)
@see (links_or_references)
/*/  
User Function CP09004(aParam)
Local oBrowse
PRIVATE _LCOPIA	:= .F.

oBrowse := FWMBrowse():New()
oBrowse:SetAlias(D_ALIAS)
oBrowse:SetDescription(D_TITULO)

//oBrowse:AddLegend( "ZA0_TIPO=='I'", "BLUE"  , "Interprete"  )
//oBrowse:SetFilterDefault( "ZA0_TIPO=='C'" )
//oBrowse:SetFilterDefault( "Empty(ZA0_DTAFAL)" )
oBrowse:DisableDetails()

oBrowse:Activate()

Return NIL

        
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ CP09004  บAutor  ณAugusto Ribeiro     บ Data ณ 07/01/2012  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ 	Botoes do MBrowser                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/  
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE 'Pesquisar'  ACTION 'PesqBrw'             OPERATION 1 ACCESS 0
ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.'+D_ROTINA OPERATION 2 ACCESS 0
ADD OPTION aRotina TITLE 'Incluir'    ACTION 'U_CP904MNU("INCLUI")' OPERATION 3 ACCESS 0
ADD OPTION aRotina TITLE 'Abrir Arq. OFX'    ACTION 'U_CP904MNU("ABRIR_OFX")' OPERATION 4 ACCESS 0
ADD OPTION aRotina TITLE 'Alterar'    ACTION 'VIEWDEF.'+D_ROTINA OPERATION 4 ACCESS 0
ADD OPTION aRotina TITLE 'Excluir'    ACTION 'VIEWDEF.'+D_ROTINA OPERATION 5 ACCESS 0
ADD OPTION aRotina TITLE 'Exlusใo em Lote'   ACTION 'U_CP904MNU("EXCLUI_LOTE")' OPERATION 6 ACCESS 0
//ADD OPTION aRotina TITLE 'Reprocessar'   ACTION 'U_PCON04RP()' OPERATION 4 ACCESS 0
ADD OPTION aRotina TITLE 'Imprimir'   ACTION 'VIEWDEF.CP09004' OPERATION 8 ACCESS 0
//ADD OPTION aRotina TITLE 'Copiar'     ACTION 'VIEWDEF.CP09004' OPERATION 9 ACCESS 0
Return aRotina



/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ EST02MNU  บAutor  ณAugusto Ribeiro     บ Data ณ 07/01/2011  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Fucao para identificacao do botao utilizado                บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/  
User Function CP904MNU(cAcao)
Local nRetAux
Local lRet	:= .t.
Local clPerg :="CP09EXC"
//Local oView 	:= FWViewActive()
//Local oModFull	:= FWModelActive()



//| Forca execu็ใo do set val
IF cAcao == "INCLUI"
	
	_LCOPIA	:= .F.
	
	nRetAux := FWExecView(D_TITULO,D_ROTINA,  MODEL_OPERATION_INSERT,,  {|| .T. } )
	
	WHILE nRetAux == 0
		//ALERT("OK")
		
		IF  AVISO("Copiar ultimo registro", "Deseja incluir um novo registro a partir de uma c๓pia do registro recem gravado ?", {"Sim", "Nใo"},1) == 1
			_LCOPIA	:= .T.	
			nRetAux := FWExecView(D_TITULO,D_ROTINA,  9,,  {|| .T. } ) //| Inicia Copia do Registro 
			_LCOPIA	:= .F.
		ELSE 
			nRetAux := 1
		ENDIF
	ENDDO
	
ELSEIF cAcao == 'ABRIR_OFX'


	IF !EMPTY(ZB2->ZB2_CODARQ)
		DBSELECTAREA("ZB1")
		ZB1->(DBSETORDER(1)) //| 
		IF ZB1->(DBSEEK(xfilial("ZB1")+ZB2->ZB2_CODARQ)) 
			
			
			cTemp		:= GetTempPath(.T.)
			
			cNomeArq	:= NomeArq(alltrim(ZB1->ZB1_ARQUIV))
			
			MSGRUN( "Copiando Arquivo "+cNomeArq, "Copiando arquivo para visualiza็ใo", {|| __CopyFile(ZB1->ZB1_ARQUIVO, cTemp+cNomeArq)})
			
			
			
			//| Abre Arquivo OFX|
			WinExec('explorer.exe '+cTemp+cNomeArq,2)
			
		ENDIF
	ELSE
		lRet	:= .f.
		Help(" ",1,"Arq. Concilia็ใo",,"Este Registro nใo possui arquivo OFX vinculado. Verifique se o arquivo nใo foi inserido manualmente.",4,5)			
	ENDIF

ELSEIF cAcao == 'EXCLUI_LOTE'
		
	Pergunte(clPerg,.T.,"EXCLUSรO EM LOTE")
		 	
	If (mv_par04 > mv_par05)  		
		Aviso("EXCLUI_LOTE","O parametro Data de, deve ser menor que o Data ate: ",{"OK"},1)
		Return()  			
	Elseif Empty(mv_par04) .or. Empty(mv_par05)		
		Aviso("EXCLUI_LOTE","o 4ฐ e o 5บ parametro sใo Obrigat๓rios",{"OK"},1)
		Return()			
	EndIf	
	
	Processa({||CP09EXCL()}, "[ EXCLUSAO EM LOTES ]"+CRLF, "Selecionando ...", .T. )			
			
ENDIF

Return(lRet)


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ CP09004  บAutor  ณAugusto Ribeiro     บ Data ณ 07/01/2011  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ 	Definicoes do Model                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/  
Static Function ModelDef()
// Cria a estrutura a ser usada no Modelo de Dados
Local oStruct := FWFormStruct( 1, D_ALIAS, /*bAvalCampo*/,/*lViewUsado*/ )
//Local oStruZG7 := FWFormStruct( 1, 'ZG7', /*bAvalCampo*/,/*lViewUsado*/ )
Local oModel   

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New(D_MODEL, /*bPreValidacao*/, /*bPosValidacao*/, { |oModel| GRVMODEL(oModel) } /*bCommit*/, /*bCancel*/ )

// Adiciona ao modelo uma estrutura de formulแrio de edi็ใo por campo
oModel:AddFields( D_MODELMASTER, /*cOwner*/, oStruct, /*bPreValidacao*/, /*bPosValidacao*/, /*bCarga*/ )  

// Adiciona ao modelo uma estrutura de formulแrio de edi็ใo por grid
//oModel:AddGrid( 'ZG7DETAIL', 'ZK7MASTER', oStruZG7, /*bLinePre*/, /*bLinePost*/, /*bPreVal*/, /*bPosVal*/, /*BLoad*/ )

// Faz relaciomaneto entre os compomentes do model
//oModel:SetRelation( 'ZG7DETAIL', { { 'ZG7_FILIAL', 'ZK7_FILIAL' }, { 'ZG7_CODIGO', 'ZK7_CODIGO' } }, 'ZG7_FILIAL + ZG7_CODIGO' )

// Liga o controle de nao repeticao de linha
//oModel:GetModel( 'ZG7DETAIL' ):SetUniqueLine( { 'ZG7_CHAVE' } )

// Indica que ้ opcional ter dados informados na Grid
//oModel:GetModel( 'ZG7DETAIL' ):SetOptional(.T.)


// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( D_TITULO )

// Adiciona a descricao do Componente do Modelo de Dados
//oModel:GetModel( 'ZK7MASTER' ):SetDescription( 'Cadastro de fun็ใo de representantes' )
//oModel:GetModel( 'ZG7DETAIL' ):SetDescription( 'Config. Sistemas Protheus Connector'  )

// Liga a valida็ใo da ativacao do Modelo de Dados
//oModel:SetVldActivate( { |oModel,cAcao| U_CP701VLD('MODEL_ACTIVE', oModel) } )
oModel:SetVldActivate( { |oModel| MODELVLD("MODEL_ACTIVE", oModel ) } )
oModel:SetActivate( {|oModel| U_CP904CP(oModel)} )
Return oModel


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ CP09004  บAutor  ณAugusto Ribeiro     บ Data ณ 07/01/2011  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ 	Definicoes da View                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/  
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

// Define qual o Modelo de dados serแ utilizado
oView:SetModel( oModel )

//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( D_VIEWMASTER, oStruct, D_MODELMASTER )
                                                     
// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'SUPERIOR' , 100 )    

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( D_VIEWMASTER, 'SUPERIOR' )

oView:SetCloseOnOk({||.T.})

  

oView:SetFieldAction(  'ZB2_VALOR',  {  |oView,  cIDView,  cField,  xValue| FAction(  oView,  cIDView, cField, xValue ) } )

// Define campos que terao Auto Incremento
//oView:AddIncrementField( 'VIEW_ZG7', 'ZG7_ITEM' )


// Criar novo botao na barra de botoes no antigo Enchoice Bar
// oView:AddUserButton( 'Inclui Linha', 'CLIPS', { |oView| VldDados() } )

// Liga a identificacao do componente
//oView:EnableTitleView('VIEW_ZG7','UNIDADES')                    

// Liga a Edi็ใo de Campos na FormGrid
//oView:SetViewProperty( 'VIEW_ZG7', "ENABLEDGRIDDETAIL", { 60 } )

Return oView





/*/{Protheus.doc} CP904CPO
Validacao de usuแrios
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
User Function CP904CPO(cCampo, cTipo)
Local lRet := .T.
Local nPosCpo, nI
Local oModel := FWModelActive()
Local nOperation := oModel:GetOperation()
Local aAreaZEG := {}

Local oModeZEG, cCodRot

Default cCampo		:= ''
Default cTipo		:= "V"

cCampo := alltrim(cCampo)

/*-------------------
  VALIDACAO
--------------------*/
IF cTipo == "V"


	
/*-------------------
 MODO DE EDICAO - WHEN
--------------------*/
ELSEIF cTipo == "W"

ENDIF


Return(lRet)




/*/{Protheus.doc} MODELVLD
Realiza valida็ใo da Model
@author Augusto Ribeiro | www.compila.com.br
@since 10/01/2017
@version version
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function MODELVLD(cModel, oModel)
Local lRet	:= .T.
Local nOperation := oModel:GetOperation()
Local cMsgErro	:= ""


IF cModel == "MODEL_ACTIVE"
	//| INICIAR NOVA REVISAO - "COPIA"

	//| Regras para COPIA
	IF nOperation == MODEL_OPERATION_UPDATE .OR. nOperation == MODEL_OPERATION_DELETE
	

		IF !EMPTY(ZB2->ZB2_CODCON)
			DBSELECTAREA("SE5")
			
			/*--------------------------
			ITENS CONCILIADOS MOV. BANCARI
			---------------------------*/
			DBSELECTAREA("ZB7")
			ZB7->(DBSETORDER(1))  
			IF ZB7->(DBSEEK(xfilial("ZB7")+ZB2->ZB2_CODCON)) 
				WHILE ZB7->(!EOF()) .AND. ZB7->ZB7_CODIGO == ZB2->ZB2_CODCON
			
					SE5->(DBGOTO(ZB7->ZB7_SE5REC))
					IF !EMPTY(SE5->E5_RECONC)
						cMsgErro	:= "Somente ้ permitida altera็ใo de lan็amentos nใo conciliados. Titulo ["+ALLTRIM(ZB7->ZB7_SE5CHV)+"]" //"Titulo no financeiro esta conciliado. Primeiro desconcile o titulo antes de excluir este registro"
						EXIT
					ENDIF
				
					ZB7->(DBSKIP()) 
				ENDDO
			ENDIF
		ENDIF
			
			
		IF EMPTY(cMsgErro) .AND. nOperation == MODEL_OPERATION_UPDATE .AND. ZB2->ZB2_ORIGEM == "1"
			cMsgErro	:= "Nใo ้ permitida a alteracao de registros importados."
		ENDIF

		IF !EMPTY(cMsgErro)
			Help(" ",1,"BLQALT",,cMsgErro,4,5)	
			lRet	:= .F.	
		ENDIF
		
	ENDIF
ENDIF


Return(lRet)






/*/{Protheus.doc} FAction
Field Action
@author Augusto Ribeiro | www.compila.com.br
@since 10/01/2017
@version 6
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function FAction( oView,  cIDView, cField, xValue)
Local cMsgAviso, nI, nY, nTotLen
Local aColsEmp		:= {}
Local nValor

 
IF ALLTRIM(cField) == "ZB2_VALOR"

	oModFull 	:= oView:GetModel()
	oModItem 	:= oModFull:GetModel(D_MODELMASTER)	
	 
	IF xValue > 0
		oModItem:LoadValue("ZB2_TIPO", "CREDIT" )
	ELSEIF xValue < 0
		oModItem:LoadValue("ZB2_TIPO", "DEBIT" )
	ELSE
		oModItem:LoadValue("ZB2_TIPO", "" )		
	ENDIF
	 		
	oView:Refresh()		
	
ENDIF

Return NIL 







/*/{Protheus.doc} CP701ZA3
Carrega dados no GRID quando inclusao
@author Augusto Ribeiro | www.compila.com.br
@since 17/01/2015
@version 1.0
@param ${oModel}, ${O}, ${Objeto model}
@return ${aRet}, ${Array com dados do GRID}
/*/
//User Function CP07LZA3(oModFull)
User Function CP904CP(oModFull)
Local aRet			:= {}
Local oModeZB2 		:= oModFull:GetModel(D_MODELMASTER) 

Local nOperation 		:= oModFull:GetOperation()
 
//| Determina se trata-se de uma copia
Local LCOPIA		:= oModFull:ACONTROLS[4] == 6

IF _LCOPIA
	LCOPIA	:= .T.
ENDIF


IF nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE
	
	
	/*---------------------------------------------------------------------------------------
		COPIA - ZERA CAMPOS
	------------------------------------------------------------------------------------------*/
	IF LCOPIA
		
		oModeZB2:LoadValue("ZB2_CODIGO", 	CRIAVAR("ZB2_CODIGO",.T.))
		oModeZB2:LoadValue("ZB2_TIPO", 		CRIAVAR("ZB2_TIPO",.T.))
		oModeZB2:LoadValue("ZB2_DATA", 		CRIAVAR("ZB2_DATA",.T.))
		oModeZB2:LoadValue("ZB2_VALOR", 	CRIAVAR("ZB2_VALOR",.T.))
		oModeZB2:LoadValue("ZB2_FITID", 	CRIAVAR("ZB2_FITID",.T.))
		oModeZB2:LoadValue("ZB2_DESC", 		CRIAVAR("ZB2_DESC",.T.))
		oModeZB2:LoadValue("ZB2_CODARQ", 	CRIAVAR("ZB2_CODARQ",.T.))
		oModeZB2:LoadValue("ZB2_DTCONC", 	CRIAVAR("ZB2_DTCONC",.T.))
		oModeZB2:LoadValue("ZB2_CODCON", 	CRIAVAR("ZB2_CODCON",.T.))

		//oModeZA2:DeActivate()
		
		//oModeZA2:Activate()

		/*
		FOR nI := 1 TO oModeZA2:Length()
			oModeZA2:GoLine(nI)
			oModeZA2:DeleteLine()	
		NEXT nI
		*/
		
	ENDIF
ENDIF

	
Return(NIL)





/*/{Protheus.doc} NomeArq
Retorna nome do arquivo com a extensใo
@author Augusto Ribeiro | www.compila.com.br
@since 09/01/2015
@version 1.0
@param ${cFullPath}, ${c}, ${Caminho completo do arquivo}
@return ${cRet}, ${Nome do Arquivo sem extensใo }
/*/
Static Function NomeArq(cFullPath)
Local cRet	:= ""
Local nPosBar

cFullPath	:= ALLTRIM(cFullPath)
nPosBar	:= rat("\",cFullPath)

IF nPosBar > 0
	cRet := SUBSTR(cFullPath, nPosBar+1, LEN(cFullPath)-nPosBar )
ENDIF

Return(cRet)





/*/{Protheus.doc} GRVMODEL
Grava Parametros
@author Augusto Ribeiro | www.compila.com.br
@since 14/02/2015
@version 1.0
@param oModel,O, Model
@return lRet, Retorno Aprovacao
@example
(examples)
@see (links_or_references)
/*/
Static Function GRVMODEL(oModFull)
Local lRet				:= .T.


BEGIN TRANSACTION

cCodCon	:= ZB2->ZB2_CODCON

FWFormCommit( oModFull )

U_CP09DCON(cCodCon)


END TRANSACTION
	
Return(lRet)


/*/{Protheus.doc} CP09EXCL
Eclui titulos de acordo com os parโmetros selecionados.
@author Fabio Sales | www.compila.com.br
@since 08/07/2017
@version 1.0
@see (links_or_references)
/*/

Static Function CP09EXCL()

	Local clQuery := ""
	Local nlCount := 0
	Local nlTotal := 0
	Local aHeader		:= {}
	Local nY
	Local aDadosList	:= {}
	Private aCpoHeader	:= {} 
	Private cCadastro 	:= ""

	clQuery += " SELECT * " +CRLF
	clQuery += " FROM "+ RetSqlName("ZB2") + " ZB2 WITH(NOLOCK) " +CRLF
	clQuery += " WHERE  ZB2.D_E_L_E_T_= '' "  +CRLF
	
	IF !Empty(mv_par01)	 
		clQuery += " AND  ZB2.ZB2_BANCO = '"+ mv_par01 +" ' "  +CRLF
	EndIf
	
	IF !Empty(mv_par02)	 
		clQuery += " AND  ZB2.ZB2_AGENC = '"+ mv_par02 +" ' "  +CRLF
	EndIf
	
	IF !Empty(mv_par03)	 
		clQuery += " AND  ZB2.ZB2_CONTA = '"+ mv_par03 +" ' "  +CRLF
	EndIf
	
	clQuery += " AND  ZB2.ZB2_DATA BETWEEN  '"+ DTOS(mv_par04) +" ' AND '"+ DTOS(mv_par05) +"' "  +CRLF
	clQuery += " AND  ZB2.ZB2_DTCONC ='' "  +CRLF
	clQuery += " AND  ZB2.ZB2_CODCON ='' "  +CRLF
	
	If Select("TSQL1") > 0
		dbSelectArea("TSQL1")
		DbCloseArea()
	EndIf
	
	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,clQuery),"TSQL1",.F.,.T.)
	
	dbSelectArea("TSQL1") 
	
	TSQL1->(DBGoTop())	
	TSQL1->( dbEval( {|| nlTotal++ } ) )	
	TSQL1->(DBGoTop()) 	
	
	IF TSQL1->(!EOF())
		
		aadd(aHeader," ")                
		aadd(aCpoHeader," ")
		For nY := 1 To TSQL1->(FCOUNT())
		   aadd(aHeader,RetTitle(FieldName(nY)))
		   aadd(aCpoHeader,FieldName(nY))
		Next nY	
										
		//| Monta aDados
		
		WHILE TSQL1->(!EOF())
			aLinha	:= {}
			AADD(aLinha, .F.)
			For nY := 1 To TSQL1->(FCOUNT())
			   aadd(aLinha, TSQL1->&(FieldName(nY)) )
			Next nY	 
			
		 	AADD(aDadosList, aLinha)
		 	
			TSQL1->(DBSKIP())
		ENDDO                       					
		
		//| Monta ListMark para o Usuแrio
		
		CP09EXCL01(aHeader, aDadosList)
					
	ELSE
		Aviso("NAO ACHOU","Nenhum registro encontrado com os parโmetros informados. ",{"OK"},1) == 1
	ENDIF

Return()


/*/{Protheus.doc} CP09EXCL01
Monta um listmark para o usuแrio selecionar o que ele deseja
@author Fabio Sales | www.compila.com.br
@since 08/07/2017
@version 1.0
@param aHeader,A, Cont้m os titulos dos campos.
@param aDados,A, Cont้m os dados dos campos.
@example
(examples)
@see (links_or_references)
/*/

Static Function CP09EXCL01(aHeader, aDados)

	Local cVar     := Nil
	Local oDlg     := Nil
	Local cTitulo  := "Selecione as OSs que deseja Faturar"
	Local lMark    := .F.
	Local oOk      := LoadBitmap( GetResources(), "LBOK" ) //| Checked
	Local oNo      := LoadBitmap( GetResources(), "LBNO" ) //| Unchecked
	Local oChk     := Nil
	Local aDados
	Local nY, nI        
	Local cBCodLin	:= ""	
	Local aVetor	:= {}
	
	Private lMarkb	:= .f.
	Private nColAnt	:= 1
	
	Private lChk     := .F.
	Private oLbx := Nil
	
	//| Carrega dados do Listmark
	
	FOR nY := 1 to len(aDados)	   
		aLinVet	:= {}
		For nI := 1 To LEN(aHeader)
		   aadd(aLinVet,aDados[nY, nI])
		Next nI	                       
		
		aadd(aVetor,aLinVet)
	Next nY	                             
	    
	//| Dimensionamento da Janela
	
	aSize := MsAdvSize()   
	
	aObjects := {}
	aAdd( aObjects, { 100, 100, .T., .T. } )
	
	
	aInfo := { aSize[ 1 ], aSize[ 2 ], aSize[ 3 ], aSize[ 4 ], 3, 3 }
	aPosObj := MsObjSize( aInfo, aObjects )
	aPosEnc	:= {000,000,aPosObj[1,3]-aPosObj[1,1]-12,aPosObj[1,4]-aPosObj[1,2]-1}
	   
	aPosObj[1,3] -= 20
	
	DEFINE MSDIALOG oDlg TITLE cTitulo FROM aSize[7],00 to aSize[6],aSize[5] OF oMainWnd PIXEL
	//   " ", "Campos" ;   
	@ 000,000 LISTBOX oLbx VAR cVar FIELDS HEADER ;
	   " ", "Campos" ;
	   SIZE aPosObj[1,4],aPosObj[1,3] OF oDlg PIXEL ON dblClick(aVetor[oLbx:nAt,1] := !aVetor[oLbx:nAt,1],oLbx:Refresh())
	
	oLbx:aheaders := aHeader
	oLbx:BHEADERCLICK	:= { |oObj,nCol| U_CP0904H(oObj, nCol, lMarkb := !(lMarkb)) }		
	oLbx:SetArray( aVetor )  
	
	//| Cria string com Bloco de Codigo
	
	cBCodLin	:= "Iif(aVetor[oLbx:nAt,1],oOk,oNo)"
	For nI := 2 To LEN(aHeader)
	   cBCodLin	+= ", aVetor[oLbx:nAt,"+alltrim(str(nI))+"]"
	Next nI	
	
	cBCodLin	:= "oLbx:bLine := {|| {"+cBCodLin+"}}"
	&(cBCodLin)
	
	
	//| Para marcar e desmarcar todos os itens existentes
	
	@ (aPosObj[1,3]+5),05 CHECKBOX oChk VAR lChk PROMPT "Marca/Desmarca" SIZE 60,007 PIXEL OF oDlg ON CLICK(aEval(aVetor,{|x| x[1]:= lChk} ),oLbx:Refresh())
	
	DEFINE SBUTTON FROM (aPosObj[1,3]+5), (aPosObj[1,4]-40) TYPE 1 ACTION {|| Processa( { || CP09EXCL02(aCpoHeader,aVetor) }, ,"Excluindo movimenta็๕es..." ), oDlg:End()} ENABLE OF oDlg 	//| OK 
	DEFINE SBUTTON FROM (aPosObj[1,3]+5), (aPosObj[1,4]-80) TYPE 2 ACTION oDlg:End() ENABLE OF oDlg 		//| Cancela
	
	ACTIVATE MSDIALOG oDlg CENTER

Return 

/*/{Protheus.doc} CP09EXCL02
Monta um listmark para o usuแrio selecionar o que ele deseja
@author Fabio Sales | www.compila.com.br
@since 08/07/2017
@version 1.0
@param aListHead,A, Cont้m os titulos dos campos.
@param aLista,A, Cont้m os dados dos campos.
@example
(examples)
@see (links_or_references)
/*/


Static Function CP09EXCL02(aListHead, aLista)

	Local nI := 0
	Local nPosRec:= Ascan(aListHead, "R_E_C_N_O_")
		
	FOR nI := 1 TO Len(aLista)
	
		IF !aLista[nI,1]
	
			Loop
			
		Else
		
			//| Executa a exclusใo do Registro.
			
			DBSELECTAREA("ZB2")
			
			ZB2->(DBGOTO(aLista[nI,nPosRec]))
			
			Reclock("ZB2",.F.)
	
				ZB2->(dbDelete())
				
			ZB2->(MSUNLOCK())
		
		Endif
						
	Next nI

Return()





/*/{Protheus.doc} CP0904H
Orderna Coluna que o usuario realizar o click ou Marca/Desmarca todos os registros selecionados
ATENCAO: Necessairo declarar variavel "nColAnt" com private  
@author Augusto Ribeiro | www.compila.com.br
@since 28/01/2015
@version 1.0
@param oLbxAux, C, Objeto ListBox
@param nCol, N, Numero da Coluna
@param lMark, L, Marca ou Desmarca
/*/
//User Function CPXCPADH(oLbxAux, nCol, lMark)
User Function CP0904H(oLbxAux, nCol, lMark)
Local lMarkAll
Default lMark	:= .F.

If	nCol > 0

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Marca/Desmarca Registrios ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	IF !EMPTY(oLbxAux:aArray)
		If nCol == 1 .AND. lMark
		                   
			lMarkAll	:= !(oLbxAux:aArray[1,1])
	
			aEval(oLbxAux:aArray, {|x| x[1] := lMarkAll} )
			nColAnt := nCol			
		
		ELSEIF nCol == nColAnt
			aSort(oLbxAux:aArray,,,{ |x,y| x[nCol] < y[nCol] })
			nColAnt := 0
		Else
			aSort(oLbxAux:aArray,,,{ |x,y| x[nCol] > y[nCol] })
			nColAnt := nCol
		EndIf
	
		oLbxAux:Refresh()
	ENDIF
	
EndIf

Return()

