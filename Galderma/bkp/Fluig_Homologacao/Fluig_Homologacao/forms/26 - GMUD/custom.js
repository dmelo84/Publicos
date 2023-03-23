/*
* Versão 1.0 
* Dev: Evaldo Maciel - evaldomaciel17@gmail.com
*/

/* Atividades */
var zero = 0;
var inicio = 4;

$(document).ready(function () {

	atividade = getAtividade();

	//$("#responsavel").val("admin");

	console.log("documento carregado com sucesso");

	$("input[name^='aprova1e2']").on('change', function () {
		console.log("mudou");
		verificacaoAprova1e2();
	});

	$("input[name^='aprova3e4']").on('change', function () {
		console.log("mudou");
		verificacaoAprova3e4();
	});

	$("input[name^='aprovComite']").on('change', function () {
		console.log("mudou");
		verificacaoAprovComite();
	});

	$("input[name^='aprovTestes']").on('change', function () {
		console.log("mudou");
		verificacaoAprovTestes();
	});

	$("input[name^='aprovTestesComite']").on('change', function () {
		console.log("mudou");
		verificacaoAprovTestesComite();
	});

	$("input[name^='aprovTestesComite']").on('change', function () {
		console.log("mudou");
		verificacaoAprovTestesComite();
	});

	$("input[name^='aprovDeploy']").on('change', function () {
		console.log("mudou");
		verificacaoAprovDeploy();
	});

	$("input[name^='tipoProposta']").on('change', function () {
		verificacaoTipoProposta();
	});

	if (atividade == inicio || atividade == zero) {
		let dataSol = getData();
		let autor = getUserName();

		$("#solicitante").on('change', function () {
			var responsavel = verificaSolicitante();
			$("#responsavel").val(responsavel);
			$("#solicitanteId").val(responsavel);
			var solicitante = getUser();
			findManager(responsavel);
			getGMUDManager();
		});

		$("#autor").val(autor);
		$(".autorTexto").text(autor);

		var dataForm = getDataForm();
		let numFormularios = numFormulario(dataForm);

		$("#numFormulario").val(numFormularios);
		$(".numFormularioTexto").text(numFormularios);
		inicializarAutoComplete("#solicitante");
	}

	if (atividade == 5) {
	}

	if (FORM_MODE == "MOD" || FORM_MODE == "ADD") {
		let dataSol = FLUIGC.calendar("#dataSol");
		dataSol.setDate(new Date());

		$("#btnAddTeste").on("click", function () {
			console.log("Adicionou teste");
			adicionaTeste();
		});

	}

	if (atividade == 31) {
		setInterval(() => {
			var resposavel = usuariosTeste();
			$("#responsavel").val(resposavel);
		}, 1000);
	}

	if (atividade == 44) {
		setInterval(() => {
			verificarUsuarioTeste();
		}, 1000);
	}

	let autor = $("#autor").val();
	let numFormularios = $("#numFormulario").val();
	$(".numFormularioTexto").text(numFormularios);
	$(".autorTexto").text(autor);

	setTimeout(() => {
		autocompleteCargo("#cargo");
		autocompleteDepartamento("#departamento");
	}, 1000);

	if (atividade == 25) {
		let dataAprovProd = FLUIGC.calendar("#dataAprovProd");
		dataAprovProd.setDate(new Date());
		var responsavel = verificaSolicitante();
		$("#responsavel").val("Pool:Role:res_erp_gmud");
	}

	if (atividade == 109) {
		var responsavel = verificaSolicitante();
		$("#responsavel").val(responsavel);
	}

	// Aprovação do gerente TI gmud
	if (atividade == 33 && FORM_MODE == "MOD") {
		$("[name=aprovComite]:checked").prop("checked", false);
		$("#aceiteProdGerenteTI").val(getUserName());
		$("#aceiteProdGerenteTIData").val(getData("aprovacao"));
	}

	// Aprovação de GO LIVE - Lider da sustentação 
	if (atividade == 25 && FORM_MODE == "MOD") {
		$("#aceiteProdRespSustERP").val(getUserName());
		$("#aceiteProdRespSustERPData").val(getData("aprovacao"));
	}

	// Validação do deploy - gerente e solicitante 
	if (atividade == 91 && FORM_MODE == "MOD") {
		if (getUser() == $("#gerente").val()) {
			$("#aceiteProdRespAreaSol").val(getUserName());
			$("#aceiteProdRespAreaSolData").val(getData("aprovacao"));
		} else {
			$("#aceiteProdRespSol").val(getUserName());
			$("#aceiteProdRespSolData").val(getData("aprovacao"));
		}
	}

	// Finaliza e documenta
	if (atividade == 96 && FORM_MODE == "MOD") {
		$("#aceiteProdRespERP").val(getUserName());
		$("#aceiteProdRespERPData").val(getData("aprovacao"));
	}

	if (FORM_MODE != "VIEW") {
		setInterval(() => {
			$(".tabAceite").hide();
			$(".tabData").hide();
		}, 1000);
	}

	if (FORM_MODE == "VIEW") {
		$("label").removeClass("required");
		$("label").addClass("bold");
	}
});

function adicionaTeste() {
	let idTeste = wdkAddChild("planoDeTesteTabela");
	inicializarAutoComplete("#tabUsuarioChave___" + idTeste);
	let tabData = FLUIGC.calendar("#tabData___" + idTeste);
	$("#tabData___" + idTeste).attr("readonly", true);
	$("#tabAceite___" + idTeste).attr("readonly", true);



	console.log(tabData);
}


function autocompleteDepartamento(nomeDoCampo) {
	var item = [];
	if (item[nomeDoCampo] !== undefined) {
		item[nomeDoCampo].destroy();
		item[nomeDoCampo] = undefined;
	}
	var campos = ["groupDescription", "groupPK.groupId"];
	var operacoes = DatasetFactory.getDataset("group", campos, null, null).values;
	funcTemp = [];
	for (i = 0; i < operacoes.length; i++) {
		funcTemp.push(operacoes[i]["groupDescription"]);
	}

	item[nomeDoCampo] = FLUIGC.autocomplete(nomeDoCampo, {
		source: substringMatcher(funcTemp),
		name: 'ID',
		minLength: 1,
		displayKey: 'description',
		allowDuplicates: false,
		hint: true,
		tagClass: 'tag-gray',
		type: 'autocomplete'
	});
}

function autocompleteCargo(nomeDoCampo) {
	var item = [];
	if (item[nomeDoCampo] !== undefined) {
		item[nomeDoCampo].destroy();
		item[nomeDoCampo] = undefined;
	}
	var campos = ["roleDescription", "workflowRolePK.roleId"];
	var operacoes = DatasetFactory.getDataset("workflowRole", campos, null, null).values;
	funcTemp = [];
	for (i = 0; i < operacoes.length; i++) {
		funcTemp.push(operacoes[i]["roleDescription"]);
	}

	item[nomeDoCampo] = FLUIGC.autocomplete(nomeDoCampo, {
		source: substringMatcher(funcTemp),
		name: 'ID',
		minLength: 1,
		displayKey: 'description',
		allowDuplicates: false,
		hint: true,
		tagClass: 'tag-gray',
		type: 'autocomplete'
	});
}

function usuariosTeste() {

	var listaDeUsuarios = new Array();
	var usuarios = $("input[name^='tabUsuarioChave___']");
	usuarios[0].name;

	;

	for (let i = 0; i < usuarios.length; i++) {
		usuarios[0].name;
		listaDeUsuarios.push($("#" + usuarios[i].name).val().split("|")[0]);

	}
	var listafinal = listaDeUsuarios.join();
	console.log(listaDeUsuarios.join());
	return listafinal;
}

function inicializarAutoComplete(nomeDoCampo) {
	var operacoesAutoComplete = [];
	if (operacoesAutoComplete[nomeDoCampo] !== undefined) {
		operacoesAutoComplete[nomeDoCampo].destroy();
		operacoesAutoComplete[nomeDoCampo] = undefined;
	}
	var campos = ["colleagueName", "colleaguePK.colleagueId"];
	var operacoes = DatasetFactory.getDataset("colleague", campos, null, null).values;
	funcTemp = [];
	for (i = 0; i < operacoes.length; i++) {
		funcTemp.push(operacoes[i]["colleaguePK.colleagueId"] + "|" + operacoes[i]["colleagueName"]);
	}

	operacoesAutoComplete[nomeDoCampo] = FLUIGC.autocomplete(nomeDoCampo, {
		source: substringMatcher(funcTemp),
		name: 'funcionarios',
		minLength: 1,
		displayKey: 'description',
		allowDuplicates: false,
		hint: true,
		tagClass: 'tag-gray',
		type: 'autocomplete'
	});
}

function substringMatcher(strs) {
	return function findMatches(q, cb) {
		var matches, substrRegex;
		matches = [];
		substrRegex = new RegExp(q, 'i');
		$.each(strs, function (i, str) { if (substrRegex.test(str)) { matches.push({ description: str }); } }); cb(matches);
	};
}

function numFormulario(data) {

	var numForm = String();

	var constraintTigmund1 = DatasetFactory.createConstraint('dataSol', data, data, ConstraintType.MUST, true);
	var constraintTigmund2 = DatasetFactory.createConstraint('metadata#active', 'true', 'true', ConstraintType.MUST);
	var datasetTigmund = DatasetFactory.getDataset('tigmud', null, new Array(constraintTigmund1, constraintTigmund2), null).values;
	datasetTigmund;
	if (datasetTigmund != undefined && datasetTigmund != null) {
		numForm = data + "_00" + String(datasetTigmund.length + 1);
	} else {
		numForm = data + String("_001")
	}
	console.log(numForm);
	return numForm;

}

function verificacaoAprova1e2() {
	if ($("[name=aprova1e2]:checked").val() == 'sim') {
		// $('#aprova1e2Just').attr('readonly', 'true');
		console.log("Sim");
	}

	if ($("[name=aprova1e2]:checked").val() == 'nao') {
		console.log("Não");
		// $('#aprova1e2Just').removeAttr('readonly');
	}
}

function verificacaoAprova3e4() {
	if ($("[name=aprova3e4]:checked").val() == 'sim') {
		// $('#aprova3e4Just').attr('readonly', 'true');
		console.log("Sim");
	}

	if ($("[name=aprova3e4]:checked").val() == 'nao') {
		console.log("Não");
		// $('#aprova3e4Just').removeAttr('readonly');
	}
}

function verificacaoAprovComite() {
	if ($("[name=aprovComite]:checked").val() == 'sim') {
		// $('#aprovComiteJust').attr('readonly', 'true');
		console.log("Sim");
	}

	if ($("[name=aprovComite]:checked").val() == 'nao') {
		console.log("Não");
		// $('#aprovComiteJust').removeAttr('readonly');
	}
}

function verificacaoAprovTestes() {
	if ($("[name=aprovTestes]:checked").val() == 'sim') {
		// $('#aprovTestesJust').attr('readonly', 'true');
		console.log("Sim");
	}

	if ($("[name=aprovTestes]:checked").val() == 'nao') {
		console.log("Não");
		// $('#aprovTestesJust').removeAttr('readonly');
	}
}

function verificacaoAprovTestesComite() {
	if ($("[name=aprovTestesComite]:checked").val() == 'sim') {
		// $('#aprovTestesComiteJust').attr('readonly', 'true');
		console.log("Sim");
	}

	if ($("[name=aprovTestesComite]:checked").val() == 'nao') {
		console.log("Não");
		// $('#aprovTestesComiteJust').removeAttr('readonly');
	}
}

function verificacaoAprovDeploy() {
	if ($("[name=aprovDeploy]:checked").val() == 'sim') {
		// $('#aprovDeployJust').attr('readonly', 'true');
		console.log("Sim");
	}

	if ($("[name=aprovDeploy]:checked").val() == 'nao') {
		console.log("Não");
		// $('#aprovDeployJust').removeAttr('readonly');
	}
}

function verificacaoTipoProposta() {
	if ($("[name=tipoProposta]:checked").val() == 'melhoria') {
		$('#equipeDev').val('Desenvolvimento');
		console.log("melhoria: equipeDev =  Desenvolvimento");
	}

	if ($("[name=tipoProposta]:checked").val() == 'projeto') {
		$('#equipeDev').val('Projeto');
		console.log("projeto: equipeDev =  Projeto");

	}
}

function getData(tipo) {
	var data = new Date();
	var dia = data.getDate();
	var mes = data.getMonth() + 1;
	var ano = data.getFullYear();
	dia = (dia <= 9 ? "0" + dia : dia);
	mes = (mes <= 9 ? "0" + mes : mes);
	var novaData = ano + "/" + mes + "/" + dia;
	if (tipo == "aprovacao") {
		return  dia  + "/" + mes  +  "/" + ano;
	} else {
		return novaData;
	}
}

function getDataForm() {
	var data = new Date();
	var dia = data.getDate();
	var mes = data.getMonth() + 1;
	var ano = data.getFullYear();
	dia = (dia <= 9 ? "0" + dia : dia);
	mes = (mes <= 9 ? "0" + mes : mes);
	var novaData = ano + mes + dia;
	return novaData;
}

function verificarUsuarioTeste() {
	var quantidadeItens = $("[name^='tabUsuarioChave___']").length;
	for (var i = 0; i < quantidadeItens; i++) {
		var certo = String(i + 1);
		var element = quantidadeItens[certo];
		var usuarioLinha = $("[name^='tabUsuarioChave___" + certo + "']").val().split("|")[0];
		console.log(usuarioLinha);
		if (usuarioLinha != getUser()) {
			$("[name^='tabAceite___" + certo + "']").attr("readonly", true);
			$("[name^='tabData___" + certo + "']").attr("readonly", true);
		}

		else {
			$("[name^='tabAceite___" + certo + "']").val(getUserName());
			$("[name^='tabData___" + certo + "']").val(getData());
		}
	}
}

function verificaSolicitante() {
	var solic = $("#solicitante").val().split("|")[0];
	return solic;
}

//Funções de consulta de atribuição

function findManager(solicitante) {
	var c1 = DatasetFactory.createConstraint("cdusuario", solicitante, solicitante, ConstraintType.MUST);
	var constraints = new Array(c1);
	var dataset = DatasetFactory.getDataset("dsUsuarioGerente", new Array(), constraints, new Array());
	var codgerente = (dataset['values'][0]) ? dataset['values'][0]["cdgerente"] : "";

	if (codgerente != "" && codgerente != null && codgerente != undefined) {
		$("#gerente").val(codgerente);
		console.log(codgerente);
		return codgerente;
	} else {
		var myModal = FLUIGC.modal({
			title: 'Gerente não vinculado',
			content: 'Solicitante não possuí gerente vinculado ao cadastro',
			id: 'fluig-modal',
			actions: [{
				'label': 'Ok',
				'autoClose': true
			}]
		}, function (err, data) {
			if (err) {
				// do error handling
			} else {
				// do something with data
			}
		});

		setTimeout(() => {
			$("#solicitante").val("");
			$("#solicitanteId").val("");
			$("#gerente").val("");
		}, 500);

		return false;

	}
}

function getGMUDManager() {
	var array = [];

	var c1 = DatasetFactory.createConstraint('workflowColleagueRolePK.roleId', 'ger_gmud', 'ger_gmud', ConstraintType.MUST);
	var dataset = DatasetFactory.getDataset('workflowColleagueRole', null, new Array(c1), null);
	for (var i = 0; i < dataset.values.length; i++) {
		var gerente = dataset['values'][i]["workflowColleagueRolePK.colleagueId"];
		array.push(gerente);
	}

	var result = array.toString();
	$("#gergmud").val(result);
	return result;
}

function assinaturaAprovacao(numSolicitacao, atividade) {
	//var cs0 = DatasetFactory.createConstraint('sqlLimit', '1', '1', ConstraintType.MUST);
	var cs1 = DatasetFactory.createConstraint('numSolicitacao', numSolicitacao, numSolicitacao, ConstraintType.MUST);
	var cs2 = DatasetFactory.createConstraint('atividade', atividade, atividade, ConstraintType.MUST);
	var datasetTIGMUD = DatasetFactory.getDataset('tigmud', ['id', 'atividade', 'usuarioLogado', 'dataAtual'], new Array(cs1, cs2), ['id;desc']);
	var obj = new Array();
	for (let i = 0; i < datasetTIGMUD.values.length; i++) {
		var user = datasetTIGMUD.values[i]['usuarioLogado'];
		var nome = nomeDeUsuario(user, "colleagueName");
		console.log(nome);
		obj.push(nome);
	}
	return obj;
}


function nomeDeUsuario(colleagueId, saida) {
	var constraintColleague2 = DatasetFactory.createConstraint('colleaguePK.colleagueId', colleagueId, colleagueId, ConstraintType.MUST);
	var datasetColleague = DatasetFactory.getDataset('colleague', null, new Array(constraintColleague2), null);
	return datasetColleague.values[0][saida];
}

assinaturaAprovacao(80, 25);
