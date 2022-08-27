/*
---------------------------------------------------------------------------
-- - Name : SMC_DTO_Scoring_ScoringLine
-- - Author : Vincent RECASENS
-- - Description : This class is a wrapper and it represent a complete scoring
--
-- Maintenance History:
--
-- Date         Name                    Version     Remarks
-- -----------  ----                    -------     ------------------
-- 12-FEB-2018  Vincent RECASENS  		1.0     Initial Version
---------------------------------------------------------------------------
*/

public with sharing class SMC_DTO_Scoring_ScoringLine implements Comparable {
  @AuraEnabled
  public Integer id { get; set; }

  // @AuraEnabled
  // public Integer scoringId {get;set;}

  // @AuraEnabled
  // public Integer pricingGroupId {get;set;}

  @AuraEnabled
  public SMC_DTO_Scoring_PricingGroup priceGroup { get; set; }

  @AuraEnabled
  public Double maxSuggested { get; set; }

  @AuraEnabled
  public Double min { get; set; }

  @AuraEnabled
  public Double max { get; set; }

  @AuraEnabled
  public Double discount { get; set; }

  @AuraEnabled
  public Double discountTemp { get; set; }

  @AuraEnabled
  public Datetime createDate { get; set; }
  //DPHA 07/07
  @AuraEnabled
  public Datetime lastModifiedDate { get; set; }

  @AuraEnabled
  public Boolean valid { get; set; }

  //Champs non présent dans l'API *********************
  @AuraEnabled
  public Boolean isModified { get; set; }

  @AuraEnabled
  public Boolean discountTempExist { get; set; }
  // ***************************************************

  public Integer compareTo(Object compareTo) {
    SMC_DTO_Scoring_ScoringLine line = (SMC_DTO_Scoring_ScoringLine) compareTo;

    // The return value of 0 indicates that both elements are equal.
    Integer returnValue = 0;

    /*****Ca ne devrait pas arriver normalement d'avoir une valeur à null *****/
    if (line.priceGroup == null) {
      line.priceGroup = new SMC_DTO_Scoring_PricingGroup();
    }
    /**************************************************************************/

    if (this.priceGroup.tri > line.priceGroup.tri) {
      // Set return value to a positive value.
      returnValue = 1;
    } else if (this.priceGroup.tri < line.priceGroup.tri) {
      // Set return value to a negative value.
      returnValue = -1;
    }
    return returnValue;
  }
}