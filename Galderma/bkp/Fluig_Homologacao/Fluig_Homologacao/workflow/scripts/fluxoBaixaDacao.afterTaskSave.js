function afterTaskSave(colleagueId,nextSequenceId,userList){
/*	
	var atv      = getValue("WKNumState");
	var nextAtv  = getValue("WKNextState");
	var obj      = {}
	var oTabela  = hAPI.getChildrenIndexes('ingre');
	var alias    = hAPI.getCardValue('depto')
	var oTitulo  = {"erro":"Sem Informacao"}
	var lOk = true;
		
	if(atv == 16 ){
		
		for(var i = 0; i < oTabela.length; i++){
			
			console.log("Tamanho tabela "+oTabela.length)
			
			empresa = hAPI.getCardValue('empresaId')
			filial  = hAPI.getCardValue('filial___'+oTabela[i])
								
			console.log("Linha: "+i +" Inicio!")
			
	//		if(hAPI.getCardValue("titulo___"+i) != ''){
				obj = {
						empresa  : hAPI.getCardValue("empresaId"),
						filial   : hAPI.getCardValue('filial___'+oTabela[i]),
						prefixo  : hAPI.getCardValue('prefixo___'+oTabela[i]),
						numero   : hAPI.getCardValue('titulo___'+oTabela[i]),
						parcela  : hAPI.getCardValue('parcela___'+oTabela[i]),
						tipo     : hAPI.getCardValue("tipo___"+oTabela[i]),
						valor    : hAPI.getCardValue("valor___"+oTabela[i]),
						alias    : alias,
						processo : getValue("WKNumProces").toString(),
						atividade: getValue("WKNumState").toString()
					}
				//Log do Objeto//
				console.log("Objeto Titulos: "+obj)
			    oTitulo = obj					
				//POST//
				try{
		            var clientService = fluigAPI.getAuthorizeClientService();
		            var data = {
		                companyId : getValue("WKCompany") + '',
		                serviceCode : 'baixaTitulos',
		                endpoint : 'http://10.30.4.139:8083/rest/BAIXA_TITULOS',
		                method : 'post',// 'delete', 'patch', 'put', 'get'     
		                timeoutService: '300', // segundos
		                params : obj,
		             headers: {
		            	 TenantID : empresa+","+"01"
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
		                	lOk = true;
		                	console.log("OK => "+retorno.OK);
		                }else{
		                	console.log("PARSE => "+retorno.errorMessage)
		                	lOk = false;
		                	throw retorno.errorMessage
		                }
		                
		                console.log("Linha: "+i +" Fim!")
		                
		                //Envio de email//
		              //Gravou
		        		if(lOk){
		        					        			
		        			var JSONStr = JSONUtil.toJSON(oTitulo); 
		        			
		        			console.log(JSONStr)
		        			
		        			var aEmail = ["diogo.silva@qsdobrasil.com","diogo.silva@galderma.com","raphaela.marques@galderma.com"]
		        			
		        			 log.info('funcao email');
		        			
		        			for(j = 0; j < aEmail.length; j++){
		        				
		        				    var obj = new com.fluig.foundation.mail.service.EMailServiceBean();
		        				    var subject = "[ WorkFlow ] - Título com baixa dação";
		        				    var emailSolic = aEmail[j]//"raphaela.marques@galderma.com"
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
		        				    mensagem +="<h2>Alteração de título dação</h2>"
		        				    mensagem +="<p>O título abaixo foi baixado pelo processo do Fluig.</p>"
		        				    mensagem +="<table>"
		        				    mensagem +="<tr>"
		        				    mensagem +="<th>Empresa</th>"
		        				    mensagem +="<th>Nome</th>"
		        				    mensagem +="<th>Filial</th>"
		        				    mensagem +="<th>Prefixo</th>"
		        				    mensagem +="<th>Titulo</th>"
		        				    mensagem +="<th>Parcela</th>"
		        				    mensagem +="<th>Tipo</th>"
		        				    mensagem +="<th>Valor</th>"
		        				    mensagem +="</tr>"
		        				    mensagem +="<tr>"
		        				    	if(hAPI.getCardValue('empresaId') == '01'){
		        				    		cEmpresa = "Galderma"
		        				    	}else{
		        				    		cEmpresa = "Galderma Distribuidora"
		        				    	}
		        				//    for(var i = 0; i < oTabela.length; i++){
		        				    	
		        				    	mensagem +="<td>"+cEmpresa+"</td>"
		        				    	mensagem +="<td>"+hAPI.getCardValue('nome___'+oTabela[i])+"</td>"
		        				    	mensagem +="<td>"+hAPI.getCardValue('filial___'+oTabela[i])+"</td>"
			        				    mensagem +="<td>"+hAPI.getCardValue('prefixo___'+oTabela[i])+"</td>"
			        				    mensagem +="<td>"+hAPI.getCardValue('titulo___'+oTabela[i])+"</td>"
			        				    mensagem +="<td>"+hAPI.getCardValue('parcela___'+oTabela[i])+"</td>"
			        				    mensagem +="<td>"+hAPI.getCardValue('tipo___'+oTabela[i])+"</td>"
			        				    mensagem +="<td>"+hAPI.getCardValue('valor___'+oTabela[i])+"</td>"
			        				    mensagem +="</tr>"
		        			 //	    }
		        				    		        				    	
		        				    mensagem +="</table>"
		        				    mensagem +="</body>"
		        				    mensagem +="</html>"


		        				    obj.simpleEmail(1,subject, mailFluig, emailSolic, mensagem, "text/html");
		        			}
		        		}
		                //
		            }
		        }catch(err){
		        	console.log("ERRO DIOGO")
		        	console.log("CATCH => "+err)
		        }
	//		}
		}
	}

*/	
}