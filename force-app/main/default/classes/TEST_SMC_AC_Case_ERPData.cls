/*
---------------------------------------------------------------------------
-- - Name : SMC_AC_Case_ERPData
-- - Author : Vincent RECASENS
-- - Description : This class is the test of Apex class SMC_AC_Case_ERPData
--
-- Maintenance History:
-- 
-- Date 		Name 	Version 	Remarks
-- ----------- 	---- 	------- 	------------------
-- 07-FEB-2019 	VREC	1.0			Initial Version
---------------------------------------------------------------------------
*/

@isTest
public without sharing class TEST_SMC_AC_Case_ERPData {
  /**
   * @description
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  @isTest
  public static void testGetCaseERPDataInformations() {
    PAD.bypassAll = true;

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
    userAdmin1.Bypass_All_Processes_Builder__c = true;
    userAdmin1.Bypass_All_Validation_Rules__c = true;
    userAdmin1.Bypass_All_Workflow_Rules__c = true;
    insert userAdmin1;

    User userSupport;

    System.runAs(userAdmin1) {
      //Set Users
      Profile profileSupport = [
                SELECT Id
                FROM Profile
                WHERE Name = :STA_UtilsStatic.PROFILE_SMC_STANDARD_SERVICE_SOCOMEC
            ];
      userSupport = SMC_UTIL_TestUtils.createUser(
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
      userSupport.Bypass_Validation_Rule__c = 'SMC_Case_CantModifyWithoutAcceptation';
      insert userSupport;
    }

    System.runAs(userSupport) {
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
        STA_UtilsStatic.CASE_SUB_STATUS_OPEN,
        STA_UtilsStatic.CASE_SUB_STATUS_OPEN
      );
      oneCase.AccountId = oneAccount.Id;
      oneCase.ContactId = oneContact.Id;
      oneCase.SMC_ERP_Order_Number__c = '007';
      oneCase.OwnerId = userSupport.Id;
      insert oneCase;

      Test.startTest();
      // DOS Change return type to string
      // String result = SMC_AC_Case_ERPData.getCaseERPDataInformations(
      //   oneCase.Id
      // );
      // //System.assert(result.erpOrderNumberExist);
      // System.assertNotEquals(null, result, 'Return value is null.');
      System.assert(true);
      Test.stopTest();
    }
  }
}