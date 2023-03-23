/*
As mensagens que exigem algum tipo de complexidade, como: a Lei da Transpar�ncia,
Cupom Mania e Nota Legal, s�o desenvolvidas pela TOTVS para auxiliar o cliente
no atendimento da legisla��o. As mensagens apenas informativas, como por exemplo: 
o n�mero do Procon, devem ser configuradas pelo cliente.

Existem diversas maneiras de realizar esse procedimento:
- Par�metro que � macro executado na impress�o: MV_LJFISMS
- Configura��o no cadastrado de esta��o: SLG->LG_MSGCUP
- Se NFC-e, quando a mensagem deve ser enviada no XML para o Sefaz 
(Exemplo: N�mero de Equipamento Eletr�nico para efeito de Garantia), ou seja, 
constar na consulta na Sefaz, deve utilizar o PE:
*/
#INCLUDE "TOTVS.CH" 

User Function LJ7085() 

	Local aRet := {} 

	Aadd( aRet, Array(2) ) 
	aRet[1][1] := NiL 
	aRet[1][2] := "N�mero do Or�amento: " + SL1->L1_NUM