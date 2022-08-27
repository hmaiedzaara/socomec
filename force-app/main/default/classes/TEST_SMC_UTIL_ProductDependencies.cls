/*
---------------------------------------------------------------------------
-- - Name : TEST_SMC_UTIL_ProductDependencies
-- - Author : Vincent RECASENS
-- - Description : This class test SMC_UTIL_ProductDependencies
                   The tests call method and not really tests because 
                   org cache don't exist in a test context
--
-- Maintenance History:
--
-- Date 		Name 	Version 	Remarks
-- ----------- 	---- 	------- 	------------------
-- 29-MAR-2019 	VREC	1.0			Initial Version
---------------------------------------------------------------------------
*/

@isTest
public without sharing class TEST_SMC_UTIL_ProductDependencies {
  /**
  * @description : test SMC_UTIL_ProductDependencies
  * @author Vincent RECASENS (Modis) | 07-15-2020 
  **/
  @isTest
  public static void testClass() {
    SMC_UTIL_ProductDependencies utilObject = new SMC_UTIL_ProductDependencies();
    utilObject.putPicklistDependencies();
    utilObject.getList(STA_UtilsStatic.ORG_CACHE_SERVICE_PRODUCT_MANUFACTURER);
    System.assertNotEquals(null, utilObject, 'The cache org is empty.');
  }
}