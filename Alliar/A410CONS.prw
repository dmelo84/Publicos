#Include 'Protheus.ch'

/*/{Protheus.doc} A410CONS
É chamada no momento de montar a enchoicebar do pedido de vendas, 
e serve para incluir mais botões com rotinas de usuário.

@type function
@author claudiol
@since 07/04/2016
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
User Function A410CONS()

Local aBtnAdd	:= {}

AAdd(aBtnAdd,{ "Formas de pagamento Alliar", {|| U_FSFATC01() }, "Formas Alliar" } )
Aadd(aBtnAdd,{ "Impostos Alliar", {|| U_ALRFAT02() }, "Impostos Alliar" } )

Return aBtnAdd
