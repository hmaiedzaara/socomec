/**
 * @File Name          : SMC_TGR_WorkOrderTrigger.trigger
 * @Description        : 
 * @Author             : emmanuel.bernier@modis.com
 * @Group              : 
 * @Last Modified By   : emmanuel.bernier@modis.com
 * @Last Modified On   : 28/05/2020 à 14:52:23
 * @Modification Log   : 
 * Ver       Date            Author      		    Modification
 * 1.0    28/05/2020   emmanuel.bernier@modis.com     Initial Version
**/
trigger SMC_TGR_WorkOrderTrigger on WorkOrder(
  before insert,
  before update,
  before delete,
  after update
) {
  new TH_WO_WorkOrderTriggerHandler().run();
}