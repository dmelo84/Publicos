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
Antonio 		12/11/15	Altera��o fun��o SOMAABAT para a vers�o 12.

*/
//-------------------------------------------------------------------------------------------------------------------------------------------------

User Function nCNAB02()

Local  nVlrPrinc := 0
Local  nAbatim   := 0
Local  nVlrTot   := 0
                             
nVlrPrinc  := SE2->E2_SALDO
//nAbatim	   := SOMAABAT(SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,"P",1,SE2->E2_MOEDA,SE2->E2_FORNECE,SE2->E2_LOJA) // Retirado 12/11/15

nAbaTim   := SomaAbat(SE2->E2_PREFIXO,SE2->E2_NUM,SE2->E2_PARCELA,"P",SE2->E2_MOEDA,,SE2->E2_FORNECE,SE2->E2_LOJA) // Mudan�a para a vers�o 12
          
nVlrTot    := STRZERO(((nVlrPrinc - nAbaTim)+SE2->E2_SDACRES-SE2->E2_SDDECRE)*100,15)


Return(nVlrTot)
 