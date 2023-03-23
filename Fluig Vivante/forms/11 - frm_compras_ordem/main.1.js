var selectedCentroCusto = {};
var selectedacLocalEstoque = {};
var selectedacProduto = {};
var selectedacContrato = {};
var selectedacEmpresa = {};
var selectacUnidade = {};
var selectedFornecedor = {};

//var myFORM = form

$(document).ready(function () {

    initMask();
    loadValidation();
    setTimeout(validateAll, 1000);

    $("#tipo_ordem").bind("change load", function () {

        var tipo = $(this).val();

    //  alert(tipo);

        if (tipo == "contrato") {
            $("#divContrato").show();
            tipoContrato();
        } else {
            $("#divContrato").hide();



            $("select option:contains(Contrato)").attr("disabled","disabled")
 
        
        }

    }).trigger("change");

    totalizaTodosItens();

});

function tipoContrato() {

    $("#div_adicionaProduto").hide();

    $("input[name^='produto_preco']").each(function () {
        $(this).attr("readonly", true);
    });

    $("#tipo_ordem").attr("readonly",true);

    $("[data-fieldset-contrato]").each(function () {

        $(this).attr("disabled", true);
    })

}

FLUIGC.calendar('#entrega_data_input', {
    pickDate: true,
    pickTime: false,
    minDate: new Date(),
});

$("#btn_entrega_data").click(function () {
    $("#entrega_data").focus();
})

$(document).on("change", "input[name^='produto_preco'],input[name^='produto_quantidade']", function () {


    var id = $(this).attr("name").split("___")[1];
    totalizaItem(id)
    /*
        var preco = convertStringFloat($("#produto_preco___" + id).val());
        var quantidade = convertStringFloat($("#produto_quantidade___" + id).val());

        var total = preco * quantidade;
        total = total.toFixed(2).toString().replace(".", ",");

        $("#produto_valorTotal___" + id).val("R$ " + total);*/


});


$("#btnIdentarXml").click(function (event) {

    event.preventDefault();

    var xml = $("#integracao_xml").val();

    $("#integracao_xml").val(vkbeautify.xml(xml));

})

function addItemTable(produto, quantidade) {

    var id = wdkAddChild('tblItensOrdem');

    var item = produto;

    $('#produto_codigo___' + id).val(item.CODIGOPRD);
    $('#produto_nome___' + id).val(item.DESCRICAO);
    $('#produto_un___' + id).val(item.CODUNDCOMPRA);
    $('#produto_quantidade___' + id).val(quantidade);
    $('#ccusto_codigo_item___' + id).val($("#ccusto_codigo").val());
    $('#ccusto_nome_item___' + id).val($("#ccusto_nome").val());

    $('#itemfamily___' + id).val(item.ITEMFAMILY);
    $('#itemcontrl___' + id).val(item.ITEMCONTRL);

    $('#produto_tipo___' + id).val(item.TIPO);
    $('#produto_codtb2fat___' + id).val(item.CODTB2FAT);

    $('#produto_idprd___' + id).val(item.IDPRD);

    limpaProdutoAdd();
    refreshSequenceItems();

    MaskEvent.init();
    initMask();
    loadValidation();
    setTimeout(validateAll, 1000);
}

function totalizaTodosItens() {

    $("input[name^='produto_preco']").each(function () {

        var id = $(this).attr("name").split("___")[1];
        totalizaItem(id);

    })



}

function totalizaItem(id) {

    //var id = $(this).attr("name").split("___")[1];

    var preco = convertStringFloat($("#produto_preco___" + id).val());
    var quantidade = convertStringFloat($("#produto_quantidade___" + id).val());

    var total = preco * quantidade;
    total = total.toFixed(2).toString().replace(".", ",");

    $("#produto_valorTotal___" + id).val("R$ " + total);


}

function limpaProdutoAdd() {

    $("#produto_codigo_add").val("");
    $("#produto_descricao_add").val("");
    $("#produto_un_add").val("");
    $("#produto_quantidade_add").val("");

    acProduto.removeAll();
    selectedacProduto = {};

}


$("#btnAddItem").click(function (event) {

    event.preventDefault();

    var produto = selectedacProduto;
    var quantidade = $("#produto_quantidade_add").val();

    console.log(produto);

    if (!jQuery.isEmptyObject(produto) && convertStringFloat(quantidade) > 0) {
        addItemTable(produto, quantidade);
    } else {
        FLUIGC.toast({
            title: '',
            message: 'É necessário informar o produto e quantidade.',
            type: 'warning'
        });
    }
});


function countChildItems() {
    var quantidade = $("table[tablename='tblItensOrdem'] tbody tr").length;
    quantidade = quantidade - 1;

    return quantidade;
}

function refreshSequenceItems() {
    var index = 0;
    $("table[tablename='tblItensOrdem'] tbody tr").each(function () {

        $(this).find("td input[name^='seq_']").val(index);
        index++;
    })
}

function fnCustomDelete(oElement) {
    // Chamada a funcao padrao, NAO RETIRAR
    fnWdkRemoveChild(oElement);
    refreshSequenceItems();
};


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
            if (source == "fornecedor")
                matches = buscarFornecedor(q)

            cb(matches);
        }, 500);
    };
};

function buscarContrato(parametro) {

    var returnList = [];

    var c0 = DatasetFactory.createConstraint("sqlLimit", "50", "50", ConstraintType.MUST);
    var c1 = DatasetFactory.createConstraint("NOME", "%" + parametro + "%", "%" + parametro + "%", ConstraintType.MUST, true);

    var constraints = new Array(c0, c1);

    var dataset = DatasetFactory.getDataset("rm_consulta_contrato", null, constraints, null);

    if (dataset) {
        returnList = dataset.values;
    }

    return returnList;
}

function buscarEmpresa(parametro) {

    var returnList = [];
    console.log("Buscar Empresa");

    var c0 = DatasetFactory.createConstraint("sqlLimit", "50", "50", ConstraintType.MUST);
    var c1 = DatasetFactory.createConstraint("NOME", "%" + parametro + "%", "%" + parametro + "%", ConstraintType.SHOULD, true);
    var c2 = DatasetFactory.createConstraint("CODCOLIGADA", "%" + parametro + "%", "%" + parametro + "%", ConstraintType.SHOULD, true);

    var constraints = new Array(c0, c1, c2);

    var dataset = DatasetFactory.getDataset("rm_consulta_coligada", null, constraints, null);

    if (dataset) {
        returnList = dataset.values;
    }

    return returnList;
}

function buscarUnidade(parametro) {

    var returnList = [];

    //Busca Unidades do Usuário
    var c1 = DatasetFactory.createConstraint("CODUSUARIO", "mestre", "mestre", ConstraintType.MUST);
    var c2 = DatasetFactory.createConstraint("CODCOLIGADA", $("#empresa_codigo").val(), $("#empresa_codigo").val(), ConstraintType.MUST, true);
    var c3 = DatasetFactory.createConstraint("NOME", "%" + parametro + "%", "%" + parametro + "%", ConstraintType.SHOULD, true);
    var c4 = DatasetFactory.createConstraint("COD_UNIDADE", "%" + parametro + "%", "%" + parametro + "%", ConstraintType.SHOULD, true);
    var constraints = new Array(c1, c2, c3, c4);

    var dataset = DatasetFactory.getDataset("rm_consulta_usuario_unidade", null, constraints, null);

    if (dataset) {
        returnList = dataset.values;
    }

    return returnList;




}


function buscarContrato(parametro) {

    var returnList = [];


    var c0 = DatasetFactory.createConstraint("sqlLimit", "50", "50", ConstraintType.MUST);
    var c1 = DatasetFactory.createConstraint("NOME", "%" + parametro + "%", "%" + parametro + "%", ConstraintType.MUST, true);


    var constraints = new Array(c0, c1);

    var dataset = DatasetFactory.getDataset("rm_consulta_contrato", null, constraints, null);

    if (dataset) {
        returnList = dataset.values;
    }

    return returnList;
}


function buscarLocalEstoque(parametro) {

    var returnList = [];


    var c0 = DatasetFactory.createConstraint("sqlLimit", "50", "50", ConstraintType.MUST);
    var c1 = DatasetFactory.createConstraint("CODLOC", "%" + $("#ccusto_codigo").val().substring(8, 12) + "%", "%" + $("#ccusto_codigo").val().substring(8, 12) + "%", ConstraintType.MUST, true);
    var c2 = DatasetFactory.createConstraint("CODLOC", "%" + parametro + "%", "%" + parametro + "%", ConstraintType.SHOULD, true);
    var c3 = DatasetFactory.createConstraint("NOME", "%" + parametro + "%", "%" + parametro + "%", ConstraintType.SHOULD, true);
    var c4 = DatasetFactory.createConstraint("FILIAL_VIVANTE", "%" + parametro + "%", "%" + parametro + "%", ConstraintType.SHOULD, true);


    var constraints = new Array(c0, c1, c2, c3, c4);

    var dataset = DatasetFactory.getDataset("rm_consulta_locais_de_estoque_ws", null, constraints, null);

    if (dataset) {
        returnList = dataset.values;
    }

    return returnList;
}


function buscarCentroCusto(parametro) {

    var returnList = [];
    var constraints = new Array();

    //Verifica se o usuário possui vinculo com centro de custo no Totvs RM
    var listaCCusto = [];
    listaCCusto = centroCustoAutorizado();

    var listSize = listaCCusto.length;

    if (listSize > 0) {
        for (let i = 0; i < listSize; i++) {
            constraints.push(DatasetFactory.createConstraint("CCUSTO_USUARIO", listaCCusto[i].CODCCUSTO, listaCCusto[i].CODCCUSTO, ConstraintType.SHOULD, true));
        }

    }
    // Fim Verificação
    var coligada = $("#empresa_codigo").val();

    constraints.push(DatasetFactory.createConstraint("sqlLimit", "10", "10", ConstraintType.MUST));
    constraints.push(DatasetFactory.createConstraint("CODCOLIGADA", coligada, coligada, ConstraintType.MUST, false));
    constraints.push(DatasetFactory.createConstraint("CODCCUSTO", "%" + parametro + "%", "%" + parametro + "%", ConstraintType.MUST, true));
    constraints.push(DatasetFactory.createConstraint("UNIDADE", $("#unidade_codigo").val(), $("#unidade_codigo").val(), ConstraintType.MUST, true));
    var dataset = DatasetFactory.getDataset("rm_consulta_centro_custo_sql", null, constraints, null);

    if (dataset) {
        returnList = dataset.values;
    }

    return returnList;
}

function centroCustoAutorizado() {
    var returnList = [];

    var codusuario = $("#codigo_solicitante").val();
    var c0 = DatasetFactory.createConstraint("FLUIG_LOGIN", codusuario, codusuario, ConstraintType.MUST);
    var constraints = new Array(c0);

    var dataset = DatasetFactory.getDataset("rm_consulta_centro_custo_usuario", null, constraints, null);

    if (dataset) {
        returnList = dataset.values;
    }

    return returnList;
}


function buscarFornecedor(parametro) {

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


function buscarProduto(parametro) {

    var returnList = [];


    var c0 = DatasetFactory.createConstraint("sqlLimit", "50", "50", ConstraintType.MUST);
    var c1 = DatasetFactory.createConstraint("CODCOLIGADA", "1", "1", ConstraintType.MUST);
    var c2 = DatasetFactory.createConstraint("CODIGOPRD", "%" + parametro + "%", "%" + parametro + "%", ConstraintType.SHOULD, true);
    var c3 = DatasetFactory.createConstraint("DESCRICAO", "%" + parametro + "%", "%" + parametro + "%", ConstraintType.SHOULD, true);


    var constraints = new Array(c0, c1, c2, c3);

    var dataset = DatasetFactory.getDataset("rm_consulta_produto_ws", null, constraints, null);

    if (dataset) {
        returnList = dataset.values;
    }

    return returnList;
}


function initMask() {

    $("[data-mask-money]").each(function () {
        $(this).maskMoney(({
            prefix: 'R$ ',
            allowNegative: false,
            thousands: '.',
            decimal: ',',
            affixesStay: true,
            defaultZero: true
        }));
    })

    $("[data-mask-value]").each(function () {
        $(this).maskMoney(({
            allowNegative: false,
            thousands: '.',
            decimal: ',',
            affixesStay: false,
            defaultZero: true
        }));

        $("[data-mask-percent]").each(function () {
            $(this).maskMoney(({
                suffix: ' %',
                allowNegative: false,
                thousands: '.',
                decimal: ',',
                affixesStay: true,
                defaultZero: true
            }));
        })
    })
}

function convertStringFloat(valor) {
    valor = String(valor);
    valor = valor.replace("R$ ", "").replace(" %", "");

    if (valor.indexOf(',') == -1) {} else {
        valor = valor.split(".").join("").replace(",", ".");
    }
    valor = parseFloat(valor);

    valor = valor.toFixed(4);

    return parseFloat(valor);
}



var loadValidation = function () {
    $.validate({
        validateOnBlur: true,
        validateHiddenInputs: false,
        dateFormat: 'dd/mm/yyyy',
        decimalSeparator: ",",
        onModulesLoaded: function () {},
        onElementValidate: function (valid, $el, $form, errorMess) {
            console.log('Input ' + $el.attr('name') + ' is ' + (valid ? 'VALID' : 'NOT VALID'));
        }
    });
}

function validateAll() {
    validationErrors = [];

    $('input,textarea').validate(function (valid, elem) {

        if (!valid) {
            validationErrors.push(elem.name);
        }

    });

    console.log("### Log erros");
    console.dir(validationErrors);
}



// Set maskmoney on change input value
var originalVal = $.fn.val;
$.fn.val = function (value) {
    if (typeof value == 'undefined') {
        return originalVal.call(this);
    } else {
        setTimeout(function () {
            this.trigger('mask.maskMoney');
        }.bind(this), 100);
        return originalVal.call(this, value);
    }
};
//////