function scripttask91() {

    preparaProcesso();

}

function preparaProcesso(){

    

    var processo = getValue("WKNumProces");
    
    log.info("xx@@# Iniciou preparação, processo: "+processo);

    var processId = "CP004_aprovacao_sindico";
    var ativDest = "0";
    var listColab = new java.util.ArrayList();
    var obs = "";
    var completarTarefa = true;
    var modoGestor = false;

    var cardDataFields = hAPI.getCardData(processo);

    log.info("xx@@# cardDataFields: ");
    log.dir(cardDataFields);

    var despesas = cardDataFields.keySet().iterator();

    var index = 0;

    while (despesas.hasNext()) {

        //log.info("xx@@# entrou no while");

        var fieldDespesa = despesas.next();

        if (fieldDespesa.match(/seq___/)) {

            var id = fieldDespesa.split("___")[1];
            log.info("xx@@# entrou no item "+id);

            var itemcontrl = hAPI.getCardValue("despesa_controle___" + id);
            log.info("xx@@# valor de itemcontrl "+itemcontrl);
            //var aprov_sindico_processo = hAPI.getCardValue("aprov_sindico_processo___" + id);
            var documentId = hAPI.getCardValue("documentid");

            if (itemcontrl != "" ) {

                //loading.setMessage("Gerando Solicitações de Aprovação para Síndicos");

                var membros = consultaMembrosPapel("Aprov_Sindico_" + itemcontrl);
                log.info("xx@@# sindicos encontrados");
                log.dir(membros);

                for (var i = 0; i < membros.rowsCount; i++) {

                    var user = membros.getValue(i, "workflowColleagueRolePK.colleagueId");
                    log.info("##$$ Usuário adicionado " + user);
                    listColab.add(user);

                }


                var cardData = new java.util.HashMap();
                cardData.put("produto_nome", hAPI.getCardValue("despesa_descricao___" + id));
                cardData.put("ordem_documentId", documentId.toString());
                cardData.put("ordem_childId", hAPI.getCardValue("seq___" + id).toString());

                cardData.put("ordem_processo_origem", processo.toString());
                cardData.put("NumAtividadeMovimentada", "93"); //definia a atividade que deve ser movimentada no processo origem
               

                cardData.put("quantidade", hAPI.getCardValue("quantidade___"+id).toString());
                cardData.put("preco", hAPI.getCardValue("valor_unitario___"+id).toString());
                cardData.put("total", hAPI.getCardValue("valor_despesa___"+id).toString());

                cardData.put("ccusto", hAPI.getCardValue("ccusto_codigo").toString() + " - " + hAPI.getCardValue("ccusto_nome").toString());
                cardData.put("unidade", hAPI.getCardValue("unidade_codigo").toString() + " - " + hAPI.getCardValue("unidade_nome").toString());
                cardData.put("solicitante", hAPI.getCardValue("solicitante").toString());
                cardData.put("fornecedor", hAPI.getCardValue("favorecido_codigo").toString() +' - '+hAPI.getCardValue("favorecido_nome").toString());

                cardData.put("cotacao_numero", "");
                cardData.put("cotacao_item", "");

                cardData.put("produto_codigo", "");
              

                obs = "SOLICITAÇÃO DE APROVAÇÃO DO ITEM DA PRESTAÇÃO DE CONTAS: <strong>" + hAPI.getCardValue("despesa_descricao___" + id) + "</strong>";


                var startedProcess = hAPI.startProcess(processId, ativDest, listColab, obs, completarTarefa, cardData, modoGestor);

                var num_processo_aprovacao = startedProcess.get("iProcess").toString();

                cardData.put("quantidade", hAPI.getCardValue("quantidade___"+id).toString());
                
                hAPI.setCardValue("despesa_WkSindico___"+id, num_processo_aprovacao);


                log.info("xx@@# startedProcesse")
                log.dir(startedProcess);

                log.info("xx@@# Started set id = " + id + " processo aprov " + startedProcess.get("iProcess").toString() + "Docto " + startedProcess.get("WDNrDocto"));


                //var childData = new java.util.HashMap();
                //childData.put("aprov_sindico_processo", num_processo_aprovacao);

                //addCardChild(tableName, cardData)
                //hAPI.setCardValue("aprov_sindico_processo___"+id , num_processo_aprovacao);
             
            }
        }
    }

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
