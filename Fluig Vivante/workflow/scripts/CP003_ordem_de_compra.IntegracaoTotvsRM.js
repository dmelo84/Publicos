function preparaXML(){

    log.info("#@2511 Prepara XML")
    
    
    var processo = getValue("WKNumProces");
    var campos = hAPI.getCardData(processo);

    log.info("#@2511 Processo " + processo)
    log.dir(campos)

    var now        = new java.util.Date();
    var formatDate = new java.text.SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss");
    var dataAtual  = formatDate.format(now);
    var tipo_ordem = hAPI.getCardValue("tipo_ordem");
    var codtmv = "";

  
    //CODTMV


    //PREPARA TMOV
    var xmlTMOV = getTemplateTMOV();
        xmlTMOV = replaceValue(xmlTMOV, "CODCOLIGADA", hAPI.getCardValue("empresa_codigo"));
        xmlTMOV = replaceValue(xmlTMOV, "CODFILIAL", hAPI.getCardValue("filial").toString().split(" - ")[0]);
        xmlTMOV = replaceValue(xmlTMOV, "CODLOC", hAPI.getCardValue("local_estoque_codigo"));
        xmlTMOV = replaceValue(xmlTMOV, "CODCFO", hAPI.getCardValue("fornecedor_codigo"));

        xmlTMOV = replaceValue(xmlTMOV, "CODUSUARIO", hAPI.getCardValue("codusuario_rm"));
        xmlTMOV = replaceValue(xmlTMOV, "USUARIOCRIACAO", hAPI.getCardValue("codusuario_rm"));

        
       /* tipo_ordem == 'materiais' ? codtmv = '1.1.37' : false;
        tipo_ordem == 'ativo' ? codtmv = '1.1.37' : false;
        tipo_ordem == 'servico' ? codtmv = '1.1.37' : false;
        tipo_ordem == 'contrato' ? codtmv = '1.1.37' : false;*/

        
        xmlTMOV = replaceValue(xmlTMOV, "CODTMV", "1.1.37");
        xmlTMOV = replaceValue(xmlTMOV, "NUMEROMOV", processo.toString());
        xmlTMOV = replaceValue(xmlTMOV, "SEGUNDONUMERO", processo.toString());
        xmlTMOV = replaceValue(xmlTMOV, "SERIE", "OC");
        xmlTMOV = replaceValue(xmlTMOV, "DATAEMISSAO", dataAtual);
        xmlTMOV = replaceValue(xmlTMOV, "DATAENTREGA", campos.get("entrega_data"));
        xmlTMOV = replaceValue(xmlTMOV, "DATASAIDA", dataAtual);
        xmlTMOV = replaceValue(xmlTMOV, "DATAEXTRA2", dataAtual);
        xmlTMOV = replaceValue(xmlTMOV, "CODCPG", "15DDC");
        xmlTMOV = replaceValue(xmlTMOV, "VALORBRUTO", hAPI.getCardValue("valortotal_ordem"));
        xmlTMOV = replaceValue(xmlTMOV, "VALORLIQUIDO", hAPI.getCardValue("valortotal_ordem"));
        xmlTMOV = replaceValue(xmlTMOV, "VALOROUTROS", hAPI.getCardValue("valortotal_ordem"));
        xmlTMOV = replaceValue(xmlTMOV, "VALORFRETE", hAPI.getCardValue("valor_frete").replace("R$ ",""));

        xmlTMOV = replaceValue(xmlTMOV, "DATAMOVIMENTO", dataAtual);
        xmlTMOV = replaceValue(xmlTMOV, "CODCCUSTO", hAPI.getCardValue("ccusto_codigo"));
        xmlTMOV = replaceValue(xmlTMOV, "CAMPOLIVRE1", processo.toString());
        xmlTMOV = replaceValue(xmlTMOV, "CAMPOLIVRE2", " ");
        xmlTMOV = replaceValue(xmlTMOV, "CAMPOLIVRE3", " ");
        xmlTMOV = replaceValue(xmlTMOV, "HISTORICOLONGO", hAPI.getCardValue("observacoes"));
    
    
        log.info("#@2511 xmlTMOV")
        log.dir(xmlTMOV)

    //PREPARA TMOVCOMPL
    var xmlTMOVCOMPL = getTemplateTMOVCOMPL();

        xmlTMOVCOMPL = replaceValue(xmlTMOVCOMPL, "CODCOLIGADA", hAPI.getCardValue("empresa_codigo"));
        xmlTMOVCOMPL = replaceValue(xmlTMOVCOMPL, "FLUIG_URL_SOL", "https://conecta.vivante.com.br/portal/p/Vivante/pageworkflowview?app_ecm_workflowview_detailsProcessInstanceID="+hAPI.getCardValue("ordem_numero"));
        xmlTMOVCOMPL = replaceValue(xmlTMOVCOMPL, "CODCOMPRADOR", hAPI.getCardValue("nome_solicitante"));
        xmlTMOVCOMPL = replaceValue(xmlTMOVCOMPL, "CODPAGAMENTO", hAPI.getCardValue("condpgto"));
        log.info("#@2511 xmlTMOVCOMPL")
        log.dir(xmlTMOVCOMPL)

    //PREPARA TITMMOV
    //PERCORRE A TABELA PAI E FILHO DOS ITENS DO MOVIMENTO
    var contador = campos.keySet().iterator();
    var count = 0;
    var nseqitmmov = 0;
    var xmlITENS = "";
    var XMLTRIBITENS = "";

    while (contador.hasNext()) {
        var id = contador.next();

        if (id.match(/^seq___/)) { // 
            var campo = campos.get(id);
            var id = id.split("___")[1];


            log.dir(campos);
            log.info(campo);

            //var statusDevolvido = campos.get("statusDevolucaoAux___" + id);
    

                var xmlTITMMOV = getTemplateTITMMOV();

                xmlTITMMOV = replaceValue(xmlTITMMOV, "CODCOLIGADA", hAPI.getCardValue("empresa_codigo"));
                xmlTITMMOV = replaceValue(xmlTITMMOV, "CODFILIAL", hAPI.getCardValue("filial").toString().split(" - ")[0]);
                nseqitmmov++;
                xmlTITMMOV = replaceValue(xmlTITMMOV, "NSEQITMMOV",  campos.get("seq___"+ id));
                xmlTITMMOV = replaceValue(xmlTITMMOV, "IDPRD", campos.get("produto_idprd___" + id));
                xmlTITMMOV = replaceValue(xmlTITMMOV, "QUANTIDADE", campos.get("produto_quantidade___" + id).toString().replace("R$ ",""));
                xmlTITMMOV = replaceValue(xmlTITMMOV, "CODUND", campos.get("produto_un___" + id));
                xmlTITMMOV = replaceValue(xmlTITMMOV, "CODTBORCAMENTO", campos.get("produto_codtborcamento___" + id));
                xmlTITMMOV = replaceValue(xmlTITMMOV, "CODCCUSTO", campos.get("ccusto_codigo_item___" + id));
                xmlTITMMOV = replaceValue(xmlTITMMOV, "CODCOLTBORCAMENTO",  hAPI.getCardValue("empresa_codigo"));
                xmlTITMMOV = replaceValue(xmlTITMMOV, "PRECOUNITARIO", campos.get("produto_preco___" + id).toString().replace("R$ ",""));
                xmlTITMMOV = replaceValue(xmlTITMMOV, "CODCCUSTO", campos.get("ccusto_codigo_item___" + id));
                xmlTITMMOV = replaceValue(xmlTITMMOV, "VALORBRUTOITEM", campos.get("produto_valorTotal___" + id).toString().replace("R$ ",""));
              

                //PREENCHE O VINCULO COM O CONTRATO
                //Desativado em 17-02-20. Identificado que usuarios cadastraram todos os contratos na mesma coligada 
                //e necessitam emitir OCs para coligadas diversas
                    /*if(tipo_ordem=="contrato"){
                        xmlTITMMOV = replaceValue(xmlTITMMOV, "IDCNT", campos.get("produto_contrato_idcnt___" + id));
                        xmlTITMMOV = replaceValue(xmlTITMMOV, "NSEQITMCNT", campos.get("produto_contrato_nseqitmcnt___" + id));
                    }*/


                var xmlTTRBITMMOV = getTemplateTTRBITMMOV();

                xmlTTRBITMMOV = replaceValue(xmlTTRBITMMOV, "CODCOLIGADA", hAPI.getCardValue("empresa_codigo"));
                xmlTTRBITMMOV = replaceValue(xmlTTRBITMMOV, "NSEQITMMOV", campos.get("seq___"+ id));
                xmlTTRBITMMOV = replaceValue(xmlTTRBITMMOV, "CODTRB", "IPI");
                xmlTTRBITMMOV = replaceValue(xmlTTRBITMMOV, "BASEDECALCULO", campos.get("produto_valorTotal___" + id).toString().replace("R$ ",""));
                xmlTTRBITMMOV = replaceValue(xmlTTRBITMMOV, "ALIQUOTA", campos.get("produto_percent_ipi_iss___" + id).toString().replace(" %",""));
                xmlTTRBITMMOV = replaceValue(xmlTTRBITMMOV, "BASEDECALCULOCALCULADA", campos.get("produto_valorTotal___" + id).toString().replace("R$ ",""));



                count++

                xmlITENS += xmlTITMMOV;
                XMLTRIBITENS += xmlTTRBITMMOV;
            
        } //if campo referencia
    } //while


    //FINALIZA A CONCATENAÇÃO DOS XML'S
    var xmlEnvio = "<MovMovimento>";
        xmlEnvio += xmlTMOV ;
        xmlEnvio += xmlTMOVCOMPL;
        xmlEnvio += xmlITENS;
        xmlEnvio += XMLTRIBITENS;
        xmlEnvio += "</MovMovimento>";
    log.info("#@2511 xmlEnvio")
    log.dir(xmlEnvio);

    return xmlEnvio;

}

function integrar() {

    log.info("#@2511 integrar")


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
            context = "CODSISTEMA=T;CODCOLIGADA=" + hAPI.getCardValue("empresa_codigo") + ";CODUSUARIO=" + hAPI.getCardValue("codusuario_rm");
        }

       
        //var xmlEnvio =   hAPI.getCardValue("integracao_xml");
        var xmlEnvio = preparaXML();

        log.info("#@2511 xmlEnvio campo")
        log.dir(xmlEnvio);

        //if (xmlEnvio.length > 0) {
            var result = {};
            result = new String(authService.saveRecord(dataserver, xmlEnvio, context));

            var coligada = result.split(";")[0];
            var idmov = result.split(";")[1];

            if(checkIsPK(result, 2)){
                
                var numMov = getNumemoMov(idmov, coligada);
                hAPI.setCardValue("ordem_numero_rm", numMov);
                hAPI.setCardValue("idmov", idmov);


                enviarOCPorEmail(idmov, coligada)

                hAPI.setTaskComments(getValue("WKUser"), processo, 0, "Movimento criado com Número " + numMov + ", Id " + idmov + " na coligada " + coligada + ".")


            }
     
       // }

    } catch (e) {
        if (e == null) e = "Erro desconhecido!";
        var mensagemErro = "Ocorreu um erro ao salvar dados no RM: " + e;
        throw mensagemErro;
    }

}


function getNumemoMov(idMov,codColigada) {
	var numeroMov = null;
	var BASE_RM = "CORPORE";
	var dataSource = "java:/jdbc/AppDS";
	var ic = new javax.naming.InitialContext();
	var ds = ic.lookup(dataSource);
    //var query = "SELECT TMOV.NUMEROMOV FROM "+BASE_RM+"..TMOV WHERE TMOV.IDMOV = ?";
    var query = "select NUMEROMOV from  "+BASE_RM+".dbo.TMOV WHERE IDMOV=? AND CODCOLIGADA =?"
	var conn = ds.getConnection();
	var stmt = conn.prepareStatement(query);
    stmt.setInt(1, idMov);
    stmt.setInt(2, codColigada);
	
	try {
		var rs = stmt.executeQuery();
		
		while(rs.next()) {
			numeroMov = rs.getInt("NUMEROMOV");
		}
	} catch (e) {
		log.error("### Erro ao buscar o número do movimento: " + e);
		throw "Erro ao buscar o número do movimento: " + e;
	}  finally {
		if(stmt != null) 
			stmt.close();
		if(conn != null) 
			conn.close();                     
	}
	return numeroMov;
}

function getTemplateTTRBITMMOV(){

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
        "  <TMOV>"+
        "     <CODCOLIGADA>1</CODCOLIGADA>"+
        "     <IDMOV>-1</IDMOV>"+
        "     <CODFILIAL></CODFILIAL>"+
        "     <CODLOC></CODLOC>"+
        "     <CODCFO>49930514000135A</CODCFO>"+
        "     <NUMEROMOV>-1</NUMEROMOV>"+
        "     <SEGUNDONUMERO>-1</SEGUNDONUMERO>" +
        "     <SERIE></SERIE>"+
        "     <CODTMV></CODTMV>"+
        "     <TIPO>A</TIPO>"+
        "     <STATUS>F</STATUS>"+
        "     <DATAEMISSAO>2018-10-03</DATAEMISSAO>"+
        "     <DATASAIDA>2018-10-03</DATASAIDA>"+
        "     <DATAEXTRA2>2018-10-03</DATAEXTRA2>"+
        "     <DATAENTREGA></DATAENTREGA>" +
        "     <CODCPG>15DDC</CODCPG>"+
        "     <VALORBRUTO>1141</VALORBRUTO>"+
        "     <VALORLIQUIDO>1141</VALORLIQUIDO>"+
        "     <VALOROUTROS>1141</VALOROUTROS>"+
        "     <CODTB1FLX>0001</CODTB1FLX>"+
        "     <VALORFRETE>0.0000</VALORFRETE>"+
        "     <CODCOLCFONATUREZA>1</CODCOLCFONATUREZA>"+
        "     <IDNAT>1368</IDNAT>"+
        "      <CODCOLCFO>0</CODCOLCFO>"+
        "     <CODTB4FLX>000001</CODTB4FLX>"+
        "     <CODMOEVALORLIQUIDO>R$</CODMOEVALORLIQUIDO>"+
        "     <DATAMOVIMENTO>2018-10-03</DATAMOVIMENTO>"+
        "     <CODCCUSTO>11.11.2.0029.00.00</CODCCUSTO>"+
        "     <CODUSUARIO></CODUSUARIO>"+
        "     <CAMPOLIVRE1>251</CAMPOLIVRE1>"+
        "     <CAMPOLIVRE2>0471</CAMPOLIVRE2>"+
        "     <CAMPOLIVRE3>223</CAMPOLIVRE3>"+
        "     <USUARIOCRIACAO></USUARIOCRIACAO>"+
        "     <DATACRIACAO>2018-06-28</DATACRIACAO>"+
        "     <INTEGRAAPLICACAO>T</INTEGRAAPLICACAO>"+
        "     <HISTORICOLONGO></HISTORICOLONGO>" +
        "  </TMOV>"

    );
}

function getTemplateTMOVCOMPL() {
    return new String(
        "  <TMOVCOMPL>" +
        "    <CODCOLIGADA>1</CODCOLIGADA>" +
        "    <IDMOV>-1</IDMOV>" +
        "    <FLUIG_URL_SOL></FLUIG_URL_SOL>" +
        "    <CODCOMPRADOR></CODCOMPRADOR>" +
        "    <CODPAGAMENTO></CODPAGAMENTO>" +
        "  </TMOVCOMPL>"
    );
}

function getTemplateTITMMOV() {
    return new String(
        " <TITMMOV>"+
        "     <CODCOLIGADA>1</CODCOLIGADA>"+
        "     <IDMOV>-1</IDMOV>"+
        "     <NSEQITMMOV>1</NSEQITMMOV>"+
        "     <CODFILIAL>1</CODFILIAL>"+
        "     <NUMEROSEQUENCIAL>1</NUMEROSEQUENCIAL>"+
        "     <IDCNT></IDCNT>"+
        "     <NSEQITMCNT></NSEQITMCNT>"+
        "     <IDPRD></IDPRD>"+
        "     <CODCOLTBORCAMENTO></CODCOLTBORCAMENTO>"+
        "     <CODTBORCAMENTO></CODTBORCAMENTO>"+
        "     <CODFAB></CODFAB>"+
        "     <QUANTIDADE></QUANTIDADE>"+
        "     <PRECOUNITARIO></PRECOUNITARIO>"+
        "     <VALORDESC></VALORDESC>"+
        "     <CODTB5FAT></CODTB5FAT>"+
        "     <CODUND></CODUND>"+
        "     <CODCCUSTO></CODCCUSTO>"+
        "     <VALORBRUTOITEM></VALORBRUTOITEM>"+
        "     <PRECOEDITADO></PRECOEDITADO>"+
        "     <PRECOTOTALEDITADO></PRECOTOTALEDITADO>"+
        "     <INTEGRAAPLICACAO>T</INTEGRAAPLICACAO>"+
        "  </TITMMOV>"
    );
}

function getTemplateEmail(){

return new String(
    "<MovEnviaEmailMovParams z:Id=\"i1\" xmlns=\"http://www.totvs.com.br/RM/\" xmlns:i=\"http://www.w3.org/2001/XMLSchema-instance\" xmlns:z=\"http://schemas.microsoft.com/2003/10/Serialization/\">" +
    "  <ActionModule xmlns=\"http://www.totvs.com/\">T</ActionModule>" +
    "  <ActionName xmlns=\"http://www.totvs.com/\">MovEnviaEmailMovAction</ActionName>" +
    "  <CanParallelize xmlns=\"http://www.totvs.com/\">true</CanParallelize>" +
    "  <CanSendMail xmlns=\"http://www.totvs.com/\">false</CanSendMail>" +
    "  <CanWaitSchedule xmlns=\"http://www.totvs.com/\">false</CanWaitSchedule>" +
    "  <CodUsuario xmlns=\"http://www.totvs.com/\">mestre</CodUsuario>" +
    "  <ConnectionId i:nil=\"true\" xmlns=\"http://www.totvs.com/\" />" +
    "  <ConnectionString i:nil=\"true\" xmlns=\"http://www.totvs.com/\" />" +
    "  <Context z:Id=\"i2\" xmlns=\"http://www.totvs.com/\" xmlns:a=\"http://www.totvs.com.br/RM/\">" +
    "    <a:_params xmlns:b=\"http://schemas.microsoft.com/2003/10/Serialization/Arrays\">" +
    "      <b:KeyValueOfanyTypeanyType>" +
    "        <b:Key i:type=\"c:string\" xmlns:c=\"http://www.w3.org/2001/XMLSchema\">$EXERCICIOFISCAL</b:Key>" +
    "        <b:Value i:type=\"c:int\" xmlns:c=\"http://www.w3.org/2001/XMLSchema\">21</b:Value>" +
    "      </b:KeyValueOfanyTypeanyType>" +
    "      <b:KeyValueOfanyTypeanyType>" +
    "        <b:Key i:type=\"c:string\" xmlns:c=\"http://www.w3.org/2001/XMLSchema\">$CODLOCPRT</b:Key>" +
    "        <b:Value i:type=\"c:int\" xmlns:c=\"http://www.w3.org/2001/XMLSchema\">-1</b:Value>" +
    "      </b:KeyValueOfanyTypeanyType>" +
    "      <b:KeyValueOfanyTypeanyType>" +
    "        <b:Key i:type=\"c:string\" xmlns:c=\"http://www.w3.org/2001/XMLSchema\">$CODTIPOCURSO</b:Key>" +
    "        <b:Value i:type=\"c:int\" xmlns:c=\"http://www.w3.org/2001/XMLSchema\">-1</b:Value>" +
    "      </b:KeyValueOfanyTypeanyType>" +
    "      <b:KeyValueOfanyTypeanyType>" +
    "        <b:Key i:type=\"c:string\" xmlns:c=\"http://www.w3.org/2001/XMLSchema\">$EDUTIPOUSR</b:Key>" +
    "        <b:Value i:type=\"c:string\" xmlns:c=\"http://www.w3.org/2001/XMLSchema\">-1</b:Value>" +
    "      </b:KeyValueOfanyTypeanyType>" +
    "      <b:KeyValueOfanyTypeanyType>" +
    "        <b:Key i:type=\"c:string\" xmlns:c=\"http://www.w3.org/2001/XMLSchema\">$CODUNIDADEBIB</b:Key>" +
    "        <b:Value i:type=\"c:int\" xmlns:c=\"http://www.w3.org/2001/XMLSchema\">-1</b:Value>" +
    "      </b:KeyValueOfanyTypeanyType>" +
    "      <b:KeyValueOfanyTypeanyType>" +
    "        <b:Key i:type=\"c:string\" xmlns:c=\"http://www.w3.org/2001/XMLSchema\">$CODCOLIGADA</b:Key>" +
    "        <b:Value i:type=\"c:int\" xmlns:c=\"http://www.w3.org/2001/XMLSchema\">PAR_COLIGADA</b:Value>" +
    "      </b:KeyValueOfanyTypeanyType>" +
    "      <b:KeyValueOfanyTypeanyType>" +
    "        <b:Key i:type=\"c:string\" xmlns:c=\"http://www.w3.org/2001/XMLSchema\">$RHTIPOUSR</b:Key>" +
    "        <b:Value i:type=\"c:string\" xmlns:c=\"http://www.w3.org/2001/XMLSchema\">-1</b:Value>" +
    "      </b:KeyValueOfanyTypeanyType>" +
    "      <b:KeyValueOfanyTypeanyType>" +
    "        <b:Key i:type=\"c:string\" xmlns:c=\"http://www.w3.org/2001/XMLSchema\">$CODIGOEXTERNO</b:Key>" +
    "        <b:Value i:type=\"c:string\" xmlns:c=\"http://www.w3.org/2001/XMLSchema\">-1</b:Value>" +
    "      </b:KeyValueOfanyTypeanyType>" +
    "      <b:KeyValueOfanyTypeanyType>" +
    "        <b:Key i:type=\"c:string\" xmlns:c=\"http://www.w3.org/2001/XMLSchema\">$CODSISTEMA</b:Key>" +
    "        <b:Value i:type=\"c:string\" xmlns:c=\"http://www.w3.org/2001/XMLSchema\">T</b:Value>" +
    "      </b:KeyValueOfanyTypeanyType>" +
    "      <b:KeyValueOfanyTypeanyType>" +
    "        <b:Key i:type=\"c:string\" xmlns:c=\"http://www.w3.org/2001/XMLSchema\">$CODUSUARIOSERVICO</b:Key>" +
    "        <b:Value i:type=\"c:string\" xmlns:c=\"http://www.w3.org/2001/XMLSchema\" />" +
    "      </b:KeyValueOfanyTypeanyType>" +
    "      <b:KeyValueOfanyTypeanyType>" +
    "        <b:Key i:type=\"c:string\" xmlns:c=\"http://www.w3.org/2001/XMLSchema\">$CODUSUARIO</b:Key>" +
    "        <b:Value i:type=\"c:string\" xmlns:c=\"http://www.w3.org/2001/XMLSchema\">mestre</b:Value>" +
    "      </b:KeyValueOfanyTypeanyType>" +
    "      <b:KeyValueOfanyTypeanyType>" +
    "        <b:Key i:type=\"c:string\" xmlns:c=\"http://www.w3.org/2001/XMLSchema\">$IDPRJ</b:Key>" +
    "        <b:Value i:type=\"c:int\" xmlns:c=\"http://www.w3.org/2001/XMLSchema\">-1</b:Value>" +
    "      </b:KeyValueOfanyTypeanyType>" +
    "      <b:KeyValueOfanyTypeanyType>" +
    "        <b:Key i:type=\"c:string\" xmlns:c=\"http://www.w3.org/2001/XMLSchema\">$CHAPAFUNCIONARIO</b:Key>" +
    "        <b:Value i:type=\"c:string\" xmlns:c=\"http://www.w3.org/2001/XMLSchema\">-1</b:Value>" +
    "      </b:KeyValueOfanyTypeanyType>" +
    "      <b:KeyValueOfanyTypeanyType>" +
    "        <b:Key i:type=\"c:string\" xmlns:c=\"http://www.w3.org/2001/XMLSchema\">$CODFILIAL</b:Key>" +
    "        <b:Value i:type=\"c:int\" xmlns:c=\"http://www.w3.org/2001/XMLSchema\">1</b:Value>" +
    "      </b:KeyValueOfanyTypeanyType>" +
    "    </a:_params>" +
    "    <a:Environment>DotNet</a:Environment>" +
    "  </Context>" +
    "  <CustomData i:nil=\"true\" xmlns=\"http://www.totvs.com/\" />" +
    "  <DisableIsolateProcess xmlns=\"http://www.totvs.com/\">false</DisableIsolateProcess>" +
    "  <DriverType i:nil=\"true\" xmlns=\"http://www.totvs.com/\" />" +
    "  <ExecutionId xmlns=\"http://www.totvs.com/\"></ExecutionId>" +
    "  <FailureMessage xmlns=\"http://www.totvs.com/\">Falha na execução do processo</FailureMessage>" +
    "  <FriendlyLogs i:nil=\"true\" xmlns=\"http://www.totvs.com/\" />" +
    "  <HideProgressDialog xmlns=\"http://www.totvs.com/\">false</HideProgressDialog>" +
    "  <HostName xmlns=\"http://www.totvs.com/\">SPVBFLUIG</HostName>" +
    "  <Initialized xmlns=\"http://www.totvs.com/\">true</Initialized>" +
    "  <Ip xmlns=\"http://www.totvs.com/\">192.168.1.143</Ip>" +
    "  <IsolateProcess xmlns=\"http://www.totvs.com/\">false</IsolateProcess>" +
    "  <JobID xmlns=\"http://www.totvs.com/\">" +
    "    <Children />" +
    "    <ExecID>1</ExecID>" +
    "    <ID>-1</ID>" +
    "    <IsPriorityJob>false</IsPriorityJob>" +
    "  </JobID>" +
    "  <JobServerHostName xmlns=\"http://www.totvs.com/\">SPVBFLUIG</JobServerHostName>" +
    "  <MasterActionName xmlns=\"http://www.totvs.com/\">MovMovimentoMDIAction</MasterActionName>" +
    "  <MaximumQuantityOfPrimaryKeysPerProcess xmlns=\"http://www.totvs.com/\">1000</MaximumQuantityOfPrimaryKeysPerProcess>" +
    "  <MinimumQuantityOfPrimaryKeysPerProcess xmlns=\"http://www.totvs.com/\">1</MinimumQuantityOfPrimaryKeysPerProcess>" +
    "  <NetworkUser xmlns=\"http://www.totvs.com/\">consultor.ti2</NetworkUser>" +
    "  <NotifyEmail xmlns=\"http://www.totvs.com/\">false</NotifyEmail>" +
    "  <NotifyEmailList i:nil=\"true\" xmlns=\"http://www.totvs.com/\" xmlns:a=\"http://schemas.microsoft.com/2003/10/Serialization/Arrays\" />" +
    "  <NotifyFluig xmlns=\"http://www.totvs.com/\">false</NotifyFluig>" +
    "  <OnlineMode xmlns=\"http://www.totvs.com/\">false</OnlineMode>" +
    "  <PrimaryKeyList xmlns=\"http://www.totvs.com/\" xmlns:a=\"http://schemas.microsoft.com/2003/10/Serialization/Arrays\">" +
    "    <a:ArrayOfanyType>" +
    "      <a:anyType i:type=\"b:short\" xmlns:b=\"http://www.w3.org/2001/XMLSchema\">PAR_COLIGADA</a:anyType>" +
    "      <a:anyType i:type=\"b:int\" xmlns:b=\"http://www.w3.org/2001/XMLSchema\">PAR_IDMOV</a:anyType>" +
    "    </a:ArrayOfanyType>" +
    "  </PrimaryKeyList>" +
    "  <PrimaryKeyNames xmlns=\"http://www.totvs.com/\" xmlns:a=\"http://schemas.microsoft.com/2003/10/Serialization/Arrays\">" +
    "    <a:string>CODCOLIGADA</a:string>" +
    "    <a:string>IDMOV</a:string>" +
    "  </PrimaryKeyNames>" +
    "  <PrimaryKeyTableName xmlns=\"http://www.totvs.com/\">TMOV</PrimaryKeyTableName>" +
    "  <ProcessName xmlns=\"http://www.totvs.com/\">Enviar E-mail do Movimento</ProcessName>" +
    "  <QuantityOfSplits xmlns=\"http://www.totvs.com/\">0</QuantityOfSplits>" +
    "  <SaveLogInDatabase xmlns=\"http://www.totvs.com/\">true</SaveLogInDatabase>" +
    "  <SaveParamsExecution xmlns=\"http://www.totvs.com/\">false</SaveParamsExecution>" +
    "  <ScheduleDateTime xmlns=\"http://www.totvs.com/\">2019-12-02T08:45:21.9634499-03:00</ScheduleDateTime>" +
    "  <Scheduler xmlns=\"http://www.totvs.com/\">JobMonitor</Scheduler>" +
    "  <SendMail xmlns=\"http://www.totvs.com/\">false</SendMail>" +
    "  <ServerName xmlns=\"http://www.totvs.com/\">MovEnviaEmailMovProc</ServerName>" +
    "  <ServiceInterface i:nil=\"true\" xmlns=\"http://www.totvs.com/\" xmlns:a=\"http://schemas.datacontract.org/2004/07/System\" />" +
    "  <ShouldParallelize xmlns=\"http://www.totvs.com/\">false</ShouldParallelize>" +
    "  <ShowReExecuteButton xmlns=\"http://www.totvs.com/\">true</ShowReExecuteButton>" +
    "  <StatusMessage i:nil=\"true\" xmlns=\"http://www.totvs.com/\" />" +
    "  <SuccessMessage xmlns=\"http://www.totvs.com/\">Processo executado com sucesso</SuccessMessage>" +
    "  <SyncExecution xmlns=\"http://www.totvs.com/\">false</SyncExecution>" +
    "  <UseJobMonitor xmlns=\"http://www.totvs.com/\">true</UseJobMonitor>" +
    "  <UserName xmlns=\"http://www.totvs.com/\">mestre</UserName>" +
    "  <WaitSchedule xmlns=\"http://www.totvs.com/\">false</WaitSchedule>" +
    "  <Anexo />" +
    "  <ArquivoAnexo i:nil=\"true\" />" +
    "  <Assunto>Movimento Nº 000000021 - Ordem de Compra</Assunto>" +
    "  <CodColRelAnexo>0</CodColRelAnexo>" +
    "  <CodColRelCorpo i:nil=\"true\" />" +
    "  <CorpoEmail>----</CorpoEmail>" +
    "  <EnviarCompradorVendedor>false</EnviarCompradorVendedor>" +
    "  <EnviarContatosCliente>false</EnviarContatosCliente>" +
    "  <EnviarEmailFornecedor>false</EnviarEmailFornecedor>" +
    "  <EnviarRepresentante>false</EnviarRepresentante>" +
    "  <EnviarTransportadora>false</EnviarTransportadora>" +
    "  <EnviarUsuarioLogado>false</EnviarUsuarioLogado>" +
    "  <FormatoAnexo>REL</FormatoAnexo>" +
    "  <FormatoAnexoDotNet>PDF</FormatoAnexoDotNet>" +
    "  <IdRelAnexo>135</IdRelAnexo>" +
    "  <IdRelCorpo i:nil=\"true\" />" +
    "  <ListaMovimento xmlns:a=\"http://www.totvs.com/\">" +
    "    <a:MovIdMov z:Id=\"i3\">" +
    "      <a:InternalId i:nil=\"true\" />" +
    "      <CodColigada>PAR_COLIGADA</CodColigada>" +
    "      <EmailContatos xmlns:b=\"http://schemas.microsoft.com/2003/10/Serialization/Arrays\" />" +
    "      <IdMov>PAR_IDMOV</IdMov>" +
    "    </a:MovIdMov>" +
    "  </ListaMovimento>" +
    "  <OutrosDestinatarios>rcoelho@vivante.com.br</OutrosDestinatarios>" +
    "  <ParametersRelAnexo xmlns:a=\"http://www.totvs.com/\">" +
    "    <a:RMSReportParams z:Id=\"i4\">" +
    "      <a:Descricao>COLIGADA</a:Descricao>" +
    "      <a:Ordem>0</a:Ordem>" +
    "      <a:Value i:type=\"b:string\" xmlns:b=\"http://www.w3.org/2001/XMLSchema\">PAR_COLIGADA</a:Value>" +
    "    </a:RMSReportParams>" +
    "    <a:RMSReportParams z:Id=\"i5\">" +
    "      <a:Descricao>IDMOV</a:Descricao>" +
    "      <a:Ordem>1</a:Ordem>" +
    "      <a:Value i:type=\"b:string\" xmlns:b=\"http://www.w3.org/2001/XMLSchema\">PAR_IDMOV</a:Value>" +
    "    </a:RMSReportParams>" +
    "  </ParametersRelAnexo>" +
    "  <ParametersRelCorpo xmlns:a=\"http://www.totvs.com/\" />" +
    "  <RelatorioAnexoDotNet>true</RelatorioAnexoDotNet>" +
    "  <RelatorioCorpoDotNet>true</RelatorioCorpoDotNet>" +
    "</MovEnviaEmailMovParams> " 
)

}

function replaceValue(text, columnName, newValue) {


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

function enviarOCPorEmail(idmov,coligada){




    var xml = getTemplateEmail();

    xml = xml.replace(/PAR_COLIGADA/g, coligada)//replaceValue(xml, "IdMov", idmov);
    xml = xml.replace(/PAR_IDMOV/g, idmov)
    xml = replaceValue(xml, "Assunto", "Ordem de Compra Aprovada: " + getValue("WKNumProces"));
    xml = replaceValue(xml, "OutrosDestinatarios", "felipelouzada@gmail.com");

    
    var textoEmail = "Prezados(as) \n"+
                     "Ordem de compra em anexo aprovada, se atentar aos dados de faturamento e as informações obrigatórias da NF, enviar a nota fiscal  para recebimentofiscal@vivante.com.br Cc triagem_fiscal@vivante.com.br"

    xml = replaceValue(xml, "CorpoEmail", textoEmail);

    log.info("##0312 xml email")
    log.info(xml)

    //Monta as constraints para consulta
    var constraints = new Array();
    constraints.push(DatasetFactory.createConstraint("string_xml", xml, xml, ConstraintType.MUST));
    constraints.push(DatasetFactory.createConstraint("dataserver", "MovEnviaEmailMovProc", "MovEnviaEmailMovProc", ConstraintType.MUST)); //Coligada da FV, 0 == Global


    //Define os campos para ordenação
    var sortingFields = new Array();

    //Busca o dataset

    log.info("RRR constraints")
    log.dir(constraints)

    try {

        var dataset = DatasetFactory.getDataset("rm_executa_processo", null, constraints, sortingFields);

        log.info("RRR dataset")
        log.dir(dataset)

    } catch (error) {

        log.info("RRR ERRO")
        log.info("Ocorreu um erro ao enviar o e-mail: " + error);

    }

    
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
