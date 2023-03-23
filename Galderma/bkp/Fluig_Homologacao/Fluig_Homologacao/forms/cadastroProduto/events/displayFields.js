function displayFields(form,customHTML){ 
	
	 var codigo = parseInt(getValue("WKNumState"));
	 var api = fluigAPI.getUserService().getCurrent();
	 var usuarioId = getValue("WKUser");
	 var const1 = DatasetFactory.createConstraint("colleaguePK.colleagueId",usuarioId , usuarioId, ConstraintType.MUST);
	 var datasetAttachment = DatasetFactory.getDataset("colleague", null, [const1], null);
	 var usuario = datasetAttachment.getValue(0,"colleagueName");
	 var email = datasetAttachment.getValue(0,"mail");
	 
	 log.info(">>>>>>>>>>> " + api);
	 
	 //Edição dos campos
	 //form.setEnabled("b1_cod", false);
	 	
	//Trata campos do formulário
    if(codigo == 0){
    	
    	form.setValue("requisitante", usuario);
    	form.setValue("nome", usuario);
    	form.setValue("email", email);
    	/**/
    	form.setEnabled("b1_xorigem", false);
        form.setEnabled("b1_xtipo", false)
        form.setEnabled("b1_xgrupo", false)
        form.setEnabled("b1_grupo", false)
        form.setEnabled("b1_cod", false)
        form.setEnabled("b1_desc", false)
        form.setEnabled("b1_xsubgrp", false)
        form.setEnabled("b1_tipo", false)
        form.setEnabled("b1_um", false)
        form.setEnabled("b1_xtipgal", false)
        form.setEnabled("b1_locpad", false)
        form.setEnabled("b1_prv1", false) 
        form.setEnabled("b1_conta", false) 
        form.setEnabled("b1_cc", false) 
        form.setEnabled("b1_usafefo", false) 
        form.setEnabled("b1_xtpven", false)  
        form.setEnabled("b1_posipi", false)  
        form.setEnabled("b1_origem", false)   
        form.setEnabled("requisitante", false) 
        form.setEnabled("nome", false) 
        form.setEnabled("email", false)
    } 
	
	//Trata os botoes habilitados
    // form.setHideDeleteButton(false);
    
    //Trata a visualização dos campos
    form.setShowDisabledFields(true);
    
    //Manter este codigo em todos os fontes
    form.setHidePrintLink(true);
    
	 
}