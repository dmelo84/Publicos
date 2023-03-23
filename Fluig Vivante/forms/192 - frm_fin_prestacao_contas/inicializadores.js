var errors ={};

function init() {


    //numeral.locale('pt-br');

    verificaOrigemRecurso();
    

    initMask();

    loadValidation();

    setTimeout(validateAll, 1000);

    if(!Mobile){

        $("input[type=date]").each(function(){
        
          //  var valor = $(this).val();
          //  $(this).prop("type", "text");
          //  $(this).val(valor);
        })
        
        }

};


var loadValidation = function () {
    $.validate({

        validateOnBlur: true,
        validateHiddenInputs: false,
        dateFormat: 'dd/mm/yyyy',
        decimalSeparator: ",",
        inputParentClassOnError :'has-error' ,
        //addValidClassOnAll : true,
        onModulesLoaded: function () {},
        onElementValidate: function (valid, $el, $form, errorMess) {
         //   console.log('Input ' + $el.attr('name') + ' is ' + (valid ? 'VALID' : 'NOT VALID'));
        }
    });

    $.formUtils.addValidator({
        name : 'data_prestacao_contas',
        validatorFunction : function(value, $el, config, language, $form) {
    
            var nomeInput = $el.get(0).name;

            
            var dataInicial =converteData($("#periodo_inicial").val()); ;
            var dataFinal = converteData($("#periodo_final").val())
            var dataEmissao =converteData($("#data_emissao").val())

          return dataFinal >= dataEmissao && dataInicial <= dataFinal && dataInicial != "" && dataFinal != "";
        },
        errorMessage : 'You have to answer with an even number',
        errorMessageKey: 'badEvenNumber'
      });
      
    $.formUtils.addValidator({
        name: 'cnpj',
        validatorFunction: function (value, $el, config, language, $form) {

            cnpj = value.replace(/[^\d]+/g, '');

            if (cnpj == '') return false;

            if (cnpj.length != 14)
                return false;

            // Elimina CNPJs invalidos conhecidos
            if (cnpj == "00000000000000" ||
                cnpj == "11111111111111" ||
                cnpj == "22222222222222" ||
                cnpj == "33333333333333" ||
                cnpj == "44444444444444" ||
                cnpj == "55555555555555" ||
                cnpj == "66666666666666" ||
                cnpj == "77777777777777" ||
                cnpj == "88888888888888" ||
                cnpj == "99999999999999")
                return false;

            // Valida DVs
            tamanho = cnpj.length - 2
            numeros = cnpj.substring(0, tamanho);
            digitos = cnpj.substring(tamanho);
            soma = 0;
            pos = tamanho - 7;
            for (i = tamanho; i >= 1; i--) {
                soma += numeros.charAt(tamanho - i) * pos--;
                if (pos < 2)
                    pos = 9;
            }
            resultado = soma % 11 < 2 ? 0 : 11 - soma % 11;
            if (resultado != digitos.charAt(0))
                return false;

            tamanho = tamanho + 1;
            numeros = cnpj.substring(0, tamanho);
            soma = 0;
            pos = tamanho - 7;
            for (i = tamanho; i >= 1; i--) {
                soma += numeros.charAt(tamanho - i) * pos--;
                if (pos < 2)
                    pos = 9;
            }
            resultado = soma % 11 < 2 ? 0 : 11 - soma % 11;
            if (resultado != digitos.charAt(1))
                return false;

            return true;
        },
        errorMessage: 'You have to answer with an even number',
        errorMessageKey: 'badEvenNumber'
    });

      

}

function converteData(data){

    var dataConvertida = data;
    var dataSplit = dataConvertida.split("/");

    dataSplit.length > 1 ? dataConvertida = dataSplit[2]+"-"+dataSplit[1]+"-"+dataSplit[0]  :dataConvertida;

    return dataConvertida;

}

function validateAll()
  {
    errors={};
    var validationErrors = [];

    $('input,textarea,select,radio').validate(function(valid, elem) {
    
        if(!valid){
            validationErrors.push(elem.name.split("___")[0]);
        }
        
     });


    var um = $("#unidade_nome").val();
    var dois = $("#unidade_nome")


    errors = validationErrors;

    if (!$("#unidade_nome").val())
        errors.push("unidade_nome")

    if (!$("#favorecido_nome").val())
        errors.push("favorecido_nome")

    if (!$("#ccusto_nome").val())
        errors.push("ccusto_nome")



    

 
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