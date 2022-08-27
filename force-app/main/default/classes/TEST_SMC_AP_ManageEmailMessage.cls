/*
---------------------------------------------------------------------------
-- - Name : TEST_SMC_AP_ManageEmailMessage
-- - Author : Vincent RECASENS
-- - Description : This class is the test of SMC_AP_ManageEmailMessage
--
-- Maintenance History:
--
-- Date         Name                    Version     Remarks
-- -----------  ----                    -------     ------------------
-- 31-JUL-2018  Vincent RECASENS  		1.0     	Initial Version
---------------------------------------------------------------------------
*/

@isTest
public without sharing class TEST_SMC_AP_ManageEmailMessage {
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
      STA_UtilsStatic.USERNAME_TEST,
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
    userAdmin1.Bypass_All_Validation_Rules__c = true;
    userAdmin1.Bypass_All_Workflow_Rules__c = true;
    insert new List<User>{ userAdmin1 };

    System.runAs(userAdmin1) {
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
      insert new List<User>{ userSupport };

      //Create Case
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
        '',
        oneAccount.Id
      );
      insert oneContact;
      Case firstCase = SMC_UTIL_TestUtils.createCase(
        STA_UtilsStatic.CASE_SUBJECT1,
        STA_UtilsStatic.CASE_DESCRIPTION1,
        STA_UtilsStatic.CASE_TYPE_TECHNICAL_SUPPORT,
        STA_UtilsStatic.CASE_SUB_STATUS_OPEN
      );
      firstCase.AccountId = oneAccount.Id;
      firstCase.ContactId = oneContact.Id;
      firstCase.OwnerId = userSupport.Id;
      insert firstCase;

      PAD.bypassAll = false;
    }
  }

  /**
  * @description : test SMC_AP_ManageEmailMessage.updateCaseNewEmailMessage() by trigger
  * @author Vincent RECASENS (Modis) | 07-10-2020 
  **/
  @isTest
  public static void testTriggerUpdateCaseNewEmailMessage() {
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
      WHERE Email = :(STA_UtilsStatic.USERNAME_TEST)
    ];
    User supportUser = [
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

    System.runAs(adminUser) {
      // //Check before insert EmailMessage
      Case caseCheckedBeforeEmail = [
        SELECT Id, SMC_New_Email_Flag__c
        FROM Case
        WHERE subject = :STA_UtilsStatic.CASE_SUBJECT1
      ];
      System.assert(
        !caseCheckedBeforeEmail.SMC_New_Email_Flag__c,
        'The case already has an email linked to it. Remove file insertion before this assert.'
      );

      /****** There is no Trigger on EmailMessage --> we will test only ManageCase with EMAIL static parameter ******/
      EmailMessage oneEmailMessage = SMC_UTIL_TestUtils.createEmailMessage(
        caseCheckedBeforeEmail.Id,
        STA_UtilsStatic.CASE_BODY,
        STA_UtilsStatic.CASE_SUBJECT1,
        UserInfo.getName(),
        UserInfo.getUserEmail(),
        UserInfo.getUserEmail(),
        STA_UtilsStatic.USERNAME_TEST
      );

      //Check insertion of EmailMessage
      System.assert(
        Database.insert(oneEmailMessage).isSuccess(),
        'EmailMessage is not inserted.'
      );

      //Check after insert EmailMessage
      Case caseCheckedAfterEmail = [
        SELECT Id, SMC_New_Email_Flag__c
        FROM Case
        WHERE Id = :caseCheckedBeforeEmail.Id
      ];
      System.assert(
        caseCheckedAfterEmail.SMC_New_Email_Flag__c,
        'The email is not linked to the case.'
      );
    }
  }

  /**
  * @description : test SMC_AP_ManageEmailMessage.updateCaseNewEmailMessage(OtherObject) by trigger
  * @author Vincent RECASENS (Modis) | 07-10-2020 
  **/
  @isTest
  public static void testUpdateCaseNewEmailMessageWithOtherObject() {
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
      WHERE Email = :(STA_UtilsStatic.USERNAME_TEST)
    ];
    User supportUser = [
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

    System.runAs(adminUser) {
      PAD.bypassAll = true;

      // //Check before insert EmailMessage
      Account oneAccount = [
        SELECT Id
        FROM Account
        WHERE Name = :(STA_UtilsStatic.TEST + STA_UtilsStatic.ACCOUNT)
      ];
      Boolean checkBefore = false;
      for (EmailMessage oneES : [SELECT Id, ParentId FROM EmailMessage]) {
        if (oneES.ParentId == oneAccount.Id) {
          checkBefore = true;
        }
      }
      System.assert(
        !checkBefore,
        'An email message is linked with another object than a case.'
      );

      /****** There is no Trigger on EmailMessage --> we will test only ManageCase with EMAIL static parameter ******/
      EmailMessage oneEmailMessage = SMC_UTIL_TestUtils.createEmailMessage(
        null,
        STA_UtilsStatic.CASE_BODY,
        STA_UtilsStatic.CASE_SUBJECT1,
        UserInfo.getName(),
        UserInfo.getUserEmail(),
        UserInfo.getUserEmail(),
        STA_UtilsStatic.USERNAME_TEST
      );
      oneEmailMessage.RelatedToId = oneAccount.Id;

      //Check insertion of EmailMessage
      System.assert(
        Database.insert(oneEmailMessage).isSuccess(),
        'The email is not inserted. Check initialisation of it.'
      );

      //Check insertion of EmailMessage
      System.assert(
        !SMC_AP_ManageEmailMessage.updateCaseNewEmailMessage(
          new List<EmailMessage>{ oneEmailMessage }
        ),
        'The email message is linked to a case, not to an account as expected.'
      );
    }
  }

  /**
  * @description : test SMC_AP_ManageEmailMessage.emailAttachmentNotVisibleByCommunityUsers() by trigger
  * @author Vincent RECASENS (Modis) | 07-10-2020 
  **/
  @isTest
  public static void testEmailAttachmentNotVisibleByCommunityUsers() {
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
      WHERE Email = :(STA_UtilsStatic.USERNAME_TEST)
    ];
    User supportUser = [
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

    System.runAs(adminUser) {
      PAD.bypassAll = true;

      Case caseEmail = [
        SELECT Id
        FROM Case
        WHERE subject = :STA_UtilsStatic.CASE_SUBJECT1
      ];

      EmailMessage oneEmailMessage = SMC_UTIL_TestUtils.createEmailMessage(
        caseEmail.Id,
        STA_UtilsStatic.CASE_BODY,
        STA_UtilsStatic.CASE_SUBJECT1,
        UserInfo.getName(),
        UserInfo.getUserEmail(),
        UserInfo.getUserEmail(),
        STA_UtilsStatic.USERNAME_TEST
      );
      oneEmailMessage.RelatedToId = caseEmail.Id;
      //Check insertion of EmailMessage
      System.assert(
        Database.insert(oneEmailMessage).isSuccess(),
        'The email is not inserted. Check initialisation of it.'
      );

      // PAD.bypassAll = false;

      ContentVersion contentVersion1 = new ContentVersion();
      contentVersion1.Title = 'Penguins1';
      contentVersion1.PathOnClient = 'Penguins1.jpg';
      contentVersion1.VersionData = Blob.valueOf('Test Content');
      contentVersion1.IsMajorVersion = true;
      contentVersion1.FirstPublishLocationId = oneEmailMessage.Id;
      contentVersion1.OwnerId = adminUser.Id;
      insert contentVersion1;

      Attachment formAttach = new Attachment();
      formAttach.Name = contentVersion1.PathOnClient;
      formAttach.Body = contentVersion1.VersionData;
      formAttach.ContentType = 'application/pdf';
      formAttach.ParentId = oneEmailMessage.Id;
      insert formAttach;

      oneEmailMessage = [
        SELECT Id, RelatedToId, HasAttachment
        FROM EmailMessage
        WHERE Id = :oneEmailMessage.Id
      ];
      Test.startTest();
      SMC_AP_ManageEmailMessage.emailAttachmentNotVisibleByCommunityUsers(
        new List<EmailMessage>{ oneEmailMessage }
      );
      Test.stopTest();

      System.assertNotEquals(
        null,
        [
          SELECT Id, Visibility, LinkedEntityId, ContentDocumentId
          FROM ContentDocumentLink
          WHERE LinkedEntityId = :oneEmailMessage.Id
        ],
        'There is no ContentDocumentLink visible. Check insertion of it.'
      );
      List<Id> contentDocumentIds = new List<Id>();
      for (ContentDocumentLink oneCdl : [
        SELECT Id, Visibility, LinkedEntityId, ContentDocumentId
        FROM ContentDocumentLink
        WHERE LinkedEntityId = :oneEmailMessage.Id
      ]) {
        if (oneCdl.LinkedEntityId.getSObjectType() != Schema.User.SObjectType) {
          System.assertEquals(
            STA_UtilsStatic.INTERNAL_USERS,
            oneCdl.Visibility,
            'The ContentDocumentLink is not set with "Internal" visibility.'
          );
          contentDocumentIds.add(oneCdl.ContentDocumentId);
        }
      }
      System.assertNotEquals(
        null,
        [
          SELECT Id, SharingPrivacy
          FROM ContentVersion
          WHERE ContentDocumentId IN :contentDocumentIds
        ],
        'There is no ContentDocumentLink visibble. Check insertion of it.'
      );
      for (ContentVersion oneCV : [
        SELECT Id, SharingPrivacy
        FROM ContentVersion
        WHERE ContentDocumentId IN :contentDocumentIds
      ]) {
        System.assertEquals(
          STA_UtilsStatic.PRIVATE_ON_RECORD,
          oneCV.SharingPrivacy,
          'The ContentDocumentLink is not set with "Private" visibility.'
        );
      }
    }
  }
}