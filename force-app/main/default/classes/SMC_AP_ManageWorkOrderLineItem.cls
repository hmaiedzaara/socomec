/**
 * @File Name          : SMC_AP_ManageWorkOrderLineItem.cls
 * @Description        :
 * @Author             : Vincent RECASENS (Modis)
 * @Group              :
 * @Last Modified By   : Vincent RECASENS (Modis)
 * @Last Modified On   : 04-09-2021
 * @Modification Log   :
 * Ver       Date            Author      		              Modification
 * 1.0       ??/11/2019      Emmanuel BERNIER (Modis)     Initial Version
 * 2.0       30/05/2022      Denis PHAM (Modis)           Update method checkServiceProductOnAssetAndWorkType
 **/

public with sharing class SMC_AP_ManageWorkOrderLineItem {
  /**
   * @description : prevent cancel status if work order is link to a product or a labor
   * @author Vincent RECASENS (Modis) | 08/04/2020
   * @param oldMap
   * @param newMap
   **/
  public static void preventCancel(
    map<id, WorkOrderLineItem> oldMap,
    map<id, WorkOrderLineItem> newMap
  ) {
    map<id, WorkOrderLineItem> canceledWoliMap = new Map<id, WorkOrderLineItem>();
    for (WorkOrderLineItem woli : newMap.values()) {
      if (
        (woli.SMC_Sub_status__c == STA_UtilsStatic.WOLI_CANCELED) &&
        woli.SMC_Sub_status__c != oldMap.get(woli.id).SMC_Sub_status__c
      ) {
        canceledWoliMap.put(woli.id, woli);
      }
    }
    preventCancelDelete(canceledWoliMap);
  }

  /**
   * @description : prevent cancel status if work order is link to a product or a labor
   * @author Vincent RECASENS (Modis) | 08/04/2020
   * @param oldMap
   * @param newMap
   **/
  public static Boolean preventCancelDelete(
    map<id, WorkOrderLineItem> canceledWoliMap
  ) {
    set<Id> workOrderWithConsumedProduct = new Set<Id>();
    for (ProductRequired consumed : [
      SELECT id, ParentRecordId
      FROM ProductRequired
      WHERE
        ParentRecordId IN :canceledWoliMap.keyset()
        AND SMC_Quantity_Consumed__c > 0
    ]) {
      workOrderWithConsumedProduct.add(consumed.ParentRecordId);
    }
    for (WorkOrderLineItem woli : canceledWoliMap.values()) {
      if (woli.SMC_Labor_time_in_hours__c > 0) {
        woli.addError(Label.SMC_FSL_Cant_Cancel_With_Labor);
        return false;
      }
      if (workOrderWithConsumedProduct.contains(woli.Id)) {
        woli.addError(Label.SMC_FSL_Cant_Cancel_With_Product);
        return false;
      }
    }
    return true;
  }

  /**
   * @description : prevent complete status if work order is link to a product not consumed (from Trigger)
   * @author Emmanuel Bernier (Modis) | 08/04/2020
   * @param oldMap
   * @param newMap
   **/
  public static void preventComplete(
    map<id, WorkOrderLineItem> oldMap,
    map<id, WorkOrderLineItem> newMap
  ) {
    map<id, WorkOrderLineItem> completedWoliMap = new Map<id, WorkOrderLineItem>();
    for (WorkOrderLineItem woli : newMap.values()) {
      if (
        woli.SMC_Sub_status__c == STA_UtilsStatic.WOLI_COMPLETED &&
        woli.SMC_Sub_status__c != oldMap.get(woli.id).SMC_Sub_status__c
      ) {
        completedWoliMap.put(woli.id, woli);
      }
    }
    map<Id, Id> workOrderWithoutConsumedProduct = new Map<Id, Id>();
    list<ProductRequired> prodreqList = [
      SELECT Id, ParentRecordId, SMC_Quantity_Consumed__c, QuantityRequired
      FROM ProductRequired
      WHERE ParentRecordId IN :completedWoliMap.keyset()
    ];
    for (ProductRequired consumed : prodreqList) {
      if (consumed.SMC_Quantity_Consumed__c == null) {
        workOrderWithoutConsumedProduct.put(
          consumed.ParentRecordId,
          consumed.ParentRecordId
        );
      }
    }
    for (WorkOrderLineItem woli : completedWoliMap.values()) {
      if (workOrderWithoutConsumedProduct.get(woli.Id) != null) {
        woli.addError(
          System.Label.SMC_FSL_Cant_complete_without_consumed_product
        );
      }
    }
  }

  /**
  * @description : update WorkOrder to completed if all their woli are Completed 
  **/
  public static void passWOStatusToCompleted(
    map<id, WorkOrderLineItem> oldMap,
    map<id, WorkOrderLineItem> newMap
  ) {
    
    // Check status change between newMap and oldMap, if changed stock WorkOrderId
    map<id, id> statusChangedWOLI = new Map<id, id>();
    map<id, List<WorkOrderLineItem>> mapWoId_ListWOLI = new Map<id, List<WorkOrderLineItem>>();
    for (WorkOrderLineItem woli : newMap.values()) {
      if (
        woli.Status == STA_UtilsStatic.WOLI_COMPLETED_MAIN_STATUS &&
        woli.Status != oldMap.get(woli.id).Status
      ) {
        statusChangedWOLI.put(woli.id, woli.WorkOrderId);
        if(mapWoId_ListWOLI.get(woli.WorkOrderId) != null){
          mapWoId_ListWOLI.get(woli.WorkOrderId).add(woli);
        }
        else{
          mapWoId_ListWOLI.put(woli.WorkOrderId, new List<WorkOrderLineItem>{woli});
        }
      }
    } //request all WOLI with the same WorkOrderId than those that were changed
    List<WorkOrderLineItem> allWOLI = new List<WorkOrderLineItem>();
    try {
      allWOLI = [SELECT Id,Status, SMC_Sub_status__c, WorkOrderId FROM WorkOrderLineItem WHERE WorkOrderId IN: statusChangedWOLI.values()];
    } catch (Exception e) {
      System.debug('The following exception has occurred: ' + e.getMessage());
    }
    
    Map<Id, List<WorkOrderLineItem>> newMapWoId_ListWOLI = new Map<Id, List<WorkOrderLineItem>>();
    for (Id workOrderIdWOLI : mapWoId_ListWOLI.keyset()) {
      for (WorkOrderLineItem woli : allWOLI) {
        if(newMapWoId_ListWOLI.get(woli.WorkOrderId) != null){
          newMapWoId_ListWOLI.get(woli.WorkOrderId).add(woli);
        }
        else{
          newMapWoId_ListWOLI.put(woli.WorkOrderId, new List<WorkOrderLineItem>{woli});
        }
        
      }
    }

    //Check if all WOLI status from a WO are Completed
    List<Id> WorkOrderLIIdToUpdateToComplete = new List<Id>();
    List<Id> WorkOrderLIIdToUpdateToInProgress = new List<Id>();

    Boolean allWOLIstatusComplete = true;
    Boolean atLeastOneWOLIComplete = false;
    Boolean subStatusAborted = false;
    for (Id idWO : newMapWoId_ListWOLI.keySet()) {
      allWOLIstatusComplete = true;
      atLeastOneWOLIComplete = false;
      subStatusAborted = false;
      for (WorkOrderLineITem oneWOLI : newMapWoId_ListWOLI.get(idWO)) {
        if (oneWOLI.Status != STA_UtilsStatic.WOLI_COMPLETED_MAIN_STATUS) {
          allWOLIstatusComplete = false;
        }
        if (oneWOLI.Status == STA_UtilsStatic.WOLI_COMPLETED_MAIN_STATUS) {
          atLeastOneWOLIComplete = true;
        }
        if (oneWOLI.SMC_Sub_status__c == STA_UtilsStatic.WOLI_ABORTED) {
          subStatusAborted = true;
        }

      }
      if (allWOLIstatusComplete && !subStatusAborted) {
        WorkOrderLIIdToUpdateToComplete.add(idWO);
      } else if (atLeastOneWOLIComplete || subStatusAborted) {
        WorkOrderLIIdToUpdateToInProgress.add(idWO);
      }
    }

    if (WorkOrderLIIdToUpdateToComplete.size() == 0 && WorkOrderLIIdToUpdateToInProgress.size() == 0) {
      return;
    }

    //if all WOLI have a status = Completed, update WorkOrder Status to Completed
    List<WorkOrder> workOrder = [SELECT Id, Status, SMC_Sub_status__c FROM WorkOrder WHERE Id IN: WorkOrderLIIdToUpdateToComplete OR Id IN: WorkOrderLIIdToUpdateToInProgress];
    
    for (WorkOrder wo : workOrder) {
      if (WorkOrderLIIdToUpdateToComplete.contains(wo.Id)) {
        wo.Status = STA_UtilsStatic.COMPLETED;
        wo.SMC_Sub_Status__c = STA_UtilsStatic.COMPLETED_ALL_CAPS;
      }
      if (WorkOrderLIIdToUpdateToInProgress.contains(wo.Id)) {
        wo.Status = STA_UtilsStatic.WO_IN_PROGRESS;
        System.debug('IN PROGRESS status--->' + wo.Status );

      }
    }

    
    try {
      update workOrder;
    } catch (Exception e) {
      System.debug('The following exception has occurred: ' + e.getMessage());
      SMC_UTIL_Methods_Batch.createErrorLog(
      new List<Exception>{ e },
      'Work Order Line Item - passWOStatusToCompleted',
      STA_UtilsStatic.PICKLIST_LOGS_PROCESS_TYPE_DML,
      'Error : ' + e.getMessage(),
      null,
      new List<String>{ UserInfo.getUsername() });
    }
    
  }



  /**
   * @description : update Asset for completed woli Commissionning or Decommissionning
   * @author Vincent RECASENS (Modis) | 11-27-2020
   * @param completedWoliMap
   **/
  public static void manageAssetFromWoliCompleted(
    Map<Id, WorkOrderLineItem> oldMap,
    Map<Id, WorkOrderLineItem> newMap
  ) {
    // Map<String, List<Asset>> mapAssets = new Map<String, List<Asset>>();
    Map<String, List<Asset>> mapAssets = new Map<String, List<Asset>>();
    Map<Id, WorkOrderLineItem> mapAssetIdToWoli = new Map<Id, WorkOrderLineItem>();
    for (WorkOrderLineItem oneWoli : [
      SELECT
        Id,
        Status,
        EndDate,
        LocationId,
        WorkType.SMC_Type__c,
        WorkOrder.AccountId,
        WorkOrder.LocationId,
        AssetId,
        Asset.AccountId,
        Asset.LocationId,
        Asset.SMC_Asset_Location__c,
        Asset.Status,
        Asset.InstallDate,
        Asset.SMC_CommissioningDate__c,
        Asset.SMC_Decomissionning_type__c,
        Asset.SMC_User_Decomissioner__c,
        Asset.SMC_NotCommissionBySocomec__c
      FROM WorkOrderLineItem
      WHERE Id IN :newMap.keySet()
    ]) {
      //Check Status "Completed"
      if (
        newMap.get(oneWoli.Id).Status != oldMap.get(oneWoli.Id).Status &&
        newMap.get(oneWoli.Id).Status ==
        STA_UtilsStatic.WOLI_COMPLETED_MAIN_STATUS &&
        newMap.get(oneWoli.Id).SMC_Sub_Status__c ==
        STA_UtilsStatic.WOLI_COMPLETED &&
        newMap.get(oneWoli.Id).EndDate != null
      ) {
        //WT Commissionning
        if (
          oneWoli.WorkType.SMC_Type__c == STA_UtilsStatic.WT_TYPE_COMMISSIONING
        ) {
          //Check list exist
          if (mapAssets.get(STA_UtilsStatic.WT_TYPE_COMMISSIONING) == null) {
            mapAssets.put(
              STA_UtilsStatic.WT_TYPE_COMMISSIONING,
              new List<Asset>()
            );
          }
          mapAssets.get(STA_UtilsStatic.WT_TYPE_COMMISSIONING)
            .add(
              new Asset(
                Id = oneWoli.AssetId,
                AccountId = oneWoli.Asset.AccountId,
                LocationId = oneWoli.Asset.LocationId,
                Status = oneWoli.Asset.Status,
                InstallDate = oneWoli.Asset.InstallDate,
                SMC_CommissioningDate__c = oneWoli.Asset.SMC_CommissioningDate__c,
                SMC_Decomissionning_type__c = oneWoli.Asset.SMC_Decomissionning_type__c,
                SMC_User_Decomissioner__c = oneWoli.Asset.SMC_User_Decomissioner__c,
                SMC_NotCommissionBySocomec__c = oneWoli.Asset.SMC_NotCommissionBySocomec__c
              )
            );
        }
        mapAssetIdToWoli.put(oneWoli.AssetId, oneWoli);
      }
    }

    if (mapAssets.size() > 0) {
      SMC_AP_ManageAsset.manageAssetFromWoliCompleted(
        mapAssets,
        mapAssetIdToWoli
      );
    }
  }
  /**
   * @description : update Asset for completed woli Type Installation
   * @author Tanya SIBONI (Modis) | 06-23-2021
   * @param completedWoliMap
   **/
  public static void manageAssetFromWoliCompletedInstalationType(
    Map<Id, WorkOrderLineItem> oldMap,
    Map<Id, WorkOrderLineItem> newMap
  ) {
    // Map<String, List<Asset>> mapAssets = new Map<String, List<Asset>>();
    Map<String, List<Asset>> mapAssets = new Map<String, List<Asset>>();
    Map<Id, WorkOrderLineItem> mapAssetIdToWoli = new Map<Id, WorkOrderLineItem>();
    for (WorkOrderLineItem oneWoli : [
      SELECT
      Id,
      Status,
      StartDate,	
      EndDate,
      LocationId,
      WorkType.SMC_Type__c,
      WorkOrder.AccountId,
      WorkOrder.LocationId,
      AssetId,
      Asset.AccountId,
      Asset.LocationId,
      Asset.SMC_Asset_Location__c,
      Asset.Status,
      Asset.InstallDate
      FROM WorkOrderLineItem
      WHERE Id IN :newMap.keySet()
    ]) {
      //Check Status "Completed"
      if (
        newMap.get(oneWoli.Id).Status != oldMap.get(oneWoli.Id).Status &&
        newMap.get(oneWoli.Id).Status == STA_UtilsStatic.WOLI_COMPLETED_MAIN_STATUS &&
        newMap.get(oneWoli.Id).SMC_Sub_Status__c == STA_UtilsStatic.WOLI_COMPLETED 
      ) {
        //WT Installation
        if (
          oneWoli.WorkType.SMC_Type__c == STA_UtilsStatic.WT_TYPE_INSTALLATION
        ) { 
          //Check list exist
          if (mapAssets.get(STA_UtilsStatic.WT_TYPE_INSTALLATION) == null) {

            mapAssets.put(
              STA_UtilsStatic.WT_TYPE_INSTALLATION,
              new List<Asset>()
            );
          }
          mapAssets.get(STA_UtilsStatic.WT_TYPE_INSTALLATION)
            .add(
              new Asset(
                Id = oneWoli.AssetId,
                AccountId = oneWoli.Asset.AccountId,
                LocationId = oneWoli.Asset.LocationId,
                Status = oneWoli.Asset.Status,
                InstallDate = oneWoli.Asset.InstallDate
              )
            );
        }
        mapAssetIdToWoli.put(oneWoli.AssetId, oneWoli);
      }
    }

    if (mapAssets.size() > 0) {
      SMC_AP_ManageAsset.manageAssetFromWoliCompletedInstalledType(
        mapAssets,
        mapAssetIdToWoli
      );
    }
  }

  /**
   * @description : addcreate product reuqired for the work order line
   * @author Vincent RECASENS (Modis) | 08/04/2020
   * @param oldMap
   * @param newMap
   **
  public static void addRequiredPartForReplacement(
    Map<Id, WorkOrderLineItem> newMap
  ) {
    List<ProductRequired> prodReqList = new List<ProductRequired>();
    Map<Id, string> woliWotyMap = new Map<Id, string>();
    Map<Id, list<Id>> woliAssetMap = new Map<Id, list<Id>>();
    for (WorkOrderLineItem woli : [
      SELECT id, assetId, WorkType.SMC_type__c
      FROM WorkOrderLineItem
      WHERE
        id IN :newMap.keySet()
        AND WorkTypeId != null
        AND WorkType.SMC_type__c != null
    ]) {
      if (
        woli.AssetId != null &&
        woli.WorkType.SMC_type__c.startsWith('REPLACEMENT - ')
      ) {
        woliWotyMap.put(
          woli.id,
          woli.WorkType.SMC_type__c.removeStart('REPLACEMENT - ')
        );
        if (woliAssetMap.get(woli.AssetId) == null) {
          woliAssetMap.put(woli.AssetId, new List<Id>());
        }
        woliAssetMap.get(woli.AssetId).add(woli.id);
      }
    }

    for (Asset ass : [
      SELECT
        id,
        (
          SELECT
            id,
            SMC_Logistic_Technical_Guide__c,
            SMC_Logistic_Technical_Guide__r.SMC_Group__c,
            SMC_Logistic_Technical_Guide__r.SMC_New_Spare_Part__c,
            Product2Id,
            SMC_Group_Type__c,
            quantity
          FROM ChildAssets
        )
      FROM Asset
      WHERE id IN :woliAssetMap.keyset()
    ]) {
      for (Id woliid : woliAssetMap.get(ass.id)) {
        String currGroup = woliWotyMap.get(woliid).replace(' ', '_');
        for (Asset ass2 : ass.ChildAssets) {
          if (ass2.SMC_Group_Type__c == currGroup) {
            prodReqList.add(
              new ProductRequired(
                ParentRecordId = woliid,
                Product2Id = ass2.Product2Id,
                QuantityRequired = ass2.Quantity,
                SMC_Technical_Logistic_Guide__c = (ass2.SMC_Logistic_Technical_Guide__c !=
                  null
                  ? ass2.SMC_Logistic_Technical_Guide__c
                  : null)
              )
            );
          }
        }
      }
    }
    if (prodReqList.size() > 0) {
      insert prodReqList;
    }
  }
*/

  /**
   * @description : test if duration is filled
   * @author emmanuel bernier (Modis) | 16/04/2020
   * @param newlist
   **/
  public static void testRequiredTime(List<WorkOrderLineItem> newList) {
    for (WorkOrderLineItem woli : newList) {
      if (woli.Duration == null || woli.DurationType == null) {
        woli.addError(Label.SMC_FSL_cant_insert_without_duration);
      }
    }
  }

  /**
   * @description : close line related to decomissioned asset
   * @author emmanuel bernier (Modis) | 16/04/2020
   * @param newlist
   **/
  public static void handleDecomissionningLineClose(
    List<WorkOrderLineItem> newList,
    Map<Id, WorkOrderLineItem> oldMap
  ) {
    set<id> workTypeIdSet = new Set<Id>();
    List<WorkOrderLineItem> closedWoli = new List<WorkOrderLineItem>();
    for (WorkOrderLineItem woli : newList) {
      if (
        woli.SMC_Sub_status__c == STA_UtilsStatic.WOLI_COMPLETED &&
        woli.SMC_Sub_status__c != oldMap.get(woli.id).SMC_Sub_status__c
      ) {
        closedWoli.add(woli);
        workTypeIdSet.add(woli.WorkTypeId);
      }
    }
    set<id> decomissionedAssetIdSet = new Set<Id>();
    set<id> runningWorkOrderIdSet = new Set<Id>();
    if (closedWoli.size() > 0) {
      Map<id, WorkType> wtMap = new Map<id, worktype>(
        [SELECT id, SMC_Type__c FROM WorkType WHERE id IN :workTypeIdSet]
      );
      for (WorkOrderLineItem woli : newList) {
        if (wtMap.get(woli.WorkTypeId).SMC_Type__c == STA_UtilsStatic.WT_TYPE_DECOMMISSIONNING) {
          decomissionedAssetIdSet.add(woli.AssetId);
          runningWorkOrderIdSet.add(woli.WorkOrderId);
        }
      }
      cancelWoliOnDecomissionnedAsset(
        decomissionedAssetIdSet,
        runningWorkOrderIdSet
      );
      PAD.ApexForcedBypass.add('assetDecommission');
      List<Asset> assetList = new List<Asset>();
      for (Id assId : decomissionedAssetIdSet) {
        assetList.add(
          new Asset(
            Id = assId,
            Status = STA_UtilsStatic.PICKLIST_ASSET_DECOMISSION,
            UsageEndDate = Date.today()
          )
        );
      }
      update assetList;
    }
  }

  /**
   * @description method to canceled Woli related to Decomissionned asset
   * but not related to current Work Order
   * @author emmanuel.bernier@modis.com | 08-28-2020
   * @param decomissionedAssetIdSet
   * @param runningWorkOrderIdSet
   **/
  public static void cancelWoliOnDecomissionnedAsset(
    Set<Id> decomissionedAssetIdSet,
    Set<Id> runningWorkOrderIdSet
  ) {
    List<WorkOrderLineItem> woliToCancelList = new List<WorkOrderLineItem>();
    List<WorkOrderLineItem> woliToCheckList = [
      SELECT
        id,
        (SELECT Id FROM ProductsRequired WHERE SMC_Quantity_Consumed__c > 0)
      FROM WorkOrderLineItem
      WHERE
        assetId IN :decomissionedAssetIdSet
        AND WorkOrderId NOT IN :runningWorkOrderIdSet
        AND isClosed = false
        AND (SMC_Labor_time_in_hours__c = 0
        OR SMC_Labor_time_in_hours__c = null)
    ];
    for (WorkOrderLineItem woliToCancel : woliToCheckList) {
      if (woliToCancel.ProductsRequired.size() == 0) {
        woliToCancel.Status = STA_UtilsStatic.COMPLETED;
        woliToCancel.SMC_Sub_status__c = 'SMC_Cancelled';
        woliToCancelList.add(woliToCancel);
      }
    }
    if (woliToCancelList.size() > 0) {
      update woliToCancelList;
    }
  }
  // /**
  //  * @description
  //  * @author Vincent RECASENS (Modis) | 13/05/2020
  //  * @param oldMap
  //  * @param newMap
  //  * @return void
  //  **/
  // public static void checkConsumedProduct(map<id, WorkOrderLineItem> newMap) {
  //   Set<Id> completedWoli = new Set<Id>();
  //   for (WorkOrderLineItem woli : newMap.values()) {
  //     if (woli.SMC_Sub_status__c == STA_UtilsStatic.WOLI_COMPLETED) {
  //       completedWoli.add(woli.id);
  //     }
  //   }

  //   for (ProductRequired onePR : [
  //     SELECT Id, ParentRecordId, SMC_Quantity_Consumed__c
  //     FROM ProductRequired
  //     WHERE ParentRecordId IN :completedWoli
  //   ]) {
  //     if (
  //       onePR.SMC_Quantity_Consumed__c == null &&
  //       !newMap.get(onePR.ParentRecordId)
  //         .TECH_SMC_Quantity_Consumed_Is_Not_Filled__c
  //     ) {
  //       newMap.get(onePR.ParentRecordId)
  //         .TECH_SMC_Quantity_Consumed_Is_Not_Filled__c = true;
  //     }
  //   }
  // }

  /**
   * @description : check validity of asset link to the work order
   * @author Vincent RECASENS (Modis) | 08/04/2020
   * @param workorderId
   * @return Boolean
   **/
  @AuraEnabled(cacheable=true)
  public static Map<String, Boolean> isLinkedAsset(id workorderLineItemId) {
    Map<String, Boolean> mapWOLILinked = new Map<String, Boolean>();
    WorkOrderLineItem woli;
    try {
      mapWOLILinked.put('eol', false);
      woli = [
        SELECT
          Id,
          WorkTypeId,
          WorkType.SMC_Spare_parts_are__c,
          Asset.Product2.SMC_Date_EndOfLife__c
        FROM WorkorderLineItem
        WHERE Id = :workorderLineItemId
      ];
      if (woli.Asset.Product2.SMC_Date_EndOfLife__c < date.TODAY()) {
        mapWOLILinked.put('eol', true);
      }
    } catch (Exception e) {
      System.debug(
        LoggingLevel.INFO,
        'There is no WorkOrderLineItem correspond to this query : [SELECT Id, WorkType.SMC_Spare_parts_are__c FROM WorkorderLineItem WHERE Id = :workorderLineItemId AND Asset.Product2.SMC_Date_EndOfLife__c < TODAY]'
      );
      mapWOLILinked.put('eol', false);
    }

    mapWOLILinked.put(
      'sparePart',
      IsSparePartsKo(new Set<Id>{ woli.Id }).get(woli.Id)
    );
    return mapWOLILinked;
  }

  /**
   * @description : check if WOLI need and has SpareParts
   * @author Vincent RECASENS (Modis) | 16/06/2020
   * @param woliIdSet
   * @return Map<Id, Boolean>
   **/
  public static Map<Id, Boolean> IsSparePartsKo(Set<Id> woliIdSet) {
    Map<Id, Boolean> resMap = new Map<Id, Boolean>();
    for (WorkOrderLineItem woli : [
      SELECT
        Id,
        WorkType.SMC_Spare_parts_are__c,
        (SELECT Id FROM ProductsRequired)
      FROM WorkOrderLineItem
      WHERE Id IN :woliIdSet
    ]) {
      resMap.put(
        woli.Id,
        woli.WorkType.SMC_Spare_parts_are__c == STA_UtilsStatic.MANDATORY &&
        woli.ProductsRequired.size() == 0
      );
    }
    return resMap;
  }

  /**
   * @description : manage 'Abordted' status on WOLI
   * @author Vincent RECASENS (Modis) | 07-05-2020
   * @param newMap
   * @param oldMap
   **/
  public static void toggleAbortedWoli(
    Map<Id, WorkOrderLineItem> newMap,
    Map<Id, WorkOrderLineItem> oldMap
  ) {
    Map<Id, List<String>> mapWorkOrderIdToWoliAborted = new Map<Id, List<String>>();
    Profile partnerProfile = [
      SELECT Id
      FROM Profile
      WHERE Name = :STA_UtilsStatic.PROFILE_SMC_PARTNER_COMMUNITY
    ];
    for (Id oneId : newMap.keySet()) {
      WorkOrderLineItem newWorkOrderLineItem = newMap.get(oneId);
      WorkOrderLineItem oldWorkOrderLineItem = oldMap.get(oneId);
      if (
        newWorkOrderLineItem.SMC_Sub_status__c !=
        STA_UtilsStatic.WOLI_ABORTED &&
        oldWorkOrderLineItem.SMC_Sub_status__c == STA_UtilsStatic.WOLI_ABORTED
      ) {
        mapWorkOrderIdToWoliAborted.put(
          newWorkOrderLineItem.WorkOrderId,
          new List<String>()
        );
      } else if (
        newWorkOrderLineItem.SMC_Aborted__c &&
        !oldWorkOrderLineItem.SMC_Aborted__c
      ) {
        //Checked abortion
        //Set field for abortion
        newMap.get(oneId).SMC_Aborted_By__c = (UserInfo.getProfileId() ==
          partnerProfile.Id
          ? STA_UtilsStatic.CUSTOMER
          : STA_UtilsStatic.ENGINEER);
        newMap.get(oneId).Status = STA_UtilsStatic.COMPLETED;
        newMap.get(oneId).SMC_Sub_status__c = STA_UtilsStatic.WOLI_ABORTED;
        //Set map to transfert information to the WorkOrder
        if (
          mapWorkOrderIdToWoliAborted.get(newWorkOrderLineItem.WorkOrderId) !=
          null
        ) {
          mapWorkOrderIdToWoliAborted.get(newWorkOrderLineItem.WorkOrderId)
            .add(newWorkOrderLineItem.LineItemNumber);
        } else {
          mapWorkOrderIdToWoliAborted.put(
            newWorkOrderLineItem.WorkOrderId,
            new List<String>{ newWorkOrderLineItem.LineItemNumber }
          );
        }
      }
    }

    if (mapWorkOrderIdToWoliAborted.size() > 0) {
      System.enqueueJob(new WoliAborted(mapWorkOrderIdToWoliAborted));
    }
  }

  /**
   * @description : add Note when WOLI is completed and WO have a Comment_On_Installation filled (from Trigger)
   * @author Vincent RECASENS (Modis) | 11-19-2020
   * @param oldMap
   * @param newMap
   **/
  public static void addInstallNoteOnAsset(
    Map<Id, WorkOrderLineItem> oldMap,
    Map<Id, WorkOrderLineItem> newMap
    ) {
    Map<Id, WorkOrderLineItem> newMapForNote = new Map<Id, WorkOrderLineItem>();
    for(Id oneId : newMap.keyset()){
      if (
        newMap.get(oneId).Status == STA_UtilsStatic.COMPLETED &&
        newMap.get(oneId).Status != oldMap.get(oneId).Status &&
        newMap.get(oneId).SMC_Actions_needed__c != '' &&
        newMap.get(oneId).SMC_Actions_needed__c != null
      ) {
        newMapForNote.put(oneId, newMap.get(oneId));
      }
    }
    if(newMapForNote.size() == 0){
      System.debug(LoggingLevel.INFO, 'There is no note to add.');
      return;
    }

    Map<Id, ContentNote> mapAssetIdToContentNote = new Map<Id, ContentNote>();
    for (WorkOrderLineItem woli : [
      SELECT
        Status,
        LineItemNumber,
        AssetId,
        SMC_Actions_needed__c,
        WorkOrder.WorkOrderNumber
      FROM WorkOrderLineItem
      WHERE Id IN :newMapForNote.keyset()
    ]) {
      mapAssetIdToContentNote.put(
        woli.AssetId,
        new ContentNote(
          Title = 'WO ' +
            woli.WorkOrder.WorkOrderNumber +
            '-' +
            woli.LineItemNumber,
          Content = Blob.valueOf(
            newMap.get(woli.Id).SMC_Actions_needed__c
          )
        )
      );
    }
    
    if (mapAssetIdToContentNote.size() > 0) {
      //Insert notes
      insert mapAssetIdToContentNote.values();

      //Create link between notes and assets
      List<ContentDocumentLink> newContentDocumentLinkNotesToInsert = new List<ContentDocumentLink>();
      for (Id oneId : mapAssetIdToContentNote.keySet()) {
        ContentDocumentLink newContentDocumentLink = new ContentDocumentLink();
        newContentDocumentLink.LinkedEntityId = oneId;
        newContentDocumentLink.ContentDocumentId = mapAssetIdToContentNote.get(
            oneId
          )
          .Id;
        newContentDocumentLinkNotesToInsert.add(newContentDocumentLink);
      }
      System.debug('newContentDocumentLinkNotesToInsert : ' + newContentDocumentLinkNotesToInsert);
      //Insert links
      if (newContentDocumentLinkNotesToInsert.size() > 0) {
        insert newContentDocumentLinkNotesToInsert;
      }
    }
  }

  /**
   * @description : check ServiceProduct On Asset and WorkType (if WorkType has a ServiceProduct)
   * @author Vincent RECASENS (Modis) | 11-26-2020
   * @lastModifiedBy Denis PHAM (Modis) | 30/05/2022
   * @param newList
   **/
  public static void checkServiceProductOnAssetAndWorkType(
    List<WorkOrderLineItem> newList
  ) {
    //Get Assets and WorkTypes
    Set<Id> setAssetId = new Set<Id>();
    Set<Id> setWorkTypeId = new Set<Id>();
    for (WorkOrderLineItem oneWorkOrderLineItem : newList) {
      if (
        oneWorkOrderLineItem.AssetId != null &&
        String.valueOf(oneWorkOrderLineItem.AssetId) != ''
      ) {
        setAssetId.add(oneWorkOrderLineItem.AssetId);
      }
      if (
        oneWorkOrderLineItem.WorkTypeId != null &&
        String.valueOf(oneWorkOrderLineItem.WorkTypeId) != ''
      ) {
        setWorkTypeId.add(oneWorkOrderLineItem.WorkTypeId);
      }
    }

    if (setAssetId.size() > 0 && setWorkTypeId.size() > 0) {
      Map<Id, Asset> mapAsset = new Map<Id, Asset>(
        [SELECT Product2Id FROM Asset WHERE Id IN :setAssetId]
      );

      Set<Id> serviceProductIdOnWorkType = new Set<Id>();
      List<SMC_WorkTypeServiceProductAssociation__c> lWorkTypeServiceProductAss = [SELECT SMC_Service_Product__c FROM SMC_WorkTypeServiceProductAssociation__c WHERE SMC_Work_Type__c IN :setWorkTypeId];

      if(lWorkTypeServiceProductAss.size() > 0)
      {
        for(SMC_WorkTypeServiceProductAssociation__c lAss : lWorkTypeServiceProductAss){
          serviceProductIdOnWorkType.add(lAss.SMC_Service_Product__c);
        }
      }

      if (mapAsset.size() > 0) {
        for (WorkOrderLineItem oneWorkOrderLineItem : newList) {
          if (
            !serviceProductIdOnWorkType.contains(mapAsset.get(oneWorkOrderLineItem.AssetId).Product2Id)
          ) {
            oneWorkOrderLineItem.addError(
              Label.SMC_NoMatch_ServiceProduct_WorkType_Asset
            );
          }
        }
      }
    }
  }

  /**
   * @description : used to prevent duplication of WOLI with same Asset-WorkType on one WorkOrder
   * @author Vincent RECASENS (Modis) | 12-01-2020
   * @param newList
   **/
  public static void keepUniquenessOnWorkOrder(
    List<WorkOrderLineItem> newList
  ) {
    Set<Id> woIds = new Set<Id>();
    Map<Id, Id> mapAssetIdToWorkTypeId = new Map<Id, Id>();
    for (WorkOrderLineItem oneWoli : newList) {
      woIds.add(oneWoli.WorkOrderId);
    }

    Map<Id, WorkOrderLineItem> mapWorkOrderLineItem = new Map<Id, WorkOrderLineItem>(
      [
        SELECT Id, AssetId, WorkTypeId
        FROM WorkOrderLineItem
        WHERE WorkOrderId IN :woIds
      ]
    );
    for (WorkOrderLineItem oneWoli : newList) {
      for (Id oneId : mapWorkOrderLineItem.keySet()) {
        WorkOrderLineItem woli = mapWorkOrderLineItem.get(oneId);
        if (
          oneWoli.AssetId == woli.AssetId &&
          oneWoli.WorkTypeId == woli.WorkTypeId
        ) {
          oneWoli.addError(
            'There is already a work order line item with the same asset and work type.'
          );
          break;
        }
      }
    }
  }

  /**
   * @description : flag WorkOrder if one WOLI is COMMISSIONING
   * @author Vincent RECASENS (Modis) | 01-15-2021
   * @param newMap
   **/
  public static void flagWOForWOLICommissionning(
    Map<Id, WorkOrderLineItem> newMap
  ) {
    Map<Id, WorkOrderLineItem> mapWoli = new Map<Id, WorkOrderLineItem>(
      [
        SELECT Id, WorkOrderId, WorkType.SMC_Type__c
        FROM WorkOrderLineItem
        WHERE Id IN :newMap.keySet()
      ]
    );
    Map<Id, WorkOrder> mapWorkOrderToUpdate = new Map<Id, WorkOrder>();
    for (WorkOrderLineITem oneWoli : [
      SELECT Id, WorkOrderId, WorkType.SMC_Type__c
      FROM WorkOrderLineItem
      WHERE Id IN :newMap.keySet()
    ]) {
      if (
        oneWoli.WorkType.SMC_Type__c == STA_UtilsStatic.WT_TYPE_COMMISSIONING
      ) {
        mapWorkOrderToUpdate.put(
          oneWoli.WorkOrderId,
          new WorkOrder(
            Id = oneWoli.WorkOrderId,
            SMC_Has_not_a_commissioning_WOLI__c = false
          )
        );
      }
    }

    if (mapWorkOrderToUpdate.size() > 0) {
      update mapWorkOrderToUpdate.values();
    }
  }

  /**
   * @description : used to delete useless SkillRequirement
   * @author Vincent RECASENS (Modis) | 01-15-2021
   * @param oldMap
   **/
  public static void checkSkillRequirementToDelete(
    Map<Id, WorkOrderLineItem> oldMap
  ) {
    Map<Id, SkillRequirement> mapSkillRequirement = new Map<Id, SkillRequirement>(
      [
        SELECT Id, RelatedRecordId, SkillId
        FROM SkillRequirement
        WHERE RelatedRecordId IN :oldMap.keySet()
      ]
    );
    if (mapSkillRequirement.size() > 0) {
      Map<Id, Set<Id>> mapWoIdsToSetSkillIds = new Map<Id, Set<Id>>();
      for (Id oneId : oldMap.keySet()) {
        mapWoIdsToSetSkillIds.put(oldMap.get(oneId).WorkOrderId, new Set<Id>());
        for (Id oneSRId : mapSkillRequirement.keySet()) {
          if (mapSkillRequirement.get(oneSRId).RelatedRecordId == oneId) {
            mapWoIdsToSetSkillIds.get(oldMap.get(oneId).WorkOrderId)
              .add(mapSkillRequirement.get(oneSRId).SkillId);
          }
        }
      }

      if (mapWoIdsToSetSkillIds.size() > 0) {
        System.enqueueJob(new SKillRequirementToDelete(mapWoIdsToSetSkillIds));
      }
    }
  }

  public class WoliAborted implements Queueable {
    Map<Id, List<String>> mapWorkOrderIdToWoliAborted;
    Map<Id, WorkOrder> mapWorkOrder;

    public WoliAborted(Map<Id, List<String>> mapWorkOrderIdToWoliAborted) {
      this.mapWorkOrderIdToWoliAborted = mapWorkOrderIdToWoliAborted;
      this.mapWorkOrder = new Map<Id, WorkOrder>(
        [
          SELECT Id, SMC_Work_Order_Line_Items_aborted__c
          FROM WorkOrder
          WHERE Id IN :mapWorkOrderIdToWoliAborted.keySet()
        ]
      );
    }

    public void execute(QueueableContext context) {
      for (WorkOrder oneWorkOrder : this.mapWorkOrder.values()) {
        oneWorkOrder.SMC_Work_Order_Line_Items_aborted__c = '';
        if (mapWorkOrderIdToWoliAborted.get(oneWorkOrder.Id).size() > 0) {
          for (
            String oneStr : mapWorkOrderIdToWoliAborted.get(oneWorkOrder.Id)
          ) {
            oneWorkOrder.SMC_Work_Order_Line_Items_aborted__c += oneStr + ';';
          }
          oneWorkOrder.SMC_Work_Order_Line_Items_aborted__c = oneWorkOrder.SMC_Work_Order_Line_Items_aborted__c.substring(
            0,
            oneWorkOrder.SMC_Work_Order_Line_Items_aborted__c.length() - 1
          );
        }
      }

      try {
        update mapWorkOrder.values();
      } catch (DMLException dmlException) {
        System.debug(LoggingLevel.INFO, 'ERROR ' + dmlException);
      }
    }
  }

  public class SKillRequirementToDelete implements Queueable {
    Map<Id, Set<Id>> mapWoIdsToSetSkillIds;
    Set<Id> skillIds;
    List<SkillRequirement> srToDelete;

    public SKillRequirementToDelete(Map<Id, Set<Id>> mapWoIdsToSetSkillIds) {
      this.mapWoIdsToSetSkillIds = mapWoIdsToSetSkillIds;
      this.skillIds = new Set<Id>();
      for (Id oneId : mapWoIdsToSetSkillIds.keySet()) {
        skillIds.addAll(mapWoIdsToSetSkillIds.get(oneId));
      }

      Map<Id, SkillRequirement> mapSkillRequirementLinkToWO = new Map<Id, SkillRequirement>(
        [
          SELECT Id
          FROM SkillRequirement
          WHERE
            RelatedRecordId IN :mapWoIdsToSetSkillIds.keySet()
            AND SkillId IN :skillIds
        ]
      );
      if (mapSkillRequirementLinkToWO.size() > 0) {
        this.srToDelete = mapSkillRequirementLinkToWO.values();
      }
    }

    public void execute(QueueableContext context) {
      if (this.srToDelete.size() > 0) {
        delete this.srToDelete;
      }
    }
  }
}