trigger SMC_TGR_AssociatedLocationTrigger on AssociatedLocation (after insert) {
    new TH_AL_AssociatedLocationTriggerHandler().run();
}