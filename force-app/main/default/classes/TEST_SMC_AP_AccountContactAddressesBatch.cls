/*
---------------------------------------------------------------------
-- - Name          : TEST_SMC_AP_AccountContactAddressesBatch
-- - Author        : Guillaume BONNET
-- - Description   : A batch so that contacts who have the SMC_Sync_With_Address_Account__c
                     checkbox checked take the address of their related account.
-- Maintenance History:
--
-- Date         Name 			                        Version  Remarks 
-- -----------  ----  			                        -------  ---------------------------
-- xx-MARS-2018  TEST_SMC_AP_AccountContactAddressesBatch     1.0      Initial version 
---------------------------------------------------------------------
*/
@isTest
global class TEST_SMC_AP_AccountContactAddressesBatch {
  /**
   * @description : SMC_AP_AccountContactAddressesBatch.run()
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  @isTest
  public static void testSyncAddressOnce() {
    PAD.bypassAll = true;
    Id profileId = [
        SELECT Id
        FROM Profile
        WHERE Name = :STA_UtilsStatic.PROFILE_SALE_STANDARD
        LIMIT 1
      ]
      .get(0)
      .Id;
    User userBypasser = SMC_UTIL_TestUtils.createUser(
      STA_UtilsStatic.TEST_DIESE,
      STA_UtilsStatic.EMAIL_TEST,
      profileId,
      STA_UtilsStatic.USERNAME_TEST,
      STA_UtilsStatic.USER_NICKNAME
    );
    userBypasser.Bypass_All_Processes_Builder__c = true;
    userBypasser.Bypass_All_Duplicate_Rules__c = true;
    userBypasser.Bypass_All_Workflow_Rules__c = true;
    userBypasser.Bypass_All_Validation_Rules__c = true;

    Integer nbContactLoop = 199;

    System.runAs(userBypasser) {
      Account accWithBillingAddress = new Account(
        Name = STA_UtilsStatic.ACCOUNT_NAME1,
        BillingCountry = STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY1,
        BillingCountryCode = STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY1,
        BillingCity = STA_UtilsStatic.ACCOUNT_BILLINGCITY1,
        BillingStreet = STA_UtilsStatic.ACCOUNT_BILLINGSTREET1,
        BillingPostalCode = STA_UtilsStatic.ACCOUNT_BILLINGPOSTALCODE1,
        BillingState = STA_UtilsStatic.ACCOUNT_BILLINGSTATE1,
        BillingStateCode = STA_UtilsStatic.ACCOUNT_BILLINGSTATECODE1
      );

      insert accWithBillingAddress;

      List<Contact> contacts = new List<Contact>();

      for (Integer i = 0; i < nbContactLoop; i++) {
        contacts.add(
          new Contact(
            FirstName = STA_UtilsStatic.CONTACT_FIRSTNAME1 + i,
            LastName = STA_UtilsStatic.CONTACT_LASTNAME1,
            AccountId = accWithBillingAddress.Id,
            SMC_Sync_With_Address_Account__c = true
          )
        );
      }
      try {
        insert contacts;
      } catch (Exception e) {
        System.debug(
          LoggingLevel.INFO,
          'in TEST_SMC_AP_AccountContactAddressesBatch > testSyncAddressOnce() > catch: insert contacts failed'
        );
        System.debug(LoggingLevel.INFO, e.getMessage());
      }

      insert new Contact(
        FirstName = STA_UtilsStatic.CONTACT_FIRSTNAME2,
        LastName = STA_UtilsStatic.CONTACT_LASTNAME2,
        AccountId = accWithBillingAddress.Id,
        SMC_Sync_With_Address_Account__c = false,
        MailingCountry = accWithBillingAddress.BillingCountry,
        MailingCountryCode = accWithBillingAddress.BillingCountryCode,
        MailingCity = STA_UtilsStatic.CONTACT_MAILINGCITY2,
        MailingStreet = accWithBillingAddress.BillingStreet,
        MailingPostalCode = accWithBillingAddress.BillingPostalCode,
        MailingState = accWithBillingAddress.BillingState,
        MailingStateCode = accWithBillingAddress.BillingStateCode
      );

      insert new Contact(
        FirstName = STA_UtilsStatic.CONTACT_FIRSTNAME3,
        LastName = STA_UtilsStatic.CONTACT_LASTNAME3,
        AccountId = accWithBillingAddress.Id,
        SMC_Sync_With_Address_Account__c = true,
        MailingCountry = accWithBillingAddress.BillingCountry,
        MailingCountryCode = accWithBillingAddress.BillingCountryCode,
        MailingCity = STA_UtilsStatic.CONTACT_MAILINGCITY3,
        MailingStreet = accWithBillingAddress.BillingStreet,
        MailingPostalCode = accWithBillingAddress.BillingPostalCode,
        MailingState = accWithBillingAddress.BillingState,
        MailingStateCode = accWithBillingAddress.BillingStateCode
      );

      accWithBillingAddress.BillingCountry = STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY1;
      accWithBillingAddress.BillingCountryCode = STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY1;
      update (accWithBillingAddress);

      Test.startTest();
      new SMC_AP_AccountContactAddressesBatch();
      SMC_AP_AccountContactAddressesBatch.run(null);
      Test.stopTest();
    }

    List<Contact> contactsToSync = [
      SELECT
        Name,
        MailingCountry,
        MailingCountryCode,
        MailingCity,
        MailingStreet,
        MailingPostalCode,
        MailingState,
        MailingStateCode,
        AccountId
      FROM Contact
      WHERE SMC_Sync_With_Address_Account__c = true
    ];
    List<Id> accountsIdFromContact = new List<Id>();
    for (Contact contact : contactsToSync) {
      accountsIdFromContact.add(contact.AccountId);
    }
    Map<Id, Account> accountsLinked = new Map<Id, Account>(
      [
        SELECT
          BillingCountry,
          BillingCountryCode,
          BillingCity,
          BillingStreet,
          BillingPostalCode,
          BillingState,
          BillingStateCode
        FROM Account
        WHERE id IN :accountsIdFromContact
      ]
    );

    for (Contact contact : contactsToSync) {
      System.assertEquals(
        accountsLinked.get(contact.AccountId).BillingCountry,
        contact.MailingCountry,
        'Contact.MailingCountry not match with Account.BillingCountry'
      );
      System.assertEquals(
        accountsLinked.get(contact.AccountId).BillingCountryCode,
        contact.MailingCountryCode,
        'Contact.MailingCountryCode not match with Account.BillingCountryCode'
      );
      System.assertEquals(
        accountsLinked.get(contact.AccountId).BillingCity,
        contact.MailingCity,
        'Contact.MailingCity not match with Account.BillingCity.'
      );
      System.assertEquals(
        accountsLinked.get(contact.AccountId).BillingStreet,
        contact.MailingStreet,
        'Contact.MailingStreet not match with Account.BillingStreet.'
      );
      System.assertEquals(
        accountsLinked.get(contact.AccountId).BillingPostalCode,
        contact.MailingPostalCode,
        'Contact.MailingPostalCode not match with Account.BillingPostalCode.'
      );
      System.assertEquals(
        accountsLinked.get(contact.AccountId).BillingState,
        contact.MailingState,
        'Contact.MailingState not match with Account.BillingState.'
      );
      System.assertEquals(
        accountsLinked.get(contact.AccountId).BillingStateCode,
        contact.MailingStateCode,
        'Contact.MailingStateCode not match with Account.BillingStateCode.'
      );
    }

    System.AssertEquals(
      STA_UtilsStatic.CONTACT_MAILINGCITY2,
      [
        SELECT MailingCity
        FROM Contact
        WHERE FirstName = :STA_UtilsStatic.CONTACT_FIRSTNAME2
      ]
      .MailingCity,
      'Contact.MailingCity not match with test value "STA_UtilsStatic.CONTACT_MAILINGCITY2".'
    );

    SMC_Log__c log = [
      SELECT
        Id,
        CreatedDate,
        Name,
        SMC_Process_Name__c,
        SMC_Process_Type__c,
        SMC_Start_Date__c,
        SMC_User__c,
        SMC_Queried_Records_Number__c,
        SMC_DML_Process_Number__c,
        SMC_Success_Number__c,
        SMC_Error_Number__c,
        SMC_End_Date__c,
        SMC_Parameters__c
      FROM SMC_Log__c
      ORDER BY CreatedDate DESC
      LIMIT 1
    ];

    System.debug(LoggingLevel.INFO, 'log' + log);
    System.assertEquals(
      STA_UtilsStatic.PICKLIST_LOGS_PROCESS_TYPE_AB,
      log.SMC_Process_Type__c,
      'Log.Processtype not match with test value "STA_UtilsStatic.PICKLIST_LOGS_PROCESS_TYPE_AB".'
    );
    System.assertEquals(
      STA_UtilsStatic.CLASS_ACCOUNT_CONTACT_ADDRESSES_BATCH,
      log.SMC_Process_Name__c,
      'Log.ProcessName not match with test value "STA_UtilsStatic.CLASS_ACCOUNT_CONTACT_ADDRESSES_BATCH".'
    );
    System.assertNotEquals(
      null,
      log.SMC_End_Date__c,
      'Log do not save an end date.'
    );
    System.assertEquals(
      nbContactLoop + 1,
      log.SMC_Queried_Records_Number__c,
      'Log do not query the rigth number of contact.'
    );
    System.assertEquals(
      nbContactLoop + 1,
      log.SMC_DML_Process_Number__c,
      'Log do not process the rigth number of contact.'
    );
    System.assertEquals(
      nbContactLoop + 1,
      log.SMC_Success_Number__c,
      'Log do not save the rigth number of contact.'
    );
    System.assertEquals(0, log.SMC_Error_Number__c, 'Log save some errors.');
  }
}