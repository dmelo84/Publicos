
var table="";
function openModalItemContrato() {
  


   /* var id = $(element).closest("tr").find("input").first().attr("name").split("___")[1]

    var coligada = $("#empresa_codigo").val();
    var codigoproduto = $("#produto_codigo___" + id).val();
    var produtodescricao = $("#produto_descricao___" + id).val();
  */

    var modalHistorico = FLUIGC.modal({
        title: 'Itens do Contrato ' ,
        content: '<div id="DivModalItensContrato" class="col-md-12"><table id="lookupContratoItens" class="table table-condensed"></table></div>',
        id: 'fluig-modal',
        size: 'full', //'full | large | small'
        actions: [ {
            'label': 'Fechar',
            'autoClose': true
        }]
    }, function (err, data) {
        if (err) {

        } else {

       


        }
    });

    var disabled="";
    if(WKNumState != 4 && WKNumState != 42){
        disabled="disabled";
    }

    var mydata = buscarContratoItens();
    console.log(mydata);
    var groupColumn = 2;
    table = $('#lookupContratoItens').DataTable({

        language: {
            url: "js/plugins/datatables/Portuguese-Brasil.json"
        },
        data: mydata,
        columns: [
            {
                data: 'CODIGOPRD',
                title: 'Cód'},
                {
                    data: 'NOMEFANTASIA',
                    title: 'Descrição'}, {
                        data: 'CODUNDCOMPRA',
                        title: 'Un.'},

         
            {
                data: 'PRECOFATURAMENTO',
                title: 'Preço',
                render: function ( data, type, row ) {
                    var dateSplit = numeral(parseFloat(data)).format('$ 0,0.00');
                    return type === "display" || type === "filter" ?
                        dateSplit  :
                        data;
                }},

                {
                    "data": null,
                    "defaultContent": `<button type="button" class="btn btn-sm btn-default" onclick="addItemContrato(this);" ${disabled}>
                            <span class="fluigicon fluigicon-plus-circle fluigicon-sm"></span> Adicionar</button>`
                }
          
        ], "columnDefs": [
            {
                "targets": [ 0 ],
                "visible": true,
                "searchable": true
        }],
        "lengthMenu": [
            [5, 10],
            [5, 10]
        ]
    });

    $(document).on("click", "[data-open-modal-historico]", function (e) {

     
        modalHistorico.remove();



    });



}


function addItemContrato(el) {


  var item = {};

  var tr =  $(el).closest('tr');
  var row = table.rows(tr).data()[0];
  console.log(row);

  item.CODIGOPRD    = row.CODIGOPRD;
  item.DESCRICAO    = row.NOMEFANTASIA;
  item.CODUNDCOMPRA = row.CODUNDCOMPRA;
  item.ITEMFAMILY   = "";
  item.ITEMCONTRL   = "";
  item.TIPO         = "";
  item.CODTB2FAT    = "";
  item.IDPRD        = row.IDPRD;
  item.CUSTOMEDIO   = row.PRECOFATURAMENTO;
  item.IDCNT        = row.IDCNT;
  item.NSEQITMCNT   = row.NSEQITMCNT;


  

  addItemTable(item, "1");


    /*
    loading.show();
    var value = $(el).closest('tr').find('td:first')[0].innerText;
    console.log(value);
    //var id = wdkAddChild('tblFornecedor');
    
    selectedFornecedor = buscarFornecedor(value)[0];
    console.log(selectedFornecedor[0]);
    addFornecedor();
    selectedFornecedor = {};
    loading.hide();
    */
    
}