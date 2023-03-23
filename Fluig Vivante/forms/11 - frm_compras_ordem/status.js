function atualizaStatus(){

	var atvAprovGerente = 15;
	var atvAprovPortfolio = 17;
	var atvAprovDiretor = 21;
	var atvAprovPresidente = 23;
	var atvAprovEmergencial = 144
	var atvLiberaOrdem = 31;
	var atvAprovGerenteRH = 170;
	var atvAprovGerenteSESMET = 178;
	var atvAprovDiretorRH = 172;

	if(WKNumState == atvAprovGerente)
	    $("[data-status-workflow]").text("Aprovação Gerente Unidade");
	
	if(WKNumState == atvAprovPortfolio)
	    $("[data-status-workflow]").text("Aprovação Portfólio");
	
	if(WKNumState == atvAprovDiretor)
	    $("[data-status-workflow]").text("Aprovação Diretor");
	
	if(WKNumState == atvAprovPresidente)
	    $("[data-status-workflow]").text("Aprovação Presidente");
	
	if(WKNumState == atvAprovEmergencial)
	    $("[data-status-workflow]").text("Aprovação Emergencial");
	
	if(WKNumState == atvAprovGerenteRH)
	    $("[data-status-workflow]").text("Aprovação Gerente RH");
	
	if(WKNumState == atvAprovGerenteSESMET)
	    $("[data-status-workflow]").text("Aprovação Gerente SESMET");
	
	if(WKNumState == atvAprovDiretorRH)
	    $("[data-status-workflow]").text("Aprovação Diretoria RH");

}