function beforeTaskSave(colleagueId,nextSequenceId,userList){

    //Table tblItensCotacaoFornecedor
    updateTableChildIds("cotacao_item_seq","cotacao_childId");

    //Table tblItensCotacaoFornecedor
    updateTableChildIds("forn_seq","forn_childId");

    //Table tblItensCotacaoFornecedor
    updateTableChildIds("local_childId", "local_childId");

    if(nextSequenceId == 67){

        CopyNegociation();

    }


    var cardDataFields = hAPI.getCardData(getValue("WKNumProces"));
    var itemCotacao = cardDataFields.keySet().iterator();

    var arrUnidade = [];

    while (itemCotacao.hasNext()) {
        var fieldsCotacao = itemCotacao.next();
        if (fieldsCotacao.match(/^sol_unidade___/)) {
            var id = fieldsCotacao.split("___")[1];
            var unidade = hAPI.getCardValue("sol_unidade___" + id);

            log.info("@#* Id " + id + " unidade " + unidade);

            if (arrUnidade.indexOf(unidade) < 0) {
                arrUnidade.push(unidade)
            }

        }
    }

    log.info("@#* Arr Unidade")
    log.info(arrUnidade)



    


    var attachments = hAPI.listAttachments();
    log.info("##$$%%3 ");
    log.info(attachments)
    var hasAttachment = false;
  
    for (var i = 0; i < attachments.size(); i++) {
        var attachment = attachments.get(i);
        if (attachment.getDocumentDescription() == "fluig.pdf") {
            hasAttachment = true;
        }

        for(var x in attachment){

          log.info("##$$%% "+x);

        }
        log.info("##$$%%4 ");
        log.dir(attachment)
       
        var descricao = "nova desc";//attachment.getDocumentDescription() + attachment.getPhisicalFile()

   
    }
  
   // if (!hasAttachment) {
   //     throw "Attachment not found!";
  //  }


}

function updateTableChildIds(masterFieldName,idFieldName){


    var processo = getValue("WKNumProces");
    var campos   = hAPI.getCardData(processo);
    var contador = campos.keySet().iterator();
    var count    = 0;



    
    while (contador.hasNext()) {
        var id = contador.next();

        var str = masterFieldName+"___";

        log.info("#### str: " + str);

        if (id.indexOf(str) > -1) { 
            var campo = campos.get(id);
            var seq   = id.split("___");

            hAPI.setCardValue(idFieldName+"___" + seq[1],seq[1])
          
            log.info("#### campo: " + campo);
            log.info("#### seq: " + seq);

            count++;
        }
}

log.info("#### TOTAL DE FILHOS: " + count);

}


function CopyNegociation(){


    log.info("#(# CopyNegociation");
    var processo = getValue("WKNumProces");
    var campos = hAPI.getCardData(processo);
    var contador1 = campos.keySet().iterator();
    var contador2 = campos.keySet().iterator();
    var count = 0;


    while (contador1.hasNext()) {
        var id = contador1.next();

        if (id.match(/forn_seq___/)) { // qualquer campo do Filho
            var campo = campos.get(id);
            var seq = id.split("___");

            log.info("#(# forn_nome "+campos.get("forn_nome___" + seq[1]));


            hAPI.setCardValue("cotacao_prev_entrega_hist___"+ seq[1],campos.get("cotacao_previsao_entrega___" + seq[1]));
            hAPI.setCardValue("cotacao_tem_frete_hist___"+ seq[1],campos.get("cotacao_tem_frete___" + seq[1]));
            hAPI.setCardValue("cotacao_valor_frete_hist___"+ seq[1],campos.get("cotacao_valor_frete___" + seq[1]));
            hAPI.setCardValue("cotacao_cond_pgto_hist___"+ seq[1],campos.get("cotacao_cond_pgto___" + seq[1]));
            hAPI.setCardValue("cotacao_total_itens_hist___"+ seq[1],campos.get("cotacao_total_itens___" + seq[1]));
            hAPI.setCardValue("cotacao_total_hist___"+ seq[1],campos.get("cotacao_total_cotacao___" + seq[1]));
    
        }
    }


    while (contador2.hasNext()) {
        var id = contador2.next();

        if (id.match(/cotacao_item_seq___/)) { // qualquer campo do Filho
            var campo = campos.get(id);
            var seq = id.split("___");

            log.info("#(# cotacao_produto_descricaO "+campos.get("cotacao_produto_descricao___" + seq[1]));

            var childData = new java.util.HashMap();

            childData.put("hist_cotacao_item_seq", campos.get("cotacao_item_seq___" + seq[1]));

            childData.put("hist_cotacao_unidade", campos.get("cotacao_unidade___" + seq[1]));
            childData.put("hist_cotacao_unidade_nome", campos.get("cotacao_unidade_nome___" + seq[1]));

            childData.put("hist_cotacao_status_item", campos.get("cotacao_status_item___" + seq[1]));
            childData.put("hist_cotacao_solicit_numero", campos.get("cotacao_solicitacao_numero___" + seq[1]));
            childData.put("hist_cotacao_codcfo", campos.get("cotacao_codcfo___" + seq[1]));
            childData.put("hist_cotacao_key", campos.get("cotacao_key___" + seq[1]));
            childData.put("hist_cotacao_produto_codigo", campos.get("cotacao_produto_codigo___" + seq[1]));
            childData.put("hist_cotacao_produto_descricao", campos.get("cotacao_produto_descricao___" + seq[1]));
            childData.put("hist_cotacao_prod_quantidade", campos.get("cotacao_produto_quantidade___" + seq[1]));
            childData.put("hist_cotacao_produto_ipi", campos.get("cotacao_produto_ipi___" + seq[1]));

            childData.put("hist_cotacao_preco", campos.get("cotacao_preco___" + seq[1]));
            childData.put("hist_cotacao_solicit_item_seq", campos.get("cotacao_solicitacao_item_seq___" + seq[1]));
            childData.put("hist_cotacao_icmsst", campos.get("cotacao_icmsst___" + seq[1]));
            childData.put("hist_cotacao_desconto", campos.get("cotacao_desconto___" + seq[1]));
            childData.put("hist_cotacao_total_item", campos.get("cotacao_total_item___" + seq[1]));
            childData.put("hist_cotacao_ccusto_codigo", campos.get("cotacao_ccusto_codigo___" + seq[1]));
            childData.put("hist_cotacao_ccusto_nome", campos.get("cotacao_ccusto_nome___" + seq[1]));
            childData.put("hist_cotacao_childId", campos.get("cotacao_childId___" + seq[1]));
            childData.put("hist_cotacao_item_vencedor", campos.get("cotacao_item_vencedor___" + seq[1]));
            childData.put("hist_cotacao_prod_itemfamily", campos.get("cotacao_produto_itemfamily___" + seq[1]));
            childData.put("hist_cotacao_prod_itemcontrl", campos.get("cotacao_produto_itemcontrl___" + seq[1]));
            childData.put("hist_cotacao_produto_tipo", campos.get("cotacao_produto_tipo___" + seq[1]));
            childData.put("hist_cotacao_produto_codtb2fat", campos.get("cotacao_produto_codtb2fat___" + seq[1]));
            childData.put("hist_cotacao_produto_idprd", campos.get("cotacao_produto_idprd___" + seq[1]));
            childData.put("hist_cotacao_prod_observacoes", campos.get("cotacao_produto_observacoes___" + seq[1]));



            log.info("#(# ChildData");
            log.dir(childData);

            hAPI.addCardChild("tblItensCotacaoFornecedorHistorico", childData);

        }


    }
}
