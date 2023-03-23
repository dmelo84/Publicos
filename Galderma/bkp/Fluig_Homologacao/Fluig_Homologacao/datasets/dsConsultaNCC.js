function createDataset(fields, constraints, sortFields) {
    var newDataset = DatasetBuilder.newDataset();
    var dataSource = "/jdbc/bancoProtheus";
    var ic = new javax.naming.InitialContext();
    var ds = ic.lookup(dataSource);
    var created = false;
    var filtro = '' //DMS
    var tabela = 'SE1020'
    	
    	if(constraints != null ){
            console.log("if tabela")
            for (d = 0; d < constraints.length; d++){
                  if( constraints[d].fieldName == 'DEPTO'){
                        tabela = constraints[d].initialValue
                  }
            }
      }
    
    var myQuery =  "select E1_PREFIXO, E1_PARCELA, E1_NUM, E1_TIPO, E1_NATUREZ, E1_CLIENTE, E1_LOJA, "
    	myQuery += "E1_NOMCLI, E1_EMISSAO, E1_VENCREA, E1_VALOR " 
    	myQuery += "from "+ tabela 
    	myQuery += "where D_E_L_E_T_ != '*' "
    	myQuery += "and E1_TIPO = 'NCC' "
    	myQuery += "and E1_SALDO > 0 "
        
            if(constraints != null ){
                  console.log("if cliente")
                  for (d = 0; d < constraints.length; d++){
                        if( constraints[d].fieldName == 'CLIENTE'){
                              filtro = constraints[d].initialValue
                              myQuery += "and E1_CLIENTE ='"+filtro+"'"
                        }
                  }
                  console.log("SQL => "+myQuery)
            }
          try {
              var conn = ds.getConnection();
              var stmt = conn.createStatement();
              var rs = stmt.executeQuery(myQuery);
              var columnCount = rs.getMetaData().getColumnCount();
              while (rs.next()) {
                  if (!created) {
                      for (var i = 1; i <= columnCount; i++) {
                          newDataset.addColumn(rs.getMetaData().getColumnName(i));
                      }
                      created = true;
                  }
                  var Arr = new Array();
                  for (var i = 1; i <= columnCount; i++) {
                      var obj = rs.getObject(rs.getMetaData().getColumnName(i));
                      if (null != obj) {
                          Arr[i - 1] = rs.getObject(rs.getMetaData().getColumnName(i)).toString();
                      } else {
                          Arr[i - 1] = "null";
                      }
                  }
                  newDataset.addRow(Arr);
              }
          } catch (e) {
              log.error("ERRO==============> " + e.message);
          } finally {
              if (stmt != null) {
                  stmt.close();
              }
              if (conn != null) {
                  conn.close();
              }
          }
    //}
    return newDataset;
}
