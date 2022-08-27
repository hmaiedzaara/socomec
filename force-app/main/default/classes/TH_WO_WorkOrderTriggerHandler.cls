/*
----------------------------------------------------------------------------------------------
-- - Name          : TH_WO_WorkOrderTriggerHandler
-- - Author        : Emmanuel Bernier (EBR) - Modis
-- - Description   : Handler for trigger Workorder
-- - Project       : Socomec
--
-- Maintenance History:
--
-- Date         Name  	Version     Remarks
-- -----------  ----  	-------     -------------------------------------------------
-- 16-MAR-2020  EBR    	1.0         Initial version
-- 06-APR-2020  VR      1.1         Add documentation
----------------------------------------------------------------------------------------------
*/

public without sharing class TH_WO_WorkOrderTriggerHandler extends TriggerHandler {
  // Maps and list initialized from the Trigger context
  private Map<Id, WorkOrder> oldMap;
  private Map<Id, WorkOrder> newMap;
  private List<WorkOrder> oldList;
  private List<WorkOrder> newList;

  // Constructor
  public TH_WO_WorkOrderTriggerHandler() {
    this.oldMap = (Map<Id, WorkOrder>) Trigger.oldMap;
    this.newMap = (Map<Id, WorkOrder>) Trigger.newMap;
    this.oldList = (List<WorkOrder>) Trigger.Old;
    this.newList = (List<WorkOrder>) Trigger.New;
  }

  /**
  * @description Handle "WorkOrder Before Insert"
  - fill Comment from location additionnal infos
  * @author Vincent RECASENS (Modis) | 06/04/2020   
  **/
  public override void beforeInsert() {
    if (Pad.cantrigger(STA_UtilsStatic.CLASS_WORKORDER_MANAGEMENT)) {
      System.debug(
        LoggingLevel.INFO,
        '## >>> WorkOrder Before Insert:START <<< run by ' + UserInfo.getName()
      );
      SMC_AP_ManageWorkOrder.fillCommentForTechnicianWithAdditionnalInfosFromLocation(this.newList);
      System.debug(LoggingLevel.INFO, '## >>> WorkOrder Before Insert:END <<<');
    }
  }

  /**
  * @description Handle "WorkOrder Before Update"
  -prevent cancel if link to a product or labor
  * @author Vincent RECASENS (Modis) | 06/04/2020   
  **/
  public override void beforeUpdate() {
    if (Pad.cantrigger(STA_UtilsStatic.CLASS_WORKORDER_MANAGEMENT)) {
      System.debug(
        LoggingLevel.INFO,
        '## >>> WorkOrder Before Update:START <<< run by ' + UserInfo.getName()
      );
      SMC_AP_ManageWorkOrder.preventCancel(this.oldMap, this.newMap);
      SMC_AP_ManageWorkOrder.preventCompleteIfQuantityConsumedNotfilled(
        this.newMap,
        this.oldMap
      );
      System.debug(LoggingLevel.INFO, '## >>> WorkOrder Before Update:END <<<');
    }
  }

  /**
   * @description "WorkOrder after update"
   * @author emmanuel.bernier@modis.com | 28/05/2020
   * @return void
   **/
  public override void afterUpdate() {
    if (Pad.cantrigger(STA_UtilsStatic.CLASS_WORKORDER_MANAGEMENT)) {
      System.debug(
        LoggingLevel.INFO,
        '## >>> WorkOrder After Update:START <<< run by ' + UserInfo.getName()
      );
      SMC_AP_ManageWorkOrder.syncSaOnWorkorderProgress(newList, oldMap);
      Map<Id, Workorder> completedWorkOrderMap = SMC_AP_ManageWorkOrder.filterCompletedWorkOrder(
        newList,
        oldMap
      );
      SMC_AP_ManageWorkOrder.updateAssetOnWorkOrderCompletion(
        this.newMap,
        this.oldMap
      );
      SMC_AP_ManageWorkOrder.updateServiceAppointmentForCommissionningWO(
        this.newMap,
        this.oldMap
      );
      SMC_AP_ManageWorkOrder.updateServiceAppointmentForDurationModification(
        this.newMap,
        this.oldMap
      );
      if (completedWorkOrderMap.size() > 0) {
        SMC_AP_ManageWorkOrder.syncStartEndDateCustomAndStandard(
          newList,
          oldMap
        );
      }
      System.debug(LoggingLevel.INFO, '## >>> WorkOrder After Update:END <<<');
    }
  }

  /**
  * @description Handle "WorkOrder Before Delete"
  -prevent deletion if link to a product or labor
  * @author Vincent RECASENS (Modis) | 06/04/2020   
  **/
  public override void beforeDelete() {
    if (Pad.cantrigger(STA_UtilsStatic.CLASS_WORKORDER_MANAGEMENT)) {
      System.debug(
        LoggingLevel.INFO,
        '## >>> WorkOrder Before Delete:START <<< run by ' + UserInfo.getName()
      );
      SMC_AP_ManageWorkOrder.preventCancelDelete(this.oldMap);
      System.debug(LoggingLevel.INFO, '## >>> WorkOrder Before Delete:END <<<');
    }
  }
}