#INCLUDE "PROTHEUS.CH"

/*/{Protheus.doc} CP160003
    Funcao Alliar responsavel por processar o body da requisição
    @type  User Function
    @author Julio Teixeira
    @since 29/06/2020
    @version 12
    @param cBody, string, Corpo do webhook recebido.
    @return aRet - {Boolean, MsgErro, Conteúdo de retorno}
    @example
    @see 
/*/
User Function CP160003(cBody)

    Local aRet := {.T.,"",""}
    Local oJson := JsonObject():New()
    Local cCatch := ""
    Local _cCodEmp	:= SM0->M0_CODIGO
    Local _cCodFil	:= SM0->M0_CODFIL
    Local _cFilNew	:= "01901MG0001"
    Local cIdInte   := ""

    Default cBody := ""

    /*---------------------------------------
    Realiza a TROCA DA FILIAL CORRENTE SPO
    -----------------------------------------*/
    If _cCodEmp+_cCodFil <> _cCodEmp+_cFilNew
        CFILANT := _cFilNew
        opensm0(_cCodEmp+CFILANT)
    Endif

    cCatch := oJson:FromJson(cBody)

    If Valtype(cCatch) == "U" 

        DO CASE
            CASE ValType(oJson:GetJsonObject("uid")) != "U" .AND.;
                ValType(oJson:GetJsonObject("cliente")) != "U" .AND.;
                ValType(oJson:GetJsonObject("itens")) != "U" .AND.;
                ValType(oJson:GetJsonObject("pagamentos")) != "U" 

                BEGIN TRANSACTION

                aRet := IncOrder(oJson)

                If !aRet[1]
                    DisarmTransaction()
                Endif

                END TRANSACTION 

            CASE ValType(oJson:GetJsonObject("event")) != "U" .AND.;
                ValType(oJson["event"]:GetJsonObject("type")) == "C" .AND.;
                oJson["event"]["type"] == "bill_paid"

                cIdInte := "id" + cValToChar(oJson['event']['data']['bill']['code'])+"-"
                cIdInte += oJson['event']['type']

                BEGIN TRANSACTION

                aRet := BillB2b(oJson['event']['data'])//Valida e prepara para gravacao
                
                If !aRet[1]
                    DisarmTransaction()
                Endif
                END TRANSACTION

            CASE ValType(oJson:GetJsonObject("event")) != "U" .AND.;
                ValType(oJson["event"]:GetJsonObject("type")) == "C" .AND.;
                oJson["event"]["type"] == "charge_refunded"

                cIdInte := "id" + cValToChar(oJson['event']['data']['charge']['id'])+"-"
                cIdInte += oJson['event']['type']

                BEGIN TRANSACTION

                aRet := RefundB2b(oJson['event']['data'])//Valida e prepara para gravacao
                
                If !aRet[1]
                    DisarmTransaction()
                Endif
                END TRANSACTION

            CASE ValType(oJson:GetJsonObject("event")) != "U" .AND.;
                ValType(oJson["event"]:GetJsonObject("type")) == "C" .AND.;
                oJson["event"]["type"] == "canceled_status"

            	aRet :=	U_CP16CNFB( oJson["event"]["id"],oJson["event"]["rps_number"],oJson["event"]["series_number"])

            CASE ValType(oJson:GetJsonObject("event")) != "U" .AND.;
                ValType(oJson["event"]:GetJsonObject("type")) == "C" .AND.;
                oJson["event"]["type"] == "order_cancel_b2b"

            	aRet :=	gFluxCanc( oJson["event"])    

            OTHERWISE
                aRet[1] := .F.
                aRet[2] := "Estrutura recebida não possui os requisitos minimos para processamento."
        ENDCASE    
    Else
        aRet[1] := .F.
        aRet[2] := "Falha na estrutura do JSON recebido."
    ENDIF

    FreeObj(oJson)
Return aRet

/*/{Protheus.doc} BillB2b
    Realiza baixa do título pago ref. cartão aliança B2B
    @type  Static Function
    @author Julio Teixeira
    @since 27/07/2020
    @version 12
    @param oJson - JSON do evento bill_paid
    @return aRet
/*/
Static Function BillB2b(oJson)
    
Local aRet := {.T.,""}
Local aPed := {}
Local aArea := GetArea()
Local aAreaSC5 := SC5->(GetArea())
Local aAreaSE1 := SE1->(GetArea())
Local dDataBx 
Local nValRec := 0
Local nX, nY := 1
Local cIdUnico := ""
Local cDadosBco := SuperGetMV("CP16_BCOB",.F.,"341,2938,47588")
Local aDadosBco := StrtoKarr(cDadosBco,",")
Local nValDif,nValbX,nTotPend := 0

Default oJson := ""
If len(aDadosBco) == 3
    If ValType(oJson:GetJsonObject("bill")) != "U" .AND.;
    ValType(oJson["bill"]:GetJsonObject("metadata")) != "U" .AND.;
    ValType(oJson["bill"]["metadata"]:GetJsonObject("code")) != "U" 
        
        If ValType(oJson["bill"]['metadata']['code']) == "N"
            cIdUnico := "R"+StrZero(oJson["bill"]['metadata']['code'], TamSX3("C5_XIDPLE")[1]-1)
        Else
            cIdUnico := "R"+StrZero(0, TamSX3("C5_XIDPLE")[1] - (len(oJson["bill"]['metadata']['code'])+1) )+oJson["bill"]['metadata']['code'] 
        Endif
        //aPed := ExistOrder( cIdUnico )
        aPed := GetOrders(cIdUnico)
        
        If !aPed[1]
            
            If ValType(oJson["bill"]['metadata']['code']) == "N"
                cIdUnico := "U"+StrZero(oJson["bill"]['metadata']['code'], TamSX3("C5_XIDPLE")[1]-1)
            Else
                cIdUnico := "U"+StrZero(0, TamSX3("C5_XIDPLE")[1] - (len(oJson["bill"]['metadata']['code'])+1) )+oJson["bill"]['metadata']['code'] 
            Endif
            aPed := GetOrders(cIdUnico)

        Endif

        If aPed[1]
            DbSelectArea("SC5")
            SC5->(DbSetOrder(1))

            nValRec := 0
            nValDif := 0
            For nX := 1 to len(oJson['bill']['charges'])
                dDataBx := StoD(Left(StrTran(oJson['bill']['charges'][nX]['paid_at'],"-",""),8))          
                nValRec += Val(oJson['bill']['charges'][nX]['amount'])
            Next nX

            //nValDif := nValRec - Val(oJson['bill']['amount']) 

            nTotPend := 0
            For nY := 1 to len(aPed[3])
                SC5->(DbGoTo(aPed[3][nY][2]))
                If Alltrim(SC5->C5_XIDPLE) == Alltrim(cIdUnico)        
                    DbSelectArea("SE1")
                    SE1->(DbSetOrder(2))
                    If SE1->(DbSeek(xFilial("SE1")+SC5->(C5_CLIENTE+C5_LOJACLI+C5_SERIE+C5_NOTA)+Padr("",TamSX3("E1_PARCELA")[1])+"NF"))
                        nTotPend += SE1->E1_SALDO
                    Endif
                Endif
            Next nY

            If nValRec > nTotPend
                nValDif := nValRec-nTotPend
            Endif
            
            nValbX := 0
            
            For nY := 1 to len(aPed[3])
                SC5->(DbGoTo(aPed[3][nY][2]))
                If Alltrim(SC5->C5_XIDPLE) == Alltrim(cIdUnico)        
                    DbSelectArea("SE1")
                    SE1->(DbSetOrder(2))
                    If SE1->(DbSeek(xFilial("SE1")+SC5->(C5_CLIENTE+C5_LOJACLI+C5_SERIE+C5_NOTA)+Padr("",TamSX3("E1_PARCELA")[1])+"NF"))

                        If SE1->E1_SALDO > nValRec-nValbX
                            aRet := U_CP16BTIT(SE1->(Recno()),"NOR",aDadosBco[1],aDadosBco[2],aDadosBco[3],nValRec-nValbX, nValDif ,dDataBx, "Baixa realizada via evento billpaid B2B")   
                            nValbX += nValRec-nValbX
                        Else
                            nValbX += SE1->E1_SALDO
                            aRet := U_CP16BTIT(SE1->(Recno()),"NOR",aDadosBco[1],aDadosBco[2],aDadosBco[3],SE1->E1_SALDO, nValDif ,dDataBx, "Baixa realizada via evento billpaid B2B")   
                        Endif

                        nValDif := 0

                        If !aRet[1]
                            nValbX := 0
                            Exit
                        Endif
                    Endif
                Endif
            Next nY
        Else
            aRet[1] := .F.
            aRet[2] := "Não foi possível processar esta requisição, O código único "+cIdUnico+" não foi encontrado." 
        Endif
    Endif
Else
    aRet[1] := .F.
    aRet[2] := "Dados da conta informada no parâmetro CP16_BCOB estão incorretos. Ajustar parâmetro no formato: XXX,YYYY,ZZZZZ (Banco,Agencia,Conta)."
Endif
RestArea(aArea)
RestArea(aAreaSC5)
RestArea(aAreaSE1)

Return aRet

/*/{Protheus.doc} RefundB2b
    Função responsavel pelo estorno da baixa
    @type  Static Function
    @author user
    @since 25/08/2020
    @version version
    @param ojson
    @return aRet
/*/
Static Function RefundB2b(oJson)

Local aRet := {.T.,"",}
Local aPed := {}
Local aArea := GetArea()
Local aAreaSC5 := SC5->(GetArea())
Local aAreaSE1 := SE1->(GetArea())
Local dDataBx 
Local nValRec := 0
Local cIdUnico := ""
Local nValDif := 0

Default oJson := ""

If ValType(oJson:GetJsonObject("charge")) != "U" .AND.;
ValType(oJson["charge"]:GetJsonObject("metadata")) != "U" .AND.;
ValType(oJson["charge"]["metadata"]:GetJsonObject("code")) != "U" 
    
    If ValType(oJson["charge"]['metadata']['code']) == "N"
        cIdUnico := "R"+StrZero(oJson["bill"]['metadata']['code'], TamSX3("C5_XIDPLE")[1]-1)
    Else
        cIdUnico := "R"+StrZero(0, TamSX3("C5_XIDPLE")[1] - (len(oJson["charge"]['metadata']['code'])+1) )+oJson["charge"]['metadata']['code'] 
    Endif
    aPed := ExistOrder( cIdUnico )
    If aPed[1]
        DbSelectArea("SC5")
        SC5->(DbSetOrder(1))
        SC5->(DbGoTo(aPed[3][2]))
        If Alltrim(SC5->C5_XIDPLE) == Alltrim(cIdUnico)
            
            DbSelectArea("SE1")
            SE1->(DbSetOrder(2))
            If SE1->(DbSeek(xFilial("SE1")+SC5->(C5_CLIENTE+C5_LOJACLI+C5_SERIE+C5_NOTA)+Padr("",TamSX3("E1_PARCELA")[1])+"NF"))
                nValRec := 0
                nValDif := 0
                
                dDataBx := StoD(Left(StrTran(oJson['charge']['last_transaction']['created_at'],"-",""),8))          
                nValRec += Val(oJson['charge']['last_transaction']['amount'])

                nValDif := nValRec - Val(oJson['charge']['amount']) 
                aRet := U_CP16BTIT(SE1->(Recno()),"NOR","","","",nValRec-nValDif, nValDif ,dDataBx, "Estorno via Charge_Refunded",5/*5=Canc.Baixa*/)   
            Else
                aRet[1] := .F.
                aRet[2] := "Título referente ao id "+cIdUnico+" não encontrado!"
            Endif
        Else
            aRet[1] := .F.
            aRet[2] := "Pedido referente ao id "+cIdUnico+" não encontrado!"    
        Endif
        
    Else
        aRet[1] := .F.
        aRet[2] := "Não foi possível processar esta requisição, O código único R"+StrZero(oJson['uid'], TamSX3("C5_XIDPLE")[1]-1)+" não foi encontrado." 
    Endif
Endif

RestArea(aArea)
RestArea(aAreaSC5)
RestArea(aAreaSE1)


Return aRet

/*/{Protheus.doc} gFluxCanc
    (long_description)
    @type  Static Function
    @author user
    @since 06/08/2020
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
Static Function gFluxCanc(oJson)

Local cUserFluig	:= GETMV("MV_ECMMAT",.F.,"") 
Local cComments		:= "NfEmissaoCancelamentoAjuste"
Local cProcId		:= "NfEmissaoCancelamentoAjuste"
Local aCardData		:= {}
Local aRetAux := {}
Local aRet := {.T.,""}
Local lComplete		:= .T.
Local lManager		:= .F.
Local nTaskDest		:= 0
Local _cFilNew	:= "01901MG0001" 

Default oJson := ""

DbSelectArea("SF2")
SF2->(DbGoTo(oJson:GetJsonObject("recno_sf2")))
If Alltrim(SF2->F2_XIDPLE) == oJson:GetJsonObject("uid") 
    DbSelectArea("SA1")
    SA1->(DbSetOrder(1))
    If DbSeek(xFilial("SA1")+SF2->(F2_CLIENTE+F2_LOJA))

        Aadd(aCardData, {"M0_CODIGO"  ,  "01"			})
        Aadd(aCardData, {"M0_NOME"    ,  "ALLIAR"		})
        Aadd(aCardData, {"M0_CODFIL"  ,  _cFilNew		})
        Aadd(aCardData, {"M0_FILIAL"  ,  FWFilialName("01", _cFilNew ,1)})
        Aadd(aCardData, {"login"  ,  "alianca"})
        Aadd(aCardData, {"ColleagueName"  ,  "Aliança"})

        Aadd(aCardData, {"descricao" , oJson:GetJsonObject("desc") })

        Aadd(aCardData, {"dtInicial" , DTOC( DDATABASE ) })
        Aadd(aCardData, {"dtFinal" , DTOC( DDATABASE ) })
        Aadd(aCardData, {"A1_COD" , SA1->A1_COD })
        Aadd(aCardData, {"A1_NOME" , SA1->A1_NOME })
        Aadd(aCardData, {"F2_DOC" , SF2->F2_DOC })
        Aadd(aCardData, {"F2_SERIE" , SF2->F2_SERIE })
        Aadd(aCardData, {"F2_VALBRUT" , SF2->F2_VALBRUT })
        Aadd(aCardData, {"F2_EMISSAO" , dtoc(SF2->F2_EMISSAO) })

        If len(aCardData) > 0 
            aRetAux	:= U_cpFNewTsk(cProcId, cUserFluig, nTaskDest, cComments, lComplete, lManager, aCardData)

            IF aRetAux[1]
                aRet := aRetAux
                aRet[2] := aRet[3]
            ELSE    
                aRet[1] := .F.
                aRet[2] := aRetAux[2]
            ENDIF	
        Endif
    Else
        aRet[1] := .F.
        aRet[2] := "Falha ao buscar dados do cliente."    
    Endif
Else
    aRet[1] := .F.
    aRet[2] := "Dados da nota a ser cancelada não encontrados."
Endif

Return aRet

/*/{Protheus.doc} IncOrder
    FunÃ§ao Alliar responsavel por cadastrar o cliente recebido
    @type  Static Function
    @author Julio Teixeira
    @since 29/06/2020
    @version 12
    @param cBody, string, Corpo do webhook recebido.
    @return aRet - {Boolean, MsgErro, ConteÃºdo de retorno}
/*/
Static Function IncOrder(oJson)

    Local nX, nY := 1
    Local aRet := {.T.,"",""} 
    Local aLinha, aCab:= {}
    Local cTesPed := SuperGetMV("ES_TESCON",.F.,"501")
    Local cMsgNf := SuperGetMV("CP16_MSGNF",.F.,"")
    Local cCondPag := SuperGetMV("CP16_CPG2B",.F.,"024")
    //Local cProdParc := SuperGetMV("CP16_PRODP",.F.,"23000001|23000002")
    Local cPgTipo := ""
    Local nPgValor := 0
    Local aArea := GetArea()
    Local aAreaSZ7 := SZ7->(GetArea())
    Local aAreaSA1 := SA1->(GetArea())
    Local cCusto := U_FSCustoFil(Alltrim(SM0->M0_CGC))
    Local aPed := {}
    Local lCliOk := .F.
    Local cPessoa := "J"
    Local aAssinat := {}
    Local aPeriodo := {}
    Local aPeriods := {}
    Local nOperAss := 4
    Local aEmpFil  := {}
    Local cCgcUnVen := ""
    Local nPosFil  := 0
    Local xUid 

    Default oJson := ""

    If ValType(oJson) == "J" 

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

        If aRet[1]

            DbSelectArea("SA1")
            SA1->(DbSetOrder(1))
            If SA1->(DbSeek(xFilial("SA1")+Alltrim(oJson['cliente']['cpf_cnpj'])))
                lCliOk := SA1->A1_XCLIST == "2"//1=Novo,2=Liberado
                cPessoa := SA1->A1_PESSOA//F ou J
            Endif

            If ValType(oJson:GetJsonObject("data_emissao")) != "U" 
                dDataBase := StoD(Left(StrTran(oJson['data_emissao'],"-",""),8))
            ENDIF

            For nX := 1 to len(oJson['itens'])

                nPreco := Val(oJson['itens'][nx]['vunit'])

                aAdd(aCab,{"C5_TIPO",       "N",            Nil})
                aAdd(aCab,{"C5_CLIENTE",    Left(oJson['cliente']['cpf_cnpj'],TamSx3("A1_COD")[1]) ,  Nil})
                aAdd(aCab,{"C5_LOJACLI",    SubStr(oJson['cliente']['cpf_cnpj'], TamSx3("A1_COD")[1]+1, TamSx3("A1_LOJA")[1] ) , Nil})
                aAdd(aCab,{"C5_CLIENT",     Left(oJson['cliente']['cpf_cnpj'],TamSx3("A1_COD")[1]),   Nil})
                aAdd(aCab,{"C5_LOJAENT",    SubStr(oJson['cliente']['cpf_cnpj'], TamSx3("A1_COD")[1]+1, TamSx3("A1_LOJA")[1] ) , Nil})
                aAdd(aCab,{"C5_TIPOCLI",    "F",            Nil})
                aAdd(aCab,{"C5_CONDPAG",    cCondPag ,      Nil})
                aAdd(aCab,{"C5_MENNOTA",    Left(cMsgNf,TamSX3("C5_MENNOTA")[1]) , Nil})
                If ValType(oJson:GetJsonObject("cnpj_unidade_venda")) <> "U" .AND. !Empty(oJson['cnpj_unidade_venda'])
                    
                    aAdd(aCab,{"C5_XIDPLE",     "U"+xUid ,       Nil})

                    aEmpFil := FWLoadSM0()
                    cCgcUnVen := alltrim(oJson['cnpj_unidade_venda'])
                    cCgcUnVen := StrTran(cCgcUnVen,"-","")
                    cCgcUnVen := StrTran(cCgcUnVen,".","")
                    cCgcUnVen := StrTran(cCgcUnVen,"/","")

                    nPosFil := aScan(aEmpFil, {|x| AllTrim(x[18]) == cCgcUnVen } )
                    If nPosFil > 0
                        aAdd(aCab,{"C5_XUNVALC", aEmpFil[nPosFil][2] ,       Nil})
                    Endif
                Else
                    aAdd(aCab,{"C5_XIDPLE",     "R"+xUid ,       Nil})
                Endif
                If ValType(oJson['itens'][nX]:GetJsonObject("cnpj_parceiro")) <> "U" //.AND. Alltrim(oJson['itens'][nX]['id']) $ cProdParc 
                    aAdd(aCab,{"C5_XCGCPAR",  oJson['itens'][nX]['cnpj_parceiro']  ,       Nil})
                Endif

                aAdd(aCab,{"C5_XBLQ", Iif(lCliOk,"4","1")   ,            Nil })//1=Cliente novo,4=Pedido pronto para faturamento
                
                For nY := 1 to len(oJson['pagamentos'])
                    aAdd(aCab,{"C5_PARC"+cValtoChar(nY),    nPreco*oJson['itens'][nY]['quant'] ,            Nil})
                    aAdd(aCab,{"C5_DATA"+cValtoChar(nY),    StoD(Left(StrTran(oJson['pagamentos'][nY]['data_venc'],"-",""),8)) ,            Nil})

                    cPgTipo := LEFT(oJson['pagamentos'][nY]['tipo'],2)
                    nPgValor += Val(oJson['pagamentos'][nY]['valor'])

                Next nY

                aLinha := {}
                
                aadd(aLinha,{"C6_ITEM",    StrZero(1,TamSx3("C6_ITEM")[1]), Nil})
                aadd(aLinha,{"C6_PRODUTO", Alltrim(oJson['itens'][nX]['id']),        Nil})
                aadd(aLinha,{"C6_TES",     cTesPed,        Nil})
                aadd(aLinha,{"C6_QTDVEN",  1, Nil})
                aadd(aLinha,{"C6_PRCVEN",  nPreco*oJson['itens'][nX]['quant'] , Nil})
                aadd(aLinha,{"C6_PRUNIT",  nPreco*oJson['itens'][nX]['quant'] , Nil})
                aadd(aLinha,{"C6_VALOR",   nPreco*oJson['itens'][nX]['quant'] , Nil})
                If !Empty(cCusto)
                    aadd(aLinha,{"C6_CCUSTO",  cCusto , Nil})
                Endif
                
                //aadd(aItens, aLinha)
                aRet := U_CP16GPED(aCab,{aLinha})

                aCab := {}
                aLinha := {}
                If !aRet[1]
                    Exit
                Else
                    DbSelectArea("SZ7")
                    SZ7->(DbSetOrder(1))
                    IF SZ7->(DbSeek(xFilial("SZ7")+aRet[3]))
                        RecLock("SZ7",.F.)
                    Else
                        RecLock("SZ7",.T.)
                    ENDIF

                    SZ7->Z7_FILIAL	:= xFilial("SZ7")
                    SZ7->Z7_PEDIDO	:= aRet[3]
                    SZ7->Z7_FORMA	:= cPgTipo
                    SZ7->Z7_VALOR	:= nPgValor
                    SZ7->Z7_QTDPAR	:= len(oJson['pagamentos'])
                    SZ7->Z7_PAGTO	:= StoD(Left(StrTran(oJson['pagamentos'][1]['data_venc'],"-",""),8))
                    SZ7->Z7_NUMCHQ	:= ""
                    SZ7->Z7_BAND	:= ""
                    SZ7->Z7_IDTRAN	:= Iif(ValType(oJson['pagamentos'][1]:GetJsonObject("numero_autorizacao_cartao")) == "U","",oJson['pagamentos'][1]['numero_autorizacao_cartao'])
                    
                    SZ7->( MsUnlock() )    
                Endif

            Next nX

            If aRet[1]

                //Gera registro no controle de assinaturas 
                aAdd(aAssinat,{"ZZC_CODASS",""})
                aAdd(aAssinat,{"ZZC_CODCLI",SC5->C5_CLIENTE})
                aAdd(aAssinat,{"ZZC_LOJCLI",SC5->C5_LOJACLI})

                aAdd(aPeriodo,{"ZZD_CODCLI", SC5->C5_CLIENTE})
                aAdd(aPeriodo,{"ZZD_LOJCLI", SC5->C5_LOJACLI})
                aAdd(aPeriodo,{"ZZD_CODPER", cValtoChar(Val(xUid))})
                aAdd(aPeriodo,{"ZZD_CICLO",  pegaCiclo(SC5->C5_CLIENTE,SC5->C5_LOJACLI,cValtoChar(Val(xUid)))})
                aAdd(aPeriodo,{"ZZD_CODASS", ""})
                aAdd(aPeriodo,{"ZZD_DTINIC", StoD(Left(StrTran(oJson['data_inicio_plano'],"-",""),8)) })
                aAdd(aPeriodo,{"ZZD_DTFIM",  StoD(Left(StrTran(oJson['data_fim_plano'],"-",""),8)) })
                aAdd(aPeriodo,{"ZZD_ESTORN", "2" })//"2=Não"
                aAdd(aPeriodo,{"ZZD_CGCUNF", Iif(ValType(oJson:GetJsonObject("cnpj_unidade_faturamento")) == "U","",oJson['cnpj_unidade_faturamento'])})
                aAdd(aPeriodo,{"ZZD_CGCUNV", Iif(ValType(oJson:GetJsonObject("cnpj_unidade_venda")) == "U","",oJson['cnpj_unidade_venda']) })
                aAdd(aPeriodo,{"ZZD_CODPLA", Iif(ValType(oJson:GetJsonObject("codigo_plano")) == "U","",oJson['codigo_plano']) })

                DbSelectArea("ZZC")
                ZZC->(DbSetOrder(2))
                If ZZC->(!DbSeek(xFilial("ZZC")+SC5->C5_CLIENTE+SC5->C5_LOJACLI))
                    aAdd(aAssinat,{"ZZC_DTASSI",StoD(Left(StrTran(oJson['data_emissao'],"-",""),8))})
                    aAdd(aAssinat,{"ZZC_STATUS", "1"})
                    //aAdd(aAssinat,{"ZZC_DADOS",cBody})
                    nOperAss := 3 
                Endif

                aAdd(aPeriods,aPeriodo)

                aRet := U_CP16ASS1(aAssinat,aPeriods,nOperAss)//Inclusão ou alteração de assinatura   

            ENDIF

        Endif
        
        RestArea(aArea)
        RestArea(aAreaSZ7)
        RestArea(aAreaSA1)
        FreeObj(oJson)

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
        cQuery += "WHERE C5_FILIAL = '" + xFilial("SC5") + "' " 
        cQuery += "AND C5_XIDPLE = '" +cIdSubs+ "' "
        cQuery += "AND D_E_L_E_T_ = '' "
        cQuery := ChangeQuery(cQuery)
        DBUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cArea, .T., .T.)  
    
        If (cArea)->(!EOF())

            aRet[3] := { (cArea)->C5_NUM , (cArea)->C5_REC  }

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


/*/{Protheus.doc} CP16JNFB
    
    Gera o JSON para envio dos dados da NF B2B transmitida para Ateliware

    @type  User Function
    @author Julio Teixeira - Compila
    @since 27/07/2020
    @version 12
    @param 
    @return aRet
/*/
User Function CP16JNFB(cCgcFil,cIdVindi,cSerie,cDoc,cChvNfe,cDatEmi,cNFElet,nTotImp,nTot)

Local aRet := {.T.,"",""}
Local cJson := "" 
Local nIdVindi
Local cURLAW   := SuperGetMV("CP16_URLAW",.F.,"https://staging1.cartaoalianca.com.br")
Local cURLNFSe := SuperGetMV("CP16_URLNF",.F.,"https://bhissdigital.pbh.gov.br/nfse/pages/consultaNFS-e_cidadao.jsf")
Local cUserWSR := Alltrim(SuperGetMV("CP16_USRAW",.F.,""))//svc.alianca
Local cSenhWSR := Alltrim(SuperGetMV("CP16_SENAW",.F.,""))//&@oV#pqT9Rvi
Local cPath := "/enterprise_payment_webhooks/invoice"

Default cCgcFil := ""
Default cIdVindi := ""
Default cSerie  := ""
Default cDoc    := ""
Default cChvNfe := ""
Default cDatEmi := ""
Default cNFElet := ""
Default nTot    := 0
Default nTotAbat := 0

If !Empty(cNFElet)
    DbSelectArea("SE1")
    SE1->(DbSetOrder(2)) 
    If SF2->F2_DOC == cDoc .AND. SF2->F2_SERIE == cSerie .AND. SE1->(DbSeek(xFilial("SE1")+SF2->(F2_CLIENTE+F2_LOJA+F2_SERIE+F2_DOC+Padr("",TamSX3("E1_PARCELA")[1])+"NF")))
        
        nTot := SE1->E1_SALDO
        nTotAbat := nTot - SomaAbat(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",1,,SE1->E1_CLIENTE,SE1->E1_LOJA,SE1->E1_FILIAL,,)
        
        If Right(cURLAW,1) == "/"//Tratamento da url para nao duplicar a barra
            cURLAW := Left(cURLAW, len(cURLAW)-1)//Remove barra do final
        Endif

        cIdVindi := SubStr(cIdVindi,2,len(cIdVindi))
        nIdVindi := Val(cIdVindi)

        cDatEmi := SubStr(cDatEmi,1,4)+"-"+SubStr(cDatEmi,5,2)+"-"+SubStr(cDatEmi,7,2)

        cJson := '{'
        cJson +=    '"invoice":{'
        cJson +=        '"code": '+cValtoChar(nIdVindi)+','  // 180_713, # id da assinatura na Vindi
        cJson +=        '"status": "issued",'              // 
        cJson +=        '"series_number": "'+cSerie+'",'        //'1', # série da nota, em string (qualquer formato)
        cJson +=        '"rps_number": "'+cDoc+'",'             //'1', # rps da nota, em string (qualquer formato) - opcional
        cJson +=        '"number": "'+cNFElet+'",'              //'1', # número da nota, em string (qualquer formato)
        cJson +=        '"validation_key": "'+cChvNfe+'",'      //'validation_key', # código da chave de validação (qualquer formato)
        cJson +=        '"emission_date": "'+cDatEmi+'",'       //'2020-04-01', # data de emissão em YYYY-MM-DD
        cJson +=        '"description": "",'                    //'Produto Cartão Aliança Trimestral', # descrição do produto que veio na bill
        cJson +=        '"external_url": "'+cURLNFSe+'",'        //'"https://link-exemplo.direto/nota.pdf', # PDF da nota (link para onde estiver, se houver) - opcional
        cJson +=        '"seller_cnpj": "'+cCgcFil+'",'          //'12345678000199' # CNPJ da empresa vendedora (alliar)
        cJson +=        '"value_with_taxes" : '+cValtoChar(nTot)+','             //
        cJson +=        '"value_without_taxes" : '+cValtoChar(nTotAbat)         //
        cJson +=    '}'
        cJson += '}'

        aRet := U_CP16POST(cURLAW,cPath,cJson,cUserWSR,cSenhWSR)
    Else
        aRet[1] := .F.
        aRet[2] := "Título financeiro não encontrado para obtenção dos valores para geração do boleto."
    Endif    
Else
    aRet[1] := .F.
    aRet[2] := "Somente os documentos transmitidos podem ser integrados."
Endif

Return aRet

/*/{Protheus.doc} CP16JNFD
    
    Gera o JSON para envio dos dados da NF B2B transmitida para Ateliware

    @type  User Function
    @author Julio Teixeira - Compila
    @since 27/07/2020
    @version 12
    @param 
    @return aRet
/*/
User Function CP16JNFD(cCgcFil,cIdVindi,cSerie,cDoc,cChvNfe,cDatEmi,nTot)

Local aRet := {.T.,"",""}
Local cJson := "" 
Local nIdVindi
Local cURLAW   := SuperGetMV("CP16_URLAW",.F.,"https://staging1.cartaoalianca.com.br")
Local cUserWSR := Alltrim(SuperGetMV("CP16_USRAW",.F.,""))//svc.alianca
Local cSenhWSR := Alltrim(SuperGetMV("CP16_SENAW",.F.,""))//&@oV#pqT9Rvi
Local cPath := "/enterprise_payment_webhooks/debit_note"

Default cCgcFil := ""
Default cIdVindi := ""
Default cSerie  := ""
Default cDoc    := ""
Default cChvNfe := ""
Default cDatEmi := ""
 
    If Right(cURLAW,1) == "/"//Tratamento da url para nao duplicar a barra
        cURLAW := Left(cURLAW, len(cURLAW)-1)//Remove barra do final
    Endif

    cIdVindi := SubStr(cIdVindi,2,len(cIdVindi))
    nIdVindi := Val(cIdVindi)

    cDatEmi := SubStr(cDatEmi,1,4)+"-"+SubStr(cDatEmi,5,2)+"-"+SubStr(cDatEmi,7,2)

    cJson := '{'
    cJson +=    '"debit_note":{'
    cJson +=        '"code": '+cValtoChar(nIdVindi)+','  // 180_713, # id da assinatura na Vindi
    cJson +=        '"status": "issued",'              // 
    cJson +=        '"series_number": "'+cSerie+'",'        //'1', # série da nota, em string (qualquer formato)
    cJson +=        '"rps_number": "'+cDoc+'",'             //'1', # rps da nota, em string (qualquer formato) - opcional
    cJson +=        '"emission_date": "'+cDatEmi+'",'       //'2020-04-01', # data de emissão em YYYY-MM-DD
    cJson +=        '"description": "debit_note",'                    //'Produto Cartão Aliança Trimestral', # descrição do produto que veio na bill
    cJson +=        '"seller_cnpj": "'+cCgcFil+'",'          //'12345678000199' # CNPJ da empresa vendedora (alliar)
    cJson +=        '"value" : '+cValtoChar(nTot)   
    cJson +=    '}'
    cJson += '}'

    aRet := U_CP16POST(cURLAW,cPath,cJson,cUserWSR,cSenhWSR)
   
Return aRet

/*/{Protheus.doc} CP16CNFB
    
    Gera o JSON para envio dos dados da NF B2B cancelada para Ateliware

    @type  User Function
    @author Julio Teixeira - Compila
    @since 27/07/2020
    @version 12
    @param 
    @return aRet
/*/
User Function CP16CNFB(cIdVindi,cNF,cSerie)

Local aRet := {.T.,"",""}
Local cJson := "" 
Local nIdVindi
Local cURLAW   := SuperGetMV("CP16_URLAW",.F.,"https://staging1.cartaoalianca.com.br")
Local cUserWSR := Alltrim(SuperGetMV("CP16_USRAW",.F.,""))//svc.alianca
Local cSenhWSR := Alltrim(SuperGetMV("CP16_SENAW",.F.,""))//&@oV#pqT9Rvi
Local cPath := "/enterprise_payment_webhooks/cancel_invoice"

Default cIdVindi := ""
Default cNF := ""
Default cSerie := ""

If !Empty(cIdVindi)

    If Left(AllTrim(cIdVindi),1) == "U"
        cPath := "/payment_webhooks/cancel_invoice"
    Endif

    If Right(cURLAW,1) == "/"//Tratamento da url para nao duplicar a barra
        cURLAW := Left(cURLAW, len(cURLAW)-1)//Remove barra do final
    Endif

    cIdVindi := SubStr(cIdVindi,2,len(cIdVindi))
    nIdVindi := Val(cIdVindi)

    cJson := '{'
    cJson +=    '"invoice":{'
    cJson +=        '"code": '+cValtoChar(nIdVindi)+',' 
    cJson +=        '"status": "canceled",' 
    cJson +=        '"series_number": "'+cSerie+'",'
    cJson +=        '"rps_number": "'+cNF+'"' 
    cJson +=    '}'
    cJson += '}'

    aRet := U_CP16POST(cURLAW,cPath,cJson,cUserWSR,cSenhWSR)
Else
    aRet[1] := .F.
    aRet[2] := "Id não informado."
Endif

Return aRet


/*/{Protheus.doc} pegaCiclo
    Pega o ciclo/item para cadastrar na tabela ZZD
    @type  Static Function
    @author Julio Teixeira
    @since 02/11/2020
    @version version
    @param param_name, param_type, param_descr
    @return aRet
/*/
Static Function pegaCiclo(cCli,cLoja,cCodPer)
    
Local cRet := "001"
Local cQuery := ""
Local cAlias1 := GetNextAlias()
Local cAlias2 := GetNextAlias()

Default cCodPer := ""
Default cCli := ""
Default cLoja := ""

cQuery := " SELECT ZZD_CICLO "
cQuery += " FROM "+RetSqlName("ZZD")+" NOLOCK "   
cQuery += " WHERE ZZD_CODCLI = '"+cCli+"' "
cQuery += " AND ZZD_LOJCLI = '"+cLoja+"' "
cQuery += " AND ZZD_CODPER = '"+cCodPer+"' "
cQuery += " AND D_E_L_E_T_ = '' "

DBUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAlias1, .T., .T.)  
    
If (cAlias1)->(!EOF())
    cRet := (cAlias1)->ZZD_CICLO
Else
    cQuery := " SELECT COUNT(1) NCOUNT "
    cQuery += " FROM "+RetSqlName("ZZD")+" NOLOCK "   
    cQuery += " WHERE ZZD_CODCLI = '"+cCli+"' "
    cQuery += " AND ZZD_LOJCLI = '"+cLoja+"' "
    cQuery += " AND D_E_L_E_T_ = '' "

    DBUseArea(.T., "TOPCONN", TcGenQry( , , cQuery), cAlias2, .T., .T.)  
        
    If (cAlias2)->(!EOF())
        cRet := STRZERO((cAlias2)->NCOUNT+1,3)
    ENDIF    

ENDIF 

Return cRet

/*/{Protheus.doc} GetOrders

    Funçao para retornar pedidos de um mesmo id

    @type  Function
    @author Julio Teixeira - Compila
    @since 11/11/2020
    @version version
    @param cIdSubs - Id do pedido
    @return aRet - {Boolean, MsgErro, Lista de periodos encontrados }
/*/
Static Function GetOrders(cIdSubs)

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
            While (cArea)->(!EOF())

                aAdd(aRet[3],{ (cArea)->C5_NUM , (cArea)->C5_REC  })

                (cArea)->(DbSkip())
            Enddo
        Else
            aRet[1] := .F.
            aRet[2] := "Nenhum pedido encontrado!"
        Endif

        (cArea)->(dbCloseArea())
    Else
        aRet[1] := .F.
        aRet[2] := "Nenhum id informado para busca dos periodos"
    Endif

    RestArea(aArea)

Return aRet
