/**
 * @description       :
 * @author            : Vincent RECASENS (Modis)
 * @group             :
 * @last modified on  : 10-07-2020
 * @last modified by  : Vincent RECASENS (Modis)
 * Modifications Log
 * Ver   Date         Author                     Modification
 * 1.0   10-07-2020   Vincent RECASENS (Modis)   Initial Version
 **/
@IsTest
public class TEST_SMC_AC_SoSales_CreateCase {
  @isTest
  public static void testGetCase() {
    Profile profileStandard = [
      SELECT Id
      FROM Profile
      WHERE Name = :STA_UtilsStatic.PROFILE_SALE_STANDARD
    ];
    User userStandard = SMC_UTIL_TestUtils.createUser(
      'standard-' + STA_UtilsStatic.USERNAME_TEST,
      'standard-' + STA_UtilsStatic.USERNAME_TEST,
      profileStandard.Id,
      'standard-' + STA_UtilsStatic.USERNAME_TEST,
      'standard-' + STA_UtilsStatic.USERNAME_TEST
    );
    insert userStandard;

    System.runAs(userStandard) {
      /* SETUP */
      Id recordTypeIdAccount = [
        SELECT Id
        FROM RecordType
        WHERE name = :STA_UtilsStatic.RECORDTYPE_ACCOUNT_CUSTOMER
      ]
      .Id;
      Account parentAccount = SMC_UTIL_TestUtils.createAccount(
        recordTypeIdAccount,
        'testParent',
        STA_UtilsStatic.PICKLIST_ACCOUNT_TYPE_MARKETING_PROSPECT,
        STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY1
      );
      parentAccount.AccountNumber = 'ACC-{000001}';
      insert parentAccount;
      insert (new Account(
        Name = 'testChild',
        BillingCountryCode = 'FR',
        ParentId = parentAccount.Id
      ));
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
        parentAccount.Id
      );
      insert oneContact;

      Case oneCase = SMC_UTIL_TestUtils.createCase(
        STA_UtilsStatic.CASE_SUBJECT2,
        STA_UtilsStatic.CASE_DESCRIPTION2,
        STA_UtilsStatic.CASE_TYPE_TECHNICAL_SUPPORT,
        STA_UtilsStatic.CASE_SUB_STATUS_OPEN,
        STA_UtilsStatic.CASE_SUB_STATUS_OPEN
      );
      oneCase.AccountId = parentAccount.Id;
      oneCase.ContactId = oneContact.Id;
      oneCase.OwnerId = userStandard.Id;
      insert new List<Case>{ oneCase };

      //Check Before
      Case checkCaseBefore = [
        SELECT SMC_Internal_Requestor__c
        FROM Case
        WHERE Subject = :STA_UtilsStatic.CASE_SUBJECT2
      ];
      System.assertEquals(null, checkCaseBefore.SMC_Internal_Requestor__c);

      /* TEST */
      Test.startTest();
      Case caseReturned = SMC_AC_SoSales_CreateCase.getCase(oneCase.Id);
      Test.stopTest();

      //Check After
      System.assertEquals(
        UserInfo.getUserId(),
        caseReturned.SMC_Internal_Requestor__c
      );
    }
  }
}