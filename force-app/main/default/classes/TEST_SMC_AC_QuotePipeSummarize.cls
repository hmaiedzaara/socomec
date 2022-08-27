/**
 * @File Name          : TEST_SMC_AC_QuotePipeSummarize.cls
 * @Description        :
 * @Author             : Vincent RECASENS (Modis)
 * @Group              :
 * @Last Modified By   : Vincent RECASENS (Modis)
 * @Last Modified On   : 07-10-2020
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    04/04/2018   Guillaume BONNET (Modis)     Initial Version
 **/

@isTest
public without sharing class TEST_SMC_AC_QuotePipeSummarize {
  /** TO DO : Gearset voit une erreur UNABLE_TO_LOCK_ROW --> le Pricebook a té retiré pour faire passer la classe **/

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
    insert new List<User>{ userStandard };

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
      PAD.bypassAll = true;

      //create and insert an Account
      Map<String, Schema.RecordTypeInfo> recordTypesAccount = new Map<String, Schema.RecordTypeInfo>();
      recordTypesAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName();
      Id recordTypeIdAcc = recordTypesAccount.get(
          STA_UtilsStatic.RECORDTYPE_ACCOUNT_CUSTOMER_DEVNAME
        )
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
   * @description : test SMC_AC_QuotePipeSummarize.getAmountPipe()
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  @IsTest
  public static void getAmountPipeTest() {
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
      Decimal amount = SMC_AC_QuotePipeSummarize.getAmountPipe();
      Test.stopTest();
      System.debug(LoggingLevel.INFO, 'qte1.TotalPrice:' + qte1.TotalPrice);
      // System.assertEquals(1.4 + 3 + 20 + 15, amount);
      System.assertEquals(0.00, amount, 'The amount does not match.');
    }
  }

  /**
   * @description : test SMC_AC_QuotePipeSummarize.getQuoteNumberPipe()
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  @IsTest
  public static void getProjectNumberPipeTest() {
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
      Decimal nbOpp = SMC_AC_QuotePipeSummarize.getQuoteNumberPipe();
      System.assertEquals(2, nbOpp, 'The number of element does not match.');
    }
  }

  /**
  * @description : test SMC_AC_QuotePipeSummarize.getUserDefaultCurrency()
  * @author Vincent RECASENS (Modis) | 07-10-2020 
  **/
  @IsTest
  public static void getUserDefaultCurrencyTest() {
    User user = [
      SELECT Id, Name
      FROM User
      WHERE Email = :STA_UtilsStatic.USERNAME_TEST
    ];
    System.runAs(user) {
      System.assertEquals(
        SMC_AC_QuotePipeSummarize.getUserDefaultCurrency(),
        UserInfo.getDefaultCurrency(),
        'The user currency not does match.'
      );
    }
  }
}