function openModalQuadro() {

    var modalHistorico = FLUIGC.modal({
        title: 'Quadro Comparativo ',
        content: getTemplateQuadro(),
        id: 'fluig-modal',
        size: 'full',
        actions: [{
            'label': 'Salvar',
            'bind': 'data-salvar-quadro',
        },{
            'label': 'Fechar',
            'autoClose': true
        }]
    }, function (err, data) {
        if (err) {
         
        } else {

            menorValorTotal();
            menorValorPorItem();
            menorPrazoEntrega();
            verificaFaseCotacao();
            verificaEmpatePreco();
           

        }
    });

    $(".modal-body").css("max-height","600");
    
}

$(document).on("click", "[data-salvar-quadro]", function (e) {

    fornecedorEscolhido();

    FLUIGC.toast({
        title: 'Quadro Salvo ',
        message: 'Quadro comparativo salvo com sucesso!',
        type: 'success',
        //timeout: 2000 // The strings 'fast' and 'slow' can be supplied to indicate durations of 2000 and 6000 milliseconds, respectively. If the timeout parameter is omitted, the default duration of 4000 milliseconds is used.
    });

})

function verificaFaseCotacao(){

 $("#tabelaQuadro").find("input[type=radio]").each(function(){
        $(this).hide();
    })

    if(WKNumState == 15){

        botoesCenarios();
        $("#tabelaQuadro").find("input[type=radio]").each(function(){
            
            $(this).show();
        })
    }
    
   

}

function getTemplateQuadro() {

    var tableFornecedor = $("table[tablename='tblFornecedor'] tbody tr").not(':first');
    var tableItem = $("table[tablename='tblItem'] tbody tr").not(':first');
    var tableItemCotacaoFornecedor = $("table[tablename='tblItensCotacaoFornecedor'] tbody tr").not(':first');

    //HEADER
    var html = `

    <table id="tabelaQuadro" class="table table-condensed table-bordered">
            <colgroup>
                <col style="min-width:350px;">
                <col style="min-width:100px;">
                <col style="min-width:30px;">
            </colgroup>
            <colgroup>`
    $(tableFornecedor).each(function () {
        html += `<col style="width:100px;">
                 <col style="width:100px;">
                 <col style="width:100px;">
                 <col style="width:100px;">`

    })


    html += ` </colgroup>
    <tr>
    <td style="min-width: 500px" colspan="3" rowspan="3"></td>
    `
    //CRIA COLUNAS DOS FORNECEDORES

    //TITULO
    $(tableFornecedor).each(function () {
        
        var fornecedor = $(this).find("td input[name^='forn_nome_']").val();
        var key = $(this).find("td input[name^='forn_key_']").val();
        html += `
        <td style="min-width: 340px" class="fs-txt-center text-info" colspan="4">
        <input type="radio" data-radio-quadro-fornecedor="${key}" name="fornecedor_radio" id="fornecedor_radio_${key}" class="pull-left">
        <span style="font-size:18px">
          <strong>${fornecedor}</strong>
        </span>
      </td>
      `
    });
    //VALOR TOTAL

    html += `<tr>`

    $(tableFornecedor).each(function () {

        
        html += `
        <td class="text-center active"><strong>Cond. Pgto</strong></td>
        <td class="text-center active"><strong>Entrega</strong></td>
        <td class="text-center active"><strong>Frete</strong></td>
        <td class="text-center active"><strong>Total</strong></td>

    `
    });

    html += `</tr>`
    //FRETE

    html += `<tr>`

    $(tableFornecedor).each(function () {

        var frete = $(this).find("td input[name^='cotacao_valor_frete_']").val();
        var condpgto = $(this).find("td input[name^='cotacao_cond_pgto_']").val();
        var key = $(this).find("td input[name^='forn_key_']").val();
        var entrega = $(this).find("td input[name^='cotacao_previsao_entrega_']").val();
        entrega != "" ? entrega = moment(entrega).format("DD/MM/YYYY") : "";
     
        var total = $(this).find("td input[name^='cotacao_total_cotacao_']").val();
       


   
        html += `
        <td class="text-center">${condpgto || "---"}</td>
        <td data-quadro-prazo class="text-center">${entrega || "---"}</td>
        <td class="text-right">${frete || "R$ 0,00"}</td>
        <td data-quadro-total-cotacao="${key}" style="font-size:16px" class="text-right"><strong>${total || "R$ 0,00"}</strong></td>`
    });

    html +=`</tr>
            <tr>
                <td colspan="2" class="active"><strong>Item Cotado</strong></td>
                <td class="active"><strong>Quant.</strong></td>`
                
    $(tableFornecedor).each(function () {
        
        
        html +=`<td class="text-center active"><strong>Tributos</strong></td>
                <td class="text-center active"><strong>Desconto</strong></td>
                <td class="text-center active"><strong>Preço</strong></td>
                <td class="text-center active"><strong>Total</strong></td>`
    })

    html += `</tr>`;


    //FIM CARREGAMENTO CABEÇALHO

    // INICIAR CARREGAMENTO LINHAS DO ORÇAMENTO

    $(tableItem).each(function () {

        var seqItem = $(this).find("td input[name^='item_seq_']").val();
        var produto = $(this).find("td input[name^='produto_descricao_']").val();
        var un = "UN";
        var quantidade = $(this).find("td input[name^='produto_quantidade_']").val();
      
      

        html += `<tr data-tr-item>
        <td colspan="2">${seqItem} - ${produto}</td>
        <td>${quantidade} ${un} </td>`

        $(tableFornecedor).each(function () {

            var key = $(this).find("td input[name^='forn_key_']").val();

            $(tableItemCotacaoFornecedor).each(function () {

                var key_item = $(this).find("td input[name^='cotacao_key_']").val();
                var cotacao_item_seq = $(this).find("td input[name^='cotacao_item_seq_']").val();
                var cotacao_item_vencedor = $(this).find("td input[name^='cotacao_item_vencedor_']").val();
                var checkItem = cotacao_item_vencedor == "S" ? "checked" : "";

                if (key === key_item && seqItem === cotacao_item_seq) {
                    
                    var idTable = $(this).find("td input[name^='cotacao_preco_']").attr("name").split("___")[1];
                    
                    var preco = $(this).find("td input[name^='cotacao_preco_']").val();
                    var total = $(this).find("td input[name^='cotacao_total_item_']").val();
                    var desconto = $(this).find("td input[name^='cotacao_desconto_']").val();;
                    var ipi = convertStringFloat($(this).find("td input[name^='cotacao_produto_ipi_']").val()) || 0;
                    var icms = convertStringFloat($(this).find("td input[name^='cotacao_icmsst_']").val()) || 0;
                    var qtd = convertStringFloat($(this).find("td input[name^='cotacao_produto_quantidade_']").val()) || 0;
                    var status = $(this).find("td input[name^='cotacao_status_item_']").val();
                    var tributos = ((ipi + icms) /100) * (qtd*convertStringFloat(preco)) ;

                    tributos = tributos.toLocaleString('pt-br',{style: 'currency', currency: 'BRL'});

                    if(status != "cotado"){

                        status == "nao_cotado"     ? status = "Não Cotado"     : false;
                        status == "nao_fornecido"  ? status = "Não Fornecido"  : false;
                        status == "nao_disponivel" ? status = "Não Disponível" : false;

                        html+=` <td class="text-center warning" colspan="4">${status}</td>`

                    } else{
                    html += `
                    <td class="text-right">${tributos || "R$ 0,00"}</td>
                    <td class="text-right">${desconto || "R$ 0,00"}</td>
                    <td class="text-right">${preco}</td>
                    <td data-quadro-total-item class="text-right">
                        <input type="radio" data-radio-quadro-item="${key}" name="item_radio_${seqItem}" value="${idTable}" id="item_radio_${key}" class="pull-left" ${checkItem}> 
                            ${total}
                    </td>
                    `
                }
                }
            })
        })
        html += `</tr>`;

    })

    html += '</table>'

    return html;

   
}

function menorValorTotal(escolha)
{
    var arr = new Array();

    var objects =  $('[data-quadro-total-cotacao]');

    $(objects).each(function(){
        var valor = convertStringFloat($(this).text());
        if(valor>0){
          arr.push(valor);
         }
    });

    var min = Math.min.apply(null, arr);
    var max = Math.max.apply(null, arr);

    $(objects).each(function(){
        var valor = convertStringFloat($(this).text());
        if(valor==min)
        {
            var key = $(this).data().quadroTotalCotacao;
            $(this).addClass("success");


            var radioElement = $("input[id^='fornecedor_radio_"+key+"']");

            escolha ? $(radioElement).prop("checked",true) : false;
            
            //$(radioElement).trigger("change"); //Dispara o evento change
 
        }
        if(valor==max)
        {
            $(this).addClass("danger");
        }
    })

  

}

function menorValorPorItem(escolha) {

    $("[data-tr-item]").each(function () {

        var arr = new Array();
        var objects = $(this).find("[data-quadro-total-item]");

        $(objects).each(function () {
            var valor = convertStringFloat($(this).text());
            if (valor > 0) {
                arr.push(valor);
            }
        });

        var min = Math.min.apply(null, arr);
        var max = Math.max.apply(null, arr);

        $(objects).each(function () {
            var valor = convertStringFloat($(this).text());

            if (valor == min) {
                
                $(this).addClass("success");

                var radioElement = $(this).find("input[type='radio']");

                if(escolha){ 
                    $(radioElement).prop("checked",true);              
                }  
                $(radioElement).trigger("change"); //Dispara o evento change
            }
            if (valor == max) {

                $(this).addClass("danger");

            }


        })


    })

    verificaEmpatePreco();

  
}

function verificaEmpatePreco(){

    $("[data-quadro-total-item]").each(function(){

            var seq = $(this).find("input").attr("name").split("_")[2];
            var arr = new Array();
            
            $("input[name='item_radio_"+seq+"']").each(function(){
    
                var valor =   convertStringFloat($(this).parent().text().replace(" ",""));
                if (valor > 0) {
                    arr.push(valor);
                }
    
            })
    
            
            if(new Set(arr).size != arr.length){
                //
                $(this).removeClass();
                $(this).addClass("text-right");
                //
            }
    
        });
    

}


function menorPrazoEntrega() {

    var arr = new Array();
    var objects =  $('[data-quadro-prazo]');

    $(objects).each(function(){
        
        var data = new Date(moment($(this).text(),'DD/MM/YYYY'));

        console.log("Data Localizada: " + data);

        if(data.getTime()){
            arr.push(data);
         }

    });


    var min = new Date(Math.min.apply(null,arr));
    var max = new Date(Math.max.apply(null,arr));


    $(objects).each(function(){

        var data = new Date(moment($(this).text(),'DD/MM/YYYY'));


        if(data.getTime() == min.getTime())
        {
            $(this).addClass("success");
        }
        if(data.getTime()==max.getTime())
        {
            $(this).addClass("danger");
        }
    })

}

function fornecedorEscolhido(){

    //Verifica se escolha foi global

    
  

    var global=false;

    $("[data-radio-quadro-fornecedor]").each(function(){
       if($(this).prop("checked")){
          var key = $(this).data().radioQuadroFornecedor;
          var global=true;

         // $("[data-radio-quadro-item]").find(`[data-radio-quadro-item='${key}']`).each(function(){

            $("[data-radio-quadro-item='"+key+"']").each(function(){
              $(this).prop("checked",true);
          })
       }
    })

    if(!global){
    $("[data-radio-quadro-item]").each(function(){

        var key = $(this).data().radioQuadroItem;
        var item_seq = $(this).attr("name").split("_")[2];
        var id = $(this).val();

        if($(this).prop("checked")){
           $("#cotacao_item_vencedor___"+id).val("S");
           $("")
        } else{
           $("#cotacao_item_vencedor___"+id).val("");
        }
     })
    }

    $("#fornecedoresEscolhidos").val(escolha);
console.log(escolha);
}

function botoesCenarios(){

    var html = `<div class='pull-left'>
                    <button data-btn-escolha-melhor-fornecedor class='btn btn-info'>
                        <span class="fluigicon fluigicon-money-circle fluigicon-sm"></span> Menor Preço por Fornecedor
                    </button>
                    <button data-btn-escolha-melhor-preco-item class='btn btn-info'>
                        <span class="fluigicon fluigicon-money fluigicon-sm"></span> Menor Preço Por Item
                    </button>
               
               </div>`;

    $(".modal-footer").append(html);

}


$(document).on("click", "[data-btn-escolha-melhor-fornecedor]", function (e) {

    menorValorTotal(true);
    fornecedorEscolhido();

})

$(document).on("click", "[data-btn-escolha-melhor-preco-item]", function (e) {
    menorValorPorItem(true);
    fornecedorEscolhido();
})

$(document).on("click", "[data-btn-escolha-melhor-prazo]", function (e) {
    
})

$(document).on("change", "[data-radio-quadro-fornecedor]", function (e) {
    console.log("## change radio fornecedor");

    console.log($(this).attr("id"));
    console.log($(this).prop("checked"));

    $("[data-radio-quadro-item]").each(function(){
        $(this).prop("checked",false);
    });

    fornecedorEscolhido();

})

$(document).on("change", "[data-radio-quadro-item]", function (e) {
   
    $("[data-radio-quadro-fornecedor]").each(function(){
        $(this).prop("checked",false);
    })
})