/*
---------------------------------------------------------------------
-- - Name          : TEST_SMC_AP_ManageContentVersion
-- - Author        : Vincent RECASENS (VR)
-- - Description   : Test for SMC_AP_ManageContentVersion               
-- Maintenance History:
--
-- Date         Name    Version     Remarks 
-- -----------  ----	------      ---------------------------
-- 19-DEC-2018  (VR)    1.0         Initial version 
---------------------------------------------------------------------
*/
@isTest
public without sharing class TEST_SMC_AP_ManageContentVersion {

  @TestSetup
  public static void setup(){
    //Setup
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
    insert user;

    PermissionSet ps = [
      SELECT Id
      FROM PermissionSet
      WHERE Name = :STA_UtilsStatic.QUOTATION_TOOL_PERMISSION
    ];
    insert new PermissionSetAssignment(
      AssigneeId = user.id,
      PermissionSetId = ps.Id
    );

    System.runAs(user) {
      PAD.bypassAll = true;

      //Account
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
      //Contact
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

      PAD.bypassAll = false;
    }
  }
  /**
   * @description : test SMC_AP_ManageContentVersion.makeFileVisibleByCommunityUsers()
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  @isTest
  public static void testMakeFileVisibleByCommunityUsers() {
    //Setup
    User user = [SELECT Id FROM User WHERE Email = :STA_UtilsStatic.USERNAME_TEST];

    System.runAs(user) {
      Account oneAccount = [SELECT Id FROM Account WHERE Name = :(STA_UtilsStatic.TEST + STA_UtilsStatic.ACCOUNT)];

      //Test 1
      ContentVersion contentVersion1 = new ContentVersion();
      contentVersion1.Title = 'Penguins1';
      contentVersion1.PathOnClient = 'Penguins1.jpg';
      contentVersion1.VersionData = Blob.valueOf('Test Content');
      contentVersion1.IsMajorVersion = true;
      contentVersion1.FirstPublishLocationId = oneAccount.Id;
      insert contentVersion1;

      //Test 2
      ContentVersion contentVersion2 = new ContentVersion();
      contentVersion2.Title = 'Penguins2';
      contentVersion2.PathOnClient = 'Penguins2.jpg';
      contentVersion2.VersionData = Blob.valueOf('Test Content');
      contentVersion2.IsMajorVersion = true;
      contentVersion2.FirstPublishLocationId = oneAccount.Id;
      insert contentVersion2;

      Test.startTest();

      //Test 1
      contentVersion1 = [
        SELECT
          Id,
          Title,
          ContentDocumentId,
          SMC_Is_Visible_By_Partner__c,
          SharingPrivacy
        FROM ContentVersion
        WHERE Id = :contentVersion1.Id
      ];

      //Visibility to TRUE
      List<ContentDocumentLink> contentDocumentLinksChecked = [
        SELECT Id, Visibility, LinkedEntityId
        FROM ContentDocumentLink
        WHERE ContentDocumentId = :contentVersion1.ContentDocumentId
      ];
      for (
        ContentDocumentLink oneContentDocumentLink : contentDocumentLinksChecked
      ) {
        System.assertEquals(
          STA_UtilsStatic.ALL_USERS,
          oneContentDocumentLink.Visibility,
          'The default visibility (AllUsers) is not set properly.'
        );
      }

      //Visibility to FALSE
      contentVersion1.SMC_Is_Visible_By_Partner__c = STA_UtilsStatic.NO;
      update contentVersion1;

      contentDocumentLinksChecked = [
        SELECT Id, Visibility, LinkedEntityId
        FROM ContentDocumentLink
        WHERE ContentDocumentId = :contentVersion1.ContentDocumentId
      ];
      for (
        ContentDocumentLink oneContentDocumentLink : contentDocumentLinksChecked
      ) {
        if (oneContentDocumentLink.LinkedEntityId == oneAccount.Id) {
          System.assertEquals(
            STA_UtilsStatic.INTERNAL_USERS,
            oneContentDocumentLink.Visibility,
            'The internal visibility is not set properly.'
          );
        }
        if (oneContentDocumentLink.LinkedEntityId == user.Id) {
          System.assertEquals(
            STA_UtilsStatic.ALL_USERS,
            oneContentDocumentLink.Visibility,
            'The visibility of this ContentDocumentLink should not be changed.'
          );
        }
      }

      //Test 2
      contentVersion2 = [
        SELECT
          Id,
          Title,
          ContentDocumentId,
          SMC_Is_Visible_By_Partner__c,
          SharingPrivacy
        FROM ContentVersion
        WHERE Id = :contentVersion2.Id
      ];
      contentVersion2.SMC_File_Privacy_on_Records__c = STA_UtilsStatic.TECH_PRIVATE_ON_RECORD_APINAME;
      update contentVersion2;

      contentVersion2 = [
        SELECT
          Id,
          Title,
          ContentDocumentId,
          SMC_Is_Visible_By_Partner__c,
          SharingPrivacy
        FROM ContentVersion
        WHERE Id = :contentVersion2.Id
      ];
      System.assert(
        contentVersion2.Title.startsWith(STA_UtilsStatic.FILE_PRIVATE_PREFIX),
        'The title management is broken.'
      );

      update contentVersion2;
      contentVersion2 = [
        SELECT
          Id,
          Title,
          ContentDocumentId,
          SMC_Is_Visible_By_Partner__c,
          SharingPrivacy
        FROM ContentVersion
        WHERE Id = :contentVersion2.Id
      ];
      System.assert(
        contentVersion2.Title.startsWith(STA_UtilsStatic.FILE_PRIVATE_PREFIX),
        'The title management is broken.'
      );

      Test.stopTest();
    }
  }

  /*public static void testPreventUploadFileOnClosedCase(){
        //Set Users
        Profile profileSupport = [SELECT Id FROM Profile WHERE Name = :STA_UtilsStatic.PROFILE_SMC_STANDARD_SUPPORT];
        User userSupport = SMC_UTIL_TestUtils.createUser('support-' + STA_UtilsStatic.USER_NICKNAME, 'support-' + STA_UtilsStatic.USERNAME_TEST, profileSupport.Id, 'support-' + STA_UtilsStatic.USERNAME_TEST, 'support-' + STA_UtilsStatic.USER_NICKNAME);
        userSupport.UserRoleId = [SELECT Id FROM UserRole WHERE DeveloperName = :STA_UtilsStatic.ROLE_SUPPORT_DEVNAME].Id; //Support
        insert userSupport;
        
        System.runAs(userSupport){

            PAD.bypassAll = true;
            
            Id recordTypeIdAccount = [SELECT Id FROM RecordType WHERE Name =: STA_UtilsStatic.RECORDTYPE_ACCOUNT_CUSTOMER].Id;
            Account oneAccount = SMC_UTIL_TestUtils.createAccount(recordTypeIdAccount, STA_UtilsStatic.TEST + STA_UtilsStatic.ACCOUNT,STA_UtilsStatic.PICKLIST_ACCOUNT_TYPE_MARKETING_PROSPECT,STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY1);
            oneAccount.AccountNumber = 'ACC-{000001}';
            insert oneAccount;
            Contact oneContact = SMC_UTIL_TestUtils.createContact(STA_UtilsStatic.CONTACT_FIRSTNAME1 + 'test', STA_UtilsStatic.CONTACT_LASTNAME1 + 'test', STA_UtilsStatic.CONTACT_PHONE1, STA_UtilsStatic.CONTACT_MOBILEPHONE1,
            'test-' + STA_UtilsStatic.CONTACT_EMAIL1, STA_UtilsStatic.CONTACT_MAILINGSTREET1, STA_UtilsStatic.CONTACT_MAILINGPOSTALCODE1, STA_UtilsStatic.CONTACT_MAILINGCITY1, STA_UtilsStatic.CONTACT_MAILINGSTATE1,
            STA_UtilsStatic.CONTACT_MAILINGCOUNTRY1, STA_UtilsStatic.EMPTY_STRING, oneAccount.Id);
            insert oneContact;

            Case oneCase = SMC_UTIL_TestUtils.createCase(STA_UtilsStatic.CASE_SUBJECT2, STA_UtilsStatic.CASE_DESCRIPTION2, STA_UtilsStatic.CASE_TYPE_TECHNICAL, STA_UtilsStatic.CASE_SUB_STATUS_OPEN, STA_UtilsStatic.CASE_SUB_STATUS_OPEN);
            oneCase.AccountId = oneAccount.Id;
            oneCase.ContactId = oneContact.Id;
            oneCase.OwnerId = userSupport.Id;
            insert new List<Case>{oneCase};

            oneCase.Status = STA_UtilsStatic.CASE_STATUS_CLOSED;
            oneCase.SMC_Answer_To_Customer__c = STA_UtilsStatic.TEST;
            update oneCase;

            PAD.bypassAll = false;

            Test.startTest();   
                ContentVersion contentVersion1 = new ContentVersion();
                contentVersion1.Title = 'Penguins1';
                contentVersion1.PathOnClient = 'Penguins1.jpg';
                contentVersion1.VersionData = Blob.valueOf('Test Content');
                contentVersion1.IsMajorVersion = true;
                contentVersion1.FirstPublishLocationId = oneCase.Id;
                insert contentVersion1;
            Test.stopTest();

        }
    }*/
}