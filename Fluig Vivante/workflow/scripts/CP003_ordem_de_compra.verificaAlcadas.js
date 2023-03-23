function verificaAlcadas(destino){
	log.info("####### Ordem de Compra - VERIFICA ALCADAS #######");
	var nivelFavorecido = buscaNivelUsuario();
	
	var ultNivelAprovadorCampo = hAPI.getCardValue("ultNivelAprovador");
	var nivelAprovadorCampo    = hAPI.getCardValue("nivelAprovador");
	
	if (nivelAprovadorCampo == '') {
		nivelAprovadorCampo = nivelFavorecido;
	}
	
	if (destino == 'fim') {
		if (nivelAprovadorCampo == ultNivelAprovadorCampo) {
			return true
		}
	} else if (destino == 'aprovacao') {
		if (nivelAprovadorCampo != ultNivelAprovadorCampo) {
			return true;
		}
	}
	
	return false;
}