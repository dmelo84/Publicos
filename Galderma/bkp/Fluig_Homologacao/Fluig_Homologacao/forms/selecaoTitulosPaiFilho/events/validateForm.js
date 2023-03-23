function validateForm(form){
	
	var indexes = form.getChildrenIndexes('ingre');
	var atividadeAtual = parseInt(getValue("WKNumState"));
	
	var indexes  = form.getChildrenIndexes('ingre');
	var atv      = getValue("WKNumState");
	var nextAtv  = getValue("WKNextState");
	var obj      = {}
	var total = 0
	var linhas = indexes.length
	
/*Validaçães de campo */	
	
	if(atv == 14 || atv == 07 || atv == 9){
		if(form.getValue('motivoRep') == '' && form.getValue('aprovaN1') == 'N'){
			throw ("Motivo de reprovação não preenchido, e é obrigatório.")
		}
	}
	if(form.getValue('motivo') == ''){
		throw ("Motivo da baixa não preenchido, e é obrigatório.")
	}
		
	if(indexes.length < 1){
		throw ("Nenhum título na lista de baixa.")
	}else{
		for(var i = 0; i < indexes.length; i++){
			if(form.getValue("titulo___"+indexes[i]) == ''){
				throw("A tabela contém linhas não preenhidas com o número do título.")
			}
		}
	}
	if(atividadeAtual != 0){
		form.setValue('hdi_etapa', atividadeAtual)
	}
	for(var i = 0; i < indexes.length; i++){
		if(form.getValue("valor___"+indexes[i]) > 0){
			total += parseInt(form.getValue("valor___"+indexes[i]))
		}
	}
/*Gravação de campo hidden*/
	console.log("Valor total: "+total)
	form.setValue('total',total)
	//
	console.log("Valor total Hiden: "+total)
	form.setValue('hdi_total',total)
	//
	console.log("Total de linhas: "+linhas)
	form.setValue('linhas',linhas)
		
}
