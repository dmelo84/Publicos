#include "PROTHEUS.CH"

User Function FncPNFVl(aPNFEntrada, cMsg)
	Local nRetorno := 1
	Local nCount
	
	if aPNFEntrada:OPERACAO == 3
		if (U_RegExiste("SF1", aPNFEntrada:F1_FILIAL + aPNFEntrada:F1_DOC + aPNFEntrada:F1_SERIE, 1))
			nRetorno := 3 //Erro
			cMsg     := "Pre-NF Entrada já cadastrada."
			Return (nRetorno)
		endif
	endif
	
	if !(aPNFEntrada:F1_TIPO $ "N|D|I|P|B|C")  
		cMsg := "Valor do campo F1_TIPO deverá ser igual a N, D, I, P, B ou C."
		nRetorno := 3 //Erro
		Return nRetorno
	endif
	
	if !NaoVazio(aPNFEntrada:F1_FORMUL) .OR.;
	   !(aPNFEntrada:F1_FORMUL $ "S|N")  
	   cMsg := "Valor do campo F1_FORMUL deverá ser igual a S ou N."
	   nRetorno := 3 //Erro
	   Return nRetorno
	endif
	
	if !NaoVazio(aPNFEntrada:F1_EMISSAO)		
		cMsg := "Valor do campo F1_EMISSAO deve ser válido."
		nRetorno := 3 //Erro
		Return nRetorno
	endif
	
	For nCount := 1 to Len(aPNFEntrada:ITEM)
		if !NaoVazio(aPNFEntrada:ITEM[nCount]:D1_COD) .OR.;
		   !U_RegExiste("SB1", xFilial("SB1", aPNFEntrada:F1_FILIAL) + aPNFEntrada:ITEM[nCount]:D1_COD, 1)
		   cMsg := "Valor do campo D1_COD deverá ser válido."
		   nRetorno := 3 //Erro
		   Return nRetorno
		endif
		
		if !U_RegExiste("SAH",xFilial("SAH", aPNFEntrada:F1_FILIAL) + aPNFEntrada:ITEM[nCount]:D1_UM, 1)
			cMsg := "Valor do campo D1_UM deve ser válido."
			nRetorno := 3 //Erro
			Return nRetorno
		endif
		
		if !NaoVazio(aPNFEntrada:ITEM[nCount]:D1_QUANT) .OR.;
		   !aPNFEntrada:ITEM[nCount]:D1_QUANT > -1
			cMsg := "Valor do campo D1_QUANT deve ser informado."
			nRetorno := 3 //Erro
			Return nRetorno
		endif
		
		if !NaoVazio(aPNFEntrada:ITEM[nCount]:D1_VUNIT) .OR.;
		   !aPNFEntrada:ITEM[nCount]:D1_VUNIT > -1
			cMsg := "Valor do campo D1_VUNIT deve ser informado."
			nRetorno := 3 //Erro
			Return nRetorno
		endif
		
		if !NaoVazio(aPNFEntrada:ITEM[nCount]:D1_TOTAL) .OR.;
		   !aPNFEntrada:ITEM[nCount]:D1_TOTAL > -1
			cMsg := "Valor do campo D1_TOTAL deve ser informado."
			nRetorno := 3 //Erro
			Return nRetorno
		endif
		
		if !NaoVazio(aPNFEntrada:ITEM[nCount]:D1_PEDIDO) .OR.;
		   !U_RegExiste("SC7",aPNFEntrada:F1_FILIAL + aPNFEntrada:ITEM[nCount]:D1_PEDIDO, 1)
			cMsg := "Valor do campo D1_PEDIDO deve ser válido."
			nRetorno := 3 //Erro
			Return nRetorno
		endif
		
		if !NaoVazio(aPNFEntrada:ITEM[nCount]:D1_LOTECTL) .AND.;
		   FnLoteObr(aPNFEntrada:F1_FILIAL, aPNFEntrada:ITEM[nCount]:D1_COD)
		    cMsg := "Valor do campo D1_LOTECTL deve ser informado."
		    nRetorno := 3 //Erro
			Return nRetorno
		endif
		
	Next nCount
	                                                                                                          
Return (nRetorno)

Static Function FnLoteObr(cF1_FIL, cD1_COD)
	Local lObr := .F.
	
	dbSelectArea("SB1")
	SB1->(DbSetOrder(1))
		
	if SB1->(dbSeek(xFilial("SB1" ,cF1_FIL) + cD1_COD)) 
		if SB1->B1_RASTRO = "L" 
			lObr := .T.
		endif
	endif
	
Return lObr