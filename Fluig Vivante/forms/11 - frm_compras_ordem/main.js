var selectedCentroCusto = {};
var selectedacLocalEstoque = {};
var selectedacProduto = {};
var selectedacContrato = {};
var selectedacEmpresa = {};
var selectacUnidade = {};
var selectedFornecedor = {};

var ativ_tratamentoErro = 121;

var SEQ_PF_ITENS = '';

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



            $("select option:contains(Contrato)").attr("disabled", "disabled")


        }

    }).trigger("change");

    totalizaTodosItens();

    atualizaStatus();


    $("#navegador").val(FLUIGC.utilities.checkBrowser().name)


});

$(document).on("click", "[data-rateio]", function (event) {
    event.preventDefault();

    SEQ_PF_ITENS = $(this).parent().parent().next().find("input[id^='tblIt_uid']").attr("id").split("___")[1];

    //limparItensTabela("tblItem");
    //limparItensTabela("tblRateio");

    $("#upload").val("");
    $("#xlx_json").val("");
    $("#upload").trigger('click');

    document.getElementById('upload').addEventListener('change', handleFileSelect, false);

})

$(document).on("click", "[data-btn-detalhe-item]", function (evt) {

    evt.preventDefault();

    //console.log($(this).attr("name").split("___")[1]);
    //console.log($(this));

    var id = $(this).closest("tr").find("input[name^=seq]").attr("name").split("___")[1];
    var produto_codigo = $("#produto_codigo___" + id).val();
    var produto_descricao = $("#produto_nome___" + id).val();
    var ccusto_codigo_item = $("#ccusto_codigo_item___" + id).val();
    var ccusto_nome_item = $("#ccusto_nome_item___" + id).val();
    var produto_familia = $("#itemfamily___" + id).val();
    var produto_itemcontrl = $("#itemcontrl___" + id).val();
    var produto_codtborcamento = $("#produto_codtborcamento___" + id).val();
    var budget_saldo = $("#budget_saldo___" + id).val();


    var htmltitulomodal = "<h5>" + produto_codigo + " - " + produto_descricao + "</h5>"




    var htmlmodal = `     <div class="alert alert-info"><h5><strong>${produto_codigo} - ${produto_descricao}</strong></h5></div>

    <div class="form-group col-md-12">
    <label>Centro de Custo</label>
<div class="input-group">
<span class="input-group-addon">
    <input type="text" id="ccusto_codigo_itemModal" name="ccusto_codigo_itemModal" size="18" value="${ccusto_codigo_item}" class="fs-no-style-input" placeholder="">
</span>
<input type="text" class="form-control" name="ccusto_nome_itemModal" id="ccusto_nome_itemModal" value="${ccusto_nome_item}" placeholder="Digite para iniciar a pesquisa" data-validation="required" data-validation-error-msg="É necessário informar o centro de custo." //>
<span class="input-group-btn">
    <button data-btn-zoom-autocomplete="acCentroCusto_itemModal" class="btn btn-default" type="button" style="height: 34px;">
        <span class="fluigicon fluigicon-zoom-in fluigicon-xs"></span>
</button>
</span>
</div>

    </div>
  
    <div class="form-group col-md-3">
            <label>Saldo Estoque</label>
            <input data-mask-value type="text" class="form-control" readonly>
    </div>
    <div class="form-group col-md-3">
            <label>Estoque Mínimo</label>
            <input data-mask-value type="text" class="form-control" readonly>
    </div>
    <div class="form-group col-md-3">
            <label>Estoque Máximo</label>
            <input data-mask-value type="text" class="form-control" readonly>
    </div>
    <div class="form-group col-md-3">
            <label>Ponto de Pedido</label>
            <input data-mask-value type="text" class="form-control" readonly>
    </div>
    <div class="form-group col-md-6">
            <label>Família</label>
            <input type="text" class="form-control" value="${produto_familia}" readonly>
    </div>
    <div class="form-group col-md-6">
         <label>Controle - Síndico</label>
         <input type="text" class="form-control" value="${produto_itemcontrl}"readonly>
    </div>
    <div class="form-group col-md-9">
         <label>Natureza Orçamentária</label>
         <input type="text" class="form-control" value="${produto_codtborcamento}"readonly>
    </div>
    <div class="form-group col-md-3">
         <label>Saldo Orçamento</label>
         <input type="text" id="modal_budget_saldo" name="modal_budget_saldo" data-mask-money class="form-control" value="${budget_saldo}" readonly>
    </div>
    `

    var modal_detalhe_item = FLUIGC.modal({
        title: "Detalhe do Item",
        content: htmlmodal,
        id: 'fluig-modal',
        size: "large",
        actions: [{
            'label': 'Ok',
            'bind': 'data-open-modal',
        }, {
            'label': 'Fechar',
            'autoClose': true
        }]
    }, function (err, data) {
        if (err) {

        } else {

        }
    });


    $('[data-open-modal]').click(function () {
        //console.log("ClickOk");

        $("#ccusto_codigo_item___" + id).val($("#ccusto_codigo_itemModal").val());
        $("#ccusto_nome_item___" + id).val($("#ccusto_nome_itemModal").val());


        setOrcamento(id, getOrcamento($("#ccusto_codigo_itemModal").val(), id));

        modal_detalhe_item.remove();
        $("#fluig-modal").hide();


    })




    var acCentroCustoItem = FLUIGC.autocomplete('#ccusto_nome_itemModal', {
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

    acCentroCustoItem.on("fluig.autocomplete.selected", function (event) {

        selectedCentroCusto = event.item;
        $("#ccusto_codigo_itemModal").val(selectedCentroCusto.CODCCUSTO);

        console.log("Mudou C.Custo no item id " + id);

        var budget = getOrcamento(selectedCentroCusto.CODCCUSTO, id);

        if (budget.length > 0) {

            $("#modal_budget_saldo").val(budget[0].VALORSALDO);
        } else {
            $("#modal_budget_saldo").val(0);
        }

        initMask();

    });

    acCentroCustoItem.on("fluig.autocomplete.opened", function (event) {
        //resetCentroCusto();
        selectedCentroCusto = {};
        $("#ccusto_codigo_itemModal").val("");


    });

    acCentroCustoItem.on("fluig.autocomplete.closed", function (event) {

        var value = $("#ccusto_codigo_itemModal").val();
        if (!value) {
            // resetCentroCusto();
        }


    });

    $("[data-btn-zoom-autocomplete]").click(function () {


        var target = $(this).data("btn-zoom-autocomplete");
        ////console.log(target);

        if (target == "acCentroCusto_itemModal") {
            acCentroCustoItem.val("%");
            $("#ccusto_nome_itemModal").focus();
            acCentroCustoItem.open();
        }

    });


});


function tipoContrato() {

    $("#div_adicionaProduto").hide();

    $("input[name^='produto_preco']").each(function () {
        $(this).attr("readonly", true);
    });

    $("#tipo_ordem").attr("readonly", true);

    $("[data-fieldset-contrato]").each(function (index, value) {
        //$(this).attr("disabled", true);
    })
    
    $("[data-fieldset-contrato] input").each(function (index, value) {
    	$(this).attr("readonly", true);
    });
    
    acEmpresa.destroy();
    acUnidade.destroy();
    acContrato.destroy();
    acCentroCusto.destroy();
    acLocalEstoque.destroy();
    acFornecedor.destroy();

    $("[data-btn-zoom-autocomplete]").each(function () {

        $(this).hide();
        

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

$(document).on("change", "input[name^='produto_preco'],input[name^='produto_quantidade'],input[name^='produto_percent_ipi_iss']", function () {


    var id = $(this).attr("name").split("___")[1];
    totalizaItem(id)

});


$(document).on("change", "input[name^='valor_frete']", function () {


    totalizaOrdem();

});


$("#btnIdentarXml").click(function (event) {

    event.preventDefault();

    var xml = $("#integracao_xml").val();

    $("#integracao_xml").val(vkbeautify.xml(xml));

})

function addItemTable(produto, quantidade) {

    var id = wdkAddChild('tblItensOrdem');
    
    $("#tblIt_uid___" + id).val(FLUIGC.utilities.randomUUID());

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
    $('#produto_codtborcamento___' + id).val(item.CODTBORCAMENTO);


    if (item.CODTBORCAMENTO != "") {

        var budget = getOrcamento($("#ccusto_codigo").val(), id);

        setOrcamento(id, budget)
    }



    limpaProdutoAdd();
    refreshSequenceItems();

    MaskEvent.init();
    initMask();
    loadValidation();
    setTimeout(validateAll, 1000);
}



function totalizaOrdem() {

    var totalItens = 0;
    var totalImpostos = 0;
    var valorFrete = convertStringFloat($("#valor_frete").val()) || 0;

    $("input[name^='produto_valorTotal___'").each(function () {

        var id = $(this).attr("name").split("___")[1];

        var imposto = convertStringFloat($("#produto_valor_ipi_iss___"+id).val()) || 0;
        totalItens += convertStringFloat($(this).val()) - imposto;
        
        totalImpostos += imposto;

    });

    var totalBruto = totalItens + valorFrete + totalImpostos;
    
    $("#valor_total_liquido").val(totalItens.toFixed(4).toString().replace(".", ","));
    $("#valor_total").val(totalBruto.toFixed(4).toString().replace(".", ","));


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
    var percent_imposto = convertStringFloat($("#produto_percent_ipi_iss___" + id).val());
        percent_imposto ? percent_imposto = percent_imposto / 100 : percent_imposto=0;

    var valor_imposto = ((preco * quantidade) * percent_imposto);
    var total_item = (preco * quantidade) + valor_imposto;

   

    $("#produto_valor_ipi_iss___" + id).val("R$ " + valor_imposto.toFixed(2).toString().replace(".", ","));
    $("#produto_valorTotal___" + id).val("R$ " + total_item.toFixed(4).toString().replace(".", ","));

    totalizaOrdem();

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

    //console.log(produto);

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
    totalizaOrdem();
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
            if (source == "centroCustoRateio")
                matches = buscarCentroCustoRateio(q)
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
    //console.log("Buscar Empresa");

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

    var usuario = $("#codusuario_rm").val();
    //Busca Unidades do Usuário
    var c1 = DatasetFactory.createConstraint("CODUSUARIO", usuario, usuario, ConstraintType.MUST);
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
    var c1 = DatasetFactory.createConstraint("CODCOLIGADA", $("#empresa_codigo").val(), $("#empresa_codigo").val(), ConstraintType.MUST, true);
    var c2 = DatasetFactory.createConstraint("CODUNI", "%" + $("#ccusto_codigo").val().substring(8, 12) + "%", "%" + $("#ccusto_codigo").val().substring(8, 12) + "%", ConstraintType.MUST, true);
    var c3 = DatasetFactory.createConstraint("CODLOC", "%" + parametro + "%", "%" + parametro + "%", ConstraintType.SHOULD, true);
    var c4 = DatasetFactory.createConstraint("NOME", "%" + parametro + "%", "%" + parametro + "%", ConstraintType.SHOULD, true);
    var c5 = DatasetFactory.createConstraint("FILIAL_VIVANTE", "%" + parametro + "%", "%" + parametro + "%", ConstraintType.SHOULD, true);


    var constraints = new Array(c0, c1, c2, c3, c4, c5);

    var dataset = DatasetFactory.getDataset("rm_consulta_locais_de_estoque_ws", null, constraints, null);

    if (dataset) {
        returnList = dataset.values;
    }

    return returnList;
}


function buscarCentroCusto(parametro) {

    //console.log("## Buscar Centro de Custo ")

    var returnList = [];
    var constraints = new Array();

    var codusuario = $("#codusuario_rm").val();
    var coligada = $("#empresa_codigo").val();

    //console.log("## Buscar Centro de Custo COLIGADA " + coligada);
    //console.log("## Buscar Centro de Custo USUARIO " + codusuario);
    //console.log("## Buscar Centro de Custo UNIDADE " + $("#unidade_codigo").val());
    //console.log("## Buscar Centro de Custo PARAMETRO_" + parametro);

    constraints.push(DatasetFactory.createConstraint("sqlLimit", "100", "100", ConstraintType.MUST));
    constraints.push(DatasetFactory.createConstraint("CODUSUARIO", codusuario, codusuario, ConstraintType.MUST));
    constraints.push(DatasetFactory.createConstraint("CODCOLIGADA", coligada, coligada, ConstraintType.MUST, true));
    constraints.push(DatasetFactory.createConstraint("CODCCUSTO", "%" + parametro + "%", "%" + parametro + "%", ConstraintType.SHOULD, true));
    constraints.push(DatasetFactory.createConstraint("NOME_CCUSTO", "%" + parametro + "%", "%" + parametro + "%", ConstraintType.SHOULD, true));
    constraints.push(DatasetFactory.createConstraint("COD_UNIDADE", $("#unidade_codigo").val(), $("#unidade_codigo").val(), ConstraintType.MUST));

    var dataset = DatasetFactory.getDataset("rm_consulta_centro_custo_usuario", null, constraints, null);

    //console.log("## Buscar Centro de Custo CONSTRAINTS ");
    console.table(constraints);

    if (dataset) {
        returnList = dataset.values;
        //  console.table(returnList)
    }

    return returnList;
}

function buscarCentroCustoRateio(parametro) {

    //console.log("## Buscar Centro de Custo ")

    var returnList = [];
    var constraints = new Array();

    var codusuario = $("#codusuario_rm").val();
    var coligada = $("#empresa_codigo").val();

    //console.log("## Buscar Centro de Custo COLIGADA " + coligada);
    //console.log("## Buscar Centro de Custo USUARIO " + codusuario);
    //console.log("## Buscar Centro de Custo UNIDADE " + $("#unidade_codigo").val());
    //console.log("## Buscar Centro de Custo PARAMETRO_" + parametro);

    constraints.push(DatasetFactory.createConstraint("sqlLimit", "100", "100", ConstraintType.MUST));
    constraints.push(DatasetFactory.createConstraint("CODUSUARIO", codusuario, codusuario, ConstraintType.MUST));
    constraints.push(DatasetFactory.createConstraint("CODCOLIGADA", coligada, coligada, ConstraintType.MUST, true));
    constraints.push(DatasetFactory.createConstraint("CODCCUSTO", "%" + parametro + "%", "%" + parametro + "%", ConstraintType.SHOULD, true));
    constraints.push(DatasetFactory.createConstraint("NOME_CCUSTO", "%" + parametro + "%", "%" + parametro + "%", ConstraintType.SHOULD, true));
    //constraints.push(DatasetFactory.createConstraint("COD_UNIDADE", $("#unidade_codigo").val(), $("#unidade_codigo").val(), ConstraintType.MUST));

    var dataset = DatasetFactory.getDataset("rm_consulta_centro_custo_usuario", null, constraints, null);

    //console.log("## Buscar Centro de Custo CONSTRAINTS ");
    console.table(constraints);

    if (dataset) {
        returnList = dataset.values;
        //  console.table(returnList)
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
//function getOrcamento(coligada, ccusto, naturezaOrcamentaria){
function getOrcamento(ccusto, id) {


    var coligada = $("#empresa_codigo").val();
    //var ccusto = $('#ccusto_codigo_item___' + id).val();
    var naturezaOrcamentaria = $('#produto_codtborcamento___' + id).val();


    var returnList = [];

    var dataEmissao = $("#ordem_data").val().split("/");


    var c0 = DatasetFactory.createConstraint("CODCOLIGADA", coligada.toString(), coligada.toString(), ConstraintType.MUST);
    var c1 = DatasetFactory.createConstraint("CODCCUSTO", ccusto, ccusto, ConstraintType.MUST);
    var c2 = DatasetFactory.createConstraint("CODTBORCAMENTO", naturezaOrcamentaria, naturezaOrcamentaria, ConstraintType.MUST);
    var c3 = DatasetFactory.createConstraint("MES", dataEmissao[1], dataEmissao[1], ConstraintType.MUST);
    var c4 = DatasetFactory.createConstraint("ANO", dataEmissao[2], dataEmissao[2], ConstraintType.MUST);

    //console.log(">>> Consulta orçamento")

    var constraints = new Array(c0, c1, c2, c3, c4);

    //console.log(">>> Consulta orçamento constraints");
    //console.log(constraints);


    var dataset = DatasetFactory.getDataset("rm_consulta_orcamento", null, constraints, null);

    if (dataset) {
        returnList = dataset.values;
    }

    //console.log(">>> Consulta orçamento retorno");
    //console.log(returnList);

    return returnList;

}

function setOrcamento(id, budget) {

    if (budget.length > 0) {
        $('#budget_previsto___' + id).val(budget[0].VALORORCADO);
        $('#budget_alocado___' + id).val(budget[0].VALOROPCIONAL1);
        $('#budget_saldo___' + id).val(budget[0].VALORSALDO);
        $('#budget_excedido___' + id).val(budget[0].VALOREXCEDENTE);

    } else {
        $('#budget_previsto___' + id).val("");
        $('#budget_alocado___' + id).val("");
        $('#budget_saldo___' + id).val("");
        $('#budget_excedido___' + id).val("");

    }
    initMask();
}

function buscarProduto(parametro) {

    var returnList = [];

    var codcoligada = $("#empresa_codigo").val();

    var c0 = DatasetFactory.createConstraint("sqlLimit", "50", "50", ConstraintType.MUST);
    var c1 = DatasetFactory.createConstraint("CODCOLIGADA", codcoligada, codcoligada, ConstraintType.MUST);
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
            defaultZero: true,
            precision: 4
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
            //console.log('Input ' + $el.attr('name') + ' is ' + (valid ? 'VALID' : 'NOT VALID'));
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

    //console.log("### Log erros");
    console.dir(validationErrors);
}

function makeid() {
	var text = "";
	var possible = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";

	for (var i = 0; i < 5; i++)
		text += possible.charAt(Math.floor(Math.random() * possible.length));

	return text;
}

function adicionarRateio(idTblDesp, codreduzido, valor, percentual) {
	console.log("adicionarRateio");
    //Adicionar linha na tabela de rateio
    var id = wdkAddChild("tblRateio");

    //busca UID da despesa
    var uid = $("#tblIt_uid___" + idTblDesp).val();

    //busca informações adicionais do c.ccusto pelo codigo reduzido

    //var ccusto = buscaCCustoPeloCodigoReduzido($("#coligada_codigo").val(), codreduzido);
    var ccusto = buscarCcustoPorCodigo(codreduzido);

    console.log("ccusto");
    console.log(ccusto);

    //preenche linha da tabela de rateio

    $("#tblRat_tblIt_uid___" + id).val(uid);
    $("#tblRat_ccusto_codigo___" + id).val(ccusto[0].CODCCUSTO);
    $("#tblRat_ccusto___" + id).val(codreduzido);
    $("#tblRat_ccusto_nome___" + id).val(ccusto[0].NOME_CCUSTO);
    $("#tblRat_valor___" + id).val(valor);
    $("#tblRat_percent___" + id).val(percentual);

    return id;
}

function buscarProdutoPorCodigo(codigo) {
	var returnList = [];

	var codcoligada = $("#empresa_codigo").val();

	var constraints = new Array();
	constraints.push(DatasetFactory.createConstraint("CODIGOPRD",codigo,codigo, ConstraintType.MUST));
	constraints.push(DatasetFactory.createConstraint("CODCOLIGADA",codcoligada,codcoligada, ConstraintType.MUST));

	var dataset = DatasetFactory.getDataset("rm_consulta_produto_ws", null, constraints, null);

	if (dataset) {
		returnList = dataset.values;
	}

	return returnList;
}

function buscarCcustoPorCodigo(codigo) {
    var returnList = [];

    var codusuario  = $("#codusuario_rm").val();
    var codcoligada = $("#empresa_codigo").val();

    var constraints = new Array();
    constraints.push(DatasetFactory.createConstraint("CODUSUARIO", codusuario, codusuario, ConstraintType.MUST));
    constraints.push(DatasetFactory.createConstraint("CODCCUSTO", codigo, codigo, ConstraintType.MUST));
    constraints.push(DatasetFactory.createConstraint("CODCOLIGADA", codcoligada, codcoligada, ConstraintType.MUST));

    var dataset = DatasetFactory.getDataset("rm_consulta_centro_custo_usuario", null, constraints, null);

    if (dataset) {
        returnList = dataset.values;
    }

    return returnList;
}

function buscarFornecedorPorCodigo(codigo){
    var returnList = [];

    var c1 = DatasetFactory.createConstraint("CODCFO",  codigo ,  codigo , ConstraintType.MUST);
    var constraints = new Array(c1);

    var dataset = DatasetFactory.getDataset("rm_consulta_cliente_fornecedor", null, constraints, null);
    if (dataset) {
        returnList = dataset.values;
    }
    
    return returnList;
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