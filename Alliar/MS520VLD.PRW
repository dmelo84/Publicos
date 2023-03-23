#INCLUDE "PROTHEUS.CH"
//-------------------------------------------------------------------
/*{Protheus.doc} MS520VLD
Validacao na Exclusão da NF de Saida

@author Guilherme Santos
@since 29/09/2016
@version P12
*/
//-------------------------------------------------------------------
User Function MS520VLD()
	Local aArea		:= GetArea()
	Local aAreaSC5	:= SC5->(GetArea())
	Local aAreaSD2	:= SD2->(GetArea())
	Local aAreaSF2	:= SF2->(GetArea())
	Local aPedidos	:= U_AL07GPED(SF2->F2_SERIE, SF2->F2_DOC, SF2->F2_CLIENTE, SF2->F2_LOJA)
	Local nPedido		:= 0
	Local lCorrCSC	:= .T.
	Local lRetorno 	:= .T.

	//Determina o Tipo de Correcao da NF
	lRetorno := U_AL07TPEX(@lCorrCSC)

	If lRetorno
		For nPedido := 1 to Len(aPedidos)
			//Altera o status do pedido para nao faturar novamente
			DbSelectArea("SC5")
			DbSetOrder(1)		//C5_FILIAL, C5_NUM
			
			If SC5->(DbSeek(xFilial("SC5") + aPedidos[nPedido][01]))
				If !Empty(SC5->C5_XIDPLE)
	    			RecLock("SC5", .F.)
	    				SC5->C5_XELIMRE := If(lCorrCSC, "N", "S")
	    			MsUnlock()		
	    		EndIf
			EndIf
		Next nPedido 
	EndIf

	If lRetorno .AND. (LEFT(Alltrim(SF2->F2_XIDPLE),1) == "R" .OR. LEFT(Alltrim(SF2->F2_XIDPLE),1) == "U")
		
		U_CP12ADD("000033", "", 0, '{"event":{"type":"canceled_status","id":"'+SF2->F2_XIDPLE+'","rps_number":"'+ALLTRIM(SF2->F2_DOC)+'","series_number":"'+ALLTRIM(SF2->F2_SERIE)+'"}}', )
	
	Endif

	RestArea(aAreaSF2)
	RestArea(aAreaSD2)
	RestArea(aAreaSC5)
	RestArea(aArea)
Return lRetorno
