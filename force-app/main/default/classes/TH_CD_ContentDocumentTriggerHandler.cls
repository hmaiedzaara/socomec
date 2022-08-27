/*
---------------------------------------------------------------------
-- - Name          : TH_CD_ContentDocumentTriggerHandler
-- - Author        : Vincent RECASENS (VR)
-- - Description   : Handler for trigger ContentDocumentTrigger         
-- Maintenance History:
--
-- Date         Name    Version     Remarks 
-- -----------  ----	------      ---------------------------
-- 12-OCT-2018  VR      1.0         Initial version 
-- 12-DEC-2018  VR      1.1         Add CheckRecursive and BypassAll
-- 06-APR-2020  VR      1.1         Add documentation
---------------------------------------------------------------------
*/
public without sharing class TH_CD_ContentDocumentTriggerHandler extends TriggerHandler {
  // Maps and list initialized from the Trigger context
  private Map<Id, ContentDocument> oldMap;
  private Map<Id, ContentDocument> newMap;
  private List<ContentDocument> oldList;
  private List<ContentDocument> newList;

  // Constructor
  public TH_CD_ContentDocumentTriggerHandler() {
    this.oldMap = (Map<Id, ContentDocument>) Trigger.oldMap;
    this.newMap = (Map<Id, ContentDocument>) Trigger.newMap;
    this.oldList = (List<ContentDocument>) Trigger.Old;
    this.newList = (List<ContentDocument>) Trigger.New;
  }

  /**
  * @description Handle "ContentDocument Before Delete"
  -prevent file deletion from community user
  * @author ChangeMeIn@UserSettingsUnder.SFDoc | 06/04/2020   
  **/
  public override void beforeDelete() {
    if (Pad.cantrigger(STA_UtilsStatic.CLASS_CONTENTDOCUMENT_MANAGEMENT)) {
      System.debug(
        LoggingLevel.INFO,
        '## >>> ContentDocument Before Delete : START <<< run by ' +
        UserInfo.getName()
      );

      SMC_AP_ManageContentDocument.communityUserCantDeleteFiles(oldList);

      System.debug(
        LoggingLevel.INFO,
        '## >>> ContentDocument Before Delete : END <<<'
      );
    }
  }
}