function beforeTaskSave(colleagueId,nextSequenceId,userList){

    log.info("##4 cp004 beforeTaskSave ### "+nextSequenceId);

    log.info("valor before "+hAPI.getCardValue("status_aprovacao"));

    nextSequenceId ==  9 ? hAPI.setCardValue("status_aprovacao","aprovado") : false;
    nextSequenceId == 15 ? hAPI.setCardValue("status_aprovacao","reprovado"): false; 

    log.info("valor after "+hAPI.getCardValue("status_aprovacao"));

}
