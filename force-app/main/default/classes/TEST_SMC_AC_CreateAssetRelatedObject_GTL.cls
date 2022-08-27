/*
---------------------------------------------------------------------------
-- - Name : TEST_SMC_AC_CreateAssetRelatedObject_GTL
-- - Author : Vincent RECASENS
-- - Description : This class test SMC_AC_CreateAssetRelatedObject_GTL
--
-- Maintenance History:
--
-- Date 		Name 	Version 	Remarks
-- ----------- 	---- 	------- 	------------------
-- 20-FEB-2019 	VREC	1.0			Initial Version
---------------------------------------------------------------------------
*/

@isTest(isParallel=false)
public without sharing class TEST_SMC_AC_CreateAssetRelatedObject_GTL {
  //20-02-2019 : test -> en attente d'avoir la base installée
  @isTest
  public static void testGetGTLfromAssetId() {
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
    userAdmin.Bypass_Validation_Rule__c = 'SMC_NoEditProduct';
    userAdmin.IsActive = true;
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
      Product2 theProductSparePart = SMC_UTIL_TestUtils.createProductFSL(
        productSparePartRecordTypeId,
        STA_UtilsStatic.TEST + '_sparePart',
        true
      );
      insert new List<Product2>{ theProduct, theProductSparePart };

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
      insert contact;

      PAD.bypassAll = true;
      Asset theAsset = SMC_UTIL_TestUtils.createAsset(
        Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName()
          .get(STA_UtilsStatic.RECORDTYPE_ASSET)
          .getRecordTypeId(),
        null,
        account.Id,
        contact.Id,
        STA_UtilsStatic.TEST,
        theProduct.Id,
        null,
        '001'
      );
      theAsset.SMC_Parent_service_organisation__c = STA_UtilsStatic.PSO_FR;
      theAsset.InstallDate = Date.today();
      theAsset.SMC_CommissioningDate__c = Date.today();
      theAsset.SMC_Manufacturing_date__c = Date.today();
      theAsset.SMC_Shipping_date__c = Date.today();
      insert new List<Asset>{ theAsset };

      PAD.bypassAll = false;
      Test.startTest();
      String resultJSON = SMC_AC_CreateAssetRelatedObject_GTL.getGTLfromAssetId(
        theAsset.Id
      );
      SMC_AC_CreateAssetRelatedObject_GTL.ResultWrapper result = (SMC_AC_CreateAssetRelatedObject_GTL.ResultWrapper) JSON.deserialize(
        resultJSON,
        SMC_AC_CreateAssetRelatedObject_GTL.ResultWrapper.class
      );
      Test.stopTest();
      System.assert(result.isSuccess, 'Creation failed.');
    }
  }
}