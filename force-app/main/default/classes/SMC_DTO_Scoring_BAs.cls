/**
 * @File Name          : SMC_DTO_Scoring_BAs.cls
 * @Description        :
 * @Author             : Vincent RECASENS (Modis)
 * @Group              :
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 10/12/2019 à 15:33:32
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    ??/07/2018   Vincent RECASENS (Modis)     Initial Version
 **/

public without sharing class SMC_DTO_Scoring_BAs {
  @AuraEnabled
  public String id { get; set; }

  @AuraEnabled
  public String ba { get; set; }

  @AuraEnabled
  public String expiryDate { get; set; }

  // @AuraEnabled
  // public Date expiryDate {get;set;}

  @AuraEnabled
  public Boolean valid { get; set; }

  @AuraEnabled
  public Boolean answerRequired { get; set; }

  public SMC_DTO_Scoring_BAs() {
  }

  // public SMC_DTO_Scoring_BAs(String expiryDate){
  //     this.expiryDate = Date.parse(expiryDate);
  // }

  public SMC_DTO_Scoring_BAs(String id, String ba) {
    this.id = id;
    this.ba = ba;
  }
}