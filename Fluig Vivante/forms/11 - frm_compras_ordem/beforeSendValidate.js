var beforeSendValidate = function(numState,nextState){

    console.log("SendValidate");
    
   $("[data-fieldset-contrato]").each(function () {

        $(this).prop("disabled", false);
    });

    validateAll();

    var campos="";

    //VERIFICA CAMPOS QUE SÃO VALIDADOS

    for (var i = 0; i < validationErrors.length; i++) {
        
        var campo = validationErrors[i];
        var label = $("label[for='" + campo + "']").text();

        if(label != "")
            campos +=  " * " + label + "\n";

        if(campo.split("___")[0] == "produto_preco")
            campos +=  " * Preço do Item " + $("#seq___"+campo.split("___")[1]).val() +"\n";
        
    }

    //VERIFICA SE TABELAD E ITENS ESTÁ FAZIA

    if(countChildItems() == 0)
        campos += "* É necessário incluir pelo menos um item."



    if(campos != ""){

        throw "Favor verificar os seguintes campos obrigatórios:\n" + campos;
    }

    //Limpa flag "em elaboração"
    if(numState == 160){
        $("#emElaboracao").val("");
    }
    
    
}