/**
 * @File Name          : TEST_SMC_AC_CreateNewAssetAction.cls
 * @Description        :
 * @Author             : Vincent RECASENS (Modis)
 * @Group              :
 * @Last Modified By   : Vincent RECASENS (Modis)
 * @Last Modified On   : 09-21-2020
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    10/104/2019   Vincent RECASENS (Modis)     Initial Version
 **/

@isTest
public without sharing class TEST_SMC_AC_CreateNewAssetAction {
  /**
   * @description : test setup
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  @TestSetup
  static void makeData() {
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
    userStandard.Bypass_Validation_Rule__c = 'SMC_NoEditProduct';
    insert userStandard;

    System.runAs(userStandard) {
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
      Asset oneAsset = SMC_UTIL_TestUtils.createAsset(
        assetRecordTypeId,
        null,
        account.Id,
        contact.Id,
        STA_UtilsStatic.TEST,
        theProduct.Id,
        null,
        '001'
      );
      oneAsset.SerialNumber = '00007';
      insert oneAsset;
    }
  }

  /**
   * @description : test SMC_AC_CreateNewAssetAction.getParentInformation()
   * @author Vincent RECASENS (Modis) | 07-10-2020
   **/
  @IsTest
  static void methodName() {
    User userStandard = [
      SELECT Id
      FROM User
      WHERE Name = :('standard-' + STA_UtilsStatic.USERNAME_TEST)
    ];

    System.runAs(userStandard) {
      Asset ass = [SELECT id, AccountId, product2Id FROM Asset LIMIT 1];
      Product2 prod2 = [
        SELECT id
        FROM Product2
        WHERE id != :ass.Product2Id
        LIMIT 1
      ];
      Test.startTest();
      Asset ass2 = SMC_AC_CreateNewAssetAction.getParentInformation(ass.Id);
      system.assertEquals(
        ass.AccountId,
        ass2.AccountId,
        'Assets are not link as Parent/Child.'
      );
      Test.stopTest();
    }
  }
}