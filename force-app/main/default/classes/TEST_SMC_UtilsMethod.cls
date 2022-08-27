/*
---------------------------------------------------------------------
-- - Name          : TEST_SMC_UtilsMethod
-- - Author        : Vincent RECASENS (VREC)
-- - Description   : This class test SMC_UtilsMethod
--
-- Maintenance History:
--
-- Date         Name 	Version  Remarks 
-- -----------  ------  -------  ---------------------------
-- 09-JUL-2019  VREC    1.0      Initial version 
---------------------------------------------------------------------
*/

@IsTest
public without sharing class TEST_SMC_UtilsMethod {
  @isTest
  public static void testGetEndpointWebmethodCaseCallout() {
    String wsToCall = STA_UtilsStatic.ERP_DATA;
    Case_Callout__mdt caseCalloutInformations = new Case_Callout__mdt();
    caseCalloutInformations = [
      SELECT
        URL_Credential__c,
        URL_Credential_DEV__c,
        URL_Credential_TEST__c,
        URL_Complement_Ending__c,
        The_URL__c,
        Authorization__c
      FROM Case_Callout__mdt
      WHERE DeveloperName = :wsToCall
    ];
    Case_Callout__mdt resultDev = SMC_UtilsMethod.getEndpointWebmethodCaseCallout(
      STA_UtilsStatic.ERP_DATA
    );
    System.assertNotEquals(null, resultDev.The_URL__c);
    System.assertNotEquals('', resultDev.The_URL__c);
  }

  /**
   * @description : test SMC_UtilsMethod.escapeSpecialCharaters() [ERROR ON --> \ + * ( ) [ { ? ]
   * @author Vincent RECASENS (Modis) | 07-15-2020
   **/
  @isTest
  public static void testEscapeSpecialCharaters() {
    String specialString1 = 'a\' a- a: a~ a^ a! a| a& a"';
    System.assertNotEquals(
      specialString1,
      SMC_UtilsMethod.escapeSpecialCharaters(specialString1),
      'The custom "escapaSpecialCharacter" have is broken.'
    );
  }
}