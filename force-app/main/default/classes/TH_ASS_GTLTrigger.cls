/**
 * @File Name          : TH_ASS_GTLTrigger.cls
 * @Description        :
 * @Author             : Emmanuel BERNIER (Modis)
 * @Group              :
 * @Last Modified By   : Vincent RECASENS (Modis)
 * @Last Modified On   : 03-31-2021
 * @Modification Log   :
 * Ver       Date            Author      		        Modification
 * 1.0    10/12/2019   Emmanuel BERNIER (Modis)   Initial Version
 * 1.0    06/04/2020   Vincent RECASENS (Modis)   Add documentation
 **/
public without sharing class TH_ASS_GTLTrigger extends TriggerHandler {
  // Maps and list initialized from the Trigger context
  private Map<Id, SMC_GTL__c> oldMap;
  private Map<Id, SMC_GTL__c> newMap;
  private List<SMC_GTL__c> oldList;
  private List<SMC_GTL__c> newList;

  // Constructor
  public TH_ASS_GTLTrigger() {
    this.oldMap = (Map<Id, SMC_GTL__c>) Trigger.oldMap;
    this.newMap = (Map<Id, SMC_GTL__c>) Trigger.newMap;
    this.oldList = (List<SMC_GTL__c>) Trigger.Old;
    this.newList = (List<SMC_GTL__c>) Trigger.New;
  }

  /**
  * @description Handle "GTL Before Insert"
  -check duplication
  * @author Vincent RECASENS (Modis) | 06/04/2020   
  **/
  public override void beforeInsert() {
    if (Pad.cantrigger(STA_UtilsStatic.CLASS_GTL_MANAGEMENT)) {
      System.debug(
        LoggingLevel.INFO,
        '## >>>GTL Before Insert:START <<< run by ' + UserInfo.getName()
      );

      SMC_AP_ManageGTL.checkForDuplicates(this.newList);

      System.debug(LoggingLevel.INFO, '## >>> GTL Before Insert:END <<<');
    }
  }

  /**
  * @description Handle "GTL Before Update"
  -check duplication
  * @author Vincent RECASENS (Modis) | 06/04/2020   
  **/
  public override void beforeUpdate() {
    if (Pad.cantrigger(STA_UtilsStatic.CLASS_GTL_MANAGEMENT)) {
      System.debug(
        LoggingLevel.INFO,
        '## >>> GTL Before Update:START <<< run by ' + UserInfo.getName()
      );

      SMC_AP_ManageGTL.checkForDuplicates(this.newList);

      System.debug(LoggingLevel.INFO, '## >>> GTL Before Update:END <<<');
    }
  }

  /**
  * @description Handle "GTL After Update"
  -check if the GTL is a valide line
  * @author Vincent RECASENS (Modis) | 06/04/2020   
  **/
  public override void afterUpdate() {
    if (Pad.cantrigger(STA_UtilsStatic.CLASS_GTL_MANAGEMENT)) {
      System.debug(
        LoggingLevel.INFO,
        '## >>> GTL After Update:START <<< run by ' + UserInfo.getName()
      );

      SMC_AP_ManageGTL.invalidateGtlLine(this.newList, this.oldMap);
      SMC_AP_ManageGTL.manageGTLComment(this.newMap, this.oldMap);

      System.debug(LoggingLevel.INFO, '## >>> GTL After Update:END <<<');
    }
  }
}