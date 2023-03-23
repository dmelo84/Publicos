function afterTaskSave(colleagueId,nextSequenceId,userList){

    var aprovacaoSindico = 91;
    var aprovacaoGestor = 15;
    var aprovacaoContabil = 22;
    var reprovado = 32;
    var aberta = 7;
    var liberada = 41;

    log.info("*** afterTaskSave FIN001" + nextSequenceId)



    //APROVAÇÃO SINDICO - PARA SINDICO
    if (nextSequenceId == aprovacaoSindico && getValue("WKCompletTask").equals("true")) {

        var assunto = "Aprovação Síndico";
        var msgInicial = "Esta solicitação está pendente de sua aprovação como Síndico do Processo. Acesse o portal do Fluig ou aplicativo Approval para registrar a decisão."
        var msgFinal = "";

        //Envia e-mail para os aprovadores
        var destinatarios = userList;

        SendMail(assunto, destinatarios, msgInicial, msgFinal, nextSequenceId);

    }

    //APROVAÇÃO SINDICO - PARA FAVORECIDO
    if (nextSequenceId == aprovacaoSindico && getValue("WKCompletTask").equals("true")) {

        var assunto = "Aprovação Síndico";
        var msgInicial = "A Prestação de Contas está aguardando a aprovação do síndico do processo."
        var msgFinal = "";

        if (hAPI.getCardValue("email_favorecido")) {
            destinatarios.add(hAPI.getCardValue("email_favorecido"));
        }

        SendMail(assunto, destinatarios, msgInicial, msgFinal, nextSequenceId);

    }

    //APROVAÇÃO GESTOR
    if (nextSequenceId == aprovacaoGestor && getValue("WKCompletTask").equals("true")) {

        var assunto = "Aprovação";
        var msgInicial = "Esta solicitação está pendente de sua aprovação. Acesse o portal do Fluig ou aplicativo Approval para registrar a decisão."
        var msgFinal = "";

        //Envia e-mail para os aprovadores
        var destinatarios = userList;


        SendMail(assunto, destinatarios, msgInicial, msgFinal, nextSequenceId);

    }

    if (nextSequenceId == aprovacaoGestor && getValue("WKCompletTask").equals("true")) {

        var assunto = "Aprovação";
        var msgInicial = "A Prestação de Contas está aguardando a aprovação do gestor responsável."
        var msgFinal = "";


        if (hAPI.getCardValue("email_favorecido")) {
            var destinatarios = new Array();
            destinatarios.add(hAPI.getCardValue("email_favorecido"));
            SendMail(assunto, destinatarios, msgInicial, msgFinal, nextSequenceId);
        }

        

    }

    //APROVAÇÃO CONTABIL
    if (nextSequenceId == aprovacaoContabil && getValue("WKCompletTask").equals("true")) {

        var assunto = "Aprovação Contábil";
        var msgInicial = "Esta solicitação está pendente de sua aprovação. Acesse o portal do Fluig ou aplicativo Approval para registrar a decisão."
        var msgFinal = "";

        //Envia e-mail para os aprovadores
        var destinatarios = userList;

     

        SendMail(assunto, destinatarios, msgInicial, msgFinal, nextSequenceId);

    }

    if (nextSequenceId == aprovacaoContabil && getValue("WKCompletTask").equals("true")) {

        var assunto = "Aprovação Contábil";
        var msgInicial = "A Prestação de Contas está aguardando a aprovação da área contábil."
        var msgFinal = "";


        if (hAPI.getCardValue("email_favorecido")) {
            destinatarios.add(hAPI.getCardValue("email_favorecido"));
        }

        SendMail(assunto, destinatarios, msgInicial, msgFinal, nextSequenceId);

    }

    //REPROVADO
    if (nextSequenceId == reprovado && getValue("WKCompletTask").equals("true")) {

        var assunto = "REPROVADA";
        var msgInicial = "Esta solicitação foi reprovada. Acesse a solicitação para verificar o motivo e realize o ajuste ou cancelamento."
        var msgFinal = "";

        //Envia e-mail para os aprovadores
        var destinatarios = userList;

        if (hAPI.getCardValue("email_favorecido")) {
            destinatarios.add(hAPI.getCardValue("email_favorecido"));
        }

        SendMail(assunto, destinatarios, msgInicial, msgFinal, nextSequenceId);

    }

    //ABERTA
    if (nextSequenceId == aberta && getValue("WKCompletTask").equals("true")) {

        var assunto = "Pendente Fechamento";
        var msgInicial = "Esta solicitação foi aberta e está aguardando o seu fechamento para início do processo de aprovação."
        var msgFinal = "";

        //Envia e-mail para os aprovadores
        var destinatarios = userList;

        if (hAPI.getCardValue("email_favorecido")) {
            destinatarios.add(hAPI.getCardValue("email_favorecido"));
        }

        SendMail(assunto, destinatarios, msgInicial, msgFinal, nextSequenceId);

    }

    //LIBERADA
    if (nextSequenceId == liberada && getValue("WKCompletTask").equals("true")) {

        var assunto = "Liberada";
        var msgInicial = "Sua solicitação foi aprovada pelo gestor responsável e liberada pela área contábil."
        var msgFinal = "";

     
      

        if (hAPI.getCardValue("email_favorecido")) {
            destinatarios.add(hAPI.getCardValue("email_favorecido"));
        }

        SendMail(assunto, destinatarios, msgInicial, msgFinal, nextSequenceId);

    }

    //NOTIFICA FISCAL, PROBLEMA VALIDACAO DOCUMENTOS
    if (nextSequenceId == aprovacaoGestor && getValue("WKCompletTask").equals("true") && hAPI.getCardValue("notificarValidacaoDocumento") == "S") {

        var assunto = "DOCUMENTO FISCAL JÁ UTILIZADO";
        var msgInicial = "<strong>DOCUMENTO FISCAL INFORMADO JÁ FOI UTILIZADO EM OUTROS LANÇAMENTOS.</strong> \n" + hAPI.getCardValue("validacaoDocumentoMsg");
        var msgFinal = "";

        var destinatarios = new java.util.ArrayList();

            destinatarios.add('tsena@vivante.com.br');
            destinatarios.add('contabilidade@vivante.com.br');
            destinatarios.add('cbenevides@vivante.com.br');

        SendMail(assunto, destinatarios, msgInicial, msgFinal, nextSequenceId);

    }
    
}
