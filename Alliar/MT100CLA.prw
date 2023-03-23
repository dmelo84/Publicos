#include 'protheus.ch'
#include 'parmtype.ch'


/*/{Protheus.doc} MT100CLA
Este ponto de entrada � chamado logo ap�s a 
chamada da fun��o de Classificacao da Nota fiscal no MATA100
Atribui vari�vel da condi��o de pagamento 
@author Jonatas Oliveira | www.compila.com.br
@since 08/02/2019
@version 1.0
/*/
User Function MT100CLA()
	IF !EMPTY(SF1->F1_COND)
		cCondicao := SF1->F1_COND
	ENDIF 
Return()