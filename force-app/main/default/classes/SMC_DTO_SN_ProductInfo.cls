/**
 * @File Name          : SMC_DTO_SN_ProductInfo.cls
 * @Description        :
 * @Author             : Vincent RECASENS (Modis)
 * @Group              :
 * @Last Modified By   : Vincent RECASENS (Modis)
 * @Last Modified On   : 08/04/2020 à 16:56:47
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    ??/??/2018   Vincent RECASENS (Modis)     Initial Version
 **/

public with sharing class SMC_DTO_SN_ProductInfo {
  @AuraEnabled
  public Integer id { get; set; }
  @AuraEnabled
  public String serialNumber { get; set; }
  @AuraEnabled
  public Double rate { get; set; }
  @AuraEnabled
  public String productFamily { get; set; }
  @AuraEnabled
  public String productFamilyDescription { get; set; }
  @AuraEnabled
  public String productModel { get; set; }
  @AuraEnabled
  public String productModelDescription { get; set; }
  @AuraEnabled
  public String productConfig { get; set; }
  @AuraEnabled
  public String productConfigDescription { get; set; }
}