function afterProcessCreate(processId){

  var WKNumProces = getValue("WKNumProces");
  hAPI.setCardValue("numero_solicitacao", WKNumProces);
  hAPI.setCardValue("status_solicitacao", "ativa");

}
