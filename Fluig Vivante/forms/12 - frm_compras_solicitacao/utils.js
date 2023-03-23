var util = {
//teste
    stringToDate : function(stringData){
        //Converte uma string com a data no formato DD/MM/AAAA em um Date();
    
        if (stringData.split("/").length > 1) {
    
            var stringDataArr = stringData.split("/");
            var dataFormatUS = stringDataArr[2] + "-" + stringDataArr[1] + "-" + stringDataArr[0];
    
            return new Date(dataFormatUS + " 00:00:00") || false;
        }
    
        if (stringData.split("-").length > 1) {
    
            return new Date(stringData + " 00:00:00") || false;
        }
    
    
        return false;
    }
}