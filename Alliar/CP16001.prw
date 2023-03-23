#INCLUDE "TOTVS.CH"

User Function CP16001()
Return 

/*/{Protheus.doc} CP16PROC
    Funçao Alliar responsavel por processar o body do webhook recebido pela Vindi
    @type  User Function
    @author Julio Teixeira
    @since 25/03/2020
    @version 12
    @param cBody, string, Corpo do webhook recebido.
    @return aRet - {Boolean, MsgErro, Conteúdo de retorno}
    @example
    @see 
/*/
User Function CP16PROC(cBody)

    Local aRet := {.T.,"",""}
    Local oJson := JsonObject():New()
    Local cCatch := ""
    Local nOper := 3//Inclusao
    Local _cCodEmp	:= SM0->M0_CODIGO
    Local _cCodFil	:= SM0->M0_CODFIL
    Local _cFilNew	:= "01901MG0001"	
    Local cIdInte   := ""
    Local aAssinat := {}
    Local aPeriodo := {}
    Local aPeriods := {}
    Local aSubsc   := {}
    Local nPos     := 0
   
    Default cBody := ""

    /*---------------------------------------
    Realiza a TROCA DA FILIAL CORRENTE SPO
    -----------------------------------------*/
    If _cCodEmp+_cCodFil <> _cCodEmp+_cFilNew
        CFILANT := _cFilNew
        opensm0(_cCodEmp+CFILANT)
    Endif

    cCatch := oJson:FromJson(cBody)

    If Valtype(cCatch) == "U" .AND.;
       ValType(oJson:GetJsonObject("event")) != "U" .AND.;
       ValType(oJson['event']:GetJsonObject("type")) == "C" .AND.;
       ValType(oJson['event']:GetJsonObject("data")) != "U" 

        DO CASE
            CASE oJson['event']['type'] == "subscription_canceled"

                cIdInte := "id" + cValToChar(oJson['event']['data']['subscription']['id'])+"-"
                cIdInte += oJson['event']['type']
                
                BEGIN TRANSACTION

                aRet := U_CP16SUBC(oJson['event']['data'])

                If !aRet[1]
                    DisarmTransaction()
                Endif

                END TRANSACTION 
                //aRet[1] := .F.
                //aRet[2] := "Nenhuma acao implementada para o evento, "+oJson['event']['type']+"."

            CASE oJson['event']['type'] == "subscription_created"

                cIdInte := "id" + cValToChar(oJson['event']['data']['subscription']['id'])+"-"
                cIdInte += oJson['event']['type']

                aRet := U_CP16SUBS(oJson['event']['data'])//Valida e prepara para gravacao
                If aRet[1]

                    BEGIN TRANSACTION

                    aRet := U_CP16GPED(aClone(aRet[3][1]), aClone(aRet[3][2]), nOper)//Chama execauto MATA410
                    If aRet[1] .AND. ExistFunc("U_CP16ASS1")
                        aAdd(aAssinat,{"ZZC_CODASS",cValtoChar(oJson['event']['data']['subscription']['id'])})
                        aAdd(aAssinat,{"ZZC_CODCLI",SC5->C5_CLIENTE})
                        aAdd(aAssinat,{"ZZC_LOJCLI",SC5->C5_LOJACLI})
                        aAdd(aAssinat,{"ZZC_DTASSI",StoD(Left(StrTran(oJson['event']['data']['subscription']['start_at'],"-",""),8))})
                        aAdd(aAssinat,{"ZZC_STATUS", Iif(oJson['event']['data']['subscription']['status']=="active","1","0")})
                        aAdd(aAssinat,{"ZZC_DADOS",cBody})

                        aAdd(aPeriodo,{"ZZD_CODPER",cValtoChar(oJson['event']['data']['subscription']['current_period']['id'])})
                        aAdd(aPeriodo,{"ZZD_CICLO", StrZero(oJson['event']['data']['subscription']['current_period']['cycle'],3)})
                        aAdd(aPeriodo,{"ZZD_CODASS", cValtoChar(oJson['event']['data']['subscription']['id'])})
                        aAdd(aPeriodo,{"ZZD_DTINIC", StoD(Left(StrTran(oJson['event']['data']['subscription']['current_period']['start_at'],"-",""),8)) })
                        aAdd(aPeriodo,{"ZZD_DTFIM", StoD(Left(StrTran(oJson['event']['data']['subscription']['current_period']['end_at'],"-",""),8)) })
                        aAdd(aPeriodo,{"ZZD_ESTORN", "2" })//"2=Não"

                        aAdd(aPeriods,aPeriodo)

                        aRet := U_CP16ASS1(aAssinat,aPeriods,3)//Inclusão de nova assinatura               
                    Endif

                    If !aRet[1]
                        DisarmTransaction()
                    Endif

                    END TRANSACTION 

                Endif
                
            CASE oJson['event']['type'] == "subscription_reactivated"
                
                aRet[1] := .F.
                aRet[2] := "Nenhuma acao implementada para o evento, "+oJson['event']['type']+"."

            CASE oJson['event']['type'] == "charge_created"
            
                aRet[1] := .F.
                aRet[2] := "Nenhuma acao implementada para o evento, "+oJson['event']['type']+"."

            CASE oJson['event']['type'] == "charge_refunded"

                cIdInte := "id" + cValToChar(oJson['event']['data']['charge']['id'])+"-"
                cIdInte += oJson['event']['type']

                BEGIN TRANSACTION

                aRet := U_CP16CREF(oJson['event']['data'])//Valida e prepara para gravacao
                
                If !aRet[1]
                    DisarmTransaction()
                Endif
                END TRANSACTION
                //aRet[1] := .F.
                //aRet[2] := "Nenhuma acao implementada para o evento, "+oJson['event']['type']+"."
                
            CASE oJson['event']['type'] == "charge_canceled"

                aRet[1] := .F.
                aRet[2] := "Nenhuma acao implementada para o evento, "+oJson['event']['type']+"."

            CASE oJson['event']['type'] == "charge_rejected"

                aRet[1] := .F.
                aRet[2] := "Nenhuma acao implementada para o evento, "+oJson['event']['type']+"."

            CASE oJson['event']['type'] == "bill_created"

                aRet[1] := .F.
                aRet[2] := "Nenhuma acao implementada para o evento, "+oJson['event']['type']+"."

            CASE oJson['event']['type'] == "bill_paid"
                
                cIdInte := "id" + cValToChar(oJson['event']['data']['bill']['id'])+"-"
                cIdInte += oJson['event']['type']

                BEGIN TRANSACTION

                aRet := U_CP16BILP(oJson['event']['data'])//Valida e prepara para gravacao
                
                If !aRet[1]
                    DisarmTransaction()
                Endif
                END TRANSACTION

            CASE oJson['event']['type'] == "bill_canceled"
                
                aRet[1] := .F.
                aRet[2] := "Nenhuma acao implementada para o evento, "+oJson['event']['type']+"."

            CASE oJson['event']['type'] == "bill_seen"
                
                aRet[1] := .F.
                aRet[2] := "Nenhuma acao implementada para o evento, "+oJson['event']['type']+"."

            CASE oJson['event']['type'] == "period_created"
                
                cIdInte := "id"+cValToChar(oJson['event']['data']['period']['id'])+"-"
                cIdInte += cValToChar(oJson['event']['data']['period']['cycle'])+"-"
                cIdInte += oJson['event']['type']

                aRet := U_CP16PERI(oJson['event']['data'])//Valida e prepara para gravacao
                
                BEGIN TRANSACTION

                    If aRet[1] .AND. ValType(aRet[3]) == "A" .AND. ValType(aRet[3][1]) == "A"
                        aRet := U_CP16GPED(aClone(aRet[3][1]), aClone(aRet[3][2]), nOper)//Chama execauto MATA410
                    Endif

                    If aRet[1] .AND. ExistFunc("U_CP16ASS1")
                        aAdd(aAssinat,{"ZZC_CODASS",cValtoChar(oJson['event']['data']['period']['subscription']['id'])})

                        aAdd(aPeriodo,{"ZZD_CODPER", cValtoChar(oJson['event']['data']['period']['id'])})
                        aAdd(aPeriodo,{"ZZD_CICLO", StrZero(oJson['event']['data']['period']['cycle'],3)})
                        aAdd(aPeriodo,{"ZZD_CODASS", cValtoChar(oJson['event']['data']['period']['subscription']['id'])})
                        aAdd(aPeriodo,{"ZZD_DTINIC", StoD(Left(StrTran(oJson['event']['data']['period']['start_at'],"-",""),8)) })
                        aAdd(aPeriodo,{"ZZD_DTFIM", StoD(Left(StrTran(oJson['event']['data']['period']['end_at'],"-",""),8)) })
                        aAdd(aPeriodo,{"ZZD_DADOS", cBody})
                        If ValType(oJson['event']['data']['period']['usages'][1]['bill']) == "J"
                            aAdd(aPeriodo,{"ZZD_IDBILL", cValtoChar(oJson['event']['data']['period']['usages'][1]['bill']['id']) })
                        Endif
                        aAdd(aPeriods,aPeriodo)

                        aRet := U_CP16ASS1(aAssinat,aPeriods,4)//Inclusão de novo periodo

                    Endif

                    If aRet[1] .AND. ValType(oJson['event']['data']['period']['usages'][1]['bill']) == "J"
                        aSubsc := ExistSubs( "V"+StrZero(oJson['event']['data']['period']['subscription']['id'],TamSX3("C5_XIDPLE")[1]-1))
                        If aSubsc[1] 
                            nPos := aScan(aSubsc[3][2],"V"+cValToChar(oJson['event']['data']['period']['id']))
                            If nPos > 0
                                DbSelectArea("SC5")
                                SC5->(DbGoTo(aSubsc[3][3][nPos]))
                                //Gera SZ7 
                                aRet := GrvPagto( cValToChar(oJson['event']['data']['period']['usages'][1]['bill']['id']),SC5->C5_NUM)
                            Endif    
                        Endif    
                    Endif
                    If !aRet[1]
                        DisarmTransaction()
                    Endif
                END TRANSACTION

            CASE oJson['event']['type'] == "issue_created"
                
                aRet[1] := .F.
                aRet[2] := "Nenhuma acao implementada para o evento, "+oJson['event']['type']+"."

            CASE oJson['event']['type'] == "payment_profile_created"
                
                aRet[1] := .F.
                aRet[2] := "Nenhuma acao implementada para o evento, "+oJson['event']['type']+"."

            CASE oJson['event']['type'] == "message_seen"
                
                aRet[1] := .F.
                aRet[2] := "Nenhuma acao implementada para o evento, "+oJson['event']['type']+"."

            OTHERWISE
                
                aRet[1] := .F.
                aRet[2] := "Evento, "+oJson['event']['type']+", nao esperado"

        END CASE    

        Reclock("ZD1",.F.)
            ZD1->ZD1_IDINTE := Left( cIdInte ,TamSx3("ZD1_IDINTE")[1])
        ZD1->(MsUnlock())

    Else   
        aRet[1] := .F.
        aRet[2] := "Problema ao acessar as entidades: event, type, data. "
        aRet[2] += "Uma ou mais entidade nao encontradas na estrutua"
    Endif

    /*---------------------------------------
        Restaura FILIAL  
    -----------------------------------------*/
    If _cCodEmp+_cCodFil <> _cCodEmp+_cFilNew
        CFILANT := _cCodFil
        opensm0(_cCodEmp+CFILANT)			 			
    Endif

    FreeObj(oJson)

Return aRet

/*/{Protheus.doc} CP16SUBS
    Funçao Alliar responsavel por validar a existência de todos os dados necessarios para geracao do pedido
    @type  User Function
    @author Julio Teixeira
    @since 25/03/2020
    @version 12
    @param oJson, Objeto json com dados da Vindi
    @return aRet - {Boolean, MsgErro, Array para inclusao do pedido}
    @example
    @see 
/*/
User Function CP16SUBS(oJson)

    Local aRet := {.T.,"",""}
    Local cCliVindId := ""
    Local cEndPoint := SuperGetMV("CP16_URLVI",.F.,"https://sandbox-app.vindi.com.br/api")
    Local cChave := SuperGetMV("CP16_CHVVI",.F.,"8GWJghISrCMYkLypxRd8q6bkqxlEgP5mLrRLNSc-I5g")
    Local cCondPag := ""
    Local cCodProd := ""
    Local aArea := GetArea()
    Local aAreaSA1 := SA1->(GetArea())
    Local aCab := {}
    Local aLinha := {}
    Local aItens := {}
    Local cProdTrime := SuperGetMV("CP16_PTRIM",.F.,"")
    Local cProdSemes := SuperGetMV("CP16_PSEME",.F.,"")
    Local cProdAnual := SuperGetMV("CP16_PANUA",.F.,"")
    Local cMsgNf := SuperGetMV("CP16_MSGNF",.F.,"")
    Local cTesPed := SuperGetMV("ES_TESCON",.F.,"501")
    Local lAtuCli := SuperGetMV("CP16_ATUCL",.F.,.F.)
    Local cCliLoj := ""
    Local oCli 
    Local aCli := {}
    Local nX := 1
    Local nPreco := ""
    Local cIdSubs := ""
    Local cIdPeriod := ""
    Local cCusto := U_FSCustoFil(Alltrim(SM0->M0_CGC)) 

    Default oJson := ""

    If Right(cEndPoint,1) == "/"//Tratamento da url para nao duplicar a barra
        cEndPoint := Left(cEndPoint, len(cEndPoint)-1)//Remove barra do final
    Endif

    //Valida existência do Id na estrutura
    If ValType(oJson:GetJsonObject("subscription")) != "U" .AND.;
       ValType(oJson['subscription']:GetJsonObject("customer")) != "U" .AND.;
       ValType(oJson['subscription']['customer']:GetJsonObject("id")) != "U"
        
        //Verifica se o Id da venda ja foi processado antes
        cIdSubs := "V"+StrZero(oJson['subscription']['id'],TamSx3("C5_XIDPLE")[1]-1)
        
        If ExistSubs(cIdSubs)[1]
            aRet[1] := .F.
            aRet[2] := "Pedido nao incluido. Id do pedido ja processado: "+cIdSubs
            conout(aRet[2])
        Endif

        If aRet[1]
            cCliVindId := cValtoChar(oJson['subscription']['customer']['id'])
            //Realiza validacao do cliente na base
            aRet := ExistCli(cCliVindId)
            If aRet[1]
                Conout("Cliente e Id ja cadastrado")
                cCliLoj := aRet[3]
            Else
                
                aCli := U_CP16GET(cEndPoint, "/v1/customers/"+cCliVindId, cChave, "")
                If aCli[1]
                    oCli := aCli[3]
                    If ValType(oCli:GetJsonObject("customer")) != "U" .AND.;
                    ValType(oCli['customer']:GetJsonObject("registry_code")) != "U"
                        
                        SA1->(DbSetOrder(1))//Filial+cod+loja
                        If SA1->(DbSeek(xFilial("SA1")+oCli['customer']['registry_code']))
                            RecLock("SA1",.F.)//Atualiza o cliente com ID da Vindi
                                SA1->A1_XIDVIND := cCliVindId
                            SA1->(MsUnlock())
                            Conout("Cliente encontrado e vinculado com id Vindi")
                            cCliLoj := Alltrim(SA1->A1_COD+SA1->A1_LOJA)
                        Else
                            aRet := CadCliente(oCli)//Static Func. para preparar e chamar o cadastro de cliente
                            cCliLoj := aRet[3]
                        Endif
                    Else
                        aRet[1] := .F.
                        aRet[2] := "Falha ao obter as entidades, 'customer', 'id' e 'registry_code'."    
                    Endif    
                Else
                    aRet[1] := aCli[1]
                    aRet[2] := aCli[2]
                Endif    
            Endif
        Endif
        //Atualiza dados do cliente com os dados da Vindo - CP16_ATUCLI
        If aRet[1] .AND. lAtuCli
            If Valtype(oCli) != "J" 
                aCli := U_CP16GET(cEndPoint, "/v1/customers/"+cCliVindId, cChave, "")
                If aCli[1]
                    oCli := aCli[3]
                    aRet := CadCliente(oCli,cCliLoj)//Static Func. para preparar e chamar o cadastro de cliente
                Else
                    aRet[1] := aCli[1]
                    aRet[2] := aCli[2]
                Endif    
            Else
                aRet := CadCliente(oCli,cCliLoj)//Static Func. para preparar e chamar o cadastro de cliente
            Endif
        Endif

        //Valida condiçao de pagamento
        If aRet[1]
            cCondPag := "V"+ StrZero(oJson['subscription']['installments'],2)
        Endif

        //Utiliza o produto de acordo com o tipo de plano
        If aRet[1] 
            If oJson['subscription']['interval'] == "months" 
                If oJson['subscription']['interval_count'] == 3
                    cCodProd := cProdTrime
                Elseif oJson['subscription']['interval_count'] == 6
                    cCodProd := cProdSemes
                Elseif oJson['subscription']['interval_count'] == 12
                    cCodProd := cProdAnual
                Else
                    cCodProd := cProdAnual    
                Endif
            Else
                cCodProd := cProdAnual
            Endif
        Endif

        //Monta arrays do pedido de venda
        If aRet[1]

            aAdd(aCab,{"C5_TIPO",       "N",            Nil})
            aAdd(aCab,{"C5_CLIENTE",    Left(cCliLoj,TamSx3("A1_COD")[1]) ,  Nil})
            aAdd(aCab,{"C5_LOJACLI",    SubStr(cCliLoj, TamSx3("A1_COD")[1]+1, TamSx3("A1_LOJA")[1] ) , Nil})
            aAdd(aCab,{"C5_CLIENT",     Left(cCliLoj,TamSx3("A1_COD")[1]),   Nil})
            aAdd(aCab,{"C5_LOJAENT",    SubStr(cCliLoj, TamSx3("A1_COD")[1]+1, TamSx3("A1_LOJA")[1] ) , Nil})
            aAdd(aCab,{"C5_TIPOCLI",    "F",            Nil})
            aAdd(aCab,{"C5_CONDPAG",    cCondPag ,      Nil})
            aAdd(aCab,{"C5_MENNOTA",    Left(cMsgNf,TamSX3("C5_MENNOTA")[1]) , Nil})
            aAdd(aCab,{"C5_XIDPLE",     cIdSubs ,       Nil})
            cIdPeriod := cValtoChar(oJson['subscription']['current_period']['id'])
            aAdd(aCab,{"C5_ORIGEM",     "V"+cIdPeriod , Nil})

            For nX := 1 to len(oJson['subscription']['product_items'])
                
                nPreco := Val(oJson['subscription']['product_items'][nX]['pricing_schema']['price'])
                
                aadd(aLinha,{"C6_ITEM",    StrZero(1,TamSx3("C6_ITEM")[nX]), Nil})
                aadd(aLinha,{"C6_PRODUTO", cCodProd,        Nil})
                aadd(aLinha,{"C6_TES",     cTesPed,        Nil})
                aadd(aLinha,{"C6_QTDVEN",  oJson['subscription']['product_items'][nX]['quantity'], Nil})
                aadd(aLinha,{"C6_PRCVEN",  nPreco , Nil})
                aadd(aLinha,{"C6_PRUNIT",  nPreco , Nil})
                aadd(aLinha,{"C6_VALOR",   nPreco*oJson['subscription']['product_items'][nX]['quantity'] , Nil})
                If  len(oJson['subscription']['product_items'][nX]['discounts']) >= 1
                    If oJson['subscription']['product_items'][nX]['discounts'][1]['discount_type'] == "percentage"
                        aadd(aLinha,{"C6_DESCONT", Val(oJson['subscription']['product_items'][nX]['discounts'][1]['percentage']) , Nil})
                    Else
                        aadd(aLinha,{"C6_VALDESC", Val(oJson['subscription']['product_items'][nX]['discounts'][1]['amount'])  , Nil})
                    Endif    
                Endif 
                If !Empty(cCusto)
                    aadd(aLinha,{"C6_CCUSTO",  cCusto , Nil})
                Endif
                    
                aadd(aItens, aLinha)
            Next nX
            aRet[3] := {aCab,aItens}
        Endif

    Else
        aRet[1] := .F.
        aRet[2] := "Problema na estrutura do objeto recebido, "
        aRet[2] += "Falha ao obter propriedade 'id' do cliente."
        aRet[3] := ""
    Endif

    FreeObj(oJson)
    FreeObj(oCli)
    RestArea(aAreaSA1)
    RestArea(aArea)

Return aRet

/*/{Protheus.doc} CP16SUBC
    Funçao Alliar responsavel por realizar o cancelamento da assinatura
    @type  User Function
    @author Julio Teixeira
    @since 25/03/2020
    @version 12
    @param oJson, Objeto json com dados da Vindi
    @return aRet - {Boolean, MsgErro, Array para inclusao do pedido}
/*/
User Function CP16SUBC(oJson)

    Local aRet := {.T.,"",""}
    Local aAssinat := {}
    Local cIdPeriod := ""
    Local cIdSubs := ""
    Local nPos := 0
    Local dDtCanc := StoD(StrTran(Left(oJson['subscription']['end_at'],10),"-",""))
    Local aArea := GetArea()
    Local aAreaSC5 := SC5->(GetArea())
    Local aAreaSF2 := SF2->(GetArea())
    Local aRetTit := {}
    Local cTxtEmail := ""
    Local nX := 1 
    Local cDesEmail := SuperGetMV("CP16_MAILC",.F.,"") 
    Local cMotBx := SuperGetMV("CP16_MOTBX",.F.,"DAC") 

    Default oJson := ""

    //Atualiza o controle de assinaturas
    cIdSubs := "V"+StrZero(oJson['subscription']['id'],TamSx3("C5_XIDPLE")[1]-1)

    aAdd(aAssinat,{"ZZC_CODASS",cValtoChar(oJson['subscription']['id'])})
    aAdd(aAssinat,{"ZZC_STATUS", "0" })
    aAdd(aAssinat,{"ZZC_DTCANC",dDtCanc})
    aRet := U_CP16ASS1(aAssinat,{},4)

    If aRet[1]

        aRet := ExistSubs(cIdSubs)
        If aRet[1]
            cIdPeriod := "V"+cValToChar(oJson['subscription']['current_period']['id'])
            nPos := aScan(aRet[3][2], cIdPeriod)
            If nPos > 0
                DbSelectArea("SC5")
                SC5->(DbGoTo(aRet[3][3][nPos]))
                RecLock("SC5", .F.)    
                    SC5->C5_XBLQ := ""
                    SC5->C5_XELIMRE := "S"
                SC5->(MsUnlock())
            
                //Monta o texto do e-mail antes de excluir a nota
                cTxtEmail := "<h3><div>A assinatura com ID "+cIdSubs+" foi cancelada e não foi possível realizar o cancelamento da nota fiscal.</div>"+CRLF
                cTxtEmail += "<div> Verifique as ações necessárias.</div> </h3>"+CRLF+CRLF

                cTxtEmail += "<h3> <div>Unidade: "+SC5->C5_FILIAL+"</div>"+CRLF
                cTxtEmail += " <div>Cliente: "+SC5->C5_CLIENTE+SC5->C5_LOJACLI+" - "+POSICIONE("SA1",1,xFilial("SA1")+SC5->C5_CLIENTE+SC5->C5_LOJACLI,"A1_NOME")+"</div>"+CRLF
                DbSelectArea("SF2")
                SF2->(DbSetorder(1))
                If !Empty(SC5->C5_NOTA) .AND. SF2->(DbSeek(xFilial("SF2")+SC5->C5_NOTA+SC5->C5_SERIE))  
                    cTxtEmail += "<h3><div> RPS: "+SC5->C5_SERIE+"-"+SC5->C5_NOTA+"</div>"+CRLF
                    cTxtEmail += "<div> Nota Fiscal: "+SF2->F2_NFELETR+"</div>"+CRLF
                    cTxtEmail += "<div> Data: "+dtoc(SF2->F2_EMISSAO)+"</div>"+CRLF
                    cTxtEmail += "<div> Valor: R$ "+StrTran(StrZero(SF2->F2_VALFAT,6,2),".",",")+"</div></h3>"+CRLF
                ENDIF

                aRetTit := ExistBx(SC5->C5_NOTA, SC5->C5_SERIE, SC5->C5_CLIENTE, SC5->C5_LOJACLI)

                If dDtCanc - ZZC->ZZC_DTASSI <= 7 .AND. !aRetTit[1]

                    If !Empty(SC5->C5_NOTA)
                        //Chama exclusão do documento de saída
                        aRet := U_CP16EXCD(SC5->C5_NOTA,SC5->C5_SERIE)
                    Endif

                    If aRet[1]
                        aRet :=  U_CP16RESI(SC5->C5_NUM)
                    Endif

                Else

                    For nX := 1 to len(aRetTit[3][2])
                        aRet := U_CP16BTIT(aRetTit[3][2][nX],cMotBx,"","","", 0, 0 , dDataBase,"BX AUT CANC ASS C.ALIANÇA")
                        If !aRet[1]
                            aRet[2] := "Falha ao tentar realizar baixa dos títulos."
                            Exit
                        Endif
                    Next nX
        
                Endif  

                If !aRet[1] 

                    If !U_CP16MAIL("[Cartão Aliança] Cancelamento de Assinatura "+cIdSubs,cTxtEmail,cDesEmail)
                        aRet[1] := .F.
                        aRet[2] := "Falha no envio de e-mail de alerta sobre falha de cancelamento da assinatura."
                    Endif

                Endif
            Else
                aRet[1] := .F.
                aRet[2] := "Pedido referente a assinatura cancelada não encontrado."    
            Endif
        Endif      
    Else    
        aRet[1] := .F.
        If Empty(aRet[2])    
            aRet[2] := "Falha ao atualizar o controle de assinaturas." 
        Endif    
    Endif

    RestArea(aAreaSF2)
    RestArea(aAreaSC5)
    RestArea(aArea)
    FreeObj(oJson)

Return aRet


/*/{Protheus.doc} CP16PERI
    Funçao Alliar responsavel por validar a existência de todos os dados necessarios para geracao do pedido
    @type  User Function
    @author Julio Teixeira
    @since 31/03/2020
    @version 12
    @param oJson, Objeto json com dados da Vindi
    @return aRet - {Boolean, MsgErro, Array para inclusao do pedido}
/*/
User Function CP16PERI(oJson)

    Local aRet := {.T.,"",""}
    Local cIdSubs := ""
    Local cIdPeriod := ""
    Local aCab := {}
    Local aLinha := {}
    Local aItens := {}
    Local aArea := GetArea()
    Local aAreaSC5 := SC5->(GetArea())
    Local aAreaSC6 := SC6->(GetArea())

    Default oJson := ""
    
    //Valida existência do Id na estrutura
    If ValType(oJson:GetJsonObject("period")) != "U" .AND.;
       ValType(oJson['period']:GetJsonObject("subscription")) != "U" .AND.;
       ValType(oJson['period']['subscription']:GetJsonObject("id")) != "U"

        //Verifica se o Id da assinatura ja foi processado antes
        cIdSubs := "V"+StrZero(oJson['period']['subscription']['id'],TamSx3("C5_XIDPLE")[1]-1)
        cIdPeriod := "V"+cValtoChar(oJson['period']['id'])
        aRet := ExistSubs(cIdSubs)
        If aRet[1] 
            If aScan(aRet[3][2],cIdPeriod) <= 0 

                DbSelectArea("SC5")
                SC5->(DbSetOrder(1))
                If SC5->(DbSeek(xFilial("SC5")+aRet[3][1]))

                    aAdd(aCab,{"C5_TIPO",       SC5->C5_TIPO,      Nil})
                    aAdd(aCab,{"C5_CLIENTE",    SC5->C5_CLIENTE ,  Nil})
                    aAdd(aCab,{"C5_LOJACLI",    SC5->C5_LOJACLI ,  Nil})
                    aAdd(aCab,{"C5_CLIENT",     SC5->C5_CLIENT ,   Nil})
                    aAdd(aCab,{"C5_LOJAENT",    SC5->C5_LOJAENT ,  Nil})
                    aAdd(aCab,{"C5_TIPOCLI",    SC5->C5_TIPOCLI ,  Nil})
                    aAdd(aCab,{"C5_CONDPAG",    SC5->C5_CONDPAG ,  Nil})
                    aAdd(aCab,{"C5_XIDPLE",     cIdSubs ,          Nil})
                    aAdd(aCab,{"C5_ORIGEM",     cIdPeriod ,        Nil})
                    aAdd(aCab,{"C5_MENNOTA",    SC5->C5_MENNOTA ,        Nil})
                    
                    DbSelectArea("SC6")
                    SC6->(DbSetOrder(1))
                    If SC6->(DbSeek(xFilial("SC6")+SC5->C5_NUM))
                        While SC6->C6_FILIAL == SC5->C5_FILIAL .AND. SC6->C6_NUM == SC5->C5_NUM
                            aadd(aLinha,{"C6_ITEM",    SC6->C6_ITEM , Nil})
                            aadd(aLinha,{"C6_PRODUTO", SC6->C6_PRODUTO , Nil})
                            aadd(aLinha,{"C6_TES",     SC6->C6_TES , Nil})
                            aadd(aLinha,{"C6_QTDVEN",  SC6->C6_QTDVEN , Nil})
                            aadd(aLinha,{"C6_PRCVEN",  SC6->C6_PRCVEN , Nil})
                            aadd(aLinha,{"C6_PRUNIT",  SC6->C6_PRUNIT , Nil})
                            aadd(aLinha,{"C6_VALOR",   SC6->C6_VALOR , Nil})
                            If SC6->C6_VALDESC > 0
                                aRet := CyclesDesc(cValtoChar(oJson['period']['subscription']['id']) , __hextodec(SC6->C6_ITEM))
                                If aRet[1] .AND. aRet[3] >= oJson['period']['cycle']
                                    aadd(aLinha,{"C6_VALDESC", SC6->C6_VALDESC  , Nil})
                                Endif    
                            Endif
                            If !Empty(SC6->C6_CCUSTO )
                                aadd(aLinha,{"C6_CCUSTO",  SC6->C6_CCUSTO , Nil})
                            Endif
                            
                            aadd(aItens, aLinha)

                            SC6->(DbSkip())
                        Enddo    
                    Else
                        aRet[1] := .F.
                        aRet[2] := "Falha ao localizar os itens da assinatura."
                    Endif
                
                    aRet[3] := {aCab, aItens} 
                Else
                    aRet[1] := .F.
                    aRet[2] := "Falha ao localizar assinatura."
                Endif    
            Else
                aRet[1] := .T.
                aRet[2] := "Periodo processado ja tem pedido gerado."
            Endif
        Else
            aRet[1] := .F.
            aRet[2] := "Pedido/Assinatura referente ao periodo nao encontrada. "
            aRet[2] += "Os eventos de periodo so sao processados apos existir uma assinatura."
        Endif
    Else
        aRet[1] := .F.
        aRet[2] := "Problema na estrutura do objeto recebido."
        aRet[2] += "Falha ao obter propriedade 'id' da assinatura."
    Endif

    RestArea(aAreaSC6)
    RestArea(aAreaSC5)
    RestArea(aArea)

    FreeObj(oJson)    

Return aRet

/*/{Protheus.doc} CP16BILP
    Funçao Alliar responsavel por validar o pagamento da fatura e atualizar os campos necessários
    @type  User Function
    @author Julio Teixeira
    @since 31/03/2020
    @version 12
    @param oJson, Objeto json com dados da Vindi
    @return aRet - {Boolean, MsgErro, Array para inclusao do pedido}
/*/
User Function CP16BILP(oJson)

    Local aRet := {.T.,"",""}
    Local cIdSubs := ""
    Local cIdPeriod := ""
    Local aArea := GetArea()
    Local aAreaSC5 := SC5->(GetArea())
    Local aAreaZZD := ZZD->(GetArea())
    Local aAreaSZ7 := SZ7->(GetArea())
    Local nPos := 0

    Default oJson := ""
    
    //Valida existência do Id na estrutura
    If ValType(oJson:GetJsonObject("bill")) != "U" .AND.;
       ValType(oJson['bill']:GetJsonObject("subscription")) != "U" .AND.;
       ValType(oJson['bill']['subscription']:GetJsonObject("id")) != "U" .AND.;
       ValType(oJson['bill']:GetJsonObject("period")) != "U" .AND.;
       ValType(oJson['bill']['period']:GetJsonObject("id")) != "U" 

        cIdSubs := "V"+StrZero(oJson['bill']['subscription']['id'],TamSx3("C5_XIDPLE")[1]-1)
        cIdPeriod := "V"+cValtoChar(oJson['bill']['period']['id'])

        aRet := ExistSubs(cIdSubs)
        If aRet[1]
            //Verifica e atualiza o pedido de venda
            nPos := aScan(aRet[3][2],cIdPeriod)
            If nPos > 0 
                DbSelectArea("SC5")
                SC5->(DbGoTo(aRet[3][3][nPos]))
                RecLock("SC5",.F.)
                   SC5->C5_XBLQ := "4"//Flag para que o pedido seja faturado      
                SC5->(MsUnlock())
            Else
                aRet[1] := .F. 
                aRet[2] := "Período referente ao evento não encontrado, verifique se os eventos de período desta assiantura já foram processados."
            Endif
            
            //Atualiza o id da fatura no controle de assinaturas 
            If aRet[1]    
                DbSelectArea("ZZD")
                ZZD->(DbSetOrder(1))
                If ZZD->(DbSeek(xFilial("ZZD")+cValtoChar(oJson['bill']['period']['id'])))
                    RecLock("ZZD",.F.)
                        ZZD->ZZD_IDBILL := cValtoChar(oJson['bill']['id'])//Flag para que o pedido seja faturado      
                    ZZD->(MsUnlock())
                Else
                    aRet[1] := .F. 
                    aRet[2] := "Controle de assinatura referente ao evento não encontrada, verifique se os eventos de assinatura e período já foram processados."
                Endif
            Endif

            //Verifica se o pagamento foi registrado na tabela SZ7 caso não, faz o registro
            DbSelectArea("SZ7")
            SZ7->(DbSetOrder(1))
            If aRet[1] .AND. SZ7->(!DbSeek(xFilial("SZ7")+SC5->C5_NUM))
                aRet := GrvPagto( cValToChar(oJson['bill']['id']),SC5->C5_NUM)
            Endif

        Else
            aRet[1] := .F. 
            aRet[2] := "Pedido referente ao evento não encontrado, verifique se os eventos de assinatura e período já foram processados."
        Endif

        FreeObj(oJson)
    Else
        aRet[1] := .F. 
        aRet[2] := "Falha na estrutura do JSON."          
    Endif

    FreeObj(oJson)    
    RestArea(aArea)
    RestArea(aAreaSC5)
    RestArea(aAreaZZD)
    RestArea(aAreaSZ7)

Return aRet

/*/{Protheus.doc} CP16CREF
    Funçao Alliar responsavel por estornar o pagamento da fatura e atualizar os campos necessários
    @type  User Function
    @author Julio Teixeira
    @since 27/05/2020
    @version 12
    @param oJson, Objeto json com dados da Vindi
    @return aRet - {Boolean, MsgErro, Array para inclusao do pedido}
/*/
User Function CP16CREF(oJson)

    Local aRet := {.T.,"",}
    Local aArea := GetArea()
    Local cEndPoint := SuperGetMV("CP16_URLVI",.F.,"https://sandbox-app.vindi.com.br/api")
    Local cChave := SuperGetMV("CP16_CHVVI",.F.,"8GWJghISrCMYkLypxRd8q6bkqxlEgP5mLrRLNSc-I5g")
    Local aBill := {}
    Local cIdSubs := ""
    Local cTxtEmail := ""
    Local cDesEmail := SuperGetMV("CP16_MAILE",.F.,"julio.teixeira@compila.com.br") 
    Local cQuery := ""
    Local cAlias := GetNextAlias()
    Local oBill

    Default oJson := ""

    //Valida existência do Id na estrutura
    If ValType(oJson:GetJsonObject("charge")) != "U" .AND.;
       ValType(oJson['charge']:GetJsonObject("bill")) != "U" .AND.;
       ValType(oJson['charge']['bill']:GetJsonObject("id")) != "U"

        aBill := U_CP16GET(cEndPoint, "/v1/bills/"+cValtoChar(oJson['charge']['bill']['id']), cChave, "")

        If aBill[1]

            oBill := aBill[3]

            cIdSubs := "V"+StrZero(aBill[3]['bill']['subscription']['id'],TamSx3("C5_XIDPLE")[1]-1)

            DbSelectArea("ZZD")
            ZZD->(DbSetOrder(1))
            If ZZD->(DbSeek(xFilial("ZZD")+cValtoChar(oBill['bill']['period']['id'])))
                RecLock("ZZD",.F.)
                    ZZD->ZZD_ESTORN := "1" //1=SIM    
                ZZD->(MsUnlock())

                cQuery := " SELECT F2_FILIAL, F2_CLIENTE, F2_LOJA, A1_NOME, F2_DOC, F2_SERIE, F2_NFELETR, F2_EMINFE, F2_EMISSAO"
                cQuery += " FROM "+RetSqlName("SC5")+" SC5"
                cQuery += " INNER JOIN "+RetSqlName("SA1")+" SA1 ON A1_COD = C5_CLIENTE AND A1_LOJA = C5_LOJACLI AND SA1.D_E_L_E_T_ = ''"
                cQuery += " INNER JOIN "+RetSqlName("SF2")+" SF2 ON C5_NOTA = F2_DOC AND C5_SERIE = F2_SERIE AND C5_CLIENTE = F2_CLIENTE AND SC5.D_E_L_E_T_ = ''"
                cQuery += " WHERE SF2.D_E_L_E_T_ = '' "
                cQuery += " AND C5_XIDPLE = '"+cIdSubs+"'"
                cQuery += " AND C5_ORIGEM = 'V"+cValtoChar(oBill['bill']['period']['id'])+"'"
                cQuery := ChangeQuery(cQuery)
                DbUseArea(.T., "TOPCONN", TcGenQry(NIL, NIL, cQuery), cAlias, .T., .T.)
                
                cTxtEmail := "<h3><div> A assinatura com ID "+cIdSubs+" foi cancelada e houve solicitação de estorno de pagamento.</div>"
                cTxtEmail += "<div> Verifique as ações necessárias.</div></h3>"+CRLF+CRLF

                If (cAlias)->(!EOF())

                    cTxtEmail += "<h3><div> Unidade: "+(cAlias)->F2_FILIAL+" </div>"
                    cTxtEmail += "<div> Cliente: "+(cAlias)->(F2_CLIENTE+F2_LOJA)+" - "+(cAlias)->A1_NOME+" </div>"
                    cTxtEmail += "<div> RPS: "+(cAlias)->F2_SERIE+"-"+(cAlias)->F2_DOC+" </div>"
                    If !Empty((cAlias)->F2_NFELETR)
                        cTxtEmail += "<div> Nota Fiscal: "+(cAlias)->F2_NFELETR+" </div>"
                    Endif    
                    cTxtEmail += "<div> Data: "+dtoc(stod((cAlias)->F2_EMISSAO))+" </div></h3>"
                    
                    (cAlias)->(DbCloseArea())
                Endif        
                cTxtEmail += "<h3><div> Valor: R$ "+StrTran(strzero(Val(oJson['charge']['amount']),6,2),".",",")+" </div>"
                cTxtEmail += "<div> Estorno: R$ "+StrTran(strzero(Val(oJson['charge']['last_transaction']['amount']),6,2),".",",")+" </div></h3>"

                If !U_CP16MAIL("[Cartão Aliança] Estorno de Pagamento "+cIdSubs,cTxtEmail,cDesEmail)
                    aRet[1] := .F.
                    aRet[2] := "Falha ao enviar e-mail de estorno de pagamento."
                Endif
            Else
                aRet[1] := .F. 
                aRet[2] := "Controle de assinatura referente ao evento não encontrada, verifique se os eventos de assinatura e período já foram processados."
            Endif
        Else
            aRet[1] := .F. 
            aRet[2] := "Falha ao realizar GET para obter dados da fatura." 
        Endif

        FreeObj(oBill)

    Else
        aRet[1] := .F. 
        aRet[2] := "Falha na estrutura do JSON."   
    Endif

    FreeObj(oJson)    
    RestArea(aArea)

Return aRet

/*/{Protheus.doc} CadCliente
    Funçao para realizar cadastro ou atualizacao do cliente vindo da Vindi
    @type  Function
    @author user
    @since 27/03/2020
    @version version
    @param oJson - Objeto json com dados do cliente Vindi
    @param cCliLoj - Codigo do cliente e loja
    @return aRet - {Boolean, MsgErro, Codigo e loja do cliente incluidos }
/*/
Static Function CadCliente(oJson,cCliLoj)
    
    Local aRet := {.T.,"",""}
    Local aCli := {}
    Local cEnd := ""
    Local cCodMun := ""
    Local nOper := 3
    Local cNatureza := SuperGetMV("ES_NATFINC",.F., "11010001")
    Local cTelef := ""

    Default oJson := ""
    Default cCliLoj := ""

    If ValType(oJson) == "J" .AND. ValType(oJson:GetJsonObject("customer")) != "U"

        If ValType(oJson['customer']['address']['street']) == "C"
            cEnd := oJson['customer']['address']['street']+", "
        Endif    
        If ValType(oJson['customer']['address']['number']) == "C"
            cEnd += oJson['customer']['address']['number']
        Endif
            
        //Tenta obter cod ibge 
        aRet := U_CP16GMUN(oJson['customer']['address']['city'])
        If aRet[1]
            cCodMun := aRet[3]  
            aRet[2] := ""                    
            aRet[3] := ""
        Else
            aRet := U_CP16GMUN(,oJson['customer']['address']['zipcode'])
            If aRet[1]
                cCodMun := aRet[3]  
                aRet[2] := ""                    
                aRet[3] := ""
            Endif                
        Endif  
        //Caso cCliLoj esteja preenchido apenas atualiza um cliente existente
        If !Empty(cCliLoj)
            nOper := 4
        Else
            cCliLoj := oJson['customer']['registry_code']
        Endif
        
        aAdd(aCli,{"A1_COD"    , Left(cCliLoj,TamSx3("A1_COD")[1]) ,Nil})    
        aAdd(aCli,{"A1_LOJA"   , SubStr(cCliLoj, TamSx3("A1_COD")[1]+1, TamSx3("A1_LOJA")[1] ) ,Nil})

        aAdd(aCli,{"A1_NOME"    , Substr(oJson['customer']['name'],1,TamSx3("A1_NOME")[1]) ,Nil})
        aAdd(aCli,{"A1_NREDUZ"  , Substr(oJson['customer']['name'],1,TamSx3("A1_NREDUZ")[1]) ,Nil}) 
        aAdd(aCli,{"A1_TIPO"    , "F" ,Nil})
        aAdd(aCli,{"A1_INCISS"  , "S" ,Nil})
        aAdd(aCli,{"A1_END"     , Substr(cEnd,1,TamSx3("A1_END")[1]) ,Nil}) 
        aAdd(aCli,{"A1_CODPAIS" , "01058",Nil}) 
        //aAdd(aCli,{"A1_CONTA" , "1102010001",Nil})
        aAdd(aCli,{"A1_NATUREZ" , cNatureza, Nil})
        aAdd(aCli,{"A1_CEP"     , oJson['customer']['address']['zipcode'] ,Nil}) 
        aAdd(aCli,{"A1_BAIRRO"  , oJson['customer']['address']['neighborhood'] ,Nil}) 
        aAdd(aCli,{"A1_EST"     , oJson['customer']['address']['state'] ,Nil})
        aAdd(aCli,{"A1_MUN"     , oJson['customer']['address']['city'] ,Nil})
        aAdd(aCli,{"A1_COD_MUN" , cCodMun ,Nil})
        aAdd(aCli,{"A1_CGC"     , oJson['customer']['registry_code'] ,Nil})
        aAdd(aCli,{"A1_XIDVIND" , cValtoChar(oJson['customer']['id']) ,Nil})

        If len(oJson['customer']['phones']) >= 1
            cTelef := oJson['customer']['phones'][1]['number']
            If len(cTelef) >= 12    
                cTelef := SubStr(cTelef , 3 , len(cTelef)-2)
            Endif
            aAdd(aCli,{"A1_DDD" , Left(cTelef,2) ,Nil})
            aAdd(aCli,{"A1_TEL" , SubStr(cTelef,3, len(cTelef)-2 ) ,Nil})
        Endif
        
        If aRet[1] 
            aRet := U_CP16CCLI(aCli,nOper)//Inclusao ou alteracao de cliente - SA1
        Endif

        FreeObj(oJson)

    Else
        aRet[1] := .F.
        aRet[2] := "CP16001 - CadCliente -  Objeto Json nao recebido ou formato invalido."
    Endif

Return aRet

/*/{Protheus.doc} ExistSubs

    Funçao para verificar se assinatura existe 

    @type  Function
    @author Julio Teixeira - Compila
    @since 31/03/2020
    @version version
    @param cIdSubs - Id da assinatura
    @return aRet - {Boolean, MsgErro, Lista de periodos encontrados }
/*/
Static Function ExistSubs(cIdSubs)

    Local aRet := {.T.,"",{}}
    Local aArea := GetArea()
    Local cArea  := GetNextAlias()
    Local cQuery := ""

    Default cIdSubs := ""
    
    If !Empty(cIdSubs)
    
        cQuery := "SELECT C5_NUM ,C5_ORIGEM, R_E_C_N_O_ C5_REC "  
        cQuery += "FROM "+RetSqlName("SC5")+" "
        cQuery += "WHERE C5_FILIAL = '" + xFilial("SC5") + "' " 
        cQuery += "AND C5_XIDPLE = '" +cIdSubs+ "' "
        cQuery += "AND D_E_L_E_T_ = '' "
        cQuery := ChangeQuery(cQuery)
        DBUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cArea, .T., .T.)  
    
        If (cArea)->(!EOF())

            aRet[3] := { (cArea)->C5_NUM , {}, {} }

            While (cArea)->(!EOF())

               aAdd(aRet[3][2],  Alltrim((cArea)->C5_ORIGEM)  )
               aAdd(aRet[3][3],  (cArea)->C5_REC  )

               (cArea)->(DbSkip())
            Enddo
        Else
            aRet[1] := .F.
            aRet[2] := "Nenhum pedido encontrado com o id da assinatura informado!"
        Endif

        (cArea)->(dbCloseArea())
    Else
        aRet[1] := .F.
        aRet[2] := "Nenhum id informado para busca dos periodos"
    Endif

    RestArea(aArea)

Return aRet


/*/{Protheus.doc} CycleDesc
    
    Funçao para buscar os ciclos da assinatura que terão desconto

    @type  Function
    @author Julio Teixeira - Compila
    @since 31/03/2020
    @version version
    @param cIdSubs - Id da assinatura
    @param nCycle - Cycle atual
    @param nItem - Item a ser verificado se há desconto
    @return aRet - {Boolean, MsgErro, Número de ciclos com desconto }
/*/
Static Function CyclesDesc(cIdSubs,nItem)

    Local aRet := {.T.,"",""}
    Local cEndPoint := SuperGetMV("CP16_URLVI",.F.,"https://sandbox-app.vindi.com.br/api")
    Local cChave := SuperGetMV("CP16_CHVVI",.F.,"8GWJghISrCMYkLypxRd8q6bkqxlEgP5mLrRLNSc-I5g")
    Local nCycles := 0

    Default cIdSubs := ""
    Default nItem := 0

    If !Empty(cIdSubs) .AND. nItem > 0 
        aRet := U_CP16GET(cEndPoint, "/v1/subscriptions/"+cIdSubs, cChave, "")
        If aRet[1]
            If ValType(aRet[3]:GetJsonObject("subscription")) != "U" .AND.;
               ValType(aRet[3]['subscription']:GetJsonObject("product_items")) != "U" .AND.;
               ValType(aRet[3]['subscription']['product_items'][nItem]:GetJsonObject("discounts")) != "U"
         
                If len(aRet[3]['subscription']['product_items'][nItem]['discounts']) > 0 .AND.;
                   ValType(aRet[3]['subscription']['product_items'][nItem]['discounts'][1]['cycles']) != "U"
                   
                    nCycles := aRet[3]['subscription']['product_items'][nItem]['discounts'][1]['cycles']
                Endif
                FreeObj(aRet[3])                            
                aRet[3] := nCycles
            Else
                aRet[1] := .F.
                aRet[2] := "Falha ao acessar a propriedade do desconto na estrutura do JSON de subscription."
            Endif
        Endif
    Else
        aRet[1] := .F.
        aRet[2] := "Parametros nao informados para verificar os descontos da assinatura."
    Endif    

Return aRet

/*/{Protheus.doc} ExistCli
    Funçao para verificar se assinatura existe 
    @type  Function
    @author Julio Teixeira - Compila
    @since 31/03/2020
    @version version
    @param cIdcli - Id da cliente
    @return aRet - {Boolean, MsgErro, Cod+loja}
/*/
Static Function ExistCli(cIdcli)

    Local aRet := { .T., "",{} }
    Local aArea := GetArea()
    Local cArea  := GetNextAlias()
    Local cQuery := ""

    Default cIdcli := ""
    
    If !Empty(cIdcli)
    
        cQuery := "SELECT A1_COD ,A1_LOJA"  
        cQuery += "FROM "+RetSqlName("SA1")+" "
        cQuery += "WHERE A1_FILIAL = '" + xFilial("SA1") + "' " 
        cQuery += "AND A1_XIDVIND = '" +cIdcli+ "' "
        cQuery += "AND D_E_L_E_T_ = '' "
        cQuery := ChangeQuery(cQuery)
        DBUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cArea, .T., .T.)  
    
        If (cArea)->(!EOF())
            aRet[3] := (cArea)->A1_COD+(cArea)->A1_LOJA  
        Else
            aRet[1] := .F.
            aRet[2] := "Cliente não encontrado! Buscando dados na Vindi para cadastro..."
        Endif

        (cArea)->(dbCloseArea())
    Else
        aRet[1] := .F.
        aRet[2] := "Nenhum id informado para busca."
    Endif

    RestArea(aArea)

Return aRet

/*/{Protheus.doc} CP16JNFS
    
    Gera o JSON para envio dos dados da NF transmitida para Ateliware

    @type  User Function
    @author Julio Teixeira - Compila
    @since 13/04/2020
    @version 12
    @param 
    @return aRet
/*/
User Function CP16JNFS(cCgcFil,cIdVindi,cSerie,cDoc,cChvNfe,cDatEmi,cNFElet)

Local aRet := {.T.,"",""}
Local cJson := "" 
Local nIdVindi
Local cURLAW   := SuperGetMV("CP16_URLAW",.F.,"https://staging1.cartaoalianca.com.br")
Local cURLNFSe := SuperGetMV("CP16_URLNF",.F.,"https://bhissdigital.pbh.gov.br/nfse/pages/consultaNFS-e_cidadao.jsf")
Local cUserWSR := Alltrim(SuperGetMV("CP16_USRAW",.F.,""))//svc.alianca
Local cSenhWSR := Alltrim(SuperGetMV("CP16_SENAW",.F.,""))//&@oV#pqT9Rvi
Local cPath := "/payment_webhooks/invoice"
Local cPrefix := ""
Local nTot 
Local nTotAbat

Default cCgcFil := ""
Default cIdVindi := ""
Default cSerie := ""
Default cDoc := ""
Default cChvNfe := ""
Default cDatEmi := ""
Default cNFElet := ""

If !Empty(cNFElet)

    If Right(cURLAW,1) == "/"//Tratamento da url para nao duplicar a barra
        cURLAW := Left(cURLAW, len(cURLAW)-1)//Remove barra do final
    Endif

    cPrefix  := Left(Alltrim(cIdVindi),1)
    cIdVindi := SubStr(cIdVindi,2,len(cIdVindi))
    nIdVindi := Val(cIdVindi)

    cDatEmi := SubStr(cDatEmi,1,4)+"-"+SubStr(cDatEmi,5,2)+"-"+SubStr(cDatEmi,7,2)

    If cPrefix == "V"
        cJson := '{'
        cJson +=    '"invoice":{'
        cJson +=        '"subscription_id_on_gateway": '+cValtoChar(nIdVindi)+','  // 180_713, # id da assinatura na Vindi
        cJson +=        '"bill_id_on_gateway": 0,'              // 1, # id da bill na Vindi
        cJson +=        '"series_number": "'+cSerie+'",'        //'1', # série da nota, em string (qualquer formato)
        cJson +=        '"rps_number": "'+cDoc+'",'             //'1', # rps da nota, em string (qualquer formato) - opcional
        cJson +=        '"number": "'+cNFElet+'",'              //'1', # número da nota, em string (qualquer formato)
        cJson +=        '"validation_key": "'+cChvNfe+'",'      //'validation_key', # código da chave de validação (qualquer formato)
        cJson +=        '"emission_date": "'+cDatEmi+'",'       //'2020-04-01', # data de emissão em YYYY-MM-DD
        cJson +=        '"description": "",'                    //'Produto Cartão Aliança Trimestral', # descrição do produto que veio na bill
        cJson +=        '"invoice_pdf": "'+cURLNFSe+'",'        //'"https://link-exemplo.direto/nota.pdf', # PDF da nota (link para onde estiver, se houver) - opcional
        cJson +=        '"seller_cnpj": "'+cCgcFil+'"'          //'12345678000199' # CNPJ da empresa vendedora (alliar)
        cJson +=    '}'
        cJson += '}'
    ElseIf cPrefix == "U"
        cJson := '{
	    cJson += '     "invoice" : {
		cJson +=        '"code" : '+cValtoChar(nIdVindi)+',' 				
		cJson +=        '"status" : "issued",'
        cJson +=        '"series_number": "'+cSerie+'",'        //'1', # série da nota, em string (qualquer formato)
        cJson +=        '"rps_number": "'+cDoc+'",'             //'1', # rps da nota, em string (qualquer formato) - opcional
        cJson +=        '"number": "'+cNFElet+'",'              //'1', # número da nota, em string (qualquer formato)
        cJson +=        '"validation_key": "'+cChvNfe+'",'      //'validation_key', # código da chave de validação (qualquer formato)
        cJson +=        '"emission_date": "'+cDatEmi+'",'       //'2020-04-01', # data de emissão em YYYY-MM-DD
        cJson +=        '"description": "",'                    //'Produto Cartão Aliança Trimestral', # descrição do produto que veio na bill
        cJson +=        '"invoice_pdf": "'+cURLNFSe+'",'        //'"https://link-exemplo.direto/nota.pdf', # PDF da nota (link para onde estiver, se houver) - opcional
        cJson +=        '"seller_cnpj": "'+cCgcFil+'"'          //'12345678000199' # CNPJ da empresa vendedora (alliar)
       // INICIO https://compilabr.teamwork.com/#/tasks/22697018
        DbSelectArea("SE1")
        SE1->(DbSetOrder(2)) 
        If SF2->F2_DOC == cDoc .AND. SF2->F2_SERIE == cSerie .AND. SE1->(DbSeek(xFilial("SE1")+SF2->(F2_CLIENTE+F2_LOJA+F2_SERIE+F2_DOC+Padr("",TamSX3("E1_PARCELA")[1])+"NF")))
            nTot := SE1->E1_SALDO
            nTotAbat := nTot - SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",1,,SE1->E1_CLIENTE,SE1->E1_LOJA,SE1->E1_FILIAL,,)
            cJson +=        ',"value_with_taxes" : '+cValtoChar(nTot)+','             //
            cJson +=        '"value_without_taxes" : '+cValtoChar(nTotAbat)         //
        Endif
       // FIM https://compilabr.teamwork.com/#/tasks/22697018
	    cJson +=    '}'
        cJson += '}'
    Endif

    aRet := U_CP16POST(cURLAW,cPath,cJson,cUserWSR,cSenhWSR)
Else
    aRet[1] := .F.
    aRet[2] := "Somente os documentos transmitidos podem ser integrados."
Endif

Return aRet

/*/{Protheus.doc} GrvPagto
    
    Função responsável por obter dados do pagamento e gerar SZ7

    @type  Static Function
    @author Julio Teixeira - Compila
    @since 23/04/2020
    @version 12
    @param 
    @return aRet - {lRet, cMsgErro, xReturn}
/*/
Static Function GrvPagto(cIdBill, cPedVen)

    Local cEndPoint := SuperGetMV("CP16_URLVI",.F.,"https://sandbox-app.vindi.com.br/api")
    Local cChave := SuperGetMV("CP16_CHVVI",.F.,"8GWJghISrCMYkLypxRd8q6bkqxlEgP5mLrRLNSc-I5g")
    Local aPgto := {}
    Local nX := 1
    Local nValor := 0
    Local nQtdPar := 0
    Local cNumCart := ""
    Local cBandei := ""
    Local cCodAut := ""
    Local dDtPagto := ctod("")
 //   Local oModelSZ7 
    Local aRet := {.T.,"",}
    Local aArea := GetArea()
    Local oPag 

    Default cIdBill := ""
    Default cPedVen := ""

    DbSelectArea("SZ7")
    SZ7->(DbSetOrder(1))
    If !Empty(cIdBill) .AND. SZ7->(!DbSeek(xFilial("SZ7")+cPedVen))
        aPgto := U_CP16GET(cEndPoint, "/v1/bills/"+cIdBill, cChave, "")
        If aPgto[1]//Verifica se conseguiu realizar o GET

            oPag := aPgto[3]

            If ValType(oPag:GetJsonObject("bill")) != "U" .AND.;
            ValType(oPag['bill']:GetJsonObject("charges")) == "A" .AND.;
            len(oPag['bill']['charges']) >= 1
                For nX := 1 to len(oPag['bill']['charges'])
                    
                    If oPag['bill']['charges'][nX]['payment_method']['code'] == "credit_card"
                        cForma := "CC"
                    Elseif oPag['bill']['charges'][nX]['payment_method']['code'] == "debit_card"
                        cForma := "CD"
                    Endif
                    nValor := Val(oPag['bill']['charges'][nX]['amount'])
                    nQtdPar := oPag['bill']['charges'][nX]['installments']
                    If ValType(oPag['bill']['charges'][nX]:GetJsonObject('paid_at')) == "C"
                        dDtPagto := StoD(Left(StrTran(oPag['bill']['charges'][nX]['paid_at'],"-",""),8))
                    Endif    
                    cNumCart := oPag['bill']['charges'][nX]['last_transaction']['payment_profile']['card_number_first_six']
                    cNumCart += "XXXXXX"
                    cNumCart += oPag['bill']['charges'][nX]['last_transaction']['payment_profile']['card_number_last_four']

                    cBandei := cValtoChar(oPag['bill']['charges'][nX]['last_transaction']['payment_profile']['payment_company']['id'])
                    cBandei := Left(cBandei,TamSX3("Z7_BAND")[1])

                    If ValType(oPag['bill']['charges'][nX]['last_transaction']['gateway_response_fields']:GetJsonObject('authorization_code')) == "C"
                        cCodAut := oPag['bill']['charges'][nX]['last_transaction']['gateway_response_fields']['authorization_code']
                    ElseIf ValType(oPag['bill']['charges'][nX]['last_transaction']['gateway_response_fields']:GetJsonObject('nsu')) == "C"
                        cCodAut := oPag['bill']['charges'][nX]['last_transaction']['gateway_response_fields']['nsu']
                    EndIf
                    cCodAut := Left(cCodAut,TamSX3("Z7_IDTRAN")[1])
                        
                    /*oModelSZ7 := FWLoadModel('FSFATC01')
                    oModelSZ7:DeActivate()*/
                    DbSelectArea("SZ7")
                    SZ7->(DbSetOrder(1))
                    IF SZ7->(DbSeek(xFilial("SZ7")+cPedVen))
                        //oModelSZ7:SetOperation(4)//Define alteração
                        RecLock("SZ7",.F.)
                    Else
                        //oModelSZ7:SetOperation(3)//Define inclusão
                        RecLock("SZ7",.T.)
                    ENDIF

                    SZ7->Z7_FILIAL	:= xFilial("SZ7")
                    SZ7->Z7_PEDIDO	:= cPedVen
                    SZ7->Z7_FORMA	:= cForma
                    SZ7->Z7_VALOR	:= nValor
                    SZ7->Z7_QTDPAR	:= nQtdPar
                    SZ7->Z7_PAGTO	:= dDtPagto
                    SZ7->Z7_NUMCHQ	:= cNumCart
                    SZ7->Z7_BAND	:= cBandei
                    SZ7->Z7_IDTRAN	:= cCodAut
                    
                    SZ7->( MsUnlock() )

                   /* oModelSZ7:Activate()//Ativa o modelo para inclusão
                    
                    oModelSZ7:SetValue('SZ7MASTER','Z7_PEDIDO',cPedVen)
                    oModelSZ7:SetValue('SZ7MASTER','Z7_FORMA' ,cForma)
                    oModelSZ7:SetValue('SZ7MASTER','Z7_VALOR' ,nValor)
                    oModelSZ7:SetValue('SZ7MASTER','Z7_QTDPAR',nQtdPar)
                    If !Empty(dtos(dDtPagto))
                        oModelSZ7:SetValue('SZ7MASTER','Z7_PAGTO' ,dDtPagto)
                    Endif    
                    oModelSZ7:SetValue('SZ7MASTER','Z7_NUMCHQ',cNumCart)
                    oModelSZ7:SetValue('SZ7MASTER','Z7_BAND'  ,cBandei)
                    If !Empty(cCodAut)
                        oModelSZ7:SetValue('SZ7MASTER','Z7_IDTRAN',cCodAut)
                    Endif    
                    
                    If oModelSZ7:VldData()
                        oModelSZ7:CommitData()
                    EndIf

                    aErro := oModelSZ7:GetErrorMessage()
                    If len(aErro) >= 6 .AND. !Empty(aErro[6])
                        aRet[1] := .F.
                        aRet[2] := aErro[6]+" - Falha ao gravar tabela SZ7"
                        nX := len(aPgto[3]['bill']['charges'])
                    Endif

                    oModelSZ7:DeActivate() 
                    oModelSZ7:Destroy()
                    oModelSZ7 := Nil*/

                Next nX 

                FreeObj(oPag)
            Else
                aRet[1]  := .F.
                aRet[2]  := "Problema na estrutura retornada pelo endpoint: "+cEndPoint     
            Endif
        Else
            aRet[1]  := .F.
            aRet[2]  := "Não foi possível obter os dados através do endpoint: "+cEndPoint
        Endif
    Endif
    
    RestArea(aArea)

Return aRet


/*/{Protheus.doc} ExistBx
    Retorna se existe baixa ou não e os recnos dos títulos
    @type  Static Function
    @author Julio Teixeira
    @since 26/05/2020
    @version 12
    @param 
    @return aRet
/*/
Static Function ExistBx(cDoc, cSerie, cCodCli, cLojaCli)
    
    Local cQuery := ""
    Local cAlias := GetNextAlias()
    Local aRet := {.F.,"",{{},{}} }
    
    Default cDoc := ""
    Default cSerie := ""
    Default cCodCli := ""
    Default cLojaCli := ""

    If !Empty(cDoc) .AND. !Empty(cSerie)

        cQuery := "SELECT R_E_C_N_O_ E1_RECNO, E1_SALDO, E1_STATUS "  
        cQuery += "FROM "+RetSqlName("SE1")+" SE1"
        cQuery += "WHERE E1_FILIAL = '" + xFilial("SE1") + "' " 
        cQuery += "AND E1_NUM = '" +cDoc+ "' "
        cQuery += "AND E1_PREFIXO = '" +cSerie+ "' "
        cQuery += "AND E1_CLIENTE = '" +cCodCli+ "' "
        cQuery += "AND E1_LOJA = '" +cLojaCli+ "' "
        cQuery += "AND D_E_L_E_T_ = '' "
        cQuery += "ORDER BY E1_PARCELA ASC "
        cQuery := ChangeQuery(cQuery)
        DBUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAlias, .T., .T.)  
    
        If (cAlias)->(!EOF())
            While (cAlias)->(!EOF())
                If (cAlias)->E1_STATUS == "B"
                    aAdd(aRet[3][1], (cAlias)->E1_RECNO)
                    aRet[1] := .T.
                Else
                    aAdd(aRet[3][2], (cAlias)->E1_RECNO)
                Endif
                (cAlias)->(DbSkip())
            Enddo

            If len(aRet[3][1]) == 0
                aRet[1] := .F.
                aRet[2] := "Nenhum título baixado foi encontrado"  
            Endif
        Else
            aRet[1] := .F.
            aRet[2] := "Nenhum título baixado foi encontrado"      
        Endif

        (cAlias)->(dbCloseArea())

    Endif

Return aRet
