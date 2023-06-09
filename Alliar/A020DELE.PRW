/*
+----------+----------+-------+---------------------+-----+-----------------+
|Programa  |A020DELE  |Autor  |                                             |
+----------+----------+-------+---------------------+-----+-----------------+
|Desc.     |Ponto de Entrada na exclus�o do fornecedor para excluir automa- |
|          |ticamente o item contabil a partir do c�digo e loja do mesmo.   |
+----------+----------------------------------------------------------------+
|            ALTERACOES REALIZADAS DESDE A CRIACAO                          |
+----------+-------------+--------------------------------------------------+
| DATA     | PROGRAMADOR | DESCRICAO                                        |
+----------+-------------+--------------------------------------------------+
|          |             |                                                  |
+----------+-------------+--------------------------------------------------+
*/

#include "rwmake.ch"

User Function A020DELE()


dbSelectArea("CTD")
dbSetOrder(1)
             
If dbseek(xFilial("CTD")+ "F" + ALLTRIM(SA1->A1_COD) + SA1->A1_LOJA)
	Reclock("CTD",.F.)
	dbDelete()
	MsUnlock("CTD")
EndIf

Return(.T.)
