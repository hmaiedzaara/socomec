trigger SMC_TGR_SMCOpportunityActors on SMC_Opportunity_Actors__c (after insert, after update, after delete) {
	new TH_OPPACT_SMCOppActorsTriggerHandler().run();
}