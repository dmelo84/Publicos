 //document.getElementById("cmpNumDoc").readOnly = true; 
var nAtividade = WKNumState;
$("#addButton").hide();
$("#Apagar").hide();
$("#cmpSolicitante").val(parent.WCMAPI.getUser());

	if(nAtividade != 0){
		$('#DocsemZoom').hide();
		$('#divDoc').show();
		$('#ForSemZoom').hide()
		$('#ForZoom').show();
		$('#PedSemZoom').hide()
		$('#PedZoom').show();
		document.getElementById("motivo").readOnly = false;
		if($("#cmpAntecipacao").val() == '2'){
			$("#DivdtAntecipacao").show();
			var calendarAntecipacao = FLUIGC.calendar('#cmpDtAntecipacao');
		}
	}
	
	if(nAtividade == 27){
		$("#cmpAntecipacaoOk").val("1")
	}
function setSelectedZoomItem(selectedItem) {
	
	if(selectedItem.inputId == 'cmpFornecedor'){
		var fornecedor = $("#cmpFornecedor").val()[0];
		reloadZoomFilterValues("cmpNumDoc", "CGC,"+ fornecedor);
	}
	if(selectedItem.inputId == 'cmpNumDoc'){
		$('table[tablename=tabelaProdutos] tbody tr').not(':first').remove();
		var constraint  = []
		var numDoc = $("#cmpNumDoc").val()[0];
		var fornecedor = $("#cmpFornecedor").val()[0];
		var tipoNf = $("#cmpTipo").val();
		constraint.push(DatasetFactory.createConstraint("FORNECEDOR",fornecedor,fornecedor, ConstraintType.MUST));
		constraint.push(DatasetFactory.createConstraint("DOC",numDoc,numDoc, ConstraintType.MUST));
		constraint.push(DatasetFactory.createConstraint("TIPO",tipoNf,tipoNf, ConstraintType.MUST));
		var datasetRet = DatasetFactory.getDataset("ds_ITENS_DOC_QXML", null, constraint,null);
		var recordsPP2 = null
		var row = 0; 
		reloadZoomFilterValues("cmpPedido", "C7_NUM,"+datasetRet.values[0].C7_NUM);
		$("#cmpSerie").val(datasetRet.values[0].PP2_SERIE)
		for (var i = 0; i < datasetRet.values.length; i++) {
 			
 			recordsPP2 = datasetRet.values[i];
 			row = wdkAddChild('tabelaProdutos');
 			$("#cmpItem___"+row.toString().trim()).val(recordsPP2.PP2_ITEM);
 			$("#cmpProd___"+row.toString().trim()).val(recordsPP2.C7_PRODUTO.trim() +" / "+recordsPP2.B1_DESC.trim());
 			$("#cmpVlr___"+row.toString().trim()).val(recordsPP2.PP2_VUNIT);
 			$("#cmpVlrTotal___"+row.toString().trim()).val(recordsPP2.PP2_TOTAL);
 			$("#cmpQtde___"+row.toString().trim()).val(recordsPP2.PP2_QUANT);
	}
	}
	if( selectedItem.inputId == "cmpPedido"){
		var constraint  = [];
		var numPed = $("#cmpPedido").val()[0];
		constraint.push(DatasetFactory.createConstraint("NUM",numPed,numPed, ConstraintType.MUST));
		var datasetRet = DatasetFactory.getDataset("ds_PEDIDO_COMPRA", null, constraint,null)
		$('table[tablename=tabelaProdutos] tbody tr').not(':first').remove();
		$('#divDoc').hide();
		$('#DocsemZoom').show()
		document.getElementById("cmpNumDoc1").readOnly = false;
		document.getElementById("cmpSerie").readOnly = false;
		var recordsSC7 = null;
		var row = 0; 
		for (var i = 0; i < datasetRet.values.length; i++) {
     			
     			recordsSC7 = datasetRet.values[i];
     			row = wdkAddChild('tabelaProdutos');
     			$("#cmpItem___"+row.toString().trim()).val(recordsSC7.C7_ITEM);
     			$("#cmpProd___"+row.toString().trim()).val(recordsSC7.C7_PRODUTO.trim() +" / "+recordsSC7.B1_DESC.trim());
     			$("#cmpVlr___"+row.toString().trim()).val(recordsSC7.C7_PRECO);
     			$("#cmpVlrTotal___"+row.toString().trim()).val(recordsSC7.C7_TOTAL);
     			$("#cmpQtde___"+row.toString().trim()).val(recordsSC7.C7_QUANT);
		}
     			
		
	}
}
function removedZoomItem(removedItem) {
	
	if (removedItem.inputId == "cmpPedido" ||removedItem.inputId == "cmpNumDoc") {
		$('table[tablename=tabelaProdutos] tbody tr').not(':first').remove();
    }
}
function setEmpFil(){
	var aEmp = $("#cmpDestinataria").val();
	$("#cmpPedido").val('');
	$("#cmpNumDoc").val('');
	$("#cmpFornecedor").val('');
	reloadZoomFilterValues("cmpPedido","EMPRESA,"+aEmp);
	reloadZoomFilterValues("cmpNumDoc","EMPRESA,"+aEmp);
	reloadZoomFilterValues("cmpFornecedor","EMPRESA,"+aEmp);
}
function antecipacao(){
	
	if($("#cmpAntecipacao").val() == '2'){
		$("#DivdtAntecipacao").show();
		var calendarAntecipacao = FLUIGC.calendar('#cmpDtAntecipacao');
	}else{
		$("#DivdtAntecipacao").hide();
	}
	
}
function typeDoc(){
	var status = $("#cmpTipo").val();
	if(status == '0' ||status == '3'){
		
		document.getElementById("cmpNumDoc1").readOnly = false;
		document.getElementById("_cmpEmissao").readOnly = false; 
		var calendar = FLUIGC.calendar('#_cmpEmissao');
		$('#DocsemZoom').hide();
		$('#divDoc').show();
		$('#ForSemZoom').hide()
		$('#ForZoom').show();
		$('#PedSemZoom').hide()
		$('#PedZoom').show();
	}else if(status == '1' ||status == '2'){
		$('#DocsemZoom').hide();
		$('#divDoc').show();
		$('#ForSemZoom').hide()
		$('#ForZoom').show();
		$('#PedSemZoom').hide()
		$('#PedZoom').show();
	}else{
		$('#ForSemZoom').show();
		$('#ForZoom').hide();
		$('#DocsemZoom').show();
		$('#divDoc').hide();
		document.getElementById("cmpNumDoc1").readOnly = true;
		document.getElementById("cmpFornecedor1").readOnly = true;
		$('#ForSemZoom').show()
		$('#ForZoom').hide();
		$('#PedSemZoom').show()
		$('#PedZoom').hide();
	}
}

function addItem() {
	var row = wdkAddChild('tabelaProdutos');
	var strrow = ("0000" + row).slice(-4);
	$("#cmpItem___"+row).val(strrow);
	$("#cmpQtde___"+row).val("0");
	$("#itreal").val(row);
    MaskEvent.init();
};
function somaTotal(id){
	var searchId = id.split('___')[1]
	var qtd = $("#cmpQtde___"+searchId).val();
	var vlr = $("#cmpVlr___"+searchId).val()
	if(qtd != "" && vlr != ""){
		
		var Total = parseFloat(qtd) * parseFloat(vlr);

		$("#cmpVlrTotal___"+searchId).val(Total);
		//$("#cmpQtde___"+searchId).mask("000.00");
		//$("#cmpVlr___"+searchId).mask("000.00");
		
		//$("#cmpVlrTotal___"+searchId).mask("000000.00");
	}
}

function addproduto(oElement) {
    var row = wdkAddChild('tabelaProdutos');
	var itreal = $("#itreal").val();
	var strrow = "";
	var item = "";
	var itseq = parseInt(itreal);
	var newitem = 0;
	
	itseq++;
	
	MaskEvent.init();
	
	$("input[id^='cmpItem___']").each(function(index, value){
	    var item = $(this).val();
    	newitem++;
		strrow = ("0000" + newitem).slice(-4);
    	$(this).val(strrow);
	    
		$("#itreal").val(newitem);
	});

};

function removeproduto(oElement){
	var newitem = 0;
	var item = 0;
	var vlditem= -1;
	var strrow = "";
	var itemexc = $(oElement).closest('tr').find("input[id^='cmpItem']").val();
	$("input[id^='cmpItem___']").each(function(index, value){
	    var item = $(this).val();
	    if (item != itemexc){
	    	newitem++;
			strrow = ("0000" + newitem).slice(-4);
	    	$(this).val(strrow);
	    }
		$("#itreal").val(newitem);
	});
	fnWdkRemoveChild(oElement);   
}