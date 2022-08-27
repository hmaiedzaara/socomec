/*
---------------------------------------------------------------------
-- - Name          : SMC_UtilsMethod
-- - Author        : Vincent RECASENS (VREC)
-- - Description   : This class regroup all utils methos
--
-- Maintenance History:
--
-- Date         Name 	Version  Remarks 
-- -----------  ------  -------  ---------------------------
-- 09-JUL-2019  VREC    1.0      Initial version 
---------------------------------------------------------------------
*/

public without sharing class SMC_UtilsMethod {
  /* REAL METHOD!! DO NOT DELETE */
  // /**
  //  * @description : get case callout informations
  //  * @author Vincent RECASENS (Modis) | 08/04/2020
  //  * @param wsToCall
  //  * @return Case_Callout__mdt
  //  **/
  // public static Case_Callout__mdt getEndpointWebmethodCaseCallout(
  //   String wsToCall
  // ) {
  //   System.debug(
  //     LoggingLevel.INFO,
  //     '>>>>>>SMC_AP_CaseCallout -> Method getEndpointWebmethod - START'
  //   );

  //   Case_Callout__mdt caseCalloutInformations = new Case_Callout__mdt();
  //   caseCalloutInformations = [
  //     SELECT
  //       URL_Credential__c,
  //       URL_Credential_DEV__c,
  //       URL_Credential_TEST__c,
  //       URL_Complement_Ending__c,
  //       The_URL__c,
  //       Authorization__c
  //     FROM Case_Callout__mdt
  //     WHERE DeveloperName = :wsToCall
  //   ];

  //   // String host = URL.getSalesforceBaseUrl().getHost();
  //   String host = URL.getSalesforceBaseUrl().toExternalForm();
  //   String[] tmpTab = host.split('--');
  //   //Production
  //   if (tmpTab.size() == 1) {
  //     caseCalloutInformations.The_URL__c = caseCalloutInformations.URL_Credential__c;
  //   } else if (
  //     tmpTab[1] == ('dev' + STA_UtilsStatic.DOT_SANDBOX_DOT_MY_DOT_SALESFORCE_DOT_COM) ||
  //     tmpTab[1] == ('int' + STA_UtilsStatic.DOT_SANDBOX_DOT_MY_DOT_SALESFORCE_DOT_COM)
  //   ) {
  //     //Dev/Int
  //     caseCalloutInformations.The_URL__c = caseCalloutInformations.URL_Credential_DEV__c;
  //   } else if (
  //     tmpTab[1] == ('qa' + STA_UtilsStatic.DOT_SANDBOX_DOT_MY_DOT_SALESFORCE_DOT_COM) ||
  //     tmpTab[1] == ('preprod' + STA_UtilsStatic.DOT_SANDBOX_DOT_MY_DOT_SALESFORCE_DOT_COM)
  //   ) {
  //     //QA/Preprod
  //     caseCalloutInformations.The_URL__c = caseCalloutInformations.URL_Credential_TEST__c;
  //   }

  //   System.debug(
  //     LoggingLevel.INFO,
  //     '>>>>>>SMC_AP_CaseCallout -> Method getEndpointWebmethod - END'
  //   );
  //   return caseCalloutInformations;
  // }
  /* REAL METHOD!! DO NOT DELETE */

  /* Temporary method */
  /**
   * @description : get case callout informations
   * @author Vincent RECASENS (Modis) | 08/04/2020
   * @param wsToCall
   * @return Case_Callout__mdt
   **/
  public static Case_Callout__mdt getEndpointWebmethodCaseCallout(
    String wsToCall
  ) {
    System.debug(
      LoggingLevel.INFO,
      '>>>>>>SMC_AP_CaseCallout -> Method getEndpointWebmethod - START'
    );

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

    // String host = URL.getSalesforceBaseUrl().getHost();
    String host = URL.getSalesforceBaseUrl().toExternalForm();
    String[] tmpTab = host.split('--');

    List<String> tmpList = new List<String>{
      STA_UtilsStatic.FC_DISCOUNT,
      STA_UtilsStatic.FC_NET_PRICE,
      STA_UtilsStatic.FC_DISCOUNT_PER_ITEM
    };
        
    //Production & Community
    if (tmpTab.size() == 1) {
      //PROD
      if(tmpTab[0] == 'https://socomec' + STA_UtilsStatic.DOT_MY_DOT_SALESFORCE_DOT_COM && tmpList.contains(wsToCall)){
        caseCalloutInformations.The_URL__c = caseCalloutInformations.URL_Credential__c;
      }
      //Dev/Int Community
      else if((host.split('dev-socomec').size() == 2 || host.split('int-socomec').size() == 2) && !tmpList.contains(wsToCall)){
        caseCalloutInformations.The_URL__c = caseCalloutInformations.URL_Credential_DEV__c;
      }
      //QA/Preprod Community
      else if(host.split('qa-socomec').size() == 2 || host.split('preprod-socomec').size() == 2 || tmpList.contains(wsToCall)){
        caseCalloutInformations.The_URL__c = caseCalloutInformations.URL_Credential_TEST__c;
      }
      else{
        caseCalloutInformations.The_URL__c = caseCalloutInformations.URL_Credential__c;
      }
    }
    //Dev/Int Salesforce
    else if (
      (tmpTab[1] == ('dev' + STA_UtilsStatic.DOT_SANDBOX_DOT_MY_DOT_SALESFORCE_DOT_COM) ||
      tmpTab[1] == ('int' + STA_UtilsStatic.DOT_SANDBOX_DOT_MY_DOT_SALESFORCE_DOT_COM))
      && !tmpList.contains(wsToCall) //Temp condition
    ) {
      caseCalloutInformations.The_URL__c = caseCalloutInformations.URL_Credential_DEV__c;
    }
    //QA/Preprod Salesforce
    else if (
      tmpTab[1] == ('qa' + STA_UtilsStatic.DOT_SANDBOX_DOT_MY_DOT_SALESFORCE_DOT_COM) ||
      tmpTab[1] == ('preprod' + STA_UtilsStatic.DOT_SANDBOX_DOT_MY_DOT_SALESFORCE_DOT_COM) ||
      tmpList.contains(wsToCall) //Temp condition
    ) {
      caseCalloutInformations.The_URL__c = caseCalloutInformations.URL_Credential_TEST__c;
    }

    System.debug(
      LoggingLevel.INFO,
      '>>>>>>SMC_AP_CaseCallout -> Method getEndpointWebmethod - END'
    );
    return caseCalloutInformations;
  }
  /* Temporary method */

  /**
   * @description : remake 'escapeSingleQuote' function and include special char
   * @author Vincent RECASENS (Modis) | 10/04/2020
   * @param specialString
   * @return String
   **/
  public static String escapeSpecialCharaters(String specialString) {
    String[] tabJsonWhereClause;
    String tmpString = '';
    String specialChar = '\\';
    if (specialString.contains('\'')) {
      tmpString = '';
      tabJsonWhereClause = specialString.split('\'');
      for (String str : tabJsonWhereClause) {
        tmpString += str + specialChar + '\'';
      }
      specialString = tmpString.substring(0, tmpString.length() - 2);
    }
    if (specialString.contains('-')) {
      tmpString = '';
      tabJsonWhereClause = specialString.split('-');
      for (String str : tabJsonWhereClause) {
        tmpString += str + specialChar + '-';
      }
      specialString = tmpString.substring(0, tmpString.length() - 2);
    }
    if (specialString.contains('"')) {
      tmpString = '';
      tabJsonWhereClause = specialString.split('"');
      for (String str : tabJsonWhereClause) {
        tmpString += str + specialChar + '"';
      }
      specialString = tmpString.substring(0, tmpString.length() - 2);
    }
    if (specialString.contains(':')) {
      tmpString = '';
      tabJsonWhereClause = specialString.split(':');
      for (String str : tabJsonWhereClause) {
        tmpString += str + specialChar + ':';
      }
      specialString = tmpString.substring(0, tmpString.length() - 2);
    }
    if (specialString.contains('~')) {
      tmpString = '';
      tabJsonWhereClause = specialString.split('~');
      for (String str : tabJsonWhereClause) {
        tmpString += str + specialChar + '~';
      }
      specialString = tmpString.substring(0, tmpString.length() - 2);
    }
    if (specialString.contains('^')) {
      tmpString = '';
      tabJsonWhereClause = specialString.split('^');
      for (String str : tabJsonWhereClause) {
        tmpString += str + specialChar + '^';
      }
      specialString = tmpString.substring(0, tmpString.length() - 2);
    }
    if (specialString.contains('!')) {
      tmpString = '';
      tabJsonWhereClause = specialString.split('!');
      for (String str : tabJsonWhereClause) {
        tmpString += str + specialChar + '!';
      }
      specialString = tmpString.substring(0, tmpString.length() - 2);
    }
    if (specialString.contains('|')) {
      tmpString = '';
      tabJsonWhereClause = specialString.split('|');
      for (String str : tabJsonWhereClause) {
        tmpString += str + specialChar + '|';
      }
      specialString = tmpString.substring(0, tmpString.length() - 2);
    }
    if (specialString.contains('&')) {
      tmpString = '';
      tabJsonWhereClause = specialString.split('&');
      for (String str : tabJsonWhereClause) {
        tmpString += str + specialChar + '&';
      }
      specialString = tmpString.substring(0, tmpString.length() - 2);
    }

    return specialString;
  }
}