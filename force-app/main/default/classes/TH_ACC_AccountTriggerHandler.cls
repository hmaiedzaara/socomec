/*
----------------------------------------------------------------------------------------------
-- - Name          : TH_ACC_AccountTriggerHandler
-- - Author        : Xavier BRANCHE (XB) - Modis
-- - Description   : Handler for trigger AccountTrigger
-- - Project       : Socomec
--
-- Maintenance History:
--
-- Date         Name  Version   Remarks
-- -----------  ----  -------   -------------------------------------------------
-- 29-Mai-2017  XB    1.0       Initial version
-- 21-Fév-2018  VR    1.1       Add "Scoring" in 'afterInsert()' & 'afterUpdate()'
-- 12-DEC-2018  VR    1.2       Add CheckRecursive and BypassAll
-- 06-APR-2020  VR    1.2       Add documentation
----------------------------------------------------------------------------------------------
*/

public without sharing class TH_ACC_AccountTriggerHandler extends TriggerHandler {
  // Maps and list initialized from the Trigger context
  private Map<Id, Account> oldMap;
  private Map<Id, Account> newMap;
  private List<Account> oldList;
  private List<Account> newList;

  // Constructor
  public TH_ACC_AccountTriggerHandler() {
    this.oldMap = (Map<Id, Account>) Trigger.oldMap;
    this.newMap = (Map<Id, Account>) Trigger.newMap;
    this.oldList = (List<Account>) Trigger.Old;
    this.newList = (List<Account>) Trigger.New;
  }

  /**
  * @description Handle "Account Before Insert"
  -complete default country if not filled
  * @author Vincent RECASENS (Modis) | 06/04/2020   
  **/
  public override void beforeInsert() {
    if (Pad.cantrigger(STA_UtilsStatic.CLASS_ACCOUNT_MANAGEMENT)) {
      System.debug(
        LoggingLevel.INFO,
        '## >>> Account Before Insert:START <<< run by ' + UserInfo.getName()
      );

      SMC_AP_ManageAccount.completeAccountsWithDefaultCountry(this.newList);

      System.debug(LoggingLevel.INFO, '## >>> Account Before Insert:END <<<');
    }
  }

  /**
  * @description Handle "Account After Insert"
  -manage team member (insert/update/delete TM)
  * @author Vincent RECASENS (Modis) | 06/04/2020   
  **/
  public override void afterInsert() {
    if (Pad.cantrigger(STA_UtilsStatic.CLASS_ACCOUNT_MANAGEMENT)) {
      System.debug(
        LoggingLevel.INFO,
        '## >>> Account After Insert :START <<< run by ' + UserInfo.getName()
      );

      SMC_AP_ManageAccount.insertTeamMember(this.newMap, this.oldList);
      // SMC_AP_ManageAccount.eraseCrmCodeInsert(this.newList);

      System.debug(LoggingLevel.INFO, '## >>> Account After Insert:END <<<');
    }
  }

  /**
  * @description Handle "Account After Update" : 
  -manage team member (insert/update/delete TM)
  -update Scoring when Account is update
  * @author Vincent RECASENS (Modis) | 06/04/2020   
  **/
  public override void afterUpdate() {
    if (Pad.cantrigger(STA_UtilsStatic.CLASS_ACCOUNT_MANAGEMENT)) {
      System.debug(
        LoggingLevel.INFO,
        '## >>> Account After Update:START <<< run by ' + UserInfo.getName()
      );

      SMC_AP_ManageAccount.insertTeamMember(this.newMap, this.oldList);
      SMC_AP_ManageAccount.prepareUpdateScoring(this.newList, this.oldMap);

      System.debug(LoggingLevel.INFO, '## >>> Account After Update:END <<<');
    }

    // if(Pad.cantrigger(STA_UtilsStatic.CLASS_ACCOUNT_MANAGEMENT) && Pad.cantrigger(STA_UtilsStatic.CLASS_ACCOUNT_MANAGEMENT + STA_UtilsStatic.TERRITORY) ) {
    // TODO @DOS should be delete with new winter 19 feature
    //AP_manageAccount.setAssignedTerritories(oldList, newList/*, false*/);
    // }
  }

  /**
  * @description Handle "Account Before Delete"
  -check if user can delete Account and if Account can be deleted (link to opportunities or not)
  * @author Vincent RECASENS (Modis) | 06/04/2020   
  **/
  public override void beforeDelete() {
    if (Pad.cantrigger(STA_UtilsStatic.CLASS_ACCOUNT_MANAGEMENT) &&
      Pad.cantrigger(
        STA_UtilsStatic.CLASS_ACCOUNT_MANAGEMENT + STA_UtilsStatic.MASS_DELETE
      )) {
      System.debug(
        LoggingLevel.INFO,
        '## >>> Account After Delete:START <<< run by ' + UserInfo.getName()
      );

      SMC_AP_ManageAccount.checkERPAccountToMassDeleteAndLinkOpportunity(
        this.oldMap
      );

      System.debug(LoggingLevel.INFO, '## >>> Account After Delete:END <<<');
    }
  }
}