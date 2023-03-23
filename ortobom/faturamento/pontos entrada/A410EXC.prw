#include 'Protheus.ch'

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  � A410EXC  �Autor  � Adriano Dourado    � Data �  19/07/18   ���
�������������������������������������������������������������������������͹��
���Desc.     � Valida��o de Romaneio para exclus�o do pedido de venda.    ���
���          �  19/07/2018 - SSI 63573                                    ���
���          �                                                            ���
�������������������������������������������������������������������������͹��
���Uso       � Ortobom                                                    ���
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/

User Function A410EXC()

Local lRet		:= .T.                                                                            
Local cPedido	:= SC5->C5_NUM
Local cQuery  	:= " "
Local QRY		:= GetNextAlias()

if cEmpAnt == "21"

	cQuery := " SELECT NUMROMAN, CLIFORN, LOJA, VENDEDOR, TRANSPORT  "
	cQuery += "   FROM SIGA.CABROM210 "
	cQuery += " WHERE NUMPV = '"+cPedido+"' "
	cQuery += "   AND FILIAL = '"+XFILIAL("SC5")+"' "
		
	If Select(QRY) > 0
		(QRY)->(dbCloseArea())
	EndIf

	dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),QRY,.F.,.T.)
	(QRY)->(dbGoTop())
	If (QRY)->(!EOF())
		MsgStop("N�o � poss�vel excluir pedido com ROMANEIO vinculado. Verifique!")
		lRet := .F.
	Endif

	If Select(QRY) > 0
		(QRY)->(dbCloseArea())
	EndIf

else

	lRet := .T.
	
endif

Return(lRet)
