/*
--------------------------------------------------------------------------------------
-- - Name          : TH_EVNT_EventTriggerHandler
-- - Author        : David SOBCZAK (DOS) - Socomec
-- - Description   : Handler for trigger EventTrigger
-- - Project       : Socomec
--
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  -------------------------------------------------------
-- 31-Mai-2017  DOS    1.0     Initial version
-- 23-Aug-2017  DOS    1.1     Add Accompanied by management
-- 12-DEC-2018  VR     1.2     Add CheckRecursive and BypassAll
-- 06-APR-2020  VRE    1.3     Add documentation
--------------------------------------------------------------------------------------
*/

public without sharing class TH_EVNT_EventTriggerHandler extends TriggerHandler {
  // Maps and list initialized from the Trigger context
  private Map<Id, Event> oldMap;
  private Map<Id, Event> newMap;
  private List<Event> oldList;
  private List<Event> newList;
  private Boolean bypassSFOutlook;

  // Constructor
  public TH_EVNT_EventTriggerHandler() {
    this.oldMap = (Map<Id, Event>) Trigger.oldMap;
    this.newMap = (Map<Id, Event>) Trigger.newMap;
    this.oldList = (List<Event>) Trigger.Old;
    this.newList = (List<Event>) Trigger.New;

    //Get user.TECH_SMC_PAD_Bypass_All_Trigger__c
    if (Pad.cantrigger(STA_UtilsStatic.CLASS_EVENT_MANAGEMENT)) {
      User contextUser = [
        SELECT SMC_Is_Lightning_Sync__c
        FROM User
        WHERE Id = :UserInfo.getUserId()
      ];
      this.bypassSFOutlook = contextUser.SMC_Is_Lightning_Sync__c;
    }
  }

  /**
  * @description Handle "Event Before Insert"
  -check if account is a GroupConsolidated
  -fill SMC_ContactId__c with WhoId is not 
  * @author Vincent RECASENS (Modis) | 06/04/2020   
  **/
  public override void beforeInsert() {
    if (Pad.cantrigger(STA_UtilsStatic.CLASS_EVENT_MANAGEMENT)) {
      System.debug(
        LoggingLevel.INFO,
        '## >>> Event Before Insert:START <<< run by ' + UserInfo.getName()
      );

      //DPHA - RT has been removed from the Account, so the function is useless 
      //SMC_AP_ManageEvent.isParentAccountGroupConsolidated(this.newList);
      SMC_AP_ManageEvent.fillContactFieldWithWhoId(this.newList, null);
      SMC_AP_ManageEvent.populateEvntDescription(this.newList);

      SMC_AP_ManageEvent.populateEvntLocationWithRelatedAddress(this.newList);

      System.debug(LoggingLevel.INFO, '## >>> Event Before Insert:END <<<');
    }
  }

  /**
  * @description Handle "Event After Insert"
  -populate fields : Location + Description
  -manage Invitee and Pilot
  * @author Vincent RECASENS (Modis) | 06/04/2020   
  **/
  public override void afterInsert() {
    if (Pad.cantrigger(STA_UtilsStatic.CLASS_EVENT_MANAGEMENT)) {
      System.debug(
        LoggingLevel.INFO,
        '## >>> Event After Insert :START <<< run by ' + UserInfo.getName()
      );

      //   SMC_AP_ManageEvent.populateEvntLocationWithRelatedAddress_Future(
      //     this.newMap.keySet()
      //   );
      // SMC_AP_ManageEvent.populateEvntDescription_Future(this.newList);
      SMC_AP_ManageEvent.managePilotNotificationInsertOrDelete(
        this.newMap,
        true
      );
      if (!bypassSFOutlook) {
        SMC_AP_ManageEvent.manageAccompaniedByInviteeOnInsert(this.newMap);
      }

      System.debug(LoggingLevel.INFO, '## >>> Event After Insert:END <<<');
    }
  }

  /**
  * @description Handle "Event Before Update"
  -check if account is a GroupConsolidated
  -fill SMC_ContactId__c with WhoId is not 
  -manage Invitee
  * @author Vincent RECASENS (Modis) | 06/04/2020   
  **/
  public override void beforeUpdate() {
    if (Pad.cantrigger(STA_UtilsStatic.CLASS_EVENT_MANAGEMENT)) {
      System.debug(
        LoggingLevel.INFO,
        '## >>> Event Before Update:START <<< run by ' + UserInfo.getName()
      );

      //SMC_AP_ManageEvent.isParentAccountGroupConsolidated(this.newList);
      SMC_AP_ManageEvent.fillContactFieldWithWhoId(this.newList, this.oldMap);
      if (!bypassSFOutlook) {
        SMC_AP_ManageEvent.manageAccompaniedByInviteeOnUpdate(
          this.newMap,
          this.oldMap
        );
      }

      System.debug(LoggingLevel.INFO, '## >>> Event Before Update:END <<<');
    }
  }

  /**
  * @description Handle "Event After Update"
  -manage Pilot
  -check if relations aren't break
  * @author Vincent RECASENS (Modis) | 06/04/2020   
  **/
  public override void afterUpdate() {
    //!System.isFuture() WORKAROUND to avoid to duplicate trigger with the future method
    //populateEvntLocationWithRelatedAddress/populateEvntDescription
    if (
      Pad.cantrigger(STA_UtilsStatic.CLASS_EVENT_MANAGEMENT) &&
      !System.isFuture()
      ) {
      System.debug(
        LoggingLevel.INFO,
        '## >>> Event After Update:START <<< run by ' + UserInfo.getName()
      );
      SMC_AP_ManageEvent.managePilotNotificationUpdate(
        this.newMap,
        this.oldMap
      );

      if (!bypassSFOutlook) {
        SMC_AP_ManageEvent.checkEventRelationAfterUpdate(this.newMap);
      }

      System.debug(LoggingLevel.INFO, '## >>> Event After Update:END <<<');
    }
  }

  /**
  * @description Handle "Event Before Delete"
  -populate fields : Location + Description
  -manage Invitee and Pilot
  * @author Vincent RECASENS (Modis) | 06/04/2020   
  **/
  public override void beforeDelete() {
    if (Pad.cantrigger(STA_UtilsStatic.CLASS_EVENT_MANAGEMENT)) {
      System.debug(
        LoggingLevel.INFO,
        '## >>> Event Before Delete:START <<< run by ' + UserInfo.getName()
      );
      SMC_AP_ManageEvent.managePilotNotificationInsertOrDelete(
        this.oldMap,
        false
      );
      if (!bypassSFOutlook) {
        SMC_AP_ManageEvent.manageAccompaniedByInviteeOnDelete(this.oldMap);
      }

      System.debug(LoggingLevel.INFO, '## >>> Event Before Delete:END <<<');
    }
  }
}