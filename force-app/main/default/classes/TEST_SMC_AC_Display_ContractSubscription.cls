/**
 * @File Name          : TEST_SMC_AC_Display_ContractSubscription.cls
 * @Description        :
 * @Author             : Vincent RECASENS (Modis)
 * @Group              :
 * @Last Modified By   : Vincent RECASENS (Modis)
 * @Last Modified On   : 04-09-2021
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    30/03/2020   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
 **/
@IsTest
public with sharing class TEST_SMC_AC_Display_ContractSubscription {
  /**
   * @description : test SMC_AC_Display_ContractSubscription.initMethod()
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  @isTest
  public static void testInitMethod() {
    //Create Account/Contract/Product(App)/SMC_Contract_Subscription__c
    // Generate users
    Profile profileStandard = [
      SELECT Id
      FROM Profile
      WHERE Name = :STA_UtilsStatic.PROFILE_SALE_STANDARD
    ];
    User user1 = SMC_UTIL_TestUtils.createUser(
      STA_UtilsStatic.TEST_DIESE,
      STA_UtilsStatic.EMAIL_TEST,
      profileStandard.Id,
      STA_UtilsStatic.USERNAME_TEST,
      STA_UtilsStatic.USER_NICKNAME
    );
    user1.Bypass_Validation_Rule__c = 'SMC_NoEditProduct';
    // insert user1;

    System.runAs(user1) {
      // Generate Account
      Map<String, Schema.RecordTypeInfo> recordTypesAccount = new Map<String, Schema.RecordTypeInfo>();
      recordTypesAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName();
      Id recordTypeAccCustomerId = recordTypesAccount.get(
          STA_UtilsStatic.RECORDTYPE_ACCOUNT_CUSTOMER_DEVNAME
        )
        .getRecordTypeId();
      Account account1 = SMC_UTIL_TestUtils.createAccount(
        recordTypeAccCustomerId,
        STA_UtilsStatic.ACCOUNT_NAME1,
        STA_UtilsStatic.PICKLIST_ACCOUNT_TYPE_CUSTOMER,
        STA_UtilsStatic.ACCOUNT_BILLINGSTREET1,
        STA_UtilsStatic.ACCOUNT_BILLINGPOSTALCODE1,
        STA_UtilsStatic.ACCOUNT_BILLINGCITY1,
        STA_UtilsStatic.ACCOUNT_BILLINGSTATE1,
        STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY1,
        user1.Id,
        user1.Id,
        user1.Id,
        user1.Id,
        user1.Id
      );
      insert account1;

      Contact contact2 = SMC_UTIL_TestUtils.createContact(
        STA_UtilsStatic.CONTACT_FIRSTNAME2,
        STA_UtilsStatic.CONTACT_LASTNAME2,
        STA_UtilsStatic.CONTACT_PHONE2,
        STA_UtilsStatic.CONTACT_MOBILEPHONE2,
        STA_UtilsStatic.CONTACT_EMAIL2,
        null,
        null,
        null,
        null,
        STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY1,
        STA_UtilsStatic.EMPTY_STRING,
        account1.Id
      );
      insert contact2;

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
      oneProductApp.Family = 'IoT_Connectivity_Services';
      insert oneProductApp;

      //Installation
      SMC_Installation__c instal = new SMC_Installation__c();
      instal.Name = 'Test';
      instal.SMC_Description__c = 'Test desc';
      instal.SMC_Account__c = account1.Id;
      instal.SMC_Main_Contact__c = contact2.Id;
      insert instal;
      //Contract
      Contract oneContract = SMC_UTIL_TestUtils.createContract(
        'Contract ' + STA_UtilsStatic.TEST,
        account1.Id
      );
      oneContract.SMC_Installation__c = instal.Id;
      insert oneContract;

      //Subscription
      SMC_Contract_Subscription__c oneContractSubscription = SMC_UTIL_TestUtils.createContractSubscription(
        oneContract.Id,
        oneProductApp.Id
      );
      insert oneContractSubscription;

      //Launch method
      Test.startTest();
      List<SMC_AC_Display_ContractSubscription.ContractSubscriptionInformations> resultList = SMC_AC_Display_ContractSubscription.initMethod();
      Test.stopTest();

      System.assert(
        resultList.size() > 0,
        'There is no SMC_Contract_Subscription__c.'
      );
      System.assertEquals(
        oneContractSubscription.Id,
        resultList[0].id,
        'Can\'t retrieve SMC_Contract_Subscription__c'
      );
    }
  }
}