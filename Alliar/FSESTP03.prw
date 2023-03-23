#include 'protheus.ch'
#include 'parmtype.ch'
#include 'FWCommand.ch'  

#define _CABLOG 	1
#define _CABSEN	2
#define _CABCNPJ	3
#define _CABIDREQ	4
#define _CABOPER	5
#define _ITPROD	1
#define _ITQUANT	2
#define _ITDATPRF	3
#define _ITOBS		4

/*/{Protheus.doc} FSESTP03
Recebimento Requisicao ao almoxarifado

@author claudiol
@since 24/02/2016
@version undefined

@type function
/*/
user function FSESTP03(cXml)
	
Local aRet		:= {}
Local aRetCon	:= FRetFil()
Local cEmpCon	:= aRetCon[1]
Local cFilCon	:= aRetCon[2]
Local cFilOri	:= ""
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
			//Altera a filial solicitante para a filial CD
			cFilOri:= cFilCon
			cFilCon:= U_R05Fil(cFilOri)

			//Acerta filial
			U_FSMudFil(cFilCon)
			
			//Gera requisicao
			If (lRet:= FGerReq(aCabec, aItens, @cMensLog, cFilOri))
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
	//Valida xml recebido
	lRet:= FVldDad(oXml,@cMensLog)
EndIf

If lRet
	Aadd(aCabec, oXml:_REQUISICAO:_LOGIN:TEXT)
	Aadd(aCabec, oXml:_REQUISICAO:_SENHA:TEXT)
	Aadd(aCabec, oXml:_REQUISICAO:_CNPJFILIAL:TEXT)
	Aadd(aCabec, oXml:_REQUISICAO:_IDREQUIS:TEXT)
	Aadd(aCabec, oXml:_REQUISICAO:_OPERACAO:TEXT)

	//Busca Itens
	oXmlIte:= XmlChildEx(oXml:_REQUISICAO, "_ITENS") 

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
			Aadd(aItem, Stod(oXmlITE:_ITEM[nXi]:_NECESSIDADE:TEXT)) //Converte data
			Aadd(aItem, oXmlITE:_ITEM[nXi]:_OBS:TEXT)

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


/*/{Protheus.doc} FGerReq
Gera requisicao almoxarifado

@author claudiol
@since 24/02/2016
@version undefined
@param aCabec, array, descricao
@param aItens, array, descricao
@type function
/*/
Static Function FGerReq(aCabEnv, aIteEnv, cMensLog, cFilOri)

Local lRet		:= .T.
Local nModAux	:= 0 
Local cMsgRet	:= ""
Local nXi		:= 0
Local aCabec	:= {}
Local aItens	:= {}
Local aItem		:= {}
Local cCusto	:= U_FSCustoFil(aCabEnv[_CABCNPJ]) 
Local lExiste	:= .T.
Local cSeqIte	:= ""
Local lInclui	:= .F.
Local lAltera	:= .F.
Local lDeleta	:= .F.
Local lContinua:= .T.
Local dEmiss 

Private cFsNumReq:= "" //Numero da requisicao alimentada via PE

//Avalia se já existe
SCP->(dbOrderNickName("FSSCP01")) //CP_FILIAL+CP_XIDPLE
SCP->(MsSeek(xFilial("SCP")+aCabEnv[_CABIDREQ]))
lExiste:= SCP->(!Eof())

If aCabEnv[_CABOPER]=="D" .And. lExiste
	lDeleta:= .T.
ElseIf aCabEnv[_CABOPER]=="U" .And. !lExiste
	lInclui:= .T.
ElseIf aCabEnv[_CABOPER]=="U" .And. lExiste
	lAltera:= .T.
Else
	lRet:= .F.
	cMensLog += "Operação Invalida!"
EndIf

If lRet
	BeginTran()

		If lAltera .Or. lDeleta
			cFsNumReq:= SCP->CP_NUM
		
			aCabec := {}
			aadd(aCabec,{"CP_FILIAL"	, SCP->CP_FILIAL	, Nil})
			aadd(aCabec,{"CP_NUM"		, SCP->CP_NUM		, Nil})
			aadd(aCabec,{"CP_SOLICIT" 	, SCP->CP_SOLICIT	, Nil}) // Nome do Solicitante (usuário logado)
			aadd(aCabec,{"CP_EMISSAO" 	, SCP->CP_EMISSAO	, Nil}) // Data de Emissão
	
			aItens := {}
			SCP->(dbSetOrder(1)) //CP_FILIAL+CP_NUM+CP_ITEM+DTOS(CP_EMISSAO)
			SCP->(MsSeek(cSeek:= xFilial("SCP")+cFsNumReq,.T.))
			While SCP->(!Eof()) .And. cSeek==SCP->(CP_FILIAL+CP_NUM)
			
				aItem:= {}
				aadd(aItem, {"CP_ITEM"		, SCP->CP_ITEM		, Nil})
				aadd(aItem, {"CP_PRODUTO"	, SCP->CP_PRODUTO	, Nil})
				aadd(aItem, {"CP_QUANT"   	, SCP->CP_QUANT	, Nil})
				Aadd(aItens,aItem)
			
				SCP->(dbSkip())
			EndDo
	
			dbSelectArea("SCP")
			dbSetOrder(1)
			nModAux:= nModulo
			nModulo:= 4
			If (lRet:= U_FSExeAut("MATA105",5,aCabec,aItens,@cMsgRet))
				cMensLog+= "Excluído Requisição Armazem: "+ cFsNumReq + CRLF
			Else
				cMensLog+= cMsgRet + CRLF
				lContinua:= .F.
			EndIf
			nModulo:= nModAux
		EndIf
	
		If lContinua .And. (lInclui .Or. lAltera)
			aCabec := {}
			dEmiss := dDataBase 

			aItens := {}
			cSeqIte:= Strzero(0, TamSX3("CP_ITEM")[1])
			For nXi:= 1 To Len(aIteEnv)
				aItem:= {}
				cSeqIte:= Soma1(cSeqIte)
				If aIteEnv[nXi,_ITDATPRF] < dEmiss
					dEmiss := aIteEnv[nXi,_ITDATPRF]
				Endif
				
				aadd(aItem, {"CP_ITEM"		, cSeqIte					, Nil})
				aadd(aItem, {"CP_PRODUTO"	, aIteEnv[nXi,_ITPROD]	, Nil})
				aadd(aItem, {"CP_QUANT"   	, aIteEnv[nXi,_ITQUANT]	, Nil})
				aadd(aItem, {"CP_DATPRF"   , aIteEnv[nXi,_ITDATPRF], Nil})
				aadd(aItem, {"CP_OBS"    	, aIteEnv[nXi,_ITOBS]	, Nil})
				aadd(aItem, {"CP_CC"    	, cCusto 					, Nil})
				aadd(aItem, {"CP_XIDPLE"	, aCabEnv[_CABIDREQ]		, Nil})
				aadd(aItem, {"CP_XFILORI", cFilOri		, Nil})
				Aadd(aItens,aItem)
			Next nXi

			aadd(aCabec,{"CP_EMISSAO" 	,dEmiss , Nil})

			//Ordena array de acordo com SX3
			U_FSOrdArr(aCabec,"SCP")
	
			//Ordena array de acordo com SX3
			U_FSOrdArr(aItens,"SCP",.T.)
	
			nModAux:= nModulo
			nModulo:= 4
			If (lRet:= U_FSExeAut("MATA105",3,aCabec,aItens,@cMsgRet))
				cMensLog+= "Gerado Requisição Armazem: "+ cFsNumReq + CRLF
			Else
				cMensLog+= cMsgRet + CRLF
			EndIf
			nModulo:= nModAux
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
	
Return(lRet)


/*/{Protheus.doc} FVldDad
Valida obrigatoriedade dos dados recebidos
@type function
@author claudiol
@since 09/06/2016
@version 1.0
@param aCabec, array, (Descrição do parâmetro)
@param aItem, array, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function FVldDad(oXml,cMensLog)

Local lRet:= .T.
Local cXmlName:= ""
Local cXmlText:= ""
Local nXi:= 0
Local oXmlIte

//Valida cabecalho
For nXi := 1 to XmlChildCount(oXml:_REQUISICAO)
	cXmlName:= Upper(XmlGetChild(oXml:_REQUISICAO, nXi):REALNAME)
	cXmlText:= XmlGetChild(oXml:_REQUISICAO, nXi):TEXT
	If cXmlName <> "ITENS" .And. Empty(cXmlText)
		cMensLog += "Não Informado TAG " + cXmlName + CRLF
	EndIf
Next nXi

//Valida itens
oXmlIte:= XmlChildEx(oXml:_REQUISICAO, "_ITENS") 

If (XmlChildCount(oXmlIte) <> 0)
	If(ValType(oXmlITE:_ITEM) != "A")
		XmlNode2Arr(oXmlITE:_ITEM, "_ITEM")
	EndIf

	For nXi:= 1 To Len(oXmlIte:_ITEM)
		For nXy := 1 to XmlChildCount(oXmlITE:_ITEM[nXi])
			cXmlName:= Upper(XmlGetChild(oXmlITE:_ITEM[nXi], nXy):REALNAME)
			cXmlText:= XmlGetChild(oXmlITE:_ITEM[nXi], nXy):TEXT
			If cXmlName <> "OBS" .And. Empty(cXmlText)
				cMensLog += "Não Informado TAG " + cXmlName + " do item " + cValToChar(nXi) + CRLF
			EndIf
		Next nXi
	Next nXi
EndIf

lRet:= Empty(cMensLog)

Return(lRet)
