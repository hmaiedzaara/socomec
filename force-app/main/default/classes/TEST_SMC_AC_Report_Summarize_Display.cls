/*
---------------------------------------------------------------------
-- - Name          : TEST_SMC_AC_Report_Summarize_Display
-- - Author        : Vincent RECASENS (VRE)
-- - Description   : Test the controler SMC_AC_Report_Summarize_Display
-- Maintenance History:
--
-- Date         Name   Version  Remarks 
-- -----------  ----   -------  ---------------------------
-- 24-OCT-2019  VRE    1.0      Initial version 
---------------------------------------------------------------------
*/

@IsTest
public with sharing class TEST_SMC_AC_Report_Summarize_Display {
  /**
  * @description : test  SMC_AC_Report_Summarize_Display.getInformations(ClasseTest_D4J)
  * @author Vincent RECASENS (Modis) | 07-10-2020 
  **/
  @isTest(SeeAllData=true)
  public static void testGetInformationsFAKE() {
    SMC_AC_Report_Summarize_Display.AllInformations result = SMC_AC_Report_Summarize_Display.getInformations(
      'ClasseTest_D4J',
      1,
      1
    );
    System.assertEquals(null, result.error, 'Change the name of the report.');
  }
}