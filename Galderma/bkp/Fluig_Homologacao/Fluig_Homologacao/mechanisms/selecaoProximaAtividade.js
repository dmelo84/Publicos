function resolve(process,colleague){
 
    var userList = new java.util.ArrayList();
 
    //-- CONSULTA A UM DATASET, DE GRUPO DE USUARIOS FLUIG
    var dtsGroup = DatasetFactory.getDataset('group',null,null,null);
    for(var g = 0; g < dtsGroup.values.length; g++){
        userList.add( 'Pool:Group:'+dtsGroup.getValue(g.toString(),"groupPK.groupId") );
    }
    
    //-- CONSULTA A UM DATASET, DE PAPEIS DE USUARIOS FLUIG
    var dtsRole = DatasetFactory.getDataset('workflowRole',null,null,null);
    for(var h = 0; h < dtsRole.values.length; h++){
        userList.add( 'Pool:Role:'+papel["workflowRolePK.roleId"] );
    }
     
    return userList;
 
}