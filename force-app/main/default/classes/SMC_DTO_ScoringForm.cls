/**
 * @File Name          : SMC_DTO_ScoringForm.cls
 * @Description        :
 * @Author             : Vincent RECASENS (Modis)
 * @Group              :
 * @Last Modified By   : Vincent RECASENS (Modis)
 * @Last Modified On   : 08/04/2020 à 16:56:47
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    12/02/2018   Vincent RECASENS (Modis)     Initial Version
 **/

public with sharing class SMC_DTO_ScoringForm {
  @AuraEnabled
  public String token { get; set; }

  @AuraEnabled
  public SMC_DTO_DiscountToken discountTokenDto { get; set; }

  @AuraEnabled
  public Account account { get; set; }

  @AuraEnabled
  public List<Account> accountList { get; set; }

  @AuraEnabled
  public String urlPartial { get; set; }

  @AuraEnabled
  public Boolean scoringExist { get; set; }

  @AuraEnabled
  public List<String> baIds { get; set; }

  public SMC_DTO_ScoringForm() {
  }
}