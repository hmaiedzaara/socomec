/*
-----------------------------------------------------------------------------------
-- - Name : SMC_AC_CreateRecordFromDatatable
-- - Author : Vincent RECASENS (VRE)
-- - Description : This class is the Apex controller of the lightning 
                   component SMC_LC_CreateRecordFromDatatable
--
-- Maintenance History:
--
-- Date         Name   Version     Remarks
-- -----------  ----   -------     ----------------------------
-- 19-MAR-2019  VRE    1.0         Initial Version
------------------------------------------------------------------------------------
*/

public without sharing class SMC_AC_CreateRecordFromDatatable {
  /** WRAPPER **/
  public class WrapperDataTableForWorkerOrderLineItem implements Comparable {
    public String targetObject { get; set; }
    public String id { get; set; }
    public String sparePartProductName { get; set; }
    public String gtlGroup { get; set; }
    public String gtlSubset { get; set; }
    public Integer quantity { get; set; }

    public WrapperDataTableForWorkerOrderLineItem(
      Id sparePartProductId,
      String sparePartProductName,
      String gtlGroup,
      String gtlSubset,
      Integer quantity
    ) {
      this.targetObject = STA_UtilsStatic.WORK_ORDER_LINE_ITEM;
      this.id = sparePartProductId;
      this.sparePartProductName = sparePartProductName;
      this.gtlGroup = gtlGroup;
      this.gtlSubset = gtlSubset;
      this.quantity = quantity == null ? 0 : quantity;
    }

    public Integer compareTo(Object compareTo) {
      WrapperDataTableForWorkerOrderLineItem compareToGoal = (WrapperDataTableForWorkerOrderLineItem) compareTo;

      // The return value of 0 indicates that both elements are equal.
      Integer returnValue = 0;

      if (this.sparePartProductName > compareToGoal.sparePartProductName) {
        return 1;
      } else if (sparePartProductName < compareToGoal.sparePartProductName) {
        return -1;
      }

      return returnValue;
    }
  }

  /** WRAPPER **/
  public class WrapperDataTableForAsset implements Comparable {
    public String targetObject { get; set; }
    public String id { get; set; }
    public String gtlId { get; set; }
    public String serviceProductName { get; set; }
    public String serviceProductCode { get; set; }
    public String serviceSparePartCode { get; set; }
    public String gtlGroup { get; set; }
    public String gtlSubset { get; set; }
    public String gtlOption { get; set; }
    public String gtlParentOrganization { get; set; }
    public Decimal sparePartWarrantyAddMonth { get; set; }
    public Integer quantity { get; set; }
    public String key { get; set; }

    public WrapperDataTableForAsset(
      Id serviceProductId,
      Id gtlId,
      String serviceProductName,
      String serviceProductCode,
      String serviceSparePartCode,
      String gtlGroup,
      String gtlSubset,
      String gtlOption,
      String gtlParentOrganization,
      Decimal sparePartWarrantyAddMonth,
      Integer quantity,
      String key
    ) {
      this.targetObject = STA_UtilsStatic.ASSET;
      this.id = serviceProductId;
      this.gtlId = gtlId;
      this.serviceProductName = serviceProductName;
      this.serviceProductCode = serviceProductCode;
      this.serviceSparePartCode = serviceSparePartCode;
      this.gtlGroup = gtlGroup;
      this.gtlSubset = gtlSubset;
      this.gtlOption = gtlOption;
      this.gtlParentOrganization = gtlParentOrganization;
      this.sparePartWarrantyAddMonth = sparePartWarrantyAddMonth;
      this.quantity = quantity == null ? 0 : quantity;
      this.key = key;
    }

    public WrapperDataTableForAsset(
      Id serviceProductId,
      Id gtlId,
      String serviceProductName,
      String serviceProductCode,
      String serviceSparePartCode,
      String gtlGroup,
      String gtlSubset,
      String gtlOption,
      String gtlParentOrganization,
      Decimal sparePartWarrantyAddMonth,
      Integer quantity
    ) {
      this.targetObject = STA_UtilsStatic.ASSET;
      this.id = serviceProductId;
      this.gtlId = gtlId;
      this.serviceProductName = serviceProductName;
      this.serviceProductCode = serviceProductCode;
      this.serviceSparePartCode = serviceSparePartCode;
      this.gtlGroup = gtlGroup;
      this.gtlSubset = gtlSubset;
      this.gtlOption = gtlOption;
      this.gtlParentOrganization = gtlParentOrganization;
      this.sparePartWarrantyAddMonth = sparePartWarrantyAddMonth;
      this.quantity = quantity == null ? 0 : quantity;
      this.key = serviceProductId;
    }

    public Integer compareTo(Object compareTo) {
      WrapperDataTableForAsset compareToGoal = (WrapperDataTableForAsset) compareTo;

      // The return value of 0 indicates that both elements are equal.
      Integer returnValue = 0;

      if (this.serviceProductName > compareToGoal.serviceProductName) {
        return 1;
      } else if (serviceProductName < compareToGoal.serviceProductName) {
        return -1;
      }

      return returnValue;
    }
  }

  /**
   * @description : distinction beteween WorkOrderLineItem and Asset and get informations
   * @author Vincent RECASENS (Modis) | 10/04/2020
   * @param recordId
   * @return String  = serialization(WrapperDataTableForWorkerOrderLineItem) OR serialization(WrapperDataTableForAsset)
   **/
  @AuraEnabled
  public static String getInformations(String recordId, Integer factorOffset, Boolean onlyBattery, String searchSparePartCode) {
    Id recId = (Id) recordId;
    String result;
    if (recId.getSobjectType() == Schema.WorkOrderLineItem.SObjectType) {
      result = getAllProductForWorkOrderLineItem(recordId, factorOffset);
    } else if (recId.getSobjectType() == Schema.Asset.SObjectType && !onlyBattery) {
      result = getAllProductForAsset(recordId, factorOffset, searchSparePartCode);
    } else if (recId.getSobjectType() == Schema.Asset.SObjectType && onlyBattery) {
      result = getSparePartNotLinkToGTL(recordId, factorOffset, searchSparePartCode);
    }
    return result;
  }

  /**
   * @description : get all product from WorkOrderLineItem
   * @author Vincent RECASENS (Modis) | 10/04/2020
   * @param workOrderLineItemId
   * @param factorOffset
   * @return String = serialization(WrapperDataTableForWorkerOrderLineItem)
   **/
  @TestVisible
  private static String getAllProductForWorkOrderLineItem(
    String workOrderLineItemId,
    Integer factorOffset  
  ) {
    System.debug(
      LoggingLevel.INFO,
      '>>>>>> SMC_AC_CreateRecordFromDatatable : getAllProductForWorkOrderLineItem - START'
    );
    //Get record
    WorkOrderLineItem workOrderLineItem = [
      SELECT Id, AssetId, Asset.Product2Id
      FROM WorkOrderLineItem
      WHERE Id = :workOrderLineItemId
    ];

    //Get products already linked
    List<Id> product2IdProductRequiredAlreadyCreated = new List<Id>();
    for (ProductRequired oneProductRequired : [
      SELECT Id, Product2Id
      FROM ProductRequired
      WHERE ParentRecordId = :workOrderLineItemId
    ]) {
      product2IdProductRequiredAlreadyCreated.add(
        oneProductRequired.Product2Id
      );
    }

    //Get product to display
    List<WrapperDataTableForWorkerOrderLineItem> wrapperList = new List<WrapperDataTableForWorkerOrderLineItem>();
    Set<Id> sparePartId = new Set<Id>();
    Integer queryLimit = 100;
    Integer offset = (queryLimit == 0 ? 0 : queryLimit*factorOffset);
    Map<String, Schema.RecordTypeInfo> recordTypesProduct2 = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName();
    Id sparePartRecordTypeId = recordTypesProduct2.get(
        STA_UtilsStatic.RECORDTYPE_SPARE_PART_PRODUCT
      )
      .getRecordTypeId();

    for (SMC_GtlServiceProductAssociation__c oneAssociation : [
      SELECT
        SMC_Logistic_Technical_Guide__c,
        SMC_Logistic_Technical_Guide__r.SMC_Spare_Part__c,
        SMC_Logistic_Technical_Guide__r.SMC_Spare_Part__r.Name,
        SMC_Logistic_Technical_Guide__r.SMC_Group__c,
        SMC_Logistic_Technical_Guide__r.SMC_Subset_GTL__c,
        SMC_Logistic_Technical_Guide__r.SMC_Quantity__c
      FROM SMC_GtlServiceProductAssociation__c
      WHERE
        SMC_Service_Product__c = :workOrderLineItem.Asset.Product2Id
        AND SMC_Logistic_Technical_Guide__r.SMC_Spare_Part__c NOT IN :product2IdProductRequiredAlreadyCreated
        AND SMC_Logistic_Technical_Guide__r.SMC_Spare_Part__r.RecordTypeId = :sparePartRecordTypeId
        AND SMC_Logistic_Technical_Guide__r.SMC_Currently_Active__c = true
      // ORDER BY Id
      // LIMIT :queryLimit
      // OFFSET :offset
    ]) {
      if (
        !sparePartId.contains(
          oneAssociation.SMC_Logistic_Technical_Guide__r.SMC_Spare_Part__c
        )
      ) {
        wrapperList.add(
          new WrapperDataTableForWorkerOrderLineItem(
            oneAssociation.SMC_Logistic_Technical_Guide__r.SMC_Spare_Part__c,
            oneAssociation.SMC_Logistic_Technical_Guide__r.SMC_Spare_Part__r.Name,
            oneAssociation.SMC_Logistic_Technical_Guide__r.SMC_Group__c,
            oneAssociation.SMC_Logistic_Technical_Guide__r.SMC_Subset_GTL__c,
            Integer.valueOf(
              oneAssociation.SMC_Logistic_Technical_Guide__r.SMC_Quantity__c
            )
          )
        );
      }
      sparePartId.add(
        oneAssociation.SMC_Logistic_Technical_Guide__r.SMC_Spare_Part__c
      );
    }
    wrapperList.sort();

    System.debug(
      LoggingLevel.INFO,
      '>>>>>> SMC_AC_CreateRecordFromDatatable : getAllProductForWorkOrderLineItem - END'
    );
    return JSON.serialize(wrapperList);
  }

  /**
   * @description : get all product from WorkOrderLineItem
   * @author Vincent RECASENS (Modis) | 10/04/2020
   * @param assetId
   * @param factorOffset
   * @return String = serialization(WrapperDataTableForAsset)
   **/
  @TestVisible
  private static String getAllProductForAsset(String assetId, Integer factorOffset, String spareCodeSearched) {
    System.debug(
      LoggingLevel.INFO,
      '>>>>>> SMC_AC_CreateRecordFromDatatable : getAllProductForAsset - START'
    );
    //Get record
    Asset theAsset = [
      SELECT
        Id,
        Product2Id,
        SMC_Parent_service_organisation__c,
        AccountId,
        ContactId
      FROM Asset
      WHERE Id = :assetId
    ];

    //Get product to display
    List<WrapperDataTableForAsset> wrapperList = new List<WrapperDataTableForAsset>();
    Integer queryLimit = 100;
    Integer offset = (queryLimit == 0 ? 0 : queryLimit*factorOffset);
    Set<String> productId_Group_Subset = new Set<String>();
    
    //Build query
    Date dateToday = Date.today();
    Id theAssetProductId = theAsset.Product2Id;
    String obsoleteLabel = STA_UtilsStatic.PRODUCT_OBSOLETE;
    String query = 'SELECT SMC_Logistic_Technical_Guide__c, ' + 
                          'SMC_Logistic_Technical_Guide__r.SMC_Spare_Part__c, ' + 
                          'SMC_Logistic_Technical_Guide__r.SMC_Spare_Part__r.Name, ' + 
                          'SMC_Logistic_Technical_Guide__r.SMC_Spare_Part__r.ProductCode, ' + 
                          'SMC_Logistic_Technical_Guide__r.SMC_Spare_Part__r.SMC_Warranty_duration_month__c, ' + 
                          'SMC_Logistic_Technical_Guide__r.SMC_Spare_Part_Code__c, ' + 
                          'SMC_Logistic_Technical_Guide__r.SMC_Quantity__c, ' + 
                          'SMC_Logistic_Technical_Guide__r.SMC_Group__c, ' + 
                          'SMC_Logistic_Technical_Guide__r.SMC_Subset_GTL__c, ' + 
                          'SMC_Logistic_Technical_Guide__r.SMC_Option__c, ' + 
                          'SMC_Service_Product__c ' + 
                    'FROM SMC_GtlServiceProductAssociation__c ' + 
                    'WHERE SMC_Service_Product__c = :theAssetProductId ' + 
                          // 'AND SMC_Logistic_Technical_Guide__r.SMC_Spare_Part__c NOT IN :assetRelatedObjectAlreadyCreated ' + 
                          'AND SMC_Logistic_Technical_Guide__r.SMC_IsServiceComponent__c = \'yes\' ' + 
                          'AND SMC_Logistic_Technical_Guide__r.SMC_Status_GTL__c != :obsoleteLabel ' + 
                          'AND (SMC_Logistic_Technical_Guide__r.SMC_ValidityDate__c = null ' + 
                          'OR SMC_Logistic_Technical_Guide__r.SMC_ValidityDate__c >= :dateToday) ' + 
                          'AND SMC_Logistic_Technical_Guide__r.SMC_Start_Date__c <= :dateToday ';
    if(spareCodeSearched != null && spareCodeSearched != ''){
      query += 'AND SMC_Logistic_Technical_Guide__r.SMC_Spare_Part__r.ProductCode LIKE \'' + spareCodeSearched + '%\'';
    }
    query += 'ORDER BY Id LIMIT :queryLimit OFFSET :offset';
    
    for (
      SMC_GtlServiceProductAssociation__c oneAssociation : (List<SMC_GtlServiceProductAssociation__c>) Database.query(query)
    ) {
      if (
        !productId_Group_Subset.contains(
          oneAssociation.SMC_Logistic_Technical_Guide__r.SMC_Spare_Part__c + 
          '' + 
          oneAssociation.SMC_Logistic_Technical_Guide__r.SMC_Group__c + 
          '' + 
          oneAssociation.SMC_Logistic_Technical_Guide__r.SMC_Subset_GTL__c
        )
      ) {
        wrapperList.add(
          new WrapperDataTableForAsset(
            oneAssociation.SMC_Logistic_Technical_Guide__r.SMC_Spare_Part__c,
            oneAssociation.SMC_Logistic_Technical_Guide__C,
            oneAssociation.SMC_Logistic_Technical_Guide__r.SMC_Spare_Part__r.Name,
            oneAssociation.SMC_Logistic_Technical_Guide__r.SMC_Spare_Part__r.ProductCode,
            oneAssociation.SMC_Logistic_Technical_Guide__r.SMC_Spare_Part_Code__c,
            oneAssociation.SMC_Logistic_Technical_Guide__r.SMC_Group__c,
            oneAssociation.SMC_Logistic_Technical_Guide__r.SMC_Subset_GTL__c,
            oneAssociation.SMC_Logistic_Technical_Guide__r.SMC_Option__c,
            theAsset.SMC_Parent_service_organisation__c,
            oneAssociation.SMC_Logistic_Technical_Guide__r.SMC_Spare_Part__r.SMC_Warranty_duration_month__c,
            Integer.valueOf(
              oneAssociation.SMC_Logistic_Technical_Guide__r.SMC_Quantity__c
            ),
            (oneAssociation.SMC_Logistic_Technical_Guide__r.SMC_Spare_Part__c + 
             '' + 
             oneAssociation.SMC_Logistic_Technical_Guide__r.SMC_Group__c + 
             '' + 
             oneAssociation.SMC_Logistic_Technical_Guide__r.SMC_Subset_GTL__c)
          )
        );
        // (Double) oneAssociation.SMC_Logistic_Technical_Guide__r.SMC_Replacement_Frequency__c));
      }
      productId_Group_Subset.add(
        oneAssociation.SMC_Logistic_Technical_Guide__r.SMC_Spare_Part__c + 
        '' + 
        oneAssociation.SMC_Logistic_Technical_Guide__r.SMC_Group__c + 
        '' + 
        oneAssociation.SMC_Logistic_Technical_Guide__r.SMC_Subset_GTL__c
      );
    }
    //Sort list
    wrapperList.sort();

    System.debug(
      LoggingLevel.INFO,
      '>>>>>> SMC_AC_CreateRecordFromDatatable : getAllProductForAsset - END'
    );
    return JSON.serialize(wrapperList);
  }

  /**
  * @description : add product (SparePart) not link to GTL and with SMC_Technical_Item_Group__c = 'battery'
  * @author Vincent RECASENS (Modis) | 05-17-2021 
  * @param theAsset 
  * @param wrapperList 
  * @param assetRelatedObjectAlreadyCreated
  * @return List<WrapperDataTableForAsset> 
  **/
  @TestVisible
  private static String getSparePartNotLinkToGTL(String assetId, Integer factorOffset, String spareCodeSearched){
    System.debug(
      LoggingLevel.INFO,
      '>>>>>> SMC_AC_CreateRecordFromDatatable : getSparePartNotLinkToGTL - START'
    );
    //Get record
    Asset theAsset = [
      SELECT
        Id,
        Product2Id,
        SMC_Parent_service_organisation__c,
        AccountId,
        ContactId
      FROM Asset
      WHERE Id = :assetId
    ];

    //Get asset already linked
    Map<String, Schema.RecordTypeInfo> recordTypesAsset = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName();
    Id assetRelatedObjectRecordTypeId = recordTypesAsset.get(
        STA_UtilsStatic.RECORDTYPE_ASSET_RELATED_OBJECT
      )
      .getRecordTypeId();
    List<Id> assetRelatedObjectAlreadyCreated = new List<Id>();
    for (Asset oneAsset : [
      SELECT Id, Product2Id
      FROM Asset
      WHERE
        ParentId = :assetId
        AND RecordTypeId = :assetRelatedObjectRecordTypeId
    ]) {
      assetRelatedObjectAlreadyCreated.add(oneAsset.Product2Id);
    }

    //Get product to display
    List<WrapperDataTableForAsset> wrapperList = new List<WrapperDataTableForAsset>();
    Set<Id> productId = new Set<Id>();
    Integer queryLimit = 100;
    Integer offset = (queryLimit == 0 ? 0 : queryLimit*factorOffset);
    Id recordTypeIdProductSparePart = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName().get(
      STA_UtilsStatic.RECORDTYPE_SPARE_PART_PRODUCT
    ).getRecordTypeId();

    //Build query
    String technicalItemGroupBattery = STA_UtilsStatic.TECHNICAL_ITEM_GROUP_BATTERY;
    String query = 'SELECT Id, ' + 
                          'Name, ' + 
                          'ProductCode ' + 
                   'FROM Product2 ' + 
                   'WHERE RecordTypeId = :recordTypeIdProductSparePart ' + 
                        'AND IsActive = TRUE ' + 
                        'AND Id NOT IN :assetRelatedObjectAlreadyCreated ' + 
                        'AND SMC_Technical_Item_Group__c = :technicalItemGroupBattery '; 
    if(spareCodeSearched != null && spareCodeSearched != ''){
      query += 'AND ProductCode LIKE \'' + spareCodeSearched + '%\' ';
    }
    query += 'ORDER BY Id LIMIT :queryLimit OFFSET :offset';
    // for(Product2 onePdt : [SELECT Id, 
    //                               Name, 
    //                               ProductCode 
    //                        FROM Product2 
    //                        WHERE RecordTypeId = :recordTypeIdProductSparePart AND 
    //                              IsActive = TRUE AND 
    //                              Id NOT IN :assetRelatedObjectAlreadyCreated AND 
    //                              SMC_Technical_Item_Group__c = :STA_UtilsStatic.TECHNICAL_ITEM_GROUP_BATTERY    
    //                        ORDER BY Id
    //                        LIMIT :queryLimit
    //                        OFFSET :offset
    //                       ]
    // ) {
    for(Product2 onePdt : (List<Product2>) Database.query(query)) {
      if (!productId.contains(onePdt.Id)){
        wrapperList.add(
          new WrapperDataTableForAsset(
            onePdt.Id,
            null,
            onePdt.Name,
            onePdt.ProductCode,
            onePdt.ProductCode,
            STA_UtilsStatic.BATTERY,
            null,
            null,
            theAsset.SMC_Parent_service_organisation__c,
            null,
            1
          )
        );
      }
      productId.add(onePdt.Id);
    }

    wrapperList.sort();

    System.debug(
      LoggingLevel.INFO,
      '>>>>>> SMC_AC_CreateRecordFromDatatable : getSparePartNotLinkToGTL - END'
    );
    return JSON.serialize(wrapperList);
  } 

  /**
   * @description : save the selection from LC
   * @author Vincent RECASENS (Modis) | 10/04/2020
   * @param recordId
   * @param selectedRows
   * @return Boolean
   **/
  @AuraEnabled
  public static Boolean saveRecord(String recordId, String selectedRows) {
    System.debug(
      LoggingLevel.INFO,
      '>>>>>> SMC_AC_CreateRecordFromDatatable : saveRecord - START'
    );
    Id recId = (Id) recordId;
    Boolean result;
    if (recId.getSobjectType() == Schema.WorkOrderLineItem.SObjectType) {
      result = saveProductRequired(recordId, selectedRows);
    } else if (recId.getSobjectType() == Schema.Asset.SObjectType) {
      result = saveAssetRelatedObject(recordId, selectedRows);
    }
    System.debug(
      LoggingLevel.INFO,
      '>>>>>> SMC_AC_CreateRecordFromDatatable : saveRecord - END'
    );
    return result;
  }

  /**
   * @description : save ProductRequired for WorkOrderLineItem
   * @author Vincent RECASENS (Modis) | 10/04/2020
   * @param workOrderLineItemId
   * @param selectedRows
   * @return Boolean
   **/
  @TestVisible
  private static Boolean saveProductRequired(
    String workOrderLineItemId,
    String selectedRows
  ) {
    System.debug(
      LoggingLevel.INFO,
      '>>>>>> SMC_AC_CreateRecordFromDatatable : saveProductRequired - START'
    );

    List<WrapperDataTableForWorkerOrderLineItem> wrapperList = (List<WrapperDataTableForWorkerOrderLineItem>) JSON.deserialize(
      selectedRows,
      List<WrapperDataTableForWorkerOrderLineItem>.class
    );
    if (wrapperList == null || wrapperList.size() == 0) {
      return false;
    }
    Boolean resultCreation = SMC_AP_ManageProductRequired.createProductRequired(
      workOrderLineItemId,
      wrapperList
    );

    System.debug(
      LoggingLevel.INFO,
      '>>>>>> SMC_AC_CreateRecordFromDatatable : saveProductRequired - END'
    );
    return resultCreation;
  }

  /**
   * @description : save AssetRelatedObject(ServiceBOM) for Asset
   * @author Vincent RECASENS (Modis) | 10/04/2020
   * @param assetId
   * @param selectedRows
   * @return Boolean
   **/
  @TestVisible
  private static Boolean saveAssetRelatedObject(
    String assetId,
    String selectedRows
  ) {
    System.debug(
      LoggingLevel.INFO,
      '>>>>>> SMC_AC_CreateRecordFromDatatable : saveAssetRelatedObject - START'
    );

    List<WrapperDataTableForAsset> wrapperList = (List<WrapperDataTableForAsset>) JSON.deserialize(
      selectedRows,
      List<WrapperDataTableForAsset>.class
    );
    if (wrapperList == null || wrapperList.size() == 0) {
      System.debug(
        LoggingLevel.INFO,
        '>>>>>> SMC_AC_CreateRecordFromDatatable : saveAssetRelatedObject - END with wrapperList NULL'
      );
      return false;
    }

    Map<String, Schema.RecordTypeInfo> recordTypesAsset = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName();
    Id assetRelatedObjectRecordTypeId = recordTypesAsset.get(
        STA_UtilsStatic.RECORDTYPE_ASSET_RELATED_OBJECT
      )
      .getRecordTypeId();

    Asset theAsset = [
      SELECT
        Id,
        Product2Id,
        SMC_Parent_service_organisation__c,
        AccountId,
        ContactId,
        InstallDate,
        SMC_CommissioningDate__c,
        SMC_Manufacturing_date__c,
        SMC_Shipping_date__c,
        CreatedDate
      FROM Asset
      WHERE Id = :assetId
    ];

    Boolean resultCreation = SMC_AP_ManageAsset.creationRelatedObject(
      theAsset,
      assetRelatedObjectRecordTypeId,
      wrapperList
    );

    System.debug(
      LoggingLevel.INFO,
      '>>>>>> SMC_AC_CreateRecordFromDatatable : saveAssetRelatedObject - END'
    );
    return resultCreation;
  }
}