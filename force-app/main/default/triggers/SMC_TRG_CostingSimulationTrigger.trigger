/**
 * @File Name          : SMC_TGR_CostingSimulationTrigger.trigger
 * @Description        :
 * @Author             : Denis PHAM (Modis)
 * @Group              :
 * @Last Modified By   : 
 * @Last Modified On   : 
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0       19/07/2022      Denis PHAM (Modis)     Initial Version
 **/

trigger SMC_TRG_CostingSimulationTrigger on SMC_Costing_Simulation__c (
    before update,
    after update) 
{
    new TH_COS_CostingSimulationTriggerHandler().run();
}