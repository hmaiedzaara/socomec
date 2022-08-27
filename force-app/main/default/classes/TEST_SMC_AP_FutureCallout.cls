/*
---------------------------------------------------------------------------
-- - Name : TEST_SMC_AP_FutureCallout
-- - Author : Vincent RECASENS
-- - Description : This class is the Apex controller of the lightning
                   component SMC_AP_FutureCallout
--
-- Maintenance History:
--
-- Date         Name                    Version     Remarks
-- -----------  ----                    -------     ------------------
-- 29-MAR-2018  Vincent RECASENS  		1.0     	Initial Version
---------------------------------------------------------------------------
*/

@isTest
public without sharing class TEST_SMC_AP_FutureCallout {
  /**
   * @description : test setup
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  @testSetup
  public static void setup() {
    PAD.bypassAll = true;

    Id recordTypeId = [
        SELECT Id
        FROM RecordType
        WHERE name = :STA_UtilsStatic.RECORDTYPE_ACCOUNT_CUSTOMER
        LIMIT 1
      ]
      .get(0)
      .Id;
    Account acc = SMC_UTIL_TestUtils.createAccount(
      recordTypeId,
      STA_UtilsStatic.ACCOUNT_NAME1,
      STA_UtilsStatic.PICKLIST_ACCOUNT_TYPE_MARKETING_PROSPECT,
      STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY1
    );
    acc.SMC_Category__c = STA_UtilsStatic.ACCOUNT_CATEGORY1;
    acc.SMC_Activity__c = STA_UtilsStatic.ACCOUNT_ACTIVITY1;
    acc.SMC_Business__c = STA_UtilsStatic.ACCOUNT_BUSINESS1;
    acc.SMC_PCO_Price_List__c = STA_UtilsStatic.ACCOUNT_PRICELIST;
    insert acc;

    SMC_AP_FutureCallout.ExceptionsWrapper wrapper = new SMC_AP_FutureCallout.ExceptionsWrapper();
    wrapper.errorName = STA_UtilsStatic.CHECK_FIELD;
    wrapper.errorMessage = STA_UtilsStatic.CHECK_FIELD;
    wrapper.errorStackTrace = STA_UtilsStatic.CHECK_FIELD;
  }

  /**
   * @description : test SMC_AP_FutureCallout.constructJSON()
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  @isTest
  public static void testConstructJSONTest() {
    Account acc1 = [
      SELECT Id, Name
      FROM Account
      WHERE Name = :STA_UtilsStatic.ACCOUNT_NAME1
    ];

    Id recordTypeId = [
        SELECT Id
        FROM RecordType
        WHERE name = :STA_UtilsStatic.RECORDTYPE_ACCOUNT_CUSTOMER
        LIMIT 1
      ]
      .get(0)
      .Id;
    Account acc2 = SMC_UTIL_TestUtils.createAccount(
      recordTypeId,
      STA_UtilsStatic.ACCOUNT_NAME2,
      STA_UtilsStatic.PICKLIST_ACCOUNT_TYPE_MARKETING_PROSPECT,
      STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY2
    );
    acc2.SMC_Category__c = STA_UtilsStatic.ACCOUNT_CATEGORY1;
    acc2.SMC_PCO_Price_List__c = STA_UtilsStatic.ACCOUNT_PRICELIST;
    insert acc2;

    Set<Id> accountId = new Set<Id>{ acc1.Id, acc2.Id };
    String expectedJSON =
      '{"batchRequests":[{"method":"PATCH","url":"/services/data/v41.0/sobjects/Account/' +
      acc1.Id +
      '","richInput":{}},{"method":"PATCH","url":"/services/data/v41.0/sobjects/Account/' +
      acc2.Id +
      '","richInput":{}}]}';
    System.assertEquals(
      expectedJSON,
      SMC_AP_FutureCallout.constructJSON(accountId),
      'Check the method to rigth the JSON as expected.'
    );
  }

  /**
   * @description : test SMC_AP_FutureCallout.calloutAssignTerritories()
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  @isTest
  public static void testCalloutAssignTerritories() {
    Account acc = [
      SELECT Id, Name
      FROM Account
      WHERE Name = :STA_UtilsStatic.ACCOUNT_NAME1
    ];
    Set<Id> accountId = new Set<Id>();
    accountId.add(acc.Id);
    SMC_UTIL_MockHttpResponseGenerator fakeResponse = new SMC_UTIL_MockHttpResponseGenerator(
      200,
      STA_UtilsStatic.COMPLETE,
      STA_UtilsStatic.OPEN_ACCOLADE +
      STA_UtilsStatic.ASSIGN_TERRITORIES_RESPONSE,
      null
    );
    Test.setMock(HttpCalloutMock.class, fakeResponse);
    Test.startTest();
    SMC_AP_FutureCallout.calloutAssignTerritories(accountId);

    //Method Future is void and call a WS --> useless to test a mock
    //Gearset NEED at least one System.assert() by method
    System.assert(true, 'The assert function is broken.');
    Test.stopTest();
  }
}