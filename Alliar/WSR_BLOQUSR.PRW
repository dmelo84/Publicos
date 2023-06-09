#Include 'Protheus.ch'
#Include 'FWMVCDEF.ch'
#Include 'RestFul.CH'
#INCLUDE "TBICONN.CH" 

User Function WSR_BLOUSER()
Return



WSRESTFUL BLOUSER DESCRIPTION "[CUSTOMIZADO] - Servi�o REST para bloqueio de usu�rios"

WSMETHOD POST DESCRIPTION "Bloqueia usu�rio atrav�s o e-mail passado." WSSYNTAX "/BLOUSER || /BLOUSER/{}"

END WSRESTFUL


WSMETHOD POST  WSSERVICE BLOUSER
LOcal cBody		:= ""
Local oJson	
Local lRet		:= .F.
Local aRetAux
Local cAutBasic		:= ""

::SetContentType("application/json")

/*------------------------------------------------------ Augusto Ribeiro | 18/01/2018 - 9:36:31 PM
	Bloco de Autoriza��o 
------------------------------------------------------------------------------------------*/

cAutBasic	:= self:GetHeader("Authorization") //| BASIC YWRtaW46|
	

IF U_CPxAuWSR(cAutBasic)

	cBody := ::GetContent()
	IF !EMPTY(cBody)
	

		//IF FWJsonDeserialize(cBody,@oJson)
		CONOUT(cBody)
		aRetAux	:= U_WSRBLQUSR(cBody)
		if aRetAux[1]
			::SetResponse('{"errorCode":200,"errorMessage":"Sucesso"}')
			lRet	:= .t.
		else
			SetRestFault(400, aRetAux[2])	
		endif
	ELSE
		SetRestFault(400, "Empty Body")	
	ENDIF
ELSE
	SetRestFault(401, "Authentication Required")
ENDIF


Return(lRet)


/*/{Protheus.doc} WSRBLQUSR
Realiza bloqueio do usu�rio de acordo com o e-mail passado
@author Augusto Ribeiro | www.compila.com.br
@since 01/04/2019
@version undefined
@param cJson
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
User Function WSRBLQUSR(cJson)
Local aRet	:= {.f.,""}
Local oJson, cUserCod


IF FWJsonDeserialize(cJson,@oJson)
	
	
	/*------------------------------------------------------ Augusto Ribeiro | 01/02/2018 - 1:50:25 PM
		Estou utilizando a atribui��a campo a campo pois nesta vers�o da BUIL/LIB  a fun��o
		ClassDataArr( < oObj >, [ lParent ] ) n�o funciona de maneira corrata.
	------------------------------------------------------------------------------------------*/
	IF AttIsMemberOf(oJson , "EMAIL")
	
		PswOrder(4)//|E-mail|
		If PswSeek( alltrim(oJson:EMAIL), .T. )
			aDadosUsr	:= PswRet( 1, .F. )
			
			cUsrCod 	:= aDadosUsr[1][1]
			cUsrName	:= aDadosUsr[1][2]
			
			IF PswBlock(cUsrName)
				aRet[1]	:= .T.
			ELSE
				aRet[2] := "Falha no Bloqueio do usu�rio"
			ENDIF			
		ELSE
			aRet[2] := "Usuario nao localizado"
		ENDIF
	ELSE
		aRet[2] := "Json Invalido. EMAIL Obrigat�rio"
	ENDIF
	
ELSE
	aRet[2] := "Json Invalido"
ENDIF


Return(aRet)

