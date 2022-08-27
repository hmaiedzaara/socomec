/*
---------------------------------------------------------------------------
-- - Name : SMC_AP_ManageAsset
-- - Author : Vincent RECASENS
-- - Description : This class manage Asset
--
-- Maintenance History:
--
-- Date         Name        Version     Remarks
-- -----------  ----        -------     -----------------------
-- 19-FEB-2019  VRE  		1.0     	Initial Version
-- 04-MAR-2019	TOC			1.1			Linked to the relational GTL
---------------------------------------------------------------------------
*/

public without sharing class SMC_AP_ManageAsset {
  public static SMC_AC_CreateAssetRelatedObject_GTL.ResultWrapper resultWrapperAssetForCreationRelatedObject;

  /**
   * @description : create asset ServiceBOM from trigger
   * @author Vincent RECASENS (Modis) | 08/04/2020
   * @param newMap
   * @param assetToPreviousBomMap
   * @return SMC_AC_CreateAssetRelatedObject_GTL.ResultWrapper
   **/
  public static SMC_AC_CreateAssetRelatedObject_GTL.ResultWrapper createAssetRelatedObject(
    Map<Id, Asset> newMap,
    Map<id, previousBillOfMaterialDates> assetToPreviousBomMap
  ) {
    System.debug(
      LoggingLevel.INFO,
      '>>>>>> SMC_AP_ManageAsset.createAssetRelatedObject(newMap, assetToPreviousBomMap) - START'
    );

    resultWrapperAssetForCreationRelatedObject = new SMC_AC_CreateAssetRelatedObject_GTL.ResultWrapper();

    if (newMap.size() == 0) {
      resultWrapperAssetForCreationRelatedObject.emptyList = true;
      System.debug(
        LoggingLevel.INFO,
        '>>>>>> SMC_AP_ManageAsset.createAssetRelatedObject - Empty input list END'
      );
      return resultWrapperAssetForCreationRelatedObject;
    }

    Map<String, Schema.RecordTypeInfo> recordTypesAsset = new Map<String, Schema.RecordTypeInfo>();
    recordTypesAsset = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName();
    Id assetRelatedObjectRecordTypeId = recordTypesAsset.get(
        STA_UtilsStatic.RECORDTYPE_ASSET_RELATED_OBJECT
      )
      .getRecordTypeId();
    Id assetGroupRecordTypeId = recordTypesAsset.get(
        STA_UtilsStatic.RECORDTYPE_ASSET_GROUP
      )
      .getRecordTypeId();

    Map<Id, Asset> assetNeedRelatedObject = checkRecordType(
      newMap,
      new List<Id>{ assetRelatedObjectRecordTypeId, assetGroupRecordTypeId }
    );
    assetNeedRelatedObject = checkExistingChild(
      assetNeedRelatedObject,
      assetRelatedObjectRecordTypeId
    );

    Map<Id, Id> assetIdToServiceProductId = new Map<Id, Id>();
    for (Asset oneAsset : assetNeedRelatedObject.values()) {
      assetIdToServiceProductId.put(oneAsset.Id, oneAsset.Product2Id);
    }

    //SELECT function
    Map<Id, SMC_GtlServiceProductAssociation__c> gtlAssociationLines = getGTLServiceAssociationFromSetId(
      assetIdToServiceProductId.values()
    );
    Map<Id, List<Id>> serviceProductIdToGtlAssociationId = new Map<Id, List<Id>>();
    for (
      SMC_GtlServiceProductAssociation__c gtlAssociation : gtlAssociationLines.values()
    ) {
      if (
        serviceProductIdToGtlAssociationId.containsKey(
          gtlAssociation.SMC_Service_Product__c
        )
      ) {
        serviceProductIdToGtlAssociationId.get(
            gtlAssociation.SMC_Service_Product__c
          )
          .add(gtlAssociation.Id);
      } else {
        serviceProductIdToGtlAssociationId.put(
          gtlAssociation.SMC_Service_Product__c,
          new List<Id>{ gtlAssociation.Id }
        );
      }
    }

    List<Asset> assetToInsert;
    if (serviceProductIdToGtlAssociationId.size() > 0) {
      assetToInsert = creationRelatedObject(
        assetNeedRelatedObject,
        assetRelatedObjectRecordTypeId,
        assetIdToServiceProductId,
        gtlAssociationLines,
        serviceProductIdToGtlAssociationId,
        assetToPreviousBomMap
      );
    }

    if (assetToInsert != null && assetToInsert.size() > 0) {
      try {
        insert assetToInsert;
        resultWrapperAssetForCreationRelatedObject.isSuccess = true;
      } catch (DMLException dmlException) {
        System.debug(LoggingLevel.INFO, 'ERROR INSERTION --> ' + dmlException);
        System.debug(
          LoggingLevel.INFO,
          'List to insert failed : ' + assetToInsert
        );
        resultWrapperAssetForCreationRelatedObject.errorOccur = true;
      }
    } else {
      System.debug(LoggingLevel.INFO, 'List to insert empty');
      resultWrapperAssetForCreationRelatedObject.errorOccur = true;
    }

    System.debug(
      LoggingLevel.INFO,
      '>>>>>> SMC_AP_ManageAsset : createAssetRelatedObject - END'
    );
    return resultWrapperAssetForCreationRelatedObject;
  }

  /**
   * @description : check asset record type
   * @author Vincent RECASENS (Modis) | 08/04/2020
   * @param newMap
   * @param assetRecordType
   * @return Map<Id, Asset>
   **/
  public static Map<Id, Asset> checkRecordType(
    Map<Id, Asset> newMap,
    List<Id> assetRecordType
  ) {
    Map<Id, Asset> assetWithGoodRecordType = new Map<Id, Asset>();
    for (Id assetId : newMap.keySet()) {
      if (!assetRecordType.contains(newMap.get(assetId).RecordTypeId)) {
        assetWithGoodRecordType.put(assetId, newMap.get(assetId));
        resultWrapperAssetForCreationRelatedObject.rigthRecordTypeAsset.add(
          newMap.get(assetId)
        );
      } else {
        resultWrapperAssetForCreationRelatedObject.badRecordTypeAsset.add(
          newMap.get(assetId)
        );
      }
    }
    return assetWithGoodRecordType;
  }

  /**
   * @description : check asset child exist
   * @author Vincent RECASENS (Modis) | 08/04/2020
   * @param newMap
   * @param assetRelatedObjectRecordTypeId
   * @return Map<Id, Asset>
   **/
  public static Map<Id, Asset> checkExistingChild(
    Map<Id, Asset> newMap,
    Id assetRelatedObjectRecordTypeId
  ) {
    //Mandatory for test
    Set<Id> assetIds = newMap.keySet();
    if (
      Test.isRunningTest() && resultWrapperAssetForCreationRelatedObject == null
    ) {
      resultWrapperAssetForCreationRelatedObject = new SMC_AC_CreateAssetRelatedObject_GTL.ResultWrapper();
    }

    //Get child asset
    Map<Id, Asset> assetNeedRelatedObject = new Map<Id, Asset>();
    List<Asset> assetRelatedObject = new List<Asset>();
    assetRelatedObject = [
      SELECT Id, RecordTypeId, ParentId
      FROM Asset
      WHERE
        ParentId = :assetIds
        AND RecordTypeId = :Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName()
          .get(STA_UtilsStatic.RECORDTYPE_ASSET_RELATED_OBJECT)
          .getRecordTypeId()
    ];

    //If there are childs asset
    if (assetRelatedObject.size() > 0) {
      List<Id> parentId = new List<Id>();
      for (Asset oneAsset : assetRelatedObject) {
        parentId.add(oneAsset.ParentId);
      }
      for (Id assetId : newMap.keySet()) {
        if (parentId.contains(assetId)) {
          resultWrapperAssetForCreationRelatedObject.badAsset.add(
            newMap.get(assetId)
          );
        } else {
          assetNeedRelatedObject.put(assetId, newMap.get(assetId));
          resultWrapperAssetForCreationRelatedObject.rigthAsset.add(
            newMap.get(assetId)
          );
        }
      }
    } else {
      return newMap;
    }
    return assetNeedRelatedObject;
  }

  /**
   * @description : get remplacement variation from SMC_replacementVariationByBA__mdt metadata
   * @author Vincent RECASENS (Modis) | 08/04/2020
   * @return List<SMC_replacementVariationByBA__mdt>
   **/
  public static List<SMC_replacementVariationByBA__mdt> getReplacementVariationMetadata() {
    return [
      SELECT
        Id,
        DeveloperName,
        SMC_DC_capacitor__c,
        SMC_AC_input_capacitor__c,
        SMC_AC_output_capacitor__c,
        SMC_FAN__c,
        SMC_Power_Supply__c
      FROM SMC_replacementVariationByBA__mdt
    ]; //There are not 200 elements in this custom metadata
  }

  /**
   * @description : get GTL association
   * @author Vincent RECASENS (Modis) | 08/04/2020
   * @param setId
   * @return Map<Id, SMC_GtlServiceProductAssociation__c>
   **/
  public static Map<Id, SMC_GtlServiceProductAssociation__c> getGTLServiceAssociationFromSetId(
    List<Id> setId
  ) {
    Map<Id, SMC_GtlServiceProductAssociation__c> mapGTLAsso = new Map<Id, SMC_GtlServiceProductAssociation__c>();
    for (SMC_GtlServiceProductAssociation__c oneAsso : [
      SELECT
        SMC_Logistic_Technical_Guide__c,
        SMC_Logistic_Technical_Guide__r.SMC_Spare_Part__c,
        SMC_Logistic_Technical_Guide__r.SMC_Spare_Part__r.ProductCode,
        SMC_Logistic_Technical_Guide__r.SMC_Spare_Part__r.SMC_Warranty_duration_month__c,
        SMC_Logistic_Technical_Guide__r.SMC_Spare_Part__r.Name,
        SMC_Logistic_Technical_Guide__r.SMC_Quantity__c,
        SMC_Logistic_Technical_Guide__r.SMC_Group__c,
        SMC_Logistic_Technical_Guide__r.SMC_Subset_GTL__c,
        SMC_Service_Product__c /* end of real query */,
        SMC_Logistic_Technical_Guide__r.SMC_Not_Real_LTG_Line__c,
        SMC_Logistic_Technical_Guide__r.SMC_Status_GTL__c,
        SMC_Logistic_Technical_Guide__r.SMC_ValidityDate__c,
        SMC_Logistic_Technical_Guide__r.SMC_Start_Date__c
      FROM SMC_GtlServiceProductAssociation__c
      WHERE SMC_Service_Product__c != null AND SMC_Service_Product__c IN :setId
    ]) {
      if (
        oneAsso.SMC_Logistic_Technical_Guide__r.SMC_Not_Real_LTG_Line__c &&
        oneAsso.SMC_Logistic_Technical_Guide__r.SMC_Status_GTL__c !=
        STA_UtilsStatic.PRODUCT_OBSOLETE &&
        (oneAsso.SMC_Logistic_Technical_Guide__r.SMC_ValidityDate__c == null ||
        oneAsso.SMC_Logistic_Technical_Guide__r.SMC_ValidityDate__c >=
        Date.today()) &&
        oneAsso.SMC_Logistic_Technical_Guide__r.SMC_Start_Date__c <=
        Date.today()
      ) {
        mapGTLAsso.put(oneAsso.Id, oneAsso);
      }
    }
    return mapGTLAsso;
  }

  /** 
  * @description : find next remplacement date
  There are 2 frequency to add to the NextReplacementDate on the new Asset : one on ServiceProduct and one on GTLLine
  * @author Vincent RECASENS (Modis) | 08/04/2020 
  * @param assetToInsert 
  * @param assetNameToServiceProductId 
  * @param serviceProductIdAssetNameToGTLGroup 
  * @param gtlGroupToReplacementFrenquency 
  * @return List<Asset> 
  **/
  public static List<Asset> findReplacementFrequencyOnProduct(
    List<Asset> assetToInsert,
    Map<String, Id> assetNameToServiceProductId,
    Map<String, String> serviceProductIdAssetNameToGTLGroup,
    Map<String, Double> gtlGroupToReplacementFrenquency
  ) {
    Map<Id, Product2> mapServiceProduct = new Map<Id, Product2>(
      [
        SELECT
          Id,
          SMC_AC_in_CAPA_Replacement_freq_years__c,
          SMC_AC_out_CAPA_Replacement_freq_years__c,
          SMC_DC_CAPA_Replacement_frequency_years__c,
          SMC_FAN_Replacement_freq_years__c,
          SMC_POWER_SUPPLY_Replacement_freq_years__c
        FROM Product2
        WHERE Id IN :assetNameToServiceProductId.values()
      ]
    );
    Map<String, String> groupFieldMap = new Map<String, String>{
      STA_UtilsStatic.AC_INPUT_CAPACITOR => 'SMC_AC_in_CAPA_Replacement_freq_years__c',
      STA_UtilsStatic.AC_OUTPUT_CAPACITOR => 'SMC_AC_out_CAPA_Replacement_freq_years__c',
      STA_UtilsStatic.DC_CAPACITOR => 'SMC_DC_CAPA_Replacement_frequency_years__c',
      STA_UtilsStatic.FAN => 'SMC_FAN_Replacement_freq_years__c',
      STA_UtilsStatic.POWER_SUPPLY => 'SMC_POWER_SUPPLY_Replacement_freq_years__c'
    };
    for (Asset oneAsset : assetToInsert) {
      Date baseDate = (oneAsset.smc_manufacturing_date__c != null
        ? oneAsset.smc_manufacturing_date__c
        : (oneAsset.InstallDate != null ? oneAsset.InstallDate : Date.today()));

      String gtlGroup;
      Decimal serviceProductFrequency;
      if (
        assetNameToServiceProductId != null &&
        assetNameToServiceProductId.get(oneAsset.Name) != null
      ) {
        if (
          serviceProductIdAssetNameToGTLGroup != null &&
          serviceProductIdAssetNameToGTLGroup.get(
            assetNameToServiceProductId.get(oneAsset.Name) +
            '|' +
            oneAsset.Name
          ) != null
        ) {
          gtlGroup = serviceProductIdAssetNameToGTLGroup.get(
            assetNameToServiceProductId.get(oneAsset.Name) +
            '|' +
            oneAsset.Name
          );
        }

        if (groupFieldMap.get(gtlGroup) != null) {
          serviceProductFrequency = mapServiceProduct.get(assetNameToServiceProductId.get(oneAsset.Name)).get(groupFieldMap.get(gtlGroup)) != null ? 
                                      (Decimal) mapServiceProduct.get(assetNameToServiceProductId.get(oneAsset.Name)).get(groupFieldMap.get(gtlGroup)) : 
                                      null;
        }
        if (
          gtlGroup != null &&
          gtlGroupToReplacementFrenquency != null &&
          gtlGroupToReplacementFrenquency.get(gtlGroup) != null
        ) {
          if (serviceProductFrequency != null) {
            oneAsset.SMC_Next_replacement_date__c = baseDate.addDays(-1).addYears(
              Math.round(
                serviceProductFrequency +
                (gtlGroupToReplacementFrenquency.get(gtlGroup) != null
                  ? gtlGroupToReplacementFrenquency.get(gtlGroup)
                  : 0.0)
              )
            );
            oneAsset.SMC_theoretical_next_replacement_date__c = baseDate.addDays(-1).addYears(
              Math.round(serviceProductFrequency)
            );
          }
        }
      }
      oneAsset.Name = oneAsset.Name.split('_')[0];
      //Default value when ReplacementField on product is null - Not effective for BATTERY
      if(gtlGroup != STA_UtilsStatic.BATTERY && 
         (oneAsset.SMC_Next_replacement_date__c == null || 
          oneAsset.SMC_Next_replacement_date__c < Date.today())){
        oneAsset.SMC_Next_replacement_date__c = baseDate.addDays(-1).addYears(1);
      }
      if(gtlGroup != STA_UtilsStatic.BATTERY && 
         (oneAsset.SMC_theoretical_next_replacement_date__c == null || 
         oneAsset.SMC_theoretical_next_replacement_date__c < Date.today())){
        oneAsset.SMC_theoretical_next_replacement_date__c = baseDate.addDays(-1).addYears(1);
      }
    }
    return assetToInsert;
  }

  /**
   * @description : create asset ServiceBOM from creationRelatedObject < trigger
   * @author Vincent RECASENS (Modis) | 08/04/2020
   * @param newMap
   * @param assetToPreviousBomMap
   * @return SMC_AC_CreateAssetRelatedObject_GTL.ResultWrapper
   **/
  public static List<Asset> creationRelatedObject(
    Map<Id, Asset> assetNeedRelatedObject,
    Id assetRelatedObjectRecordTypeId,
    Map<Id, Id> assetIdToServiceProductId,
    Map<Id, SMC_GtlServiceProductAssociation__c> gtlAssociationLines,
    Map<Id, List<Id>> serviceProductIdToGtlAssociationId,
    Map<id, previousBillOfMaterialDates> assetToPreviousBomMap
  ) {
    System.debug(
      LoggingLevel.INFO,
      '>>>>>> SMC_AP_ManageAsset.createAssetRelatedObject(assetNeedRelatedObject, assetRelatedObjectRecordTypeId, assetIdToServiceProductId, gtlAssociationLines, serviceProductIdToGtlAssociationId, assetToPreviousBomMap) - START'
    );

    //SELECT function
    List<SMC_replacementVariationByBA__mdt> nextReplacementDateList = getReplacementVariationMetadata();
    //Get FR ServiceOrg
    SMC_replacementVariationByBA__mdt frServiceOrg;
    for (
      SMC_replacementVariationByBA__mdt oneReplacement : nextReplacementDateList
    ) {
      if (oneReplacement.DeveloperName == 'FR') {
        frServiceOrg = oneReplacement;
      }
    }
    //Get generic account
    Account genericAccount;
    if (!Test.isRunningTest()) {
      genericAccount = (Account) Cache.Org.get(
        GenericAccount_SBOM.class,
        STA_UtilsStatic.GENERIC_ACCOUNT_NAME_SBOM
      );
    } else {
      try {
        genericAccount = [
          SELECT Id, Name
          FROM Account
          WHERE
            Name = :STA_UtilsStatic.GENERIC_ACCOUNT_NAME_SBOM
            AND RecordType.DeveloperName = :STA_UtilsStatic.RECORDTYPE_ACCOUNT_INTERNAL_DEVNAME
        ];
      } catch (Exception e) {
        System.debug(LoggingLevel.INFO, 'Generic account not present in base. Creation is working.');
        genericAccount = creteGenericAccount();
      }
    }

    //Populate list to insertion
    List<Asset> assetToInsert = new List<Asset>();
    Map<String, Asset> mapSparePartCodeToAssetToInsert;
    Map<String, Asset> mapSparePartCode_GroupToAssetToInsert;
    Map<String, Id> assetNameToServiceProductId = new Map<String, Id>();
    Map<String, String> mapServiceProductIdAssetNameToGTLGroup = new Map<String, String>();
    Map<String, Double> mapGTLGroupToAdditionalFrequency = new Map<String, Double>();
    for (Id oneAssetId : assetNeedRelatedObject.keySet()) {
      mapSparePartCode_GroupToAssetToInsert = new Map<String, Asset>();
      Asset theAsset = assetNeedRelatedObject.get(oneAssetId);
      if (
        serviceProductIdToGtlAssociationId.get(
          assetIdToServiceProductId.get(oneAssetId)
        ) != null
      ) {
        for (
          Id gtlAssociationId : serviceProductIdToGtlAssociationId.get(
            assetIdToServiceProductId.get(oneAssetId)
          )
        ) {
          SMC_GtlServiceProductAssociation__c oneGtlAssociation = gtlAssociationLines.get(
            gtlAssociationId
          );
          String productCode = oneGtlAssociation.SMC_Logistic_Technical_Guide__r.SMC_Spare_Part__r.ProductCode;
          String gtlGroup = oneGtlAssociation.SMC_Logistic_Technical_Guide__r.SMC_Group__c;
          if (
            !mapSparePartCode_GroupToAssetToInsert.containsKey(productCode + '_' + gtlGroup) 
            || (mapSparePartCode_GroupToAssetToInsert.containsKey(productCode + '_' + gtlGroup) && 
            mapSparePartCode_GroupToAssetToInsert.get(productCode + '_' + gtlGroup).SMC_Group_Type__c != gtlGroup)
          ) {

            Asset newAsset = new Asset();
            newAsset.RecordTypeId = assetRelatedObjectRecordTypeId;
            newAsset.ParentId = theAsset.Id;
            newAsset.AccountId = genericAccount.Id;
            newAsset.SMC_Group_Type__c = gtlGroup;
            newAsset.SMC_Subset__c = oneGtlAssociation.SMC_Logistic_Technical_Guide__r.SMC_Subset_GTL__c;
            newAsset.SMC_Parent_service_organisation__c = theAsset.SMC_Parent_service_organisation__c;
            newAsset.InstallDate = getDateFromAsset(
              theAsset,
              assetToPreviousBomMap,
              gtlGroup);
            newAsset.Name =
              productCode +
              ' - ' +
              oneGtlAssociation.SMC_Logistic_Technical_Guide__r.SMC_Spare_Part__r.Name + 
              '_' + 
              gtlGroup;
            newAsset.Product2Id = oneGtlAssociation.SMC_Logistic_Technical_Guide__r.SMC_Spare_Part__c;
            newAsset.Quantity = oneGtlAssociation.SMC_Logistic_Technical_Guide__r.SMC_Quantity__c;
            newAsset.SMC_Logistic_Technical_Guide__c = oneGtlAssociation.SMC_Logistic_Technical_Guide__c;
            newAsset.SMC_Component_Warranty_End_Date__c = oneGtlAssociation.SMC_Logistic_Technical_Guide__r.SMC_Spare_Part__r.SMC_Warranty_duration_month__c !=
              null
              ? newAsset.InstallDate.addMonths(
                  Math.round(
                    oneGtlAssociation.SMC_Logistic_Technical_Guide__r.SMC_Spare_Part__r.SMC_Warranty_duration_month__c
                  )
                ).addDays(-1)
              : null;
            assetNameToServiceProductId.put(
              newAsset.Name,
              assetIdToServiceProductId.get(oneAssetId)
            );
            mapServiceProductIdAssetNameToGTLGroup.put(
              (assetIdToServiceProductId.get(oneAssetId) +
              '|' +
              newAsset.Name),
              gtlGroup
            );

            Boolean parentServiceFound = false;
            for (
              SMC_replacementVariationByBA__mdt oneReplacement : nextReplacementDateList
            ) {
              if (
                theAsset.SMC_Parent_service_organisation__c ==
                oneReplacement.DeveloperName
              ) {
                parentServiceFound = true;
                if (
                  gtlGroup !=
                  null
                ) {
                  String groupTitle =
                    'SMC_' +
                    gtlGroup +
                    '__c';
                  if (
                    oneReplacement.getSobjectType()
                      .getDescribe()
                      .fields.getMap()
                      .keySet()
                      .contains(groupTitle.toLowerCase())
                  ) {
                    mapGTLGroupToAdditionalFrequency.put(
                      gtlGroup,
                      (Double) oneReplacement.get(groupTitle)
                    );
                  }
                  break;
                }
              }
            }

            //Set default value if null
            if (!parentServiceFound) {
              if (
                gtlGroup !=
                null
              ) {
                String groupTitle =
                  'SMC_' +
                  gtlGroup +
                  '__c';
                if (
                  frServiceOrg.getSobjectType()
                    .getDescribe()
                    .fields.getMap()
                    .keySet()
                    .contains(groupTitle.toLowerCase())
                ) {
                  mapGTLGroupToAdditionalFrequency.put(
                    gtlGroup,
                    (Double) frServiceOrg.get(groupTitle.toLowerCase())
                  );
                }
                else{
                  mapGTLGroupToAdditionalFrequency.put(
                    gtlGroup,
                    (Double) 0
                  );
                }
              }
            }
            mapSparePartCode_GroupToAssetToInsert.put(
              productCode + '_' + gtlGroup,
              newAsset
            );
          } else {
            mapSparePartCode_GroupToAssetToInsert.get(
                productCode + '_' + gtlGroup
              )
              .Quantity += oneGtlAssociation.SMC_Logistic_Technical_Guide__r.SMC_Quantity__c;
          }
        }
        assetToInsert.addAll(mapSparePartCode_GroupToAssetToInsert.values());
      }
    }
    assetToInsert = findReplacementFrequencyOnProduct(
      assetToInsert,
      assetNameToServiceProductId,
      mapServiceProductIdAssetNameToGTLGroup,
      mapGTLGroupToAdditionalFrequency
    );
    return assetToInsert;
  }

  /**
   * @description : get all dates
   * @author Vincent RECASENS (Modis) | 08/04/2020
   * @param theAsset
   * @param assetToPreviousBomMap
   * @param groupName
   * @return Date
   **/
  static Date getDateFromAsset(
    Asset theAsset,
    Map<id, previousBillOfMaterialDates> assetToPreviousBomMap,
    string groupName
  ) {
    Date baseDate = (theAsset.SMC_CommissioningDate__c != null
                     ? theAsset.SMC_CommissioningDate__c
                     : (theAsset.SMC_Shipping_date__c != null
                         ? theAsset.SMC_Shipping_date__c
                         : (theAsset.SMC_Manufacturing_date__c != null
                             ? theAsset.SMC_Manufacturing_date__c
                             : theAsset.CreatedDate.date())));
    if (
      assetToPreviousBomMap == null || 
      assetToPreviousBomMap.size() == 0 ||
      assetToPreviousBomMap.get(theAsset.Id) == null
    ) {
      return baseDate;
    } else {
      switch on groupName {
        when 'AC_INPUT_CAPACITOR' {
          return assetToPreviousBomMap.get(theAsset.Id) != null ? 
                  (assetToPreviousBomMap.get(theAsset.Id).acInputDate != null ? 
                   assetToPreviousBomMap.get(theAsset.Id).acInputDate : baseDate) :
                  baseDate;
        }
        when 'AC_OUTPUT_CAPACITOR' {
          return assetToPreviousBomMap.get(theAsset.Id) != null ? 
                  (assetToPreviousBomMap.get(theAsset.Id).acOutputDate != null ? 
                   assetToPreviousBomMap.get(theAsset.Id).acOutputDate : baseDate) :
                  baseDate;
        }
        when 'BATTERY' {
          return assetToPreviousBomMap.get(theAsset.Id) != null ? 
                  (assetToPreviousBomMap.get(theAsset.Id).batteryDate != null ? 
                   assetToPreviousBomMap.get(theAsset.Id).batteryDate : baseDate) :
                  baseDate;
        }
        when 'DC_CAPACITOR' {
          return assetToPreviousBomMap.get(theAsset.Id) != null ? 
                  (assetToPreviousBomMap.get(theAsset.Id).dcCapacitorDate != null ? 
                   assetToPreviousBomMap.get(theAsset.Id).dcCapacitorDate : baseDate) :
                  baseDate;
        }
        when 'FAN' {
          return assetToPreviousBomMap.get(theAsset.Id) != null ? 
                  (assetToPreviousBomMap.get(theAsset.Id).fanDate != null ? 
                   assetToPreviousBomMap.get(theAsset.Id).fanDate : baseDate) :
                  baseDate;
        }
        when 'POWER_SUPPLY' {
          return assetToPreviousBomMap.get(theAsset.Id) != null ? 
                  (assetToPreviousBomMap.get(theAsset.Id).powerSupply != null ? 
                   assetToPreviousBomMap.get(theAsset.Id).powerSupply : baseDate) :
                  baseDate;
        }
        when else {
          return baseDate;
        }
      }
    }
  }

  /** 
   * @description : create asset ServiceBOM from datatable (when product is changed)
   * @author Vincent RECASENS (Modis) | 08/04/2020
   * @param theAsset
   * @param assetRelatedObjectRecordTypeId
   * @param gtlAssociationLines
   * @return Boolean
   **/
  public static Boolean creationRelatedObject(
    Asset theAsset,
    Id assetRelatedObjectRecordTypeId,
    List<SMC_AC_CreateRecordFromDatatable.WrapperDataTableForAsset> gtlAssociationLines
  ) {
    System.debug(
      LoggingLevel.INFO,
      '>>>>>> SMC_AP_ManageAssetcreateAssetRelatedObject(theAsset, assetRelatedObjectRecordTypeId, gtlAssociationLines) - START'
    );
    //SELECT function
    List<SMC_replacementVariationByBA__mdt> nextReplacementDateList = getReplacementVariationMetadata();
    //Get FR ServiceOrg
    SMC_replacementVariationByBA__mdt frServiceOrg;
    for (
      SMC_replacementVariationByBA__mdt oneReplacement : nextReplacementDateList
    ) {
      if (oneReplacement.DeveloperName == 'FR') {
        frServiceOrg = oneReplacement;
      }
    }
    //Get generic account
    Account genericAccount;
    if (!Test.isRunningTest()) {
      genericAccount = (Account) Cache.Org.get(
        GenericAccount_SBOM.class,
        STA_UtilsStatic.GENERIC_ACCOUNT_NAME_SBOM
      );
    } else {
      try {
        genericAccount = [
          SELECT Id, Name
          FROM Account
          WHERE
            Name = :STA_UtilsStatic.GENERIC_ACCOUNT_NAME_SBOM
            AND RecordType.DeveloperName = :STA_UtilsStatic.RECORDTYPE_ACCOUNT_INTERNAL_DEVNAME
        ];
      } catch (Exception e) {
        genericAccount = creteGenericAccount();
      }
    }

    //Get old SBOM to set install date
    Map<String, Date> mapAssetGroup_InstallDateSBOM = new Map<String, Date>();
    Map<String, Asset> mapSparePartCode_GroupToAssetToUpdate = new Map<String, Asset>();
    for(Asset oneAssetSBOM : [SELECT Id, SMC_Group_Type__c, SMC_Subset__c, InstallDate, Product2.ProductCode, Quantity FROM Asset WHERE ParentId = :theAsset.Id]){
      mapAssetGroup_InstallDateSBOM.put(oneAssetSBOM.SMC_Group_Type__c, oneAssetSBOM.InstallDate);
      mapSparePartCode_GroupToAssetToUpdate.put(oneAssetSBOM.Product2.ProductCode + '_' + oneAssetSBOM.SMC_Group_Type__c, oneAssetSBOM);
    }

    //Populate list to insertion
    List<Asset> assetToInsert = new List<Asset>();
    Map<String, Asset> mapSparePartCode_GroupToAssetToInsert;
    Map<String, Id> assetNameToServiceProductId = new Map<String, Id>();
    Map<String, String> mapServiceProductIdAssetNameToGTLGroup = new Map<String, String>();
    Map<String, Double> mapGTLGroupToAdditionalFrequency = new Map<String, Double>();
    Set<String> serviceProductIdGtlGroupAlreadyAdded = new Set<String>();
    Map<Id, Asset> mapAssetToUpdate = new Map<Id, Asset>();
    for (
      SMC_AC_CreateRecordFromDatatable.WrapperDataTableForAsset oneGtlAssociation : gtlAssociationLines
    ) {
      mapSparePartCode_GroupToAssetToInsert = new Map<String, Asset>();
      String productCode = oneGtlAssociation.serviceProductCode;
      String gtlGroup = oneGtlAssociation.gtlGroup;
      if(mapSparePartCode_GroupToAssetToUpdate.get(productCode + '_' + gtlGroup) != null){
        if(mapAssetToUpdate.get(mapSparePartCode_GroupToAssetToUpdate.get(productCode + '_' + gtlGroup).Id) == null){
          mapAssetToUpdate.put(
            mapSparePartCode_GroupToAssetToUpdate.get(productCode + '_' + gtlGroup).Id, 
            mapSparePartCode_GroupToAssetToUpdate.get(productCode + '_' + gtlGroup));
        }
        mapAssetToUpdate.get(mapSparePartCode_GroupToAssetToUpdate.get(productCode + '_' + gtlGroup).Id).Quantity += oneGtlAssociation.quantity;
      }
      else if (
        !mapSparePartCode_GroupToAssetToInsert.containsKey(productCode + '_' + gtlGroup) 
        // || (mapSparePartCode_GroupToAssetToInsert.containsKey(productCode + '_' + gtlGroup) && 
        // mapSparePartCode_GroupToAssetToInsert.get(productCode + '_' + gtlGroup).SMC_Group_Type__c != gtlGroup)
      ) {
        
        Asset newAsset = new Asset();
        newAsset.RecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName()
          .get(STA_UtilsStatic.RECORDTYPE_ASSET_RELATED_OBJECT)
          .getRecordTypeId();
        newAsset.ParentId = theAsset.Id;
        newAsset.AccountId = genericAccount.Id;
        newAsset.SMC_Group_Type__c = oneGtlAssociation.gtlGroup;
        newAsset.SMC_Subset__c = oneGtlAssociation.gtlSubset;
        newAsset.SMC_Parent_service_organisation__c = theAsset.SMC_Parent_service_organisation__c;
        newAsset.InstallDate =  mapAssetGroup_InstallDateSBOM.get(newAsset.SMC_Group_Type__c) != null 
                                  ? mapAssetGroup_InstallDateSBOM.get(newAsset.SMC_Group_Type__c) 
                                  : (theAsset.SMC_CommissioningDate__c != null
                                     ? theAsset.SMC_CommissioningDate__c
                                     : (theAsset.SMC_Shipping_date__c != null
                                         ? theAsset.SMC_Shipping_date__c
                                         : (theAsset.SMC_Manufacturing_date__c != null
                                             ? theAsset.SMC_Manufacturing_date__c
                                             : theAsset.CreatedDate.date())));
        newAsset.SMC_Component_Warranty_End_Date__c = oneGtlAssociation.sparePartWarrantyAddMonth !=
        null
        ? newAsset.InstallDate.addMonths(
            Math.round(
              oneGtlAssociation.sparePartWarrantyAddMonth
            )
          ).addDays(-1)
        : newAsset.InstallDate.addMonths(12).addDays(-1);
        newAsset.Name =
          oneGtlAssociation.serviceProductCode +
          ' - ' +
          oneGtlAssociation.serviceProductName;
        newAsset.Product2Id = oneGtlAssociation.id;
        newAsset.Quantity = oneGtlAssociation.quantity;
        newAsset.SMC_Logistic_Technical_Guide__c = oneGtlAssociation.gtlId;

        assetNameToServiceProductId.put(newAsset.Name, theAsset.Product2Id);
        mapServiceProductIdAssetNameToGTLGroup.put(
          (theAsset.Product2Id +
          '|' +
          newAsset.Name),
          oneGtlAssociation.gtlGroup
        );

        Boolean parentServiceFound = false;
        for (
          SMC_replacementVariationByBA__mdt oneReplacement : nextReplacementDateList
        ) {
          if (
            theAsset.SMC_Parent_service_organisation__c ==
            oneReplacement.DeveloperName
          ) {
            parentServiceFound = true;
            if (oneGtlAssociation.gtlGroup != null) {
              String groupTitle = 'SMC_' + oneGtlAssociation.gtlGroup + '__c';
              if (
                oneReplacement.getSobjectType()
                  .getDescribe()
                  .fields.getMap()
                  .keySet()
                  .contains(groupTitle)
              ) {
                mapGTLGroupToAdditionalFrequency.put(
                  oneGtlAssociation.gtlGroup,
                  (Double) oneReplacement.get(groupTitle)
                );
              }
              break;
            }
          }
        }  

        //Set default value if null
        if (!parentServiceFound) {
          if (
            oneGtlAssociation.gtlGroup !=
            null
          ) {
            String groupTitle =
              'SMC_' +
              oneGtlAssociation.gtlGroup +
              '__c';
            if (
              frServiceOrg.getSobjectType()
                .getDescribe()
                .fields.getMap()
                .keySet()
                .contains(groupTitle.toLowerCase())
            ) {
              mapGTLGroupToAdditionalFrequency.put(
                oneGtlAssociation.gtlGroup,
                (Double) frServiceOrg.get(groupTitle.toLowerCase())
              );
            }
            else{
              mapGTLGroupToAdditionalFrequency.put(
                oneGtlAssociation.gtlGroup,
                (Double) 0
              );
            }
          }
        }

        mapSparePartCode_GroupToAssetToInsert.put(
          productCode + '_' + gtlGroup,
          newAsset
        );
        assetToInsert.addAll(mapSparePartCode_GroupToAssetToInsert.values());
      } else {
        mapSparePartCode_GroupToAssetToInsert.get(
            productCode + '_' + gtlGroup
          )
          .Quantity += oneGtlAssociation.quantity;
        assetToInsert.addAll(mapSparePartCode_GroupToAssetToInsert.values());
      }
    }

    //Insert
    if(assetToInsert.size() > 0){
      assetToInsert = findReplacementFrequencyOnProduct(
        assetToInsert,
        assetNameToServiceProductId,
        mapServiceProductIdAssetNameToGTLGroup,
        mapGTLGroupToAdditionalFrequency
      );

      try {
        insert assetToInsert;
      } catch (Exception e) {
        System.debug(LoggingLevel.INFO, 'ERROR : ' + e);
        return false;
      }
    }

    //Update
    if(mapAssetToUpdate.size() > 0){
      try {
        update mapAssetToUpdate.values();
      } catch (Exception e) {
        System.debug(LoggingLevel.INFO, 'ERROR : ' + e);
        return false;
      }
    }
    return true;
  }

  /**
   * @description : manage parent service organisation
   * @author Vincent RECASENS (Modis) | 08/04/2020
   * @param newList
   * @param oldmap
   **/
  public static void manageParentServiceOrganisation(
    list<Asset> newList,
    map<id, Asset> oldmap
  ) {
    System.debug(
      LoggingLevel.INFO,
      '## >>> SMC_AP_ManageAsset manageParentServiceOrganisation: START<<< ##'
    );

    map<id, asset> updatedRootIdMap = new Map<id, asset>();
    for (Asset ass : newList) {
      if (
        ass.id == ass.RootAssetId &&
        ass.SMC_Parent_service_organisation__c !=
        oldMap.get(ass.id).SMC_Parent_service_organisation__c
      ) {
        updatedRootIdMap.put(ass.id, ass);
      }
    }
    if (updatedRootIdMap.size() > 0) {
      list<Asset> changedAsset = [
        SELECT id, RootAssetId
        FROM asset
        WHERE
          RootAssetId IN :updatedRootIdMap.keyset()
          AND id NOT IN :updatedRootIdMap.keyset()
      ];
      for (Asset ass : changedAsset) {
        ass.SMC_Parent_service_organisation__c = updatedRootIdMap.get(
            ass.RootAssetId
          )
          .SMC_Parent_service_organisation__c;
      }
      update changedAsset;
    }

    System.debug(
      LoggingLevel.INFO,
      '## >>> SMC_AP_ManageAsset manageParentServiceOrganisation: END<<< ##'
    );
  }

  /**
   * @description : change product from datatble (function "Change Product")
   * @author Vincent RECASENS (Modis) | 08/04/2020
   * @param newMap
   * @param oldMap
   **/
  public static void productIsChanged(
    Map<Id, Asset> newMap,
    Map<Id, Asset> oldMap
  ) {
    System.debug(
      LoggingLevel.INFO,
      '## >>> SMC_AP_ManageAsset productIsChanged: START<<< ##'
    );
    List<Id> parentAssetIds = new List<Id>();
    for (Asset oneAsset : newMap.values()) {
      Asset oldAsset = oldMap.get(oneAsset.Id);
      if (
        oneAsset.Product2Id != oldAsset.Product2Id &&
        oldAsset.Product2Id != null
      ) {
        parentAssetIds.add(oneAsset.Id);
      }
    }

    Map<id, previousBillOfMaterialDates> assetToPreviousBomMap = new Map<id, previousBillOfMaterialDates>();
    if (parentAssetIds.size() > 0) {
      Map<String, Schema.RecordTypeInfo> recordTypesAsset = new Map<String, Schema.RecordTypeInfo>();
      recordTypesAsset = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName();
      Map<Id, Asset> childBomAssetList = new Map<Id, Asset>(
        [
          SELECT
            Id,
            SMC_Logistic_Technical_Guide__r.Smc_group__c,
            installDate,
            SMC_CommissioningDate__c,
            ParentId
          FROM Asset
          WHERE
            ParentId IN :parentAssetIds
            AND RecordTypeId = :recordTypesAsset.get(
                STA_UtilsStatic.RECORDTYPE_ASSET_RELATED_OBJECT
              )
              .getRecordTypeId()
        ]
      );
      for (Asset ass : childBomAssetList.values()) {
        if(assetToPreviousBomMap.get(ass.ParentId) == null)
          assetToPreviousBomMap.put(ass.ParentId, new previousBillOfMaterialDates());

        switch on ass.SMC_Logistic_Technical_Guide__r.Smc_group__c {
          when 'AC_INPUT_CAPACITOR' {
            assetToPreviousBomMap.get(ass.ParentId).acInputDate = ass.installDate;
          }
          when 'AC_OUTPUT_CAPACITOR' {
            assetToPreviousBomMap.get(ass.ParentId).acOutputDate = ass.installDate;
          }
          when 'BATTERY' {
            assetToPreviousBomMap.get(ass.ParentId).acOutputDate = ass.installDate;
          }
          when 'DC_CAPACITOR' {
            assetToPreviousBomMap.get(ass.ParentId).dcCapacitorDate = ass.installDate;
          }
          when 'FAN' {
            assetToPreviousBomMap.get(ass.ParentId).fanDate = ass.installDate;
          }
          when 'POWER_SUPPLY' {
            assetToPreviousBomMap.get(ass.ParentId).powerSupply = ass.installDate;
          }
        }
      }
      delete childBomAssetList.values();
    }

    createAssetRelatedObject(newMap, assetToPreviousBomMap);

    System.debug(
      LoggingLevel.INFO,
      '## >>> SMC_AP_ManageAsset productIsChanged: END<<< ##'
    );
  }

  /**
   * @description : update ServiceBOM
   * @author Vincent RECASENS (Modis) | 08/04/2020
   * @param newMap
   * @param oldMap
   **/
  public static void updateServiceBOM(
    Map<Id, Asset> newMap,
    Map<Id, Asset> oldMap
  ) {
    System.debug(
      LoggingLevel.INFO,
      '## >>> SMC_AP_ManageAsset updateServiceBOM: START<<< ##'
    );
    //Search GTL for assets and build a map to sort them
    Id recordTypeServiceBOM = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName()
      .get(STA_UtilsStatic.RECORDTYPE_ASSET_RELATED_OBJECT)
      .getRecordTypeId();
    Map<Id, Id> mapGTLIdToAssetId = new Map<Id, Id>();
    Map<Id, Id> assetIdToParentId = new Map<Id, Id>();
    for (Asset oneAsset : newMap.values()) {
      if (
        oldMap.get(oneAsset.Id) != null &&
        oneAsset.InstallDate != null &&
        oneAsset.InstallDate != oldMap.get(oneAsset.Id).InstallDate &&
        oneAsset.RecordTypeId == recordTypeServiceBOM && 
        oneAsset.SMC_Logistic_Technical_Guide__c != null
      ) {
        assetIdToParentId.put(oneAsset.Id, oneAsset.ParentId);
        mapGTLIdToAssetId.put(
          oneAsset.SMC_Logistic_Technical_Guide__c,
          oneAsset.Id
        );
      }
    }

    if (assetIdToParentId == null || assetIdToParentId.size() == 0) {
      return;
    }

    //Variable for determinate frequency
    Map<String, Id> assetNameToServiceProductId = new Map<String, Id>();
    //Mapping AssetId to GTL
    Map<Id, SMC_GTL__c> mapAssetIdToGTLGroup = new Map<Id, SMC_GTL__c>();
    for (SMC_GTL__c oneGTL : [
      SELECT Id, SMC_Group__c
      FROM SMC_GTL__c
      WHERE Id IN :mapGTLIdToAssetId.keySet()
    ]) {
      mapAssetIdToGTLGroup.put(mapGTLIdToAssetId.get(oneGTL.Id), oneGTL);
    }

    Map<Id, Id> assetIdToServiceProductId = new Map<Id, Id>();
    Map<Id, Asset> mapParentAsset = new Map<Id, Asset>(
      [
        SELECT Id, Product2Id, SMC_Parent_service_organisation__c
        FROM Asset
        WHERE Id IN :assetIdToParentId.values()
      ]
    );

    for (Id oneAssetId : newMap.keySet()) {
      if (
        newMap.get(oneAssetId).ParentId != null &&
        mapParentAsset.get(newMap.get(oneAssetId).ParentId) != null
      ) {
        assetIdToServiceProductId.put(
          oneAssetId,
          mapParentAsset.get(newMap.get(oneAssetId).ParentId).Product2Id
        );
      }
    }

    //Get date variation
    List<SMC_replacementVariationByBA__mdt> nextReplacementDateList = getReplacementVariationMetadata();
    //Get FR ServiceOrg
    SMC_replacementVariationByBA__mdt frServiceOrg;
    for (
      SMC_replacementVariationByBA__mdt oneReplacement : nextReplacementDateList
    ) {
      if (oneReplacement.DeveloperName == 'FR') {
        frServiceOrg = oneReplacement;
      }
    }
    Map<String, String> mapServiceProductIdAssetNameToGTLGroup = new Map<String, String>();
    Map<String, Double> mapGTLGroupToAdditionalFrequency = new Map<String, Double>();
    //Setting dates
    for (Id oneAssetId : mapGTLIdToAssetId.values()) {
      if (
        assetIdToServiceProductId != null &&
        assetIdToServiceProductId.get(oneAssetId) != null
      ) {
        assetNameToServiceProductId.put(
          newMap.get(oneAssetId).Name,
          assetIdToServiceProductId.get(oneAssetId)
        );
        mapServiceProductIdAssetNameToGTLGroup.put(
          (assetIdToServiceProductId.get(oneAssetId) +
          '|' +
          newMap.get(oneAssetId).Name),
          mapAssetIdToGTLGroup.get(oneAssetId).SMC_Group__c
        );
      }

      Boolean parentServiceFound = false;
      for (
        SMC_replacementVariationByBA__mdt oneReplacement : nextReplacementDateList
      ) {
        if (
          newMap.get(oneAssetId).SMC_Parent_service_organisation__c ==
          oneReplacement.DeveloperName
        ) {
          parentServiceFound = true;
          if (mapAssetIdToGTLGroup.get(oneAssetId).SMC_Group__c != null) {
            String groupTitle =
              'SMC_' +
              mapAssetIdToGTLGroup.get(oneAssetId).SMC_Group__c +
              '__c';
            if (
              oneReplacement.getSobjectType()
                .getDescribe()
                .fields.getMap()
                .keySet()
                .contains(groupTitle.toLowerCase())
            ) {
              mapGTLGroupToAdditionalFrequency.put(
                mapAssetIdToGTLGroup.get(oneAssetId).SMC_Group__c,
                (Double) oneReplacement.get(groupTitle.toLowerCase())
              );
            }
            break;
          }
        }
      }

      //Set default value if null
      if (!parentServiceFound) {
        if (mapAssetIdToGTLGroup.get(oneAssetId).SMC_Group__c != null) {
          String groupTitle =
            'SMC_' +
            mapAssetIdToGTLGroup.get(oneAssetId).SMC_Group__c +
            '__c';
          if (
            frServiceOrg.getSobjectType()
              .getDescribe()
              .fields.getMap()
              .keySet()
              .contains(groupTitle.toLowerCase())
          ) {
            mapGTLGroupToAdditionalFrequency.put(
              mapAssetIdToGTLGroup.get(oneAssetId).SMC_Group__c,
              (Double) frServiceOrg.get(groupTitle.toLowerCase())
            );
          }
          else{
            mapGTLGroupToAdditionalFrequency.put(
              mapAssetIdToGTLGroup.get(oneAssetId).SMC_Group__c,
              (Double) 0
            );
          }
        }
      }
    }

    findReplacementFrequencyOnProduct(
      newMap.values(),
      assetNameToServiceProductId,
      mapServiceProductIdAssetNameToGTLGroup,
      mapGTLGroupToAdditionalFrequency
    );

    System.debug(
      LoggingLevel.INFO,
      '## >>> SMC_AP_ManageAsset updateServiceBOM: END<<< ##'
    );
  }

  class previousBillOfMaterialDates {
    date acInputDate;
    date acOutputDate;
    date dcCapacitorDate;
    date fanDate;
    date batteryDate;
    date powerSupply;

    previousBillOfMaterialDates() {}

    previousBillOfMaterialDates(Date assetDate) {
      this.acInputDate = assetDate;
      this.acOutputDate = assetDate;
      this.dcCapacitorDate = assetDate;
      this.fanDate = assetDate;
      this.batteryDate = assetDate;
      this.powerSupply = assetDate;
    }
  }
  // private static Date min(Date d1, Date d2) {
  //   if (d1 != null && d2 != null)
  //     return d1 < d2 ? d1 : d2;
  //   else if (d1 != null)
  //     return d1;
  //   else if (d2 != null)
  //     return d2;
  //   else
  //     return null;
  // }

  /**
   * @description : set the asset's warranty
   * @author Vincent RECASENS (Modis) | 08/04/2020
   * @param newList
   * @param oldMap
   **/
  public static void fillAssetWarranty(
    list<Asset> newList,
    map<Id, Asset> oldMap
  ) {
    Map<String, Schema.RecordTypeInfo> recordTypesAsset = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName();
    Id assetUnitRecordTypeId = recordTypesAsset.get(
        STA_UtilsStatic.RECORDTYPE_ASSET
      )
      .getRecordTypeId();
    Id assetRelatedObjectRecordTypeId = recordTypesAsset.get(
        STA_UtilsStatic.RECORDTYPE_ASSET_RELATED_OBJECT
      )
      .getRecordTypeId();
    list<Asset> assetToUpdate = new List<Asset>();
    Map<Id, List<Asset>> parentId_bomToUpdate = new Map<Id, List<Asset>>();
    list<Asset> bomToUpdate = new List<Asset>();
    list<id> parentAssetId = new List<Id>();
    list<id> serviceProductIdList = new List<Id>();
    for (Asset ass : newList) {
      //Single Asset
      if (ass.RecordTypeId == assetUnitRecordTypeId) {
        //INSERT
        //Si WarrantyEndDate vide : calcul
        if (oldMap == null && ass.SMC_CommissioningDate__c != null) {
          assetToUpdate.add(ass);
          serviceProductIdList.add(ass.Product2Id);
        } else if (oldMap != null && oldMap.get(ass.Id) != null) {
          //UPDATE
          //Si ServiceProduct modifié : calcul
          //Si CommissioningDate modifiée : calcul
          if (ass.SMC_CommissioningDate__c != null &&
              oldMap.get(ass.Id).SMC_CommissioningDate__c !=
              ass.SMC_CommissioningDate__c && ass.Product2Id != null){
            assetToUpdate.add(ass);
            serviceProductIdList.add(ass.Product2Id);
          }
          else if(ass.Product2Id != null && 
                  oldMap.get(ass.Id).Product2Id != ass.Product2Id && 
                  ass.SMC_CommissioningDate__c != null){
            assetToUpdate.add(ass);
            serviceProductIdList.add(ass.Product2Id);
          }
        }
      }
      //SBOM
      if(ass.RecordTypeId == assetRelatedObjectRecordTypeId && 
         ass.InstallDate == null){
        ass.SMC_Component_Warranty_End_Date__c = null;
      }
      else if(ass.RecordTypeId == assetRelatedObjectRecordTypeId &&
              ass.InstallDate != null &&
              (oldMap == null || (oldMap != null && 
              oldMap.get(ass.Id).InstallDate != ass.InstallDate)) && 
              ass.ParentId != null){
        parentAssetId.add(ass.ParentId);
        bomToUpdate.add(ass);
      }
    }

    if(serviceProductIdList.size() > 0){
      Map<Id, Product2> productMap = new Map<Id, product2>(
        [
          SELECT id, SMC_Warranty_duration_month__c
          FROM product2
          WHERE id IN :serviceProductIdList
        ]
      );
      for (Asset ass : assetToUpdate) {
        if (productMap.get(ass.Product2Id) != null) {
          ass.SMC_Asset_Warranty_End_Date__c = productMap.get(ass.Product2Id)
              .SMC_Warranty_duration_month__c != null
            ? (ass.SMC_CommissioningDate__c != null
                ? ass.SMC_CommissioningDate__c.addMonths(
                    Math.round(
                      productMap.get(ass.Product2Id)
                        .SMC_Warranty_duration_month__c
                    )
                  )
                : ass.CreatedDate != null
                    ? ass.CreatedDate.date()
                        .addMonths(
                          Math.round(
                            productMap.get(ass.Product2Id)
                              .SMC_Warranty_duration_month__c
                          )
                        )
                    : Date.today()
                        .addMonths(
                          Math.round(
                            productMap.get(ass.Product2Id)
                              .SMC_Warranty_duration_month__c
                          )
                        ))
            : null;
            if(ass.SMC_Asset_Warranty_End_Date__c != null){
              ass.SMC_Asset_Warranty_End_Date__c = ass.SMC_Asset_Warranty_End_Date__c.addDays(-1);
            }
        }
      }
      for (Asset bom : bomToUpdate) {
        bom.SMC_Component_Warranty_End_Date__c = (productMap.get(bom.Product2Id)
            .SMC_Warranty_duration_month__c != null &&
          bom.installDate != null)
          ? bom.installDate.addMonths(
              Math.round(
                productMap.get(bom.Product2Id).SMC_Warranty_duration_month__c
              )
            ).addDays(-1)
          : null;
      }
    }
    else if(parentAssetId.size() > 0){
      Map<Id, Asset> mapParentAsset = new Map<Id, Asset>([SELECT Id, Product2.SMC_Warranty_duration_month__c FROM Asset WHERE Id IN :parentAssetId]);
      for (Asset bom : bomToUpdate) {
        if(mapParentAsset.get(bom.ParentId) != null){
          bom.SMC_Component_Warranty_End_Date__c = (mapParentAsset.get(bom.ParentId)
            .Product2.SMC_Warranty_duration_month__c != null &&
            bom.InstallDate != null)
            ? bom.installDate.addMonths(
                Math.round(
                  mapParentAsset.get(bom.ParentId).Product2.SMC_Warranty_duration_month__c
                )
              ).addDays(-1)
            : null;
        }
      }
    }
  }

  /**
   * @description check if current user has the right to delete asset record type
   * @author emmanuel.bernier@modis.com | 18/06/2020
   * @param newList
   * @return void
   **/
  public static void preventDelete(List<Asset> newList) {
    Map<String, Schema.RecordTypeInfo> recordTypesAsset = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName();
    Id assetRecordTypeId = recordTypesAsset.get(
        STA_UtilsStatic.RECORDTYPE_ASSET
      )
      .getRecordTypeId();
    Boolean canDelete = System.FeatureManagement.checkPermission(
      STA_UtilsStatic.DELETE_ASSET_PERMISSION
    );
    if (!canDelete) {
      for (Asset curAss : newList) {
        if (curAss.RecordTypeId == assetRecordTypeId) {
          curAss.addError(Label.SMC_FSL_Cant_Delete_Asset);
        }
      }
    }
  }

  /**
   * @description decomission related WorkOrderLine
   * @author emmanuel.bernier@modis.com | 23/06/2020
   * @param newList
   * @param oldMap
   * @return void
   **/
  public static void manageDecomission(
    list<Asset> newList,
    map<Id, Asset> oldMap
  ) {
    Set<Id> decomissionedAssetIdSet = new Set<Id>();
    for (Asset ass : newList) {
      if (
        ass.Status == STA_UtilsStatic.PICKLIST_ASSET_DECOMISSION &&
        ass.Status != oldMap.get(ass.Id).Status
      ) {
        decomissionedAssetIdSet.add(ass.id);
      }
    }
    if (decomissionedAssetIdSet.size() > 0) {
      SMC_AP_ManageWorkOrderLineItem.cancelWoliOnDecomissionnedAsset(
        decomissionedAssetIdSet,
        new Set<Id>()
      );
    }
  }

  /**
   * @description : manage Asset accordgin to woli type
   * @author Vincent RECASENS (Modis) | 11-27-2020
   * @param mapAssets
   **/
  public static void manageAssetFromWoliCompleted(
    Map<String, List<Asset>> mapAssets,
    Map<Id, WorkOrderLineItem> mapAssetIdToWoli
  ) {
    List<Asset> assetsToUpdate = new List<Asset>();
    List<String> assetStatusForCommissionning = new List<String>{
      STA_UtilsStatic.STATUS_WAREHOUSE,
      STA_UtilsStatic.STATUS_SHIPPED,
      STA_UtilsStatic.STATUS_INSTALLED
    };

    //WOLI Commionning
    if (mapAssets.get(STA_UtilsStatic.WT_TYPE_COMMISSIONING) != null) {
      for (
        Asset oneAsset : mapAssets.get(STA_UtilsStatic.WT_TYPE_COMMISSIONING)
      ) {
        //Asset Status : Warehouse / Shipped / Installed
        if (assetStatusForCommissionning.contains(oneAsset.Status)) {
          oneAsset.Status = STA_UtilsStatic.ACTIVE;
          oneAsset.InstallDate = Date.today();
          oneAsset.SMC_CommissioningDate__c = Date.today();
        }
        //Asset Status : De-commissionning
        if (oneAsset.Status == STA_UtilsStatic.PICKLIST_ASSET_DECOMISSION) {
          oneAsset.Status = STA_UtilsStatic.ACTIVE;
          oneAsset.InstallDate = Date.newInstance(
            mapAssetIdToWoli.get(oneAsset.Id).EndDate.year(),
            mapAssetIdToWoli.get(oneAsset.Id).EndDate.month(),
            mapAssetIdToWoli.get(oneAsset.Id).EndDate.day()
          );
          oneAsset.SMC_CommissioningDate__c = Date.newInstance(
            mapAssetIdToWoli.get(oneAsset.Id).EndDate.year(),
            mapAssetIdToWoli.get(oneAsset.Id).EndDate.month(),
            mapAssetIdToWoli.get(oneAsset.Id).EndDate.day()
          );
          oneAsset.AccountId = mapAssetIdToWoli.get(oneAsset.Id)
            .WorkOrder.AccountId;
          oneAsset.LocationId = mapAssetIdToWoli.get(oneAsset.Id)
            .WorkOrder.LocationId;
          oneAsset.SMC_Asset_Location__c = mapAssetIdToWoli.get(oneAsset.Id)
            .LocationId;
          oneAsset.SMC_Decomissionning_type__c = null;
          oneAsset.SMC_User_Decomissioner__c = null;
          // updateAsset.SMC_NotCommissionBySocomec__c = true;
          // assetsToUpdate.add(oneAsset);
        }
        assetsToUpdate.add(oneAsset);
      }
    }

    //Update Asset
    if (assetsToUpdate.size() > 0) {
      update assetsToUpdate;
    }
  }
  /**
   * @description : manage Asset accordgin to woli type
   * @author Tanya SIBONI (Modis) | 06-24-2021
   * @param mapAssets
   **/
  public static void manageAssetFromWoliCompletedInstalledType(
    Map<String, List<Asset>> mapAssets,
    Map<Id, WorkOrderLineItem> mapAssetIdToWoli
  ) {
    List<Asset> assetsToUpdate = new List<Asset>();

    Date startDate = Date.today();
    for (WorkOrderLineItem woli : mapAssetIdToWoli.values()) {
      if (woli.StartDate == null) {
        startDate = (woli.WorkOrder.StartDate != null ? date.newinstance(woli.WorkOrder.StartDate.year(), woli.WorkOrder.StartDate.month(), woli.WorkOrder.StartDate.day()) : date.today());
      } else {
        startDate = date.newinstance(woli.StartDate.year(), woli.StartDate.month(), woli.StartDate.day());
      }
    }

    //WOLI Installation
    if (mapAssets.get(STA_UtilsStatic.WT_TYPE_INSTALLATION) != null) {
      for (Asset oneAsset : mapAssets.get(STA_UtilsStatic.WT_TYPE_INSTALLATION)) {
        oneAsset.Status = STA_UtilsStatic.STATUS_INSTALLED;
        oneAsset.InstallDate = startDate;
        assetsToUpdate.add(oneAsset);
      }
    }

    //Update Asset
    if (assetsToUpdate.size() > 0) {
      update assetsToUpdate;
    }
  }

  /**
   * @description : fill ParentServiceOrganization
   * @author Vincent RECASENS (Modis) | 11-27-2020
   * @param newList
   **/
  public static void fillParentServiceOrganization(List<Asset> newList) {
    Map<String, Id> mapAssetNumberToAccountId = new Map<String, Id>();
    for (Asset oneAsset : newList) {
      if (oneAsset.AccountId != null) {
        mapAssetNumberToAccountId.put(oneAsset.Name, oneAsset.AccountId);
      }
    }

    if (mapAssetNumberToAccountId.size() > 0) {
      Map<Id, Account> mapAccount = new Map<Id, Account>(
        [
          SELECT Id, SMC_Service_Organization__c
          FROM Account
          WHERE Id IN :mapAssetNumberToAccountId.values()
        ]
      );
      if (mapAccount.size() > 0) {
        for (Asset oneAsset : newList) {
          oneAsset.SMC_Parent_service_organisation__c = mapAccount.get(
              mapAssetNumberToAccountId.get(oneAsset.Name)
            )
            .SMC_Service_Organization__c;
        }
      }
    }
  }

  /*
   * All ServiceBOM are linked to a generic account, named #GENERIC# SERVICE BOM. Here, we get (or create if necessary) this generic account
   *
   */
  public class GenericAccount_SBOM implements Cache.CacheBuilder {
    public Object doLoad(String genericAccountName) {
      Account genericAccount;
      try {
        genericAccount = [
          SELECT Id, Name
          FROM Account
          WHERE
            Name = :genericAccountName
            AND RecordType.DeveloperName = :STA_UtilsStatic.RECORDTYPE_ACCOUNT_INTERNAL_DEVNAME
        ];
      } catch (Exception e) {
        System.debug(LoggingLevel.INFO, 'Generic Account not exist.');
        // /!\ Parallel tests failed
        //genericAccount = creteGenericAccount();
      }
      return genericAccount;
    }
  }

  /**
   * @description : crete and add to the cache the new generic account
   * @author Vincent RECASENS (Modis) | 08/04/2020
   * @return Account
   **/
  public static Account creteGenericAccount() {
    //Bypass VR
    String currentVR = '';
    User currentUser = [
      SELECT Id, Bypass_Validation_Rule__c, Bypass_All_Validation_Rules__c
      FROM User
      WHERE Id = :UserInfo.getUserId()
    ];
    if (
      !currentUser.Bypass_All_Validation_Rules__c &&
      !currentUser.Bypass_Validation_Rule__c.contains(
        STA_UtilsStatic.GENERIC_ACCOUNT_SBOM_BYPASS
      )
    ) {
      if (currentUser.Bypass_Validation_Rule__c != null) {
        currentVR = currentUser.Bypass_Validation_Rule__c;
        currentUser.Bypass_Validation_Rule__c =
          currentUser.Bypass_Validation_Rule__c +
          ';' +
          STA_UtilsStatic.GENERIC_ACCOUNT_SBOM_BYPASS;
      } else {
        currentUser.Bypass_Validation_Rule__c = STA_UtilsStatic.GENERIC_ACCOUNT_SBOM_BYPASS;
      }
      update currentUser;
    }

    //Create generic Account
    Account genereicAccountSBOM = new Account();
    genereicAccountSBOM.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
      .get(STA_UtilsStatic.RECORDTYPE_ACCOUNT_INTERNAL_DEVNAME)
      .getRecordTypeId();
    genereicAccountSBOM.Name = STA_UtilsStatic.GENERIC_ACCOUNT_NAME_SBOM;
    genereicAccountSBOM.BillingCountryCode = STA_UtilsStatic.PSO_FR; // = 'FR'
    genereicAccountSBOM.SMC_Category__c = Account.SMC_Category__c.getDescribe()
        .getPicklistValues()[0]
      .getValue();
    genereicAccountSBOM.isGenericOppAccount__c = true;
    genereicAccountSBOM.OwnerId = [
      SELECT Id
      FROM User
      WHERE Name = :STA_UtilsStatic.TECHNICAL_USER_SOC1
    ]
    .Id;
    insert genereicAccountSBOM;

    //Remove Bypass
    currentUser.Bypass_Validation_Rule__c = currentVR;
    update currentUser;

    return genereicAccountSBOM;
  }


  /**
   * @description : fill parent asset on single asset after the creation of a group level
   * @author Tanya SIBONI (Modis) | 07/01/2021
   * @param newList
   **/
  public static void fillParentAssetFieldOnSingleAsset(Map<Id, Asset> newMap) {
    System.debug('------------START: fillParentAssetFieldOnSingleAsset-------------------');
    Map<Id, Id> mapAssetParentId_SingleAssetId = new Map<Id, Id>();
    String recordTypeName = '';
    Id recordTypeIdGroup = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName().get(STA_UtilsStatic.RECORDTYPE_ASSET_GROUP).getRecordTypeId();

    for (Id oneId : newMap.keySet()) {
      Id recordTypeId = newMap.get(oneId).RecordTypeId;
      recordTypeName = Schema.SObjectType.Asset.getRecordTypeInfosById().get(recordTypeId).getName();
      if (recordTypeId == recordTypeIdGroup) {
        mapAssetParentId_SingleAssetId.put(oneId, newMap.get(oneId).ParentId);
      }
      // if (recordTypeName == STA_UtilsStatic.RECORDTYPE_NAME_ASSET_GROUP) {
      //   mapAssetParentId_SingleAssetId.put(oneId, newMap.get(oneId).ParentId);
      // }
    }

    Map<Id, Asset> mapGroupAssetToUpdate = new Map<Id, Asset>();
    for (Asset groupAssetToUpdate : [SELECT Id, ParentId, Parent.RecordTypeId FROM Asset WHERE Id IN :mapAssetParentId_SingleAssetId.keySet()]) {
      groupAssetToUpdate.ParentId = null;

      mapGroupAssetToUpdate.put(groupAssetToUpdate.Id, groupAssetToUpdate);
    }

    //remove parentId from parent Asset
    if (mapGroupAssetToUpdate.size() > 0) {
      update mapGroupAssetToUpdate.values();
    }

    Map<Id, Asset> mapAssetToUpdate = new Map<Id, Asset>();
    for (Asset assetToUpdate : [SELECT Id, ParentId FROM Asset WHERE Id IN :mapAssetParentId_SingleAssetId.values()]) {
      assetToUpdate.ParentId = (new list<Id>(mapAssetParentId_SingleAssetId.keySet()) )[0];
      mapAssetToUpdate.put(assetToUpdate.Id, assetToUpdate);
    }

    //update asset with parentId
    if (mapAssetToUpdate.size() > 0) {
      update mapAssetToUpdate.values();
    }
  }

  /**
  * @description 
  * @author Vincent RECASENS (Modis) | 01-13-2022 
  * @param newMap 
  * @param oldMap 
  **/
  public static void checkSBOMDates(Map<Id, Asset> newMap, Map<Id, Asset> oldMap){
    Map<Id, Set<String>> mapParentAssetId_GroupSet = new Map<Id, Set<String>>();
    Map<String, Date> mapParentAssetIdGroup_Install = new Map<String, Date>();
    for(Id oneId : newMap.keySet()){
      Asset newAsset = newMap.get(oneId);
      Asset oldAsset = oldMap.get(oneId);
      if(newAsset.ParentId != null && newAsset.InstallDate != oldAsset.InstallDate){
        if(mapParentAssetId_GroupSet.get(newAsset.ParentId) == null){
          mapParentAssetId_GroupSet.put(newAsset.ParentId, new Set<String>());
        }
        mapParentAssetId_GroupSet.get(newAsset.ParentId).add(newAsset.SMC_Group_Type__c);
        mapParentAssetIdGroup_Install.put(newAsset.ParentId + '_' + newAsset.SMC_Group_Type__c, newAsset.InstallDate);
      }
    }

    if(mapParentAssetId_GroupSet.size() > 0){
      List<Asset> assetToUpdate = new List<Asset>();
      for(Asset oneAsset : [SELECT Id, ParentId, InstallDate, SMC_Group_Type__c FROM Asset WHERE ParentId = :mapParentAssetId_GroupSet.keySet()]){
        if(mapParentAssetId_GroupSet.get(oneAsset.ParentId).contains(oneAsset.SMC_Group_Type__c)){
          oneAsset.InstallDate = mapParentAssetIdGroup_Install.get(oneAsset.ParentId + '_' + oneAsset.SMC_Group_Type__c);
          assetToUpdate.add(oneAsset);
        }
      }
      if(assetToUpdate.size() > 0){
        update assetToUpdate;
      }
    }
  }


  /**
  * @description : Fill the Account of Service BOM Asset before the insertion for the user SOC3
  * @author Denis PHAM (Modis) | 28-04-2022 
  * @param newList 
  **/
  public static void fillAccountSBOM(List<Asset> newList) {

    //Get the Record for SBOM Asset to apply treatment on Asset Service BOM only
    Id recordTypeServiceBOM = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName()
    .get(STA_UtilsStatic.RECORDTYPE_ASSET_RELATED_OBJECT)
    .getRecordTypeId();

    //Create or Get the generic account to populate the Account field on the Asset
    Account genericAccount;
    if (!Test.isRunningTest()) {
      genericAccount = (Account) Cache.Org.get(
        GenericAccount_SBOM.class,
        STA_UtilsStatic.GENERIC_ACCOUNT_NAME_SBOM
      );
    } else {
      try {
        genericAccount = [
          SELECT Id, Name
          FROM Account
          WHERE
            Name = :STA_UtilsStatic.GENERIC_ACCOUNT_NAME_SBOM
            AND RecordType.DeveloperName = :STA_UtilsStatic.RECORDTYPE_ACCOUNT_INTERNAL_DEVNAME
        ];
      } catch (Exception e) {
        System.debug(LoggingLevel.INFO, 'Generic account not present in base. Creation is working.');
        genericAccount = creteGenericAccount();
      }
    }

    for (Asset oneAsset : newList) {
      if(oneAsset.RecordTypeId == recordTypeServiceBOM ){
        if (oneAsset.AccountId == null) {
          oneAsset.AccountId = genericAccount.Id;
        }
      }
    }
     
  }

  /**
  * @description : Fill the Theorical next replacement date of Service BOM Asset after the insertion, for the user SOC3
  * @author Denis PHAM (Modis) | 28-04-2022 
  * @param newMap 
  **/
  public static void fillDateSBOM(Map<Id, Asset> newMap) {

    //Get the Record for SBOM Asset to apply treatment on Asset Service BOM only
    Id recordTypeServiceBOM = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName()
    .get(STA_UtilsStatic.RECORDTYPE_ASSET_RELATED_OBJECT)
    .getRecordTypeId();
    
    //Initialize variables for the function to determine the Theoretical Next Replacement Date
    Map<String, Id> assetNameToServiceProductId = new Map<String, Id>();
    Map<String, String> mapServiceProductIdAssetNameToGTLGroup = new Map<String, String>();
    Map<String, Double> mapGTLGroupToAdditionalFrequency = new Map<String, Double>();
    
    //If the RT is SBOM, we fill our MAP
    for (Asset oneAsset : newMap.values()) {
      if(oneAsset.RecordTypeId == recordTypeServiceBOM ){
        assetNameToServiceProductId.put(oneAsset.Name, oneAsset.Parent.Product2Id);
        mapServiceProductIdAssetNameToGTLGroup.put(oneAsset.Parent.Product2Id + '|' + oneAsset.Name , oneAsset.SMC_Group_Type__c);
      }
    }
    
    //If our MAP are filled, we get "Replacement Date" information to get the Replacement Frequency
    if(!assetNameToServiceProductId.isEmpty() && !mapServiceProductIdAssetNameToGTLGroup.isEmpty()){
      //Get date variation
      List<SMC_replacementVariationByBA__mdt> nextReplacementDateList = getReplacementVariationMetadata();
      //Get FR ServiceOrg
      SMC_replacementVariationByBA__mdt frServiceOrg;
      for (
        SMC_replacementVariationByBA__mdt oneReplacement : nextReplacementDateList
      ) {
        if (oneReplacement.DeveloperName == 'FR') {
          frServiceOrg = oneReplacement;
        }
      }

      //Setting dates
      for (Asset oneAsset : newMap.values()) {
        Boolean parentServiceFound = false;
        for (
          SMC_replacementVariationByBA__mdt oneReplacement : nextReplacementDateList
        ) {
          if (
            oneAsset.SMC_Parent_service_organisation__c ==
            oneReplacement.DeveloperName
          ) {
            parentServiceFound = true;
            if (oneAsset.SMC_Group_Type__c != null) {
              String groupTitle =
                'SMC_' +
                oneAsset.SMC_Group_Type__c +
                '__c';
              if (
                oneReplacement.getSobjectType()
                  .getDescribe()
                  .fields.getMap()
                  .keySet()
                  .contains(groupTitle.toLowerCase())
              ) {
                mapGTLGroupToAdditionalFrequency.put(
                  oneAsset.SMC_Group_Type__c,
                  (Double) oneReplacement.get(groupTitle.toLowerCase())
                );
              }
              break;
            }
          }
        }

        //Set default value if null
        if (!parentServiceFound) {
          if (oneAsset.SMC_Group_Type__c != null) {
            String groupTitle =
              'SMC_' +
              oneAsset.SMC_Group_Type__c +
              '__c';
            if (
              frServiceOrg.getSobjectType()
                .getDescribe()
                .fields.getMap()
                .keySet()
                .contains(groupTitle.toLowerCase())
            ) {
              mapGTLGroupToAdditionalFrequency.put(
                oneAsset.SMC_Group_Type__c,
                (Double) frServiceOrg.get(groupTitle.toLowerCase())
              );
            }
            else{
              mapGTLGroupToAdditionalFrequency.put(
                oneAsset.SMC_Group_Type__c,
                (Double) 0
              );
            }
          }
        }
      }

      List<Asset> assetToUpdate = [SELECT Id, Name, SMC_theoretical_next_replacement_date__c, SMC_Manufacturing_date__c, InstallDate, SMC_Next_replacement_date__c from Asset WHERE Id IN :newMap.keyset()];

      if(!mapGTLGroupToAdditionalFrequency.isEmpty()){
        assetToUpdate = findReplacementFrequencyOnProduct(
          assetToUpdate,
          assetNameToServiceProductId,
          mapServiceProductIdAssetNameToGTLGroup,
          mapGTLGroupToAdditionalFrequency
        );
      }

      try {
        update assetToUpdate;
      } catch (Exception e) {
        System.debug(LoggingLevel.INFO, 'ERROR : ' + e);
      }
    }
  }

}