

function init() {

    FLUIGC.switcher.init('#ckb_investimento');

    loadValidation();

    setTimeout(validateAll, 1000);

    numeral.locale('pt-br');

    checkFinalidadeEspecifica();
}

var loadValidation = function () {
    $.validate({
        validateOnBlur: true,
        validateHiddenInputs: false,
        dateFormat: 'dd/mm/yyyy',
        decimalSeparator: ",",
        onModulesLoaded: function () {},
        onElementValidate: function (valid, $el, $form, errorMess) {
         //   console.log('Input ' + $el.attr('name') + ' is ' + (valid ? 'VALID' : 'NOT VALID'));
        }
    });
    $.formUtils.addValidator({
        name: 'data_necessidade',

        validatorFunction: function (value, $el, config, language, $form) {

            var retorno = true;

            idInput = $el.get(0).name;

            var dataSolicitacao = util.stringToDate($("#data_solicitacao").val());
            var dataNecessidade = util.stringToDate(value);

            if(dataNecessidade < dataSolicitacao){

                this.errorMessage = "A data da necessidade não pode ser inferior a data da solicitação."
                retorno =false;
            }

            if(!dataNecessidade){
                this.errorMessage = "Informe a data da necessidade."
                retorno =false;
            }

            if (value.toString().split("/").length != 3){
                this.errorMessage = "Informe a data da necessidade."
                retorno = false;
            }
            
           return retorno;

            
        },
        errorMessage: 'Verifique a Data',
        errorMessageKey: 'badEvenNumber'
    });


}


