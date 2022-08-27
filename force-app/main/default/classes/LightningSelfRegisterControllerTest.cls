/**
 * @File Name          : LightningSelfRegisterControllerTest.cls
 * @Description        :
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              :
 * @Last Modified By   : Vincent RECASENS (Modis)
 * @Last Modified On   : 10/04/2020 à 11:08:24
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    11/12/2019   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
 **/
@IsTest(SeeAllData=true)
public without sharing class LightningSelfRegisterControllerTest {
  /* Verifies that IsValidPassword method with various password combinations. */
  @IsTest
  static void testIsValidPassword() {
    System.assert(
      LightningSelfRegisterController.isValidPassword(
        'password?@12334',
        'password?@12334'
      ) == true
    );
    System.assert(
      LightningSelfRegisterController.isValidPassword(
        'password?@12334',
        'dummyPassword'
      ) == false
    );
    System.assert(
      LightningSelfRegisterController.isValidPassword(
        'password?@12334',
        null
      ) == false
    );
    System.assert(
      LightningSelfRegisterController.isValidPassword(null, 'fakePwd') == false
    );
  }

  @IsTest
  static void testSiteAsContainerEnabled() {
    String urlTest = 'https://test.salesforce.com';
    System.assertNotEquals(
      null,
      LightningSelfRegisterController.siteAsContainerEnabled(urlTest)
    );
  }

  /* Verifies the selfRegistration method flow with various invalid inputs */
  @IsTest
  static void testSelfRegistration() {
    Map<String, String> paramsMap = initializeParams();
    System.assertNotEquals(null, paramsMap);
    System.assertEquals(
      Label.Site.lastname_is_required,
      LightningSelfRegisterController.selfRegister(
        paramsMap.get('firstName'),
        STA_UtilsStatic.EMPTY_STRING,
        paramsMap.get('email'),
        paramsMap.get('password'),
        paramsMap.get('confirmPasswordCorrect'),
        null,
        paramsMap.get('regConfirmUrl'),
        null,
        paramsMap.get('startUrl'),
        true
      )
    );
    System.assertEquals(
      Label.Site.email_is_required,
      LightningSelfRegisterController.selfRegister(
        paramsMap.get('firstName'),
        paramsMap.get('lastName'),
        STA_UtilsStatic.EMPTY_STRING,
        paramsMap.get('password'),
        paramsMap.get('confirmPasswordCorrect'),
        null,
        paramsMap.get('regConfirmUrl'),
        null,
        paramsMap.get('startUrl'),
        true
      )
    );
    System.assertEquals(
      Label.Site.email_is_required,
      LightningSelfRegisterController.selfRegister(
        null,
        paramsMap.get('lastName'),
        STA_UtilsStatic.EMPTY_STRING,
        null,
        paramsMap.get('confirmPasswordCorrect'),
        null,
        paramsMap.get('regConfirmUrl'),
        null,
        paramsMap.get('startUrl'),
        true
      )
    );
    System.assertEquals(
      Label.site.passwords_dont_match,
      LightningSelfRegisterController.selfRegister(
        paramsMap.get('firstName'),
        paramsMap.get('lastName'),
        paramsMap.get('email'),
        paramsMap.get('password'),
        paramsMap.get('confirmPasswordWrong'),
        null,
        paramsMap.get('regConfirmUrl'),
        null,
        paramsMap.get('startUrl'),
        true
      )
    );
    System.assertNotEquals(
      null,
      LightningSelfRegisterController.selfRegister(
        paramsMap.get('firstName'),
        paramsMap.get('lastName'),
        STA_UtilsStatic.EMPTY_STRING,
        paramsMap.get('password'),
        paramsMap.get('confirmPasswordWrong'),
        null,
        paramsMap.get('regConfirmUrl'),
        null,
        paramsMap.get('startUrl'),
        false
      )
    );
  }

  /* Verifies the selfRegistration flow for valid inputs */
  @IsTest
  static void testSelfRegisterWithProperCredentials() {
    Map<String, String> paramsMap = initializeParams();
    System.assertEquals(
      null,
      LightningSelfRegisterController.selfRegister(
        paramsMap.get('firstName'),
        paramsMap.get('lastName'),
        paramsMap.get('email'),
        paramsMap.get('password'),
        paramsMap.get('confirmPasswordCorrect'),
        null,
        paramsMap.get('regConfirmUrl'),
        null,
        paramsMap.get('startUrl'),
        true
      )
    );
  }

  /* Verifies SelfRegistration flow with an accounId that is created within the test */
  @IsTest
  static void testSelfRegisterWithCreatedAccount() {
    //   Account acc = new Account(name = 'test acc');
    PAD.bypassAll = true;
    Id userId1 = UserInfo.getUserId();
    Id recordTypeAccCustomerId = [
        SELECT Id
        FROM RecordType
        WHERE name = :STA_UtilsStatic.RECORDTYPE_ACCOUNT_CUSTOMER
        LIMIT 1
      ]
      .get(0)
      .Id;
    Account acc = SMC_UTIL_TestUtils.createAccount(
      recordTypeAccCustomerId,
      'test acc',
      STA_UtilsStatic.PICKLIST_ACCOUNT_TYPE_CUSTOMER,
      STA_UtilsStatic.ACCOUNT_BILLINGSTREET1,
      STA_UtilsStatic.ACCOUNT_BILLINGPOSTALCODE1,
      STA_UtilsStatic.ACCOUNT_BILLINGCITY1,
      STA_UtilsStatic.ACCOUNT_BILLINGSTATE1,
      STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY1,
      userId1,
      userId1,
      userId1,
      userId1,
      userId1
    );
    insert acc;
    List<Account> accounts = [SELECT Id FROM Account LIMIT 1];
    System.assert(
      !accounts.isEmpty(),
      'There must be at least one account in this environment!'
    );
    String accountId = accounts[0].Id;
    Map<String, String> paramsMap = initializeParams();
    System.assertEquals(
      null,
      LightningSelfRegisterController.selfRegister(
        paramsMap.get('firstName'),
        paramsMap.get('lastName'),
        paramsMap.get('email'),
        paramsMap.get('password'),
        paramsMap.get('confirmPasswordCorrect'),
        accountId,
        paramsMap.get('regConfirmUrl'),
        null,
        paramsMap.get('startUrl'),
        false
      )
    );
  }

  @IsTest
  static void testGetNullExtraFields() {
    System.assertEquals(
      new List<Map<String, Object>>(),
      LightningSelfRegisterController.getExtraFields(null)
    );
  }

  @IsTest
  static void testGetNonEmptyExtraFields() {
    System.assertEquals(
      new List<Map<String, Object>>(),
      LightningSelfRegisterController.getExtraFields('field1')
    );
  }

  /* Verifies validation of extraFields within the Self Registration flow */
  @IsTest
  static void testGetExtraFieldsInSelfRegistration() {
    List<Map<String, Object>> fieldlist = new List<Map<String, Object>>();
    Map<String, String> paramsMap = initializeParams();
    Map<String, Object> fieldMap = new Map<String, Object>();
    fieldMap.put('description', 'new field');
    fieldMap.put('fieldPath', 'dummyPath');
    fieldlist.add(fieldMap);
    String extraFields = JSON.serialize(fieldlist);
    System.assertNotEquals(
      null,
      LightningSelfRegisterController.selfRegister(
        paramsMap.get('firstName'),
        paramsMap.get('lastName'),
        paramsMap.get('email'),
        paramsMap.get('password'),
        paramsMap.get('confirmPasswordCorrect'),
        null,
        paramsMap.get('regConfirmUrl'),
        extraFields,
        paramsMap.get('startUrl'),
        true
      )
    );
  }

  @IsTest
  static void LightningSelfRegisterControllerInstantiation() {
    LightningSelfRegisterController controller = new LightningSelfRegisterController();
    System.assertNotEquals(controller, null);
  }

  /* Helper method to initialize the parameters required for SelfRegistration. */
  private static Map<String, String> initializeParams() {
    Map<String, String> paramsMap = new Map<String, String>();
    String firstName = 'test';
    String lastName = 'User';
    String email = 'testUser@salesforce.com';
    String password = 'testuser123';
    String confirmPasswordCorrect = 'testuser123';
    String confirmPasswordWrong = 'wrongpassword';
    String accountId = 'testuser123';
    String regConfirmUrl = 'http://registration-confirm.com';
    String startUrl = 'http://my.company.salesforce.com';
    paramsMap.put('firstName', firstName);
    paramsMap.put('lastName', lastName);
    paramsMap.put('email', email);
    paramsMap.put('password', password);
    paramsMap.put('confirmPasswordCorrect', confirmPasswordCorrect);
    paramsMap.put('confirmPasswordWrong', confirmPasswordWrong);
    paramsMap.put('accountId', accountId);
    paramsMap.put('regConfirmUrl', regConfirmUrl);
    paramsMap.put('startUrl', startUrl);
    return paramsMap;
  }
}