function createDataset(fields, constraints, sortFields) {
	var filtro = ""
	if (constraints !== null){
		 for (var i = 0; i < constraints.length; i++) {
			 if (constraints[i].fieldName == "CGC") {
				 if(filtro != ""){
					 filtro += "&CGC='" +constraints[i].initialValue + "'" ;
				 }else{
					 filtro = "CGC='" +constraints[i].initialValue + "'" ; 
				 }
			 }
			 if (constraints[i].fieldName == "DOC") { 
				 if(filtro != ""){
					 filtro += "&DOC='" +constraints[i].initialValue + "'" ; 
				 }else{
					 filtro = "DOC='" +constraints[i].initialValue + "'" ; 
				 }
			 }
			 if (constraints[i].fieldName == "TIPO") { 
				 if(filtro != ""){
					 filtro += "&TIPO='" +constraints[i].initialValue + "'" ; 
				 }else{
					 filtro = "TIPO='" +constraints[i].initialValue + "'" ; 
				 } 
			 }
			 if (constraints[i].fieldName == "SERIE") { 
				 if(filtro != ""){
					 filtro += "&SERIE='" +constraints[i].initialValue + "'" ; 
				 }else{
					 filtro = "SERIE='" +constraints[i].initialValue + "'" ;  
				 }
				  
			 }
     }
	}
	
	var endPoint = "http://10.30.4.139:8083/rest/QXML_PP2"
	
	if(filtro != ""){
		endPoint += "?" +filtro;
	}
	
	    
	var servicoURL = endPoint/*+"&cPref="+cPref+"&cFilAtu="+cNum*/;    
    
    var myApiConsumer =  oauthUtil.getGenericConsumer("","", "", "");    
    var data = myApiConsumer.get(servicoURL);
   
  
    var dataset = DatasetBuilder.newDataset();       
    
    var objdata = JSON.parse(data);    
    console.log(data)
    
    dataset.addColumn('C7_PRODUTO');
    dataset.addColumn('C7_NUM');
    dataset.addColumn('B1_DESC');
    dataset.addColumn('PP2_DOC');
    dataset.addColumn('PP2_QUANT');
	dataset.addColumn('PP2_VUNIT');
	dataset.addColumn('PP2_TOTAL');
	dataset.addColumn('PP2_DSPFOR');
	dataset.addColumn('PP2_TPDOC');
	dataset.addColumn('PP1_EMRAZA');
	dataset.addColumn('PP2_EMCNPJ');
	dataset.addColumn('PP2_ITEM');
	dataset.addColumn('PP2_SERIE');
	
    
	console.log('---------------------------')
	for(var i in objdata){
		for(var x in objdata[i]){
		console.log(objdata[i][x].PP2_DOC)
		dataset.addRow(new Array(objdata[i][x].C7_PRODUTO, objdata[i][x].C7_NUM, 
								 objdata[i][x].B1_DESC,objdata[i][x].PP2_DOC, 
								 objdata[i][x].PP2_QUANT,objdata[i][x].PP2_VUNIT,
								 objdata[i][x].PP2_TOTAL,objdata[i][x].PP2_DSPFOR,
								 objdata[i][x].PP2_TPDOC,objdata[i][x].PP1_EMRAZA,
								 objdata[i][x].PP2_EMCNPJ,objdata[i][x].PP2_ITEM,
								 objdata[i][x].PP2_SERIE));
		}
	};
		
    return dataset;   
}