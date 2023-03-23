function afterCancelProcess(colleagueId,processId){



    var cardData = hAPI.getCardData(processId);

    log.info("##** CardData");
    log.info(cardData);

    var keys = cardData.keySet().toArray();
    
    for (var key in keys) {
    	
    	var field = keys[key]
    	
    	if (field.indexOf("solicitacao_data___") > -1) {
    		
            
   		 
              var index = field.replace("solicitacao_data___", "");
              
              var solicitacao = cardData.get("solicitacao_numero___" + index) || "";
              log.info("##** id "+index);
              log.info("##** solicitacao "+solicitacao);


              var solicitacao_item_seq = cardData.get("solicitacao_item_seq___" + index) || "";
              var solicitacao_documentid = cardData.get("solicitacao_documentid___" + index) || "";
            
              updateCancelPurchaseRequest(index);
    	
    	 }
	
	
	}

}

function updateCancelPurchaseRequest(id)
{

    log.info("##** updateCancelPurchaseRequest  "+id);
  
    var cardServiceProvider = ServiceManager.getServiceInstance("ECMCardService");
    var cardServiceLocator = cardServiceProvider.instantiate("com.totvs.technology.ecm.dm.ws.ECMCardServiceService");
    var cardService = cardServiceLocator.getCardServicePort();
    var cardFieldDtoArray = cardServiceProvider.instantiate("com.totvs.technology.ecm.dm.ws.CardFieldDtoArray");
    var cardField = cardServiceProvider.instantiate("com.totvs.technology.ecm.dm.ws.CardFieldDto");

    var campo = "numero_cotacao___" + hAPI.getCardValue("solicitacao_item_seq___"+id);
    var valor = getValue("WKNumProces");
    var documentid = hAPI.getCardValue("solicitacao_documentid___"+id)
    var solicitacao_numero = hAPI.getCardValue("solicitacao_numero___"+id)
    var produto_descricao = hAPI.getCardValue("produto_descricao___"+id)

    log.info("##** campo  "+campo);
    log.info("##** documentid  "+documentid);
    log.info("##** valor  "+valor);
    log.info("##** solicitacao_numero  "+solicitacao_numero);

    cardField.setField(campo);
    cardField.setValue("");

    cardFieldDtoArray.getItem().add(cardField);

    //hAPI.setTaskComments(, orderNumProcess,  0, str_obs)

   hAPI.setTaskComments(getValue("WKUser"), solicitacao_numero,  0, "A cotação "+valor+" que o item "+produto_descricao+" participava foi cancelada pelo comprador. ");

    cardService.updateCardData(1, "felipe.louzada", "Aa@74412692", parseInt(documentid), cardFieldDtoArray);
}