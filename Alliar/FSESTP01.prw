#include 'protheus.ch'
#include 'parmtype.ch'
#include 'FWCommand.ch'  

#define _RTPLESTA 1
#define _RTPLEMSG 2

Static aDadSB1	:= {}

/*/{Protheus.doc} FSESTP01
Rotina de envio produto ao Pleres

@author claudiol
@since 24/02/2016
@version undefined

@type function
/*/
user function FSESTP01(cOper,lShowHelp,aHead019,aCols019)

Local cMsg		:= ""
Local lContinua:= .F.
Local nXi		:= 0
Local aProdutos:= {}
Local aEnvFil	:= {}

Default lShowHelp:= .T.
Default aHead019:= {}
Default aCols019:= {}

//No caso de alteracao verifica se foi alterado somente os campos enviados
If !Empty(aDadSB1)
	For nXi := 1 To Len(aDadSB1)
		If &("SB1->"+aDadSB1[nXi][01]) != aDadSB1[nXi][02]
			lContinua := .T.
			Exit
		EndIf
	Next nXi
Else
	lContinua := .T.	
EndIf
aDadSB1:= {}

If lContinua

	Aadd(aProdutos,SB1->B1_COD)

	If cOper<>"X"
		//Busca filiais configuradas para enviar
		aEnvFil:= U_FSPrdSBZ(SB1->B1_COD)
	Else
		aEnvFil:= FPrd019(aHead019,aCols019)
	EndIf

	If !Empty(aEnvFil)
		If lShowHelp
			MsgRun("Enviando dados ao Pleres. Aguarde...","Integrando PLERES", {|| CursorWait(), cMsg:= FPlePrd(cOper,aProdutos,aEnvFil), CursorArrow()})
		Else
			cMsg:= FPlePrd(cOper,aProdutos,aEnvFil)
		EndIf
	EndIf
EndIf

If lShowHelp .And. !Empty(cMsg)
	ApMsgStop(cMsg,".:Atenção:.")
Else
	Conout(cMsg)
EndIf

Return


/*/{Protheus.doc} FPlePrd
Envia dados do produto ao Pleres

@author claudiol
@since 24/02/2016
@version undefined
@param cOper, characters, descricao
@type function
/*/
Static Function FPlePrd(cOper,aProdutos,aEnvFil)

Local aRet		:= {}
Local cXml		:= ""
Local cMsg		:= ""
Local cOperEnv:= ""
Local nXi		:= 0
Local cFilOld	:= cFilAnt

For nXi:= 1 To Len(aEnvFil)
	//Altera a filial corrente
	U_FSMudFil(aEnvFil[nXi,1])

	//Monta XML de envio
	If cOper=="X"
		cOperEnv:= aEnvFil[nXI,2]
	Else
		cOperEnv:= cOper
	EndIf

	cXml:= FXmPrPl(aProdutos,cOperEnv)
	
	//Envia via WS
	lTeste:= .F.
	If !lTeste
		aRet:= U_FSPLEEST("PRD", cXml)
	Else
		ApMsgAlert(cXml)
		aRet:= {"0",""}
	EndIf

	//Trata retorno em caso de erro
	If aRet[_RTPLESTA]== "-1"
		cMsg+= "Erro de Envio Filial: " + aEnvFil[nXi,1] + CRLF
		cMsg+= aRet[_RTPLEMSG] + CRLF
	EndIf
Next nXi

//Restaura a filial corrente
U_FSMudFil(cFilOld)

Return(cMsg)


/*/{Protheus.doc} FPrdSBZ
Busca as filiais que seram enviadas o cadastro de produto

@author claudiol
@since 24/02/2016
@version undefined
@param cCodProd, characters, descricao
@type function
/*/
User Function FSPrdSBZ(cCodProd)

Local cAliTMP	:= GetNextAlias()
Local aRet		:= {}

BeginSql Alias cAliTMP
	SELECT BZ_FILIAL, SBZ.R_E_C_N_O_ SBZRECNO  
	FROM %table:SBZ% SBZ
	WHERE SBZ.%notDel% 
	  AND SBZ.BZ_COD = %exp:cCodProd%
	  AND SBZ.BZ_XINTPLE ='S'
EndSql

(cAliTmp)->(dbGotop())
While (cAliTmp)->(!Eof())
	Aadd(aRet,{(cAliTmp)->BZ_FILIAL,""})
	(cAliTmp)->(dbSkip())
EndDo

(cAliTmp)->(dbCloseArea())

Return(aRet)


/*/{Protheus.doc} FPrd019
Monta empresa alteradas

@type function
@author claudiol
@since 18/03/2016
@version 1.0
@param aHead019, array, (Descrição do parâmetro)
@param aCols019, array, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function FPrd019(aHead019,aCols019)

Local nI		:= 0
Local cFilPes	:= ""
Local cCodPrd	:= AllTrim(M->B1_COD)
Local aRet		:= {}

//Varre todas as linhas do aCols
For nI := 1 To Len(aCols019)
	cFilPes:= GDFieldGet ("BZ_FILIAL" , nI, Nil, aHead019, aCols019 )
		
	//Caso nao esteja deletado
	If !aCols019[nI][Len(aHead019)+1]
		SBZ->(dbSetOrder(1))
		cOper:= Iif(!MsSeek(cFilPes+cCodPrd),"D","U")
	Else //Se for item deletado
		cOper:= "D"
	EndIf

	If GDFieldGet ("BZ_XINTPLE" , nI, Nil, aHead019, aCols019 ) == "S"
		Aadd(aRet,{ cFilPes, cOper})
	EndIf
Next nI

Return(aRet)


/*/{Protheus.doc} FXmPrPl
Gera XML de Produto para integracao Pleres

@author claudiol
@since 24/02/2016
@version undefined
@param aProdutos, array, descricao
@param cOper, characters, descricao
@type function
/*/
Static Function FXmPrPl(aProdutos,cOper)

Local nXi		:= 0
Local nYi		:= 0
Local aTagCab	:= {}
Local aTagXml	:= {}
Local cXml		:= ""
Local aFilAtu 	:= FWArrFilAtu()

//Tab Cabecalho
Aadd(aTagCab,{"Login"				,""	, "{|x| '" + Supergetmv("ES_PLELOG",.F.,"") + "' }" })
Aadd(aTagCab,{"Senha"				,""	, "{|x| '" + Supergetmv("ES_PLEPSW",.F.,"") + "' }" })
Aadd(aTagCab,{"CNPJFilial"			,""	, "{|x| '" + aFilAtu[SM0_CGC] + "' }" })
Aadd(aTagCab,{"NomeFilial"			,""	, "{|x| '" + aFilAtu[SM0_NOMECOM] + "' }" })
Aadd(aTagCab,{"Operacao"			,""	, "{|x| '" + cOper + "' }" })

//Tag do XML
Aadd(aTagXml,{"CodProduto"			,"B1_COD"		, "" })
Aadd(aTagXml,{"DesProduto"			,"B1_DESC"		, "" })
Aadd(aTagXml,{"UnMedida"			,"B1_UM"			, "" })
Aadd(aTagXml,{"Bloqueio"			,"B1_MSBLQL"	, "" })
Aadd(aTagXml,{"Lote"				,"B1_RASTRO"	, "" })

//Inicio
cXml+= MontaXML("Produto",,,,,,,.T.,.F.,.T.)

For nXi:= 1 To Len(aTagCab)
	cXml+= U_FSCnvXML(aTagCab[nXi],2)
Next nXi

For nXi:= 1 To Len(aProdutos)

	//Posiciona tabelas
	SB1->(dbSetOrder(1)) //B1_FILIAL+B1_COD
	SB1->(MsSeek(xFilial("SB1")+aProdutos[nXi]))

	cXml+= MontaXML("Dados",,,,,,2,.T.,.F.,.T.)
	
	For nYi:= 1 To Len(aTagXml)
		cXml+= U_FSCnvXML(aTagXml[nYi],4)
	Next nYi
	
	cXml+= MontaXML("Dados",,,,,,2,.F.,.T.,.T.)
Next nXi

//Fim
cXml+= MontaXML("Produto",,,,,,,.F.,.T.)

Return(cXml)


/*/{Protheus.doc} FSSetSB1
Guarda em variavel statica conteudo inicial para verificar se foi alterado
@author claudiol
@since 04/03/2016
@version undefined

@type function
/*/
User Function FSSetSB1()

Local	nXi		:= 0
Local	cCampos	:= "B1_COD/B1_DESC/B1_UM/B1_MSBLQL/"

//Guardo registro corrente 
aDadSB1 := {}
For nXi := 1 To SB1->(FCount())
	If Alltrim(SB1->(Field(nXi))) $ cCampos
		AAdd(aDadSB1, {SB1->(Field(nXi)), SB1->(FieldGet(nXi))})
	EndIf
Next

Return Nil
