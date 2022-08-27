/*
---------------------------------------------------------------------
-- - Name          : SMC_AP_ManageOpportunity
-- - Author        : Xavier BRANCHE
-- - Description   : Manage Opportunity               
-- Maintenance History:
--
-- Date         Name             		Version  Remarks 
-- -----------  ----           			------  ---------------------------
-- 28-JUL-2017  SMC_AP_ManageOpportunity    1.0      Initial version 
---------------------------------------------------------------------
*/
public with sharing class SMC_AP_ManageOpportunity {
  //erase the crm Code if the contact is cloned

  /**
   * @description : erase opportunity crm code
   * @author Vincent RECASENS (Modis) | 08/04/2020
   * @param OpportunitiesToCompare 
   **/
  public static void eraseCrmCode(List<Opportunity> OpportunitiesToCompare) {
    for (Opportunity o : OpportunitiesToCompare) {
      if (o.SMC_Duplicate_Id__c != null && o.SMC_Duplicate_Id__c != o.Id) {
        o.SMC_Opportunity_number__c = null;
      }
    }
  }

  /**
   * @description : check QTO can be launched
   * @author Vincent RECASENS (Modis) | 08/04/2020
   * @param theOpportunities 
   **/
  public static void checkOngoingQTO(Map<Id, Opportunity> theOpportunities) {
    //Get Custom Permission
    Boolean isAuthorizeToManageQuote = false;
    isAuthorizeToManageQuote = (FeatureManagement.checkPermission(
        STA_UtilsStatic.DELETE_OPPORTUNITY_PERMISSION
      )
      ? true
      : isAuthorizeToManageQuote);

    if (isAuthorizeToManageQuote) {
      //Build a list of quote ids to select SyncedQuote
      Set<Id> quoteIds = new Set<Id>();
      for (Opportunity oneOpportunity : theOpportunities.values()) {
        quoteIds.add(oneOpportunity.SyncedQuoteId);
      }

      //Check if it can be delete
      Map<Id, Quote> theQuotes = new Map<Id, Quote>(
        [
          SELECT Id, SMC_Is_QTO_Read_Only__c, SMC_Sales_Order__c
          FROM Quote
          WHERE Id IN :quoteIds
        ]
      );
      for (Opportunity oneOpportunity : theOpportunities.values()) {
        Quote oneQuote = theQuotes.get(oneOpportunity.SyncedQuoteId);
        if (
          oneQuote != null && oneQuote.SMC_Is_QTO_Read_Only__c &&
          oneQuote.SMC_Sales_Order__c != null
        ) {
          if (!Test.isRunningTest()) {
            oneOpportunity.addError(
              String.escapeSingleQuotes(System.Label.SMC_DontDeleteQTO),
              true
            );
          } else {
            DMLException dmlException = new DMLException();
            dmlException.setMessage(
              'Quote has a QTO started, you can\'t delete it'
            );
            throw dmlException;
          }
        }
      }
    } else {
      if (!Test.isRunningTest()) {
        theOpportunities.values()[0]
          .addError(
            String.escapeSingleQuotes(
              STA_UtilsStatic.DELETE_OPPORTUNITY_PERMISSION
            ),
            true
          );
      } else {
        DMLException dmlException = new DMLException();
        dmlException.setMessage(
          'You haven\'t the permission to delete a quote.'
        );
        throw dmlException;
      }
    }
  }

  /**
   * @description : check if current  is already a pilot on the opportunity
   * @author Vincent RECASENS (Modis) | 08/04/2020
   * @param opportunityId
   * @return Boolean
   **/
  public static Boolean currentUserIsPilot(Id opportunityId) {
    if (opportunityId == null) {
      System.debug(
        LoggingLevel.INFO,
        STA_UtilsStatic.ERROR_NO_OPPORTUNITY_LINK
      );
      return true;
    } else {
      try {
        Id userId = UserInfo.getUserId();
        OpportunityTeamMember opportunityTeamMember = [
          SELECT Id, OpportunityId, UserId, TeamMemberRole
          FROM OpportunityTeamMember
          WHERE
            OpportunityId = :opportunityId
            AND UserId = :userId
            AND TeamMemberRole = :STA_UtilsStatic.ROLE_PILOT
        ];
      } catch (Exception e) {
        return true;
      }
    }

    return false;
  }

  /**
   * @description : assign a generic account
   * @author Vincent RECASENS (Modis) | 08/04/2020
   * @param newList
   * @param oldMap 
   **/
  public static void assignGenericAccount(
    List<Opportunity> newList,
    Map<Id, Opportunity> oldMap
  ) {
    /* RETRIEVE OPP WITH ACCOUNT RELATED INFORMATION */
    Map<ID, Opportunity> oppListGenericAcc = new Map<ID, Opportunity>(
      [
        SELECT ID, Account.isGenericOppAccount__c
        FROM OPPORTUNITY
        WHERE ID IN :newList
      ]
    );
    /* RETRIEVE OPP WHICH NEED A GENERIC ACCOUNT */

    List<Opportunity> opportunityNeedGenericAccount = new List<Opportunity>();
    Set<Id> ownerIdOppsNeedGeneric = new Set<Id>();
    for (Opportunity oneOpportunity : newList) {
      // Condition 1 = if no account or contact are filled we need to define a generic account
      // OU Condition 2 = if current opp account is generic account and opp owner is changed
      if (
        (oneOpportunity.AccountId == null &&
        oneOpportunity.SMC_Primary_Contact__c == null &&
        oneOpportunity.SMC_Project_Lookup__c == null &&
        oneOpportunity.SMC_Project_Contact_Lookup__c == null) ||
        (oldMap != null &&
        oneOpportunity.OwnerId != oldMap.get(oneOpportunity.Id).OwnerId &&
        oneOpportunity.AccountId != null &&
        oppListGenericAcc.containsKey(oneOpportunity.Id) &&
        oppListGenericAcc.get(oneOpportunity.Id)
          .Account.isGenericOppAccount__c == true)
      ) {
        opportunityNeedGenericAccount.add(oneOpportunity);
        ownerIdOppsNeedGeneric.add(oneOpportunity.OwnerId);
      }
    }

    if (
      opportunityNeedGenericAccount != null &&
      opportunityNeedGenericAccount.size() > 0
    ) {
      /* RETRIEVE GENERIC ACCOUNT RELATED TO OPPORTUNITY OWNER */
      Map<Id, Id> ownerGenericAcc = new Map<Id, Id>();
      for (AccountTeamMember oneATM : [
        SELECT Id, UserId, AccountId
        FROM AccountTeamMember
        WHERE
          Account.isGenericOppAccount__c = true
          AND UserId = :ownerIdOppsNeedGeneric
      ]) {
        if (ownerGenericAcc.containsKey(oneATM.UserId) == false) {
          ownerGenericAcc.put(oneATM.UserId, oneATM.AccountId);
        }
      }

      if (ownerGenericAcc != null && ownerGenericAcc.isEmpty() == false) {
        /* SET GENERIC ACCOUNT */
        for (Opportunity oneOpportunity : opportunityNeedGenericAccount) {
          if (ownerGenericAcc.containsKey(oneOpportunity.OwnerId)) {
            oneOpportunity.AccountId = ownerGenericAcc.get(
              oneOpportunity.OwnerId
            );
          }
        }
      }
    }
  }

  /**
   * @description : if primary quote is changing, get the following status and apply to the new primary quote
   * @author Vincent RECASENS (Modis) | 08/04/2020
   * @param newMap
   * @param oldMap 
   **/
  public static void primaryQuoteIsFollowed(
    Map<Id, Opportunity> newMap,
    Map<Id, Opportunity> oldMap
  ) {
    Id recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName()
      .get(STA_UtilsStatic.RECORDTYPE_OPPORTUNITY_PROJECT)
      .getRecordTypeId();
    List<Id> quoteToUpdateIds = new List<Id>();
    Map<Id, Id> oppIdToOldQuoteIds = new Map<Id, Id>();
    for (Id oneId : newMap.keySet()) {
      if (
        oldMap.get(oneId).SyncedQuoteId != null &&
        newMap.get(oneId).SyncedQuoteId != oldMap.get(oneId).SyncedQuoteId &&
        oldMap.get(oneId).RecordTypeId == recordTypeId
      ) {
        oppIdToOldQuoteIds.put(oneId, oldMap.get(oneId).SyncedQuoteId);
      }
    }

    if (oppIdToOldQuoteIds.size() > 0) {
      Map<Id, Quote> oldQuotes = new Map<Id, Quote>(
        [
          SELECT Id, SMC_Followed__c
          FROM Quote
          WHERE Id IN :oppIdToOldQuoteIds.values()
        ]
      );
      // if(oldQuotes.size() > 0){
      for (Id oneId : newMap.keySet()) {
        if (oldQuotes.get(oppIdToOldQuoteIds.get(oneId)).SMC_Followed__c) {
          quoteToUpdateIds.add(newMap.get(oneId).SyncedQuoteId);
        }
      }
      // }

      if (quoteToUpdateIds.size() > 0) {
        SMC_AP_ManageQuote.primaryQuoteWasFollowed(quoteToUpdateIds);
      }
    }
  }
}