/**
 * @File Name          : SMC_DTO_TheScoringLine.cls
 * @Description        :
 * @Author             : Vincent RECASENS (Modis)
 * @Group              :
 * @Last Modified By   : Vincent RECASENS (Modis)
 * @Last Modified On   : 08/04/2020 à 16:56:47
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    12/02/2018   Vincent RECASENS (Modis)     Initial Version
 **/

public with sharing class SMC_DTO_TheScoringLine {
  @AuraEnabled
  public Integer scoringLineId { get; set; }

  @AuraEnabled
  public Double discount { get; set; }

  @AuraEnabled
  public Double maxSuggested { get; set; }

  @AuraEnabled
  public Double discountTemp { get; set; }

  @AuraEnabled
  public String user { get; set; }

  public SMC_DTO_TheScoringLine() {
  }

  public SMC_DTO_TheScoringLine(
    SMC_DTO_Scoring_ScoringLine scoringLine,
    String userId
  ) {
    this.scoringLineId = scoringLine.id;
    this.maxSuggested = scoringLine.maxSuggested;
    this.user = userId;

    this.discount = scoringLine.discount;
    if (scoringLine.discountTemp != null) {
      this.discountTemp = scoringLine.discountTemp;
    } else {
      this.discountTemp = null;
    }
  }
}