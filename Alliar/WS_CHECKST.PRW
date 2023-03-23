#INCLUDE "APWEBSRV.CH"
#INCLUDE "PROTHEUS.CH"

WsService WS_CHECKST Description 'Verifica se WS esta on-line' NameSpace "http://localhost/ws/WS_CHECKST.apw"

	WsData   cMensagem   As String
	WsData   cPar01   As String
	
	WsMethod checkst  Description "Verifica se WS esta on-line"
	
EndWsService



/*/{Protheus.doc} checkst
Verifica se status do WS esta on-line
@author Augusto Ribeiro | www.compila.com.br
@since 28/06/2019
@version undefined
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
//WsMethod checkst WsReceive cCompany, cBranch, cEquipment, cRequester, cService, cExtension, cIdFluig WsSend cMensagem WsService WS_CHECKST
WsMethod checkst WsReceive cPar01 WsSend cMensagem WsService WS_CHECKST
Local lRet := .t.

DBSELECTAREA("SA1")
SA1->(DBSETORDER(1)) //| 
SA1->(DBGOTOP())
IF !EMPTY(SA1->A1_COD)

	::cMensagem	:= "Sucesso"

ELSE
	::cMensagem :=  "FALHA. Primeiro registro do SA1 vazio"
	lRet	:= .F.
ENDIF	
	
Return lRet
