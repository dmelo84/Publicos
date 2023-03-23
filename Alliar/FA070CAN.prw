#Include "Protheus.Ch"
#Include "rwmake.Ch"
#Include "TopConn.Ch"




/*/{Protheus.doc} FA070CAN
O ponto de entrada FA070CAN sera executado apos gravacao dos dados de cancelamento no SE1 e antes de estornar os dados do SE5 e de comissao.
@author Augusto Ribeiro | www.compila.com.br
@since 30/10/2017
@version 6
@param PARAMIXB = nValor
@example
(examples)
@see (links_or_references)
/*/
User Function FA070CAN(aParam)

/*------------------------------------------------------ Augusto Ribeiro | 30/10/2017 - 5:40:58 PM
	BAIXA CARTAO DE CREDITO
	Estorno da baixa
------------------------------------------------------------------------------------------*/
U_CP11ESTF("SE1", SE1->(RECNO()), SE5->E5_MOTBX, SE5->E5_VALOR)

Return()