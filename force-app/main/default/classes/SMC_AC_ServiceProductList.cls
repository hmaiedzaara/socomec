/*
---------------------------------------------------------------------
-- - Name          : SMC_AC_ServiceProductList
-- - Author        : Vincent RECASENS (VREC)
-- - Description   : This class is the Apex controller of the 
                     lightning component SMC_LC_ServiceProductList.
-- Maintenance History:
--
-- Date         Name 	Version  Remarks 
-- -----------  ------  -------  ---------------------------
-- 25-MARS-2019  VREC   1.0      Initial version 
---------------------------------------------------------------------
*/

public without sharing class SMC_AC_ServiceProductList {
  public class WhereClauseWrapper {
    public String productCode { get; set; }
    public String manufacturer { get; set; }
    public String range { get; set; }
    public String model { get; set; }
    public String configuration { get; set; }
    public String phase { get; set; }
    public String power { get; set; }

    public WhereClauseWrapper() {
    }
  }

  /**
   * @description : get all products in according to the filters from LC
   * @author Vincent RECASENS (Modis) | 10/04/2020
   * @param productName
   * @param jsonWhereClause
   * @return List<Product2>
   **/
  @AuraEnabled
  public static List<Product2> getAllProduct(
    String productName,
    String jsonWhereClause
  ) {
    if (productName != null && productName != '') {
      return getServiceProductSOSL(productName, jsonWhereClause);
    } else {
      return getServiceProductSOQL(jsonWhereClause);
    }
  }

  /**
   * @description : build WHERE clause
   * @author Vincent RECASENS (Modis) | 10/04/2020
   * @param query
   * @param jsonWhereClause
   * @return String
   **/
  @TestVisible
  private static String buildWhereClause(String query, String jsonWhereClause) {
    if (jsonWhereClause != null && jsonWhereClause != '') {
      WhereClauseWrapper whereClauseWrapper = (WhereClauseWrapper) JSON.deserialize(
        jsonWhereClause,
        WhereClauseWrapper.class
      );

      //Product Name never null --> not need to test this (when function will complete [asap]) ----- At 27/03/2019
      String whereclause =
        (whereClauseWrapper.productCode != null
          ? 'ProductCode LIKE \'%' +
            String.escapeSingleQuotes(whereClauseWrapper.productCode) +
            '%\' AND '
          : '') +
        (whereClauseWrapper.manufacturer != null
          ? 'SMC_Manufacturer_p__c=\'' +
            String.escapeSingleQuotes(
              SMC_UTIL_ProductDependencies.getLabelReverse(
                STA_UtilsStatic.ORG_CACHE_SERVICE_PRODUCT_MANUFACTURER,
                whereClauseWrapper.manufacturer
              )
            ) +
            '\' AND '
          : '') +
        (whereClauseWrapper.range != null
          ? 'SMC_Range_p__c=\'' +
            String.escapeSingleQuotes(
              SMC_UTIL_ProductDependencies.getLabelReverse(
                STA_UtilsStatic.ORG_CACHE_SERVICE_PRODUCT_RANGE,
                whereClauseWrapper.range
              )
            ) +
            '\' AND '
          : '') +
        (whereClauseWrapper.model != null
          ? 'SMC_Model_p__c=\'' +
            String.escapeSingleQuotes(
              SMC_UTIL_ProductDependencies.getLabelReverse(
                STA_UtilsStatic.ORG_CACHE_SERVICE_PRODUCT_MODEL,
                whereClauseWrapper.model
              )
            ) +
            '\' AND '
          : '') +
        (whereClauseWrapper.configuration != null
          ? 'SMC_Configuration_p__c=\'' +
            String.escapeSingleQuotes(
              SMC_UTIL_ProductDependencies.getLabelReverse(
                STA_UtilsStatic.ORG_CACHE_SERVICE_PRODUCT_CONFIGURATION,
                whereClauseWrapper.configuration
              )
            ) +
            '\' AND '
          : '') +
        (whereClauseWrapper.phase != null
          ? 'SMC_Phase_p__c=\'' +
            String.escapeSingleQuotes(
              SMC_UTIL_ProductDependencies.getLabelReverse(
                STA_UtilsStatic.ORG_CACHE_SERVICE_PRODUCT_PHASE,
                whereClauseWrapper.phase
              )
            ) +
            '\' AND '
          : '') +
        (whereClauseWrapper.power != null
          ? 'SMC_Power_p__c=\'' +
            String.escapeSingleQuotes(
              SMC_UTIL_ProductDependencies.getLabelReverse(
                STA_UtilsStatic.ORG_CACHE_SERVICE_PRODUCT_POWER,
                whereClauseWrapper.power
              )
            ) +
            '\' AND '
          : '');

      //Add WhereClause to query
      if (whereClause != null && whereClause.length() > 0) {
        query += whereClause;
      }
    }

    //Get RecordTypeId - Service Product
    Map<String, Schema.RecordTypeInfo> recordTypesProduct = new Map<String, Schema.RecordTypeInfo>();
    recordTypesProduct = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName();
    Id productRecordTypeId = recordTypesProduct.get(
        STA_UtilsStatic.RECORDTYPE_SERVICE_PRODUCT
      )
      .getRecordTypeId();

    //Finish query and execute
    query +=
      'RecordTypeId=\'' +
      String.escapeSingleQuotes(productRecordTypeId) +
      '\'';
    return query;
  }

  /**
   * @description : get service product with an SOSL
   * @author Vincent RECASENS (Modis) | 10/04/2020
   * @param productName
   * @param jsonWhereClause
   * @return List<Product2>
   **/
  @TestVisible
  private static List<Product2> getServiceProductSOSL(
    String productName,
    String jsonWhereClause
  ) {
    String query =
      'FIND {' +
      SMC_UtilsMethod.escapeSpecialCharaters(productName) +
      '} IN NAME FIELDS RETURNING ' +
      'Product2(Id, ' +
      'Name, ' +
      'ProductCode, ' +
      'toLabel(SMC_Manufacturer_p__c), ' +
      'toLabel(SMC_Range_p__c), ' +
      'toLabel(SMC_Model_p__c), ' +
      'toLabel(SMC_Configuration_p__c), ' +
      'toLabel(SMC_Phase_p__c), ' +
      'toLabel(SMC_Power_p__c), ' +
      'SMC_Power_Unit_p__c ' +
      'WHERE ';

    List<List<SObject>> soslResult = search.query(
      buildWhereClause(query, jsonWhereClause) + ' ORDER BY Id DESC) LIMIT 20'
    );
    return (List<Product2>) soslResult[0];
  }

  /**
   * @description : get service product with an SOQL
   * @author Vincent RECASENS (Modis) | 10/04/2020
   * @param productName
   * @param jsonWhereClause
   * @return List<Product2>
   **/
  @TestVisible
  private static List<Product2> getServiceProductSOQL(String jsonWhereClause) {
    String query =
      'SELECT  Id, ' +
      'Name, ' +
      'ProductCode, ' +
      'toLabel(SMC_Manufacturer_p__c), ' +
      'toLabel(SMC_Range_p__c), ' +
      'toLabel(SMC_Model_p__c), ' +
      'toLabel(SMC_Configuration_p__c), ' +
      'toLabel(SMC_Phase_p__c), ' +
      'toLabel(SMC_Power_p__c), ' +
      'SMC_Power_Unit_p__c ' +
      'FROM Product2 WHERE ';

    List<Product2> soqlResult = Database.query(
      buildWhereClause(String.escapeSingleQuotes(query), jsonWhereClause) +
      ' ORDER BY Id DESC LIMIT 20'
    );
    return soqlResult;
  }

  /**
   * @description : get SMC_Manufacturer_p__c label and value sorted from the cache
   * @author Vincent RECASENS (Modis) | 10/04/2020
   * @return String
   **/
  @AuraEnabled
  public static String getCacheManufacturer() {
    if (Test.isRunningTest()) {
      return STA_UtilsStatic.MANUFACTURER_CACHE;
    } else {
      SMC_UTIL_ProductDependencies productpicklistDependencies = new SMC_UTIL_ProductDependencies();
      return JSON.serialize(
        productpicklistDependencies.getList(
          STA_UtilsStatic.ORG_CACHE_SERVICE_PRODUCT_MANUFACTURER
        )
      );
    }
  }

  /**
   * @description : get SMC_Range_p__c label and value sorted from the cache
   * @author Vincent RECASENS (Modis) | 10/04/2020
   * @return String
   **/
  @AuraEnabled
  public static String getCacheRange(String manufacturer) {
    if (Test.isRunningTest()) {
      return STA_UtilsStatic.RANGE_CACHE;
    } else {
      SMC_UTIL_ProductDependencies productpicklistDependencies = new SMC_UTIL_ProductDependencies();
      Map<String, Set<String>> manufacturerMap = productpicklistDependencies.getList(
        STA_UtilsStatic.ORG_CACHE_SERVICE_PRODUCT_MANUFACTURER
      );
      for (String key : manufacturerMap.keySet()) {
        if (key == manufacturer) {
          return JSON.serialize(manufacturerMap.get(key));
        }
      }
      return null;
    }
  }

  /**
   * @description : get SMC_Model_p__c label and value sorted from the cache
   * @author Vincent RECASENS (Modis) | 10/04/2020
   * @return String
   **/
  @AuraEnabled
  public static String getCacheModel(String range) {
    if (Test.isRunningTest()) {
      return STA_UtilsStatic.MODEL_CACHE;
    } else {
      SMC_UTIL_ProductDependencies productpicklistDependencies = new SMC_UTIL_ProductDependencies();
      Map<String, Set<String>> rangeMap = productpicklistDependencies.getList(
        STA_UtilsStatic.ORG_CACHE_SERVICE_PRODUCT_RANGE
      );
      for (String key : rangeMap.keySet()) {
        if (key == range) {
          return JSON.serialize(rangeMap.get(key));
        }
      }
      return null;
    }
  }

  /**
   * @description : get SMC_Configuration_p__c label and value sorted from the cache
   * @author Vincent RECASENS (Modis) | 10/04/2020
   * @return String
   **/
  @AuraEnabled
  public static String getCacheConfiguration(String model) {
    if (Test.isRunningTest()) {
      return STA_UtilsStatic.CONFIGURATION_CACHE;
    } else {
      SMC_UTIL_ProductDependencies productpicklistDependencies = new SMC_UTIL_ProductDependencies();
      Map<String, Set<String>> modelMap = productpicklistDependencies.getList(
        STA_UtilsStatic.ORG_CACHE_SERVICE_PRODUCT_MODEL
      );
      for (String key : modelMap.keySet()) {
        if (key == model) {
          return JSON.serialize(modelMap.get(key));
        }
      }
      return null;
    }
  }

  /**
   * @description : get SMC_Phase_p__c label and value sorted from the cache
   * @author Vincent RECASENS (Modis) | 10/04/2020
   * @return String
   **/
  @AuraEnabled
  public static String getCachePhase(String configuration) {
    if (Test.isRunningTest()) {
      return STA_UtilsStatic.PHASE_CACHE;
    } else {
      SMC_UTIL_ProductDependencies productpicklistDependencies = new SMC_UTIL_ProductDependencies();
      Map<String, Set<String>> configurationMap = productpicklistDependencies.getList(
        STA_UtilsStatic.ORG_CACHE_SERVICE_PRODUCT_CONFIGURATION
      );
      for (String key : configurationMap.keySet()) {
        if (key == configuration) {
          return JSON.serialize(configurationMap.get(key));
        }
      }
      return null;
    }
  }

  /**
   * @description : get SMC_Power_p__c label and value sorted from the cache
   * @author Vincent RECASENS (Modis) | 10/04/2020
   * @return String
   **/
  @AuraEnabled
  public static String getCachePower(String phase) {
    if (Test.isRunningTest()) {
      return STA_UtilsStatic.POWER_CACHE;
    } else {
      SMC_UTIL_ProductDependencies productpicklistDependencies = new SMC_UTIL_ProductDependencies();
      Map<String, Set<String>> phaseMap = productpicklistDependencies.getList(
        STA_UtilsStatic.ORG_CACHE_SERVICE_PRODUCT_PHASE
      );
      for (String key : phaseMap.keySet()) {
        if (key == phase) {
          return JSON.serialize(phaseMap.get(key));
        }
      }
      return null;
    }
  }
}