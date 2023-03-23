function displayFields(form,customHTML){ 

    var codigo = parseInt(getValue("WKNumState"));
    var api = fluigAPI.getUserService().getCurrent();
    
    log.info(">>>>>>>>>>> " + api);
    
    //Trata campos do formulário
    if(form.getValue('aprova') == 'Sim'){
    	form.setEnabled("nome", false);
        form.setEnabled("titulo", false)
        form.setEnabled("prefixo", false)
        form.setEnabled("parcela", false)
        form.setEnabled("tipo", false)
        form.setEnabled("aprova", false)
        form.setEnabled("venctoaltera", false)
    } 
    if(codigo == 0){
    	form.setEnabled("aprova", false)
    }
        
    //Trata os botoes habilitados
    // form.setHideDeleteButton(false);
    
    //Trata a visualização dos campos
    form.setShowDisabledFields(true);
    
    //Manter este codigo em todos os fontes
    form.setHidePrintLink(true);
    
    //Botoes
    /*
     * <button type="button" id='grava' class="btn btn-primary">Grava</button>
	   <button type="button" id='aprovacao' class="btn btn-primary">Aprovação</button> 
     */
    /*
    if(form.getFormMode() != "VIEW" && codigo > 0)  {
    	customHTML.append("<button type='button' ");
    	customHTML.append("id='aprovacao' ");
    	customHTML.append("class='btn btn-primary'>");
    	customHTML.append("Aprovação</button>");
    }
    if(form.getValue('aprovacao') == 'Aprovado'){
    	customHTML.append('<button type="button" id="grava" onclick="$("#grava").click()" class="btn btn-primary">Atualiza</button>');
    }
    */
}