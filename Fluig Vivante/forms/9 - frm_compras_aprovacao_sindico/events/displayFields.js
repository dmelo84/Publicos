var globalForm =""

function displayFields(form,customHTML){ 


    //Variáveis de trabalho
    globalForm = form;
    log.dir(form);
    var WKNumState = getValue("WKNumState");
    var FormMode = form.getFormMode(); //ADD: Criação do formulário MOD: Formulário em edição VIEW: Visualização do formulário
    var DocumentId = form.getDocumentId(); //Retorna o ID do documento (registro de formulário)
    var CardIndex = form.getCardIndex(); //Retorna o ID do formulário
    var Mobile = form.getMobile();
    var StatesHistory = getStatesHistory();
    var out = "<script>";

    WKNumState == 0 ? WKNumState = 4 : false ;

    var atividade_inicio = 4;

    getUserFluig();




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

function getUserFluig(){

    var filterColleague = new java.util.HashMap();
        filterColleague.put("colleaguePK.colleagueId", getValue("WKUser"));
    var colleague = getDatasetValues('colleague', filterColleague);

    globalForm.setValue("aprovador",colleague.get(0).get("colleagueName"));

    var email=colleague.get(0).get("mail");

    if(email == "felipe.louzada@noick.com.br"){
        getUserTotvsRM(colleague.get(0).get("mail"))
    }

}

function getUserTotvsRM(email){

    var c1 = DatasetFactory.createConstraint("EMAIL",email, email, ConstraintType.MUST);
    var constraints = new Array(c1);
    
    var usuario = DatasetFactory.getDataset("rm_consulta_usuario", null, constraints, null);
  
        
    globalForm.setValue("codusuario_solicitante",usuario.getValue(0,"CODUSUARIO"));
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
