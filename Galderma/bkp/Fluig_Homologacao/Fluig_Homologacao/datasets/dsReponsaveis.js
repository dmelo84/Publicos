function createDataset(fields, constraints, sortFields) {
	
	var ds = DatasetBuilder.newDataset();
	
	ds.addColumn("login");
	ds.addColumn("nome");
	
	var filtroGrupo = DatasetFactory.createConstraint("colleagueGroupPK.groupId", "Responsaveis",
			"Responsaveis",ConstraintType.MUST);
	
	var datasetGrupo = DatasetFactory.getDataset("colleagueGroup", null, new Array(filtroGrupo), null);
	
	for (i = 0; i < datasetGrupo.rowsCount ;i++ ){
		var colabGrupo = DatasetGrupo.getValue(i, "colleagueGroupPK.colleagueId");
		
		var datasetColaborador = DatasetFactory.getDataset("colleague", null, null, null);
		
		for(j = 0; j < datasetColaborador.rowsCount; j++){
			var colabCol = datasetColaborador.getValue(j, "colleaguePK.colleagueId");
			var colabNome = datasetColaborador.getValue(j, "colleagueName");
			if(colabCol == colabGrupo){
				ds.addRow(new Array(colabCol, colabNome));
			}
		}
	}
	return datasetGrupo;
}