function servicetask109(attempt, message) {

	var process = getValue("WKNumProces");
	var processId = "CP003_ordem_de_compra";
	var ativDest = "59";
	var listColab = new java.util.ArrayList();
	listColab.add(getValue("WKUser"));
	var completarTarefa = true;
	var modoGestor = false;
	var obs = "Ordem de Compra gerada pelo processo de cotação: " + getValue("WKNumProces");



	//Faz a busca de quantas ordens devem ser geradas
	//Deve gerar uma ordem de compra para cada unidade / local entrega / fornecedor (combinação)

	var destinos = getDestinosOrdens();
	log.info("Int# ds Destinos")
	log.dir(destinos)

	try {
		//Para cada destino, deve montar as informações da ordem que será gerada
		for (var i = 0; i < destinos.rowsCount; i++) {

	

			var destinoUnidade      = destinos.getValue(i,"cotacao_unidade");
			var destinoLocalEntrega = destinos.getValue(i,"local_codigo");
			var destinoFornKey      = destinos.getValue(i,"forn_key");

			//Busca informações da ordens com base no destino
			var informacoesOrdens = getInformacoesOrdens(destinoUnidade, destinoLocalEntrega, destinoFornKey);

			log.info("Int# ds informacoesOrdens")
			log.dir(informacoesOrdens)

			var cardDataOrdem = new java.util.HashMap();

			// --------------- Monta campos da capa da Ordem -------------------- //

			cardDataOrdem.put("fornecedor_nome", informacoesOrdens.getValue(0,"forn_nome"));
			cardDataOrdem.put("fornecedor_cnpj", informacoesOrdens.getValue(0,"forn_cnpj"));
			cardDataOrdem.put("fornecedor_codigo", informacoesOrdens.getValue(0,"forn_codcfo"));
			cardDataOrdem.put("valor_frete", informacoesOrdens.getValue(0,"local_valor_frete"));
			cardDataOrdem.put("entrega_data", informacoesOrdens.getValue(0,"local_dataentrega"));
			cardDataOrdem.put("condpgto", informacoesOrdens.getValue(0,"local_condpgto"));
			cardDataOrdem.put("empresa_nome", informacoesOrdens.getValue(0,"empresa_nome"));
			cardDataOrdem.put("empresa_codigo", informacoesOrdens.getValue(0,"empresa_codigo"));
			cardDataOrdem.put("nome_solicitante", informacoesOrdens.getValue(0,"nome_comprador"));
			cardDataOrdem.put("unidade_codigo", informacoesOrdens.getValue(0,"cotacao_unidade"));
			cardDataOrdem.put("unidade_nome", informacoesOrdens.getValue(0,"cotacao_unidade_nome"));
			cardDataOrdem.put("ordem_data", dataAtualFormatada());
			cardDataOrdem.put("nro_cotacao", informacoesOrdens.getValue(0,"numero_cotacao"));
			cardDataOrdem.put("filial", informacoesOrdens.getValue(0,"filial_codigo"));
			cardDataOrdem.put("codusuario_rm", informacoesOrdens.getValue(0,"codusuario_comprador"));
			cardDataOrdem.put("codigo_solicitante", informacoesOrdens.getValue(0,"codusuario_comprador"));
			cardDataOrdem.put("local_estoque_codigo", informacoesOrdens.getValue(0,"local_codigo"));
			cardDataOrdem.put("local_estoque_nome", informacoesOrdens.getValue(0,"local_nome"));
			cardDataOrdem.put("ccusto_codigo", informacoesOrdens.getValue(0, "cotacao_ccusto_codigo"));
			cardDataOrdem.put("ccusto_nome", informacoesOrdens.getValue(0, "cotacao_ccusto_nome"));

			// --------------- Monta campos dos itens da Ordem -------------------- //

			for (var j = 0; j < informacoesOrdens.rowsCount; j++) {

			
				var index = (j + 1);

				log.info("Int# info")
				

				if (informacoesOrdens.getValue(j, "cotacao_produto_itemcontrl") != "") {
					cardDataOrdem.put("pendenteAprovSindico", "S");
				}

				cardDataOrdem.put("seq___" + index, index.toString())
				cardDataOrdem.put("produto_nome___" + index, informacoesOrdens.getValue(j,"cotacao_produto_descricao"));
				cardDataOrdem.put("produto_codigo___" + index, informacoesOrdens.getValue(j,"cotacao_produto_codigo"));

				cardDataOrdem.put("produto_un___" + index, "UN"); //TODO Incluir campo na Cotação

				cardDataOrdem.put("produto_quantidade___" + index, informacoesOrdens.getValue(j,"cotacao_produto_quantidade"));
				cardDataOrdem.put("produto_preco___" + index, informacoesOrdens.getValue(j,"cotacao_preco"));
				cardDataOrdem.put("produto_valorTotal___" + index, informacoesOrdens.getValue(j,"cotacao_total_item"));
				cardDataOrdem.put("produto_codtborcamento___" + index, informacoesOrdens.getValue(j,"cotacao_produto_codtborcamento"));
				cardDataOrdem.put("itemcontrl___" + index, informacoesOrdens.getValue(j,"cotacao_produto_itemcontrl"));
				cardDataOrdem.put("itemfamily___" + index, informacoesOrdens.getValue(j,"cotacao_produto_itemfamily"));
				cardDataOrdem.put("produto_tipo___" + index, informacoesOrdens.getValue(j,"cotacao_produto_tipo"));
				cardDataOrdem.put("produto_codtb2fat___" + index, informacoesOrdens.getValue(j,"cotacao_produto_codtb2fat"));
				cardDataOrdem.put("childId___" + index, index.toString());
				cardDataOrdem.put("childId_cotacao___" + index, informacoesOrdens.getValue(j,"cotacao_item_seq"));
				cardDataOrdem.put("ccusto_codigo_item___" + index, informacoesOrdens.getValue(j,"cotacao_ccusto_codigo"));
				cardDataOrdem.put("ccusto_nome_item___" + index, informacoesOrdens.getValue(j,"cotacao_ccusto_nome"));
				cardDataOrdem.put("produto_idprd___" + index, informacoesOrdens.getValue(j,"produto_idprd"));
				cardDataOrdem.put("produto_percent_ipi_iss___" + index, informacoesOrdens.getValue(j,"cotacao_produto_ipi"));

				/* Solicitacao de Origem */

				cardDataOrdem.put("sol_numero___" + index, informacoesOrdens.getValue(j,"solicitacao_numero"));
				cardDataOrdem.put("sol_id_item___" + index, informacoesOrdens.getValue(j,"solicitacao_item_seq"));
				cardDataOrdem.put("sol_documentId___" + index, informacoesOrdens.getValue(j,"solicitacao_documentid"));
				//cardDataOrdem.put("sol_uid_item", informacoesOrdens.getValue(0,numero_cotacao);
				log.info("Int# cardDataOrdem")
				log.dir(cardDataOrdem)


			}


			// --------------- Executa integração/Criação da OC -------------------- //

			var processStarted = hAPI.startProcess(processId, ativDest, listColab, obs, completarTarefa, cardDataOrdem, modoGestor);
			log.info("Int#  processStarted ");
			log.dir(processStarted)
			log.info(processStarted)

			//TODO: Confirmar que processo foi criado

			hAPI.setTaskComments(getValue("WKUser"), getValue("WKNumProces"), 0, "Ordem de Compra " + processStarted.get("iProcess").toString() + " criada para o fornecedor " + informacoesOrdens.getValue(0, "forn_nome"))
			
			// ---------------              Fim                 -------------------- //

		}
	} catch (error) {

		log.info("Int# ERRO")
		log.info(error)

		throw "Ocorreu um erro ao Gerar a Ordem de Compra: " + error


	}



}

function getDestinosOrdens() {

	var sentenca = " SELECT DISTINCT cotacao_unidade,local_codigo,forn_key FROM VW_COTACAO_VENCEDOR";
	sentenca += " where numero_cotacao =" + getValue("WKNumProces");
	return executaConsulta(sentenca)

}

function getInformacoesOrdens(destinoUnidade, destinoLocalEntrega, destinoFornKey) {

	var sentenca = "SELECT distinct * FROM VW_COTACAO_VENCEDOR";
	sentenca += " where cotacao_unidade ='" + destinoUnidade + "' and local_codigo =  '" + destinoLocalEntrega + "' and forn_key='" + destinoFornKey + "'";
	return executaConsulta(sentenca)

}

function executaConsulta(sentencaSQL) {

	log.info("Int#  executaConsulta")
	log.info("Int#  sentencaSQL")
	log.info(sentencaSQL)

	var constraints = new Array();
	constraints.push(DatasetFactory.createConstraint("consulta", sentencaSQL, sentencaSQL, ConstraintType.MUST));
	constraints.push(DatasetFactory.createConstraint('pool-name', 'AppDS', 'AppDS', ConstraintType.MUST));

	var sortingFields = new Array();
	var dataset = DatasetFactory.getDataset("consulta_mssql", null, constraints, sortingFields);

	log.info("Int#  dataset")
	log.dir(dataset)

	return dataset

}




function dataAtualFormatada() {
	var data = new Date();
	var dia = data.getDate();

	if (dia.toString().length == 1)
		dia = "0" + dia;
	var mes = data.getMonth() + 1;
	if (mes.toString().length == 1)
		mes = "0" + mes;
	var ano = data.getFullYear();
	return dia + "/" + mes + "/" + ano;
}

