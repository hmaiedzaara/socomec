/*
---------------------------------------------------------------------
-- - Name          : TEST_SMC_AP_ManageQuote
-- - Author        : Vincent RECASENS - MODIS
-- - Description   : Manage Quote               
-- Maintenance History:
--
-- Date         Name                Version  Remarks
-- -----------  ----                -------  ------------------------
-- 28-MAY-18    Vincent RECASENS    1.0     Initial version
---------------------------------------------------------------------
*/

@isTest
public without sharing class TEST_SMC_AP_ManageQuote {
  /**
   * @description : test setup
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  @testSetup
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
    user.SMC_Approval_Level__c = 1;
    user.SMC_User_Subsidiary__c = 'SSA_EXP';
    user.Bypass_Validation_Rule__c = 'SMC_EditInterfaceInformation;SMC_Lock_record_type';
    user.Bypass_All_Processes_Builder__c = true;
    insert user;
    User userHighLevelApproval = SMC_UTIL_TestUtils.createUser(
      'Submitter_' + STA_UtilsStatic.USER_NICKNAME,
      'Submitter_' + STA_UtilsStatic.USERNAME_TEST,
      profile.Id,
      'Submitter_' + STA_UtilsStatic.USERNAME_TEST,
      'Submitter_' + STA_UtilsStatic.USER_NICKNAME
    );
    userHighLevelApproval.SMC_Approval_Level__c = 5;
    userHighLevelApproval.SMC_User_Subsidiary__c = 'SSA_EXP';
    userHighLevelApproval.Bypass_Validation_Rule__c = 'SMC_EditInterfaceInformation;SMC_Lock_record_type';
    userHighLevelApproval.ManagerId = user.Id;
    userHighLevelApproval.Bypass_All_Processes_Builder__c = true;
    insert userHighLevelApproval;

    // Territory2Type theTerritoryType = [SELECT Id FROM Territory2Type LIMIT 1];
    // Territory2Model theTerritoryModel = [
    //   SELECT Id
    //   FROM Territory2Model
    //   WHERE ActivatedDate != null
    //   LIMIT 1
    // ];
    // Territory2 theTerritory = SMC_UTIL_TestUtils.createTerritory2(
    //   'Dev' + STA_UtilsStatic.TEST,
    //   STA_UtilsStatic.TEST,
    //   theTerritoryModel.Id,
    //   theTerritoryType.Id
    // );
    // insert theTerritory;
    // UserTerritory2Association userTerritoryAssociation = SMC_UTIL_TestUtils.createUserTerritory2Association(
    //   theTerritory.Id,
    //   user.Id
    // );
    // insert userTerritoryAssociation;

    Account account;

    System.runAs(user) {
      Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
        .get(STA_UtilsStatic.RECORDTYPE_ACCOUNT_CUSTOMER_DEVNAME)
        .getRecordTypeId();
      account = SMC_UTIL_TestUtils.createAccount(
        recordTypeIdAccount,
        STA_UtilsStatic.ACCOUNT_NAME1,
        STA_UtilsStatic.PICKLIST_ACCOUNT_TYPE_MARKETING_PROSPECT,
        STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY1
      );
      account.BillingCountryCode = STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY1;
      account.SMC_Category__c = STA_UtilsStatic.ACCOUNT_CATEGORY1;
      account.SMC_PCO_Price_List__c = STA_UtilsStatic.ACCOUNT_PRICELIST;
      account.SMC_ERPID_PCS__c = STA_UtilsStatic.ACCOUNT_ERPID_PCS;
      account.OwnerId = user.Id;
      insert account;

      Contact contact = SMC_UTIL_TestUtils.createContact(
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
        account.Id
      );
      insert contact;

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
      genericAccount.SMC_Account_Subsidiaries__c = 'SSA_EXP';
      insert genericAccount;
    }
  }

  /**
   * @description : test SMC_AP_ManageQuote.createFakeOpportunity(Insert)
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  @isTest
  public static void testCreateFakeOpportunityBeforeInsert() {
    User user = [
      SELECT Id, Name
      FROM User
      WHERE Email = :STA_UtilsStatic.USERNAME_TEST
    ];

    System.runAs(user) {
      Account oneAccount = [SELECT Id, Name FROM Account LIMIT 1];
      Contact oneContact = [SELECT Id, Name FROM Contact LIMIT 1];

      Id recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName()
        .get(STA_UtilsStatic.RECORDTYPE_OPPORTUNITY_PROJECT)
        .getRecordTypeId();
      Opportunity oneOpportunity = SMC_UTIL_TestUtils.createOpportunity(
        recordTypeId,
        STA_UtilsStatic.NA_VALUE,
        STA_UtilsStatic.OPPORTUNITY_PROJECT_DETECTED
      );
      insert oneOpportunity;

      Map<String, Schema.RecordTypeInfo> recordTypesQuote = new Map<String, Schema.RecordTypeInfo>();
      recordTypesQuote = Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName();
      Id quoteProjectId = recordTypesQuote.get(
          STA_UtilsStatic.RECORDTYPE_QUOTE_PROJECT
        )
        .getRecordTypeId();
      Id quickQuoteId = recordTypesQuote.get(
          STA_UtilsStatic.RECORDTYPE_QUICK_QUOTE
        )
        .getRecordTypeId();

      List<Quote> quotes = new List<Quote>();
      Quote quickQuote = SMC_UTIL_TestUtils.createQuote(
        null,
        STA_UtilsStatic.QUOTE_NAME1,
        oneAccount.Id
      );
      quickQuote.ContactId = oneContact.Id;
      quickQuote.RecordTypeId = quickQuoteId;
      quickQuote.SMC_Closing_Date__c = Date.today().addMonths(1);
      quotes.add(quickQuote);

      Quote projectQuote = SMC_UTIL_TestUtils.createQuote(
        null,
        STA_UtilsStatic.QUOTE_NAME2,
        oneAccount.Id
      );
      projectQuote.OpportunityId = oneOpportunity.Id;
      projectQuote.RecordTypeId = quoteProjectId;
      projectQuote.SMC_Closing_Date__c = Date.today().addMonths(1);
      quotes.add(projectQuote);

      Test.startTest();
      insert quotes;
      Test.stopTest();

      Quote quickQuoteToCheck = [
        SELECT Id, OpportunityId
        FROM Quote
        WHERE Id = :quickQuote.Id
      ];
      List<Opportunity> checkOpportunities = new List<Opportunity>();
      checkOpportunities = [
        SELECT Id
        FROM Opportunity
        WHERE RecordTypeId != :recordTypeId
      ];
      System.assertEquals(
        1,
        checkOpportunities.size(),
        'The fake opportunity was not created.'
      );
      System.assertEquals(
        checkOpportunities[0].Id,
        quickQuoteToCheck.OpportunityId,
        'The new fake opportunity is not linked to the new quote.'
      );
    }
  }

  /**
   * @description : test SMC_AP_ManageQuote.checkOngoingQTO()
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  @isTest
  public static void testCheckOngoingQTO() {
    User user = [
      SELECT Id, Name
      FROM User
      WHERE Email = :STA_UtilsStatic.USERNAME_TEST
    ];
    user.Bypass_All_Validation_Rules__c = true;
    update user;

    System.runAs(user) {
      PAD.bypassAll = true;

      Account oneAccount = [SELECT Id, Name FROM Account LIMIT 1];
      Contact oneContact = [SELECT Id, Name FROM Contact LIMIT 1];

      Id recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName()
        .get(STA_UtilsStatic.RECORDTYPE_OPPORTUNITY_PROJECT)
        .getRecordTypeId();
      Opportunity oneOpportunity = SMC_UTIL_TestUtils.createOpportunity(
        recordTypeId,
        STA_UtilsStatic.NA_VALUE,
        STA_UtilsStatic.OPPORTUNITY_PROJECT_DETECTED
      );
      insert oneOpportunity;

      Quote oneQuote = SMC_UTIL_TestUtils.createQuote(
        null,
        STA_UtilsStatic.QUOTE_NAME3,
        oneAccount.Id
      );
      oneQuote.ContactId = oneContact.Id;
      oneQuote.OpportunityId = oneOpportunity.Id;
      insert oneQuote;

      oneOpportunity.SyncedQuoteId = oneQuote.Id;
      update oneOpportunity;
      oneQuote.SMC_QTO_Step__c = STA_UtilsStatic.QTO_STEP_S50;
      oneQuote.SMC_Quote_Document_Status__c = STA_UtilsStatic.QUOTE_DOC_STATUS;
      update oneQuote;

      List<Quote> newlist = new List<Quote>();
      newList.add(oneQuote);
      System.assert(
        SMC_AP_ManageQuote.checkOngoingQTO(newList),
        'The conditions to strat a QTO are not meet. Check quote setup.'
      );
    }

    user.Bypass_All_Validation_Rules__c = false;
    update user;
  }

  /**
   * @description : test delete quote
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  @isTest
  public static void testDeleteQuote() {
    User user = [
      SELECT Id, Name
      FROM User
      WHERE Email = :STA_UtilsStatic.USERNAME_TEST
    ];

    System.runAs(user) {
      PAD.bypassAll = true;

      Account oneAccount = [SELECT Id, Name FROM Account LIMIT 1];
      Contact oneContact = [SELECT Id, Name FROM Contact LIMIT 1];

      Id recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName()
        .get(STA_UtilsStatic.RECORDTYPE_OPPORTUNITY_PROJECT)
        .getRecordTypeId();
      Opportunity oneOpportunity = SMC_UTIL_TestUtils.createOpportunity(
        recordTypeId,
        STA_UtilsStatic.NA_VALUE,
        STA_UtilsStatic.OPPORTUNITY_PROJECT_DETECTED
      );
      insert oneOpportunity;

      Quote oneQuote = SMC_UTIL_TestUtils.createQuote(
        null,
        STA_UtilsStatic.QUOTE_NAME3,
        oneAccount.Id
      );
      oneQuote.ContactId = oneContact.Id;
      oneQuote.OpportunityId = oneOpportunity.Id;
      insert oneQuote;

      PAD.bypassAll = false;

      System.assert(
        Database.delete(oneQuote).isSuccess(),
        'The quote can not be deleted. Check the primary quote of the opportunity linked.'
      );
    }
  }

  /**
   * @description : test SMC_AP_ManageQuote.displayInfosToStartQTO()
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  @isTest
  public static void testDisplayInfosToStartQTO() {
    User user = [
      SELECT Id, Name
      FROM User
      WHERE Email = :STA_UtilsStatic.USERNAME_TEST
    ];

    System.runAs(user) {
      // Contact oneContact = [SELECT Id, Name, AccountId FROM Contact LIMIT 1];

      // Id recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName()
      //   .get(STA_UtilsStatic.RECORDTYPE_OPPORTUNITY_PROJECT)
      //   .getRecordTypeId();
      // Opportunity oneOpportunity = SMC_UTIL_TestUtils.createOpportunity(
      //   recordTypeId,
      //   STA_UtilsStatic.NA_VALUE,
      //   STA_UtilsStatic.OPPORTUNITY_PROJECT_DETECTED
      // );
      // insert oneOpportunity;

      // Id quoteProjectId = Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName()
      //   .get(STA_UtilsStatic.RECORDTYPE_QUOTE_PROJECT)
      //   .getRecordTypeId();
      Quote oneQuote = SMC_UTIL_TestUtils.createQuote(
        null,
        STA_UtilsStatic.QUOTE_NAME3,
        null
      );
      // oneQuote.OpportunityId = oneOpportunity.Id;
      // oneQuote.RecordTypeId = quoteProjectId;
      // insert oneQuote;

      System.assert(
        SMC_AP_ManageQuote.displayInfosToStartQTO(new List<Quote>{ oneQuote }),
        'All conditions to start are meet. Check quote setup.'
      );
    }
  }

  /**
   * @description : test SMC_AP_ManageQuote.setProcessInstanceIdField --> code coverage
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  @isTest
  public static void testSetProcessInstanceIdField() {
    User user = [
      SELECT Id, Name
      FROM User
      WHERE Email = :STA_UtilsStatic.USERNAME_TEST
    ];
    //PermissonSet "Quotation Tool"
    PermissionSet ps1 = [
      SELECT ID
      FROM PermissionSet
      WHERE Name = :STA_UtilsStatic.BUSINESS_DEVELOPPER
    ];
    PermissionSet ps2 = [
      SELECT ID
      FROM PermissionSet
      WHERE Name = :STA_UtilsStatic.QUOTATION_TOOL_PERMISSION
    ];
    insert new List<PermissionSetAssignment>{
      new PermissionSetAssignment(
        AssigneeId = user.id,
        PermissionSetId = ps1.Id
      ),
      new PermissionSetAssignment(
        AssigneeId = user.id,
        PermissionSetId = ps2.Id
      )
    };

    System.runAs(user) {
      Account oneAccount = [SELECT Id, Name FROM Account LIMIT 1];
      Contact oneContact = [SELECT Id, Name FROM Contact LIMIT 1];

      PAD.bypassAll = true;

      Map<String, Schema.RecordTypeInfo> recordTypesQuote = new Map<String, Schema.RecordTypeInfo>();
      recordTypesQuote = Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName();
      Id quoteProjectId = recordTypesQuote.get(
          STA_UtilsStatic.RECORDTYPE_QUOTE_PROJECT
        )
        .getRecordTypeId();

      Id recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName()
        .get(STA_UtilsStatic.RECORDTYPE_OPPORTUNITY_PROJECT)
        .getRecordTypeId();
      Opportunity oneOpportunity = SMC_UTIL_TestUtils.createOpportunity(
        recordTypeId,
        STA_UtilsStatic.NA_VALUE,
        STA_UtilsStatic.OPPORTUNITY_PROJECT_DETECTED
      );
      insert oneOpportunity;

      Quote projectQuote = SMC_UTIL_TestUtils.createQuote(
        null,
        STA_UtilsStatic.QUOTE_NAME1,
        oneAccount.Id
      );
      projectQuote.ContactId = oneContact.Id;
      projectQuote.OpportunityId = oneOpportunity.Id;
      projectQuote.RecordTypeId = quoteProjectId;
      insert projectQuote;

      projectQuote.SMC_Approval_Level_Validated__c = 1;
      projectQuote.SMC_Approval_Level_Requested__c = 5;
      projectQuote.SMC_Approval_Status__c = STA_UtilsStatic.STATUS_APPROVAL_PENDING;

      Quote checkProjectQuote = [
        SELECT
          Id,
          SMC_Approval_Needed__c,
          SMC_Approval_Level_Validated__c,
          SMC_Approval_Status__c,
          TECH_SMC_Process_Instance_Id__c,
          QuoteNumber
        FROM Quote
      ];
      System.assertEquals(
        null,
        checkProjectQuote.TECH_SMC_Process_Instance_Id__c,
        'Check the conditions to start an approval.'
      );

      Test.startTest();
      SMC_AP_ManageQuote.setProcessInstanceIdField(
        new Map<Id, Quote>{ projectQuote.Id => projectQuote },
        true
      );
      Test.stopTest();
    }
  }

  /**
   * @description : test SMC_AP_ManageQuote.resetProcessInstanceIdField --> code coverage
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  @isTest
  public static void testResetProcessInstanceIdField() {
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
    //PermissonSet "Quotation Tool"
    PermissionSet ps1 = [
      SELECT ID
      FROM PermissionSet
      WHERE Name = :STA_UtilsStatic.BUSINESS_DEVELOPPER
    ];
    PermissionSet ps2 = [
      SELECT ID
      FROM PermissionSet
      WHERE Name = :STA_UtilsStatic.QUOTATION_TOOL_PERMISSION
    ];
    insert new List<PermissionSetAssignment>{
      new PermissionSetAssignment(
        AssigneeId = user.id,
        PermissionSetId = ps1.Id
      ),
      new PermissionSetAssignment(
        AssigneeId = user.id,
        PermissionSetId = ps2.Id
      )
    };

    System.runAs(user) {
      Account oneAccount = [SELECT Id, Name FROM Account LIMIT 1];
      Contact oneContact = [SELECT Id, Name FROM Contact LIMIT 1];

      PAD.bypassAll = true;

      //Setting
      Map<String, Schema.RecordTypeInfo> recordTypesQuote = new Map<String, Schema.RecordTypeInfo>();
      recordTypesQuote = Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName();
      Id quoteProjectId = recordTypesQuote.get(
          STA_UtilsStatic.RECORDTYPE_QUOTE_PROJECT
        )
        .getRecordTypeId();

      Id recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName()
        .get(STA_UtilsStatic.RECORDTYPE_OPPORTUNITY_PROJECT)
        .getRecordTypeId();
      Opportunity oneOpportunity = SMC_UTIL_TestUtils.createOpportunity(
        recordTypeId,
        STA_UtilsStatic.NA_VALUE,
        STA_UtilsStatic.OPPORTUNITY_PROJECT_DETECTED
      );
      insert oneOpportunity;

      Quote projectQuote = SMC_UTIL_TestUtils.createQuote(
        null,
        STA_UtilsStatic.QUOTE_NAME1,
        oneAccount.Id
      );
      projectQuote.ContactId = oneContact.Id;
      projectQuote.OpportunityId = oneOpportunity.Id;
      projectQuote.RecordTypeId = quoteProjectId;
      insert projectQuote;

      Test.startTest();
      SMC_AP_ManageQuote.resetProcessInstanceIdField(
        new Set<Id>{ projectQuote.Id }
      );
      Test.stopTest();

      Quote checkProjectQuote = [
        SELECT
          Id,
          SMC_Approval_Needed__c,
          SMC_Approval_Level_Validated__c,
          SMC_Approval_Status__c,
          TECH_SMC_Process_Instance_Id__c,
          QuoteNumber
        FROM Quote
      ];
      System.assertEquals(
        null,
        checkProjectQuote.TECH_SMC_Process_Instance_Id__c,
        'Check the conditions to start an approval.'
      );
    }
  }

  /**
   * @description : test SMC_AP_ManageQuote.primaryQuoteIsFollowed() by trigger
   * @author Vincent RECASENS (Modis) | 07-15-2020
   **/
  @isTest
  public static void testPrimaryQuoteIsFollowed() {
    User user = [
      SELECT Id, Name
      FROM User
      WHERE Email = :STA_UtilsStatic.USERNAME_TEST
    ];
    // update user;

    System.runAs(user) {
      PAD.bypassAll = true;

      Account oneAccount = [SELECT Id, Name FROM Account LIMIT 1];
      Contact oneContact = [SELECT Id, Name FROM Contact LIMIT 1];

      Id recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName()
        .get(STA_UtilsStatic.RECORDTYPE_OPPORTUNITY_PROJECT)
        .getRecordTypeId();
      Opportunity oneOpportunity = SMC_UTIL_TestUtils.createOpportunity(
        recordTypeId,
        STA_UtilsStatic.NA_VALUE,
        STA_UtilsStatic.OPPORTUNITY_PROJECT_DETECTED
      );
      insert oneOpportunity;

      Id quoteProjectId = Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName()
        .get(STA_UtilsStatic.RECORDTYPE_QUOTE_PROJECT)
        .getRecordTypeId();
      Quote firstPrimaryQuote = SMC_UTIL_TestUtils.createQuote(
        null,
        STA_UtilsStatic.QUOTE_NAME3 + ' First Primary Quote',
        oneAccount.Id
      );
      firstPrimaryQuote.ContactId = oneContact.Id;
      firstPrimaryQuote.RecordTypeId = quoteProjectId;
      firstPrimaryQuote.SMC_Followed__c = true;
      firstPrimaryQuote.OpportunityId = oneOpportunity.Id;
      Quote secondPrimaryQuote = SMC_UTIL_TestUtils.createQuote(
        null,
        STA_UtilsStatic.QUOTE_NAME3 + ' Second Primary Quote',
        oneAccount.Id
      );
      secondPrimaryQuote.ContactId = oneContact.Id;
      secondPrimaryQuote.RecordTypeId = quoteProjectId;
      secondPrimaryQuote.SMC_Followed__c = false;
      secondPrimaryQuote.OpportunityId = oneOpportunity.Id;
      insert new List<Quote>{ firstPrimaryQuote, secondPrimaryQuote };

      oneOpportunity.SyncedQuoteId = firstPrimaryQuote.Id;
      update oneOpportunity;

      PAD.bypassAll = false;

      Test.startTest();
      oneOpportunity.SyncedQuoteId = secondPrimaryQuote.Id;
      update oneOpportunity;
      Test.stopTest();

      System.assert(
        [SELECT SMC_Followed__c FROM Quote WHERE Id = :secondPrimaryQuote.Id]
        .SMC_Followed__c,
        'The new primary quote do not take old primary quote\'s SMC_Followed__c value.'
      );
    }
  }

  //This method have is own context cause there is an "Too many SOQL" error if we execute more SOQL here
  @isTest
  public static void testCheckApprovalInformations() {
    User userHighLevelApproval = [
      SELECT Id, Name, SMC_Approval_Level__c, ManagerId
      FROM User
      WHERE Email = :('Submitter_' + STA_UtilsStatic.USERNAME_TEST)
    ];
    //PermissonSet "Quotation Tool"
    PermissionSet ps2 = [
      SELECT ID
      FROM PermissionSet
      WHERE Name = :STA_UtilsStatic.QUOTATION_TOOL_PERMISSION
    ];
    insert new List<PermissionSetAssignment>{
      new PermissionSetAssignment(
        AssigneeId = userHighLevelApproval.id,
        PermissionSetId = ps2.Id
      )
    };

    System.runAs(userHighLevelApproval) {
      PAD.bypassAll = true;

      Id recordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
        .get(STA_UtilsStatic.RECORDTYPE_ACCOUNT_CUSTOMER_DEVNAME)
        .getRecordTypeId();
      Account oneAccount = SMC_UTIL_TestUtils.createAccount(
        recordTypeIdAccount,
        STA_UtilsStatic.ACCOUNT_NAME2,
        STA_UtilsStatic.PICKLIST_ACCOUNT_TYPE_MARKETING_PROSPECT,
        STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY2
      );
      oneAccount.BillingCountryCode = STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY2;
      oneAccount.SMC_Category__c = STA_UtilsStatic.ACCOUNT_CATEGORY2;
      oneAccount.SMC_PCO_Price_List__c = STA_UtilsStatic.ACCOUNT_PRICELIST;
      oneAccount.SMC_ERPID_PCS__c = STA_UtilsStatic.ACCOUNT_ERPID_PCS;
      oneAccount.OwnerId = userHighLevelApproval.Id;
      insert oneAccount;

      Contact oneContact = SMC_UTIL_TestUtils.createContact(
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
        oneAccount.Id
      );
      insert oneContact;

      Map<String, Schema.RecordTypeInfo> recordTypesQuote = new Map<String, Schema.RecordTypeInfo>();
      recordTypesQuote = Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName();
      Id quoteProjectId = recordTypesQuote.get(
          STA_UtilsStatic.RECORDTYPE_QUOTE_PROJECT
        )
        .getRecordTypeId();

      Id recordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName()
        .get(STA_UtilsStatic.RECORDTYPE_OPPORTUNITY_PROJECT)
        .getRecordTypeId();
      Opportunity oneOpportunity = SMC_UTIL_TestUtils.createOpportunity(
        recordTypeId,
        STA_UtilsStatic.NA_VALUE,
        STA_UtilsStatic.OPPORTUNITY_PROJECT_DETECTED
      );
      insert oneOpportunity;

      // PAD.bypassAll = false;

      Quote projectQuote = SMC_UTIL_TestUtils.createQuote(
        null,
        STA_UtilsStatic.QUOTE_NAME1,
        oneAccount.Id
      );
      projectQuote.ContactId = oneContact.Id;
      projectQuote.OpportunityId = oneOpportunity.Id;
      projectQuote.RecordTypeId = quoteProjectId;
      projectQuote.SMC_Approval_Level_Validated__c = 0;
      projectQuote.SMC_Approval_Level_Requested__c = 5;
      projectQuote.SMC_Next_Approver__c = userHighLevelApproval.Id;
      projectQuote.TECH_SMC_Next_Approver_Id__c = userHighLevelApproval.Id;

      Quote projectQuoteBis = SMC_UTIL_TestUtils.createQuote(
        null,
        STA_UtilsStatic.QUOTE_NAME1,
        oneAccount.Id
      );
      projectQuoteBis.ContactId = oneContact.Id;
      projectQuoteBis.OpportunityId = oneOpportunity.Id;
      projectQuoteBis.RecordTypeId = quoteProjectId;
      projectQuoteBis.SMC_Approval_Level_Validated__c = 1;
      projectQuoteBis.SMC_Approval_Level_Requested__c = 5;
      projectQuoteBis.SMC_Next_Approver__c = userHighLevelApproval.Id;
      projectQuoteBis.TECH_SMC_Next_Approver_Id__c = userHighLevelApproval.ManagerId;
      insert new List<Quote>{ projectQuoteBis };

      Test.startTest();
      SMC_AP_ManageQuote.checkApprovalInformations(
        new Map<Id, Quote>{ projectQuoteBis.Id => projectQuoteBis },
        new Map<Id, Quote>{ projectQuoteBis.Id => projectQuote }
      );
      Test.stopTest();

      Quote checkProjectQuote = [
        SELECT Id, SMC_Next_Approver__c, SMC_Approval_Level_Validated__c
        FROM Quote
        WHERE Id = :projectQuoteBis.Id
      ];

      System.assertEquals(
        userHighLevelApproval.ManagerId,
        checkProjectQuote.SMC_Next_Approver__c,
        'The next approver is not identify. Check manager of actual approver.'
      );
      System.assertEquals(
        5,
        checkProjectQuote.SMC_Approval_Level_Validated__c,
        'Check conditions to jump on the next level of the approval.'
      );
    }
  }
}