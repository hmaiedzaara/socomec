/*
---------------------------------------------------------------------------
-- - Name : TEST_SMC_AP_CaseCallout
-- - Author : Vincent RECASENS
-- - Description : This class is the test of SMC_AP_CaseCallout
--
-- Maintenance History:
--
-- Date         Name        Version     Remarks
-- -----------  ----        -------     ------------------
-- 16-NOV-2018  VRE  		1.0     	Initial Version
---------------------------------------------------------------------------
*/

@isTest
public without sharing class TEST_SMC_AP_CaseCallout {
  /**
   * @description : test SMC_AP_CaseCallout.getEndpointWebmethod()
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  @isTest
  public static void testGetEndpointWebmethod() {
    Case_Callout__mdt caseCalloutInformtions = new Case_Callout__mdt();
    caseCalloutInformtions = SMC_AP_CaseCallout.getEndpointWebmethod(
      STA_UtilsStatic.INSTALLED_PRODUCT_INFORMATIONS
    );
    System.assert(caseCalloutInformtions != null, 'Metadata has changed.');
  }

  /** UNSED COMPONENT AND METHOD - CODE COVERAGE --> To delete in Apex class **/
  @isTest
  public static void testGetInstalledProductInfosHTML() {
    //TEST
    SMC_UTIL_MockHttpResponseGenerator fakeResponse = new SMC_UTIL_MockHttpResponseGenerator(
      200,
      STA_UtilsStatic.COMPLETE,
      SMC_UTIL_CaseCalloutMockJSON.INSTALLED_PRODUCT_INFO,
      null
    );
    Test.setMock(HttpCalloutMock.class, fakeResponse);

    Test.startTest();
    String rep = SMC_AP_CaseCallout.getInstalledProductInfosHTML(
      SMC_UTIL_CaseCalloutMockJSON.SERIAL_NUMBER_FOR_MOCK,
      new List<String>{ STA_UtilsStatic.TEST }
    );
    System.assert(
      rep.startsWith('<html>'),
      'Mock is wrong. Check it and relaunch test.'
    );
    Test.stopTest();
  }

  /** UNSED COMPONENT AND METHOD - CODE COVERAGE --> To delete in Apex class **/
  @isTest
  public static void testGetInstalledProductInfosHTMLBADJSON() {
    //TEST
    SMC_UTIL_MockHttpResponseGenerator fakeResponse = new SMC_UTIL_MockHttpResponseGenerator(
      200,
      STA_UtilsStatic.COMPLETE,
      '',
      null
    );
    Test.setMock(HttpCalloutMock.class, fakeResponse);

    Test.startTest();
    String rep = SMC_AP_CaseCallout.getInstalledProductInfosHTML(
      SMC_UTIL_CaseCalloutMockJSON.SERIAL_NUMBER_FOR_MOCK,
      new List<String>{ STA_UtilsStatic.TEST }
    );
    System.assert(
      !rep.startsWith('<html>'),
      'Mock is wrong. Check it and relaunch test.'
    );
    Test.stopTest();
  }

  /** UNSED COMPONENT AND METHOD - CODE COVERAGE --> To delete in Apex class **/
  @isTest
  public static void testGetInstalledProductInfosHTMLBADCode() {
    //TEST
    SMC_UTIL_MockHttpResponseGenerator fakeResponse = new SMC_UTIL_MockHttpResponseGenerator(
      500,
      STA_UtilsStatic.COMPLETE,
      SMC_UTIL_CaseCalloutMockJSON.INSTALLED_PRODUCT_INFO,
      null
    );
    Test.setMock(HttpCalloutMock.class, fakeResponse);

    Test.startTest();
    String rep = SMC_AP_CaseCallout.getInstalledProductInfosHTML(
      SMC_UTIL_CaseCalloutMockJSON.SERIAL_NUMBER_FOR_MOCK,
      new List<String>{ STA_UtilsStatic.TEST }
    );
    System.assert(
      rep.startsWith('<html>'),
      'Mock is wrong. Check it and relaunch test.'
    );
    Test.stopTest();
  }

  @isTest
  public static void testGetSalesOrderInfos() {
    //TEST
    SMC_UTIL_MockHttpResponseGenerator fakeResponse = new SMC_UTIL_MockHttpResponseGenerator(
      200,
      STA_UtilsStatic.COMPLETE,
      SMC_UTIL_CaseCalloutMockJSON.SALES_ORDER_DETAILS,
      null
    );
    Test.setMock(HttpCalloutMock.class, fakeResponse);

    Test.startTest();
    List<SMC_DTO_SalesOrderDetails> rep = SMC_AP_CaseCallout.getSalesOrderInfos(
      SMC_UTIL_CaseCalloutMockJSON.SERIAL_NUMBER_FOR_MOCK,
      new List<String>{ STA_UtilsStatic.TEST }
    );
    System.assertNotEquals(
      0,
      rep.size(),
      'Mock is wrong. Check it and relaunch test.'
    );
    Test.stopTest();
  }

  @isTest
  public static void testGetSalesOrderInfosBADJSON() {
    //TEST
    SMC_UTIL_MockHttpResponseGenerator fakeResponse = new SMC_UTIL_MockHttpResponseGenerator(
      500,
      STA_UtilsStatic.COMPLETE,
      '',
      null
    );
    Test.setMock(HttpCalloutMock.class, fakeResponse);

    Test.startTest();
    List<SMC_DTO_SalesOrderDetails> rep = SMC_AP_CaseCallout.getSalesOrderInfos(
      SMC_UTIL_CaseCalloutMockJSON.SERIAL_NUMBER_FOR_MOCK,
      new List<String>{ STA_UtilsStatic.TEST }
    );
    System.assertEquals(
      0,
      rep.size(),
      'Mock is wrong. Check it and relaunch test.'
    );
    Test.stopTest();
  }

  @isTest
  public static void testGetSalesOrderInfosBADCode() {
    //TEST
    SMC_UTIL_MockHttpResponseGenerator fakeResponse = new SMC_UTIL_MockHttpResponseGenerator(
      500,
      STA_UtilsStatic.COMPLETE,
      SMC_UTIL_CaseCalloutMockJSON.SALES_ORDER_DETAILS,
      null
    );
    Test.setMock(HttpCalloutMock.class, fakeResponse);

    Test.startTest();
    List<SMC_DTO_SalesOrderDetails> rep = SMC_AP_CaseCallout.getSalesOrderInfos(
      SMC_UTIL_CaseCalloutMockJSON.SERIAL_NUMBER_FOR_MOCK,
      new List<String>{ STA_UtilsStatic.TEST }
    );
    System.assertNotEquals(
      0,
      rep.size(),
      'Mock is wrong. Check it and relaunch test.'
    );
    Test.stopTest();
  }

  @isTest
  public static void testGetSNProductInfo() {
    //TEST
    SMC_UTIL_MockHttpResponseGenerator fakeResponse = new SMC_UTIL_MockHttpResponseGenerator(
      200,
      STA_UtilsStatic.COMPLETE,
      SMC_UTIL_CaseCalloutMockJSON.SN_PRODUCT_INFO,
      null
    );
    Test.setMock(HttpCalloutMock.class, fakeResponse);

    Test.startTest();
    List<SMC_DTO_SN_ProductInfo> rep = SMC_AP_CaseCallout.getSNProductInfo(
      SMC_UTIL_CaseCalloutMockJSON.SERIAL_NUMBER_FOR_MOCK,
      new List<String>{ STA_UtilsStatic.TEST }
    );
    System.assertNotEquals(
      0,
      rep.size(),
      'Mock is wrong. Check it and relaunch test.'
    );
    Test.stopTest();
  }

  @isTest
  public static void testGetSNProductInfoBADJSON() {
    //TEST
    SMC_UTIL_MockHttpResponseGenerator fakeResponse = new SMC_UTIL_MockHttpResponseGenerator(
      200,
      STA_UtilsStatic.COMPLETE,
      '',
      null
    );
    Test.setMock(HttpCalloutMock.class, fakeResponse);

    Test.startTest();
    List<SMC_DTO_SN_ProductInfo> rep = SMC_AP_CaseCallout.getSNProductInfo(
      SMC_UTIL_CaseCalloutMockJSON.SERIAL_NUMBER_FOR_MOCK,
      new List<String>{ STA_UtilsStatic.TEST }
    );
    System.assertEquals(
      0,
      rep.size(),
      'Mock is wrong. Check it and relaunch test.'
    );
    Test.stopTest();
  }

  @isTest
  public static void testGetSNProductInfoBADCode() {
    //TEST
    SMC_UTIL_MockHttpResponseGenerator fakeResponse = new SMC_UTIL_MockHttpResponseGenerator(
      500,
      STA_UtilsStatic.COMPLETE,
      SMC_UTIL_CaseCalloutMockJSON.SN_PRODUCT_INFO,
      null
    );
    Test.setMock(HttpCalloutMock.class, fakeResponse);

    Test.startTest();
    List<SMC_DTO_SN_ProductInfo> rep = SMC_AP_CaseCallout.getSNProductInfo(
      SMC_UTIL_CaseCalloutMockJSON.SERIAL_NUMBER_FOR_MOCK,
      new List<String>{ STA_UtilsStatic.TEST }
    );
    System.assertNotEquals(
      0,
      rep.size(),
      'Mock is wrong. Check it and relaunch test.'
    );
    Test.stopTest();
  }

  @isTest
  public static void testCreateCimsaVisit() {
    //TEST
    SMC_UTIL_MockHttpResponseGenerator fakeResponse = new SMC_UTIL_MockHttpResponseGenerator(
      200,
      STA_UtilsStatic.COMPLETE,
      SMC_UTIL_CaseCalloutMockJSON.CIMSA_VISIT_MOCK,
      null
    );
    Test.setMock(HttpCalloutMock.class, fakeResponse);

    Test.startTest();
    SMC_DTO_CimsaVisit rep = SMC_AP_CaseCallout.createCimsaVisit(
      SMC_UTIL_CaseCalloutMockJSON.SERIAL_NUMBER_FOR_MOCK,
      new List<String>{ STA_UtilsStatic.TEST }
    );
    System.assertEquals(
      'INSERT_VISIT_FOR_SOCOLINE',
      rep.PS,
      'Mock is wrong. Check it and relaunch test.'
    );
    Test.stopTest();
  }

  @isTest
  public static void testCreateCimsaVisitBADJSON() {
    //TEST
    SMC_UTIL_MockHttpResponseGenerator fakeResponse = new SMC_UTIL_MockHttpResponseGenerator(
      200,
      STA_UtilsStatic.COMPLETE,
      '',
      null
    );
    Test.setMock(HttpCalloutMock.class, fakeResponse);

    Test.startTest();
    SMC_DTO_CimsaVisit rep = SMC_AP_CaseCallout.createCimsaVisit(
      SMC_UTIL_CaseCalloutMockJSON.SERIAL_NUMBER_FOR_MOCK,
      new List<String>{ STA_UtilsStatic.TEST }
    );
    System.assertEquals(
      null,
      rep.PS,
      'Mock is wrong. Check it and relaunch test.'
    );
    Test.stopTest();
  }

  @isTest
  public static void testCreateCimsaVisitBADCode() {
    //TEST
    SMC_UTIL_MockHttpResponseGenerator fakeResponse = new SMC_UTIL_MockHttpResponseGenerator(
      500,
      STA_UtilsStatic.COMPLETE,
      SMC_UTIL_CaseCalloutMockJSON.CIMSA_VISIT_MOCK,
      null
    );
    Test.setMock(HttpCalloutMock.class, fakeResponse);

    Test.startTest();
    SMC_DTO_CimsaVisit rep = SMC_AP_CaseCallout.createCimsaVisit(
      SMC_UTIL_CaseCalloutMockJSON.SERIAL_NUMBER_FOR_MOCK,
      new List<String>{ STA_UtilsStatic.TEST }
    );
    System.assertEquals(
      'INSERT_VISIT_FOR_SOCOLINE',
      rep.PS,
      'Mock is wrong. Check it and relaunch test.'
    );
    Test.stopTest();
  }
}