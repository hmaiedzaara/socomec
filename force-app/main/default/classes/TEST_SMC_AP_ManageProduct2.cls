@isTest
public with sharing class TEST_SMC_AP_ManageProduct2 {
    @isTest
    public static void testcheckActiveProduct(){
        User userStandard = SMC_UTIL_TestUtils.createTestUser(
        STA_UtilsStatic.PROFILE_SALE_STANDARD
        );
        insert new List<User>{ userStandard };
        System.runAs(userStandard) {
            Map<String, Schema.RecordTypeInfo> recordTypesProduct = new Map<String, Schema.RecordTypeInfo>();
            recordTypesProduct = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName();
            Id serviceProductRecordTypeId = recordTypesProduct.get(STA_UtilsStatic.RECORDTYPE_SERVICE_PRODUCT).getRecordTypeId();
            Id salesProductRecordTypeId = recordTypesProduct.get(STA_UtilsStatic.RECORDTYPE_SALES_PRODUCT).getRecordTypeId();
           
            Product2 productNoEOLandNoEEOL =  SMC_UTIL_TestUtils.createServiceProductFSL(
                serviceProductRecordTypeId,
                STA_UtilsStatic.TEST + 'NoEOLandNoEEOL',
                true,
                'testProductCode',
                STA_UtilsStatic.PRODUCT_MANUFACTEUR_SOC_CP,
                STA_UtilsStatic.PRODUCT_RANGE_SOC_CP,
                STA_UtilsStatic.PRODUCT_MODEL_SOC_CP,
                STA_UtilsStatic.PRODUCT_CONFIGURATION_SOC_CP,               
                STA_UtilsStatic.PRODUCT_PHASE_SOC_CP,
                STA_UtilsStatic.PRODUCT_POWER_SOC_CP,
                'kVA'
            );
            productNoEOLandNoEEOL.SMC_Date_EndOfLife__c = null;
            productNoEOLandNoEEOL.SMC_Date_ExtendedEndOfLife__c = null;
            Product2 productEOLgreaterThanToday =  SMC_UTIL_TestUtils.createServiceProductFSL(
                serviceProductRecordTypeId,
                STA_UtilsStatic.TEST + 'EOLgreaterThanToday',
                true,
                'testProductCode',
                STA_UtilsStatic.PRODUCT_MANUFACTEUR_SOC_CP,
                STA_UtilsStatic.PRODUCT_RANGE_SOC_CP,
                STA_UtilsStatic.PRODUCT_MODEL_SOC_CP,
                STA_UtilsStatic.PRODUCT_CONFIGURATION_SOC_CP,               
                STA_UtilsStatic.PRODUCT_PHASE_SOC_CP,
                STA_UtilsStatic.PRODUCT_POWER_SOC_CP,
                'kVA'
            );
            productEOLgreaterThanToday.SMC_Date_EndOfLife__c = Date.today().addDays(15);
            productEOLgreaterThanToday.SMC_Date_ExtendedEndOfLife__c = null;
            Product2 productEEOLgreaterThanToday =  SMC_UTIL_TestUtils.createServiceProductFSL(
                serviceProductRecordTypeId,
                STA_UtilsStatic.TEST + 'EOLgreaterThanToday',
                true,
                'testProductCode',
                STA_UtilsStatic.PRODUCT_MANUFACTEUR_SOC_CP,
                STA_UtilsStatic.PRODUCT_RANGE_SOC_CP,
                STA_UtilsStatic.PRODUCT_MODEL_SOC_CP,
                STA_UtilsStatic.PRODUCT_CONFIGURATION_SOC_CP,               
                STA_UtilsStatic.PRODUCT_PHASE_SOC_CP,
                STA_UtilsStatic.PRODUCT_POWER_SOC_CP,
                'kVA'
            );
            productEEOLgreaterThanToday.SMC_Date_EndOfLife__c = null;
            productEEOLgreaterThanToday.SMC_Date_ExtendedEndOfLife__c = Date.today().addDays(15);
            Product2 productActiveBadEOLandEEOL =  SMC_UTIL_TestUtils.createServiceProductFSL(
                serviceProductRecordTypeId,
                STA_UtilsStatic.TEST + 'EOLgreaterThanToday',
                true,
                'testProductCode',
                STA_UtilsStatic.PRODUCT_MANUFACTEUR_SOC_CP,
                STA_UtilsStatic.PRODUCT_RANGE_SOC_CP,
                STA_UtilsStatic.PRODUCT_MODEL_SOC_CP,
                STA_UtilsStatic.PRODUCT_CONFIGURATION_SOC_CP,               
                STA_UtilsStatic.PRODUCT_PHASE_SOC_CP,
                STA_UtilsStatic.PRODUCT_POWER_SOC_CP,
                'kVA'
            );
            productActiveBadEOLandEEOL.IsActive = true;
            productActiveBadEOLandEEOL.SMC_Date_EndOfLife__c = Date.today().addDays(-15);
            productActiveBadEOLandEEOL.SMC_Date_ExtendedEndOfLife__c = Date.today().addDays(-15);
            Product2 productBadNotService =  SMC_UTIL_TestUtils.createServiceProductFSL(
                salesProductRecordTypeId,
                STA_UtilsStatic.TEST + 'EOLgreaterThanToday',
                true,
                'testProductCode',
                STA_UtilsStatic.PRODUCT_MANUFACTEUR_SOC_CP,
                STA_UtilsStatic.SALES_PRODUCT_RANGE,
                STA_UtilsStatic.SALES_PRODUCT_MODEL,
                STA_UtilsStatic.PRODUCT_CONFIGURATION_SOC_CP,               
                STA_UtilsStatic.PRODUCT_PHASE_SOC_CP,
                STA_UtilsStatic.PRODUCT_POWER_SOC_CP,
                'kVA'
            );
            productBadNotService.IsActive = false;
            productBadNotService.SMC_Date_EndOfLife__c = null;
            productBadNotService.SMC_Date_ExtendedEndOfLife__c = null;

            Test.startTest();
            insert new List<Product2>{productNoEOLandNoEEOL, productEOLgreaterThanToday, productEEOLgreaterThanToday, productActiveBadEOLandEEOL, productBadNotService};
            Test.stopTest();

            Map<Id, Product2> checkProducts = new Map<Id, Product2>([SELECT Id, 
                                                                            IsActive 
                                                                     FROM Product2 
                                                                     WHERE Id IN :new List<Id>{productNoEOLandNoEEOL.Id, 
                                                                                               productEOLgreaterThanToday.Id, 
                                                                                               productEEOLgreaterThanToday.Id, 
                                                                                               productActiveBadEOLandEEOL.Id, 
                                                                                               productBadNotService.Id}
                                                                    ]);
            System.assert(checkProducts.get(productNoEOLandNoEEOL.Id).IsActive, 'Service Product without EOL and EEOL is not activated');
            System.assert(checkProducts.get(productEOLgreaterThanToday.Id).IsActive, 'Service Product with EOL greater than today is not activated');
            System.assert(checkProducts.get(productEEOLgreaterThanToday.Id).IsActive, 'Service Product with EEOL greater than today is not activated');
            System.assert(!checkProducts.get(productActiveBadEOLandEEOL.Id).IsActive, 'Service Product with EOL and EEOL lowar than today is not desactivated');
            System.assert(!checkProducts.get(productBadNotService.Id).IsActive, 'Sales Product is activated');
        }
    }

    @isTest
    public static void testRenameProductCode_ProductName() {
        User userStandard = SMC_UTIL_TestUtils.createTestUser(
        STA_UtilsStatic.PROFILE_SALE_STANDARD
        );
        insert new List<User>{ userStandard };
        System.runAs(userStandard) {
            Map<String, Schema.RecordTypeInfo> recordTypesProduct = new Map<String, Schema.RecordTypeInfo>();
            recordTypesProduct = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName();
            Id productRecordTypeId = recordTypesProduct.get(STA_UtilsStatic.RECORDTYPE_SERVICE_PRODUCT).getRecordTypeId();
           
            Product2 productTest =  SMC_UTIL_TestUtils.createServiceProductFSL(
                productRecordTypeId,
                STA_UtilsStatic.TEST,
                true,
                'testProductCode',
                STA_UtilsStatic.PRODUCT_MANUFACTEUR_SOC_CP,
                STA_UtilsStatic.PRODUCT_RANGE_SOC_CP,
                STA_UtilsStatic.PRODUCT_MODEL_SOC_CP,
                STA_UtilsStatic.PRODUCT_CONFIGURATION_SOC_CP,               
                STA_UtilsStatic.PRODUCT_PHASE_SOC_CP,
                STA_UtilsStatic.PRODUCT_POWER_SOC_CP,
                'kVA'
            );

            Test.startTest();
            insert productTest;
            Test.stopTest();

            String expectedProductCode = STA_UtilsStatic.PRODUCT_MANUFACTEUR_SOC_CP + '-' + STA_UtilsStatic.PRODUCT_RANGE_SOC_CP + '-' + STA_UtilsStatic.PRODUCT_MODEL_SOC_CP + '-' + STA_UtilsStatic.PRODUCT_CONFIGURATION_SOC_CP +  '-' + STA_UtilsStatic.PRODUCT_PHASE_SOC_CP + '-' + STA_UtilsStatic.PRODUCT_POWER_SOC_CP + '-kVA' ;
            String expectedProductName = 'SOCOMEC CP ' + STA_UtilsStatic.PRODUCT_MODEL_SOC_CP_LABEL + ' (' + STA_UtilsStatic.PRODUCT_MANUFACTEUR_SOC_CP + '-' + STA_UtilsStatic.PRODUCT_RANGE_SOC_CP + '-' + STA_UtilsStatic.PRODUCT_MODEL_SOC_CP + ') ' + STA_UtilsStatic.PRODUCT_CONFIGURATION_SOC_CP + ' ' +STA_UtilsStatic.PRODUCT_PHASE_SOC_CP + ' ' + STA_UtilsStatic.PRODUCT_POWER_SOC_CP + ' kVA';
            System.debug('TEST expectedProductCode------>'+expectedProductCode);
            System.debug('TEST expectedProductName------>'+expectedProductName);

            List<Product2> actualProduct = [SELECT Id, ProductCode, Name FROM Product2 WHERE Id =: productTest.Id];
            System.debug('TEST actualProduct------>'+actualProduct[0].ProductCode);
            System.debug('TEST actualProduct------>'+actualProduct[0].Name);

            System.assertEquals(expectedProductCode,actualProduct[0].ProductCode);
            System.assertEquals(expectedProductName,actualProduct[0].Name);

        }
    }

    @isTest
    public static void testRenameProductCode_ProductNameWithNullFields() {
        User userStandard = SMC_UTIL_TestUtils.createTestUser(
        STA_UtilsStatic.PROFILE_SALE_STANDARD
        );
        insert new List<User>{ userStandard };
        System.runAs(userStandard) {
            Map<String, Schema.RecordTypeInfo> recordTypesProduct = new Map<String, Schema.RecordTypeInfo>();
            recordTypesProduct = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName();
            Id productRecordTypeId = recordTypesProduct.get(STA_UtilsStatic.RECORDTYPE_SERVICE_PRODUCT).getRecordTypeId();
           
            Product2 productTest =  SMC_UTIL_TestUtils.createServiceProductFSL(
                productRecordTypeId,
                STA_UtilsStatic.TEST,
                true,
                'testProductCode',
                STA_UtilsStatic.PRODUCT_MANUFACTEUR_SOC_CP,
                null,
                STA_UtilsStatic.PRODUCT_MODEL_SOC_CP,
                null,               
                STA_UtilsStatic.PRODUCT_PHASE_SOC_CP,
                null,
                'kVA'
            );

            Test.startTest();
            insert productTest;
            Test.stopTest();

            String expectedProductCode = STA_UtilsStatic.PRODUCT_MANUFACTEUR_SOC_CP + '--' + STA_UtilsStatic.PRODUCT_MODEL_SOC_CP + '--' + STA_UtilsStatic.PRODUCT_PHASE_SOC_CP + '--kVA' ;
            String expectedProductName = 'SOCOMEC CP ' + STA_UtilsStatic.PRODUCT_MODEL_SOC_CP_LABEL + ' (' + STA_UtilsStatic.PRODUCT_MANUFACTEUR_SOC_CP + '-' + STA_UtilsStatic.PRODUCT_MODEL_SOC_CP + ') ' +STA_UtilsStatic.PRODUCT_PHASE_SOC_CP + ' kVA';

            List<Product2> actualProduct = [SELECT Id, Name, ProductCode FROM Product2 WHERE Id =: productTest.Id];
            System.debug('TEST actualProduct------>'+actualProduct[0].ProductCode);
            System.debug('TEST actualProduct------>'+actualProduct[0].Name);

            System.assertEquals(expectedProductCode,actualProduct[0].ProductCode);
            System.assertEquals(expectedProductName,actualProduct[0].Name);

        }
    }

    @isTest
    public static void testAssociateWorkTypeToNewProductWorkItem(){
        // createNewWorkTypesForNewProductWorkItem
        User userStandard = SMC_UTIL_TestUtils.createTestUser(STA_UtilsStatic.PROFILE_SALE_STANDARD);
        insert new List<User>{ userStandard };
        Id fslPermSetId = [
          SELECT id
          FROM PermissionSet
          WHERE Name = :STA_UtilsStatic.FSL_KEY_USER
          LIMIT 1
        ]
        .Id;
        insert new PermissionSetAssignment(
          AssigneeId = userStandard.Id,
          PermissionSetId = fslPermSetId
        );

        System.runAs(userStandard) {
            Map<String, Schema.RecordTypeInfo> recordTypesProduct = new Map<String, Schema.RecordTypeInfo>();
            recordTypesProduct = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName();
            Id productRecordTypeId = recordTypesProduct.get(STA_UtilsStatic.RECORDTYPE_SERVICE_PRODUCT).getRecordTypeId();
            Id workItemRecordTypeId = recordTypesProduct.get(STA_UtilsStatic.RECORDTYPE_WORK_ITEM_PRODUCT).getRecordTypeId();
            
            Product2 productTest1A =  SMC_UTIL_TestUtils.createServiceProductFSL(
                productRecordTypeId,
                'testProductCode1A',
                true,
                'testProductCode1A',
                STA_UtilsStatic.PRODUCT_MANUFACTEUR_SOC_CP,
                STA_UtilsStatic.PRODUCT_RANGE_SOC_CP,
                STA_UtilsStatic.PRODUCT_MODEL_SOC_CP,
                'C5',               
                STA_UtilsStatic.PRODUCT_PHASE_SOC_CP,
                STA_UtilsStatic.PRODUCT_POWER_SOC_CP,
                'kVA'
            );
            productTest1A.SMC_Type_p__c = 'UPS';
            Product2 productTest1B =  SMC_UTIL_TestUtils.createServiceProductFSL(
                productRecordTypeId,
                'testProductCode1B',
                true,
                'testProductCode1B',
                STA_UtilsStatic.PRODUCT_MANUFACTEUR_SOC_CP,
                STA_UtilsStatic.PRODUCT_RANGE_SOC_CP,
                STA_UtilsStatic.PRODUCT_MODEL_SOC_CP,
                STA_UtilsStatic.PRODUCT_CONFIGURATION_SOC_CP,
                STA_UtilsStatic.PRODUCT_PHASE_SOC_CP,
                STA_UtilsStatic.PRODUCT_POWER_SOC_CP,
                'kVA'
            );
            productTest1B.SMC_Type_p__c = 'MULTI_BY_PASS';
            Product2 productTest2A =  SMC_UTIL_TestUtils.createServiceProductFSL(
                productRecordTypeId,
                'testProductCode2A',
                true,
                'testProductCode2A',
                STA_UtilsStatic.PRODUCT_MANUFACTEUR_ABLE,
                STA_UtilsStatic.PRODUCT_RANGE_ABLE,
                STA_UtilsStatic.PRODUCT_MODEL_ABLE,
                STA_UtilsStatic.PRODUCT_CONFIGURATION_ABLE,
                STA_UtilsStatic.PRODUCT_PHASE_ABLE,
                STA_UtilsStatic.PRODUCT_POWER_ABLE,
                'kVA'
            );
            productTest2A.SMC_Type_p__c = 'UPS';
            insert new List<Product2>{productTest1A, productTest1B, productTest2A};

            Test.startTest();
                Product2 theWorkItem =  SMC_UTIL_TestUtils.createServiceProductFSL(
                    workItemRecordTypeId,
                    STA_UtilsStatic.TEST + 'WorkItem',
                    true,
                    'testProductCode1A',
                    STA_UtilsStatic.PRODUCT_MANUFACTEUR_SOC_CP,
                    STA_UtilsStatic.PRODUCT_RANGE_SOC_CP,
                    STA_UtilsStatic.PRODUCT_MODEL_SOC_CP,
                    null,               
                    STA_UtilsStatic.PRODUCT_PHASE_SOC_CP,
                    STA_UtilsStatic.PRODUCT_POWER_SOC_CP,
                    'kVA'
                );
                theWorkItem.SMC_Work_Type_Category__c = STA_UtilsStatic.PDT_WT_CAT_REPLACEMNT_AC_INPUT_CAPACITOR;
                insert theWorkItem;
            Test.stopTest();

            List<SMC_WorkTypeServiceProductAssociation__c> checkWorkTypeAssoSP = [SELECT Id FROM SMC_WorkTypeServiceProductAssociation__c];
            System.assertEquals(2, checkWorkTypeAssoSP.size());
            List<WorkType> checkWorkType = [SELECT Id, SMC_Work_Item__c FROM WorkType];
            System.assertEquals(2, checkWorkType.size());
            for(WorkType onWt : checkWorkType){
                System.assertEquals(theWorkItem.Id, onWt.SMC_Work_Item__c);
            }
        }
    }

    @isTest
    public static void testupdateWorkTypeIfProductWorkItemDeactivated(){
        // createNewWorkTypesForNewProductWorkItem
        User userStandard = SMC_UTIL_TestUtils.createTestUser(STA_UtilsStatic.PROFILE_SALE_STANDARD);
        insert new List<User>{ userStandard };
        Id fslPermSetId = [
          SELECT id
          FROM PermissionSet
          WHERE Name = :STA_UtilsStatic.FSL_KEY_USER
          LIMIT 1
        ]
        .Id;
        insert new PermissionSetAssignment(
          AssigneeId = userStandard.Id,
          PermissionSetId = fslPermSetId
        );

        System.runAs(userStandard) {
            Map<String, Schema.RecordTypeInfo> recordTypesProduct = new Map<String, Schema.RecordTypeInfo>();
            recordTypesProduct = Schema.SObjectType.Product2.getRecordTypeInfosByDeveloperName();
            Id workItemRecordTypeId = recordTypesProduct.get(STA_UtilsStatic.RECORDTYPE_WORK_ITEM_PRODUCT).getRecordTypeId();

            Product2 theWorkItem =  SMC_UTIL_TestUtils.createServiceProductFSL(
                workItemRecordTypeId,
                STA_UtilsStatic.TEST + 'WorkItem',
                true,
                'testProductCode1A',
                STA_UtilsStatic.PRODUCT_MANUFACTEUR_SOC_CP,
                STA_UtilsStatic.PRODUCT_RANGE_SOC_CP,
                STA_UtilsStatic.PRODUCT_MODEL_SOC_CP,
                null,               
                STA_UtilsStatic.PRODUCT_PHASE_SOC_CP,
                STA_UtilsStatic.PRODUCT_POWER_SOC_CP,
                'kVA'
            );
            theWorkItem.SMC_Work_Type_Category__c = STA_UtilsStatic.PDT_WT_CAT_REPLACEMNT_AC_INPUT_CAPACITOR;
            theWorkItem.IsActive = true;
            insert theWorkItem;

            WorkType wt1 = SMC_UTIL_TestUtils.createWorkType(
                'WT1',
                23
            );
            wt1.SMC_Work_Item__c = theWorkItem.Id;

            WorkType wt2 = SMC_UTIL_TestUtils.createWorkType(
                'WT2',
                21
            );
            wt2.SMC_Work_Item__c = theWorkItem.Id;

            WorkType wt3 = SMC_UTIL_TestUtils.createWorkType(
                'WT3',
                22
            );
            wt3.SMC_Work_Item__c = theWorkItem.Id;
            insert new List<WorkType>{wt1, wt2, wt3};

            Test.startTest();
                theWorkItem.IsActive = false;
                update theWorkItem;
            Test.stopTest();

            List<WorkType> wt = [SELECT Id, SMC_Work_Item__c, SMC_Active_until__c FROM WorkType WHERE SMC_Work_Item__c=:theWorkItem.Id];
            
            Date today = Date.today();
            for (WorkType onewt : wt) {
                System.assertEquals(today, onewt.SMC_Active_until__c);
            }
            
        }
    }
}