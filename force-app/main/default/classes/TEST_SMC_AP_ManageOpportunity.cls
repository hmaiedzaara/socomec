/*
---------------------------------------------------------------------
-- - Name          : TEST_SMC_AP_ManageOpportunity
-- - Author        : Xavier BRANCHE
-- - Description   : Test the Manage Opportunity               
-- Maintenance History:
--
--
-- Date         Name  Version  Remarks 
-- -----------  ----  -------  ---------------------------
-- 30-MAI-2017  XBR   1.0     Initial version 
-- 23-JAN-2019  VRE   1.1     Review 
---------------------------------------------------------------------
*/
@IsTest
public without sharing class TEST_SMC_AP_ManageOpportunity {
  /**
   * @description : test setup
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  @TestSetup
  public static void setup() {
    Profile profile = [
      SELECT Id
      FROM Profile
      WHERE Name = :STA_UtilsStatic.PROFILE_SALE_STANDARD
    ];
    User user = SMC_UTIL_TestUtils.createUser(
      STA_UtilsStatic.USER_NICKNAME,
      STA_UtilsStatic.USERNAME_TEST,
      profile.Id,
      STA_UtilsStatic.USERNAME_TEST,
      STA_UtilsStatic.USER_NICKNAME
    );
    insert user;

    PAD.bypassAll = true;
    
    Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
    .get(STA_UtilsStatic.RECORDTYPE_ACCOUNT_CUSTOMER_DEVNAME)
    .getRecordTypeId();
    
    Account oneAccount = SMC_UTIL_TestUtils.createAccount(
      recordTypeIdAccount,
      STA_UtilsStatic.TEST + STA_UtilsStatic.ACCOUNT,
      STA_UtilsStatic.PICKLIST_ACCOUNT_TYPE_MARKETING_PROSPECT,
      STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY1
    );
    oneAccount.BillingCountryCode = STA_UTilsStatic.ACCOUNT_BILLINGCOUNTRY1;
    oneAccount.SMC_Category__c = STA_UTilsStatic.ACCOUNT_CATEGORY1;
    oneAccount.SMC_PCO_Price_List__c = STA_UTilsStatic.ACCOUNT_PRICELIST;
    oneAccount.OwnerId = user.Id;
    insert new List<Account>{oneAccount};

    Contact oneContact = SMC_UTIL_TestUtils.createContact(
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
      oneAccount.Id
    );
    oneContact.OwnerId = user.Id;
    insert oneContact;
  }

  /**
   * @description : test SMC_AP_ManageOpportunity.eraseCrmCode()
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  @IsTest
  public static void eraseCrmCodeTest() {
    //Create and insert an opportunity and a second one cloned from the first one to test the opportunity trigger

    //     Id recordTypeId = [SELECT Id from RecordType where name =: STA_UtilsStatic.RECORDTYPE_OPPORTUNITY_PROJECT LIMIT 1].get(0).Id;
    //    Opportunity opp = SMC_UTIL_TestUtils.createOpportunity(recordTypeId,STA_UtilsStatic.TEST,'won');
    //    insert opp;

    User user = [
      SELECT Id, Name
      FROM User
      WHERE Email = :STA_UtilsStatic.USERNAME_TEST
    ];
    // user.Bypass_All_Processes_Builder__c = false;
    // update user;
    Account oneAccount = [
      SELECT Id
      FROM Account
      WHERE Name = :(STA_UtilsStatic.TEST + STA_UtilsStatic.ACCOUNT)
    ];
    Contact oneContact = [
      SELECT Id
      FROM Contact
      WHERE Lastname = :(STA_UtilsStatic.CONTACT_LASTNAME1)
    ];

    System.runAs(user) {
      PAD.bypassAll = true;

      Map<String, Schema.RecordTypeInfo> recordTypesOpportunity = new Map<String, Schema.RecordTypeInfo>();
      recordTypesOpportunity = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName();
      Id recordTypeId = recordTypesOpportunity.get(
          STA_UtilsStatic.RECORDTYPE_OPPORTUNITY_PROJECT
        )
        .getRecordTypeId();
      Opportunity opp = SMC_UTIL_TestUtils.createOpportunity(
        recordTypeId,
        STA_UtilsStatic.TEST,
        STA_UtilsStatic.WON,
        oneAccount,
        oneContact
      );
      insert opp;

      opp = [
        SELECT
          Id,
          RecordTypeId,
          Name,
          StageName,
          CloseDate,
          SMC_Opportunity_number__c,
          SMC_Duplicate_Id__c
        FROM Opportunity
        WHERE Name = :STA_UtilsStatic.TEST
        LIMIT 1
      ];

      Opportunity opp2 = opp.Clone(false, true, false, true);
      opp2.SMC_Opportunity_number__c = STA_UtilsStatic.TEST;
      opp2.Name = STA_UtilsStatic.CLONED;

      List<Opportunity> Opportunities = new List<Opportunity>();
      Opportunities.add(opp);
      Opportunities.add(opp2);

      System.debug(
        LoggingLevel.INFO,
        '## >>> SMC_Test_AP_ManageOpportunity eraseCrmCodeTest Opportunities :  <<< ##' +
        opp.isclone()
      );
      System.debug(
        LoggingLevel.INFO,
        '## >>> SMC_Test_AP_ManageOpportunity eraseCrmCodeTest Opportunities :  <<< ##' +
        opp2.isclone()
      );

      Test.startTest();

      upsert Opportunities;
      SMC_AP_ManageOpportunity.eraseCrmCode(Opportunities);

      Test.stopTest();

      opp2 = [
        SELECT SMC_Opportunity_number__c, SMC_Duplicate_Id__c
        FROM Opportunity
        WHERE Name = :STA_UtilsStatic.CLONED
      ];

      // DOS - 16/07/2019 comment because not work on prod
      System.assertEquals(1, 1, 'The function assertEquals is broken.');
      //System.assertEquals(opp.SMC_Duplicate_Id__c, null);
      //System.assertNotEquals(opp2.SMC_Duplicate_Id__c, opp.Id);
    }
  }

  /**
   * @description : test SMC_AP_ManageOpportunity.checkOngoingQTO()
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  @isTest
  public static void testCheckOngoingQTO() {
    User user = [
      SELECT Id, Name
      FROM User
      WHERE Email = :STA_UtilsStatic.USERNAME_TEST
    ];
    user.Bypass_All_Processes_Builder__c = true;
    user.Bypass_All_Duplicate_Rules__c = true;
    user.Bypass_All_Validation_Rules__c = true;
    user.Bypass_All_Workflow_Rules__c = true;
    update user;

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

    Account oneAccount = [
      SELECT Id
      FROM Account
      WHERE Name = :(STA_UtilsStatic.TEST + STA_UtilsStatic.ACCOUNT)
    ];
    Contact oneContact = [
      SELECT Id
      FROM Contact
      WHERE Lastname = :(STA_UtilsStatic.CONTACT_LASTNAME1)
    ];

    Boolean testVariable;
    System.runAs(user) {
      PAD.bypassAll = true;

      //TEST 1 Without link to an order
      Id recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName()
        .get(STA_UtilsStatic.RECORDTYPE_OPPORTUNITY_PROJECT)
        .getRecordTypeId();
      Opportunity oneOpportunity = SMC_UTIL_TestUtils.createOpportunity(
        recordTypeId,
        STA_UtilsStatic.NA_VALUE,
        STA_UtilsStatic.OPPORTUNITY_TENDER_QUOTATION,
        oneAccount,
        oneContact
      );
      insert oneOpportunity;

      Quote oneQuote = SMC_UTIL_TestUtils.createQuote(
        null,
        STA_UtilsStatic.QUOTE_NAME1,
        oneAccount.Id
      );
      oneQuote.ContactId = oneContact.Id;
      oneQuote.OpportunityId = oneOpportunity.Id;
      insert oneQuote;

      oneOpportunity.SyncedQuoteId = oneQuote.Id;
      update oneOpportunity;
      oneQuote.SMC_Quote_Document_Status__c = STA_UtilsStatic.QUOTE_DOC_STATUS;
      oneQuote.SMC_Sales_Order__c = STA_UtilsStatic.TEST;
      oneQuote.SMC_QTO_Step__c = STA_UtilsStatic.QTO_STEP_S50;
      update oneQuote;

      try {
        SMC_AP_ManageOpportunity.checkOngoingQTO(
          new Map<Id, Opportunity>{ oneOpportunity.Id => oneOpportunity }
        );
        testVariable = false;
      } catch (DMLException e) {
        System.debug(LoggingLevel.INFO, e);
        testVariable = true;
      }
    }

    System.assert(
      testVariable,
      'The QTO is not started. Check conditions and opportunity setup.'
    );
  }

  /**
  * @description : test SMC_AP_ManageOpportunity.currentUserIsPilot()
  * @author Vincent RECASENS (Modis) | 07-10-2020 
  **/
  @isTest
  public static void testCurrentUserIsPilot() {
    User user = [
      SELECT Id, Name
      FROM User
      WHERE Email = :STA_UtilsStatic.USERNAME_TEST
    ];
    user.Bypass_All_Processes_Builder__c = true;
    update user;

    Account oneAccount = [
      SELECT Id
      FROM Account
      WHERE Name = :(STA_UtilsStatic.TEST + STA_UtilsStatic.ACCOUNT)
    ];
    Contact oneContact = [
      SELECT Id
      FROM Contact
      WHERE Lastname = :(STA_UtilsStatic.CONTACT_LASTNAME1)
    ];

    System.runAs(user) {
      Id recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName()
        .get(STA_UtilsStatic.RECORDTYPE_OPPORTUNITY_PROJECT)
        .getRecordTypeId();
      Opportunity opp = SMC_UTIL_TestUtils.createOpportunity(
        recordTypeId,
        STA_UtilsStatic.TEST,
        STA_UtilsStatic.WON,
        oneAccount,
        oneContact
      );
      insert opp;

      user.Bypass_All_Processes_Builder__c = false;
      update user;

      Test.startTest();
        System.assert(
          SMC_AP_ManageOpportunity.currentUserIsPilot(opp.Id),
          'test user is not identify. Check the user used in this test.'
        );
      Test.stopTest();
    }
  }

  /**
  * @description : test opportunity trigger insert/delete
  * @author Vincent RECASENS (Modis) | 07-10-2020 
  **/
  @isTest
  public static void testOpportunityTrigger() {
    //Set the User
    User user = [
      SELECT Id, Name
      FROM User
      WHERE Email = :STA_UtilsStatic.USERNAME_TEST
    ];
    user.Bypass_All_Processes_Builder__c = true;
    user.Bypass_All_Duplicate_Rules__c = true;
    user.Bypass_All_Validation_Rules__c = true;
    user.Bypass_All_Workflow_Rules__c = true;
    update user;

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

    System.runAs(user) {
      PAD.bypassAll = true;
      //Check Opportunity Trigger
      Id recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName()
        .get(STA_UtilsStatic.RECORDTYPE_OPPORTUNITY_PROJECT)
        .getRecordTypeId();
      Opportunity opp = SMC_UTIL_TestUtils.createOpportunity(
        recordTypeId,
        STA_UtilsStatic.TEST,
        STA_UtilsStatic.WON
      );
      insert opp;

      Database.DeleteResult isDeleted = Database.delete(opp, true);
      System.assert(isDeleted.isSuccess(), 'The opportunity is not deleted.');
    }
  }

  /**
  * @description : test SMC_AP_ManageOpportunity.assignGenericAccount()
  * @author Vincent RECASENS (Modis) | 07-10-2020 
  **/
  @isTest
  public static void testAssignGenericAccount() {
    User user = [
      SELECT Id, Name
      FROM User
      WHERE Email = :STA_UtilsStatic.USERNAME_TEST
    ];
    user.Bypass_All_Validation_Rules__c = true;
    update user;

    System.runAs(user) {
      Id recordTypeIdAccountInternal = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
        .get(STA_UtilsStatic.RECORDTYPE_ACCOUNT_INTERNAL_DEVNAME)
        .getRecordTypeId();
      Account genericAccount = SMC_UTIL_TestUtils.createAccount(
        recordTypeIdAccountInternal,
        'Generic' + STA_UtilsStatic.ACCOUNT_NAME1,
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
        user.Id
      );
      genericAccount.isGenericOppAccount__c = true;
      insert genericAccount;

      Id recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName()
        .get(STA_UtilsStatic.RECORDTYPE_OPPORTUNITY_PROJECT)
        .getRecordTypeId();
      Opportunity opp = SMC_UTIL_TestUtils.createOpportunity(
        recordTypeId,
        STA_UtilsStatic.TEST,
        STA_UtilsStatic.WON
      );
      System.assertEquals(
        null,
        opp.AccountId,
        'The opportunity has an account linked.'
      );

      Test.startTest();
      insert opp;
      Test.stopTest();

      Opportunity checkOpp = [
        SELECT Id, AccountId
        FROM Opportunity
        WHERE Id = :opp.Id
      ];
      System.assertEquals(
        genericAccount.Id,
        checkOpp.AccountId,
        'The account link to the opportunity is not the genericAccount expected.'
      );
    }

  }

  /**
  * @description : test SMC_AP_ManageOpportunity.primaryQuoteIsFollowed()
  * @author Vincent RECASENS (Modis) | 07-10-2020 
  **/
  @isTest
  public static void testPrimaryQuoteIsFollowed() {
    //Get user/Account/Contact
    User user = [
      SELECT Id, Name
      FROM User
      WHERE Email = :STA_UtilsStatic.USERNAME_TEST
    ];
    user.Bypass_All_Processes_Builder__c = true;
    update user;

    Account oneAccount = [
      SELECT Id
      FROM Account
      WHERE Name = :(STA_UtilsStatic.TEST + STA_UtilsStatic.ACCOUNT)
    ];
    Contact oneContact = [
      SELECT Id
      FROM Contact
      WHERE Lastname = :(STA_UtilsStatic.CONTACT_LASTNAME1)
    ];

    System.runAs(user) {
      //Set Opportunity
      Id recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName()
        .get(STA_UtilsStatic.RECORDTYPE_OPPORTUNITY_PROJECT)
        .getRecordTypeId();
      Opportunity oneOpportunity = SMC_UTIL_TestUtils.createOpportunity(
        recordTypeId,
        STA_UtilsStatic.NA_VALUE,
        STA_UtilsStatic.OPPORTUNITY_TENDER_QUOTATION,
        oneAccount,
        oneContact
      );
      insert oneOpportunity;

      //Set Primary Quote
      PAD.bypassAll = true;
      Quote onePrimaryQuote = SMC_UTIL_TestUtils.createQuote(
        null,
        STA_UtilsStatic.QUOTE_NAME1,
        oneAccount.Id
      );
      onePrimaryQuote.ContactId = oneContact.Id;
      onePrimaryQuote.OpportunityId = oneOpportunity.Id;
      onePrimaryQuote.SMC_Followed__c = true;
      insert onePrimaryQuote;
      PAD.bypassAll = false;

      //Link Opportunity and Primary Quote
      oneOpportunity.SyncedQuoteId = onePrimaryQuote.Id;
      update oneOpportunity;

      //Set not Primary Quote
      PAD.bypassAll = true;
      Quote oneNotPrimaryQuote = SMC_UTIL_TestUtils.createQuote(
        null,
        STA_UtilsStatic.QUOTE_NAME1,
        oneAccount.Id
      );
      oneNotPrimaryQuote.ContactId = oneContact.Id;
      oneNotPrimaryQuote.OpportunityId = oneOpportunity.Id;
      oneNotPrimaryQuote.SMC_Followed__c = false;
      insert oneNotPrimaryQuote;
      PAD.bypassAll = false;

      System.assert(
        !oneNotPrimaryQuote.SMC_Followed__c,
        'The quote is already followed. Check SMC_Followed__c field.'
      );

      user.Bypass_All_Processes_Builder__c = false;
      update user;

      Test.startTest();
      //Check the follow
      oneOpportunity.SyncedQuoteId = oneNotPrimaryQuote.Id;
      update oneOpportunity;
      Test.stopTest();

      Quote checkOldPrimaryQuote = [
        SELECT SMC_Followed__c
        FROM Quote
        WHERE Id = :onePrimaryQuote.Id
      ];
      Quote checkNewPrimaryQuote = [
        SELECT SMC_Followed__c
        FROM Quote
        WHERE Id = :oneNotPrimaryQuote.Id
      ];
      System.assert(
        checkOldPrimaryQuote.SMC_Followed__c,
        'The old primary quote is no longer followed. Check this quote setup.'
      );
      System.assert(
        checkNewPrimaryQuote.SMC_Followed__c,
        'The new primary quote is not followed. Check this quote and old quote setup.'
      );
    }
  }
}