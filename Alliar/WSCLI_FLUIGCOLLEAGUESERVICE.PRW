#INCLUDE "PROTHEUS.CH"
#INCLUDE "APWEBSRV.CH"


/* ===============================================================================
WSDL Location    http://alliar.fluig.com/webdesk/ECMColleagueService?wsdl
WSDL Location    http://alliartst.fluig.com:8080/webdesk/ECMColleagueService?wsdl
Gerado em        12/12/17 11:43:13
Observações      Código-Fonte gerado por ADVPL WSDL Client 1.120703
                 Alterações neste arquivo podem causar funcionamento incorreto
                 e serão perdidas caso o código-fonte seja gerado novamente.
=============================================================================== */

User Function _VSCKFEC ; Return  // "dummy" function - Internal Use 

/* -------------------------------------------------------------------------------
WSDL Service UWSECMCOLLEAGUESERVICESERVICE
------------------------------------------------------------------------------- */

WSCLIENT UWSECMCOLLEAGUESERVICESERVICE

	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD RESET
	WSMETHOD CLONE
	WSMETHOD getColleaguesMail
	WSMETHOD removeColleague
	WSMETHOD getSummaryColleagues
	WSMETHOD validateColleagueLogin
	WSMETHOD activateColleague
	WSMETHOD getSimpleColleague
	WSMETHOD getGroups
	WSMETHOD createColleague
	WSMETHOD updateColleague
	WSMETHOD createColleaguewithDependencies
	WSMETHOD getColleagueByLogin
	WSMETHOD getColleaguesCompressedData
	WSMETHOD getColleagues
	WSMETHOD updateColleaguewithDependencies
	WSMETHOD createColleagueWithMap
	WSMETHOD getColleague

	WSDATA   _URL                      AS String
	WSDATA   _HEADOUT                  AS Array of String
	WSDATA   _COOKIES                  AS Array of String
	WSDATA   cusername                 AS string
	WSDATA   cpassword                 AS string
	WSDATA   ncompanyId                AS int
	WSDATA   cmail                     AS string
	WSDATA   oWSgetColleaguesMailresult AS UECMColleagueServiceService_colleagueDtoArray
	WSDATA   ccolleagueId              AS string
	WSDATA   cresult                   AS string
	WSDATA   oWSgetSummaryColleaguesresult AS UECMColleagueServiceService_colleagueDtoArray
	WSDATA   oWSgetSimpleColleagueresult AS UECMColleagueServiceService_colleagueDto
	WSDATA   oWSgetGroupscolab         AS UECMColleagueServiceService_groupDtoArray
	WSDATA   oWScreateColleaguecolleagues AS UECMColleagueServiceService_colleagueDtoArray
	WSDATA   cresultXML                AS string
	WSDATA   oWSupdateColleaguecolleagues AS UECMColleagueServiceService_colleagueDtoArray
	WSDATA   oWScreateColleaguewithDependenciescolleagues AS UECMColleagueServiceService_colleagueDtoArray
	WSDATA   oWScreateColleaguewithDependenciesgroups AS UECMColleagueServiceService_groupDtoArray
	WSDATA   oWScreateColleaguewithDependenciesworkflowRoles AS UECMColleagueServiceService_workflowRoleDtoArray
	WSDATA   oWSgetColleagueByLogincolleagueId AS UECMColleagueServiceService_colleagueDto
	WSDATA   oWSgetColleaguesresult    AS UECMColleagueServiceService_colleagueDtoArray
	WSDATA   oWSupdateColleaguewithDependenciescolleagues AS UECMColleagueServiceService_colleagueDtoArray
	WSDATA   oWSupdateColleaguewithDependenciesgroups AS UECMColleagueServiceService_groupDtoArray
	WSDATA   oWSupdateColleaguewithDependenciesworkflowRoles AS UECMColleagueServiceService_workflowRoleDtoArray
	WSDATA   ccolleagueXML             AS string
	WSDATA   oWSgetColleaguecolab      AS UECMColleagueServiceService_colleagueDtoArray

ENDWSCLIENT

WSMETHOD NEW WSCLIENT UWSECMCOLLEAGUESERVICESERVICE
::Init()
If !FindFunction("XMLCHILDEX")
	UserException("O Código-Fonte Client atual requer os executáveis do Protheus Build [7.00.131227A-20160510 NG] ou superior. Atualize o Protheus ou gere o Código-Fonte novamente utilizando o Build atual.")
EndIf
Return Self

WSMETHOD INIT WSCLIENT UWSECMCOLLEAGUESERVICESERVICE
	::oWSgetColleaguesMailresult := UECMColleagueServiceService_COLLEAGUEDTOARRAY():New()
	::oWSgetSummaryColleaguesresult := UECMColleagueServiceService_COLLEAGUEDTOARRAY():New()
	::oWSgetSimpleColleagueresult := UECMColleagueServiceService_COLLEAGUEDTO():New()
	::oWSgetGroupscolab  := UECMColleagueServiceService_GROUPDTOARRAY():New()
	::oWScreateColleaguecolleagues := UECMColleagueServiceService_COLLEAGUEDTOARRAY():New()
	::oWSupdateColleaguecolleagues := UECMColleagueServiceService_COLLEAGUEDTOARRAY():New()
	::oWScreateColleaguewithDependenciescolleagues := UECMColleagueServiceService_COLLEAGUEDTOARRAY():New()
	::oWScreateColleaguewithDependenciesgroups := UECMColleagueServiceService_GROUPDTOARRAY():New()
	::oWScreateColleaguewithDependenciesworkflowRoles := UECMColleagueServiceService_WORKFLOWROLEDTOARRAY():New()
	::oWSgetColleagueByLogincolleagueId := UECMColleagueServiceService_COLLEAGUEDTO():New()
	::oWSgetColleaguesresult := UECMColleagueServiceService_COLLEAGUEDTOARRAY():New()
	::oWSupdateColleaguewithDependenciescolleagues := UECMColleagueServiceService_COLLEAGUEDTOARRAY():New()
	::oWSupdateColleaguewithDependenciesgroups := UECMColleagueServiceService_GROUPDTOARRAY():New()
	::oWSupdateColleaguewithDependenciesworkflowRoles := UECMColleagueServiceService_WORKFLOWROLEDTOARRAY():New()
	::oWSgetColleaguecolab := UECMColleagueServiceService_COLLEAGUEDTOARRAY():New()
Return

WSMETHOD RESET WSCLIENT UWSECMCOLLEAGUESERVICESERVICE
	::cusername          := NIL 
	::cpassword          := NIL 
	::ncompanyId         := NIL 
	::cmail              := NIL 
	::oWSgetColleaguesMailresult := NIL 
	::ccolleagueId       := NIL 
	::cresult            := NIL 
	::oWSgetSummaryColleaguesresult := NIL 
	::oWSgetSimpleColleagueresult := NIL 
	::oWSgetGroupscolab  := NIL 
	::oWScreateColleaguecolleagues := NIL 
	::cresultXML         := NIL 
	::oWSupdateColleaguecolleagues := NIL 
	::oWScreateColleaguewithDependenciescolleagues := NIL 
	::oWScreateColleaguewithDependenciesgroups := NIL 
	::oWScreateColleaguewithDependenciesworkflowRoles := NIL 
	::oWSgetColleagueByLogincolleagueId := NIL 
	::oWSgetColleaguesresult := NIL 
	::oWSupdateColleaguewithDependenciescolleagues := NIL 
	::oWSupdateColleaguewithDependenciesgroups := NIL 
	::oWSupdateColleaguewithDependenciesworkflowRoles := NIL 
	::ccolleagueXML      := NIL 
	::oWSgetColleaguecolab := NIL 
	::Init()
Return

WSMETHOD CLONE WSCLIENT UWSECMCOLLEAGUESERVICESERVICE
Local oClone := UWSECMCOLLEAGUESERVICESERVICE():New()
	oClone:_URL          := ::_URL 
	oClone:cusername     := ::cusername
	oClone:cpassword     := ::cpassword
	oClone:ncompanyId    := ::ncompanyId
	oClone:cmail         := ::cmail
	oClone:oWSgetColleaguesMailresult :=  IIF(::oWSgetColleaguesMailresult = NIL , NIL ,::oWSgetColleaguesMailresult:Clone() )
	oClone:ccolleagueId  := ::ccolleagueId
	oClone:cresult       := ::cresult
	oClone:oWSgetSummaryColleaguesresult :=  IIF(::oWSgetSummaryColleaguesresult = NIL , NIL ,::oWSgetSummaryColleaguesresult:Clone() )
	oClone:oWSgetSimpleColleagueresult :=  IIF(::oWSgetSimpleColleagueresult = NIL , NIL ,::oWSgetSimpleColleagueresult:Clone() )
	oClone:oWSgetGroupscolab :=  IIF(::oWSgetGroupscolab = NIL , NIL ,::oWSgetGroupscolab:Clone() )
	oClone:oWScreateColleaguecolleagues :=  IIF(::oWScreateColleaguecolleagues = NIL , NIL ,::oWScreateColleaguecolleagues:Clone() )
	oClone:cresultXML    := ::cresultXML
	oClone:oWSupdateColleaguecolleagues :=  IIF(::oWSupdateColleaguecolleagues = NIL , NIL ,::oWSupdateColleaguecolleagues:Clone() )
	oClone:oWScreateColleaguewithDependenciescolleagues :=  IIF(::oWScreateColleaguewithDependenciescolleagues = NIL , NIL ,::oWScreateColleaguewithDependenciescolleagues:Clone() )
	oClone:oWScreateColleaguewithDependenciesgroups :=  IIF(::oWScreateColleaguewithDependenciesgroups = NIL , NIL ,::oWScreateColleaguewithDependenciesgroups:Clone() )
	oClone:oWScreateColleaguewithDependenciesworkflowRoles :=  IIF(::oWScreateColleaguewithDependenciesworkflowRoles = NIL , NIL ,::oWScreateColleaguewithDependenciesworkflowRoles:Clone() )
	oClone:oWSgetColleagueByLogincolleagueId :=  IIF(::oWSgetColleagueByLogincolleagueId = NIL , NIL ,::oWSgetColleagueByLogincolleagueId:Clone() )
	oClone:oWSgetColleaguesresult :=  IIF(::oWSgetColleaguesresult = NIL , NIL ,::oWSgetColleaguesresult:Clone() )
	oClone:oWSupdateColleaguewithDependenciescolleagues :=  IIF(::oWSupdateColleaguewithDependenciescolleagues = NIL , NIL ,::oWSupdateColleaguewithDependenciescolleagues:Clone() )
	oClone:oWSupdateColleaguewithDependenciesgroups :=  IIF(::oWSupdateColleaguewithDependenciesgroups = NIL , NIL ,::oWSupdateColleaguewithDependenciesgroups:Clone() )
	oClone:oWSupdateColleaguewithDependenciesworkflowRoles :=  IIF(::oWSupdateColleaguewithDependenciesworkflowRoles = NIL , NIL ,::oWSupdateColleaguewithDependenciesworkflowRoles:Clone() )
	oClone:ccolleagueXML := ::ccolleagueXML
	oClone:oWSgetColleaguecolab :=  IIF(::oWSgetColleaguecolab = NIL , NIL ,::oWSgetColleaguecolab:Clone() )
Return oClone

// WSDL Method getColleaguesMail of Service UWSECMCOLLEAGUESERVICESERVICE

WSMETHOD getColleaguesMail WSSEND cusername,cpassword,ncompanyId,cmail WSRECEIVE oWSgetColleaguesMailresult WSCLIENT UWSECMCOLLEAGUESERVICESERVICE
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:getColleaguesMail xmlns:q1="http://ws.foundation.ecm.technology.totvs.com/">'
cSoap += WSSoapValue("username", ::cusername, cusername , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("password", ::cpassword, cpassword , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("companyId", ::ncompanyId, ncompanyId , "int", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("mail", ::cmail, cmail , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += "</q1:getColleaguesMail>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"getColleaguesMail",; 
	"RPCX","http://ws.foundation.ecm.technology.totvs.com/",,,; 
	"http://alliar.fluig.com/webdesk/ECMColleagueService")

::Init()
::oWSgetColleaguesMailresult:SoapRecv( WSAdvValue( oXmlRet,"_RESULT","colleagueDtoArray",NIL,NIL,NIL,"O",NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method removeColleague of Service UWSECMCOLLEAGUESERVICESERVICE

WSMETHOD removeColleague WSSEND cusername,cpassword,ncompanyId,ccolleagueId WSRECEIVE cresult WSCLIENT UWSECMCOLLEAGUESERVICESERVICE
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:removeColleague xmlns:q1="http://ws.foundation.ecm.technology.totvs.com/">'
cSoap += WSSoapValue("username", ::cusername, cusername , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("password", ::cpassword, cpassword , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("companyId", ::ncompanyId, ncompanyId , "int", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("colleagueId", ::ccolleagueId, ccolleagueId , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += "</q1:removeColleague>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"removeColleague",; 
	"RPCX","http://ws.foundation.ecm.technology.totvs.com/",,,; 
	"http://alliar.fluig.com/webdesk/ECMColleagueService")

::Init()
::cresult            :=  WSAdvValue( oXmlRet,"_RESULT","string",NIL,NIL,NIL,"S",NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method getSummaryColleagues of Service UWSECMCOLLEAGUESERVICESERVICE

WSMETHOD getSummaryColleagues WSSEND ncompanyId WSRECEIVE oWSgetSummaryColleaguesresult WSCLIENT UWSECMCOLLEAGUESERVICESERVICE
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:getSummaryColleagues xmlns:q1="http://www.w3.org/2001/XMLSchema">'
cSoap += WSSoapValue("companyId", ::ncompanyId, ncompanyId , "int", .T. , .T. , 0 , NIL, .F.) 
cSoap += "</q1:getSummaryColleagues>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"getSummaryColleagues",; 
	"RPCX","http://ws.foundation.ecm.technology.totvs.com/",,,; 
	"http://alliar.fluig.com/webdesk/ECMColleagueService")

::Init()
::oWSgetSummaryColleaguesresult:SoapRecv( WSAdvValue( oXmlRet,"_RESULT","colleagueDtoArray",NIL,NIL,NIL,"O",NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method validateColleagueLogin of Service UWSECMCOLLEAGUESERVICESERVICE

WSMETHOD validateColleagueLogin WSSEND ncompanyId,ccolleagueId,cpassword WSRECEIVE cresult WSCLIENT UWSECMCOLLEAGUESERVICESERVICE
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:validateColleagueLogin xmlns:q1="http://ws.foundation.ecm.technology.totvs.com/">'
cSoap += WSSoapValue("companyId", ::ncompanyId, ncompanyId , "int", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("colleagueId", ::ccolleagueId, ccolleagueId , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("password", ::cpassword, cpassword , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += "</q1:validateColleagueLogin>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"validateColleagueLogin",; 
	"RPCX","http://ws.foundation.ecm.technology.totvs.com/",,,; 
	"http://alliar.fluig.com/webdesk/ECMColleagueService")

::Init()
::cresult            :=  WSAdvValue( oXmlRet,"_RESULT","string",NIL,NIL,NIL,"S",NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method activateColleague of Service UWSECMCOLLEAGUESERVICESERVICE

WSMETHOD activateColleague WSSEND cusername,cpassword,ncompanyId,ccolleagueId WSRECEIVE cresult WSCLIENT UWSECMCOLLEAGUESERVICESERVICE
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:activateColleague xmlns:q1="http://ws.foundation.ecm.technology.totvs.com/">'
cSoap += WSSoapValue("username", ::cusername, cusername , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("password", ::cpassword, cpassword , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("companyId", ::ncompanyId, ncompanyId , "int", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("colleagueId", ::ccolleagueId, ccolleagueId , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += "</q1:activateColleague>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"activateColleague",; 
	"RPCX","http://ws.foundation.ecm.technology.totvs.com/",,,; 
	"http://alliar.fluig.com/webdesk/ECMColleagueService")

::Init()
::cresult            :=  WSAdvValue( oXmlRet,"_RESULT","string",NIL,NIL,NIL,"S",NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method getSimpleColleague of Service UWSECMCOLLEAGUESERVICESERVICE

WSMETHOD getSimpleColleague WSSEND cusername,cpassword WSRECEIVE oWSgetSimpleColleagueresult WSCLIENT UWSECMCOLLEAGUESERVICESERVICE
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:getSimpleColleague xmlns:q1="http://ws.foundation.ecm.technology.totvs.com/">'
cSoap += WSSoapValue("username", ::cusername, cusername , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("password", ::cpassword, cpassword , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += "</q1:getSimpleColleague>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"getColleague",; 
	"RPCX","http://ws.foundation.ecm.technology.totvs.com/",,,; 
	"http://alliar.fluig.com/webdesk/ECMColleagueService")

::Init()
::oWSgetSimpleColleagueresult:SoapRecv( WSAdvValue( oXmlRet,"_RESULT","colleagueDto",NIL,NIL,NIL,"O",NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method getGroups of Service UWSECMCOLLEAGUESERVICESERVICE

WSMETHOD getGroups WSSEND cusername,cpassword,ncompanyId,ccolleagueId WSRECEIVE oWSgetGroupscolab WSCLIENT UWSECMCOLLEAGUESERVICESERVICE
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:getGroups xmlns:q1="http://ws.foundation.ecm.technology.totvs.com/">'
cSoap += WSSoapValue("username", ::cusername, cusername , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("password", ::cpassword, cpassword , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("companyId", ::ncompanyId, ncompanyId , "int", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("colleagueId", ::ccolleagueId, ccolleagueId , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += "</q1:getGroups>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"get Groups",; 
	"RPCX","http://ws.foundation.ecm.technology.totvs.com/",,,; 
	"http://alliar.fluig.com/webdesk/ECMColleagueService")

::Init()
::oWSgetGroupscolab:SoapRecv( WSAdvValue( oXmlRet,"_COLAB","groupDtoArray",NIL,NIL,NIL,"O",NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method createColleague of Service UWSECMCOLLEAGUESERVICESERVICE

WSMETHOD createColleague WSSEND cusername,cpassword,ncompanyId,oWScreateColleaguecolleagues WSRECEIVE cresultXML WSCLIENT UWSECMCOLLEAGUESERVICESERVICE
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:createColleague xmlns:q1="http://ws.foundation.ecm.technology.totvs.com/">'
cSoap += WSSoapValue("username", ::cusername, cusername , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("password", ::cpassword, cpassword , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("companyId", ::ncompanyId, ncompanyId , "int", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("colleagues", ::oWScreateColleaguecolleagues, oWScreateColleaguecolleagues , "colleagueDtoArray", .T. , .T. , 0 , NIL, .F.) 
cSoap += "</q1:createColleague>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"createCollegue",; 
	"RPCX","http://ws.foundation.ecm.technology.totvs.com/",,,; 
	"http://alliar.fluig.com/webdesk/ECMColleagueService")

::Init()
::cresultXML         :=  WSAdvValue( oXmlRet,"_RESULTXML","string",NIL,NIL,NIL,"S",NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method updateColleague of Service UWSECMCOLLEAGUESERVICESERVICE

WSMETHOD updateColleague WSSEND cusername,cpassword,ncompanyId,oWSupdateColleaguecolleagues WSRECEIVE cresultXML WSCLIENT UWSECMCOLLEAGUESERVICESERVICE
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:updateColleague xmlns:q1="http://ws.foundation.ecm.technology.totvs.com/">'
cSoap += WSSoapValue("username", ::cusername, cusername , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("password", ::cpassword, cpassword , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("companyId", ::ncompanyId, ncompanyId , "int", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("colleagues", ::oWSupdateColleaguecolleagues, oWSupdateColleaguecolleagues , "colleagueDtoArray", .T. , .T. , 0 , NIL, .F.) 
cSoap += "</q1:updateColleague>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"updateColleague",; 
	"RPCX","http://ws.foundation.ecm.technology.totvs.com/",,,; 
	"http://alliar.fluig.com/webdesk/ECMColleagueService")

::Init()
::cresultXML         :=  WSAdvValue( oXmlRet,"_RESULTXML","string",NIL,NIL,NIL,"S",NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method createColleaguewithDependencies of Service UWSECMCOLLEAGUESERVICESERVICE

WSMETHOD createColleaguewithDependencies WSSEND cusername,cpassword,ncompanyId,oWScreateColleaguewithDependenciescolleagues,oWScreateColleaguewithDependenciesgroups,oWScreateColleaguewithDependenciesworkflowRoles WSRECEIVE cresultXML WSCLIENT UWSECMCOLLEAGUESERVICESERVICE
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:createColleaguewithDependencies xmlns:q1="http://ws.foundation.ecm.technology.totvs.com/">'
cSoap += WSSoapValue("username", ::cusername, cusername , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("password", ::cpassword, cpassword , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("companyId", ::ncompanyId, ncompanyId , "int", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("colleagues", ::oWScreateColleaguewithDependenciescolleagues, oWScreateColleaguewithDependenciescolleagues , "colleagueDtoArray", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("groups", ::oWScreateColleaguewithDependenciesgroups, oWScreateColleaguewithDependenciesgroups , "groupDtoArray", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("workflowRoles", ::oWScreateColleaguewithDependenciesworkflowRoles, oWScreateColleaguewithDependenciesworkflowRoles , "workflowRoleDtoArray", .T. , .T. , 0 , NIL, .F.) 
cSoap += "</q1:createColleaguewithDependencies>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"createColleaguewithDependencies",; 
	"RPCX","http://ws.foundation.ecm.technology.totvs.com/",,,; 
	"http://alliar.fluig.com/webdesk/ECMColleagueService")

::Init()
::cresultXML         :=  WSAdvValue( oXmlRet,"_RESULTXML","string",NIL,NIL,NIL,"S",NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method getColleagueByLogin of Service UWSECMCOLLEAGUESERVICESERVICE

WSMETHOD getColleagueByLogin WSSEND cusername,cpassword WSRECEIVE oWSgetColleagueByLogincolleagueId WSCLIENT UWSECMCOLLEAGUESERVICESERVICE
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:getColleagueByLogin xmlns:q1="http://ws.foundation.ecm.technology.totvs.com/">'
cSoap += WSSoapValue("username", ::cusername, cusername , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("password", ::cpassword, cpassword , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += "</q1:getColleagueByLogin>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"getColleagueByLogin",; 
	"RPCX","http://ws.foundation.ecm.technology.totvs.com/",,,; 
	"http://alliar.fluig.com/webdesk/ECMColleagueService")

::Init()
::oWSgetColleagueByLogincolleagueId:SoapRecv( WSAdvValue( oXmlRet,"_COLLEAGUEID","colleagueDto",NIL,NIL,NIL,"O",NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method getColleaguesCompressedData of Service UWSECMCOLLEAGUESERVICESERVICE

WSMETHOD getColleaguesCompressedData WSSEND cusername,cpassword,ncompanyId WSRECEIVE cresult WSCLIENT UWSECMCOLLEAGUESERVICESERVICE
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:getColleaguesCompressedData xmlns:q1="http://ws.foundation.ecm.technology.totvs.com/">'
cSoap += WSSoapValue("username", ::cusername, cusername , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("password", ::cpassword, cpassword , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("companyId", ::ncompanyId, ncompanyId , "int", .T. , .T. , 0 , NIL, .F.) 
cSoap += "</q1:getColleaguesCompressedData>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"getColleaguesCompressedData",; 
	"RPCX","http://ws.foundation.ecm.technology.totvs.com/",,,; 
	"http://alliar.fluig.com/webdesk/ECMColleagueService")

::Init()
::cresult            :=  WSAdvValue( oXmlRet,"_RESULT","base64Binary",NIL,NIL,NIL,"SB",NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method getColleagues of Service UWSECMCOLLEAGUESERVICESERVICE

WSMETHOD getColleagues WSSEND cusername,cpassword,ncompanyId WSRECEIVE oWSgetColleaguesresult WSCLIENT UWSECMCOLLEAGUESERVICESERVICE
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:getColleagues xmlns:q1="http://ws.foundation.ecm.technology.totvs.com/">'
cSoap += WSSoapValue("username", ::cusername, cusername , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("password", ::cpassword, cpassword , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("companyId", ::ncompanyId, ncompanyId , "int", .T. , .T. , 0 , NIL, .F.) 
cSoap += "</q1:getColleagues>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"getColleagues",; 
	"RPCX","http://ws.foundation.ecm.technology.totvs.com/",,,; 
	"http://alliar.fluig.com/webdesk/ECMColleagueService")

::Init()
::oWSgetColleaguesresult:SoapRecv( WSAdvValue( oXmlRet,"_RESULT","colleagueDtoArray",NIL,NIL,NIL,"O",NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method updateColleaguewithDependencies of Service UWSECMCOLLEAGUESERVICESERVICE

WSMETHOD updateColleaguewithDependencies WSSEND cusername,cpassword,ncompanyId,oWSupdateColleaguewithDependenciescolleagues,oWSupdateColleaguewithDependenciesgroups,oWSupdateColleaguewithDependenciesworkflowRoles WSRECEIVE cresultXML WSCLIENT UWSECMCOLLEAGUESERVICESERVICE
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:updateColleaguewithDependencies xmlns:q1="http://ws.foundation.ecm.technology.totvs.com/">'
cSoap += WSSoapValue("username", ::cusername, cusername , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("password", ::cpassword, cpassword , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("companyId", ::ncompanyId, ncompanyId , "int", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("colleagues", ::oWSupdateColleaguewithDependenciescolleagues, oWSupdateColleaguewithDependenciescolleagues , "colleagueDtoArray", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("groups", ::oWSupdateColleaguewithDependenciesgroups, oWSupdateColleaguewithDependenciesgroups , "groupDtoArray", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("workflowRoles", ::oWSupdateColleaguewithDependenciesworkflowRoles, oWSupdateColleaguewithDependenciesworkflowRoles , "workflowRoleDtoArray", .T. , .T. , 0 , NIL, .F.) 
cSoap += "</q1:updateColleaguewithDependencies>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"updateColleaguewithDependencies",; 
	"RPCX","http://ws.foundation.ecm.technology.totvs.com/",,,; 
	"http://alliar.fluig.com/webdesk/ECMColleagueService")

::Init()
::cresultXML         :=  WSAdvValue( oXmlRet,"_RESULTXML","string",NIL,NIL,NIL,"S",NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method createColleagueWithMap of Service UWSECMCOLLEAGUESERVICESERVICE

WSMETHOD createColleagueWithMap WSSEND cusername,cpassword,ccolleagueXML WSRECEIVE cresultXML WSCLIENT UWSECMCOLLEAGUESERVICESERVICE
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:createColleagueWithMap xmlns:q1="http://ws.foundation.ecm.technology.totvs.com/">'
cSoap += WSSoapValue("username", ::cusername, cusername , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("password", ::cpassword, cpassword , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("colleagueXML", ::ccolleagueXML, ccolleagueXML , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += "</q1:createColleagueWithMap>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"createColleagueWithMap",; 
	"RPCX","http://ws.foundation.ecm.technology.totvs.com/",,,; 
	"http://alliar.fluig.com/webdesk/ECMColleagueService")

::Init()
::cresultXML         :=  WSAdvValue( oXmlRet,"_RESULTXML","string",NIL,NIL,NIL,"S",NIL,NIL) 

END WSMETHOD

oXmlRet := NIL
Return .T.

// WSDL Method getColleague of Service UWSECMCOLLEAGUESERVICESERVICE

WSMETHOD getColleague WSSEND cusername,cpassword,ncompanyId,ccolleagueId WSRECEIVE oWSgetColleaguecolab WSCLIENT UWSECMCOLLEAGUESERVICESERVICE
Local cSoap := "" , oXmlRet

BEGIN WSMETHOD

cSoap += '<q1:getColleague xmlns:q1="http://ws.foundation.ecm.technology.totvs.com/">'
cSoap += WSSoapValue("username", ::cusername, cusername , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("password", ::cpassword, cpassword , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("companyId", ::ncompanyId, ncompanyId , "int", .T. , .T. , 0 , NIL, .F.) 
cSoap += WSSoapValue("colleagueId", ::ccolleagueId, ccolleagueId , "string", .T. , .T. , 0 , NIL, .F.) 
cSoap += "</q1:getColleague>"

oXmlRet := SvcSoapCall(	Self,cSoap,; 
	"getColleague",; 
	"RPCX","http://ws.foundation.ecm.technology.totvs.com/",,,; 
	"http://alliar.fluig.com/webdesk/ECMColleagueService")

::Init()
::oWSgetColleaguecolab:SoapRecv( WSAdvValue( oXmlRet,"_COLAB","colleagueDtoArray",NIL,NIL,NIL,"O",NIL,NIL) )

END WSMETHOD

oXmlRet := NIL
Return .T.


// WSDL Data Structure colleagueDtoArray

WSSTRUCT UECMColleagueServiceService_colleagueDtoArray
	WSDATA   oWSitem                   AS UECMColleagueServiceService_colleagueDto OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT UECMColleagueServiceService_colleagueDtoArray
	::Init()
Return Self

WSMETHOD INIT WSCLIENT UECMColleagueServiceService_colleagueDtoArray
	::oWSitem              := {} // Array Of  UECMColleagueServiceService_COLLEAGUEDTO():New()
Return

WSMETHOD CLONE WSCLIENT UECMColleagueServiceService_colleagueDtoArray
	Local oClone := UECMColleagueServiceService_colleagueDtoArray():NEW()
	oClone:oWSitem := NIL
	If ::oWSitem <> NIL 
		oClone:oWSitem := {}
		aEval( ::oWSitem , { |x| aadd( oClone:oWSitem , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT UECMColleagueServiceService_colleagueDtoArray
	Local cSoap := ""
	aEval( ::oWSitem , {|x| cSoap := cSoap  +  WSSoapValue("item", x , x , "colleagueDto", .F. , .T., 0 , NIL, .F.)  } ) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT UECMColleagueServiceService_colleagueDtoArray
	Local nRElem1 , nTElem1
	Local aNodes1 := WSRPCGetNode(oResponse,.T.)
	::Init()
	If oResponse = NIL ; Return ; Endif 
	nTElem1 := len(aNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( aNodes1[nRElem1] )
			aadd(::oWSitem , UECMColleagueServiceService_colleagueDto():New() )
  			::oWSitem[len(::oWSitem)]:SoapRecv(aNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure colleagueDto

WSSTRUCT UECMColleagueServiceService_colleagueDto
	WSDATA   lactive                   AS boolean OPTIONAL
	WSDATA   ladminUser                AS boolean OPTIONAL
	WSDATA   narea1Id                  AS int OPTIONAL
	WSDATA   narea2Id                  AS int OPTIONAL
	WSDATA   narea3Id                  AS int OPTIONAL
	WSDATA   narea4Id                  AS int OPTIONAL
	WSDATA   narea5Id                  AS int OPTIONAL
	WSDATA   ccolleagueId              AS string OPTIONAL
	WSDATA   ccolleagueName            AS string OPTIONAL
	WSDATA   ccolleaguebackground      AS string OPTIONAL
	WSDATA   ncompanyId                AS long OPTIONAL
	WSDATA   ccurrentProject           AS string OPTIONAL
	WSDATA   cdefaultLanguage          AS string OPTIONAL
	WSDATA   cdialectId                AS string OPTIONAL
	WSDATA   cecmVersion               AS string OPTIONAL
	WSDATA   lemailHtml                AS boolean OPTIONAL
	WSDATA   cespecializationArea      AS string OPTIONAL
	WSDATA   cextensionNr              AS string OPTIONAL
	WSDATA   lgedUser                  AS boolean OPTIONAL
	WSDATA   cgroupId                  AS string OPTIONAL
	WSDATA   lguestUser                AS boolean OPTIONAL
	WSDATA   chomePage                 AS string OPTIONAL
	WSDATA   clogin                    AS string OPTIONAL
	WSDATA   cmail                     AS string OPTIONAL
	WSDATA   nmaxPrivateSize           AS float OPTIONAL
	WSDATA   nmenuConfig               AS int OPTIONAL
	WSDATA   lnominalUser              AS boolean OPTIONAL
	WSDATA   cpasswd                   AS string OPTIONAL
	WSDATA   cphotoPath                AS string OPTIONAL
	WSDATA   nrowId                    AS int OPTIONAL
	WSDATA   csessionId                AS string OPTIONAL
	WSDATA   nusedSpace                AS float OPTIONAL
	WSDATA   cvolumeId                 AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT UECMColleagueServiceService_colleagueDto
	::Init()
Return Self

WSMETHOD INIT WSCLIENT UECMColleagueServiceService_colleagueDto
Return

WSMETHOD CLONE WSCLIENT UECMColleagueServiceService_colleagueDto
	Local oClone := UECMColleagueServiceService_colleagueDto():NEW()
	oClone:lactive              := ::lactive
	oClone:ladminUser           := ::ladminUser
	oClone:narea1Id             := ::narea1Id
	oClone:narea2Id             := ::narea2Id
	oClone:narea3Id             := ::narea3Id
	oClone:narea4Id             := ::narea4Id
	oClone:narea5Id             := ::narea5Id
	oClone:ccolleagueId         := ::ccolleagueId
	oClone:ccolleagueName       := ::ccolleagueName
	oClone:ccolleaguebackground := ::ccolleaguebackground
	oClone:ncompanyId           := ::ncompanyId
	oClone:ccurrentProject      := ::ccurrentProject
	oClone:cdefaultLanguage     := ::cdefaultLanguage
	oClone:cdialectId           := ::cdialectId
	oClone:cecmVersion          := ::cecmVersion
	oClone:lemailHtml           := ::lemailHtml
	oClone:cespecializationArea := ::cespecializationArea
	oClone:cextensionNr         := ::cextensionNr
	oClone:lgedUser             := ::lgedUser
	oClone:cgroupId             := ::cgroupId
	oClone:lguestUser           := ::lguestUser
	oClone:chomePage            := ::chomePage
	oClone:clogin               := ::clogin
	oClone:cmail                := ::cmail
	oClone:nmaxPrivateSize      := ::nmaxPrivateSize
	oClone:nmenuConfig          := ::nmenuConfig
	oClone:lnominalUser         := ::lnominalUser
	oClone:cpasswd              := ::cpasswd
	oClone:cphotoPath           := ::cphotoPath
	oClone:nrowId               := ::nrowId
	oClone:csessionId           := ::csessionId
	oClone:nusedSpace           := ::nusedSpace
	oClone:cvolumeId            := ::cvolumeId
Return oClone

WSMETHOD SOAPSEND WSCLIENT UECMColleagueServiceService_colleagueDto
	Local cSoap := ""
	cSoap += WSSoapValue("active", ::lactive, ::lactive , "boolean", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("adminUser", ::ladminUser, ::ladminUser , "boolean", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("area1Id", ::narea1Id, ::narea1Id , "int", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("area2Id", ::narea2Id, ::narea2Id , "int", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("area3Id", ::narea3Id, ::narea3Id , "int", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("area4Id", ::narea4Id, ::narea4Id , "int", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("area5Id", ::narea5Id, ::narea5Id , "int", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("colleagueId", ::ccolleagueId, ::ccolleagueId , "string", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("colleagueName", ::ccolleagueName, ::ccolleagueName , "string", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("colleaguebackground", ::ccolleaguebackground, ::ccolleaguebackground , "string", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("companyId", ::ncompanyId, ::ncompanyId , "long", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("currentProject", ::ccurrentProject, ::ccurrentProject , "string", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("defaultLanguage", ::cdefaultLanguage, ::cdefaultLanguage , "string", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("dialectId", ::cdialectId, ::cdialectId , "string", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("ecmVersion", ::cecmVersion, ::cecmVersion , "string", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("emailHtml", ::lemailHtml, ::lemailHtml , "boolean", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("especializationArea", ::cespecializationArea, ::cespecializationArea , "string", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("extensionNr", ::cextensionNr, ::cextensionNr , "string", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("gedUser", ::lgedUser, ::lgedUser , "boolean", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("groupId", ::cgroupId, ::cgroupId , "string", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("guestUser", ::lguestUser, ::lguestUser , "boolean", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("homePage", ::chomePage, ::chomePage , "string", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("login", ::clogin, ::clogin , "string", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("mail", ::cmail, ::cmail , "string", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("maxPrivateSize", ::nmaxPrivateSize, ::nmaxPrivateSize , "float", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("menuConfig", ::nmenuConfig, ::nmenuConfig , "int", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("nominalUser", ::lnominalUser, ::lnominalUser , "boolean", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("passwd", ::cpasswd, ::cpasswd , "string", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("photoPath", ::cphotoPath, ::cphotoPath , "string", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("rowId", ::nrowId, ::nrowId , "int", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("sessionId", ::csessionId, ::csessionId , "string", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("usedSpace", ::nusedSpace, ::nusedSpace , "float", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("volumeId", ::cvolumeId, ::cvolumeId , "string", .F. , .T., 0 , NIL, .F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT UECMColleagueServiceService_colleagueDto
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::lactive            :=  WSAdvValue( oResponse,"_ACTIVE","boolean",NIL,NIL,NIL,"L",NIL,"xs") 
	::ladminUser         :=  WSAdvValue( oResponse,"_ADMINUSER","boolean",NIL,NIL,NIL,"L",NIL,"xs") 
	::narea1Id           :=  WSAdvValue( oResponse,"_AREA1ID","int",NIL,NIL,NIL,"N",NIL,"xs") 
	::narea2Id           :=  WSAdvValue( oResponse,"_AREA2ID","int",NIL,NIL,NIL,"N",NIL,"xs") 
	::narea3Id           :=  WSAdvValue( oResponse,"_AREA3ID","int",NIL,NIL,NIL,"N",NIL,"xs") 
	::narea4Id           :=  WSAdvValue( oResponse,"_AREA4ID","int",NIL,NIL,NIL,"N",NIL,"xs") 
	::narea5Id           :=  WSAdvValue( oResponse,"_AREA5ID","int",NIL,NIL,NIL,"N",NIL,"xs") 
	::ccolleagueId       :=  WSAdvValue( oResponse,"_COLLEAGUEID","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::ccolleagueName     :=  WSAdvValue( oResponse,"_COLLEAGUENAME","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::ccolleaguebackground :=  WSAdvValue( oResponse,"_COLLEAGUEBACKGROUND","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::ncompanyId         :=  WSAdvValue( oResponse,"_COMPANYID","long",NIL,NIL,NIL,"N",NIL,"xs") 
	::ccurrentProject    :=  WSAdvValue( oResponse,"_CURRENTPROJECT","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::cdefaultLanguage   :=  WSAdvValue( oResponse,"_DEFAULTLANGUAGE","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::cdialectId         :=  WSAdvValue( oResponse,"_DIALECTID","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::cecmVersion        :=  WSAdvValue( oResponse,"_ECMVERSION","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::lemailHtml         :=  WSAdvValue( oResponse,"_EMAILHTML","boolean",NIL,NIL,NIL,"L",NIL,"xs") 
	::cespecializationArea :=  WSAdvValue( oResponse,"_ESPECIALIZATIONAREA","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::cextensionNr       :=  WSAdvValue( oResponse,"_EXTENSIONNR","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::lgedUser           :=  WSAdvValue( oResponse,"_GEDUSER","boolean",NIL,NIL,NIL,"L",NIL,"xs") 
	::cgroupId           :=  WSAdvValue( oResponse,"_GROUPID","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::lguestUser         :=  WSAdvValue( oResponse,"_GUESTUSER","boolean",NIL,NIL,NIL,"L",NIL,"xs") 
	::chomePage          :=  WSAdvValue( oResponse,"_HOMEPAGE","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::clogin             :=  WSAdvValue( oResponse,"_LOGIN","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::cmail              :=  WSAdvValue( oResponse,"_MAIL","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::nmaxPrivateSize    :=  WSAdvValue( oResponse,"_MAXPRIVATESIZE","float",NIL,NIL,NIL,"N",NIL,"xs") 
	::nmenuConfig        :=  WSAdvValue( oResponse,"_MENUCONFIG","int",NIL,NIL,NIL,"N",NIL,"xs") 
	::lnominalUser       :=  WSAdvValue( oResponse,"_NOMINALUSER","boolean",NIL,NIL,NIL,"L",NIL,"xs") 
	::cpasswd            :=  WSAdvValue( oResponse,"_PASSWD","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::cphotoPath         :=  WSAdvValue( oResponse,"_PHOTOPATH","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::nrowId             :=  WSAdvValue( oResponse,"_ROWID","int",NIL,NIL,NIL,"N",NIL,"xs") 
	::csessionId         :=  WSAdvValue( oResponse,"_SESSIONID","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::nusedSpace         :=  WSAdvValue( oResponse,"_USEDSPACE","float",NIL,NIL,NIL,"N",NIL,"xs") 
	::cvolumeId          :=  WSAdvValue( oResponse,"_VOLUMEID","string",NIL,NIL,NIL,"S",NIL,"xs") 
Return

// WSDL Data Structure groupDtoArray

WSSTRUCT UECMColleagueServiceService_groupDtoArray
	WSDATA   oWSitem                   AS UECMColleagueServiceService_groupDto OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT UECMColleagueServiceService_groupDtoArray
	::Init()
Return Self

WSMETHOD INIT WSCLIENT UECMColleagueServiceService_groupDtoArray
	::oWSitem              := {} // Array Of  UECMColleagueServiceService_GROUPDTO():New()
Return

WSMETHOD CLONE WSCLIENT UECMColleagueServiceService_groupDtoArray
	Local oClone := UECMColleagueServiceService_groupDtoArray():NEW()
	oClone:oWSitem := NIL
	If ::oWSitem <> NIL 
		oClone:oWSitem := {}
		aEval( ::oWSitem , { |x| aadd( oClone:oWSitem , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT UECMColleagueServiceService_groupDtoArray
	Local cSoap := ""
	aEval( ::oWSitem , {|x| cSoap := cSoap  +  WSSoapValue("item", x , x , "groupDto", .F. , .T., 0 , NIL, .F.)  } ) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT UECMColleagueServiceService_groupDtoArray
	Local nRElem1 , nTElem1
	Local aNodes1 := WSRPCGetNode(oResponse,.T.)
	::Init()
	If oResponse = NIL ; Return ; Endif 
	nTElem1 := len(aNodes1)
	For nRElem1 := 1 to nTElem1 
		If !WSIsNilNode( aNodes1[nRElem1] )
			aadd(::oWSitem , UECMColleagueServiceService_groupDto():New() )
  			::oWSitem[len(::oWSitem)]:SoapRecv(aNodes1[nRElem1])
		Endif
	Next
Return

// WSDL Data Structure workflowRoleDtoArray

WSSTRUCT UECMColleagueServiceService_workflowRoleDtoArray
	WSDATA   oWSitem                   AS UECMColleagueServiceService_workflowRoleDto OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT UECMColleagueServiceService_workflowRoleDtoArray
	::Init()
Return Self

WSMETHOD INIT WSCLIENT UECMColleagueServiceService_workflowRoleDtoArray
	::oWSitem              := {} // Array Of  UECMColleagueServiceService_WORKFLOWROLEDTO():New()
Return

WSMETHOD CLONE WSCLIENT UECMColleagueServiceService_workflowRoleDtoArray
	Local oClone := UECMColleagueServiceService_workflowRoleDtoArray():NEW()
	oClone:oWSitem := NIL
	If ::oWSitem <> NIL 
		oClone:oWSitem := {}
		aEval( ::oWSitem , { |x| aadd( oClone:oWSitem , x:Clone() ) } )
	Endif 
Return oClone

WSMETHOD SOAPSEND WSCLIENT UECMColleagueServiceService_workflowRoleDtoArray
	Local cSoap := ""
	aEval( ::oWSitem , {|x| cSoap := cSoap  +  WSSoapValue("item", x , x , "workflowRoleDto", .F. , .T., 0 , NIL, .F.)  } ) 
Return cSoap

// WSDL Data Structure groupDto

WSSTRUCT UECMColleagueServiceService_groupDto
	WSDATA   ncompanyId                AS long OPTIONAL
	WSDATA   cfoo                      AS string OPTIONAL
	WSDATA   cgroupDescription         AS string OPTIONAL
	WSDATA   cgroupId                  AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
	WSMETHOD SOAPRECV
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT UECMColleagueServiceService_groupDto
	::Init()
Return Self

WSMETHOD INIT WSCLIENT UECMColleagueServiceService_groupDto
	::cfoo                 := {} // Array Of  ""
Return

WSMETHOD CLONE WSCLIENT UECMColleagueServiceService_groupDto
	Local oClone := UECMColleagueServiceService_groupDto():NEW()
	oClone:ncompanyId           := ::ncompanyId
	oClone:cfoo                 := IIf(::cfoo <> NIL , aClone(::cfoo) , NIL )
	oClone:cgroupDescription    := ::cgroupDescription
	oClone:cgroupId             := ::cgroupId
Return oClone

WSMETHOD SOAPSEND WSCLIENT UECMColleagueServiceService_groupDto
	Local cSoap := ""
	cSoap += WSSoapValue("companyId", ::ncompanyId, ::ncompanyId , "long", .F. , .T., 0 , NIL, .F.) 
	aEval( ::cfoo , {|x| cSoap := cSoap  +  WSSoapValue("foo", x , x , "string", .F. , .T., 0 , NIL, .F.)  } ) 
	cSoap += WSSoapValue("groupDescription", ::cgroupDescription, ::cgroupDescription , "string", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("groupId", ::cgroupId, ::cgroupId , "string", .F. , .T., 0 , NIL, .F.) 
Return cSoap

WSMETHOD SOAPRECV WSSEND oResponse WSCLIENT UECMColleagueServiceService_groupDto
	Local oNodes2 :=  WSAdvValue( oResponse,"_FOO","string",{},NIL,.T.,"S",NIL,"xs") 
	::Init()
	If oResponse = NIL ; Return ; Endif 
	::ncompanyId         :=  WSAdvValue( oResponse,"_COMPANYID","long",NIL,NIL,NIL,"N",NIL,"xs") 
	aEval(oNodes2 , { |x| aadd(::cfoo ,  x:TEXT  ) } )
	::cgroupDescription  :=  WSAdvValue( oResponse,"_GROUPDESCRIPTION","string",NIL,NIL,NIL,"S",NIL,"xs") 
	::cgroupId           :=  WSAdvValue( oResponse,"_GROUPID","string",NIL,NIL,NIL,"S",NIL,"xs") 
Return

// WSDL Data Structure workflowRoleDto

WSSTRUCT UECMColleagueServiceService_workflowRoleDto
	WSDATA   ncompanyId                AS long OPTIONAL
	WSDATA   cfoo                      AS string OPTIONAL
	WSDATA   croleDescription          AS string OPTIONAL
	WSDATA   croleId                   AS string OPTIONAL
	WSMETHOD NEW
	WSMETHOD INIT
	WSMETHOD CLONE
	WSMETHOD SOAPSEND
ENDWSSTRUCT

WSMETHOD NEW WSCLIENT UECMColleagueServiceService_workflowRoleDto
	::Init()
Return Self

WSMETHOD INIT WSCLIENT UECMColleagueServiceService_workflowRoleDto
	::cfoo                 := {} // Array Of  ""
Return

WSMETHOD CLONE WSCLIENT UECMColleagueServiceService_workflowRoleDto
	Local oClone := UECMColleagueServiceService_workflowRoleDto():NEW()
	oClone:ncompanyId           := ::ncompanyId
	oClone:cfoo                 := IIf(::cfoo <> NIL , aClone(::cfoo) , NIL )
	oClone:croleDescription     := ::croleDescription
	oClone:croleId              := ::croleId
Return oClone

WSMETHOD SOAPSEND WSCLIENT UECMColleagueServiceService_workflowRoleDto
	Local cSoap := ""
	cSoap += WSSoapValue("companyId", ::ncompanyId, ::ncompanyId , "long", .F. , .T., 0 , NIL, .F.) 
	aEval( ::cfoo , {|x| cSoap := cSoap  +  WSSoapValue("foo", x , x , "string", .F. , .T., 0 , NIL, .F.)  } ) 
	cSoap += WSSoapValue("roleDescription", ::croleDescription, ::croleDescription , "string", .F. , .T., 0 , NIL, .F.) 
	cSoap += WSSoapValue("roleId", ::croleId, ::croleId , "string", .F. , .T., 0 , NIL, .F.) 
Return cSoap


