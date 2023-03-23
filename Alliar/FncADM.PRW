#include "PROTHEUS.CH"

User Function FncADMVl(aAdmissao, cMsg)
	Local nRetorno := 1
	
Return (nRetorno)

User Function FncADMSq(aAdmissao)
	Local cSeq := ""
	
	cAliasQry := GetNextAlias()
	cQuery := " SELECT MAX(SRA.RA_MAT) AS MATRICULA "
	cQuery += "  FROM " + RetSqlName("SRA")+" SRA "
	cQuery += " WHERE SRA.RA_FILIAL = '" + aAdmissao:RA_FILIAL + "'"
	cQuery += "   AND SRA.D_E_L_E_T_ <> '*' "

	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)  

	dbSelectArea(cAliasQry)
	dbGoTop()

	If !(cAliasQry)->(Eof())
		//Sequencial
		If Empty((cAliasQry)->MATRICULA)
			cSeq := PADL("1", 06, "0")
		Else
			//Incrementa Sequencial
			cSeq := Soma1((cAliasQry)->MATRICULA)
		Endif 
	Else
		cSeq := PADL("1", 06, "0")   
	Endif
	
	(cAliasQry)->(dbCloseArea())
	
Return (cSeq)