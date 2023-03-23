function enableFields(form) {

	var atividade = getValue("WKNumState");

	function cabecaho(parametro) {
		form.setEnabled("sistema", parametro);
		form.setEnabled("solicitante", parametro);
		form.setEnabled("dataSol", parametro);
		form.setEnabled("departamento", parametro);
		form.setEnabled("empresasImpacto", parametro);
		form.setEnabled("cargo", parametro);
	}

	function proposta(parametro) {
		form.setEnabled("proposta", parametro);
	}

	function detProposta(parametro) {
		form.setEnabled("detProposta", parametro);
		form.setEnabled("sitAtual", parametro);
		form.setEnabled("altPropostas", parametro);
		form.setEnabled("motivoProposta", parametro);
		form.setEnabled("tipoProposta", parametro);
	}

	function avalImpacto(parametro) {
		form.setEnabled("afetaBoasPraticas", parametro);
		form.setEnabled("afetaObrigFiscais", parametro);
		form.setEnabled("afetaContab", parametro);
		form.setEnabled("afetaRealGerenc", parametro);
		form.setEnabled("afetaProcessCritic", parametro);
	}

	function ananliseTec(parametro) {
		form.setEnabled("erroSistema", parametro);
		form.setEnabled("erroCustomi", parametro);
		form.setEnabled("mudParamet", parametro);
		form.setEnabled("atualizaPatch", parametro);
		form.setEnabled("novoRelatorio", parametro);
		form.setEnabled("customizaProjeto", parametro);
		form.setEnabled("customizaMelhoria", parametro);
		form.setEnabled("necessidadeOrga", parametro);
		form.setEnabled("alteraBD", parametro);
		form.setEnabled("criaAlteraProg", parametro);
		form.setEnabled("mudParamet2", parametro);
		form.setEnabled("atualizaPatch2", parametro);
		form.setEnabled("horasDesenvolv", parametro);
		form.setEnabled("descHorasDesenvolv", parametro);
	}

	function aprovaSustentacao(parametro) {
		form.setEnabled("aprovProposta", parametro);
		form.setEnabled("justRejeicao", parametro);
	}

	function roteiroDeploy(parametro) {
		form.setEnabled("roteiroAtualizacao", parametro);
		form.setEnabled("aprovDeploy", parametro);
		form.setEnabled("aprovDeployJust", parametro);
	}

	if (atividade != zero && atividade != inicio) {
		form.setEnabled("refTicket", false);
		cabecaho(false);
	}

	if (atividade == aprova1e2) {
		cabecaho(false);
		proposta(false);
		detProposta(false);
	}

	if (atividade == aprovaSuperiorSol) {
		cabecaho(false);
		proposta(false);
		detProposta(false);
		avalImpacto(true);
		ananliseTec(true);
	}


	if (atividade != aprovaSuperiorSol) {
		avalImpacto(false);
		ananliseTec(false);
	}

	if (atividade == documentaEEncerra) {
		cabecaho(false);
		proposta(false);
		detProposta(false);
	}


	if (atividade == aprova3e4) {
		cabecaho(false);
		proposta(false);
		detProposta(false);
		avalImpacto(false);
		ananliseTec(false);
	}

	if (atividade == aprovaTISustentacao) {
		cabecaho(false);
		proposta(false);
		detProposta(false);
		avalImpacto(false);
		ananliseTec(false);
	}

	if (atividade != aprovaTISustentacao) {
		aprovaSustentacao(false);
	}

	if (atividade == aprovaTIComite) {
		cabecaho(false);
		proposta(false);
		detProposta(false);
		avalImpacto(false);
		ananliseTec(false);
	}

	if (atividade == realizaImplementa || atividade == realizaImplementaTeste) {
		cabecaho(false);
		proposta(false);
		detProposta(false);
		avalImpacto(false);
		ananliseTec(false);
	}

	if (atividade == preparaRotTeste) {
		cabecaho(false);
		proposta(false);
		detProposta(false);
		avalImpacto(false);
		ananliseTec(false);
		

		var testeID = form.getChildrenIndexes("planoDeTesteTabela");
		for (var i = 0; testeID.length > i; i++) {
			form.setEnabled("tabAceite___" + testeID[i], false);
			form.setEnabled("tabData___" + testeID[i], false);
		}
	}

	if (atividade != preparaRotTeste) {

		form.setEnabled("roteiroAtualizacao", false);
		form.setEnabled("roteiroRollback", false);
		

		var testeID = form.getChildrenIndexes("planoDeTesteTabela");

		for (var i = 0; testeID.length > i; i++) {
			form.setEnabled("tabEmpresa___" + testeID[i], false);
			form.setEnabled("tabModulo___" + testeID[i], false);
			form.setEnabled("tabMenu___" + testeID[i], false);
			form.setEnabled("tabCaminho___" + testeID[i], false);
			form.setEnabled("tabPrograma___" + testeID[i], false);
			form.setEnabled("tabAtividade___" + testeID[i], false);
			form.setEnabled("tabResultadoEsp___" + testeID[i], false);
			form.setEnabled("tabUsuarioChave___" + testeID[i], false);
		}
	}

	if (atividade != preparaRotTeste && atividade != efetuaTestes) {
		var testeID = form.getChildrenIndexes("planoDeTesteTabela");
		for (var i = 0; testeID.length > i; i++) {
			form.setEnabled("tabEmpresa___" + testeID[i], false);
			form.setEnabled("tabModulo___" + testeID[i], false);
			form.setEnabled("tabMenu___" + testeID[i], false);
			form.setEnabled("tabCaminho___" + testeID[i], false);
			form.setEnabled("tabPrograma___" + testeID[i], false);
			form.setEnabled("tabAtividade___" + testeID[i], false);
			form.setEnabled("tabResultadoEsp___" + testeID[i], false);
			form.setEnabled("tabUsuarioChave___" + testeID[i], false);
			form.setEnabled("tabAceite___" + testeID[i], false);
			form.setEnabled("tabData___" + testeID[i], false);
		}
	}


	if (atividade == qualidade) {
		cabecaho(false);
		proposta(false);
		detProposta(false);
		avalImpacto(false);
		ananliseTec(false);
		form.setEnabled("qualidadeJust", true);
	}

	if (atividade != qualidade) {
		form.setEnabled("qualidadeJust", false);
	}

	if (atividade == aprovaTIProd) {
		cabecaho(false);
		proposta(false);
		detProposta(false);
		avalImpacto(false);
		ananliseTec(false);
	}

	if (atividade != aprovaTIProd) {
		form.setEnabled("aprovTestes", false);
		form.setEnabled("aprovTestesJust", false);
	}

	if (atividade == aprovaTIProdComite) {
		cabecaho(false);
		proposta(false);
		detProposta(false);
		avalImpacto(false);
		ananliseTec(false);
	}

	if (atividade != aprovaTIProdComite) {
		form.setEnabled("aprovTestesComite", false);
		form.setEnabled("aprovTestesComiteJust", false);
	}

	if (atividade == deployProd) {
		cabecaho(false);
		proposta(false);
		detProposta(false);
		avalImpacto(false);
		ananliseTec(false);
	}
	
	if (atividade != aprovaTIProd) {
		form.setEnabled("horarioAplicacao",false);
		form.setEnabled("dataAprovProd",false);
	}

	if (atividade == finalizaTicket) {
		cabecaho(false);
		proposta(false);
		detProposta(false);
		avalImpacto(false);
		ananliseTec(false);
	}

	if (atividade == roolback) {
		cabecaho(false);
		proposta(false);
		detProposta(false);
		avalImpacto(false);
		ananliseTec(false);
		roteiroDeploy(false);
	}

	if (atividade != roolback && atividade != preparaRotTeste) {
		form.setEnabled("roteiroRollback", false);
	}

	if (atividade == efetuaTestes) {
		cabecaho(false);
		proposta(false);
		detProposta(false);
		avalImpacto(false);
		ananliseTec(false);
		form.setEnabled("aprovTestes", true);
	}

	if (atividade == finalizaTicket || atividade == documentaFim1e3 || atividade == documentaFim3e4 || atividade == fim61 || atividade == fim73 || atividade == fimSucesso) {
		cabecaho(false);
		proposta(false);
		detProposta(false);
		avalImpacto(false);
        ananliseTec(false);
        roteiroDeploy(false);
        form.setEnabled("roteiroRollback", false);
        form.setEnabled("dataAprovProd", false);
        form.setEnabled("horarioAplicacao", false);

	}
}

