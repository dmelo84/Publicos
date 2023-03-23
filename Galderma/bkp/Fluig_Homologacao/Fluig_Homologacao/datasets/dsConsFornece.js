function createDataset(fields, constraints, sortFields) {
	
	var ccod="";
    
	var servicoURL = "http://10.30.4.139:8083/rest/FORNECEDORES_SA2"//?ccod=" + ccod;    
    
    var myApiConsumer =  oauthUtil.getGenericConsumer("","", "", "");    
    var data = myApiConsumer.get(servicoURL);    
   
  
    var dataset = DatasetBuilder.newDataset();       
    
    var objdata = JSON.parse(data);    
   
    dataset.addColumn('Codigo');
	dataset.addColumn('Nome');
	
	for(i = 0; i < objdata.length; i++){
		dataset.addRow(new Array(objdata[i]['Codigo'], objdata[i]['Nome']));
	};
		
    return dataset;    
}