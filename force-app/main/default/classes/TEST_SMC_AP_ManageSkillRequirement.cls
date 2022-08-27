/*
--------------------------------------------------------------------------------------
-- - Name          : TEST_SMC_AP_ManageSkillRequirement
-- - Author        : Vincent RECASENS (VRE - Modis)
-- - Description   : This class test the Apex class SMC_AP_ManageSkillRequirement
-- - Project       : Socomec
--
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  -------------------------------------------------------
-- 10-JUL-2019  VR    1.0     Initial version
--------------------------------------------------------------------------------------
*/

@IsTest
public with sharing class TEST_SMC_AP_ManageSkillRequirement {
  /**
   * @description : test setup
   * @author Vincent RECASENS (Modis) | 07-15-2020
   **/
  @testSetup
  public static void setup() {
    System.debug(
      LoggingLevel.INFO,
      '>>>>>> TEST_SMC_AP_ManageSkillRequirement : setup - START'
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
    userAdmin.Bypass_Validation_Rule__c = 'SMC_NoEditProduct;SMC_PreventLocationWithoutAddress';
    insert userAdmin;

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
      Product2 theProduct = SMC_UTIL_TestUtils.createProductFSL(
        productRecordTypeId,
        STA_UtilsStatic.TEST,
        true
      );
      Product2 theProduct2 = SMC_UTIL_TestUtils.createProductFSL(
        productRecordTypeId,
        STA_UtilsStatic.TEST,
        true
      );
      Product2 theProductSparePart = SMC_UTIL_TestUtils.createProductFSL(
        productSparePartRecordTypeId,
        STA_UtilsStatic.TEST + '_sparePart',
        true
      );
      insert new List<Product2>{ theProduct, theProduct2, theProductSparePart };

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

      //WorkType
      WorkType theWorkType = SMC_UTIL_TestUtils.createWorkType(
        'theWorkType',
        10.5
      );
      theWorkType.SMC_Service_Product__c = theProduct.Id;
      insert theWorkType;

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
        theProduct.Id,
        null,
        '001'
      );
      theAsset.SMC_Parent_service_organisation__c = STA_UtilsStatic.PSO_FR;
      Asset theAssetBis = SMC_UTIL_TestUtils.createAsset(
        assetRecordTypeId,
        null,
        account.Id,
        contact.Id,
        STA_UtilsStatic.TEST + 'Bis',
        theProduct2.Id,
        null,
        '002'
      );
      theAsset.SMC_Parent_service_organisation__c = STA_UtilsStatic.PSO_FR;
      insert new List<Asset>{ theAsset, theAssetBis };

      WorkOrder theWorkOrder = SMC_UTIL_TestUtils.createWorkOrder(theAsset.Id);
      insert new List<WorkOrder>{ theWorkOrder };

      //SMC_WorkTypeServiceProductAssociation__c
      SMC_WorkTypeServiceProductAssociation__c wtspAss = SMC_UTIL_TestUtils.createWorkTypeServiceProductAssociation(theAsset.Product2Id, theWorkType.Id);      
      insert wtspAss;      

      WorkOrderLineItem theWorkOrderLineItem = SMC_UTIL_TestUtils.createWorkOrderLineItem(
        theWorkOrder.Id,
        theAsset.Id
      );
      theWorkOrderLineItem.Duration = 1;
      theWorkOrderLineItem.WorkTypeId = theWorkType.Id;
      insert new List<WorkOrderLineItem>{ theWorkOrderLineItem };
    }

    System.debug(
      LoggingLevel.INFO,
      '>>>>>> TEST_SMC_AP_ManageSkillRequirement : setup - END'
    );
  }

  /**
   * @description : test SMC_AP_ManageSkillRequirement.replySkillRequirementOnWorkOrder() by trigger
   * @author Vincent RECASENS (Modis) | 07-15-2020
   **/
  @isTest
  public static void testReplySkillRequirementOnWorkOrder() {
    System.debug(
      LoggingLevel.INFO,
      '>>>>>> TEST_SMC_AP_ManageSkillRequirement : testReplySkillRequirementOnWorkOrder - START'
    );

    User userAdmin = [
      SELECT Id
      FROM User
      WHERE Name = :('admin-' + STA_UtilsStatic.USERNAME_TEST)
    ];

    Skill oneSkill = [SELECT Id FROM Skill LIMIT 1];

    System.runAs(userAdmin) {
      WorkOrder theWorkOrder = [SELECT Id FROM WorkOrder LIMIT 1];
      WorkOrderLineItem theWorkOrderLineItem = [
        SELECT Id
        FROM WorkOrderLineItem
        LIMIT 1
      ];

      //Test
      if (oneSkill != null) {
        //BEFORE
        System.assertEquals(
          0,
          [
              SELECT RelatedRecordId
              FROM SkillRequirement
              WHERE RelatedRecordId = :theWorkOrder.Id
            ]
            .size(),
          'The work order is already linked to the skill. Check work order setup.'
        );

        Test.startTest();
        SkillRequirement theSkillRequirement = SMC_UTIL_TestUtils.createSkillRequirement(
          oneSkill.Id,
          theWorkOrderLineItem.Id
        );
        insert new List<SkillRequirement>{ theSkillRequirement };
        Test.stopTest();

        //AFTER
        System.assertEquals(
          theWorkOrder.Id,
          [
            SELECT RelatedRecordId
            FROM SkillRequirement
            WHERE RelatedRecordId = :theWorkOrder.Id
          ]
          .RelatedRecordId,
          'The work order is not linked to the skill. Check work order setup.'
        );
      }
    }

    System.debug(
      LoggingLevel.INFO,
      '>>>>>> TEST_SMC_AP_ManageSkillRequirement : testReplySkillRequirementOnWorkOrder - END'
    );
  }

  /**
   * @description : test Skil duplication on WorkOrder
   * @author Vincent RECASENS (Modis) | 07-15-2020
   **/
  @isTest
  public static void testDuplicateSkillRequirementOnWorkOrder() {
    // replySkillRequirementOnWorkOrder(List<SkillRequirement> newList)
    User userAdmin = [
      SELECT Id
      FROM User
      WHERE Name = :('admin-' + STA_UtilsStatic.USERNAME_TEST)
    ];

    Skill oneSkill = [SELECT Id FROM Skill LIMIT 1];
    Asset assetBis = [
      SELECT Id
      FROM Asset
      WHERE Name = :STA_UtilsStatic.TEST + 'Bis'
    ];

    System.runAs(userAdmin) {
      WorkOrder theWorkOrder = [SELECT Id FROM WorkOrder LIMIT 1];
      WorkOrderLineItem theWorkOrderLineItem1 = [
        SELECT Id, AssetId
        FROM WorkOrderLineItem
        LIMIT 1
      ];

      WorkOrderLineItem theWorkOrderLineItem2 = SMC_UTIL_TestUtils.createWorkOrderLineItem(
        theWorkOrder.Id,
        assetBis.Id
      );
      theWorkOrderLineItem2.Duration = 1;
      insert new List<WorkOrderLineItem>{ theWorkOrderLineItem2 };

      SkillRequirement theSkillRequirement1 = SMC_UTIL_TestUtils.createSkillRequirement(
        oneSkill.Id,
        theWorkOrderLineItem1.Id
      );
      SkillRequirement theSkillRequirement2 = SMC_UTIL_TestUtils.createSkillRequirement(
        oneSkill.Id,
        theWorkOrderLineItem2.Id
      );

      Boolean isNotError = true;
      Test.startTest();
      try {
        insert new List<SkillRequirement>{ theSkillRequirement1 };
        insert new List<SkillRequirement>{ theSkillRequirement2 };
      } catch (Exception e) {
        System.debug(
          LoggingLevel.INFO,
          'Can\'t insert cause duplicate SkillRequirement on the WorkOrder.'
        );
        System.debug(LoggingLevel.INFO, 'ERROR : ' + e);
        isNotError = false;
      }
      Test.stopTest();

      System.assert(
        isNotError,
        'A work order line item is linked twice at the same skill.'
      );
    }
  }

  //Créer des WorkType à lier avec des WorkOrderLineItem
  @isTest
  public static void testAddMultipleWorkOrderLineItemWithSameWorkOrderAndWorkType() {
    // replySkillRequirementOnWorkOrder(List<SkillRequirement> newList)
    User userAdmin = [
      SELECT Id
      FROM User
      WHERE Name = :('admin-' + STA_UtilsStatic.USERNAME_TEST)
    ];

    System.runAs(userAdmin) {
      WorkOrderLineItem theWorkOrderLineItem0 = [
        SELECT Id, AssetId, WorkOrderId, WorkTypeId
        FROM WorkOrderLineItem
        LIMIT 1
      ];
      Skill oneSkill = [SELECT Id FROM Skill LIMIT 1];

      SkillRequirement theSkillRequirement1 = SMC_UTIL_TestUtils.createSkillRequirement(
        oneSkill.Id,
        theWorkOrderLineItem0.WorkTypeId
      );
      insert new List<SkillRequirement>{ theSkillRequirement1 };

      WorkOrderLineItem theWorkOrderLineItem2 = SMC_UTIL_TestUtils.createWorkOrderLineItem(
        theWorkOrderLineItem0.WorkOrderId,
        theWorkOrderLineItem0.AssetId
      );
      theWorkOrderLineItem2.WorkTypeId = theWorkOrderLineItem0.WorkTypeId;

      Boolean isNotError = false;
      Test.startTest();
      try {
        insert new List<WorkOrderLineItem>{ theWorkOrderLineItem2 };
      } catch (Exception e) {
        System.debug(
          LoggingLevel.INFO,
          'Can\'t insert cause duplicate SkillRequirement on the WorkOrder.'
        );
        System.debug(LoggingLevel.INFO, 'ERROR : ' + e);
        isNotError = true;
      }
      Test.stopTest();

      System.assert(
        isNotError,
        'A work order line item is linked twice at the same skill.'
      );
    }
  }
}