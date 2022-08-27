/*
---------------------------------------------------------------------------
-- - Name : SMC_DTO_Scoring_BusinessApplication
-- - Author : Vincent RECASENS
-- - Description : This class is a wrapper and it identify the business 
                   activity of a customer
--
-- Maintenance History:
--
-- Date         Name                    Version     Remarks
-- -----------  ----                    -------     ------------------
-- 12-FEB-2018  Vincent RECASENS        1.0     Initial Version
---------------------------------------------------------------------------
*/

public with sharing class SMC_DTO_Scoring_BusinessApplication {
  @AuraEnabled
  public Integer id { get; set; }

  @AuraEnabled
  public String ba { get; set; }
}