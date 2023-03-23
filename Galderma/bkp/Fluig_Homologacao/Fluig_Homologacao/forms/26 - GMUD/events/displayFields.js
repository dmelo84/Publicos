function displayFields(form, customHTML) {
	var numSolicitacao = getValue("WKNumProces");
	var atividade = getValue("WKNumState");
	var WKNumProces = getValue("WKNumProces");
	var FORM_MODE = form.getFormMode();
	var usuarioLogado = getValue("WKUser");
	var roteiroRollback = form.getValue("roteiroRollback");
	var afetaBoasPraticas = form.getValue("afetaBoasPraticas");
	var qualidadeJust = form.getValue("qualidadeJust");
	var fluigMobile = form.getMobile();

	var dadosUsario = consultaUsuario(usuarioLogado);

	var nomeUsuario = dadosUsario.nome;
	var emailUsuario = dadosUsario.mail;

	form.setValue("numSolicitacao", numSolicitacao);
	customHTML.append("\n<script>");

	customHTML.append("\n function getUser(){ return '" + getValue("WKUser") + "'; }");
	customHTML.append("\n function getUserName(){ return '" + nomeUsuario + "'; }");
	customHTML.append("\n function getUserMail(){ return '" + emailUsuario + "'; }");
	customHTML.append("\n function getAtividade(){ return " + atividade + "; }");
	customHTML.append("\n function getNumSol(){ return " + numSolicitacao + "; }");
	customHTML.append("\n const FORM_MODE = '" + FORM_MODE + "'; ");

	customHTML.append("\n</script>\n");

	// Ocultando todos os campos
	form.setVisibleById("div_tipoProposta", false);
	form.setVisibleById("cabecalhoDados", true);
	form.setVisibleById("div_proposta", true);
	form.setVisibleById("div_detProposta", true);
	form.setVisibleById("div_aprova1e2", false);
	form.setVisibleById("div_avalImpacto", false);
	form.setVisibleById("div_ananliseTec", false);
	form.setVisibleById("div_aprova3e4", false);
	form.setVisibleById("div_aprovProposta", false);
	form.setVisibleById("div_planoDeTestes", false);
	form.setVisibleById("div_roteiroAtualizacao", false);
	form.setVisibleById("div_roteiroRollback", false);


	// Trabalhando com campos personalizados por atividade
	customHTML.append("\n<script>\n");

	if (atividade == zero || atividade == inicio) {
		customHTML.append('\n $("usuarioLogado").val(' + usuarioLogado + ');');
		customHTML.append('');
	}

	if (atividade == categorizacaoMudanca) {
	}

	if (atividade == formPreench) {
	}

	if (atividade == aprova1e2) {
		form.setVisibleById("div_aprova1e2", true);
	}

	if (atividade == aprova1e2) {
		form.setVisibleById("div_aprova1e2", true);
	}

	if (atividade == aprovaSuperiorSol || atividade == qualidade || atividade == aprova3e4 || atividade == realizaImplementa || atividade == realizaImplementaTeste) {
		itens3e4(true);
		if (atividade == aprova3e4) {
			form.setVisibleById("div_aprova3e4", true);
		}

		if (atividade == qualidade) {
			form.setVisibleById("div_div_qualidade", true);
		}
	}

	if (qualidadeJust != "" && qualidadeJust != null) {
		form.setVisibleById("div_div_qualidade", true);
	}


	if (atividade == aprovaTISustentacao || atividade == aprovaTIComite) {
		form.setVisibleById("div_aprovProposta", true);
		itens3e4(true);


		if (atividade == aprovaTISustentacao) {
			form.setVisibleById("div_div_aprovComite", false);
			form.setVisibleById("comiteDeAprovacao", false);

		}

		if (atividade == aprovaTIComite) {
			form.setVisibleById("div_div_aprovComite", true);
			form.setVisibleById("comiteDeAprovacao", true);
		}
	}

	if (atividade == preparaRotTeste) {
		form.setVisibleById("div_planoDeTestes", true);
		form.setVisibleById("div_div_aprovTestesComite", false);
		form.setVisibleById("div_div_aprovDeploy", false);
		form.setVisibleById("div_div_aprovTestes", false);
		form.setVisibleById("div_roteiroAtualizacao", true);
		form.setVisibleById("div_roteiroRollback", true);

		itens3e4(true);

		if (roteiroRollback != "" && roteiroRollback != null) {
			form.setVisibleById("div_roteiroAtualizacao", true);
			form.setVisibleById("div_roteiroRollback", true);
		}

	}

	if (atividade != preparaRotTeste && FORM_MODE != "MOD") {
		form.setVisibleById("btnAddTeste", false);
	}

	if (atividade == efetuaTestes) {
		planoDeTestes(true);
		itens3e4(true);
		form.setVisibleById("div_div_aprovTestes", false);
		form.setVisibleById("div_div_aprovTestesComite", false);
		form.setVisibleById("div_roteiroAtualizacao", true);
		form.setVisibleById("div_roteiroRollback", true);
	}

	if (atividade == aprovaTIProd) {
		form.setVisibleById("div_planoDeTestes", true);
		form.setVisibleById("div_div_aprovTestes", true);
		form.setVisibleById("div_div_aprovTestesComite", false);
		itens3e4(true);
		form.setVisibleById("div_roteiroAtualizacao", true);
		form.setVisibleById("div_roteiroRollback", true);
	}

	if (atividade == aprovaTIProdComite) {
		planoDeTestes(true);
		itens3e4(true);
		if (FORM_MODE == "VIEW") {
			customHTML.append("$('#aprovTestesComite').val();");
		}
		form.setVisibleById("div_roteiroAtualizacao", true);
		form.setVisibleById("div_roteiroRollback", true);
	}

	if (atividade == efetuaTestes) {
		itens3e4(true);
		form.setVisibleById("div_roteiroAtualizacao", true);
		form.setVisibleById("div_roteiroRollback", true);
	}


	if (atividade != preparaRotTeste) {
		form.setHideDeleteButton(true);
		form.setVisibleById("btnAddTeste", false);
	}

	if (atividade == aprovaTIProd) {
		itens3e4(true);
		form.setVisibleById("div_roteiroAtualizacao", true);
		form.setVisibleById("div_roteiroRollback", true);
	}

	if (atividade != aprovaTIProdComite) {
		form.setVisibleById("div_aprovAtualizaProd", false);
	}

	if (atividade != deployProd) {
		form.setVisibleById("div_aceiteProd", false);

	}

	if (atividade == deployProd) {
		itens3e4(true);
		planoDeTestes(true);
		form.setVisibleById("div_roteiroAtualizacao", true);
		form.setVisibleById("div_roteiroAtualizacao", true);
		form.setVisibleById("div_roteiroRollback", true);
		form.setVisibleById("div_aprovAtualizaProd", true);
		

		if (FORM_MODE == "VIEW") {
			customHTML.append("$('#processoAprovado').val()");
		}
	}

	if (atividade == roolback) {
		itens3e4(true);
		planoDeTestes(true);
		form.setVisibleById("div_roteiroRollback", true);
	}

	if (atividade == finalizaTicket || atividade == documentaFim1e3 || atividade == documentaFim3e4 || atividade == fim61 || atividade == fim73 || atividade == fimSucesso) {
		itens3e4(true);
		planoDeTestes(true);
		form.setVisibleById("div_roteiroRollback", true);
		form.setVisibleById("div_roteiroAtualizacao", true);
		form.setVisibleById("div_planoDeTestes", true);
		form.setVisibleById("div_div_aprovTestes", true);
		form.setVisibleById("div_div_aprovDeploy", true);
		form.setVisibleById("div_aprovAtualizaProd", true);
		form.setVisibleById("div_roteiroAtualizacao", true);
		form.setVisibleById("div_roteiroRollback", true);
		form.setVisibleById("div_aceiteProd", true);

	}

	function itens3e4(paramentro) {
		form.setVisibleById("div_avalImpacto", paramentro);
		form.setVisibleById("div_ananliseTec", paramentro);
	}

	function planoDeTestes(paramentro) {
		form.setVisibleById("div_planoDeTestes", paramentro);
		form.setVisibleById("div_div_aprovTestes", paramentro);
	}

	form.setVisibleById("div_respAreaSol", false);
	form.setVisibleById("div_respSol", false);
	form.setVisibleById("div_respSustERP", false);
	form.setVisibleById("div_respERP", false);
	form.setVisibleById("div_gerenteTI", false);
	form.setVisibleById("divText_afetaBoasPraticas", false);
	form.setVisibleById("div_prodrespAreaSol", false);
	form.setVisibleById("div_prodrespSol", false);
	form.setVisibleById("div_prodrespSustERP", false);
	form.setVisibleById("div_prodrespERP", false);
	form.setVisibleById("div_prodgerenteTI", false);

	if (atividade == 98) {
		form.setVisibleById("div_respAreaSol", true);
		form.setVisibleById("div_respSol", true);
		form.setVisibleById("div_respSustERP", true);
		form.setVisibleById("div_respERP", true);
		form.setVisibleById("div_gerenteTI", true);
		form.setVisibleById("divText_afetaBoasPraticas", true);
		form.setVisibleById("div_prodrespAreaSol", true);
		form.setVisibleById("div_prodrespSol", true);
		form.setVisibleById("div_prodrespSustERP", true);
		form.setVisibleById("div_prodrespERP", true);
		form.setVisibleById("div_prodgerenteTI", true);
	}

	customHTML.append('\n $("usuarioLogado").val(' + usuarioLogado + ');');


	customHTML.append("\n</script>\n");

}

function getData() {
	var data = new Date();
	var dia = data.getDate();
	var mes = data.getMonth() + 1;
	var ano = data.getFullYear();
	dia = (dia <= 9 ? "0" + dia : dia);
	mes = (mes <= 9 ? "0" + mes : mes);
	var novaData = ano + mes + dia;
	return novaData;
}

function consultaUsuario(usuario) {
	var c1 = DatasetFactory.createConstraint("colleaguePK.colleagueId", usuario, usuario, ConstraintType.MUST);
	retorno = DatasetFactory.getDataset('colleague', null, new Array(c1), null);

	for (var i = 0; i < retorno.rowsCount; i++) {
		var nomeUsuario = retorno.getValue(i, "colleagueName");
		var email = retorno.getValue(i, "mail");
	}

	var newObject = new Object();
	newObject.nome = nomeUsuario;
	newObject.mail = email;
	return newObject;
}