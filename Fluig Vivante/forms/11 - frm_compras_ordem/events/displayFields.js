var globalForm;

function displayFields(form, customHTML) {

    globalForm = form;
    var out = "<script>";
    form.setValue("ordem_documentId", form.getDocumentId());


    var WKNumState = getValue("WKNumState");
    var FormMode = form.getFormMode(); //ADD: Criação do formulário MOD: Formulário em edição VIEW: Visualização do formulário
    var DocumentId = form.getDocumentId(); //Retorna o ID do documento (registro de formulário)
    var CardIndex = form.getCardIndex(); //Retorna o ID do formulário
    var Mobile = form.getMobile();
    var StatesHistory = getStatesHistory();

    WKNumState == 0 ? WKNumState=4 : false;

    var ativ_inicio = 4;
    var ativ_aprovSindico = 110;
    var ativ_aprovGerenteUnidade = 15;
    var ativ_aprovGerentePortfolio = 17;
    var ativ_aprovDiretorOperacional = 21;
    var ativ_aprovPresidente = 23;
    var ativ_aprovGerenteRH = 170;
    var ativ_aprovGerenteSESMET = 178;
    var ativ_aprovDiretorRH = 172;
    var ativ_correcao = 113;
    var ativ_tratamentoErro = 121;
    var ativ_elaboracao = 160;


    if(WKNumState == ativ_inicio){
        form.setValue("ordem_data",dataAtualFormatada());
        getUserFluig();
    } else if(WKNumState == ativ_elaboracao){
        getUserFluig();
    }

    form.setHidePrintLink(true);
    form.setShowDisabledFields(true);

    //Desabilita edição caso ativilidade não for a inicial, correção ou preparação

  

    if(WKNumState != ativ_inicio && WKNumState != ativ_correcao && WKNumState != ativ_tratamentoErro  && WKNumState != ativ_elaboracao ){

        
        out += "$('[data-btn-zoom-autocomplete]').hide();";
        out += "$('button').attr('disabled',true);";
        out += "$('#div_adicionaProduto').hide();";
        out += "$('.bootstrap-tagsinput').hide();";
        out += "$('#btnDetalheItem').attr('disabled',false);";
        setEnabled(form, false);

        out += "$('#tratamentoErro').attr('readonly',false);";
        out += "$('#btnIdentarXml').removeAttr('disabled');";

    }

    if (WKNumState != ativ_elaboracao){

        

    }

    if(WKNumState != ativ_tratamentoErro ){

     
       
        out += "$('#tratamentoErro').hide();";
        
    } 

    if (FormMode == "VIEW") {

        form.setShowDisabledFields(true);
        out += "$('[data-btn-zoom-autocomplete]').hide();";
        out += "$('button').attr('disabled',true);";
        out += "$('#div_adicionaProduto').hide();";
        out += "$('.bootstrap-tagsinput').hide();";
        out += "$('.btn_rateio').attr('disabled',false);";

    }

    //Habilita/Desabilita Botão Imprimir Ordem de Compra
    if (WKNumState != 9) {
     //   out += "$('#btnImprimirOrdem').hide();";
    } else {
        out += "$('#btnGerarRelatorioRM').attr('disabled',false);";
    }

    //Append no HTML do Formulário
    //Essas variaveis podem ser chamadas internamente no formulário;
    out += "var WKNumState = '" + WKNumState + "';";
    out += "var FormMode = '" + FormMode + "';";
    out += "var DocumentId = '" + DocumentId + "';";
    out += "var CardIndex = '" + CardIndex + "';";
    out += "var Mobile = " + Mobile + ";";
    out += "var FormMode = '" + FormMode + "';";
    out += "var StatesHistory = '" + StatesHistory + "';";

    out += "</script>";

    customHTML.append(out);


    
    /////////////////////////////////////////////////////////////////////

    if (WKNumState == ativ_aprovGerenteUnidade) {

        log.info("#*# SET STATUS");
        var indexes = form.getChildrenIndexes("tblItensOrdem");

        for (var i = 0; i < indexes.length; i++) {

            var status = verificaAprovacaoItem(indexes[i]);
            form.setValue("produto_status_aprovSindico___" + indexes[i], status);
        }
    }

    //////////////////////////////////////////////////////////////////////


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



function verificaAprovacaoItem(seq) {

    log.info("##$$0110 Chamou Verificação");

    var status = "";

    //Monta as constraints para consulta
    var constraints = new Array();
    log.info("##$$0110 seq parametro " + seq);

    constraints.push(DatasetFactory.createConstraint("ordem_processo_origem", getValue("WKNumProces"), getValue("WKNumProces"), ConstraintType.MUST));
    constraints.push(DatasetFactory.createConstraint("ordem_childID", seq, seq, ConstraintType.MUST));


    log.info("##$$1 Constraints")
    log.dir(constraints)
    //Define os campos para ordenação
    var sortingFields = new Array();

    //Busca o dataset
    var dataset = DatasetFactory.getDataset("frm_compras_aprovacao_sindico", null, constraints, sortingFields);

    log.info("##$$1 DATASET")
    log.dir(dataset)
    for (var i = 0; i < dataset.rowsCount; i++) {
        log.info("##$$1 dataset " + dataset.getValue(i, "status_aprovacao"));

        status = dataset.getValue(i, "status_aprovacao");
    }

    log.info("##0110 status" + status);
    return status;

}


function setEnabled(form, lEnable) {
    var hpForm = new java.util.HashMap();
    hpForm = form.getCardData();
    var it = hpForm.keySet().iterator();

    while (it.hasNext()) {
        var key = it.next();

        if(key != "integracao_xml"){
             form.setEnabled(key, lEnable);
        }
    }
}

function disableTableField(form, tableName, FieldId) {
	var indexes = form.getChildrenIndexes(tableName);

	for (var i = 0; i < indexes.length; i++) {
		form.setEnabled(FieldId + '___' + indexes[i], false);
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

  function getUserFluig(){

    var filterColleague = new java.util.HashMap();
        filterColleague.put("colleaguePK.colleagueId", getValue("WKUser"));
    var colleague = getDatasetValues('colleague', filterColleague);

    log.info("@)(# Colleague ");
    log.dir(colleague);
  
    globalForm.setValue("nome_solicitante",colleague.get(0).get("colleagueName"));
    globalForm.setValue("codigo_solicitante",getValue("WKUser"));


  
    var login=colleague.get(0).get("login");

    log.info("@)(# main ");
    log.dir(login);

    globalForm.setValue("codusuario_rm",getUserTotvsRM(login));

  
  }

  
function getUserTotvsRM(login){

    log.info("@)(# getUserTotvsRM ");
    log.info(login);

    var c1 = DatasetFactory.createConstraint("CODUSUARIO",login, login, ConstraintType.MUST);
    var constraints = new Array(c1);
    
    var usuario = DatasetFactory.getDataset("rm_consulta_usuario", null, constraints, null);
  
    log.info("@)(# usuario ");
    log.dir(usuario);


    log.info("@)(# usuario >>>>>>>> " + usuario.getValue(0,"CODUSUARIO"));
    
    return usuario.getValue(0,"CODUSUARIO");
   // globalForm.setValue("codusuario_rm",usuario.getValue(0,"CODUSUARIO"));
}