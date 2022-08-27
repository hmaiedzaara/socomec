/*
-----------------------------------------------------------------------------------
-- - Name : SMC_AP_CaseCallout
-- - Author : David SOBZACK - Vincent RECASENS
-- - Description : This class manage Case callouts
--
-- Maintenance History:
--
-- Date         Name   Version     Remarks
-- -----------  ----   -------     ----------------------------
-- xx-XXX-2018  DOS    1.0         Initial Version
-- 26-OCT-2018  VRE    1.1         Add metadata for endpoint
-- 13-MAR-2019  VRE    1.2         Add method "createCimsaVisit"
------------------------------------------------------------------------------------
*/

public without sharing class SMC_AP_CaseCallout {
  /**
   * /!\ DEPRECATED/!\
   * @description : get callout informations
   * @author Vincent RECASENS (Modis) | 08/04/2020
   * @param wsToCall
   * @return Case_Callout__mdt
   * /!\ DEPRECATED/!\
   **/
  public static Case_Callout__mdt getEndpointWebmethod(String wsToCall) {
    System.debug(
      LoggingLevel.INFO,
      '>>>>>>SMC_AP_CaseCallout -> Method getEndpointWebmethod - START'
    );

    String host = URL.getSalesforceBaseUrl().getHost();
    String urlEndpoint = STA_UtilsStatic.EMPTY_STRING;
    SMC_Endpoint_Webmethod__mdt[] endpoints = [
      SELECT
        SMC_URL_Endpoint__c,
        Organization__c,
        SMC_Is_Mocking_Mode__c,
        Organization_Community__c
      FROM SMC_Endpoint_Webmethod__mdt
    ]; //There are not 200 elements in this custom metadata
    for (SMC_Endpoint_Webmethod__mdt e : endpoints) {
      //If host == mdt.Organization__c -> PRODUCTION
      //TODO - Variabiliser le cas de community en dur actuellement pour raison hotfix
      //System.debug(LoggingLevel.INFO, '>>>>>>SMC_AP_CaseCallout -> Method host : ' + host);
      // if(host == e.Organization__c || (host == 'socomec.force.com' && e.Organization__c == 'socomec.my.salesforce.com')) {
      if (host == e.Organization__c || host == e.Organization_Community__c) {
        urlEndpoint = e.SMC_URL_Endpoint__c;
      } else if (
        (host.contains(e.Organization__c) ||
        host.startsWithIgnoreCase(e.Organization__c + '-socomec')) &&
        e.Organization__c.length() <= 10
      ) {
        //If host contains 'DEV', 'QA', or 'INT' -> mdt.Organization__c length is lower of 5 char
        //If it's mocked, return null
        if (e.SMC_Is_Mocking_Mode__c) {
          return null;
        }
        urlEndpoint = e.SMC_URL_Endpoint__c;
      }
    }
    Case_Callout__mdt caseCalloutInformations = new Case_Callout__mdt();
    caseCalloutInformations = [
      SELECT URL_Complement__c, URL_Complement_Ending__c, Authorization__c
      FROM Case_Callout__mdt
      WHERE DeveloperName = :wsToCall
    ];
    caseCalloutInformations.URL_Complement__c =
      urlEndpoint + caseCalloutInformations.URL_Complement__c; // To keep "urlEndpoint" value and return the metadata and not a custom wrapper

    System.debug(
      LoggingLevel.INFO,
      '>>>>>>SMC_AP_CaseCallout -> Method getEndpointWebmethod - END'
    );
    return caseCalloutInformations;
  }

  /**
   * @description : callout to get product informations from case serial number (html version)
   * @author Vincent RECASENS (Modis) | 08/04/2020
   * @param serialNumber
   * @param recordList
   * @return String
   **/
  public static String getInstalledProductInfosHTML(
    String serialNumber,
    List<String> recordList
  ) {
    System.debug(
      LoggingLevel.INFO,
      '>>>>>>SMC_AP_CaseCallout -> Method getInstalledProductInfosHTML - START'
    );

    Case_Callout__mdt caseCalloutInformtions = new Case_Callout__mdt();
    caseCalloutInformtions = SMC_UtilsMethod.getEndpointWebmethodCaseCallout(
      STA_UtilsStatic.INSTALLED_PRODUCT_INFORMATIONS
    );
    if (caseCalloutInformtions == null) {
      return SMC_UTIL_CaseCalloutMockJSON.INSTALLED_PRODUCT_INFO;
    }

    //Build the callout*****
    HttpRequest request = new HttpRequest();
    request.setEndpoint(caseCalloutInformtions.The_URL__c + serialNumber);
    request.setMethod(STA_UtilsStatic.GET_METHOD);
    request.setTimeout(60000);

    String requestBody = STA_UtilsStatic.BODY_SYSDEBUG + request.getBody(); // Body empty
    String requestQuery =
      STA_UtilsStatic.QUERY_SYSDEBUG + request.getEndpoint();

    Http http = new Http();
    HTTPResponse response = new HTTPResponse();
    String htmlResponse = STA_UtilsStatic.EMPTY_STRING;

    try {
      response = http.send(request);
      htmlResponse = response.getBody();

      //Error
      if (response.getStatusCode() != 200 && response.getStatusCode() != 204) {
        CalloutException calloutException = new CalloutException();
        calloutException.setMessage(
          STA_UtilsStatic.BAD_STATUS_CODE +
          response.getStatusCode() +
          ' -> BODY : ' +
          response.getBody()
        );
        throw calloutException;
      }
    } catch (CalloutException calloutException) {
      System.debug(
        LoggingLevel.INFO,
        STA_UtilsStatic.BAD_STATUS_CODE +
        response.getStatusCode() +
        ' -> CalloutException : ' +
        calloutException
      );
      SMC_UTIL_Methods_Batch.createErrorLog(
        new List<CalloutException>{ calloutException },
        STA_UtilsStatic.ERROR_CASE_LOG_INSTALLED_PRODUCT_INFO_HTML,
        STA_UtilsStatic.PICKLIST_LOGS_PROCESS_TYPE_WS,
        requestBody,
        requestQuery,
        recordList
      );
    } catch (Exception e) {
      System.debug(LoggingLevel.INFO, 'Exception : ' + e);
      SMC_UTIL_Methods_Batch.createErrorLog(
        new List<Exception>{ e },
        STA_UtilsStatic.ERROR_CASE_LOG_INSTALLED_PRODUCT_INFO_HTML,
        STA_UtilsStatic.PICKLIST_LOGS_PROCESS_TYPE_WS,
        requestBody,
        requestQuery,
        recordList
      );
    }

    System.debug(
      LoggingLevel.INFO,
      '>>>>>>SMC_AP_CaseCallout -> Method getInstalledProductInfosHTML - END'
    );
    return htmlResponse;
  }

  /**
   * @description : callout to get sales order informations from case order number
   * @author Vincent RECASENS (Modis) | 08/04/2020
   * @param orderNumber
   * @param recordList
   * @return List<SMC_DTO_SalesOrderDetails>
   **/
  public static List<SMC_DTO_SalesOrderDetails> getSalesOrderInfos(
    String orderNumber,
    List<String> recordList
  ) {
    System.debug(
      LoggingLevel.INFO,
      '>>>>>>SMC_AP_CaseCallout -> Method getSalesOrderInfos - START'
    );

    //Return value
    List<SMC_DTO_SalesOrderDetails> salesOrderDetails = new List<SMC_DTO_SalesOrderDetails>();

    Case_Callout__mdt caseCalloutInformtions = new Case_Callout__mdt();
    caseCalloutInformtions = SMC_UtilsMethod.getEndpointWebmethodCaseCallout(
      STA_UtilsStatic.SALES_ORDER_INFORMATIONS
    );
    if (caseCalloutInformtions == null) {
      try {
        salesOrderDetails = (List<SMC_DTO_SalesOrderDetails>) JSON.deserialize(
          SMC_UTIL_CaseCalloutMockJSON.SALES_ORDER_DETAILS,
          (List<SMC_DTO_SalesOrderDetails>.class)
        );
      } catch (JSONException jsonException) {
        System.debug(
          LoggingLevel.INFO,
          STA_UtilsStatic.MALFORMED_JSON + jsonException
        );
      }
      return salesOrderDetails;
    }

    //Build the callout*****
    HttpRequest request = new HttpRequest();
    request.setEndpoint(
      caseCalloutInformtions.The_URL__c +
      orderNumber +
      caseCalloutInformtions.URL_Complement_Ending__c
    );
    request.setMethod(STA_UtilsStatic.GET_METHOD);
    request.setTimeout(60000);

    String requestBody = STA_UtilsStatic.BODY_SYSDEBUG + request.getBody(); // Body empty
    String requestQuery =
      STA_UtilsStatic.QUERY_SYSDEBUG + request.getEndpoint();

    Http http = new Http();
    HTTPResponse response = new HTTPResponse();
    String salesOrderDetailsJSON = STA_UtilsStatic.EMPTY_STRING;
    try {
      response = http.send(request);
      salesOrderDetailsJSON = response.getBody();
      salesOrderDetails = (List<SMC_DTO_SalesOrderDetails>) JSON.deserialize(
        salesOrderDetailsJSON,
        (List<SMC_DTO_SalesOrderDetails>.class)
      );
      System.debug(LoggingLevel.INFO, response.getBody());

      //Error
      if (response.getStatusCode() != 200 && response.getStatusCode() != 204) {
        CalloutException calloutException = new CalloutException();
        calloutException.setMessage(
          STA_UtilsStatic.BAD_STATUS_CODE +
          response.getStatusCode() +
          ' -> BODY : ' +
          response.getBody()
        );
        throw calloutException;
      }
    } catch (CalloutException calloutException) {
      System.debug(
        LoggingLevel.INFO,
        STA_UtilsStatic.BAD_STATUS_CODE +
        response.getStatusCode() +
        ' -> CalloutException : ' +
        calloutException
      );
      SMC_UTIL_Methods_Batch.createErrorLog(
        new List<CalloutException>{ calloutException },
        STA_UtilsStatic.ERROR_CASE_LOG_SALES_ORDER_INFOS,
        STA_UtilsStatic.PICKLIST_LOGS_PROCESS_TYPE_WS,
        requestBody,
        requestQuery,
        recordList
      );
    } catch (JSONException jsonException) {
      System.debug(
        LoggingLevel.INFO,
        STA_UtilsStatic.BAD_STATUS_CODE +
        response.getStatusCode() +
        ' -> JSONException : ' +
        jsonException
      );
      SMC_UTIL_Methods_Batch.createErrorLog(
        new List<JSONException>{ jsonException },
        STA_UtilsStatic.ERROR_CASE_LOG_SALES_ORDER_INFOS,
        STA_UtilsStatic.PICKLIST_LOGS_PROCESS_TYPE_WS,
        requestBody,
        requestQuery,
        recordList
      );
    } catch (Exception e) {
      System.debug(LoggingLevel.INFO, 'Exception : ' + e);
      SMC_UTIL_Methods_Batch.createErrorLog(
        new List<Exception>{ e },
        STA_UtilsStatic.ERROR_CASE_LOG_SALES_ORDER_INFOS,
        STA_UtilsStatic.PICKLIST_LOGS_PROCESS_TYPE_WS,
        requestBody,
        requestQuery,
        recordList
      );
    }

    System.debug(
      LoggingLevel.INFO,
      '>>>>>>SMC_AP_CaseCallout -> Method getSalesOrderInfos - END'
    );
    return salesOrderDetails;
  }

  /**
   * @description : callout to get product informations from case serial number (fields version)
   * @author Vincent RECASENS (Modis) | 08/04/2020
   * @param serialNumbersJSON
   * @param recordList
   * @return List<SMC_DTO_SN_ProductInfo>
   **/
  public static List<SMC_DTO_SN_ProductInfo> getSNProductInfo(
    String serialNumbersJSON,
    List<String> recordList
  ) {
    System.debug(
      LoggingLevel.INFO,
      '>>>>>>SMC_AP_CaseCallout -> Method getSNProductInfo - START'
    );

    //Return value
    List<SMC_DTO_SN_ProductInfo> snProductInfoJSON = new List<SMC_DTO_SN_ProductInfo>();

    Case_Callout__mdt caseCalloutInformtions = new Case_Callout__mdt();
    caseCalloutInformtions = SMC_UtilsMethod.getEndpointWebmethodCaseCallout(
      STA_UtilsStatic.SN_PRODUCT_INFORMATIONS
    );
    if (caseCalloutInformtions == null) {
      try {
        //ATTENTION, le mock ne fonctionne que lorsque le Case que l'on envoie possède le serialNumber du MOCK --> BP171860
        snProductInfoJSON = (List<SMC_DTO_SN_ProductInfo>) JSON.deserialize(
          SMC_UTIL_CaseCalloutMockJSON.SN_PRODUCT_INFO,
          (List<SMC_DTO_SN_ProductInfo>.class)
        );
      } catch (JSONException jsonException) {
        System.debug(
          LoggingLevel.INFO,
          'There is a problem with the MOCK SNProductInfo -> JSONException : ' +
          jsonException
        );
      }
      return snProductInfoJSON;
    }

    HttpRequest request = new HttpRequest();
    request.setEndpoint(caseCalloutInformtions.The_URL__c);
    request.setMethod(STA_UtilsStatic.POST_METHOD);
    request.setHeader(
      STA_UtilsStatic.CONTENT_TYPE,
      STA_UtilsStatic.APPLICATION_JSON
    );
    request.setBody(serialNumbersJSON);
    request.setTimeout(60000);

    String requestBody = STA_UtilsStatic.BODY_SYSDEBUG + request.getBody();
    String requestQuery =
      STA_UtilsStatic.QUERY_SYSDEBUG + request.getEndpoint();

    Http http = new Http();
    HTTPResponse response = new HTTPResponse();
    String snProductInfo = STA_UtilsStatic.EMPTY_STRING;
    try {
      response = http.send(request);
      snProductInfo = response.getBody();
      snProductInfoJSON = (List<SMC_DTO_SN_ProductInfo>) JSON.deserialize(
        snProductInfo,
        (List<SMC_DTO_SN_ProductInfo>.class)
      );

      //Error
      if (response.getStatusCode() != 200 && response.getStatusCode() != 204) {
        CalloutException calloutException = new CalloutException();
        calloutException.setMessage(
          STA_UtilsStatic.BAD_STATUS_CODE +
          response.getStatusCode() +
          ' -> BODY : ' +
          snProductInfo
        );
        throw calloutException;
      }
    } catch (CalloutException calloutException) {
      System.debug(
        LoggingLevel.INFO,
        STA_UtilsStatic.BAD_STATUS_CODE +
        response.getStatusCode() +
        ' -> CalloutException : ' +
        calloutException
      );
      SMC_UTIL_Methods_Batch.createErrorLog(
        new List<CalloutException>{ calloutException },
        STA_UtilsStatic.ERROR_CASE_LOG_SN_PRODUCT_INFO,
        STA_UtilsStatic.PICKLIST_LOGS_PROCESS_TYPE_WS,
        requestBody,
        requestQuery,
        recordList
      );
    } catch (JSONException jsonException) {
      System.debug(
        LoggingLevel.INFO,
        STA_UtilsStatic.BAD_STATUS_CODE +
        response.getStatusCode() +
        ' -> JSONException : ' +
        jsonException
      );
      SMC_UTIL_Methods_Batch.createErrorLog(
        new List<JSONException>{ jsonException },
        STA_UtilsStatic.ERROR_CASE_LOG_SN_PRODUCT_INFO,
        STA_UtilsStatic.PICKLIST_LOGS_PROCESS_TYPE_WS,
        requestBody,
        requestQuery,
        recordList
      );
    } catch (Exception e) {
      System.debug(LoggingLevel.INFO, 'Exception : ' + e);
      SMC_UTIL_Methods_Batch.createErrorLog(
        new List<Exception>{ e },
        STA_UtilsStatic.ERROR_CASE_LOG_SN_PRODUCT_INFO,
        STA_UtilsStatic.PICKLIST_LOGS_PROCESS_TYPE_WS,
        requestBody,
        requestQuery,
        recordList
      );
    }

    System.debug(
      LoggingLevel.INFO,
      '>>>>>>SMC_AP_CaseCallout -> Method getSNProductInfo - END'
    );
    return snProductInfoJSON;
  }

  /**
   * @description : callout to create CIMsa visit
   * @author Vincent RECASENS (Modis) | 08/04/2020
   * @param body
   * @param recordList
   * @return SMC_DTO_CimsaVisit
   **/
  public static SMC_DTO_CimsaVisit createCimsaVisit(
    String body,
    List<String> recordList
  ) {
    System.debug(
      LoggingLevel.INFO,
      '>>>>>>SMC_AP_CaseCallout -> Method createCimsaVisit - START'
    );

    //Return value
    SMC_DTO_CimsaVisit cimsaVisit = new SMC_DTO_CimsaVisit();

    Case_Callout__mdt caseCalloutInformtions = new Case_Callout__mdt();
    caseCalloutInformtions = SMC_UtilsMethod.getEndpointWebmethodCaseCallout(
      STA_UtilsStatic.CIMSA_VISIT
    );
    if (caseCalloutInformtions == null) {
      try {
        cimsaVisit = (SMC_DTO_CimsaVisit) JSON.deserialize(
          SMC_UTIL_CaseCalloutMockJSON.CIMSA_VISIT_MOCK,
          (SMC_DTO_CimsaVisit.class)
        );
      } catch (JSONException jsonException) {
        System.debug(
          LoggingLevel.INFO,
          STA_UtilsStatic.MALFORMED_JSON + jsonException
        );
      }
      return cimsaVisit;
    }

    //Build the callout*****
    HttpRequest request = new HttpRequest();
    request.setBody(body);
    request.setEndpoint(caseCalloutInformtions.The_URL__c);
    request.setMethod(STA_UtilsStatic.POST_METHOD);
    request.setHeader(
      STA_UtilsStatic.CONTENT_TYPE,
      STA_UtilsStatic.APPLICATION_JSON
    );
    request.setTimeout(60000);

    String requestBody = STA_UtilsStatic.BODY_SYSDEBUG + request.getBody();
    String requestQuery =
      STA_UtilsStatic.QUERY_SYSDEBUG + request.getEndpoint();

    Http http = new Http();
    HTTPResponse response = new HTTPResponse();
    String cimsaVisitJSON = STA_UtilsStatic.EMPTY_STRING;
    try {
      response = http.send(request);
      cimsaVisitJSON = response.getBody();
      cimsaVisit = (SMC_DTO_CimsaVisit) JSON.deserialize(
        cimsaVisitJSON,
        (SMC_DTO_CimsaVisit.class)
      );
      cimsaVisit.calloutResponse = true;

      //Error
      if (response.getStatusCode() != 200 && response.getStatusCode() != 204) {
        CalloutException calloutException = new CalloutException();
        calloutException.setMessage(
          STA_UtilsStatic.BAD_STATUS_CODE + response.getStatusCode()
        ); // + ' -> BODY : ' + response.getBody());
        throw calloutException;
      }
    } catch (CalloutException calloutException) {
      System.debug(
        LoggingLevel.INFO,
        STA_UtilsStatic.BAD_STATUS_CODE +
        response.getStatusCode() +
        ' -> CalloutException : ' +
        calloutException
      );
      SMC_UTIL_Methods_Batch.createErrorLog(
        new List<CalloutException>{ calloutException },
        STA_UtilsStatic.ERROR_CASE_LOG_CIMSA_VISIT,
        STA_UtilsStatic.PICKLIST_LOGS_PROCESS_TYPE_WS,
        requestBody,
        requestQuery,
        recordList
      );
    } catch (JSONException jsonException) {
      System.debug(
        LoggingLevel.INFO,
        STA_UtilsStatic.MALFORMED_JSON +
        response.getStatusCode() +
        ' -> JSONException : ' +
        jsonException
      );
      SMC_UTIL_Methods_Batch.createErrorLog(
        new List<JSONException>{ jsonException },
        STA_UtilsStatic.ERROR_CASE_LOG_CIMSA_VISIT,
        STA_UtilsStatic.PICKLIST_LOGS_PROCESS_TYPE_WS,
        requestBody,
        requestQuery,
        recordList
      );
    } catch (Exception e) {
      System.debug(LoggingLevel.INFO, 'Exception : ' + e);
      SMC_UTIL_Methods_Batch.createErrorLog(
        new List<Exception>{ e },
        STA_UtilsStatic.ERROR_CASE_LOG_CIMSA_VISIT,
        STA_UtilsStatic.PICKLIST_LOGS_PROCESS_TYPE_WS,
        requestBody,
        requestQuery,
        recordList
      );
    }

    if (Test.isRunningTest()) {
      cimsaVisit.calloutResponse = true;
    }

    System.debug(
      LoggingLevel.INFO,
      '>>>>>>SMC_AP_CaseCallout -> Method createCimsaVisit - END'
    );
    return cimsaVisit;
  }
}