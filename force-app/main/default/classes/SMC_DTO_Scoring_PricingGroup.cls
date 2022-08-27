/*
---------------------------------------------------------------------------
-- - Name : SMC_DTO_Scoring_ScoringLine
-- - Author : Vincent RECASENS
-- - Description : This class is a wrapper and it identify a pricing group
--
-- Maintenance History:
--
-- Date         Name                    Version     Remarks
-- -----------  ----                    -------     ------------------
-- 12-FEB-2018  Vincent RECASENS  		1.0     Initial Version
---------------------------------------------------------------------------
*/

public with sharing class SMC_DTO_Scoring_PricingGroup {
  @AuraEnabled
  public String id { get; set; }

  @AuraEnabled
  public String label { get; set; }

  /*AuraEnabled
  public String description { get; set; }*/
  @AuraEnabled
  public String descr { get; set; }
  @AuraEnabled
  public String code { get; set; }

  @AuraEnabled
  public Integer tri { get; set; }

  // //At 30/10/2018 11:33 --> In progress
  // @AuraEnabled
  // public String type {get; set;}

  public SMC_DTO_Scoring_PricingGroup() {
    this.id = '-1';
    // this.code = STA_UtilsStatic.UNKNOWN_VALUE;
    this.label = STA_UtilsStatic.UNKNOWN_VALUE;
    this.tri = 999;
    // this.type = 'NA';
  }
}