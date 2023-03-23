function servicetask23(attempt, message) {
	
		var atv      = getValue("WKNumState");
		var nextAtv  = getValue("WKNextState");
		var obj = {}
		var auxTratDate = [];
		var dia, mes, ano, cDataEmiss
			
			 auxTratDate = hAPI.getCardValue("cmpEmissao").split('/');
		   	 ano  = auxTratDate[2];
		   	 mes  = auxTratDate[1];
		   	 dia  = auxTratDate[0];
		   	
		   	cDataEmiss = ano+mes+dia//("00" + dia).slice(-2)+'/'+("00" + mes).slice(-2)+'/'+("0000" + ano).slice(-4);
			
		   	 var Docs = hAPI.getCardValue('cmpNumDoc') == "" ? hAPI.getCardValue('cmpNumDoc1') : hAPI.getCardValue('cmpNumDoc');
		   	
			obj = {
				PP1_TPDOC: hAPI.getCardValue('cmpTipo'),
				PP1_EMCNPJ: hAPI.getCardValue('cmpFornecedor'),
				PP1_DOC : Docs,
				PP1_SERIE : hAPI.getCardValue('cmpSerie'),
				PP1_EMISSA : hAPI.getCardValue("cmpEmissao"),
				PP2_PDCOM: hAPI.getCardValue("cmpPedido"),
				SOLICIT_FLUIG: getValue("WKNumProces").toString()
			}
			
			try{
	            var clientService = fluigAPI.getAuthorizeClientService();
	            var data = {
	                companyId : getValue("WKCompany") + '',
	                serviceCode : 'TESTE_SERVICE',
	                endpoint : '',
	                method : 'post',// 'delete', 'patch', 'put', 'get'     
	                timeoutService: '100', // segundos
	                params : obj,
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
	       
}