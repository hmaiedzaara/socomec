/**
 * @File Name          : SMC_DTO_SalesOrderDetails.cls
 * @Description        :
 * @Author             : Vincent RECASENS (Modis)
 * @Group              :
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 10/12/2019 à 15:33:14
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    ??/07/2018   Vincent RECASENS (Modis)     Initial Version
 **/

public without sharing class SMC_DTO_SalesOrderDetails {
  @AuraEnabled
  public String salesOrder { get; set; }
  @AuraEnabled
  public Integer positionNumber { get; set; }
  @AuraEnabled
  public String item { get; set; }
  @AuraEnabled
  public String itemDescription { get; set; }
  @AuraEnabled
  public Integer orderedQuantity { get; set; }
  @AuraEnabled
  public Integer deliveredQuantity { get; set; }
  @AuraEnabled
  public Integer backOrder { get; set; }
  @AuraEnabled
  public Integer packingSlipNumber { get; set; }
  @AuraEnabled
  public Integer invoiceNumber { get; set; }
  @AuraEnabled
  public DateTime deliverySlipDate { get; set; }
  @AuraEnabled
  public String salesOrderFlowCategory { get; set; }
  @AuraEnabled
  public DateTime packingSlipShippingDate { get; set; }
  @AuraEnabled
  public String packingSlipCarrier { get; set; }
  @AuraEnabled
  public String packingSlipTrackingNumber { get; set; }
  @AuraEnabled
  public DateTime lineExWorkConfirmed { get; set; }
  @AuraEnabled
  public DateTime lineReviewDate { get; set; }
}