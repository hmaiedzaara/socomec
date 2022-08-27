/**
 * @File Name          : SMC_AC_Edit_Contacts_From_Account.cls
 * @Description        :
 * @Author             : Vincent RECASENS (Modis)
 * @Group              :
 * @Last Modified By   : Vincent RECASENS (Modis)
 * @Last Modified On   : 10-01-2020
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    27/05/2020   Vincent RECASENS (Modis)     Initial Version
 **/
public with sharing class SMC_AC_Edit_Contacts_From_Account {
  public class AllContacts {
    @TestVisible
    String accountId { get; set; }
    @TestVisible
    String accountName { get; set; }
    @TestVisible
    String iotMainContactId { get; set; }
    @TestVisible
    String iotAdministrativeContactId { get; set; }
    @TestVisible
    String iotTechnicalContactId { get; set; }
    @TestVisible
    List<MapContact> mapContacts { get; set; }

    public AllContacts(
      String accountId,
      String accountName,
      String iotMainContactId,
      String iotAdministrativeContactId,
      String iotTechnicalContactId,
      List<MapContact> mapContacts
    ) {
      this.accountId = accountId;
      this.accountName = accountName;
      this.iotMainContactId = iotMainContactId;
      this.iotAdministrativeContactId = iotAdministrativeContactId;
      this.iotTechnicalContactId = iotTechnicalContactId;
      this.mapContacts = mapContacts;
    }
  }

  public class MapContact {
    @TestVisible
    String label { get; set; }
    @TestVisible
    String value { get; set; }

    public MapContact() {
    }

    public MapContact(String label, String value) {
      this.label = label;
      this.value = value;
    }
  }

  /**
   * @description : get account's contacts and IOT contacts already set
   * @author Vincent RECASENS (Modis) | 27/05/2020
   * @return String
   **/
  @AuraEnabled
  public static String getContacts() {
    String accountId = [
      SELECT SMC_Account_Id__c
      FROM User
      WHERE Id = :UserInfo.getUserId()
    ]
    .SMC_Account_Id__c;

    Account theAccount = [
      SELECT
        Id,
        Name,
        SMC_IOT_Main_Contact__c,
        SMC_IOT_Administrative_Contact__c,
        SMC_IOT_Technical_Contact__c
      FROM Account
      WHERE Id = :accountId
    ];

    List<MapContact> mapContacts = new List<MapContact>();
    for (Contact oneContact : [
      SELECT Id, Name
      FROM Contact
      WHERE AccountId = :accountId
    ]) {
      mapContacts.add(new MapContact(oneContact.Name, oneContact.Id));
    }

    return JSON.serialize(
      new AllContacts(
        accountId,
        theAccount.Name,
        theAccount.SMC_IOT_Main_Contact__c,
        theAccount.SMC_IOT_Administrative_Contact__c,
        theAccount.SMC_IOT_Technical_Contact__c,
        mapContacts
      )
    );
  }

  /**
   * @description : save new IOT contacts
   * @author Vincent RECASENS (Modis) | 08/06/2020
   * @param accountName
   * @param accountId
   * @param mainContactId
   * @param administrativeContactId
   * @param technicalContactId
   * @param mapContactsSerialized
   * @return Boolean
   **/
  @AuraEnabled
  public static Boolean saveContacts(
    String accountId,
    String accountName,
    String mainContactId,
    String administrativeContactId,
    String technicalContactId,
    String mapContactsSerialized
  ) {
    List<MapContact> mapContacts = (List<MapContact>) JSON.deserialize(
      mapContactsSerialized,
      List<MapContact>.class
    );
    String mainContactName;
    String administrativeContactName;
    String technicalContactName;
    User currentUser = [
      SELECT SMC_Account_Id__c
      FROM User
      WHERE Id = :UserInfo.getUserId()
    ];
    Account theAccount = [
      SELECT
        Id,
        SMC_IOT_Administrative_Contact__c,
        SMC_IOT_Main_Contact__c,
        SMC_IOT_Technical_Contact__c
      FROM Account
      WHERE Id = :currentUser.SMC_Account_Id__c
    ];
    for (MapContact oneMapContact : mapContacts) {
      if (
        mainContactId != null &&
        mainContactName == null &&
        oneMapContact.value == mainContactId
      ) {
        mainContactName = oneMapContact.label;
        theAccount.SMC_IOT_Main_Contact__c = oneMapContact.value;
      }
      if (
        administrativeContactId != null &&
        administrativeContactName == null &&
        oneMapContact.value == administrativeContactId
      ) {
        administrativeContactName = oneMapContact.label;
        theAccount.SMC_IOT_Administrative_Contact__c = oneMapContact.value;
      }
      if (
        technicalContactId != null &&
        technicalContactName == null &&
        oneMapContact.value == technicalContactId
      ) {
        technicalContactName = oneMapContact.label;
        theAccount.SMC_IOT_Technical_Contact__c = oneMapContact.value;
      }
    }

    if (
      mainContactName == null &&
      administrativeContactName == null &&
      technicalContactName == null
    ) {
      return null;
    } else {
      return Database.update(theAccount).isSuccess();
    }

    /*
    //   Case type  : Other
    Case newCase = new Case();
    newCase.Subject = 'Request modification IOT contacts - ' + accountName;
    newCase.Type = STA_UtilsStatic.CASE_TYPE_CUSTOMER_CLAIM;
    newCase.SMC_Case_Category__c = STA_UtilsStatic.CASE_CATEGORY_OTHER;
    newCase.AccountId = accountId;
    newCase.ContactId = [
      SELECT ContactId
      FROM User
      WHERE Id = :UserInfo.getUserId()
    ]
    .ContactId;
    //DESCRIPTION
    //Main contact
    if (mainContactName != null) {
      newCase.Description =
        'IOT Main Contact : ' +
        mainContactName +
        ' (' +
        mainContactId +
        ')';
    }
    //Administrartive Contact
    if (administrativeContactName != null) {
      if (newCase.Description != null && newCase.Description.length() > 0) {
        newCase.Description +=
          '\nIOT Administrative Contact : ' +
          administrativeContactName +
          ' (' +
          administrativeContactId +
          ')';
      } else {
        newCase.Description =
          'IOT Administrative Contact : ' +
          administrativeContactName +
          ' (' +
          administrativeContactId +
          ')';
      }
    }
    //Technical Contact
    if (technicalContactName != null) {
      if (newCase.Description != null && newCase.Description.length() > 0) {
        newCase.Description +=
          '\nIOT Administrative Contact : ' +
          technicalContactName +
          ' (' +
          technicalContactId +
          ')';
      } else {
        newCase.Description =
          'IOT Administrative Contact : ' +
          technicalContactName +
          ' (' +
          technicalContactId +
          ')';
      }
    }
    return Database.insert(newCase).isSuccess();
    */
  }
}