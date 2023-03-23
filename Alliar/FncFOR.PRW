#include "PROTHEUS.CH"

User Function CadDBFor(aFornecedor, cA2_COD, cA2_LOJA)
Local nOpcao

	nOpcao := aFornecedor:OPERACAO
	    
	dbSelectArea("FIL")
	
	Do Case		
		//Inclusão
		Case (nOpcao == 3)
			dbSelectArea("FIL")
			dbSetOrder(1)      
			If !FIL->(dbSeek(xFilial("FIL") + cA2_COD + cA2_LOJA))		
				FIL->(RECLOCK("FIL", .T.))
	
				FIL->FIL_FILIAL := xFilial("FIL")
				FIL->FIL_FORNEC := cA2_COD
				FIL->FIL_LOJA   := cA2_LOJA
				FIL->FIL_BANCO  := aFornecedor:A2_BANCO
				FIL->FIL_AGENCI := aFornecedor:A2_AGENCIA
				FIL->FIL_DVAGE  := aFornecedor:A2_DVAGE
				FIL->FIL_CONTA  := aFornecedor:A2_NUMCON
				FIL->FIL_DVCTA  := aFornecedor:A2_DVCTA
				FIL->FIL_TIPO   := "1"
				FIL->FIL_DETRAC := "0"
				FIL->FIL_MOEDA  := 1
				FIL->FIL_TIPCTA := aFornecedor:FIL_TIPCTA
				FIL->(MSUNLOCK())
			EndIf
			
		//Alteração	
		Case (nOpcao == 4)
			dbSelectArea("FIL")
	        dbSetOrder(1)      
	        
	        if FIL->(dbSeek(xFilial("FIL") + cA2_COD + cA2_LOJA))
	        	RECLOCK("FIL", .F.)
        	
	        	FIL->FIL_FILIAL := xFilial("FIL")
	        	FIL->FIL_FORNEC := cA2_COD
	        	FIL->FIL_LOJA   := cA2_LOJA
	        	FIL->FIL_BANCO  := aFornecedor:A2_BANCO
	        	FIL->FIL_AGENCI := aFornecedor:A2_AGENCIA
	        	FIL->FIL_DVAGE  := aFornecedor:A2_DVAGE
	        	FIL->FIL_CONTA  := aFornecedor:A2_NUMCON
	        	FIL->FIL_DVCTA  := aFornecedor:A2_DVCTA
	        	FIL->FIL_TIPO   := "1"
	        	FIL->FIL_DETRAC := "0"
	        	FIL->FIL_MOEDA  := 1
	        	FIL->FIL_TIPCTA := aFornecedor:FIL_TIPCTA
    
	        	//Destrava o registro
	        	FIL->(MSUNLOCK())     
	        endif
	        
	    //Exclusão
	    Case (nOpcao == 5)
	    	dbSelectArea("FIL")
			FIL->(DbSetOrder(1))
	    	
			//Busca exata para deletar os dependentes
			if FIL->(dbSeek(xFilial("FIL") + cA2_COD + cA2_LOJA)) 
				FIL->(RecLock("FIL"))
				FIL->(DbDelete())
				FIL->(MsUnlock())
			endif
	EndCase	
	
Return .T.

User Function FncFORSq(aFornecedor) 
	Local cA2_COD := ""
	
	if (aFornecedor:A2_TIPO == 'J') .AND.;
	   (aFornecedor:OPERACAO == 3)  .AND.;
	   (Trim(aFornecedor:A2_EST) = "EX")
	   
	   cAliasQry := GetNextAlias()
	   cQuery := " SELECT MAX(CAST(SA2.A2_COD AS NUMERIC)) + 1 INCREMENTO "
	   cQuery += "   FROM " + RetSqlName("SA2")+" SA2 "
	   cQuery += "  WHERE SA2.A2_FILIAL = '" + xFilial("SA2") + "'"
	   cQuery += "    AND SA2.A2_EST = '" + Trim(aFornecedor:A2_EST) + "'"
	   cQuery += "    AND SA2.D_E_L_E_T_ <> '*' "

	   cQuery := ChangeQuery(cQuery)
	   dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)  

	   dbSelectArea(cAliasQry)
	   dbGoTop()
	
	   If !Eof()	
	   		if Empty((cAliasQry)->INCREMENTO)
	   			cA2_COD := PADL("1", 08, "0")
	   		else
	   			cA2_COD := PADL(cVALTOCHAR((cAliasQry)->INCREMENTO), 08, "0") 
	   		endif
	   else
	   		cA2_COD := cA2_COD := PADL("1", 08, "0")
	   endif
	
	   (cAliasQry)->(dbCloseArea())
	   
	endif
		
	if (aFornecedor:A2_TIPO == 'J')
		if (aFornecedor:OPERACAO == 3) .AND.;
		   (Trim(aFornecedor:A2_EST) = "EX")
		   cA2_COD := cA2_COD 
		else
		   cA2_COD  := SUBSTR(aFornecedor:A2_CGC, 1, 8)
		endif
	else
		cA2_COD  := SUBSTR(aFornecedor:A2_CGC, 1, 8) 
	endif
	
Return (cA2_COD)

User Function FncFORLj(aFornecedor) 
	Local cA2_LOJA := ""
	
	if (aFornecedor:A2_TIPO == 'J')
		if (aFornecedor:OPERACAO == 3) .AND.;
		   (Trim(aFornecedor:A2_EST) = "EX")
		    cA2_LOJA := "0001" 
		else
			cA2_LOJA := SUBSTR(aFornecedor:A2_CGC, 9, 4)
		endif
	else
		cA2_LOJA := SUBSTR(aFornecedor:A2_CGC, 9, 3)
	endif
	
Return (cA2_LOJA)
