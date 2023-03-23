function displayFields(form,customHTML){ 

    var codigo = parseInt(getValue("WKNumState"));
    var api = fluigAPI.getUserService().getCurrent();
    
    log.info(">>>>>>>>>>> " + api);
    
    //Trata campos do formulário
    /*
    if(form.getValue('valorConvertido') != ""){
    	setCardValue("valorConvertido", parseFloat(form.getValue('valorConvertido')))
        form.setEnabled("valorConvertido", false)
    }
    */
    if(form.getValue('aprova') == 'S'){
    	form.setEnabled("cliente", false);
    	form.setEnabled("nome", false);
        form.setEnabled("titulo", false)
        form.setEnabled("prefixo", false)
        form.setEnabled("parcela", false)
        form.setEnabled("tipo", false)
      //form.setEnabled("aprova", false)
        form.setEnabled("venctoaltera", false)
        form.setEnabled("empresa", false)
        form.setEnabled("motivo", false)
        form.setEnabled("venctoaltera", false)
        form.setEnabled("justificativa", false)
           
    }
    if(form.getValue("aprova") != "N"){
    	form.setEnabled("motivo", true)
    }else{
    	form.setEnabled("motivo", false)
    }
    if(codigo == 0){
    	form.setEnabled("empresa", true)
    	form.setEnabled("aprova", false)
    }
    if ( form.getValue("aprova") == "S" && codigo == 6 ) {
        form.setValue("ok", "Nivel 2")
      }
        
    //Trata os botoes habilitados
    // form.setHideDeleteButton(false);
    
    //Trata a visualização dos campos
    form.setShowDisabledFields(true);
    
    //Manter este codigo em todos os fontes
    form.setHidePrintLink(true);
    /*   
    if(form.getFormMode() != "VIEW" && codigo >= 4 && form.getValue('aprova') == 'Sim')  {
    	customHTML.append('<div class="form-group col-md-2">');
    	customHTML.append('<label for="ok">Status</label>');
    	customHTML.append('<input type="text" name="ok" id="ok" class="form-control" readonly>');
    	customHTML.append('</div>');    	
    }*/
    
  //Botoes
//    if(form.getValue('aprovacao') == 'Aprovado'){
//    	customHTML.append('<button type="button" id="grava" onclick="$("#grava").click()" class="btn btn-primary">Atualiza</button>');
//    }
    
}