trigger SMC_TGR_QuoteLineItemTrigger on QuoteLineItem (before delete) {
	new TH_QLI_QuoteLineItemTriggerHandler().run();
}