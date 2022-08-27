trigger SMC_TGR_ContentVersion on ContentVersion (before insert, after insert, before update) {
    new TH_CV_ContentVersionTriggerHandler().run();
}