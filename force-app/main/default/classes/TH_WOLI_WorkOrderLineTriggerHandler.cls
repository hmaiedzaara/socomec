/*
----------------------------------------------------------------------------------------------
-- - Name          : TH_WOLI_WorkOrderLineTriggerHandler
-- - Author        : Emmanuel Bernier (EBR) - Modis
-- - Description   : Handler for trigger Workorderline item
-- - Project       : Socomec
--
-- Maintenance History:
--
-- Date         Name  	Version     Remarks
-- -----------  ----  	-------     -------------------------------------------------
-- 16-MAR-2020  EBR    	1.0         Initial version
-- 06-APR-2020  VRE    	1.0         Add documentation
----------------------------------------------------------------------------------------------
*/

public without sharing class TH_WOLI_WorkOrderLineTriggerHandler extends TriggerHandler {
  // Maps and list initialized from the Trigger context
  private Map<Id, WorkOrderLineItem> oldMap;
  private Map<Id, WorkOrderLineItem> newMap;
  private List<WorkOrderLineItem> oldList;
  private List<WorkOrderLineItem> newList;

  // Constructor
  public TH_WOLI_WorkOrderLineTriggerHandler() {
    this.oldMap = (Map<Id, WorkOrderLineItem>) Trigger.oldMap;
    this.newMap = (Map<Id, WorkOrderLineItem>) Trigger.newMap;
    this.oldList = (List<WorkOrderLineItem>) Trigger.Old;
    this.newList = (List<WorkOrderLineItem>) Trigger.New;
  }

  /**
  * @description Handle "WorkOrder Before Insert"
  -add product required for replacement
  * @author Vincent RECASENS (Modis) | 06/04/2020   
  **/
  public override void beforeInsert() {
    if (Pad.cantrigger(STA_UtilsStatic.CLASS_WORKORDER_MANAGEMENT)) {
      System.debug(
        LoggingLevel.INFO,
        '## >>> WorkOrder Line Item Before Insert:START <<< run by ' +
        UserInfo.getName()
      );
      SMC_AP_ManageWorkOrderLineItem.checkServiceProductOnAssetAndWorkType(
        this.newList
      );
      if (
        Pad.cantrigger(
          STA_UtilsStatic.METHOD_WOLI_UNIQUENESS_CLASS_WOLI_MANAGEMENT
        )
      ) {
        SMC_AP_ManageWorkOrderLineItem.keepUniquenessOnWorkOrder(this.newList);
      }
      System.debug(
        LoggingLevel.INFO,
        '## >>> WorkOrder Line Item Before Insert:END <<<'
      );
    }
  }

  /**
  * @description Handle "WorkOrder After Insert"
  -add product required for replacement
  * @author Vincent RECASENS (Modis) | 06/04/2020   
  **/
  public override void afterInsert() {
    if (Pad.cantrigger(STA_UtilsStatic.CLASS_WORKORDER_MANAGEMENT)) {
      System.debug(
        LoggingLevel.INFO,
        '## >>> WorkOrder Line Item After Insert:START <<< run by ' +
        UserInfo.getName()
      );
      //SMC_AP_ManageWorkOrderLineItem.addRequiredPartForReplacement(this.newMap);
      SMC_AP_ManageWorkOrderLineItem.testRequiredTime(this.newList);
      SMC_AP_ManageWorkOrderLineItem.flagWOForWOLICommissionning(this.newMap);
      System.debug(
        LoggingLevel.INFO,
        '## >>> WorkOrder Line Item After Insert:END <<<'
      );
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
        '## >>> WorkOrder Line ItemLine Before Update:START <<< run by ' +
        UserInfo.getName()
      );
      SMC_AP_ManageWorkOrderLineItem.preventCancel(this.oldMap, this.newMap);
      SMC_AP_ManageWorkOrderLineItem.preventComplete(this.oldMap, this.newMap);
      // SMC_AP_ManageWorkOrderLineItem.checkConsumedProduct(this.newMap);
      SMC_AP_ManageWorkOrderLineItem.toggleAbortedWoli(
        this.newMap,
        this.oldMap
      );
      System.debug(
        LoggingLevel.INFO,
        '## >>> WorkOrder Line ItemLine Before Update:END <<<'
      );
    }
  }

  /**
  * @description Handle "WorkOrder After Insert"
  -add product required for replacement
  * @author Vincent RECASENS (Modis) | 06/04/2020   
  **/
  public override void afterUpdate() {
    if (Pad.cantrigger(STA_UtilsStatic.CLASS_WORKORDER_MANAGEMENT)) {
      System.debug(
        LoggingLevel.INFO,
        '## >>> WorkOrder Line Item After Update:START <<< run by ' +
        UserInfo.getName()
      );
      SMC_AP_ManageWorkOrderLineItem.testRequiredTime(this.newList);
      SMC_AP_ManageWorkOrderLineItem.handleDecomissionningLineClose(
        this.newList,
        this.oldMap
      );
      SMC_AP_ManageWorkOrderLineItem.addInstallNoteOnAsset(
        this.oldMap,
        this.newMap
      );
      SMC_AP_ManageWorkOrderLineItem.manageAssetFromWoliCompleted(
        this.oldMap,
        this.newMap
      );
      SMC_AP_ManageWorkOrderLineItem.manageAssetFromWoliCompletedInstalationType(
        this.oldMap,
        this.newMap
      );
      SMC_AP_ManageWorkOrderLineItem.passWOStatusToCompleted(this.oldMap, this.newMap);
      System.debug(
        LoggingLevel.INFO,
        '## >>> WorkOrder Line Item Update Insert:END <<<'
      );
    }
  }

  /**
  * @description Handle "WorkOrder Before Delete"
  -prevent cancel if link to a product or labor
  * @author Vincent RECASENS (Modis) | 06/04/2020   
  **/
  public override void beforeDelete() {
    if (Pad.cantrigger(STA_UtilsStatic.CLASS_WORKORDER_MANAGEMENT)) {
      System.debug(
        LoggingLevel.INFO,
        '## >>> WorkOrderLine Before Delete:START <<< run by ' +
        UserInfo.getName()
      );
      if (SMC_AP_ManageWorkOrderLineItem.preventCancelDelete(this.oldMap)) {
        SMC_AP_ManageWorkOrderLineItem.checkSkillRequirementToDelete(
          this.oldMap
        );
      }
      System.debug(
        LoggingLevel.INFO,
        '## >>> WorkOrderLine Before Delete:END <<<'
      );
    }
  }
}