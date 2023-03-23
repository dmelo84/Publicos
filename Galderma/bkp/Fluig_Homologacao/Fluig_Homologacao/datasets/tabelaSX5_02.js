function createDataset(fields, constraints, sortFields) {
	
	var codTab="02";
    
	var servicoURL = "http://10.30.4.139:8083/rest/CONSULTA_SX5?cabela="+codTab  
    
    var myApiConsumer =  oauthUtil.getGenericConsumer("","", "", "");    
    var data = myApiConsumer.get(servicoURL);    
   
  
    var dataset = DatasetBuilder.newDataset();       
    
    var objdata = JSON.parse(data);    
   
    dataset.addColumn('tabela');
	dataset.addColumn('chave');
	dataset.addColumn('descricao');
	
	for(i = 0; i < objdata.length; i++){
		dataset.addRow(new Array(objdata[i]['tabela'], objdata[i]['chave'],objdata[i]['descricao']));
	};
		
    return dataset;    
}