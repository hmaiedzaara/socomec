/**
 * @File Name          : SMC_AP_ManageWorkOrder.cls
 * @Description        :
 * @Author             : emmanuel.bernier@modis.com
 * @Group              :
 * @Last Modified By   : Vincent RECASENS (Modis)
 * @Last Modified On   : 01-22-2021
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    ??/11/2019   Emmanuel BERNIER (Modis)     Initial Version
 * 1.1    10/03/2020   Vincent RECASENS (Modis)     Create "isLinkedAssets(id workorderLineItemId)" to replace "isLinkedAssetEOL(id workorderLineItemId)"
 **/

public with sharing class SMC_AP_ManageWorkOrder {
  /**
   * @description : check validity of asset link to the work order
   * @author Vincent RECASENS (Modis) | 08/04/2020
   * @param workorderId
   * @return Boolean
   **/
  @AuraEnabled //(cacheable=true)
  public static Boolean isLinkedAssetsEOL(id workorderId) {
    Boolean checkValidation =
      [
        SELECT id
        FROM WorkorderLineItem
        WHERE
          WorkOrderId = :workorderId
          AND Asset.Product2.SMC_Date_EndOfLife__c < TODAY
      ]
      .size() > 0;
    return checkValidation;
  }

  /**
   * @description : prevent cancel status if work order is link to a product or a labor
   * @author Vincent RECASENS (Modis) | 08/04/2020
   * @param oldMap
   * @param newMap
   **/
  public static void preventCancel(
    map<id, WorkOrder> oldMap,
    map<id, WorkOrder> newMap
  ) {
    map<id, WorkOrder> canceledwoMap = new Map<id, WorkOrder>();
    for (WorkOrder wo : newMap.values()) {
      String oldStatus = oldMap.get(wo.id).status;
      if (wo.SMC_Sub_status__c == 'CANCELED' && wo.status != oldStatus) {
        canceledwoMap.put(wo.id, wo);
        if (
          oldStatus != 'New' &&
          oldStatus != 'TO BE SCHEDULED' &&
          oldStatus != 'SCHEDULED'
        ) {
          wo.addError(Label.SMC_FSL_Cant_Cancel_In_ProgressWO);
        }
      }
    }
    if (canceledwoMap.size() > 0) {
      preventCancelDelete(canceledwoMap);
    }
  }

  /**
   * @description : prevent cancel status if work order is link to a product or a labor
   * @author Vincent RECASENS (Modis) | 08/04/2020
   * @param oldMap
   * @param newMap
   **/
  public static void preventCancelDelete(map<id, WorkOrder> canceledwoMap) {
    set<Id> workOrderWithConsumedProduct = new Set<Id>();
    Map<id, Id> mapWoWoli = new Map<id, Id>();
    Set<Id> setWoNotCanceledWoli = new Set<Id>();
    for (WorkOrderLineItem woli : [
      SELECT id, WorkOrderId, SMC_Sub_status__c
      FROM WorkOrderLineItem
      WHERE WorkOrderId IN :canceledwoMap.keySet()
    ]) {
      mapWoWoli.put(woli.Id, woli.WorkOrderId);
      if (
        woli.SMC_Sub_status__c != STA_UtilsStatic.WOLI_CANCELED &&
        woli.SMC_Sub_status__c != STA_UtilsStatic.WOLI_ABORTED
      ) {
        setWoNotCanceledWoli.add(woli.WorkOrderId);
      }
    }
    for (ProductRequired consumed : [
      SELECT id, ParentRecordId
      FROM ProductRequired
      WHERE
        ParentRecordId IN :mapWoWoli.keySet()
        AND SMC_Quantity_Consumed__c > 0
    ]) {
      workOrderWithConsumedProduct.add(mapWoWoli.get(consumed.ParentRecordId));
    }
    for (WorkOrder wo : canceledwoMap.values()) {
      if (wo.SMC_consolidated_labor_time__c > 0) {
        wo.addError(Label.SMC_FSL_Cant_Cancel_With_Labor);
      }
      if (workOrderWithConsumedProduct.contains(wo.Id)) {
        wo.addError(Label.SMC_FSL_Cant_Cancel_With_Product);
      }
      if (setWoNotCanceledWoli.contains(wo.Id)) {
        wo.addError(Label.SMC_FSL_Cant_Cancel_With_UncanceldWOLI);
      }
    }
  }

  /**
   * @description : prevent Complete status if some WOLI have QuantityConsumed field not filled
   * @author Vincent RECASENS (Modis) | 13/05/2020
   * @param newMap
   * @param oldMap
   * @return void
   **/
  public static void preventCompleteIfQuantityConsumedNotfilled(
    Map<Id, WorkOrder> newMap,
    Map<Id, WorkOrder> oldMap
  ) {
    Set<Id> setWorkOrderId = new Set<Id>();
    for (Id oneId : newMap.keySet()) {
      WorkOrder newWo = newMap.get(oneId);
      WorkOrder oldWo = oldMap.get(oneId);
      if (
        newWo.Status != oldWo.Status &&
        newWo.Status == 'Completed' &&
        newWo.SMC_Sub_status__c == 'COMPLETED'
      ) {
        setWorkOrderId.add(oneId);
      }
    }

    if (setWorkOrderId.size() > 0) {
      for (WorkOrderLineItem oneWoli : [
        SELECT
          Id,
          WorkOrderId,
          TECH_SMC_Quantity_Consumed_Is_Not_Filled__c,
          WorkType.SMC_Spare_parts_are__c
        FROM WorkOrderLineItem
        WHERE
          WorkOrderId IN :setWorkOrderId
          AND WorkType.SMC_Spare_parts_are__c = 'mandatory'
          AND TECH_SMC_Quantity_Consumed_Is_Not_Filled__c = true
      ]) {
        newMap.get(oneWoli.WorkOrderId)
          .addError(
            System.Label.SMC_FSL_Cant_complete_WO_without_consumed_product
          );
      }
    }
  }

  /**
   * @description Update the Service Appointment status according to the workorder status
   * @author emmanuel.bernier@modis.com | 28/05/2020
   * @param newList
   * @param oldMap
   * @return void
   **/
  public static void syncSaOnWorkorderProgress(
    List<WorkOrder> newList,
    Map<Id, WorkOrder> oldMap
  ) {
    Map<Id, String> changedWorkOrderIdMap = new Map<Id, String>();
    for (WorkOrder wo : newList) {
      WorkOrder oldWo = oldMap.get(wo.Id);
      if (wo.SMC_Sub_status__c == 'COMPLETED' && oldWo.Status != wo.Status) {
        changedWorkOrderIdMap.put(wo.id, 'Completed');
      }
      if (wo.status == 'IN PROGRESS' && oldWo.Status != wo.Status) {
        changedWorkOrderIdMap.put(wo.id, 'In Progress');
      }
      if (wo.SMC_Sub_status__c == 'CANCELED' && oldWo.Status != wo.Status) {
        changedWorkOrderIdMap.put(wo.id, 'Canceled');
      }
    }
    if (changedWorkOrderIdMap.size() > 0) {
      List<ServiceAppointment> saList = [
        SELECT id, ParentRecordId
        FROM ServiceAppointment
        WHERE ParentRecordId IN :changedWorkOrderIdMap.keySet()
      ];
      set<Id> canceledSaIdSet = new Set<Id>();
      for (ServiceAppointment sa : salist) {
        sa.Status = changedWorkOrderIdMap.get(sa.ParentRecordId);
        if (changedWorkOrderIdMap.get(sa.ParentRecordId) == 'Canceled') {
          canceledSaIdSet.add(sa.Id);
        }
      }
      update saList;
      if (canceledSaIdSet.size() > 0) {
        delete [
          SELECT Id
          FROM AssignedResource
          WHERE ServiceAppointmentId IN :canceledSaIdSet
        ];
      }
    }
  }

  /**
   * @description return filtered Workorder that have been completed
   * @author emmanuel.bernier@modis.com | 08-20-2020
   * @param newList
   * @param oldMap
   * @return Map<Id, WorkOrder>
   **/
  public static Map<Id, WorkOrder> filterCompletedWorkOrder(
    List<WorkOrder> newList,
    Map<Id, WorkOrder> oldMap
  ) {
    Map<Id, WorkOrder> retMap = new Map<Id, WorkOrder>();
    for (WorkOrder wo : newList) {
      if (wo.Status != oldMap.get(wo.Id).Status) {
        if (wo.Status == 'Completed') {
          retMap.put(wo.Id, wo);
        }
      }
    }
    return retMap;
  }

  /**
   * @description : used to add a note on the asset linked to the woli
   * @author Vincent RECASENS (Modis) | 11-12-2020
   * @param completedWoMap
   **/
  public static void updateAssetOnWorkOrderCompletion(
    Map<Id, WorkOrder> newMap,
    Map<Id, WorkOrder> oldMap
  ) {
    Map<Id, WorkOrder> woNeedToAddNote = new Map<Id, WorkOrder>();
    for (Id oneWoId : newMap.keySet()) {
      if (
        newMap.get(oneWoId).SMC_Comment_on_installation__c != '' &&
        newMap.get(oneWoId).SMC_Comment_on_installation__c != null &&
        newMap.get(oneWoId).SMC_Comment_on_installation__c !=
        oldMap.get(oneWoId).SMC_Comment_on_installation__c
      ) {
        woNeedToAddNote.put(oneWoId, newMap.get(oneWoId));
      }
    }
    if (woNeedToAddNote.size() == 0) {
      return;
    }

    Map<Id, Map<String, Id>> workOrderToMapWoliNumberToAsset = new Map<Id, Map<String, Id>>();
    for (WorkOrderLineItem woli : [
      SELECT
        Status,
        SMC_Sub_status__c,
        LineItemNumber,
        AssetId,
        WorkOrderId,
        WorkOrder.SMC_Comment_on_installation__c,
        WorkOrder.WorkOrderNumber
      FROM WorkOrderLineItem
      WHERE WorkOrderId IN :woNeedToAddNote.keyset()
    ]) {
      if (
        woli.Status == 'Completed' &&
        woli.SMC_Sub_status__c == 'SMC_Completed'
      ) {
        if (workOrderToMapWoliNumberToAsset.get(woli.WorkOrderId) == null) {
          workOrderToMapWoliNumberToAsset.put(
            woli.WorkOrderId,
            new Map<String, Id>()
          );
        }
        if (woli.AssetId != null) {
          workOrderToMapWoliNumberToAsset.get(woli.WorkOrderId)
            .put(woli.LineItemNumber, woli.AssetId);
        }
      }
    }
    //Create notes
    if (workOrderToMapWoliNumberToAsset.size() > 0) {
      Map<Id, ContentNote> mapAssetIdToContentNote = new Map<Id, ContentNote>();
      Set<Id> assetsAlreadyHaveTheNewNote = new Set<Id>();
      for (WorkOrder wo : woNeedToAddNote.values()) {
        for (String str : workOrderToMapWoliNumberToAsset.get(wo.Id).keySet()) {
          if (
            !assetsAlreadyHaveTheNewNote.contains(
              workOrderToMapWoliNumberToAsset.get(wo.Id).get(str)
            )
          ) {
            mapAssetIdToContentNote.put(
              workOrderToMapWoliNumberToAsset.get(wo.Id).get(str),
              new ContentNote(
                Title = 'WO ' + wo.WorkOrderNumber + '-' + str,
                Content = Blob.valueOf(wo.SMC_Comment_on_installation__c)
              )
            );
            assetsAlreadyHaveTheNewNote.add(
              workOrderToMapWoliNumberToAsset.get(wo.Id).get(str)
            );
          }
        }
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
        //Insert links
        if (newContentDocumentLinkNotesToInsert.size() > 0) {
          insert newContentDocumentLinkNotesToInsert;
        }
      }
    }
  }

  public static void syncStartEndDateCustomAndStandard(
    List<WorkOrder> newList,
    Map<Id, WorkOrder> oldMap
  ) {
    Set<Id> workOrderCompleted = new Set<Id>();
    for (WorkOrder newWo : newList) {
      if (
        newWo.SMC_Sotech_synchro_Completed_date__c != null &&
        newWo.StartDate == null &&
        newWo.EndDate == null
      ) {
        workOrderCompleted.add(newWo.Id);
      }
    }

    if (workOrderCompleted.size() > 0) {
      System.enqueueJob(new WOCompleteStartDate(workOrderCompleted));
    }
  }

  public static void updateServiceAppointmentForCommissionningWO(
    Map<Id, WorkOrder> newMap,
    Map<Id, WorkOrder> oldMap
  ) {
    Map<Id, WorkOrder> mapWorkOrder = new Map<Id, WorkOrder>();
    for (Id oneId : newMap.keySet()) {
      if (
        newMap.get(oneId).SMC_Has_not_a_commissioning_WOLI__c !=
        oldMap.get(oneId).SMC_Has_not_a_commissioning_WOLI__c
      ) {
        mapWorkOrder.put(oneId, newMap.get(oneId));
      }
    }

    if (mapWorkOrder.size() > 0) {
      Map<Id, ServiceAppointment> mapWoIdTosaToUpdate = new Map<Id, ServiceAppointment>();
      for (ServiceAppointment oneSA : [
        SELECT Id, ParentRecordId, SMC_Auto_Dispatched__c
        FROM ServiceAppointment
        WHERE ParentRecordId IN :mapWorkOrder.keySet()
      ]) {
        mapWoIdTosaToUpdate.put(oneSA.ParentRecordId, oneSA);
      }
      if (mapWoIdTosaToUpdate.size() > 0) {
        System.enqueueJob(
          new ServiceAppointmentUpdater(mapWorkOrder, mapWoIdTosaToUpdate)
        );
      }
    }
  }

  /**
  * @description : fill comment for technician to inform him specific instruction on location
  * @author Vincent RECASENS (Modis) | 04-15-2021 
  * @param newMap 
  **/
  public static void fillCommentForTechnicianWithAdditionnalInfosFromLocation(List<WorkOrder> newList){
    Map<Id, String> mapLocationId_WoNumber = new Map<Id, String>();
    for(WorkOrder oneWo : newList){
      if(oneWo.LocationId != null){
        /*
          In before insert, wo number is null.
          The map is used to utilize ".get(key)" after retrieve locations
        */
        mapLocationId_WoNumber.put(oneWo.LocationId, oneWo.WorkOrderNumber);
      }
    }

    if(mapLocationId_WoNumber.size() > 0){
      Map<Id, Schema.Location> mapLocation = new Map<Id, Schema.Location>([SELECT Id, SMC_AdditionalInfos__c FROM Location WHERE Id IN :mapLocationId_WoNumber.keySet()]);
      for(WorkOrder oneWo : newList){
        if(oneWo.LocationId != null && mapLocation.get(oneWo.LocationId) != null){
          if(oneWo.SMC_Comment_for_Technician__c == null || oneWo.SMC_Comment_for_Technician__c == ''){
            oneWo.SMC_Comment_for_Technician__c = String.valueOf(mapLocation.get(oneWo.LocationId).SMC_AdditionalInfos__c);
          }
          else if(mapLocation.get(oneWo.LocationId) != null && mapLocation.get(oneWo.LocationId).SMC_AdditionalInfos__c != null){
            oneWo.SMC_Comment_for_Technician__c += '\n' + mapLocation.get(oneWo.LocationId).SMC_AdditionalInfos__c;
          }
        }
      }
    }
  }

  /**
  * @description : update SergiceAppointment if duration is modified on WOLI
  * @author Vincent RECASENS (Modis) | 05-25-2021 
  * @param newMap 
  * @param oldMap 
  **/
  public static void updateServiceAppointmentForDurationModification(
    Map<Id, WorkOrder> newMap,
    Map<Id, WorkOrder> oldMap
  ){
    Map<Id, Decimal> mapWoId_NewDurationInMinutes = new Map<Id, Decimal>();
    for(Id oneId : newMap.keySet()){
      WorkOrder newWo = newMap.get(oneId);
      WorkOrder oldWo = oldMap.get(oneId);
      if(newWo.SMC_Theoritical_duration__c != oldWo.SMC_Theoritical_duration__c){
        mapWoId_NewDurationInMinutes.put(oneId, newWo.SMC_Theoritical_duration__c);
      }
    }

    if(mapWoId_NewDurationInMinutes.size() > 0){
      List<ServiceAppointment> saToUpdate = new List<ServiceAppointment>();
      for(ServiceAppointment oneSa : [SELECT Id, ParentRecordId, Duration FROM ServiceAppointment WHERE ParentRecordId IN :mapWoId_NewDurationInMinutes.keySet() AND Status = 'None']){
        if(mapWoId_NewDurationInMinutes.get(oneSa.ParentRecordId) != null){
          oneSa.Duration = mapWoId_NewDurationInMinutes.get(oneSa.ParentRecordId);
          saToUpdate.add(oneSa);
        }
      }

      if(saToUpdate.size() > 0){
        update saToUpdate;
      }
    }
  }

  public class WOCompleteStartDate implements Queueable {
    Set<Id> workOrderCompleted;

    public WOCompleteStartDate(Set<Id> workOrderCompleted) {
      this.workOrderCompleted = workOrderCompleted;
    }

    public void execute(QueueableContext context) {
      List<WorkOrder> workOrderToUpdate = [
        SELECT
          Id,
          StartDate,
          SMC_Start_Date_Min__c,
          EndDate,
          SMC_End_Date_Max__c
        FROM WorkOrder
        WHERE Id IN :this.workOrderCompleted
      ];
      for (WorkOrder oneWorkOrder : workOrderToUpdate) {
        oneWorkOrder.StartDate = oneWorkOrder.SMC_Start_Date_Min__c;
        oneWorkOrder.EndDate = oneWorkOrder.SMC_End_Date_Max__c;
      }

      update workOrderToUpdate;
    }
  }

  public class ServiceAppointmentUpdater implements Queueable {
    Map<Id, WorkOrder> mapWorkOrder;
    Map<Id, ServiceAppointment> mapWoIdTosaToUpdate;

    public ServiceAppointmentUpdater(
      Map<Id, WorkOrder> mapWorkOrder,
      Map<Id, ServiceAppointment> mapWoIdTosaToUpdate
    ) {
      this.mapWorkOrder = mapWorkOrder;
      this.mapWoIdTosaToUpdate = mapWoIdTosaToUpdate;
    }

    public void execute(QueueableContext context) {
      for (Id oneId : mapWorkOrder.keySet()) {
        if (mapWoIdTosaToUpdate.get(oneId) != null) {
          mapWoIdTosaToUpdate.get(oneId)
            .SMC_Auto_Dispatched__c = mapWorkOrder.get(oneId)
            .SMC_Has_not_a_commissioning_WOLI__c;
        }
      }
      update mapWoIdTosaToUpdate.values();
    }
  }
}