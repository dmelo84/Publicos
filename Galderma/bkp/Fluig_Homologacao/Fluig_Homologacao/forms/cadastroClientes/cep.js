/*Carregar o script na pagina do formulário
 * <script type="text/javascript" src=cep.js </script> 
 * incluir mascara no input "mask="00000-000" */ 
$("#a1_cep").blur(function(){
	$.getJSON("//viacep.com.br/ws/" +$("#a1_cep").val() +"/json/", function(dados){
		$("#a1_end").val(dados.logradouro);
		$("#a1_bairro").val(dados.bairro);
		$("#a1_mun").val(dados.localidade);
		$("#a1_est").val(dados.uf);
	})
});