/**
 * @description       :
 * @author            : Vincent RECASENS (Modis)
 * @group             :
 * @last modified on  : 03-12-2021
 * @last modified by  : Vincent RECASENS (Modis)
 * Modifications Log
 * Ver   Date         Author                     Modification
 * 1.0   03-03-2021   Vincent RECASENS (Modis)   Initial Version
 **/
public without sharing class SMC_AC_LoraWan_IOT_Keys {
  /*************************************** DTO/WRAPPER ***************************************/
  public class DTOResponseGlobal {
    @AuraEnabled
    public String devEUI { get; set; }
    @AuraEnabled
    public String appEUI { get; set; }
    @AuraEnabled
    public String appKey { get; set; }
    @AuraEnabled
    public String serialNumber { get; set; }
    @AuraEnabled
    public String theclass { get; set; }
    @AuraEnabled
    public String deviceType { get; set; }
    @AuraEnabled
    public String netId { get; set; }
    @AuraEnabled
    public String reference { get; set; }
    @AuraEnabled
    public String manufacturerSN { get; set; }
    @AuraEnabled
    public String firmwareVersion { get; set; }
    @AuraEnabled
    public String abpDevAddr { get; set; }
    @AuraEnabled
    public String abpNwkSKey { get; set; }
    @AuraEnabled
    public String abpAppSKey { get; set; }
    @AuraEnabled
    public String codeFamille { get; set; }
    @AuraEnabled
    public String unconfirmed { get; set; }
    @AuraEnabled
    public String synchro { get; set; }
    @AuraEnabled
    public String adr { get; set; }

    public DTOResponseGlobal() {
    }

    public DTOResponseGlobal(String devEUI) {
      this.devEUI = devEUI;
    }
  }

  public class DTOResponse {
    @AuraEnabled
    public Integer take { get; set; }
    @AuraEnabled
    public Integer total { get; set; }
    @AuraEnabled
    public String format { get; set; }
    @AuraEnabled
    public List<SMC_AC_LoraWan_IOT_Keys.DTOResponseGlobal> result { get; set; }

    public DTOResponse() {
      this.take = 1000;
      this.result = new List<SMC_AC_LoraWan_IOT_Keys.DTOResponseGlobal>();
    }
    public DTOResponse(String format) {
      this.format = format;
      this.result = new List<SMC_AC_LoraWan_IOT_Keys.DTOResponseGlobal>();
    }
    public DTOResponse(Integer take, String format) {
      this.take = take;
      this.format = format;
      this.result = new List<SMC_AC_LoraWan_IOT_Keys.DTOResponseGlobal>();
    }
    public DTOResponse(Integer take, Integer total, String format) {
      this.take = take;
      this.total = total;
      this.format = format;
      this.result = new List<SMC_AC_LoraWan_IOT_Keys.DTOResponseGlobal>();
    }
  }

  public class WrapperToPrintColumn {
    @AuraEnabled
    public String label { get; set; }
    @AuraEnabled
    public String fieldName { get; set; }
    @AuraEnabled
    public String type { get; set; }

    public WrapperToPrintColumn() {
    }
    public WrapperToPrintColumn(String label, String fieldName, String type) {
      this.label = label;
      this.fieldName = fieldName;
      this.type = type;
    }
  }

  public class WrapperToPrintDatas {
    @AuraEnabled
    public String responseClientFileName { get; set; }
    @AuraEnabled
    public List<SMC_AC_LoraWan_IOT_Keys.WrapperToPrintColumn> responseClientColumn {
      get;
      set;
    }
    @AuraEnabled
    public SMC_AC_LoraWan_IOT_Keys.DTOResponse responseClient { get; set; }
    @AuraEnabled
    public List<String> responseClientInvalidDevEUI { get; set; }
    @AuraEnabled
    public String responseNkeFileName { get; set; }
    @AuraEnabled
    public String responseNkeColumn { get; set; }
    @AuraEnabled
    public SMC_AC_LoraWan_IOT_Keys.DTOResponse responseNke { get; set; }
    @AuraEnabled
    public String responseNkeToPrint { get; set; }
    @AuraEnabled
    public List<String> responseNkeInvalidDevEUI { get; set; }

    public WrapperToPrintDatas() {
      this.responseNkeColumn = 'DevEUI;ABP_DevAddr;ABP_NwkSKey;ABP_AppSKey;CodeFamille;Version;OTA_AppKey;OTA_AppEUI;Unconfirmed;CodeFamillePF;Synchro;Adr;SNnke\n';
      this.responseClientColumn = new List<SMC_AC_LoraWan_IOT_Keys.WrapperToPrintColumn>{
        new SMC_AC_LoraWan_IOT_Keys.WrapperToPrintColumn(
          'DevEUI',
          'devEUI',
          'txt'
        ),
        new SMC_AC_LoraWan_IOT_Keys.WrapperToPrintColumn(
          'AppEUI',
          'appEUI',
          'txt'
        ),
        new SMC_AC_LoraWan_IOT_Keys.WrapperToPrintColumn(
          'AppKey',
          'appKey',
          'txt'
        ),
        new SMC_AC_LoraWan_IOT_Keys.WrapperToPrintColumn(
          'Serial Number',
          'serialNumber',
          'txt'
        ),
        new SMC_AC_LoraWan_IOT_Keys.WrapperToPrintColumn(
          'Reference',
          'reference',
          'txt'
        ),
        new SMC_AC_LoraWan_IOT_Keys.WrapperToPrintColumn(
          'Class',
          'theclass',
          'txt'
        ),
        new SMC_AC_LoraWan_IOT_Keys.WrapperToPrintColumn(
          'Device Type',
          'deviceType',
          'txt'
        ),
        new SMC_AC_LoraWan_IOT_Keys.WrapperToPrintColumn(
          'NetId',
          'netId',
          'txt'
        ),
        new SMC_AC_LoraWan_IOT_Keys.WrapperToPrintColumn(
          'Firmware version',
          'firmwareVersion',
          'txt'
        )
      };
      this.responseClient = new SMC_AC_LoraWan_IOT_Keys.DTOResponse();
      this.responseClientInvalidDevEUI = new List<String>();
      this.responseNke = new SMC_AC_LoraWan_IOT_Keys.DTOResponse();
      this.responseNkeInvalidDevEUI = new List<String>();
    }
  }

  /*************************************** FORMATTER ***************************************/
  /**
   * @description : build Map<String, String>
   * @author Vincent RECASENS (Modis) | 03-03-2021
   * @param infos
   * @return Map<String, String>
   **/
  @TestVisible
  private static String buildUrl(
    String urlBase,
    String format,
    List<String> devEUIs
  ) {
    if (devEUIs.size() == 0) {
      throw new MissingDevEUIsException(
        'There are no "devEUIs" filled. Please, report the error to your Salesforce administrator.'
      );
    }
    String urlEnding = urlBase + format + '&';
    for (String devEUI : devEUIs) {
      if(devEUI != null && devEUI != ''){
        urlEnding += 'devEUIs=' + devEUI + '&';
      }
    }
    return urlEnding.removeEnd('&');
  }

  /**
   * @description : used to match the desired format
   * @author Vincent RECASENS (Modis) | 03-03-2021
   * @return String
   **/
  @TestVisible
  private static String formatDatetime() {
    String justNow = Datetime.now().format('yyyy-MM-dd\'T\'HH:mm:ss.SSS');
    String[] dateTab = justNow.split('T')[0].split('-');
    String[] timeTab = justNow.split('T')[1].split(':');
    String datetimeFormatted =
      dateTab[0] +
      dateTab[1] +
      dateTab[2] +
      '-' +
      timeTab[0] +
      timeTab[1] +
      timeTab[2];
    return datetimeFormatted;
  }

  /**
   * @description : used to format string to MAC address
   * @author Vincent RECASENS (Modis) | 03-03-2021
   * @param devEUI
   * @return String
   **/
  @TestVisible
  private static String formatToMac(String devEUI) {
    String formattedString = '';
    for (Integer i = 2; i <= devEUI.length(); i += 2) {
      formattedString += devEUI.substring(i - 2, i) + ':';
    }
    return formattedString.removeEnd(':');
  }

  /**
   * @description : used to format string to MAC address
   * @author Vincent RECASENS (Modis) | 03-03-2021
   * @param devEUI
   * @return String
   **/
  @TestVisible
  private static Object formatDatasForFile(
    String format,
    List<SMC_AC_LoraWan_IOT_Keys.DTOResponseGlobal> datas
  ) {
    //Format = CLIENT
    if (format == System.Label.SMC_CLIENT) {
      for (Integer i = 0; i < datas.size(); ++i) {
        datas[i].devEUI = (datas[i].devEUI != null
          ? datas[i].devEUI.toUpperCase()
          : '');
        datas[i].appEUI = (datas[i].appEUI != null
          ? datas[i].appEUI.toUpperCase()
          : '');
        datas[i].appKey = (datas[i].appKey != null
          ? datas[i].appKey.toUpperCase()
          : '');
        datas[i].netId = (datas[i].netId != null
          ? datas[i].netId.toUpperCase()
          : '');
      }
      return datas;
    } else if (format == System.Label.SMC_NKE) {
      //Format = NKE
      String finalstr = '';
      for (SMC_AC_LoraWan_IOT_Keys.DTOResponseGlobal oneData : datas) {
        String oneLine =
          '' +
          (oneData.devEUI != null
            ? formatToMac(oneData.devEUI.toUpperCase())
            : '') +
          ';' +
          '' +
          (oneData.abpDevAddr != null ? oneData.abpDevAddr.toUpperCase() : '') +
          ';' +
          '' +
          (oneData.abpNwkSKey != null ? oneData.abpNwkSKey.toUpperCase() : '') +
          ';' +
          '' +
          (oneData.abpAppSKey != null ? oneData.abpAppSKey.toUpperCase() : '') +
          ';' +
          '' +
          (oneData.codeFamille != null ? oneData.codeFamille : '') +
          ';' +
          '' +
          (oneData.firmwareVersion != null ? oneData.firmwareVersion : '') +
          ';' +
          '' +
          (oneData.appKey != null ? oneData.appKey.toUpperCase() : '') +
          ';' +
          '' +
          (oneData.appEUI != null ? oneData.appEUI.toUpperCase() : '') +
          ';' +
          '' +
          (oneData.unconfirmed != null ? oneData.unconfirmed : '') +
          ';' +
          '' +
          (oneData.codeFamille != null ? oneData.codeFamille : '') +
          ';' +
          '' +
          (oneData.synchro != null ? oneData.synchro : '') +
          ';' +
          '' +
          (oneData.adr != null ? oneData.adr : '') +
          ';' +
          '' +
          (oneData.serialNumber != null ? oneData.serialNumber : '') +
          '\n';
        finalstr += oneLine;
      }
      return finalstr;
    }
    return null;
  }

  /**
   * @description : used to check invalid/not returned "devEUIs"
   * @author Vincent RECASENS (Modis) | 03-04-2021
   * @param datasTocheck
   * @return List<String>
   **/
  @TestVisible
  private static List<String> checkInvalidLine(
    List<String> listDevEUIs,
    SMC_AC_LoraWan_IOT_Keys.DTOResponse datasTocheck
  ) {
    //Set a list with devEUI returned
    List<String> devEUIreturned = new List<String>();
    List<String> devEUINotreturned = new List<String>();
    for (
      SMC_AC_LoraWan_IOT_Keys.DTOResponseGlobal oneData : datasTocheck.result
    ) {
      devEUIreturned.add(oneData.devEUI.toUpperCase());
    }
    //Set a list with devEUI NOT returned to display it
    for (String oneStr : listDevEUIs) {
      if (!devEUIreturned.contains(oneStr.toUpperCase())) {
        devEUINotreturned.add(oneStr);
      }
    }
    
    return devEUINotreturned;
  }

  /*************************************** GETTER ***************************************/
  /**
   * @description : get callout informations (endpoint, authorization...)
   * @author Vincent RECASENS (Modis) | 10/04/2020
   * @return Endpoint_DocList_Community__mdt
   **/
  @TestVisible
  private static SMC_IOT_Key__mdt getEndpoint(String tokenOrDatas) {
    //Get metadata
    SMC_IOT_Key__mdt theMdt = [
      SELECT
        URL__c,
        URL_DEVINT__c,
        URL_QA__c,
        URL_PROD__c,
        Authorization__c,
        Authorization_DEV_INT__c,
        Authorization_QA_PREPROD__c,
        Authorization_PROD__c,
        username__c,
        SMC_Is_Mocking_Mode__c
      FROM SMC_IOT_Key__mdt
      WHERE DeveloperName = :tokenOrDatas
    ];
    

    //If host == mdt.Org__c -> PRODUCTION
    String host;
    host = URL.getSalesforceBaseUrl().getHost();
    if(host.contains('DEV') || 
       host.contains('dev') || 
       host.contains('INT') || 
       host.contains('int')){
        // theMdt.Authorization__c = theMdt.Authorization_PROD__c;
        // theMdt.URL__c = theMdt.URL_PROD__c;
        theMdt.Authorization__c = theMdt.Authorization_DEV_INT__c;
        theMdt.URL__c = theMdt.URL_DEVINT__c;
    }
    else if(host.contains('QA') || 
            host.contains('qa')){
        theMdt.Authorization__c = theMdt.Authorization_DEV_INT__c;
        theMdt.URL__c = theMdt.URL_DEVINT__c;
    }
    else{
        theMdt.Authorization__c = theMdt.Authorization_PROD__c;
        theMdt.URL__c = theMdt.URL_PROD__c;
    }
    return theMdt;
  }

  /*************************************** AURA ENABLED METHOD ***************************************/
  /**
   * @description : called from LWC "smc_lwc_lorawan_downloader" to make a callout and download response
   * @author Vincent RECASENS (Modis) | 03-04-2021
   * @param format
   * @param requestid
   * @param useremail
   * @param deveuis
   * @return WrapperToPrintDatas
   **/
  @AuraEnabled
  public static SMC_AC_LoraWan_IOT_Keys.WrapperToPrintDatas manageLoRaWanCalloutAndPrintDatas(
    String format,
    String requestid,
    String useremail,
    String deveuis
  ) {
      //Get information from WS
      SMC_AC_LoraWan_IOT_Keys.DTOResponse responseClient;
      SMC_AC_LoraWan_IOT_Keys.DTOResponse responseNke;
      //Build devEUIs list
      List<String> listDevEUIs = new List<String>();
      if (deveuis.contains('\n')) {
        for (String devEUI : deveuis.split('\n')) {
          if(devEUI.length() > 0){
            listDevEUIs.add(devEUI);
          }
        }
      } else if (deveuis.split(',').size() > 1) {
        for (String devEUI : deveuis.split(',')) {
          listDevEUIs.add(devEUI);
        }
      } else if (deveuis.split(';').size() > 1) {
        for (String devEUI : deveuis.split(';')) {
          listDevEUIs.add(devEUI);
        }
      } else if (deveuis.split(' ').size() > 1) {
        for (String devEUI : deveuis.split(' ')) {
          listDevEUIs.add(devEUI);
        }
      } else if (deveuis != null && deveuis != '') {
        listDevEUIs.add(deveuis);
      }
      //Make callout
      WrapperToPrintDatas resultToSendToLWC = new WrapperToPrintDatas();
      if (format == System.Label.SMC_CLIENT) {
        responseClient = makeCallout(format, requestId, listDevEUIs);
      } else if (format == System.Label.SMC_NKE) {
        responseNke = makeCallout(format, requestId, listDevEUIs);
      } else if (
        format == System.Label.SMC_CLIENT + '_' + System.Label.SMC_NKE
      ) {
        responseClient = makeCallout(
          System.Label.SMC_CLIENT,
          requestId,
          listDevEUIs
        );
        responseNke = makeCallout(
          System.Label.SMC_NKE,
          requestId,
          listDevEUIs
        );
      }

      //Format fields CLIENT
      if (responseClient != null) {
        resultToSendToLWC.responseClientFileName =
          formatDatetime() +
          '_LoRaWan-keys_' +
          requestId +
          '.csv';
        resultToSendToLWC.responseClient.result = (List<SMC_AC_LoraWan_IOT_Keys.DTOResponseGlobal>) formatDatasForFile(
          System.Label.SMC_CLIENT,
          responseClient.result
        );
        //Check and display invalid devEUIs
        resultToSendToLWC.responseClientInvalidDevEUI = checkInvalidLine(
          listDevEUIs,
          responseClient
        );
      }

      //Format fields NKE
      if (responseNke != null) {
        resultToSendToLWC.responseNkeFileName =
          formatDatetime() +
          '_LoRaWan-configFile_' +
          requestId +
          '.txt';
        resultToSendToLWC.responseNke = responseNke;
        resultToSendToLWC.responseNkeToPrint = (String) formatDatasForFile(
          System.Label.SMC_NKE,
          responseNke.result
        );
        //Check and display invalid devEUIs
        resultToSendToLWC.responseNkeInvalidDevEUI = checkInvalidLine(
          listDevEUIs,
          responseNke
        );
      }
      return resultToSendToLWC;
  }

  /*************************************** CALLOUT ***************************************/
  /**
   * @description : get datas to print a csv
   * @author Vincent RECASENS (Modis) | 03-03-2021
   **/
  @TestVisible
  private static SMC_AC_LoraWan_IOT_Keys.DTOResponse makeCallout(
    String format,
    String requestId,
    List<String> devEUIs
  ) {
    HttpRequest request = new HttpRequest();
    SMC_AC_LoraWan_IOT_Keys.DTOResponse jsonResult = new SMC_AC_LoraWan_IOT_Keys.DTOResponse(
      format
    );
    SMC_IOT_Key__mdt mdt = getEndpoint(STA_UtilsStatic.DATAS_VAULT);
    //Method is bypassed --> return a mock
    if (mdt.SMC_Is_Mocking_Mode__c) {
      if (format == System.Label.SMC_CLIENT) {
        String responseMock = [
            SELECT Id, Body
            FROM StaticResource
            WHERE Name = 'MOCK_LoRaWan_CLIENT'
          ]
          .Body.toString()
          .replace('"class"', '"theclass"');
        System.debug('responseMock : ' + responseMock);
        jsonResult = (SMC_AC_LoraWan_IOT_Keys.DTOResponse) JSON.deserialize(
          responseMock,
          SMC_AC_LoraWan_IOT_Keys.DTOResponse.class
        );
      } else if (format == System.Label.SMC_NKE) {
        jsonResult.result = (List<SMC_AC_LoraWan_IOT_Keys.DTOResponseGlobal>) JSON.deserialize(
          [SELECT Id, Body FROM StaticResource WHERE Name = 'MOCK_LoRaWan_NKE']
            .Body.toString(),
          List<SMC_AC_LoraWan_IOT_Keys.DTOResponseGlobal>.class
        );
      }
      return jsonResult;
    }
    //End mock

    //Method make callout
    String theUrl = buildUrl(mdt.URL__c, format, devEUIs);
    if (format == System.Label.SMC_NKE) {
      theUrl += '&tags=NKE';
    }
    String requestQuery = theUrl;
    request.setEndpoint(requestQuery);
    System.debug(LoggingLevel.INFO, 'QUERY requestQuery : ' + requestQuery);
    request.setMethod(STA_UtilsStatic.GET_METHOD);
    request.setHeader(STA_UtilsStatic.ACCEPT, STA_UtilsStatic.APPLICATION_JSON);
    request.setHeader(
      STA_UtilsStatic.AUTHORIZATION, 
      STA_UtilsStatic.BASIC_MINOR + 
        EncodingUtil.base64Encode(
          Blob.valueOf(
            mdt.username__c + ':' + mdt.Authorization__c
          )
        )
    );

    Http http = new Http();
    HTTPResponse response = new HTTPResponse();
    String responseBody = STA_UtilsStatic.EMPTY_STRING;
    try {
      response = http.send(request);
      System.debug('Response : ' + response);
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
      //Format response body
      responseBody = response.getBody();
      System.debug(LoggingLevel.INFO, 'BODY makeCallout : ' + responseBody);

      //Remove elements that detected as key words
      if (responseBody.contains('"class"')) {
        responseBody = responseBody.replace('"class"', '"theclass"');
      }
      jsonResult = (SMC_AC_LoraWan_IOT_Keys.DTOResponse) JSON.deserialize(
        responseBody,
        SMC_AC_LoraWan_IOT_Keys.DTOResponse.class
      );
    } catch (CalloutException calloutException) {
      System.debug(
        LoggingLevel.INFO,
        STA_UtilsStatic.BAD_STATUS_CODE +
        response.getStatusCode() +
        ' -> CalloutException : ' +
        calloutException
      );
      sendErrorLog(
        new List<CalloutException>{ calloutException },
        'LoraWan (IOT Platform) - Get Datas',
        STA_UtilsStatic.PICKLIST_LOGS_PROCESS_TYPE_WS,
        null,
        requestQuery,
        requestId
      );
    } catch (Exception e) {
      System.debug(LoggingLevel.INFO, 'Exception : ' + e);
      sendErrorLog(
        new List<Exception>{ e },
        'LoraWan (IOT Platform) - Get Datas',
        STA_UtilsStatic.PICKLIST_LOGS_PROCESS_TYPE_WS,
        null,
        requestQuery,
        requestId
      );
    }

    return jsonResult;
  }

  /*************************************** ERROR LOG ***************************************/
  public class MissingDevEUIsException extends Exception {
  }
  /**
   * @description : generate a SMC_Log__c
   * @author Vincent RECASENS (Modis) | 10/04/2020
   * @param exceptions
   * @param errorProcessName
   * @param typeProcess
   * @param body
   * @param query
   * @return void
   **/
  @TestVisible
  private static void sendErrorLog(
    List<Exception> exceptions,
    String errorProcessName,
    String typeProcess,
    String body,
    String query,
    String requestId
  ) {
    SMC_UTIL_Methods_Batch.createErrorLog(
      exceptions,
      errorProcessName,
      STA_UtilsStatic.PICKLIST_LOGS_PROCESS_TYPE_WS,
      body,
      query,
      new List<String>{ requestId }
    );
  }
}