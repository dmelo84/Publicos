#include "RwMake.ch"
/*
Na confirmação da NF Entrada, atualiza os dados bancários no titulo do financeiro.
MATA103
*/

User Function MT100GE2
/* **************************************************************************************
*
*
*******
*/
Local aArea    := GetArea("")
Local aAreaSD1 := GetArea("SD1")

dbSelectArea("SE2")
RecLock("SE2",.F.)
	Replace	E2_FORBCO   With SA2->A2_BANCO       // Banco
	Replace E2_FORAGE   With SA2->A2_AGENCIA     // Agencia
	Replace E2_FAGEDV   With SA2->A2_DVAGE       // Digito Agencia
	Replace E2_FORCTA   With SA2->A2_NUMCON      // Conta
	Replace E2_FCTADV   With SA2->A2_DVCTA       // Digito Conta
	Replace E2_DATAAGE  With SE2->E2_VENCREA 	// VENCIMENTO REAL	
	Replace E2_XIDFLG   With SF1->F1_XIDFLG  	// ID FLUIG
	Replace E2_XTPINT   With SF1->F1_XTPINT 	// TIPO DE INTEGRAÇÃO	
	Replace E2_XTPDOC   With SF1->F1_XTPDOC 	// TIPO PGTO
	
	/*----------------------------------------
		22/05/2019 - Jonatas Oliveira - Compila
		- Caso de pagamento por deposito e 
			banco Itau atribui Forma de Pagamento 01
		- Caso seja deposito e banco diferente de Itau
			atribui Forma de Pagamento 41
		- Caso não entre em nenhuma das condições acima
			NÃo Atribui valor
	------------------------------------------*/
	// ********************************************************************
	//  20210726 - HFP - Compila  
	// **** ABAX -->  CASO ALTERE A REGRA ABAIXO, ALTERAR TAMBEM O FONTE
	//                SF1100I 
	// ********************************************************************** 
	IF SF1->F1_XTPDOC == "DEP" .OR. SF1->F1_XTPINT == "HM"
		IF SA2->A2_BANCO == "341" 			
			Replace E2_FORMPAG   With "01"
		ELSEIF !Empty(SA2->A2_BANCO)
			Replace E2_FORMPAG   With "41"
		ELSE	
			Replace E2_FORMPAG   With ""
		ENDIF 	
	ELSE
		Replace E2_FORMPAG   With ""
	ENDIF 
	
SE2->(MsUnlock())


RestArea(aAreaSD1)
RestArea(aArea)

Return()
