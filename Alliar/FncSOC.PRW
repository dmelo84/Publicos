#include "PROTHEUS.CH"

User Function FncSOCVl(aSolicitacaoCompra, cMsg)
	Local nRetorno := 1
	Local nCount
	
	If !NaoVazio(aSolicitacaoCompra:C1_EMISSAO)
		cMsg := "Valor do campo C1_EMISSAO deve ser informado."
		nRetorno := 3 //Erro
		Return nRetorno
	EndIf
	
	For nCount := 1 to Len(aSolicitacaoCompra:ITEM)
		if !Naovazio(aSolicitacaoCompra:ITEM[nCount]:C1_PRODUTO)
			cMsg := "Valor do campo C1_PRODUTO deve ser informado."
			nRetorno := 3 //Erro
			Return nRetorno
		endif 
		
		if !U_RegExiste("SB1",xFilial("SB1", aSolicitacaoCompra:C1_FILENT) + aSolicitacaoCompra:ITEM[nCount]:C1_PRODUTO, 1)
			cMsg := "Valor do campo C1_PRODUTO deve ser válido."
			nRetorno := 3 //Erro
			Return nRetorno
		endif
		
		if !Naovazio(aSolicitacaoCompra:ITEM[nCount]:C1_UM) 
			cMsg := "Valor do campo C1_UM deve ser informado."
			nRetorno := 3 //Erro
			Return nRetorno
		endif
		
		if !U_RegExiste("SAH",xFilial("SAH", aSolicitacaoCompra:C1_FILENT) + aSolicitacaoCompra:ITEM[nCount]:C1_UM, 1)
			cMsg := "Valor do campo C1_UM deve ser válido."
			nRetorno := 3 //Erro
			Return nRetorno
		endif
		
		if !NaoVazio(aSolicitacaoCompra:ITEM[nCount]:C1_QUANT) .OR.;
		   !aSolicitacaoCompra:ITEM[nCount]:C1_QUANT > -1
			cMsg := "Valor do campo C1_QUANT deve ser informado."
			nRetorno := 3 //Erro
			Return nRetorno
		endif
		
		if !U_RegExiste("NNR",xFilial("NNR",aSolicitacaoCompra:C1_FILENT) + aSolicitacaoCompra:ITEM[nCount]:C1_LOCAL, 1) 
			cMsg     := "Valor do campo C1_LOCAL deve ser válido."
			nRetorno := 3 //Erro
			Return nRetorno
		endif
		
		if !NaoVazio(aSolicitacaoCompra:ITEM[nCount]:C1_DATPRF)
			cMsg     := "Valor do campo C1_DATPRF deve ser informado."
			nRetorno := 3 //Erro
			Return nRetorno
		endif
		
	Next nCount

Return (nRetorno)

User Function FncSOCSq(aSolicitacaoCompra)
	Local cSeq := "" 

	cAliasQry := GetNextAlias()
	cQuery := " SELECT MAX(CAST(SC1.C1_NUM AS INTEGER)) + 1 INCREMENTO "
	cQuery += "  FROM " + RetSqlName("SC1")+" SC1 "
	cQuery += " WHERE SC1.C1_FILIAL = '" + aSolicitacaoCompra:C1_FILIAL + "'"
	cQuery += "   AND SC1.D_E_L_E_T_ <> '*' "

	cQuery := ChangeQuery(cQuery)
	dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),cAliasQry, .F., .T.)  

	dbSelectArea(cAliasQry)
	dbGoTop()
	
	If !Eof()
		//Sequencial
		if Empty((cAliasQry)->INCREMENTO)
			cSeq := PADL("1", 06, "0")
		else
			//Incrementa Sequencial
			cSeq := PADL(cVALTOCHAR((cAliasQry)->INCREMENTO), 06, "0")
		endif 
	else
		cSeq := PADL("1", 06, "0")   
	endif
	
	(cAliasQry)->(dbCloseArea())
Return (cSeq) 

User Function M110STTS() 
	Local lCopia  := IsInCallStack("A110Copia")
	
	IF (!INCLUI .AND. !ALTERA .AND. !lCopia) .AND. !Empty(SC1->C1_XIDFLG)     
		MsgRun("Executando integração!", "Integração!",{||ECFLG(SC1->C1_XIDFLG)})
	endif
Return 

//Função para Executar a exclusão da Solicitação de compra no Fluig consumindo webservice
Static Function ECFLG(cIdFlg)
	Local FlgWS := WSECMWorkflowEngineServiceService():new()
	
	FlgWs:_URL := SuperGetMV("MV_ECMURL") + "ECMWorkflowEngineService"
	
	if FlgWS:cancelInstance(SuperGetMv("MV_ECMUSER"    ,NIL ,"integrador"),;
	                        SuperGetMv("MV_ECMPSW"     ,NIL ,"integrador"),;
	                        VAL(SuperGetMv("MV_ECMEMP" ,NIL ,1)),;
	                        VAL(cIdFlg),;
	                        SuperGetMv("MV_ECMMAT"),;
	                        "Processo cancelado através da integração com o Protheus") 
		//Se processamento ocorrer sem erros exibe o valor de retorno
		MsgInfo("Cancelamento de Solicitação de Compra no Fluig realizado com sucesso!") 
	else
		MsgStop("Erro na integração com o Fluig: " + GetWSCError(3))
	endIf
   
Return