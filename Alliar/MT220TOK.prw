


User Function MT220TOK()

	Local lRet		:= .T.
	
	/*
	Somente será executado quando for chamado pela rotina abaixo.
	*/
	
	IF FUNNAME() == "ALMTA220" .AND. lRet
	
		IF VALTYPE(_xSD5Itens) == "A"
		
			aLotesIni := aClone(_xSD5Itens)	
		
		ENDIF
		
	ENDIF

Return(lRet)