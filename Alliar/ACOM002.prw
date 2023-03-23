#Include "Protheus.Ch"
#Include "rwmake.Ch"
#Include "TopConn.Ch"
#INCLUDE 'FWMVCDEF.CH'
#INCLUDE "FWMBROWSE.CH"     


//#DEFINE aCpoCabec	{"ZN_GRUPO","ZN_PRODUTO"}
#DEFINE aCpoCabec	{"ZN_FILAUX"}

//| TABELA
#DEFINE D_ALIAS 'SZN'
#DEFINE D_TITULO 'Solicitantes'
#DEFINE D_ROTINA 'ACOM002'
#DEFINE D_MODEL 'SZNMODEL'
#DEFINE D_MODELMASTER 'SZNMASTER'
#DEFINE D_VIEWMASTER 'VIEW_SZN'


/* - FWMVCDEF
MODEL_OPERATION_INSERT para inclusใo;
MODEL_OPERATION_UPDATE para altera็ใo;
MODEL_OPERATION_DELETE para exclusใo.
*/

/*/{Protheus.doc} ACOM002

@author Jonatas Oliveira | www.compila.com.br
@since 12/12/2018
@version 1.0
/*/
User function ACOM002()
Local oBrowse
     
Private lDesOper	:= .F.
Private lDesAmbi	:= .F.

oBrowse := FWMBrowse():New()
oBrowse:SetAlias(D_ALIAS)
oBrowse:SetDescription(D_TITULO)

oBrowse:Activate()

Return(NIL)

        
/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ CP11003  บAutor  ณAugusto Ribeiro     บ Data ณ 12/12/2013  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ 	Botoes do MBrowser                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/  
Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE 'Pesquisar'  ACTION 'PesqBrw'             OPERATION 1 ACCESS 0
ADD OPTION aRotina TITLE 'Visualizar' ACTION 'VIEWDEF.'+D_ROTINA OPERATION 2 ACCESS 0                         
ADD OPTION aRotina TITLE 'Incluir'  ACTION 'VIEWDEF.'+D_ROTINA OPERATION 3 ACCESS 0  	
ADD OPTION aRotina TITLE 'Alterar'    ACTION 'VIEWDEF.'+D_ROTINA OPERATION 4 ACCESS 0
ADD OPTION aRotina TITLE 'Excluir'    ACTION 'VIEWDEF.'+D_ROTINA OPERATION 5 ACCESS 0
//ADD OPTION aRotina TITLE 'Copiar'     ACTION 'VIEWDEF.'+D_ROTINA OPERATION 9 ACCESS 0
ADD OPTION aRotina TITLE 'Imprimir'   ACTION 'VIEWDEF.'+D_ROTINA OPERATION 8 ACCESS 0
//ADD OPTION aRotina TITLE 'Legenda'  ACTION 'eval(oBrowse:aColumns[1]:GetDoubleClick())'             OPERATION 1 ACCESS 0



Return(aRotina)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ CP11003  บAutor  ณAugusto Ribeiro     บ Data ณ 12/12/2013  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ 	Definicoes do Model                                       บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/  
Static Function ModelDef()

// Cria a estrutura a ser usada no Modelo de Dados
Local oStruSZN := FWFormStruct( 1, D_ALIAS, { |cCampo| CPOCABEC(cCampo) } /*bAvalCampo*/,/*lViewUsado*/ )
Local oStItemSZN := FWFormStruct( 1, D_ALIAS, /*bAvalCampo*/,/*lViewUsado*/ )
Local oModel, nI  



/*------------------------------------------------------ Augusto Ribeiro | 12/10/2017 - 5:40:45 PM
	Altera inicializador Padrใo dos itens para nใo apresentar erro de campo
	obrigatorio nao preenchido
------------------------------------------------------------------------------------------*/
FOR nI := 1 to len(aCpoCabec)
	oStItemSZN:SetProperty(aCpoCabec[nI], MODEL_FIELD_INIT, FwBuildFeature(STRUCT_FEATURE_INIPAD, '"*"'))
NEXT nI



// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New(D_ROTINA+'MODEL',/*bPreValidacao*/, /*{  |oModel| POSMODEL( oModel ) }*/,{  |oModel| GRVDADOS( oModel ) }  , {||RollbackSX8(), .T.} )

// Adiciona ao modelo uma estrutura de formulแrio de edi็ใo por campo
oModel:AddFields( 'SZNMASTER', /*cOwner*/, oStruSZN, /*bPreValidacao*/ { |oModel, nLine, cAction, cField| PRELZZA(oModel, nLine, cAction, cField) }, /*bPosValidacao*/, /*bCarga*/ )
oModel:AddGrid( 'SZNITENS', 'SZNMASTER', oStItemSZN, /* { |oModel, nLine, cAction, cField| PRELZZA(oModel, nLine, cAction, cField) } */ , /*{ |oModel, nLine, cAction, cField| POSLZZA(oModel, nLine, cAction, cField) } bLinePost*/, /*bPreVal*/,	 /*bPosVal*/, /*BLoad*/ )

//oModel:SetRelation( 'ZA3VALEMP',	{{ 'ZA3_FILIAL', 'ZA1_FILIAL' }, { 'ZA3_CODIGO', 'ZA1_CODIGO' } , { 'ZA3_REV', 'ZA1_REV' }},"ZA3_FILIAL+ZA3_CODIGO+ZA3_REV" )
oModel:SetRelation( 'SZNITENS',	{{ 'ZN_FILIAL', 'XFILIAL("SZN")' }/*, { 'ZN_GRUPO', 'ZN_GRUPO' }, { 'ZN_PRODUTO', 'ZN_PRODUTO' } */ },  SZN->( IndexKey( 1 ) ) )


// Liga o controle de nao repeticao de linha
oModel:GetModel( 'SZNMASTER' ):SetPrimaryKey( { 'ZN_FILIAL', 'ZN_GRUPO', 'ZN_PRODUTO'} )
//oModel:GetModel( 'ZAWITENS' ):SetUniqueLine( { 'ZAW_FILIAL', 'ZAW_CODIND' } )

//Se torna obrigat๓rio cont้udo da linha do Grid informado
//oModel:GetModel( 'SZNITENS' ):SetOptional(.T.)
//oModel:GetModel( 'ZAWITENS' ):SetOptional(.T.)

//Se torna a apenas visual o cont้udo da Linha do Grid informado
//oModel:GetModel( 'SZNMASTER' ):SetOnlyView ( .T. )   

// Adiciona a descricao do Modelo de Dados
oModel:SetDescription( D_TITULO )

// Liga o controle de nao repeticao de linha
//oModel:GetModel( 'SZNITENS' ):SetUniqueLine( { 'SZN_CODCTR','SZN_REVCTR','SZN_ITECTR' } )


//oStItemSZN:SetProperty( 'ZN_FILIAL' , MODEL_FIELD_WHEN   , {|| .T.})


// Liga a valida็ใo da ativacao do Modelo de Dados
//oModel:SetVldActivate( { |oModel,cAcao| U_FAT06VLD('MODEL_ACTIVE', oModel) } )

Return(oModel)

/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ CP11003  บAutor  ณAugusto Ribeiro     บ Data ณ 12/12/2013  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ 	Definicoes da View                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/  
Static Function ViewDef()
// Cria um objeto de Modelo de Dados baseado no ModelDef do fonte informado
Local oModel   := FWLoadModel( D_ROTINA )
// Para a interface (View) a fun็ใo FWFormStruct, traz para a estrutura os campos conforme o nํvel, uso ou m๓dulo. 
Local oStruSZN := FWFormStruct( 2, D_ALIAS,  { |cCampo| CPOCABEC(cCampo) })
Local oStItemSZN := FWFormStruct( 2, D_ALIAS, { |cCampo| !CPOCABEC(cCampo) })

Local oView, cOrdemCpo, nI
Local aCpoView 	:= {} 

 


// Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados serแ utilizado
oView:SetModel( oModel )

// Cria o objeto de Estrutura 


//Adiciona no nosso View um controle do tipo FormFields(antiga enchoice)
oView:AddField( D_VIEWMASTER , oStruSZN , D_MODELMASTER )
oView:AddGrid ( 'VIEW_SZNITEM'   , oStItemSZN , 'SZNITENS' )
//oView:AddGrid ( 'VIEW_ZAW'   , oStructZAW , 'ZAWITENS' )
                                                     
// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'SUPERIOR'  , 30   )    
oView:CreateHorizontalBox( 'INFERIOR'  , 70   )

//oView:CreateVerticalBox( 'LEFT_INF1'	, 48 , 'INFERIOR' )
//oView:CreateVerticalBox( 'RIGHT_INF'	, 52 , 'INFERIOR' )

// Relaciona o ID da View com o "box" para exibicao
oView:SetOwnerView( D_VIEWMASTER, 'SUPERIOR' )
oView:SetOwnerView( "VIEW_SZNITEM"  ,  'INFERIOR' )
//oView:SetOwnerView( "VIEW_ZAW" , 'RIGHT_INF' )

oView:AddIncrementField( 'VIEW_SZNITEM', 'ZN_ITEM' )

// Informa os titulos dos box da View
oView:EnableTitleView(D_VIEWMASTER,'Cabecalho')
oView:EnableTitleView('VIEW_SZNITEM','Itens')
//oView:EnableTitleView('VIEW_ZAW','Hist๓rico de indํces %')


//oView:SetFieldAction(  'SZN_ITECTR',  {  |oView,  cIDView,  cField,  xValue|  GITECTR(  oView,  cIDView, cField, xValue ) } )


oView:SetCloseOnOk({||.T.})


Return(oView)



/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ GRVDADOS  บAutor  ณAugusto Ribeiro    บ Data ณ 19/11/2013  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/  
Static Function GRVDADOS(oModel)
Local lRet	:= .T.
Local nOperation	:= oModel:GetOperation()
Local oModCabec	:= oModel:GetModel(D_MODELMASTER)
Local oModItem		:= oModel:GetModel('SZNITENS')
Local cCodTicket	:= ""
Local nI, nY


IF nOperation == 3 .OR. nOperation == 4
	FOR nI := 1 to oModItem:Length()
	
		oModItem:GoLine( nI )
		
		
		FOR nY := 1 TO LEN(aCpoCabec)	
			oModItem:LOADVALUE(aCpoCabec[nY], oModCabec:GetValue(aCpoCabec[nY]))	
		NEXT nY
	
	next nI
ENDIF


aRet	:= GRVMODEL(oModItem)


Return(lRet)



/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ POSMODEL  บAutor  ณAugusto Ribeiro    บ Data ณ 19/11/2013  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/  
Static Function POSMODEL(oModel)
Local lRet	:= .T.
Local nY, nAux
Local nOperation	:= oModel:GetOperation()


Return(lRet)



/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ GRVMODEL บAutor  ณAugusto Ribeiro     บ Data ณ 13/12/2013  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Grava dados da Model no banco                              บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/  
Static Function GRVMODEL(oObjeto)
Local aRet	:= {.F.,""}
Local nOperation := oObjeto:GetOperation()
Local cOldAlias	:= ""
Local bBefore,bAfter,nOperation,oSuperObjeto, bAfterSTTS
Local nY, nX, nLen, cAlias

bBefore 	:= {|| .T.}
bAfter		:= {|| .T.}
bAfterSTTS	:= {|| .T.}

cAlias	:= oObjeto:oFormModelStruct:GetTable()[FORM_STRUCT_TABLE_ALIAS_ID]

IF !EMPTY(cAlias)

	aRelation := oObjeto:GetRelation()
	aDados    := oObjeto:GetData()
	aStruct   := oObjeto:oFormModelStruct:GetFields()
	IF ALLTRIM(oObjeto:ClassName()) == "FWFORMGRID"
	
		If (nOperation == MODEL_OPERATION_INSERT) .OR. (nOperation == MODEL_OPERATION_UPDATE)
		
			For nY := 1 To Len(aDados)
				oObjeto:GoLine(nY)
				lLock     := .F.
				nNextOper := 0
				//--------------------------------------------------------------------
				//Verifica o tipo de atualicao ( Insert ou Update )
				//--------------------------------------------------------------------
				If aDados[nY][MODEL_GRID_ID] <> 0
					//--------------------------------------------------------------------
					//Verifica se uma das linhas foi atualizada
					//--------------------------------------------------------------------
					For nX := 1 To Len(aStruct)
						If aDados[nY][MODEL_GRID_DATA][MODEL_GRIDLINE_UPDATE][nX]
							lLock := .T.
							Exit
						EndIf
					Next nX
					If aDados[nY][MODEL_GRID_DELETE] .Or. lLock
						(cAlias)->(MsGoto(aDados[nY][MODEL_GRID_ID]))
						RecLock(cAlias,.F.)
						lLock     := .T.
					EndIf
					nNextOper := nOperation
					If aDados[nY][MODEL_GRID_DELETE]
						nNextOper := MODEL_OPERATION_DELETE
					EndIf
				Else				
					For nX := 1 To Len(aStruct)
						If aDados[nY][MODEL_GRID_DATA][MODEL_GRIDLINE_UPDATE][nX] .And. !aDados[nY][MODEL_GRID_DELETE]
							lLock     := .T.
							nNextOper := nOperation
							Exit
						EndIf
					Next nX
					If lLock
						//--------------------------------------------------------------------
						//Quando as estruturas sao da mesma tabela - Modelo 2
						//--------------------------------------------------------------------
						If (nY == 1 .And. cAlias == cOldAlias)
							RecLock(cAlias,.F.)
						Else
							RecLock(cAlias,.T.)
						EndIf
					EndIf
				EndIf
				If lLock
					//--------------------------------------------------------------------
					//Executa o bloco de c๓digo de Pre-atualiza็ใo
					//--------------------------------------------------------------------
					If !Empty(bBefore)
						(cAlias)->(Eval(bBefore,oObjeto,oObjeto:cID,cAlias))
					EndIf
					//--------------------------------------------------------------------
					//Verifica se a linha foi deletada
					//--------------------------------------------------------------------
					If aDados[nY][MODEL_GRID_DELETE]
						(cAlias)->(dbDelete())
					Else
						//--------------------------------------------------------------------
						//Efetua a gravacao dos campos                    
						//--------------------------------------------------------------------
						For nX := 1 To Len(aStruct)
							If aDados[nY][MODEL_GRID_DATA][MODEL_GRIDLINE_UPDATE][nX] .Or. aDados[nY][MODEL_GRID_ID] == 0
								If (cAlias)->(FieldPos(aStruct[nX][MODEL_FIELD_IDFIELD])) > 0
									(cAlias)->(FieldPut(FieldPos(aStruct[nX][MODEL_FIELD_IDFIELD]),aDados[nY][MODEL_GRID_DATA][MODEL_GRIDLINE_VALUE][nX]))
								EndIf
							EndIf
						Next nX
						If (cAlias)->(FieldPos(PrefixoCpo(cAlias)+"_FILIAL")) > 0 .And. nOperation == MODEL_OPERATION_INSERT .And. !Empty(xFilial(cAlias))
							(cAlias)->(FieldPut(FieldPos(PrefixoCpo(cAlias)+"_FILIAL"),xFilial(cAlias)))
						EndIf
						//--------------------------------------------------------------------
						//Efetua a gravacao das chaves estrangeiras       
						//--------------------------------------------------------------------
						For nX := 1 To Len(aRelation[MODEL_RELATION_RULES])
							oModel := Nil							
							If oObjeto:GetModel():GetIdField(aRelation[MODEL_RELATION_RULES][nX][MODEL_RELATION_RULES_TARGET],@oModel) == 0
								xValue := &(aRelation[MODEL_RELATION_RULES][nX][MODEL_RELATION_RULES_TARGET])
							Else								
								xValue := oModel:GetValue(aRelation[MODEL_RELATION_RULES][nX][MODEL_RELATION_RULES_TARGET])
							EndIf
							(cAlias)->(FieldPut(FieldPos(aRelation[MODEL_RELATION_RULES][nX][MODEL_RELATION_RULES_ORIGEM]),xValue))
						Next nX
						//--------------------------------------------------------------------
						//Efetua a gravacao do modelo 2                   
						//--------------------------------------------------------------------
						If (nY <> 1 .And. cAlias == cOldAlias)
							aOldDados := oSuperObjeto:GetData()
							For nX := 1 To Len(aOldDados)
								If aOldDados[nX][MODEL_DATA_UPDATE] .Or. (nOperation == MODEL_OPERATION_INSERT)
									If (cAlias)->(FieldPos(aOldDados[nX][MODEL_DATA_IDFIELD])) > 0
										(cAlias)->(FieldPut(FieldPos(aOldDados[nX][MODEL_DATA_IDFIELD]),aOldDados[nX][MODEL_DATA_VALUE]))
									EndIf
								EndIf
							Next nX						
						EndIf
					EndIf
					//--------------------------------------------------------------------
					//Efetua a gravacao do bloco de c๓digo de pos-valida็ใo
					//--------------------------------------------------------------------
					(cAlias)->(Eval(bAfter,oObjeto,oObjeto:cID,cAlias))
				EndIf
				//--------------------------------------------------------------------
				//Seleciona o modelos em que este ้ proprietแrio.
				//--------------------------------------------------------------------
				/*If nNextOper <> 0
					For nX := 1 To Len(aModel[MODEL_STRUCT_OWNER])
						ExFormCommit(aModel[MODEL_STRUCT_OWNER][nX],bBefore,bAfter,nNextOper,oObjeto)						
					Next nX
				EndIf*/
			Next nY


			aRet	:= {.T.,""}
			
			
		ELSE
						
			If oObjeto:ClassName()=="FWFORMGRID"
				//--------------------------------------------------------------------
				//Efetua a gravacao da estrutura FWFORMGRID
				//--------------------------------------------------------------------
				If !Empty(cAlias)
					For nY := 1 To Len(aDados)
						lLock     := .F.
						oObjeto:GoLine(nY)
						//--------------------------------------------------------------------
						//Verifica o tipo de atualicao ( Insert ou Update )
						//--------------------------------------------------------------------
						If aDados[nY][MODEL_GRID_ID] <> 0
							(cAlias)->(MsGoto(aDados[nY][MODEL_GRID_ID]))
							RecLock(cAlias,.F.)
							lLock     := .T.
						EndIf
						If lLock
							/*
							//--------------------------------------------------------------------
							//Seleciona o modelos em que este ้ proprietแrio.
							//--------------------------------------------------------------------
							For nX := 1 To Len(aModel[MODEL_STRUCT_OWNER])
								ExFormCommit(aModel[MODEL_STRUCT_OWNER][nX],bBefore,bAfter,nNextOper,oObjeto)
							Next nX
							//--------------------------------------------------------------------
							//Executa o bloco de c๓digo de Pre-atualiza็ใo
							//--------------------------------------------------------------------
							If !Empty(bBefore)
								(cAlias)->(Eval(bBefore,oObjeto,oObjeto:cID,cAlias))
							EndIf
							*/
							//--------------------------------------------------------------------
							//Efetua a gravacao dos campos                    
							//--------------------------------------------------------------------
							(cAlias)->(dbDelete())
							//--------------------------------------------------------------------
							//Efetua a gravacao do bloco de c๓digo de pos-valida็ใo
							//--------------------------------------------------------------------
							(cAlias)->(Eval(bAfter,oObjeto,oObjeto:cID,cAlias))
						EndIf
					Next nY
				EndIf	
			EndIf		
	
	
			aRet	:= {.T.,""}
		ENDIF
	
	ELSEIF ALLTRIM(oModCabec:ClassName())  == "FWFORMFIELDS"
		aRet[2] := "FWFORMFIELDS nao implementada." 
	ENDIF
ENDIF


Return(aRet)



/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ PRELZZA  บAutor  ณAugusto Ribeiro     บ Data ณ 13/12/2013  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Pre-Validacao                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/  
Static Function PRELZZA(oModel, nLine, cAction, cField)
Local lRet 		:= .T.
Local oModFull		:= oModel:GetModel()
Local nOperation := oModel:GetOperation()
Local oView

cAction := ALLTRIM(cAction)

IF nOperation == MODEL_OPERATION_INSERT 
	oModel:LoadValue("ZN_FILAUX ", XFILIAL("SZN"))
ENDIF 

//oModel:LoadValue("ZN_ITEM", STRZERO(oModel:GetLine(),3))

//IF cAction == 'CANSETVALUE' .AND. (nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE) 
//
//	IF EMPTY(oModel:GetValue("SZN_CODREF"))
//		oView	:= FWViewActive()
//
//		oModel:LoadValue("SZN_CODREF", oModFull:GetValue("SZNMASTER", "SZN_CODIGO"))
//		
//		/*
//		oModel:LoadValue("SZN_CODCTR", oModFull:GetValue("SZNMASTER", "SZN_CODCTR"))
//		//oModel:LoadValue("SZN_REVCTR", oModFull:GetValue("SZNMASTER", "SZN_REVCTR"))		
//		oModel:LoadValue("SZN_REVCTR", ZA2->ZA2_REV)
//		oModel:LoadValue("SZN_CODCLI", oModFull:GetValue("SZNMASTER", "SZN_CODCLI"))
//		oModel:LoadValue("SZN_LOJA", oModFull:GetValue("SZNMASTER", "SZN_LOJA"))		
//		oModel:LoadValue("SZN_UM", oModFull:GetValue("SZNMASTER", "SZN_UM"))
//		
//		//oModel:LoadValue("SZN_MANIF", oModFull:GetValue("SZNMASTER", "SZN_MANIF"))
//		oModel:LoadValue("SZN_PLACA", oModFull:GetValue("SZNMASTER", "SZN_PLACA"))
//		oModel:LoadValue("SZN_NOMMOT", oModFull:GetValue("SZNMASTER", "SZN_NOMMOT"))		
//		oModel:LoadValue("SZN_DTENT", oModFull:GetValue("SZNMASTER", "SZN_DTENT"))
//		oModel:LoadValue("SZN_HRENT", oModFull:GetValue("SZNMASTER", "SZN_HRENT"))		
//		oModel:LoadValue("SZN_DTSAI", oModFull:GetValue("SZNMASTER", "SZN_DTSAI"))
//		oModel:LoadValue("SZN_HRSAI", oModFull:GetValue("SZNMASTER", "SZN_HRSAI"))
//		
//		oModel:LoadValue("SZN_TIPCLI", oModFull:GetValue("SZNMASTER", "SZN_TIPCLI"))
//		oModel:LoadValue("SZN_CODORI", ZA2->ZA2_CODORI)
//		oModel:LoadValue("SZN_TARA", oModFull:GetValue("SZNMASTER", "SZN_TARA"))
//		oModel:LoadValue("SZN_TRANSP", oModFull:GetValue("SZNMASTER", "SZN_TRANSP"))
//		oModel:LoadValue("SZN_CODGER", oModFull:GetValue("SZNMASTER", "SZN_CODGER"))
//		oModel:LoadValue("SZN_BALENT", oModFull:GetValue("SZNMASTER", "SZN_BALENT"))
//		oModel:LoadValue("SZN_BALSAI", oModFull:GetValue("SZNMASTER", "SZN_BALSAI"))
//		oModel:LoadValue("SZN_CODSET", oModFull:GetValue("SZNMASTER", "SZN_CODSET"))
//		oModel:LoadValue("SZN_CODCIR", oModFull:GetValue("SZNMASTER", "SZN_CODCIR"))
//		oModel:LoadValue("SZN_PSSAI", oModFull:GetValue("SZNMASTER", "SZN_TARA"))
//		
//		oModel:LoadValue("SZN_CODNAT", oModFull:GetValue("SZNMASTER", "SZN_CODNAT"))		
//		oModel:LoadValue("SZN_LOTE", oModFull:GetValue("SZNMASTER", "SZN_LOTE"))
//		oModel:LoadValue("SZN_COTA", oModFull:GetValue("SZNMASTER", "SZN_COTA"))
//		
//		IF lDesOper
//			oModel:LoadValue("SZN_ORIREG", "2")
//		ELSEIF lDesAmbi
//			oModel:LoadValue("SZN_ORIREG", "4")		
//		ENDIF
//		
//		oModel:LoadValue("SZN_OBS", "")
//		*/
//		oView:Refresh()
//	ENDIF
//
//ELSEIF cAction == 'DELETE' //.AND.  EMPTY(oModel:GetValue("SZN_CODREF"))
//
//	ROLLBACKSX8()
//	
//ENDIF



Return(lRet)






/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ GITECTR  บAutor  ณAugusto Ribeiro     บ Data ณ 16/12/2013  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Preenche demais campos como Gatilho via SetFieldAction     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/  
Static Function GITECTR( oView,  cIDView, cField, xValue)
Local oModFull 	:= oView:GetModel()
Local oModItem 	:= oModFull:GetModel('SZNITENS')
Local cMsgAviso, nI, nY, nTotLen
Local aColsEmp		:= {}

 
IF ALLTRIM(cField) == "SZN_ITECTR"

	oModFull 	:= oView:GetModel()
	oModItem 	:= oModFull:GetModel('SZNITENS')	
	 
	oModItem:LoadValue("SZN_REVCTR", ZA2->ZA2_REV )
	oModItem:LoadValue("SZN_CODORI", ZA2->ZA2_CODORI )
	 
	aAreaZA2	:= ZA2->(GetArea())
	
	DBSELECTAREA("ZA2")
	ZA2->(DBSETORDER(1))
	IF ZA2->(DBSEEK(XFILIAL("ZA2")+oModFull:GetValue("SZNMASTER","SZN_CODCTR")+oModFull:GetValue("SZNMASTER","SZN_REVCTR")+ALLTRIM(xValue)))
		oModItem:LoadValue("SZN_CODGER", ZA2->ZA2_CODCLI )
		oModItem:LoadValue("SZN_LOJGER", ZA2->ZA2_LOJA )
		oModItem:LoadValue("SZN_NOMEGE", POSICIONE("SA1",1,XFILIAL("SA1")+ZA2->ZA2_CODCLI+ZA2->ZA2_LOJA,"A1_NOME") )		
		oModItem:LoadValue("SZN_CODPRO", ZA2->ZA2_CODPRO ) 			
		oModItem:LoadValue("SZN_PROD", POSICIONE("SB1",1,XFILIAL("SB1")+ZA2->ZA2_CODPRO,"B1_DESC") )		
		oModItem:LoadValue("SZN_CODORI",  ZA2->ZA2_CODORI)
		
		oModItem:LoadValue("SZN_UM", SZN->SZN_UM )
		oView:Refresh()	                                   
	ELSEIF !EMPTY(xValue)		
   		oModItem:LoadValue("SZN_CODGER", "" )
		oModItem:LoadValue("SZN_LOJGER", "" )
		oModItem:LoadValue("SZN_NOMEGE", "" )
		oModItem:LoadValue("SZN_CODPRO", "" )
		oModItem:LoadValue("SZN_PROD", "" )
		oModItem:LoadValue("SZN_CODORI", "" )
		
		oModItem:LoadValue("SZN_UM", "" )
	ENDIF 


	
	RestArea(aAreaZA2)
	
ENDIF

Return NIL 





/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ FAT05GAT  บAutor  ณAugusto Ribeiro     บ Data ณ 17/12/2013  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Gatilhos via SX7                                            บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/  
//User Function FAT05GAT(cField)
Static Function FAT05GAT(cField)
Local xRet
Local oModFull
Local oModItem
Local nValBase	 := 0

Default  cField := ""

IF 	cField == "SZN_TPCONV" .OR.;
	cField == "SZN_CONV"  .OR.;
	cField == "SZN_PSLIQ"
	
	xRet		:= 0
	
	oModFull	:= FwModelActive()
	oModItem	:= oModFull:GetModel("SZNITENS")

	
	nValBase := oModItem:GetValue("SZN_PSLIQ")
	
	IF !empty(nValBase) .AND. !empty(oModItem:GetValue("SZN_TPCONV")) .AND. !empty(oModItem:GetValue("SZN_CONV"))
	
	
		IF oModItem:GetValue("SZN_TPCONV") == "M"
			
			xRet	:= nValBase*oModItem:GetValue("SZN_CONV")
		
		ELSEIF oModItem:GetValue("SZN_TPCONV") == "D"
		
			xRet	:= nValBase/oModItem:GetValue("SZN_CONV")		

		ENDIF
		
		
		/* Caso alteracao na segunda unidade, 
		preenche SZN_PSLIQ via LoadValue para que nใo ocorra novamente a execu็ao
		dos gatilhos em Loop 
		IF cField == "SZN_PSSGUM"
			oModItem:LoadValue("SZN_PSLIQ") := xRet
			oView	:= FwViewActive()
			oView:Refresh()
		ENDIF
		*/
	ENDIF
	
ELSEIF 	cField == "SZN_PSSGUM"
	
	xRet		:= 0
	
	oModFull	:= FwModelActive()
	oModItem	:= oModFull:GetModel("SZNITENS")
		
	nValBase := oModItem:GetValue("SZN_PSSGUM")
	
	IF !empty(nValBase) .AND. !empty(oModItem:GetValue("SZN_TPCONV")) .AND. !empty(oModItem:GetValue("SZN_CONV"))
	
	
		IF oModItem:GetValue("SZN_TPCONV") == "M"
			
			xRet	:= nValBase/oModItem:GetValue("SZN_CONV")
		
		ELSEIF oModItem:GetValue("SZN_TPCONV") == "D"
		
			xRet	:= nValBase*oModItem:GetValue("SZN_CONV")			

		ENDIF
	ENDIF
Endif

Return(xRet)





/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ POSLZZA  บAutor  ณAugusto Ribeiro     บ Data ณ 28/04/2015  บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ POS-Validacao                             บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/  
Static Function POSLZZA(oModel, nLine, cAction, cField)
Local lRet 	   		:= .T.
Local oModFull		:= oModel:GetModel()
Local nOperation 	:= oModel:GetOperation()
Local oView

//cAction := ALLTRIM(cAction)

//oModel:LoadValue("SZN_CODIGO", oModFull:GetValue("SZNMASTER", "SZN_CODIGO"))
//oModel:LoadValue("SZN_ITEM", STRZERO(oModel:GetLine(),3))

IF nOperation == MODEL_OPERATION_INSERT .OR. nOperation == MODEL_OPERATION_UPDATE

	IF EMPTY(oModel:GetValue("SZN_ITECTR"))
		lRet := .F.
		Help(" ",1,"SZN_ITECTR",,"Item de contrato esta vazio. Campo de preenchimento obrigatorio" ,4,5)			
	ENDIF
	

	
ENDIF



Return(lRet)



/*/{Protheus.doc} CPOCABEC
(long_description)
@author Augusto Ribeiro | www.compila.com.br
@since 12/10/2017
@version version
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
Static Function CPOCABEC(cCampo)
Local lRet	:= .F.

Default cCampo	:= ""

cCampo	:= ALLTRIM(cCampo)


IF ASCAN(aCpoCabec, cCampo) > 0
	lRet	:= .T.
ENDIF
/*
IF cCampo == "SZN_CODIGO" .OR.;
	cCampo == "SZN_DESC"
	
	lRet	:= .T.

ENDIF

*/


Return(lRet)



//-------------------------------------------------------------------
/*/{Protheus.doc} A084Group()
Valid do campo AI_GRUPO
@author alexandre.gimenez
@since 26/08/2013
@version 1.0
@return lRet 
/*/
//-------------------------------------------------------------------
User Function AC2Group()
Local oModel := FWModelActive()
Local oSAI_GD := oModel:GetModel('SZNITENS')
Local cVar	:= oSAI_GD:GetValue('ZN_GRUPO')
Local lRet := .T.


If !Empty(cVar) .And. PadR('*',len(cVar)) <> cVar 
	lRet := ExistCpo("SBM",M->AI_GRUPO)
EndIf

Return lRet 



//-------------------------------------------------------------------
/*/{Protheus.doc} A084Prod()
Valid do campo AI_PRODUTO
@author alexandre.gimenez
@since 26/08/2013
@version 1.0
@return lRet 
/*/
//-------------------------------------------------------------------
User Function AC2Prod()

Local oModel := FWModelActive()
Local oSAI_GD := oModel:GetModel('SZNITENS')
Local cVar	:= oSAI_GD:GetValue('ZN_PRODUTO')
Local lRet	:= .T.

If !Empty(cVar) .And. PadR('*',len(cVar)) <> cVar
	dbSelectArea("SB1")
	dbSetOrder(1)
	If !dbSeek(xFilial()+cVar)
		HELP(" ",1,"REGNOIS")
		lRet := .F.
	EndIf
	// Verifica se o Registro esta Bloqueado.
	If lRet .And. !RegistroOk("SB1")
       lRet := .F.
	EndIf
EndIf
	
Return lRet
