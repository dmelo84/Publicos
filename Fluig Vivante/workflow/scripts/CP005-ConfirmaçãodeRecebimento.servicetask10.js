function servicetask10(attempt, message) {

	preparaXML();

}

function preparaXML() {

	log.info("## Prepara XML")

	var processo = getValue("WKNumProces");
	var campos = hAPI.getCardData(processo);

	var now = new java.util.Date();
	var formatDate = new java.text.SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss");
	var dataAtual = formatDate.format(now);

	//PREPARA TMOV
	var xmlMov = getTemplateMovFaturamento();

	xmlMov = replaceValue(xmlMov, "CodColigada", "");
	xmlMov = replaceValue(xmlMov, "CodTmvOrigem", "");
	xmlMov = replaceValue(xmlMov, "dataBase", dataAtual);
	xmlMov = replaceValue(xmlMov, "numeroMov", campos.get("nf_numero"));
	xmlMov = replaceValue(xmlMov, "serie", campos.get("nf_serie"));
	
	var arrData = campos.get("nf_emissao").split("/");
	var data_emissao_nf = arrData[2] + "-" + arrData[1] + "-" + arrData[0];
	xmlMov = replaceValue(xmlMov, "dataEmissao", data_emissao_nf);

	var ordens = hAPI.getCardValue("ordens_recebidas").toString().split(",");

	for (var i = 0; i < ordens.length; i++) {

		var ordem = ordens[i];

		var xmlIdmov = getTemplateIdMov();
		xmlIdmov = replaceValue(xmlIdmov, "int", ordem);

		xmlMov = appendValue(xmlMov, "IdMov", xmlIdmov)
	}



	//PERCORRE A TABELA PAI E FILHO DOS ITENS DO MOVIMENTO
	var contador = campos.keySet().iterator();
	var count = 0;
	var nseqitmmov = 0;
	var xmlITENS = "";

	while (contador.hasNext()) {
		var id = contador.next();

		if (id.match(/titem_nroOrdem___/)) {

			var campo = campos.get(id);
			var id = id.split("___")[1];

			log.dir(campos);
			log.info(campo);

			var xmlMovItem = getTemplateMovItemFatAutomatico();

			xmlMovItem = replaceValue(xmlMovItem, "CodColigada", campos.get("titem_codcoligada___" + id));
			xmlMovItem = replaceValue(xmlMovItem, "IdMov", campos.get("titem_idmov___" + id));
			xmlMovItem = replaceValue(xmlMovItem, "NSeqItmMov", campos.get("titem_nseqitmmov___" + id));
			xmlMovItem = replaceValue(xmlMovItem, "Quantidade", campos.get("titem_qtdRecebida___" + id));

			xmlMov = appendValue(xmlMov, "listaMovItemFatAutomatico", xmlMovItem)

		} //if campo referencia
	} //while

	//FINALIZA A CONCATENAÇÃO DOS XML'S

	log.info("## Prepara XML XML");
	log.dir(xmlMov);
	log.info("## Prepara Integrar");
	integrar(xmlMov);

	return xmlMov;

}

function integrar(xml) {

	var processo = getValue("WKNumProces");
	var campos = hAPI.getCardData(processo);
	var formatDate = new java.text.SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss");

	var ProcessServerName = "MovFaturamentoProc";
	var usuario = "mestre";
	var senha = "vb220590";
	var context;


	var authService = getWebService(usuario, senha);

	log.info("## Prepara authService");
	for (x in authService) {
		log.info(x);
	}

	try {



		var xmlEnvio = xml; //hAPI.getCardValue("integracao_xml");

		//if (xmlEnvio.length > 0) {
		var result = {};

		result = new String(authService.executeWithParams(ProcessServerName, xmlEnvio));

		// checkIsPK(result, 2);
		// }

	} catch (e) {
		if (e == null) e = "Erro desconhecido!";
		var mensagemErro = "Ocorreu um erro ao salvar dados no RM: " + e;

		throw mensagemErro;
	}

}


function getTemplateMovFaturamento() {

	return new String(
		//   "<?xml version="1.0" encoding="UTF-8"?>"+
		"		<MovFaturamentoProcParams>" +
		"		   <movCopiaFatPar>" +
		"		      <CodColigada>1</CodColigada>" +
		"		      <CodSistema>T</CodSistema>" +
		"		      <CodTmvDestino>1.1.39</CodTmvDestino>" +
		"		      <CodTmvOrigem>1.1.33</CodTmvOrigem>" +
		"		      <CodUsuario>mestre</CodUsuario>" +
		"		      <GrupoFaturamento />" +
		"		      <IdExercicioFiscal>21</IdExercicioFiscal>" +
		"		      <IdMov></IdMov>" +
		"		      <TipoFaturamento>1</TipoFaturamento>" +
		"		      <dataBase>2018-10-23T00:00:00-03:00</dataBase>" +
		"		      <dataEmissao></dataEmissao>" +
		"		      <dataSaida />" +
		"		      <efeitoPedidoFatAutomatico>2</efeitoPedidoFatAutomatico>" +
		"		      <listaMovItemFatAutomatico></listaMovItemFatAutomatico>" +
		"		      <numeroMov></numeroMov>" +
		"		      <serie></serie>" +
		"		      <realizaBaixaPedido>true</realizaBaixaPedido>" +
		"		   </movCopiaFatPar>" +
		"		</MovFaturamentoProcParams>"

	);
}


function getTemplateMovItemFatAutomatico() {

	return new String(

		"		         <MovItemFatAutomatico>" +
		"		            <CodColigada>1</CodColigada>" +
		"		            <Checked>1</Checked>" +
		"		            <IdMov>2253356</IdMov>" +
		"		            <NSeqItmMov>1</NSeqItmMov>" +
		"		            <Quantidade>1,0000</Quantidade>" +
		"		         </MovItemFatAutomatico>"


	);
}

function getTemplateIdMov() {
	return new String("<int>2253356</int>");
}


function replaceValue(text, columnName, newValue) {

	if ((newValue != null) && (newValue.trim() != "")) {
		var regex = new RegExp("<" + columnName + ">(.*?)<\\/" + columnName + ">", "g");
		var replaceText = "<" + columnName + ">" + newValue + "</" + columnName + ">";

		return text.replace(regex, replaceText);
	} else
		return text;
}

function appendValue(text, closeTag, newValue) {

	if ((newValue != null) && (newValue.trim() != "")) {
		return text.replace("</" + closeTag, newValue + "</" + closeTag);
	}
}

function isEmpty(str) {
	return (!str || 0 === str.length);
}

function getWebService(Usuario, Senha) {

	var Nome_Servico = "wsProcess";
	var Caminho_Servico = "com.totvs.WsProcess";

	var dataServerService = ServiceManager.getServiceInstance(Nome_Servico);
	if (dataServerService == null) {
		throw "Servico nao encontrado: " + Nome_Servico;
	}

	var serviceLocator = dataServerService.instantiate(Caminho_Servico);
	if (serviceLocator == null) {
		throw "Instancia do servico nao encontrada: " + Nome_Servico + " - " + Caminho_Servico;
	}

	var service = serviceLocator.getRMIwsProcess();
	if (service == null) {
		throw "Instancia do dataserver do invalida: " + Nome_Servico + " - " + Caminho_Servico;
	}

	var serviceHelper = dataServerService.getBean();
	if (serviceHelper == null) {
		throw "Instancia do service helper invalida: " + Nome_Servico + " - " + Caminho_Servico;
	}

	var authService = serviceHelper.getBasicAuthenticatedClient(service, "com.totvs.IwsProcess", Usuario, Senha);
	if (serviceHelper == null) {
		throw "Instancia do auth service invalida: " + Nome_Servico + " - " + Caminho_Servico;
	}

	return authService;
}

function dcExecuteWithParams(ProcessServerName, xml) {



}

function dcReadView(dataservername, context, usuario, senha, filtro) {
	// carrega o webservice...
	var authService = getWebService(usuario, senha);

	// lê os dados da visão respeitando o filtro passado
	var viewData = new String(authService.readView(dataservername, filtro, context));

	return viewData;
}

function dcReadRecord(dataservername, context, usuario, senha, primaryKey) {
	// carrega o webservice...
	var authService = getWebService(usuario, senha);

	// lê os dados do registro respeitando a pk passada
	try {
		var recordData = new String(authService.readRecord(dataservername, primaryKey, context));
	} catch (e) {
		var recordData = new String(authService.getSchema(dataservername, context));
	}

	return recordData;
}

function dcSaveRecord(dataservername, context, usuario, senha, xml) {

	// carrega o webservice...
	var authService = getWebService(usuario, senha);

	// salva o registro de acordo com o xml passado
	var pk = new String(authService.readRecord(dataservername, xml, context));

	return pk;
}

//Transforma o conceito de constraints do Fluig para o Filtro do TBC.
function parseConstraints(constraints, filterRequired) {
	// inicializa o resultado...
	var result = [];
	result.context = "";

	// inicializa o filtro...
	var filter = "";

	// varre as contraints...
	for (con in constraints) {
		var fieldName = con.getFieldName().toUpperCase();
		if (fieldName == "RMSCONTEXT") {
			result.context = con.getInitialValue();
			continue;
		}

		filter += "(";

		if (fieldName == "RMSFILTER") {
			filter += con.getInitialValue();
		} else {
			if (con.getInitialValue() == con.getFinalValue() || isEmpty(con.getFinalValue())) {
				filter += con.getFieldName();
				var isLike = false;
				switch (con.getConstraintType()) {
					case ConstraintType.MUST:
						filter += " = ";
						break;
					case ConstraintType.MUST_NOT:
						filter += " = ";
						break;
					case ConstraintType.SHOULD:
						filter += " LIKE ";
						isLike = true;
						break;
					case ConstraintType.SHOULD_NOT:
						filter += " NOT LIKE ";
						isLike = true;
						break;
				}
				filter += getFormattedValue(con.getInitialValue(), isLike);
			} else {
				filter += con.getFieldName();
				filter += " BETWEEN ";
				filter += getFormattedValue(con.getInitialValue(), false);
				filter += " AND ";
				filter += getFormattedValue(con.getFinalValue(), false);
			}
		}

		filter += ") AND ";
	}

	if (filter.length == 0) {
		if (filterRequired) {
			filter = "1=1";
		} else {
			filter = "1=1";
		}
	} else
		filter = filter.substring(0, filter.length - 5);

	// guarda o filtro...
	result.filter = filter;

	// retorna o resultado...
	return result;
}

function isEmpty(str) {
	return (!str || 0 === str.length);
}

function getFormattedValue(value, isLike) {
	if (isLike) {
		return "'%" + value + "%'";
	} else {
		return "'" + value + "'";
	}
}

function checkIsPK(result, qtd) {
	log.info("FUNCTION checkIsPK");
	var lines = result.split('\r');

	if (lines.length == 1) {
		var pk = result.split(';');
		if (pk.length == qtd)
			return true;
	}
	throw result;

}

function ChekExist(result) {
	var lines = result.split('\r');
	if (lines.length > 1)
		return true
	else
		return false;
}