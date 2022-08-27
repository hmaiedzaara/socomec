/*
---------------------------------------------------------------------------
-- - Name : TEST_SMC_AC_Scoring
-- - Author : Vincent RECASENS
-- - Description : This class test the Apex class SMC_AC_Scoring
--
-- Maintenance History:
--
-- Date         Name                    Version     Remarks
-- -----------  ----                    -------     ------------------
-- 28-MAR-2018  Vincent RECASENS  		1.0     	Initial Version
-- 01-JUN-2022  Denis PHAM            2.0       Add test class for the Discount Form v2
---------------------------------------------------------------------------
*/

@isTest
public without sharing class TEST_SMC_AC_Scoring {
  /**
   * @description : test setup
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  @testSetup
  public static void setup() {
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
  }

  /**
   * @description : test SMC_AC_Scoring.getTheScoring()
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  @isTest
  public static void testGetTheScoring() {
    System.debug(
      LoggingLevel.INFO,
      '>>>>>> TEST_SMC_AC_Scoring : testGetTheScoring - START'
    );

    Account account = [
      SELECT
        Id,
        Name,
        BillingCountryCode,
        SMC_Business__c,
        SMC_Category__c,
        SMC_PCO_Price_List__c
      FROM Account
      LIMIT 1
    ];
    SMC_UTIL_MockHttpResponseGenerator fakeResponse = new SMC_UTIL_MockHttpResponseGenerator(
      200,
      STA_UtilsStatic.COMPLETE,
      SMC_UTIL_ScoringMockJSONs.GET_ALL_SCORING_MOCK,
      null
    );

    Test.setMock(HttpCalloutMock.class, fakeResponse);
    Test.startTest();
    List<SMC_DTO_Scoring> items = SMC_AC_Scoring.getTheScoring(
      JSON.serialize(account),
      SMC_UTIL_ScoringMockJSONs.DISCOUNT_TOKEN,
      new List<String>{ STA_UtilsStatic.ONE }
    );
    Test.stopTest();

    System.debug(LoggingLevel.INFO, 'items : ' + items);

    System.assert(
      items.size() > 0,
      'Mock is wrong. Check it and relaunch test.'
    );
    System.debug(
      LoggingLevel.INFO,
      '>>>>>> TEST_SMC_AC_Scoring : testGetTheScoring - END'
    );
  }

  /**
   * @description : test SMC_AC_Scoring.saveTheScoring()
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  @isTest
  public static void testSaveTheScoring() {
    System.debug(
      LoggingLevel.INFO,
      '>>>>>> TEST_SMC_AC_Scoring : testSaveTheScoring - START'
    );

    String body = SMC_UTIL_ScoringMockJSONs.PUT_SAVE_BODY;
    Boolean res = false;

    SMC_UTIL_MockHttpResponseGenerator fakeResponse = new SMC_UTIL_MockHttpResponseGenerator(
      200,
      STA_UtilsStatic.COMPLETE,
      SMC_UTIL_ScoringMockJSONs.PUT_SAVE_SUCCESS,
      null
    );
    Test.setMock(HttpCalloutMock.class, fakeResponse);
    Test.startTest();
    res = SMC_AC_Scoring.saveTheScoring(
      body,
      SMC_UTIL_ScoringMockJSONs.DISCOUNT_TOKEN,
      null
    );
    Test.stopTest();
    System.assert(res, 'Mock is wrong. Check it and relaunch test.');
    System.debug(
      LoggingLevel.INFO,
      '>>>>>> TEST_SMC_AC_Scoring : testSaveTheScoring - END'
    );
  }

  /**
  * @description : test SMC_AC_Scoring.getTheScoring_v2()
  * @author Denis PHAM (Modis) | 01/06/2022
  **/
  @isTest
  public static void testGetTheScoring_v2() {
    System.debug(
      LoggingLevel.INFO,
      '>>>>>> TEST_SMC_AC_Scoring : testGetTheScoring_v2 - START'
    );

    Account account = [
      SELECT
        Id,
        Name,
        BillingCountryCode,
        SMC_Business__c,
        SMC_Category__c,
        SMC_PCO_Price_List__c
      FROM Account
      LIMIT 1
    ];
    SMC_UTIL_MockHttpResponseGenerator fakeResponse = new SMC_UTIL_MockHttpResponseGenerator(
      200,
      STA_UtilsStatic.COMPLETE,
      SMC_UTIL_ScoringMockJSONs.GET_SCORING_MOCK,
      null
    );

    Test.setMock(HttpCalloutMock.class, fakeResponse);
    Test.startTest();
    List<SMC_DTO_Scoring> items = SMC_AC_Scoring.getTheScoring_v2(
      JSON.serialize(account),
      SMC_UTIL_ScoringMockJSONs.DISCOUNT_TOKEN, //I can also use the Session ID of the user ? 
      STA_UtilsStatic.ONE
    );
    Test.stopTest();

    System.debug(LoggingLevel.INFO, 'items : ' + items);

    System.assert(
      items.size() > 0,
      'Mock is wrong. Check it and relaunch test.'
    );
    System.debug(
      LoggingLevel.INFO,
      '>>>>>> TEST_SMC_AC_Scoring : testGetTheScoring_v2 - END'
    );
  }
}