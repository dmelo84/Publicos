/*/---------------------------------------
 * Função de seleção de Zoom webservice
 * Diogo Melo: 07/05/2021
 ----------------------------------------*/
function setSelectedZoomItem(selectedItem) {

	var cCampo  = selectedItem.inputId;
	
	var cHtml = ''
	var divTitu = document.getElementById("areaTitulos")		
	var div = document.getElementById("duplicata")
	var cId = '1'
	
	if(selectedItem.inputId == 'titulo'){
		$("#a1_est").val(selectedItem["UF"])
		$("#a1_cod_mun").val(selectedItem["codigoMunicipio"])
		$("#a1_mun").val(selectedItem["municipio"])
		
		if(typeof div == null || typeof div == 'undefined'){
			
			divTitu.innerHTML ="<div id='duplicata'></div>"
		};
		
		cNumero  = selectedItem['Numero'].trim()
		cPrefixo = selectedItem['Prefixo'].trim()
		cIdTitulo = cPrefixo+cNumero
					   
		 cHtml = '<div class="custom-checkbox custom-checkbox-primary">'
		 cHtml += '<input type="checkbox" id="checkbox'+cIdTitulo+'">'
		 cHtml += '<label for="checkbox'+cIdTitulo+' value='+cNumero+'">'+cNumero+'</label>'
		 cHtml += '</div>'
		
		
		div.innerHTML += cHtml
	}
}

/*/---------------------------------------
 * Função de deleção de Zoom webservice
 * Diogo Melo: 07/05/2021
 ----------------------------------------*/
function removedZoomItem(removedItem) {

	var cCampo  = removedItem.inputId;
	
	if (removedItem.inputId === 'a1_cod_mun') {
	
		$("#a1_est").val("")
		$("#a1_cod_mun").val("")
		$("#a1_mun").val("")
	}
}

/*/---------------------------------------
 * Função teste
 * Diogo Melo: 08/09/2021
 ----------------------------------------*/
$("#inclui").click(function() {
	var cHtml = ''
	var divTitu = document.getElementById("areaTitulos")		
	var div = document.getElementById("duplicata")
	var cId = '1'
		
	if(typeof div == null || typeof div == 'undefined'){
		
		divTitu.innerHTML ="<div id='duplicata'></div>"
	};
	
	cTexto = 'Diogo Melo'
		   
	 cHtml = '<div class="custom-checkbox custom-checkbox-primary">'
	 cHtml += '<input type="checkbox" id="checkbox'+cId+'">'
	 cHtml += '<label for="checkbox'+cId+'">'+cTexto+'</label>'
	 cHtml += '</div>'
	
	
	div.innerHTML += cHtml
	
});
$("#exclui").click(function() {
	
	var div = document.getElementById("areaTitulos")
	div.innerHTML ="<div id='duplicata'></div>"		
/*		
	// cria um novo elemento div
	// e dá à ele conteúdo
	
	var divNova = document.createElement("duplicata");
	var conteudoNovo = document.createTextNode("Selecione novos Títulos!");
	
	divNova.appendChild(conteudoNovo); //adiciona o nó de texto à nova div criada

	// adiciona o novo elemento criado e seu conteúdo ao DOM
	var divAtual = document.getElementById("areaTitulos");
	document.body.insertBefore(divNova, divAtual);
*/		
});

/*
Rest Teste
*/

var testDatatable = SuperWidget.extend({
    myTable: null,
    tableData: null,
    dataInit: null,
 
    init: function() {
        this.loadTable();
    },
 
    loadTable: function() {
        var that = this;
        that.myTable = FLUIGC.datatable('#duplicata' + "_" + that.instanceId, {
            dataRequest: DatasetFactory.getDataset('colleague', null,null,null).values,
            renderContent: ['colleagueName', 'login', 'mail', 'defaultLanguage'],
            header: [
                {'title': 'colleagueName'},
                {'title': 'login'},
                {'title': 'mail'},
                {'title': 'defaultLanguage'}
            ],
            search: {
                enabled: true,
                onlyEnterkey: true,
                onSearch: function(res) {
                    if (!res) {
                        that.myTable.reload(dataInit);
                    }
                    var dataAll = that.myTable.getData();
                    var search = dataAll.filter(function(el) {
                        return el.colleagueName.toUpperCase().indexOf(res.toUpperCase()) >= 0
                            || el.login.toUpperCase().indexOf(res.toUpperCase()) >= 0
                            || el.mail.toUpperCase().indexOf(res.toUpperCase()) >= 0;
                    });
                    if (search && search.length) {
                        that.myTable.reload(search);
                    } else {
                        FLUIGC.toast({
                            title: 'Searching: ',
                            message: 'No results',
                            type: 'success'
                        });
                    }
                }
            },
            navButtons: {
                enabled: false,
            },
        }, function(err, data) {
            if(data) {
                dataInit = data;
            }
            else if (err) {
                FLUIGC.toast({
                    message: err,
                    type: 'danger'
                });
            }
        });
    }
});