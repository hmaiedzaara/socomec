/**
 * @File Name          : SMC_DTO_GetAllScoring.cls
 * @Description        :
 * @Author             : Vincent RECASENS (Modis)
 * @Group              :
 * @Last Modified By   : Vincent RECASENS (Modis)
 * @Last Modified On   : 08/04/2020 à 16:53:14
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    ??/02/2018   Vincent RECASENS (Modis)     Initial Version
 **/

public with sharing class SMC_DTO_GetAllScoring {
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
  public List<SMC_DTO_Scoring> scorings { get; set; }

  public SMC_DTO_GetAllScoring() {
  }
}