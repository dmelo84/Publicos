function beforeTaskSave(colleagueId, nextSequenceId, userList) {


    var processo = getValue("WKNumProces");
    var campos = hAPI.getCardData(processo);
    log.info("##$$$$ CARD");
    log.dir(campos);

    log.info("Idlog ##$$ beforeTaskSave \n Processo: " + getValue("WKNumProces") + "\n Atividade :" + getValue("WKNumState") + "\n CP003" +
        "\n Next " + nextSequenceId);

    var atividade =  parseInt(getValue("WKNumState"));

    log.info("Idlog ATIVIDADE ----> "+atividade);

    var atvGerenteUnidade = 15;
    var atvGerentePortfolio = 17;
    var atvDiretorOperacional = 21;
    var atvDiretorFinanceiro = 166;
    var atvPresidente = 23;
    var atvLiberacaoOrdem = 31;
	var atvAprovGerenteRH = 170;
	var atvAprovGerenteSESMET = 178;
	var atvAprovDiretorRH = 172;

    //updateTableChildIds("seq", "childId");

    if (nextSequenceId == atvGerenteUnidade ||
    		nextSequenceId == atvGerentePortfolio || 
    		nextSequenceId == atvDiretorOperacional || 
    		nextSequenceId == atvDiretorFinanceiro || 
    		nextSequenceId == atvPresidente ||
    		nextSequenceId == atvAprovGerenteRH ||
    		nextSequenceId == atvAprovGerenteSESMET ||
    		nextSequenceId == atvAprovDiretorRH){
        setApprovers(userList);
    }

    if (atividade == 0 || atividade == 4) {

        hAPI.setCardValue("ordem_numero", processo);

        //Atualiza ID's se executado atividade inicial
        log.info("Idlog updateTableChildIds");
        //updateTableChildIds("seq", "childId");
        //TODO 2019-05-09 > Comentei essa function porque estava quebrndo a integração via Central de Compras
    }
}

function setApprovers(userList) {
    log.info("#( entrou setApprovers");
    log.dir(userList);
    userList.clear();

    var proximoAprovador = "";

    var unidade_codigo = hAPI.getCardValue("unidade_codigo");
    var centroCusto    = hAPI.getCardValue("ccusto_codigo");
    var unidade        = hAPI.getCardValue("aprovado_gerente_unidade") == "on" ? true : false;
    var portfolio      = hAPI.getCardValue("aprovado_gerente_portfolio") == "on" ? true : false;
    var operacional    = hAPI.getCardValue("aprovado_diretor_operacional") == "on" ? true : false;
    var financeiro     = hAPI.getCardValue("aprovado_diretor_financeiro") == "on" ? true : false;
    var presidente     = hAPI.getCardValue("aprovado_presidente") == "on" ? true : false;
    var gerenteRH      = hAPI.getCardValue("aprovado_gerente_rh") == "on" ? true : false;
    var gerenteSESMET  = hAPI.getCardValue("aprovado_gerente_sesmet") == "on" ? true : false;
    var diretoRH       = hAPI.getCardValue("aprovado_diretor_rh") == "on" ? true : false;

    if (centroCustoRH()) {
    	
        if (!gerenteRH)
            proximoAprovador = "GERENTERH";

        if (gerenteRH && !diretoRH)
            proximoAprovador = "DIRETORRH";

        if (diretoRH && !presidente)
            proximoAprovador = "PRESIDENTE";
        
    } else if (centroCustoSESMET()) {
    	
        if (!gerenteSESMET)
            proximoAprovador = "GERENTSESMT";

        if (gerenteSESMET && !diretoRH)
            proximoAprovador = "DIRETORRH";

        if (diretoRH && !presidente)
            proximoAprovador = "PRESIDENTE";
        
    } else {
        if (!unidade)
            proximoAprovador = "UNIDADE";

        if (unidade && !portfolio)
            proximoAprovador = "PORTFOLIO";

        if (portfolio && !operacional)
            proximoAprovador = "DIRETOR";

        if (operacional && !financeiro)
            proximoAprovador = "DIRETORFIN";

        if (financeiro && !presidente)
            proximoAprovador = "PRESIDENTE";
    }
    
    log.info("#( proximoAprovador "+ proximoAprovador);
    log.info("#( centroCusto "+ centroCusto);

    var c1 = DatasetFactory.createConstraint("COD_UNIDADE", unidade_codigo, unidade_codigo, ConstraintType.MUST);
    var c2 = DatasetFactory.createConstraint(proximoAprovador, true, true, ConstraintType.MUST);

    var constraints = new Array(c1, c2);

    log.info("#( constraints ");
    log.dir(constraints);

//
//rm_consulta_centro_custo_usuario
    var approvers = DatasetFactory.getDataset("rm_consulta_usuario_aprovador_unidade", null,constraints, null);

    log.info("#( approvers ");
    log.dir(approvers);

    for (var i = 0; i < approvers.values.length; i++) {

        userList.add(approvers.getValue(i, "USER_CODE")); //TODO: DESCOMENTAR ESSA LINHA PARA AMBIENTE OFICIAL/TESTE USUÁRIO
       
    }

   // userList.add("felipe.louzada");//TODO:COMENTAR ESSA LINHA

    log.info("#( userList ");
    log.dir(userList);


    if (userList.size() == 0) {
        throw "\n Não foram encontrados aprovadores com escopo " + proximoAprovador + " para o centro de custo " + centroCusto + ".\n\n <strong>Entre em contato com a equipe de TI.</strong> \n\n Você poderá salvar a solicitação para enviar mais tarde.\n";
    };

    log.info("#( Aprovadores");
    log.dir(userList);

    //return userList;
}

function updateTableChildIds(masterFieldName, idFieldName) {

    var processo = getValue("WKNumProces");

    var campos = hAPI.getCardData(processo);
    log.dir(campos);

    var contador = campos.keySet().iterator();
    var count = 0;

    while (contador.hasNext()) {

        var id = contador.next();
        var str = masterFieldName + "___";

        if (id.indexOf(str) > -1) {
            var campo = campos.get(id);
            var seq = id.split("___");

            log.info("Idlog " + campo);
            log.info("Idlog " + idFieldName);
            log.info("Idlog " + masterFieldName);
            log.info("Idlog " + seq[1]);
            log.info("Idlog " + idFieldName + "___" + seq[1].toString() + "," + seq[1].toString());

            hAPI.setCardValue(idFieldName + "___" + seq[1].toString(), seq[1].toString());
            log.log("Idlog " +idFieldName + "___" + seq[1].toString() + " - " + seq[1].toString());

            count++;
        }
    }
}