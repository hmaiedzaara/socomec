/*
-----------------------------------------------------------------------------------
-- - Name : SMC_AP_ManageProductRequired
-- - Author : Vincent RECASENS (VRE)
-- - Description : This class is manage Product Required
--
-- Maintenance History:
--
-- Date         Name   Version     Remarks
-- -----------  ----   -------     ----------------------------
-- 16-APR-2019  VRE    1.0         Initial Version
------------------------------------------------------------------------------------
*/

public with sharing class SMC_AP_ManageProductRequired {
  /**
   * @description : create a product required for new work oreder line
   * @author Vincent RECASENS (Modis) | 08/04/2020
   * @param workOrderLineItemId
   * @param wrapperList
   * @return Boolean
   **/
  public static Boolean createProductRequired(
    String workOrderLineItemId,
    List<SMC_AC_CreateRecordFromDatatable.WrapperDataTableForWorkerOrderLineItem> wrapperList
  ) {
    List<ProductRequired> productRequiredToInsert = new List<ProductRequired>();
    for (
      SMC_AC_CreateRecordFromDatatable.WrapperDataTableForWorkerOrderLineItem oneObject : wrapperList
    ) {
      //Build new ProductRequired
      ProductRequired newProductRequired = new ProductRequired();
      newProductRequired.ParentRecordId = workOrderLineItemId;
      newProductRequired.Product2Id = oneObject.id;
      newProductRequired.QuantityRequired = Integer.valueOf(oneObject.quantity);
      productRequiredToInsert.add(newProductRequired);
    }

    try {
      insert productRequiredToInsert;
    } catch (DMLException dmlException) {
      System.debug(LoggingLevel.INFO, 'DMLException : ' + dmlException);
      SMC_UTIL_Methods_Batch.createErrorLog(
        new List<Exception>{ dmlException },
        'Error during PorudtcRequired insertion',
        STA_UtilsStatic.PICKLIST_LOGS_PROCESS_TYPE_WS,
        'Record list body : ' + productRequiredToInsert,
        'INSERT',
        new List<String>{ workOrderLineItemId }
      );
      return false;
    }
    return true;
  }

  /**
   * @description : used to update WOLI in according to ProductRequired.SMC_Quantity_Consumed__c is filled or not.
   * @author Vincent RECASENS (Modis) | 14/05/2020
   * @param newList
   * @return void
   **/
  public static void launchFutureMethodUpdateWOLI(
    List<ProductRequired> newList
  ) {
    Set<Id> setWoliId = new Set<Id>();
    for (ProductRequired onePR : newList) {
      if (
        onePR.ParentRecordId.getSobjectType() ==
        Schema.WorkOrderLineItem.SObjectType
      ) {
        setWoliId.add(onePR.ParentRecordId);
      }
    }

    if (setWoliId.size() > 0) {
      updateWOLIQuantityConsumedIndentifierField(setWoliId);
    }
  }

  /**
   * @description : update parent WOLI
   * @author Vincent RECASENS (Modis) | 14/05/2020
   * @param mapWoliIdToQuantityConsumedIsFilledJSON
   * @return void
   **/
  @Future
  public static void updateWOLIQuantityConsumedIndentifierField(
    Set<Id> setWoliId
  ) {
    Map<Id, WorkOrderLineItem> mapWorkOrderLineItem = new Map<Id, WorkOrderLineItem>(
      [
        SELECT Id, Subject, TECH_SMC_Quantity_Consumed_Is_Not_Filled__c
        FROM WorkOrderLineItem
        WHERE Id IN :setWoliId
      ]
    );
    Map<Id, List<ProductRequired>> mapWoliIdToListProductRequired = new Map<Id, List<ProductRequired>>();
    for (ProductRequired onePr : [
      SELECT Id, ParentRecordId, SMC_Quantity_Consumed__c
      FROM ProductRequired
      WHERE ParentRecordId IN :setWoliId
    ]) {
      if (mapWoliIdToListProductRequired.get(onePr.ParentRecordId) != null) {
        mapWoliIdToListProductRequired.get(onePr.ParentRecordId).add(onePr);
      } else {
        mapWoliIdToListProductRequired.put(
          onePr.ParentRecordId,
          new List<ProductRequired>{ onePr }
        );
      }
    }

    for (Id oneWoliId : mapWoliIdToListProductRequired.keySet()) {
      Boolean quantityConsumedIsNotFilled = false;
      for (
        ProductRequired onePr : mapWoliIdToListProductRequired.get(oneWoliId)
      ) {
        if (onePr.SMC_Quantity_Consumed__c == null) {
          quantityConsumedIsNotFilled = true;
        }
      }
      mapWorkOrderLineItem.get(oneWoliId)
        .TECH_SMC_Quantity_Consumed_Is_Not_Filled__c = quantityConsumedIsNotFilled;
      mapWorkOrderLineItem.get(oneWoliId)
        .SMC_TECH_Has_required_product__c = true;
    }

    if (mapWorkOrderLineItem.size() > 0) {
      update mapWorkOrderLineItem.values();
    }
  }
}