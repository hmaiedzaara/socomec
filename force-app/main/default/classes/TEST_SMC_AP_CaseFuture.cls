/*
---------------------------------------------------------------------------
-- - Name : TEST_SMC_AP_CaseFuture
-- - Author : Vincent RECASENS
-- - Description : This class is the test of SMC_AP_CaseFuture and SMC_AP_CaseFuture_WithoutSharing
--
-- Maintenance History:
--
-- Date         Name                    Version     Remarks
-- -----------  ----                    -------     ------------------
-- 16-NOV-2018  Vincent RECASENS  		1.0     	Initial Version
---------------------------------------------------------------------------
*/

@isTest
public without sharing class TEST_SMC_AP_CaseFuture {
  /**
   * @description : test SMC_AP_CaseFuture.updateCasesProductInfo()
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  @isTest
  public static void testUpdateCasesProductInfo() {
    System.debug(
      LoggingLevel.INFO,
      '>>>>>> TEST_SMC_AP_ManageCase - SMC_AP_CaseFutur : testUpdateCasesProductInfo - START'
    );

    PAD.bypassAll = true;
    Id profileId = [
        SELECT Id
        FROM Profile
        WHERE Name = :STA_UtilsStatic.PROFILE_SMC_ADMIN
        LIMIT 1
      ]
      .get(0)
      .Id;
    User user = SMC_UTIL_TestUtils.createUser(
      STA_UtilsStatic.TEST_DIESE,
      STA_UtilsStatic.EMAIL_TEST,
      profileId,
      STA_UtilsStatic.USERNAME_TEST,
      STA_UtilsStatic.USER_NICKNAME
    );
    user.Bypass_All_Processes_Builder__c = true;
    user.Bypass_Validation_Rule__c = 'SMC_Valid_Case_SerialNumber';
    insert user;
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
      // oneAccount.AccountNumber = 'ACC-{000001}';
      insert oneAccount;
      Contact oneContact = SMC_UTIL_TestUtils.createContact(
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
      oneCase.SMC_Serial_Number__c = SMC_UTIL_CaseCalloutMockJSON.SERIAL_NUMBER_FOR_MOCK;
      oneCase.OwnerId = user.Id;
      insert oneCase;

      SMC_UTIL_MockHttpResponseGenerator fakeResponse = new SMC_UTIL_MockHttpResponseGenerator(
        200,
        STA_UtilsStatic.COMPLETE,
        SMC_UTIL_CaseCalloutMockJSON.SN_PRODUCT_INFO,
        null
      );
      Test.setMock(HttpCalloutMock.class, fakeResponse);

      Test.startTest();
      SMC_AP_CaseFuture.updateCasesProductInfo(new Set<Id>{ oneCase.Id }, true);
      Test.stopTest();

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

    System.debug(
      LoggingLevel.INFO,
      '>>>>>> TEST_SMC_AP_ManageCase - SMC_AP_CaseFutur : testUpdateCasesProductInfo - END'
    );
  }

  /**
   * @description : test SMC_AP_CaseFuture_WithoutSharing.fillQueueInChargeAfterInsert()
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  @isTest
  public static void testCaseFuturWithoutSharingMethod() {
    System.debug(
      LoggingLevel.INFO,
      '>>>>>> TEST_SMC_AP_ManageCase : testFillQueueInCharge - START'
    );
    //Admin
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
    userAdmin1.Bypass_All_Processes_Builder__c = true;
    userAdmin1.Bypass_Validation_Rule__c = 'SMC_Case_CantModifyWithoutAcceptation';
    userAdmin1.Bypass_All_Workflow_Rules__c = true;
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
    insert new List<User>{ userAdmin1, userAdmin2, userSupport };

    Account accountQueue;
    Account accountQueueToTransfer;
    Group franceOSL;
    Group franceTOS;

    System.runAs(userAdmin1) {
      PAD.bypassAll = true;
      //Queue
      franceOSL = [
        SELECT Id, Name, Type
        FROM Group
        WHERE
          Type = :STA_UtilsStatic.QUEUE
          AND Name = :STA_UtilsStatic.ACCOUNT_QUEUE_FRANCE_OSL
      ];
      franceTOS = [
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
      accountQueue = SMC_UTIL_TestUtils.createAccount(
        recordTypeIdAccount,
        STA_UtilsStatic.ACCOUNT + '_GroupQueue',
        STA_UtilsStatic.PICKLIST_ACCOUNT_TYPE_MARKETING_PROSPECT,
        STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY1
      );
      accountQueue.SMC_Queue_ID__c = franceOSL.Id;
      accountQueue.OwnerId = userAdmin1.Id;
      accountQueueToTransfer = SMC_UTIL_TestUtils.createAccount(
        recordTypeIdAccount,
        STA_UtilsStatic.ACCOUNT + '_GroupQueueToTransfer',
        STA_UtilsStatic.PICKLIST_ACCOUNT_TYPE_MARKETING_PROSPECT,
        STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY1
      );
      accountQueueToTransfer.SMC_Queue_ID__c = franceTOS.Id;
      accountQueueToTransfer.OwnerId = userAdmin2.Id;
      insert new List<Account>{ accountQueue, accountQueueToTransfer };

      //To fill Queue In Charge --> QueueInCharge = Owner
      Case oneCase = SMC_UTIL_TestUtils.createCase(
        STA_UtilsStatic.CASE_SUBJECT2 + '_QueueOwner',
        STA_UtilsStatic.CASE_DESCRIPTION2,
        STA_UtilsStatic.CASE_TYPE_TOOL_SUPPORT,
        STA_UtilsStatic.CASE_SUB_STATUS_OPEN
      );
      oneCase.Status = STA_UtilsStatic.CASE_SUB_STATUS_OPEN;
      oneCase.OwnerId = franceOSL.Id;
      //With Queue In Charge already fill --> Owner = QueueInCharge
      Case twoCase = SMC_UTIL_TestUtils.createCase(
        STA_UtilsStatic.CASE_SUBJECT2 + '_QueueInCharge',
        STA_UtilsStatic.CASE_DESCRIPTION2,
        STA_UtilsStatic.CASE_TYPE_TOOL_SUPPORT,
        STA_UtilsStatic.CASE_SUB_STATUS_OPEN
      );
      twoCase.Status = STA_UtilsStatic.CASE_SUB_STATUS_OPEN;
      twoCase.SMC_Expert_Queue__c = accountQueueToTransfer.Id;
      //With Owner --> do nothing
      Case thirdCase = SMC_UTIL_TestUtils.createCase(
        STA_UtilsStatic.CASE_SUBJECT2 + '_UserOwner',
        STA_UtilsStatic.CASE_DESCRIPTION2,
        STA_UtilsStatic.CASE_TYPE_TOOL_SUPPORT,
        STA_UtilsStatic.CASE_SUB_STATUS_OPEN
      );
      thirdCase.Status = STA_UtilsStatic.CASE_SUB_STATUS_OPEN;
      thirdCase.OwnerId = userAdmin1.Id;
      //Insert cases
      List<Case> caseList = new List<Case>{ oneCase, twoCase, thirdCase };
      insert caseList;

      Test.startTest();
      Map<Id, Id> caseIdToQueueId = new Map<Id, Id>();
      for (Case theCase : caseList) {
        caseIdToQueueId.put(theCase.Id, theCase.SMC_Expert_Queue__c);
      }

      SMC_AP_CaseFuture_WithoutSharing.fillQueueInChargeAfterInsert(
        caseIdToQueueId
      );

      Test.stopTest();

      PAD.bypassAll = false;
    }

    Case checkCaseQueue = [
      SELECT Id, Subject, OwnerId, SMC_Expert_Queue__c
      FROM Case
      WHERE Subject = :STA_UtilsStatic.CASE_SUBJECT2 + '_QueueOwner'
    ];
    System.assertEquals(
      accountQueue.Id,
      checkCaseQueue.SMC_Expert_Queue__c,
      'Check account/queue intialisation.'
    );
    Case checkCaseOwner = [
      SELECT Id, Subject, OwnerId, SMC_Expert_Queue__c
      FROM Case
      WHERE Subject = :STA_UtilsStatic.CASE_SUBJECT2 + '_QueueInCharge'
    ];
    System.assertEquals(
      accountQueueToTransfer.SMC_Queue_ID__c,
      checkCaseOwner.OwnerId,
      'Check account/queue intialisation.'
    );
    Case checkCaseUser = [
      SELECT Id, Subject, OwnerId, SMC_Expert_Queue__c
      FROM Case
      WHERE Subject = :STA_UtilsStatic.CASE_SUBJECT2 + '_UserOwner'
    ];
    System.assertEquals(
      null,
      checkCaseUser.SMC_Expert_Queue__c,
      'Check account/queue intialisation.'
    );

    System.debug(
      LoggingLevel.INFO,
      '>>>>>> TEST_SMC_AP_ManageCase : testFillQueueInCharge - END'
    );
  }
}