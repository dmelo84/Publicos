#Include 'Protheus.ch'

#Define _RTBIOSTA 1
#Define _RTBIODAT 2
#Define _RTBIOMSG 3

#Define _PDCCNPJ 1
#Define _PDCSCNU 2
#Define _PDCSCIT 3
#Define _PDCPROD 4
#Define _PDCQTDO 5
#Define _PDCPRUN 6
#Define _PDCDTEN 7
#Define _PDCQTEN 8
#Define _PDCJUST 9
#Define _PDCNUME 10
#Define _PDCDATA 11
#Define _PDCHORA 12
#Define _PDCCPAG 13
#Define _PDCTFRE 14

#Define _PDCTAM  14

/*/{Protheus.doc} FSLIBBIO
Funcoes relacionadas ao processo de integração Bionexo
A Função de nome FSLIBBIO nunca será implementada

@type function
@author claudiol
@since 22/12/2015
@version 1.0
@example
(examples)
@see (links_or_references)
/*/
User Function FSLIBBIO()

Return


/*/{Protheus.doc} FSGerReq
Gera Sequencia de Requisicao

@author claudiol
@since 11/01/2016
@version undefined

@type function
/*/
User Function FSGerReq(cOpcao,cNumReq)

Local		aAreOld	:= {SC1->(GetArea()),GetArea()}
Local 	cAliAux	:= "SC1"
Local 	cNumReq	:= "" 

Default cOpcao	:= "G"
Default cNumReq:= ""

If cOpcao=="G"  //Gera sequencial
	cNumReq	:= U_FSGerSeq(cAliAux, 0, "FSSC101", "C1_XNUMREQ", 6)
ElseIf cOpcao=="L" //Libera sequencial
	Leave1Code(cEmpAnt+cAliAux+xFilial(cAliAux)+cNumReq)
EndIf

aEval(aAreOld, {|xAux| RestArea(xAux)})

Return


/*/{Protheus.doc} FSEnvPDC
Envia PDC ao Bionexo

@author claudiol
@since 04/01/2016
@version undefined
@param aProdutos, array, descricao
@param aRecSC1, array, descricao
@type function
/*/
User Function FSEnvPDC(aProdutos,aRecSC1,cNumReq)

Local aRet:= {}
Local cXml	:= ""

//Monta XML de produtos
cXml:= U_FSXMLPrd(aProdutos)

//Envia Produtos para Bionexo
aRet:= U_FSMntXML("P","WIP","LAYOUT=WI",cXml)

If aRet[_RTBIOSTA]  == "1" //-1=Erro; 0=Sem Dados;1=Ok
	//Monta XML de PDC
	cXml:= U_FSXMLPdc(aRecSC1,cNumReq)

	MemoWrite("\FSENVPDC.XML", cXml)

	//Envia PDC para Bionexo
	aRet:= U_FSMntXML("P","WAS","LAYOUT=WA",cXml)
EndIf

Return(aRet)


/*/{Protheus.doc} FSXMLPrd
Gera XML de Produto para integracao BIONEXO

@type function
@author claudiol
@since 22/12/2015
@version 1.0
@param cXml, character, (Descrição do parâmetro)
@param aProdutos, array, (Descrição do parâmetro)
@param lShowHelp, ${param_type}, (Descrição do parâmetro)
@example
(examples)
@see (links_or_references)
/*/
User Function FSXMLPrd(aProdutos)

Local nXi		:= 0
Local nYi		:= 0
Local aTagXml	:= {}
Local cXml		:= ""

//Tag do XML
Aadd(aTagXml,{"Ativo"				,"B1_MSBLQL"	, "{|x| Iif(x=='1','N',Iif(x=='2','S','')) }" })
Aadd(aTagXml,{"Nome"				,"B1_DESC"		, "" })
Aadd(aTagXml,{"Codigo"				,"B1_COD"		, "" })
Aadd(aTagXml,{"Marca_Preferida"		,"C1_XMARPRE"	, "" })
Aadd(aTagXml,{"Embalagem"			,"B1_CODEMB" 	, "" })
Aadd(aTagXml,{"Id_Unidade_Medida"	,"AH_XUMBIO"	, "" })
Aadd(aTagXml,{"Id_Categoria"		,"BM_XCATBIO"	, "" })
Aadd(aTagXml,{"Alternativa"			,"B1_XMARALT" 	, "{|x| Iif(x=='S','S','N') }" })

//Inicio
cXml+= MontaXML("Cadastro_Produto",,,,,,,.T.,.F.,.T.)

For nXi:= 1 To Len(aProdutos)

	//Posiciona tabelas
	SB1->(dbSetOrder(1)) //B1_FILIAL+B1_COD
	SB1->(MsSeek(xFilial("SB1")+aProdutos[nXi]))

	SAH->(dbSetOrder(1)) //AH_FILIAL+AH_UNIMED
	SAH->(MsSeek(xFilial("SAH")+SB1->B1_UM))

	SBM->(dbSetOrder(1)) //BM_FILIAL+BM_GRUPO
	SBM->(MsSeek(xFilial("SBM")+SB1->B1_GRUPO))

	cXml+= MontaXML("Produto",,,,,,2,.T.,.F.,.T.)
	
	For nYi:= 1 To Len(aTagXml)
		cXml+= U_FSCnvXML(aTagXml[nYi],4)
	Next nYi
	
	cXml+= MontaXML("Produto",,,,,,2,.F.,.T.,.T.)
Next nXi

//Fim
cXml+= MontaXML("Cadastro_Produto",,,,,,,.F.,.T.)

Return(cXml)


/*/{Protheus.doc} FSXMLPdc
Monta XML PDC bionexo

@author claudiol
@since 04/01/2016
@version undefined
@param aRecSC1, array, descricao
@type function
/*/
User Function FSXMLPdc(aRecSC1,cNumReq)

Local nXi		:= 0
Local nYi		:= 0
Local aTagCab	:= {}
Local aTagIte	:= {}
Local cXml		:= ""

//Tag do Cab
Aadd(aTagCab,{"Requisicao"				,""	, "{|x| '"+cNumReq+"' }" })
Aadd(aTagCab,{"Titulo_Pdc"				,""	, "{|x| 'PDC Gerado via ERP Protheus' }" })
Aadd(aTagCab,{"Id_Forma_Pagamento"		,""	, '{|x| Posicione("SE4",1,xFilial("SE4")+cGetConPag,"E4_XFPGBIO") }' })
Aadd(aTagCab,{"Data_Vencimento"			,""	, "{|x| dGetDatVen }" })
Aadd(aTagCab,{"Hora_Vencimento"			,""	, "{|x| cGetHorVen }" })
Aadd(aTagCab,{"Moeda"					,""	, "{|x| 'Reais' }" })
Aadd(aTagCab,{"Observacao"				,""	, "{|x| Alltrim(cMGObs) }" })
Aadd(aTagCab,{"Tipo_Cotacao"			,""	, "{|x| cGetTipCot }" })

//Tag do Ite
Aadd(aTagIte,{"Codigo_Produto"			,"C1_PRODUTO"	, "" })
Aadd(aTagIte,{"Descricao_Produto"		,"B1_DESC"		, "" })
Aadd(aTagIte,{"Quantidade"				,"C1_QUANT"		, "" })


//Inicio
cXml+= MontaXML('Pedido Layout="WA"',,,,,,,.T.,.F.,.T.)
cXml+= MontaXML("Cabecalho",,,,,,2,.T.,.F.,.T.)
For nXi:= 1 To Len(aTagCab)
	cXml+= U_FSCnvXML(aTagCab[nXi],4)
Next nXi
cXml+= MontaXML("Cabecalho",,,,,,2,.F.,.T.,.T.)

cXml+= MontaXML("Itens_Requisicao",,,,,,2,.T.,.F.,.T.)

For nXi:= 1 To Len(aRecSC1)

	//Posiciona tabelas
	SC1->(dbGoto(aRecSC1[nXi]))

	SB1->(dbSetOrder(1)) //B1_FILIAL+B1_COD
	SB1->(MsSeek(xFilial("SB1")+SC1->C1_PRODUTO))


	cXml+= MontaXML("Item_Requisicao",,,,,,4,.T.,.F.,.T.)
	
	For nYi:= 1 To Len(aTagIte)
		cXml+= U_FSCnvXML(aTagIte[nYi],6)
	Next nYi

	cXml+= MontaXML("Programacao_Entrega",,,,,,6,.T.,.F.,.T.)
	cXml+= U_FSCnvXML({"Data","C1_DATPRF",""},8)
	cXml+= U_FSCnvXML({"Quantidade","C1_QUANT",""},8)
	cXml+= MontaXML("Programacao_Entrega",,,,,,6,.F.,.T.,.T.)

	cXml+= MontaXML("Campo_Extra",,,,,,6,.T.,.F.,.T.)
	cXml+= U_FSCnvXML({"Nome","","{|x|'Item'}"},8)
	cXml+= U_FSCnvXML({"Valor","C1_ITEM",""},8)
	cXml+= MontaXML("Campo_Extra",,,,,,6,.F.,.T.,.T.)

	cXml+= MontaXML("Campo_Extra",,,,,,6,.T.,.F.,.T.)
	cXml+= U_FSCnvXML({"Nome","","{|x|'Requisicao'}"},8)
	cXml+= U_FSCnvXML({"Valor","C1_NUM",""},8)
	cXml+= MontaXML("Campo_Extra",,,,,,6,.F.,.T.,.T.)
	
	cXml+= MontaXML("Item_Requisicao",,,,,,4,.F.,.T.,.T.)
Next nXi

cXml+= MontaXML("Itens_Requisicao",,,,,,2,.F.,.T.,.T.)

cXml+= MontaXML("Pedido",,,,,,,.F.,.T.)

Return(cXml)


/*/{Protheus.doc} FSMntXML
Monta string XML e envia WS

@type function
@author claudiol
@since 31/12/2015
@version 1.0
@param cXml, character, (Descrição do parâmetro)
@param lShowHelp, ${param_type}, (Descrição do parâmetro)
@example
(examples)
@see (links_or_references)
/*/
User Function FSMntXML(cTipo,cOper,cParBio,cXml,lShowHelp)

Local cError  	:= ""
Local cWarning	:= ""
Local oXml		:= Nil
Local aRet		:= {}
Local cMsg		:= ""
Local lRet		:= .T.

Default cXml		:= ""
Default lShowHelp	:= .T.

If cTipo=="P" //Post
	//Gera o Objeto XML ref. ao script
	oXml := XmlParser( cXml, "_", @cError, @cWarning )
	
	If (oXml == NIL )
		lRet:= .F.
	Endif
EndIf

If !lRet
	cMsg:= "Falha ao gerar Objeto XML : "+cError+" / "+cWarning
Else
	aRet:= U_FSCONBIO(cTipo,cOper,cParBio,cXml)

	If aRet[_RTBIOSTA]== "-1"
		cMsg:= aRet[_RTBIOMSG]
	EndIf
EndIf

If lShowHelp .And. !Empty(cMsg)
	ApMsgStop(cMsg,".:Atenção:.")
EndIf

Return(aRet)


/*/{Protheus.doc} FSCONBIO
Conecta ao WS do Bionexo para envio(post) ou retorno(request)

@author claudiol
@since 05/01/2016
@version undefined
@param cTipo, characters, descricao
@param cOper, characters, descricao
@param cParam, characters, descricao
@param cXml, characters, descricao
@type function
/*/
User Function FSCONBIO(cTipo,cOper,cParam,cXml)

Local oWSDL
Local cBioUsr	:= Supergetmv("ES_BIOLOG",.F.,"")
Local cBioPsw	:= Supergetmv("ES_BIOPSW",.F.,"")
Local cDescErr:= "Erro:"
Local lDebug := SuperGetMV("ES_XDBGINT", NIL, .F.)

Default cXml:= ""

// Cria a instância da classe client
oWSDL := WSBionexoBeanService():New()

// Alimenta as propriedades de envio 
oWSDL:clogin		:= cBioUsr
oWSDL:cpassword	:= cBioPsw
oWSDL:coperation	:= cOper
oWSDL:cparameters	:= cParam
oWSDL:_URL			:= SuperGetMV("ES_BIOWSDL", NIL, "http://sandbox.bionexo.com.br/ws2/BionexoBean/")

//Carrega XML somente para POST
If cTipo=="P"
	oWSDL:cxml		:= cXml
EndIf

// Habilita informações de debug no log de console
If lDebug
	WSDLDbgLevel(3)
EndIf

// Chama o método do Web Service
If cTipo=="P" 
	lRet:= oWSDL:Post(cBioUsr,cBioPsw,cOper,cParam,cXml)
Else
	lRet:= oWSDL:Request(cBioUsr,cBioPsw,cOper,cParam)
EndIf

If lRet
	cRet:= oWSDL:cReturn
	//aRet:= StrTokArr(cRet,";") //Alterado pois em teste foi incluido observacao com ponto e virgula atrapalhando a logica
	aRet:= U_FSQBRBIO(cRet,";")
Else
	cRet:= GetWSCError()
	aRet:= {"-1", Dtoc(Date())+" "+Time(), cDescErr + CRLF + cRet, ""}
EndIf

Return(aRet)


/*/{Protheus.doc} FSQBRBIO
(long_description)
@type function
@author claudiol
@since 21/01/2016
@version 1.0
@param cRet, character, (Descrição do parâmetro)
@param cSepara, character, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
User Function FSQBRBIO(cRet,cSepara)

Local aRet		:= {}
Local nPos		:= 0
Local nStart	:= 1
Local nXi		:= 0

For nXi:= 1 To 3
	cRet:= SubStr(cRet,nStart)
	If nXi<>3
		nPos:= at(cSepara, cRet, nStart)
	Else
		nPos:= Len(cRet)+1 //Considera o final da string
	EndIf

	If nPos<>0
		cString:= SubStr(cRet,1,nPos-1)
		Aadd(aRet,cString)
		nStart:= nPos+1
	Else
		Exit
	EndIf
Next nXi

Return(aRet)


/*/{Protheus.doc} FSRetPDC
Retorna PDC

@author claudiol
@since 05/01/2016
@version undefined
@param cNumPDC, characters, descricao
@type function
/*/
User Function FSRetPDC(cNumPDC)

Local aRet:= {}
Local cXml:= ""

//Retorna PDC Bionexo
aRet:= U_FSMntXML("R","WDG","LAYOUT=WD;ID="+cNumPDC+";ISO=1",,.F.)

Return(aRet)


/*/{Protheus.doc} FSItensOK
Busca fornecedores ganhadores e itens selecionados

@author claudiol
@since 06/01/2016
@version undefined
@param cXML, characters, descricao
@param aFornece, array, descricao
@param aPedido, array, descricao
@param cMensLog, characters, descricao
@type function
@obs
19/05/2016 Claudio Silva 	Arredondamento do valor unitario de acordo com campo C7_PRECO
/*/
User Function FSItensOK(cXML,aFornece,aItensPDC,cMensLog)

Local lRet		:= .T.
Local lSelect	:= .F.
Local	dDatPdc	:= ctod("")
Local cError  	:= ""
Local cWarning	:= ""
Local	cNumPdc	:= ""
Local	cNumReq	:= ""
Local	cHorPdc	:= ""
Local oXml		:= Nil //XML retorno
Local oXmlCab	:= Nil //Cabecalho
Local oXmlIte 	:= Nil //Itens
Local oXmlRes	:= Nil //Resposta do item
Local oXmlExt 	:= Nil //Resposta - campo extra
Local oXmlIEX 	:= Nil //Item - campo extra
Local oXmlPEN 	:= Nil //Programacao entrega
Local nPos		:= 0
Local nXi		:= 0
Local nYi		:= 0
Local nSemCnpj	:= 0
Local nSemCPg	:= 0 
Local aProduto	:= {}
Local aProdAux	:= {}
Local aForAux	:= {}
Local aForBio	:= {}
Local nVlrUnit:= 0

MemoWrite("\FSItensOK.XML", cXML)

//Gera o Objeto XML ref. ao script
oXml := XmlParser( cXml, "_", @cError, @cWarning )

If (oXml == NIL )
	cMensLog += "Falha ao gerar Objeto XML : "+cError+" / "+cWarning + CRLF
	lRet:= .F.
Endif

If lRet

	oXmlCab:= XmlChildEx(oXml:_RESPOSTAS, "_CABECALHO")

	cNumPdc:= oXmlCab:_PDC:TEXT
	cNumReq:= oXmlCab:_REQUISICAO:TEXT
	dDatPdc:= ctod(oXmlCab:_DATA_VENCIMENTO:TEXT)
	cHorPdc:= oXmlCab:_HORA_VENCIMENTO:TEXT

	//Busca condicao de pagamento
	oXmlFor:= XmlChildEx(oXml:_RESPOSTAS, "_FORNECEDORES") 

	If (XmlChildCount(oXmlFor) <> 0)
		
		// Transforma em array
		If(ValType(oXmlFor:_FORNECEDOR) != "A")
			XmlNode2Arr(oXmlFor:_FORNECEDOR, "_FORNECEDOR")
		EndIf

 		//Verifica cada item
		For nXi:= 1 To Len(oXmlFor:_FORNECEDOR)
			aForAux:= {}
			Aadd(aForAux, U_FSISDIGIT(oXmlFor:_FORNECEDOR[nXi]:_CNPJ:TEXT)) //Deixa somente numeros

			//Busca de/para de condicao de pagamento
			cCondPag:= U_FSBusCPG(oXmlFor:_FORNECEDOR[nXi]:_ID_FORMA_PAGAMENTO:TEXT)

			Aadd(aForAux, cCondPag)
			Aadd(aForAux, oXmlFor:_FORNECEDOR[nXi]:_FRETE:TEXT)
			Aadd(aForBio,aClone(aForAux))
		Next nXi
	EndIf
	
	//Busca Itens
	oXmlIte:= XmlChildEx(oXml:_RESPOSTAS, "_ITENS") 

	If (XmlChildCount(oXmlIte) <> 0)
		
		// Transforma em array
		If(ValType(oXmlITE:_ITEM) != "A")
			XmlNode2Arr(oXmlITE:_ITEM, "_ITEM")
		EndIf

 		//Verifica cada item
		For nXi:= 1 To Len(oXmlIte:_ITEM)

			lSelect:= .F.
			aProduto:= Array(_PDCTAM)
			
			aProduto[_PDCNUME]:= cNumPdc
			aProduto[_PDCDATA]:= dDatPdc
			aProduto[_PDCHORA]:= cHorPdc
			
			//Busca respostas do itemA
			If (Valtype(oXmlITE:_ITEM[nXi]:_RESPOSTA)  != "A")
				XmlNode2Arr(oXmlITE:_ITEM[nXi]:_RESPOSTA, "_RESPOSTA")
			EndIf 
			
			oXmlRes:= XmlChildEx(oXmlITE:_ITEM[nXi], "_RESPOSTA")
			
			For nYi:= 1 To Len(oXmlRes)

				//Verifica campos extra da resposta se item foi selecinado
				If (Valtype(oXmlRes[nYi]:_CAMPO_EXTRA)  != "A")
					XmlNode2Arr(oXmlRes[nYi]:_CAMPO_EXTRA, "_CAMPO_EXTRA")
				EndIf 

				oXmlExt:= XmlChildEx(oXmlRes[nYi], "_CAMPO_EXTRA")
				If (nPos:= aScan(oXmlExt,{|x| Upper(x:_NOME:TEXT) == Upper("Selecionado") })) <> 0
					If (oXmlExt[nPos]:_VALOR:TEXT) == "S" //Selecionado
						lSelect:= .T.
						aProduto[_PDCCNPJ]:= U_FSISDIGIT(oXmlRes[nYi]:_CNPJ:TEXT) //Deixa somente numeros
						nVlrUnit:= Val( Strtran(oXmlRes[nYi]:_PRECO_UNITARIO:TEXT,",",".") )	 //Converte para valor
						aProduto[_PDCPRUN]:= Round(nVlrUnit, TamSX3("C7_PRECO")[2])

						If (nPos:= aScan(aForBio,{|x| x[1] == aProduto[_PDCCNPJ] })) <> 0
							aProduto[_PDCCPAG]:= aForBio[nPos,2]
							aProduto[_PDCTFRE]:= Iif(aForBio[nPos,3]=="CIF","C",Iif(aForBio[nPos,3]=="FOB","F",""))
						EndIf

						Exit
					EndIf
				EndIf

			Next nYi

			If lSelect
				aProduto[_PDCPROD]:= oXmlITE:_ITEM[nXi]:_COD_PRODUTO:TEXT
				aProduto[_PDCQTDO]:= Val(Strtran(oXmlITE:_ITEM[nXi]:_QUANTIDADE:TEXT,",","."))   //Converte para valor
				
				//Campo Extra
				If (Valtype(oXmlITE:_ITEM[nXi]:_CAMPO_EXTRA)  != "A")
					XmlNode2Arr(oXmlITE:_ITEM[nXi]:_CAMPO_EXTRA, "_CAMPO_EXTRA")
				EndIf 

				oXmlIEX:= XmlChildEx(oXmlITE:_ITEM[nXi], "_CAMPO_EXTRA")
				If (nPos:= aScan(oXmlIEX,{|x| Upper(x:_NOME:TEXT) == Upper("Item") })) <> 0 
					aProduto[_PDCSCIT]:= oXmlIEX[nPos]:_VALOR:TEXT
				EndIf
				If (nPos:= aScan(oXmlIEX,{|x| Upper(x:_NOME:TEXT) == Upper("Requisicao") })) <> 0 
					aProduto[_PDCSCNU]:= oXmlIEX[nPos]:_VALOR:TEXT
				EndIf
				If (nPos:= aScan(oXmlIEX,{|x| Upper(x:_NOME:TEXT) == Upper("Justificativa") })) <> 0 
					aProduto[_PDCJUST]:= FWNoAccent(oXmlIEX[nPos]:_VALOR:TEXT)  //Retira acentos
				EndIf

				//Programacao de Entrega
				If (Valtype(oXmlITE:_ITEM[nXi]:_PROGRAMACAO_ENTREGA)  != "A")
					XmlNode2Arr(oXmlITE:_ITEM[nXi]:_PROGRAMACAO_ENTREGA, "_PROGRAMACAO_ENTREGA")
				EndIf 

				oXmlPEN:= XmlChildEx(oXmlITE:_ITEM[nXi], "_PROGRAMACAO_ENTREGA")
				For nYi:= 1 To Len(oXmlPEN)
					aProdAux:= aClone(aProduto)
					aProdAux[_PDCDTEN]:= Ctod(oXmlPEN[nYi]:_DATA:TEXT)  //Converte para data
					aProdAux[_PDCQTEN]:= Val(Strtran(oXmlPEN[nYi]:_QUANTIDADE:TEXT,",","."))	 //Converte para valor

					//Array dos produtos selecionados
					Aadd(aItensPDC, aProdAux)
				Next nYi

			EndIf

			//Proximo item
		Next nXi

	EndIf

EndIf

//Avalia se foi localizado itens marcados
If lRet .And. Len(aItensPDC) == 0
	cMensLog+= "Não foi localizado itens ganhadores no PDC no sistema Bionexo." + CRLF
	lRet:= .F.
EndIf

//Avalia se existe fornecedor selecionado sem o CNPJ
If lRet
	aEval(aItensPDC,{|x| Iif(Empty(x[_PDCCNPJ]), nSemCnpj++, Nil)})
	If nSemCnpj <> 0
		cMensLog+= "Foi localizado um item ganhador sem o CNPJ do fornecedor." + CRLF
		lRet:= .F.
	EndIf
EndIf

//Avalia se existe fornecedor sem condicao de pagamento
If lRet
	aEval(aItensPDC,{|x| Iif(Empty(x[_PDCCPAG]), nSemCPg++, Nil)})
	If nSemCPg <> 0
		cMensLog+= "Foi localizado um item ganhador sem a forma de pagamento Bionexo amarrada a condição de pagamento." + CRLF
		lRet:= .F.
	EndIf
EndIf


If lRet
	//Monta array fornecedores - aFornece
	For nXi:= 1 To Len(aItensPDC)
		If (nPos:= aScan(aFornece, aItensPDC[nXi,_PDCCNPJ] )) == 0
			Aadd(aFornece, aItensPDC[nXi,_PDCCNPJ])
		EndIf
	Next nXi
EndIf

Return(lRet)


/*/{Protheus.doc} FSGerPDC
Gera pedido de compra 

@author claudiol
@since 06/01/2016
@version undefined
@param aPedido, array, descricao
@param cMensLog, characters, descricao
@type function
/*/
User Function FSGerPDC(aItensPDC,aRecSC1,cMensLog)

Local lRet		:= .T.
Local nModAux	:= 0 
Local cMsgRet	:= ""
Local nXi		:= 0
Local aCabec	:= {}
Local aItens	:= {}
Local aPedidos	:= {}

//Monta array pedidos - aPedidos
FMntPDC(aItensPDC,aPedidos,aRecSC1)

For nXi:= 1 To Len(aPedidos)
	aCabec:= aClone(aPedidos[nXi,1])
	aItens:= aClone(aPedidos[nXi,2])

	//Ordena array de acordo com SX3
	U_FSOrdArr(aCabec,"SC7")
		
	//Ordena array de acordo com SX3
	U_FSOrdArr(aItens,"SC7",.T.)

	nModAux:= nModulo
	nModulo:= 2
	If (lRet:= U_FSExeAut("MATA120",3,aCabec,aItens,@cMsgRet))
		cMensLog+= "Gerado Pedido de Compra: "+ SC7->C7_NUM + CRLF
		cMensLog+= "ID Fluig: " + SC7->C7_XIDFLG + CRLF
	Else
		cMensLog+= cMsgRet + CRLF
	EndIf
	nModulo:= nModAux
	
	If !lRet
		Exit
	EndIf
Next nXi
	
Return(lRet)


/*/{Protheus.doc} FMntPDC
Monta array de pedidos de compra a serem gerados

@author claudiol
@since 13/01/2016
@version undefined
@param aItensPDC, array, descricao
@param aPedidos, array, descricao
@type function
@obs
11/02/2016 claudiol 	Inclusao dos campos cc, conta, itemcont e classe valor para ser atualizado a partir do SC1
/*/
Static Function FMntPDC(aItensPDC,aPedidos,aRecSC1)

Local cQuebra	:= ""
Local	lFirst	:= .T.
Local nXi		:= 0
Local aCabec	:= {}
Local aItens	:= {}
Local aItem		:= {}
Local aPedAux	:= {}
Local cNumPed	:= ""

//Ordena por CNPJ + SC + ITEMSC
aSort( aItensPDC,,, { |x,y| x[1]+x[2]+x[3] < y[1]+y[2]+[3] } )

cQuebra:= aItensPDC[1,_PDCCNPJ]

While .T.

	nXi++
	
	If (nXi > Len(aItensPDC)) .Or. (aItensPDC[nXi,_PDCCNPJ] <> cQuebra)
		aPedAux:= {}
		Aadd(aPedAux,aClone(aCabec))
		Aadd(aPedAux,aClone(aItens))
		Aadd(aPedidos,aClone(aPedAux))
		
		If (nXi > Len(aItensPDC))
			Exit
		EndIf
		
		cQuebra:= aItensPDC[nXi,_PDCCNPJ]
		
		aCabec:= {}
		aItens:= {}
		lFirst:= .T.
	EndIf

	//Posiciona SC
	SC1->(DbSetOrder(1)) //C1_FILIAL+C1_NUM+C1_ITEM+C1_ITEMGRD
	SC1->(MsSeek(xFilial("SC1")+aItensPDC[nXi,_PDCSCNU]+aItensPDC[nXi,_PDCSCIT],.T.))

	Aadd(aRecSC1,SC1->(Recno()))

	//Monta array cabecalho
	If lFirst
		//Posiciona Fornecedor
		SA2->(DbSetOrder(3)) //A2_FILIAL+A2_CGC
		SA2->(MsSeek(xFilial("SA2")+aItensPDC[nXi,_PDCCNPJ]))

		cNumPed := CriaVar('C7_NUM', .T.)

		aCabec:= {}
		aadd(aCabec,{"C7_NUM"     ,cNumPed						,Nil})
		aadd(aCabec,{"C7_EMISSAO" ,dDataBase					,Nil})
		aadd(aCabec,{"C7_FORNECE" ,SA2->A2_COD					,Nil})
		aadd(aCabec,{"C7_LOJA"    ,SA2->A2_LOJA				,Nil})
		aadd(aCabec,{"C7_COND"    ,aItensPDC[nXi,_PDCCPAG]	,Nil}) //SC1->C1_XCONPAG
		aadd(aCabec,{"C7_FILENT"  ,xFilial("SC1")				,Nil}) //SC1->C1_FILENT
		aadd(aCabec,{"C7_CONTATO" ,Iif(Empty(SA2->A2_CONTATO),".",SA2->A2_CONTATO)	,Nil})
		aadd(aCabec,{"C7_TPFRETE" ,aItensPDC[nXi,_PDCTFRE]	,Nil}) //SC1->C1_XCONPAG
		
		lFirst:= .F.
	EndIf

	//Monta array de itens
	aItem := {}
	aadd(aItem,{"C7_PRODUTO"		,aItensPDC[nXi,_PDCPROD]	,Nil})
	aadd(aItem,{"C7_QUANT"		,aItensPDC[nXi,_PDCQTEN]	,Nil})
	aadd(aItem,{"C7_PRECO"		,aItensPDC[nXi,_PDCPRUN]	,Nil})
	aadd(aItem,{"C7_NUMSC"		,aItensPDC[nXi,_PDCSCNU]	,Nil})
	aadd(aItem,{"C7_ITEMSC"		,aItensPDC[nXi,_PDCSCIT]	,Nil})
	aadd(aItem,{"C7_DATPRF"		,aItensPDC[nXi,_PDCDTEN]	,Nil})
	aadd(aItem,{"C7_XNUMPDC"		,aItensPDC[nXi,_PDCNUME]	,Nil})
	aadd(aItem,{"C7_XJUSTIF"		,aItensPDC[nXi,_PDCJUST]	,Nil})

	aadd(aItem,{"C7_CC"			,SC1->C1_CC		,Nil})
	aadd(aItem,{"C7_CONTA"		,SC1->C1_CONTA	,Nil})
	aadd(aItem,{"C7_ITEMCTA"		,SC1->C1_ITEMCTA	,Nil})
	aadd(aItem,{"C7_CLVL"		,SC1->C1_CLVL		,Nil})

	Aadd(aItens,aItem)

EndDo

Return


/*/{Protheus.doc} FSRetFor
Retorna dados do fornecedor

@author claudiol
@since 06/01/2016
@version undefined
@param aFornece, array, descricao
@param cMensLog, characters, descricao
@type function
/*/
User Function FSRetFor(aFornece, cMensLog)

Local	aAreOld	:= {SA2->(GetArea()),GetArea()}
Local lRet		:= .T.
Local cSeek		:= ""
Local aNaoExis	:= {}
Local cCNPJ		:= ""
Local aRet		:= {}
Local nXi		:= 0
Local aCabec	:= {}
Local cMsgRet	:= ""

//Verifica fornecedores não cadastrados
For nXi:= 1 To Len(aFornece)

	cCNPJ:= U_FSISDIGIT(aFornece[nXi]) //Deixa somente numeros

	SA2->(DbSetOrder(3)) //A2_FILIAL+A2_CGC
	SA2->(MsSeek(cSeek:= xFilial("SA2")+cCNPJ))
	If SA2->(Eof()) //.And. (cSeek <> SA2->(A2_FILIAL+Alltrim(A2_CGC)))
		Aadd(aNaoExis,cCNPJ)
	EndIf

Next nXi


For nXi:= 1 To Len(aNaoExis)

	//Retorna Dados do Fornecedor
	aRet:= U_FSMntXML("R","WMG","LAYOUT=WM;ISO=1; CNPJ="+aNaoExis[nXi],,.F.)

	If aRet[_RTBIOSTA]  == "1" //-1=Erro; 0=Sem Dados;1=Ok
		//Monta array de fornecedor a partir do XML de retorno
		lRet:= U_FSXmlFor(aRet[_RTBIOMSG], @aCabec, @cMensLog)
		
		If !lRet
			Exit
		EndIf

		nModAux:= nModulo
		nModulo:= 2
		lRet:= U_FSExeAut("MATA020",3,aCabec,,@cMsgRet)
		nModulo:= nModAux
		
		cMensLog+= cMsgRet + CRLF
	Else
		lRet:= .F.
		If aRet[_RTBIOSTA] == "0" //-1=Erro; 0=Sem Dados;1=Ok
			cMensLog+= "Não existe retorno." + CRLF
		Else
			cMensLog+= aRet[_RTBIOMSG] + CRLF
		EndIf
	EndIf

Next nXi

aEval(aAreOld, {|xAux| RestArea(xAux)})

Return(lRet)


/*/{Protheus.doc} FSXmlFor
Monta array para SIGAAUTO

@author claudiol
@since 06/01/2016
@version undefined
@param aCabec, array, descricao
@type function
/*/
User Function FSXmlFor(cXml, aCabec, cMensLog)

Local cError  	:= ""
Local cWarning	:= ""
Local oXml		:= Nil
Local oXmlCab 	:= Nil
Local aTagCab	:= FForBio() //Carrega array de de/para
Local cCampo	:= ""
Local bBloco	:= Nil
Local nXi		:= 0
Local cTagXml	:= ""
Local xValor
Local lRet		:= .T.

aCabec:= {}

//Gera o Objeto XML ref. ao script
oXml := XmlParser( cXml, "_", @cError, @cWarning )

If (oXml == NIL )
	cMensLog += "Falha ao gerar Objeto XML : "+cError+" / "+cWarning + CRLF
	lRet:= .F.
Endif

If lRet
	oXmlCab:= XmlChildEx(oXml:_EMPRESAS, "_EMPRESA")
	
	//Monta array cabecalho
	aCabec:= {}
	For nXi:= 1 To XmlChildCount(oXmlCab)  
	
		cTagXml	:= UPPER(Alltrim(XmlGetChild(oXmlCab, nXi):REALNAME))

		If (nPos:= aScan(aTagCab,{|x| Alltrim(Upper(x[2])) == cTagXml })) <> 0

			cCampo:= aTagCab[nPos,1]
			bBloco:= aTagCab[nPos,3]

			cTipo		:= TamSX3(cCampo)[3]
			If cTipo == "D"
				xValor := StoD(XmlGetChild(oXmlCab, nXi):Text)
			ElseIf cTipo == "N"
				xValor := Val(Strtran(XmlGetChild(oXmlCab, nXi):Text,",","."))
			Else
				xValor := XmlGetChild(oXmlCab, nXi):Text
				xValor := Upper(xValor) 		//Passa a string para maiusculo 
				xValor := FWNoAccent(xValor)  //Retira acentos
			EndIf

			If !Empty(bBloco)
				xValor := Eval(&bBloco, xValor)
			EndIf

			Aadd(aCabec,{aTagCab[nPos,1], xValor, Nil})

		EndIf
			
	Next nXi

	//Verifica campos não recebidos no XML
	For nXi:= 1 To Len(aTagCab)

		If Empty(aTagCab[nXi,2])
	
			cCampo:= aTagCab[nXi,1]
			bBloco:= aTagCab[nXi,3]
			xValor:= Nil

			If !Empty(bBloco)
				xValor := Eval(&bBloco, xValor, aCabec)
			EndIf

			Aadd(aCabec,{aTagCab[nXi,1], xValor, Nil})

		EndIf
			
	Next nXi

	//Ordena array de acordo com SX3
	U_FSOrdArr(aCabec,"SA2")
	
EndIf

Return(lRet)


/*/{Protheus.doc} FForBio
Relacao TAG WS Bionexo X Campo tabela fornecedor 

@author claudiol
@since 06/01/2016
@version undefined
@type function
/*/
Static Function FForBio()

Local aTagCab:= {}

Aadd(aTagCab,{"A2_NOME" 	,"Razao_Social"			, "" })
Aadd(aTagCab,{"A2_NREDUZ" 	,"Nome_Fantasia"		, "{|x| U_FSRetNRE(x,'A2_NREDUZ') }" })
Aadd(aTagCab,{"A2_CGC" 		,"CNPJ"					, "{|x| U_FSISDIGIT(x) }" })
Aadd(aTagCab,{"A2_INSCR" 	,"Inscricao_Estadual"	, "{|x| U_FSISDIGIT(x) }" })
Aadd(aTagCab,{"A2_CEP" 		,"CEP"					, "{|x| U_FSISDIGIT(x) }" })
Aadd(aTagCab,{"A2_END" 		,"Logradouro"			, "" })
Aadd(aTagCab,{"A2_MUN" 		,"Cidade"				, "" })
Aadd(aTagCab,{"A2_EST" 		,"Estado_Sigla"			, "" })
Aadd(aTagCab,{"A2_PAIS" 	,"Pais"					, "{|x| U_FSRetPais(x) }" })
Aadd(aTagCab,{"A2_TEL" 		,"Telefone"				, "" })
Aadd(aTagCab,{"A2_FAX" 		,"Fax"					, "" })
Aadd(aTagCab,{"A2_CONTATO" ,"Contato"				, "" })
Aadd(aTagCab,{"A2_EMAIL" 	,"Email"					, "" })
Aadd(aTagCab,{"A2_TIPO" 	,""						, "{|x,y| Iif(Len(U_FSISDIGIT(U_FSRetVal(y,'A2_CGC')))==14,'J','F')  }" })
Aadd(aTagCab,{"A2_COD" 		,""						, "{|x,y| Left(U_FSISDIGIT(U_FSRetVal(y,'A2_CGC')),8) }" })
Aadd(aTagCab,{"A2_LOJA" 	,""						, "{|x,y| SubStr(U_FSISDIGIT(U_FSRetVal(y,'A2_CGC')),9,4) }" })
Aadd(aTagCab,{"A2_XBIONEX" ,""						, "{|| 'S' }" })
Aadd(aTagCab,{"A2_COD_MUN" ,""						, "{|x,y| U_FSRetMun(U_FSRetVal(y,'A2_EST'), U_FSRetVal(y,'A2_MUN')) }" })

Return(aTagCab)


/*/{Protheus.doc} FSRetPais
Pesquisa codigo do Pais

@author claudiol
@since 06/01/2016
@version undefined
@param cNomPais, characters, descricao
@type function
/*/
User Function FSRetPais(cNomPais)

Local	aAreOld	:= {SYA->(GetArea()),GetArea()}
Local cRet:= "" 
Local cSeek:= ""

cNomPais:= FWNoAccent(cNomPais) //Retira acentos se tiver

SYA->(dbSetOrder(2)) //YA_FILIAL+YA_DESCR
SYA->(MsSeek(cSeek:= xFilial("SYA")+Upper(cNomPais)))
If SYA->(!Eof()) .And. Alltrim(cSeek)==Alltrim(SYA->(YA_FILIAL+YA_DESCR))
	cRet:= SYA->YA_CODGI
EndIf

aEval(aAreOld, {|xAux| RestArea(xAux)})

Return(cRet)


/*/{Protheus.doc} FSRetNRE
Retorna conteudo com tamanho do campo do SX3
@author Jonatas Oliveira | www.compila.com.br
@since 14/08/2018
@param cDescCp, characters, descricao
@param cCpoSx3, characters, campo do SX3
@version 1.0
/*/
User Function FSRetNRE(cDescCp, cCpoSx3)

	Local cRet:= "" 

	cDescCp	:= FWNoAccent(cDescCp) //Retira acentos se tiver
	
	cRet	:=	LEFT( cDescCp,TAMSX3(cCpoSx3)[1])

Return(cRet)



/*/{Protheus.doc} FSRetMun
Retorna o codigo do municipio

@author claudiol
@since 08/01/2016
@version undefined
@param cMunEst, characters, descricao
@param cMunNom, characters, descricao
@type function
/*/
User Function FSRetMun(cMunEst, cMunNom)

Local	aAreOld	:= {CC2->(GetArea()),GetArea()}
Local cRet:= "" 
Local cSeek:= ""

cMunNom:= FWNoAccent(cMunNom) //Retira acentos se tiver

CC2->(dbSetOrder(4)) //CC2_FILIAL+CC2_EST+CC2_MUN
CC2->(MsSeek(cSeek:= xFilial("CC2")+Upper(Padr(cMunEst,2)+cMunNom)))
If SYA->(!Eof()) .And. Alltrim(cSeek)==Alltrim(CC2->(CC2_FILIAL+CC2_EST+CC2_MUN))
	cRet:= CC2->CC2_CODMUN
EndIf

aEval(aAreOld, {|xAux| RestArea(xAux)})

Return(cRet)


/*/{Protheus.doc} FSGrvSC1
Grava historico, status e numero PDC apos envio Bionexo

@author claudiol
@since 05/01/2016
@version undefined
@param aRecSC1, array, descricao
@param aRet, array, descricao
@type function
/*/
User Function FSGrvSC1(cOper,aRecSC1,aRet,cNumReq,cMsgAux,cMensLog)

Local lRet		:= .T.
Local cNumBio	:= aRet[_RTBIOMSG]
Local cNumPdc	:= ""
Local cHistor	:= ""
Local nXi		:= 0

Default cNumReq:= ""
Default cMsgAux:= ""
Default cMensLog:= ""

//Monta historico
cHistor:= aRet[_RTBIODAT] + Space(02)
cHistor+= Alltrim(cUserName) + Space(02)

If cOper=="E"
	cNumPdc:= cNumBio
	cDesOpe:= "Enviado"
	cStaBio:= "1"
ElseIf cOper=="R"
	cNumPdc:= cNumBio
	cDesOpe:= "Retornado"
	cStaBio:= "2"
ElseIf (cOper=="C")
	cNumPdc:= ""
	cDesOpe:= "Cancelado"
	cStaBio:= "3"
ElseIf (cOper=="X")
	cNumPdc:= cNumBio
	cDesOpe:= "Excluido"
	cStaBio:= "1"
ElseIf (cOper=="Y")
	cNumPdc:= cNumBio
	cDesOpe:= ""
	cStaBio:= "1"
	cHistor:= ""
EndIf

If (cOper=="X")
	cHistor+= cDesOpe + " "
ElseIf (cOper=="Y")
	cHistor+= ""
Else
	cHistor+= Padr(cDesOpe,10) + "PDC no. " + cNumBio
EndIf

If !Empty(cMsgAux)
	cHistor+= cMsgAux + CRLF
ElseIf !Empty(cHistor)
	cHistor+= CRLF
EndIf

For nXi:= 1 To Len(aRecSC1)

	SC1->(dbGoto(aRecSC1[nXi]))

	If (lRet:= Reclock("SC1",.F.))
		SC1->C1_XNUMPDC:= cNumPdc
		SC1->C1_XSTABIO:= cStaBio
		If !Empty(cHistor)
			SC1->C1_XHISBIO:= cHistor + SC1->C1_XHISBIO  //Adiciona sempre a ultima ocorrencia primeiro
		EndIf

		If cOper $ "E"
			SC1->C1_XTIPPDC:= cGetTipCot
			SC1->C1_XDATVEN:= dGetDatVen
			SC1->C1_XHORVEN:= cGetHorVen
			SC1->C1_XCONPAG:= cGetConPag
			SC1->C1_XOBS	:= cMGObs
		EndIf

		If cOper $ "EC"
			SC1->C1_XNUMREQ:= cNumReq
		EndIf

		SC1->(MsUnlock())
	Else
		Exit
	EndIf

Next nXi

If !lRet
	cMensLog += "As SCs do PDC " + cNumPdc + " não foram corretamente atualizadas no sistema. Verifique!" + CRLF
EndIf

Return(lRet)


/*/{Protheus.doc} FSBusSC1
Busca todas as SCs do PDC

@author claudiol
@since 11/01/2016
@version undefined
@param cNumPDc, characters, descricao
@type function
/*/
User Function FSBusSC1(cNumPDc, aRecSC1, cMensLog, lSemPed)

Local lRet			:= .T.
Local cAliTMP		:= GetNextAlias()
Local nCtdNok		:= 0

Default cMensLog	:= ""
Default lSemPed	:= .F.

//Pesquisa na tabela SN1
BeginSql Alias cAliTMP
	SELECT SC1.R_E_C_N_O_ SC1RECNO, SC1.C1_QUJE, SC1.C1_PEDIDO, SC1.C1_RESIDUO
	FROM %table:SC1% SC1
	WHERE SC1.%notDel%
	  AND SC1.C1_FILIAL 	= %xFilial:SC1%
	  AND SC1.C1_XNUMPDC = %exp:cNumPDC%
EndSql

//Carrega recno de todos as SCs do PDC
(cAliTmp)->(dbGotop())
While (cAliTmp)->(!Eof())
	If !lSemPed
		Aadd(aRecSC1, (cAliTmp)->SC1RECNO)
		If (cAliTmp)->C1_QUJE <> 0 .Or. !Empty((cAliTmp)->C1_PEDIDO)
			nCtdNok++
		EndIf
	Else
		If (cAliTmp)->C1_QUJE <> 0 .Or. Empty((cAliTmp)->C1_PEDIDO)
			Aadd(aRecSC1, (cAliTmp)->SC1RECNO)
		EndIf
	EndIf

	(cAliTmp)->(dbSkip())
EndDo

(cAliTMP)->(dbCloseArea())

If !lSemPed
	//Verifica se foi encontrado SC e se todas ainda nao foram utilizadas
	lRet:= (Len(aRecSC1)<>0 .And. nCtdNok==0)
	If !lRet
		cMensLog += "Existem SCs que já foram processadas!" + CRLF
	EndIf
Else
	lRet:= (Len(aRecSC1)<>0)
EndIf

Return(lRet)


/*/{Protheus.doc} FSVerPdc
Verifica a existencia de mais de um pedido de compra para o mesmo PDC (Pedido de Compra Bionexo)

@author claudiol
@since 14/01/2016
@version undefined
@param nOpcao, numeric, descricao
@param cPedCom, characters, descricao
@type function
/*/
User Function FSVerPdc(nOpcao,cPedCom)

Local lRet		:= .T.
Local cAliTMP	:= GetNextAlias()
Local cNumPDC	:= SC7->C7_XNUMPDC
Local cPedidos	:= ""
Local aPedCom	:= {}

//Pesquisa na tabela SN1
BeginSql Alias cAliTMP
	SELECT SC7.R_E_C_N_O_ SC7RECNO, SC7.C7_NUM
	FROM %table:SC7% SC7
	WHERE SC7.%notDel%
	  AND SC7.C7_FILIAL 	= %xFilial:SC7%
	  AND SC7.C7_XNUMPDC = %exp:cNumPDC%
	  AND SC7.C7_NUM	 	<> %exp:cPedCom%
EndSql

(cAliTmp)->(dbGotop())
While (cAliTmp)->(!Eof())
	If aScan(aPedCom, (cAliTmp)->C7_NUM)==0
		Aadd(aPedCom, (cAliTmp)->C7_NUM)
	EndIf
	(cAliTmp)->(dbSkip())
EndDo

(cAliTMP)->(dbCloseArea())

//Verifica se foi encontrado SC e se todas ainda nao foram utilizadas
If (!Empty(aPedCom))
	aEval(aPedCom,{|x| cPedidos += (x + "/") })

	cMsgAux := "Existem mais pedidos de compra para O PDC " + cNumPDC + ". Verifique!" + CRLF
	cMsgAux += "Pedidos: " + cPedidos + CRLF + CRLF
	cMsgAux += "Continua EXCLUSÃO do Pedido "+cPedCom+"?"
	lRet:= ApMsgNoYes(cMsgAux,".:Confirmação:.")
EndIf

Return(lRet)


/*/{Protheus.doc} FSBusCPG
Busca condicao de pagamento a partir do codigo da forma de pagamento bionexo

@author claudiol
@since 20/01/2016
@version undefined
@param cForPag, characters, descricao
@type function
/*/
User Function FSBusCPG(cForPag)

Local cRet		:= ""
Local cAliTMP	:= GetNextAlias()

//Pesquisa na tabela SE4
BeginSql Alias cAliTMP
	SELECT SE4.E4_CODIGO
	FROM %table:SE4% SE4
	WHERE SE4.%notDel%
	  AND SE4.E4_FILIAL 	= %xFilial:SE4%
	  AND SE4.E4_XFPGBIO = %exp:cForPag%
	  AND SE4.E4_MSBLQL = '2'
EndSql

(cAliTmp)->(dbGotop())
If (cAliTmp)->(!Eof())
	cRet:= (cAliTmp)->E4_CODIGO
EndIf

(cAliTMP)->(dbCloseArea())

Return(cRet)
