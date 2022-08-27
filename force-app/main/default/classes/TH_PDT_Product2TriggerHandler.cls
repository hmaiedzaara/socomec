public class TH_PDT_Product2TriggerHandler extends TriggerHandler {
  // Maps and list initialized from the Trigger context
  private Map<Id, Product2> oldMap;
  private Map<Id, Product2> newMap;
  private List<Product2> oldList;
  private List<Product2> newList;

  // Constructor
  public TH_PDT_Product2TriggerHandler() {
    this.oldMap = (Map<Id, Product2>) Trigger.oldMap;
    this.newMap = (Map<Id, Product2>) Trigger.newMap;
    this.oldList = (List<Product2>) Trigger.Old;
    this.newList = (List<Product2>) Trigger.New;
  }

 /**
  * @description Handle "Product2 Before Insert"
  * @author Tanya SIBONI (Modis) | 23/04/2021   
  **/
  public override void beforeInsert() {
    if (Pad.cantrigger(STA_UtilsStatic.CLASS_PRODUCT2_MANAGEMENT)) {
      System.debug(
        LoggingLevel.INFO,
        '## >>> Product2 Before Insert :START <<< run by ' + UserInfo.getName()
      );
      
      SMC_AP_ManageProduct2.checkActiveProduct(this.newList);
      SMC_AP_ManageProduct2.renameProductCode_ProductName(this.newList);

      System.debug(LoggingLevel.INFO, '## >>> Product2 Before Insert:END <<<');
    }
  }
  
  /**
  * @description Handle "Product2 After Insert"
  * @author Vincent RECASENS (Modis) | 06/04/2020   
  **/
  public override void afterInsert() {
    if (Pad.cantrigger(STA_UtilsStatic.CLASS_PRODUCT2_MANAGEMENT)) {
      System.debug(
        LoggingLevel.INFO,
        '## >>> Product2 After Insert :START <<< run by ' + UserInfo.getName()
      );
        
      System.debug(LoggingLevel.INFO, 'No method for now');
      // SMC_AP_ManageProduct2.newWorkOrderItem(this.newMap);
      SMC_AP_ManageProduct2.createNewWorkTypesForNewProductWorkItem(this.newMap);

      System.debug(LoggingLevel.INFO, '## >>> Product2 After Insert:END <<<');
    }
  }

  /**
   * @description Handle "Product2 Before Insert"
   * @author Tanya SIBONI (Modis) | 23/04/2021   
   **/
   public override void beforeUpdate() {
     if (Pad.cantrigger(STA_UtilsStatic.CLASS_PRODUCT2_MANAGEMENT)) {
       System.debug(
         LoggingLevel.INFO,
         '## >>> Product2 Before Update :START <<< run by ' + UserInfo.getName()
       );
       
       SMC_AP_ManageProduct2.checkActiveProduct(this.newList);
       SMC_AP_ManageProduct2.renameProductCode_ProductName(this.newList);
      
       
 
       System.debug(LoggingLevel.INFO, '## >>> Product2 Before Update:END <<<');
     }
   }

  /**
  * @description Handle "Product2 After Update"
  * @author Vincent RECASENS (Modis) | 06/04/2020   
  **/
  public override void afterUpdate() {
    if (Pad.cantrigger(STA_UtilsStatic.CLASS_PRODUCT2_MANAGEMENT)) {
      System.debug(
        LoggingLevel.INFO,
        '## >>> Product2 After Update :START <<< run by ' + UserInfo.getName()
      );
        
      SMC_AP_ManageProduct2.updateWorkTypeIfProductWorkItemDeactivated(this.newMap, this.oldmap);
      //System.debug(LoggingLevel.INFO, 'THERE IS NO METHOD HERE');

      System.debug(LoggingLevel.INFO, '## >>> Product2 After Update:END <<<');
    }
  }
}