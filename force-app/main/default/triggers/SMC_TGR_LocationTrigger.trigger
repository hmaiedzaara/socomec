trigger SMC_TGR_LocationTrigger on Location (before update, after update) {
    new TH_LO_LocationTriggerHandler().run(); 
}