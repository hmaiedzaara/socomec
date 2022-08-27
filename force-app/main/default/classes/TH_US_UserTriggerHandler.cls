/*
----------------------------------------------------------------------------------------------
-- - Name          : TH_US_UserTriggerHandler
-- - Author        : Vincent RECASENS (VR) - Modis
-- - Description   : Handler for trigger User
-- - Project       : Socomec
--
-- Maintenance History:
--
-- Date         Name  	Version     Remarks
-- -----------  ----  	-------     -------------------------------------------------
-- 22-NOV-2018  VR    	1.0         Initial version
-- 12-DEC-2018  VR      1.1         Add CheckRecursive and BypassAll
-- 06-APR-2020  VR      1.1         Add documentation
----------------------------------------------------------------------------------------------
*/

public without sharing class TH_US_UserTriggerHandler extends TriggerHandler {
  // Maps and list initialized from the Trigger context
  private Map<Id, User> oldMap;
  private Map<Id, User> newMap;
  private List<User> oldList;
  private List<User> newList;

  // Constructor
  public TH_US_UserTriggerHandler() {
    this.oldMap = (Map<Id, User>) Trigger.oldMap;
    this.newMap = (Map<Id, User>) Trigger.newMap;
    this.oldList = (List<User>) Trigger.Old;
    this.newList = (List<User>) Trigger.New;
  }

  /**
  * @description Handle "User Before Insert"
  -insert related contact if user is a Partner
  * @author Vincent RECASENS (Modis) | 06/04/2020   
  **/
  public override void beforeInsert() {
    if (Pad.cantrigger(STA_UtilsStatic.CLASS_USER_MANAGEMENT)) {
      System.debug(
        LoggingLevel.INFO,
        '## >>> User Before Insert:START <<< run by ' + UserInfo.getName()
      );

      SMC_AP_ManageUser.setBypassFlows(newList, null);

      System.debug(LoggingLevel.INFO, '## >>> User Before Insert:END <<<');
    }
  }

  /**
  * @description Handle "User After Insert"
  -update related contact if user is a Partner
  * @author Vincent RECASENS (Modis) | 06/04/2020   
  **/
  public override void afterInsert() {
    if (Pad.cantrigger(STA_UtilsStatic.CLASS_USER_MANAGEMENT)) {
      System.debug(
        LoggingLevel.INFO,
        '## >>> User After Insert:START <<< run by ' + UserInfo.getName()
      );

      SMC_AP_ManageUser.flagContactIfPartner(newList);
      SMC_AP_ManageUser.addPartnerToPublicGroup(newMap);

      System.debug(LoggingLevel.INFO, '## >>> User After Insert:END <<<');
    }
  }

  /**
  * @description Handle "User Before Update"
  -update related contact if user is a Partner
  * @author Vincent RECASENS (Modis) | 06/04/2020   
  **/
  public override void beforeUpdate() {
    if (Pad.cantrigger(STA_UtilsStatic.CLASS_USER_MANAGEMENT)) {
      System.debug(
        LoggingLevel.INFO,
        '## >>> User Before Update:START <<< run by ' + UserInfo.getName()
      );

      SMC_AP_ManageUser.unflagContactIfPartner(newList, oldMap);
      SMC_AP_ManageUser.setBypassFlows(newList, oldMap);

      System.debug(LoggingLevel.INFO, '## >>> User Before Update:END <<<');
    }
  }
}