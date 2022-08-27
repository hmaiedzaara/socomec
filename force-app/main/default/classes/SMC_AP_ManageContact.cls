/*
---------------------------------------------------------------------
-- - Name          : SMC_AP_ManageContact
-- - Author        : Xavier BRANCHE
-- - Description   : Manage Contact               
-- Maintenance History:
--
-- Date         Name             		Version  Remarks 
-- -----------  ----           			------  ---------------------------
-- 28-JUL-2017  SMC_AP_ManageContact    1.0      Initial version 
-- 21-NOV-2017  VRECA                   1.2      Add method "checkIfContactIfIMPartner"
---------------------------------------------------------------------
*/
public with sharing class SMC_AP_ManageContact {
  public static void eraseCrmCodeInsert(List<Contact> newList) {
    Set<Id> contactIds = new Set<Id>();
    for (Contact oneContact : newList) {
      if (
        ((oneContact.SMC_Contact_Number__c == null ||
        oneContact.SMC_Contact_Number__c == '') &&
        (oneContact.SMC_Contact_External_Id__c == null ||
        oneContact.SMC_Contact_External_Id__c == '')) ||
        oneContact.SMC_Contact_Number__c !=
        oneContact.SMC_Contact_External_Id__c
      ) {
        contactIds.add(oneContact.Id);
      }
    }
    if (contactIds.size() > 0) {
      manageCrmCode(contactIds);
    }
  }
  @Future
  public static void manageCrmCode(Set<Id> contactIds) {
    List<Contact> contactsToUpdate = new List<Contact>{
      [
        SELECT
          Id,
          SMC_Contact_Number__c,
          SMC_Contact_External_Id__c,
          SMC_CRM_ID__c,
          Description
        FROM Contact
        WHERE Id IN :contactIds
      ]
    };
    for (Contact oneContact : contactsToUpdate) {
      if (
        oneContact.SMC_Contact_Number__c == null ||
        oneContact.SMC_Contact_Number__c == ''
      ) {
        oneContact.SMC_Contact_Number__c = oneContact.SMC_CRM_ID__c;
        oneContact.SMC_Contact_External_Id__c = oneContact.SMC_CRM_ID__c;
      } else {
        oneContact.SMC_Contact_External_Id__c = oneContact.SMC_Contact_Number__c;
      }
    }

    if (contactsToUpdate.size() > 0) {
      update contactsToUpdate;
    }
  }

  public class ContactSyncedToAccount {
    @AuraEnabled
    public Account account { get; set; }

    @AuraEnabled
    public Contact contact { get; set; }

    public ContactSyncedToAccount() {
    }

    public ContactSyncedToAccount(Account account, Contact contact) {
      this.account = account;
      this.contact = contact;
    }
  }

  /**
   * @description : display message if sync contact with account is no longer sync
   * @author Vincent RECASENS (Modis) | 08/04/2020
   * @param newList
   * @return Boolean
   **/
  public static Boolean showMessageSyncContact(List<Contact> newList) {
    System.debug(
      LoggingLevel.INFO,
      '## >>> SMC_AP_ManageContact showMessageSyncContact : START <<< ##'
    );

    Set<Id> accounIds = new Set<Id>();
    for (Contact oneContact : newList) {
      if (oneContact.SMC_Sync_With_Address_Account__c) {
        accounIds.add(oneContact.AccountId);
      }
    }
    List<Account> accounts = new List<Account>();
    accounts = [
      SELECT
        Id,
        Name,
        BillingCity,
        BillingCountry,
        BillingCountryCode,
        BillingGeocodeAccuracy,
        BillingLongitude,
        BillingLatitude,
        BillingState,
        BillingStateCode,
        BillingStreet,
        BillingPostalCode
      FROM Account
      WHERE Id IN :accounIds
    ];
    List<ContactSyncedToAccount> csta = new List<ContactSyncedToAccount>();
    for (Contact oneContact : newList) {
      if (oneContact.SMC_Sync_With_Address_Account__c) {
        for (Account oneAccount : accounts) {
          if (oneContact.AccountId == oneAccount.Id) {
            csta.add(new ContactSyncedToAccount(oneAccount, oneContact));
          }
        }
      }
    }

    for (ContactSyncedToAccount oneCtsa : csta) {
      // If contact is synced to an account, check every field from address compound field,
      // except MailingCountry : it is populated in AfterInsert
      if (
        oneCtsa.contact.MailingCity == null &&
        oneCtsa.contact.MailingCountryCode == null &&
        oneCtsa.contact.MailingGeocodeAccuracy == null &&
        oneCtsa.contact.MailingLongitude == null &&
        oneCtsa.contact.MailingLatitude == null &&
        oneCtsa.contact.MailingState == null &&
        oneCtsa.contact.MailingStateCode == null &&
        oneCtsa.contact.MailingStreet == null &&
        oneCtsa.contact.MailingPostalCode == null
      ) {
        SMC_AP_DoNothingClass.doNothing();
      } else if (
        oneCtsa.contact.MailingCity != oneCtsa.account.BillingCity ||
        oneCtsa.contact.MailingCountryCode !=
        oneCtsa.account.BillingCountryCode ||
        oneCtsa.contact.MailingLongitude != oneCtsa.account.BillingLongitude ||
        oneCtsa.contact.MailingLatitude != oneCtsa.account.BillingLatitude ||
        oneCtsa.contact.MailingState != oneCtsa.account.BillingState ||
        oneCtsa.contact.MailingStateCode != oneCtsa.account.BillingStateCode ||
        oneCtsa.contact.MailingStreet != oneCtsa.account.BillingStreet ||
        oneCtsa.contact.MailingPostalCode != oneCtsa.account.BillingPostalCode
      ) {
        oneCtsa.contact.addError(
          String.escapeSingleQuotes(System.Label.SMC_ContactSyncAcocunt),
          true
        );
        return false;
      }
    }

    System.debug(
      LoggingLevel.INFO,
      '## >>> SMC_AP_ManageContact showMessageSyncContact : END <<< ##'
    );
    return true;
  }

  /**
   * @description : flag contact as a partner
   * @author Vincent RECASENS (Modis) | 08/04/2020
   * @param contactIdToUserId
   * @param flagOrUnflag
   **/
  @Future
  public static void flagPartnerContact(
    Map<Id, Id> contactIdToUserId,
    Boolean flagOrUnflag
  ) {
    System.debug(
      LoggingLevel.INFO,
      '## >>> SMC_AP_ManageContact flagPartnerContact:START <<< ##'
    );

    List<Contact> contacts = new List<Contact>();
    contacts = [
      SELECT Id, SMC_Is_Partner_Contact__c, SMC_TECH_Partner_User__c
      FROM Contact
      WHERE Id IN :contactIdToUserId.keySet()
    ];
    for (Contact oneContact : contacts) {
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
      update contacts;
    } catch (DMLException dmlException) {
      System.debug(
        LoggingLevel.INFO,
        'ERROR TO UPDATE PARTNER CONTACT --> ' + dmlException
      );
    }

    System.debug(
      LoggingLevel.INFO,
      '## >>> SMC_AP_ManageContact flagPartnerContact:END <<< ##'
    );
  }

  /**
   * @description : prevent delete if user has not the permissions and contact is linked to an opportunity
   * @author Vincent RECASENS (Modis) | 08/04/2020
   * @param oldMap
   **/
  public static void checkContactToMassDeleteAndLinkOpportunity(
    Map<Id, Contact> oldMap
  ) {
    System.debug(
      LoggingLevel.INFO,
      '## >>> AP_Managecontact checkERPcontactToMassDelete : START <<< ##'
    );

    // The limit is 50.000, but it is possible to find an contact in multiple Opportunity.
    // To prevent error, the limit is 5.000
    // Integer maximumRecordsRetrievedBySOQL = 5000;

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
        onePas.PermissionSet.Name ==
        STA_UtilsStatic.BUSINESS_ADMIN_PERMISSION ||
        onePas.PermissionSet.Name == STA_UtilsStatic.FRENCH_ADDON_PERMISSION //STA_UtilsStatic.MASS_DELETE_PERMISSION
      ) {
        isAuthorizeToManageQuote = true;
        break;
      }
    }

    //Get Custom Permission
    isAuthorizeToManageQuote = (FeatureManagement.checkPermission(
        STA_UtilsStatic.DELETE_OPPORTUNITY_PERMISSION
      )
      ? true
      : isAuthorizeToManageQuote);

    if (isAuthorizeToManageQuote) {
      for (Opportunity oneOpp : [
        SELECT Id, SMC_Primary_Contact__c, SMC_Project_Contact_Lookup__c
        FROM Opportunity
        WHERE
          SMC_Primary_Contact__c IN :oldMap.keySet()
          AND SMC_Project_Contact_Lookup__c IN :oldMap.keySet()
      ]) {
        if (oldMap.keySet().contains(oneOpp.SMC_Primary_Contact__c)) {
          oldMap.get(oneOpp.SMC_Primary_Contact__c)
            .addError(
              String.escapeSingleQuotes(
                System.Label.SMC_ContactLinkOpportunity
              ),
              true
            );
        } else if (
          oldMap.keySet().contains(oneOpp.SMC_Project_Contact_Lookup__c)
        ) {
          oldMap.get(oneOpp.SMC_Project_Contact_Lookup__c)
            .addError(
              String.escapeSingleQuotes(
                System.Label.SMC_ContactLinkOpportunity
              ),
              true
            );
        }
      }
    } else {
      oldMap.values()[0]
        .addError(
          String.escapeSingleQuotes(
            System.Label.SMC_DeleteContactWithoutPermission
          ),
          true
        );
    }

    System.debug(
      LoggingLevel.INFO,
      '## >>> AP_Managecontact checkERPcontactToMassDelete : END <<< ##'
    );
  }

  /**
   * @description : check activities the last 2 years and prevent deletion if there are
   * @author Vincent RECASENS (Modis) | 11-13-2020
   * @param oldMap
   **/
  public static void checkActivitiesOnContact(Map<Id, Contact> oldMap) {
    // if (
    //   !FeatureManagement.checkPermission(
    //     STA_UtilsStatic.KEY_USER_DEVELOPERNAME
    //   ) &&
    //   !FeatureManagement.checkPermission(
    //     STA_UtilsStatic.BUSINESS_ADMIN_DEVELOPERNAME
    //   )
    // ) {
    Datetime timeLastTwoYear = Datetime.now().addYears(-2);
    //Task
    Set<Id> contactDoNotDelete = new Set<Id>();
    for (Task oneTask : [
      SELECT Id, WhoId, Type
      FROM Task
      WHERE WhoId IN :oldMap.keySet() AND LastModifiedDate >= :timeLastTwoYear
    ]) {
      if (oneTask.Type == 'Call') {
        contactDoNotDelete.add(oneTask.WhoId);
      }
    }
    //Event
    for (Event oneEvent : [
      SELECT Id, WhoId, Type, SMC_Event_Type__c
      FROM Event
      WHERE WhoId IN :oldMap.keySet() AND LastModifiedDate >= :timeLastTwoYear
    ]) {
      if (oneEvent.SMC_Event_Type__c == 'VISIT' || oneEvent.Type == 'Visit') {
        contactDoNotDelete.add(oneEvent.WhoId);
      }
    }

    if (contactDoNotDelete.size() > 0) {
      for (Id oneId : contactDoNotDelete) {
        oldMap.get(oneId)
          .addError(
            'You can\'t delete this contact cause there are activities active in the last 2 years.'
          );
      }
    }
    // }
  }

  public static void preventDeletionContact(Map<Id, Contact> mapContact){
    Datetime timeLastTwoYear = Datetime.now().addYears(-2);
      
    //Get PermissionSet
    Boolean isAuthorizeToDeleteContact = false;
    List<PermissionSetAssignment> pasList = new List<PermissionSetAssignment>();
    try{
        pasList = [SELECT Assignee.Id, PermissionSet.Id, PermissionSet.Name
                   FROM PermissionSetAssignment
                   WHERE Assignee.Id = :UserInfo.getUserId() AND 
                       (PermissionSet.Name = :STA_UtilsStatic.KEY_USER_PERMISSION OR 
                         PermissionSet.Name = :STA_UtilsStatic.BUSINESS_ADMIN_PERMISSION OR 
                         PermissionSet.Name = :STA_UtilsStatic.FRENCH_ADDON_PERMISSION)];
        if(pasList.size() > 0)
        isAuthorizeToDeleteContact = true;
    }
    catch(Exception e){
      System.debug('User has no permission to delete Contact');
    }

    //User has no permission to delete Contact
    if(!isAuthorizeToDeleteContact){
      for(Contact oneCtc : mapContact.values()){
        oneCtc.addError(String.escapeSingleQuotes(System.Label.SMC_DeleteContactWithoutPermission), true);
      }
      return;
    }
    //Get Opportunities
    Map<Id, Boolean> mapRefContactId_FindAtLeastOneOpp = new Map<Id, Boolean>();
    for(Opportunity oneOpp : [SELECT SMC_Primary_Contact__c, 
                                       SMC_Project_Contact_Lookup__c 
                                FROM Opportunity 
                                WHERE SMC_Primary_Contact__c IN :mapContact.keySet() OR 
                                      SMC_Project_Contact_Lookup__c IN :mapContact.keySet()]){
      if(oneOpp.SMC_Primary_Contact__c != null){
        mapRefContactId_FindAtLeastOneOpp.put(oneOpp.SMC_Primary_Contact__c, true);
      }
      if(oneOpp.SMC_Project_Contact_Lookup__c != null){
        mapRefContactId_FindAtLeastOneOpp.put(oneOpp.SMC_Project_Contact_Lookup__c, true);
      }
    }

    Boolean authorizedToDelete = FeatureManagement.checkPermission(STA_UtilsStatic.DELETE_OPPORTUNITY_PERMISSION);
    if(Test.isRunningTest()){
      User testUser = [SELECT Id, Profile.Name FROM User WHERE Id = :UserInfo.getUserId()];
      if(testUser.Profile.Name == STA_UtilsStatic.PROFILE_SMC_STANDARD_SERVICE_SOCOMEC){
        authorizedToDelete = false;
      }
    }
    

    //Prevent Contact deletion
    for(Contact oneContact : [SELECT Id, 
                                     pi__url__c, 
                                     (SELECT WhoId 
                                     FROM Events 
                                     WHERE (SMC_Event_Type__c = 'VISIT' OR Type = 'Visit') 
                                             AND LastModifiedDate >= :timeLastTwoYear LIMIT 1), 
                                     (SELECT WhoId 
                                     FROM Tasks 
                                     WHERE Type = 'Call' 
                                           AND LastModifiedDate >= :timeLastTwoYear LIMIT 1), 
                                     (SELECT ContactId FROM Quotes LIMIT 1)
                             FROM Contact
                             WHERE Id IN :mapContact.keySet()]){
      if(oneContact.pi__url__c != null && oneContact.pi__url__c != ''){
        mapContact.get(oneContact.Id).addError('You can\'t delete this contact because it is linked to Pardot.', true);
      }
      if(oneContact.Events.size() > 0 ||oneContact.Tasks.size() > 0){
        mapContact.get(oneContact.Id).addError('You can\'t delete this contact because there are active tasks or events in the last 2 years.', true);
      }
      if(oneContact.Quotes.size() > 0){
        mapContact.get(oneContact.Id).addError('You can\'t delete this contact because there are at least one quote linked to this contact.', true);
      }
      if(!authorizedToDelete){
        if(mapRefContactId_FindAtLeastOneOpp.get(oneContact.Id) != null && 
           mapRefContactId_FindAtLeastOneOpp.get(oneContact.Id)){
          mapContact.get(oneContact.Id).addError('You can\'t delete this contact because there are at least one opportunity linked to this contact.', true);
        }
      }
    }
  }
}