function init() {


    numeral.locale('pt-br');

    checkEnableAddSolicitacao();

    checkFrete();

    loadBtnGroup();

    document.getElementById('data_limite').min = new Date(new Date().getTime() - new Date().getTimezoneOffset() * 60000).toISOString().split("T")[0];

    calculaTotaisTodosFornecedores();

    loadValidation();

    setTimeout(validateAll, 1000);

    initMask();

    getFiles();

};


var loadValidation = function () {
    $.validate({
        validateOnBlur: true,
        validateHiddenInputs: false,
        dateFormat: 'dd/mm/yyyy',
        decimalSeparator: ",",
        onModulesLoaded: function () {},
        onElementValidate: function (valid, $el, $form, errorMess) {
       //     console.log('Input ' + $el.attr('name') + ' is ' + (valid ? 'VALID' : 'NOT VALID'));
        }
    });
    $.formUtils.addValidator({
        name: 'data_necessidade',

        validatorFunction: function (value, $el, config, language, $form) {

            var retorno = true;

            idInput = $el.get(0).name;

            var dataSolicitacao = util.stringToDate($("#data_solicitacao").val());
            var dataNecessidade = util.stringToDate(value);

            if (dataNecessidade < dataSolicitacao) {

                this.errorMessage = "A data da necessidade não pode ser inferior a data da solicitação."
                retorno = false;
            }

            if (!dataNecessidade) {
                this.errorMessage = "Informe a data da necessidade."
                retorno = false;
            }

            if (value.toString().split("/").length != 3) {
                this.errorMessage = "Informe a data da necessidade."
                retorno = false;
            }

            return retorno;


        },
        errorMessage: 'Verifique a Data',
        errorMessageKey: 'badEvenNumber'
    });

}

function loadBtnGroup() {

    $("[data-toggle='buttons']").each(function () {
        $(this).find("input[type='radio']").each(function (e) {

            if ($(this).prop("checked")) {
                $(this).parent().addClass("active");
            } else {
                $(this).parent().removeClass("active");
            }
        })
    })
}

function getFiles() {

    $.ajax({
        async: true,
        type: "GET",
        contentType: "application/json",
        url: '/api/public/ecm/document/listDocumentWithChildren/1365',
        success: function (retorno) {
            $.each(retorno.content, function (k, v) {
                var objeto = new Object();
                objeto = v.children;
                for (var x = 0; x < objeto.length; x++) {
                    console.log("NOME DA PASTA " + objeto[x].description);
                }
            })
        }
    });



}

