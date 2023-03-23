

/*/{Protheus.doc} F470ALLF
Este ponto de entrada permite a sinaliza��o de que deve ser feito o  tratamento do extrato utilizando o filtro da filial corrente.A rotina de Extrato Bancario disp�e de tratamentos para que a filial do SE5 n�o seja filtrada caso quando 'SA6 exclusivo' e 'SE5 compartilhado'. Esse controle � feito garantir a integridade do Extrato Banc�rio.No entanto,  o cliente pode utilizar suas tabelas nessa configura��o e ainda assim ter somente 1 filial ou todos os movimentos banc�rios na mesma filial. Para tal, foi disponibilizado um Ponto de Entrada para que possa ser sinalizado que quer o tratamento do extrato utilizando o filtro da filial corrente.
O PE � chamado antes de montar as querys da rotina FINR470.
@author Augusto Ribeiro | www.compila.com.br
@since 03/02/2020
@version version
@param param
@return lAllFil(logico), Deve informar se o sistema n�o vai filtrar por filial - considerando todas as filiais (.T.) ou vai filtrar por filial - considerando somente os registros da filial corrente(.F.)
@example
(examples)
@see (links_or_references)
/*/
User function F470ALLF()


Return(.t.)