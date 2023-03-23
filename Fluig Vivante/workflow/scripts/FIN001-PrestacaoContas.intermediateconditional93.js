function intermediateconditional93() {

    //RESPONSAVEL POR VERIFICAR SE AS APROVAÇÕES DOS ITENS CONTROLADOS/SÍNDICOS
	//FORAM CONCLUÍDAS. SE CONCLUÍDOS, AVANÇA PARA PRÓXIMA ATIVIDADE > DECISÃO PRÓXIMO APROVADOR

	log.info("##& Rodando Intermadiario ");
	var processo = getValue("WKNumProces");

	log.info("##& processo "+processo);

	var cardDataFields = hAPI.getCardData(processo);
	var item = cardDataFields.keySet().iterator();

	var retorno = false;

	var qtdItem=0;
	var qtdAprov=0;

	while (item.hasNext()) {

		var field = item.next();

		if (field.match(/seq___/)) {

			var id = field.split("___")[1];
			var despesa_WkSindico = hAPI.getCardValue("despesa_WkSindico___" + id);

			log.info("##& despesa_WkSindico "+despesa_WkSindico);

			if (despesa_WkSindico != "") {

				qtdItem ++;
				  //Monta as constraints para consulta
				  var constraints   = new Array();
				 // constraints.push(DatasetFactory.createConstraint("stateSequence", 9, 9, ConstraintType.MUST));
				  constraints.push(DatasetFactory.createConstraint("processHistoryPK.processInstanceId", despesa_WkSindico, despesa_WkSindico, ConstraintType.MUST));
				   
				  //Define os campos para ordenação
				  var sortingFields = new Array();
				   
				  log.info("##& constraints ");
				  log.dir(constraints);

				  //Busca o dataset
				  var dataset = DatasetFactory.getDataset("processHistory", null, constraints, sortingFields);
				   
				  for(var i = 0; i < dataset.rowsCount; i++) {
					
					var active = dataset.getValue(i, "active");
					var stateSequence = dataset.getValue(i, "stateSequence");
					
					if(active && stateSequence == 5){
						hAPI.setCardValue("despesa_statusAprov___"+id, "pendente");
					}

					if(stateSequence == 9){
						hAPI.setCardValue("despesa_statusAprov___"+id, "aprovado");
						qtdAprov++;
					}

					if(stateSequence == 15){
						hAPI.setCardValue("despesa_statusAprov___"+id, "reprovado");
						qtdAprov++;
					}
					
	
				  }

			}
		}
	}

	log.info("##& qtdItem "+ qtdItem + " qtdAprov "+ qtdAprov);

	if(qtdItem == qtdAprov){
		return true;
	} else {
		return false;
	}


//	log.info("##& RETORNO = "+retorno);

//	return retorno;

}

