/*
---------------------------------------------------------------------------
-- - Name : TEST_SMC_AC_CIMsa_Access
-- - Author : Vincent RECASENS
-- - Description : This class test SMC_AC_CIMsa_Access
--
-- Maintenance History:
--
-- Date         Name                        Version     Remarks
-- -----------  ----                        -------     ------------------
-- 05-FEB-2018  TEST_SMC_AC_CIMsa_Access(DOS)   1.1         Extend limit char of sandbox name
-- 26-DEC-2017  TEST_SMC_AC_CIMsa_Access    1.0         Initial Version
---------------------------------------------------------------------------
*/

@isTest
public with sharing class TEST_SMC_AC_CIMsa_Access {
  /**
  * @description : test SMC_AC_CIMsa_Access.openNewTab()
  * @author Vincent RECASENS (Modis) | 07-10-2020 
  **/
  @isTest
  public static void testOpenNewTab() {
    String urlRes = SMC_AC_CIMsa_Access.openNewTab();
    String host = URL.getSalesforceBaseUrl().getHost();

    Boolean check = false;
    CIMsa_Access__mdt[] cimsas = [
      SELECT Org__c, Organization_Community__c, CIMsa_Url__c
      FROM CIMsa_Access__mdt
    ];
    for (CIMsa_Access__mdt mdt : cimsas) {
      //If host == mdt.Org__c -> PRODUCTION
      if (host == mdt.Org__c || host == mdt.Organization_Community__c) {
        if (mdt.CIMsa_Url__c == urlRes) {
          check = true;
        }
      } else if (host.contains(mdt.Org__c) && mdt.Org__c.length() <= 10) {
        //If host contains sandbox name -> mdt.Org__c length is lower or equals of 10 char (sf limit sandbox name)
        if (mdt.CIMsa_Url__c == urlRes) {
          check = true;
        }
      }
    }

    System.assert(check, 'Return result is false.');
  }
}