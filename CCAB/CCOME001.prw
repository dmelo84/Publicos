#include "protheus.ch"
#Include 'TbiConn.ch'

/*/{Protheus.doc} CCOME001
	Função principal
@author felipe ortega
@since 15/04/2020
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
user function CCOME001()

	local cAlias
	local lSkip 	:= .F.
//	local cQuery 	:= ""
	
	Conout(DToC(dDataBase) + " - " + Time() + " - APROVAÇÃO PC FLUIG - INICIO DO PROCESSO ")
	
	if paramixb[3] == 1
	
		Conout(DToC(dDataBase) + " - " + Time() + " - APROVAÇÃO PC FLUIG - PARAMIXB[3] IGUAL A 1")
		
		if INCLUI .Or. ALTERA .or. LCOP

			if ALTERA

				U_CB00104()

			endif
		
			Conout(DToC(dDataBase) + " - " + Time() + " - APROVAÇÃO PC FLUIG - REALIZANDO QUERY PARA PROCESSAMENTO ")
		
			cAlias := getNextAlias()
			
			U_CB00102(@cAlias)
			
			if (cAlias)->(!eof())
				
				Conout(DToC(dDataBase) + " - " + Time() + " - APROVAÇÃO PC FLUIG - RETORNOU RESULTADOS DA QUERY ")
			
				while (cAlias)->(!eof())
				
					if empty((cAlias)->CR_XSTATFL)
					
						Conout(DToC(dDataBase) + " - " + Time() + " - APROVAÇÃO PC FLUIG - REALIZANDO CHAMADA DA FUNÇÃO DE PROCESSAMENTO DE DADOS E START ")
		
						U_CB00101(@cAlias, SCR->CR_NUM, @lSkip)
						
					endif
					
					if !lSkip
				
						(cAlias)->(dbskip())
						
					endif
				
				enddo
				
			else
			
				msgInfo("Não foi encontrada nenhuma aprovação")
			
			endif
			
			(cAlias)->(dbCloseArea())

		elseif PARAMIXB[1] == 5
			
			U_CB00104()
		
		endif

	endif

return

user function CB00104()

	local cQuery := ""
	local cAlias

	cQuery += "SELECT ZFG_NUMFLG NUMFLG " + CRLF
	cQuery += "FROM " + retSqlName("ZFG") + " " + CRLF
	cQuery += "WHERE " + CRLF
	cQuery += "ZFG_CHVPRT = '" + xFilial("SC7") + "IP" + cex120num + "'" + CRLF
	
	cAlias := getNextAlias()
	
	dbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAlias,.F., .F.)

	if (cAlias)->(!eof())
		if !empty((cAlias)->NUMFLG)
	
			U_CCOME002(alltrim((cAlias)->NUMFLG), "Titulo excluido")
		
		endif
	endif
return

/*/{Protheus.doc} CB00101
	Função que realiza o start para o fluig
@author felipe ortega
@since 15/04/2020
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
user function CB00101(cAlias, cCrNum, lSkip)

	local oFlg
	local aCardData		:= {}
	local nI			:= 0
	local aDataEmiss
	local cDataEmiss
	local cArea			:= getArea()
	local cAliasIt
	local aRecno		:= {}
	local cItem			:= ""
	local nTotal		:= 0
//	Local nTotalConv    := 0 //DMS
	Local nMoeda        := 0  //DMS
	local cAprovadores	:= ""
	local cRecnos		:= ""
	local cCentro		:= alltrim((cAlias)->C7_CC)
	local cfilPed		:= (cAlias)->CR_FILIAL
	local nTax			:= 0
	Local nTotal_ := 0
	
	lSkip := .F.

	Conout(DToC(dDataBase) + " - " + Time() + " - APROVAÇÃO PC FLUIG - INSTANCIANDO OBJETO CINTFLG ")
	
	oFlg			:= CINTFLG():New(.T.)
	
	oFlg:setUserId(,.F.)

	aDataEmiss := strTokArr(dtoc(dDatabase), "/")
	
	cDataEmiss := cvaltochar(year(dDatabase)) + "-" + aDataEmiss[2] + "-" +  aDataEmiss[1]

	aAdd(aCardData,{"Solicitante"		, ALLTRIM(UsrRetName(RetCodUsr())) })
	aAdd(aCardData,{"dataSolicitacao"	, cDataEmiss })
	aAdd(aCardData,{"dtFiltroEmissao"	, DtoS(dDatabase) })
	
	aAdd(aCardData,{"codFilial"			, alltrim((cAlias)->CR_FILIAL) })
	aAdd(aCardData,{"dbmitgrp"			, alltrim((cAlias)->DBM_ITGRP) })
	//Retorna Moeda para conversão posterior DMS - Diogo Melo
	nMoeda := (cAlias)->MOEDA
	/**/
	aAdd(aCardData,{"moeda"				, cValTochar(nMoeda) })
	
	dbSelectArea("SC7")
	
	SC7->(dbSetOrder(1))
	
	SC7->(msSeek(xFilial("SC7") + alltrim(cCrNum) + "0001"))
	
	aAdd(aCardData,{"tituloForm"		, If(SC7->C7_XCONTRA=="S","Inclusão de Contrato", "Pedido de Compras") })
	aAdd(aCardData,{"observacao"		, alltrim(SC7->C7_XOBSPED) })
	
	aAdd(aCardData,{"filial"			, alltrim(FWFilialName()) })
	
	aAdd(aCardData,{"numeroEIC"			, alltrim(SC7->C7_PO_EIC) })

	aAdd(aCardData,{"C7_VALFRE"			, cValtoChar(SC7->C7_VALFRE) }) //dms

	aAdd(aCardData,{"C7_SEGURO"			, cValtochar(SC7->C7_SEGURO) }) //dms

	aAdd(aCardData,{"C7_DESPESA"		, cValtoChar(SC7->C7_DESPESA)}) //dms
	
	dbSelectArea("SA2")
	
	SA2->(dbSetOrder(1))
	
	Conout(DToC(dDataBase) + " - " + Time() + " - APROVAÇÃO PC FLUIG - REALIZANDO BUSCA DO FORNECEDOR ")
	
	if !(SA2->(msSeek(xFilial("SA2") + ca120forn + ca120loj)))
	
		msgInfo("Fornecedor não encontrado")
		
		return
		
	endif
	
	aAdd(aCardData,{"numPedido"			, cCrNum })
	aAdd(aCardData,{"consultaPedido"	, cCrNum })
	aAdd(aCardData,{"fornecedor"		, "<![CDATA[" + alltrim(NoChar(SA2->A2_NOME, .t.)) + "]]>" })
	aAdd(aCardData,{"codFornecedor"		, ca120forn })
	aAdd(aCardData,{"loja"				, ca120loj })
	
	dbSelectArea("CTT")
	CTT->(dbSetOrder(1))
	
	Conout(DToC(dDataBase) + " - " + Time() + " - APROVAÇÃO PC FLUIG - REALIZANDO BUSCA DO CENTRO DE CUSTO ")
	
	if !(CTT->(msSeek(xFilial("CTT") + alltrim((cAlias)->C7_CC))))
	
		msgInfo("Centro de custo não encontrado")
		
		return
	
	endif
	
	aAdd(aCardData,{"codCC"				, cCentro })
	aAdd(aCardData,{"centrocusto"		, alltrim(CTT->CTT_DESC01) })
	
	dbSelectArea("SAK")
	
	SAK->(dbSetOrder(1))
	
	Conout(DToC(dDataBase) + " - " + Time() + " - APROVAÇÃO PC FLUIG - BUSCANDO APROVADORES ")
	
	while (cAlias)->(!eof()) .and. alltrim((cAlias)->C7_CC) == cCentro
	
		if !(SAK->(msSeek(xFilial("SAK") + (cAlias)->CR_APROV)))
		
			msgInfo("Aprovador não encontrado")
			
			return
		
		endif
		
		if !Empty(cAprovadores)
		
			cAprovadores += ","
			cRecnos		+= ","
		
		endif
		
		cAprovadores += alltrim(SAK->AK_XCPF)
		cRecnos		+= cValTochar((cAlias)->RECNO)
		
		(cAlias)->(dbSkip())
		
		lSkip := .T.
		
	enddo
	
	Conout(DToC(dDataBase) + " - " + Time() + " - APROVAÇÃO PC FLUIG - APROVADORES - " + cAprovadores)
	
	aAdd(aCardData,{"matAprovador"		, alltrim(cAprovadores) })
	
	aAdd(aCardData,{"recno"				, cRecnos })
	
	cAliasIt := getNextAlias()
	
	Conout(DToC(dDataBase) + " - " + Time() + " - APROVAÇÃO PC FLUIG - BUSCANDO ITENS ")
	
	CB00103(@cAliasIt, cCentro)
	
	dbSelectArea("SM2")
	
	SM2->(dbSetOrder(1))
	
	if (cAliasIt)->(!eof())
	
		Conout(DToC(dDataBase) + " - " + Time() + " - APROVAÇÃO PC FLUIG - ITENS ENCONTRADOS ")
	
		while (cAliasIt)->(!eof())

			if (cAliasIt)->C7_ITEM == cItem
			
				aAdd(aRecno, (cAliasIt)->RECNO)
				
				(cAliasIt)->(dbSkip())
				
				loop
			endif
			
			nI++
			
			if (cAliasIt)->MOEDA != 1
			
				if ((cAliasIt)->C7_TXMOEDA == 0)
					SM2->(msSeek(dDatabase))
					nTax := SM2->&("M2_MOEDA"+cValToChar((cAliasIt)->MOEDA))
				else
					nTax := (cAliasIt)->C7_TXMOEDA
				endif
				
				aAdd(aCardData,{"seqItem___" + cValToChar(nI)			, strZero(val((cAliasIt)->C7_ITEM), 4)})
				aAdd(aCardData,{"codProduto___" + cValToChar(nI)		, (cAliasIt)->C7_PRODUTO })
				aAdd(aCardData,{"descricao___" + cValToChar(nI)			, "<![CDATA[" + (cAliasIt)->B1_DESC + "]]>" })
				aAdd(aCardData,{"quantideItem___" + cValToChar(nI)		, AllTrim(Transform((cAliasIt)->C7_QUANT, "@E 999,999,999.99")) })
				aAdd(aCardData,{"valorUnit___" + cValToChar(nI)			, AllTrim(Transform(Round((cAliasIt)->C7_PRECO*nTax,2), "@E 999,999,999.99")) })
				aAdd(aCardData,{"ipi___" + cValToChar(nI)				, AllTrim(Transform((cAliasIt)->C7_IPI, "@E 999,999,999.99")) })
				aAdd(aCardData,{"valorTotalItem___" + cValToChar(nI)	, AllTrim(Transform(Round((cAliasIt)->(C7_QUANT*C7_PRECO*nTax),2), "@E 999,999,999.99")) })
				aAdd(aCardData,{"observacao___" + cValToChar(nI)		, "<![CDATA[" + AllTrim((cAliasIt)->C7_OBS) + "]]>" })
				aAdd(aCardData,{"ContaContabil___" + cValToChar(nI)		, AllTrim((cAliasIt)->C7_CONTA) })
				
				nTotal += Round((cAliasIt)->(C7_QUANT*C7_PRECO*nTax),2)
				nTotal_ += Round((cAliasIt)->(C7_QUANT*C7_PRECO),2)
			else
				aAdd(aCardData,{"seqItem___" + cValToChar(nI)			, strZero(val((cAliasIt)->C7_ITEM), 4)})
				aAdd(aCardData,{"codProduto___" + cValToChar(nI)		, (cAliasIt)->C7_PRODUTO })
				aAdd(aCardData,{"descricao___" + cValToChar(nI)			, "<![CDATA[" + (cAliasIt)->B1_DESC + "]]>" })
				aAdd(aCardData,{"quantideItem___" + cValToChar(nI)		, AllTrim(Transform((cAliasIt)->C7_QUANT, "@E 999,999,999.99")) })
				aAdd(aCardData,{"valorUnit___" + cValToChar(nI)			, AllTrim(Transform((cAliasIt)->C7_PRECO, "@E 999,999,999.99")) })
				aAdd(aCardData,{"ipi___" + cValToChar(nI)				, AllTrim(Transform((cAliasIt)->C7_IPI, "@E 999,999,999.99")) })
				aAdd(aCardData,{"valorTotalItem___" + cValToChar(nI)	, AllTrim(Transform(Round((cAliasIt)->(C7_QUANT*C7_PRECO),2), "@E 999,999,999.99")) })
				aAdd(aCardData,{"observacao___" + cValToChar(nI)		, "<![CDATA[" + AllTrim((cAliasIt)->C7_OBS) + "]]>" })
				aAdd(aCardData,{"ContaContabil___" + cValToChar(nI)		, AllTrim((cAliasIt)->C7_CONTA) })
				
				nTotal += Round((cAliasIt)->(C7_QUANT*C7_PRECO),2)
			endif

			aAdd(aRecno, (cAliasIt)->RECNO)
			
			cItem := (cAliasIt)->C7_ITEM
			
			(cAliasIt)->(dbSkip())
		
		enddo
	
	endif
	
	aAdd(aCardData,{"total"	, AllTrim(Transform(nTotal, "@E 999,999,999.99")) })
	/*
	nVMoeda := xMoeda(nVMo, nMo, nMd, , dData, nDec)

	Parâmetros:
	nVMoeda = Retorno. Valor na moeda de destino.
	nVMo = Valor na moeda origem.
	nMo = Número da moeda origem.
	nMd = Número da moeda destino.
	dData = Data para conversão.
	nDec = Número de decimais. Se não informado, assume-se 2 casas decimais.
	*//*Calculo de conversão para moeda estrangeira.*/
	
	//if nMoeda == 2
		//nTotalConv := xMoeda(nTotal, /*nMo*/2, /*nMd*/1,dDatabase, /*nDec*/2) //Conversão de Moeda.
	//EndIF 

	aAdd(aCardData,{"vlrTotalEst"		, AllTrim(Transform(nTotal_, "@E 999,999,999.99")) })
	/*FIM*/
	Conout(DToC(dDataBase) + " - " + Time() + " - APROVAÇÃO PC FLUIG - REALIZANDO STARTPROCESS ")

	IF oFlg:startprocess("AprovPC",;	// ProcessId
		"0",;						// NextTask
		{oFlg:UserId},;
		"Inicio da aprovação: ",;
		oFlg:UserId,;
		.T.,;
		{},;
		aCardData)
		
		Conout(DToC(dDataBase) + " - " + Time() + " - APROVAÇÃO PC FLUIG - PROCESSO INICIADO COM SUCESSO - " + oFlg:idSol)
		
		dbSelectArea("SCR")
		dbSelectArea("DBM")
		
		SCR->(dbOrderNickName("FLG"))
		
		for nI := 1 to len(aRecno)
		
			DBM->(dbGoto(aRecno[nI]))
		
			if SCR->(msSeek(alltrim(cfilPed) + "IP" + padr(alltrim(cCrNum), tamsx3("CR_NUM")[1]) + padr(alltrim(DBM->DBM_USER), tamsx3("CR_APROV")[1]) + DBM->DBM_GRUPO))
				
				reclock("SCR", .f.)
				
				SCR->CR_XNUMFLG := oFlg:idSol
				SCR->CR_XSTATFL := '2'
				SCR->(msUnLock())
				
			endif
		
		next
		
		dbselectArea("ZFG")

		ZFG->(dbsetorder(2))

		if ZFG->(msseek(cfilPed + "IP" + padr(alltrim(cCrNum), tamsx3("CR_NUM")[1]) + (cAlias)->CR_GRUPO))
			if ZFG->ZFG_ACAO == '3' .and. ZFG->ZFG_STATUS $ "1|3"
				reclock("ZFG", .F.)

				ZFG->(dbdelete())

				ZFG->(msunlock())
			endif
		endif
		
		reclock("ZFG", .T.)
		
		ZFG->ZFG_FILIAL := xfilial("ZFG")
		ZFG->ZFG_CHVPRT := cfilPed + "IP" + padr(alltrim(cCrNum), tamsx3("CR_NUM")[1]) + (cAlias)->CR_GRUPO
		ZFG->ZFG_NUMFLG := oFlg:idSol
		ZFG->ZFG_STATUS := '2'
		ZFG->ZFG_ORIGEM := "PC"
		ZFG->ZFG_ACAO   := '3'
		ZFG->ZFG_ENVIO  := oFlg:xml
		ZFG->ZFG_MSG    := "Processamento realizado com sucesso"
		
		ZFG->(msunlock())
		
	else
	
		Conout(DToC(dDataBase) + " - " + Time() + " - APROVAÇÃO PC FLUIG - FALHA AO INICIAR PROCESSO - " + oFlg:Error)
		
		CENVMAIL(alltrim(cCrNum), alltrim(oFlg:Error))
		
		dbselectArea("ZFG")

		ZFG->(dbsetorder(2))

		if ZFG->(msseek(cfilPed + "IP" + padr(alltrim(cCrNum), tamsx3("CR_NUM")[1]) + (cAlias)->CR_GRUPO))
			if ZFG->ZFG_ACAO == '3'
				reclock("ZFG", .F.)

				ZFG->(dbdelete())

				ZFG->(msunlock())
			endif
		endif
		
		reclock("ZFG", .T.)
		
		ZFG->ZFG_FILIAL := xfilial("ZFG")
		ZFG->ZFG_CHVPRT := cfilPed + "IP" + padr(alltrim(cCrNum), tamsx3("CR_NUM")[1]) + (cAlias)->CR_GRUPO
		ZFG->ZFG_NUMFLG := oFlg:idSol
		ZFG->ZFG_STATUS := '3'
		ZFG->ZFG_ORIGEM := "PC"
		ZFG->ZFG_ACAO   := '3'
		ZFG->ZFG_ENVIO  := oFlg:xml
		ZFG->ZFG_MSG    := oFlg:Error
		
		ZFG->(msunlock())
		
	endif
	
	(cAliasIt)->(dbCloseArea())
	
	restArea(cArea)
	
return

/*/{Protheus.doc} CB00102
	Busca dados aprovação por aprovador
@author felipe ortega
@since 15/04/2020
@version 1.0
@return ${return}, ${return_description}

@type function
/*/
user function CB00102(cAlias)

	local cQuery 	:= ""

	cQuery += "SELECT C7.C7_CC, CR.CR_APROV, CR.CR_TOTAL, CR.R_E_C_N_O_ RECNO, CR.CR_FILIAL, BM.DBM_ITGRP, CR.CR_XSTATFL, C7.C7_MOEDA MOEDA, CR.CR_GRUPO " + CRLF
	cQuery += "FROM " + retSqlname("SCR") + " CR" + CRLF
	cQuery += "INNER JOIN " + retSqlname("DBM") + " BM ON CR.CR_FILIAL = BM.DBM_FILIAL AND CR.CR_NUM = BM.DBM_NUM AND CR.CR_USER = BM.DBM_USER" + CRLF
	cQuery += "INNER JOIN " + retSqlname("SC7") + " C7 ON C7.C7_FILIAL = BM.DBM_FILIAL AND C7.C7_NUM = BM.DBM_NUM AND C7.C7_ITEM = BM.DBM_ITEM" + CRLF
	cQuery += "WHERE C7.C7_FILIAL = '" + xFilial("SC7") + "' AND CR.CR_NUM = '" + SCR->CR_NUM + "'" + CRLF
	cQuery += "AND CR.CR_NIVEL = (SELECT MIN(CR2.CR_NIVEL) NIVEL FROM " + retSqlname("SCR") + " CR2 WHERE CR2.CR_FILIAL = CR.CR_FILIAL AND CR2.CR_NUM = CR.CR_NUM AND CR2.CR_GRUPO = CR.CR_GRUPO AND CR2.D_E_L_E_T_ = ' ')" + CRLF
	cQuery += "AND CR.CR_XSTATFL = ' ' " + CRLF
	cQuery += "AND CR.D_E_L_E_T_ = ' '" + CRLF
	cQuery += "AND BM.D_E_L_E_T_ = ' '" + CRLF
	cQuery += "AND C7.D_E_L_E_T_ = ' '" + CRLF
	cQuery += "GROUP BY C7.C7_CC, CR.CR_APROV, CR.CR_TOTAL, CR.R_E_C_N_O_ , CR.CR_FILIAL, BM.DBM_ITGRP, CR.CR_XSTATFL, C7.C7_MOEDA, CR.CR_GRUPO " + CRLF

	dbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAlias,.F., .F.)

return

/*/{Protheus.doc} CB00103
	Busca dados aprovação por item
@author felipe ortega
@since 15/04/2020
@version 1.0
@return ${return}, ${return_description}
@param cAlias, characters, descricao
@type function
/*/
static function CB00103(cAliasIt, cCc)

	local cQuery 	:= ""

	cQuery += "SELECT C7.C7_ITEM, C7.C7_PRODUTO, B1.B1_DESC, BM.DBM_VALOR, C7.C7_QUANT, C7.C7_PRECO, C7.C7_IPI, BM.R_E_C_N_O_ RECNO, C7.C7_MOEDA MOEDA, C7.C7_OBS, C7_CONTA, C7_TXMOEDA" + CRLF
	cQuery += "FROM " + retSqlname("SC7") + " C7" + CRLF
	cQuery += "INNER JOIN " + retSqlname("SB1") + " B1 ON B1.B1_COD = C7.C7_PRODUTO " + CRLF
	cQuery += "INNER JOIN " + retSqlname("DBM") + " BM ON C7.C7_FILIAL = BM.DBM_FILIAL AND C7.C7_NUM = BM.DBM_NUM AND C7.C7_ITEM = BM.DBM_ITEM" + CRLF
	cQuery += "WHERE C7.C7_FILIAL = '" + xFilial("SC7") + "' AND C7.C7_NUM = '" + SCR->CR_NUM + "'" + CRLF
	cQuery += "AND C7.C7_CC = '" + cCc + "'" + CRLF
	cQuery += "AND C7.D_E_L_E_T_ = ' '" + CRLF
	cQuery += "AND BM.D_E_L_E_T_ = ' '" + CRLF
	cQuery += "ORDER BY C7.C7_ITEM"

	dbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQuery),cAliasIt,.F., .F.)

return

Static Function CENVMAIL(cNumero, cErro)

	local cDestino 	:= SuperGetMv('MV_XMAITST',,'humberto.quesada@hqsolucoes.com;way2solutions@ccab-agro.com.br')
	local oEmail 	:= EmailNotif():New(cDestino, "Erro no Start de pedido de compras", FBODY(cNumero, cErro))
	local lRet	 	:= .T.
	
	lRet := oEmail:Enviar()

return lRet

Static Function FBODY(cNumero, cErro)
	Local cBody     := ""
	Local cAbertura := ""
	Local cHora     := SubStr(time(), 1, 2)
	
	If Val(cHora) < 12
		cAbertura := "bom dia"
	elseIf Val(cHora) < 18
		cAbertura := "boa tarde"
	else
		cAbertura := "boa noite"
	EndIf
	
	cBody += "            <html>"
	cBody += "" + CRLF + "	<head>"	
	cBody += "" + CRLF + "	</head>"
	cBody += "" + CRLF + "	<body>"
	cBody += "" + CRLF + "	    " + cAbertura + "!"
	cBody += "" + CRLF + "		<br>"
	cBody += "" + CRLF + "		Houve uma falha ao startar a aprovação do Pedido de compras numero " + cNumero + " <br><br>"
	cBody += "" + CRLF + "		Erro: " + cErro 
	cBody += "" + CRLF + "	</body>"
	cBody += "" + CRLF + "</html>"
	
Return cBody

STATIC FUNCTION NoChar(cString,lConverte)

	Default lConverte := .F.

	If lConverte
		cString := (StrTran(cString,"&lt;","<"))
		cString := (StrTran(cString,"&gt;",">"))
		cString := (StrTran(cString,"&amp;","&"))
		cString := (StrTran(cString,"&quot;",'"'))
		cString := (StrTran(cString,"&#39;","'"))
	EndIf

Return(cString)







