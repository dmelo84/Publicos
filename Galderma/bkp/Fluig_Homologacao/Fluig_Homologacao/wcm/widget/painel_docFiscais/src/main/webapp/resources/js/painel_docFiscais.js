var painel_Doc = SuperWidget.extend({
    //variáveis da widget
    variavelNumerica: null,
    variavelCaracter: null,

    //método iniciado quando a widget é carregada
    init: function() {
    	var FluigClient = new FluigClient()
                .setHost("http://10.30.4.121:80")
                .setConsumerKey("102030")
                .setConsumerSecret("302010")
                .connect();
    	if(!WCMAPI.userLogin){
    		var myModal
    		var html = ''
    			
    			html = '<h3>Bem-Vindo,</h3><p><b>favor informar CNPJ e senha para logar no Painel</b></p>'
    			html += '<div class="col-md-4" style="padding-left: 0px;">'
    			html += '<div class="form-group">'
    			html += '<label>CNPJ:</label>'	
    			html += '<input type="text" name="cgc" id="cgc" class="form-control" maxlength="14" mask="00.000.000/0000-00">'	
    			html += ' </div>'
    			html += ' </div>'
    			html += '<div class="col-md-3">'
    	    	html += '<div class="form-group">'
    	    	html += '<label>Senha:</label>'	
    	    	html += '<input type="text" name="senha" id="senha" class="form-control">'	
    	    	html += ' </div>'
    	    	html += ' </div>'
    				
    		myModal = FLUIGC.modal({
			    title: 'Gerenciador de Documentos',
			    content: html,
			    id: 'fluig-modal',
			    actions: [{
			        'label': 'Entrar',
			        'bind': 'data-sigIn'
			    },{
			        'label': 'Solicitar Senha',
			        'bind': 'data-envPassword'
			    }]
    		});
    		$(document).on('click', '[data-envPassword]', function(ev) {
    			var cgc = $("#cgc").val();
    			if(cgc != "" && cgc.length == 14){
    				
    				var objForn = {
    						A2_CGC:cgc
    				}
    				var JSONStr = JSON.stringify(objForn);
    				var constraint = DatasetFactory.createConstraint("VALID",JSONStr, "", ConstraintType.MUST);
    		    	var dataLogin = DatasetFactory.getDataset("ds_QSHUBLOGIN_PORTAL_FORNECEDOR", null,constraint ,null);
    				myModal.remove()
    			}else{
    				alert("Favor preencher com um CNPJ válido")
    			}
    			//var uf = $("#uf").val()
    			
    		});
    	}else{
    		var objForn = {
					A2_CGC:'53611872000152'
			}
			var JSONStr = JSON.stringify(objForn);
			var constraint = DatasetFactory.createConstraint("VALID",JSONStr, "", ConstraintType.MUST);
	    	var dataLogin = DatasetFactory.getDataset("ds_QSHUBLOGIN_PORTAL_FORNECEDOR", null,constraint ,null);
	    	console.log("hello")
    	}
    },
  
    //BIND de eventos
    bindings: {
        local: {
            'loadTable': ['click_loadTable']
        },
        global: {}
    },
 
    loadTable: function() {
    	var html = "";
    	
    	html +='    <table id="myTableHeader" class="table">';
    	html +='        <thead>';
    	html +='            <tr>';
    	html +='                <th>N° Documento / Serie </th>';
      	html +='                <th>Tipo</th>';
    	html +='                <th>Responsável</th>';
    	html +='                <th>Data Inclusão</th>';
    	html +='                <th>Total</th>';
    	html +='                <th>Status</th>';
    	html +='                <th>Detalhes</th>';
    	html +='            </tr>';
    	html +='        </thead>';
    	html +='        <tbody>';
	    html +='         <div class="table-datatable">';
	    html +='   <tr>';
	    html +='  	<td>000000123 / 0001</td>';
	    html +='  	<td> Nota de Serviço </td>';
	    html +='  	<td> Willian Carlos </td>';
	    html +='  	<td>08/06/2021</td>';
	    html +='  	<td>10.000,00</td>';
	    html +='  	<td>Em análise</td>';
	    html +='  	<td><a href="#" target="_blank" >Acessar Doc.</a></td>';
	    html +='  </tr>';
	    html +='   <tr>';
	    html +='  <td>000000534 / 0001</td>';
	    html +='  <td> Nota de Serviço </td>';
	    html +='  <td> Marcelo Almeida </td>';
	    html +='  <td>01/04/2021</td>';
	    html +='  <td>15.000,00</td>';
	    html +='  <td>Incluída</td>';
	    html +='  <td><a href="#" target="_blank" >Acessar Doc.</a></td>';
	    html +='  </tr><tr>'
	    html +='  <td>000000354 / 0001</td>';
	    html +='  	<td> Nota de Débito </td>';
	    html +='  <td> João Francisco </td>';
	    html +='  <td>03/05/2021</td>';
	    html +='  <td>5.000,00</td>';
	    html +='  <td>Incluída</td>';
	    html +='  <td><a href="#" target="_blank" >Acessar Doc.</a></td>';
	    html +='  </tr>';
	    html +='  </div>';
	    html +='        </tbody>';
	    html +='    </table>';
	    html +='</div>';
	    html +='</div>';
	    $("#table").append(html);
    }

});

