/*
---------------------------------------------------------------------
-- - Name          : SMC_AP_ManageEmailMessage
-- - Author        : Vincent RECASENS (VR)
-- - Description   : Manage EmailMessage         
-- Maintenance History:
--
-- Date         Name    Version     Remarks 
-- -----------  ----	------      ---------------------------
-- 30-JUL-2018  (VR)    1.0         Initial version 
-- XX-XXX-2018  (VR)    1.1         Deteled
-- 12-FEB-2019  (VR)    2.0         Rework - Manage EmailMessage good again
-- 06-APR-2020  (VR)    2.0         Add document
---------------------------------------------------------------------
*/
public without sharing class TH_EM_EmailMessageTriggerHandler extends TriggerHandler {
  // Maps and list initialized from the Trigger context
  private Map<Id, EmailMessage> oldMap;
  private Map<Id, EmailMessage> newMap;
  private List<EmailMessage> oldList;
  private List<EmailMessage> newList;

  // Constructor
  public TH_EM_EmailMessageTriggerHandler() {
    this.oldMap = (Map<Id, EmailMessage>) Trigger.oldMap;
    this.newMap = (Map<Id, EmailMessage>) Trigger.newMap;
    this.oldList = (List<EmailMessage>) Trigger.Old;
    this.newList = (List<EmailMessage>) Trigger.New;
  }

  /**
   * @description Handle "EmailMessage" After Insert"
   -send information "NewEmail" to parent case
   -hidde attchment to customer
   * @author Vincent RECASENS (Modis) | 06/04/2020 
   **/
  public override void afterInsert() {
    if (Pad.cantrigger(STA_UtilsStatic.CLASS_EMAILMESSAGE_MANAGEMENT)) {
      System.debug(
        LoggingLevel.INFO,
        '## >>> EmailMessage After Insert:START <<< run by ' +
        UserInfo.getName()
      );

      SMC_AP_ManageEmailMessage.updateCaseNewEmailMessage(newList);
      SMC_AP_ManageEmailMessage.emailAttachmentNotVisibleByCommunityUsers(
        newList
      );

      System.debug(
        LoggingLevel.INFO,
        '## >>> EmailMessage After Insert:END <<<'
      );
    }
  }
}