function inputFields(form){


    if (form.getValue("data_solicitacao").match("^[0-3]?[0-9]/[0-3]?[0-9]/(?:[0-9]{2})?[0-9]{2}$")) {
        var split = form.getValue("data_solicitacao").split('/');
        form.setValue("data_solicitacao", split[0] + '/' + split[1] + '/' + split[2]);
    }
}