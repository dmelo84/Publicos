/*Diogo Melo*/

function formatVlr(){
	
	MaskEvent.init()
	
}
 
function fnCustomDelete(oElement){
/*	
 // Recuperar o valor do registro filho que está sendo eliminado
    var valor = $(oElement).closest('tr').find("input[id^='valor']").val();
    
	    for(i = 0; i < valor.length; i++){
	    	if(valor[i] == '.'){
	    		valor = valor.replace(".","")
	    	}
	    	if(valor[i] == ','){
	    		valor = valor.replace(",",".")
	    	}
	    }
    
    var valor = parseFloat(valor)
    
    var total = document.getElementById('total').value
    
	    for(i = 0; i < total.length; i++){
	    	if(total[i] == '.'){
	    		total = total.replace(".","")
	    	}
	    	if(total[i] == ','){
	    		total = total.replace(",",".")
	    	}
	    }
    
    var total = parseFloat(total)
        
    var subtrai = 0
            
    if(valor != "NaN"){
    	
        subtrai = valor - total 
        subtrai = subtrai.toFixed(2)
        subtrai = parseFloat(subtrai)
                
        $("#total").val(subtrai);
        
        if(subtrai <= 0){
        	$("#total").val("0")
        	$("#linhas").val("0")
        }
        // Revomer o registro filho
        fnWdkRemoveChild(oElement);
    }else{
    	fnWdkRemoveChild(oElement);
    	somaItens()
    }
//Agora vou rodar a função somaItens*/
	fnWdkRemoveChild(oElement)
	somaItens()
	formatVlr()
}

/*Função botão*/

$(function(){
	
console.log("heelo");

$('[data-btn-add-item]').on('click', function(){
		var empresa = $("#empresaId").val();
		var alias  = $("#depto").val();	
		
		var row = wdkAddChild('ingre');
		var strrow = "";
		
		var titulo = $("#titulo___"+(row-1)).val()
		

		if( titulo != undefined){
				
				titulo = titulo[0]
				reloadZoomFilterValues("titulo___"+row,"ALIAS,"+alias+",EMPRESA,"+empresa+",TITULO,"+titulo);
		}else{
			reloadZoomFilterValues("titulo___"+row,"ALIAS,"+alias+",EMPRESA,"+empresa);
		}
		
MaskEvent.init();

});
});

/*Função Filtro Filial*/
	function setFiltro(){
		
		//var conteudo = $(cCampo).val();
		var empresa = $("#empresaId").val();
		var alias  = $("#depto").val();		
//		reloadZoomFilterValues("titulo", "ALIAS,"+alias, "EMPRESA"+empresa);

	}
/*Recarrega a pagina*/
	function reload() {
	    window.location.reload(); // atualiza a página
	}
	
/*Função de inicialização de pagina */
function init(){   //Função executada quando o script é carregado
	
	var hdi = $("#hdi_etapa").val()
	var aprova = $("#aprovaN1").val()
	
	   if(hdi != ''){
		   //$("#inputAdicionar").attr('disabled', 'disabled');
		   $('[data-btn-add-item]').attr('disabled', 'disabled');
		   document.getElementById("divN1").style.display = 'block';
	   }else{
		   document.getElementById("divN1").style.display = 'none';
	   }
		if(hdi == 4){
			if(aprova == 'N'){
				document.getElementById("divN1").style.display = 'none';
			}
		}
};
	
/*Campo Zoom*/

function setSelectedZoomItem(selectedItem) {
			
			var dataAtual = new Date();
			var dia = dataAtual.getDate();
			var mes = dataAtual.getMonth();
			var ano = dataAtual.getFullYear();
			var dados = selectedItem
			var cCampo  = dados.inputId
			
			var aIndice = selectedItem.inputId.split("___")
	    	var nIndice = aIndice[1]
			
			var total = $("#total").val()
			var linhas = $("#linhas").val()
			
			if (dados.inputId == 'titulo___'+nIndice) {
				
	    		/*
	    		 * $("#"+selectedItem.inputId).val()
	    		 * Retorna a seleção do Zoom */
	    		 /* Inicio da leitura*/
//	    		 $('table[tablename=ingre] tbody tr').not(':first').remove();
	      		
	      			row = nIndice;//wdkAddChild('ingre');

	      			$("#empresa___"+row.toString().trim()).val(dados.Codigo);
	      			$("#filial___"+row.toString().trim()).val(dados.Filial);
	      			$("#nome___"+row.toString().trim()).val(dados.Nome);
	      			$("#prefixo___"+row.toString().trim()).val(dados.Prefixo);
	      		  //$("#titulo___"+row.toString().trim()).val(dados.Numero);
	      			$("#parcela___"+row.toString().trim()).val(dados.Parcela);
	      			$("#tipo___"+row.toString().trim()).val(dados.Tipo);
	      			$("#valor___"+row.toString().trim()).val(dados.Valor);
	      			
	      			setZoomData("titulo___"+row.toString().trim(),dados.Numero);
	      			/*	      			
	      			if(total == ''){
	    	        	$('#total').val(parseFloat(dados.Valor))
	    	        	linhas = $("#linhas").val('0')
	    	        }else{
	    	        	//Conversão de valores
	    	        	total = total.replace(".","")
	    	        	total = total.replace(",",".")
	    	        	total = parseFloat(total)
	    	        	//Recebendo o parse
	    	        	total = total + parseFloat(dados.Valor)
	    	        	total = total.toFixed(2)
	    	            $('#total').val(total.toString())
	    	            //Preechimento de itens
	    	            linhas = parseInt(linhas)
	    	            linhas++
	    	            $('#linhas').val(linhas.toString())
	    	        }
	    	        */
	      		    //Formata Mascara
	      			formatVlr()
	      			//Soma Itens
	      			somaItens()
			}
}

/*Função setZoom */
function setZoomData(instance, value){
    window[instance].setValue(value);
}

/*Função delete Zoom*/
function removedZoomItem(removedItem) {
    
	var dados = removedItem
	var cCampo  = dados.inputId
			
	var aIndice = removedItem.inputId.split("___")
	var nIndice = aIndice[1]
	
	row = nIndice
	
    if (dados.inputId == "titulo___"+nIndice ) {
        //--window["cmpc7filent2"].clear(); limpa campo zoom
    	$("#empresa___"+row.toString().trim()).val(dados.Codigo);
		$("#nome___"+row.toString().trim()).val(dados.Nome);
		$("#prefixo___"+row.toString().trim()).val(dados.Prefixo);
	  //$("#titulo___"+row.toString().trim()).val(dados.Numero);
		$("#parcela___"+row.toString().trim()).val(dados.Parcela);
		$("#tipo___"+row.toString().trim()).val(dados.Tipo);
		$("#valor___"+row.toString().trim()).val(dados.Valor);
		window["titulo___"+row.toString().trim()].clear(); 
//	    $('table[tablename=ingre] tbody tr').not(':first').remove();
		
		totalAtual = parseFloat(total) - parseFloat(dados.Valor)
		
		if(totalAtual > 0){
			$('#total').val(totalAtual.toString())
			$('#hdi_total').val(totalAtual.toString())
		}else{
			$('#total').val("0")
			$('#hdi_total').val("0")
			$('#linhas').val("0")
		}

    }
}
		
/*======================
 * 	 Controle de DIV
 =======================*/
function controleDiv(el){
	
	var display = document.getElementById(el).style.display;
	var nOpc = $("#campo").val()
	
	if(nOpc == 1 ){
		document.getElementById(el).style.display = 'block';
	}else{
		document.getElementById(el).style.display = 'none';
	}
	
}

/*======================
 * 	 Soma Itens
 =======================*/

function somaItens() {

    var soma = 0;
    var valor = $("input[id^='valor___']").each(function(index,value){
        $(this).val();
    });

     for (i=0; i< valor.length; i++){
    	 
     valorItermediario = $(valor[i]).val()
     
     	for(j=0; j < valorItermediario.length; j++){
     		if(valorItermediario[j] == '.'){
     			valorItermediario = valorItermediario.replace(".","")
	    	}
	    	if(valorItermediario[j] == ','){
	    		valorItermediario = valorItermediario.replace(",",".")
	    	}
     	}
     
        soma += parseFloat(valorItermediario);
     }
     soma = soma.toFixed(2)
     //Trata condição automatica do fluxo
     $('#hdi_total').val(soma)
     console.log(soma);

     document.getElementById('total').value = soma.toLocaleString('pt-br', {minimumFractionDigits: 2});
     
     //Recarrega Mascara
     formatVlr()
}

