#INCLUDE 'PROTHEUS.CH'
//-------------------------------------------------------------------
/*{Protheus.doc} NFSVLNUM
Valida o Numero de NF selecionado

@author Guilherme Santos
@since 18/10/2016
@version P12
*/
//-------------------------------------------------------------------
User Function NFSVLNUM()
	Local cNumero		:= PARAMIXB[1]
	Local cSerie		:= PARAMIXB[2]
	Local lRetorno		:= .T.
    Local nQtddgNf      := SuperGetMv("CP_QTDDGNF",.T.,9)
    
    
    If Len(alltrim(cNumero)) ==  nQtddgNf  
		If !VldNumNF(cSerie, cNumero)
					
		 If	 ApMsgNoYes("Já existe NF com Numeração maior que a informada e data inferior a data do Sistema. Deseja Continuar?", "NFSVLNUM") 
		      lRetorno := .T.
		 Else 
		      lRetorno := .F.
		 EndIf	
			//Aviso("NFSVLNUM", "Já existe NF com Numeração maior que a informada e data inferior a data do Sistema.", {"Fechar"})
			//Help(" ",1,"NFSVLNUM",,"Já existe NF com Numeração maior que a informada e data inferior a data do Sistema.",4,5)
		EndIf
	Else
	     lRetorno := .F.
			//Aviso("NFSVLNUM", "O numero da NF foi alterado manualmente e difere dos "+ str(nQtddgNf)+" digitos.", {"Fechar"})
			Help(" ",1,"NFSVLNUM",, "O numero da NF foi alterado manualmente e difere dos "+ str(nQtddgNf)+" digitos.",4,5)
	EndIf
	

Return lRetorno
//-------------------------------------------------------------------
/*{Protheus.doc} VldNumNF
Valida a Numeracao informada

@author Guilherme Santos
@since 19/10/2016
@version P12
*/
//-------------------------------------------------------------------
Static Function VldNumNF(cSerie, cNumero)
	Local aArea		:= GetArea()
	Local cQuery		:= ""
	Local cTabQry		:= GetNextAlias()
	Local lRetorno	:= .T.
	
	cQuery += "SELECT		TOP 1 SF2.F2_DOC" + CRLF
	cQuery += "FROM		" + RetSqlName("SF2") + " SF2" + CRLF
	cQuery += "WHERE		SF2.F2_FILIAL = '" + xFilial("SF2") + "'" + CRLF
	cQuery += "AND		SF2.F2_SERIE = '" + cSerie + "'" + CRLF
	cQuery += "AND		SF2.F2_EMISSAO < '" + DtoS(dDatabase) + "'" + CRLF
	cQuery += "AND		SF2.F2_DOC > '" + cNumero + "'" + CRLF
	cQuery += "AND 		SF2.D_E_L_E_T_ = ''" + CRLF
	
	cQuery := ChangeQuery(cQuery)
		
	DbUseArea(.T., "TOPCONN", TcGenQry(NIL, NIL, cQuery), cTabQry, .T., .T.)
		
	While !(cTabQry)->(Eof())
		lRetorno := .F.
	
		(cTabQry)->(DbSkip())
	End
	
	If Select(cTabQry) > 0
		(cTabQry)->(DbCloseArea())
	EndIf
	
	RestArea(aArea)
Return( lRetorno)
