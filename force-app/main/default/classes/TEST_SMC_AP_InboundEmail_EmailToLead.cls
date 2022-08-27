/*
-----------------------------------------------------------------------------------
-- - Name : TEST_SMC_AP_InboundEmail_EmailToLead
-- - Author : Vincent RECASENS
-- - Description : This class is the test of the class SMC_AP_InboundEmail_EmailToLead
--
-- Maintenance History:
--
-- Date         Name   Version     Remarks
-- -----------  ----   -------     ----------------------------
-- 09-JAN-2019  VRE    1.0         Initial Version
------------------------------------------------------------------------------------
*/

@isTest
public without sharing class TEST_SMC_AP_InboundEmail_EmailToLead {
  /**
   * @description : test SMC_AP_InboundEmail_EmailToLead.handleInboundEmail()
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  @isTest
  public static void testHandleInboundEmailOK() {
    Id profileId = [
      SELECT Id
      FROM Profile
      WHERE Name = :STA_UtilsStatic.PROFILE_SMC_ADMIN
    ]
    .Id;
    User user = SMC_UTIL_TestUtils.createUser(
      STA_UtilsStatic.TEST_DIESE,
      STA_UtilsStatic.EMAIL_TEST,
      profileId,
      STA_UtilsStatic.USERNAME_TEST,
      STA_UtilsStatic.USER_NICKNAME
    );
    insert user;

    System.runAs(user) {
      //Create the Lead
      Lead theLead = SMC_UTIL_TestUtils.createLead(
        STA_UtilsStatic.EVENTS,
        STA_UtilsStatic.LEAD_COMPANY1,
        STA_UtilsStatic.LEAD_FIRSTNAME1,
        STA_UtilsStatic.LEAD_LASTNAME1,
        STA_UtilsStatic.LEAD_PHONE1,
        STA_UtilsStatic.LEAD_EMAIL1,
        STA_UtilsStatic.LEAD_STREET1_VERY_LONG,
        STA_UtilsStatic.LEAD_POSTALCODE1,
        STA_UtilsStatic.LEAD_CITY1,
        STA_UtilsStatic.LEAD_STATE1,
        STA_UtilsStatic.LEAD_COUNTRY1
      );
      insert theLead;
      //Check there is no File link to the Lead
      List<ContentVersion> contentVersion = new List<ContentVersion>();
      contentVersion = [
        SELECT Id
        FROM ContentVersion
        WHERE FirstPublishLocationId = :theLead.Id
      ];
      System.assert(
        contentVersion.size() == 0,
        'The target lead has already a file linked.'
      );

      //Create an email
      Messaging.InboundEmail theInboundEmail = new Messaging.InboundEmail();
      theInboundEmail.fromAddress = 'test@modis.com';
      theInboundEmail.toAddresses = new List<String>{
        'smc_email-to-lead@i-32t7rj2yo81up0gtgtnwxue1pnh8616p622aayar4hrfcuzep1.0d-8bhduai.cs106.apex.sandbox.salesforce.com'
      };
      theInboundEmail.subject =
        'Lead Test InboundEmail [RefId:' +
        theLead.Id +
        ']';
      theInboundEmail.plainTextBody = 'Test Body';

      Test.startTest();
      SMC_AP_InboundEmail_EmailToLead catcher = new SMC_AP_InboundEmail_EmailToLead();
      System.assert(
        catcher.handleInboundEmail(theInboundEmail, null).success,
        'The catcher do not received the inbound email. Check inbound email launch conditions.'
      );

      List<ContentVersion> contentVersionCheck = new List<ContentVersion>();
      contentVersionCheck = [
        SELECT Id, Title, VersionData
        FROM ContentVersion
        WHERE FirstPublishLocationId = :theLead.Id
      ];
      System.assertEquals(
        1,
        contentVersionCheck.size(),
        'The file was not saved in the base.'
      );
      System.assertEquals(
        'Lead Test InboundEmail',
        contentVersionCheck[0].Title,
        'The file do not match with test value.'
      );
      Test.stopTest();
    }

  }

  /**
   * @description : test
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  @isTest
  public static void testHandleInboundEmailKOBadIdSobjectType() {
    Id profileId = [
      SELECT Id
      FROM Profile
      WHERE Name = :STA_UtilsStatic.PROFILE_SMC_ADMIN
    ]
    .Id;
    User user = SMC_UTIL_TestUtils.createUser(
      STA_UtilsStatic.TEST_DIESE,
      STA_UtilsStatic.EMAIL_TEST,
      profileId,
      STA_UtilsStatic.USERNAME_TEST,
      STA_UtilsStatic.USER_NICKNAME
    );
    insert user;

    System.runAs(user) {
      //Create an email
      Messaging.InboundEmail theInboundEmail = new Messaging.InboundEmail();
      theInboundEmail.fromAddress = 'test@modis.com';
      theInboundEmail.toAddresses = new List<String>{
        'smc_email-to-lead@i-32t7rj2yo81up0gtgtnwxue1pnh8616p622aayar4hrfcuzep1.0d-8bhduai.cs106.apex.sandbox.salesforce.com'
      };
      theInboundEmail.subject =
        'Lead Test InboundEmail [RefId:' +
        UserInfo.getUserId() +
        ']';
      theInboundEmail.plainTextBody = 'Test Body';

      Test.startTest();
      SMC_AP_InboundEmail_EmailToLead catcher = new SMC_AP_InboundEmail_EmailToLead();
      System.assert(
        !catcher.handleInboundEmail(theInboundEmail, null).success,
        'The catcher received the indound email. Check SObject type.'
      );
      Test.stopTest();
    }

  }

  /**
   * @description : test SMC_AP_InboundEmail_EmailToLead.handleInboundEmail() [BAD]
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  @isTest
  public static void testHandleInboundEmailKOException() {
    Id profileId = [
      SELECT Id
      FROM Profile
      WHERE Name = :STA_UtilsStatic.PROFILE_SMC_ADMIN
    ]
    .Id;
    User user = SMC_UTIL_TestUtils.createUser(
      STA_UtilsStatic.TEST_DIESE,
      STA_UtilsStatic.EMAIL_TEST,
      profileId,
      STA_UtilsStatic.USERNAME_TEST,
      STA_UtilsStatic.USER_NICKNAME
    );
    insert user;

    System.runAs(user) {
      //Create the Lead
      Lead theLead = SMC_UTIL_TestUtils.createLead(
        STA_UtilsStatic.EVENTS,
        STA_UtilsStatic.LEAD_COMPANY1,
        STA_UtilsStatic.LEAD_FIRSTNAME1,
        STA_UtilsStatic.LEAD_LASTNAME1,
        STA_UtilsStatic.LEAD_PHONE1,
        STA_UtilsStatic.LEAD_EMAIL1,
        STA_UtilsStatic.LEAD_STREET1_VERY_LONG,
        STA_UtilsStatic.LEAD_POSTALCODE1,
        STA_UtilsStatic.LEAD_CITY1,
        STA_UtilsStatic.LEAD_STATE1,
        STA_UtilsStatic.LEAD_COUNTRY1
      );
      insert theLead;
      //Check there is no File link to the Lead
      List<ContentVersion> contentVersion = new List<ContentVersion>();
      contentVersion = [
        SELECT Id
        FROM ContentVersion
        WHERE FirstPublishLocationId = :theLead.Id
      ];
      System.assert(
        contentVersion.size() == 0,
        'There is already a Contentversion link to the lead.'
      );

      //Create an email
      Messaging.InboundEmail theInboundEmail = new Messaging.InboundEmail();
      theInboundEmail.fromAddress = 'test@modis.com';
      theInboundEmail.toAddresses = new List<String>{
        'smc_email-to-lead@i-32t7rj2yo81up0gtgtnwxue1pnh8616p622aayar4hrfcuzep1.0d-8bhduai.cs106.apex.sandbox.salesforce.com'
      };
      theInboundEmail.subject =
        'RefId:' +
        theLead.Id +
        ' - Subject : Test InboundEmail';
      theInboundEmail.plainTextBody = null;

      Test.startTest();
      SMC_AP_InboundEmail_EmailToLead catcher = new SMC_AP_InboundEmail_EmailToLead();
      System.assert(
        !catcher.handleInboundEmail(theInboundEmail, null).success,
        'The catcher received the indound email. Check inbound email launch conditions.'
      );
      Test.stopTest();
    }

  }

  /**
   * @description  : test SMC_AP_InboundEmail_EmailToLead.handleInboundEmail(Attachment) [OK]
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  @isTest
  public static void testHandleInboundEmailHasAttachment() {
    Id profileId = [
      SELECT Id
      FROM Profile
      WHERE Name = :STA_UtilsStatic.PROFILE_SMC_ADMIN
    ]
    .Id;
    User user = SMC_UTIL_TestUtils.createUser(
      STA_UtilsStatic.TEST_DIESE,
      STA_UtilsStatic.EMAIL_TEST,
      profileId,
      STA_UtilsStatic.USERNAME_TEST,
      STA_UtilsStatic.USER_NICKNAME
    );
    insert user;

    System.runAs(user) {
      //Create the Lead
      Lead theLead = SMC_UTIL_TestUtils.createLead(
        STA_UtilsStatic.EVENTS,
        STA_UtilsStatic.LEAD_COMPANY1,
        STA_UtilsStatic.LEAD_FIRSTNAME1,
        STA_UtilsStatic.LEAD_LASTNAME1,
        STA_UtilsStatic.LEAD_PHONE1,
        STA_UtilsStatic.LEAD_EMAIL1,
        STA_UtilsStatic.LEAD_STREET1_VERY_LONG,
        STA_UtilsStatic.LEAD_POSTALCODE1,
        STA_UtilsStatic.LEAD_CITY1,
        STA_UtilsStatic.LEAD_STATE1,
        STA_UtilsStatic.LEAD_COUNTRY1
      );
      insert theLead;
      //Check there is no File link to the Lead
      List<ContentVersion> contentVersion = new List<ContentVersion>();
      contentVersion = [
        SELECT Id
        FROM ContentVersion
        WHERE FirstPublishLocationId = :theLead.Id
      ];
      System.assert(
        contentVersion.size() == 0,
        'There is already a Contentversion link to the lead.'
      );

      Messaging.InboundEmail.BinaryAttachment binaryAttachment = new Messaging.InboundEmail.BinaryAttachment();
      binaryAttachment.fileName = 'Test Attachment for Parent';
      binaryAttachment.body = Blob.valueOf('Test Data');
      binaryAttachment.mimeTypeSubType = 'image/png';

      //Create an email
      Messaging.InboundEmail theInboundEmail = new Messaging.InboundEmail();
      theInboundEmail.fromAddress = 'test@modis.com';
      theInboundEmail.toAddresses = new List<String>{
        'smc_email-to-lead@i-32t7rj2yo81up0gtgtnwxue1pnh8616p622aayar4hrfcuzep1.0d-8bhduai.cs106.apex.sandbox.salesforce.com'
      };
      theInboundEmail.subject =
        'Lead Test InboundEmail [RefId:' +
        theLead.Id +
        ']';
      theInboundEmail.plainTextBody = 'Test Body';
      theInboundEmail.binaryAttachments = new List<Messaging.InboundEmail.BinaryAttachment>{
        binaryAttachment
      };

      Test.startTest();
      SMC_AP_InboundEmail_EmailToLead catcher = new SMC_AP_InboundEmail_EmailToLead();
      System.assert(
        catcher.handleInboundEmail(theInboundEmail, null).success,
        'The catcher do not received the indound email. Check inbound email launch conditions.'
      );

      List<ContentVersion> contentVersionCheck = new List<ContentVersion>();
      contentVersionCheck = [
        SELECT Id, Title, VersionData
        FROM ContentVersion
        WHERE FirstPublishLocationId = :theLead.Id
      ];
      System.assertEquals(
        2,
        contentVersionCheck.size(),
        'ContentVersion are not inserted or linked to the lead.'
      );
      for (ContentVersion oneContentVersion : contentVersionCheck) {
        System.assert(
          oneContentVersion.Title.contains('Lead Test InboundEmail'),
          'The email attachment was not saved in base.'
        );
      }
      Test.stopTest();
    }
  }

  /**
   * @description  : test SMC_AP_InboundEmail_EmailToLead.handleInboundEmail(TextAttachment) [OK]
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  @isTest
  public static void testHandleInboundEmailHasTextAttachment() {
    Id profileId = [
      SELECT Id
      FROM Profile
      WHERE Name = :STA_UtilsStatic.PROFILE_SMC_ADMIN
    ]
    .Id;
    User user = SMC_UTIL_TestUtils.createUser(
      STA_UtilsStatic.TEST_DIESE,
      STA_UtilsStatic.EMAIL_TEST,
      profileId,
      STA_UtilsStatic.USERNAME_TEST,
      STA_UtilsStatic.USER_NICKNAME
    );
    insert user;

    System.runAs(user) {
      //Create the Lead
      Lead theLead = SMC_UTIL_TestUtils.createLead(
        STA_UtilsStatic.EVENTS,
        STA_UtilsStatic.LEAD_COMPANY1,
        STA_UtilsStatic.LEAD_FIRSTNAME1,
        STA_UtilsStatic.LEAD_LASTNAME1,
        STA_UtilsStatic.LEAD_PHONE1,
        STA_UtilsStatic.LEAD_EMAIL1,
        STA_UtilsStatic.LEAD_STREET1_VERY_LONG,
        STA_UtilsStatic.LEAD_POSTALCODE1,
        STA_UtilsStatic.LEAD_CITY1,
        STA_UtilsStatic.LEAD_STATE1,
        STA_UtilsStatic.LEAD_COUNTRY1
      );
      insert theLead;
      //Check there is no File link to the Lead
      List<ContentVersion> contentVersion = new List<ContentVersion>();
      contentVersion = [
        SELECT Id
        FROM ContentVersion
        WHERE FirstPublishLocationId = :theLead.Id
      ];
      System.assert(
        contentVersion.size() == 0,
        'There is already a Contentversion link to the lead.'
      );

      //Create an TextAttachment
      Messaging.InboundEmail.TextAttachment textAttachment = new Messaging.InboundEmail.TextAttachment();
      textAttachment.fileName = 'Test Attachment for Parent';
      textAttachment.body = 'Test Data';
      textAttachment.mimeTypeSubType = 'text/plain';

      //Create an email
      Messaging.InboundEmail theInboundEmail = new Messaging.InboundEmail();
      theInboundEmail.fromAddress = 'test@modis.com';
      theInboundEmail.toAddresses = new List<String>{
        'smc_email-to-lead@i-32t7rj2yo81up0gtgtnwxue1pnh8616p622aayar4hrfcuzep1.0d-8bhduai.cs106.apex.sandbox.salesforce.com'
      };
      theInboundEmail.subject =
        'Lead Test InboundEmail [RefId:' +
        theLead.Id +
        ']';
      theInboundEmail.plainTextBody = 'Test Body';
      theInboundEmail.textAttachments = new List<Messaging.InboundEmail.TextAttachment>{
        textAttachment
      };

      Test.startTest();
      SMC_AP_InboundEmail_EmailToLead catcher = new SMC_AP_InboundEmail_EmailToLead();
      System.assert(
        catcher.handleInboundEmail(theInboundEmail, null).success,
        'The catcher do not received the indound email. Check inbound email launch conditions.'
      );

      List<ContentVersion> contentVersionCheck = new List<ContentVersion>();
      contentVersionCheck = [
        SELECT Id, Title, VersionData
        FROM ContentVersion
        WHERE FirstPublishLocationId = :theLead.Id
      ];
      System.assertEquals(2, contentVersionCheck.size());
      for (ContentVersion oneContentVersion : contentVersionCheck) {
        System.assert(
          oneContentVersion.Title.contains('Lead Test InboundEmail'),
          'The email attachment was not saved in base.'
        );
      }
      Test.stopTest();
    }
  }
}