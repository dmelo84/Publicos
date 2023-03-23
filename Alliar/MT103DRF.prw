#Include 'Protheus.ch'
#include "rwmake.ch"


/*/{Protheus.doc} MT103DRF
Este ponto de entrada pertence ao MATA103X (fun��es de valida��o e controle de interface do documento de entrada). e
� executado na rotina de valida��o do c�digo do fornecedor, NFEFORNECE() para documentos de entrada padr�o.
Tamb�m � executado na rotina A103NFiscal do MATA103 quando da classifica��o de pr�-notas de entrada.
Permite alterar o combobox com a informa��o se gera DIRF e o c�digo de reten��o.
Dispon�vel para IRPF, ISS, PIS, Cofins e CSLL.
@author Jonatas Oliveira | www.compila.com.br
@since 09/09/2015
@version 1.0
/*/
User Function MT103DRF()
	Local nCombo 	:= PARAMIXB[1]
	Local cCodRet 	:= PARAMIXB[2]
	Local oCombo 	:= PARAMIXB[3]
	Local oCodRet 	:= PARAMIXB[4]
	Local aImpRet 	:= {}

	Local aArea		:= GetArea()
	Local aAreaSA2	:= SA2->(GetArea())
	Local aAreaSED	:= SED->(GetArea())
	//inclu�do bloco abaixo [Mauro Nagata, www.compil.com.br, 20200319]
	Local cNxRIR	:= SuperGetMV("AL_CRETIRF", .F., "21010139;0422;21010141;0422;21010144;0422;21010135;1708;21010138;1708;21010142;1708;21010143;1708;21010046;3208;23050028;9385;23060003;5706")	//natureza x reten��o IR
	Local cNatur	:= AllTrim(SED->ED_CODIGO)
	Local nTamNat	:= Len(cNatur)
	//fim bloco [Mauro Nagata, www.compila.com.br, 20200319]
	//inclu�do bloco abaixo [Mauro Nagata, www.compila.com.br, 20200414]
	Local cNxRPIS	:= SuperGetMV("AL_CRETPIS", .F., "21010135;5979;21010138;5979;21010142;5979")					//natureza x reten��o PIS
	Local cNxRCOF	:= SuperGetMV("AL_CRETCOF", .F., "21010136;5960;21010137;5960;21010142;5960;21010143;5960")		//natureza x reten��o COF
	Local cNxRCSL	:= SuperGetMV("AL_CRETCSL", .F., "21010135;5987;21010138;5987")									//natureza x reten��o CSLL	
	//fim bloco [Mauro Nagata, www.compila.com.br, 20200414]

	cCONDICAO 		:= SF1->F1_COND

	/*
	Par�metros:
	Nome			Tipo				Descri��o
	nCombo			Num�rico			Posi��o do combo (1=sim;2=n�o)
	cCodRet			Caracter			C�digo da reten��o
	oCombo			Array of Record		Objeto oCombo
	oCodRet			Array of Record		Objeto oCodRet
	*/

	IF SA2->A2_TIPO == "J"
	
		/*
		IF SA2->A2_XCOOPER = '1'
			nCombo  := 1
			cCodRet := "3280"
			aadd(aImpRet,{"IRR",nCombo,cCodRet})
		ELSE
			IF SED->ED_CALCIRF <> "S"
				nCombo  := 2
				cCodRet := ""
				aadd(aImpRet,{"IRR",nCombo,cCodRet})
			ELSE
				nCombo  := 1
				cCodRet := "1708"
				aadd(aImpRet,{"IRR",nCombo,cCodRet})
			ENDIF
		ENDIF
		*/
		//Substitu�do bloco acima pelo abaixo [Mauro Nagata, www.compil.com.br, 20200319] 
		/*
		IF SA2->A2_XCOOPER = '1'
			nCombo  := 1
			cCodRet := "3280"
			aAdd(aImpRet,{"IRR",nCombo,cCodRet})
		ELSE
			IF SED->ED_CALCIRF <> "S"
				nCombo  := 2
				cCodRet := ""
				aAdd(aImpRet,{"IRR",nCombo,cCodRet})
			ELSE
				nCombo  := 1
				nPosCRIR 	:= At(cNatur, cNxRIR) + nTamNat + 1
				If nPosCRIR > nTamNat + 1
					cCodRet	:= Substr(cNxRIR, nPosCRIR, 4)
				Else
					cCodRet := "1708"
				EndIf
				aadd(aImpRet,{"IRR",nCombo,cCodRet})
			ENDIF
		ENDIF
		//fim bloco [Mauro Nagata, www.compil.com.br, 20200319]
		*/
		//Substitu�do bloco acima pelo abaixo [Mauro Nagata, www.compil.com.br, 20200818] 
		IF SED->ED_CALCIRF = "S"
			IF SA2->A2_XCOOPER = '1'
				nCombo  := 1
				cCodRet := "3280"
				aAdd(aImpRet,{"IRR",nCombo,cCodRet})
			Else
				nCombo  := 1
				nPosCRIR 	:= At(cNatur, cNxRIR) + nTamNat + 1
				If nPosCRIR > nTamNat + 1
					cCodRet	:= Substr(cNxRIR, nPosCRIR, 4)
				Else
					cCodRet := "1708"
				EndIf
				aadd(aImpRet,{"IRR",nCombo,cCodRet})
			EndIf
		Else 
			nCombo  := 2
			cCodRet := ""
			aAdd(aImpRet,{"IRR",nCombo,cCodRet})
		ENDIF
		//fim bloco [Mauro Nagata, www.compil.com.br, 20200818]

		//nCombo  := 1
		//cCodRet := "5952"
		//substitu�da linha acima pelo bloco abaixo [Mauro Nagata, www.compila.com.br, 20200414]
		//Reten��o PIS
		 
		If SED->ED_CALCPIS == "S" .And. SED->ED_PERCPIS > 0
			nCombo  	:= 1
			nPosCRPIS 	:= At(cNatur, cNxRPIS) + nTamNat + 1
			If nPosCRPIS > nTamNat + 1
				cCodRet	:= Substr(cNxRPIS, nPosCRPIS, 4)
			Else
				cCodRet := "5952"
			EndIf
		EndIf	
		//fim bloco [Mauro Nagata, www.compila.com.br, 20200414]
				
		aadd(aImpRet,{"PIS",nCombo,cCodRet})

		//nCombo  := 1
		//cCodRet := "5952"
		//substitu�da linha acima pelo bloco abaixo [Mauro Nagata, www.compila.com.br, 20200414]
		//Reten��o CSLL
		If SED->ED_CALCCOF == "S" .And. SED->ED_PERCCOF > 0
			nCombo  	:= 1
			nPosCRCOF 	:= At(cNatur, cNxRCOF) + nTamNat + 1
			If nPosCRCoF > nTamNat + 1
				cCodRet	:= Substr(cNxRCOF, nPosCRCOF, 4)
			Else
				cCodRet := "5952"
			EndIf
		EndIf	
		//fim bloco [Mauro Nagata, www.compila.com.br, 20200414]
		aadd(aImpRet,{"COF",nCombo,cCodRet})

		//nCombo  := 1
		//cCodRet := "5952"
		//substitu�da linha acima pelo bloco abaixo [Mauro Nagata, www.compila.com.br, 20200414]
		//Reten��o CSLL
		If SED->ED_CALCCSL == "S" .And. SED->ED_PERCCSL > 0
			nCombo  	:= 1
			nPosCRCSL 	:= At(cNatur, cNxRCSL) + nTamNat + 1
			If nPosCRCSL > nTamNat + 1
				cCodRet	:= Substr(cNxRCSL, nPosCRCSL, 4)
			Else
				cCodRet := "5952"
			EndIf
		EndIf	
		//fim bloco [Mauro Nagata, www.compila.com.br, 20200414]
		
		aadd(aImpRet,{"CSL",nCombo,cCodRet})
	ELSE
	
		aadd(aImpRet,{"IRR",2    	,""     	})
		aadd(aImpRet,{"PIS",2		,""			})
		aadd(aImpRet,{"COF",2		,""			})
		aadd(aImpRet,{"CSL",2		,""			})
	
		/* Alterado por Vaney no dia  11/06/2019
		nCombo  := 2
		cCodRet := ""

		IF ALLTRIM(SA2->A2_NATUREZ) == ALLTRIM(SED->ED_CODIGO)
			nCombo  := 1
			cCodRet := SED->ED_CODRET
		ELSE
			nCombo  := 1
			cCodRet := ""
		ENDIF

		aadd(aImpRet,{"IRR",nCombo	,cCodRet		})
		aadd(aImpRet,{"PIS",2		,""			})
		aadd(aImpRet,{"COF",2		,""			})
		aadd(aImpRet,{"CSL",2		,""			})
		*/

	ENDIF

	RestArea(aAreaSED)
	RestArea(aAreaSA2)
	RestArea(aArea)
Return(aImpRet)

