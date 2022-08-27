/*
--------------------------------------------------------------------------------------
-- - Name          : SMC_UTIL_CheckRecursiveTrigger
-- - Author        : David SOBCZAK (DOS) - Socomec
-- - Description   : Class util that allow to avoid recursive trigger call - cf. https://help.salesforce.com/articleView?id=000133752&type=1
-- - Project       : Socomec
--
-- Maintenance History:
--
-- Date         Name  Version  Remarks
-- -----------  ----  -------  -------------------------------------------------------
-- 24-Aug-2017  DOS    1.0     Initial version
--------------------------------------------------------------------------------------
*/

public without sharing class SMC_UTIL_CheckRecursiveTrigger {
  private static boolean run = true;
  /**
   * @description : check recursive trigger to run it only once
   * @author Vincent RECASENS (Modis) | 07-10-2020
   * @return boolean
   **/
  public static boolean runOnce() {
    if (run) {
      run = false;
      return true;
    } else {
      return run;
    }
  }
}