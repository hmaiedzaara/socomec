trigger SMC_TGR_GTLTrigger on SMC_GTL__c (before insert, before update, after update) {
    new TH_ASS_GTLTrigger().run(); 
}