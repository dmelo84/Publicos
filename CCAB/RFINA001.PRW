#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#Include 'Topconn.ch'
#Include 'TbiConn.ch'

#Define ATRASOS_SALDO		1
#Define ATRASOS_MOEDA		2
#Define ATRASOS_EMISSAO		3

Static __nOper 		:= 0 // Operacao da rotina
Static __Aprova     := .F. // Utilizado na aprovação do limite
Static __lFluig     := .F. // Chamado para aprovação pelo Fluig

/*
=====================================================================================
|Programa: RFINA001    |Autor: Marcos A. Montes                    |Data: 07/11/2019|
=====================================================================================
|Descrição: Rotina de manutenção do Calendário Safra / Grupo de Vendas              |
|                                                                                   |
=====================================================================================
|CONTROLE DE ALTERAÇÕES:                                                            |
=====================================================================================
|Programador          |Data       |Descrição                                        |
=====================================================================================
|Montes               |13/02/2020 |Quando aprovação do fluig já vira com a aprovação|
|                     |           |do gestor de credito junto. #MO20200213          |
|Montes               |24/04/2020 |Liberação do campo SAFRA2 e SAFRA3 para manuten- |
|                     |           |no gride de garantias Chamado #20200414000638    |
|Wanderley Neto       |07/05/2020 |Corrigindo limite calculado maior que a garantia |
|                     |           |Atualizando saldo em atraso                      |
|                     |           |Alterando tabela de safras para se basear nas ta-|
|                     |           |belas de preço.                                  |
=====================================================================================
*/
User Function RFINA001()

Local oBrowse	    := Nil
Local DsComCarteira := Nil
Local DsComGestor   := Nil
Local aColunas      := AvGetCpBrw("ZZH")
Local aCamposBrw    := {} 
Local nX            := 0
Local aParam 		:= {}


Private aRetPar		  := {}
Private aRotina		  := MenuDef()
Private aBKRECZZI     := {}
Private lFina001Auto  := .F.

AAdd(aParam, {1, 'Safra De', Replicate(' ',TamSX3('ZZH_SAFRA')[1]), '9999/9999','.T.',,'.T.',80,.F.})
AAdd(aParam, {1, 'Safra Ate', Replicate(' ',TamSX3('ZZH_SAFRA')[1]), '9999/9999','.T.',,'.T.',80,.F.})
AAdd(aParam, {1, 'Gestor', Replicate(' ',TamSX3('A1_XGESTOR')[1]), '@!','.T.','ZZN','.T.',80,.F.})

If Parambox(aParam, 'Filtro de calendários', @aRetPar)


	dbSelectArea('ZZH')
	ZZH->(dbSetOrder(1))

	//Monta array com as colunas para as Visões
	AADD(aCamposBrw,Nil) //Coluna de Legenda
	For nX := 1 To Len(aColunas)
	    AADD(aCamposBrw,aColunas[nX])
	Next

	/* 

	Atualiza saldo de cateira - Avaliar se ficará lento ao atualizar toda vez que entra na tela

	*/
	MsgRun("Atualizando saldo de carteira...", "Aguarde", {|| AtuCarteira() }) 

	oBrowse:= FWMBrowse():New()
	oBrowse:SetAlias('ZZH')
	oBrowse:SetDescription('Calendário Safra / Grupo de Vendas (GERAL)')
	oBrowse:SetMenuDef('RFINA001') // Indicamos ao Browse onde buscar os definições do menu. 
	oBrowse:SetAmbiente(.F.)
	//oBrowse:DisableLocate()
	//oBrowse:DisableReport()
	oBrowse:SetWalkThru(.F.)

	cFilter := "@("
	cFilter += "SELECT COUNT(*) FROM "+RetSqlName("ACY")+" ACY "
	cFilter += "INNER JOIN "+RetSqlName("SA1")+" SA1 ON A1_FILIAL = '"+xFilial("SA1")+"' AND A1_COD = ACY_XCODRP AND A1_LOJA = ACY_XLOJRP AND SA1.D_E_L_E_T_ = ' ' "
	cFilter += "WHERE ACY_FILIAL = '"+xFilial("ACY")+"' AND ACY_GRPVEN = ZZH_GRPVEN AND ACY.D_E_L_E_T_ = ' ' "
	If !Empty(AllTrim(aRetPar[1]))
		cFilter += "  AND ZZH_SAFRA >= '"+ AllTrim(aRetPar[1]) +"'"
	EndIf
	If !Empty(AllTrim(aRetPar[2]))
		cFilter += "  AND ZZH_SAFRA <= '"+ AllTrim(aRetPar[2]) +"'"
	EndIf
	If !Empty(AllTrim(aRetPar[3]))
		cFilter += "  AND A1_XGESTOR = '"+ AllTrim(aRetPar[3]) +"'"
	EndIf
	cFilter += ") > 0"
	oBrowse:SetFilterDefault(cFilter)

	// Inicio de Montagem das Views
	oTableAtt := FWTableAtt():New()
	oTableAtt:SetAlias("ZZH")

	DsComCarteira := FWDSView():New()
	DsComCarteira:SetID("DsComCarteira") 
	DsComCarteira:SetName("Calendários com pedidos bloqueados") 
	DsComCarteira:SetPublic(.T.)
	DsComCarteira:SetOrder(1) 
	DsComCarteira:SetCollumns(aCamposBrw)
	DsComCarteira:AddFilter( "Calendários com pedidos bloqueados", "!EMPTY(ZZH_CARTEI)" ) 
	oTableAtt:AddView(DsComCarteira)

	DsComGestor := FWDSView():New()
	DsComGestor:SetID("DsComGestor")
	DsComGestor:SetName("Calendários Aguardando Liberação dos Gestores")
	DsComGestor:SetPublic(.T.)
	DsComGestor:SetOrder(1)
	DsComGestor:SetCollumns(aCamposBrw)
	DsComGestor:AddFilter( "Calendários Aguardando Liberação dos Gestores", "ZZH_STATUS $ '2;3'" ) 
	oTableAtt:AddView(DsComGestor)

	oBrowse:SetAttach(.T.)
	oBrowse:SetViewsDefault(oTableAtt:aViews)
	// Fim definição das Views

	//Adiciona Legenda no Browse
	If ZZH->(FIELDPOS("ZZH_MSBLQL")) > 0
	   oBrowse:AddLegend( "ZZH_MSBLQL='1'"       , "BR_VERMELHO", "Registro Bloqueado" )
	EndIf
	oBrowse:AddLegend( "ZZH_STATUS$'1/ '"     , "BR_VERDE"   , "Limite Liberado" )
	oBrowse:AddLegend( "ZZH_STATUS='2'"       , "BR_AMARELO" , "Aguardando Liberação Gestor Regional" )
	oBrowse:AddLegend( "ZZH_STATUS='3'"       , "BR_AZUL"    , "Aguardando Liberação Gestor Crédito" )

	oBrowse:Activate()
EndIf

Return Nil

/*
=====================================================================================
|Programa: RFINA001    |Autor: Marcos A. Montes                    |Data: 07/11/2019|
=====================================================================================
|Descrição: Definição do menu da rotina de planejamento de transferencias           |
|                                                                                   |
=====================================================================================
*/
Static Function MenuDef()

Local aRotina		:= {}

ADD OPTION aRotina Title 'Visualizar'   Action 'VIEWDEF.RFINA001' OPERATION 2  ACCESS 0
ADD OPTION aRotina Title 'Incluir'  	Action 'VIEWDEF.RFINA001' OPERATION 3  ACCESS 0
ADD OPTION aRotina Title 'Alterar'  	Action 'VIEWDEF.RFINA001' OPERATION 4  ACCESS 0
//ADD OPTION aRotina Title 'Alterar'  	Action 'U_FI001VIEW(4)' OPERATION 4 ACCESS 0

//Verificar se ira permitir excluir Calendário pois ao fazer isto irá excluir todas as garantias 
//ADD OPTION aRotina Title 'Excluir'  	Action 'VIEWDEF.RFINA001' OPERATION 5  ACCESS 0  

If IsInCallStack("u_RFINA001") .And. (FWIsAdmin( __cUserID ) .Or. RetCodUsr() $ GETMV("MV_XUSAGAR",.F.,"")) 
	ADD OPTION aRotina Title 'Aprova Limite' Action 'U_FINA001A'       OPERATION 10  ACCESS 0
EndIf

ADD OPTION aRotina Title 'Gerar Excel'   Action 'U_CCABCPR'        OPERATION 6   ACCESS 0

ADD OPTION aRotina Title 'Conhecimento'  Action 'MSDOCUMENT'       OPERATION 4   ACCESS 0

If FWIsAdmin( __cUserID ) //Se usuário é administrador ou está no grupo Administradores	
	ADD OPTION aRotina Title 'Carga Inicial'  Action 'U_FINA001B'       OPERATION 4   ACCESS 0
EndIf

ADD OPTION aRotina Title 'Limpeza Previsão'  Action 'U_FINA001D'       OPERATION 4   ACCESS 0

Return aRotina

/*
=====================================================================================
|Programa: RFINA001    |Autor: Marcos Antonio Montes               |Data: 07/11/2019|
=====================================================================================
|Descrição: Definição do modelo de dados                                            |
|                                                                                   |
=====================================================================================
*/
Static Function ModelDef()

Local oModel		:= Nil
Local oStruZZH		:= FwFormStruct(1,'ZZH')
Local oStruZZ2G		:= FwFormStruct(1,'ZZ2',{|cCampo| .T. /*!AllTrim(cCampo)+"|" $ 'ZZ2_SAFRA2|ZZ2_SAFRA3|'*/ }) //#MO20200424
Local oStruZZI		:= FwFormStruct(1,'ZZI')

Local bFI001TOK		:= {|oMod| FI001TOK(oMod) }
Local bFI001COM		:= {|oMod| FI001COM(oMod) }

Local bPreZZH       := { |oModel, cAction, cField, xValue| ZZHPre( oModel, cAction, cField,xValue ) }
Local bPreZZ2       := { |oModel, nLine, cAction, cField, xValue, xOldValue| ZZ2LinPre( oModel, nLine, cAction, cField,xValue, xOldValue ) }
Local bPosZZ2       := { |oModel| ZZ2LinPos( oModel ) }

oStruZZ2G:AddTrigger( "ZZ2_TPREG", "ZZ2_DESGRP", {|| .T. },;
							 { |oModel| Posicione('ACY',1,xFilial('ACY')+oModel:GetValue("ZZ2_GRPVEN"),'ACY_DESCRI') } )

oModel := MPFormModel():New('MVCRFINA001',,bFI001TOK,bFI001COM,)

oModel:AddFields('ZZHMASTER',          ,oStruZZH, bPreZZH , /*bPost*/, /*bLoad*/)
oModel:AddGrid(  'ZZ2_GRID','ZZHMASTER',oStruZZ2G, bPreZZ2 /*blinePre*/, bPosZZ2/*blinePos*/,/*bPreVal*/,/*bPosVal*/,/*blinePre*/)   
oModel:AddGrid(  'ZZI_GRID','ZZHMASTER',oStruZZI,/*blinePre*/,/*blinePos*/,/*bPreVal*/,/*bPosVal*/,/*blinePre*/)   

oModel:SetPrimaryKey({'ZZH_FILIAL','ZZH_SAFRA','ZZH_GRPVEN'})

oModel:SetRelation('ZZ2_GRID', {{'ZZ2_FILIAL','xFilial("ZZ2")'},{'ZZ2_REVSAF','ZZH_SAFRA'},{'ZZ2_GRPVEN','ZZH_GRPVEN'}} )
oModel:SetRelation('ZZI_GRID', {{'ZZI_FILIAL','xFilial("ZZI")'},{'ZZI_REVSAF','ZZH_SAFRA'},{'ZZI_GRPVEN','ZZH_GRPVEN'}} )

// Definicao de linha sem duplicidade ZZ2
oModel:GetModel('ZZ2_GRID'):SetUniqueLine( {'ZZ2_REVSAF','ZZ2_GRPVEN','ZZ2_IDREG'} )

// Descrição do Modelo
oModel:SetDescription('Calendário Safra / Grupo de Vendas')

// Descrição do Modelo
oModel:GetModel('ZZHMASTER'):SetDescription('Calendário Safra / Grupo de Vendas')
oModel:GetModel('ZZ2_GRID'):SetDescription("Garantias")
oModel:GetModel('ZZI_GRID'):SetDescription("Histórico de Alterações")

oModel:GetModel('ZZ2_GRID'):SetOptional(.T.)

oModel:GetModel('ZZI_GRID'):SetOptional(.T.)
oModel:GetModel('ZZI_GRID'):SetDelAllLine(.F.)
oModel:GetModel('ZZI_GRID'):SetNoUpdateLine(.T.)
oModel:GetModel('ZZI_GRID'):SetNoInsertLine(.T.)
oModel:GetModel('ZZI_GRID'):SetNoDeleteLine(.T.)

//oStruZZ2G:SetProperty("*",MODEL_FIELD_WHEN,{||.F.})
oStruZZ2G:SetProperty("ZZ2_REVSAF",MODEL_FIELD_WHEN,{||.F.})
oStruZZ2G:SetProperty("ZZ2_GRPVEN",MODEL_FIELD_WHEN,{||.F.})
//oStruZZ2G:SetProperty("ZZ2_IDREG",MODEL_FIELD_WHEN,{||.F.})

oStruZZH:SetProperty("ZZH_LMBLOQ",MODEL_FIELD_WHEN,{||IIF(__nOper=10,.T.,.F.)})
oStruZZH:SetProperty("ZZH_MOTLM" ,MODEL_FIELD_WHEN,{||IIF(__nOper=10,.T.,.F.)})
oStruZZH:SetProperty("ZZH_STATUS",MODEL_FIELD_WHEN,{||__Aprova})
oStruZZH:SetProperty("ZZH_LIMDIS",MODEL_FIELD_WHEN,{||__Aprova})

Return oModel

/*
=====================================================================================
|Programa: RFINA001    |Autor: Marcos A. Montes                    |Data: 07/11/2019|
=====================================================================================
|Descrição: Definição da view do planejamento                                       |
|                                                                                   |
=====================================================================================
*/
Static Function ViewDef()

Local oView 			:= FwFormView():New()
Local oModel			:= FwLoadModel('RFINA001')
Local cFldCredito       := 'ZZH_SAFRA|ZZH_GRPVEN|ZZH_RATING|ZZH_CARTEI|ZZH_SLDPED|ZZH_SLDDUP|ZZH_DESCR|ZZH_DESCGR|ZZH_SALLIM|ZZH_SLDATS|ZZH_MOEDLC|ZZH_MSBLQL|ZZH_MOTIVO|ZZH_ACAO|ZZH_PREVLI|'
Local oStruZZH			:= FwFormStruct(2,'ZZH',{|cCampo| AllTrim(cCampo)+"|" $ cFldCredito})
Local oStruZZH2			:= FwFormStruct(2,'ZZH',{|cCampo| !AllTrim(cCampo)+"|" $ cFldCredito})
Local oStruZZ2G         := FWFormStruct(2,'ZZ2',{|cCampo| .T. /*!AllTrim(cCampo)+"|" $ 'ZZ2_SAFRA2|ZZ2_SAFRA3|'*/ }) //#MO20200424
Local oStruZZI			:= FwFormStruct(2,'ZZI')
Local oModZZ2G 
Local nX                := 0

// Define qual o Modelo de dados será utilizado na View
oView:SetModel( oModel )

// Adiciona no nosso View um controle do tipo formulário
// (antiga Enchoice)
oView:AddField( 'VIEW_ZZH'  , oStruZZH,  'ZZHMASTER' )
oView:AddField( 'VIEW_ZZH2' , oStruZZH2, 'ZZHMASTER' )

oView:AddGrid(  'VIEW_ZZ2G' , oStruZZ2G, 'ZZ2_GRID' ) 

oView:AddGrid(  'VIEW_ZZI'  , oStruZZI,  'ZZI_GRID' )

// Criar um "box" horizontal para receber algum elemento da view
//oView:CreateHorizontalBox( 'TELA' , 100 )
oView:CreateVerticallBox( "TELA", 100 )

// Agora vamos criar 'box' para suportar os componentes. Box é uma descrição genérica para Window, Panel, etc
oView:CreateHorizontalBox( 'SUPERIOR', 60, 'TELA' ) // ocupar 60% da tela 
oView:CreateHorizontalBox( 'INFERIOR', 40, 'TELA' ) // ocupar 40% da tela 

//Cria um Folder
oView:CreateFolder("PASTAS"   ,'INFERIOR')
oView:CreateFolder("PASTASCAB",'SUPERIOR')

//Cria as abas do Folder
oView:AddSheet("PASTAS"   ,"ABA_GAR"    ,"Garantia" )
oView:AddSheet("PASTAS"   ,"ABA_HIST"   ,"Histórico")
oView:AddSheet("PASTASCAB","ABA_CREDITO","Créditos" )
oView:AddSheet("PASTASCAB","ABA_OUTROS" ,"Outros"   )

oView:CreateVerticallbox( 'GARANTIAG',100,,,'PASTAS','ABA_GAR' ) 
oView:CreateHorizontalBox( 'HISTORICO',100,,,'PASTAS','ABA_HIST' ) 

oView:CreateVerticallbox( 'CREDITO',100,,,'PASTASCAB','ABA_CREDITO' ) 
oView:CreateVerticallbox( 'OUTROS' ,100,,,'PASTASCAB','ABA_OUTROS' ) 

// Relacionamos o Box criado ao objeto View
oView:SetOwnerView('VIEW_ZZH' ,'CREDITO')
oView:SetOwnerView('VIEW_ZZH2','OUTROS' )

oView:SetOwnerView('VIEW_ZZ2G','GARANTIAG') 
oView:SetOwnerView('VIEW_ZZI' ,'HISTORICO')

//Para mostrar os titulos dos grids
//oView:EnableTitleView('VIEW_ZZH')
//oView:EnableTitleView('VIEW_ZZ2G')
//oView:EnableTitleView('VIEW_ZZI')

oModZZ2G := oView:GetModel():GetModel("ZZ2_GRID")
For nX := 1 To Len(oModZZ2G:aHeader)

    oView:SetFieldAction( oModZZ2G:aHeader[nX][2]  ,{ |oView, cIDView, cField, xValue| FI001Vld(oView, cIDView, cField, xValue)} )

Next

oStruZZ2G:SetProperty('ZZ2_IDREG',MVC_VIEW_ORDEM,'01')  
oStruZZ2G:SetProperty('ZZ2_TPREG',MVC_VIEW_ORDEM,'02')
oStruZZ2G:SetProperty('ZZ2_CULTUR',MVC_VIEW_COMBOBOX,ListCultura())

oStruZZH:SetProperty('ZZH_SAFRA',MVC_VIEW_COMBOBOX,ListSafra())

// Definindo agrupamento da tela principal
oStruZZH:AddGroup( 'G01', ''		, '', 1 )
oStruZZH:AddGroup( 'G02', 'Acompanhamento'	, '', 2 )

oStruZZH:SetProperty('ZZH_SAFRA',	MVC_VIEW_GROUP_NUMBER, 'G01')
oStruZZH:SetProperty('ZZH_GRPVEN',	MVC_VIEW_GROUP_NUMBER, 'G01')
oStruZZH:SetProperty('ZZH_RATING',	MVC_VIEW_GROUP_NUMBER, 'G01')
oStruZZH:SetProperty('ZZH_CARTEI',	MVC_VIEW_GROUP_NUMBER, 'G01')
oStruZZH:SetProperty('ZZH_SLDPED',	MVC_VIEW_GROUP_NUMBER, 'G01')
oStruZZH:SetProperty('ZZH_SLDDUP',	MVC_VIEW_GROUP_NUMBER, 'G01')
oStruZZH:SetProperty('ZZH_DESCGR',	MVC_VIEW_GROUP_NUMBER, 'G01')
oStruZZH:SetProperty('ZZH_SALLIM',	MVC_VIEW_GROUP_NUMBER, 'G01')
oStruZZH:SetProperty('ZZH_SLDATS',	MVC_VIEW_GROUP_NUMBER, 'G01')
oStruZZH:SetProperty('ZZH_MOEDLC',	MVC_VIEW_GROUP_NUMBER, 'G01')
oStruZZH:SetProperty('ZZH_MSBLQL',	MVC_VIEW_GROUP_NUMBER, 'G01')

oStruZZH:SetProperty('ZZH_MOTIVO',	MVC_VIEW_GROUP_NUMBER, 'G02')
oStruZZH:SetProperty('ZZH_PREVLI',	MVC_VIEW_GROUP_NUMBER, 'G02')
oStruZZH:SetProperty('ZZH_ACAO',	MVC_VIEW_GROUP_NUMBER, 'G02')

aBKRECZZI := {}

If oModel:GetOperation() = 1 .And. __nOper <> 10 //Alteração e não for tela de Aprovação

   	oView:AddUserButton("Integ.Agrometrika","",{|oView| IntAgrome(oView) },"Efetua a integração com sistema Agrometrika.",,{4/*MODEL_OPERATION_UPDATE*/})

   	oView:AddUserButton("Calcula Limite","",{|oView| CalcLim(oView,) },"Efetua o calculo do Limite Clean e Disponivel.",,{4/*MODEL_OPERATION_UPDATE*/})

EndIf

oView:AddUserButton("Consulta Posição ","",{|oView| Posicao(oView) },"Consulta posição financeira do grupo economico.")

If oModel:GetOperation() = 1 .And. __nOper <> 10 //Alteração e não for tela de Aprovação

   	oView:AddUserButton("Imp.Gar.SAFRA Ant.","",{|oView| CriaRev(oView:GetModel():GetModel("ZZHMASTER"):GetValue("ZZH_GRPVEN")) },"Efetua importacao Garantias/CPR's da SAFRA anterior.",,{4/*MODEL_OPERATION_UPDATE*/})

EndIf

oView:SetAfterViewActivate({|oView|FI001Ava(oView)})

Return oView

///////////////////////////////
Static Function FI001Ava(oView)

Local oModZZH := Nil

If IsInCallStack('U_RFINA001') // #WN20200123
	oModZZH := oView:GetModel():GetModel("ZZHMASTER")
Else
	oModZZH := oView:GetModel("ZZHMASTER") // Chamadno a partir da integração, a variavel oView recebe o modelo //FwModelActive():GetModel("ZZHMASTER")
EndIf

If __nOper == 10

	//Grava Limite Disponivel com o Limite Calculado com base nas Garantias e libera o status
    If oModZZH:GetValue("ZZH_STATUS") $ "2/3"
	
        __Aprova := .T.

        //If __lFluig //#MO20200213
			oModZZH:SetValue("ZZH_LIMDIS",oModZZH:GetValue("ZZH_DISCAL"))
			oModZZH:SetValue("ZZH_LIMMAN",oModZZH:GetValue("ZZH_LMBLOQ"))
			oModZZH:SetValue("ZZH_STATUS","1") //Liberado        
		//Else
        //	If oModZZH:GetValue("ZZH_STATUS") == "2" //#MO20200213
		//		oModZZH:SetValue("ZZH_LIMDIS",oModZZH:GetValue("ZZH_DISCAL"))
		//  		oModZZH:SetValue("ZZH_STATUS","3") //Ag.Lib.Gestor Credito         
		//	ElseIf oModZZH:GetValue("ZZH_STATUS") == "3"
		//		oModZZH:SetValue("ZZH_LIMMAN",oModZZH:GetValue("ZZH_LMBLOQ"))
		//		oModZZH:SetValue("ZZH_STATUS","1") //Liberado        
		//	EndIf
		//EndIf
		oModZZH:SetValue("ZZH_DTLIMD",DATE())
		oModZZH:SetValue("ZZH_HRLIMD",TIME())

        __Aprova := .F.

    EndIf

EndIf

VerMotBlq("SE1") //#MO20200131
VerMotBlq("ZZH") //#MO20200129
VerMotBlq("ZZ2") //#MO20200129

If IsInCallStack("U_RFINA001")
	oView:Refresh()
EndIf

Return .T.

/*
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
+ Funcao: FI001Vld                Autor: Montes               Data: 22/11/2019 +
+ Uso: Funcao para Preenchimento de Campos nos Grids, a partir da digitação de +
+ um campo                                                                     +
+------------------------------------------------------------------------------+
+ Projeto: CCAB                                                                +
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
*/
Static Function FI001Vld(oView, cIDView, cField, xValue)

Local oModZZ2G := Nil // #WN20200124 - 
Local oModZZH  := Nil // #WN20200124 - 
Local lRFINA001	:= IsInCallStack('U_RFINA001')

If cIDView = "VIEW_ZZ2G"

	If lRFINA001
		oModZZ2G := oView:GetModel():GetModel("ZZ2_GRID")
		oModZZH  := oView:GetModel():GetModel("ZZHMASTER")
	ELse
		oModZZ2G := FwModelActive():GetModel("ZZ2_GRID")
		oModZZH  := FwModelActive():GetModel("ZZHMASTER")
	EndIf

    //Carga do campos de chave de relacionamento no Form a partir dos dados do FORM MASTER
	oModZZ2G:LoadValue("ZZ2_REVSAF",oModZZH:GetValue("ZZH_SAFRA"))
	oModZZ2G:LoadValue("ZZ2_GRPVEN",oModZZH:GetValue("ZZH_GRPVEN"))

    If RTRIM(cField) == "ZZ2_STATUS"

        /*
		//#MO20200124 transferido tratamento para função de pre-validação do campo da grid ZZ2
        // Alterou status da Garantia recalculada Limite Disponivel
		If xValue <> oModZZ2G:GetValue("ZZ2_STATUS") // TODO: Sempre o mesmo valor / // #WN20200122

            CalcLim(oView,xValue)
			
		EndIf
		*/
	EndIf

	If lRFINA001
		oView:Refresh()
	EndIf
EndIf

Return 

/*
=====================================================================================
|Programa: RFINA001    |Autor: Marcos A. Montes                    |Data: 07/11/2019|
=====================================================================================
|Descrição: Define validação ao confirmar atualização                               |
|                                                                                   |
=====================================================================================
*/

Static Function FI001TOK(oModel)

Local lRet 			:= .T.
//Local cModal		:= oModel:GetValue('MdFieldZZH','ZZH_MODALI')

/*
If oModel:GetOperation() <> 5 //MODEL_OPERATION_DELETE

	Do case
		Case cModal == '1'
			 lRet := !(Empty(oModel:GetValue('MdFieldZZF', 'ZZF_FILORI')) .Or. Empty(oModel:GetValue('MdFieldZZF', 'ZZF_FILDES')))
			 If !lRet
			    Help(,,'FI001TOK',, 'Filial origem ou destino inválido. Favor verificar.',1)
			 EndIf
		Case cModal == '2' 
			 lRet := !(Empty(oModel:GetValue('MdFieldZZF', 'ZZF_ARMORI')) .Or. Empty(oModel:GetValue('MdFieldZZF', 'ZZF_ARMDES')))
			 If !lRet
			    Help(,,'FI001TOK',, 'Armazém origem ou destino inválido. Favor verificar.',1)
			 EndIf
		Case cModal == '3'		
			 lRet := !(Empty(oModel:GetValue('MdFieldZZF', 'ZZF_DTDEST')))
			 If !lRet
			    Help(,,'FI001TOK',, 'Período "destino" inválido. Favor verificar.',1)
			 EndIf
	EndCase

EndIf
*/

Return lRet

/*
=====================================================================================
|Programa: RFINA001    |Autor: Marcos A. Montes                    |Data: 07/11/2019|
=====================================================================================
|Descrição: Define o bloco de consistencia do modelo de dados.                      |
|                                                                                   |
=====================================================================================
*/
Static Function FI001COM(oModel)

Local nOper	:= oModel:GetOperation()
Local lRet	:=  .F.
Local oView 	:= FWViewActive()


/*

Envio de e-mail de notificação para responsavel quando status igual a 2-Aguardando Aprovação.

-> Envia somente quando limite disponivel diferente do calculado, evitando enviar a cada toda alteração

*/
/*
//#MO20200206 Desabilitado envio de notificação de novo limite calculado 
If oModel:GetValue('ZZHMASTER','ZZH_STATUS')  == "2" .And. oModel:GetValue('ZZHMASTER','ZZH_LIMDIS') <> oModel:GetValue('ZZHMASTER','ZZH_DISCAL')

	cAssunto := "Novo limite calculado para o Grp.Economico "+oModel:GetValue('ZZHMASTER','ZZH_GRPVEN')+"-"+RTRIM(oModel:GetValue('ZZHMASTER','ZZH_DESCGR'))+" e Safra "+oModel:GetValue('ZZHMASTER','ZZH_SAFRA')+" aguardando aprovação."

	cBody := "-----------------------------------------------------------------------" + CRLF
	cBody += "    NOVO LIMITE DE CREDITO CALCULADO AGUARDANDO APROVAÇÃO DO GESTOR    " + CRLF
	cBody += "-----------------------------------------------------------------------" + CRLF
	cBody += CRLF
	cBody += "Grupo Economico: "+oModel:GetValue('ZZHMASTER','ZZH_GRPVEN')+"-"+oModel:GetValue('ZZHMASTER','ZZH_DESCGR')+CRLF
	cBody += "Safra: "+oModel:GetValue('ZZHMASTER','ZZH_SAFRA')+CRLF
	cBody += CRLF
	cBody += "Rating: "+oModel:GetValue('ZZHMASTER','ZZH_RATING')+CRLF
	cBody += CRLF
	cBody += "Limite Clean: "+TRANSFORM(oModel:GetValue('ZZHMASTER','ZZH_LIMCLE'),PesqPictQt("ZZH_LIMCLE",16))+CRLF
	cBody += CRLF
	cBody += "Limite Garantia:"+CRLF
	cBody += CRLF
	cBody += "  Atual    : "+TRANSFORM(oModel:GetValue('ZZHMASTER','ZZH_LIMDIS'),PesqPictQt("ZZH_LIMDIS",16))+CRLF
	cBody += CRLF
	cBody += "  Calculado: "+TRANSFORM(oModel:GetValue('ZZHMASTER','ZZH_DISCAL'),PesqPictQt("ZZH_DISCAL",16))+CRLF
	cBody += CRLF
	cBody += "Status: 2-Aguardando Aprovação"+CRLF
	cBody += CRLF

    envNotif(cAssunto,cBody)
	
	GravaHist("ZZH_STATUS",Nil,"Envio de notifição de necessidade de liberação de novo limite calculado.",)
EndIf
*/

If !IsBlind() .And. oView <> Nil //#MO20201116 #MO20201230
	CalcLim(oView,)
EndIf

DbSelectArea('ZZH')
lRet := FwformCommit(oModel)

If lRet

	If __nOper == 10 .And. oModel:GetValue('ZZHMASTER','ZZH_LIMMAN') > 0

		// -------------------------------------------------------------------------
		// Se for aprovado um limite temporário, uma notificação será enviada ao
		//  gestor da equipe de crédito
		// -------------------------------------------------------------------------
		EnvNotLT(oModel)

	EndIf

	If nOper == 3 //Inclusão

	    /*
		
		Atualiza campos acumulados
		
		*/
	    nSalDup := CalcDuplic(ZZH->ZZH_SAFRA,ZZH->ZZH_GRPVEN,ZZH->ZZH_MOEDLC)
		nSalPed := CalcPedLib(ZZH->ZZH_SAFRA,ZZH->ZZH_GRPVEN,ZZH->ZZH_MOEDLC)
		nSalAts := CalcDupAts(ZZH->ZZH_SAFRA,ZZH->ZZH_GRPVEN,ZZH->ZZH_MOEDLC)

		AtuSalDup(ZZH->ZZH_SAFRA,ZZH->ZZH_GRPVEN,"=",nSalDup,ZZH->ZZH_MOEDLC,dDataBase)
		AtuSalPed(ZZH->ZZH_SAFRA,ZZH->ZZH_GRPVEN,"=",nSalPed,ZZH->ZZH_MOEDLC,dDataBase)
		AtuSalAts(ZZH->ZZH_SAFRA,ZZH->ZZH_GRPVEN,"=",nSalAts,ZZH->ZZH_MOEDLC,dDataBase)
		AtuCarteira()

	EndIf

	If !Empty(ZZH->ZZH_RATING)
		// Atualiza Rating dos clientes do grupo
		AtuRatCli(ZZH->ZZH_SAFRA, ZZH->ZZH_GRPVEN, ZZH->ZZH_RATING)
	EndIf
	
EndIf

Return lRet

/*
=====================================================================================
|Programa: RFINA001    |Autor: Montes - Wikitec                    |Data: 07/11/2019|
=====================================================================================
|Descrição: Executa view com base na operação                                       |
|                                                                                   |
=====================================================================================
*/
User Function FI001VIEW(nOperation)

__nOper := nOperation

If nOperation == 5 //MODEL_OPERATION_DELETE

	//Help(,,'FI001VIEW',, 'Registro já sofreu baixa não pode ser excluído.',1)
       
ElseIf nOperation == 4 //MODEL_OPERATION_UPDATE

EndIf

// Visualizar, Incluir, Alterar
FWExecView( 'Calendário Safra / Grupo de Vendas' , 'RFINA001', nOperation )

__nOper := 0

Return Nil

///////////////////////////////////////////////
Static Function VerCalend(cSafra,cGrpVen,lCria)

Local aArea   := GETAREA()
Local lReturn := .F.
Local nSalDup := 0
Local nSalPed := 0

Default lCria := .F.

dbSelectArea("ZZH")
lReturn := dbSeek(xFilial("ZZH")+cSafra+cGrpVen)
If !lReturn .And. lCria

   RecLock("ZZH",.T.)
   ZZH->ZZH_FILIAL := xFilial("ZZH")
   ZZH->ZZH_SAFRA  := cSafra
   ZZH->ZZH_GRPVEN := cGrpVen
   ZZH->ZZH_DESCGR := POSICIONE("ACY",1,xFilial("ACY")+cGrpVen,"ACY_DESCRI")
   ZZH->ZZH_DTINCL := dDataBase
   ZZH->ZZH_MOEDLC := VAL(GETMV("MV_MCUSTO"))
   MsUnLock()

   nSalDup := CalcDuplic(ZZH->ZZH_SAFRA,ZZH->ZZH_GRPVEN,ZZH->ZZH_MOEDLC)
   nSalPed := CalcPedLib(ZZH->ZZH_SAFRA,ZZH->ZZH_GRPVEN,ZZH->ZZH_MOEDLC)
   nSalAts := CalcDupAts(ZZH->ZZH_SAFRA,ZZH->ZZH_GRPVEN,ZZH->ZZH_MOEDLC)

   AtuSalDup(ZZH->ZZH_SAFRA,ZZH->ZZH_GRPVEN,"=",nSalDup,ZZH->ZZH_MOEDLC,dDataBase)
   AtuSalPed(ZZH->ZZH_SAFRA,ZZH->ZZH_GRPVEN,"=",nSalPed,ZZH->ZZH_MOEDLC,dDataBase)
   AtuSalAts(ZZH->ZZH_SAFRA,ZZH->ZZH_GRPVEN,"=",nSalAts,ZZH->ZZH_MOEDLC,dDataBase)

EndIf

RestArea(aArea)

Return lReturn

///////////////////////////////////////
//Posicionar no Calendario de Safra / Grupo de Vendas (ZZH) e diminuir ou aumentar o saldo de duplicata
// cOper = "-", "+" ou "="
// campo ZZH_SLDDUP
// Chamada externa:     StaticCall(RFINA001,AtuSAlDup,cSafra,cGrpVen,cOper,nValor)
//                       Ex.: StaticCall(RFINA001,AtuSAlDup,SE1->E1_XSAFRA,SA1->A1_GRPVEN,"+",SE1->E1_VALOR)
///////////////////////////////////////
User Function RF001ASD(cSafra,cGrpVen,cOper,nValor,nMoeda,dEmissao)

AtuSalDup(cSafra,cGrpVen,cOper,nValor,nMoeda,dEmissao)

Return Nil

Static Function AtuSalDup(cSafra,cGrpVen,cOper,nValor,nMoeda,dEmissao)

If VerCalend(cSafra,cGrpVen)

    nValor := xMoeda(nValor,nMoeda,ZZH->ZZH_MOEDLC,dEmissao,2)

	Reclock("ZZH",.F.)
	If cOper == "+"
		ZZH->ZZH_SLDDUP += nValor
    ElseIf cOper == "-"
		ZZH->ZZH_SLDDUP -= nValor
	ElseIf cOper == "="
		ZZH->ZZH_SLDDUP := nValor
	EndIf
	MsUnLock()

EndIf

Return Nil

///////////////////////////////////////
//Posicionar no Calendario de Safra / Grupo de Vendas (ZZH) e diminuir ou aumentar o saldo de pedido liberado
// cOper = "-", "+" ou "="
// campo ZZH_SLDPED
///////////////////////////////////////
User Function RF001ASP(cSafra,cGrpVen,cOper,nValor,nMoeda,dEmissao)

AtuSalPed(cSafra,cGrpVen,cOper,nValor,nMoeda,dEmissao)

Return Nil

Static Function AtuSalPed(cSafra,cGrpVen,cOper,nValor,nMoeda,dEmissao)

If VerCalend(cSafra,cGrpVen)

    nValor := xMoeda(nValor,nMoeda,ZZH->ZZH_MOEDLC,dEmissao,2)

	Reclock("ZZH",.F.)
	If cOper == "+"
		ZZH->ZZH_SLDPED += nValor
    ElseIf cOper == "-"
		ZZH->ZZH_SLDPED -= nValor
	ElseIf cOper == "="
		ZZH->ZZH_SLDPED := nValor
	EndIf
	MsUnLock()

EndIf

Return Nil

///////////////////////////////////////
//Posicionar no Calendario de Safra / Grupo de Vendas (ZZH) e diminuir ou aumentar o saldo de Titulos em Atraso
// cOper = "-", "+" ou "="
// campo ZZH_SLDATS
///////////////////////////////////////
User Function RF001ASA(cSafra,cGrpVen,cOper,nValor,nMoeda,dEmissao)

Return AtuSalAts(cSafra,cGrpVen,cOper,nValor,nMoeda,dEmissao)

Static Function AtuSalAts(cSafra,cGrpVen,cOper,nValor,nMoeda,dEmissao)

If VerCalend(cSafra,cGrpVen)

    nValor := xMoeda(nValor,nMoeda,ZZH->ZZH_MOEDLC,dEmissao,2)

	Reclock("ZZH",.F.)
	If cOper == "+"
		ZZH->ZZH_SLDATS += nValor
    ElseIf cOper == "-"
		ZZH->ZZH_SLDATS -= nValor
	ElseIf cOper == "="
		ZZH->ZZH_SLDATS := nValor
	EndIf
	MsUnLock()

EndIf

Return nValor

///////////////////////////////////////////////////////////////////////////////////
// Atualiza o valor da carteira dos registros de Safra / Grupo de Vendas         //
///////////////////////////////////////////////////////////////////////////////////
Static Function AtuCarteira()

Local cScript := "" 
 
/*

#MO20200219 - inclusão dos pedidos de vendas gerados que ainda não fora liberado credito/faturado
#MO20200401 - inclusão de query para listar os calendarios com valores em carteira para comparação e zeramento

*/
cScript := "BEGIN TRANSACTION "+CRLF
cScript += "UPDATE "+RetSqlName("ZZH")+" SET ZZH_CARTEI = ROUND(TMPUPD.CARTCALC,2) "+CRLF
cScript += "FROM ( "+CRLF
cScript += "SELECT A1_GRPVEN,DA0_XSAFRA,SUM(CARTCALC) CARTCALC,ZZH_CARTEI,ZZH.R_E_C_N_O_ RECZZH "+CRLF
cScript += "FROM ( "+CRLF

//registro de calendário com saldo em carteira para comparação
cScript += "SELECT ZZH_GRPVEN A1_GRPVEN,ZZH_SAFRA DA0_XSAFRA,0 CARTCALC "+CRLF
cScript += "FROM "+RetSqlName("ZZH")+" ZZH "+CRLF
cScript += "WHERE ZZH_FILIAL = ' ' "+CRLF
cScript += "AND ZZH.D_E_L_E_T_ =  ' ' "+CRLF
cScript += "AND ZZH_CARTEI <> 0 "+CRLF

//soma total dos pré-pedidos
cScript += "UNION ALL "+CRLF
cScript += "SELECT A1_GRPVEN,DA0_XSAFRA,SUM(( (CASE WHEN Z2_MOEDA = ZZH_MOEDLC THEN Z3_VALOR "+CRLF
cScript += "                                        ELSE ROUND(Z3_VALOR*NULLIF(((CASE WHEN dbo.fn_xMoeda(Z2_EMISSAO,Z2_MOEDA) = 0 THEN 1 ELSE dbo.fn_xMoeda(Z2_EMISSAO,Z2_MOEDA) END)/(CASE WHEN dbo.fn_xMoeda(Z2_EMISSAO,ZZH_MOEDLC) = 0 THEN 1 ELSE dbo.fn_xMoeda(Z2_EMISSAO,ZZH_MOEDLC) END)),0),2)  END) /Z3_QTDVEN)*Z3_QTDPEN) CARTCALC "+CRLF
cScript += "FROM "+RetSqlName("SZ3")+" SZ3 "+CRLF
cScript += "INNER JOIN "+RetSqlName("SZ2")+" SZ2 ON Z2_FILIAL = Z3_FILIAL AND Z2_NUM = Z3_NUM AND SZ2.D_E_L_E_T_ = ' ' "+CRLF
cScript += "INNER JOIN "+RetSqlName("DA0")+" DA0 ON DA0_FILIAL = Z3_FILIAL AND DA0_CODTAB = Z3_XTABELA AND DA0.D_E_L_E_T_ = ' ' "+CRLF
cScript += "INNER JOIN "+RetSqlName("SA1")+" SA1 ON A1_FILIAL = Z3_FILIAL AND A1_COD = Z3_CLI AND A1_LOJA = Z3_LOJA AND SA1.D_E_L_E_T_ = ' ' "+CRLF
cScript += "INNER JOIN "+RetSqlName("ZZH")+" ZZH ON ZZH_FILIAL = '  ' AND ZZH_SAFRA = DA0_XSAFRA AND ZZH_GRPVEN = A1_GRPVEN AND ZZH.D_E_L_E_T_ = ' ' "+CRLF
cScript += "WHERE Z3_FILIAL = ' ' "+CRLF
cScript += "AND NOT Z3_BLQ IN ('C','R') "+CRLF
cScript += "AND A1_GRPVEN <> ' ' "+CRLF
cScript += "AND DA0_XSAFRA <> ' ' "+CRLF
cScript += "AND SZ3.D_E_L_E_T_ =  ' ' "+CRLF
cScript += "GROUP BY A1_GRPVEN,DA0_XSAFRA "+CRLF

//Soma dos pedidos pendentes para faturamento
cScript += "UNION ALL "+CRLF
cScript += "SELECT A1_GRPVEN,DA0_XSAFRA,SUM(((CASE WHEN C5_MOEDA = ZZH_MOEDLC THEN C6_VALOR "+CRLF
cScript += "                                       ELSE ROUND(C6_VALOR*NULLIF(((CASE WHEN dbo.fn_xMoeda(C5_EMISSAO,C5_MOEDA) = 0 THEN 1 ELSE dbo.fn_xMoeda(C5_EMISSAO,C5_MOEDA) END)/(CASE WHEN dbo.fn_xMoeda(C5_EMISSAO,ZZH_MOEDLC) = 0 THEN 1 ELSE dbo.fn_xMoeda(C5_EMISSAO,ZZH_MOEDLC) END)),0),2)  END) /C6_QTDVEN)*(C6_QTDVEN-C6_QTDENT)) CARTCALC "+CRLF
cScript += "FROM "+RetSqlName("SC6")+" SC6 "+CRLF
cScript += "INNER JOIN "+RetSqlName("SC5")+" SC5 ON C5_FILIAL = C6_FILIAL AND C5_NUM = C6_NUM AND SC5.D_E_L_E_T_ = '  ' "+CRLF
cScript += "INNER JOIN "+RetSqlName("SF4")+" SF4 ON F4_FILIAL = '   ' AND F4_CODIGO = C6_TES AND SF4.D_E_L_E_T_ = ' ' "+CRLF
cScript += "INNER JOIN "+RetSqlName("DA0")+" DA0 ON DA0_FILIAL = '  ' AND DA0_CODTAB = C6_XTABELA AND DA0.D_E_L_E_T_ = ' ' "+CRLF 
cScript += "INNER JOIN "+RetSqlName("SA1")+" SA1 ON A1_FILIAL = '  ' AND A1_COD = C6_CLI AND A1_LOJA = C6_LOJA AND SA1.D_E_L_E_T_ = ' ' "+CRLF
cScript += "INNER JOIN "+RetSqlName("ZZH")+" ZZH ON ZZH_FILIAL = '  ' AND ZZH_SAFRA = DA0_XSAFRA AND ZZH_GRPVEN = A1_GRPVEN AND ZZH.D_E_L_E_T_ = ' ' "+CRLF
cScript += "WHERE C6_FILIAL >= '   ' "+CRLF
cScript += "AND NOT C6_BLQ IN ('C','R') "+CRLF
cScript += "AND F4_XTESFAT = 'S' "+CRLF
cScript += "AND F4_DUPLIC = 'S' "+CRLF
cScript += "AND (C6_QTDVEN-C6_QTDENT) > 0 "+CRLF
cScript += "AND A1_GRPVEN <> ' ' "+CRLF
cScript += "AND DA0_XSAFRA <> ' ' "+CRLF
cScript += "AND SC6.D_E_L_E_T_ = ' ' "+CRLF
cScript += "GROUP BY A1_GRPVEN,DA0_XSAFRA "+CRLF

//Diminui os pedidos liberados em crédito
cScript += "UNION ALL "+CRLF
cScript += "SELECT A1_GRPVEN,DA0_XSAFRA,SUM((C9_QTDLIB*(CASE WHEN C5_MOEDA = ZZH_MOEDLC THEN C9_PRCVEN "+CRLF
cScript += "                                                 ELSE ROUND(C9_PRCVEN*NULLIF(((CASE WHEN dbo.fn_xMoeda(C5_EMISSAO,C5_MOEDA) = 0 THEN 1 ELSE dbo.fn_xMoeda(C5_EMISSAO,C5_MOEDA) END)/(CASE WHEN dbo.fn_xMoeda(C5_EMISSAO,ZZH_MOEDLC) = 0 THEN 1 ELSE dbo.fn_xMoeda(C5_EMISSAO,ZZH_MOEDLC) END)),0),2)  END)))*-1 CARTCALC "+CRLF
cScript += "FROM "+RetSqlName("SC9")+" SC9 "+CRLF
cScript += "INNER JOIN "+RetSqlName("SC6")+" SC6 ON C6_FILIAL = C9_FILIAL AND C6_NUM = C9_PEDIDO AND C6_ITEM = C9_ITEM AND SC6.D_E_L_E_T_ = ' ' "+CRLF
cScript += "INNER JOIN "+RetSqlName("SC5")+" SC5 ON C5_FILIAL = C6_FILIAL AND C5_NUM = C6_NUM AND SC5.D_E_L_E_T_ = '  ' "+CRLF
cScript += "INNER JOIN "+RetSqlName("SF4")+" SF4 ON F4_FILIAL = '   ' AND F4_CODIGO = C6_TES AND SF4.D_E_L_E_T_ = ' ' "+CRLF
cScript += "INNER JOIN "+RetSqlName("DA0")+" DA0 ON DA0_FILIAL = '  ' AND DA0_CODTAB = C6_XTABELA AND DA0.D_E_L_E_T_ = ' ' "+CRLF
cScript += "INNER JOIN "+RetSqlName("SA1")+" SA1 ON A1_FILIAL = '  ' AND A1_COD = C6_CLI AND A1_LOJA = C6_LOJA AND SA1.D_E_L_E_T_ = ' ' "+CRLF
cScript += "INNER JOIN "+RetSqlName("ZZH")+" ZZH ON ZZH_FILIAL = '  ' AND ZZH_SAFRA = DA0_XSAFRA AND ZZH_GRPVEN = A1_GRPVEN AND ZZH.D_E_L_E_T_ = ' ' "+CRLF
cScript += "WHERE C9_FILIAL >= '   ' "+CRLF
cScript += "AND C9_BLCRED = '  ' "+CRLF
cScript += "AND NOT C6_BLQ IN ('C','R') "+CRLF
cScript += "AND F4_XTESFAT = 'S' "+CRLF
cScript += "AND F4_DUPLIC = 'S' "+CRLF
cScript += "AND (C6_QTDVEN-C6_QTDENT) > 0 "+CRLF
cScript += "AND A1_GRPVEN <> ' ' "+CRLF
cScript += "AND DA0_XSAFRA <> ' ' "+CRLF
cScript += "AND SC9.D_E_L_E_T_ = ' ' "+CRLF
cScript += "GROUP BY A1_GRPVEN,DA0_XSAFRA "+CRLF 
cScript += ") TMP "+CRLF
cScript += "INNER JOIN "+RetSqlName("ZZH")+" ZZH ON ZZH_FILIAL = '  ' AND ZZH_SAFRA = DA0_XSAFRA AND ZZH_GRPVEN = A1_GRPVEN AND ZZH.D_E_L_E_T_ = ' ' "+CRLF

//cScript += "WHERE A1_GRPVEN = '000168' "+CRLF
//cScript += "AND DA0_XSAFRA = '2019/2020' "+CRLF
 
cScript += "GROUP BY A1_GRPVEN,DA0_XSAFRA,ZZH_CARTEI,ZZH.R_E_C_N_O_ "+CRLF
cScript += "HAVING ROUND(SUM(CARTCALC),2) <> ROUND(ZZH_CARTEI,2) "+CRLF
cScript += ") AS TMPUPD WHERE "+RetSqlName("ZZH")+".R_E_C_N_O_ = TMPUPD.RECZZH "+CRLF
cScript += "COMMIT"+CRLF

TCSQLEXEC(cScript) 

Return Nil

///////////////////////////////////////////////////////////////////////////////////
// Soma o total de titulos em aberto para a Safra / Grupo de Vendas              //
///////////////////////////////////////////////////////////////////////////////////
Static Function CalcDuplic(cSafra,cGrpVen,nMoedaLC)

Local nSalDup   := 0
Local cAliasTit := GetNextAlias()
Local cQuery    := " "
Local nDataConv := GETMV("MV_XDTCONV",.F.,0) //0-DataBase;1-Emissao - #MO20200629

cQuery := " "
cQuery += CRLF + "SELECT ISNULL(SUM(CASE WHEN E1_MOEDA = "+RTRIM(STR(nMoedaLC))+" THEN E1_SALDO "
cQuery += CRLF + "         ELSE ROUND(E1_SALDO*NULLIF(((CASE WHEN dbo.fn_xMoeda("+IIF(nDataConv=0,DTOS(dDataBase),"E1_EMISSAO")+",E1_MOEDA) = 0 THEN 1 ELSE dbo.fn_xMoeda("+IIF(nDataConv=0,DTOS(dDataBase),"E1_EMISSAO")+",E1_MOEDA) END)/(CASE WHEN dbo.fn_xMoeda("+IIF(nDataConv=0,DTOS(dDataBase),"E1_EMISSAO")+","+RTRIM(STR(nMoedaLC))+") = 0 THEN 1 ELSE dbo.fn_xMoeda("+IIF(nDataConv=0,DTOS(dDataBase),"E1_EMISSAO")+","+RTRIM(STR(nMoedaLC))+") END)),0),2) END),0) SALDUP "+CRLF
cQuery += CRLF + "FROM "+RetSqlName("SE1")+" SE1 "
cQuery += CRLF + "INNER JOIN "+RetSqlName("SC5")+" SC5 ON C5_FILIAL = E1_MSFIL AND C5_NUM = E1_PEDIDO AND SC5.D_E_L_E_T_ = ' ' "
cQuery += CRLF + "INNER JOIN "+RetSqlName("DA0")+" DA0 ON DA0_FILIAL = "+IIF(EMPTY(xFilial("DA0")),"'  '","E1_MSFIL")+" AND DA0_CODTAB = C5_TABELA AND DA0.D_E_L_E_T_ = ' ' "
cQuery += CRLF + "INNER JOIN "+RetSqlName("SA1")+" SA1 ON A1_FILIAL = "+IIF(EMPTY(xFilial("SA1")),"'  '","E1_MSFIL")+" AND A1_COD = E1_CLIENTE AND A1_LOJA = E1_LOJA AND SA1.D_E_L_E_T_ = ' ' "
cQuery += CRLF + "WHERE E1_FILIAL >= ' ' "
cQuery += CRLF + "AND E1_SALDO > 0 "
cQuery += CRLF + "AND E1_TIPO NOT IN ('RA ','NCC') "
cQuery += CRLF + "AND SE1.D_E_L_E_T_ = ' ' "
cQuery += CRLF + "AND A1_GRPVEN = '"+cGrpVen+"' "
cQuery += CRLF + "AND DA0_XSAFRA = '"+cSafra+"' "

dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasTit,.F., .F.)

TCSetField(cAliasTit, 'SALDUP','N',14,2)
                    
nSalDup := (cAliasTit)->SALDUP  
                    
(cAliasTit)->(dbCloseArea())

Return nSalDup

///////////////////////////////////////////////////////////////////////////////////
// Soma o total de titulos em atraso para a Safra / Grupo de Vendas              //
///////////////////////////////////////////////////////////////////////////////////
Static Function CalcDupAts(cSafra,cGrpVen,nMoedaLC)

Local nSalAts   := 0
Local cAliasTit := GetNextAlias()
Local cQuery    := " "
Local nDataConv := GETMV("MV_XDTCONV",.F.,0) //0-DataBase;1-Emissao - #MO20200629

cQuery := " "
cQuery += CRLF + "SELECT ISNULL(SUM(CASE WHEN E1_MOEDA = "+RTRIM(STR(nMoedaLC))+" THEN E1_SALDO "
cQuery += CRLF + "         ELSE ROUND(E1_SALDO*NULLIF(((CASE WHEN dbo.fn_xMoeda("+IIF(nDataConv=0,DTOS(dDataBase),"E1_EMISSAO")+",E1_MOEDA) = 0 THEN 1 ELSE dbo.fn_xMoeda("+IIF(nDataConv=0,DTOS(dDataBase),"E1_EMISSAO")+",E1_MOEDA) END)/(CASE WHEN dbo.fn_xMoeda("+IIF(nDataConv=0,DTOS(dDataBase),"E1_EMISSAO")+","+RTRIM(STR(nMoedaLC))+") = 0 THEN 1 ELSE dbo.fn_xMoeda("+IIF(nDataConv=0,DTOS(dDataBase),"E1_EMISSAO")+","+RTRIM(STR(nMoedaLC))+") END)),0),2) END),0) SALATS "+CRLF
cQuery += CRLF + "FROM "+RetSqlName("SE1")+" SE1 "
cQuery += CRLF + "INNER JOIN "+RetSqlName("SC5")+" SC5 ON C5_FILIAL = E1_MSFIL AND C5_NUM = E1_PEDIDO AND SC5.D_E_L_E_T_ = ' ' "
cQuery += CRLF + "INNER JOIN "+RetSqlName("DA0")+" DA0 ON DA0_FILIAL = "+IIF(EMPTY(xFilial("DA0")),"'  '","E1_MSFIL")+" AND DA0_CODTAB = C5_TABELA AND DA0.D_E_L_E_T_ = ' ' "
cQuery += CRLF + "INNER JOIN "+RetSqlName("SA1")+" SA1 ON A1_FILIAL = "+IIF(EMPTY(xFilial("SA1")),"'  '","E1_MSFIL")+" AND A1_COD = E1_CLIENTE AND A1_LOJA = E1_LOJA AND SA1.D_E_L_E_T_ = ' ' "
cQuery += CRLF + "WHERE E1_FILIAL >= ' ' "
cQuery += CRLF + "AND E1_SALDO > 0 "
cQuery += CRLF + "AND E1_TIPO NOT IN ('RA ','NCC') "
cQuery += CRLF + "AND SE1.D_E_L_E_T_ = ' ' "
cQuery += CRLF + "AND A1_GRPVEN = '"+cGrpVen+"' "
//cQuery += CRLF + "AND DA0_XSAFRA = '"+cSafra+"' " //Não considera safra conforme regra do PE MAAVCRED 
cQuery += CRLF + "AND E1_VENCTO < '"+DTOS(dDataBase)+"' "

dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasTit,.F., .F.)

TCSetField(cAliasTit, 'SALATS','N',14,2)
                    
nSalAts := (cAliasTit)->SALATS  
                    
(cAliasTit)->(dbCloseArea())

Return nSalAts

///////////////////////////////////////////////////////////////////////////////////
// Soma o total de pedidos liberados aptos a faturar da Safra / Grupo de Vendas  //
///////////////////////////////////////////////////////////////////////////////////
Static Function CalcPedLib(cSafra,cGrpVen,nMoedaLC)

Local nSalPed      := 0
Local cAliasPedLib := GetNextAlias()
Local cQuery       := " "

cQuery := " "
cQuery += CRLF + "SELECT ISNULL(SUM(CASE WHEN C5_MOEDA = "+RTRIM(STR(nMoedaLC))+" THEN (C9_QTDLIB*C9_PRCVEN) "
cQuery += CRLF + "         ELSE ROUND((C9_QTDLIB*C9_PRCVEN)*NULLIF(((CASE WHEN dbo.fn_xMoeda(C5_EMISSAO,C5_MOEDA) = 0 THEN 1 ELSE dbo.fn_xMoeda(C5_EMISSAO,C5_MOEDA) END)/(CASE WHEN dbo.fn_xMoeda(C5_EMISSAO,"+RTRIM(STR(nMoedaLC))+") = 0 THEN 1 ELSE dbo.fn_xMoeda(C5_EMISSAO,"+RTRIM(STR(nMoedaLC))+") END)),0),2) END),0) SALPED "+CRLF
cQuery += CRLF + "FROM "+RetSqlName("SC9")+" SC9 "
cQuery += CRLF + "INNER JOIN "+RetSqlName("SC5")+" SC5 ON C5_FILIAL = C9_FILIAL AND C5_NUM = C9_PEDIDO AND SC5.D_E_L_E_T_ = ' ' "
cQuery += CRLF + "INNER JOIN "+RetSqlName("DA0")+" DA0 ON DA0_FILIAL = "+IIF(EMPTY(xFilial("DA0")),"'  '","C9_FILIAL")+" AND DA0_CODTAB = C5_TABELA AND DA0.D_E_L_E_T_ = ' ' "
cQuery += CRLF + "INNER JOIN "+RetSqlName("SA1")+" SA1 ON A1_FILIAL = "+IIF(EMPTY(xFilial("SA1")),"'  '","C9_FILIAL")+" AND A1_COD = C5_CLIENTE AND A1_LOJA = C5_LOJACLI AND SA1.D_E_L_E_T_ = ' ' "
cQuery += CRLF + "WHERE C9_FILIAL >= ' ' "
cQuery += CRLF + "AND C9_BLEST = '  ' "
cQuery += CRLF + "AND C9_BLEST = '  ' "
cQuery += CRLF + "AND SC9.D_E_L_E_T_ = ' ' "
cQuery += CRLF + "AND A1_GRPVEN = '"+cGrpVen+"' "                   
cQuery += CRLF + "AND DA0_XSAFRA = '"+cSafra+"' " 

dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasPedLib,.F., .F.)
                    
TCSetField(cAliasPedLib, 'SALPED','N',14,2)
                    
nSalPed := (cAliasPedLib)->SALPED  
                    
(cAliasPedLib)->(dbCloseArea())

Return nSalPed


/////////////////////////////////////
Static Function CalcLim(oView,xValue)

Local oModZZ2G  := oView:GetModel():GetModel("ZZ2_GRID")
Local oModZZH   := oView:GetModel():GetModel("ZZHMASTER")
//Local cAssunto  := ""
//Local cBody     := ""
Local nX        := 0
Local lCropLine := .F. 
Local dCorteLCl	:= SuperGetMV('MV_XDTCLCN',,STod('20210520'))
Local nLimClean	:= 0

ACY->(dbSetOrder(1))
ACY->(dbSeek(xFilial("ACY")+oModZZH:GetValue("ZZH_GRPVEN")))
SA1->(dbSetOrder(1))
SA1->(dbSeek(xFilial("SA1")+ACY->ACY_XCODRP+ACY->ACY_XLOJRP))

lCropLine := ( SA1->A1_VEND == "000002" ) //CropLine

cRating   := oModZZH:GetValue("ZZH_RATING")

If lCropLine 
	// ------------------------------------------------------------------------------------------
	// Limite Clean da Cropline:
	//
	// Cada rating tem um percentual do LC que será liberado, assim como um teto máximo de 
	//  liberação. Segue a tabela em 07/2021 (Cham. 20210608001366):
	//
	// RATING	% DE LIB.				 TETO 
	// A		100		(MV_XPLCRAA)	 500K	(MV_XTLCRAA)
	// B		 75		(MV_XPLCRAB)	 300K	(MV_XTLCRAB)
	// C		 50		(MV_XPLCRAC)	 150K	(MV_XTLCRAC)
	// D		  0		(MV_XPLCRAD)	 -		(MV_XTLCRAD)
	// E		  0		(MV_XPLCRAE)	 -		(MV_XTLCRAE)
	// 
	// - -----------------------------------------------------------------------------------------

	If oModZZH:GetValue("ZZH_DTINCL") >= dCorteLCl

		// Considera o menor entre limite definido * % de liberação e o teto definido para o Rating
		nLimClean := Min((SuperGetMV("MV_XPLCRA"+RTRIM(cRating),,0)/100)*oModZZH:GetValue("ZZH_LIMPOT"),;				// Limite Potencial * % por rating
	   					 xMoeda(SuperGetMV("MV_XTLCRA"+RTRIM(cRating),,0),2,oModZZH:GetValue("ZZH_MOEDLC"),dDataBase) )	// Teto para o Rating
		

   	EndIf
	
Else

   /*
	CALCULO LIMITE CLEAN

    Parametro MV_XLCRTXX para definição do Limite Clean por Rating, onde XX é o Rating definido.      

    Rating       US$ Mil		Parametro
        AA        	150,0 		MV_XLCRTAA
        A         	100,0 		MV_XLCRTA
        B          	 75,0		MV_XLCRTB
        C      		 25,0		MV_XLCRTC
        D             0,0		MV_XLCRTD
        E             0,0		MV_XLCRTE
   */
	If oModZZH:GetValue("ZZH_DTINCL") >= dCorteLCl
		nLimClean := GetNewPar("MV_XLCRT"+RTRIM(cRating),0)	   
	EndIf

EndIf

// ------------------------------------------------------------------------------------------
// Limite clean é calculado pela regra no Protheus porém 
// é limitado pelo Clean definido no Agrometrika pelo gestor
// ------------------------------------------------------------------------------------------
nLimClean := Min(oModZZH:GetValue("ZZH_LIMCLE"),nLimClean)
oModZZH:LoadValue("ZZH_LIMCLE",nLimClean)

/*
   
	CALCULO LIMITE DISPONIVEL 

	ZZ2_STATUS
	X3_CBOX
        	1=Em Juridico;
			2=Em Assinat;
			3=Em Registro;
			4=Registrado;
			5=Baixado;
			6=Cancel;
			7=Pendente;
			8=Tramite;
			9=A Baixar;
			B=Validado             

    Parametro MV_XPGSTX para definição do valor do Limite da Garantia pelo Status definido, onde X é o Status.      

	STATUS PROTHEUS		STATUS POLÍTICA		%		PARAMETRO

	7-Pendente			Não formalizado		0		MV_XPGST7
	1=Em Juridico		Não formalizado		0		MV_XPGST1
	2=Em Assinatura   	Em formalização		20		MV_XPGST2
	3=Em Registro		Em registro			50		MV_XPGST3
	4=Registrado		Formalizado			100		MV_XPGST4
	8-Tramite		    Formalizado			100		MV_XPGST8
	B=Validado		    Formalizado			100		MV_XPGSTB
	9=A Baixar										MV_XPGST9
	5=Baixado										MV_XPGST5
	6=Cancelado										MV_XPGST6
*/

nLinAtu  := oModZZ2G:GetLine() //Salva linha atual #MO20200618
nLimDisp := 0

For nX := 1 To oModZZ2G:Length()
	oModZZ2G:SetLine(nX)
	If xValue <> Nil .And. nX == nLinAtu //Considerar valor digitado...
		cStatus := xValue
	Else
		cStatus := oModZZ2G:GetValue("ZZ2_STATUS")
	EndIf
	nPerGar := GetNewPar("MV_XPGST"+RTRIM(cStatus),NIL) 
	If nPerGar <> NIl
		//nLimDisp += ROUND(( oModZZ2G:GetValue("ZZ2_VALOR") * (nPerGar/100)),2) 
		nLimDisp += ROUND(( xMoeda(oModZZ2G:GetValue("ZZ2_VALOR"),2,oModZZH:GetValue("ZZH_MOEDLC"),dDataBase,2) * (nPerGar/100)),2)
	EndIf
Next
oModZZ2G:SetLine(nLinAtu) //Retorna linha atual #MO20200618

If nLimDisp <> oModZZH:GetValue("ZZH_LIMDIS")
	__Aprova := .T.
	oModZZH:SetValue("ZZH_DISCAL",nLimDisp) //Grava no calculado para apos liberação grava no ZZH_LIMDIS e liberar status
	oModZZH:SetValue("ZZH_STATUS","2")      //Bloqueado - Aguardando Aprovação
	__Aprova := .F.
EndIf

If !lFina001Auto
	oView:Refresh()
EndIf

Return


////////////////////////////////
Static Function IntAgrome(oView)

Local oRest
Local aHeader := {}
Local oObj
Local lSend    := .F.
//Local cJSON    := ""
Local cUrl     := GetNewPar("AGR_URLRST","https://homologacao.agrometrikaweb.com.br/APIv2/") 		
//Local oModZZ2G := oView:GetModel():GetModel("ZZ2_GRID")
Local oModZZH  := oView:GetModel():GetModel("ZZHMASTER")
Local cCNPJ    := ""
Local aCNPJ    := {}
Local nCNPJ    := 0
Local cCodERP  := ""
// #WN20200507
Local aSldAtr	:= {}
Local nTitulo	:= 0
Local cSafra	:= ''
Local cGrupo	:= ''
Local nP        := 0
Local cRetSAFRAS := '' 

//Local dCorteLCl	:= SuperGetMV('MV_XDTCLCN',,STod('20210520'))

dbSelectArea("ACY")
dbSetOrder(1)
If dbSeek(xFilial("ACY")+oModZZH:GetValue("ZZH_GRPVEN"))
	dbSelectArea("SA1")
	dbSetOrder(1)
	If dbSeek(xFilial("SA1")+ACY->ACY_XCODRP+ACY->ACY_XLOJRP)
       cCNPJ := RTRIM(SA1->A1_CGC)
	EndIf
EndIf

If EMPTY(cCNPJ)
   If !lFina001Auto
   		MsgInfo("Não encontrado CNPJ do responsavel para este Grupo de Vendas ("+oModZZH:GetValue("ZZH_GRPVEN")+") ! Verifique o cadastro de grupo de vendas/clientes.","Integração AGROMETRIKA")
   EndIf
   Return 
EndIf

aAdd(aHeader, 'Content-Type:application/json;charset=utf-8')
aAdd(aHeader, 'X-Authentication-Token:' + Alltrim(U_AUTRST(cEmpAnt,cFilAnt)))

oRest := FWRest():New(cUrl)

//Alterar para trazer os codigos ERP's - Montes - 30/08/2021
aCNPJ := TrazCNPJ(cCNPJ) //Retorna array com todos os CNPJs eCod.ERP cadastrados a partir da Raiz do CNPJ (8 primeiros digitos)

For nCNPJ := 1 To Len(aCNPJ)

	cCNPJ   := aCNPJ[nCNPJ][1]
	cCodERP := aCNPJ[nCNPJ][2]

	oRest:setPath("Cliente/LimitePorCodERP2Anos/"+cCodERP) //oRest:setPath("Cliente/Limite/"+cCNPJ)

	lSend := oRest:Get(aHeader)

	If lSend
		
		oObj := JsonObject():new()
		xRet := oObj:fromJson(oRest:cResult)

		If oObj["Salvo"] <> Nil .And. oObj["Salvo"] //SUCESSO

			lOk := .F.

			For nP := 1 To LEN(oObj["LimitesClientes"])		


				If oObj["LimitesClientes"][nP]["desSafra"] == LEFT(oModZZH:GetValue("ZZH_SAFRA"),5)+RIGHT(oModZZH:GetValue("ZZH_SAFRA"),2) 
					oModZZH:LoadValue("ZZH_LIMPOT",oObj["LimitesClientes"][nP]["valLimite"])
					oModZZH:LoadValue("ZZH_LIMCLE",oObj["LimitesClientes"][nP]["ValDisponivel"]) // Carrega limite clean (se for Cooperativa vai ser recalculado na CalcLim)
					oModZZH:LoadValue("ZZH_RATING",IIF(oObj["LimitesClientes"][nP]["ConceitoOriginal"]=Nil," ",oObj["LimitesClientes"][nP]["ConceitoOriginal"]))
					oModZZH:LoadValue("ZZH_DTAGRO",DATE())
					oModZZH:LoadValue("ZZH_HRAGRO",TIME())
					oModZZH:LoadValue("ZZH_MOEDLC",oObj["LimitesClientes"][nP]["codMoeda"])

					// Alterou Rating chama rotina para calculo do limite clean e tambem do disponivel. 
					CalcLim(oView,)
					lOk := .T.
					Exit
				EndIf

				cRetSAFRAS += oObj["LimitesClientes"][nP]["desSafra"] + "|"

			Next

			If lOk 
				If !lFina001Auto
					MsgInfo("Integrado com sucesso !","Integração AGROMETRIKA")
				EndIf
			Else
				If !lFina001Auto
					MsgInfo ("Proposta retornada não corresponde a Safra atual "+LEFT(oModZZH:GetValue("ZZH_SAFRA"),5)+RIGHT(oModZZH:GetValue("ZZH_SAFRA"),2)+", Safras retornadas "+cRetSAFRAS+", por favor verifique a ultima proposta disponivel no portal ! CNPJ "+cCNPJ,"Integração AGROMETRIKA")
				Else
					Conout('INTAGROME'+' - '+DToC(dDataBase)+' '+Time()+'| Proposta retornada não corresponde a Safra atual '+LEFT(oModZZH:GetValue("ZZH_SAFRA"),5)+RIGHT(oModZZH:GetValue("ZZH_SAFRA"),2)+', Safras retornadas '+cRetSAFRAS+', por favor verifique a ultima proposta disponivel no portal! CNPJ '+cCNPJ)
				EndIf
			EndIf

			Exit

		Else
			//FALHA (GRAVA ERRO)
			If !lFina001Auto .And. nCNPJ = Len(aCNPJ) //Apresenta mensagem somente no ultimo CNPJ
				MsgInfo("O seguinte erro foi retornado pelo serviço da AGROMETRIKA :" + CRLF + oObj["errosRequisicao"][1]["codErro"] + "-" + DecodeUtf8(oObj["errosRequisicao"][1]["descricaoErro"]),"Integração AGROMETRIKA")
			Else
				Conout('INTAGROME'+' - '+DToC(dDataBase)+' '+Time()+ "| O seguinte erro foi retornado pelo serviço da AGROMETRIKA :" + CRLF + oObj["errosRequisicao"][1]["codErro"] + "-" + DecodeUtf8(oObj["errosRequisicao"][1]["descricaoErro"]))
			EndIf
		EndIf
	Else
		If !lFina001Auto
			MsgInfo("Erro ao conectar no serviço da AGROMETRIKA ! CNPJ "+cCNPJ,"Integração AGROMETRIKA")
		else
			Conout('INTAGROME'+' - '+DToC(dDataBase)+' '+Time()+"| ERRO ao conectar no serviço da AGROMETRIKA! CNPJ "+cCNPJ)
		EndIf
		Exit
	EndIf
Next

// ------------------------------------------------------------------------------------------
// Calcula saldo atrasado 
// #WN20200507
// ------------------------------------------------------------------------------------------
cSafra := oModZZH:GetValue("ZZH_SAFRA")
cGrupo := oModZZH:GetValue("ZZH_GRPVEN")

u_RF001ASA(cSafra,cGrupo,'=',0,oModZZH:GetValue("ZZH_MOEDLC"),dDataBase) // Zera saldo atrasado
aSldAtr := BuscaSlAt(cSafra,cGrupo) // Busca os valores atrasados do grupo por data e moeda

For nTitulo := 1 To Len(aSldAtr)

	// Gera saldo atrasado e atualiza tela
	oModZZH:LoadValue('ZZH_SLDATS',oModZZH:GetValue('ZZH_SLDATS')+u_RF001ASA(cSafra,cGrupo,'+',aSldAtr[nTitulo,ATRASOS_SALDO],aSldAtr[nTitulo,ATRASOS_MOEDA],aSldAtr[nTitulo,ATRASOS_EMISSAO]))

Next nTitulo

Return

/*
=====================================================================================
|Programa: RFINA001    |Autor: Wanderley R. Neto                   |Data: 07/05/2020|
=====================================================================================
|Descrição: Busca os saldos em atrasado do grupo agrupando por moeda e data de emis-|
| sao do titulo                                                                     |
=====================================================================================
*/
Static Function BuscaSlAt(cSafra,cGrupo)

Local cAliasTmp	:= GetNextAlias()
Local cQuery	:= ''
Local aSaldos	:= {}
Local nDataConv := GETMV("MV_XDTCONV",.F.,0) //0-DataBase;1-Emissao - #MO20200629

cQuery += CRLF + "Select Sum(E1_SALDO) SALDO, E1_EMISSAO EMISSAO, E1_MOEDA MOEDA "
cQuery += CRLF + "  From " + RetSqlName('SE1')
cQuery += CRLF + " Where D_E_L_E_T_ = '' "
cQuery += CRLF + "   And E1_SALDO > 0 "
cQuery += CRLF + "   And E1_XSAFRA = '"+cSafra+"'"
cQuery += CRLF + "   And E1_CLIENTE in (Select A1_COD From "+RetSqlName('SA1')+" Where D_E_L_E_T_ = '' And A1_GRPVEN = '"+cGrupo+"')"
cQuery += CRLF + " Group by E1_EMISSAO,E1_MOEDA,E1_XSAFRA "

dbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasTmp,.F., .F.)

While (cAliasTmp)->( ! Eof() )

	AAdd(aSaldos, {;
		(cAliasTmp)->SALDO	,;	// ATRASOS_SALDO
		(cAliasTmp)->MOEDA	,;	// ATRASOS_MOEDA
		IIF(nDataConv=0,dDataBase,SToD((cAliasTmp)->EMISSAO)) ;	// ATRASOS_EMISSAO
	})

	(cAliasTmp)->( DbSkip() )
End

(cAliasTmp)->(dbCloseArea())

Return aSaldos

//////////////////////////////
Static Function Posicao(oView)

Local aArea    := GETAREA()
Local oModZZH  := oView:GetModel():GetModel("ZZHMASTER")

dbSelectArea("ACY")
dbSetOrder(1)
If dbSeek(xFilial("ACY")+oModZZH:GetValue("ZZH_GRPVEN"))
	dbSelectArea("SA1")
	dbSetOrder(1)
	If dbSeek(xFilial("SA1")+ACY->ACY_XCODRP+ACY->ACY_XLOJRP)

		//StaticCall(RFINC010,Fc010Con,"SA1",SA1->(RECNO()),2)
        U_RFC010CON("SA1",SA1->(RECNO()),2)

	Else

       	MsgInfo("Grupo economico sem representante informado ("+ACY->ACY_GRPVEN+"-"+RTRIM(ACY->ACY_DESCRI)+") ! Atualize o cadastro do Grupo Economico.","Posiçao por Grupo Economico")
	EndIf
EndIf

RestArea(aArea)

Return 


/*/{Protheus.doc} ZZHPre
Tratamento para form de digitação Garantia. 
@author Montes
@since  05/12/19
/*/
Static Function ZZHPre( oModZZH, cAction, cField , xValue )

Local xOldValue := Nil
//Local oView 	:= FWViewActive()
//Local oModel	:= FWModelActive()

/*
cAction
"CANSETVALUE" : valida se o submodelo pode ou não receber atribuição de valor.
"SETVALUE" : valida se o campo do submodelo pode receber aquele valor
*/
If cAction == "SETVALUE"

    xOldValue := oModZZH:GetValue(cField) 

    If !cField $ "ZZH_SAFRA|ZZH_MOTBLQ" 
	   GravaHist(cField,xValue,xOldValue,)
	EndIf

    If cField $ "ZZH_GRPVEN" 
		CriaRev(xValue)
	EndIf

    If !cField $ "ZZH_MOTBLQ" //#MO20200124 Não chama função se campo for o ZZH_MOTBLQ, evitar erro de overflow 
       VerMotBlq("ZZH")
    EndIf

EndIf

//If oView != Nil
//	oView:Refresh()
//EndIf

Return .T.

/*/{Protheus.doc} ZZ2LinPre
Tratamento para form de digitação Garantia. 
@author Montes
@since  05/12/19
/*/
Static Function ZZ2LinPre( oModZZ2, nLine, cAction, cField , xValue, xOldValue )
Local oView 	:= FWViewActive()
//Local oModel	:= FWModelActive()

/*
cAction
- "UNDELETE"
- "DELETE"
- "SETVALUE" : nesse caso, serão passados mais três parametros
*/
If cAction == "SETVALUE"

    cIdZZ2 := oModZZ2:GetValue("ZZ2_IDREG")

	GravaHist(cField,xValue,xOldValue,cIdZZ2)

	// Alterou status da Garantia recalcula Limite Disponivel #MO20200124 
	If cField == "ZZ2_STATUS" .And. xValue <> xOldValue 

        CalcLim(oView,xValue)

	EndIf

	VerMotBlq("ZZ2")

EndIf

//If oView != Nil
//	oView:Refresh()
//EndIf
	
Return .T.

/*/{Protheus.doc} ZZ2LinPos
Tratamento para form de digitação Garantia. 
@author Montes
@since  01/09/2021
/*/
Static Function ZZ2LinPos( oModZZ2, cAction )

Local lRet 			:= .T.

If !oModZZ2:IsDeleted()
    // Tornar obrigatorio os campos ZZ2_VALOR e ZZ2_REGIAO para tipo diferente de 7-ENDOSSO DPL
	If oModZZ2:GetValue("ZZ2_TPREG") <> '7'
		If lRet .And. EMPTY(oModZZ2:GetValue("ZZ2_VALOR"))
	    	HELP("",1,"OBRIGAT",,'O Campo VLR Ped. US$ (ZZ2_VALOR) não foi preenchido',1,0) 
			lRet := .F.
		EndIf
		If lRet .And. oModZZ2:GetValue("ZZ2_TPREG") <> '7' .And. EMPTY(oModZZ2:GetValue("ZZ2_REGIAO"))
	    	HELP("",1,"OBRIGAT",,'O Campo Reg. Cotação (ZZ2_REGIAO) não foi preenchido',1,0) 
			lRet := .F.
		EndIf
	EndIf
EndIf

Return lRet

/////////////////////////////////////////////////////////////////
Static Function GravaHist(cField,xValue,xOldValue,cIdZZ2)

Local oView   := Nil // #WN20200123
Local oModel  := FWModelActive()
Local oModZZI := oModel:GetModel():GetModel("ZZI_GRID")
Local cHist := cObs := ""
Local cTituloSX3
Local nRegZZI := Nil
Local nP := 0 

DEFAULT cIdZZ2 := SPACE(6)

If IsInCallStack('u_RFINA001')

	oView := FWViewActive()

Else
	aBKRECZZI := {}

EndIf

/*
SetOperation
1 - Visualização
3 - Inserção
4 - Atualização
5 - Exclusão
9 - Cópia
*/
If oModel:GetOperation() == 3 //MODEL_OPERATION_INSERT

    cHist := "Inclusão de novo calendário"
    cObs  := ""

Else

    //Inclusão de tratamento para gravação de mensagem de notificação no historico de alteração. 
    cObs := ""
	If xValue == Nil 
        cObs += xOldValue
	ElseIf xValue <> xOldValue
		cTituloSX3 := GetSx3Cache(cField,"X3_TITULO")

        If !EMPTY(GetSX3Cache(cField,"X3_CBOX")) 
    		aOpcoes := RetSX3Box(GetSX3Cache(cField,"X3_CBOX"),,,1)
			If (nSeek := Ascan( aOpcoes, {|x| x[2] == CVALTOCHAR(xOldValue)})) > 0
		      	xOldValue := aOpcoes[nSeek][1]
			EndIf
			If (nSeek := Ascan( aOpcoes, {|x| x[2] == CVALTOCHAR(xValue)})) > 0
		      	xValue := aOpcoes[nSeek][1]
			EndIf
        EndIf

		cObs += "Campo "+cTituloSX3+" Alterado de:"+CVALTOCHAR(xOldValue)+" para:"+CVALTOCHAR(xValue)+"."+CRLF
	EndIf

	If !EMPTY(cObs) 
	    If !EMPTY(cIdZZ2)
    	   cHist := "Alteração de Garantia"
		Else
		   If __nOper == 10
		      cHist := "Aprovação de Limite Disponível"
		   Else
		      cHist := "Alteração de calendário"
		   EndIf
	    EndIf
	EndIf

EndIf

If !EMPTY(cHist)

    nP := ASCAN(aBKRECZZI,{|x|x[1]==cIdZZ2})
    If nP = 0
	   AADD(aBKRECZZI,{cIdZZ2,Nil})
	   nP := LEN(aBKRECZZI)
    EndIf
	nRegZZI := aBKRECZZI[nP,2]
	
    // Atualiza GRID do Histórico
	oModZZI:SetNoInsertLine(.F.)
	oModZZI:SetNoUpdateLine(.F.)
	If nRegZZI <> NIl

		oModZZI:GoLine(nRegZZI)

        cObs := Alltrim(oModZZI:GetValue("ZZI_OBS"))+CRLF+cObs
      
	    If EMPTY(oModZZI:GetValue("ZZI_REVSAF")) .Or. EMPTY(oModZZI:GetValue("ZZI_GRPVEN"))  
        	oModZZI:LoadValue("ZZI_REVSAF"  ,oModel:GetValue('ZZHMASTER','ZZH_SAFRA'))
        	oModZZI:LoadValue("ZZI_GRPVEN"  ,oModel:GetValue('ZZHMASTER','ZZH_GRPVEN'))
		EndIf

		oModZZI:SetValue("ZZI_OBS"    ,cObs)
	Else
	
		oModZZI:GoLine(oModZZI:Length())
    	If !EMPTY(oModZZI:GetValue("ZZI_REVSAF")) //!oModZZI:IsInserted()
		   oModZZI:AddLine()
	    EndIf
		oModZZI:LoadValue("ZZI_FILIAL"  ,xFilial("ZZI"))
        oModZZI:LoadValue("ZZI_REVSAF"  ,oModel:GetValue('ZZHMASTER','ZZH_SAFRA'))
		If cField == "ZZH_GRPVEN"
           oModZZI:LoadValue("ZZI_GRPVEN"  ,xOldValue)
	    Else
           oModZZI:LoadValue("ZZI_GRPVEN"  ,oModel:GetValue('ZZHMASTER','ZZH_GRPVEN'))
		EndIf
		oModZZI:SetValue("ZZI_DTALT"  ,dDataBase)
		oModZZI:SetValue("ZZI_HRALT"  ,Time())
		oModZZI:SetValue("ZZI_USALT"  ,cUserName)
		oModZZI:SetValue("ZZI_HIST"   ,cHist)
		oModZZI:SetValue("ZZI_OBS"    ,cObs)
	   	oModZZI:SetValue("ZZI_IDZZ2"  ,cIdZZ2)
	EndIf
	oModZZI:SetNoInsertLine(.T.)		
	oModZZI:SetNoUpdateLine(.T.)

    aBKRECZZI[nP,2] := oModZZI:GetLine()

    //oView:Refresh()

EndIf


Return Nil

Static Function VerMotBlq(cTabela)

Local oModel	 := FWModelActive()
Local cMotBlq    := ""
Local cMotBlqOld := oModel:GetValue('ZZHMASTER', 'ZZH_MOTBLQ')
Local cTiposBlq  := ""
Local cAliasTit := GetNextAlias()

/*

Tratamento para manter os motivos anteriores

*/
If "1." $ cMotBlqOld
   cTiposBlq  += "1|"
EndIf
If "2." $ cMotBlqOld
   cTiposBlq  += "2|"
EndIf
If "3." $ cMotBlqOld
   cTiposBlq  += "3|"
EndIf
If "X." $ cMotBlqOld
   cTiposBlq  += "X|"
EndIf

/*

Atualiza campo de Motivo de Bloqueio - #MO24012020


Motivo do Bloqueio:
1.Sem análise de Crédito  (sem valor no campo limite de crédito (limite potencial); 
2.Garantia Pendente/ Em formalização (campo de Limite com base na garantia estiver zerado ou com valor menor que o valo do pedido bloqueado); 
3.Divida vencida (ter duplicatas com vencimento inferior a data da consulta); 
X.Outros

*/
If cTabela == "ZZH" 
	If EMPTY(oModel:GetValue('ZZHMASTER', 'ZZH_LIMPOT'))
      	cTiposBlq += "1|"
    Else 
	    cTiposBlq := STRTRAN(cTiposBlq,"1|","")
	EndIf
ElseIf cTabela == "ZZ2"
    If EMPTY(oModel:GetValue('ZZHMASTER', 'ZZH_LIMDIS'))
      	cTiposBlq += "2|"
    Else 
	    cTiposBlq := STRTRAN(cTiposBlq,"2|","")
	EndIf
ElseIf cTabela == "SE1"
	// -----------------------------------------------------------------------
	// Verificação de títulos vencidos.
	// -----------------------------------------------------------------------
	cQuery := " "
	cQuery += CRLF + "SELECT MIN(E1_VENCREA) VENCIMENTO "
	cQuery += CRLF + "FROM "+RetSqlName("SE1")+" SE1 "
	cQuery += CRLF + "INNER JOIN "+RetSqlName("SA1")+" SA1 ON A1_FILIAL = "+IIF(EMPTY(xFilial("SA1")),"'  '","E1_FILIAL")+" "
	cQuery += CRLF + "  AND A1_COD = E1_CLIENTE AND A1_LOJA = E1_LOJA AND SA1.D_E_L_E_T_ = ' ' "
	cQuery += CRLF + "WHERE SE1.D_E_L_E_T_ = ' ' "
	cQuery += CRLF + "AND E1_FILIAL >= '  ' "
	cQuery += CRLF + "AND E1_SALDO > 0 "
	cQuery += CRLF + "AND E1_TIPO NOT IN ('RA ','NCC') "
	cQuery += CRLF + "AND A1_GRPVEN = '"+oModel:GetValue('ZZHMASTER', 'ZZH_GRPVEN')+"' "                    
	cQuery += CRLF + "AND E1_VENCREA < '"+DTOS(dDataBase)+"' "

	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasTit,.F., .F.)

	TCSetField(cAliasTit, 'VENCIMENTO','D')
                    
	If (cAliasTit)->VENCIMENTO < dDataBase .AND. !EMPTY((cAliasTit)->VENCIMENTO)  
    	cTiposBlq += "3|"
    Else 
	    cTiposBlq := STRTRAN(cTiposBlq,"3|","")
	EndIf
                    
	(cAliasTit)->(dbCloseArea())
EndIf

/*

Monta campo de Motivos com base nos tipos de Bloqueios

*/
If "1" $ cTiposBlq
	cMotBlq += "1.Sem análise de Crédito"+CRLF
EndIf
If "2" $ cTiposBlq
	cMotBlq += "2.Garantia Pendente/ Em formalização"+CRLF
EndIf
If "3" $ cTiposBlq
	cMotBlq += "3.Divida vencida"+CRLF
EndIf
If "X" $ cTiposBlq
	cMotBlq += "X.Outros"+CRLF
EndIf

oModel:LoadValue('ZZHMASTER', 'ZZH_MOTBLQ',cMotBlq)

Return Nil


////////////////////////////////
Static Function CriaRev(cGrpVen)

Local aArea     := GETAREA()
Local oModel	:= FWModelActive()
//Local oModZZH   := oModel:GetModel():GetModel("ZZH_FORM")
Local oModZZ2G  := oModel:GetModel():GetModel("ZZ2_GRID") 
Local nX := 0 
Local cRevSaf   := oModel:GetValue('ZZHMASTER','ZZH_SAFRA')
Local cAliasRev := GetNextAlias()
Local dPerIni   := dPerFim := CTOD("")
Local aPeriodo  := {}

If oModZZ2G:Length() = 0 .Or. (oModZZ2G:Length() = 1 .And. EMPTY((oModZZ2G:GoLine(1),oModZZ2G:GetValue("ZZ2_CODCLI")))/*oModZZ2G:IsInserted()*/)

	cQuery := " "
	cQuery += CRLF + "SELECT ISNULL(MAX(ZZ2_REVSAF),'         ') ULTSAF "
	cQuery += CRLF + "FROM "+RetSqlName("ZZ2")+" ZZ2 "
	cQuery += CRLF + "WHERE ZZ2_FILIAL = '"+xFilial("ZZ2")+"' "
	cQuery += CRLF + "AND ZZ2_GRPVEN = '"+cGrpVen+"' "                   
	cQuery += CRLF + "AND ZZ2_REVSAF < '"+cRevSaf+"' "
	cQuery += CRLF + "AND ZZ2.D_E_L_E_T_ = ' ' "

	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasRev,.F., .F.)

	cUltSaf := (cAliasRev)->ULTSAF

	(cAliasRev)->(dbCloseArea())

	//dPerIni := CTOD("01/07/"+SUBSTRING(cRevSaf,1,4))
	//dPerFim := CTOD("30/06/"+SUBSTRING(cRevSaf,6,4))
	aPeriodo := PerSafra(cRevSaf)
	dPerIni := aPeriodo[1]
	dPerFim := aPeriodo[2]

	dbSelectArea("ZZ2")
	dbSetOrder(21) //ZZ2_FILIAL+ZZ2_REVSAF+ZZ2_GRPVEN+ZZ2_IDREG
	dbSeek(xFilial("ZZ2")+cUltSaf+cGrpVen)

	While !EOF() .And. ZZ2->ZZ2_GRPVEN == cGrpVen .And. ZZ2->ZZ2_REVSAF == cUltSaf

		If EMPTY(ZZ2->ZZ2_VENCIM) .Or. ZZ2->ZZ2_VENCIM >= dPerIni //(ZZ2->ZZ2_VENCIM >= dPerIni .And. ZZ2->ZZ2_VENCIM <= dPerFim) 
			oModZZ2G:GoLine(oModZZ2G:Length())
			If !oModZZ2G:IsInserted()
				oModZZ2G:AddLine()
			EndIf
			oModZZ2G:LoadValue("ZZ2_FILIAL"  ,xFilial("ZZ2"))
			oModZZ2G:LoadValue("ZZ2_GRPVEN"  ,cGrpVen)
			oModZZ2G:LoadValue("ZZ2_REVSAF"  ,cRevSaf)
			For nX := 1 To Len(oModZZ2G:aHeader)
				If !ALLTRIM(oModZZ2G:aHeader[nX][2]) $ "ZZ2_FILIAL/ZZ2_GRPVEN/ZZ2_REVSAF"
					oModZZ2G:LoadValue(oModZZ2G:aHeader[nX][2],ZZ2->(FIELDGET(FIELDPOS(oModZZ2G:aHeader[nX][2]))))
				EndIf
			Next
		EndIf

		ZZ2->(dbSkip())
	EndDo
	
	oModZZ2G:GoLine(1)

EndIf

RESTAREA(aArea)

Return

////////////////////////
User Function FINA001A(cSafra, cGrpVen, nLimTemp, cMotTemp,cMotcanc,cProvLib,cAcao)

Local  oModel	:= Nil
Local lContinua	:= .F.
Local cFilZZH	:= ''

Default cSafra		:= Nil
Default cGrpVen		:= Nil
Default nLimTemp	:= Nil

	__nOper      := 10
	cTitulo      := 'Aprova Limite de Credito Disponivel'
	cPrograma    := 'RFINA001'
	nOperation   := 4 //MODEL_OPERATION_UPDATE

	__lFluig := nLimTemp <> Nil .And. !IsInCallStack("U_RFINA001")
	
	If __lFluig

		Reset Environment
		Prepare Environment Empresa '01' Filial '01' TABLES ',ZZH,ZZ2,ZZI,' MODULO 'FIN'
		
		DbSelectArea('ZZH')
		cFilZZH := xFilial('ZZH')
		ZZH->(DbSetOrder(1)) // Safra + Grupo Vend

		lContinua := ZZH->( DbSeek( cFilZZH + cSafra + cGrpVen ) )

	EndIf

	oModel := FwLoadModel('RFINA001')

	oModel:GetModel('ZZ2_GRID'):SetDelAllLine(.F.)
	oModel:GetModel('ZZ2_GRID'):SetNoUpdateLine(.T.)
	oModel:GetModel('ZZ2_GRID'):SetNoInsertLine(.T.)
	oModel:GetModel('ZZ2_GRID'):SetNoDeleteLine(.T.)

	If !__lFluig
		nRet         := FWExecView( cTitulo , cPrograma, nOperation, /*oDlg*/, {|| .T. } ,{ |oModel| .T. } , /*nPercReducao*/, /*aEnableButtons*/, /*bCancel*/ , /*cOperatId*/, /*cToolBar*/, /*oModel*/ )
	Else

		If lContinua
			If ZZH->ZZH_STATUS $ '2/3' // Se estiver bloqueado
				oModel:SetOperation(nOperation)
				oModel:Activate()

				//If __lFluig //#MO20200213  cMotcanc,cProvLib,cAcao
					oModel:GetModel('ZZHMASTER'):LoadValue('ZZH_LMBLOQ'	,nLimTemp)
					oModel:GetModel('ZZHMASTER'):LoadValue('ZZH_MOTLM'	,cMotTemp)
					oModel:GetModel('ZZHMASTER'):LoadValue('ZZH_MOTIVO'	,cMotcanc)
					oModel:GetModel('ZZHMASTER'):LoadValue('ZZH_PREVLI'	,cProvLib)
					oModel:GetModel('ZZHMASTER'):LoadValue('ZZH_ACAO'	,cAcao)
				//Else
				//   	If ZZH->ZZH_STATUS $ '2' 
				//    	//oModel:GetModel('ZZHMASTER'):LoadValue('ZZH_LIMMAN',nLimTemp)
				//    	oModel:GetModel('ZZHMASTER'):LoadValue('ZZH_LMBLOQ',nLimTemp)
				//   	EndIf
				//EndIf
				FI001Ava(oModel)

				// --------------------------------------------
				// Consistindo o modelo
				// --------------------------------------------
				If oModel:VldData()
					If oModel:CommitData()

						Conout('RFINA001'+' - '+DToC(dDataBase)+' '+Time()+'| Aprovação via Fluig gravada com sucesso.')

					EndIf

				EndIf

				oModel:Deactivate()
			EndIf
		EndIf
		
		If __lFluig
			Reset Environment
		EndIf
	EndIf

	__nOper      := 0

	oModel:GetModel('ZZ2_GRID'):SetDelAllLine(.T.)
	oModel:GetModel('ZZ2_GRID'):SetNoUpdateLine(.F.)
	oModel:GetModel('ZZ2_GRID'):SetNoInsertLine(.F.)
	oModel:GetModel('ZZ2_GRID'):SetNoDeleteLine(.F.)

Return Nil

//////////////////////////////////
// Funcao: ListSafra
// Return: Retorna array com as safras conforme calendario contabil
//
// Parametro lX3CBOX igual a .T. retorna lista para utilizar no combo box
// X3_CBOX = #StaticCall(RFINA001,ListSafra,.T.)
//////////////////////////////////
Static Function ListSafra(lX3CBOX)

Local aArea     := GetArea()
Local aListBox  := {SPACE(9)}
Local cQuery    := " "
Local cAliasTmp := GetNextAlias()
Local cX3CBOX   := ""

Default lX3CBOX := .F.
   
cQuery := " "

// #WN20200507 - Substituindo safra do calendário contabil pelas safras informadas nas tabelas de preço

// cQuery += CRLF + "SELECT MIN(YEAR(CTG_DTINI)) ANO1,MAX(YEAR(CTG_DTFIM)) ANO2 " 
// cQuery += CRLF + "FROM "+RetSqlName("CTG")+" CTG "
// cQuery += CRLF + "WHERE CTG_FILIAL = '"+xFilial("CTG")+"' "
// cQuery += CRLF + "AND CTG.D_E_L_E_T_ = ' ' "
// cQuery += CRLF + "GROUP BY CTG_CALEND "
// cQuery += CRLF + "HAVING MIN(YEAR(CTG_DTINI)) <> MAX(YEAR(CTG_DTFIM)) "
// cQuery += CRLF + "ORDER BY 1 DESC "

cQuery += CRLF + " select distinct DA0_XSAFRA SAFRA"
cQuery += CRLF + "   from "+RetSqlName('DA0')
cQuery += CRLF + "  where D_E_L_E_T_ = ''"
cQuery += CRLF + "    and DA0_XSAFRA <> ''"

dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasTmp,.F., .F.)

dbGoTop()

While (cAliasTmp)->(!EOF())

    // AADD(aListBox,STRZERO((cAliasTmp)->ANO1,4)+"/"+STRZERO((cAliasTmp)->ANO2,4))
	AAdd(aListBox, AllTrim((cAliasTmp)->SAFRA))

	(cAliasTmp)->(dbSkip())
EndDo

(cAliasTmp)->(dbCloseArea())

RestArea(aArea)

If lX3CBOX
	cX3CBOX := ""
	//AEVAL(aListBox,{|x|cX3CBOX+=x+"="+x+";"})
	AEVAL(aListBox,{|x|cX3CBOX+=x+";"})
	If EMPTY(cX3CBOX)
		cX3CBOX := "2019/2020;"
	EndIf 
	Return cX3CBOX
EndIf

Return aListBox

/////////////////////////////
Static Function ListCultura()

Local aArea := GetArea()
Local aListBox := {SPACE(9)}
Local cQuery := " "
Local cAliasTmp := GetNextAlias()

cQuery := " "
cQuery += CRLF + "SELECT X5_DESCRI  " 
cQuery += CRLF + "FROM "+RetSqlName("SX5")+" SX5 "
cQuery += CRLF + "WHERE X5_FILIAL = '"+xFilial("SX5")+"' "
cQuery += CRLF + "AND SX5.X5_TABELA = 'ZH' "
cQuery += CRLF + "AND SX5.D_E_L_E_T_ = ' ' "
cQuery += CRLF + "ORDER BY 1 "

dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasTmp,.F., .F.)

dbGoTop()

While (cAliasTmp)->(!EOF())

    AADD(aListBox,PADR((cAliasTmp)->X5_DESCRI,TAMSX3("ZZ2_CULTUR")[1]))

	(cAliasTmp)->(dbSkip())
EndDo

(cAliasTmp)->(dbCloseArea())

RestArea(aArea)

Return aListBox


//////////////////////////////////
Static Function SaldoLim(lGatilho)

Local nSaldoLim := 0

DEFAULT lGatilho := .F.

If lGatilho
	If M->ZZH_LIMMAN > 0
   		nSaldoLim := M->ZZH_LIMMAN
	// ElseIf M->ZZH_LIMDIS > M->ZZH_LIMMAN 
	ElseIf M->ZZH_LIMDIS > M->ZZH_LIMCLE // #WN20200120 - Considerando Limite Clean na comparação
   		nSaldoLim := M->ZZH_LIMDIS
	Else
   		nSaldoLim := M->ZZH_LIMCLE
	EndIf

	nSaldoLim -= M->ZZH_SLDDUP
	nSaldoLim -= M->ZZH_SLDPED

	//Se saldo do Limite não pode ser maior que o potencial
	If !EMPTY(M->ZZH_LIMPOT) .And. nSaldoLim > M->ZZH_LIMPOT
   		nSaldoLim := M->ZZH_LIMPOT
	EndIf
Else
	If ZZH->ZZH_LIMMAN > 0
   		nSaldoLim := ZZH->ZZH_LIMMAN
	// ElseIf ZZH->ZZH_LIMDIS > ZZH->ZZH_LIMMAN 
	ElseIf ZZH->ZZH_LIMDIS > ZZH->ZZH_LIMCLE // #WN20200120 - Considerando Limite Clean na comparação
   		nSaldoLim := ZZH->ZZH_LIMDIS
	Else
   		nSaldoLim := ZZH->ZZH_LIMCLE
	EndIf

	nSaldoLim -= ZZH->ZZH_SLDDUP
	nSaldoLim -= ZZH->ZZH_SLDPED

	//Se saldo do Limite não pode ser maior que o potencial
	If !EMPTY(ZZH->ZZH_LIMPOT) .And. nSaldoLim > ZZH->ZZH_LIMPOT
   		nSaldoLim := ZZH->ZZH_LIMPOT
	EndIf
EndIf

Return nSaldoLim


/*
=====================================================================================
|Programa: envNotif    |Autor: Montes                              |Data: 18/12/2019|
=====================================================================================
|Descrição: Envia e-mail de notificação para responsaveis                           |
|                                                                                   |
|                                                                                   |
|MV_XEMLCRD - Email dos responsaveis para envio de notificação                      |
|			 de alteração de limite Calendario Safra/Grp.Econo-                     |
|			 mico.                                                                  |	
|	Ex.Conteudo: marcos.montes@wikitec.com.br;wanderley.neto@wikite.com.br		    |
|                                                                                   |
=====================================================================================
*/
Static Function envNotif(cAssunto,cBody)

Local oNotif	:= Nil
Local cTo		:= ''
Local aAreas	:= {;
					 ZZN->(GetArea()),;
					 GetArea()}

DbSelectArea('ZZN')
ZZN->(DbSetOrder(1))

If ZZN->( DbSeek( xFilial('ZZN') + SA1->A1_XGESTOR ) ) .And. !Empty(ZZN->ZZN_NOTNCL)
	cTo := ZZN->ZZN_NOTNCL
Else
	cTo := AllTrim(SuperGetMv("MV_XEMLCRD",,"way2solutions@ccab-agro.com.br;humberto.quesada@hqsolucoes.com"))
EndIf

oNotif	:= EmailNotif():New(AllTrim(cTo),;
							cAssunto,;
							cBody)
oNotif:Enviar()

Aeval( aAreas, {|x| RestArea(x) })

Return

//////////////////////////////////
// Funcao: U_FINA001B
// Return: Gera calendario conforme historico carteira de pedidos e garantias
//////////////////////////////////
User Function FINA001B()

Local aArea     := GetArea()
Local cQuery    := " "
Local cAliasTmp := GetNextAlias()
   
cQuery := "SELECT ZZ2_REVSAF SAFRA,ZZ2_GRPVEN GRPVEN,COUNT(*) " + CRLF 
cQuery += "FROM "+RetSqlName("ZZ2")+" ZZ2 " + CRLF
cQuery += "WHERE ZZ2.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "AND ZZ2_REVSAF <> ' ' " + CRLF
cQuery += "AND ZZ2_GRPVEN <> ' ' " + CRLF
cQuery += "GROUP BY ZZ2_REVSAF,ZZ2_GRPVEN " + CRLF

cQuery += "UNION ALL " + CRLF

cQuery += "SELECT DA0_XSAFRA SAFRA,A1_GRPVEN GRPVEN,COUNT(*) " + CRLF 
cQuery += "FROM "+RetSqlName("SZ3")+" SZ3 " + CRLF
cQuery += "INNER JOIN "+RetSqlName("DA0")+" DA0 ON DA0_FILIAL = Z3_FILIAL AND DA0_CODTAB = Z3_XTABELA AND DA0.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "INNER JOIN "+RetSqlName("SA1")+" SA1 ON A1_FILIAL = Z3_FILIAL AND A1_COD = Z3_CLI AND A1_LOJA = Z3_LOJA AND SA1.D_E_L_E_T_ = '' " + CRLF
cQuery += "WHERE SZ3.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "AND DA0_XSAFRA <> ' ' " + CRLF
cQuery += "AND A1_GRPVEN <> ' ' " + CRLF
cQuery += "GROUP BY DA0_XSAFRA,A1_GRPVEN " + CRLF

dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasTmp,.F., .F.)

dbGoTop()

While (cAliasTmp)->(!EOF())

    /*
    
    Cria calendário Safra / Grupo de Vendas 
    
    */
    cSafra  := (cAliasTmp)->SAFRA
    cGrpVen := (cAliasTmp)->GRPVEN
	    
	VerCalend(cSafra,cGrpVen,.T./*lCria*/)

	(cAliasTmp)->(dbSkip())
EndDo

(cAliasTmp)->(dbCloseArea())

RestArea(aArea)

Return

User Function FINA001X()

U_FINA001C({"01","01"})

RETURN 

/////////////////////////////////////////////////////////////////////////////////
// Funcao: U_FINA001C                                                          //
// Return: Repassa a base do calendario e executa a atualização do Agrometrika //
/////////////////////////////////////////////////////////////////////////////////
User Function FINA001C(aParam)

Local aArea     := GetArea()
Local cQuery    := " "
Local cAliasTmp := GetNextAlias()
Local cSafra    := ""
Local lJob      := (aParam <> Nil)
Local nSalAts   := 0
Local nSalDup   := 0
Local nSalPed   := 0

Private oModel //Modelo
Private aRotina
Private lFina001Auto := .T. //Variável que define se é rotina automática
Private aBKRECZZI    := {}

If lJob 
    //PREPARE ENVIRONMENT EMPRESA aParam[1] FILIAL aParam[2] TABLES "ZZH,ZZ2,SA1,ACY"
	RPCClearEnv()
	RPCSetType(3)
	RPCSetEnv(aParam[1],aParam[2])
EndIf

cSafra := RetSafra(dDataBase)

cQuery := "SELECT ZZH.R_E_C_N_O_ RECZZH,ACY_XCODRP,ACY_XLOJRP " + CRLF
cQuery += "FROM "+RetSqlName("ZZH")+" ZZH " + CRLF
cQuery += "INNER JOIN "+RetSqlName("ACY")+" ACY ON ACY_FILIAL = '"+xFilial("ACY")+"' AND ACY_GRPVEN = ZZH_GRPVEN AND ACY.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "WHERE ZZH.D_E_L_E_T_ = ' ' " + CRLF
cQuery += "AND ZZH_SAFRA >= '"+cSafra+"' " + CRLF //#MO20200703 Considera Safra atual e posteriores
//cQuery += "AND ACY_XCODRP <> ' ' " + CRLF
//cQuery += "AND ACY_XLOJRP <> ' ' " + CRLF
cQuery += "AND ZZH_DTAGRO < '"+DTOS(dDataBase)+"' " + CRLF
cQuery += "ORDER BY ZZH_GRPVEN,ZZH_SAFRA " + CRLF 

dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasTmp,.F., .F.)

dbGoTop()

While (cAliasTmp)->(!EOF())

    ZZH->(dbGoTo((cAliasTmp)->RECZZH))

    // Só chama integração do Agrometrika para os grupos com representantes cadastrados
    If !EMPTY((cAliasTmp)->ACY_XCODRP) .And. !EMPTY((cAliasTmp)->ACY_XLOJRP)

		oModel := FWLoadModel("RFINA001") //Carrega o modelo

		oModel:SetOperation(4/*MODEL_OPERATION_UPDATE*/) //Seta operação de inclusão
		oModel:Activate() //Ativa o modelo

    	IntAgrome(oModel) 

		//Validação e Gravação do Modelo
		If oModel:VldData()
			oModel:CommitData()
		Else
			aErro := oModel:GetErrorMessage()

			cArqErrAuto := "Id do formulário de origem:"+ ' [' + AllToChar( aErro[1] ) + ']' + Chr(13) + Chr(10)
			cArqErrAuto += "Id do campo de origem: " + ' [' + AllToChar( aErro[2] ) + ']' + Chr(13) + Chr(10)
			cArqErrAuto += "Id do formulário de erro: " + ' [' + AllToChar( aErro[3] ) + ']' + Chr(13) + Chr(10)
			cArqErrAuto += "Id do campo de erro: " + ' [' + AllToChar( aErro[4] ) + ']' + Chr(13) + Chr(10)
			cArqErrAuto += "Id do erro: " + ' [' + AllToChar( aErro[5] ) + ']' + Chr(13) + Chr(10)
			cArqErrAuto += "Mensagem do erro: " + ' [' + AllToChar( aErro[6] ) + ']' + Chr(13) + Chr(10)
			cArqErrAuto += "Mensagem da solução: " + ' [' + AllToChar( aErro[7] ) + ']' + Chr(13) + Chr(10)
			cArqErrAuto += "Valor atribuído: " + ' [' + AllToChar( aErro[8] ) + ']' + Chr(13) + Chr(10)
			cArqErrAuto += "Valor anterior: " + ' [' + AllToChar( aErro[9] ) + ']' + Chr(13) + Chr(10)

			//Alert ('Falha no ExecAuto MVC: ' + (Chr(13) + Chr(10)) + cArqErrAuto)
		EndIf

		oModel:DeActivate()
		oModel:Destroy()

		oModel := NIL
	EndIf

	/*
		
		Atualiza campos acumulados
		
	*/
	nSalDup := CalcDuplic(ZZH->ZZH_SAFRA,ZZH->ZZH_GRPVEN,ZZH->ZZH_MOEDLC)
	nSalPed := CalcPedLib(ZZH->ZZH_SAFRA,ZZH->ZZH_GRPVEN,ZZH->ZZH_MOEDLC)
	nSalAts := CalcDupAts(ZZH->ZZH_SAFRA,ZZH->ZZH_GRPVEN,ZZH->ZZH_MOEDLC)

	AtuSalDup(ZZH->ZZH_SAFRA,ZZH->ZZH_GRPVEN,"=",nSalDup,ZZH->ZZH_MOEDLC,dDataBase)
	AtuSalPed(ZZH->ZZH_SAFRA,ZZH->ZZH_GRPVEN,"=",nSalPed,ZZH->ZZH_MOEDLC,dDataBase)
	AtuSalAts(ZZH->ZZH_SAFRA,ZZH->ZZH_GRPVEN,"=",nSalAts,ZZH->ZZH_MOEDLC,dDataBase)

	(cAliasTmp)->(dbSkip())
EndDo

(cAliasTmp)->(dbCloseArea())

/*
		
	Atualiza saldo carteira para todos os calendarios
		
*/
AtuCarteira()

If lJob
	RESET ENVIRONMENT
Else 
	RestArea(aArea)
EndIf

Return

////////////////////////////////////////////////////////////////////////////////////
// Funcao: RetSafra                                                               //
// Return: Retorna a Safra com base uma determinada data pelo calendario contabil //
////////////////////////////////////////////////////////////////////////////////////
Static Function RetSafra(dDataCal)

Local aArea     := GetArea()
Local cQuery    := " "
Local cAliasTmp := GetNextAlias()
Local cSafra    := SPACE(9)

cQuery := " "
cQuery += CRLF + "SELECT TOP 1 MIN(YEAR(CTG_DTINI)) ANO1,MAX(YEAR(CTG_DTFIM)) ANO2 " 
cQuery += CRLF + "FROM "+RetSqlName("CTG")+" CTG "
cQuery += CRLF + "WHERE CTG_FILIAL = '"+xFilial("CTG")+"' "
cQuery += CRLF + "AND CTG.D_E_L_E_T_ = ' ' "
cQuery += CRLF + "AND CTG_CALEND IN ( SELECT CTG_CALEND FROM "+RetSqlName("CTG")+" CTG2 WHERE '"+DTOS(dDataCal)+"' BETWEEN CTG_DTINI AND CTG_DTFIM AND CTG2.D_E_L_E_T_ = ' ' ) "
cQuery += CRLF + "GROUP BY CTG_CALEND "
cQuery += CRLF + "HAVING MIN(YEAR(CTG_DTINI)) <> MAX(YEAR(CTG_DTFIM)) "
cQuery += CRLF + "ORDER BY 1 DESC "

dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasTmp,.F., .F.)

dbGoTop()

If (cAliasTmp)->(!EOF())

    cSafra := STRZERO((cAliasTmp)->ANO1,4)+"/"+STRZERO((cAliasTmp)->ANO2,4)

EndIf

(cAliasTmp)->(dbCloseArea())

RestArea(aArea)

Return cSafra


/*
=====================================================================================
|Programa: RFINA001    |Autor: Wanderley R. Neto                   |Data: 27/01/2020|
=====================================================================================
|Descrição: Rotina de notificação ao gestor quando um limite temporario é aprovado  |
|                                                                                   |
=====================================================================================
*/
Static Function EnvNotLT(oModel)

Local cBody		:= ''
Local oNotif	:= Nil
Local cSimbMoed := GetMv( "MV_MOEDA" + cValToChar( oModel:GetValue('ZZHMASTER','ZZH_MOEDLC') ) )

cBody := 		''
cBody += CRLF + 'Um novo limite temporário foi aprovado.'+ CRLF
cBody += CRLF
cBody += "Grupo Economico: "+oModel:GetValue('ZZHMASTER','ZZH_GRPVEN')+"-"+oModel:GetValue('ZZHMASTER','ZZH_DESCGR')+CRLF
cBody += "Safra: "+oModel:GetValue('ZZHMASTER','ZZH_SAFRA')+CRLF
cBody += CRLF
cBody += "Rating: "+oModel:GetValue('ZZHMASTER','ZZH_RATING')+CRLF
cBody += CRLF
cBody += "Limite Clean: "+cSimbMoed+TRANSFORM(oModel:GetValue('ZZHMASTER','ZZH_LIMCLE'),PesqPictQt("ZZH_LIMCLE",16))+CRLF
cBody += CRLF
cBody += "Limite Garantia:"+CRLF
cBody += CRLF
cBody += "  Atual    : "+cSimbMoed+TRANSFORM(oModel:GetValue('ZZHMASTER','ZZH_LIMDIS'),PesqPictQt("ZZH_LIMDIS",16))+CRLF
cBody += CRLF
cBody += "  Calculado: "+cSimbMoed+TRANSFORM(oModel:GetValue('ZZHMASTER','ZZH_DISCAL'),PesqPictQt("ZZH_DISCAL",16))+CRLF
cBody += CRLF
cBody += "Limite Temporário: "+cSimbMoed+TRANSFORM(oModel:GetValue('ZZHMASTER','ZZH_LIMMAN'),PesqPictQt("ZZH_LIMMAN",16))+CRLF
cBody += CRLF
cBody += "Gestor Responsável: "+ObtemGestor(oModel:GetValue('ZZHMASTER','ZZH_GRPVEN'))+CRLF


oNotif	:= EmailNotif():New(AllTrim(SuperGetMv('MV_XNOTALT',,'wanderley.neto@wikitec.com.br')),;
							'Aprovação de Limite Temporário',;
							cBody) 
oNotif:Enviar()


Return

/*
=====================================================================================
|Programa: RFINA001    |Autor: Wanderley R. Neto                   |Data: 30/01/2020|
=====================================================================================
|Descrição: Função para retornar o gestor regional responsável por um determinado   |
| grupo economico                                                                   |
=====================================================================================
*/
Static Function ObtemGestor(cGrpVen)

Local cGestor	:= ''
Local cFilACY	:= xFilial('ACY')
Local cFilSA1	:= xFilial('SA1')
Local cFilZZN	:= xFilial('ZZN')
Local aAreas	:= {;
					 ACY->(GetArea()),;
					 SA1->(GetArea()),;
					 GetArea()}

If ACY->( DbSeek( cFilACY + cGrpVen ) )

	If SA1->( DbSeek( cFilSA1 + ACY->( ACY_XCODRP + ACY_XLOJRP ) ) )
	
		If ZZN->( DbSeek( cFilZZN +  SA1->A1_XGESTOR ) )
		
			cGestor := ZZN->( ZZN_CODIGO + '-' + AllTrim(ZZN_NOME))
		
		EndIf
	
	EndIf

EndIf

Aeval( aAreas, {|x| RestArea(x) })

Return cGestor

//////////////////////////////////////////////////////////////////////////////////////
// Retorna o Grupo de Vendas da Loja quando da inclusão de uma nova loja do cliente //
//////////////////////////////////////////////////////////////////////////////////////
User Function RF001LOJ()

Local aArea    := GETAREA()
Local aAreaSA1 := SA1->(GETAREA())
Local cGrpVen  := M->A1_GRPVEN

If M->A1_LOJA <> "01"
   
	dbSelectArea("SA1")
	dbSetOrder(1)
	If dbSeek(xFilial("SA1")+M->A1_COD+"01") .And. !EMPTY(SA1->A1_GRPVEN)
		cGrpVen := SA1->A1_GRPVEN
	EndIf

EndIf

RESTAREA(aArea)
RESTAREA(aAreaSA1)

Return cGrpVen

//////////////////////////////////
// Funcao: PerSafra
// Return: Retorna array com a data inicio e final da safra conforme calendario contabil
//
//////////////////////////////////
Static Function PerSafra(cSafra)

Local aArea     := GetArea()
Local aPeriodo  := {CTOD("  /  /  "),CTOD("  /  /  ")}
Local cQuery    := " "
Local cAliasTmp := GetNextAlias()
   
cQuery := " "
cQuery += CRLF + "SELECT MIN(CTG_DTINI) PERINI,MAX(CTG_DTFIM) PERFIM " 
cQuery += CRLF + "FROM "+RetSqlName("CTG")+" CTG "
cQuery += CRLF + "WHERE CTG_FILIAL = '"+xFilial("CTG")+"' "
cQuery += CRLF + "AND CTG.D_E_L_E_T_ = ' ' "
cQuery += CRLF + "GROUP BY CTG_CALEND "
cQuery += CRLF + "HAVING MIN(YEAR(CTG_DTINI)) <> MAX(YEAR(CTG_DTFIM)) "
cQuery += CRLF + "AND STR(MIN(YEAR(CTG_DTINI)),4)+'/'+STR(MAX(YEAR(CTG_DTFIM)),4) = '"+cSafra+"' "
cQuery += CRLF + "ORDER BY 1 DESC "

dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasTmp,.F., .F.)

dbGoTop()

If (cAliasTmp)->(!EOF())

   aPeriodo  := {STOD((cAliasTmp)->PERINI),STOD((cAliasTmp)->PERFIM)}

Else

   aPeriodo  := {CTOD("01/07/"+SUBSTRING(cSafra,1,4)),CTOD("30/06/"+SUBSTRING(cSafra,6,4))}

EndIf

(cAliasTmp)->(dbCloseArea())

RestArea(aArea)

Return aPeriodo

//////////////////////////////////
// Funcao: TrazCNPJ
// Return: Retorna array com todos os CNPJs cadastrados a partir da Raiz do CNPJ (8 primeiros digitos)
//
//////////////////////////////////
Static Function TrazCNPJ(cCNPJ)

Local aCNPJ     := {}
Local aArea     := GetArea()
Local cQuery    := " "
Local cAliasTmp := GetNextAlias()
	
cQuery := " "
cQuery += CRLF + "SELECT DISTINCT A1_CGC CNPJ, A1_COD+A1_LOJA CODERP "
cQuery += CRLF + "FROM "+RetSqlName("SA1")+" SA1 "
cQuery += CRLF + "WHERE A1_FILIAL = '"+xFilial("SA1")+"' "
cQuery += CRLF + "AND SA1.D_E_L_E_T_ = ' ' "
If LEN(cCNPJ) > 11 //Nao consulta se for CPF  
	cQuery += CRLF + "AND A1_CGC LIKE '"+LEFT(cCNPJ,8)+"%' "
	//cQuery += CRLF + "AND A1_CGC <> '"+cCNPJ+"' "
Else
	cQuery += CRLF + "AND A1_CGC LIKE '"+cCNPJ+"' "
EndIf
cQuery += CRLF + "ORDER BY 1 ASC "

dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAliasTmp,.F., .F.)

While (cAliasTmp)->( ! Eof() )

	AADD(aCNPJ,{(cAliasTmp)->CNPJ,(cAliasTmp)->CODERP})	

	(cAliasTmp)->( dbSkip() )
EndDo

(cAliasTmp)->(dbCloseArea())


RestArea(aArea)

Return aCNPJ

/*

-- =============================================
-- Author:          Agility
-- Create date: 26-10-2018
-- Description:     Função para cálculo da PTAX
-- =============================================
ALTER FUNCTION [dbo].[fn_xMoeda](
-- Add the parameters for the function here
@cData  VARCHAR(8),
@cMoeda INT)
RETURNS FLOAT
AS
     BEGIN
         -- Declare the return variable here
         DECLARE @Result FLOAT;

         -- Add the T-SQL statements to compute the return value here
         SELECT TOP 1 @Result = (CASE @cMoeda
                                     WHEN 2
                                     THEN M2_MOEDA2
                                     WHEN 3
                                     THEN M2_MOEDA3
                                     WHEN 4
                                     THEN M2_MOEDA4
                                     WHEN 5
                                     THEN M2_MOEDA5
                                     ELSE 0
                                 END)
         FROM SM2010
         WHERE M2_DATA <= @cData
                 --Evitar problemas com PA futuro (23/01/2019 - Sergio CCAB)
                 --Resolve casos em que o PA tenha sido lançado com data futura com cadastro da MOEDA na data e valor 0
                 --Utiliza a moeda da maior data com valor cadastrado
                 AND (
                           (@cData>=getdate() --caso citado
                       AND (CASE @cMoeda
                                     WHEN 2
                                     THEN M2_MOEDA2
                                     WHEN 3
                                     THEN M2_MOEDA3
                                     WHEN 4
                                     THEN M2_MOEDA4
                                     WHEN 5
                                     THEN M2_MOEDA5
                                     ELSE 0
                                 END) <> 0
                           )
                           OR
                           (@cData<getdate()) --datas anteriores devem ter PTAX cadastrada
                    )
                 --fim
               AND D_E_L_E_T_ = ' '
             ORDER BY M2_DATA DESC;
         -- Return the result of the function
         RETURN @Result;
     END;

*/

/*
=====================================================================================
|Programa: RFINA001    |Autor: Wanderley R. Neto                   |Data: 30/11/2020|
=====================================================================================
|Descrição: Retorna lista de opções dos motivos para bloqueio do credito.           |
|                                                                                   |
=====================================================================================
*/
User Function RF001CBO()
Return 	'1=Em Análise de Crédito;'+;
		'2=Em Análise Jurídica;'+;
		'3=Aguardando Documentos;'+;
		'4=Aguardando Pagamento;'+;
		'5=Pedido à Vista;'+;
		'6=Dívida Vencida;'+;
		'7=Garantia Pendente;'+;
		'8=Liberação da Diretoria;'+;
		'9=Limite de Crédito Reprovado'

/*
=====================================================================================
|Programa: RFINA001    |Autor: Wanderley R. Neto                   |Data: 30/04/2021|
=====================================================================================
|Descrição: Retorna a ultima safra do grupo com rating informado (que tenha proposta|
| formalizada no Agrometrika)                                                       |
=====================================================================================
*/
Static Function UltSafra(cGrupo)

	Local cSafra	:= ''
	Local cQuery	:= ''
	Local cAliasZZH	:= GetNextAlias()

	cQuery += CRLF + " Select MAX(ZZH_SAFRA) ULTSAFRA "
	cQuery += CRLF + "   From "+RetSqlName('ZZH')
	cQuery += CRLF + "  Where D_E_L_E_T_ = '' "
	cQuery += CRLF + "    and ZZH_GRPVEN = '"+AllTrim(cGrupo)+"' "
	cQuery += CRLF + "    and ZZH_RATING <> '' "


	dbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasZZH,.F., .F.)

	If ! (cAliasZZH)->( Eof() )
		cSafra := (cAliasZZH)->ULTSAFRA
	EndIf
	
	(cAliasZZH)->(dbCloseArea())

Return cSafra

/*
=====================================================================================
|Programa: RFINA001    |Autor: Wanderley R. Neto                   |Data: 30/04/2021|
=====================================================================================
|Descrição: Atualiza o rating dos clientes do grupo e acordo com o Rating do Grupo  |
| definido no Agrometrika                                                           |
=====================================================================================
*/
Static Function AtuRatCli(cSafra, cGrupo, cRating)

	Local cUltSafra	:= UltSafra(cGrupo) // ultima safra com Rating informado
	Local aAreas	:= {;
						 SA1->(GetArea()),;
						 GetArea()}
	// Se safra atualizada for a ultima do grupo atualiza o rating dos clientes
	If cSafra >= cUltSafra

		DbSelectArea('SA1')
		SA1->(DbSetOrder(6)) // A1_FILIAL + A1_GRPVEN

		If SA1->( DbSeek( xFilial('SA1') + cGrupo ) )
		
			While SA1->( ! Eof() ) .And. SA1->A1_GRPVEN == cGrupo
			
				RecLock('SA1',.F.)
					SA1->A1_XCLASSE := cRating
				SA1->(MsUnlock())
			
				SA1->( DbSkip() )
			End			
		
		EndIf

	EndIf

	Aeval( aAreas, {|x| RestArea(x) })

Return Nil

//////////////////////////////////
// Funcao: U_FINA001D
// Return: Limpa data de Previsão, Motivo e Ação do Gestor
//////////////////////////////////////////////////////////
User Function FINA001D()

Local aCalend   := {}
Local nOpca     := 0
Local cVarQ     := ""
Local nAt
Local aButton   := Array(2)
Local oOk       := LoadBitmap( GetResources(), "LBOK")
Local oNo       := LoadBitmap( GetResources(), "LBNO")
Local oCalend, oDlg
Local oModel, oModZZH
Local aArea     := GETAREA()
Local aAreaZZH  := ZZH->(GETAREA())

MsgRun("Localizando calendários...", "Aguarde", {|| aCalend := LoadCalend() })

//Monta LISTBOX com os calendários selecionados.
If Len(aCalend) > 0 

	DEFINE MSDIALOG oDlg TITLE "Limpeza de Previsão dos calendários em Lote" From 9,0 To 41,100 /*31,80*/ OF oMainWnd

		DEFINE FONT oFnt1	NAME "Arial" 			Size 10,12 BOLD
		@ 0.3,.5 Say "Calendários com Previsão" FONT oFnt1 COLOR CLR_RED	  

		@ 13,04 BUTTON "Inverte Selecao" PIXEL OF oDlg SIZE 50,11; 
		ACTION (	aEval(oCalend:aArray, {|e| 	e[1] := ! e[1] }),;
		oCalend:Refresh())

		@ 2,.5  LISTBOX oCalend VAR cVarQ Fields HEADER "","SAFRA","Descr.GRUPO","Status","Previsao","Motivo","Acao","Gestor","Nome Gestor";  
			SIZE 400,200 NOSCROLL	

     	oCalend:bLDblClick := {|| (aCalend[oCalend:nAt,1] := !aCalend[oCalend:nAt,1],oCalend:Refresh()) }
		oCalend:SetArray(aCalend)
		oCalend:bLine := { || {IIF(aCalend[oCalend:nAt][1],oOk,oNo),aCalend[oCalend:nAt,2],aCalend[oCalend:nAt,3],;
		      aCalend[oCalend:nAt,4],aCalend[oCalend:nAt,5],aCalend[oCalend:nAt,6],aCalend[oCalend:nAt,7],aCalend[oCalend:nAt,8],aCalend[oCalend:nAt,9]}}

        bGrava := {||IIF(Aviso("Confirma gravação","Efetua a limpeza dos campos de previsão, motivo de bloqueio e ação do Gestor dos registos marcados?",{"Sim","Não"},3,"Limpeza dos campos do calendário",,,.T.)==1,(nOpca:=1,oDlg:End()),)}
        bSair  := {||oDlg:End()              }

        aButton[1]	:= tButton():New(230.5,300,"&Grava"       ,oDlg,bGrava    ,35,12,,,,.T.)
        aButton[2]	:= tButton():New(230.5,350,"&Sair"        ,oDlg,bSair     ,35,12,,,,.T.)

	ACTIVATE MSDIALOG oDlg CENTERED

	If nOpca == 1
    
        For nAt := 1 To Len(aCalend)

            If aCalend[nAt][1]  

                dbSelectArea("ZZH")
                ZZH->(dbGoto(aCalend[nAt][10]))

                If ZZH->(!EOF())

					oModel := FWLoadModel("RFINA001") //Carrega o modelo

					oModel:SetOperation(4/*MODEL_OPERATION_UPDATE*/) //Seta operação de inclusão
					oModel:Activate() //Ativa o modelo

					oModZZH  := oModel:GetModel():GetModel("ZZHMASTER")
					
					GravaHist("ZZH_PREVLI",CTOD("  /  /  "),oModZZH:GetValue("ZZH_PREVLI"),)
					GravaHist("ZZH_MOTIVO",SPACE(TAMSX3("ZZH_MOTIVO")[1]),oModZZH:GetValue("ZZH_MOTIVO"),)
					GravaHist("ZZH_ACAO",SPACE(TAMSX3("ZZH_ACAO")[1]),oModZZH:GetValue("ZZH_ACAO"),)

					oModZZH:LoadValue("ZZH_PREVLI",CTOD("  /  /  "))
					oModZZH:LoadValue("ZZH_MOTIVO",SPACE(TAMSX3("ZZH_MOTIVO")[1]))
					oModZZH:LoadValue("ZZH_ACAO",SPACE(TAMSX3("ZZH_ACAO")[1]))

					//Validação e Gravação do Modelo
					If oModel:VldData()
						oModel:CommitData()
					Else
						aErro := oModel:GetErrorMessage()

						cArqErrAuto := "Id do formulário de origem:"+ ' [' + AllToChar( aErro[1] ) + ']' + Chr(13) + Chr(10)
						cArqErrAuto += "Id do campo de origem: " + ' [' + AllToChar( aErro[2] ) + ']' + Chr(13) + Chr(10)
						cArqErrAuto += "Id do formulário de erro: " + ' [' + AllToChar( aErro[3] ) + ']' + Chr(13) + Chr(10)
						cArqErrAuto += "Id do campo de erro: " + ' [' + AllToChar( aErro[4] ) + ']' + Chr(13) + Chr(10)
						cArqErrAuto += "Id do erro: " + ' [' + AllToChar( aErro[5] ) + ']' + Chr(13) + Chr(10)
						cArqErrAuto += "Mensagem do erro: " + ' [' + AllToChar( aErro[6] ) + ']' + Chr(13) + Chr(10)
						cArqErrAuto += "Mensagem da solução: " + ' [' + AllToChar( aErro[7] ) + ']' + Chr(13) + Chr(10)
						cArqErrAuto += "Valor atribuído: " + ' [' + AllToChar( aErro[8] ) + ']' + Chr(13) + Chr(10)
						cArqErrAuto += "Valor anterior: " + ' [' + AllToChar( aErro[9] ) + ']' + Chr(13) + Chr(10)

						//Alert ('Falha no ExecAuto MVC: ' + (Chr(13) + Chr(10)) + cArqErrAuto)
					EndIf

					oModel:DeActivate()
					oModel:Destroy()

					oModel := NIL
                EndIf

            EndIf

        Next
	EndIf
Else
	MsgInfo("Nenhum registro de Calendário com previsão encontrado!!!","ATENÇÃO")
EndIf

RestArea(aAreaZZH)
RestArea(aArea)

Return Nil

//////////////////////////////////
// Funcao: LoadCalend
// Return: Retorna a relação de calendário com previsão preenchida
///////////////////////////////////////////////////////////////////
Static Function LoadCalend()

Local aCalend   := {}
Local cAliasQry := GetNextAlias()
Local cQuery    := ""
Local aStatus   := RetSX3Box(GetSX3Cache("ZZH_STATUS","X3_CBOX"),,,1)
Local aMotivos  := RetSX3Box(U_RF001CBO(),,,1)
Local nSeek     := 0
Local cStatus   := ""
Local cMotivo   := ""

cQuery := " SELECT ZZH_SAFRA,ZZH_GRPVEN,ZZH_DESCGR,ZZH_STATUS,ZZH_PREVLI,ZZH_MOTIVO,ZZH_ACAO,A1_XGESTOR,ZZN_NOME,ZZH.R_E_C_N_O_ RECZZH "
cQuery += " FROM "+RetSqlName("ZZH")+" ZZH "
cQuery += " INNER JOIN "+RetSqlName("ACY")+" ACY ON ACY_FILIAL = '"+xFilial("ACY")+"' AND ACY_GRPVEN = ZZH_GRPVEN AND ACY.D_E_L_E_T_ = ' ' "
cQuery += " INNER JOIN "+RetSqlName("SA1")+" SA1 ON A1_FILIAL = '"+xFilial("SA1")+"' AND A1_COD = ACY_XCODRP AND A1_LOJA = ACY_XLOJRP AND SA1.D_E_L_E_T_ = ' ' "
cQuery += " INNER JOIN "+RetSqlName("ZZN")+" ZZN ON ZZN_FILIAL = '"+xFilial("ZZN")+"' AND ZZN_CODIGO = A1_XGESTOR AND ZZN.D_E_L_E_T_ = ' ' "
cQuery += " WHERE ZZH_FILIAL = '"+xFilial("ZZH")+"' "
cQuery += " AND ZZH.D_E_L_E_T_ = ' ' "
cQuery += " AND ZZH_PREVLI <> '       ' " // Traz somente calendários com Previsão preenchida
If !Empty(AllTrim(aRetPar[1]))
	cQuery += "  AND ZZH_SAFRA >= '"+ AllTrim(aRetPar[1]) +"'"
EndIf
If !Empty(AllTrim(aRetPar[2]))
	cQuery += "  AND ZZH_SAFRA <= '"+ AllTrim(aRetPar[2]) +"'"
EndIf
If !Empty(AllTrim(aRetPar[3]))
	cQuery += "  AND A1_XGESTOR = '"+ AllTrim(aRetPar[3]) +"'"
EndIf

cQuery := ChangeQuery(cQuery)

dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasQry,.T.,.T.)

TcSetField(cAliasQry,"ZZH_PREVLI","D",8				,0)
TcSetField(cAliasQry,"RECZZH","N",17 				,0)

dbSelectArea(cAliasQry)

While (cAliasQry)->(!Eof())

	If (nSeek := Ascan( aStatus, {|x| x[2] == (cAliasQry)->ZZH_STATUS})) > 0
		cStatus := aStatus[nSeek][1]
	Else
		cStatus := (cAliasQry)->ZZH_STATUS
    EndIf

	If (nSeek := Ascan( aMotivos, {|x| x[2] == RTRIM((cAliasQry)->ZZH_MOTIVO)})) > 0
		cMotivo := aMotivos[nSeek][1]
	Else
		cMotivo := (cAliasQry)->ZZH_MOTIVO
    EndIf

	Aadd(aCalend,{EMPTY((cAliasQry)->ZZH_PREVLI),;
				 (cAliasQry)->ZZH_SAFRA,;
				 (cAliasQry)->ZZH_DESCGR,;
				 cStatus,;
	             DTOC((cAliasQry)->ZZH_PREVLI),;
				 cMotivo,;
				 (cAliasQry)->ZZH_ACAO,;
				 (cAliasQry)->A1_XGESTOR,;
				 (cAliasQry)->ZZN_NOME,;
				 (cAliasQry)->RECZZH})
	
    (cAliasQry)->(dbSkip())
EndDo

dbSelectArea(cAliasQry)
dbCloseArea()

Return aCalend
