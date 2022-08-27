/*
---------------------------------------------------------------------------
-- - Name : TEST_SMC_UTIL_LCDesign_AssetRelatedCase
-- - Author : Vincent RECASENS
-- - Description : This class test SMC_UTILS_LCDesign_AssetRelatedCase
--
-- Maintenance History:
--
-- Date 		Name 	Version 	Remarks
-- ----------- 	---- 	------- 	------------------
-- 20-MAR-2019 	VREC	1.0			Initial Version
---------------------------------------------------------------------------
*/

@isTest
public without sharing class TEST_SMC_UTIL_LCDesign_AssetRelatedCase {
  /**
   * @description : test SMC_UTIL_LCDesign_AssetRelatedCase constructor
   * @author Vincent RECASENS (Modis) | 07-15-2020
   **/
  @isTest
  public static void testClassDesign() {
    SMC_UTIL_LCDesign_AssetRelatedCase objectClass = new SMC_UTIL_LCDesign_AssetRelatedCase();

    VisualEditor.DataRow defaultValue = objectClass.getDefaultValue();
    System.assertNotEquals(
      null,
      defaultValue,
      'The method "getDefaultValue" is broken and return null.'
    );

    VisualEditor.DynamicPickListRows picklist = objectClass.getValues();
    System.assertNotEquals(
      null,
      picklist,
      'The method "getValues" is broken and return null.'
    );
  }
}