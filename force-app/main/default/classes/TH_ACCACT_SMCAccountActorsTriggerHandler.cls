/*
--------------------------------------------------------------------------------------
-- - Name          : TH_ACCACT_SMCAccountActorsTriggerHandler
-- - Author        : David SOBCZAK (DOS) - Socomec
-- - Description   : Handler for trigger SMC_TGR_SMCAccountActors
-- - Project       : Socomec
--
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  -------------------------------------------------------
-- 24-Aug-2017  DOS    1.0     Initial version
-- 12-DEC-2018  VR     1.1     Add CheckRecursive and BypassAll
-- 06-APR-2020  VR     1.1     Add documentation
--------------------------------------------------------------------------------------
*/

public without sharing class TH_ACCACT_SMCAccountActorsTriggerHandler extends TriggerHandler {
  // Maps and list initialized from the Trigger context
  private Map<Id, SMC_Account_Actors__c> oldMap;
  private Map<Id, SMC_Account_Actors__c> newMap;
  private List<SMC_Account_Actors__c> oldList;
  private List<SMC_Account_Actors__c> newList;

  // Constructor
  public TH_ACCACT_SMCAccountActorsTriggerHandler() {
    this.oldMap = (Map<Id, SMC_Account_Actors__c>) Trigger.oldMap;
    this.newMap = (Map<Id, SMC_Account_Actors__c>) Trigger.newMap;
    this.oldList = (List<SMC_Account_Actors__c>) Trigger.Old;
    this.newList = (List<SMC_Account_Actors__c>) Trigger.New;
  }

  /**
  * @description Handle "AccountActors After Insert"
  -manage Account actors (insert)
  * @author Vincent RECASENS (Modis) | 06/04/2020   
  **/
  public override void afterInsert() {
    if (Pad.cantrigger(STA_UtilsStatic.CLASS_SMCACCOUNTACTORS_MANAGEMENT) &&
      SMC_UTIL_CheckRecursiveTrigger.runOnce()) {
      System.debug(
        LoggingLevel.INFO,
        '## >>> AccountActors After Insert :START <<< run by ' +
        UserInfo.getName()
      );

      SMC_AP_ManageSMCAccountActors.bidirectionalActorsManagement(
        this.oldList,
        this.newList,
        this.oldMap,
        true
      );

      System.debug(
        LoggingLevel.INFO,
        '## >>> AccountActors After Insert:END <<<'
      );
    }
  }

  /**
  * @description Handle "AccountActors After Update"
  -manage Account actors (update)
  * @author Vincent RECASENS (Modis) | 06/04/2020   
  **/
  public override void afterUpdate() {
    if (
      Pad.cantrigger(STA_UtilsStatic.CLASS_SMCACCOUNTACTORS_MANAGEMENT) &&
      SMC_UTIL_CheckRecursiveTrigger.runOnce()) {
      System.debug(
        LoggingLevel.INFO,
        '## >>> AccountActors After Update:START <<< run by ' +
        UserInfo.getName()
      );

      SMC_AP_ManageSMCAccountActors.bidirectionalActorsManagement(
        this.oldList,
        this.newList,
        this.oldMap,
        false
      );

      System.debug(
        LoggingLevel.INFO,
        '## >>> AccountActors After Update:END <<<'
      );
    }
  }

  /**
  * @description Handle "AccountActors After Delete"
  -manage Account actors (delete)
  * @author Vincent RECASENS (Modis) | 06/04/2020   
  **/
  public override void afterDelete() {
    if (
      Pad.cantrigger(STA_UtilsStatic.CLASS_SMCACCOUNTACTORS_MANAGEMENT) &&
      SMC_UTIL_CheckRecursiveTrigger.runOnce()) {
      System.debug(
        LoggingLevel.INFO,
        '## >>> AccountActors After Delete:START <<< run by ' +
        UserInfo.getName()
      );

      SMC_AP_ManageSMCAccountActors.bidirectionalActorsManagement(
        this.oldList,
        this.newList,
        this.oldMap,
        null
      );

      System.debug(
        LoggingLevel.INFO,
        '## >>> AccountActors After Delete:END <<<'
      );
    }
  }
}