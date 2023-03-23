var globalForm = "";

function displayFields(form, customHTML) {

    globalForm = form;
    var WKNumProces = getValue("WKNumProces")
    var WKNumState = getValue("WKNumState");
    var FormMode = form.getFormMode(); //ADD: Criação do formulário MOD: Formulário em edição VIEW: Visualização do formulário
    var DocumentId = form.getDocumentId(); //Retorna o ID do documento (registro de formulário)
    var CardIndex = form.getCardIndex(); //Retorna o ID do formulário
    var Mobile = form.getMobile();
    var StatesHistory = getStatesHistory() || "";
    var nomeUsuario = getNomeUsuario();

    var out = "<script>";



    //Append no HTML do Formulário
    //Essas variaveis podem ser chamadas internamente no formulário;
    out += "var WKNumState = '" + WKNumState + "';";
    out += "var FormMode = '" + FormMode + "';";
    out += "var DocumentId = '" + DocumentId + "';";
    out += "var CardIndex = '" + CardIndex + "';";
    out += "var Mobile = " + Mobile + ";";
    out += "var StatesHistory = '" + StatesHistory + "';";
    out += "var nomeUsuario = '" + nomeUsuario + "';";
    out += "var WKNumProces = '" + WKNumProces + "';";

    form.setHidePrintLink(true);

    var atividade_inicio = 4;
    var ativAprovacaoGestor = 15;
    var ativAprovacaoPortfolio = 17;
    var ativAprovacaoFinanceira = 36;
    var ativAprovacaoContabil = 22;

    var ativRelatorioPendente = 7;
    var ativRetornadoGestor = 32;
    var ativRetornadoContabil = 29;
    var ativRetornadoFinanceiro = 39;
    var ativRetornadoPortfolio = 55;
    var ativEnviarComprovantes = 88;
    var ativAprovacaoSindicos = 91;

    var atividade_erroIntegracao = 51;


    log.info("@@ State" + StatesHistory);


    //ativAprovacaoContabil
    if (StatesHistory != "") {
        if (StatesHistory.toString().match(/,22/)) {
            out += "$('#divPainelParecer').css('display','');";
            out += "$('#divParecerContabil').css('display','');";
        }

        //ativAprovacaoGestor
        if (StatesHistory.toString().match(/,15/)) {
            out += "$('#divPainelParecer').css('display','');";
            out += "$('#divParecerAprovador').css('display','');";
        }

        if (StatesHistory.toString().match(/,15/) && !Mobile) {
            out += "$('#DivImprimirRelatorio').css('display','');";

        }
    }

    WKNumState == 0 ? WKNumState = 4 : false;

    if (WKNumState == atividade_inicio && FormMode == "ADD") {
        getUserFluig();
        globalForm.setValue("data_emissao", dataAtualFormatada());

    }

    if (WKNumState != atividade_inicio || FormMode == "VIEW") {
        form.setShowDisabledFields(true);

        form.setEnabled("parecer_aprovador", false);
        form.setEnabled("justificativa_aprovador", false);
        form.setEnabled("parecer_contabil", false);
        form.setEnabled("justificativa_contabil", false);



        // setEnabled(form,false);

        form.setEnabled("empresa_codigo", false);
        form.setEnabled("empresa_nome", false);
        form.setEnabled("unidade_codigo", false);
        form.setEnabled("unidade_nome", false);
        form.setEnabled("ccusto_codigo", false);
        form.setEnabled("ccusto_nome", false);

        form.setEnabled("favorecido_codigo", false);
        form.setEnabled("favorecido_nome", false);
        form.setEnabled("finalidade", false);
        form.setEnabled("ccusto_nome", false);


        form.setEnabled("periodo_inicial", false);
        form.setEnabled("periodo_final", false);
        form.setEnabled("recurso", false);

        disableTableField(form, "tblItemDespesa", "valor_unitario");

        out += "$('[data-btn-zoom-autocomplete]').each(function(){$(this).hide(); });";


    }

    if (WKNumState == ativRelatorioPendente ||
        WKNumState == ativRetornadoGestor ||
        WKNumState == ativRetornadoPortfolio) { }


    if (WKNumState == ativRetornadoContabil || WKNumState == ativRetornadoFinanceiro) {

        form.setEnabled("status_relatorio", false);
        disableTable(form, "tblItemDespesa");
        out += "$('button').attr('disabled',true);";
    }

    if (WKNumState == ativEnviarComprovantes) {

        form.setEnabled("status_relatorio", false);
        form.setEnabled("justificativa_aprovador", false);
        form.setEnabled("justificativa_contabil", false);
        disableTable(form, "tblItemDespesa");
        //out += "$('button').not('#btnImprimir').attr('disabled',true);";


    }


    if (WKNumState == ativAprovacaoGestor || WKNumState == ativAprovacaoSindicos) {
        disableTable(form, "tblItemDespesa");
        form.setEnabled("parecer_aprovador", true);
        form.setEnabled("status_relatorio", false);
        form.setEnabled("justificativa_aprovador", true);
        out += "$('button').attr('disabled',true);";


    }




    if (WKNumState == ativAprovacaoContabil) {
        disableTable(form, "tblItemDespesa");
        form.setEnabled("parecer_contabil", true);
        form.setEnabled("status_relatorio", false);
        form.setEnabled("justificativa_contabil", true);
        out += "$('button').attr('disabled',true);";


    }

    if (WKNumState == atividade_inicio) {

        form.setEnabled("parecer_aprovador", false);
        form.setEnabled("justificativa_aprovador", false);
        form.setEnabled("parecer_contabil", false);
        form.setEnabled("justificativa_contabil", false);
        form.setEnabled("parecer_financeiro", false);
        form.setEnabled("justificativa_financeiro", false);

    }


    if (WKNumState == atividade_erroIntegracao) {

        out += "$('#divErroIntegracao').css('display','');";
    }

    out += "$('[data-btn-imprimir]').attr('disabled',false);";

    out += "</script>";

    customHTML.append(out);
}

function getStatesHistory() {
    var states = [];
    var constraints = [DatasetFactory.createConstraint("processHistoryPK.processInstanceId", getValue("WKNumProces"), getValue("WKNumProces"), ConstraintType.MUST)];
    var fields = ["stateSequence"];
    var order = ["processHistoryPK.movementSequence"];
    var dataset = DatasetFactory.getDataset("processHistory", fields, constraints, order);
    if (dataset != null && dataset.rowsCount > 0) {
        for (var i = 0; i < dataset.rowsCount; i++) {
            var state = new java.lang.String.valueOf(dataset.getValue(i, "stateSequence"));
            if (states.indexOf(state) == -1)
                states.push(state);
        }
    }
    return states;
}

function getNomeUsuario() {

    var filterColleague = new java.util.HashMap();
    filterColleague.put("colleaguePK.colleagueId", getValue("WKUser"));
    var colleague = getDatasetValues('colleague', filterColleague);

    return colleague.get(0).get("colleagueName");
}

function getUserFluig() {

    var filterColleague = new java.util.HashMap();
    filterColleague.put("colleaguePK.colleagueId", getValue("WKUser"));
    var colleague = getDatasetValues('colleague', filterColleague);

    globalForm.setValue("solicitante", colleague.get(0).get("colleagueName"));
    globalForm.setValue("codusuario_solicitante", getValue("WKUser"));
    globalForm.setValue("login_solicitante", colleague.get(0).get("login"));

    var email = colleague.get(0).get("mail");

    getUserTotvsRM(colleague.get(0).get("mail"));
}

function getUserTotvsRM(email) {

    var c1 = DatasetFactory.createConstraint("EMAIL", email, email, ConstraintType.MUST);
    var constraints = new Array(c1);

    var usuario = DatasetFactory.getDataset("rm_consulta_usuario", null, constraints, null);


    globalForm.setValue("codusuario_rm", usuario.getValue(0, "CODUSUARIO"));
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

function setEnabled(form, lEnable) {
    var hpForm = new java.util.HashMap();
    hpForm = form.getCardData();
    var it = hpForm.keySet().iterator();

    while (it.hasNext()) {
        var key = it.next();
        form.setEnabled(key, lEnable);
    }
}

function disableTableField(form, tableName, FieldId) {
    var indexes = form.getChildrenIndexes(tableName);

    for (var i = 0; i < indexes.length; i++) {
        form.setEnabled(FieldId + '___' + indexes[i], false);
    }
}

function disableTable(form, tableName) {
    var indexes = form.getChildrenFromTable(tableName);

    log.info("ROOROO");
    log.info(tableName);

    var hpForm = new java.util.HashMap();
    hpForm = indexes;
    var it = hpForm.keySet().iterator();

    while (it.hasNext()) {
        var key = it.next();
        log.info(key);
        // disableTableField(form, tableName, key)
        if (!key.match(/tipo_despesa/))
            form.setEnabled(key, false);

    }




}