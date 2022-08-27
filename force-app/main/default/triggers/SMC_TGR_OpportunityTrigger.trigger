trigger SMC_TGR_OpportunityTrigger on Opportunity (before insert, after insert, before update, before delete) {
	new TH_OPP_OpportunityTriggerHandler().run();
}