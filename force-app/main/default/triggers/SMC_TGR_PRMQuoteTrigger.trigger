trigger SMC_TGR_PRMQuoteTrigger on SMC_PRM_Quote__c (after insert) {
    new TH_PRMQ_PRMQuoteTriggerHandler().run();
}