/*
--------------------------------------------------------------------------------------
-- - Name          : TH_CV_ContentVersionTriggerHandler
-- - Author        : Vincent RECASENS
-- - Description   : Handler for trigger ContactTrigger
-- - Project       : Socomec
--
-- Maintenance History:
--
-- Date         Name   Version  Remarks
-- -----------  ----   -------  -------------------------------------------------------
-- 20-JUL-2018  VRE    1.0     Initial version
-- 06-APR-2020  VRE    1.1     Add documentation
--------------------------------------------------------------------------------------
*/

public without sharing class TH_CV_ContentVersionTriggerHandler extends TriggerHandler {
  // Maps and list initialized from the Trigger context
  private Map<Id, ContentVersion> oldMap;
  private Map<Id, ContentVersion> newMap;
  private List<ContentVersion> oldList;
  private List<ContentVersion> newList;

  // Constructor
  public TH_CV_ContentVersionTriggerHandler() {
    this.oldMap = (Map<Id, ContentVersion>) Trigger.oldMap;
    this.newMap = (Map<Id, ContentVersion>) Trigger.newMap;
    this.oldList = (List<ContentVersion>) Trigger.Old;
    this.newList = (List<ContentVersion>) Trigger.New;
  }

  /**
  * @description Handle "ContentVersion Before Insert"
  -prepare insertion : manage title
  -prevent upload on closed case
  * @author Vincent RECASENS (Modis) | 06/04/2020 
  * @return void 
  **/
  public override void beforeInsert() {
    if (Pad.cantrigger(STA_UtilsStatic.CLASS_CONTENTVERSION_MANAGEMENT)) {
      System.debug(
        LoggingLevel.INFO,
        '## >>> ContentVersion Before Insert : START <<< run by ' +
        UserInfo.getName()
      );

      SMC_AP_ManageContentVersion.prepareInsertion(newList);
      SMC_AP_ManageContentVersion.preventUploadFileOnClosedCase(newList);

      System.debug(
        LoggingLevel.INFO,
        '## >>> ContentVersion Before Insert : END <<<'
      );
    }
  }

  /**
  * @description Handle "ContentVersion After Insert"
  -finish insertion : manage title
  -prevent upload on closed case
  * @author Vincent RECASENS (Modis) | 06/04/2020 
  * @return void 
  **/
  public override void afterInsert() {
    if (Pad.cantrigger(STA_UtilsStatic.CLASS_CONTENTVERSION_MANAGEMENT)) {
      System.debug(
        LoggingLevel.INFO,
        '## >>> ContentVersion After Insert : START <<< run by ' +
        UserInfo.getName()
      );

      SMC_AP_ManageContentVersion.finishInsertion(newList);

      /* /!\ Waiting solution without automatically email sent /!\
       SMC_AP_ManageContentVersion.addOwnerAsViwer(newList); */
      System.debug(
        LoggingLevel.INFO,
        '## >>> ContentVersion After Insert : END <<<'
      );
    }
  }

  /**
  * @description Handle "ContentVersion Before Update"
  -manage visibility (Public/Internal/Private)
  * @author Vincent RECASENS (Modis) | 06/04/2020 
  * @return void 
  **/
  public override void beforeUpdate() {
    if (Pad.cantrigger(STA_UtilsStatic.CLASS_CONTENTVERSION_MANAGEMENT)) {
      System.debug(
        LoggingLevel.INFO,
        '## >>> ContentVersion Before Update : START <<< run by ' +
        UserInfo.getName()
      );

      SMC_AP_ManageContentVersion.manageFileVisibility(newList, oldMap);
      // SMC_AP_ManageContentVersion.preventFileModificationsOnQuote(newList);

      System.debug(
        LoggingLevel.INFO,
        '## >>> ContentVersion Before Update : END <<<'
      );
    }
  }
}