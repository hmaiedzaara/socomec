trigger SMC_TGR_EventTrigger on Event (before insert, after insert, before update, after update, before delete, after delete) {
     new TH_EVNT_EventTriggerHandler().run();
}