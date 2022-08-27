/*
-----------------------------------------------------------------------------------
-- - Name : SMC_AC_Escalation_Process_Components
-- - Author : Vincent RECASENS (VRE)
-- - Description : This class is the Apex controller of the lightning 
                   component SMC_LC_Escalation_Process_Components
--
-- Maintenance History:
--
-- Date         Name   Version     Remarks
-- -----------  ----   -------     ----------------------------
-- 21-MAY-2019  VRE    1.0         Initial Version
------------------------------------------------------------------------------------
*/

public with sharing class SMC_AC_Escalation_Process_Components {
  public class EscalationProcessWrapper {
    // public ProcessInstance processInstance {get;set;}
    public String processInstanceId { get; set; }
    public String processInstanceWorkitemId { get; set; }
    public String targetObjectId { get; set; }
    public String targetObjectName { get; set; }
    public String targetObjectType { get; set; }
    public String submittedByName { get; set; }
    public Datetime createdDate { get; set; }
  }

  /**
   * @description : check user permission
   * @author Vincent RECASENS (Modis) | 10/04/2020
   * @return Boolean
   **/
  @AuraEnabled
  public static Boolean getPermission() {
    System.debug(
      LoggingLevel.INFO,
      '>>>>>> SMC_AC_Escalation_Process_Components : getPermssion - START'
    );

    //Get user permissions
    List<PermissionSetAssignment> pasList = [
      SELECT Assignee.Id, PermissionSet.Id, PermissionSet.Name
      FROM PermissionSetAssignment
      WHERE Assignee.Id = :UserInfo.getUserId()
    ];
    for (PermissionSetAssignment onePas : pasList) {
      if (onePas.PermissionSet.Name == STA_UtilsStatic.BUSINESS_DEVELOPPER) {
        System.debug(
          LoggingLevel.INFO,
          '>>>>>> SMC_AC_Escalation_Process_Components : getPermssion - END with PS'
        );
        return true;
      }
    }

    System.debug(
      LoggingLevel.INFO,
      '>>>>>> SMC_AC_Escalation_Process_Components : getPermssion - END without PS'
    );
    return false;
  }

  /**
   * @description : get informations in according to the LC design
   * @author Vincent RECASENS (Modis) | 10/04/2020
   * @param selectApprovalByDesign
   * @return String
   **/
  @AuraEnabled
  public static String searchApproval(String selectApprovalByDesign) {
    System.debug(
      LoggingLevel.INFO,
      '>>>>>> SMC_AC_Escalation_Process_Components : getAllProcessInstance - START'
    );

    if (selectApprovalByDesign == System.Label.SMC_AllAproval) {
      System.debug(
        LoggingLevel.INFO,
        '>>>>>> SMC_AC_Escalation_Process_Components : getAllProcessInstance - END AllItem'
      );
      return getAllProcessInstance();
    } else if (
      selectApprovalByDesign == System.Label.SMC_Item_To_Approve_Delegated
    ) {
      System.debug(
        LoggingLevel.INFO,
        '>>>>>> SMC_AC_Escalation_Process_Components : getAllProcessInstance - END Deleagted'
      );
      return getProcessInstanceDelegated();
    } else {
      System.debug(
        LoggingLevel.INFO,
        '>>>>>> SMC_AC_Escalation_Process_Components : getAllProcessInstance - END Null'
      );
      return null;
    }
  }

  /**
   * @description : get all approval in 'Pending' status
   * @author Vincent RECASENS (Modis) | 10/04/2020
   * @return String = serialization(List<EscalationProcessWrapper>)
   **/
  @TestVisible
  private static String getAllProcessInstance() {
    //Wrapper
    List<EscalationProcessWrapper> jsonResult = new List<EscalationProcessWrapper>();

    //Get process instance (ApprovalItem)
    Map<Id, ProcessInstance> processInstanceMap = new Map<Id, ProcessInstance>(
      [
        SELECT
          Id,
          TargetObjectId,
          TargetObject.Name,
          TargetObject.Type,
          SubmittedById,
          SubmittedBy.Name,
          SubmittedBy.SMC_User_Subsidiary__c,
          CreatedDate,
          CreatedBy.Name
        FROM ProcessInstance
        WHERE Status = :STA_UtilsStatic.STATUS_PENDING
      ]
    );
    processInstanceMap = checkTargetObjectId(processInstanceMap);
    Map<Id, ProcessInstanceWorkitem> processInstanceWorkitemMap = new Map<Id, ProcessInstanceWorkitem>(
      [
        SELECT Id, ProcessInstanceId
        FROM ProcessInstanceWorkitem
        WHERE ProcessInstanceId IN :processInstanceMap.keySet()
      ]
    );

    Map<Id, Id> mapProcessInstanceIdToProcessInstanceWorkitemId = new Map<Id, Id>();
    for (
      ProcessInstanceWorkitem oneProcessInstanceWorkitem : processInstanceWorkitemMap.values()
    ) {
      mapProcessInstanceIdToProcessInstanceWorkitemId.put(
        oneProcessInstanceWorkitem.ProcessInstanceId,
        oneProcessInstanceWorkitem.Id
      );
    }

    //Fill wrapper
    for (ProcessInstance oneProcessInstance : processInstanceMap.values()) {
      EscalationProcessWrapper wrapperItem = new EscalationProcessWrapper();
      wrapperItem.processInstanceId = oneProcessInstance.Id;
      wrapperItem.processInstanceWorkitemId = mapProcessInstanceIdToProcessInstanceWorkitemId.get(
        oneProcessInstance.Id
      );
      wrapperItem.targetObjectId = oneProcessInstance.TargetObjectId;
      wrapperItem.targetObjectName = oneProcessInstance.TargetObject.Name;
      wrapperItem.targetObjectType = oneProcessInstance.TargetObject.Type;
      wrapperItem.submittedByName = oneProcessInstance.SubmittedBy.Name;
      wrapperItem.createdDate = oneProcessInstance.CreatedDate;
      jsonResult.add(wrapperItem);
    }

    return JSON.serialize(jsonResult);
  }

  /**
   * @description : get approval delegated to the current user
   * @author Vincent RECASENS (Modis) | 10/04/2020
   * @return String = serialization(List<EscalationProcessWrapper>)
   **/
  public static String getProcessInstanceDelegated() {
    List<Id> userIds = new List<Id>();
    for (User oneUser : [
      SELECT Id
      FROM User
      WHERE DelegatedApproverId = :UserInfo.getUserId()
    ]) {
      userIds.add(oneUser.Id);
    }

    //Wrapper
    List<EscalationProcessWrapper> jsonResult = new List<EscalationProcessWrapper>();
    //Get process instance (ApprovalItem)
    Map<Id, ProcessInstanceWorkitem> processInstanceWorkitems = new Map<Id, ProcessInstanceWorkitem>(
      [
        SELECT
          Id,
          OriginalActorId,
          OriginalActor.Name,
          ActorId,
          ProcessInstanceId
        FROM ProcessInstanceWorkitem
        WHERE ActorId IN :userIds
      ]
    );
    List<Id> processInstanceIds = new List<Id>();
    for (
      ProcessInstanceWorkitem oneProcessInstanceWorkitem : processInstanceWorkitems.values()
    ) {
      processInstanceIds.add(oneProcessInstanceWorkitem.ProcessInstanceId);
    }

    Map<Id, ProcessInstance> processInstances = new Map<Id, ProcessInstance>(
      [
        SELECT
          Id,
          SubmittedById,
          SubmittedBy.Name,
          SubmittedBy.SMC_User_Subsidiary__c,
          TargetObjectId,
          TargetObject.Name,
          TargetObject.Type,
          CreatedDate,
          CreatedBy.Name
        FROM ProcessInstance
        WHERE Id IN :processInstanceIds
      ]
    );
    processInstances = checkTargetObjectId(processInstances);

    //Fill wrapper
    for (Id oneProcessInstanceWorkitemId : processInstanceWorkitems.keySet()) {
      ProcessInstanceWorkitem oneProcessInstanceWorkitem = processInstanceWorkitems.get(
        oneProcessInstanceWorkitemId
      );
      if (
        processInstances.get(oneProcessInstanceWorkitem.ProcessInstanceId) !=
        null
      ) {
        ProcessInstance oneProcessInstance = processInstances.get(
          oneProcessInstanceWorkitem.ProcessInstanceId
        );

        EscalationProcessWrapper wrapperItem = new EscalationProcessWrapper();
        wrapperItem.processInstanceId = oneProcessInstance.Id;
        wrapperItem.processInstanceWorkitemId = oneProcessInstanceWorkitemId;
        wrapperItem.targetObjectId = oneProcessInstance.TargetObjectId;
        wrapperItem.targetObjectName = oneProcessInstance.TargetObject.Name;
        wrapperItem.targetObjectType = oneProcessInstance.TargetObject.Type;
        wrapperItem.submittedByName = oneProcessInstanceWorkitem.OriginalActor.Name;
        wrapperItem.createdDate = oneProcessInstance.CreatedDate;
        jsonResult.add(wrapperItem);
      }
    }

    return JSON.serialize(jsonResult);
  }

  /**
   * @description : check if approval is apply to a quote and if the user can access to it
   * @author Vincent RECASENS (Modis) | 10/04/2020
   * @param processInstances
   * @return Map<Id, ProcessInstance>
   **/
  @TestVisible
  private static Map<Id, ProcessInstance> checkTargetObjectId(
    Map<Id, ProcessInstance> processInstances
  ) {
    String userSubsidiary = [
      SELECT SMC_User_Subsidiary__c
      FROM User
      WHERE Id = :UserInfo.getUserId()
    ]
    .SMC_User_Subsidiary__c;
    Map<Id, ProcessInstance> processInstancesToReturn = new Map<Id, ProcessInstance>();
    for (Id oneId : processInstances.keySet()) {
      ProcessInstance theProcessInstance = processInstances.get(oneId);
      if (
        theProcessInstance.TargetObjectId.getSObjectType() ==
        Schema.Quote.SObjectType /* && userSubsidiary == theProcessInstance.SubmittedBy.SMC_User_Subsidiary__c*/
      ) {
        processInstancesToReturn.put(oneId, theProcessInstance);
      }
    }
    return processInstancesToReturn;
  }
}