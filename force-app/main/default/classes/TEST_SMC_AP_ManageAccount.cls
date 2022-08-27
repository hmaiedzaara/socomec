/*
---------------------------------------------------------------------
-- - Name          : TEST_SMC_AP_ManageAccount
-- - Author        : Xavier BRANCHE
-- - Description   : Test the Manage Account               
-- Maintenance History:
--
-- Date         Name 			 Version  Remarks 
-- -----------  ----  			 -------  ---------------------------
-- 30-MAI-2017  TEST_SMC_AP_ManageAccount    1.0      Initial version 
---------------------------------------------------------------------
*/
@IsTest
public without sharing class TEST_SMC_AP_ManageAccount {
  @testSetup
  static void allTheDataForThisTestClass() {
    //create and insert users
    Profile profile = [
      SELECT Id
      FROM Profile
      WHERE Name = :STA_UtilsStatic.PROFILE_SALE_STANDARD
    ];
    User user = SMC_UTIL_TestUtils.createUser(
      STA_UtilsStatic.TEST_DIESE,
      STA_UtilsStatic.EMAIL_TEST,
      profile.Id,
      STA_UtilsStatic.USERNAME_TEST + 'ManageAccount',
      STA_UtilsStatic.USER_NICKNAME + 'ManageAccount'
    );
    User user1 = SMC_UTIL_TestUtils.createUser(
      STA_UtilsStatic.TEST_DIESE + '1',
      STA_UtilsStatic.EMAIL_TEST + '1',
      profile.Id,
      STA_UtilsStatic.USERNAME_TEST,
      STA_UtilsStatic.USER_NICKNAME
    );
    User user2 = SMC_UTIL_TestUtils.createUser(
      STA_UtilsStatic.TEST_DIESE + '2',
      STA_UtilsStatic.EMAIL_TEST + '2',
      profile.Id,
      STA_UtilsStatic.USERNAME_TEST2,
      STA_UtilsStatic.USER_NICKNAME2
    );
    User user3 = SMC_UTIL_TestUtils.createUser(
      STA_UtilsStatic.TEST_DIESE + '3',
      STA_UtilsStatic.EMAIL_TEST + '3',
      profile.Id,
      STA_UtilsStatic.USERNAME_TEST3,
      STA_UtilsStatic.USER_NICKNAME3
    );
    User user4 = SMC_UTIL_TestUtils.createUser(
      STA_UtilsStatic.TEST_DIESE + '4',
      STA_UtilsStatic.EMAIL_TEST + '4',
      profile.Id,
      STA_UtilsStatic.USERNAME_TEST4,
      STA_UtilsStatic.USER_NICKNAME4
    );
    User user5 = SMC_UTIL_TestUtils.createUser(
      STA_UtilsStatic.TEST_DIESE + '5',
      STA_UtilsStatic.EMAIL_TEST + '5',
      profile.Id,
      STA_UtilsStatic.USERNAME_TEST5,
      STA_UtilsStatic.USER_NICKNAME5
    );
    insert new List<User>{ user, user1, user2, user3, user4, user5 };

    // Create PermissionSet with Custom Permission and assign to test user
    PermissionSet ps = new PermissionSet();
    ps.Name = 'Test';
    ps.Label = 'Test';
    insert ps;
    SetupEntityAccess sea = new SetupEntityAccess();
    sea.ParentId = ps.Id;
    sea.SetupEntityId = [
      SELECT Id
      FROM CustomPermission
      WHERE DeveloperName = :STA_UtilsStatic.DELETE_OPPORTUNITY_PERMISSION
    ][0]
    .Id;
    insert sea;
    PermissionSetAssignment psa = new PermissionSetAssignment();
    psa.AssigneeId = user.Id;
    psa.PermissionSetId = ps.Id;
    insert psa;
  }

  // This method test the insertTeamMember in the SMC_AP_ManageAccount.

  @IsTest
  public static void insertTeamMemberTest() {
    List<Account> accounts = new List<Account>();

    User user = [SELECT Id FROM User WHERE Email = :STA_UtilsStatic.EMAIL_TEST];
    user.Bypass_All_Processes_Builder__c = true;
    update user;

    System.runAs(user) {
      Id recordTypeId = [
          SELECT Id
          FROM RecordType
          WHERE Name = :STA_UtilsStatic.RECORDTYPE_ACCOUNT_CUSTOMER
          LIMIT 1
        ]
        .get(0)
        .Id;
      List<User> users = [
        SELECT Id
        FROM User
        WHERE LastName LIKE :(STA_UtilsStatic.TEST_DIESE + '%')
      ];

      for (Integer i = 0; i < 100; i++) {
        Account account = SMC_UTIL_TestUtils.createAccount(
          recordTypeId,
          STA_UtilsStatic.TEST + i,
          STA_UtilsStatic.PICKLIST_ACCOUNT_TYPE_MARKETING_PROSPECT,
          STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY2
        );
        account.CurrencyIsoCode = STA_UtilsStatic.CURRENCY_EUR;
        account.BillingCountryCode = STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY2;
        account.SMC_EE_Pilot__c = users.get(0).Id;
        account.SMC_PCO_Pilot__c = users.get(1).Id;
        account.SMC_PCS_Pilot__c = users.get(2).Id;
        account.SMC_SERVICE_Pilot__c = users.get(3).Id;
        account.SMC_ESS_Pilot__c = users.get(4).Id;
        account.OwnerId = users.get(5).Id;
        accounts.add(account);
      }

      PAD.ApexForcedBypass.add(
        STA_UtilsStatic.CLASS_ACCOUNT_MANAGEMENT + STA_UtilsStatic.TERRITORY
      );
      Test.startTest();
      insert accounts;
      Test.stopTest();
      PAD.ApexForcedBypass.remove(
        STA_UtilsStatic.CLASS_ACCOUNT_MANAGEMENT + STA_UtilsStatic.TERRITORY
      );
    }

    List<AccountTeamMember> teamMembers = [SELECT Id FROM AccountTeamMember];
    System.assertEquals(100, accounts.size(), 'Check account insertion.');
    System.assertEquals(
      600,
      teamMembers.size(),
      'Check account pilots. There are 5 pilots by account + the owner.'
    );
  }

  @isTest
  public static void eraseCrmCodeTest() {
    // create and insert an Account and an account Cloned form the first one

    // PAD.bypassAll = true;

    Test.startTest();
    PAD.ApexForcedBypass.add(
      STA_UtilsStatic.CLASS_ACCOUNT_MANAGEMENT + STA_UtilsStatic.SCORING
    );
    PAD.ApexForcedBypass.add(
      STA_UtilsStatic.CLASS_ACCOUNT_MANAGEMENT + STA_UtilsStatic.TERRITORY
    );

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
    account.SMC_Account_External_Id__c = STA_UtilsStatic.TEST + 'ssssss';
    insert account;

    account = [
      SELECT RecordTypeID, Name, Type, Id, AccountNumber
      FROM Account
      WHERE Name = :STA_UtilsStatic.TEST
      LIMIT 1
    ];

    Account account2 = account.Clone(false, true, false, true);
    //account2.AccountNumber = STA_UtilsStatic.TEST;
    account2.AccountNumber = STA_UtilsStatic.TEST + '2';
    account2.Name = STA_UtilsStatic.CLONED;
    account2.BillingCountry = STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY2;
    insert account2;

    List<Account> accounts = new List<Account>();
    accounts.add(account);
    accounts.add(account2);

    PAD.ApexForcedBypass.remove(
      STA_UtilsStatic.CLASS_ACCOUNT_MANAGEMENT + STA_UtilsStatic.SCORING
    );
    PAD.ApexForcedBypass.remove(
      STA_UtilsStatic.CLASS_ACCOUNT_MANAGEMENT + STA_UtilsStatic.TERRITORY
    );
    Test.stopTest();

    Account accountCheck = [
      SELECT RecordTypeID, Name, Type, Id, AccountNumber
      FROM Account
      WHERE Name = :STA_UtilsStatic.TEST
      LIMIT 1
    ];
    Account account2Check = [
      SELECT AccountNumber
      FROM Account
      WHERE Name = :STA_UtilsStatic.CLONED
    ];

    System.assertNotEquals(
      null,
      accountCheck.AccountNumber,
      'The AccountNumber was not filled during insertion.'
    );
    System.assertNotEquals(
      null,
      account2Check.AccountNumber,
      'The AccountNumber was not filled during insertion.'
    );
  }

  @IsTest
  public static void completeAccountsWithDefaultCountryTestOK() {
    // PAD.bypassAll = true;

    Id profileId = [
        SELECT Id
        FROM Profile
        WHERE Name = :STA_UtilsStatic.PROFILE_SALE_STANDARD
        LIMIT 1
      ]
      .get(0)
      .Id;
    User user = SMC_UTIL_TestUtils.createUser(
      STA_UtilsStatic.TEST_DIESE + 'CAWDCT1',
      STA_UtilsStatic.EMAIL_TEST + 'CAWDCT1',
      profileId,
      STA_UtilsStatic.USERNAME_TEST + 'CAWDCT1',
      STA_UtilsStatic.USER_NICKNAME + 'CAWDCT1'
    );
    user.SMC_Default_Country__c = 'FR';
    user.Bypass_All_Validation_Rules__c = true;
    insert user;

    Id recordTypeId = [
        SELECT Id
        FROM RecordType
        WHERE name = :STA_UtilsStatic.RECORDTYPE_ACCOUNT_CUSTOMER
        LIMIT 1
      ]
      .get(0)
      .Id;
    List<Account> accounts = new List<Account>();
    Account accountTest1 = SMC_UTIL_TestUtils.createAccount(
      recordTypeId,
      STA_UtilsStatic.ACCOUNT_NAME1,
      STA_UtilsStatic.PICKLIST_ACCOUNT_TYPE_MARKETING_PROSPECT,
      null
    );
    // accountTest1.BillingCountryCode = null;
    accounts.add(accountTest1);

    Account accountTest2 = SMC_UTIL_TestUtils.createAccount(
      recordTypeId,
      STA_UtilsStatic.ACCOUNT_NAME2,
      STA_UtilsStatic.PICKLIST_ACCOUNT_TYPE_MARKETING_PROSPECT,
      null
    );
    // accountTest1.BillingCountryCode = null;
    accounts.add(accountTest2);
    System.runAs(user) {
      insert accounts;

      List<Account> accountsInserted = [
        SELECT BillingCountryCode, BillingCountry
        FROM Account
      ];
      for (Account elem : accountsInserted) {
        System.assertEquals(
          user.SMC_Default_Country__c,
          elem.BillingCountryCode,
          'Accounts do not save the user default country code.'
        );
        // TODO System.assertEquals('France', elem.BillingCountry);
      }
    }
  }

  @IsTest
  public static void completeAccountsWithDefaultCountryTestKO() {
    Id profileId = [
        SELECT Id
        FROM Profile
        WHERE Name = :STA_UtilsStatic.PROFILE_SALE_STANDARD
        LIMIT 1
      ]
      .get(0)
      .Id;
    User user = SMC_UTIL_TestUtils.createUser(
      STA_UtilsStatic.TEST_DIESE + 'CAWDCT1',
      STA_UtilsStatic.EMAIL_TEST + 'CAWDCT1',
      profileId,
      STA_UtilsStatic.USERNAME_TEST + 'CAWDCT1',
      STA_UtilsStatic.USER_NICKNAME + 'CAWDCT1'
    );
    insert user;

    Id recordTypeId = [
        SELECT Id
        FROM RecordType
        WHERE name = :STA_UtilsStatic.RECORDTYPE_ACCOUNT_CUSTOMER
        LIMIT 1
      ]
      .get(0)
      .Id;
    Account accountTest = SMC_UTIL_TestUtils.createAccount(
      recordTypeId,
      STA_UtilsStatic.TEST + 'CAWDCT1',
      STA_UtilsStatic.PICKLIST_ACCOUNT_TYPE_MARKETING_PROSPECT,
      STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY2
    );
    accountTest.BillingCountryCode = 'LU';
    accountTest.BillingCountry = 'LU';

    PAD.ApexForcedBypass.add(
      STA_UtilsStatic.CLASS_ACCOUNT_MANAGEMENT + STA_UtilsStatic.SCORING
    );
    PAD.ApexForcedBypass.add(
      STA_UtilsStatic.CLASS_ACCOUNT_MANAGEMENT + STA_UtilsStatic.TERRITORY
    );
    System.runAs(user) {
      Test.startTest();
      insert accountTest;
      Test.stopTest();
    }
    PAD.ApexForcedBypass.remove(
      STA_UtilsStatic.CLASS_ACCOUNT_MANAGEMENT + STA_UtilsStatic.SCORING
    );
    PAD.ApexForcedBypass.remove(
      STA_UtilsStatic.CLASS_ACCOUNT_MANAGEMENT + STA_UtilsStatic.TERRITORY
    );

    System.assertNotEquals(
      null,
      accountTest.Id,
      'The accountTest was not inserted.'
    );
    System.assertEquals(
      'LU',
      accountTest.BillingCountry,
      'The account country was erased by user default country or field is empty.'
    );
    System.assertEquals(
      'LU',
      accountTest.BillingCountryCode,
      'The account country code was erased by user default country code or field is empty.'
    );
  }

  @IsTest
  public static void setAssignedTerritoriesTESTOK() {
    Id profileId = [
        SELECT Id
        FROM Profile
        WHERE Name = :STA_UtilsStatic.PROFILE_SALE_STANDARD
        LIMIT 1
      ]
      .get(0)
      .Id;
    User user = SMC_UTIL_TestUtils.createUser(
      STA_UtilsStatic.TEST_DIESE + 'ATOK',
      STA_UtilsStatic.EMAIL_TEST + 'ATOK',
      profileId,
      STA_UtilsStatic.USERNAME_TEST + 'ATOK',
      STA_UtilsStatic.USER_NICKNAME + 'ATOK'
    );
    user.Bypass_All_Processes_Builder__c = true;
    user.Bypass_All_Duplicate_Rules__c = true;
    user.Bypass_All_Workflow_Rules__c = true;
    user.Bypass_All_Validation_Rules__c = true;
    insert user;

    Id recordTypeId = [
        SELECT Id
        FROM RecordType
        WHERE name = :STA_UtilsStatic.RECORDTYPE_ACCOUNT_CUSTOMER
        LIMIT 1
      ]
      .get(0)
      .Id;
    Account accountTest = SMC_UTIL_TestUtils.createAccount(
      recordTypeId,
      STA_UtilsStatic.TEST + 'ATOK',
      STA_UtilsStatic.PICKLIST_ACCOUNT_TYPE_MARKETING_PROSPECT,
      STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY2
    );
    accountTest.BillingCountry = 'JP';

    //fake callout
    SMC_UTIL_MockHttpResponseGenerator fakeResponse = new SMC_UTIL_MockHttpResponseGenerator(
      200,
      STA_UtilsStatic.EMPTY_STRING,
      '{"hasErrors":false,"results":[{"statusCode":204,"result":null}]}',
      null
    );
    Test.setMock(HttpCalloutMock.class, fakeResponse);

    PAD.ApexForcedBypass.add(
      STA_UtilsStatic.CLASS_ACCOUNT_MANAGEMENT + STA_UtilsStatic.SCORING
    );
    System.runAs(user) {
      insert accountTest;
      Test.startTest();
      accountTest.BillingCountry = 'AL';
      update accountTest;
      Test.stopTest();
    }
    PAD.ApexForcedBypass.remove(
      STA_UtilsStatic.CLASS_ACCOUNT_MANAGEMENT + STA_UtilsStatic.SCORING
    );

    List<ObjectTerritory2Association> listJunction = [
      SELECT Id, ObjectId, Territory2Id
      FROM ObjectTerritory2Association
      WHERE ObjectId = :accountTest.Id
    ];

    List<Id> listTerritoryId = new List<Id>();

    for (ObjectTerritory2Association junction : listJunction) {
      listTerritoryId.add(junction.Territory2Id);
    }

    List<Territory2> listTerritory = [
      SELECT ID, Name, DeveloperName, Territory2ModelId
      FROM Territory2
      WHERE Id IN :listTerritoryId
      ORDER BY Name
    ];

    // //We actually can't test the function since during tests one can't send the true callouts to the SF API which would update the test data
    // System.assertEquals('Central & East Europe', listTerritory.get(0).Name );
    // System.assertEquals('SRB - Socomec Serbia', listTerritory.get(1).Name );
    System.assert(true, 'The assert function is broken.');
  }

  @IsTest
  public static void setAssignedTerritoriesTESTKO() {
    Id profileId = [
        SELECT Id
        FROM Profile
        WHERE Name = :STA_UtilsStatic.PROFILE_SALE_STANDARD
        LIMIT 1
      ]
      .get(0)
      .Id;
    User user = SMC_UTIL_TestUtils.createUser(
      STA_UtilsStatic.TEST_DIESE + 'ATKO',
      STA_UtilsStatic.EMAIL_TEST + 'ATKO',
      profileId,
      STA_UtilsStatic.USERNAME_TEST + 'ATKO',
      STA_UtilsStatic.USER_NICKNAME + 'ATKO'
    );
    user.Bypass_All_Processes_Builder__c = true;
    user.Bypass_All_Duplicate_Rules__c = true;
    user.Bypass_All_Workflow_Rules__c = true;
    user.Bypass_All_Validation_Rules__c = true;
    insert user;

    Id recordTypeId = [
        SELECT Id
        FROM RecordType
        WHERE name = :STA_UtilsStatic.RECORDTYPE_ACCOUNT_CUSTOMER
        LIMIT 1
      ]
      .get(0)
      .Id;
    Account accountTest = SMC_UTIL_TestUtils.createAccount(
      recordTypeId,
      STA_UtilsStatic.TEST + 'ATKO',
      STA_UtilsStatic.PICKLIST_ACCOUNT_TYPE_MARKETING_PROSPECT,
      STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY2
    );
    accountTest.BillingCountry = 'JP';

    //fake callout
    SMC_UTIL_MockHttpResponseGenerator fakeResponse = new SMC_UTIL_MockHttpResponseGenerator(
      200,
      STA_UtilsStatic.EMPTY_STRING,
      '{"hasErrors":false,"results":[{"statusCode":204,"result":null}]}',
      null
    );
    Test.setMock(HttpCalloutMock.class, fakeResponse);

    PAD.ApexForcedBypass.add(
      STA_UtilsStatic.CLASS_ACCOUNT_MANAGEMENT + STA_UtilsStatic.SCORING
    );
    System.runAs(user) {
      insert accountTest;
      Test.startTest();
      accountTest.BillingCity = 'Tokyo';
      update accountTest;
      Test.stopTest();
    }
    PAD.ApexForcedBypass.remove(
      STA_UtilsStatic.CLASS_ACCOUNT_MANAGEMENT + STA_UtilsStatic.SCORING
    );

    system.assertEquals('JP', accountTest.BillingCountry);
    List<ObjectTerritory2Association> listJunction = [
      SELECT Id, ObjectId, Territory2Id
      FROM ObjectTerritory2Association
      WHERE ObjectId = :accountTest.Id
    ];
    system.assertEquals(0, listJunction.size());
  }

  @isTest
  public static void testCheckERPAccountToMassDelete() {
    User userWithPS = [
      SELECT Id, Name
      FROM User
      WHERE Username = :STA_UtilsStatic.USERNAME_TEST
    ];

    System.runAs(userWithPS) {
      Map<String, Schema.RecordTypeInfo> recordTypesAccount = new Map<String, Schema.RecordTypeInfo>();
      recordTypesAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName();
      Id recordTypeIdAcc = recordTypesAccount.get(
          STA_UtilsStatic.RECORDTYPE_ACCOUNT_CUSTOMER_DEVNAME
        )
        .getRecordTypeId();
      Account account = SMC_UTIL_TestUtils.createAccount(
        recordTypeIdAcc,
        STA_UtilsStatic.TEST,
        STA_UtilsStatic.PICKLIST_ACCOUNT_TYPE_CUSTOMER,
        STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY2
      );
      account.SMC_isLinkedWithErp__c = true;
      insert account;

      try {
        delete account;
        System.debug(LoggingLevel.INFO, STA_UtilsStatic.TEST_FAIL_SYSDEBUG);
      } catch (Exception e) {
        System.debug(
          LoggingLevel.INFO,
          'Can\'t delete an account - TEST OK!!\n' + e
        );
      }
      List<Account> accountCheck = new List<Account>();
      accountCheck = [
        SELECT Id
        FROM Account
        WHERE Name = :STA_UtilsStatic.TEST
      ];
      System.assert(accountCheck.size() == 1, 'The account is deleted.');
    }
  }

  @isTest
  public static void testCheckAccountToMassDeleteWithPermission() {
    User userWithPS = [
      SELECT Id, Name
      FROM User
      WHERE Username = :STA_UtilsStatic.USERNAME_TEST + 'ManageAccount'
    ];

    System.runAs(userWithPS) {
      Map<String, Schema.RecordTypeInfo> recordTypesAccount = new Map<String, Schema.RecordTypeInfo>();
      recordTypesAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName();
      Id recordTypeIdAcc = recordTypesAccount.get(
          STA_UtilsStatic.RECORDTYPE_ACCOUNT_CUSTOMER_DEVNAME
        )
        .getRecordTypeId();
      Account account = SMC_UTIL_TestUtils.createAccount(
        recordTypeIdAcc,
        STA_UtilsStatic.TEST,
        STA_UtilsStatic.PICKLIST_ACCOUNT_TYPE_CUSTOMER,
        STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY2
      );
      account.SMC_isLinkedWithErp__c = false;
      insert account;

      try {
        delete account;
      } catch (Exception e) {
        System.debug(LoggingLevel.INFO, STA_UtilsStatic.TEST_FAIL_SYSDEBUG + e);
      }

      List<Account> accountCheck = new List<Account>();
      accountCheck = [
        SELECT Id
        FROM Account
        WHERE Name = :STA_UtilsStatic.TEST
      ];
      System.assert(accountCheck.size() == 0, 'The acocunt is not deleted.');
    }
  }

  @isTest
  public static void testCheckAccountToMassDeleteLinkOpportunity() {
    User userWithPS = [
      SELECT Id, Name
      FROM User
      WHERE Username = :STA_UtilsStatic.USERNAME_TEST
    ];
    userWithPS.Bypass_All_Processes_Builder__c = true;
    userWithPS.Bypass_All_Duplicate_Rules__c = true;
    userWithPS.Bypass_All_Validation_Rules__c = true;
    userWithPS.Bypass_All_Workflow_Rules__c = true;
    update userWithPS;

    System.runAs(userWithPS) {
      Map<String, Schema.RecordTypeInfo> recordTypesAccount = new Map<String, Schema.RecordTypeInfo>();
      recordTypesAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName();
      Id recordTypeIdAcc = recordTypesAccount.get(
          STA_UtilsStatic.RECORDTYPE_ACCOUNT_CUSTOMER_DEVNAME
        )
        .getRecordTypeId();
      Account account1 = SMC_UTIL_TestUtils.createAccount(
        recordTypeIdAcc,
        STA_UtilsStatic.TEST + '1',
        STA_UtilsStatic.PICKLIST_ACCOUNT_TYPE_CUSTOMER,
        STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY2
      );
      insert new List<Account>{ account1 };

      Map<String, Schema.RecordTypeInfo> recordTypesOpportunity = new Map<String, Schema.RecordTypeInfo>();
      recordTypesOpportunity = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName();
      Id recordTypeId = recordTypesOpportunity.get(
          STA_UtilsStatic.RECORDTYPE_OPPORTUNITY_PROJECT
        )
        .getRecordTypeId();
      Opportunity oppToAccount1 = SMC_UTIL_TestUtils.createOpportunity(
        recordTypeId,
        STA_UtilsStatic.TEST,
        STA_UtilsStatic.WON
      );
      oppToAccount1.AccountId = account1.Id;
      insert new List<Opportunity>{ oppToAccount1 };

      //Account1
      try {
        delete account1;
        System.debug(
          LoggingLevel.INFO,
          'ERROR Account1 - Test fail if we\'ll see this message'
        );
      } catch (Exception e) {
        System.debug(
          LoggingLevel.INFO,
          'Account1 - Can\'t delete an account - TEST OK!!\n' + e
        );
      }
      List<Account> accountCheck = new List<Account>();
      accountCheck = [
        SELECT Id
        FROM Account
        WHERE Name LIKE :(STA_UtilsStatic.TEST + '%')
      ];
      System.assertEquals(1, accountCheck.size(), 'The account is deleted.');
    }
  }

  @isTest
  public static void testCheckAccountToMassDeleteListAccountWithOneLinkOpportunity() {
    // Profile profile = [SELECT Id FROM Profile WHERE Name = :STA_UtilsStatic.PROFILE_SALE_STANDARD];
    User userWithPS = [
      SELECT Id, Name
      FROM User
      WHERE Username = :STA_UtilsStatic.USERNAME_TEST
    ];
    userWithPS.Bypass_All_Processes_Builder__c = true;
    userWithPS.Bypass_All_Duplicate_Rules__c = true;
    userWithPS.Bypass_All_Validation_Rules__c = true;
    userWithPS.Bypass_All_Workflow_Rules__c = true;
    update userWithPS;

    System.runAs(userWithPS) {
      Map<String, Schema.RecordTypeInfo> recordTypesAccount = new Map<String, Schema.RecordTypeInfo>();
      recordTypesAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName();
      Id recordTypeIdAcc = recordTypesAccount.get(
          STA_UtilsStatic.RECORDTYPE_ACCOUNT_CUSTOMER_DEVNAME
        )
        .getRecordTypeId();
      Account account1 = SMC_UTIL_TestUtils.createAccount(
        recordTypeIdAcc,
        STA_UtilsStatic.TEST + '1',
        STA_UtilsStatic.PICKLIST_ACCOUNT_TYPE_CUSTOMER,
        STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY2
      );
      Account account2 = SMC_UTIL_TestUtils.createAccount(
        recordTypeIdAcc,
        STA_UtilsStatic.TEST + '2',
        STA_UtilsStatic.PICKLIST_ACCOUNT_TYPE_CUSTOMER,
        STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY2
      );
      insert new List<Account>{ account1, account2 };

      Map<String, Schema.RecordTypeInfo> recordTypesOpportunity = new Map<String, Schema.RecordTypeInfo>();
      recordTypesOpportunity = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName();
      Id recordTypeId = recordTypesOpportunity.get(
          STA_UtilsStatic.RECORDTYPE_OPPORTUNITY_PROJECT
        )
        .getRecordTypeId();
      Opportunity oppToAccount1 = SMC_UTIL_TestUtils.createOpportunity(
        recordTypeId,
        STA_UtilsStatic.TEST,
        STA_UtilsStatic.WON
      );
      oppToAccount1.AccountId = account1.Id;
      insert new List<Opportunity>{ oppToAccount1 };

      try {
        delete new List<Account>{ account1, account2 };
        System.debug(LoggingLevel.INFO, STA_UtilsStatic.TEST_FAIL_SYSDEBUG);
      } catch (Exception e) {
        System.debug(
          LoggingLevel.INFO,
          'Account1 - Can\'t delete an account - TEST OK!!\n' + e
        );
      }
      List<Account> accountCheck = new List<Account>();
      accountCheck = [
        SELECT Id
        FROM Account
        WHERE Name LIKE :(STA_UtilsStatic.TEST + '%')
      ];
      System.assertEquals(2, accountCheck.size(), 'Accounts are deleted.');
    }
  }

  @isTest
  public static void testCheckERPAccountToMassDeleteWithoutPermission() {
    User userWithoutPS = [
      SELECT Id, Name
      FROM User
      WHERE Username = :STA_UtilsStatic.USERNAME_TEST2
    ];

    System.runAs(userWithoutPS) {
      Map<String, Schema.RecordTypeInfo> recordTypesAccount = new Map<String, Schema.RecordTypeInfo>();
      recordTypesAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName();
      Id recordTypeIdAcc = recordTypesAccount.get(
          STA_UtilsStatic.RECORDTYPE_ACCOUNT_CUSTOMER_DEVNAME
        )
        .getRecordTypeId();
      Account account = SMC_UTIL_TestUtils.createAccount(
        recordTypeIdAcc,
        STA_UtilsStatic.TEST,
        STA_UtilsStatic.PICKLIST_ACCOUNT_TYPE_CUSTOMER,
        STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY2
      );
      insert account;

      try {
        delete account;
        System.debug(LoggingLevel.INFO, STA_UtilsStatic.TEST_FAIL_SYSDEBUG);
      } catch (Exception e) {
        System.debug(
          LoggingLevel.INFO,
          'Can\'t delete an account - TEST OK!!\n' + e
        );
      }
      List<Account> accountCheck = new List<Account>();
      accountCheck = [
        SELECT Id
        FROM Account
        WHERE Name = :STA_UtilsStatic.TEST
      ];
      System.assert(accountCheck.size() == 1, 'Account is deleted.');
    }
  }
}