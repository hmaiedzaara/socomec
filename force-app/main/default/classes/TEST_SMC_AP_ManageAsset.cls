/*
---------------------------------------------------------------------------
-- - Name : TEST_SMC_AP_ManageAsset
-- - Author : Vincent RECASENS
-- - Description : This class test the Apex class SMC_AP_ManageAsset
--
-- Maintenance History:
--
-- Date         Name        Version     Remarks
-- -----------  ----        -------     -----------------------
-- 15-MAR-2019  VRE 		1.0     	Initial Version
---------------------------------------------------------------------------
*/

@isTest(isParallel=false)
public with sharing class TEST_SMC_AP_ManageAsset {
  /**
   * @description : test setup
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  @testSetup
  public static void setup() {
    System.debug(
      LoggingLevel.INFO,
      '>>>>>> TEST_SMC_AP_ManageAsset : setup - START'
    );
    Profile profileAdmin = [
      SELECT Id
      FROM Profile
      WHERE Name = :STA_UtilsStatic.PROFILE_SMC_ADMIN
    ];
    User userAdmin = SMC_UTIL_TestUtils.createUser(
      'admin-' + STA_UtilsStatic.USERNAME_TEST,
      'admin-' + STA_UtilsStatic.USERNAME_TEST,
      profileAdmin.Id,
      'admin-' + STA_UtilsStatic.USERNAME_TEST,
      'admin-' + STA_UtilsStatic.USERNAME_TEST
    );
    userAdmin.SMC_Defautlt_Parent_Service_organisation__c = STA_UtilsStatic.PSO_FR;
    userAdmin.Bypass_Validation_Rule__c = 'SMC_NoEditProduct;SMC_BAESprotectedField;SMC_PreventLocationWithoutAddress';
    insert userAdmin;

    System.runAs(userAdmin) {
      PAD.bypassAll = true;

      //Product
      Map<String, Schema.RecordTypeInfo> recordTypesProduct = new Map<String, Schema.RecordTypeInfo>();
      recordTypesProduct = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName();
      Id productRecordTypeId = recordTypesProduct.get(
          STA_UtilsStatic.RECORDTYPE_SERVICE_PRODUCT
        )
        .getRecordTypeId();
      Id productSparePartRecordTypeId = recordTypesProduct.get(
          STA_UtilsStatic.RECORDTYPE_SPARE_PART_PRODUCT
        )
        .getRecordTypeId();
      Product2 theProductBis = SMC_UTIL_TestUtils.createProductFSL(
        productRecordTypeId,
        STA_UtilsStatic.TEST + 'Bis',
        true
      );
      Product2 theProductSparePart = SMC_UTIL_TestUtils.createProductFSL(
        productSparePartRecordTypeId,
        STA_UtilsStatic.TEST + '_sparePart',
        true
      );
      insert new List<Product2>{ theProductBis, theProductSparePart };
      Product2 theProduct = SMC_UTIL_TestUtils.createProductFSL(
        productRecordTypeId,
        STA_UtilsStatic.TEST,
        true
      );
      theProduct.SMC_Spare_Part_Code__c = theProductSparePart.Id;
      insert new List<Product2>{ theProduct };

      //Account
      Map<String, Schema.RecordTypeInfo> recordTypesAccount = new Map<String, Schema.RecordTypeInfo>();
      recordTypesAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName();
      Id recordTypeIdAcc = recordTypesAccount.get(
          STA_UtilsStatic.RECORDTYPE_ACCOUNT_CUSTOMER_DEVNAME
        )
        .getRecordTypeId();
      Account account = SMC_UTIL_TestUtils.createAccount(
        recordTypeIdAcc,
        STA_UtilsStatic.TEST,
        STA_UtilsStatic.PICKLIST_ACCOUNT_TYPE_MARKETING_PROSPECT,
        STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY2
      );
      insert account;

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
        account.Id
      );
      insert contact;

      //Asset
      Map<String, Schema.RecordTypeInfo> recordTypesAsset = new Map<String, Schema.RecordTypeInfo>();
      recordTypesAsset = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName();
      Id assetRecordTypeId = recordTypesAsset.get(
          STA_UtilsStatic.RECORDTYPE_ASSET
        )
        .getRecordTypeId();
      Id assetRelatedObjectRecordTypeId = recordTypesAsset.get(
          STA_UtilsStatic.RECORDTYPE_ASSET_RELATED_OBJECT
        )
        .getRecordTypeId();
      Asset theAsset = SMC_UTIL_TestUtils.createAsset(
        assetRecordTypeId,
        null,
        account.Id,
        contact.Id,
        STA_UtilsStatic.TEST,
        theProduct.Id,
        null,
        '001'
      );
      theAsset.SMC_Parent_service_organisation__c = STA_UtilsStatic.PSO_FR;
      Asset theAssetParent = SMC_UTIL_TestUtils.createAsset(
        assetRecordTypeId,
        null,
        account.Id,
        contact.Id,
        STA_UtilsStatic.TEST + ' Parent',
        theProduct.Id,
        null,
        '0011'
      );
      Asset theAssetBis = SMC_UTIL_TestUtils.createAsset(
        assetRecordTypeId,
        null,
        account.Id,
        contact.Id,
        STA_UtilsStatic.TEST + '2',
        theProductBis.Id,
        null,
        '002'
      );
      insert new List<Asset>{ theAsset, theAssetParent, theAssetBis };
      Asset theAssetChild = SMC_UTIL_TestUtils.createAsset(
        assetRelatedObjectRecordTypeId,
        null,
        account.Id,
        contact.Id,
        STA_UtilsStatic.TEST + ' Child',
        theProductSparePart.Id,
        null,
        '003'
      );
      theAssetChild.ParentId = theAssetParent.Id;
      insert new List<Asset>{ theAssetChild };

      PAD.bypassAll = false;

      System.debug(
        LoggingLevel.INFO,
        '>>>>>> TEST_SMC_AP_ManageAsset : setup - END'
      );
    }
  }

  /**
   * @description : test SMC_AP_ManageAsset.createAssetRelatedObject()
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  @isTest
  public static void testCreateAssetRelatedObjectOK() {
    System.debug(
      LoggingLevel.INFO,
      '>>>>>> TEST_SMC_AP_ManageAsset : testCreateAssetRelatedObjectOK - START'
    );

    User userAdmin = [
      SELECT Id
      FROM User
      WHERE Name = :('admin-' + STA_UtilsStatic.USERNAME_TEST)
    ];

    System.runAs(userAdmin) {
      Product2 theProduct = [
        SELECT Id
        FROM Product2
        WHERE Name = :STA_UtilsStatic.TEST
      ];
      Product2 theProductSparePart = [
        SELECT Id
        FROM Product2
        WHERE Name = :(STA_UtilsStatic.TEST + '_sparePart')
      ];
      Asset theAsset = [
        SELECT
          Id,
          Name,
          RecordTypeId,
          AccountId,
          ContactId,
          Product2Id,
          SMC_Parent_service_organisation__c,
          InstallDate,
          SMC_CommissioningDate__c,
          SMC_Manufacturing_date__c,
          SMC_Shipping_date__c,
          CreatedDate
        FROM Asset
        WHERE Name = :STA_UtilsStatic.TEST
      ];

      SMC_GTL__c theGTL = SMC_UTIL_TestUtils.createGTL(
        theProduct.Id,
        STA_UtilsStatic.TEST_DIESE,
        STA_UtilsStatic.GTL_ACTIVE
      );
      theGtl.SMC_Spare_Part__c = theProductSparePart.Id;
      theGtl.SMC_Quantity__c = 7;
      theGtl.SMC_Group__c = STA_UtilsStatic.AC_INPUT_CAPACITOR;
      theGtl.SMC_IsServiceComponent__c = 'yes';
      insert theGtl;

      SMC_GtlServiceProductAssociation__c theGTLAssociation = SMC_UTIL_TestUtils.createGTLServiceProductAssociation(
        theProduct.Id,
        theGtl.Id
      );
      insert theGTLAssociation;

      SMC_AC_CreateAssetRelatedObject_GTL.ResultWrapper result = SMC_AP_ManageAsset.createAssetRelatedObject(
        new Map<Id, Asset>{ theAsset.Id => theAsset },
        null
      );
      System.assert(
        result.isSuccess,
        'ServiceBOM (RelatedObject) were not created. Check variables initialisation.'
      );
    }

    System.debug(
      LoggingLevel.INFO,
      '>>>>>> TEST_SMC_AP_ManageAsset : testCreateAssetRelatedObjectOK - END'
    );
  }

  /**
   * @description : test SMC_AP_ManageAsset.creationRelatedObject()
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  @isTest
  public static void testCreateRelatedObjectFromDatatable() {
    System.debug(
      LoggingLevel.INFO,
      '>>>>>> TEST_SMC_AP_ManageAsset : testCreateAssetRelatedObjectOK - START'
    );

    User userAdmin = [
      SELECT Id
      FROM User
      WHERE Name = :('admin-' + STA_UtilsStatic.USERNAME_TEST)
    ];

    System.runAs(userAdmin) {
      Product2 theProductSparePart = [
        SELECT Id, ProductCode
        FROM Product2
        WHERE Name = :(STA_UtilsStatic.TEST + '_sparePart')
      ];
      Product2 theProduct = [
        SELECT Id, Name, ProductCode, SMC_Spare_Part_Code__c
        FROM Product2
        WHERE Name = :STA_UtilsStatic.TEST
      ];
      // theProduct.SMC_Spare_Part_Code__c = theProductSparePart.Id;
      update theProduct;

      Asset theAsset = [
        SELECT
          Id,
          Name,
          RecordTypeId,
          AccountId,
          ContactId,
          Product2Id,
          SMC_Parent_service_organisation__c,
          InstallDate,
          SMC_CommissioningDate__c,
          SMC_Manufacturing_date__c,
          SMC_Shipping_date__c,
          CreatedDate
        FROM Asset
        WHERE Name = :STA_UtilsStatic.TEST
      ];
      theAsset.SMC_Parent_service_organisation__c = STA_UtilsStatic.PSO_FR;
      update theAsset;

      SMC_GTL__c theGTL = SMC_UTIL_TestUtils.createGTL(
        theProduct.Id,
        STA_UtilsStatic.TEST_DIESE,
        STA_UtilsStatic.GTL_ACTIVE
      );
      theGtl.SMC_Spare_Part__c = theProductSparePart.Id;
      theGtl.SMC_Quantity__c = 7;
      theGtl.SMC_Group__c = STA_UtilsStatic.AC_INPUT_CAPACITOR;
      theGtl.SMC_Option__c = STA_UtilsStatic.ACS;
      theGtl.SMC_IsServiceComponent__c = 'yes';
      insert theGtl;

      SMC_GtlServiceProductAssociation__c theGTLAssociation = SMC_UTIL_TestUtils.createGTLServiceProductAssociation(
        theProduct.Id,
        theGtl.Id
      );
      insert theGTLAssociation;

      SMC_AC_CreateRecordFromDatatable.WrapperDataTableForAsset wrapper = new SMC_AC_CreateRecordFromDatatable.WrapperDataTableForAsset(
        theProduct.SMC_Spare_Part_Code__c,
        theGTL.Id,
        theProduct.Name,
        theProduct.ProductCode,
        theProductSparePart.ProductCode,
        theGTL.SMC_Group__c,
        null,
        theGTL.SMC_Option__c,
        theAsset.SMC_Parent_service_organisation__c,
        null,
        17
      );

      Boolean result = SMC_AP_ManageAsset.creationRelatedObject(
        theAsset,
        Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName()
          .get(STA_UtilsStatic.RECORDTYPE_ASSET_RELATED_OBJECT)
          .getRecordTypeId(),
        new List<SMC_AC_CreateRecordFromDatatable.WrapperDataTableForAsset>{
          wrapper
        }
      );
      System.assert(
        result,
        'ServiceBOM (RelatedObject) were not created. Check variables initialisation.'
      );
    }

    System.debug(
      LoggingLevel.INFO,
      '>>>>>> TEST_SMC_AP_ManageAsset : testCreateAssetRelatedObjectOK - END'
    );
  }

  /**
   * @description : test SMC_AP_ManageAsset.createAssetRelatedObject() [BAD]
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  @isTest
  public static void testCreateAssetRelatedObjectBAD() {
    System.debug(
      LoggingLevel.INFO,
      '>>>>>> TEST_SMC_AP_ManageAsset : testCreateAssetRelatedObjectOK - START'
    );

    User userAdmin = [
      SELECT Id
      FROM User
      WHERE Name = :('admin-' + STA_UtilsStatic.USERNAME_TEST)
    ];

    System.runAs(userAdmin) {
      SMC_AC_CreateAssetRelatedObject_GTL.ResultWrapper result = SMC_AP_ManageAsset.createAssetRelatedObject(
        new Map<Id, Asset>(),
        null
      );
      System.assert(
        result.emptyList,
        'ServiceBOM (RelatedObject) were created. Check variables initialisation.'
      );
    }

    System.debug(
      LoggingLevel.INFO,
      '>>>>>> TEST_SMC_AP_ManageAsset : testCreateAssetRelatedObjectOK - END'
    );
  }

  /**
   * @description : test SMC_AP_ManageAsset.checkExistingChild()
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  @isTest
  public static void testCheckExistingChildWithReltedObject() {
    System.debug(
      LoggingLevel.INFO,
      '>>>>>> TEST_SMC_AP_ManageAsset : testCreateAssetRelatedObjectOK - START'
    );

    User userAdmin = [
      SELECT Id
      FROM User
      WHERE Name = :('admin-' + STA_UtilsStatic.USERNAME_TEST)
    ];

    System.runAs(userAdmin) {
      Asset theAsset = [
        SELECT
          Id,
          Name,
          RecordTypeId,
          Product2Id,
          SMC_Parent_service_organisation__c,
          InstallDate
        FROM Asset
        WHERE Name = :(STA_UtilsStatic.TEST)
      ];
      Asset theAssetParent = [
        SELECT
          Id,
          Name,
          RecordTypeId,
          Product2Id,
          SMC_Parent_service_organisation__c,
          InstallDate
        FROM Asset
        WHERE Name = :(STA_UtilsStatic.TEST + ' Parent')
      ];

      Map<Id, Asset> checkMap = SMC_AP_ManageAsset.checkExistingChild(
        new Map<Id, Asset>{
          theAsset.Id => theAsset,
          theAssetParent.Id => theAssetParent
        },
        null
      );
      System.assertEquals(
        new Map<Id, Asset>{ theAsset.Id => theAsset },
        checkMap,
        'Childs were not identify.'
      );
    }

    System.debug(
      LoggingLevel.INFO,
      '>>>>>> TEST_SMC_AP_ManageAsset : testCreateAssetRelatedObjectOK - END'
    );
  }

  /**
   * @description : test SMC_AP_ManageAsset.manageParentServiceOrganisation() by trigger
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  @isTest
  public static void testManageParentServiceOrganisation() {
    System.debug(
      LoggingLevel.INFO,
      '>>>>>> TEST_SMC_AP_ManageAsset : testManageParentServiceOrganisation - START'
    );

    // Profile profileAdmin = [
    //   SELECT Id
    //   FROM Profile
    //   WHERE Name = :STA_UtilsStatic.PROFILE_SALE_STANDARD
    // ];
    // User userAdmin = SMC_UTIL_TestUtils.createUser(
    //   'admin-' + STA_UtilsStatic.USERNAME_TEST,
    //   'admin-' + STA_UtilsStatic.USERNAME_TEST,
    //   profileAdmin.Id,
    //   'admin-' + STA_UtilsStatic.USERNAME_TEST,
    //   'admin-' + STA_UtilsStatic.USERNAME_TEST
    // );
    // userAdmin.SMC_Defautlt_Parent_Service_organisation__c = STA_UtilsStatic.PSO_FR;
    // userAdmin.Bypass_Validation_Rule__c = 'SMC_NoEditProduct';
    // insert userAdmin;
    User userAdmin = [
      SELECT Id
      FROM User
      WHERE Name = :('admin-' + STA_UtilsStatic.USERNAME_TEST)
    ];

    System.runAs(userAdmin) {
      Map<String, Schema.RecordTypeInfo> recordTypesProduct = new Map<String, Schema.RecordTypeInfo>();
      recordTypesProduct = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName();
      Id productRecordTypeId = recordTypesProduct.get(
          STA_UtilsStatic.RECORDTYPE_SERVICE_PRODUCT
        )
        .getRecordTypeId();
      Id productSparePartRecordTypeId = recordTypesProduct.get(
          STA_UtilsStatic.RECORDTYPE_SPARE_PART_PRODUCT
        )
        .getRecordTypeId();

      //Get Power Unit
      Schema.DescribeFieldResult fieldResult = Product2.SMC_Power_Unit_p__c.getDescribe();
      List<Schema.PicklistEntry> entries = fieldResult.getPicklistValues();

      Product2 theProduct = SMC_UTIL_TestUtils.createServiceProductFSL(
        productRecordTypeId,
        STA_UtilsStatic.PRODUCT_NAME + '1',
        true,
        STA_UtilsStatic.PRODUCT_CODE_ABLE,
        STA_UtilsStatic.PRODUCT_MANUFACTEUR_ABLE,
        STA_UtilsStatic.PRODUCT_RANGE_ABLE,
        STA_UtilsStatic.PRODUCT_MODEL_ABLE,
        STA_UtilsStatic.PRODUCT_CONFIGURATION_ABLE,
        STA_UtilsStatic.PRODUCT_PHASE_ABLE,
        STA_UtilsStatic.PRODUCT_POWER_ABLE,
        entries[0].getValue()
      );
      Product2 theProductBis = SMC_UTIL_TestUtils.createServiceProductFSL(
        productRecordTypeId,
        STA_UtilsStatic.PRODUCT_NAME + '2',
        true,
        STA_UtilsStatic.PRODUCT_CODE_ABLE_BIS,
        STA_UtilsStatic.PRODUCT_MANUFACTEUR_ABLE,
        STA_UtilsStatic.PRODUCT_RANGE_ABLE,
        STA_UtilsStatic.PRODUCT_MODEL_ABLE_BIS,
        null,
        null,
        null,
        entries[0].getValue()
      );
      Product2 theProductSparePart = SMC_UTIL_TestUtils.createProductFSL(
        productSparePartRecordTypeId,
        STA_UtilsStatic.TEST + '_sparePart',
        true
      );
      Product2 theProductSparePart2 = SMC_UTIL_TestUtils.createProductFSL(
        productSparePartRecordTypeId,
        STA_UtilsStatic.TEST + '_sparePart2',
        true
      );
      insert new List<Product2>{
        theProduct,
        theProductBis,
        theProductSparePart,
        theProductSparePart2
      };

      SMC_GTL__c theGTL = SMC_UTIL_TestUtils.createGTL(
        theProduct.Id,
        STA_UtilsStatic.TEST_DIESE,
        STA_UtilsStatic.GTL_ACTIVE
      );
      theGtl.SMC_Spare_Part__c = theProductSparePart.Id;
      theGtl.SMC_Quantity__c = 7;
      theGtl.SMC_Group__c = STA_UtilsStatic.AC_INPUT_CAPACITOR;
      theGtl.SMC_IsServiceComponent__c = 'yes';
      SMC_GTL__c theGtl2 = SMC_UTIL_TestUtils.createGTL(
        theProductBis.Id,
        STA_UtilsStatic.TEST_DIESE,
        STA_UtilsStatic.GTL_ACTIVE
      );
      theGtl2.SMC_Spare_Part__c = theProductSparePart.Id;
      theGtl2.SMC_Quantity__c = 7;
      theGtl2.SMC_Group__c = STA_UtilsStatic.AC_INPUT_CAPACITOR;
      theGtl2.SMC_IsServiceComponent__c = 'yes';
      insert new List<SMC_GTL__c>{ theGtl, theGtl2 };

      SMC_GtlServiceProductAssociation__c theGTLAssociation = SMC_UTIL_TestUtils.createGTLServiceProductAssociation(
        theProduct.Id,
        theGtl.Id
      );
      SMC_GtlServiceProductAssociation__c theGTLAssociation2 = SMC_UTIL_TestUtils.createGTLServiceProductAssociation(
        theProductBis.Id,
        theGtl2.Id
      );
      insert new List<SMC_GtlServiceProductAssociation__c>{
        theGTLAssociation,
        theGTLAssociation2
      };

      //Account
      Map<String, Schema.RecordTypeInfo> recordTypesAccount = new Map<String, Schema.RecordTypeInfo>();
      recordTypesAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName();
      Id recordTypeIdAcc = recordTypesAccount.get(
          STA_UtilsStatic.RECORDTYPE_ACCOUNT_CUSTOMER_DEVNAME
        )
        .getRecordTypeId();
      Account account = SMC_UTIL_TestUtils.createAccount(
        recordTypeIdAcc,
        STA_UtilsStatic.TEST + 'manageParentOrganisation',
        STA_UtilsStatic.PICKLIST_ACCOUNT_TYPE_MARKETING_PROSPECT,
        STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY2
      );
      insert account;

      //Contact
      Contact contact = SMC_UTIL_TestUtils.createContact(
        STA_UtilsStatic.CONTACT_FIRSTNAME1,
        'deDuplcateContactPSO' + STA_UtilsStatic.CONTACT_LASTNAME1,
        null,
        null,
        'deDuplcateContactPSO' + STA_UtilsStatic.CONTACT_EMAIL1,
        STA_UtilsStatic.CONTACT_MAILINGSTREET1,
        STA_UtilsStatic.CONTACT_MAILINGPOSTALCODE1,
        STA_UtilsStatic.CONTACT_MAILINGCITY1,
        STA_UtilsStatic.CONTACT_MAILINGSTATE1,
        STA_UtilsStatic.CONTACT_MAILINGCOUNTRY1,
        STA_UtilsStatic.CONTACT_OTHERCITY1,
        account.Id
      );
      insert contact;

      Map<String, Schema.RecordTypeInfo> recordTypesAsset = new Map<String, Schema.RecordTypeInfo>();
      recordTypesAsset = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName();
      Id assetRecordTypeId = recordTypesAsset.get(
          STA_UtilsStatic.RECORDTYPE_ASSET
        )
        .getRecordTypeId();
      Asset theAsset = SMC_UTIL_TestUtils.createAsset(
        assetRecordTypeId,
        null,
        account.Id,
        contact.Id,
        STA_UtilsStatic.TEST + ' ParentServiceOrganisation',
        theProduct.Id,
        null,
        '100'
      );
      theAsset.SMC_Parent_service_organisation__c = STA_UtilsStatic.PSO_FR;
      Asset theAssetBis = SMC_UTIL_TestUtils.createAsset(
        assetRecordTypeId,
        null,
        account.Id,
        contact.Id,
        STA_UtilsStatic.TEST + '2 ParentServiceOrganisation',
        theProductBis.Id,
        null,
        '101'
      );
      insert new List<Asset>{ theAsset, theAssetBis };

      Test.startTest();
      List<Asset> assetList = [
        SELECT Id, Name, SMC_Parent_service_organisation__c
        FROM Asset
        WHERE Name LIKE '%ParentServiceOrganisation'
      ];
      for (Asset oneAsset : assetList) {
        if (
          oneAsset.Name == STA_UtilsStatic.TEST + ' ParentServiceOrganisation'
        ) {
          oneAsset.Description = STA_UtilsStatic.TEST;
        }
      }

      update assetList;
      Test.stopTest();

      List<Asset> assetListCheck = [
        SELECT Id, Name, SMC_Parent_service_organisation__c
        FROM Asset
        WHERE Name LIKE '%ParentServiceOrganisation'
      ];
      for (Asset oneAsset : assetList) {
        if (
          oneAsset.Name == STA_UtilsStatic.TEST + ' ParentServiceOrganisation'
        ) {
          /*System.assertEquals(
            STA_UtilsStatic.PSO_FR,
            oneAsset.SMC_Parent_service_organisation__c
          );*/
        }
        if (
          oneAsset.Name ==
          (STA_UtilsStatic.TEST + '2 ParentServiceOrganisation')
        ) {
          System.assertNotEquals(
            STA_UtilsStatic.PSO_FR,
            oneAsset.SMC_Parent_service_organisation__c,
            'The asset ParentServiceOrganisation was not match with test value "STA_UtilsStatic.PSO_FR".'
          );
        }
      }
    }

    System.debug(
      LoggingLevel.INFO,
      '>>>>>> TEST_SMC_AP_ManageAsset : testManageParentServiceOrganisation - END'
    );
  }

  /**
   * @description : test SMC_AP_ManageAsset.productIschanged()
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  @isTest
  public static void testProductIsChanged() {
    User userAdmin = [
      SELECT Id
      FROM User
      WHERE Name = :('admin-' + STA_UtilsStatic.USERNAME_TEST)
    ];
    PAD.bypassAll = false;

    System.runAs(userAdmin) {
      Map<String, Schema.RecordTypeInfo> recordTypesProduct = new Map<String, Schema.RecordTypeInfo>();
      recordTypesProduct = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName();
      Id productSparePartRecordTypeId = recordTypesProduct.get(
          STA_UtilsStatic.RECORDTYPE_SPARE_PART_PRODUCT
        )
        .getRecordTypeId();
      Asset theAsset = [
        SELECT
          Id,
          Name,
          RecordTypeId,
          AccountId,
          ContactId,
          Product2Id,
          SMC_Parent_service_organisation__c,
          InstallDate,
          SMC_CommissioningDate__c,
          SMC_Manufacturing_date__c,
          SMC_Shipping_date__c,
          CreatedDate
        FROM Asset
        WHERE Name = :STA_UtilsStatic.TEST
      ];
      Product2 theProduct = [
        SELECT Id
        FROM Product2
        WHERE Name = :STA_UtilsStatic.TEST
      ];
      Product2 theProductBis2 = [
        SELECT Id
        FROM Product2
        WHERE Name = :(STA_UtilsStatic.TEST + 'Bis')
      ];
      Product2 theProductSparePart = [
        SELECT Id
        FROM Product2
        WHERE Name = :(STA_UtilsStatic.TEST + '_sparePart')
      ];
      List<String> groupList = new List<String>{
        STA_UtilsStatic.AC_INPUT_CAPACITOR,
        STA_UtilsStatic.AC_OUTPUT_CAPACITOR,
        STA_UtilsStatic.DC_CAPACITOR,
        STA_UtilsStatic.FAN,
        // STA_UtilsStatic.BATTERY,
        STA_UtilsStatic.POWER_SUPPLY
      };
      list<SMC_GTL__c> gtlList = new List<SMC_GTL__c>();
      List<SMC_GtlServiceProductAssociation__c> gtlAssociationList = new List<SMC_GtlServiceProductAssociation__c>();
      List<Product2> theProductSparePartGTLList = new List<Product2>();
      Map<String, Product2> theProductSparePartGTLMap = new Map<String,Product2>();
      //Add Spare part
      for (String groupStr : groupList) {
        Product2 theProductSparePartGTL = SMC_UTIL_TestUtils.createProductFSL(
          productSparePartRecordTypeId,
          STA_UtilsStatic.TEST + '_sparePart_' + groupStr,
          true
        );
        theProductSparePartGTL.ProductCode = groupStr;
        theProductSparePartGTLMap.put(groupStr, theProductSparePartGTL);
        theProductSparePartGTLList.add(theProductSparePartGTL);
      }
      insert theProductSparePartGTLList;

      for(Product2 onePdt : theProductSparePartGTLList){
        theProductSparePartGTLMap.put(onePdt.Name.split('_sparePart_')[1], onePdt);
      }


      // for(Integer i = 0; i < theProductSparePartGTLList.size(); ++i){
      //   SMC_GTL__c theGTL = SMC_UTIL_TestUtils.createGTL(
      //     theProduct.Id,
      //     STA_UtilsStatic.TEST_DIESE,
      //     STA_UtilsStatic.GTL_ACTIVE
      //   );
      //   theGtl.SMC_Spare_Part__c = theProductSparePartGTLList[i].Id;
      //   theGtl.SMC_Quantity__c = 7;
      //   theGtl.SMC_Group__c = groupList[i];
      //   theGtl.SMC_IsServiceComponent__c = 'yes';
      //   gtlList.add(theGtl);
      // }
      // insert gtlList;
      //Add GTL
      // Integer i = 0;
      for (String oneGrp : theProductSparePartGTLMap.keySet()) {
        SMC_GTL__c theGTL = SMC_UTIL_TestUtils.createGTL(
          theProduct.Id,
          STA_UtilsStatic.TEST_DIESE,
          STA_UtilsStatic.GTL_ACTIVE
        );
        theGtl.SMC_Spare_Part__c = theProductSparePartGTLMap.get(oneGrp).id;
        theGtl.SMC_Quantity__c = 7;
        theGtl.SMC_Group__c = oneGrp;
        theGtl.SMC_IsServiceComponent__c = 'yes';
        gtlList.add(theGtl);
      }
      insert gtlList;
      //Add GTL asscoaition
      for (SMC_GTL__c gtlItem : gtlList) {
        SMC_GtlServiceProductAssociation__c theGTLAssociation = SMC_UTIL_TestUtils.createGTLServiceProductAssociation(
          theProduct.Id,
          gtlItem.Id
        );
        SMC_GtlServiceProductAssociation__c theGTLAssociationBis = SMC_UTIL_TestUtils.createGTLServiceProductAssociation(
          theProductBis2.Id,
          gtlItem.Id
        );
        gtlAssociationList.add(theGTLAssociation);
        gtlAssociationList.add(theGTLAssociationBis);
      }
      insert gtlAssociationList;

      SMC_AP_ManageAsset.createAssetRelatedObject(
        new Map<Id, Asset>{ theAsset.Id => theAsset },
        null
      );
      List<Asset> relatedObjectList = [
        SELECT Id, InstallDate
        FROM Asset
        WHERE
          ParentId = :theAsset.Id
          AND RecordTypeId = :Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName()
            .get(STA_UtilsStatic.RECORDTYPE_ASSET_RELATED_OBJECT)
            .getRecordTypeId()
      ];
      System.assertEquals(
        5,
        relatedObjectList.size(),
        'Service BOM are not created Before TEST.'
      );

      for (Asset relatedObject : relatedObjectList) {
        relatedObject.installDate = Date.today().addDays(-5);
      }
      update relatedObjectList;

      relatedObjectList = [
        SELECT Id, InstallDate
        FROM Asset
        WHERE
          ParentId = :theAsset.Id
          AND RecordTypeId = :Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName()
            .get(STA_UtilsStatic.RECORDTYPE_ASSET_RELATED_OBJECT)
            .getRecordTypeId()
      ];
      System.assertEquals(
        5,
        relatedObjectList.size(),
        'Service BOM are not created Before TEST.'
      );

      Test.startTest();
        Product2 theProductBis = [
          SELECT Id
          FROM Product2
          WHERE Name = :(STA_UtilsStatic.TEST + 'Bis')
        ];
        theAsset.Product2Id = theProductBis.Id;
        update theAsset;
      Test.stopTest();

      List<Asset> relatedObjectListAfter = [
        SELECT Id, InstallDate, ParentId
        FROM Asset
        WHERE
          ParentId = :theAsset.Id
          AND RecordTypeId = :Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName()
            .get(STA_UtilsStatic.RECORDTYPE_ASSET_RELATED_OBJECT)
            .getRecordTypeId()
      ];
      System.assertEquals(
        5,
        relatedObjectList.size(),
        'Service BOM are not created After TEST.'
      );


      for (asset ass : relatedObjectListAfter) {
        System.assertEquals(
          Date.today().addDays(-5),
          ass.installDate,
          'install date was not kept'
        );
      }
    }
  }

  /**
   * @description : test SMC_AP_ManageAsset.findReplacementFrequencyOnProduct() [Multiple tests]
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  @isTest
  public static void testFindReplacementFrequencyOnProduct() {
    // Profile profileAdmin = [
    //   SELECT Id
    //   FROM Profile
    //   WHERE Name = :STA_UtilsStatic.PROFILE_SALE_STANDARD
    // ];
    // User userAdmin = SMC_UTIL_TestUtils.createUser(
    //   'admin-' + STA_UtilsStatic.USERNAME_TEST,
    //   'admin-' + STA_UtilsStatic.USERNAME_TEST,
    //   profileAdmin.Id,
    //   'admin-' + STA_UtilsStatic.USERNAME_TEST,
    //   'admin-' + STA_UtilsStatic.USERNAME_TEST
    // );
    // userAdmin.Bypass_Validation_Rule__c = 'SMC_NoEditProduct';
    // insert userAdmin;
    User userAdmin = [
      SELECT Id
      FROM User
      WHERE Name = :('admin-' + STA_UtilsStatic.USERNAME_TEST)
    ];

    System.runAs(userAdmin) {
      PAD.bypassAll = true;

      Id productRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName()
        .get(STA_UtilsStatic.RECORDTYPE_SERVICE_PRODUCT)
        .getRecordTypeId();
      Product2 theProduct = SMC_UTIL_TestUtils.createProductFSL(
        productRecordTypeId,
        STA_UtilsStatic.TEST +
        '-' +
        STA_UtilsStatic.AC_INPUT_CAPACITOR,
        true
      );
      theProduct.SMC_AC_in_CAPA_Replacement_freq_years__c = 1;
      theProduct.SMC_AC_out_CAPA_Replacement_freq_years__c = 2;
      theProduct.SMC_DC_CAPA_Replacement_frequency_years__c = 3;
      theProduct.SMC_FAN_Replacement_freq_years__c = 4;
      theProduct.SMC_POWER_SUPPLY_Replacement_freq_years__c = 5;
      insert new List<Product2>{ theProduct };

      //Account
      Map<String, Schema.RecordTypeInfo> recordTypesAccount = new Map<String, Schema.RecordTypeInfo>();
      recordTypesAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName();
      Id recordTypeIdAcc = recordTypesAccount.get(
          STA_UtilsStatic.RECORDTYPE_ACCOUNT_CUSTOMER_DEVNAME
        )
        .getRecordTypeId();
      Account account = SMC_UTIL_TestUtils.createAccount(
        recordTypeIdAcc,
        STA_UtilsStatic.TEST + 'findFrequency',
        STA_UtilsStatic.PICKLIST_ACCOUNT_TYPE_MARKETING_PROSPECT,
        STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY2
      );
      insert account;

      //Contact
      Contact contact = SMC_UTIL_TestUtils.createContact(
        STA_UtilsStatic.CONTACT_FIRSTNAME1,
        'deDuplcateContact' + STA_UtilsStatic.CONTACT_LASTNAME1,
        null,
        null,
        'deDuplcateContact' + STA_UtilsStatic.CONTACT_EMAIL1,
        STA_UtilsStatic.CONTACT_MAILINGSTREET1,
        STA_UtilsStatic.CONTACT_MAILINGPOSTALCODE1,
        STA_UtilsStatic.CONTACT_MAILINGCITY1,
        STA_UtilsStatic.CONTACT_MAILINGSTATE1,
        STA_UtilsStatic.CONTACT_MAILINGCOUNTRY1,
        STA_UtilsStatic.CONTACT_OTHERCITY1,
        account.Id
      );
      insert contact;

      Id assetRecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName()
        .get(STA_UtilsStatic.RECORDTYPE_ASSET)
        .getRecordTypeId();
      Asset theAssetAcin = SMC_UTIL_TestUtils.createAsset(
        assetRecordTypeId,
        null,
        account.Id,
        contact.Id,
        STA_UtilsStatic.TEST + ' TestFrequency ACIN',
        theProduct.Id,
        null,
        '004-1'
      );
      Asset theAssetAcout = SMC_UTIL_TestUtils.createAsset(
        assetRecordTypeId,
        null,
        account.Id,
        contact.Id,
        STA_UtilsStatic.TEST + ' TestFrequency ACOUT',
        theProduct.Id,
        null,
        '004-2'
      );
      Asset theAssetDc = SMC_UTIL_TestUtils.createAsset(
        assetRecordTypeId,
        null,
        account.Id,
        contact.Id,
        STA_UtilsStatic.TEST + ' TestFrequency DC',
        theProduct.Id,
        null,
        '004-3'
      );
      Asset theAssetFan = SMC_UTIL_TestUtils.createAsset(
        assetRecordTypeId,
        null,
        account.Id,
        contact.Id,
        STA_UtilsStatic.TEST + ' TestFrequency FAN',
        theProduct.Id,
        null,
        '004-4'
      );
      Asset theAssetPS = SMC_UTIL_TestUtils.createAsset(
        assetRecordTypeId,
        null,
        account.Id,
        contact.Id,
        STA_UtilsStatic.TEST + ' TestFrequency PS',
        theProduct.Id,
        null,
        '004-5'
      );
      insert new List<Asset>{
        theAssetAcin,
        theAssetAcout,
        theAssetDc,
        theAssetFan,
        theAssetPS
      };

      PAD.bypassAll = false;

      Test.startTest();
      List<Asset> checkAcin = SMC_AP_ManageAsset.findReplacementFrequencyOnProduct(
        new List<Asset>{ theAssetAcin },
        new Map<String, Id>{ theAssetAcin.Name => theProduct.Id },
        new Map<String, String>{
          theProduct.Id +
          '|' +
          theAssetAcin.Name => STA_UtilsStatic.AC_INPUT_CAPACITOR
        },
        new Map<String, Double>{ STA_UtilsStatic.AC_INPUT_CAPACITOR => 1 }
      );
      List<Asset> checkAcout = SMC_AP_ManageAsset.findReplacementFrequencyOnProduct(
        new List<Asset>{ theAssetAcout },
        new Map<String, Id>{ theAssetAcout.Name => theProduct.Id },
        new Map<String, String>{
          theProduct.Id +
          '|' +
          theAssetAcout.Name => STA_UtilsStatic.AC_OUTPUT_CAPACITOR
        },
        new Map<String, Double>{ STA_UtilsStatic.AC_OUTPUT_CAPACITOR => 2 }
      );
      List<Asset> checkDc = SMC_AP_ManageAsset.findReplacementFrequencyOnProduct(
        new List<Asset>{ theAssetDc },
        new Map<String, Id>{ theAssetDc.Name => theProduct.Id },
        new Map<String, String>{
          theProduct.Id +
          '|' +
          theAssetDc.Name => STA_UtilsStatic.DC_CAPACITOR
        },
        new Map<String, Double>{ STA_UtilsStatic.DC_CAPACITOR => 3 }
      );
      List<Asset> checkFan = SMC_AP_ManageAsset.findReplacementFrequencyOnProduct(
        new List<Asset>{ theAssetFan },
        new Map<String, Id>{ theAssetFan.Name => theProduct.Id },
        new Map<String, String>{
          theProduct.Id +
          '|' +
          theAssetFan.Name => STA_UtilsStatic.FAN
        },
        new Map<String, Double>{ STA_UtilsStatic.FAN => 4 }
      );
      List<Asset> checkPS = SMC_AP_ManageAsset.findReplacementFrequencyOnProduct(
        new List<Asset>{ theAssetPS },
        new Map<String, Id>{ theAssetPS.Name => theProduct.Id },
        new Map<String, String>{
          theProduct.Id +
          '|' +
          theAssetPS.Name => STA_UtilsStatic.POWER_SUPPLY
        },
        new Map<String, Double>{ STA_UtilsStatic.POWER_SUPPLY => 5 }
      );
      Test.stopTest();

      System.assertEquals(
        Date.today().addYears(2).addDays(-1),
        checkAcin[0].SMC_Next_replacement_date__c,
        'Check asset Acin initailisation (Next replacement).'
      );
      System.assertEquals(
        Date.today().addYears(1).addDays(-1),
        checkAcin[0].SMC_theoretical_next_replacement_date__c,
        'Check asset Acin initailisation (Theoretical next replacement).'
      );

      System.assertEquals(
        Date.today().addYears(4).addDays(-1),
        checkAcout[0].SMC_Next_replacement_date__c,
        'Check asset Acout initailisation (Next replacement).'
      );
      System.assertEquals(
        Date.today().addYears(2).addDays(-1),
        checkAcout[0].SMC_theoretical_next_replacement_date__c,
        'Check asset Acout initailisation (Theoretical next replacement).'
      );

      System.assertEquals(
        Date.today().addYears(6).addDays(-1),
        checkDc[0].SMC_Next_replacement_date__c,
        'Check asset DC initailisation (Next replacement).'
      );
      System.assertEquals(
        Date.today().addYears(3).addDays(-1),
        checkDc[0].SMC_theoretical_next_replacement_date__c,
        'Check asset DC initailisation (Theoretical next replacement).'
      );

      System.assertEquals(
        Date.today().addYears(8).addDays(-1),
        checkFan[0].SMC_Next_replacement_date__c,
        'Check asset FAN initailisation (Next replacement).'
      );
      System.assertEquals(
        Date.today().addYears(4).addDays(-1),
        checkFan[0].SMC_theoretical_next_replacement_date__c,
        'Check asset FAN initailisation (Theoretical next replacement).'
      );

      System.assertEquals(
        Date.today().addYears(10).addDays(-1),
        checkPS[0].SMC_Next_replacement_date__c,
        'Check asset PS initailisation (Next replacement).'
      );
      System.assertEquals(
        Date.today().addYears(5).addDays(-1),
        checkPS[0].SMC_theoretical_next_replacement_date__c,
        'Check asset PS initailisation (Theoretical next replacement).'
      );
    }
  }

  /**
   * @description : test SMC_AP_ManageAsset.getAccountGeneric()
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  // @isTest
  // public static void getAccountGenericFromCache() {
  //   Test.startTest();
  //   SMC_AP_ManageAsset.creteGenericAccount(); //GenericAccount_SBOM
  //   System.assertNotEquals(
  //     null,Cache.Org.get(
  //       GenericAccount_SBOM.class,
  //       STA_UtilsStatic.GENERIC_ACCOUNT_NAME_SBOM
  //     ),
  //     'The do load function does not work.'
  //   );
  //   Test.stopTest();
  // }

  @isTest
  public static void deletionPrevention() {
    Asset sBom = [
      SELECT id
      FROM Asset
      WHERE SMC_SerialNumber__c = '003'
      LIMIT 1
    ];
    Asset ass = [
      SELECT id
      FROM Asset
      WHERE Name = :(STA_UtilsStatic.TEST + '2')
      LIMIT 1
    ];
    User userAdmin = [
      SELECT Id
      FROM User
      WHERE Name = :('admin-' + STA_UtilsStatic.USERNAME_TEST)
    ];

    System.runAs(userAdmin) {
      delete sBom;
      Boolean isError = false;
      try {
        delete ass;
      } catch (Exception e) {
        isError = true;
      }
      system.assert(
        isError,
        'User should have been prevented from deleting asset'
      );
    }
    Test.startTest();
    Id fslPermSetId = [
      SELECT id
      FROM PermissionSet
      WHERE Name = :STA_UtilsStatic.FSL_KEY_USER
      LIMIT 1
    ]
    .Id;
    insert new PermissionSetAssignment(
      AssigneeId = userAdmin.Id,
      PermissionSetId = fslPermSetId
    );
    Test.stopTest();

    System.runAs(userAdmin) {
      Boolean isError = false;
      try {
        delete ass;
      } catch (Exception e) {
        isError = true;
      }
      system.assert(!isError, 'User should have successfuly deleted asset');
    }
  }

  /**
   * @description : test SMC_AP_ManageAsset.manageDecommissionning()
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  @isTest
  public static void testManageDecomission() {
    User userAdmin = [
      SELECT Id
      FROM User
      WHERE Name = :('admin-' + STA_UtilsStatic.USERNAME_TEST)
    ];

    System.runAs(userAdmin) {
      Asset ass = [
        SELECT id, Status, Product2Id
        FROM Asset
        WHERE Name = :STA_UtilsStatic.TEST
        LIMIT 1
      ];
      ass.SMC_CommissioningDate__c = Date.today();
      ass.SMC_Shipping_date__c = Date.today();
      ass.SMC_Manufacturing_date__c = Date.today();
      ass.Status = 'Active';
      update ass;

      WorkType wt = new WorkType(
        SMC_type__c = STA_UtilsStatic.WT_TYPE_FAN,
        Name = 'testWorktype',
        EstimatedDuration = 1,
        DurationType = 'Minutes'
      );
      insert wt;

      WorkOrder wo = new WorkOrder();
      insert wo;

      //SMC_WorkTypeServiceProductAssociation__c
      SMC_WorkTypeServiceProductAssociation__c wtspAss = SMC_UTIL_TestUtils.createWorkTypeServiceProductAssociation(ass.Product2Id, wt.Id);      
      insert wtspAss;

      WorkOrderLineItem woli = new WorkOrderLineItem(
        WorkOrderId = wo.id,
        AssetId = ass.id,
        WorkTypeId = wt.id
      );
      woli.Status = 'New';
      insert woli;

      Test.startTest();
      System.assertNotEquals(
        STA_UtilsStatic.PICKLIST_ASSET_DECOMISSION,
        ass.Status,
        'Asset is already decomissionning.'
      );
      System.assertNotEquals(
        STA_UtilsStatic.COMPLETED,
        [SELECT Id, Status FROM WorkOrderLineItem WHERE AssetId = :ass.Id]
        .Status,
        'WorkOrderLineItem have a bad status (Completed).'
      );
      //Test
      ass.Status = STA_UtilsStatic.PICKLIST_ASSET_DECOMISSION;
      update ass;
      //Check
      System.assertEquals(
        STA_UtilsStatic.PICKLIST_ASSET_DECOMISSION,
        [SELECT Id, Status FROM Asset WHERE Id = :ass.Id]
        .Status,
        'Asset is not decommissionning.'
      );
      System.assertEquals(
        STA_UtilsStatic.COMPLETED,
        [SELECT Id, Status FROM WorkOrderLineItem WHERE AssetId = :ass.Id]
        .Status,
        'WorkOrderLineItem is not completed.'
      );

      Test.stopTest();
    }
  }

  @isTest
  public static void testFillParentServiceOrganization() {
    User userAdmin = [
      SELECT Id
      FROM User
      WHERE Name = :('admin-' + STA_UtilsStatic.USERNAME_TEST)
    ];

    System.runAs(userAdmin) {
      //Account
      Map<String, Schema.RecordTypeInfo> recordTypesAccount = new Map<String, Schema.RecordTypeInfo>();
      recordTypesAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName();
      Id recordTypeIdAcc = recordTypesAccount.get(
          STA_UtilsStatic.RECORDTYPE_ACCOUNT_CUSTOMER_DEVNAME
        )
        .getRecordTypeId();
      Account account = SMC_UTIL_TestUtils.createAccount(
        recordTypeIdAcc,
        STA_UtilsStatic.TEST + 'fillParentOrganisation',
        STA_UtilsStatic.PICKLIST_ACCOUNT_TYPE_MARKETING_PROSPECT,
        STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY2
      );
      account.SMC_Service_Organization__c = 'FR';
      insert account;

      //Contact
      Contact contact = SMC_UTIL_TestUtils.createContact(
        STA_UtilsStatic.CONTACT_FIRSTNAME1,
        STA_UtilsStatic.CONTACT_LASTNAME1 + 'fillParentOrganisation',
        STA_UtilsStatic.CONTACT_PHONE1,
        STA_UtilsStatic.CONTACT_MOBILEPHONE1,
        'fillParentOrganisation.' + STA_UtilsStatic.CONTACT_EMAIL1,
        STA_UtilsStatic.CONTACT_MAILINGSTREET1,
        STA_UtilsStatic.CONTACT_MAILINGPOSTALCODE1,
        STA_UtilsStatic.CONTACT_MAILINGCITY1,
        STA_UtilsStatic.CONTACT_MAILINGSTATE1,
        STA_UtilsStatic.CONTACT_MAILINGCOUNTRY1,
        STA_UtilsStatic.CONTACT_OTHERCITY1,
        account.Id
      );
      insert contact;

      //Product
      Map<String, Schema.RecordTypeInfo> recordTypesProduct = new Map<String, Schema.RecordTypeInfo>();
      recordTypesProduct = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName();
      Id productRecordTypeId = recordTypesProduct.get(
          STA_UtilsStatic.RECORDTYPE_SERVICE_PRODUCT
        )
        .getRecordTypeId();
      Product2 theProduct = SMC_UTIL_TestUtils.createProductFSL(
        productRecordTypeId,
        STA_UtilsStatic.TEST + 'fillParentOrganisation',
        true
      );

      //Asset
      Map<String, Schema.RecordTypeInfo> recordTypesAsset = new Map<String, Schema.RecordTypeInfo>();
      recordTypesAsset = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName();
      Id assetRecordTypeId = recordTypesAsset.get(
          STA_UtilsStatic.RECORDTYPE_ASSET
        )
        .getRecordTypeId();
      Asset theAsset = SMC_UTIL_TestUtils.createAsset(
        assetRecordTypeId,
        null,
        account.Id,
        contact.Id,
        'TestFillPSO',
        theProduct.Id,
        null,
        'TestFillPSO'
      );
      theAsset.SMC_CommissioningDate__c = Date.today().addDays(-10);
      theAsset.SMC_Shipping_date__c = Date.today().addDays(-10);
      theAsset.InstallDate = Date.today().addDays(10);
      System.assertEquals(null, theAsset.SMC_Parent_service_organisation__c);
      Test.startTest();
      insert theAsset;
      Test.stopTest();
      System.assertEquals(
        'FR',
        [
          SELECT SMC_Parent_service_organisation__c
          FROM Asset
          WHERE Id = :theAsset.Id
        ]
        .SMC_Parent_service_organisation__c
      );
    }
  }

  @isTest
  public static void testManageAssetFromWoliCompleted() {
    User userAdmin = [
      SELECT Id, Bypass_Validation_Rule__c
      FROM User
      WHERE Name = :('admin-' + STA_UtilsStatic.USERNAME_TEST)
    ];
    userAdmin.Bypass_Validation_Rule__c += ';SMC_PreventLocationWithoutAddress';
    update userAdmin;

    System.runAs(userAdmin) {
      PAD.bypassAll = true;
      //Account
      Map<String, Schema.RecordTypeInfo> recordTypesAccount = new Map<String, Schema.RecordTypeInfo>();
      recordTypesAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName();
      Id recordTypeIdAcc = recordTypesAccount.get(
          STA_UtilsStatic.RECORDTYPE_ACCOUNT_CUSTOMER_DEVNAME
        )
        .getRecordTypeId();
      Account account = SMC_UTIL_TestUtils.createAccount(
        recordTypeIdAcc,
        STA_UtilsStatic.TEST + 'ManageAssetFromWoliCompleted',
        STA_UtilsStatic.PICKLIST_ACCOUNT_TYPE_MARKETING_PROSPECT,
        STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY2
      );
      account.SMC_Service_Organization__c = 'FR';
      insert account;

      //Contact
      Contact contact = SMC_UTIL_TestUtils.createContact(
        STA_UtilsStatic.CONTACT_FIRSTNAME1,
        STA_UtilsStatic.CONTACT_LASTNAME1 + 'ManageAssetFromWoliCompleted',
        STA_UtilsStatic.CONTACT_PHONE1,
        STA_UtilsStatic.CONTACT_MOBILEPHONE1,
        'ManageAssetFromWoliCompleted.' + STA_UtilsStatic.CONTACT_EMAIL1,
        STA_UtilsStatic.CONTACT_MAILINGSTREET1,
        STA_UtilsStatic.CONTACT_MAILINGPOSTALCODE1,
        STA_UtilsStatic.CONTACT_MAILINGCITY1,
        STA_UtilsStatic.CONTACT_MAILINGSTATE1,
        STA_UtilsStatic.CONTACT_MAILINGCOUNTRY1,
        STA_UtilsStatic.CONTACT_OTHERCITY1,
        account.Id
      );
      insert contact;

      //Product
      Map<String, Schema.RecordTypeInfo> recordTypesProduct = new Map<String, Schema.RecordTypeInfo>();
      recordTypesProduct = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName();
      Id productRecordTypeId = recordTypesProduct.get(
          STA_UtilsStatic.RECORDTYPE_SERVICE_PRODUCT
        )
        .getRecordTypeId();
      Product2 theProduct = SMC_UTIL_TestUtils.createProductFSL(
        productRecordTypeId,
        STA_UtilsStatic.TEST + 'ManageAssetFromWoliCompleted',
        true
      );

      //Asset
      Map<String, Schema.RecordTypeInfo> recordTypesAsset = new Map<String, Schema.RecordTypeInfo>();
      recordTypesAsset = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName();
      Id assetRecordTypeId = recordTypesAsset.get(
          STA_UtilsStatic.RECORDTYPE_ASSET
        )
        .getRecordTypeId();
      Asset theAsset = SMC_UTIL_TestUtils.createAsset(
        assetRecordTypeId,
        null,
        account.Id,
        contact.Id,
        'TestFillPSO',
        theProduct.Id,
        null,
        'TestFillPSO'
      );
      theAsset.SMC_CommissioningDate__c = Date.today().addDays(-10);
      theAsset.SMC_Shipping_date__c = Date.today().addDays(-10);
      theAsset.InstallDate = Date.today().addDays(10);
      theAsset.Status = STA_UtilsStatic.STATUS_WAREHOUSE;
      insert theAsset;

      WorkType wtDecommissionning = new WorkType(
        SMC_Type__c = STA_UtilsStatic.WT_TYPE_COMMISSIONING,
        Name = 'WT ManageAsset Status',
        EstimatedDuration = 1,
        DurationType = 'Minutes',
        SMC_Service_Product__c = theAsset.Product2Id
      );
      insert new List<WorkType>{ wtDecommissionning };

      WorkOrder wo = new WorkOrder();
      insert wo;

      WorkOrderLineItem woli = new WorkOrderLineItem(
        WorkOrderId = wo.id,
        AssetId = theAsset.id,
        WorkTypeId = wtDecommissionning.id
      );
      woli.Status = 'New';
      insert woli;

      Test.startTest();
      SMC_AP_ManageAsset.manageAssetFromWoliCompleted(
        new Map<String, List<Asset>>{
          STA_UtilsStatic.WT_TYPE_COMMISSIONING => new List<Asset>{ theAsset }
        },
        new Map<Id, WorkOrderLineItem>{ theAsset.Id => woli }
      );
      Test.stopTest();

      System.assertEquals(
        STA_UtilsStatic.ACTIVE,
        [SELECT Status FROM Asset WHERE Id = :theAsset.Id]
        .Status
      );
      PAD.bypassAll = false;
    }
  }

  @isTest
  public static void testManageAssetFromWoliCompletedInstalledType() {
    User userAdmin = [
      SELECT Id, Bypass_Validation_Rule__c
      FROM User
      WHERE Name = :('admin-' + STA_UtilsStatic.USERNAME_TEST)
    ];
    userAdmin.Bypass_Validation_Rule__c += ';SMC_PreventLocationWithoutAddress';
    update userAdmin;

    System.runAs(userAdmin) {
      PAD.bypassAll = true;
      //Account
      Map<String, Schema.RecordTypeInfo> recordTypesAccount = new Map<String, Schema.RecordTypeInfo>();
      recordTypesAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName();
      Id recordTypeIdAcc = recordTypesAccount.get(
          STA_UtilsStatic.RECORDTYPE_ACCOUNT_CUSTOMER_DEVNAME
        )
        .getRecordTypeId();
      Account account = SMC_UTIL_TestUtils.createAccount(
        recordTypeIdAcc,
        STA_UtilsStatic.TEST + 'ManageAssetFromWoliCompletedInstalledType',
        STA_UtilsStatic.PICKLIST_ACCOUNT_TYPE_MARKETING_PROSPECT,
        STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY2
      );
      account.SMC_Service_Organization__c = 'FR';
      insert account;

      //Contact
      Contact contact = SMC_UTIL_TestUtils.createContact(
        STA_UtilsStatic.CONTACT_FIRSTNAME1,
        STA_UtilsStatic.CONTACT_LASTNAME1 + 'ManageAssetFromWoliCompletedInstalledType',
        STA_UtilsStatic.CONTACT_PHONE1,
        STA_UtilsStatic.CONTACT_MOBILEPHONE1,
        'ManageAssetFromWoliCompletedInstalledType.' + STA_UtilsStatic.CONTACT_EMAIL1,
        STA_UtilsStatic.CONTACT_MAILINGSTREET1,
        STA_UtilsStatic.CONTACT_MAILINGPOSTALCODE1,
        STA_UtilsStatic.CONTACT_MAILINGCITY1,
        STA_UtilsStatic.CONTACT_MAILINGSTATE1,
        STA_UtilsStatic.CONTACT_MAILINGCOUNTRY1,
        STA_UtilsStatic.CONTACT_OTHERCITY1,
        account.Id
      );
      insert contact;

      //Product
      Map<String, Schema.RecordTypeInfo> recordTypesProduct = new Map<String, Schema.RecordTypeInfo>();
      recordTypesProduct = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName();
      Id productRecordTypeId = recordTypesProduct.get(
          STA_UtilsStatic.RECORDTYPE_SERVICE_PRODUCT
        )
        .getRecordTypeId();
      Product2 theProduct = SMC_UTIL_TestUtils.createProductFSL(
        productRecordTypeId,
        STA_UtilsStatic.TEST + 'ManageAssetFromWoliCompletedInstalledType',
        true
      );

      //Asset
      Map<String, Schema.RecordTypeInfo> recordTypesAsset = new Map<String, Schema.RecordTypeInfo>();
      recordTypesAsset = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName();
      Id assetRecordTypeId = recordTypesAsset.get(
          STA_UtilsStatic.RECORDTYPE_ASSET
        )
        .getRecordTypeId();
      Asset theAsset = SMC_UTIL_TestUtils.createAsset(
        assetRecordTypeId,
        null,
        account.Id,
        contact.Id,
        'TestFillPSO',
        theProduct.Id,
        null,
        'TestFillPSO'
      );
      theAsset.SMC_CommissioningDate__c = Date.today().addDays(-10);
      theAsset.SMC_Shipping_date__c = Date.today().addDays(-10);
      theAsset.InstallDate = Date.today().addDays(10);
      theAsset.Status = STA_UtilsStatic.STATUS_WAREHOUSE;
      insert theAsset;

      WorkType wtInstallation = new WorkType(
        //SMC_Type__c = STA_UtilsStatic.WT_TYPE_INSTALLATION,
        SMC_Type__c = STA_UtilsStatic.WT_TYPE_COMMISSIONING,
        Name = 'WT ManageAsset Status',
        EstimatedDuration = 1,
        DurationType = 'Minutes',
        SMC_Service_Product__c = theAsset.Product2Id
      );
      insert new List<WorkType>{ wtInstallation };

      WorkOrder wo = new WorkOrder();
      insert wo;

      WorkOrderLineItem woli = new WorkOrderLineItem(
        WorkOrderId = wo.id,
        AssetId = theAsset.id,
        WorkTypeId = wtInstallation.id
      );
      woli.Status = 'New';
      woli.StartDate = Date.today().addDays(-1);
      insert woli;
      
      Test.startTest();
      SMC_AP_ManageAsset.manageAssetFromWoliCompletedInstalledType(
        new Map<String, List<Asset>>{
          STA_UtilsStatic.WT_TYPE_INSTALLATION => new List<Asset>{ theAsset }
        },
        new Map<Id, WorkOrderLineItem>{ theAsset.Id => woli }
      );
      Test.stopTest();

      System.assertEquals(
        STA_UtilsStatic.STATUS_INSTALLED,[SELECT Status FROM Asset WHERE Id = :theAsset.Id].Status
      );
      DateTime dateExpected = [SELECT StartDate FROM WorkOrderLineItem WHERE Id =:woli.Id].StartDate;
      System.assertEquals(
        dateExpected, [SELECT InstallDate FROM Asset WHERE Id = :theAsset.Id].InstallDate
      );
      PAD.bypassAll = false;
    }
  }


  /**
   * @description : test SMC_AP_ManageAsset.fillAccountSBOM() and SMC_AP_ManageAsset.fillDateSBOM()
   * @author Denis PHAM (Modis) | 28-04-2020
   **/
  @isTest
  public static void testFillAccountAndDateSBOM() {
    User userAdmin = [
      SELECT Id
      FROM User
      WHERE Name = :('admin-' + STA_UtilsStatic.USERNAME_TEST)
    ];

    System.runAs(userAdmin) {
      PAD.bypassAll = true;

      Id productRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName()
        .get(STA_UtilsStatic.RECORDTYPE_SERVICE_PRODUCT)
        .getRecordTypeId();
      Id productSparePartRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName()
      .get(STA_UtilsStatic.RECORDTYPE_SPARE_PART_PRODUCT)
      .getRecordTypeId();

      Product2 theProduct = SMC_UTIL_TestUtils.createProductFSL(
        productRecordTypeId,
        STA_UtilsStatic.TEST +
        '-' +
        STA_UtilsStatic.AC_INPUT_CAPACITOR,
        true
      );
      theProduct.SMC_AC_in_CAPA_Replacement_freq_years__c = 1;
      theProduct.SMC_AC_out_CAPA_Replacement_freq_years__c = 2;
      theProduct.SMC_DC_CAPA_Replacement_frequency_years__c = 3;
      theProduct.SMC_FAN_Replacement_freq_years__c = 4;
      theProduct.SMC_POWER_SUPPLY_Replacement_freq_years__c = 5;
      // insert new List<Product2>{ theProduct };

      Product2 theProductSparePart = SMC_UTIL_TestUtils.createProductFSL(
        productSparePartRecordTypeId,
        STA_UtilsStatic.TEST + '_sparePart',
        true
      );
      insert new List<Product2>{ theProductSparePart };

      Product2 theProductChild = SMC_UTIL_TestUtils.createProductFSL(
        productRecordTypeId,
        STA_UtilsStatic.TEST,
        true
      );
      theProductChild.SMC_Spare_Part_Code__c = theProductSparePart.Id;
      insert new List<Product2>{ theProduct, theProductChild };

      

      //Account
      Map<String, Schema.RecordTypeInfo> recordTypesAccount = new Map<String, Schema.RecordTypeInfo>();
      recordTypesAccount = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName();
      Id recordTypeIdAcc = recordTypesAccount.get(
          STA_UtilsStatic.RECORDTYPE_ACCOUNT_CUSTOMER_DEVNAME
        )
        .getRecordTypeId();
      Account account = SMC_UTIL_TestUtils.createAccount(
        recordTypeIdAcc,
        STA_UtilsStatic.TEST + 'findFrequency',
        STA_UtilsStatic.PICKLIST_ACCOUNT_TYPE_MARKETING_PROSPECT,
        STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY2
      );
      insert account;

      //Contact
      Contact contact = SMC_UTIL_TestUtils.createContact(
        STA_UtilsStatic.CONTACT_FIRSTNAME1,
        'deDuplcateContact' + STA_UtilsStatic.CONTACT_LASTNAME1,
        null,
        null,
        'deDuplcateContact' + STA_UtilsStatic.CONTACT_EMAIL1,
        STA_UtilsStatic.CONTACT_MAILINGSTREET1,
        STA_UtilsStatic.CONTACT_MAILINGPOSTALCODE1,
        STA_UtilsStatic.CONTACT_MAILINGCITY1,
        STA_UtilsStatic.CONTACT_MAILINGSTATE1,
        STA_UtilsStatic.CONTACT_MAILINGCOUNTRY1,
        STA_UtilsStatic.CONTACT_OTHERCITY1,
        account.Id
      );
      insert contact;

      Id assetRecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName()
        .get(STA_UtilsStatic.RECORDTYPE_ASSET)
        .getRecordTypeId();
      Asset theAssetAcin = SMC_UTIL_TestUtils.createAsset(
        assetRecordTypeId,
        null,
        account.Id,
        contact.Id,
        STA_UtilsStatic.TEST + ' TestFrequency ACIN',
        theProduct.Id,
        null,
        '004-1'
      );
      insert theAssetAcin;

      PAD.bypassAll = false;

      Test.startTest();

      List<Asset> assetBOMToInsert = new List<Asset>();
      Map<Id, Asset> mapAsset = new Map<Id, Asset>();

      Id assetBOMRecordTypeId = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName()
      .get(STA_UtilsStatic.RECORDTYPE_ASSET_RELATED_OBJECT)
      .getRecordTypeId();

      Asset parentAsset = [SELECT Id from Asset WHERE Name LIKE '%TestFrequency ACIN'][0];
      Product2 product = [SELECT Id from Product2 WHERE Name LIKE '%_sparePart'][0];

      Asset theAssetBOMAcin = SMC_UTIL_TestUtils.createAsset(
        assetBOMRecordTypeId,
        parentAsset.Id,
        null,
        null,
        STA_UtilsStatic.TEST + ' TestFrequency ACIN SBOM',
        product.Id,
        null,
        '004-2'
      );
      theAssetBOMAcin.InstallDate = Date.today();
      theAssetBOMAcin.Quantity = 3;
      theAssetBOMAcin.SMC_Next_replacement_date__c =  Date.today();
      theAssetBOMAcin.SMC_Component_Warranty_End_Date__c = Date.today();
      theAssetBOMAcin.SMC_Group_Type__c = STA_UtilsStatic.AC_INPUT_CAPACITOR;


      assetBOMToInsert.add(theAssetBOMAcin);
      SMC_AP_ManageAsset.fillAccountSBOM(assetBOMToInsert);

      insert assetBOMToInsert;

      mapAsset.put(assetBOMToInsert[0].Id, assetBOMToInsert[0]);
      SMC_AP_ManageAsset.fillDateSBOM(mapAsset);

      Asset assetBOM = [SELECT Id, Name, SMC_theoretical_next_replacement_date__c, SMC_Manufacturing_date__c, InstallDate, SMC_Next_replacement_date__c from Asset WHERE Name LIKE '%TestFrequency ACIN SBOM'][0];

      Test.stopTest();

      System.assertNotEquals(
        null,
        assetBOMToInsert[0].AccountId
      );
      
      System.assertNotEquals(
        null,
        assetBOM.SMC_theoretical_next_replacement_date__c
      );
    }
  }
}