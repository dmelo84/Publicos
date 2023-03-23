/*Variavel Global*/
codigoProduto = getRandomInt(000001, 999999)
$("#b1_cod").val(codigoProduto)

/*============================
 * Geração de numero randomico
 * ===========================*/
function getRandomInt(min, max) {
	  min = Math.ceil(min);
	  max = Math.floor(max);
	  return Math.floor(Math.random() * (max - min)) + min;
	}

/*=================================
 * Gravação do produto no Protheus
 * ===============================*/
//Botão grava
$("#grava").click(function(){
	
	var cEmp = $("#empresa").val() //Defino a empresa um padrão para teste
			
	var dados = { "cEmp":cEmp/*$("#empresa").val()*/,
	  		  	  "orgGalderma":  $("#b1_xorigem").val()[0],
				  "tipoGalderma":   $("#b1_xtipo").val()[0],
				  "grupoGalderma":  $("#b1_xgrupo").val()[0],
				  "grupoProduto":  $("#b1_grupo").val()[0],
				  "codigo":  $("#b1_cod").val(),
				  "descricao": $("#b1_desc").val(),
				  "subGrupo": $("#b1_xsubgrp").val()[0],
				  "tipo": $("#b1_tipo").val()[0],
				  "uniMedida": $("#b1_um").val()[0],
				  "tipoProduto": $("#b1_xtipgal").val(),
				  "armazem": $("#b1_locpad").val()[0],
				  "precoVenda": $("#b1_prv1").val(),
				  "contaContabil": $("#b1_conta").val()[0],
				  "centroCusto": $("#b1_cc").val()[0],
				  "fefo": $("#b1_usafefo").val(),
				  "tipoVenda": $("#b1_xtpven").val(),
				  "ncm": $("#b1_posipi").val(),
				  "origem": $("#b1_origem").val(),
			  };
  	$.ajax({
  		
  		data: JSON.stringify(dados),
  		dataType: 'json',
  		url: 'http://localhost:8084/rest/PRODUTOS_SB1',
  		type: 'POST',
  		contentType: 'application/json',
  		headers: {'tenantid': cEmp},
  		success: function(result) {
  		}, error: function(e){
          	FLUIGC.toast({
  		        message: e.responseText ,
  		        type: 'danger'
          	});
  		}
  	});
})
