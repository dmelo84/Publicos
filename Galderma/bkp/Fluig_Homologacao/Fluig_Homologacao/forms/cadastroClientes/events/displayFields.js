function displayFields(form,customHTML){ 

    var codigo = parseInt(getValue("WKNumState"));
    var api = fluigAPI.getUserService().getCurrent();
    
    log.info(">>>>>>>>>>> " + api);
    
    //Trata campos do formulário
    if(form.getValue('"selecionaLayer"') =='1'){
    	form.setEnable('A1_LOJA',false)
    	form.setEnable('A1_NOME',false)
    	form.setEnable('A1_PESSOA',false)
    	form.setEnable('A1_END',false)
    	form.setEnable('A1_EST',false)
    	form.setEnable('A1_COD_MUN',false)
    	form.setEnable('A1_MUN',false)
    	form.setEnable('A1_BAIRRO',false)
    	form.setEnable('A1_CEP',false)
    	form.setEnable('A1_DDD',false)
    	form.setEnable('A1_TEL',false)
    	form.setEnable('A1_PAISDES',false)
    	form.setEnable('A1_PAIS',false)
    	form.setEnable('A1_CGC',false)
    	form.setEnable('A1_INSCR',false)
    	form.setEnable('A1_EMAIL',false)
    	form.setEnable('A1_HPAGE',false)
    	form.setEnable('A1_MSBLQL',false)
    	form.setEnable('A1_COMPLEM',false)
    	form.setEnable('A1_XTIPCLI',false)
    	form.setEnable('A1_XDTABT',false)
    	form.setEnable('A1_COD',false)
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
    if(form.getValue('aprovacao') =='Aprovado'){
    	customHTML.append('<button type="button" id="grava" onclick="$("#grava").click()" class="btn btn-primary">Atualiza</button>');
    }
    */
}