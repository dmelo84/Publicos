var selectedCentroCusto = {};
var selectedacLocalEstoque = {};
var selectedacProduto = {};
var selectedacContrato = {};
var selectedacEmpresa = {};
var selectacUnidade={};
var selectacFinalidadeCompra={};
var errors ={};
var myFORM = form

$(document).ready(function () {



    init();
    //var data = new Date();

    checkContrato();
  
    setLabelProduto();

    atualizaInfoStatus();

    FLUIGC.calendar('#data_necessidade',{
        minDate: $("#data_solicitacao").val()
    });
    
    FLUIGC.popover('.bs-docs-popover-hover',{trigger: 'hover', placement: 'auto'});
 

    //checkUsuarioRM();

    if (WKNumState == 28 || WKNumState == 32){
    	$('[data-btn-zoom-autocomplete]').hide();
    	$('[data-btn-zoom-autocomplete]').each(function(){$(this).hide(); });
    }
    $("#navegador").val(FLUIGC.utilities.checkBrowser().name);
})

function atualizaInfoStatus(){

    var stateName = $("#stateName").val() || "Abertura";

    $("[data-info-status]").html(stateName);

}

function checkUsuarioRM(){

    if($("#codusuario_rm").val()==""){
        $("#formulario").html("<h1>Seu login não está habilitado para iniciar uma solicitação de compras. </br> Entre em contato com a equipe de TI para liberação.</h1>")
    }
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


function fnCustomDelete(oElement) {



    var uid = $(oElement).closest("tr").find("input[name^='uid_item_']").val()

   
    // Chamada a funcao padrao, NAO RETIRAR
    fnWdkRemoveChild(oElement);

    rateio.removeRateioItem(uid);

    refreshSequenceItems();
};

function checkContrato() {

    var $divContrato = $("#divContrato");
    var $divInvestimento = $("#divInvestimento");

    


    if ($("input[name='tipo_solicitacao']:checked").val() == "contrato") {

        $divContrato.show();
        $divInvestimento.hide();
      
        $('#divBtnWorkflow').button('reset');
        $('#divWorkFlow').hide();
        $("#div_adicionaItensContrato").show();
        $("#div_adicionaProduto").hide();
        $("#divFinalidade").hide();       
    } else {
        $("#divFinalidade").show();
        $divContrato.hide();
        $divInvestimento.show();
        $("#div_adicionaItensContrato").hide();
        $("#div_adicionaProduto").show();
        $('#divWorkFlow').show();
        $('input[name=prioridade]').filter('[value="emergencial"]').attr('readonly',false);

        $("#ccusto_codigo").attr("disabled", false);
        $("#ccusto_nome").attr("disabled", false);

        $("#unidade_codigo").attr("disabled", false);
        $("#unidade_nome").attr("disabled", false);

        $("[data-btn-zoom-autocomplete='acCentroCusto']").show();
        $("[data-btn-zoom-autocomplete='acUnidade']").show();

     /*   $("#ccusto_codigo").attr("disabled",false);
        $("#ccusto_nome").attr("disabled",false);

        $("#unidade_codigo").attr("disabled",false);
        $("#unidade_nome").attr("disabled",false);
*/



    }
}

function changeTipoSolicitacao(){

    resetEmpresa();
    

}

$("[data-btn-open-itens-contrato]").click(function(event){
    event.preventDefault();
    
    openModalItemContrato();
})

$('input[name=tipo_solicitacao]').on('change', function () {

    checkContrato();
    //changeTipoSolicitacao();
    //limpatblItensSolicitacao();

})

function limpatblItensSolicitacao(){

  
    $('#tblItensSolicitacao tbody tr').not(':first').each(function (count, tr) {

        fnWdkRemoveChild(tr);
        refreshSequenceItems();
    });

    $('#tblRateio tbody tr').not(':first').each(function (count, tr) {

        fnWdkRemoveChild(tr);

    });

}

function limpaProdutoAdd() {
    $("#produto_codigo_add").val("");
    $("#produto_descricao_add").val("");
    $("#produto_un_add").val("");
    $("#produto_quantidade_add").val("");

    acProduto.removeAll();
    selectedacProduto = {};
}

function limpaLocalEntrega() {

    $("#local_estoque_codigo").val("");
    $("#filial").val("");
    $("#cliente_nome").val("");
    $("#entrega_endereco").val("");
    $("#entrega_cidade").val("");
    $("#cnpj_filial_vivante").val("");

}

function verificaItemContratual(codigoColigada,codigoUnidade,codigoProduto,id){

    console.clear();
    console.log("Entrou verificação item contratual");
      //Monta as constraints para consulta
      var constraints   = new Array();
      constraints.push(DatasetFactory.createConstraint("CODCOLIGADA", codigoColigada, codigoColigada, ConstraintType.MUST));
      constraints.push(DatasetFactory.createConstraint("CODCCUSTO", "%."+codigoUnidade+".%", "%."+codigoUnidade+".%", ConstraintType.SHOULD,true));
      constraints.push(DatasetFactory.createConstraint("CODCCUSTO_CONTRATO", "%."+codigoUnidade+".%", "%."+codigoUnidade+".%", ConstraintType.SHOULD,true));
      constraints.push(DatasetFactory.createConstraint("CODIGOPRD", codigoProduto, codigoProduto, ConstraintType.MUST));
      constraints.push(DatasetFactory.createConstraint("TIPO_CONTRATO", "100", "100", ConstraintType.SHOULD));
      constraints.push(DatasetFactory.createConstraint("TIPO_CONTRATO", "02", "02", ConstraintType.SHOULD));
       
      //Define os campos para ordenação
      var sortingFields = new Array();
       
      //Busca o dataset
      var dataset = DatasetFactory.getDataset("rm_consulta_contrato_item", null, constraints, sortingFields);
       
      console.log("Dataset constraints");
      console.log(constraints);

      console.log("Dataset retorno");
      console.log(dataset);

      if(dataset.values.length > 0){
         $("#produto_contratual___"+id).val("S");

        
       
        return true;
      }  else {
          return false;
        } 

      


}

///////////////////////////////////

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
                if (source == "finalidade")
                matches = buscarFinalidade(q)
                
            cb(matches);
        }, 500);
    };
};

/*function centroCustoAutorizado() {
    var returnList = [];

    var codusuario = $("#codusuario_solicitante").val();
    var c0 = DatasetFactory.createConstraint("FLUIG_LOGIN", codusuario, codusuario, ConstraintType.MUST);
    var constraints = new Array(c0);

    var dataset = DatasetFactory.getDataset("rm_consulta_centro_custo_usuario", null, constraints, null);

    if (dataset) {
        returnList = dataset.values;
    }

    return returnList;
}*/

function buscarCentroCusto(parametro) {

    console.log("## Buscar Centro de Custo ")

    var returnList = [];
    var constraints = new Array();
    var coligada   = $("#empresa_codigo").val();
    var usuario = $("#codusuario_rm").val();

    constraints.push(DatasetFactory.createConstraint("sqlLimit", "100", "100", ConstraintType.MUST));
    constraints.push(DatasetFactory.createConstraint("CODCOLIGADA", coligada,coligada, ConstraintType.MUST, false));
    //constraints.push(DatasetFactory.createConstraint("CODCCUSTO", "%" + parametro + "%", "%" + parametro + "%", ConstraintType.SHOULD, true));
    constraints.push(DatasetFactory.createConstraint("COD_UNIDADE", $("#unidade_codigo").val(), $("#unidade_codigo").val(), ConstraintType.MUST));
    constraints.push(DatasetFactory.createConstraint("CODUSUARIO", usuario, usuario, ConstraintType.MUST));


    var dataset = DatasetFactory.getDataset("rm_consulta_centro_custo_usuario", null, constraints, null);
  
    console.log("## Buscar Centro de Custo CONSTRAINTS ");
    console.table(constraints);

    if (dataset) {
        returnList = dataset.values;
      //  console.table(returnList)
    }

    return returnList;
}

function buscarLocalEstoque(parametro) {

    var returnList = [];


    var c0 = DatasetFactory.createConstraint("sqlLimit", "50", "50", ConstraintType.MUST);
    var c1 = DatasetFactory.createConstraint("CODUNI", "%" +  $("#ccusto_codigo").val().substring(8, 12) + "%", "%" + $("#ccusto_codigo").val().substring(8, 12) + "%", ConstraintType.MUST, true);
    var c2 = DatasetFactory.createConstraint("CODLOC", "%" + parametro + "%", "%" + parametro + "%", ConstraintType.SHOULD, true);
    var c3 = DatasetFactory.createConstraint("NOME", "%" + parametro + "%", "%" + parametro + "%", ConstraintType.SHOULD, true);
    var c4 = DatasetFactory.createConstraint("FILIAL_VIVANTE", "%" + parametro + "%", "%" + parametro + "%", ConstraintType.SHOULD, true);
    var c5 = DatasetFactory.createConstraint("CODCOLIGADA", $("#empresa_codigo").val(),$("#empresa_codigo").val(), ConstraintType.MUST);

    var constraints = new Array(c0, c1, c2, c3, c4, c5);

    var dataset = DatasetFactory.getDataset("rm_consulta_locais_de_estoque_ws", null, constraints, null);

    if (dataset) {
        returnList = dataset.values;
    }

    return returnList;
}

function buscarProduto(parametro) {

    var returnList = [];

    var codcoligada = $("#codcoligada").val();
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

function buscarProdutoFinalidade(codigoFinalidade) {

    var returnList = [];

    var constraints = new Array();
   
    constraints.push(DatasetFactory.createConstraint("CODFINALIDADE", codigoFinalidade,codigoFinalidade, ConstraintType.MUST));

    var dataset = DatasetFactory.getDataset("rm_consulta_compras_finalidade_produto", null, constraints, null);

    if (dataset) {
        returnList = dataset.values;
    }

    return returnList;


}

function buscarContrato(parametro) {

    var returnList = [];

    var coligada = $("#empresa_codigo").val();
    var codusuario = $("#codusuario_rm").val();

    var c1 = DatasetFactory.createConstraint("CODCOLIGADA", coligada, coligada, ConstraintType.MUST);
    var c2 = DatasetFactory.createConstraint("CODUSUARIO", codusuario, codusuario, ConstraintType.MUST);
    var c3 = DatasetFactory.createConstraint("CODTCN", "100", "100", ConstraintType.MUST);


    var constraints = new Array(c1,c2,c3);

    var dataset = DatasetFactory.getDataset("rm_consulta_contrato_usuario", null, constraints, null);

    if (dataset) {
        returnList = dataset.values;
    }

    console.log("Consulta Contrato")
    console.table(returnList);

    return returnList;
}


function buscarContratoItens() {

    var returnList = [];

    var coligada = $("#empresa_codigo").val();
    var contrato = $("#contrato_codigo").val();

    var c1 = DatasetFactory.createConstraint("CODCOLIGADA", coligada, coligada, ConstraintType.MUST);
    var c2 = DatasetFactory.createConstraint("CODIGOCONTRATO", contrato, contrato, ConstraintType.MUST);

    var constraints = new Array(c1,c2);

    var dataset = DatasetFactory.getDataset("rm_consulta_contrato_item", null, constraints, null);

    if (dataset) {
        returnList = dataset.values;
    }

    console.log("Consulta Contrato ITENS")
    console.table(returnList);

    return returnList;
}

function buscarItemContrato(codProduto) {

    var returnList = [];

    var coligada = $("#empresa_codigo").val();
    var contrato = $("#contrato_codigo").val();

    var c1 = DatasetFactory.createConstraint("CODCOLIGADA", coligada, coligada, ConstraintType.MUST);
    var c2 = DatasetFactory.createConstraint("CODIGOCONTRATO", contrato, contrato, ConstraintType.MUST);
    var c3 = DatasetFactory.createConstraint("CODIGOPRD", codProduto, codProduto, ConstraintType.MUST);
    
    var constraints = new Array(c1,c2,c3);

    var dataset = DatasetFactory.getDataset("rm_consulta_contrato_item", null, constraints, null);

    if (dataset) {
        returnList = dataset.values;
    }

    console.log("Consulta ITEM Contrato")
    console.log(returnList);

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

function buscarFinalidade(parametro) {

    var returnList = [];

    var codunidade = $("#unidade_codigo").val();

    var constraints = new Array();

    constraints.push(DatasetFactory.createConstraint("CODUNI", "%."+codunidade, "%."+codunidade, ConstraintType.MUST,true));
    constraints.push(DatasetFactory.createConstraint("INATIVO", false, false, ConstraintType.MUST));

    var dataset = DatasetFactory.getDataset("rm_consulta_compras_finalidade", null, constraints, null);

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

    var order = new Array("COD_UNIDADE");

    var dataset = DatasetFactory.getDataset("rm_consulta_usuario_unidade", null, constraints, order);

    if (dataset) {
        returnList = dataset.values;
    }

    return returnList;

}

function makeid() {
    var text = "";
    var possible = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";

    for (var i = 0; i < 5; i++)
        text += possible.charAt(Math.floor(Math.random() * possible.length));

    return text;
}

function addItemTable(produto, quantidade,exclusivo) {
    var id = wdkAddChild('tblItensSolicitacao');

    var item = produto;


    $('#uid_item___' + id).val(makeid());
    $('#produto_codigo___' + id).val(item.CODIGOPRD);
    $('#produto_descricao___' + id).val(item.DESCRICAO);
    $('#produto_un___' + id).val(item.CODUNDCOMPRA);
    $('#produto_quantidade___' + id).val(quantidade);
    $('#ccusto_codigo_item___' + id).val($("#ccusto_codigo").val());
    $('#ccusto_nome_item___' + id).val($("#ccusto_nome").val());
    $('#itemfamily___' + id).val(item.ITEMFAMILY);
    $('#itemcontrl___' + id).val(item.ITEMCONTRL);
    $('#produto_codtborcamento___' + id).val(item.CODTBORCAMENTO);
    $('#produto_tipo___' + id).val(item.TIPO);
    $('#produto_codtb2fat___' + id).val(item.CODTB2FAT);
    $('#produto_codtb1fat___' + id).val(item.CODTB1FAT);
    $('#produto_id___' + id).val(item.IDPRD);
    $('#produto_contrato_idcnt___' + id).val(item.IDCNT);
    $('#produto_contrato_nseqitmcnt___' + id).val(item.NSEQITMCNT);

    if(item.CUSTOMEDIO){
        $('#produto_preco___'+id).val(item.CUSTOMEDIO.toFixed(4));
        $('#produto_total___'+id).val((parseFloat(item.CUSTOMEDIO.toFixed(4)) * parseFloat(quantidade)).toFixed(4));
        console.log("Preço >>> ",parseFloat(item.CUSTOMEDIO.toFixed(4)) * parseFloat(quantidade));
        }
    exclusivo ? $("#produto_exclusivo___"+id).val("S") : false;

    var contratual = verificaItemContratual($("#codcoligada").val(),$("#unidade_codigo").val(),item.CODIGOPRD,id);

    if(!contratual){
     
    }
    if(!exclusivo && !contratual){
        $("#produto_normal___"+id).val("S");
       
    }




 
    limpaProdutoAdd();
    refreshSequenceItems();

    setLabelProduto();

    MaskEvent.init();
    atualizaPreco();
}

function CallValidationForm() {


    for (var i = 0; i < myFORM.elements.length; i++) {
        var e = myFORM.elements[i];
        // console.log(e.name+"="+e.value);

        if ($(e).attr("data-validation") || $(e).is(":visible")) {

            $("#" + e.id).validate(function (valid, elem) {

                if (!valid) {
                    //    console.log($(e));
                }
                //  console.log('Element ' + elem.name + ' is ' + (valid ? 'valid' : 'invalid'));
            });
        }
    }

}

function validateAll()
  {
    errors={};
    validationErrors = [];

    $('input,textarea').validate(function(valid, elem) {
    
       // console.log("### Log erros "+elem.name + " is "+valid);


        if(!valid){
            validationErrors.push(elem.name);
        }
        
     });

     errors = validationErrors;
   //  console.log("### Log erros");
    // console.dir(errors);
  }

$("#btnAddItem").click(function (event) {

    event.preventDefault();

    var produto = selectedacProduto;
    var quantidade = $("#produto_quantidade_add").val();

    console.log(produto);

    if (!jQuery.isEmptyObject(produto) && quantidade) {
        addItemTable(produto, quantidade,false);
    } else {
        FLUIGC.toast({
            title: '',
            message: 'É necessário informar item e quantidade.',
            type: 'warning'
        });
    }





});

function countChildItems() {
    var quantidade = $("table[tablename='tblItensSolicitacao'] tbody tr").length;
    quantidade = quantidade - 1;

    return quantidade;
}

function refreshSequenceItems() {
    var index = 0;
    $("table[tablename='tblItensSolicitacao'] tbody tr").each(function () {


        $(this).find("td input[name^='item_seq_']").val(index);


        index++;
    })
}

function showModalDetalheItem(el) {

   
    var id = $(el).closest('tr').find("td input[name*='item_seq___']").attr("name").split("___")[1];
    var produto_codigo = $("#produto_codigo___" + id).val();
    var produto_descricao = $("#produto_descricao___" + id).val();
    var ccusto_codigo_item = $("#ccusto_codigo_item___" + id).val();
    var ccusto_nome_item = $("#ccusto_nome_item___" + id).val();
    var produto_familia = $("#itemfamily___"+id).val();
    var produto_itemcontrl = $("#itemcontrl___"+id).val();

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
            <input type="text" class="form-control" readonly>
    </div>
    <div class="form-group col-md-3">
            <label>Estoque Mínimo</label>
            <input type="text" class="form-control" readonly>
    </div>
    <div class="form-group col-md-3">
            <label>Estoque Máximo</label>
            <input type="text" class="form-control" readonly>
    </div>
    <div class="form-group col-md-3">
            <label>Ponto de Pedido</label>
            <input type="text" class="form-control" readonly>
    </div>
    <div class="form-group col-md-6">
            <label>Família</label>
            <input type="text" class="form-control" value="${produto_familia}" readonly>
    </div>
    <div class="form-group col-md-6">
    <label>Controle - Síndico</label>
    <input type="text" class="form-control" value="${produto_itemcontrl}"readonly>
</div>`

    var modal_detalhe_item = FLUIGC.modal({
        title: "Detalhe do Item",
        content: htmlmodal,
        id: 'fluig-modal',
        size:"large",
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


$('[data-open-modal]').click(function(){
    console.log("ClickOk");

    $("#ccusto_codigo_item___" + id).val($("#ccusto_codigo_itemModal").val());
    $("#ccusto_nome_item___" + id).val($("#ccusto_nome_itemModal").val());

    modal_detalhe_item.remove();


})







    
  var   acCentroCustoItem = FLUIGC.autocomplete('#ccusto_nome_itemModal', {
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
    console.log(target);

    if(target == "acCentroCusto_itemModal" )
    {
        acCentroCustoItem.val("%");
        $("#ccusto_nome_itemModal").focus();
        acCentroCustoItem.open();
    }

});


}

function checkFinalidadeEspecifica(){

    var checked = $("#finalidade_especifica").is(":checked");

 

    if(checked){
        $("#finalidade_compra").prop("disabled",false);
        $("[data-btn-zoom-autocomplete='acFinalidadeCompra']").show();
        $("#finalidade_compra").attr("data-validation","required");
        $("#finalidade_compra").validate();
       
    } else {
        $("#finalidade_compra").prop("disabled",true);
        $("[data-btn-zoom-autocomplete='acFinalidadeCompra']").hide();
        $("#finalidade_compra").attr("data-validation","");
        resetFinalidadeCompra();
        $("#finalidade_compra").validate();
    }

}

$(document).on("change","#finalidade_especifica",function(event){

    console.log(event.type)

    checkFinalidadeEspecifica();

    removeItensExclusivo();
})

function removeItensExclusivo(){

    $('#tblItensSolicitacao tbody tr').not(':first').each(function (count, tr) {

        var exclusivo = $(tr).find("input[name^='produto_exclusivo_']").val();

        if(exclusivo=="S"){
            fnWdkRemoveChild(tr);
            refreshSequenceItems();
        }

    });


}

function setLabelProduto(){

    $('#tblItensSolicitacao tbody tr').not(':first').each(function (count, tr) {

        var exclusivo = $(tr).find("input[name^='produto_exclusivo_']").val();
        var contratual = $(tr).find("input[name^='produto_contratual_']").val();

        exclusivo  == "S" ?  $(this).find("[data-label-item-exclusivo]").show() : false;
        contratual == "S" ?  $(this).find("[data-label-item-contratual]").show() : false;
 
    });
}

function atualizaPreco() {
	var totalItens = 0;
    $("input[name^='produto_codigo___']").each(function () {
    	var id             = $(this).attr("id").split("___")[1];
    	var codProduto     = $(this).val();
    	var prodContratual = $("#produto_contratual___" + id).val();
    	var quantidade     = $("#produto_quantidade___" + id).val();
    	
    	var contrato_codigo = $("#contrato_codigo").val();

    	if (prodContratual == 'S' && contrato_codigo.trim() != '') {
        	var dadosProd = buscarItemContrato(codProduto);
        	var precoProd = dadosProd[0].PRECOFATURAMENTO;
            $('#produto_preco___' + id).val(precoProd.toFixed(4));
            $('#produto_total___' + id).val((parseFloat(precoProd.toFixed(4)) * parseFloat(quantidade)).toFixed(4));
            MaskEvent.init();
    	}
    	
        var totItemRow = $('#produto_total___' + id).val().split(".").join("").split(",").join(".");
        totalItens = parseFloat(totalItens) + parseFloat(totItemRow);
    });
    
    $("#total_itens").val(parseFloat(totalItens.toFixed(4)));
    MaskEvent.init();
}

$(document).on("change",".calculavel",function(){
	var id         = $(this).attr("name").split("___")[1];
	var quantidade = $("#produto_quantidade___"+id).val().replace(".","").replace(",",".");
	var preco      = $("#produto_preco___"+id).val().replace(".","").replace(",",".");
	var total      = preco * quantidade;

	$("#produto_total___"+id).val(total.toFixed(4));
    
	MaskEvent.init();
 
	atualizaPreco();
})