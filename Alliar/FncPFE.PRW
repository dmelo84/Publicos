#include "PROTHEUS.CH"

User Function FncPFEVl(aProgramacaoFerias, cMsg)
	Local nRetorno := 1
	
	//Valida se j� existe o registro
	if (aProgramacaoFerias:OPERACAO == 3) 
		if (U_RegExiste("SRF", aProgramacaoFerias:RF_FILIAL + aProgramacaoFerias:RF_MAT + DTOS(aProgramacaoFerias:RF_DATABAS), 1))
			nRetorno := 3 //Erro
			cMsg     := "Programa��o de F�rias j� cadastrada para a matr�cula nesta data"
		
			Return (nRetorno)
		endif
	endif
	
	//Valida Tem Abono Pecuniario
	if !aProgramacaoFerias:RF_TEMABPE $ "S|N"
	else
		nRetorno := 3 //Erro
		cMsg     := "RF_TEMABPE inv�lido"
		
		Return (nRetorno)
	endif
	
	//Valida Matricula
	if (!Empty(aProgramacaoFerias:RF_MAT)) .AND.;
	   (U_RegExiste("SRA", aProgramacaoFerias:RF_FILIAL + aProgramacaoFerias:RF_MAT, 1)) .AND.;
	   (Val(aProgramacaoFerias:RF_MAT) > 0)
	else
		nRetorno := 3 //Erro
	    cMsg     := "R8_MAT inv�lida"
		
		Return(nRetorno)
    endif
		
	//Valida Dias de Abono
	if (aProgramacaoFerias:RF_DABPRO1 > -1)
	else
		nRetorno := 3 //Erro
	    cMsg     := "RF_DABPRO1 inv�lido"
		
	    Return(nRetorno)
	endif
	
	//Valida quantidade de dias de f�rias
	if aProgramacaoFerias:RF_DABPRO1 > 0 .AND.;
	   aProgramacaoFerias:RF_DABPRO1 > 30
	   nRetorno := 3 //Erro
	   cMsg     := "A quantidade de dias de f�rias e dias de abono da primeira programa��o ultrapassa 30 dias."
	   
	   Return(nRetorno)	
    endif
	
Return (nRetorno)