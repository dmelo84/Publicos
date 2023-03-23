function centroCustoSESMET() {
	var unidade_codigo = hAPI.getCardValue("unidade_codigo");
	var centroCusto    = hAPI.getCardValue("ccusto_codigo");
	/*
    if (unidade_codigo == '0377' 
    	|| unidade_codigo == '0373'
    	|| unidade_codigo == '0378'
    	|| unidade_codigo == '0928'
    	|| unidade_codigo == '0998'
    	|| unidade_codigo == '0968') {
    	return true;
    } else {
    	return false;
    }
    */
	var constraints   = new Array();
	constraints.push(DatasetFactory.createConstraint("CCUSTO", unidade_codigo, unidade_codigo, ConstraintType.MUST));
	
	var dataset = DatasetFactory.getDataset("VW_APROVADOR_GERENTE_SESMT", null, constraints, null);
	
	if (dataset.rowsCount > 0) {
		return true;
	} else {
		return false;
	}
}