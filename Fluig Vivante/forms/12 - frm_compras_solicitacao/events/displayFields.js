var globalForm =""

function displayFields(form,customHTML){ 

    //enableCabecalho(form,false);
    
    //Variáveis de trabalho
    globalForm = form;

    var WKNumState      = getValue("WKNumState");
    var FormMode        = form.getFormMode(); //ADD: Criação do formulário MOD: Formulário em edição VIEW: Visualização do formulário
    var DocumentId      = form.getDocumentId(); //Retorna o ID do documento (registro de formulário)
    var CardIndex       = form.getCardIndex(); //Retorna o ID do formulário
    var Mobile          = form.getMobile();
    var StatesHistory   = getStatesHistory();

    form.setHidePrintLink(true);
    form.setShowDisabledFields(true);

    var out = "<script>";

    WKNumState == 0 ? WKNumState = 4 : false ;

    var atividade_inicio        = 4;
    var atividade_estimarPreco  = 32;
    var atividade_correcao      = 42;
    var atividade_aprovacao = 28


    if(WKNumState == atividade_inicio && FormMode=="ADD"){

        getUserFluig();
        globalForm.setValue("data_solicitacao",dataAtualFormatada());

        var now        = new java.util.Date();
        var formatDate = new java.text.SimpleDateFormat("yyyy-MM-dd");
        var dataAtual  = formatDate.format(now);
    
        globalForm.setValue("data_solicitacao_us",dataAtual);

    }

    if((WKNumState != atividade_inicio && WKNumState != atividade_correcao) || FormMode == "VIEW" ){
//
       
        out += "$('[data-btn-zoom-autocomplete]').each(function(){$(this).hide(); });";
        /*out += 'document.getElementById("fsIdentificacao").disabled = true;';
        out += 'document.getElementById("fsDadosEntrega").disabled = true;';*/
        enableCabecalho(form,false);
        out += 'document.getElementById("fsAddProduto").disabled = true;';
        out += "$('[data-produto-quantidade]').prop('readonly', true );";
        out += "$('[data-produto-observacoes]').prop('readonly', true );";
        
        out += "$('[data-btnDetalheItem]').attr('disabled',false);";
        out += "$('[data-btnRemoveItem]').attr('disabled',true);";
        out += "$('#div_adicionaProduto').hide();";

        

    }

    if(WKNumState == atividade_estimarPreco){

        out += "$('[data-produto-preco]').prop('readonly', false );";
        out += "$('[data-produto-quantidade]').prop('readonly', true );";
        out += "$('[data-produto-observacoes]').prop('readonly', true );";
        //out += 'document.getElementById("fsIdentificacao").disabled = true;';
        enableCabecalho(form, false);
        out += "$('[data-btnDetalheItem]').attr('disabled',true);";
        out += "$('[data-btnRemoveItem]').attr('disabled',true);";
        out += "$('#div_adicionaProduto').hide();";
        
       
    }

    if (WKNumState == atividade_aprovacao){

        
        out += "$('[data-btn-zoom-autocomplete]').each(function(){$(this).hide(); });";
        /*out += 'document.getElementById("fsIdentificacao").disabled = true;';
        out += 'document.getElementById("fsDadosEntrega").disabled = true;';*/
        enableCabecalho(form,false);
        out += 'document.getElementById("fsAddProduto").disabled = true;';
        out += "$('[data-produto-quantidade]').prop('readonly', true );";
        out += "$('[data-produto-observacoes]').prop('readonly', true );";
        
        out += "$('[data-btnDetalheItem]').attr('disabled',false);";
        out += "$('[data-btnRemoveItem]').attr('disabled',true);";
        out += "$('#div_adicionaProduto').hide();";

        out += "$('[data-btn-zoom-autocomplete=\"acUnidade\"]').hide();";
        
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
	
}


function enableCabecalho(form,isEnabled){

    /*Cabeçalho*/
    form.setEnabled("data_necessidade", isEnabled);
    form.setEnabled("tipo_solicitacao", isEnabled);
    form.setEnabled("empresa_codigo", isEnabled);
    form.setEnabled("empresa_nome", isEnabled);
    form.setEnabled("unidade_codigo", isEnabled);
    form.setEnabled("unidade_nome", isEnabled);
    form.setEnabled("contrato_codigo", isEnabled);
    form.setEnabled("contrato_descricao", isEnabled);
    form.setEnabled("ccusto_codigo", isEnabled);
    form.setEnabled("ccusto_nome", isEnabled);
    form.setEnabled("prioridade", isEnabled);
    form.setEnabled("finalidade_compra_codigo", isEnabled);
    form.setEnabled("finalidade_compra", isEnabled);
    /*Local Estoque*/
    form.setEnabled("local_estoque_codigo", isEnabled);
    form.setEnabled("local_estoque_nome", isEnabled);
    form.setEnabled("observacoes_capa", isEnabled);

}

function getUserFluig(){

    var filterColleague = new java.util.HashMap();
        filterColleague.put("colleaguePK.colleagueId", getValue("WKUser"));
    var colleague = getDatasetValues('colleague', filterColleague);

    globalForm.setValue("nome_solicitante",colleague.get(0).get("colleagueName"));
    globalForm.setValue("codusuario_solicitante",getValue("WKUser"));

    var email=colleague.get(0).get("login");

    getUserTotvsRM(colleague.get(0).get("login"))

}

function getUserTotvsRM(login){

    var c1 = DatasetFactory.createConstraint("CODUSUARIO",login, login, ConstraintType.MUST);

    var constraints = new Array(c1);
    var usuario = DatasetFactory.getDataset("rm_consulta_usuario", null, constraints, null);

    if(usuario.rowsCount > 0){
        globalForm.setValue("codusuario_rm",usuario.getValue(0,"CODUSUARIO"));
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



function setEnabled(form, lEnable) {
    var hpForm = new java.util.HashMap();
    hpForm = form.getCardData();
    var it = hpForm.keySet().iterator();

    while (it.hasNext()) {
        var key = it.next();
        form.setEnabled(key, lEnable);
    }
}

function disableTableField(form, tableName, FieldId,enabled) {
	var indexes = form.getChildrenIndexes(tableName);

	for (var i = 0; i < indexes.length; i++) {
		form.setEnabled(FieldId + '___' + indexes[i], enabled);
	}
}

function getStatesHistory() {
	var states = [];
	var constraints = [DatasetFactory.createConstraint("processHistoryPK.processInstanceId", getValue("WKNumProces"), getValue("WKNumProces"), ConstraintType.MUST)];
	var fields = ["stateSequence"];
	var order = ["processHistoryPK.movementSequence"];
	var dataset = DatasetFactory.getDataset("processHistory", fields, constraints, order);
	if (dataset != null && dataset.rowsCount > 0) {
		for(var i = 0; i < dataset.rowsCount; i++) {
			var state = new java.lang.String.valueOf(dataset.getValue(i, "stateSequence"));
			if (states.indexOf(state) == -1)
				states.push(state);
		}
	}
	return states;
}
