function GerarRelatorioRM() {

	console.log("Gerar Relatório")
	// cria uma nova janela para exibição do conteúdo do relatório em PDF
	newWindow = window.open('', 'pagina');
	newWindow.document.write("<iframe id='iFrameReport' width='100%' height='100%' src='" + getBytesRMReport() + "'></iframe>");
	/*
	var myModal = FLUIGC.modal({
		title: 'Relatório',
		content: '<div id="divFrame"></div>',
		id: 'fluig-modal',
		actions: [{
			'label': 'Fechar',
			'autoClose': true
		}]
	}, function(err, data) {
		if(err) {
			// do error handling
		} else {
			// do something with data
			document.getElementById('divFrame').innerHTML = "<iframe id='iFrameReport' width='100%' height='100%' src='" + getBytesRMReport() + "'></iframe>";
		}
	});
	*/
}


function getBytesRMReport() {

	// Constraint com o identificador do movimento que será utilizado para geração do realtório
	//


console.log("Chamou Relatório")

	var constraints = [];
	//constraints.push(DatasetFactory.createConstraint("CODIGOCOLIGADA", coligada, coligada, ConstraintType.MUST));
	//constraints.push(DatasetFactory.createConstraint("IDMOV", idmov, idmov, ConstraintType.MUST))
	constraints.push(DatasetFactory.createConstraint("SOLICITACAO", WKNumProces, WKNumProces, ConstraintType.MUST))
	constraints.push(DatasetFactory.createConstraint("IDRELATORIO", 142, 142, ConstraintType.MUST))

	var resultado = "";


	console.log("Chamou Relatório constraints")

	console.log(constraints)

	// dsRelatorioWs é identificador do DataSet exportado para o Fluig
	var dataset = DatasetFactory.getDataset("rm_relatorio_prestacaoContas", null, constraints, null);
	var wsReport = dataset.values[0];

	// seta o formato de abertura da string base 64 retornada pelo Web Service do RM Reports para PDF
	if (dataset.values.length == 1) {
		resultado = "data:application/pdf;base64, " + wsReport["RELATORIO"];
	}


	return resultado;
}