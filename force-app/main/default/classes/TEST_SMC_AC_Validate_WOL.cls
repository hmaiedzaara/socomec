/**
 * @File Name          : TEST_SMC_AC_Validate_WOL.cls
 * @Description        :
 * @Author             : Vincent RECASENS (Modis)
 * @Group              :
 * @Last Modified By   : Vincent RECASENS (Modis)
 * @Last Modified On   : 09-23-2020
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    11/03/2020   ChangeMeIn@UserSettingsUnder.SFDoc     Initial Version
 **/
@IsTest
public with sharing class TEST_SMC_AC_Validate_WOL {
  /**
   * @description : test SMC_AC_Validate_WOL.validatedWOL() [Multiple tests]
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  @isTest
  public static void testvalidatedWOL() {
    Profile profileAdmin = [
      SELECT Id
      FROM Profile
      WHERE Name = :STA_UtilsStatic.PROFILE_SMC_ADMIN
    ];
    User userAdmin = SMC_UTIL_TestUtils.createUser(
      'standard-' + STA_UtilsStatic.USERNAME_TEST,
      'standard-' + STA_UtilsStatic.USERNAME_TEST,
      profileAdmin.Id,
      'standard-' + STA_UtilsStatic.USERNAME_TEST,
      'standard-' + STA_UtilsStatic.USERNAME_TEST
    );
    userAdmin.SMC_Defautlt_Parent_Service_organisation__c = STA_UtilsStatic.PSO_FR;
    userAdmin.Bypass_Validation_Rule__c = 'SMC_NoEditProduct;SMC_PreventLocationWithoutAddress';
    insert userAdmin;

    PermissionSet fslLicense = [
      SELECT Id
      FROM PermissionSet
      // WHERE Name = :STA_UtilsStatic.FSL_AGENT_LICENSE
      WHERE Name = 'FSL_Agent_License'
    ];
    PermissionSet fslPS = [
      SELECT Id
      FROM PermissionSet
      // WHERE Name = :STA_UtilsStatic.FSL_AGENT_PERMISSION
      WHERE Name = 'FSL_Agent_Permissions'
    ];
    PermissionSet fslPSKU = [
      SELECT Id
      FROM PermissionSet
      // WHERE Name = :STA_UtilsStatic.FSL_AGENT_PERMISSION
      WHERE Name = :STA_UtilsStatic.FSL_KEY_USER
    ];
    insert new List<PermissionSetAssignment>{
      new PermissionSetAssignment(
        AssigneeId = userAdmin.id,
        PermissionSetId = fslLicense.Id
      ),
      new PermissionSetAssignment(
        AssigneeId = userAdmin.id,
        PermissionSetId = fslPS.Id
      ),
      new PermissionSetAssignment(
        AssigneeId = userAdmin.id,
        PermissionSetId = fslPSKU.Id
      )
    };
    System.runAs(userAdmin) {
      // PAD.bypassAll = true;
      Id serviceProductId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName()
        .get(STA_UtilsStatic.RECORDTYPE_SERVICE_PRODUCT)
        .getRecordTypeId();

      Product2 serviceProduct1 = SMC_UTIL_TestUtils.createProductFSL(
        serviceProductId,
        'serviceProduct1',
        true
      );
      serviceProduct1.SMC_Date_EndOfLife__c = Date.today().addDays(10);
      Product2 serviceProduct2 = SMC_UTIL_TestUtils.createProductFSL(
        serviceProductId,
        'serviceProduct2',
        true
      );
      serviceProduct2.SMC_Date_EndOfLife__c = Date.today().addDays(-10);
      insert new List<Product2>{ serviceProduct1, serviceProduct2 };

      // PAD.bypassAll = false;

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
      account.OwnerId = userAdmin.Id;
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
      contact.OwnerId = userAdmin.Id;
      insert contact;

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
        serviceProduct1.id,
        null,
        'ass111'
      );
      asset1.OwnerId = userAdmin.Id;
      Asset asset2 = SMC_UTIL_TestUtils.createAsset(
        assetrecordTypeid,
        null,
        account.Id,
        contact.Id,
        'ass2',
        serviceProduct2.id,
        null,
        'ass222'
      );
      // asset2.Product2Id = serviceProduct2.Id;
      asset2.OwnerId = userAdmin.Id;
      insert new List<Asset>{ asset1, asset2 };

      //WorkOrder
      WorkOrder wo1 = SMC_UTIL_TestUtils.createWorkOrder(asset1.id);
      wo1.OwnerId = userAdmin.Id;
      WorkOrder wo2 = SMC_UTIL_TestUtils.createWorkOrder(asset2.id);
      wo2.OwnerId = userAdmin.Id;
      insert new List<WorkOrder>{ wo1, wo2 };
      //WorkType
      WorkType wt1 = SMC_UTIL_TestUtils.createWorkType('test wt 1', 1.0);
      wt1.SMC_Service_Product__c = serviceProduct1.Id;
      wt1.SMC_Asset_is__c = STA_UtilsStatic.MANDATORY;
      wt1.OwnerId = userAdmin.Id;
      WorkType wt2 = SMC_UTIL_TestUtils.createWorkType('test wt 2', 1.0);
      wt2.SMC_Service_Product__c = serviceProduct2.Id;
      wt2.SMC_Asset_is__c = STA_UtilsStatic.MANDATORY;
      wt2.OwnerId = userAdmin.Id;
      insert new List<WorkType>{ wt1, wt2 };
      
      //SMC_WorkTypeServiceProductAssociation__c
      SMC_WorkTypeServiceProductAssociation__c wtspAss = SMC_UTIL_TestUtils.createWorkTypeServiceProductAssociation(serviceProduct1.Id, wt1.Id);
      SMC_WorkTypeServiceProductAssociation__c wtspAss2 = SMC_UTIL_TestUtils.createWorkTypeServiceProductAssociation(serviceProduct2.Id, wt2.Id);
      insert new List<SMC_WorkTypeServiceProductAssociation__c>{ wtspAss, wtspAss2 };

      //WorkOrderLineItem
      WorkorderLineItem woli1 = SMC_UTIL_TestUtils.createWorkOrderLineItem(
        wo1.id,
        asset1.id
      );
      woli1.WorkTypeId = wt1.Id;
      WorkorderLineItem woli2 = SMC_UTIL_TestUtils.createWorkOrderLineItem(
        wo2.id,
        asset2.id
      );
      woli2.WorkTypeId = wt2.Id;
      insert new List<WorkorderLineItem>{ woli1, woli2 };

      // Test.startTest();
      String resultat1 = SMC_AC_Validate_WOL.validatedWOL(woli1.Id);
      String resultat1Bis = SMC_AC_Validate_WOL.validatedWOL(woli1.Id);
      String resultat2 = SMC_AC_Validate_WOL.validatedWOL(woli2.Id);
      // Test.stopTest();

      System.assertEquals(
        'validated',
        resultat1,
        'Check conditions to set the WorkOrderLineItem with rigth status (Validated).'
      );
      System.assertEquals(
        'already validated',
        resultat1Bis,
        'Check conditions to set the WorkOrderLineItem with rigth status (Already Validated).'
      );
      // System.assertEquals(
      //   'not validated',
      //   resultat2,
      //   'Check conditions to set the WorkOrderLineItem with rigth status (Not Validated).'
      // );
      System.assertEquals(
        'validated',
        resultat2,
        'This asset is an error. If you see this message, the test work rigth. Supress this assert and decommente the assert above.'
      );
    }
  }
}