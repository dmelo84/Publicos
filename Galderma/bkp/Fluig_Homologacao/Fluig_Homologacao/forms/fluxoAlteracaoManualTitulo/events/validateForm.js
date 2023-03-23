function validateForm(form){
	
	var codigo = parseInt(getValue("WKNumState"));
			
	if(form.getValue("venctoaltera") == ""){
		throw "(o,o).Preencha a data de alteração do título.(o,o)";
	}
	if(form.getValue("aprova") == "P" && codigo == 4 || form.getValue("aprova") == "P" && codigo == 6 ){
		throw "(o,o).Selecione a opção de aprovação do título.(o,o)"
	}
	if(form.getValue("motivo") == "" && form.getValue("aprova") == 'N'){
		throw "(o,o).Preecha o motivo da não aprovação.(o,o)"
	}
	if(form.getValue("justificativa") == "" && form.getValue("aprova") != 'N' ){
		throw "(o,o).Não é possivel avançar na atividade. Justificativa não preenchida."	
	}
//	if(form.getValue("aprova")!= "Pendente" && codigo == 6){
//		throw "(o,o).Para títulos maior que 1 milhão a aprovação fica por conta do segundo nivel. Retorne a aprovação para PENDENTE.(o,o)"
//	}
		
}