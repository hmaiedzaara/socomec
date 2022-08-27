/**
 * @description       : Class test of SMC_AC_Case_Order_Tracking
 * @author            : Vincent RECASENS (Modis)
 * @group             : 
 * @last modified on  : 05-11-2021
 * @last modified by  : Vincent RECASENS (Modis)
 * Modifications Log 
 * Ver   Date         Author                     Modification
 * 1.0   05-11-2021   Vincent RECASENS (Modis)   Initial Version
**/
@IsTest
public with sharing class TEST_SMC_AC_Case_Order_Tracking {

    @TestSetup
    public static void setup(){
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
        System.runAs(userStandard){
            //Account
            Map<String, Schema.RecordTypeInfo> recordTypesAccount = new Map<String, Schema.RecordTypeInfo>();
            recordTypesAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName();
            Id recordTypeIdAcc = recordTypesAccount.get(
                STA_UtilsStatic.RECORDTYPE_ACCOUNT_CUSTOMER_DEVNAME
              )
              .getRecordTypeId();
            Account oneAccount = SMC_UTIL_TestUtils.createAccount(
                recordTypeIdAcc,
            STA_UtilsStatic.TEST + STA_UtilsStatic.ACCOUNT,
            STA_UtilsStatic.PICKLIST_ACCOUNT_TYPE_MARKETING_PROSPECT,
            STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY1
            );
            oneAccount.AccountNumber = 'ACC-{000001}';
            insert oneAccount;
            //Contact
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
            //Case
            Case oneCase = SMC_UTIL_TestUtils.createCase(
            STA_UtilsStatic.CASE_SUBJECT2,
            STA_UtilsStatic.CASE_DESCRIPTION2,
            STA_UtilsStatic.CASE_TYPE_TOOL_SUPPORT,
            STA_UtilsStatic.CASE_SUB_STATUS_OPEN,
            STA_UtilsStatic.CASE_SUB_STATUS_OPEN
            );
            oneCase.AccountId = oneAccount.Id;
            oneCase.ContactId = oneContact.Id;
            oneCase.SMC_ERP_Order_Number__c = '100031';
            oneCase.OwnerId = userStandard.Id;
            insert new List<Case>{ oneCase };
        }
    }
    
    @isTest
    public static void testInitializeTabOK(){
        User userStandard = [SELECT Id FROM User WHERE Email = :('standard-' + STA_UtilsStatic.USERNAME_TEST)];
        System.runAs(userStandard){
            SMC_UTIL_MockHttpResponseGenerator fakeResponse = new SMC_UTIL_MockHttpResponseGenerator(
                200,
                STA_UtilsStatic.COMPLETE,
                'validFakeMock',
                null
            );
  
            Test.setMock(HttpCalloutMock.class, fakeResponse);
            String responseResultString;
            Test.startTest();
                responseResultString = SMC_AC_Case_Order_Tracking.initialisationTab([SELECT Id FROM Case LIMIT 1].Id, 'Internal');
            Test.stopTest();

            SMC_AC_Case_Order_Tracking.WrapperInformation responseResult = 
                (SMC_AC_Case_Order_Tracking.WrapperInformation) JSON.deserialize(responseResultString, SMC_AC_Case_Order_Tracking.WrapperInformation.class);
            System.assertEquals(
                'validFakeMock',
                responseResult.jsonResult
            );
        }
    }
    
    @isTest
    public static void testInitializeTabBADCode(){
        User userStandard = [SELECT Id FROM User WHERE Email = :('standard-' + STA_UtilsStatic.USERNAME_TEST)];
        System.runAs(userStandard){
            SMC_UTIL_MockHttpResponseGenerator fakeResponse = new SMC_UTIL_MockHttpResponseGenerator(
                500,
                STA_UtilsStatic.COMPLETE,
                'badCodeFakeMock',
                null
            );
  
            Test.setMock(HttpCalloutMock.class, fakeResponse);
            String responseResultString;
            Test.startTest();
                responseResultString = SMC_AC_Case_Order_Tracking.initialisationTab([SELECT Id FROM Case LIMIT 1].Id, 'Internal');
            Test.stopTest();
        
            SMC_AC_Case_Order_Tracking.WrapperInformation responseResult = 
                (SMC_AC_Case_Order_Tracking.WrapperInformation) JSON.deserialize(responseResultString, SMC_AC_Case_Order_Tracking.WrapperInformation.class);
            System.assertEquals(
                '',
                responseResult.jsonResult
            );
        }
    }
}