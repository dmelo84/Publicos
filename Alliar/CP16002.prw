#Include "PROTHEUS.ch"
#INCLUDE "FWMVCDEF.CH"

/*/{Protheus.doc} CP16002
    
    Browse de assinaturas Vindi

    @type  User Function
    @author Julio Teixeira - Compila
    @since 14/04/2020
    @version 12
    @param 
    @return Nil
/*/
User Function CP16002()

    Local oBrowse 
    
    oBrowse := FWMBrowse():New()
    oBrowse:SetAlias("ZZC")
    oBrowse:SetDescription("Assinaturas Aliança")

    oBrowse:Activate()

Return Nil

Static Function MenuDef()

    Local aRotina := {}

    ADD OPTION aRotina TITLE 'Pesquisar'    ACTION 'PesqBrw'  OPERATION 1 ACCESS 0
    ADD OPTION aRotina TITLE 'Visualizar'   ACTION 'VIEWDEF.CP16002' OPERATION 2 ACCESS 0
    //ADD OPTION aRotina TITLE 'Incluir'      ACTION 'VIEWDEF.CP16002' OPERATION 3 ACCESS 0
    //ADD OPTION aRotina TITLE 'Alterar'      ACTION 'VIEWDEF.CP16002' OPERATION 4 ACCESS 0

Return aRotina

/*/{Protheus.doc} ModelDef
    Modelo
    @type  User Function
    @author Julio Teixeira - Compila
    @since 14/04/2020
    @version 12
    @param 
    @return Nil
/*/
Static Function ModelDef()
    
    Local oModel := MpFormModel():New("CP16002M",/*Pre-Validacao*/,/*Pos-Validacao*/,/*Commit*/,/*Cancel*/)

    Local oStruZZC := FwFormStruct(1, "ZZC")
    Local oStruZZD := FwFormStruct(1, "ZZD")
    
    oStruZZC:AddField( ;      	// Ord. Tipo Desc.
                        "Nome Cli."       	, ;      // [01]  C   Titulo do campo
                        "Nome Cliente"		, ;      // [02]  C   ToolTip do campo
                        'ZZC_NOME'		, ;      // [03]  C   Id do Field
                        'C'					, ;      // [04]  C   Tipo do campo
                        100            	, ;      // [05]  N   Tamanho do campo
                        0					, ;      // [06]  N   Decimal do campo
                        NIL					, ;      // [07]  B   Code-block de validação do campo
                        NIL					, ;      // [08]  B   Code-block de validação When do campo
                        NIL            	, ;      // [09]  A   Lista de valores permitido do campo
                        .F.             , ;      // [10]  L   Indica se o campo tem preenchimento obrigatório
                        FwBuildFeature( STRUCT_FEATURE_INIPAD,'Posicione("SA1",1,xFilial("SA1")+M->(ZZC_CODCLI+ZZC_LOJCLI),"A1_NOME")' ), ;      // [11]  B   Code-block de inicializacao do campo
                        NIL					, ;      // [12]  L   Indica se trata-se de um campo chave
                        NIL					, ;      // [13]  L   Indica se o campo pode receber valor em uma operação de update.
                        .T.             )        // [14]  L   Indica se o campo é virtual


    oModel:AddFields("ZZCMASTER", NIL, oStruZZC)
    oModel:AddGrid("ZZDDETAIL", "ZZCMASTER", oStruZZD)

    oModel:SetPrimaryKey( { "ZZC_FILIAL", "ZZC_CODASS" } )
    // DEFINE A RELAÇÃO ENTRE OS SUBMODELOS
    //oModel:SetRelation("ZZDDETAIL", {{"ZZD_FILIAL", "FwXFilial('ZZD')"}, {"ZZD_CODASS", "ZZC_CODASS"}}, ZZD->(IndexKey( 2 )))
    oModel:SetRelation("ZZDDETAIL", {{"ZZD_FILIAL", "FwXFilial('ZZD')"}, {"ZZD_CODCLI", "ZZC_CODCLI"},{"ZZD_LOJCLI", "ZZC_LOJCLI"}, {"ZZD_CODASS", "ZZC_CODASS"}}, ZZD->(IndexKey( 3 )))

    oModel:GetModel("ZZCMASTER"):SetDescription("Assinaturas")
    oModel:GetModel("ZZDDETAIL"):SetDescription("Periodos")
Return oModel

/*/{Protheus.doc} ViewDef
    Interface Visual
    @type  User Function
    @author Julio Teixeira - Compila
    @since 14/04/2020
    @version 12
    @param 
    @return Nil
/*/
Static Function ViewDef()

    Local oView := FwFormView():New()

    Local oStruZZC := FwFormStruct(2, "ZZC")
    Local oStruZZD := FwFormStruct(2, "ZZD")
    Local oModel := FwLoadModel("CP16002")

    oStruZZD:RemoveField("ZZD_CODASS")
    oStruZZD:RemoveField("ZZD_CODCLI")
    oStruZZD:RemoveField("ZZD_LOJCLI")

    oStruZZC:AddField(; 	      // Ord. Tipo Desc.
                        'ZZC_NOME'		, ;      // [01]  C   Nome do Campo
                        "02"         	, ;      // [02]  C   Ordem
                        "Nome Cliente"			, ;      // [03]  C   Titulo do campo
                        "Nome Cliente"     		, ;      // [04]  C   Descricao do campo
                        { "" }		, ;      // [05]  A   Array com Help
                        'C' 				, ;      // [06]  C   Tipo do campo
                        '@!'           	, ;      // [07]  C   Picture
                        NIL            	, ;      // [08]  B   Bloco de Picture Var
                        ''             	, ;      // [09]  C   Consulta F3
                        .f.					, ;      // [10]  L   Indica se o campo é alteravel
                        NIL           	, ;      // [11]  C   Pasta do campo
                        NIL            	, ;      // [12]  C   Agrupamento do campo
                        NIL            	, ;      // [13]  A   Lista de valores permitido do campo (Combo)
                        NIL            	, ;      // [14]  N   Tamanho maximo da maior opção do combo
                        NIL            	, ;      // [15]  C   Inicializador de Browse
                        .T.             , ;      // [16]  L   Indica se o campo é virtual
                        NIL            	, ;      // [17]  C   Picture Variavel
                        NIL            	)        // [18]  L   Indica pulo de linha após o campo


    // INDICA O MODELO DA VIEW
    oView:SetModel(oModel)

    oView:AddField("VIEW_ZZC", oStruZZC, "ZZCMASTER")
    oView:AddGrid("VIEW_ZZD", oStruZZD, "ZZDDETAIL")

    oView:CreateHorizontalBox("SUPERIOR", 40)
    oView:CreateHorizontalBox("INFERIOR", 60)

    oView:SetOwnerView("VIEW_ZZC", "SUPERIOR")
    oView:SetOwnerView("VIEW_ZZD", "INFERIOR")

    oView:EnableTitleView( "VIEW_ZZD", "Periodos da Assinatura" )

Return oView

/*/{Protheus.doc} User Function CP16ASS1
    
    Função para gravar/alterar assinaturas 
    
    @type  User Function
    @author Julio Teixeira - Compila
    @since 15/04/2020
    @version 12
    @param aCab,aItens,nOper
    @return aRet, {.T.,cErro,cCodAss}
/*/
User Function CP16ASS1(aCab,aItens,nOper)

Local aRet := {.T.,"",""}    
Local aErro := {}
Local nX := 1
Local nY := 1
Local oModelZZC
Local oModelZZD
Local aArea := GetArea()
Local lExist := .T.

Default aCab := {}
Default aItens := {}
Default nOper := 0

If len(aCab) >= 1 .AND. nOper >= 3
    
    oModelZZC	:= FWLoadModel('CP16002')//Model controle de assinaturas

    DbSelectArea("ZZC")
    If Ascan(aCab, { |x| AllTrim(x[1]) == 'ZZC_CODCLI' }) > 0     
        ZZC->(DbSetOrder(2))
        lExist := ZZC->(DbSeek(xFilial("ZZC")+aCab[Ascan(aCab, { |x| AllTrim(x[1]) == 'ZZC_CODCLI' })][2]+aCab[Ascan(aCab, { |x| AllTrim(x[1]) == 'ZZC_LOJCLI' })][2]+aCab[Ascan(aCab, { |x| AllTrim(x[1]) == 'ZZC_CODASS' })][2] ))
    ElseIf Ascan(aCab, { |x| AllTrim(x[1]) == 'ZZC_CODASS' }) > 0     
        ZZC->(DbSetOrder(1))
        lExist := ZZC->(DbSeek(xFilial("ZZC")+aCab[Ascan(aCab, { |x| AllTrim(x[1]) == 'ZZC_CODASS' })][2] ))
    Endif

    If (!lExist .AND. nOper == 3) .OR. (lExist .AND. nOper == 4)
        oModelZZC:DeActivate()
        oModelZZC:SetOperation(nOper)//Define operação
        oModelZZC:Activate()//Ativa o modelo para inclusão/alteração

        For nX := 1 to len(aCab)
            If !(nOper == 4 .AND. aCab[nX][1] == "ZZC_CODASS")
                oModelZZC:SetValue("ZZCMASTER", aCab[nX][1], aCab[nX][2])
            Endif
        Next nX
        
        oModelZZD :=  oModelZZC:GetModel( 'ZZDDETAIL' )

        For nX := 1 to len(aItens)
            
            If nOper == 3 .AND. ( (oModelZZD:Length() == 1 .AND. (!Empty(oModelZZD:GetValue("ZZD_CODPER")) .OR. oModelZZD:IsDeleted()) ) .OR. oModelZZD:Length() > 1 )
                oModelZZD:AddLine()
            Elseif nOper == 4 .AND. Val(aItens[nX][Ascan(aItens[nX], { |x| AllTrim(x[1]) == 'ZZD_CICLO' })][2]) <= oModelZZD:Length() 
                oModelZZD:GoLine( Val(aItens[nX][Ascan(aItens[nX], { |x| AllTrim(x[1]) == 'ZZD_CICLO' })][2]) )      
            Elseif nOper == 4 .AND. Val(aItens[nX][Ascan(aItens[nX], { |x| AllTrim(x[1]) == 'ZZD_CICLO' })][2]) > oModelZZD:Length() 
                oModelZZD:AddLine()
            Endif

            For nY := 1 to len(aItens[nX])
                oModelZZD:SetValue(aItens[nX][nY][1],aItens[nX][nY][2])
            Next nY
        Next nX

        If oModelZZC:VldData()
            oModelZZC:CommitData()
        EndIf

        aErro := oModelZZC:GetErrorMessage()
        If len(aErro) >= 6 .AND. !Empty(aErro[6])
            aRet[1] := .F.
            aRet[2] := aErro[6]
        Endif
    
       // oModelZZD:DeActivate() 
       // oModelZZD:Destroy()
    Else
        aRet[1] := .F.
        If lExist    
            aRet[2] := "Assinatura já cadastrada!"
        Else
            aRet[2] := "Assinatura não encontrada!"
        Endif    
    EndIf
    oModelZZC:DeActivate() 
    oModelZZC:Destroy()
Else
    aRet[1] := .F.
    aRet[2] := "Todos os parâmetros são obrigatórios para execução da rotina CP16ASS1, informar parâmetros!"
Endif    

RestArea(aArea)

Return aRet
