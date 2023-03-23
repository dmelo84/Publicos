var validationErrors = [];
var datablePrecosCotados = {};

$(document).ready(function () {


    FLUIGC.calendar('#data_limite_group', {
    
         language: 'pt-br',
         minData: $("#data_cotacao").val()
 
     });


    

    init();
    checkNegociation();

    $("#data_limite").change(function (e, v) {

        console.log(moment($(this).val(), "YYYY-MM-DD").fromNow());

    })

    if (WKNumState == 23) {
        $("#header_cotacao").hide();
        $("#divIdentificacaoCotacao").hide();
        $("#divItensCotacao").hide();
        $("#divFornecedoresCotacao").hide();
        $("#divEscolhaFornecedores").show();
        $("#aprovacaoEscolhaFornecedor_quadro").html(getTemplateQuadro());
    }

    MontaViewPorLocalEstoque();

})

$(document).on("change", "#attachmentsTable", function () {

    console.log("Mudou Tabela >>>>");
    console.log($(this));

})

$(document).on("click", "[data-btn-anexar-cotacao]", function (event) {

    var id = $(this).attr("name").split("___")[1];
    var keycfo = $("#forn_key___" + id).val();

    showCamera();

})

$(document).on("change", "[data-tipo-cotacao]", function () {

    console.log("RADIO")


    var id = $(this).attr("name").split("___")[1];
    var tipo = $(this)[0].value;

    if (tipo == "web") {
        EditaFornecedor(id, false);
    } else {
        EditaFornecedor(id, true);
    }


})

$("[data-btn-selecao-solicitacao]").click(function (event) {

    event.preventDefault();

    var modalSolicitacoes = FLUIGC.modal({
        title: 'Pesquisa Solicitações Pendentes',
        content: '<div id="lookupSolicitacoes"></div>',
        id: 'fluig-modal',
        size: 'full', //'full | large | small'
        actions: [{
            'label': 'Ok',
            'bind': 'data-open-modal',
        }, {
            'label': 'Fechar',
            'autoClose': true
        }]
    }, function (err, data) {
        if (err) {
            // do error handling
        } else {
            // do something with data
        }
    });

    $(".modal-body").css("max-height", "600");

    $(document).on("click", "[data-open-modal]", function (e) {

        var index = datatableSolicitacoes.selectedRows();

        for (let i = 0; i < index.length; i++) {

            var selected = datatableSolicitacoes.getRow(index[i]);
            console.log(selected)


            if (!checkItemExist(selected.numero_solicitacao, selected.item_seq)) {

                addItemCotacao(selected);

            } else {
                FLUIGC.toast({
                    message: 'O item ' + selected.produto_descricao + ' já consta na lista.',
                    type: 'warning'
                });

            }
        }

        datatableSolicitacoes.destroy();
        modalSolicitacoes.remove();



    });


    var mydata = buscarSolicitacoes();

    var datatableSolicitacoes = FLUIGC.datatable('#lookupSolicitacoes', {
        dataRequest: mydata,
        root: '',
        limit: 10,
        renderContent: ['numero_solicitacao', 'data_solicitacao', 'produto_codigo', 'produto_descricao', 'produto_quantidade'],
        header: [{
            'title': 'Solicitação'
        },
        {
            'title': 'Data'
        },
        {
            'title': 'Cód. Item'
        },
        {
            'title': 'Descrição'
        },
        {
            'title': 'Quantidade'
        }
        ],
        search: {
            enabled: true,
            onSearch: function (response) {
                console.log("Pesquisou " + response);
            },
            onlyEnterkey: true,
            searchAreaStyle: 'col-md-3'
        },
        multiSelect: true,
        classSelected: 'info',
        navButtons: {
            enabled: false,
            forwardstyle: 'btn-warning',
            backwardstyle: 'btn-warning',
        },
        actions: {
            enabled: true,
            template: '.my_template_area_actions',
            actionAreaStyle: 'col-md-9'
        },
        emptyMessage: '<div class="text-center">Não foram encontradas solicitações pendentes.</div>',
        tableStyle: 'table-striped',
        scroll: {
            target: '#lookupSolicitacoes',
            enabled: true
        }

    }, function (err, data) {
        // DO SOMETHING (error or success)
    });


})

$("[data-btn-open-quadro]").click(function (event) {
    event.preventDefault();
    openModalQuadro();
})

$(document).on("change", "[ data-status-item-cotacao]", function () {

    var id = $(this).attr("name").split("_")[1];
    var status = $(this).val();

    if (status != "cotado") {


        calculaTotaisDigitacao();
    }


})

$(document).on("change", "[data-cotacao-preco],[data-cotacao-ipi],[data-cotacao-desconto],[data-cotacao-icms]", function (element) {

    var id = $(this).attr("name").split("_")[1];
    var preco = convertStringFloat($("#preco_" + id).val()) || 0;

    if (preco > 0) {

        $("#status_" + id).val("cotado");

    } else {

        $("#status_" + id).val("nao_cotado");

    }

    calculaTotaisDigitacao();

});

$(document).on("change", "input[name^='cotacao_valor_frete___']", function (element) {

    calculaTotaisTodosFornecedores();
});

$(document).on("change", "input[name^='cotacao_tem_frete___']", function (element) {

    checkFrete();
});

$(document).on("change", "[data-campo-local-entrega]", function () {



    let id = $(this).attr("data-campo-local-entrega")
    let campoAlterado = $(this).attr("name");
    let value = $(this).val()

    if (campoAlterado.startsWith('cotacao_valor_frete'))
        $("#local_valor_frete___" + id).val(value)

    if (campoAlterado.startsWith('cotacao_previsao_entrega'))
        $("#local_dataentrega___" + id).val(value)

    if (campoAlterado.startsWith('cotacao_cond_pgto'))
        $("#local_condpgto___" + id).val(value)

    if (campoAlterado.startsWith('cotacao_tem_frete'))
        $("#local_tem_frete___" + id).val(value)



})


function showCamera(parameter) {

    //  parameter = "ok "+=parameter;


    console.log("JSInterface")
    console.log(JSInterface)
    JSInterface.showCamera(parameter);

}

function checkNegociation() {

    const NegotiationExists = $.inArray("67", StatesHistory.split(","));

    if (NegotiationExists > -1) {

        updateTabLink();
        changeRegisterPriceMode();

    } else {

        $("[data-nav-tab-inicial]").hide();

    }

}

function changeRegisterPriceMode() {

    $("[data-cotacao-header]").text("");
    $("[data-cotacao-capa]").removeClass();
    $("[data-cotacao-capa]").toggleClass("alert alert-warning");


    $("[data-nav-tab-atual]").html("<span class='fluigicon fluigicon-user-transfer fluigicon-sm'></span> Negociação");
    $("[data-nav-tab-inicial]").html("<span class='fluigicon fluigicon-user-cost fluigicon-sm'></span> Cotação")






}

function EditaFornecedor(id, trueFalse) {

    let td = $("#forn_nome___" + id).closest("td")

    $(td).find("input[name^='cotacao_previsao_entrega___']").prop("readonly", !trueFalse);
    $(td).find("input[name^='cotacao_tem_frete___']").prop("readonly", !trueFalse);
    $(td).find("input[name^='cotacao_valor_frete___']").prop("readonly", !trueFalse);
    $(td).find("input[name^='cotacao_cond_pgto___']").prop("readonly", !trueFalse);   
    $(td).find("input[name^='btn_forn_anexar___']").prop("readonly", !trueFalse);
 
    if (!trueFalse) {
        limpaCotacaoFornecedor(id);
    }

}

function limpaCotacaoFornecedor(id) {

    let td = $("#forn_nome___" + id).closest("td")

    $(td).find("input[name^='cotacao_previsao_entrega___']").val("")
    $(td).find("input[name^='cotacao_tem_frete___']").val("")
    $(td).find("input[name^='cotacao_valor_frete___']").val("")
    $(td).find("input[name^='cotacao_cond_pgto___']").val("")
    $(td).find("input[name^='cotacao_total_itens___']").val("")
    $(td).find("input[name^='cotacao_total_cotacao___']").val("")




    var key = $("#forn_key___" + id).val();

    $('#tblItensCotacaoFornecedor tbody tr').not(':first').each(
        function (count, tr) {
            var keycfo_item = $(tr).find("input[name^='cotacao_key__']").val();
            var id = $(tr).find("input[name^='cotacao_key__']").attr("name").split("___")[1];

            if (key == keycfo_item) {
                $("#cotacao_preco___" + id).val("");
                $("#cotacao_produto_ipi___" + id).val("");
                $("#cotacao_icmsst___" + id).val("");
                $("#cotacao_desconto___" + id).val("");
                $("#cotacao_total_item___" + id).val("");
                $("#cotacao_status_item___" + id).val("nao_cotado");


            }

        });



}

function checkTipoProduto(tipo){

    var retorno = true;

    $("input[name^=produto_tipo___").each(function(){

        var tipoItem = $(this).val();

        if(tipo != tipoItem && tipoItem != ""){

            retorno=false;
        }

    })

    return retorno;

}

function addFornecedor() {

    console.log("addFornecedor");
    console.log(selectedFornecedor);

    if(!$.isEmptyObject(selectedFornecedor)){
    if (!checkFornecedorExist(selectedFornecedor.CODCFO)) {

        var id = wdkAddChild('tblFornecedor');


            $("#forn_codcfo___" + id).val(selectedFornecedor.CODCFO);
            $("#forn_nome___" + id).val(selectedFornecedor.NOMEFANTASIA);
            $("#forn_razaosocial___" + id).val(selectedFornecedor.NOME);
            $("#forn_cnpj___" + id).val(selectedFornecedor.CGCCFO);
            $("#forn_telefone___" + id).val(selectedFornecedor.TELEFONE);
            $("#forn_contato___" + id).val(selectedFornecedor.CONTATO);
            $("#forn_email___" + id).val(selectedFornecedor.EMAIL);
            selectedFornecedor["KEY"] = makeid();
            $("#forn_key___" + id).val(selectedFornecedor.KEY);

            var regex = /^([a-zA-Z0-9_.+-])+\@(([a-zA-Z0-9-])+\.)+([a-zA-Z0-9]{2,4})+$/;

            if (!regex.test($.trim(selectedFornecedor.EMAIL))) {

                $("#cotacao_tipo_cotacao___"+id+" option[value='web']").attr('disabled', true);

                $("#cotacao_tipo_cotacao___" + id).val("manual")

                /*$("input[name='cotacao_tipo_cotacao___" + id + "']").each(function () {
                    $(this).closest("label").attr("disabled", true);
                })*/
            };


            //Adiciona os itens cotados para o fornecedor
            addItensCotacaoFornecedor(selectedFornecedor);

            //Adiciona Locais de Entrega/Fornecedor
            addLocalCotacaoFornecedor(selectedFornecedor);

            MontaViewPorLocalEstoque();

            //Necessita ficar sempre no final da function
            initMask();
            resetFornecedor();
            refreshSequenceForn();
            checkFrete();
            updateTabLink();

            

            FLUIGC.toast({
                message: 'Fornecedor adicionado com sucesso!',
                type: 'success'
            });



        } else {

            FLUIGC.toast({
                message: 'O fornecedor já consta na lista.',
                type: 'warning'
            });

        }}

        selectedFornecedor = {};
   
}

function checkFornecedorExist(codcfo) {

    console.log("checkFornecedorExist");

    var flag = false;

    if (codcfo) {
        $("input[name^='forn_codcfo___']").each(function () {

            $(this).val() == codcfo ? flag = true : flag = false;

        });
    }
    return flag;
}

function addItemCotacao(item) {

    var id ="";


    if (checkTipoProduto(item.produto_tipo)) {

        id = wdkAddChild('tblItem');

        $("#sol_unidade___" + id).val(item.unidade_codigo);
        $("#sol_unidade_nome___" + id).val(item.unidade_nome);

        $("#solicitacao_numero___" + id).val(item.numero_solicitacao);
        $("#solicitacao_data___" + id).val(item.data_solicitacao);
        $("#produto_codigo___" + id).val(item.produto_codigo);
        $("#produto_descricao___" + id).val(item.produto_descricao);
        $("#produto_quantidade___" + id).val(item.produto_quantidade);
        $("#solicitacao_item_seq___" + id).val(item.item_seq);
        $("#solicitacao_documentid___" + id).val(item.documentid);
        $("#solicitacao_local_estoque___" + id).val(item.local_estoque_codigo);


        $("#produto_itemfamily___" + id).val(item.itemfamily);
        $("#produto_itemcontrl___" + id).val(item.itemcontrl);
        $("#produto_tipo___" + id).val(item.produto_tipo);
        $("#produto_codtb2fat___" + id).val(item.produto_codtb2fat);
        $("#produto_codtborcamento___" + id).val(item.produto_codtborcamento);


        $("#ccusto_codigo___" + id).val(item.ccusto_codigo_item);
        $("#ccusto_nome___" + id).val(item.ccusto_nome_item);
        $("#produto_idprd___" + id).val(item.produto_id);

        $("#entrega_endereco___" + id).val(item.entrega_endereco);
        $("#entrega_cidade___" + id).val(item.entrega_cidade);
        $("#entrega_uf___" + id).val(item.entrega_uf);
        $("#entrega_filial___" + id).val(item.entrega_filial);
        $("#entrega_local_nome___" + id).val(item.unidade_nome);
        $("#produto_observacoes___" + id).val(item.produto_observacoes);




        var c0 = DatasetFactory.createConstraint("solicitacao_item_seq", item.item_seq, item.item_seq, ConstraintType.MUST);
        var c1 = DatasetFactory.createConstraint("solicitacao_documentid", item.documentid, item.documentid, ConstraintType.MUST);
        var c2 = DatasetFactory.createConstraint("operacao", "add", "add", ConstraintType.MUST);
        var c3 = DatasetFactory.createConstraint("numero_cotacao", WKNumProces, WKNumProces, ConstraintType.MUST);
        var c4 = DatasetFactory.createConstraint("login", $("#codusuario_solicitante").val(), $("#codusuario_solicitante").val(), ConstraintType.MUST);

        var constraints = new Array(c0, c1, c2, c3, c4);

        //Comentado para teste
        //Faz a atualização do documento
        var dataset = DatasetFactory.getDataset("updatePurchaseRequest", null, constraints, null);



        refreshSequenceItem();

        //Adiciona item nos fornecedores que já estão participando do processo de cotação
        $("input[name^='forn_codcfo___']").each(function () {

            let idCfo = $(this).attr("name").split("___")[1];
            
            let fornecedor    = {};
            fornecedor.CODCFO = $(this).val();
            fornecedor.NOME = $("#forn_nome___" + idCfo).val()
            fornecedor.KEY = $("#forn_key___" + idCfo).val()



            var idItemCot = wdkAddChild('tblItensCotacaoFornecedor');

            setValoresItemCotacaoFornecedor(idItemCot, item, fornecedor)

            addLocalCotacaoFornecedor(fornecedor)


        })

        //


    } else {


        FLUIGC.message.alert({
            message: 'Não é possível cotar itens do tipo "Produto" e "Serviço" no mesmo processo. \n' +
                'O item <strong>' + item.produto_descricao + '</strong> não foi adicionado.',
            title: 'Cotação',
            label: 'OK'
        }, function (el, ev) {
            //Callback action executed by the user...

            //el: Element (button) clicked...
            //ev: Event triggered...

            // this.someFunc();
        });






    }

}

function addItensCotacaoFornecedor(selectedFornecedor) {

    var itens = getItensCotacao();

    for (var i = 0; i < itens.length; i++) {

        const obj = itens[i];

        var id = wdkAddChild('tblItensCotacaoFornecedor');

        setValoresItemCotacaoFornecedor(id, obj, selectedFornecedor)
        


    }
    
    initMask();

}

function itemObjeto(trTable) {


    var item = {};


    item.item_seq = $(trTable).find("input[name^='item_seq___']").val();
    item.numero_solicitacao = $(trTable).find("input[name^='solicitacao_numero___']").val();
    item.solicitacao_data = $(trTable).find("input[name^='solicitacao_data___']").val();
    item.unidade_codigo = $(trTable).find("input[name^='sol_unidade___']").val();
    item.unidade_nome = $(trTable).find("input[name^='sol_unidade_nome___']").val();
    item.produto_quantidade = $(trTable).find("input[name^='produto_quantidade___']").val();
    item.produto_codigo = $(trTable).find("input[name^='produto_codigo___']").val();
    item.produto_descricao = $(trTable).find("input[name^='produto_descricao___']").val();
    item.solicitacao_item_seq = $(trTable).find("input[name^='solicitacao_item_seq___']").val();
    item.solicitacao_documentid = $(trTable).find("input[name^='solicitacao_documentid___']").val();
    item.itemfamily = $(trTable).find("input[name^='produto_itemfamily___']").val();
    item.itemcontrl = $(trTable).find("input[name^='produto_itemcontrl___']").val();
    item.produto_tipo = $(trTable).find("input[name^='produto_tipo___']").val();
    item.produto_codtb2fat = $(trTable).find("input[name^='produto_codtb2fat___']").val();
    item.codccusto_item = $(trTable).find("input[name^='ccusto_codigo___']").val();
    item.ccusto_nome_item = $(trTable).find("input[name^='ccusto_nome___']").val();
    item.produto_id = $(trTable).find("input[name^='produto_idprd___']").val();
    item.produto_codtborcamento = $(trTable).find("input[name^='produto_codtborcamento___']").val();
    item.local_estoque_codigo = $(trTable).find("input[name^='solicitacao_local_estoque___']").val();
    item.entrega_cidade = $(trTable).find("input[name^='entrega_cidade___']").val();
    item.entrega_uf = $(trTable).find("input[name^='entrega_uf___']").val();
    item.entrega_filial = $(trTable).find("input[name^='entrega_filial___']").val();
    item.entrega_endereco = $(trTable).find("input[name^='entrega_endereco___']").val();
    item.cnpj_filial_vivante = $(trTable).find("input[name^='cnpj_filial_vivante___']").val();
    item.local_estoque_nome = $(trTable).find("input[name^='entrega_local_nome___']").val();
    item.produto_observacoes = $(trTable).find("input[name^='produto_observacoes___']").val();


    return item
}

function setValoresItemCotacaoFornecedor(idItemCotacaoFornecedor, objItem, fornecedor){

    let selectedFornecedor = fornecedor;
    let obj = objItem;
    let id = idItemCotacaoFornecedor;

    $("#cotacao_item_seq___" + id).val(obj.item_seq);
    $("#cotacao_unidade___" + id).val(obj.unidade_codigo);
    $("#cotacao_unidade_nome___" + id).val(obj.unidade_nome);
    $("#cotacao_solicitacao_numero___" + id).val(obj.numero_solicitacao);
    $("#cotacao_codcfo___" + id).val(selectedFornecedor.CODCFO);
    $("#cotacao_forn_nome___" + id).val(selectedFornecedor.NOME);
    $("#cotacao_key___" + id).val(selectedFornecedor.KEY);
    $("#cotacao_produto_codigo___" + id).val(obj.produto_codigo);
    $("#cotacao_produto_descricao___" + id).val(obj.produto_descricao);
    $("#cotacao_produto_quantidade___" + id).val(numeral(obj.produto_quantidade).format('0,0.00'));
    
    $("#cotacao_solicitacao_item_seq___" + id).val(obj.solicitacao_item_seq);
    $("#cotacao_sol_documentid___" + id).val(obj.solicitacao_documentid);

    $("#cotacao_status_item___" + id).val("nao_cotado");
    $("#cotacao_produto_itemfamily___" + id).val(obj.itemfamily);
    $("#cotacao_produto_itemcontrl___" + id).val(obj.itemcontrl);
    $("#cotacao_produto_tipo___" + id).val(obj.produto_tipo);
    $("#cotacao_produto_codtb2fat___" + id).val(obj.produto_codtb2fat);
    $("#cotacao_produto_codtborcamento___" + id).val(obj.produto_codtborcamento);
    $("#cotacao_ccusto_codigo___" + id).val(obj.codccusto_item);
    $("#cotacao_ccusto_nome___" + id).val(obj.ccusto_nome_item);
    $("#cotacao_produto_idprd___" + id).val(obj.produto_id);

    //Informações do endereço de entrega informados na solicitação
    $("#cotacao_cnpj_filial_vivante" + id).val(obj.cnpj_filial_vivante);
    $("#cotacao_entrega_endereco___" + id).val(obj.entrega_endereco);
    $("#cotacao_entrega_cidade___" + id).val(obj.entrega_cidade);
    $("#cotacao_entrega_uf___" + id).val(obj.entrega_uf);
    $("#cotacao_entrega_filial___" + id).val(obj.entrega_filial);
    $("#cotacao_sol_local_estoque___" + id).val(obj.local_estoque_codigo);
    $("#cotacao_entrega_local_nome___" + id).val(obj.local_estoque_nome);
    $("#cotacao_produto_observacoes___" + id).val(obj.produto_observacoes);

    



}

function addLocalCotacaoFornecedor(selectedFornecedor) {


    


    

    $.each(getLocalEstoqueUnico(), function (i, el) {


        //Verificar se já existe local para fornecedor

        let jaRegistrado = false;

        $("input[name^='local_codigo___']").each(function () {

            let id_local = $(this).attr("name").split("___")[1]
            let forn_key_local = $("#local_forn_key___" + id_local).val();
            let local_codigo_local = $("#local_codigo___" + id_local).val();

            if (el.CODIGO == local_codigo_local && selectedFornecedor.KEY == forn_key_local)
                jaRegistrado = true;

        })

        //Se o flag JaRegistrado não for alterado, registra local novo para o fornecedor

        if (!jaRegistrado){
        
            var id = wdkAddChild('tblLocalCotacaoFornecedor');

            $("#local_codigo___" + id).val(el.CODIGO);
            $("#local_forn_key___" + id).val(selectedFornecedor.KEY);
            $("#local_nome___" + id).val(el.NOME);
            $("#local_endereco___" + id).val(el.ENDERECO);
            $("#local_estado___" + id).val(el.UF);
            $("#local_cidade___" + id).val(el.CIDADE);
            $("#local_cep___" + id).val("");
            $("#local_tem_frete___" + id).val("");
            $("#local_valor_frete___" + id).val("");
            $("#local_condpgto___" + id).val("");
            $("#local_dataentrega___" + id).val("");

        }

    })


   

}

function getItensCotacao() {
   
    var itens = [];

    $("table[tablename='tblItem'] tbody tr").not(':first').each(function () {

        var tr = $(this);
        itens.push(itemObjeto(tr))
       
    });

    return itens
   
}

function getItensCotacaoFornecedor(codcfo, origem,localEstoque) {

    var itens = [];

    if (origem == "atual") {

        $("table[tablename='tblItensCotacaoFornecedor'] tbody tr").not(':first').each(function () {

            var tr = $(this);

            var codcfo_cotacao = $(tr).find("input[name^='cotacao_codcfo__']").val();
            var localEstoque_cotacao = $(tr).find("input[name^='cotacao_sol_local_estoque__']").val();
            var seq = $(tr).find("input[name^='cotacao_codcfo__']").attr("name").split("___")[1];

            if (codcfo == codcfo_cotacao && localEstoque_cotacao == localEstoque) {

                var item = {};

                /* $(tr).find('input').each(function(){
                     item[$(this).attr("name").split("___")[0]] = $(this).val();
                     item.cotacao_idPaiFilho = $(this).attr("name").split("___")[1];
                 });*/



                item.idPaiFilho = seq;
                item.unidade = $("#cotacao_unidade___" + seq).val();
                item.unidade_nome = $("#cotacao_unidade_nome___" + seq).val();

                item.ccusto_codigo = $("#cotacao_ccusto_codigo___" + seq).val();
                item.ccusto_nome = $("#cotacao_ccusto_nome___" + seq).val();
                item.childId = $("#cotacao_childId___" + seq).val();
                item.codcfo = $("#cotacao_codcfo___" + seq).val();
                item.forn_nome = $("#cotacao_forn_nome___" + seq).val();
                item.desconto = $("#cotacao_desconto___" + seq).val();
                item.icmsst = $("#cotacao_icmsst___" + seq).val();

                item.item_seq = $("#cotacao_item_seq___" + seq).val();
                item.item_vencedor = $("#cotacao_item_vencedor___" + seq).val();
                item.key = $("#cotacao_key___" + seq).val();
                item.preco = $("#cotacao_preco___" + seq).val();
                item.produto_codigo = $("#cotacao_produto_codigo___" + seq).val();
                item.produto_codtb2fat = $("#cotacao_produto_codtb2fat___" + seq).val();
                item.produto_descricao = $("#cotacao_produto_descricao___" + seq).val();
                item.produto_idprd = $("#cotacao_produto_idprd___" + seq).val();
                item.produto_ipi = $("#cotacao_produto_ipi___" + seq).val();
                item.produto_itemcontrl = $("#cotacao_produto_itemcontrl___" + seq).val();
                item.produto_itemfamily = $("#cotacao_produto_itemfamily___" + seq).val();
                item.produto_quantidade = $("#cotacao_produto_quantidade___" + seq).val();
                item.produto_tipo = $("#cotacao_produto_tipo___" + seq).val();
                item.solicitacao_item_seq = $("#cotacao_solicitacao_item_seq___" + seq).val();
                item.solicitacao_numero = $("#cotacao_solicitacao_numero___" + seq).val();
                item.status_item = $("#cotacao_status_item___" + seq).val();
                item.total_item = $("#cotacao_total_item___" + seq).val();
                item.produto_codtborcamento = $("#cotacao_produto_codtborcamento___" + seq).val();

                item.cotacao_sol_local_estoque = $("#cotacao_sol_local_estoque___" + seq).val();
                


                itens.push(item);
            }

        });

    }

    if (origem == "inicial") {

        $("table[tablename='tblItensCotacaoFornecedorHistorico'] tbody tr").not(':first').each(function () {

            var tr = $(this);

            var codcfo_cotacao = $(tr).find("input[name^='hist_cotacao_codcfo__']").val();
            var seq = $(tr).find("input[name^='hist_cotacao_codcfo__']").attr("name").split("___")[1];

            if (codcfo == codcfo_cotacao) {

                var item = {};

                /* $(tr).find('input').each(function(){
                     item[$(this).attr("name").split("___")[0]] = $(this).val();
                     item.cotacao_idPaiFilho = $(this).attr("name").split("___")[1];
                 });*/



                item.idPaiFilho = seq;
                item.ccusto_codigo = $("#hist_cotacao_ccusto_codigo___" + seq).val();
                item.ccusto_nome = $("#hist_cotacao_ccusto_nome___" + seq).val();
                item.childId = $("#hist_cotacao_childId___" + seq).val();
                item.codcfo = $("#hist_cotacao_codcfo___" + seq).val();
                item.desconto = $("#hist_cotacao_desconto___" + seq).val();
                item.icmsst = $("#hist_cotacao_icmsst___" + seq).val();

                item.unidade = $("#hist_cotacao_unidade___" + seq).val();
                item.unidade_nome = $("#hist_cotacao_unidade_nome___" + seq).val();

                item.item_seq = $("#hist_cotacao_item_seq___" + seq).val();
                item.item_vencedor = $("#cotacao_item_vencedor___" + seq).val();
                item.key = $("#hist_cotacao_key___" + seq).val();
                item.preco = $("#hist_cotacao_preco___" + seq).val();
                item.produto_codigo = $("#hist_cotacao_produto_codigo___" + seq).val();
                item.produto_codtb2fat = $("#hist_cotacao_produto_codtb2fat___" + seq).val();
                item.produto_descricao = $("#hist_cotacao_produto_descricao___" + seq).val();
                item.produto_idprd = $("#hist_cotacao_produto_idprd___" + seq).val();
                item.produto_ipi = $("#hist_cotacao_produto_ipi___" + seq).val();
                item.produto_itemcontrl = $("#hist_cotacao_prod_itemcontrl___" + seq).val();
                item.produto_itemfamily = $("#hist_cotacao_prod_itemfamily___" + seq).val();
                item.produto_quantidade = $("#hist_cotacao_prod_quantidade___" + seq).val();
                item.produto_tipo = $("#hist_cotacao_produto_tipo___" + seq).val();
                item.solicitacao_item_seq = $("#hist_cotacao_solic_item_seq___" + seq).val();
                item.solicitacao_numero = $("#hist_cotacao_solicit_numero___" + seq).val();
                item.status_item = $("#hist_cotacao_status_item___" + seq).val();
                item.total_item = $("#hist_cotacao_status_item___" + seq).val();



                itens.push(item);
            }

        });


    }






    console.log(itens);

    return itens;


}

function checkEnableAddSolicitacao() {


    if ($("#unidade_codigo").val() != "") {
        $('[data-btn-selecao-solicitacao]').attr("disabled", false);
    } else {
        $('[data-btn-selecao-solicitacao]').attr("disabled", true);
    }



}

function checkItemExist(numeroSolicitacao, sequencia) {

    var flag = false;
    $("table[tablename='tblItem'] tbody tr").each(function () {


        var numero = $(this).find("td input[name^='solicitacao_numero__']").val();
        var item_seq = $(this).find("td input[name^='solicitacao_item_seq__']").val();

        if (numero == numeroSolicitacao && item_seq == sequencia) {
            flag = true;
            return flag;
        }

    });

    return flag;
}

function openModalSolicitacoes() {

}

function openModalHistoricoItem(element) {



    var id = $(element).closest("tr").find("input").first().attr("name").split("___")[1]

    var coligada = $("#empresa_codigo").val();
    var codigoproduto = $("#produto_codigo___" + id).val();
    var produtodescricao = $("#produto_descricao___" + id).val();


    var modalHistorico = FLUIGC.modal({
        title: 'Últimas Compras do Item: ' + produtodescricao,
        content: '<div id="DivUltimasCompras" class="col-md-12"><table id="lookupHistorico" class="table table-condensed"></table></div>',
        id: 'fluig-modal',
        size: 'full', //'full | large | small'
        actions: [{
            'label': 'Fechar',
            'autoClose': true
        }]
    }, function (err, data) {
        if (err) {

        } else {




        }
    });

    var disabled = "";
    if (WKNumState != 4 && WKNumState != 81) {
        disabled = "disabled";
    }

    var mydata = buscarHistorico(coligada, codigoproduto);
    console.log(mydata);
    var groupColumn = 2;
    $('#lookupHistorico').DataTable({

        language: {
            url: "js/plugins/datatables/Portuguese-Brasil.json"
        },
        data: mydata,
        columns: [{
                data: 'CODCFO',
                title: 'Código'
            },
            {
                data: 'DATAEMISSAO',
                title: 'Data',
                render: function (data, type, row) {
                    var dateSplit = moment(data).format("DD/MM/YYYY")
                    return type === "display" || type === "filter" ?
                        dateSplit :
                        data;
                }
            },
            {
                data: 'CGCCFO',
                title: 'CNPJ'
            },
            {
                data: 'NOME',
                title: 'Fornecedor'
            },

            {
                data: 'QUANTIDADE',
                title: 'Quantidade',
                render: function (data, type, row) {
                    var dateSplit = numeral(parseFloat(data)).format('0,0.00');
                    return type === "display" || type === "filter" ?
                        dateSplit :
                        data;
                }
            },
            {
                data: 'PRECOUNITARIO',
                title: 'Preço',
                render: function (data, type, row) {
                    var dateSplit = numeral(parseFloat(data)).format('$ 0,0.00');
                    return type === "display" || type === "filter" ?
                        dateSplit :
                        data;
                }
            },
            {
                "data": null,
                "defaultContent": `<button type="button" class="btn btn-sm btn-default" onclick="addFornecedorHistorico(this);" ${disabled}>
                        <span class="fluigicon fluigicon-money-circle fluigicon-sm"></span> Cotar</button>`
            }
        ],
        "columnDefs": [{
            "targets": [0],
            "visible": true,
            "searchable": false
        }],
        "lengthMenu": [
            [5, 10],
            [5, 10]
        ]
    });

    $(document).on("click", "[data-open-modal-historico]", function (e) {


        modalHistorico.remove();



    });



}

function openModalCotacaoFornecedor(element, origem,localEstoque) {

    console.log("OpenModal")
    console.log(element)
    console.log(origem)
    console.log(localEstoque)


    var id = $(element).closest("tr").find("input").first().attr("name").split("___")[1];
    var forma_cotar = $("select[name='cotacao_tipo_cotacao___"+id+"'] option:selected").val()



  

    // console.log(forma_cotar);

    var modeRead = "";
    var actions = [{
        'label': 'Ok',
        'bind': 'data-save-cotacao',
        'autoClose': true
    }, {
        'label': 'Cancelar',
        'autoClose': true
    }];

    if (origem == "inicial" || forma_cotar == "web") {
        modeRead = "readonly";
        actions = [{
            'label': 'Cancelar',
            'autoClose': true
        }]
    }

    if (origem == "atual"  && forma_cotar == "web" && WKNumState == "67") {
        modeRead = "";
        var actions = [{
            'label': 'Ok',
            'bind': 'data-save-cotacao',
            'autoClose': true
        }, {
            'label': 'Cancelar',
            'autoClose': true
        }];
    }




    var codcfo = $("#forn_codcfo___" + id).val();
    var itens = getItensCotacaoFornecedor(codcfo, origem,localEstoque);
    console.log("Itens")
    console.log(itens)


    var html = `<table data-tbl-precos class="table-bordered table-condensed table-hover"></table>`





    var modalCotacao = FLUIGC.modal({
        title: 'Pesquisa',
        title: 'Registro de Preços Cotados',
        content: html,
        id: 'fluig-modal',
        size: 'full',
        actions: actions
    }, function (err, data) {
        if (err) {

        } else {


        }
    });

    datablePrecosCotados = $('[data-tbl-precos]').DataTable(
        {
            language: {
                "url": "/devLib/resources/js/plugins/datatables/Portuguese-Brasil.json"
            },
            dom: 'Bfrtip',
            buttons: ['copy', 'excel'],
            data: itens,

            //  data: this.buscaOrdens(),
            columns: [

                {
                    data: "idPaiFilho",
                    title: "Seq",
                    render: function (data, isType, full, meta) {
                        return full.idPaiFilho
                    }
                },
                {
                    data: "",
                    title: "Status",
                    render: function (data, isType, full, meta) {


                        var status = full.status_item;

                        var nao_cotado = "";
                        var cotado = "";
                        var nao_fornecido = "";
                        var nao_disponivel = "";

                        status == "nao_cotado" ? nao_cotado = "selected" : false;
                        status == "cotado" ? cotado = "selected" : false;
                        status == "nao_fornecido" ? nao_fornecido = "selected" : false;
                        status == "nao_disponivel" ? nao_disponivel = "selected" : false;



                        return `    
                                <select data-status-item-cotacao name="status_${full.idPaiFilho}" id="status_${full.idPaiFilho}" value="${status}" class="form-control" ${modeRead}>
                                    <option value="nao_cotado" ${nao_cotado}>Não Cotado</option>
                                    <option value="cotado" ${cotado}>Cotado</option>
                                    <option value="nao_fornecido" ${nao_fornecido}>Não Fornecido</option>
                                    <option value="nao_disponivel" ${nao_disponivel}>Item não disponível</option>
                                </select>
                                <input type="hidden" size="2" name="idPaiFilhoFornecedor_${full.idPaiFilho}" id="idPaiFilhoFornecedor_${full.idPaiFilho}" class="form-control" value="${id}" >
                                <input type="hidden" size="2" name="idPaiFilhoItemCotacao_${full.idPaiFilho}" id="idPaiFilhoItemCotacao_${full.idPaiFilho}" class="form-control" value="${full.idPaiFilho}" >
                                `
                    }
                },
                {
                    data: "produto_descricao",
                    title: "Item",

                },
                {
                    data: "produto_quantidade",
                    title: "Quantidade",
                    render: function (data, isType, full, meta) {
                        return `<input type="text" data-mask-value data-cotacao-quantidade  name="quantidade_${full.idPaiFilho}" id="quantidade_${full.idPaiFilho}" class="form-control fs-txt-right" value="${full.produto_quantidade}" readonly/>`
                        //return `<span data-mask-value data-cotacao-quantidade id="quantidade_${full.idPaiFilho}" name="quantidade_${full.idPaiFilho}">${full.produto_quantidade}</span>`

                    }



                },
                {
                    data: "",
                    title: "Preço Unitário",
                    render: function (data, isType, full, meta) {
                        return `<input type="text" data-mask-money data-cotacao-preco placeholder="R$ 0,00" data-preco  name="preco_${full.idPaiFilho}" id="preco_${full.idPaiFilho}" value="${full.preco}" class="form-control fs-txt-right" ${modeRead}/>`
                    }
                },
                {
                    data: "",
                    title: "% IPI",
                    render: function (data, isType, full, meta) {
                        return `<input type="text" data-mask-percent data-cotacao-ipi placeholder="0,00 %" name="ipi_${full.idPaiFilho}" id="ipi_${full.idPaiFilho}" class="form-control fs-txt-right" value="${full.produto_ipi}" ${modeRead}/>`
                    }
                },
                {
                    data: "",
                    title: "% ICMS",
                    render: function (data, isType, full, meta) {
                        return `<input type="text" data-mask-percent data-cotacao-icms placeholder="0,00 %" name="icmsst_${full.idPaiFilho}" id="icmsst_${full.idPaiFilho}"  class="form-control fs-txt-right" value="${full.icmsst}" ${modeRead}/>`
                    }
                },
                {
                    data: "",
                    title: "Desconto",
                    render: function (data, isType, full, meta) {
                        return `<input type="text" data-mask-money data-cotacao-desconto placeholder="R$ 0,00" name="desconto_${full.idPaiFilho}" id="desconto_${full.idPaiFilho}"  class="form-control fs-txt-right" value="${full.desconto}" ${modeRead}/>`
                    }
                },

                {
                    data: "",
                    title: "Total Item",
                    render: function (data, isType, full, meta) {
                        return `<input type="text" data-mask-money  placeholder="R$ 0,00" name="total_${full.idPaiFilho}" id="total_${full.idPaiFilho}"  class="form-control fs-txt-right"  readonly/>`
                    }
                },
            ],
            columnDefs: [ // {"targets": [0], "visible": false,"searchable": false},
            ],
            fixedHeader: true,
            processing: true, //utilizado para atualizar a tabela
            destroy: true, //utilizado para atualizar a tabela
            pagingType: 'full_numbers', //tipo de paginação
            "lengthMenu": [
                [5, 10,30],
                [5, 10,30]
            ],
            info: true, //Se terá info da tabela
            createdRow: function (row, data, index) {

            },
            drawCallback: function (configs) {

                $("[data-preco]").keypress(function (e) {

                    console.log(e.which)
                    if (e.which == 13) {
                        console.log($(this).closest('tr'))

                        $(this).closest('tr').nextAll().eq(0).find('input[data-preco]').focus();


                    }

                    if (e.which == 38) {
                        console.log($(this).closest('tr'))

                        $(this).closest('tr').nextAll().eq(0).find('input').focus();


                    }
                })

                initMask();
                calculaTotaisDigitacao();

            },
            "initComplete": function (settings, json) {


            }

        }


    )





    initMask();

    $('[data-save-cotacao]').click(function () {
        salvaDadosDigitados();
        calculaTotaisTodosFornecedores();
        modalCotacao.remove();
        datablePrecosCotados.destroy();
    })

}

function salvaDadosDigitados() {

    console.log("salvaDadosDigitados")
    console.log(datablePrecosCotados)

    
    datablePrecosCotados.data().map((item, i) => {

        console.log(item)

        var preco = item.preco;
        var id_itemCotado = $("#idPaiFilhoItemCotacao_" + item.idPaiFilho).val();

        

        $("#cotacao_preco___" + id_itemCotado).val(preco);
        $("#cotacao_status_item___" + id_itemCotado).val(item.status_item);
        $("#cotacao_produto_ipi___" + id_itemCotado).val(item.produto_ipi);
        $("#cotacao_desconto___" + id_itemCotado).val(item.desconto);
        $("#cotacao_icmsst___" + id_itemCotado).val(item.icmsst);
        $("#cotacao_total_item___" + id_itemCotado).val(item.total_item);



    })

    $("[data-cotacao-preco]").each(function () {

        var preco = $(this).val();
        var id_precoDigitado = $(this).attr("name").split("_")[1];
        var id_itemCotado = $("#idPaiFilhoItemCotacao_" + id_precoDigitado).val();

        $("#cotacao_preco___" + id_itemCotado).val(preco);
        $("#cotacao_status_item___" + id_itemCotado).val($("#status_" + id_precoDigitado).val());
        $("#cotacao_produto_ipi___" + id_itemCotado).val($("#ipi_" + id_precoDigitado).val());
        $("#cotacao_desconto___" + id_itemCotado).val($("#desconto_" + id_precoDigitado).val());
        $("#cotacao_icmsst___" + id_itemCotado).val($("#icmsst_" + id_precoDigitado).val());
        $("#cotacao_total_item___" + id_itemCotado).val($("#total_" + id_precoDigitado).val());


    });

}

function calculaTotaisDigitacao() {

    $("[data-cotacao-preco]").each(function () {

        var id = $(this).attr("name").split("_")[1];
        var preco = convertStringFloat($(this).val()) || 0;

        if (preco > 0) {

            var quantidade = convertStringFloat($("#quantidade_" + id).val());
            var ipi = convertStringFloat($("#ipi_" + id).val() || 0);
            var icms = convertStringFloat($("#icmsst_" + id).val() || 0);
            var desconto = convertStringFloat($("#desconto_" + id).val() || 0);

            var valorLiquido = (quantidade * preco) - desconto;
            var valorTributos = valorLiquido * ((ipi + icms) / 100);

            var total = valorLiquido + valorTributos;
            $("#total_" + id).val("R$ " + numeral(total).format('0,0.00'));
        }
    })
}

function calculaTotaisItensTodosFornecedores() {

    //Local Entrega Fornecedor
    

    $("input[name^='local_forn_key___']").each(function () {

        var keycfo = $(this).val();
        var id = $(this).attr("name").split("___")[1];
        var local_codigo = $("#local_codigo___"+id).val()

        var total = 0;

        $('#tblItensCotacaoFornecedor tbody tr').not(':first').each(
            function (count, tr) {
                var keycfo_item = $(tr).find("input[name^='cotacao_key__']").val();
                var local_item = $(tr).find("input[name^='cotacao_sol_local_estoque__']").val();

                if (keycfo == keycfo_item && local_item == local_codigo)  {
                    var precoItem = convertStringFloat($(tr).find("input[name^='cotacao_preco__']").val());

                    if (precoItem > 0) {

                        var ipi = convertStringFloat($(tr).find("input[name^='cotacao_produto_ipi__']").val()) || 0;
                        var icms = convertStringFloat($(tr).find("input[name^='cotacao_icmsst__']").val()) || 0;
                        var desconto = convertStringFloat($(tr).find("input[name^='cotacao_desconto__']").val()) || 0;
                        var quantidade = convertStringFloat($(tr).find("input[name^='cotacao_produto_quantidade__']").val());

                        var valorLiquido = (quantidade * precoItem) - desconto;
                        var valorTributos = valorLiquido * ((ipi + icms) / 100);

                        var totalitem = valorLiquido + valorTributos;

                        total = total + totalitem;
                    }

                   
                }

            });

        console.log("Total Itens Local " + local_codigo)
        console.log(total)

        console.log(numeral(total).format('$ 0,0.00'))

        $("input[data-campo-local-entrega='"+id+"'][id^='cotacao_total_itens']").val(numeral(total).format('$ 0,0.00'))

        //$("#cotacao_total_itens___" + id).val(numeral(total).format('$ 0,0.00'));
    });
}

function calculaTotaisTodosFornecedores() {

    calculaTotaisItensTodosFornecedores();

    $("input[name^='local_forn_key___']").each(function () {

        var keycfo = $(this).val();
        var id = $(this).attr("name").split("___")[1];
        var local_codigo = $("#local_codigo___"+id).val()
        var total_frete = $("input[data-campo-local-entrega='"+id+"'][id^='cotacao_valor_frete']").val() || 0;
        var total_itens = $("input[data-campo-local-entrega='"+id+"'][id^='cotacao_total_itens']").val() || 0;
        var total = convertStringFloat(total_frete) + convertStringFloat(total_itens);

        $("input[data-campo-local-entrega='"+id+"'][id^='cotacao_total_cotacao']").val(numeral(total).format('$ 0,0.00'))

    })

}

function addFornecedorHistorico(el) {

    var value = $(el).closest('tr').find('td:first')[0].innerText;

    selectedFornecedor = buscarFornecedor(value.trimEnd())[0];

    console.log("addFornecedorHistorico");
    console.log(selectedFornecedor);


    if (!$.isEmptyObject(selectedFornecedor))
        addFornecedor();




}

function buscarHistorico(coligada, codigoproduto) {


    var returnList = [];




    var c0 = DatasetFactory.createConstraint("CODCOLIGADA", coligada, coligada, ConstraintType.MUST);
    var c1 = DatasetFactory.createConstraint("CODIGOPRD", codigoproduto, codigoproduto, ConstraintType.MUST);

    var constraints = new Array(c0, c1);

    var dataset = DatasetFactory.getDataset("rm_consulta_ultimas_compras", null, constraints, null);

    if (dataset) {
        returnList = dataset.values;
    }

    return returnList;


}

function buscarSolicitacoes() {


    var returnList = [];

    var coligada = $("#empresa_codigo").val();
   /// var unidade_codigo = $("#unidade_codigo").val();
    var filial_codigo = $("#filial_codigo").val();


    console.log("### filial_codigo : " + filial_codigo);


    var c0 = DatasetFactory.createConstraint("sqlLimit", "50", "50", ConstraintType.MUST);
    var c1 = DatasetFactory.createConstraint("codcoligada", coligada, coligada, ConstraintType.MUST);
    var c2 = DatasetFactory.createConstraint("codfilial", filial_codigo, filial_codigo, ConstraintType.MUST);

    var constraints = new Array(c0, c1, c2);

    var dataset = DatasetFactory.getDataset("CP002-SolicitacoesPendentes", null, constraints, null);

    if (dataset) {
        returnList = dataset.values;
    }

    return returnList;


}

function delItemCotacao(oElement) {


    let id = $(oElement).closest("tr").find("input[name^='solicitacao_numero_']").attr("name").split("___")[1]

    let solicitacao = $("#solicitacao_numero___"+id).val();
    let item_seq = $("#solicitacao_item_seq___" + id).val();
    let solicitacao_documentid = $("#solicitacao_documentid___" + id).val();
    let localEstoqueSolicitacao = $("#solicitacao_local_estoque___" + id).val();
    let quantidadeItensMesmoLocal = $("input[name^='solicitacao_local_estoque_'][value='" + localEstoqueSolicitacao + "']").length


    // Atualizar Solicitacao de Compras

    var c0 = DatasetFactory.createConstraint("solicitacao_item_seq", item_seq, item_seq, ConstraintType.MUST);
    var c1 = DatasetFactory.createConstraint("solicitacao_documentid", solicitacao_documentid, solicitacao_documentid, ConstraintType.MUST);
    var c2 = DatasetFactory.createConstraint("operacao", "cancel", "cancel", ConstraintType.MUST);

    var constraints = new Array(c0, c1, c2);

    var dataset = DatasetFactory.getDataset("updatePurchaseRequest", null, constraints, null);

    console.log("Dataset")
    console.log(dataset)

   /* if (dataset) {
        returnList = dataset.values;
    }*/

    //////////////////////////////////////


    //Deleta Item da Cotação dos Fornecedores
    delItemCotacaoFornecedor(solicitacao, item_seq)

    //Deleta Locais de Estoque

    if (quantidadeItensMesmoLocal == 1){

        let locaisRemover = $("input[name^='local_codigo_'][value='" + localEstoqueSolicitacao+"']").closest("tr");

        for (let i = 0; i < locaisRemover.length; i++) {
        
            fnWdkRemoveChild(locaisRemover[i])
            
        }

        

    }




    //Deleta Item Cotado
    fnWdkRemoveChild(oElement);

    
    refreshSequenceItem();

}

function delItemCotacaoFornecedor(solicitacao, item){

    //Deleta um item da cotação para os fornecedores
    $("input[name^='cotacao_item_seq___']").each(function(){

      
        let id = $(this).attr("name").split("___")[1]

        cotacao_solicitacao_numero = $("#cotacao_solicitacao_numero___"+id).val()
        cotacao_solicitacao_item_seq = $("#cotacao_solicitacao_item_seq___" + id).val()

        if (solicitacao == cotacao_solicitacao_numero && item == cotacao_solicitacao_item_seq ){

            fnWdkRemoveChild(this);
           

        }


    })


}

function delFornecedor(oElement) {


    var id = $(oElement).closest("tr").find("input").first().attr("name").split("___")[1];
    var keycfo_deletado = $("#forn_key___" + id).val();

    //DELETA ITENS COTAÇÃO DO FORNECEDOR
    $('#tblItensCotacaoFornecedor tbody tr').not(':first').each(
        function (count, tr) {
            var keycfo_item = $(tr).find("input[name^='cotacao_key__']").val();

            if (keycfo_deletado == keycfo_item) {
                fnWdkRemoveChild(tr);
            }

        });

    //DELETA LOCAIS COTAÇÃO DO FORNECEDOR
    $('#tblLocalCotacaoFornecedor tbody tr').not(':first').each(
        function (count, tr) {
            var keycfo_LOCAL = $(tr).find("input[name^='local_forn_key__']").val();

            if (keycfo_deletado == keycfo_LOCAL) {
                fnWdkRemoveChild(tr);
            }

        });


    fnWdkRemoveChild(oElement);


    refreshSequenceForn();
}

function refreshSequenceForn() {
    var index = 0;
    $("table[tablename='tblFornecedor'] tbody tr").each(function () {
        $(this).find("td input[name^='forn_seq_']").val(index);
        index++;
    });
}

function refreshSequenceItem() {
    var index = 0;
    $("table[tablename='tblItem'] tbody tr").each(function () {
        $(this).find("td input[name^='item_seq_']").val(index);
        index++;
    });
}

function makeid() {
    var text = "";
    var possible = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";

    for (var i = 0; i < 5; i++)
        text += possible.charAt(Math.floor(Math.random() * possible.length));

    return text;
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

function checkFrete() {



    $("input[name^='cotacao_tem_frete___']").each(function(){

        var temFrete = $(this).is(":checked");
        var id=$(this).attr("name").split("___")[1]
        var inputFrete =  $("td input[name='cotacao_valor_frete___"+id+"']");

           if (temFrete) {
            $(inputFrete).attr("readonly", false);
            $(inputFrete).attr("data-validation", "required");
            $(inputFrete).attr("data-validation-error-msg", "Informe o valor do frete");

        } else {
            $(inputFrete).val("");
            $(inputFrete).attr("data-validation", "");
            $(inputFrete).attr("readonly", true);
        }


    })





}

function updateTabLink() {



    $("input[name^='forn_codcfo___']").each(function () {

        var seq = $(this).attr("name").split("___")[1];

        var td = $(this).closest("td");

        var tabAtual = $(td).find("[data-nav-tab-atual]");
        var tabOriginal = $(td).find("[data-nav-tab-inicial]");

        var paneAtual = $(td).find("[data-nav-pane-atual]");
        var paneOriginal = $(td).find("[data-nav-pane-inicial]");



        $(tabAtual).attr("href", "#tabAtual" + seq);
        $(paneAtual).attr("id", "tabAtual" + seq);

        $(tabOriginal).attr("href", "#tabOriginal" + seq);
        $(paneOriginal).attr("id", "tabOriginal" + seq);




    })

    /* $("a[id^='tabMenu']").not(':first').each(function(){

         var name = $(this).attr("id").split("___")[0];
         var id = $(this).attr("id").split("___")[1];
         var href = $(this).attr("href");

         if(href.split("___").length > 0){
             href.split("___")[0];
         }


         if(name=="tabMenuNegociacao"){
             $(this).attr("href","#ta"+id);
         }else{
             $(this).attr("href","#tabRegistroPreco___"+id);
         }
         

         console.table([id,href+"___"+id]);
             
     })*/

}

function countChildItems(table) {
    var quantidade = $("table[tablename='"+table+"'] tbody tr").length;
    quantidade = quantidade - 1;

    return quantidade;
}

function removeDuplicates(myArr, prop) {
    return myArr.filter((obj, pos, arr) => {
        return arr.map(mapObj => mapObj[prop]).indexOf(obj[prop]) === pos;
    });
}

function getLocalEstoqueUnico(){

    var locaisEntregaArr = []
    $("input[name^='cotacao_sol_local_estoque_']").each(function () {
        
        let local = {};
        let id = $(this).attr("name").split("___")[1]

        local.CODIGO   = $(this).val()
        local.CIDADE   = $("#cotacao_entrega_cidade___"+id).val()
        local.ENDERECO = $("#cotacao_entrega_endereco___" + id).val()
        local.UF       = $("#cotacao_entrega_uf___" + id).val()
        local.NOME     = $("#cotacao_entrega_local_nome___" + id).val()
 
        if (local.CODIGO != ""){
            locaisEntregaArr.push(local)
        }
        //locaisEntregaArr.push($(this).val())

    })

    console.log("locaisEntregaArr");
    console.log(locaisEntregaArr);

   
    var obj = {};

    for (var i = 0, len = locaisEntregaArr.length; i < len; i++)
        obj[locaisEntregaArr[i]['CODIGO']] = locaisEntregaArr[i];

    locaisEntregaArr = new Array();
    
    for (var key in obj)
        locaisEntregaArr.push(obj[key]);



    return locaisEntregaArr

}

function MontaViewPorLocalEstoque(){

   
    //Iteração cada Fornecedor
    $("input[name^='forn_codcfo___']").each(function () {

        var id_forn = $(this).attr("name").split("___")[1]
        var forn_key = $("#forn_key___" + id_forn).val()
        var div = $(this).closest("tr").find("[data-div-capa-cotacao-fornecedor]")
     
        let outHTML = "";
        $(div).html("");

        //Iteração cada Local de Entrega/Fornecedor
        $("input[name^='local_forn_key___']").each(function () {

            var id_local = $(this).attr("name").split("___")[1]
            var local_forn_key = $("#local_forn_key___" + id_local).val()
            var local_codigo =  $("#local_codigo___" + id_local).val()


            if (forn_key == local_forn_key){

      
                var valorfrete = $("#local_valor_frete___" + id_local).val();
                
                console.log("# Valor do Frete para o item "+id_local+":"+valorfrete)

                 outHTML += `<div class="panel panel-default">
                                     <div class="panel-body">	<div class="row">
                                        <div class="form-group col-md-5">
                                                   <label for="identificador">Local de Entrega</label>
                                                   <input type="text" class="fs-no-style-input fs-display-block"  size="100%" style="font-size: 18;"  name="local_nome___${id_local}" id="local_nome___${id_local}" value="${$("#local_nome___" + id_local).val() ||''}">
                                         </div>
                                         <div class="form-group col-md-7">
                                                     <label for="identificador">Endereço</label>
                                                     <input type="text" class="fs-no-style-input fs-display-block" size="100%" style="font-size: 18;" name="local_endereco___${id_local}" id="local_endereco___${id_local}" value="${$("#local_endereco___" + id_local).val() ||''}"">
                                                 </div>
                                             </div>
                                             <div class="row">
                                                 <div class="form-group col-md-2">
                                                     <label>Data Entrega</label>
                                                     <input type="text" data-campo-local-entrega="${id_local}" data-previsao-entrega name="cotacao_previsao_entrega___${id_local}" id="cotacao_previsao_entrega___${id_local}" class="form-control" value="${$("#local_dataentrega___" + id_local).val() || '' }">
                                                 </div>
                                                 <div class="form-group col-md-2">
                                                     <label>Valor Frete</label>
                                                     <div class="input-group">
                                                         <span class="input-group-addon">
                                                             <input data-campo-local-entrega="${id_local}" name="cotacao_tem_frete___${id_local}" id="cotacao_tem_frete___${id_local}" value="sim" type="checkbox" ${$("#local_tem_frete___" + id_local).val() == "sim" ? "checked" : ""} >
                                                        </span>
                                                         <input type="text" data-campo-local-entrega="${id_local}"  data-mask-money name="cotacao_valor_frete___${id_local}" id="cotacao_valor_frete___${id_local}" class="form-control" placeholder="R$ 0,00" value="${$("#local_valor_frete___" + id_local).val() || ''}" readonly>
                                                     </div>
                                                 </div>
                                                 <div class="form-group col-md-2">
                                                     <label>Cond. Pagto</label>
                                                     <input type="text" data-campo-local-entrega="${id_local}" name="cotacao_cond_pgto___${id_local}" id="cotacao_cond_pgto___${id_local}" class="form-control" ${$("#local_condpgto___" + id_local).val() || ""}>
                                                 </div>
                                                 <div class="form-group col-md-2" style="width:auto;">
                                                     <label style="display:block">Total Itens</label>
                                                     <strong class=""><input type="text" size="14" style="display:block;  font-size: 20px" data-campo-local-entrega="${id_local}" font-size: 20px" value="R$ 0,00" placeholder="R$ 0,00" name="cotacao_total_itens___${id_local}" id="cotacao_total_itens___${id_local}"
                                                                class="fs-no-style-input" readonly></strong>
                                                 </div>
                                                 <div class="form-group col-md-2" style="width:auto;">
                                                     <label style="display:block">Total Cotação</label>
                                                     <strong><input type="text" size="14" style="display:block; font-size: 20px" data-campo-local-entrega="${id_local}" value="R$ 0,00" placeholder="R$ 0,00" name="cotacao_total_cotacao___${id_local}" id="cotacao_total_cotacao___${id_local}"
                                                                class="fs-no-style-input" readonly></strong>
                                                 </div>
                                                 <div class="btn-group" style="margin-top:24px">
                                                     <button type="button" class="btn btn-default" id="btn_forn_itens" name="btn_forn_itens" data-btn-cotacao-fornecedor onclick="openModalCotacaoFornecedor(this,'atual','${local_codigo}')">
                                                         <span class="fluigicon fluigicon-money fluigicon-sm fs-cursor-pointer"></span> Preços Cotados
                                                     </button>
                                                     <button type="button" data-btn-anexar-cotacao class="btn btn-default" id="btn_forn_anexar" name="btn_forn_anexar">
                                                         <span class="fluigicon fluigicon-file-upload fluigicon-sm fs-cursor-pointer"></span> Anexar
                                                     </button>
                                                 </div>
                                             </div>
                                             </div></div>`
    
            }

           

        })

        $(div).append(outHTML)

        FLUIGC.calendar('[data-previsao-entrega]', {
            language: 'pt-br',
            minData: $("#data_cotacao").val()
        });



    })


    
 
    calculaTotaisTodosFornecedores();
 initMask();

   
}

$(document).on('focus click', '[data-previsao-entrega]', function (e) {
    console.clear()
    console.log("FOCUS!")
    FLUIGC.calendar('[data-previsao-entrega]', {
        language: 'pt-br',
        minData: $("#data_cotacao").val()
    });
})


