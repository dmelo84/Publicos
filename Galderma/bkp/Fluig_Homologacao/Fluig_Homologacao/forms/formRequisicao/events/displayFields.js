/*Preenchimento de campos*/

function displayFields(form,customHTML){ 
	var usuarioId = getValue("WKUser");
	var const1 = DatasetFactory.createConstraint("colleaguePK.colleagueId",usuarioId , usuarioId, ConstraintType.MUST);
	var datasetAttachment = DatasetFactory.getDataset("colleague", null, [const1], null);
	var usuario = datasetAttachment.getValue(0,"colleagueName");
	var email = datasetAttachment.getValue(0,"mail");
	
	form.setValue("requisitante", usuario);
	form.setValue("nome", usuario);
	form.setValue("email", email);
}