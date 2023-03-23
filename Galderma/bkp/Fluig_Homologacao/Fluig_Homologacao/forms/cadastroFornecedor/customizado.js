/*Variavel Globais
	var nSolicitacao = WKNumProces;
	var nAtividade = WKNumState;
*/	
codigoCliente = getRandomInt(000001, 999999)
$("#A2_COD").val(codigoCliente)
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
	
	if(selectedItem.inputId == 'A2_COD_MUN'){
		$("#A2_EST").val(selectedItem["UF"])
		$("#A2_COD_MUN").val(selectedItem["codigoMunicipio"])
		$("#A2_MUN").val(selectedItem["municipio"])
	}
}

/*/---------------------------------------
 * Função de deleção de Zoom webservice
 * Diogo Melo: 07/05/2021
 ----------------------------------------*/
function removedZoomItem(removedItem) {

	var cCampo  = removedItem.inputId;
	
	if (removedItem.inputId === 'A2_COD_MUN') {
	
		$("#A2_EST").val("")
		$("#A2_COD_MUN").val("")
		$("#A2_MUN").val("")
	}
}
/*/---------------------------------------
 * Consulta CEP
 * Diogo Melo: 07/05/2021
 ----------------------------------------*/
$("#A2_CEP").blur(function(){
	$.getJSON("//viacep.com.br/ws/" +$("#A2_CEP").val() +"/json/", function(dados){
		$("#A2_END").val(dados.logradouro);
		$("#A2_BAIRRO").val(dados.bairro);
		$("#A2_MUN").val(dados.localidade);
		$("#A2_EST").val(dados.uf);
	})
});
/*======================
 * 	 AutoPreenchimento
 =======================*/
$("#filtroCPF").blur(function(){
	$("#A2_CGC").val($("#filtroCPF").val());
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
 * Função rest Post para gravação SA2
   Data: 11/05/2021
---------------------------------------*/

$("#grava").click(function(){
	
	var cgc = $("#filtroCPF").val()
	var cEmpAtu = $("#empresa").val()
	var ltem = $("#ltem").val()
	
	if($("#A2_LOJA").val() == ""){
		FLUIGC.toast({
	        message: 'Loja não preenchida!' ,
	        type: 'danger'
	    });
		return
	}
	
	if(cgc == ''){
		FLUIGC.toast({
		        message: 'Campo CPF/CNPJ nao preenchido!' ,
		        type: 'danger'
		    });
	}else{
		if(ltem != 'true'){
			FLUIGC.toast({
		        message: 'Digite outro CPF/CNPJ' ,
		        type: 'success'
		    });
			return
		}
		var dados = { "empresa":cEmpAtu,
				  "filial":"01",
				  "codigo":$("#A2_COD").val(),
				  "loja":  $("#A2_LOJA").val(),
				  "nomeReduzido":   $("#A2_NREDUZ").val(),
				  "nomeCompleto":  $("#A2_NOME").val(),
				  "CGC":  $("#A2_CGC").val(),
				  "endereco":  $("#A2_END").val(),
				  "bairro": $("#A2_BAIRRO").val(),
				  "estado": $("#A2_EST").val(),
				  "codMunicipio":$("#A2_COD_MUN").val(),
				  "municipio": $("#A2_MUN").val(),
				  "tipoFornece": $("#A2_TIPOFOR").val(), 
				  "tipoPessoa": $("#A2_TIPO").val(),
				  "cep": $("#A2_CEP").val(),
				  "IE": $("#A2_INSCR").val(),
				  "email": $("#A2_EMAIL").val(),
				  "ddd": $("#A2_DDD").val(),
				  "telefone": $("#A2_TEL").val(),
				  "codPais": $("#A2_PAIS").val(),
				  "pais": $("#A2_PAISDES").val(),
				  "paisBacen":$("#A2_CODPAIS").val(),
				  "msblql": $("#A2_MSBLQL").val(),
			  };
	$.ajax({
		
		data: JSON.stringify(dados),
		dataType: 'json',
		url: 'http://10.30.4.139:8083/rest/FORNECEDORES_SA2',
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
		        message: 'error'+e.responseJSON.errorMessage ,
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
	var dados = { "id.fornecedor":$("#filtroCPF").val()}
	var parametro = "?id.fornecedor="+$("#filtroCPF").val()
	var cEmpAtu = $("#empresa").val()
	
	if($("#filtroCPF").val() != ""){
		
		$.ajax({
	  		
	  		data: JSON.stringify(dados),
	  		dataType: 'json',
	  		url: 'http://10.30.4.139:8083/rest/FORNECEDORES_SA2'+parametro,
	  		type: 'GET',
	  		contentType: 'application/json',
	  		headers: {'tenantid': cEmpAtu},
	  		success: function(result){
	  			FLUIGC.toast({
	  		        message: 'Aviso '+result.erro ,
	  		        type: 'info'
	  		    })
	  		    
	  		    if(result.erro == 'sucesso'){ 
	  		    	$("#ltem").val(true) //Valida se tem Cliente Cadastrado
	  		    }else{
	  		    	$("#ltem").val(false)
	  		    }
	  			
	  		},
	  		error: function(e){
	  			FLUIGC.toast({
	  		        message: 'error'+e.responseJSON ,
	  		        type: 'danger'
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
