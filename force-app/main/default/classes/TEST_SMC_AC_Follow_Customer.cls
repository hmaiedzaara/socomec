/**
 * @description       :
 * @author            : Vincent RECASENS (Modis)
 * @group             :
 * @last modified on  : 02-23-2021
 * @last modified by  : Vincent RECASENS (Modis)
 * Modifications Log
 * Ver   Date         Author                     Modification
 * 1.0   02-23-2021   Vincent RECASENS (Modis)   Initial Version
 **/
@IsTest
public with sharing class TEST_SMC_AC_Follow_Customer {

  /**
   * @description : Test Setup used to factorise creation of account
   * @author Denis PHAM (Modis) | 14-04-2022
   **/
  @TestSetup
  static void createSetup(){

    Id recordTypeIdAccount = [
      SELECT Id
      FROM RecordType
      WHERE name = :STA_UtilsStatic.RECORDTYPE_ACCOUNT_CUSTOMER
    ]
    .Id;

    Account account = SMC_UTIL_TestUtils.createAccount(
      recordTypeIdAccount,
      STA_UtilsStatic.TEST + STA_UtilsStatic.ACCOUNT,
      STA_UtilsStatic.PICKLIST_ACCOUNT_TYPE_MARKETING_PROSPECT,
      STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY1
    );
    account.AccountNumber = 'ACC-{000001}';
    account.SMC_Account_Subsidiaries__c = 'SSA';
    account.SMC_ERPID_PCS__c = 'PCS Code';
    insert account;

  }


  /**
   * @description : test SMC_AC_Follow_Customer.initialisation(Statistics)
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  @isTest
  public static void testGetStatistic() {
    
    Account account = [SELECT Id, AccountNumber, SMC_ERPID_PCS__c, SMC_Account_Subsidiaries__c, SMC_TECH_Sales_Office__c, SMC_TECH_Suffix_Smartconf__c FROM Account WHERE AccountNumber = 'ACC-{000001}' LIMIT 1];

    StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
    mock.setStaticResource(
      STA_UtilsStatic.MOCK_FOLLOW_CUSTOMER_FAMILY_TURNOVER
    );
    mock.setStatusCode(200);
    mock.setHeader(STA_UtilsStatic.ACCEPT, STA_UtilsStatic.APPLICATION_JSON);

    // Set the mock callout mode
    Test.setMock(HttpCalloutMock.class, mock);

    Test.startTest();
    String result = SMC_AC_Follow_Customer.initialisation(
      System.Label.SMC_Statistics,
      account
    );
    Test.stopTest();

    System.assertNotEquals(
      null,
      result,
      'Mock is wrong. Check it and relaunch test.'
    );
  }
  /**
   * @description : test SMC_AC_Follow_Customer.initialisation(Statistics)
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  @isTest
  public static void testGetStatisticBAD() {

    Account account = [SELECT Id, AccountNumber, SMC_ERPID_PCS__c, SMC_Account_Subsidiaries__c, SMC_TECH_Sales_Office__c, SMC_TECH_Suffix_Smartconf__c FROM Account WHERE AccountNumber = 'ACC-{000001}' LIMIT 1];

    StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
    // mock.setStaticResource(null);
    mock.setStatusCode(500);
    mock.setHeader(STA_UtilsStatic.ACCEPT, STA_UtilsStatic.APPLICATION_JSON);

    // Set the mock callout mode
    Test.setMock(HttpCalloutMock.class, mock);

    Test.startTest();
    String result = SMC_AC_Follow_Customer.initialisation(
      System.Label.SMC_Statistics,
      account
    );
    Test.stopTest();

    SMC_AC_Follow_Customer.WrapperCustomerInformations resultDeserialized = (SMC_AC_Follow_Customer.WrapperCustomerInformations) JSON.deserialize(
      result,
      (SMC_AC_Follow_Customer.WrapperCustomerInformations.class)
    );

    System.assertEquals(
      0,
      resultDeserialized.datas.size(),
      'Mock is wrong. Check it and relaunch test.'
    );
  }

  /**
   * @description : test SMC_AC_Follow_Customer.initialisation(FamilyDiscount)
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  @isTest
  public static void testGetDiscount() {

    Account account = [SELECT Id, AccountNumber, SMC_ERPID_PCS__c, SMC_Account_Subsidiaries__c, SMC_TECH_Sales_Office__c, SMC_TECH_Suffix_Smartconf__c FROM Account WHERE AccountNumber = 'ACC-{000001}' LIMIT 1];

    StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
    mock.setStaticResource(
      STA_UtilsStatic.MOCK_FOLLOW_CUSTOMER_FAMILY_DISCOUNT
    );
    mock.setStatusCode(200);
    mock.setHeader(STA_UtilsStatic.ACCEPT, STA_UtilsStatic.APPLICATION_JSON);

    // Set the mock callout mode
    Test.setMock(HttpCalloutMock.class, mock);

    Test.startTest();
    String result = SMC_AC_Follow_Customer.initialisation(
      System.Label.SMC_Discount_Per_Family,
      account
    );
    Test.stopTest();

    System.assertNotEquals(
      null,
      result,
      'Mock is wrong. Check it and relaunch test.'
    );
  }

  // /**
  //  * @description : test SMC_AC_Follow_Customer.initialisation(FamilyDiscount)
  //  * @author Vincent RECASENS (Modis) | 07-10-2020
  //  **/
  // @isTest
  // public static void testGetFamilyDiscountBAD() {
  //   Id recordTypeIdAccount = [
  //     SELECT Id
  //     FROM RecordType
  //     WHERE name = :STA_UtilsStatic.RECORDTYPE_ACCOUNT_CUSTOMER
  //   ]
  //   .Id;
  //   Account account = SMC_UTIL_TestUtils.createAccount(
  //     recordTypeIdAccount,
  //     STA_UtilsStatic.TEST + STA_UtilsStatic.ACCOUNT,
  //     STA_UtilsStatic.PICKLIST_ACCOUNT_TYPE_MARKETING_PROSPECT,
  //     STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY1
  //   );
  //   account.AccountNumber = 'ACC-{000001}';
  //   insert account;

  //   StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
  //   // mock.setStaticResource(
  //   //   STA_UtilsStatic.MOCK_FOLLOW_CUSTOMER_FAMILY_DISCOUNT
  //   // );
  //   mock.setStatusCode(500);
  //   mock.setHeader(STA_UtilsStatic.ACCEPT, STA_UtilsStatic.APPLICATION_JSON);

  //   // Set the mock callout mode
  //   Test.setMock(HttpCalloutMock.class, mock);

  //   Test.startTest();
  //   String result = SMC_AC_Follow_Customer.initialisation(
  //     System.Label.SMC_Discount_Per_Family,
  //     account
  //   );
  //   Test.stopTest();

  //   SMC_AC_Follow_Customer.WrapperCustomerInformations resultDeserialized = (SMC_AC_Follow_Customer.WrapperCustomerInformations) JSON.deserialize(
  //     result,
  //     (SMC_AC_Follow_Customer.WrapperCustomerInformations.class)
  //   );

  //   System.assertEquals(
  //     0,
  //     resultDeserialized.datas.size(),
  //     'Mock is wrong. Check it and relaunch test.'
  //   );
  // }

  /**
   * @description : test SMC_AC_Follow_Customer.initialisation(PriceList)
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  @isTest
  public static void testGetNetPrice() {

    Account account = [SELECT Id, AccountNumber, SMC_ERPID_PCS__c, SMC_Account_Subsidiaries__c, SMC_TECH_Sales_Office__c, SMC_TECH_Suffix_Smartconf__c FROM Account WHERE AccountNumber = 'ACC-{000001}' LIMIT 1];

    StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
    mock.setStaticResource(STA_UtilsStatic.MOCK_FOLLOW_CUSTOMER_PRICE_LIST);
    mock.setStatusCode(200);
    mock.setHeader(STA_UtilsStatic.ACCEPT, STA_UtilsStatic.APPLICATION_JSON);

    // Set the mock callout mode
    Test.setMock(HttpCalloutMock.class, mock);

    Test.startTest();
    String result = SMC_AC_Follow_Customer.initialisation(
      System.Label.SMC_Price_List,
      account
    );
    Test.stopTest();

    System.assertNotEquals(
      null,
      result,
      'Mock is wrong. Check it and relaunch test.'
    );
  }

  // /**
  //  * @description : test SMC_AC_Follow_Customer.initialisation(PriceList)
  //  * @author Vincent RECASENS (Modis) | 07-10-2020
  //  **/
  // @isTest
  // public static void testGetPriceListBAD() {
  //   Id recordTypeIdAccount = [
  //     SELECT Id
  //     FROM RecordType
  //     WHERE name = :STA_UtilsStatic.RECORDTYPE_ACCOUNT_CUSTOMER
  //   ]
  //   .Id;
  //   Account account = SMC_UTIL_TestUtils.createAccount(
  //     recordTypeIdAccount,
  //     STA_UtilsStatic.TEST + STA_UtilsStatic.ACCOUNT,
  //     STA_UtilsStatic.PICKLIST_ACCOUNT_TYPE_MARKETING_PROSPECT,
  //     STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY1
  //   );
  //   account.AccountNumber = 'ACC-{000001}';
  //   insert account;
  //   StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
  //   // mock.setStaticResource(STA_UtilsStatic.MOCK_FOLLOW_CUSTOMER_PRICE_LIST);
  //   mock.setStatusCode(500);
  //   mock.setHeader(STA_UtilsStatic.ACCEPT, STA_UtilsStatic.APPLICATION_JSON);

  //   // Set the mock callout mode
  //   Test.setMock(HttpCalloutMock.class, mock);

  //   Test.startTest();
  //   String result = SMC_AC_Follow_Customer.initialisation(
  //     System.Label.SMC_Price_List,
  //     account
  //   );
  //   Test.stopTest();

  //   SMC_AC_Follow_Customer.WrapperCustomerInformations resultDeserialized = (SMC_AC_Follow_Customer.WrapperCustomerInformations) JSON.deserialize(
  //     result,
  //     (SMC_AC_Follow_Customer.WrapperCustomerInformations.class)
  //   );

  //   System.assertEquals(
  //     0,
  //     resultDeserialized.datas.size(),
  //     'Mock is wrong. Check it and relaunch test.'
  //   );
  // }

  /**
   * @description : test SMC_AC_Follow_Customer.initialisation(DiscountPerItem)
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  @isTest
  public static void testGetDiscountPerItem() {

    Account account = [SELECT Id, AccountNumber, SMC_ERPID_PCS__c, SMC_Account_Subsidiaries__c, SMC_TECH_Sales_Office__c, SMC_TECH_Suffix_Smartconf__c FROM Account WHERE AccountNumber = 'ACC-{000001}' LIMIT 1];

    StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
    mock.setStaticResource(
      STA_UtilsStatic.MOCK_FOLLOW_CUSTOMER_FAMILY_DISCOUNT
    );
    mock.setStatusCode(200);
    mock.setHeader(STA_UtilsStatic.ACCEPT, STA_UtilsStatic.APPLICATION_JSON);

    // Set the mock callout mode
    Test.setMock(HttpCalloutMock.class, mock);

    Test.startTest();
    String result = SMC_AC_Follow_Customer.initialisation(
      System.Label.SMC_Discount_Per_Item,
      account
    );
    Test.stopTest();

    System.assertNotEquals(
      null,
      result,
      'Mock is wrong. Check it and relaunch test.'
    );
  }

  /**
   * @description : test SMC_AC_Follow_Customer.initialisation(NewDiscount)
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  @isTest
  public static void testGetNewDiscount() {

    Account account = [SELECT Id, AccountNumber, SMC_ERPID_PCS__c, SMC_Account_Subsidiaries__c, SMC_TECH_Sales_Office__c, SMC_TECH_Suffix_Smartconf__c FROM Account WHERE AccountNumber = 'ACC-{000001}' LIMIT 1];

    StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
    mock.setStaticResource(
      STA_UtilsStatic.MOCK_FOLLOW_CUSTOMER_FAMILY_DISCOUNT
    );
    mock.setStatusCode(200);
    mock.setHeader(STA_UtilsStatic.ACCEPT, STA_UtilsStatic.APPLICATION_JSON);

    // Set the mock callout mode
    Test.setMock(HttpCalloutMock.class, mock);

    Test.startTest();
    String result = SMC_AC_Follow_Customer.initialisation(
      'Discount_New',
      account
    );
    Test.stopTest();

    System.assertNotEquals(
      null,
      result,
      'Mock is wrong. Check it and relaunch test.'
    );
  }

  /**
   * @description : test SMC_AC_Follow_Customer.initialisation(NewPriceList)
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  @isTest
  public static void testGetNewPriceList() {

    Account account = [SELECT Id, AccountNumber, SMC_ERPID_PCS__c, SMC_Account_Subsidiaries__c, SMC_TECH_Sales_Office__c, SMC_TECH_Suffix_Smartconf__c FROM Account WHERE AccountNumber = 'ACC-{000001}' LIMIT 1];

    StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
    mock.setStaticResource(
      STA_UtilsStatic.MOCK_FOLLOW_CUSTOMER_FAMILY_DISCOUNT
    );
    mock.setStatusCode(200);
    mock.setHeader(STA_UtilsStatic.ACCEPT, STA_UtilsStatic.APPLICATION_JSON);

    // Set the mock callout mode
    Test.setMock(HttpCalloutMock.class, mock);

    Test.startTest();
    String result = SMC_AC_Follow_Customer.initialisation(
      'Price_List_New',
      account
    );
    Test.stopTest();

    System.assertNotEquals(
      null,
      result,
      'Mock is wrong. Check it and relaunch test.'
    );
  }
  
  /**
   * @description : test SMC_AC_Follow_Customer.initalisation(DiscountPerProductLine)
   * @author Denis PHAM (Modis) | 13-04-2022
   **/
  @isTest
  public static void testGetDiscountPerProductLine() {
    
    Account account = [SELECT Id, AccountNumber, SMC_ERPID_PCS__c, SMC_Account_Subsidiaries__c, SMC_TECH_Sales_Office__c, SMC_TECH_Suffix_Smartconf__c FROM Account WHERE AccountNumber = 'ACC-{000001}' LIMIT 1];

    StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
    mock.setStaticResource(
      STA_UtilsStatic.MOCK_FOLLOW_CUSTOMER_FAMILY_DISCOUNT
    );
    mock.setStatusCode(200);
    mock.setHeader(STA_UtilsStatic.ACCEPT, STA_UtilsStatic.APPLICATION_JSON);

    // Set the mock callout mode
    Test.setMock(HttpCalloutMock.class, mock);

    Test.startTest();
    String result = SMC_AC_Follow_Customer.initialisation(
      System.Label.SMC_Discount_Per_Product_Line,
      account
    );
    Test.stopTest();

    System.assertNotEquals(
      null,
      result,
      'Mock is wrong. Check it and relaunch test.'
    );
  }

  /**
  * @description : test get account method
  * @author Vincent RECASENS (Modis) | 09-03-2021 
  **/
  @isTest
  public static void testGetAccount(){
    
    Account account = [SELECT Id, AccountNumber, SMC_ERPID_PCS__c, SMC_Account_Subsidiaries__c, SMC_TECH_Sales_Office__c, SMC_TECH_Suffix_Smartconf__c FROM Account WHERE AccountNumber = 'ACC-{000001}' LIMIT 1];

    Test.startTest();
      Account checkAccount = SMC_AC_Follow_Customer.getAccount(account.Id);
    Test.stopTest();

    System.assertEquals(
      account.Id,
      checkAccount.Id,
      'Mock is wrong. Check it and relaunch test.'
    );
  }

  /**
  * @description : test get account method
  * @author Vincent RECASENS (Modis) | 09-03-2021 
  **/
  @isTest
  public static void testGetBusinessPlan(){
 
    Account account = [SELECT Id, AccountNumber, SMC_ERPID_PCS__c, SMC_Account_Subsidiaries__c, SMC_TECH_Sales_Office__c, SMC_TECH_Suffix_Smartconf__c FROM Account WHERE AccountNumber = 'ACC-{000001}' LIMIT 1];

    // SMC_Business_Plan__c bp = SMC_UTIL_TestUtils.createBusinessPlan('TEST BP', account.Id);
    SMC_Business_Plan__c bp = new SMC_Business_Plan__c();
    bp.Name = 'TEST BP';
    bp.SMC_Account__c = account.Id;
    insert bp;

    Test.startTest();
      Account checkAccount = SMC_AC_Follow_Customer.getBusinessPlan(bp.Id);
    Test.stopTest();

    System.assertEquals(
      account.Id,
      checkAccount.Id,
      'Mock is wrong. Check it and relaunch test.'
    );
  }

  /**
  * @description : tesst removeCurrencyElmt
  * @author Vincent RECASENS (Modis) | 09-03-2021 
  **/
  @isTest
  public static void testRemoveCcy(){
    System.assertEquals('{"test":test}', SMC_AC_Follow_Customer.removeCurrencyElmt('{"currency":10,"test":test}'));
  }

  /**
   * @description : : test all dto for SMC_AC_Follow_Customer
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  @isTest
  public static void testDto() {
    SMC_AC_Follow_Customer.Column constructorColumn = new SMC_AC_Follow_Customer.Column();
    SMC_AC_Follow_Customer.Data dto = new SMC_AC_Follow_Customer.Data();
    dto.customer = 'a string';
    dto.effectiveDate = 'a string';
    dto.priceGroup = 'a string';
    dto.crm_account_code = 'a string';
    dto.scoring_family_l2_code = 'a string';
    dto.scoring_family_l2_descr_en = 'a string';
    dto.scoring_family_l1_descr_en = 'a string';
    dto.item = 'a string';
    dto.discount = 1.1;
    dto.to_n_2 = 1.1;
    dto.to_n_1 = 1.1;
    dto.to_n = 1.1;
    dto.target = 1.1;
    dto.projected = 1.1;
    dto.target_vs_projected = 1.1;
    dto.projected_vs_ton1 = 1.1;
    dto.ccy = 'a string';
    dto.priceBook = 'a string';
    dto.matrixType = 'a string';
    dto.matrixLevel = 'a string';
    dto.matrixDefinition = 'a string';
    dto.sequence = 'a string';
    dto.discountPercent = 1.1;
    dto.productLine = 'a string';
    dto.soldToBp = 'a string';
    dto.salesOrderType = 'a string';
    dto.salesOffice = 'a string';
    dto.priceList = 'a string';
    dto.buyFromBp = 'a string';
    dto.shipFromBp = 'a string';
    dto.quantityUnit = 'a string';
    dto.priceType = 'a string';
    dto.breakQuantity = 'a string';
    dto.price = 'a string';
    // dto.priceGroupDescriptionEn = 'a string';
    // dto.priceGroupDescriptionFr = 'a string';
    // dto.description = 'a string';
    // dto.expirationDate = 'a string';
    // dto.netPrice = 1.1;
    // dto.quantity = 100;
    // dto.previousDiscount = 1.1;
    System.assert(true, 'Error');
  }
}