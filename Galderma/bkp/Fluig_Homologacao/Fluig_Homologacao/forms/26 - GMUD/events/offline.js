

simulaForms = function () {
	this.primeira = "primeira";
	RateioTelemont = this;
}


simulaForms.prototype.setVisibleById = function (campo, booleano) { 
	console.log("SimulaCampos entrou");
	if (booleano == true) {
		$("#" + campo).show();
	}
	
	if (booleano == false) {
		$("#" + campo).hide();
	}
}

// var form = new simulaForms(true);
