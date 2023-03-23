#INCLUDE "PROTHEUS.CH"

user function LJ7051//FTVD70LG

aCor := {}

Aadd(aCor, {'!Empty(SL1->L1_PEDIDO) ', "BR_LARANJA" })
U_LJ7051( 1 , @aCor )
U_LJ7051( 2 , @aCor )

//alert("passou lj7051")

Return aCor
