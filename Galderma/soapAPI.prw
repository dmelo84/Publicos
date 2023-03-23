#include "protheus.ch"
#include "Totvs.ch"
#include "tbiconn.ch"
#INCLUDE "TOPCONN.CH"

#define enter chr(13) + chr(10)

User Function soapApi(clogin,cPsw,nomeDistr,cProtocol)

  Local oWsdl
  Local oXml
  Local xRet
  Local aSimple
  Local lOk
  Local aComplex
  Local cMsgSoap := ""
  Local cErros   := ""
  Local cAvisos  := ""
  Local aretCon  := {}
  Local oRetXml
  Local lEnvOk
  Local cRetMsg
  Local cRetRest
  Local cHtmlPage
  Local aOps
  Local n := 0
  Local oJson

  Default clogin    := "elfa-galderma"
  Default cPsw      := "vcup%Zmjx3jW7s6TWiudcZ1SMIeFAbZP"
  Default cProtocol := '202108116114190ec31e/8'
  Default nomeDistr := "Elfa"
   
   // Cria o objeto da classe TWsdlManager
   oWsdl := TWsdlManager():New()

   //oWsdl:cSSLCACertFile := "C:\Temp\cacert.pem"
   oWsdl:lSSLInsecure := .T.

  //Define o modo de trabalho como "VERBOSE"
  oWsdl:lVerbose := .T.  
  
  // Faz o parse de uma URL
  xRet := oWsdl:ParseURL( "https://soap.comprovei.com.br/exportQueue/v2/index.php?wsdl" )
  if xRet == .F.
    conout( "Erro: " + oWsdl:cError )
    Return
  endif

  // Lista as operações definidas. Passo opcional.
  aOps := oWsdl:ListOperations()
  if Len( aOps ) == 0
        conout( "Erro: " + oWsdl:cError )
        Return
  else
    varinfo( "Operações: ", aOps )
  endif

  // Lista os tipos complexos da mensagem de input envolvida na operação
  aComplex := oWsdl:ComplexInput()
  varinfo( "Complexos: ", aComplex )
  
  // Lista os tipos simples da mensagem de input envolvida na operação
  aSimple := oWsdl:SimpleInput()
  varinfo( "Simples: ", aSimple )

  // Define a operação
  xRet := oWsdl:SetOperation( "getExportProtocolStatus" )
  if xRet == .F.
    conout( "Erro: " + oWsdl:cError )
    Return
  else
    lOk  := oWsdl:GetAuthentication( clogin , cPsw  )
  endif

  /*/ Define o valor de cada parâmeto necessário
  xRet := oWsdl:SetValue( 0, cProtocol )
  if xRet == .F.
        conout( "Erro: " + oWsdl:cError )
        Return
  endif
  /*/

// Pega a mensagem SOAP que será enviada ao servidor
//cMsgSoap := oWsdl:GetSoapMsg()
 cMsgSoap +='<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" ' +enter
 cMsgSoap +='xmlns:web="WebServiceComprovei" ' +enter
 cMsgSoap +='xmlns:web1="WebServiceComprovei:getExportProtocolStatus"> '+enter
 cMsgSoap +='<soapenv:Header>'+enter
 cMsgSoap +='<web:Credenciais>'+enter
 cMsgSoap +='<web:Usuario>'+clogin+'</web:Usuario>'+enter
 cMsgSoap +='<web:Senha>'+cPsw+'</web:Senha>'+enter
 cMsgSoap +='</web:Credenciais>'+enter
 cMsgSoap +='</soapenv:Header>'+enter
 cMsgSoap +='<soapenv:Body>'+enter
 cMsgSoap +='<web1:getExportProtocolStatus>'+enter
 cMsgSoap +='<web1:protocolo>'+cProtocol+'</web1:protocolo>'+enter
 cMsgSoap +='</web1:getExportProtocolStatus>'+enter
 cMsgSoap +='</soapenv:Body>'+enter
 cMsgSoap +='</soapenv:Envelope>'

conout( cMsgSoap )
lEnvOk := oWsdl:SendSoapMsg(cMsgSoap)

//Se houve falha, exibe a mensagem
If ! lEnvOk
    Conout("Erro SendSoapMsg: " + oWsdl:cError)
endif

// Pega a mensagem de resposta
cRetMsg := oWsdl:GetSoapResponse()
conout(cRetMsg)

// Pega a mensagem de resposta parseada
oXml := xParseObj(cRetMsg)
if oXml:_soap_env_envelope:_soap_env_body:_ns1_getexportprotocolstatusresponse:_ns1_processado:text == 'Sim'
    conout("Documento já processado - Segue:")
else
    conout(oXml:_soap_env_envelope:_soap_env_body:_ns1_getexportprotocolstatusresponse:_ns1_status:text)
    return
endif
//Exibe o retorno
conout( oWsdl:GetParsedResponse(cRetMsg) )

//Abre conexão com o FLuig
aretCon := OtherConn()

//Busca o nó e retorna o link do rest
oRetXml := XmlGetChild(oxml:_soap_env_envelope:_soap_env_body:_ns1_getexportprotocolstatusresponse, 8)

//Processamento
If Valtype(oRetXml) = 'O'

    //Link da Requisição
    cRetRest := oRetXml:text 
    
    // Chama página passando parâmetros
    cHtmlPage := Httpget(cRetRest) //Executa o link
    varinfo("Reposta Link: ", cHtmlPage)
    //
    oXmlGet :=  XmlParser(cHtmlPage, "_", @cErros, @cAvisos) //Parse da resposta
    varinfo( "Parse Get: ", oXmlGet )
    //
    aXmlGet := oXmlGet:_documentos:_documento //Retorna array dos documentos
    if aretCon[1] //Banco FLuig conectado .T. se não .F.
        for n := 1 to len(aXmlGet)
        
        cChave := aXmlGet[n]:_chave:text
        oJson := reqRest(cChave)

        nCountRespData := len(oJson:response_data)
        nCountItem     := len(oJson:response_data[len(oJson:response_data)]:documento:itens)

        //Input do dados WS502
        cQry := "insert into COMPROVEI_WS502_OUTPUT(" +enter
        cQry += "WS502_DISTRIBUTOR,WS502_CHAVE,INPUT_DATE"+enter
        cQry += ")"+enter
        cQry += "values ('"+clogin+"','"+cChave+"','"+dtos(ddatabase)+"')"

        nStatus := TCSqlExec(cQry)

            if (nStatus < 0)
                conout("TCSQLError() " + TCSQLError())
                //Msginfo("TCSQLError() " + TCSQLError())
                Return .F.
            else
                conout("Insert: "+cQry)
            endif

        //Input dos dados WS204
        cQry := "insert into COMPROVEI_WS204_OUTPUT "
        cQry += "(" 
        cQry += "WS204_DISTRIBUTOR,"+enter
        cQry += "DOCUMENTO_NUMERONF,"+enter
        cQry += "DOCUMENTO_NUMEROPEDIDO,"+enter
        cQry += "DOCUMENTO_NOME,"+enter
        cQry += "DOCUMENTO_LOGRADOURO,"+enter
        cQry += "DOCUMENTO_BAIRRO,"+enter
        cQry += "DOCUMENTO_CIDADE," +enter
        cQry += "DOCUMENTO_ESTADO,"+enter 
        cQry += "DOCUMENTO_PRAZOSLA," +enter
        cQry += "DOCUMENTO_SLADIASUTEIS,"+enter
        cQry += "DOCUMENTO_DATAHORA,"+enter
        cQry += "DOCUMENTO_PREVISAO_ENTREGA,"+enter
        cQry += "DOCUMENTO_CODIGOSTATUS,"+enter
        cQry += "DOCUMENTO_STATUS,"+enter
        cQry += "DOCUMENTO_CODOCORRENCIA,"+enter
        cQry += "DOCUMENTO_DESCRICAOCORRENCIA,"+enter
        cQry += "DOCUMENTO_DATAROTA,"+enter
        cQry += "DOCUMENTO_LINKTRACKING)"+enter
        cQry += "values ('"+clogin+"',"+enter
        cQry += "'"+oJson:response_data[nCountRespData]:documento:numeronf+"',"+enter
        cQry += "'"+oJson:response_data[nCountRespData]:documento:numeropedido+"',"+enter
        cQry += "'"+oJson:response_data[nCountRespData]:documento:nome+"',"+enter
        cQry += "'"+strtran(oJson:response_data[nCountRespData]:documento:logradouro,","," ")+"',"+enter
        cQry += "'"+oJson:response_data[nCountRespData]:documento:bairro+"',"+enter
        cQry += "'"+oJson:response_data[nCountRespData]:documento:cidade+"',"+enter
        cQry += "'"+oJson:response_data[nCountRespData]:documento:estado+"',"+enter
        cQry += "'"+oJson:response_data[nCountRespData]:documento:prazosla+"',"+enter
        cQry += "'"+oJson:response_data[nCountRespData]:documento:sladiasuteis+"',"+enter
        cQry += "'"+oJson:response_data[nCountRespData]:documento:datahora+"',"+enter
        if valtype(oJson:response_data[nCountRespData]:documento:previsaoentrega) != 'U'
            cQry += "'"+oJson:response_data[nCountRespData]:documento:previsaoentrega+"',"+enter
        else
            cQry += "'',"+enter
        endif
        cQry += "'"+oJson:response_data[nCountRespData]:documento:codigostatus+"',"+enter
        cQry += "'"+oJson:response_data[nCountRespData]:documento:status+"',"+enter
        cQry += "'"+oJson:response_data[nCountRespData]:documento:codocorrencia+"',"+enter
        cQry += "'"+oJson:response_data[nCountRespData]:documento:descricaoocorrencia+"',"+enter
        if valtype(oJson:response_data[nCountRespData]:documento:datarota) != 'U'
            cQry += "'"+oJson:response_data[nCountRespData]:documento:datarota+"',"+enter
        else
            cQry += "'',"+enter
        endif
        cQry += "'"+oJson:response_data[nCountRespData]:documento:linktracking+"'"+enter
        cQry += ")"
        
        nStatus := TCSqlExec(cQry)

            if (nStatus < 0)
                conout("TCSQLError() " + TCSQLError())
                //Msginfo("TCSQLError() " + TCSQLError())
                Return .F.
            else
                conout("Insert: "+cQry)
            endif
        next 
    endif
endIf

// Fecha a conexão com o Fluig
  TcUnlink( aretCon[2] )
  conout( "Fluig desconectado" )
Return

/*##################################################################################
// Exemplo de função que alterna entre conexão de dados de ERP e conexão adicional
// com outro banco através do DBAccess. Deve ser executada a partir do Menu do ERP.
####################################################################################*/

static Function OtherConn()
  // Recupera handler da conexão atual com o DBAccess
  // Esta conexão foi feita pelo Framework do AdvPL, usando TCLink()

  //Local nHndERP := AdvConnection()
  Local cDBOra  := "MSSQL/Fluig"
  Local cSrvOra := "localhost"
  Local nHndOra := -1
  Local cQuery  := 'select * from PROCESS_OBSERVATION'
  Local lAberto
  Local lconOk := .T.
  Local nCount := 0

//Controle de abertura de ambiente   
    RpcClearEnv() //Se tiver aberto, fecha o ambiente
	RPCSetType(3)  //Nao consome licensas
	lAberto := RpcSetEnv("99","01",,,,GetEnvServer(),{ })
    nHndERP := AdvConnection() //So funciona com o ambiente aberto
//
  conout( "ERP conectado - Handler = " + str( nHndERP, 4 ) )
   
// Cria uma conexão com um outro banco, outro DBAcces
  nHndOra := TcLink( cDbOra, cSrvOra, 7890 )
  If nHndOra < 0
    UserException( "Falha ao conectar com " + cDbOra + " em " + cSrvOra )
    lconOk := .F.
  else
      nStatus := TCSqlExec(cQuery)
      if (nStatus < 0)
		conout("TCSQLError() " + TCSQLError())
		//Msginfo("TCSQLError() " + TCSQLError())
		Return .F.
      else
        TCQuery (cQuery) ALIAS cTable NEW

        while cTable->(!eof())
            nCount++
            cTable->(dbSkip())
        end
        if nCount > 0
            conout("Conexão teste com: "+cValtoChar(nCount)+" Registros")
        endif
	  endif
  Endif
   
  conout( "Fluig conectado - Handler = " + str( nHndOra, 4 ) )
  conout( "Banco = " + TcGetDB() )
/*   
  // Volta para conexão ERP
  tcSetConn( nHndERP )
  conout( "Banco = " + TcGetDB() )
      
  // Mostra a conexão ativa
  conout( "Banco = " + TcGetDB() )

  // Fecha a conexão com o Fluig
  TcUnlink( nHndOra )
  conout( "Fluig desconectado" )
*/
cTable->(dbCloseArea())
Return {lconOk,nHndOra}

/*##################################################################################
// Função de requisição Rest
// Diogo Melo.
####################################################################################*/

static function reqRest(cKey)

Local aHeadOut      := {}
Local cHttpHeader   := ""
Local cUrl          := "https://api.comprovei.com.br/api/1.1/documents/getStatus?key="+cKey
Local cHttpGet      := ""
Local cUser := "elfa-galderma"
Local cPsw  := "vcup%Zmjx3jW7s6TWiudcZ1SMIeFAbZP"
Local oJson 

//oJson := JsonObject():New()

aAdd( aHeadOut , "Authorization: Basic "+Encode64(cUser+":"+cPsw ) )
Aadd(aHeadOut, "Content-Type: application/json")

cHttpGet := HttpGet(cUrl,"",NIL,aHeadOut,@cHttpHeader)
//cHttpGet := oJson:FromJson(cHttpGet)
FwJSONDeserialize(cHttpGet, @oJSON) // DESERIALIZAÇÃO DE STRING PARA OBJETO

varinfo("Json: ",oJSON)
Return( oJSON )

/*##################################################################################
// Função de parse XML.
// Diogo Melo.
####################################################################################*/

static function xParseObj(cRetMsg)

Local cErros  := ""
Local cAvisos := ""
Local oXml

oXml :=  XmlParser(cRetMsg, "_", @cErros, @cAvisos)

Return oXml
