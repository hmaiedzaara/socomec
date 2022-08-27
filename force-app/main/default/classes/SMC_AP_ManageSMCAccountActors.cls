/*
---------------------------------------------------------------------
-- - Name          : SMC_AP_ManageSMCAccountActors
-- - Author        : David SOBCZAK (DOS)
-- - Description   : Manage SMC Account Actors               
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  -------------------------------------------------------
-- 31-Mai-2017  DOS    1.0     Initial version
-------
*/
public with sharing class SMC_AP_ManageSMCAccountActors {
  /**
   * @description : manage account actors (insert/update/delete)
   * @author Vincent RECASENS (Modis) | 08/04/2020
   * @param p_old_accountactors
   * @param p_new_accountactors
   * @param map_old_accountactors
   * @param isInsert 
   **/
  public static void bidirectionalActorsManagement(
    List<SMC_Account_Actors__c> p_old_accountactors,
    List<SMC_Account_Actors__c> p_new_accountactors,
    Map<Id, SMC_Account_Actors__c> map_old_accountactors,
    Boolean isInsert
  ) {
    List<SMC_Account_Actors__c> accountActorsToCreate = new List<SMC_Account_Actors__c>();
    List<SMC_Account_Actors__c> accountActorsToUpdateRole = new List<SMC_Account_Actors__c>();
    Map<Id, SMC_Account_Actors__c> mapOppositeIdToAccount = new Map<Id, SMC_Account_Actors__c>();
    List<SMC_Account_Actors__c> accountActorsToDelete = new List<SMC_Account_Actors__c>();
    // Retrieve account actors triggered opposite relation if it's exist
    Map<String, SMC_Account_Actors__c> accountActorsBidirectionalMap = new Map<String, SMC_Account_Actors__c>();

    // We need to keep on priority old_value to manage correctly update trigger
    if (p_old_accountactors != null && !p_old_accountactors.IsEmpty()) {
      accountActorsBidirectionalMap = getBidirectionalRelation(
        p_old_accountactors
      );
    } else if (p_new_accountactors != null && !p_new_accountactors.IsEmpty()) {
      accountActorsBidirectionalMap = getBidirectionalRelation(
        p_new_accountactors
      );
    }

    //Se servir du old pour comparer les roles seulement

    if (p_new_accountactors != null && !p_new_accountactors.IsEmpty()) {
      for (SMC_Account_Actors__c aa : p_new_accountactors) {
        String oppositeUniqueId = getGenerateOppositeUniqueId(aa);
        if (
          accountActorsBidirectionalMap == null ||
          !accountActorsBidirectionalMap.containsKey(oppositeUniqueId)
        ) {
          SMC_Account_Actors__c newAccountActor = getNewOppositeAccountActors(
            aa
          );
          accountActorsToCreate.add(newAccountActor);
          accountActorsToUpdateRole.add(newAccountActor);
          mapOppositeIdToAccount.put(newAccountActor.SMC_Account_Actors__c, aa);
        } else if (
          isInsert != null && !isInsert &&
          map_old_accountactors != null &&
          aa.SMC_Role__c != map_old_accountactors.get(aa.Id).SMC_Role__c
        ) {
          accountActorsToUpdateRole.add(
            accountActorsBidirectionalMap.get(oppositeUniqueId)
          );
          mapOppositeIdToAccount.put(
            accountActorsBidirectionalMap.get(oppositeUniqueId)
              .SMC_Linked_Account__c,
            aa
          );
        }
      }
    }

    insert accountActorsToCreate;

    if (
      isInsert != null &&
      accountActorsToUpdateRole.size() > 0 &&
      mapOppositeIdToAccount.size() > 0
    ) {
      manageRoles(accountActorsToUpdateRole, mapOppositeIdToAccount, isInsert);
    } else if (isInsert == null) {
      // If there is old value (we are in update or delete trigger) we delete opposite relation if it exists
      // if(p_old_accountactors != NULL && !p_old_accountactors.IsEmpty()) {
      for (SMC_Account_Actors__c aa : p_old_accountactors) {
        String oppositeUniqueId = getGenerateOppositeUniqueId(aa);
        if (
          accountActorsBidirectionalMap != null &&
          accountActorsBidirectionalMap.containsKey(oppositeUniqueId)
        ) {
          accountActorsToDelete.add(
            accountActorsBidirectionalMap.get(oppositeUniqueId)
          );
        }
      }
      // }
      delete accountActorsToDelete;
    }
  }

  /**
   * @description : get opposite account actors
   * @author Vincent RECASENS (Modis) | 08/04/2020
   * @param p_accountactors
   * @return Map<String, SMC_Account_Actors__c>
   **/
  @TestVisible
  private static Map<String, SMC_Account_Actors__c> getBidirectionalRelation(
    List<SMC_Account_Actors__c> p_accountactors
  ) {
    // Get Activity_CRM_Id from child event
    List<String> accountActorsIdUnique = new List<string>();
    for (SMC_Account_Actors__c aa : p_accountactors) {
      accountActorsIdUnique.add(getGenerateOppositeUniqueId(aa));
    }
    // Get parent event in a map with CRM_id for key because it's the only link between child and parent
    Map<String, SMC_Account_Actors__c> bidirectionalRelations = new Map<String, SMC_Account_Actors__c>();
    for (SMC_Account_Actors__c bidirectionalRelation : [
      SELECT
        Id,
        SMC_Account_Actors__c,
        SMC_Linked_Account__c,
        SMC_Unique_Id_Account_Actors__c,
        SMC_Role__c
      FROM SMC_Account_Actors__c
      WHERE SMC_Unique_Id_Account_Actors__c IN :accountActorsIdUnique
    ]) {
      if (
        !bidirectionalRelations.containsKey(
          bidirectionalRelation.SMC_Unique_Id_Account_Actors__c
        )
      ) {
        bidirectionalRelations.put(
          bidirectionalRelation.SMC_Unique_Id_Account_Actors__c,
          bidirectionalRelation
        );
      }
    }
    return bidirectionalRelations;
  }

  /**
   * @description : generate unique id
   * @author Vincent RECASENS (Modis) | 08/04/2020
   * @param p_accountactor
   * @return String
   **/
  @TestVisible
  private static String getGenerateOppositeUniqueId(
    SMC_Account_Actors__c p_accountactor
  ) {
    return p_accountactor.SMC_Linked_Account__c +
      '#' +
      p_accountactor.SMC_Account_Actors__c;
  }

  /**
   * @description : create opposite account actor
   * @author Vincent RECASENS (Modis) | 08/04/2020
   * @param p_accountactor
   * @return SMC_Account_Actors__c
   **/
  @TestVisible
  private static SMC_Account_Actors__c getNewOppositeAccountActors(
    SMC_Account_Actors__c p_accountactor
  ) {
    SMC_Account_Actors__c aa = new SMC_Account_Actors__c();
    aa.SMC_Account_Actors__c = p_accountactor.SMC_Linked_Account__c;
    aa.SMC_Linked_Account__c = p_accountactor.SMC_Account_Actors__c;
    return aa;
  }

  /**
   * @description : manage roles thanks to SMC_AccountActors_Role__mdt metatdata
   * @author Vincent RECASENS (Modis) | 08/04/2020
   * @param oppositeRelationToUpdate
   * @param mapOppositeIdToAccount
   * @param isInsert 
   **/
  public static void manageRoles(
    List<SMC_Account_Actors__c> oppositeRelationToUpdate,
    Map<Id, SMC_Account_Actors__c> mapOppositeIdToAccount,
    Boolean isInsert
  ) {
    List<SMC_AccountActors_Role__mdt> accountActorsMeta = [
      SELECT Account_Customer__c, Account_Supplier__c
      FROM SMC_AccountActors_Role__mdt
      LIMIT 200
    ]; //There are not 200 elements in this custom metadata

    for (SMC_Account_Actors__c oneAccountActor : oppositeRelationToUpdate) {
      for (SMC_AccountActors_Role__mdt oneMeta : accountActorsMeta) {
        if (isInsert) {
          if (
            mapOppositeIdToAccount.get(oneAccountActor.SMC_Account_Actors__c)
              .SMC_Role__c == oneMeta.Account_Supplier__c
          ) {
            oneAccountActor.SMC_Role__c = oneMeta.Account_Customer__c;
            break;
          } else if (
            mapOppositeIdToAccount.get(oneAccountActor.SMC_Account_Actors__c)
              .SMC_Role__c == oneMeta.Account_Customer__c
          ) {
            oneAccountActor.SMC_Role__c = oneMeta.Account_Supplier__c;
            break;
          }
        } else {
          if (
            mapOppositeIdToAccount.get(oneAccountActor.SMC_Linked_Account__c)
              .SMC_Role__c == oneMeta.Account_Supplier__c
          ) {
            oneAccountActor.SMC_Role__c = oneMeta.Account_Customer__c;
            break;
          } else if (
            mapOppositeIdToAccount.get(oneAccountActor.SMC_Linked_Account__c)
              .SMC_Role__c == oneMeta.Account_Customer__c
          ) {
            oneAccountActor.SMC_Role__c = oneMeta.Account_Supplier__c;
            break;
          }
        }
      }
    }

    update oppositeRelationToUpdate;
  }
}