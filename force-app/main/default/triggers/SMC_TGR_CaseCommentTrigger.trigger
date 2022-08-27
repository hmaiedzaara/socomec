trigger SMC_TGR_CaseCommentTrigger on CaseComment (before insert, after insert) {
    new TH_CCMT_CaseCommentTriggerHandler().run();
}