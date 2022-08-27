/*
-----------------------------------------------------------------------------------
-- - Name : TEST_SMC_AC_Marketing_Library
-- - Author : Vincent RECASENS
-- - Description : This class test the Apex controller SMC_AC_Marketing_Library
--
-- Maintenance History:
--
-- Date         Name   Version     Remarks
-- -----------  ----   -------     ----------------------------
-- 12-AUG-2019  VRE    1.0         Initial Version
------------------------------------------------------------------------------------
*/

@IsTest
public without sharing class TEST_SMC_AC_View_Files_Case {
  /**
   * @description : test SMC_AC_View_Files_Case.getCaseFiles()
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  @isTest
  public static void testGetCaseFiles() {
    Profile profileAdmin = [
      SELECT Id
      FROM Profile
      WHERE Name = :STA_UtilsStatic.PROFILE_SMC_ADMIN
    ];
    User userAdmin = SMC_UTIL_TestUtils.createUser(
      'Admin-' + STA_UtilsStatic.USER_NICKNAME,
      'Admin-' + STA_UtilsStatic.USERNAME_TEST,
      profileAdmin.Id,
      'Admin-' + STA_UtilsStatic.USERNAME_TEST,
      'Admin-' + STA_UtilsStatic.USER_NICKNAME
    );
    userAdmin.UserRoleId = [
      SELECT Id
      FROM UserRole
      WHERE DeveloperName = :STA_UtilsStatic.ROLE_CEO_DEVNAME
    ]
    .Id;
    userAdmin.Bypass_Validation_Rule__c = 'SMC_EditInterfaceInformation;SMC_Lock_record_type';
    User userAdmin2 = SMC_UTIL_TestUtils.createUser(
      'Admin2-' + STA_UtilsStatic.USER_NICKNAME,
      'Admin2-' + STA_UtilsStatic.USERNAME_TEST,
      profileAdmin.Id,
      'Admin2-' + STA_UtilsStatic.USERNAME_TEST,
      'Admin2-' + STA_UtilsStatic.USER_NICKNAME
    );
    insert new List<User>{ userAdmin, userAdmin2 };

    Case parentCase;
    Case childCase;

    System.runAs(userAdmin) {
      PAD.bypassAll = true;

      Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
        .get(STA_UtilsStatic.RECORDTYPE_ACCOUNT_CUSTOMER_DEVNAME)
        .getRecordTypeId();
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

      parentCase = SMC_UTIL_TestUtils.createCase(
        STA_UtilsStatic.CASE_SUBJECT2,
        STA_UtilsStatic.CASE_DESCRIPTION2,
        STA_UtilsStatic.CASE_TYPE_TOOL_SUPPORT,
        STA_UtilsStatic.CASE_SUB_STATUS_OPEN,
        STA_UtilsStatic.CASE_SUB_STATUS_OPEN
      );
      parentCase.Status = STA_UtilsStatic.CASE_SUB_STATUS_OPEN;
      parentCase.AccountId = oneAccount.Id;
      parentCase.ContactId = oneContact.Id;
      parentCase.OwnerId = userAdmin.Id;
      insert parentCase;

      childCase = SMC_UTIL_TestUtils.createCase(
        STA_UtilsStatic.CASE_SUBJECT2,
        STA_UtilsStatic.CASE_DESCRIPTION2,
        STA_UtilsStatic.CASE_TYPE_TOOL_SUPPORT,
        STA_UtilsStatic.CASE_SUB_STATUS_OPEN,
        STA_UtilsStatic.CASE_SUB_STATUS_OPEN
      );
      childCase.Status = STA_UtilsStatic.CASE_SUB_STATUS_OPEN;
      childCase.AccountId = oneAccount.Id;
      childCase.ContactId = oneContact.Id;
      childCase.ParentId = parentCase.Id;
      parentCase.OwnerId = userAdmin.Id;
      insert childCase;

      PAD.bypassAll = false;

      ContentVersion contentVersionPenguins = new ContentVersion();
      contentVersionPenguins.Title = 'Penguins';
      contentVersionPenguins.PathOnClient = 'Penguins.jpg';
      contentVersionPenguins.VersionData = Blob.valueOf('Test Penguins');
      contentVersionPenguins.FirstPublishLocationId = parentCase.Id;
      contentVersionPenguins.IsMajorVersion = true;

      ContentVersion contentVersionElephants = new ContentVersion();
      contentVersionElephants.Title = 'Elephants';
      contentVersionElephants.PathOnClient = 'Elephants.jpg';
      contentVersionElephants.VersionData = Blob.valueOf('Test Elephants');
      contentVersionElephants.FirstPublishLocationId = childCase.Id;
      contentVersionElephants.IsMajorVersion = true;
      insert new List<ContentVersion>{
        contentVersionPenguins,
        contentVersionElephants
      };
    }

    System.runAs(userAdmin2) {
      PAD.bypassAll = true;

      ContentVersion contentVersionRorodile = new ContentVersion();
      contentVersionRorodile.Title = 'Rorodile';
      contentVersionRorodile.PathOnClient = 'Rorodile.jpg';
      contentVersionRorodile.VersionData = Blob.valueOf('Test Rorodile');
      contentVersionRorodile.FirstPublishLocationId = parentCase.Id;
      contentVersionRorodile.IsMajorVersion = true;
      insert new List<ContentVersion>{ contentVersionRorodile };

      contentVersionRorodile.SMC_File_Privacy_on_Records__c = 'SMC_Private';
      contentVersionRorodile.SharingPrivacy = 'P';
      update contentVersionRorodile;
      // contentVersionRorodile = [SELECT Id, ContentDocumentId FROM ContentVersion WHERE Id = :contentVersionRorodile.Id];
      // ContentDocument theContentDocument = [SELECT Id, SharingPrivacy FROM ContentDocument WHERE Id = :contentVersionRorodile.ContentDocumentId];
      // theContentDocument.SharingPrivacy = STA_UtilsStatic.PRIVATE_ON_RECORD;
      // theContentDocument.OwnerId = userAdmin2.Id;
      // update theContentDocument;

      PAD.bypassAll = false;
    }

    System.runAs(userAdmin) {
      Test.startTest();
      Map<String, ContentDocument> parentFiles = SMC_AC_View_Files_Case.getCaseFiles(
        parentCase.Id
      );
      Map<String, ContentDocument> childFiles = SMC_AC_View_Files_Case.getCaseFiles(
        childCase.Id
      );
      Test.stopTest();

      System.assertEquals(
        2,
        parentFiles.size(),
        'Files are not inserted or not visible. Check files insertion and Case visibility.'
      );
      System.assertEquals(
        2,
        childFiles.size(),
        'Files are not inserted or not visible. Check files insertion and Case visibility.'
      );
    }
  }
}