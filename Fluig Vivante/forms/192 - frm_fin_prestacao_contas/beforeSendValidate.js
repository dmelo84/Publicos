var beforeSendValidate = function (numState, nextState) {

    var campos = "";

    $("#ccusto_codigo").prop('disabled', false);
    $("#ccusto_nome").prop('disabled', false);
    $("#unidade_codigo").prop('disabled', false);
    $("#unidade_nome").prop('disabled', false);

    var ativRetornadoGestor = 32;
    var ativRetornadoContabil = 29;
    var ativAprovacaoGestor = 15;
    var ativAprovacaoContabil = 22;


    validateAll();

  

    if(!$("#unidade_nome").val())
        campos += "* " + "Unidade" + "\n";

    if(!$("#favorecido_nome").val())
        campos += "* " + "Favorecido" + "\n";

    if(!$("#ccusto_nome").val())
        campos += "* " + "C.Custo" + "\n";


    if (errors.length > 0) {

        for (i = 0; i < errors.length; i++) {



            var label = $("label[for='" + errors[i] + "']").first().text();

            if (label != "")
                campos += "* " + label + "\n";


        }
    }

    var temDespesa = $('#tblItemDespesa tbody tr').not(':first').length > 0 ? true : campos += "* É necessário adicionar as despesas do relatório; \n";

    if (nextState == ativRetornadoContabil) {

        var justificativa = $("#justificativa_contabil").val();
        if (justificativa == "") {
            campos += "Justificativa parecer reprovado."
        }
    }


    if (retornaSO() != 'iOS'){

        try {

            var validaDocumentoFiscalDespesasRet = validaDocumentoFiscalDespesas();

            if (validaDocumentoFiscalDespesasRet != "") {

                campos += "Existem erros que impedem a gravação da solicitação – entre em contato com a equipe de contabilidade através do movidesk. \n";
                $("#notificarValidacaoDocumento").val("S");
            }

            
        } catch (error) {

            throw error
            
        }
    }
  
  
    if (campos != "") {
        throw "Favor verificar os seguintes campos obrigatórios: \n" + campos;
    }

}


function dataAtualFormatada() {
    var data = new Date();
    var dia = data.getDate();
    if (dia.toString().length == 1)
        dia = "0" + dia;
    var mes = data.getMonth() + 1;
    if (mes.toString().length == 1)
        mes = "0" + mes;
    var ano = data.getFullYear();
    return dia + "/" + mes + "/" + ano;
}

function validaDocumentoFiscalDespesas(){
    
    var msg = "";


    $('#tblItemDespesa tbody tr').not(':first').each(
        function (count, tr) {

            var id = $(this).find("td input[name*='seq_']").attr("name").split("___")[1];
          

            var seq          = $("#seq___" + id).val();
            var data_despesa = $("#data_despesa___" + id).val();
            var doc_numero   = $("#doc_numero___" + id).val();
            var doc_cnpj     = $("#doc_cnpj___" + id).val();

            
            if (doc_cnpj != ""){

            
                doc_cnpj = doc_cnpj.replaceAll(".","").replace("/","").replace("-","");//substitui pontuacoes, barras e traco

                if(existeDocumentoFiscalRM(data_despesa, doc_numero, doc_cnpj)){

                    msg += "Item " + seq + ", Documento " + doc_numero + ", CNPJ " + doc_cnpj;

                    $("#validacaoDocumentoMsg").val(msg);

                }
            }

         }
    )

    return msg;


}

function existeDocumentoFiscalRM(emissao,documento,cnpj){
	/*
    var retorno = false;
    var query =  "SELECT DATAEMISSAO, NUMEROMOV, REPLACE(REPLACE(REPLACE(FCFO.CGCCFO, '.', ''), '/', ''), '-', '') AS CGCCFO FROM TMOV (nolock) "
    query += "INNER JOIN FCFO (nolock) ON FCFO.CODCFO = TMOV.CODCFO "

    query += " WHERE CODTMV LIKE '1.2.%' AND ";
    query += " REPLACE(REPLACE(REPLACE(FCFO.CGCCFO, '.', ''), '/', ''), '-', '') LIKE '" + cnpj +"' AND";
    query += " NUMEROMOV LIKE '%"+documento+"' AND";
    query += " DATAEMISSAO = '" + emissao+"';";

    try {
   
        var constraints = new Array();
        constraints.push(DatasetFactory.createConstraint("pool-name", "CorporeRM", "CorporeRM", ConstraintType.MUST))
        constraints.push(DatasetFactory.createConstraint("consulta", query, query, ConstraintType.MUST))

        var dataset = DatasetFactory.getDataset("consulta_mssql", null, constraints, null);

        if(dataset.values.length > 0){
            retorno = true;
        }

    } catch (error) {

        throw error;
        
    }

    return retorno;
	*/
    var retorno = false;
    try {
        var constraints = new Array();
        constraints.push(DatasetFactory.createConstraint("cnpj", cnpj, cnpj, ConstraintType.MUST))
        constraints.push(DatasetFactory.createConstraint("documento", documento, documento, ConstraintType.MUST))
        constraints.push(DatasetFactory.createConstraint("emissao", emissao, emissao, ConstraintType.MUST))

        var dataset = DatasetFactory.getDataset("dsExisteDocFiscalRM", null, constraints, null);

        if(dataset.values.length > 0){
            retorno = true;
        }
    } catch (error) {
        throw error;
    }
    
    return retorno;
}

function retornaSO() {
    var userAgent = navigator.userAgent || navigator.vendor || window.opera;

    if (/windows phone/i.test(userAgent)) {
        return "Windows Phone";
    } else if (/android/i.test(userAgent)) {
        return "Android";
    } else if (/iPad|iPhone|iPod/.test(userAgent) && !window.MSStream) {
        return "iOS";
    } else {
        return "unknown";
    }
}

