/*
---------------------------------------------------------------------------
-- - Name : TEST_SMC_AC_QlikView_Access
-- - Author : Vincent RECASENS
-- - Description : This class test the Apex class SMC_AC_QlikView_Access
--
-- Maintenance History:
--
-- Date 			    Name 	Version 	Remarks
-- ----------- 		---- 	------- 	------------------
-- 10-JUL-2019 		VRE		1.0			  Initial Version
-- 11-MAY-2022    DPHA  2.0       Deprecated -> To be deleted
---------------------------------------------------------------------------
*/

@IsTest
public with sharing class TEST_SMC_AC_QlikView_Access {
  /**
  * @description : test SMC_AC_QlikView_Access.openNewTab()
  * @author Vincent RECASENS (Modis) | 07-10-2020 
  **/
  @isTest
  public static void testOpenNewTab() {
    System.assertNotEquals(
      null,
      SMC_AC_QlikView_Access.openNewTab(),
      'The org is not exist in the metadata "SMC_QliView_Access__mdt".'
    );
    //Same url on every organisation
    System.assertEquals(
      [SELECT QliView_Url__c FROM SMC_QliView_Access__mdt LIMIT 1]
      .QliView_Url__c,
      SMC_AC_QlikView_Access.openNewTab(),
      'The org is not exist in the metadata "SMC_QliView_Access__mdt".'
    );
  }
}