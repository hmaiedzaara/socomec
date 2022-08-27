trigger SMC_TGR_EmailMessageTrigger on EmailMessage (before insert, after insert) {
    new TH_EM_EmailMessageTriggerHandler().run();
}