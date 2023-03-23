function afterProcessCreate(processId){
	
	log.info("@@&1 afterProcessCreate");

	checkPurchaseRequest();

	var WKNumProces = getValue("WKNumProces");
	//hAPI.setCardValue("ordem_numero", WKNumProces);
	


	  
}



function setChildTable(numProcessoPai){
	
	
	//var parent = hAPI.getParentInstance(numProcessoPai);
		
    var cardData = hAPI.getCardData(numProcessoPai);
       
    var keys = cardData.keySet().toArray();
    
    for (var key in keys) {
    	
    	var field = keys[key]
    	
    	if (field.indexOf("companyid___") > -1) {
    		
    		var childData = new java.util.HashMap();
   		 
    		  var index = field.replace("companyid___", "");
  
			  childData.put("seq",index);
			  childData.put("produto_codigo",cardData.get("produto_codigo___" + index));
			  childData.put("produto_nome",cardData.get("produto_descricao___" + index));
			  childData.put("produto_un",cardData.get("produto_un___" + index));
			  childData.put("produto_quantidade",cardData.get("produto_quantidade___" + index));
			  childData.put("produto_codtb2fat",cardData.get("produto_codtb2fat___" + index));
			  childData.put("produto_idprd",cardData.get("produto_id___" + index));
			  childData.put("ccusto_codigo_item",cardData.get("ccusto_codigo_item___" + index));
			  childData.put("ccusto_nome_item",cardData.get("ccusto_nome_item___" + index));
			  childData.put("produto_idprd",cardData.get("produto_id___" + index));
			  childData.put("produto_preco",cardData.get("produto_preco___" + index).replace(".",","));
			  childData.put("itemfamily",cardData.get("itemfamily___" + index));
			  childData.put("itemcontrl",cardData.get("itemcontrl___" + index));
			  childData.put("produto_tipo",cardData.get("produto_tipo___" + index));

			  childData.put("produto_contrato_idcnt",cardData.get("produto_contrato_idcnt___" + index));
			  childData.put("produto_contrato_nseqitmcnt",cardData.get("produto_contrato_nseqitmcnt___" + index));
			
    		 
    		  
    		  hAPI.addCardChild("tabelaItens",childData)
    	 }
	
	
	}
	var tipo = cardData.get("tipo_solicitacao");

	if(tipo=="contrato"){
		hAPI.setCardValue("tipo_ordem","contrato");
	}


	hAPI.setCardValue("unidade_codigo",cardData.get("unidade_codigo"));
	log.info("##)# Set Unidade = "+cardData.get("unidade_codigo"));
	hAPI.setCardValue("unidade_nome",cardData.get("unidade_nome"));
	hAPI.setCardValue("ccusto_codigo",cardData.get("ccusto_codigo"));
	hAPI.setCardValue("ccusto_nome",cardData.get("ccusto_nome"));
	
}



function checkPurchaseRequest(){


	var cardDataFields = hAPI.getCardData(getValue("WKNumProces"));
	var item = cardDataFields.keySet().iterator();

	//loading.setMessage("Atualizando Solicitações de Compras...");
	
	while (item.hasNext()) {
			
			var field = item.next();

			if (field.match(/^seq___/)) { 
					
					var id   = field.split("___")[1];
					updatePurchaseRequest(id);
			}
	}
}

function updatePurchaseRequest(id)
{


	var cardServiceProvider = ServiceManager.getServiceInstance("ECMCardService");
	var cardServiceLocator = cardServiceProvider.instantiate("com.totvs.technology.ecm.dm.ws.ECMCardServiceService");
	var cardService = cardServiceLocator.getCardServicePort();
	var cardFieldDtoArray = cardServiceProvider.instantiate("com.totvs.technology.ecm.dm.ws.CardFieldDtoArray");
	var cardField = cardServiceProvider.instantiate("com.totvs.technology.ecm.dm.ws.CardFieldDto");

	//
	var campo = "numero_pedido___" + hAPI.getCardValue("sol_id_item___"+id);
	log.info("@@&1 campo "+campo);
	var valor = getValue("WKNumProces");
	log.info("@@&1 valor "+campo);
  //
	var documentid = hAPI.getCardValue("sol_documentId___"+id);
	log.info("@@&1 documentid "+documentid);
	var solicitacao_numero = hAPI.getCardValue("sol_numero___"+id);
	log.info("@@&1 solicitacao_numero "+solicitacao_numero);
	var produto_nome = hAPI.getCardValue("produto_nome___"+id);
	log.info("@@&1 produto_descricao "+produto_nome);

	cardField.setField(campo);
	cardField.setValue(valor);

	log.info("@@&1 cardField");
	log.dir(cardField);

	cardFieldDtoArray.getItem().add(cardField);

	//hAPI.setTaskComments(, orderNumProcess,  0, str_obs)

	log.info("@@&1 Vai TaskComments ");
	hAPI.setTaskComments(getValue("WKUser"), solicitacao_numero,  0, "O item "+produto_nome+" foi relacionado a ordem de compra: "+valor +".");

	log.info("@@&1 cardFieldDtoArray ");
	log.dir(cardFieldDtoArray);



	var constraints   = new Array();
	constraints.push(DatasetFactory.createConstraint("login", getValue("WKUser"), getValue("WKUser"), ConstraintType.MUST));
	 
	


		//Busca o dataset
		var dataset  = DatasetFactory.getDataset("fluig_default_workflow_user", null, constraints, null);
		var login    = dataset.getValue(0, "login");
		var password = dataset.getValue(0, "password");

		log.info("@@&1 DataSet Login");
		log.dir(dataset);
	

	log.info("@@&1 Vai Rodar Update ");
	cardService.updateCardData(getValue("WKCompany"), login, password, parseInt(documentid), cardFieldDtoArray);
}
