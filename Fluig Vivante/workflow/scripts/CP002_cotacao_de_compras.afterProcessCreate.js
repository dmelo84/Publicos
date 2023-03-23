function afterProcessCreate(processId){

  var WKNumProces=getValue("WKNumProces");
  var WKNumState = parseInt(getValue("WKNumState"));

  //Passa número do processo criado para o campo "numero_cotacao"
  hAPI.setCardValue("numero_cotacao", WKNumProces);

  //Ao criar a Cotação, atualiza as solicitações com seu respectivo número de cotação
  checkPurchaseRequest();

   //Ao criar a Cotação, cria pasta no ECM para armazenar os anexos
  criaPastaAnexosECM(WKNumProces);


}

function checkPurchaseRequest(){

    var cardDataFields = hAPI.getCardData(getValue("WKNumProces"));
    var item = cardDataFields.keySet().iterator();
  
    loading.setMessage("Atualizando Solicitações de Compras...");
    
    while (item.hasNext()) {
        
        var field = item.next();
  
        if (field.match(/^item_seq___/)) { 
            
            var id   = field.split("___")[1];
            updatePurchaseRequest(id);
        }
    }
}

function updatePurchaseRequest(id)
{

    log.info("updatePurchaseRequest id "+id);
    var cardServiceProvider = ServiceManager.getServiceInstance("ECMCardService");
    var cardServiceLocator = cardServiceProvider.instantiate("com.totvs.technology.ecm.dm.ws.ECMCardServiceService");
    var cardService = cardServiceLocator.getCardServicePort();
    var cardFieldDtoArray = cardServiceProvider.instantiate("com.totvs.technology.ecm.dm.ws.CardFieldDtoArray");
    var cardField = cardServiceProvider.instantiate("com.totvs.technology.ecm.dm.ws.CardFieldDto");

    var campo = "numero_cotacao___" + hAPI.getCardValue("solicitacao_item_seq___"+id);
    var valor = getValue("WKNumProces");
    var documentid = hAPI.getCardValue("solicitacao_documentid___"+id)
    var solicitacao_numero = hAPI.getCardValue("solicitacao_numero___"+id)
    var produto_descricao = hAPI.getCardValue("produto_descricao___"+id)

    cardField.setField(campo);
    cardField.setValue(valor);

    cardFieldDtoArray.getItem().add(cardField);

    //hAPI.setTaskComments(, orderNumProcess,  0, str_obs)

   
    log.info("cardFieldDtoArray id "+id);
    log.dir(cardFieldDtoArray)

    var user = getUsuarioIntegracao(getValue("WKUser"));


    try {
        
        var taskUpdated = cardService.updateCardData(1, user.login, user.password, parseInt(documentid), cardFieldDtoArray);
        
        if(taskUpdated.item.get(0).webServiceMessage=="ok"){
            hAPI.setTaskComments(getValue("WKUser"), solicitacao_numero,  0, "O item <strong>"+produto_descricao+"</strong> entrou no processo de cotação número <strong>"+valor+"</strong>");
        }
          
    } catch (error) {
        throw "Ocorreu um erro ao atualizar a solicitação de origem. \n"+error;
    }
   
}

function criaPastaAnexosECM(WKNumProces){

    var folderIdPrincipal = 1365; //Código da Pasta de Primeiro nível onde serão criados as pastas individuais das cotações;
    var nome_pasta_cotacao = WKNumProces; //Nome que será atribuido a pasta da cotação, por convensão, será o nro da solicitação (cotação);

    var dto = docAPI.newDocumentDto();
        dto.setDocumentDescription(nome_pasta_cotacao);
        dto.setDocumentType("1");
        dto.setParentDocumentId(folderIdPrincipal);
        dto.setDocumentTypeId("");

    var folderCotacao = docAPI.createFolder(dto, null, null);

    var cotacao_folderId = folderCotacao.getDocumentId();

    hAPI.setCardValue("cotacao_folderId",cotacao_folderId);


    //Cria pasta para cada fornecedor


    var cardDataFields = hAPI.getCardData(getValue("WKNumProces"));
    var item = cardDataFields.keySet().iterator();
  
    //loading.setMessage("Atualizando Solicitações de Compras...");
    
    while (item.hasNext()) {
        
        var field = item.next();
  
        if (field.match(/^forn_nome___/)) { 
            
            var id  = field.split("___")[1];


            var dto = docAPI.newDocumentDto();
            dto.setDocumentDescription(hAPI.getCardValue("forn_razaosocial___"+id));
            dto.setDocumentType("1");
            dto.setParentDocumentId(cotacao_folderId);
            dto.setDocumentTypeId("");
    
             var folderFornecedor = docAPI.createFolder(dto, null, null);
        
            var forn_folderId = folderFornecedor.getDocumentId();
        
            hAPI.setCardValue("forn_folderId___"+id,forn_folderId);


           
        }
    }


    /*
    * Armazena no GED
    ---------------------------------------------------------------- */
    var calendar = java.util.Calendar.getInstance().getTime();
    var docs = hAPI.listAttachments(); //Pega os anexos do processo
    var anexos = new java.util.ArrayList();


}

function getUsuarioIntegracao(login){

    var retorno={};
      //Monta as constraints para consulta
      var constraints   = new Array();
      constraints.push(DatasetFactory.createConstraint("login", login, login, ConstraintType.MUST));
       
      //Define os campos para ordenação
      var sortingFields = new Array();
       
      //Busca o dataset
      var dataset = DatasetFactory.getDataset("fluig_default_workflow_user", null, constraints, sortingFields);
       
      log.info("#*14# Dataset Usuario ");
      log.dir(dataset);

      if( dataset.rowsCount > 0){

        retorno = {login:dataset.getValue(0, "login"), password: dataset.getValue(0, "password")}
 
      }

      return retorno;

}