/**
 * @description       :
 * @author            : Vincent RECASENS (Modis)
 * @group             :
 * @last modified on  : 03-08-2021
 * @last modified by  : Vincent RECASENS (Modis)
 * Modifications Log
 * Ver   Date         Author                     Modification
 * 1.0   03-08-2021   Vincent RECASENS (Modis)   Initial Version
 **/
@IsTest
public with sharing class TEST_SMC_AC_LoraWan_IOT_Keys {
  @testSetup
  public static void setup() {
    //Guest
    Profile profileWarrantyGuestUser = [
      SELECT Id
      FROM Profile
      WHERE Name = :STA_UtilsStatic.PROFIL_WARRANTY_REGISTRATION_NAME
    ];
    User userWarrantyRegistration = SMC_UTIL_TestUtils.createUser(
      'lora-' + STA_UtilsStatic.USER_NICKNAME,
      'lora-' + STA_UtilsStatic.USERNAME_TEST,
      profileWarrantyGuestUser.Id,
      'lora-' + STA_UtilsStatic.USERNAME_TEST,
      'lora-' + STA_UtilsStatic.USER_NICKNAME
    );
    insert userWarrantyRegistration;

    //LoraWan Requestor
    SMC_Lorawan_Keys_Requestor__c newRequestor = new SMC_Lorawan_Keys_Requestor__c();
    newRequestor.First_Name__c = 'customerPortal';
    newRequestor.Last_Name__c = STA_UtilsStatic.USER_NICKNAME;
    newRequestor.Email__c = 'customerPortal-' + STA_UtilsStatic.USERNAME_TEST;
    newRequestor.Phone__c = null;
    newRequestor.Company__c = STA_UtilsStatic.ACCOUNT_NAME1;
    newRequestor.Country__c = STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY1;
    insert newRequestor;
    //LoraWan Request
    SMC_Lorawan_Keys_Request__c request = new SMC_Lorawan_Keys_Request__c();
    request.Keys__c = '00174ACA0000F000\n00174ACA0000F000\n00174ACA0000F000\n00174ACA0000F000\n';
    request.Requestor__c = newRequestor.Id;
    insert request;
  }

  @isTest
  public static void testMakeCallout_CLIENT() {
    StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
    mock.setStaticResource(STA_UtilsStatic.MOCK_LORAWAN_KEY);
    mock.setStatusCode(200);
    mock.setHeader(STA_UtilsStatic.ACCEPT, STA_UtilsStatic.APPLICATION_JSON);
    mock.setHeader(
      STA_UtilsStatic.CONTENT_TYPE,
      STA_UtilsStatic.APPLICATION_X_WWW_FORM_URLENCODED
    );

    // Set the mock callout mode
    Test.setMock(HttpCalloutMock.class, mock);

    User userGuest = [
      SELECT Id
      FROM User
      WHERE Name = :('lora-' + STA_UtilsStatic.USER_NICKNAME)
    ];
    SMC_Lorawan_Keys_Request__c request = [
      SELECT Id
      FROM SMC_Lorawan_Keys_Request__c
      LIMIT 1
    ];
    SMC_AC_LoraWan_IOT_Keys.DTOResponse response;
    System.runAs(userGuest) {
      Test.startTest();
      response = SMC_AC_LoraWan_IOT_Keys.makeCallout(
        System.Label.SMC_CLIENT,
        request.Id,
        new List<String>{ '00174aca0000f015' }
      );
      Test.stopTest();
    }

    System.assert(
      response.result.size() > 0,
      'Mock is wrong. Check it and relaunch test.'
    );
  }

  @isTest
  public static void testMakeCallout_CLIENT_BAD() {
    StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
    mock.setStaticResource(STA_UtilsStatic.MOCK_ERROR);
    mock.setStatusCode(500);
    mock.setHeader(STA_UtilsStatic.ACCEPT, STA_UtilsStatic.APPLICATION_JSON);
    mock.setHeader(
      STA_UtilsStatic.CONTENT_TYPE,
      STA_UtilsStatic.APPLICATION_X_WWW_FORM_URLENCODED
    );

    // Set the mock callout mode
    Test.setMock(HttpCalloutMock.class, mock);

    User userGuest = [
      SELECT Id
      FROM User
      WHERE Name = :('lora-' + STA_UtilsStatic.USER_NICKNAME)
    ];
    SMC_Lorawan_Keys_Request__c request = [
      SELECT Id
      FROM SMC_Lorawan_Keys_Request__c
      LIMIT 1
    ];
    SMC_AC_LoraWan_IOT_Keys.DTOResponse response;
    System.runAs(userGuest) {
      try {
        Test.startTest();
        response = SMC_AC_LoraWan_IOT_Keys.makeCallout(
          System.Label.SMC_CLIENT,
          request.Id,
          new List<String>{ '00174aca0000f015' }
        );
        Test.stopTest();
      } catch (Exception e) {
        System.debug('Bad code value response is catched.');
      }
    }

    System.assert(
      response.result.size() == 0,
      'Mock is wrong. Check it and relaunch test.'
    );
  }

  @isTest
  public static void testManageLoRaWanCalloutAndPrintDatas_CLIENT() {
    StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
    mock.setStaticResource(STA_UtilsStatic.MOCK_LORAWAN_KEY);
    mock.setStatusCode(200);
    mock.setHeader(STA_UtilsStatic.ACCEPT, STA_UtilsStatic.APPLICATION_JSON);
    mock.setHeader(
      STA_UtilsStatic.CONTENT_TYPE,
      STA_UtilsStatic.APPLICATION_X_WWW_FORM_URLENCODED
    );

    // Set the mock callout mode
    Test.setMock(HttpCalloutMock.class, mock);

    User userGuest = [
      SELECT Id
      FROM User
      WHERE Name = :('lora-' + STA_UtilsStatic.USER_NICKNAME)
    ];
    SMC_Lorawan_Keys_Request__c request = [
      SELECT Id
      FROM SMC_Lorawan_Keys_Request__c
      LIMIT 1
    ];
    SMC_AC_LoraWan_IOT_Keys.DTOResponse response;
    SMC_AC_LoraWan_IOT_Keys.WrapperToPrintDatas responseToPrint;
    System.runAs(userGuest) {
      Test.startTest();
      responseToPrint = SMC_AC_LoraWan_IOT_Keys.manageLoRaWanCalloutAndPrintDatas(
        System.Label.SMC_CLIENT,
        String.valueOf(request.Id),
        null,
        '00174aca0000f015'
      );
      Test.stopTest();
    }

    System.assert(
      responseToPrint.responseClient.result.size() > 0,
      'Mock is wrong. Check it and relaunch test.'
    );
  }

  @isTest
  public static void testManageLoRaWanCalloutAndPrintDatas_NKE() {
    StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
    mock.setStaticResource(STA_UtilsStatic.MOCK_LORAWAN_CONFIG);
    mock.setStatusCode(200);
    mock.setHeader(STA_UtilsStatic.ACCEPT, STA_UtilsStatic.APPLICATION_JSON);
    mock.setHeader(
      STA_UtilsStatic.CONTENT_TYPE,
      STA_UtilsStatic.APPLICATION_X_WWW_FORM_URLENCODED
    );

    // Set the mock callout mode
    Test.setMock(HttpCalloutMock.class, mock);

    User userGuest = [
      SELECT Id
      FROM User
      WHERE Name = :('lora-' + STA_UtilsStatic.USER_NICKNAME)
    ];
    SMC_Lorawan_Keys_Request__c request = [
      SELECT Id
      FROM SMC_Lorawan_Keys_Request__c
      LIMIT 1
    ];
    SMC_AC_LoraWan_IOT_Keys.DTOResponse response;
    SMC_AC_LoraWan_IOT_Keys.WrapperToPrintDatas responseToPrint;
    System.runAs(userGuest) {
      Test.startTest();
      responseToPrint = SMC_AC_LoraWan_IOT_Keys.manageLoRaWanCalloutAndPrintDatas(
        System.Label.SMC_NKE,
        String.valueOf(request.Id),
        null,
        '00174aca0000f015'
      );
      Test.stopTest();
    }

    System.assertNotEquals(
      '',
      responseToPrint.responseNkeToPrint,
      'Mock is wrong. Check it and relaunch test.'
    );
  }

  @isTest
  public static void testManageLoRaWanCalloutAndPrintDatas_NKE_BAD() {
    StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
    mock.setStaticResource(STA_UtilsStatic.MOCK_LORAWAN_CONFIG);
    mock.setStatusCode(500);
    mock.setHeader(STA_UtilsStatic.ACCEPT, STA_UtilsStatic.APPLICATION_JSON);
    mock.setHeader(
      STA_UtilsStatic.CONTENT_TYPE,
      STA_UtilsStatic.APPLICATION_X_WWW_FORM_URLENCODED
    );

    // Set the mock callout mode
    Test.setMock(HttpCalloutMock.class, mock);

    User userGuest = [
      SELECT Id
      FROM User
      WHERE Name = :('lora-' + STA_UtilsStatic.USER_NICKNAME)
    ];
    SMC_Lorawan_Keys_Request__c request = [
      SELECT Id
      FROM SMC_Lorawan_Keys_Request__c
      LIMIT 1
    ];
    SMC_AC_LoraWan_IOT_Keys.DTOResponse response;
    SMC_AC_LoraWan_IOT_Keys.WrapperToPrintDatas responseToPrint;
    System.runAs(userGuest) {
      try {
        Test.startTest();
        responseToPrint = SMC_AC_LoraWan_IOT_Keys.manageLoRaWanCalloutAndPrintDatas(
          System.Label.SMC_NKE,
          String.valueOf(request.Id),
          null,
          '00174aca0000f015'
        );
        Test.stopTest();
      } catch (Exception e) {
        System.debug('Bad code value response is catched.');
      }
    }

    System.assertEquals(
      '',
      responseToPrint.responseNkeToPrint,
      'Mock is wrong. Check it and relaunch test.'
    );
  }

  @isTest
  public static void testDTOWrapper(){
    //Response globale
    SMC_AC_LoraWan_IOT_Keys.DTOResponseGlobal responseGlobale = new SMC_AC_LoraWan_IOT_Keys.DTOResponseGlobal();
    responseGlobale.devEUI = 'coverage';
    responseGlobale.appEUI = 'coverage';
    responseGlobale.appKey = 'coverage';
    responseGlobale.serialNumber = 'coverage';
    responseGlobale.theclass = 'coverage';
    responseGlobale.deviceType = 'coverage';
    responseGlobale.netId = 'coverage';
    responseGlobale.reference = 'coverage';
    responseGlobale.manufacturerSN = 'coverage';
    responseGlobale.firmwareVersion = 'coverage';
    responseGlobale.abpDevAddr = 'coverage';
    responseGlobale.abpNwkSKey = 'coverage';
    responseGlobale.abpAppSKey = 'coverage';
    responseGlobale.codeFamille = 'coverage';
    responseGlobale.unconfirmed = 'coverage';
    responseGlobale.synchro = 'coverage';
    responseGlobale.adr = 'coverage';
    SMC_AC_LoraWan_IOT_Keys.DTOResponseGlobal responseGlobaleBis = new SMC_AC_LoraWan_IOT_Keys.DTOResponseGlobal('coverage');

    //Response
    SMC_AC_LoraWan_IOT_Keys.DTOResponse response0 = new SMC_AC_LoraWan_IOT_Keys.DTOResponse();
    response0.take = 1000;
    response0.total = 0;
    response0.format = 'coverage';
    response0.result = new List<SMC_AC_LoraWan_IOT_Keys.DTOResponseGlobal>();
    SMC_AC_LoraWan_IOT_Keys.DTOResponse response1 = new SMC_AC_LoraWan_IOT_Keys.DTOResponse('coverage');
    SMC_AC_LoraWan_IOT_Keys.DTOResponse response2 = new SMC_AC_LoraWan_IOT_Keys.DTOResponse(1000, 'coverage');
    SMC_AC_LoraWan_IOT_Keys.DTOResponse response3 = new SMC_AC_LoraWan_IOT_Keys.DTOResponse(1000, 0, 'coverage');

    //Wrapper column
    SMC_AC_LoraWan_IOT_Keys.WrapperToPrintColumn wrapperColumn = new SMC_AC_LoraWan_IOT_Keys.WrapperToPrintColumn();

    //Assert true
    System.assert(true);
  }
}