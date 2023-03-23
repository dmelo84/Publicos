
var selectedFornecedor={};
var acFornecedor = FLUIGC.autocomplete('#fornecedor_nome', {
    source: substringMatcher("fornecedor"),
    name: 'NOMEFANTASIA',
    displayKey: 'NOMEFANTASIA',
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

console.log("ACFORNECEDOR");
console.log(acFornecedor)

function substringMatcher(source) {

    console.log("substringMatcher");
    var timeout;

    return function findMatches(q, cb) {
        var matches, substrRegex;
        if (timeout) {
            clearTimeout(timeout);
        }
        timeout = setTimeout(function () {
            if (source == "fornecedor")
                matches = buscarFornecedor(q)
            if (source == "centroCusto")
                matches = buscarCentroCusto(q)
            if (source == "localEstoque")
                matches = buscarLocalEstoque(q)
            if (source == "produto")
                matches = buscarProduto(q)
            if (source == "contrato")
                matches = buscarContrato(q)
            if (source == "empresa")
                matches = buscarEmpresa(q)
            if (source == "unidade")
                matches = buscarUnidade(q)


            cb(matches);
        }, 500);
    };
};

function buscarFornecedor(parametro){

    var returnList = [];


    var c0 = DatasetFactory.createConstraint("sqlLimit", "50", "50", ConstraintType.MUST);
    var c1 = DatasetFactory.createConstraint("CGCCFO", "%" + parametro + "%", "%" + parametro + "%", ConstraintType.SHOULD, true);
    var c2 = DatasetFactory.createConstraint("NOME", "%" + parametro + "%", "%" + parametro + "%", ConstraintType.SHOULD, true);
    var c3 = DatasetFactory.createConstraint("CODCFO", "%" + parametro + "%", "%" + parametro + "%", ConstraintType.SHOULD, true);


    var constraints = new Array(c0, c1, c2, c3);

    var dataset = DatasetFactory.getDataset("rm_consulta_cliente_fornecedor", null, constraints, null);

    if (dataset) {
        returnList = dataset.values;
    }

    return returnList;

}

acFornecedor.on("fluig.autocomplete.selected", function (event) {

    console.log("fluig.autocomplete.selected")
    console.log(event);
    selectedFornecedor = event.item;

    $("#fornecedor_codigo").val(selectedFornecedor.CODCFO);
    
});

acFornecedor.on("fluig.autocomplete.opened", function (event) {

    console.log("fluig.autocomplete.opened")

    selectedFornecedor = {};

    $("#fornecedor_codigo").val("");

    acFornecedor.removeAll();

});

acFornecedor.on("fluig.autocomplete.closed", function (event) {

    console.log("fluig.autocomplete.closed")

    var value = $("#fornecedor_codigo").val();
    if (!value) {

        selectedFornecedor = {};

        $("#fornecedor_codigo").val("");

    acFornecedor.removeAll();
       

    }
});

console.log("Carregou autoComplete");