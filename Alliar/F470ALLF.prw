

/*/{Protheus.doc} F470ALLF
Este ponto de entrada permite a sinalização de que deve ser feito o  tratamento do extrato utilizando o filtro da filial corrente.A rotina de Extrato Bancario dispõe de tratamentos para que a filial do SE5 não seja filtrada caso quando 'SA6 exclusivo' e 'SE5 compartilhado'. Esse controle é feito garantir a integridade do Extrato Bancário.No entanto,  o cliente pode utilizar suas tabelas nessa configuração e ainda assim ter somente 1 filial ou todos os movimentos bancários na mesma filial. Para tal, foi disponibilizado um Ponto de Entrada para que possa ser sinalizado que quer o tratamento do extrato utilizando o filtro da filial corrente.
O PE é chamado antes de montar as querys da rotina FINR470.
@author Augusto Ribeiro | www.compila.com.br
@since 03/02/2020
@version version
@param param
@return lAllFil(logico), Deve informar se o sistema não vai filtrar por filial - considerando todas as filiais (.T.) ou vai filtrar por filial - considerando somente os registros da filial corrente(.F.)
@example
(examples)
@see (links_or_references)
/*/
User function F470ALLF()


Return(.t.)