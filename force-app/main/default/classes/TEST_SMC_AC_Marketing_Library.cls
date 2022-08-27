/*
-----------------------------------------------------------------------------------
-- - Name : TEST_SMC_AC_Marketing_Library
-- - Author : Vincent RECASENS
-- - Description : This class test the Apex controller SMC_AC_Marketing_Library
--
-- Maintenance History:
--
-- Date         Name   Version     Remarks
-- -----------  ----   -------     ----------------------------
-- 12-AUG-2019  VRE    1.0         Initial Version
------------------------------------------------------------------------------------
*/

@IsTest
public without sharing class TEST_SMC_AC_Marketing_Library {
  @isTest
  public static void testInit() {
    System.assertNotEquals(
      new SMC_DTO_ML_Wrappers.SMC_DTO_ML_AllData(),
      SMC_AC_Marketing_Library.initAll(
        STA_UtilsStatic.STR_DISTRIBUTOR,
        STA_UtilsStatic.ONE
      ),
      'The Marketing Library\'s initialization does not work.'
    );
  }

  @isTest
  public static void testGetDocList() {
    StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
    mock.setStaticResource(
      STA_UtilsStatic.MOCK_MARKETING_LIBRARY_DOCUMENT_LIST
    );
    mock.setStatusCode(200);
    mock.setHeader(STA_UtilsStatic.ACCEPT, STA_UtilsStatic.APPLICATION_JSON);
    mock.setHeader(
      STA_UtilsStatic.CONTENT_TYPE,
      STA_UtilsStatic.APPLICATION_X_WWW_FORM_URLENCODED
    );

    // Set the mock callout mode
    Test.setMock(HttpCalloutMock.class, mock);

    Test.startTest();
    SMC_DTO_ML_Wrappers.SMC_DTO_ML_AllData result = SMC_AC_Marketing_Library.getDocumentList(
      STA_UtilsStatic.STR_DISTRIBUTOR,
      STA_UtilsStatic.ONE,
      '29',
      null,
      'EN',
      '0',
      '',
        'desc',
        null
    );
    Test.stopTest();

    System.assertNotEquals(
      null,
      result,
      'Mock is wrong. Check it and relaunch test.'
    );
  }

  @isTest
  public static void testResetProductFamily() {
    StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
    mock.setStaticResource(
      STA_UtilsStatic.MOCK_MARKETING_LIBRARY_PICKLIST_PRODUCT_FAMILY
    );
    mock.setStatusCode(200);
    mock.setHeader(STA_UtilsStatic.ACCEPT, STA_UtilsStatic.APPLICATION_JSON);
    mock.setHeader(
      STA_UtilsStatic.CONTENT_TYPE,
      STA_UtilsStatic.APPLICATION_X_WWW_FORM_URLENCODED
    );

    // Set the mock callout mode
    Test.setMock(HttpCalloutMock.class, mock);

    Test.startTest();
    SMC_DTO_ML_Wrappers.SMC_DTO_ML_AllData result = SMC_AC_Marketing_Library.resetProductFamily(
      STA_UtilsStatic.STR_DISTRIBUTOR,
      STA_UtilsStatic.ONE,
      null,
      'EN',
      '0',
      '',
        'desc',
        null
    );
    Test.stopTest();

    System.assertNotEquals(
      null,
      result,
      'Mock is wrong. Check it and relaunch test.'
    );
  }

  @isTest
  public static void testGetDocLIstByTarget() {
    StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
    mock.setStaticResource(
      STA_UtilsStatic.MOCK_MARKETING_LIBRARY_DOCUMENT_LIST
    );
    mock.setStatusCode(200);
    mock.setHeader(STA_UtilsStatic.ACCEPT, STA_UtilsStatic.APPLICATION_JSON);
    mock.setHeader(
      STA_UtilsStatic.CONTENT_TYPE,
      STA_UtilsStatic.APPLICATION_X_WWW_FORM_URLENCODED
    );

    // Set the mock callout mode
    Test.setMock(HttpCalloutMock.class, mock);

    Test.startTest();
    SMC_DTO_ML_Wrappers.SMC_DTO_ML_Documents result = SMC_AC_Marketing_Library.getDocumentListByTargetFromWS(
      STA_UtilsStatic.STR_DISTRIBUTOR,
      STA_UtilsStatic.ONE,
      '29',
      null,
      'EN',
      '100',
      '0',
      '',
      new User(SMC_Partner_Level__c = '4'),
      'desc',
      null
    );
    Test.stopTest();

    System.assertNotEquals(
      null,
      result,
      'Mock is wrong. Check it and relaunch test.'
    );
  }

  @isTest
  public static void testGetDocLIstByTargetFAIL() {
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

    Test.startTest();
    SMC_DTO_ML_Wrappers.SMC_DTO_ML_Documents result = SMC_AC_Marketing_Library.getDocumentListByTargetFromWS(
      STA_UtilsStatic.STR_DISTRIBUTOR,
      STA_UtilsStatic.ONE,
      '29',
      null,
      'EN',
      '100',
      '0',
      '',
      new User(SMC_Partner_Level__c = '4'),
      'desc',
      null
    );
    Test.stopTest();

    System.assertEquals(
      null,
      result,
      'Mock is wrong. Check it and relaunch test.'
    );
  }

  @isTest
  public static void testGetPicklistBa() {
    StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
    mock.setStaticResource(STA_UtilsStatic.MOCK_MARKETING_LIBRARY_PICKLIST_BA);
    mock.setStatusCode(200);
    mock.setHeader(STA_UtilsStatic.ACCEPT, STA_UtilsStatic.APPLICATION_JSON);
    mock.setHeader(
      STA_UtilsStatic.CONTENT_TYPE,
      STA_UtilsStatic.APPLICATION_X_WWW_FORM_URLENCODED
    );

    // Set the mock callout mode
    Test.setMock(HttpCalloutMock.class, mock);

    Test.startTest();
    SMC_DTO_ML_Wrappers.SMC_DTO_ML_PF_Parent result = SMC_AC_Marketing_Library.getPicklistBaAndProductFamily(
      STA_UtilsStatic.PICKLIST_DOC_LIST_COMMUNITY + STA_UtilsStatic.BA,
      null,
      SMC_AC_Marketing_Library.getEndpoint()
    );
    Test.stopTest();

    System.assertNotEquals(
      null,
      result,
      'Mock is wrong. Check it and relaunch test.'
    );
  }

  @isTest
  public static void testGetPicklistBaFAIL() {
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

    Test.startTest();
    SMC_DTO_ML_Wrappers.SMC_DTO_ML_PF_Parent result = SMC_AC_Marketing_Library.getPicklistBaAndProductFamily(
      STA_UtilsStatic.PICKLIST_DOC_LIST_COMMUNITY + STA_UtilsStatic.BA,
      null,
      SMC_AC_Marketing_Library.getEndpoint()
    );
    Test.stopTest();

    System.assertEquals(
      null,
      result,
      'Mock is wrong. Check it and relaunch test.'
    );
  }

  @isTest
  public static void testGetPicklistProductFamily() {
    StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
    mock.setStaticResource(
      STA_UtilsStatic.MOCK_MARKETING_LIBRARY_PICKLIST_PRODUCT_FAMILY
    );
    mock.setStatusCode(200);
    mock.setHeader(STA_UtilsStatic.ACCEPT, STA_UtilsStatic.APPLICATION_JSON);
    mock.setHeader(
      STA_UtilsStatic.CONTENT_TYPE,
      STA_UtilsStatic.APPLICATION_X_WWW_FORM_URLENCODED
    );

    // Set the mock callout mode
    Test.setMock(HttpCalloutMock.class, mock);

    Test.startTest();
    SMC_DTO_ML_Wrappers.SMC_DTO_ML_PF_Parent result = SMC_AC_Marketing_Library.getPicklistBaAndProductFamily(
      STA_UtilsStatic.PICKLIST_DOC_LIST_COMMUNITY +
      STA_UtilsStatic.PRODUCT_FAMILY,
      STA_UtilsStatic.ONE,
      SMC_AC_Marketing_Library.getEndpoint()
    );
    Test.stopTest();

    System.assertNotEquals(
      null,
      result,
      'Mock is wrong. Check it and relaunch test.'
    );
  }

  @isTest
  public static void testGetPicklistProductFamilyFAIL() {
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

    Test.startTest();
    SMC_DTO_ML_Wrappers.SMC_DTO_ML_PF_Parent result = SMC_AC_Marketing_Library.getPicklistBaAndProductFamily(
      STA_UtilsStatic.PICKLIST_DOC_LIST_COMMUNITY +
      STA_UtilsStatic.PRODUCT_FAMILY,
      STA_UtilsStatic.ONE,
      SMC_AC_Marketing_Library.getEndpoint()
    );
    Test.stopTest();

    System.assertEquals(
      null,
      result,
      'Mock is wrong. Check it and relaunch test.'
    );
  }

  @isTest
  public static void testGetPicklistDocType() {
    StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
    mock.setStaticResource(
      STA_UtilsStatic.MOCK_MARKETING_LIBRARY_PICKLIST_DOCUMENT_TYPE
    );
    mock.setStatusCode(200);
    mock.setHeader(STA_UtilsStatic.ACCEPT, STA_UtilsStatic.APPLICATION_JSON);
    mock.setHeader(
      STA_UtilsStatic.CONTENT_TYPE,
      STA_UtilsStatic.APPLICATION_JSON
    );

    // Set the mock callout mode
    Test.setMock(HttpCalloutMock.class, mock);

    Test.startTest();
    SMC_DTO_ML_Wrappers.SMC_DTO_ML_Others result = SMC_AC_Marketing_Library.getPicklistDocTypeAndLanguage(
      STA_UtilsStatic.PICKLIST_DOC_LIST_COMMUNITY + STA_UtilsStatic.DOC_TYPE,
      SMC_AC_Marketing_Library.getEndpoint()
    );
    Test.stopTest();

    System.assertNotEquals(
      null,
      result,
      'Mock is wrong. Check it and relaunch test.'
    );
  }

  @isTest
  public static void testGetPicklistDocTypeFAIL() {
    StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
    mock.setStaticResource(STA_UtilsStatic.MOCK_ERROR);
    mock.setStatusCode(500);
    mock.setHeader(STA_UtilsStatic.ACCEPT, STA_UtilsStatic.APPLICATION_JSON);
    mock.setHeader(
      STA_UtilsStatic.CONTENT_TYPE,
      STA_UtilsStatic.APPLICATION_JSON
    );

    // Set the mock callout mode
    Test.setMock(HttpCalloutMock.class, mock);

    Test.startTest();
    SMC_DTO_ML_Wrappers.SMC_DTO_ML_Others result = SMC_AC_Marketing_Library.getPicklistDocTypeAndLanguage(
      STA_UtilsStatic.PICKLIST_DOC_LIST_COMMUNITY + STA_UtilsStatic.DOC_TYPE,
      SMC_AC_Marketing_Library.getEndpoint()
    );
    Test.stopTest();

    System.assertEquals(
      null,
      result,
      'Mock is wrong. Check it and relaunch test.'
    );
  }

  @isTest
  public static void testGetPicklistLanguage() {
    StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
    mock.setStaticResource(
      STA_UtilsStatic.MOCK_MARKETING_LIBRARY_PICKLIST_LANGUAGE
    );
    mock.setStatusCode(200);
    mock.setHeader(STA_UtilsStatic.ACCEPT, STA_UtilsStatic.APPLICATION_JSON);
    mock.setHeader(
      STA_UtilsStatic.CONTENT_TYPE,
      STA_UtilsStatic.APPLICATION_JSON
    );

    // Set the mock callout mode
    Test.setMock(HttpCalloutMock.class, mock);

    Test.startTest();
    SMC_DTO_ML_Wrappers.SMC_DTO_ML_Others result = SMC_AC_Marketing_Library.getPicklistDocTypeAndLanguage(
      STA_UtilsStatic.PICKLIST_DOC_LIST_COMMUNITY + STA_UtilsStatic.LANGUAGE,
      SMC_AC_Marketing_Library.getEndpoint()
    );
    Test.stopTest();

    System.assertNotEquals(
      null,
      result,
      'Mock is wrong. Check it and relaunch test.'
    );
  }

  @isTest
  public static void testGetPicklistLanguageFAIL() {
    StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
    mock.setStaticResource(STA_UtilsStatic.MOCK_ERROR);
    mock.setStatusCode(500);
    mock.setHeader(STA_UtilsStatic.ACCEPT, STA_UtilsStatic.APPLICATION_JSON);
    mock.setHeader(
      STA_UtilsStatic.CONTENT_TYPE,
      STA_UtilsStatic.APPLICATION_JSON
    );

    // Set the mock callout mode
    Test.setMock(HttpCalloutMock.class, mock);

    Test.startTest();
    SMC_DTO_ML_Wrappers.SMC_DTO_ML_Others result = SMC_AC_Marketing_Library.getPicklistDocTypeAndLanguage(
      STA_UtilsStatic.PICKLIST_DOC_LIST_COMMUNITY + STA_UtilsStatic.LANGUAGE,
      SMC_AC_Marketing_Library.getEndpoint()
    );
    Test.stopTest();

    System.assertEquals(
      null,
      result,
      'Mock is wrong. Check it and relaunch test.'
    );
  }

  @isTest
  public static void testFindImgAndPath_PictureDefaultPathNull(){
    // oneDoc.publicPictureDefaultPath == null && pathEn == null
    
    SMC_DTO_ML_Wrappers.SMC_DTO_ML_AllData allData = SMC_AC_Marketing_Library.initAll(
                                                        STA_UtilsStatic.STR_DISTRIBUTOR,
                                                        STA_UtilsStatic.ONE
                                                      );
    Integer i = 1;
    for(SMC_DTO_ML_Wrappers.SMC_DTO_ML_Document oneDoc : allData.docList.documents){
      oneDoc.publicPictureDefaultPath = null;
    }

    Test.startTest();
      SMC_AC_Marketing_Library.findImgAndPath(allData);
    Test.stopTest();

    for(SMC_DTO_ML_Wrappers.SMC_DTO_ML_Document oneDoc : allData.docList.documents){
      System.assertNotEquals(null, oneDoc.publicPictureDefaultPath);
    }
  }

  @isTest
  public static void testCheckPictureUrl() {
    StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
    mock.setStaticResource(
      STA_UtilsStatic.MOCK_MARKETING_LIBRARY_CHECK_PICTURE
    );
    mock.setStatusCode(200);
    mock.setHeader(STA_UtilsStatic.ACCEPT, STA_UtilsStatic.APPLICATION_JSON);
    mock.setHeader(
      STA_UtilsStatic.CONTENT_TYPE,
      STA_UtilsStatic.APPLICATION_JSON
    );

    // Set the mock callout mode
    Test.setMock(HttpCalloutMock.class, mock);

    Test.startTest();
      String result = SMC_AC_Marketing_Library.checkPictureUrl(STA_UtilsStatic.GOOGLE_URL);
    Test.stopTest();

    System.assertEquals(
      STA_UtilsStatic.GOOGLE_URL,
      result,
      'Mock is wrong. Check it and relaunch test.'
    );
  }

  @isTest
  public static void testCheckPictureUrl_FAIL() {
    StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
    mock.setStaticResource(
      STA_UtilsStatic.MOCK_MARKETING_LIBRARY_CHECK_PICTURE
    );
    mock.setStatusCode(500);
    mock.setHeader(STA_UtilsStatic.ACCEPT, STA_UtilsStatic.APPLICATION_JSON);
    mock.setHeader(
      STA_UtilsStatic.CONTENT_TYPE,
      STA_UtilsStatic.APPLICATION_JSON
    );

    // Set the mock callout mode
    Test.setMock(HttpCalloutMock.class, mock);

    Test.startTest();
      String result = SMC_AC_Marketing_Library.checkPictureUrl(STA_UtilsStatic.GOOGLE_URL);
    Test.stopTest();

    System.assertEquals(
      System.Label.SMC_NoPicture_Path,
      result,
      'Mock is wrong. Check it and relaunch test.'
    );
  }
}