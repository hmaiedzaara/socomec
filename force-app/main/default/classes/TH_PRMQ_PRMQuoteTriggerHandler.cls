public with sharing class TH_PRMQ_PRMQuoteTriggerHandler  extends TriggerHandler {
    // Maps and list initialized from the Trigger context
    private Map<Id, SMC_PRM_Quote__c> oldMap;
    private Map<Id, SMC_PRM_Quote__c> newMap;
    private List<SMC_PRM_Quote__c> oldList;
    private List<SMC_PRM_Quote__c> newList;
  
    // Constructor
    public TH_PRMQ_PRMQuoteTriggerHandler() {
      this.oldMap = (Map<Id, SMC_PRM_Quote__c>) Trigger.oldMap;
      this.newMap = (Map<Id, SMC_PRM_Quote__c>) Trigger.newMap;
      this.oldList = (List<SMC_PRM_Quote__c>) Trigger.Old;
      this.newList = (List<SMC_PRM_Quote__c>) Trigger.New;
    }
  
    /**
      * @description Handle "PRM Quote After Insert"
      -
      * @author Vincent RECASENS (Modis) | 06/04/2020   
      **/
    public override void afterInsert() {
      if (Pad.cantrigger(STA_UtilsStatic.CLASS_PRMQUOTE_MANAGEMENT)) {
        System.debug(
          LoggingLevel.INFO,
          '## >>> PRM Quote After Insert:START <<< run by ' +
          UserInfo.getName()
        );
  
        SMC_AP_ManagePRMQuote.duplicateLinkQuoteToPRMQuote(this.newMap);
  
        System.debug(
          LoggingLevel.INFO,
          '## >>> PRM Quote After Insert:END <<<'
        );
      }
    }
}