function beforeStateEntry(sequenceId){
	
	 var atividadeAtual = getValue("WKNumState");
	 var proximaAtividade = getValue("WKNextState");
	 var usuario = getValue('WKUser'); //usuário logado
	 var numSolicitacao = getValue("WKNumProces");
	    
	console.log("Tarefa ="+sequenceId)
	//hAPI.setCardValue('hdi_etapa', atividadeAtual);
}