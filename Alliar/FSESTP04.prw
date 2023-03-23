#include 'protheus.ch'
#include 'parmtype.ch'

#define _CABLOG 	1
#define _CABSEN	2
#define _CABCNPJ	3
#define _CABDATA	4

#define _ITPROD	1
#define _ITQUANT	2
#define _ITQTDCON	3
#define _ITOPER	4

/*/{Protheus.doc} FSESTP04
Recebimento do consumo efetuado no Pleres

@author claudiol
@since 24/02/2016
@version undefined

@type function
/*/
user function FSESTP04(cXml)
	
Local aRet		:= {}
Local aRetCon	:= FRetFil()
Local cEmpCon	:= aRetCon[1]
Local cFilCon	:= aRetCon[2]
Local lOk		:= .T.
Local aCabec	:= {}
Local aItens	:= {}
Local cMensLog	:= ""

If Select("SM0") == 0
	//Abri o ambiente na primeira filial
	RpcSetEnv(cEmpCon, cFilCon)
EndIf

//Le XML
aRet:= FLeXml(cXml, @cMensLog) //{lRet, aCabec,aItens}

lOk	:= aRet[1]
aCabec:= aRet[2]
aItens:= aRet[3]

If aRet[1]
	cCNPJ:= aCabec[_CABCNPJ]

	//Valida usuario/senha
	If U_FVerPwd(aCabec[_CABLOG], aCabec[_CABSEN])
		//Seta a filial do CNPJ de solicitacao
		aRetCon	:= FRetFil(cCNPJ)
		cEmpCon	:= aRetCon[1]
		cFilCon	:= aRetCon[2]
		
		If !Empty(cEmpCon) .And. !Empty(cFilCon) .And. RpcSetEnv(cEmpCon, cFilCon)
			//Acerta filial
			U_FSMudFil(cFilCon)
			
			//Gera requisicao
			If (lRet:= FGrvReg(aCabec, aItens, @cMensLog))
				aRet:= {"0",cMensLog,""}
			Else
				aRet:= {"-1",cMensLog,""}
			EndIf
		Else
			aRet:= {"-1","ERRO: EMPRESA/FILIAL INVÁLIDA!",""}
		EndIf
	Else
		aRet:= {"-1","ERRO: USUÁRIO/SENHA INVÁLIDA!",""}
	EndIf
	
Else
	If Empty(cMensLog)
		cMensLog+= "ERRO: LEITURA NO XML!"
	EndIf
	aRet:= {"-1", cMensLog, ""}
EndIf

Return(aRet)


/*/{Protheus.doc} FLeXml
Monta 
@author claudiol
@since 24/02/2016
@version undefined
@param cXml, characters, descricao
@type function
/*/
Static Function FLeXml(cXml, cMensLog) 

Local cError  	:= ""
Local cWarning	:= ""
Local oXml		:= Nil
Local oXmlIte	:= Nil
Local aCabec	:= {}
Local aItens	:= {}
Local aItem		:= {}
Local lRet		:= .T.

//Gera o Objeto XML ref. ao script
oXml := XmlParser( cXml, "_", @cError, @cWarning )

If (oXml == NIL )
	cMensLog += "Falha ao gerar Objeto XML : "+cError+" / "+cWarning + CRLF
	lRet:= .F.
Endif

If lRet
	Aadd(aCabec, oXml:_ESTOQUE:_LOGIN:TEXT)
	Aadd(aCabec, oXml:_ESTOQUE:_SENHA:TEXT)
	Aadd(aCabec, oXml:_ESTOQUE:_CNPJFILIAL:TEXT)
	Aadd(aCabec, Stod(oXml:_ESTOQUE:_DATA:TEXT))

	//Busca Itens
	oXmlIte:= XmlChildEx(oXml:_ESTOQUE, "_ITENS") 

	If (XmlChildCount(oXmlIte) <> 0)
		// Transforma em array
		If(ValType(oXmlITE:_ITEM) != "A")
			XmlNode2Arr(oXmlITE:_ITEM, "_ITEM")
		EndIf

 		//Verifica cada item
		For nXi:= 1 To Len(oXmlIte:_ITEM)
			aItem:= {}
			Aadd(aItem, oXmlITE:_ITEM[nXi]:_PRODUTO:TEXT)
			Aadd(aItem, Val(Strtran(oXmlITE:_ITEM[nXi]:_QUANT:TEXT,",",".")))	 //Converte para valor
			Aadd(aItem, Val(Strtran(oXmlITE:_ITEM[nXi]:_QTDCON:TEXT,",",".")))	 //Converte para valor
			Aadd(aItem, oXmlITE:_ITEM[nXi]:_OPERACAO:TEXT)

			//Array dos produtos selecionados
			Aadd(aItens, aItem)
		Next nXi
	EndIf
EndIf

Return({lRet, aCabec, aItens})


/*/{Protheus.doc} FRetFil
Retorna uma filial valida para a empresa

@author claudiol
@since 24/02/2016
@version undefined
@param cCNPJ, characters, descricao
@type function
/*/
Static Function FRetFil(cCNPJ)

Local cEmpRet	:= ""
Local cFilRet	:= ""
Local nXi		:= 0

Default cCNPJ:= ""

If Select("SM0")==0
	If U_FSOpenSm0(.T.)
		SM0->(dbGoTop())
		cEmpRet:= SM0->M0_CODIGO
		cFilRet:= SM0->M0_CODFIL
		SM0->( dbCloseArea() )
	EndIf
Else
	//Carrega todas as filiais
	aSM0 := FWLoadSM0()

	For nXi:= 1 To Len(aSM0)
		If (Alltrim(aSM0[nXi,SM0_CGC]) == Alltrim(U_FSISDIGIT(cCNPJ)))
			cEmpRet:= aSM0[nXi,SM0_EMPRESA]
			cFilRet:= aSM0[nXi,SM0_CODFIL]
		EndIf
	Next nXi
EndIf

Return({cEmpRet,cFilRet})


/*/{Protheus.doc} FGrvReg
Gera requisicao almoxarifado

@author claudiol
@since 24/02/2016
@version undefined
@param aCabec, array, descricao
@param aItens, array, descricao
@type function
/*/
Static Function FGrvReg(aCabEnv, aIteEnv, cMensLog)

Local lRet		:= .T.
Local nXi		:= 0
Local aItem		:= {}
Local lExiste	:= .T.
Local lInclui	:= .F.
Local lAltera	:= .F.
Local lDeleta	:= .F.

For nXi:= 1 To Len(aIteEnv)

	lInclui	:= .F.
	lAltera	:= .F.
	lDeleta	:= .F.
	lRet		:= .T.

	SB1->(dbSetOrder(1)) //B1_FILIAL+B1_COD
	SB1->(MsSeek(xFilial("SB1")+aIteEnv[nXi,_ITPROD]))
	If SB1->(Eof())
		cMensLog+= "Produto Inexistente: "+aIteEnv[nXi,_ITPROD] + CRLF
		Loop
	EndIf

	//Avalia se já existe
	SZ9->(dbSetOrder(1)) //Z9_FILIAL+Z9_PRODUTO
	SZ9->(MsSeek(xFilial("SZ9")+aIteEnv[nXi,_ITPROD]))
	lExiste:= SZ9->(!Eof())
	
	If aIteEnv[nXi,_ITOPER]=="D" .And. lExiste
		lDeleta:= .T.
	ElseIf aIteEnv[nXi,_ITOPER]=="U" .And. !lExiste
		lInclui:= .T.
	ElseIf aIteEnv[nXi,_ITOPER]=="U" .And. lExiste
		lAltera:= .T.
	Else
		lRet:= .F.
	EndIf

	If lRet
		BeginTran()

			If lDeleta
				lRet:= U_FSGrvReg(Nil,.F.,"SZ9",Nil,lDeleta)

			ElseIf lInclui .Or. lAltera

				aItem:= {}
				aadd(aItem,{"Z9_FILIAL"	, xFilial("SZ9")			, Nil})
				aadd(aItem,{"Z9_PRODUTO", aIteEnv[nXi,_ITPROD]	, Nil})
				aadd(aItem,{"Z9_DATA" 	, aCabEnv[_CABDATA]		, Nil})
				aadd(aItem,{"Z9_QUANT" 	, aIteEnv[nXi,_ITQUANT]	, Nil})
				aadd(aItem,{"Z9_QTDCON"	, aIteEnv[nXi,_ITQTDCON], Nil})

				lRet:= U_FSGrvReg(aItem,!lExiste,"SZ9")

			EndIf
		
			If lRet
				//Efetiva transacao
				EndTran()
			Else
				//Disarmo a transação
				DisarmTransaction ()
			EndIF
		
		MsUnlockAll()
		
	EndIf
Next nXi
	
Return(lRet)
	