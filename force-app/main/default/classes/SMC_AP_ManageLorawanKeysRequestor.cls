/**
 * @description       :
 * @author            : Vincent RECASENS (Modis)
 * @group             :
 * @last modified on  : 02-11-2021
 * @last modified by  : Vincent RECASENS (Modis)
 * Modifications Log
 * Ver   Date         Author                     Modification
 * 1.0   12-24-2020   Vincent RECASENS (Modis)   Initial Version
 **/
public without sharing class SMC_AP_ManageLorawanKeysRequestor {
  public class WrapperPostBody {
    public String email;
    public String first_name;
    public String last_name;
    public String Country;
    public String Phone;
    public String Company;

    public WrapperPostBody() {
    }
    public WrapperPostBody(
      String email,
      String first_name,
      String last_name,
      String Country,
      String Phone,
      String Company
    ) {
      this.email = email;
      this.first_name = first_name;
      this.last_name = last_name;
      this.Country = Country;
      this.Phone = Phone;
      this.Company = Company;
    }
  }

  /**
   * @description : send FormHandler to Pardot
   * @author Vincent RECASENS (Modis) | 12-24-2020
   **/
  public static void sendFormToPardot(
    Map<Id, SMC_Lorawan_Keys_Requestor__c> newMap,
    Map<Id, SMC_Lorawan_Keys_Requestor__c> oldMap
  ) {
    //Check before send to Pardot
    //Condition : phone updated
    Id requestorToSendToPardotId;
    for (Id oneId : newMap.keySet()) {
      SMC_Lorawan_Keys_Requestor__c newRequestor = newMap.get(oneId);
      SMC_Lorawan_Keys_Requestor__c oldRequestor = oldMap.get(oneId);
      if (
        (newRequestor.Type__c == 'Guest' || Test.isRunningTest()) &&
        newRequestor.Phone__c != null &&
        newRequestor.Phone__c != oldRequestor.Phone__c
      ) {
        requestorToSendToPardotId = newRequestor.Id;
      }
    }

    if (requestorToSendToPardotId != null) {
      //Form can be sent only by Community from one person : there is only one requestor triggered
      //   System.enqueueJob(new QueueableHttpRequest(requestorToSendToPardot));
      try {
        postToPardot(requestorToSendToPardotId);
      } catch (Exception e) {
        System.debug(
          'There is en error when sending form to pardot : ERROR --> ' +
          e.getMessage()
        );
      }
    }
  }

  @TestVisible
  @Future(callout=true)
  private static void postToPardot(Id requestorId) {
    SMC_Lorawan_Keys_Requestor__c requestor = [
      SELECT
        Id,
        Company__c,
        Country__c,
        Email__c,
        First_Name__c,
        Last_Name__c,
        Phone__c
      FROM SMC_Lorawan_Keys_Requestor__c
      WHERE Id = :requestorId
    ];
    //Build the callout*****
    HttpRequest request = new HttpRequest();
    request.setEndpoint('callout:Lora_To_Pardot/l/86922/2020-12-22/6t72wr');
    request.setMethod(STA_UtilsStatic.POST_METHOD);
    request.setHeader(
      STA_UtilsStatic.CONTENT_TYPE,
      STA_UtilsStatic.APPLICATION_JSON
    );
    request.setBody(buildBody(requestor));
    request.setTimeout(60000);

    String requestBody = STA_UtilsStatic.BODY_SYSDEBUG + request.getBody();
    String requestQuery =
      STA_UtilsStatic.QUERY_SYSDEBUG + request.getEndpoint();

    Http http = new Http();
    HTTPResponse response = new HTTPResponse();
    String htmlResponse = STA_UtilsStatic.EMPTY_STRING;

    try {
      response = http.send(request);
      htmlResponse = response.getBody();

      System.debug(LoggingLevel.INFO, 'htmlResponse : ' + htmlResponse);

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
        new List<String>{ requestor.Id }
      );
      if (Test.isRunningTest()) {
        throw calloutException;
      }
    } catch (Exception e) {
      System.debug(LoggingLevel.INFO, 'Exception : ' + e);
      SMC_UTIL_Methods_Batch.createErrorLog(
        new List<Exception>{ e },
        'LORA - Form Handler to Pardot ERROR',
        STA_UtilsStatic.PICKLIST_LOGS_PROCESS_TYPE_WS,
        requestBody,
        requestQuery,
        new List<String>{ requestor.Id }
      );
      if (Test.isRunningTest()) {
        throw e;
      }
    }
  }

  @TestVisible
  private static String buildBody(SMC_Lorawan_Keys_Requestor__c requestor) {
    return JSON.serialize(
      new WrapperPostBody(
        requestor.Email__c,
        requestor.First_Name__c,
        requestor.Last_Name__c,
        requestor.Country__c,
        requestor.Phone__c,
        requestor.Company__c
      )
    );
  }
}