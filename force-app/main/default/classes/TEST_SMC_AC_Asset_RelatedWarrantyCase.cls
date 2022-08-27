/*
---------------------------------------------------------------------------
-- - Name : TEST_SMC_AC_Asset_RelatedWarrantyCase
-- - Author : Vincent RECASENS
-- - Description : This class is the test class of the Apex class get WhoName from contact
--
-- Maintenance History:
--
-- Date         Name        Version     Remarks
-- -----------  ----        -------     -----------------------
-- 13-FEB-2019  VREC  		1.0     	Initial Version
---------------------------------------------------------------------------
*/

@isTest
public without sharing class TEST_SMC_AC_Asset_RelatedWarrantyCase {
  /**
  * @description : test get WhoName from contact.getRelatedCase
  * @author Vincent RECASENS (Modis) | 07-10-2020 
  **/
  @isTest
  public static void testGetRelatedCase() {
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
    userAdmin1.Bypass_All_Validation_Rules__c = true;
    userAdmin1.Bypass_All_Workflow_Rules__c = true;
    insert new List<User>{ userAdmin1 };

    System.runAs(userAdmin1) {
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
        STA_UtilsStatic.CASE_SUBJECT1,
        STA_UtilsStatic.CASE_DESCRIPTION1,
        STA_UtilsStatic.CASE_TYPE_TECHNICAL_SUPPORT,
        STA_UtilsStatic.CASE_SUB_STATUS_OPEN,
        STA_UtilsStatic.CASE_SUB_STATUS_OPEN
      );
      oneCase.AccountId = oneAccount.Id;
      oneCase.ContactId = oneContact.Id;
      oneCase.SMC_Serial_Number__c = '00007';
      Case twoCase = SMC_UTIL_TestUtils.createCase(
        STA_UtilsStatic.CASE_SUBJECT2,
        STA_UtilsStatic.CASE_DESCRIPTION2,
        STA_UtilsStatic.CASE_TYPE_TECHNICAL_SUPPORT,
        STA_UtilsStatic.CASE_SUB_STATUS_OPEN,
        STA_UtilsStatic.CASE_SUB_STATUS_OPEN
      );
      twoCase.AccountId = oneAccount.Id;
      twoCase.ContactId = oneContact.Id;
      Case threeCase = SMC_UTIL_TestUtils.createCase(
        STA_UtilsStatic.CASE_SUBJECT1,
        STA_UtilsStatic.CASE_DESCRIPTION1,
        STA_UtilsStatic.CASE_TYPE_WARRANTY_CLAIMS,
        STA_UtilsStatic.CASE_SUB_STATUS_OPEN,
        STA_UtilsStatic.CASE_SUB_STATUS_OPEN
      );
      threeCase.AccountId = oneAccount.Id;
      threeCase.ContactId = oneContact.Id;
      threeCase.SMC_Serial_Number__c = '00007';
      insert new List<Case>{ oneCase, twoCase, threeCase };

      Map<String, Schema.RecordTypeInfo> recordTypesProduct = new Map<String, Schema.RecordTypeInfo>();
      recordTypesProduct = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName();
      Id productRecordTypeId = recordTypesProduct.get(
          STA_UtilsStatic.RECORDTYPE_SERVICE_PRODUCT
        )
        .getRecordTypeId();
      Product2 theProduct = SMC_UTIL_TestUtils.createProductFSL(
        productRecordTypeId,
        STA_UtilsStatic.TEST,
        true
      );

      Map<String, Schema.RecordTypeInfo> recordTypesAsset = new Map<String, Schema.RecordTypeInfo>();
      recordTypesAsset = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName();
      Id assetRecordTypeId = recordTypesAsset.get(
          STA_UtilsStatic.RECORDTYPE_ASSET
        )
        .getRecordTypeId();
      Asset oneAsset = SMC_UTIL_TestUtils.createAsset(
        assetRecordTypeId,
        null,
        oneAccount.Id,
        oneContact.Id,
        STA_UtilsStatic.TEST,
        theProduct.Id,
        null,
        '001'
      );
      oneAsset.SerialNumber = '00007';
      // oneAsset.SMC_SerialNumber__c = '00007';
      insert oneAsset;

      // Test.startTest();
      List<Case> cases = SMC_AC_Asset_RelatedWarrantyCase.getRelatedCase(
        oneAsset.Id,
        STA_UtilsStatic.DEFAULT_PICKLIST_VALUE
      );
      System.assertEquals(2, cases.size(), 'Cases are not retrieve.');

      cases = SMC_AC_Asset_RelatedWarrantyCase.getRelatedCase(
        oneAsset.Id,
        STA_UtilsStatic.CASE_TYPE +
        ' = \'' +
        STA_UtilsStatic.CASE_TYPE_WARRANTY_CLAIMS +
        '\''
      );
      System.assertEquals(1, cases.size(), 'Case is not retrieve.');

      // Test.stopTest();
    }
  }
}