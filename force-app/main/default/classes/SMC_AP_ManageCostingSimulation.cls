/*
---------------------------------------------------------------------
-- - Name          : SMC_AP_ManageCostingSimulation
-- - Author        : Denis PHAM - MODIS
-- - Description   : Manage Quote               
-- - Maintenance History:
--
-- Date         Name                Version  Remarks
-- -----------  ----                -------  -------------------------------------------------------
-- 19-JUL-22    Denis PHAM          1.0      Initial version
--------------------------------------------------------------------------------------
*/

public with sharing class SMC_AP_ManageCostingSimulation {
  
    /**
          3 step to send notification for an approval ending :
              - setProcessInstanceIdField
              - sendNotificationForApprovalEnding
              - resetProcessInstanceIdField
    **/
    /**
     * @description : Set Costing Simulation TECH_SMC_Process_Instance_Id__c
     * @author Denis PHAM (Modis) | 19/07/2022
     * @param newMap
     * @param iStestingThisMethod
     **/
    public static void setProcessInstanceIdField(
      Map<Id, SMC_Costing_Simulation__c> newMap,
      Boolean iStestingThisMethod
    ) {
      //Check if Costing Simulation are in approval ending
      Map<Id, SMC_Costing_Simulation__c> costingSimulationWithApprovalEnded = new Map<Id, SMC_Costing_Simulation__c>();
      for (SMC_Costing_Simulation__c oneCS : newMap.values()) {
        if (
          oneCS.SMC_Approval_Status__c == STA_UtilsStatic.STATUS_APPROVAL_PENDING &&
          oneCS.TECH_SMC_Process_Instance_Id__c == null
        ) {
            costingSimulationWithApprovalEnded.put(oneCS.Id, oneCS);
        }
      }
  
      if (costingSimulationWithApprovalEnded.size() > 0) {
        //Get ProcessInstanceId
        List<ProcessInstance> processInstanceList = new List<ProcessInstance>();
        processInstanceList = [
          SELECT Id, TargetObjectId
          FROM ProcessInstance
          WHERE TargetObjectId IN :costingSimulationWithApprovalEnded.keySet()
          ORDER BY CreatedDate DESC
        ];
  
        //Set field
        Set<Id> targetIdHasAlreadyUpdated = new Set<Id>();
        for (ProcessInstance oneProcessInstance : processInstanceList) {
          if (
            newMap.get(oneProcessInstance.TargetObjectId) != null &&
            !targetIdHasAlreadyUpdated.contains(oneProcessInstance.TargetObjectId)
          ) {
            newMap.get(oneProcessInstance.TargetObjectId)
              .TECH_SMC_Process_Instance_Id__c = oneProcessInstance.Id;
            targetIdHasAlreadyUpdated.add(oneProcessInstance.TargetObjectId);
          }
        }
      }
  
      if (Test.isRunningTest() && iStestingThisMethod) {
        update newMap.values();
      }
    }
  
    /**
     * @description : Send notification for approval ending
     * @author Denis PHAM (Modis) | 19/07/2022
     * @param newMap
     * @param oldMap
     **/
    public static void sendNotificationForApprovalEnding(
      Map<Id, SMC_Costing_Simulation__c> newMap,
      Map<Id, SMC_Costing_Simulation__c> oldMap
    ) {
      //Check if Quotes are in approval ending
      Map<Id, SMC_Costing_Simulation__c> processInstanceIdWithApprovalEnded = new Map<Id, SMC_Costing_Simulation__c>();
      Set<Id> resetCS = new Set<Id>();
      for (SMC_Costing_Simulation__c oneCS : newMap.values()) {
        if (
          oneCS.TECH_SMC_Process_Instance_Id__c != null &&
          oneCS.SMC_Approval_Status__c != null &&
          oneCS.SMC_Approval_Status__c != STA_UtilsStatic.STATUS_APPROVAL_PENDING &&
          oldMap.get(oneCS.Id).SMC_Approval_Status__c == STA_UtilsStatic.STATUS_APPROVAL_PENDING
        ) {
          processInstanceIdWithApprovalEnded.put(oneCS.TECH_SMC_Process_Instance_Id__c, oneCS);
          resetCS.add(oneCS.Id);
        }
      }
  
      //Get ProcessInstanceStep for redirection
      List<ProcessInstanceStep> processInstanceStepList = new List<ProcessInstanceStep>();
      processInstanceStepList = [
        SELECT Id, ProcessInstanceId, ProcessInstance.TargetObject.Id, CreatedDate
        FROM ProcessInstanceStep
        WHERE ProcessInstanceId IN :processInstanceIdWithApprovalEnded.keySet()
        ORDER BY CreatedDate DESC
      ];
      if (processInstanceIdWithApprovalEnded.size() > 0) {
        Set<Id> postAlreadySend = new Set<Id>();
        for (
          ProcessInstanceStep oneProcessInstanceStep : processInstanceStepList
        ) {
          //Check to send only one email
          if (
            !postAlreadySend.contains(
              oneProcessInstanceStep.ProcessInstance.TargetObject.Id
            )
          ) {
            SMC_Costing_Simulation__c theCostingSimulation = processInstanceIdWithApprovalEnded.get(
              oneProcessInstanceStep.ProcessInstanceId
            );
            Map<String, Object> variablesMap = new Map<String, Object>();
            variablesMap.put(STA_UtilsStatic.THE_COSTING_SIMULATION, theCostingSimulation);
            variablesMap.put(
              STA_UtilsStatic.THE_PROCESS_INSTANCE_ID,
              theCostingSimulation.TECH_SMC_Process_Instance_Id__c
            );
            //Build message in according to the approval status
            if (
              theCostingSimulation.SMC_Approval_Status__c == STA_UtilsStatic.STATUS_APPROVED
            ) {
              variablesMap.put(
                STA_UtilsStatic.MESSAGE,
                'The costing simulation ' +
                theCostingSimulation.Name +
                ' was approved. See the approval here : https://' +
                URL.getSalesforceBaseUrl().getHost() +
                '/lightning/r/ProcessInstanceStep/' +
                oneProcessInstanceStep.Id +
                '/view'
              );
            } else if (
              theCostingSimulation.SMC_Approval_Status__c == STA_UtilsStatic.STATUS_REJECTED
            ) {
              variablesMap.put(
                STA_UtilsStatic.MESSAGE,
                'The costing simulation ' +
                theCostingSimulation.Name +
                ' was rejected. See the approval here : https://' +
                URL.getSalesforceBaseUrl().getHost() +
                '/lightning/r/ProcessInstanceStep/' +
                oneProcessInstanceStep.Id +
                '/view'
              );
            }
            Flow.Interview.SMC_Costing_Simulation_Approval_Notification postChatterFlow = new Flow.Interview.SMC_Costing_Simulation_Approval_Notification(
              variablesMap
            );
            postChatterFlow.start();
  
            postAlreadySend.add(
              oneProcessInstanceStep.ProcessInstance.TargetObject.Id
            );
          }
        }
  
        resetProcessInstanceIdField(resetCS);
      }
    }
  
    /**
     * @description : Reset the field TECH_SMC_Process_Instance_Id__c
     * @author Denis PHAM (Modis) | 19/07/2022
     * @param costingSimulationIds
     **/
    @Future
    public static void resetProcessInstanceIdField(Set<Id> costingSimulationIds) {
      List<SMC_Costing_Simulation__c> costingSimulations = new List<SMC_Costing_Simulation__c>();
      costingSimulations = [
        SELECT Id, TECH_SMC_Process_Instance_Id__c
        FROM SMC_Costing_Simulation__c
        WHERE Id IN :costingSimulationIds
      ];
      for (SMC_Costing_Simulation__c oneCS : costingSimulations) {
        oneCS.TECH_SMC_Process_Instance_Id__c = null;
      }
  
      update costingSimulations;
    }
  
  
    /**
     * @description : Used to set the rigth user if a delegated user approve/reject/cancel the approval
     * @author Denis PHAM (Modis) | 19/07/2022
     * @param newMap
     * @param oldMap
     **/
    public static void checkApprovalInformations(
      Map<Id, SMC_Costing_Simulation__c> newMap,
      Map<Id, SMC_Costing_Simulation__c> oldMap
    ) {
      //Sort Quote in needed
      Map<Id, Id> assignedApprvalIdToCsId = new Map<Id, Id>();
      for (Id oneCSId : newMap.keySet()) {
        SMC_Costing_Simulation__c newCostingSimulation = newMap.get(oneCSId);
        SMC_Costing_Simulation__c oldCostingSimulation = oldMap.get(oneCSId);
        if (
          newCostingSimulation.SMC_Approval_Level_Requested__c != null &&
          (oldCostingSimulation.SMC_Approval_Level_Requested__c == null ||
          (newCostingSimulation.SMC_Approval_Level_Requested__c == oldCostingSimulation.SMC_Approval_Level_Requested__c &&
          newCostingSimulation.TECH_SMC_Next_Approver_Id__c != oldCostingSimulation.TECH_SMC_Next_Approver_Id__c))
        ) {
          if (
            oldCostingSimulation.SMC_Approval_Level_Requested__c == null &&
            newCostingSimulation.SMC_Approval_Level_Requested__c != null
          ) {
            newCostingSimulation.SMC_Approval_Level_Validated__c = 0;
            newCostingSimulation.SMC_Next_Approver__c = newCostingSimulation.CreatedById;
          } else {
            assignedApprvalIdToCsId.put(newCostingSimulation.SMC_Next_Approver__c, oneCSId);
          }
        }
      }
  
      //Bypass method
      if (assignedApprvalIdToCsId.size() == 0) {
        return;
      }
  
      for (User oneUser : [
        SELECT Id, Name, SMC_Approval_Level__c
        FROM User
        WHERE Id IN :assignedApprvalIdToCsId.keySet()
      ]) {
        newMap.get(assignedApprvalIdToCsId.get(oneUser.Id)).SMC_Approval_Level_Validated__c = oneUser.SMC_Approval_Level__c;
        newMap.get(assignedApprvalIdToCsId.get(oneUser.Id)).SMC_Next_Approver__c = newMap.get(assignedApprvalIdToCsId.get(oneUser.Id)).TECH_SMC_Next_Approver_Id__c;
      }
  
      if (Test.isRunningTest()) {
        update newMap.values();
      }
    }
}