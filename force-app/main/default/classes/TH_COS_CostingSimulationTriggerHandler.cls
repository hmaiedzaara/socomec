/*
----------------------------------------------------------------------------------------------
-- - Name          : TH_COS_CostingSimulationTriggerHandler
-- - Author        : Denis PHAM (VR) - MODIS
-- - Description   : Handler for trigger CostingSimulationTrigger
-- - Project       : Socomec
--
-- Maintenance History:
--
-- Date         Name        Version  Remarks
-- -----------  ----        -------  -------------------------------------------------
-- 19-JUL-2022  Denis PHAM   1.0      Initial version
----------------------------------------------------------------------------------------------
*/
public with sharing class TH_COS_CostingSimulationTriggerHandler extends TriggerHandler{
  // Maps and list initialized from the Trigger context
  private Map<Id, SMC_Costing_Simulation__c> oldMap;
  private Map<Id, SMC_Costing_Simulation__c> newMap;
  private List<SMC_Costing_Simulation__c> oldList;
  private List<SMC_Costing_Simulation__c> newList;

  // Constructor
  public TH_COS_CostingSimulationTriggerHandler() {
    this.oldMap = (Map<Id, SMC_Costing_Simulation__c>) Trigger.oldMap;
    this.newMap = (Map<Id, SMC_Costing_Simulation__c>) Trigger.newMap;
    this.oldList = (List<SMC_Costing_Simulation__c>) Trigger.Old;
    this.newList = (List<SMC_Costing_Simulation__c>) Trigger.New;
  }


  /**
  * @description Handle "Costing Simulation Before Update"
  - set TECH_SMC_Process_Instance_Id__c
  - manage Approval fields (fix)
  * @author Denis PHAM (Modis) | 19/07/2022  
  **/
  public override void beforeUpdate() {
    if (
      Pad.cantrigger(STA_UtilsStatic.CLASS_COSTING_SIMULATION_MANAGEMENT) &&
      SMC_UTIL_CheckRecursiveTrigger.runOnce()
    ) {
      System.debug(
        LoggingLevel.INFO,
        '## >>> Costing Simulation Before Update:START <<< run by ' + UserInfo.getName()
      );

      SMC_AP_ManageCostingSimulation.setProcessInstanceIdField(newMap, false);
      SMC_AP_ManageCostingSimulation.checkApprovalInformations(newMap, oldMap);

      System.debug(LoggingLevel.INFO, '## >>> Costing Simulation Before Update:END <<<');
    }
  }

  /**
  * @description Handle "Costing Simulation After Update"
  -send notification with redirection on approval
  * @author Denis PHAM (Modis) | 19/07/2022   
  **/
  public override void afterUpdate() {
    if (Pad.cantrigger(STA_UtilsStatic.CLASS_COSTING_SIMULATION_MANAGEMENT)) {
      System.debug(
        LoggingLevel.INFO,
        '## >>> Costing Simulation After Update:START <<< run by ' + UserInfo.getName()
      );

      SMC_AP_ManageCostingSimulation.sendNotificationForApprovalEnding(newMap, oldMap);

      System.debug(LoggingLevel.INFO, '## >>> Costing Simulation After Update:END <<<');
    }
  }

}