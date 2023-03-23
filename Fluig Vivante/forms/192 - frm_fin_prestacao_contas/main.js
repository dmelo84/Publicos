var despesas = [];
$(document).ready(function () { 


    setTimeout(() => {
        carregamentoInicial();
    }, 120);


   // reloadZoomFilterValues('unidade_codigo', "CODCOLIGADA","1");
    

});

function carregamentoInicial(){
    var txtLog = $('#logForm');

    init();
    //empresaLoadSelect();
    carregaFinalidades();
    carregaDespesasIncluidas();
    apresentaAtributoFinalidade();
    bloqueiaPeriodo();
    //empresaLoadSelect();
    /*cCustoLoadSelect();
    unidadeLoadSelect();
    favorecidoLoadSelect()*/
    $(txtLog).val('carregado');

}

function validateZoomField(field){

    console.log("validateZoomField")
    console.log(field)

}

function setSelectedZoomItem(selectedItem) { 

    //console.log(selectedItem)


    console.log("Selecionou " + selectedItem.inputId)

    const codusuario = $("#codusuario_rm").val();
    const empresa_codigo = $("#empresa_codigo").val();

    if (selectedItem.inputId == "unidade_nome"){

        $("#unidade_codigo").val(selectedItem.COD_UNIDADE);

        window["ccusto_nome"].disable(false);
        reloadZoomFilterValues('ccusto_nome',`CODCOLIGADA,${empresa_codigo},CODUSUARIO,${codusuario},COD_UNIDADE,${selectedItem.COD_UNIDADE}`);
        
        window["favorecido_nome"].disable(false);
        reloadZoomFilterValues('favorecido_nome', `COD_UNIDADE,${selectedItem.COD_UNIDADE}`);


  

    }

    if (selectedItem.inputId == "ccusto_nome") {


        $("#ccusto_codigo").val(selectedItem.CODCCUSTO);

    }

    if (selectedItem.inputId == "favorecido_nome") {

        console.log("----------------------------------------------------")
        console.log(window["ccusto_nome"].getSelectedItems())
        console.log(selectedItem)

        $("#favorecido_codigo").val(selectedItem.CPF);

        $("#login_favorecido").val(selectedItem.LOGIN);
        $("#email_favorecido").val(selectedItem.EMAIL);
        $("#codusuario_favorecido").val(selectedItem.USERID);
        $("#login_favorecido").val(selectedItem.LOGIN);
        $("#codcfo_favorecido").val(selectedItem.CODCFO);
        $("#cgcfo_favorecido").val(selectedItem.CPF);
        $("#restrito_favorecido").val(selectedItem.RESTRITO);

        var gestor = favorecidoGestor(selectedItem.EMAIL);

        if (gestor.length > 0) {

            console.log("Favorecido é gestor ");
            console.table(gestor);

            $("#favorecidoGestorUnidade").val(gestor[0].UNIDADE);
            $("#favorecidoGestorPortfolio").val(gestor[0].PORTFOLIO);
            $("#favorecidoGestorDiretor").val(gestor[0].DIRETOR);
            $("#favorecidoGestorPresidente").val(gestor[0].PRESIDENTE);



        }

       
    }



}

function removedZoomItem(removedItem) {

    if (removedItem.inputId == "unidade_nome") {

        window['ccusto_nome'].clear(); 
        window["ccusto_nome"].disable(true);
        $("#ccusto_codigo").val("");
     
        window['favorecido_nome'].clear(); 
        window["favorecido_nome"].disable(true);
        $("#favorecido_codigo").val("");


        $("#unidade_codigo").val("");
        $("#login_favorecido").val("");
        $("#email_favorecido").val("");
        $("#codusuario_favorecido").val("");
        $("#codcfo_favorecido").val("");
        $("#cgcfo_favorecido").val("");
        $("#restrito_favorecido").val("");
        $("#login_favorecido").val("");
     
        
    }

    if (removedItem.inputId == "ccusto_nome") {
        $("#ccusto_codigo").val("");

    }

    if (removedItem.inputId == "favorecido_nome") {


        $("#favorecido_codigo").val("");
        $("#login_favorecido").val("");
        $("#email_favorecido").val("");
        $("#codusuario_favorecido").val("");
        $("#codcfo_favorecido").val("");
        $("#cgcfo_favorecido").val("");
        $("#restrito_favorecido").val("");
        $("#login_favorecido").val("");


    }

}


function favorecidoGestor(email) {


    console.log("Consultou se é gestor "+email)


    var returnList = [];
    //rm_consulta_usuario_aprovador_unidade
    var unidade = $("#unidade_codigo").val();

    var c1 = DatasetFactory.createConstraint("COD_UNIDADE", unidade, unidade, ConstraintType.MUST);
    var c2 = DatasetFactory.createConstraint("EMAIL", email, email, ConstraintType.MUST);
    var c3 = DatasetFactory.createConstraint("UNIDADE", "true", "true", ConstraintType.SHOULD);
    var c4 = DatasetFactory.createConstraint("PORTFOLIO", "true", "true", ConstraintType.SHOULD);
    var c5 = DatasetFactory.createConstraint("DIRETOR", "true", "true", ConstraintType.SHOULD);
    var c6 = DatasetFactory.createConstraint("PRESIDENTE", "true", "true", ConstraintType.SHOULD);

    var constraints = new Array(c1, c2, c3, c4, c5, c6);



    var dataset = DatasetFactory.getDataset("rm_consulta_usuario_aprovador_unidade", null, constraints, null);



    if (dataset) {

        returnList = dataset.values;


    }

    return returnList;
}



/*-----------------------------------------------------*/

function disablePullToRefresh() {
    return true;
}
/*
async function empresaExecuteGetDateset(){

    loading = FLUIGC.loading('[data-field-empresa]');
    loading.show();
    await empresaGetDataset().then((res)=>{

    }).finally(()=>{
        loading.hide();
    })

}

function empresaGetDataset() {

    return new Promise((resolve, reject) => {

        setTimeout(() => {
            try {

                var dataset = DatasetFactory.getDataset("rm_consulta_coligada", null, null, null);
                
                if (dataset) {

                    $("#empresa_json").text(JSON.stringify(dataset.values))

                    empresaLoadSelect();

                    resolve(dataset.values)

                }

            } catch (error) {reject(error)}
        }, 100);

    })
}
*/
function empresaLoadSelect() {

    console.log("Empresa Select Inicio")

    var empresa_json = $("textarea[name*='empresa_json']");
    var empresasObj = null;

    if ($(empresa_json).text() != ""){
        
        empresasObj = JSON.parse($(empresa_json).text(), "") || "";

    }
    

    if (!empresasObj){
        empresasObj = empresaGetDataset();
        
        setTimeout(() => {
        	window["ccusto_nome"].disable(true);
        	window["favorecido_nome"].disable(true);
		}, 1000);
    }

    for (var i = 0; i < empresasObj.length; i++) {
        
        var element = empresasObj[i];
        addSelectOption("empresa_codigo", element.CODCOLIGADA, element.NOME)
    }

    console.log("Empresa fim")

}

function empresaReset(){

    $("#empresa_codigo").empty().append('<option disabled selected value>Selecione</option>')
    $("#empresa_json").text("");
    
    unidadeReset();


}

$(document).on("change","#empresa_codigo",async function(){
    

    let empresa_nome = $("#empresa_nome");
    let empresa_codigo = $(this).val();
    var codusuario = $("#codusuario_rm").val();

    $(empresa_nome).val("");
    $(empresa_nome).val($(this).children("option:selected").text())
 
    //unidadeExecuteGetDateset();
    window["ccusto_nome"].disable(false);
     window["favorecido_nome"].disable(false);

    //reloadZoomFilterValues('unidade_nome', `CODCOLIGADA,${empresa_codigo},CODUSUARIO,${codusuario}`);

    
})

/*-----------------------------------------------------*/
/*
async function unidadeExecuteGetDateset() {

    loading = FLUIGC.loading('[data-field-unidade]');
    loading.show();

    unidadeReset();

    await unidadeGetDataset().then((res) => {

    }).finally(() => {

    
        loading.hide();
    })

}

function unidadeGetDataset() {

    return new Promise((resolve, reject) => {

        setTimeout(() => {
            try {


                var c1 = DatasetFactory.createConstraint("CODCOLIGADA", $("#empresa_codigo").val(), $("#empresa_codigo").val(), ConstraintType.MUST, true);
                var c2 = DatasetFactory.createConstraint("CODUSUARIO", $("#codusuario_rm").val(), $("#codusuario_rm").val(), ConstraintType.MUST);
                var constraints = new Array(c1,c2);

                var dataset = DatasetFactory.getDataset("rm_consulta_usuario_unidade", null, constraints, null);

                if (dataset) {

                    $("#unidade_json").text(JSON.stringify(dataset.values))

                    unidadeLoadSelect();

                    resolve(dataset.values)

                }

            } catch (error) { reject(error) }
        }, 100);

    })


}

function unidadeLoadSelect() {


    var unidade_json = $("textarea[name*='unidade_json']");
    let unidadeObj = null

    if ($(unidade_json).text() != "") {
        unidadeObj = JSON.parse($(unidade_json).text(), "") || "";
    }

    if (!unidadeObj){
        unidadeObj = unidadeGetDataset();
    }

    for (let i = 0; i < unidadeObj.length; i++) {

        const unidade = unidadeObj[i];
        addSelectOption("unidade_codigo", unidade.COD_UNIDADE, unidade.NOME)
    }

}

function unidadeReset() {

    $("#unidade_codigo").empty().append('<option disabled selected value>Selecione</option>')
    $("#unidade_json").text("");
    cCustoReset();
    favorecidoReset();

}
*/

/*
$(document).on("change", "#unidade_codigo", async function () {

    let unidade_nome = $("#unidade_nome");
    let empresa_codigo = $("#empresa_codigo").val();
    var codusuario = $("#codusuario_rm").val();

    $(unidade_nome).val("");
    $(unidade_nome).val($(this).children("option:selected").text())

    //let unidade_codigo = selectedItem["unidade_codigo"]
    //cCustoExecuteGetDateset();

    reloadZoomFilterValues('ccusto_codigo', 
   `CODCOLIGADA,${empresa_codigo},
    CODUSUARIO,${codusuario},
    COD_UNIDADE,${unidade_codigo}`);


  

})*/

/*-----------------------------------------------------*/

/*
async function cCustoExecuteGetDateset() {

    loading = FLUIGC.loading('[data-field-ccusto]', {
        textMessage: 'Carregando C.Custos...',
    })

    loading.show();

    cCustoReset();

    await cCustoGetDataset().then((res) => {

    }).finally(() => {
      
        loading.hide();
    })

}

function cCustoGetDataset() {


    var codusuario = $("#codusuario_rm").val();
    var coligada = $("#empresa_codigo").val();
    var unidade = $("#unidade_codigo").val()

    if (unidade != "") {
        return new Promise((resolve, reject) => {

            setTimeout(() => {
                try {

                    var codusuario = $("#codusuario_rm").val();
                    var coligada = $("#empresa_codigo").val();
                    var unidade = $("#unidade_codigo").val()

                    var constraints = new Array();

                    constraints.push(DatasetFactory.createConstraint("CODUSUARIO", codusuario, codusuario, ConstraintType.MUST));
                    constraints.push(DatasetFactory.createConstraint("CODCOLIGADA", coligada, coligada, ConstraintType.MUST, false));
                    constraints.push(DatasetFactory.createConstraint("COD_UNIDADE", unidade, unidade, ConstraintType.MUST));

                    var dataset = DatasetFactory.getDataset("rm_consulta_centro_custo_usuario", null, constraints, null);

                    if (dataset) {

                        $("#ccusto_json").text(JSON.stringify(dataset.values))

                        cCustoLoadSelect();

                        resolve(dataset.values)

                    }

                } catch (error) { reject(error) }
            }, 100);

        })
    }


}

function cCustoLoadSelect() {

    var ccusto_json = $("textarea[name*='ccusto_json']");
    var ccustoObj = null;

    if ($(ccusto_json).text() != ""){

        ccustoObj = JSON.parse($(ccusto_json).text(), "") || "";

    }

    if (!ccustoObj) {
        ccustoObj = cCustoGetDataset();
    }


    for (var i = 0; i < ccustoObj.length; i++) {

        var ccusto = ccustoObj[i];
        addSelectOption("ccusto_codigo", ccusto.CODCCUSTO, ccusto.NOME_CCUSTO)
    }

}

function cCustoReset() {

    $("#ccusto_codigo").empty().append('<option disabled selected value>Selecione</option>')
    $("#ccusto_json").text("");

}
*/

/*$(document).on("change", "#ccusto_codigo", async function () {

    let ccusto_nome = $("#ccusto_nome");

    $(ccusto_nome).val("");
    $(ccusto_nome).val($(this).children("option:selected").text())
    
    favorecidoExecuteGetDateset();

})*/

/*-----------------------------------------------------*/
/*
async function favorecidoExecuteGetDateset() {

    loading = FLUIGC.loading('[data-field-favorecido]');
    loading.show();

    favorecidoReset();

    await favorecidoGetDataset().then((res) => {

    }).finally(() => {
        loading.hide();
    })

}

function favorecidoGetDataset() {

    return new Promise((resolve, reject) => {

        setTimeout(() => {
            try {


                var unidade = $("#unidade_codigo").val();
                var constraints = new Array();
                    constraints.push(DatasetFactory.createConstraint("COD_UNIDADE", unidade, unidade, ConstraintType.MUST));

                var dataset = DatasetFactory.getDataset("rm_consulta_favorecido", null, constraints, ["NOME"]);

                if (dataset) {

                    $("#favorecido_json").text(JSON.stringify(dataset.values))

                    favorecidoLoadSelect();

                    resolve(dataset.values)

                }

            } catch (error) { reject(error) }
        }, 100);

    })


}

function favorecidoLoadSelect() {


    var favorecido_json = $("textarea[name*='favorecido_json']");
    var favorecidoObj = null
    //JSON.parse($("textarea[name*='favorecido_json']").text(), "");
    if ($(favorecido_json).text() != ""){

        favorecidoObj = JSON.parse($(favorecido_json).text(), "") || "";

    }

    if (!favorecidoObj){

        favorecidoObj = favorecidoGetDataset();

    }

    for (var i = 0; i < favorecidoObj.length; i++) {

        var favorecido = favorecidoObj[i];
        addSelectOption("favorecido_codigo", favorecido.CPF, favorecido.NOME.toUpperCase(),favorecido)
    }


    $("select[name*='favorecido_codigo']").val($("input[name*='cgcfo_favorecido']").val());
   

}

function favorecidoReset() {


	$("#login_favorecido").val("");
    $("#email_favorecido").val("");
    $("#codusuario_favorecido").val("");
    $("#codcfo_favorecido").val("");
    $("#cgcfo_favorecido").val("");
    $("#restrito_favorecido").val("");
    $("#login_favorecido").val("");
    


    $("#favorecido_codigo").empty().append('<option disabled selected value>Selecione</option>')
    $("#favorecido_json").text("");

}*/
/*
$(document).on("change", "#favorecido_codigo", function () {

	$("#login_favorecido").val("");
    $("#email_favorecido").val("");
    $("#codusuario_favorecido").val("");
    $("#codcfo_favorecido").val("");
    $("#cgcfo_favorecido").val("");
    $("#restrito_favorecido").val("");
    $("#nome_favorecido").val("");
    

    let selectedFavorecido = $(this).children("option:selected").data()

    console.log("CHange Favorecido")
    console.log(selectedFavorecido)


    $("#favorecido_codigo").validate();
    $("#login_favorecido").val(selectedFavorecido.login);
    $("#email_favorecido").val(selectedFavorecido.email);
    $("#codusuario_favorecido").val(selectedFavorecido.userid);
    $("#login_favorecido").val(selectedFavorecido.codusuario);
    $("#codcfo_favorecido").val(selectedFavorecido.codcfo);
    $("#cgcfo_favorecido").val(selectedFavorecido.cpf);
    $("#restrito_favorecido").val(selectedFavorecido.restrito);
    $("#nome_favorecido").val($(this).children("option:selected").text());


    var gestor = favorecidoGestor(selectedFavorecido.email);

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
    //carregaFinalidades();

    if (selectedFavorecido.RESTRITO) {



    }


})*/

/*-----------------------------------------------------*/


function addSelectOption(selectName, value, text,data=null) {

    let select = $("select[name*='" + selectName+"']")


    if (selectName == "favorecido_codigo")

    {
        $(select).append($('<option>', {
            value: value,
            text: text,
            'data-CPF': data.CPF,
            'data-EMAIL': data.EMAIL,
            'data-CODUSUARIO': data.LOGIN,
            'data-CODCFO': data.CODCFO,
            'data-CGCCFO': data.CGCCFO,
            'data-RESTRITO': data.RESTRITO,
            'data-USERID': data.USERID,

        }));
    } else {

        $(select).append($('<option>', {
            value: value,
            text: text,


        }));
    }

  

   
 






}

function bloqueiaPeriodo(){

    var temDespesa = $('#tblItemDespesa tbody tr').not(':first').length > 0 ? true : false;
    if(temDespesa){
        $("#periodo_final").attr("readonly",true);
        $("#periodo_inicial").attr("readonly",true);
    } else {
        $("#periodo_final").attr("readonly",false);
        $("#periodo_inicial").attr("readonly",false);
    }
}
$(document).on("change", "#periodo_final", function () {

    $("#periodo_inicial").validate();
    var txtLog = $('#logForm');

    if (txtLog.val() == ""){
        carregamentoInicial();
    }


   

});



$("[data-btn-imprimir]").click(function(){

    GerarRelatorioRM();

   /* var idmov = $("#idmov").val();

    if(idmov == ""){
        FLUIGC.message.alert({
            message: 'A prestação de contas ainda não foi liberada e integrada pela área Fiscal.',
            title: 'Não liberada',
            label: 'OK'
        }, function(el, ev) {
            //Callback action executed by the user...
             
            //el: Element (button) clicked...
            //ev: Event triggered...
             
            //this.someFunc();
        });

    } else {
    GerarRelatorioRM();
    }*/

})


$(document).on("change", "[data-finalidade]", function (){



    $("[data-atributos-finalidade]").empty(); //limpa apresentação dos atributos
    $("#id_finalidade").val("");
    $("#descricao_finalidade").val("");
    //Verifica se existem despesas registradas anteriormente
    var temDespesa = $('#tblItemDespesa tbody tr').not(':first').length > 0 ? true : false;

    var id_finalidade = $(this).children("option:selected").val();



  

    if(temDespesa){
        

        limpaDespesas();
        $("#id_finalidade").val(id_finalidade);
        $("#descricao_finalidade").val($("#finalidade option:selected").text());
        consultaDespesasFinalidade(id_finalidade);


    } else {
       
        $("#id_finalidade").val(id_finalidade);
        $("#descricao_finalidade").val($("#finalidade option:selected").text());
        consultaDespesasFinalidade(id_finalidade);

    }

    adicionaAtributoFinalidade(id_finalidade);
    apresentaAtributoFinalidade();

})


$("[data-tipo-despesa]").change(function () {

   


})

function limpaDespesas(){


    $('#tblItemDespesa tbody tr').not(':first').each(
        function (count, tr) {

            removeDespesa(tr);
              
        });

}

function addItem(tableName) {

    if(tableName == "tblItemDespesa"){

        //verificar se foi selecionado uma finalidade
        var temFinalidade = $('#finalidade').val() != "" ? true:false;
        var periodo_inicial = $("#periodo_inicial");
        var periodo_final = $("#periodo_final");
        var periodoIniciaDefinido = $(periodo_inicial).val() != "" ? true:false;
        var periodoFinalDefinido = $(periodo_final).val() != "" ? true:false;


        if(temFinalidade && periodoIniciaDefinido && periodoFinalDefinido){
        	
        	var campoVazio = false;
        	$("input[id^='data_despesa___'], select[id^='data_despesa___']").each(function(i, v){
        		var seqPF = $(this).attr("id").split("___")[1];
        		
        		if ($("#data_despesa___" + seqPF).val() == '' 
        			|| $("#tipo_despesa___" + seqPF).val() == ''
        				|| $("#quantidade___" + seqPF).val() == ''
        					|| $("#valor_unitario___" + seqPF).val() == '') {
        			campoVazio = true;
        		}
        	});
        	
        	if (campoVazio) {
        		FLUIGC.message.alert({
        			message: 'É necessário preencher todos os campos da Despesa.',
        			title: 'Inclusão de despesas',
        			label: 'Ok'
        		}, function(el, ev) {
                
        		});
        	} else {
                var id = wdkAddChild(tableName);
                
                atualizaSequenciaDespesas();
                
                carregaDespesas(id);
                
                $("#despesa_uid___" + id).val(FLUIGC.utilities.randomUUID());
                
                goToDespesa(id);

                $('#data_despesa___' + id).attr("min", converteData($(periodo_inicial).val()));
                $('#data_despesa___' + id).attr("max", converteData($(periodo_final).val()));

                bloqueiaPeriodo();

                initMask();
        	}

        } else {

            FLUIGC.message.alert({
                message: 'É necessário selecionar uma <strong>finalidade</strong> e definir o <strong>período</strong> do relatório.',
                title: 'Inclusão de despesas',
                label: 'Ok'
            }, function(el, ev) {
            
            });
        }

 

    }

    $("[data-valorDespesaItem]").focus(function () {
        $(this).blur()
    });
    MaskEvent.init();
}

$(document).on("change","[data-despesa-quantidade],[data-despesa-valor-unitario]",function(){

    var id = $(this).attr("name").split("___")[1];

    calculaTotalDespesa(id);
})

function calculaTotalDespesa(id){

    var qtd = convertStringFloat($("#quantidade___"+id).val());
    var vlr_unit = convertStringFloat($("#valor_unitario___"+id).val());
    var total = (qtd*vlr_unit) || 0.00;
    total = "R$ "+ total.toFixed(2).replace(".",",");

 

    $("#valor_despesa___"+id).val(total);



    calculaTotalGeralDespesa();
}


$("#valor_total_despesas").focus(function () {
    $(this).blur()
});

$("[data-valorDespesaItem]").focus(function () {
    $(this).blur()
});



function calculaTotalGeralDespesa(){

    var total=0;

    $('#tblItemDespesa tbody tr').not(':first').each(
        function (count, tr) {

        var id = $(this).find("td input[name^='seq_']").attr("name").split("___")[1];
        
        total +=convertStringFloat($("#valor_despesa___"+id).val());
      
        })

    $("#valor_total_despesas").val("R$ "+total.toFixed(2).replace(".",","))
    $("#valor_total_despesas").maskMoney(({
            prefix: 'R$ ',
            allowNegative: false,
            thousands: '.',
            decimal: ',',
            affixesStay: true,
            defaultZero: true,
        disabled:true
        }));


    $("#valor_total_despesas").attr('readonly', true);

}

function goToDespesa(id) {

    $('html,body').animate({
        scrollTop: $("#seq___" + id).offset().top - 30
    },
        'slow');
}

function anexarComprovanteDespesa(el){

    var id = $(el).closest("tr").find("input").first().attr("name").split("___")[1];

    var nome = $("#seq___"+id).val() + " - " +$("#despesa_descricao___"+id).val();

    if($("#despesa_descricao___"+id).val() == ""){

        FLUIGC.message.alert({
            message: 'É necessário selecionar uma <strong>despesa</strong> antes de anexar os comprovantes.',
            title: 'Despesa não selecionada',
            label: 'Ok'
        }, function(el, ev) {
        
        });

    } else{

        showCamera(nome);
    }

    

}

function showCamera(parameter) {
    JSInterface.showCamera(parameter);
}

function removeDespesa(el) {



    var id = $(el).closest("tr").find("input").first().attr("name").split("___")[1];

    removeAtributoDespesa(id);

   fnWdkRemoveChild(el);

   calculaTotalGeralDespesa();
   atualizaSequenciaDespesas();
   bloqueiaPeriodo();

}

function carregaFinalidades() {


    consultaDespesasFinalidade($("select[name*='finalidade']").val())

    //Limpa Seleção e campo
    /*var id_finalidade        = $("#id_finalidade").val();
    var descricao_finalidade = $("#descricao_finalidade").val();
    var favorecido_codigo = $("#favorecido_codigo").val();

    $('[data-finalidade]').find('option').remove();
    $('[data-finalidade]').append('<option disabled selected value>Selecione</option>');
    
    if(favorecido_codigo != ""){

    if (id_finalidade == "") {
        $("[data-finalidade]").trigger( "change");
        var finalidades = consultaFinalidades();

        for (var i = 0; i < finalidades.length; i++) {

            $('[data-finalidade]').append($('<option>', {
                value: finalidades[i].ID,
                text: finalidades[i].DESCRICAO
            }));

            consultaDespesasFinalidade(finalidades[i].ID);


        }
    } else {

        $('[data-finalidade]').append($('<option>', {
            value: id_finalidade,
            text: descricao_finalidade
        }));

        $('[data-finalidade]').val(id_finalidade);
        $('[data-finalidade]').attr("disabled", true);

        consultaDespesasFinalidade(id_finalidade);
    }
}*/

}

function consultaAtributoFinalidade(id_finalidade){

    //Monta as constraints para consulta
    var constraints = new Array();
    constraints.push(DatasetFactory.createConstraint("ID_FINALIDADE", id_finalidade, id_finalidade, ConstraintType.MUST));

    //Define os campos para ordenação
    var sortingFields = new Array("SEQUENCIA");

    //Busca o dataset
    var dataset = DatasetFactory.getDataset("rm_consulta_atributo_finalidade", null, constraints, sortingFields);

    if (dataset) {

        return dataset.values;

    }

}

function consultaAtributosDespesa(id_despesa) {


    //Monta as constraints para consulta
    var constraints = new Array();
    constraints.push(DatasetFactory.createConstraint("ID_DESPESA", id_despesa, id_despesa, ConstraintType.MUST));

    //Define os campos para ordenação
    var sortingFields = new Array("SEQUENCIA");

    //Busca o dataset
    var dataset = DatasetFactory.getDataset("rm_consulta_atributo_despesa", null, constraints, sortingFields);

    if (dataset) {

        return dataset.values;

    }
}

function consultaFinalidades() {

    console.log("#Consulta Finalidade");
    var retorno = [];

    var restrito_favorecido = parseInt($("#restrito_favorecido").val()) || 0;
    //Monta as constraints para consulta
    var constraints = new Array();

    console.log("#Consulta Finalidade restrito_favorecido "+restrito_favorecido);


        constraints.push(DatasetFactory.createConstraint("RESTRITO", restrito_favorecido, restrito_favorecido, ConstraintType.MUST));
  
    //  constraints.push(DatasetFactory.createConstraint("activeVersion", "true", "true", ConstraintType.MUST));

    //Define os campos para ordenação
    var sortingFields = new Array();

    //Busca o dataset
    var dataset = DatasetFactory.getDataset("rm_consulta_pcfinalidade", null, constraints, sortingFields);

    if (dataset) {
    
        retorno = dataset.values;
    }

    console.log("#Consulta Finalidade constraints ");
    console.log(constraints);

    console.log("#Consulta Finalidade retorno ");
    console.log(retorno);
    return retorno;
    /* for(var i = 0; i < dataset.rowsCount; i++) {
        log.info(dataset.getValue(i, "documentPK.documentId"));
    }
*/

}

function consultaDespesasFinalidade(id_finalidade) {

    console.log("consultaDespesasFinalidade id_finalidade " + id_finalidade)


    var coligada = $("#empresa_codigo").val();

    console.log("consultaDespesasFinalidade coligada " + coligada)
    var retorno = [];
    //Monta as constraints para consulta
    var constraints = new Array();
    constraints.push(DatasetFactory.createConstraint("ID_FINALIDADE", id_finalidade, id_finalidade, ConstraintType.MUST));
    constraints.push(DatasetFactory.createConstraint("CODCOLIGADA", coligada, coligada, ConstraintType.MUST));

    //Define os campos para ordenação
    var sortingFields = new Array();

    //Busca o dataset
    var dataset = DatasetFactory.getDataset("rm_consulta_pcdespesa", null, constraints, sortingFields);

    if (dataset) {

        retorno = dataset.values;
        despesas = dataset.values;
    }

    console.log("consultaDespesasFinalidade retorno")
    console.log(retorno)

    return retorno;
    /* for(var i = 0; i < dataset.rowsCount; i++) {
        log.info(dataset.getValue(i, "documentPK.documentId"));
    }
*/


}

function consultaDespesas(id_despesa) {


    var retorno = [];
    //Monta as constraints para consulta
    var constraints = new Array();
    constraints.push(DatasetFactory.createConstraint("ID", id_despesa, id_despesa, ConstraintType.MUST));

    //Define os campos para ordenação
    var sortingFields = new Array();

    //Busca o dataset
    var dataset = DatasetFactory.getDataset("rm_consulta_pcdespesa", null, constraints, sortingFields);

    if (dataset) {
        retorno = dataset.values;

    }

    return retorno;
    /* for(var i = 0; i < dataset.rowsCount; i++) {
        log.info(dataset.getValue(i, "documentPK.documentId"));
    }
*/


}

function carregaDespesas(id) {

    var despesa_id = $("#despesa_id___" + id).val();
    var despesa_descricao = $("#despesa_descricao___" + id).val();

    if (despesa_id == "") {
        for (var i = 0; i < despesas.length; i++) {

            $('#tipo_despesa___' + id).append($('<option>', {
                value: despesas[i].ID,
                text: despesas[i].DESCRICAO
            }));

        }
    } else {
//

    $("#tipo_despesa___" + id).find('option').remove();
    $("#tipo_despesa___" + id).append($('<option>', {
        value: despesa_id,
        text: despesa_descricao
    }));


    $("#tipo_despesa___" + id +" option[value='"+despesa_id+"']").attr('selected','selected');
    $("#tipo_despesa___" + id).val(despesa_id);
    $("#tipo_despesa___" + id).attr("disabled", true);




    }

}

function carregaDespesasIncluidas() {

    $('#tblItemDespesa tbody tr').not(':first').each(
        function (count, tr) {

        var id = $(this).find("td input[name*='seq_']").attr("name").split("___")[1];
        var uid = $("#despesa_uid___"+id).val();
        apresentaAtributoDespesa(uid);
        carregaDespesas(id);
        })

}

$(document).on('change','table',function(el,evt){

    var obj = el.target;
   $(obj).validate();

})

$(document).on("change", "[data-despesa]", function () {

    var id = $(this).attr("name").split("___")[1];
    var id_despesa = $(this).val();

    var despesa = consultaDespesas(id_despesa);

    $('#despesa_id___' + id).val(despesa[0].ID);
    $('#despesa_codigo___' + id).val(despesa[0].CODIGO);
    $('#despesa_codigoprd___' + id).val(despesa[0].CODIGOPRD);
    $('#despesa_descricao___' + id).val(despesa[0].DESCRICAO);
    $('#despesa_idprd___' + id).val(despesa[0].IDPRD);
    $('#despesa_codund___' + id).val(despesa[0].CODUNDCONTROLE);
    $('#despesa_codtborcamento___' + id).val(despesa[0].CODTBORCAMENTO);
    $('#despesa_controle___' + id).val(despesa[0].CONTROLE);
    $('#despesa_informadoc___' + id).val(despesa[0].INFORMADOC);

    

    if(despesa[0].VALOR_POLITICA > 0){

        $('#valor_unitario___' + id).val("R$ " + despesa[0].VALOR_POLITICA.toFixed(2).replace(".",","));
        $('#valor_unitario___' + id).attr("readonly",true);
    } else {
        $('#valor_unitario___' + id).val("");
        $('#valor_unitario___' + id).attr("readonly",false);
    }

    calculaTotalDespesa(id);
    
    adicionaAtributoDespesa(id);

    apresentaAtributoDespesa($('#despesa_uid___' + id).val());

    checkControleSindico();

});

function checkControleSindico(){

    $("#sindico_aprova").prop("checked",false);

    $("input[name^='despesa_controle___']").each(function(){

        var valor = $(this).val();
        if(valor != ""){
            $("#sindico_aprova").prop("checked",true);
        }

    })
}

function adicionaAtributoFinalidade(id){

    removeAtributoFinalidade();

    var atributos = consultaAtributoFinalidade(id);

    for(var i = 0; i < atributos.length; i++){

        var id = wdkAddChild('tblAtribFinalidade');

        $("#id_tblAtribFinalidade___" + id).val(atributos[i].ID);
        $("#descricao_tblAtribFinalidade___" + id).val(atributos[i].DESCRICAO);
        $("#finalidade_tblAtribFinalidade___" + id).val(atributos[i].FINALIDADE);
        $("#id_atributo_tblAtribFinalidade___" + id).val(atributos[i].ID_ATRIBUTO);
        $("#id_finalidade_tblAtribFin___" + id).val(atributos[i].ID_FINALIDADE);
        $("#sequencia_tblAtribFinalidade___" + id).val(atributos[i].SEQUENCIA);

        $("#tamanho_tblAtribFinalidade___" + id).val(atributos[i].TAMANHO);
        $("#tipo_dado_tblAtribFinalidade___" + id).val(atributos[i].TIPO_DADO);
        $("#valor_tblAtribFinalidade___" + id).val(atributos[i].VALOR);



    }

}


function adicionaAtributoDespesa(id) {

    removeAtributoDespesa(id);

    var id_despesa = $('#despesa_id___' + id).val();

    var atributos = consultaAtributosDespesa(id_despesa);

    for (var i = 0; i < atributos.length; i++) {

        var id_atrib = wdkAddChild('tblAtribItemDespesa');

        $("#despesa_uid_atrib___" + id_atrib).val($("#despesa_uid___" + id).val());
        $("#id_atributoItemDespesa___" + id_atrib).val(atributos[i].ID);
        $("#seqAttr_atributoItemDespesa___" + id_atrib).val(atributos[i].SEQUENCIA);
        $("#descricao_atributoItemDespesa___" + id_atrib).val(atributos[i].DESCRICAO_ATRIBUTO);
        $("#tipo_AtributoItemDespesa___" + id_atrib).val(atributos[i].TIPO_DADO);
        $("#tamanho_AtributoItemDespesa___" + id_atrib).val(atributos[i].TAMANHO);
        $("#valor_AtributoItemDespesa___" + id_atrib).val();


    }




}

function apresentaAtributoDespesa(uid) {

    var html = "";
    var seq_atr = 0;

    $('#tblAtribItemDespesa tbody tr').not(':first').each(
        function (count, tr) {
            seq_atr++;

            var despesa_uid_atrib = $(tr).find("input[name*='despesa_uid_atrib__']").val();
            
            var id = $(tr).find("input[name*='despesa_uid_atrib__']").attr("name").split("___")[1];
            var despesa_descricao = $("#despesa_descricao___"+id).val();
            var id_atribDesp = $("#id_atributoItemDespesa___" + id).val();
            var valor = $("#valor_AtributoItemDespesa___" + id).val();
            var tipo_campo = $("#tipo_AtributoItemDespesa___" + id).val();
            var tipoJs ="";
            switch (tipo_campo) {
                case "Texto":
                    tipoJs = "text" 
                    break;
                case "Data":
                    tipoJs = "date"
                    break;
                case "Decimal":
                    tipoJs = "number"
                    break;
                case "Inteiro":
                    tipoJs = "number"
                    break;
                default:
                    break;
            }
            
            if (despesa_uid_atrib == uid) {

                var descricao = $("#descricao_atributoItemDespesa___" + id).val();

                if(tipoJs != ""){
                html +=
                    `
                        <div class="form-group col-md-3 fs-no-padding-left">
                            <label for="atributo__${id_atribDesp}__${id}">${descricao}</label>
                            <input onchange="atualizaValorAtributo(this)" data-atributo type="${tipoJs}" name="atributo__${id_atribDesp}__${id}" 
                            id="atributo__${id_atribDesp}__${id}" class="form-control" value="${valor}" data-validation="required"  data-validation-error-msg-container="#">
                        </div>
                    `
                } else{
                    if(tipo_campo=="Anexo"){
                      html+=  `<button class="btn btn-primary" onclick="showCamera('${despesa_descricao}')" id="atributo__${id_atribDesp}__${id}" name="atributo__${id_atribDesp}__${id}">${descricao}</button>`
                        console.log(html);
                        console.log("HTML");
                    }
                }


            }

        });

    var id = localizaItemDespesaPeloUID(uid);
    var tr = $("input[name*='seq___" + id+"'").closest("tr");
    var divAtributo = $(tr).find("[data-atributos]");
    $(divAtributo).html('');
    $(divAtributo).html(html);

    /*Apresenta Campos Documentos Fiscal*/

    if ($("input[name*='despesa_informadoc___" + id + "'").val() == "true"){
        
        $(tr).find("[data-divDocumento]").show();
    } else {
        $(tr).find("[data-divDocumento]").hide();
    }


}

function apresentaAtributoFinalidade(){

    console.log("Apresentação Atributo Finalidade");
    console.log(WKNumState);

    var readonly = "";

    if(WKNumState != "" && WKNumState != 0 && WKNumState != 4 && WKNumState != 7  && WKNumState != 32  )
    {
        readonly="readonly"
    }
    
    

    var html = ""

    $('#tblAtribFinalidade tbody tr').not(':first').each(
        function (count, tr) {
            

            var despesa_uid_atrib = $(tr).find("input[name*='despesa_uid_atrib__']").val();
     
            var id = $(tr).find("input[name*='id_atributo_tblAtribFinalidade__']").attr("name").split("___")[1];

            var id_atribFin = $("#id_atributo_tblAtribFinalidade___" + id).val();
            var valor = $("#valor_tblAtribFinalidade___" + id).val();
            var tamanho = $("#tamanho_tblAtribFinalidade___" + id).val() || '3';
                tamanho > 12 ? tamanho = 4 : false;
            var tipo_campo = $("#tipo_dado_tblAtribFinalidade___" + id).val();
            var descricao = $("#descricao_tblAtribFinalidade___" + id).val();

            var tipoJs ="";
            switch (tipo_campo) {
                case "Texto":
                    tipoJs = "text" 
                    break;
                case "Data":
                    tipoJs = "date"
                    break;
                case "Decimal":
                    tipoJs = "number"
                    break;
                case "Inteiro":
                    tipoJs = "number"
                    break;
                default:
                    break;
            }
            
  


                

                if(tipoJs != ""){
                html +=
                    `
                        <div class="form-group col-md-${tamanho} fs-no-padding-left">
                            <label for="atributo__${id_atribFin}__${id}">${descricao}</label>
                            <input onchange="atualizaValorAtributoFinalidade(this)" data-atributo-finalidade type="${tipoJs}" name="atributo__${id_atribFin}__${id}" 
                            id="atributo__${id_atribFin}__${id}" class="form-control" value="${valor}" data-validation="required"  data-validation-error-msg-container="#" ${readonly}>
                        </div>
                    `
                }

                //var id = localizaItemDespesaPeloUID(uid);
               // var tr = $("input[name*='seq___" + id+"'").closest("tr");
               // var divAtributo = $(tr).find("[data-atributos]");
                
            
            

        });

        if(html != ""){
            html = "<h4><strong>Dados Adicionais da Finalidade</strong></h4> " + html;
        }
    
        $("[data-atributos-finalidade]").html(html);
}

$(document).on("change", "[data-recurso]", function () {

    verificaOrigemRecurso();

   
})

function verificaOrigemRecurso(){

    var recurso = $("[data-recurso]").val();

    if(recurso == "recurso_cartao_corporativo"){
        $("#DivRecurso").show('slow');

    } else {
        $("#DivRecurso").hide('slow');

    }



}

function atualizaValorAtributo(el){

    var id = $(el).attr("name").split("__")[2];
    var idAtribDesp = $(el).attr("name").split("__")[1];
    var valor = $(el).val();

    $("#valor_AtributoItemDespesa___"+id).val(valor);

}


function atualizaValorAtributoFinalidade(el){

    var id = $(el).attr("name").split("__")[2];
    //var idAtribDesp = $(el).attr("name").split("__")[1];
    var valor = $(el).val();

    $("#valor_tblAtribFinalidade___"+id).val(valor);

}

function localizaItemDespesaPeloUID(uid) {

    var retorno = 0;
    $('#tblItemDespesa tbody tr').not(':first').each(
        function (count, tr) {
            var despesa_uid_obj = $(tr).find("input[name*='despesa_uid__']");
            var despesa_uid = $(despesa_uid_obj).val();
            var id = $(despesa_uid_obj).attr("name").split("___")[1];

            if (despesa_uid == uid) {
                retorno = id;
            }

        });

    return retorno;
}

function removeAtributoDespesa(id_despesa) {

    var uid = $("#despesa_uid___" + id_despesa).val();

    $('#tblAtribItemDespesa tbody tr').not(':first').each(
        function (count, tr) {
            var despesa_uid_atrib = $(tr).find("input[name*='despesa_uid_atrib__']").val();
            var id = $(tr).find("input[name^='despesa_uid_atrib__']").attr("name").split("___")[1];

            if (despesa_uid_atrib == uid) {

                fnWdkRemoveChild(tr);

            }

        });


}


function removeAtributoFinalidade() {

 

    $('#tblAtribFinalidade tbody tr').not(':first').each(
        function (count, tr) {
       
                fnWdkRemoveChild(tr);

        });


}

function atualizaSequenciaDespesas() {

    var index = 0;
    $("table[tablename='tblItemDespesa'] tbody tr").each(function () {

        $(this).find("td input[name*='seq_']").val(index);
        index++;
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


