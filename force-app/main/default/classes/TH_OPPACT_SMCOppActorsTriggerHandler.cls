/*
--------------------------------------------------------------------------------------
-- - Name          : TH_OPPACT_SMCOppActorsTriggerHandler
-- - Author        : David SOBCZAK (DOS) - Socomec
-- - Description   : Handler for trigger EventTrigger
-- - Project       : Socomec
--
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  -------------------------------------------------------
-- 17-Oct-2017  DOS    1.0     Initial version
-- 12-DEC-2018  VRE    1.1     Add CheckRecursive and BypassAll
-- 06-APR-2020  VRE    1.1     Add documentation
--------------------------------------------------------------------------------------
*/

public without sharing class TH_OPPACT_SMCOppActorsTriggerHandler extends TriggerHandler {
  // Maps and list initialized from the Trigger context
  private Map<Id, SMC_Opportunity_Actors__c> oldMap;
  private Map<Id, SMC_Opportunity_Actors__c> newMap;
  private List<SMC_Opportunity_Actors__c> oldList;
  private List<SMC_Opportunity_Actors__c> newList;

  // Constructor
  public TH_OPPACT_SMCOppActorsTriggerHandler() {
    this.oldMap = (Map<Id, SMC_Opportunity_Actors__c>) Trigger.oldMap;
    this.newMap = (Map<Id, SMC_Opportunity_Actors__c>) Trigger.newMap;
    this.oldList = (List<SMC_Opportunity_Actors__c>) Trigger.Old;
    this.newList = (List<SMC_Opportunity_Actors__c>) Trigger.New;
  }

  /**
  * @description Handle "Event After Insert"
  -manage opportunity actors
  * @author Vincent RECASENS (Modis) | 06/04/2020   
  **/
  public override void afterInsert() {
    if (Pad.cantrigger(STA_UtilsStatic.CLASS_SMCOPPORTUNITYACTORS_MANAGEMENT)) {
      System.debug(
        LoggingLevel.INFO,
        '## >>> OPPACT After Insert :START <<< run by ' + UserInfo.getName()
      );

      SMC_AP_ManageSMCOpportunityActors.syncWithOppContactRoles(
        this.oldList,
        this.newList
      );

      System.debug(LoggingLevel.INFO, '## >>> OPPACT After Insert:END <<<');
    }
  }

  /**
  * @description Handle "Event After Update"
  -manage opportunity actors
  * @author Vincent RECASENS (Modis) | 06/04/2020   
  **/
  public override void afterUpdate() {
    if (Pad.cantrigger(STA_UtilsStatic.CLASS_SMCOPPORTUNITYACTORS_MANAGEMENT)) {
      System.debug(
        LoggingLevel.INFO,
        '## >>> OPPACT After Update:START <<< run by ' + UserInfo.getName()
      );

      SMC_AP_ManageSMCOpportunityActors.syncWithOppContactRoles(
        this.oldList,
        this.newList
      );

      System.debug(LoggingLevel.INFO, '## >>> OPPACT After Update:END <<<');
    }
  }

  /**
  * @description Handle "Event After Delete"
  -manage opportunity actors
  * @author Vincent RECASENS (Modis) | 06/04/2020   
  **/
  public override void afterDelete() {
    if (Pad.cantrigger(STA_UtilsStatic.CLASS_SMCOPPORTUNITYACTORS_MANAGEMENT)) {
      System.debug(
        LoggingLevel.INFO,
        '## >>> OPPACT After Delete:START <<< run by ' + UserInfo.getName()
      );

      SMC_AP_ManageSMCOpportunityActors.syncWithOppContactRoles(
        this.oldList,
        this.newList
      );

      System.debug(LoggingLevel.INFO, '## >>> OPPACT After Delete:END <<<');
    }
  }
}