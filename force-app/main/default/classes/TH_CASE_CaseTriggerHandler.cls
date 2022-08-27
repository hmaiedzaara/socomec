/*
----------------------------------------------------------------------------------------------
-- - Name          : TH_CASE_CaseTriggerHandler
-- - Author        : Vincent RECASENS (VR) - Modis
-- - Description   : Handler for trigger CaseTrigger
-- - Project       : Socomec
--
-- Maintenance History:
--
-- Date         Name  	Version     Remarks
-- -----------  ----  	-------     -------------------------------------------------
-- 26-JUL-2018  VR    	1.0         Initial version
-- 12-DEC-2018  VR      1.1         Add CheckRecursive and BypassAll
-- 06-APR-2020  VR      1.1         Add documentation
----------------------------------------------------------------------------------------------
*/

public without sharing class TH_CASE_CaseTriggerHandler extends TriggerHandler {
  // Maps and list initialized from the Trigger context
  private Map<Id, Case> oldMap;
  private Map<Id, Case> newMap;
  private List<Case> oldList;
  private List<Case> newList;

  // Constructor
  public TH_CASE_CaseTriggerHandler() {
    this.oldMap = (Map<Id, Case>) Trigger.oldMap;
    this.newMap = (Map<Id, Case>) Trigger.newMap;
    this.oldList = (List<Case>) Trigger.Old;
    this.newList = (List<Case>) Trigger.New;
  }

  /*
Handle "Case Before Insert"
*/

  /**
  * @description Handle "Case Before Insert"
  -case creation for an other user
  -fix priority for case creation from Email-To-Case
  -get product informations from case serial number --> asset
  * @author Vincent RECASENS (Modis) | 06/04/2020   
  **/
  public override void beforeInsert() {
    if (Pad.cantrigger(STA_UtilsStatic.CLASS_CASE_MANAGEMENT)) {
      System.debug(
        LoggingLevel.INFO,
        '## >>> Case Before Insert:START <<< run by ' + UserInfo.getName()
      );

      SMC_AP_ManageCase.createACaseForAnotherUser(newList, false);
      SMC_AP_ManageCase.fixPriorityForEmailToCase(newList);
      SMC_AP_ManageCase.getProductInfoFromSerialNumber(newList, oldMap);
      // SMC_AP_ManageCase.assignCaseToSoc1(newList);

      System.debug(LoggingLevel.INFO, '## >>> Case Before Insert:END <<<');
    }
  }

  /**
  * @description Handle "Case After Insert"
  -launch assignment rule when case is created from Community
  -callout and update/get product info when is changed
  -fill Queue In Charge field : used to know wich BA work on the case
  * @author Vincent RECASENS (Modis) | 06/04/2020   
  **/
  public override void afterInsert() {
    if (Pad.cantrigger(STA_UtilsStatic.CLASS_CASE_MANAGEMENT)) {
      System.debug(
        LoggingLevel.INFO,
        '## >>> Case After Insert:START <<< run by ' + UserInfo.getName()
      );

      // SMC_AP_ManageCase.caseAssignmentRuleFromCommunity(newList);
      SMC_AP_ManageCase.caseAssignmentRuleFromCommunity(newMap.keySet());
      // SMC_AP_ManageCase.addSharingAndReassignToQueueWithAssignmentRule(newMap.keySet());
      SMC_AP_ManageCase.updateCasesProductInfo(newList, oldMap, true);
      SMC_AP_ManageCase.fillQueueInCharge(newMap, true);

      System.debug(LoggingLevel.INFO, '## >>> Case After Insert:END <<<');
    }
  }

  /**
  * @description Handle "Case Before Update"
  -fill Queue In Charge field : used to know wich BA work on the case
  -add field AnswerToCustomer in case comment
  -relaunch assignment rule when case is reopened
  -get product informations from case serial number --> asset
  * @author Vincent RECASENS (Modis) | 06/04/2020   
  **/
  public override void beforeUpdate() {
    if (system.isFuture()) {
      SMC_AP_ManageCase.checkAfterAssignementRuleExecution(newMap, oldMap);
      return;
    }

    if (
      Pad.cantrigger(STA_UtilsStatic.CLASS_CASE_MANAGEMENT) &&
      SMC_UTIL_CheckRecursiveTrigger.runOnce()
    ) {
      System.debug(
        LoggingLevel.INFO,
        '## >>> Case Before Update:START <<< run by ' + UserInfo.getName()
      );

      SMC_AP_ManageCase.fillQueueInCharge(newMap, false);
      SMC_AP_ManageCase.answerToCustomerInComment(newList, oldMap);
      SMC_AP_ManageCase.reassignementForReopenCase(newList, oldMap);
      SMC_AP_ManageCase.getProductInfoFromSerialNumber(newList, oldMap);
      SMC_AP_ManageCase.addJiraIdentifierIfNeeded(newMap);

      System.debug(LoggingLevel.INFO, '## >>> Case Before Update:END <<<');
    }
  }

  /**
  * @description Handle "Case After Update"
  -callout and update/get product info when is changed
  -callout to create the next CIMsa visit
  * @author Vincent RECASENS (Modis) | 06/04/2020   
  **/
  public override void afterUpdate() {
    if (system.isFuture())
      return;

    if (Pad.cantrigger(STA_UtilsStatic.CLASS_CASE_MANAGEMENT)) {
      System.debug(
        LoggingLevel.INFO,
        '## >>> Case After Update:START <<< run by ' + UserInfo.getName()
      );

      SMC_AP_ManageCase.updateCasesProductInfo(newList, oldMap, false);
      SMC_AP_ManageCase.createCimsaVisit(newList, oldMap);

      System.debug(LoggingLevel.INFO, '## >>> Case After Update:END <<<');
    }
  }
}