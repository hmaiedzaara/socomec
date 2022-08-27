/**
 * @File Name          : SMC_DTO_QuotationTool_MissingFields.cls
 * @Description        :
 * @Author             : Vincent RECASENS (Modis)
 * @Group              :
 * @Last Modified By   : Vincent RECASENS (Modis)
 * @Last Modified On   : 08/04/2020 à 16:56:47
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    ??/07/2018   Vincent RECASENS (Modis)     Initial Version
 **/

public with sharing class SMC_DTO_QuotationTool_MissingFields {
  @AuraEnabled
  public Account account { get; set; }

  @AuraEnabled
  public List<String> accountFields { get; set; }

  @AuraEnabled
  public Boolean accountFieldsMiss { get; set; }

  @AuraEnabled
  public Contact contact { get; set; }

  @AuraEnabled
  public List<String> contactFields { get; set; }

  @AuraEnabled
  public Boolean contactFieldsMiss { get; set; }

  @AuraEnabled
  public Quote quote { get; set; }

  @AuraEnabled
  public List<String> quoteFields { get; set; }

  @AuraEnabled
  public Boolean quoteFieldsMiss { get; set; }

  @AuraEnabled
  public Boolean fieldMiss { get; set; }

  @AuraEnabled
  public Boolean nullExist { get; set; }

  public SMC_DTO_QuotationTool_MissingFields() {
    this.nullExist = false;
    this.fieldMiss = false;
    this.accountFields = new List<String>();
    this.contactFields = new List<String>();
    this.quoteFields = new List<String>();
  }
}