/**
 * @description       :
 * @author            : Vincent RECASENS (Modis)
 * @group             :
 * @last modified on  : 09-28-2020
 * @last modified by  : Vincent RECASENS (Modis)
 * Modifications Log
 * Ver   Date         Author                     Modification
 * 1.0   09-25-2020   Vincent RECASENS (Modis)   Initial Version
 **/
trigger SMC_TGR_ContactTrigger on Contact(before insert, before delete) {
  new TH_CTC_ContactTriggerHandler().run();
}