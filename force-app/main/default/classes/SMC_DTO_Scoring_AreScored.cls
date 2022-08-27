/**
 * @File Name          : SMC_DTO_Scoring_AreScored.cls
 * @Description        :
 * @Author             : Vincent RECASENS (Modis)
 * @Group              :
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 10/12/2019 à 15:33:22
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    ??/07/2018   Vincent RECASENS (Modis)     Initial Version
 **/

public without sharing class SMC_DTO_Scoring_AreScored {
  @AuraEnabled
  public String account { get; set; }

  @AuraEnabled
  public String country { get; set; }

  @AuraEnabled
  public String category { get; set; }

  @AuraEnabled
  public String business { get; set; }

  @AuraEnabled
  public String acc { get; set; }

  @AuraEnabled
  public String tier { get; set; }

  @AuraEnabled
  public String user { get; set; }

  @AuraEnabled
  public String baIds { get; set; }

  @AuraEnabled
  public List<SMC_DTO_Scoring_BAs> bas { get; set; }

  @AuraEnabled
  public Boolean valid { get; set; } //...

  @AuraEnabled
  public Boolean answerRequired { get; set; } //...

  public SMC_DTO_Scoring_AreScored() {
  }
}