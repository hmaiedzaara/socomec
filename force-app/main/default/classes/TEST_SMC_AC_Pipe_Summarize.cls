/*
---------------------------------------------------------------------
-- - Name          : TEST_SMC_AC_Pipe_Summarize
-- - Author        : Vincent RECASENS (VRE)
-- - Description   : Test the controler SMC_AC_Pipe_Summarize
-- Maintenance History:
--
-- Date         Name   Version  Remarks 
-- -----------  ----   -------  ---------------------------
-- 04-OCT-2019  VRE    1.0      Initial version 
---------------------------------------------------------------------
*/

@IsTest
public with sharing class TEST_SMC_AC_Pipe_Summarize {
  /**
  * @description : test setup
  * @author Vincent RECASENS (Modis) | 07-10-2020 
  **/
  @testSetup
  public static void insertQuotes() {
    //Set the User
    User userStandard = SMC_UTIL_TestUtils.createTestUser(
      STA_UtilsStatic.PROFILE_SALE_STANDARD
    );
    userStandard.Bypass_Validation_Rule__c = 'SMC_EditInterfaceInformation;SMC_Lock_record_type';
    insert new List<User>{ userStandard };

    Territory2Type theTerritoryType = [SELECT Id FROM Territory2Type LIMIT 1];
    Territory2Model theTerritoryModel = [
      SELECT Id
      FROM Territory2Model
      WHERE ActivatedDate != null
      LIMIT 1
    ];
    Territory2 theTerritory = SMC_UTIL_TestUtils.createTerritory2(
      'Dev' + STA_UtilsStatic.TEST,
      STA_UtilsStatic.TEST,
      theTerritoryModel.Id,
      theTerritoryType.Id
    );
    insert theTerritory;
    UserTerritory2Association userTerritoryAssociation = SMC_UTIL_TestUtils.createUserTerritory2Association(
      theTerritory.Id,
      userStandard.Id
    );
    insert userTerritoryAssociation;

    //PermissonSet "Quotation Tool"
    PermissionSet ps = [
      SELECT Id
      FROM PermissionSet
      WHERE Name = :STA_UtilsStatic.QUOTATION_TOOL_PERMISSION
    ];
    insert new PermissionSetAssignment(
      AssigneeId = userStandard.id,
      PermissionSetId = ps.Id
    );

    System.runAs(userStandard) {
      //Generic account
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
        userStandard.Id
      );
      genericAccount.isGenericOppAccount__c = true;
      insert genericAccount;

      PAD.bypassAll = true;
      //create and insert an Account
      Id recordTypeIdAcc = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
        .get(STA_UtilsStatic.RECORDTYPE_ACCOUNT_CUSTOMER_DEVNAME)
        .getRecordTypeId();
      Account accountGAP = SMC_UTIL_TestUtils.createAccount(
        recordTypeIdAcc,
        STA_UtilsStatic.TEST,
        STA_UtilsStatic.PICKLIST_ACCOUNT_TYPE_MARKETING_PROSPECT,
        STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY2
      );
      insert accountGAP;

      //create and insert an Opportunity
      Map<String, Schema.RecordTypeInfo> recordTypesOpportunity = new Map<String, Schema.RecordTypeInfo>();
      recordTypesOpportunity = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName();
      Id recordTypeIdOpp = recordTypesOpportunity.get(
          STA_UtilsStatic.RECORDTYPE_OPPORTUNITY_PROJECT
        )
        .getRecordTypeId();
      Opportunity opp = SMC_UTIL_TestUtils.createOpportunity(
        recordTypeIdOpp,
        STA_UtilsStatic.TEST,
        STA_UtilsStatic.OPEN
      );
      opp.AccountId = accountGAP.Id;
      opp.pricebook2Id = Test.getStandardPricebookId();
      insert opp;

      Map<String, Schema.RecordTypeInfo> recordTypesQuote = new Map<String, Schema.RecordTypeInfo>();
      recordTypesQuote = Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName();
      Id simuExpressRecordTypeId = recordTypesQuote.get(
          STA_UtilsStatic.RECORDTYPE_SIMU_EXPRESS
        )
        .getRecordTypeId();
      Id quickQuoteRecordTypeId = recordTypesQuote.get(
          STA_UtilsStatic.RECORDTYPE_QUICK_QUOTE
        )
        .getRecordTypeId();
      Id projectQuoteRecordTypeId = recordTypesQuote.get(
          STA_UtilsStatic.RECORDTYPE_QUOTE_PROJECT
        )
        .getRecordTypeId();

      // //insert Pricebook2
      Pricebook2 prcbk = new Pricebook2(Name = STA_UtilsStatic.PRICEBOOK_NAME);
      insert prcbk;

      //insert product2Id
      Product2 prdct = new Product2(Name = STA_UtilsStatic.PRODUCT_NAME);
      prdct.SMC_Product_BA__c = STA_UtilsStatic.PCO;
      insert prdct;

      //insert PricebookEntry
      // PricebookEntry prcBkEntry = new PricebookEntry(UnitPrice = 3.5, Pricebook2Id= Test.getStandardPricebookId(), Product2Id = prdct.id, IsActive=true);
      // insert prcBkEntry;

      Quote qte1 = SMC_UTIL_TestUtils.createQuote(
        opp.Id,
        STA_UtilsStatic.QUOTE_NAME1,
        accountGAP.Id
      );
      qte1.RecordTypeId = quickQuoteRecordTypeId;
      // qte1.pricebook2Id = Test.getStandardPricebookId();
      insert qte1;

      //create and insert a QuoteLine
      // QuoteLineItem quoteLine11 = new QuoteLineItem(QuoteId = qte1.Id, UnitPrice= 1.4, Quantity=1, /*PricebookEntryId=prcBkEntry.Id,*/ Product2Id=prdct.Id);
      // QuoteLineItem quoteLine12 = new QuoteLineItem(QuoteId = qte1.Id, UnitPrice= 3, Quantity=1, /*PricebookEntryId=prcBkEntry.Id,*/ Product2Id=prdct.Id);
      // PAD.bypassAll = true;
      // insert new List<QuoteLineItem> {quoteLine11, quoteLine12};
      PAD.bypassAll = false;

      Quote qte2 = SMC_UTIL_TestUtils.createQuote(
        opp.Id,
        STA_UtilsStatic.QUOTE_NAME1,
        accountGAP.Id
      );
      qte2.RecordTypeId = projectQuoteRecordTypeId;
      // qte2.pricebook2Id = Test.getStandardPricebookId();
      insert qte2;

      //create and insert a QuoteLine
      // QuoteLineItem quoteLine21 = new QuoteLineItem(QuoteId = qte2.Id, UnitPrice= 20, Quantity=1, /*PricebookEntryId=prcBkEntry.Id,*/ Product2Id=prdct.Id);
      // QuoteLineItem quoteLine22 = new QuoteLineItem(QuoteId = qte2.Id, UnitPrice= 15, Quantity=1, /*PricebookEntryId=prcBkEntry.Id,*/ Product2Id=prdct.Id);
      // insert new List<QuoteLineItem> {quoteLine21, quoteLine22};

      Quote qte3 = SMC_UTIL_TestUtils.createQuote(
        opp.Id,
        STA_UtilsStatic.QUOTE_NAME1,
        accountGAP.Id
      );
      qte3.RecordTypeId = simuExpressRecordTypeId;
      // qte3.pricebook2Id = Test.getStandardPricebookId();
      insert qte3;

      //create and insert a QuoteLine
      // QuoteLineItem quoteLine31 = new QuoteLineItem(QuoteId = qte3.Id, UnitPrice= 6000.3333333, Quantity=1, /*PricebookEntryId=prcBkEntry.Id,*/ Product2Id=prdct.Id);
      // QuoteLineItem quoteLine32 = new QuoteLineItem(QuoteId = qte3.Id, UnitPrice= 6000.11111, Quantity=1, /*PricebookEntryId=prcBkEntry.Id,*/ Product2Id=prdct.Id);
      // insert new List<QuoteLineItem> {quoteLine31, quoteLine32};
    }

    PAD.bypassAll = false;
  }

  /**
  * @description : test SMC_AC_PipeSummarize.getInformations(PipeProject)
  * @author Vincent RECASENS (Modis) | 07-10-2020 
  **/
  @isTest
  public static void testGetInformationsForProjects() {
    User user = [
      SELECT Id, Name
      FROM User
      WHERE Email = :STA_UtilsStatic.USERNAME_TEST
    ];
    System.runAs(user) {
      Map<String, Schema.RecordTypeInfo> recordTypesOpportunity = new Map<String, Schema.RecordTypeInfo>();
      recordTypesOpportunity = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName();
      Id recordTypeId = recordTypesOpportunity.get(
          STA_UtilsStatic.RECORDTYPE_OPPORTUNITY_PROJECT
        )
        .getRecordTypeId();
      Opportunity o = new Opportunity();
      o.Name = STA_UtilsStatic.TEST;
      o.CloseDate = Date.today();
      o.OwnerId = UserInfo.getUserID();
      o.StageName = STA_UtilsStatic.OPPORTUNITY_PROJECT_DETECTED;
      o.RecordTypeId = recordTypeId;
      o.amount = 1.00;
      insert o;

      Test.startTest();
      SMC_AC_PipeSummarize.AllInformations result = SMC_AC_PipeSummarize.getInformations(
        STA_UtilsStatic.PROJECT_PIPE
      );
      Test.stopTest();

      System.assertEquals(
        o.Amount,
        result.amountPipe,
        'The amount does not match.'
      );
      System.assertEquals(
        2,
        result.elementPipe,
        'The number of element does not match.'
      );
      System.assertEquals(
        result.userCurrency,
        UserInfo.getDefaultCurrency(),
        'The user currency not does match.'
      );
    }
  }

  /**
  * @description : test SMC_AC_PipeSummarize.getInformations(QuoteProject)
  * @author Vincent RECASENS (Modis) | 07-10-2020 
  **/
  @isTest
  public static void testGetInformationsForQuotes() {
    User user = [
      SELECT Id, Name
      FROM User
      WHERE Email = :STA_UtilsStatic.USERNAME_TEST
    ];
    System.runAs(user) {
      Quote qte1 = [
          SELECT TotalPrice
          FROM Quote
          WHERE Name = :STA_UtilsStatic.QUOTE_NAME1
        ]
        .get(0);
      Test.startTest();
      SMC_AC_PipeSummarize.AllInformations result = SMC_AC_PipeSummarize.getInformations(
        STA_UtilsStatic.QUOTE_PIPE
      );
      Test.stopTest();

      System.assertEquals(
        0.00,
        result.amountPipe,
        'The amount does not match.'
      );
      System.assertEquals(
        3,
        result.elementPipe,
        'The number of element does not match.'
      );
      System.assertEquals(
        result.userCurrency,
        UserInfo.getDefaultCurrency(),
        'The user currency not does match.'
      );
    }
  }
}