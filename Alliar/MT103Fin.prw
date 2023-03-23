#include "PROTHEUS.CH"
//	* Ponto de entrada em Mata103 para validacao de datas e valores das parcelas
User Function MT103Fin()




	Local lReturn  := .T.
	Local aHeadFin  := PARAMIXB[1]
	Local aColsFin  := PARAMIXB[2]
	Local nPosVencto := aScan(aHeadFin,{|x| AllTrim(x[2]) == "E2_VENCTO"})
	Local i   := 0 
	Local lErro   := .F.
	Local _cParam,cDia := ""
	Local cMsg1:= ""  //hfp abax 
	Local cMsg2:= ""  //hfp abax 
	Local cMsg3:= ""  //hfp abax

	// CriaMv(_cFilial,_cTipo,_cNome,_cDefault,_cDescri)
	// u_CriaMv(xfilial("SA1"),"N",_cParam,"1","Prazo minimo em dias para entrada de nf (em relacao ao 1o vencimento). Criado automaticamente pela rotina Mt103fin")
	private nPrzMin  := 0


	IF Type("cXTPINT") == "C"
		IF cXTPINT == "HM"
			_cParam := "ES_XDPGHM"
		ELSE	
			_cParam := "ES_XDIASPG"
		ENDIF	
	ELSEIF FunName() == "MATA103" .AND. ALTERA
		IF ALLTRIM(SF1->F1_XTPINT) == "HM"
			_cParam := "ES_XDPGHM"
		ELSE	
			_cParam := "ES_XDIASPG" 
		ENDIF	

	ELSE
		//HFP-Compila  20210329 - inlusdo else para nao dar erro -  _cParam nulo qdo inclusao
		//             task 7554649
		_cParam := "ES_XDIASPG"  
	ENDIF

	nPrzMin  := GetMV(_cParam,.F.)
	cDia:= " Dia"+ Iif(nPrzMin > 1,"s","")

	//	If MaFisRet(,"NF_BASEDUP") > 0
	For i := 1 To Len(aColsFin)
		If aColsFin[i][nPosVencto] < Date()+nPrzMin 
			lErro := .T.
			Exit
		EndIf
	Next i

	If lErro
		If INCLUI .or. ALTERA

			//hfp abax
			/*
			Aviso("Prazo Mínimo Pagto.",;
			"A Data de vencimento deverá ser maior que a data atual.",;
			{"&Ok"},,;
			"Prazo mínimo: " + StrZero(nPrzMin,2) + cDia)
			*/

			cMsg1:="Prazo Mínimo Pagto"  //abax
			cMsg2:="A Data de vencimento deverá ser maior que a data atual." //abax
			cMsg3:="Prazo mínimo: " + StrZero(nPrzMin,2) + cDia //abax

			Help( , , cMsg1, ,cMsg2 , 1, 0, NIL, NIL, NIL, NIL, NIL, {cMsg3}) //abax

			lReturn := .F.
		EndIf
	EndIf
	//	Endif

Return(lReturn)
