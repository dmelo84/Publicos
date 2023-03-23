#include "PROTHEUS.CH"
#include "RWMAKE.CH"
#include "APWEBSRV.CH"
#include "TOPCONN.CH"

User Function FncBNFVl(aBeneficio, cMsg)
	Local nRetorno := 1
	
	//Valida se já existe o registro
	if (aBeneficio:OPERACAO == 3) 
		if (U_RegExiste("SR0", aBeneficio:R0_FILIAL + aBeneficio:R0_MAT + aBeneficio:R0_CODIGO + aBeneficio:R0_TPVALE, 1))
			nRetorno := 3 //Erro
			cMsg     := "Benefício já cadastrado para a matrícula"
		
			Return (nRetorno)
		endif
	endif
	
	//Valida Matricula
	if (!Empty(aBeneficio:R0_MAT)) .AND.;
	   (U_RegExiste("SRA", aBeneficio:R0_FILIAL + aBeneficio:R0_MAT)) .AND.;
	   (Val(aBeneficio:R0_MAT) > 0)
	else
		nRetorno := 3 //Erro
		cMsg     := "R0_MAT inválida"
		
		Return(nRetorno)
	endif
	
	if aBeneficio:R0_QDIAINF < 0
		nRetorno := 3 //Erro
		cMsg     := "R0_QDIAINF deve ser positivo"
		
		Return(nRetorno)
	endif
	
	if aBeneficio:R0_QDNUTIL < 0
		nRetorno := 3 //Erro
		cMsg     := "R0_QDNUTIL deve ser positivo"
		
		Return(nRetorno)
	endif
	
Return (nRetorno)