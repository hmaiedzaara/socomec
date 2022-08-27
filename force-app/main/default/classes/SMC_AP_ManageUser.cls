/*
----------------------------------------------------------------------------------------------
-- - Name          : SMC_AP_ManageUser
-- - Author        : Vincent RECASENS (VR) - Modis
-- - Description   : Manage users
-- - Project       : Socomec
--
-- Maintenance History:
--
-- Date         Name  	Version     Remarks
-- -----------  ----  	-------     -------------------------------------------------
-- 22-NOV-2018  VR    	1.0         Initial version
-- 22-NOV-2018  VR    	1.0         Add Queueable class to flag partner contact
----------------------------------------------------------------------------------------------
*/

public with sharing class SMC_AP_ManageUser {
  /**
   * @description : flag contact record if user is a partner
   * @author Vincent RECASENS (Modis) | 08/04/2020
   * @param newList
   **/
  public static void flagContactIfPartner(List<User> newList) {
    System.debug(
      LoggingLevel.INFO,
      '## >>> SMC_AP_ManageUser flagContactIfPartner:START <<< ##'
    );

    Map<Id, Id> contactIdToUserId = new Map<Id, Id>();
    for (User oneUser : newList) {
      if (
        oneUser.UserType == STA_UtilsStatic.PARTNER &&
        oneUser.ContactId != null
      ) {
        contactIdToUserId.put(oneUser.ContactId, oneUser.Id);
      }
    }

    if (contactIdToUserId.size() > 0) {
      System.enqueueJob(
        new LinkContactPartnerToHisUser(contactIdToUserId, true)
      );
    }

    System.debug(
      LoggingLevel.INFO,
      '## >>> SMC_AP_ManageUser flagContactIfPartner : END <<< ##'
    );
  }

  /**
   * @description : unflag contact record is user is desactivated
   * @author Vincent RECASENS (Modis) | 08/04/2020
   * @param newList
   * @param oldMap
   **/
  public static void unflagContactIfPartner(
    List<User> newList,
    Map<Id, User> oldMap
  ) {
    System.debug(
      LoggingLevel.INFO,
      '## >>> SMC_AP_ManageUser unflagContactIfPartner:START <<< ##'
    );

    Map<Id, Id> contactIdToUserId = new Map<Id, Id>();
    for (User oneUser : newList) {
      User oldUser = oldMap.get(oneUser.Id);
      if (
        oneUser.UserType == STA_UtilsStatic.PARTNER &&
        oneUser.IsActive == false &&
        oldUser.IsActive == true
      ) {
        contactIdToUserId.put(oneUser.ContactId, oneUser.Id);
      }
    }

    if (contactIdToUserId.size() > 0) {
      System.enqueueJob(
        new LinkContactPartnerToHisUser(contactIdToUserId, false)
      );
    }

    System.debug(
      LoggingLevel.INFO,
      '## >>> SMC_AP_ManageUser unflagContactIfPartner : END <<< ##'
    );
  }

  /**
   * @description : add new partner to his public group
   * @author Vincent RECASENS (Modis) | 09-03-2020
   * @param newList
   **/
  public static void addPartnerToPublicGroup(Map<Id, User> newMap) {
    // Check partner and get country code
    Map<Id, String> mapUserIdToCountryCode = new Map<Id, String>();
    for (Id oneId : newMap.keySet()) {
      if (newMap.get(oneId).UserType == STA_UtilsStatic.PARTNER) {
        mapUserIdToCountryCode.put(oneId, newMap.get(oneId).CountryCode);
      }
    }

    // Get country labels
    if (mapUserIdToCountryCode.size() > 0) {
      Map<String, Set<Id>> mapCountryLabelToUserId = new Map<String, Set<Id>>();
      for (User oneUser : [
        SELECT Id, toLabel(CountryCode)
        FROM User
        WHERE Id IN :mapUserIdToCountryCode.keySet()
      ]) {
        if (
          oneUser.CountryCode != null &&
          mapUserIdToCountryCode.get(oneUser.Id) != 'GB' &&
          mapUserIdToCountryCode.get(oneUser.Id) != 'US' &&
          mapCountryLabelToUserId.get('SMC_Partners_' + oneUser.CountryCode) ==
          null
        ) {
          mapCountryLabelToUserId.put(
            'SMC_Partners_' + oneUser.CountryCode,
            new Set<Id>{ oneUser.Id }
          );
        } else if (
          oneUser.CountryCode != null &&
          mapUserIdToCountryCode.get(oneUser.Id) != 'GB' &&
          mapUserIdToCountryCode.get(oneUser.Id) != 'US' &&
          mapCountryLabelToUserId.get('SMC_Partners_' + oneUser.CountryCode) !=
          null
        ) {
          mapCountryLabelToUserId.get('SMC_Partners_' + oneUser.CountryCode)
            .add(oneUser.Id);
        } else if (
          mapUserIdToCountryCode.get(oneUser.Id) == 'GB' &&
          mapCountryLabelToUserId.get('SMC_Partners_' + 'UK') == null
        ) {
          mapCountryLabelToUserId.put(
            'SMC_Partners_' + 'UK',
            new Set<Id>{ oneUser.Id }
          );
        } else if (
          mapUserIdToCountryCode.get(oneUser.Id) == 'GB' &&
          mapCountryLabelToUserId.get('SMC_Partners_' + 'UK') != null
        ) {
          mapCountryLabelToUserId.get('SMC_Partners_' + 'UK').add(oneUser.Id);
        } else if (
          mapUserIdToCountryCode.get(oneUser.Id) == 'US' &&
          mapCountryLabelToUserId.get('SMC_Partners_' + 'USA') == null
        ) {
          mapCountryLabelToUserId.put(
            'SMC_Partners_' + 'USA',
            new Set<Id>{ oneUser.Id }
          );
        } else if (
          mapUserIdToCountryCode.get(oneUser.Id) == 'US' &&
          mapCountryLabelToUserId.get('SMC_Partners_' + 'USA') != null
        ) {
          mapCountryLabelToUserId.get('SMC_Partners_' + 'USA').add(oneUser.Id);
        }
      }

      if (mapCountryLabelToUserId.size() > 0) {
        System.enqueueJob(
          new LinkPartnerToHisPublicGroup(mapCountryLabelToUserId)
        );
      }
    }
  }
  
  public static void setBypassFlows(List<User> newList, Map<Id, User> oldMap){
    for(User oneUser : newList){
      User newUser = oneUser;
      /* OLD ACTION --> transform with process builder conversion in flow trigger
      //Old triggered actions are ProcessBuilder, so "bypass flow <=> bypass process builder"
      if(newUser.Bypass_Process_Builder__c != oldMap.get(oneId).Bypass_Process_Builder__c){
        newUser.BypassFlow_TXT__c = newUser.Bypass_Process_Builder__c;
      }
      */
      if((oldMap != null && 
          (newUser.Bypass_Process_Builder__c != oldMap.get(newUser.Id).Bypass_Process_Builder__c || 
          newUser.Bypass_Flow_Trigger__c != oldMap.get(newUser.Id).Bypass_Flow_Trigger__c)
          ) ||
         (oldMap == null && 
          ((newUser.Bypass_Process_Builder__c != null && newUser.Bypass_Process_Builder__c != '') || 
          (newUser.Bypass_Flow_Trigger__c != null && newUser.Bypass_Flow_Trigger__c != ''))
         )
        ){
        newUser.BypassFlow_TXT__c = (newUser.Bypass_Process_Builder__c != null && newUser.Bypass_Process_Builder__c != '' ?
                                      newUser.Bypass_Process_Builder__c  + ';' : '') + 
                                    (newUser.Bypass_Flow_Trigger__c != null && newUser.Bypass_Flow_Trigger__c != '' ?
                                      newUser.Bypass_Flow_Trigger__c : '');
      }
    }
  }

  public class LinkContactPartnerToHisUser implements Queueable {
    List<Contact> contactList;
    Map<Id, Id> contactIdToUserId;
    Boolean flagOrUnflag;

    public LinkContactPartnerToHisUser(
      Map<Id, Id> contactIdToUserId,
      Boolean flagOrUnflag
    ) {
      this.contactIdToUserId = contactIdToUserId;
      this.flagOrUnflag = flagOrUnflag;
      this.contactList = [
        SELECT Id, SMC_Is_Partner_Contact__c, SMC_TECH_Partner_User__c
        FROM Contact
        WHERE Id IN :contactIdToUserId.keySet()
      ];
    }

    public void execute(QueueableContext context) {
      for (Contact oneContact : this.contactList) {
        oneContact.SMC_TECH_Partner_User__c = contactIdToUserId.get(
          oneContact.Id
        );
        if (flagOrUnflag) {
          oneContact.SMC_Is_Partner_Contact__c = true;
        } else {
          oneContact.SMC_Is_Partner_Contact__c = false;
        }
      }

      try {
        update contactList;
      } catch (DMLException dmlException) {
        System.debug(
          LoggingLevel.INFO,
          'ERROR TO UPDATE PARTNER CONTACT --> ' + dmlException
        );
      }
    }
  }

  public class LinkPartnerToHisPublicGroup implements Queueable {
    Map<String, Set<Id>> mapCountryLabelToUser;
    Map<Id, Group> groups;

    public LinkPartnerToHisPublicGroup(
      Map<String, Set<Id>> mapCountryLabelToUser
    ) {
      this.mapCountryLabelToUser = mapCountryLabelToUser;
    }

    public void execute(QueueableContext context) {
      this.groups = new Map<Id, Group>(
        [
          SELECT Id, DeveloperName
          FROM Group
          WHERE DeveloperName IN :mapCountryLabelToUser.keySet()
        ]
      );
      if (this.groups.size() > 0) {
        List<GroupMember> gmList = new List<GroupMember>();
        for (Id oneId : this.groups.keySet()) {
          for (
            Id secId : this.mapCountryLabelToUser.get(
              this.groups.get(oneId).DeveloperName
            )
          ) {
            GroupMember gm = new GroupMember();
            gm.GroupId = oneId;
            gm.UserOrGroupId = secId;
            gmList.add(gm);
          }
        }

        if (gmList.size() > 0) {
          insert gmList;
        }
      }
    }
  }
}