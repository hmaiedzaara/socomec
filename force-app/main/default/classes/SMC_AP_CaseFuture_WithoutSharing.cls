/*
---------------------------------------------------------------------
-- - Name          : SMC_AP_CaseFuture_WithoutSharing
-- - Author        : Vincent RECASENS (VR)
-- - Description   : Apex class with Future method and "without sharing" definition
-- Maintenance History:
--
-- Date         Name    Version     Remarks 
-- -----------  ----	------      ---------------------------
-- 01-NOV-2018  (VR)    1.0         Initial version 
---------------------------------------------------------------------
*/
public without sharing class SMC_AP_CaseFuture_WithoutSharing {
  /**
   * @description : fill case QueuInCharge to know which BA work on the case
   * @author Vincent RECASENS (Modis) | 08/04/2020
   * @param newCaseIdToQueueId 
   **/
  @Future
  public static void fillQueueInChargeAfterInsert(
    Map<Id, Id> newCaseIdToQueueId
  ) {
    System.debug(
      LoggingLevel.INFO,
      '>>>>>>SMC_AP_CaseFuture_WithoutSharing -> Method fillQueueInChargeAfterInsert - START'
    );

    Map<Id, List<Case>> ownerIdToNewCaseId = new Map<Id, List<Case>>();
    Map<Id, List<Case>> remakeQueueIdToNewCaseId = new Map<Id, List<Case>>();
    for (Case newCase : [
      SELECT
        Id,
        OwnerId,
        SMC_Expert_Queue__c,
        SMC_Expert_Queue__r.SMC_Queue_ID__c,
        Subject,
        ParentId
      FROM Case
      WHERE Id IN :newCaseIdToQueueId.keySet()
    ]) {
      //If Assignement Rule was played before
      if (
        (newCase.SMC_Expert_Queue__c != null &&
        newCaseIdToQueueId.get(newCase.Id) != null &&
        newCase.SMC_Expert_Queue__r.SMC_Queue_ID__c !=
        newCaseIdToQueueId.get(newCase.Id)) ||
        newCase.OwnerId == null ||
        newCase.OwnerId.getSObjectType() == Schema.User.SObjectType
      ) {
        if (
          remakeQueueIdToNewCaseId.containsKey(
            newCaseIdToQueueId.get(newCase.Id)
          )
        ) {
          remakeQueueIdToNewCaseId.get(newCaseIdToQueueId.get(newCase.Id))
            .add(newCase);
        } else {
          remakeQueueIdToNewCaseId.put(
            newCaseIdToQueueId.get(newCase.Id),
            new List<Case>{ newCase }
          );
        }
      } else {
        if (newCase.OwnerId.getSObjectType() == Schema.Group.SObjectType) {
          if (ownerIdToNewCaseId.containsKey(newCase.OwnerId)) {
            ownerIdToNewCaseId.get(newCase.OwnerId).add(newCase);
          } else {
            ownerIdToNewCaseId.put(newCase.OwnerId, new List<Case>{ newCase });
          }
        }
      }
    }

    Id recordTypeIdAccountCaseTeam = [
      SELECT Id
      FROM RecordType
      WHERE name = :STA_UtilsStatic.RECORDTYPE_ACCOUNT_CASE_TEAM
    ]
    .Id;
    List<Case> caseToUpdate = new List<Case>();
    if (ownerIdToNewCaseId.size() > 0) {
      for (Account oneAccountGroup : [
        SELECT Id, Name, SMC_Queue_ID__c
        FROM Account
        WHERE
          SMC_Queue_ID__c IN :ownerIdToNewCaseId.keySet()
          AND RecordTypeId = :recordTypeIdAccountCaseTeam
      ]) {
        for (
          Case oneCase : ownerIdToNewCaseId.get(oneAccountGroup.SMC_Queue_ID__c)
        ) {
          oneCase.SMC_Expert_Queue__c = oneAccountGroup.Id;
          caseToUpdate.add(oneCase);
        }
      }
    }
    if (remakeQueueIdToNewCaseId.size() > 0) {
      for (Account oneAccountGroup : [
        SELECT Id, Name, SMC_Queue_ID__c
        FROM Account
        WHERE
          Id IN :remakeQueueIdToNewCaseId.keySet()
          AND RecordTypeId = :recordTypeIdAccountCaseTeam
      ]) {
        for (Case oneCase : remakeQueueIdToNewCaseId.get(oneAccountGroup.Id)) {
          oneCase.SMC_Expert_Queue__c = oneAccountGroup.Id;
          oneCase.OwnerId = oneAccountGroup.SMC_Queue_ID__c;
          caseToUpdate.add(oneCase);
        }
      }
    }

    try {
      update caseToUpdate;
    } catch (DMLException dmlException) {
      System.debug(
        LoggingLevel.INFO,
        'ERROR during update --> ' + dmlException
      );
    }

    System.debug(
      LoggingLevel.INFO,
      '>>>>>>SMC_AP_CaseFuture_WithoutSharing -> Method fillQueueInChargeAfterInsert - END'
    );
  }
}