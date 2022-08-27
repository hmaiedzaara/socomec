trigger SMC_TGR_ContentDocumentLinkTrigger on ContentDocumentLink (after insert, before delete) {
    new TH_CDL_ContentDocumentLinkTriggerHandler().run();
}