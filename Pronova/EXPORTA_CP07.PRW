#Include "Protheus.Ch"
#Include "rwmake.Ch"
#Include "Tbiconn.Ch"



/*/{Protheus.doc} ${CP07_PRJ}
Exporta SX's do projeto CP07 | Reembolso de Despesa
@author Augusto Ribeiro | www.compila.com.br
@since 09/12/2014
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
USER Function CP07_PRJ()
Local cDrive		:= "CTREECDX"//"DBFCDX" "CTREECDX"
Local cExt			:= IIF(cDrive == "CTREECDX", ".dtc", ".dbf")
Local aAlias		:= {}
Local aCampos		:= {}
Local aGatilhos	:= {}
Local aChvSX6		:= {} 
Local aConsPad	:= {}
Local aAliasDados	:= {}
Local cPrefixo	:= "reembolso_" 
Local cDestino	:= "\data\CP07_REEMBOLSO\"

	AADD(aAlias, "Z08")
	AADD(aAlias, "ZA0")
	AADD(aAlias, "ZA1")
	AADD(aAlias, "ZA2")
	AADD(aAlias, "ZA3")
	AADD(aAlias, "ZA4")
	AADD(aAlias, "ZA5")
	AADD(aAlias, "ZA6")
	AADD(aAlias, "ZA7")
	AADD(aAlias, "ZA8")
	//AADD(aAlias, "ZA9")
	AADD(aAlias, "ZAA")
	AADD(aAlias, "ZAB")
	AADD(aAlias, "ZAC")
	AADD(aAlias, "ZAD")
	AADD(aAlias, "ZAE")
		
	
	aadd(aGatilhos, {"ZA0_CODIGO", "001"})
	aadd(aGatilhos, {"ZA0_CODFOR", "001"})
	aadd(aGatilhos, {"ZA0_LOJFOR", "001"})
	aadd(aGatilhos, {"ZA1_CODPRO", "001"})
	aadd(aGatilhos, {"ZA1_CODPRO", "002"})	
	aadd(aGatilhos, {"ZA1_CODPRO", "003"})
	//aadd(aGatilhos, {"ZA1_CODPRO", "004"})
	aadd(aGatilhos, {"ZA1_CODNAT", "001"})
	aadd(aGatilhos, {"ZA1_CODNAT", "002"})
	aadd(aGatilhos, {"ZA1_CODNAT", "003"})
	aadd(aGatilhos, {"ZA1_QTDE", 	"001"})	
	aadd(aGatilhos, {"ZA1_VLRUNI", "001"})	
	aadd(aGatilhos, {"ZA3_ALIAS", "001"})
	aadd(aGatilhos, {"ZA3_ALIAS", "002"})
	aadd(aGatilhos, {"ZA3_ALIAS", "003"})
	aadd(aGatilhos, {"ZA3_ALIAS", "004"})
	aadd(aGatilhos, {"ZA5_TABPRE", "001"})
	aadd(aGatilhos, {"ZA5_CONPAG", "001"})
	aadd(aGatilhos, {"ZA6_CODUSR", "001"})
	aadd(aGatilhos, {"ZA7_CODGRP", "001"})		
	aadd(aGatilhos, {"ZA7_CODPRO", "001"})
	aadd(aGatilhos, {"ZA8_ALIAS", "001"})
	aadd(aGatilhos, {"ZAB_CODPRO", "001"})
	aadd(aGatilhos, {"ZAE_USRVIN", "001"})
	aadd(aGatilhos, {"ZA1_CODUSR", "001"})
	
	
	aadd(aConsPad, "CP0701")
	aadd(aConsPad, "CP0702")
	aadd(aConsPad, "CP0703")
	aadd(aConsPad, "CP0704")
	aadd(aConsPad, "ZA0")
	aadd(aConsPad, "ZAA")
	aadd(aConsPad, "ZA5")
	
	
	aadd(aAliasDados, "Z08")
	

/*	                                               	
	aadd(aCampos, "A1_CODUNID")	
	

	aadd(aCampos, "Z64_MOTCAN")

	aadd(aCampos, "A5_CODPRF")
	aadd(aCampos, "E2_XSTATUS")
	aadd(aCampos, "F1_CHVNFE")	
	aadd(aCampos, "F1_XCNFOBS")	
	aadd(aCampos, "F1_XNFOBS")
	
	aadd(aChvSX6, "  MQ_XMLDEST")

	                       
	aadd(aConsPad, "ZA7")	
	
	CP03SX7
	
	
	//aadd(aGatilhos, {"CAMPO", "SEQUENCIA"})

	                              */   
	                              
	                              
	_cEmp		:= "99"
	_cFilial	:= "01"
	PREPARE ENVIRONMENT EMPRESA _cEmp FILIAL _cFilial

//		cFullPath	:= cDestino+cPrefixo+"six"+cExt
//		U_CP03SIX(cDrive, cFullPath, aAlias)
//		
//		cFullPath	:= cDestino+cPrefixo+"sx2"+cExt
//		U_CP03SX2(cDrive, cFullPath, aAlias)
//
//		cFullPath	:= cDestino+cPrefixo+"sx3"+cExt
//		U_CP03SX3(cDrive, cFullPath, aAlias, aCampos)

//		cFullPath	:= cDestino+cPrefixo+"sx6"+cExt
//		U_CP03SX6(cDrive, cFullPath, aChvSX6)


//		cFullPath	:= cDestino+cPrefixo+"sx7"+cExt
//		U_CP03SX7(cDrive, cFullPath, aGatilhos)

		cFullPath	:= cDestino+cPrefixo+"sxb"+cExt
		U_CP03SXB(cDrive, cFullPath, aConsPad)
		
//		FOR nI := 1 to len(aAliasDados)
//			cFullPath	:= cDestino+cPrefixo+"dados_"+aAliasDados[nI]+cExt
//			U_CP03DADOS(cDrive, cFullPath, aAliasDados[nI])		
//		NEXT		
//		
		
	RESET ENVIRONMENT
Return                
