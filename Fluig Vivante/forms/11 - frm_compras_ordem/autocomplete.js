var acFornecedor = FLUIGC.autocomplete('#fornecedor_nome', {
    source: substringMatcher("fornecedor"),
    name: 'nome',
    displayKey: 'NOME',
    tagClass: '',
    type: 'autocomplete',
    autoLoading: true,
    maxTags: 1,


    allowDuplicates: false,
    tagMaxWidth: 400,
    templates: {
        suggestion: '<div><h6>{{CODCFO}} - {{NOMEFANTASIA}}</h6><div>'
    }
});

acFornecedor.on("fluig.autocomplete.selected", function (event) {

    selectedFornecedor = event.item;



    $("#fornecedor_codigo").val(selectedFornecedor.CODCFO);
    $("#fornecedor_cnpj").val(selectedFornecedor.CGCCFO);

});

acFornecedor.on("fluig.autocomplete.opened", function (event) {
    selectedFornecedor = {};

    $("#fornecedor_codigo").val("");
    $("#fornecedor_cnpj").val("");
    acFornecedor.removeAll();

});

acFornecedor.on("fluig.autocomplete.closed", function (event) {

    var value = $("#fornecedor_codigo").val();
    if (!value) {

        selectedFornecedor = {};

        $("#fornecedor_codigo").val("");
        $("#fornecedor_cnpj").val("");

        acFornecedor.removeAll();


    }
});

var acEmpresa = FLUIGC.autocomplete('#empresa_nome', {

    source: substringMatcher("empresa"),
    name: 'nome',
    displayKey: 'NOME',
    tagClass: '',
    type: 'autocomplete', //'tagAutocomplete',
    autoLoading: false,
    maxTags: 1,

    allowDuplicates: false,
    tagMaxWidth: 400,
    templates: {
        suggestion: '<div><h6>{{CODCOLIGADA}} - {{NOME}}</h6><div>'
    }

});

acEmpresa.on("fluig.autocomplete.selected", function (event) {


    selectedacEmpresa = event.item;
    $("#empresa_codigo").val(selectedacEmpresa.CODCOLIGADA);
    $("#codcoligada").val(selectedacEmpresa.CODCOLIGADA);


});

acEmpresa.on("fluig.autocomplete.opened", function (event) {

    selectedacEmpresa = {};

    resetEmpresa();


});

acEmpresa.on("fluig.autocomplete.closed", function (event) {



    var value = $("#empresa_codigo").val();
    if (!value) {

        resetEmpresa();

    }

});

var acUnidade = FLUIGC.autocomplete('#unidade_nome', {
    source: substringMatcher("unidade"),
    name: 'nome',
    displayKey: 'NOME',
    tagClass: '',
    type: 'autocomplete', //'tagAutocomplete',
    autoLoading: true,
    maxTags: 1,
    allowDuplicates: false,
    tagMaxWidth: 400,
    templates: {
        suggestion: '<div><h6>{{COD_UNIDADE}} - {{NOME}}</h6><div>'
    }



});

acUnidade.on("fluig.autocomplete.selected", function (event) {

    selectacUnidade = event.item;
    $("#unidade_codigo").val(selectacUnidade.COD_UNIDADE);

});

acUnidade.on("fluig.autocomplete.opened", function (event) {
    resetUnidade();
    selectacUnidade = {};
    $("#unidade_codigo").val("");


});

acUnidade.on("fluig.autocomplete.closed", function (event) {

    var value = $("#unidade_codigo").val();
    if (!value) {
        resetUnidade();
    }


});

var acLocalEstoque = FLUIGC.autocomplete('#local_estoque_nome', {
    source: substringMatcher("localEstoque"),
    name: 'NOME',
    displayKey: 'NOME',
    tagClass: '',
    type: 'autocomplete',
    autoLoading: true,
    maxTags: 1,
    allowDuplicates: false,
    tagMaxWidth: 250,
    templates: {
        suggestion: '<div><h6><strong>{{CODLOC}} - {{NOME}}</strong></h6><div><div><h6>Filial: {{CODFILIAL}} -{{CNPJ_VIVANTE}} - {{FILIAL_VIVANTE}}</h6><div>'
    }
});


acLocalEstoque.on("fluig.autocomplete.selected", function (event) {

    selectedacLocalEstoque = event.item;
    $("#local_estoque_codigo").val(selectedacLocalEstoque.CODLOC);


    $("#filial").val(selectedacLocalEstoque.CODFILIAL + " - " + selectedacLocalEstoque.FILIAL_VIVANTE);
    $("#cliente_nome").val(selectedacLocalEstoque.cliente_nome);
    $("#entrega_endereco").val(
        selectedacLocalEstoque.RUA + "" +
        selectedacLocalEstoque.NUMERO + "" +
        selectedacLocalEstoque.BAIRRO
    );
    $("#entrega_cidade").val(selectedacLocalEstoque.CIDADE);
    $("#cnpj_filial_vivante").val(selectedacLocalEstoque.CNPJ_VIVANTE);
    $("#codfilial").val(selectedacLocalEstoque.CODFILIAL);
 





});

acLocalEstoque.on("fluig.autocomplete.opened", function (event) {

    selectedacLocalEstoque = {};
    $("#local_estoque_codigo").val("");
    resetLocalEstoque();


});

acLocalEstoque.on("fluig.autocomplete.closed", function (event) {


    var value = $("#local_estoque_codigo").val();
    if (!value) {
        resetLocalEstoque();
    }




});

/// Autocomplete Contrato
var acContrato = FLUIGC.autocomplete('#contrato_nome', {
    source: substringMatcher("contrato"),
    name: 'NOME',
    displayKey: 'NOME',
    tagClass: '',
    type: 'autocomplete',
    autoLoading: true,
    maxTags: 1,
    allowDuplicates: false,
    tagMaxWidth: 400,
    templates: {
        suggestion: '<div><h6><strong>{{CODIGOCONTRATO}} - {{NOME}}</strong></h6><div>'
    }
});

acContrato.on("fluig.autocomplete.selected", function (event) {

    selectedacContrato = event.item;
    $("#contrato_codigo").val(selectedacContrato.CODIGOCONTRATO);


});

acContrato.on("fluig.autocomplete.opened", function (event) {
    resetContrato();
    selectedacContrato = {};
    $("#contrato_codigo").val("");


});

acContrato.on("fluig.autocomplete.closed", function (event) {

    var value = $("#contrato_codigo").val();
    if (!value) {
        resetContrato();
    }


});

var acCentroCusto = FLUIGC.autocomplete('#ccusto_nome', {
    source: substringMatcher("centroCusto"),
    name: 'NOME_CCUSTO',
    displayKey: 'NOME_CCUSTO',
    tagClass: '',
    type: 'autocomplete', //'tagAutocomplete',
    autoLoading: true,
    maxTags: 1,


    allowDuplicates: false,
    tagMaxWidth: 400,
    templates: {
        suggestion: '<div><h6>{{CODCCUSTO}} - {{NOME_CCUSTO}}</h6><div>'
    }



});

acCentroCusto.on("fluig.autocomplete.selected", function (event) {

    selectedCentroCusto = event.item;
    $("#ccusto_codigo").val(selectedCentroCusto.CODCCUSTO);

});

acCentroCusto.on("fluig.autocomplete.opened", function (event) {
    resetCentroCusto();
    selectedCentroCusto = {};
    $("#ccusto_codigo").val("");


});

acCentroCusto.on("fluig.autocomplete.closed", function (event) {

    var value = $("#ccusto_codigo").val();
    if (!value) {
        resetCentroCusto();
    }


});


/// Autocomplete Produto
var acProduto = FLUIGC.autocomplete('#produto_descricao_add', {
    source: substringMatcher("produto"),
    name: 'DESCRICAO',
    displayKey: 'DESCRICAO',
    tagClass: '',
    type: 'tagAutocomplete',
    autoLoading: true,
    maxTags: 1,
    allowDuplicates: false,
    tagMaxWidth: 400,
    templates: {
        suggestion: '<div><h6><strong>{{CODIGOPRD}} - {{DESCRICAO}}</strong></h6><div>'
    }
});

acProduto.on("fluig.autocomplete.itemAdded", function (event) {
    console.log("PRODUTO ADD >>>>>");
    
    selectedacProduto = event.item;

    console.log(selectedacProduto);

    $("#produto_codigo_add").val(selectedacProduto.CODIGOPRD);
    $("#produto_un_add").val(selectedacProduto.CODUNDCOMPRA);

});

acProduto.on("fluig.autocomplete.itemRemoved", function (event) {
    selectedacProduto = {};

    $("#produto_codigo_add").val("");
    $("#produto_un_add").val("");
    $("#produto_quantidade_add").val("");


});






function resetEmpresa() {

    selectedacEmpresa = {};
    acEmpresa.val("");

    $("#empresa_codigo").val("");
    $("#codcoligada").val("");

    resetUnidade();


}

function resetUnidade() {

    selectacUnidade = {};
    acUnidade.val("");
    $("#unidade_codigo").val("");

    resetCentroCusto();
};

function resetCentroCusto() {

    selectedCentroCusto = {};
    acCentroCusto.val("");
    $("#ccusto_codigo").val("");

    resetLocalEstoque();
    resetContrato();
}

function resetLocalEstoque() {

    selectedacLocalEstoque = {};
    acLocalEstoque.val("");
    $("#local_estoque_codigo").val("");
    $("#codfilial").val("");

}

function resetContrato() {

    selectedacContrato = {};
    acContrato.val("");
    $("#contrato_codigo").val("");

}

$("[data-btn-zoom-autocomplete]").click(function () {

    var target = $(this).data("btn-zoom-autocomplete");
    console.log(target);

    if (target == "acEmpresa") {
      
        if (!$("#empresa_nome").prop("readonly")) {
            acEmpresa.val("%");
            $("#empresa_nome").focus();
            acEmpresa.open();
        }
    }

    if (target == "acCentroCusto") {
        if (!$("#ccusto_nome").prop("readonly")) {
            acCentroCusto.val("%");
            $("#ccusto_nome").focus();
            acCentroCusto.open();
        }
    }
    
	if (target.indexOf("acCentroCusto___") != -1) {
		var seqTarget = target.split("___")[1];
        if (!$("#ccusto_nome___" + seqTarget).prop("readonly")) {
        	
        	var acCentroCustoRat = FLUIGC.autocomplete("#ccusto_nome___" + seqTarget, {
				source: substringMatcher("centroCustoRateio"),
				name: 'NOME_CCUSTO',
				displayKey: 'NOME_CCUSTO',
				tagClass: '',
				type: 'autocomplete', //'tagAutocomplete',
				autoLoading: true,
				maxTags: 1,
				allowDuplicates: false,
				tagMaxWidth: 400,
				templates: {
				    suggestion: '<div><h6>{{CODCCUSTO}} - {{NOME_CCUSTO}}</h6><div>'
				}
        	});
        	
        	acCentroCustoRat.on("fluig.autocomplete.selected", function (event) {
        	    selectedCentroCusto = event.item;
        	    $("#ccusto_codigo" + seqTarget).val(selectedCentroCusto.CODCCUSTO);
        	});

        	acCentroCustoRat.on("fluig.autocomplete.opened", function (event) {
        	    resetCentroCusto();
        	    selectedCentroCusto = {};
        	    $("#ccusto_codigo" + seqTarget).val("");
        	});

        	acCentroCustoRat.on("fluig.autocomplete.closed", function (event) {
        	    var value = $("#ccusto_codigo" + seqTarget).val();
        	    if (!value) {
        	        //resetCentroCusto();
        	    }
        	});
        	
        	acCentroCustoRat.val("%");
            $("#ccusto_nome___" + seqTarget).focus();
            acCentroCustoRat.open();
        }
    }
    /*
    if (target == "acCentroCusto") {
        if (!$("#ccusto_nome").prop("readonly")) {
        	
        	
        	// --------------------------
        	var acCentroCusto = FLUIGC.autocomplete('#ccusto_nome', {
        	    source: substringMatcher("centroCusto"),
        	    name: 'NOME_CCUSTO',
        	    displayKey: 'NOME_CCUSTO',
        	    tagClass: '',
        	    type: 'autocomplete', //'tagAutocomplete',
        	    autoLoading: true,
        	    maxTags: 1,


        	    allowDuplicates: false,
        	    tagMaxWidth: 400,
        	    templates: {
        	        suggestion: '<div><h6>{{CODCCUSTO}} - {{NOME_CCUSTO}}</h6><div>'
        	    }
        	});

        	acCentroCusto.on("fluig.autocomplete.selected", function (event) {
        	    selectedCentroCusto = event.item;
        	    $("#ccusto_codigo").val(selectedCentroCusto.CODCCUSTO);
        	});

        	acCentroCusto.on("fluig.autocomplete.opened", function (event) {
        	    resetCentroCusto();
        	    selectedCentroCusto = {};
        	    $("#ccusto_codigo").val("");
        	});

        	acCentroCusto.on("fluig.autocomplete.closed", function (event) {
        	    var value = $("#ccusto_codigo").val();
        	    if (!value) {
        	        resetCentroCusto();
        	    }
        	});
        	// FIM ----------------------
        	
            acCentroCusto.val("%");
            $("#ccusto_nome").focus();
            acCentroCusto.open();
        }
    }
    */

    if (target == "acLocalEstoque") {
        if (!$("#local_estoque_nome").prop("readonly")) {
            acLocalEstoque.val("%");
            $("#local_estoque_nome").focus();
            acLocalEstoque.open();
        }
    }

    if (target == "acContrato") {
        if (!$("#contrato_nome").prop("readonly")) {
            acContrato.val("%");
            $("#contrato_nome").focus();
            acContrato.open();
        }
    }

    if (target == "acUnidade") {
        if (!$("#unidade_nome").prop("readonly")) {
            acUnidade.val("%");
            $("#unidade_nome").focus();
            acUnidade.open();
        }
    }

    if (target == "acFornecedor") {
        if (!$("#fornecedor_nome").prop("readonly")) {
            acFornecedor.val("%");
            $("#fornecedor_nome").focus();
            acFornecedor.open();
        }
    }


});