/*
-----------------------------------------------------------------------------------
-- - Name : TEST_SMC_AC_CreateRecordFromDatatable
-- - Author : Vincent RECASENS (VRE)
-- - Description : This class test the Apex class SMC_AC_CreateRecordFromDatatable
--
-- Maintenance History:
--
-- Date         Name   Version     Remarks
-- -----------  ----   -------     ----------------------------
-- 19-MAR-2019  VRE    1.0         Initial Version
------------------------------------------------------------------------------------
*/

@isTest
public without sharing class TEST_SMC_AC_CreateRecordFromDatatable {
  /**
  * @description : test setup
  * @author Vincent RECASENS (Modis) | 07-10-2020 
  **/
  @testSetup
  public static void setup() {
    System.debug(
      LoggingLevel.INFO,
      '>>>>>> TEST_SMC_AC_CreateRecordFromDatatable : setup - START'
    );

    Profile profileStandard = [
      SELECT Id
      FROM Profile
      WHERE Name = :STA_UtilsStatic.PROFILE_SALE_STANDARD
    ];
    User userStandard = SMC_UTIL_TestUtils.createUser(
      'standard-' + STA_UtilsStatic.USERNAME_TEST,
      'standard-' + STA_UtilsStatic.USERNAME_TEST,
      profileStandard.Id,
      'standard-' + STA_UtilsStatic.USERNAME_TEST,
      'standard-' + STA_UtilsStatic.USERNAME_TEST
    );
    userStandard.SMC_Defautlt_Parent_Service_organisation__c = STA_UtilsStatic.PSO_FR;
    userStandard.Bypass_Validation_Rule__c = 'SMC_NoEditProduct;SMC_PreventLocationWithoutAddress';
    insert userStandard;

    PermissionSet ps = [
      SELECT Id
      FROM PermissionSet
      WHERE Name = :STA_UtilsStatic.FSL_KEY_USER
    ];
    insert new PermissionSetAssignment(
      AssigneeId = userStandard.id,
      PermissionSetId = ps.Id
    );

    System.runAs(userStandard) {
      PAD.bypassAll = true;

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
      // Product2 theProduct = SMC_UTIL_TestUtils.createProductFSL(productRecordTypeId, STA_UtilsStatic.TEST, true);
      Product2 theServiceProduct = SMC_UTIL_TestUtils.createProductFSL(
        productRecordTypeId,
        STA_UtilsStatic.TEST + '_service',
        true
      );
      Product2 theProductSparePart = SMC_UTIL_TestUtils.createProductFSL(
        productSparePartRecordTypeId,
        STA_UtilsStatic.TEST + '_sparePart',
        true
      );
      insert new List<Product2>{
        theServiceProduct,
        theProductSparePart
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
        STA_UtilsStatic.TEST,
        STA_UtilsStatic.PICKLIST_ACCOUNT_TYPE_MARKETING_PROSPECT,
        STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY2
      );
      account.OwnerId = userStandard.Id;
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
        STA_UtilsStatic.TEST,
        theServiceProduct.Id,
        null,
        '001'
      );
      theAsset.InstallDate = Date.today();
      theAsset.SMC_CommissioningDate__c = Date.today();
      theAsset.SMC_Manufacturing_date__c = Date.today();
      theAsset.SMC_Shipping_date__c = Date.today();
      insert new List<Asset>{ theAsset };

      SMC_GTL__c theGTL = SMC_UTIL_TestUtils.createGTL(
        theServiceProduct.Id,
        STA_UtilsStatic.TEST_DIESE,
        STA_UtilsStatic.GTL_ACTIVE
      );
      theGtl.SMC_Spare_Part__c = theProductSparePart.Id;
      theGtl.SMC_Group__c = STA_UtilsStatic.AC_INPUT_CAPACITOR;
      theGtl.SMC_Option__c = STA_UtilsStatic.FAN_CONTROL;
      theGtl.SMC_Quantity__c = 7;
      theGtl.SMC_Start_Date__c = Date.today();
      theGtl.SMC_ValidityDate__c = Date.today();
      theGtl.SMC_IsServiceComponent__c = 'yes';
      insert new List<SMC_GTL__c>{ theGtl };

      SMC_GtlServiceProductAssociation__c theGTLAssociation = SMC_UTIL_TestUtils.createGTLServiceProductAssociation(
        theServiceProduct.Id,
        theGtl.Id
      );
      insert new List<SMC_GtlServiceProductAssociation__c>{ theGTLAssociation };

      WorkOrder theWorkOrder = SMC_UTIL_TestUtils.createWorkOrder(theAsset.Id);
      insert theWorkOrder;

      WorkOrderLineItem theWorkOrderLineItem = SMC_UTIL_TestUtils.createWorkOrderLineItem(
        theWorkOrder.Id,
        theAsset.Id
      );
      theWorkOrderLineItem.Duration = 1;
      insert theWorkOrderLineItem;

      PAD.bypassAll = false;
    }

    System.debug(
      LoggingLevel.INFO,
      '>>>>>> TEST_SMC_AC_CreateRecordFromDatatable : setup - END'
    );
  }

  /**
  * @description : test SMC_AC_CreateRecordFromDatatable.saveRecord(WorkOrderLineItem)
  * @author Vincent RECASENS (Modis) | 07-10-2020 
  **/
  @isTest
  public static void testForWorkOrderLineItem() {
    System.debug(
      LoggingLevel.INFO,
      '>>>>>> TEST_SMC_AC_CreateRecordFromDatatable : testForWorkOrderLineItem - START'
    );
    User userStandard = [
      SELECT Id
      FROM User
      WHERE Name = :('standard-' + STA_UtilsStatic.USERNAME_TEST)
    ];

    WorkOrderLineItem theWorkOrderLineItem;
    System.runAs(userStandard) {
      Asset theAsset = [
        SELECT Id, AccountId, ContactId
        FROM Asset
        WHERE Name = :STA_UtilsStatic.TEST
      ];
      theWorkOrderLineItem = [
        SELECT Id
        FROM WorkOrderLineItem
        WHERE AssetId = :theAsset.Id
      ];
      List<ProductRequired> result = [
        SELECT Id
        FROM ProductRequired
        WHERE ParentRecordId = :theWorkOrderLineItem.Id
      ];
      System.assertEquals(
        0,
        result.size(),
        'ProductRequired is/are already created.'
      );

      Test.startTest();
      SMC_AC_CreateRecordFromDatatable.saveRecord(
        theWorkOrderLineItem.Id,
        SMC_AC_CreateRecordFromDatatable.getInformations(
          theWorkOrderLineItem.Id,
          0,
          false,
          null
        )
      );
      Test.stopTest();
    }

    List<ProductRequired> resultCheck = [
      SELECT Id
      FROM ProductRequired
      WHERE ParentRecordId = :theWorkOrderLineItem.Id
    ];
    System.assertEquals(1, resultCheck.size(), 'Can\'t save new ProductRequired.');

    System.debug(
      LoggingLevel.INFO,
      '>>>>>> TEST_SMC_AC_CreateRecordFromDatatable : testForWorkOrderLineItem - END'
    );
  }

  /**
  * @description : test SMC_AC_CreateRecordFromDatatable.saveRecord(Asset)
  * @author Vincent RECASENS (Modis) | 07-10-2020 
  **/
  @isTest
  public static void testForAsset() {
    System.debug(
      LoggingLevel.INFO,
      '>>>>>> TEST_SMC_AC_CreateRecordFromDatatable : testForAsset - START'
    );
    User userStandard = [
      SELECT Id
      FROM User
      WHERE Name = :('standard-' + STA_UtilsStatic.USERNAME_TEST)
    ];
    Asset theAsset;
    System.runAs(userStandard) {
      theAsset = [
        SELECT Id, AccountId, ContactId
        FROM Asset
        WHERE Name = :STA_UtilsStatic.TEST
      ];
      List<Asset> result = [
        SELECT Id, AccountId, ContactId
        FROM Asset
        WHERE ParentId = :theAsset.Id
      ];
      System.assertEquals(0, result.size(), 'Parent asset is already created.');

      Test.startTest();
      SMC_AC_CreateRecordFromDatatable.saveRecord(
        theAsset.Id,
        SMC_AC_CreateRecordFromDatatable.getInformations(theAsset.Id, 0, false, null)
      );
      Test.stopTest();
    }

    List<Asset> resultCheck = [SELECT Id FROM Asset WHERE ParentId = :theAsset.Id];
    System.assertEquals(
      1,
      resultCheck.size(),
      'Can\'t save new Asset(ServiceBOM).'
    );

    System.debug(
      LoggingLevel.INFO,
      '>>>>>> TEST_SMC_AC_CreateRecordFromDatatable : testForAsset - END'
    );
  }

  /**
  * @description : test SMC_AC_CreateRecordFromDatatable.saveRecord(Asset)
  * @author Vincent RECASENS (Modis) | 07-10-2020 
  **/
  @isTest
  public static void testForAssetBattery() {
    System.debug(
      LoggingLevel.INFO,
      '>>>>>> TEST_SMC_AC_CreateRecordFromDatatable : testForAsset - START'
    );
    User userStandard = [
      SELECT Id
      FROM User
      WHERE Name = :('standard-' + STA_UtilsStatic.USERNAME_TEST)
    ];

    Account theAccount = [SELECT Id FROM Account LIMIT 1];
    Contact theContact = [SELECT Id FROM Contact WHERE AccountId = :theAccount.Id LIMIT 1];
    System.runAs(userStandard) {
      PAD.bypassAll = true;

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
      // Product2 theProduct = SMC_UTIL_TestUtils.createProductFSL(productRecordTypeId, STA_UtilsStatic.TEST, true);
      Product2 theServiceProduct = SMC_UTIL_TestUtils.createProductFSL(
        productRecordTypeId,
        STA_UtilsStatic.TEST + '_service',
        true
      );
      Product2 theProductSparePart = SMC_UTIL_TestUtils.createProductFSL(
        productSparePartRecordTypeId,
        STA_UtilsStatic.TEST + '_sparePart',
        true
      );
      // Product2 theProduct = SMC_UTIL_TestUtils.createProductFSL(productRecordTypeId, STA_UtilsStatic.TEST, true);
      Product2 theServiceProductBattery = SMC_UTIL_TestUtils.createProductFSL(
        productRecordTypeId,
        STA_UtilsStatic.TEST + '_serviceBattery',
        true
      );
      Product2 theProductSparePartBattery = SMC_UTIL_TestUtils.createProductFSL(
        productSparePartRecordTypeId,
        STA_UtilsStatic.TEST + '_sparePartBattery',
        true
      );
      theProductSparePartBattery.SMC_Technical_Item_Group__c = STA_UtilsStatic.TECHNICAL_ITEM_GROUP_BATTERY;
      insert new List<Product2>{
        theServiceProductBattery,
        theProductSparePartBattery
      };

      Map<String, Schema.RecordTypeInfo> recordTypesAsset = new Map<String, Schema.RecordTypeInfo>();
      recordTypesAsset = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName();
      Id assetRecordTypeId = recordTypesAsset.get(
          STA_UtilsStatic.RECORDTYPE_ASSET
        )
        .getRecordTypeId();
      
      Asset theAssetBattery = SMC_UTIL_TestUtils.createAsset(
        assetRecordTypeId,
        null,
        theAccount.Id,
        theContact.Id,
        STA_UtilsStatic.TEST + '-BATTERY',
        theServiceProductBattery.Id,
        null,
        '001B'
      );
      theAssetBattery.InstallDate = Date.today();
      theAssetBattery.SMC_CommissioningDate__c = Date.today();
      theAssetBattery.SMC_Manufacturing_date__c = Date.today();
      theAssetBattery.SMC_Shipping_date__c = Date.today();
      insert new List<Asset>{ theAssetBattery };

      List<Asset> assets = [
        SELECT Id, AccountId, ContactId
        FROM Asset
        WHERE ParentId = :theAssetBattery.Id
      ];
      System.assertEquals(0, assets.size(), 'Parent asset is already created.');

      PAD.bypassAll = false;

      System.debug('SOQL : ' + [SELECT Id, Name, ProductCode FROM Product2 WHERE RecordTypeId = :productSparePartRecordTypeId AND IsActive = TRUE AND SMC_Technical_Item_Group__c = :STA_UtilsStatic.TECHNICAL_ITEM_GROUP_BATTERY]);
      Test.startTest();
        String result = SMC_AC_CreateRecordFromDatatable.getSparePartNotLinkToGTL(theAssetBattery.Id, 0, null);
      Test.stopTest();
      System.debug('result : ' + result);
      List<SMC_AC_CreateRecordFromDatatable.WrapperDataTableForAsset> resultParsed = 
        (List<SMC_AC_CreateRecordFromDatatable.WrapperDataTableForAsset>) JSON.deserialize(result, List<SMC_AC_CreateRecordFromDatatable.WrapperDataTableForAsset>.class);
      System.assertEquals(
        1,
        resultParsed.size(),
        'Asset(ServiceBOM) not retrieve.'
      );
    }

    System.debug(
      LoggingLevel.INFO,
      '>>>>>> TEST_SMC_AC_CreateRecordFromDatatable : testForAsset - END'
    );
  }
}