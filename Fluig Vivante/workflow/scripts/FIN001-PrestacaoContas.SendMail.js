function SendMail(assunto, userList, msgInicial, msgFinal, atividade){

    var processo = getValue("WKNumProces").toString();
    log.info("#$ Send mail processo " + processo)
    log.info("#$ destinatarios ")
    log.dir(userList)

    try {

        //Monta mapa com parâmetros do template
        var parametros = new java.util.HashMap();
        var subject = "[WF " + processo + "] - FIN001-Prestação de Contas - "+hAPI.getCardValue("nome_favorecido");
        
        //Assunto do e-mail
        if (assunto != "") {
            subject += " | " + assunto;
        }

        parametros.put("subject", subject);
        parametros.put("MSGINICIAL", msgInicial);
        parametros.put("MSGFINAL", msgFinal);

        /*Informações Cabeçalho Prestação*/

        parametros.put("numProcesso", processo);
        parametros.put("nome_favorecido", hAPI.getCardValue("favorecido_nome"));
        parametros.put("descricao_finalidade", hAPI.getCardValue("descricao_finalidade"));
        parametros.put("valor_total_despesas", hAPI.getCardValue("valor_total_despesas"));
        parametros.put("data_emissao", hAPI.getCardValue("data_emissao"));
        parametros.put("periodo_inicial", convertDate(hAPI.getCardValue("periodo_inicial")));
        parametros.put("periodo_final", convertDate(hAPI.getCardValue("periodo_final")));
        parametros.put("solicitante", hAPI.getCardValue("solicitante"));
        parametros.put("empresa_nome", hAPI.getCardValue("empresa_nome"));
        parametros.put("data_emissao", hAPI.getCardValue("data_emissao"));
        parametros.put("unidade_nome", hAPI.getCardValue("unidade_nome"));
        parametros.put("ccusto_nome", hAPI.getCardValue("ccusto_nome"));

        /*Despesas*/

        var despesasTableHTML = getDespesas();

        parametros.put("TBLDESPESAS", despesasTableHTML);


        var destinatarios = new java.util.ArrayList();

        destinatarios = userList;
       // destinatarios.add("patrick.santos@noick.com.br") //SOMENTE AMBIENTE DE TESTE
       // destinatarios.add("felipe.louzada@noick.com.br")

        var notificacao = notifier.notify("fluigadmin", "tplPrestacaoContas", parametros, destinatarios, "text/html");

    } catch (error) {

        log.info("##** Erro no envio de email processo " + processo);
        log.info(e);
        
    }

}

function getDespesas(){

    var processo = getValue("WKNumProces");
    var campos = hAPI.getCardData(processo);
    var retorno = "";

    var contador = campos.keySet().iterator();
    while (contador.hasNext()) {

        var id = contador.next();

        if (id.match(/seq___/)) { // 

            var campo = campos.get(id);
            var id = id.split("___")[1];

            var seq = campos.get("seq___" + id);
            var data_despesa = convertDate(campos.get("data_despesa___" + id));
            var despesa_descricao = campos.get("despesa_descricao___" + id);
            var quantidade = campos.get("quantidade___" + id);
            var valor_unitario = campos.get("valor_unitario___" + id);
            var valor_despesa = campos.get("valor_despesa___" + id);



            retorno += "<tr>";
            retorno += "    <td>" + seq+"</td>";
            retorno += "    <td>" + data_despesa+"</td>";
            retorno += "    <td>" + despesa_descricao+"</td>";
            retorno += "    <td style=\"text-align: right\">" + quantidade+"</td>";
            retorno += "    <td style=\"text-align: right\">" + valor_unitario+"</td>";
            retorno += "    <td style=\"text-align: right\">" + valor_despesa+"</td>";
            retorno += "</tr>";

        }
    }


    return retorno;

}

function convertDate(date){

    var dateArr = date.split("-");
    return dateArr[2] + "/"+ dateArr[1] + "/" +dateArr[0];

}