function beforeCancelProcess(colleagueId,processId){
	
	
	cancelPurchaseRequest();
    
    
}

function cancelPurchaseRequest(){


	var cardDataFields = hAPI.getCardData(getValue("WKNumProces"));
	var item = cardDataFields.keySet().iterator();

	//loading.setMessage("Atualizando Solicitações de Compras...");
	
	while (item.hasNext()) {
			
			var field = item.next();

			if (field.match(/^seq___/)) { 
					
					var id   = field.split("___")[1];
					updatePurchaseRequest1(id);
			}
	}

	return true;
}

function updatePurchaseRequest1(id)
{


	var cardServiceProvider = ServiceManager.getServiceInstance("ECMCardService");
	var cardServiceLocator = cardServiceProvider.instantiate("com.totvs.technology.ecm.dm.ws.ECMCardServiceService");
	var cardService = cardServiceLocator.getCardServicePort();
	var cardFieldDtoArray = cardServiceProvider.instantiate("com.totvs.technology.ecm.dm.ws.CardFieldDtoArray");
	var cardFieldPedido = cardServiceProvider.instantiate("com.totvs.technology.ecm.dm.ws.CardFieldDto");
	var cardFieldCotacao = cardServiceProvider.instantiate("com.totvs.technology.ecm.dm.ws.CardFieldDto");

	//
	var campo = "numero_pedido___" + hAPI.getCardValue("sol_id_item___"+id);
	var valor = getValue("WKNumProces");

  //
	var documentid = hAPI.getCardValue("sol_documentId___"+id) || "";
	var solicitacao_numero = hAPI.getCardValue("sol_numero___"+id) || "";
	var produto_nome = hAPI.getCardValue("produto_nome___"+id) || "";

	cardFieldPedido.setField("numero_pedido___" + hAPI.getCardValue("sol_id_item___" + id));
	cardFieldPedido.setValue("");

	cardFieldCotacao.setField("numero_cotacao___" + hAPI.getCardValue("sol_id_item___" + id));
	cardFieldCotacao.setValue("");

	cardFieldDtoArray.getItem().add(cardFieldPedido);
	cardFieldDtoArray.getItem().add(cardFieldCotacao);


	if (documentid && documentid != ""){

		var companyId = getValue("WKCompany");

		

		var constraints   = new Array();
			constraints.push(DatasetFactory.createConstraint("login", getValue("WKUser"),getValue("WKUser"), ConstraintType.MUST));
			
		//Busca o dataset
		var dataset = DatasetFactory.getDataset("fluig_default_workflow_user", null, constraints, null);
		
		log.info("Cancel...dataset");
		log.dir(dataset);

		var login     =		dataset.getValue(0, "login");
		var password  =		dataset.getValue(0, "password");


		try {
		
			//Limpa numero da Ordem no Item da Solicitação

			
				cardService.updateCardData(companyId, login, password, parseInt(documentid), cardFieldDtoArray);

				//Insere um complemento informando que o produto foi excluído da ordem
				hAPI.setTaskComments(getValue("WKUser"), solicitacao_numero,  0, "O item "+produto_nome+" não está mais relacionado a ordem de compra "+valor +" porque o processo foi cancelado pelo responsável.");
		
			
		} catch (error) {
			log.info("#Erro updateCardData")
		//	log.info(error)
			throw "Não foi possível atualizar as solicitações relacionadas a esta ordem: "+error.toString();
		}
	

	}
}
