#include "PROTHEUS.CH"

User Function FncPFEVl(aProgramacaoFerias, cMsg)
	Local nRetorno := 1
	
	//Valida se já existe o registro
	if (aProgramacaoFerias:OPERACAO == 3) 
		if (U_RegExiste("SRF", aProgramacaoFerias:RF_FILIAL + aProgramacaoFerias:RF_MAT + DTOS(aProgramacaoFerias:RF_DATABAS), 1))
			nRetorno := 3 //Erro
			cMsg     := "Programação de Férias já cadastrada para a matrícula nesta data"
		
			Return (nRetorno)
		endif
	endif
	
	//Valida Tem Abono Pecuniario
	if !aProgramacaoFerias:RF_TEMABPE $ "S|N"
	else
		nRetorno := 3 //Erro
		cMsg     := "RF_TEMABPE inválido"
		
		Return (nRetorno)
	endif
	
	//Valida Matricula
	if (!Empty(aProgramacaoFerias:RF_MAT)) .AND.;
	   (U_RegExiste("SRA", aProgramacaoFerias:RF_FILIAL + aProgramacaoFerias:RF_MAT, 1)) .AND.;
	   (Val(aProgramacaoFerias:RF_MAT) > 0)
	else
		nRetorno := 3 //Erro
	    cMsg     := "R8_MAT inválida"
		
		Return(nRetorno)
    endif
		
	//Valida Dias de Abono
	if (aProgramacaoFerias:RF_DABPRO1 > -1)
	else
		nRetorno := 3 //Erro
	    cMsg     := "RF_DABPRO1 inválido"
		
	    Return(nRetorno)
	endif
	
	//Valida quantidade de dias de férias
	if aProgramacaoFerias:RF_DABPRO1 > 0 .AND.;
	   aProgramacaoFerias:RF_DABPRO1 > 30
	   nRetorno := 3 //Erro
	   cMsg     := "A quantidade de dias de férias e dias de abono da primeira programação ultrapassa 30 dias."
	   
	   Return(nRetorno)	
    endif
	
Return (nRetorno)