/**
 * @File Name          : SMC_AC_Message_To_Customer.cls
 * @Description        :
 * @Author             : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Group              :
 * @Last Modified By   : Vincent RECASENS (Modis)
 * @Last Modified On   : 10/04/2020 à 15:02:02
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    13/01/2020   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
 **/
public with sharing class SMC_AC_Message_To_Customer {
  public class WrapperInfo {
    List<Contact> contacts { get; set; }
    Map<Id, String> mapcontactIdToContactEmail { get; set; }
    Id accountId { get; set; }
    Id pfrId { get; set; }

    public WrapperInfo() {
    }
    public WrapperInfo(
      List<Contact> contacts,
      Map<Id, String> mapcontactIdToContactEmail,
      Id accountId,
      Id pfrId
    ) {
      this.contacts = contacts;
      this.mapcontactIdToContactEmail = mapcontactIdToContactEmail;
      this.accountId = accountId;
      this.pfrId = pfrId;
    }
  }

  /**
   * @description : get all contact from Account/PartnerFundRequest
   * @author Vincent RECASENS (Modis) | 10/04/2020
   * @param recordId
   * @return String = serialization(WrapperInfo)
   **/
  @AuraEnabled
  public static String getContactsFromAccount(String recordId) {
    List<Contact> contacts = new List<Contact>();
    Map<Id, String> mapcontactIdToContactEmail = new Map<Id, String>();
    Id accountId;
    Id pfrId;
    if (((Id) recordId).getSobjectType() == Schema.Account.SObjectType) {
      accountId = recordId;
      for (Contact oneContact : [
        SELECT Id, Name, Email
        FROM Contact
        WHERE AccountId = :accountId
      ]) {
        contacts.add(oneContact);
        mapcontactIdToContactEmail.put(oneContact.Id, oneContact.Email);
      }
    } else if (
      ((Id) recordId).getSobjectType() == Schema.PartnerFundRequest.SObjectType
    ) {
      pfrId = recordId;
      PartnerFundRequest pfr = [
        SELECT Id, ChannelPartnerId
        FROM PartnerFundRequest
        WHERE Id = :recordId
      ];
      for (Contact oneContact : [
        SELECT Id, Name, Email
        FROM Contact
        WHERE AccountId = :pfr.ChannelPartnerId
      ]) {
        contacts.add(oneContact);
        mapcontactIdToContactEmail.put(oneContact.Id, oneContact.Email);
      }
    }
    WrapperInfo wrapperInfos = new WrapperInfo(
      contacts,
      mapcontactIdToContactEmail,
      accountId,
      pfrId
    );
    return JSON.serialize(wrapperInfos);
  }

  /**
   * @description : insert new CommunityMessage from SF and PB send the email
   * @author Vincent RECASENS (Modis) | 10/04/2020
   * @param title
   * @param body
   * @param selectedContact
   * @param accountId
   * @param pfrId
   * @param mapcontactIdToContactEmail
   * @return Boolean
   **/
  @AuraEnabled
  public static Boolean createCommunityMessage(
    String title,
    Blob body,
    String selectedContact,
    Id accountId,
    Id pfrId,
    Map<Id, String> mapcontactIdToContactEmail
  ) {
    try {
      SMC_Community_Message__c oneMessage = new SMC_Community_Message__c();
      oneMessage.SMC_Send_From__c = STA_UtilsStatic.SALESFORCE;
      oneMessage.Title__c = title;
      oneMessage.Message__c = body.toString();
      oneMessage.Recipient_Contact__c = selectedContact;
      oneMessage.SMC_Recipient_Email__c = mapcontactIdToContactEmail.get(
        selectedContact
      );
      if (accountId != null) {
        oneMessage.Account__c = accountId;
      }
      if (accountId != null) {
        oneMessage.Partner_Fund_Request__c = pfrId;
      }

      return Database.insert(oneMessage).isSuccess();
    } catch (Exception e) {
      System.debug(LoggingLevel.INFO, 'ERROR : ' + e);
      return false;
    }
  }
}