#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.ch"

/*/{Protheus.doc} F040BLQ
Títulos de mutuo utilizarao somente cancelamento de baixa, jamais exclusao da baixa

@since 30/12/2014
@version P11 11.8
@description trata consistencias do mutuo
@obs Uso: Bradesco Seguros - BSP 
 
@return Boolean
/*/

User Function F040BLQ ()
Local aE1Area := GetArea("SE1")
Local aArea := GetArea()

Local lRet  := .T.
Local cPrefMutuo   := SuperGetMV("ES_PRMU",, '')  

If AllTrim(SE1->E1_PREFIXO) == AllTrim(cPrefMutuo) 
	If FindFunction("U_ALFIN4")
		lRet := U_ALFIN4()
	EndIf
EndIf

restArea(aArea)
restArea(aE1Area)

Return (lRet)

