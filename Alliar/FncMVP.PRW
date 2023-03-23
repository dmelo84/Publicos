#include "PROTHEUS.CH"

User Function FncMVPVl(aMovPessoal ,cMsg)
	Local nRetorno := 0
	
	if !U_RegExiste("SRA" ,xFilial("SRA" ,aMovPessoal:RA_FILIAL) + aMovPessoal:RA_MAT ,1)
		cMsg     := "Funcionario nao cadastrado!"
		nRetorno := 3 //Erro
		Return nRetorno
	endif
	
	if !U_RegExiste("SQ3", xFilial("SQ3", aMovPessoal:RA_FILIAL) + aMovPessoal:RA_CARGO ,1)
		cMsg     := "Cargo nao cadastrado!"
		nRetorno := 3 //Erro
		Return nRetorno
	endif
	
	if !U_RegExiste("SRJ", xFilial("SRJ", aMovPessoal:RA_FILIAL) + aMovPessoal:RJ_FUNCAO ,1)
		cMsg     := "Funcao nao cadastrada!"
		nRetorno := 3 //Erro
		Return nRetorno
	endif
	
Return (nRetorno)

User Function FncMVPSq(aMovPessoal)
	Local cSeq := "" 
	
	cAliasQry := GetNextAlias()
	cQuery := " SELECT MAX(CAST(SR7.R7_SEQ AS INTEGER)) + 1 INCREMENTO "
	cQuery += "   FROM " + RetSqlName("SR7")+" SR7 "
	cQuery += "  WHERE SR7.R7_FILIAL = '" + xFilial("SR7", aMovPessoal:RA_FILIAL) + "'"
	cQuery += "    AND SR7.R7_MAT = '" + aMovPessoal:RA_MAT + "'"
	cQuery += "    AND SR7.D_E_L_E_T_ <> '*' "  

	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)  

	dbSelectArea(cAliasQry)
	dbGoTop()
	
	If !Eof()
		//Sequencial
		if Empty((cAliasQry)->INCREMENTO)
			cSeq := PADL("1", 01, "0")
		else
			//Incrementa Sequencial
			cSeq := PADL(cVALTOCHAR((cAliasQry)->INCREMENTO), 01, "0")
		endif 
	else
		cSeq := PADL("1", 01, "0")   
	endif
	
	(cAliasQry)->(dbCloseArea())
	
Return (cSeq)

User Function FncMVPTp(aMovPessoal)
	Local cTp := "" 
	
	cAliasQry := GetNextAlias()
	cQuery := " SELECT RA_TIPOPGT "
	cQuery += "   FROM " + RetSqlName("SRA")+" SRA "
	cQuery += "  WHERE SRA.RA_FILIAL = '" + xFilial("SRA", aMovPessoal:RA_FILIAL) + "'"
	cQuery += "    AND SRA.RA_MAT = '" + aMovPessoal:RA_MAT + "'"
	cQuery += "    AND SRA.D_E_L_E_T_ <> '*' "  

	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)  

	dbSelectArea(cAliasQry)
	dbGoTop()
	
	cTp := (cAliasQry)->RA_TIPOPGT
	
	(cAliasQry)->(dbCloseArea())
	
Return (cTp)

User Function FncMVPCf(aMovPessoal)
	Local cCf := "" 
	
	cAliasQry := GetNextAlias()
	cQuery := " SELECT RA_CATFUNC "
	cQuery += "   FROM " + RetSqlName("SRA")+" SRA "
	cQuery += "  WHERE SRA.RA_FILIAL = '" + xFilial("SRA", aMovPessoal:RA_FILIAL) + "'"
	cQuery += "    AND SRA.RA_MAT = '" + aMovPessoal:RA_MAT + "'"
	cQuery += "    AND SRA.D_E_L_E_T_ <> '*' "  

	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)  

	dbSelectArea(cAliasQry)
	dbGoTop()
	
	cCf := (cAliasQry)->RA_CATFUNC
	
	(cAliasQry)->(dbCloseArea())
	
Return (cCf)