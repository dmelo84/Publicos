#Include "PROTHEUS.CH"

//Ponto de entrada Exclus�o do Movimento Banc�rio
User Function FA100CAN()
	Local ExpL1 := .T.// Confirma a exclus�o do Movimento Banc�rio
    
    if !Empty(SE5->E5_XIDFLG)     
    	MsgRun("Executando integra��o!", "Integra��o!",{||ECFLG(SE5->E5_XIDFLG)})
	endif

Return ExpL1

//Fun��o para Executar o cancelamento do Movimento Banc�rio no Fluig consumindo webservice
Static Function ECFLG(cIdFlg)
	Local FlgWS := WSECMWorkflowEngineServiceService():new()
	
	FlgWs:_URL := SuperGetMV("MV_ECMURL") + "ECMWorkflowEngineService"
	
	if FlgWS:cancelInstance(SuperGetMv("MV_ECMUSER"    ,NIL ,"integrador"),;
	                        SuperGetMv("MV_ECMPSW"     ,NIL ,"integrador"),;
	                        VAL(SuperGetMv("MV_ECMEMP" ,NIL ,1)),;
	                        VAL(cIdFlg),;
	                        SuperGetMv("MV_ECMMAT"),;
	                        "Processo cancelado atrav�s da integra��o com o Protheus") 
		//Se processamento ocorrer sem erros exibe o valor de retorno
		MsgInfo("Cancelamento de Movimento Banc�rio no Fluig realizado com sucesso!") 
	else
		MsgStop("Erro na integra��o com o Fluig: " + GetWSCError(3))
	endIf
   
Return