


function beforeSendData(customFields, customFacts) {

	var processo = getValue("WKNumProces");
	var campos = hAPI.getCardData(processo);


	var totalFinalizadoNegociado = 0;
	var totalFinalizadoCotado = 0;
	var QtdFornecedores = 0;

	var contador = campos.keySet().iterator();

	while (contador.hasNext()) {
		var id = contador.next();

		if (id.match(/^cotacao_item_seq___/)) { // qualquer campo do Filho
			var campo = campos.get(id);
			var seq = id.split("___");

			var winner = campos.get("cotacao_item_vencedor___" + seq[1]);
			var seq_item = campos.get("cotacao_item_seq___" + seq[1]);

			if (winner != "") {

				totalFinalizadoNegociado += convertStringFloat(campos.get("cotacao_total_item___" + seq[1]));


				var contador2 = campos.keySet().iterator();

				while (contador2.hasNext()) {
					var id = contador2.next();

					if (id.match(/hist_cotacao_item_seq/)) { // qualquer campo do Filho
						var seq = id.split("___");
						var seq_item_hist = campos.get("hist_cotacao_item_seq___" + seq[1]);

						if (seq_item_hist == seq_item) {

							totalFinalizadoCotado += convertStringFloat(campos.get("hist_cotacao_total_item___" + seq[1]));

						}
					}
				}

			}

		}
	}



	var contador3 = campos.keySet().iterator();

	var count=0;
	while (contador3.hasNext()) {
		var id = contador3.next();

		if (id.match(/forn_seq___/)) { // qualquer campo do Filho
			var seq = id.split("___");

			count ++;
			QtdFornecedores = count;
			

		}
	}




	try {

		customFields[0] = hAPI.getCardValue("cotacao_tipo_cotacao___1");
		customFields[1] = hAPI.getCardValue("forn_razaosocial");
		customFields[2] = hAPI.getCardValue("unidade_codigo") + "- " + hAPI.getCardValue("unidade_nome");
		customFields[3] = hAPI.getCardValue("nome_comprador");
		customFields[4] = QtdFornecedores.toString();

		customFacts[0] = totalFinalizadoNegociado;
		customFacts[1] = totalFinalizadoCotado;
		customFacts[2] = QtdFornecedores;

		log.info("ANALYTICS: totalFinalizadoNegociado" + totalFinalizadoNegociado);
		log.info("ANALYTICS: totalFinalizadoCotado" + totalFinalizadoCotado)
		log.info("ANALYTICS: QtdFornecedores" + QtdFornecedores)

	} catch (e) {
		log.info("ANALYTICS: erro" + e.lineNumber);
	}
}


function convertStringFloat(valor) {
	valor = String(valor);
	valor = valor.replace("R$ ", "").replace(" %", "");

	if (valor.indexOf(',') == -1) {} else {
		valor = valor.split(".").join("").replace(",", ".");
	}
	valor = parseFloat(valor);

	valor = valor.toFixed(4);

	return parseFloat(valor);
}