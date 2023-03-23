function preparaXML() {

    log.info("#)) Prepara XML")


    var processo = getValue("WKNumProces");
    var campos = hAPI.getCardData(processo);

    log.info("#)) Prepara XML campos")
    log.dir(campos);

    var now = new java.util.Date();
    var formatDate = new java.text.SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss");
    var dataAtual = formatDate.format(now);

    var codtmv = "";


    //CODTMV


    //PREPARA TMOV
    var xmlTMOV = getTemplateTMOV();

    log.info("#)) Prepara XML TMOV");
    xmlTMOV = replaceValue(xmlTMOV, "CODCOLIGADA", hAPI.getCardValue("empresa_codigo"));

    var recurso = hAPI.getCardValue("recurso");
    var CODCFO = hAPI.getCardValue("codcfo_favorecido");
    var serie = "1";



    if (recurso == "recurso_cartao_corporativo") {

        CODCFO = hAPI.getCardValue("codcfo_favorecido");
        codtmv = '1.1.40';
        serie = "PCFC";
    }

    if (recurso == "recurso_proprio") {

        codtmv = '1.1.39';
        serie = "PCFR";

    }

    xmlTMOV = replaceValue(xmlTMOV, "NUMEROMOV", processo.toString());
    xmlTMOV = replaceValue(xmlTMOV, "CODCFO", CODCFO);
    xmlTMOV = replaceValue(xmlTMOV, "CODTMV", codtmv);
    xmlTMOV = replaceValue(xmlTMOV, "SERIE", serie);
    xmlTMOV = replaceValue(xmlTMOV, "DATAEMISSAO", dataAtual);
    xmlTMOV = replaceValue(xmlTMOV, "DATASAIDA", dataAtual);
    xmlTMOV = replaceValue(xmlTMOV, "DATAEXTRA2", dataAtual);
    xmlTMOV = replaceValue(xmlTMOV, "CODCPG", "15DDC");
    xmlTMOV = replaceValue(xmlTMOV, "VALORBRUTO", hAPI.getCardValue("valor_total_despesas").replace("R$ ", ""));
    xmlTMOV = replaceValue(xmlTMOV, "VALORLIQUIDO", hAPI.getCardValue("valor_total_despesas").replace("R$ ", ""));
    xmlTMOV = replaceValue(xmlTMOV, "VALOROUTROS", hAPI.getCardValue("valor_total_despesas").replace("R$ ", ""));
    xmlTMOV = replaceValue(xmlTMOV, "DATAMOVIMENTO", dataAtual);
    xmlTMOV = replaceValue(xmlTMOV, "CODCCUSTO", hAPI.getCardValue("ccusto_codigo"));
    xmlTMOV = replaceValue(xmlTMOV, "CAMPOLIVRE1", "");
    xmlTMOV = replaceValue(xmlTMOV, "CAMPOLIVRE2", "");
    xmlTMOV = replaceValue(xmlTMOV, "CAMPOLIVRE3", "");
    xmlTMOV = replaceValue(xmlTMOV, "USUARIOCRIACAO", hAPI.getCardValue("codusuario_rm"));



    

    //PREPARA TMOVCOMPL
    /*  var xmlTMOVCOMPL = getTemplateTMOVCOMPL();
  
          xmlTMOVCOMPL = replaceValue(xmlTMOVCOMPL, "CODCOLIGADA", hAPI.getCardValue("empresa_codigo"));
          xmlTMOVCOMPL = replaceValue(xmlTMOVCOMPL, "FLUIG_NRO_SOL", processo);
        //  xmlTMOVCOMPL = replaceValue(xmlTMOVCOMPL, "FLUIG_URL_SOL", "https://conecta.vivante.com.br/portal/p/Vivante/pageworkflowview?app_ecm_workflowview_detailsProcessInstanceID="+processo);
  */

    //PREPARA TITMMOV
    //PERCORRE A TABELA PAI E FILHO DOS ITENS DO MOVIMENTO
    var contador = campos.keySet().iterator();
    var count = 0;
    var nseqitmmov = 0;
    var xmlITENS = "";
    var xmlITENSCOMPL = "";

    while (contador.hasNext()) {
        var id = contador.next();

        if (id.match(/seq___/)) { // 
            var campo = campos.get(id);
            var id = id.split("___")[1];


            log.dir(campos);
            log.info(campo);

            //var statusDevolvido = campos.get("statusDevolucaoAux___" + id);

            log.info("#)) Prepara XML TITMMOV");
            var xmlTITMMOV = getTemplateTITMMOV();

            xmlTITMMOV = replaceValue(xmlTITMMOV, "CODCOLIGADA", hAPI.getCardValue("empresa_codigo"));
            //   xmlTITMMOV = replaceValue(xmlTITMMOV, "CODFILIAL", hAPI.getCardValue("filial").toString().split(" - ")[0]);
            //    xmlTITMMOV = replaceValue(xmlTITMMOV, "CODLOC", hAPI.getCardValue("local_estoque_codigo"));
            nseqitmmov++;
            xmlTITMMOV = replaceValue(xmlTITMMOV, "NSEQITMMOV", campos.get("seq___" + id));

            xmlTITMMOV = replaceValue(xmlTITMMOV, "IDPRD", campos.get("despesa_idprd___" + id));
            xmlTITMMOV = replaceValue(xmlTITMMOV, "QUANTIDADE", campos.get("quantidade___" + id).toString().replace("R$ ", ""));
            xmlTITMMOV = replaceValue(xmlTITMMOV, "CODUND", campos.get("despesa_codund___" + id));

            xmlTITMMOV = replaceValue(xmlTITMMOV, "CODTBORCAMENTO", campos.get("despesa_codtborcamento___" + id));
            xmlTITMMOV = replaceValue(xmlTITMMOV, "CODCCUSTO", campos.get("ccusto_codigo_item___" + id));
            xmlTITMMOV = replaceValue(xmlTITMMOV, "CODCOLTBORCAMENTO", hAPI.getCardValue("empresa_codigo"));



            xmlTITMMOV = replaceValue(xmlTITMMOV, "PRECOUNITARIO", campos.get("valor_unitario___" + id).toString().replace("R$ ", ""));
            xmlTITMMOV = replaceValue(xmlTITMMOV, "CODCCUSTO", hAPI.getCardValue("ccusto_codigo"));
            xmlTITMMOV = replaceValue(xmlTITMMOV, "VALORBRUTOITEM", campos.get("valor_despesa___" + id).toString().replace("R$ ", ""));
            xmlTITMMOV = replaceValue(xmlTITMMOV, "DATAENTREGA", dataAtual);


            /*PREENCHE CAMPOS COMPLEMENTARES*/

            if (campos.get("doc_numero___" + id) != ""){
                
                var xmTITMMOVCOMPL = getTemplateTITMMOVCOMPL();
  
                xmTITMMOVCOMPL = replaceValue(xmTITMMOVCOMPL, "CODCOLIGADA", hAPI.getCardValue("empresa_codigo"));
                xmTITMMOVCOMPL = replaceValue(xmTITMMOVCOMPL, "NSEQITMMOV", campos.get("seq___" + id));
                xmTITMMOVCOMPL = replaceValue(xmTITMMOVCOMPL, "NUMERO_DOCUMENTO", campos.get("doc_numero___" + id));
                xmTITMMOVCOMPL = replaceValue(xmTITMMOVCOMPL, "CNPJ", campos.get("doc_cnpj___" + id));

                xmlITENSCOMPL += xmTITMMOVCOMPL;
            }
     

            count++

            xmlITENS += xmlTITMMOV;
          

        } //if campo referencia
    } //while


    //FINALIZA A CONCATENAÇÃO DOS XML'S
    var xmlEnvio = "<MovMovimento>";
    xmlEnvio += xmlTMOV;
    //   xmlEnvio += xmlTMOVCOMPL;
    xmlEnvio += xmlITENS;
    xmlEnvio += xmlITENSCOMPL;
    xmlEnvio += "</MovMovimento>";

    log.info("#) XML")
    log.dir(xmlEnvio);

    return xmlEnvio;

}

function integrar() {

    var processo = getValue("WKNumProces");
    var campos = hAPI.getCardData(processo);
    var formatDate = new java.text.SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss");

    var dataserver = "MovMovimentoTBCData";
    var usuario = "integra_fluig";
    var senha = "vb220590";
    var context;


    var authService = getWebService(usuario, senha);

    try {
        if (isEmpty(hAPI.getCardValue("empresa_codigo"))) {
            throw "Necessário informar o código da coligada.";
        } else {
            context = "CODSISTEMA=T;CODCOLIGADA=" + hAPI.getCardValue("empresa_codigo") + ";CODUSUARIO=" + usuario;
        }


        var xmlEnvio = hAPI.getCardValue("integracao_xml");

        log.info("##6 xmlEnvio")
        log.dir(xmlEnvio);

        //if (xmlEnvio.length > 0) {
        var result = {};
        result = new String(authService.saveRecord(dataserver, xmlEnvio, context));

        var coligada = result.split(";")[0];
        var idmov = result.split(";")[1];

        checkIsPK(result, 2);
        var numMov = getNumemoMov(idmov, coligada);
        hAPI.setCardValue("numeromov", numMov);
        hAPI.setCardValue("idmov", idmov);

        // }

    } catch (e) {
        if (e == null) e = "Erro desconhecido!";
        var mensagemErro = "Ocorreu um erro ao salvar dados no RM: " + e;






        throw mensagemErro;
    }

}


function getNumemoMov(idMov, codColigada) {
    var numeroMov = null;
    var BASE_RM = "CORPORE";
    var dataSource = "java:/jdbc/FluigJDBC";
    var ic = new javax.naming.InitialContext();
    var ds = ic.lookup(dataSource);
    //var query = "SELECT TMOV.NUMEROMOV FROM "+BASE_RM+"..TMOV WHERE TMOV.IDMOV = ?";
    var query = "select NUMEROMOV from  " + BASE_RM + ".dbo.TMOV WHERE IDMOV=? AND CODCOLIGADA =?"
    var conn = ds.getConnection();
    var stmt = conn.prepareStatement(query);
    stmt.setInt(1, idMov);
    stmt.setInt(2, codColigada);

    try {
        var rs = stmt.executeQuery();

        while (rs.next()) {
            numeroMov = rs.getInt("NUMEROMOV");
        }
    } catch (e) {
        log.error("### Erro ao buscar o número do movimento: " + e);
        throw "Erro ao buscar o número do movimento: " + e;
    } finally {
        if (stmt != null)
            stmt.close();
        if (conn != null)
            conn.close();
    }
    return numeroMov;
}

function getTemplateTTRBITMMOV() {

    return new String(
        "  <TTRBITMMOV>" +
        "    <CODCOLIGADA></CODCOLIGADA>" +
        "    <IDMOV>-1</IDMOV>" +
        "    <NSEQITMMOV></NSEQITMMOV>" +
        "    <CODTRB></CODTRB>" +
        "    <BASEDECALCULO></BASEDECALCULO>" +
        "    <ALIQUOTA></ALIQUOTA>" +
        "    <VALOR></VALOR>" +
        "    <FATORREDUCAO></FATORREDUCAO>" +
        "    <FATORSUBSTTRIB></FATORSUBSTTRIB>" +
        "    <BASEDECALCULOCALCULADA></BASEDECALCULOCALCULADA>" +
        "    <EDITADO>0</EDITADO>" +
        "    <PERCDIFERIMENTOPARCIALICMS></PERCDIFERIMENTOPARCIALICMS>" +
        "    <BASECHEIA></BASECHEIA>" +
        "    <RECCREATEDBY></RECCREATEDBY>" +
        "    <RECCREATEDON></RECCREATEDON>" +
        "    <RECMODIFIEDBY></RECMODIFIEDBY>" +
        "    <RECMODIFIEDON></RECMODIFIEDON>" +
        "  </TTRBITMMOV>"
    )
}

function getTemplateTMOV() {

    return new String(
        "  <TMOV>" +
        "     <CODCOLIGADA>1</CODCOLIGADA>" +
        "     <IDMOV>-1</IDMOV>" +
        "     <CODFILIAL>1</CODFILIAL>" +
        "     <CODLOC>0029</CODLOC>" +
        "     <CODCFO></CODCFO>" +
        "     <NUMEROMOV>-1</NUMEROMOV>" +
        "     <SERIE>OC</SERIE>" +
        "     <CODTMV>1.1.38</CODTMV>" +
        "     <TIPO>A</TIPO>" +
        "     <STATUS>F</STATUS>" +
        "     <DATAEMISSAO>2018-10-03</DATAEMISSAO>" +
        "     <DATASAIDA>2018-10-03</DATASAIDA>" +
        "     <DATAEXTRA2>2018-10-03</DATAEXTRA2>" +
        "     <CODCPG>15DDC</CODCPG>" +
        "     <VALORBRUTO>1141</VALORBRUTO>" +
        "     <VALORLIQUIDO>1141</VALORLIQUIDO>" +
        "     <VALOROUTROS>1141</VALOROUTROS>" +
        "     <CODTB1FLX>0001</CODTB1FLX>" +
        "     <VALORFRETE>0.0000</VALORFRETE>" +
        "     <CODCOLCFONATUREZA>1</CODCOLCFONATUREZA>" +
        "     <IDNAT>1368</IDNAT>" +
        "      <CODCOLCFO>0</CODCOLCFO>" +
        "     <CODTB4FLX>000897</CODTB4FLX>" +
        "     <CODMOEVALORLIQUIDO>R$</CODMOEVALORLIQUIDO>" +
        "     <DATAMOVIMENTO>2018-10-03</DATAMOVIMENTO>" +
        "     <CODCCUSTO>11.11.2.0029.00.00</CODCCUSTO>" +
        "     <CODUSUARIO>prismaint</CODUSUARIO>" +
        "     <CAMPOLIVRE1>251</CAMPOLIVRE1>" +
        "     <CAMPOLIVRE2>0471</CAMPOLIVRE2>" +
        "     <CAMPOLIVRE3>223</CAMPOLIVRE3>" +
        "     <USUARIOCRIACAO>prismaint</USUARIOCRIACAO>" +
        "     <DATACRIACAO>2018-06-28</DATACRIACAO>" +
        "     <INTEGRAAPLICACAO>T</INTEGRAAPLICACAO>" +
        "  </TMOV>"

    );
}


function getTemplateTMOVCOMPL() {
    return new String(
        "  <TMOVCOMPL>" +
        "    <CODCOLIGADA>1</CODCOLIGADA>" +
        "    <IDMOV>-1</IDMOV>" +
        "    <FLUIG_NRO_SOL>2212992</FLUIG_NRO_SOL>" +
        "    <FLUIG_URL_SOL>2212992</FLUIG_URL_SOL>" +
        "  </TMOVCOMPL>"
    );
}


function getTemplateTITMMOV() {
    return new String(
        " <TITMMOV>" +
        "     <CODCOLIGADA>1</CODCOLIGADA>" +
        "     <IDMOV>-1</IDMOV>" +
        "     <NSEQITMMOV>1</NSEQITMMOV>" +
        "     <CODFILIAL>1</CODFILIAL>" +
        "     <NUMEROSEQUENCIAL>1</NUMEROSEQUENCIAL>" +
        "     <IDCNT></IDCNT>" +
        "     <NSEQITMCNT></NSEQITMCNT>" +
        "     <IDPRD></IDPRD>" +
        //    "     <CODIGOPRD>18185</CODIGOPRD>"+
        //    "     <NOMEFANTASIA>REFEICAO</NOMEFANTASIA>"+
        //    "     <CODIGOREDUZIDO>18185</CODIGOREDUZIDO>"+
        "     <DATAENTREGA></DATAENTREGA>" +
        "     <CODCOLTBORCAMENTO></CODCOLTBORCAMENTO>" +
        "     <CODTBORCAMENTO></CODTBORCAMENTO>" +
        "     <CODFAB></CODFAB>" +
        "     <QUANTIDADE></QUANTIDADE>" +
        "     <PRECOUNITARIO></PRECOUNITARIO>" +
        "     <VALORDESC></VALORDESC>" +
        "     <CODTB5FAT></CODTB5FAT>" +
        "     <CODUND></CODUND>" +
        //   "     <QUANTIDADEARECEBER></QUANTIDADEARECEBER>"+
        "     <CODCCUSTO></CODCCUSTO>" +
        "     <VALORBRUTOITEM></VALORBRUTOITEM>" +
        "     <PRECOEDITADO></PRECOEDITADO>" +
        "     <PRECOTOTALEDITADO></PRECOTOTALEDITADO>" +
        "     <CODLOC>0029</CODLOC>" +
        "     <INTEGRAAPLICACAO>T</INTEGRAAPLICACAO>" +
        "  </TITMMOV>"
    );
}

function getTemplateTITMMOVCOMPL() {



    return new String(
        "<TITMMOVCOMPL>" +
        "<CODCOLIGADA></CODCOLIGADA>" +
        "<IDMOV>-1</IDMOV>" +
        "<NSEQITMMOV></NSEQITMMOV>" +
        "<NUMERO_DOCUMENTO></NUMERO_DOCUMENTO>" +
        "<CNPJ></CNPJ>" +
        "</TITMMOVCOMPL>"

    );
}

function replaceValue(text, columnName, newValue) {

    log.info("RPC text " + text + " columnName " + columnName + " newValue " + newValue);

    if ((newValue != null) && (newValue.trim() != "")) {
        var regex = new RegExp("<" + columnName + ">(.*?)<\\/" + columnName + ">", "g");
        var replaceText = "<" + columnName + ">" + newValue + "</" + columnName + ">";

        return text.replace(regex, replaceText);
    } else
        return text;
}


function isEmpty(str) {
    return (!str || 0 === str.length);
}




function getWebService(Usuario, Senha) {

    var Nome_Servico = "wsDataServer";
    var Caminho_Servico = "com.totvs.WsDataServer";

    var dataServerService = ServiceManager.getServiceInstance(Nome_Servico);
    if (dataServerService == null) {
        throw "Servico nao encontrado: " + Nome_Servico;
    }

    var serviceLocator = dataServerService.instantiate(Caminho_Servico);
    if (serviceLocator == null) {
        throw "Instancia do servico nao encontrada: " + Nome_Servico + " - " + Caminho_Servico;
    }

    var service = serviceLocator.getRMIwsDataServer();
    if (service == null) {
        throw "Instancia do dataserver do invalida: " + Nome_Servico + " - " + Caminho_Servico;
    }

    var serviceHelper = dataServerService.getBean();
    if (serviceHelper == null) {
        throw "Instancia do service helper invalida: " + Nome_Servico + " - " + Caminho_Servico;
    }

    var authService = serviceHelper.getBasicAuthenticatedClient(service, "com.totvs.IwsDataServer", Usuario, Senha);
    if (serviceHelper == null) {
        throw "Instancia do auth service invalida: " + Nome_Servico + " - " + Caminho_Servico;
    }

    return authService;
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
