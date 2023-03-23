#INCLUDE "TOTVS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "WINAPI.CH"
#INCLUDE "COLORS.CH"



// Adiciona Regras p/ exibicao da Legenda nos pedidos conf campo customizado (C5_XBLQ)
User Function MA410COR()
	Local aCores := {} 
	Local aPadrao := aClone(ParamIxb) 
	Local nX := 0
	
	Aadd(aCores, {"C5_XBLQ == '1' .AND. Empty(C5_NOTA)",'BR_CINZA'		,"Bloq.: Cliente novo atualizar cadastro"})
	Aadd(aCores, {"C5_XBLQ == '2' .AND. Empty(C5_NOTA)",'BR_MARROM'		,"Bloq.: Atualizar cad. cliente"})
	Aadd(aCores, {"C5_XBLQ == '3' .AND. Empty(C5_NOTA)",'BR_BRANCO'		,"Bloq.: Atualizar valor dos tribs retidos"})
	Aadd(aCores, {"C5_XBLQ == '5' .AND. Empty(C5_NOTA)",'BR_LARANJA'	,"Bloq.: Atualizar Valor do Pedido"})
	Aadd(aCores, {"C5_XBLQ == '6' .AND. Empty(C5_NOTA)",'BR_AZUL'		,"Bloq.: NF Cancelada"})
	Aadd(aCores, {"C5_XBLQ == '7' .AND. Empty(C5_NOTA)",'BR_PRETO'		,"Bloq.: Emitindo NF"})
	Aadd(aCores, {"C5_XBLQ == '8' .AND. Empty(C5_NOTA)",'BR_PINK'		,"Bloq.: Aguard Complemento Fluig"})

	For nX:= 1 to Len(aPadrao)
		Aadd(aCores, aPadrao[nX])	
	Next nX

Return(aCores)
