trigger SMC_TGR_CaseTrigger on Case (before insert, after insert, before update, after update) {
    new TH_CASE_CaseTriggerHandler().run();
}