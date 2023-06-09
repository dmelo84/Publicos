#Include 'Protheus.ch'
#Include 'FWMVCDEF.ch'
#Include 'RestFul.CH'

User Function WSR_CHECKST()
Return



WSRESTFUL CHECKST DESCRIPTION "Servi�o REST verifica��o do Status do servi�o "

WSMETHOD GET DESCRIPTION "Retorna 200 caso servi�o estaja no ar" WSSYNTAX "/CHECKST "

END WSRESTFUL




/*/{Protheus.doc} GET
Servi�o utilizado pela Totvs somente para verificar se servi�o esta on-line.
@author Augusto Ribeiro | www.compila.com.br
@since 28/06/2019
@version undefined
@param param
@return return, return_description
@example
(examples)
@see (links_or_references)
/*/
WSMETHOD GET  WSSERVICE CHECKST
Local lRet		:= .T.


::SetContentType("application/json")


DBSELECTAREA("SA1")
SA1->(DBSETORDER(1)) //| 
SA1->(DBGOTOP())
IF !EMPTY(SA1->A1_COD)

	::SetResponse( '{"code":200,"status":"success"}')

ELSE
	SetRestFault(401, "Primeiro registro do SA1 vazio")
	lRet	:= .F.
ENDIF	



Return(lRet)


