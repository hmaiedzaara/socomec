/**
 * @description       : 
 * @author            : Vincent RECASENS (Modis)
 * @group             : 
 * @last modified on  : 12-24-2020
 * @last modified by  : Vincent RECASENS (Modis)
 * Modifications Log 
 * Ver   Date         Author                     Modification
 * 1.0   12-24-2020   Vincent RECASENS (Modis)   Initial Version
**/
trigger SMC_TGR_LoraKeyRequestor on SMC_Lorawan_Keys_Requestor__c(after update) {
    new TH_LKR_RequestorTriggerHandler().run();
}