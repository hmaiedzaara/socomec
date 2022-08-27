/**
 * @description       :
 * @author            : Vincent RECASENS (Modis)
 * @group             :
 * @last modified on  : 02-11-2021
 * @last modified by  : Vincent RECASENS (Modis)
 * Modifications Log
 * Ver   Date         Author                     Modification
 * 1.0   12-24-2020   Vincent RECASENS (Modis)   Initial Version
 **/
@IsTest
public with sharing class TEST_SMC_AP_ManageLorawanKeysRequestor {
  @isTest
  public static void testSendToPardot() {
    //Guest
    Profile profileCustomerPortalGuestUser = [
      SELECT Id
      FROM Profile
      WHERE Name = :STA_UtilsStatic.PROFIL_CUSTOMER_PORTAL_NAME
    ];
    User userCustomerPortalRegistration = SMC_UTIL_TestUtils.createUser(
      'customerPortal-' + STA_UtilsStatic.USER_NICKNAME,
      'customerPortal-' + STA_UtilsStatic.USERNAME_TEST,
      profileCustomerPortalGuestUser.Id,
      'customerPortal-' + STA_UtilsStatic.USERNAME_TEST,
      'customerPortal-' + STA_UtilsStatic.USER_NICKNAME
    );
    insert userCustomerPortalRegistration;

    System.runAs(userCustomerPortalRegistration) {
      SMC_UTIL_MockHttpResponseGenerator fakeResponse = new SMC_UTIL_MockHttpResponseGenerator(
        200,
        STA_UtilsStatic.COMPLETE,
        STA_UtilsStatic.COMPLETE,
        null
      );
      Test.setMock(HttpCalloutMock.class, fakeResponse);
      SMC_Lorawan_Keys_Requestor__c newRequestor = new SMC_Lorawan_Keys_Requestor__c();
      newRequestor.First_Name__c = 'customerPortal';
      newRequestor.Last_Name__c = STA_UtilsStatic.USER_NICKNAME;
      newRequestor.Email__c = 'customerPortal-' + STA_UtilsStatic.USERNAME_TEST;
      newRequestor.Phone__c = null;
      newRequestor.Company__c = STA_UtilsStatic.ACCOUNT_NAME1;
      newRequestor.Country__c = STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY1;
      insert newRequestor;

      Boolean isSuccess = false;
      try {
        Test.startTest();
        newRequestor.Phone__c = '0606060606';
        update newRequestor;
        Test.stopTest();
        isSuccess = true;
      } catch (Exception e) {
        isSuccess = false;
        System.debug(
          'There is an error during callout. ERROR : ' + e.getMessage()
        );
      }
      System.assert(isSuccess, 'There is an error during callout.');
    }
  }
  @isTest
  public static void testSendToPardotBAD() {
    //Guest
    Profile profileCustomerPortalGuestUser = [
      SELECT Id
      FROM Profile
      WHERE Name = :STA_UtilsStatic.PROFIL_CUSTOMER_PORTAL_NAME
    ];
    User userCustomerPortalRegistration = SMC_UTIL_TestUtils.createUser(
      'customerPortal-' + STA_UtilsStatic.USER_NICKNAME,
      'customerPortal-' + STA_UtilsStatic.USERNAME_TEST,
      profileCustomerPortalGuestUser.Id,
      'customerPortal-' + STA_UtilsStatic.USERNAME_TEST,
      'customerPortal-' + STA_UtilsStatic.USER_NICKNAME
    );
    insert userCustomerPortalRegistration;

    System.runAs(userCustomerPortalRegistration) {
      SMC_UTIL_MockHttpResponseGenerator fakeResponse = new SMC_UTIL_MockHttpResponseGenerator(
        500,
        STA_UtilsStatic.COMPLETE,
        STA_UtilsStatic.COMPLETE,
        null
      );
      Test.setMock(HttpCalloutMock.class, fakeResponse);
      SMC_Lorawan_Keys_Requestor__c newRequestor = new SMC_Lorawan_Keys_Requestor__c();
      newRequestor.First_Name__c = 'customerPortal';
      newRequestor.Last_Name__c = STA_UtilsStatic.USER_NICKNAME;
      newRequestor.Email__c = 'customerPortal-' + STA_UtilsStatic.USERNAME_TEST;
      newRequestor.Phone__c = null;
      newRequestor.Company__c = STA_UtilsStatic.ACCOUNT_NAME1;
      newRequestor.Country__c = STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY1;
      insert newRequestor;

      Boolean isFail = false;
      newRequestor.Phone__c = '0606060606';
      try {
        Test.startTest();
        update newRequestor;
        Test.stopTest();
        isFail = false;
      } catch (Exception e) {
        isFail = true;
        System.debug(LoggingLevel.INFO, 'Error catched for code 500');
      }
      System.assert(isFail, 'Error Status != 200 is not catch');
    }
  }
}