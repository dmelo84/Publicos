var importaRateio = {
	datatable: [],
	montaTabela: function (dataSet) {
		//MONTAGEM DAS COLUNAS
		//Array de colunas que serão carregadas da planilha
		var colunasArr = [];
	
		//Pega a primeira linha do array de objetos retornado da planilha
		var colunasObj = dataSet[0];
	
	    //Pega os nomes das colunas e passa para o Array de Colunas para ser passado na inicialização da Tabela
		for (col in colunasObj) {
			colunaObj = {}; //objeto
			colunaObj.title = col.toString(); //passa o nome da coluna para a propriedade title
			colunasArr.push(colunaObj); //adiciona ao array
		}
	
		if (!validaColunas(colunasArr)) {
			FLUIGC.message.alert({
				message: 'A planilha deve conter as seguintes colunas:\n\n A1 = FORNECEDOR,\n B1 = CODPRD,\n C1 = CCUSTO,\n D1 = VALOR,\n E1= HISTORICO \n\n Os dados devem iniciar na linha 2.',
				title: 'Planilha fora do padrão',
				label: 'OK'
			}, function (el, ev) {
	
			});
	
			return false;
		}
	
		//MONTAGEM DOS VALORES
		//Array dos valores
		var result = [];
		var erros = "";
	
	    //Para cada linha do array de objetos retornado pela planilha
		for (var i in dataSet) {
			if (validaLinha(dataSet[i])) {
				//console.log("Linha "+i+ "= "+validaLinha(dataSet[i]));
	
				//Array de valores que serão montados
				var values = [];
				
				//Monta os valores com base nas colunas, para isto, percorre cada coluna e adiciona o respectivo valor
				for (col in colunasObj) {
					//adiciona valor na posição da coluna
					values.push(dataSet[i][col])
				}
				
				//Adicionar o array de valores (linha) ao array de valores principal
				result.push(values);
			} else {
				var linha = parseInt(parseInt(i) + 1);
				console.log("Linha "+linha);
				
				if (erros.length == 0) {
					erros += linha.toString();
				} else { erros += ", " + linha.toString() }
			}
		}
	
	    var htmlModal = ` <table class="table table-bordered" id="tablePlanilha" style="width:100%">
	    </table>`
	
	    var myModal = FLUIGC.modal({
	    	title: 'Importação de Rateios',
	    	content: htmlModal,
	    	id: 'fluig-modal',
	    	size: 'full',
	    	actions: [{
	    		'label': 'Adicionar',
	    		'bind': 'data-adiciona-item-rateio',
	    	}, {
	    		'label': 'Fechar',
	    		'autoClose': true
	    	}]
	    }, function (err, data) {
	    	if (err) {
	    		// do error handling
	    	} else {
	    		$(".modal-footer").append(`<div class="col-md-10">
			        <div class="progress">
			        <div class="progress-bar progress-bar-info" data-progress-bar role="progressbar" aria-valuenow="2" aria-valuemin="0" aria-valuemax="100" style="width: 0%;">
			        </div>
			    </div></div>`);
	    	}
	    });
	
	    importaRateio.datatable = $('#tablePlanilha').dataTable({
	    	data: result,
	    	columns: colunasArr,
	    	"searching": false,
	    	"lengthChange": false,
	    	"pageLength": 5,
	    	"language": {
	    		"url": "/devLib/resources/js/plugins/datatables/Portuguese-Brasil.json"
	    	}
	    });
	
	    if (erros.length > 0) {
	    	var msg = "";
	    	if (erros.split(",").length > 0) {
	    		msg = "ATENÇÃO: As linhas " + erros + " não serão incluídas pois não passaram na validação do formato. Revise a planinha.";
	    	} else {
	    		msg = "ATENÇÃO: A linha " + erros + " não será incluída pois não passou na validação do formato. Revise a planinha.";
	    	}
	
	    	FLUIGC.message.alert({
	    		message: msg,
	    		title: 'Linha da planilha fora do padrão',
	    		label: 'OK'
	    	}, function (el, ev) {
	
	    	});
	    }
	}, // montaTabela
	
	ExcelToJSON: function () {
		this.parseExcel = function (file) {
			var reader = new FileReader();

			reader.onload = function (e) {
				var data = e.target.result;
				var workbook = XLSX.read(data, {
					type: 'binary'
				});
				console.log("## workbook ");
				console.log(workbook);
				//   workbook.SheetNames.forEach(function (sheetName) {
				// Here is your object
				console.log("sheetName " + sheetName);

				var sheetName = workbook.SheetNames[0];
				var XL_row_object = XLSX.utils.sheet_to_row_object_array(workbook.Sheets[sheetName]);
				// console.log("XL_row_object "+XL_row_object);

				console.log("FORMATO XL_row_object");
				console.log(XL_row_object);

				var json_object = JSON.stringify(XL_row_object);
				console.log("FORMATO json_object");
				console.log(json_object);

				console.log("FORMATO JSON.parse(json_object)");
				console.log(JSON.parse(json_object));

				importaRateio.montaTabela(JSON.parse(json_object));
				//montaTable(JSON.parse(json_object));

				jQuery('#xlx_json').val(json_object);
			};

			reader.onerror = function (ex) {
				console.log(ex);
			};

			reader.readAsBinaryString(file);
		};
	}, // ExcelToJSON
	
	adicionaItem: function () {
		console.log(importaRateio.datatable);
		var arr = importaRateio.datatable.fnGetData();
		console.log(arr);
		console.log("iniciou");

		var progressBar = $("[data-progress-bar]");
		$("[data-adiciona-item-rateio]").attr("disabled", "disabled");
		$("[data-dismiss]").attr("disabled", "disabled");

		var total = 0;

		for (var i = 0, ln = arr.length; i < ln; i++) {
			setTimeout(function (y) {
				console.log("ln " + ln);
				console.log("i " + i);
				console.log("y " + y);
				console.log(arr[y]);

				var posicao = ((y + 1) / ln * 100).toFixed(2) + "%";
				$(progressBar).text(posicao).css("width", posicao);

				const codcfo = arr[y][0];

				let fornecedor = buscarFornecedorPorCodigo(codcfo);

				$("#codcfo").val(codcfo);
				$("#codcfo_nome").val(fornecedor[0].NOME);
				$("#codcfo").attr("readonly", true);
				$("#codcfo_nome").attr("disabled", true);
				$("[data-btn-zoom-autocomplete='acCfo']").hide();

				const codproduto = arr[y][1];
				const codccusto = arr[y][2];

				const valor = arr[y][3].replace(".", ",");
				total += convertStringFloat(valor);

				const historico = arr[y][4];

				var produto = buscarProdutoPorCodigo(codproduto);
				var ccusto = buscarCcustoPorCodigo(codccusto);

				if (!produto || produto.length == 0){
					FLUIGC.toast({
						title: 'Item ' + ln + ' não adicionado.',
						message: 'Não foi possível encontrar o produto com código ' + codproduto,
						type: 'danger'
					});
				}

				if (!ccusto || ccusto.length == 0){
					FLUIGC.toast({
						title: 'Item '+ln+' não adicionado.',
						message: 'O C.Custo ' + codccusto + ' não foi encontrado ou está inativo.',
						type: 'danger'
					});
				}

				if(produto.length > 0 && ccusto.length > 0){
					//var id = adicionarItem();
					//setProduto(produto[0], id);
					var id = SEQ_PF_ITENS;
					adicionarRateio(id, codccusto, valor, "100");
					$("#tblIt_Preco___" + id).val("R$ " + convertStringFloat(valor).toFixed(2).replace(".", ","));
					$("#tblIt_Preco___" + id).maskMoney('mask');
					$("#tblIt_QtdCompra___" + id).val("1");
					$("#tblIt_infoAdicionais___" + id).val(historico);
					//calculaConversaoUnidadeInterna(id)
				}
				console.log(y + "=" + (ln - 1));

				if (y == (ln - 1)) {
					//$("[data-adiciona-item-rateio]").removeAttr("disabled");
					$("[data-dismiss]").removeAttr("disabled");
				}

				$("#valor_total").val("R$ " + total.toFixed(2).replace(".", ","));
				$("#valor_total").maskMoney('mask');
			}, i * 200, i);
		}
		// We can hide the message of loading

	}, // adicionaItem
}

function validaColunas(colunasArr) {
	return colunasArr[0].title == "FORNECEDOR" &&
	colunasArr[1].title == "CODPRD" &&
	colunasArr[2].title == "CCUSTO" &&
	colunasArr[3].title == "VALOR" &&
	colunasArr[4].title == "HISTORICO";
} // validaColunas

function validaLinha(row) {
	return row.FORNECEDOR.length > 0 &&
	row.CODPRD.length > 0 &&
	row.CCUSTO.length >= 4 &&
	(row.VALOR.length > 0 &&
			!isNaN(parseFloat(row.VALOR))) 
} // validaLinha

$(document).on("click", "[data-adiciona-item-rateio]", function () {
	importaRateio.adicionaItem();
	initMask();
	validateAll();
	//exibeValorTotal();
	console.log("finalizou");
})

function handleFileSelect(evt) {
	var files = evt.target.files; // FileList object
	var xl2json = new importaRateio.ExcelToJSON();

	xl2json.parseExcel(files[0]);
} // handleFileSelect


$(document).on("hide.bs.modal", function (event) {
	//verificaTipoSolicitacao();
});