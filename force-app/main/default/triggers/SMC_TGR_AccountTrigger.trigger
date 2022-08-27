trigger SMC_TGR_AccountTrigger on Account (before insert, after insert, after update, before delete) {
    new TH_ACC_AccountTriggerHandler().run();
}