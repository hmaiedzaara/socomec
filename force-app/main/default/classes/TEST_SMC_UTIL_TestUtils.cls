/*
---------------------------------------------------------------------
-- - Name          : TEST_SMC_UTIL_TestUtils
-- - Author        : Xavier BRANCHE
-- - Description   : Test the TestUtils class               
-- Maintenance History:
--
-- Date         Name 			          Version  Remarks 
-- -----------  ----  			        -------  ---------------------------
-- 31-MAI-2017  ??????????????       1.0      Initial version 
-- 24-AVR-2018  Guillaume Bonnet     1.0      Added bypass to insert Account
-- 24-AVR-2018  Vincent RECASENS     1.0      Added bypass
---------------------------------------------------------------------
*/
@IsTest
public without sharing class TEST_SMC_UTIL_TestUtils {
  // @testSetup
  // public static void setup(){
  //     Profile profileSupport = [SELECT Id FROM Profile WHERE Name = :STA_UtilsStatic.PROFILE_SMC_STANDARD_SUPPORT];
  //     User userSupport = SMC_UTIL_TestUtils.createUser('support-' + STA_UtilsStatic.USER_NICKNAME, 'support-' + STA_UtilsStatic.USERNAME_TEST, profileSupport.Id, 'support-' + STA_UtilsStatic.USERNAME_TEST, 'support-' + STA_UtilsStatic.USER_NICKNAME);
  //     userSupport.UserRoleId = [SELECT Id FROM UserRole WHERE DeveloperName = :STA_UtilsStatic.ROLE_SUPPORT_DEVNAME].Id; //Support
  //     insert userSupport;

  //     System.runAs(userSupport){

  //         //Queue
  //         Group franceOSL = [SELECT Id, Name, Type FROM Group WHERE Type = :STA_UtilsStatic.QUEUE AND Name = :STA_UtilsStatic.ACCOUNT_QUEUE_FRANCE_OSL];
  //         Group franceTOS = [SELECT Id, Name, Type FROM Group WHERE Type = :STA_UtilsStatic.QUEUE AND Name = :STA_UtilsStatic.ACCOUNT_QUEUE_FRANCE_TOS];
  //         Id recordTypeIdAccount = [Select Id from RecordType where name =: STA_UtilsStatic.RECORDTYPE_ACCOUNT_CASE_TEAM].Id;
  //         Account accountQueue = SMC_UTIL_TestUtils.createAccount(recordTypeIdAccount, STA_UtilsStatic.ACCOUNT + '_GroupQueue',STA_UtilsStatic.PICKLIST_ACCOUNT_TYPE_MARKETING_PROSPECT,STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY1);
  //         accountQueue.SMC_Queue_ID__c = franceOSL.Id;
  //         accountQueue.OwnerId = userAdmin1.Id;
  //         Account accountQueueToTransfer = SMC_UTIL_TestUtils.createAccount(recordTypeIdAccount, STA_UtilsStatic.ACCOUNT + '_GroupQueueToTransfer',STA_UtilsStatic.PICKLIST_ACCOUNT_TYPE_MARKETING_PROSPECT,STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY1);
  //         accountQueueToTransfer.SMC_Queue_ID__c = franceTOS.Id;
  //         accountQueueToTransfer.OwnerId = userAdmin2.Id;
  //         insert new List<Account>{accountQueue, accountQueueToTransfer};
  //     }
  // }

  // This method tests the createTestUser method
  @IsTest
  public static void createTestUserTest() {
    User user = SMC_UTIL_TestUtils.createTestUser(
      STA_UtilsStatic.PROFILE_SALE_STANDARD
    );
    insert user;

    User usertoCompare = [
      SELECT
        LastName,
        Email,
        ProfileId,
        Username,
        CommunityNickname,
        Alias,
        TimeZoneSidKey,
        LocaleSidKey,
        EmailEncodingKey,
        LanguageLocaleKey
      FROM User
      WHERE Lastname = :STA_UtilsStatic.USER_NICKNAME
    ];
    System.assertEquals(
      usertoCompare.LastName,
      user.LastName,
      'Missing reuqired field.'
    );
  }

  // This method tests the createUser method
  @IsTest
  public static void createUserTest() {
    Id profileId = [
        SELECT Id
        FROM Profile
        WHERE Name = :STA_UtilsStatic.PROFILE_SALE_STANDARD
        LIMIT 1
      ]
      .get(0)
      .Id;
    User user = SMC_UTIL_TestUtils.createUser(
      STA_UtilsStatic.USER_NICKNAME,
      STA_UtilsStatic.USERNAME_TEST,
      profileId,
      STA_UtilsStatic.USERNAME_TEST,
      STA_UtilsStatic.USER_NICKNAME
    );
    insert user;
    // User user = SMC_UTIL_TestUtils.createUser('lastName', 'email@email.fr', profileId, 'username@email.fr', 'communityNickname');
    // insert user;
    User usertoCompare = [
      SELECT
        LastName,
        Email,
        ProfileId,
        Username,
        CommunityNickname,
        Alias,
        TimeZoneSidKey,
        LocaleSidKey,
        EmailEncodingKey,
        LanguageLocaleKey
      FROM User
      WHERE Lastname = :STA_UtilsStatic.USER_NICKNAME
    ];
    System.assertEquals(
      usertoCompare.LastName,
      user.LastName,
      'Missing reuqired field.'
    );
  }

  // This method tests the createAccount method
  @IsTest
  public static void createAccountTest() {
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
      STA_UtilsStatic.CUSTOMER,
      STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY2
    );
    PAD.bypassAll = true;
    insert account;
    PAD.bypassAll = false;
    Account accountToCompare = [
      SELECT Name, RecordTypeId, Type, BillingCountry
      FROM Account
    ];
    System.assertEquals(account, accountToCompare, 'Missing reuqired field.');
  }

  // This method tests the createAccount method
  @IsTest
  public static void createAccountTestExtended() {
    Id profileStandardId = [
        SELECT Id
        FROM Profile
        WHERE Name = :STA_UtilsStatic.PROFILE_SALE_STANDARD
        LIMIT 1
      ]
      .get(0)
      .Id;
    Id recordTypeId = [
        SELECT Id
        FROM RecordType
        WHERE name = :STA_UtilsStatic.RECORDTYPE_ACCOUNT_CUSTOMER
        LIMIT 1
      ]
      .get(0)
      .Id;
    User user1 = SMC_UTIL_TestUtils.createUser(
      STA_UtilsStatic.TEST_DIESE,
      STA_UtilsStatic.EMAIL_TEST,
      profileStandardId,
      STA_UtilsStatic.USERNAME_TEST,
      STA_UtilsStatic.USER_NICKNAME
    );
    insert user1;
    Id userId1 = user1.Id;
    Account account = SMC_UTIL_TestUtils.createAccount(
      recordTypeId,
      STA_UtilsStatic.ACCOUNT_NAME1,
      STA_UtilsStatic.CUSTOMER,
      STA_UtilsStatic.ACCOUNT_BILLINGSTREET2,
      STA_UtilsStatic.ACCOUNT_BILLINGPOSTALCODE2,
      STA_UtilsStatic.ACCOUNT_BILLINGCITY2,
      STA_UtilsStatic.ACCOUNT_BILLINGSTATE2,
      STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY2,
      userId1,
      userId1,
      userId1,
      userId1,
      userId1
    );
    PAD.bypassAll = true;
    insert account;
    PAD.bypassAll = false;
    Account accountToCompare = [SELECT Name, RecordTypeId, Type FROM Account];
    System.assertEquals(
      account.Name,
      accountToCompare.Name,
      'Missing reuqired field.'
    );
  }

  /**
  * @description : test SMC_UTIL_TestUtils.createAccountActors()
  * @author Vincent RECASENS (Modis) | 07-15-2020 
  **/
  @isTest
  public static void createAccountActorsTest() {
    Id recordTypeId = [
        SELECT Id
        FROM RecordType
        WHERE name = :STA_UtilsStatic.RECORDTYPE_ACCOUNT_CUSTOMER
        LIMIT 1
      ]
      .get(0)
      .Id;
    Account account1 = SMC_UTIL_TestUtils.createAccount(
      recordTypeId,
      STA_UtilsStatic.TEST + '1',
      STA_UtilsStatic.PICKLIST_ACCOUNT_TYPE_MARKETING_PROSPECT,
      STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY1
    );
    account1.SMC_Category__c = STA_UtilsStatic.ACCOUNT_CATEGORY1;
    Account account2 = SMC_UTIL_TestUtils.createAccount(
      recordTypeId,
      STA_UtilsStatic.TEST + '2',
      STA_UtilsStatic.PICKLIST_ACCOUNT_TYPE_MARKETING_PROSPECT,
      STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY2
    );
    account2.SMC_Category__c = STA_UtilsStatic.ACCOUNT_CATEGORY2;
    insert new List<Account>{ account1, account2 };

    SMC_Account_Actors__c accountActors = SMC_UTIL_TestUtils.createAccountActors(
      account1.Id,
      account2.Id
    );
    System.assert(
      Database.insert(accountActors).isSuccess(),
      'Missing reuqired field.'
    );
  }

  // This method tests the createLead method
  @IsTest
  public static void createLeadTest() {
    // Generate lead
    Lead lead1 = SMC_UTIL_TestUtils.createLead(
      STA_UtilsStatic.LEAD_SOURCE1,
      STA_UtilsStatic.LEAD_COMPANY1,
      STA_UtilsStatic.LEAD_FIRSTNAME1,
      STA_UtilsStatic.LEAD_LASTNAME1,
      STA_UtilsStatic.LEAD_PHONE1,
      STA_UtilsStatic.LEAD_EMAIL1,
      STA_UtilsStatic.LEAD_STREET1,
      STA_UtilsStatic.LEAD_POSTALCODE1,
      STA_UtilsStatic.LEAD_CITY1,
      STA_UtilsStatic.LEAD_STATE1,
      STA_UtilsStatic.LEAD_COUNTRY1
    );

    insert lead1;

    Lead leadToCompare = [SELECT Company FROM Lead];

    System.assertEquals(
      lead1.Company,
      leadToCompare.Company,
      'Leads has not the same company.'
    );
  }

  // This method tests the createContact method
  @IsTest
  public static void createContactTest() {
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
      STA_UtilsStatic.CUSTOMER,
      STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY2
    );
    PAD.bypassAll = true;
    insert account;
    PAD.bypassAll = false;
    // Generate contacts
    Contact contact1 = SMC_UTIL_TestUtils.createContact(
      STA_UtilsStatic.CONTACT_FIRSTNAME1,
      STA_UtilsStatic.CONTACT_LASTNAME1,
      STA_UtilsStatic.CONTACT_PHONE1,
      STA_UtilsStatic.CONTACT_MOBILEPHONE1,
      STA_UtilsStatic.CONTACT_EMAIL1,
      STA_UtilsStatic.CONTACT_MAILINGSTREET1,
      STA_UtilsStatic.CONTACT_MAILINGPOSTALCODE1,
      STA_UtilsStatic.CONTACT_MAILINGCITY1,
      STA_UtilsStatic.CONTACT_MAILINGSTATE1,
      STA_UtilsStatic.CONTACT_MAILINGCOUNTRY1,
      null,
      account.Id
    );

    PAD.bypassAll = true;
    insert contact1;
    PAD.bypassAll = false;

    Contact contactToComp = [SELECT FirstName, LastName FROM Contact];

    System.assertEquals(
      contact1.FirstName,
      contactToComp.FirstName,
      'Missing reuqired field.'
    );
  }

  // This method tests the createOpportunity(3 params) method
  @IsTest
  public static void createOpportunityTest1() {
    Id recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName()
      .get(STA_UtilsStatic.RECORDTYPE_OPPORTUNITY_PROJECT)
      .getRecordTypeId();
    Opportunity opp = SMC_UTIL_TestUtils.createOpportunity(
      recordTypeId,
      STA_UtilsStatic.TEST,
      STA_UtilsStatic.WON
    );

    System.assert(Database.insert(opp).isSuccess(), 'Missing reuqired field.');
  }

  // This method tests the createOpportunity(5 params) method
  @IsTest
  public static void createOpportunityTest2() {
    PAD.bypassAll = true;

    Id recordTypeAccountId = [
        SELECT Id
        FROM RecordType
        WHERE name = :STA_UtilsStatic.RECORDTYPE_ACCOUNT_CUSTOMER
        LIMIT 1
      ]
      .get(0)
      .Id;
    Account account = SMC_UTIL_TestUtils.createAccount(
      recordTypeAccountId,
      STA_UtilsStatic.ACCOUNT_NAME1,
      STA_UtilsStatic.CUSTOMER,
      STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY2
    );
    insert account;

    Contact contact = SMC_UTIL_TestUtils.createContact(
      STA_UtilsStatic.CONTACT_FIRSTNAME1,
      STA_UtilsStatic.CONTACT_LASTNAME1,
      STA_UtilsStatic.CONTACT_PHONE1,
      STA_UtilsStatic.CONTACT_MOBILEPHONE1,
      STA_UtilsStatic.CONTACT_EMAIL1,
      STA_UtilsStatic.CONTACT_MAILINGSTREET1,
      STA_UtilsStatic.CONTACT_MAILINGPOSTALCODE1,
      STA_UtilsStatic.CONTACT_MAILINGCITY1,
      STA_UtilsStatic.CONTACT_MAILINGSTATE1,
      STA_UtilsStatic.CONTACT_MAILINGCOUNTRY1,
      null,
      account.Id
    );
    insert contact;

    PAD.bypassAll = false;

    Id recordTypeOpportunityId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName()
      .get(STA_UtilsStatic.RECORDTYPE_OPPORTUNITY_PROJECT)
      .getRecordTypeId();
    Opportunity opp = SMC_UTIL_TestUtils.createOpportunity(
      recordTypeOpportunityId,
      STA_UtilsStatic.TEST,
      STA_UtilsStatic.WON,
      account,
      contact
    );

    System.assert(Database.insert(opp).isSuccess(), 'Missing reuqired field.');
  }

  // This method tests the createOpportunity(5 params) method
  @IsTest
  public static void createQuoteTest() {
    Profile profile = [
      SELECT Id
      FROM Profile
      WHERE Name = :STA_UtilsStatic.PROFILE_SMC_ADMIN
    ];
    User user = SMC_UTIL_TestUtils.createUser(
      STA_UtilsStatic.USER_NICKNAME,
      STA_UtilsStatic.USERNAME_TEST,
      profile.Id,
      STA_UtilsStatic.USERNAME_TEST,
      STA_UtilsStatic.USER_NICKNAME
    );
    user.Bypass_All_Processes_Builder__c = true;
    insert user;
    PermissionSet ps2 = [
      SELECT ID
      FROM PermissionSet
      WHERE Name = :STA_UtilsStatic.QUOTATION_TOOL_PERMISSION
    ];
    insert new List<PermissionSetAssignment>{
      new PermissionSetAssignment(
        AssigneeId = user.id,
        PermissionSetId = ps2.Id
      )
    };

    System.runAs(user){
      PAD.bypassAll = true;

      Id recordTypeAccountId = [
          SELECT Id
          FROM RecordType
          WHERE name = :STA_UtilsStatic.RECORDTYPE_ACCOUNT_CUSTOMER
          LIMIT 1
        ]
        .get(0)
        .Id;
      Account account = SMC_UTIL_TestUtils.createAccount(
        recordTypeAccountId,
        STA_UtilsStatic.ACCOUNT_NAME1,
        STA_UtilsStatic.CUSTOMER,
        STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY2
      );
      insert account;

      Contact contact = SMC_UTIL_TestUtils.createContact(
        STA_UtilsStatic.CONTACT_FIRSTNAME1,
        STA_UtilsStatic.CONTACT_LASTNAME1,
        STA_UtilsStatic.CONTACT_PHONE1,
        STA_UtilsStatic.CONTACT_MOBILEPHONE1,
        STA_UtilsStatic.CONTACT_EMAIL1,
        STA_UtilsStatic.CONTACT_MAILINGSTREET1,
        STA_UtilsStatic.CONTACT_MAILINGPOSTALCODE1,
        STA_UtilsStatic.CONTACT_MAILINGCITY1,
        STA_UtilsStatic.CONTACT_MAILINGSTATE1,
        STA_UtilsStatic.CONTACT_MAILINGCOUNTRY1,
        null,
        account.Id
      );
      insert contact;

      PAD.bypassAll = false;

      Id recordTypeOpportunityId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName()
        .get(STA_UtilsStatic.RECORDTYPE_OPPORTUNITY_PROJECT)
        .getRecordTypeId();
      Opportunity opp = SMC_UTIL_TestUtils.createOpportunity(
        recordTypeOpportunityId,
        STA_UtilsStatic.TEST,
        STA_UtilsStatic.OPEN,
        account,
        contact
      );
      insert opp;

      Quote quote = SMC_UTIL_TestUtils.createQuote(
        opp.Id,
        STA_UtilsStatic.TEST,
        account.Id
      );
      System.assert(
        Database.insert(quote).isSuccess(),
        'Missing reuqired field.'
      );
    }
  }

  // This method tests the createOpportunity(5 params) method
  @IsTest
  public static void createOpportunityActorsTest() {
    PAD.bypassAll = true;

    Id recordTypeAccountId = [
        SELECT Id
        FROM RecordType
        WHERE name = :STA_UtilsStatic.RECORDTYPE_ACCOUNT_CUSTOMER
        LIMIT 1
      ]
      .get(0)
      .Id;
    Account account = SMC_UTIL_TestUtils.createAccount(
      recordTypeAccountId,
      STA_UtilsStatic.ACCOUNT_NAME1,
      STA_UtilsStatic.CUSTOMER,
      STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY2
    );
    insert account;

    Contact contact = SMC_UTIL_TestUtils.createContact(
      STA_UtilsStatic.CONTACT_FIRSTNAME1,
      STA_UtilsStatic.CONTACT_LASTNAME1,
      STA_UtilsStatic.CONTACT_PHONE1,
      STA_UtilsStatic.CONTACT_MOBILEPHONE1,
      STA_UtilsStatic.CONTACT_EMAIL1,
      STA_UtilsStatic.CONTACT_MAILINGSTREET1,
      STA_UtilsStatic.CONTACT_MAILINGPOSTALCODE1,
      STA_UtilsStatic.CONTACT_MAILINGCITY1,
      STA_UtilsStatic.CONTACT_MAILINGSTATE1,
      STA_UtilsStatic.CONTACT_MAILINGCOUNTRY1,
      null,
      account.Id
    );
    insert contact;

    PAD.bypassAll = false;

    Id recordTypeOpportunityId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName()
      .get(STA_UtilsStatic.RECORDTYPE_OPPORTUNITY_PROJECT)
      .getRecordTypeId();
    Opportunity opp = SMC_UTIL_TestUtils.createOpportunity(
      recordTypeOpportunityId,
      STA_UtilsStatic.TEST,
      STA_UtilsStatic.WON,
      account,
      contact
    );
    insert opp;

    SMC_Opportunity_Actors__c oppActors = SMC_UTIL_TestUtils.createOpportunityActors(
      opp.Id,
      account.Id,
      contact.Id,
      true
    );
    System.assert(
      Database.insert(oppActors).isSuccess(),
      'Missing reuqired field.'
    );
  }

  /*
    // This method tests the createCase(4 params) method
    @IsTest
    public static void createCase1Test() {
        
        PAD.bypassAll = true;

        Group franceTOS = [SELECT Id, Name, Type FROM Group WHERE Type = :STA_UtilsStatic.QUEUE AND Name = :STA_UtilsStatic.ACCOUNT_QUEUE_FRANCE_TOS];
        Id recordTypeIdAccount = [Select Id from RecordType where name =: STA_UtilsStatic.RECORDTYPE_ACCOUNT_CUSTOMER].Id;
        Account oneAccount = SMC_UTIL_TestUtils.createAccount(recordTypeIdAccount, STA_UtilsStatic.TEST + STA_UtilsStatic.ACCOUNT,STA_UtilsStatic.PICKLIST_ACCOUNT_TYPE_MARKETING_PROSPECT,STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY1);
        oneAccount.AccountNumber = 'ACC-{000001}';
        oneAccount.SMC_Queue_ID__c = franceTOS.Id;
        insert oneAccount;
        Contact oneContact = SMC_UTIL_TestUtils.createContact(STA_UtilsStatic.CONTACT_FIRSTNAME1 + 'test', STA_UtilsStatic.CONTACT_LASTNAME1 + 'test', STA_UtilsStatic.CONTACT_PHONE1, STA_UtilsStatic.CONTACT_MOBILEPHONE1,
        'test-' + STA_UtilsStatic.CONTACT_EMAIL1, STA_UtilsStatic.CONTACT_MAILINGSTREET1, STA_UtilsStatic.CONTACT_MAILINGPOSTALCODE1, STA_UtilsStatic.CONTACT_MAILINGCITY1, STA_UtilsStatic.CONTACT_MAILINGSTATE1,
        STA_UtilsStatic.CONTACT_MAILINGCOUNTRY1, STA_UtilsStatic.EMPTY_STRING, oneAccount.Id);
        insert oneContact;

        PAD.bypassAll = false;

        Case oneCase = SMC_UTIL_TestUtils.createCase(STA_UtilsStatic.CASE_SUBJECT2, STA_UtilsStatic.CASE_DESCRIPTION2, STA_UtilsStatic.CASE_TYPE_TECHNICAL_SUPPORT, STA_UtilsStatic.CASE_SUB_STATUS_OPEN);
        oneCase.AccountId = oneAccount.Id;
        oneCase.ContactId = oneContact.Id;
        oneCase.OwnerId = UserInfo.getUserId();
        System.assert(Database.insert(oneCase).isSuccess());
    }
    
    // This method tests the createCase(5 params) method
    @IsTest
    public static void createCase2Test() {
        
        PAD.bypassAll = true;

        Group franceTOS = [SELECT Id, Name, Type FROM Group WHERE Type = :STA_UtilsStatic.QUEUE AND Name = :STA_UtilsStatic.ACCOUNT_QUEUE_FRANCE_TOS];
        Id recordTypeIdAccount = [Select Id from RecordType where name =: STA_UtilsStatic.RECORDTYPE_ACCOUNT_CUSTOMER].Id;
        Account oneAccount = SMC_UTIL_TestUtils.createAccount(recordTypeIdAccount, STA_UtilsStatic.TEST + STA_UtilsStatic.ACCOUNT,STA_UtilsStatic.PICKLIST_ACCOUNT_TYPE_MARKETING_PROSPECT,STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY1);
        oneAccount.AccountNumber = 'ACC-{000001}';
        oneAccount.SMC_Queue_ID__c = franceTOS.Id;
        insert oneAccount;
        Contact oneContact = SMC_UTIL_TestUtils.createContact(STA_UtilsStatic.CONTACT_FIRSTNAME1 + 'test', STA_UtilsStatic.CONTACT_LASTNAME1 + 'test', STA_UtilsStatic.CONTACT_PHONE1, STA_UtilsStatic.CONTACT_MOBILEPHONE1,
        'test-' + STA_UtilsStatic.CONTACT_EMAIL1, STA_UtilsStatic.CONTACT_MAILINGSTREET1, STA_UtilsStatic.CONTACT_MAILINGPOSTALCODE1, STA_UtilsStatic.CONTACT_MAILINGCITY1, STA_UtilsStatic.CONTACT_MAILINGSTATE1,
        STA_UtilsStatic.CONTACT_MAILINGCOUNTRY1, STA_UtilsStatic.EMPTY_STRING, oneAccount.Id);
        insert oneContact;

        PAD.bypassAll = false;

        Case oneCase = SMC_UTIL_TestUtils.createCase(STA_UtilsStatic.CASE_SUBJECT2, STA_UtilsStatic.CASE_DESCRIPTION2, STA_UtilsStatic.CASE_TYPE_TECHNICAL_SUPPORT, STA_UtilsStatic.CASE_SUB_STATUS_OPEN, STA_UtilsStatic.CASE_SUB_STATUS_OPEN);
        oneCase.AccountId = oneAccount.Id;
        oneCase.ContactId = oneContact.Id;
        oneCase.OwnerId = UserInfo.getUserId();
        System.assert(Database.insert(oneCase).isSuccess());
    }
    
    // This method tests the createCase(4 params) method
    @IsTest
    public static void createCaseCommentTest() {
        
        PAD.bypassAll = true;

        Group franceTOS = [SELECT Id, Name, Type FROM Group WHERE Type = :STA_UtilsStatic.QUEUE AND Name = :STA_UtilsStatic.ACCOUNT_QUEUE_FRANCE_TOS];
        Id recordTypeIdAccount = [Select Id from RecordType where name =: STA_UtilsStatic.RECORDTYPE_ACCOUNT_CUSTOMER].Id;
        Account oneAccount = SMC_UTIL_TestUtils.createAccount(recordTypeIdAccount, STA_UtilsStatic.TEST + STA_UtilsStatic.ACCOUNT,STA_UtilsStatic.PICKLIST_ACCOUNT_TYPE_MARKETING_PROSPECT,STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY1);
        oneAccount.AccountNumber = 'ACC-{000001}';
        oneAccount.SMC_Queue_ID__c = franceTOS.Id;
        insert oneAccount;
        Contact oneContact = SMC_UTIL_TestUtils.createContact(STA_UtilsStatic.CONTACT_FIRSTNAME1 + 'test', STA_UtilsStatic.CONTACT_LASTNAME1 + 'test', STA_UtilsStatic.CONTACT_PHONE1, STA_UtilsStatic.CONTACT_MOBILEPHONE1,
        'test-' + STA_UtilsStatic.CONTACT_EMAIL1, STA_UtilsStatic.CONTACT_MAILINGSTREET1, STA_UtilsStatic.CONTACT_MAILINGPOSTALCODE1, STA_UtilsStatic.CONTACT_MAILINGCITY1, STA_UtilsStatic.CONTACT_MAILINGSTATE1,
        STA_UtilsStatic.CONTACT_MAILINGCOUNTRY1, STA_UtilsStatic.EMPTY_STRING, oneAccount.Id);
        insert oneContact;

        PAD.bypassAll = false;

        Case oneCase = SMC_UTIL_TestUtils.createCase(STA_UtilsStatic.CASE_SUBJECT2, STA_UtilsStatic.CASE_DESCRIPTION2, STA_UtilsStatic.CASE_TYPE_TECHNICAL_SUPPORT, STA_UtilsStatic.CASE_SUB_STATUS_OPEN);
        oneCase.AccountId = oneAccount.Id;
        oneCase.ContactId = oneContact.Id;
        oneCase.OwnerId = UserInfo.getUserId();
        insert oneCase;

        CaseComment oneCaseComment = SMC_UTIL_TestUtils.createCaseComment(oneCase.Id, STA_UtilsStatic.TEST, true);
        System.assert(Database.insert(oneCaseComment).isSuccess());
    }*/

  // This method tests the createEvent method
  @IsTest
  public static void createEventTest() {
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
      STA_UtilsStatic.CUSTOMER,
      STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY2
    );
    PAD.bypassAll = true;
    insert account;
    PAD.bypassAll = false;
    // Generate contacts
    Contact contact1 = SMC_UTIL_TestUtils.createContact(
      STA_UtilsStatic.CONTACT_FIRSTNAME1,
      STA_UtilsStatic.CONTACT_LASTNAME1,
      STA_UtilsStatic.CONTACT_PHONE1,
      STA_UtilsStatic.CONTACT_MOBILEPHONE1,
      STA_UtilsStatic.CONTACT_EMAIL1,
      STA_UtilsStatic.CONTACT_MAILINGSTREET1,
      STA_UtilsStatic.CONTACT_MAILINGPOSTALCODE1,
      STA_UtilsStatic.CONTACT_MAILINGCITY1,
      STA_UtilsStatic.CONTACT_MAILINGSTATE1,
      STA_UtilsStatic.CONTACT_MAILINGCOUNTRY1,
      null,
      account.Id
    );

    PAD.bypassAll = true;
    insert contact1;
    PAD.bypassAll = false;

    Event event = SMC_UTIL_TestUtils.createEvent(
      UserInfo.getUserID(),
      account.Id,
      contact1.Id,
      STA_UtilsStatic.EVENT_SUBJECT1,
      STA_UtilsStatic.EVENT_DESCRIPTION1,
      STA_UtilsStatic.LOCATION,
      Datetime.newInstance(2017, 10, 20, 12, 30, 0),
      Datetime.newInstance(2017, 10, 20, 13, 30, 0)
    );

    insert event;

    Event eventToComp = [SELECT Subject FROM Event];

    System.assertEquals(
      event.Subject,
      eventToComp.Subject,
      'Missing reuqired field.'
    );
  }

  // This method tests the createEvent method
  @IsTest
  public static void createEventRelationTest() {
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
      STA_UtilsStatic.CUSTOMER,
      STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY2
    );
    PAD.bypassAll = true;
    insert account;
    PAD.bypassAll = false;
    // Generate contacts
    Contact contact1 = SMC_UTIL_TestUtils.createContact(
      STA_UtilsStatic.CONTACT_FIRSTNAME1,
      STA_UtilsStatic.CONTACT_LASTNAME1,
      STA_UtilsStatic.CONTACT_PHONE1,
      STA_UtilsStatic.CONTACT_MOBILEPHONE1,
      STA_UtilsStatic.CONTACT_EMAIL1,
      STA_UtilsStatic.CONTACT_MAILINGSTREET1,
      STA_UtilsStatic.CONTACT_MAILINGPOSTALCODE1,
      STA_UtilsStatic.CONTACT_MAILINGCITY1,
      STA_UtilsStatic.CONTACT_MAILINGSTATE1,
      STA_UtilsStatic.CONTACT_MAILINGCOUNTRY1,
      null,
      account.Id
    );

    PAD.bypassAll = true;
    insert contact1;
    PAD.bypassAll = false;

    Event event = SMC_UTIL_TestUtils.createEvent(
      UserInfo.getUserID(),
      account.Id,
      contact1.Id,
      STA_UtilsStatic.EVENT_SUBJECT1,
      STA_UtilsStatic.EVENT_DESCRIPTION1,
      STA_UtilsStatic.LOCATION,
      Datetime.newInstance(2017, 10, 20, 12, 30, 0),
      Datetime.newInstance(2017, 10, 20, 13, 30, 0)
    );
    insert event;

    User user = SMC_UTIL_TestUtils.createTestUser(
      STA_UtilsStatic.PROFILE_SALE_STANDARD
    );
    insert user;
    EventRelation eventRelation = SMC_UTIL_TestUtils.createEventRelation(
      event.Id,
      user.Id,
      true
    );
    System.assert(
      Database.insert(eventRelation).isSuccess(),
      'Missing reuqired field.'
    );
  }

  /**
  * @description : test SMC_UTIL_TestUtils.createTeamMember()
  * @author Vincent RECASENS (Modis) | 07-15-2020 
  **/
  @isTest
  public static void createTeamMemberTest() {
    //create and insert accounts with team Member
    Id profileId = [
        SELECT Id
        FROM Profile
        WHERE Name = :STA_UtilsStatic.PROFILE_SALE_STANDARD
        LIMIT 1
      ]
      .get(0)
      .Id;
    User user = SMC_UTIL_TestUtils.createUser(
      STA_UtilsStatic.USER_NICKNAME,
      STA_UtilsStatic.USERNAME_TEST,
      profileId,
      STA_UtilsStatic.USERNAME_TEST,
      STA_UtilsStatic.USER_NICKNAME
    );
    insert user;

    System.runAs(user) {
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
        STA_UtilsStatic.TEST,
        STA_UtilsStatic.PICKLIST_ACCOUNT_TYPE_MARKETING_PROSPECT,
        STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY2
      );
      account.SMC_Category__c = STA_UtilsStatic.ACCOUNT_CATEGORY1;
      account.OwnerId = user.Id;
      insert account;

      /*****NOT PAD --> USELESS****/
      // AccountTeamMember teamMember =  SMC_UTIL_TestUtils.createTeamMember(account.Id, user.Id);

      // Test.startTest();
      //     // Database.insert(teamMember);
      // Test.stopTest();
      /*****NOT PAD --> USELESS****/

      AccountTeamMember teamMemberToCompare = [
        SELECT
          TeamMemberRole,
          AccountId,
          AccountAccessLevel,
          CaseAccessLevel,
          OpportunityAccessLevel,
          ContactAccessLevel,
          UserId
        FROM AccountTeamMember
      ];
      System.assertNotEquals(
        null,
        teamMemberToCompare,
        'Missing reuqired field.'
      );
    }
  }

  /**
  * @description : test SMC_UTIL_TestUtils.createEmailMessage()
  * @author Vincent RECASENS (Modis) | 07-15-2020 
  **/
  @isTest
  public static void testCreateEmailMessage() {
    Id recordTypeIdAccount = [
      SELECT Id
      FROM RecordType
      WHERE name = :STA_UtilsStatic.RECORDTYPE_ACCOUNT_CUSTOMER
    ]
    .Id;
    Account oneAccount = SMC_UTIL_TestUtils.createAccount(
      recordTypeIdAccount,
      STA_UtilsStatic.TEST + STA_UtilsStatic.ACCOUNT,
      STA_UtilsStatic.PICKLIST_ACCOUNT_TYPE_MARKETING_PROSPECT,
      STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY1
    );
    insert oneAccount;

    EmailMessage result = SMC_UTIL_TestUtils.createEmailMessage(
      oneAccount.Id,
      STA_UtilsStatic.TEST,
      'Subject ' + STA_UtilsStatic.TEST,
      UserInfo.getUserName(),
      UserInfo.getUserEmail(),
      null,
      UserInfo.getUserEmail()
    );
    System.assertNotEquals(null, result, 'Missing reuqired field.');
    System.assertEquals(
      oneAccount.id,
      result.ParentId,
      'Email message link to the wrong parent'
    );
    System.assertEquals(
      STA_UtilsStatic.TEST,
      result.TextBody,
      'Email message have a diffrent TextBody than setup.'
    );
    System.assertEquals(
      'Subject ' + STA_UtilsStatic.TEST,
      result.Subject,
      'Email message have a diffrent Subject than setup.'
    );
    System.assertEquals(
      UserInfo.getUserName(),
      result.FromName,
      'Email message have a diffrent FromName than setup.'
    );
    System.assertEquals(
      UserInfo.getUserEmail(),
      result.FromAddress,
      'Email message have a diffrent FromAddress than setup.'
    );
    System.assertEquals(
      null,
      result.ValidatedFromAddress,
      'Email message have a diffrent ValidatedFromAddress than setup.'
    );
    System.assertEquals(
      UserInfo.getUserEmail(),
      result.ToAddress,
      'Email message have a diffrent ToAddress than setup.'
    );
  }

  /**
  * @description : test SMC_UTIL_TestUtils.createContentDocumentLink()
  * @author Vincent RECASENS (Modis) | 07-15-2020 
  **/
  @isTest
  public static void testCreateContentDocumentLink() {
    Id profileId = [
        SELECT Id
        FROM Profile
        WHERE Name = :STA_UtilsStatic.PROFILE_SALE_STANDARD
        LIMIT 1
      ]
      .get(0)
      .Id;
    User user = SMC_UTIL_TestUtils.createUser(
      STA_UtilsStatic.USER_NICKNAME,
      STA_UtilsStatic.USERNAME_TEST,
      profileId,
      STA_UtilsStatic.USERNAME_TEST,
      STA_UtilsStatic.USER_NICKNAME
    );
    insert user;

    Id currentUserId = UserInfo.getUserId();

    System.runAs(user) {
      Id recordTypeIdAccount = [
        SELECT Id
        FROM RecordType
        WHERE name = :STA_UtilsStatic.RECORDTYPE_ACCOUNT_CUSTOMER
      ]
      .Id;
      Account oneAccount = SMC_UTIL_TestUtils.createAccount(
        recordTypeIdAccount,
        STA_UtilsStatic.TEST + STA_UtilsStatic.ACCOUNT,
        STA_UtilsStatic.PICKLIST_ACCOUNT_TYPE_MARKETING_PROSPECT,
        STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY1
      );
      insert oneAccount;

      ContentVersion contentVersion = new ContentVersion();
      contentVersion.Title = 'Test';
      contentVersion.PathOnClient = 'Test.txt';
      contentVersion.VersionData = Blob.valueOf('Test Content');
      contentVersion.IsMajorVersion = true;
      contentVersion.FirstPublishLocationId = oneAccount.Id;
      insert contentVersion;

      contentVersion = [
        SELECT Id, Title, ContentDocumentId
        FROM ContentVersion
        WHERE Id = :contentVersion.Id
        LIMIT 1
      ];
      ContentDocumentLink result = SMC_UTIL_TestUtils.createContentDocumentLink(
        currentUserId,
        contentVersion.ContentDocumentId,
        STA_UtilsStatic.VIEWER_PERMISSION,
        STA_UtilsStatic.ALL_USERS
      );

      System.assertEquals(
        currentUserId,
        result.LinkedEntityId,
        'The ContentDoucmentLink is linked to the wrong record.'
      );
      System.assertEquals(
        contentVersion.ContentDocumentId,
        result.ContentDocumentId,
        'The ContentDoucmentLink have a different ContentDocument.'
      );
      System.assertEquals(
        STA_UtilsStatic.VIEWER_PERMISSION,
        result.ShareType,
        'The ContentDoucmentLink have a wrong ShareType.'
      );
      System.assertEquals(
        STA_UtilsStatic.ALL_USERS,
        result.Visibility,
        'The ContentDoucmentLink have a Visibility.'
      );
    }
  }

  @isTest
  public static void testCreatePRMQuote(){
    Id profileId = [
        SELECT Id
        FROM Profile
        WHERE Name = :STA_UtilsStatic.PROFILE_SALE_STANDARD
        LIMIT 1
      ]
      .get(0)
      .Id;
    User user = SMC_UTIL_TestUtils.createUser(
      STA_UtilsStatic.USER_NICKNAME,
      STA_UtilsStatic.USERNAME_TEST,
      profileId,
      STA_UtilsStatic.USERNAME_TEST,
      STA_UtilsStatic.USER_NICKNAME
    );
    insert user;

    System.runAs(user){
      Id recordTypeIdAccount = [
        SELECT Id
        FROM RecordType
        WHERE name = :STA_UtilsStatic.RECORDTYPE_ACCOUNT_CUSTOMER
      ]
      .Id;
      Account oneAccount = SMC_UTIL_TestUtils.createAccount(
        recordTypeIdAccount,
        STA_UtilsStatic.TEST + STA_UtilsStatic.ACCOUNT,
        STA_UtilsStatic.PICKLIST_ACCOUNT_TYPE_MARKETING_PROSPECT,
        STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY1
      );
      insert oneAccount;

      //Opportunity
      Id recordTypeOppId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName()
                            .get(STA_UtilsStatic.RECORDTYPE_OPPORTUNITY_PROJECT)
                            .getRecordTypeId();
      Opportunity opp = SMC_UTIL_TestUtils.createOpportunity(recordTypeOppId, 
                                                              STA_UtilsStatic.TEST + 'Share File - Opp', 
                                                              STA_UtilsStatic.RECORDTYPE_OPPORTUNITY_PROJECT);
      insert opp;

      //Quote
      Quote oneQuote = SMC_UTIL_TestUtils.createQuote(opp.Id, 
                                                      STA_UtilsStatic.TEST + 'Share File', 
                                                      oneAccount.Id);
      insert oneQuote;

      Test.startTest();
        SMC_PRM_Quote__c prmQuote = SMC_UTIL_TestUtils.createPRMQuote(oneQuote.Id);
        insert prmQuote;
      Test.stopTest();
      SMC_PRM_Quote__c prmQuoteChecker = [SELECT Id, Quote__c, SMC_Account_Name__c FROM SMC_PRM_Quote__c WHERE Id = :prmQuote.Id];
      System.assertEquals(oneQuote.Id, prmQuoteChecker.Quote__c, 'The PRM Quote is not link to the quote (Quote.Id)');
      System.assertEquals(oneAccount.Name, prmQuoteChecker.SMC_Account_Name__c, 'The PRM Quote is not link to the quote (Account.Name)');

    }
  }
  /* Commenter par David afin de pouvoir deployer des hotfixes
    @isTest
    public static void testCreateAsset(){

        Id recordTypeIdAccount = [Select Id from RecordType where name =: STA_UtilsStatic.RECORDTYPE_ACCOUNT_CUSTOMER].Id;
        Account oneAccount = SMC_UTIL_TestUtils.createAccount(recordTypeIdAccount, STA_UtilsStatic.TEST + STA_UtilsStatic.ACCOUNT,STA_UtilsStatic.PICKLIST_ACCOUNT_TYPE_MARKETING_PROSPECT,STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY1);
        insert oneAccount;
        Contact oneContact = SMC_UTIL_TestUtils.createContact(STA_UtilsStatic.CONTACT_FIRSTNAME1 + 'test', STA_UtilsStatic.CONTACT_LASTNAME1 + 'test', STA_UtilsStatic.CONTACT_PHONE1, STA_UtilsStatic.CONTACT_MOBILEPHONE1,
        'test-' + STA_UtilsStatic.CONTACT_EMAIL1, STA_UtilsStatic.CONTACT_MAILINGSTREET1, STA_UtilsStatic.CONTACT_MAILINGPOSTALCODE1, STA_UtilsStatic.CONTACT_MAILINGCITY1, STA_UtilsStatic.CONTACT_MAILINGSTATE1,
        STA_UtilsStatic.CONTACT_MAILINGCOUNTRY1, STA_UtilsStatic.EMPTY_STRING, oneAccount.Id);
        insert oneContact;
        
        Asset oneAsset = SMC_UTIL_TestUtils.createAsset(STA_UtilsStatic.TEST, oneAccount.Id, oneContact.Id, '007');

        System.assertEquals(oneAccount.Id, oneAsset.AccountId);
        System.assertEquals(oneContact.Id, oneAsset.ContactId);
    }
    */
}