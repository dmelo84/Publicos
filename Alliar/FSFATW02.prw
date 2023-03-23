#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://187.1.82.118/wsIntegraFaturamento/wsIntegraFaturamento.asmx?WSDL
Gerado em        04/01/16 14:45:29
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _GKQNFDN ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSIntegraFaturamento
------------------------------------------------------------------------------- */

WSCLIENT WSIntegraFaturamento

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD LotexNotaFiscal

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   cRetornoNF                AS string
	WSDATA   oWSLotexNotaFiscalResult  AS IntegraFaturamento_Retorno

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSIntegraFaturamento
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.131227A-20160114 NG] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSIntegraFaturamento
	::oWSLotexNotaFiscalResult := IntegraFaturamento_RETORNO():New()
Return

WSMETHOD RESET WSCLIENT WSIntegraFaturamento
	::cRetornoNF         := NIL 
	::oWSLotexNotaFiscalResult := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSIntegraFaturamento
Local oClone := WSIntegraFaturamento():New()
	oClone:_URL          := ::_URL 
	oClone:cRetornoNF    := ::cRetornoNF
	oClone:oWSLotexNotaFiscalResult :=  IIF(::oWSLotexNotaFiscalResult = NIL , NIL ,::oWSLotexNotaFiscalResult:Clone() )
Return oClone

// WSDL Method LotexNotaFiscal of Service WSIntegraFaturamento

WSMETHOD LotexNotaFiscal WSSEND cRetornoNF WSRECEIVE oWSLotexNotaFiscalResult WSCLIENT WSIntegraFaturamento
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<LotexNotaFiscal xmlns="Pixeon.WebServices">'
cSoap += WSSoapValue("RetornoNF", ::cRetornoNF, cRetornoNF , "string", .F. , .F., 0 , NIL, .F.) 
cSoap += "</LotexNotaFiscal>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"Pixeon.WebServices/LotexNotaFiscal",; 
	"DOCUMENT","Pixeon.WebServices",,,; 
	"http://192.168.10.28/wsIntegraFaturamento/wsIntegraFaturamento.asmx")

::Init()
::oWSLotexNotaFiscalResult:SoapRecv( WSAdvValue( oXmlRet,"_LOTEXNOTAFISCALRESPONSE:_LOTEXNOTAFISCALRESULT","Retorno",NIL,NIL,NIL,NIL,NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure Retorno

WSSTRUCT IntegraFaturamento_Retorno
	WSDATA   nCodStatus                AS int
	WSDATA   cMsgErro                  AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT IntegraFaturamento_Retorno
	::Init()
Return Self

WSMETHOD INIT WSCLIENT IntegraFaturamento_Retorno
Return

WSMETHOD CLONE WSCLIENT IntegraFaturamento_Retorno
	Local oClone := IntegraFaturamento_Retorno():NEW()
	oClone:nCodStatus           := ::nCodStatus
	oClone:cMsgErro             := ::cMsgErro
Return oClone

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT IntegraFaturamento_Retorno
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::nCodStatus         :=  WSAdvValue( oResponse,"_CODSTATUS","int",NIL,"Property nCodStatus as s:int on SOAP Response not found.",NIL,"N",NIL,NIL) 
	::cMsgErro           :=  WSAdvValue( oResponse,"_MSGERRO","string",NIL,NIL,NIL,"S",NIL,NIL) 
Return


