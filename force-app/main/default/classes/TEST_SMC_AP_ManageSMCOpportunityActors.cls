/*
---------------------------------------------------------------------
-- - Name          : TEST_SMC_AP_ManageSMCOpportunityActors
-- - Author        : David SOBCZAK (DOS)
-- - Description   : Test the Manage SMC_Opportunity_Actors              
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  -------------------------------------------------------
-- 13-Jun-2017  DOS    1.0     Initial version
--------------------------------------------------------------------------------------
*/

@IsTest
public without sharing class TEST_SMC_AP_ManageSMCOpportunityActors {
  /**
   * @description : test setup
   * @author Vincent RECASENS (Modis) | 07-15-2020
   **/
  @testSetup
  static void allTheDataForThisTestClass() {
    PAD.bypassAll = true;

    // Generate users
    Profile profileStandard = [
      SELECT Id
      FROM Profile
      WHERE Name = :STA_UtilsStatic.PROFILE_SALE_STANDARD
    ];
    User user = SMC_UTIL_TestUtils.createUser(
      STA_UtilsStatic.TEST_DIESE,
      STA_UtilsStatic.EMAIL_TEST,
      profileStandard.Id,
      STA_UtilsStatic.USERNAME_TEST,
      STA_UtilsStatic.USER_NICKNAME
    );
    insert user;
    Id userId = user.Id;

    // Generate Account
    Map<String, Schema.RecordTypeInfo> recordTypesAccount = new Map<String, Schema.RecordTypeInfo>();
    recordTypesAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName();
    Id recordTypeAccCustomerId = recordTypesAccount.get(
        STA_UtilsStatic.RECORDTYPE_ACCOUNT_CUSTOMER_DEVNAME
      )
      .getRecordTypeId();
    Account account = SMC_UTIL_TestUtils.createAccount(
      recordTypeAccCustomerId,
      STA_UtilsStatic.ACCOUNT_NAME1,
      STA_UtilsStatic.PICKLIST_ACCOUNT_TYPE_CUSTOMER,
      STA_UtilsStatic.ACCOUNT_BILLINGSTREET1,
      STA_UtilsStatic.ACCOUNT_BILLINGPOSTALCODE1,
      STA_UtilsStatic.ACCOUNT_BILLINGCITY1,
      STA_UtilsStatic.ACCOUNT_BILLINGSTATE1,
      STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY1,
      userId,
      userId,
      userId,
      userId,
      userId
    );

    insert account;
    Id accId = account.Id;

    // Generate Contacts
    Contact contact1 = SMC_UTIL_TestUtils.createContact(
      STA_UtilsStatic.CONTACT_FIRSTNAME1,
      STA_UtilsStatic.CONTACT_LASTNAME1,
      STA_UtilsStatic.CONTACT_PHONE1,
      STA_UtilsStatic.CONTACT_MOBILEPHONE1,
      STA_UtilsStatic.CONTACT_EMAIL1,
      STA_UtilsStatic.CONTACT_MAILINGSTREET1,
      STA_UtilsStatic.CONTACT_MAILINGPOSTALCODE1,
      STA_UtilsStatic.CONTACT_MAILINGCITY1,
      STA_UtilsStatic.CONTACT_MAILINGSTATE1,
      STA_UtilsStatic.CONTACT_MAILINGCOUNTRY1,
      STA_UtilsStatic.CONTACT_OTHERCITY1,
      accId
    );

    Contact contact2 = SMC_UTIL_TestUtils.createContact(
      STA_UtilsStatic.CONTACT_FIRSTNAME2,
      STA_UtilsStatic.CONTACT_LASTNAME2,
      STA_UtilsStatic.CONTACT_PHONE2,
      STA_UtilsStatic.CONTACT_MOBILEPHONE2,
      STA_UtilsStatic.CONTACT_EMAIL2,
      STA_UtilsStatic.CONTACT_MAILINGSTREET2,
      STA_UtilsStatic.CONTACT_MAILINGPOSTALCODE2,
      STA_UtilsStatic.CONTACT_MAILINGCITY2,
      STA_UtilsStatic.CONTACT_MAILINGSTATE2,
      STA_UtilsStatic.CONTACT_MAILINGCOUNTRY2,
      STA_UtilsStatic.CONTACT_OTHERCITY2,
      accId
    );

    List<Contact> contacts = new List<Contact>();
    contacts.add(contact1);
    contacts.add(contact2);
    insert contacts;
    Id conId1 = contacts[0].Id;

    // Generate Opportunity
    Map<String, Schema.RecordTypeInfo> recordTypesOpportunity = new Map<String, Schema.RecordTypeInfo>();
    recordTypesOpportunity = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName();
    Id recordTypeIdOpp = recordTypesOpportunity.get(
        STA_UtilsStatic.RECORDTYPE_OPPORTUNITY_PROJECT
      )
      .getRecordTypeId();
    Opportunity opp = SMC_UTIL_TestUtils.createOpportunity(
      recordTypeIdOpp,
      STA_UtilsStatic.TEST,
      STA_UtilsStatic.OPPORTUNITY_PROJECT_DETECTED
    );
    insert opp;
    Id oppId = opp.Id;

    // Generate Opp Actors
    SMC_Opportunity_Actors__c oa = SMC_UTIL_TestUtils.createOpportunityActors(
      oppId,
      accId,
      conId1,
      true
    );
    insert oa;

    PAD.bypassAll = false;
  }

  /**
  * @description : test opportunity actors management (add/remove) by trigger
  * @author Vincent RECASENS (Modis) | 07-15-2020 
  **/
  @IsTest
  public static void addAndRemoveOppActors() {
    // Retrieve information
    Opportunity opp = [
      SELECT Id
      FROM Opportunity
      WHERE Name = :STA_UtilsStatic.TEST
      LIMIT 1
    ];

    System.debug(LoggingLevel.INFO, 'Opportunities for test : ' + opp);
    Account acc = [
      SELECT Id
      FROM Account
      WHERE Name = :STA_UtilsStatic.ACCOUNT_NAME1
      LIMIT 1
    ];
    Contact con = [
      SELECT
        Id,
        MailingStreet,
        MailingPostalCode,
        MailingCity,
        MailingState,
        MailingCountry,
        OtherStreet,
        OtherPostalCode,
        OtherCity,
        OtherState,
        OtherCountry
      FROM Contact
      WHERE email = :STA_UtilsStatic.CONTACT_EMAIL2
      LIMIT 1
    ];

    // Retrieve opportunity actors in order to delete it
    SMC_Opportunity_Actors__c oaToDelete = [
      SELECT Id
      FROM SMC_Opportunity_Actors__c
      WHERE SMC_Opportunity_Actors__c = :opp.Id
      LIMIT 1
    ];

    // Create a new Opportunity actors
    SMC_Opportunity_Actors__c oaToCreate = SMC_UTIL_TestUtils.createOpportunityActors(
      opp.Id,
      acc.Id,
      con.Id,
      true
    );

    // Launch test
    Test.startTest();
    insert oaToCreate;
    delete oaToDelete;
    Test.stopTest();

    // Retrieve opportunity actors in order to delete it
    SMC_Opportunity_Actors__c oaCreated = [
      SELECT Id
      FROM SMC_Opportunity_Actors__c
      WHERE Contact__c = :con.Id
      LIMIT 1
    ];

    System.assertNotEquals(
      null,
      oaCreated,
      'Opportunity actor was not created.'
    );
  }
}