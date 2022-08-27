/*
--------------------------------------------------------------------------------------
-- - Name          : TH_CTC_ContactTriggerHandler
-- - Author        : Xavier BRANCHE (XB) - Modis
-- - Description   : Handler for trigger ContactTrigger
-- - Project       : Socomec
--
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  -------------------------------------------------------
-- 28-JUL-2017  XB    1.0     Initial version
-- 12-DEC-2018  VR    1.1     Add CheckRecursive and BypassAll
-- 06-APR-2020  VR    1.1     Add documentation
--------------------------------------------------------------------------------------
*/

public with sharing class TH_CTC_ContactTriggerHandler extends TriggerHandler {
  // Maps and list initialized from the Trigger context
  private Map<Id, Contact> oldMap;
  private Map<Id, Contact> newMap;
  private List<Contact> oldList;
  private List<Contact> newList;

  // Constructor
  public TH_CTC_ContactTriggerHandler() {
    this.oldMap = (Map<Id, Contact>) Trigger.oldMap;
    this.newMap = (Map<Id, Contact>) Trigger.newMap;
    this.oldList = (List<Contact>) Trigger.Old;
    this.newList = (List<Contact>) Trigger.New;
  }

  /**
  * @description Handle "Contact Before Insert"
  -check if Sync is active and valide
  * @author Vincent RECASENS (Modis) | 06/04/2020   
  **/
  public override void beforeInsert() {
    if (Pad.cantrigger(STA_UtilsStatic.CLASS_CONTACT_MANAGEMENT)) {
      System.debug(
        LoggingLevel.INFO,
        '## >>> Contact Before Insert:START <<< run by ' + UserInfo.getName()
      );

      //    SMC_AP_ManageContact.eraseCrmCode(this.newList);
      SMC_AP_ManageContact.showMessageSyncContact(this.newList);

      System.debug(LoggingLevel.INFO, '## >>> Contact Before Insert:END <<<');
    }
  }

  /*
Handle "Contact Before Delete"
*/

  /**
  * @description Handle "Contact Before Delete"
  -check if user can delete contact and if contact can be deleted (link to opportunities or not)
  * @author Vincent RECASENS (Modis) | 06/04/2020   
  **/
  public override void beforeDelete() {
    if (Pad.cantrigger(STA_UtilsStatic.CLASS_CONTACT_MANAGEMENT)) {
      System.debug(
        LoggingLevel.INFO,
        '## >>> Contact Before Delete:START <<< run by ' + UserInfo.getName()
      );

      // SMC_AP_ManageContact.checkContactToMassDeleteAndLinkOpportunity(
      //   this.oldMap
      // );
      SMC_AP_ManageContact.preventDeletionContact(this.oldMap);

      // SMC_AP_ManageContact.checkActivitiesOnContact(
      //   this.oldMap
      // );

      System.debug(LoggingLevel.INFO, '## >>> Contact Before Delete:END <<<');
    }
  }
}