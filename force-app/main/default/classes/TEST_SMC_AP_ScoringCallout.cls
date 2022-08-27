/*
---------------------------------------------------------------------------
-- - Name : TEST_SMC_AP_ScoringCallout
-- - Author : Vincent RECASENS
-- - Description : This class is the test of SMC_AP_ScoringCallout
--
-- Maintenance History:
--
-- Date         Name                    Version     Remarks
-- -----------  ----                    -------     ------------------
-- 04-OCT-2018  Vincent RECASENS  		1.0     	Initial Version
-- 01-JUN-2022  Denis PHAM            2.0       Add test class for the Discount Form v2
---------------------------------------------------------------------------
*/

@isTest
public without sharing class TEST_SMC_AP_ScoringCallout {
  /**
   * @description : test setup
   * @author Vincent RECASENS (Modis) | 07-15-2020
   **/
  @testSetup
  public static void testSetup() {
    Profile profileStandard = [
      SELECT Id
      FROM Profile
      WHERE Name = :STA_UtilsStatic.PROFILE_SALE_STANDARD
    ];
    User userStandard1 = SMC_UTIL_TestUtils.createUser(
      'Standard1-' + STA_UtilsStatic.USER_NICKNAME,
      'Standard1-' + STA_UtilsStatic.USERNAME_TEST,
      profileStandard.Id,
      'Standard1-' + STA_UtilsStatic.USERNAME_TEST,
      'Standard1-' + STA_UtilsStatic.USER_NICKNAME
    );
    userStandard1.UserRoleId = [
      SELECT Id
      FROM UserRole
      WHERE DeveloperName = :STA_UtilsStatic.ROLE_CEO_DEVNAME
    ]
    .Id; //CEO
    // userStandard1.Bypass_All_Processes_Builder__c = true;
    // userStandard1.Bypass_All_Validation_Rules__c = true;
    // userStandard1.Bypass_All_Workflow_Rules__c = true;
    insert new List<User>{ userStandard1 };

    System.runAs(userStandard1) {
      Map<String, Schema.RecordTypeInfo> recordTypesAccount = new Map<String, Schema.RecordTypeInfo>();
      recordTypesAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName();
      Id recordTypeAccCustomerId = recordTypesAccount.get(
          STA_UtilsStatic.RECORDTYPE_ACCOUNT_CUSTOMER_DEVNAME
        )
        .getRecordTypeId();
      Account account = SMC_UTIL_TestUtils.createAccount(
        recordTypeAccCustomerId,
        STA_UtilsStatic.ACCOUNT_NAME1,
        STA_UtilsStatic.PICKLIST_ACCOUNT_TYPE_CUSTOMER,
        STA_UtilsStatic.ACCOUNT_BILLINGSTREET1,
        STA_UtilsStatic.ACCOUNT_BILLINGPOSTALCODE1,
        STA_UtilsStatic.ACCOUNT_BILLINGCITY1,
        STA_UtilsStatic.ACCOUNT_BILLINGSTATE1,
        STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY1,
        userStandard1.Id,
        userStandard1.Id,
        userStandard1.Id,
        userStandard1.Id,
        userStandard1.Id
      );
      insert account;
    }
  }

  /**
   * @description : test SMC_AP_ScoringCallout.getDiscountToken()
   * @author Vincent RECASENS (Modis) | 07-15-2020
   **/
  @isTest
  public static void testGetDiscountToken() {
    User stanadrdUser = [
      SELECT
        Id,
        Username,
        Alias,
        FirstName,
        LastName,
        SMC_Subsdiary_Label__c,
        UserType
      FROM User
      WHERE Email = :('Standard1-' + STA_UtilsStatic.USERNAME_TEST)
    ];

    System.runAs(stanadrdUser) {
      Call_Scoring_Domain__mdt tokenInformations = new Call_Scoring_Domain__mdt();
      tokenInformations.SecurityToken_Application__c = SMC_UTIL_ScoringMockJSONs.GET_DISCOUNT_TOKEN_APPLICATION;
      tokenInformations.SecurityToken_Secret__c = SMC_UTIL_ScoringMockJSONs.GET_DISCOUNT_TOKEN_SECRET;

      SMC_UTIL_MockHttpResponseGenerator fakeResponse = new SMC_UTIL_MockHttpResponseGenerator(
        200,
        STA_UtilsStatic.COMPLETE,
        SMC_UTIL_ScoringMockJSONs.DISCOUNT_TOKEN,
        null
      );
      Test.setMock(HttpCalloutMock.class, fakeResponse);
      Test.startTest();
      SMC_DTO_DiscountToken discountToken = SMC_AP_ScoringCallout.getDiscountToken(
        tokenInformations,
        'auth/',
        null
      );
      Test.stopTest();

      System.assertEquals(
        'refreshToken',
        discountToken.refreshToken,
        'Mock is wrong. Check it.'
      );
    }
  }
    
  /**
  * @description : test SMC_AP_ScoringCallout.getDiscountToken()
  * @author Denis PHAM (Modis) | 01/06/2022
  **/
  @isTest
  public static void testGetDiscountToken_Fail() {
    User standardUser = [
      SELECT
        Id,
        Username,
        Alias,
        FirstName,
        LastName,
        SMC_Subsdiary_Label__c,
        UserType
      FROM User
      WHERE Email = :('Standard1-' + STA_UtilsStatic.USERNAME_TEST)
    ];

    System.runAs(standardUser) {
      
      Call_Scoring_Domain__mdt tokenInformations = new Call_Scoring_Domain__mdt();
      tokenInformations.SecurityToken_Application__c = SMC_UTIL_ScoringMockJSONs.GET_DISCOUNT_TOKEN_APPLICATION;
      tokenInformations.SecurityToken_Secret__c = SMC_UTIL_ScoringMockJSONs.GET_DISCOUNT_TOKEN_SECRET;

      SMC_UTIL_MockHttpResponseGenerator fakeResponse = new SMC_UTIL_MockHttpResponseGenerator(
        500,
        STA_UtilsStatic.BAD_JSON,
        SMC_UTIL_ScoringMockJSONs.BAD_JSON,
        null
      );
      Test.setMock(HttpCalloutMock.class, fakeResponse);
      Test.startTest();
      SMC_DTO_DiscountToken discountToken;
      try{
        discountToken = SMC_AP_ScoringCallout.getDiscountToken(
          tokenInformations,
          'auth/',
          null
        );
      }catch(Exception e){
        System.debug(e);
      }
      Test.stopTest();

      System.assertNotEquals(
        'refreshToken',
        discountToken.refreshToken,
        'Mock is wrong. Check it.'
      );
    }
  }

  /**
   * @description : test SMC_AP_ScoringCallout.areScoredScoring()
   * @author Vincent RECASENS (Modis) | 07-15-2020
   **/
  @isTest
  public static void testAreScored() {
    User stanadrdUser = [
      SELECT
        Id,
        Username,
        Alias,
        FirstName,
        LastName,
        SMC_Subsdiary_Label__c,
        UserType
      FROM User
      WHERE Email = :('Standard1-' + STA_UtilsStatic.USERNAME_TEST)
    ];

    System.runAs(stanadrdUser) {
      SMC_UTIL_MockHttpResponseGenerator fakeResponse = new SMC_UTIL_MockHttpResponseGenerator(
        200,
        STA_UtilsStatic.COMPLETE,
        SMC_UTIL_ScoringMockJSONs.ARE_SCORED_BODY,
        null
      );
      Test.setMock(HttpCalloutMock.class, fakeResponse);

      Test.startTest();
      List<SMC_DTO_Scoring_AreScored> areScored = SMC_AP_ScoringCallout.areScoredScoring(
        SMC_UTIL_ScoringMockJSONs.ARE_SCORED,
        STA_UtilsStatic.END_POINT,
        SMC_UTIL_ScoringMockJSONs.DISCOUNT_TOKEN,
        null
      );
      Test.stopTest();

      System.assert(areScored.size() > 0, 'Mock is wrong. Check it.');
    }
  }

  /**
  * @description : test SMC_AP_ScoringCallout.areScoredScoring()
  * @author Denis PHAM (Modis) | 01/06/2022
  **/
  @isTest
  public static void testAreScored_Fail() {
    User stanadrdUser = [
      SELECT
        Id,
        Username,
        Alias,
        FirstName,
        LastName,
        SMC_Subsdiary_Label__c,
        UserType
      FROM User
      WHERE Email = :('Standard1-' + STA_UtilsStatic.USERNAME_TEST)
    ];

    System.runAs(stanadrdUser) {
      SMC_UTIL_MockHttpResponseGenerator fakeResponse = new SMC_UTIL_MockHttpResponseGenerator(
        500,
        STA_UtilsStatic.BAD_JSON,
        SMC_UTIL_ScoringMockJSONs.BAD_JSON,
        null
      );
      Test.setMock(HttpCalloutMock.class, fakeResponse);

      Test.startTest();
      List<SMC_DTO_Scoring_AreScored> areScored = new List<SMC_DTO_Scoring_AreScored>();
      try{
        areScored = SMC_AP_ScoringCallout.areScoredScoring(
          SMC_UTIL_ScoringMockJSONs.ARE_SCORED,
          STA_UtilsStatic.END_POINT,
          SMC_UTIL_ScoringMockJSONs.DISCOUNT_TOKEN,
          null
        );
      } catch(Exception e){
        System.debug(e);
      }
      Test.stopTest();

      System.assertEquals(null, areScored);
    }
  }

  /**
   * @description : test SMC_AP_ScoringCallout.upsertScoring(Insert)
   * @author Vincent RECASENS (Modis) | 07-15-2020
   **/
  @isTest
  public static void testUpsertScoring_Insert() {
    User stanadrdUser = [
      SELECT
        Id,
        Username,
        Alias,
        FirstName,
        LastName,
        SMC_Subsdiary_Label__c,
        UserType
      FROM User
      WHERE Email = :('Standard1-' + STA_UtilsStatic.USERNAME_TEST)
    ];

    System.runAs(stanadrdUser) {
      SMC_UTIL_MockHttpResponseGenerator fakeResponse = new SMC_UTIL_MockHttpResponseGenerator(
        200,
        STA_UtilsStatic.COMPLETE,
        SMC_UTIL_ScoringMockJSONs.PUT_SAVE_SUCCESS,
        null
      );
      Test.setMock(HttpCalloutMock.class, fakeResponse);

      SMC_AP_ScoringCallout.ScoringWrapper wrapperReturn;
      Test.startTest();
      wrapperReturn = SMC_AP_ScoringCallout.upsertScoring(
        SMC_UTIL_ScoringMockJSONs.UPSERT_SCORING,
        STA_UtilsStatic.POST_METHOD,
        STA_UtilsStatic.END_POINT,
        SMC_UTIL_ScoringMockJSONs.DISCOUNT_TOKEN,
        null
      );
      Test.stopTest();

      System.assert(
        wrapperReturn.response.getStatusCode() == 200,
        'Mock is wrong. Check it.'
      );
    }
  }

  /**
   * @description : test SMC_AP_ScoringCallout.upsertScoring(Insert)
   * @author Denis PHAM (Modis) | 01/06/2022
   **/
  @isTest
  public static void testUpsertScoring_Insert_Fail() {
    User stanadrdUser = [
      SELECT
        Id,
        Username,
        Alias,
        FirstName,
        LastName,
        SMC_Subsdiary_Label__c,
        UserType
      FROM User
      WHERE Email = :('Standard1-' + STA_UtilsStatic.USERNAME_TEST)
    ];

    System.runAs(stanadrdUser) {
      SMC_UTIL_MockHttpResponseGenerator fakeResponse = new SMC_UTIL_MockHttpResponseGenerator(
        500,
        STA_UtilsStatic.BAD_JSON,
        SMC_UTIL_ScoringMockJSONs.BAD_JSON,
        null
      );
      Test.setMock(HttpCalloutMock.class, fakeResponse);

      SMC_AP_ScoringCallout.ScoringWrapper wrapperReturn;
      Test.startTest();
      try{
        wrapperReturn = SMC_AP_ScoringCallout.upsertScoring(
          SMC_UTIL_ScoringMockJSONs.UPSERT_SCORING,
          STA_UtilsStatic.POST_METHOD,
          STA_UtilsStatic.END_POINT,
          SMC_UTIL_ScoringMockJSONs.DISCOUNT_TOKEN,
          null
        );
      }catch(Exception e){
        System.debug(e);
      }
      Test.stopTest();

      System.assertNotEquals(wrapperReturn.response.getStatusCode(), 200);
    }
  }

  /**
   * @description : test SMC_AP_ScoringCallout.upsertScoring(Update)
   * @author Vincent RECASENS (Modis) | 07-15-2020
   **/
  @isTest
  public static void testUpsertScoring_Update() {
    User stanadrdUser = [
      SELECT
        Id,
        Username,
        Alias,
        FirstName,
        LastName,
        SMC_Subsdiary_Label__c,
        UserType
      FROM User
      WHERE Email = :('Standard1-' + STA_UtilsStatic.USERNAME_TEST)
    ];

    System.runAs(stanadrdUser) {
      SMC_UTIL_MockHttpResponseGenerator fakeResponse = new SMC_UTIL_MockHttpResponseGenerator(
        200,
        STA_UtilsStatic.COMPLETE,
        SMC_UTIL_ScoringMockJSONs.PUT_SAVE_SUCCESS,
        null
      );
      Test.setMock(HttpCalloutMock.class, fakeResponse);

      SMC_AP_ScoringCallout.ScoringWrapper wrapperReturn;
      Test.startTest();
      wrapperReturn = SMC_AP_ScoringCallout.upsertScoring(
        SMC_UTIL_ScoringMockJSONs.UPSERT_SCORING,
        STA_UtilsStatic.PUT_METHOD,
        STA_UtilsStatic.END_POINT,
        SMC_UTIL_ScoringMockJSONs.DISCOUNT_TOKEN,
        null
      );
      Test.stopTest();

      System.assert(
        wrapperReturn.response.getStatusCode() == 200,
        'Mock is wrong. Check it.'
      );
    }
  }

  /**
   * @description : test SMC_AP_ScoringCallout.upsertScoring(Update)
   * @author Denis PHAM (Modis) | 01/06/2022
   **/
  @isTest
  public static void testUpsertScoring_Update_Fail() {
    User stanadrdUser = [
      SELECT
        Id,
        Username,
        Alias,
        FirstName,
        LastName,
        SMC_Subsdiary_Label__c,
        UserType
      FROM User
      WHERE Email = :('Standard1-' + STA_UtilsStatic.USERNAME_TEST)
    ];

    System.runAs(stanadrdUser) {
      SMC_UTIL_MockHttpResponseGenerator fakeResponse = new SMC_UTIL_MockHttpResponseGenerator(
        500,
        STA_UtilsStatic.BAD_JSON,
        SMC_UTIL_ScoringMockJSONs.BAD_JSON,
        null
      );
      Test.setMock(HttpCalloutMock.class, fakeResponse);

      SMC_AP_ScoringCallout.ScoringWrapper wrapperReturn;
      Test.startTest();
      try{
        wrapperReturn = SMC_AP_ScoringCallout.upsertScoring(
          SMC_UTIL_ScoringMockJSONs.UPSERT_SCORING,
          STA_UtilsStatic.PUT_METHOD,
          STA_UtilsStatic.END_POINT,
          SMC_UTIL_ScoringMockJSONs.DISCOUNT_TOKEN,
          null
        );
      } catch (Exception e){
        System.debug(e);
      }
      Test.stopTest();

      System.assertNotEquals(wrapperReturn.response.getStatusCode(), 200);
    }
  }

  /**
   * @description : test SMC_AP_ScoringCallout.getAllScoring()
   * @author Vincent RECASENS (Modis) | 07-15-2020
   **/
  @isTest
  public static void testGetAllScoring() {
    User stanadrdUser = [
      SELECT
        Id,
        Username,
        Alias,
        FirstName,
        LastName,
        SMC_Subsdiary_Label__c,
        UserType
      FROM User
      WHERE Email = :('Standard1-' + STA_UtilsStatic.USERNAME_TEST)
    ];

    System.runAs(stanadrdUser) {
      String body = '[{"account":"' + account.Id + '","baIds":[1]}]';
      SMC_UTIL_MockHttpResponseGenerator fakeResponse = new SMC_UTIL_MockHttpResponseGenerator(
        200,
        STA_UtilsStatic.COMPLETE,
        SMC_UTIL_ScoringMockJSONs.GET_ALL_SCORING_MOCK,
        null
      );
      Test.setMock(HttpCalloutMock.class, fakeResponse);
      Test.startTest();
      List<SMC_DTO_GetAllScoring> allScoring = new List<SMC_DTO_GetAllScoring>();
      allScoring = SMC_AP_ScoringCallout.getAllScoring(
        body,
        STA_UtilsStatic.END_POINT,
        SMC_UTIL_ScoringMockJSONs.DISCOUNT_TOKEN,
        null
      );
      Test.stopTest();

      System.assert(allScoring.size() > 0, 'Mock is wrong. Check it.');
    }
  }

   /**
   * @description : test SMC_AP_ScoringCallout.getAllScoring()
   * @author Denis PHAM (Modis) | 01/06/2022
   **/
  @isTest
  public static void testGetAllScoring_Fail() {
    User stanadrdUser = [
      SELECT
        Id,
        Username,
        Alias,
        FirstName,
        LastName,
        SMC_Subsdiary_Label__c,
        UserType
      FROM User
      WHERE Email = :('Standard1-' + STA_UtilsStatic.USERNAME_TEST)
    ];

    System.runAs(stanadrdUser) {
      String body = '[{"account":"' + account.Id + '","baIds":[1]}]';
      SMC_UTIL_MockHttpResponseGenerator fakeResponse = new SMC_UTIL_MockHttpResponseGenerator(
        500,
        STA_UtilsStatic.BAD_JSON,
        SMC_UTIL_ScoringMockJSONs.BAD_JSON,
        null
      );
      Test.setMock(HttpCalloutMock.class, fakeResponse);
      Test.startTest();
      List<SMC_DTO_GetAllScoring> allScoring = new List<SMC_DTO_GetAllScoring>();
      try{
        allScoring = SMC_AP_ScoringCallout.getAllScoring(
          body,
          STA_UtilsStatic.END_POINT,
          SMC_UTIL_ScoringMockJSONs.DISCOUNT_TOKEN,
          null
        );
      } catch (Exception e){
        System.debug(e);
      }

      Test.stopTest();

      System.assertEquals(null, allScoring);
    }
  }

  /**
  * @description : test SMC_AP_ScoringCallout.getScoring_v2()
  * @author Denis PHAM (Modis) | 01/06/2022
  **/
  @isTest
  public static void testGetScoring_v2() {
    User standardUser = [
      SELECT
        Id,
        Username,
        Alias,
        FirstName,
        LastName,
        SMC_Subsdiary_Label__c,
        UserType
      FROM User
      WHERE Email = :('Standard1-' + STA_UtilsStatic.USERNAME_TEST)
    ];

    System.runAs(standardUser) {
      
      String body = '{"sfdcAccountId":"' + account.Id + '",' + 
                      '"category":null,' +
                      '"business":null,' +
                      '"countryCode":null,' +
                      '"tier":null,' +
                      '"acc":"' + account.AccountNumber + '",' +
                      '"baIds":[1]}'; 
      SMC_UTIL_MockHttpResponseGenerator fakeResponse = new SMC_UTIL_MockHttpResponseGenerator(
        200,
        STA_UtilsStatic.COMPLETE,
        SMC_UTIL_ScoringMockJSONs.GET_SCORING_MOCK,
        null
      );
      Test.setMock(HttpCalloutMock.class, fakeResponse);
      Test.startTest();
      SMC_DTO_GetScoring allScoring = new SMC_DTO_GetScoring();
      allScoring = SMC_AP_ScoringCallout.getScoring_v2(
        body,
        STA_UtilsStatic.END_POINT,
        SMC_UTIL_ScoringMockJSONs.DISCOUNT_TOKEN,
        null
      );
      Test.stopTest();

      System.assert(allScoring.scoringLines.size() > 0, 'Mock is wrong. Check it.');
    }
  }

  /**
  * @description : test SMC_AP_ScoringCallout.getScoring_v2()
  * @author Denis PHAM (Modis) | 01/06/2022
  **/
  @isTest
  public static void testGetScoring_v2_Fail() {
    User standardUser = [
      SELECT
        Id,
        Username,
        Alias,
        FirstName,
        LastName,
        SMC_Subsdiary_Label__c,
        UserType
      FROM User
      WHERE Email = :('Standard1-' + STA_UtilsStatic.USERNAME_TEST)
    ];

    System.runAs(standardUser) {
      
      String body = '{"sfdcAccountId":"' + account.Id + '",' + 
                      '"category":null,' +
                      '"business":null,' +
                      '"countryCode":null,' +
                      '"tier":null,' +
                      '"acc":"' + account.AccountNumber + '",' +
                      '"baIds":[1]}'; 
      SMC_UTIL_MockHttpResponseGenerator fakeResponse = new SMC_UTIL_MockHttpResponseGenerator(
        500,
        STA_UtilsStatic.BAD_JSON,
        SMC_UTIL_ScoringMockJSONs.BAD_JSON,
        null
      );
      Test.setMock(HttpCalloutMock.class, fakeResponse);
      Test.startTest();
      SMC_DTO_GetScoring allScoring = new SMC_DTO_GetScoring();
        try{
          allScoring = SMC_AP_ScoringCallout.getScoring_v2(
            body,
            STA_UtilsStatic.END_POINT,
            SMC_UTIL_ScoringMockJSONs.DISCOUNT_TOKEN,
            null
          );           
        }catch(Exception e){
            System.debug(e);
            
        }

      Test.stopTest();

      System.assertEquals(null, allScoring.scoringLines);
    }
  }

  // /****GET DISCOUNT TOKEN****/
  // @isTest
  // public static void testGetDiscountTokenBadCode() {
  //   User stanadrdUser = [
  //     SELECT
  //       Id,
  //       Username,
  //       Alias,
  //       FirstName,
  //       LastName,
  //       SMC_Subsdiary_Label__c,
  //       UserType
  //     FROM User
  //     WHERE Email = :('Standard1-' + STA_UtilsStatic.USERNAME_TEST)
  //   ];

  //   System.runAs(stanadrdUser) {
  //     Call_Scoring_Domain__mdt tokenInformations = new Call_Scoring_Domain__mdt();
  //     tokenInformations.SecurityToken_Application__c = SMC_UTIL_ScoringMockJSONs.GET_DISCOUNT_TOKEN_APPLICATION;
  //     tokenInformations.SecurityToken_Secret__c = SMC_UTIL_ScoringMockJSONs.GET_DISCOUNT_TOKEN_SECRET;

  //     SMC_UTIL_MockHttpResponseGenerator fakeResponse = new SMC_UTIL_MockHttpResponseGenerator(
  //       500,
  //       STA_UtilsStatic.COMPLETE,
  //       SMC_UTIL_ScoringMockJSONs.DISCOUNT_TOKEN,
  //       null
  //     );
  //     Test.setMock(HttpCalloutMock.class, fakeResponse);

  //     Test.startTest();
  //     Boolean isInError = false;
  //     try {
  //       SMC_DTO_DiscountToken discountToken = SMC_AP_ScoringCallout.getDiscountToken(
  //         tokenInformations,
  //         'auth/',
  //         null
  //       );
  //     } catch (Exception e) {
  //       isInError = true;
  //     }
  //     Test.stopTest();

  //     System.assert(
  //       isInError,
  //       'The function does not identify the bad code returning.'
  //     );
  //   }
  // }

  // /****GET DISCOUNT TOKEN****/
  // @isTest
  // public static void testGetDiscountTokenBadJSON() {
  //   User stanadrdUser = [
  //     SELECT
  //       Id,
  //       Username,
  //       Alias,
  //       FirstName,
  //       LastName,
  //       SMC_Subsdiary_Label__c,
  //       UserType
  //     FROM User
  //     WHERE Email = :('Standard1-' + STA_UtilsStatic.USERNAME_TEST)
  //   ];

  //   System.runAs(stanadrdUser) {
  //     Call_Scoring_Domain__mdt tokenInformations = new Call_Scoring_Domain__mdt();
  //     tokenInformations.SecurityToken_Application__c = SMC_UTIL_ScoringMockJSONs.GET_DISCOUNT_TOKEN_APPLICATION;
  //     tokenInformations.SecurityToken_Secret__c = SMC_UTIL_ScoringMockJSONs.GET_DISCOUNT_TOKEN_SECRET;

  //     SMC_UTIL_MockHttpResponseGenerator fakeResponse = new SMC_UTIL_MockHttpResponseGenerator(
  //       200,
  //       STA_UtilsStatic.COMPLETE,
  //       STA_UtilsStatic.BAD_JSON,
  //       null
  //     );
  //     Test.setMock(HttpCalloutMock.class, fakeResponse);

  //     Test.startTest();
  //     Boolean isInError = false;
  //     try {
  //       SMC_DTO_DiscountToken discountToken = SMC_AP_ScoringCallout.getDiscountToken(
  //         tokenInformations,
  //         'auth/',
  //         null
  //       );
  //     } catch (Exception e) {
  //       isInError = true;
  //     }

  //     Test.stopTest();

  //     System.assert(
  //       isInError,
  //       'The function does not identify the bad JSON returning.'
  //     );
  //   }
  // }

  // /****ARE SCORED SCORING/DISCOUNT****/
  // @isTest
  // public static void testAreScoredBadCode() {
  //   User stanadrdUser = [
  //     SELECT
  //       Id,
  //       Username,
  //       Alias,
  //       FirstName,
  //       LastName,
  //       SMC_Subsdiary_Label__c,
  //       UserType
  //     FROM User
  //     WHERE Email = :('Standard1-' + STA_UtilsStatic.USERNAME_TEST)
  //   ];

  //   System.runAs(stanadrdUser) {
  //     SMC_UTIL_MockHttpResponseGenerator fakeResponse = new SMC_UTIL_MockHttpResponseGenerator(
  //       500,
  //       STA_UtilsStatic.COMPLETE,
  //       SMC_UTIL_ScoringMockJSONs.ARE_SCORED_BODY,
  //       null
  //     );
  //     Test.setMock(HttpCalloutMock.class, fakeResponse);

  //     Test.startTest();
  //     Boolean isInError = false;
  //     try {
  //       List<SMC_DTO_Scoring_AreScored> areScored = SMC_AP_ScoringCallout.areScoredScoring(
  //         SMC_UTIL_ScoringMockJSONs.ARE_SCORED,
  //         STA_UtilsStatic.END_POINT,
  //         SMC_UTIL_ScoringMockJSONs.DISCOUNT_TOKEN,
  //         null
  //       );
  //     } catch (Exception e) {
  //       isInError = true;
  //     }
  //     Test.stopTest();

  //     System.assert(
  //       isInError,
  //       'The function does not identify the bad code returning.'
  //     );
  //   }
  // }

  // /****ARE SCORED SCORING/DISCOUNT****/
  // @isTest
  // public static void testAreScoredBadJSON() {
  //   User stanadrdUser = [
  //     SELECT
  //       Id,
  //       Username,
  //       Alias,
  //       FirstName,
  //       LastName,
  //       SMC_Subsdiary_Label__c,
  //       UserType
  //     FROM User
  //     WHERE Email = :('Standard1-' + STA_UtilsStatic.USERNAME_TEST)
  //   ];

  //   System.runAs(stanadrdUser) {
  //     SMC_UTIL_MockHttpResponseGenerator fakeResponse = new SMC_UTIL_MockHttpResponseGenerator(
  //       200,
  //       STA_UtilsStatic.COMPLETE,
  //       STA_UtilsStatic.BAD_JSON,
  //       null
  //     );
  //     Test.setMock(HttpCalloutMock.class, fakeResponse);

  //     Test.startTest();
  //     Boolean isInError = false;
  //     try {
  //       List<SMC_DTO_Scoring_AreScored> areScored = SMC_AP_ScoringCallout.areScoredScoring(
  //         SMC_UTIL_ScoringMockJSONs.ARE_SCORED,
  //         STA_UtilsStatic.END_POINT,
  //         SMC_UTIL_ScoringMockJSONs.DISCOUNT_TOKEN,
  //         null
  //       );
  //     } catch (Exception e) {
  //       isInError = true;
  //     }
  //     Test.stopTest();

  //     System.assert(
  //       isInError,
  //       'The function does not identify the bad JSON returning.'
  //     );
  //   }
  // }

  // /****UPSERT SCORING/DISCOUNT****/
  // @isTest
  // public static void testUpsertScoring_InsertBadCode() {
  //   User stanadrdUser = [
  //     SELECT
  //       Id,
  //       Username,
  //       Alias,
  //       FirstName,
  //       LastName,
  //       SMC_Subsdiary_Label__c,
  //       UserType
  //     FROM User
  //     WHERE Email = :('Standard1-' + STA_UtilsStatic.USERNAME_TEST)
  //   ];

  //   System.runAs(stanadrdUser) {
  //     SMC_UTIL_MockHttpResponseGenerator fakeResponse = new SMC_UTIL_MockHttpResponseGenerator(
  //       500,
  //       STA_UtilsStatic.COMPLETE,
  //       SMC_UTIL_ScoringMockJSONs.PUT_SAVE_SUCCESS,
  //       null
  //     );
  //     Test.setMock(HttpCalloutMock.class, fakeResponse);

  //     SMC_AP_ScoringCallout.ScoringWrapper wrapperReturn;

  //     Test.startTest();
  //     Boolean isInError = false;
  //     try {
  //       wrapperReturn = SMC_AP_ScoringCallout.upsertScoring(
  //         SMC_UTIL_ScoringMockJSONs.UPSERT_SCORING,
  //         STA_UtilsStatic.POST_METHOD,
  //         STA_UtilsStatic.END_POINT,
  //         SMC_UTIL_ScoringMockJSONs.DISCOUNT_TOKEN,
  //         null
  //       );
  //     } catch (Exception e) {
  //       isInError = true;
  //     }
  //     Test.stopTest();

  //     System.assert(
  //       isInError,
  //       'The function does not identify the bad code returning.'
  //     );
  //   }
  // }

  // /****UPSERT SCORING/DISCOUNT****/
  // @isTest
  // public static void testUpsertScoring_InsertBadJSON() {
  //   User stanadrdUser = [
  //     SELECT
  //       Id,
  //       Username,
  //       Alias,
  //       FirstName,
  //       LastName,
  //       SMC_Subsdiary_Label__c,
  //       UserType
  //     FROM User
  //     WHERE Email = :('Standard1-' + STA_UtilsStatic.USERNAME_TEST)
  //   ];

  //   System.runAs(stanadrdUser) {
  //     SMC_UTIL_MockHttpResponseGenerator fakeResponse = new SMC_UTIL_MockHttpResponseGenerator(
  //       200,
  //       STA_UtilsStatic.COMPLETE,
  //       STA_UtilsStatic.BAD_JSON,
  //       null
  //     );
  //     Test.setMock(HttpCalloutMock.class, fakeResponse);

  //     SMC_AP_ScoringCallout.ScoringWrapper wrapperReturn;

  //     Test.startTest();
  //     Boolean isInError = false;
  //     try {
  //       wrapperReturn = SMC_AP_ScoringCallout.upsertScoring(
  //         SMC_UTIL_ScoringMockJSONs.UPSERT_SCORING,
  //         STA_UtilsStatic.POST_METHOD,
  //         STA_UtilsStatic.END_POINT,
  //         SMC_UTIL_ScoringMockJSONs.DISCOUNT_TOKEN,
  //         null
  //       );
  //     } catch (Exception e) {
  //       isInError = true;
  //     }
  //     Test.stopTest();

  //     System.assert(
  //       isInError,
  //       'The function does not identify the bad JSON returning.'
  //     );
  //   }
  // }

  // @isTest
  // public static void testUpsertScoring_UpdateBadCode() {
  //   User stanadrdUser = [
  //     SELECT
  //       Id,
  //       Username,
  //       Alias,
  //       FirstName,
  //       LastName,
  //       SMC_Subsdiary_Label__c,
  //       UserType
  //     FROM User
  //     WHERE Email = :('Standard1-' + STA_UtilsStatic.USERNAME_TEST)
  //   ];

  //   System.runAs(stanadrdUser) {
  //     SMC_UTIL_MockHttpResponseGenerator fakeResponse = new SMC_UTIL_MockHttpResponseGenerator(
  //       500,
  //       STA_UtilsStatic.COMPLETE,
  //       SMC_UTIL_ScoringMockJSONs.PUT_SAVE_SUCCESS,
  //       null
  //     );
  //     Test.setMock(HttpCalloutMock.class, fakeResponse);

  //     SMC_AP_ScoringCallout.ScoringWrapper wrapperReturn;

  //     Test.startTest();
  //     Boolean isInError = false;
  //     try {
  //       wrapperReturn = SMC_AP_ScoringCallout.upsertScoring(
  //         SMC_UTIL_ScoringMockJSONs.UPSERT_SCORING,
  //         STA_UtilsStatic.PUT_METHOD,
  //         STA_UtilsStatic.END_POINT,
  //         SMC_UTIL_ScoringMockJSONs.DISCOUNT_TOKEN,
  //         null
  //       );
  //     } catch (Exception e) {
  //       isInError = true;
  //     }
  //     Test.stopTest();

  //     System.assert(
  //       isInError,
  //       'The function does not identify the bad code returning.'
  //     );
  //   }
  // }

  // @isTest
  // public static void testUpsertScoring_UpdateBadJson() {
  //   User stanadrdUser = [
  //     SELECT
  //       Id,
  //       Username,
  //       Alias,
  //       FirstName,
  //       LastName,
  //       SMC_Subsdiary_Label__c,
  //       UserType
  //     FROM User
  //     WHERE Email = :('Standard1-' + STA_UtilsStatic.USERNAME_TEST)
  //   ];

  //   System.runAs(stanadrdUser) {
  //     SMC_UTIL_MockHttpResponseGenerator fakeResponse = new SMC_UTIL_MockHttpResponseGenerator(
  //       200,
  //       STA_UtilsStatic.COMPLETE,
  //       STA_UtilsStatic.BAD_JSON,
  //       null
  //     );
  //     Test.setMock(HttpCalloutMock.class, fakeResponse);

  //     SMC_AP_ScoringCallout.ScoringWrapper wrapperReturn;

  //     Test.startTest();
  //     Boolean isInError = false;
  //     try {
  //       wrapperReturn = SMC_AP_ScoringCallout.upsertScoring(
  //         SMC_UTIL_ScoringMockJSONs.UPSERT_SCORING,
  //         STA_UtilsStatic.PUT_METHOD,
  //         STA_UtilsStatic.END_POINT,
  //         SMC_UTIL_ScoringMockJSONs.DISCOUNT_TOKEN,
  //         null
  //       );
  //     } catch (Exception e) {
  //       isInError = true;
  //     }
  //     Test.stopTest();

  //     System.assert(
  //       isInError,
  //       'The function does not identify the bad JSON returning.'
  //     );
  //   }
  // }

  // /****GET ALL SCORING/DISCOUNT****/
  // @isTest
  // public static void testGetAllScoringBadCode() {
  //   User stanadrdUser = [
  //     SELECT
  //       Id,
  //       Username,
  //       Alias,
  //       FirstName,
  //       LastName,
  //       SMC_Subsdiary_Label__c,
  //       UserType
  //     FROM User
  //     WHERE Email = :('Standard1-' + STA_UtilsStatic.USERNAME_TEST)
  //   ];

  //   System.runAs(stanadrdUser) {
  //     String body = '[{"account":"' + account.Id + '","baIds":[1]}]';
  //     SMC_UTIL_MockHttpResponseGenerator fakeResponse = new SMC_UTIL_MockHttpResponseGenerator(
  //       500,
  //       STA_UtilsStatic.COMPLETE,
  //       SMC_UTIL_ScoringMockJSONs.GET_ALL_SCORING_MOCK,
  //       null
  //     );
  //     Test.setMock(HttpCalloutMock.class, fakeResponse);

  //     Test.startTest();
  //     Boolean isInError = false;
  //     try {
  //       List<SMC_DTO_GetAllScoring> allScoring = new List<SMC_DTO_GetAllScoring>();
  //       allScoring = SMC_AP_ScoringCallout.getAllScoring(
  //         body,
  //         STA_UtilsStatic.END_POINT,
  //         SMC_UTIL_ScoringMockJSONs.DISCOUNT_TOKEN,
  //         null
  //       );
  //     } catch (Exception e) {
  //       isInError = true;
  //     }
  //     Test.stopTest();

  //     System.assert(
  //       isInError,
  //       'The function does not identify the bad code returning.'
  //     );
  //   }
  // }

  // /****GET ALL SCORING/DISCOUNT****/
  // @isTest
  // public static void testGetAllScoringBadJSON() {
  //   User stanadrdUser = [
  //     SELECT
  //       Id,
  //       Username,
  //       Alias,
  //       FirstName,
  //       LastName,
  //       SMC_Subsdiary_Label__c,
  //       UserType
  //     FROM User
  //     WHERE Email = :('Standard1-' + STA_UtilsStatic.USERNAME_TEST)
  //   ];

  //   System.runAs(stanadrdUser) {
  //     String body = '[{"account":"' + account.Id + '","baIds":[1]}]';
  //     SMC_UTIL_MockHttpResponseGenerator fakeResponse = new SMC_UTIL_MockHttpResponseGenerator(
  //       200,
  //       STA_UtilsStatic.COMPLETE,
  //       STA_UtilsStatic.BAD_JSON,
  //       null
  //     );
  //     Test.setMock(HttpCalloutMock.class, fakeResponse);

  //     Test.startTest();
  //     Boolean isInError = false;
  //     try {
  //       List<SMC_DTO_GetAllScoring> allScoring = new List<SMC_DTO_GetAllScoring>();
  //       allScoring = SMC_AP_ScoringCallout.getAllScoring(
  //         body,
  //         STA_UtilsStatic.END_POINT,
  //         SMC_UTIL_ScoringMockJSONs.DISCOUNT_TOKEN,
  //         null
  //       );
  //     } catch (Exception e) {
  //       isInError = true;
  //     }
  //     Test.stopTest();

  //     System.assert(
  //       isInError,
  //       'The function does not identify the bad JSON returning.'
  //     );
  //   }
  // }

  // /****SAVE SCORING/DISCOUNT****/
  // @isTest
  // public static void testSaveScoringBadCode() {
  //   User stanadrdUser = [
  //     SELECT
  //       Id,
  //       Username,
  //       Alias,
  //       FirstName,
  //       LastName,
  //       SMC_Subsdiary_Label__c,
  //       UserType
  //     FROM User
  //     WHERE Email = :('Standard1-' + STA_UtilsStatic.USERNAME_TEST)
  //   ];

  //   System.runAs(stanadrdUser) {
  //     SMC_UTIL_MockHttpResponseGenerator fakeResponse = new SMC_UTIL_MockHttpResponseGenerator(
  //       500,
  //       STA_UtilsStatic.COMPLETE,
  //       SMC_UTIL_ScoringMockJSONs.PUT_SAVE_SUCCESS,
  //       null
  //     );
  //     Test.setMock(HttpCalloutMock.class, fakeResponse);

  //     Test.startTest();
  //     Boolean isInError = false;
  //     try {
  //       Boolean saveScoring = SMC_AP_ScoringCallout.saveScoring(
  //         SMC_UTIL_ScoringMockJSONs.PUT_SAVE_BODY,
  //         STA_UtilsStatic.END_POINT,
  //         SMC_UTIL_ScoringMockJSONs.DISCOUNT_TOKEN,
  //         null
  //       );
  //     } catch (Exception e) {
  //       isInError = true;
  //     }
  //     Test.stopTest();

  //     System.assert(
  //       isInError,
  //       'The function does not identify the bad code returning.'
  //     );
  //   }
  // }

  // /****SAVE SCORING/DISCOUNT****/
  // @isTest
  // public static void testSaveScoringBadJSON() {
  //   User stanadrdUser = [
  //     SELECT
  //       Id,
  //       Username,
  //       Alias,
  //       FirstName,
  //       LastName,
  //       SMC_Subsdiary_Label__c,
  //       UserType
  //     FROM User
  //     WHERE Email = :('Standard1-' + STA_UtilsStatic.USERNAME_TEST)
  //   ];

  //   System.runAs(stanadrdUser) {
  //     SMC_UTIL_MockHttpResponseGenerator fakeResponse = new SMC_UTIL_MockHttpResponseGenerator(
  //       200,
  //       STA_UtilsStatic.COMPLETE,
  //       STA_UtilsStatic.BAD_JSON,
  //       null
  //     );
  //     Test.setMock(HttpCalloutMock.class, fakeResponse);

  //     Test.startTest();
  //     System.assert(
  //       SMC_AP_ScoringCallout.saveScoring(
  //         SMC_UTIL_ScoringMockJSONs.PUT_SAVE_BODY,
  //         STA_UtilsStatic.END_POINT,
  //         SMC_UTIL_ScoringMockJSONs.DISCOUNT_TOKEN,
  //         null
  //       ),
  //       'Mock is wrong. Check it.'
  //     );
  //     Boolean isInError = false;
  //     try {
  //       SMC_AP_ScoringCallout.saveScoring(
  //         SMC_UTIL_ScoringMockJSONs.PUT_SAVE_BODY,
  //         STA_UtilsStatic.END_POINT,
  //         SMC_UTIL_ScoringMockJSONs.DISCOUNT_TOKEN,
  //         null
  //       );
  //     } catch (Exception e) {
  //       isInError = true;
  //     }
  //     Test.stopTest();

  //     System.assert(
  //       isInError,
  //       'The function does not identify the bad JSON returning.'
  //     );
  //   }
  // }
}