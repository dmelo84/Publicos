#Include "Protheus.Ch"

//| TABELA
#DEFINE D_ALIAS 'ACH'
#DEFINE D_TITULO 'Cadastro de Medicos'
#DEFINE D_ROTINA 'ATMK002'
#DEFINE D_MODEL 'ACHMODEL'
#DEFINE D_MODELMASTER 'ACHMASTER'
#DEFINE D_VIEWMASTER 'VIEW_ACH'

/*/{Protheus.doc} ${ATMK002}
Modelo 1 MVC
@author Augusto Ribeiro | www.compila.com.br
@since 02/11/2013 
@version 1.0
@example
(examples)
@see (links_or_references)
/*/  
User Function ATMK002()
//Local cFilDef	:= '!empty(POSICIONE("Z04",2,__CUSERID+ACH->(ACH_CODIGO+ACH_LOJA),"Z04_CODVIS"))'

Private cVisitad	:= __cUserID
//
//DBSELECTAREA("Z04")
//Z04->(DBSETORDER(1))
//Z04->(DBGOTOP())

/*------------------------------------------------------ Augusto Ribeiro | 18/09/2017 - 9:32:06 AM
	Chamada cadastro de médicos Padrão (SUSPECTS)
------------------------------------------------------------------------------------------*/
TMKA341(, , , )

Return NIL
