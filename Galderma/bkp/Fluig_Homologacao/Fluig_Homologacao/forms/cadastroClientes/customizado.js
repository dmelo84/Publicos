/*Variavel Globais
	var nSolicitacao = WKNumProces;
	var nAtividade = WKNumState;
*/	
codigoCliente = getRandomInt(000001, 999999)
$("#a1_cod").val(codigoCliente)

/*============================
 * Geração de numero randomico
 * ===========================*/
function getRandomInt(min, max) {
	  min = Math.ceil(min);
	  max = Math.floor(max);
	  return Math.floor(Math.random() * (max - min)) + min;
	}
/*------------------------------
 * Executa ao carregar a pagina
 * ----------------------------*/
$(window).on("load", function(){
	controleDiv("btnGrava")
	})
/*/---------------------------------------
 * Função de seleção de Zoom webservice
 * Diogo Melo: 07/05/2021
 ----------------------------------------*/
function setSelectedZoomItem(selectedItem) {

	var cCampo  = selectedItem.inputId;
	
	if(selectedItem.inputId == 'a1_cod_mun'){
		$("#a1_est").val(selectedItem["UF"])
		$("#a1_cod_mun").val(selectedItem["codigoMunicipio"])
		$("#a1_mun").val(selectedItem["municipio"])
	}
}

/*/---------------------------------------
 * Função de deleção de Zoom webservice
 * Diogo Melo: 07/05/2021
 ----------------------------------------*/
function removedZoomItem(removedItem) {

	var cCampo  = removedItem.inputId;
	
	if (removedItem.inputId === 'a1_cod_mun') {
	
		$("#a1_est").val("")
		$("#a1_cod_mun").val("")
		$("#a1_mun").val("")
	}
}
/*===================
 * 	 Cadastro CEP
 ====================*/
$("#a1_cep").blur(function(){
	$.getJSON("//viacep.com.br/ws/" +$("#a1_cep").val() +"/json/", function(dados){
		$("#a1_end").val(dados.logradouro);
		$("#a1_bairro").val(dados.bairro);
		$("#a1_mun").val(dados.localidade);
		$("#a1_est").val(dados.uf);
	})
});
/*======================
 * 	 AutoPreenchimento
 =======================*/
$("#filtroCPF").blur(function(){
	$("#a1_cgc").val($("#filtroCPF").val());
})
/*======================
 * 	 Execução de Select
 =======================*/
function mostraSelecao(elemento){
	
        var nOpc = elemento.value;
        var cSelecao = elemento.options[elemento.options.selectedIndex].innerText
        
        /* Acesso direto ao select
        controleDiv(elemento.options[elemento.options.selectedIndex].innerText)
        */
        /*
        if(nOpc == '1' ){
        	controleDiv("cadastrais")
        }else if(nOpc == '2'){
        	controleDiv("admFin")
        }else if(nOpc == '3'){
        	controleDiv("fiscais")
        }else
        	alert("teste")
        */
    }
/*======================
 * 	 Controle de DIV
 =======================*/
function controleDiv(el){
	
	var display = document.getElementById(el).style.display;
	var nOpc = $("#selecionaLayer").val()
	/*
	if(nOpc == 0 || nOpc == null ){
		document.getElementById("cadastrais").style.display = 'none';
		document.getElementById("admFin").style.display     = 'none';
		document.getElementById("fiscais").style.display    = 'none';
		document.getElementById("vendas").style.display     = 'none';
		document.getElementById("outros").style.display     = 'none';
		document.getElementById("vendas").style.display     = 'none';
		document.getElementById("btnGrava").style.display   = 'none';
	}
	if(nOpc == 1 ){
		document.getElementById(el).style.display = 'block';
	}else{
		document.getElementById(el).style.display = 'none';
	}
	*/
}

/*--------------------------------------
 * Função rest Post para gravação SB1
   Data: 11/05/2021
---------------------------------------*/
$("#grava").click(function(){
	
	var cgc = $("#filtroCPF").val()
	var cEmpAtu = $("#empresa").val()
	var ltem = $("#ltem").val()
	
	if(cgc == ''){
		FLUIGC.toast({
		        message: 'Campo CPF/CNPJ nao preenchido!' ,
		        type: 'danger'
		    });
	}else{
		if(ltem == 'true'){
			FLUIGC.toast({
		        message: 'Digite outro CPF/CNPJ' ,
		        type: 'success'
		    });
			return
		}
		var dados = { "codigo":$("#a1_cod").val(),
				  "loja":  $("#a1_loja").val(),
				  "nomeReduzido":   $("#a1_nreduz").val(),
				  "nomeCompleto":  $("#a1_nome").val(),
				  "cpf":  $("#a1_cgc").val(),
				  "endereco":  $("#a1_end").val(),
				  "bairro": $("#a1_bairro").val(),
				  "estado": $("#a1_est").val(),
				  "municipio": $("#a1_mun").val(),
				  "tipoPessoa": $("#a1_pessoa").val(),
				  "tipoCliente": $("#a1_tipo").val(),
			  };
	$.ajax({
		
		data: JSON.stringify(dados),
		dataType: 'json',
		url: 'http://10.30.4.139:8083/rest/CLIENTES_SA1',
		type: 'POST',
		contentType: 'application/json',
		headers: {'tenantid': cEmpAtu},
		success: function(result){
			FLUIGC.toast({
		        message: 'Sucesso'+result ,
		        type: 'success'
		    });
		},
		error: function(e){
			FLUIGC.toast({
		        message: 'Error'+e ,
		        type: 'danger'
		    });
		}
	});
	}
});

/*--------------------------------------
* Função rest Post para gravação SA1
  Data: 11/05/2021
---------------------------------------*/
$("#filtroCPF").blur(function(){
	var dados = { "id.cliente":$("#filtroCPF").val()}
	var parametro = "?id.cliente="+$("#filtroCPF").val()
	
	if($("#filtroCPF").val() != ""){
		
		$.ajax({
	  		
	  		data: JSON.stringify(dados),
	  		dataType: 'json',
	  		url: 'http://10.30.4.139:8083/rest/CLIENTES_SA1'+parametro,
	  		type: 'GET',
	  		contentType: 'application/json',
	  		headers: {'tenantid': cEmpAtu},
	  		success: function(result){
	  			FLUIGC.toast({
	  		        message: 'Aviso '+result.erro ,
	  		        type: 'info'
	  		    })
	  		    $("#ltem").val(true) //Valida se tem Cliente Cadastrado
	  		},
	  		error: function(e){
	  			FLUIGC.toast({
	  		        message: 'Error'+e ,
	  		        type: 'success'
	  		    });
	  		}
	  	});
	}else{
		FLUIGC.toast({
		        message: 'CPF/CNPJ em branco.' ,
		        type: 'danger'
		    });
	}

});



