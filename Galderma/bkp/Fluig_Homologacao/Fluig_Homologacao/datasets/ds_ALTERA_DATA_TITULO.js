function createDataset(fields, constraints, sortFields) {
	
	var cAlias   = "SE1";
	var endPoint = "http://10.30.4.139:8083/rest/TITULOS_FINANCEIRO"
	    
	var servicoURL = endPoint; 
	//
    console.log("Requisição: "+servicoURL)
    //
    var myApiConsumer =  oauthUtil.getGenericConsumer("","", "", "");    
    var data = myApiConsumer.get(servicoURL);
   
  
    var dataset = DatasetBuilder.newDataset();   
    //
    //console.log(data)
    //
    var objdata = JSON.parse(data);    
   
    dataset.addColumn('cAlias');
    dataset.addColumn('Codigo');
    dataset.addColumn('Nome');
	dataset.addColumn('Prefixo');
	dataset.addColumn('Numero');
	dataset.addColumn('Valor');
	dataset.addColumn('Vencimento');
	dataset.addColumn('VencimentoReal');
	dataset.addColumn('Tipo');
	dataset.addColumn('Parcela');
	dataset.addColumn('codigoCliente');
	dataset.addColumn('lojaCliente');
	
	for(i = 0; i < objdata.length; i++){
		dataset.addRow(new Array(cAlias, objdata[i]['Codigo'], objdata[i]['Nome'], objdata[i]['Prefixo'], objdata[i]['Numero'], objdata[i]['Valor'], objdata[i]['Vencimento'], objdata[i]['VencimentoReal'],objdata[i]['Tipo'],objdata[i]['Parcela'],objdata[i]['codigoCliente'],objdata[i]['lojaCliente']));
	};
		
    return dataset;   
}