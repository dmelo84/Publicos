#include 'protheus.ch'
#include 'parmtype.ch'

/*------------------------------------------------------
|Ponto de Entrada - Gravação de campo na SE1 depois da  |
|efetivação da venda                                    |
|Desenvolvedor Diogo Melo                               |
|Data: 26/06/2019                                       |
--------------------------------------------------------*/

User Function LJRECSE1()

	Local aSE1:= PARAMIXB[1]  //dados que foram inclusos na SE1.
	Local aTit:=PARAMIXB[2] // dados do título recebido.

Return