#INCLUDE "Protheus.ch"
#INCLUDE "RWMAKE.CH"


/*/{Protheus.doc} M460NUM
Ponto de Entrada executado na geracao do numero da NF
@type function
@author gustavo.barcelos
@since 05/02/2016
@version 1.0
/*/

User Function M460NUM()
Local aPvlNfs 	:= PARAMIXB
Local cNFTmp		:= ""
Local nXI			:= 0
Local nTamNota  	:= Len(SF2->F2_DOC)
Local cRet			:= ""
Local lContinua	:= .f.

	If Type('__GeraNF') != "U"
		If __GeraNF 
			lContinua := .t.
		Endif	
	Endif	

	// Se chamado via Job
	If lContinua

		ConOut("*********************************************************")
		ConOut("* M460NUM - " + DtoC(Date()) + " - " + Time() + " - Verificando salto de numeracao de NF! ")
		ConOut("*********************************************************")									

		cNFTmp	:= cNumero
		
		For nXI := 1 to 5	 		
			cNFTmp	:= StrZero(Val(cNumero)-nXi,nTamNota,0)

			cRet := ChkNumNF(cSerie,cNFTmp)
			
			Do Case
				Case cRet	== "C" // Para busca, NF´s em outra data
					Exit
				Case cRet 	== "B" // Encontrou salto na numeracao - ajusta NF	
					ConOut("*********************************************************")
					ConOut("* M460NUM - " + DtoC(Date()) + " - " + Time() + " - Salto na numeracao de NF! ")
					ConOut("* Numero da NF alterado para "+cNFTmp )
					ConOut("*********************************************************")									
					cNumero := cNFTmp
					Exit
			EndCase						
		Next	
	Endif
	
Return


//-------------------------------------------------------------------
/*{Protheus.doc} ChkNumNF
Verifica e Corrige a Numeracao das NFs da Filial

@author Guilherme Santos
@since 18/10/2016
@version P12
*/
//-------------------------------------------------------------------
Static Function ChkNumNF(cSer,cNum)
	Local aArea		:= GetArea()
	Local cQuery		:= ""
	Local cTabQry		:= GetNextAlias()
	Local cRet			:= ""
	
	cQuery += "SELECT	* " + CRLF
	cQuery += "FROM		" + RetSqlName("SF2") + " SF2" + CRLF
	cQuery += "WHERE		SF2.F2_FILIAL = '" + xFilial("SF2") + "'" + CRLF
	cQuery += "AND		SF2.F2_SERIE = '" + cSer + "'" + CRLF
	cQuery += "AND		SF2.F2_DOC = '" + cNum + "'" + CRLF

	cQuery := ChangeQuery(cQuery)
		
	DbUseArea(.T., "TOPCONN", TcGenQry(NIL, NIL, cQuery), cTabQry, .T., .T.)
		
	If !(cTabQry)->(Eof())
		If (cTabQry)->F2_EMISSAO != Dtos(dDataBase)
			cRet := "C" // Para busca, NF´s em outra data
		Else
			cRet := "A"
		Endif	
	Else
		cRet := "B"	 // Salto na numeracao de NF
	Endif	
	
	If Select(cTabQry) > 0
		(cTabQry)->(DbCloseArea())
	EndIf
	
	RestArea(aArea)

Return cRet


