#Include "Totvs.ch"

/*
CN121PED
ATUALIZA GRUPO DE APROVACAO DA CN9 NO PEDIO DE COMPRA QUE VAI SER GERADO PELA MEDICAO

==> antigo CN120PED (CNTA120)  (HFP-COMPILA)
 

@author 
@since 09/12/2014
@version 1.0
*/



User Function CN121PED()
Local aArea := GetArea()
Local aRet  := {paramixb[1],paramixb[2]} 

If FindFunction("U_ALCO11")  .And. !Empty(CN9->CN9_XAPALI)
	aRet[2]	:= U_ALCO11(paramixb[2])
EndIf

If FindFunction("U_ALCO21")  .And. Empty(CN9->CN9_XAPALI)

	aRet[2]	:= U_ALCO21(paramixb[2])
EndIf


	
RestArea(aArea)
	
Return aRet
