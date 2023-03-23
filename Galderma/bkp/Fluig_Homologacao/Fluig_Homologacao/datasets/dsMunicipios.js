function createDataset(fields, constraints, sortFields) {
	
	var ccod="";
    
	var servicoURL = "http://10.30.4.139:8083/rest/MUNICIPIOS_CC2"  
    
    var myApiConsumer =  oauthUtil.getGenericConsumer("","", "", "");    
    var data = myApiConsumer.get(servicoURL);    
   
  
    var dataset = DatasetBuilder.newDataset();       
    
    var objdata = JSON.parse(data);    
   
    dataset.addColumn('UF');
	dataset.addColumn('codigoMunicipio');
	dataset.addColumn('municipio');
	
	for(i = 0; i < objdata.length; i++){
		dataset.addRow(new Array(objdata[i]['UF'], objdata[i]['codigoMunicipio'], objdata[i]['municipio']));
	};
		
    return dataset;    
}