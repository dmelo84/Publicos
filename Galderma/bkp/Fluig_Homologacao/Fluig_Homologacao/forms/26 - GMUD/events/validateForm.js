function validateForm(form) {
	var atividade = getValue("WKNumState");
	var usuarioLogado = getValue("WKUser");

	
	var sistema = form.getValue("sistema");
	var gerente = form.getValue("gerente");
	var solicitante = form.getValue("solicitante");
	var dataSol = form.getValue("dataSol");
	var departamento = form.getValue("departamento");
	var cargo = form.getValue("cargo");
	var empresasImpacto = form.getValue("empresasImpacto");
	var refTicket = form.getValue("refTicket");



	var aprova1e2Campo = form.getValue("aprova1e2");
	var aprova1e2Just = form.getValue("aprova1e2Just");

	var aprova3e4Campo = form.getValue("aprova3e4");
	var aprova3e4Just = form.getValue("aprova3e4Just");
	var aprovTestes = form.getValue("aprovTestes");
	var aprovTestesJust = form.getValue("aprovTestesJust");
	var aprovTestesComite = form.getValue("aprovTestesComite");
	var aprovTestesComiteJust = form.getValue("aprovTestesComiteJust");
	var aprovDeploy = form.getValue("aprovDeploy");

	if (atividade == zero || atividade == inicio) {

		if (sistema == null && sistema == "") {
			throw "Por favor, preencha o campo \"Sistema\". ";
		}

		if (gerente == null && gerente == "") {
			throw "O usuário solicitante selecionando não possuí gerente vinculado. Por favor, solicite a vinculação do gerente ao usuário";
		}

		if (solicitante == null && solicitante == "") {
			throw "Por favor, preencha o campo \"Solicitante\". ";
		}

		if (dataSol == null && dataSol == "") {
			throw "Por favor, preencha o campo \"Data da Solicitação\". ";
		}

		if (departamento == null && departamento == "") {
			throw "Por favor, preencha o campo \"Departamento\". ";
		}

		if (cargo == null && cargo == "") {
			throw "Por favor, preencha o campo \"Cargo\". ";
		}

		if (empresasImpacto == null && empresasImpacto == "") {
			throw "Por favor, preencha o campo \"Empresas Impactadas\". ";
		}

		if (refTicket == null && refTicket == "") {
			throw "Por favor, preencha o campo \"Referência do sistema\". ";
		}
	}

	if (atividade == aprova1e2) {
		if (aprova1e2Campo != "sim" && aprova1e2Campo != "nao") {
			throw "Por favor, selecione uma das opção no campo \"Aprovação dos itens 1 e 2\". ";
		}

		if (aprova1e2Campo == "nao") {
			if (aprova1e2Just == null || aprova1e2Just == "") {
				throw "Ao rejeitar a proposta o campo \"Justificativa\" deve ser preenchido. ";
			}
		}
	}

	if (atividade == aprovaTISustentacao) {
		var aprovProposta = form.getValue("aprovProposta");
		var justRejeicao = form.getValue("justRejeicao");
		if (aprovProposta != "sim" && aprovProposta != "nao") {
			throw "Por favor, selecione uma das opção no campo \"Aprovação\". ";
		}

		if (aprovProposta == "nao") {
			if (justRejeicao == null || justRejeicao == "") {
				throw "Ao rejeitar a proposta o campo \"Justificativa\" deve ser preenchido. ";
			}
		}
	}

	if (atividade == aprova3e4) {
		if (aprova3e4Campo != "sim" && aprova3e4Campo != "nao") {
			throw "Por favor, selecione uma das opção no campo \"Aprovação dos itens 3 e 4\". ";
		}

		if (aprova3e4Campo == "nao") {
			if (aprova3e4Just == null || aprova3e4Just == "") {
				throw "Ao rejeitar a proposta o campo \"Justificativa\" deve ser preenchido. ";
			}
		}
	}

	if (atividade == aprovaTIProd) {

		if (aprovTestes != "sim" && aprovTestes != "nao") {
			throw "Por favor, selecione uma das opção no campo \"Aprovação dos testes (Lider sustentação)\". ";
		}

		if (aprovTestes == "nao") {
			if (aprovTestesJust == null || aprovTestesJust == "") {
				throw "Ao rejeitar a proposta o campo \"Justificativa\" deve ser preenchido. ";
			}
		}
	}

	if (atividade == aprovaTIComite) {
		var aprovComite = form.getValue("aprovComite");
		var aprovComiteJust = form.getValue("aprovComiteJust");

		if (aprovComite != "sim" && aprovComite != "nao") {
			throw "Por favor, selecione uma das opção no campo \"Aprovação (Comitê)\". ";
		}

		if (aprovComite == "nao") {
			if (aprovComiteJust == null || aprovComiteJust == "") {
				throw "Ao rejeitar a proposta o campo \"Justificativa\" deve ser preenchido. ";
			}
		}
	}

	if (atividade == aprovaTIProdComite) {

		// if (aprovTestesComite != "sim" && aprovTestesComite != "nao") {
		// 	throw "Por favor, selecione uma das opção no campo \"Aprovação dos testes (Comitê)\". ";
		// }

		// if (aprovTestesComite == "nao") {
		// 	if (aprovTestesComiteJust == null || aprovTestesComiteJust == "") {
		// 		throw "Ao rejeitar a proposta o campo \"Justificativa\" deve ser preenchido. ";
		// 	}
		// }
	}

	if (atividade == deployProd) {
		var horarioAplicacao_comercial = form.getValue("horarioAplicacao_comercial");
		var horarioAplicacao_apos18 = form.getValue("horarioAplicacao_apos18");
		var horarioAplicacao_FDS = form.getValue("horarioAplicacao_comercial");
		
		var dataAprovProd = form.getValue("dataAprovProd");
		if (dataAprovProd == "" || dataAprovProd == null) {
			throw "Por favor, preencha o campo \"Data de aplicação\". ";
		}
		if (horarioAplicacao_comercial == "" || horarioAplicacao_comercial == null,
			   horarioAplicacao_apos18 == "" || horarioAplicacao_apos18 == null,	
				  horarioAplicacao_FDS == "" || horarioAplicacao_FDS == null) {
			throw "Por favor, selecione uma das opção no campo \"Horário de aplicação\". ";
		}
	}

	// if (atividade == aprovaTIProdComite) {
	// 	var aprovTestesComite= form.getValue("aprovTestesComite");

	// 	if (aprovTestesComite != "sim" && aprovTestesComite != "nao") {
	// 		throw "Por favor, selecione uma das opção no campo \"Aprovação dos testes (Comitê)\". ";
	// 	}
	// }

    /*
    if (atividade != efetuaTestes) {
        var testeID = form.getChildrenIndexes("planoDeTesteTabela");
        for (var i = 0; testeID.length > i; i++) {

            var usuarioChave = form.getValue("tabUsuarioChave___" + testeID);
            var tabAceite = form.getValue("tabAceite___" + testeID);
            var tabData = form.getValue("tabData___" + testeID);

            var usuarioTratado = usuarioChave.split("|")[0];

            if (usuarioLogado == usuarioTratado) {
                if (tabData == "" || tabData == null || tabData == undefined) {
                    throw "O campo \"Data do aceite\" deve ser preenchido. ";

                }
            }
        }
    }


    function verificarUsuarioTeste(usuario, aceite, data) {
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
        }
    }
*/
}