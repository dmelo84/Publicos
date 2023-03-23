#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.ch"

/*/{Protheus.doc} FA040DEL
APÓS EXCLUSAO DO TITULO NO CR INVOCA EXCLUSAO DO TITULO DESTINO NO CP

@since 30/12/2014
@version P11 11.8
@description trata consistencias do mutuo
@obs Uso: Bradesco Seguros - BSP 
 
@return Boolean
/*/

User Function FA040DEL ()
Local aE1Area := GetArea("SE1")
Local aArea := GetArea()
Local cPrefMutuo   := SuperGetMV("ES_PRMU",, '')  


/*--------------------------------------
 \/ CP11 - Baixa Cartao de Credito
-----------------------------------------*/
U_CP11ESTF("SE1", SE1->(RECNO()),, SE1->E1_VALOR)
RestArea(aE1Area)
/*--------------------------------------
 /\ CP11 - Baixa Cartao de Credito
-----------------------------------------*/




If AllTrim(SE1->E1_PREFIXO) == AllTrim(cPrefMutuo) 
	If FindFunction("U_ALFIN6EXCLCP")
	
		U_ALFIN6ExclCP(.T.)
	EndIf
EndIf


/*--------------------------
	INTEGRAÇÃO GESPLAN
---------------------------*/
IF SE1->E1_XSTFIN == "1" .OR. SE1->E1_XSTACC == "1"  //| FinancialOpenness ou AccountingOpenness

	SE1->(RecLock("SE1",.F.))
	
		SE1->E1_XSTFIN	:= "0" //| Volta para CashPosting
		SE1->E1_XSTACC	:= "0" //| Volta para CashPosting
		SE1->E1_XSTCAS	:= "0" //| Volta para CashPosting
		SE1->E1_XDTGPLA := CTOD("")
		
	SE1->(MsUnLock())
	
	
	
	
ENDIF


restArea(aE1Area)
restArea(aArea)
Return 


