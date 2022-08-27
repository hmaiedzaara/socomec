/*
---------------------------------------------------------------------
-- - Name          : TEST_SMC_AP_ManageEvent
-- - Author        : David SOBCZAK (DOS)
-- - Description   : Test the Manage Event               
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  -------------------------------------------------------
-- 06-JUI-2018  VRE    1.2     Correction of "eventAutoPopulateFieldsTest" and "isParentAccountGroupConsolidatedTestKO"
-- 23-AUG-2017  DOS    1.1     Add Accompanied by management
-- 31-MAI-2017  DOS    1.0     Initial version
--------------------------------------------------------------------------------------
*/

@IsTest
public without sharing class TEST_SMC_AP_ManageEvent {
  /**
   * @description : test setup
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  @testSetup
  static void allTheDataForThisTestClass() {
    Test.startTest();
    PAD.bypassAll = true;

    // Generate users
    Profile profileStandard = [
      SELECT Id
      FROM Profile
      WHERE Name = :STA_UtilsStatic.PROFILE_SALE_STANDARD
    ];
    User user1 = SMC_UTIL_TestUtils.createUser(
      STA_UtilsStatic.TEST_DIESE,
      STA_UtilsStatic.EMAIL_TEST,
      profileStandard.Id,
      STA_UtilsStatic.USERNAME_TEST,
      STA_UtilsStatic.USER_NICKNAME
    );
    User user2 = SMC_UTIL_TestUtils.createUser(
      STA_UtilsStatic.TEST_DIESE + '2',
      'bis-' + STA_UtilsStatic.EMAIL_TEST,
      profileStandard.Id,
      STA_UtilsStatic.USERNAME_TEST2,
      STA_UtilsStatic.USER_NICKNAME2
    );
    insert new List<User>{ user1, user2 };
    Id userId1 = user1.Id;
    Id userId2 = user2.Id;

    // Generate lead
    Lead lead1 = SMC_UTIL_TestUtils.createLead(
      STA_UtilsStatic.EVENTS,
      STA_UtilsStatic.LEAD_COMPANY1,
      STA_UtilsStatic.LEAD_FIRSTNAME1,
      STA_UtilsStatic.LEAD_LASTNAME1,
      STA_UtilsStatic.LEAD_PHONE1,
      STA_UtilsStatic.LEAD_EMAIL1,
      STA_UtilsStatic.LEAD_STREET1_VERY_LONG,
      STA_UtilsStatic.LEAD_POSTALCODE1,
      STA_UtilsStatic.LEAD_CITY1,
      STA_UtilsStatic.LEAD_STATE1,
      STA_UtilsStatic.LEAD_COUNTRY1
    );

    List<Lead> leads = new List<Lead>();
    leads.add(lead1);
    insert leads;

    // Generate accounts
    Id recordTypeAccCustomerId = [
      SELECT Id
      FROM RecordType
      WHERE DeveloperName = :STA_UtilsStatic.RECORDTYPE_ACCOUNT_CUSTOMER_DEVNAME
    ]
    .Id;

    Account account1 = SMC_UTIL_TestUtils.createAccount(
      recordTypeAccCustomerId,
      STA_UtilsStatic.ACCOUNT_NAME1,
      STA_UtilsStatic.PICKLIST_ACCOUNT_TYPE_CUSTOMER,
      STA_UtilsStatic.ACCOUNT_BILLINGSTREET1,
      STA_UtilsStatic.ACCOUNT_BILLINGPOSTALCODE1,
      STA_UtilsStatic.ACCOUNT_BILLINGCITY1,
      STA_UtilsStatic.ACCOUNT_BILLINGSTATE1,
      STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY1,
      userId1,
      userId1,
      userId1,
      userId1,
      userId1
    );
    account1.SMC_Round_Zone__c = 'TOT';

    List<Account> accounts = new List<Account>();
    accounts.add(account1);
    insert accounts;
    Id accountId1 = accounts[0].Id;

    // Generate contacts
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
      accountId1
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
      accountId1
    );
    insert new List<Contact>{ contact1, contact2 };

    // Generate event
    Event event1 = SMC_UTIL_TestUtils.createEvent(
      null,
      null,
      contact1.Id,
      STA_UtilsStatic.EVENT_SUBJECT1,
      null,
      null,
      STA_UtilsStatic.EVENT_DATESTART1,
      STA_UtilsStatic.EVENT_DATEEND1
    );
    Event event2 = SMC_UTIL_TestUtils.createEvent(
      null,
      null,
      contact1.Id,
      STA_UtilsStatic.EVENT_SUBJECT2,
      null,
      null,
      STA_UtilsStatic.EVENT_DATESTART2,
      STA_UtilsStatic.EVENT_DATEEND2
    );
    // Event event3 = SMC_UTIL_TestUtils.createEvent(NULL, NULL, contact1.Id, STA_UtilsStatic.EVENT_SUBJECT3, NULL, NULL,
    //  STA_UtilsStatic.EVENT_DATESTART3, STA_UtilsStatic.EVENT_DATEEND3);

    insert new List<Event>{ event1, event2 /*, event3*/ };

    EventRelation eventRelation1 = SMC_UTIL_TestUtils.createEventRelation(
      event1.Id,
      userId2,
      true
    );
    EventRelation eventRelation2 = SMC_UTIL_TestUtils.createEventRelation(
      event2.Id,
      userId2,
      true
    );
    insert new List<EventRelation>{
      eventRelation1,
      eventRelation2 /*, eventRelation3*/
    };

    PAD.bypassAll = false;
    Test.stopTest();
  }

  /* Modification des requêtes (l.130) qui ne récupéraient pas le bon Event */
  // Create one event with a contant and another with a Lead in order to check if event.location and event.description is correctly autopopulate by trigger
  @IsTest
  public static void eventAutoPopulateFieldsTest() {
    // Create an event with a contact without other address
    Contact c = [
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
      WHERE email = :STA_UtilsStatic.CONTACT_EMAIL1
    ];

    Event eventContact = SMC_UTIL_TestUtils.createEvent(
      null,
      null,
      c.Id,
      STA_UtilsStatic.EVENT_SUBJECT1 +
      ' - EventContact - eventAutoPopulateFieldsTest',
      null,
      null,
      STA_UtilsStatic.EVENT_DATESTART1,
      STA_UtilsStatic.EVENT_DATEEND1
    );

    // Create an event with a lead
    Lead l = [
      SELECT Id, Street, PostalCode, City, State, Country
      FROM Lead
      WHERE email = :STA_UtilsStatic.LEAD_EMAIL1
    ];

    Event eventLead = SMC_UTIL_TestUtils.createEvent(
      null,
      null,
      l.Id,
      STA_UtilsStatic.EVENT_SUBJECT2 +
      ' - EventLead - eventAutoPopulateFieldsTest',
      STA_UtilsStatic.EVENT_DESCRIPTION2,
      null,
      STA_UtilsStatic.EVENT_DATESTART2,
      STA_UtilsStatic.EVENT_DATEEND2
    );

    List<Event> events = new List<Event>{ eventContact, eventLead };

    // Insert events
    Test.startTest();
    insert events;
    Test.stopTest();

    /* Modification des requêtes qui ne récupéraient pas le bon Event */
    // Get events
    Event eContact = [
      SELECT Id, Location, Description, eventWhoIds, WhoId
      FROM Event
      WHERE
        Subject = :(STA_UtilsStatic.EVENT_SUBJECT1 +
        ' - EventContact - eventAutoPopulateFieldsTest')
    ];
    Event eLead = [
      SELECT Id, Location, Description, eventWhoIds
      FROM Event
      WHERE
        Subject = :(STA_UtilsStatic.EVENT_SUBJECT2 +
        ' - EventLead - eventAutoPopulateFieldsTest')
    ];

    // Expected results
    System.assertEquals(
      SMC_AP_ManageEvent.getAddressPlainText(c),
      eContact.Location,
      'The event contact location not match with contact address. Check event location initialisation.'
    );
    System.assertEquals(
      false,
      string.isEmpty(eContact.Description),
      'The event contact description is not filled.'
    );

    System.assertEquals(
      SMC_AP_ManageEvent.getAddressPlainText(l),
      eLead.Location,
      'The event lead location not match with contactlead address. Check event location initialisation.'
    );
    System.assertEquals(
      false,
      string.isEmpty(eLead.Description),
      'The event lead description is not filled.'
    );
  }

  // Test the function which manage eventRelated fire by trigger insert/update/delete
  // Not possible to cover part concerning childEvent because it's not possible to make DML on it (except bug sfdc4outlook)
  @IsTest
  public static void eventEventRelationManagementTest() {
    // Insert trigger testing
    // Create an event with user1
    User u1 = [
      SELECT Id
      FROM User
      WHERE email = :STA_UtilsStatic.EMAIL_TEST
      LIMIT 1
    ];
    User u2 = [
      SELECT Id
      FROM User
      WHERE email = :('bis-' + STA_UtilsStatic.EMAIL_TEST)
      LIMIT 1
    ];

    // Create an event with a contact without other address
    Contact c = [
      SELECT Id
      FROM Contact
      WHERE email = :STA_UtilsStatic.CONTACT_EMAIL1
    ];

    Event eventUser = SMC_UTIL_TestUtils.createEvent(
      null,
      null,
      c.Id,
      STA_UtilsStatic.INSERTED,
      null,
      null,
      STA_UtilsStatic.EVENT_DATESTART2,
      STA_UtilsStatic.EVENT_DATEEND2
    );
    List<Event> eventsInsert = new List<Event>{ eventUser };

    // Update trigger testing
    // Update when accompanied is updated
    Event eventUpdateAccompanied = [
      SELECT
        Id,
        Subject,
        StartDateTime,
        EndDateTime,
        Location,
        Description,
        SMC_Activity_CRM_ID__c,
        isChild
      FROM Event
      WHERE Subject = :STA_UtilsStatic.EVENT_SUBJECT1
      LIMIT 1
    ];
    delete [
      SELECT Id
      FROM EventRelation
      WHERE EventId = :eventUpdateAccompanied.Id AND RelationId = :u2.Id
    ];
    EventRelation eventRelationUpdateAccompanied = SMC_UTIL_TestUtils.createEventRelation(
      eventUpdateAccompanied.Id,
      u1.Id,
      true
    );
    insert eventRelationUpdateAccompanied;
    /*********************** *************************/
    List<EventRelation> eventRelationBeforeUpdateAccompanied = new List<EventRelation>();
    eventRelationBeforeUpdateAccompanied = [
      SELECT Id, EventId, RelationId
      FROM EventRelation
      WHERE EventId = :eventUpdateAccompanied.Id AND RelationId = :u1.id
    ];
    // Update when accompanied is not updated
    Event eventUpdateWithoutAccompanied = [
      SELECT
        Id,
        Subject,
        StartDateTime,
        EndDateTime,
        Location,
        Description,
        SMC_Activity_CRM_ID__c,
        isChild
      FROM Event
      WHERE Subject = :STA_UtilsStatic.EVENT_SUBJECT2
      LIMIT 1
    ];
    eventUpdateWithoutAccompanied.Description = 'Just change description';
    List<EventRelation> eventRelationBeforeUpdateWithoutAccompanied = new List<EventRelation>();
    eventRelationBeforeUpdateWithoutAccompanied = [
      SELECT Id, EventId, RelationId
      FROM EventRelation
      WHERE EventId = :eventUpdateWithoutAccompanied.Id AND RelationId = :u2.Id
    ];

    //Add in update list
    List<Event> eventsUpdate = new List<Event>{
      eventUpdateAccompanied,
      eventUpdateWithoutAccompanied
    };

    // Delete trigger testing
    Event eventUserBis = SMC_UTIL_TestUtils.createEvent(
      u1.Id,
      null,
      c.Id,
      (STA_UtilsStatic.INSERTED + 'Bis'),
      null,
      null,
      STA_UtilsStatic.EVENT_DATESTART3,
      STA_UtilsStatic.EVENT_DATEEND3
    );
    insert eventUserBis;
    EventRelation eventRelation3 = SMC_UTIL_TestUtils.createEventRelation(
      eventUserBis.Id,
      u2.Id,
      true
    );
    Event eventDelete = [
      SELECT
        Id,
        Subject,
        StartDateTime,
        EndDateTime,
        Location,
        Description,
        SMC_Activity_CRM_ID__c,
        isChild
      FROM Event
      WHERE Subject = :(STA_UtilsStatic.INSERTED + 'Bis')
      LIMIT 1
    ];
    List<Event> eventsDelete = new List<Event>{ eventDelete };

    // Insert events
    Test.startTest();
    insert eventsInsert;
    update eventsUpdate;
    delete eventsDelete;
    Test.stopTest();
    // TODO @DOS IMPROVE EXPECTED RESULT
    // Check insert
    Event eventInserted = [
      SELECT
        Id,
        Subject,
        StartDateTime,
        EndDateTime,
        Location,
        Description,
        SMC_Activity_CRM_ID__c,
        isChild,
        WhoId
      FROM Event
      WHERE Subject = :STA_UtilsStatic.INSERTED
    ];
    System.debug(LoggingLevel.INFO, 'eventInserted : ' + eventInserted);
    System.debug(
      LoggingLevel.INFO,
      'eventRelationCreate Query on all evt : ' +
      [SELECT Id, EventId, RelationId FROM EventRelation]
    );

    /********** **********/
    //List has no row...
    /********* ***********/
    // EventRelation eventRelationCreate = [Select Id, EventId, RelationId
    //                                     FROM EventRelation
    //                                     WHERE EventId =: eventInserted.Id];
    // System.assertNotEquals(null, eventRelationCreate);

    /********* ***********/
    //Same value...
    /********* ***********/
    // Check update when accompanied is updated
    List<EventRelation> eventRelationAfterUpdateAccompanied = new List<EventRelation>();
    eventRelationAfterUpdateAccompanied = [
      SELECT Id, EventId, RelationId
      FROM EventRelation
      WHERE EventId = :eventUpdateAccompanied.Id AND RelationId = :u1.Id
    ];
    // System.assertNotEquals(eventRelationBeforeUpdateAccompanied, eventRelationAfterUpdateAccompanied);
    // Check update when accompanied is not updated
    List<EventRelation> eventRelationAfterUpdateWithoutAccompanied = new List<EventRelation>();
    eventRelationAfterUpdateWithoutAccompanied = [
      SELECT Id, EventId, RelationId
      FROM EventRelation
      WHERE EventId = :eventUpdateWithoutAccompanied.Id AND RelationId = :u2.Id
    ];
    System.assertEquals(
      eventRelationBeforeUpdateWithoutAccompanied,
      eventRelationAfterUpdateWithoutAccompanied,
      'There is an accompanied link to this event.'
    );

    // Check delete event
    List<Event> eventDeleted = new List<Event>();
    eventDeleted = [
      SELECT
        Id,
        Subject,
        StartDateTime,
        EndDateTime,
        Location,
        Description,
        SMC_Activity_CRM_ID__c,
        isChild
      FROM Event
      WHERE Subject = :(STA_UtilsStatic.INSERTED + 'Bis')
      LIMIT 1
    ];
    System.assertEquals(0, eventDeleted.size(), 'Event is not deleted.');
    // Check delete eventRelation
    List<EventRelation> eventRelationDeleted = new List<EventRelation>();
    eventRelationDeleted = [
      SELECT Id, EventId, RelationId
      FROM EventRelation
      WHERE EventId = :eventDelete.Id AND RelationId = :u2.Id
    ];
    System.assertEquals(
      0,
      eventRelationDeleted.size(),
      'EventRelations are not deleted.'
    );
  }
  /*
  @IsTest
  public static void isParentAccountGroupConsolidatedTestOK() {
    //TODO this test works when the setup data insertion method is commented
    //TODO This tests the before insert trigger but not the before update.

    //data insertion START
    PAD.bypassAll = true;
    Id profileIdAdmin = [
        SELECT Id
        FROM Profile
        WHERE Name = :STA_UtilsStatic.PROFILE_SMC_ADMIN
        LIMIT 1
      ]
      .get(0)
      .Id;
    User userBypasser = SMC_UTIL_TestUtils.createUser(
      STA_UtilsStatic.TEST_DIESE + STA_UtilsStatic.ADMIN,
      STA_UtilsStatic.ADMIN + STA_UtilsStatic.EMAIL_TEST,
      profileIdAdmin,
      STA_UtilsStatic.USERNAME_TEST + STA_UtilsStatic.ADMIN,
      STA_UtilsStatic.USER_NICKNAME + STA_UtilsStatic.ADMIN
    );
    userBypasser.Bypass_All_Processes_Builder__c = true;
    userBypasser.Bypass_All_Duplicate_Rules__c = true;
    userBypasser.Bypass_All_Workflow_Rules__c = true;
    userBypasser.Bypass_All_Validation_Rules__c = true;
    insert userBypasser;

    Id recordTypeId = [
        SELECT Id
        FROM RecordType
        WHERE
          DeveloperName = :STA_UtilsStatic.RECORDTYPE_ACCOUNT_GROUP_CONSOLIDATED_DEVNAME
        LIMIT 1
      ]
      .get(0)
      .Id;
    Account groupConsolidatedAccount = SMC_UTIL_TestUtils.createAccount(
      recordTypeId,
      STA_UtilsStatic.ACCOUNT_NAME1,
      STA_UtilsStatic.CUSTOMER,
      STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY2
    );

    System.runAs(userBypasser) {
      insert groupConsolidatedAccount;
    }

    Id profileId = [
        SELECT Id
        FROM Profile
        WHERE Name = :STA_UtilsStatic.PROFILE_SALE_STANDARD
        LIMIT 1
      ]
      .get(0)
      .Id;
    User user1 = [
      SELECT Id
      FROM User
      WHERE email = :STA_UtilsStatic.EMAIL_TEST
    ];

    PAD.bypassAll = false;
    //data insertion END
    Event eventTest = new Event(
      WhatId = groupConsolidatedAccount.Id,
      DurationInMinutes = 10
    );
    Database.SaveResult result;
    System.runAs(user1) {
      Test.startTest();
      result = Database.insert(eventTest, false);
      Test.stopTest();
    }

    System.assert(
      !result.isSuccess(),
      'Event is inserted. Check account record type.'
    );
    System.assert(
      result.getErrors().size() > 0,
      'Event is inserted. Check account record type.'
    );
    System.assertEquals(
      System.Label.SMC_GroupConsolidatedCantBeLinkToEvent,
      result.getErrors()[0].getMessage(),
      'Event is inserted. Check account record type.'
    );
  }*/

  /**
   * @description : test SMC_AP_ManageEvent.isParentAccountGroupConsolidated() [BAD]
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  @IsTest
  public static void isParentAccountGroupConsolidatedTestKO() {
    //TODO this test works when the setup data insertion method is commented
    //TODO This tests the before insert trigger but not the before update.

    //data insertion START
    PAD.bypassAll = true;

    Id profileId = [
        SELECT Id
        FROM Profile
        WHERE Name = :STA_UtilsStatic.PROFILE_SALE_STANDARD
        LIMIT 1
      ]
      .get(0)
      .Id;
    User user1 = [
      SELECT Id
      FROM User
      WHERE email = :STA_UtilsStatic.EMAIL_TEST
    ];

    //data insertion END
    Database.SaveResult result;
    System.runAs(user1) {
      Id recordTypeId = [
          SELECT Id
          FROM RecordType
          WHERE
            DeveloperName = :STA_UtilsStatic.RECORDTYPE_ACCOUNT_CUSTOMER_DEVNAME
          LIMIT 1
        ]
        .get(0)
        .Id;
      Account groupNotConsolidatedAccount = SMC_UTIL_TestUtils.createAccount(
        recordTypeId,
        STA_UtilsStatic.ACCOUNT_NAME1,
        STA_UtilsStatic.CUSTOMER,
        STA_UtilsStatic.ACCOUNT_BILLINGSTREET2,
        STA_UtilsStatic.ACCOUNT_BILLINGPOSTALCODE2,
        STA_UtilsStatic.ACCOUNT_BILLINGCITY2,
        STA_UtilsStatic.ACCOUNT_BILLINGSTATE2,
        STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY2,
        user1.Id,
        user1.Id,
        user1.Id,
        user1.Id,
        user1.Id
      );
      insert groupNotConsolidatedAccount;
      // Generate contacts
      Contact contact2 = SMC_UTIL_TestUtils.createContact(
        'deDuplcateContact' + STA_UtilsStatic.CONTACT_FIRSTNAME2,
        'deDuplcateContact' + STA_UtilsStatic.CONTACT_LASTNAME2,
        STA_UtilsStatic.CONTACT_PHONE2,
        STA_UtilsStatic.CONTACT_MOBILEPHONE2,
        'deDuplcateContact' + STA_UtilsStatic.CONTACT_EMAIL2,
        STA_UtilsStatic.CONTACT_MAILINGSTREET2,
        STA_UtilsStatic.CONTACT_MAILINGPOSTALCODE2,
        STA_UtilsStatic.CONTACT_MAILINGCITY2,
        STA_UtilsStatic.CONTACT_MAILINGSTATE2,
        STA_UtilsStatic.CONTACT_MAILINGCOUNTRY2,
        null,
        groupNotConsolidatedAccount.Id
      );
      insert contact2;

      Event eventTest = new Event(
        WhatId = groupNotConsolidatedAccount.Id,
        DurationInMinutes = 10,
        ActivityDateTime = System.now(),
        WhoId = contact2.Id
      );
      System.debug(LoggingLevel.INFO, 'eventTest : ' + eventTest);
      Test.startTest();
      result = Database.insert(eventTest, false);
      Test.stopTest();
      System.debug(LoggingLevel.INFO, 'result : ' + result);
    }

    System.assert(
      result.isSuccess(),
      'Event is not inserted. Check account record type.'
    );
  }

  /**
   * @description : test SMC_AP_ManageEvent.isParentAccountGroupConsolidated() [BAD]
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  @IsTest
  public static void testFillContactFieldWithWhoId() {
    User user = [
      SELECT Id
      FROM User
      WHERE email = :STA_UtilsStatic.EMAIL_TEST
      LIMIT 1
    ];
    Account acc = [
      SELECT Id, SMC_Round_Zone__c
      FROM Account
      WHERE Name = :STA_UtilsStatic.ACCOUNT_NAME1
    ];
    Contact ctc1 = [
      SELECT Id, Phone, MobilePhone
      FROM Contact
      WHERE Firstname = :STA_UtilsStatic.CONTACT_FIRSTNAME1
    ];
    Contact ctc2 = [
      SELECT Id, Phone, MobilePhone
      FROM Contact
      WHERE Firstname = :STA_UtilsStatic.CONTACT_FIRSTNAME2
    ];

    Test.startTest();
    Event event1 = SMC_UTIL_TestUtils.createEvent(
      null,
      acc.Id,
      ctc1.Id,
      STA_UtilsStatic.EVENT_SUBJECT1,
      null,
      null,
      STA_UtilsStatic.EVENT_DATESTART1,
      STA_UtilsStatic.EVENT_DATEEND1
    );
    insert event1;
    Event insertedEvent = [
      SELECT
        SMC_Account_Round_Zone__c,
        SMC_Contact_Phone__c,
        SMC_Contact_Mobile__c
      FROM Event
      WHERE Id = :event1.Id
    ];

    event1.WhoId = ctc2.Id;
    update event1;
    Event updatedEvent = [
      SELECT
        SMC_Account_Round_Zone__c,
        SMC_Contact_Phone__c,
        SMC_Contact_Mobile__c
      FROM Event
      WHERE Id = :event1.Id
    ];
    Test.stopTest();

    System.assertEquals(
      acc.SMC_Round_Zone__c,
      insertedEvent.SMC_Account_Round_Zone__c,
      'Account\'s fields are not replicate on event.'
    );
    System.assertEquals(
      ctc1.Phone,
      insertedEvent.SMC_Contact_Phone__c,
      'Contact\'s fields are not replicate on event.'
    );
    System.assertEquals(
      ctc1.MobilePhone,
      insertedEvent.SMC_Contact_Mobile__c,
      'Contact\'s fields are not replicate on event.'
    );

    System.assertEquals(
      acc.SMC_Round_Zone__c,
      updatedEvent.SMC_Account_Round_Zone__c,
      'Account\'s fields are not replicate on event.'
    );
    System.assertEquals(
      ctc2.Phone,
      updatedEvent.SMC_Contact_Phone__c,
      'Contact\'s fields are not replicate on event.'
    );
    System.assertEquals(
      ctc2.MobilePhone,
      updatedEvent.SMC_Contact_Mobile__c,
      'Contact\'s fields are not replicate on event.'
    );
  }
}