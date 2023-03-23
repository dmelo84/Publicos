function GerarRelatorioRM() {

	

	var idmov = $("#idmov").val()
	var coligadaMov = $("#empresa_codigo").val()

	//idmov = 2339839;
	//coligadaMov = 1;

	if(idmov == ""){

		FLUIGC.message.alert({
			message: 'A OC ainda não foi integrada no sistema, verifique se todas as etapas de aprovações foram concluídas e se o comprador já liberou a integração.',
			title: 'Ordem não integrada',
			label: 'OK'
		}, function (el, ev) {
	
		});

	} else {

		// cria uma nova janela para exibição do conteúdo do relatório em PDF
		newWindow = window.open('RMReports', 'pagina');
		newWindow.document.write("<iframe id='iFrameReport' width='100%' height='100%' src='" + getBytesRMReport(idmov, coligadaMov) + "'></iframe>");

	}


}


function getBytesRMReport(idmov, coligadaMov) {

	var idRelatorio = 125;//"125"///getRMReportId(codigo_relatorio);
	var constraints = [];




	

	constraints.push(DatasetFactory.createConstraint("COLIGADAREL", 0, 0, ConstraintType.MUST))
	constraints.push(DatasetFactory.createConstraint("COLIGADAMOV", coligadaMov, coligadaMov, ConstraintType.MUST))
	constraints.push(DatasetFactory.createConstraint("IDMOV", idmov, idmov, ConstraintType.MUST))
	constraints.push(DatasetFactory.createConstraint("IDRELATORIO", idRelatorio, idRelatorio, ConstraintType.MUST))

	var resultado = "";

	// dsRelatorioWs é identificador do DataSet exportado para o Fluig
	var dataset = DatasetFactory.getDataset("rm_relatorio_movimento", null, constraints, null);
	var wsReport = dataset.values[0];

	// seta o formato de abertura da string base 64 retornada pelo Web Service do RM Reports para PDF
	if (dataset.values.length == 1) {
		resultado = "data:application/pdf;base64, " + wsReport["RELATORIO"];
	}


	return resultado;
}

function getRMReportId(codigo_relatorio){

	var resultado = "";

	var consulta = "select id from RRPTREPORT ";
		consulta += "where CODIGO = '"+codigo_relatorio+"' and CODCOLIGADA=0";
		
	var constraints = [];
		constraints.push(DatasetFactory.createConstraint('pool-name', 'TotvsRM_MSSQL', 'TotvsRM_MSSQL', ConstraintType.MUST));
		constraints.push(DatasetFactory.createConstraint('consulta', consulta, consulta, ConstraintType.MUST));

	var dataset = DatasetFactory.getDataset("dsConsultaBancoDados", null, constraints, null);
	var dsValues = dataset.values[0];

	if (dataset.values.length == 1) {
		resultado = dsValues["id"];
	}


	return resultado;

}

