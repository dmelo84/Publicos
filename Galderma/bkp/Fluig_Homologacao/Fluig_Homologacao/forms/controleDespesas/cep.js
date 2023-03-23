/*Carregar o script na pagina do formulário
 * <script type="text/javascript" src=cep.js </script> 
 * incluir mascara no input "mask="00000-000" */ 
$("#cep").blur(function(){
	$.getJSON("//viacep.com.br/ws/" +$("#cep").val() +"/json/", function(dados){
		$("#logradouro").val(dados.logradouro);
		$("#bairro").val(dados.bairro);
		$("#cidade").val(dados.localidade);
		$("#estado").val(dados.uf);
	})
});