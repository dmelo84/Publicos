#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"

/* ===============================================================================
WSDL Location    http://ws.sandbox.bionexo.com.br/BionexoBean?wsdl
Gerado em        07/05/16 12:12:26
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _FOLAAAK ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service WSBionexoBeanService
------------------------------------------------------------------------------- */

WSCLIENT WSBionexoBeanService

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD post
	WSMETHOD request

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   clogin                    AS string
	WSDATA   cpassword                 AS string
	WSDATA   coperation                AS string
	WSDATA   cparameters               AS string
	WSDATA   cxml                      AS string
	WSDATA   creturn                   AS string

ENDWSCLIENT

WSMETHOD NEW WSCLIENT WSBionexoBeanService
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.131227A-20160318 NG] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT WSBionexoBeanService
Return

WSMETHOD RESET WSCLIENT WSBionexoBeanService
	::clogin             := NIL 
	::cpassword          := NIL 
	::coperation         := NIL 
	::cparameters        := NIL 
	::cxml               := NIL 
	::creturn            := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT WSBionexoBeanService
Local oClone := WSBionexoBeanService():New()
	oClone:_URL          := ::_URL 
	oClone:clogin        := ::clogin
	oClone:cpassword     := ::cpassword
	oClone:coperation    := ::coperation
	oClone:cparameters   := ::cparameters
	oClone:cxml          := ::cxml
	oClone:creturn       := ::creturn
Return oClone

// WSDL Method post of Service WSBionexoBeanService

WSMETHOD post WSSEND clogin,cpassword,coperation,cparameters,cxml WSRECEIVE creturn WSCLIENT WSBionexoBeanService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:post xmlns:q1="http://webservice.bionexo.com/">'
cSoap += WSSoapValue("login", ::clogin, clogin , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("password", ::cpassword, cpassword , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("operation", ::coperation, coperation , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("parameters", ::cparameters, cparameters , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("xml", ::cxml, cxml , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += "</q1:post>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"RPCX","http://webservice.bionexo.com/",,,; 
	"http://ws.sandbox.bionexo.com.br/bionexo-wsEAR-bionexo-wsn/BionexoBean")

::Init()
::creturn            :=  WSAdvValue( oXmlRet,"_RETURN","string",NIL,NIL,NIL,"S",NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method request of Service WSBionexoBeanService

WSMETHOD request WSSEND clogin,cpassword,coperation,cparameters WSRECEIVE creturn WSCLIENT WSBionexoBeanService
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:request xmlns:q1="http://webservice.bionexo.com/">'
cSoap += WSSoapValue("login", ::clogin, clogin , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("password", ::cpassword, cpassword , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("operation", ::coperation, coperation , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("parameters", ::cparameters, cparameters , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += "</q1:request>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"",; 
	"RPCX","http://webservice.bionexo.com/",,,; 
	"http://ws.sandbox.bionexo.com.br/bionexo-wsEAR-bionexo-wsn/BionexoBean")

::Init()
::creturn            :=  WSAdvValue( oXmlRet,"_RETURN","string",NIL,NIL,NIL,"S",NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.



