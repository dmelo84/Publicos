/*
As mensagens que exigem algum tipo de complexidade, como: a Lei da Transparência,
Cupom Mania e Nota Legal, são desenvolvidas pela TOTVS para auxiliar o cliente
no atendimento da legislação. As mensagens apenas informativas, como por exemplo: 
o número do Procon, devem ser configuradas pelo cliente.

Existem diversas maneiras de realizar esse procedimento:
- Parâmetro que é macro executado na impressão: MV_LJFISMS
- Configuração no cadastrado de estação: SLG->LG_MSGCUP
- Se NFC-e, quando a mensagem deve ser enviada no XML para o Sefaz 
(Exemplo: Número de Equipamento Eletrônico para efeito de Garantia), ou seja, 
constar na consulta na Sefaz, deve utilizar o PE:
*/
#INCLUDE "TOTVS.CH" 

User Function LJ7085() 

	Local aRet := {} 

	Aadd( aRet, Array(2) ) 
	aRet[1][1] := NiL 
	aRet[1][2] := "Número do Orçamento: " + SL1->L1_NUM