/*Preenchimento de campos*/

function displayFields(form,customHTML){ 
		
	var codigo = parseInt(getValue("WKNumState"))
	var usuarioId = getValue("WKUser");
	var const1 = DatasetFactory.createConstraint("colleaguePK.colleagueId",usuarioId , usuarioId, ConstraintType.MUST);
	var datasetAttachment = DatasetFactory.getDataset("colleague", null, [const1], null);
	var usuario = datasetAttachment.getValue(0,"colleagueName");
	var email = datasetAttachment.getValue(0,"mail");
		
	if(codigo == 0 ){
		//Controle de edição de campo
		form.setValue("requisitante", usuario);
		form.setValue("nome", usuario);
		form.setValue("email", email);
	  //form.setEnabled("requisitante", true);
	}else{
		form.setEnabled("requisitante", false);
		form.setValue("hdi_etapa",codigo)
	}
/*
	if(codigo == 7 || codigo == 9 || codigo == 14){
		form.setEnabled("aprovaN1", true)
	}else{
		form.setEnabled("aprovaN1", false)
	}
*/		
}