#INCLUDE "TOTVS.CH"

User Function CP16000()
Return 

//-------------------------------------------------------------------
/*/ {REST Web Service} CP16GPED
    Função generica de geração de pedido de venda
    @version undefined
    @since 25/03/2020
    @author Julio Teixeira | www.compila.com.br
    @param aCab - Cabeçalho do pedido
    @param aItens - Itens do pedido
    @param aOper - Operação desejada, Inclusão, Alteração ou Exclusão
/*/
//-------------------------------------------------------------------
User Function CP16GPED(aCab, aItens, nOper)

Local cNumPed := ""
Local aErroAuto := {}
Local aRet := {.T.,"",""}
Local nCount := 1
Local cLogErro := ""

Private lMsErroAuto		:= .F.
Private lAutoErrNoFile	:= .T.

Default aCab := {}
Default aItens := {}
Default nOper := 3

If len(aCab) >= 1
    
    If nOper == 3
        cNumPed := GetSxeNum("SC5","C5_NUM") 
        aAdd(aCab,{"C5_NUM" , cNumPed , Nil})
    Endif
        
    MsExecAuto({|x,y,z| MATA410( x, y, z )}, aCab , aItens , nOper)

    If !lMsErroAuto
        FwLogMsg("CP16GPED", /*cTransactionId*/, "REST", FunName(), "", "01", "Pedido "+cNumPed+", processado com sucesso! ", 0, 0, {}) 
        aRet[3] := cNumPed
        If nOper == 3
            ConfirmSX8()
        Endif
    Else
        If nOper == 3
            RollBAckSx8()
            cNumPed := ""
        Endif    
        FwLogMsg("CP16GPED", /*cTransactionId*/, "REST", FunName(), "", "01", "Erro!", 0, 0, {}) 
        aErroAuto := GetAutoGRLog()
        For nCount := 1 To Len(aErroAuto)
            cLogErro += Iif( ValType(aErroAuto[nCount]) == "C", StrTran(StrTran(aErroAuto[nCount], "<", ""), "-", "")+" " , "")
            aRet[1] := .F.
            aRet[2] := cLogErro
        Next nCount
        ConOut(cLogErro)
    EndIf
Endif

Return aRet

//-------------------------------------------------------------------
/*/ {REST Web Service} CP16CCLI
    Função generica de cadastro de cliente
    @version undefined
    @since 25/03/2020
    @author Julio Teixeira | www.compila.com.br
    @param aCab - Cabeçalho do pedido
    @param aItens - Itens do pedido
    @param aOper - Operação desejada, Inclusão, Alteração ou Exclusão
/*/
//-------------------------------------------------------------------
User Function CP16CCLI(aCli, nOper)

Local cCodCli := ""
Local cLojCli := ""
Local aErroAuto := {}
Local lMvcSA1 := SuperGetMv("MV_MVCSA1",.F.,.F.)
Local nCodCli := 0
Local nLojCli := 0
Local aRet := {.T.,"",""}
Local nCount := 1
Local cLogErro := ""
Local nX := 1
Local aPosCpo := {}

Private lMsErroAuto		:= .F.
Private lAutoErrNoFile	:= .T.

Default aCli := {}
Default nOper := 0

If len(aCli) >= 1

    conout("### CP16CCLI ")
    nCodCli := aScan(aCli, {|x| AllTrim(x[1]) == "A1_COD"} )
    nLojCli := aScan(aCli, {|x| AllTrim(x[1]) == "A1_LOJA"} )

    If nCodCli <= 0 
        cCodCli := GetSxeNum("SA1","A1_COD")
        aAdd(aCli,{"A1_COD" , cCodCli , Nil})
    Else
        cCodCli := aCli[nCodCli][2]    
    Endif    

    aAdd( aPosCpo ,aScan(aCli, {|x| AllTrim(x[1]) == "A1_NREDUZ"}) )
    aAdd( aPosCpo ,aScan(aCli, {|x| AllTrim(x[1]) == "A1_NOME"}) )
    aAdd( aPosCpo ,aScan(aCli, {|x| AllTrim(x[1]) == "A1_BAIRRO"}) )
    
    //TRATAMENTO caracteres especiais
    For nX := 1 to len(aPosCpo)
        If aPosCpo[nX] > 0
            aCli[aPosCpo[nX],2] := StrTran(aCli[aPosCpo[nX],2],"á","a")
            aCli[aPosCpo[nX],2] := StrTran(aCli[aPosCpo[nX],2],"é","e")
            aCli[aPosCpo[nX],2] := StrTran(aCli[aPosCpo[nX],2],"í","i")
            aCli[aPosCpo[nX],2] := StrTran(aCli[aPosCpo[nX],2],"ó","o")
            aCli[aPosCpo[nX],2] := StrTran(aCli[aPosCpo[nX],2],"ú","u")
            aCli[aPosCpo[nX],2] := StrTran(aCli[aPosCpo[nX],2],"ã","a")
            aCli[aPosCpo[nX],2] := StrTran(aCli[aPosCpo[nX],2],"õ","o")
            aCli[aPosCpo[nX],2] := StrTran(aCli[aPosCpo[nX],2],"à","a")
            aCli[aPosCpo[nX],2] := StrTran(aCli[aPosCpo[nX],2],"ç","c")
            aCli[aPosCpo[nX],2] := StrTran(aCli[aPosCpo[nX],2],"ê","e")
            aCli[aPosCpo[nX],2] := StrTran(aCli[aPosCpo[nX],2],"Á","A")
            aCli[aPosCpo[nX],2] := StrTran(aCli[aPosCpo[nX],2],"É","E")
            aCli[aPosCpo[nX],2] := StrTran(aCli[aPosCpo[nX],2],"Í","I")
            aCli[aPosCpo[nX],2] := StrTran(aCli[aPosCpo[nX],2],"Ó","O")
            aCli[aPosCpo[nX],2] := StrTran(aCli[aPosCpo[nX],2],"Ú","U")
            aCli[aPosCpo[nX],2] := StrTran(aCli[aPosCpo[nX],2],"Â","A")
            aCli[aPosCpo[nX],2] := StrTran(aCli[aPosCpo[nX],2],"Ê","E")
            aCli[aPosCpo[nX],2] := StrTran(aCli[aPosCpo[nX],2],"Ô","O")
        Endif
    Next nX

    If nLojCli <= 0 
        cLojCli := StrZero(1,TamSx3("A1_LOJA")[1])
        aAdd(aCli,{"A1_LOJA", cLojCli ,Nil})
    Else
        cLojCli := aCli[nLojCli][2]
    Endif    
    
    If !lMvcSA1
        MsExecAuto({|a,b| MATA030( a , b )}, aCli, nOper)
    Else
        MSExecAuto({|a,b,c| CRMA980( a , b , c )}, aCli, nOper, {})
    Endif

    If !lMsErroAuto
      ConOut("CP16CCLI - Cliente processado com sucesso! " + cCodCli)
      aRet[3] := cCodCli+cLojCli
      Iif( nCodCli <= 0 , ConfirmSX8() ,)
    Else
        Iif( nCodCli <= 0 , RollBAckSx8() , )//Faz rollback caso tenha código reservado
        cCodCli := ""
        ConOut("CP16CCLI - Erro na inclusao!")
        aErroAuto := GetAutoGRLog()
        For nCount := 1 To Len(aErroAuto)
            If Valtype(aErroAuto[nCount]) == "C"    
                cLogErro += StrTran(StrTran(aErroAuto[nCount], "<", ""), "-", "") + " "                
            Endif    
        Next nCount
        ConOut(cLogErro)
        aRet[1] := .F.
        aRet[2] := cLogErro
    EndIf
Endif

Return aRet

/*/{Protheus.doc} CP16GET
    Função Responsável por fazer o get na API informada e retornar o JSON da resposta
    @type  User Function
    @author Julio Teixeira
    @since 25/03/2020
    @version 12
    @param cBody, string, Corpo do webhook recebido.
    @return lRet, boolean, Booleano que informa se o processamento do body ocorreu com sucesso.
/*/
User Function CP16GET(cUrl,cPath,cUsuario,cSenhaEP)

Local cBody := ""
Local aRet := {.T.,"",""}
Local aHeader := {}
Local oRestClient 	:= FWRest():New(cUrl)
Local oJson := JsonObject():New()
Local cCatch := ""

Default cUrl := ""
Default cPath := ""
Default cUsuario := ""
Default cSenhaEP := ""

If !Empty(cUrl) .AND. !Empty(cPath) 
    
    If !Empty(cUsuario)
        aAdd(aHeader,"Authorization: Basic "+ Encode64(cUsuario+":"+cSenhaEP) )
    Endif
    aAdd(aHeader,"Content-Type: application/json")

    oRestClient:setPath(cPath)
    
    // Conecta
	If oRestClient:Get(aHeader)
        cBody := oRestClient:GetResult()
        cBody := DecodeUtf8(cBody, "")

        cCatch := oJson:FromJson(cBody)
        If Valtype(cCatch) == "U"
            aRet[3] := oJson
        Else
            aRet[1] := .F.   
            aRet[2] := "Falha na estrutura retornada pelo endpoint"
        Endif
    Else
        aRet[1] := .F.
        aRet[2] := oRestClient:GetLastError()   
    Endif    

Endif

FreeObj(oJson)
FreeObj(oRestClient)

Return aRet


/*/{Protheus.doc} CP16GMUN
    (long_description)
    @type  Function
    @author user
    @since 27/03/2020
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
/*/
User Function CP16GMUN(cDesMun,cCep)
    
Local aRet := {.T.,"",""}
Local cCodMun := ""
Local aArea := GetArea()
Local aAreaCC2 := CC2->(GetArea())

Default cDesMun := ""
Default cCep := ""

If !Empty(cDesMun)
    cDesMun := UPPER(cDesMun)
    cDesMun := StrTran( cDesMun, "Ã","A")
    cDesMun := StrTran( cDesMun, "Õ","O")

    cDesMun := StrTran( cDesMun, "Ç","C")

    cDesMun := StrTran( cDesMun, "Á","A")
    cDesMun := StrTran( cDesMun, "É","E")
    cDesMun := StrTran( cDesMun, "Í","I")
    cDesMun := StrTran( cDesMun, "Ó","O")
    cDesMun := StrTran( cDesMun, "Ú","U")

    cDesMun := StrTran( cDesMun, "Â","A")
    cDesMun := StrTran( cDesMun, "Ê","E")
    cDesMun := StrTran( cDesMun, "Î","I")
    cDesMun := StrTran( cDesMun, "Ô","O")
    cDesMun := StrTran( cDesMun, "Û","U")

    DbSelectArea("CC2")
    CC2->(DbSetOrder(2))
    CC2->(dbGoTop())    

    If CC2->( MsSeek( xFilial( "CC2" ) + cDesMun ) )	    
        cCodMun := CC2->CC2_CODMUN
        aRet[3] := cCodMun
    Else
        aRet[1] := .F.
        aRet[2] := "CP16GMUN - Código do município não encontrado no cadstro CC2"
    EndIf
Elseif !Empty(cCep)
    
    cCep := StrTran( cCep, "-","")
    cCep := StrTran( cCep, " ","")
    
    aRet := U_CP16GET("https://viacep.com.br/ws/",cCep+"/json/")  //20210326
    
    If aRet[1]
        aRet[3] := cValToChar(aRet[3]['ibge'])
    Else
        aRet[2] += " - Falha ao obter CEP via https://viacep.com.br/ws/"+cCep+"/json"   
    Endif    
Else
    aRet[1] := .F.
    aRet[2] := "CP16GMUN - Descrição do município ou CEP não informados."
Endif

RestArea(aAreaCC2)
RestArea(aArea)

Return aRet

/*/{Protheus.doc} CP16POST
    Função Responsável por fazer o get na API informada e retornar o JSON da resposta
    @type  User Function
    @author Julio Teixeira
    @since 09/04/2020
    @version 12
    @param URL, Caminho, Corpo, Usuário, Senha 
    @return lRet, boolean, Booleano que informa se o processamento do body ocorreu com sucesso.
/*/
User Function CP16POST(cUrl,cPath,cBody,cUsuario,cSenhaEP)


Local aRet := {.T.,"",""}
Local aHeader := {}
Local oRestClient
Local oJson := JsonObject():New()
Local cCatch := ""

Default cUrl := ""
Default cPath := ""
Default cBody := ""
Default cUsuario := ""
Default cSenhaEP := ""

If !Empty(cUrl) .AND. !Empty(cPath) 
    
    oRestClient := FWRest():New(cUrl)

    If !Empty(cUsuario)
        aAdd(aHeader,"Authorization: Basic "+ Encode64(cUsuario+":"+cSenhaEP) )
    Endif    
    aAdd(aHeader,"Content-Type: application/json")
    // define o conteúdo do body
    oRestClient:SetPostParams(cBody)

    oRestClient:SetPath(cPath)
    
    // Conecta
	If oRestClient:Post(aHeader)
        cBody := oRestClient:GetResult()
        cBody := DecodeUtf8(cBody, "")

        cCatch := oJson:FromJson(cBody)
        If Valtype(cCatch) == "U"
            aRet[3] := oJson
        Else
            aRet[1] := .F.   
            aRet[2] := "Falha na estrutura retornada pelo endpoint"
        Endif
    Else
        aRet[1] := .F.
        aRet[2] := oRestClient:GetLastError()   
        aRet[2] += Iif(ValType(oRestClient:GetResult())=="C",DecodeUTF8(oRestClient:GetResult()),"")
    Endif    

    FreeObj(oRestClient)

Endif

FreeObj(oJson)

Return aRet


/*/{Protheus.doc} CP16EXCD
    
    Função para chamar a exclusão do documento de saída 
    
    @type User Function
    @author Julio Teixeira
    @since 27/03/2020
    @version 12
    @param cDoc, cSerie
    @return aRet
/*/
User Function CP16EXCD(cDoc,cSerie)
    // DECLARAÇÃO DE VARIÁVEIS LOCAIS
    Local aArea := GetArea()
    Local aHeaderF2 := {}
    Local aErroAuto := {}
    Local aRet := {.T.,"",}
    Local nCount := 1
    Local cLogErro := ""
    // DECLARAÇÃO DE VARIÁVEIS PRIVADAS
    Private lMsErroAuto := .F.

    Default cDoc := ""
    Default cSerie := ""

    If !Empty(cDoc) .AND. !Empty(cSerie) 

        AAdd(aHeaderF2, {"F2_DOC",      PadR(Alltrim(cDoc),   TamSX3("F2_DOC")[1]),      NIL}) // NÚMERO DA NOTA
        AAdd(aHeaderF2, {"F2_SERIE",    PadR(Alltrim(cSerie), TamSX3("F2_SERIE")[1]),    NIL}) // SÉRIE

        // REALIZA A OPERAÇÃO
        MsExecAuto({|x| MATA520(x)}, aClone(aHeaderF2))

        // VERIFICA STATUS FINAL
        If !lMsErroAuto
            ConOut("CP16EXCD - Documento excluido com sucesso! Doc: " + cDoc + " Serie: "+cSerie )
        Else
            ConOut("CP16EXCD - Erro na exclusão do documento!")
            aErroAuto := GetAutoGRLog()
            For nCount := 1 To Len(aErroAuto)
                If Valtype(aErroAuto[nCount]) == "C"    
                    cLogErro += StrTran(StrTran(aErroAuto[nCount], "<", ""), "-", "") + " "                
                Endif    
            Next nCount
            ConOut(cLogErro)
            aRet[1] := .F.
            aRet[2] := cLogErro
        EndIf
    
    Endif

    // RESTAURA AREA
    RestArea(aArea)

Return aRet

/*/{Protheus.doc} CP16MAIL

envia email

@author TOTVS
@since 14/01/2015
@version x.x
@param Parâmetro, Tipo, Descrição do parâmetro
@return Tipo, Descrição do retorno
@description
/*/
User Function CP16MAIL(cTit,cText,cPara)

	Local aArea			:= GetArea()
	//
	Local oMailServer 	:= Nil
	Local lRetorno    	:= .F.
	Local nError      	:= 0	
	Local nPos			:= 0
	Local nDomain		:= 0
	Local cMsgErro      := ""
	//								
	Local nSMTPPort   	:= SuperGetMV("MV_PORSMTP", .F., 25 )  				// PORTA SMTP
	Local cSMTPAddr   	:= AllTrim(SuperGetMV("MV_RELSERV", .F., "" ))  	// ENDERECO SMTP
	Local cUser       	:= AllTrim(SuperGetMV("MV_RELACNT", .F., "" ))  	// USUARIO PARA AUTENTICACAO SMTP
	Local cPass       	:= AllTrim(SuperGetMV("MV_RELPSW" , .F., "" ))  	// SENHA PARA AUTENTICA SMTP
	Local cUserAut    	:= AllTrim(SuperGetMV("MV_RELAUSR", .F., "" ))
	Local lAutentica  	:= SuperGetMV("MV_RELAUTH", .F., .F.) 				// VERIFICAR A NECESSIDADE DE AUTENTICACAO
	Local nSMTPTime   	:= SuperGetMV("MV_RELTIME", .F., 120) 				// TIMEOUT PARA A CONEXAO
	Local lSSL        	:= SuperGetMV("MV_RELSSL" , .F., .F.)  				// VERIFICA O USO DE SSL
	Local lTLS        	:= SuperGetMV("MV_RELTLS" , .F., .F.)  				// VERIFICA O USO DE TLS
	//
	Local cSubject		:= OemToAnsi( cTit )
	Local cBody			:= ""

    Private cDe       := Trim(GetMV('MV_RELFROM'))
	Private cCC       := ""
	Private cCCO      := ""
	Private cReplyTo  := ""

	BEGIN SEQUENCE

		If Empty(cPara)
			Break
		EndIf

		cBody := ''
		cBody += '<!DOCTYPE html>' + CRLF
		cBody += '<html lang="en" xmlns="http://www.w3.org/1999/xhtml">' + CRLF
		cBody += '<head>' + CRLF
		cBody += '    <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">' + CRLF
		cBody += '    <title>'+cTit+'</title>' + CRLF
		cBody += '</head>' + CRLF
		cBody += '<body bgcolor="#FFFFFF" style="min-width:100%; padding:0;  margin:0; -webkit-text-size-adjust:none; -ms-text-size-adjust:100%">' + CRLF
		cBody += '<h3>'+cText+'</h3>' + CRLF
		cBody += '</body>' + CRLF
		cBody += '</html>' + CRLF

		//- Ajusta endereco SMPT
		If ( nPos := AT(":", cSMTPAddr) ) > 0
			cSMTPAddr := SubStr( cSMTPAddr,1,nPos-1 )	
		EndIf

		oMailServer := TMailManager():New()

		// Usa SSL, TLS ou nenhum na inicializacao
		oMailServer:SetUseSSL(lSSL)
		oMailServer:SetUseTLS(lTLS)

		// Inicializacao do objeto de Email
		If nError == 0
			nError := oMailServer:Init("", cSMTPAddr, cUser, cPass, 0, nSMTPPort)
			If nError <> 0
				cMsgErro := "Falha ao conectar: " + oMailServer:getErrorString(nError)
				Help( " ", 1, "02 - Autenticação", , cMsgErro, 4, 5 )
				Break
			EndIf
		Endif

		// Define o Timeout SMTP
		If (nError == 0 .AND. oMailServer:SetSMTPTimeout(nSMTPTime) <> 0)
			nError := 1
			cMsgErro := "Falha ao definir timeout"
			Help( " ", 1, "02 - Autenticação", , cMsgErro, 4, 5 )
			Break
		EndIf

		// Conecta ao servidor
		If nError == 0
			nError := oMailServer:SmtpConnect()
			If nError <> 0
				cMsgErro := "Falha ao conectar: " + oMailServer:getErrorString(nError)  
				oMailServer:SMTPDisconnect()
				Help( " ", 1, "02 - Autenticação", , cMsgErro, 4, 5 )
				Break
			EndIf
		EndIf

		// Realiza autenticacao no servidor
		If nError == 0 .AND. lAutentica
			nError := oMailServer:SmtpAuth(cUserAut,cPass)
			If nError != 0
				nDomain := At("@",cUserAut)
				If ( nDomain > 0 )
					nError := oMailServer:SmtpAuth(LTrim(Subs(cUserAut,1,nDomain-1)),cPass)
				EndIf
			EndIf

			If nError <> 0
				cMsgErro := "Falha ao autenticar: " + oMailServer:getErrorString(nError)   
				oMailServer:SMTPDisconnect()
				Help( " ", 1, "02 - Autenticação", , cMsgErro, 4, 5 )
				Break
			EndIf
		EndIf

		lRetorno := (nError == 0) 

		If ( lRetorno )

			oMessage:= TMailMessage():New()
			oMessage:Clear()
			oMessage:cFrom    := cDe
			oMessage:cTo      := cPara
			oMessage:cCc      := cCc
			oMessage:cBcc     := cCCO
			oMessage:cSubject := cSubject
			oMessage:cBody    := cBody
			oMessage:cReplyTo := cReplyTo

			If ( lRetorno )  

				nError := oMessage:Send(oMailServer)

				If nError <> 0
					cMsgErro := "Falha ao enviar o e-mail: " + oMailServer:GetErrorString(nError)   
					Help( " ", 1, "02 - Autenticação", , cMsgErro, 4, 5 )
					Break
				EndIf

				lRetorno := ( nError == 0 )

			Endif	

			oMailServer:SmtpDisconnect()    

		EndIf	

	END SEQUENCE

	RestArea( aArea )

Return( lRetorno )


/*/{Protheus.doc} CP16RESI
    Elimina resíduo do pedido
    @type  Static Function
    @author user
    @since 27/05/2020
    @version version
    @param cC5Num
    @return aRet
/*/
User Function CP16RESI(cC5Num)

	Local aArea		:= GetArea()
	Local aAreaSC5	:= SC5->(GetArea())
	Local aAreaSC6	:= SC6->(GetArea())
	Local aAreaSC9	:= SC9->(GetArea())
    Local aItem := {}
    Local aRet := {.T.,"",}

    Default cC5Num := ""
    
    If !Empty(cC5Num)

        Begin Transaction

            DbSelectArea("SC5")
            DbSetOrder(1)		//C5_FILIAL, C5_NUM

            If SC5->(DbSeek(xFilial("SC5") + cC5Num))

                DbSelectArea("SC6")
                SC6->(DbSetOrder(1))			//C6_FILIAL, C6_NUM, C6_ITEM

                If SC6->(DbSeek(xFilial("SC6") + SC5->C5_NUM))
                    While !SC6->(Eof()) .AND. xFilial("SC6") + SC5->C5_NUM == SC6->C6_FILIAL + SC6->C6_NUM

                        //Faz alteração no pedido para estornar as liberações
                        aAdd(aItem,{"C6_ITEM",SC6->C6_ITEM,})
                        aAdd(aItem,{"C6_NUM",SC6->C6_NUM,})
                        aAdd(aItem,{"C6_PRODUTO",SC6->C6_PRODUTO,})
                        aAdd(aItem,{"C6_PRCVEN",SC6->C6_PRCVEN,})
                        aAdd(aItem,{"C6_QTDVEN",SC6->C6_QTDVEN,})
                        aAdd(aItem,{"C6_VALOR",SC6->C6_VALOR,})
                        aAdd(aItem,{"C6_TES",SC6->C6_TES,})
                        aRet := U_CP16GPED({{"C5_NUM",cC5Num,},{"C5_MENNOTA",".",}},{aItem},4)//Chama execauto MATA410
                        If !aRet[1]
                            aRet[1] := .F.
                            aRet[2] := "Erro durante o estorno de liberação do Pedido " + SC5->C5_NUM
                            DisarmTransaction()
                            Exit
                        Endif

                        If aRet[1] .AND. !MaResDoFat(SC6->(Recno()), .T., .T.)
                            aRet[1] 	:= .F.
                            aRet[2] := "Erro durante a Eliminação dos Residuos do Item " + SC6->C6_ITEM + " do Pedido " + SC5->C5_NUM
                            DisarmTransaction()
                            Exit
                        EndIf
                        aItem := {}
                        SC6->(DbSkip())
                    Enddo
                EndIf
                       
            EndIf

        End Transaction
    Endif

	RestArea(aAreaSC9)
	RestArea(aAreaSC6)
	RestArea(aAreaSC5)
	RestArea(aArea)

Return aRet

/*/{Protheus.doc} BxTit
Baixa titulo de acordo com os parametros passados
@author Augusto Ribeiro | www.compila.com.br
@since 29/11/2016
@version 6
@param param
@return return, return_description
/*/
User Function CP16BTIT(_nRecnoE1,_cMotBx,_cPortado,_cAgeDep,_cConta,_nVlRec,nVlrAjuste,_dDtRec, cHist, nOpc)
Local aRet			:= {.f.,""}
Local aBaixa		:=	{}
Local _aAreaAtu 	:= GetArea()
Local _cCodFil  	:= cFilAnt
Local _dDataBase	:= dDataBase
Local cMemo, cAutoLog

Default nVlrAjuste	:= 0
Default _nVlRec := 0
Default cHist := ""
Default nOpc := 3
/*--------------------------
	Soma multa no valor recebido
---------------------------*/
IF  nVlrAjuste > 0
	_nVlRec	:= _nVlRec+nVlrAjuste
ENDIF

DbSelectArea("SE1")   
SE1->(DbGoTo(_nRecnoE1))

If _nVlRec == 0
   _nVlRec :=  SE1->E1_SALDO
Endif
															
aAdd( aBaixa, { "E1_FILIAL" 	, SE1->E1_FILIAL						, Nil } )	// 01
aAdd( aBaixa, { "E1_PREFIXO" 	, SE1->E1_PREFIXO						, Nil } )	// 01
aAdd( aBaixa, { "E1_NUM"     	, SE1->E1_NUM		 					, Nil } )	// 02
aAdd( aBaixa, { "E1_PARCELA" 	, SE1->E1_PARCELA						, Nil } )	// 03
aAdd( aBaixa, { "E1_TIPO"    	, SE1->E1_TIPO							, Nil } )	// 04
aAdd( aBaixa, { "E1_CLIENTE"	, SE1->E1_CLIENTE						, Nil } )	// 05
aAdd( aBaixa, { "E1_LOJA"    	, SE1->E1_LOJA							, Nil } )	// 06
aAdd( aBaixa, { "AUTMOTBX"  	, _cMotBx								, Nil } )	// 07
aAdd( aBaixa, { "AUTBANCO"  	, _cPortado								, Nil } )	// 08
aAdd( aBaixa, { "AUTAGENCIA"	, PADR(_cAgeDep,TAMSX3("A6_AGENCIA")[1])								, Nil } )	// 09
aAdd( aBaixa, { "AUTCONTA"  	, PADR(_cConta,TAMSX3("A6_NUMCON")[1])								, Nil } )	// 10
aAdd( aBaixa, { "AUTDTBAIXA"	, _dDtRec			                	, Nil } )	// 11
aAdd( aBaixa, { "AUTDTCREDITO"	, _dDtRec              				    , Nil } )	// 11
aAdd( aBaixa, { "AUTHIST"   	,  cHist                              	, Nil } )	// 12
aAdd( aBaixa, { "AUTVALREC" 	, _nVlRec								, Nil } )	// 13

IF nVlrAjuste < 0
	aAdd( aBaixa, { "AUTDESCONT" 	, nVlrAjuste*-1								, Nil } )	// 13
ELSEIF nVlrAjuste > 0 
	aAdd( aBaixa, { "AUTMULTA"		, nVlrAjuste								, Nil } )	// 14
ENDIF
		  
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Posiciona na Filial para efetuar a baixa ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
_cCodFil	:= cFilAnt
dDataBase   := _dDtRec
cFilAnt		:= SE1->E1_FILIAL

lMSErroAuto := .F.
lMSHelpAuto := .T.
MSExecAuto({|x, y| Fina070(x, y)}, aBaixa,nOpc)  
cFilAnt := _cCodFil
dDataBase := _dDataBase
If 	lMsErroAuto
    
	//MostraErro()
	cAutoLog	:= alltrim(NOMEAUTOLOG())

	cMemo := STRTRAN(MemoRead(cAutoLog),'"',"")
	CONOUT("CP16BTIT | "+DTOC(date())+" "+TIME(), cMemo)
	cMemo := STRTRAN(cMemo,"'","")

	//| Apaga arquivo de Log
	Ferase(cAutoLog)

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Le Log da Execauto e retorna mensagem amigavel ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aRet[2] := U_CPXERRO(cMemo)

	IF EMPTY(aRet[2])
		aRet[2]	:= alltrim(cMemo)
	ENDIF	

ELSE
	
	aRet[1]	:= .t.
Endif

RestArea(_aAreaAtu)

Return(aRet)
