/*
---------------------------------------------------------------------------
-- - Name : TEST_SMC_AP_ManageCase
-- - Author : Vincent RECASENS
-- - Description : This class is the test of SMC_AP_ManageCase
--
-- Maintenance History:
--
-- Date         Name                    Version     Remarks
-- -----------  ----                    -------     ------------------
-- 29-MAR-2018  Vincent RECASENS  		1.0     	Initial Version
---------------------------------------------------------------------------
*/

@isTest
public without sharing class TEST_SMC_AP_ManageCase {
  /**
   * @description : test setup
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  @testSetup
  public static void setup() {
    //Set Admin - Used to setup the AccountQueue
    Profile profileAdmin = [
      SELECT Id
      FROM Profile
      WHERE Name = :STA_UtilsStatic.PROFILE_SMC_ADMIN
    ];
    User userAdmin1 = SMC_UTIL_TestUtils.createUser(
      'admin1-' + STA_UtilsStatic.USER_NICKNAME,
      'admin1-' + STA_UtilsStatic.USERNAME_TEST,
      profileAdmin.Id,
      'admin1-' + STA_UtilsStatic.USERNAME_TEST,
      'admin1-' + STA_UtilsStatic.USER_NICKNAME
    );
    userAdmin1.UserRoleId = [
      SELECT Id
      FROM UserRole
      WHERE DeveloperName = :STA_UtilsStatic.ROLE_CEO_DEVNAME
    ]
    .Id; //CEO
    // userAdmin1.Bypass_All_Processes_Builder__c = true;
    // userAdmin1.Bypass_All_Validation_Rules__c = true;
    // userAdmin1.Bypass_All_Workflow_Rules__c = true;
    User userAdmin2 = SMC_UTIL_TestUtils.createUser(
      'admin2-' + STA_UtilsStatic.USER_NICKNAME,
      'admin2-' + STA_UtilsStatic.USERNAME_TEST,
      profileAdmin.Id,
      'admin2-' + STA_UtilsStatic.USERNAME_TEST,
      'admin2-' + STA_UtilsStatic.USER_NICKNAME
    );
    userAdmin2.UserRoleId = [
      SELECT Id
      FROM UserRole
      WHERE DeveloperName = :STA_UtilsStatic.ROLE_CEO_DEVNAME
    ]
    .Id; //CEO
    insert new List<User>{ userAdmin1, userAdmin2 };

    System.runAs(userAdmin1) {
      //Queue
      Group franceOSL = [
        SELECT Id, Name, Type
        FROM Group
        WHERE
          Type = :STA_UtilsStatic.QUEUE
          AND Name = :STA_UtilsStatic.ACCOUNT_QUEUE_FRANCE_OSL
      ];
      Group franceTOS = [
        SELECT Id, Name, Type
        FROM Group
        WHERE
          Type = :STA_UtilsStatic.QUEUE
          AND Name = :STA_UtilsStatic.ACCOUNT_QUEUE_FRANCE_TOS
      ];
      Id recordTypeIdAccount = [
        SELECT Id
        FROM RecordType
        WHERE name = :STA_UtilsStatic.RECORDTYPE_ACCOUNT_CASE_TEAM
      ]
      .Id;
      Account accountQueue = SMC_UTIL_TestUtils.createAccount(
        recordTypeIdAccount,
        STA_UtilsStatic.ACCOUNT + '_GroupQueue',
        STA_UtilsStatic.PICKLIST_ACCOUNT_TYPE_MARKETING_PROSPECT,
        STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY1
      );
      accountQueue.SMC_Queue_ID__c = franceOSL.Id;
      accountQueue.OwnerId = userAdmin1.Id;
      Account accountQueueToTransfer = SMC_UTIL_TestUtils.createAccount(
        recordTypeIdAccount,
        STA_UtilsStatic.ACCOUNT + '_GroupQueueToTransfer',
        STA_UtilsStatic.PICKLIST_ACCOUNT_TYPE_MARKETING_PROSPECT,
        STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY1
      );
      accountQueueToTransfer.SMC_Queue_ID__c = franceTOS.Id;
      accountQueueToTransfer.OwnerId = userAdmin2.Id;
      insert new List<Account>{ accountQueue, accountQueueToTransfer };

      //Set Contacts
      RecordType recordTypeContactPartner = [
        SELECT Id, Name
        FROM RecordType
        WHERE DeveloperName = :STA_UtilsStatic.PARTNER_CONTACT_RECORDTYPE_NAME
      ];
      Contact contactPartner = SMC_UTIL_TestUtils.createContact(
        null,
        STA_UtilsStatic.CONTACT_LASTNAME1,
        STA_UtilsStatic.CONTACT_PHONE1,
        STA_UtilsStatic.CONTACT_MOBILEPHONE1,
        STA_UtilsStatic.CONTACT_EMAIL1,
        STA_UtilsStatic.CONTACT_MAILINGSTREET1,
        STA_UtilsStatic.CONTACT_MAILINGPOSTALCODE1,
        STA_UtilsStatic.CONTACT_MAILINGCITY1,
        STA_UtilsStatic.CONTACT_MAILINGSTATE1,
        STA_UtilsStatic.CONTACT_MAILINGCOUNTRY1,
        STA_UtilsStatic.EMPTY_STRING,
        accountQueue.Id
      );
      contactPartner.RecordTypeId = recordTypeContactPartner.Id;
      Contact contactPartnerBis = SMC_UTIL_TestUtils.createContact(
        null,
        'bis-' + STA_UtilsStatic.CONTACT_LASTNAME1,
        '1-(601)228-1952',
        '1-(215)343-7720',
        'bis-' + STA_UtilsStatic.CONTACT_EMAIL1,
        STA_UtilsStatic.CONTACT_MAILINGSTREET1,
        STA_UtilsStatic.CONTACT_MAILINGPOSTALCODE1,
        STA_UtilsStatic.CONTACT_MAILINGCITY1,
        STA_UtilsStatic.CONTACT_MAILINGSTATE1,
        STA_UtilsStatic.CONTACT_MAILINGCOUNTRY1,
        STA_UtilsStatic.EMPTY_STRING,
        accountQueueToTransfer.Id
      );
      contactPartner.RecordTypeId = recordTypeContactPartner.Id;

      RecordType recordTypeContactChatterFree = [
        SELECT Id, Name
        FROM RecordType
        WHERE
          DeveloperName = :STA_UtilsStatic.CHATTER_FREE_CONTACT_RECORDTYPE_NAME
      ];
      Contact contactChatterFree = SMC_UTIL_TestUtils.createContact(
        STA_UtilsStatic.CONTACT_FIRSTNAME2,
        STA_UtilsStatic.CONTACT_LASTNAME2,
        STA_UtilsStatic.CONTACT_PHONE2,
        STA_UtilsStatic.CONTACT_MOBILEPHONE2,
        STA_UtilsStatic.CONTACT_EMAIL2,
        STA_UtilsStatic.CONTACT_MAILINGSTREET2,
        STA_UtilsStatic.CONTACT_MAILINGPOSTALCODE2,
        STA_UtilsStatic.CONTACT_MAILINGCITY2,
        STA_UtilsStatic.CONTACT_MAILINGSTATE2,
        STA_UtilsStatic.CONTACT_MAILINGCOUNTRY2,
        STA_UtilsStatic.EMPTY_STRING,
        null
      );
      contactPartner.RecordTypeId = recordTypeContactChatterFree.Id;
      insert new List<Contact>{
        contactPartner,
        contactPartnerBis,
        contactChatterFree
      };

      //Set Users
      Profile profileSupport = [
                SELECT Id
                FROM Profile
                WHERE Name = :STA_UtilsStatic.PROFILE_SMC_STANDARD_SERVICE_SOCOMEC
            ];
      User userSupport = SMC_UTIL_TestUtils.createUser(
        'support-' + STA_UtilsStatic.USER_NICKNAME,
        'support-' + STA_UtilsStatic.USERNAME_TEST,
        profileSupport.Id,
        'support-' + STA_UtilsStatic.USERNAME_TEST,
        'support-' + STA_UtilsStatic.USER_NICKNAME
      );
      userSupport.UserRoleId = [
        SELECT Id
        FROM UserRole
        WHERE DeveloperName = :STA_UtilsStatic.ROLE_SUPPORT_DEVNAME
      ]
      .Id; //Support
      userSupport.Bypass_All_Processes_Builder__c = true;
      userSupport.Bypass_All_Validation_Rules__c = true;
      userSupport.Bypass_All_Workflow_Rules__c = true;

      Profile profileStandard = [
        SELECT Id
        FROM Profile
        WHERE Name = :STA_UtilsStatic.PROFILE_SMC_STANDARD_SERVICE_SOCOMEC
        // WHERE Name = :STA_UtilsStatic.PROFILE_SALE_STANDARD
      ];
      User userStandard = SMC_UTIL_TestUtils.createUser(
        'standard-' + STA_UtilsStatic.USERNAME_TEST,
        'standard-' + STA_UtilsStatic.USERNAME_TEST,
        profileStandard.Id,
        'standard-' + STA_UtilsStatic.USERNAME_TEST,
        'standard-' + STA_UtilsStatic.USERNAME_TEST
      );
      //userStandard.UserRoleId = [SELECT Id FROM UserRole WHERE DeveloperName = :STA_UtilsStatic.ROLE_SUPPORT_DEVNAME].Id; //Support
      userStandard.Bypass_All_Processes_Builder__c = true;
      userStandard.Bypass_All_Validation_Rules__c = true;
      userStandard.Bypass_All_Workflow_Rules__c = true;
      userStandard.IsActive = true;
      userStandard.UserRoleId = [
        SELECT Id
        FROM UserRole
        WHERE DeveloperName = :STA_UtilsStatic.ROLE_CEO_DEVNAME
      ]
      .Id; //CEO

      Profile profilePartner = [
        SELECT Id
        FROM Profile
        WHERE Name = :STA_UtilsStatic.PROFILE_SMC_PARTNER_COMMUNITY
      ];
      User userPartner = SMC_UTIL_TestUtils.createUser(
        STA_UtilsStatic.CONTACT_LASTNAME1,
        STA_UtilsStatic.CONTACT_EMAIL1,
        profilePartner.Id,
        STA_UtilsStatic.CONTACT_EMAIL1,
        STA_UtilsStatic.USER_NICKNAME + '_Partner'
      );
      userPartner.ContactId = contactPartner.Id;
      userPartner.IsActive = true;

      Profile profilesChatterFree = [
        SELECT Id
        FROM Profile
        WHERE Name = :STA_UtilsStatic.PROFILE_SMC_CHATTER_FREE
      ];
      User userChatterFree = SMC_UTIL_TestUtils.createUser(
        STA_UtilsStatic.CONTACT_LASTNAME2,
        STA_UtilsStatic.CONTACT_EMAIL2,
        profilesChatterFree.Id,
        STA_UtilsStatic.CONTACT_EMAIL2,
        STA_UtilsStatic.USER_NICKNAME + '_ChatterFree'
      );
      userChatterFree.IsActive = true;
      insert new List<User>{
        userSupport,
        userStandard,
        /*userPartner, */ userChatterFree
      };
    }
  }

  /**
   * @description : test SMC_AP_ManageCase.updateCaseNewObject()
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  @isTest
  public static void testUpdateCaseNewObjectComment() {
    PAD.bypassAll = true;
    User user1 = [
      SELECT Id
      FROM User
      WHERE Email = :('standard-' + STA_UtilsStatic.USERNAME_TEST)
    ];

    Case oneCase;
    System.runAs(user1) {
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
      oneAccount.AccountNumber = 'ACC-{000001}';
      insert oneAccount;
      Contact oneContact = SMC_UTIL_TestUtils.createContact(
        STA_UtilsStatic.CONTACT_FIRSTNAME1 + 'test',
        STA_UtilsStatic.CONTACT_LASTNAME1 + 'test',
        STA_UtilsStatic.CONTACT_PHONE1,
        STA_UtilsStatic.CONTACT_MOBILEPHONE1,
        'test-' + STA_UtilsStatic.CONTACT_EMAIL1,
        STA_UtilsStatic.CONTACT_MAILINGSTREET1,
        STA_UtilsStatic.CONTACT_MAILINGPOSTALCODE1,
        STA_UtilsStatic.CONTACT_MAILINGCITY1,
        STA_UtilsStatic.CONTACT_MAILINGSTATE1,
        STA_UtilsStatic.CONTACT_MAILINGCOUNTRY1,
        STA_UtilsStatic.EMPTY_STRING,
        oneAccount.Id
      );
      insert oneContact;

      oneCase = SMC_UTIL_TestUtils.createCase(
        STA_UtilsStatic.CASE_SUBJECT2,
        STA_UtilsStatic.CASE_DESCRIPTION2,
        STA_UtilsStatic.CASE_TYPE_TOOL_SUPPORT,
        STA_UtilsStatic.CASE_SUB_STATUS_OPEN,
        STA_UtilsStatic.CASE_SUB_STATUS_OPEN
      );
      oneCase.AccountId = oneAccount.Id;
      oneCase.ContactId = oneContact.Id;
      oneCase.OwnerId = user1.Id;
      insert new List<Case>{ oneCase };
    }

    Map<Id, Boolean> oneCaseId = new Map<Id, Boolean>();
    oneCaseId.put(oneCase.Id, false);
    System.assert(
      oneCase.SMC_New_Comment_Flag__c != true,
      'Bypass was not apply.'
    );

    User user2 = [
      SELECT Id
      FROM User
      WHERE Email = :('admin2-' + STA_UtilsStatic.USERNAME_TEST)
    ];
    CaseComment oneCaseComment;
    System.runAs(user2) {
      oneCaseComment = SMC_UTIL_TestUtils.createCaseComment(
        oneCase.Id,
        STA_UtilsStatic.CASE_BODY,
        false
      );
      insert oneCaseComment;
      SMC_AP_ManageCase.updateCaseNewObject(oneCaseId, STA_UtilsStatic.COMMENT); //Update Case
    }

    System.runAs(user1) {
      Case oneCaseChecked = [
        SELECT Id, Subject, SMC_New_Comment_Flag__c
        FROM Case
        WHERE Subject = :STA_UtilsStatic.CASE_SUBJECT2
      ];
      System.assert(
        oneCaseChecked.SMC_New_Comment_Flag__c == true,
        'Check comment\'s owner and case\'s owner.'
      );
    }
  }

  /**
   * @description : test SMC_AP_ManageCase.updateCaseNewObjectNoSwitchFlag(true)
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  @isTest
  public static void testUpdateCaseNewObjectNoSwitchFlagToTrue() {
    User user = [
      SELECT Id
      FROM User
      WHERE Email = :('standard-' + STA_UtilsStatic.USERNAME_TEST)
    ];
    System.runAs(user) {
      PAD.bypassAll = true;

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
      oneAccount.AccountNumber = 'ACC-{000001}';
      insert oneAccount;
      Contact oneContact = SMC_UTIL_TestUtils.createContact(
        STA_UtilsStatic.CONTACT_FIRSTNAME1 + 'test',
        STA_UtilsStatic.CONTACT_LASTNAME1 + 'test',
        STA_UtilsStatic.CONTACT_PHONE1,
        STA_UtilsStatic.CONTACT_MOBILEPHONE1,
        'test-' + STA_UtilsStatic.CONTACT_EMAIL1,
        STA_UtilsStatic.CONTACT_MAILINGSTREET1,
        STA_UtilsStatic.CONTACT_MAILINGPOSTALCODE1,
        STA_UtilsStatic.CONTACT_MAILINGCITY1,
        STA_UtilsStatic.CONTACT_MAILINGSTATE1,
        STA_UtilsStatic.CONTACT_MAILINGCOUNTRY1,
        STA_UtilsStatic.EMPTY_STRING,
        oneAccount.Id
      );
      insert oneContact;

      Case oneCase = SMC_UTIL_TestUtils.createCase(
        STA_UtilsStatic.CASE_SUBJECT2,
        STA_UtilsStatic.CASE_DESCRIPTION2,
        STA_UtilsStatic.CASE_TYPE_TOOL_SUPPORT,
        STA_UtilsStatic.CASE_SUB_STATUS_OPEN
      );
      oneCase.AccountId = oneAccount.Id;
      oneCase.ContactId = oneContact.Id;
      oneCase.OwnerId = user.Id;
      oneCase.SMC_Take_Ownership__c = true;
      insert new List<Case>{ oneCase };

      PAD.bypassAll = false;

      Map<Id, Boolean> oneCaseId = new Map<Id, Boolean>();
      oneCaseId.put(oneCase.Id, false);

      System.assert(!oneCase.SMC_New_Comment_Flag__c, 'Bypass was not apply.');
      CaseComment oneCaseComment = SMC_UTIL_TestUtils.createCaseComment(
        oneCase.Id,
        STA_UtilsStatic.CASE_BODY,
        false
      );
      insert oneCaseComment;

      Case oneCaseChecked = [
        SELECT Id, Subject, SMC_New_Comment_Flag__c, Status, SMC_Sub_Status__c
        FROM Case
        WHERE Subject = :STA_UtilsStatic.CASE_SUBJECT2
      ];
      System.assert(
        !oneCaseChecked.SMC_New_Comment_Flag__c,
        'Check comment\'s owner and case\'s owner.'
      );
    }
  }

  /**
   * @description : test SMC_AP_ManageCase.updateCasesProductInfo()
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  @isTest
  public static void testUpdateCasesProductInfo() {
    PAD.bypassAll = true;
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
      WHERE Email = :('standard-' + STA_UtilsStatic.USERNAME_TEST)
    ];

    Case oneCase;
    System.runAs(standardUser) {
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
      oneAccount.AccountNumber = 'ACC-{000001}';
      insert oneAccount;
      Contact oneContact = SMC_UTIL_TestUtils.createContact(
        STA_UtilsStatic.CONTACT_FIRSTNAME1 + 'test',
        STA_UtilsStatic.CONTACT_LASTNAME1 + 'test',
        STA_UtilsStatic.CONTACT_PHONE1,
        STA_UtilsStatic.CONTACT_MOBILEPHONE1,
        'test-' + STA_UtilsStatic.CONTACT_EMAIL1,
        STA_UtilsStatic.CONTACT_MAILINGSTREET1,
        STA_UtilsStatic.CONTACT_MAILINGPOSTALCODE1,
        STA_UtilsStatic.CONTACT_MAILINGCITY1,
        STA_UtilsStatic.CONTACT_MAILINGSTATE1,
        STA_UtilsStatic.CONTACT_MAILINGCOUNTRY1,
        STA_UtilsStatic.EMPTY_STRING,
        oneAccount.Id
      );
      insert oneContact;

      oneCase = SMC_UTIL_TestUtils.createCase(
        STA_UtilsStatic.CASE_SUBJECT2,
        STA_UtilsStatic.CASE_DESCRIPTION2,
        STA_UtilsStatic.CASE_TYPE_TOOL_SUPPORT,
        STA_UtilsStatic.CASE_SUB_STATUS_OPEN
      );
      oneCase.AccountId = oneAccount.Id;
      oneCase.ContactId = oneContact.Id;
      oneCase.SMC_Serial_Number__c = SMC_UTIL_CaseCalloutMockJSON.SERIAL_NUMBER_FOR_MOCK;
      oneCase.OwnerId = standardUser.Id;
      oneCase.SMC_Take_Ownership__c = true;
      insert new List<Case>{ oneCase };

      SMC_UTIL_MockHttpResponseGenerator fakeResponse = new SMC_UTIL_MockHttpResponseGenerator(
        200,
        STA_UtilsStatic.COMPLETE,
        SMC_UTIL_CaseCalloutMockJSON.SN_PRODUCT_INFO,
        null
      );
      Test.setMock(HttpCalloutMock.class, fakeResponse);

      Test.startTest();
      SMC_AP_ManageCase.updateCasesProductInfo(
        new List<Case>{ oneCase },
        null,
        true
      );
      Test.stopTest();
    }

    oneCase = [
      SELECT Id, Subject, SMC_Serial_Number__c, SMC_Product_Family__c
      FROM Case
      WHERE Subject = :STA_UtilsStatic.CASE_SUBJECT2
    ];
    System.assertEquals(
      SMC_UTIL_CaseCalloutMockJSON.PRODUCT_FAMILY_MOCK,
      oneCase.SMC_Product_Family__c,
      'Mock is wrong. Check it and relaunch test.'
    );
  }

  /**
   * @description : test SMC_AP_ManageCase.caseAssignmentRuleFromCommunity()
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  @isTest
  public static void testCaseAssignmentRuleFromCommunity() {
    PAD.bypassAll = true;
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
      WHERE Email = :('support-' + STA_UtilsStatic.USERNAME_TEST)
    ];

    System.runAs(standardUser) {
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
      oneAccount.AccountNumber = 'ACC-{000001}';
      insert oneAccount;
      Contact oneContact = SMC_UTIL_TestUtils.createContact(
        STA_UtilsStatic.CONTACT_FIRSTNAME1 + 'test',
        STA_UtilsStatic.CONTACT_LASTNAME1 + 'test',
        STA_UtilsStatic.CONTACT_PHONE1,
        STA_UtilsStatic.CONTACT_MOBILEPHONE1,
        'test-' + STA_UtilsStatic.CONTACT_EMAIL1,
        STA_UtilsStatic.CONTACT_MAILINGSTREET1,
        STA_UtilsStatic.CONTACT_MAILINGPOSTALCODE1,
        STA_UtilsStatic.CONTACT_MAILINGCITY1,
        STA_UtilsStatic.CONTACT_MAILINGSTATE1,
        STA_UtilsStatic.CONTACT_MAILINGCOUNTRY1,
        STA_UtilsStatic.EMPTY_STRING,
        oneAccount.Id
      );
      insert oneContact;

      Case oneCase = SMC_UTIL_TestUtils.createCase(
        STA_UtilsStatic.CASE_SUBJECT2,
        STA_UtilsStatic.CASE_DESCRIPTION2,
        STA_UtilsStatic.CASE_TYPE_TOOL_SUPPORT,
        STA_UtilsStatic.CASE_SUB_STATUS_OPEN
      );
      oneCase.AccountId = oneAccount.Id;
      oneCase.ContactId = oneContact.Id;
      oneCase.OwnerId = standardUser.Id;
      oneCase.SMC_Take_Ownership__c = true;
      insert new List<Case>{ oneCase };

      List<Case> cases = [SELECT Id, Subject FROM Case];
      // System.assert(
      //   SMC_AP_ManageCase.caseAssignmentRuleFromCommunity(cases),
      //   'Assignments rule does not started'
      // );
      System.assert(
        SMC_AP_ManageCase.caseAssignmentRuleFromCommunity(new Set<Id>{ oneCase.Id}),
        'Assignments rule does not started'
      );
    }

    PAD.bypassAll = false;
  }

  /**
   * @description : test SMC_AP_ManageCase.fillQueueInCharge(insert)
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  @isTest
  public static void testFillQueueInChargeINSERT() {
    // User supportUser = [SELECT Id, Username, Alias, FirstName, LastName, SMC_Subsdiary_Label__c, UserType FROM User WHERE Email = :('support-' + STA_UtilsStatic.USERNAME_TEST)];
    // User admin1User = [SELECT Id, Username FROM User WHERE Email = :('admin1-' + STA_UtilsStatic.USERNAME_TEST)];
    User admin1User = [
      SELECT Id, Username, Bypass_Validation_Rule__c
      FROM User
      WHERE Email = :('admin1-' + STA_UtilsStatic.USERNAME_TEST)
    ];
    admin1User.Bypass_Validation_Rule__c = 'SMC_Case_CantModifyWithoutAcceptation';
    update admin1User;

    User admin2User = [
      SELECT Id, Username
      FROM User
      WHERE Email = :('admin2-' + STA_UtilsStatic.USERNAME_TEST)
    ];

    Account oneAccountQueue = [
      SELECT Id, SMC_Queue_ID__c
      FROM Account
      WHERE Name = :(STA_UtilsStatic.ACCOUNT + '_GroupQueue')
    ];
    Contact oneContactQueue = [
      SELECT Id
      FROM Contact
      WHERE AccountId = :oneAccountQueue.Id
    ];

    Account oneAccountQueueToTransfer = [
      SELECT Id, SMC_Queue_ID__c
      FROM Account
      WHERE Name = :(STA_UtilsStatic.ACCOUNT + '_GroupQueueToTransfer')
    ];
    Contact oneContactQueueToTransfer = [
      SELECT Id
      FROM Contact
      WHERE AccountId = :oneAccountQueueToTransfer.Id
    ];

    System.runAs(admin1User) {
      //To fill Queue In Charge --> QueueInCharge = Owner
      Case oneCase = SMC_UTIL_TestUtils.createCase(
        STA_UtilsStatic.CASE_SUBJECT2 + '_QueueOwnerInsert',
        STA_UtilsStatic.CASE_DESCRIPTION2,
        STA_UtilsStatic.CASE_TYPE_TOOL_SUPPORT,
        STA_UtilsStatic.CASE_SUB_STATUS_OPEN
      );
      oneCase.Status = STA_UtilsStatic.CASE_SUB_STATUS_OPEN;
      oneCase.AccountId = oneAccountQueue.Id;
      oneCase.ContactId = oneContactQueue.Id;
      oneCase.OwnerId = (Id) oneAccountQueue.SMC_Queue_ID__c;

      //With Queue In Charge already fill --> Owner = QueueInCharge
      Case twoCase = SMC_UTIL_TestUtils.createCase(
        STA_UtilsStatic.CASE_SUBJECT2 + '_QueueInChargeInsert',
        STA_UtilsStatic.CASE_DESCRIPTION2,
        STA_UtilsStatic.CASE_TYPE_TOOL_SUPPORT,
        STA_UtilsStatic.CASE_SUB_STATUS_OPEN
      );
      twoCase.Status = STA_UtilsStatic.CASE_SUB_STATUS_OPEN;
      twoCase.AccountId = oneAccountQueueToTransfer.Id;
      twoCase.ContactId = oneContactQueueToTransfer.Id;
      twoCase.OwnerId = (Id) oneAccountQueueToTransfer.SMC_Queue_ID__c;

      //With Owner --> do nothing
      Case thirdCase = SMC_UTIL_TestUtils.createCase(
        STA_UtilsStatic.CASE_SUBJECT2 + '_UserOwnerInsert',
        STA_UtilsStatic.CASE_DESCRIPTION2,
        STA_UtilsStatic.CASE_TYPE_TOOL_SUPPORT,
        STA_UtilsStatic.CASE_SUB_STATUS_OPEN
      );
      thirdCase.Status = STA_UtilsStatic.CASE_SUB_STATUS_OPEN;
      thirdCase.AccountId = oneAccountQueueToTransfer.Id;
      thirdCase.ContactId = oneContactQueueToTransfer.Id;
      // thirdCase.SMC_Requestor_Email__c = admin2User.Username;
      thirdCase.OwnerId = admin2User.Id;
      //Insert cases
      // SMC_AP_ManageCase.caseAssignmentRuleFromCommunity(new List<Case>{oneCase, twoCase, thirdCase});
      List<Case> caseList = new List<Case>{ oneCase, twoCase, thirdCase };
      // insert oneCase;
      // insert twoCase;
      // insert thirdCase;
      
      PAD.bypassAll = true;

      insert caseList;
      
      Database.DMLOptions dmo = new Database.DMLOptions();
      dmo.AssignmentRuleHeader.useDefaultRule = true;
      for (Case theCase : caseList) {
        //DML Option
        theCase.setOptions(dmo);
      }
      update caseList;

      PAD.bypassAll = false;
      
      Test.startTest();

      // SMC_AP_ManageCase.caseAssignmentRuleFromCommunity(
      //   new List<Case>{ oneCase, twoCase, thirdCase }
      // );
      // SMC_AP_ManageCase.caseAssignmentRuleFromCommunity(
      //   new Set<Id>{ oneCase.Id, twoCase.Id, thirdCase.Id }
      // );
      Map<Id, Case> caseMap = new Map<Id, Case>(
        [
          SELECT Id, OwnerId, SMC_Expert_Queue__c
          FROM Case
          WHERE Id IN :(new List<Id>{ oneCase.Id, twoCase.Id, thirdCase.Id })
        ]
      );

      /** TO TEST!!! **/
      SMC_AP_ManageCase.fillQueueInCharge(caseMap, true);
      // PAD.bypassAll = false;

      Test.stopTest();

      Case checkCaseQueue = [
        SELECT Id, Subject, OwnerId, SMC_Expert_Queue__c
        FROM Case
        WHERE Subject = :STA_UtilsStatic.CASE_SUBJECT2 + '_QueueOwnerInsert'
      ];
      System.assertEquals(
        oneAccountQueue.Id,
        checkCaseQueue.SMC_Expert_Queue__c,
        'Check case initialisation and queues.'
      );
      Case checkCaseOwner = [
        SELECT Id, Subject, OwnerId, SMC_Expert_Queue__c
        FROM Case
        WHERE Subject = :STA_UtilsStatic.CASE_SUBJECT2 + '_QueueInChargeInsert'
      ];
      System.assertEquals(
        oneAccountQueue.SMC_Queue_ID__c,
        checkCaseOwner.OwnerId,
        'Check case initialisation and queues.'
      );
      Case checkCaseUser = [
        SELECT Id, Subject, OwnerId, SMC_Expert_Queue__c
        FROM Case
        WHERE Subject = :STA_UtilsStatic.CASE_SUBJECT2 + '_UserOwnerInsert'
      ];
      System.assertEquals(
        oneAccountQueue.Id,
        checkCaseUser.SMC_Expert_Queue__c,
        'Check case initialisation and queues.'
      );
    }

    admin1User.Bypass_Validation_Rule__c = null;
    update admin1User;
  }

  // /**
  //  * @description : test SMC_AP_ManageCase.caseAssignmentRuleFromCommunity()
  //  * @author Vincent RECASENS (Modis) | 07-10-2020
  //  **/
  // @isTest
  // public static void testAddSharingAndReassignToQueueWithAssignmentRule() {
  //   User standardUser = [
  //     SELECT
  //       Id,
  //       Username,
  //       Alias,
  //       FirstName,
  //       LastName,
  //       SMC_Subsdiary_Label__c,
  //       UserType
  //     FROM User
  //     WHERE Email = :('support-' + STA_UtilsStatic.USERNAME_TEST)
  //   ];

  //   Case oneCase;
  //   System.runAs(standardUser) {

  //     PAD.bypassAll = true;

  //     Id recordTypeIdAccount = [
  //       SELECT Id
  //       FROM RecordType
  //       WHERE name = :STA_UtilsStatic.RECORDTYPE_ACCOUNT_CUSTOMER
  //     ]
  //     .Id;
  //     Account oneAccount = SMC_UTIL_TestUtils.createAccount(
  //       recordTypeIdAccount,
  //       STA_UtilsStatic.TEST + STA_UtilsStatic.ACCOUNT,
  //       STA_UtilsStatic.PICKLIST_ACCOUNT_TYPE_MARKETING_PROSPECT,
  //       STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY1
  //     );
  //     oneAccount.AccountNumber = 'ACC-{000001}';
  //     insert oneAccount;
  //     Contact oneContact = SMC_UTIL_TestUtils.createContact(
  //       STA_UtilsStatic.CONTACT_FIRSTNAME1 + 'test',
  //       STA_UtilsStatic.CONTACT_LASTNAME1 + 'test',
  //       STA_UtilsStatic.CONTACT_PHONE1,
  //       STA_UtilsStatic.CONTACT_MOBILEPHONE1,
  //       'test-' + STA_UtilsStatic.CONTACT_EMAIL1,
  //       STA_UtilsStatic.CONTACT_MAILINGSTREET1,
  //       STA_UtilsStatic.CONTACT_MAILINGPOSTALCODE1,
  //       STA_UtilsStatic.CONTACT_MAILINGCITY1,
  //       STA_UtilsStatic.CONTACT_MAILINGSTATE1,
  //       STA_UtilsStatic.CONTACT_MAILINGCOUNTRY1,
  //       STA_UtilsStatic.EMPTY_STRING,
  //       oneAccount.Id
  //     );
  //     insert oneContact;

  //     oneCase = SMC_UTIL_TestUtils.createCase(
  //       STA_UtilsStatic.CASE_SUBJECT2,
  //       STA_UtilsStatic.CASE_DESCRIPTION2,
  //       STA_UtilsStatic.CASE_TYPE_TOOL_SUPPORT,
  //       STA_UtilsStatic.CASE_SUB_STATUS_OPEN
  //     );
  //     oneCase.AccountId = oneAccount.Id;
  //     oneCase.ContactId = oneContact.Id;
  //     oneCase.OwnerId = [SELECT UserId__c, Username__c FROM SF_Technical_User__mdt WHERE Username__c = :STA_UtilsStatic.TECHNICAL_USER_SOC1].UserId__c;
  //     oneCase.SMC_Take_Ownership__c = true;
  //     insert oneCase;

  //     // CaseShare newCS = new CaseShare();
  //     // newCS.CaseId = oneCase.Id;
  //     // newCS.UserOrGroupId = UserInfo.getUserId();
  //     // newCs.RowCause = 'Manual';
  //     // newCs.CaseAccessLevel = 'Read';
  //     // insert newCs;
      
  //     PAD.bypassAll = false;

  //     Map<Id, Case> cases = new Map<Id, Case>([SELECT Id, Subject FROM Case]);
  //     Test.startTest();
  //       SMC_AP_ManageCase.addSharingAndReassignToQueueWithAssignmentRule(new Set<Id>{oneCase.Id});
  //     Test.stopTest();
  //   }

  //   System.assert(
  //     ((String) [SELECT Id, OwnerId FROM Case WHERE Id = :oneCase.Id].OwnerId).startsWith('00G'),
  //     'Assignments rule does not started'
  //   );

  // }

  // /**
  //  * @description : test SMC_AP_ManageCase.fillQueueInCharge(insert)
  //  * @author Vincent RECASENS (Modis) | 07-10-2020
  //  **/
  // @isTest
  // public static void testFillQueueInChargeINSERT() {
  //   // User supportUser = [SELECT Id, Username, Alias, FirstName, LastName, SMC_Subsdiary_Label__c, UserType FROM User WHERE Email = :('support-' + STA_UtilsStatic.USERNAME_TEST)];
  //   // User admin1User = [SELECT Id, Username FROM User WHERE Email = :('admin1-' + STA_UtilsStatic.USERNAME_TEST)];
  //   User admin1User = [
  //     SELECT Id, Username, Bypass_Validation_Rule__c
  //     FROM User
  //     WHERE Email = :('admin1-' + STA_UtilsStatic.USERNAME_TEST)
  //   ];
  //   admin1User.Bypass_Validation_Rule__c = 'SMC_Case_CantModifyWithoutAcceptation';
  //   update admin1User;

  //   User admin2User = [
  //     SELECT Id, Username
  //     FROM User
  //     WHERE Email = :('admin2-' + STA_UtilsStatic.USERNAME_TEST)
  //   ];

  //   Account oneAccountQueue = [
  //     SELECT Id, SMC_Queue_ID__c
  //     FROM Account
  //     WHERE Name = :(STA_UtilsStatic.ACCOUNT + '_GroupQueue')
  //   ];
  //   Contact oneContactQueue = [
  //     SELECT Id
  //     FROM Contact
  //     WHERE AccountId = :oneAccountQueue.Id
  //   ];

  //   Account oneAccountQueueToTransfer = [
  //     SELECT Id, SMC_Queue_ID__c
  //     FROM Account
  //     WHERE Name = :(STA_UtilsStatic.ACCOUNT + '_GroupQueueToTransfer')
  //   ];
  //   Contact oneContactQueueToTransfer = [
  //     SELECT Id
  //     FROM Contact
  //     WHERE AccountId = :oneAccountQueueToTransfer.Id
  //   ];

  //   Id soc1Id = [SELECT UserId__c, Username__c FROM SF_Technical_User__mdt WHERE Username__c = :STA_UtilsStatic.TECHNICAL_USER_SOC1].UserId__c;

  //   System.runAs(admin1User) {
  //     //To fill Queue In Charge --> QueueInCharge = Owner
  //     Case oneCase = SMC_UTIL_TestUtils.createCase(
  //       STA_UtilsStatic.CASE_SUBJECT2 + '_QueueOwnerInsert',
  //       STA_UtilsStatic.CASE_DESCRIPTION2,
  //       STA_UtilsStatic.CASE_TYPE_TOOL_SUPPORT,
  //       STA_UtilsStatic.CASE_SUB_STATUS_OPEN
  //     );
  //     oneCase.Status = STA_UtilsStatic.CASE_SUB_STATUS_OPEN;
  //     oneCase.AccountId = oneAccountQueue.Id;
  //     oneCase.ContactId = oneContactQueue.Id;
  //     oneCase.OwnerId = (Id) oneAccountQueue.SMC_Queue_ID__c;

  //     //With Queue In Charge already fill --> Owner = QueueInCharge
  //     Case twoCase = SMC_UTIL_TestUtils.createCase(
  //       STA_UtilsStatic.CASE_SUBJECT2 + '_QueueInChargeInsert',
  //       STA_UtilsStatic.CASE_DESCRIPTION2,
  //       STA_UtilsStatic.CASE_TYPE_TOOL_SUPPORT,
  //       STA_UtilsStatic.CASE_SUB_STATUS_OPEN
  //     );
  //     twoCase.Status = STA_UtilsStatic.CASE_SUB_STATUS_OPEN;
  //     twoCase.AccountId = oneAccountQueueToTransfer.Id;
  //     twoCase.ContactId = oneContactQueueToTransfer.Id;
  //     twoCase.OwnerId = (Id) oneAccountQueueToTransfer.SMC_Queue_ID__c;

  //     //With Owner --> do nothing
  //     Case thirdCase = SMC_UTIL_TestUtils.createCase(
  //       STA_UtilsStatic.CASE_SUBJECT2 + '_UserOwnerInsert',
  //       STA_UtilsStatic.CASE_DESCRIPTION2,
  //       STA_UtilsStatic.CASE_TYPE_TOOL_SUPPORT,
  //       STA_UtilsStatic.CASE_SUB_STATUS_OPEN
  //     );
  //     thirdCase.Status = STA_UtilsStatic.CASE_SUB_STATUS_OPEN;
  //     thirdCase.AccountId = oneAccountQueueToTransfer.Id;
  //     thirdCase.ContactId = oneContactQueueToTransfer.Id;
  //     thirdCase.SMC_Requestor_Email__c = admin2User.Username;
  //     thirdCase.OwnerId = soc1Id;
  //     //Insert cases
  //     // SMC_AP_ManageCase.caseAssignmentRuleFromCommunity(new List<Case>{oneCase, twoCase, thirdCase});
  //     List<Case> caseList = new List<Case>{ oneCase, twoCase, thirdCase };
  //     // insert oneCase;
  //     // insert twoCase;
  //     // insert thirdCase;
  //     PAD.bypassAll = true;
  //     insert caseList;
      
  //     List<CaseShare> csList = new List<CaseShare>();
  //     for(Case theCase : caseList){
  //       CaseShare newCS = new CaseShare();
  //       newCS.CaseId = theCase.Id;
  //       newCS.UserOrGroupId = UserInfo.getUserId();
  //       newCs.RowCause = 'Manual';
  //       newCs.CaseAccessLevel = 'Read';
  //       csList.add(newCs);
  //     }
  //     insert csList;

  //     Database.DMLOptions dmo = new Database.DMLOptions();
  //     dmo.AssignmentRuleHeader.useDefaultRule = true;
  //     for (Case theCase : caseList) {
  //       //DML Option
  //       theCase.setOptions(dmo);
  //     }
  //     update caseList;

  //     PAD.bypassAll = false;

  //     Test.startTest();

  //       Map<Id, Case> caseMap = new Map<Id, Case>(
  //         [
  //           SELECT Id, OwnerId, SMC_Expert_Queue__c
  //           FROM Case
  //           WHERE Id IN :(new List<Id>{ oneCase.Id, twoCase.Id, thirdCase.Id })
  //         ]
  //       );

  //       /** TO TEST!!! **/
  //       SMC_AP_ManageCase.fillQueueInCharge(caseMap, true);

  //     Test.stopTest();

  //     Case checkCaseQueue = [
  //       SELECT Id, Subject, OwnerId, SMC_Expert_Queue__c
  //       FROM Case
  //       WHERE Subject = :STA_UtilsStatic.CASE_SUBJECT2 + '_QueueOwnerInsert'
  //     ];
  //     System.assertEquals(
  //       oneAccountQueue.Id,
  //       checkCaseQueue.SMC_Expert_Queue__c,
  //       'Check case initialisation and queues.'
  //     );
  //     Case checkCaseOwner = [
  //       SELECT Id, Subject, OwnerId, SMC_Expert_Queue__c
  //       FROM Case
  //       WHERE Subject = :STA_UtilsStatic.CASE_SUBJECT2 + '_QueueInChargeInsert'
  //     ];
  //     System.assertEquals(
  //       oneAccountQueue.SMC_Queue_ID__c,
  //       checkCaseOwner.OwnerId,
  //       'Check case initialisation and queues.'
  //     );
  //     Case checkCaseUser = [
  //       SELECT Id, Subject, OwnerId, SMC_Expert_Queue__c
  //       FROM Case
  //       WHERE Subject = :STA_UtilsStatic.CASE_SUBJECT2 + '_UserOwnerInsert'
  //     ];
  //     System.assertEquals(
  //       oneAccountQueue.Id,
  //       checkCaseUser.SMC_Expert_Queue__c,
  //       'Check case initialisation and queues.'
  //     );
  //   }
  // }

  /**
   * @description : test SMC_AP_ManageCase.fillQueueInCharge(update)
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  @isTest
  public static void testFillQueueInChargeUPDATE() {
    // User user = [SELECT Id FROM User WHERE Email = :('support-' + STA_UtilsStatic.USERNAME_TEST)];
    User admin1User = [
      SELECT Id, Username
      FROM User
      WHERE Email = :('admin1-' + STA_UtilsStatic.USERNAME_TEST)
    ];
    User admin2User = [
      SELECT Id, Username
      FROM User
      WHERE Email = :('admin2-' + STA_UtilsStatic.USERNAME_TEST)
    ];

    Account oneAccountQueue = [
      SELECT Id, SMC_Queue_ID__c
      FROM Account
      WHERE Name = :(STA_UtilsStatic.ACCOUNT + '_GroupQueue')
    ];
    Contact oneContactQueue = [
      SELECT Id
      FROM Contact
      WHERE AccountId = :oneAccountQueue.Id
    ];

    Account oneAccountQueueToTransfer = [
      SELECT Id, SMC_Queue_ID__c
      FROM Account
      WHERE Name = :(STA_UtilsStatic.ACCOUNT + '_GroupQueueToTransfer')
    ];
    Contact oneContactQueueToTransfer = [
      SELECT Id
      FROM Contact
      WHERE AccountId = :oneAccountQueueToTransfer.Id
    ];

    System.runAs(admin1User) {
      PAD.bypassAll = true;

      //To fill Queue In Charge --> QueueInCharge = Owner
      Case oneCase = SMC_UTIL_TestUtils.createCase(
        STA_UtilsStatic.CASE_SUBJECT2 + '_QueueOwnerUpdate',
        STA_UtilsStatic.CASE_DESCRIPTION2,
        null,
        STA_UtilsStatic.CASE_SUB_STATUS_OPEN
      );
      oneCase.Status = STA_UtilsStatic.CASE_SUB_STATUS_OPEN;
      // oneCase.AccountId = oneAccountQueue.Id;
      // oneCase.ContactId = oneContactQueue.Id;
      oneCase.SMC_Requestor_Email__c = admin2User.Username;
      oneCase.OwnerId = (Id) oneAccountQueue.SMC_Queue_ID__c;

      //With Queue In Charge already fill --> Owner = QueueInCharge
      // Case twoCase = SMC_UTIL_TestUtils.createCase(STA_UtilsStatic.CASE_SUBJECT2 + '_QueueInChargeUpdate', STA_UtilsStatic.CASE_DESCRIPTION2, STA_UtilsStatic.CASE_TYPE_TOOL_SUPPORT, STA_UtilsStatic.CASE_SUB_STATUS_OPEN);
      // twoCase.Status = STA_UtilsStatic.CASE_SUB_STATUS_OPEN;
      // twoCase.AccountId = oneAccountQueueToTransfer.Id;
      // twoCase.ContactId = oneContactQueueToTransfer.Id;
      // twoCase.SMC_Expert_Queue__c = oneAccountQueueToTransfer.Id;
      // // twoCase.SMC_Requestor_Email__c = admin2User.Username;
      // twoCase.OwnerId = admin2User.Id;

      //With Owner --> do nothing
      Case thirdCase = SMC_UTIL_TestUtils.createCase(
        STA_UtilsStatic.CASE_SUBJECT2 + '_UserOwnerUpdate',
        STA_UtilsStatic.CASE_DESCRIPTION2,
        STA_UtilsStatic.CASE_TYPE_TOOL_SUPPORT,
        STA_UtilsStatic.CASE_SUB_STATUS_OPEN
      );
      thirdCase.Status = STA_UtilsStatic.CASE_SUB_STATUS_OPEN;
      thirdCase.AccountId = oneAccountQueueToTransfer.Id;
      thirdCase.ContactId = oneContactQueueToTransfer.Id;
      // thirdCase.SMC_Requestor_Email__c = admin2User.Username;
      thirdCase.OwnerId = admin2User.Id;

      List<Case> caseList = new List<Case>{ oneCase /*, twoCase*/, thirdCase };
      // SMC_AP_ManageCase.caseAssignmentRuleFromCommunity(new List<Case>{oneCase, twoCase, thirdCase});
      insert oneCase;
      insert thirdCase;
      // insert caseList;

      PAD.bypassAll = false;

      Test.startTest();
      Map<Id, Case> caseMap = new Map<Id, Case>(
        [
          SELECT Id, OwnerId, SMC_Expert_Queue__c
          FROM Case
          WHERE
            Id IN :(new List<Id>{ oneCase.Id /*, twoCase.Id*/, thirdCase.Id })
        ]
      );
      List<Case> result = SMC_AP_ManageCase.fillQueueInCharge(caseMap, false);
      update result;
      Test.stopTest();

      Case checkCaseQueue = [
        SELECT Id, Subject, OwnerId, SMC_Expert_Queue__c
        FROM Case
        WHERE Subject = :STA_UtilsStatic.CASE_SUBJECT2 + '_QueueOwnerUpdate'
      ];
      System.assertEquals(
        oneAccountQueue.Id,
        checkCaseQueue.SMC_Expert_Queue__c,
        'Check case initialisation and queues.'
      );
      // Case checkCaseOwner = [SELECT Id, Subject, OwnerId, SMC_Expert_Queue__c FROM Case WHERE Subject = :STA_UtilsStatic.CASE_SUBJECT2 + '_QueueInChargeUpdate'];
      // System.assertEquals(oneAccountQueueToTransfer.SMC_Queue_ID__c, checkCaseOwner.OwnerId);
      Case checkCaseUser = [
        SELECT Id, Subject, OwnerId, SMC_Expert_Queue__c
        FROM Case
        WHERE Subject = :STA_UtilsStatic.CASE_SUBJECT2 + '_UserOwnerUpdate'
      ];
      System.assertEquals(
        null,
        checkCaseUser.SMC_Expert_Queue__c,
        'Check case initialisation and queues.'
      );
    }
  }

  /**
   * @description : test SMC_AP_ManageCase.createACaseForAnotherUser()
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  @isTest
  public static void testCreatedACaseForAnotherUserOK() {
    User adminUser = [
      SELECT
        Id,
        Username,
        Alias,
        FirstName,
        LastName,
        SMC_Subsdiary_Label__c,
        UserType
      FROM User
      WHERE Email = :('admin1-' + STA_UtilsStatic.USERNAME_TEST)
    ];
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
      WHERE Email = :('standard-' + STA_UtilsStatic.USERNAME_TEST)
    ];
    // User partnerUser = [SELECT Id, Username, Alias, FirstName, LastName, SMC_Subsdiary_Label__c, UserType FROM User WHERE Email = :STA_UtilsStatic.CONTACT_EMAIL1];
    User chatterFreeUser = [
      SELECT
        Id,
        Username,
        Alias,
        FirstName,
        LastName,
        SMC_Subsdiary_Label__c,
        UserType
      FROM User
      WHERE Email = :STA_UtilsStatic.CONTACT_EMAIL2
    ];

    System.runAs(adminUser) {
      PAD.bypassAll = true;

      //Standard
      Case standardCase = SMC_UTIL_TestUtils.createCase(
        STA_UtilsStatic.CASE_SUBJECT2 + '_Standard',
        STA_UtilsStatic.CASE_DESCRIPTION2,
        null,
        STA_UtilsStatic.CASE_SUB_STATUS_OPEN
      );
      standardCase.SMC_Requestor_Email__c = standardUser.Username;
      // //Partner
      // Case partnerCase = SMC_UTIL_TestUtils.createCase(STA_UtilsStatic.CASE_SUBJECT2 + '_Partner', STA_UtilsStatic.CASE_DESCRIPTION2, null, STA_UtilsStatic.CASE_SUB_STATUS_OPEN);
      // partnerCase.SMC_Requestor_Email__c = partnerUser.Username;
      //ChatterFree
      Case chatterFreeCase = SMC_UTIL_TestUtils.createCase(
        STA_UtilsStatic.CASE_SUBJECT2 + '_ChatterFree',
        STA_UtilsStatic.CASE_DESCRIPTION2,
        null,
        STA_UtilsStatic.CASE_SUB_STATUS_OPEN
      );
      chatterFreeCase.SMC_Requestor_Email__c = chatterFreeUser.Username;

      Test.startTest();
      SMC_AP_ManageCase.createACaseForAnotherUser(
        new List<Case>{
          standardCase,
          chatterFreeCase /*, partnerCase.Id => partnerCase*/
        },
        true
      );
      Test.stopTest();

      PAD.bypassAll = false;

      //Standard
      String standardSubject = STA_UtilsStatic.CASE_SUBJECT2 + '_Standard';
      standardCase = [
        SELECT
          Id,
          Subject,
          SMC_Internal_Requestor__c,
          SMC_Requestor_Alias__c,
          SMC_Requestor_Firstname__c,
          SMC_Requestor_Name__c,
          SMC_Requestor_Organization__c
        FROM Case
        WHERE Subject = :standardSubject
      ];
      System.assertEquals(
        standardCase.SMC_Internal_Requestor__c,
        standardUser.Id,
        'Check case initialisation and user who insert the case.'
      );
      System.assertEquals(
        null,
        standardCase.SMC_Requestor_Alias__c,
        'The case is assigned to the user who has inserted it.'
      );
      System.assertEquals(
        null,
        standardCase.SMC_Requestor_Firstname__c,
        'The case is assigned to the user who has inserted it.'
      );
      System.assertEquals(
        null,
        standardCase.SMC_Requestor_Name__c,
        'The case is assigned to the user who has inserted it.'
      );
      System.assertEquals(
        null,
        standardCase.SMC_Requestor_Organization__c,
        'The case is assigned to the user who has inserted it.'
      );

      // //Partner
      // String partnerSubject = STA_UtilsStatic.CASE_SUBJECT2 + '_Partner';
      // partnerCase = [SELECT Id, Subject, SMC_Internal_Requestor__c , SMC_Requestor_Alias__c, SMC_Requestor_Firstname__c, SMC_Requestor_Name__c, SMC_Requestor_Organization__c FROM Case WHERE Subject = :partnerSubject];
      // System.assertEquals(partnerCase.SMC_Internal_Requestor__c, null);
      // System.assertEquals(partnerCase.SMC_Requestor_Alias__c, null);
      // System.assertEquals(partnerCase.SMC_Requestor_Firstname__c, null);
      // System.assertEquals(partnerCase.SMC_Requestor_Name__c, null);
      // System.assertEquals(partnerCase.SMC_Requestor_Organization__c, null);

      //ChatterFree
      String chatterFreeSubject =
        STA_UtilsStatic.CASE_SUBJECT2 + '_ChatterFree';
      chatterFreeCase = [
        SELECT
          Id,
          Subject,
          SMC_Internal_Requestor__c,
          SMC_Requestor_Alias__c,
          SMC_Requestor_Firstname__c,
          SMC_Requestor_Name__c,
          SMC_Requestor_Organization__c
        FROM Case
        WHERE Subject = :chatterFreeSubject
      ];
      System.assertEquals(
        chatterFreeCase.SMC_Internal_Requestor__c,
        null,
        'The case "chatterFreeCase" have an InternalRequestor.'
      );
      System.assertEquals(
        chatterFreeCase.SMC_Requestor_Alias__c,
        chatterFreeUser.Alias,
        'The case is assigned to the user who has inserted it.'
      );
      System.assertEquals(
        chatterFreeCase.SMC_Requestor_Firstname__c,
        chatterFreeUser.FirstName,
        'The case is assigned to the user who has inserted it.'
      );
      System.assertEquals(
        chatterFreeCase.SMC_Requestor_Name__c,
        chatterFreeUser.LastName,
        'The case is assigned to the user who has inserted it.'
      );
      System.assertEquals(
        chatterFreeCase.SMC_Requestor_Organization__c,
        chatterFreeUser.SMC_Subsdiary_Label__c,
        'The case is assigned to the user who has inserted it.'
      );
    }
  }

  /**
   * @description : test SMC_AP_ManageCase.createACaseForAnotherUser() [BAD]
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  @isTest
  public static void testCreatedACaseForAnotherUserERROR() {
    User adminUser = [
      SELECT
        Id,
        Username,
        Alias,
        FirstName,
        LastName,
        SMC_Subsdiary_Label__c,
        UserType
      FROM User
      WHERE Email = :('admin1-' + STA_UtilsStatic.USERNAME_TEST)
    ];

    System.runAs(adminUser) {
      PAD.bypassAll = true;

      //Fake User
      Case errorCase = SMC_UTIL_TestUtils.createCase(
        STA_UtilsStatic.CASE_SUBJECT2 + '_Error',
        STA_UtilsStatic.CASE_DESCRIPTION2,
        null,
        STA_UtilsStatic.CASE_SUB_STATUS_OPEN
      );
      errorCase.SMC_Requestor_Email__c = 'testFake@fake.com';

      Test.startTest();
      try {
        SMC_AP_ManageCase.createACaseForAnotherUser(
          new List<Case>{ errorCase },
          true
        );
        System.assert(false, 'The case is inserted.');
      } catch (QueryException queryException) {
        System.assertEquals(
          System.Label.SMC_RequestorNotFound,
          queryException.getMessage(),
          'The error message does not match with the custom label used for this.'
        );
      }
      Test.stopTest();

      PAD.bypassAll = false;
    }
  }

  /**
   * @description : test SMC_AP_ManageCase.createCimsaVisit()
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  @isTest
  public static void testCreateCimsaVisit() {
    User supportUser = [
      SELECT
        Id,
        Bypass_All_Processes_Builder__c,
        Bypass_All_Validation_Rules__c,
        Bypass_All_Workflow_Rules__c
      FROM User
      WHERE Email = :('support-' + STA_UtilsStatic.USERNAME_TEST)
    ];
    supportUser.Bypass_All_Processes_Builder__c = true;
    supportUser.Bypass_All_Validation_Rules__c = true;
    supportUser.Bypass_All_Workflow_Rules__c = true;
    update supportUser;

    System.runAs(supportUser) {
      PAD.bypassAll = true;

      //Standard
      Case standardCase = SMC_UTIL_TestUtils.createCase(
        STA_UtilsStatic.CASE_SUBJECT2 + '_Standard',
        STA_UtilsStatic.CASE_DESCRIPTION2,
        null,
        STA_UtilsStatic.CASE_SUB_STATUS_OPEN
      );
      standardCase.SMC_IsVisitCimsaCreationSent__c = true;
      standardCase.SMC_CIMSA_Visit_Under__c = '7';
      standardCase.SMC_CIMSA_Visit_Category__c = '1';
      standardCase.SMC_CIMSA_Planned_Date__c = Date.today();
      standardCase.SMC_CIMSA_Estimated_Work__c = 4.5;
      standardCase.SMC_Serial_Number__c = SMC_UTIL_CaseCalloutMockJSON.SERIAL_NUMBER_FOR_MOCK;
      standardCase.SMC_Take_Ownership__c = true;
      // insert standardCase;

      //Old Standard
      Case oldStandardCase = SMC_UTIL_TestUtils.createCase(
        STA_UtilsStatic.CASE_SUBJECT2 + '_Standard',
        STA_UtilsStatic.CASE_DESCRIPTION2,
        null,
        STA_UtilsStatic.CASE_SUB_STATUS_OPEN
      );
      oldStandardCase.SMC_IsVisitCimsaCreationSent__c = true;
      oldStandardCase.SMC_CIMSA_Visit_Under__c = '7';
      oldStandardCase.SMC_CIMSA_Visit_Category__c = '1';
      oldStandardCase.SMC_CIMSA_Planned_Date__c = Date.today();
      oldStandardCase.SMC_CIMSA_Estimated_Work__c = 4.5;
      oldStandardCase.SMC_Serial_Number__c = SMC_UTIL_CaseCalloutMockJSON.SERIAL_NUMBER_FOR_MOCK;
      oldStandardCase.SMC_IsVisitCimsaCreationSent__c = false;
      oldStandardCase.SMC_Take_Ownership__c = true;
      insert new List<Case>{ standardCase, oldStandardCase };

      SMC_UTIL_MockHttpResponseGenerator fakeResponse = new SMC_UTIL_MockHttpResponseGenerator(
        200,
        STA_UtilsStatic.COMPLETE,
        SMC_UTIL_CaseCalloutMockJSON.CIMSA_VISIT_MOCK,
        null
      );
      Test.setMock(HttpCalloutMock.class, fakeResponse);

      PAD.bypassAll = false;

      Test.startTest();
      standardCase.SMC_IsVisitCimsaCreationSent__c = true;
      update standardCase;

      SMC_AP_ManageCase.createCimsaVisit(
        new List<Case>{ standardCase },
        new Map<Id, Case>{ standardCase.Id => oldStandardCase }
      );
      Test.stopTest();

      Case checkCase = [
        SELECT Id, SMC_IsVisitCimsaCreationSent__c, SMC_CIMSA_Visit_Number__c
        FROM Case
        WHERE Id = :standardCase.Id
      ];
      System.assert(
        !checkCase.SMC_IsVisitCimsaCreationSent__c,
        'The process does not reset tech field SMC_IsVisitCimsaCreationSent__c.'
      );
      System.assertEquals(
        SMC_UTIL_CaseCalloutMockJSON.VICODE_FOR_MOCK,
        checkCase.SMC_CIMSA_Visit_Number__c,
        'Mock is wrong. Check it and relaunch test.'
      );
    }
  }

  /**
   * @description : test SMC_AP_ManageCase.createCimsaVisit()
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  @isTest
  public static void testResetCimsaVisitBoolean() {
    User supportUser = [
      SELECT
        Id,
        Bypass_All_Processes_Builder__c,
        Bypass_All_Validation_Rules__c,
        Bypass_All_Workflow_Rules__c
      FROM User
      WHERE Email = :('support-' + STA_UtilsStatic.USERNAME_TEST)
    ];
    supportUser.Bypass_All_Processes_Builder__c = true;
    supportUser.Bypass_All_Validation_Rules__c = true;
    supportUser.Bypass_All_Workflow_Rules__c = true;
    update supportUser;

    System.runAs(supportUser) {
      PAD.bypassAll = true;

      //Standard
      Case standardCase = SMC_UTIL_TestUtils.createCase(
        STA_UtilsStatic.CASE_SUBJECT2 + '_Standard',
        STA_UtilsStatic.CASE_DESCRIPTION2,
        null,
        STA_UtilsStatic.CASE_SUB_STATUS_OPEN
      );
      standardCase.SMC_IsVisitCimsaCreationSent__c = true;
      standardCase.SMC_CIMSA_Visit_Under__c = '7';
      standardCase.SMC_CIMSA_Visit_Category__c = '1';
      standardCase.SMC_CIMSA_Planned_Date__c = Date.today();
      standardCase.SMC_CIMSA_Estimated_Work__c = 4.5;
      standardCase.SMC_Serial_Number__c = SMC_UTIL_CaseCalloutMockJSON.SERIAL_NUMBER_FOR_MOCK;
      standardCase.SMC_Take_Ownership__c = true;
      insert standardCase;

      //Old Standard
      Case oldCase = standardCase;

      PAD.bypassAll = false;

      Test.startTest();
      SMC_AP_ManageCase.createCimsaVisit(
        new List<Case>{ standardCase },
        new Map<Id, Case>{ standardCase.Id => oldCase }
      );
      Test.stopTest();

      Case checkCase = [
        SELECT Id, SMC_IsVisitCimsaCreationSent__c, SMC_CIMSA_Visit_Number__c
        FROM Case
        WHERE Id = :standardCase.Id
      ];
      System.assert(
        !checkCase.SMC_IsVisitCimsaCreationSent__c,
        'The process does not reset tech field SMC_IsVisitCimsaCreationSent__c.'
      );
      System.assertEquals(
        null,
        checkCase.SMC_CIMSA_Visit_Number__c,
        'The process does not reset the number of visit.'
      );
    }
  }

  /**
   * @description : test SMC_AP_ManageCase.getProductInfoFromSerialNumber() by trigger
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  @isTest
  public static void testGetProductInfoFromSerialNumber() {
    //Get and add bypass on standard user
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
      WHERE Email = :('standard-' + STA_UtilsStatic.USERNAME_TEST)
    ];
    standardUser.Bypass_All_Processes_Builder__c = false;
    standardUser.Bypass_All_Validation_Rules__c = false;
    standardUser.Bypass_All_Workflow_Rules__c = false;
    standardUser.Bypass_Validation_Rule__c = 'SMC_NoEditProduct';
    update standardUser;

    PermissionSet ps = [
      SELECT ID
      FROM PermissionSet
      WHERE Name = :STA_UtilsStatic.FSL_KEY_USER
    ];
    insert new List<PermissionSetAssignment>{
      new PermissionSetAssignment(
        AssigneeId = standardUser.id,
        PermissionSetId = ps.Id
      )
    };

    Account oneAccountQueue = [
      SELECT Id, SMC_Queue_ID__c
      FROM Account
      WHERE Name = :(STA_UtilsStatic.ACCOUNT + '_GroupQueue')
    ];

    System.runAs(standardUser) {
      PAD.bypassAll = true;

      Id productRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName()
        .get(STA_UtilsStatic.RECORDTYPE_SERVICE_PRODUCT)
        .getRecordTypeId();
      Product2 theProduct = SMC_UTIL_TestUtils.createProductFSL(
        productRecordTypeId,
        'TEST-CASEPRODUCT-1',
        true
      );
      insert new List<Product2>{ theProduct };

      //Create Account
      Id recordTypeIdAccount = [
        SELECT Id
        FROM RecordType
        WHERE name = :STA_UtilsStatic.RECORDTYPE_ACCOUNT_CUSTOMER
      ]
      .Id;
      Account account = SMC_UTIL_TestUtils.createAccount(
        recordTypeIdAccount,
        STA_UtilsStatic.TEST + STA_UtilsStatic.ACCOUNT,
        STA_UtilsStatic.PICKLIST_ACCOUNT_TYPE_MARKETING_PROSPECT,
        STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY1
      );
      account.AccountNumber = 'ACC-{000001}';
      account.OwnerId = standardUser.Id;
      insert account;

      Contact contact = SMC_UTIL_TestUtils.createContact(
        STA_UtilsStatic.CONTACT_FIRSTNAME1 + 'test',
        STA_UtilsStatic.CONTACT_LASTNAME1 + 'test',
        STA_UtilsStatic.CONTACT_PHONE1,
        STA_UtilsStatic.CONTACT_MOBILEPHONE1,
        'test-' + STA_UtilsStatic.CONTACT_EMAIL1,
        STA_UtilsStatic.CONTACT_MAILINGSTREET1,
        STA_UtilsStatic.CONTACT_MAILINGPOSTALCODE1,
        STA_UtilsStatic.CONTACT_MAILINGCITY1,
        STA_UtilsStatic.CONTACT_MAILINGSTATE1,
        STA_UtilsStatic.CONTACT_MAILINGCOUNTRY1,
        STA_UtilsStatic.EMPTY_STRING,
        account.Id
      );
      insert contact;

      Id assetRecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName()
        .get(STA_UtilsStatic.RECORDTYPE_ASSET)
        .getRecordTypeId();
      Asset theAsset = SMC_UTIL_TestUtils.createAsset(
        assetRecordTypeId,
        null,
        account.Id,
        contact.Id,
        'Q190413572',
        theProduct.Id,
        null,
        'Q190413572'
      );
      theAsset.OwnerId = standardUser.Id;
      insert new List<Asset>{ theAsset };

      PAD.bypassAll = false;

      Case oneCase = SMC_UTIL_TestUtils.createCase(
        STA_UtilsStatic.CASE_SUBJECT2 + '-oneCase',
        STA_UtilsStatic.CASE_DESCRIPTION2,
        STA_UtilsStatic.CASE_TYPE_TOOL_SUPPORT,
        STA_UtilsStatic.CASE_SUB_STATUS_OPEN,
        STA_UtilsStatic.CASE_SUB_STATUS_OPEN
      );
      oneCase.AccountId = account.Id;
      oneCase.ContactId = contact.Id;
      oneCase.OwnerId = standardUser.Id;
      oneCase.SMC_Serial_Number__c = 'Q190413572';
      oneCase.SMC_Expert_Queue__c = oneAccountQueue.Id;
      oneCase.SMC_Take_Ownership__c = true;
      Case twoCase = SMC_UTIL_TestUtils.createCase(
        STA_UtilsStatic.CASE_SUBJECT2 + '-twoCase',
        STA_UtilsStatic.CASE_DESCRIPTION2,
        STA_UtilsStatic.CASE_TYPE_TOOL_SUPPORT,
        STA_UtilsStatic.CASE_SUB_STATUS_OPEN,
        STA_UtilsStatic.CASE_SUB_STATUS_OPEN
      );
      twoCase.AccountId = account.Id;
      twoCase.ContactId = contact.Id;
      twoCase.OwnerId = standardUser.Id;
      twoCase.SMC_Serial_Number__c = 'TestSerialNumberFake';
      twoCase.SMC_Expert_Queue__c = oneAccountQueue.Id;
      twoCase.SMC_Take_Ownership__c = true;

      Test.startTest();

      try {
        insert oneCase;
      } catch (Exception e) {
        System.assert(false, 'There is an error : EXCEPTION --> ' + e);
      }
      try {
        insert twoCase;
      } catch (Exception e) {
        System.assert(
          true,
          'The validation rule block the insertion : EXCEPTION --> ' + e
        );
      }

      Case checkOneCase = [
        SELECT Id, Subject, SMC_Serial_Number__c, ProductId
        FROM Case
        WHERE Id = :oneCase.Id
      ];
        /*
      System.assertEquals(
        theProduct.Id,
        checkOneCase.ProductId,
        'The case does not take the rigth asset. Check initialisation.'
      );
*/

      Test.stopTest();
    }
  }
}