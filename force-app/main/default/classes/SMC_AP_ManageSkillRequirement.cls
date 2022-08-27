/*
--------------------------------------------------------------------------------------
-- - Name          : SMC_AP_ManageSkillRequirement
-- - Author        : Vincent RECASENS (VRE - Modis)
-- - Description   : Manage SkillRequirement
-- - Project       : Socomec
--
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  -------------------------------------------------------
-- 24-MAY-2019  VR    1.0     Initial version
--------------------------------------------------------------------------------------
*/

public with sharing class SMC_AP_ManageSkillRequirement {
  /**
   * @description : add new skill on work order without duplication
   * @author Vincent RECASENS (Modis) | 08/04/2020
   * @param newList 
   **/
  public static void replySkillRequirementOnWorkOrder(
    List<SkillRequirement> newList
  ) {
    Map<Id, Id> skillIdsToWorkOrderLineItemIds = new Map<Id, Id>();
    for (SkillRequirement oneSkillRequirement : newList) {
      if (
        oneSkillRequirement.RelatedRecordId.getSObjectType() ==
        Schema.WorkOrderLineItem.SobjectType
      ) {
        skillIdsToWorkOrderLineItemIds.put(
          oneSkillRequirement.Id,
          oneSkillRequirement.RelatedRecordId
        );
      }
    }

    if (skillIdsToWorkOrderLineItemIds.size() > 0) {
      Map<Id, Id> workOrderLineItemIdsToWorkOrderIds = new Map<Id, Id>();
      for (WorkOrderLineItem oneWorkOrderLineItem : [
        SELECT Id, WorkOrderId
        FROM WorkOrderLineItem
        WHERE Id IN :skillIdsToWorkOrderLineItemIds.values()
      ]) {
        workOrderLineItemIdsToWorkOrderIds.put(
          oneWorkOrderLineItem.Id,
          oneWorkOrderLineItem.WorkOrderId
        );
      }

      Map<Id, Id> skillIdsToWorkOrderIdsControl = new Map<Id, Id>();
      Map<String, SkillRequirement> newSkillRequirementLinkToWorkOrder = new Map<String, SkillRequirement>(); //key = 'SkillId-RelatedRecordId'
      //TODO add guard condition to not duplicate skills work 4407
      for (SkillRequirement oneSkillRequirement : newList) {
        Id workOrderId = workOrderLineItemIdsToWorkOrderIds.get(
          skillIdsToWorkOrderLineItemIds.get(oneSkillRequirement.Id)
        );
        SkillRequirement skillRequirementForWorkOrder = new SkilLRequirement();
        skillRequirementForWorkOrder.SkillId = oneSkillRequirement.SkillId;
        skillRequirementForWorkOrder.SkillLevel = oneSkillRequirement.SkillLevel;
        skillRequirementForWorkOrder.RelatedRecordId = workOrderId;
        newSkillRequirementLinkToWorkOrder.put(
          oneSkillRequirement.SkillId +
          '-' +
          workOrderId,
          skillRequirementForWorkOrder
        );
        skillIdsToWorkOrderIdsControl.put(
          oneSkillRequirement.SkillId,
          workOrderId
        );
      }

      // Control the duplication of SkillRequirement on WorkOrder and keep the higher SkillLevel
      List<SkillRequirement> toDeleteSkillRequirement = new List<SkillRequirement>();
      for (SkillRequirement oneSR : [
        SELECT SkillId, RelatedRecordId, SkillLevel
        FROM SkillRequirement
        WHERE
          SkillId IN :skillIdsToWorkOrderIdsControl.keySet()
          AND RelatedRecordId IN :skillIdsToWorkOrderIdsControl.values()
      ]) {
        if (
          skillIdsToWorkOrderIdsControl.get(oneSR.SkillId) ==
          oneSR.RelatedRecordId
        ) {
          if (
            oneSR.SkillLevel >
            newSkillRequirementLinkToWorkOrder.get(
                oneSR.SkillId +
                '-' +
                oneSR.RelatedRecordId
              )
              .SkillLevel
          ) {
            newSkillRequirementLinkToWorkOrder.remove(
              oneSR.SkillId +
              '-' +
              oneSR.RelatedRecordId
            );
          } else {
            toDeleteSkillRequirement.add(oneSR);
          }
        }
      }

      if (toDeleteSkillRequirement.size() > 0)
        delete toDeleteSkillRequirement;

      if (newSkillRequirementLinkToWorkOrder.size() > 0)
        insert newSkillRequirementLinkToWorkOrder.values();
    }
    // else{
    //     System.debug(LoggingLevel.INFO, 'AggregateQueries LIMIT : ' + Limits.getLimitAggregateQueries());
    //     System.debug(LoggingLevel.INFO, 'AggregateQueries : ' + Limits.getAggregateQueries());
    //     System.debug(LoggingLevel.INFO, 'AsyncCalls LIMIT : ' + Limits.getAsyncCalls());
    //     System.debug(LoggingLevel.INFO, 'AsyncCalls : ' + Limits.getLimitAsyncCalls());
    //     System.debug(LoggingLevel.INFO, 'Callouts LIMIT : ' + Limits.getLimitCallouts());
    //     System.debug(LoggingLevel.INFO, 'Callouts : ' + Limits.getCallouts());
    //     System.debug(LoggingLevel.INFO, 'CPUTime LIMIT : ' + Limits.getLimitCpuTime());
    //     System.debug(LoggingLevel.INFO, 'CPUTime : ' + Limits.getCpuTime());
    //     System.debug(LoggingLevel.INFO, 'DMLRows LIMIT : ' + Limits.getLimitDMLRows());
    //     System.debug(LoggingLevel.INFO, 'DMLRows : ' + Limits.getDMLRows());
    //     System.debug(LoggingLevel.INFO, 'DMLStatements LIMIT : ' + Limits.getLimitDMLStatements());
    //     System.debug(LoggingLevel.INFO, 'DMLStatements : ' + Limits.getDMLStatements());
    //     System.debug(LoggingLevel.INFO, 'EmailInvocation LIMIT : ' + Limits.getLimitEmailInvocations());
    //     System.debug(LoggingLevel.INFO, 'EmailInvocation : ' + Limits.getEmailInvocations());
    //     System.debug(LoggingLevel.INFO, 'EmailInvocation LIMIT : ' + Limits.getLimitEmailInvocations());
    //     System.debug(LoggingLevel.INFO, 'EmailInvocation : ' + Limits.getEmailInvocations());
    //     System.debug(LoggingLevel.INFO, 'FutureCall LIMIT : ' + Limits.getLimitFutureCalls());
    //     System.debug(LoggingLevel.INFO, 'FutureCall : ' + Limits.getFutureCalls());
    //     System.debug(LoggingLevel.INFO, 'HeapSize LIMIT : ' + Limits.getLimitHeapSize());
    //     System.debug(LoggingLevel.INFO, 'HeapSize : ' + Limits.getHeapSize());
    //     System.debug(LoggingLevel.INFO, 'Queries LIMIT : ' + Limits.getLimitQueries());
    //     System.debug(LoggingLevel.INFO, 'Queries : ' + Limits.getQueries());
    //     System.debug(LoggingLevel.INFO, 'Queries LIMIT : ' + Limits.getLimitQueries());
    //     System.debug(LoggingLevel.INFO, 'Queries : ' + Limits.getQueries());
    //     System.debug(LoggingLevel.INFO, 'QueryLocatorRows LIMIT : ' + Limits.getLimitQueryLocatorRows());
    //     System.debug(LoggingLevel.INFO, 'QueryLocatorRows : ' + Limits.getQueryLocatorRows());
    //     System.debug(LoggingLevel.INFO, 'QueryRows LIMIT : ' + Limits.getLimitQueryRows());
    //     System.debug(LoggingLevel.INFO, 'QueryRows : ' + Limits.getQueryRows());
    //     System.debug(LoggingLevel.INFO, 'QueueableJobs LIMIT : ' + Limits.getLimitQueueableJobs());
    //     System.debug(LoggingLevel.INFO, 'QueueableJobs : ' + Limits.getQueueableJobs());
    //     System.debug(LoggingLevel.INFO, 'SOSL LIMIT : ' + Limits.getLimitSoslQueries());
    //     System.debug(LoggingLevel.INFO, 'SOSL : ' + Limits.getSoslQueries());
    // }
  }
}