function validateAvailableStates(iCurrentState, stateList) {

	log.info("##00 validateAvailableStates " + iCurrentState);

	if (iCurrentState != 4 && iCurrentState != 0) {

		log.info("##00 busca arquivos ");


		var cardData = hAPI.getCardData(getValue("WKNumProces"));
		var keys = cardData.keySet().toArray();

		for (var key in keys) {

			var field = keys[key]

			if (field.indexOf("forn_folderId___") > -1) {

				var index = field.replace("forn_folderId___", "");
				var folder = cardData.get("forn_folderId___" + index);

				log.info("##00 folder " + parseInt(folder));

				var arquivos = fluigAPI.getFolderDocumentService().list(parseInt(folder),0);
			
				log.info("##00 arquivos ");
				log.dir(arquivos);

				log.info("##00 size ");
				log.info(arquivos.size());


				for (var i = 0; i < arquivos.size(); i++) {

					if (arquivos.get(i).documentType == 2) {

						log.info(arquivos.get(i).documentId + ' - ' + arquivos.get(i).documentType + ' - ' + arquivos.get(i).documentDescription);

						hAPI.attachDocument(parseInt(arquivos.get(i).documentId));

					}
				}

			}
		}
	}
}