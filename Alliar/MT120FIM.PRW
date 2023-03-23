#Include "PROTHEUS.CH"

User Function MT120FIM()

	Local lCopia  := IsInCallStack("A120Copia")
	//hfp Local nCount
	Local nOpca120  := If(IsInCallStack("U_AVALCOPC") .OR. (ValType(PARAMIXB[3]) == "N" .AND. PARAMIXB[3] == 1) , 1, PARAMIXB[3])
	Local lRotAuto	:= If(ValType("l120Auto") == "L" .AND. l120Auto, .T., .F.)
	Local lMudou	:= .F.

	//IF IsInCallStack("CNTA120") 

	// ****************************************************
	//abax - 20210625 - tinha sido feito pela cotacao
	// mas eles geram por pedido, entao incluindo
	// incluido aqui, para ser antes da chamada fluig
	//	FABAX02()
	// ****************************************************
	//ELSE

	If nOpca120 == 1

		If (Inclui .OR. Altera .OR. lCopia)

			//abax
			lMudou:= FVerMuda()

			// ****************************************************
			//abax - 20210625 - tinha sido feito pela cotacao
			// mas eles geram por pedido, entao incluindo
			// aqui, para ser antes da chamada fluig
			FABAX02()
			// ****************************************************

			//FnIdFlg(SC7->C7_NUM)
			If !U_RegExiste("SCR", xFilial("SCR", SC7->C7_FILIAL) + "PC" + SC7->C7_NUM, 1)
				If lRotAuto
					Aviso("MT120FIM", "O Pedido "+ Trim(SC7->C7_NUM) +" não possui regra de alçada definida (Tabela SCR)!"+chr(13)+ "O Pedido não será enviado ao Fluig para aprovação.", {"Fechar"})
				Else
					MsgStop("O Pedido "+ Trim(SC7->C7_NUM) +" não possui regra de alçada definida (Tabela SCR)!"+chr(13)+;
						"O Pedido não será enviado ao Fluig para aprovação.")
				EndIf
			Else

				IF lMudou .or. Inclui .OR. lCopia  //abax nao gerar id se foi alteracao apenas do tipo doc

					If lRotAuto
						MsgRun("Executando integração!", "Integração!",{||ECFLG(lRotAuto)})
					Else
						WSDLDbgLevel(2) //| Debug|
						ECFLG(lRotAuto)
					EndIf

				Endif  //l mudou

			Endif
		EndIf

	Endif

	//Endif

Return .T.


User Function tstPC(cNumPC)
	Local lRotAuto	:= .F.

	DBSELECTAREA("SC7")
	SC7->(DBSETORDER(1)) //| C7_FILIAL+C7_NUM+C7_ITEM+C7_SEQUEN
	IF SC7->(DBSEEK(xfilial("SC7")+cNumPC))
		alert("achou!")
		WSDLDbgLevel(2) //| Debug|
		ECFLG(lRotAuto)
	ENDIF



Return()


//Função para Executar o envio do Pedido para o Fluig
Static Function ECFLG(lRotAuto)
	Local FlgWS  := WSECMWorkflowEngineServiceService():new()

	Local nCount := 0
	Local nY     := 0
	Local nRet   := 0

	Local xValor := NIL

	Local cAprovMail  := ""
	Local cAprovName  := ""
	Local cRecnoList  := ""
	Local cProces     := ""

	Local aCardData   := {}
	Local lCotacao    := IsInCallStack("U_AVALCOPC")
	Local cPedido     := SC7->C7_NUM
	//hfp Local cUnidMed    := ""
	Local aAreaSC7    := SC7->(GetArea())
	Local nTotPed     := 0

	Local cNumC7 := ""
	Local cFilC7 := ""

	dbSelectArea("SCR")
	dbSetOrder(1)

	If dbSeek(xFilial("SCR", SC7->C7_FILIAL)+"PC"+SC7->C7_NUM)
		While !SCR->(Eof()) .AND. SCR->CR_FILIAL == xFilial("SCR", SC7->C7_FILIAL) .AND. SCR->CR_TIPO == "PC" .AND. AllTrim(SCR->CR_NUM) == AllTrim(SC7->C7_NUM)

			//Ordena pesquisa por id do usuário
			PswOrder(1)

			If PswSeek(SCR->CR_USER)
				if Empty(cAprovMail)
					cAprovMail := PswRet(1)[1][14]
					cAprovName := PswRet(1)[1][2]
					cRecnoList := Trim(STR(SCR->(Recno())))
				else
					cAprovMail := cAprovMail + "," + PswRet(1)[1][14]
					cAprovName := cAprovName + "," + PswRet(1)[1][2]
					cRecnoList := cRecnoList + "," + Trim(STR(SCR->(Recno())))
				endif
			EndIf

			SCR->(dbSkip())
		End
	EndIf

	FlgWs:_URL             := SuperGetMV("MV_ECMURL") + "ECMWorkflowEngineService"
	FlgWS:cusername        := SuperGetMv("MV_ECMUSER"     ,NIL ,"integrador")//GETMV("MV_USERFLG"
	FlgWS:cpassword        := SuperGetMv("MV_ECMPSW"      ,NIL ,"integrador")//GETMV("MV_PWDFLG")
	FlgWS:ncompanyId       := Val(SuperGetMv("MV_ECMEMP"  ,NIL ,1))//GETMV("MV_COMPFLG")
	FlgWS:cprocessId       := "AprovacaoPedidoDeCompras"
	FlgWS:nchoosedState	   := 40
	FlgWS:cuserID		   := SuperGetMv("MV_ECMMAT")//GETMV("MV_USIDFLG")
	FlgWS:ccomments        := ""
	FlgWS:lcompleteTask	  := .T.
	FlgWS:lmanagerMode	  := .F.

	// Informações cabeçalho da solicitação
	AddCard(@aCardData ,"approversMailList"	,cAprovMail)
	AddCard(@aCardData ,"approversList"		,cAprovName)
	AddCard(@aCardData ,"R8_CODGRUPOEMP"    ,FWGrpCompany())
	AddCard(@aCardData ,"R8_DESCGRUPOEMP"   ,FWGrpName())
	AddCard(@aCardData ,"R8_FILIAL"         ,FWCodFil())
	AddCard(@aCardData ,"R8_DESC_FILIAL"    ,FWFilialName())
	AddCard(@aCardData ,"login"             ,AllTrim(RetLogin()))
	AddCard(@aCardData ,"colleagueName"     ,AllTrim(UsrFullName(RetCodUsr())))
	AddCard(@aCardData ,"id_pedidocompra"   ,SC7->C7_NUM)
	AddCard(@aCardData ,"id_dtEmissao"      ,DTOC(SC7->C7_EMISSAO))
	AddCard(@aCardData ,"id_dtEntrega"      ,DTOC(SC7->C7_DATPRF))

	AddCard(@aCardData ,"C7_FORNECE"     	,SC7->C7_FORNECE)
	AddCard(@aCardData ,"A2_NOME"        	,Posicione("SA2",1,FWxFilial("SA2")+SC7->(C7_FORNECE+C7_LOJA),"A2_NOME"))

	AddCard(@aCardData ,"F1_XTPDOC"			,SC7->C7_XTPDOC)   //HFP TASK 22155415 e 22201925   ABAX

	AddCard(aCardData  ,"recnoList"         ,cRecnoList)



	If lCotacao
		DbSelectArea("SC7")
		DbSetOrder(1)		//C7_FILIAL, C7_NUM, C7_ITEM

		If SC7->(DbSeek(xFilial("SC7") + cPedido))

			nCount := 1

			While !SC7->(Eof()) .AND. xFilial("SC7") + cPedido == SC7->C7_FILIAL + SC7->C7_NUM

				AddCard(@aCardData ,"id_item___"+ALLTRIM(STR(nCount))          +"" ,SC7->C7_ITEM)
				AddCard(@aCardData ,"id_produto___"+ALLTRIM(STR(nCount))       +"" ,SC7->C7_PRODUTO)
				AddCard(@aCardData ,"id_um___"+ALLTRIM(STR(nCount))            +"" ,Posicione("SB1", 1, xFilial("SB1") + SC7->C7_PRODUTO, "B1_UM"))
				AddCard(@aCardData ,"id_segum___"+ALLTRIM(STR(nCount))         +"" ,SC7->C7_SEGUM)
				AddCard(@aCardData ,"id_quantidade___"+ALLTRIM(STR(nCount))    +"" ,ALLTRIM(TRANSFORM(SC7->C7_QUANT   ,"@E 999,999,999.99")))
				AddCard(@aCardData ,"prcunitario___"+ALLTRIM(STR(nCount))      +"" ,ALLTRIM(TRANSFORM(SC7->C7_PRECO   ,"@E 999,999,999.9999")))
				AddCard(@aCardData ,"vltoal___"+ALLTRIM(STR(nCount))           +"" ,ALLTRIM(TRANSFORM(SC7->C7_TOTAL   ,"@E 999,999,999.99")))
				AddCard(@aCardData ,"id_segum2___"+ALLTRIM(STR(nCount))        +"" ,ALLTRIM(TRANSFORM(SC7->C7_QTSEGUM ,"@E 999,999,999.99")))
				AddCard(@aCardData ,"id_dtnecessidade___"+ALLTRIM(STR(nCount)) +"" ,DTOC(SC7->C7_DATPRF))
				AddCard(@aCardData ,"id_armazem___"+ALLTRIM(STR(nCount))       +"" ,SC7->C7_LOCAL)
				AddCard(@aCardData ,"id_obsitem___"+ALLTRIM(STR(nCount))       +"" ,SC7->C7_OBS)
				AddCard(@aCardData ,"id_ccusto___"+ALLTRIM(STR(nCount))        +"" ,SC7->C7_CC)
				AddCard(@aCardData ,"desc_produto___"+ALLTRIM(STR(nCount))     +"" ,SC7->C7_DESCRI)
				AddCard(@aCardData ,"vlipi___"+ALLTRIM(STR(nCount))            	+"" ,ALLTRIM(TRANSFORM(SC7->C7_VALIPI   ,"@E 999,999,999.99")))

				//HFP ABAX
				AddCard(@aCardData ,"XBUDGET___"+ALLTRIM(STR(nCount))       		+"", SC7->C7_XBUDGET) //abax
				AddCard(@aCardData ,"XMOTBUD___"+ALLTRIM(STR(nCount))       		+"", SC7->C7_XMOTBUD) //abax
				cDescMot:= Posicione("Z50",1,xFilial("Z50")+SC7->C7_XMOTBUD,"Z50_DESC")
				AddCard(@aCardData  ,"XMOTDESC___"+ALLTRIM(STR(nCount))       		+"",cDescMot)

                /*----------------------------------------
                	28/09/2018 - Jonatas Oliveira - Compila
                  Adicionado campos de despesas e descontos
                ------------------------------------------*/
                
            AddCard(@aCardData ,"totalDesc"     	,SC7->C7_DESPESA)
				AddCard(@aCardData ,"totalFrete"     	,SC7->C7_SEGURO)
				AddCard(@aCardData ,"totalSeguro"     	,SC7->C7_VALFRE)
				AddCard(@aCardData ,"totalDespesa"     	,SC7->C7_VLDESC)
               
				nTotPed += SC7->C7_TOTAL + SC7->C7_VALFRE - SC7->C7_VLDESC + SC7->C7_DESPESA + SC7->C7_SEGURO
				

				nCount++			

				SC7->(DbSkip())
			End
		EndIf
		
		//Reposiciona na SC7
		RestArea(aAreaSC7)	
	Else
		for nCount := 1 to len(aCols)
			
			//Nao Considera Registros Deletados
			If !aCols[nCount][Len(aHeader)+1]
				
				AddCard(@aCardData ,"id_item___"+ALLTRIM(STR(nCount))          +"" ,aCols[nCount,aScan(aHeader,{|x| AllTrim(x[2]) == 'C7_ITEM'})])
				AddCard(@aCardData ,"id_produto___"+ALLTRIM(STR(nCount))       +"" ,aCols[nCount,aScan(aHeader,{|x| AllTrim(x[2]) == 'C7_PRODUTO'})])
				AddCard(@aCardData ,"id_um___"+ALLTRIM(STR(nCount))            +"" ,Posicione("SB1", 1, xFilial("SB1") + aCols[nCount,aScan(aHeader,{|x| AllTrim(x[2]) == 'C7_PRODUTO'})], "B1_UM"))
				AddCard(@aCardData ,"id_segum___"+ALLTRIM(STR(nCount))         +"" ,aCols[nCount,aScan(aHeader,{|x| AllTrim(x[2]) == 'C7_SEGUM'})])
				AddCard(@aCardData ,"id_quantidade___"+ALLTRIM(STR(nCount))    +"" ,ALLTRIM(TRANSFORM(aCols[nCount,aScan(aHeader,{|x| AllTrim(x[2]) == 'C7_QUANT'})]   ,"@E 999,999,999.99")))
				AddCard(@aCardData ,"prcunitario___"+ALLTRIM(STR(nCount))      +"" ,ALLTRIM(TRANSFORM(aCols[nCount,aScan(aHeader,{|x| AllTrim(x[2]) == 'C7_PRECO'})]   ,"@E 999,999,999.9999")))
				AddCard(@aCardData ,"vltoal___"+ALLTRIM(STR(nCount))           +"" ,ALLTRIM(TRANSFORM(aCols[nCount,aScan(aHeader,{|x| AllTrim(x[2]) == 'C7_TOTAL'})]   ,"@E 999,999,999.99")))
				AddCard(@aCardData ,"id_segum2___"+ALLTRIM(STR(nCount))        +"" ,ALLTRIM(TRANSFORM(aCols[nCount,aScan(aHeader,{|x| AllTrim(x[2]) == 'C7_QTSEGUM'})] ,"@E 999,999,999.99")))
				AddCard(@aCardData ,"id_dtnecessidade___"+ALLTRIM(STR(nCount)) +"" ,DTOC(aCols[nCount,aScan(aHeader,{|x| AllTrim(x[2])              == 'C7_DATPRF'})]))
				AddCard(@aCardData ,"id_armazem___"+ALLTRIM(STR(nCount))       +"" ,aCols[nCount,aScan(aHeader,{|x| AllTrim(x[2])                   == 'C7_LOCAL'})])
				AddCard(@aCardData ,"id_obsitem___"+ALLTRIM(STR(nCount))       +"" ,aCols[nCount,aScan(aHeader,{|x| AllTrim(x[2])                   == 'C7_OBS'})])
				AddCard(@aCardData ,"id_ccusto___"+ALLTRIM(STR(nCount))        +"" ,aCols[nCount,aScan(aHeader,{|x| AllTrim(x[2])                   == 'C7_CC'})])
				AddCard(@aCardData ,"desc_produto___"+ALLTRIM(STR(nCount))     +"" ,aCols[nCount,aScan(aHeader,{|x| AllTrim(x[2])                   == 'C7_DESCRI'})])
				AddCard(@aCardData ,"vlipi___"+ALLTRIM(STR(nCount))     	   +"" ,ALLTRIM(TRANSFORM(aCols[nCount,aScan(aHeader,{|x| AllTrim(x[2]) == 'C7_VALIPI'})]   ,"@E 999,999,999.99")))
				
				 /*----------------------------------------
                	28/09/2018 - Jonatas Oliveira - Compila
                  Adicionado campos de despesas e descontos
                ------------------------------------------*/
				
            AddCard(@aCardData ,"totalDesc"     	,ALLTRIM(TRANSFORM(aCols[nCount,aScan(aHeader,{|x| AllTrim(x[2]) == 'C7_VLDESC'})]   ,"@E 999,999,999.99")))            	
				AddCard(@aCardData ,"totalFrete"     	,ALLTRIM(TRANSFORM(aCols[nCount,aScan(aHeader,{|x| AllTrim(x[2]) == 'C7_VALFRE'})]   ,"@E 999,999,999.99")))
				AddCard(@aCardData ,"totalSeguro"     	,ALLTRIM(TRANSFORM(aCols[nCount,aScan(aHeader,{|x| AllTrim(x[2]) == 'C7_SEGURO'})]   ,"@E 999,999,999.99")))
				AddCard(@aCardData ,"totalDespesa"     	,ALLTRIM(TRANSFORM(aCols[nCount,aScan(aHeader,{|x| AllTrim(x[2]) == 'C7_DESPESA'})]  ,"@E 999,999,999.99")))
                
                
				nTotPed += aCols[nCount,aScan(aHeader,{|x| AllTrim(x[2]) == 'C7_TOTAL'})] +  aCols[nCount,aScan(aHeader,{|x| AllTrim(x[2]) == 'C7_VALFRE'})] - aCols[nCount,aScan(aHeader,{|x| AllTrim(x[2]) == 'C7_VLDESC'})] + aCols[nCount,aScan(aHeader,{|x| AllTrim(x[2]) == 'C7_DESPESA'})]  + aCols[nCount,aScan(aHeader,{|x| AllTrim(x[2]) == 'C7_SEGURO'})] 
			EndIf
		
	   	next nCount
	EndIf
	
//	nTotped    := MaFisRet(,"NF_TOTAL")
   	
	AddCard(@aCardData, "id_totalpedido", AllTrim(TRANSFORM(nTotPed, "@E 999,999,999.99")))
	
	WSDLDbgLevel(2)
	
   	//Atribui CardData
	For nCount	:= 1 to Len(aCardData)
		Aadd(FlgWs:OWSSTARTPROCESSCARDDATA:oWSitem, ECMWorkflowEngineServiceService_stringArray():New())
		
		For nY := 1 to Len(aCardData[nCount])
			
			xValor := aCardData[nCount][nY]

			If ValType(xValor) == "L"
				If xValor
					xValor := "true"
				Else
					xValor := "false"
				EndIf
			ElseIf ValType(xValor) == "D"
				xValor := DtoC(xValor)
			ElseIf ValType(xValor) == "N"
				xValor := AllTrim(Str(xValor))
			EndIf
			
			Aadd(aTail(FlgWs:OWSSTARTPROCESSCARDDATA:oWSitem):cItem, xValor)
		Next nY
	Next nX
	
	If FlgWs:startProcess()        
		if len(FlgWs:oWSstartProcessresult:oWSitem) < 3
			If lRotAuto
				Aviso("ECFLG", 'Ocorreu um erro e o processo não pode ser aberto ' +chr(13)+FlgWs:oWSstartProcessresult:oWSitem[1]:citem[2], {"Fechar"})
			Else
				MsgStop('Ocorreu um erro e o processo não pode ser aberto ' +chr(13)+FlgWs:oWSstartProcessresult:oWSitem[1]:citem[2])
			EndIf
			Return .T.
		else
			cProces := ""//cValtoChar(FlgWs:oWSstartProcessresult:oWSitem[3]:citem[2])

			For nRet := 1 to Len(FlgWs:OWSSTARTPROCESSRESULT:OWSITEM)
				If AllTrim(FlgWs:OWSSTARTPROCESSRESULT:OWSITEM[nRet]:cItem[1]) == "iProcess"
					cProces := FlgWs:OWSSTARTPROCESSRESULT:OWSITEM[nRet]:cItem[2]
				EndIf
			Next nRet
						
			//Atualiza tabela SC7
			If lCotacao
				DbSelectArea("SC7")
				DbSetOrder(1)			//C7_FILIAL, C7_NUM, C7_ITEM
				
				If SC7->(DbSeek(xFilial("SC7") + cPedido))
					While !SC7->(Eof()) .AND. xFilial("SC7") + cPedido == SC7->C7_FILIAL + SC7->C7_NUM

						SC7->(RECLOCK("SC7", .F.))
							SC7->C7_XIDFLG := cProces
						SC7->(MSUNLOCK()) 
						SC7->(DbSkip())
					End				
				EndIf
			Else

				cNumC7 := SC7->C7_NUM
				cFilC7 := SC7->C7_FILIAL

				dbSelectArea( "SC7" )
				SC7->(dbSetOrder(1))

				For nCount := 1 To Len(aCols)
					If dbSeek(xFilial("SC7", cFilC7) + cNumC7 + aCols[nCount][aScan(aHeader,{|x| AllTrim(x[2])=='C7_ITEM'})])
						SC7->(RECLOCK("SC7", .F.))
						SC7->C7_XIDFLG := cProces
						SC7->(MSUNLOCK()) 
					EndIf
				Next
			EndIf

			//Reposiciona na SC7
			RestArea(aAreaSC7)
			
			//Atualiza tabela SCR
			dbSelectArea( "SCR" )
			dbSetOrder(1)
			
			If dbSeek(xFilial("SCR", cFilC7) + "PC" + cNumC7)
				While !SCR->(Eof()) .AND.;
				      SCR->CR_FILIAL == xFilial("SCR", cFilC7) .AND.;
				      Alltrim(SCR->CR_TIPO) == "PC" .AND.;
				      AllTrim(SCR->CR_NUM) = AllTrim(SC7->C7_NUM)
				
					SCR->(RECLOCK("SCR", .F.))
					
					SCR->CR_XIDFLG := cProces
					
					SCR->(MSUNLOCK())
					
					SCR->(dbSkip())
				End
				 
			EndIf
			
			If !lRotAuto .OR. (IsInCallStack("U_AVALCOPC") .OR. IsInCallStack("CN120GRVPED"))
				MsgInfo('Pedido de compra ' + Trim(SC7->C7_NUM) + ' enviado ao Fluig.' +chr(13)+;
		            	'Processo Fluig - '+cProces+'!')
			EndIf
					   
		EndIf		
	Else
		If lRotAuto
			Aviso("ECFLG", 'Ocorreu um erro no processo de integração!'+chr(13)+GetWSCError(), {"Fechar"})
		Else
			MsgStop('Ocorreu um erro no processo de integração!'+chr(13)+GetWSCError())
		EndIf
	Endif    
Return .T.

Static Function FnIdFlg(cC7_NUM)
	Local cIdFlg := ""
	
	dbSelectArea( "SC7" )
	dbSetOrder(1)
	
	If dbSeek(xFilial("SC7") + cC7_NUM)
		cIdFlg := SC7->C7_XIDFLG
	EndIf
	
	if !Empty(cIdFlg)
		//Verifica se cancelou o processo aberto anteriormente no Fluig
		if FncCFlg(cIdFlg)
			
			//Atualiza a SC7 e SCR para o status igual a BRANCO
			dbSelectArea( "SC7" )
			dbSetOrder(1)
			
			If dbSeek(xFilial("SC7", SC7->C7_FILIAL) + SC7->C7_NUM)
				While !SC7->(Eof()) .AND. SCR->CR_NUM == cC7_NUM
					SC7->(RecLock("SC7", .F.))
					
					SC7->C7_XIDFLG := ""
					
					SC7->(MSUNLOCK())
					
					SC7->(dbSkip())
				End 
			EndIf
			
			dbSelectArea( "SCR" )
			dbSetOrder(1)
			
			If dbSeek(xFilial("SCR", SC7->C7_FILIAL) + "PC" + SC7->C7_NUM)
				While !SCR->(Eof()) .AND. SCR->CR_FILIAL == xFilial("SCR", SC7->C7_FILIAL) .AND. SCR->CR_TIPO == "PC" .AND. SCR->CR_NUM == SC7->C7_NUM  
					SCR->(RecLock("SCR", .F.))
					
					SCR->CR_XIDFLG := ""
					
					SCR->(MSUNLOCK())
					
					SCR->(dbSkip())
				End 
			EndIf
		endif
	endif
					
Return cIdFlg

//Cancela Solicitacao Fluig
Static Function FncCFlg(cIdFlg)
	Local FlgWS    := WSECMWorkflowEngineServiceService():new()
	Local lRetorno := .F. 
	
	FlgWs:_URL := SuperGetMV("MV_ECMURL") + "ECMWorkflowEngineService"
	
	if FlgWS:cancelInstance(SuperGetMv("MV_ECMUSER"    ,NIL ,"integrador"),;
	                        SuperGetMv("MV_ECMPSW"     ,NIL ,"integrador"),;
	                        VAL(SuperGetMv("MV_ECMEMP" ,NIL ,1)),;
	                        VAL(cIdFlg),;
	                        SuperGetMv("MV_ECMMAT"),;
	                        "Processo cancelado através da integração com o Protheus") 
		//Se processamento ocorrer sem erros exibe o valor de retorno
		lRetorno := .T. 
	endif
	
Return lRetorno

//-------------------------------------------------------------------
/*{Protheus.doc} AddCard
Adiciona os Dados do Formulario para Envio

@author Guilherme.Santos
@since 06/01/2016
@version P12
*/
//-------------------------------------------------------------------
Static Function AddCard(aCardData, cCampo, xValor)
	Local aTemp := {}

	Aadd(aTemp, cCampo)
	Aadd(aTemp, xValor)
	Aadd(aCardData, aClone(aTemp))
Return NIL

//Retorna e-mail do usuário logado
Static Function RetLogin()
	Local cRetorno := ""

	//Ordena pesquisa por id do usuário
	PswOrder(1)

	If PswSeek(RetCodUsr())
		cRetorno := PswRet(1)[1][14]
	EndIf

Return cRetorno



/*/{Protheus.doc} nomeFunction
	(long_description)   ABAX
	@type  Function
	@author user
	@since 25/06/2021
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/

Static Function FABAX02()
	Local aAreSC7:= SC7->( GetArea() )
	Local aAreaSC1:= SC1->( GetArea() )
	Local cPedido:= SC7->C7_NUM

//	Local cAlias	  //abax O
//	Local cItem
//	Local cZeros

	SC7->( DbSetOrder(1) )	//C7_FILIAL, C7_NUM, C7_ITEM

	If SC7->(DbSeek(xFilial("SC7") + cPedido))

		While !SC7->(Eof()) .AND. xFilial("SC7") + cPedido == SC7->C7_FILIAL + SC7->C7_NUM

			/*
			//ABAX
			IF IsInCallStack("CNTA120")  //VEIO MEDICAO

				cAlias	:=	GetNextAlias()
				//ajusta tamanho do item  aqui na Alliar o SC7 esta com 4 e CNE com 3
				cZeros:=Repl('0',10)
				cItem		:=  Right( cZeros+SC7->C7_ITEM, TamSx3('CNE_ITEM')[1] )

				BeginSql Alias cAlias
					%NoParser%

					SELECT * 
					FROM %table:CNE010% CNE 
					WHERE CNE.%NotDel%  AND CNE_FILIAL = %xFilial:CNE%  
						AND CNE_PEDIDO = %exp:cPedido%  AND  CNE_ITEM = %exp:cItem% 
		 
				EndSql    //GetLastQuery()[2]

				IF (cAlias)->(!Eof())

					SC7->(RECLOCK("SC7", .F.))
					SC7->C7_XBUDGET	:= (cAlias)->CNE_XBUDGE  //abax
					SC7->C7_XMOTBUD	:= (cAlias)->CNE_XMOTBU  //abax
					SC7->(MSUNLOCK())

				ENDIF

				(cAlias)->(dbCloseArea())




			ELSE
			*/
			SC1->(dbSetOrder(1))
			SC1->(dbSeek(xFilial("SC1")+SC7->(C7_NUMSC+C7_ITEMSC)))

			If SC1->(!Eof()) .And. AllTrim(SC7->C7_ITEMSC)  == AllTrim(SC1->C1_ITEM)  .And.  AllTrim(SC7->C7_NUMSC) == AllTrim(SC1->C1_NUM)

				SC7->(RECLOCK("SC7", .F.))
				SC7->C7_XBUDGET	:= SC1->C1_XBUDGET  //abax
				SC7->C7_XMOTBUD	:= SC1->C1_XMOTBUD  //abax
				SC7->(MSUNLOCK())

			ENdIf

			RestArea(aAreaSC1)

			//ENDIF

			SC7->(DbSkip())
		EndDO

	EndIf

	//Reposiciona na SC7
	RestArea(aAreSC7)

RETURN




/*/{Protheus.doc} nomeFunction
	(long_description)
	@type  Function
	@author user
	@since 05/07/2021
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/

Static FUNCTION FVerMuda()
	Local aAreaSC7 := SC7->(GetArea())

	Local cXPedido:= SC7->C7_NUM
	Local aEstrSC7:= {}
	Local jj
	Local lAltera:=.f.
	Local gg

	Private aMudAbax2:={}   //abax

	//If nOper == 2 //-- 1 = Chamada via A120LINOK, 2 = Chamada via A120TUDOK
	//-- Validações de usuário
	//    lRet := .F.
	//  EndIf

	SC7->(dbSetOrder(1))
	SC7->(dbSeek(xFilial("SC7") + cXPedido) )

	aEstrSC7:= SC7->(dbStruct())
	nStru:=Len(aEstrSC7)

	While !SC7->(Eof()) .AND. xFilial("SC7") + cXPedido == SC7->C7_FILIAL + SC7->C7_NUM

		AADD(aMudAbax2,{})

		For jj:=1 to nStru

			AADD(aMudAbax2[len(aMudAbax2)], {sc7->(FieldName(jj)), sc7->(FieldGet(jj)) } )

		NEXT

		SC7->(DbSkip())
	ENDDO

	RestArea(aAreaSC7)

	nTam1:=len(amudabax)
	nTam2:= len(amudabax2)

	//se os arrays tem tamanho diferentes, nem compara, ja retorna para gerar direto
	IF nTam1 <> nTam2
		lAltera:=.T.


	ELSE

		//compara os array se nao teve modificacao
		For jj:= 1 to nTam1

			For gg:=1 to Len(aMudAbax[jj])

				//pego o nome do campo do aMudAbax
				cCampo:= aMudAbax[jj,gg,1]
				//procura o mesmo campo no aMudAbax2
				nPosi:= aScan(aMudAbax2[jj],{|x| AllTrim(x[1]) == cCampo})
				//verifica se o valor é igual nos 2
				IF !aMudAbax[jj,gg,2] == aMudAbax2[jj,nPosi,2] .and. cCampo <> 'C7_XTPDOC'  //abax
					lAltera:=.T.
					exit
				ENDIF

			Next
			IF lAltera
				exit
			ENDIF
		Next

	ENDIF

Return lAltera

