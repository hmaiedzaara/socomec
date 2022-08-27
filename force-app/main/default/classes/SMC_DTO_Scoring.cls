/*
---------------------------------------------------------------------------
-- - Name : SMC_DTO_ScoringBa
-- - Author : Vincent RECASENS
-- - Description : This class is a wrapper and it represent a BA
--
-- Maintenance History:
--
-- Date         Name                    Version     Remarks
-- -----------  ----                    -------     ------------------
-- 12-FEB-2018  Vincent RECASENS        1.0     Initial Version
---------------------------------------------------------------------------
*/

public without sharing class SMC_DTO_Scoring {
  @AuraEnabled
  public SMC_DTO_Scoring_BusinessApplication ba { get; set; }

  @AuraEnabled
  public List<SMC_DTO_Scoring_ScoringLine> scoringLines { get; set; }

  @AuraEnabled
  public Boolean userSeeMaxSuggested { get; set; }

  @AuraEnabled
  public String userLanguage { get; set; }

  public SMC_DTO_Scoring() {
    this.userLanguage = UserInfo.getLanguage();
    this.scoringLines = new List<SMC_DTO_Scoring_ScoringLine>();
  }
}