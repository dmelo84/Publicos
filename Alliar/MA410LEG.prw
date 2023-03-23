#INCLUDE "TOTVS.CH"
#INCLUDE "RWMAKE.CH"
#INCLUDE "WINAPI.CH"
#INCLUDE "COLORS.CH"



// Incrementa Cores Customizadas a legenda padrao do Ped. Vendas
User Function MA410LEG() 
	Local aCores	:= {}
	Local aPadrao	:= aClone(ParamIxb)
	Local nX		:= 0 

	Aadd(aCores, {"BR_CINZA"	, "Bloq.: Cadastro NOVO Cliente" })
	Aadd(aCores, {"BR_MARROM"	, "Bloq.: Cliente com tributo VARIAVEL"  })
	Aadd(aCores, {"BR_BRANCO"	, "Bloq.: Sem VALOR dos tributos retidos"  })
	Aadd(aCores, {"BR_LARANJA"	, "Bloq.: Pedido NÃO possui retenções"})
	Aadd(aCores, {"BR_AZUL"		, "Bloq.: NF Cancelada"})
	Aadd(aCores, {"BR_PRETO"	, "Bloq.: Emitindo NF"})
	Aadd(aCores, {"BR_PINK"		, "Bloq.: Aguard Complemento Fluig"})

	For nX:= 1 to Len(aPadrao)
		Aadd(aCores, aPadrao[nX])	
	Next nX

Return(aCores)
