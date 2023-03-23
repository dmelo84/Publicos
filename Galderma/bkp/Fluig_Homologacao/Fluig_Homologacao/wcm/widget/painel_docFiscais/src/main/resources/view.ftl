<div id="painel_Doc_${instanceId}" class="super-widget wcm-widget-class fluig-style-guide"
     data-params="painel_Doc.instance()">
	<div id="target">
			<div class="table-datatable">
			    <div class="panel panel-default">
			      
			        <div class="panel-body">
			            <div class="row">
				                <div class="col-md-2">
				                    <div class="form-group">
				                    <label>Nº. Documento:</label>
				                        <input type="text" name="numDoc_${instanceId}" id="numDoc_${instanceId}" class="form-control">
				                    </div>
				                </div>
				                 <div class="col-md-2">
				                    <div class="form-group">
				                    <label>Emissão De:</label>
				                        <input type="date" class="form-control" name="EmissaoDe_${instanceId}"  id="EmissaoDe_${instanceId}" 
				                        >
				                    </div>
				                </div>
				                 <div class="col-md-2">
				                    <div class="form-group">
				                     <label>Emissão Até:</label>
				                        <input type="date" class="form-control" name="EmissaoAte_${instanceId}" id="EmissaoAte_${instanceId}">
				                    </div>
				                </div>
				                 <div class="col-md-2">
				                    <div class="form-group">
				                    <label>Responsável:</label>
				                        <input type="text" class="form-control" name="Responsavel_${instanceId}" id="Responsavel_${instanceId}">
	                                </div>
				                </div>
				                 <div class="col-md-2">
						       		<label>Status:</label>
					       			 <input type="text" class="form-control" name="status_${instanceId}" id="status_${instanceId}">
					       		</div>
					       		<div class="col-md-2" style="margin-top: 5px;padding-left: 0px;">
				                    <div class="btn-group col-md-6" style="padding-left: 0px;">
				                    	<br>
				                        <button type="button" class="btn btn-primary" data-loadTable>Pesquisar</button>
				                    </div>
				                     <div class="btn-group col-md-6" style="right: 10px;padding-right: 0px;">
					            	 	<br>
					                        <button type="button" class="btn btn-success"> Incluir Doc.</button>
					                 </div>
				                </div>
				           </div>
				           <div class="row">
				           	 <div class="col-md-2">
						       		<label>Tipo Doc.:</label>
					       			 <input type="text" class="form-control" name="status_${instanceId}" id="status_${instanceId}">
					       		</div>
				           </div>
			        </div>
			        <!-- Table -->
			        <div id="table"></div>
			    </div>
			</div>	
	</div> 
     
</div>
<script src="/webdesk/vcXMLRPC.js" type="text/javascript"></script>