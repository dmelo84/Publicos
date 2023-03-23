#include "PROTHEUS.CH"

User Function FncACTVl(aAcidenteTrabalho, cMsg)
	Local nRetorno := 1
	
	If !(aAcidenteTrabalho:TNC_TIPCAT $ "1|2|3")
		cMsg := "Valor do TNC_TIPCAT deverá ser igual a 1, 2 ou 3."
		nRetorno := 3 //Erro
		Return nRetorno
	EndIf
	

	If !(aAcidenteTrabalho:TNC_TIPREV $ "1|2|6|7")
		cMsg := "Valor do TNC_TIPREV deverá ser igual a 1, 2, 6 ou 7."
		nRetorno := 3 //Erro
		Return nRetorno
	EndIf

	If !(aAcidenteTrabalho:TNC_APOSEN $ "1|2")
		cMsg := "Valor do TNC_APOSEN deverá ser igual a 1 ou 2."
		nRetorno := 3 //Erro
		Return nRetorno
	EndIf

	If !(aAcidenteTrabalho:TNC_AREA $ "1|2")
		cMsg := "Valor do TNC_AREA deverá ser igual a 1 ou 2."
		nRetorno := 3 //Erro
		Return nRetorno
	EndIf

	If !(VALHORA(aAcidenteTrabalho:TNC_HRACID))
		cMsg := "Horário informado no TNC_HRACID é inválido."
		nRetorno := 3 //Erro
		Return nRetorno
	EndIf
	

	If !(VALHORA(aAcidenteTrabalho:TNC_HRTRAB))
		cMsg := "Horário informado no TNC_HRTRAB é inválido."
		nRetorno := 3 //Erro
		Return nRetorno
	EndIf

	If !(aAcidenteTrabalho:TNC_AFASTA $ "1|2")
		cMsg := "Valor do TNC_AFASTA deverá ser igual a 1 ou 2."
		nRetorno := 3 //Erro
		Return nRetorno
	EndIf

	If !(aAcidenteTrabalho:TNC_INDLOC $ "1|2|3|4|5")
		cMsg := "Valor do TNC_INDLOC deverá ser igual a 1, 2, 3, 4, ou 5."
		nRetorno := 3 //Erro
		Return nRetorno
	EndIf

	If Empty(aAcidenteTrabalho:TNC_DTACID) .OR. !ValDt(aAcidenteTrabalho:TNC_DTACID,.f.)
		cMsg := "TNC_DTACID inválido"
		nRetorno := 3 //Erro
		Return nRetorno
	EndIf

	If Empty(aAcidenteTrabalho:TNC_DTULTI) .OR. !ValDt(aAcidenteTrabalho:TNC_DTULTI,.f.)
		cMsg := "TNC_DTULTI inválido"
		nRetorno := 3 //Erro
		Return nRetorno
	EndIf
	
	if !(aAcidenteTrabalho:TNC_INDACI $ "1|2|3|4|5|6")
		cMsg := "Valor do TNC_INDACI deverá ser igual a 1, 2, 3, 4, 5 ou 6."
		nRetorno := 3 //Erro
		Return nRetorno
	endif
	
	if !(aAcidenteTrabalho:TNC_VITIMA $ "1|2|3")
		cMsg := "Valor do TNC_VITIMA deverá ser igual a 1, 2 ou 3."
		nRetorno := 3 //Erro
		Return nRetorno
	endif
	
	if !(aAcidenteTrabalho:TNC_TRANSF $ "1|2")
		cMsg := "Valor do TNC_TRANSF deverá ser igual a 1 ou 2."
		nRetorno := 3 //Erro
		Return nRetorno
	endif
	
	if !(aAcidenteTrabalho:TNC_EMITEN $ "1|2|3|4|5")
		cMsg := "Valor do TNC_EMITEN deverá ser igual a 1, 2, 3, 4 ou 5."
		nRetorno := 3 //Erro
		Return nRetorno
	endif
	
	if !(aAcidenteTrabalho:TNC_POLICI $ "1|2")
		cMsg := "Valor do TNC_POLICI deverá ser igual a 1 ou 2."
		nRetorno := 3 //Erro
		Return nRetorno
	endif
	
	if !(aAcidenteTrabalho:TNC_MORTE $ "1|2")
		cMsg := "Valor do TNC_MORTE deverá ser igual a 1 ou 2."
		nRetorno := 3 //Erro
		Return nRetorno
	endif
	
	if !(aAcidenteTrabalho:TNC_LOCACT $ "1|2|3|4")
		cMsg := "Valor do TNC_LOCACT deverá ser igual a 1, 2, 3 ou 4."
		nRetorno := 3 //Erro
		Return nRetorno
	endif
	
	if !(aAcidenteTrabalho:TNC_MUDANC $ "1|2")
		cMsg := "Valor do TNC_MUDANC deverá ser igual a 1 ou 2."
		nRetorno := 3 //Erro
		Return nRetorno
	endif

Return (nRetorno)

User Function FncACTSq(aAcidenteTrabalho)
	Local cSeq := ""
	
	cAliasQry := GetNextAlias()
	cQuery := " SELECT MAX(CAST(TNC.TNC_ACIDEN AS INTEGER)) + 1 INCREMENTO "
	cQuery += "   FROM " + RetSqlName("TNC")+" TNC "
	cQuery += "  WHERE TNC.TNC_FILIAL = '" + xFilial("TNC", aAcidenteTrabalho:TNC_FILIAL) + "'"
	cQuery += "    AND TNC.D_E_L_E_T_ <> '*' "

	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)  

	dbSelectArea(cAliasQry)
	dbGoTop()
	
	If !Eof()
		//Sequencial
		if Empty((cAliasQry)->INCREMENTO)
			cSeq := PADL("1", 06, "0")
		else
			//Incrementa Sequencial
			cSeq := PADL(cVALTOCHAR((cAliasQry)->INCREMENTO), 06, "0")
		endif 
	else
		cSeq := PADL("1", 06, "0")   
	endif
	
	(cAliasQry)->(dbCloseArea())
	
Return (cSeq)

Static Function VALHORA(cHora)
	Local nPos    := At(":",cHora)
	Local nHora   := Val(SubStr(cHora,1,(nPos-1)))
	Local nMinuto := Val(SubStr(cHora,(nPos+1)))
	Local lRet    := nMinuto < 60 .Or. nMinuto < 0
	Local lFim    := .F.

	If "-" $ cHora
		Help(" ",1,"HORAINVALI")
		lRet := .F.
		lFim := .T.
	EndIf

	If !lFim
		//Valida a hora somente quando houver 2 digitos em Hora
		If lRet .And. nPos == 3
			lRet := nHora < 24 .Or. nMinuto < 0
		EndIf

		If Alltrim(cHORA) = ":" .Or. !lRet
			If Alltrim(cHORA) = ":"
				Help(" ",1,"HORAINVA")
			Else
				Help(" ",1,"HORAINVALI")
			EndIf
			lRet := .F.
		EndIf
	EndIf

Return lRet