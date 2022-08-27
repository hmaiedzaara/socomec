/*
----------------------------------------------------------------------------------------------
-- - Name          : TH_ACC_QuoteTriggerHandler
-- - Author        : Vincent RECASENS (VR) - MODIS
-- - Description   : Handler for trigger QuoteTrigger
-- - Project       : Socomec
--
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  -------------------------------------------------
-- 28-MAI-2018  VR    1.0      Initial version
-- 12-DEC-2018  VR    1.1      Add CheckRecursive and BypassAll
-- 12-DEC-2018  VR    1.1      Add documentation
----------------------------------------------------------------------------------------------
*/

public without sharing class TH_QUO_QuoteTriggerHandler extends TriggerHandler {
  // Maps and list initialized from the Trigger context
  private Map<Id, Quote> oldMap;
  private Map<Id, Quote> newMap;
  private List<Quote> oldList;
  private List<Quote> newList;

  // Constructor
  public TH_QUO_QuoteTriggerHandler() {
    this.oldMap = (Map<Id, Quote>) Trigger.oldMap;
    this.newMap = (Map<Id, Quote>) Trigger.newMap;
    this.oldList = (List<Quote>) Trigger.Old;
    this.newList = (List<Quote>) Trigger.New;
  }

  /**
  * @description Handle "Quote Before Insert"
  -create fake opportunity for quote SimuExpress/Quotation
  * @author Vincent RECASENS (Modis) | 06/04/2020   
  **/
  public override void beforeInsert() {
    if (Pad.cantrigger(STA_UtilsStatic.CLASS_QUOTE_MANAGEMENT)) {
      System.debug(
        LoggingLevel.INFO,
        '## >>> Quote Before Insert:START <<< run by ' + UserInfo.getName()
      );

      SMC_AP_ManageQuote.createFakeOpportunityBeforeInsert(this.newList);
      // SMC_AP_ManageQuote.setBPAccount(this.newList);
      // SMC_AP_ManageQuote.followPrimaryQuote(this.newList);
      // SMC_AP_ManageQuote.fillCustomContactField(this.newList, null);
      // SMC_AP_ManageQuote.removeAccountBypass(this.newList);

      System.debug(LoggingLevel.INFO, '## >>> Quote Before Insert:END <<<');
    }
  }

  /**
  * @description Handle "Quote Before Update"
  -display missing informations to launch QTO
  -set TECH_SMC_Process_Instance_Id__c
  -manage Approval fields (fix)
  * @author Vincent RECASENS (Modis) | 06/04/2020   
  **/
  public override void beforeUpdate() {
    if (
      Pad.cantrigger(STA_UtilsStatic.CLASS_QUOTE_MANAGEMENT) &&
      SMC_UTIL_CheckRecursiveTrigger.runOnce()
    ) {
      System.debug(
        LoggingLevel.INFO,
        '## >>> Quote Before Update:START <<< run by ' + UserInfo.getName()
      );

      SMC_AP_ManageQuote.displayInfosToStartQTO(this.newList);
      SMC_AP_ManageQuote.setProcessInstanceIdField(newMap, false);
      SMC_AP_ManageQuote.checkApprovalInformations(newMap, oldMap);
      SMC_AP_ManageQuote.preventModificationIfQuoteIsValidatedOrCancelled(
        newMap,
        oldMap
      );
      // SMC_AP_ManageQuote.fillCustomContactField(this.newList, this.oldMap);
      // SMC_AP_ManageQuote.removeAccountBypass(this.newList);

      System.debug(LoggingLevel.INFO, '## >>> Quote Before Update:END <<<');
    }
  }

  /**
  * @description Handle "Quote After Update"
  -send notification with redirection on approval
  * @author Vincent RECASENS (Modis) | 06/04/2020   
  **/
  public override void afterUpdate() {
    if (Pad.cantrigger(STA_UtilsStatic.CLASS_QUOTE_MANAGEMENT)) {
      System.debug(
        LoggingLevel.INFO,
        '## >>> Quote After Update:START <<< run by ' + UserInfo.getName()
      );

      SMC_AP_ManageQuote.sendNotificationForApprovalEnding(newMap, oldMap);

      System.debug(LoggingLevel.INFO, '## >>> Quote After Update:END <<<');
    }
  }

  /**
  * @description Handle "Quote Before Delete"
  -prevent deletion if quote is in QTO process
  * @author Vincent RECASENS (Modis) | 06/04/2020   
  **/
  public override void beforeDelete() {
    if (Pad.cantrigger(STA_UtilsStatic.CLASS_QUOTE_MANAGEMENT)) {
      System.debug(
        LoggingLevel.INFO,
        '## >>> Quote Before Delete:START <<< run by ' + UserInfo.getName()
      );

      SMC_AP_ManageQuote.checkOngoingQTO(this.oldList);

      System.debug(LoggingLevel.INFO, '## >>> Quote Before Delete:END <<<');
    }
  }
}