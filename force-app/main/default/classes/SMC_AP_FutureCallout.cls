/*
-----------------------------------------------------------------------------------
-- - Name : SMC_AP_FutureCallout
-- - Author : Vincent RECASENS
-- - Description : This class is the Future Apex class to call external WS
--
-- Maintenance History:
--
-- Date         Name   Version     Remarks
-- -----------  ----   -------     ----------------------------
-- 01-FEB-2018  VRE    1.0         Initial Version
-- 30-OCT-2018  VRE    1.1         Add params on "upsert"
------------------------------------------------------------------------------------
*/

public without sharing class SMC_AP_FutureCallout {
  /**
   * @description : callout SF services to assign territories
   * @author Vincent RECASENS (Modis) | 08/04/2020
   * @param setAccountId
   **/
  @Future(callout=true)
  public static void calloutAssignTerritories(Set<Id> setAccountId) {
    System.debug(
      LoggingLevel.INFO,
      '>>>>>>SMC_AP_FutureCallout -> Method calloutAssignTerritories - START'
    );

    //Make sure your Salesforce instance URL is added in remote site settings
    String sfdcURL = URL.getSalesforceBaseUrl().toExternalForm();
    String restAPIURL = sfdcURL + '/services/data/v41.0/composite/batch/';

    HttpRequest httpRequest = new HttpRequest();
    httpRequest.setMethod(STA_UtilsStatic.POST_METHOD);
    if (!Test.isRunningTest()) {
      httpRequest.setHeader(
        STA_UtilsStatic.AUTHORIZATION,
        'OAuth ' + Page.sessionID.getContent().toString()
      );
      // TestSessionIdAPI is a visualforce page which contain only a sessionID ({!$Api.Session_Id}) this page is only used to
      // get the sessionID from a future/asynchronous method to log on the salesforce API.
    }
    httpRequest.setHeader(
      STA_UtilsStatic.CONTENT_TYPE,
      STA_UtilsStatic.APPLICATION_JSON
    );
    // httpRequest.setHeader('Sforce-Auto-Assign', 'TRUE');
    httpRequest.setEndpoint(restAPIURL);
    httpRequest.setBody(constructJSON(setAccountId));
    httprequest.setTimeout(60000);
    try {
      Http http = new Http();
      HttpResponse httpResponse = http.send(httpRequest);

      if (
        httpResponse.getStatusCode() != 200 ||
        !HttpResponse.getBody()
          .substring(1, 18)
          .equals(STA_UtilsStatic.ASSIGN_TERRITORIES_RESPONSE)
      ) {
        System.debug(
          LoggingLevel.INFO,
          '## >>> SMC_AP_FutureCallout calloutAssignTerritories:ERROR BODY IS <<< ##: ' +
          HttpResponse.getBody()
        );
        throw new CalloutException(httpResponse.getBody());
      }
      System.debug(
        LoggingLevel.INFO,
        '>>>>>>SMC_AP_FutureCallout -> Method calloutAssignTerritories - END'
      );
    } catch (Exception e) {
      System.debug(
        LoggingLevel.INFO,
        '## >>> SMC_AP_FutureCallout calloutAssignTerritories:ERROR <<< ##: ' +
        e
      );
      List<String> recordList = new List<String>();
      for (Id oneId : setAccountId) {
        recordList.add('Account : ' + oneId);
      }
      SMC_UTIL_Methods_Batch.createErrorLog(
        new List<Exception>{ e },
        STA_UtilsStatic.ERROR_ACCOUNT_LOG_CALL_ASSIGN_TERRITORIES,
        STA_UtilsStatic.PICKLIST_LOGS_PROCESS_TYPE_WS,
        httpRequest.getBody(),
        httpRequest.getEndpoint(),
        recordList
      );
      throw e;
    }
  }

  /**
   * @description : JSON formatter
   * @author Vincent RECASENS (Modis) | 07-10-2020
   * @param setAccountId
   * @return String
   **/
  public static String constructJSON(Set<Id> setAccountId) {
    String jsonString = STA_UtilsStatic.EMPTY_STRING;
    jsonString += '{"batchRequests":[';

    for (Id accountId : setAccountId) {
      String accountString =
        '{"method":"PATCH","url":"/services/data/v41.0/sobjects/Account/' +
        accountId +
        '","richInput":{}},';
      jsonString += accountString;
    }

    //Remove last coma ","
    jsonString = jsonString.substring(0, jsonString.length() - 1);

    jsonString += ']}';
    return jsonString;
  }

  /**
   * @description : callout to update Scoring on external server
   * @author Vincent RECASENS (Modis) | 08/04/2020
   * @param newAccountIds
   **/
  @Future(callout=true)
  public static void callUpdateScoring(Set<Id> newAccountIds) {
    System.debug(
      LoggingLevel.INFO,
      '>>>>>>SMC_AP_FutureCallout -> Method callUpdateScoring - START'
    );

    SMC_AC_ScoringForm.getDiscountInformations(newAccountIds, false);

    System.debug(
      LoggingLevel.INFO,
      '>>>>>>SMC_AP_FutureCallout -> Method callUpdateScoring - END'
    );
  }

  public class ExceptionsWrapper {
    public String errorName { get; set; }
    public String errorMessage { get; set; }
    public String errorStackTrace { get; set; }
  }
}