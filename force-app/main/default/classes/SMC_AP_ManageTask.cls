/*
---------------------------------------------------------------------
-- - Name          : SMC_AP_ManageTask
-- - Author        : Guillaume BONNET
-- - Description   : Manage Task               
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  ---------------------------------------
-- xx-Mars-2018 DOS    1.0     Initial version
----------------------------------------------------------------------
*/

public without sharing class SMC_AP_ManageTask {
  /**
   * @description : close reminder task from flow
   * @author Vincent RECASENS (Modis) | 01-20-2021
   * @param oppList
   **/
  @InvocableMethod(label='Update Close Reminder Task')
  public static void updateClosedReminderTask(List<Opportunity> oppList) {
    Set<Id> oppIds = new Set<Id>();
    for (Opportunity oneOpp : oppList) {
      oppIds.add(oneOpp.Id);
    }
    List<Task> taskToUpdate = new List<Task>();
    List<String> recordList = new List<String>();
    for (Task oneTask : [
      SELECT Id, Subject, Status
      FROM Task
      WHERE WhatId IN :oppIds AND Type = 'Reminder'
    ]) {
      oneTask.Status = STA_UtilsStatic.COMPLETED;
      taskToUpdate.add(oneTask);
      recordList.add(oneTask.Subject);
    }

    if (taskToUpdate.size() > 0) {
      try {
        update taskToUpdate;
      } catch (DMLException dmlE) {
        System.debug(
          'ERROR : Update Closed Reminder Task --> ' + dmlE.getMessage()
        );
        SMC_UTIL_Methods_Batch.createErrorLog(
          new List<DMLException>{ dmlE },
          'Update Closed Reminder Task',
          null,
          'update List<Task>()',
          null,
          recordList
        );
        if (Test.isRunningTest()) {
          throw dmlE;
        }
      }
    }
  }

  /**
   * @description : prevent link beteween task and account type Group Consolidated
   * @author Vincent RECASENS (Modis) | 08/04/2020
   * @param tasksToCheck
   **/
  // public static void isParentAccountGroupConsolidated(List<Task> tasksToCheck) {
  //   System.debug(
  //     LoggingLevel.INFO,
  //     '## >>> SMC_AP_ManageTask isParrentAccountGroupConsolidated(List<Task> TasksToCheck):START <<< ##'
  //   );

  //   List<Id> relatedAccountId = new List<Id>();
  //   for (Task elem : tasksToCheck) {
  //     relatedAccountId.add(elem.WhatId);
  //   }
  //   Map<ID, Account> relatedAccount = new Map<ID, Account>(
  //     [SELECT Id, RecordTypeId FROM Account WHERE Id IN :relatedAccountId]
  //   );

  //   Id groupConsolidatedRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
  //     .get(STA_UtilsStatic.RECORDTYPE_ACCOUNT_GROUP_CONSOLIDATED_DEVNAME)
  //     .getRecordTypeId();
  //   for (Task elem : tasksToCheck) {
  //     if (
  //       relatedAccount.get(elem.WhatId) != null &&
  //       relatedAccount.get(elem.WhatId).RecordTypeId ==
  //       groupConsolidatedRecordTypeId
  //     ) {
  //       elem.addError(System.Label.SMC_GroupConsolidatedCantBeLinkToTask, true);
  //     }
  //   }

  //   System.debug(
  //     LoggingLevel.INFO,
  //     '## >>> SMC_AP_ManageTask isParrentAccountGroupConsolidated(List<Task> TasksToCheck):END <<< ##'
  //   );
  // }
}