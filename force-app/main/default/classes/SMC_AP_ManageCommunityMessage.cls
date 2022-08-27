/**
 * @File Name          : SMC_AP_ManageCommunityMessage.cls
 * @Description        :
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              :
 * @Last Modified By   : Vincent RECASENS (Modis)
 * @Last Modified On   : 25/06/2020 à 14:55:37
 * @Modification Log   :
 * Ver       Date            Author      		                        Modification
 * 1.0       19/12/2019      ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
 * 2.0       17/06/2022      Denis PHAM                             Fix URL Host Name for Community
 **/
public with sharing class SMC_AP_ManageCommunityMessage {
  /**
   * @description : set community url
   * @author Vincent RECASENS (Modis) | 08/04/2020
   * @param newList
   **/
  public static void fillURLCustomersCompmunityField(
    List<SMC_Community_Message__c> newList
  ) {
    System.debug(
      LoggingLevel.INFO,
      'SMC_AP_ManageCommunityMessage - fillURLCustomersCompmunityField START'
    );

    //Salesforce URL
    String salesforceUrl = URL.getSalesforceBaseUrl().toExternalForm();

    for (SMC_Community_Message__c newCommunityMessage : newList) {
      if (
        newCommunityMessage.SMC_Send_From__c == STA_UtilsStatic.SALESFORCE ||
        newCommunityMessage.SMC_Send_From__c ==
        STA_UtilsStatic.COMMUNITY_CUSTOMERS
      ) {
        //Replace the Salesforce URL with the Community URL 
        String communityURL = salesforceUrl.replace('salesforce', 'site');

        newCommunityMessage.SMC_URL_Instance__c =
          communityURL +
          '/' +
          STA_UtilsStatic.CUSTOMERS_MIN;
      } else if (
        newCommunityMessage.SMC_Send_From__c ==
        STA_UtilsStatic.COMMUNITY_MYSPACE
      ) {
        newCommunityMessage.SMC_URL_Instance__c =
          salesforceUrl +
          '/' +
          STA_UtilsStatic.MYSPACE_MIN;
      } else {
        newCommunityMessage.SMC_URL_Instance__c = Url.getOrgDomainUrl()
          .toExternalForm();
      }
    }

    System.debug(
      LoggingLevel.INFO,
      'SMC_AP_ManageCommunityMessage - fillURLCustomersCompmunityField END'
    );
  }

  /**
   * @description : set user field from contact
   * @author Vincent RECASENS (Modis) | 08/04/2020
   * @param newList
   **/
  public static void fillUserLookupFromContact(
    List<SMC_Community_Message__c> newList
  ) {
    System.debug(
      LoggingLevel.INFO,
      'SMC_AP_ManageCommunityMessage - fillUserLookupFromContact START'
    );
    //Get ContactId to find User
    Set<Id> setContactId = new Set<Id>();
    Set<Id> setContactIdToFindAccount = new Set<Id>();
    for (SMC_Community_Message__c oneCommMessage : newList) {
      if (
        oneCommMessage.Recipient_Contact__c != null &&
        oneCommMessage.SMC_Send_From__c == STA_UtilsStatic.SALESFORCE &&
        oneCommMessage.Account__c == null &&
        oneCommMessage.Partner_Fund_Request__c == null
      ) {
        setContactId.add(oneCommMessage.Recipient_Contact__c);
      } else if (
        oneCommMessage.Recipient_Contact__c != null &&
        oneCommMessage.SMC_Send_From__c == STA_UtilsStatic.OTHER
      ) {
        setContactIdToFindAccount.add(oneCommMessage.Recipient_Contact__c);
      } else if (
        oneCommMessage.Recipient_Contact__c == null &&
        oneCommMessage.SMC_Send_From__c == STA_UtilsStatic.OTHER
      ) {
        oneCommMessage.addError(
          'You are not a partner. Please call your manager to report him your problem.'
        );
      }
    }

    //Find User
    if (setContactId.size() != 0) {
      Map<Id, Id> mapContactIdToUserId = new Map<Id, Id>();
      for (User oneUser : [
        SELECT Id, ContactId
        FROM User
        WHERE ContactId IN :setContactId
      ]) {
        mapContactIdToUserId.put(oneUser.ContactId, oneUser.Id);
      }

      //Set Recipient__c field with User from ContactId
      for (SMC_Community_Message__c oneCommMessage : newList) {
        oneCommMessage.Recipient__c = mapContactIdToUserId.get(
          oneCommMessage.Recipient_Contact__c
        );
      }
    }

    //Find Account
    if (setContactIdToFindAccount.size() != 0) {
      Map<Id, Contact> mapContactIdToContact = new Map<Id, Contact>();
      for (Contact oneContact : [
        SELECT Id, AccountId, Account.OwnerId
        FROM Contact
        WHERE Id IN :setContactIdToFindAccount
      ]) {
        mapContactIdToContact.put(oneContact.Id, oneContact);
      }

      //Set Account__c field
      for (SMC_Community_Message__c oneCommMessage : newList) {
        oneCommMessage.Account__c = mapContactIdToContact.get(
            oneCommMessage.Recipient_Contact__c
          )
          .AccountId;
        oneCommMessage.Recipient__c = mapContactIdToContact.get(
            oneCommMessage.Recipient_Contact__c
          )
          .Account.OwnerId;
      }
    }
    System.debug(
      LoggingLevel.INFO,
      'SMC_AP_ManageCommunityMessage - fillUserLookupFromContact END'
    );
  }
}