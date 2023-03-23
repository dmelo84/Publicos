#INCLUDE "PROTHEUS.CH"
#INCLUDE "RESTFUL.CH"
#INCLUDE 'FWMVCDEF.ch'

User Function CP16WSR2()
Return

//-------------------------------------------------------------------
/*/ {REST Web Service} ALIANCAB2B
    Serviço rest utilizado para recepção de eventos aliança B2B
    @version undefined
    @since 24/03/2020
    @author Julio Teixeira | www.compila.com.br
/*/
//-------------------------------------------------------------------
WSRESTFUL ALIANCAB2B DESCRIPTION "Serviço Aliança B2B"

    WSMETHOD POST Order_b2b ; 
    DESCRIPTION "Recebe Pedido Alianca B2B" ;
    WSSYNTAX "/api/aliancab2b/order" ;
    PATH "/api/aliancab2b/order"

    WSMETHOD POST Cancel_b2b ; 
    DESCRIPTION "Cancelamento de Pedido Alianca B2B" ;
    WSSYNTAX "/api/aliancab2b/ordercancel" ;
    PATH "/api/aliancab2b/ordercancel"

    WSMETHOD POST Customer_b2b ; 
    DESCRIPTION "Recebe Cliente Alianca B2B" ;
    WSSYNTAX "/api/aliancab2b/customer" ;
    PATH "/api/aliancab2b/customer"

    WSMETHOD POST Webhook ; 
    DESCRIPTION "Recebe webhook Alianca B2B" ;
    WSSYNTAX "/api/aliancab2b/webhook" ;
    PATH "/api/aliancab2b/webhook"

END WSRESTFUL

/*/--------------------------------------------------------------------------/*/
WSMETHOD POST Order_b2b WSSERVICE ALIANCAB2B

    Local cBody 
    Local cCatch  
    Local oJson := JsonObject():New()
    Local cJRetOK := '{"errorCode":201,"status":"success"}'
    Local aRet := {.T.,"",""}
    Local aPropr := {"uid","data_emissao","cliente","itens","pagamentos"}
    Local aArea := GetArea()
    Local aAreaSA1 := SA1->(GetArea())
    Local aAreaSB1 := SB1->(GetArea())
    Local nX := 1
    Local aPed := {}
    Local xUid 

    ::SetContentType("application/json")
    cBody := ::GetContent()
    cBody := DECODEUTF8( cBody )

    If !Empty(cBody) 
        
        cCatch := oJson:FromJson(cBody)
        
        If ValType(cCatch) == "U"        

            For nX := 1 to len(aPropr)
                If ValType(oJson:GetJsonObject(aPropr[nX])) == "U"
                    aRet[1] := .F. 
                    aRet[2] := "Propriedade obrigatória nao localizada. ("+aPropr[nX]+"). "
                Else
                    If aPropr[nX] != "cliente".AND. Empty(oJson[aPropr[nX]])
                        aRet[1] := .F. 
                        aRet[2] := "Propriedade tem preenchimento obrigatorio. ("+aPropr[nX]+"). "
                    Endif    
                Endif
            Next nX

            DbSelectArea("SA1")
            SA1->(DbSetOrder(3))
            If ValType(oJson['cliente']:GetJsonObject('cpf_cnpj')) == "U" .OR. SA1->(!DbSeek(xFilial("SA1")+Alltrim(oJson['cliente']['cpf_cnpj'])))
                aRet[1] := .F.
                aRet[2] := "Cliente não encontrado."
            Endif

            If ValType(oJson['uid']) == "C"
                xUid := StrZero(Val(oJson['uid']), TamSX3("C5_XIDPLE")[1]-1)
            Else
                xUid := StrZero(oJson['uid'], TamSX3("C5_XIDPLE")[1]-1)
            Endif    

            aPed := ExistOrder( "R"+xUid )
            If aPed[1]
                aRet[1] := .F.
                aRet[2] := "Não foi possível processar esta requisição, pois já existe o pedido "+aPed[3][1]+" gerado com este ID R"+xUid+"." 
            Else
                aPed := ExistOrder( "U"+xUid )
                If aPed[1]
                    aRet[1] := .F.
                    aRet[2] := "Não foi possível processar esta requisição, pois já existe o pedido "+aPed[3][1]+" gerado com este ID U"+xUid+"." 
                Endif
            Endif

            If len(oJson['itens']) >= 1
                For nx := 1 to len(oJson['itens'])
                    DbSelectArea("SB1")
                    SB1->(DbSetOrder(1))
                    If ValType(oJson['itens'][nX]:GetJsonObject('id')) != "C" 
                        aRet[1] := .F.
                        aRet[2] := "Produto informado está em formato inválido, seu tipo deve ser 'string'."
                    ElseIf SB1->(!DbSeek(xFilial("SB1")+Alltrim(oJson['itens'][nX]['id'])))
                        aRet[1] := .F.
                        aRet[2] := "Produto "+Alltrim(oJson['itens'][nX]['id'])+" não encontrado."
                    Endif
                Next nX    
            Endif
            
            If aRet[1]
                aRet := U_CP12ADD("000033", "", 0, cBody, )
            
                If aRet[1]
                    ::SetResponse(cJRetOK)
                Else
                    SetRestFault(500, "Internal server error")
                Endif
            Else
                SetRestFault(412, "Precondition Failed. "+EncodeUTF8(aRet[2]))
            Endif

        Else          
            SetRestFault(402, "Invalid Json")
        Endif
    Else
        SetRestFault(401, "Empty body")
    Endif

    FreeObj(oJson)
    RestArea(aArea)
    RestArea(aAreaSA1)
    RestArea(aAreaSB1)

Return aRet[1]

/*/--------------------------------------------------------------------------/*/
WSMETHOD POST Cancel_b2b WSSERVICE ALIANCAB2B

    Local cBody as String
    Local cCatch as Character 
    Local oJson := JsonObject():New()
    Local cJRetOK := '{"errorCode":201,"status":"success"}'
    Local aRet := {.T.,"",""}
    Local aPropr := {"uid","serie","rps"}
    Local nX := 1
    Local aArea := GetArea()
    Local aPed := {}
    Local cDesc := ""
    Local _cCodEmp	:= SM0->M0_CODIGO
    Local _cCodFil	:= SM0->M0_CODFIL
    Local _cFilNew	:= "01901MG0001"	
    Local cUid := ""
    Local cSerie := ""
    Local cRps := ""
    
    If _cCodEmp+_cCodFil <> _cCodEmp+_cFilNew
        CFILANT := _cFilNew
        opensm0(_cCodEmp+CFILANT)
    Endif

    ::SetContentType("application/json")
    cBody := ::GetContent()
    
    If !Empty(cBody) 

        cBody := DECODEUTF8( cBody )
        
        cCatch := oJson:FromJson(cBody)
        
        If ValType(cCatch) == "U" 

            For nX := 1 to len(aPropr)
                If ValType(oJson:GetJsonObject(aPropr[nX])) == "U"
                    aRet[1] := .F. 
                    aRet[2] := ENCODEUTF8("Propriedade obrigatoria nao localizada. ("+aPropr[nX]+"). ")
                Else
                    If Empty(oJson[aPropr[nX]])
                        aRet[1] := .F. 
                        aRet[2] := ENCODEUTF8("Propriedade tem preenchimento obrigatorio. ("+aPropr[nX]+"). ")
                    Endif    
                Endif
            Next nX

            If aRet[1]
                cUid := "R"+StrZero(oJson['uid'], TamSX3("C5_XIDPLE")[1]-1)
                aPed := ExistOrder( cUid )
                If !aPed[1]
                    cUid := "U"+StrZero(oJson['uid'], TamSX3("C5_XIDPLE")[1]-1)
                    aPed := ExistOrder( cUid )
                Endif
                cRps := oJson['rps']+SPACE(TamSX3("C5_NOTA")[1] - LEN(oJson['rps']))
                cSerie := oJson['serie']+SPACE(TamSX3("C5_SERIE")[1] - LEN(oJson['serie']))
                If aPed[1]
                    If ValType(oJson:GetJsonObject('desc')) == "C"
                        cDesc := oJson['desc']
                    Endif
                    
                    DbSelectArea("SC5")
                    SC5->(DbGoTo(aPed[3,3]))
                    DbSelectArea("SF2")
                    SF2->(DbSetOrder(1))
                    If SF2->(DbSeek(xFilial("SF2")+cRps+cSerie+SC5->(C5_CLIENTE+C5_LOJACLI))) .AND. (!Empty(SF2->F2_NFELETR) .OR. ALLTRIM(cSerie) $ Alltrim(SuperGetMV("CP16_SERNFD",.F.,"")) )
                        aRet := U_CP12ADD("000033", "", 0, '{"event":{"type":"order_cancel_b2b","recno_sf2":'+cValtoChar(SF2->(RECNO()))+',"uid":"'+cUid+'","desc":"'+cDesc+'"}}', )
                    Else
                        aRet[1] := .F.
                        aRet[2] := "Não existe uma nota fiscal para o pedido informado, portando a requisição de cancelamento não pode ser atendida."
                    Endif    
                Else
                    aRet[1] := .F.
                    aRet[2] := "Não existe pedido/nota fiscal para o id informado."
                Endif

                If aRet[1]
                    
                    cJRetOK := '{"code":201,"status":"Success."}'
                    cJRetOK := ENCODEUTF8(cJRetOK)    
                    ::SetResponse(cJRetOK)  

                Elseif !Empty(aRet[2])
                    SetRestFault(422, ENCODEUTF8(aRet[2]) )                      
                Else
                    SetRestFault(500, "Internal server error")
                Endif
            Else
                SetRestFault(412, "Precondition Failed. "+ENCODEUTF8(aRet[2]))
            Endif    
        Else          
            SetRestFault(402, "Invalid Json")
        Endif
    Else
        SetRestFault(401, "Empty body")
    Endif

    FreeObj(oJson)

    RestArea(aArea )

    If _cCodEmp+_cCodFil <> _cCodEmp+_cFilNew
        CFILANT := _cCodFil
        opensm0(_cCodEmp+CFILANT)			 			
    Endif

Return aRet[1]

/*/--------------------------------------------------------------------------/*/
WSMETHOD POST Customer_b2b WSSERVICE ALIANCAB2B

    Local cBody as String
    Local cCatch as Character 
    Local oJson := JsonObject():New()
    Local cJRetOK := '{"errorCode":201,"status":"success"}'
    Local aRet := {.T.,"",""}
    Local aPropr := {"cpf_cnpj","nome","uf","cep","end","end_num","municipio"}
    Local nX := 1
    Local aArea := GetArea()
    Local lAtuCli := SuperGetMV("CP16_ATUCL",.F.,.F.)
    Local nOpc := 3

    ::SetContentType("application/json")
    cBody := ::GetContent()
    
    If !Empty(cBody) 

        cBody := DECODEUTF8( cBody )
        
        cCatch := oJson:FromJson(cBody)
        
        If ValType(cCatch) == "U" 

            For nX := 1 to len(aPropr)
                If ValType(oJson:GetJsonObject(aPropr[nX])) == "U"
                    aRet[1] := .F. 
                    aRet[2] := "Propriedade obrigatoria nao localizada. ("+aPropr[nX]+"). "
                Else
                    If Empty(oJson[aPropr[nX]])
                        aRet[1] := .F. 
                        aRet[2] := "Propriedade tem preenchimento obrigatorio. ("+aPropr[nX]+"). "
                    Endif    
                Endif
            Next nX

            DbSelectArea("SA1")
            SA1->(DbSetOrder(3))
            If !lAtuCli .AND. ValType(oJson:GetJsonObject('cpf_cnpj')) != "U" .AND. SA1->(DbSeek(xFilial("SA1")+Alltrim(oJson['cpf_cnpj'])))
                aRet[1] := .F.
                aRet[2] := " Cliente "+Alltrim(oJson['cpf_cnpj'])+" já existente na base cadastrado com ID "+SA1->A1_COD+"-"+SA1->A1_LOJA+"."
            Elseif lAtuCli .AND. SA1->(DbSeek(xFilial("SA1")+Alltrim(oJson['cpf_cnpj'])))
                nOpc := 4
            Else    
                nOpc := 3    
            Endif

            If aRet[1]
                
                //aRet := U_CP12ADD("000033", "", 0, cBody, )
                aRet := CadCli(oJson, nOpc)

                If aRet[1]
                    If nOpc == 3
                        cJRetOK := '{"errorCode":201,"code":201,"status":"Cliente cadastrado com sucesso!"}'
                    Else
                        cJRetOK := '{"errorCode":201,"code":201,"status":"Cliente '+Alltrim(oJson['cpf_cnpj'])+' já existente na base cadastrado com ID '+SA1->A1_COD+'-'+SA1->A1_LOJA+'. Os dados foram atualizados."}'
                    Endif    
                    
                    cJRetOK := ENCODEUTF8(cJRetOK)    
                    
                    ::SetResponse(cJRetOK)  
                Elseif !Empty(aRet[2])
                    SetRestFault(422, ENCODEUTF8(aRet[2]) )                      
                Else
                    SetRestFault(500, "Internal server error")
                Endif
            Else
                SetRestFault(412, "Precondition Failed. "+ENCODEUTF8(aRet[2]))
            Endif    
        Else          
            SetRestFault(402, "Invalid Json")
        Endif
    Else
        SetRestFault(401, "Empty body")
    Endif

    FreeObj(oJson)

    RestArea(aArea )

Return aRet[1]

/*/--------------------------------------------------------------------------/*/
WSMETHOD POST Webhook WSSERVICE ALIANCAB2B

    Local cBody as String
    Local cCatch as Character 
    Local oJson := JsonObject():New()
    Local cJRetOK := '{"code":201,"status":"success"}'
    Local aRet := {.T.,"",""}
    Local aPropr := {"event"}
    Local nX := 1
    Local aArea := GetArea()

    ::SetContentType("application/json")
    cBody := ::GetContent()
    
    If !Empty(cBody) 

        cBody := DECODEUTF8( cBody )
        
        cCatch := oJson:FromJson(cBody)
        
        If ValType(cCatch) == "U" 

            For nX := 1 to len(aPropr)
                If ValType(oJson:GetJsonObject(aPropr[nX])) == "U" .OR. ValType(oJson[aPropr[nX]]:GetJsonObject('type')) == "U"
                    aRet[1] := .F. 
                    aRet[2] := "Propriedade obrigatoria nao localizada. ("+aPropr[nX]+"). "
                Endif
            Next nX

            If aRet[1]

                aRet := U_CP12ADD("000033", "", 0, cBody, )

                If aRet[1]   
                    cJRetOK := '{"code":201,"status":"Success. Webhook recebido com sucesso!"}'
                    cJRetOK := ENCODEUTF8(cJRetOK)    
                    
                    ::SetResponse(cJRetOK)  
                Elseif !Empty(aRet[2])
                    SetRestFault(422, ENCODEUTF8(aRet[2]) )                      
                Else
                    SetRestFault(500, "Internal server error")
                Endif
            Else
                SetRestFault(412, "Precondition Failed. "+ENCODEUTF8(aRet[2]))
            Endif    
        Else          
            SetRestFault(402, "Invalid Json")
        Endif
    Else
        SetRestFault(401, "Empty body")
    Endif

    FreeObj(oJson)
    RestArea(aArea )

Return aRet[1]


/*/{Protheus.doc} CadCli
    Função Alliar responsavel por cadastrar o cliente recebido
    @type  Static Function
    @author Julio Teixeira
    @since 29/06/2020
    @version 12
    @param cBody, string, Corpo do webhook recebido.
    @return aRet - {Boolean, MsgErro, Conteúdo de retorno}
/*/
Static Function CadCli(oJson, nOpc)

    Local aRet := {.T.,"",""} 
    Local cCliLoj := oJson['cpf_cnpj']
    Local cNatureza := SuperGetMV("ES_NATFINC",.F., "11010001")
    Local cCodMun := ""
    Local aCli := {}
    Local cEnd := ""
    
    Default nOpc := 3
    Default oJson := ""

    If ValType(oJson) == "J" 
        aRet := U_CP16GMUN(,oJson['cep'])
        If aRet[1] 
            cCodMun := aRet[3]
        Endif
        if empty(cCodMun)
            aRet := U_CP16GMUN(oJson['municipio']) 
            If aRet[1]
                cCodMun := aRet[3]    
            Endif
        Endif

        cEnd := Alltrim(oJson['end'])+", "+Alltrim(oJson['end_num'])   
        cEnd := Left(cEnd,TamSx3("A1_END")[1])

        aAdd(aCli,{"A1_COD"    , Left(cCliLoj,TamSx3("A1_COD")[1]) ,Nil})    
        aAdd(aCli,{"A1_LOJA"   , SubStr(cCliLoj, TamSx3("A1_COD")[1]+1, TamSx3("A1_LOJA")[1] ) ,Nil})
        aAdd(aCli,{"A1_CGC"     , Alltrim(oJson['cpf_cnpj']) ,Nil})
        If ValType(oJson:GetJsonObject("razao_social")) != "U" .AND. !Empty(oJson['razao_social'])
            aAdd(aCli,{"A1_NOME"    , Substr(oJson['razao_social'],1,TamSx3("A1_NOME")[1]) ,Nil})
        Else
            aAdd(aCli,{"A1_NOME"    , Substr(oJson['nome'],1,TamSx3("A1_NOME")[1]) ,Nil})
        Endif    
        aAdd(aCli,{"A1_NREDUZ"  , Substr(oJson['nome'],1,TamSx3("A1_NREDUZ")[1]) ,Nil}) 

        aAdd(aCli,{"A1_TIPO"    , "F" ,Nil})
        aAdd(aCli,{"A1_INCISS"  , "S" ,Nil})
        aAdd(aCli,{"A1_END"     , cEnd ,Nil}) 
        aAdd(aCli,{"A1_CODPAIS" , "01058",Nil})
        aAdd(aCli,{"A1_NATUREZ" , cNatureza, Nil})
        aAdd(aCli,{"A1_CEP"     , oJson['cep'] ,Nil}) 
        aAdd(aCli,{"A1_EST"     , Upper(oJson['uf']) ,Nil})
        aAdd(aCli,{"A1_MUN"     , oJson['municipio'] ,Nil})
        aAdd(aCli,{"A1_COD_MUN" , Right(cCodMun,TamSx3("A1_COD_MUN")[1]) ,Nil})
        If len(Alltrim(oJson['cpf_cnpj'])) >= 12
            aAdd(aCli,{"A1_XCLIST" , "1" ,Nil}) // Cliente Novo - Em análise
        Else
            aAdd(aCli,{"A1_XCLIST" , "2" ,Nil}) // Cliente Liberado
        Endif
        aAdd(aCli,{"A1_XTRIBES", "N" ,Nil}) 

        If ValType(oJson:GetJsonObject("id")) == "C"
            aAdd(aCli,{"A1_XIDVIND" , Alltrim(oJson['id']) ,Nil})
        Elseif ValType(oJson:GetJsonObject("id")) == "N"
            aAdd(aCli,{"A1_XIDVIND" , cValtoChar(oJson['id']) ,Nil})
        Endif

        If ValType(oJson:GetJsonObject("inscr")) != "U" 
            aAdd(aCli,{"A1_INSCR"     , oJson['inscr'] ,Nil})
        Endif

        If ValType(oJson:GetJsonObject("ddd")) != "U" 
            aAdd(aCli,{"A1_DDD"     , Right(oJson['ddd'],2) ,Nil})
        Endif

        If ValType(oJson:GetJsonObject("tel_contato")) != "U" 
            aAdd(aCli,{"A1_TEL"     , oJson['tel_contato'] ,Nil})
        Endif

        If ValType(oJson:GetJsonObject("bairro")) != "U" 
            aAdd(aCli,{"A1_BAIRRO"     , oJson['bairro'] ,Nil})
        Endif

        If ValType(oJson:GetJsonObject("complemento")) != "U" 
            aAdd(aCli,{"A1_COMPLEM" , Left(oJson['complemento'],TamSx3("A1_COMPLEM")[1]),Nil})
        Endif

        If ValType(oJson:GetJsonObject("nome_contato")) != "U" 
            aAdd(aCli,{"A1_CONTATO" , oJson['nome_contato'] ,Nil})
        Endif

        If ValType(oJson:GetJsonObject("email")) != "U" 
            aAdd(aCli,{"A1_EMAIL"  , Left(oJson['email'],TamSx3("A1_EMAIL")[1]) ,Nil})
        Endif

        If ValType(oJson:GetJsonObject("insc_mun")) != "U" 
            aAdd(aCli,{"A1_INSCRM"  , Left(oJson['insc_mun'],TamSx3("A1_INSCRM")[1]) ,Nil})
        Endif

        FreeObj(oJson)

        aRet := U_CP16CCLI(aCli, nOpc)
    Endif
Return aRet

/*/{Protheus.doc} ExistOrder

    Funçao para verificar se assinatura existe 

    @type  Function
    @author Julio Teixeira - Compila
    @since 31/03/2020
    @version version
    @param cIdSubs - Id da assinatura
    @return aRet - {Boolean, MsgErro, Lista de periodos encontrados }
/*/
Static Function ExistOrder(cIdSubs)

    Local aRet := {.T.,"",{}}
    Local aArea := GetArea()
    Local cArea  := GetNextAlias()
    Local cQuery := ""

    Default cIdSubs := ""
    
    If !Empty(cIdSubs)
    
        cQuery := "SELECT C5_NUM ,C5_ORIGEM, R_E_C_N_O_ C5_REC "  
        cQuery += "FROM "+RetSqlName("SC5")+" "
        cQuery += "WHERE  " 
        cQuery += "C5_XIDPLE = '" +cIdSubs+ "' "
        cQuery += "AND D_E_L_E_T_ = '' "
        cQuery := ChangeQuery(cQuery)
        DBUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cArea, .T., .T.)  
    
        If (cArea)->(!EOF())

            aRet[3] := { (cArea)->C5_NUM , Alltrim((cArea)->C5_ORIGEM) , (cArea)->C5_REC   }
         
        Else
            aRet[1] := .F.
            aRet[2] := "Nenhuma assinatura encontrada!"
        Endif

        (cArea)->(dbCloseArea())
    Else
        aRet[1] := .F.
        aRet[2] := "Nenhum id informado para busca dos periodos"
    Endif

    RestArea(aArea)

Return aRet
