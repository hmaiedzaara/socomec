trigger SMC_TGR_ContentDocument on ContentDocument (before delete) {
	new TH_CD_ContentDocumentTriggerHandler().run();
}