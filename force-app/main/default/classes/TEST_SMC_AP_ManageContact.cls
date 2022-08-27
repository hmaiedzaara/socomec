/*
---------------------------------------------------------------------
-- - Name          : TEST_SMC_AP_ManageContact
-- - Author        : Xavier BRANCHE
-- - Description   : Test the Manage Contact               
-- Maintenance History:
--
-- Date         Name  Version  Remarks 
-- -----------  ----  -------  ---------------------------
-- 30-MAI-2017  XBR   1.0     Initial version 
-- 23-JAN-2019  VRE   1.1     Review 
---------------------------------------------------------------------
*/
@IsTest
public without sharing class TEST_SMC_AP_ManageContact {
  /**
   * @description : test setup
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  @testSetup
  public static void setup() {
    //create and insert users
    Id profileId = [
      SELECT Id
      FROM Profile
      WHERE Name = :STA_UtilsStatic.PROFILE_SALE_STANDARD
    ]
    .Id;
    User user = SMC_UTIL_TestUtils.createUser(
      STA_UtilsStatic.TEST_DIESE,
      STA_UtilsStatic.EMAIL_TEST,
      profileId,
      STA_UtilsStatic.USERNAME_TEST,
      STA_UtilsStatic.USER_NICKNAME
    );
    User userBis = SMC_UTIL_TestUtils.createUser(
      'wtps_' + STA_UtilsStatic.TEST_DIESE,
      'wtps_' + STA_UtilsStatic.EMAIL_TEST,
      profileId,
      'wtps_' + STA_UtilsStatic.USERNAME_TEST,
      STA_UtilsStatic.USER_NICKNAME + 'WT PS'
    );
    user.Bypass_All_Processes_Builder__c = true;
    user.Bypass_All_Validation_Rules__c = true;
    user.Bypass_All_Workflow_Rules__c = true;
    insert new List<User>{ user, userBis };

    // Create PermissionSet with Custom Permission and assign to test user
    PermissionSet ps = new PermissionSet();
    ps.Name = 'Test';
    ps.Label = 'Test';
    insert ps;
    SetupEntityAccess sea = new SetupEntityAccess();
    sea.ParentId = ps.Id;
    sea.SetupEntityId = [
      SELECT Id
      FROM CustomPermission
      WHERE DeveloperName = :STA_UtilsStatic.DELETE_OPPORTUNITY_PERMISSION
    ][0]
    .Id;
    insert sea;
    PermissionSetAssignment psa = new PermissionSetAssignment();
    psa.AssigneeId = user.Id;
    psa.PermissionSetId = ps.Id;
    insert psa;

    // Id recordTypeId = [
    //     SELECT Id
    //     FROM RecordType
    //     WHERE
    //       DeveloperName = :STA_UtilsStatic.RECORDTYPE_ACCOUNT_QUALIFIED_PROSPECT_DEVNAME
    //     LIMIT 1
    //   ]
    //   .get(0)
    //   .Id;

    Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
      .get(STA_UtilsStatic.RECORDTYPE_ACCOUNT_QUALIFIED_PROSPECT_DEVNAME)
      .getRecordTypeId();

    System.runAs(user) {
      Account accountMassDelete = SMC_UTIL_TestUtils.createAccount(
        recordTypeId,
        STA_UtilsStatic.TEST + '_MassDelete',
        STA_UtilsStatic.PICKLIST_ACCOUNT_TYPE_MARKETING_PROSPECT,
        STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY2
      );
      insert accountMassDelete;
    }

    System.runAs(userBis) {
      Account accountMassDelete = SMC_UTIL_TestUtils.createAccount(
        recordTypeId,
        STA_UtilsStatic.TEST + '_MassDeleteBis',
        STA_UtilsStatic.PICKLIST_ACCOUNT_TYPE_MARKETING_PROSPECT,
        STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY2
      );
      insert accountMassDelete;
    }
  }

  /**
   * @description : test SMC_AP_ManageContact.showMessageSyncContact()
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  @isTest
  public static void testShowMessageSyncContact() {
    PAD.bypassAll = true;

    // Account account = [SELECT Id FROM Account WHERE Name = :STA_UtilsStatic.TEST];

    Id recordTypeId = [
        SELECT Id
        FROM RecordType
        WHERE
          DeveloperName = :STA_UtilsStatic.RECORDTYPE_ACCOUNT_QUALIFIED_PROSPECT_DEVNAME
        LIMIT 1
      ]
      .get(0)
      .Id;
    Account account = SMC_UTIL_TestUtils.createAccount(
      recordTypeId,
      STA_UtilsStatic.TEST,
      STA_UtilsStatic.PICKLIST_ACCOUNT_TYPE_MARKETING_PROSPECT,
      STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY2
    );
    insert account;

    // Generate contacts
    Contact contact1 = new Contact();
    contact1.FirstName = STA_UtilsStatic.CONTACT_FIRSTNAME1;
    contact1.LastName = STA_UtilsStatic.CONTACT_LASTNAME1;
    contact1.AccountId = account.Id;
    contact1.SMC_Sync_With_Address_Account__c = false;

    Contact contact2 = SMC_UTIL_TestUtils.createContact(
      STA_UtilsStatic.CONTACT_FIRSTNAME2,
      STA_UtilsStatic.CONTACT_LASTNAME2,
      STA_UtilsStatic.CONTACT_PHONE1,
      STA_UtilsStatic.CONTACT_MOBILEPHONE1,
      STA_UtilsStatic.CONTACT_EMAIL1,
      STA_UtilsStatic.CONTACT_MAILINGSTREET1,
      STA_UtilsStatic.CONTACT_MAILINGPOSTALCODE1,
      STA_UtilsStatic.CONTACT_MAILINGCITY1,
      STA_UtilsStatic.CONTACT_MAILINGSTATE1,
      STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY2,
      STA_UtilsStatic.EMPTY_STRING,
      account.Id
    );
    contact2.SMC_Sync_With_Address_Account__c = true;

    List<Contact> contacts = new List<Contact>();
    contacts.add(contact1);
    contacts.add(contact2);
    insert contacts;

    List<Contact> contactGood = new List<Contact>();
    contactGood.add(contact1);
    System.assert(
      SMC_AP_ManageContact.showMessageSyncContact(contactGood),
      'This contact is not synced with its account.'
    );

    List<Contact> contactFalse = new List<Contact>();
    contactFalse.add(contact2);
    System.assert(
      !SMC_AP_ManageContact.showMessageSyncContact(contactFalse),
      'This contact is synced with its account.'
    );

    PAD.bypassAll = false;
  }

  /**
   * @description : test SMC_AP_ManageContact.flagPartnerContact()
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  @isTest
  public static void testFlagPartnerContact() {
    PAD.bypassAll = true;

    // Account account = [SELECT Id FROM Account WHERE Name = :STA_UtilsStatic.TEST];

    Id recordTypeId = [
        SELECT Id
        FROM RecordType
        WHERE
          DeveloperName = :STA_UtilsStatic.RECORDTYPE_ACCOUNT_QUALIFIED_PROSPECT_DEVNAME
        LIMIT 1
      ]
      .get(0)
      .Id;
    Account account = SMC_UTIL_TestUtils.createAccount(
      recordTypeId,
      STA_UtilsStatic.TEST,
      STA_UtilsStatic.PICKLIST_ACCOUNT_TYPE_MARKETING_PROSPECT,
      STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY2
    );
    insert account;

    PAD.bypassAll = false;

    Contact partnerContact = SMC_UTIL_TestUtils.createContact(
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
      STA_UtilsStatic.EMPTY_STRING,
      account.Id
    );
    insert partnerContact;

    Test.startTest();
    Profile profilePartner = [
      SELECT Id
      FROM Profile
      WHERE Name = :STA_UtilsStatic.PROFILE_SMC_PARTNER_COMMUNITY
    ];
    User userPartner = SMC_UTIL_TestUtils.createUser(
      STA_UtilsStatic.CONTACT_LASTNAME1,
      STA_UtilsStatic.CONTACT_EMAIL1,
      profilePartner.Id,
      STA_UtilsStatic.CONTACT_EMAIL1,
      STA_UtilsStatic.USER_NICKNAME + '_Partner'
    );
    userPartner.ContactId = partnerContact.Id;
    userPartner.IsActive = true;

    SMC_AP_ManageContact.flagPartnerContact(
      new Map<Id, Id>{ userPartner.ContactId => userPartner.Id },
      true
    );
    Test.stopTest();

    Contact checkPartnerContact = [
      SELECT Id, SMC_Is_Partner_Contact__c
      FROM Contact
      WHERE Id = :partnerContact.Id
    ];
    System.assert(
      checkPartnerContact.SMC_Is_Partner_Contact__c,
      'The contact is not identify as a partner.'
    );
  }

  /**
   * @description : test SMC_AP_ManageContact.unflagPartnerContact()
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  @isTest
  public static void testUnflagPartnerContact() {
    PAD.bypassAll = true;

    // Account account = [SELECT Id FROM Account WHERE Name = :STA_UtilsStatic.TEST];

    Id recordTypeId = [
        SELECT Id
        FROM RecordType
        WHERE
          DeveloperName = :STA_UtilsStatic.RECORDTYPE_ACCOUNT_QUALIFIED_PROSPECT_DEVNAME
        LIMIT 1
      ]
      .get(0)
      .Id;
    Account account = SMC_UTIL_TestUtils.createAccount(
      recordTypeId,
      STA_UtilsStatic.TEST,
      STA_UtilsStatic.PICKLIST_ACCOUNT_TYPE_MARKETING_PROSPECT,
      STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY2
    );
    insert account;

    PAD.bypassAll = false;

    Contact partnerContact = SMC_UTIL_TestUtils.createContact(
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
      STA_UtilsStatic.EMPTY_STRING,
      account.Id
    );
    partnerContact.SMC_Is_Partner_Contact__c = true;
    insert partnerContact;

    Test.startTest();

    SMC_AP_ManageContact.flagPartnerContact(
      new Map<Id, Id>{
        partnerContact.Id => partnerContact.SMC_TECH_Partner_User__c
      },
      false
    );

    Test.stopTest();

    Contact checkPartnerContact = [
      SELECT Id, SMC_Is_Partner_Contact__c
      FROM Contact
      WHERE Id = :partnerContact.Id
    ];
    System.assert(
      !checkPartnerContact.SMC_Is_Partner_Contact__c,
      'The contact is linked to an active partner.'
    );
  }

  @isTest
  public static void testDeleteContactWithoutPermission(){
    Id profileId = [
      SELECT Id
      FROM Profile
      WHERE Name = :STA_UtilsStatic.PROFILE_SALE_STANDARD
    ]
    .Id;
    User user = SMC_UTIL_TestUtils.createUser(
      'delctc' + STA_UtilsStatic.TEST_DIESE,
      'delctc' + STA_UtilsStatic.EMAIL_TEST,
      profileId,
      'delctc' + STA_UtilsStatic.USERNAME_TEST,
      'delctc' + STA_UtilsStatic.USER_NICKNAME
    );
    insert user;

    System.runAs(user) {
      Id recordTypeAccId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
        .get(STA_UtilsStatic.RECORDTYPE_ACCOUNT_QUALIFIED_PROSPECT_DEVNAME)
        .getRecordTypeId();

      Account account = SMC_UTIL_TestUtils.createAccount(
        recordTypeAccId,
        STA_UtilsStatic.TEST + 'check Opp',
        STA_UtilsStatic.PICKLIST_ACCOUNT_TYPE_MARKETING_PROSPECT,
        STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY2
      );
      insert account;

      Map<String, Schema.RecordTypeInfo> recordTypesContact = new Map<String, Schema.RecordTypeInfo>();
      recordTypesContact = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName();
      Id recordTypeIdCtc = recordTypesContact.get(
          STA_UtilsStatic.RECORDTYPE_CONTACT_CUSTOMER
        )
        .getRecordTypeId();
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
        STA_UtilsStatic.EMPTY_STRING,
        account.Id
      );
      contact1.OwnerId = user.Id;
      insert new List<Contact>{ contact1 };

      Test.startTest();
        try{
          System.assertEquals(1, [SELECT Id FROM Contact WHERE OwnerId = :user.Id].size(), 'Contact missing before deletion');
          delete contact1;
        }
        catch(Exception e){
          System.debug('TEST OK - Need check');
        }
      Test.stopTest();

      System.assertEquals(1, [SELECT Id FROM Contact WHERE OwnerId = :user.Id].size(), 'Contact is deleted - TEST FAIL!');
    }
  }

  @isTest
  public static void testDeleteContactWithPermission(){
    Id profileId = [
      SELECT Id
      FROM Profile
      WHERE Name = :STA_UtilsStatic.PROFILE_SALE_STANDARD
    ]
    .Id;
    User user = SMC_UTIL_TestUtils.createUser(
      'delctc' + STA_UtilsStatic.TEST_DIESE,
      'delctc' + STA_UtilsStatic.EMAIL_TEST,
      profileId,
      'delctc' + STA_UtilsStatic.USERNAME_TEST,
      'delctc' + STA_UtilsStatic.USER_NICKNAME
    );
    insert user;

    PermissionSet ps = [
      SELECT ID
      FROM PermissionSet
      WHERE Name = :STA_UtilsStatic.KEY_USER_PERMISSION
    ];
    insert new PermissionSetAssignment(
      AssigneeId = user.id,
      PermissionSetId = ps.Id
    );

    System.runAs(user) {
      Id recordTypeAccId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
        .get(STA_UtilsStatic.RECORDTYPE_ACCOUNT_QUALIFIED_PROSPECT_DEVNAME)
        .getRecordTypeId();

      Account account = SMC_UTIL_TestUtils.createAccount(
        recordTypeAccId,
        STA_UtilsStatic.TEST + 'check Opp',
        STA_UtilsStatic.PICKLIST_ACCOUNT_TYPE_MARKETING_PROSPECT,
        STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY2
      );
      insert account;

      Map<String, Schema.RecordTypeInfo> recordTypesContact = new Map<String, Schema.RecordTypeInfo>();
      recordTypesContact = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName();
      Id recordTypeIdCtc = recordTypesContact.get(
          STA_UtilsStatic.RECORDTYPE_CONTACT_CUSTOMER
        )
        .getRecordTypeId();
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
        STA_UtilsStatic.EMPTY_STRING,
        account.Id
      );
      contact1.OwnerId = user.Id;
      insert new List<Contact>{ contact1 };

      Test.startTest();
        try{
          System.assertEquals(1, [SELECT Id FROM Contact WHERE OwnerId = :user.Id].size(), 'Contact missing before deletion');
          delete contact1;
        }
        catch(Exception e){
          System.debug('TEST OK - Need check');
        }
      Test.stopTest();

      System.assertEquals(0, [SELECT Id FROM Contact WHERE OwnerId = :user.Id].size(), 'Contact isn\'t deleted - TEST FAIL!');
    }
  }

  @isTest
  public static void testDeleteContactLinkedToPArdot(){
    Id profileId = [
      SELECT Id
      FROM Profile
      WHERE Name = :STA_UtilsStatic.PROFILE_SALE_STANDARD
    ]
    .Id;
    User user = SMC_UTIL_TestUtils.createUser(
      'delctc' + STA_UtilsStatic.TEST_DIESE,
      'delctc' + STA_UtilsStatic.EMAIL_TEST,
      profileId,
      'delctc' + STA_UtilsStatic.USERNAME_TEST,
      'delctc' + STA_UtilsStatic.USER_NICKNAME
    );
    insert user;

    PermissionSet ps = [
      SELECT ID
      FROM PermissionSet
      WHERE Name = :STA_UtilsStatic.KEY_USER_PERMISSION
    ];
    insert new PermissionSetAssignment(
      AssigneeId = user.id,
      PermissionSetId = ps.Id
    );

    System.runAs(user) {
      Id recordTypeAccId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
        .get(STA_UtilsStatic.RECORDTYPE_ACCOUNT_QUALIFIED_PROSPECT_DEVNAME)
        .getRecordTypeId();

      Account account = SMC_UTIL_TestUtils.createAccount(
        recordTypeAccId,
        STA_UtilsStatic.TEST + 'check Opp',
        STA_UtilsStatic.PICKLIST_ACCOUNT_TYPE_MARKETING_PROSPECT,
        STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY2
      );
      insert account;

      Map<String, Schema.RecordTypeInfo> recordTypesContact = new Map<String, Schema.RecordTypeInfo>();
      recordTypesContact = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName();
      Id recordTypeIdCtc = recordTypesContact.get(
          STA_UtilsStatic.RECORDTYPE_CONTACT_CUSTOMER
        )
        .getRecordTypeId();
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
        STA_UtilsStatic.EMPTY_STRING,
        account.Id
      );
      contact1.OwnerId = user.Id;
      contact1.pi__url__c = 'NotEmptyString';
      insert new List<Contact>{ contact1 };

      Test.startTest();
        try{
          System.assertEquals(1, [SELECT Id FROM Contact WHERE OwnerId = :user.Id].size(), 'Contact missing before deletion');
          delete contact1;
        }
        catch(Exception e){
          System.debug('TEST OK - Need check');
        }
      Test.stopTest();

      System.assertEquals(1, [SELECT Id FROM Contact WHERE OwnerId = :user.Id].size(), 'Contact isn\'t deleted - TEST FAIL!');
    }
  }

  @isTest
  public static void testDeleteContactLinkedToActivities(){
    Id profileId = [
      SELECT Id
      FROM Profile
      WHERE Name = :STA_UtilsStatic.PROFILE_SALE_STANDARD
    ]
    .Id;
    User user = SMC_UTIL_TestUtils.createUser(
      'delctc' + STA_UtilsStatic.TEST_DIESE,
      'delctc' + STA_UtilsStatic.EMAIL_TEST,
      profileId,
      'delctc' + STA_UtilsStatic.USERNAME_TEST,
      'delctc' + STA_UtilsStatic.USER_NICKNAME
    );
    insert user;

    PermissionSet ps = [
      SELECT ID
      FROM PermissionSet
      WHERE Name = :STA_UtilsStatic.KEY_USER_PERMISSION
    ];
    insert new PermissionSetAssignment(
      AssigneeId = user.id,
      PermissionSetId = ps.Id
    );

    System.runAs(user) {
      Id recordTypeAccId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
        .get(STA_UtilsStatic.RECORDTYPE_ACCOUNT_QUALIFIED_PROSPECT_DEVNAME)
        .getRecordTypeId();

      Account account = SMC_UTIL_TestUtils.createAccount(
        recordTypeAccId,
        STA_UtilsStatic.TEST + 'check Opp',
        STA_UtilsStatic.PICKLIST_ACCOUNT_TYPE_MARKETING_PROSPECT,
        STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY2
      );
      insert account;

      Map<String, Schema.RecordTypeInfo> recordTypesContact = new Map<String, Schema.RecordTypeInfo>();
      recordTypesContact = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName();
      Id recordTypeIdCtc = recordTypesContact.get(
          STA_UtilsStatic.RECORDTYPE_CONTACT_CUSTOMER
        )
        .getRecordTypeId();
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
        STA_UtilsStatic.EMPTY_STRING,
        account.Id
      );
      contact1.OwnerId = user.Id;
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
        STA_UtilsStatic.EMPTY_STRING,
        account.Id
      );
      contact2.OwnerId = user.Id;
      insert new List<Contact>{ contact1, contact2 };

      Event evt = SMC_UTIL_TestUtils.createEvent(
        user.Id,
        account.Id,
        contact1.Id,
        'Test Del Event',
        'Desc',
        'LYON',
        Datetime.now(),
        Datetime.now().addHours(1)
      );
      evt.Type = 'Visit';
      insert evt;

      Task taskTest = new Task(
        WhatId = account.Id,
        WhoId = contact2.Id,
        Type = 'Call'
      );
      insert new List<Task>{ taskTest };

      Test.startTest();
        try{
          System.assertEquals(2, [SELECT Id FROM Contact WHERE OwnerId = :user.Id].size(), 'Contact missing before deletion');
          delete new List<Contact>{ contact1, contact2 };
        }
        catch(Exception e){
          System.debug('TEST OK - Need check');
        }
      Test.stopTest();

      System.assertEquals(2, [SELECT Id FROM Contact WHERE OwnerId = :user.Id].size(), 'Contact is deleted - TEST FAIL!');
    }
  }

  @isTest
  public static void testDeleteContactLinkedToAOpportunity(){
    Id profileId = [
      SELECT Id
      FROM Profile
      WHERE Name = :STA_UtilsStatic.PROFILE_SMC_STANDARD_SERVICE_SOCOMEC
    ]
    .Id;
    User user = SMC_UTIL_TestUtils.createUser(
      'delctc' + STA_UtilsStatic.TEST_DIESE,
      'delctc' + STA_UtilsStatic.EMAIL_TEST,
      profileId,
      'delctc' + STA_UtilsStatic.USERNAME_TEST,
      'delctc' + STA_UtilsStatic.USER_NICKNAME
    );
    user.Bypass_All_Processes_Builder__c = true;
    insert user;

    PermissionSet ps = [
      SELECT ID
      FROM PermissionSet
      WHERE Name = :STA_UtilsStatic.KEY_USER_PERMISSION
    ];
    insert new PermissionSetAssignment(
      AssigneeId = user.id,
      PermissionSetId = ps.Id
    );

    System.runAs(user) {
      Id recordTypeAccId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
        .get(STA_UtilsStatic.RECORDTYPE_ACCOUNT_QUALIFIED_PROSPECT_DEVNAME)
        .getRecordTypeId();

      Account account = SMC_UTIL_TestUtils.createAccount(
        recordTypeAccId,
        STA_UtilsStatic.TEST + 'check Opp',
        STA_UtilsStatic.PICKLIST_ACCOUNT_TYPE_MARKETING_PROSPECT,
        STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY2
      );
      insert account;

      Map<String, Schema.RecordTypeInfo> recordTypesContact = new Map<String, Schema.RecordTypeInfo>();
      recordTypesContact = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName();
      Id recordTypeIdCtc = recordTypesContact.get(
          STA_UtilsStatic.RECORDTYPE_CONTACT_CUSTOMER
        )
        .getRecordTypeId();
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
        STA_UtilsStatic.EMPTY_STRING,
        account.Id
      );
      contact1.OwnerId = user.Id;
      insert new List<Contact>{ contact1 };

      Id recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName()
        .get(STA_UtilsStatic.RECORDTYPE_OPPORTUNITY_PROJECT)
        .getRecordTypeId();
      Opportunity oneOpportunity = SMC_UTIL_TestUtils.createOpportunity(
        recordTypeId,
        STA_UtilsStatic.NA_VALUE,
        STA_UtilsStatic.OPPORTUNITY_PROJECT_DETECTED
      );
      oneOpportunity.OwnerId = user.Id;
      oneOpportunity.AccountId = account.Id;
      oneOpportunity.SMC_Primary_Contact__c = contact1.Id;
      insert oneOpportunity;

      Test.startTest();
        try{
          System.assertEquals(1, [SELECT Id FROM Contact WHERE OwnerId = :user.Id].size(), 'Contact missing before deletion');
          delete contact1;
        }
        catch(Exception e){
          System.debug('TEST OK - Need check');
        }
      Test.stopTest();

      System.assertEquals(1, [SELECT Id FROM Contact WHERE OwnerId = :user.Id].size(), 'Contact is deleted - TEST FAIL!');
    }
  }

  @isTest
  public static void testDeleteContactLinkedToAOpportunityWithDeleteOpportunityPermission(){
    Id profileId = [
      SELECT Id
      FROM Profile
      WHERE Name = :STA_UtilsStatic.PROFILE_SALE_STANDARD
    ]
    .Id;
    User user = SMC_UTIL_TestUtils.createUser(
      'delctc' + STA_UtilsStatic.TEST_DIESE,
      'delctc' + STA_UtilsStatic.EMAIL_TEST,
      profileId,
      'delctc' + STA_UtilsStatic.USERNAME_TEST,
      'delctc' + STA_UtilsStatic.USER_NICKNAME
    );
    user.Bypass_All_Processes_Builder__c = true;
    insert user;

    List<PermissionSet> ps = [
      SELECT ID
      FROM PermissionSet
      WHERE Name = :STA_UtilsStatic.KEY_USER_PERMISSION OR  Name = 'Test'
    ];
    insert new List<PermissionSetAssignment>{new PermissionSetAssignment(
                                                 AssigneeId = user.id,
                                                 PermissionSetId = ps[0].Id),
                                             new PermissionSetAssignment(
                                                 AssigneeId = user.id,
                                                 PermissionSetId = ps[1].Id)
    };

    System.runAs(user) {
      Id recordTypeAccId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
        .get(STA_UtilsStatic.RECORDTYPE_ACCOUNT_QUALIFIED_PROSPECT_DEVNAME)
        .getRecordTypeId();

      Account account = SMC_UTIL_TestUtils.createAccount(
        recordTypeAccId,
        STA_UtilsStatic.TEST + 'check Opp',
        STA_UtilsStatic.PICKLIST_ACCOUNT_TYPE_MARKETING_PROSPECT,
        STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY2
      );
      insert account;

      Map<String, Schema.RecordTypeInfo> recordTypesContact = new Map<String, Schema.RecordTypeInfo>();
      recordTypesContact = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName();
      Id recordTypeIdCtc = recordTypesContact.get(
          STA_UtilsStatic.RECORDTYPE_CONTACT_CUSTOMER
        )
        .getRecordTypeId();
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
        STA_UtilsStatic.EMPTY_STRING,
        account.Id
      );
      contact1.OwnerId = user.Id;
      insert new List<Contact>{ contact1 };

      Id recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName()
        .get(STA_UtilsStatic.RECORDTYPE_OPPORTUNITY_PROJECT)
        .getRecordTypeId();
      Opportunity oneOpportunity = SMC_UTIL_TestUtils.createOpportunity(
        recordTypeId,
        STA_UtilsStatic.NA_VALUE,
        STA_UtilsStatic.OPPORTUNITY_PROJECT_DETECTED
      );
      oneOpportunity.AccountId = account.Id;
      oneOpportunity.SMC_Primary_Contact__c = contact1.Id;
      insert oneOpportunity;

      Test.startTest();
        try{
          System.assertEquals(1, [SELECT Id FROM Contact WHERE OwnerId = :user.Id].size(), 'Contact missing before deletion');
          delete contact1;
        }
        catch(Exception e){
          System.debug('TEST OK - Need check');
        }
      Test.stopTest();

      System.assertEquals(0, [SELECT Id FROM Contact WHERE OwnerId = :user.Id].size(), 'Contact isn\'t deleted - TEST FAIL!');
    }
  }

  @isTest
  public static void testDeleteContactLinkedToAQuote(){
    Id profileId = [
      SELECT Id
      FROM Profile
      WHERE Name = :STA_UtilsStatic.PROFILE_SALE_STANDARD
    ]
    .Id;
    User user = SMC_UTIL_TestUtils.createUser(
      'delctc' + STA_UtilsStatic.TEST_DIESE,
      'delctc' + STA_UtilsStatic.EMAIL_TEST,
      profileId,
      'delctc' + STA_UtilsStatic.USERNAME_TEST,
      'delctc' + STA_UtilsStatic.USER_NICKNAME
    );
    insert user;

    PermissionSet ps = [
      SELECT ID
      FROM PermissionSet
      WHERE Name = :STA_UtilsStatic.KEY_USER_PERMISSION
    ];
    insert new PermissionSetAssignment(
      AssigneeId = user.id,
      PermissionSetId = ps.Id
    );

    System.runAs(user) {
      Id recordTypeAccId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
        .get(STA_UtilsStatic.RECORDTYPE_ACCOUNT_QUALIFIED_PROSPECT_DEVNAME)
        .getRecordTypeId();

      Account account = SMC_UTIL_TestUtils.createAccount(
        recordTypeAccId,
        STA_UtilsStatic.TEST + 'check Opp',
        STA_UtilsStatic.PICKLIST_ACCOUNT_TYPE_MARKETING_PROSPECT,
        STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY2
      );
      insert account;

      Map<String, Schema.RecordTypeInfo> recordTypesContact = new Map<String, Schema.RecordTypeInfo>();
      recordTypesContact = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName();
      Id recordTypeIdCtc = recordTypesContact.get(
          STA_UtilsStatic.RECORDTYPE_CONTACT_CUSTOMER
        )
        .getRecordTypeId();
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
        STA_UtilsStatic.EMPTY_STRING,
        account.Id
      );
      contact1.OwnerId = user.Id;
      insert new List<Contact>{ contact1 };

      Quote projectQuote = SMC_UTIL_TestUtils.createQuote(
        null,
        STA_UtilsStatic.QUOTE_NAME1,
        account.Id
      );
      projectQuote.ContactId = contact1.Id;
      insert projectQuote;

      Test.startTest();
        try{
          System.assertEquals(1, [SELECT Id FROM Contact WHERE OwnerId = :user.Id].size(), 'Contact missing before deletion');
          delete contact1;
        }
        catch(Exception e){
          System.debug('TEST OK - Need check');
        }
      Test.stopTest();

      System.assertEquals(1, [SELECT Id FROM Contact WHERE OwnerId = :user.Id].size(), 'Contact is deleted - TEST FAIL!');
    }
  }

  /**
   * @description : test SMC_AP_ManageContact.checkContactToMassDelete() [OK]
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  // @isTest
  // public static void testCheckContactToMassDeleteWithPermission() {
  //   Profile profile = [
  //     SELECT Id
  //     FROM Profile
  //     WHERE Name = :STA_UtilsStatic.PROFILE_SALE_STANDARD
  //   ];
  //   User userWithPS = [
  //     SELECT Id, Name
  //     FROM User
  //     WHERE Username = :STA_UtilsStatic.USERNAME_TEST
  //   ];

  //   System.runAs(userWithPS) {
  //     PAD.bypassAll = true;

  //     Account account = [
  //       SELECT Id
  //       FROM Account
  //       WHERE Name = :(STA_UtilsStatic.TEST + '_MassDelete')
  //     ];

  //     Map<String, Schema.RecordTypeInfo> recordTypesContact = new Map<String, Schema.RecordTypeInfo>();
  //     recordTypesContact = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName();
  //     Id recordTypeIdCtc = recordTypesContact.get(
  //         STA_UtilsStatic.RECORDTYPE_CONTACT_CUSTOMER
  //       )
  //       .getRecordTypeId();
  //     Contact contact = SMC_UTIL_TestUtils.createContact(
  //       STA_UtilsStatic.CONTACT_FIRSTNAME1,
  //       STA_UtilsStatic.CONTACT_LASTNAME1,
  //       STA_UtilsStatic.CONTACT_PHONE1,
  //       STA_UtilsStatic.CONTACT_MOBILEPHONE1,
  //       STA_UtilsStatic.CONTACT_EMAIL1,
  //       STA_UtilsStatic.CONTACT_MAILINGSTREET1,
  //       STA_UtilsStatic.CONTACT_MAILINGPOSTALCODE1,
  //       STA_UtilsStatic.CONTACT_MAILINGCITY1,
  //       STA_UtilsStatic.CONTACT_MAILINGSTATE1,
  //       STA_UtilsStatic.CONTACT_MAILINGCOUNTRY1,
  //       STA_UtilsStatic.EMPTY_STRING,
  //       account.Id
  //     );
  //     insert contact;

  //     PAD.bypassAll = false;

  //     try {
  //       delete contact;
  //       System.debug(LoggingLevel.INFO, 'Can delete a Contact - TEST OK!!\n');
  //     } catch (Exception e) {
  //       System.debug(LoggingLevel.INFO, STA_UtilsStatic.TEST_FAIL_SYSDEBUG + e);
  //     }
  //     List<Contact> contactCheck = new List<Contact>();
  //     contactCheck = [SELECT Id FROM Contact];
  //     System.assertEquals(
  //       0,
  //       contactCheck.size(),
  //       'Contacts are not deleted. Check user permissions.'
  //     );
  //   }
  // }

  /**
   * @description : test SMC_AP_ManageContact.checkContactToMassDelete() [BAD]
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  // @isTest
  // public static void testCheckERPContactToMassDeleteWithoutPermission() {
  //   Profile profile = [
  //     SELECT Id
  //     FROM Profile
  //     WHERE Name = :STA_UtilsStatic.PROFILE_SALE_STANDARD
  //   ];
  //   User userWithoutPS = [
  //     SELECT Id, Name
  //     FROM User
  //     WHERE Username = :('wtps_' + STA_UtilsStatic.USERNAME_TEST)
  //   ];

  //   System.runAs(userWithoutPS) {
  //     PAD.bypassAll = true;

  //     Account account = [
  //       SELECT Id
  //       FROM Account
  //       WHERE Name = :(STA_UtilsStatic.TEST + '_MassDeleteBis')
  //     ];

  //     Map<String, Schema.RecordTypeInfo> recordTypesContact = new Map<String, Schema.RecordTypeInfo>();
  //     recordTypesContact = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName();
  //     Id recordTypeIdCtc = recordTypesContact.get(
  //         STA_UtilsStatic.RECORDTYPE_CONTACT_CUSTOMER
  //       )
  //       .getRecordTypeId();
  //     Contact contact = SMC_UTIL_TestUtils.createContact(
  //       STA_UtilsStatic.CONTACT_FIRSTNAME1,
  //       STA_UtilsStatic.CONTACT_LASTNAME1,
  //       STA_UtilsStatic.CONTACT_PHONE1,
  //       STA_UtilsStatic.CONTACT_MOBILEPHONE1,
  //       STA_UtilsStatic.CONTACT_EMAIL1,
  //       STA_UtilsStatic.CONTACT_MAILINGSTREET1,
  //       STA_UtilsStatic.CONTACT_MAILINGPOSTALCODE1,
  //       STA_UtilsStatic.CONTACT_MAILINGCITY1,
  //       STA_UtilsStatic.CONTACT_MAILINGSTATE1,
  //       STA_UtilsStatic.CONTACT_MAILINGCOUNTRY1,
  //       STA_UtilsStatic.EMPTY_STRING,
  //       account.Id
  //     );
  //     insert contact;

  //     PAD.bypassAll = false;

  //     try {
  //       delete contact;
  //       System.debug(LoggingLevel.INFO, STA_UtilsStatic.TEST_FAIL_SYSDEBUG);
  //     } catch (Exception e) {
  //       System.debug(
  //         LoggingLevel.INFO,
  //         'Can\'t delete an Contact - TEST OK!!\n' + e
  //       );
  //     }
  //     List<Contact> contactCheck = new List<Contact>();
  //     contactCheck = [SELECT Id FROM Contact];
  //     System.assertEquals(
  //       1,
  //       contactCheck.size(),
  //       'The contact is deleted. Check user permissions.'
  //     );
  //   }
  // }

  /**
   * @description : test SMC_AP_ManageContact.checkContactToMassDelete() [OK]
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  // @isTest
  // public static void testCheckContactToMassDeleteListContactWithOneLinkOpportunity() {
  //   Profile profile = [
  //     SELECT Id
  //     FROM Profile
  //     WHERE Name = :STA_UtilsStatic.PROFILE_SALE_STANDARD
  //   ];
  //   User userWithPS = [
  //     SELECT Id, Name
  //     FROM User
  //     WHERE Username = :STA_UtilsStatic.USERNAME_TEST
  //   ];

  //   System.runAs(userWithPS) {
  //     PAD.bypassAll = true;

  //     // Id recordTypeIdAccountInternal = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get(STA_UtilsStatic.RECORDTYPE_ACCOUNT_INTERNAL_DEVNAME).getRecordTypeId();
  //     // Account genericAccount = SMC_UTIL_TestUtils.createAccount(recordTypeIdAccountInternal, 'Generic' + STA_UtilsStatic.ACCOUNT_NAME1, STA_UtilsStatic.PICKLIST_ACCOUNT_TYPE_CUSTOMER,
  //     // STA_UtilsStatic.ACCOUNT_BILLINGSTREET1, STA_UtilsStatic.ACCOUNT_BILLINGPOSTALCODE1, STA_UtilsStatic.ACCOUNT_BILLINGCITY1,
  //     // STA_UtilsStatic.ACCOUNT_BILLINGSTATE1, STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY1, null, null, null, null, user.Id);
  //     // genericAccount.isGenericOppAccount__c = true;
  //     // insert genericAccount;

  //     Account account = [
  //       SELECT Id
  //       FROM Account
  //       WHERE Name = :(STA_UtilsStatic.TEST + '_MassDelete')
  //     ];

  //     Map<String, Schema.RecordTypeInfo> recordTypesContact = new Map<String, Schema.RecordTypeInfo>();
  //     recordTypesContact = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName();
  //     Id recordTypeIdCtc = recordTypesContact.get(
  //         STA_UtilsStatic.RECORDTYPE_CONTACT_CUSTOMER
  //       )
  //       .getRecordTypeId();
  //     Contact contact1 = SMC_UTIL_TestUtils.createContact(
  //       STA_UtilsStatic.CONTACT_FIRSTNAME1,
  //       STA_UtilsStatic.CONTACT_LASTNAME1,
  //       STA_UtilsStatic.CONTACT_PHONE1,
  //       STA_UtilsStatic.CONTACT_MOBILEPHONE1,
  //       STA_UtilsStatic.CONTACT_EMAIL1,
  //       STA_UtilsStatic.CONTACT_MAILINGSTREET1,
  //       STA_UtilsStatic.CONTACT_MAILINGPOSTALCODE1,
  //       STA_UtilsStatic.CONTACT_MAILINGCITY1,
  //       STA_UtilsStatic.CONTACT_MAILINGSTATE1,
  //       STA_UtilsStatic.CONTACT_MAILINGCOUNTRY1,
  //       STA_UtilsStatic.EMPTY_STRING,
  //       account.Id
  //     );
  //     Contact contact2 = SMC_UTIL_TestUtils.createContact(
  //       STA_UtilsStatic.CONTACT_FIRSTNAME2,
  //       STA_UtilsStatic.CONTACT_LASTNAME2,
  //       STA_UtilsStatic.CONTACT_PHONE2,
  //       STA_UtilsStatic.CONTACT_MOBILEPHONE2,
  //       STA_UtilsStatic.CONTACT_EMAIL2,
  //       STA_UtilsStatic.CONTACT_MAILINGSTREET2,
  //       STA_UtilsStatic.CONTACT_MAILINGPOSTALCODE2,
  //       STA_UtilsStatic.CONTACT_MAILINGCITY2,
  //       STA_UtilsStatic.CONTACT_MAILINGSTATE2,
  //       STA_UtilsStatic.CONTACT_MAILINGCOUNTRY2,
  //       STA_UtilsStatic.EMPTY_STRING,
  //       account.Id
  //     );
  //     insert new List<Contact>{ contact1, contact2 };

  //     Map<String, Schema.RecordTypeInfo> recordTypesOpportunity = new Map<String, Schema.RecordTypeInfo>();
  //     recordTypesOpportunity = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName();
  //     Id recordTypeId = recordTypesOpportunity.get(
  //         STA_UtilsStatic.RECORDTYPE_OPPORTUNITY_PROJECT
  //       )
  //       .getRecordTypeId();
  //     Opportunity oppTocontact1 = SMC_UTIL_TestUtils.createOpportunity(
  //       recordTypeId,
  //       STA_UtilsStatic.TEST,
  //       'Won'
  //     );
  //     oppTocontact1.SMC_Primary_Contact__c = contact1.Id;
  //     // oppTocontact1.SMC_Project_Contact_Lookup__c = contact1.Id;
  //     insert new List<Opportunity>{ oppTocontact1 };

  //     PAD.bypassAll = false;

  //     try {
  //       delete new List<Contact>{ contact1, contact2 };
  //       System.debug(
  //         LoggingLevel.INFO,
  //         'ERROR Contacts - Test fail if we\'ll see this message'
  //       );
  //     } catch (Exception e) {
  //       System.debug(
  //         LoggingLevel.INFO,
  //         'Contacts - Can\'t delete an Contact - TEST OK!!\n' + e
  //       );
  //     }
  //     List<Contact> contactCheck = new List<Contact>();
  //     contactCheck = [SELECT Id FROM Contact];
  //     System.assertEquals(
  //       0,
  //       contactCheck.size(),
  //       'Contacts are not deleted. Check links beteween contacts and opportunities.'
  //     );
  //   }
  // }

  /**
   * @description : test SMC_AP_ManageContact.checkContactToMassDelete() [OK]
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  // @isTest
  // public static void testCheckContactToMassDeleteLinkOpportunity() {
  //   // Profile profile = [
  //   //   SELECT Id
  //   //   FROM Profile
  //   //   WHERE Name = :STA_UtilsStatic.PROFILE_SALE_STANDARD
  //   // ];
  //   // User userWithPS = [
  //   //   SELECT Id, Name
  //   //   FROM User
  //   //   WHERE Username = :STA_UtilsStatic.USERNAME_TEST
  //   // ];
  //   Id profileId = [
  //     SELECT Id
  //     FROM Profile
  //     WHERE Name = :STA_UtilsStatic.PROFILE_SALE_STANDARD
  //   ]
  //   .Id;
  //   User user = SMC_UTIL_TestUtils.createUser(
  //     'delctc' + STA_UtilsStatic.TEST_DIESE,
  //     'delctc' + STA_UtilsStatic.EMAIL_TEST,
  //     profileId,
  //     'delctc' + STA_UtilsStatic.USERNAME_TEST,
  //     'delctc' + STA_UtilsStatic.USER_NICKNAME
  //   );
  //   insert user;

  //   PermissionSet ps = [
  //     SELECT ID
  //     FROM PermissionSet
  //     WHERE Name = :STA_UtilsStatic.KEY_USER_PERMISSION
  //   ];
  //   insert new PermissionSetAssignment(
  //     AssigneeId = user.id,
  //     PermissionSetId = ps.Id
  //   );

  //   System.runAs(user) {
  //     // Id recordTypeAccId = [
  //     //     SELECT Id
  //     //     FROM RecordType
  //     //     WHERE
  //     //       DeveloperName = :STA_UtilsStatic.RECORDTYPE_ACCOUNT_QUALIFIED_PROSPECT_DEVNAME
  //     //     LIMIT 1
  //     //   ]
  //     //   .get(0)
  //     //   .Id;

  //     Id recordTypeAccId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
  //       .get(STA_UtilsStatic.RECORDTYPE_ACCOUNT_QUALIFIED_PROSPECT_DEVNAME)
  //       .getRecordTypeId();

  //     Account account = SMC_UTIL_TestUtils.createAccount(
  //       recordTypeAccId,
  //       STA_UtilsStatic.TEST + 'check Opp',
  //       STA_UtilsStatic.PICKLIST_ACCOUNT_TYPE_MARKETING_PROSPECT,
  //       STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY2
  //     );
  //     insert account;

  //     Map<String, Schema.RecordTypeInfo> recordTypesContact = new Map<String, Schema.RecordTypeInfo>();
  //     recordTypesContact = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName();
  //     Id recordTypeIdCtc = recordTypesContact.get(
  //         STA_UtilsStatic.RECORDTYPE_CONTACT_CUSTOMER
  //       )
  //       .getRecordTypeId();
  //     Contact contact1 = SMC_UTIL_TestUtils.createContact(
  //       STA_UtilsStatic.CONTACT_FIRSTNAME1,
  //       STA_UtilsStatic.CONTACT_LASTNAME1,
  //       STA_UtilsStatic.CONTACT_PHONE1,
  //       STA_UtilsStatic.CONTACT_MOBILEPHONE1,
  //       STA_UtilsStatic.CONTACT_EMAIL1,
  //       STA_UtilsStatic.CONTACT_MAILINGSTREET1,
  //       STA_UtilsStatic.CONTACT_MAILINGPOSTALCODE1,
  //       STA_UtilsStatic.CONTACT_MAILINGCITY1,
  //       STA_UtilsStatic.CONTACT_MAILINGSTATE1,
  //       STA_UtilsStatic.CONTACT_MAILINGCOUNTRY1,
  //       STA_UtilsStatic.EMPTY_STRING,
  //       account.Id
  //     );
  //     Contact contact2 = SMC_UTIL_TestUtils.createContact(
  //       STA_UtilsStatic.CONTACT_FIRSTNAME2,
  //       STA_UtilsStatic.CONTACT_LASTNAME2,
  //       STA_UtilsStatic.CONTACT_PHONE2,
  //       STA_UtilsStatic.CONTACT_MOBILEPHONE2,
  //       STA_UtilsStatic.CONTACT_EMAIL2,
  //       STA_UtilsStatic.CONTACT_MAILINGSTREET2,
  //       STA_UtilsStatic.CONTACT_MAILINGPOSTALCODE2,
  //       STA_UtilsStatic.CONTACT_MAILINGCITY2,
  //       STA_UtilsStatic.CONTACT_MAILINGSTATE2,
  //       STA_UtilsStatic.CONTACT_MAILINGCOUNTRY2,
  //       STA_UtilsStatic.EMPTY_STRING,
  //       account.Id
  //     );
  //     Contact contact3 = SMC_UTIL_TestUtils.createContact(
  //       STA_UtilsStatic.CONTACT_FIRSTNAME3,
  //       STA_UtilsStatic.CONTACT_LASTNAME3,
  //       STA_UtilsStatic.CONTACT_PHONE3,
  //       STA_UtilsStatic.CONTACT_MOBILEPHONE3,
  //       STA_UtilsStatic.CONTACT_EMAIL3,
  //       STA_UtilsStatic.CONTACT_MAILINGSTREET3,
  //       STA_UtilsStatic.CONTACT_MAILINGPOSTALCODE3,
  //       STA_UtilsStatic.CONTACT_MAILINGCITY3,
  //       STA_UtilsStatic.CONTACT_MAILINGSTATE3,
  //       STA_UtilsStatic.CONTACT_MAILINGCOUNTRY3,
  //       STA_UtilsStatic.EMPTY_STRING,
  //       account.Id
  //     );
  //     insert new List<Contact>{ contact1, contact2, contact3 };

  //     Map<String, Schema.RecordTypeInfo> recordTypesOpportunity = new Map<String, Schema.RecordTypeInfo>();
  //     recordTypesOpportunity = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName();
  //     Id recordTypeId = recordTypesOpportunity.get(
  //         STA_UtilsStatic.RECORDTYPE_OPPORTUNITY_PROJECT
  //       )
  //       .getRecordTypeId();
  //     Opportunity oppTocontact1 = SMC_UTIL_TestUtils.createOpportunity(
  //       recordTypeId,
  //       STA_UtilsStatic.TEST,
  //       'Won'
  //     );
  //     oppTocontact1.SMC_Primary_Contact__c = contact1.Id;
  //     oppTocontact1.AccountId = account.Id;
  //     Opportunity oppTocontact3 = SMC_UTIL_TestUtils.createOpportunity(
  //       recordTypeId,
  //       STA_UtilsStatic.TEST,
  //       'Won'
  //     );
  //     oppTocontact1.SMC_Primary_Contact__c = contact3.Id;
  //     oppTocontact3.SMC_Project_Contact_Lookup__c = contact3.Id;
  //     oppTocontact3.AccountId = account.Id;
  //     PAD.ApexForcedBypass.add(STA_UtilsStatic.CLASS_OPPORTUNITY_MANAGEMENT);
  //     insert new List<Opportunity>{ oppTocontact1, oppTocontact3 };
  //     PAD.ApexForcedBypass.remove(STA_UtilsStatic.CLASS_OPPORTUNITY_MANAGEMENT);

  //     //contact1
  //     try {
  //       delete contact1;
  //       System.debug(
  //         LoggingLevel.INFO,
  //         'ERROR Contact1 - Test fail if we\'ll see this message'
  //       );
  //     } catch (Exception e) {
  //       System.debug(
  //         LoggingLevel.INFO,
  //         'Contact1 - Can\'t delete an Contact - TEST OK!!\n' + e
  //       );
  //     }
  //     //contact2
  //     try {
  //       delete contact2;
  //       System.debug(
  //         LoggingLevel.INFO,
  //         'ERROR Contact2 - Test fail if we\'ll see this message'
  //       );
  //     } catch (Exception e) {
  //       System.debug(
  //         LoggingLevel.INFO,
  //         'Contact2 - Can\'t delete an Contact - TEST OK!!\n' + e
  //       );
  //     }
  //     //contact3
  //     try {
  //       delete contact3;
  //       System.debug(
  //         LoggingLevel.INFO,
  //         'ERROR Contact3 - Test fail if we\'ll see this message'
  //       );
  //     } catch (Exception e) {
  //       System.debug(
  //         LoggingLevel.INFO,
  //         'Contact3 - Can\'t delete an Contact - TEST OK!!\n' + e
  //       );
  //     }
  //     List<Contact> contactCheck = new List<Contact>();
  //     contactCheck = [SELECT Id FROM Contact];
  //     System.assertEquals(
  //       1,
  //       contactCheck.size(),
  //       'Contacts are deleted. Check links beteween contacts and opportunities.'
  //     );
  //   }
  // }

  // @isTest
  // public static void testCheckActivitiesOnContactFrenchAddon() {
  //   Id profileId = [
  //     SELECT Id
  //     FROM Profile
  //     WHERE Name = :STA_UtilsStatic.PROFILE_SALE_STANDARD
  //   ]
  //   .Id;
  //   User user = SMC_UTIL_TestUtils.createUser(
  //     'delctc' + STA_UtilsStatic.TEST_DIESE,
  //     'delctc' + STA_UtilsStatic.EMAIL_TEST,
  //     profileId,
  //     'delctc' + STA_UtilsStatic.USERNAME_TEST,
  //     'delctc' + STA_UtilsStatic.USER_NICKNAME
  //   );
  //   insert user;

  //   PermissionSet ps = [
  //     SELECT ID
  //     FROM PermissionSet
  //     WHERE Name = 'SMC_French_User_Addon'
  //   ];
  //   insert new PermissionSetAssignment(
  //     AssigneeId = user.id,
  //     PermissionSetId = ps.Id
  //   );

  //   System.runAs(user) {
  //     Id recordTypeAccId = [
  //         SELECT Id
  //         FROM RecordType
  //         WHERE
  //           DeveloperName = :STA_UtilsStatic.RECORDTYPE_ACCOUNT_QUALIFIED_PROSPECT_DEVNAME
  //         LIMIT 1
  //       ]
  //       .get(0)
  //       .Id;

  //     Account account = SMC_UTIL_TestUtils.createAccount(
  //       recordTypeAccId,
  //       STA_UtilsStatic.TEST + 'check Opp',
  //       STA_UtilsStatic.PICKLIST_ACCOUNT_TYPE_MARKETING_PROSPECT,
  //       STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY2
  //     );
  //     insert account;

  //     Map<String, Schema.RecordTypeInfo> recordTypesContact = new Map<String, Schema.RecordTypeInfo>();
  //     recordTypesContact = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName();
  //     Id recordTypeIdCtc = recordTypesContact.get(
  //         STA_UtilsStatic.RECORDTYPE_CONTACT_CUSTOMER
  //       )
  //       .getRecordTypeId();
  //     Contact contact1 = SMC_UTIL_TestUtils.createContact(
  //       STA_UtilsStatic.CONTACT_FIRSTNAME1,
  //       STA_UtilsStatic.CONTACT_LASTNAME1,
  //       STA_UtilsStatic.CONTACT_PHONE1,
  //       STA_UtilsStatic.CONTACT_MOBILEPHONE1,
  //       STA_UtilsStatic.CONTACT_EMAIL1,
  //       STA_UtilsStatic.CONTACT_MAILINGSTREET1,
  //       STA_UtilsStatic.CONTACT_MAILINGPOSTALCODE1,
  //       STA_UtilsStatic.CONTACT_MAILINGCITY1,
  //       STA_UtilsStatic.CONTACT_MAILINGSTATE1,
  //       STA_UtilsStatic.CONTACT_MAILINGCOUNTRY1,
  //       STA_UtilsStatic.EMPTY_STRING,
  //       account.Id
  //     );
  //     Contact contact2 = SMC_UTIL_TestUtils.createContact(
  //       STA_UtilsStatic.CONTACT_FIRSTNAME2,
  //       STA_UtilsStatic.CONTACT_LASTNAME2,
  //       STA_UtilsStatic.CONTACT_PHONE2,
  //       STA_UtilsStatic.CONTACT_MOBILEPHONE2,
  //       STA_UtilsStatic.CONTACT_EMAIL2,
  //       STA_UtilsStatic.CONTACT_MAILINGSTREET2,
  //       STA_UtilsStatic.CONTACT_MAILINGPOSTALCODE2,
  //       STA_UtilsStatic.CONTACT_MAILINGCITY2,
  //       STA_UtilsStatic.CONTACT_MAILINGSTATE2,
  //       STA_UtilsStatic.CONTACT_MAILINGCOUNTRY2,
  //       STA_UtilsStatic.EMPTY_STRING,
  //       account.Id
  //     );
  //     Contact contact3 = SMC_UTIL_TestUtils.createContact(
  //       STA_UtilsStatic.CONTACT_FIRSTNAME3,
  //       STA_UtilsStatic.CONTACT_LASTNAME3,
  //       STA_UtilsStatic.CONTACT_PHONE3,
  //       STA_UtilsStatic.CONTACT_MOBILEPHONE3,
  //       STA_UtilsStatic.CONTACT_EMAIL3,
  //       STA_UtilsStatic.CONTACT_MAILINGSTREET3,
  //       STA_UtilsStatic.CONTACT_MAILINGPOSTALCODE3,
  //       STA_UtilsStatic.CONTACT_MAILINGCITY3,
  //       STA_UtilsStatic.CONTACT_MAILINGSTATE3,
  //       STA_UtilsStatic.CONTACT_MAILINGCOUNTRY3,
  //       STA_UtilsStatic.EMPTY_STRING,
  //       account.Id
  //     );
  //     insert new List<Contact>{ contact1, contact2, contact3 };

  //     Event event1 = SMC_UTIL_TestUtils.createEvent(
  //       user.Id,
  //       account.Id,
  //       contact1.Id,
  //       STA_UtilsStatic.EVENT_SUBJECT1,
  //       null,
  //       null,
  //       STA_UtilsStatic.EVENT_DATESTART1,
  //       STA_UtilsStatic.EVENT_DATEEND1
  //     );
  //     event1.Type = 'Visit';
  //     insert new List<Event>{ event1 };

  //     Task taskTest = new Task(
  //       WhatId = account.Id,
  //       WhoId = contact2.Id,
  //       Type = 'Call'
  //     );
  //     insert new List<Task>{ taskTest };

  //     Test.startTest();
  //     Boolean checkForEvent = false;
  //     Boolean checkForTask = false;
  //     Boolean checkDeletion = false;
  //     //Delete with Event
  //     try {
  //       delete contact1;
  //       checkForEvent = false;
  //     } catch (Exception e) {
  //       checkForEvent = true;
  //     }
  //     //Delete with Task
  //     try {
  //       delete contact2;
  //       checkForTask = false;
  //     } catch (Exception e) {
  //       checkForTask = true;
  //     }
  //     //Delete without any Event or  Task
  //     try {
  //       delete contact3;
  //       checkDeletion = true;
  //     } catch (Exception e) {
  //       checkDeletion = false;
  //     }
  //     Test.stopTest();

  //     System.assert(checkForEvent, 'Contact with event is deleted --> ERROR');
  //     System.assert(checkForTask, 'Contact with task is deleted --> ERROR');
  //     System.assert(checkDeletion, 'Contact is NOT deleted --> ERROR');
  //   }
  // }

  // @isTest
  // public static void testCheckActivitiesOnContactKeyUser() {
  //   Id profileId = [
  //     SELECT Id
  //     FROM Profile
  //     WHERE Name = :STA_UtilsStatic.PROFILE_SALE_STANDARD
  //   ]
  //   .Id;
  //   User user = SMC_UTIL_TestUtils.createUser(
  //     'delctc' + STA_UtilsStatic.TEST_DIESE,
  //     'delctc' + STA_UtilsStatic.EMAIL_TEST,
  //     profileId,
  //     'delctc' + STA_UtilsStatic.USERNAME_TEST,
  //     'delctc' + STA_UtilsStatic.USER_NICKNAME
  //   );
  //   insert user;

  //   PermissionSet ps = [
  //     SELECT ID
  //     FROM PermissionSet
  //     WHERE Name = :STA_UtilsStatic.KEY_USER_PERMISSION
  //   ];
  //   insert new PermissionSetAssignment(
  //     AssigneeId = user.id,
  //     PermissionSetId = ps.Id
  //   );

  //   System.runAs(user) {
  //     Id recordTypeAccId = [
  //         SELECT Id
  //         FROM RecordType
  //         WHERE
  //           DeveloperName = :STA_UtilsStatic.RECORDTYPE_ACCOUNT_QUALIFIED_PROSPECT_DEVNAME
  //         LIMIT 1
  //       ]
  //       .get(0)
  //       .Id;

  //     Account account = SMC_UTIL_TestUtils.createAccount(
  //       recordTypeAccId,
  //       STA_UtilsStatic.TEST + 'check Opp',
  //       STA_UtilsStatic.PICKLIST_ACCOUNT_TYPE_MARKETING_PROSPECT,
  //       STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY2
  //     );
  //     insert account;

  //     Map<String, Schema.RecordTypeInfo> recordTypesContact = new Map<String, Schema.RecordTypeInfo>();
  //     recordTypesContact = Schema.SObjectType.Contact.getRecordTypeInfosByDeveloperName();
  //     Id recordTypeIdCtc = recordTypesContact.get(
  //         STA_UtilsStatic.RECORDTYPE_CONTACT_CUSTOMER
  //       )
  //       .getRecordTypeId();
  //     Contact contact1 = SMC_UTIL_TestUtils.createContact(
  //       STA_UtilsStatic.CONTACT_FIRSTNAME1,
  //       STA_UtilsStatic.CONTACT_LASTNAME1,
  //       STA_UtilsStatic.CONTACT_PHONE1,
  //       STA_UtilsStatic.CONTACT_MOBILEPHONE1,
  //       STA_UtilsStatic.CONTACT_EMAIL1,
  //       STA_UtilsStatic.CONTACT_MAILINGSTREET1,
  //       STA_UtilsStatic.CONTACT_MAILINGPOSTALCODE1,
  //       STA_UtilsStatic.CONTACT_MAILINGCITY1,
  //       STA_UtilsStatic.CONTACT_MAILINGSTATE1,
  //       STA_UtilsStatic.CONTACT_MAILINGCOUNTRY1,
  //       STA_UtilsStatic.EMPTY_STRING,
  //       account.Id
  //     );
  //     insert new List<Contact>{ contact1 /*, contact2, contact3*/ };

  //     Event event1 = SMC_UTIL_TestUtils.createEvent(
  //       user.Id,
  //       account.Id,
  //       contact1.Id,
  //       STA_UtilsStatic.EVENT_SUBJECT1,
  //       null,
  //       null,
  //       STA_UtilsStatic.EVENT_DATESTART1,
  //       STA_UtilsStatic.EVENT_DATEEND1
  //     );
  //     event1.SMC_Event_Type__c = 'VISIT';
  //     insert new List<Event>{ event1 };

  //     Test.startTest();
  //     Boolean checkDeletion = false;
  //     //Delete with Event
  //     try {
  //       delete contact1;
  //     } catch (Exception e) {
  //       checkDeletion = true;
  //     }
  //     Test.stopTest();

  //     // System.assert(checkForEvent, 'Contact with event is deleted --> ERROR');
  //     // System.assert(checkForTask, 'Contact with task is deleted --> ERROR');
  //     System.assert(checkDeletion, 'Contact is deleted --> ERROR');
  //   }
  // }
}