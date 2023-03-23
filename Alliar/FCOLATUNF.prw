#INCLUDE "PROTHEUS.CH"

User Function FCOLATUNF()
	Local aParam		:= If(Len(PARAMIXB) > 5, aClone(PARAMIXB[6]), {})
	Local cCdVerNFS	:= ""
	Local cSerie		:= PARAMIXB[1]
	Local cNumero		:= PARAMIXB[2]
	Local cProtocolo	:= PARAMIXB[3]
	Local cRPS			:= PARAMIXB[4]
	Local cNumNFSe	:= PARAMIXB[5]
	Local lExisteCmp	:=  SF2->(FieldPos('F2_XCVNFS')) > 0

	If lExisteCmp
		If !Empty(aParam) .AND. Len(aParam) >= 9
			cCdVerNFS	:= aParam[9]
		EndIf
		
		If !Empty(cCdVerNFS)
			DbSelectArea("SF2")
			DbSetOrder(1)		//F2_FILIAL, F2_DOC, F2_SERIE

			If SF2->(DbSeek(xFilial("SF2") + cNumero + cSerie))
				Reclock("SF2", .F.)
					SF2->F2_XCVNFS := cCdVerNFS
				MsUnlock()
			EndIf
		EndIf
	EndIf
	
Return Nil
