function afterStateEntry(sequenceId) {

    var atvGerenteUnidade = 15;
    var atvGerentePortfolio = 17;
    var atvDiretorOperacional = 21;
    var atvPresidente = 23;
    var atvLiberacaoOrdem = 31;
    var atvAprovEmergencial = 144;
    var atvDiretorFinanceiro = 166;
	var atvAprovGerenteRH = 170;
	var atvAprovGerenteSESMET = 178;
	var atvAprovDiretorRH = 172;

    log.info("##0110 afterStateEntry " + sequenceId);

    
   // hAPI.setCardValue("cardData_cotacao",hAPI.getCardData(hAPI.getCardValue("nro_cotacao")));
    


    if (atvGerenteUnidade == sequenceId) {
        hAPI.setCardValue("aprovado_gerente_unidade", "on");
        calculaTotal();

    }

    if (atvGerentePortfolio == sequenceId)
        hAPI.setCardValue("aprovado_gerente_portfolio", "on");

    if (atvDiretorOperacional == sequenceId)
        hAPI.setCardValue("aprovado_diretor_operacional", "on");

    if (atvPresidente == sequenceId)
        hAPI.setCardValue("aprovado_presidente", "on");
    
    if (atvDiretorFinanceiro == sequenceId)
        hAPI.setCardValue("aprovado_diretor_financeiro", "on");

    if (atvAprovEmergencial == sequenceId)
        hAPI.setCardValue("aprovado_emergencial", "on");
    
    if (atvAprovGerenteRH == sequenceId)
        hAPI.setCardValue("aprovado_gerente_rh", "on");
    
    if (atvAprovGerenteSESMET == sequenceId)
        hAPI.setCardValue("aprovado_gerente_sesmet", "on");
    
    if (atvAprovDiretorRH == sequenceId)
        hAPI.setCardValue("aprovado_diretor_rh", "on");
    
    if(atvLiberacaoOrdem == sequenceId){
        var xml = preparaXML();
        hAPI.setCardValue("integracao_xml",xml.substring(0, 8000));
    }



 
   
}

function calculaTotal() {

    log.info("##0110 calculaTotal ");

    var processo = getValue("WKNumProces");
    var campos = hAPI.getCardData(processo);
    var contador = campos.keySet().iterator();
    var total = 0;

    while (contador.hasNext()) {

        var id = contador.next();
        var str = "seq___";

        if (id.indexOf(str) > -1) {

            var campo = campos.get(id);
            var seq = id.split("___")[1];

            var valor = hAPI.getCardValue("produto_valorTotal___" + seq);

            log.info("##0110 valor antes "+valor);
                valor = convertStringFloat(valor);
            log.info("##0110 valor depois "+valor);


            var itemcontrl = hAPI.getCardValue("itemcontrl___" + seq);
            var status = "";

            log.info("##0110 Item " + seq + " / valor " + valor + " / itemcontrl " + itemcontrl);

            if (itemcontrl != "") {

                log.info("##$$0110 Chamou Verificação");
                status = verificaAprovacaoItem(seq);

                //Monta as constraints para consulta
                var constraints = new Array();
                log.info("##$$0110 seq parametro " + seq);

                constraints.push(DatasetFactory.createConstraint("ordem_processo_origem", getValue("WKNumProces"), getValue("WKNumProces"), ConstraintType.MUST));
                constraints.push(DatasetFactory.createConstraint("ordem_childID", seq, seq, ConstraintType.MUST));


                log.info("##0110 Constraints")
                log.dir(constraints)
                //Define os campos para ordenação
                var sortingFields = new Array();

                //Busca o dataset
                var dataset = DatasetFactory.getDataset("frm_compras_aprovacao_sindico", null, constraints, sortingFields);

                log.info("##0110 DATASET")
                log.dir(dataset)
                for (var i = 0; i < dataset.rowsCount; i++) {
                    log.info("##0110 retorno " + dataset.getValue(i, "status_aprovacao"));

                    status = dataset.getValue(i, "status_aprovacao") || "";
                }

            }

            //hAPI.setCardValue("produto_status_aprovSindico___"+seq.toString(), status.toString());

            if (itemcontrl == "" || status == "aprovado") {
                total = valor + parseFloat(total);
                log.info("##0110 +total " + total);
            }


              
      


        }
    }

    log.info("##0110 totalfinal " + total);
    hAPI.setCardValue("valortotal_ordem", total);








}

function verificaAprovacaoItem(seq) {

    log.info("##$$0110 Chamou Verificação");

    var status = "";

    //Monta as constraints para consulta
    var constraints = new Array();
    log.info("##$$0110 seq parametro " + seq);

    constraints.push(DatasetFactory.createConstraint("ordem_processo_origem", getValue("WKNumProces"), getValue("WKNumProces"), ConstraintType.MUST));
    constraints.push(DatasetFactory.createConstraint("ordem_childID", seq, seq, ConstraintType.MUST));


    log.info("##$$1 Constraints")
    log.dir(constraints)
    //Define os campos para ordenação
    var sortingFields = new Array();

    //Busca o dataset
    var dataset = DatasetFactory.getDataset("frm_compras_aprovacao_sindico", null, constraints, sortingFields);

    log.info("##$$1 DATASET")
    log.dir(dataset)
    for (var i = 0; i < dataset.rowsCount; i++) {
        log.info("##$$1 dataset " + dataset.getValue(i, "status_aprovacao"));

        status = dataset.getValue(i, "status_aprovacao");
    }

    log.info("##0110 status" + status);
    return status;

}

function convertStringFloat(valor) {
    valor = String(valor);
    valor = valor.replace("R$ ", "").replace(" %", "");

    if (valor.indexOf(',') == -1) {} else {
        valor = valor.split(".").join("").replace(",", ".");
    }
    valor = parseFloat(valor);

    valor = valor.toFixed(4);

    return parseFloat(valor);
}