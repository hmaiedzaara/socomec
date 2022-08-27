trigger SMC_TGR_TaskTrigger on Task (before insert, before update) {
    new TH_TSK_TaskTriggerHandler().run();
}