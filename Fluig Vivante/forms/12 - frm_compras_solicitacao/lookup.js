

function openLookup() {

    var modalLookUp = FLUIGC.modal({
        title: 'Pesquisa',
        content: '<div id="lookupDataTable"></div>',
        id: 'fluig-modal',
        size: 'large',
        actions: [{
            'label': 'Ok',
            'bind': 'data-open-modal',
        }, {
            'label': 'Fechar',
            'autoClose': true
        }]
    }, function (err, data) {
        if (err) {
          
        } else {
           
        }
    });

   

    var data = buscarProduto('%');

    var datatablelk = FLUIGC.datatable('#lookupDataTable', {
        dataRequest: data,
        renderContent: ['CODIGOPRD', 'DESCRICAO','CODUDCONTROLE','TIPO'],
        header: [{
                'title': 'Código',
                'title': 'Descrição',
                'title': 'Un',
                'title': 'Tipo'
            }

        ],
        search: {
            enabled: true,
            onSearch: function (response) {

              
                if (response) {
                    var  data = buscarProduto(response);
        
           
                    datatablelk.reload(data);
                
                }
               
            },
            onlyEnterkey: true,
            searchAreaStyle: 'col-md-3'
        },
        multiSelect: false,
        classSelected: 'info',
        navButtons: {
            enabled: false,
            forwardstyle: 'btn-warning',
            backwardstyle: 'btn-warning',
        },
        actions: {
            enabled: true,
            template: '.my_template_area_actions',
            actionAreaStyle: 'col-md-9'
        },
        emptyMessage: '<div class="text-center">Não foram encontradas solicitações pendentes.</div>',
        tableStyle: 'table-striped',

    }, function (err, data) {
        // DO SOMETHING (error or success)
       
    });

    

    $(document).on("click", "[data-open-modal]", function (e) {
      


        var index = datatablelk.selectedRows();
        console.log(index);
       



        for (let i = 0; i < index.length; i++) {

            var selected = datatablelk.getRow(index[i]);


            $("#ccusto_codigo").val(selected.CODCCUSTO)
            $("#ccusto_nome").val(selected.NOME)
       
            
        }

        datatablelk.destroy();
        modalLookUp.remove();

      

});



}

function loadDataTable(){

}

