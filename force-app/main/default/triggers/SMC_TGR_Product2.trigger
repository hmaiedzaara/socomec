trigger SMC_TGR_Product2 on Product2 (before insert, after insert, before update,after update) {
     new TH_PDT_Product2TriggerHandler().run();
}