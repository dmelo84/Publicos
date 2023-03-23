/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ MT410TOK ºAutor  ³ Microsiga          º Data ³  16/04/13   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Validação da digitacao do pedido de venda                  º±±
±±º          ³  16/04/2013 - SSI 27937                                    º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ MT410TOK ºAutor  ³ Márcio Sobreira    º Data ³  11/06/18   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±                        
±±ºDesc.     ³ Obrigar o preenchimento do campo "Unid. Dest." quando      º±±
±±º          ³ operação for 13									          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ MT410TOK ºAutor  ³ Nei Carlos   º Data ³  11/10/19         º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Informar o pedido principal em pedido de operação 05       º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
±±ºPrograma  ³ MT410TOK ºAutor  ³ Gabriel Rezende    º Data ³  12/11/2020 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Obrigar o preenchimento do campo C5_XNICHO quando segmento º±±
±±º          ³ do pedido for 1 ou 2								          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
*/
#include 'Protheus.ch'
#Include "TopConn.Ch"
#Include "RwMake.Ch"


************************
User Function MT410TOK()
	************************

	Local lContinua	:= .T.
	Local lSSI27937	:= cEmpAnt $ "03"
	Local lRet		:= .T.
	Local aFiltPrd	:= {}
	Local nPosPrd	:= 0                                                                           
	Local nX		:= 0
	Local nY		:= 0
	Local aAreaSA1	:= SA1->(GetArea())
	Local cCliPri   :=" "  
	Local cCliLoj   :=" "  
	Local cCliGrp   :=" " 
	Local cGcliPed  :=" " 
	Local aAreaSC5  := SC5->(GetArea())
	Local aClibri   :={}
	Local nIdCli    := 0


	/* INÍCIO ALTERAÇÃO - AMARRAÇÃO NICHO NO PEDIDO*/

	IF  M->C5_XTPSEGM $ '1|2|6' .And. cEmpAnt $ '02|03|04|05|06|07|08|09|10|15|18|21|22|23|24|25|26|27' //Segmento Industrial, Comercial e Caminhão Volante

		DbSelectArea("SZ0")
		DbSetorder(1)

		If Empty(M->C5_XNICHO) .Or. !SZ0->(DbSeek(xFilial("SZ0") + "CM" + M->C5_XNICHO))

			_cMsg := "<html><head></head><body><b><u> Canal (nicho) informado inválido! </u></b><br>"    + CRLF
			_cMsg += "Prezado(a) " + Alltrim(Capital(UsrFullName(__cUserID))) + ",  "    + CRLF
			_cMsg += "Por se tratar de cliente do segmento Industrial/Comercial       "   + CRLF
			_cMsg += "é necessário que se informe o Canal (nicho) do mesmo! <br>"     + CRLF
			_cMsg += "Informar uma codificação válida (campo Nicho Client):<br><br> "           + CRLF
			_cMsg += "00001 - REDE  "           	+ CRLF
			_cMsg += "00002 - COMERCIAL VAREJO  "+ CRLF
			_cMsg += "00003 - CAMINHAO VOLANTE "+ CRLF
			_cMsg += "00004 - REVENDEDOR WEB   "  + CRLF
			_cMsg += "00005 - HOTEL/HOSPITAL  "  + CRLF
			_cMsg += "00006 - INSUMOS<br> "         + CRLF
			_cMsg += "</body></html>"                                                         + CRLF

			MsgAlert(_cMsg,"MT410tOK")

			lRet := .F.
			RestArea(aAreaSC5)
			
			Return lRet
		
		EndIf

	EndIF

	/* FIM ALTERAÇÃO - AMARRAÇÃO NICHO NO PEDIDO*/

	DbSelectArea("SX6")
	DbSetOrder(1) 

	If !DbSeek(xFilial("SX6")+"MV_XCLIBRI") //Verifica se o parametro existe
		RecLock("SX6",.T.) 
		SX6->X6_FIL     := xFilial( "SX6" )
		SX6->X6_VAR     := "MV_XCLIBRI"
		SX6->X6_TIPO    := "C"
		SX6->X6_DESCRIC := "Clientes de Brinde "
		SX6->X6_CONTEUD := " "
		MsUnLock() 
	EndIf

	aCliBri := StrTokArr(UPPER(GETMV("MV_XCLIBRI")), ";" )
	nIdCli  := ASCAN(aCliBri,UPPER(M->C5_CLIENTE))


	If  !(cEmpAnt $ "21-22-23-24-18") .AND. nIdCli == 0 .and. !IsInCallStack("U_ORTA334") // SSI: 116592
		//Validação para operação 05, neste caso informar o pedido principal é obrigatorio.

		IF M->C5_XOPER == "05" .AND.  empty(M->C5_XPEDPRI)
			MsgAlert("O campo pedido principal é obrigatorio para esta operação. ","Pedido Principal")
			lret := .F.  
			RestArea(aAreaSC5)
			Return lret
		Endif


		//Busca Cliente do Pedido Principal.

		IF  M->C5_XOPER == "05" .AND. !empty(M->C5_XPEDPRI)

			DbSelectArea("SC5")
			DbSetorder(1)
			SC5->(DbGotop())

			If SC5->(Dbseek(XFILIAL("SC5")+ M->C5_XPEDPRI)) 
				cCliPri := SC5->C5_CLIENTE  
				cCliLoj := SC5->C5_LOJACLI

			EndIf  

		EndIF                                    


		//Verifica se o pedido foi atual foi informado como pedido principal.

		IF M->C5_XOPER == "05" .AND.  M->C5_XPEDPRI == M->C5_NUM
			MsgAlert("Não é permitido referenciar o proprio pedido no campo pedido principal  ","Pedido Principal")
			lret := .F.
			Return lret

		ElseIF M->C5_XOPER == "05" .AND. M->C5_CLIENTE != cCliPri //O Cliente da Operação 05 Deverá ser o mesmo do pedido principal

			DbSelectArea("SA1")  // SSI 87138
			SA1->(DBSETORDER(1))
			If SA1->(DbSeek(XFilial("SA1")+cCliPri+cCliLoj))
				cCliGrp := SA1->A1_XCODGRU
			EndIf
			If SA1->(DbSeek(XFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI))
				cGcliPed:= SA1->A1_XCODGRU 			
			EndIf

		ElseIf cCliGrp !=cGcliPed		
			MsgAlert("O Cliente informado diverge do cliente ou grupo de cliente do pedido principal. ","Cliente")
			RestArea(aAreaSC5)   
			lret = .F.
			Return lret
		Endif


		RestArea(aAreaSC5)    
	EndIf
	//---------------------/Fim da alteração/-------------------------------------- //

	IF IsInCallStack("U_ORTA703") .OR. IsInCallStack("U_ORTA425") .OR. IsInCallStack("U_ORTA034R") .OR. IsInCallStack("U_SONOSFAB")
		Return lRet
	EndIf

	If cEmpAnt $ "02|03|04|05|06|07|08|09|10|11|15|26"
		If !U_FVLDCONS(M->C5_CLIENTE, M->C5_XTPSEGM)
			Return .F.
		EndIf
	EndIf

	//If !(M->C5_TIPO $ 'D|B') .AND. (M->C5_CLIENT <> M->C5_CLIENTE .AND. M->C5_XTPSEGM <> '5')   
	If !empty(M->C5_CLIENT) .AND. M->C5_CLIENT <> M->C5_CLIENTE .AND. M->C5_XTPSEGM <> '5'
		MsgAlert("O Campo cliente de entrega nao pode ser preenchido para este tipo/segmento!")
		Return(.F.)                              
	Endif

	*'INICIO - Validação do Processo de Importação de Pedidos entre Unidades - 11/06/2018 - SSI: XXXXX --'*
	If "MATA410" $ FUNNAME() 
		If Inclui 
			if M->C5_XOPER == "13" .and. M->C5_XUNDEST = "  " 
				MsgAlert("Pedido entre unidades. Favor preencher o campo {Unidade de Destino}!")
				Return(.F.)                              
			Endif	    
			if M->C5_XOPER == "13" .and. (M->C5_XUNDEST == cEmpAnt .or. !(AllTrim(M->C5_XUNDEST) $ "02/03/18/04/05/06/07/23/24/08/09/10/11/26/15/21/22/27/28/")) 
				MsgAlert("Unidade de destino é inválida!")
				Return(.F.)                              
			Endif	    
			if M->C5_XOPER == "13" .and. !Empty(M->C5_XPEDCLX)
				MsgAlert("Pedido entre unidades. Favor não preencher o campo {Ped. Cliente}!")
				Return(.F.)                              
			Endif		
			if M->C5_XOPER == "14" 
				MsgAlert("Tp.Operação não permitida para inclusão MANUAL. Apenas pelo processo de Importação entre unidades!")
				Return(.F.)                              
			Endif	    
			if M->C5_XOPER == "13" .and. M->C5_XUNDEST $ "21/22/23/24" .and. M->C5_XDESPRO $ "1/2"
				_cTexto := "O pedido lançado possui desconto do IPI e a unidade de destino não possui esta prática."
				_cTexto += " Ajustar o pedido para não haver desconrto para que o mesmo possa ser incluído!"
				MsgAlert(_cTexto)
				Return(.F.)                              
			Endif										
		ElseIf Altera
			if SC5->C5_XOPER == "13" .and. SC5->C5_XUNDEST = "  " 
				MsgAlert("Pedido entre unidades. Favor preencher o campo {Unidade de Destino}!")
				Return(.F.)                              
			Endif
			/*	Comando Duplicado  - DMS
			if SC5->C5_XOPER == "13" .and. (SC5->C5_XUNDEST == cEmpAnt .or. !(AllTrim(SC5->C5_XUNDEST) $ "02/03/18/04/05/06/07/23/24/08/09/10/11/26/15/21/22/27/28")) 
				MsgAlert("Unidade de destino é inválida!")
				Return(.F.)                              
			Endif
			*/	    
			if SC5->C5_XOPER == "13" .and. !Empty(SC5->C5_XPEDCLX)
				MsgAlert("Pedido entre unidades. Favor não preencher o campo {Ped. Cliente}!")
				Return(.F.)                              
			Endif	
			if SC5->C5_XOPER == "13" .and. SC5->C5_XUNDEST $ "21/22/23/24" .and. SC5->C5_XDESPRO $ "1/2"
				_cTexto := "O pedido lançado possui desconto do IPI e a unidade de destino não possui esta prática."
				_cTexto += " Ajustar o pedido para não haver desconrto para que o mesmo possa ser incluído!"
				MsgAlert(_cTexto)
				Return(.F.)                              
			Endif					
		ElseIf !Altera .and. !Inclui
			If SC5->C5_XOPER == "13" .and. !Empty(SC5->C5_XUNDEST) .and. !Empty(SC5->C5_RESREM)
				MsgAlert("Pedido entre unidades. Cancelamento apenas Aceito na {Unidade de Destino}!")
				Return(.F.)                                                                                        
			Endif
		Endif	
	Endif
	*'F I M  ----------------------------------------------------------------- 11/06/2018 - SSI: XXXXX --'*

	if Altera .and. alltrim(cUserName)<>"dupim" .and. SC5->C5_XOPER <> "98"
		/// GLM: George: 12/11/2014 - Permissão para alterar o pedido de venda da Ortofio enquanto sistema em implantação
		If cEmpAnt <> "21"  // Se não for a unidade Ortofio
			MsgAlert("Nao e permitido a alteração de pedidos")
			Return(.F.)
		EndIf	
	endif

	If Alltrim(FunName()) ="ORTA397" // Geracao do pedido de venda via ExecAuto Ortofio
		Return
	EndIf

	lSSI27937	:= lRet .And. lContinua .And. lSSI27937 .And. Type("aCols") == "A" .And. Type("aHeader") == "A"

	//Seta posicao do produto no acols
	lSSI27937	:= lRet .And. lContinua .And. lSSI27937 .And. (nPosPrd := AScan( aHeader, {|x| x[2] == "C6_PRODUTO"} )) > 0

	//Define se o cliente do pedido faz parte da filtragem
	lSSI27937	:= lRet .And. lContinua .And. lSSI27937 .And. !(M->C5_CLIENTE $ "003045|011829|003051|006747|007309|007669|012277")

	//Define relacao de produtos a serem filtrados
	If lRet .And. lContinua .And. lSSI27937
		aAdd( aFiltPrd, PADR("1040325119", GetSX3Cache("B1_COD","X3_TAMANHO")) )
		aAdd( aFiltPrd, PADR("1040325122", GetSX3Cache("B1_COD","X3_TAMANHO")) )
		aAdd( aFiltPrd, PADR("1040325123", GetSX3Cache("B1_COD","X3_TAMANHO")) )
		aAdd( aFiltPrd, PADR("1040325124", GetSX3Cache("B1_COD","X3_TAMANHO")) )
		aAdd( aFiltPrd, PADR("1040325125", GetSX3Cache("B1_COD","X3_TAMANHO")) )
		aAdd( aFiltPrd, PADR("1040325126", GetSX3Cache("B1_COD","X3_TAMANHO")) )
		aAdd( aFiltPrd, PADR("1040325127", GetSX3Cache("B1_COD","X3_TAMANHO")) )
		aAdd( aFiltPrd, PADR("1040325128", GetSX3Cache("B1_COD","X3_TAMANHO")) )
		aAdd( aFiltPrd, PADR("1060310107", GetSX3Cache("B1_COD","X3_TAMANHO")) )
		aAdd( aFiltPrd, PADR("1060310108", GetSX3Cache("B1_COD","X3_TAMANHO")) )
		aAdd( aFiltPrd, PADR("1060310109", GetSX3Cache("B1_COD","X3_TAMANHO")) )
		aAdd( aFiltPrd, PADR("1060310110", GetSX3Cache("B1_COD","X3_TAMANHO")) )
		aAdd( aFiltPrd, PADR("1060310111", GetSX3Cache("B1_COD","X3_TAMANHO")) )
	EndIf

	//Executa busca nos produtos
	If lRet .And. lContinua .And. lSSI27937
		For nX := 1 To Len(aCols)
			//        If aCols[_Ln,Len(aCols[_Ln])] == .F.  // Se linha não deletada - Henrique - 05/03/2015
			If ( nY := AScan( aFiltPrd, aCols[nX][nPosPrd] ) ) > 0
				lRet		:= .F.
				lContinua	:= .F.
				MsgAlert( OemToAnsi("O produto '"+AllTrim(aFiltPrd[nY])+"' não está autorizado para este cliente."), OemToAnsi("SSI 27937") )
			EndIf
			//	    EndIf
		Next nX
	EndIf

	// Início SSI 31347 - By Rafael Rezende - 06/09/2013
	If lRet
		If Len( AllTrim( M->C5_XPEDCLI ) ) > 15 
			Aviso( "Atenção", "O Campo [Ped. Cliente]tet está restrito a no máximo 15 caracteres.", { "Voltar" } ) 
			lRet := .F.
		End If  
	End If 
	// Fim SSI 31347 

	If lRet .and. !IsBlind() // nao exibir o alert quando for execauto... reprocessamento de pedido devolvido pode repetir o talsac...
		If !Empty(M->C5_XTALSAC)
			cAliasSC5 := GetNextAlias()

			cQrySC5 := " SELECT C5_NUM "
			cQrySC5 += "   FROM "+RETSQLNAME("SC5")+" SC5 "
			cQrySC5 += " WHERE SC5.D_E_L_E_T_ = ' ' "
			cQrySC5 += "   AND C5_FILIAL = '"+XFILIAL("SC5")+"' "
			cQrySC5 += "   AND C5_XTALSAC = '"+M->C5_XTALSAC+"' "
			cQrySC5 += "   AND C5_XOPER   = '"+M->C5_XOPER  +"' "

			If Select(cAliasSC5) > 0
				(cAliasSC5)->(dbCloseArea())
			EndIf

			dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQrySC5),cAliasSC5,.F.,.T.)
			(cAliasSC5)->(dbGoTop())
			If (cAliasSC5)->(!EOF())
				MsgStop("Já existe esse numero de pedido de assistência cadastrado. Verifique!")
				lRet := .F.
			Endif
			If Select(cAliasSC5) > 0
				(cAliasSC5)->(dbCloseArea())
			EndIf
		Endif
	EndIf

	If lRet
		For nX := 1 To Len(M->C5_XPEDFIC)
			If !(SubStr(M->C5_XPEDFIC, nX, 1) $ "0123456789ABCDEFGHIJKLMNOPQRSTUVWYXZ ")
				MsgStop("Número de pedido ficha inválido! O campo deve ser preenchido somente com espaços, caracteres ou números")
				lRet	:= .F.
			EndIf
		Next nX
	EndIf

	If Empty(M->C5_XENTREF)

		//adicionado 09/09/2019 - Gabriel Rezende
		If lRet .And. AllTrim(Posicione("SA1",1,xFilial("SA1")+M->C5_CLIENTE+M->C5_LOJACLI,"A1_XCLIAGD")) = '1' .And. AllTrim(M->C5_XQUAREN) != '1'
			If "MATA410" $ FUNNAME() 
				Aviso( "Atenção", "Cliente configurado como Cliente Agendamento. O pédido irá para Quarentena.", { "Fechar" } ) 
			Endif	
			M->C5_XQUAREN := "1"
		EndIf
		RestArea(aAreaSA1)

	EndIf

	// INICIO - Márcio Sobreira - Verifica se na unidade de Destino já existe o Cliente - 26/11/2019 //////
	If lRet .and. "MATA410" $ FUNNAME() 
		If Inclui 
			If M->C5_XOPER == "13" .and. !Empty(M->C5_XUNDEST) .and. Empty(M->C5_RESREM)
				FVEREUNX(M->C5_XUNDEST, M->C5_CLIENTE)
			Endif
		ElseIf Altera	
			If SC5->C5_XOPER == "13" .and. !Empty(SC5->C5_XUNDEST) .and. Empty(SC5->C5_RESREM)
				FVEREUNX(SC5->C5_XUNDEST, SC5->C5_CLIENTE)
			Endif
		Endif
	Endif				
	// FIM    - Márcio Sobreira - Verifica se na unidade de Destino já existe o Cliente - 26/11/2019 //////

Return lRet

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Static Function FVEREUNX(_cUnDest, _cCliente)
	Local aRet    := {}
	Local aIps    := U_FRetUnidades()
	Local cUnDest := "  "

	aAdd( aIps, { "27", "10.0.200.63", 1235, "ORTORJ" , "18", "03", "Queimados		    ","RJ", "QM" } )

	cUnDest := _cUnDest
	aDados  := fBuscDcl(_cCliente) // Busca dados do cliente
    
	If cEmpAnt == '03' .And. cUnDest == '27'
		aRet := U_ORTA646K(aDados[1],"S",cEmpAnt,aDados[2])
	Else	
		nPos:= aScan(aIps,{|x| x[1]==cUnDest})
		if nPos==0
			//	Alert("Unidade Invalida")
			Return()
		Else
			oSrv:=rpcconnect(aIps[nPos,2], aIps[nPos,3], aIps[nPos,4], aIps[nPos,5], aIps[nPos,6])
	
			if valtype(oSrv)=="O"
				_aAreaAtu := GetArea()
				SaveInter()
				aRet := oSrv:CallProc( 'U_ORTA646K', aDados[1],"S",cEmpAnt,aDados[2])
				rpcdisconnect(oSrv)
				RestInter()
				RestArea(_aAreaAtu)
	
				If ValType(aRet)<>"A"
					Alert("Problemas na conexao com a unidade de Destino ["+cUnDest+"] 2")
				Else
					If Len(aRet) > 0
						// Envia E-mail
					Else
						Aviso("Atenção", "Nenhum pedido localizado para esta empresa!", { "Sair" } )
					Endif
	
				Endif
				//	_aRet := U_ORTXRPC(cUnDest, "U_ORTA646K",{aDados[1],"S",cEmpAnt,aDados[2]})  // Array Cliente, RPC?, Unidade Origem, CNPJ
			Else
				Alert("Problemas na conexao com a unidade de Destino ["+cUnDest+"] 1")	
			Endif 
		Endif
	Endif
Return                                                     

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
Static Function fBuscDcl(_cCliente)
	Local aSX3SA1 := {}
	Local aRet    := {}
	Local i	  := 1

	DbSelectArea("SX3")
	Dbsetorder(1)
	DbSeek("SA1")
	Do While SX3->X3_ARQUIVO=="SA1"
		if SX3->X3_CONTEXT<>"V" .and. SX3->X3_TIPO<>"M"
			aadd(aSX3SA1,{SX3->X3_CAMPO,SX3->X3_TIPO})
		Endif
		DbSkip()
	Enddo

	// SELECT
	cQuery:=" SELECT * " 
	cQuery+="        FROM "+RetSqlName("SA1")+" SA1 "
	cQuery+="        WHERE A1_FILIAL   = '"+xFilial("SA1")+"' "
	cQuery+="        AND SA1.D_E_L_E_T_ = ' ' "
	cQuery+="        AND SA1.A1_COD = '"+_cCliente+"' "

	conout("[fBuscDcli] - Query: "+cQuery)
	memowrite("C:\QUERYS\sobreira\fBuscDcli.SQL",cQuery)

	If Select("QRY") > 0
		QRY->(dbCloseArea())
	EndIf

	TCQuery cQuery Alias "QRY" NEW
	DbSelectArea("QRY")
	If !eof()
		_cCnpj := QRY->A1_CGC

		// Cliente ////////////////////////////////////////
		For i:=1 to Len(aSX3SA1)
			cCmp:="QRY->"+aSX3SA1[i,1]
			If aSX3SA1[i,2]=="D"
				aadd(aRet,{aSX3SA1[i,1],StoD(&cCmp)})
			Else
				If aSX3SA1[i,2]=="L"
					aadd(aRet,{aSX3SA1[i,1],&cCmp=="T"})
				Else
					aadd(aRet,{aSX3SA1[i,1],&cCmp})
				Endif
			Endif
		Next
		///////////////////////////////////////////////////
	Endif
	QRY->(dbCloseArea())

Return({aRet,_cCnpj})
