/*
---------------------------------------------------------------------------
-- - Name : SMC_AC_QlikSens_Access
-- - Author : Denis PHAM
-- - Description : This class is the Apex controller of the lightning
				   component SMC_LC_QlikSense_Access
--
-- Maintenance History:
--
-- Date 			Name 	Version 	Remarks
-- ----------- 		---- 	------- 	------------------
-- 10/05/2022 		VDPHA	1.0			Initial Version
---------------------------------------------------------------------------
*/

public without sharing class SMC_AC_QlikSense_Access {
  /**
   * @description : get QliSense URL from MDT in according to org
   * @author Denis PHAM (Modis) | 10/05/2022
   * @return String
   **/
  @AuraEnabled
  public static String openNewTab() {
    String host;
    host = URL.getSalesforceBaseUrl().getHost();

    List<SMC_QliSense_Access__mdt> qliSense = [
      SELECT Org__c,  QliSense_Url__c
      FROM SMC_QliSense_Access__mdt
    ];

    for (SMC_QliSense_Access__mdt mdt : qliSense) {
      //If host == mdt.Org__c -> PRODUCTION
      if (host == mdt.Org__c) {
        return mdt.QliSense_Url__c;
      } else if (host.contains(mdt.Org__c) && mdt.Org__c.length() <= 10) {
        //If host contains 'DEV', 'QA', or 'INT' -> mdt.Org__c length is lower of 5 char
        return mdt.QliSense_Url__c;
      }
    }

    System.debug(LoggingLevel.INFO, STA_UtilsStatic.ERROR_QLISENSE_ACCESS);
    return null;
  }
}