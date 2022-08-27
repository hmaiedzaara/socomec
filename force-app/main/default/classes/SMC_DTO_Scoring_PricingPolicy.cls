/*
---------------------------------------------------------------------------
-- - Name : SMC_DTO_Scoring_Scoring
-- - Author : Vincent RECASENS
-- - Description : This class is a wrapper and it identify the pricing 
				   policy  of a customer
--
-- Maintenance History:
--
-- Date         Name                    Version     Remarks
-- -----------  ----                    -------     ------------------
-- 12-FEB-2018  Vincent RECASENS  		1.0     Initial Version
---------------------------------------------------------------------------
*/

public with sharing class SMC_DTO_Scoring_PricingPolicy {
  @AuraEnabled
  public Integer id { get; set; }

  @AuraEnabled
  public String code { get; set; }

  @AuraEnabled
  public Boolean isCorporate { get; set; }

  @AuraEnabled
  public String label { get; set; }

  @AuraEnabled
  public Boolean isActive { get; set; }
}