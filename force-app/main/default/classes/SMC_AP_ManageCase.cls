/*
---------------------------------------------------------------------
-- - Name          : SMC_AP_ManageCase
-- - Author        : Vincent RECASENS (VR)
-- - Description   : Manage Case               
-- Maintenance History:
--
-- Date         Name    Version     Remarks 
-- -----------  ----	------      ---------------------------
-- 27-JUL-2018  (VR)    1.0         Initial version 
-- 24-JAN-2019  (VR)    1.1         Review createForAnotherUser + Add getERPData
-- 18-MAR-2019  (VR)    1.2         Add createCimsaVisit 
-- 21-NOV-2019  (VR)    1.3         Add PAD.Bypass on update in "caseAssignmentRuleFromCommunity" and control origin
---------------------------------------------------------------------
*/
public without sharing class SMC_AP_ManageCase {

  /**
   * @description : flag elmt (Email/Attachment/CaseComment) on the case
   * @author Vincent RECASENS (Modis) | 08/04/2020
   * @param casesIdToUpdate
   * @param newObject
   * @return Boolean
   **/
  public static Boolean updateCaseNewObject(
    Map<Id, Boolean> casesIdToUpdate,
    String newObject
  ) {
    //We received a map "casesIdToUpdate" to request cases HERE
    List<Case> cases = new List<Case>();
    cases = [
      SELECT
        Id,
        OwnerId,
        SMC_New_Email_Flag__c,
        SMC_New_Attachment_Flag__c,
        SMC_New_Comment_Flag__c
      FROM Case
      WHERE Id IN :casesIdToUpdate.keySet()
    ];

    //If it's technical user, don't switch flags
    Id userId = UserInfo.getUserId();
    SF_Technical_User__mdt technicalUser = [
      SELECT UserId__c, Username__c
      FROM SF_Technical_User__mdt
      WHERE Username__c = :STA_UtilsStatic.TECHNICAL_USER_SOC1
    ];
    if (userId != technicalUser.UserId__c) {
      for (Case oneCase : cases) {
        //If current User if the case owner, don't switch flag
        if (userId == oneCase.OwnerId) {
          break;
        } else {
          if (newObject == STA_UtilsStatic.EMAIL) {
            oneCase.SMC_New_Email_Flag__c = true;
            for (Id caseId : casesIdToUpdate.keySet()) {
              if (caseId == oneCase.Id) {
                if (casesIdToUpdate.get(caseId)) {
                  oneCase.SMC_New_Attachment_Flag__c = true;
                  System.debug(
                    LoggingLevel.INFO,
                    'There is an attachment --> ' +
                    STA_UtilsStatic.CASE_UPDATE_CONTENT_DOCUMENT_LINK
                  );
                }
                break;
              }
            }
          } else if (newObject == STA_UtilsStatic.COMMENT) {
            oneCase.SMC_New_Comment_Flag__c = true;
          } else if (newObject == STA_UtilsStatic.CONTENT_DOCUMENT_LINK) {
            oneCase.SMC_New_Attachment_Flag__c = true;
          }
        }
      }
    }

    try {
      update cases;
      //CustomNotif : mentionUser = Customer / Target = Case
    } catch (DmlException dmlException) {
      System.debug(
        LoggingLevel.INFO,
        'ERROR <<SMC_AP_ManageCase.updateCaseNewObject>> : Exception --> ' +
        dmlException
      );
      return false;
    }
    return true;
  }


  /***************************** USED TO REASIGNMENT *****************************/
  // Need to assign Case to SOC1 to let user insert CaseShare beteween him and the Case
  // CaseShare to let user see cases during update
  // During reassignment rule, standard user lose the read permission on the case and the update crash
  // This insert let user do the case update
  /**
   * @description : launch assignment rule
   * @author Vincent RECASENS (Modis) | 08/04/2020
   * @param newList
   * @return Boolean
   **/
  public static Boolean caseAssignmentRuleFromCommunity(Set<Id> newCaseIds) {
    //Set share Read to current user
      Id teamRoleCaseCreator = [SELECT Id FROM CaseTeamRole WHERE Name = :STA_UtilsStatic.CREATOR].Id;
      List<CaseTeamMember> ctmList = new List<CaseTeamMember>();
     for (Id oneCaseId : newCaseIds) {
      //DML Option
      CaseTeamMember newCTM = new CaseTeamMember();
      newCTM.ParentId = oneCaseId;
      newCTM.MemberId = UserInfo.getUserId();
      newCTM.TeamRoleId = teamRoleCaseCreator;
      ctmList.add(newCTM);
     }
     insert ctmList;
      

    //Set option to reassign Case to the rigth Queue
    Database.DMLOptions dmo = new Database.DMLOptions();
    dmo.AssignmentRuleHeader.useDefaultRule = true;
    List<Case> cases = new List<Case>();
    cases = [SELECT Id, Origin, OwnerId, RecordTypeId FROM Case WHERE Id IN :newCaseIds];
    for (Case oneCase : cases) {
      //DML Option
      oneCase.setOptions(dmo);
    }

    try {
      //Bypass trigger cause execute Trigger.Update before finish Trigger.Insert
      PAD.ApexForcedBypass.add(STA_UtilsStatic.CLASS_CASE_MANAGEMENT);
      update cases;
      PAD.ApexForcedBypass.remove(STA_UtilsStatic.CLASS_CASE_MANAGEMENT);
        
      return true;
    } catch (DmlException dmlException) {
      System.debug(
        LoggingLevel.INFO,
        'ERROR <<SMC_AP_ManageCase.caseAssignmentRuleFromCommunity>> : Exception --> ' +
        dmlException
      );
      return false;
    }
  }
  /***************************** USED TO REASIGNMENT *****************************/

  /**
   * @description : callout to find product informations from case serial number
   * @author Vincent RECASENS (Modis) | 08/04/2020
   * @param newList
   * @param oldMap
   * @param isInsert
   **/
  public static void updateCasesProductInfo(
    List<Case> newList,
    Map<Id, Case> oldMap,
    Boolean isInsert
  ) {
    Set<Id> caseIds = new Set<Id>();
    for (Case c : newList) {
      if (
        (isInsert && c.SMC_Serial_Number__c != null) ||
        (!isInsert &&
        oldMap.get(c.Id) != null &&
        c.SMC_Serial_Number__c != oldMap.get(c.Id).SMC_Serial_Number__c)
      ) {
        caseIds.add(c.Id);
      }
    }

    if (caseIds.size() > 0) {
      SMC_AP_CaseFuture.updateCasesProductInfo(caseIds, isInsert);
    }
  }

  /**
   * @description : search asset from case serial number to link the case to the product
   * @author Vincent RECASENS (Modis) | 08/04/2020
   * @param newList
   * @param oldMap
   * @param isInsert
   **/
  public static void getProductInfoFromSerialNumber(
    List<Case> newCase,
    Map<Id, Case> oldMap
  ) {
    System.debug(LoggingLevel.INFO, 'getProductInfoFromSerialNumber START');
    List<String> serialNumberList = new List<String>();
    for (Case oneCase : newCase) {
      if (
        oneCase.ProductId == null &&
        oneCase.SMC_Serial_Number__c != null && 
        oneCase.SMC_Serial_Number__c != '' &&
        (oldMap == null ||
        (oldMap != null &&
        oneCase.SMC_Serial_Number__c !=
        oldMap.get(oneCase.Id).SMC_Serial_Number__c))
      ) {
        serialNumberList.add(oneCase.SMC_Serial_Number__c);
      }
    }

    Map<String, Asset> assetNameToProduct2Id = new Map<String, Asset>();
    if (serialNumberList.size() > 0) {
      Id recordTypeSingleAsset = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName()
        .get(STA_UtilsStatic.RECORDTYPE_ASSET)
        .getRecordTypeId();
      for (Asset oneAsset : [
        SELECT Id, SerialNumber, Product2Id
        FROM Asset
        WHERE
          SerialNumber IN :serialNumberList 
          AND SerialNumber != '' 
          AND SerialNumber != NULL
          AND RecordTypeId = :recordTypeSingleAsset
      ]) {
        assetNameToProduct2Id.put(oneAsset.SerialNumber.toLowerCase(), oneAsset);
      }
    }

    if (assetNameToProduct2Id.size() > 0) {
      for (Case oneCase : newCase) {
        if (assetNameToProduct2Id.get(oneCase.SMC_Serial_Number__c.toLowerCase()) != null) {
          Asset theAsset = assetNameToProduct2Id.get(
            oneCase.SMC_Serial_Number__c.toLowerCase()
          );
          oneCase.AssetId = theAsset.Id;
          oneCase.ProductId = theAsset.Product2Id;
        }
      }
    }

    System.debug(LoggingLevel.INFO, 'getProductInfoFromSerialNumber END');
  }

  /**
   * @description : fill case QueuInCharge to know which BA work on the case
   * @author Vincent RECASENS (Modis) | 08/04/2020
   * @param newMap
   * @param isInsert
   * @return List<Case>
   **/
  public static List<Case> fillQueueInCharge(
    Map<Id, Case> newMap,
    Boolean isInsert
  ) {
    System.debug(
      LoggingLevel.INFO,
      '>>>>>>SMC_AP_ManageCase -> Method fillQueueInCharge - START'
    );
    //For creation
    if (isInsert) {
      Map<Id, Id> newCaseIdToQueueId = new Map<Id, Id>();
      for (Case newCase : newMap.values()) {
        newCaseIdToQueueId.put(newCase.Id, newCase.SMC_Expert_Queue__c);
      }

      try {
        SMC_AP_CaseFuture_WithoutSharing.fillQueueInChargeAfterInsert(
          newCaseIdToQueueId
        );
      } catch (Exception e) {
        System.debug(LoggingLevel.INFO, 'ERROR : ' + e);
      }

      return [
        SELECT Id, OwnerId, SMC_Expert_Queue__c
        FROM Case
        WHERE Id IN :newCaseIdToQueueId.keySet()
      ];
    } else {
      System.debug(
        LoggingLevel.INFO,
        '>>>>>>SMC_AP_ManageCase -> Method fillQueueInCharge - UPDATE'
      );
      //For update or transfer case
      Map<Id, List<Case>> ownerIdToNewCases = new Map<Id, List<Case>>();
      Map<Id, List<Case>> queueIdToNewCases = new Map<Id, List<Case>>();
      for (Case newCase : newMap.values()) {
        //Check if owner is a queue
        if (
          newCase.OwnerId != null &&
          newCase.OwnerId.getSObjectType() == Schema.Group.SObjectType
        ) {
          if (ownerIdToNewCases.containsKey(newCase.OwnerId)) {
            ownerIdToNewCases.get(newCase.OwnerId).add(newCase);
          } else {
            ownerIdToNewCases.put(newCase.OwnerId, new List<Case>{ newCase });
          }
        } else if (
          newCase.OwnerId != null &&
          newCase.OwnerId.getSObjectType() == Schema.User.SObjectType
        ) {
          //Check if owner is a user
          SMC_AP_DoNothingClass.doNothing();
        } else if (newCase.SMC_Expert_Queue__c != null) {
          //Check if a creation or modification (to transfer case)
          if (queueIdToNewCases.containsKey(newCase.SMC_Expert_Queue__c)) {
            queueIdToNewCases.get(newCase.SMC_Expert_Queue__c).add(newCase);
          } else {
            queueIdToNewCases.put(
              newCase.SMC_Expert_Queue__c,
              new List<Case>{ newCase }
            );
          }
        }
      }

      //Find Groups
      Id recordTypeIdAccountCaseTeam = [
        SELECT Id
        FROM RecordType
        WHERE name = :STA_UtilsStatic.RECORDTYPE_ACCOUNT_CASE_TEAM
      ]
      .Id;
      if (ownerIdToNewCases.size() > 0) {
        for (Account oneAccountGroup : [
          SELECT Id, Name, SMC_Queue_ID__c
          FROM Account
          WHERE
            SMC_Queue_ID__c IN :ownerIdToNewCases.keySet()
            AND RecordTypeId = :recordTypeIdAccountCaseTeam
        ]) {
          for (
            Case oneCase : ownerIdToNewCases.get(
              oneAccountGroup.SMC_Queue_ID__c
            )
          ) {
            oneCase.SMC_Expert_Queue__c = oneAccountGroup.Id;
          }
        }
      }
      if (queueIdToNewCases.size() > 0) {
        for (Account oneAccountGroupFromQueue : [
          SELECT Id, Name, SMC_Queue_ID__c
          FROM Account
          WHERE
            Id IN :queueIdToNewCases.keySet()
            AND RecordTypeId = :recordTypeIdAccountCaseTeam
        ]) {
          for (
            Case oneCase : queueIdToNewCases.get(oneAccountGroupFromQueue.Id)
          ) {
            oneCase.OwnerId = oneAccountGroupFromQueue.SMC_Queue_ID__c;
          }
        }
      }

      return newMap.values();
    }
  }

  /**
   * @description : case creation for other user/agent
   * @author Vincent RECASENS (Modis) | 08/04/2020
   * @param newList
   * @param isTestingThisMethod
   **/
  public static void createACaseForAnotherUser(
    List<Case> newList,
    Boolean isTestingThisMethod
  ) {
    //Get Requestors username
    Map<String, Case> mapCaseRequestorEmailToCase = new Map<String, Case>();
    Map<String, Case> mapCaseRequestorEmailToCaseClone = new Map<String, Case>();
    for (Case oneCase : newList) {
      if (
        oneCase.SMC_Requestor_Email__c != null &&
        oneCase.SMC_Requestor_Alias__c == null
      ) {
        //If there is more than one requestor by case, there is an error
        if (
          mapCaseRequestorEmailToCase.put(
            oneCase.SMC_Requestor_Email__c + '%',
            oneCase
          ) != null
        ) {
          oneCase.addError(
            String.escapeSingleQuotes(System.Label.SMC_TechnicalError),
            true
          );
        } else {
          mapCaseRequestorEmailToCase.put(
            oneCase.SMC_Requestor_Email__c + '%',
            oneCase
          );
          mapCaseRequestorEmailToCaseClone.put(
            oneCase.SMC_Requestor_Email__c + '%',
            oneCase
          );
        }
      }
    }

    if (mapCaseRequestorEmailToCase.size() > 0) {
      //Get Requestor
      List<User> newRequestors = [
        SELECT
          Id,
          Alias,
          FirstName,
          LastName,
          SMC_Subsdiary_Label__c,
          UserType,
          Username
        FROM User
        WHERE
          Username LIKE :mapCaseRequestorEmailToCase.keySet()
          AND IsActive = true
          AND UserType != :STA_UtilsStatic.PARTNER
      ];

      //Set the new Case
      for (User oneRequestor : newRequestors) {
        String usernameKey = oneRequestor.Username + '%';
        if (
          oneRequestor.UserType != null &&
          oneRequestor.UserType == STA_UtilsStatic.CHATTER_FREE
        ) {
          mapCaseRequestorEmailToCase.get(usernameKey)
            .SMC_Requestor_Alias__c = oneRequestor.Alias;
          mapCaseRequestorEmailToCase.get(usernameKey)
            .SMC_Requestor_Firstname__c = oneRequestor.FirstName;
          mapCaseRequestorEmailToCase.get(usernameKey)
            .SMC_Requestor_Name__c = oneRequestor.LastName;
          mapCaseRequestorEmailToCase.get(usernameKey)
            .SMC_Requestor_Organization__c = oneRequestor.SMC_Subsdiary_Label__c;
          mapCaseRequestorEmailToCaseClone.remove(usernameKey);
        } else {
          mapCaseRequestorEmailToCase.get(usernameKey)
            .SMC_Internal_Requestor__c = oneRequestor.Id;
          mapCaseRequestorEmailToCase.get(usernameKey)
            .SMC_Requestor_Organization__c = oneRequestor.SMC_Subsdiary_Label__c;
          mapCaseRequestorEmailToCaseClone.remove(usernameKey);
        }
      }

      //Check if requestor is found
      if (mapCaseRequestorEmailToCaseClone.size() > 0) {
        for (Case oneCase : newList) {
          if (
            mapCaseRequestorEmailToCase.get(
              oneCase.SMC_Requestor_Email__c + '%'
            ) != null
          ) {
            if (Test.isRunningTest()) {
              throw new QueryException(System.Label.SMC_RequestorNotFound);
            } else {
              oneCase.addError(
                String.escapeSingleQuotes(System.Label.SMC_RequestorNotFound),
                true
              );
            }
          }
        }
      }
    }

    if (Test.isRunningTest() && isTestingThisMethod) {
      insert newList;
    }
  }

  /**
   * @description : manage case CIMsa fields
   * @author Vincent RECASENS (Modis) | 08/04/2020
   * @param newList
   * @param oldMap
   **/
  public static void createCimsaVisit(
    List<Case> newList,
    Map<Id, Case> oldMap
  ) {
    //Pour le moment, pas de bulkification --> list[0]
    if (newList.size() > 1 || newList.size() == 0 || newList[0].Id == null) {
      return;
    } else {
      if (
        newList[0].SMC_IsVisitCimsaCreationSent__c &&
        !oldMap.get(newList[0].Id).SMC_IsVisitCimsaCreationSent__c &&
        ((newList[0].SMC_Serial_Number__c != null &&
        newList[0].SMC_Serial_Number__c != '') ||
        (newList[0].SMC_CIMSA_Visit_Category__c ==
        STA_UtilsStatic.VISIT_CATEGORY_SPARE_PART_APINAME &&
        newList[0].SMC_CIMSA_Visit_Under__c ==
        STA_UtilsStatic.VISIT_UNDER_PAID_BY_CUSTOMER_APINAME))
      ) {
        SMC_AP_CaseFuture.sendCimsaVisit(new Set<Id>{ newList[0].Id });
      } else if (newList[0].SMC_IsVisitCimsaCreationSent__c) {
        SMC_AP_CaseFuture.resetCimsaVisitBoolean(new Set<Id>{ newList[0].Id });
      }
    }
  }

  /**
   * @description : relaunch assignment rule for reopening from community
   * @author Vincent RECASENS (Modis) | 08/04/2020
   * @param newList
   * @return Boolean
   **/
  public static void reassignementForReopenCase(
    List<Case> newList,
    Map<Id, Case> oldMap
  ) {
    Map<Id, Case> reopenCases = new Map<Id, Case>();
    Map<Id, Id> reopenAccountIdToCaseId = new Map<Id, Id>();
    for (Case newCase : newList) {
      Case oldcase = oldMap.get(newCase.Id);
      if (
        newCase.Status == STA_UtilsStatic.CASE_STATUS_OPEN &&
        newCase.SMC_Sub_Status__c == STA_UtilsStatic.CASE_SUB_STATUS_REOPEN &&
        oldMap.get(newCase.Id).Status == STA_UtilsStatic.CASE_STATUS_CLOSED
      ) {
        reopenCases.put(newCase.Id, newCase);
        reopenAccountIdToCaseId.put(newCase.SMC_Expert_Queue__c, newCase.Id);
      }
    }

    if (reopenCases.size() > 0) {
      Map<Id, Id> mapCaseIdToQueueId = new Map<Id, Id>();
      for (Account oneAccountQueue : [
        SELECT Id, SMC_Queue_ID__c
        FROM Account
        WHERE Id IN :reopenAccountIdToCaseId.keySet()
      ]) {
        mapCaseIdToQueueId.put(
          reopenAccountIdToCaseId.get(oneAccountQueue.Id),
          oneAccountQueue.SMC_Queue_ID__c
        );
      }

      for (Case newCase : newList) {
        newCase.OwnerId = mapCaseIdToQueueId.get(newCase.Id);
      }
    }
  }

  /**
   * @description : add AnswerToCustomer value as a case comment
   * @author Vincent RECASENS (Modis) | 08/04/2020
   * @param newList
   * @param oldMap
   **/
  public static void answerToCustomerInComment(
    List<Case> newList,
    Map<Id, Case> oldMap
  ) {
    Map<Id, String> caseIdToAnswerToCustomer = new Map<Id, String>();
    for (Case newCase : newList) {
      Case oldcase = oldMap.get(newCase.Id);
      if (
        newCase.SMC_Answer_To_Customer__c != oldCase.SMC_Answer_To_Customer__c
      ) {
        newCase.SMC_New_Comment_Flag__c = true;
        caseIdToAnswerToCustomer.put(
          newCase.Id,
          newCase.SMC_Answer_To_Customer__c
        );
      }
    }
    SMC_AP_ManageCaseComment.addAnswerToCustomer(caseIdToAnswerToCustomer);
  }

  public static void fixPriorityForEmailToCase(List<Case> newList) {
    Map<String, String> casePriority = new Map<String, String>();
    Schema.DescribeFieldResult fieldResult = Case.Priority.getDescribe();
    List<Schema.PicklistEntry> entries = fieldResult.getPicklistValues();
    for (Integer i = 0; i < entries.size(); ++i) {
      casePriority.put(entries[i].getLabel(), entries[i].getValue());
    }
    for (Case oneCase : newList) {
      if (oneCase.SuppliedEmail != null) {
        oneCase.Priority = casePriority.get(oneCase.Priority);
      }
    }
  }

  /**
   * @description : check QueueInCharge field after assignment rule execution
   * @author Vincent RECASENS (Modis) | 08/04/2020
   * @param newMap
   * @param oldMap
   **/
  public static void checkAfterAssignementRuleExecution(
    Map<Id, Case> newMap,
    Map<Id, Case> oldMap
  ) {
    System.debug(
      LoggingLevel.INFO,
      '<<SMC_AP_ManageCase.checkAfterAssignementRuleExecution>> : START'
    );
    Map<Id, Id> mapCaseExpertQueueToCaseId = new Map<Id, Id>();
    for (Id oneId : newMap.keySet()) {
      if (
        newMap.get(oneId).OwnerId.getSObjectType() ==
        Schema.Group.SObjectType &&
        oldMap.get(oneId).OwnerId.getSObjectType() ==
        Schema.Group.SObjectType &&
        newMap.get(oneId).OwnerId != oldMap.get(oneId).OwnerId
      ) {
        mapCaseExpertQueueToCaseId.put(newMap.get(oneId).OwnerId, oneId);
      }
    }

    if (mapCaseExpertQueueToCaseId.size() == 0) {
      System.debug(
        LoggingLevel.INFO,
        '<<SMC_AP_ManageCase.checkAfterAssignementRuleExecution>> : END in if'
      );
      return;
    } else {
      for (Account oneAccount : [
        SELECT Id, SMC_Queue_ID__c
        FROM Account
        WHERE SMC_Queue_ID__c IN :mapCaseExpertQueueToCaseId.keySet()
      ]) {
        newMap.get(mapCaseExpertQueueToCaseId.get(oneAccount.SMC_Queue_ID__c))
          .SMC_Expert_Queue__c = oneAccount.Id;
      }

      System.debug(
        LoggingLevel.INFO,
        '<<SMC_AP_ManageCase.checkAfterAssignementRuleExecution>> : END in else'
      );
    }
  }

  /**
   * @description : add '#jira' for internal comment if checkbox SMC_JIRA_Comment_s__c is check and reset SMC_JIRA_Comment_s__c
   * @author Vincent RECASENS (Modis) | 14/04/2020
   * @param newList
   **/
  public static void addJiraIdentifierIfNeeded(Map<Id, Case> newMap) {
    for (Id oneId : newMap.keySet()) {
      if (
        newMap.get(oneId).SMC_JIRA_Comment_s__c &&
        newMap.get(oneId).Comments != null
      ) {
        newMap.get(oneId).Comments = '#jira ' + newMap.get(oneId).Comments;
        newMap.get(oneId).SMC_JIRA_Comment_s__c = false;
      }
    }
  }
}