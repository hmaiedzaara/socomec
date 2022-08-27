/**
 * @description       :
 * @author            : Vincent RECASENS (Modis)
 * @group             :
 * @last modified on  : 10-07-2020
 * @last modified by  : Vincent RECASENS (Modis)
 * Modifications Log
 * Ver   Date         Author                     Modification
 * 1.0   10-07-2020   Vincent RECASENS (Modis)   Initial Version
 **/
@IsTest
public class TEST_SMC_AC_WOLI_Aborted_Message {
  @isTest
  public static void testGetWoliInfos() {
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
            //Product
            Id idSpareRecordTypeId = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName()
                .get(STA_UtilsStatic.RECORDTYPE_SERVICE_PRODUCT)
                .getRecordTypeId();
            
            // Product2 spare1 = SMC_UTIL_TestUtils.createProductFSL(
            //   idSpareRecordTypeId,
            //   'spare1',
            //   true
            // );
            // insert new List<Product2>{ spare1 };
            
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
            Id assetrecordTypeid = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName()
                .get(STA_UtilsStatic.RECORDTYPE_ASSET)
                .getRecordTypeId();
            Asset asset1 = SMC_UTIL_TestUtils.createAsset(
                assetrecordTypeid,
                null,
                account.Id,
                contact.Id,
                'ass1',
                null,
                null,
                'ass111'
            );
            insert new List<Asset>{ asset1 };
                
                //Work Order
                WorkOrder wo1 = SMC_UTIL_TestUtils.createWorkOrder(asset1.id);
            insert new List<workOrder>{ wo1 };
                workorderLineItem woli1 = SMC_UTIL_TestUtils.createWorkOrderLineItem(
                    wo1.id,
                    asset1.id
                );
            woli1.duration = 10;
            workorderLineItem woli2 = SMC_UTIL_TestUtils.createWorkOrderLineItem(
                wo1.id,
                asset1.id
            );
            woli2.duration = 15;
            insert new List<workorderLineItem>{ woli1, woli2 };
                
                List<String> result = new List<String>();
            Test.startTest();
            woli1.SMC_Aborted__c = true;
            update woli1;
            Test.stopTest();
            
            result = SMC_AC_WOLI_Aborted_Message.getWoliInfos(wo1.id);
            
            workorderLineItem checkWoli1 = [
                SELECT LineItemNumber
                FROM workorderLineItem
                WHERE Id = :woli1.Id
            ];
            System.assertEquals(checkWoli1.LineItemNumber, result[0]);
        }
  }
}