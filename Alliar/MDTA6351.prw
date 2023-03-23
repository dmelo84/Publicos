#Include 'Totvs.ch'

/*/{Protheus.doc} MDTA6351

@author Jorge Heitor
@since 12/01/2016
@version 12.001.7
@description Ponto de Entrada para acionar a atualiza��o de Mandato no Fluig (Ap�s Inclus�o no Protheus)
@obs Espec�fico ALLIAR - Abertura CIPA

/*/
User Function MDTA6351()

	If INCLUI
		
		U_ALRMDT02(3)
		
	EndIf
	
	//TODO Verificar exclus�o de Mandato (para casos em que incluiu erroneamente. 

Return .T.