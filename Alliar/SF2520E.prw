#INCLUDE "PROTHEUS.CH"
//-------------------------------------------------------------------
/*{Protheus.doc} SF2520E
Ponto de Entrada na Exclusao da NF de Saida

@author Guilherme Santos
@since 09/08/2016
@version P12
*/
//-------------------------------------------------------------------
User Function SF2520E()
	Local aArea		:= GetArea()
	Local aAreaSC5	:= SC5->(GetArea())
	Local aAreaSD2	:= SD2->(GetArea())
	Local aAreaSF2	:= SF2->(GetArea())
	Local aPedidos	:= U_AL07GPED(SF2->F2_SERIE, SF2->F2_DOC, SF2->F2_CLIENTE, SF2->F2_LOJA)
	Local nPedido		:= 0

	Local oIntegra	:= NIL
    /*
    -----------------------------------------------------------------------------------------------------
    	Verifica se os Pedidos são de Integracao e Consome o WS para Excluir nos Sistemas de Origem
    -----------------------------------------------------------------------------------------------------	
    */
	U_AL07VLEX(aPedidos)
	/*
	-----------------------------------------------------------------------------------------------------
		Altera o status do pedido para nao faturar novamente
	-----------------------------------------------------------------------------------------------------	
	*/
	
	DBSELECTAREA("SZK")
	SZK->(DBSETORDER(1)) //| 
	
	DBSELECTAREA("SA1")
	SA1->(DBSETORDER(1))
	
	For nPedido := 1 to Len(aPedidos)
		DbSelectArea("SC5")
		DbSetOrder(1)		//C5_FILIAL, C5_NUM
		
		If SC5->(DbSeek(xFilial("SC5") + aPedidos[nPedido][01]))
			If !Empty(SC5->C5_XIDPLE)
    			RecLock("SC5", .F.)
    				SC5->C5_XBLQ := "6"
    			MsUnlock()
    			
    			IF SA1->(DBSEEK( XFILIAL("SA1") + SC5->( C5_CLIENTE + C5_LOJACLI ) )) .AND. SA1->A1_PESSOA == "J"
					IF SZK->(DBSEEK(SM0->M0_CODIGO + SC5->C5_FILIAL)) .AND. SZK->ZK_FATPJAU == "S"
		    			/*------------------------------------------------------ Augusto Ribeiro | 30/10/2018 - 5:21:48 PM
							Atualiza Satus do Fluig - Adiciona a fila do Integrador
						------------------------------------------------------------------------------------------*/
						U_CP12ADD("000025", "SF2", SF2->(RECNO()),,, "02", SC5->C5_XIDFLG)
					ENDIF 
				ENDIF 
    		EndIf
		EndIf
	Next nPedido 
	
	

	RestArea(aAreaSF2)
	RestArea(aAreaSD2)
	RestArea(aAreaSC5)
	RestArea(aArea)
Return NIL
