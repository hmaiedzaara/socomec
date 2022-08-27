/**
 * @description       : 
 * @author            : Vincent RECASENS (Modis)
 * @group             : 
 * @last modified on  : 11-24-2020
 * @last modified by  : Vincent RECASENS (Modis)
 * Modifications Log 
 * Ver   Date         Author                     Modification
 * 1.0   11-24-2020   Vincent RECASENS (Modis)   Initial Version
**/
trigger SMC_TGR_WorkOrderLineTrigger on WorkOrderLineItem(
  before insert,
  before update,
  before delete,
  after insert,
  after update
) {
  new TH_WOLI_WorkOrderLineTriggerHandler().run();
}