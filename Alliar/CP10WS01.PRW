#Include 'Protheus.ch'
//#Include 'FWMVCDEF.ch'
#Include 'RestFul.CH'


User Function CP10WS01()
Return


WSRESTFUL COMPILA_SIMPLE_EXPORT DESCRIPTION "Rest de retorno dinámico baseado em views pré-definidas. "

WSDATA IDWS AS STRING  //| TOTAIS/SUCESSO_FALHA/PRINCIPAIS_FALHAS/PV_ABERTO/FALHAS_EMPRESA |
//WSDATA PERIODO AS STRING  //| DIARIO/SEMANAL/MENSAL |
 

//WSMETHOD GET DESCRIPTION "Retorna dados (IDWS define consulta). Demais parametros verifique com o Administrador da Aplicação" WSSYNTAX "/COMPILA_SIMPLE_EXPORT/{IDWS}"
WSMETHOD POST DESCRIPTION "Retorna dados (IDWS define consulta). Demais parametros verifique com o Administrador da Aplicação. (www.compila.com.br)" WSSYNTAX "/COMPILA_SIMPLE_EXPORT/{IDWS}"


END WSRESTFUL


/*
WSMETHOD GET WSRECEIVE IDWS WSSERVICE COMPILA_SIMPLE_EXPORT
Local lRet		:= .F.
LOCAL cJson := ""
Local dAtual, dAnter
Local aAtual, aAnter
Local cQuery	:= ""
Local aVlrAtu	:= {} 
Local aVlrAnt	:= {}
Local nI, nX, nPerc

::SetContentType("application/json")


IF !EMPTY(SELF:IDWS)

	::SetResponse(cJson)
	lRet	:= .t.
ELSE
	SetRestFault(400, "Parameters are mandatory")
ENDIF




Return(lRet)

*/


WSMETHOD POST  WSSERVICE COMPILA_SIMPLE_EXPORT
Local oObjProd := Nil
Local cStatus  := ""
LOcal cBody		:= ""
Local cJRetOK   := '{"code":200,"status":"success"}'
Local aRetAux
Local lRet		:= .F.
Private oCpJson

::SetContentType("application/json")

cBody := ::GetContent()
IF !EMPTY(cBody)
	/*------------------------------------------------------ Augusto Ribeiro | 28/06/2017 - 6:21:47 PM
		Processa Json recebido pelo REST
	------------------------------------------------------------------------------------------*/
	aRetAux	:= U_CP10WSJSON(cBody)
	if aRetAux[1] == 200
		::SetResponse(aRetAux[3])
		lRet	:= .T.
	ELSE
		SetRestFault(aRetAux[1], aRetAux[2])
	ENDIF				
	
ELSE
   SetRestFault(401, "Body Vazio")

ENDIF


 


Return(lRet)

