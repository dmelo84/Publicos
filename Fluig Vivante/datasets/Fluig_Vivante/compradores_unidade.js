function createDataset(fields, constraints, sortFields) {


    log.info("##** 1 Inicio dataset");

    var dataset = DatasetBuilder.newDataset();  

    dataset.addColumn("UNIDADE_CODIGO");
    dataset.addColumn("USUARIO");

    var UNIDADE_CODIGO = "";

    if (constraints != null) {
        if (constraints.length > 0) {
            for (var i = 0; i < constraints.length; i++) {
                if (constraints[i].fieldName == 'UNIDADE_CODIGO') {
                    UNIDADE_CODIGO = constraints[i].initialValue;
                }
            }
        }
    }

    log.info("##** 2 UNIDADE CODIGO " +UNIDADE_CODIGO);

    
    var constraintsCompradores = new Array();
    constraintsCompradores.push(DatasetFactory.createConstraint("workflowColleagueRolePK.roleId", "Comprador_Unidade", "Comprador_Unidade", ConstraintType.MUST));

    var dsCompradores = DatasetFactory.getDataset("workflowColleagueRole", null, constraintsCompradores, null);

    for (var i = 0; i < dsCompradores.rowsCount; i++) {

        var colleagueId = dsCompradores.getValue(i, "workflowColleagueRolePK.colleagueId");

        log.info("##** 3 colleagueId no Papel Comprador_Unidade " +colleagueId);
        
        var login = returnlogin(colleagueId);
        var constraintsUsuarioUnidade = new Array();
        constraintsUsuarioUnidade.push(DatasetFactory.createConstraint("COD_UNIDADE", UNIDADE_CODIGO, UNIDADE_CODIGO, ConstraintType.MUST));
        constraintsUsuarioUnidade.push(DatasetFactory.createConstraint("FLUIG_LOGIN", login, login, ConstraintType.MUST));


        log.info("##** 4 Constraints consulta Usuario Unidade " );
        log.dir(constraintsUsuarioUnidade);


        var dsUsuarioUnidade = DatasetFactory.getDataset("rm_consulta_usuario_unidade", null, constraintsUsuarioUnidade, null);



        if(dsUsuarioUnidade.rowsCount > 0){
           
            
            for (var j = 0; j < dsUsuarioUnidade.rowsCount; j++) {

                dataset.addRow(new Array(
                    dsUsuarioUnidade.getValue(j, "COD_UNIDADE"),
                    dsUsuarioUnidade.getValue(j, "FLUIG_LOGIN")

                ));


            }
        }

    }

 

    return dataset;

}

function returnlogin(colleagueId) {
	var fieldsUser = null;

	var constraintsUser = new Array();
	constraintsUser.push(DatasetFactory.createConstraint("colleaguePK.colleagueId", colleagueId, colleagueId, ConstraintType.MUST));

	var sortingFieldsUser = null;

	//Busca o dataset
	var datasetUser = DatasetFactory.getDataset("colleague", fieldsUser, constraintsUser, sortingFieldsUser);

	return datasetUser.getValue(0, "login");
}

