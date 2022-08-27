/*
---------------------------------------------------------------------------
-- - Name : TEST_SMC_AC_ServiceProductList
-- - Author : Vincent RECASENS
-- - Description : This class is the test of SMC_AC_ServiceProductList
--
-- Maintenance History:
--
-- Date         Name    Version     Remarks
-- -----------  ----    -------     ---------------
-- 26-DEC-2017  VRE     1.0         Initial Version
---------------------------------------------------------------------------
*/

@isTest
public without sharing class TEST_SMC_AC_ServiceProductList {
  /**
   * @description : test SMC_AC_ServiceProductList.getAllProduct()
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  @isTest
  public static void testGetServiceProduct() {
    Profile profile = [
      SELECT Id
      FROM Profile
      WHERE Name = :STA_UtilsStatic.PROFILE_SALE_STANDARD
    ];
    User userStandard = SMC_UTIL_TestUtils.createUser(
      STA_UtilsStatic.USER_NICKNAME,
      STA_UtilsStatic.USERNAME_TEST,
      profile.Id,
      STA_UtilsStatic.USERNAME_TEST,
      STA_UtilsStatic.USER_NICKNAME
    );
    userStandard.Bypass_Validation_Rule__c = 'SMC_NoEditProduct';
    insert userStandard;

    System.runAs(userStandard) {
      //Get Manufacturer
      Schema.DescribeFieldResult fieldResultManufacturer = Product2.SMC_Manufacturer_p__c.getDescribe();
      List<Schema.PicklistEntry> entriesManufacturer = fieldResultManufacturer.getPicklistValues();
      //Get Range
      Schema.DescribeFieldResult fieldResultRange = Product2.SMC_Range_p__c.getDescribe();
      List<Schema.PicklistEntry> entriesRange = fieldResultRange.getPicklistValues();
      //Get Model
      Schema.DescribeFieldResult fieldResultModel = Product2.SMC_Model_p__c.getDescribe();
      List<Schema.PicklistEntry> entriesModel = fieldResultModel.getPicklistValues();
      //Get Configuration
      Schema.DescribeFieldResult fieldResultConfiguration = Product2.SMC_Configuration_p__c.getDescribe();
      List<Schema.PicklistEntry> entriesConfiguration = fieldResultConfiguration.getPicklistValues();
      //Get Phase
      Schema.DescribeFieldResult fieldResultPhase = Product2.SMC_Phase_p__c.getDescribe();
      List<Schema.PicklistEntry> entriesPhase = fieldResultPhase.getPicklistValues();
      //Get Power
      Schema.DescribeFieldResult fieldResultPower = Product2.SMC_Power_p__c.getDescribe();
      List<Schema.PicklistEntry> entriesPower = fieldResultPower.getPicklistValues();
      //Get Power Unit
      Schema.DescribeFieldResult fieldResultPowerUnit = Product2.SMC_Power_Unit_p__c.getDescribe();
      List<Schema.PicklistEntry> entriesPowerUnit = fieldResultPowerUnit.getPicklistValues();

      Id productRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName()
        .get(STA_UtilsStatic.RECORDTYPE_SERVICE_PRODUCT)
        .getRecordTypeId();

      Product2 product1 = SMC_UTIL_TestUtils.createServiceProductFSL(
        productRecordTypeId,
        STA_UtilsStatic.PRODUCT_NAME + '1',
        true,
        entriesManufacturer[0].getValue() +
        '-' +
        entriesRange[0].getValue() +
        ' ' +
        entriesModel[0].getValue() +
        '-' +
        entriesConfiguration[0].getValue() +
        '-' +
        entriesConfiguration[0].getValue() +
        '-' +
        entriesPhase[0].getValue() +
        '-' +
        entriesPower[0].getValue() +
        ' ' +
        entriesPowerUnit[0].getValue(),
        entriesManufacturer[0].getValue(),
        entriesRange[0].getValue(),
        entriesModel[0].getValue(),
        entriesConfiguration[0].getValue(),
        entriesPhase[0].getValue(),
        entriesPower[0].getValue(),
        entriesPowerUnit[0].getValue()
      );
      Product2 product2 = SMC_UTIL_TestUtils.createServiceProductFSL(
        productRecordTypeId,
        STA_UtilsStatic.PRODUCT_NAME + '2',
        true,
        entriesManufacturer[0].getValue() +
        '-' +
        entriesRange[0].getValue() +
        ' ' +
        entriesModel[0].getValue() +
        '-' +
        entriesConfiguration[1].getValue(),
        entriesManufacturer[0].getValue(),
        entriesRange[0].getValue(),
        entriesModel[0].getValue(),
        entriesConfiguration[1].getValue(),
        null,
        null,
        null
      );

      // Product2 product3 = SMC_UTIL_TestUtils.createServiceProductFSL(
      //   productRecordTypeId,
      //   STA_UtilsStatic.PRODUCT_NAME + '3',
      //   true,
      //   entriesManufacturer[2].getValue() +
      //   '-' +
      //   entriesRange[2].getValue() +
      //   ' ' +
      //   entriesModel[2].getValue() +
      //   '-' +
      //   entriesConfiguration[2].getValue() +
      //   '-' +
      //   entriesConfiguration[2].getValue() +
      //   '-' +
      //   entriesPhase[2].getValue() +
      //   '-' +
      //   entriesPower[2].getValue() +
      //   ' ' +
      //   entriesPowerUnit[2].getValue(),
      //   entriesManufacturer[2].getValue(),
      //   entriesRange[2].getValue(),
      //   entriesModel[2].getValue(),
      //   entriesConfiguration[2].getValue(),
      //   entriesPhase[2].getValue(),
      //   entriesPower[2].getValue(),
      //   entriesPowerUnit[2].getValue()
      // );

      insert new List<Product2>{ product1 };
      insert new List<Product2>{ product2 };
      // insert new List<Product2>{ product3 };

      String jsonProduct =
        '{' +
        '"manufacturer":"' +
        entriesManufacturer[0].getLabel() +
        '",' +
        '"range":"' +
        entriesRange[0].getLabel() +
        '",' +
        '"model":"' +
        entriesModel[0].getLabel() +
        '",' +
        '"configuration":"' +
        entriesConfiguration[0].getLabel() +
        '",' +
        '"phase":"' +
        entriesPhase[0].getLabel() +
        '",' +
        '"power":"' +
        entriesPower[0].getLabel() +
        '"' +
        '}';
      String jsonProductAll =
        '{' +
        '"manufacturer":"' +
        entriesManufacturer[0].getLabel() +
        '",' +
        '"range":"' +
        entriesRange[0].getLabel() +
        '"' +
        '}';

      Test.startTest();

      Test.setFixedSearchResults(
        new List<String>{ product1.Id, product2.Id } //, product3.Id }
      );

      //Name
      List<Product2> checkListName = new List<Product2>();
      checkListName = SMC_AC_ServiceProductList.getAllProduct(
        STA_UtilsStatic.PRODUCT_NAME,
        STA_UtilsStatic.EMPTY_STRING
      );
      System.assertEquals(
        2,
        checkListName.size(),
        'Check variables initialisations and reuqired fields on Product2.'
      );

      List<Product2> checkListAble = new List<Product2>();
      checkListName = SMC_AC_ServiceProductList.getAllProduct(
        STA_UtilsStatic.PRODUCT_NAME,
        jsonProductAll
      );
      System.assertEquals(
        2,
        checkListName.size(),
        'Check variables initialisations and reuqired fields on Product2.'
      );

      List<Product2> checkListAbleBis = new List<Product2>();
      checkListName = SMC_AC_ServiceProductList.getAllProduct(
        STA_UtilsStatic.PRODUCT_NAME,
        jsonProduct
      );
      System.assertEquals(
        1,
        checkListName.size(),
        'Check variables initialisations and reuqired fields on Product2.'
      );

      //Without ProductName
      List<Product2> checkListSOQL = new List<Product2>();
      checkListSOQL = SMC_AC_ServiceProductList.getAllProduct(
        STA_UtilsStatic.EMPTY_STRING,
        jsonProductAll
      );
      System.assertEquals(
        2,
        checkListSOQL.size(),
        'Check variables initialisations and reuqired fields on Product2.'
      );
      Test.stopTest();
    }
  }

  /**
   * @description : test SMC_AC_ServiceProductList.getCacheManufacturer()
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  @isTest
  public static void testgetCacheManufacturer() {
    String result = SMC_AC_ServiceProductList.getCacheManufacturer();
    System.assertNotEquals(null, result, 'Check cache intialisation.');
  }

  /**
   * @description : test SMC_AC_ServiceProductList.getCacheRange()
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  @isTest
  public static void testgetCacheRange() {
    String result = SMC_AC_ServiceProductList.getCacheRange(
      STA_UtilsStatic.ORG_CACHE_SERVICE_PRODUCT_MANUFACTURER
    );
    System.assertNotEquals(null, result, 'Check cache intialisation.');
  }

  /**
   * @description : test SMC_AC_ServiceProductList.getCacheModel()
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  @isTest
  public static void testgetCacheModel() {
    String result = SMC_AC_ServiceProductList.getCacheModel(
      STA_UtilsStatic.ORG_CACHE_SERVICE_PRODUCT_RANGE
    );
    System.assertNotEquals(null, result, 'Check cache intialisation.');
  }

  /**
   * @description : test SMC_AC_ServiceProductList.getCacheConfiguration()
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  @isTest
  public static void testgetCacheConfiguration() {
    String result = SMC_AC_ServiceProductList.getCacheConfiguration(
      STA_UtilsStatic.ORG_CACHE_SERVICE_PRODUCT_MODEL
    );
    System.assertNotEquals(null, result, 'Check cache intialisation.');
  }

  /**
   * @description : test SMC_AC_ServiceProductList.getCachePhase()
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  @isTest
  public static void testgetCachePhase() {
    String result = SMC_AC_ServiceProductList.getCachePhase(
      STA_UtilsStatic.ORG_CACHE_SERVICE_PRODUCT_CONFIGURATION
    );
    System.assertNotEquals(null, result, 'Check cache intialisation.');
  }

  /**
   * @description : test SMC_AC_ServiceProductList.getCachePower()
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  @isTest
  public static void testgetCachePower() {
    String result = SMC_AC_ServiceProductList.getCachePower(
      STA_UtilsStatic.ORG_CACHE_SERVICE_PRODUCT_PHASE
    );
    System.assertNotEquals(null, result, 'Check cache intialisation.');
  }

  /**
   * @description : test SMC_AC_ServiceProductList.WhereClauseWrapper()
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  @isTest
  public static void testWrapper() {
    SMC_AC_ServiceProductList.WhereClauseWrapper wrapper = new SMC_AC_ServiceProductList.WhereClauseWrapper();
    System.assertNotEquals(
      null,
      wrapper,
      'Check the DTO "SMC_AC_ServiceProductList.WhereClauseWrapper"'
    );
  }
}