$("#grava").click(function(){
	
	var dados = { E2_NUM : $("#numero").val(), 
				  E2_TIPO : $("#tipo").val(),
				  E2_NATUREZ : $("#naturez").val(),
				  E2_FORNECE : $("#fornece").val(),
				  E2_EMISSAO : $("#caledar").val(),
				  E2_VENCTO : $("#caledar").val(),
				  E2_VENCREA : $("#caledar").val(),
				  E2_VALOR : $("#valor").val()
				  
	};
	
	$.ajax({
		
		data: JSON.stringify(dados),
		dataType: 'json',
		url: 'meu fluig',
		type: 'POST',
		contentType: 'application/json',
		success: function(result) {
			FLUIGC.toast({
		        message: 'Titulo incluido.' ,
		        type: 'success'
		    });
		}
		
	});
	
});