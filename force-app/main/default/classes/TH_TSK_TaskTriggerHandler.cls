/*
--------------------------------------------------------------------------------------
-- - Name          : TH_TSK_TaskTriggerHandler
-- - Author        : ?????
-- - Description   : Handler for trigger TaskTrigger
-- - Project       : Socomec
--
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  -------------------------------------------------------
-- ??-???-????  ??    1.0     Initial version
-- 12-DEC-2018  VR    1.1     Add CheckRecursive and BypassAll
-- 06-APR-2020  VR    1.1     Add documentation
--------------------------------------------------------------------------------------
*/

public without sharing class TH_TSK_TaskTriggerHandler extends TriggerHandler {
  // Maps and list initialized from the Trigger context
  private Map<Id, Task> oldMap;
  private Map<Id, Task> newMap;
  private List<Task> oldList;
  private List<Task> newList;

  // Constructor
  public TH_TSK_TaskTriggerHandler() {
    this.oldMap = (Map<Id, Task>) Trigger.oldMap;
    this.newMap = (Map<Id, Task>) Trigger.newMap;
    this.oldList = (List<Task>) Trigger.Old;
    this.newList = (List<Task>) Trigger.New;
  }

  /**
  * @description Handle "Task Before Insert"
  -check if account is a GroupConsolidated
  * @author Vincent RECASENS (Modis) | 06/04/2020   
  **/
  public override void beforeInsert() {
    if (Pad.cantrigger(STA_UtilsStatic.CLASS_TASK_MANAGEMENT)) {
    System.debug(
      LoggingLevel.INFO,
      '## >>> Task Before Insert:START <<< run by ' + UserInfo.getName()
    );

    // SMC_AP_ManageTask.isParentAccountGroupConsolidated(this.newList);

    System.debug(LoggingLevel.INFO, '## >>> Task Before Insert:END <<<');
    }
  }

  /**
  * @description Handle "Task Before Update"
  -check if account is a GroupConsolidated
  * @author Vincent RECASENS (Modis) | 06/04/2020   
  **/
  public override void beforeUpdate() {
    if (Pad.cantrigger(STA_UtilsStatic.CLASS_TASK_MANAGEMENT)) {
    System.debug(
      LoggingLevel.INFO,
      '## >>> Task Before Update:START <<< run by ' + UserInfo.getName()
    );

    // SMC_AP_ManageTask.isParentAccountGroupConsolidated(this.newList);

    System.debug(LoggingLevel.INFO, '## >>> Task Before Update:END <<<');
    }
  }
}