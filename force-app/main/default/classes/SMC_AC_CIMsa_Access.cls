/*
---------------------------------------------------------------------------
-- - Name : SMC_AC_CIMsa_Access
-- - Author : Vincent RECASENS
-- - Description : This class is the Apex controller of the lightning
				   component SMC_LC_CIMsa_Access
--
-- Maintenance History:
--
-- Date 		Name 				Version 	Remarks
-- ----------- 	---- 				------- 	------------------
-- 26-DEC-2017 	SMC_AC_CIMsa_Access	1.0			Initial Version
-- 12-JAN-2018 	SMC_AC_CIMsa_Access	2.0			Add Custom Metadata Types
---------------------------------------------------------------------------
*/

public without sharing class SMC_AC_CIMsa_Access {
  /**
   * @description : get url in according to the sandbox
   * @author Vincent RECASENS (Modis) | 10/04/2020
   * @return String
   **/
  @AuraEnabled
  public static String openNewTab() {
    System.debug(
      LoggingLevel.INFO,
      '>>>>>> SMC_AC_CIMsa_Access : openNewTab - START'
    );

    String host;
    host = URL.getSalesforceBaseUrl().getHost();

    System.debug(
      LoggingLevel.INFO,
      '>>>>>> SMC_AC_CIMsa_Access : openNewTab - host : ' + host
    );
    CIMsa_Access__mdt[] cimsas = [
      SELECT Org__c, Organization_Community__c, CIMsa_Url__c
      FROM CIMsa_Access__mdt
    ];
    for (CIMsa_Access__mdt mdt : cimsas) {
      //If host == mdt.Org__c -> PRODUCTION
      if (host == mdt.Org__c || host == mdt.Organization_Community__c) {
        System.debug(
          LoggingLevel.INFO,
          '>>>>>> SMC_AC_CIMsa_Access : openNewTab - END'
        );
        return mdt.CIMsa_Url__c;
      } else if (host.contains(mdt.Org__c) && mdt.Org__c.length() <= 10) {
        //If host contains 'DEV', 'QA', or 'INT' -> mdt.Org__c length is lower of 5 char
        System.debug(
          LoggingLevel.INFO,
          '>>>>>> SMC_AC_CIMsa_Access : openNewTab - END'
        );
        return mdt.CIMsa_Url__c;
      }
    }

    System.debug(LoggingLevel.INFO, STA_UtilsStatic.ERROR_CIMSA_ACCESS);
    System.debug(
      LoggingLevel.INFO,
      '>>>>>> SMC_AC_CIMsa_Access : openNewTab - END'
    );
    return null;
  }
}