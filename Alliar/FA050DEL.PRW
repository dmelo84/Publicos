#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.ch"

/*/{Protheus.doc} FA050DEL
evita EXCLUSAO DO TITULO NO CP 

@since 30/12/2014
@version P11 11.8
@description trata consistencias do mutuo
@obs Uso: Alliar
 
@return Boolean
/*/

User Function FA050DEL ()
Local aE1Area := GetArea("SE1")
Local aE2Area := GetArea("SE2")
Local aArea := GetArea()
Local cPrefMutuo   := SuperGetMV("ES_PRMU",, '')  
Local lRet := .T.


//no ato de cancelar a exclusao o proprio produto padrao nao passa por este PE. 
If AllTrim(SE2->E2_PREFIXO) == AllTrim(cPrefMutuo) 
	If FindFunction("U_ALFIN6ExclCP")

		lRet := U_ALFIN6ExclCP(.F.)
	EndIf
EndIf

//| Na exclusão do Título, inclui registro na fila do integrador

IF SE2->E2_XSTFIN == "1" //| FinancialOpenness

	SE2->(RecLock("SE2",.F.))
	
		SE2->E2_XSTCAS	:= "0" //| Volta para CashPosting
		SE2->E2_XSTFIN	:= "0" //| Volta para CashPosting
		SE2->E2_XSTACC	:= "0" //| Volta para CashPosting
		SE2->E2_XDTGPLA := CTOD("")
		
	SE2->(MsUnLock())
	
ENDIF

restArea(aE1Area)
restArea(aE2Area)
restArea(aArea)
Return lRet

