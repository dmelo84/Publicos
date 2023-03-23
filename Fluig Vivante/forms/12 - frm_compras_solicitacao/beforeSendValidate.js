var beforeSendValidate = function (numState, nextState) {

    var campos = "";

    if (!$("#codusuario_rm").val()) {
        throw "Usuário não habilitado para iniciar solicitações.";
    }

    validateAll();



    if (errors.length > 0) {

        for (i = 0; i < errors.length; i++) {

            console.log(errors[i]);

            var label = $("label[for='" + errors[i] + "']").text();

            if (label != "")
                campos += "* " + label + "\n";

            console.log(label);
        }
    }
    if (countChildItems() == 0)
        campos += "* É necessário incluir pelo menos um item.";

    if (numState == 0 || numState == "4" || numState == "32") {

        $("#estimarPreco").val("");

        $("input[name^='produto_preco___']").each(function () {

            if ($(this).val() == "") {
                $("#estimarPreco").val("S");
            }

        })


    }


    if (campos != "") {

        throw "Favor verificar os seguintes campos obrigatórios: \n" + campos;

    } else {

        document.getElementById("fsIdentificacao").disabled = false;
        document.getElementById("fsDadosEntrega").disabled = false;
        document.getElementById("fsAddProduto").disabled = false;
        document.getElementById("unidade_codigo").disabled = false;
        document.getElementById("unidade_nome").disabled = false;
        document.getElementById("ccusto_codigo").disabled = false;
        document.getElementById("ccusto_nome").disabled = false;

    }
}