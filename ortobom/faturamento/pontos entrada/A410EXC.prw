#include 'Protheus.ch'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ A410EXC  ºAutor  ³ Adriano Dourado    º Data ³  19/07/18   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Validação de Romaneio para exclusão do pedido de venda.    º±±
±±º          ³  19/07/2018 - SSI 63573                                    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Ortobom                                                    º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
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
		MsgStop("Não é possível excluir pedido com ROMANEIO vinculado. Verifique!")
		lRet := .F.
	Endif

	If Select(QRY) > 0
		(QRY)->(dbCloseArea())
	EndIf

else

	lRet := .T.
	
endif

Return(lRet)
