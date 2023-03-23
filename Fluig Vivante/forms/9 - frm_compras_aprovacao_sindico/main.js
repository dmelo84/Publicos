
$(document).ready(function () {

    getCotacao();

    getUltimasCompras();


});


function getCotacao() {


    var nrocotacao = $("#cotacao_numero").val() || $("#cotacao_numero").text();
    var nroitem = $("#cotacao_item").val() || $("#cotacao_item").text();

    var c1 = DatasetFactory.createConstraint("NroCotacao", nrocotacao, nrocotacao, ConstraintType.MUST);
    var c2 = DatasetFactory.createConstraint("Item", nroitem, nroitem, ConstraintType.MUST);

    var constraints = new Array(c1, c2);

    var dsCotacao = DatasetFactory.getDataset("CP004_cotacoes_do_produto", null, constraints, null);

    console.log("dsCotacao")
    console.dir(dsCotacao);
    // console.dir(dataset);


    for (var i = 0; i < dsCotacao.values.length; i++) {

        /*	<tr >
        							<td>Fornecedor</td>
        							<td>Quantidade</td>
        							<td>Preço Original</td>
        							<td>Total Original</td>
        							<td>Preço Negociado</td>
        							<td>Total Negociado</td>
        						</tr> */

        var html = "";
        if (dsCotacao.values[i].Fornecedor) {
            html = `<tr >
                        <td>${dsCotacao.values[i].Fornecedor}</td>
                        <td>${dsCotacao.values[i].Quantidade}</td>`

            if (dsCotacao.values[i].PrecoOriginal) {

                html += `<td>${dsCotacao.values[i].PrecoOriginal}</td>
                     <td>${dsCotacao.values[i].TotalOriginal}</td>`
            } else {

                html += `<td colspan="2" class="text-center warning">Sem registro de negociação.</td>`
            }


            html += `    <td>${dsCotacao.values[i].PrecoNegociado}</td>
                     <td>${dsCotacao.values[i].TotalNegociado}</td>
                    </tr>`

        } else {
            html += `<td colspan="6" class="text-center warning">Sem registro de cotações.</td>`
        }
        $("#dadosCotacao").append(html);



    }
}


function getUltimasCompras() {

    console.log("Chamou");
    var returnList = [];

    var coligada = "1";
    var codigoproduto = $("#produto_codigo").val() || $("#produto_codigo").text();
    console.log("codigoproduto "+codigoproduto);

    var c0 = DatasetFactory.createConstraint("CODCOLIGADA", coligada, coligada, ConstraintType.MUST);
    var c1 = DatasetFactory.createConstraint("CODIGOPRD", codigoproduto, codigoproduto, ConstraintType.MUST);

    var constraints = new Array(c0, c1);

    var dataset = DatasetFactory.getDataset("rm_consulta_ultimas_compras", null, constraints, null);


    console.dir(dataset);


    var html = "";

    var length = dataset.values.length;

    length > 10 ? length = 10 : false;

    if (dataset) {

        for (var i = 0; i < length; i++) {

            html += `<tr>
                        <td>${new Date(dataset.values[i].DATAEMISSAO).toLocaleDateString()}</td>
                        <td>${dataset.values[i].NOMEFANTASIA_FORN}</td>
                         <td class="text-right">${convertStringFloat(dataset.values[i].QUANTIDADE).toFixed(2).toString().replace(".",",")}</td>
                        <td class="text-right">R$ ${convertStringFloat(dataset.values[i].PRECOUNITARIO).toFixed(2).toString().replace(".",",")}</td>
                        <td class="text-right">R$ ${convertStringFloat(dataset.values[i].VALORBRUTOITEMORIG).toFixed(2).toString().replace(".",",")}</td>
                    </tr>`
        }

    } else {

        html += `<tr>
                    <td colspan="5" class="text-center">Não foram localizadas compras anteriores.</td>
                </tr>`
    }

    $("#dadosUltimasCompras").append(html);




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