#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://54.207.126.178:7705/IntegracaoERPProtheusTotvs.svc?singleWsdl
Gerado em        05/25/16 11:29:43
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _WCNZHFP ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSIntegracaoERPProtheusTotvs
------------------------------------------------------------------------------- */

WSCLIENT WSIntegracaoERPProtheusTotvs

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD AtualizarDadosPedidoNota
	WSMETHOD IncluirRecebimentoPagamento
	WSMETHOD LotexNotaFiscal
	WSMETHOD Produto
	WSMETHOD BaixaSA

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   oWSentrada                AS IntegracaoERPProtheusTotvs_PedidoNotaIntegracaoProtheusTotvs
	WSDATA   oWSAtualizarDadosPedidoNotaResult AS IntegracaoERPProtheusTotvs_RetornoERPIntegracaoProtheusTotvs
	WSDATA   oWSIncluirRecebimentoPagamentoResult AS IntegracaoERPProtheusTotvs_RetornoERPIntegracaoProtheusTotvs
	WSDATA   cxml                      AS string
	WSDATA   cLotexNotaFiscalResult    AS string
	WSDATA   cProdutoResult            AS string
	WSDATA   cBaixaSAResult            AS string

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSIntegracaoERPProtheusTotvs
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.131227A-20160318 NG] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSIntegracaoERPProtheusTotvs
	::oWSentrada         := IntegracaoERPProtheusTotvs_PEDIDONOTAINTEGRACAOPROTHEUSTOTVS():New()
	::oWSAtualizarDadosPedidoNotaResult := IntegracaoERPProtheusTotvs_RETORNOERPINTEGRACAOPROTHEUSTOTVS():New()
	::oWSIncluirRecebimentoPagamentoResult := IntegracaoERPProtheusTotvs_RETORNOERPINTEGRACAOPROTHEUSTOTVS():New()
Return

WSMETHOD RESET WSCLIENT WSIntegracaoERPProtheusTotvs
	::oWSentrada         := NIL 
	::oWSAtualizarDadosPedidoNotaResult := NIL 
	::oWSIncluirRecebimentoPagamentoResult := NIL 
	::cxml               := NIL 
	::cLotexNotaFiscalResult := NIL 
	::cProdutoResult     := NIL 
	::cBaixaSAResult     := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSIntegracaoERPProtheusTotvs
Local oClone := WSIntegracaoERPProtheusTotvs():New()
	oClone:_URL          := ::_URL 
	oClone:oWSentrada    :=  IIF(::oWSentrada = NIL , NIL ,::oWSentrada:Clone() )
	oClone:oWSAtualizarDadosPedidoNotaResult :=  IIF(::oWSAtualizarDadosPedidoNotaResult = NIL , NIL ,::oWSAtualizarDadosPedidoNotaResult:Clone() )
	oClone:oWSIncluirRecebimentoPagamentoResult :=  IIF(::oWSIncluirRecebimentoPagamentoResult = NIL , NIL ,::oWSIncluirRecebimentoPagamentoResult:Clone() )
	oClone:cxml          := ::cxml
	oClone:cLotexNotaFiscalResult := ::cLotexNotaFiscalResult
	oClone:cProdutoResult := ::cProdutoResult
	oClone:cBaixaSAResult := ::cBaixaSAResult
Return oClone

// WSDL Method AtualizarDadosPedidoNota of Service WSIntegracaoERPProtheusTotvs

WSMETHOD AtualizarDadosPedidoNota WSSEND oWSentrada WSRECEIVE oWSAtualizarDadosPedidoNotaResult WSCLIENT WSIntegracaoERPProtheusTotvs
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<AtualizarDadosPedidoNota xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("entrada", ::oWSentrada, oWSentrada , "PedidoNotaIntegracaoProtheusTotvs", .F. , .F., 0 , NIL, .F.) 
cSoap += "</AtualizarDadosPedidoNota>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://tempuri.org/IIntegracaoERPProtheusTotvs/AtualizarDadosPedidoNota",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"http://54.207.126.178:7705/IntegracaoERPProtheusTotvs.svc")

::Init()
::oWSAtualizarDadosPedidoNotaResult:SoapRecv( WSAdvValue( oXmlRet,"_ATUALIZARDADOSPEDIDONOTARESPONSE:_ATUALIZARDADOSPEDIDONOTARESULT","RetornoERPIntegracaoProtheusTotvs",NIL,NIL,NIL,NIL,NIL,"xs") )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method IncluirRecebimentoPagamento of Service WSIntegracaoERPProtheusTotvs

WSMETHOD IncluirRecebimentoPagamento WSSEND oWSentrada WSRECEIVE oWSIncluirRecebimentoPagamentoResult WSCLIENT WSIntegracaoERPProtheusTotvs
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<IncluirRecebimentoPagamento xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("entrada", ::oWSentrada, oWSentrada , "RecebimentoPagamentoIntegracaoProtheusTotvs", .F. , .F., 0 , NIL, .F.) 
cSoap += "</IncluirRecebimentoPagamento>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://tempuri.org/IIntegracaoERPProtheusTotvs/IncluirRecebimentoPagamento",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"http://54.207.126.178:7705/IntegracaoERPProtheusTotvs.svc")

::Init()
::oWSIncluirRecebimentoPagamentoResult:SoapRecv( WSAdvValue( oXmlRet,"_INCLUIRRECEBIMENTOPAGAMENTORESPONSE:_INCLUIRRECEBIMENTOPAGAMENTORESULT","RetornoERPIntegracaoProtheusTotvs",NIL,NIL,NIL,NIL,NIL,"xs") )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method LotexNotaFiscal of Service WSIntegracaoERPProtheusTotvs

WSMETHOD LotexNotaFiscal WSSEND cxml WSRECEIVE cLotexNotaFiscalResult WSCLIENT WSIntegracaoERPProtheusTotvs
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<LotexNotaFiscal xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("xml", ::cxml, cxml , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</LotexNotaFiscal>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://tempuri.org/IIntegracaoERPProtheusTotvs/LotexNotaFiscal",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"http://54.207.126.178:7705/IntegracaoERPProtheusTotvs.svc")

::Init()
::cLotexNotaFiscalResult :=  WSAdvValue( oXmlRet,"_LOTEXNOTAFISCALRESPONSE:_LOTEXNOTAFISCALRESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,"xs") 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method Produto of Service WSIntegracaoERPProtheusTotvs

WSMETHOD Produto WSSEND cxml WSRECEIVE cProdutoResult WSCLIENT WSIntegracaoERPProtheusTotvs
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<Produto xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("xml", ::cxml, cxml , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</Produto>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://tempuri.org/IIntegracaoERPProtheusTotvs/Produto",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"http://54.207.126.178:7705/IntegracaoERPProtheusTotvs.svc")

::Init()
::cProdutoResult     :=  WSAdvValue( oXmlRet,"_PRODUTORESPONSE:_PRODUTORESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,"xs") 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method BaixaSA of Service WSIntegracaoERPProtheusTotvs

WSMETHOD BaixaSA WSSEND cxml WSRECEIVE cBaixaSAResult WSCLIENT WSIntegracaoERPProtheusTotvs
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<BaixaSA xmlns="http://tempuri.org/">'
cSoap += WSSoapValue("xml", ::cxml, cxml , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</BaixaSA>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"http://tempuri.org/IIntegracaoERPProtheusTotvs/BaixaSA",; 
	"DOCUMENT","http://tempuri.org/",,,; 
	"http://54.207.126.178:7705/IntegracaoERPProtheusTotvs.svc")

::Init()
::cBaixaSAResult     :=  WSAdvValue( oXmlRet,"_BAIXASARESPONSE:_BAIXASARESULT:TEXT","string",NIL,NIL,NIL,NIL,NIL,"xs") 

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure PedidoNotaIntegracaoProtheusTotvs

WSSTRUCT IntegracaoERPProtheusTotvs_PedidoNotaIntegracaoProtheusTotvs
	WSDATA   cDominio                  AS string OPTIONAL
	WSDATA   cLogin                    AS string OPTIONAL
	WSDATA   cNotaFiscal               AS string OPTIONAL
	WSDATA   nNumeroPedidoNota         AS int OPTIONAL
	WSDATA   cRps                      AS string OPTIONAL
	WSDATA   cSenha                    AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT IntegracaoERPProtheusTotvs_PedidoNotaIntegracaoProtheusTotvs
	::Init()
Return Self

WSMETHOD INIT WSCLIENT IntegracaoERPProtheusTotvs_PedidoNotaIntegracaoProtheusTotvs
Return

WSMETHOD CLONE WSCLIENT IntegracaoERPProtheusTotvs_PedidoNotaIntegracaoProtheusTotvs
	Local oClone := IntegracaoERPProtheusTotvs_PedidoNotaIntegracaoProtheusTotvs():NEW()
	oClone:cDominio             := ::cDominio
	oClone:cLogin               := ::cLogin
	oClone:cNotaFiscal          := ::cNotaFiscal
	oClone:nNumeroPedidoNota    := ::nNumeroPedidoNota
	oClone:cRps                 := ::cRps
	oClone:cSenha               := ::cSenha
Return oClone

WSMETHOD SOAPSEND WSCLIENT IntegracaoERPProtheusTotvs_PedidoNotaIntegracaoProtheusTotvs
	Local cSoap := ""
	cSoap += WSSoapValue("Dominio", ::cDominio, ::cDominio , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("Login", ::cLogin, ::cLogin , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("NotaFiscal", ::cNotaFiscal, ::cNotaFiscal , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("NumeroPedidoNota", ::nNumeroPedidoNota, ::nNumeroPedidoNota , "int", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("Rps", ::cRps, ::cRps , "string", .F. , .F., 0 , NIL, .F.) 
	cSoap += WSSoapValue("Senha", ::cSenha, ::cSenha , "string", .F. , .F., 0 , NIL, .F.) 
Return cSoap

// WSDL Data Structure RetornoERPIntegracaoProtheusTotvs

WSSTRUCT IntegracaoERPProtheusTotvs_RetornoERPIntegracaoProtheusTotvs
	WSDATA   nCodStatus                AS int OPTIONAL
	WSDATA   cMsgErro                  AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT IntegracaoERPProtheusTotvs_RetornoERPIntegracaoProtheusTotvs
	::Init()
Return Self

WSMETHOD INIT WSCLIENT IntegracaoERPProtheusTotvs_RetornoERPIntegracaoProtheusTotvs
Return

WSMETHOD CLONE WSCLIENT IntegracaoERPProtheusTotvs_RetornoERPIntegracaoProtheusTotvs
	Local oClone := IntegracaoERPProtheusTotvs_RetornoERPIntegracaoProtheusTotvs():NEW()
	oClone:nCodStatus           := ::nCodStatus
	oClone:cMsgErro             := ::cMsgErro
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT IntegracaoERPProtheusTotvs_RetornoERPIntegracaoProtheusTotvs
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::nCodStatus         :=  WSAdvValue( oResponse,"_CODSTATUS","int",NIL,NIL,NIL,"N",NIL,"xs") 
	::cMsgErro           :=  WSAdvValue( oResponse,"_MSGERRO","string",NIL,NIL,NIL,"S",NIL,"xs") 
Return
