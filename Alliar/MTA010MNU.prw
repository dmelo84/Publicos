#include 'protheus.ch'
#include 'parmtype.ch'


/*/{Protheus.doc}MTA010MNU
Ponto de entrada na rotina de cadastro de produtos
LOCALIZA��O : Function MenuDef - Fun��o de defini��o dos bot�es de menu	

@author Ponto de entrada Padr�o
@author Edson Melo | www.compila.com.br
@since 01/12/2016
@example
(examples)
@see (links_or_references)
/*/


user function MTA010MNU()
	Local _lRet := .T. //Vari�vel para o controle das opera��es efetuadas dentro do ponto de entrada.
	
	aAdd(aRotina,{ "Envia Produto Pleres", "U_FSESTP02()", 0 , 2, 0, .F.})
	
	_lRet := MTA010MN_1()
	
return(.T.)

static function MTA010MN_1()
	aAdd(aRotina,{"Gerar Indicadores", "U_ZMAKESBZ", 0, 4, 2, .F.})	//"Gera indicadores dos produtos"
return(.T.)