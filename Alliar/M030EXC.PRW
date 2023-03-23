/*
+----------+----------+-------+---------------------+-----+-----------------+
|Programa  |M030EXC   |Autor  |                                             |
+----------+----------+-------+---------------------+-----+-----------------+
|Desc.     |Ponto de Entrada na exclusão do cliente para excluir automati-  |
|          |camente o item contabil a partir do código e loja do mesmo.     |
+----------+----------------------------------------------------------------+
|            ALTERACOES REALIZADAS DESDE A CRIACAO                          |
+----------+-------------+--------------------------------------------------+
| DATA     | PROGRAMADOR | DESCRICAO                                        |
+----------+-------------+--------------------------------------------------+
|          |             |                                                  |
+----------+-------------+--------------------------------------------------+
*/

#include "rwmake.ch"

User Function M030EXC()


dbSelectArea("CTD")
dbSetOrder(1)
If dbseek(xFilial("CTD")+"C" + ALLTRIM(SA1->A1_COD) + SA1->A1_LOJA)
	Reclock("CTD",.F.)
	dbDelete()
	MsUnlock("CTD")
EndIf

Return
