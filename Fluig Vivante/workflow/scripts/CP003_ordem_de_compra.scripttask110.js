function scripttask110() {
    checkAprv();
}




function consultaMembrosPapel(codigoPapel) {

    log.info("@@@ consultaMembrosPapel " + codigoPapel);
    //Monta as constraints para consulta
    var constraints = new Array();
    constraints.push(DatasetFactory.createConstraint("workflowColleagueRolePK.roleId", codigoPapel, codigoPapel, ConstraintType.MUST));

    //Define os campos para ordenação
    var sortingFields = new Array();

    //Busca o dataset
    var dataset = DatasetFactory.getDataset("workflowColleagueRole", null, constraints, sortingFields);

    if (dataset) {
        return dataset;
    }

    
    
    
}


function checkAprv(){
    
    log.info("##$$ Chamou SolicitacaoAprovacaoSindico");

    loading.setMessage("Verificando Aprovações dos Síndicos");


    var processo = getValue("WKNumProces")
    log.info("##$$ Processo de Compra Origem "+processo);

    var processId = "CP004_aprovacao_sindico";
    var ativDest = "0";
    var listColab = new java.util.ArrayList();
    var obs = "";
    var completarTarefa = true;
    var modoGestor = false;

    var cardDataFields = hAPI.getCardData(getValue("WKNumProces"));
    log.info("##$$ CardData do Processo de Compras ");
    log.dir(cardDataFields)

    var produtos = cardDataFields.keySet().iterator();

  

    var index = 0;

    while (produtos.hasNext()) {

        var fieldProduto = produtos.next();


        if (fieldProduto.match(/seq___/)) {

            var id = fieldProduto.split("___")[1];
            var itemcontrl = hAPI.getCardValue("itemcontrl___" + id);
            var aprov_sindico_processo = hAPI.getCardValue("aprov_sindico_processo___" + id);
            var documentId = hAPI.getCardValue("documentid");

            if (itemcontrl != "" && aprov_sindico_processo == "") {


                loading.setMessage("Gerando Solicitações de Aprovação para Síndicos");

                var membros = consultaMembrosPapel("Aprov_Sindico_" + itemcontrl);


                for (var i = 0; i < membros.rowsCount; i++) {

                    var user = membros.getValue(i, "workflowColleagueRolePK.colleagueId");
                    log.info("##$$ Usuário adicionado " + user);
                    listColab.add(user);

                }


                var cardData = new java.util.HashMap();
                cardData.put("produto_nome", hAPI.getCardValue("produto_nome___" + id));
                cardData.put("ordem_documentId", documentId.toString());
                cardData.put("ordem_childId", hAPI.getCardValue("childId___" + id).toString());
                cardData.put("ordem_processo_origem", processo.toString());
                cardData.put("NumAtividadeMovimentada", "113"); //definia a atividade que deve ser movimentada no processo origem


                cardData.put("quantidade", hAPI.getCardValue("produto_quantidade___"+id).toString() + " "+ hAPI.getCardValue("produto_un___"+id).toString() );
                cardData.put("preco", hAPI.getCardValue("produto_preco___"+id).toString());
                cardData.put("total", hAPI.getCardValue("produto_valorTotal___"+id).toString());

                cardData.put("ccusto", hAPI.getCardValue("ccusto_codigo_item___"+id).toString() + " - " + hAPI.getCardValue("ccusto_nome_item___"+id).toString());
                cardData.put("unidade", hAPI.getCardValue("unidade_codigo").toString() + " - " + hAPI.getCardValue("unidade_nome").toString());
                cardData.put("solicitante", hAPI.getCardValue("nome_solicitante").toString());
                cardData.put("fornecedor", hAPI.getCardValue("fornecedor_cnpj").toString() +' - '+hAPI.getCardValue("fornecedor_nome").toString());

                cardData.put("cotacao_numero", hAPI.getCardValue("nro_cotacao").toString());
                cardData.put("cotacao_item", hAPI.getCardValue("childId_cotacao___"+id).toString());

                cardData.put("produto_codigo", hAPI.getCardValue("produto_codigo___"+id).toString());
              

                obs = "Solicito aprovação para o seguinte item controlado: <strong>" + hAPI.getCardValue("produto_nome___" + id) + "</strong>";


                var startedProcess = hAPI.startProcess(processId, ativDest, listColab, obs, completarTarefa, cardData, modoGestor);

                var num_processo_aprovacao = startedProcess.get("iProcess").toString();


                log.info("KS 2");

                log.info("##$$ startedProcess");
      
                log.dir(startedProcess);

                log.info("##$$ Started set id = " + id + " processo aprov " + startedProcess.get("iProcess").toString() + "Docto " + startedProcess.get("WDNrDocto"));


                //var childData = new java.util.HashMap();
                //childData.put("aprov_sindico_processo", num_processo_aprovacao);

                //addCardChild(tableName, cardData)
                //hAPI.setCardValue("aprov_sindico_processo___"+id , num_processo_aprovacao);
             
            }
        }
    }
    loading.setMessage("");
}

