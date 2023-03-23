#INCLUDE "Protheus.ch"
/*/{Protheus.doc} FTotPed
Gera o total do pedido para ser apresentado no browse
@author marcos.aleluia
@since 29/12/2016
@version undefined

@type function
/*/
User Function FTotPed(cNumPed)

	Local nTotal := 0
	Local aAreaC6 := GetArea()
	Default cNumPed := ""
	
	SC6->( dbSetOrder(1) )
	if SC6->( MsSeek( FWxFilial("SC6") + cNumPed ) )
		while ! SC6->( EOF() ) .AND. FWxFilial("SC6") + cNumPed == SC6->( C6_FILIAL + C6_NUM )
			nTotal += SC6->C6_VALOR
			SC6->( dbSkip() )
		enddo
	endif
	
	RestArea(aAreaC6)

Return(nTotal)