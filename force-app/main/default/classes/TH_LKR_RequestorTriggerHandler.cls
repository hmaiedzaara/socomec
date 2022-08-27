/**
 * @description       :
 * @author            : Vincent RECASENS (Modis)
 * @group             :
 * @last modified on  : 12-24-2020
 * @last modified by  : Vincent RECASENS (Modis)
 * Modifications Log
 * Ver   Date         Author                     Modification
 * 1.0   12-24-2020   Vincent RECASENS (Modis)   Initial Version
 **/
public with sharing class TH_LKR_RequestorTriggerHandler extends TriggerHandler {
  // Maps and list initialized from the Trigger context
  private Map<Id, SMC_Lorawan_Keys_Requestor__c> oldMap;
  private Map<Id, SMC_Lorawan_Keys_Requestor__c> newMap;
  private List<SMC_Lorawan_Keys_Requestor__c> oldList;
  private List<SMC_Lorawan_Keys_Requestor__c> newList;
  private Boolean bypassAllTrigger;

  // Constructor
  public TH_LKR_RequestorTriggerHandler() {
    this.oldMap = (Map<Id, SMC_Lorawan_Keys_Requestor__c>) Trigger.oldMap;
    this.newMap = (Map<Id, SMC_Lorawan_Keys_Requestor__c>) Trigger.newMap;
    this.oldList = (List<SMC_Lorawan_Keys_Requestor__c>) Trigger.Old;
    this.newList = (List<SMC_Lorawan_Keys_Requestor__c>) Trigger.New;

    //Get user.TECH_SMC_PAD_Bypass_All_Trigger__c
    if (Pad.cantrigger(STA_UtilsStatic.CLASS_LORA_KEY_REQUESTOR_MANAGEMENT)) {
      this.bypassAllTrigger = [
        SELECT TECH_SMC_PAD_Bypass_All_Trigger__c
        FROM User
        WHERE Id = :UserInfo.getUserId()
      ]
      .TECH_SMC_PAD_Bypass_All_Trigger__c;
    }
  }

  /**
    * @description Handle "SMC_Lorawan_Keys_Requestor__c After Update"
    -manage Skils on WorkOrder
    * @author Vincent RECASENS (Modis) | 06/04/2020   
    **/
  public override void afterUpdate() {
    if (
      Pad.cantrigger(STA_UtilsStatic.CLASS_LORA_KEY_REQUESTOR_MANAGEMENT) &&
      !bypassAllTrigger
    ) {
      System.debug(
        LoggingLevel.INFO,
        '## >>> SMC_Lorawan_Keys_Requestor__c After Update:START <<< run by ' +
        UserInfo.getName()
      );

      SMC_AP_ManageLorawanKeysRequestor.sendFormToPardot(
        this.newMap,
        this.oldMap
      );

      System.debug(
        LoggingLevel.INFO,
        '## >>> SMC_Lorawan_Keys_Requestor__c After Update:END <<<'
      );
    }
  }
}