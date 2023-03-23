

User Function MT220GRV()

	/*
	Somente será executado quando for chamado pela rotina abaixo.
	*/
	
	IF FUNNAME() == "ALMTA220"
	
		CONOUT("### MT220GRV")
		A220AtuSD5(SB9->B9_COD, SB9->B9_LOCAL)
		
	ENDIF
	
Return()