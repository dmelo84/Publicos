function beforeTaskSave(colleagueId, nextSequenceId, userList) {


    log.info("#BeforeTaskSave nextSequenceId:"+nextSequenceId+" colleagueId:"+colleagueId);
    log.info("#UserList");
    log.dir(userList);
    

    var WKNumProces = getValue("WKNumProces");
    hAPI.setCardValue("numero_solicitacao", WKNumProces);

    var NumState = getValue("WKNumState");

    // Acessa o valor de um campo do formulário do processo
    // var contrato = hAPI.getCardValue("tipo_solicitacao") == "contrato" || false;
    // var emergencial = hAPI.getCardValue("workflow_compra") == "emergencial" || false;
    var unidade = hAPI.getCardValue("unidade_codigo");


    // Ao completar a atividade inicial
    if((NumState == 4 || NumState == 0) && getValue("WKCompletTask").equals("true")){

        //Verifica se há item sem preço estimado
        

    }

    //Envia aprovação da necessidade para o gestor da unidade
    //if( &&  getValue("WKCompletTask").equals("true")){
    if (nextSequenceId == 28 && getValue("WKCompletTask").equals("true")) {

        log.info("#Gestores Lista Inicial NumState " + NumState + " nextSequenceId " + nextSequenceId);
        log.info(userList)
        
        var constraints = [];

        constraints.push(DatasetFactory.createConstraint("COD_UNIDADE", unidade, unidade, ConstraintType.MUST));
        constraints.push(DatasetFactory.createConstraint("UNIDADE", true, true, ConstraintType.MUST));

        var gestoresUnidade = DatasetFactory.getDataset("rm_consulta_usuario_aprovador_unidade", null, constraints, null);

        log.info("#Gestores Constraints");
        log.dir(constraints);

        log.info("#Gestores Dataset");
        log.dir(gestoresUnidade);


        if(gestoresUnidade.rowsCount > 0){

            userList.clear();

            for (var i = 0; i < gestoresUnidade.rowsCount; i++) {
                userList.add(gestoresUnidade.getValue(i, "FLUIG_LOGIN"));
            }

        } else {
            throw "\n<strong>Não foram encontrados usuários com papel de 'Gestores' para a unidade "+unidade+"</strong> \n Entre em contato com a área de Suprimentos.";
        }
        
        log.info("#Gestores Lista Final");
        log.info(userList)

    }

    if(nextSequenceId == 9 &&  getValue("WKCompletTask").equals("true")){
        
        var cardData = hAPI.getCardData(WKNumProces);
        var movimentar=true;

        var keys = cardData.keySet().toArray();

        var qtdCotacao = 0
        var qtdPedido = 0
        var qtdItem = 0

        for (var key in keys) {

            var field = keys[key]

            if (field.indexOf("numero_cotacao___") > -1) {

                var index = field.replace("numero_cotacao___", "");
                qtdItem++
                var cotacao = cardData.get("numero_cotacao___" + index) || "";
                var pedido = cardData.get("numero_pedido___" + index) || "";

                if (cotacao != "") {
                    qtdCotacao++;
                }
       
                if (pedido != "") {
                    qtdPedido++;
                }

            }

        }

        if (qtdPedido < qtdItem){

            throw "\n\n A solicitação não pode ser finalizada pois está aguardando o processo de compras. \n\n"

        }
        
        /*for (var key in keys) {
            
            var field = keys[key]
            
            if (field.indexOf("companyid___") > -1) {
                
                  var index = field.replace("companyid___", "");
                  
                  var cotacao = cardData.get("numero_cotacao___" + index) || "";
                  var pedido = cardData.get("numero_pedido___" + index) || "";
    
                  if(cotacao != ""){
    
                    throw "\n\n A solicitação não pode ser finalizada porque um ou mais itens já estão participando de cotação. \n\n"
    
                  }
    
                  if(pedido != ""){
    
                    throw "\n\n A solicitação não pode ser finalizada porque um ou mais itens estão relacionados a um pedido. \n\n"
    
                  }
            
             }
        
        }*/
    }

    if (nextSequenceId == 42 && getValue("WKCompletTask").equals("true")) {

        var comentario = getValue("WKUserComment");

        if (comentario == "") {
            throw "Obrigatório informar um Complemento justificando a reprovação.";
        }

    }


    /*

    */

}