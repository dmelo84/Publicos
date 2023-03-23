function beforeCancelProcess(colleagueId,processId){




    var cardData = hAPI.getCardData(processId);

    var keys = cardData.keySet().toArray();
    
    for (var key in keys) {
    	
    	var field = keys[key]
    	
    	if (field.indexOf("companyid___") > -1) {
    		
    
   		 
              var index = field.replace("companyid___", "");
              
              var cotacao = cardData.get("numero_cotacao___" + index) || "";
              var pedido = cardData.get("numero_pedido___" + index) || "";

        if (cotacao != "" && getValue("WKUser") != 'fluigadmin'){

                throw "\n\n A solicitação não pode ser cancelada porque um ou mais itens já estão participando de cotação. \n\n"

              }

        if (pedido != "" && getValue("WKUser") != 'fluigadmin'){

                throw "\n\n A solicitação não pode ser cancelada porque um ou mais itens estão relacionados a um pedido. \n\n"

              }
  
		
    	
    	 }
	
	
	}

}