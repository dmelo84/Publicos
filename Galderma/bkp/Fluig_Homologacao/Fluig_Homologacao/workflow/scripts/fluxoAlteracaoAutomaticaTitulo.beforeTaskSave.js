function beforeTaskSave(colleagueId, nextSequenceId, userList) {

    var atv      = getValue("WKNumState");
    var nextAtv  = getValue("WKNextState");

    if (atv == 5) {

        var anexos   = hAPI.listAttachments();
        var temAnexo = false;

        if (anexos.size() > 0) {
            temAnexo = true;
        }

        if (!temAnexo) {
            throw "É preciso anexar o documento para continuar o processo!";
        }

    }
}