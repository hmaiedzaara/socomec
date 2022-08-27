/**
 * @File Name          : TEST_SMC_AC_MyApplications.cls
 * @Description        :
 * @Author             : Vincent RECASENS (Modis)
 * @Group              :
 * @Last Modified By   : Vincent RECASENS (Modis)
 * @Last Modified On   : 04-09-2021
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    08/06/2020   Vincent RECASENS (Modis)     Initial Version
 **/
@IsTest
public class TEST_SMC_AC_MyApplications {
  @isTest
  public static void testGetRecords() {
    //Create Account
    Id recordTypeIdAccount = [
      SELECT Id
      FROM RecordType
      WHERE name = :STA_UtilsStatic.RECORDTYPE_ACCOUNT_CUSTOMER
    ]
    .Id;
    Account account = SMC_UTIL_TestUtils.createAccount(
      recordTypeIdAccount,
      STA_UtilsStatic.TEST + STA_UtilsStatic.ACCOUNT,
      STA_UtilsStatic.PICKLIST_ACCOUNT_TYPE_MARKETING_PROSPECT,
      STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY1
    );
    account.AccountNumber = 'ACC-{000001}';
    insert account;

    Contact contact = SMC_UTIL_TestUtils.createContact(
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
      account.Id
    );
    insert contact;

    //Set the User
    Profile profile = [
      SELECT Id
      FROM Profile
      WHERE Name = :STA_UtilsStatic.PROFILE_SMC_PARTNER_COMMUNITY
    ];
    User userPartner = SMC_UTIL_TestUtils.createUser(
      STA_UtilsStatic.USER_NICKNAME,
      STA_UtilsStatic.USERNAME_TEST,
      profile.Id,
      STA_UtilsStatic.USERNAME_TEST,
      STA_UtilsStatic.USER_NICKNAME
    );
    userPartner.ContactId = contact.Id;
    insert new List<User>{ userPartner };

    //Product
    Map<String, Schema.RecordTypeInfo> recordTypesProduct = new Map<String, Schema.RecordTypeInfo>();
    recordTypesProduct = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName();
    Id salesProductRecordType = recordTypesProduct.get(
        STA_UtilsStatic.RECORDTYPE_SALES_PRODUCT
      )
      .getRecordTypeId();
    Product2 oneProductApp = SMC_UTIL_TestUtils.createProductFSL(
      salesProductRecordType,
      'App ' + STA_UtilsStatic.TEST,
      true
    );
    oneProductApp.DisplayUrl = 'https://google.com';
    oneProductApp.Family = 'IoT_Applications_Services';
    insert oneProductApp;

    // //Contract
    // Contract oneContract = SMC_UTIL_TestUtils.createContract(
    //   'Contract ' + STA_UtilsStatic.TEST,
    //   account.Id
    // );
    // insert oneContract;

    // //Subscription
    // SMC_Contract_Subscription__c oneContractSubscription = SMC_UTIL_TestUtils.createContractSubscription(
    //   oneContract.Id,
    //   oneProductApp.Id
    // );
    // insert oneContractSubscription;

    //Installation
    SMC_Installation__c instal = new SMC_Installation__c();
    instal.Name = 'Test';
    instal.SMC_Description__c = 'Test desc';
    instal.SMC_Account__c = account.Id;
    instal.SMC_Main_Contact__c = contact.Id;
    insert instal;

    Contract oneContract;
    SMC_Contract_Subscription__c oneContractSubscription;
    String jsonResult;
    System.runAs(userPartner) {
      //Contract
      oneContract = SMC_UTIL_TestUtils.createContract(
        'Contract ' + STA_UtilsStatic.TEST,
        account.Id
      );
      oneContract.SMC_Installation__c = instal.Id;
      insert oneContract;
      //Subscription
      oneContractSubscription = SMC_UTIL_TestUtils.createContractSubscription(
        oneContract.Id,
        oneProductApp.Id
      );
      insert oneContractSubscription;

      // Result
      jsonResult = SMC_AC_MyApplications.getRecords(
        'Applications',
        'MySpace',
        null
      );
    }

    List<SMC_AC_MyApplications.Wrapper> result = (List<SMC_AC_MyApplications.Wrapper>) JSON.deserialize(
      jsonResult,
      List<SMC_AC_MyApplications.Wrapper>.class
    );

    SMC_Contract_Subscription__c checkRsult = [
      SELECT
        Id,
        Product__r.SMC_App_Picture_Path__c,
        Product__r.Name,
        Product__r.DisplayUrl
      FROM SMC_Contract_Subscription__c
      WHERE Id = :oneContractSubscription.Id
    ];
    System.assertEquals(1, result.size());
    System.assertEquals(checkRsult.Id, result[0].id);
    System.assertEquals(
      checkRsult.Product__r.SMC_App_Picture_Path__c,
      result[0].picture
    );
    System.assertEquals(checkRsult.Product__r.Name, result[0].name);
    System.assertEquals(checkRsult.Product__r.DisplayUrl, result[0].url);
    System.assertEquals(
      '/customerportal/s/smc-contract-subscription/' +
      checkRsult.Id +
      '/detail',
      result[0].toTheRecord
    );
  }
}