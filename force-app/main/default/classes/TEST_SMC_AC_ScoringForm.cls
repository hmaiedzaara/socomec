/*
---------------------------------------------------------------------------
-- - Name : TEST_SMC_AC_ScoringForm
-- - Author : Vincent RECASENS
-- - Description : This class test the Apex class SMC_AC_ScoringForm
--
-- Maintenance History:
--
-- Date         Name                    Version     Remarks
-- -----------  ----                    -------     ------------------
-- 27-NOV-2018  Vincent RECASENS  		1.0     	Initial Version
-- 01-JUN-2022  Denis PHAM            2.0       Add test class for the Discount Form v2
---------------------------------------------------------------------------
*/
@isTest
public with sharing class TEST_SMC_AC_ScoringForm {
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
    Account account = SMC_UTIL_TestUtils.createAccount(
      recordTypeId,
      STA_UtilsStatic.ACCOUNT_NAME1,
      STA_UtilsStatic.PICKLIST_ACCOUNT_TYPE_MARKETING_PROSPECT,
      STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY1
    );
    account.SMC_Category__c = STA_UtilsStatic.ACCOUNT_CATEGORY1;
    account.SMC_Activity__c = STA_UtilsStatic.ACCOUNT_ACTIVITY1;
    account.SMC_Business__c = STA_UtilsStatic.ACCOUNT_BUSINESS1;
    account.SMC_PCO_Price_List__c = STA_UtilsStatic.ACCOUNT_PRICELIST;
    account.SMC_Pricing_Tier__c = STA_UtilsStatic.ACCOUNT_PRICE_LIST_TIER;
    insert account;
  }

  /**
   * @description : test SMC_AC_ScoringForm.getDiscountInformationsFromDiscountForm()
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  @isTest
  public static void testGetDiscountInformationsFromDiscountForm() {
    System.debug(
      LoggingLevel.INFO,
      '>>>>>> TEST_SMC_AC_ScoringForm : testGetDiscountInformationsFromDiscountForm - START'
    );

    Account account = [
      SELECT
        Id,
        Name,
        AccountNumber,
        SMC_Category__c,
        SMC_Business__c,
        SMC_Pricing_Tier__c,
        BillingCountryCode
      FROM Account
      LIMIT 1
    ];

    SMC_UTIL_MockHttpResponseGenerator fakeResponse = new SMC_UTIL_MockHttpResponseGenerator(
      200,
      STA_UtilsStatic.COMPLETE,
      SMC_UTIL_ScoringMockJSONs.DISCOUNT_TOKEN,
      null
    );
    Test.setMock(HttpCalloutMock.class, fakeResponse);
    Test.startTest();
    SMC_DTO_ScoringForm dtoScoringForm = SMC_AC_ScoringForm.getDiscountInformationsFromDiscountForm(
      account.Id
    );
    Test.stopTest();

    System.assertEquals(
      account.Id,
      dtoScoringForm.account.Id,
      'Mock is wrong. Check it and relaunch test.'
    );
    System.assertNotEquals(
      null,
      dtoScoringForm.token,
      'Mock is wrong. Check it and relaunch test.'
    );
    System.assertNotEquals(
      null,
      dtoScoringForm.urlPartial,
      'Mock is wrong. Check it and relaunch test.'
    );

    System.debug(
      LoggingLevel.INFO,
      '>>>>>> TEST_SMC_AC_ScoringForm : testGetDiscountInformationsFromDiscountForm - END'
    );
  }

  /**
   * @description : testSMC_AC_ScoringForm.getDiscountInformations()
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  @isTest
  public static void testGetDiscountInformations() {
    System.debug(
      LoggingLevel.INFO,
      '>>>>>> TEST_SMC_AC_ScoringForm : testGetDiscountInformations - START'
    );

    Account account = [
      SELECT
        Id,
        Name,
        AccountNumber,
        SMC_Category__c,
        SMC_Business__c,
        SMC_Pricing_Tier__c,
        BillingCountryCode
      FROM Account
      LIMIT 1
    ];

    SMC_UTIL_MockHttpResponseGenerator fakeResponse = new SMC_UTIL_MockHttpResponseGenerator(
      200,
      STA_UtilsStatic.COMPLETE,
      SMC_UTIL_ScoringMockJSONs.DISCOUNT_TOKEN,
      null
    );
    Test.setMock(HttpCalloutMock.class, fakeResponse);
    Test.startTest();
    SMC_DTO_ScoringForm dtoScoringForm = SMC_AC_ScoringForm.getDiscountInformations(
      new Set<Id>{ account.Id },
      false
    );
    Test.stopTest();

    System.assertEquals(
      account.Id,
      dtoScoringForm.account.Id,
      'Mock is wrong. Check it and relaunch test.'
    );
    System.assertNotEquals(
      null,
      dtoScoringForm.token,
      'Mock is wrong. Check it and relaunch test.'
    );
    System.assertNotEquals(
      null,
      dtoScoringForm.urlPartial,
      'Mock is wrong. Check it and relaunch test.'
    );

    System.debug(
      LoggingLevel.INFO,
      '>>>>>> TEST_SMC_AC_ScoringForm : testGetDiscountInformations - END'
    );
  }

  /**
   * @description : test SMC_AC_ScoringForm.upsertDiscount(Insert)
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  @isTest
  public static void testUpsertDiscountInsert() {
    System.debug(
      LoggingLevel.INFO,
      '>>>>>> TEST_SMC_AC_ScoringForm : testUpsertDiscountInsert - START'
    );

    Account account = [
      SELECT
        Id,
        Name,
        AccountNumber,
        SMC_Category__c,
        SMC_Business__c,
        SMC_Pricing_Tier__c,
        BillingCountryCode
      FROM Account
      LIMIT 1
    ];

    List<SMC_DTO_Scoring_AreScored> listResultMock = (List<SMC_DTO_Scoring_AreScored>) JSON.deserialize(
      SMC_UTIL_ScoringMockJSONs.ARE_SCORED_WITHOUT_BA,
      (List<SMC_DTO_Scoring_AreScored>.class)
    );
    listResultMock[0].account = account.Id;

    SMC_DTO_DiscountToken discountToken = new SMC_DTO_DiscountToken();
    discountToken.refreshToken = SMC_UTIL_ScoringMockJSONs.DISCOUNT_TOKEN;
    discountToken.callInformations = SMC_AC_ScoringForm.getHost();
    SMC_DTO_ScoringForm dtoScoringForm = new SMC_DTO_ScoringForm();
    dtoScoringForm.account = account;
    dtoScoringForm.token = SMC_UTIL_ScoringMockJSONs.DISCOUNT_TOKEN;
    dtoScoringForm.discountTokenDto = discountToken;

    SMC_UTIL_MockHttpResponseGenerator fakeResponse = new SMC_UTIL_MockHttpResponseGenerator(
      200,
      STA_UtilsStatic.COMPLETE,
      SMC_UTIL_ScoringMockJSONs.POST_SUCCESS,
      null
    );
    Test.setMock(HttpCalloutMock.class, fakeResponse);
    Test.startTest();
    SMC_AC_ScoringForm.ObjectLinkDiscountInfrmationToUpsertDiscount objectLink = SMC_AC_ScoringForm.upsertDiscount(
      new List<Account>{ account },
      dtoScoringForm,
      true,
      listResultMock
    );
    Test.stopTest();

    System.assert(
      objectLink.scoringExist,
      'Mock is wrong. Check it and relaunch test.'
    );
    System.assertNOtEquals(
      null,
      objectLink.baIds,
      'Mock is wrong. Check it and relaunch test.'
    );

    System.debug(
      LoggingLevel.INFO,
      '>>>>>> TEST_SMC_AC_ScoringForm : testUpsertDiscountInsert - END'
    );
  }

  /**
   * @description : test SMC_AC_ScoringForm.upsertDiscount(Update)
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  @isTest
  public static void testUpsertDiscountUpdate() {
    System.debug(
      LoggingLevel.INFO,
      '>>>>>> TEST_SMC_AC_ScoringForm : testUpsertDiscountUpdate - START'
    );

    Account account = [
      SELECT
        Id,
        Name,
        AccountNumber,
        SMC_Category__c,
        SMC_Business__c,
        SMC_Pricing_Tier__c,
        BillingCountryCode
      FROM Account
      LIMIT 1
    ];

    List<SMC_DTO_Scoring_AreScored> listResultMock = (List<SMC_DTO_Scoring_AreScored>) JSON.deserialize(
      SMC_UTIL_ScoringMockJSONs.ARE_SCORED,
      (List<SMC_DTO_Scoring_AreScored>.class)
    );
    listResultMock[0].account = account.Id;

    SMC_DTO_DiscountToken discountToken = new SMC_DTO_DiscountToken();
    discountToken.refreshToken = SMC_UTIL_ScoringMockJSONs.DISCOUNT_TOKEN;
    discountToken.callInformations = SMC_AC_ScoringForm.getHost();
    SMC_DTO_ScoringForm dtoScoringForm = new SMC_DTO_ScoringForm();
    dtoScoringForm.account = account;
    dtoScoringForm.token = SMC_UTIL_ScoringMockJSONs.DISCOUNT_TOKEN;
    dtoScoringForm.discountTokenDto = discountToken;

    SMC_UTIL_MockHttpResponseGenerator fakeResponse = new SMC_UTIL_MockHttpResponseGenerator(
      200,
      STA_UtilsStatic.COMPLETE,
      SMC_UTIL_ScoringMockJSONs.PUT_UPDATE_SUCCESS,
      null
    );
    Test.setMock(HttpCalloutMock.class, fakeResponse);
    Test.startTest();
    SMC_AC_ScoringForm.ObjectLinkDiscountInfrmationToUpsertDiscount objectLink = SMC_AC_ScoringForm.upsertDiscount(
      new List<Account>{ account },
      dtoScoringForm,
      false,
      listResultMock
    );
    Test.stopTest();

    System.assert(
      objectLink.scoringExist,
      'Mock is wrong. Check it and relaunch test.'
    );
    System.assertNOtEquals(
      null,
      objectLink.baIds,
      'Mock is wrong. Check it and relaunch test.'
    );

    System.debug(
      LoggingLevel.INFO,
      '>>>>>> TEST_SMC_AC_ScoringForm : testUpsertDiscountUpdate - END'
    );
  }

  /**
  * @description : test SMC_AC_ScoringForm.getBaInformations()
  * @author Denis PHAM  (Modis) | 01/06/2022
  **/
  @isTest
  public static void testGetBaInfo() {

    Test.startTest();

    List<SMC_BA_Information__mdt> lBa = SMC_AC_ScoringForm.getBaInformations();

    Test.stopTest();

    System.assertNotEquals(0, lBa.size(), 'The list is empty');
  }

  /**
   * @description : test SMC_AC_ScoringForm.getDiscountInformationsFromDiscountForm_v2()
   * @author Denis PHAM  (Modis) | 01/06/2022
   **/
  @isTest
  public static void testGetDiscountInformationsFromDiscountForm_v2() {
    System.debug(
      LoggingLevel.INFO,
      '>>>>>> TEST_SMC_AC_ScoringForm : testGetDiscountInformationsFromDiscountForm_v2 - START'
    );

    Account account = [
      SELECT
        Id,
        Name,
        AccountNumber,
        SMC_Category__c,
        SMC_Business__c,
        SMC_Pricing_Tier__c,
        BillingCountryCode
      FROM Account
      LIMIT 1
    ];

    Test.startTest();
    SMC_DTO_ScoringForm dtoScoringForm = SMC_AC_ScoringForm.getDiscountInformationsFromDiscountForm_v2(
      account.Id
    );
    Test.stopTest();

    System.assertEquals(
      account.Id,
      dtoScoringForm.account.Id,
      'Mock is wrong. Check it and relaunch test.'
    );
    System.assertNotEquals(
      null,
      dtoScoringForm.token,
      'Mock is wrong. Check it and relaunch test.'
    );
    System.assertNotEquals(
      null,
      dtoScoringForm.urlPartial,
      'Mock is wrong. Check it and relaunch test.'
    );

    System.debug(
      LoggingLevel.INFO,
      '>>>>>> TEST_SMC_AC_ScoringForm : testGetDiscountInformationsFromDiscountForm_v2 - END'
    );
  }

  /**
   * @description : testSMC_AC_ScoringForm.getDiscountInformations_v2()
   * @author Denis PHAM  (Modis) | 01/06/2022
   **/
  @isTest
  public static void testGetDiscountInformations_v2() {
    System.debug(
      LoggingLevel.INFO,
      '>>>>>> TEST_SMC_AC_ScoringForm : testGetDiscountInformations_v2 - START'
    );

    Account account = [
      SELECT
        Id,
        Name,
        AccountNumber,
        SMC_Category__c,
        SMC_Business__c,
        SMC_Pricing_Tier__c,
        BillingCountryCode
      FROM Account
      LIMIT 1
    ];

    Test.startTest();
    SMC_DTO_ScoringForm dtoScoringForm = SMC_AC_ScoringForm.getDiscountInformations(
      new Set<Id>{ account.Id },
      false
    );
    Test.stopTest();

    System.assertEquals(
      account.Id,
      dtoScoringForm.account.Id,
      'Mock is wrong. Check it and relaunch test.'
    );
    System.assertNotEquals(
      null,
      dtoScoringForm.token,
      'Mock is wrong. Check it and relaunch test.'
    );
    System.assertNotEquals(
      null,
      dtoScoringForm.urlPartial,
      'Mock is wrong. Check it and relaunch test.'
    );

    System.debug(
      LoggingLevel.INFO,
      '>>>>>> TEST_SMC_AC_ScoringForm : testGetDiscountInformations_v2 - END'
    );
  }
}