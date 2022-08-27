/**
 * @File Name          : SMC_AP_ManageServiceAppointment.cls
 * @Description        :
 * @Author             : Vincent RECASENS (Modis)
 * @Group              :
 * @Last Modified By   : Vincent RECASENS (Modis)
 * @Last Modified On   : 01-27-2021
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    ??/11/2019   Emmanuel BERNIER (Modis)     Initial Version
 **/

public with sharing class SMC_AP_ManageServiceAppointment {
  /**
   * @description
   * @author Vincent RECASENS (Modis) | 01-06-2021
   * @param newList
   * @return Boolean
   **/
  public static void checkUniquenessServiceAppointmentOnWorkOrder(
    List<ServiceAppointment> newList
  ) {
    //Check ParentRecordId = WorkOrder
    List<Id> listParentRecordId = new List<Id>();
    for (ServiceAppointment oneSA : newList) {
      if (
        oneSA.ParentRecordId.getSObjectType() == Schema.WorkOrder.SObjectType
      ) {
        listParentRecordId.add(oneSA.ParentRecordId);
      }
    }

    if (listParentRecordId.size() > 0) {
      //Get existing ServiceAppouintment
      Set<Id> setParentRecordId = new Set<Id>();
      for (ServiceAppointment oneExistingSA : [
        SELECT Id, ParentRecordId
        FROM ServiceAppointment
        WHERE
          ParentRecordId IN :listParentRecordId
          AND Status != 'Completed'
          AND Status != 'Canceled'
      ]) {
        setParentRecordId.add(oneExistingSA.ParentRecordId);
      }
      if (setParentRecordId.size() > 0) {
        for (ServiceAppointment oneSA : newList) {
          if (setParentRecordId.contains(oneSA.ParentRecordId)) {
            oneSA.addError(
              'You cannot create another service appointment on the same work order if the existing service appointment is not completed or cancelled.'
            );
          }
        }
      }
    }
  }

  /**
   * @description : set serviceAppointment EarliestStartTime field from parent
   * and duration = workorder theoritical duration
   * @author Vincent RECASENS (Modis) | 08/04/2020
   * @param newList
   **/
  public static void fillEarliestStartDateFromParent(
    List<ServiceAppointment> newList
  ) {
    set<Id> parentWorkOrderSet = new Set<Id>();
    for (ServiceAppointment sa : newList) {
      if (sa.ParentRecordId.getSObjectType() == Schema.WorkOrder.SObjectType) {
        parentWorkOrderSet.add(sa.ParentRecordId);
      }
    }
    if(parentWorkOrderSet.size() > 0){
      Map<Id, WorkOrder> workOrderMap = new Map<Id, WorkOrder>(
        [
          SELECT id, createdDate, SMC_Theoritical_duration__c
          FROM WorkOrder
          WHERE id IN :parentWorkOrderSet
        ]
      );
      for (ServiceAppointment sa : newList) {
        if (workOrderMap.get(sa.ParentRecordId) != null) {
          sa.EarliestStartTime = sa.EarliestStartTime <
            workOrderMap.get(sa.ParentRecordId).createdDate
            ? workOrderMap.get(sa.ParentRecordId).createdDate
            : sa.EarliestStartTime;
        }
      }
    }
  }

  /**
   * @description : set serviceAppointment SMC_First_pre_planned_Date__c field from parent
   * @author Vincent RECASENS (Modis) | 08/04/2020
   * @param newList
   **/
  public static void fillFirstStartDateFromParent(
    list<ServiceAppointment> newList
  ) {
    set<Id> parentWorkOrderSet = new Set<Id>();
    for (ServiceAppointment sa : newList) {
      if (sa.ParentRecordId.getSObjectType() == Schema.WorkOrder.SObjectType) {
        parentWorkOrderSet.add(sa.ParentRecordId);
      }
    }
    if(parentWorkOrderSet.size() > 0){
      Map<Id, WorkOrder> workOrderMap = new Map<Id, WorkOrder>(
        [
          SELECT id, createdDate, SMC_First_pre_planned_Date__c
          FROM WorkOrder
          WHERE id IN :parentWorkOrderSet
        ]
      );
      list<WorkOrder> woList = new List<WorkOrder>();
      for (ServiceAppointment sa : newList) {
        if (sa.SchedStartTime != null) {
          if (
            workOrderMap.get(sa.ParentRecordId) != null &&
            workOrderMap.get(sa.ParentRecordId).SMC_First_pre_planned_Date__c ==
            null
          ) {
            workOrderMap.get(sa.ParentRecordId)
              .SMC_First_pre_planned_Date__c = sa.SchedStartTime.date();
            woList.add(workOrderMap.get(sa.ParentRecordId));
          }
        }
      }
      update woList;
    }
  }

  /**
   * @description : check validity of WOLI from SA
   * @author Vincent RECASENS (Modis) | 07-10-2020
   * @param newList
   **/
  public static void checkWorkOrderCorrectness(
    List<ServiceAppointment> newList
  ) {
    Map<Id, ServiceAppointment> parentIdMap = new Map<Id, ServiceAppointment>();
    for (ServiceAppointment sapp : newList) {
      parentIdMap.put(sapp.ParentRecordId, sapp);
    }
    map<Id, WorkOrderLineItem> concernedWoli = new Map<Id, WorkOrderLineItem>(
      [
        SELECT id, workOrderId
        FROM WorkOrderLineItem
        WHERE workOrderId IN :parentIdMap.keySet()
      ]
    );
    Map<Id, Boolean> koWoliMap = SMC_AP_ManageWorkOrderLineItem.IsSparePartsKo(
      concernedWoli.keySet()
    );
    for (id woliId : koWoliMap.keySet()) {
      if (koWoliMap.get(woliID)) {
        parentIdMap.get(concernedWoli.get(woliId).workOrderId)
          .addError(Label.SMC_FSL_Cant_Create_SA_with_incomplete_lines);
      }
    }
  }

  /**
   * @description : send Email to the ContactId
   * @author Vincent RECASENS (Modis) | 11-27-2020
   * @param newList
   * @param oldMap
   **/
  public static void sendEmailServiceAppointment(
    List<ServiceAppointment> newList,
    Map<Id, ServiceAppointment> oldMap
  ) {
    Messaging.SingleEmailMessage[] messages = new List<Messaging.SingleEmailMessage>();
    Map<Id, Messaging.SingleEmailMessage> ctcIdsToMessages = new Map<Id, Messaging.SingleEmailMessage>();
    for (ServiceAppointment oneSA : newList) {
      if (
        oldMap != null &&
        (oneSA.SchedStartTime != oldMap.get(oneSA.Id).SchedStartTime ||
        oneSA.SchedEndTime != oldMap.get(oneSA.Id).SchedEndTime) &&
        oneSA.Status == 'Dispatched'
      ) {
        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.setWhatId(oneSA.Id); //This is important for the merge fields in template to work
        message.setTargetObjectId(oneSA.ContactId);
        message.setSenderDisplayName('Socomec Support');
        message.setReplyTo('noreply.salesforce@socomec.com');
        message.setUseSignature(false);
        message.setBccSender(false);
        message.setSaveAsActivity(false);
        EmailTemplate emailTemplate = [
          SELECT Id, Subject, Description, HtmlValue, DeveloperName, Body
          FROM EmailTemplate
          WHERE Name = 'SMC_Appointment_multilang'
        ];
        message.setTemplateID(emailTemplate.Id);
        ctcIdsToMessages.put(oneSA.ContactId, message);
      }
    }

    if (ctcIdsToMessages.size() > 0) {
      for (Contact oneContact : [
        SELECT Id, Email
        FROM Contact
        WHERE Id IN :ctcIdsToMessages.keySet()
      ]) {
        ctcIdsToMessages.get(oneContact.Id).toAddresses = new List<String>{
          oneContact.Email
        };
        messages.add(ctcIdsToMessages.get(oneContact.Id));
      }
    }

    if (messages.size() > 0) {
      Messaging.sendEmail(messages);
    } else {
      System.debug('No email send.');
    }
  }

  /**
   * @description : set boolean to auto-dispatch ServiceAppointement if WO has not commissionning woli
   * @author Vincent RECASENS (Modis) | 01-15-2021
   * @param newList
   **/
  public static void checkCommissionningWO(List<ServiceAppointment> newList) {
    Set<Id> parentRecordId = new Set<Id>();
    for (ServiceAppointment oneSA : newList) {
      if (
        oneSA.ParentRecordId.getSObjectType() == Schema.WorkOrder.SObjectType
      ) {
        parentRecordId.add(oneSA.ParentRecordId);
      }
    }

    if (parentRecordId.size() > 0) {
      Map<Id, WorkOrder> mapWo = new Map<Id, WorkOrder>(
        [
          SELECT Id, SMC_Has_not_a_commissioning_WOLI__c
          FROM WorkOrder
          WHERE Id IN :parentRecordId
        ]
      );
      if (mapWo.size() > 0) {
        for (ServiceAppointment oneSA : newList) {
          if (mapWo.get(oneSA.ParentRecordId) != null) {
            oneSA.SMC_Auto_Dispatched__c = mapWo.get(oneSA.ParentRecordId)
              .SMC_Has_not_a_commissioning_WOLI__c;
          }
        }
      }
    }
  }

  /**
  * @description : 
  * @author Vincent RECASENS (Modis) | 04-15-2021 
  * @param newList 
  **/
  public static void setDurationFromAllRelatedWoli(List<ServiceAppointment> newList){
    //Get work order id
    // Map<String, Id> mapSANumber_WOId = new Map<String, Id>();
    Map<Id, ServiceAppointment> mapWOId_SA = new Map<Id, ServiceAppointment>();
    for(ServiceAppointment oneSA : newList){
      if(oneSA.ParentRecordId.getSObjectType() == Schema.WorkOrder.SObjectType){
        // mapSANumber_WOId.put(oneSA.AppointmentNumber, oneSA.ParentRecordId);
        mapWOId_SA.put(oneSA.ParentRecordId, oneSA);
      }
    }

    if(mapWOId_SA.size() > 0){
      //Get work order line items duration
      Map<Id, Decimal> mapWOId_Duration = new Map<Id, Decimal>();
      // for(WorkOrderLineItem oneWoli : [SELECT Id, WorkOrderId, Duration, DurationType FROM WorkOrderLineItem WHERE WorkOrderId IN :mapSANumber_WOId.values() AND Status != :STA_UtilsStatic.WOLI_COMPLETED_MAIN_STATUS]){
      for(WorkOrderLineItem oneWoli : [SELECT Id, WorkOrderId, Duration, DurationType FROM WorkOrderLineItem WHERE WorkOrderId IN :mapWOId_SA.keySet() AND Status != :STA_UtilsStatic.WOLI_COMPLETED_MAIN_STATUS]){
        //Set duration in hours
        if(oneWoli.DurationType == STA_UtilsStatic.WT_TYPE_DURATION_TYPE_MINUTES){
          oneWoli.Duration = (oneWoli.Duration/60.0).round(System.RoundingMode.UP);
        }
        //Store duration
        if(mapWOId_Duration.get(oneWoli.WorkOrderId) != null){
          mapWOId_Duration.put(oneWoli.WorkOrderId, mapWOId_Duration.get(oneWoli.WorkOrderId) + oneWoli.Duration);
          // mapWOId_Duration.get(oneWoli.WorkOrderId) = mapWOId_Duration.get(oneWoli.WorkOrderId) + oneWoli.Duration; --> VSCode said "Expression cannot be assigned"...
        }
        else{
          mapWOId_Duration.put(oneWoli.WorkOrderId, oneWoli.Duration);
        }
      }

      //Set duration on service appointments
      for(ServiceAppointment oneSA : newList){
        // if(mapSANumber_WOId.get(oneSA.AppointmentNumber) != null && mapWOId_Duration.get(mapSANumber_WOId.get(oneSA.AppointmentNumber)) != null){
        if(mapWOId_Duration.get(oneSA.ParentRecordId) != null){
          oneSA.DurationType = STA_UtilsStatic.WT_TYPE_DURATION_TYPE_HOURS;
          oneSA.Duration = mapWOId_Duration.get(oneSA.ParentRecordId);
        }
      }
    }
  }

  /**
   * @description : stop creation of service appointment if estimated labor time = 0
   * @author Vincent RECASENS (Modis) | 11-12-2020
   * @param newMap 
   * @param oldMap 
   **/
  public static void checkEstimatedLaborTime(List<ServiceAppointment> newList){
    Set<Id> parentRecordId = new Set<Id>();
    for (ServiceAppointment oneSA : newList) {
      if (
        oneSA.ParentRecordId.getSObjectType() == Schema.WorkOrder.SObjectType
      ) {
        parentRecordId.add(oneSA.ParentRecordId);
      }
    }

    if (parentRecordId.size() > 0) {
      Map<Id, WorkOrder> mapWo = new Map<Id, WorkOrder>(
        [
          SELECT Id, SMC_Theoritical_duration__c
          FROM WorkOrder
          WHERE Id IN :parentRecordId
        ]
      );
      if (mapWo.size() > 0) {
        for (ServiceAppointment oneSA : newList) {
          if ((mapWo.get(oneSA.ParentRecordId).SMC_Theoritical_duration__c == null) || (mapWo.get(oneSA.ParentRecordId).SMC_Theoritical_duration__c == 0.00)) {
            oneSA.addError(STA_UtilsStatic.SERVICE_APPOINTMENT_ESTIMATED_LABOR_TIME_NULL);
          }
        }
      }
    }
  }
}