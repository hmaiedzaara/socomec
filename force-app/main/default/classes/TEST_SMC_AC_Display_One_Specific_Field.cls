/**
 * @File Name          : SMC_AC_Display_One_Specific_Field.cls
 * @Description        :
 * @Author             : Tanya SIBONI (Modis)
 * @Group              :
 * @Last Modified By   : Tanya SIBONI (Modis)
 * @Last Modified On   : 09/22/2021
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 **/
@IsTest
public with sharing class TEST_SMC_AC_Display_One_Specific_Field {
  /**
   * @description : test SMC_AC_Display_One_Specific_Field.getField()
   * @author Tanya SIBONI (Modis) | 09/22/2021
   **/
  @isTest
  public static void testgetField() {
        // Generate users
        User userStandard = SMC_UTIL_TestUtils.createTestUser(
            STA_UtilsStatic.PROFILE_SALE_STANDARD
        );
        insert new List<User>{ userStandard };
    

        Id recordTypeId = [
            SELECT Id
            FROM RecordType
            WHERE name = :STA_UtilsStatic.RECORDTYPE_ACCOUNT_CUSTOMER
            LIMIT 1
        ]
        .get(0)
        .Id;
        Account account = SMC_UTIL_TestUtils.createAccount(
            recordTypeId,
            STA_UtilsStatic.TEST,
            STA_UtilsStatic.PICKLIST_ACCOUNT_TYPE_MARKETING_PROSPECT,
            STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY2
        );
        insert account;
    
        // Map<String, Schema.RecordTypeInfo> recordTypesProduct = new Map<String, Schema.RecordTypeInfo>();
        // recordTypesProduct = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName();
        // Id serviceProductRecordTypeId = recordTypesProduct.get(STA_UtilsStatic.RECORDTYPE_SERVICE_PRODUCT).getRecordTypeId();
        // Product2 productNoEOLandNoEEOL =  SMC_UTIL_TestUtils.createServiceProductFSL(
        //         serviceProductRecordTypeId,
        //         STA_UtilsStatic.TEST + 'NoEOLandNoEEOL',
        //         true,
        //         'testProductCode',
        //         STA_UtilsStatic.PRODUCT_MANUFACTEUR_SOC_CP,
        //         STA_UtilsStatic.PRODUCT_RANGE_SOC_CP,
        //         STA_UtilsStatic.PRODUCT_MODEL_SOC_CP,
        //         STA_UtilsStatic.PRODUCT_CONFIGURATION_SOC_CP,               
        //         STA_UtilsStatic.PRODUCT_PHASE_SOC_CP,
        //         STA_UtilsStatic.PRODUCT_POWER_SOC_CP,
        //         'kVA'
        // );
        // productNoEOLandNoEEOL.SMC_Picture1__c = 'test';
        // insert productNoEOLandNoEEOL;
        Test.startTest();
        SMC_AC_Display_One_Specific_Field.Wrapper result = SMC_AC_Display_One_Specific_Field.getField(account.Id,'Account','Name');
        SMC_AC_Display_One_Specific_Field.Wrapper result1 = SMC_AC_Display_One_Specific_Field.getField(account.Id,'Account','SMC_ERPID_EE__c');
        // SMC_AC_Display_One_Specific_Field.Wrapper result2 = SMC_AC_Display_One_Specific_Field.getField(productNoEOLandNoEEOL.Id,'Product2','SMC_Picture_1_Community__c');
        Test.stopTest();
  }
}