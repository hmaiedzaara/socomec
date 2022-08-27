/*
---------------------------------------------------------------------
-- - Name          : TEST_SMC_AP_ManageSMCAccountActors
-- - Author        : David SOBCZAK (DOS)
-- - Description   : Test the Manage SMC Account Actors               
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  -------------------------------------------------------
-- 25-Aug-2017  DOS    1.0     Initial version
--------------------------------------------------------------------------------------
*/

@IsTest
public without sharing class TEST_SMC_AP_ManageSMCAccountActors {
  @testSetup
  static void allTheDataForThisTestClass() {
    // Generate 3 accounts
    Id recordTypeAccCustomerId = [
        SELECT Id
        FROM RecordType
        WHERE name = :STA_UtilsStatic.RECORDTYPE_ACCOUNT_CUSTOMER
        LIMIT 1
      ]
      .get(0)
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
      null,
      null,
      null,
      null,
      null
    );
    Account account2 = SMC_UTIL_TestUtils.createAccount(
      recordTypeAccCustomerId,
      STA_UtilsStatic.ACCOUNT_NAME2,
      STA_UtilsStatic.PICKLIST_ACCOUNT_TYPE_MARKETING_PROSPECT,
      STA_UtilsStatic.ACCOUNT_BILLINGSTREET2,
      STA_UtilsStatic.ACCOUNT_BILLINGPOSTALCODE2,
      STA_UtilsStatic.ACCOUNT_BILLINGCITY2,
      STA_UtilsStatic.ACCOUNT_BILLINGSTATE2,
      STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY2,
      null,
      null,
      null,
      null,
      null
    );
    Account account3 = SMC_UTIL_TestUtils.createAccount(
      recordTypeAccCustomerId,
      STA_UtilsStatic.ACCOUNT_NAME3,
      STA_UtilsStatic.PICKLIST_ACCOUNT_TYPE_MARKETING_PROSPECT,
      STA_UtilsStatic.ACCOUNT_BILLINGSTREET3,
      STA_UtilsStatic.ACCOUNT_BILLINGPOSTALCODE3,
      STA_UtilsStatic.ACCOUNT_BILLINGCITY3,
      STA_UtilsStatic.ACCOUNT_BILLINGSTATE3,
      STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY3,
      null,
      null,
      null,
      null,
      null
    );

    List<Account> accounts = new List<Account>();
    accounts.add(account1);
    accounts.add(account2);
    accounts.add(account3);
    PAD.bypassAll = true;
    insert accounts;
    PAD.bypassAll = false;
    Id accountId1 = accounts[0].Id;
    Id accountId2 = accounts[1].Id;
    Id accountId3 = accounts[2].Id;

    // Generate 1 AccountActors
    SMC_Account_Actors__c accountActors1 = SMC_UTIL_TestUtils.createAccountActors(
      accountId1,
      accountId2
    );
    accountActors1.SMC_Role__c = STA_UtilsStatic.STR_PARTNER;

    List<SMC_Account_Actors__c> accountActors = new List<SMC_Account_Actors__c>();
    accountActors.add(accountActors1);
    insert accountActors;
  }

  // Check if the new accountActor created has also automatically created the bidirection actor
  @IsTest
  public static void accountActorsInsertTest() {
    Id accountId1 = [
        SELECT Id
        FROM Account
        WHERE name = :STA_UtilsStatic.ACCOUNT_NAME1
        LIMIT 1
      ]
      .get(0)
      .Id;
    Id accountId2 = [
        SELECT Id
        FROM Account
        WHERE name = :STA_UtilsStatic.ACCOUNT_NAME2
        LIMIT 1
      ]
      .get(0)
      .Id;
    Id accountId3 = [
        SELECT Id
        FROM Account
        WHERE name = :STA_UtilsStatic.ACCOUNT_NAME3
        LIMIT 1
      ]
      .get(0)
      .Id;

    // Insert trigger testing
    SMC_Account_Actors__c accountActorCreate = SMC_UTIL_TestUtils.createAccountActors(
      accountId1,
      accountId3
    );
    List<SMC_Account_Actors__c> accountActorsInsert = new List<SMC_Account_Actors__c>{
      accountActorCreate
    };

    // Insert events
    Test.startTest();
    insert accountActorsInsert;
    Test.stopTest();

    // Check if the new accountActor created has also automatically created the bidirection actor
    SMC_Account_Actors__c accountActorCreatedBidirectional = [
      SELECT Id, SMC_Account_Actors__c, SMC_Linked_Account__c
      FROM SMC_Account_Actors__c
      WHERE
        SMC_Account_Actors__c = :accountId3
        AND SMC_Linked_Account__c = :accountId1
      LIMIT 1
    ];
    System.assertNotEquals(
      null,
      accountActorCreatedBidirectional,
      'Account actors are not inserted.'
    );
  }

  // Check if the accountActor deleted has also automatically created the bidirection actor
  @IsTest
  public static void accountActorsDeleteTest() {
    Id accountId1 = [
        SELECT Id
        FROM Account
        WHERE name = :STA_UtilsStatic.ACCOUNT_NAME1
        LIMIT 1
      ]
      .get(0)
      .Id;
    Id accountId2 = [
        SELECT Id
        FROM Account
        WHERE name = :STA_UtilsStatic.ACCOUNT_NAME2
        LIMIT 1
      ]
      .get(0)
      .Id;
    Id accountId3 = [
        SELECT Id
        FROM Account
        WHERE name = :STA_UtilsStatic.ACCOUNT_NAME3
        LIMIT 1
      ]
      .get(0)
      .Id;

    List<SMC_Account_Actors__c> accountActorDeletetest = [
      SELECT Id, SMC_Account_Actors__c, SMC_Linked_Account__c
      FROM SMC_Account_Actors__c
    ];
    // Delete trigger testing
    SMC_Account_Actors__c accountActorDelete = [
      SELECT Id, SMC_Account_Actors__c, SMC_Linked_Account__c
      FROM SMC_Account_Actors__c
      WHERE
        SMC_Account_Actors__c = :accountId1
        AND SMC_Linked_Account__c = :accountId2
      LIMIT 1
    ];
    List<SMC_Account_Actors__c> accountActorsDelete = new List<SMC_Account_Actors__c>{
      accountActorDelete
    };

    // Insert events
    Test.startTest();
    delete accountActorsDelete;
    Test.stopTest();

    // Check if the accountActor deleted has also automatically created the bidirection actor
    List<SMC_Account_Actors__c> accountActorDeletedBidirectional = [
      SELECT Id, SMC_Account_Actors__c, SMC_Linked_Account__c
      FROM SMC_Account_Actors__c
      WHERE
        SMC_Account_Actors__c = :accountId1
        AND SMC_Linked_Account__c = :accountId2
      LIMIT 1
    ];

    System.assertEquals(
      0,
      accountActorDeletedBidirectional.size(),
      'Account actors are not deleted.'
    );
  }

  // Check if the accountActor updated has also automatically created the bidirection actor
  @IsTest
  public static void accountActorsRoleTest() {
    Id accountId1 = [
        SELECT Id
        FROM Account
        WHERE name = :STA_UtilsStatic.ACCOUNT_NAME1
        LIMIT 1
      ]
      .get(0)
      .Id;
    Id accountId2 = [
        SELECT Id
        FROM Account
        WHERE name = :STA_UtilsStatic.ACCOUNT_NAME2
        LIMIT 1
      ]
      .get(0)
      .Id;
    SMC_Account_Actors__c accountActors1 = [
      SELECT Id, SMC_Account_Actors__c, SMC_Linked_Account__c, SMC_Role__c
      FROM SMC_Account_Actors__c
      WHERE SMC_Account_Actors__c = :accountId1
    ];
    SMC_Account_Actors__c accountActors1Opposite = [
      SELECT Id, SMC_Account_Actors__c, SMC_Linked_Account__c, SMC_Role__c
      FROM SMC_Account_Actors__c
      WHERE SMC_Linked_Account__c = :accountId1
    ];
    System.assertEquals(
      STA_UtilsStatic.STR_PARTNER,
      accountActors1.SMC_Role__c,
      'The matching table is no longer valide. Check "STA_UtilsStatic.STR_PARTNER" and the metadata "SMC_AccountActors_Role__mdt".'
    );
    System.assertEquals(
      STA_UtilsStatic.STR_PARTNER,
      accountActors1Opposite.SMC_Role__c,
      'The matching table is no longer valide. Check "STA_UtilsStatic.STR_PARTNER" and the metadata "SMC_AccountActors_Role__mdt".'
    );

    Test.startTest();
    accountActors1.SMC_Role__c = STA_UtilsStatic.STR_SUPPLIER;
    update accountActors1;
    Test.stopTest();

    SMC_Account_Actors__c checkAccountActors1 = [
      SELECT Id, SMC_Account_Actors__c, SMC_Linked_Account__c, SMC_Role__c
      FROM SMC_Account_Actors__c
      WHERE SMC_Account_Actors__c = :accountId1
    ];
    SMC_Account_Actors__c checkAccountActors1Opposite = [
      SELECT Id, SMC_Account_Actors__c, SMC_Linked_Account__c, SMC_Role__c
      FROM SMC_Account_Actors__c
      WHERE SMC_Linked_Account__c = :accountId1
    ];
    System.assertEquals(
      STA_UtilsStatic.STR_SUPPLIER,
      checkAccountActors1.SMC_Role__c,
      'The matching table is no longer valide. Check "STA_UtilsStatic.STR_SUPPLIER" and the metadata "SMC_AccountActors_Role__mdt".'
    );
    System.assertEquals(
      STA_UtilsStatic.STR_CUSTOMER,
      checkAccountActors1Opposite.SMC_Role__c,
      'The matching table is no longer valide. Check "STA_UtilsStatic.STR_CUSTOMER" and the metadata "SMC_AccountActors_Role__mdt".'
    );
  }
}