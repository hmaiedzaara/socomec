/**
 * @File Name          : TH_CM_CommunityMessageTrigger.cls
 * @Description        :
 * @Author             : Vincent RECASENS (Modis)
 * @Group              :
 * @Last Modified By   : Vincent RECASENS (Modis)
 * @Last Modified On   : 03-31-2021
 * @Modification Log   :
 * Ver       Date            Author      		          Modification
 * 1.0    19/12/2019   Vincent RECASENS (Modis)     Initial Version
 * 1.0    06/04/2020   Vincent RECASENS (Modis)     Add documention
 **/
public without sharing class TH_CM_CommunityMessageTrigger extends TriggerHandler {
  // Maps and list initialized from the Trigger context
  private Map<Id, SMC_Community_Message__c> oldMap;
  private Map<Id, SMC_Community_Message__c> newMap;
  private List<SMC_Community_Message__c> oldList;
  private List<SMC_Community_Message__c> newList;

  // Constructor
  public TH_CM_CommunityMessageTrigger() {
    this.oldMap = (Map<Id, SMC_Community_Message__c>) Trigger.oldMap;
    this.newMap = (Map<Id, SMC_Community_Message__c>) Trigger.newMap;
    this.oldList = (List<SMC_Community_Message__c>) Trigger.Old;
    this.newList = (List<SMC_Community_Message__c>) Trigger.New;
  }

  /**
  * @description Handle "SMC_Community_Message__c Before Insert"
  -fill fields and let PB send message
  * @author Vincent RECASENS (Modis) | 06/04/2020   
  **/
  public override void beforeInsert() {
    if (Pad.cantrigger(STA_UtilsStatic.CLASS_COMMUNITY_MESSAGE_MANAGEMENT)) {
      System.debug(
        LoggingLevel.INFO,
        '## >>> SMC_Community_Message__c Before Insert:START <<< run by ' +
        UserInfo.getName()
      );

      SMC_AP_ManageCommunityMessage.fillURLCustomersCompmunityField(newList);
      SMC_AP_ManageCommunityMessage.fillUserLookupFromContact(newList);

      System.debug(
        LoggingLevel.INFO,
        '## >>> SMC_Community_Message__c Before Insert:END <<<'
      );
    }
  }
}