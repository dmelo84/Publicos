/****** 
** Enable customization script to change agreement calculation. 
** Input: 
**	stateId -> Current state, whose agreement percentage is being calculated. 
**	agreementData.get("currentPercentage") -> Current percentage, calculated by the workflow engine
**	agreementData.get("currentDestState") -> Current destination state. Zero, if process won't move
**	agreementData.get("currentDestUsers") -> Current destination users. Empty if process won't move
**/
function calculateAgreement(currentState, agreementData) {
	
	log.info("calculateAgreement Estimativa de Preços ");
	log.dir(agreementData);

	var WKNextState = getValue('WKNextState');
	log.info("getValue('WKNextState'): " + getValue("WKNextState"));
	// Quando o primeiro aprovador agir, a aprovacao da atividade já é considerado 100 % de consenso
	agreementData.put("currentPercentage", 100);
	agreementData.put("currentDestState", getValue("WKNextState"));
	
	if (WKNextState == 37)
		agreementData.put("currentDestUsers", "System:Auto");

	if (WKNextState != 37)
		agreementData.put("currentDestUsers", hAPI.getCardValue("codusuario_solicitante"));



}