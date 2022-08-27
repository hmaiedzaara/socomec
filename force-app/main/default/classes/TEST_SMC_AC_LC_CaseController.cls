/**
 * @File Name          : TEST_SMC_AC_LC_CaseController.cls
 * @Description        :
 * @Author             : Vincent RECASENS (Modis)
 * @Group              :
 * @Last Modified By   : Vincent RECASENS (Modis)
 * @Last Modified On   : 07-10-2020
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    ??/??/2018   David SOBZACK (Socomec)      Initial Version
 **/

@isTest
public without sharing class TEST_SMC_AC_LC_CaseController {
  /** UNSED COMPONENT AND METHOD - CODE COVERAGE --> To delete in Apex class **/
  //Le retour de la méthode "SMC_AC_LC_CaseController.getInstalledProductInfosHTML" est une page HTML
  @isTest
  public static void testgetInstalledProductInfosHTML() {
    System.debug(
      LoggingLevel.INFO,
      '## >>> TEST_SMC_AC_LC_CaseController testgetInstalledProductInfosHTML:START <<< ##'
    );

    //TEST
    // SMC_UTIL_MockHttpResponseGenerator fakeResponse = new SMC_UTIL_MockHttpResponseGenerator(200, STA_UtilsStatic.COMPLETE, SMC_UTIL_CaseCalloutMockJSON.INSTALLED_PRODUCT_INFO, null);
    // Test.setMock(HttpCalloutMock.class, fakeResponse);
    // SMC_UTIL_MockHttpResponseGenerator fakeResponse2 = new SMC_UTIL_MockHttpResponseGenerator(201, STA_UtilsStatic.COMPLETE, SMC_UTIL_CaseCalloutMockJSON.INSTALLED_PRODUCT_INFO, null);
    // Test.setMock(HttpCalloutMock.class, fakeResponse2);

    Test.startTest();
    String rep = SMC_AC_LC_CaseController.getInstalledProductInfosHTML(
      SMC_UTIL_CaseCalloutMockJSON.SERIAL_NUMBER_FOR_MOCK,
      null
    );
    System.assertEquals('', rep, 'Check the method.');
    // System.assert(rep.startsWith('<html>'));
    // String rep2 = SMC_AC_LC_CaseController.getInstalledProductInfosHTML(SMC_UTIL_CaseCalloutMockJSON.SERIAL_NUMBER);
    // Map<String, Object> deserializedRep = (Map<String, Object>)JSON.deserializeUntyped(rep);
    // List<Object> products = (List<Object>) deserializedRep.get(SMC_UTIL_CaseCalloutMockJSON.PRODUCTS);
    // System.assertEquals(3,Products.size());

    Test.stopTest();

    System.debug(
      LoggingLevel.INFO,
      '## >>> TEST_SMC_AC_LC_CaseController testgetInstalledProductInfosHTML:END <<< ##'
    );
  }

  /**
   * @description : test SMC_AC_LC_CaseController.getSalesOrderInfos()
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  @isTest
  public static void testgetSalesOrderInfos() {
    System.debug(
      LoggingLevel.INFO,
      '## >>> TEST_SMC_AC_LC_CaseController testgetSalesOrderInfos:START <<< ##'
    );

    SMC_UTIL_MockHttpResponseGenerator fakeResponse = new SMC_UTIL_MockHttpResponseGenerator(
      200,
      STA_UtilsStatic.COMPLETE,
      SMC_UTIL_CaseCalloutMockJSON.SALES_ORDER_DETAILS,
      null
    );
    Test.setMock(HttpCalloutMock.class, fakeResponse);
    SMC_UTIL_MockHttpResponseGenerator fakeResponse2 = new SMC_UTIL_MockHttpResponseGenerator(
      201,
      STA_UtilsStatic.COMPLETE,
      SMC_UTIL_CaseCalloutMockJSON.SALES_ORDER_DETAILS,
      null
    );
    Test.setMock(HttpCalloutMock.class, fakeResponse2);
    Test.startTest();
    List<SMC_DTO_SalesOrderDetails> responses = SMC_AC_LC_CaseController.getSalesOrderInfos(
      SMC_UTIL_CaseCalloutMockJSON.ORDER_NUMBER,
      null
    );
    System.assertEquals(
      2,
      responses.size(),
      'Mock is wrong. Check it and relaunch test.'
    );
    List<SMC_DTO_SalesOrderDetails> responsesFail = SMC_AC_LC_CaseController.getSalesOrderInfos(
      SMC_UTIL_CaseCalloutMockJSON.ORDER_NUMBER,
      null
    );
    Test.stopTest();

    System.debug(
      LoggingLevel.INFO,
      '## >>> TEST_SMC_AC_LC_CaseController testgetSalesOrderInfos:END <<< ##'
    );
  }

  /**
   * @description : test SMC_AC_LC_CaseController.getRelatedWarrantyCase()
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  @isTest
  public static void testGetRelatedWarrantyCase() {
    System.debug(
      LoggingLevel.INFO,
      '## >>> TEST_SMC_AC_LC_CaseController testGetRelatedWarrantyCase:START <<< ##'
    );

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

      Case firstCase = SMC_UTIL_TestUtils.createCase(
        STA_UtilsStatic.CASE_SUBJECT1,
        STA_UtilsStatic.CASE_DESCRIPTION1,
        STA_UtilsStatic.CASE_TYPE_WARRANTY_CLAIMS,
        STA_UtilsStatic.CASE_SUB_STATUS_OPEN
      );
      firstCase.AccountId = oneAccount.Id;
      firstCase.ContactId = oneContact.Id;
      firstCase.SMC_Serial_Number__c = '007';
      firstCase.SMC_Take_Ownership__c = true;
      Case secondCase = SMC_UTIL_TestUtils.createCase(
        STA_UtilsStatic.CASE_SUBJECT2,
        STA_UtilsStatic.CASE_DESCRIPTION2,
        STA_UtilsStatic.CASE_TYPE_WARRANTY_CLAIMS,
        STA_UtilsStatic.CASE_SUB_STATUS_OPEN
      );
      secondCase.AccountId = oneAccount.Id;
      secondCase.ContactId = oneContact.Id;
      secondCase.SMC_Serial_Number__c = '007';
      secondCase.SMC_Take_Ownership__c = true;
      Case firstCaseWithoutSerialNumber = SMC_UTIL_TestUtils.createCase(
        STA_UtilsStatic.CASE_SUBJECT1,
        STA_UtilsStatic.CASE_DESCRIPTION1,
        STA_UtilsStatic.CASE_TYPE_WARRANTY_CLAIMS,
        STA_UtilsStatic.CASE_SUB_STATUS_OPEN
      );
      firstCaseWithoutSerialNumber.AccountId = oneAccount.Id;
      firstCaseWithoutSerialNumber.ContactId = oneContact.Id;
      firstCaseWithoutSerialNumber.SMC_Take_Ownership__c = true;
      insert new List<Case>{
        firstCase,
        secondCase,
        firstCaseWithoutSerialNumber
      };

      Test.startTest();
      List<Case> resultWithSameSerialNumber = SMC_AC_LC_CaseController.getRelatedWarrantyCase(
        firstCase.Id
      );
      System.assertEquals(
        1,
        resultWithSameSerialNumber.size(),
        'Mock is wrong. Check it and relaunch test.'
      );
      List<Case> resultWithoutSameSerialNumber = SMC_AC_LC_CaseController.getRelatedWarrantyCase(
        firstCaseWithoutSerialNumber.Id
      );
      System.assertEquals(
        0,
        resultWithoutSameSerialNumber.size(),
        'Mock is wrong. Check it and relaunch test.'
      );
      Test.stopTest();

      PAD.bypassAll = false;
    }

    System.debug(
      LoggingLevel.INFO,
      '## >>> TEST_SMC_AC_LC_CaseController testGetRelatedWarrantyCase:END <<< ##'
    );
  }
}