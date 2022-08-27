/*
---------------------------------------------------------------------------
-- - Name : SMC_AP_ScoringCallout
-- - Author : Vincent RECASENS
-- - Description : This class is the Apex class to call web services link 
				   to the Quotation Tool
--
-- Maintenance History:
-- /!\ DISCOUNT = SCORING /!\
-- Date         Name                    Version     Remarks
-- -----------  ----                    -------     ------------------
-- 12-FEB-2018  Vincent RECASENS  		1.0     	Initial Version
-- 20-MAR-2018  Vincent RECASENS  		2.0     	Sort lines in GET
-- 26-SEP-2018  Vincent RECASENS  		3.0     	Add getDiscountToken method
-- 31-MAY-2022  Denis PHAM            	4.0       Adptation for new Discount Form
-- 07-JUL-2022  Denis PHAM            	4.1       Adptation for new Discount Form after test on QA
---------------------------------------------------------------------------
*/

public with sharing class SMC_AP_ScoringCallout {
  public class ScoringWrapper {
    public List<Exception> exceps { get; set; }
    public Boolean upsertReturn { get; set; }
    public String logName { get; set; }
    public String errorType { get; set; }
    public String logParam { get; set; }
    public String logQuery { get; set; }
    public HttpResponse response { get; set; }
  }

  //Exception class
  public class CustomException extends Exception {} 

  /**
   * @description : get scoring token
   * @author Vincent RECASENS (Modis) | 08/04/2020
   * @param tokenInformations
   * @param tokenEndpoint
   * @param recordList
   * @return SMC_DTO_DiscountToken
   **/
  public static SMC_DTO_DiscountToken getDiscountToken(
    Call_Scoring_Domain__mdt tokenInformations,
    String tokenEndpoint,
    List<String> recordList
  ) {
    System.debug(
      LoggingLevel.INFO,
      '>>>>>>SMC_AP_ScoringCallout -> Method getDiscountToken - START'
    );

    //Error log
    List<Exception> logs = new List<Exception>();

    //Construct request body
    SMC_DTO_GetInformationsForToken discountToken = new SMC_DTO_GetInformationsForToken(); // The constructor catch current user
    discountToken.application = tokenInformations.SecurityToken_Application__c;
    discountToken.secret = tokenInformations.SecurityToken_Secret__c;

    HttpRequest request = new HttpRequest();
    request.setEndpoint(tokenEndpoint);
    request.setMethod(STA_UtilsStatic.POST_METHOD);
    request.setHeader(
      STA_UtilsStatic.CONTENT_TYPE,
      STA_UtilsStatic.APPLICATION_JSON
    );
    request.setBody(JSON.serialize(discountToken));
    request.setTimeout(60000);
    String requestBody = STA_UtilsStatic.BODY_SYSDEBUG + request.getBody();
    String requestQuery =
      STA_UtilsStatic.QUERY_SYSDEBUG + request.getEndpoint();

    Http http = new Http();
    HTTPResponse response = new HTTPResponse();
    SMC_DTO_DiscountToken jsonObject;
    try {
      System.debug(
        LoggingLevel.INFO,
        'Response for request --> ' + request
      );
      response = http.send(request);
      System.debug(
        LoggingLevel.INFO,
        'Response for TOKEN --> ' + response.getBody()
      );
      jsonObject = (SMC_DTO_DiscountToken) JSON.deserialize(
        response.getBody(),
        (SMC_DTO_DiscountToken.class)
      );

      //Error
      if (response.getStatusCode() != 200) {
        System.debug(
          LoggingLevel.INFO,
          STA_UtilsStatic.BAD_STATUS_CODE +
          response.getStatusCode() +
          ' -> BODY : ' +
          response.getBody()
        );
        CalloutException calloutException = new CalloutException();
        calloutException.setMessage(
          STA_UtilsStatic.BAD_STATUS_CODE +
          response.getStatusCode() +
          ' -> BODY : ' +
          response.getBody()
        );
        logs.add(calloutException);
        // SMC_Utils_Methods_Batch.createErrorLog(
        //   new List<Exception>{ calloutException },
        //   STA_UtilsStatic.ERROR_DISCOUNT_LOG_GET_DISCOUNT_TOKEN,
        //   STA_UtilsStatic.PICKLIST_LOGS_PROCESS_TYPE_WS,
        //   requestBody,
        //   requestQuery,
        //   recordList
        // );
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
        new List<Exception>{ calloutException },
        STA_UtilsStatic.ERROR_DISCOUNT_LOG_GET_DISCOUNT_TOKEN,
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
        new List<Exception>{ jsonException },
        STA_UtilsStatic.ERROR_DISCOUNT_LOG_GET_DISCOUNT_TOKEN,
        STA_UtilsStatic.PICKLIST_LOGS_PROCESS_TYPE_WS,
        requestBody,
        requestQuery,
        recordList
      );
    } catch (Exception e) {
      System.debug(LoggingLevel.INFO, 'Exception : ' + e);
      SMC_UTIL_Methods_Batch.createErrorLog(
        new List<Exception>{ e },
        STA_UtilsStatic.ERROR_DISCOUNT_LOG_GET_DISCOUNT_TOKEN,
        STA_UtilsStatic.PICKLIST_LOGS_PROCESS_TYPE_WS,
        requestBody,
        requestQuery,
        recordList
      );
    }

    System.debug(
      LoggingLevel.INFO,
      '>>>>>>SMC_AP_ScoringCallout -> Method getDiscountToken - END'
    );
    if (jsonObject == null) {
      return new SMC_DTO_DiscountToken();
    } else {
      return jsonObject;
    }
  }

  /**
   * @description : ask to the server if accounts have scoring
   * @author Vincent RECASENS (Modis) | 08/04/2020
   * @param body
   * @param areScoredEndpoint
   * @param token
   * @param recordList
   * @return List<SMC_DTO_Scoring_AreScored>
   **/
  public static List<SMC_DTO_Scoring_AreScored> areScoredScoring(
    String body,
    String areScoredEndpoint,
    String token,
    List<String> recordList
  ) {
    System.debug(
      LoggingLevel.INFO,
      '>>>>>>SMC_AP_ScoringCallout -> Method areScoredScoring - START'
    );

    //Error log
    List<Exception> logs = new List<Exception>();

    //Construct request body
    HttpRequest request = new HttpRequest();
    request.setEndpoint(areScoredEndpoint + UserInfo.getUserName());
    request.setMethod(STA_UtilsStatic.POST_METHOD);
    request.setHeader(
      STA_UtilsStatic.CONTENT_TYPE,
      STA_UtilsStatic.APPLICATION_JSON
    );
    request.setHeader(
      STA_UtilsStatic.AUTHORIZATION,
      STA_UtilsStatic.BEARER +
      STA_UtilsStatic.SPACE +
      token
    );
    request.setBody(body);
    request.setTimeout(60000);
    String requestBody = STA_UtilsStatic.BODY_SYSDEBUG + request.getBody();
    String requestQuery =
      STA_UtilsStatic.QUERY_SYSDEBUG + request.getEndpoint();

    Http http = new Http();
    HTTPResponse response = new HTTPResponse();
    List<SMC_DTO_Scoring_AreScored> jsonObject;
    try {
      response = http.send(request);
      System.debug(
        LoggingLevel.INFO,
        'Response for ARE SCORED --> ' + response.getBody()
      );
      jsonObject = (List<SMC_DTO_Scoring_AreScored>) JSON.deserialize(
        response.getBody(),
        (List<SMC_DTO_Scoring_AreScored>.class)
      );

      //Error
      if (response.getStatusCode() != 200) {
        System.debug(
          LoggingLevel.INFO,
          STA_UtilsStatic.BAD_STATUS_CODE +
          response.getStatusCode() +
          ' -> BODY : ' +
          response.getBody()
        );
        CalloutException calloutException = new CalloutException();
        calloutException.setMessage(
          STA_UtilsStatic.BAD_STATUS_CODE +
          response.getStatusCode() +
          ' -> BODY : ' +
          response.getBody()
        );
        logs.add(calloutException);
        // SMC_Utils_Methods_Batch.createErrorLog(
        //   new List<Exception>{ calloutException },
        //   STA_UtilsStatic.ERROR_DISCOUNT_LOG_ARESCORED,
        //   STA_UtilsStatic.PICKLIST_LOGS_PROCESS_TYPE_WS,
        //   requestBody,
        //   requestQuery,
        //   recordList
        // );
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
        new List<Exception>{ calloutException },
        STA_UtilsStatic.ERROR_DISCOUNT_LOG_ARESCORED,
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
        new List<Exception>{ jsonException },
        STA_UtilsStatic.ERROR_DISCOUNT_LOG_ARESCORED,
        STA_UtilsStatic.PICKLIST_LOGS_PROCESS_TYPE_WS,
        requestBody,
        requestQuery,
        recordList
      );
    } catch (Exception e) {
      System.debug(LoggingLevel.INFO, 'Exception : ' + e);
      SMC_UTIL_Methods_Batch.createErrorLog(
        new List<Exception>{ e },
        STA_UtilsStatic.ERROR_DISCOUNT_LOG_ARESCORED,
        STA_UtilsStatic.PICKLIST_LOGS_PROCESS_TYPE_WS,
        requestBody,
        requestQuery,
        recordList
      );
    }

    System.debug(
      LoggingLevel.INFO,
      '>>>>>>SMC_AP_ScoringCallout -> Method areScoredScoring - END'
    );
    return jsonObject;
  }

  /**
   * @description : upsert scoring
   * @author Vincent RECASENS (Modis) | 08/04/2020
   * @param body
   * @param calloutMethod
   * @param methodendpoint
   * @param token
   * @param recordList
   * @return ScoringWrapper
   **/
  public static ScoringWrapper upsertScoring(
    String body,
    String calloutMethod,
    String methodendpoint,
    String token,
    List<String> recordList
  ) {
    System.debug(
      LoggingLevel.INFO,
      '>>>>>>SMC_AP_ScoringCallout -> Method updateOneScoring - START'
    );

    // Define errorLog
    String errorLogName = STA_UtilsStatic.ERROR_DISCOUNT_LOG_UPSERT;
    List<Exception> logs = new List<Exception>();
    if (calloutMethod == STA_UtilsStatic.POST_METHOD) {
      errorLogName = STA_UtilsStatic.ERROR_DISCOUNT_LOG_INITIATE;
    } else if (calloutMethod == STA_UtilsStatic.PUT_METHOD) {
      errorLogName = STA_UtilsStatic.ERROR_DISCOUNT_LOG_UPDATE;
    }

    //Construct request body
    HttpRequest request = new HttpRequest();
    request.setEndpoint(methodendpoint + UserInfo.getUserName());
    request.setMethod(calloutMethod);
    request.setHeader(
      STA_UtilsStatic.CONTENT_TYPE,
      STA_UtilsStatic.APPLICATION_JSON
    );
    request.setHeader(
      STA_UtilsStatic.AUTHORIZATION,
      STA_UtilsStatic.BEARER +
      STA_UtilsStatic.SPACE +
      token
    );
    request.setBody(body);
    request.setTimeout(60000);
    String requestBody = STA_UtilsStatic.BODY_SYSDEBUG + request.getBody();
    String requestQuery =
      STA_UtilsStatic.QUERY_SYSDEBUG + request.getEndpoint();

    Http http = new Http();
    HttpResponse response = new HttpResponse();
    ScoringWrapper wrapToReturn = new ScoringWrapper();
    try {
      response = http.send(request);
      wrapToReturn.response = response;
      System.debug(
        LoggingLevel.INFO,
        'Response for UPSERT --> ' + response.getBody()
      );

      //Error
      if (response.getStatusCode() != 200 && response.getStatusCode() != 201) {
        System.debug(
          LoggingLevel.INFO,
          STA_UtilsStatic.BAD_STATUS_CODE +
          response.getStatusCode() +
          ' -> BODY : ' +
          response.getBody()
        );
        CalloutException calloutException = new CalloutException();
        calloutException.setMessage(
          STA_UtilsStatic.BAD_STATUS_CODE +
          response.getStatusCode() +
          ' -> BODY : ' +
          response.getBody()
        );
        logs.add(calloutException);
        // SMC_Utils_Methods_Batch.createErrorLog(
        //   new List<Exception>{ calloutException },
        //   STA_UtilsStatic.ERROR_DISCOUNT_LOG_UPSERT,
        //   STA_UtilsStatic.PICKLIST_LOGS_PROCESS_TYPE_WS,
        //   requestBody,
        //   requestQuery,
        //   recordList
        // );
        throw calloutException;
      }
    } catch (CalloutException calloutException) {
      System.debug(LoggingLevel.INFO, 'CalloutException : ' + calloutException);
      logs.add(calloutException);
      SMC_UTIL_Methods_Batch.createErrorLog(
        new List<Exception>{ calloutException },
        STA_UtilsStatic.ERROR_DISCOUNT_LOG_UPSERT,
        STA_UtilsStatic.PICKLIST_LOGS_PROCESS_TYPE_WS,
        requestBody,
        requestQuery,
        recordList
      );
    } catch (Exception e) {
      System.debug(LoggingLevel.INFO, 'Exception : ' + e);
      logs.add(e);
      SMC_UTIL_Methods_Batch.createErrorLog(
        new List<Exception>{ e },
        STA_UtilsStatic.ERROR_DISCOUNT_LOG_UPSERT,
        STA_UtilsStatic.PICKLIST_LOGS_PROCESS_TYPE_WS,
        requestBody,
        requestQuery,
        recordList
      );
    }

    wrapToReturn.exceps = logs;
    wrapToReturn.logName = errorLogName;
    wrapToReturn.errorType = STA_UtilsStatic.PICKLIST_LOGS_PROCESS_TYPE_WS;
    wrapToReturn.logParam = requestBody;
    wrapToReturn.logQuery = requestQuery;
    wrapToReturn.upsertReturn = true;
    return wrapToReturn;
  }

  /**
   * @description : get all existing scoring
   * @author Vincent RECASENS (Modis) | 08/04/2020
   * @param body
   * @param areScoredEndpoint
   * @param token
   * @param recordList
   * @return List<SMC_DTO_GetAllScoring>
   **/
  public static List<SMC_DTO_GetAllScoring> getAllScoring(
    String body,
    String areScoredEndpoint,
    String token,
    List<String> recordList
  ) {
    System.debug(
      LoggingLevel.INFO,
      '>>>>>>SMC_AP_ScoringCallout -> Method getAllScoring - START'
    );
    System.debug(LoggingLevel.INFO, 'body : ' + body);
    System.debug(LoggingLevel.INFO, 'areScoredEndpoint : ' + areScoredEndpoint);
    System.debug(
      LoggingLevel.INFO,
      'token1 : ' + token.substring(0, Math.round((token.length() / 2)))
    );
    System.debug(
      LoggingLevel.INFO,
      'token2 : ' +
      token.substring(Math.round((token.length() / 2)), token.length())
    );

    //Error log
    List<Exception> logs = new List<Exception>();

    //Construct request body
    HttpRequest request = new HttpRequest();
    request.setEndpoint(areScoredEndpoint + UserInfo.getUserName());
    request.setMethod(STA_UtilsStatic.POST_METHOD);
    request.setHeader(
      STA_UtilsStatic.CONTENT_TYPE,
      STA_UtilsStatic.APPLICATION_JSON
    );
    request.setHeader(
      STA_UtilsStatic.AUTHORIZATION,
      STA_UtilsStatic.BEARER +
      STA_UtilsStatic.SPACE +
      token
    );
    request.setBody(body);
    request.setTimeout(60000);
    String requestQuery =
      STA_UtilsStatic.QUERY_SYSDEBUG + request.getEndpoint();
    String requestBody = STA_UtilsStatic.BODY_SYSDEBUG + request.getBody();

    Http http = new Http();
    HTTPResponse response = new HTTPResponse();
    List<SMC_DTO_GetAllScoring> jsonObject;
    try {
      response = http.send(request);
      System.debug(
        LoggingLevel.INFO,
        'Response for GET ALL --> ' + response.getBody()
      );
      jsonObject = (List<SMC_DTO_GetAllScoring>) JSON.deserialize(
        response.getBody(),
        (List<SMC_DTO_GetAllScoring>.class)
      );

      //Error
      if (response.getStatusCode() != 200) {
        System.debug(
          LoggingLevel.INFO,
          STA_UtilsStatic.BAD_STATUS_CODE +
          response.getStatusCode() +
          ' -> BODY : ' +
          response.getBody()
        );
        CalloutException calloutException = new CalloutException();
        calloutException.setMessage(
          STA_UtilsStatic.BAD_STATUS_CODE +
          response.getStatusCode() +
          ' -> BODY : ' +
          response.getBody()
        );
        logs.add(calloutException);
        // SMC_Utils_Methods_Batch.createErrorLog(
        //   new List<Exception>{ calloutException },
        //   STA_UtilsStatic.ERROR_DISCOUNT_LOG_GET_ALL,
        //   STA_UtilsStatic.PICKLIST_LOGS_PROCESS_TYPE_WS,
        //   requestBody,
        //   requestQuery,
        //   recordList
        // );
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
        new List<Exception>{ calloutException },
        STA_UtilsStatic.ERROR_DISCOUNT_LOG_GET_ALL,
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
        new List<Exception>{ jsonException },
        STA_UtilsStatic.ERROR_DISCOUNT_LOG_GET_ALL,
        STA_UtilsStatic.PICKLIST_LOGS_PROCESS_TYPE_WS,
        requestBody,
        requestQuery,
        recordList
      );
    } catch (Exception e) {
      System.debug(LoggingLevel.INFO, 'Exception : ' + e);
      SMC_UTIL_Methods_Batch.createErrorLog(
        new List<Exception>{ e },
        STA_UtilsStatic.ERROR_DISCOUNT_LOG_GET_ALL,
        STA_UtilsStatic.PICKLIST_LOGS_PROCESS_TYPE_WS,
        requestBody,
        requestQuery,
        recordList
      );
    }

    System.debug(
      LoggingLevel.INFO,
      '>>>>>>SMC_AP_ScoringCallout -> Method getAllScoring - END'
    );
    return jsonObject;
  }

  /**
   * @description : save scoring modification
   * @author Vincent RECASENS (Modis) | 08/04/2020
   * @param body
   * @param saveEndpoint
   * @param token
   * @param recordList
   * @return Boolean
   **/
  public static Boolean saveScoring(
    String body,
    String saveEndpoint,
    String token,
    List<String> recordList
  ) {
    System.debug(
      LoggingLevel.INFO,
      '>>>>>>SMC_AP_ScoringCallout -> Method saveScoring - START'
    );
    System.debug(LoggingLevel.INFO, 'body : ' + body);
    System.debug(
      LoggingLevel.INFO,
      'token1 : ' + token.substring(0, Math.round((token.length() / 2)))
    );
    System.debug(
      LoggingLevel.INFO,
      'token2 : ' +
      token.substring(Math.round((token.length() / 2)), token.length())
    );

    //Error log
    List<Exception> logs = new List<Exception>();

    //Construct request body
    HttpRequest request = new HttpRequest();
    request.setEndpoint(saveEndpoint + UserInfo.getUserName());
    request.setMethod(STA_UtilsStatic.PUT_METHOD);
    request.setHeader(
      STA_UtilsStatic.CONTENT_TYPE,
      STA_UtilsStatic.APPLICATION_JSON
    );
    request.setHeader(
      STA_UtilsStatic.AUTHORIZATION,
      STA_UtilsStatic.BEARER +
      STA_UtilsStatic.SPACE +
      token
    );
    request.setBody(body);
    request.setTimeout(60000);
    String requestBody = STA_UtilsStatic.BODY_SYSDEBUG + request.getBody();
    String requestQuery =
      STA_UtilsStatic.QUERY_SYSDEBUG + request.getEndpoint();

    System.debug(LoggingLevel.INFO, requestQuery);
    System.debug(LoggingLevel.INFO, requestBody);

    Http http = new Http();
    HttpResponse response = new HttpResponse();
    Datetime stTime = Datetime.now();
    System.debug(LoggingLevel.INFO, 'StartTime : ' + Datetime.now());
    try {
      response = http.send(request);
      System.debug(
        LoggingLevel.INFO,
        'Response for SAVE --> ' + response.getBody()
      );
      Datetime endTime = Datetime.now();
      System.debug(LoggingLevel.INFO, 'EndTime : ' + endTime);
      System.debug(
        LoggingLevel.INFO,
        'Diff : ' + String.valueOf(endTime.getTime() - stTime.getTime())
      );

      //Error
      if (response.getStatusCode() != 200 && response.getStatusCode() != 201) {
        System.debug(
          LoggingLevel.INFO,
          STA_UtilsStatic.BAD_STATUS_CODE +
          response.getStatusCode() +
          ' -> BODY : ' +
          response.getBody()
        );
        CalloutException calloutException = new CalloutException();
        calloutException.setMessage(
          STA_UtilsStatic.BAD_STATUS_CODE +
          response.getStatusCode() +
          ' -> BODY : ' +
          response.getBody()
        );
        logs.add(calloutException);
        // SMC_Utils_Methods_Batch.createErrorLog(
        //   new List<Exception>{ calloutException },
        //   STA_UtilsStatic.ERROR_DISCOUNT_LOG_SAVE,
        //   STA_UtilsStatic.PICKLIST_LOGS_PROCESS_TYPE_WS,
        //   requestBody,
        //   requestQuery,
        //   recordList
        // );
        // return false;
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
        new List<Exception>{ calloutException },
        STA_UtilsStatic.ERROR_DISCOUNT_LOG_SAVE,
        STA_UtilsStatic.PICKLIST_LOGS_PROCESS_TYPE_WS,
        requestBody,
        requestQuery,
        recordList
      );
      System.debug(
        LoggingLevel.INFO,
        '>>>>>>SMC_AP_ScoringCallout -> Method saveScoring - END with CalloutException'
      );
      return false;
    } catch (Exception e) {
      System.debug(LoggingLevel.INFO, 'Exception : ' + e);
      SMC_UTIL_Methods_Batch.createErrorLog(
        new List<Exception>{ e },
        STA_UtilsStatic.ERROR_DISCOUNT_LOG_SAVE,
        STA_UtilsStatic.PICKLIST_LOGS_PROCESS_TYPE_WS,
        requestBody,
        requestQuery,
        recordList
      );
      System.debug(
        LoggingLevel.INFO,
        '>>>>>>SMC_AP_ScoringCallout -> Method saveScoring - END with Exception'
      );
      return false;
    }

    System.debug(
      LoggingLevel.INFO,
      '>>>>>>SMC_AP_ScoringCallout -> Method saveScoring - END'
    );
    return true;
  }


  /**
   * @description : Get scoring for an Account
   * @author Denis PHAM (Modis) | 24/05/2022
   * @param body
   * @param getEndpoint
   * @param token
   * @param recordList
   * @return List<SMC_DTO_GetAllScoring>
   **/
  public static SMC_DTO_GetScoring getScoring_v2(
    String body,
    String getEndpoint,
    String token,
    List<String> recordList
  ) {
    System.debug(
      LoggingLevel.INFO,
      '>>>>>>SMC_AP_ScoringCallout -> Method getScoring_v2 - START'
    );
    System.debug(LoggingLevel.INFO, 'body : ' + body);

    //Error log
    List<Exception> logs = new List<Exception>();

    //Construct request body
    HttpRequest request = new HttpRequest();
    request.setEndpoint(getEndpoint + UserInfo.getUserName());
    request.setMethod(STA_UtilsStatic.POST_METHOD);
    request.setHeader(
      STA_UtilsStatic.CONTENT_TYPE,
      STA_UtilsStatic.APPLICATION_JSON
    );
    request.setHeader(
      STA_UtilsStatic.AUTHORIZATION,
      STA_UtilsStatic.BEARER +
      STA_UtilsStatic.SPACE +
      token
    );
    request.setBody(body);
    request.setTimeout(60000);
    String requestQuery =
      STA_UtilsStatic.QUERY_SYSDEBUG + request.getEndpoint();
    String requestBody = STA_UtilsStatic.BODY_SYSDEBUG + request.getBody();
    System.debug('request ++++++++++++++++++++++ ' +  request);

    Http http = new Http();
    HTTPResponse response = new HTTPResponse();
      
    SMC_DTO_GetScoring jsonObject;
    SMC_DTO_GetScoring_Error dtoError;
    try {
      response = http.send(request);
      System.debug(
        LoggingLevel.INFO,
        'Resp v2 :' + response.getBody()
      );

      jsonObject = (SMC_DTO_GetScoring) JSON.deserialize(
        response.getBody(),
        (SMC_DTO_GetScoring.class)
      );

      System.debug(' jsonObject ++++++++++++++++++++++ ' +  jsonObject);
      // //Error
      // if (response.getStatusCode() != 200 && response.getStatusCode() != 204) {
      //   System.debug(
      //     LoggingLevel.INFO,
      //     STA_UtilsStatic.BAD_STATUS_CODE +
      //     response.getStatusCode() +
      //     ' -> BODY GET V2: ' +
      //     response.getBody()
      //   );
      //   CalloutException calloutException = new CalloutException();
      //   calloutException.setMessage(
      //     STA_UtilsStatic.BAD_STATUS_CODE +
      //     response.getStatusCode() +
      //     ' -> BODY GET V2: ' +
      //     response.getBody()
      //   );
      //   logs.add(calloutException);
      //   throw calloutException;
      // }
    } catch (CalloutException calloutException) {
      System.debug(
        LoggingLevel.INFO,
        STA_UtilsStatic.BAD_STATUS_CODE +
        response.getStatusCode() +
        ' -> CalloutException : ' +
        calloutException
      );
      SMC_UTIL_Methods_Batch.createErrorLog(
        new List<Exception>{ calloutException },
        STA_UtilsStatic.ERROR_DISCOUNT_LOG_GET_ALL,
        STA_UtilsStatic.PICKLIST_LOGS_PROCESS_TYPE_WS,
        requestBody,
        requestQuery,
        recordList
      );

      dtoError = (SMC_DTO_GetScoring_Error) JSON.deserialize(
        response.getBody(),
        (SMC_DTO_GetScoring_Error.class)
      );
      throw new CustomException( dtoError.message ,calloutException);
    } catch (JSONException jsonException) {
      System.debug(
        LoggingLevel.INFO,
        STA_UtilsStatic.MALFORMED_JSON +
        response.getStatusCode() +
        ' -> JSONException : ' +
        jsonException
      );
      SMC_UTIL_Methods_Batch.createErrorLog(
        new List<Exception>{ jsonException },
        STA_UtilsStatic.ERROR_DISCOUNT_LOG_GET_ALL,
        STA_UtilsStatic.PICKLIST_LOGS_PROCESS_TYPE_WS,
        requestBody,
        requestQuery,
        recordList
      );
        
      dtoError = (SMC_DTO_GetScoring_Error) JSON.deserialize(
        response.getBody(),
        (SMC_DTO_GetScoring_Error.class)
      );
        
      throw new CustomException( dtoError.message ,jsonException);
    } catch (Exception e) {
      System.debug(LoggingLevel.INFO, 'Exception : ' + e);
      SMC_UTIL_Methods_Batch.createErrorLog(
        new List<Exception>{ e },
        STA_UtilsStatic.ERROR_DISCOUNT_LOG_GET_ALL,
        STA_UtilsStatic.PICKLIST_LOGS_PROCESS_TYPE_WS,
        requestBody,
        requestQuery,
        recordList
      );
      dtoError = (SMC_DTO_GetScoring_Error) JSON.deserialize(
        response.getBody(),
        (SMC_DTO_GetScoring_Error.class)
      );
      throw new CustomException( dtoError.message ,e);
    }

    System.debug(
      LoggingLevel.INFO,
      '>>>>>>SMC_AP_ScoringCallout -> Method getScoring_v2 - END'
    );
    return jsonObject;
  }
}