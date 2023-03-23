var selectedCentroCusto = {};
var selectedacLocalEstoque = {};
var selectedacProduto = {};
var selectedacContrato = {};
var selectedacEmpresa = {};
var selectacUnidade={};
var selectacFavorecido={};


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
        suggestion: '<div><h6>{{CODCCUSTO}} - {{NOME_CCUSTO}}</h6><h6>Coligada: {{CODCOLIGADA}}</h6><div>'
    }



});

acCentroCusto.on("fluig.autocomplete.selected", function (event) {

    selectedCentroCusto = event.item;
    $("#ccusto_codigo").val(selectedCentroCusto.CODCCUSTO).validate();
    $(this).attr("readonly",false).blur().validate();

});

acCentroCusto.on("fluig.autocomplete.opened", function (event) {
    resetCentroCusto();
    selectedCentroCusto = {};
    $("#ccusto_codigo").val("");


});

acCentroCusto.on("fluig.autocomplete.closed", function (event) {
    $(this).attr("readonly",false);
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

  
    selectacUnidade = event.item;
    $("#unidade_codigo").val(selectacUnidade.COD_UNIDADE).validate();
    $(this).attr("readonly",false).blur().validate();

    var codusuario_rm=$("#codusuario_rm").val();

    selectacFavorecido = buscarFavorecido(codusuario_rm);

    if(selectacFavorecido.CGCFO){
        setFavorecido();
     
    }

 

});

acUnidade.on("fluig.autocomplete.opened", function (event) {

    resetUnidade();
    selectacUnidade = {};
    $("#unidade_codigo").val("");


});

acUnidade.on("fluig.autocomplete.closed", function (event) {

    $(this).attr("readonly",false);
    var value = $("#unidade_codigo").val();
    if (!value) {
        resetUnidade();
    }


});


///////////////////////////////////

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
    $("#empresa_codigo").val(selectedacEmpresa.CODCOLIGADA).validate();
    $("#codcoligada").val(selectedacEmpresa.CODCOLIGADA);
    $(this).attr("readonly",false).blur().validate();
    

});

acEmpresa.on("fluig.autocomplete.opened", function (event) {

    selectedacEmpresa = {};

    resetEmpresa();


});

acEmpresa.on("fluig.autocomplete.closed", function (event) {

  
    $(this).attr("readonly",false);
    var value = $("#empresa_codigo").val();
    if (!value) {

        resetEmpresa();

    }

});

// AC FAVORECIDO


var acFavorecido = FLUIGC.autocomplete('#favorecido_nome', {
    source: substringMatcher("favorecido"),
    name: 'nome',
    displayKey: 'NOME',
    tagClass: '',
    type: 'autocomplete', //'tagAutocomplete',
    autoLoading: true,
    maxTags: 1,
    allowDuplicates: false,
    tagMaxWidth: 400,
    templates: {
        suggestion: '<div><h6>{{NOME}} - {{CGCCFO}}</h6><div>'
    }
});

acFavorecido.on("fluig.autocomplete.selected", function (event) {

 

    selectacFavorecido = event.item;
    setFavorecido();
    $(this).attr("readonly",false).blur().validate();
    
    


});

function setFavorecido(){

        $("#favorecido_codigo").val(selectacFavorecido.CPF).validate();
        $("#login_favorecido").val(selectacFavorecido.LOGIN);
        $("#email_favorecido").val(selectacFavorecido.EMAIL);
        $("#codusuario_favorecido").val(selectacFavorecido.LOGIN);
        $("#codcfo_favorecido").val(selectacFavorecido.CODCFO);
        $("#cgcfo_favorecido").val(selectacFavorecido.CGCFO);
        $("#restrito_favorecido").val(selectacFavorecido.RESTRITO);
        

        var gestor = favorecidoGestor(selectacFavorecido.EMAIL);

        if (gestor.length > 0) {

            console.log("Favorecido é gestor ");
            console.table(gestor);

            $("#favorecidoGestorUnidade").val(gestor[0].UNIDADE);
            $("#favorecidoGestorPortfolio").val(gestor[0].PORTFOLIO);
            $("#favorecidoGestorDiretor").val(gestor[0].DIRETOR);
            $("#favorecidoGestorPresidente").val(gestor[0].PRESIDENTE);
            
            

        }

        $("#id_finalidade").val("");
            $("#descricao_finalidade").val("");
            carregaFinalidades();
            
        if(selectacFavorecido.RESTRITO){

            

        }

}

acFavorecido.on("fluig.autocomplete.opened", function (event) {
   
    resetFavorecido();
    selectacFavorecido = {};


});

acFavorecido.on("fluig.autocomplete.closed", function (event) {
    $(this).attr("readonly",false);
    var value = $("#favorecido_codigo").val();
    if (!value) {
        resetFavorecido();
    }


});


function resetEmpresa() {

    selectedacEmpresa = {};
    acEmpresa.val("");

    $("#empresa_codigo").val("");
    $("#empresa_nome").val("");
    $("#codcoligada").val("");

    


    resetUnidade();
    resetCentroCusto();

    validateAll();

}

function resetCentroCusto() {

    selectedCentroCusto = {};
    acCentroCusto.val("");
    $("#ccusto_codigo").val("");
    $("#ccusto_nome").val("");

    validateAll();

}

function resetUnidade() {

    selectacUnidade = {};
    acUnidade.val("");
    $("#unidade_codigo").val("");
    $("#unidade_nome").val("");
    resetCentroCusto();
    resetFavorecido();
    validateAll();

}

function resetFavorecido() {

    selectacFavorecido = {};
    acFavorecido.val("");
    $("#favorecido_codigo").val("");
    $("#favorecido_nome").val("");
    $("#login_favorecido").val("");
    $("#email_favorecido").val("");
    $("#codusuario_favorecido").val("");
    $("#codcfo_favorecido").val("");
    $("#cgcfo_favorecido").val("");
    $("#restrito_favorecido").val("");
    $("#favorecidoGestorUnidade").val("");
    $("#favorecidoGestorPortfolio").val("");
    $("#favorecidoGestorDiretor").val("");
    $("#favorecidoGestorPresidente").val("");
    
   // resetCentroCusto();
    validateAll();

}

$("[data-btn-zoom-autocomplete]").click(function () {

    var target = $(this).data("btn-zoom-autocomplete");


    if (target == "acEmpresa") {
        acEmpresa.val("%");
        $("#empresa_nome").attr("readonly",true);
        $("#empresa_nome").focus();
        acEmpresa.open();
    }

    if (target == "acCentroCusto") {
        acCentroCusto.val("%");
        $("#ccusto_nome").attr("readonly",true).focus();
        acCentroCusto.open();
    }

    if (target == "acUnidade") {
        if(!$("#unidade_nome").is('[readonly]')){
        acUnidade.val("%");
        $("#unidade_nome").attr("readonly",true).focus();
        acUnidade.open();
    }}

    if (target == "acFavorecido") {
        if(!$("#favorecido_nome").is('[readonly]')){
        acFavorecido.val("%");
        $("#favorecido_nome").attr("readonly",true).focus();
        acFavorecido.open();
    }
    }
    



});

function substringMatcher(source) {

    var timeout;

    return function findMatches(q, cb) {
        var matches, substrRegex;
        if (timeout) {
            clearTimeout(timeout);
        }
        timeout = setTimeout(function () {
            if (source == "centroCusto")
                matches = buscarCentroCusto(q)
            if (source == "empresa")
                matches = buscarEmpresa(q)
            if (source == "unidade")
                matches = buscarUnidade(q)
            if (source == "favorecido")
                matches = buscarFavorecido(q)

            cb(matches);
        }, 500);
    };
};

function buscarCentroCusto(parametro) {



    var returnList = [];
    var constraints = new Array();

    var codusuario = $("#codusuario_rm").val();
    var coligada   = $("#empresa_codigo").val();



    constraints.push(DatasetFactory.createConstraint("sqlLimit", "100", "100", ConstraintType.MUST));
    constraints.push(DatasetFactory.createConstraint("CODUSUARIO", codusuario, codusuario, ConstraintType.MUST));
    constraints.push(DatasetFactory.createConstraint("CODCOLIGADA", coligada,coligada, ConstraintType.MUST, false));
    //constraints.push(DatasetFactory.createConstraint("CODCCUSTO", "%" + parametro + "%", "%" + parametro + "%", ConstraintType.SHOULD, true));
    constraints.push(DatasetFactory.createConstraint("COD_UNIDADE", $("#unidade_codigo").val(), $("#unidade_codigo").val(), ConstraintType.MUST));
    
    var dataset = DatasetFactory.getDataset("rm_consulta_centro_custo_usuario", null, constraints, null);
  


    if (dataset) {
        returnList = dataset.values;

    }

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

    var codusuario = $("#codusuario_rm").val();

    //Busca Unidades do Usuário
    var c1 = DatasetFactory.createConstraint("CODUSUARIO", codusuario, codusuario, ConstraintType.MUST);
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

function buscarFavorecido(parametro) {
    var returnList = [];
    var constraints = new Array();

    var codusuario   = $("#codusuario_rm").val();
    var empresa      = $("#empresa_codigo").val();
    var unidade      = $("#unidade_codigo").val();
    var centro_custo = $("#ccusto_codigo").val();

    constraints.push(DatasetFactory.createConstraint("sqlLimit", "100", "100", ConstraintType.MUST));
   // constraints.push(DatasetFactory.createConstraint("CODUSUARIO", codusuario, codusuario, ConstraintType.MUST));
    //constraints.push(DatasetFactory.createConstraint("CODCOLIGADA", coligada,coligada, ConstraintType.MUST, false));
    constraints.push(DatasetFactory.createConstraint("NOME", "%" + parametro + "%", "%" + parametro + "%", ConstraintType.SHOULD, true));
    constraints.push(DatasetFactory.createConstraint("CPF", "%" + parametro + "%", "%" + parametro + "%", ConstraintType.SHOULD, true));
    constraints.push(DatasetFactory.createConstraint("LOGIN", "%" + parametro + "%", "%" + parametro + "%", ConstraintType.SHOULD, true));
    constraints.push(DatasetFactory.createConstraint("EMAIL", "%" + parametro + "%", "%" + parametro + "%", ConstraintType.SHOULD, true));
    constraints.push(DatasetFactory.createConstraint("COD_UNIDADE", unidade, unidade, ConstraintType.MUST));
    
    var dataset = DatasetFactory.getDataset("rm_consulta_favorecido", null, constraints, null);
  


    if (dataset) {
        returnList = dataset.values;
    }

    return returnList;
}