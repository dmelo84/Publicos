#include 'protheus.ch'
#include 'parmtype.ch'


/*/{Protheus.doc} MT100CLA
Este ponto de entrada é chamado logo após a 
chamada da função de Classificacao da Nota fiscal no MATA100
Atribui variável da condição de pagamento 
@author Jonatas Oliveira | www.compila.com.br
@since 08/02/2019
@version 1.0
/*/
User Function MT100CLA()
	IF !EMPTY(SF1->F1_COND)
		cCondicao := SF1->F1_COND
	ENDIF 
Return()