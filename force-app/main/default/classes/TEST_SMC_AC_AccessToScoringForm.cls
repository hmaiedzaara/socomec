/*
---------------------------------------------------------------------------
-- - Name : TEST_SMC_AC_AccessToScoringForm
-- - Author : Vincent RECASENS
-- - Description : This class is the Apex test of SMC_AC_AccessToScoringForm
--
-- Maintenance History:
--
-- Date 		Name 				Version 	Remarks
-- ----------- 	---- 				------- 	------------------
-- 26-DEC-2017 	Vincent RECASENS	1.0			Initial Version
---------------------------------------------------------------------------
*/
@isTest
public without sharing class TEST_SMC_AC_AccessToScoringForm {
  /**
   * @description : test method "getTheAccount"
   * @author Vincent RECASENS (Modis) | 09/06/2020
   * @return void
   **/
  @isTest
  public static void testGetTheAccount() {
    PAD.bypassAll = true;

    Id recordTypeId = [
        SELECT Id
        FROM RecordType
        WHERE name = :STA_UtilsStatic.RECORDTYPE_ACCOUNT_CUSTOMER
        LIMIT 1
      ]
      .get(0)
      .Id;
    Account acc = SMC_UTIL_TestUtils.createAccount(
      recordTypeId,
      STA_UtilsStatic.ACCOUNT_NAME1,
      STA_UtilsStatic.PICKLIST_ACCOUNT_TYPE_MARKETING_PROSPECT,
      STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY1
    );
    acc.SMC_Category__c = STA_UtilsStatic.ACCOUNT_CATEGORY1;
    acc.SMC_Activity__c = STA_UtilsStatic.ACCOUNT_ACTIVITY1;
    acc.SMC_Business__c = STA_UtilsStatic.ACCOUNT_BUSINESS1;
    acc.SMC_PCO_Price_List__c = STA_UtilsStatic.ACCOUNT_PRICELIST;
    insert acc;

    //Success
    Access_to_Scoring_form__mdt[] mdtUrl = [
      SELECT Url_Access__c, Error_Access__c
      FROM Access_to_Scoring_form__mdt
    ];
    String url = mdtUrl[0].Url_Access__c + +acc.Id;
    String goodConditionsResult = SMC_AC_AccessToScoringForm.getTheAccount(
      acc.Id
    );
    System.assertEquals(url, goodConditionsResult, 'URL is not valide.');

    //Error message
    acc.SMC_Category__c = null;
    acc.SMC_Activity__c = null;
    acc.SMC_Business__c = null;
    acc.SMC_PCO_Price_List__c = null;
    update acc;
    String errorConditionsResult = SMC_AC_AccessToScoringForm.getTheAccount(
      acc.Id
    );
    System.assertEquals(
      mdtUrl[0].Error_Access__c,
      errorConditionsResult,
      'Error conditions not met (for account).'
    );

    //Exception
    String exceptionConditionsResult = SMC_AC_AccessToScoringForm.getTheAccount(
      null
    );
    System.assertEquals(
      mdtUrl[0].Error_Access__c,
      exceptionConditionsResult,
      'Error conditions not met (for null).'
    );
  }
}