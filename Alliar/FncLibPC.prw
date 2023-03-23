#Include "PROTHEUS.CH"
#include 'TBICONN.CH'

User Function FncLibPC(nReg,nOpc,nTotal,cCodLiber,cGrupo,cObs,dRefer,oModelCT)
Local lLog			:= GetNewPar("MV_HABLOG",.F.)
Local lUsaACC 	:= WebbConfig()
Local lMta097		:= ExistBlock("MTA097")
Local lA097PCO	:= ExistBlock("A097PCO")
Local lLanPCO		:= .T.	//-- Podera ser modificada pelo PE A097PCO
Local ca097User 	:= RetCodUsr()
Local cName   	:= UsrRetName(ca097User)
Local lLiberou	:= .F.
Local nRecnoAS400	:= 1
Local cPCLib		:= ""
Local cPCUser		:= ""

Local cEnvPed		:= SuperGetMV("MV_ENVPED",.F.,"0")                                                                                                    
Local aMail		    := {}
Local aPedCom		:= {}
Local nOpMail		:= 0
Local cTit			:= ""
Local cNomeEmp	:= FWEmpName(cEmpAnt)
Local cNomeFil	:= Alltrim(FWFilialName())
Local cBody 		:= ""
Local cAprTipRev	:= ""
Local lRet			:= .T.
Local lLibOk		:= .F.

Default nTotal	:= SCR->CR_TOTAL
Default cCodLiber	:= SCR->CR_APROV
Default cGrupo 	:= SCR->CR_GRUPO
Default cObs		:= SCR->CR_OBS
Default dRefer	:= SCR->CR_DATALIB
Default oModelCT	:= NIL

SCR->(dbClearFilter())
If ( Select("SCR") > 0 )
	SCR->(dbCloseArea())
EndIf

dbSelectArea("SCR")
SCR->(dbSetOrder(1))
SCR->(dbGoTo(nReg))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Esta Rotina posiciona o Browse no proximo registro valido  ³
//³para o filtro "Nao Aprovados" pois em AS400 Top 2 apos     ³
//³a liberacao o Browse sempre era posicionado no final do    ³
//³arquivo.                                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SCR") 
SCR->(dbGoTo(nReg))

If ( SCR->CR_TIPO == "NF" )
	lLibOk := A097Lock(Substr(SCR->CR_NUM,1,Len(SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA)),SCR->CR_TIPO)
ElseIf SCR->CR_TIPO == "PC" .Or. SCR->CR_TIPO == "AE" .Or. SCR->CR_TIPO == "IP"
	lLibOk := A097Lock(Substr(SCR->CR_NUM,1,Len(SC7->C7_NUM)),SCR->CR_TIPO)
ElseIf SCR->CR_TIPO == "CP"
	lLibOk := A097Lock(Substr(SCR->CR_NUM,1,Len(SC3->C3_NUM)),SCR->CR_TIPO)
ElseIf SCR->CR_TIPO == "MD"
	lLibOk := A097Lock(Substr(SCR->CR_NUM,1,Len(CND->CND_NUMMED)),SCR->CR_TIPO)
ElseIf SCR->CR_TIPO == "CT"
	lLibOk := A097Lock(Substr(SCR->CR_NUM,1,Len(CN9->CN9_NUMERO)),SCR->CR_TIPO)
ElseIf SCR->CR_TIPO == "GA" // Documento de Garantia (SIGAJURI)
	lLibOk := A097Lock(SCR->CR_NUM,SCR->CR_TIPO)			
ElseIf SCR->CR_TIPO == "SC" // Solicitação de Compras (SIGACOM)
	lLibOk := A097Lock(SCR->CR_NUM,SCR->CR_TIPO)
ElseIf	SCR->CR_TIPO == "SA" // Solicitação ao Armazém (SIGAEST)
	lLibOk := A097Lock(SCR->CR_NUM,SCR->CR_TIPO)
ElseIf	SCR->CR_TIPO == "ST" // Solicitação de transferência (SIGAEST)
	lLibOk := A097Lock(SCR->CR_NUM,SCR->CR_TIPO)	
ElseIf SCR->CR_TIPO == "RV"
	lLibOk := A097Lock(Substr(SCR->CR_NUM,1,Len(CN9->CN9_NUMERO) + Len(CN9->CN9_REVISA)),SCR->CR_TIPO)
EndIf
If lLibOk
	Begin Transaction
		If lMta097 .And. nOpc == 2
			If ExecBlock("MTA097",.F.,.F.)
				lLiberou := MaAlcDoc({SCR->CR_NUM,SCR->CR_TIPO,nTotal,cCodLiber,,cGrupo,,,,,cObs},dRefer,If(nOpc==2,4,6))
			EndIf
		Else
			lLiberou := MaAlcDoc({SCR->CR_NUM,SCR->CR_TIPO,nTotal,cCodLiber,,cGrupo,,,,,cObs},dRefer,If(nOpc==2,4,6))
		EndIf
		
		If lA097PCO
			lLanPCO := ExecBlock("A097PCO",.F.,.F.,{SC7->C7_NUM,cName,lLanPCO})
		Endif
		
		//-- Apenas o PE A097PCO pode alterar o valor de lA097PCO
		//-- Se ele nao existir ela devera seguir o valor da liberacao (lLiberou)
		If !lA097PCO
			lLanPCO := lLiberou
		EndIf
		
		If lLanPCO
			PcoIniLan("000055")			
		EndIf 		
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Envia e-mail ao comprador ref. Liberacao do pedido para compra- 034³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ  
		If lLiberou
			cPCLib  := SC7->C7_NUM
			cPCUser := SC7->C7_USER	
			MEnviaMail("034",{cPCLib,SCR->CR_TIPO},cPCUser) 				
		Endif
		If lLiberou .or. lLanPCO
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Grava os lancamentos nas contas orcamentarias SIGAPCO    ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lLanPCO
				PcoDetLan("000055","02","MATA097")
			EndIf

			If lLiberou .and. (SCR->CR_TIPO == "NF")
				dbSelectArea("SF1")
				Reclock("SF1",.F.)
				SF1->F1_STATUS := If(SF1->F1_STATUS=="B"," ",SF1->F1_STATUS)
				MsUnlock()
			ElseIf (SCR->CR_TIPO == "PC" .Or. SCR->CR_TIPO == "AE")
				If lLiberou .And. SuperGetMv("MV_EASY")=="S" .And. !Empty(SC7->C7_PO_EIC)
					If SW2->(MsSeek(xFilial("SW2")+SC7->C7_PO_EIC)) .AND. !Empty(SW2->W2_CONAPRO)
						Reclock("SW2",.F.)
						SW2->W2_CONAPRO := "L"
						MsUnlock()
					EndIf
				EndIf
				dbSelectArea("SC7")
				cPCLib := SC7->C7_NUM
				cPCUser:= SC7->C7_USER
				While !SC7->(Eof()) .And. SC7->C7_FILIAL+Substr(SC7->C7_NUM,1,len(SC7->C7_NUM)) == xFilial("SC7")+Substr(SCR->CR_NUM,1,len(SC7->C7_NUM))
					If lLiberou
						Reclock("SC7",.F.)
						SC7->C7_CONAPRO := "L"
						MsUnlock()
						//Caio.Santos - 11/01/13 - Req.72
						If lLog
							RSTSCLOG("LIB",1,/*cUsrWF*/)
						EndIf
						If ExistBlock("MT097APR")
							ExecBlock("MT097APR",.F.,.F.)      
						EndIf
						
						//Alimenta array para envio de email
						If cEnvPed $ "1|2"
							aMail	:= {AllTrim(POSICIONE('SA2', 1, xFilial('SA2') + SC7->(C7_FORNECE+C7_LOJA), 'A2_EMAIL'))}
							If !(Empty(aMail[1]))
								If Empty(Len(aPedCom))
									Aadd(aPedCom,SC7->C7_NUM)
									Aadd(aPedCom,AllTrim(POSICIONE('SA2', 1, xFilial('SA2') + SC7->(C7_FORNECE+C7_LOJA), 'A2_NOME')) + " - " + AllTrim(SC7->C7_FORNECE) + "/" + SC7->C7_LOJA)
									Aadd(aPedCom,cNomeEmp + " - " + cNomeFil)
									Aadd(aPedCom,C7_CONTATO)
									Aadd(aPedCom,{})
								EndIf
								Aadd(aPedCom[5],{	SC7->C7_ITEM,;
													SC7->C7_PRODUTO,;
													POSICIONE('SB1', 1, xFilial('SB1') + SC7->C7_PRODUTO, 'B1_DESC'),;
													SC7->C7_UM,;
													SC7->C7_QUANT,;
													SC7->C7_PRECO,;
													SC7->C7_TOTAL,;
													SC7->C7_DATPRF;
												})
							EndIf
						EndIf
						
					EndIf
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Grava os lancamentos nas contas orcamentarias SIGAPCO    ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If lLanPCO
						PcoDetLan("000055","01","MATA097")
					EndIf
					SC7->(dbSkip())
				EndDo
				
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Integracao ACC envia aprovacao do pedido            ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				SC7->(dbSkip(-1))
				If lLiberou .and. lUsaACC .And. !Empty(SC7->C7_ACCNUM)
					If IsBlind()
						Webb533(SC7->C7_NUM)
					Else
						MsgRun('Aguarde, comunicando aprovação ao portal... ## Portal ACC','Aguarde, comunicando aprovação ao portal... ## Portal ACC',{|| Webb533(SC7->C7_NUM)})	//Aguarde, comunicando aprovação ao portal... ## Portal ACC
					EndIf
				EndIf
				
			ElseIf lLiberou .and. SCR->CR_TIPO == "CP"
				dbSelectArea("SC3")
				While !SC3->(Eof()) .And. SC3->C3_FILIAL+Substr(SC3->C3_NUM,1,len(SC3->C3_NUM)) == xFilial("SC3")+Substr(SCR->CR_NUM,1,len(SC3->C3_NUM))
					Reclock("SC3",.F.)
					SC3->C3_CONAPRO := "L"
					MsUnlock()
					dbSkip()
				EndDo
			ElseIf lLiberou .and. SCR->CR_TIPO == "MD"
				dbSelectArea("CND")
				dbSetOrder(4)
				If CND->(dbSeek(xFilial("CND")+SCR->CR_NUM))
					Reclock("CND",.F.)
					CND->CND_ALCAPR := "L"
					MsUnlock()
					If ExistBlock("MT097APR")
						ExecBlock("MT097APR",.F.,.F.)
					EndIf
				EndIf
			ElseIf lLiberou .and. SCR->CR_TIPO == "CT"
				dbSelectArea("CN9")
				dbSetOrder(1)
				If dbSeek(xFilial("CN9")+SCR->CR_NUM)
					Reclock("CN9",.F.)
					CN9->CN9_SITUAC := "05" //Vigente 
					CN9->CN9_DTASSI := dDataBase
					MsUnlock()
				EndIf
			ElseIf lLiberou .and. SCR->CR_TIPO == "GA" // Documento de Garantia (SIGAJURI)
				dbSelectArea("NV3")
				dbSetOrder(1)												
				If dbSeek(xFilial("NV3")+Substr(AllTrim(SCR->CR_NUM),4,Len(AllTrim(SCR->CR_NUM))))				
					If !JurGerPag(3,'NT2',SCR->CR_TOTAL,NV3->NV3_CAJURI,NV3->NV3_CODLAN,'2','NV3',1)
						DisarmTransaction()  // Problema ao gerar Contas a Pagar
					EndIf										
				EndIf
				
			ElseIf lLiberou .And. SCR->CR_TIPO == "SC" // Solicitação de Compras(SIGACOM)
              SC1->(dbSetOrder(1))            			
				DBM->(dbSetOrder(3))
				DBM->(dbSeek(xFilial("DBM")+SCR->(CR_TIPO+CR_NUM+CR_GRUPO+CR_ITGRP+CR_APROV+CR_APRORI)))
				While DBM->(!EOF()) .And. DBM->(DBM_FILIAL+DBM_TIPO+DBM_NUM+DBM_GRUPO+DBM_ITGRP+DBM_USAPRO+DBM_USAPOR) == SCR->(CR_FILIAL+CR_TIPO+CR_NUM+CR_GRUPO+CR_ITGRP+CR_APROV+CR_APRORI)
	             	If MtGLastDBM(SCR->CR_TIPO,DBM->DBM_NUM,DBM->DBM_ITEM) //-- Verifica se é o ultimo item de aprovação
                    	If SC1->(dbSeek(xFilial("SC1")+DBM->(PadR(DBM_NUM,TamSX3("C1_NUM")[1])+PadR(DBM_ITEM,TamSX3("C1_ITEM")[1]))))
                    		Reclock("SC1",.F.)
                    		SC1->C1_APROV := "L"
                    		SC1->(MsUnlock())
                    	EndIf
                  EndIf
                  DBM->(dbSkip())
				End
                                        
			ElseIf lLiberou .And. SCR->CR_TIPO == "SA"	// Solicitação ao Armazém(SIGAEST)
				SCP->(dbSetOrder(1))
				DBM->(dbSetOrder(3))
				DBM->(dbSeek(xFilial("DBM")+SCR->(CR_TIPO+CR_NUM+CR_GRUPO+CR_ITGRP+CR_APROV+CR_APRORI)))
				While DBM->(!EOF()) .And. DBM->(DBM_FILIAL+DBM_TIPO+DBM_NUM+DBM_GRUPO+DBM_ITGRP+DBM_USAPRO+DBM_USAPOR) == SCR->(CR_FILIAL+CR_TIPO+CR_NUM+CR_GRUPO+CR_ITGRP+CR_APROV+CR_APRORI)
                 If MtGLastDBM(SCR->CR_TIPO,DBM->DBM_NUM,DBM->DBM_ITEM) //-- Verifica se é o último item de aprovação
                 		If SCP->(dbSeek(xFilial("SCP")+DBM->(PadR(DBM_NUM,TamSX3("CP_NUM")[1])+PadR(DBM_ITEM,TamSX3("CP_ITEM")[1]))))
                    		Reclock("SCP",.F.)
                    		SCP->CP_STATSA := "L"
                   		SCP->(MsUnlock())
                 		EndIf
                 	EndIf
              	DBM->(dbSkip())
				End
                
			ElseIf lLiberou .And. SCR->CR_TIPO == "IP" // Item do Pedido (SIGACOM)
				SC7->(dbSetOrder(1))
				DBM->(dbSetOrder(3))
				DBM->(dbSeek(xFilial("DBM") + SCR->CR_TIPO + SCR->CR_NUM + SCR->CR_GRUPO + SCR->CR_ITGRP + SCR->CR_APROV + SCR->CR_APRORI))
				
				While DBM->(!EOF())
					If DBM->DBM_FILIAL + DBM->DBM_TIPO + DBM->DBM_NUM + DBM->DBM_GRUPO + DBM->DBM_ITGRP + DBM->DBM_USAPRO + DBM->DBM_USAPOR == SCR->CR_FILIAL + SCR->CR_TIPO + SCR->CR_NUM + SCR->CR_GRUPO + SCR->CR_ITGRP + SCR->CR_APROV + SCR->CR_APRORI
		             	If MtGLastDBM(SCR->CR_TIPO,DBM->DBM_NUM,DBM->DBM_ITEM) //-- Verifica se é o ultimo item de aprovação
	                 		If SC7->(dbSeek(xFilial("SC7") + PadR(DBM->DBM_NUM,TamSX3("C7_NUM")[1]) + PadR(DBM->DBM_ITEM,TamSX3("C7_ITEM")[1]))) .And. Empty(SC7->C7_APROV)
	                    		If Reclock("SC7",.F.)
	                    			SC7->C7_CONAPRO := "L"
	                    			SC7->(MsUnlock())
	                    		Endif
	                    	EndIf
	                 	EndIf
					Endif
              	DBM->(dbSkip())
				Enddo
				
				If MtGLastDBM(SCR->CR_TIPO,SCR->CR_NUM) 
					IF !Empty(SC7->C7_APROV) 
						lRet := MaAlcDoc({SC7->C7_NUM,"PC",A097TotPC(SC7->C7_NUM),,,SC7->C7_APROV,,SC7->C7_MOEDA,SC7->C7_TXMOEDA,SC7->C7_EMISSAO},SC7->C7_EMISSAO,1)
					EndIf
					
					If lRet
						//Alimenta array para envio de email
						SC7->(dbSeek(xFilial("SC7") + PadR(DBM->DBM_NUM,TamSX3("C7_NUM")[1])))
						
						While SC7->(!EoF())
							If PadR(DBM->DBM_NUM,TamSX3("C7_NUM")[1]) == PadR(SC7->C7_NUM,TamSX3("C7_NUM")[1])
								If cEnvPed $ "1|2" .And. !Empty(SC7->C7_APROV)
									aMail	:= {AllTrim(POSICIONE('SA2', 1, xFilial('SA2') + SC7->C7_FORNECE + SC7->C7_LOJA, 'A2_EMAIL'))}
									
									If !Empty(aMail[1])
										If Empty(Len(aPedCom))
											Aadd(aPedCom,SC7->C7_NUM)
											Aadd(aPedCom,AllTrim(POSICIONE('SA2', 1, xFilial('SA2') + SC7->C7_FORNECE + SC7->C7_LOJA, 'A2_NOME')) + " - " + AllTrim(SC7->C7_FORNECE) + "/" + SC7->C7_LOJA)
											Aadd(aPedCom,cNomeEmp + " - " + cNomeFil)
											Aadd(aPedCom,SC7->C7_CONTATO)
											Aadd(aPedCom,{})
										EndIf
										Aadd(aPedCom[5],{	SC7->C7_ITEM,;
															SC7->C7_PRODUTO,;
															POSICIONE('SB1', 1, xFilial('SB1') + SC7->C7_PRODUTO, 'B1_DESC'),;
															SC7->C7_UM,;
															SC7->C7_QUANT,;
															SC7->C7_PRECO,;
															SC7->C7_TOTAL,;
															SC7->C7_DATPRF;
														})
									EndIf
								EndIf
							Endif
							SC7->(DbSkip())
						EndDo
					EndIf
				EndIf
				
			Elseif lLiberou .And. SCR->CR_TIPO == "ST"
				Reclock("NNS",.F.)
					NNS->NNS_STATUS := "1"
				NNS->(MsUnlock())
				
			ElseIf lLiberou .and. SCR->CR_TIPO == "RV"		
				
				If oModelCT:VldData()
					oModelCT:CommitData()	
					oModelCT:DeActivate()
				Else
					lLiberou := .F.		
				EndIf
				
			EndIf
			
			If ExistBlock("MT097APR")
				ExecBlock("MT097APR",.F.,.F.)
			EndIf
				
		EndIf
		
		If lLanPCO
			//-- Finaliza a gravacao dos lancamentos do SIGAPCO
			PcoFinLan("000055")
		EndIf		
		
		//Envia email para fornecedor.
		If cEnvPed $ "1|2" .And. lRet .And. Len(aMail) > 0 .And. !Empty(aMail[1])
			nOpMail := 2
			cTit 	:= cNomeEmp + " - " + cNomeFil + " - Pedido de Compra " + SC7->C7_NUM
			cBody 	:= A120GerMail(aPedCom,nOpMail)
				
			If !MTSendMail(aMail,cTit,cBody)
				MsgInfo(OemToAnsi('Erro ao enviar E-Mail')+cMail,OemToAnsi('Erro ao enviar E-Mail'))//"Erro ao enviar E-Mail"
			EndIf
		EndIf
		
	End Transaction
Else
	Help(" ",1,"A097LOCK")
Endif

If SCR->CR_TIPO == "NF"
	SF1->(MsUnlockAll())
ElseIf SCR->CR_TIPO == "PC" .Or. SCR->CR_TIPO == "AE" .Or. SCR->CR_TIPO == "IP"
	SC7->(MsUnlockAll())
ElseIf SCR->CR_TIPO == "SC"
	SC1->(MsUnlockAll())
ElseIf SCR->CR_TIPO == "SA"
	SCP->(MsUnlockAll())
ElseIf SCR->CR_TIPO == "CP"
	SC3->(MsUnlockAll())
ElseIf SCR->CR_TIPO == "MD"
	CND->(MsUnlockAll())
ElseIf SCR->CR_TIPO == "RV"
	CN9->(MsUnlockAll())
EndIf

Return .T.