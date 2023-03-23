function afterTaskSave(colleagueId,nextSequenceId,userList){
	var atv      = getValue("WKNumState");
	var nextAtv  = getValue("WKNextState");
	var solicit = getValue("WKNumProces");
	var obj = {}
	var auxTratDate = [];
	var Doc = hAPI.getCardValue('cmpNumDoc').trim() == "" ? hAPI.getCardValue('cmpNumDoc1').trim() : hAPI.getCardValue('cmpNumDoc').trim();
    	try{
            var clientService = fluigAPI.getAuthorizeClientService();
            var data = {
                companyId : getValue("WKCompany") + '',
                serviceCode : 'API_CRUD_PP3',
                endpoint : '',
                method : 'post',// 'delete', 'patch', 'put', 'get'     
                timeoutService: '100', // segundos
                params : {
                	PP3_TPDOC: hAPI.getCardValue('cmpTipo'),
        			PP3_EMCNPJ: hAPI.getCardValue('cmpFornecedor'),
        			PP3_DOC : Doc,
        			PP3_SERIE : hAPI.getCardValue('cmpSerie'),
        			PP3_NFLUIG: solicit.toString()
                },
             headers: {
            	 TenantID:hAPI.getCardValue('cmpDestinataria')+",01"
             }
            }
            console.log(JSONUtil.toJSON(data))
            var vo = clientService.invoke(JSONUtil.toJSON(data));
            
            if(vo.getResult()== null || vo.getResult().isEmpty()){
            	//dataset.addRow(new Array(err));
            	console.log("ERROR => "+err)
            }else{
                log.info(vo.getResult());
            }
        } catch(err) {
        	console.log("ERROR => "+err)
        	//dataset.addRow(new Array(err));
        }
//         var JSONStr = JSONUtil.toJSON(obj); 
//       	 var constr = [ DatasetFactory.createConstraint("body",JSONStr, "", ConstraintType.MUST),
//       	                DatasetFactory.createConstraint("empresa",hAPI.getCardValue('cmpDestinataria'), "", ConstraintType.MUST)
//       	               ];
//       	 var datasetLogProcess = DatasetFactory.getDataset("ds_CRUDPP3", null ,constr, null);
        //}
}