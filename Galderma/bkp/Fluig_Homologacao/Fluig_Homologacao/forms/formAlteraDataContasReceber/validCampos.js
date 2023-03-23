//Variavel Globais
	var nSolicitacao = WKNumProces;
	var nAtividade = WKNumState;
	var dataAtual = FLUIGC.calendar('#venctoaltera');
	var datareal = FLUIGC.calendar('#venctoreal');
	
/*/Tratativa Alteração de data
$("#venctoaltera").blur(function(){
	var dataAtual = FLUIGC.calendar('#venctoaltera');
})
$("#venctoreal").blur(function(){
	var datareal = FLUIGC.calendar('#venctoreal');
})
/*/
//Botão grava
$("#grava").click(function(){
	
	var cEmp = $("#empresa").val();
	var	cPref  = $("#prefixo").val();
	var cNum   = $("#titulo").val()[0];
	var cParc  = $("#parcela").val();
	var cTipo  = $("#tipo").val();
	var cVencto = $("#venctoaltera").val();
	var cOk     = $("#ok").val();
//	var nCodTarefa = taskId
	
	 if(nAtividade === 0 || nAtividade === 3){
		 FLUIGC.toast({
             message: 'Para gravar a nova data de vencimento é necessário submeter o título à aprovação.' ,
             type: 'info'
         });
		 return
	 }
	
	 if (cVencto != '' ) {
        if (cPref == '') {
        	FLUIGC.toast({
                message: 'Campo prefixo não preenchido' ,
                type: 'info'
            });
        }if (cNum == '') {
        	FLUIGC.toast({
                message: 'Campo numero não preenchido' ,
                type: 'info'
            });
        }if (cTipo == ''){
        	FLUIGC.toast({
                message: 'Campo tipo não preenchido' ,
                type: 'info'
            });
        }if(cPref != ''&& cNum != ''&& cTipo != '' && cOk == '' ){
        	
        	var dados = { "cEmp":$("#empresa").val(),
        		  "cPref":  $("#prefixo").val(),
      			  "cNum":   $("#titulo").val(),
      			  "cParc":  $("#parcela").val(),
      			  "cTipo":  $("#tipo").val(),
      			  "dData":  $("#venctoaltera").val(),
      			  "nValor": $("#valor").val(),
      			  "cTable": "SE1",
      			  };
        	if(cEmp == '01-Galderma'){
        		cEmpAtu = '01'
        	}else{
        		cEmpAtu = '02'
        	}
        	
		  	$.ajax({
		  		
		  		data: JSON.stringify(dados),
		  		dataType: 'json',
		  		url: 'http://10.30.4.139:8083/rest/TITULOS_FINANCEIRO',
		  		type: 'PUT',
		  		contentType: 'application/json',
		  		headers: {'tenantid': cEmpAtu},
		  		success: function(result) {
		  			if(typeof result.Erro_encontrado != "undefined"){
		  				FLUIGC.toast({
			  		        message: 'Titulo não encontrado '+result.Erro_encontrado ,
			  		        type: 'danger'
			  		    });
		  				return
		  			}
		  			if(cOk == ''){
		  				$("#ok").val('Gravado!') //Status de alteração
			  			FLUIGC.toast({
			  		        message: 'Titulo alterado.'+cOk ,
			  		        type: 'success'
			  		    });
		  			}else{
		  				FLUIGC.toast({
			  		        message: 'Titulo já atualizado no Protheus.'+cOk ,
			  		        type: 'danger'
			  		    });
		  			}
		  		}, error: function(e){
		          	FLUIGC.toast({
		  		        message: e.responseText ,
		  		        type: 'danger'
		          	});
		  		}
		  	});
	        }else{
	        	FLUIGC.toast({
	  		        message: "Erro na requisição ou conexão com WebService, Ou título já gravado." ,
	  		        type: 'danger'
	          	});
	        }
        }else{
        	FLUIGC.toast({
		        message: 'Data de alteração do título não preenchida.' ,
		        type: 'danger'
        	});
        }
});

//Botão aprovação
$("#aprovacao").click(function(){
	
	var cAprovacao = "Aprovado";
	var aprovado  = $("#aprova").val();
//	var nSolicitacao = WKNumProces;
//	var nAtividade = WKNumState;
	var cVencto = $("#venctoaltera").val();
	
	if(cVencto == ''){
		FLUIGC.toast({
            message: 'Data a ser alterada do título não preenchida.' ,
            type: 'danger'
		});
		return
	}
	
	if(aprovado == '' && nAtividade > 0 ){
		$("#aprova").val(cAprovacao)
		FLUIGC.toast({
	        message: 'Aprovado!' ,
	        type: 'success'
    	});
	}else{
		FLUIGC.toast({
            message: 'A atividade: '+nAtividade+' não está apta para aprovação.' ,
            type: 'danger'
        });
	}
		
});
/*------------------------------
 * Funções auxiliares para teste
 * ----------------------------*/
$("#motivo").blur(function(){
	$("#ok").val('Em aprovação!')
});
function Mudarestado(el) {
	
	var cAprova = $("#aprova").val();
    var display = document.getElementById(el).style.display;
    
    if(display == "none" || cAprova != 'Sim'  )
        document.getElementById(el).style.display = 'none';
    else
        document.getElementById(el).style.display = 'block';
}
/*------------------------------
 * Executa ao carregar a pagina
 * ----------------------------*/
$(window).on("load", function(){
		Mudarestado('divStatus');
		Mudarestado('divGrava');
	//	$("#ok").val('Atividade N°'+nAtividade)
	
})
	         
/*/---------------------------------------
 * Função de seleção de Zoom webservice
 * Diogo Melo: 12/01/2021
 ----------------------------------------*/

function setSelectedZoomItem(selectedItem) {

	//var cPref    = "prefixo";
	var cTitulo  = "titulo";
	//var cParcela = "parcela";
	//var cTipo    = "tipo";

	var FIELD = selectedItem.inputId;

	if(selectedItem.inputId == cTitulo){
	//	setZoomData("prefixo", selectedItem["Prefixo"]);
	//	setZoomData("parcela", selectedItem["Parcela"]);
	//	setZoomData("tipo", selectedItem["Tipo"]);
		$("#empresa").val(selectedItem["Codigo"])
		$("#prefixo").val(selectedItem["Prefixo"])
		$("#parcela").val(selectedItem["Parcela"])
		$("#tipo").val(selectedItem["Tipo"])
		$("#nome").val(selectedItem["Nome"])
    	$("#valor").val(selectedItem["Valor"])
    	$("#venctoreal").val(selectedItem["Vencimento"])

	}/*else if(selectedItem.inputId == EMAIL){
		setZoomData("colleagueName", selectedItem["colleagueName"]);
		setZoomData("colleagueId", selectedItem["colleagueId"]);

	}else if(selectedItem.inputId == ID){
		setZoomData("colleagueName", selectedItem["colleagueName"]);
		setZoomData("colleagueMail", selectedItem["mail"]);
	}*/
}
/*
function setZoomData(instance, value){
	window[instance].setValue(value);
}
*/
function removedZoomItem(removedItem) {

	//var cPref    = "prefixo";
	var cTitulo  = "titulo";
	//var cParcela = "parcela";
	//var cTipo    = "tipo";

	if (removedItem.inputId === cTitulo) {
	//	console.log("Retornando resultado removedZoomItem");
	//	console.log(removedItem);
		/*
		window[cPref].clear();
		window[cTitulo].clear();
		window[cParcela].clear();
		window[cTipo].clear();
		*/
		$("#prefixo").val("")
		$("#parcela").val("")
		$("#nome").val("")
    	$("#valor").val("")
    	$("#venctoreal").val("")
    	$("#venctoaltera").val("")
    	$("#tipo").val("")
	}
}