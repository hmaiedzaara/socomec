/*
----------------------------------------------------------------------------------------------
-- - Name          : TH_CCMT_CaseCommentTriggerHandlers
-- - Author        : Vincent RECASENS (VR) - Modis
-- - Description   : Handler for trigger CaseCommentTrigger
-- - Project       : Socomec
-- - Modified by   : Vincent RECASENS (VR) - Modis
--
-- Maintenance History:
--
-- Date         Name  	Version     Remarks
-- -----------  ----  	-------     -------------------------------------------------
-- 30-JUL-2018  VR    	1.0         Initial version
-- 29-AUG-2018  LA    	1.1         Add Before Insert method
-- 12-DEC-2018  VR      1.2         Add CheckRecursive and BypassAll
-- 06-APR-2020  VR      1.2         Add documentation
----------------------------------------------------------------------------------------------
*/

public without sharing class TH_CCMT_CaseCommentTriggerHandler extends TriggerHandler {
  // Maps and list initialized from the Trigger context
  private Map<Id, CaseComment> oldMap;
  private Map<Id, CaseComment> newMap;
  private List<CaseComment> oldList;
  private List<CaseComment> newList;

  // Constructor
  public TH_CCMT_CaseCommentTriggerHandler() {
    this.oldMap = (Map<Id, CaseComment>) Trigger.oldMap;
    this.newMap = (Map<Id, CaseComment>) Trigger.newMap;
    this.oldList = (List<CaseComment>) Trigger.Old;
    this.newList = (List<CaseComment>) Trigger.New;
  }

  /**
  * @description Handle "CaseComment Before Insert"
  -prevent comment on closed case
  -add JIRA identifier on comment if needed and reset Case.SMC_JIRA_Comment_s__c field
  * @author Vincent RECASENS (Modis) | 06/04/2020   
  **/
  public override void beforeInsert() {
    if (Pad.cantrigger(STA_UtilsStatic.CLASS_CASECOMMENT_MANAGEMENT)) {
      System.debug(
        LoggingLevel.INFO,
        '## >>> CaseComment Before Insert:START <<< run by ' +
        UserInfo.getName()
      );

      SMC_AP_ManageCaseComment.preventUpdateOnClosedCase(newList);
      // SMC_AP_ManageCaseComment.addJiraIdentifierIfNeeded(newList);

      System.debug(
        LoggingLevel.INFO,
        '## >>> CaseComment Before Insert:END <<<'
      );
    }
  }

  /**
  * @description Handle "CaseComment After Insert"
  -send information "NewComment" to parent case
  * @author Vincent RECASENS (Modis) | 06/04/2020   
  **/
  public override void afterInsert() {
    if (Pad.cantrigger(STA_UtilsStatic.CLASS_CASECOMMENT_MANAGEMENT)) {
      System.debug(
        LoggingLevel.INFO,
        '## >>> CaseComment After Insert:START <<< run by ' + UserInfo.getName()
      );

      SMC_AP_ManageCaseComment.updateCaseParentId(newMap);

      System.debug(
        LoggingLevel.INFO,
        '## >>> CaseComment After Insert:END <<<'
      );
    }
  }
}