/**
 * @File Name          : LCCtrl_genericLookup_Test.cls
 * @Description        : Lookup component usable in layouts or flows
 * @Author             : Emmanuel BERNIER (Modis)
 * @Group              :
 * @Last Modified By   : Vincent RECASENS (Modis)
 * @Last Modified On   : 10-07-2020
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    ??/07/2019   Emmanuel BERNIER (Modis)     Initial Version
 **/

@isTest
public without sharing class LCCtrl_genericLookup_Test {
  @testSetup
  public static void setup() {
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
    }
  }

  @isTest
  public static void testLookupCtrlAccountChild() {
    User user1 = [
      SELECT Id
      FROM User
      WHERE Email = :('standard-' + STA_UtilsStatic.USERNAME_TEST)
    ];
    System.runAs(user1) {
      List<Account> accList = LCCtrl_GenericLookup.fetchLookUpValues(
        'testChild',
        'Account',
        '',
        false
      );
      System.assertEquals(1, accList.size(), 'no account returned');
    }
  }

  @isTest
  public static void testLookupCtrlAccountParent() {
    User user1 = [
      SELECT Id
      FROM User
      WHERE Email = :('standard-' + STA_UtilsStatic.USERNAME_TEST)
    ];
    System.runAs(user1) {
      List<Account> accList = LCCtrl_GenericLookup.fetchLookUpValues(
        'testParent',
        'Account',
        '',
        true
      );
      System.assertEquals(1, accList.size(), 'no account returned');
    }
  }

  @isTest
  public static void testFetchDefaultAccount() {
    User user1 = [
      SELECT Id
      FROM User
      WHERE Email = :('standard-' + STA_UtilsStatic.USERNAME_TEST)
    ];
    System.runAs(user1) {
      Id accId = [SELECT Id FROM Account WHERE Name = 'testChild' LIMIT 1].Id;
      Account theAccount = (Account) LCCtrl_GenericLookup.fetchDefaultObject(
        'Account',
        accId
      );
      System.assertNotEquals(null, theAccount);
    }
  }

  @isTest
  public static void testLookupCtrlCaseChild() {
    User user1 = [
      SELECT Id
      FROM User
      WHERE Email = :('standard-' + STA_UtilsStatic.USERNAME_TEST)
    ];

    Case theCase = [
      SELECT CaseNumber
      FROM Case
      WHERE Subject = :STA_UtilsStatic.CASE_SUBJECT2
    ];
    System.runAs(user1) {
      List<Case> caseList = LCCtrl_GenericLookup.fetchLookUpValues(
        theCase.CaseNumber,
        'Case',
        '',
        false
      );
      System.assertEquals(1, caseList.size(), 'no account returned');
    }
  }

  @isTest
  public static void testLookupCtrlCaseParent() {
    User user1 = [
      SELECT Id
      FROM User
      WHERE Email = :('standard-' + STA_UtilsStatic.USERNAME_TEST)
    ];

    Case theCase = [
      SELECT CaseNumber
      FROM Case
      WHERE Subject = :STA_UtilsStatic.CASE_SUBJECT2
    ];
    System.runAs(user1) {
      List<Case> caseList = LCCtrl_GenericLookup.fetchLookUpValues(
        theCase.CaseNumber,
        'Case',
        '',
        true
      );
      System.assertEquals(1, caseList.size(), 'no account returned');
    }
  }

  @isTest
  public static void testFetchDefaultCase() {
    User user1 = [
      SELECT Id
      FROM User
      WHERE Email = :('standard-' + STA_UtilsStatic.USERNAME_TEST)
    ];
    Id theCaseId = [
      SELECT Id
      FROM Case
      WHERE Subject = :STA_UtilsStatic.CASE_SUBJECT2
    ]
    .Id;
    System.runAs(user1) {
      Case theCase = (Case) LCCtrl_GenericLookup.fetchDefaultObject(
        'Case',
        theCaseId
      );
      System.assertNotEquals(null, theCase);
    }
  }
}