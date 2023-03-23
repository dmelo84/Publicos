function afterTaskSave(colleagueId,nextSequenceId,userList){
	var atv      = getValue("WKNumState");
	var nextAtv  = getValue("WKNextState");
	var obj = {}
	var auxTratDate = [];
	var dia, mes, ano, cDataEmiss
	var lVez = false;
	var lOk  = false;
		
		 auxTratDate = hAPI.getCardValue("venctoaltera").split('/');
	   	 ano  = auxTratDate[2];
	   	 mes  = auxTratDate[1];
	   	 dia  = auxTratDate[0];
	   	
	   	 cDataEmiss = ano+mes+dia//("00" + dia).slice(-2)+'/'+("00" + mes).slice(-2)+'/'+("0000" + ano).slice(-4);
		
	   	 var Docs = hAPI.getCardValue('empresa') == "" ? hAPI.getCardValue('cliente') : hAPI.getCardValue('titulo');
	   	
		obj = {
			cEmp  : hAPI.getCardValue('empresa'),
			cFil  : hAPI.getCardValue('filial'),
			cPref : hAPI.getCardValue('prefixo'),
			cNum  : hAPI.getCardValue('titulo'),
			cParc : hAPI.getCardValue('parcela'),
			cTipo : hAPI.getCardValue("tipo"),
			dData : hAPI.getCardValue("venctoaltera"),
			nValor: hAPI.getCardValue("valorConvertido"),
			cTable: "SE1",
			cProcesso : getValue("WKNumProces").toString(),
			atividade : getValue("WKNumState").toString()
		}
		
		if(atv == 5 && hAPI.getCardValue("aprova") == "S" ){
			
			try{
	            var clientService = fluigAPI.getAuthorizeClientService();
	            var data = {
	                companyId : getValue("WKCompany") + '',
	                serviceCode : 'ALTERA_VENCIMENTO_TITULO',
	                endpoint : 'http://10.30.4.139:8083/rest/TITULOS_FINANCEIRO',
	                method : 'post',// 'delete', 'patch', 'put', 'get'     
	                timeoutService: '100', // segundos
	                params : obj,
	             headers: {
	            	 TenantID:hAPI.getCardValue('empresa')+",01"
	             }
	            }
	            
	            console.log(JSONUtil.toJSON(data))
	            
	            var vo = clientService.invoke(JSONUtil.toJSON(data));
	            var retorno  = JSON.parse(vo.getResult());
	            
	            console.log("RETORNO => "+vo.getResult())
	            
	            if(vo.getResult()== null || vo.getResult().isEmpty()){
	            	console.log("ERROR => "+err)
	            	throw err
	            }else{	 	                	                	                
	                if(typeof(retorno.OK) != "undefined"){
	                	lVez = true;
	                	console.log("OK => "+retorno.OK);
	                }else{
	                	console.log("PARSE => "+retorno.errorMessage)
	                	throw retorno.errorMessage
	                }
	                console.log("lVez => "+lVez)
	            }
	        }catch(err){
	        	console.log("CATCH => "+err)
	        	//throw "catch "+err
	        }
	      //Envio de email
            if(atv == 5 ){
        		
        		if(hAPI.getCardValue('aprova') == 'S' && lVez){
        			lOk = true;
        		}
        		//Gravou
        		if(lOk){
        			
        			var oTitulo = {
        						  cEmp:  hAPI.getCardValue('empresa'),
        						  cFil:  hAPI.getCardValue('filial'),
        		        		  cPref: hAPI.getCardValue('prefixo'),
        		      			  cNum:  hAPI.getCardValue('titulo'),
        		      			  cParc: hAPI.getCardValue('parcela'),
        		      			  cTipo: hAPI.getCardValue('tipo'),
        		      			  dData: hAPI.getCardValue('venctoaltera'),
        		      			  nValor:hAPI.getCardValue('valorConvertido'),
        		      			  cTable: "SE1",
        	      			  };
        			
        			var JSONStr = JSONUtil.toJSON(oTitulo); 
        			console.log(JSONStr)
        			
        			var aEmail = ["diogo.silva@qsdobrasil.com","diogo.silva@galderma.com","raphaela.marques@galderma.com"]
        			
        			 log.info('funcao email');
        			
        			for(i = 0; i < aEmail.length; i++){
        				
        				    var obj = new com.fluig.foundation.mail.service.EMailServiceBean();
        				    var subject = "[ WorkFlow ] - Titulo com Vencimento alterado";
        				    var emailSolic = aEmail[i]//"raphaela.marques@galderma.com"
        				    var mailFluig  = "workflow@galderma.com"
        				    	
        				    mensagem = "<!DOCTYPE html>"
        				    mensagem +="<html>"
        				    mensagem +="<head>"
        				    mensagem +="<style>"
        				    mensagem +="table, td, th {"    
        				    mensagem +="border: 1px solid #ddd;"
        				    mensagem +="text-align: left;"
        				    mensagem +="}"
        				   	mensagem +="table {"
        				    mensagem +="border-collapse: collapse;"
        				    mensagem +="width: 100%;"
        				    mensagem +="}"
        				    mensagem +="th, td {"
        				    mensagem +="padding: 15px;"
        				    mensagem +="}"
        				    mensagem +="</style>"
        				    mensagem += "</head>"
        				    mensagem +="<body>"
        				    mensagem +="<h2>Alteração de título</h2>"
        				    mensagem +="<p>O título abaixo foi alterado pelo processo do Fluig.</p>"
        				    mensagem +="<table>"
        				    mensagem +="<tr>"
        				    mensagem +="<th>Empresa</th>"
        				    mensagem +="<th>Titulo</th>"
        				    mensagem +="<th>Cliente</th>"
        				    mensagem +="<th>Vencimento Atual</th>"
        				    mensagem +="<th>Vencimento Anterior</th>"
        				    mensagem +="<th>Valor</th>"
        				    mensagem +="</tr>"
        				    mensagem +="<tr>"
        				    	if(hAPI.getCardValue('empresa') == '01'){
        				    		cEmpresa = "Galderma"
        				    	}else{
        				    		cEmpresa = "Galderma Distribuidora"
        				    	}
        				    mensagem +="<td>"+cEmpresa+"</td>"
        				    mensagem +="<td>"+hAPI.getCardValue('titulo')+"</td>"
        				    mensagem +="<td>"+hAPI.getCardValue('nome')+"</td>"
        				    mensagem +="<td>"+hAPI.getCardValue('venctoaltera')+"</td>"
        				    mensagem +="<td>"+hAPI.getCardValue('venctoreal')+"</td>"
        				    mensagem +="<td>"+"R$ "+hAPI.getCardValue('valorConvertido')+"</td>"
        				    mensagem +="</tr>"
        				    mensagem +="</table>"
        				    mensagem +="</body>"
        				    mensagem +="</html>"


        				    obj.simpleEmail(1,subject, mailFluig, emailSolic, mensagem, "text/html");
        			}
        			   
        		}else{
        			//Não gravou
        			var oTitulo = {
  						  cEmp:  hAPI.getCardValue('empresa'),
  						  cFil:  hAPI.getCardValue('filial'),
  		        		  cPref: hAPI.getCardValue('prefixo'),
  		      			  cNum:  hAPI.getCardValue('titulo'),
  		      			  cParc: hAPI.getCardValue('parcela'),
  		      			  cTipo: hAPI.getCardValue('tipo'),
  		      			  dData: hAPI.getCardValue('venctoaltera'),
  		      			  nValor:hAPI.getCardValue('valorConvertido'),
  		      			  cTable: "SE1",
  	      			  };
  			
  			var JSONStr = JSONUtil.toJSON(oTitulo); 
  			console.log(JSONStr)
  			
  			var aEmail = ["diogo.silva@qsdobrasil.com","diogo.silva@galderma.com"]
  			
  			 log.info('funcao email');
  			
  			for(i = 0; i < aEmail.length; i++){
  				
  				    var obj = new com.fluig.foundation.mail.service.EMailServiceBean();
  				    var subject = "[ WorkFlow ] - Titulo não alterado";
  				    var emailSolic = aEmail[i]//"raphaela.marques@galderma.com"
  				    var mailFluig  = "workflow@galderma.com"
  				    	
  				    mensagem = "<!DOCTYPE html>"
  				    mensagem +="<html>"
  				    mensagem +="<head>"
  				    mensagem +="<style>"
  				    mensagem +="table, td, th {"    
  				    mensagem +="border: 1px solid #ddd;"
  				    mensagem +="text-align: left;"
  				    mensagem +="}"
  				   	mensagem +="table {"
  				    mensagem +="border-collapse: collapse;"
  				    mensagem +="width: 100%;"
  				    mensagem +="}"
  				    mensagem +="th, td {"
  				    mensagem +="padding: 15px;"
  				    mensagem +="}"
  				    mensagem +="</style>"
  				    mensagem += "</head>"
  				    mensagem +="<body>"
  				    mensagem +="<h2>Alteração de título</h2>"
  				    mensagem +="<p><font color='#FF0000'>Houve um erro na alteração do título.</font></p>"
  				    mensagem +="<p><font color='#FF0000'>"+retorno.errorMessage+"</font></p>"	
  				    mensagem +="<table>"
  				    mensagem +="<tr>"
  				    mensagem +="<th>Empresa</th>"
  				    mensagem +="<th>Titulo</th>"
  				    mensagem +="<th>Cliente</th>"
  				    mensagem +="<th>Vencimento Atual</th>"
  				    mensagem +="<th>Vencimento Anterior</th>"
  				    mensagem +="<th>Valor</th>"
  				    mensagem +="</tr>"
  				    mensagem +="<tr>"
  				    	if(hAPI.getCardValue('empresa') == '01'){
  				    		cEmpresa = "Galderma"
  				    	}else{
  				    		cEmpresa = "Galderma Distribuidora"
  				    	}
  				    mensagem +="<td>"+cEmpresa+"</td>"
  				    mensagem +="<td>"+hAPI.getCardValue('titulo')+"</td>"
  				    mensagem +="<td>"+hAPI.getCardValue('nome')+"</td>"
  				    mensagem +="<td>"+hAPI.getCardValue('venctoaltera')+"</td>"
  				    mensagem +="<td>"+hAPI.getCardValue('venctoreal')+"</td>"
  				    mensagem +="<td>"+"R$ "+hAPI.getCardValue('valorConvertido')+"</td>"
  				    mensagem +="</tr>"
  				    mensagem +="</table>"
  				    mensagem +="</body>"
  				    mensagem +="</html>"


  				    obj.simpleEmail(1,subject, mailFluig, emailSolic, mensagem, "text/html");
  			}
        			//Fim
        		}
        		
        	}
            //Fim envio de email 
		}
}