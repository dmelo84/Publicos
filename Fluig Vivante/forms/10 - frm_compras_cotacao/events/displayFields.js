var globalForm;

function displayFields(form,customHTML){

  log.info("DISP: Inicio");
  //Variáveis de trabalho
  globalForm = form;
  log.dir(form);
  var WKNumProces = getValue('WKNumProces');
  var WKNumState = getValue("WKNumState");
  var FormMode = form.getFormMode(); //ADD: Criação do formulário MOD: Formulário em edição VIEW: Visualização do formulário
  var DocumentId = form.getDocumentId(); //Retorna o ID do documento (registro de formulário)
  var CardIndex = form.getCardIndex(); //Retorna o ID do formulário
  var Mobile = form.getMobile();
  var StatesHistory = getStatesHistory();
  var out = "<script>";


  if(FormMode == "VIEW"){

    form.setShowDisabledFields(true);
    out += "$('[data-btn-zoom-autocomplete]').hide();";
    out += "$('button').attr('disabled',true);";


}

  WKNumState == 0 ? WKNumState = 4 : "";

  var atividade_inicio = 4;
  var atividade_registro_preco = 15;
  var atividade_escolha_vencedor = 64;
  var atividade_aprovacao_vencedor = 23;
  var atividade_negociacao = 67;
  var atividade_preparacao = 81;
  var atividade_modificar = 95
 
  log.info("@#Display")

  log.info(WKNumState)
  log.info(atividade_inicio)

  //
  if (WKNumState != atividade_inicio){

    log.info("@#Oculta Btn")

    out += "$(\"[data-btn-zoom-autocomplete='acEmpresa']\").hide();"
    out += "$(\"[data-btn-zoom-autocomplete='acFilial']\").hide();"


  }


if (WKNumState == atividade_inicio || WKNumState == atividade_preparacao) {

  getUserFluig();
  form.setValue("data_cotacao",dataAtualFormatada());

}

  if (WKNumState != atividade_inicio && WKNumState != atividade_preparacao && WKNumState != atividade_modificar ){


  
  form.setVisibleById("divItensCotacao", false);
  form.setVisibleById("divLocalizarFornecedor", false);
  form.setVisibleById("divIncluirSolicitacoes", false);

  form.setEnabled("data_limite", false);
  form.setEnabled("observacoes", false);

  form.setEnabled("empresa_nome", false);
  form.setEnabled("empresa_codigo", false);

  form.setEnabled("unidade_nome", false);
  form.setEnabled("unidade_codigo", false);

  out += "$('[data-tipo-cotacao]').prop('disabled',true);"; //Desabilita Remover Troca Tipo Cotacao
  out += "$('[data-btn-remover-item-cotacao]').prop('disabled',true);"; //Desabilita Remover itens da Cotação
  out += "$('[data-btn-remover-fornecedor]').prop('disabled',true);"; //Desabilita Remover Fornecedores da Cotação
  

}

if (form.getValue("emElaboracao")=="S"){

    form.setEnabled("empresa_nome", false);
    form.setEnabled("empresa_codigo", false);

  form.setEnabled("filial_codigo", false);
  form.setEnabled("filial_nome", false);

  }

  //Append no HTML do Formulário
  //Essas variaveis podem ser chamadas internamente no formulário;
  out += "var WKNumState = '" + WKNumState + "';";
  out += "var WKNumProces = '" + WKNumProces + "';";
  out += "var FormMode = '" + FormMode + "';";
  out += "var DocumentId = '" + DocumentId + "';";
  out += "var CardIndex = '" + CardIndex + "';";
  out += "var Mobile = " + Mobile + ";";
  out += "var FormMode = '" + FormMode + "';";
  out += "var StatesHistory = '" + StatesHistory + "';";

  out += "</script>";

customHTML.append(out);


}

function getUserFluig(){

  var filterColleague = new java.util.HashMap();
      filterColleague.put("colleaguePK.colleagueId", getValue("WKUser"));
  var colleague = getDatasetValues('colleague', filterColleague);

  globalForm.setValue("nome_comprador",colleague.get(0).get("colleagueName"));
  globalForm.setValue("codusuario_solicitante",getValue("WKUser"));

  log.info("#@0  getUserFluig colleague.get(0).get(\"mail\")")
  log.info(colleague.get(0).get("mail"))
  globalForm.setValue("codusuario_rm", getValue("WKUser"));
  
  //getUserTotvsRM(getValue("WKUser"))

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
