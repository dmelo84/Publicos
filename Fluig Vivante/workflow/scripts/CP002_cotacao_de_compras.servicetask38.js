function servicetask38(attempt, message) {

	//loading.setMessage("Enviando convites aos fornecedores...");

	var cardDataFields = hAPI.getCardData(getValue("WKNumProces"));
	var item = cardDataFields.keySet().iterator();

	log.info("@#2111 card ")
	log.dir(cardDataFields)

	while (item.hasNext()) {

		var field = item.next();

		if (field.match(/^forn_nome___/)) {

			var id = field.split("___")[1];
			var tipo_cotacao = hAPI.getCardValue("cotacao_tipo_cotacao___" + id);

			log.info("@#2111 tipo_cotacao  " + tipo_cotacao)

			log.info("@#2111 id " + id)
		


			if (tipo_cotacao == "web") {

				var nprocesso = getValue("WKNumProces");
				var key = hAPI.getCardValue("forn_key___" + id);
				var data = hAPI.getCardValue("data_limite");
				//var dtArr = data.split("-");
				//data = dtArr[2]+"/"+dtArr[1]+"/"+dtArr[0];
				
				//Monta mapa com parâmetros do template
				var parametros = new java.util.HashMap();

				var dadosHTML = "";
				dadosHTML += "<p>Prezado fornecedor,</p>";
				dadosHTML += "<p>Você está convidado para participar do processo de cotação Nº" + nprocesso + ".</p>";
				dadosHTML += "<p>Pedimos que realize o acesso no Portal de Cotações e registre os preços e condições até o dia " + data + ".</p>";
				dadosHTML += "<strong>Dados de Acesso:</strong>";
				dadosHTML += "<p><strong>Endereço do Portal:</strong> <a href=\"https://conecta.vivante.com.br/portal/Vivante/portal-cotacoes\">https://conecta.vivante.com.br/portal/Vivante/portal-cotacoes</a> <br>";
				dadosHTML += "    <strong>Número da Cotação: </strong> " + nprocesso + " <br>";
				dadosHTML += "    <strong>Código de Acesso: </strong>" + key;
				dadosHTML += "</p>";



				

				//Assunto do e-mail
				parametros.put("subject", "VIVANTE | Convite Processo de Cotação " + nprocesso);
				parametros.put("title", "VIVANTE | Convite Processo de Cotação " + nprocesso);
				parametros.put("bodyContent", dadosHTML);

				var destinatarios = new java.util.ArrayList();
				destinatarios.add("felipe.louzada@noick.com.br");
				destinatarios.add("felipelouzada@gmail.com");
				destinatarios.add(hAPI.getCardValue("codusuario_solicitante")); 
				

				log.info("@#2111 Envio email ")
				log.info("@#2111 parametros")
				log.dir(parametros)

				log.info("@#2111 x")
				for (x in notifier){
					log.info(x)
				}

				var result = notifier.notify("fluigadmin", "tplVivanteGeneric", parametros, destinatarios, "text/html");
				log.info("@#2111 result")
				log.info(result)


//notify(string,string,java.util.HashMap,string,string)

				/*var jsonContent = {
					"to": "felipelouzada@gmail.com", //emails of recipients separated by ";"
					"from": "workflow@vivante.com.br", // sender
					"subject": "VIVANTE | Convite Processo de Cotação " + getValue("WKNumProces"), //   subject
					"templateId": "TPLTASK_SEND_EMAIL", // template usado como modelo.
					"dialectId": "pt_BR", //Email dialect , if not informed receives pt_BR , email dialect ("pt_BR", "en_US", "es")
					"param": {
						"SERVER_URL": "https://conecta.vivante.com.br/",
						"WorkflowMailContent": dadosHTML
					} //  Map with variables to be replaced in the template    	
				}

				var consumer = oauthUtil.getNewAPIConsumer('7d40a562-cd02-415c-a9cf-73c1026253d9', '5cfef15d-2968-4fd7-bf62-cde41fcbd575163a4fa2-ec2c-40ce-aa57-bb1d63b2db25');
				
				consumer.post("/public/alert/customEmailSender", JSON.stringify(jsonContent));*/


				
			}
		}
	}
}