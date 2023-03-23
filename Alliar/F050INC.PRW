#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"


/*/{Protheus.doc} F050INC
//TODO Gravação de contas a pagar
@author Mauro Nagata | www.compila.com.br
@since 19/03/2020
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
User Function F050INC()

Local aArea		:= GetArea()
Local aAreasE2	:= SE2->(GetArea())
//Local nRecSE2	:= SE2->(Recno())
//incluído bloco abaixo [Mauro Nagata, www.compila.com.br, 20200414]
Local cNxRPIS	:= SuperGetMV("AL_CRETPIS", .F., "21010135;5979;21010138;5979;21010142;5979")					//natureza x retenção PIS
Local cNxRCOF	:= SuperGetMV("AL_CRETCOF", .F., "21010136;5960;21010137;5960;21010142;5960;21010143;5960")		//natureza x retenção COF
Local cNxRCSL	:= SuperGetMV("AL_CRETCSL", .F., "21010135;5987;21010138;5987")									//natureza x retenção CSLL
Local cNatur	:= AllTrim(SE2->E2_NATUREZ)	
Local cUniao	:= SuperGetMV("MV_UNIAO", .F., "UNIAO")															//fornecedor taxa
//fim bloco [Mauro Nagata, www.compila.com.br, 20200414]
Local nTamNat	:= Len(cNatur)
/*
//Retenção PIS
If AllTrim(SE2->E2_NATUREZ) $ "21010135.21010138.21010142"
	If SE2->E2_PIS > 0
		RecLock("SE2", .F.)
		SE2->E2_CODRPIS := "5979"
		SE2->(MsUnLock())
		
		If DbSeek(SE2->(E2_FILIAL + E2_PREFIXO + E2_NUM + E2_PARCPIS) + "PIS")
			RecLock("SE2", .F.)
			SE2->E2_CODRPIS := "5979"
			SE2->E2_DIRF	:= "1"
			SE2->(MsUnLock())
		EndIf
		
		DbGoTo(nRecSE2)		
	EndIf
EndIf	
	
//Retenção COFINS
If AllTrim(SE2->E2_NATUREZ) $ "21010136.21010137.21010142.21010143"
	If SE2->E2_COFINS > 0
		RecLock("SE2", .F.)
		SE2->E2_CODRCOF := "5960"
		SE2->(MsUnLock())	
		
		DbSelectArea("SE2")
		DbSetOrder(1)
		If DbSeek(SE2->(E2_FILIAL + E2_PREFIXO + E2_NUM + E2_PARCCOF) + "COF")
			RecLock("SE2", .F.)
			SE2->E2_CODRCOF := "5960"
			SE2->E2_DIRF	:= "1"
			SE2->(MsUnLock())
		EndIf	
		
		DbGoTo(nRecSE2)
	EndIf
EndIf

//Retenção CSLL
If AllTrim(SE2->E2_NATUREZ) $ "21010135.21010138"
	If SE2->E2_CSLL > 0
		RecLock("SE2", .F.)
		SE2->E2_CODRCSL := "5987"
		SE2->(MsUnLock())		
		
		If DbSeek(SE2->(E2_FILIAL + E2_PREFIXO + E2_NUM + E2_PARCSLL) + "CSL")
			RecLock("SE2", .F.)
			SE2->E2_CODRCSL := "5987"
			SE2->E2_DIRF	:= "1"
			SE2->(MsUnLock())
		EndIf
		
		DbGoTo(nRecSE2)
	EndIf
EndIf
//substituído bloco acima pelo abaixo [Mauro Nagata, www.compila.com.br, 20200414]
*/

//Retenção PIS
 
If SE2->E2_PIS > 0
	nPosCRPIS 	:= At(cNatur, cNxRPIS) + nTamNat + 1
	If nPosCRPIS > nTamNat + 1
		cCRetPIS	:= Substr(cNxRPIS,nPosCRPIS,4)
		
		RecLock("SE2", .F.)
		SE2->E2_CODRPIS := cCRetPIS
		SE2->(MsUnLock())
		
		DbSelectArea("SE2")
		DbSetOrder(1)
		If DbSeek(SE2->(E2_FILIAL + E2_PREFIXO + E2_NUM + E2_PARCPIS) + "PIS" + cUniao)
			RecLock("SE2", .F.)
			SE2->E2_CODRPIS := cCRetPIS	
			SE2->E2_DIRF	:= "1"
			SE2->(MsUnLock())
		EndIf
		
		//DbGoTo(nRecSE2)
		RestArea(aAreaSE2)		
	EndIf
EndIf	
	
//Retenção COFINS
If SE2->E2_COFINS > 0
	nPosCRCOF 	:= At(cNatur, cNxRCOF) + nTamNat + 1
	If nPosCRCOF > nTamNat + 1
		cCRetCOF	:= Substr(cNxRCOF,nPosCRCOF,4)
	
		RecLock("SE2", .F.)
		SE2->E2_CODRCOF := cCRetCOF
		SE2->(MsUnLock())	
		
		DbSelectArea("SE2")
		DbSetOrder(1)
		If DbSeek(SE2->(E2_FILIAL + E2_PREFIXO + E2_NUM + E2_PARCCOF) + "COF" + cUniao)
			RecLock("SE2", .F.)
			SE2->E2_CODRCOF := cCRetCOF
			SE2->E2_DIRF	:= "1"
			SE2->(MsUnLock())
		EndIf	
		
		//DbGoTo(nRecSE2)
		RestArea(aAreaSE2)
	EndIf
EndIf

//Retenção CSLL
If SE2->E2_CSLL > 0
	nPosCRCSL 	:= At(cNatur, cNxRCSL) + nTamNat + 1
	If nPosCRCSL > nTamNat + 1
		cCRetCSL	:= Substr(cNxRCSL,nPosCRCSL,4)
		
		RecLock("SE2", .F.)
		SE2->E2_CODRCSL := cCRetCSL
		SE2->(MsUnLock())		
		
		DbSelectArea("SE2")
		DbSetOrder(1)
		If DbSeek(SE2->(E2_FILIAL + E2_PREFIXO + E2_NUM + E2_PARCSLL) + "CSL" + cUniao)
			RecLock("SE2", .F.)
			SE2->E2_CODRCSL := cCRetCSL
			SE2->E2_DIRF	:= "1"
			SE2->(MsUnLock())
		EndIf
		
		//DbGoTo(nRecSE2)
		RestArea(aAreaSE2)
	EndIf
EndIf
//fim bloco [Mauro Nagata, www.compila.com.br, 20200414]

//RestArea(aAreaSE2)
RestArea(aArea)

Return


