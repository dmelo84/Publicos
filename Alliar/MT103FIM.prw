#Include 'Protheus.ch'
#include "rwmake.ch"


/*/{Protheus.doc} MT103FIM
//TODO Opera��o ap�s a grava��o da NFE
@author Mauro Nagata | www.compila.com.br
@since 16/04/2020
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
User Function MT103FIM()
Local aParamIXB	:= PARAMIXB				//{aRotina[nOpcX,4],nOpc}
Local aArea		:= GetArea()
Local aAreaSE2	:= SE2->(GetArea())
Local aAreaSED	:= SED->(GetArea())
Local cTipoSF1	:= SF1->F1_TIPO
Local cSerSF1	:= SF1->F1_SERIE
Local cDocSF1	:= SF1->F1_DOC
Local cForSF1	:= SF1->F1_FORNECE
Local cLjaSF1	:= SF1->F1_LOJA
Local lIpIRF	:= .F.
Local cNxRIR	:= SuperGetMV("AL_CRETIRF", .F., "21010139;0422;21010141;0422;21010144;0422;21010135;1708;21010138;1708;21010142;1708;21010143;1708;21010046;3208;23050028;9385;23060003;5706")	//natureza x reten��o IR
Local cNxRPIS	:= SuperGetMV("AL_CRETPIS", .F., "21010135;5979;21010138;5979;21010142;5979")					//natureza x reten��o PIS
Local cNxRCOF	:= SuperGetMV("AL_CRETCOF", .F., "21010136;5960;21010137;5960;21010142;5960;21010143;5960")		//natureza x reten��o COF
Local cNxRCSL	:= SuperGetMV("AL_CRETCSL", .F., "21010135;5987;21010138;5987")									//natureza x reten��o CSLL			
Local cNatur	 
Local nTamNat	
Local nPosCRIRF
Local nPosCRPIS
Local nPosCRCOF
Local nPosCRCSL
Local cCodRIRF
Local cCodRPIS
Local cCodRCOF
Local cCodRCSL
Local cNatIRF	:= GetMV( "MV_IRF" ) 
Local cNatPIS	:= GetMV( "MV_PISNAT" )
Local cNatCOF	:= GetMV( "MV_COFINS" )
Local cNatCSL	:= GetMV( "MV_CSLL" )
Local nVlrPIS
Local nVlrCOF
Local nVlrCSL
Local nVlrIRF

If cTipoSF1 == "N"		//normal
	DbSelectArea("SE2")
	DbSetOrder(1)
	
	//verifica se existe t�tulo a pagar do documento de entrada
	If DbSeek(xFilial("SE2")+cSerSF1 + cDocSF1 + "   " + "NF " + cForSF1 + cLjaSF1)
		cCodRIRF	:= SE2->E2_CODRET					//c�digo de reten��o IRRF t�tulo principal
		cCodRPIS	:= SE2->E2_CODRPIS				//c�digo de reten��o PIS t�tulo principal
		cCodRCOF	:= SE2->E2_CODRCOF				//c�digo de reten��o COFINS t�tulo principal
		cCodRCSL	:= SE2->E2_CODRCSL				//c�digo de reten��o CSLL t�tulo principal
		nVlrIRF	:= SE2->E2_IRRF					//valor IRRF t�tulo principal
		nVlrPIS	:= SE2->E2_PIS						//valor PIS t�tulo principal
		nVlrCOF	:= SE2->E2_COFINS					//valor COFINS t�tulo principal
		nVlrCSL	:= SE2->E2_CSLL					//valor CSLL t�tulo principal
		cNatur 	:= AllTrim(SE2->E2_NATUREZ)	//natureza t�tulo principal
		//inclu�da linha abaixo [Mauro Nagata, www.compila.com.br, 20200819]
		cTipoTit := SE2->E2_TIPO					//tipo do titulo
		nTamNat	:= Len(cNatur)						//tamanho natureza
		
		DbSelectArea("SED")
		DbSetOrder(1)
		
		//verifica se existe natureza cadastrada
		If DbSeek( xFilial( "SED" ) + cNatur )
		
			//Reten��o IRRF
			If SED->ED_CALCIRF == "S" .And. SED->ED_PERCIRF > 0
				/*
				nPosCRIRF 	:= At(cNatur, cNxRIR) + nTamNat + 1
				If nPosCRIRF > nTamNat + 1
					cCodRIRF	:= Substr(cNxRIR, nPosCRIRF, 4)
					cDirf		:= "1"
					lIpIRF		:= .T.
				EndIf
				*/
				//substitu�do bloco acima pelo abaixo [Mauro Nagata, www.compila.com.br, 20200818]
				IF SA2->A2_XCOOPER = '1'
					cCodRIRF := "3280"
					cDirf		:= "1"
					lIpIRF	:= .T.
				Else
					nPosCRIRF 	:= At( cNatur, cNxRIR ) + nTamNat + 1
					If nPosCRIRF > nTamNat + 1
						cCodRIRF	:= Substr( cNxRIR, nPosCRIRF, 4 )
						cDirf		:= "1"
						lIpIRF	:= .T.
					//inclu�do bloco abaixo [Mauro Nagata, www.compila.com.br, 20200818]
					Else
						cCodRIRF := "1708"
					//fim bloco [Mauro Nagata, www.compila.com.br, 20200818]
					EndIf
				EndIf 
				//fim bloco [Mauro Nagata, www.compila.com.br, 20200818]
			//inclu�do bloco abaixo [Mauro Nagata, www.compila.com.br, 20200818]
			Else 
				cCodRIRF	:= ""
				cDirf		:= "2"
				lIpIRF	:= .F.
			//fim bloco [Mauro Nagata, www.compila.com.br, 20200818]
			EndIf
				
			//Reten��o PIS
			If SED->ED_CALCPIS == "S" .And. SED->ED_PERCPIS > 0
				nPosCRPIS 	:= At( cNatur, cNxRPIS ) + nTamNat + 1
				If nPosCRPIS > nTamNat + 1
					cCodRPIS	:= Substr(cNxRPIS, nPosCRPIS, 4)
				//inclu�do bloco abaixo [Mauro Nagata, www.compila.com.br, 20200818]
				Else
					cCodRPIS := "5952"
				//fim bloco [Mauro Nagata, www.compila.com.br, 20200818]
				EndIf
			//inclu�do bloco abaixo [Mauro Nagata, www.compila.com.br, 20200818]
			Else 
				cCodRPIS	:= ""
			//fim bloco [Mauro Nagata, www.compila.com.br, 20200818]
			EndIf	
			
	
			//Reten��o COFINS
			If SED->ED_CALCCOF == "S" .And. SED->ED_PERCCOF > 0
				nPosCRCOF 	:= At( cNatur, cNxRCOF ) + nTamNat + 1
				If nPosCRCoF > nTamNat + 1
					cCodRCOF	:= Substr( cNxRCOF, nPosCRCOF, 4 )
				//inclu�do bloco abaixo [Mauro Nagata, www.compila.com.br, 20200818]
				Else
					cCodRCOF := "5952"
				//fim bloco [Mauro Nagata, www.compila.com.br, 20200818]
				EndIf
			//inclu�do bloco abaixo [Mauro Nagata, www.compila.com.br, 20200818]
			Else 
				cCodRCOF	:= ""
			//fim bloco [Mauro Nagata, www.compila.com.br, 20200818]
			EndIf	
			
	
			//Reten��o CSLL
			If SED->ED_CALCCSL == "S" .And. SED->ED_PERCCSL > 0
				nPosCRCSL 	:= At(cNatur, cNxRCSL) + nTamNat + 1
				If nPosCRCSL > nTamNat + 1
					cCodRCSL	:= Substr( cNxRCSL, nPosCRCSL, 4 )
				//inclu�do bloco abaixo [Mauro Nagata, www.compila.com.br, 20200818]
				Else
					cCodRCSL := "5952"
				//fim bloco [Mauro Nagata, www.compila.com.br, 20200818]
				EndIf
			//inclu�do bloco abaixo [Mauro Nagata, www.compila.com.br, 20200818]
			Else 
				cCodRCSL	:= ""
				//fim bloco [Mauro Nagata, www.compila.com.br, 20200818]
			EndIf	
			
			//salvando no t�tulo principal
			RecLock( "SE2", .F. )
			SE2->E2_CODRET		:= cCodRIRF		//c�digo de reten��o IRRF t�tulo principal
			SE2->E2_CODRPIS	:= cCodRPIS		//c�digo de reten��o PIS t�tulo principal
			SE2->E2_CODRCOF	:= cCodRCOF		//c�digo de reten��o COFINS t�tulo principal
			SE2->E2_CODRCSL	:= cCodRCSL		//c�digo de reten��o CSLL t�tulo principal
			SE2->E2_DIRF		:= "2"			//DIRF n�o
			//inclu�do bloco abaixo [Mauro Nagata, www.compila.com.br, 20200821]
			If ( !Empty( cCodRPIS ) .Or. !Empty( cCodRCOF ) .Or. !Empty( cCodRCSL ) ) .And. GetMV( "MV_BX10925" ) = "1"
				If Empty( cCodRIRF )
					SE2->E2_CODRET := If( !Empty( cCodRPIS ), cCodRPIS, If( !Empty( cCodRCOF ), cCodRCOF, cCodRCSL ) )
				EndIf
				SE2->E2_DIRF		:= "1"			//DIRF sim
			EndIf 
			//fim bloco [Mauro Nagata, www.compila.com.br, 20200821]
			SE2->(MsUnLock())
			
			DbSkip()
			

			//salvando nos t�tulos dos impostos 
			Do While !Eof() .And. SE2->E2_FILIAL = xFilial( "SE2" ) .And. SE2->E2_PREFIXO = cSerSF1 .And. SE2->E2_NUM = cDocSF1
			
				//natureza e valor IRRF
				//If cNatIRF = SE2->E2_NATUREZ .And. SE2->E2_IRRF = nVlrIRF
				//substitu�da linha acima pela abaixo [Mauro Nagata, www.compila.cm.br, 20201202]
				If AllTrim(SE2->E2_NATUREZ) $ cNatIRF .And. SE2->E2_VALOR = nVlrIRF
					RecLock( "SE2", .F. )
					SE2->E2_CODRET	:= cCodRIRF
					SE2->E2_DIRF	:= "1"
					SE2->( MsUnLock() )
				EndIf
				
				//natureza e valor PIS
				//If cNatPIS = SE2->E2_NATUREZ .And. SE2->E2_PIS = nVlrPIS
				//substitu�da linha acima pela abaixo [Mauro Nagata, www.compila.cm.br, 20201202]
				If AllTrim(SE2->E2_NATUREZ) $ cNatPIS .And. SE2->E2_VALOR = nVlrPIS
					RecLock("SE2",.F.)
					SE2->E2_CODRET	:= cCodRPIS 
					SE2->E2_DIRF	:= "1"
					SE2->( MsUnLock() )
				EndIf
				
				//natureza e valor COFINS
				//If cNatCOF = SE2->E2_NATUREZ .And. SE2->E2_COFINS = nVlrCOF
				//substitu�da linha acima pela abaixo [Mauro Nagata, www.compila.cm.br, 20201202]
				If AllTrim(SE2->E2_NATUREZ) $ cNatCOF .And. SE2->E2_VALOR = nVlrCOF
					RecLock( "SE2", .F. )
					SE2->E2_CODRET	:= cCodRCOF
					SE2->E2_DIRF	:= "1"
					SE2->( MsUnLock() )
				EndIf
			
				//natureza e valor CSLL
				//If cNatCSL = SE2->E2_NATUREZ .And. SE2->E2_CSLL = nVlrCSL
				//substitu�da linha acima pela abaixo [Mauro Nagata, www.compila.cm.br, 20201202]
				If AllTrim(SE2->E2_NATUREZ) $ cNatCSL .And. SE2->E2_VALOR = nVlrCSL

					RecLock( "SE2", .F. ) 
					SE2->E2_CODRET	:= cCodRCSL
					SE2->E2_DIRF	:= "1"
					SE2->( MsUnLock() )
				EndIf
				
				//inclu�do bloco abaixo [Mauro Nagata, www.compila.com.br, 20200819]
				//natureza e valor PCC acumulado
				If AllTrim(SE2->E2_NATUREZ) $ cNatCSL .And. SE2->E2_VALOR = nVlrPIS + nVlrCOF + nVlrCSL .And. cTipoTit = "TX "
					RecLock( "SE2", .F. ) 
					SE2->E2_CODRET	:= cCodRCSL
					SE2->E2_DIRF	:= "1"
					SE2->( MsUnLock() )
				EndIf
				//fim bloco [Mauro Nagata, www.compila.com.br, 20200819]

				DbSelectArea( "SE2" )
				DbSkip()
			EndDo
		EndIf
	EndIf

EndIf

SED->( RestArea( aArea ) )
SE2->( RestArea( aArea ) ) 
RestArea( aArea )

Return
