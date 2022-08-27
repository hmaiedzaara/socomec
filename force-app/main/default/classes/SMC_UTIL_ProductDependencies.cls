/*
---------------------------------------------------------------------
-- - Name          : SMC_UTIL_ProductDependencies
-- - Author        : Vincent RECASENS (VREC)
-- - Description   : This class is used to get all picklist on a Product2
                     and store results in organization cache.

-- Maintenance History:
--
-- Date         Name 	Version  Remarks 
-- -----------  ------  -------  ---------------------------
-- 28-MARS-2019  VREC   1.0      Initial version 
---------------------------------------------------------------------
*/

public with sharing class SMC_UTIL_ProductDependencies {
  private Cache.OrgPartition partition;

  public SMC_UTIL_ProductDependencies() {
    this.partition = new Cache.OrgPartition('local.ProductDependencies');
  }

  public void clearCache() {
    this.partition.remove(
      STA_UtilsStatic.ORG_CACHE_SERVICE_PRODUCT_MANUFACTURER
    );
    this.partition.remove(STA_UtilsStatic.ORG_CACHE_SERVICE_PRODUCT_RANGE);
    this.partition.remove(STA_UtilsStatic.ORG_CACHE_SERVICE_PRODUCT_MODEL);
    this.partition.remove(
      STA_UtilsStatic.ORG_CACHE_SERVICE_PRODUCT_CONFIGURATION
    );
    this.partition.remove(STA_UtilsStatic.ORG_CACHE_SERVICE_PRODUCT_PHASE);
  }

  public Map<String, Set<String>> getList(String key) {
    Map<String, Set<String>> result = new Map<String, Set<String>>();
    result = (Map<String, Set<String>>) this.partition.get(key);
    if (result == null) {
      putPicklistDependencies();
      result = (Map<String, Set<String>>) this.partition.get(key);
    }
    return result;
  }

  /**
   * @description : get cache informations
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  public void putPicklistDependencies() {
    Map<String, String> mapManufacturerLabel = getManufacturerLabel();
    Map<String, String> mapRangeLabel = getRangeLabel();
    Map<String, String> mapModelLabel = getModelLabel();
    Map<String, String> mapConfigurationLabel = getConfigurationLabel();
    Map<String, String> mapPhaseLabel = getPhaseLabel();
    Map<String, String> mapPowerLabel = getPowerLabel();

    Map<String, Set<String>> mapManufacturer = new Map<string, set<String>>();
    Map<String, Set<String>> mapRange = new Map<string, set<String>>();
    Map<String, Set<String>> mapModel = new Map<string, set<String>>();
    Map<String, Set<String>> mapConfiguration = new Map<string, set<String>>();
    Map<String, Set<String>> mapPhase = new Map<string, set<String>>();

    Map<String, Schema.RecordTypeInfo> recordTypesProduct = new Map<String, Schema.RecordTypeInfo>();
    recordTypesProduct = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName();
    Id serviceProductId = recordTypesProduct.get(
        STA_UtilsStatic.RECORDTYPE_SERVICE_PRODUCT
      )
      .getRecordTypeId();

    for (Product2 oneProduct : [
      SELECT
        SMC_Manufacturer_p__c,
        SMC_Range_p__c,
        SMC_Model_p__c,
        SMC_Configuration_p__c,
        SMC_Phase_p__c,
        SMC_Power_p__c
      FROM Product2
      WHERE
        SMC_Manufacturer_p__c IN :mapManufacturerLabel.keySet()
        AND RecordTypeId = :serviceProductId
    ]) {
      //Manufacturer
      if (
        mapManufacturer.get(
          mapManufacturerLabel.get(oneProduct.SMC_Manufacturer_p__c)
        ) == null
      ) {
        mapManufacturer.put(
          mapManufacturerLabel.get(oneProduct.SMC_Manufacturer_p__c),
          new Set<String>{ STA_UtilsStatic.DEFAULT_PICKLIST_VALUE }
        );
      }
      mapManufacturer.get(
          mapManufacturerLabel.get(oneProduct.SMC_Manufacturer_p__c)
        )
        .add(mapRangeLabel.get(oneProduct.SMC_Range_p__c));

      //Range
      if (mapRange.get(mapRangeLabel.get(oneProduct.SMC_Range_p__c)) == null) {
        mapRange.put(
          mapRangeLabel.get(oneProduct.SMC_Range_p__c),
          new Set<String>{ STA_UtilsStatic.DEFAULT_PICKLIST_VALUE }
        );
      }
      mapRange.get(mapRangeLabel.get(oneProduct.SMC_Range_p__c))
        .add(mapModelLabel.get(oneProduct.SMC_Model_p__c));

      //Model
      if (mapModel.get(mapModelLabel.get(oneProduct.SMC_Model_p__c)) == null) {
        mapModel.put(
          mapModelLabel.get(oneProduct.SMC_Model_p__c),
          new Set<String>{ STA_UtilsStatic.DEFAULT_PICKLIST_VALUE }
        );
      }
      mapModel.get(mapModelLabel.get(oneProduct.SMC_Model_p__c))
        .add(mapConfigurationLabel.get(oneProduct.SMC_Configuration_p__c));

      //Configuration
      if (
        mapConfiguration.get(
          mapConfigurationLabel.get(oneProduct.SMC_Configuration_p__c)
        ) == null
      ) {
        mapConfiguration.put(
          mapConfigurationLabel.get(oneProduct.SMC_Configuration_p__c),
          new Set<String>{ STA_UtilsStatic.DEFAULT_PICKLIST_VALUE }
        );
      }
      mapConfiguration.get(
          mapConfigurationLabel.get(oneProduct.SMC_Configuration_p__c)
        )
        .add(mapPhaseLabel.get(oneProduct.SMC_Phase_p__c));

      //Phase
      if (mapPhase.get(mapPhaseLabel.get(oneProduct.SMC_Phase_p__c)) == null) {
        mapPhase.put(
          mapPhaseLabel.get(oneProduct.SMC_Phase_p__c),
          new Set<String>{ STA_UtilsStatic.DEFAULT_PICKLIST_VALUE }
        );
      }
      mapPhase.get(mapPhaseLabel.get(oneProduct.SMC_Phase_p__c))
        .add(mapPowerLabel.get(oneProduct.SMC_Power_p__c));
    }
    mapManufacturer.put(
      STA_UtilsStatic.DEFAULT_PICKLIST_VALUE,
      new Set<String>{ STA_UtilsStatic.DEFAULT_PICKLIST_VALUE }
    );
    this.partition.put(
      STA_UtilsStatic.ORG_CACHE_SERVICE_PRODUCT_MANUFACTURER,
      mapManufacturer
    );
    this.partition.put(
      STA_UtilsStatic.ORG_CACHE_SERVICE_PRODUCT_RANGE,
      mapRange
    );
    this.partition.put(
      STA_UtilsStatic.ORG_CACHE_SERVICE_PRODUCT_MODEL,
      mapModel
    );
    this.partition.put(
      STA_UtilsStatic.ORG_CACHE_SERVICE_PRODUCT_CONFIGURATION,
      mapConfiguration
    );
    this.partition.put(
      STA_UtilsStatic.ORG_CACHE_SERVICE_PRODUCT_PHASE,
      mapPhase
    );
  }

  /** GET ALL LABEL **/
  public Map<String, String> getManufacturerLabel() {
    //Get Label from picklist definition
    Map<String, String> manufacturers = new Map<String, String>();
    Schema.DescribeFieldResult fieldResult = Product2.SMC_Manufacturer_p__c.getDescribe();
    List<Schema.PicklistEntry> entries = fieldResult.getPicklistValues();
    for (Integer i = entries.size() - 1; i >= 0; --i) {
      manufacturers.put(entries[i].getValue(), entries[i].getLabel());
    }
    return manufacturers;
  }

  public Map<String, String> getRangeLabel() {
    //Get Label from picklist definition
    Map<String, String> ranges = new Map<String, String>();
    Schema.DescribeFieldResult fieldResult = Product2.SMC_Range_p__c.getDescribe();
    List<Schema.PicklistEntry> entries = fieldResult.getPicklistValues();
    for (Integer i = entries.size() - 1; i >= 0; --i) {
      ranges.put(entries[i].getValue(), entries[i].getLabel());
    }
    return ranges;
  }

  public Map<String, String> getModelLabel() {
    //Get Label from picklist definition
    Map<String, String> models = new Map<String, String>();
    Schema.DescribeFieldResult fieldResult = Product2.SMC_Model_p__c.getDescribe();
    List<Schema.PicklistEntry> entries = fieldResult.getPicklistValues();
    for (Integer i = entries.size() - 1; i >= 0; --i) {
      models.put(entries[i].getValue(), entries[i].getLabel());
    }
    return models;
  }

  public Map<String, String> getConfigurationLabel() {
    //Get Label from picklist definition
    Map<String, String> configurations = new Map<String, String>();
    Schema.DescribeFieldResult fieldResult = Product2.SMC_Configuration_p__c.getDescribe();
    List<Schema.PicklistEntry> entries = fieldResult.getPicklistValues();
    for (Integer i = entries.size() - 1; i >= 0; --i) {
      configurations.put(entries[i].getValue(), entries[i].getLabel());
    }
    return configurations;
  }

  public Map<String, String> getPhaseLabel() {
    //Get Label from picklist definition
    Map<String, String> phases = new Map<String, String>();
    Schema.DescribeFieldResult fieldResult = Product2.SMC_Phase_p__c.getDescribe();
    List<Schema.PicklistEntry> entries = fieldResult.getPicklistValues();
    for (Integer i = entries.size() - 1; i >= 0; --i) {
      phases.put(entries[i].getValue(), entries[i].getLabel());
    }
    return phases;
  }

  public Map<String, String> getPowerLabel() {
    //Get Label from picklist definition
    Map<String, String> powers = new Map<String, String>();
    Schema.DescribeFieldResult fieldResult = Product2.SMC_Power_p__c.getDescribe();
    List<Schema.PicklistEntry> entries = fieldResult.getPicklistValues();
    for (Schema.PicklistEntry entry : entries) {
      powers.put(entry.getValue(), entry.getLabel());
    }
    return powers;
  }

  /** GET VALUE **/
  public static String getLabelReverse(String labelSearched, String value) {
    //Get Label from value (from selection in Lightning component)
    String returnValue;
    //Manufacturer
    if (
      labelSearched == STA_UtilsStatic.ORG_CACHE_SERVICE_PRODUCT_MANUFACTURER
    ) {
      Schema.DescribeFieldResult fieldResult = Product2.SMC_Manufacturer_p__c.getDescribe();
      List<Schema.PicklistEntry> entries = fieldResult.getPicklistValues();
      for (Schema.PicklistEntry oneEntry : entries) {
        if (value == oneEntry.getLabel()) {
          returnValue = oneEntry.getValue();
          break;
        }
      }
    } else if (
      labelSearched == STA_UtilsStatic.ORG_CACHE_SERVICE_PRODUCT_RANGE
    ) {
      //Range
      Schema.DescribeFieldResult fieldResult = Product2.SMC_Range_p__c.getDescribe();
      List<Schema.PicklistEntry> entries = fieldResult.getPicklistValues();
      for (Schema.PicklistEntry oneEntry : entries) {
        if (value == oneEntry.getLabel()) {
          returnValue = oneEntry.getValue();
          break;
        }
      }
    } else if (
      labelSearched == STA_UtilsStatic.ORG_CACHE_SERVICE_PRODUCT_MODEL
    ) {
      //Model
      Schema.DescribeFieldResult fieldResult = Product2.SMC_Model_p__c.getDescribe();
      List<Schema.PicklistEntry> entries = fieldResult.getPicklistValues();
      for (Schema.PicklistEntry oneEntry : entries) {
        if (value == oneEntry.getLabel()) {
          returnValue = oneEntry.getValue();
          break;
        }
      }
    } else if (
      labelSearched == STA_UtilsStatic.ORG_CACHE_SERVICE_PRODUCT_CONFIGURATION
    ) {
      //Configuration
      Schema.DescribeFieldResult fieldResult = Product2.SMC_Configuration_p__c.getDescribe();
      List<Schema.PicklistEntry> entries = fieldResult.getPicklistValues();
      for (Schema.PicklistEntry oneEntry : entries) {
        if (value == oneEntry.getLabel()) {
          returnValue = oneEntry.getValue();
          break;
        }
      }
    } else if (
      labelSearched == STA_UtilsStatic.ORG_CACHE_SERVICE_PRODUCT_PHASE
    ) {
      //Phase
      Schema.DescribeFieldResult fieldResult = Product2.SMC_Phase_p__c.getDescribe();
      List<Schema.PicklistEntry> entries = fieldResult.getPicklistValues();
      for (Schema.PicklistEntry oneEntry : entries) {
        if (value == oneEntry.getLabel()) {
          returnValue = oneEntry.getValue();
          break;
        }
      }
    } else if (
      labelSearched == STA_UtilsStatic.ORG_CACHE_SERVICE_PRODUCT_POWER
    ) {
      //Power
      Schema.DescribeFieldResult fieldResult = Product2.SMC_Power_p__c.getDescribe();
      List<Schema.PicklistEntry> entries = fieldResult.getPicklistValues();
      for (Schema.PicklistEntry oneEntry : entries) {
        if (value == oneEntry.getLabel()) {
          returnValue = oneEntry.getValue();
          break;
        }
      }
    }

    return returnValue;
  }
}