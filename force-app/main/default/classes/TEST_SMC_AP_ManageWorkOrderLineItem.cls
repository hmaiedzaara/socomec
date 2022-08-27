/**
 * @File Name          : TEST_SMC_AP_ManageWorkOrderLineItem.cls
 * @Description        :
 * @Author             : Vincent RECASENS (Modis)
 * @Group              :
 * @Last Modified By   : Vincent RECASENS (Modis)
 * @Last Modified On   : 04-09-2021
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    ??/11/2019   Emmanuel BERNIER (Modis)     Initial Version
 **/

@isTest
public with sharing class TEST_SMC_AP_ManageWorkOrderLineItem {
  /**
   * @description : test setup
   * @author Vincent RECASENS (Modis) | 07-15-2020
   **/
  @testSetup
  public static void setup() {
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
      SELECT ID
      FROM PermissionSet
      WHERE Name = :STA_UtilsStatic.FSL_ADMIN_PERMISSION
    ];
    insert new List<PermissionSetAssignment>{
      new PermissionSetAssignment(
        AssigneeId = userStandard.id,
        PermissionSetId = ps.Id
      )
    };

    System.runAs(userStandard) {
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
      Product2 theProductSparePartNew = SMC_UTIL_TestUtils.createProductFSL(
        productSparePartRecordTypeId,
        STA_UtilsStatic.TEST + '_newsparePart',
        true
      );
      insert new List<Product2>{
        theProductBis,
        theProductSparePart,
        theProductSparePartNew
      };
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
      theAsset.Quantity = 1;
      theAsset.SMC_Parent_service_organisation__c = STA_UtilsStatic.PSO_FR;
      theAsset.SMC_Shipping_date__c = Date.today();
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
      theAssetParent.Quantity = 1;
      theAssetParent.Status = STA_UtilsStatic.STATUS_WAREHOUSE;
      theAssetParent.SMC_Shipping_date__c = Date.today().addDays(-14);
      theAssetParent.SMC_CommissioningDate__c = Date.today().addDays(-7);
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
      theAssetBis.Quantity = 1;
      theAssetBis.Status = STA_UtilsStatic.PICKLIST_ASSET_DECOMISSION;
      theAssetBis.SMC_CommissioningDate__c = Date.today();
      theAssetBis.SMC_Shipping_date__c = Date.today();
      insert new List<Asset>{ theAsset, theAssetParent, theAssetBis };
      SMC_GTL__c gtlFine = SMC_UTIL_TestUtils.createGTL(
        theProductSparePart.Id,
        'itemCode1',
        'Active'
      );
      gtlFine.SMC_Group__c = 'FAN';
      gtlFine.SMC_Quantity__c = 1;
      SMC_GTL__c gtlReplace = SMC_UTIL_TestUtils.createGTL(
        theProductSparePart.Id,
        'itemCode1',
        'Active'
      );
      gtlReplace.SMC_Group__c = 'FAN';
      gtlFine.SMC_Quantity__c = 1;
      gtlReplace.SMC_New_Spare_Part__c = theProductSparePartNew.id;
      insert new List<SMC_GTL__c>{ gtlFine, gtlReplace };
      Asset theAssetChild = SMC_UTIL_TestUtils.createAsset(
        assetRelatedObjectRecordTypeId,
        null,
        account.Id,
        contact.Id,
        STA_UtilsStatic.TEST + ' Child',
        theProductSparePartNew.Id,
        null,
        '003'
      );
      theAssetChild.SMC_Logistic_Technical_Guide__c = gtlFine.id;
      theAssetChild.ParentId = theAssetParent.id;
      theAssetChild.Quantity = 1;
      theAssetChild.SMC_Group_Type__c = 'FAN';
      Asset theObsoleteBomChild = SMC_UTIL_TestUtils.createAsset(
        assetRelatedObjectRecordTypeId,
        null,
        account.Id,
        contact.Id,
        STA_UtilsStatic.TEST + ' ChildObso',
        theProductSparePart.Id,
        null,
        '004'
      );
      theObsoleteBomChild.ParentId = theAssetParent.Id;
      theObsoleteBomChild.SMC_Logistic_Technical_Guide__c = gtlReplace.id;
      theObsoleteBomChild.Quantity = 10;
      theObsoleteBomChild.SMC_Group_Type__c = 'FAN';
      insert new List<Asset>{ theAssetChild, theObsoleteBomChild };

      // Location theLocation = new Location();
      // theLocation.Name = 'LocationTest';
      // insert theLocation;
      // Address theAddreess = new Address();
      // theAddreess.Name = 'AddressTest';
      // theAddreess.ParentId = theLocation.Id;
      // insert theAddreess;
      // theLocation.VisitorAddressId = theAddreess.Id;
      // update theLocation;

      PAD.bypassAll = false;
    }
  }
  /**
   * @description : test SMC_AP_ManageWorkOrderLineItem.isLinkedAsset()
   * @author Vincent RECASENS (Modis) | 07-15-2020
   **/
  // @IsTest
  // static void testEolAsset() {
  //   User standardUser = [
  //     SELECT
  //       Id,
  //       Username,
  //       Alias,
  //       FirstName,
  //       LastName,
  //       SMC_Subsdiary_Label__c,
  //       UserType
  //     FROM User
  //     WHERE Email = :('standard-' + STA_UtilsStatic.USERNAME_TEST)
  //   ];

  //   System.runAs(standardUser) {
  //     WorkType wt = new WorkType(
  //       SMC_type__c = STA_UtilsStatic.WT_TYPE_FAN,
  //       Name = 'testWorktype',
  //       EstimatedDuration = 1,
  //       DurationType = 'Minutes'
  //     );
  //     insert wt;
  //     Asset ass = [
  //       SELECT id
  //       FROM Asset
  //       WHERE name = :(STA_UtilsStatic.TEST + ' Parent')
  //       LIMIT 1
  //     ];

  //     WorkOrder wo = new WorkOrder();
  //     insert wo;

  //     Test.startTest();
  //       insert new WorkOrderLineItem(
  //         WorkOrderId = wo.id,
  //         AssetId = ass.id,
  //         WorkTypeId = wt.id
  //       );
  //     Test.stopTest();
  //     list<ProductRequired> prodList = [
  //       SELECT id, Product2Id, product2.Name
  //       FROM ProductRequired
  //     ];
  //     System.assertEquals(2, prodList.size(), 'no fan required');
  //     Boolean newSpare = false;
  //     for (ProductRequired prod : prodList) {
  //       if (prod.Product2.Name == STA_UtilsStatic.TEST + '_newsparePart') {
  //         newSpare = true;
  //       }
  //     }
  //     System.assert(newSpare, 'Newspare part not required');
  //   }
  // }

  /**
   * @description : test SMC_AP_ManageWorkOrderLineItem.handleDecomissionningLineClose() WorkOrderLineItem
   * @author Vincent RECASENS (Modis) | 07-15-2020
   **/
  @IsTest
  static void testDecommission() {
    User standardUser = [
      SELECT
        Id,
        Username,
        Alias,
        FirstName,
        LastName,
        SMC_Subsdiary_Label__c,
        UserType
      FROM User
      WHERE Email = :('standard-' + STA_UtilsStatic.USERNAME_TEST)
    ];

    System.runAs(standardUser) {
      WorkType wt = new WorkType(
        SMC_type__c = STA_UtilsStatic.WT_TYPE_DECOMMISSIONNING,
        Name = 'testWorktype',
        EstimatedDuration = 1,
        DurationType = 'Minutes'
      );
      insert wt;
      Asset ass = [
        SELECT id, Product2Id
        FROM Asset
        WHERE name = :(STA_UtilsStatic.TEST + ' Parent')
        LIMIT 1
      ];

      //SMC_WorkTypeServiceProductAssociation__c
      SMC_WorkTypeServiceProductAssociation__c wtspAss = SMC_UTIL_TestUtils.createWorkTypeServiceProductAssociation(ass.Product2Id, wt.Id);
      insert wtspAss;

      WorkOrder wo = new WorkOrder();
      insert wo;

      WorkOrderLineItem woli1 = new WorkOrderLineItem(
        WorkOrderId = wo.id,
        AssetId = ass.id,
        WorkTypeId = wt.id
      );
      insert woli1;
      WorkOrder wo2 = new WorkOrder();
      insert wo2;

      WorkOrderLineItem woli2 = new WorkOrderLineItem(
        WorkOrderId = wo2.id,
        AssetId = ass.id,
        WorkTypeId = wt.id
      );
      insert woli2;
      Test.startTest();
      woli1.Status = 'Completed';
      woli1.SMC_Sub_status__c = 'SMC_Completed';
      update woli1;
      Test.stopTest();
      WorkOrderLineItem woli2res = [
        SELECT id, status, SMC_Sub_status__c
        FROM WorkOrderLineItem
        WHERE id = :woli2.id
        LIMIT 1
      ];
      System.assertEquals(
        'SMC_Cancelled',
        woli2res.SMC_Sub_status__c,
        'substatus not canceled'
      );
      System.assertEquals('Completed', woli2res.Status, 'status not completed');
      Asset ass2 = [
        SELECT id, Status
        FROM Asset
        WHERE name = :(STA_UtilsStatic.TEST + ' Parent')
        LIMIT 1
      ];
      System.assertEquals(
        STA_UtilsStatic.PICKLIST_ASSET_DECOMISSION,
        ass2.Status,
        'Status of the asset was not updated'
      );
    }
  }

  /**
   * @description : test SMC_AP_ManageWorkOrderLineItem.handleDecomissionningLineClose() Asset
   * @author Vincent RECASENS (Modis) | 07-15-2020
   **/
  @IsTest
  static void testDecommissionAsset() {
    User standardUser = [
      SELECT
        Id,
        Username,
        Alias,
        FirstName,
        LastName,
        SMC_Subsdiary_Label__c,
        UserType
      FROM User
      WHERE Email = :('standard-' + STA_UtilsStatic.USERNAME_TEST)
    ];

    System.runAs(standardUser) {
      WorkType wt = new WorkType(
        SMC_type__c = STA_UtilsStatic.WT_TYPE_DECOMMISSIONNING,
        Name = 'testWorktype',
        EstimatedDuration = 1,
        DurationType = 'Minutes'
      );
      insert wt;
      Asset ass = [
        SELECT id, Product2Id
        FROM Asset
        WHERE name = :(STA_UtilsStatic.TEST + ' Parent')
        LIMIT 1
      ];

      //SMC_WorkTypeServiceProductAssociation__c
      SMC_WorkTypeServiceProductAssociation__c wtspAss = SMC_UTIL_TestUtils.createWorkTypeServiceProductAssociation(ass.Product2Id, wt.Id);
      insert wtspAss;

      WorkOrder wo = new WorkOrder();
      insert wo;

      WorkOrderLineItem woli1 = new WorkOrderLineItem(
        WorkOrderId = wo.id,
        AssetId = ass.id,
        WorkTypeId = wt.id
      );
      insert woli1;
      WorkOrder wo2 = new WorkOrder();
      insert wo2;

      WorkOrderLineItem woli2 = new WorkOrderLineItem(
        WorkOrderId = wo2.id,
        AssetId = ass.id,
        WorkTypeId = wt.id
      );

      WorkOrderLineItem woli3 = new WorkOrderLineItem(
        WorkOrderId = wo2.id,
        AssetId = ass.id,
        WorkTypeId = wt.id,
        SMC_Labor_time_in_hours__c = 1
      );

      WorkOrderLineItem woli4 = new WorkOrderLineItem(
        WorkOrderId = wo2.id,
        AssetId = ass.id,
        WorkTypeId = wt.id
      );
      insert new List<WorkOrderLineItem>{ woli2, woli3, woli4 };

      Id sparePartId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName()
        .get(STA_UtilsStatic.RECORDTYPE_SPARE_PART_PRODUCT)
        .getRecordTypeId();

      Product2 sparePart1 = SMC_UTIL_TestUtils.createProductFSL(
        sparePartId,
        'sparePart1',
        true
      );
      insert sparePart1;
      ProductRequired reqProd = new ProductRequired(
        ParentRecordId = woli4.id,
        QuantityRequired = 1,
        Product2Id = sparePart1.Id
      );
      reqProd.SMC_Quantity_Consumed__c = 1;
      insert reqProd;
      Test.startTest();
      ass.Status = STA_UtilsStatic.PICKLIST_ASSET_DECOMISSION;
      update ass;
      Test.stopTest();
      WorkOrderLineItem woli2res = [
        SELECT id, status, SMC_Sub_status__c
        FROM WorkOrderLineItem
        WHERE id = :woli2.id
        LIMIT 1
      ];
      WorkOrderLineItem woli3res = [
        SELECT id, status, SMC_Sub_status__c
        FROM WorkOrderLineItem
        WHERE id = :woli3.id
        LIMIT 1
      ];
      WorkOrderLineItem woli4res = [
        SELECT id, status, SMC_Sub_status__c
        FROM WorkOrderLineItem
        WHERE id = :woli4.id
        LIMIT 1
      ];
      System.assertEquals(
        'SMC_Cancelled',
        woli2res.SMC_Sub_status__c,
        'substatus not canceled'
      );
      System.assertNotEquals(
        'SMC_Cancelled',
        woli3res.SMC_Sub_status__c,
        'substatus not canceled'
      );
      System.assertNotEquals(
        'SMC_Cancelled',
        woli4res.SMC_Sub_status__c,
        'substatus not canceled'
      );
      System.assertEquals('Completed', woli2res.Status, 'status not completed');
    }
  }
  /**
   * @description : test SMC_AP_ManageWorkOrderLineItem.handleDecomissionningLineClose() Asset
   * @author Vincent RECASENS (Modis) | 07-15-2020
   **/
  @IsTest
  static void testCompleteDecommissionWoli() {
    User standardUser = [
      SELECT
        Id,
        Username,
        Alias,
        FirstName,
        LastName,
        SMC_Subsdiary_Label__c,
        UserType
      FROM User
      WHERE Email = :('standard-' + STA_UtilsStatic.USERNAME_TEST)
    ];

    System.runAs(standardUser) {
      PAD.ApexForcedBypass.add(
        STA_UtilsStatic.METHOD_WOLI_UNIQUENESS_CLASS_WOLI_MANAGEMENT
      );
      WorkType wt = new WorkType(
        SMC_type__c = STA_UtilsStatic.WT_TYPE_DECOMMISSIONNING,
        Name = 'testWorktype',
        EstimatedDuration = 1,
        DurationType = 'Minutes'
      );
      insert wt;
      Asset ass = [
        SELECT id, Product2Id
        FROM Asset
        WHERE name = :(STA_UtilsStatic.TEST + ' Parent')
        LIMIT 1
      ];
      //SMC_WorkTypeServiceProductAssociation__c
      SMC_WorkTypeServiceProductAssociation__c wtspAss = SMC_UTIL_TestUtils.createWorkTypeServiceProductAssociation(ass.Product2Id, wt.Id);
      insert wtspAss;

      WorkOrder wo = new WorkOrder();
      insert wo;

      WorkOrderLineItem woli1 = new WorkOrderLineItem(
        WorkOrderId = wo.id,
        AssetId = ass.id,
        WorkTypeId = wt.id
      );
      insert woli1;
      WorkOrder wo2 = new WorkOrder();
      insert wo2;

      WorkOrderLineItem woli2 = new WorkOrderLineItem(
        WorkOrderId = wo2.id,
        AssetId = ass.id,
        WorkTypeId = wt.id
      );

      WorkOrderLineItem woli3 = new WorkOrderLineItem(
        WorkOrderId = wo2.id,
        AssetId = ass.id,
        WorkTypeId = wt.id,
        SMC_Labor_time_in_hours__c = 1
      );

      WorkOrderLineItem woli4 = new WorkOrderLineItem(
        WorkOrderId = wo2.id,
        AssetId = ass.id,
        WorkTypeId = wt.id
      );
      WorkOrderLineItem woli5 = new WorkOrderLineItem(
        WorkOrderId = wo.id,
        AssetId = ass.id,
        WorkTypeId = wt.id
      );
      insert new List<WorkOrderLineItem>{ woli2, woli3, woli4, woli5 };

      Id sparePartId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName()
        .get(STA_UtilsStatic.RECORDTYPE_SPARE_PART_PRODUCT)
        .getRecordTypeId();

      Product2 sparePart1 = SMC_UTIL_TestUtils.createProductFSL(
        sparePartId,
        'sparePart1',
        true
      );
      insert sparePart1;
      ProductRequired reqProd = new ProductRequired(
        ParentRecordId = woli4.id,
        QuantityRequired = 1,
        Product2Id = sparePart1.Id
      );
      reqProd.SMC_Quantity_Consumed__c = 1;
      insert reqProd;
      Test.startTest();
      woli1.Status = STA_UtilsStatic.WOLI_COMPLETED_MAIN_STATUS;
      woli1.SMC_Sub_status__c = STA_UtilsStatic.WOLI_COMPLETED;
      update woli1;
      Test.stopTest();
      WorkOrderLineItem woli2res = [
        SELECT id, status, SMC_Sub_status__c
        FROM WorkOrderLineItem
        WHERE id = :woli2.id
        LIMIT 1
      ];
      WorkOrderLineItem woli3res = [
        SELECT id, status, SMC_Sub_status__c
        FROM WorkOrderLineItem
        WHERE id = :woli3.id
        LIMIT 1
      ];
      WorkOrderLineItem woli4res = [
        SELECT id, status, SMC_Sub_status__c
        FROM WorkOrderLineItem
        WHERE id = :woli4.id
        LIMIT 1
      ];
      WorkOrderLineItem woli5res = [
        SELECT id, status, SMC_Sub_status__c
        FROM WorkOrderLineItem
        WHERE id = :woli5.id
        LIMIT 1
      ];
      System.assertEquals(
        'SMC_Cancelled',
        woli2res.SMC_Sub_status__c,
        'substatus not canceled'
      );
      System.assertNotEquals(
        'SMC_Cancelled',
        woli3res.SMC_Sub_status__c,
        'substatus canceled'
      );
      System.assertNotEquals(
        'SMC_Cancelled',
        woli4res.SMC_Sub_status__c,
        'substatus canceled'
      );
      System.assertNotEquals(
        'SMC_Cancelled',
        woli5res.SMC_Sub_status__c,
        'substatus canceled'
      );
      System.assertEquals(
        STA_UtilsStatic.WOLI_COMPLETED_MAIN_STATUS,
        woli2res.Status,
        'status not completed'
      );
      Asset assRes = [SELECT Id, Status FROM Asset WHERE id = :ass.Id LIMIT 1];
      System.assertEquals(
        STA_UtilsStatic.PICKLIST_ASSET_DECOMISSION,
        assRes.Status,
        'Asset was not decomissionned'
      );
      PAD.ApexForcedBypass.remove(
        STA_UtilsStatic.METHOD_WOLI_UNIQUENESS_CLASS_WOLI_MANAGEMENT
      );
    }
  }

  /**
   * @description : test SMC_AP_ManageWorkOrderLineItem.preventComplete()
   * @author Vincent RECASENS (Modis) | 07-15-2020
   **/
  @IsTest
  static void testComplete_OK() {
    User standardUser = [
      SELECT
        Id,
        Username,
        Alias,
        FirstName,
        LastName,
        SMC_Subsdiary_Label__c,
        UserType
      FROM User
      WHERE Email = :('standard-' + STA_UtilsStatic.USERNAME_TEST)
    ];

    System.runAs(standardUser) {
      WorkType wt = new WorkType(
        SMC_type__c = STA_UtilsStatic.WT_TYPE_FAN,
        Name = 'testWorktype',
        EstimatedDuration = 1,
        DurationType = 'Minutes'
      );
      insert wt;
      Asset ass = [
        SELECT id, Product2Id
        FROM Asset
        WHERE name = :(STA_UtilsStatic.TEST + ' Parent')
        LIMIT 1
      ];

      //SMC_WorkTypeServiceProductAssociation__c
      SMC_WorkTypeServiceProductAssociation__c wtspAss = SMC_UTIL_TestUtils.createWorkTypeServiceProductAssociation(ass.Product2Id, wt.Id);
      insert wtspAss;

      WorkOrder wo = new WorkOrder();
      insert wo;

      WorkOrderLineItem woli = new WorkOrderLineItem(
        WorkOrderId = wo.id,
        AssetId = ass.id,
        WorkTypeId = wt.id
      );
      insert woli;
      Id sparePartId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName()
        .get(STA_UtilsStatic.RECORDTYPE_SPARE_PART_PRODUCT)
        .getRecordTypeId();

      Product2 sparePart1 = SMC_UTIL_TestUtils.createProductFSL(
        sparePartId,
        'sparePart1',
        true
      );
      insert sparePart1;
      ProductRequired reqProd = new ProductRequired(
        ParentRecordId = woli.id,
        QuantityRequired = 1,
        Product2Id = sparePart1.Id
      );
      reqProd.SMC_Quantity_Consumed__c = 1;
      insert reqProd;
      String spareProductName = STA_UtilsStatic.TEST + '_sparePart';
      woli.Status = 'Completed';
      woli.SMC_Sub_status__c = 'SMC_Completed';
      Boolean isError = false;
      Test.startTest();
        try {
          update woli;
        } catch (Exception e) {
          isError = true;
        }
      Test.stopTest();
      System.assert(
        !isError,
        'Woli was closed without consumed product ' +
        [
          SELECT
            Id,
            (
              SELECT id, QuantityRequired, SMC_Quantity_Consumed__c
              FROM ProductsRequired
            )
          FROM WorkOrderLineItem
          WHERE id = :woli.id
        ]
      );
    }
  }

  /**
   * @description : test SMC_AP_ManageWorkOrderLineItem.preventComplete()
   * @author Vincent RECASENS (Modis) | 07-15-2020
   **/
  @IsTest
  static void testComplete_PreventUpdate() {
    User standardUser = [
      SELECT
        Id,
        Username,
        Alias,
        FirstName,
        LastName,
        SMC_Subsdiary_Label__c,
        UserType
      FROM User
      WHERE Email = :('standard-' + STA_UtilsStatic.USERNAME_TEST)
    ];

    System.runAs(standardUser) {
      WorkType wt = new WorkType(
        SMC_type__c = STA_UtilsStatic.WT_TYPE_FAN,
        Name = 'testWorktype',
        EstimatedDuration = 1,
        DurationType = 'Minutes'
      );
      insert wt;
      Asset ass = [
        SELECT id, Product2Id
        FROM Asset
        WHERE name = :(STA_UtilsStatic.TEST + ' Parent')
        LIMIT 1
      ];

      //SMC_WorkTypeServiceProductAssociation__c
      SMC_WorkTypeServiceProductAssociation__c wtspAss = SMC_UTIL_TestUtils.createWorkTypeServiceProductAssociation(ass.Product2Id, wt.Id);
      insert wtspAss;

      WorkOrder wo = new WorkOrder();
      insert wo;

      WorkOrderLineItem woli = new WorkOrderLineItem(
        WorkOrderId = wo.id,
        AssetId = ass.id,
        WorkTypeId = wt.id
      );
      insert woli;
      Id sparePartId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName()
        .get(STA_UtilsStatic.RECORDTYPE_SPARE_PART_PRODUCT)
        .getRecordTypeId();

      Product2 sparePart1 = SMC_UTIL_TestUtils.createProductFSL(
        sparePartId,
        'sparePart1',
        true
      );
      insert sparePart1;
      ProductRequired reqProd = new ProductRequired(
        ParentRecordId = woli.id,
        QuantityRequired = 1,
        Product2Id = sparePart1.Id
      );
      insert reqProd;
      String spareProductName = STA_UtilsStatic.TEST + '_sparePart';
      woli.Status = 'Completed';
      woli.SMC_Sub_status__c = 'SMC_Completed';
      Boolean isError = false;
      Test.startTest();
        try {
          update woli;
        } catch (Exception e) {
          isError = true;
        }
      Test.stopTest();
      System.assert(
        isError,
        'Woli was closed without consumed product ' +
        [
          SELECT
            Id,
            (
              SELECT id, QuantityRequired, SMC_Quantity_Consumed__c
              FROM ProductsRequired
            )
          FROM WorkOrderLineItem
          WHERE id = :woli.id
        ]
      );
    }
  }

  /**
   * @description : test SMC_AP_ManageWorkOrderLineItem.addInstallNoteOnAsset()
   * @author Vincent RECASENS (Modis) | 11-30-2020
   **/
  @isTest
  public static void testAddInstallNoteOnAsset() {
    User standardUser = [
      SELECT
        Id,
        Username,
        Alias,
        FirstName,
        LastName,
        SMC_Subsdiary_Label__c,
        UserType
      FROM User
      WHERE Email = :('standard-' + STA_UtilsStatic.USERNAME_TEST)
    ];

    System.runAs(standardUser) {
      WorkType wt = new WorkType(
        SMC_type__c = STA_UtilsStatic.WT_TYPE_FAN,
        Name = 'testWorktype',
        EstimatedDuration = 1,
        DurationType = 'Minutes'
      );
      insert wt;
      Asset ass = [
        SELECT Id, Product2Id
        FROM Asset
        WHERE name = :(STA_UtilsStatic.TEST + ' Parent')
        LIMIT 1
      ];
      System.assertEquals(
        0,
        [SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId = :ass.Id]
          .size(),
        'There is already a Note linked to the Asset'
      );

      //SMC_WorkTypeServiceProductAssociation__c
      SMC_WorkTypeServiceProductAssociation__c wtspAss = SMC_UTIL_TestUtils.createWorkTypeServiceProductAssociation(ass.Product2Id, wt.Id);
      insert wtspAss;

      WorkOrder wo = new WorkOrder();
      insert wo;

      WorkOrderLineItem woli = new WorkOrderLineItem(
        WorkOrderId = wo.id,
        AssetId = ass.id,
        WorkTypeId = wt.id
      );
      woli.Status = 'New';
      insert woli;
      System.assertEquals(
        0,
        [SELECT Id FROM ContentDocumentLink WHERE LinkedEntityId = :ass.Id]
          .size(),
        'There is already a Note linked to the Asset'
      );

      Test.startTest();
          woli.SMC_Actions_needed__c = STA_UtilsStatic.TEST;
          woli.Status = STA_UtilsStatic.COMPLETED;
          update woli;
      Test.stopTest();
      
      //Check results
      WorkOrderLineItem checkWoli = [
        SELECT LineItemNumber, SMC_Actions_needed__c
        FROM WorkOrderLineItem
        WHERE Id = :woli.Id
      ];
      ContentDocumentLink linkAssetNote = [
        SELECT ContentDocumentId
        FROM ContentDocumentLink
        WHERE LinkedEntityId = :ass.Id
      ];
      ContentNote checker = [
        SELECT Id, Title, Content
        FROM ContentNote
        WHERE Id = :linkAssetNote.ContentDocumentId
      ];
      WorkOrder woContainsWoNumber = [
        SELECT WorkOrderNumber
        FROM WorkOrder
        WHERE Id = :wo.Id
      ];
      String expectedTitle =
        'WO ' +
        woContainsWoNumber.WorkOrderNumber +
        '-' +
        checkWoli.LineItemNumber +
        '.snote';
      String expectedContent = checkWoli.SMC_Actions_needed__c;
      System.assertNotEquals(null, checker, 'There is no Note created.');
      System.assertEquals(
        expectedTitle,
        checker.Title,
        'The Note title dont match.'
      );
      System.assertEquals(
        expectedContent,
        checker.Content.toString(),
        'The Note content (body) dont match.'
      );
    }
  }

  /**
   * @description : test SMC_AP_ManageWorkOrderLineItem.checkServiceProductOnAssetAndWorkType()
   * @author Vincent RECASENS (Modis) | 11-30-2020
   **/
  @isTest
  public static void testCheckServiceProductOnAssetAndWorkType() {
    User standardUser = [
      SELECT
        Id,
        Username,
        Alias,
        FirstName,
        LastName,
        SMC_Subsdiary_Label__c,
        UserType
      FROM User
      WHERE Email = :('standard-' + STA_UtilsStatic.USERNAME_TEST)
    ];

    System.runAs(standardUser) {
      Asset ass = [
        SELECT Id, Product2Id
        FROM Asset
        WHERE Name = :STA_UtilsStatic.TEST
        LIMIT 1
      ];
      WorkType wtOK = new WorkType(
        SMC_type__c = STA_UtilsStatic.WT_TYPE_FAN,
        Name = 'testWorktypeOK',
        EstimatedDuration = 1,
        DurationType = 'Minutes'
      );

      WorkType wtBad = new WorkType(
        SMC_type__c = STA_UtilsStatic.WT_TYPE_FAN,
        Name = 'testWorktypeBad',
        EstimatedDuration = 1,
        DurationType = 'Minutes'
      );
      insert new List<WorkType>{ wtOK, wtBad };

      //SMC_WorkTypeServiceProductAssociation__c
      SMC_WorkTypeServiceProductAssociation__c wtspAss = SMC_UTIL_TestUtils.createWorkTypeServiceProductAssociation(ass.Product2Id, wtOK.Id);
      insert wtspAss;

      WorkOrder wo = new WorkOrder();
      insert wo;

      WorkOrderLineItem woliOK = new WorkOrderLineItem(
        WorkOrderId = wo.id,
        AssetId = ass.id,
        WorkTypeId = wtOK.id
      );
      WorkOrderLineItem woliBad = new WorkOrderLineItem(
        WorkOrderId = wo.id,
        AssetId = ass.id,
        WorkTypeId = wtBad.id
      );

      Boolean checkWoliOK = true;
      Boolean checkWoliBad = true;

      //Woli OK
      try {
        insert woliOK;
        System.assert(true);
      } catch (Exception e) {
        System.debug('Test FAIL : woliOK is not inserted');
        System.assert(false, 'Test FAIL : woliOK is not inserted');
      }

      //Woli BAD
      try {
        insert woliBad;
        System.assert(false, 'Test FAIL : woliBad is inserted');
      } catch (Exception e) {
        System.debug('Test OK : woliBad is not inserted');
        System.assert(true);
      }
    }
  }

  /**
   * @description : test SMC_AP_ManageWorkOrderLineItem.manageAssetFromWoliCompleted()
   * @author Vincent RECASENS (Modis) | 11-30-2020
   **/
  @isTest
  public static void testManageAssetFromWoliCompleted() {
    User standardUser = [
      SELECT
        Id,
        Username,
        Alias,
        FirstName,
        LastName,
        SMC_Subsdiary_Label__c,
        UserType
      FROM User
      WHERE Email = :('standard-' + STA_UtilsStatic.USERNAME_TEST)
    ];

    System.runAs(standardUser) {
      Asset assWarehouse = [
        SELECT Id, Product2Id, Status
        FROM Asset
        WHERE Name = :(STA_UtilsStatic.TEST + ' Parent')
        LIMIT 1
      ];
      Asset assDecommissionning = [
        SELECT Id, Product2Id, Status
        FROM Asset
        WHERE Name = :(STA_UtilsStatic.TEST + '2')
        LIMIT 1
      ];
      WorkType wtWarehouse = new WorkType(
        SMC_Type__c = STA_UtilsStatic.WT_TYPE_COMMISSIONING,
        Name = 'WT ManageAsset Status Warehouse',
        EstimatedDuration = 1,
        DurationType = 'Minutes',
        SMC_Service_Product__c = assWarehouse.Product2Id
      );
      WorkType wtDecommissionning = new WorkType(
        SMC_Type__c = STA_UtilsStatic.WT_TYPE_COMMISSIONING,
        Name = 'WT ManageAsset Status Decommisionning',
        EstimatedDuration = 1,
        DurationType = 'Minutes',
        SMC_Service_Product__c = assDecommissionning.Product2Id
      );
      insert new List<WorkType>{ wtWarehouse, wtDecommissionning };

      //SMC_WorkTypeServiceProductAssociation__c
      SMC_WorkTypeServiceProductAssociation__c wtspAss1 = SMC_UTIL_TestUtils.createWorkTypeServiceProductAssociation(assWarehouse.Product2Id, wtWarehouse.Id);
      SMC_WorkTypeServiceProductAssociation__c wtspAss2 = SMC_UTIL_TestUtils.createWorkTypeServiceProductAssociation(assDecommissionning.Product2Id, wtDecommissionning.Id);
      insert new List<SMC_WorkTypeServiceProductAssociation__c>{wtspAss1, wtspAss2};

      WorkOrder wo = new WorkOrder();
      insert wo;

      WorkOrderLineItem woli = new WorkOrderLineItem(
        WorkOrderId = wo.id,
        AssetId = assWarehouse.id,
        WorkTypeId = wtWarehouse.id
      );
      woli.Status = 'SMC_Open';
      woli.StartDate = Datetime.now();
      woli.EndDate = Datetime.now().addDays(1);
      insert woli;
      WorkOrderLineItem woli2 = new WorkOrderLineItem(
        WorkOrderId = wo.id,
        AssetId = assDecommissionning.id,
        WorkTypeId = wtDecommissionning.id
      );
      woli2.Status = 'SMC_Open';
      woli2.StartDate = Datetime.now();
      insert woli2;

      System.assertEquals(
        STA_UtilsStatic.STATUS_WAREHOUSE,
        assWarehouse.Status
      );
      System.assertEquals(
        STA_UtilsStatic.PICKLIST_ASSET_DECOMISSION,
        assDecommissionning.Status
      );

      Test.startTest();
      WorkOrderLineItem woli1Bis = [
        SELECT Id, Status, SMC_Sub_status__c, EndDate
        FROM WorkOrderLineItem
        WHERE Id = :woli.Id
      ];
      WorkOrderLineItem woli2Bis = [
        SELECT Id, Status, SMC_Sub_status__c, EndDate
        FROM WorkOrderLineItem
        WHERE Id = :woli2.Id
      ];
      woli1Bis.Status = STA_UtilsStatic.WOLI_COMPLETED_MAIN_STATUS;
      woli1Bis.SMC_Sub_status__c = STA_UtilsStatic.WOLI_COMPLETED;

      woli2Bis.Status = STA_UtilsStatic.WOLI_COMPLETED_MAIN_STATUS;
      woli2Bis.SMC_Sub_status__c = STA_UtilsStatic.WOLI_COMPLETED;
      woli2Bis.EndDate = Datetime.now();
      update new List<WorkOrderLineItem>{ woli1Bis, woli2Bis };
      Test.stopTest();

      Asset checkWarehouse = [
        SELECT Id, Status
        FROM Asset
        WHERE Name = :(STA_UtilsStatic.TEST + ' Parent')
      ];
      Asset checkDecommissionning = [
        SELECT Id, Status
        FROM Asset
        WHERE Name = :(STA_UtilsStatic.TEST + '2')
      ];

      System.assertEquals(STA_UtilsStatic.ACTIVE, checkWarehouse.Status);
      System.assertEquals(STA_UtilsStatic.ACTIVE, checkDecommissionning.Status);
    }
  }


  /**
   * @description : test SMC_AP_ManageWorkOrderLineItem.manageAssetFromWoliCompletedInstalationType()
   * @author Tanya SIBONI (Modis) | 06-24-2021
   **/
  @isTest
  public static void testManageAssetFromWoliCompletedInstalationType() {
    User standardUser = [
      SELECT
        Id,
        Username,
        Alias,
        FirstName,
        LastName,
        SMC_Subsdiary_Label__c,
        UserType
      FROM User
      WHERE Email = :('standard-' + STA_UtilsStatic.USERNAME_TEST)
    ];
    
    System.runAs(standardUser) {
      Asset assWarehouse = [
        SELECT Id, Product2Id, Status
        FROM Asset
        WHERE Name = :(STA_UtilsStatic.TEST + ' Parent')
        LIMIT 1
      ];
      Asset assInstalled = [
        SELECT Id, Product2Id, Status
        FROM Asset
        WHERE Name = :(STA_UtilsStatic.TEST )
        LIMIT 1
      ];
      assInstalled.Status = STA_UtilsStatic.STATUS_WAREHOUSE;
      update assInstalled;
      
      WorkType wtWarehouse = new WorkType(
        SMC_Type__c = STA_UtilsStatic.WT_TYPE_COMMISSIONING,
        Name = 'WT ManageAsset Status Warehouse',
        EstimatedDuration = 1,
        DurationType = 'Minutes',
        SMC_Service_Product__c = assWarehouse.Product2Id
      );
      WorkType wtInstalled = new WorkType(
        SMC_Type__c = STA_UtilsStatic.WT_TYPE_INSTALLATION,
        Name = 'WT ManageAsset Status Installed',
        EstimatedDuration = 1,
        DurationType = 'Minutes',
        SMC_Service_Product__c = assInstalled.Product2Id
      );
      
      insert new List<WorkType>{ wtWarehouse, wtInstalled };

      //SMC_WorkTypeServiceProductAssociation__c
      SMC_WorkTypeServiceProductAssociation__c wtspAss1 = SMC_UTIL_TestUtils.createWorkTypeServiceProductAssociation(assWarehouse.Product2Id, wtWarehouse.Id);
      SMC_WorkTypeServiceProductAssociation__c wtspAss2 = SMC_UTIL_TestUtils.createWorkTypeServiceProductAssociation(assInstalled.Product2Id, wtInstalled.Id);
      insert new List<SMC_WorkTypeServiceProductAssociation__c>{wtspAss1, wtspAss2};

      WorkOrder wo = new WorkOrder();
      insert wo;

      WorkOrderLineItem woli = new WorkOrderLineItem(
        WorkOrderId = wo.id,
        AssetId = assWarehouse.id,
        WorkTypeId = wtWarehouse.id
      );
      woli.Status = 'SMC_Open';
      woli.StartDate = Datetime.now().addDays(-4);
      woli.EndDate = Datetime.now().addDays(1);
      insert woli;
      

      WorkOrderLineItem woli2 = new WorkOrderLineItem(
        WorkOrderId = wo.id,
        AssetId = assInstalled.id,
        WorkTypeId = wtInstalled.id
      );
      woli2.Status = 'SMC_Open';
      woli2.StartDate = Datetime.now().addDays(-5);
      insert woli2;

      System.assertEquals(
        STA_UtilsStatic.STATUS_WAREHOUSE,
        assWarehouse.Status
      );
      System.assertEquals(
        STA_UtilsStatic.STATUS_WAREHOUSE,
        assInstalled.Status
      );


      Test.startTest();
      WorkOrderLineItem woli1Bis = [
        SELECT Id, Status, SMC_Sub_status__c, StartDate	,EndDate
        FROM WorkOrderLineItem
        WHERE Id = :woli.Id
      ];
      WorkOrderLineItem woli2Bis = [
        SELECT Id, Status, SMC_Sub_status__c, StartDate	,EndDate
        FROM WorkOrderLineItem
        WHERE Id = :woli2.Id
      ];
      
      woli1Bis.Status = STA_UtilsStatic.WOLI_COMPLETED_MAIN_STATUS;
      woli1Bis.SMC_Sub_status__c = STA_UtilsStatic.WOLI_COMPLETED;

      woli2Bis.Status = STA_UtilsStatic.WOLI_COMPLETED_MAIN_STATUS;
      woli2Bis.SMC_Sub_status__c = STA_UtilsStatic.WOLI_COMPLETED;
      woli2Bis.EndDate = Datetime.now();
      
      update new List<WorkOrderLineItem>{ woli1Bis, woli2Bis };

      Test.stopTest();

      Asset checkWarehouse = [
        SELECT Id, Status
        FROM Asset
        WHERE Name = :(STA_UtilsStatic.TEST + ' Parent')
      ];
      Asset checkInstalled = [
        SELECT Id, Status, InstallDate
        FROM Asset
        WHERE Name = :(STA_UtilsStatic.TEST)
      ];

      System.assertEquals(STA_UtilsStatic.ACTIVE, checkWarehouse.Status);
      System.assertEquals(STA_UtilsStatic.STATUS_INSTALLED, checkInstalled.Status);
      Date expectedDate = Date.today().addDays(-5);
      System.assertEquals(expectedDate, checkInstalled.InstallDate);
    }
  }


  @isTest
  public static void testKeepUniquenessOnWorkOrder() {
    User standardUser = [
      SELECT
        Id,
        Username,
        Alias,
        FirstName,
        LastName,
        SMC_Subsdiary_Label__c,
        UserType
      FROM User
      WHERE Email = :('standard-' + STA_UtilsStatic.USERNAME_TEST)
    ];

    System.runAs(standardUser) {
      Asset ass1 = [
        SELECT Id, Product2Id, Status
        FROM Asset
        WHERE Name = :(STA_UtilsStatic.TEST + ' Parent')
        LIMIT 1
      ];
      WorkType wt = new WorkType(
        SMC_Type__c = STA_UtilsStatic.WT_TYPE_COMMISSIONING,
        Name = 'WT Uniqueness',
        EstimatedDuration = 1,
        DurationType = 'Hours',
        SMC_Service_Product__c = ass1.Product2Id
      );
      insert wt;

      //SMC_WorkTypeServiceProductAssociation__c
      SMC_WorkTypeServiceProductAssociation__c wtspAss = SMC_UTIL_TestUtils.createWorkTypeServiceProductAssociation(ass1.Product2Id, wt.Id);
      insert wtspAss;
      
      WorkOrder wo = new WorkOrder();
      insert wo;

      WorkOrderLineItem woli = new WorkOrderLineItem(
        WorkOrderId = wo.id,
        AssetId = ass1.id,
        WorkTypeId = wt.id
      );
      woli.Status = 'SMC_Open';
      insert woli;

      Boolean checker = false;
      Test.StartTest();
      WorkOrderLineItem woli2 = new WorkOrderLineItem(
        WorkOrderId = wo.id,
        AssetId = ass1.id,
        WorkTypeId = wt.id
      );
      woli2.Status = 'SMC_Open';
      try {
        insert woli2;
      } catch (Exception r) {
        checker = true;
        System.debug('TEST OK!');
      }
      Test.stopTest();

      System.assert(checker, 'The second WOLI is inserted.');
    }
  }

  @isTest
  public static void testFlagWOForWOLICommissionning() {
    User standardUser = [
      SELECT
        Id,
        Username,
        Alias,
        FirstName,
        LastName,
        SMC_Subsdiary_Label__c,
        UserType
      FROM User
      WHERE Email = :('standard-' + STA_UtilsStatic.USERNAME_TEST)
    ];

    System.runAs(standardUser) {
      WorkType wtComm = new WorkType(
        SMC_Type__c = STA_UtilsStatic.WT_TYPE_COMMISSIONING,
        Name = 'WT ManageAsset Status',
        EstimatedDuration = 1,
        DurationType = 'Minutes'
      );
      insert new List<WorkType>{ wtComm };

      WorkOrder wo = new WorkOrder();
      insert wo;

      WorkOrderLineItem woli = new WorkOrderLineItem(
        WorkOrderId = wo.id,
        WorkTypeId = wtComm.id
      );
      woli.Status = 'SMC_Open';
      woli.StartDate = Datetime.now();
      woli.EndDate = Datetime.now().addDays(1);

      Test.startTest();
      insert woli;
      Test.stopTest();

      WorkOrder checkWO = [
        SELECT Id, SMC_Has_not_a_commissioning_WOLI__c
        FROM WorkOrder
        WHERE Id = :wo.Id
      ];
      System.assert(
        !checkWO.SMC_Has_not_a_commissioning_WOLI__c,
        'The flag on the work order is not updated to false.'
      );
    }
  }

  /**
   * @description : test SMC_AP_ManageWorkOrderLineItem.passWOStatusToCompleted()
   **/
  @isTest
  public static void testPassWOStatusToCompleted() {
    User standardUser = [
      SELECT
        Id,
        Username,
        Alias,
        FirstName,
        LastName,
        SMC_Subsdiary_Label__c,
        UserType
      FROM User
      WHERE Email = :('standard-' + STA_UtilsStatic.USERNAME_TEST)
    ];

    System.runAs(standardUser) {
      WorkType workType1 = new WorkType(
        Name = 'Test1',
        EstimatedDuration = 1,
        DurationType = STA_UtilsStatic.WT_TYPE_DURATION_TYPE_HOURS
      );
      WorkType workType2 = new WorkType(
        Name = 'Test2',
        EstimatedDuration = 1,
        DurationType = STA_UtilsStatic.WT_TYPE_DURATION_TYPE_HOURS
      );
      insert new List<WorkType>{ workType1, workType2 };

      WorkOrder wo = new WorkOrder();
      wo.Status = STA_UtilsStatic.STR_NEW;
      insert wo;
      WorkOrder wo2 = new WorkOrder();
      wo2.Status = STA_UtilsStatic.STR_NEW;
      insert wo2;
      WorkOrderLineItem woli = new WorkOrderLineItem(
        WorkOrderId = wo.id,
        WorkTypeId = workType1.id
      );
      woli.Status = STA_UtilsStatic.STR_NEW;
      woli.StartDate = Datetime.now();
      insert woli;
      WorkOrderLineItem woli2 = new WorkOrderLineItem(
        WorkOrderId = wo.id,
        WorkTypeId = workType2.id
      );
      woli2.Status = STA_UtilsStatic.WOLI_COMPLETED_MAIN_STATUS;
      woli2.StartDate = Datetime.now();
      insert woli2;
      
      WorkOrder checkWO2Bis = [
        SELECT Id, Status
        FROM WorkOrder
        WHERE Id = :wo2.Id
      ];

      WorkOrderLineItem woli3 = new WorkOrderLineItem(
        WorkOrderId = wo2.id,
        WorkTypeId = workType1.id
      );
      woli3.Status = STA_UtilsStatic.STR_NEW;
      woli3.StartDate = Datetime.now();
      insert woli3;
      WorkOrderLineItem woli4 = new WorkOrderLineItem(
        WorkOrderId = wo2.id,
        WorkTypeId = workType2.id
      );
      woli4.Status = STA_UtilsStatic.STR_NEW;
      woli4.StartDate = Datetime.now();
      insert woli4;

      Test.startTest();      
      woli.Status = STA_UtilsStatic.WOLI_COMPLETED_MAIN_STATUS;
      
      woli3.Status = STA_UtilsStatic.WOLI_COMPLETED_MAIN_STATUS;
      update new List<WorkOrderLineItem>{ woli, woli3 };
      Test.stopTest();
      
      WorkOrder checkWO = [
        SELECT Id, Status
        FROM WorkOrder
        WHERE Id = :wo.Id
      ];
      WorkOrder checkWO2 = [
        SELECT Id, Status
        FROM WorkOrder
        WHERE Id = :wo2.Id
      ];

      System.assertEquals(STA_UtilsStatic.COMPLETED, checkWO.Status);
      System.assertEquals(STA_UtilsStatic.WO_IN_PROGRESS, checkWO2.Status);
    }
  }
}