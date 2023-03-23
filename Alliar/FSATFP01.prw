#Include "Protheus.ch"

/*/{Protheus.doc} FSATFP01
Rotina para tratamento de consulta do metodo ConsultaBem do WS WSAtivoFixo

@type function
@author claudiol
@since 09/12/2015
@version 1.0
@param cGrupo, character, (Descrição do parâmetro)
@param cPlaqueta, character, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
@obs
17/05/2016 Claudio Silva    Inclusao campo N1_BAIXA no layout de retorno
/*/
User Function FSATFP01(cGrupo, cPlaqueta)

Local aRet		:= {"","",""}
Local aRetCon	:= FRetFil(cGrupo) //Usado apenas para logar na primeira empresa
Local cEmpCon	:= aRetCon[1] 
Local cFilCon	:= aRetCon[2]

If !Empty(cEmpCon) .And. !Empty(cFilCon)
	If RpcSetEnv(cEmpCon, cFilCon)
	
		aRet:= FBusDad(cGrupo,cPlaqueta)
	
		RpcClearEnv()
	Else
		aRet:= {"0","ERRO:EMPRESA INVÁLIDA!",""}
	EndIf
Else
	If Select("SM0")>0
		aRet:= FBusDad(cGrupo,cPlaqueta)
	Else
		aRet:= {"0","ERRO:EMPRESA INVÁLIDA!",""}
	EndIf
EndIf

Return(aRet)


/*/{Protheus.doc} FBusDad
Busca dados na tabela de bem

@type function
@author claudiol
@since 09/12/2015
@version 1.0
@param cPlaqueta, character, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function FBusDad(cGrupo,cPlaqueta)

Local cAliTMP	:= GetNextAlias()
Local cStatus	:= ""
Local cMensage:= ""
Local cXML		:= ""
Local cA2Nome	:= ""
Local nCont	:= 0
Local cWhere	:= "%LEFT(SN1.N1_FILIAL,"+cValToChar(Len(cGrupo))+") = '"+cGrupo+"'%"

//Pesquisa na tabela SN1
BeginSql Alias cAliTMP
	column N1_AQUISIC as Date    
	column N1_BAIXA as Date    

	SELECT N1_FILIAL, N1_NFISCAL, N1_DESCRIC, N1_XTPOCS,	N1_FORNEC, N1_LOJA, 
	       N1_VLAQUIS, N1_AQUISIC, N1_BAIXA
	FROM %table:SN1% SN1
	WHERE SN1.%notDel%
		AND %exp:cWhere%
		AND SN1.N1_CHAPA = %exp:cPlaqueta%
EndSql

(cAliTmp)->(dbGotop())
While (cAliTmp)->(!Eof())
	nCont++
	
	//Seta a filial do registro corrente
	cFilAnt:= (cAliTmp)->N1_FILIAL

	SA2->(dbSetOrder(01)) //A2_FILIAL+A2_COD+A2_LOJA
	SA2->(MsSeek(xFilial("SA2")+(cAliTmp)->(N1_FORNEC+N1_LOJA)))
	If SA2->(!Eof())
		cA2Nome:= SA2->A2_NOME
	EndIf
	
	cStatus	:= "1" //Ativo
	cMensage	:= "PLAQUETA LOCALIZADA!"

	// Xml de Retorno.
	cXML := '<?xml version="1.0" encoding="utf-8"?>'
	cXML += '<retorno>'
	cXML += '<nota>'+cValToChar(Val((cAliTmp)->N1_NFISCAL))+'</nota>'
	cXML += '<fornecedor>'+Alltrim(cA2Nome)+'</fornecedor>'
	cXML += '<vlraquisicao>'+cValToChar((cAliTmp)->N1_VLAQUIS)+'</vlraquisicao>'
	cXML += '<dataquisicao>'+Dtoc((cAliTmp)->N1_AQUISIC)+'</dataquisicao>'
	cXML += '<descricao>'+Alltrim((cAliTmp)->N1_DESCRIC)+'</descricao>'
	cXML += '<tipobem>'+(cAliTmp)->N1_XTPOCS+'</tipobem>'
	cXML += '<databaixa>'+Dtoc((cAliTmp)->N1_BAIXA)+'</databaixa>'
	cXML += '</retorno>'

	(cAliTmp)->(dbSkip())
EndDo

If nCont==0
	cStatus	:= "0" //Inativo
	cMensage	:= "ERRO:PLAQUETA NÃO LOCALIZADA!"
ElseIf nCont>1
	cStatus	:= "0" //Inativo
	cMensage	:= "ERRO:FOI LOCALIZADO MAIS DE UM BEM COM A PLAQUETA "+ cPlaqueta + "!"
	cXML		:= ""
EndIf

(cAliTMP)->(dbCloseArea())

Return({cStatus,cMensage,cXML})


/*/{Protheus.doc} FRetFil
Retorna uma filial valida para a empresa

@type function
@author claudiol
@since 09/12/2015
@version 1.0
@param cEmpCon, character, (Descrição do parâmetro)
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/
Static Function FRetFil(cGrupo)

Local cEmpRet	:= ""
Local cFilRet	:= ""

If Select("SM0")==0
	If U_FSOpenSm0(.T.)
		SM0->(dbGoTop())
	
		While !SM0->( EOF() )
			If LEFT(SM0->M0_CODFIL,Len(cGrupo))==cGrupo
				cEmpRet:= SM0->M0_CODIGO
				cFilRet:= SM0->M0_CODFIL
				Exit
			EndIf
	
			SM0->( dbSkip() )
		End
	
		SM0->( dbCloseArea() )
	EndIf
EndIf

Return({cEmpRet,cFilRet})
