#include "rwmake.ch"

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �M020INC   �Autor  �			       � Data �  07/14/06   ���
�������������������������������������������������������������������������͹��
���Desc.     � CRIA ITEM CONTABIL A PARTIR DA INCLUSAO DO FORNEDDOR       ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � AP                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/


User Function M020INC()

Local 	cItemcont:=""

dbSelectArea("CTD")
dbSetOrder(1)
cItemcont:= "F" + ALLTRIM(SA2->A2_COD) + SA2->A2_LOJA
dbseek(xFilial("CTD")+cItemcont)
If Eof()
	dbSelectArea("CTD")
	Reclock("CTD",.T.)
	Replace CTD_FILIAL With xFilial("CTD") , ;
	CTD_ITEM   With cItemcont      , ;
	CTD_DESC01 With SA2->A2_NOME   , ;
	CTD_CLASSE With "2"            , ;
	CTD_NORMAL With "0"            , ;
	CTD_DTEXIS With ctod("01/01/1980"), ;
	CTD_BLOQ   With '2'
	MsUnlock("CTD")
	
EndIf

Return
