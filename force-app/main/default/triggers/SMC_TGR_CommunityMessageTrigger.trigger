trigger SMC_TGR_CommunityMessageTrigger on SMC_Community_Message__c (before insert) {
    new TH_CM_CommunityMessageTrigger().run();
}