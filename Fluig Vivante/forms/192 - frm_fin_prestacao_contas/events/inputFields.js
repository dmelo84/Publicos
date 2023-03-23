function inputFields(form){
	
	
	
	  if (form.getValue("periodo_inicial").match("^[0-3]?[0-9]/[0-3]?[0-9]/(?:[0-9]{2})?[0-9]{2}$")) {
	        var split = form.getValue("periodo_inicial").split('/');
			//form.setValue("periodo_inicial", split[0] + '/' + split[1] + '/' + split[2]);
			form.setValue("periodo_inicial", split[2] + '-' + split[1] + '-' + split[0]);
		}
		
		if (form.getValue("periodo_final").match("^[0-3]?[0-9]/[0-3]?[0-9]/(?:[0-9]{2})?[0-9]{2}$")) {
	        var split = form.getValue("periodo_final").split('/');
	        form.setValue("periodo_final", split[0] + '/' + split[1] + '/' + split[2]);
	    }
	  
	  
}