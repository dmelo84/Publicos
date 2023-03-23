#include 'Protheus.ch'

//Funcao para efetuar a consistencia dos dados
User Function FConDad(cCad, nOpcao, aDados, cMsg, nRetorno) 
	
	if cCad = "SOC"//Solicita��o de Compra 
		//Edi��o
		if (nOpcao == 4)
			cAliasQry := GetNextAlias()
			cQuery := " SELECT SC1.C1_PEDIDO,  "   
			cQuery += "        SC1.C1_RESIDUO, "
			cQuery += "        SC1.C1_FLAGGCT  "
			cQuery += "   FROM " + RetSqlName("SC1")+" SC1 "
	        cQuery += "  WHERE SC1.C1_NUM = '" + aDados:C1_NUM + "'"
	        cQuery += "    AND SC1.C1_FILIAL = '" + xFilial("SC1") + "'"
	        cQuery += "    AND SC1.D_E_L_E_T_ <> '*' "
	        cQuery += "    AND ((SC1.C1_PEDIDO  <> '') or " 
            cQuery += "         (SC1.C1_RESIDUO <> '') or "
            cQuery += "         (SC1.C1_FLAGGCT <> '')) "
	        cQuery += "  ORDER BY SC1.C1_NUM "
 
	        cQuery := ChangeQuery(cQuery)
	        dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)  

	        dbSelectArea(cAliasQry)
	        dbGoTop()
	
	        If !Eof()
	        	if !Empty((cAliasQry)->C1_PEDIDO)
					nRetorno := 3
					cMsg := "A Solicita��o de Compra " + Trim(aDados:C1_NUM) + " est� relacionada com o Pedido " + Trim((cAliasQry)->C1_PEDIDO) + " e n�o pode ser alterada."
					Return .F.
				endif
				
				if (AllTrim((cAliasQry)->C1_RESIDUO) == "S")
					nRetorno := 3
					cMsg := "A Solicita��o de Compra " + Trim(aDados:C1_NUM) + " foi eliminada pela rotina de Elimina��o de Res�duos e n�o pode ser alterada." 
					Return .F.
				endif
			
				if !(Empty((cAliasQry)->C1_FLAGGCT))
					nRetorno := 3
					cMsg := "A Solicita��o de Compra " + Trim(aDados:C1_NUM) + " est� relacionada a um Contrato e n�o pode ser alterada."
					Return .F.
				endif 
			endif
		endif
	endif

Return .T.