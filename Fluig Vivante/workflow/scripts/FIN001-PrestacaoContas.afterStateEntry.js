function afterStateEntry(sequenceId){


    var atividade_inicio        = 4;
    var ativAprovacaoGestor     = 15;
    var ativAprovacaoContabil   = 22;
    var ativRelatorioPendente   = 7;
    var ativRetornadoGestor     = 32;
    var ativRetornadoContabil   = 29;




    if(sequenceId == ativAprovacaoGestor || sequenceId == ativAprovacaoContabil ){


      //  hAPI.setCardValue("justificativa_aprovador","");
      //  hAPI.setCardValue("justificativa_contabil","");
    }


    if(sequenceId == ativRetornadoGestor ){
    
        hAPI.setTaskComments(getValue("WKUser"), getValue("WKNumProces"),  0,  hAPI.getCardValue("justificativa_aprovador"))
    }

    if(sequenceId == ativRetornadoContabil ){
    
        hAPI.setTaskComments(getValue("WKUser"), getValue("WKNumProces"),  0,  hAPI.getCardValue("justificativa_contabil"))
    }


    if(sequenceId == 41){

        log.info("#)) Entrou atividade 41")
        
       
        var xmlIntegracao = hAPI.getCardValue("integracao_xml") || "";

        log.info("#)) xmlIntegracao");
        log.info(xmlIntegracao);

        if(xmlIntegracao == ""){
            var xml = preparaXML();
            hAPI.setCardValue("integracao_xml",xml);

            log.info("#)) xml");
            log.info(xml);
        }
}


}