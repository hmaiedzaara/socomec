/*
----------------------------------------------------------------------------------------------
-- - Name          : TH_OPP_OpportunityTriggerHandler
-- - Author        : Vincent RECASENS (VR) - MODIS
-- - Description   : Handler for trigger OpportunityTrigger
-- - Project       : Socomec
--
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  -------------------------------------------------
-- 05-JUN-18    VR    1.0      Initial version
-- 12-DEC-2018  VR    1.1      Add CheckRecursive and BypassAll
-- 06-APR-2020  VR    1.1      Add documentation
----------------------------------------------------------------------------------------------
*/

public without sharing class TH_OPP_OpportunityTriggerHandler extends TriggerHandler {
  // Maps and list initialized from the Trigger context
  private Map<Id, Opportunity> oldMap;
  private Map<Id, Opportunity> newMap;
  private List<Opportunity> oldList;
  private List<Opportunity> newList;

  // Constructor
  public TH_OPP_OpportunityTriggerHandler() {
    this.oldMap = (Map<Id, Opportunity>) Trigger.oldMap;
    this.newMap = (Map<Id, Opportunity>) Trigger.newMap;
    this.oldList = (List<Opportunity>) Trigger.Old;
    this.newList = (List<Opportunity>) Trigger.New;
  }

  /**
  * @description Handle "Opportunity Before Insert"
  -erase opportunity number if no duplication
  -assign to generic account if account field is null
  * @author Vincent RECASENS (Modis) | 06/04/2020   
  **/
  public override void beforeInsert() {
    if (Pad.cantrigger(STA_UtilsStatic.CLASS_OPPORTUNITY_MANAGEMENT)) {
      System.debug(
        LoggingLevel.INFO,
        '## >>> Opportunity Before Insert:START <<< run by ' +
        UserInfo.getName()
      );

      SMC_AP_ManageOpportunity.eraseCrmCode(newList);
      SMC_AP_ManageOpportunity.assignGenericAccount(newList, oldMap);

      System.debug(
        LoggingLevel.INFO,
        '## >>> Opportunity Before Insert:END <<<'
      );
    }
  }

  /**
  * @description Handle "Opportunity After Insert"
  -complete default country if not filled
  * @author Vincent RECASENS (Modis) | 06/04/2020   
  **/
  public override void afterInsert() {
      System.debug(
        LoggingLevel.INFO,
        '## >>> Quote After Insert:START <<< run by ' + UserInfo.getName()
      );

      //SMC_TestApexSharing.checkSharingOpportunity(this.newMap);

      System.debug(LoggingLevel.INFO, '## >>> Quote After Insert:END <<<');
  }

  /**
  * @description Handle "Opportunity Before Update"
  -update opportunity if primary quote is changed
  -assign to generic account if account field is null
  * @author Vincent RECASENS (Modis) | 06/04/2020   
  **/
  public override void beforeUpdate() {
    if (Pad.cantrigger(STA_UtilsStatic.CLASS_OPPORTUNITY_MANAGEMENT)) {
      System.debug(
        LoggingLevel.INFO,
        '## >>> Opportunity Before Update:START <<< run by ' +
        UserInfo.getName()
      );

      SMC_AP_ManageOpportunity.primaryQuoteIsFollowed(newMap, oldMap);
      SMC_AP_ManageOpportunity.assignGenericAccount(newList, oldMap);

      System.debug(
        LoggingLevel.INFO,
        '## >>> Opportunity Before Update:END <<<'
      );
    }
  }

  /**
  * @description Handle "Opportunity Before Delete"
  -check if opportunity can be deleted
  * @author Vincent RECASENS (Modis) | 06/04/2020   
  **/
  public override void beforeDelete() {
    if (Pad.cantrigger(STA_UtilsStatic.CLASS_OPPORTUNITY_MANAGEMENT)) {
      System.debug(
        LoggingLevel.INFO,
        '## >>> Opportunity Before Delete:START <<< run by ' +
        UserInfo.getName()
      );

      SMC_AP_ManageOpportunity.checkOngoingQTO(oldMap);

      System.debug(
        LoggingLevel.INFO,
        '## >>> Opportunity Before Delete:END <<<'
      );
    }
  }
}