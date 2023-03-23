#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://54.232.247.42/alliar/integracao.php?wsdl
Gerado em        05/25/16 14:58:14
Observa��es      C�digo-Fonte gerado por ADVPL WSDL Client 1.120703
                 Altera��es neste arquivo podem causar funcionamento incorreto
                 e ser�o perdidas caso o c�digo-fonte seja gerado novamente.
=============================================================================== */

User Function _MMSDDKH ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSclinuxWS
------------------------------------------------------------------------------- */

WSCLIENT WSclinuxWS

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD LotexNotaFiscal

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   cxml                      AS string
	WSDATA   cLotexNotaFiscalResult    AS string

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSclinuxWS
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O C�digo-Fonte Client atual requer os execut�veis do Protheus Build [7.00.131227A-20160318 NG] ou superior. Atualize o Protheus ou gere o C�digo-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSclinuxWS
Return

WSMETHOD RESET WSCLIENT WSclinuxWS
	::cxml               := NIL 
	::cLotexNotaFiscalResult := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSclinuxWS
Local oClone := WSclinuxWS():New()
	oClone:_URL          := ::_URL 
	oClone:cxml          := ::cxml
	oClone:cLotexNotaFiscalResult := ::cLotexNotaFiscalResult
Return oClone

// WSDL Method LotexNotaFiscal of Service WSclinuxWS

WSMETHOD LotexNotaFiscal WSSEND cxml WSRECEIVE cLotexNotaFiscalResult WSCLIENT WSclinuxWS
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:LotexNotaFiscal xmlns:q1="http://www.w3.org/2001/XMLSchema">'
cSoap += WSSoapValue("xml", ::cxml, cxml , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += "</q1:LotexNotaFiscal>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"urn:clinuxWS#LotexNotaFiscal",; 
	"RPCX","urn:clinuxWS",,,; 
	"http://54.232.247.42/alliar/integracao.php")

::Init()
::cLotexNotaFiscalResult :=  WSAdvValue( oXmlRet,"_LOTEXNOTAFISCALRESULT","string",NIL,NIL,NIL,"S",NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.



