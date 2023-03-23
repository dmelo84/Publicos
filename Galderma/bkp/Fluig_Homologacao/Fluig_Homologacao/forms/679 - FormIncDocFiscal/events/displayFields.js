function displayFields(form,customHTML){
	
	var atividade = parseInt(getValue('WKNumState'));
	
	var data = new Date();
    var dia  = data.getDate();
    var mes  = data.getMonth() + 1;
    var ano  = data.getFullYear();
    dia  = (dia<=9 ? "0"+dia : dia);
    mes  = (mes<=9 ? "0"+mes : mes);

    var newData = dia+"/"+mes+"/"+ano;
	
	form.setValue("cmpEmissao",newData);
	form.setEnabled('cmpEmissao', false);
	//form.setEnabled('cmpPedido', false);
	//form.setEnabled('cmpItemPedido', false);
	
	
}