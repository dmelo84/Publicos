function createDataset(fields, constraints, sortFields) {
	    
	var filtro = ""
		if (constraints !== null){
			//
			console.log("if constraint")
			//
			for (var i = 0; i < constraints.length; i++) {
				if (constraints[i].fieldName == "ALIAS") {
					//
					 console.log("if Alias "+constraints[i].initialValue)
					//
					filtro += "?alias=" +constraints[i].initialValue + "" ;
					 
				 }
				if (constraints[i].fieldName == "EMPRESA") { 
					 
					 filtro += "&empresa=" +constraints[i].initialValue + "" ; 
					 
				 }
				if (constraints[i].fieldName == "FILIAL") { 
					//
					 console.log("if filial "+constraints[i].initialValue)
					//
					filtro += "&filial=" +constraints[i].initialValue + "" ; 
					 
				 }
				if (constraints[i].fieldName == "TITULO") { 
					//
					 console.log("if numero "+constraints[i].initialValue)
					//
					filtro += "&numero=" +constraints[i].initialValue + "" ; 
					 
				 }
			}
			console.log("FILTRO = " +filtro)
		}
	
	var servicoURL = "http://10.30.4.139:8083/rest/BAIXA_TITULOS"+filtro   
    
    var myApiConsumer =  oauthUtil.getGenericConsumer("","", "", "");    
    var data = myApiConsumer.get(servicoURL);    
   
  
    var dataset = DatasetBuilder.newDataset();       
    
    console.log(data)
    
    var objdata = JSON.parse(data);    
   
    dataset.addColumn('Codigo');
	dataset.addColumn('Filial');
	dataset.addColumn('Prefixo');
	dataset.addColumn('Numero');
	dataset.addColumn('Parcela');
	dataset.addColumn('Tipo');
	dataset.addColumn('Nome');
	dataset.addColumn('Valor');
	dataset.addColumn('Vencimento');
	dataset.addColumn('VencimentoReal');
	dataset.addColumn('codigoFornece');
	dataset.addColumn('lojaFornece');
	
	for(i = 0; i < objdata.length; i++){
		dataset.addRow(new Array(objdata[i]['Codigo'],
						objdata[i]['Filial'],
						objdata[i]['Prefixo'],
						objdata[i]['Numero'],
						objdata[i]['Parcela'],
						objdata[i]['Tipo'],
						objdata[i]['Nome'],
						objdata[i]['Valor'],
						objdata[i]['Vencimento'],
						objdata[i]['VencimentoReal'],
						objdata[i]['codigoFornece'],
						objdata[i]['lojaFornece']));
	};
		
    return dataset;    
}