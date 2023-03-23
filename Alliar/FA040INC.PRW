#Include "RWMAKE.CH"
#Include "TOPCONN.CH"
#Include "Protheus.Ch"
#include "TbiConn.ch"

/*/{Protheus.doc} FA040INC
EVITA INCLUIR MANULAMENTE UM TITULO COM PREFIXO DE MUTUO

@since 30/12/2014
@version P11 11.8
@description trata consistencias do mutuo
@obs Uso: Bradesco Seguros - BSP 
 
@return Boolean
/*/

User Function FA040INC ()
Local aArea := GetArea()
Local lRet  := .T.
Local cForm := M->E1_XFORMPG
Local cNome := FUNNAME()

If FindFunction("U_ALFIN5")
	lRet := U_ALFIN5(.T.)
EndIf

/*------------------------------------------------------
	Autor - Mateus Hengle  - Data - 20/09/2018
	PE que nao permite que o campo E1_XFORMPG nao seja
	preenchido quando a inclusão for manual  
------------------------------------------------------*/
IF !ISBLIND() .AND. EMPTY(cForm) .AND. (cNome == "FINA740" .OR. cNome == "FINA040") // SE FOR ROTINA MANUAL E O CAMPO DE FORMA DE PGTO ESTIVER EM BRANCO NAO DEIXA CONFIRMAR
	Help("Contas a receber",1,"Preenchimento de campo obrigatorio",,"O campo forma de pagamento na Aba OUTROS não foi preenchido, favor preencher o campo!" ,4,5)
	lRet := .F.
ENDIF	

restArea(aArea)

Return (lRet)

