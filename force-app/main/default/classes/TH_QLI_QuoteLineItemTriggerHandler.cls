/**
 * @File Name          : TH_QLI_QuoteLineItemTriggerHandler.cls
 * @Description        :
 * @Author             : David SOBCZAK (Socomec)
 * @Group              :
 * @Last Modified By   : Vincent RECASENS (Modis)
 * @Last Modified On   : 03-31-2021
 * @Modification Log   :
 * Ver       Date            Author      		          Modification
 * 1.0    11/10/2019   David SOBCZAK (Socomec)      Initial Version
 * 1.0    06/04/2020   Vincent RECASENS (Modis)     Add documentation
 **/

public without sharing class TH_QLI_QuoteLineItemTriggerHandler extends TriggerHandler {
  // Maps and list initialized from the Trigger context
  private Map<Id, QuoteLineItem> oldMap;
  private Map<Id, QuoteLineItem> newMap;
  private List<QuoteLineItem> oldList;
  private List<QuoteLineItem> newList;

  // Constructor
  public TH_QLI_QuoteLineItemTriggerHandler() {
    this.oldMap = (Map<Id, QuoteLineItem>) Trigger.oldMap;
    this.newMap = (Map<Id, QuoteLineItem>) Trigger.newMap;
    this.oldList = (List<QuoteLineItem>) Trigger.Old;
    this.newList = (List<QuoteLineItem>) Trigger.New;
  }

  /**
  * @description Handle "QuoteLineItem Before Delete"
  -prevent deletion don't provide through rest WS
  * @author Vincent RECASENS (Modis) | 06/04/2020   
  **/
  public override void beforeDelete() {
    if (Pad.cantrigger(STA_UtilsStatic.CLASS_QUOTE_MANAGEMENT)) {
      System.debug(
        LoggingLevel.INFO,
        '## >>> Quote Before Delete:START <<< run by ' + UserInfo.getName()
      );

      SMC_AP_ManageQuoteLineItem.preventDeleteByUI(this.oldList);

      System.debug(LoggingLevel.INFO, '## >>> Quote Before Delete:END <<<');
    }
  }
}