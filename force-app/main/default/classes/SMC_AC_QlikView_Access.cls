/*
---------------------------------------------------------------------------
-- - Name : SMC_AC_QlikView_Access
-- - Author : Vincent RECASENS
-- - Description : This class is the Apex controller of the lightning
				   component SMC_LC_QlikView_Access
--
-- Maintenance History:
--
-- Date 		    	Name 	Version 	Remarks
-- ----------- 		---- 	------- 	------------------
-- 14-JUN-2019 		VRE		1.0			  Initial Version
-- 11-MAY-2022    DPHA  2.0       Deprecated - To be deleted
---------------------------------------------------------------------------
*/

public without sharing class SMC_AC_QlikView_Access {
  /**
   * @description : get QliView url from MDT in according to org
   * @author Vincent RECASENS (Modis) | 10/04/2020
   * @return String
   **/
  @AuraEnabled
  public static String openNewTab() {
    String host;
    host = URL.getSalesforceBaseUrl().getHost();

    // System.debug(LoggingLevel.INFO, '>>>>>> SMC_AC_QlikView_Access : openNewTab - host : ' + host);
    SMC_QliView_Access__mdt[] qliView = [
      SELECT Org__c, /*Organization_Community__c,*/ QliView_Url__c
      FROM SMC_QliView_Access__mdt
    ];
    for (SMC_QliView_Access__mdt mdt : qliView) {
      //If host == mdt.Org__c -> PRODUCTION
      if (host == mdt.Org__c /* || host == mdt.Organization_Community__c*/) {
        return mdt.QliView_Url__c;
      } else if (host.contains(mdt.Org__c) && mdt.Org__c.length() <= 10) {
        //If host contains 'DEV', 'QA', or 'INT' -> mdt.Org__c length is lower of 5 char
        return mdt.QliView_Url__c;
      }
    }

    System.debug(LoggingLevel.INFO, STA_UtilsStatic.ERROR_QLIVIEW_ACCESS);
    return null;
  }
}