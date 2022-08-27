/*
---------------------------------------------------------------------------
-- - Name : SMC_DTO_Scoring_DPX
-- - Author : Vincent RECASENS
-- - Description : This class is a wrapper and it relate a DPX for a customer
--
-- Maintenance History:
--
-- Date         Name                    Version     Remarks
-- -----------  ----                    -------     ------------------
-- 12-FEB-2018  Vincent RECASENS  		1.0     Initial Version
---------------------------------------------------------------------------
*/

public with sharing class SMC_DTO_Scoring_DPX {
  @AuraEnabled
  public String id { get; set; }

  @AuraEnabled
  public SMC_DTO_Scoring_BusinessApplication businessApplication { get; set; }

  @AuraEnabled
  public String startDate { get; set; }

  @AuraEnabled
  public String endDate { get; set; }

  @auraEnabled
  public String description { get; set; }
}