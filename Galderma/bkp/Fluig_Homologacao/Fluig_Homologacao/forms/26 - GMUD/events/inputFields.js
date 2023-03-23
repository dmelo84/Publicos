function inputFields(form) {

	var numSolicitacao = getValue("WKNumProces");
	var atividade = getValue("WKNumState");
	var WKNumProces = getValue("WKNumProces");
	var FORM_MODE = form.getFormMode();
	var usuarioLogado = getValue("WKUser");
	var fluigMobile = form.getMobile();

	form.setValue("numSolicitacao", numSolicitacao);
	form.setValue("atividade", atividade);
	form.setValue("usuarioLogado", usuarioLogado);
	form.setValue("dataAtual", getData("aprovacao"));

}

function getData(tipo) {
	var data = new Date();
	var dia = data.getDate();
	var mes = data.getMonth() + 1;
	var ano = data.getFullYear();
	dia = (dia <= 9 ? "0" + dia : dia);
	mes = (mes <= 9 ? "0" + mes : mes);

	var novaData = String("");

	if (tipo == "aprovacao") { 
		return  dia  + "/" + mes  +  "/" + ano;
	} else {
		return ano  + mes  + dia;
	}
}

