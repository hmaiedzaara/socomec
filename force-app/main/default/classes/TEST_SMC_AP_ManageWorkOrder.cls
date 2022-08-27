/**
 * @File Name          : TEST_SMC_AP_ManageWorkOrder.cls
 * @Description        :
 * @Author             : emmanuel.bernier@modis.com
 * @Group              :
 * @Last Modified By   : Vincent RECASENS (Modis)
 * @Last Modified On   : 02-04-2021
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    ??/11/2019   Emmanuel BERNIER (Modis)     Initial Version
 **/

@isTest
public with sharing class TEST_SMC_AP_ManageWorkOrder {
  // @TestSetup
  // static void setup() {
  // }

  @IsTest
  static void testEolAsset() {
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

    System.runAs(userStandard) {
      Id idSpareRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName()
        .get(STA_UtilsStatic.RECORDTYPE_SERVICE_PRODUCT)
        .getRecordTypeId();

      Product2 spare1 = SMC_UTIL_TestUtils.createProductFSL(
        idSpareRecordTypeId,
        'spare1',
        true
      );
      spare1.SMC_Date_EndOfLife__c = Date.today().addDays(100);
      Product2 spare2 = SMC_UTIL_TestUtils.createProductFSL(
        idSpareRecordTypeId,
        'spare2',
        true
      );
      spare2.SMC_Date_EndOfLife__c = Date.today().addYears(-100);
      insert new List<Product2>{ spare1, spare2 };

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

      Id assetrecordTypeid = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName()
        .get(STA_UtilsStatic.RECORDTYPE_ASSET)
        .getRecordTypeId();
      Asset asset1 = SMC_UTIL_TestUtils.createAsset(
        assetrecordTypeid,
        null,
        account.Id,
        contact.Id,
        'ass1',
        spare1.id,
        null,
        'ass111'
      );
      Asset asset2 = SMC_UTIL_TestUtils.createAsset(
        assetrecordTypeid,
        null,
        account.Id,
        contact.Id,
        'ass2',
        spare2.id,
        null,
        'ass222'
      );
      insert new List<Asset>{ asset1, asset2 };
      WorkOrder wo1 = SMC_UTIL_TestUtils.createWorkOrder(asset1.id);
      WorkOrder wo2 = SMC_UTIL_TestUtils.createWorkOrder(asset2.id);
      insert new List<workOrder>{ wo1, wo2 };
      workorderLineItem woli1 = SMC_UTIL_TestUtils.createWorkOrderLineItem(
        wo1.id,
        asset1.id
      );
      woli1.duration = 10;
      workorderLineItem woli2 = SMC_UTIL_TestUtils.createWorkOrderLineItem(
        wo2.id,
        asset2.id
      );
      woli2.duration = 10;
      insert new List<workorderLineItem>{ woli1, woli2 };
      Test.startTest();
      System.assertEquals(
        false,
        SMC_AP_ManageWorkOrderLineItem.isLinkedAsset(woli1.id).get('eol'),
        'Asset should not be Eol ' + spare1.SMC_Date_EndOfLife__c
      );
      System.assertEquals(
        true,
        SMC_AP_ManageWorkOrderLineItem.isLinkedAsset(woli2.id).get('eol'),
        'Asset should be Eol ' +
        woli2.assetId +
        ' ' +
        asset2.id +
        ' ' +
        asset2.product2id +
        ' ' +
        spare2.id +
        ' ' +
        spare2.SMC_Date_EndOfLife__c
      );
      System.assertEquals(
        false,
        SMC_AP_ManageWorkOrder.isLinkedAssetsEOL(wo1.id),
        'Asset should not be Eol ' + spare1.SMC_Date_EndOfLife__c
      );
      System.assertEquals(
        true,
        SMC_AP_ManageWorkOrder.isLinkedAssetsEOL(wo2.id),
        'Asset should be Eol ' + spare2.SMC_Date_EndOfLife__c
      );
      Test.stopTest();
    }
  }

  @IsTest
  static void testCantCancelLaborWoli() {
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

    System.runAs(userStandard) {
      Id pricebookId = Test.getStandardPricebookId();
      Id idServiceProductRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName()
        .get(STA_UtilsStatic.RECORDTYPE_SERVICE_PRODUCT)
        .getRecordTypeId();
      Id idSpareRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName()
        .get(STA_UtilsStatic.RECORDTYPE_SPARE_PART_PRODUCT)
        .getRecordTypeId();

      Product2 spare1 = SMC_UTIL_TestUtils.createProductFSL(
        idServiceProductRecordTypeId,
        'spare1',
        true
      );
      spare1.SMC_Date_EndOfLife__c = Date.today().addDays(100);
      Product2 spare2 = SMC_UTIL_TestUtils.createProductFSL(
        idSpareRecordTypeId,
        'spare2',
        true
      );
      spare2.SMC_Date_EndOfLife__c = Date.today().addYears(-100);
      insert new List<Product2>{ spare1, spare2 };

      PricebookEntry standardPrice = new PricebookEntry(
        Pricebook2Id = pricebookId,
        Product2Id = spare1.Id,
        UnitPrice = 10000,
        IsActive = true
      );
      insert standardPrice;
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
      //ServiceTerritory
      OperatingHours oh1 = new OperatingHours(Name = 'test1');
      OperatingHours oh2 = new OperatingHours(Name = 'test2');
      insert new List<OperatingHours>{ oh1, oh2 };
      ServiceTerritory terr1 = new ServiceTerritory(
        name = 'testTerritory1',
        OperatingHoursId = oh1.Id,
        IsActive = true
      );
      ServiceTerritory terr2 = new ServiceTerritory(
        name = 'testTerritory2',
        OperatingHoursId = oh2.Id,
        IsActive = true
      );
      insert new List<ServiceTerritory>{ terr1, terr2 };
      //Location
      Schema.Location loc1 = SMC_UTIL_TestUtils.createWarehouse(
        'test Location1'
      );
      loc1.SMC_Service_Territory__c = terr1.id;
      Schema.Location loc2 = SMC_UTIL_TestUtils.createWarehouse(
        'test Location2'
      );
      loc2.SMC_Service_Territory__c = terr2.id;
      insert new List<Schema.Location>{ loc1, loc2 };

      Id assetrecordTypeid = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName()
        .get(STA_UtilsStatic.RECORDTYPE_ASSET)
        .getRecordTypeId();
      Asset asset1 = SMC_UTIL_TestUtils.createAsset(
        assetrecordTypeid,
        null,
        account.Id,
        contact.Id,
        'ass1',
        spare1.id,
        null,
        'ass111'
      );
      asset1.LocationId = loc1.Id;
      Asset asset2 = SMC_UTIL_TestUtils.createAsset(
        assetrecordTypeid,
        null,
        account.Id,
        contact.Id,
        'ass2',
        spare1.id,
        null,
        'ass222'
      );
      asset2.LocationId = loc2.Id;
      insert new List<Asset>{ asset1, asset2 };
      WorkOrder wo1 = SMC_UTIL_TestUtils.createWorkOrder(asset1.id);
      WorkOrder wo2 = SMC_UTIL_TestUtils.createWorkOrder(asset2.id);
      WorkOrder wo3 = SMC_UTIL_TestUtils.createWorkOrder(asset2.id);
      WorkOrder wo4 = SMC_UTIL_TestUtils.createWorkOrder(asset2.id);
      wo4.Status = 'IN PROGRESS';
      insert new List<workOrder>{ wo1, wo2, wo3, wo4 };
      workorderLineItem woli1 = SMC_UTIL_TestUtils.createWorkOrderLineItem(
        wo1.id,
        asset1.id
      );
      woli1.duration = 10;
      workorderLineItem woli2 = SMC_UTIL_TestUtils.createWorkOrderLineItem(
        wo2.id,
        asset2.id
      );
      woli2.duration = 10;
      woli2.SMC_Labor_time_in_hours__c = 60;
      workorderLineItem woli3 = SMC_UTIL_TestUtils.createWorkOrderLineItem(
        wo3.id,
        asset2.id
      );
      woli3.duration = 10;
      woli3.Status = 'Completed';
      woli3.SMC_Sub_status__c = 'SMC_Completed';
      insert new List<workorderLineItem>{ woli1 };
      insert new List<workorderLineItem>{ woli2 };
      insert new List<workorderLineItem>{ woli3 };

      insert new ProductRequired(
        ParentRecordId = woli1.id,
        QuantityRequired = 1,
        SMC_Quantity_Consumed__c = 1,
        Product2Id = spare2.id
      );
      Boolean cancellWoli1 = true;
      try {
        woli1.Status = 'Completed';
        woli1.SMC_Sub_status__c = STA_UtilsStatic.WOLI_CANCELED;
        update woli1;
      } catch (Exception e) {
        cancellWoli1 = false;
      }
      System.assertNotEquals(
        true,
        cancellWoli1,
        'WOLI 1 has been canceled with consumedproducts'
      );
      Boolean cancellWo1 = true;
      try {
        wo1.Status = 'COMPLETED';
        wo1.SMC_Sub_status__c = 'CANCELED';
        update wo1;
      } catch (Exception e) {
        cancellWo1 = false;
      }
      System.assertNotEquals(
        true,
        cancellWo1,
        'WO 1 has been canceled with consumedproducts'
      );
      Boolean cancellWo2 = true;
      try {
        wo2.Status = 'COMPLETED';
        wo2.SMC_Sub_status__c = 'CANCELED';
        update wo2;
      } catch (Exception e) {
        cancellWo2 = false;
      }
      System.assertNotEquals(
        true,
        cancellWo2,
        'WO 2 has been canceled with consumedproducts'
      );
      Boolean cancellWoli2 = true;
      try {
        woli2.Status = 'Completed';
        woli2.SMC_Sub_status__c = STA_UtilsStatic.WOLI_CANCELED;
        update woli2;
      } catch (Exception e) {
        cancellWoli2 = false;
      }
      System.assertNotEquals(
        true,
        cancellWoli2,
        'WOLI 2 has been canceled with consumedproducts'
      );
      Boolean cancellWo3 = true;
      try {
        wo3.Status = 'COMPLETED';
        wo3.SMC_Sub_status__c = 'CANCELED';
        update wo3;
      } catch (Exception e) {
        cancellWo3 = false;
      }
      System.assertNotEquals(
        true,
        cancellWo3,
        'WO3 has been canceled with completed WOLI'
      );

      Boolean cancellWo4 = true;
      try {
        wo4.Status = 'COMPLETED';
        wo4.SMC_Sub_status__c = 'CANCELED';
        update wo4;
      } catch (Exception e) {
        cancellWo4 = false;
      }
      System.assertNotEquals(
        true,
        cancellWo4,
        'WO4 has been canceled but was in progress'
      );
    }
  }

  @IsTest(SeeAllData=true)
  static void testServiceAppointmentStatusSync() {
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
    userStandard.Bypass_Process_Builder__c = 'SMC_ServiceAppointment_On_Update_Create';
    insert userStandard;

    System.runAs(userStandard) {
      Id pricebookId = Test.getStandardPricebookId();
      Id idSpareRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName()
        .get(STA_UtilsStatic.RECORDTYPE_SERVICE_PRODUCT)
        .getRecordTypeId();

      Product2 spare1 = SMC_UTIL_TestUtils.createProductFSL(
        idSpareRecordTypeId,
        'spare1',
        true
      );
      spare1.SMC_Date_EndOfLife__c = Date.today().addDays(100);
      Product2 spare2 = SMC_UTIL_TestUtils.createProductFSL(
        idSpareRecordTypeId,
        'spare2',
        true
      );
      spare2.SMC_Date_EndOfLife__c = Date.today().addYears(-100);
      insert new List<Product2>{ spare1, spare2 };

      PricebookEntry standardPrice = new PricebookEntry(
        Pricebook2Id = pricebookId,
        Product2Id = spare1.Id,
        UnitPrice = 10000,
        IsActive = true
      );
      insert standardPrice;
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
      //ServiceTerritory
      OperatingHours oh = new OperatingHours(Name = 'test');
      insert oh;
      ServiceTerritory terr = new ServiceTerritory(
        name = 'testTerritory',
        OperatingHoursId = oh.Id,
        IsActive = true
      );
      insert terr;
      //Location
      Schema.Location loc = SMC_UTIL_TestUtils.createWarehouse('test Location');
      loc.SMC_Service_Territory__c = terr.id;
      insert loc;

      Id assetrecordTypeid = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName()
        .get(STA_UtilsStatic.RECORDTYPE_ASSET)
        .getRecordTypeId();
      Asset asset1 = SMC_UTIL_TestUtils.createAsset(
        assetrecordTypeid,
        null,
        account.Id,
        contact.Id,
        'ass1',
        spare1.id,
        null,
        'ass111'
      );
      asset1.LocationId = loc.Id;
      insert new List<Asset>{ asset1 };
      WorkOrder wo1 = SMC_UTIL_TestUtils.createWorkOrder(asset1.id);
      WorkOrder wo2 = SMC_UTIL_TestUtils.createWorkOrder(asset1.id);
      insert new List<workOrder>{ wo1, wo2 };

      WorkOrderLineItem woli1 = SMC_UTIL_TestUtils.createWorkOrderLineItem(wo1.Id,asset1.id);
      woli1.SMC_Load_cut_duration__c = 60;
      woli1.Duration = 6;
      woli1.DurationType = 'Hours';
      WorkOrderLineItem woli2 = SMC_UTIL_TestUtils.createWorkOrderLineItem(wo2.Id,asset1.id);
      woli2.SMC_Load_cut_duration__c = 60;
      woli2.Duration = 6;
      woli2.DurationType = 'Hours';
      insert new List<WorkOrderLineItem>{ woli1, woli2 };
      System.debug('SMC_Theoritical_duration__c 1-->' + wo1.SMC_Theoritical_duration__c);
      System.debug('SMC_Theoritical_duration__c 2-->' + wo2.SMC_Theoritical_duration__c);
      ServiceAppointment sa = new ServiceAppointment(
        parentrecordId = wo1.id,
        status = 'none'
      );
      ServiceAppointment sa2 = new ServiceAppointment(
        parentrecordId = wo2.id,
        status = 'none'
      );
      insert new List<ServiceAppointment>{ sa, sa2 };
      sa.Status = 'Scheduled';
      sa2.Status = 'Scheduled';
      update new List<ServiceAppointment>{ sa, sa2 };
      sa.Status = 'Dispatched';
      sa2.Status = 'Dispatched';
      update new List<ServiceAppointment>{ sa, sa2 };
      //insert new AssignedResource(ServiceAppointmentId = sa2.id);
      wo1.status = 'IN PROGRESS';
      update wo1;
      system.assertEquals(
        'In Progress',
        [SELECT status FROM serviceAppointment WHERE id = :sa.id LIMIT 1]
        .status,
        'Wrong status for in progress Wo'
      );

      wo1.status = 'Completed';
      wo1.SMC_Sub_status__c = 'COMPLETED';
      update wo1;
      system.assertEquals(
        'Completed',
        [SELECT status FROM serviceAppointment WHERE id = :sa.id LIMIT 1]
        .status,
        'Wrong status for in progress Wo'
      );
    }
  }

  @IsTest
  static void testAssetDescriptionSyncAndWOStartEndDate() {
    Profile profileStandard = [
      SELECT Id
      FROM Profile
      WHERE Name = :STA_UtilsStatic.PROFILE_SMC_ADMIN
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

    System.runAs(userStandard) {
      Id pricebookId = Test.getStandardPricebookId();
      Id idSpareRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName()
        .get(STA_UtilsStatic.RECORDTYPE_SERVICE_PRODUCT)
        .getRecordTypeId();

      Product2 spare1 = SMC_UTIL_TestUtils.createProductFSL(
        idSpareRecordTypeId,
        'spare1',
        true
      );
      spare1.SMC_Date_EndOfLife__c = Date.today().addDays(100);
      Product2 spare2 = SMC_UTIL_TestUtils.createProductFSL(
        idSpareRecordTypeId,
        'spare2',
        true
      );
      spare2.SMC_Date_EndOfLife__c = Date.today().addYears(-100);
      insert new List<Product2>{ spare1, spare2 };

      PricebookEntry standardPrice = new PricebookEntry(
        Pricebook2Id = pricebookId,
        Product2Id = spare1.Id,
        UnitPrice = 10000,
        IsActive = true
      );
      insert standardPrice;
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
      //ServiceTerritory
      OperatingHours oh = new OperatingHours(Name = 'test');
      insert oh;
      ServiceTerritory terr = new ServiceTerritory(
        name = 'testTerritory',
        OperatingHoursId = oh.Id,
        IsActive = true
      );
      insert terr;
      //Location
      Schema.Location loc = SMC_UTIL_TestUtils.createWarehouse('test Location');
      loc.SMC_Service_Territory__c = terr.id;
      insert loc;

      Id assetrecordTypeid = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName()
        .get(STA_UtilsStatic.RECORDTYPE_ASSET)
        .getRecordTypeId();
      Asset asset1 = SMC_UTIL_TestUtils.createAsset(
        assetrecordTypeid,
        null,
        account.Id,
        contact.Id,
        'ass1',
        spare1.id,
        null,
        'ass111'
      );
      String assetDescription = 'description line 1';
      asset1.LocationId = loc.Id;
      asset1.Description = assetDescription;
      insert new List<Asset>{ asset1 };
      WorkOrder wo1 = SMC_UTIL_TestUtils.createWorkOrder(asset1.id);
      insert new List<workOrder>{ wo1 };
      WorkOrderLineItem woli = SMC_UTIL_TestUtils.createWorkOrderLineItem(
        wo1.Id,
        asset1.Id
      );
      woli.Duration = 1;
      woli.StartDate = Datetime.now();
      woli.EndDate = Datetime.now().addHours(1);
      woli.Status = 'Completed';
      woli.SMC_Sub_status__c = 'SMC_Completed';
      insert woli;
      wo1.Status = 'Completed';
      wo1.SMC_Sub_status__c = 'COMPLETED';
      wo1.SMC_Comment_on_installation__c = 'ligne 2';
      // System.assertEquals(null, wo1.SMC_Sotech_synchro_Completed_date__c);
      //Asset
      System.assertEquals(
        0,
        [
            SELECT Id, ContentDocumentId
            FROM ContentDocumentLink
            WHERE LinkedEntityId = :asset1.Id
          ]
          .size(),
        'Asset has already a note'
      );

      Test.startTest();
      update wo1;
      Test.stopTest();

      //Get ContentNote and link
      ContentDocumentLink theLink = [
        SELECT Id, ContentDocumentId
        FROM ContentDocumentLink
        WHERE LinkedEntityId = :asset1.Id
      ];
      //Asset
      System.assertNotEquals(
        null,
        theLink,
        'Note has not been added to the asset'
      );
    }
  }

  @isTest
  public static void testFillCommentForTechnicianWithAdditionnalInfosFromLocation(){
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
    userStandard.Bypass_Process_Builder__c = 'SMC_ServiceAppointment_On_Update_Create';
    insert userStandard;

    WorkOrder wo1;
    WorkOrder wo2;
    WorkOrder wo3;
    System.runAs(userStandard) {
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
      //ServiceTerritory
      OperatingHours oh1 = new OperatingHours(Name = 'test1');
      OperatingHours oh2 = new OperatingHours(Name = 'test2');
      insert new List<OperatingHours>{ oh1, oh2 };
      ServiceTerritory terr1 = new ServiceTerritory(
        name = 'testTerritory1',
        OperatingHoursId = oh1.Id,
        IsActive = true
      );
      ServiceTerritory terr2 = new ServiceTerritory(
        name = 'testTerritory2',
        OperatingHoursId = oh2.Id,
        IsActive = true
      );
      insert new List<ServiceTerritory>{ terr1, terr2 };
      //Location
      Schema.Location loc1 = SMC_UTIL_TestUtils.createWarehouse(
        'test Location1'
      );
      loc1.SMC_Service_Territory__c = terr1.id;
      loc1.SMC_Site_Account__c = account.id;
      loc1.SMC_AdditionalInfos__c = 'Additionnal Informations Loc1';
      Schema.Location loc2 = SMC_UTIL_TestUtils.createWarehouse(
        'test Location2'
      );
      loc2.SMC_Service_Territory__c = terr2.id;
      loc2.SMC_Site_Account__c = account.id;
      insert new List<Schema.Location>{ loc1, loc2 };

      //Address
      Schema.Address address1 = new Schema.Address();
      address1.ParentId = loc1.Id;
      address1.Latitude = 40.333;
      address1.Longitude = 13.428;
      Schema.Address address2 = new Schema.Address();
      address2.ParentId = loc2.Id;
      address2.Latitude = 41.333;
      address2.Longitude = 13.457;
      insert new List<Schema.Address>{ address1, address2 };

      loc1.SMC_Address__c = address1.Id;
      loc2.SMC_Address__c = address2.Id;
      update new List<Schema.Location>{ loc1, loc2 };

      //Work order
      wo1 = new WorkOrder();
      wo1.AccountId = account.id;
      wo1.LocationId = loc1.id;
      wo2 = new WorkOrder();
      wo2.AccountId = account.id;
      wo2.LocationId = loc2.id;
      wo3 = new WorkOrder();
      wo3.AccountId = account.id;
      wo3.LocationId = loc1.id;
      wo3.SMC_Comment_for_Technician__c = 'Test add';

      Test.startTest();
        insert new List<WorkOrder>{ wo1, wo2, wo3 };
      Test.stopTest();
    }

    WorkOrder checkWo1 = [SELECT Id, SMC_Comment_for_Technician__c FROM WorkOrder WHERE Id = :wo1.Id];
    System.assertEquals('Additionnal Informations Loc1', checkWo1.SMC_Comment_for_Technician__c);
    WorkOrder checkWo2 = [SELECT Id, SMC_Comment_for_Technician__c FROM WorkOrder WHERE Id = :wo2.Id];
    System.assertEquals(null, checkWo2.SMC_Comment_for_Technician__c);
    WorkOrder checkWo3 = [SELECT Id, SMC_Comment_for_Technician__c FROM WorkOrder WHERE Id = :wo3.Id];
    System.assertEquals('Test add\nAdditionnal Informations Loc1', checkWo3.SMC_Comment_for_Technician__c);
  }

  @isTest
  public static void testUpdateServiceAppointmentForDurationModification(){
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
    userStandard.Bypass_Process_Builder__c = 'SMC_ServiceAppointment_On_Update_Create';
    insert userStandard;

    System.runAs(userStandard) {
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

      //Product
      Id idSpareRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName()
        .get(STA_UtilsStatic.RECORDTYPE_SERVICE_PRODUCT)
        .getRecordTypeId();

      Product2 spare1 = SMC_UTIL_TestUtils.createProductFSL(
        idSpareRecordTypeId,
        'spare1',
        true
      );
      Product2 spare2 = SMC_UTIL_TestUtils.createProductFSL(
        idSpareRecordTypeId,
        'spare2',
        true
      );
      insert new List<Product2>{ spare1, spare2 };
      //Asset
      Id assetrecordTypeid = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName()
        .get(STA_UtilsStatic.RECORDTYPE_ASSET)
        .getRecordTypeId();
      Asset asset1 = SMC_UTIL_TestUtils.createAsset(
        assetrecordTypeid,
        null,
        account.Id,
        contact.Id,
        'ass1',
        spare1.id,
        null,
        'ass111'
      );
      Asset asset2 = SMC_UTIL_TestUtils.createAsset(
        assetrecordTypeid,
        null,
        account.Id,
        contact.Id,
        'ass2',
        spare2.id,
        null,
        'ass222'
      );
      insert new List<Asset>{ asset1, asset2 };
      //WorkOrder
      WorkOrder wo1 = SMC_UTIL_TestUtils.createWorkOrder(asset1.id);
      WorkOrder wo2 = SMC_UTIL_TestUtils.createWorkOrder(asset2.id);
      insert new List<workOrder>{ wo1, wo2 };
      //WorkOrderLineItem
      WorkOrderLineItem woli1 = SMC_UTIL_TestUtils.createWorkOrderLineItem(
        wo1.Id,
        asset1.Id
      );
      woli1.Duration = 1;
      woli1.DurationType = 'Hours';
      woli1.StartDate = Datetime.now();
      woli1.EndDate = Datetime.now().addHours(1);
      WorkOrderLineItem woli2 = SMC_UTIL_TestUtils.createWorkOrderLineItem(
        wo2.Id,
        asset2.Id
      );
      woli2.Duration = 6;
      woli2.DurationType = 'Hours';
      woli2.StartDate = Datetime.now();
      woli2.EndDate = Datetime.now().addHours(6);
      insert new List<WorkOrderLineItem>{ woli1, woli2 };
      //ServiceAppointment
      ServiceAppointment sa1 = new ServiceAppointment(
        parentrecordId = wo1.id,
        status = 'none'
      );
      ServiceAppointment sa2 = new ServiceAppointment(
        parentrecordId = wo2.id,
        status = 'none'
      );
      insert new List<ServiceAppointment>{ sa1, sa2 };
      //Check before test
      Map<Id, ServiceAppointment> saInit = new Map<Id, ServiceAppointment>([SELECT Id, Duration, AppointmentNumber FROM ServiceAppointment WHERE Id IN :(new List<Id>{ sa1.Id, sa2.Id })]);
      System.assertEquals(1.00, saInit.get(sa1.Id).Duration, 'Duration 1 is not set.');
      System.assertEquals(6.00, saInit.get(sa2.Id).Duration, 'Duration 2 is not set.');

      Test.startTest();
        //Woli1 - modify duration
        woli1.Duration = 4;
        //Woli2 - modify start and end date
        woli2.StartDate = Datetime.now().addHours(3);
        woli2.EndDate = Datetime.now().addHours(6);
        update new List<WorkOrderLineItem>{ woli1, woli2 };
      Test.stopTest();

      //Check after test
      Map<Id, ServiceAppointment> saChecker = new Map<Id, ServiceAppointment>([SELECT Id, Duration FROM ServiceAppointment WHERE Id IN :(new List<Id>{ sa1.Id, sa2.Id })]);
      System.assertEquals(240.00, saChecker.get(sa1.Id).Duration, 'Duration 1 is not updated.');
      System.assertEquals(6.00, saChecker.get(sa2.Id).Duration, 'Duration 2 is updated.');

    }

  }
}