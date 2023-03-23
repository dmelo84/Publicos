var selectedCCusto_rat = {};

var rateio = {
    modal: {},
    uid_despesa: "",
    adicionar: function (el, event, row) {

        event.preventDefault();
        var tabela = $("[data-table-rateio]");

        //var ccusto_codigo = $(row).find("input[name^=tblRat_ccusto___]").val() || "";
        var ccusto_nome = $(row).find("input[name^=tblRat_ccusto_nome___]").val() || "";
        var valor = $(row).find("input[name^=tblRat_valor___]").val() || "";
        var percent = $(row).find("input[name^=tblRat_percent___]").val() || "";
        var ccusto_codccusto = $(row).find("input[name^=tblRat_ccusto_codigo___]").val() || "";

        if (row == "first") {

            ccusto_codigo = $("#ccusto_codigo").val();
            ccusto_codccusto = $("#ccusto_codigo").val();
            ccusto_nome = $("#ccusto_nome").val();
            valor = $("#rat_valor_base").val();
            percent = "100,00";

        }


        var idRateio = makeid();

        var drow = `  
        <tr>
            <td>
                <div class="form-group">
                    <div class="input-group" id="">
                        <span class="input-group-addon fs-xs-space">
                        <input type="text" id="ccusto_codigo___${idRateio}" style="text-align:center; font-size: 11px;" name="ccusto_codigo___${idRateio}" size="18" value = "${ccusto_codccusto}"
                        class="fs-no-style-input" placeholder="" data-validation="required" data-validation-error-msg="É necessário informar o Centro de Custo."
                        readonly>
            </span>
            <input type="text" class="form-control" name="ccusto_nome___${idRateio}" id="ccusto_nome___${idRateio}" value = "${ccusto_nome}" placeholder="Digite para iniciar a pesquisa"
             data-validation="required" data-validation-error-msg="É necessário informar o Centro de Custo." />
            <span class="input-group-addon fs-xs-space fs-cursor-pointer" data-btn-zoom-autocomplete-modal="acCcusto">
                <span class="fluigicon fluigicon-xs fluigicon-pointer-down"></span>
            </span>
        </div>
    </div>
        </td>
        
        <td>

        <div class="input-group">

    <input type="text" data-validation="required" data-validation-error-msg="Informe o %" data-rateio-percent data-mask-percent class="form-control" name="rateio_percent___${idRateio}" id="rateio_percent___${idRateio}" value="${percent}" mask="#00.000.000.000.000,00">
    <span class="input-group-addon">%</span>
    </div>



           
        </td>
        <td>
            <button data-btn-add-rateio onclick="rateio.adicionar(this,event,null)" class="btn btn-default">+</button>
            <button onclick="rateio.remover(this,event)" class="btn btn-default">-</button>
        </td>
        <!--Informacoes ocultas-->
        <td>
            <input type="hidden" class="" name="id_tblRateio" id="id_tblRateio" placeholder="id_tblRateio">
        </td>
    </tr>
    `

        //  $(el).blur();

        $('#tbodyTblRateio').append(drow);

        rateio.calcula($("[data-rateio-percent]").last());
        rateio.totaliza();

        setAutoCompleteCc("ccusto_nome", idRateio);

        MaskEvent.init(); //Inicializa Máscara


        
    },
    remover: function (el, event) {
        event.preventDefault();
        $(el).closest('tr').not(':first-child').remove();
        rateio.totaliza();
    },
    exibeModal: function (el, event) {

        event.preventDefault();

        rateio.modal = FLUIGC.modal({
            title: 'Rateios',
            content: this.montaTabela(el),
            id: 'fluig-modal',
            autoClose: true,
            size: 'large',
            actions: [{
                'label': 'Ok',
                'bind': 'data-btnOk-rateio',
            }, {
                'label': 'Fechar',
                'autoClose': true
            }]
        }, function (err, data) {
            if (err) {
                // do error handling
            } else {

                //Pega UID (Unique ID) da despesa da TblDesp
                var uid = $(el).closest('tr').find("td input[name*='uid_item___']").val();

                //Verifica se já existem rateios registrados para a despesa com base no UID
                var contador = 0;

                $("table[tablename='tblRateio'] tbody tr").each(function () {


                    var uid_rat = $(this).find("td input[name*='tblRat_uid_item_']").val();
                    if (uid_rat == uid) {

                        contador = contador + 1;
                        rateio.adicionar(el, event, $(this));

                    }

                    //Se não encontrado rateios, monda primeira linha com 100% para o C.Custo do Movimento

                });

                if (contador == 0) {
                    rateio.adicionar(el, event, "first");
                }
            }
        });


    },
    montaTabela: function (el) {

        var tblDesp_valor = $(el).closest('tr').find("td input[name*='produto_total___']").val();
        var tblDesp_uid = $(el).closest('tr').find("td input[name*='uid_item___']").val();
        rateio.uid_despesa = tblDesp_uid;
        var html = `

        
        <input type="hidden" class="form-control" name="rat_uid" id="rat_uid" value="${tblDesp_uid}">
        <input type="hidden" class="form-control" name="rat_valor_base" id="rat_valor_base" placeholder="rat_valor_base" value = "${tblDesp_valor}">
        <div class="table-responsive">
        <table id="tbl" name="tbl" data-table-rateio  class="table table-layout-fixed">
            <thead>
                <th class="col-md-6">Centro de Custo</th>
              
                <th class="col-md-2">%</th>
                <th class="col-md-2"></th>
                <th></th>
            </thead>
            <tbody id="tbodyTblRateio">
       
            </tbody>
            <tfoot>
                <tr>
                    <td>Total</td>
                 
                    <td><input type="text" class="form-control" data-mask-percent name="rateio_total_percent" id="rateio_total_percent" readonly></td>
                    <td></td>
                    <td></td>
                </tr>
            </tfoot>
        </table></div>`;



        var idRateio = 0;

        return html;

    },
    calcula: function (element) {

        var tr = $(element).closest('tr');
        var valor_base = convertStringFloat($("#rat_valor_base").val() || 0);
        var valor = convertStringFloat($(tr).find("[data-rateio-valor]").val() || 0);
        var percent = convertStringFloat($(tr).find("[data-rateio-percent]").val() || 0);

        var parametro = $(element).attr("name").split("___")[0];


        if (parametro == "rateio_valor" && convertStringFloat(valor) > 0) {

            var calcula = (valor / valor_base) * 100;

            $(tr).find("[data-rateio-percent]").val(calcula.toFixed(2).toString().replace(".", ",")).maskMoney('mask');

        }
        if (parametro == "rateio_percent" && convertStringFloat(percent) > 0) {

            percent = (percent / 100);
            var calcula = percent * valor_base;

            $(tr).find("[data-rateio-valor]").val(calcula.toFixed(2).toString().replace(".", ",")).maskMoney('mask');
        }

        validateAll();
        rateio.totaliza();

    },
    totaliza: function () {

        var total_valor = 0;
        var total_percent = 0;

        $("#tbodyTblRateio tr").each(function () {


            var tr = $(this);

            var valor = convertStringFloat($(tr).find('[data-rateio-valor]').val() || 0);
            var percent = convertStringFloat($(tr).find('[data-rateio-percent]').val() || 0);

            total_percent += percent;
            total_valor += valor;

        });

        $("#rateio_total_valor").val(total_valor.toFixed(2).toString().replace(".", ",")).maskMoney('mask');
        $("#rateio_total_percent").val(total_percent.toFixed(2).toString().replace(".", ",")).maskMoney('mask');
    },
    gravar: function () {

        validateAll();
        
        $("#tbodyTblRateio").validate();

        var percentual = convertStringFloat($("#rateio_total_percent").val());
        var validacoes = $("#tbodyTblRateio").find( ".has-error" );

        var mensagem = "";

        if(percentual != 100)
            mensagem += 'O rateio não está 100% distribuído. \n';

        if(validacoes.length > 0){}
            mensagem += 'Verifique os campos obrigatórios. \n';

        if (percentual == 100 && validacoes.length == 0) {

            //Exclui os rateios existentes

            $("table[tablename='tblRateio'] tbody tr").not(':first').each(function () {

                var el = $(this);

                if (el) {
                    var id = $(el).find("td input[name*='tblRat_uid_item']").attr("name").split("___")[1];
                    var uid = $(el).find("td input[name*='tblRat_uid_item']").val();
                    var rat_uid = $("#rat_uid").val();

                    if (rat_uid == uid) {
                        fnWdkRemoveChild(this);
                    }
                }
            });

            //Adiciona os rateios em tela
            console.log("tbodyTblRateio")
            console.log($("#tbodyTblRateio tr"))
            $("#tbodyTblRateio tr").each(function () {


                var tr = $(this);

                var rat_uid = $("#rat_uid").val();
                var ccusto = $(tr).find("td input[name*='ccusto_codigo___']").val();
                var ccusto_codccusto = $(tr).find("td input[name*='ccusto_codigo___']").val();
                var ccusto_nome = $(tr).find("td input[name*='ccusto_nome___']").val();
                var valor = $(tr).find("td input[name*='rateio_valor___']").val();
                var percent = convertStringFloat($(tr).find('[data-rateio-percent]').val() || 0);

                var id = wdkAddChild("tblRateio");

                $("#tblRat_uid_item___" + id).val(rat_uid);
                //  $("#tblRat_ccusto___"+id).val(ccusto);
                $("#tblRat_ccusto_nome___" + id).val(ccusto_nome);
                //  $("#tblRat_valor___"+id).val(valor);
                $("#tblRat_percent___" + id).val(percent.toFixed(2));
                $("#tblRat_ccusto_codigo___" + id).val(ccusto_codccusto);



            });

            rateio.modal.remove();

        } else {

            FLUIGC.toast({
                title: 'Não foi possível salvar o rateio. ',
                message: mensagem,
                type: 'info',
                timeout: 2000 // The strings 'fast' and 'slow' can be supplied to indicate durations of 2000 and 6000 milliseconds, respectively. If the timeout parameter is omitted, the default duration of 4000 milliseconds is used.
            });

        }

    },
    removeRateioItem: function(uid_item){

        $("table[tablename='tblRateio'] tbody tr").not(':first').each(function () {

            var uid_item_rat = $(this).find("td input[name*='tblRat_uid_item']").val();

            if (uid_item_rat == uid_item) {
                fnWdkRemoveChild(this);
            }
      
        });
    }
};

$(document).on("keyup", "[data-rateio-valor],[data-rateio-percent]", function () {
    rateio.calcula($(this));
});

$(document).on("click", "[data-btnOk-rateio]", function () {
    rateio.gravar();



});


$(document).on("click", "[data-btn-zoom-autocomplete-modal]", function () {

    console.log("clicou");

    var el = $(this).parent().find("input[name*='ccusto_nome']");

    $(el).val("%");
    $(el).focus();



});




function setAutoCompleteCc(campo, id) {

    /// Autocomplete CCusto
    var acCcusto = FLUIGC.autocomplete("#ccusto_nome___" + id, {
        source: substringMatcher("centroCusto"),
        name: 'NOME_CCUSTO',
        displayKey: 'NOME_CCUSTO',
        tagClass: '',
        type: 'autocomplete', //'tagAutocomplete',
        autoLoading: false,
        maxTags: 1,
        allowDuplicates: false,
        tagMaxWidth: 400,
        templates: {
            suggestion: '<div><h6>{{CODCCUSTO}} - {{NOME_CCUSTO}}</h6><div>'
        }
    });

    acCcusto.on("fluig.autocomplete.selected", function (event) {

        selectedCCusto_rat = event.item;
        $("#ccusto_codigo___" + id).val(selectedCCusto_rat.CODCCUSTO);

        $(this).attr("readonly", false).blur();
        // resetCliente();



    });

    acCcusto.on("fluig.autocomplete.opened", function (event) {

        selectedCCusto_rat = {};
        //resetCCusto();

    });

    acCcusto.on("fluig.autocomplete.closed", function (event) {

        var value = $("#ccusto_codigo___" + id).val();
        if (!value) {
            //  resetCcusto();
        }
    });

}