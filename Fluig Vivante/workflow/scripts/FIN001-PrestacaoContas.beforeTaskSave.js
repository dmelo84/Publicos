function beforeTaskSave(colleagueId, nextSequenceId, userList) {


    var ativAprovacaoGestor = 15;
    var ativAprovacaoContabil = 22;
    var ativRetornadoGestor = 32;
    var ativRetornadoContabil = 29;

    log.info("X-----  beforeTaskSave" + getValue("WKNumProces"))
    
    var atividade = getValue('WKCurrentState');

    //Verifique se foi inserido anexo

    if (nextSequenceId == 91 || nextSequenceId == 15) {

        log.info("#### TESTE BEFORE TASK SAVE ####");
        var attachments = hAPI.listAttachments();
        var hasAttachment = false;

        for (var i = 0; i < attachments.size(); i++) {
            var attachment = attachments.get(i);
            // if (attachment.getDocumentDescription() == "fluig.pdf") {
            hasAttachment = true;
            //}
        }
        log.info("#### hasAttachment ####");
        log.info(hasAttachment);

        if (!hasAttachment) {
            throw "\n\n Nenhum anexo foi inserido. \nFavor anexar os comprovantes das respectivas despesas.";
        }
    }

    if (atividade == ativRetornadoGestor && getValue("WKCompletTask").equals("true") && nextSequenceId == ativAprovacaoGestor) {

        hAPI.setCardValue("justificativa_aprovador", "");



    }

    if (atividade == ativRetornadoContabil && getValue("WKCompletTask").equals("true") && nextSequenceId == ativAprovacaoContabil) {

        hAPI.setCardValue("justificativa_contabil", "");
    }

    if (atividade == ativAprovacaoGestor && getValue("WKCompletTask").equals("true") && nextSequenceId == ativAprovacaoContabil) {

        var txt = "Aprovado em " + dataAtualFormatada() + " por " + getNomeUsuario();
        var valor = hAPI.getCardValue("justificativa_aprovador");
        hAPI.setCardValue("justificativa_aprovador", txt + '\n' + valor);

    }

    if (atividade == ativAprovacaoContabil && getValue("WKCompletTask").equals("true") && nextSequenceId == 41) {

        var txt = "Aprovado em " + dataAtualFormatada() + " por " + getNomeUsuario();
        var valor = hAPI.getCardValue("justificativa_contabil");
        hAPI.setCardValue("justificativa_contabil", txt + '\n' + valor);

    }

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


function getNomeUsuario() {

    var filterColleague = new java.util.HashMap();
    filterColleague.put("colleaguePK.colleagueId", getValue("WKUser"));
    var colleague = getDatasetValues('colleague', filterColleague);

    return colleague.get(0).get("colleagueName");
}
