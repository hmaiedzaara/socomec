/*
---------------------------------------------------------------------
-- - Name          : SMC_AP_ManageCaseComment
-- - Author        : Vincent RECASENS (VR)
-- - Description   : Manage Case               
-- Maintenance History:
--
-- Date         Name    Version     Remarks 
-- -----------  ----	------      ---------------------------
-- 29-AUG-2018  LA    	1.1         Add Before Insert method
-- 30-JUL-2018  (VR)    1.0         Initial version 
---------------------------------------------------------------------
*/
public with sharing class SMC_AP_ManageCaseComment {
  /**
   * @description : inform of a new case comment on the case
   * @author Vincent RECASENS (Modis) | 08/04/2020
   * @param newList
   **/
  public static void updateCaseParentId(Map<Id, CaseComment> newMap) {
    Map<Id, Boolean> parentIdFirst = new Map<Id, Boolean>();
    for (Id oneId : newMap.keySet()) {
      CaseComment oneCaseComment = newMap.get(oneId);
      if (Schema.Case.SObjectType == oneCaseComment.ParentId.getSobjectType()) {
        parentIdFirst.put(oneCaseComment.ParentId, false);
      }
    }

    //Controll if Case if "Closed", dont execute update
    if (parentIdFirst.size() > 0) {
      Map<Id, Boolean> parentId = new Map<Id, Boolean>();
      for(Case oneCase : [SELECT Id, Status FROM Case WHERE Id IN :parentIdFirst.keySet()]){
        if(oneCase.Status != STA_UtilsStatic.CASE_STATUS_CLOSED && parentIdFirst.get(oneCase.Id) != null){
          parentId.put(oneCase.Id, parentIdFirst.get(oneCase.Id));
        }
      }
      //Cases is not closed, execute update
      if (parentId.size() > 0) {
        SMC_AP_ManageCase.updateCaseNewObject(parentId, STA_UtilsStatic.COMMENT);
      }
    }
  }

  /**
   * @description : prevent of case comment on closed case
   * @author Vincent RECASENS (Modis) | 08/04/2020
   * @param newList
   **/
  public static void preventUpdateOnClosedCase(List<CaseComment> newList) {
    List<Id> caseIds = new List<Id>();
    Map<Id, Id> commentIdToCaseId = new Map<Id, Id>();
    for (CaseComment oneCaseComment : newList) {
      commentIdToCaseId.put(oneCaseComment.Id, oneCaseComment.ParentId);
    }

    Map<Id, Case> caseMap = new Map<Id, Case>(
      [
        SELECT Id, Status
        FROM Case
        WHERE
          Id IN :commentIdToCaseId.values()
          AND Status = :STA_UtilsStatic.CLOSED
      ]
    );
    for (CaseComment oneCaseComment : newList) {
      if (caseMap.get(commentIdToCaseId.get(oneCaseComment.Id)) != null) {
        oneCaseComment.addError(
          String.escapeSingleQuotes(System.Label.SMC_NoCommentOnClosedCase),
          true
        );
      }
    }
  }

  /**
   * @description : create case comment to store AnswerToCustomer value
   * @author Vincent RECASENS (Modis) | 08/04/2020
   * @param caseIdToAnswerToCustomer
   **/
  public static void addAnswerToCustomer(
    Map<Id, String> caseIdToAnswerToCustomer
  ) {
    List<CaseComment> caseCommentList = new List<CaseComment>();
    for (Id key : caseIdToAnswerToCustomer.keySet()) {
      CaseComment caseComment = new CaseComment();
      caseComment.ParentId = key;
      caseComment.CommentBody = caseIdToAnswerToCustomer.get(key);
      caseComment.IsPublished = true;
      caseCommentList.add(caseComment);
    }
    insert caseCommentList;
  }

  // /**
  //  * @description : add '#jira' for internal comment if checkbox SMC_JIRA_Comment_s__c is check
  //  * @author Vincent RECASENS (Modis) | 14/04/2020
  //  * @param newList
  //  **/
  // public static void addJiraIdentifierIfNeeded(List<CaseComment> newList) {
  //   List<Id> caseIdslist = new List<Id>();
  //   for (CaseComment oneCaseComment : newList) {
  //     caseIdsList.add(oneCaseComment.ParentId);
  //   }
  //   Map<Id, Boolean> mapCaseJiraComment = new Map<Id, Boolean>(); //Just to have a key
  //   for (Case oneCase : [
  //     SELECT Id, SMC_JIRA_Comment_s__c
  //     FROM Case
  //     WHERE ParentId IN :caseIdsList
  //   ]) {
  //     if (oneCase.SMC_JIRA_Comment_s__c) {
  //       mapCaseJiraComment.put(oneCase.Id, oneCase.SMC_JIRA_Comment_s__c);
  //     }
  //   }

  //   for (CaseComment oneCaseComment : newList) {
  //     if (mapCaseJiraComment.get(oneCaseComment.ParentId) != null) {
  //       oneCaseComment.CommentBody = '#jira ' + oneCaseComment.CommentBody;
  //     }
  //   }
  // }
}