/**
 * @description       :
 * @author            : Vincent RECASENS (Modis)
 * @group             :
 * @last modified on  : 11-25-2020
 * @last modified by  : Vincent RECASENS (Modis)
 * Modifications Log
 * Ver   Date         Author                     Modification
 * 1.0   10-06-2020   Vincent RECASENS (Modis)   Initial Version
 **/
public without sharing class SMC_AP_DORA_Callout {
  @TestVisible
  private Map<String, String> MAP_MDT_NAME = new Map<String, String>();
  @TestVisible
  private String bodyPost;

  @TestVisible
  public SMC_AP_DORA_Callout() {
    this.MAP_MDT_NAME.put('accounts', 'Accounts');
    this.MAP_MDT_NAME.put('accountSpecific', 'Account_specific');
    this.MAP_MDT_NAME.put('pdtAvaibilityHPWQt', 'Item_Code_w_quantity_HP');
    this.MAP_MDT_NAME.put('pdtAvaibilityHPWoQt', 'Item_Code_wo_quantity_HP');
    this.MAP_MDT_NAME.put('pdtAvaibilityNOWQt', 'Item_Code_w_quantity_NO');
    this.MAP_MDT_NAME.put('pdtAvaibilityNOWoQt', 'Item_Code_wo_quantity_NO');
    this.MAP_MDT_NAME.put('orderHeaders', 'Order_Headers');
    this.MAP_MDT_NAME.put('orderRows', 'Order_Rows');
    this.MAP_MDT_NAME.put('orderGuestUser', 'Order_guest_user');
    this.MAP_MDT_NAME.put('post_orderUpsert', 'Upsert_Order');
    this.MAP_MDT_NAME.put('post_orderBuyAgain', 'Upsert_Order');
    this.MAP_MDT_NAME.put('delete_order', 'Delete_Order');
    // this.MAP_MDT_NAME.put('post_newUser', 'User_new');
  }

  /**
   * @description : get endpoint information from metadata "DORA Endpoint"
   * @author Vincent RECASENS (Modis) | 10-06-2020
   * @param fromWhere
   * @return SMC_DORA_Endpoint__mdt
   **/
  @TestVisible
  private SMC_DORA_Endpoint__mdt getEndpoint(
    String fromWhere,
    Map<String, String> mapKeyParamToValue,
    SMC_AP_DORA_Callout callout
  ) {
    String mdtName;
    if (callout.MAP_MDT_NAME.get(fromWhere) != null) {
      mdtName = callout.MAP_MDT_NAME.get(fromWhere);
    } else {
      SMC_UTIL_Methods_Batch.createErrorLog(
        null,
        'DORA - Get Endpoint : endpoint can not be build',
        STA_UtilsStatic.PICKLIST_LOGS_PROCESS_TYPE_WS,
        null,
        null,
        null
      );
      return null;
    }
    SMC_DORA_Endpoint__mdt mdt = [
      SELECT
        APIKEY_USER__c,
        Callout_Type__c,
        Params__c,
        URL__c,
        URL_Test__c,
        Is_Mocked__c,
        Mock_Name__c
      FROM SMC_DORA_Endpoint__mdt
      WHERE DeveloperName = :mdtName
    ];
    //Check if PROD
    if (
      !URL.getSalesforceBaseUrl()
        .toExternalForm()
        .startsWith(STA_UtilsStatic.HTTPS_SOCOMEC_DOT_MY_DOT)
    ) {
      mdt.URL__c = mdt.URL_Test__c;
    }
    //Set url
    String theURL = mdt.URL__c;
    if (!fromWhere.startsWith('post')) {
      for (String oneParam : mdt.Params__c.split(';')) {
        if (oneParam == 'apikey') {
          theURL += oneParam + '=' + mdt.APIKEY_USER__c + '&';
        }
        if (
          mapKeyParamToValue != null &&
          mapKeyParamToValue.get(oneParam) != null
        ) {
          if (oneParam == 'cdpar') {
            theURL +=
              oneParam +
              '=' +
              EncodingUtil.urlEncode(
                mapKeyParamToValue.get(oneParam),
                'UTF-8'
              ) +
              '&';
          } else {
            theURL += oneParam + '=' + mapKeyParamToValue.get(oneParam) + '&';
          }
        }
      }
      mdt.URL__c = theURL.removeEnd('&');
    } else {
      callout.buildPostBody(fromWhere, mapKeyParamToValue, mdt, callout);
    }

    return mdt;
  }

  /**
   * @description : build body for post callout
   * @author Vincent RECASENS (Modis) | 10-06-2020
   * @param fromWhere
   * @param mapKeyParamToValue
   * @param mdt
   * @param callout
   * @return String
   **/
  @TestVisible
  private void buildPostBody(
    String fromWhere,
    Map<String, String> mapKeyParamToValue,
    SMC_DORA_Endpoint__mdt mdt,
    SMC_AP_DORA_Callout callout
  ) {
    // if (fromWhere == 'post_orderUpsert') {
    List<SMC_DTO_DORA.SMC_DTO_Order_Data_Row> rowsList = new List<SMC_DTO_DORA.SMC_DTO_Order_Data_Row>();
    if (mapKeyParamToValue.get('rows') != null) {
      List<SMC_DTO_DORA.SMC_DTO_Get_ItemCode_Data> getItemsList = (List<SMC_DTO_DORA.SMC_DTO_Get_ItemCode_Data>) JSON.deserialize(
        mapKeyParamToValue.get('rows'),
        List<SMC_DTO_DORA.SMC_DTO_Get_ItemCode_Data>.class
      );
      for (SMC_DTO_DORA.SMC_DTO_Get_ItemCode_Data oneItem : getItemsList) {
        if ((oneItem.isProduct != null && oneItem.isProduct)) {
          rowsList.add(
            new SMC_DTO_DORA.SMC_DTO_Order_Data_Row(
              String.valueOf(oneItem.linenumber),
              oneItem.CDPAR,
              null,
              oneItem.QUANTITY,
              oneItem.GROSSPRICE * (oneItem.discountpercent != null ? (1-(oneItem.discountpercent*0.01)) : 1),
              String.valueOf(oneItem.REQUESTEDDATE)
            )
          );
        } else {
          rowsList.add(
            new SMC_DTO_DORA.SMC_DTO_Order_Data_Row(
              String.valueOf(oneItem.linenumber),
              null,
              oneItem.CDSPS,
              oneItem.QUANTITY,
              oneItem.GROSSPRICE,
              String.valueOf(oneItem.REQUESTEDDATE)
            )
          );
        }
      }
    }
    if(mapKeyParamToValue.get('newaddress') == null || mapKeyParamToValue.get('newaddress') == ''){
      callout.bodyPost = JSON.serialize(
        new SMC_DTO_DORA.SMC_DTO_Post_Order_BODY(
          mdt.APIKEY_USER__c,
          mapKeyParamToValue.get('usermail'),
          mapKeyParamToValue.get('cdord') != null
            ? mapKeyParamToValue.get('cdord')
            : '',
          mapKeyParamToValue.get('cdcli') != null
            ? mapKeyParamToValue.get('cdcli')
            : '',
          mapKeyParamToValue.get('custref') != null
            ? mapKeyParamToValue.get('custref')
            : '',
          mapKeyParamToValue.get('contactname') != null
            ? mapKeyParamToValue.get('contactname')
            : '',
          mapKeyParamToValue.get('contactphone') != null
            ? mapKeyParamToValue.get('contactphone')
            : '',
          mapKeyParamToValue.get('expecteddate') != null
            ? mapKeyParamToValue.get('expecteddate')
            : '',
          mapKeyParamToValue.get('preftime') != null
            ? mapKeyParamToValue.get('preftime')
            : '',
          mapKeyParamToValue.get('addresscode'),
          mapKeyParamToValue.get('taillift') != null
            ? mapKeyParamToValue.get('taillift')
            : '',
          mapKeyParamToValue.get('note') != null
            ? mapKeyParamToValue.get('note')
            : '',
          mapKeyParamToValue.get('secret') != null
            ? mapKeyParamToValue.get('secret')
            : '',
          rowsList
        )
      );
    }
    else{
      callout.bodyPost = JSON.serialize(
        new SMC_DTO_DORA.SMC_DTO_Post_Order_BODY_NewAddress(
          mdt.APIKEY_USER__c,
          mapKeyParamToValue.get('usermail'),
          mapKeyParamToValue.get('cdord') != null
            ? mapKeyParamToValue.get('cdord')
            : '',
          mapKeyParamToValue.get('cdcli') != null
            ? mapKeyParamToValue.get('cdcli')
            : '',
          mapKeyParamToValue.get('custref') != null
            ? mapKeyParamToValue.get('custref')
            : '',
          mapKeyParamToValue.get('contactname') != null
            ? mapKeyParamToValue.get('contactname')
            : '',
          mapKeyParamToValue.get('contactphone') != null
            ? mapKeyParamToValue.get('contactphone')
            : '',
          mapKeyParamToValue.get('expecteddate') != null
            ? mapKeyParamToValue.get('expecteddate')
            : '',
          mapKeyParamToValue.get('preftime') != null
            ? mapKeyParamToValue.get('preftime')
            : '',
          mapKeyParamToValue.get('addresscode'),
          (SMC_DTO_DORA.SMC_DTO_Post_Order_NewAddress) 
            JSON.deserialize(
              mapKeyParamToValue.get('newaddress'), 
              SMC_DTO_DORA.SMC_DTO_Post_Order_NewAddress.class
            ),
          mapKeyParamToValue.get('taillift') != null
            ? mapKeyParamToValue.get('taillift')
            : '',
          mapKeyParamToValue.get('note') != null
            ? mapKeyParamToValue.get('note')
            : '',
          mapKeyParamToValue.get('secret') != null
            ? mapKeyParamToValue.get('secret')
            : '',
          rowsList
        )
      );
    }
  }

  /**
   * @description : deserialize the response from server
   * @author Vincent RECASENS (Modis) | 10-06-2020
   * @param fromWhere
   * @param response
   * @return SMC_DTO_DORA
   **/
  @TestVisible
  private SMC_DTO_DORA deserializeHttpResponseBody(
    String fromWhere,
    HTTPResponse response,
    Map<String, String> mapKeyParamToValue
  ) {
    SMC_DTO_DORA jsonObject = new SMC_DTO_DORA();
    String responseBody = response.getBody();
    //HP Without quantity
    if (
      fromWhere == 'pdtAvaibilityHPWoQt' ||
      fromWhere == 'pdtAvaibilityNOWoQt'
    ) {
      jsonObject.getItemCode = (SMC_DTO_DORA.SMC_DTO_Get_ItemCode) JSON.deserialize(
        responseBody,
        SMC_DTO_DORA.SMC_DTO_Get_ItemCode.class
      );
    } else if (
      fromWhere == 'pdtAvaibilityHPWQt' ||
      fromWhere == 'pdtAvaibilityNOWQt'
    ) {
      //Check prices
      String toDeserialized = '';
      toDeserialized = responseBody.split(',"data":')[0] + ',"data":' + responseBody.split(',"data":')[1].replaceAll('""', '0');

      //HP With quantity
      jsonObject.getItemCodeWQt = (SMC_DTO_DORA.SMC_DTO_Get_ItemCode_With_Quantity) JSON.deserialize(
        toDeserialized,
        SMC_DTO_DORA.SMC_DTO_Get_ItemCode_With_Quantity.class
      );
      if(jsonObject.getItemCodeWQt.data != null)
        jsonObject.getItemCodeWQt.data.productLabelNotAvailable = getLabelNotAvailable();
    } else if (fromWhere == 'accounts') {
      jsonObject.getAccounts = (SMC_DTO_DORA.SMC_DTO_Get_Accounts) JSON.deserialize(
        responseBody,
        SMC_DTO_DORA.SMC_DTO_Get_Accounts.class
      );
      if (!Test.isRunningTest()) {
        for (
          SMC_DTO_DORA.SMC_DTO_Get_Account_Data oneAccount : jsonObject.getAccounts.data
        ) {
          oneAccount.COMPANYNAME =
            oneAccount.COMPANYNAME +
            ' - ' +
            oneAccount.CDCLI;
        }
      }
    } else if (fromWhere == 'accountSpecific') {
      jsonObject.getSpecificAccount = (SMC_DTO_DORA.SMC_DTO_Get_SpecificAccount) JSON.deserialize(
        responseBody,
        SMC_DTO_DORA.SMC_DTO_Get_SpecificAccount.class
      );
      for (
        Integer i = 0;
        i < jsonObject.getSpecificAccount.data.addresses.size();
        ++i
      ) {
        jsonObject.getSpecificAccount.data.addresses[i]
          .concatAddress = concatAddress(
          jsonObject.getSpecificAccount.data.addresses[i]
        );
      }
    } else if (fromWhere == 'orderHeaders') {
      jsonObject.getOrder = (SMC_DTO_DORA.SMC_DTO_Get_Order) JSON.deserialize(
        responseBody,
        SMC_DTO_DORA.SMC_DTO_Get_Order.class
      );
    } else if (fromWhere == 'orderRows') {
      jsonObject.getOrderRows = (SMC_DTO_DORA.SMC_DTO_Get_Order_Rows) JSON.deserialize(
        responseBody,
        SMC_DTO_DORA.SMC_DTO_Get_Order_Rows.class
      );
      if(jsonObject.getOrderRows.data != null)
        jsonObject.getOrderRows.data.productLabelNotAvailable = getLabelNotAvailable();
    } else if (fromWhere == 'orderGuestUser') {
      jsonObject.getOrderForGuest = (SMC_DTO_DORA.SMC_DTO_Get_Order_ForGuest) JSON.deserialize(
        responseBody,
        SMC_DTO_DORA.SMC_DTO_Get_Order_ForGuest.class
      );
      if(jsonObject.getOrderForGuest != null)
        jsonObject.getOrderForGuest.productLabelNotAvailable = getLabelNotAvailable();
    } else if (fromWhere.startsWith('post') || fromWhere == 'delete_order') {
      jsonObject.getPostResult = (SMC_DTO_DORA.SMC_DTO_Post_RESULT) JSON.deserialize(
        responseBody,
        SMC_DTO_DORA.SMC_DTO_Post_RESULT.class
      );
      //Envoie d'email
      if (fromWhere.startsWith('post') && !jsonObject.getPostResult.error) {
        sendOrderLinkEmail(mapKeyParamToValue.get('secret'));
      }
    } else {
      return null;
    }
    return jsonObject;
  }

  /**
  * @description : used to get label for fake date when a product is not available
  * @author Vincent RECASENS (Modis) | 10-27-2021 
  * @return Map<String, String> 
  **/
  @TestVisible
  private static List<SMC_DTO_DORA.SMC_DTO_NotAvailableLabel> getLabelNotAvailable(){
    List<SMC_DTO_DORA.SMC_DTO_NotAvailableLabel> listNotAvailableLabel = new List<SMC_DTO_DORA.SMC_DTO_NotAvailableLabel>();
    listNotAvailableLabel.add(new SMC_DTO_DORA.SMC_DTO_NotAvailableLabel('7999-12-31', System.Label.SMC_DORA_DateNA_MTO));
    listNotAvailableLabel.add(new SMC_DTO_DORA.SMC_DTO_NotAvailableLabel('8999-12-31', System.Label.SMC_DORA_DateNA_MTS));
    listNotAvailableLabel.add(new SMC_DTO_DORA.SMC_DTO_NotAvailableLabel('9999-12-31', System.Label.SMC_DORA_DateNA_PTS));
    // for(DORA_LabelNotAvailable__mdt oneMdt : [SELECT Label, FakeDate__c FROM DORA_LabelNotAvailable__mdt]){
    //   listNotAvailableLabel.add(new SMC_DTO_DORA.SMC_DTO_NotAvailableLabel(oneMdt.FakeDate__c, oneMdt.Label));
    // }
    return listNotAvailableLabel;
  }

  /**
   * @description : concat address to display in one line
   * @author Vincent RECASENS (Modis) | 10-21-2020
   * @param address
   * @return String
   **/
  @TestVisible
  private static String concatAddress(
    SMC_DTO_DORA.SMC_DTO_Get_Account_Data_Address address
  ) {
    return address.COMPANYNAME +
      '  ' +
      address.ADDRESS +
      ', ' +
      address.ZIPCODE +
      ' ' +
      address.CITY +
      ' ' +
      address.PROV +
      '  ' +
      address.COUNTRY;
  }

  /**
   * @description : build email template and send email to current user
   * @author Vincent RECASENS (Modis) | 10-29-2020
   * @param secret
   * @return String
   **/
  @TestVisible
  public static void sendOrderLinkEmail(String secret) {
    //SET EMAIL
    Messaging.SingleEmailMessage message = buildEmailBodyWithTemplate(secret);
    //Set toAddress
    message.toAddresses = new List<String>{ UserInfo.getUserEmail() };
    //Set FromAddress
    OrgwideEmailAddress[] orgwideaddress = [
      SELECT Id
      FROM OrgwideEmailAddress
      WHERE DisplayName = 'NoReply' //'NoReply'
    ];
    message.setOrgWideEmailAddressId(orgwideaddress[0].id);
    message.setUseSignature(false);
    message.optOutPolicy = 'FILTER';

    //Send email
    Messaging.SendEmailResult[] results;
    if (!Test.isRunningTest()) {
      results = Messaging.sendEmail(
        new List<Messaging.SingleEmailMessage>{ message }
      );
      if (results[0].success) {
        System.debug('The email was sent successfully.');
      } else {
        System.debug(
          'The email failed to send: ' + results[0].errors[0].message
        );
      }
    }
  }

  /**
   * @description : used to fill HTML body of the email
   * @author Vincent RECASENS (Modis) | 11-03-2020
   * @param message
   * @return Messaging.SingleEmailMessage
   **/
  @TestVisible
  private static Messaging.SingleEmailMessage buildEmailBodyWithTemplate(
    String secret
  ) {
    //Get url
    String theUrl =
      URL.getSalesforceBaseUrl().toExternalForm() +
      '/onlineordering/s/order-tracking?trackingorder=' +
      secret;
    //Build image url
    Id logoId;
    if (!Test.isRunningTest()) {
      logoId = [SELECT Id FROM Document WHERE DeveloperName = 'LogoBlanc_png']
      .Id;
    } else {
      logoId = '000000000000001';
    }
    String logoUrl =
      '<img src="' +
      URL.getOrgDomainUrl().toExternalForm() +
      '/servlet/servlet.ImageServer?id=' +
      logoId +
      '&oid=' +
      UserInfo.getOrganizationId() +
      '" alt="Socomec logo" title="Socomec logo" /><br/><br/>';
    //Get email template
    EmailTemplate theEmailTemplate = [SELECT Id, Name, Body, HtmlValue FROM EmailTemplate WHERE DeveloperName = 'Online_Ordering_Email_Multiplang'];
    Messaging.SingleEmailMessage message = Messaging.renderStoredEmailTemplate(theEmailTemplate.Id, UserInfo.getUserId(), null);
    message.setSaveAsActivity(false);
    String body = message.getHtmlBody();
    //Replace element in body
    body = body.replace('$$SECRET_CODE$$', secret);
    body = body.replace('$$ORDER_LINK$$', theUrl); 
    body = body.replace('$$SOCOMEC_LOGO$$', logoUrl); 
    message.setHtmlBody(body);
    return message;
  }

  /**
   * @description : launch callout
   * @author Vincent RECASENS (Modis) | 10-06-2020
   * @param fromWhere
   * @param mapKeyParamToValue
   **/
  public static SMC_DTO_DORA calloutMethod(
    String fromWhere,
    Map<String, String> mapKeyParamToValue
  ) {
    System.debug(
      LoggingLevel.INFO,
      '>>>>>>SMC_AP_DORA_Callout -> Method calloutMethod - START'
    );

    //Init variables
    SMC_AP_DORA_Callout callout = new SMC_AP_DORA_Callout();
    List<Exception> logs = new List<Exception>();

    /* SET ENDPOINT */
    SMC_DORA_Endpoint__mdt mdt = callout.getEndpoint(
      fromWhere,
      mapKeyParamToValue,
      callout
    );

    if (mdt.Is_Mocked__c) {
      SMC_UTIL_DORA_Mock mock = new SMC_UTIL_DORA_Mock();
      return mock.getMock(mdt.Mock_Name__c);
    }

    //Construct request
    HttpRequest request = new HttpRequest();
    request.setEndpoint(mdt.URL__c);
    request.setMethod(mdt.Callout_Type__c);
    request.setHeader(
      STA_UtilsStatic.CONTENT_TYPE,
      STA_UtilsStatic.APPLICATION_JSON
    );
    request.setTimeout(60000);
    System.debug(
      LoggingLevel.INFO,
      'Request URL --> ' + mdt.URL__c
    );
    if (fromWhere.startsWith('post')) {
      request.setBody(callout.bodyPost);
      System.debug(
        LoggingLevel.INFO,
        'Request Body --> ' + callout.bodyPost
      );
    }

    Http http = new Http();
    HTTPResponse response = new HTTPResponse();
    SMC_DTO_DORA returnObject;
    try {
      response = http.send(request);
      System.debug(
        LoggingLevel.INFO,
        'Response for calloutMethod --> ' + response.getBody()
      );
      //Error
      if (response.getStatusCode() == 405) {
        returnObject = (SMC_DTO_DORA) JSON.deserialize(
          response.getBody(),
            SMC_DTO_DORA.class
          );
      }
      else if (response.getStatusCode() != 200) {
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
        throw calloutException;
      } else {
        returnObject = callout.deserializeHttpResponseBody(
          fromWhere,
          response,
          mapKeyParamToValue
        );
      }
    } catch (CalloutException calloutException) {
      System.debug(
        LoggingLevel.INFO,
        STA_UtilsStatic.BAD_STATUS_CODE +
        response.getStatusCode() +
        ' -> CalloutException : ' +
        calloutException
      );
      if (!Test.isRunningTest()) {
        SMC_UTIL_Methods_Batch.createErrorLog(
          new List<Exception>{ calloutException },
          'DORA - calloutMethod',
          STA_UtilsStatic.PICKLIST_LOGS_PROCESS_TYPE_WS,
          'Callout : ' + fromWhere,
          mdt.URL__c,
          new List<String>{ UserInfo.getUsername() }
        );
      }
    } catch (JSONException jsonException) {
      System.debug(
        LoggingLevel.INFO,
        STA_UtilsStatic.BAD_STATUS_CODE +
        response.getStatusCode() +
        ' -> JSONException : ' +
        jsonException
      );
      if (!Test.isRunningTest()) {
        SMC_UTIL_Methods_Batch.createErrorLog(
          new List<Exception>{ jsonException },
          'DORA - calloutMethod',
          STA_UtilsStatic.PICKLIST_LOGS_PROCESS_TYPE_WS,
          'Callout : ' + fromWhere,
          mdt.URL__c,
          new List<String>{ UserInfo.getUsername() }
        );
      }
    } catch (Exception e) {
      System.debug(LoggingLevel.INFO, 'Exception : ' + e);
      if (!Test.isRunningTest()) {
        SMC_UTIL_Methods_Batch.createErrorLog(
          new List<Exception>{ e },
          'DORA - calloutMethod',
          STA_UtilsStatic.PICKLIST_LOGS_PROCESS_TYPE_WS,
          'Callout : ' + fromWhere,
          mdt.URL__c,
          new List<String>{ UserInfo.getUsername() }
        );
      }
    }

    System.debug(
      LoggingLevel.INFO,
      '>>>>>>SMC_AP_DORA_Callout -> Method calloutMethod - END'
    );
    return returnObject;
  }
}