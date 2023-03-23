#Include 'Protheus.ch'
#Include 'FWMVCDEF.ch'
#Include 'RestFul.CH'

User Function CP13_NF_SEM_PDF()
Return



WSRESTFUL CP13_NF_SEM_PDF DESCRIPTION "Serviço REST retonar notas sem PDF"


WSDATA XPAR1 AS STRING  //| Parametro para receber codigo de municipio ou retorno filiais ativas |

WSMETHOD GET DESCRIPTION "Busca dados das Notas para consulta de PDF nas prefeituras" WSSYNTAX "/CP13_NF_SEM_PDF"
WSMETHOD POST DESCRIPTION "Recebe PDF da Nota" WSSYNTAX "/CP13_NF_SEM_PDF"

END WSRESTFUL


WSMETHOD GET WSRECEIVE XPAR1 WSSERVICE CP13_NF_SEM_PDF
Local cAutBasic		:= ""
Local cJsonRet		:= ""
Local lRet			:= .f.
Local lCNPJAtivos	:= .F.
Local cCodMun		:= ""


::SetContentType("application/json")

/*------------------------------------------------------ Augusto Ribeiro | 18/01/2018 - 9:36:31 PM
	Bloco de Autorização 
------------------------------------------------------------------------------------------*/

cAutBasic	:= self:GetHeader("Authorization") //| BASIC YWRtaW46|
	
IF U_CPxAuWSR(cAutBasic)

	
	IF !EMPTY(SELF:XPAR1)
		IF ALLTRIM(UPPER(SELF:XPAR1)) == "CNPJ_ATIVOS"
			lCNPJAtivos	:= .T.
		ELSE
			cCodMun		:= ALLTRIM(SELF:XPAR1)
		ENDIF
	ENDIF

	IF lCNPJAtivos
		cJsonRet	:= U_CP13CNPJ()
	ELSE
		cJsonRet	:= U_CP13GNF(cCodMun)
	ENDIF
	
	::SetResponse(cJsonRet)
	lRet	:= .t.
	
ELSE
	SetRestFault(401, "Authentication Required")
ENDIF

Return(lRet)






WSMETHOD POST  WSSERVICE CP13_NF_SEM_PDF
Local cAutBasic		:= ""
Local cJsonRet		:= ""
Local lRet			:= .f.
Local cBody			:= ""
Local aRetAux

::SetContentType("application/json")

/*------------------------------------------------------ Augusto Ribeiro | 18/01/2018 - 9:36:31 PM
	Bloco de Autorização 
------------------------------------------------------------------------------------------*/

cAutBasic	:= self:GetHeader("Authorization") //| BASIC YWRtaW46|
	
IF U_CPxAuWSR(cAutBasic)

	cBody := ::GetContent()

	//cJsonRet	:= U_CP13GNF()
	
	
	IF cBody == Nil
		cBody := ""
	EndIf
	
	IF !EMPTY(cBody)
	
	
		aRetAux	:= U_CP13SPDF(cBody)
		IF aRetAux[1]
			::SetResponse('{"code":200,"status":"success"}')
			lRet	:= .t.			
		ELSE
			SetRestFault(401, "Falha "+aRetAux[2])
		ENDIF

	ENDIF
	

ELSE
	SetRestFault(401, "Authentication Required")
ENDIF

Return(lRet)




