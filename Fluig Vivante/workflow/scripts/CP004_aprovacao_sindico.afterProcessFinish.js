function afterProcessFinish(processId){


    
    log.info("##$$ CP004 afterProcessFinish  ");

    var orderNumProcess =   parseInt(hAPI.getCardValue("ordem_processo_origem"));

  
    var campos = hAPI.getCardData(processId);

    log.info("##$$ carddata  ");
    log.dir(campos);
    
    log.info("##$$ CP004 orderNumProcess  "+orderNumProcess);

    
    
    var item = hAPI.getCardValue("produto_nome");
    var status_aprovacao = hAPI.getCardValue("status_aprovacao");
    var data = new Date();
    var aprovador = hAPI.getCardValue("aprovador");

    var str_aprovacao="<font color='green'>"+status_aprovacao.toLocaleUpperCase()+"</font>";
    status_aprovacao != "aprovado" ? str_aprovacao = "<font color='red'>"+status_aprovacao.toLocaleUpperCase()+"</font>" :false;


    var str_obs = "O produto/serviço "+item.toLocaleUpperCase()+" foi "+str_aprovacao;

    
    moveWorkflowPurchaseOrder(orderNumProcess,str_obs);

}



function moveWorkflowPurchaseOrder(orderNumProcess,str_obs){

 
    loading.setMessage("Atualizando Ordem de Compra ");
    
    var url = "com.totvs.technology.ecm.workflow.ws.";

    var wfServiceProvider = ServiceManager.getServiceInstance("ECMWorkflowEngineService");
    var wfServiceLocator = wfServiceProvider.instantiate(url+"ECMWorkflowEngineServiceService");
    var wfService = wfServiceLocator.getWorkflowEngineServicePort();

    var colleagueIds = wfServiceProvider.instantiate("net.java.dev.jaxb.array.StringArray")

    colleagueIds.getItem().add("consultor.ti2");
       // colleaguesId.getItem().add("sindico01");

    var ProcessAttachmentDtoArray = wfServiceProvider.instantiate(url+"ProcessAttachmentDtoArray");
    var ProcessTaskAppointmentDtoArray = wfServiceProvider.instantiate(url+"ProcessTaskAppointmentDtoArray");
    var KeyValueDtoArray = wfServiceProvider.instantiate(url+"KeyValueDtoArray");



    //TODO: Alterar o usuário e senha fixo pela busca em parâmetros
    var user = "fluigadmin";
    var password = "Nuncamudar@2020";

    log.info("##$$ CP004 takeProcessTask  ");

    /*wfService.takeProcessTask(  user,
                                password, 
                                parseInt(getValue("WKCompany")), 
                                getValue("WKUser"), 
                                orderNumProcess, 
                                0);


                                log.info("##$$ CP004 saveAndSendTaskClassic  ");*/



    wfService.saveAndSendTaskClassic(
                    user, 
                    password, 
                    parseInt(getValue("WKCompany")), 
                    orderNumProcess,
                    parseInt(hAPI.getCardValue("NumAtividadeMovimentada")),//113,
                    colleagueIds,
                    "",
                    getValue("WKUser"),// "felipe.louzada",
                    true,
                    ProcessAttachmentDtoArray,
                    KeyValueDtoArray,
                    ProcessTaskAppointmentDtoArray,
                    false,
                    parseInt(0));
                    
                    log.info("##4 saveAndSendTaskClassic " + orderNumProcess);

                    hAPI.setTaskComments(getValue("WKUser"), orderNumProcess,  0, str_obs)
                    loading.setMessage("");
}