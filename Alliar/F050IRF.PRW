#INCLUDE "rwmake.ch"
#INCLUDE "PROTHEUS.ch"

/*/{Protheus.doc} F050IRF
//TODO tratamento do título do IRF
@author Mauro Nagata | www.compila.com.br
@since 19/03/2020
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
User Function F050IRF()

Local aArea		:= GetArea()
Local aAreaSE2	:= SE2->(GetArea())
Local nRecSE2 	:= PARAMIXB			//recno do título principal
Local nRecIR	:= SE2->(Recno())	//recno do título IR
Local lIp		:= .F.
//Local cCodRet	:= ""
//substituída linha acima pela abaixo [Mauro Nagata, www.compila.com.br, 20200416]
Local cCodRet	:= SE2->E2_CODRET	//código de retenção do IR
//incluído bloco abaixo [Mauro Nagata, www.compil.com.br, 20200416]
Local cDirf		:= SE2->E2_DIRF		//dirf do IR
Local cNxRIR	:= SuperGetMV("AL_CRETIRF", .F., "21010139;0422;21010141;0422;21010144;0422;21010135;1708;21010138;1708;21010142;1708;21010143;1708;21010046;3208;23050028;9385;23060003;5706")	//natureza x retenção IR
Local cNatur	 
Local nTamNat	

//fim bloco [Mauro Nagata, www.compila.com.br, 20200416]

DbSelectArea("SE2")

//posicionando no título principal
DbGoTo(nRecSE2)

/*
If AllTrim(SE2->E2_NATUREZ) $ "21010139.21010141.21010144"
	//posicionando no título do IR
	DbGoTo(nRecIR)
	
	cCodRet := "0422"
	
	RecLock("SE2",.F.)
	SE2->E2_CODRET	:= cCodRet 
	SE2->E2_DIRF	:= "1"
	SE2->(MsUnLock())
	
	lIp := .T.
EndIf		
If AllTrim(SE2->E2_NATUREZ) $ "21010135.21010138.21010142.21010143"
	//posicionando no título do IR
	DbGoTo(nRecIR)
	
	cCodRet := "1708"
	
	RecLock("SE2",.F.)
	SE2->E2_CODRET	:= cCodRet 
	SE2->E2_DIRF	:= "1"
	SE2->(MsUnLock())
	
	lIp := .T.
			
EndIf

If AllTrim(SE2->E2_NATUREZ) $ "21010046"
	//posicionando no título do IR
	DbGoTo(nRecIR)
	
	cCodRet := "3208"
	
	RecLock("SE2",.F.)
	SE2->E2_CODRET	:= cCodRet 
	SE2->E2_DIRF	:= "1"
	SE2->(MsUnLock())
	
	lIp := .T.
			
EndIf


//incluído bloco abaixo [Mauro Nagata, www.compila.com.br, 20200406]
If AllTrim(SE2->E2_NATUREZ) $ "23050028"
	//posicionando no título do IR
	DbGoTo(nRecIR)
	
	cCodRet := "9385"
	
	RecLock("SE2",.F.)
	SE2->E2_CODRET	:= cCodRet 
	SE2->E2_DIRF	:= "1"
	SE2->(MsUnLock())
	
	lIp := .T.
			
EndIf
*/
cNatur		:= AllTrim(SE2->E2_NATUREZ)
nTamNat		:= Len(cNatur)
nPosCRIR 	:= At(cNatur, cNxRIR) + nTamNat + 1
If nPosCRIR > nTamNat + 1
	cCodRet	:= Substr(cNxRIR, nPosCRIR, 4)
	cDirf	:= "1"
	lIp 	:= .T.
EndIf

DbGoTo(nRecIR)

RecLock("SE2",.F.)
SE2->E2_CODRET	:= cCodRet 
SE2->E2_DIRF	:= cDirf
SE2->(MsUnLock())

DbGoTo(nRecSE2)
If lIp 
	RecLock("SE2", .F.)
	SE2->E2_CODRET	:= cCodRet
	SE2->E2_DIRF	:= "2"
	SE2->(MsUnLock())
EndIf

RestArea(aAreaSE2)
RestArea(aArea)

Return


