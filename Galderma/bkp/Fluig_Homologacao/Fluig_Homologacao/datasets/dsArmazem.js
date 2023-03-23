function createDataset(fields, constraints, sortFields) {
	
	var ccod="";
    
	var servicoURL = "http://10.30.4.139:8083/rest/ARMAZEM_NNR"  
    
    var myApiConsumer =  oauthUtil.getGenericConsumer("","", "", "");    
    var data = myApiConsumer.get(servicoURL);    
   
  
    var dataset = DatasetBuilder.newDataset();       
    
    var objdata = JSON.parse(data);    
   
    dataset.addColumn('codigo');
	dataset.addColumn('descricao');
	
	for(i = 0; i < objdata.length; i++){
		dataset.addRow(new Array(objdata[i]['codigo'], objdata[i]['descricao']));
	};
		
    return dataset;    
}