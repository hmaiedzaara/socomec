/*
---------------------------------------------------------------------
-- - Name          : SMC_AP_AccountContactAddressesBatch
-- - Author        : Guillaume BONNET
-- - Description   : A batch so that contacts who have the SMC_Sync_With_Address_Account__c
                     checkbox checked take the address of their related account.
-- Maintenance History:
--
-- Date         Name 			                        Version  Remarks 
-- -----------  ----  			                        -------  ---------------------------
-- xx-MARS-2018  SMC_AP_AccountContactAddressesBatch     1.0      Initial version 
---------------------------------------------------------------------
*/

global without sharing class SMC_AP_AccountContactAddressesBatch extends SMC_AP_BatchesAbstractTemplate {
  public SMC_AP_AccountContactAddressesBatch() {
    super();
    System.debug(
      LoggingLevel.INFO,
      'in SMC_AP_AccountContactAddressesBatch > constructor: after super()'
    );
    query =
      'SELECT Name, MailingCountry, MailingCountryCode, MailingCity, MailingStreet' +
      ', MailingPostalCode, MailingState, MailingStateCode, AccountId  FROM Contact WHERE SMC_Sync_With_Address_Account__c=true';
  }

  public SMC_AP_AccountContactAddressesBatch(String overrideQuery) {
    super(overrideQuery);
    System.debug(
      LoggingLevel.INFO,
      'in SMC_AP_AccountContactAddressesBatch > constructor: after super()'
    );
    query =
      'SELECT Name, MailingCountry, MailingCountryCode, MailingCity, MailingStreet' +
      ', MailingPostalCode, MailingState, MailingStateCode, AccountId  FROM Contact WHERE SMC_Sync_With_Address_Account__c=true';
  }

  // Allow the batch to be executed with a call to this method
  public static void run(String overrideQuery) {
    System.debug(
      LoggingLevel.INFO,
      'in SMC_AP_AccountContactAddressesBatch > run'
    );
    Database.executeBatch(
      new SMC_AP_AccountContactAddressesBatch(overrideQuery),
      200
    );
    // 2nd argument[Integer] Number of records to be passed into the execute method for batch processing.
  }

  // Allow the Batch to be Schedulable
  public override void execute(SchedulableContext sc) {
    Database.executeBatch(new SMC_AP_AccountContactAddressesBatch(null), 200);
  }

  global override void bypassTriggers() {
    System.debug(
      LoggingLevel.INFO,
      'in SMC_AP_AccountContactAddressesBatch > bypassTriggers'
    );
    PAD.bypassAll = true;
  }

  public override void processObjects(List<sObject> objects) {
    System.debug(
      LoggingLevel.INFO,
      'in SMC_AP_AccountContactAddressesBatch > processObjects'
    );

    List<Id> accountsIdFromContact = new List<Id>();
    for (Contact contact : (List<Contact>) objects) {
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

    //code to trigger an exception and a log line:
    //    tobeInsertedList.add(new Account(Name='testBatchTriggerLogLine'));

    for (Contact contact : (List<Contact>) objects) {
      Account parrentAccount = accountsLinked.get(contact.AccountId);

      if (
        accountsLinked.get(contact.AccountId).BillingCountry !=
        contact.MailingCountry ||
        accountsLinked.get(contact.AccountId).BillingCountryCode !=
        contact.MailingCountryCode ||
        accountsLinked.get(contact.AccountId).BillingCity !=
        contact.MailingCity ||
        accountsLinked.get(contact.AccountId).BillingStreet !=
        contact.MailingStreet ||
        accountsLinked.get(contact.AccountId).BillingPostalCode !=
        contact.MailingPostalCode ||
        accountsLinked.get(contact.AccountId).BillingState !=
        contact.MailingState ||
        accountsLinked.get(contact.AccountId).BillingStateCode !=
        contact.MailingStateCode
      ) {
        contact.MailingCountry = parrentAccount.BillingCountry;
        contact.MailingCountryCode = parrentAccount.BillingCountryCode;
        contact.MailingCity = parrentAccount.BillingCity;
        contact.MailingStreet = parrentAccount.BillingStreet;
        contact.MailingPostalCode = parrentAccount.BillingPostalCode;
        contact.MailingState = parrentAccount.BillingState;
        contact.MailingStateCode = parrentAccount.BillingStateCode;

        tobeUpdatedList.add(contact);
      }
    }
  }
}