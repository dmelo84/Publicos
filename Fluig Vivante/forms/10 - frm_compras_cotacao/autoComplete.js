var selectedFornecedor={};
var selectedacEmpresa={};
var selectedacUnidade={};
var selectedacFilial={};


var acFornecedor = FLUIGC.autocomplete('#forn_nome_pesquisa', {
        source: substringMatcher("fornecedor"),
        name: 'nome',
        displayKey: 'NOMEFANTASIA',
        tagClass: '',
        type: 'autocomplete',
        autoLoading: true,
        maxTags: 1,


        allowDuplicates: false,
        tagMaxWidth: 400,
        templates: {
            suggestion: '<div><h6>{{CODCFO}} </br><strong>{{NOMEFANTASIA}}</strong> </br> {{NOME}}</h6><div>'
        }
    });

acFornecedor.on("fluig.autocomplete.selected", function (event) {
    console.log(event);
    selectedFornecedor = event.item;

    $("#forn_codigo_pesquisa").val(selectedFornecedor.CODCFO);
    
    


});

acFornecedor.on("fluig.autocomplete.opened", function (event) {
    selectedFornecedor = {};

    $("#forn_codigo_pesquisa").val("");
    $("#forn_nome_pesquisa").val("");

    acFornecedor.removeAll();

});


acFornecedor.on("fluig.autocomplete.closed", function (event) {

    var value = $("#forn_codigo_pesquisa").val();
    if (!value) {

        selectedFornecedor = {};

        $("#forn_codigo_pesquisa").val("");
        $("#forn_nome_pesquisa").val("");

    acFornecedor.removeAll();
       

    }
});



var acUnidade = FLUIGC.autocomplete('#unidade_nome', {
    source: substringMatcher("unidade"),
    name: 'nome',
    displayKey: 'NOME',
    tagClass: '',
    type: 'autocomplete', //'tagAutocomplete',
    autoLoading: false,
    maxTags: 1,


    allowDuplicates: false,
    tagMaxWidth: 400,
    templates: {
        suggestion: '<div><h6>{{COD_UNIDADE}} - {{NOME}}</h6><div>'
    }
});


acUnidade.on("fluig.autocomplete.selected", function (event) {


    selectedacUnidade = event.item;
    $("#unidade_codigo").val(selectedacUnidade.COD_UNIDADE);
    checkEnableAddSolicitacao();


});

acUnidade.on("fluig.autocomplete.opened", function (event) {

    selectedacUnidade = {};
    $("#unidade_codigo").val("");
    resetUnidade();

});

acUnidade.on("fluig.autocomplete.closed", function (event) {

    var value = $("#unidade_codigo").val();
    if (!value) {
        resetUnidade();
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


});

acEmpresa.on("fluig.autocomplete.opened", function (event) {

    selectedacEmpresa = {};
    $("#empresa_codigo").val("");
    resetEmpresa();


});

acEmpresa.on("fluig.autocomplete.closed", function (event) {



    var value = $("#empresa_codigo").val();
    if (!value) {

        resetEmpresa();

    }

});





var acFilial = FLUIGC.autocomplete('#filial_nome', {
    source: substringMatcher("filial"),
    name: 'nome',
    displayKey: 'FILIAL_NOMEFANTASIA',
    tagClass: '',
    type: 'autocomplete', //'tagAutocomplete',
    autoLoading: false,
    maxTags: 1,


    allowDuplicates: false,
    tagMaxWidth: 400,
    templates: {
        suggestion: '<div><h6>{{CODFILIAL}} - {{FILIAL_NOMEFANTASIA}}</h6><div>'
    }
});


acFilial.on("fluig.autocomplete.selected", function (event) {


    selectedacFilial = event.item;
    $("#filial_codigo").val(selectedacFilial.CODFILIAL);


});

acFilial.on("fluig.autocomplete.opened", function (event) {

    selectedacFilial = {};
    $("#filial_codigo").val("");
    resetFilial();


});

acFilial.on("fluig.autocomplete.closed", function (event) {



    var value = $("#filial_codigo").val();
    if (!value) {

        resetFilial();

    }

});






function resetEmpresa(){
    console.log("ResetEmpresa");
    selectedacEmpresa = {};
    acEmpresa.val("");
    $("#empresa_codigo").val("");

    resetUnidade();
    resetFilial();

    limpaTabelaSelecaoItensCotacao();

}

function resetFornecedor(){
   
    selectedFornecedor = {};
    acFornecedor.val("");
    $("#forn_codigo_pesquisa").val("");
    $("#forn_nome_pesquisa").val("");
}


function resetFilial(){
   
    selectedFilial = {};
    acFilial.val("");
    $("#filial_codigo").val("");
    $("#filial_nome").val("");
}

function resetUnidade(){
   
    selectedacUnidade = {};
    acUnidade.val("");
    $("#unidade_codigo").val("");
    $("#unidade_nome").val("");
    checkEnableAddSolicitacao();
    limpaTabelaSelecaoItensCotacao();
    limpaTabelaSelecaoFornecedoresCotacao();
    limpaTabelaItensCotacaoFornecedor();
}



function limpaTabelaSelecaoItensCotacao(){

    $('#selecaoItensCotacao tbody tr').not(':first').each(
		function (count, tr) {
			fnWdkRemoveChild(tr);
		}
	);

	WdksetNewId.tblItem = 0;
}

function limpaTabelaSelecaoFornecedoresCotacao(){

    $('#tblFornecedor tbody tr').not(':first').each(
		function (count, tr) {
			fnWdkRemoveChild(tr);
		}
	);

	WdksetNewId.tblFornecedor = 0;
}

function limpaTabelaItensCotacaoFornecedor(){

    $('#tblItensCotacaoFornecedor tbody tr').not(':first').each(
		function (count, tr) {
			fnWdkRemoveChild(tr);
		}
	);

	WdksetNewId.tblItensCotacaoFornecedor = 0;
}


function buscarFornecedor(parametro){

    var returnList = [];

    console.log("buscarFornecedor")
    console.log(parametro);


    var c0 = DatasetFactory.createConstraint("sqlLimit", "50", "50", ConstraintType.MUST);
    var c1 = DatasetFactory.createConstraint("CGCCFO", "%" + parametro + "%", "%" + parametro + "%", ConstraintType.SHOULD, true);
    var c2 = DatasetFactory.createConstraint("NOME", "%" + parametro + "%", "%" + parametro + "%", ConstraintType.SHOULD, true);
    var c3 = DatasetFactory.createConstraint("CODCFO", "%" + parametro + "%", "%" + parametro + "%", ConstraintType.SHOULD, true);
    var c4 = DatasetFactory.createConstraint("NOMEFANTASIA", "%" + parametro + "%", "%" + parametro + "%", ConstraintType.SHOULD, true);

    var constraints = new Array(c0, c1, c2, c3, c4);

    var dataset = DatasetFactory.getDataset("rm_consulta_cliente_fornecedor", null, constraints, null);

    if (dataset) {
        returnList = dataset.values;
    }
    console.log("buscarFornecedor ret");
    console.dir(returnList);

    return returnList;

}

function buscarEmpresa(parametro) {

    var returnList = [];


    var c0 = DatasetFactory.createConstraint("sqlLimit", "50", "50", ConstraintType.MUST);
    var c1 = DatasetFactory.createConstraint("NOME", "%" + parametro + "%", "%" + parametro + "%", ConstraintType.SHOULD, true);
    var c2 = DatasetFactory.createConstraint("CODCOLIGADA", "%" + parametro + "%", "%" + parametro + "%", ConstraintType.SHOULD, true);


    var constraints = new Array(c0,c1,c2);

    var dataset = DatasetFactory.getDataset("rm_consulta_coligada", null, constraints, null);

    if (dataset) {
        returnList = dataset.values;
    }

    return returnList;
}

function buscarUnidade(parametro) {

    var returnList = [];
    
    //Busca Unidades do Usuário
    var c1 = DatasetFactory.createConstraint("CODUSUARIO", $("#codusuario_rm").val(), $("#codusuario_rm").val(), ConstraintType.MUST);
    var c2 = DatasetFactory.createConstraint("CODCOLIGADA", $("#empresa_codigo").val(), $("#empresa_codigo").val(), ConstraintType.MUST, true);
    var c3 = DatasetFactory.createConstraint("NOME", "%" + parametro + "%", "%" + parametro + "%", ConstraintType.SHOULD, true);
    var c4 = DatasetFactory.createConstraint("COD_UNIDADE", "%" + parametro + "%", "%" + parametro + "%", ConstraintType.SHOULD, true);
    var constraints = new Array(c1,c2,c3,c4);

    var dataset = DatasetFactory.getDataset("rm_consulta_usuario_unidade", null, constraints, null);

    if (dataset) {
        returnList = dataset.values;
    }

    return returnList;


}


function buscarFilial(parametro) {

    var returnList = [];
    
    //Busca Unidades do Usuário
    var c1 = DatasetFactory.createConstraint("CODUSUARIO", $("#codusuario_rm").val(), $("#codusuario_rm").val(), ConstraintType.MUST);
    var c2 = DatasetFactory.createConstraint("CODCOLIGADA", $("#empresa_codigo").val(), $("#empresa_codigo").val(), ConstraintType.MUST, true);
    var c3 = DatasetFactory.createConstraint("FILIAL_NOMEFANTASIA", "%" + parametro + "%", "%" + parametro + "%", ConstraintType.SHOULD, true);
   // var c4 = DatasetFactory.createConstraint("COD_UNIDADE", "%" + parametro + "%", "%" + parametro + "%", ConstraintType.SHOULD, true);
    var constraints = new Array(c1,c2,c3);

    var dataset = DatasetFactory.getDataset("rm_consulta_usuario_filial", null, constraints, ["CODFILIAL"]);

    if (dataset) {
        returnList = dataset.values;
    }

    return returnList;







}

function substringMatcher(source) {

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
            if (source == "filial")
                matches = buscarFilial(q)

                


            cb(matches);
        }, 500);
    };
};

$("[data-btn-zoom-autocomplete]").click(function () {

    var target = $(this).data("btn-zoom-autocomplete");
    console.log(target);

    if(target == "acEmpresa" )
    {
        acEmpresa.val("%");
        $("#empresa_nome").focus();
        acEmpresa.open();
    }

    if(target == "acCentroCusto" )
    {
        acCentroCusto.val("%");
        $("#ccusto_nome").focus();
        acCentroCusto.open();
    }

      if(target == "acFornecedor" )
    {
        acFornecedor.val("%");
        $("#forn_nome_pesquisa").focus();
        acFornecedor.open();
    }

    if(target == "acContrato" )
  {
      acContrato.val("%");
      $("#contrato_descricao").focus();
      acContrato.open();
  }

  if(target == "acUnidade" )
  {
      acUnidade.val("%");
      $("#unidade_nome").focus();
      acUnidade.open();
  }

  if(target == "acFilial" )
  {
      acFilial.val("%");
      $("#filial_nome").focus();
      acFilial.open();
  }



});
