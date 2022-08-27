/*
-----------------------------------------------------------------------------------
-- - Name : TEST_SMC_AC_ERP_Line
-- - Author : Vincent RECASENS
-- - Description : This class test the Apex controller SMC_AC_ERP_Line
--
-- Maintenance History:
--
-- Date         Name   Version     Remarks
-- -----------  ----   -------     ----------------------------
-- 06-NOV-2019  VRE    1.0         Initial Version
------------------------------------------------------------------------------------
*/

@IsTest
public with sharing class TEST_SMC_AC_ERP_Line {
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
    Account account = SMC_UTIL_TestUtils.createAccount(
      recordTypeId,
      STA_UtilsStatic.TEST,
      STA_UtilsStatic.PICKLIST_ACCOUNT_TYPE_MARKETING_PROSPECT,
      STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY2
    );
    account.AccountNumber = 'ACC_11913';
    insert account;

    SMC_ERP_Invoice__c invoiceElement = SMC_UTIL_TestUtils.createERPInvoice(
      STA_UtilsStatic.TEST + '_001',
      117.0,
      account.Id
    );
    insert invoiceElement;
    SMC_ERP_Order__c orderElement = SMC_UTIL_TestUtils.createERPOrder(
      STA_UtilsStatic.TEST + '_001',
      117.0,
      account.Id
    );
    insert orderElement;
    SMC_ERP_Quote__c quoteElement = SMC_UTIL_TestUtils.createERPQuote(
      STA_UtilsStatic.TEST + '_001',
      117.0,
      account.Id
    );
    quoteElement.SMC_ERP_Quote_Id__c = '1640160603';
    insert quoteElement;

    //Code coverage
    SMC_AC_ERP_Line.WrapperData newWrapperDataEmpty = new SMC_AC_ERP_Line.WrapperData();
    SMC_AC_ERP_Line.WrapperDataUnit newWrapperDataUnitEmpty = new SMC_AC_ERP_Line.WrapperDataUnit();
  }

  /**
   * @description : test SMC_AC_ERP_Line.initialization(Invoice) [OK]
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  @isTest
  public static void testInitializationInvoiceOK() {
    StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
    mock.setStaticResource(STA_UtilsStatic.MOCK_ERP_OBJECTS_INVOICE);
    mock.setStatusCode(200);
    SMC_Endpoint_ERPObject__mdt complementaryEndpoint = [
      SELECT
        URL_Endpoint_Invoice__c,
        URL_Endpoint_Order__c,
        URL_Endpoint_Quote__c,
        Authorization__c,
        Is_Mocking_Mode__c
      FROM SMC_Endpoint_ERPObject__mdt
      LIMIT 1
    ];
    mock.setHeader(
      STA_UtilsStatic.CONTENT_TYPE,
      STA_UtilsStatic.APPLICATION_X_WWW_FORM_URLENCODED
    );
    Blob basicAuthBlob = Blob.valueOf(complementaryEndpoint.Authorization__c);
    String basicAuthHeader =
      STA_UtilsStatic.BASIC +
      STA_UtilsStatic.SPACE +
      EncodingUtil.base64Encode(basicAuthBlob);
    mock.setHeader(STA_UtilsStatic.AUTHORIZATION, basicAuthHeader);

    // Set the mock callout mode
    Test.setMock(HttpCalloutMock.class, mock);

    Test.startTest();
    SMC_AC_ERP_Line.WrapperData result = SMC_AC_ERP_Line.initialization(
      [
        SELECT Id
        FROM SMC_ERP_Invoice__c
        WHERE Name = :STA_UtilsStatic.TEST + '_001'
      ]
      .Id
    );
    Test.stopTest();

    System.assertEquals(
      STA_UtilsStatic.ICON_ERP_INVOICE,
      result.iconName,
      'Mock is wrong. Check it and relaunch test.'
    );
    System.assertEquals(
      STA_UtilsStatic.ERP_INVOICE_LINES,
      result.erpLineTitle,
      'Mock is wrong. Check it and relaunch test.'
    );
  }

  /**
   * @description : test SMC_AC_ERP_Line.initialization(Invoice) [BAD]
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  @isTest
  public static void testInitializationInvoiceBADCallout() {
    StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
    mock.setStaticResource(STA_UtilsStatic.MOCK_ERP_OBJECTS_INVOICE);
    mock.setStatus(STA_UtilsStatic.ERROR_NOT_FOUND);
    mock.setStatusCode(404);
    SMC_Endpoint_ERPObject__mdt complementaryEndpoint = [
      SELECT
        URL_Endpoint_Invoice__c,
        URL_Endpoint_Order__c,
        URL_Endpoint_Quote__c,
        Authorization__c,
        Is_Mocking_Mode__c
      FROM SMC_Endpoint_ERPObject__mdt
      LIMIT 1
    ];
    mock.setHeader(
      STA_UtilsStatic.CONTENT_TYPE,
      STA_UtilsStatic.APPLICATION_X_WWW_FORM_URLENCODED
    );
    Blob basicAuthBlob = Blob.valueOf(complementaryEndpoint.Authorization__c);
    String basicAuthHeader =
      STA_UtilsStatic.BASIC +
      STA_UtilsStatic.SPACE +
      EncodingUtil.base64Encode(basicAuthBlob);
    mock.setHeader(STA_UtilsStatic.AUTHORIZATION, basicAuthHeader);

    // Set the mock callout mode
    Test.setMock(HttpCalloutMock.class, mock);

    Test.startTest();
    SMC_AC_ERP_Line.WrapperData result = SMC_AC_ERP_Line.initialization(
      [
        SELECT Id
        FROM SMC_ERP_Invoice__c
        WHERE Name = :STA_UtilsStatic.TEST + '_001'
      ]
      .Id
    );
    Test.stopTest();

    System.assertNotEquals(
      null,
      result.error,
      'Mock JSON for error is wrong. Check it and relaunch test.'
    );
    System.assertEquals(
      0,
      result.datas.size(),
      'Mock JSON for error is wrong. Check it and relaunch test.'
    );
  }

  /**
   * @description : test SMC_AC_ERP_Line.initialization(Order) [OK]
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  @isTest
  public static void testInitializationOrderOK() {
    StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
    mock.setStaticResource(STA_UtilsStatic.MOCK_ERP_OBJECTS_ORDER);
    mock.setStatusCode(200);
    SMC_Endpoint_ERPObject__mdt complementaryEndpoint = [
      SELECT
        URL_Endpoint_Invoice__c,
        URL_Endpoint_Order__c,
        URL_Endpoint_Quote__c,
        Authorization__c,
        Is_Mocking_Mode__c
      FROM SMC_Endpoint_ERPObject__mdt
      LIMIT 1
    ];
    mock.setHeader(
      STA_UtilsStatic.CONTENT_TYPE,
      STA_UtilsStatic.APPLICATION_X_WWW_FORM_URLENCODED
    );
    Blob basicAuthBlob = Blob.valueOf(complementaryEndpoint.Authorization__c);
    String basicAuthHeader =
      STA_UtilsStatic.BASIC +
      STA_UtilsStatic.SPACE +
      EncodingUtil.base64Encode(basicAuthBlob);
    mock.setHeader(STA_UtilsStatic.AUTHORIZATION, basicAuthHeader);

    // Set the mock callout mode
    Test.setMock(HttpCalloutMock.class, mock);

    Test.startTest();
    SMC_AC_ERP_Line.WrapperData result = SMC_AC_ERP_Line.initialization(
      [
        SELECT Id
        FROM SMC_ERP_Order__c
        WHERE Name = :STA_UtilsStatic.TEST + '_001'
      ]
      .Id
    );
    Test.stopTest();

    System.assertEquals(
      STA_UtilsStatic.ICON_ERP_ORDER,
      result.iconName,
      'Mock is wrong. Check it and relaunch test.'
    );
    System.assertEquals(
      STA_UtilsStatic.ERP_ORDER_LINES,
      result.erpLineTitle,
      'Mock is wrong. Check it and relaunch test.'
    );
  }

  /**
   * @description : test SMC_AC_ERP_Line.initialization(Order) [BAD]
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  @isTest
  public static void testInitializationOrderBADJSON() {
    StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
    mock.setStaticResource(STA_UtilsStatic.MOCK_ERROR);
    mock.setStatusCode(200);
    SMC_Endpoint_ERPObject__mdt complementaryEndpoint = [
      SELECT
        URL_Endpoint_Invoice__c,
        URL_Endpoint_Order__c,
        URL_Endpoint_Quote__c,
        Authorization__c,
        Is_Mocking_Mode__c
      FROM SMC_Endpoint_ERPObject__mdt
      LIMIT 1
    ];
    mock.setHeader(
      STA_UtilsStatic.CONTENT_TYPE,
      STA_UtilsStatic.APPLICATION_X_WWW_FORM_URLENCODED
    );
    Blob basicAuthBlob = Blob.valueOf(complementaryEndpoint.Authorization__c);
    String basicAuthHeader =
      STA_UtilsStatic.BASIC +
      STA_UtilsStatic.SPACE +
      EncodingUtil.base64Encode(basicAuthBlob);
    mock.setHeader(STA_UtilsStatic.AUTHORIZATION, basicAuthHeader);

    // Set the mock callout mode
    Test.setMock(HttpCalloutMock.class, mock);

    Test.startTest();
    SMC_AC_ERP_Line.WrapperData result = SMC_AC_ERP_Line.initialization(
      [
        SELECT Id
        FROM SMC_ERP_Order__c
        WHERE Name = :STA_UtilsStatic.TEST + '_001'
      ]
      .Id
    );
    Test.stopTest();

    System.assertNotEquals(
      null,
      result.error,
      'Mock JSON for error is wrong. Check it and relaunch test.'
    );
    System.assertEquals(
      0,
      result.datas.size(),
      'Mock JSON for error is wrong. Check it and relaunch test.'
    );
  }

  /**
   * @description : test SMC_AC_ERP_Line.initialization(Quote) [OK]
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  @isTest
  public static void testInitializationQuoteOK() {
    StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
    mock.setStaticResource(STA_UtilsStatic.MOCK_ERP_OBJECTS_QUOTE);
    mock.setStatusCode(200);
    SMC_Endpoint_ERPObject__mdt complementaryEndpoint = [
      SELECT
        URL_Endpoint_Invoice__c,
        URL_Endpoint_Order__c,
        URL_Endpoint_Quote__c,
        Authorization__c,
        Is_Mocking_Mode__c
      FROM SMC_Endpoint_ERPObject__mdt
      LIMIT 1
    ];
    mock.setHeader(
      STA_UtilsStatic.CONTENT_TYPE,
      STA_UtilsStatic.APPLICATION_X_WWW_FORM_URLENCODED
    );
    Blob basicAuthBlob = Blob.valueOf(complementaryEndpoint.Authorization__c);
    String basicAuthHeader =
      STA_UtilsStatic.BASIC +
      STA_UtilsStatic.SPACE +
      EncodingUtil.base64Encode(basicAuthBlob);
    mock.setHeader(STA_UtilsStatic.AUTHORIZATION, basicAuthHeader);

    // Set the mock callout mode
    Test.setMock(HttpCalloutMock.class, mock);

    Test.startTest();
    SMC_AC_ERP_Line.WrapperData result = SMC_AC_ERP_Line.initialization(
      [
        SELECT Id
        FROM SMC_ERP_Quote__c
        WHERE Name = :STA_UtilsStatic.TEST + '_001'
      ]
      .Id
    );
    Test.stopTest();

    System.assertEquals(
      STA_UtilsStatic.ICON_ERP_QUOTE,
      result.iconName,
      'Mock is wrong. Check it and relaunch test.'
    );
    System.assertEquals(
      STA_UtilsStatic.ERP_QUOTE_LINES,
      result.erpLineTitle,
      'Mock is wrong. Check it and relaunch test.'
    );
  }

  /**
   * @description : test SMC_AC_ERP_Line.initialization(Quote) [BAD]
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  @isTest
  public static void testInitializationQuoteBADJSON() {
    StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
    mock.setStaticResource(STA_UtilsStatic.MOCK_ERROR);
    mock.setStatusCode(200);
    SMC_Endpoint_ERPObject__mdt complementaryEndpoint = [
      SELECT
        URL_Endpoint_Invoice__c,
        URL_Endpoint_Order__c,
        URL_Endpoint_Quote__c,
        Authorization__c,
        Is_Mocking_Mode__c
      FROM SMC_Endpoint_ERPObject__mdt
      LIMIT 1
    ];
    mock.setHeader(
      STA_UtilsStatic.CONTENT_TYPE,
      STA_UtilsStatic.APPLICATION_X_WWW_FORM_URLENCODED
    );
    Blob basicAuthBlob = Blob.valueOf(complementaryEndpoint.Authorization__c);
    String basicAuthHeader =
      STA_UtilsStatic.BASIC +
      STA_UtilsStatic.SPACE +
      EncodingUtil.base64Encode(basicAuthBlob);
    mock.setHeader(STA_UtilsStatic.AUTHORIZATION, basicAuthHeader);

    // Set the mock callout mode
    Test.setMock(HttpCalloutMock.class, mock);

    Test.startTest();
    SMC_AC_ERP_Line.WrapperData result = SMC_AC_ERP_Line.initialization(
      [
        SELECT Id
        FROM SMC_ERP_Quote__c
        WHERE Name = :STA_UtilsStatic.TEST + '_001'
      ]
      .Id
    );
    Test.stopTest();

    System.assertNotEquals(
      null,
      result.error,
      'Mock JSON for error is wrong. Check it and relaunch test.'
    );
    System.assertEquals(
      0,
      result.datas.size(),
      'Mock JSON for error is wrong. Check it and relaunch test.'
    );
  }
}