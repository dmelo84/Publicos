#include 'protheus.ch'
#include 'parmtype.ch'

User Function F240TDOK 

	Local cTempSE2 := paramixb[2]
	Local lRetorno

	If !Empty( paramixb[1] ) 
		While !(cTempSE2)->(Eof()) 
			If Empty( E2_Naturez ) 
				Alert( " Natureza vazia, documento: " + E2_Num )
				lRetorno := .f. 
				Exit 
			Else 
				lRetorno := .t. 
				dbSkip() 
			EndIf 
		End 
	EndIf 
Return lRetorno