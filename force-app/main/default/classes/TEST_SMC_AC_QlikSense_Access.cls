/*
---------------------------------------------------------------------------
-- - Name : TEST_SMC_AC_QlikSense_Access
-- - Author : Denis PHAM
-- - Description : This class test the Apex class SMC_AC_QlikSense_Access
--
-- Maintenance History:
--
-- Date 			Name 	Version 	Remarks
-- ----------- 		---- 	------- 	------------------
-- 10/05/2022 		DPHA	1.0			Initial Version
---------------------------------------------------------------------------
*/

@IsTest
public with sharing class TEST_SMC_AC_QlikSense_Access {
    /**
    * @description : test SMC_AC_QlikSense_Access.openNewTab()
    * @author Denis PHAM (Modis) | 10-05-2022 
    **/   
    @isTest
    public static void testOpenNewTab() {
        System.assertNotEquals(
            null,
            SMC_AC_QlikSense_Access.openNewTab(),
            'The org is not exist in the metadata "SMC_QliSense_Access__mdt".'
        );
        //Same url on every organisation
        System.assertEquals(
            [SELECT QliSense_Url__c FROM SMC_QliSense_Access__mdt LIMIT 1]
            .QliSense_Url__c,
            SMC_AC_QlikSense_Access.openNewTab(),
            'The org is not exist in the metadata "SMC_QliSense_Access__mdt".'
      );
    }
}