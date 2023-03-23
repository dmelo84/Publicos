var beforeSendValidate = function (numState, nextState) {

    $("#cotacao_completa").val(todosItensCotados());

    var campos = "";

    validateAll();

    if (validationErrors.length > 0) {

        for (i = 0; i < validationErrors.length; i++) {

            console.log(validationErrors[i]);

            var label = $("label[for='" + validationErrors[i] + "']").text();

            if (label != "")
                campos += "* " + label + ";\n";

            console.log(label);
        }
    }

    var checkFormaCotar = true;

    $("select[name^='cotacao_tipo_cotacao___']").each(function(){

        if (!$(this).val())
            checkFormaCotar = false;
    })



    !checkFormaCotar ? campos += "* É necessário selecionar a forma de cotar para cada fornecedor; \n" : false;


    if (!vencedorSelecionado() && nextState == 109){

        campos += "* É necessário escolher os fornecedores vencedores da Cotação; \n"
    }

    if(countChildItems("tblItem") == 0){
        campos += "* É necessário adicionar os itens para cotação; \n"
    };

    if(countChildItems("tblFornecedor") == 0){
        campos += "* É necessário adicionar os fornecedores; \n"
    };


    if (campos != "") {
        throw "Favor verificar os seguintes campos obrigatórios: \n" + campos;
    }

}

function todosItensCotados() {

    var flag = true;

    $("[data-cotacao-status-item]").each(function () {

        $(this).val() == "nao_cotado" ? flag = false : flag;

    });

    return flag;

}

function vencedorSelecionado(){

    //Verificar se algum item foi marcado como vencedor

    var temVencedor = false;

    $("input[name^='cotacao_item_vencedor_']").each(function(){

        if($(this).val() !== "") {
            temVencedor = true;
        }

    })

    return temVencedor

}