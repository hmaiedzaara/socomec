/**
 * @File Name          : TH_PR_ProductRequiredTriggerHandler.cls
 * @Description        :
 * @Author             : Vincent RECASENS (Modis)
 * @Group              :
 * @Last Modified By   : Vincent RECASENS (Modis)
 * @Last Modified On   : 03-31-2021
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    13/05/2020   Vincent RECASENS (Modis)     Initial Version
 **/
public with sharing class TH_PR_ProductRequiredTriggerHandler extends TriggerHandler {
  // Maps and list initialized from the Trigger context
  private Map<Id, ProductRequired> oldMap;
  private Map<Id, ProductRequired> newMap;
  private List<ProductRequired> oldList;
  private List<ProductRequired> newList;

  // Constructor
  public TH_PR_ProductRequiredTriggerHandler() {
    this.oldMap = (Map<Id, ProductRequired>) Trigger.oldMap;
    this.newMap = (Map<Id, ProductRequired>) Trigger.newMap;
    this.oldList = (List<ProductRequired>) Trigger.Old;
    this.newList = (List<ProductRequired>) Trigger.New;
  }

  /**
    * @description Handle "ProductRequired After Insert"
    -
    * @author Vincent RECASENS (Modis) | 06/04/2020   
    **/
  public override void afterInsert() {
    if (Pad.cantrigger(STA_UtilsStatic.CLASS_PRODUCTREQUIRED_MANAGEMENT)) {
      System.debug(
        LoggingLevel.INFO,
        '## >>> ProductRequired After Insert:START <<< run by ' +
        UserInfo.getName()
      );

      SMC_AP_ManageProductRequired.launchFutureMethodUpdateWOLI(this.newList);

      System.debug(
        LoggingLevel.INFO,
        '## >>> ProductRequired After Insert:END <<<'
      );
    }
  }

  /**
    * @description Handle "ProductRequired After Update"
    -
    * @author Vincent RECASENS (Modis) | 06/04/2020   
    **/
  public override void afterUpdate() {
    if (Pad.cantrigger(STA_UtilsStatic.CLASS_PRODUCTREQUIRED_MANAGEMENT)) {
      System.debug(
        LoggingLevel.INFO,
        '## >>> ProductRequired After Update:START <<< run by ' +
        UserInfo.getName()
      );

      SMC_AP_ManageProductRequired.launchFutureMethodUpdateWOLI(this.newList);

      System.debug(
        LoggingLevel.INFO,
        '## >>> ProductRequired After Update:END <<<'
      );
    }
  }
}