/*
---------------------------------------------------------------------------
-- - Name : SMC_AC_Page_CreateCase
-- - Author : Vincent RECASENS
-- - Description : This class is the Apex test of the Apex 
                   class SMC_AC_Page_CreateCase
--
-- Maintenance History:
--
-- Date 			Name 	Version 	Remarks
-- ----------- 		---- 	------- 	------------------
-- 06-SEP-2019 		VRE		1.0			Initial Version
---------------------------------------------------------------------------
*/

@IsTest
public without sharing class TEST_SMC_AC_Page_CreateCase {
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

    List<User> lUser = new List<User>();
    User user = SMC_UTIL_TestUtils.createUser(
      STA_UtilsStatic.TEST_DIESE,
      STA_UtilsStatic.EMAIL_TEST,
      profile.Id,
      STA_UtilsStatic.USERNAME_TEST,
      STA_UtilsStatic.USER_NICKNAME
    );
    lUser.add(user);

    User userWithoutPS = SMC_UTIL_TestUtils.createUser(
      'user2-' + STA_UtilsStatic.TEST_DIESE,
      'user2-' + STA_UtilsStatic.EMAIL_TEST,
      profile.Id,
      'user2-' + STA_UtilsStatic.USERNAME_TEST,
      'user2-' + STA_UtilsStatic.USER_NICKNAME
    );
    lUser.add(userWithoutPS);

    insert lUser;

    //DPHA - Add Permission set 
    List<PermissionSet> ps = [SELECT Id FROM PermissionSet WHERE Name = :STA_UtilsStatic.CREATE_SOA_CASE_PERMISSION OR Name = :STA_UtilsStatic.SUPPLIER_QUALITY_CLAIM_CASE_ACCESS_PERMISSION];
    List<PermissionSetAssignment> lpsa = new List<PermissionSetAssignment>();
    for(PermissionSet p : ps){
      PermissionSetAssignment psa = new PermissionSetAssignment();
      psa.AssigneeId = user.Id;
      psa.PermissionSetId = p.Id;
      lpsa.add(psa);
    }

    insert lpsa;

    System.runAs(user){
      //Account
      Id accRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
      .get(STA_UtilsStatic.RECORDTYPE_ACCOUNT_CUSTOMER_DEVNAME)
      .getRecordTypeId();

      Account acc = SMC_UTIL_TestUtils.createAccount(
          accRecordTypeId,
          STA_UtilsStatic.TEST + '_Standard',
          STA_UtilsStatic.PICKLIST_ACCOUNT_TYPE_MARKETING_PROSPECT,
          STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY2
      );
      insert acc;

      //Opportunity
      Id oppRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByDeveloperName()
      .get(STA_UtilsStatic.RECORDTYPE_OPPORTUNITY_PROJECT)
      .getRecordTypeId();
    
      Opportunity opp = SMC_UTIL_TestUtils.createOpportunity(
          oppRecordTypeId,
          STA_UtilsStatic.TEST,
          STA_UtilsStatic.OPPORTUNITY_PROJECT_DETECTED
      );
      insert opp;

      //Quote
      Id quoteRecordType = Schema.SObjectType.Quote.getRecordTypeInfosByDeveloperName()
      .get(STA_UtilsStatic.RECORDTYPE_QUOTE_PROJECT)
      .getRecordTypeId();

      Quote quote = SMC_UTIL_TestUtils.createQuote(
          opp.Id,
          STA_UtilsStatic.QUOTE_NAME1,
          acc.Id
      );
      quote.RecordTypeId = quoteRecordType;
      insert quote;

      //Contact 
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
          acc.Id
      );
      insert contact;
    }
  }

  @isTest
  public static void testSetKindCaseList() {
    User user = [SELECT Id FROM User WHERE Email = :STA_UtilsStatic.EMAIL_TEST];
    System.runAs(user) {
      Test.startTest();
      List<SMC_AC_Page_CreateCase.GetKindCase> listGetKindCase = SMC_AC_Page_CreateCase.setKindCaseList();
      Test.stopTest();
      System.assertNotEquals(
        null,
        listGetKindCase,
        'Check the method and the metadata "SMC_Case_RecordType__mdt".'
      );
      System.assertNotEquals(
        0,
        listGetKindCase.size(),
        'Check the method and the metadata "SMC_Case_RecordType__mdt".'
      );
    }
  }

  /**
   * @description : test SMC_AC_Page_CreateCase.setCaseTypeList(Sales)
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  @isTest
  public static void testSetCaseTypeList() {
    User user = [SELECT Id FROM User WHERE Email = :STA_UtilsStatic.EMAIL_TEST];
    System.runAs(user) {
      String kindCase = SMC_AC_Page_CreateCase.SALES;

      Test.startTest();
      String result =  SMC_AC_Page_CreateCase.setCaseTypeList(kindCase, null, null);
      Test.stopTest();

      SMC_AC_Page_CreateCase.AllInfoToCreateCaseFromAnotherObject dtoResult = (SMC_AC_Page_CreateCase.AllInfoToCreateCaseFromAnotherObject) JSON.deserialize(
        result,
        SMC_AC_Page_CreateCase.AllInfoToCreateCaseFromAnotherObject.class
      );
      Map<Id, RecordType> mapRecordType = new Map<Id, RecordType>(
        [
          SELECT Id, Name, DeveloperName
          FROM RecordType
          WHERE
            SObjectType = :STA_UtilsStatic.SOBJECT_CASE
          AND DeveloperName = :SMC_AC_Page_CreateCase.RECORDTYPE_MAP.get(kindCase)
        ]
      );
      for (
        SMC_AC_Page_CreateCase.AssociateCaseTypeToImg oneResult : dtoResult.listActi
      ) {
        System.assertNotEquals(
          null,
          mapRecordType.get(oneResult.caseTypeId),
          'The record type [Id:' +
          oneResult.caseTypeId +
          '] does not exist.'
        );
        System.assertEquals(
          STA_UtilsStatic.SMC_PREFIX_CASE_RECORDTYPE_SALES_NAME +
          ' ' +
          oneResult.caseTypeName,
          mapRecordType.get(oneResult.caseTypeId).Name,
          'The record type name does match with the manual build.'
        );
        System.assertNotEquals(
          null,
          oneResult.caseTypeImg,
          'The type has no picture linked.'
        );
      }
    }
  }

  /**
   * @description : test SMC_AC_Page_CreateCase.setCaseTypeList(SocomecApplicationSupport)
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  @isTest
  public static void testSetCaseTypeListFor_SocomecApplicationSupport() {
    User user = [SELECT Id FROM User WHERE Email = :STA_UtilsStatic.EMAIL_TEST];
    System.runAs(user) {
      String kindCase = SMC_AC_Page_CreateCase.SOCOMEC_APPLICATION_SUPPORT;

      Test.startTest();
      String result = SMC_AC_Page_CreateCase.setCaseTypeList(kindCase, null, null);
      Test.stopTest();

      SMC_AC_Page_CreateCase.AllInfoToCreateCaseFromAnotherObject dtoResult = (SMC_AC_Page_CreateCase.AllInfoToCreateCaseFromAnotherObject) JSON.deserialize(
        result,
        SMC_AC_Page_CreateCase.AllInfoToCreateCaseFromAnotherObject.class
      );
      Map<Id, RecordType> mapRecordType = new Map<Id, RecordType>(
        [
          SELECT Id, Name, DeveloperName
          FROM RecordType
          WHERE
            SObjectType = :STA_UtilsStatic.SOBJECT_CASE
          AND DeveloperName = :STA_UtilsStatic.RECORDTYPE_INTERNAL_SOCOMEC_APPLICATION_SUPPORT
        ]
      );

      for (
        SMC_AC_Page_CreateCase.AssociateCaseTypeToImg oneResult : dtoResult.listActi
      ) {
        System.assertNotEquals(
          null,
          mapRecordType.get(oneResult.caseTypeId),
          'The record type [Id:' +
          oneResult.caseTypeId +
          '] does not exist.'
        );
        System.assertEquals(
          null,
          oneResult.caseTypeName,
          'The record type name does match with the manual build.'
        );
        System.assertEquals(
          null,
          oneResult.caseTypeImg,
          'The type has a picture linked.'
        );
      }
    }
  }

  /**
   * @description : test SMC_AC_Page_CreateCase.setCaseTypeList(Marketing)
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  @isTest
  public static void testSetCaseTypeListFor_Marketing() {
    User user = [SELECT Id FROM User WHERE Email = :STA_UtilsStatic.EMAIL_TEST];
    System.runAs(user) {
      String kindCase = SMC_AC_Page_CreateCase.MARKETING;

      Test.startTest();
      String result = SMC_AC_Page_CreateCase.setCaseTypeList(kindCase, null, null);
      Test.stopTest();

      SMC_AC_Page_CreateCase.AllInfoToCreateCaseFromAnotherObject dtoResult = (SMC_AC_Page_CreateCase.AllInfoToCreateCaseFromAnotherObject) JSON.deserialize(
        result,
        SMC_AC_Page_CreateCase.AllInfoToCreateCaseFromAnotherObject.class
      );
      Map<Id, RecordType> mapRecordType = new Map<Id, RecordType>(
        [
          SELECT Id, Name, DeveloperName
          FROM RecordType
          WHERE
            SObjectType = :STA_UtilsStatic.SOBJECT_CASE
          AND DeveloperName LIKE :STA_UtilsStatic.RECORDTYPE_MARKETING_LIKE
        ]
      );
      System.debug('mapRecordType : ' + mapRecordType); 

      for (
        SMC_AC_Page_CreateCase.AssociateCaseTypeToImg oneResult : dtoResult.listActi
      ) {
        System.debug('oneResult : ' + oneResult); 
        System.debug('mapRecordType.get(oneResult.caseTypeId) : ' + mapRecordType.get(oneResult.caseTypeId)); 
        System.assertNotEquals(
          null,
          mapRecordType.get(oneResult.caseTypeId),
          'The record type [Id:' +
          oneResult.caseTypeId +
          '] does not exist.'
        );
        System.assertNotEquals(
          null,
          oneResult.caseTypeImg,
          'The type has a picture linked.'
        );
        if(mapRecordType.get(oneResult.caseTypeId).DeveloperName == STA_UtilsStatic.RECORDTYPE_MARKETING_CATALOGUE){
          System.assertEquals(
            STA_UtilsStatic.RECORDTYPE_MARKETING_CATALOGUE_LABEL,
            oneResult.caseTypeName,
            'The record type name does match with the manual build.'
          );
        }
        else{
          System.assertEquals(
            mapRecordType.get(oneResult.caseTypeId).Name.removeStart(STA_UtilsStatic.SMC_PREFIX_CASE_MARKETING_RECORDTYPE_NAME),
            oneResult.caseTypeName,
            'The record type name does match with the manual build.'
          );
        }
      }
    }
  }

  /**
   * @description : test SMC_AC_Page_CreateCase.initVariables(Sales)
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  @isTest
  public static void testInitVariables() {
    User user = [SELECT Id FROM User WHERE Email = :STA_UtilsStatic.EMAIL_TEST];
    System.runAs(user) {
      //Test Sales
      String kindCase_Sales = SMC_AC_Page_CreateCase.SALES;
      Map<String, String> IMG_PATH_CASE_TYPE_LIST_SALES;
      SMC_AC_Page_CreateCase.PredefinedFieldsValues  pfv = new SMC_AC_Page_CreateCase.PredefinedFieldsValues(kindCase_Sales);
      
      Test.startTest();
      SMC_AC_Page_CreateCase.initVariables(kindCase_Sales, pfv);
      Test.stopTest();

      IMG_PATH_CASE_TYPE_LIST_SALES = SMC_AC_Page_CreateCase.IMG_PATH_CASE_TYPE_LIST;
      System.assertNotEquals(
        0,
        SMC_AC_Page_CreateCase.IMG_PATH_CASE_TYPE_LIST.size(),
        'Initialisation broken.'
      );
    }
  }

  /**
   * @description : test SMC_AC_Page_CreateCase.PredefinedFieldsValues()
   * @author Denis PHAM (Modis) | 14-04-2022
   **/
  @isTest
  public static void testPredefinedValue() {
    User user = [SELECT Id FROM User WHERE Email = :STA_UtilsStatic.EMAIL_TEST];
    System.runAs(user) {

      Test.startTest();
      SMC_AC_Page_CreateCase.PredefinedFieldsValues  pfv = new SMC_AC_Page_CreateCase.PredefinedFieldsValues();
      Test.stopTest();

      System.assertEquals(user.id, pfv.internalUserId);
    }
  }

  /**
   * @description : test SMC_AC_Page_CreateCase.PredefinedFieldsValues(KindCase)
   * @author Denis PHAM (Modis) | 14-04-2022
   **/
  @isTest
  public static void testPredefinedValueWithParam() {
    User user = [SELECT Id FROM User WHERE Email = :STA_UtilsStatic.EMAIL_TEST];
    System.runAs(user) {

      Test.startTest();
      //Sales 
      String kindCaseSales = STA_UtilsStatic.KIND_SALES;
      SMC_AC_Page_CreateCase.PredefinedFieldsValues  pfv = new SMC_AC_Page_CreateCase.PredefinedFieldsValues(kindCaseSales);

      //After Sales BA Service 
      String kindCaseAfterSalesBaService = STA_UtilsStatic.KIND_AFTERSALES_BASERVICE;
      SMC_AC_Page_CreateCase.PredefinedFieldsValues  pfvBaService = new SMC_AC_Page_CreateCase.PredefinedFieldsValues(kindCaseAfterSalesBaService);

      //SOA
      String kindCaseSOA = STA_UtilsStatic.KIND_SOA;
      SMC_AC_Page_CreateCase.PredefinedFieldsValues  pfvSOA = new SMC_AC_Page_CreateCase.PredefinedFieldsValues(kindCaseSOA);
      Test.stopTest();

      System.assertEquals(true, pfv.doNotShowInactiveProduct);
      System.assertEquals(true, pfv.doNotShowServiceProduct);
      System.assertEquals(false, pfvBaService.doNotShowServiceProduct);
      System.assertEquals(true, pfvSOA.isCreateFromHypercare);

    }
  }

  /**
   * @description : test SMC_AC_Page_CreateCase.getCaseListView()
   * @author Denis PHAM (Modis) | 14-04-2022
   **/
  @isTest
  public static void testGetCaseListView() {
    User user = [SELECT Id FROM User WHERE Email = :STA_UtilsStatic.EMAIL_TEST];
    System.runAs(user) {

      Test.startTest();
      ListView  lv = SMC_AC_Page_CreateCase.getCaseListView();
      Test.stopTest();

      System.assertNotEquals(null, lv);
    }
  }

  /**
   * @description : test SMC_AC_Page_CreateCase.setKindCaseList() without the authorization to see SOA
   * @author Denis PHAM (Modis) | 14-04-2022
   **/
  @isTest
  public static void testSetKindCaseListNotSOA() {
    String emailUser = 'user2-' + STA_UtilsStatic.EMAIL_TEST;
    User user = [SELECT Id FROM User WHERE Email = :emailUser];
    System.runAs(user) {

      Test.startTest();
      List<SMC_AC_Page_CreateCase.GetKindCase> listGetKindCase = SMC_AC_Page_CreateCase.setKindCaseList();
      Test.stopTest();

      System.assertNotEquals(
        null,
        listGetKindCase,
        'Check the method and the metadata "SMC_Case_RecordType__mdt".'
      );
      System.assertNotEquals(
        0,
        listGetKindCase.size(),
        'Check the method and the metadata "SMC_Case_RecordType__mdt".'
      );
    }
  }

  /**
   * @description : test SMC_AC_Page_CreateCase.setCaseTypeList(SOA)
   * @author Denis PHAM (Modis) | 14-04-2022
   **/
  @isTest
  public static void testSetCaseTypeListFor_SOA() {
    User user = [SELECT Id FROM User WHERE Email = :STA_UtilsStatic.EMAIL_TEST];
    System.runAs(user) {
      String kindCase = SMC_AC_Page_CreateCase.SOA;

      Test.startTest();
      String result = SMC_AC_Page_CreateCase.setCaseTypeList(kindCase, null, null);
      Test.stopTest();

      SMC_AC_Page_CreateCase.AllInfoToCreateCaseFromAnotherObject dtoResult = (SMC_AC_Page_CreateCase.AllInfoToCreateCaseFromAnotherObject) JSON.deserialize(
        result,
        SMC_AC_Page_CreateCase.AllInfoToCreateCaseFromAnotherObject.class
      );
      Map<Id, RecordType> mapRecordType = new Map<Id, RecordType>(
        [
          SELECT Id, Name, DeveloperName
          FROM RecordType
          WHERE
            SObjectType = :STA_UtilsStatic.SOBJECT_CASE
            AND DeveloperName = :STA_UtilsStatic.RECORDTYPE_SOA_HYPERCARE_CASE
        ]
      );

      for (
        SMC_AC_Page_CreateCase.AssociateCaseTypeToImg oneResult : dtoResult.listActi
      ) {
        System.assertNotEquals(
          null,
          mapRecordType.get(oneResult.caseTypeId),
          'The record type [Id:' +
          oneResult.caseTypeId +
          '] does not exist.'
        );
        System.assertEquals(
          null,
          oneResult.caseTypeName,
          'The record type name does match with the manual build.'
        );
        System.assertEquals(
          null,
          oneResult.caseTypeImg,
          'The type has not a picture linked.'
        );
      }
    }
  }

  /**
   * @description : test SMC_AC_Page_CreateCase.setCaseTypeList(AfterSalesBaService)
   * @author Denis PHAM (Modis) | 14-04-2022
   **/
  @isTest
  public static void testSetCaseTypeListFor_AfterSalesBaService() {
    User user = [SELECT Id FROM User WHERE Email = :STA_UtilsStatic.EMAIL_TEST];
    System.runAs(user) {
      String kindCase = SMC_AC_Page_CreateCase.AFTER_SALES_BASERVICE;

      Test.startTest();
      String result = SMC_AC_Page_CreateCase.setCaseTypeList(kindCase, null, null);
      Test.stopTest();

      SMC_AC_Page_CreateCase.AllInfoToCreateCaseFromAnotherObject dtoResult = (SMC_AC_Page_CreateCase.AllInfoToCreateCaseFromAnotherObject) JSON.deserialize(
        result,
        SMC_AC_Page_CreateCase.AllInfoToCreateCaseFromAnotherObject.class
      );
      Map<Id, RecordType> mapRecordType = new Map<Id, RecordType>(
        [
          SELECT Id, Name, DeveloperName
          FROM RecordType
          WHERE
            SObjectType = :STA_UtilsStatic.SOBJECT_CASE
          AND DeveloperName LIKE :STA_UtilsStatic.SMC_PREFIX_CASE_RECORDTYPE_INTERNAL + '%'
        ]
      );

      for (
        SMC_AC_Page_CreateCase.AssociateCaseTypeToImg oneResult : dtoResult.listActi
      ) {
        System.assertNotEquals(
          null,
          mapRecordType.get(oneResult.caseTypeId),
          'The record type [Id:' +
          oneResult.caseTypeId +
          '] does not exist.'
        );
        System.assertNotEquals(
          null,
          oneResult.caseTypeName,
          'The record type name does match with the manual build.'
        );
        System.assertNotEquals(
          null,
          oneResult.caseTypeImg,
          'The type has not a picture linked.'
        );
      }
    }
  }

  /**
   * @description : test SMC_AC_Page_CreateCase.setCaseTypeList(AfterSalesLocalCenter)
   * @author Denis PHAM (Modis) | 14-04-2022
   **/
  @isTest
  public static void testSetCaseTypeListFor_AfterSalesLocalCenter() {
    User user = [SELECT Id FROM User WHERE Email = :STA_UtilsStatic.EMAIL_TEST];
    System.runAs(user) {
      String kindCase = SMC_AC_Page_CreateCase.AFTER_SALES_LOCAL_CALL_CENTER;

      Test.startTest();
      String result = SMC_AC_Page_CreateCase.setCaseTypeList(kindCase, null, null);
      Test.stopTest();

      SMC_AC_Page_CreateCase.AllInfoToCreateCaseFromAnotherObject dtoResult = (SMC_AC_Page_CreateCase.AllInfoToCreateCaseFromAnotherObject) JSON.deserialize(
        result,
        SMC_AC_Page_CreateCase.AllInfoToCreateCaseFromAnotherObject.class
      );
      Map<Id, RecordType> mapRecordType = new Map<Id, RecordType>(
        [
          SELECT Id, Name, DeveloperName
          FROM RecordType
          WHERE
            SObjectType = :STA_UtilsStatic.SOBJECT_CASE
            AND (DeveloperName LIKE :STA_UtilsStatic.SMC_PREFIX_CASE_RECORDTYPE_CUSTOMER + '%'
            OR DeveloperName = :STA_UtilsStatic.RECORDTYPE_INTERNAL_LOCAL_TECHNICAL_HELP)
        ]
      );

      for (
        SMC_AC_Page_CreateCase.AssociateCaseTypeToImg oneResult : dtoResult.listActi
      ) {
        System.assertNotEquals(
          null,
          mapRecordType.get(oneResult.caseTypeId),
          'The record type [Id:' +
          oneResult.caseTypeId +
          '] does not exist.'
        );
        System.assertNotEquals(
          null,
          oneResult.caseTypeName,
          'The record type name does match with the manual build.'
        );
        System.assertNotEquals(
          null,
          oneResult.caseTypeImg,
          'The type has not a picture linked.'
        );
      }
    }
  }

  /**
   * @description : test SMC_AC_Page_CreateCase.setCaseTypeList(Sales) Opportunity
   * @author Denis PHAM (Modis) | 14-04-2022
   **/
  @isTest
  public static void testSetCaseTypeListOppSales() {
    User user = [SELECT Id FROM User WHERE Email = :STA_UtilsStatic.EMAIL_TEST];
    System.runAs(user) {
      String kindCase = SMC_AC_Page_CreateCase.SALES;
      Opportunity opp = [SELECT Id, AccountId from Opportunity LIMIT 1];

      Test.startTest();
      String result =  SMC_AC_Page_CreateCase.setCaseTypeList(kindCase, null, opp.Id);
      Test.stopTest();

      SMC_AC_Page_CreateCase.AllInfoToCreateCaseFromAnotherObject dtoResult = (SMC_AC_Page_CreateCase.AllInfoToCreateCaseFromAnotherObject) JSON.deserialize(
        result,
        SMC_AC_Page_CreateCase.AllInfoToCreateCaseFromAnotherObject.class
      );
      Map<Id, RecordType> mapRecordType = new Map<Id, RecordType>(
        [
          SELECT Id, Name, DeveloperName
          FROM RecordType
          WHERE
            SObjectType = :STA_UtilsStatic.SOBJECT_CASE
          AND DeveloperName = :SMC_AC_Page_CreateCase.RECORDTYPE_MAP.get(kindCase)
        ]
      );
      for (
        SMC_AC_Page_CreateCase.AssociateCaseTypeToImg oneResult : dtoResult.listActi
      ) {
        System.assertNotEquals(
          null,
          mapRecordType.get(oneResult.caseTypeId),
          'The record type [Id:' +
          oneResult.caseTypeId +
          '] does not exist.'
        );
        System.assertEquals(
          STA_UtilsStatic.SMC_PREFIX_CASE_RECORDTYPE_SALES_NAME +
          ' ' +
          oneResult.caseTypeName,
          mapRecordType.get(oneResult.caseTypeId).Name,
          'The record type name does match with the manual build.'
        );
        System.assertNotEquals(
          null,
          oneResult.caseTypeImg,
          'The type has no picture linked.'
        );
      }
    }
  }

   /**
   * @description : test SMC_AC_Page_CreateCase.setCaseTypeList(Sales) Quote
   * @author Denis PHAM (Modis) | 14-04-2022
   **/
  @isTest
  public static void testSetCaseTypeListQuoteSales() {
    User user = [SELECT Id FROM User WHERE Email = :STA_UtilsStatic.EMAIL_TEST];
    System.runAs(user) {
      String kindCase = SMC_AC_Page_CreateCase.SALES;
      Quote quote = [SELECT Id, OpportunityId, Opportunity.AccountId, Opportunity.SMC_Primary_Contact__c FROM Quote LIMIT 1];

      Test.startTest();
      String result =  SMC_AC_Page_CreateCase.setCaseTypeList(kindCase, null, quote.Id);
      Test.stopTest();

      SMC_AC_Page_CreateCase.AllInfoToCreateCaseFromAnotherObject dtoResult = (SMC_AC_Page_CreateCase.AllInfoToCreateCaseFromAnotherObject) JSON.deserialize(
        result,
        SMC_AC_Page_CreateCase.AllInfoToCreateCaseFromAnotherObject.class
      );
      Map<Id, RecordType> mapRecordType = new Map<Id, RecordType>(
        [
          SELECT Id, Name, DeveloperName
          FROM RecordType
          WHERE
            SObjectType = :STA_UtilsStatic.SOBJECT_CASE
          AND DeveloperName = :SMC_AC_Page_CreateCase.RECORDTYPE_MAP.get(kindCase)
        ]
      );
      for (
        SMC_AC_Page_CreateCase.AssociateCaseTypeToImg oneResult : dtoResult.listActi
      ) {
        System.assertNotEquals(
          null,
          mapRecordType.get(oneResult.caseTypeId),
          'The record type [Id:' +
          oneResult.caseTypeId +
          '] does not exist.'
        );
        System.assertEquals(
          STA_UtilsStatic.SMC_PREFIX_CASE_RECORDTYPE_SALES_NAME +
          ' ' +
          oneResult.caseTypeName,
          mapRecordType.get(oneResult.caseTypeId).Name,
          'The record type name does match with the manual build.'
        );
        System.assertNotEquals(
          null,
          oneResult.caseTypeImg,
          'The type has no picture linked.'
        );
      }
    }
  }

   /**
   * @description : test SMC_AC_Page_CreateCase.setCaseTypeList(Sales) Contact
   * @author Denis PHAM (Modis) | 14-04-2022
   **/
  @isTest
  public static void testSetCaseTypeListContactSales() {
    User user = [SELECT Id FROM User WHERE Email = :STA_UtilsStatic.EMAIL_TEST];
    System.runAs(user) {
      String kindCase = SMC_AC_Page_CreateCase.SALES;
      Contact contact = [SELECT Id, AccountId FROM Contact LIMIT 1];

      Test.startTest();
      String result =  SMC_AC_Page_CreateCase.setCaseTypeList(kindCase, null, contact.Id);
      Test.stopTest();

      SMC_AC_Page_CreateCase.AllInfoToCreateCaseFromAnotherObject dtoResult = (SMC_AC_Page_CreateCase.AllInfoToCreateCaseFromAnotherObject) JSON.deserialize(
        result,
        SMC_AC_Page_CreateCase.AllInfoToCreateCaseFromAnotherObject.class
      );
      Map<Id, RecordType> mapRecordType = new Map<Id, RecordType>(
        [
          SELECT Id, Name, DeveloperName
          FROM RecordType
          WHERE
            SObjectType = :STA_UtilsStatic.SOBJECT_CASE
          AND DeveloperName = :SMC_AC_Page_CreateCase.RECORDTYPE_MAP.get(kindCase)
        ]
      );
      for (
        SMC_AC_Page_CreateCase.AssociateCaseTypeToImg oneResult : dtoResult.listActi
      ) {
        System.assertNotEquals(
          null,
          mapRecordType.get(oneResult.caseTypeId),
          'The record type [Id:' +
          oneResult.caseTypeId +
          '] does not exist.'
        );
        System.assertEquals(
          STA_UtilsStatic.SMC_PREFIX_CASE_RECORDTYPE_SALES_NAME +
          ' ' +
          oneResult.caseTypeName,
          mapRecordType.get(oneResult.caseTypeId).Name,
          'The record type name does match with the manual build.'
        );
        System.assertNotEquals(
          null,
          oneResult.caseTypeImg,
          'The type has no picture linked.'
        );
      }
    }
  }

  /**
   * @description : test SMC_AC_Page_CreateCase.setCaseTypeList(AfterSalesLocalCenter) Quote
   * @author Denis PHAM (Modis) | 14-04-2022
   **/
  @isTest
  public static void testSetCaseTypeListFor_QuoteAfterSalesLocalCenter() {
    User user = [SELECT Id FROM User WHERE Email = :STA_UtilsStatic.EMAIL_TEST];
    System.runAs(user) {
      String kindCase = SMC_AC_Page_CreateCase.AFTER_SALES_LOCAL_CALL_CENTER;
      Quote quote = [SELECT Id, OpportunityId, Opportunity.AccountId, Opportunity.SMC_Primary_Contact__c FROM Quote LIMIT 1];

      Test.startTest();
      String result = SMC_AC_Page_CreateCase.setCaseTypeList(kindCase, null, quote.Id);
      Test.stopTest();

      SMC_AC_Page_CreateCase.AllInfoToCreateCaseFromAnotherObject dtoResult = (SMC_AC_Page_CreateCase.AllInfoToCreateCaseFromAnotherObject) JSON.deserialize(
        result,
        SMC_AC_Page_CreateCase.AllInfoToCreateCaseFromAnotherObject.class
      );
      Map<Id, RecordType> mapRecordType = new Map<Id, RecordType>(
        [
          SELECT Id, Name, DeveloperName
          FROM RecordType
          WHERE
            SObjectType = :STA_UtilsStatic.SOBJECT_CASE
            AND (DeveloperName LIKE :STA_UtilsStatic.SMC_PREFIX_CASE_RECORDTYPE_CUSTOMER + '%'
            OR DeveloperName = :STA_UtilsStatic.RECORDTYPE_INTERNAL_LOCAL_TECHNICAL_HELP)
        ]
      );

      for (
        SMC_AC_Page_CreateCase.AssociateCaseTypeToImg oneResult : dtoResult.listActi
      ) {
        System.assertNotEquals(
          null,
          mapRecordType.get(oneResult.caseTypeId),
          'The record type [Id:' +
          oneResult.caseTypeId +
          '] does not exist.'
        );
        System.assertNotEquals(
          null,
          oneResult.caseTypeName,
          'The record type name does match with the manual build.'
        );
        System.assertNotEquals(
          null,
          oneResult.caseTypeImg,
          'The type has not a picture linked.'
        );
      }
    }
  }

  /**
   * @description : test SMC_AC_Page_CreateCase.setCaseTypeList(AfterSalesLocalCenter) Contact
   * @author Denis PHAM (Modis) | 14-04-2022
   **/
  @isTest
  public static void testSetCaseTypeListFor_ContactAfterSalesLocalCenter() {
    User user = [SELECT Id FROM User WHERE Email = :STA_UtilsStatic.EMAIL_TEST];
    System.runAs(user) {
      String kindCase = SMC_AC_Page_CreateCase.AFTER_SALES_LOCAL_CALL_CENTER;
      Contact contact = [SELECT Id, AccountId FROM Contact LIMIT 1];

      Test.startTest();
      String result = SMC_AC_Page_CreateCase.setCaseTypeList(kindCase, null, contact.Id);
      Test.stopTest();

      SMC_AC_Page_CreateCase.AllInfoToCreateCaseFromAnotherObject dtoResult = (SMC_AC_Page_CreateCase.AllInfoToCreateCaseFromAnotherObject) JSON.deserialize(
        result,
        SMC_AC_Page_CreateCase.AllInfoToCreateCaseFromAnotherObject.class
      );
      Map<Id, RecordType> mapRecordType = new Map<Id, RecordType>(
        [
          SELECT Id, Name, DeveloperName
          FROM RecordType
          WHERE
            SObjectType = :STA_UtilsStatic.SOBJECT_CASE
            AND (DeveloperName LIKE :STA_UtilsStatic.SMC_PREFIX_CASE_RECORDTYPE_CUSTOMER + '%'
            OR DeveloperName = :STA_UtilsStatic.RECORDTYPE_INTERNAL_LOCAL_TECHNICAL_HELP)
        ]
      );

      for (
        SMC_AC_Page_CreateCase.AssociateCaseTypeToImg oneResult : dtoResult.listActi
      ) {
        System.assertNotEquals(
          null,
          mapRecordType.get(oneResult.caseTypeId),
          'The record type [Id:' +
          oneResult.caseTypeId +
          '] does not exist.'
        );
        System.assertNotEquals(
          null,
          oneResult.caseTypeName,
          'The record type name does match with the manual build.'
        );
        System.assertNotEquals(
          null,
          oneResult.caseTypeImg,
          'The type has not a picture linked.'
        );
      }
    }
  }

  /**
   * @description : test SMC_AC_Page_CreateCase.setCaseTypeList(AfterSalesBaService) Quote
   * @author Denis PHAM (Modis) | 14-04-2022
   **/
  @isTest
  public static void testSetCaseTypeListFor_QuoteAfterSalesBaService() {
    User user = [SELECT Id FROM User WHERE Email = :STA_UtilsStatic.EMAIL_TEST];
    System.runAs(user) {
      String kindCase = SMC_AC_Page_CreateCase.AFTER_SALES_BASERVICE;
      Quote quote = [SELECT Id, OpportunityId, Opportunity.AccountId, Opportunity.SMC_Primary_Contact__c FROM Quote LIMIT 1];

      Test.startTest();
      String result = SMC_AC_Page_CreateCase.setCaseTypeList(kindCase, null, quote.Id);
      Test.stopTest();

      SMC_AC_Page_CreateCase.AllInfoToCreateCaseFromAnotherObject dtoResult = (SMC_AC_Page_CreateCase.AllInfoToCreateCaseFromAnotherObject) JSON.deserialize(
        result,
        SMC_AC_Page_CreateCase.AllInfoToCreateCaseFromAnotherObject.class
      );
      Map<Id, RecordType> mapRecordType = new Map<Id, RecordType>(
        [
          SELECT Id, Name, DeveloperName
          FROM RecordType
          WHERE
            SObjectType = :STA_UtilsStatic.SOBJECT_CASE
          AND DeveloperName LIKE :STA_UtilsStatic.SMC_PREFIX_CASE_RECORDTYPE_INTERNAL + '%'
        ]
      );

      for (
        SMC_AC_Page_CreateCase.AssociateCaseTypeToImg oneResult : dtoResult.listActi
      ) {
        System.assertNotEquals(
          null,
          mapRecordType.get(oneResult.caseTypeId),
          'The record type [Id:' +
          oneResult.caseTypeId +
          '] does not exist.'
        );
        System.assertNotEquals(
          null,
          oneResult.caseTypeName,
          'The record type name does match with the manual build.'
        );
        System.assertNotEquals(
          null,
          oneResult.caseTypeImg,
          'The type has not a picture linked.'
        );
      }
    }
  }

    /**
   * @description : test SMC_AC_Page_CreateCase.setCaseTypeList(AfterSalesBaService) Contact
   * @author Denis PHAM (Modis) | 14-04-2022
   **/
  @isTest
  public static void testSetCaseTypeListFor_ContactAfterSalesBaService() {
    User user = [SELECT Id FROM User WHERE Email = :STA_UtilsStatic.EMAIL_TEST];
    System.runAs(user) {
      String kindCase = SMC_AC_Page_CreateCase.AFTER_SALES_BASERVICE;
      Contact contact = [SELECT Id, AccountId FROM Contact LIMIT 1];

      Test.startTest();
      String result = SMC_AC_Page_CreateCase.setCaseTypeList(kindCase, null, contact.Id);
      Test.stopTest();

      SMC_AC_Page_CreateCase.AllInfoToCreateCaseFromAnotherObject dtoResult = (SMC_AC_Page_CreateCase.AllInfoToCreateCaseFromAnotherObject) JSON.deserialize(
        result,
        SMC_AC_Page_CreateCase.AllInfoToCreateCaseFromAnotherObject.class
      );
      Map<Id, RecordType> mapRecordType = new Map<Id, RecordType>(
        [
          SELECT Id, Name, DeveloperName
          FROM RecordType
          WHERE
            SObjectType = :STA_UtilsStatic.SOBJECT_CASE
          AND DeveloperName LIKE :STA_UtilsStatic.SMC_PREFIX_CASE_RECORDTYPE_INTERNAL + '%'
        ]
      );

      for (
        SMC_AC_Page_CreateCase.AssociateCaseTypeToImg oneResult : dtoResult.listActi
      ) {
        System.assertNotEquals(
          null,
          mapRecordType.get(oneResult.caseTypeId),
          'The record type [Id:' +
          oneResult.caseTypeId +
          '] does not exist.'
        );
        System.assertNotEquals(
          null,
          oneResult.caseTypeName,
          'The record type name does match with the manual build.'
        );
        System.assertNotEquals(
          null,
          oneResult.caseTypeImg,
          'The type has not a picture linked.'
        );
      }
    }
  }
}