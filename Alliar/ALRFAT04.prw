#INCLUDE "TOTVS.CH"
#INCLUDE "TOPCONN.CH"   

/*/{Protheus.doc} ALRFAT04
Executa ajustes nas tabelas SD2, SF2, SFT e SE1 no fim da gravacao do Doc. Saida.
@author Leandro Oliveira
@since 27/11/2015
@version 1.0
/*/
User Function ALRFAT04(lRetVlr)
Local aRet		:= {}
Default lRetVlr	:= .F.

	Private cFilialNF 	:= SF2->F2_FILIAL
	Private cCliente 	:= SF2->F2_CLIENTE
	Private cLoja 		:= SF2->F2_LOJA
	Private cNota  		:= SF2->F2_DOC
	Private cSerie 		:= SF2->F2_SERIE
	Private cTribCli 	//:= Posicione("SA1", 1, xFilial("SA1") + cCliente + cLoja, "A1_XTRIBES")
	Private cBloq		:= SC5->C5_XBLQ
	Private nValPis		:= 0
	Private nValCofins 	:= 0
	Private nValCsll   	:= 0
	Private nValIr		:= 0
	Private nValInss    := 0
	Private nBCPis 		:= 0
	Private nBCCofins 	:= 0
	Private nBCCsll 	:= 0
	Private nBCIr 		:= 0
	Private nBCInss		:= 0
	Private nPerPis 	:= 0
	Private nPerCofins 	:= 0
	Private nPerCsll 	:= 0
	Private nPerIr 		:= 0
	Private nPerInss 	:= 0
	
	/*----------------------------------------
		20/06/2019 - Jonatas Oliveira - Compila
		Tratativa para verificar os tributos 
		variaveis na tabela ZZA antes de verificar
		no cadastro de clientes		
	------------------------------------------*/
	DbSelectArea('SA1')
	DbSetOrder(1)
	SA1->( DbSeek(xFilial("SA1") + cCliente + cLoja)  )
	
	DBSELECTAREA("ZZA")
	ZZA->(DBSETORDER(1))//|ZZA_FILIAL+ZZA_CODCLI+ZZA_LOJA|
	
	If ZZA->(DBSEEK(SC5->C5_FILIAL + cCliente + cLoja ))
		IF !EMPTY(ZZA->ZZA_XTRIBE)
			cTribCli := ZZA->ZZA_XTRIBE
		ELSE
			cTribCli := SA1->A1_XTRIBES
		ENDIF 
	Else
		cTribCli := SA1->A1_XTRIBES
	Endif
	
	//If(!Empty(cTribCli) .and. cBloq != "4", Alert("Tributos retidos na fonte nao informado. Favor conferir a NF."),"")
	IF lRetVlr
		SomaTribs()
	
		AADD(aRet, nBCPis)			//| 1
		AADD(aRet, nPerPis)	        //| 2
		AADD(aRet, nValPis)		    //| 3

		AADD(aRet, nBCCofins)       //| 4
		AADD(aRet, nPerCofins)      //| 5
		AADD(aRet, nValCofins)	    //| 6

		AADD(aRet, nBCCsll)         //| 7
		AADD(aRet, nPerCsll)        //| 8
		AADD(aRet, nValCsll)        //| 9

		AADD(aRet, nBCIr)	        //| 10
		AADD(aRet, nPerIr)	        //| 11
		AADD(aRet, nValIr)	        //| 12

		AADD(aRet, nBCInss)         //| 13
		AADD(aRet, nPerInss)        //| 14
		AADD(aRet, nValInss)        //| 15		
	ELSE
		If(cTribCli $ "F,V")  // .AND. cBloq $ "4")
			cCalc := .F.
			SomaTribs()	
			UpdSF2()
			UpdSD2()
			UpdSE1()
		Else

			// ***************************************************************************************
			// HFP - Compila
			// tratamento, para quando a tela customizada, nao for configurada no cliente, 
			// nao entrar nas rotinas abaixo, mesmo que cancelado ela, e calculando erroneamente
			// os impostos.
			// * task imposto calculando IR menor 10
			// ***************************************************************************************
	
			IF SA1->A1_XTELTRI == "S"  //hfp
				cCalc := .T.
				SomaTribs()	
				UpdSE1() 

			ENDIF  //hfp
				
		Endif
	ENDIF
	
Return(aRet)


Static Function SomaTribs()

	Local cQry := "" 

	cQry := "SELECT SUM(C6_XVTRPIS) as VrPis, SUM(C6_XVTRCOF) as VrCof, SUM(C6_XVTRCSL) as VrCsl, SUM(C6_XVTRIRF) as VrIrf, SUM(C6_XVTRINS) as VrIns, "
	cQry += " SUM(C6_XBSPIS)  as BsPis, SUM(C6_XBSCOF)  as BsCof, SUM(C6_XBSCSL)  as BsCsl, SUM(C6_XBSIRF) as BsIrf, SUM(C6_XBSINS) as Bsins, "
	cQry += " SUM(C6_XALPIS) / Count(*) as AlPis, SUM(C6_XALCOF) / Count(*) as AlCof, SUM(C6_XALCSL) / Count(*) as AlCsl, " 
	cQry += " SUM(C6_XALIRF) / Count(*) as AlIrf, SUM(C6_XALINS) / Count(*) as Alins FROM "+RetSqlName("SC6")
	cQry += " WHERE C6_FILIAL = '"+cFilialNF+"' AND C6_NOTA+C6_SERIE = '"+cNota+cSerie+"' AND C6_CLI+C6_LOJA = '"+cCliente+cLoja+"' AND D_E_L_E_T_ = '' ; "
	 	
	TCQUERY cQry NEW ALIAS "temp"


	temp->(dbGoTop()) 
		nValPis		:= temp->VrPis
		nValCofins 	:= temp->VrCof
		nValCsll	:= temp->VrCsl
		nValIr  	:= temp->VrIrf
		nValInss	:= temp->VrIns
		nBCPis 		:= temp->BsPis
		nBCCofins	:= temp->BsCof
		nBCCsll 	:= temp->BsCsl
		nBCIr		:= temp->BsIrf
		nBCInss		:= temp->Bsins
		nPerPis		:= temp->AlPis
		nPerCofins	:= temp->AlCof
		nPerCsll	:= temp->AlCsl
		nPerIr 		:= temp->AlIrf
		nPerInss	:= temp->Alins 
	temp->(dbCloseArea()) 	
		
Return


Static Function UpdSF2()
	If SF2->( RecLock("SF2",.F.) )
	
		SF2->F2_BASEINS := nBCInss
		SF2->F2_VALINSS := nValInss
		
		SF2->F2_BASEIRR := nBCIr
		SF2->F2_VALIRRF := nValIr
		
		SF2->F2_BASPIS := nBCPis
		SF2->F2_VALPIS := nValPis
		
		SF2->F2_BASCOFI := nBCCofins
		SF2->F2_VALCOFI := nValCofins
		
		SF2->F2_BASCSLL := nBCCsll
		SF2->F2_VALCSLL := nValCsll
		
		SF2->( MsUnlock() )
	endif
Return


Static Function UpdSD2()
	if SD2->( MsSeek(xFilial("SD2")+SF2->F2_DOC+SF2->F2_SERIE+SF2->F2_CLIENTE+SF2->F2_LOJA) )
		
		While SD2->(! Eof()) .AND. SF2->F2_DOC == SD2->D2_DOC .AND. SF2->F2_SERIE == SD2->D2_SERIE ;
								.AND. SF2->F2_CLIENTE == SD2->D2_CLIENTE .AND. SF2->F2_LOJA    == SD2->D2_LOJA
			
			If SD2->(RecLock("SD2",.F.))

				SD2->D2_BASEPIS := nBCPis
				SD2->D2_VALPIS := nValPis
				SD2->D2_ALQPIS := nPerPis
				
				SD2->D2_BASEINS := nBCInss
				SD2->D2_ALIQINS := nPerInss
				SD2->D2_VALINS := nValInss
				
				SD2->D2_BASEIRR := nBCIr
				SD2->D2_ALQIRRF := nPerIr
				SD2->D2_VALIRRF := nValIr
				
				SD2->D2_BASECOF := nBCCofins
				SD2->D2_VALCOF := nValCofins
				SD2->D2_ALQCOF := nPerCofins
				
				SD2->D2_BASECSL := nBCCsll
				SD2->D2_VALCSL := nValCsll
				SD2->D2_ALQCSL := nPerCsll
								
				SD2->( MsUnlock() )
				
				UpdSFT(SD2->D2_SERIE, SD2->D2_DOC, SD2->D2_CLIENTE, SD2->D2_LOJA, SD2->D2_ITEM,SD2->D2_COD)
				
				SD2->( dbSkip() )
			Endif
		EndDo
	Endif
Return


Static Function UpdSFT(cSerie, cDoc, cCli, cLoja, cItem, cProd)

	Local nTamFTIt	:= TamSX3("FT_ITEM")[01]

	SFT->( dbSetOrder(1) )
	if SFT->(MsSeek(xFilial("SFT")+"S"+cSerie+cDoc+cCli+cLoja+Padr(cItem,nTamFTIt)+cProd))
		if SFT->( Reclock("SFT",.F.) )
			SFT->FT_BASEINS := nBCInss
			SFT->FT_VALINS := nValInss
			SFT->FT_ALIQINS := nPerInss
			
			SFT->FT_BASEIRR := nBCIr
			SFT->FT_VALIRR := nValIr
			SFT->FT_ALIQIRR := nPerIr
			
			SFT->FT_BRETPIS := nBCPis
			SFT->FT_VRETPIS := nValPis
			SFT->FT_ARETPIS := nPerPis
			
			SFT->FT_BRETCOF := nBCCofins
			SFT->FT_VRETCOF := nValCofins
			SFT->FT_ARETCOF := nPerCofins
			
			SFT->FT_BRETCSL := nBCCsll
			SFT->FT_VRETCSL := nValCsll
			SFT->FT_ARETCSL := nPerCsll
			
			SFT->( MsUnlock() )
		endif
	endif
Return

Static Function UpdSE1()
	Local aArea 	:= GetArea()
	Local aAreaE1	:= SE1->(GetArea())
	Local aAreaF2	:= SF2->(GetArea())

	DbSelectArea("SE1")
	dbSetOrder(1)		//E1_FILIAL, E1_PREFIXO, E1_NUM, E1_TIPO

	If SE1->(dbSeek(xFilial("SE1") + SF2->F2_SERIE + SF2->F2_DOC))

		While !SE1->(Eof()) .AND. xFilial("SE1") + SF2->F2_SERIE + SF2->F2_DOC == SE1->E1_FILIAL + SE1->E1_PREFIXO + SE1->E1_NUM
			If AllTrim(SE1->E1_TIPO) $ "NF/RPS/NFE/NFS"
				nNaturez	:= Posicione("SED",1,xFilial("SED")+ SE1->E1_NATUREZ, "ED_CODIGO")
				nPerCsll	:= (SED->ED_PERCCSLL / 100)
				nPercPIS	:= (SED->ED_PERCPIS / 100)
				nPercCof	:= (SED->ED_PERCCOF / 100)

		   		
				// HFP - Compila 
				// Aqui revisado o problema IRR menor que 10.
				//   nao será preciso intervir, pois qdo tela customizada nao for chamada,
				//   ele nao entra aqui.
			
				If SE1->E1_PARCELA == '001' .OR. Empty(SE1->E1_PARCELA)
					Reclock("SE1", .F.)		
					SE1->E1_BASEIRF	:= nBCIr
					SE1->E1_IRRF	:= nValIr
					SE1->E1_VRETIRF	:= nValIr

					SE1->E1_INSS 		:= nValInss
					SE1->E1_BASEPIS	    := nBCPis // nPercPis * SE1->E1_BASEPIS  // nBCPis
					SE1->E1_PIS 		:= nValPis // NoRound(SE1->E1_BASEPIS * nPercPis, 2)  //0.0065  // nValPis
					SE1->E1_BASECOF 	:= nBCCofins  // nPercCof * SE1->E1_BASECOF  // nBCCofins
					SE1->E1_COFINS 	    := SE1->E1_BASECOF *  nPercCof  // 0.03
					SE1->E1_BASECSL 	:= nBCCsll   //  nPercsll * SE1->E1_BASECSL  // nBCCsll
					SE1->E1_CSLL 		:= SE1->E1_BASECSL *  nPerCsll  // 0.01

					SE1->(MsUnlock())
				EndIf	
													
			ElseIf AllTrim(SE1->E1_TIPO) == "CF-"
		   		Reclock("SE1", .F.)
					SE1->E1_VALOR		:= nValCofins
					SE1->E1_SALDO		:= nValCofins
					SE1->E1_VLCRUZ	    := nValCofins
				MsUnlock()						
			ElseIf AllTrim(SE1->E1_TIPO) == "PI-"
		   		Reclock("SE1", .F.)
					SE1->E1_VALOR		:= nValPis
					SE1->E1_SALDO		:= nValPis
					SE1->E1_VLCRUZ	    := nValPis
				MsUnlock()						
			ElseIf AllTrim(SE1->E1_TIPO) == "CS-"
		   		Reclock("SE1", .F.)
					SE1->E1_VALOR		:= nValCsll
					SE1->E1_SALDO		:= nValCsll
					SE1->E1_VLCRUZ	    := nValCsll
				MsUnlock()						
			ElseIf AllTrim(SE1->E1_TIPO) == "IR-"
		   		Reclock("SE1", .F.)
					SE1->E1_VALOR		:= nValIr
 					SE1->E1_SALDO		:= nValIr
					SE1->E1_VLCRUZ	    := nValIr
				MsUnlock()						
			ElseIf AllTrim(SE1->E1_TIPO) == "IN-"
		   		Reclock("SE1", .F.)
					SE1->E1_VALOR		:= nValInss
					SE1->E1_SALDO		:= nValInss
					SE1->E1_VLCRUZ	    := nValInss
				MsUnlock()						
			EndIf

			SE1->(DbSkip())
		End
	EndIf

	RestArea(aAreaF2)
	RestArea(aAreaE1)
	RestArea(aArea)
Return NIL
