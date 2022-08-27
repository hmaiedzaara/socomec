/*
-----------------------------------------------------------------------------------
-- - Name : SMC_AC_ERP_Line
-- - Author : Vincent RECASENS
-- - Description : This class is Apex controller of LWC ERP Line
--
-- Maintenance History:
--
-- Date         Name   Version     Remarks
-- -----------  ----   -------     ----------------------------
-- 06-NOV-2019  VRE    1.0         Initial Version
------------------------------------------------------------------------------------
*/

public with sharing class SMC_AC_ERP_Line {
  public static String errorCallout;

  public class WrapperData {
    public String recordObjectType;
    @AuraEnabled
    public String error;
    @AuraEnabled
    public Boolean isInvoice;
    @AuraEnabled
    public Boolean isOrder;
    @AuraEnabled
    public Boolean isQuote;
    @AuraEnabled
    public String iconName;
    @AuraEnabled
    public String erpLineTitle;
    @AuraEnabled
    public String elementCurrency;
    @AuraEnabled
    public List<WrapperDataUnit> datas;

    public WrapperData() {
      this.isInvoice = false;
      this.isOrder = false;
      this.isQuote = false;
      this.datas = new List<WrapperDataUnit>();
    }

    public WrapperData(
      String recordObjectType,
      String iconName,
      String erpLineTitle,
      String elementCurrency
    ) {
      this.isInvoice = false;
      this.isOrder = false;
      this.isQuote = false;
      this.recordObjectType = recordObjectType;
      this.iconName = iconName;
      this.erpLineTitle = erpLineTitle;
      this.elementCurrency = elementCurrency;
      this.datas = new List<WrapperDataUnit>();
    }
  }

  public class WrapperDataUnit {
    @AuraEnabled
    public String descRef;
    @AuraEnabled
    public String productReference;
    @AuraEnabled
    public String ba;
    @AuraEnabled
    public Double amount;
    @AuraEnabled
    public Double quantity;
    @AuraEnabled
    public String status;

    public WrapperDataUnit() {
    }

    //ERP Invoice
    public WrapperDataUnit(
      String descRef,
      String productReference,
      String ba,
      Double amount
    ) {
      this.descRef = descRef;
      this.productReference = productReference;
      this.ba = ba;
      this.amount = amount;
    }

    //ERP Order
    public WrapperDataUnit(
      String descRef,
      String productReference,
      Long quantity,
      Double amount
    ) {
      this.descRef = descRef;
      this.productReference = productReference;
      this.quantity = quantity;
      this.amount = amount;
    }

    //ERP Quote
    public WrapperDataUnit(
      String descRef,
      String productReference,
      Long quantity,
      String status
    ) {
      this.descRef = descRef;
      this.productReference = productReference;
      this.quantity = quantity;
      this.status = status;
    }
  }

  /**
   * @description : distinction beteween SMC_ERP_Invoice__c/SMC_ERP_Order__c/SMC_ERP_Quote__c and get informations
   * @author Vincent RECASENS (Modis) | 10/04/2020
   * @param recordId
   * @return WrapperData
   **/
  @AuraEnabled
  public static WrapperData initialization(String recordId) {
    //Define the record object type
    String iconName;
    String erpLineTitle;
    String erpFinancialId;
    String elementCurrency;
    String recordObjectType;
    String recordCode;
    String accountCRMCode;
    if (
      ((Id) recordId).getSobjectType() == Schema.SMC_ERP_Invoice__c.SObjectType
    ) {
      iconName = 'custom:custom25';
      erpLineTitle = STA_UtilsStatic.ERP_INVOICE_LINES;
      SMC_ERP_Invoice__c oneElement = [
        SELECT Name, CurrencyIsoCode, SMC_Account__c, SMC_FinancialId__c
        FROM SMC_ERP_Invoice__c
        WHERE Id = :recordId
      ];
      erpFinancialId = oneElement.SMC_FinancialId__c != null
        ? String.valueOf(oneElement.SMC_FinancialId__c)
        : null;
      accountCRMCode = [
        SELECT AccountNumber
        FROM Account
        WHERE Id = :oneElement.SMC_Account__c
      ]
      .AccountNumber;
      recordCode = oneElement.Name;
      elementCurrency = oneElement.CurrencyIsoCode;
      recordObjectType = STA_UtilsStatic.INVOICE;
    } else if (
      ((Id) recordId).getSobjectType() == Schema.SMC_ERP_Order__c.SObjectType
    ) {
      iconName = 'custom:custom20';
      erpLineTitle = STA_UtilsStatic.ERP_ORDER_LINES;
      SMC_ERP_Order__c oneElement = [
        SELECT Name, CurrencyIsoCode, SMC_Account__c, SMC_FinancialId__c
        FROM SMC_ERP_Order__c
        WHERE Id = :recordId
      ];
      erpFinancialId = oneElement.SMC_FinancialId__c != null
        ? String.valueOf(oneElement.SMC_FinancialId__c)
        : null;
      accountCRMCode = [
        SELECT AccountNumber
        FROM Account
        WHERE Id = :oneElement.SMC_Account__c
      ]
      .AccountNumber;
      recordCode = oneElement.Name;
      elementCurrency = oneElement.CurrencyIsoCode;
      recordObjectType = STA_UtilsStatic.ORDER;
    } else if (
      ((Id) recordId).getSobjectType() == Schema.SMC_ERP_Quote__c.SObjectType
    ) {
      iconName = 'custom:custom5';
      erpLineTitle = STA_UtilsStatic.ERP_QUOTE_LINES;
      SMC_ERP_Quote__c oneElement = [
        SELECT
          SMC_ERP_Quote_Id__c,
          CurrencyIsoCode,
          SMC_Account__c,
          SMC_FinancialId__c
        FROM SMC_ERP_Quote__c
        WHERE Id = :recordId
      ];
      erpFinancialId = oneElement.SMC_FinancialId__c != null
        ? String.valueOf(oneElement.SMC_FinancialId__c)
        : null;
      accountCRMCode = [
        SELECT AccountNumber
        FROM Account
        WHERE Id = :oneElement.SMC_Account__c
      ]
      .AccountNumber;
      recordCode = oneElement.SMC_ERP_Quote_Id__c;
      elementCurrency = oneElement.CurrencyIsoCode;
      recordObjectType = STA_UtilsStatic.QUOTE;
    }

    if (erpFinancialId != null) {
      return sortDatas(
        new WrapperData(
          recordObjectType,
          iconName,
          erpLineTitle,
          elementCurrency
        ),
        getERPObjectLine(
          recordId,
          recordCode,
          accountCRMCode,
          erpFinancialId,
          recordObjectType
        )
      );
    } else {
      WrapperData noERPFinancialId = new WrapperData();
      noERPFinancialId.datas = null;
      return noERPFinancialId;
    }
  }

  /**
   * @description : get callout informations
   * @author Vincent RECASENS (Modis) | 10/04/2020
   * @return SMC_Endpoint_ERPObject__mdt
   **/
  @TestVisible
  private static SMC_Endpoint_ERPObject__mdt getEndpointWebmethodERPLine() {
    System.debug(
      LoggingLevel.INFO,
      '>>>>>>SMC_AP_Callout -> Method getEndpointWebmethod - START'
    );

    SMC_Endpoint_ERPObject__mdt calloutInformations = new SMC_Endpoint_ERPObject__mdt();
    calloutInformations = [
      SELECT
        URL_Endpoint_Invoice__c,
        URL_Endpoint_Order__c,
        URL_Endpoint_Quote__c,
        URL_Credential__c,
        URL_Credential_DEV__c,
        URL_Credential_TEST__c,
        The_URL__c
      FROM SMC_Endpoint_ERPObject__mdt
    ];

    // String host = URL.getSalesforceBaseUrl().getHost();
    String host = URL.getSalesforceBaseUrl().toExternalForm();
    String[] tmpTab = host.split('--');
    //Production
    if (tmpTab.size() == 1) {
      calloutInformations.The_URL__c = calloutInformations.URL_Credential__c;
    } else if (
      tmpTab[1] == ('dev' + STA_UtilsStatic.DOT_MY_DOT_SALESFORCE_DOT_COM)
    ) {
      //Dev/Int
      calloutInformations.The_URL__c = calloutInformations.URL_Credential_DEV__c;
    } else if (
      tmpTab[1] == ('test' + STA_UtilsStatic.DOT_MY_DOT_SALESFORCE_DOT_COM)
    ) {
      //QA/Preprod
      calloutInformations.The_URL__c = calloutInformations.URL_Credential_TEST__c;
    }

    System.debug(
      LoggingLevel.INFO,
      '>>>>>>SMC_AP_Callout -> Method getEndpointWebmethod - END'
    );
    return calloutInformations;
  }

  /**
   * @description : get SMC_ERP_Invoice__c/SMC_ERP_Order__c/SMC_ERP_Quote__c
   * @author Vincent RECASENS (Modis) | 10/04/2020
   * @param recordId
   * @param recordCode
   * @param accountCRMCode
   * @param erpFinancialId
   * @param recordObjectType
   * @return List<SMC_DTO_ERP_Objects>
   **/
  @TestVisible
  private static List<SMC_DTO_ERP_Objects> getERPObjectLine(
    String recordId,
    String recordCode,
    String accountCRMCode,
    String erpFinancialId,
    String recordObjectType
  ) {
    System.debug(
      LoggingLevel.INFO,
      '>>>>>>SMC_AC_ERP_Line -> Method getERPObjectLine - START'
    );

    SMC_AC_ERP_Line.errorCallout = null;

    SMC_Endpoint_ERPObject__mdt endpoint = getEndpointWebmethodERPLine();
    String errorElement;
    HttpRequest request = new HttpRequest();
    request.setMethod(STA_UtilsStatic.GET_METHOD);
    request.setHeader(
      STA_UtilsStatic.CONTENT_TYPE,
      STA_UtilsStatic.APPLICATION_X_WWW_FORM_URLENCODED
    );
    request.setTimeout(60000);
    // Blob basicAuthBlob = Blob.valueOf(complementaryEndpoint.Authorization__c);
    // String basicAuthHeader =
    //   STA_UtilsStatic.BASIC +
    //   STA_UtilsStatic.SPACE +
    //   EncodingUtil.base64Encode(basicAuthBlob);
    // request.setHeader(STA_UtilsStatic.AUTHORIZATION, basicAuthHeader);

    //Control if there is a / char in the recordCode to replace it by %
    String[] recordCodeTab = recordCode.split('/');
    String recordCodeWithoutSlash = '';
    if (recordCodeTab.size() > 1) {
      for (String str : recordCodeTab) {
        recordCodeWithoutSlash += str + '%252F';
      }
      recordCodeWithoutSlash = recordCodeWithoutSlash.substring(
        0,
        recordCodeWithoutSlash.length() - 5
      );
    } else {
      recordCodeWithoutSlash = recordCode;
    }
    recordCodeWithoutSlash = recordCodeWithoutSlash.replace(' ', '%20');

    if (recordObjectType == STA_UtilsStatic.INVOICE) {
      errorElement = STA_UtilsStatic.ERP_INVOICE_LINES;
      request.setEndpoint(
        endpoint.The_URL__c +
        endpoint.URL_Endpoint_Invoice__c +
        erpFinancialId +
        '/invoiceCode/' +
        recordCodeWithoutSlash +
        '/accountCode/' +
        accountCRMCode
      );
    } else if (recordObjectType == STA_UtilsStatic.ORDER) {
      errorElement = STA_UtilsStatic.ERP_ORDER_LINES;
      request.setEndpoint(
        endpoint.The_URL__c +
        endpoint.URL_Endpoint_Order__c +
        erpFinancialId +
        '/orderCode/' +
        recordCodeWithoutSlash +
        '/accountCode/' +
        accountCRMCode
      );
    } else if (recordObjectType == STA_UtilsStatic.QUOTE) {
      errorElement = STA_UtilsStatic.ERP_QUOTE_LINES;
      request.setEndpoint(
        endpoint.The_URL__c +
        endpoint.URL_Endpoint_Quote__c +
        erpFinancialId +
        '/quoteCode/' +
        recordCodeWithoutSlash +
        '/accountCode/' +
        accountCRMCode
      );
    }

    Http http = new Http();
    HTTPResponse response = new HTTPResponse();
    List<SMC_DTO_ERP_Objects> wrapperErpObjects;
    try {
      response = http.send(request);

      //Error
      if (response.getStatusCode() != 200 && response.getStatusCode() != 204) {
        CalloutException calloutException = new CalloutException();
        calloutException.setMessage(
          STA_UtilsStatic.BAD_STATUS_CODE + response.getStatusCode()
        );
        throw calloutException;
      }

      wrapperErpObjects = (List<SMC_DTO_ERP_Objects>) JSON.deserialize(
        response.getBody(),
        (List<SMC_DTO_ERP_Objects>.class)
      );
    } catch (CalloutException calloutException) {
      System.debug(
        LoggingLevel.INFO,
        STA_UtilsStatic.BAD_STATUS_CODE +
        response.getStatusCode() +
        ' -> CalloutException : ' +
        calloutException
      );
      SMC_AC_ERP_Line.errorCallout =
        STA_UtilsStatic.BAD_STATUS_CODE +
        response.getStatusCode() +
        ' -> CalloutException : ' +
        calloutException;
      SMC_UTIL_Methods_Batch.createErrorLog(
        new List<CalloutException>{ calloutException },
        errorElement,
        STA_UtilsStatic.PICKLIST_LOGS_PROCESS_TYPE_WS,
        null,
        STA_UtilsStatic.QUERY_SYSDEBUG + request.getEndpoint(),
        new List<String>{ recordId }
      );
    } catch (JSONException jsonException) {
      System.debug(
        LoggingLevel.INFO,
        STA_UtilsStatic.BAD_STATUS_CODE +
        response.getStatusCode() +
        ' -> JSONException : ' +
        jsonException
      );
      SMC_AC_ERP_Line.errorCallout =
        STA_UtilsStatic.BAD_STATUS_CODE +
        response.getStatusCode() +
        ' -> JSONException : ' +
        jsonException;
      SMC_UTIL_Methods_Batch.createErrorLog(
        new List<JSONException>{ jsonException },
        errorElement,
        STA_UtilsStatic.PICKLIST_LOGS_PROCESS_TYPE_WS,
        null,
        STA_UtilsStatic.QUERY_SYSDEBUG + request.getEndpoint(),
        new List<String>{ recordId }
      );
    } catch (Exception e) {
      System.debug(LoggingLevel.INFO, 'Exception : ' + e);
      SMC_AC_ERP_Line.errorCallout = 'Exception : ' + e;
      SMC_UTIL_Methods_Batch.createErrorLog(
        new List<Exception>{ e },
        errorElement,
        STA_UtilsStatic.PICKLIST_LOGS_PROCESS_TYPE_WS,
        null,
        STA_UtilsStatic.QUERY_SYSDEBUG + request.getEndpoint(),
        new List<String>{ recordId }
      );
    }

    System.debug(
      LoggingLevel.INFO,
      '>>>>>>SMC_AC_ERP_Line -> Method getERPObjectLine - END'
    );
    return wrapperErpObjects;
  }

  /**
   * @description : sort callout response
   * @author Vincent RECASENS (Modis) | 10/04/2020
   * @param wrapperDatas
   * @param wrapperErpObjects
   * @return WrapperData
   **/
  @TestVisible
  private static WrapperData sortDatas(
    WrapperData wrapperDatas,
    List<SMC_DTO_ERP_Objects> wrapperErpObjects
  ) {
    if (SMC_AC_ERP_Line.errorCallout != null) {
      wrapperDatas.error = SMC_AC_ERP_Line.errorCallout;
    }
    //ERP Invoice
    if (wrapperDatas.recordObjectType == STA_UtilsStatic.INVOICE) {
      wrapperDatas.isInvoice = true;
      if (wrapperErpObjects != null) {
        for (SMC_DTO_ERP_Objects oneWrapper : wrapperErpObjects) {
          wrapperDatas.datas.add(
            new WrapperDataUnit(
              oneWrapper.productDescription,
              oneWrapper.productCode,
              oneWrapper.businessApplication,
              oneWrapper.amount
            )
          );
        }
      }
    } else if (wrapperDatas.recordObjectType == STA_UtilsStatic.ORDER) {
      //ERP Order
      wrapperDatas.isOrder = true;
      if (wrapperErpObjects != null) {
        for (SMC_DTO_ERP_Objects oneWrapper : wrapperErpObjects) {
          wrapperDatas.datas.add(
            new WrapperDataUnit(
              oneWrapper.productDescription,
              oneWrapper.productCode,
              oneWrapper.quantity,
              oneWrapper.amount
            )
          );
        }
      }
    } else if (wrapperDatas.recordObjectType == STA_UtilsStatic.QUOTE) {
      //ERP Quote
      wrapperDatas.isQuote = true;
      if (wrapperErpObjects != null) {
        for (SMC_DTO_ERP_Objects oneWrapper : wrapperErpObjects) {
          wrapperDatas.datas.add(
            new WrapperDataUnit(
              oneWrapper.productDescription,
              oneWrapper.productCode,
              oneWrapper.quantity,
              oneWrapper.status
            )
          );
        }
      }
    }
    return wrapperDatas;
  }
}