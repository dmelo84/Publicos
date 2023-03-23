#Include 'Protheus.ch'
#Include "FWMVCDef.ch"

/*/{Protheus.doc} FSFATC02
Browse com os registros de Nota Fiscal de saída transmitidos para o sistema Pleres.
@type function
@author gustavo.barcelos
@since 17/02/2016
@version 1.0
/*/

User Function FSFATC02()

Local oBrowse 	:= FWMBrowse():New()

Private aRotina 	:= MenuDef()

oBrowse:SetAlias("SF2")
oBrowse:SetDescription("Documentos de Saída Pleres Transmitidos")
oBrowse:SetMenuDef("FSFATC02")
oBrowse:DisableDetails()
oBrowse:SetFilterDefault( "SF2->F2_FILIAL == '"+cFilAnt+"' " )
oBrowse:AddLegend( "F2_XINTPLE=='0' .OR. Empty(F2_XINTPLE)", "BR_BRANCO", "Documento de Saída Não Integrado" )
oBrowse:AddLegend( "F2_XINTPLE=='1'", "BR_AZUL", "Documento de Saída Integrado" )
oBrowse:AddLegend( "F2_XINTPLE=='2'", "BR_VERDE", "Autorização Integrada" )
oBrowse:AddLegend( "F2_XINTPLE=='3'", "BR_LARANJA", "Cancelamento Integrado" )
oBrowse:AddLegend( "F2_XINTPLE=='9'", "BR_VERMELHO", "Falha na Integracao" )

oBrowse:Activate()

Return(Nil)

/*/{Protheus.doc} ModelDef
(long_description)
@type function
@author gustavo.barcelos
@since 17/02/2016
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/

Static Function ModelDef()
Local oModel		:= MPFormModel():New('FSFATC02')
Local oStruct 	:= FWFormStruct(1,"SF2",{|cCampo| .f. } )

FSLerStrdX3(oStruct, "F2_FILIAL"	, "M",/*cTitulo*/,/*cDesc*/,/*cTipo*/,/*nTamaho*/,/*nDecimal*/,"","",/*cPicture*/,/*cIniPad*/,/*lVisual*/,/*lVirtual*/)
FSLerStrdX3(oStruct, "F2_DOC" 		, "M",/*cTitulo*/,/*cDesc*/,/*cTipo*/,/*nTamaho*/,/*nDecimal*/,"","",/*cPicture*/,/*cIniPad*/,.F.,.T.)
FSLerStrdX3(oStruct, "F2_SERIE"		, "M",/*cTitulo*/,/*cDesc*/,/*cTipo*/,/*nTamaho*/,/*nDecimal*/,"","",/*cPicture*/,/*cIniPad*/,/*lVisual*/,/*lVirtual*/)
FSLerStrdX3(oStruct, "F2_CLIENTE"	, "M",/*cTitulo*/,/*cDesc*/,/*cTipo*/,/*nTamaho*/,/*nDecimal*/,"","",/*cPicture*/,/*cIniPad*/,.F.,.T.)
FSLerStrdX3(oStruct, "F2_LOJA"		, "M",/*cTitulo*/,/*cDesc*/,/*cTipo*/,/*nTamaho*/,/*nDecimal*/,"","",/*cPicture*/,/*cIniPad*/,/*lVisual*/,/*lVirtual*/)
FSLerStrdX3(oStruct, "F2_EMISSAO"	, "M",/*cTitulo*/,/*cDesc*/,/*cTipo*/,/*nTamaho*/,/*nDecimal*/,"","",/*cPicture*/,/*cIniPad*/,/*lVisual*/,/*lVirtual*/)

oModel:AddFields('SF2MASTER',,oStruct) 
oModel:SetPrimaryKey({'F2_FILIAL','F2_DOC','F2_EMISSAO'})

Return(oModel)


/*/{Protheus.doc} ViewDef
(long_description)
@type function
@author gustavo.barcelos
@since 17/02/2016
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/

Static Function ViewDef()
Local oView 		:= FWFormView():New()
Local oModel		:= ModelDef()
Local oStruct 	:= FWFormStruct(2,"SF2") 
 
oView:SetModel(oModel)

FSLerStrdX3(oStruct, "F2_FILIAL"	, "V",/*cTitulo*/,/*cDesc*/,/*cTipo*/,/*nTamaho*/,/*nDecimal*/,"","",/*cPicture*/,/*cIniPad*/,.F.,.T.)
FSLerStrdX3(oStruct, "F2_DOC"		, "V",/*cTitulo*/,/*cDesc*/,/*cTipo*/,/*nTamaho*/,/*nDecimal*/,"","",/*cPicture*/,/*cIniPad*/,.F.,.T.)
FSLerStrdX3(oStruct, "F2_SERIE"		, "V",/*cTitulo*/,/*cDesc*/,/*cTipo*/,/*nTamaho*/,/*nDecimal*/,"","",/*cPicture*/,/*cIniPad*/,.F.,.T.)
FSLerStrdX3(oStruct, "F2_CLIENTE"	, "V",/*cTitulo*/,/*cDesc*/,/*cTipo*/,/*nTamaho*/,/*nDecimal*/,"","",/*cPicture*/,/*cIniPad*/,.F.,.T.)
FSLerStrdX3(oStruct, "F2_LOJA"		, "V",/*cTitulo*/,/*cDesc*/,/*cTipo*/,/*nTamaho*/,/*nDecimal*/,"","",/*cPicture*/,/*cIniPad*/,.F.,.T.)
FSLerStrdX3(oStruct, "F2_EMISSAO"	, "V",/*cTitulo*/,/*cDesc*/,/*cTipo*/,/*nTamaho*/,/*nDecimal*/,"","",/*cPicture*/,/*cIniPad*/,.F.,.T.)

oView:AddField('VIEW_SF2',oStruct,'SF2MASTER')
oView:CreateHorizontalBox('TELA',100)
oView:SetOwnerView('VIEW_SF2','TELA')

Return(oView)

/*/{Protheus.doc} MenuDef
(long_description)
@type function
@author gustavo.barcelos
@since 17/02/2016
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/

Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina TITLE 'Reprocessar' ACTION 'U_FSRepr()' OPERATION 2 ACCESS 0
ADD OPTION aRotina TITLE 'Visualizar' ACTION 'MC090Visual()' OPERATION 2 ACCESS 0
ADD OPTION aRotina TITLE "Log. Falha" ACTION "U_FSLog()" OPERATION 2 ACCESS 0
ADD OPTION aRotina TITLE "Legenda" ACTION "U_FSLegLog()" OPERATION 2 ACCESS 0

Return(aRotina)


/*/{Protheus.doc} FSLegLog
(long_description)
@type function
@author gustavo.barcelos
@since 17/02/2016
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/

User Function FSLegLog() 
      
     Local aLegenda := {} 
     aAdd( aLegenda, { "BR_BRANCO" 	,      "Documento de Saída Não Integrado" })
     aAdd( aLegenda, { "BR_AZUL" 		,      "Documento de Saída Integrado" })
     aAdd( aLegenda, { "BR_VERDE"     	,      "Autorização Integrada" })
     aAdd( aLegenda, { "BR_LARANJA"     	,      "Cancelamento Integrado" }) 
     aAdd( aLegenda, { "BR_VERMELHO"     	,      "Falha na Integracao" })    
     
     BrwLegenda( "Legenda da Integração de NF de saída com Sistema Pleres", "Legenda", aLegenda ) 

Return Nil 


/*/{Protheus.doc} FSLerStrdX3
Funcao para criar o arquivo temporario para impressao do relatorio
        
@author 		Alex Teixeira de Souza
@since 			11/09/2015
@version 		P12
@param			oObj   	- Objeto com estrutura metadados
                cCampo 	- Nome do campo que vai ser adicionado	
				cTipo	- Tipo de Objeto M=Model V=View
@obs  			Projeto PR140093010 - Req 01 
@return		oObj   	- Objeto com estrutura metadados
Alteracoes Realizadas desde a Estruturacao Inicial 
Data       Programador     Motivo 
/*/ 
//------------------------------------------------------------------

Static Function FSLerStrdX3(oObjStruc, cCampo, cTP,cTitulo,cDesc,cTipo,nTamanho,nDecimal,cValid,cF3,cPicture,cIniPad,lAltera,lVirtual)
Local cOrder := "00"
Local bValid

SX3->(DbSetOrder(2))
if SX3->(DbSeek(cCampo))


	Default cTitulo		:= Alltrim(SX3->(FIELDGET(FIELDPOS("X3_TITULO"))))
	Default cDesc		:= Alltrim(SX3->(FIELDGET(FIELDPOS("X3_DESCRIC"))))
	Default cTipo		:= Alltrim(SX3->(FIELDGET(FIELDPOS("X3_TIPO"))))
	Default nTamanho	:= SX3->(FIELDGET(FIELDPOS("X3_TAMANHO")))
	Default nDecimal	:= SX3->(FIELDGET(FIELDPOS("X3_DECIMAL")))
	Default cValid		:= Alltrim(SX3->(FIELDGET(FIELDPOS("X3_VALID"))))
	Default cF3 		:= Alltrim(SX3->(FIELDGET(FIELDPOS("X3_F3"))))
	Default cPicture	:= Alltrim(SX3->(FIELDGET(FIELDPOS("X3_PICTURE")))) 
	Default cIniPad		:= Alltrim(SX3->(FIELDGET(FIELDPOS("X3_RELACAO"))))
	DEfault lAltera		:= iif(Alltrim(SX3->(FIELDGET(FIELDPOS("X3_VISUAL")))) != "V",.T.,.F.)
	Default lVirtual	:= iif(Alltrim(SX3->(FIELDGET(FIELDPOS("X3_CONTEXT")))) == "V",.T.,.F.)
	
Endif	

if !Empty(Alltrim(cValid))
	bValid := &("{|| "+cValid+" }")
Else
	bValid := NIL
Endif		



Do Case
	
	Case cTP == "M"
		oObjStruc:AddField(;				//Ord. Tipo Desc.
		cTitulo, ;							//[01]  C   Nome do Campo
		cDesc, ;							//[02]  C   ToolTip do campo
		cCampo, ;							//[03]  C   Id do Field
		cTipo, ;							//[04]  C   Tipo do Campo
		nTamanho, ;							//[05]  N   Tamanho
		nDecimal, ;							//[06]  N   Decimal do campo
		bValid , ;      					//[07]  B   Code-block de validação do campo
		NIL  , ;      						//[08]  B   Code-block de validação When do campo
		NIL  , ;      						//[09]  A   Lista de valores permitido do campo
		.F.  , ;      						//[10]  L   Indica se o campo tem preenchimento obrigatório
		NIL  , ;      						//[11]  B   Code-block de inicializacao do campo
		NIL  , ;      						//[12]  L   Indica se trata-se de um campo chave
		NIL  , ;      						//[13]  L   Indica se o campo pode receber valor em uma operação de update.
		lVirtual  )    						 //[14]  L   Indica se o campo é virtual

	Case cTP == "V"
		
		//Pega a ultima ordem
		aEval( oObjStruc:aFields, { |aX| cOrder := IIf( aX[2] > cOrder, aX[2] , cOrder )  } )
		cOrder := StrZero(Val(cOrder)+5,2)

		oObjStruc:AddField( ;               // Ord. Tipo Desc.
		cCampo, ;							// [01]  C   Titulo do campo
		cOrder , ;      					// [02]  C   Ordem
		cTitulo , ;							// [03]  C   Titulo do campo
		cDesc, ;							// ade[04]  C   Descricao do campo
		{""},;  							//{cDesc}, ;							// [05]  C   Help do campo
		cTipo   , ;							// [06]  C   Tipo do Campo
		cPicture, ;							// [07]  C   Picture do Campo
		NIL  , ;      						// [08]  B   Bloco de Picture Var
		Alltrim(cF3)	, ;					// [09]  C   Consulta F3
		lAltera , ;     					// [10]  L   Indica se o campo é alteravel
		NIL , ;      						// [11]  C   Pasta do campo
		NIL, ;    							// [12]  C   Agrupamento do campo
		Nil	, ;      						// [13]  A   Lista de valores permitido do campo (Combo)
		NIL, ;      						// [14]  N   Tamanho maximo da maior opção do combo
		NIL, ;     							// [15]  C   Inicializador de Browse
		lVirtual  , ;						// [16]  L   Indica se o campo é virtual
		NIL, ;     							// [17]  C   Picture Variavel
		NIL)        						// [18]  L   Indica pulo de linha após o campo

EndCase


Return oObjStruc


/*/{Protheus.doc} FSRepr
Rotina responsável pelo reprocessamento do registro selecionado em tela.
@type function
@author gustavo.barcelos
@since 22/02/2016
@version 1.0
/*/

User Function FSRepr()

If ApMsgNoYes("Confirma ENVIO do retorno do faturamento ao solicitante?",".:Confirmação:.")
	U_FSFATP07()
	//U_FSFATP05()
EndIf

Return

/*/{Protheus.doc} FSLog
Rotina responsável por consultar o log do ultimo processamento e apresentar na tela
@type function
@author Julio Teixeira
@since 28/06/2021
@version 1.0
/*/
User Function FSLog()

Local cMsg := ""

dbSelectArea("ZJ1")
ZJ1->(DBSetOrder(1))
If ZJ1->(DbSeek("SF2"+cValToChar( SF2->(RECNO()) )))
	cMsg := ZJ1->ZJ1_MSGLOG
Else
	cMsg := "Nenhum log enconrtrado."
Endif

U_FSMosTxt(,cMsg)

Return
