#include "PROTHEUS.CH"

User Function FncMVBVl(aMovimentoBancario, cA6_COD, cA6_AGENCIA, cA6_NUMCON, cMsg)
	Local nRetorno := 1
	
	if !(aMovimentoBancario:E5_VALOR) > -1
		cMsg := "Valor do campo E5_VALOR deve ser positivo."
		nRetorno := 3 //Erro
		Return nRetorno
	endif  
	
	if !FinVldNat(.F., aMovimentoBancario:E5_NATUREZ, 3)
		cMsg := "Valor do campo E5_NATUREZ inválido."
		nRetorno := 3 //Erro
		Return nRetorno
	endif

Return (nRetorno)

User Function FncMVBSq(aMovimentoBancario) 
	Local cSeq := ""
	
	cAliasQry := GetNextAlias()
	cQuery := " SELECT MAX(CAST(CV4.CV4_SEQUEN AS NUMERIC)) + 1 INCREMENTO "
	cQuery += "   FROM " + RetSqlName("CV4")+" CV4 "
	cQuery += "  WHERE CV4.CV4_FILIAL = '" + xFilial("CV4", aMovimentoBancario:E5_FILIAL) + "'"
	cQuery += "    AND CV4.D_E_L_E_T_ <> '*' "

	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)  

	dbSelectArea(cAliasQry)
	dbGoTop()
	
	If !Eof()	
		if Empty((cAliasQry)->INCREMENTO)
			cSeq := PADL("1", 10, "0")
	   	else
	   		cSeq := PADL(cVALTOCHAR((cAliasQry)->INCREMENTO), 10, "0") 
	   	endif
	else
		cSeq := PADL("1", 10, "0")
	endif
	
	(cAliasQry)->(dbCloseArea())
	   
Return (cSeq)