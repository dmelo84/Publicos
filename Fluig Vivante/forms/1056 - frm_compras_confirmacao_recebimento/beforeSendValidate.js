var beforeSendValidate = function(numState,nextState){


    validateAll();

    var campos="";

    for (var i = 0; i < validationErrors.length; i++) {

         campos +=  " * " + $("label[for='" + validationErrors[i] + "']").text()+ "\n";
        
    }

    if(campos != ""){
        throw "Favor verificar os seguintes campos obrigatórios:\n" + campos;
    }
    
}