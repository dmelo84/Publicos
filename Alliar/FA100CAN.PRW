#Include "PROTHEUS.CH"

//Ponto de entrada Exclusão do Movimento Bancário
User Function FA100CAN()
	Local ExpL1 := .T.// Confirma a exclusão do Movimento Bancário
    
    if !Empty(SE5->E5_XIDFLG)     
    	MsgRun("Executando integração!", "Integração!",{||ECFLG(SE5->E5_XIDFLG)})
	endif

Return ExpL1

//Função para Executar o cancelamento do Movimento Bancário no Fluig consumindo webservice
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
		MsgInfo("Cancelamento de Movimento Bancário no Fluig realizado com sucesso!") 
	else
		MsgStop("Erro na integração com o Fluig: " + GetWSCError(3))
	endIf
   
Return