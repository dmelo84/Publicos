var data = [];
var dataItens = [];
var globalTable = {};
var selectedOrderRow = {};
var ordersAdded = [];
var dataEmissaoNf = FLUIGC.calendar('#nf_emissao_div');

$(document).ready(function () {



    numeral.locale('pt-br');
    initMask();

    buscarOrdensPendentes();
    getTableOrdens();


    
    //FLUIGC.calendar("#nf_emissao");

    loadValidation();

    //setTimeout(validateAll, 1000);

    $('a[href="#tabRecebimento"]').on('shown.bs.tab', function(e) { 
      
        validateAll();

    });


});

var loadValidation = function () {
    $.validate({
        validateOnBlur: true,
        validateHiddenInputs: false,
        dateFormat: 'dd/mm/yyyy',
        decimalSeparator: ",",
        onModulesLoaded: function () {},
        onElementValidate: function (valid, $el, $form, errorMess) {
            // console.log('Input ' + $el.attr('name') + ' is ' + (valid ? 'VALID' : 'NOT VALID'));
        }
    });

    $.formUtils.addValidator({
        name : 'even_number',
        validatorFunction : function(value, $el, config, language, $form) {
          
            var d = value.split("/");
      
            var dataInformada = new Date(d[2]+"-"+d[1]+"-"+d[0] + " 00:00:00");
            var dataAtual     = new Date();
            var dataMinima    = getMinDateOrders();

            console.log("dataInformada " + dataInformada);
            console.log("dataAtual " + dataAtual);
            console.log("dataMinima " + dataMinima);

          if(dataInformada >= dataMinima && dataInformada <= dataAtual)
          {
              return true;
          }

          
            return false;
        },
        errorMessage : 'A data de emissão não é válida',
        errorMessageKey: 'badEvenNumber'
      });

}

function getMinDateOrders(){
    
    var arrDatas = [];

    $("input[name^='titem_dataOrdem___']").each(function(){

        arrDatas.push(new Date($(this).val() + " 00:00:00"));
        var dt = $(this).val();
    })

    if(arrDatas.length > 0){
         return new Date(Math.min.apply(null,arrDatas));
    }

}

function validateAll() {
    validationErrors = [];

    $('input,textarea').validate(function (valid, elem) {

        if (!valid) {
            validationErrors.push(elem.name);
        }

    });
}

$(document).on("click", "[data-btn-filter]", function () {

    buscarOrdensPendentes();
    refreshTab();
    //getTableOrdens();

    console.log("TABLEORDENS");
    console.log( globalTable);

});

$(document).on("click", "[data-btn-zoom-autocomplete]", function () {

    var target = $(this).data("btn-zoom-autocomplete");
    //console.log(target);

    if (target == "acFornecedor") {
        acFornecedor.val("%");
        $("#fornecedor_nome").val("%");
        $("#fornecedor_nome").focus();
        acFornecedor.open();
    }

});

$(document).on("click", "[data-btn-clear]", function () {

    limpaFiltro();
});

$(document).on("click","[data-btn-limpar-recebimento]",function(evt) {

    //////
    limpaFiltro();

    limpaTabelaItens();

    $("#tabRecebimento input, select, textarea").each(function(){

        $(this).val("");

    })

});





$(document).on("click", "[data-btn-visualizar]", function (evt) {

    // console.log("Click Visualizar");
    evt.preventDefault();
    var tr = $(this).closest("tr");
    var data = globalTable.row(tr).data();

    //  console.log("Visualizar Data");
    // console.log(data);

    openModelViewItens(data);

});


$(document).on("click", "[data-btn-receber]", function (evt) {


    // $("#load").hide();
    selectedOrderRow = {};
    evt.preventDefault();

    var tr = $(this).closest("tr");
    selectedOrderRow = globalTable.row(tr).data();
    globalTable.row(tr).remove();

    setFornecedor(selectedOrderRow);



    buscarItensOrdem(selectedOrderRow);

    for (var i = 0; i < dataItens.values.length; i++) {
        addItem(dataItens.values[i]);
    }

    //$("#load").show();
});


function limpaFiltro(){

    $("#numero_ordem").val("");
    $("#numero_solicitacao").val("");

    if(ordersAdded.length == 0){
        
        acFornecedor.val("")
        $("#fornecedor_nome").val("");
        $("#fornecedor_codigo").val("");

    }

    buscarOrdensPendentes();

    refreshTab();


}
function limpaTabelaItens(){

  
    $('#tblItemRecebido tbody tr').not(':first').each(function (count, tr) {

        console.log("TR>>> ");
        console.log(tr);
        fnWdkRemoveChild(tr);
    

    });

}


function fnCustomDelete(oElement) {
    // Chamada a funcao padrao, NAO RETIRAR
    fnWdkRemoveChild(oElement);
    refreshSequenceItems();
};

function setFornecedor(fornecedor) {



    ordersAdded.push(fornecedor.IDMOV);

    $("#ordens_recebidas").val(ordersAdded);

    $("#fornecedor_codigo").val(fornecedor.CODCFO);
    $("#fornecedor_nome").val(fornecedor.NOMEFANTASIA);

    var frete = convertStringFloat($("#frete").val() || 0);
        frete += convertStringFloat(fornecedor.VALORFRETE);

    $("#frete").val(frete.toFixed(2).replace(".",","));

    $("#filial").val(fornecedor.FILIAL);
    $("#filial_cnpj").val(fornecedor.FILIAL_CNPJ);

    $("#fornecedor_codigo").attr("disabled", true);
    $("#fornecedor_nome").attr("disabled", true);

    $("[data-btn-zoom-autocomplete]").hide();


    $("#fornecedor").val(fornecedor.NOMEFANTASIA);
    $("#cnpj").val(fornecedor.CGCCFO);

    globalTable.draw();

}

function refreshTab() {

    // globalTable = $('#tableOrdens').DataTable();

    globalTable.clear();
    globalTable.rows.add(data.values).draw();


}

function buscarOrdensPendentes() {

    var codusuario_rm = $("#codusuario_rm").val();
    var numero_ordem = $("#numero_ordem").val() || "%";
    var fornecedor_codigo = $("#fornecedor_codigo").val() || "%";

    var constraints = new Array();

    constraints.push(DatasetFactory.createConstraint("CODUSUARIO", codusuario_rm, codusuario_rm, ConstraintType.MUST));


    if (ordersAdded.length > 0) {

        for (var i = 0; i < ordersAdded.length; i++) {
            constraints.push(DatasetFactory.createConstraint("NUMEROMOV", ordersAdded[i].toString(), ordersAdded[i].toString(), ConstraintType.MUST_NOT));
        }

        constraints.push(DatasetFactory.createConstraint("NUMEROMOV", "%" + numero_ordem + "%", "%" + numero_ordem + "%", ConstraintType.SHOLD, true));

    } else {

        constraints.push(DatasetFactory.createConstraint("NUMEROMOV", "%" + numero_ordem + "%", "%" + numero_ordem + "%", ConstraintType.MUST, true));
        constraints.push(DatasetFactory.createConstraint("CODCFO", fornecedor_codigo, fornecedor_codigo, ConstraintType.MUST,true));
    }

    /*

    if (ordersAdded.length > 0) {

        for (var i = 0; i < ordersAdded.length; i++) {
            constraints.push(DatasetFactory.createConstraint("NUMEROMOV", ordersAdded[i].toString(), ordersAdded[i].toString(), ConstraintType.MUST_NOT));
        }

        constraints.push(DatasetFactory.createConstraint("NUMEROMOV", "%" + numero_ordem + "%", "%" + numero_ordem + "%", ConstraintType.SHOLD, true));

    } else if (fornecedor_codigo != "%") {

        constraints.push(DatasetFactory.createConstraint("CODCFO", fornecedor_codigo, fornecedor_codigo, ConstraintType.MUST));
    } else if (numero_ordem != "%") {
        constraints.push(DatasetFactory.createConstraint("NUMEROMOV", "%" + numero_ordem + "%", "%" + numero_ordem + "%", ConstraintType.MUST, true));
    }
    */

    console.log("ordersAdded ");
    console.log(ordersAdded);
    console.log("constraints ");
    console.log(constraints);

    var dataSet = DatasetFactory.getDataset("rm_consulta_ordens_pendentes_recebimento", null, constraints, null);
    data = dataSet

    console.log("dataset ");
    console.log(dataSet);
    

}

function buscarItensOrdem(tableRow) {

    dataItens = [];

    //console.log("Busca Itens Ordem")

    var idmov = tableRow.IDMOV;
    var codcoligada = tableRow.CODCOLIGADA;

    //console.log("Busca Itens idmov "+idmov );
    //console.log("Busca Itens codcoligada "+codcoligada );
    
    var c1 = DatasetFactory.createConstraint("CODCOLIGADA", codcoligada, codcoligada, ConstraintType.MUST);
    var c2 = DatasetFactory.createConstraint("IDMOV", idmov, idmov, ConstraintType.MUST);
  
    var constraints = new Array(c1, c2);

    var dataSet = DatasetFactory.getDataset("rm_consulta_itens_ordem", null, constraints, null);

    if (dataSet) {

        dataItens = dataSet;
        return dataSet;

    }



}

function addItem(item) {

    var id = wdkAddChild('tblItemRecebido');

    $("#titem_dataOrdem___" + id).val(selectedOrderRow.DATAEMISSAO);
    $("#titem_nroOrdem___" + id).val(selectedOrderRow.NUMEROMOV);
    $("#titem_codItem___" + id).val(item.CODIGOPRD);
    $("#titem_descricao___" + id).val(item.DESCRICAO);
    $("#titem_unEntrada___" + id).val(item.CODUND);
    $("#titem_unEstoque___" + id).val(item.CODUND);
    $("#titem_fatorConv___" + id).val("1");
    $("#titem_precoUnitario___" + id).val("R$ " + numeral(item.PRECOUNITARIO).format('0,0.00'));
    $("#titem_qtdOrdem___" + id).val(numeral(item.QUANTIDADE).format('0,0.00'));
    $("#titem_qtdSaldo___" + id).val(numeral(item.QUANTIDADEARECEBER).format('0,0.00'));
    $("#titem_qtdRecebida___" + id).val(numeral(item.QUANTIDADEARECEBER).format('0,0.00'));
    var total = convertStringFloat(item.QUANTIDADEARECEBER) * convertStringFloat(item.PRECOUNITARIO)
    $("#titem_totalRecebido___" + id).val("R$ " + numeral(total).format('0,0.00'));

    $("#titem_ipi_iss___"+id).val(numeral(item.TRB_ALIQUOTA).format('0,0.00'))

    $("#titem_codcoligada___" + id).val(item.CODCOLIGADA);
    $("#titem_codfilial___" + id).val(item.CODFILIAL);
    $("#titem_nseqitmmov___" + id).val(item.NSEQITMMOV);
    $("#titem_idprd___" + id).val(item.IDPRD);
    $("#titem_idmov___" + id).val(item.IDMOV);

    dataEmissaoNf.setMinDate(new Date(selectedOrderRow.DATAEMISSAO + " 00:00:00"));
    dataEmissaoNf.setMaxDate(new Date());

    calculaTotais();

    initMask();

}

function getTableOrdens() {

    globalTable = $('#tableOrdens').DataTable({
        language: {
            url: "js/plugins/datatables/Portuguese-Brasil.json"
        },
      
        data: data.values,
        columns: [{
                "data": "null",
                "defaultContent":   `<button class="btn btn-default" data-btn-receber name="btnReceber"><span class="fluigicon fluigicon-download fluigicon-xs"></span></button>
                                    <button class="btn btn-default" data-btn-visualizar name="btnVisualizar"><span class="fluigicon fluigicon-search-test fluigicon-xs"></span></button>
`,
                "ordering": false

            },
            {
                data: 'NUMEROMOV',
                title: 'Nº Ordem'
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
                data: 'NOMEFANTASIA',
                title: 'Fornecedor'
            },
            {
                data: 'VALORBRUTOORIG',
                title: 'Valor Total',
                render: function (data, type, row) {
                    var dateSplit = numeral(parseFloat(data)).format('$ 0,0.00');
                    return type === "display" || type === "filter" ?
                        dateSplit :
                        data
                }
            }
        ],
        "columnDefs": [{
            "targets": 0,
            "searchable": false,
            "orderable": false
        }]
    });

   
}

function getTableItensOrdem() {



    var globalTableItens = $('#tableItensOrdem').DataTable({
        language: {
            url: "js/plugins/datatables/Portuguese-Brasil.json"
        },

        data: dataItens.values,
        columns: [{
                data: 'CODIGOPRD',
                title: 'Cód. Item'
            },
            {
                data: 'DESCRICAO',
                title: 'Descrição'
            },
            {
                data: 'CODUND',
                title: 'Un.'
            },
            {
                data: 'QUANTIDADE',
                title: 'Quantidade'
            },
            {
                data: 'PRECOUNITARIO',
                title: 'Preço',
                render: function (data, type, row) {
                    var dateSplit = numeral(parseFloat(data)).format('$ 0,0.00');
                    return type === "display" || type === "filter" ?
                        dateSplit :
                        data
                }
            },
            {
                data: 'VALORLIQUIDO',
                title: 'Valor',
                render: function (data, type, row) {
                    var dateSplit = numeral(parseFloat(data)).format('$ 0,0.00');
                    return type === "display" || type === "filter" ?
                        dateSplit :
                        data
                }
            }
        ],
        "columnDefs": [{
            "targets": 0,
            "searchable": false,
            "orderable": false
        }]
    });



}

$.fn.dataTable.ext.search.push(
    function (settings, data, dataIndex) {

        var cnpj = $("#cnpj").val();
        if (cnpj != "" && settings.sInstance != "tableItensOrdem") {

            if (cnpj == data[3]) {
                return true;
            } else {
                return false;
            }


        } else {
            return true;
        }

    }
);

function showCamera(parameter) {
    JSInterface.showCamera(parameter);
}

function openModelViewItens(dataRow) {

    var modal = FLUIGC.modal({
        title: 'Consulta Itens da Ordem de Compra ' + dataRow.NUMEROMOV + " | " + dataRow.NOMEFANTASIA,
        content: '<table id="tableItensOrdem" class="table table-striped table-bordered" width="100%"></table>',
        id: 'fluig-modal',
        size: 'full',
        actions: [ //{
            //'label': 'Save',
            // 'bind': 'data-open-modal',
            //},
            {
                'label': 'Fechar',
                'autoClose': true
            }
        ]
    }, function (err, data) {
        if (err) {
            // do error handling
        } else {

            buscarItensOrdem(dataRow);
            getTableItensOrdem();

        }
    });
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

$(document).on("blur", "[data-qtd-recebida]", function () {

    console.log("blur qtd recebida");
    var obj = $(this);
    var id = $(obj).attr("name").split("___")[1];

    var ipi_iss = convertStringFloat($("#titem_ipi_iss___"+id).val() || 0);
    ipi_iss = (ipi_iss/100)+1;

    var fator = convertStringFloat($("#titem_fatorConv___" + id).val());
    var preco = convertStringFloat($("#titem_precoUnitario___" + id).val());
    var saldo = convertStringFloat($("#titem_qtdSaldo___" + id).val() || 0);
    var quantidade = convertStringFloat($(obj).val());

    var total = (((preco * quantidade) * ipi_iss)).toFixed(2);

    $("#titem_totalRecebido___" + id).val(total.replace(".",","));

    calculaTotais();

})

$(document).on("keyup", "[data-qtd-recebida]", function (e) {

    console.log("keyup qtd recebida");

    var obj = $(this);
    var id = $(obj).attr("name").split("___")[1];
    var saldo = convertStringFloat($("#titem_qtdSaldo___" + id).val() || 0);
    var quantidade = convertStringFloat($(obj).val());

    if (quantidade > saldo) {

        $(obj).val(saldo.toFixed(2).replace(".",","));
    }






})

$(document).on("change", "[data-total-recebido]", function () {

    calculaTotais();

})

$(document).on("change", "[data-valor-frete]", function () {

    calculaTotais();

})

function calculaTotais() {

    var frete = convertStringFloat($("#frete").val() || 0);
    var icms = convertStringFloat($("#icms").val() || 0);

    var total = 0;
    $("[data-total-recebido]").each(function () {

  
        var valor = convertStringFloat($(this).val() || 0);
        total += valor;

    });

    $("#valorLiquido").val(total.toFixed().replace(".",","));
    $("#valorTotal").val((total + frete + icms).toFixed().replace(".",","));

}

$(document).on("keyup", "[data-total-recebido]", function (e) {


    //FAZ O TAB PARA PRÓXIMA QTD RECEBIDA

    if (e.which == 9) {

        var nome = e.currentTarget.name.split("___")[0];
        var id = e.currentTarget.name.split("___")[1];

        // console.log(e);

        if (nome == "titem_totalRecebido") {

            var next = parseInt(id) + 1;

            $("#titem_qtdRecebida___" + next).focus();
            //console.log( "#titem_qtdRecebida___"+next);
        }

    }

})