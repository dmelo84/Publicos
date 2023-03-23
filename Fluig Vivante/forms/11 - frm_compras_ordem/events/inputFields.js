function inputFields(form) {
    log.info("### Input field WKNumState ");

    var WKNumState = getValue("WKNumState");
    WKNumState == 0 ? WKNumState = 4 : false;

    if (WKNumState == 4) {

        var indexes = form.getChildrenIndexes("tblItensOrdem");

        for (var i = 0; i < indexes.length; i++) {
            var controlado = form.getValue("itemcontrl___" + indexes[i]);

            if (controlado != "") {
                //form.setValue("pendenteAprovSindico", "S");
            }
        }
    }
}