#include "rwmake.ch"



//-------------------------------------------------------------------------------------------------------------------------------------------------
/*
@author Daiana Andrade
@since 09/01/2012
@version P11
@Param N�o Possui
@Return cTrb
@obs
Fun��o criada para montar valor do t�tulo a receber para considerar os abatimentos, acr�scimos e decr�scimos.

Alteracoes Realizadas desde a Estruturacao Inicial
Programador     Data       Motivo

*/
//-------------------------------------------------------------------------------------------------------------------------------------------------

User Function nCNAB01()

Local  nVlrPrinc := 0
Local  nAbatim   := 0
Local  nVlrTot   := 0

nVlrPrinc  := SE1->E1_VLCRUZ

nAbatim	   := SOMAABAT(SE1->E1_PREFIXO,SE1->E1_NUM,SE1->E1_PARCELA,"R",1,SE1->E1_MOEDA,SE1->E1_CLIENTE,SE1->E1_LOJA)
           
nVlrTot    := STRZERO(((nVlrPrinc - nAbatim)+SE1->E1_SDACRES-SE1->E1_SDDECRE)*100,13)



Return(nVlrTot)
 