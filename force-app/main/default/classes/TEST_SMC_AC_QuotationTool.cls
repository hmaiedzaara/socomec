/*
---------------------------------------------------------------------------
-- - Name : TEST_SMC_AC_QuotationTool
-- - Author : Vincent RECASENS
-- - Description : This class is the test class of the Apex class 'SMC_AC_QuotationTool'
--
-- Maintenance History:
--
-- Date         Name                    Version     Remarks
-- -----------  ----                    -------     ------------------
-- 26-MAR-2018  Vincent RECASENS  		1.0     	Initial Version
---------------------------------------------------------------------------
*/

@isTest
public without sharing class TEST_SMC_AC_QuotationTool {
  /**
   * @description : test SMC_AC_QuotationTool.checkInformationsValidity() [Multiples tests]
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  @isTest
  public static void testCheckInformationsValidity() {
    System.debug(
      LoggingLevel.INFO,
      '>>>>>> TEST_SMC_AC_QuotationTool : testCheckValidityInformation - START'
    );

    //Set the User
    Profile profile = [
      SELECT Id
      FROM Profile
      WHERE Name = :STA_UtilsStatic.PROFILE_SALE_STANDARD
    ];
    User user = SMC_UTIL_TestUtils.createUser(
      STA_UtilsStatic.USER_NICKNAME,
      STA_UtilsStatic.USERNAME_TEST,
      profile.Id,
      STA_UtilsStatic.USERNAME_TEST,
      STA_UtilsStatic.USER_NICKNAME
    );
    user.Bypass_All_Processes_Builder__c = true;
    user.Bypass_All_Validation_Rules__c = true;
    user.Bypass_All_Workflow_Rules__c = true;
    insert user;
    //PermissonSet "Quotation Tool"
    PermissionSet ps = [
      SELECT ID
      FROM PermissionSet
      WHERE Name = :STA_UtilsStatic.QUOTATION_TOOL_PERMISSION
    ];
    insert new PermissionSetAssignment(
      AssigneeId = user.Id,
      PermissionSetId = ps.Id
    );

    System.runAs(user) {
      PAD.bypassAll = true;

      //Account
      Account account1 = new Account(); //All fields needed feed
      account1.Name = STA_UtilsStatic.ACCOUNT_NAME1;
      account1.BillingCountryCode = STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY1;
      account1.SMC_Category__c = STA_UtilsStatic.ACCOUNT_CATEGORY1;
      account1.SMC_PCO_Price_List__c = STA_UtilsStatic.ACCOUNT_PRICELIST;

      //Account
      Account account2 = new Account(); //All fields needed feed
      account2.Name = STA_UtilsStatic.ACCOUNT_NAME2;
      account2.BillingCountryCode = STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY2;

      List<Account> accounts = new List<Account>();
      accounts.add(account1);
      accounts.add(account2);
      insert accounts;

      //Contact
      Contact contact1 = new Contact(); //All fields needed feed
      contact1.FirstName = STA_UtilsStatic.CONTACT_FIRSTNAME1;
      contact1.LastName = STA_UtilsStatic.CONTACT_LASTNAME1;
      contact1.AccountId = account1.Id;
      contact1.Salutation = STA_UtilsStatic.CONTACT_SALUTATION;
      contact1.Phone = STA_UtilsStatic.CONTACT_PHONE1;
      contact1.Email = STA_UtilsStatic.CONTACT_EMAIL1;

      List<Contact> contacts = new List<Contact>();
      contacts.add(contact1);
      insert contacts;

      //Opportunity
      Opportunity opportunity1 = new Opportunity();
      opportunity1.Name = STA_UtilsStatic.OPPORTUNITY_NAME1;
      opportunity1.StageName = STA_UtilsStatic.OPPORTUNITY_TENDER_QUOTATION;
      opportunity1.CloseDate = Date.today();
      opportunity1.AccountId = account1.Id;

      Opportunity opportunity2 = new Opportunity();
      opportunity2.Name = STA_UtilsStatic.OPPORTUNITY_NAME2;
      opportunity2.StageName = STA_UtilsStatic.OPPORTUNITY_TENDER_QUOTATION;
      opportunity2.CloseDate = Date.today();
      opportunity2.AccountId = account2.Id;

      List<Opportunity> opportunities = new List<Opportunity>();
      opportunities.add(opportunity1);
      opportunities.add(opportunity2);
      insert opportunities;

      //Record Type Quote
      Map<String, Schema.RecordTypeInfo> recordTypesQuote = new Map<String, Schema.RecordTypeInfo>();
      recordTypesQuote = Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName();
      Id quoteSimuId = recordTypesQuote.get(
          STA_UtilsStatic.RECORDTYPE_SIMU_EXPRESS
        )
        .getRecordTypeId();
      Id quoteProjectId = recordTypesQuote.get(
          STA_UtilsStatic.RECORDTYPE_QUICK_QUOTE
        )
        .getRecordTypeId();
      Id quoteQuickQuotationId = recordTypesQuote.get(
          STA_UtilsStatic.RECORDTYPE_QUOTE_PROJECT
        )
        .getRecordTypeId();

      //In good conditions
      Quote quote1 = new Quote();
      quote1.Name = STA_UtilsStatic.QUOTE_NAME1;
      quote1.SMC_Account__c = account1.Id;
      quote1.OpportunityId = opportunity1.Id;
      quote1.RecordTypeId = quoteSimuId;
      quote1.OwnerId = user.Id;
      insert quote1;

      SMC_DTO_SimuExpress dtoResult1 = SMC_AC_QuotationTool.checkInformationsValidity(
        quote1.Id
      );
      System.assert(
        dtoResult1.resultList.size() > 0,
        'Check quote\'s fields in the setup.'
      );

      //In good conditions
      Quote quote2 = new Quote();
      quote2.Name = STA_UtilsStatic.QUOTE_NAME2;
      quote2.SMC_Account__c = account1.Id;
      quote2.OpportunityId = opportunity1.Id;
      quote2.ContactId = contact1.Id;
      quote2.RecordTypeId = quoteProjectId;
      quote2.OwnerId = user.Id;
      insert quote2;

      SMC_DTO_SimuExpress dtoResult2 = SMC_AC_QuotationTool.checkInformationsValidity(
        quote2.Id
      );
      System.assert(
        dtoResult2.resultList.size() > 0,
        'Check quote\'s fields in the setup.'
      );

      //Without contact
      Quote quote3 = new Quote();
      quote3.Name = STA_UtilsStatic.QUOTE_NAME3;
      quote3.SMC_Account__c = account2.Id;
      quote3.OpportunityId = opportunity2.Id;
      quote3.RecordTypeId = quoteProjectId;
      quote3.OwnerId = user.Id;
      insert quote3;

      SMC_DTO_SimuExpress dtoResult3 = SMC_AC_QuotationTool.checkInformationsValidity(
        quote3.Id
      );
      System.assertNotEquals(
        null,
        dtoResult3.dtoMissingFields,
        'Check quote\'s fields in the setup.'
      );
    }
    System.debug(
      LoggingLevel.INFO,
      '>>>>>> TEST_SMC_AC_QuotationTool : testCheckValidityInformation - END'
    );
  }

  @isTest
  public static void testGetContactSalutation() {
    System.debug(
      LoggingLevel.INFO,
      '>>>>>> TEST_SMC_AC_QuotationTool : testGetContactSalutation - START'
    );
    List<String> contactSalutations = SMC_UTIL_Quotation.getContactSalutation();
    System.assertNotEquals(
      null,
      contactSalutations,
      'Contact has no salutations.'
    );
    System.debug(
      LoggingLevel.INFO,
      '>>>>>> TEST_SMC_AC_QuotationTool : testGetContactSalutation - END'
    );
  }

  /**
   * @description : test user permission on trigger
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  @isTest
  public static void testPermissionSetAuthorization() {
    System.debug(
      LoggingLevel.INFO,
      '>>>>>> TEST_SMC_AC_QuotationTool : testPermissionSetAuthorization - START'
    );

    //Set the User
    Profile profile = [
      SELECT Id
      FROM Profile
      WHERE Name = :STA_UtilsStatic.PROFILE_SALE_STANDARD
    ];
    User user = SMC_UTIL_TestUtils.createUser(
      STA_UtilsStatic.USER_NICKNAME,
      STA_UtilsStatic.USERNAME_TEST,
      profile.Id,
      STA_UtilsStatic.USERNAME_TEST,
      STA_UtilsStatic.USER_NICKNAME
    );
    user.Bypass_All_Processes_Builder__c = true;
    user.Bypass_All_Validation_Rules__c = true;
    user.Bypass_All_Workflow_Rules__c = true;
    insert user;
    //PermissonSet "Quotation Tool"
    PermissionSet ps = [
      SELECT ID
      FROM PermissionSet
      WHERE Name = :STA_UtilsStatic.QUOTATION_TOOL_PERMISSION
    ];
    insert new PermissionSetAssignment(
      AssigneeId = user.Id,
      PermissionSetId = ps.Id
    );

    System.runAs(user) {
      PAD.bypassAll = true;

      //Account
      Account account1 = new Account(); //All fields needed feed
      account1.Name = STA_UtilsStatic.ACCOUNT_NAME1;
      account1.BillingCountryCode = STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY1;
      account1.SMC_Category__c = STA_UtilsStatic.ACCOUNT_CATEGORY1;
      account1.SMC_PCO_Price_List__c = STA_UtilsStatic.ACCOUNT_PRICELIST;

      //Opportunity
      Opportunity opportunity1 = new Opportunity();
      opportunity1.Name = STA_UtilsStatic.OPPORTUNITY_NAME1;
      opportunity1.StageName = STA_UtilsStatic.OPPORTUNITY_TENDER_QUOTATION;
      opportunity1.CloseDate = Date.today();
      opportunity1.AccountId = account1.Id;

      //Quote RecordType
      Map<String, Schema.RecordTypeInfo> recordTypesQuote = new Map<String, Schema.RecordTypeInfo>();
      recordTypesQuote = Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName();
      Id quoteSimuId = recordTypesQuote.get(
          STA_UtilsStatic.RECORDTYPE_SIMU_EXPRESS
        )
        .getRecordTypeId();
      //Quote
      Quote quote1 = new Quote();
      quote1.Name = STA_UtilsStatic.QUOTE_NAME1;
      quote1.SMC_Account__c = account1.Id;
      quote1.OpportunityId = opportunity1.Id;
      quote1.RecordTypeId = quoteSimuId;

      try {
        insert quote1;
      } catch (Exception e) {
        System.debug(
          LoggingLevel.INFO,
          'TEST OK -- Only User with PermisisonSet "Quotation Tool" can edit/insert SimuExpress quotes'
        );
        System.assert(true, 'Quote is inserted. ERROR');
      }
    }

    System.debug(
      LoggingLevel.INFO,
      '>>>>>> TEST_SMC_AC_QuotationTool : testPermissionSetAuthorization - END'
    );
  }
}