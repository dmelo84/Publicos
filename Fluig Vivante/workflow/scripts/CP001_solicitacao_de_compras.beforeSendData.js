function beforeSendData(customFields,customFacts){
	
	
	try{
		
		customFields[0] = hAPI.getCardValue("tipo_solicitacao");
		customFields[1] = hAPI.getCardValue("workflow_compra");
		customFields[2] = hAPI.getCardValue("aplicacao");
		customFields[3] = hAPI.getCardValue("ckb_investimento");
		customFields[4] = hAPI.getCardValue("unidade_codigo") +" - "+hAPI.getCardValue("unidade_nome");
		
		
		//customFacts[0] = java.lang.Double.parseDouble(hAPI.getCardValue("cotacao_total_cotacao").replace(".","").replace(",","."));
		//customFacts[1] = java.lang.Double.parseDouble(hAPI.getCardValue("cotacao_total_hist").replace(".","").replace(",","."));

		
	}catch(e){
		
	}
}
