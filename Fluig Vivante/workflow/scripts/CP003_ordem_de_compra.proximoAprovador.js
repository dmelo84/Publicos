function proximoAprovador(destino){
	var retorno = false;
	if (destino == 'emElaboracao') {
		if (hAPI.getCardValue("emElaboracao") == "S") {
			retorno = true;
		}
	} else if (destino == 'aprovado_gerente_unidade') {
		if (hAPI.getCardValue("aprovado_gerente_unidade") != "on" 
			&& !centroCustoRH() 
			&& !centroCustoSESMET()) {
			
			retorno = true;
		}
	} else if (destino == 'aprovado_gerente_rh') {
		if (hAPI.getCardValue("aprovado_gerente_rh") != "on" 
			&& centroCustoRH() 
			&& !centroCustoSESMET()) {
			
			retorno = true;
		}
	} else if (destino == 'aprovado_gerente_sesmet') {
		if (hAPI.getCardValue("aprovado_gerente_sesmet") != "on" 
			&& !centroCustoRH() 
			&& centroCustoSESMET()) {
			
			retorno = true;
		}
	} else if (destino == 'aprovado_gerente_portfolio') {
		if (hAPI.getCardValue("valortotal_ordem") > 10000 
			&& hAPI.getCardValue("aprovado_gerente_portfolio") != "on" 
			&& !centroCustoRH() 
			&& !centroCustoSESMET()) {
			
			retorno = true;
		}
	} else if (destino == 'aprovado_diretor_operacional') {
		if (hAPI.getCardValue("valortotal_ordem") > 20000 
			&& hAPI.getCardValue("aprovado_diretor_operacional") != "on" 
			&& !centroCustoRH() 
			&& !centroCustoSESMET()) {
			
			retorno = true;
		}
	} else if (destino == 'aprovado_diretor_financeiro') {
		if (hAPI.getCardValue("valortotal_ordem") > 50000 
			&& hAPI.getCardValue("aprovado_diretor_financeiro") != "on" 
			&& !centroCustoRH() 
			&& !centroCustoSESMET()) {
			
			retorno = true;
		}
	} else if (destino == 'aprovado_diretor_rh') {
		if (hAPI.getCardValue("valortotal_ordem") >= 500000
			&& hAPI.getCardValue("aprovado_diretor_rh") != "on" 
			&& (centroCustoRH() || centroCustoSESMET())) {
			
			retorno = true;
		}
	} else if (destino == 'aprovado_presidente') {
		if (hAPI.getCardValue("valortotal_ordem") > 100000 
			&& hAPI.getCardValue("aprovado_presidente")!="on") {
			
			retorno = true;
		}
	} else if (destino == 'liberacao_ordem') {
		if (hAPI.getCardValue("tipo_ordem")=="contrato") {
			retorno = true;
		}
	}
	
	return retorno;
}