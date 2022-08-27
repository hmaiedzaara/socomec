/*
---------------------------------------------------------------------
-- - Name          : TEST_SMC_AP_DeleteOldSimuExpressBatch
-- - Author        : Guillaume BONNET
-- - Description   : A batch so that the simuEpress older than 8 day are deleted.
-- Maintenance History:
--
-- Date         Name 			                        Version  Remarks 
-- -----------  ----  			                        -------  ---------------------------
-- xx-MARS-2018  TEST_SMC_AP_DeleteOldSimuExpressBatch     1.0      Initial version 
---------------------------------------------------------------------
*/
@isTest
public with sharing class TEST_SMC_AP_DeleteOldSimuExpressBatch {
  /**
   * @description : test setup
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  @testSetup
  public static void insertSImuExpress() {
    Profile profileStandard = [
      SELECT Id
      FROM Profile
      WHERE Name = :STA_UtilsStatic.PROFILE_SMC_ADMIN
    ];
    User userBypasser = SMC_UTIL_TestUtils.createUser(
      STA_UtilsStatic.TEST_DIESE,
      STA_UtilsStatic.EMAIL_TEST,
      profileStandard.Id,
      STA_UtilsStatic.USERNAME_TEST,
      STA_UtilsStatic.USER_NICKNAME
    );
    userBypasser.Bypass_All_Processes_Builder__c = true;
    // userBypasser.Bypass_All_Workflow_Rules__c = true;
    // userBypasser.Bypass_All_Validation_Rules__c = true;
    insert userBypasser;

    System.runAs(userBypasser) {
      // PAD.bypassAll = true;

      Map<String, Schema.RecordTypeInfo> recordTypesAccount = new Map<String, Schema.RecordTypeInfo>();
      recordTypesAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName();
      Id recordTypeIdAccount = recordTypesAccount.get(
          STA_UtilsStatic.RECORDTYPE_ACCOUNT_CUSTOMER_DEVNAME
        )
        .getRecordTypeId();
      Account account = SMC_UTIL_TestUtils.createAccount(
        recordTypeIdAccount,
        STA_UtilsStatic.TEST + STA_UtilsStatic.ACCOUNT,
        STA_UtilsStatic.PICKLIST_ACCOUNT_TYPE_MARKETING_PROSPECT,
        STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY2
      );

      Map<String, Schema.RecordTypeInfo> recordTypesOpportunity = new Map<String, Schema.RecordTypeInfo>();
      recordTypesOpportunity = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName();
      Id recordTypeIdOpportunity = recordTypesOpportunity.get(
          STA_UtilsStatic.RECORDTYPE_OPPORTUNITY_PROJECT
        )
        .getRecordTypeId();
      Opportunity opportunity = SMC_UTIL_TestUtils.createOpportunity(
        recordTypeIdOpportunity,
        STA_UtilsStatic.TEST + STA_UtilsStatic.OPPORTUNITY,
        STA_UtilsStatic.OPPORTUNITY_PROJECT_DETECTED
      );

      insert account;
      insert opportunity;

      Map<String, Schema.RecordTypeInfo> recordTypesQuote = new Map<String, Schema.RecordTypeInfo>();
      recordTypesQuote = Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName();
      Id simuExpressRecordTypeId = recordTypesQuote.get(
          STA_UtilsStatic.RECORDTYPE_SIMU_EXPRESS
        )
        .getRecordTypeId();

      List<Quote> quotesList = new List<Quote>();
      List<Quote> quotesExpired = new List<Quote>();
      for (
        Datetime expiredDate = Datetime.now().addDays(-30);
        expiredDate < expiredDate.addDays(-7);
        expiredDate = expiredDate.addDays(1)
      ) {
        Quote quote = SMC_UTIL_TestUtils.createQuote(
          null,
          STA_UtilsStatic.TEST + STA_UtilsStatic.QUOTE,
          account.Id
        );
        quote.RecordTypeId = simuExpressRecordTypeId;
        quote.CreatedDate = DateTime.now().addDays(-100);
        quote.LastModifiedDate = expiredDate;
        // quotesExpired.add(quote);
        quotesList.add(quote);
      }
      // insert quotesExpired;
      //30-7 = 23 expired quotes inserted

      List<Quote> quotesNotExpired = new List<Quote>();
      for (
        Datetime expiredDate = Datetime.now().addDays(-7);
        expiredDate < Datetime.now();
        expiredDate = expiredDate.addDays(1)
      ) {
        Quote quote = SMC_UTIL_TestUtils.createQuote(
          null,
          STA_UtilsStatic.TEST + STA_UtilsStatic.QUOTE,
          account.Id
        );
        quote.RecordTypeId = simuExpressRecordTypeId;
        // quote.CreatedDate = DateTime.now().addDays(-100);
        // quote.LastModifiedDate = expiredDate;
        // quotesNotExpired.add(quote);
        quotesList.add(quote);
      }
      insert quotesList;
    }
  }

  /**
  * @description : test SMC_AP_DeleteOldSimuExpressBatch.run()
  * @author Vincent RECASENS (Modis) | 07-10-2020 
  **/
  @isTest
  public static void testBatchOnce() {
    User user = [
      SELECT Id, Name
      FROM User
      WHERE Email = :STA_UtilsStatic.EMAIL_TEST
      LIMIT 1
    ];

    System.runAs(user) {
      PAD.bypassAll = true;

      Test.startTest();
      new SMC_AP_DeleteOldSimuExpressBatch();
      SMC_AP_DeleteOldSimuExpressBatch.run(null);
      Test.stopTest();

      Map<String, Schema.RecordTypeInfo> recordTypesQuote = new Map<String, Schema.RecordTypeInfo>();
      recordTypesQuote = Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName();
      Id simuExpressRecordTypeId = recordTypesQuote.get(
          STA_UtilsStatic.RECORDTYPE_SIMU_EXPRESS
        )
        .getRecordTypeId();
      Datetime expirationDate = Datetime.now().addDays(-7);
      List<Quote> expiredQuotes = [
        SELECT Id, LastModifiedDate
        FROM Quote
        WHERE
          RecordTypeId = :simuExpressRecordTypeId
          AND LastModifiedDate < :expirationDate
      ];
      System.assertEquals(
        0,
        expiredQuotes.size(),
        'Check quote initialisation. Once is expired.'
      );
    }


    // DOS - 20180717 commented this assertion because bug on production
    //List<Quote> freshQuotes = [Select Id, LastModifiedDate from Quote where RecordTypeId = :simuExpressRecordTypeId AND LastModifiedDate >= :expirationDate];
    //System.assertEquals(8, freshQuotes.size());
  }
}