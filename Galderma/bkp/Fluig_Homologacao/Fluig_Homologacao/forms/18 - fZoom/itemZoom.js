function setSelectedZoomItem(selectedItem) {
      var NAME = "codFor";
      var NAME2 = "nome";

      if( selectedItem.inputId.indexOf(NAME) != -1 || selectedItem.inputId.indexOf(NAME2) != -1){
    	  /*
            var cLin = selectedItem.inputId;
            var nPos = cLin.length-1;
            var nPosAtu = cLin.substring(nPos,cLin.length);
            var cFilial = $("#cmpc1filial2").val();
            var cB1Cod = $("#itc1cod2___"+nPosAtu).val();
            var cFiltr = "";
            var cFiltr2= "";
            var datasetReturned = null;
            var records = null;
            var datasetReturned2 = null;
            var records2 = null;
          */
    	  	var records = null;
    	  	var datasetReturned = null;
    	    var cFiltr = "";
    	  	var cLin = selectedItem.inputId;
    	  	var nPos = cLin.length-1;
    	  	var nPosAtu = cLin.substring(nPos,cLin.length);
    	  	var cB1Cod = $("#codFor___"+nPosAtu).val();
    	  	    	  	
            if (cB1Cod == null || cB1Cod == ""){
                  cB1Cod = $("#codFor___"+nPosAtu).val();
           
            }
      /*
            cFilial = cFilial[0].split(" - ");
            cFilial = cFilial[0].substring(0,4);
            cB1Cod = cB1Cod[0].split(" - ");
            cB1Cod = cB1Cod[1].trim();
            cFiltr = DatasetFactory.createConstraint("B1_COD",cFilial,cB1Cod, ConstraintType.MUST);
            datasetReturned = DatasetFactory.getDataset("ds_QSQTSB1", null, new Array(cFiltr), null);
      */
      		cFiltr = DatasetFactory.createConstraint("codigo",cB1Cod,cB1Cod, ConstraintType.MUST);
      	    datasetReturned = DatasetFactory.getDataset("dsConsFornece", null, new Array(cFiltr), null);
      
            if (datasetReturned != null && datasetReturned.values != null && datasetReturned.values.length > 0){
                  records = datasetReturned.values[0];
                  console.log(records)
                  setZoomData("nome___"+ nPosAtu ,records.Nome);
                  /*
                  setZoomData("itc1desc2___"+ nPosAtu ,records.B1_DESC);
                  setZoomData("itc1local2___"+ nPosAtu ,records.B1_LOCPAD);
                  setZoomData("itc1conta2___"+ nPosAtu ,records.B1_XCONTA);
                  cFiltr2 = DatasetFactory.createConstraint("CT1_CONTA",records.B1_XCONTA,records.B1_XCONTA, ConstraintType.MUST);
                  datasetReturned2 = DatasetFactory.getDataset("ds_QSQTCT1", null, new Array(cFiltr2), null);
                  if (datasetReturned2 != null && datasetReturned2.values != null && datasetReturned2.values.length > 0){
                        records2 = datasetReturned2.values[0];
                        setZoomData("itc1contad2___"+ nPosAtu ,records2.CT1_DESC01);
                  }
                  */
            }
      }

}