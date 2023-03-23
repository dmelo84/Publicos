function centroCustoRH() {
	var unidade_codigo = hAPI.getCardValue("unidade_codigo");
	var centroCusto    = hAPI.getCardValue("ccusto_codigo");
	/*
    if (unidade_codigo == '0950' 
    	|| unidade_codigo == '0990') {
    	return true;
    } else {
    	return false;
    }
    */
	var constraints = new Array();
	constraints.push(DatasetFactory.createConstraint("CCUSTO", unidade_codigo, unidade_codigo, ConstraintType.MUST));
	
	var dataset = DatasetFactory.getDataset("VW_APROVADOR_GERENTE_RH", null, constraints, null);
	
	if (dataset.rowsCount > 0) {
		return true;
	} else {
		return false;
	}
}