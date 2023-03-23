#include 'protheus.ch'
#include 'parmtype.ch'

/*------------------------------------------------------
|Ponto de Entrada - Gravação de campo na SE1 depois da  |
|efetivação da venda                                    |
|Desenvolvedor Diogo Melo                               |
|Data: 26/06/2019                                       |
--------------------------------------------------------*/

user function LJDEPSE1

	Local aReceb := Paramixb[1]

	If Empty(SE1->E1_P_DTRAX)

		RecLock("SE1",.F.)
			SE1->E1_P_DTRAX := SL1->L1_P_DTRAX
			SE1->E1_P_WLDPA := Strzero(Val(SL1->L1_P_DTRAX),9)+"01"
		MsUnlock()

		Conout("---------------------------------------------------------------")
		Conout("PE - LJDEPSE1: Atualizou o Titulo: "+ SE1->E1_NUM )
		Conout("PE - LJDEPSE1: o campo SL1->L1_P_DTRAX com "+ SL1->L1_P_DTRAX)
		Conout("---------------------------------------------------------------")
	EndIf
Return