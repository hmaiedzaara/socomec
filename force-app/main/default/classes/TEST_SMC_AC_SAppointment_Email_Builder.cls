/**
* @File Name          : TEST_SMC_AC_SAppointment_Email_Builder.cls
* @Description        :
* @Author             : Vincent RECASENS (Modis)
* @Group              :
* @Last Modified By   : Vincent RECASENS (Modis)
* @Last Modified On   : 09-24-2020
* @Modification Log   :
* Ver       Date            Author      		    Modification
* 1.0    04/05/2020   Vincent RECASENS (Modis)     Initial Version
**/
@Istest
public with sharing class TEST_SMC_AC_SAppointment_Email_Builder {
    /**
* @description : test setup
* @author Vincent RECASENS (Modis) | 07-10-2020
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
            insert new List<Product2>{ spare1 };
                
                //Account
                Id recordTypeIdStandard = [
                    SELECT Id
                    FROM RecordType
                    WHERE
                    DeveloperName = :STA_UtilsStatic.RECORDTYPE_ACCOUNT_CUSTOMER_DEVNAME
                    LIMIT 1
                ]
                .get(0)
                .Id;
            Account accountStandard = SMC_UTIL_TestUtils.createAccount(
                recordTypeIdStandard,
                STA_UtilsStatic.TEST + '_Standard',
                STA_UtilsStatic.PICKLIST_ACCOUNT_TYPE_MARKETING_PROSPECT,
                STA_UtilsStatic.ACCOUNT_BILLINGCOUNTRY2
            );
            insert accountStandard;
            
            //Contact
            Contact standardContact = SMC_UTIL_TestUtils.createContact(
                STA_UtilsStatic.CONTACT_FIRSTNAME1 + '_Standard',
                STA_UtilsStatic.CONTACT_LASTNAME1 + '_Standard',
                STA_UtilsStatic.CONTACT_PHONE1,
                STA_UtilsStatic.CONTACT_MOBILEPHONE1,
                STA_UtilsStatic.CONTACT_EMAIL1,
                STA_UtilsStatic.CONTACT_MAILINGSTREET1,
                STA_UtilsStatic.CONTACT_MAILINGPOSTALCODE1,
                STA_UtilsStatic.CONTACT_MAILINGCITY1,
                STA_UtilsStatic.CONTACT_MAILINGSTATE1,
                STA_UtilsStatic.CONTACT_MAILINGCOUNTRY1,
                '',
                accountStandard.Id
            );
            insert new List<Contact>{ standardContact };
                
                Id assetrecordTypeid = Schema.SObjectType.Asset.getRecordTypeInfosByDeveloperName()
                .get(STA_UtilsStatic.RECORDTYPE_ASSET)
                .getRecordTypeId();
            Asset asset1 = SMC_UTIL_TestUtils.createAsset(
                assetrecordTypeid,
                null,
                'ass1',
                spare1.id,
                null,
                'ass1'
            );
            asset1.AccountId = accountStandard.Id;
            asset1.ContactId = standardContact.Id;
            insert new List<Asset>{ asset1 };
                }
    }
    
    /**
* @description : test SMC_AC_SAppointment_Email_Builder.getWorkOrder()
* @author Vincent RECASENS (Modis) | 07-10-2020
**/
    @istest
    public static void testGetWorkorder() {
        User userStandard = [
            SELECT Id
            FROM User
            WHERE Name = :('standard-' + STA_UtilsStatic.USERNAME_TEST)
        ];
        Asset asset1;
        WorkOrder wo1;                
        List<WorkOrder> resultList = new List<WorkOrder>();
        System.runAs(userStandard){
            asset1 = [SELECT Id FROM Asset WHERE Name = 'ass1'];
            wo1 = SMC_UTIL_TestUtils.createWorkOrder(asset1.id);
            wo1.Street = '1 Rue de Westhouse';
            wo1.PostalCode = '67230';
            wo1.City = 'Benfeld';
            wo1.CountryCode = 'FR';
            insert new List<workOrder>{ wo1 };
            // Workorder wo = new Workorder();
            // // Workorder wo2 = new Workorder();
            // insert new List<WorkOrder>{wo};//, wo2};
            WorkOrderLineItem woli1 = new WorkOrderLineItem(
              WorkOrderId = wo1.id,
              Duration = 4,
              DurationType = 'Hours'
            );
            // WorkOrderLineItem woli2 = new WorkOrderLineItem(
            //   WorkOrderId = wo1.id,
            //   Duration = 3,
            //   DurationType = 'Hours'
            // );
            insert new List<WorkOrderLineItem>{woli1};//, woli2};
                
            ServiceAppointment sa1 = new ServiceAppointment(
                parentRecordId = wo1.id,
                earliestStartTime = DateTime.now().addDays(-5),
                Description = '1'
            );
            insert new List<ServiceAppointment>{ sa1 };

            Test.startTest();
            SMC_AC_SAppointment_Email_Builder inst = new SMC_AC_SAppointment_Email_Builder(
                'WorkOrder#Address',
                sa1.Id
            );
            resultList = inst.findWorkOrder();
            Test.stopTest();
        }
        
        System.assertEquals(
            wo1.Street,
            resultList[0].Street,
            'Street does not match.'
        );
        System.assertEquals(
            wo1.PostalCode,
            resultList[0].PostalCode,
            'PostalCode does not match.'
        );
        System.assertEquals(wo1.City, resultList[0].City, 'City does not match.');
        System.assertEquals(
            wo1.CountryCode,
            resultList[0].CountryCode,
            'CountryCode does not match.'
        );
    }
}