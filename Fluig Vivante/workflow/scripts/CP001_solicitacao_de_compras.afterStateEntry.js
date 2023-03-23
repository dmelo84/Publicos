function afterStateEntry(sequenceId) {

	log.info("#afterStateEntry sequenceId "+sequenceId)

	hAPI.setCardValue("stateSequence", sequenceId);
	hAPI.setCardValue("stateName", getStateName("CP001_solicitacao_de_compras", sequenceId));

}

function getStateName(processId, sequenceId) {

	//Monta as constraints para consulta
	var constraints = new Array();
	constraints.push(DatasetFactory.createConstraint("processId", processId, processId, ConstraintType.MUST));
	constraints.push(DatasetFactory.createConstraint("sequence", sequenceId, sequenceId, ConstraintType.MUST));
	constraints.push(DatasetFactory.createConstraint("active", true, true, ConstraintType.MUST));

	//Define os campos para ordenação
	var sortingFields = new Array();

	//Busca o dataset
	
	try {

		var dataset = DatasetFactory.getDataset("fluig_processStateDefinition", null, constraints, sortingFields);

	if (dataset.rowsCount > 0) {
		return dataset.getValue(0, "stateName");
	} else {
		return false;
	}
		
	} catch (error) {

		throw "Ocorreu um erro ao buscar o dataset fluig_processStateDefinition: "+error;
		
	}

	


}