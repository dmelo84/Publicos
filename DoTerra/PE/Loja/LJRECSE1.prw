#include 'protheus.ch'
#include 'parmtype.ch'

/*------------------------------------------------------
|Ponto de Entrada - Grava��o de campo na SE1 depois da  |
|efetiva��o da venda                                    |
|Desenvolvedor Diogo Melo                               |
|Data: 26/06/2019                                       |
--------------------------------------------------------*/

User Function LJRECSE1()

	Local aSE1:= PARAMIXB[1]  //dados que foram inclusos na SE1.
	Local aTit:=PARAMIXB[2] // dados do t�tulo recebido.

Return