/*
---------------------------------------------------------------------
-- - Name          : SMC_AP_ManageQuote
-- - Author        : Vincent RECASENS - MODIS
-- - Description   : Manage Quote               
-- Maintenance History:
--
-- Date         Name                Version  Remarks
-- -----------  ----                -------  -------------------------------------------------------
-- 28-MAY-18    Vincent RECASENS    1.0     Initial version
--------------------------------------------------------------------------------------
*/

public without sharing class SMC_AP_ManageQuote {

  /**
   * @description : quote need opportunity to exist, so create a fake opportunity
   * @author Vincent RECASENS (Modis) | 08/04/2020
   * @param theQuotes
   **/
  public static void createFakeOpportunityBeforeInsert(List<Quote> theQuotes) {
    // Get RecordType Quote
    Map<String, Schema.RecordTypeInfo> recordTypesQuote = new Map<String, Schema.RecordTypeInfo>();
    recordTypesQuote = Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName();
    Id quoteProjectId = recordTypesQuote.get(
        STA_UtilsStatic.RECORDTYPE_QUOTE_PROJECT
      )
      .getRecordTypeId();
    Id quoteQuickId = recordTypesQuote.get(
        STA_UtilsStatic.RECORDTYPE_QUICK_QUOTE
      )
      .getRecordTypeId();
    Id quoteSimuExpressId = recordTypesQuote.get(
        STA_UtilsStatic.RECORDTYPE_SIMU_EXPRESS
      )
      .getRecordTypeId();

    // Get RecordType Opportunity
    Map<String, Schema.RecordTypeInfo> recordTypesOpportunity = new Map<String, Schema.RecordTypeInfo>();
    recordTypesOpportunity = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName();
    Id opportunityQuickId = recordTypesOpportunity.get(
        STA_UtilsStatic.RECORDTYPE_QUICK_OPPORTUNITY
      )
      .getRecordTypeId();
    Id opportunitySimuExpressId = recordTypesOpportunity.get(
        STA_UtilsStatic.RECORDTYPE_SIMU_EXPRESS_OPPORTUNITY
      )
      .getRecordTypeId();

    Map<String, Opportunity> mapping = new Map<String, Opportunity>();
    for (Quote oneQuote : theQuotes) {
      // If quote isn't a project, create a fake opportunity
      if (
        oneQuote.OpportunityId == null &&
        oneQuote.RecordTypeId != quoteProjectId
      ) {
        Opportunity fictiveOpportunity = new Opportunity();
        fictiveOpportunity.Name = STA_UtilsStatic.NA_VALUE;
        fictiveOpportunity.StageName = STA_UtilsStatic.OPPORTUNITY_TENDER_QUOTATION;
        fictiveOpportunity.CloseDate = oneQuote.SMC_Closing_Date__c;
        fictiveOpportunity.SMC_Success_Rate_Range__c = oneQuote.SMC_Success_Rate_Range__c;
        fictiveOpportunity.AccountId = oneQuote.SMC_Account__c;
        fictiveOpportunity.SMC_Primary_Contact__c = oneQuote.ContactId;

        if (string.isBlank(oneQuote.SMC_Currency__c) == false) {
          fictiveOpportunity.CurrencyIsoCode = oneQuote.SMC_Currency__c;
        }
        //Check RecordType
        if (oneQuote.RecordTypeId == quoteQuickId) {
          fictiveOpportunity.RecordTypeId = opportunityQuickId;
        } else if (oneQuote.RecordTypeId == quoteSimuExpressId) {
          fictiveOpportunity.RecordTypeId = opportunitySimuExpressId;
        }

        mapping.put(oneQuote.Name, fictiveOpportunity);
      }
    }

    if (mapping.size() > 0) {
      try {
        //By pass Opportunity trigger cause this opportunity is fictive
        PAD.ApexForcedBypass.add(STA_UtilsStatic.CLASS_OPPORTUNITY_MANAGEMENT);
        insert mapping.values();
        PAD.ApexForcedBypass.remove(
          STA_UtilsStatic.CLASS_OPPORTUNITY_MANAGEMENT
        );
      } catch (Exception e) {
        System.debug(
          LoggingLevel.INFO,
          'createFakeOpportunity_beforeInsert -- ERROR : ' + e
        );
      }
    }

    // Link quote to fake opportunity
    for (Quote oneQuote : theQuotes) {
      if (mapping.get(oneQuote.Name) != null) {
        oneQuote.OpportunityId = mapping.get(oneQuote.Name).Id;
        /* Comment by DOS during W20
                Map<String,Object> variablesMap = new Map<String,Object>();
                variablesMap.put('AccountId', oneQuote.SMC_Account__c);
                variablesMap.put('ContactId', oneQuote.ContactId);
                variablesMap.put('OptyId', oneQuote.OpportunityId);
                variablesMap.put('IsSync', oneQuote.IsSyncing);
                Flow.Interview.SMC_OptyActorUpdate createOpportunityActor = new Flow.Interview.SMC_OptyActorUpdate(variablesMap);
                createOpportunityActor.start();
				*/
      }
    }
  }

  /**
   * @description : set BP Account on new quotes
   * @author Vincent RECASENS (Modis) | 09-24-2020
   * @param newList
   **
  public static void setBPAccount(List<Quote> newList) {
    for (Quote oneQuote : newList) {
      oneQuote.SMC_BP_Account__c = oneQuote.SMC_Account__c;
    }
  }

  /**
   * @description : set Follow field on primary quote
   * @author Vincent RECASENS (Modis) | 09-24-2020
   * @param newList
   **
  public static void followPrimaryQuote(List<Quote> newList) {
    for (Quote oneQuote : newList) {
      if (
        oneQuote.IsSyncing &&
        oneQuote.RecordTypeId ==
        Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName()
          .get(STA_UtilsStatic.RECORDTYPE_QUOTE_PROJECT)
          .getRecordTypeId()
      ) {
        oneQuote.SMC_Followed__c = true;
      }
    }
  }

  /**
   * @description : fill tech contact field if ContactId is filled
   * @author Vincent RECASENS (Modis) | 09-24-2020
   * @param newList
   **
  public static void fillCustomContactField(
    List<Quote> newList,
    Map<Id, Quote> oldMap
  ) {
    for (Quote oneQuote : newList) {
      if (
        oldMap == null &&
        oneQuote.ContactId != null &&
        oneQuote.ContactId != ''
      ) {
        oneQuote.Tech_SMC_Contact__c = oneQuote.ContactId;
      } else if (
        oldMap != null &&
        oneQuote.ContactId != null &&
        oneQuote.ContactId != '' &&
        oneQuote.ContactId == oneQuote.Tech_SMC_Contact__c
      ) {
        oneQuote.Tech_SMC_Contact__c = oneQuote.ContactId;
      }
    }
  }

  /**
   * @description : remove account bypass
   * @author Vincent RECASENS (Modis) | 09-24-2020
   * @param newList
   * @param oldMap
   **
  public static void removeAccountBypass(
    List<Quote> newList
  ) {
    for (Quote oneQuote : newList) {
      if (oneQuote.TECH_SMC_By_Pass_Account_VR__c) {
        oneQuote.TECH_SMC_By_Pass_Account_VR__c = false;
      }
    }
  }

  /**
   * @description : check if QTO is already launch
   * @author Vincent RECASENS (Modis) | 08/04/2020
   * @param theQuotes
   * @return Boolean
   **/
  public static Boolean checkOngoingQTO(List<Quote> theQuotes) {
    //Check if it can be delete
    for (Quote oneQuote : theQuotes) {
      if (oneQuote.SMC_Is_QTO_Read_Only__c) {
        oneQuote.addError(
          String.escapeSingleQuotes(System.Label.SMC_DontDeleteQTO),
          true
        );
        return false;
      }
    }
    return true;
  }

  /**
   * @description : display infos to start QTO
   * @author Vincent RECASENS (Modis) | 08/04/2020
   * @param quotes
   * @return Boolean
   **/
  public static Boolean displayInfosToStartQTO(List<Quote> quotes) {
    if (quotes != null) {
      return true;
    } else {
      return false;
    }
  }

  /**
        3 step to send notification for an approval ending :
            - setProcessInstanceIdField
            - sendNotificationForApprovalEnding
            - resetProcessInstanceIdField
    **/
  /**
   * @description : set quote TECH_SMC_Process_Instance_Id__c
   * @author Vincent RECASENS (Modis) | 08/04/2020
   * @param newMap
   * @param iStestingThisMethod
   **/
  public static void setProcessInstanceIdField(
    Map<Id, Quote> newMap,
    Boolean iStestingThisMethod
  ) {
    //Check if Quotes are in approval ending
    Map<Id, Quote> quoteWithApprovalEnded = new Map<Id, Quote>();
    for (Quote oneQuote : newMap.values()) {
      if (
        oneQuote.SMC_Approval_Status__c ==
        STA_UtilsStatic.STATUS_APPROVAL_PENDING &&
        oneQuote.TECH_SMC_Process_Instance_Id__c == null
      ) {
        quoteWithApprovalEnded.put(oneQuote.Id, oneQuote);
      }
    }

    if (quoteWithApprovalEnded.size() > 0) {
      //Get ProcessInstanceId
      List<ProcessInstance> processInstanceList = new List<ProcessInstance>();
      processInstanceList = [
        SELECT Id, TargetObjectId
        FROM ProcessInstance
        WHERE TargetObjectId IN :quoteWithApprovalEnded.keySet()
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
   * @description : send notification for approval ending
   * @author Vincent RECASENS (Modis) | 08/04/2020
   * @param newMap
   * @param oldMap
   **/
  public static void sendNotificationForApprovalEnding(
    Map<Id, Quote> newMap,
    Map<Id, Quote> oldMap
  ) {
    //Check if Quotes are in approval ending
    Map<Id, Quote> processInstanceIdWithApprovalEnded = new Map<Id, Quote>();
    Set<Id> resetQuote = new Set<Id>();
    for (Quote oneQuote : newMap.values()) {
      if (
        oneQuote.TECH_SMC_Process_Instance_Id__c != null &&
        oneQuote.SMC_Approval_Status__c != null &&
        oneQuote.SMC_Approval_Status__c !=
        STA_UtilsStatic.STATUS_APPROVAL_PENDING &&
        oldMap.get(oneQuote.Id).SMC_Approval_Status__c ==
        STA_UtilsStatic.STATUS_APPROVAL_PENDING
      ) {
        processInstanceIdWithApprovalEnded.put(
          oneQuote.TECH_SMC_Process_Instance_Id__c,
          oneQuote
        );
        resetQuote.add(oneQuote.Id);
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
          Quote theQuote = processInstanceIdWithApprovalEnded.get(
            oneProcessInstanceStep.ProcessInstanceId
          );
          Map<String, Object> variablesMap = new Map<String, Object>();
          variablesMap.put(STA_UtilsStatic.THE_QUOTE, theQuote);
          variablesMap.put(
            STA_UtilsStatic.THE_PROCESS_INSTANCE_ID,
            theQuote.TECH_SMC_Process_Instance_Id__c
          );
          //Build message in according to the approval status
          if (
            theQuote.SMC_Approval_Status__c == STA_UtilsStatic.STATUS_APPROVED
          ) {
            variablesMap.put(
              STA_UtilsStatic.MESSAGE,
              'The quote ' +
              theQuote.QuoteNumber +
              ' was approved. See the approval here : https://' +
              URL.getSalesforceBaseUrl().getHost() +
              '/lightning/r/ProcessInstanceStep/' +
              oneProcessInstanceStep.Id +
              '/view'
            );
          } else if (
            theQuote.SMC_Approval_Status__c == STA_UtilsStatic.STATUS_REJECTED
          ) {
            variablesMap.put(
              STA_UtilsStatic.MESSAGE,
              'The quote ' +
              theQuote.QuoteNumber +
              ' was rejected. See the approval here : https://' +
              URL.getSalesforceBaseUrl().getHost() +
              '/lightning/r/ProcessInstanceStep/' +
              oneProcessInstanceStep.Id +
              '/view'
            );
          }
          Flow.Interview.SMC_Approval_Notification postChatterFlow = new Flow.Interview.SMC_Approval_Notification(
            variablesMap
          );
          postChatterFlow.start();

          postAlreadySend.add(
            oneProcessInstanceStep.ProcessInstance.TargetObject.Id
          );
        }
      }

      resetProcessInstanceIdField(resetQuote);
    }
  }

  /**
   * @description : reset the field TECH_SMC_Process_Instance_Id__c
   * @author Vincent RECASENS (Modis) | 08/04/2020
   * @param quoteIds
   **/
  @Future
  public static void resetProcessInstanceIdField(Set<Id> quoteIds) {
    List<Quote> quotes = new List<Quote>();
    quotes = [
      SELECT Id, TECH_SMC_Process_Instance_Id__c
      FROM Quote
      WHERE Id IN :quoteIds
    ];
    for (Quote oneQuote : quotes) {
      oneQuote.TECH_SMC_Process_Instance_Id__c = null;
    }

    update quotes;
  }

  /**
   * @description : if primary quote is changing, get the following status and apply to the new primary quote
   * @author Vincent RECASENS (Modis) | 08/04/2020
   * @param quoteIds
   **/
  @Future
  public static void primaryQuoteWasFollowed(List<Id> quoteIds) {
    List<Quote> quoteToUpdate = new List<Quote>();
    for (Quote oneQuote : [
      SELECT Id, SMC_Followed__c
      FROM Quote
      WHERE Id IN :quoteIds
    ]) {
      oneQuote.SMC_Followed__c = true;
      quoteToUpdate.add(oneQuote);
    }

    if (quoteToUpdate.size() > 0) {
      update quoteToUpdate;
    }
  }

  /**
   * @description : used to set the rigth user if a delegated user approve/reject/cancel the approval
   * @author Vincent RECASENS (Modis) | 08/04/2020
   * @param newMap
   * @param oldMap
   **/
  public static void checkApprovalInformations(
    Map<Id, Quote> newMap,
    Map<Id, Quote> oldMap
  ) {
    //Sort Quote in needed
    Map<Id, Id> assignedApprvalIdToquoteId = new Map<Id, Id>();
    for (Id oneQuoteId : newMap.keySet()) {
      Quote newQuote = newMap.get(oneQuoteId);
      Quote oldQuote = oldMap.get(oneQuoteId);
      if (
        newQuote.SMC_Approval_Level_Requested__c != null &&
        (oldQuote.SMC_Approval_Level_Requested__c == null ||
        (newQuote.SMC_Approval_Level_Requested__c ==
        oldQuote.SMC_Approval_Level_Requested__c &&
        newQuote.TECH_SMC_Next_Approver_Id__c !=
        oldQuote.TECH_SMC_Next_Approver_Id__c))
      ) {
        if (
          oldQuote.SMC_Approval_Level_Requested__c == null &&
          newQuote.SMC_Approval_Level_Requested__c != null
        ) {
          newQuote.SMC_Approval_Level_Validated__c = 0;
          newQuote.SMC_Next_Approver__c = newQuote.OwnerId;
        } else {
          assignedApprvalIdToquoteId.put(
            newQuote.SMC_Next_Approver__c,
            oneQuoteId
          );
        }
      }
    }

    //Bypass method
    if (assignedApprvalIdToquoteId.size() == 0) {
      return;
    }

    for (User oneUser : [
      SELECT Id, Name, SMC_Approval_Level__c
      FROM User
      WHERE Id IN :assignedApprvalIdToquoteId.keySet()
    ]) {
      newMap.get(assignedApprvalIdToquoteId.get(oneUser.Id))
        .SMC_Approval_Level_Validated__c = oneUser.SMC_Approval_Level__c;
      newMap.get(assignedApprvalIdToquoteId.get(oneUser.Id))
        .SMC_Next_Approver__c = newMap.get(
          assignedApprvalIdToquoteId.get(oneUser.Id)
        )
        .TECH_SMC_Next_Approver_Id__c;
    }

    if (Test.isRunningTest()) {
      update newMap.values();
    }
  }

  /* TEMP METHOD --> to be transformed in a VR on Quote */
  public static void preventModificationIfQuoteIsValidatedOrCancelled(
    Map<Id, Quote> newMap,
    Map<Id, Quote> oldMap
  ) {
    for (Id newId : newMap.keySet()) {
      Quote newQuote = newMap.get(newId);
      Quote oldQuote = oldMap.get(newId);
      Profile userProfile = [
        SELECT Id, Name
        FROM Profile
        WHERE Id = :UserInfo.getProfileId()
      ];
      if (
        oldQuote != null &&
        userProfile.Name == STA_UtilsStatic.PROFILE_SMC_PARTNER_COMMUNITY &&
        newQuote.SMC_Partner_Validation__c !=
        oldQuote.SMC_Partner_Validation__c &&
        oldQuote.SMC_Partner_Validation__c != 'To be validated' &&
        oldQuote.SMC_Partner_Validation__c != null &&
        oldQuote.SMC_Partner_Validation__c != ''
      ) {
        newMap.get(newId)
          .addError('You can\'t edit a cancelled or validated quote.');
      }
    }
  }
}