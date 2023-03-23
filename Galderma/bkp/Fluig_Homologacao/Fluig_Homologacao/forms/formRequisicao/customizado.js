//Variavel Globais
	var nSolicitacao = WKNumProces;
	var nAtividade = WKNumState;
			
function setSelectedZoomItem(selectedItem) {
			
			var dataAtual = new Date();
			var dia = dataAtual.getDate();
			var mes = dataAtual.getMonth();
			var ano = dataAtual.getFullYear();
						
			var dsAtividadeStatus = DatasetFactory.getDataset("atividadeStatus", null, null ,null);
			
			if (dsAtividadeStatus != null && dsAtividadeStatus.values != null && dsAtividadeStatus.values.length > 0) {
	    		 var dsResultado = dsAtividadeStatus.values[0];
	    		 var aIndice = selectedItem.inputId.split("___")
	    		 var nIndice = aIndice[1]
	    		/*
	    		 * $("#"+selectedItem.inputId).val()
	    		 * Retorna a seleção do Zoom */
	    		 /* Inicio da leitura*/
	    		 $('table[tablename=ingre] tbody tr').not(':first').remove();
	      		
	      		for (var i = 0; i < dsAtividadeStatus.values.length; i++) { 
	      			row = wdkAddChild('ingre');
//	      			$("#atividadeStatus___"+row.toString().trim()).val(dsAtividadeStatus.values[i].atividade);
	      			$("#statusPxF___"+row.toString().trim()).val(dsAtividadeStatus.values[i].status);
	      			$("#responsavel___"+row.toString().trim()).val(dsAtividadeStatus.values[i].responsavel);
	      			$("#dataPxF___"+row.toString().trim()).val(dia+"/"+mes+"/"+ano);
	      			setZoomData("atividadeStatus___"+row.toString().trim(),dsAtividadeStatus.values[i].atividade);
	   
	      		 }
			}
}
/*Função de iniciação da pagina*/

function init(){
	Mudaestado('consultaFornecedor') //Inicia a div ocultada
	Mudaestado('finaceApproval')
}

function Mudaestado(el){
	var checkFornecedor = document.getElementById('chk3').checked;
	var checkFinApproval = document.getElementById('fApproval').checked;
    var display = document.getElementById(el).style.display;
    
    if(/*display == "none" ||*/ !checkFornecedor/*true*/  )
        document.getElementById(el).style.display = 'none';
    else
        document.getElementById(el).style.display = 'block';
    return
    /**/
    if(!checkFinApproval)
    	document.getElementById(el).style.display = 'none';
    else
        document.getElementById(el).style.display = 'block';
    return
}

/*Funções auxiliares*/
/*
$("#chk3").click( function(){
	if( $(this).is(':checked') ) 
		Mudaestado('consultaFornecedor')
});
*/

/*Função setZoom */
function setZoomData(instance, value){
    window[instance].setValue(value);
}
/*Função delete Zoom*/
function removedZoomItem(removedItem) {
    
    if (removedItem.inputId == "atividadeStatus" ) {
        //--window["cmpc7filent2"].clear(); limpa campo zoom
        $("#statusPxF").val("");
        $("#responsavel").val("");
	    $("#dataPxF").val("");
	    $('table[tablename=ingre] tbody tr').not(':first').remove();
	    window["atividadeStatus"].clear(); 

    }
}
