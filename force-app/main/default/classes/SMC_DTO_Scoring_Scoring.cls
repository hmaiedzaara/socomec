/*
---------------------------------------------------------------------------
-- - Name : SMC_DTO_Scoring_Scoring
-- - Author : Vincent RECASENS
-- - Description : This class is a wrapper and it relate a scoring of a BA
--
-- Maintenance History:
--
-- Date         Name                    Version     Remarks
-- -----------  ----                    -------     ------------------
-- 12-FEB-2018  Vincent RECASENS  		1.0     Initial Version
---------------------------------------------------------------------------
*/

public without sharing class SMC_DTO_Scoring_Scoring {
  @AuraEnabled
  public String id { get; set; }

  @AuraEnabled
  public String sfAccount { get; set; }

  @AuraEnabled
  public Integer dpxId { get; set; }

  @AuraEnabled
  public SMC_DTO_Scoring_DPX dpx { get; set; }

  @AuraEnabled
  public Integer countViewer { get; set; }

  @AuraEnabled
  public Integer pricingPolicyId { get; set; }

  @AuraEnabled
  public SMC_DTO_Scoring_PricingPolicy pricingPolicy { get; set; }

  @AuraEnabled
  public List<SMC_DTO_Scoring_ScoringLine> scoringLines { get; set; }
}