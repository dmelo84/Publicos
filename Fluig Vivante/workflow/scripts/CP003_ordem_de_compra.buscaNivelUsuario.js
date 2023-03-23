function buscaNivelUsuario() {
	log.info("####### Ordem de Compra - Busca Nivel Usuario #######");
	var unidade = hAPI.getCardValue("unidade_codigo");
	var login   = hAPI.getCardValue("codusuario_rm");
	
	if (hAPI.getCardValue("nivelAprovador") != '') {
		login = hAPI.getCardValue("loginAprovador");
	}

	try {
		//Campos que irá trazer
		var fields = null;
		
		//Monta as constraints para consulta
		var constraints = new Array();
		constraints.push(DatasetFactory.createConstraint("unidade", unidade, unidade, ConstraintType.MUST));
		constraints.push(DatasetFactory.createConstraint("login", login, login, ConstraintType.MUST));
		
		//Define os campos para ordenação
		var sortingFields = null;
		
		//Busca o dataset
		var dataset = DatasetFactory.getDataset("dsBuscaNivelUsuario", fields, constraints, sortingFields);
		//var count   = dataset.values.length;

		return dataset.getValue(0,'NIVEL');
	} catch (e) {
		// TODO: handle exception
		log.dir("ERRO: " + e);
	}
} // buscaNivelUsuario