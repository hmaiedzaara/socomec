trigger SMC_TGR_SMCAccountActors on SMC_Account_Actors__c (after insert, after update, after delete) {
     new TH_ACCACT_SMCAccountActorsTriggerHandler().run();
}