/*
---------------------------------------------------------------------
-- - Name          : SMC_AP_ManageSMCOpportunityActors
-- - Author        : David SOBCZAK (DOS)
-- - Description   : Class use for Opportunity Trigger actor     
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  -------------------------------------------------------
-- 15-Nov-2017  DOS    1.0     Initial version
--------------------------------------------------------------------------------------
*/

public with sharing class SMC_AP_ManageSMCOpportunityActors {
  /**
   * @description : sync opp contact with opp actor
   * @author Vincent RECASENS (Modis) | 08/04/2020
   * @param p_old_oppactors
   * @param p_new_oppactors 
   **/
  public static void syncWithOppContactRoles(
    List<SMC_Opportunity_Actors__c> p_old_oppactors,
    List<SMC_Opportunity_Actors__c> p_new_oppactors
  ) {
    System.debug(
      LoggingLevel.INFO,
      '## >>> BidirectionalActorsManagement(List<SMC_Account_Actors__c> p_old_accountactors, List<SMC_Account_Actors__c> p_new_accountactors):START <<< ##'
    );

    System.debug(LoggingLevel.INFO, 'PARAMS : ');
    System.debug(LoggingLevel.INFO, 'p_old_oppactors : ' + p_old_oppactors);
    System.debug(LoggingLevel.INFO, 'p_new_oppactors : ' + p_new_oppactors);

    List<OpportunityContactRole> oppContactRoleToCreate = new List<OpportunityContactRole>();
    List<OpportunityContactRole> oppContactRoleToDelete = new List<OpportunityContactRole>();

    // Retrieve contacts role related to the opp coming from opp actors
    Map<String, OpportunityContactRole> oppContactRoles = new Map<String, OpportunityContactRole>();
    // We need to keep on priority old_value to manage correctly update trigger
    if (p_old_oppactors != null && !p_old_oppactors.IsEmpty()) {
      oppContactRoles = getContactRoles(p_old_oppactors);
      System.debug(
        LoggingLevel.INFO,
        'OLD oppContactRoles : ' + oppContactRoles
      );
    }
    if (p_new_oppactors != null && !p_new_oppactors.IsEmpty()) {
      oppContactRoles = getContactRoles(p_new_oppactors);
      System.debug(
        LoggingLevel.INFO,
        'NEW oppContactRoles : ' + oppContactRoles
      );
    }

    // If there is old value (we are in update or delete trigger) we delete contact role if it exists
    if (p_old_oppactors != null && !p_old_oppactors.IsEmpty()) {
      for (SMC_Opportunity_Actors__c oa : p_old_oppactors) {
        String oppContactId = getOppContactId(oa);
        System.debug(LoggingLevel.INFO, 'Old oa : ' + oa);
        if (
          oa.Contact__c != null &&
          oppContactRoles != null &&
          oppContactRoles.containsKey(oppContactId)
        ) {
          oppContactRoleToDelete.add(oppContactRoles.get(oppContactId));
        }
      }
    }

    if (p_new_oppactors != null && !p_new_oppactors.IsEmpty()) {
      for (SMC_Opportunity_Actors__c oa : p_new_oppactors) {
        String oppContactId = getOppContactId(oa);
        System.debug(LoggingLevel.INFO, 'New oa : ' + oa);
        if (
          oa.Contact__c != null &&
          (oppContactRoles != null ||
          !oppContactRoles.containsKey(oppContactId))
        ) {
          oppContactRoleToCreate.add(getNewContactRole(oa));
        }
      }
    }
    System.debug(LoggingLevel.INFO, 'delete : ' + oppContactRoleToDelete);
    System.debug(LoggingLevel.INFO, 'create : ' + oppContactRoleToCreate);
    delete oppContactRoleToDelete;
    insert oppContactRoleToCreate;
    System.debug(
      LoggingLevel.INFO,
      '## >>> BidirectionalActorsManagement(List<SMC_Account_Actors__c> p_old_accountactors, List<SMC_Account_Actors__c> p_new_accountactors):END <<< ##'
    );
  }

  /**
   * @description : get all contacts role attached to opp coming from Opportunity Actors
   * @author Vincent RECASENS (Modis) | 08/04/2020
   * @param p_oppactors
   * @return Map<String, OpportunityContactRole>
   **/
  @TestVisible
  private static Map<String, OpportunityContactRole> getContactRoles(
    List<SMC_Opportunity_Actors__c> p_oppactors
  ) {
    // Get opps id coming from Opportunity Actors
    List<String> listOppsId = new List<string>();
    for (SMC_Opportunity_Actors__c oa : p_oppactors) {
      listOppsId.add(oa.SMC_Opportunity_Actors__c);
    }
    // Get contacts role related with opps
    Map<String, OpportunityContactRole> oppContactRoleMap = new Map<String, OpportunityContactRole>();
    for (OpportunityContactRole oppContactRole : [
      SELECT Id, ContactId, OpportunityId, Role, IsPrimary
      FROM OpportunityContactRole
      WHERE OpportunityId IN :listOppsId
    ]) {
      oppContactRoleMap.put(getOppContactId(oppContactRole), oppContactRole);
    }
    return oppContactRoleMap;
  }

  /**
   * @description : get contact id from opportunity actor
   * @author Vincent RECASENS (Modis) | 08/04/2020
   * @param p_oppActor
   * @return String
   **/
  @TestVisible
  private static String getOppContactId(SMC_Opportunity_Actors__c p_oppActor) {
    return p_oppActor.SMC_Opportunity_Actors__c + '#' + p_oppActor.Contact__c;
  }

  /**
   * @description : get contact id from opportunity contact role
   * @author Vincent RECASENS (Modis) | 08/04/2020
   * @param p_oppContactRole
   * @return String
   **/
  @TestVisible
  private static String getOppContactId(
    OpportunityContactRole p_oppContactRole
  ) {
    return p_oppContactRole.OpportunityId + '#' + p_oppContactRole.ContactId;
  }

  /**
   * @description : create new contact role
   * @author Vincent RECASENS (Modis) | 08/04/2020
   * @param p_oppActor
   * @return OpportunityContactRole
   **/
  @TestVisible
  private static OpportunityContactRole getNewContactRole(
    SMC_Opportunity_Actors__c p_oppActor
  ) {
    OpportunityContactRole ocr = new OpportunityContactRole();
    ocr.ContactId = p_oppActor.Contact__c;
    ocr.OpportunityId = p_oppActor.SMC_Opportunity_Actors__c;
    return ocr;
  }
}