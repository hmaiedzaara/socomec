/*
---------------------------------------------------------------------
-- - Name          : SMC_AP_ManageAccount
-- - Author        : Xavier BRANCHE
-- - Description   : Manage Account               
-- Maintenance History:
--
-- Date         Name             Version  Remarks 
-- -----------  ----             -------  ---------------------------
-- 30-MAI-2017  ????????????????    1.0      Initial version 
-- 30-NOV-2017  ????????????????    1.1      Fix concerning co-pilot removing from AccountTeamMember
-- 25-JUN-2019  Vincent RECASENS    1.2      Cleaning code
-- 12-DEC-2019  Vincent RECASENS    1.2      Add control on AccountTeamMember insertion
-- 07-APR-2020  Vincent RECASENS    1.2      Add documentation
---------------------------------------------------------------------
*/
public without sharing class SMC_AP_ManageAccount {
  // public static void eraseCrmCodeInsert(List<Account> newList) {
  //   Set<Id> accountIds = new Set<Id>();
  //   for (Account oneAccount : newList) {
  //     if (
  //       ((oneAccount.AccountNumber == null || oneAccount.AccountNumber == '') &&
  //       (oneAccount.SMC_Account_External_Id__c == null ||
  //       oneAccount.SMC_Account_External_Id__c == '')) ||
  //       oneAccount.AccountNumber != oneAccount.SMC_Account_External_Id__c
  //     ) {
  //       accountIds.add(oneAccount.Id);
  //     }
  //   }
  //   if (accountIds.size() > 0) {
  //     manageCrmCode(accountIds);
  //   }
  // }
  // @Future
  // public static void manageCrmCode(Set<Id> accountIds) {
  //   List<Account> accountsToUpdate = new List<Account>();
  //   accountsToUpdate = [
  //       SELECT
  //         Id,
  //         AccountNumber,
  //         SMC_Account_External_Id__c,
  //         SMC_CDS_Reference_ID__c,
  //         Description
  //       FROM Account
  //       WHERE Id IN :accountIds
  //     ];
  //   for (Account oneAccount : accountsToUpdate) {
  //     if (oneAccount.AccountNumber == null || oneAccount.AccountNumber == '') {
  //       oneAccount.AccountNumber = oneAccount.SMC_CDS_Reference_ID__c;
  //       oneAccount.SMC_Account_External_Id__c = oneAccount.SMC_CDS_Reference_ID__c;
  //     } else {
  //       oneAccount.SMC_Account_External_Id__c = oneAccount.AccountNumber;
  //     }
  //   }

  //   if (accountsToUpdate.size() > 0) {
  //     update accountsToUpdate;
  //   }
  // }

  /**
   * @description : fill default country (current user default country) if empty
   * @author Vincent RECASENS (Modis)
   * @param accountsToComplete
   **/
  public static void completeAccountsWithDefaultCountry(
    List<Account> accountsToComplete
  ) {
    String defaultCountry = [
      SELECT id, SMC_Default_Country__c
      FROM User
      WHERE id = :UserInfo.getUserId()
      LIMIT 1
    ]
    .SMC_Default_Country__c;
    if (defaultCountry != null) {
      for (Account elem : accountsToComplete) {
        if (elem.BillingCountryCode == null) {
          elem.BillingCountryCode = defaultCountry;
        }
      }
    }
  }

  /**
   * @description : insert new team member, launch deletion (if necessary) and notify pilots
   * @author Vincent RECASENS (Modis)
   * @param accountsToCompare
   * @param oldList
   **/
  public static void insertTeamMember(
    Map<Id, Account> accountsToCompare,
    List<Account> oldList
  ) {
    List<AccountTeamMember> teamMembers = new List<AccountTeamMember>();
    List<user> users = [SELECT Id FROM User WHERE isActive = true];
    Set<Id> setUser = new Set<Id>();
    for (user u : users) {
      setUser.add(u.Id);
    }

    //Control on AccountTeamMember before insertion of them
    Set<Id> setAccountId = new Set<Id>();
    for (Account oneAccount : accountsToCompare.values()) {
      setAccountId.add(oneAccount.Id);
    }
    Map<Id, Id> accountToATMOwnerId = new Map<Id, Id>();
    for (AccountTeamMember oneATM : [
      SELECT Id, UserId, AccountId, TeamMemberRole
      FROM AccountTeamMember
      WHERE AccountId IN :setAccountId
    ]) {
      if (
        accountToATMOwnerId.get(oneATM.AccountId) == null &&
        oneATM.TeamMemberRole == STA_UtilsStatic.ROLE_OWNER
      ) {
        accountToATMOwnerId.put(oneATM.AccountId, oneATM.UserId);
      } else if (
        accountToATMOwnerId.get(oneATM.AccountId) == null &&
        oneATM.TeamMemberRole != STA_UtilsStatic.ROLE_OWNER
      ) {
        accountToATMOwnerId.put(oneATM.AccountId, null);
      }
    }

    for (Account a : accountsToCompare.values()) {
      //insert the new team member Owner
      if (a.OwnerId != null) {
        if (
          setUser.contains(a.OwnerId) &&
          (accountToATMOwnerId.get(a.Id) == null ||
          accountToATMOwnerId.get(a.Id) != a.OwnerId)
        ) {
          AccountTeamMember teamMember = SMC_UTIL_TestUtils.createTeamMember(
            a.Id,
            a.OwnerId
          );
          if (
            a.OwnerId != a.SMC_PCO_Pilot__c &&
            a.OwnerId != a.SMC_PCS_Pilot__c &&
            a.OwnerId != a.SMC_EE_Pilot__c &&
            a.OwnerId != a.SMC_Service_Pilot__c
          ) {
            teamMember.TeamMemberRole = STA_UtilsStatic.ROLE_OWNER;
          }
          teamMembers.add(teamMember);
        }
      }

      //insert the new team member PCO
      if (a.SMC_PCO_Pilot__c != null) {
        if (
          setUser.contains(a.SMC_PCO_Pilot__c) &&
          (accountToATMOwnerId.get(a.Id) == null ||
          accountToATMOwnerId.get(a.Id) != a.SMC_PCO_Pilot__c)
        ) {
          AccountTeamMember teamMember = SMC_UTIL_TestUtils.createTeamMember(
            a.Id,
            a.SMC_PCO_Pilot__c
          );
          teamMembers.add(teamMember);
        }
      }

      //insert the new team member PCS
      if (a.SMC_PCS_Pilot__c != null) {
        if (
          setUser.contains(a.SMC_PCS_Pilot__c) &&
          (accountToATMOwnerId.get(a.Id) == null ||
          accountToATMOwnerId.get(a.Id) != a.SMC_PCS_Pilot__c)
        ) {
          AccountTeamMember teamMember = SMC_UTIL_TestUtils.createTeamMember(
            a.Id,
            a.SMC_PCS_Pilot__c
          );
          teamMembers.add(teamMember);
        }
      }

      //insert the new team member EE
      if (a.SMC_EE_Pilot__c != null) {
        if (
          setUser.contains(a.SMC_EE_Pilot__c) &&
          (accountToATMOwnerId.get(a.Id) == null ||
          accountToATMOwnerId.get(a.Id) != a.SMC_EE_Pilot__c)
        ) {
          AccountTeamMember teamMember = SMC_UTIL_TestUtils.createTeamMember(
            a.Id,
            a.SMC_EE_Pilot__c
          );
          teamMembers.add(teamMember);
        }
      }

      //insert the new team member ES
      if (a.SMC_Service_Pilot__c != null) {
        if (
          setUser.contains(a.SMC_Service_Pilot__c) &&
          (accountToATMOwnerId.get(a.Id) == null ||
          accountToATMOwnerId.get(a.Id) != a.SMC_Service_Pilot__c)
        ) {
          AccountTeamMember teamMember = SMC_UTIL_TestUtils.createTeamMember(
            a.Id,
            a.SMC_Service_Pilot__c
          );
          teamMembers.add(teamMember);
        }
      }

      //insert the new team member ESS
      if (a.SMC_ESS_Pilot__c != null) {
        if (
          setUser.contains(a.SMC_ESS_Pilot__c) &&
          (accountToATMOwnerId.get(a.Id) == null ||
          accountToATMOwnerId.get(a.Id) != a.SMC_ESS_Pilot__c)
        ) {
          AccountTeamMember teamMember = SMC_UTIL_TestUtils.createTeamMember(
            a.Id,
            a.SMC_ESS_Pilot__c
          );
          teamMembers.add(teamMember);
        }
      }
    }

    if (accountsToCompare != null) {
      deleteTeamMember(accountsToCompare.values());
    }

    if (teamMembers != null) {
      insert teamMembers;
      notifyNewPilot(accountsToCompare.values(), oldList);
    }
  }

  /**
   * @description : deletion of team members
   * @author Vincent RECASENS (Modis)
   * @param accountsToCompare
   **/
  public static void deleteTeamMember(List<Account> accountsToCompare) {
    List<AccountTeamMember> atmList = new List<AccountTeamMember>();
    atmList = [
      SELECT Id, UserId, AccountId
      FROM AccountTeamMember
      WHERE
        AccountId IN :accountsToCompare
        AND TeamMemberRole != :STA_UtilsStatic.ROLE_COPILOT
      ORDER BY AccountId
    ];

    List<AccountTeamMember> teamMemberToRemove = new List<AccountTeamMember>();

    if (atmList != null) {
      for (Account a : accountsToCompare) {
        List<AccountTeamMember> teamMembersToCompare = new List<AccountTeamMember>();
        for (AccountTeamMember atm : atmList) {
          if (atm.AccountId == a.Id) {
            teamMembersToCompare.add(atm);
          }
        }
        for (AccountTeamMember atm : teamMembersToCompare) {
          if (
            atm.UserId != a.OwnerId &&
            atm.UserId != a.SMC_Service_Pilot__c &&
            atm.UserId != a.SMC_ESS_Pilot__c &&
            atm.UserId != a.SMC_EE_Pilot__c &&
            atm.UserId != a.SMC_PCO_Pilot__c &&
            atm.UserId != a.SMC_PCS_Pilot__c
          ) {
            teamMemberToRemove.add(atm);
          }
        }
      }

      if (teamMemberToRemove != null) {
        Set<AccountTeamMember> teamMemberToRemoveWithoutDuplicate = new Set<AccountTeamMember>();
        teamMemberToRemoveWithoutDuplicate.addAll(teamMemberToRemove);
        teamMemberToRemove.clear();
        teamMemberToRemove.addAll(teamMemberToRemoveWithoutDuplicate);

        System.debug(
          LoggingLevel.INFO,
          '## >>> SMC_AP_ManageAccount teamMemberToRemove : ' +
          teamMemberToRemove
        );
        delete teamMemberToRemove;
      }
    }
  }

  /**
   * @description : assigne territories
   * @author Guillamue BONNET / ??/??/2018
   * @param oldList
   * @param newList
   **/
  public static void setAssignedTerritories(
    List<Account> oldList,
    List<Account> newList
  ) {
    if (
      oldList.size() < 200 &&
      (oldList.get(0).BillingCountryCode != newList.get(0).BillingCountryCode ||
      oldList.get(0).SMC_Account_Subsidiaries__c !=
      newList.get(0).SMC_Account_Subsidiaries__c)
    ) {
      SMC_AP_FutureCallout.calloutAssignTerritories(
        new Map<Id, Account>(newList).keySet()
      );
    }
  }

  /**
   * @description : check if we can delete an account
   * @author Vincent RECASENS (Modis)
   * @param oldMap
   **/
  public static void checkERPAccountToMassDeleteAndLinkOpportunity(
    Map<Id, Account> oldMap
  ) {
    // The limit is 50.000, but it is possible to find an Account in multiple Opportunity.
    // To prevent error, the limit is 5.000
    Integer maximumRecordsRetrievedBySOQL = 5000;

    //Get PermissionSet
    List<PermissionSetAssignment> pasList = [
      SELECT Assignee.Id, PermissionSet.Id, PermissionSet.Name
      FROM PermissionSetAssignment
      WHERE Assignee.Id = :UserInfo.getUserId()
    ];
    Boolean isAuthorizeToManageQuote = false;
    for (PermissionSetAssignment onePas : pasList) {
      if (
        onePas.PermissionSet.Name == STA_UtilsStatic.KEY_USER_PERMISSION ||
        onePas.PermissionSet.Name == STA_UtilsStatic.BUSINESS_ADMIN_PERMISSION
      ) {
        isAuthorizeToManageQuote = true;
        break;
      }
    }

    //Get Custom Permission
    isAuthorizeToManageQuote = FeatureManagement.checkPermission(
        STA_UtilsStatic.DELETE_OPPORTUNITY_PERMISSION
      )
      ? true
      : isAuthorizeToManageQuote;

    if (
      isAuthorizeToManageQuote && oldMap.size() <= maximumRecordsRetrievedBySOQL
    ) {
      for (Account acc : oldMap.values()) {
        if (acc.SMC_isLinkedWithErp__c) {
          acc.addError(
            String.escapeSingleQuotes(System.Label.SMC_AccountLinkERP),
            true
          );
        }
      }
      for (Opportunity oneOpp : [
        SELECT Id, AccountId, PartnerAccountId, SMC_Project_Lookup__c
        FROM Opportunity
        WHERE
          AccountId IN :oldMap.keySet()
          OR PartnerAccountId IN :oldMap.keySet()
          OR SMC_Project_Lookup__c IN :oldMap.keySet()
      ]) {
        if (oldMap.keySet().contains(oneOpp.AccountId)) {
          oldMap.get(oneOpp.AccountId)
            .addError(
              String.escapeSingleQuotes(
                System.Label.SMC_AccountLinkOpportunity
              ),
              true
            );
        } else if (oldMap.keySet().contains(oneOpp.PartnerAccountId)) {
          oldMap.get(oneOpp.PartnerAccountId)
            .addError(
              String.escapeSingleQuotes(
                System.Label.SMC_AccountLinkOpportunity
              ),
              true
            );
        } else if (oldMap.keySet().contains(oneOpp.SMC_Project_Lookup__c)) {
          oldMap.get(oneOpp.SMC_Project_Lookup__c)
            .addError(
              String.escapeSingleQuotes(
                System.Label.SMC_AccountLinkOpportunity
              ),
              true
            );
        }
      }
    } else {
      if (
        oldMap.size() > maximumRecordsRetrievedBySOQL &&
        isAuthorizeToManageQuote
      ) {
        oldMap.values()[0]
          .adderror(
            String.escapeSingleQuotes(
              STA_UtilsStatic.TO_MUCH_ACCOUNT_TO_CONTROL_P1 +
              maximumRecordsRetrievedBySOQL +
              STA_UtilsStatic.TO_MUCH_ACCOUNT_TO_CONTROL_P2
            ),
            true
          );
      } else if (
        oldMap.size() > maximumRecordsRetrievedBySOQL &&
        !isAuthorizeToManageQuote
      ) {
        oldMap.values()[0]
          .adderror(
            String.escapeSingleQuotes(
              STA_UtilsStatic.MASS_DELETE_WITHOUT_PERMISSION.substring(
                0,
                STA_UtilsStatic.MASS_DELETE_WITHOUT_PERMISSION.length() - 1
              ) +
              STA_UtilsStatic.SPACE +
              STA_UtilsStatic.AND_MINOR +
              STA_UtilsStatic.SPACE +
              STA_UtilsStatic.TO_MUCH_ACCOUNT_TO_CONTROL_P1.substring(1) +
              maximumRecordsRetrievedBySOQL +
              STA_UtilsStatic.TO_MUCH_ACCOUNT_TO_CONTROL_P2
            ),
            true
          );
      } else {
        oldMap.values()[0]
          .addError(
            String.escapeSingleQuotes(
              System.Label.SMC_DeleteAccountWithoutPermission
            ),
            true
          );
      }
    }
  }

  /**
   * @description : notify new pilot on account
   * @author Vincent RECASENS (Modis)
   * @param newList
   * @param oldList
   **/
  public static void notifyNewPilot(
    List<Account> newList,
    List<Account> oldList
  ) {
    List<AccountTeamMember> teamMembers = new List<AccountTeamMember>();
    Set<Id> newAccountIds = new Set<Id>();
    for (Account a : newList) {
      newAccountIds.add(a.Id);
    }

    //get all team members
    try {
      teamMembers = [
        SELECT
          Id,
          AccountId,
          Account.Name,
          TeamMemberRole,
          UserId,
          LastModifiedDate
        FROM AccountTeamMember
        WHERE AccountId IN :newAccountIds
      ];
    } catch (Exception e) {
      System.debug(LoggingLevel.INFO, STA_UtilsStatic.NO_ACCOUNT_TEAM);
    }

    //Get old list to compare
    Set<Id> oldListPilot = new Set<Id>();
    if (oldList != null) {
      for (Account oldAccount : oldList) {
        if (oldAccount.SMC_EE_Pilot__c != null) {
          oldListPilot.add(oldAccount.SMC_EE_Pilot__c);
        }
        if (oldAccount.SMC_Service_Pilot__c != null) {
          oldListPilot.add(oldAccount.SMC_Service_Pilot__c);
        }
        if (oldAccount.SMC_PCO_Pilot__c != null) {
          oldListPilot.add(oldAccount.SMC_PCO_Pilot__c);
        }
        if (oldAccount.SMC_PCS_Pilot__c != null) {
          oldListPilot.add(oldAccount.SMC_PCS_Pilot__c);
        }
        if (oldAccount.SMC_ESS_Pilot__c != null) {
          oldListPilot.add(oldAccount.SMC_ESS_Pilot__c);
        }
      }
    }

    //Get new list to compare
    for (Account account : newList) {
      Set<Id> newListPilot = new Set<Id>();
      if (account.SMC_EE_Pilot__c != null) {
        newListPilot.add(account.SMC_EE_Pilot__c);
      }
      if (account.SMC_Service_Pilot__c != null) {
        newListPilot.add(account.SMC_Service_Pilot__c);
      }
      if (account.SMC_PCO_Pilot__c != null) {
        newListPilot.add(account.SMC_PCO_Pilot__c);
      }
      if (account.SMC_PCS_Pilot__c != null) {
        newListPilot.add(account.SMC_PCS_Pilot__c);
      }
      if (account.SMC_ESS_Pilot__c != null) {
        newListPilot.add(account.SMC_ESS_Pilot__c);
      }

      if (newListPilot.contains(UserInfo.getUserId())) {
        newListPilot.remove(UserInfo.getUserId());
      }

      //Search team's pilot and owner
      for (AccountTeamMember atm : teamMembers) {
        if (account.Id == atm.AccountId && newListPilot.contains(atm.UserId)) {
          if (
            atm.TeamMemberRole == STA_UtilsStatic.ROLE_OWNER &&
            atm.TeamMemberRole == STA_UtilsStatic.ROLE_PILOT
          ) {
            Datetime atmLastModifiedDatePlusOne = atm.LastModifiedDate.addMinutes(
              1
            );
            if (atmLastModifiedDatePlusOne < Datetime.now()) {
              newListPilot.remove(atm.UserId);
            }
          }
        }
      }

      //Notify users
      for (Id pilotId : newListPilot) {
        if (oldListPilot.size() > 0 && !oldListPilot.contains(pilotId)) {
          Map<String, Object> variablesMap = new Map<String, Object>();
          variablesMap.put(STA_UtilsStatic.TARGET_ID, account.Id);
          variablesMap.put(STA_UtilsStatic.MENTION_USER_ID, pilotId);
          variablesMap.put(
            STA_UtilsStatic.MESSAGE,
            STA_UtilsStatic.NEW_ACCOUNT_TEAM_PILOT + account.Name
          );
          Flow.Interview.SMC_Post_Chatter_By_Flow postChatterFlow = new Flow.Interview.SMC_Post_Chatter_By_Flow(
            variablesMap
          );
          if (Test.isRunningTest()) {
            postChatterFlow.start();
          }
        }
      }
    }
  }

  /**
   * @description : update Scoring when account is update
   * @author Vincent RECASENS (Modis)
   * @param newList
   * @param oldMap
   **/
  public static void prepareUpdateScoring(
    List<Account> newList,
    Map<Id, Account> oldMap
  ) {
    Set<Id> accountIdToUpdate = new Set<Id>();
    for (Account newAccount : newList) {
      Account oldAccount = oldMap.get(newAccount.Id);
      //Check if there is a modification impacting Scoring/Discount
      if (
        newAccount.BillingCountryCode != oldAccount.BillingCountryCode ||
        newAccount.SMC_PCO_Price_List__c != oldAccount.SMC_PCO_Price_List__c ||
        newAccount.SMC_Category__c != oldAccount.SMC_Category__c ||
        newAccount.SMC_Business__c != oldAccount.SMC_Business__c ||
        newAccount.SMC_Pricing_Tier__c != oldAccount.SMC_Pricing_Tier__c
      ) {
        accountIdToUpdate.add(newAccount.Id);
      }
    }

    if (accountIdToUpdate.size() > 0) {
      SMC_AP_FutureCallout.callUpdateScoring(accountIdToUpdate);
    }
  }

  /**
   * @description : create error log for callout
   * @author Vincent RECASENS (Modis)
   * @param logs
   * @param nameLog
   * @param processType
   * @param requestBody
   * @param requestQuery
   **/
  public static void createErrorLog(
    List<Exception> logs,
    String nameLog,
    String processType,
    String requestBody,
    String requestQuery
  ) {
    // Generating a SMC_Log__c sObject
    string logName = nameLog;
    SMC_Log__c basicLog = SMC_UTIL_Methods_Batch.newBasicLog(
      false,
      logName,
      processType
    );
    basicLog.SMC_Parameters__c = requestBody;
    basicLog.SMC_Query__c = requestQuery;

    //Catched error in a new log line
    List<SMC_Log_Line__c> detailledLogs = new List<SMC_Log_Line__c>();
    for (Exception e : logs) {
      detailledLogs.add(SMC_UTIL_Methods_Batch.handleException(e, basicLog.Id)); //The code is temporary a magic number
    }
    insert detailledLogs;
  }
}