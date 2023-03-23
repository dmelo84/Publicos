function createDataset(fields, constraints, sortFields) {
	
	var ccod="";
    
	var servicoURL = "http://10.30.4.139:8083/rest/TITULOS_FINANCEIRO"  
    
    var myApiConsumer =  oauthUtil.getGenericConsumer("","", "", "");    
    var data = myApiConsumer.get(servicoURL);    
   
    var dataset = DatasetBuilder.newDataset();       
    
    var objdata = JSON.parse(data);    
   
    dataset.addColumn('Nome');
    dataset.addColumn('codigoCliente');
	dataset.addColumn('lojaCliente');
	
	for(i = 0; i < objdata.length; i++){
		dataset.addRow(new Array(objdata[i]['Nome'], objdata[i]['codigoCliente'], objdata[i]['lojaCliente']));
	};
		
    return dataset;    
}