var itens = [{ idPaiFilho: "1", unidade: "0084", unidade_nome: "UNISINOS", ccusto_codigo: "40.51.2.0084.00.01", ccusto_nome: "GERENTE DE AGENCIA" },
    { idPaiFilho: "2", unidade: "0084", unidade_nome: "UNISINOS", ccusto_codigo: "40.51.2.0084.00.01", ccusto_nome: "GERENTE DE AGENCIA" },
    { idPaiFilho: "3", unidade: "0084", unidade_nome: "UNISINOS", ccusto_codigo: "40.51.2.0084.00.01", ccusto_nome: "GERENTE DE AGENCIA" },
    { idPaiFilho: "4", unidade: "0084", unidade_nome: "UNISINOS", ccusto_codigo: "40.51.2.0084.00.01", ccusto_nome: "GERENTE DE AGENCIA" },
    { idPaiFilho: "5", unidade: "0084", unidade_nome: "UNISINOS", ccusto_codigo: "40.51.2.0084.00.01", ccusto_nome: "GERENTE DE AGENCIA" },
    { idPaiFilho: "6", unidade: "0084", unidade_nome: "UNISINOS", ccusto_codigo: "40.51.2.0084.00.01", ccusto_nome: "GERENTE DE AGENCIA" },
    { idPaiFilho: "7", unidade: "0084", unidade_nome: "UNISINOS", ccusto_codigo: "40.51.2.0084.00.01", ccusto_nome: "GERENTE DE AGENCIA" },
    { idPaiFilho: "8", unidade: "0084", unidade_nome: "UNISINOS", ccusto_codigo: "40.51.2.0084.00.01", ccusto_nome: "GERENTE DE AGENCIA" },
    { idPaiFilho: "9", unidade: "0084", unidade_nome: "UNISINOS", ccusto_codigo: "40.51.2.0084.00.01", ccusto_nome: "GERENTE DE AGENCIA" },
    { idPaiFilho: "10", unidade: "0084", unidade_nome: "UNISINOS", ccusto_codigo: "40.51.2.0084.00.01", ccusto_nome: "GERENTE DE AGENCIA" },
    { idPaiFilho: "11", unidade: "0084", unidade_nome: "UNISINOS", ccusto_codigo: "40.51.2.0084.00.01", ccusto_nome: "GERENTE DE AGENCIA" },
    { idPaiFilho: "12", unidade: "0084", unidade_nome: "UNISINOS", ccusto_codigo: "40.51.2.0084.00.01", ccusto_nome: "GERENTE DE AGENCIA" },
    { idPaiFilho: "13", unidade: "0084", unidade_nome: "UNISINOS", ccusto_codigo: "40.51.2.0084.00.01", ccusto_nome: "GERENTE DE AGENCIA" },
    { idPaiFilho: "14", unidade: "0084", unidade_nome: "UNISINOS", ccusto_codigo: "40.51.2.0084.00.01", ccusto_nome: "GERENTE DE AGENCIA" },
    { idPaiFilho: "15", unidade: "0084", unidade_nome: "UNISINOS", ccusto_codigo: "40.51.2.0084.00.01", ccusto_nome: "GERENTE DE AGENCIA" }]



$(document).ready(function () {

    var tbl = $('[data-tbl-precos]').DataTable(
        {
            language: {
                "url": "https://conecta.vivante.com.br/devLib/resources/js/plugins/datatables/Portuguese-Brasil.json"
            },
            dom: 'Bfrtip',
            buttons: [
                {
                    extend: 'copy',
                    text: 'Copiar'
                },
                {
                    extend: 'excel',
                    text: 'Excel'
                }

            ],
            //  data: this.buscaOrdens(),
            columns: [
                {
                    data: "idPaiFilho",
                    title: "Seq",
                    render: function (data, isType, full, meta) {
                        return full.idPaiFilho
                    }
                },
                {
                    data: "",
                    title: "Status",
                    render: function (data, isType, full, meta) {
                        return `<select  class="form-control">
                                <option>${full.idPaiFilho}</option>
                                </select>`
                    }
                },
                {
                    data: "",
                    title: "Status",
                    render: function (data, isType, full, meta) {
                        return `<input type="text" data-preco class="form-control"/>`
                    }
                },
            ],
            columnDefs: [
              
            ],
            fixedHeader: true,
            processing: true, //utilizado para atualizar a tabela
            destroy: true, //utilizado para atualizar a tabela
            pagingType: 'full_numbers', //tipo de paginação
            info: true, //Se terá info da tabela
            createdRow: function (row, data, index) {

            },
            drawCallback: function (configs) {

                $("[data-preco]").keypress(function (e) {

                    console.log(e.which)
                    if (e.which == 13) {
                        console.log($(this).closest('tr'))

                        $(this).closest('tr').nextAll().eq(0).find('input').focus();


                    }

                    if (e.which == 38) {
                        console.log($(this).closest('tr'))

                        $(this).closest('tr').nextAll().eq(0).find('input').focus();


                    }
                })
               
            },
            "initComplete": function (settings, json) {
           
           
            }

        }


    )


   
    console.log(tbl)

    console.log(itens)
    tbl.rows.add(itens).draw();
});
