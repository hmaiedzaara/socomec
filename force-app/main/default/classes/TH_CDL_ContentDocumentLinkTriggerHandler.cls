/*
---------------------------------------------------------------------
-- - Name          : TH_CDL_ContentDocumentLinkTriggerHandler
-- - Author        : Vincent RECASENS (VR)
-- - Description   : Handler for trigger ContentDocumentLinkTrigger             
-- Maintenance History:
--
-- Date         Name    Version     Remarks 
-- -----------  ----	------      ---------------------------
-- 31-JUL-2018  VR      1.0         Initial version 
-- 12-DEC-2018  VR      1.1         Add CheckRecursive and BypassAll
-- 06-APR-2020  VR      1.1         Add documentation
---------------------------------------------------------------------
*/

public without sharing class TH_CDL_ContentDocumentLinkTriggerHandler extends TriggerHandler {
  // Maps and list initialized from the Trigger context
  private Map<Id, ContentDocumentLink> oldMap;
  private Map<Id, ContentDocumentLink> newMap;
  private List<ContentDocumentLink> oldList;
  private List<ContentDocumentLink> newList;

  // Constructor
  public TH_CDL_ContentDocumentLinkTriggerHandler() {
    this.oldMap = (Map<Id, ContentDocumentLink>) Trigger.oldMap;
    this.newMap = (Map<Id, ContentDocumentLink>) Trigger.newMap;
    this.oldList = (List<ContentDocumentLink>) Trigger.Old;
    this.newList = (List<ContentDocumentLink>) Trigger.New;
  }

  /**
  * @description Handle "ContentDocumentLink After Insert"
  -send information "NewDocument" to parent case
  * @author Vincent RECASENS (Modis) | 06/04/2020   
  **/
  public override void afterInsert() {
    if (Pad.cantrigger(STA_UtilsStatic.CLASS_CONTENTDOCUMENTLINK_MANAGEMENT)) {
      System.debug(
        LoggingLevel.INFO,
        '## >>> ContentDocumentLink After Insert:START <<< run by ' +
        UserInfo.getName()
      );

      SMC_AP_ManageContentDocumentLink.updateCaseNewContentDocumentLink(this.newList);
      SMC_AP_ManageContentDocumentLink.duplicateLinkQuoteToPRMQuoteOrOpposite(this.newMap);

      System.debug(
        LoggingLevel.INFO,
        '## >>> ContentDocumentLink After Insert:END <<<'
      );
    }
  }
  
  /**
  * @description Handle "ContentDocumentLink Before Delete"
  -manage visibility (Public/Internal/Private)
  * @author Vincent RECASENS (Modis) | 06/04/2020 
  * @return void 
  **/
  public override void beforeDelete() {
    System.debug(
      LoggingLevel.INFO,
      '## >>> ContentDocumentLink Before Delete : START <<< run by ' +
      UserInfo.getName()
    );

    SMC_AP_ManageContentDocumentLink.deletePRMQuoteOrQuoteLink(this.oldMap);

    System.debug(
      LoggingLevel.INFO,
      '## >>> ContentDocumentLink Before Delete : END <<<'
    );
  }
}