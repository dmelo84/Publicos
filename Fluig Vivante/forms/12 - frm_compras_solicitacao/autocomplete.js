/// Autocomplete Centro de Custo

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


// AC UNIDADE


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

    console.log("fluig.autocomplete.selected")
    selectacUnidade = event.item;
    $("#unidade_codigo").val(selectacUnidade.COD_UNIDADE);
    $("#finalidade_especifica").prop('disabled', false);

});

acUnidade.on("fluig.autocomplete.opened", function (event) {
    console.log("fluig.autocomplete.opened")
    resetUnidade();
    selectacUnidade = {};
    $("#unidade_codigo").val("");
    $("#finalidade_especifica").prop('checked', false);
    $("#finalidade_especifica").prop('disabled', true);


});

acUnidade.on("fluig.autocomplete.closed", function (event) {

    var value = $("#unidade_codigo").val();
    //$("#finalidade_especifica").prop('checked', false);
    //$("#finalidade_especifica").prop('disabled', true);
    if (!value) {
        resetUnidade();
    }


});


///////////////////////////////////

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
        selectedacLocalEstoque.RUA + " " +
        selectedacLocalEstoque.NUMERO + " " +
        selectedacLocalEstoque.BAIRRO
    );
    $("#entrega_cidade").val(selectedacLocalEstoque.CIDADE);
    $("#cnpj_filial_vivante").val(selectedacLocalEstoque.CNPJ_VIVANTE);
    $("#codfilial").val(selectedacLocalEstoque.CODFILIAL);
    $("#entrega_uf").val(selectedacLocalEstoque.CODETD);





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
var acContrato = FLUIGC.autocomplete('#contrato_descricao', {
    source: substringMatcher("contrato"),
    name: 'NOME',
    displayKey: 'NOME',
    tagClass: '',
    type: 'autocomplete',
    autoLoading: false,
    maxTags: 1,
    allowDuplicates: false,
    tagMaxWidth: 400,
    templates: {
        suggestion: '<div><h6><strong>{{CODIGOCONTRATO}} - {{NOME}}</strong></h6><div>'
    }
});

acContrato.on("fluig.autocomplete.selected", function (event) {


    selectedacContrato = event.item;



    console.log("Contrato!!");
    console.table(selectedacContrato);

    $("#contrato_codigo").val(selectedacContrato.CODIGOCONTRATO);
    $("#contrato_descricao").val(selectedacContrato.NOME);

    $("#fornecedor_codigo").val(selectedacContrato.CODCFO).attr("disabled", true);
    $("#fornecedor_nome").val(selectedacContrato.RAZAO_SOCIAL).attr("disabled", true);
    $("#fornecedor_cnpj").val(selectedacContrato.CNPJ).attr("disabled", true);

    //CONTRATO GLOBAL (GUARDA-CHUVA)
    if (selectedacContrato.CODTCN != 100) {

        $("#ccusto_codigo").val(selectedacContrato.CCUSTO_CODIGO).attr("disabled", true);
        $("#ccusto_nome").val(selectedacContrato.CCUSTO_NOME).attr("disabled", true);

        $("#unidade_codigo").val(selectedacContrato.UNIDADE).attr("disabled", true);
        $("#unidade_nome").val(selectedacContrato.CCUSTO_NOME).attr("disabled", true);

        $("[data-btn-zoom-autocomplete='acCentroCusto']").hide();
        $("[data-btn-zoom-autocomplete='acUnidade']").hide();
    } else {

        $("#ccusto_codigo").attr("disabled", false);
        $("#ccusto_nome").attr("disabled", false);

        $("#unidade_codigo").attr("disabled", false);
        $("#unidade_nome").attr("disabled", false);

        $("[data-btn-zoom-autocomplete='acCentroCusto']").show();
        $("[data-btn-zoom-autocomplete='acUnidade']").show();

    }
    validateAll();
    atualizaPreco();
});

acContrato.on("fluig.autocomplete.opened", function (event) {
    resetContrato();
    selectedacContrato = {};
    // $("#contrato_codigo").val("");


});

acContrato.on("fluig.autocomplete.closed", function (event) {

    var value = $("#contrato_codigo").val();
    if (!value) {
        resetContrato();
    }


});

/// Autocomplete Empresa
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


/// Autocomplete Empresa
var acFinalidadeCompra = FLUIGC.autocomplete('#finalidade_compra', {
    source: substringMatcher("finalidade"),
    name: 'DESCRICAO',
    displayKey: 'DESCRICAO',
    tagClass: '',
    type: 'autocomplete', //'tagAutocomplete',
    autoLoading: false,
    maxTags: 1,
    allowDuplicates: false,
    tagMaxWidth: 400,
    templates: {
        suggestion: '<div><h6>{{DESCRICAO}}</h6><div>'
    }
});


acFinalidadeCompra.on("fluig.autocomplete.selected", function (event) {


    selectacFinalidadeCompra = event.item;
    var codFinalidade = selectacFinalidadeCompra.CODFINALIDADE;

    $("#finalidade_compra_codigo").val(codFinalidade);
    var produtos = buscarProdutoFinalidade(codFinalidade);

    produtos.length > 0 ? removeItensExclusivo() : false;


    for (let i = 0; i < produtos.length; i++) {
       

        var codcoligada = $("#codcoligada").val();
        var codigoprd = produtos[i].CODIGOPRD;

        var constraints = new Array();
            constraints.push(DatasetFactory.createConstraint("CODCOLIGADA",codcoligada,codcoligada,ConstraintType.MUST));
            constraints.push(DatasetFactory.createConstraint("CODIGOPRD",codigoprd,codigoprd,ConstraintType.MUST));

        var dataset = DatasetFactory.getDataset("rm_consulta_produto_ws", null, constraints, null);

        if (dataset) {

            addItemTable(dataset.values[0],1,true);
           // returnList = dataset.values;
        }

    

    }


    //  $("#empresa_codigo").val(selectedacEmpresa.CODCOLIGADA);
    //  $("#codcoligada").val(selectedacEmpresa.CODCOLIGADA);


});

acFinalidadeCompra.on("fluig.autocomplete.opened", function (event) {

    selectacFinalidadeCompra = {};

     resetFinalidadeCompra();


});

acFinalidadeCompra.on("fluig.autocomplete.closed", function (event) {



    var value = $("#finalidade_compra").val();
      if (!value) {

        resetFinalidadeCompra();

      }

});


/// Autocomplete Produto
var acProduto = FLUIGC.autocomplete('#produto_descricao_add', {
    source: substringMatcher("produto"),
    name: 'DESCRICAO',
    displayKey: 'DESCRICAO',
    tagClass: '',
    type: 'tagAutocomplete',//'tagAutocomplete',
    autoLoading: true,
    maxTags: 1,
    allowDuplicates: false,
    tagMaxWidth: 400,
    templates: {
        suggestion: '<div><h6><strong>{{CODIGOPRD}} - {{DESCRICAO}}</strong></h6><div>'
    }
});

acProduto.on("fluig.autocomplete.itemAdded", function (event) {
    selectedacProduto = event.item;

    $("#produto_codigo_add").val(selectedacProduto.CODIGOPRD);
    $("#produto_un_add").val(selectedacProduto.CODUNDCOMPRA);


    //$("#observacoes_capa").text($("#div_adicionaProduto").html())

});

acProduto.on("fluig.autocomplete.itemRemoved", function (event) {
    selectedacProduto = {};

    $("#produto_codigo_add").val("");
    $("#produto_un_add").val("");
    $("#produto_quantidade_add").val("");


});

function resetFinalidadeCompra(){

    selectacFinalidadeCompra = {};
    acFinalidadeCompra.val("");
    $("#finalidade_compra").val("");
    $("#finalidade_compra_codigo").val("");
}

function resetEmpresa() {

    selectedacEmpresa = {};
    acEmpresa.val("");

    $("#empresa_codigo").val("");
    $("#empresa_nome").val("");
    $("#codcoligada").val("");



    resetContrato();
    resetUnidade();
    resetCentroCusto();

    validateAll();

}

function resetCentroCusto() {
    console.log("ResetCCusto");
    selectedCentroCusto = {};
    acCentroCusto.val("");
    $("#ccusto_codigo").val("");
    $("#ccusto_nome").val("");
    resetLocalEstoque();
    validateAll();

}

function resetLocalEstoque() {

    selectedacLocalEstoque = {};
    acLocalEstoque.val("");
    $("#local_estoque_codigo").val("");
    $("#local_estoque_nome").val("");
    $("#codfilial").val("");
    limpaLocalEntrega();
    validateAll();

}


function resetContrato() {

    selectedacContrato = {};
    acContrato.val("");
    $("#contrato_codigo").val("");
    $("#contrato_descricao").val("");
    $("#fornecedor_codigo").val("");
    $("#fornecedor_nome").val("");
    $("#fornecedor_cnpj").val("");
    
    //resetUnidade();
    validateAll();



}


function resetUnidade() {

    selectacUnidade = {};
    acUnidade.val("");
    $("#unidade_codigo").val("");
    $("#unidade_nome").val("");
    resetCentroCusto();
    resetFinalidadeCompra();
    validateAll();

}






$("[data-btn-zoom-autocomplete]").click(function () {

    var target = $(this).data("btn-zoom-autocomplete");
    console.log(target);

    if (target == "acEmpresa") {
        acEmpresa.val("%");
        $("#empresa_nome").focus();
        acEmpresa.open();
    }

    if (target == "acCentroCusto") {
        acCentroCusto.val("%");
        $("#ccusto_nome").focus();
        acCentroCusto.open();
    }



    if (target == "acLocalEstoque") {
        acLocalEstoque.val("%");
        $("#local_estoque_nome").focus();
        acLocalEstoque.open();
    }

    if (target == "acContrato") {
        acContrato.val("%");
        $("#contrato_descricao").focus();
        acContrato.open();
    }

    if (target == "acUnidade") {
        if (!$("#unidade_nome").is('[readonly]')) {
            acUnidade.val("%");
            $("#unidade_nome").focus();
            acUnidade.open();
        }
    }

    if (target == "acFinalidadeCompra") {
        if (!$("#finalidade_compra").is('[readonly]')) {
            acFinalidadeCompra.val("%");
            $("#finalidade_compra").focus();
            acFinalidadeCompra.open();
        }





    }
});