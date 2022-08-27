/*
-----------------------------------------------------------------------------------
-- - Name : SMC_AC_Follow_Customer
-- - Author : Vincent RECASENS
-- - Description : This class is Apex controller of LWC Follow Customer
--
-- Maintenance History:
--
-- Date         Name   Version     Remarks
-- -----------  ----   -------     ----------------------------
-- 05-DEC-2019  VRE    1.0         Initial Version
------------------------------------------------------------------------------------
*/

public with sharing class SMC_AC_Follow_Customer {
  public class WrapperCustomerInformations {
    @AuraEnabled
    public List<Data> datas { get; set; }
    @AuraEnabled
    public List<Column> columns { get; set; }
    @AuraEnabled
    public Boolean isStatistics { get; set; }
    @AuraEnabled
    public Boolean isDiscount { get; set; }
    @AuraEnabled
    public Boolean isPrice { get; set; }
    @AuraEnabled
    public Boolean isDiscountNew { get; set; }
    @AuraEnabled
    public Boolean isPriceNew { get; set; }
    @AuraEnabled
    public Boolean isDiscountPI { get; set; }
    //DPHA - Add Discount per product line
    @AuraEnabled
    public Boolean isDiscountPerProductLine { get; set;}
    @AuraEnabled
    public Boolean suffixSmartConfIsEmpty { get; set; }
    @AuraEnabled
    public Boolean checkError { get; set; }

    public WrapperCustomerInformations() {
      this.datas = new List<Data>();
      this.columns = new List<Column>();
      this.isStatistics = false;
      this.isDiscount = false;
      this.isPrice = false;
      this.isDiscountPI = false;
      //DPHA - Add Discount per product line
      this.isDiscountPerProductLine = false;
      this.checkError = false;
      this.suffixSmartConfIsEmpty = false;
    }
  }

  public class Data {
    //Common
    @AuraEnabled
    public String priceGroup { get; set; }
    @AuraEnabled
    public String item { get; set; }
    @AuraEnabled
    public String ccy { get; set; }
    @AuraEnabled
    public string priceBook { get; set; }
    @AuraEnabled
    public String customer { get; set; }
    @AuraEnabled
    public Decimal discount { get; set; }
    @AuraEnabled
    public String effectiveDate { get; set; }
    //********Statistics********
    @AuraEnabled
    public String crm_account_code { get; set; }
    @AuraEnabled
    public String scoring_family_l2_code { get; set; }
    @AuraEnabled
    public String scoring_family_l2_descr_en { get; set; }
    @AuraEnabled
    public String scoring_family_l1_descr_en { get; set; }
    @AuraEnabled
    public Decimal to_n_2 { get; set; }
    @AuraEnabled
    public Decimal to_n_1 { get; set; }
    @AuraEnabled
    public Decimal to_n { get; set; }
    @AuraEnabled
    public Decimal target { get; set; }
    @AuraEnabled
    public Decimal projected { get; set; }
    @AuraEnabled
    public Decimal target_vs_projected { get; set; }
    @AuraEnabled
    public Decimal projected_vs_ton1 { get; set; }
    //********Family Discount********
    // public String priceGroup { get; set; }
    // public String priceGroupDescriptionEn { get; set; }
    // public String priceGroupDescriptionFr { get; set; }
    // public Decimal previousDiscount { get; set; }
    //********ProductNetPrice********
    // public String item { get; set; }
    // public String description { get; set; }
    // public Double quantity { get; set; }
    // public Decimal netPrice { get; set; }
    // public String expirationDate { get; set; }
    //********Discount C123 & Discount Per Item C123********
    @AuraEnabled
    public String matrixType { get; set; }
    @AuraEnabled
    public String matrixLevel { get; set; }
    @AuraEnabled
    public String matrixDefinition { get; set; }
    @AuraEnabled
    public String sequence { get; set; }
    @AuraEnabled
    public Decimal discountPercent { get; set; }
    @AuraEnabled
    public String productLine { get; set; }
    @AuraEnabled
    public String soldToBp { get; set; }
    @AuraEnabled
    public String salesOrderType { get; set; }
    @AuraEnabled
    public String salesOffice { get; set; }
    @AuraEnabled
    public String priceList { get; set; }
    //********PriceList C123
    @AuraEnabled
    public string buyFromBp { get; set; }
    @AuraEnabled
    public string shipFromBp { get; set; }
    @AuraEnabled
    public string quantityUnit { get; set; }
    @AuraEnabled
    public string priceType { get; set; }
    @AuraEnabled
    public string breakQuantity { get; set; }
    @AuraEnabled
    public string price { get; set; }
  }

  public class Column {
    @AuraEnabled
    public String label { get; set; }
    @AuraEnabled
    public String fieldName { get; set; }
    @AuraEnabled
    public String type { get; set; }
    @AuraEnabled
    public Boolean sortable { get; set; }
    @AuraEnabled
    public Boolean wrapText { get; set; }

    public Column() {
    }
    public Column(
      String label,
      String fieldName,
      String type,
      Boolean sortable,
      Boolean wrapText
    ) {
      this.label = label;
      this.fieldName = fieldName;
      this.type = type;
      this.sortable = sortable;
      this.wrapText = wrapText;
    }
  }

  /**
   * @description : distinction beteween tabs Statics/Discount per family/Price list, build columns for LWC and get informations (callout)
   * @author Vincent RECASENS (Modis) | 10/04/2020
   * @param recordId
   * @param informationToGet
   * @return String
   **/
  @AuraEnabled
  public static String initialisation(
    // String recordId,
    String informationToGet,
    Account theAccount
  ) {
    System.debug(
      LoggingLevel.INFO,
      '>>>>>>SMC_AC_Follow_Customer -> Method initialisation - START'
    );

    WrapperCustomerInformations theWrapper = new WrapperCustomerInformations();

    /* Gérer ces cas en js pour affiche le DiscountPerFamily malgré tout */
    // Account theAccount = getAccount(recordId);
    if (theAccount.SMC_TECH_Suffix_Smartconf__c == null) {
      theWrapper.suffixSmartConfIsEmpty = true;
    }
    //Statistics
    if (informationToGet == System.Label.SMC_Statistics) {
      theWrapper.isStatistics = true;
      theWrapper.columns = new List<Column>{
        new Column('Pdt Code', 'scoring_family_l2_code', null, true, false),
        new Column(
          'Pdt Family L2',
          'scoring_family_l2_descr_en',
          null,
          true,
          true
        ),
        new Column(
          'Pdt Family L1',
          'scoring_family_l1_descr_en',
          null,
          true,
          true
        ),
        new Column('TO N-2', 'to_n_2', 'number', true, false),
        new Column('TO N-1', 'to_n_1', 'number', true, false),
        new Column('TO N', 'to_n', 'number', true, false),
        new Column('Target', 'target', 'number', true, false),
        new Column('Projected', 'projected', 'number', true, false),
        new Column('Proj/Tg', 'target_vs_projected', 'number', true, false),
        new Column('P/N-1%', 'projected_vs_ton1', 'number', true, false)
      };
      theWrapper = getStatistic(theAccount, theWrapper);
      // //Discount OLD***
    } else if (informationToGet == System.Label.SMC_Discount_Per_Family) {
      theWrapper.isDiscount = true;
      theWrapper.columns = new List<Column>{
        new Column('Price Group', 'priceGroup', null, true, false),
        new Column(
          'Price Group Desc (EN)',
          'priceGroupDescriptionEn',
          null,
          true,
          false
        ),
        new Column(
          'Price Group Desc (FR)',
          'priceGroupDescriptionFr',
          null,
          true,
          false
        ),
        new Column('Discount', 'discount', 'number', true, false),
        new Column('Effective Date', 'effectiveDate', 'date', false, false)
      };
      theWrapper = getFamilyDiscount(theAccount, theWrapper);
    } else if (informationToGet == System.Label.SMC_Price_List) {
      //Price List OLD***
      theWrapper.isPrice = true;
      theWrapper.columns = new List<Column>{
        new Column('Item', 'item', null, true, false),
        new Column('Description', 'description', null, true, false),
        new Column('Quantity', 'quantity', 'number', true, false),
        new Column('Net Price', 'netPrice', 'number', true, false),
        new Column('Discount', 'discount', 'number', true, false),
        new Column('Effective Date', 'effectiveDate', 'date', false, false),
        new Column('Expiration Date', 'expirationDate', 'date', false, false)
      };
      theWrapper = getPriceList(theAccount, theWrapper);
      // } else if (informationToGet == System.Label.SMC_Discount_Per_Family) {
    } else if (informationToGet == 'Discount_New') {
      //Discount
      theWrapper.isDiscountNew = true;
      theWrapper.columns = new List<Column>{
        /*PAS BESOIN*/
        // new Column('Price Group', 'matrixType', null, true, false),
        // new Column('Price Group', 'matrixLevel', null, true, false),
        // new Column('Price Group', 'matrixDefinition', null, true, false),
        // new Column('Price Group', 'sequence', null, true, false),
        // new Column('Price Group', 'priceBook', null, true, false),
        // new Column('Price Group', 'item', null, true, false),
        // new Column('Price Group', 'productLine', null, true, false),
        // new Column('Price Group', 'soldToBp', null, true, false),
        // new Column('Price Group', 'salesOrderType', null, true, false),
        // new Column('Price Group', 'salesOffice', null, true, false),
        // new Column('Price Group', 'priceList', null, true, false),
        /*PAS BESOIN*/
        new Column('Price Group', 'priceGroup', 'txt ', true, false),
        new Column('Discount %', 'discountPercent', 'number', true, false)
        // new Column('Price Group', 'ccy', null, true, false)
      };
      //   theWrapper.columns = new List<Column>{
      //     new Column('Price Group', 'priceGroup', null, true, false),
      //     new Column(
      //       'Price Group Desc (EN)',
      //       'priceGroupDescriptionEn',
      //       null,
      //       true,
      //       false
      //     ),
      //     new Column(
      //       'Price Group Desc (FR)',
      //       'priceGroupDescriptionFr',
      //       null,
      //       true,
      //       false
      //     ),
      //     new Column('Discount', 'discount', 'number', true, false),
      //     new Column('Effective Date', 'effectiveDate', 'date', false, false)
      //   };
      //   theWrapper = getFamilyDiscount(theAccount, theWrapper);
      theWrapper = getNewDiscount(theAccount, theWrapper);
      // } else if (informationToGet == System.Label.SMC_Price_List) {
    } else if (informationToGet == 'Price_List_New') {
      //Price List = Net Price
      theWrapper.isPriceNew = true;
      theWrapper.columns = new List<Column>{
        // new Column('Item', 'priceBook', null, true, false),
        // new Column('Item', 'buyFromBp', null, true, false),
        // new Column('Item', 'shipFromBp', null, true, false),
        // new Column('Item', 'ccy', null, true, false),
        // new Column('Item', 'quantityUnit', null, true, false),
        // new Column('Item', 'priceType', null, true, false),
        // new Column('Item', 'breakQuantity', null, true, false),
        new Column('Item', 'item', 'txt', true, false),
        new Column('Price', 'price', 'number', true, false),
        new Column('Effective Date', 'effectiveDate', 'date', true, false)
      };
      //   theWrapper.columns = new List<Column>{
      //     new Column('Item', 'item', null, true, false),
      //     new Column('Description', 'description', null, true, false),
      //     new Column('Quantity', 'quantity', 'number', true, false),
      //     new Column('Net Price', 'netPrice', 'number', true, false),
      //     new Column('Discount', 'discount', 'number', true, false),
      //     new Column('Effective Date', 'effectiveDate', 'date', false, false),
      //     new Column('Expiration Date', 'expirationDate', 'date', false, false)
      //   };
      theWrapper = getNewNetPrice(theAccount, theWrapper);
    } else if (informationToGet == System.Label.SMC_Discount_Per_Item) {
      //Discount Per Item
      theWrapper.isDiscountPI = true;
      theWrapper.columns = new List<Column>{
        // new Column('Price Group', 'matrixType', null, true, false),
        // new Column('Price Group', 'matrixLevel', null, true, false),
        // new Column('Price Group', 'matrixDefinition', null, true, false),
        // new Column('Price Group', 'sequence', null, true, false),
        // new Column('Price Group', 'soldToBp', null, true, false),
        // new Column('Price Group', 'salesOrderType', null, true, false),
        // new Column('Price Group', 'salesOffice', null, true, false),
        // new Column('Price Group', 'ccy', null, true, false)
        new Column('Item', 'item', null, true, false),
        new Column('Pdt Line', 'productLine', null, true, false),
        new Column('Price Group', 'priceGroup', null, true, false),
        new Column('Price List', 'priceList', null, true, false),
        new Column('Price Book', 'priceBook', null, true, false),
        new Column('Discount %', 'discountPercent', null, true, false)
      };
      theWrapper = getDiscountPerItem(theAccount, theWrapper);
    } 
    //DPHA - Add Discount per product line
    else if (informationToGet == System.Label.SMC_Discount_Per_Product_Line) {
      //Discount Per Product Line
      theWrapper.isDiscountPerProductLine = true;
      theWrapper.columns = new List<Column>{
        new Column('Product Line', 'productLine', 'txt ', true, false),
        new Column('Discount %', 'discountPercent', 'number', true, false)
      };
      theWrapper = getDiscountPerProductLine(theAccount, theWrapper);
    }
    System.debug(
      LoggingLevel.INFO,
      '>>>>>>SMC_AC_Follow_Customer -> Method initialisation - END'
    );
    return JSON.serialize(theWrapper);
  }

  /**
   * @description : get account informations
   * @author Vincent RECASENS (Modis) | 07-10-2020
   * @param recordId
   * @return Account
   **/
  @AuraEnabled
  public static Account getAccount(String recordId) {
    return [
      SELECT
        Id,
        Name,
        AccountNumber,
        SMC_TECH_Suffix_Smartconf__c,
        SMC_ERPID_PCS__c,
        SMC_ERPID_EE__c,
        SMC_TECH_Sales_Office__c
      FROM Account
      WHERE Id = :recordId
    ];
  }

  /**
   * @description : get account informations
   * @author Vincent RECASENS (Modis) | 07-10-2020
   * @param recordId
   * @return Account
   **/
  @AuraEnabled
  public static Account getBusinessPlan(String recordId) {
    SMC_Business_Plan__c theBP = [
      SELECT SMC_Account__c
      FROM SMC_Business_Plan__c
      WHERE Id = :recordId
    ];
    return [
      SELECT
        Id,
        Name,
        AccountNumber,
        SMC_TECH_Suffix_Smartconf__c,
        SMC_ERPID_PCS__c,
        SMC_ERPID_EE__c
      FROM Account
      WHERE Id = :theBP.SMC_Account__c
    ];
  }

  /**
   * @description : get financial statics
   * @author Vincent RECASENS (Modis) | 07-10-2020
   * @param theAccount
   * @return List<SMC_AC_Follow_Customer.Data>
   **/
  @TestVisible
  private static WrapperCustomerInformations getStatistic(
    Account theAccount,
    WrapperCustomerInformations theWrapper
  ) {
    System.debug(
      LoggingLevel.INFO,
      '>>>>>>SMC_AC_Follow_Customer -> Method getStatistic - START'
    );

    //Return value
    // List<SMC_AC_Follow_Customer.Data> datas;

    //Callout informations
    Case_Callout__mdt calloutInformations = SMC_UtilsMethod.getEndpointWebmethodCaseCallout(
      STA_UtilsStatic.FC_STATISTICS
    );
    
    if(theAccount.AccountNumber == null){
      return theWrapper;
    }

    String theEndpoint =
      calloutInformations.The_URL__c + theAccount.AccountNumber;
    System.debug(LoggingLevel.INFO, 'theEndpoint  :' + theEndpoint);

    //Send request
    theWrapper = sendRequestAndDeserializeResponse(
      theAccount.Id,
      theWrapper,
      theEndpoint,
      STA_UtilsStatic.ERROR_FOLLOW_STATISTICS
    );
    System.debug(
      LoggingLevel.INFO,
      '>>>>>>SMC_AC_Follow_Customer -> Method getStatistic - END'
    );
    return theWrapper;
  }

  /**
   * @description : get financial discount C123 (new base) / ERP PCS à tester = ...
   * @author Vincent RECASENS (Modis) | 07-10-2020
   * @param theAccount
   * @return WrapperCustomerInformations
   **/
  @TestVisible
  private static WrapperCustomerInformations getNewDiscount(
    Account theAccount,
    WrapperCustomerInformations theWrapper
  ) {
    System.debug(
      LoggingLevel.INFO,
      '>>>>>>SMC_AC_Follow_Customer -> Method getNewDiscount - START'
    );

    //Return value
    // List<SMC_AC_Follow_Customer.Data> datas;

    //Callout informations
    Case_Callout__mdt calloutInformations = SMC_UtilsMethod.getEndpointWebmethodCaseCallout(
      STA_UtilsStatic.FC_DISCOUNT
    );
    
    if(theAccount.SMC_TECH_Sales_Office__c == null || theAccount.SMC_ERPID_PCS__c == null){
      return theWrapper;
    }

    String theEndpoint =
      calloutInformations.The_URL__c +
      theAccount.SMC_ERPID_PCS__c +
      // 'BP0001471' +
      calloutInformations.URL_Complement_Ending__c + theAccount.SMC_TECH_Sales_Office__c;
    System.debug(LoggingLevel.INFO, 'theEndpoint  :' + theEndpoint);

    //Send request
    theWrapper = sendRequestAndDeserializeResponse(
      theAccount.Id,
      theWrapper,
      theEndpoint,
      STA_UtilsStatic.ERROR_FOLLOW_DISCOUNT
    );
    System.debug(
      LoggingLevel.INFO,
      '>>>>>>SMC_AC_Follow_Customer -> Method getNewDiscount - END'
    );
    return theWrapper;
  }

  /**
   * @description : get financial discount C123 (new base) / ERP PCS à tester = ...
   * @author Vincent RECASENS (Modis) | 07-10-2020
   * @param theAccount
   * @return WrapperCustomerInformations
   **/
  @TestVisible
  private static WrapperCustomerInformations getNewNetPrice(
    Account theAccount,
    WrapperCustomerInformations theWrapper
  ) {
    System.debug(
      LoggingLevel.INFO,
      '>>>>>>SMC_AC_Follow_Customer -> Method getNewNetPrice - START'
    );

    //Return value
    // List<SMC_AC_Follow_Customer.Data> datas;

    //Callout informations
    Case_Callout__mdt calloutInformations = SMC_UtilsMethod.getEndpointWebmethodCaseCallout(
      STA_UtilsStatic.FC_NET_PRICE
    );

    if(theAccount.SMC_TECH_Sales_Office__c == null || theAccount.SMC_ERPID_PCS__c == null){
      return theWrapper;
    }

    String theEndpoint =
      calloutInformations.The_URL__c +
      theAccount.SMC_ERPID_PCS__c +
      // 'BP0001939' +
      calloutInformations.URL_Complement_Ending__c + theAccount.SMC_TECH_Sales_Office__c;
    System.debug(LoggingLevel.INFO, 'theEndpoint  :' + theEndpoint);

    //Send request
    theWrapper = sendRequestAndDeserializeResponse(
      theAccount.Id,
      theWrapper,
      theEndpoint,
      STA_UtilsStatic.ERROR_FOLLOW_PRODUCT_NET_PRICE
    );
    System.debug(
      LoggingLevel.INFO,
      '>>>>>>SMC_AC_Follow_Customer -> Method getNewNetPrice - END'
    );
    return theWrapper;
  }

  /**
   * @description : get financial discount per item C123 (new base) / ERP PCS à tester = ...
   * @author Vincent RECASENS (Modis) | 07-10-2020
   * @param theAccount
   * @return WrapperCustomerInformations
   **/
  @TestVisible
  private static WrapperCustomerInformations getDiscountPerItem(
    Account theAccount,
    WrapperCustomerInformations theWrapper
  ) {
    System.debug(
      LoggingLevel.INFO,
      '>>>>>>SMC_AC_Follow_Customer -> Method getDiscountPerItem - START'
    );

    //Return value
    // List<SMC_AC_Follow_Customer.Data> datas;

    //Callout informations
    Case_Callout__mdt calloutInformations = SMC_UtilsMethod.getEndpointWebmethodCaseCallout(
      STA_UtilsStatic.FC_DISCOUNT_PER_ITEM
    );

    if(theAccount.SMC_TECH_Sales_Office__c == null || theAccount.SMC_ERPID_PCS__c == null){
      return theWrapper;
    }
    
    String theEndpoint =
      calloutInformations.The_URL__c +
      theAccount.SMC_ERPID_PCS__c +
      // 'BP0032775' +
      // 'BP0001471' +
      calloutInformations.URL_Complement_Ending__c + theAccount.SMC_TECH_Sales_Office__c;
    System.debug(LoggingLevel.INFO, 'theEndpoint  :' + theEndpoint);

    //Send request
    theWrapper = sendRequestAndDeserializeResponse(
      theAccount.Id,
      theWrapper,
      theEndpoint,
      STA_UtilsStatic.ERROR_FOLLOW_DISCOUNT_PER_ITEM
    );
    System.debug(
      LoggingLevel.INFO,
      '>>>>>>SMC_AC_Follow_Customer -> Method getDiscountPerItem - END'
    );
    return theWrapper;
  }

  /**
   * @description : Get financial discount per product line
   * @author Denis PHAM (Modis) | 12-04-2022
   * @param theAccount
   * @return WrapperCustomerInformations
   **/
  @TestVisible
  private static WrapperCustomerInformations getDiscountPerProductLine(
    Account theAccount,
    WrapperCustomerInformations theWrapper
  ) {
    System.debug(
      LoggingLevel.INFO,
      '>>>>>>SMC_AC_Follow_Customer -> Method getDiscountPerProductLine - START'
    );

    //Return value - DPHA To verify
    // List<SMC_AC_Follow_Customer.Data> datas;

    //Callout informations
    Case_Callout__mdt calloutInformations = SMC_UtilsMethod.getEndpointWebmethodCaseCallout(
      STA_UtilsStatic.FC_DISCOUNT_PER_PRODUCT_LINE
    );

    if(theAccount.SMC_TECH_Sales_Office__c == null || theAccount.SMC_ERPID_PCS__c == null){
      return theWrapper;
    }
    
    String theEndpoint =
      calloutInformations.The_URL__c +
      theAccount.SMC_ERPID_PCS__c +
      // 'BP0032775' +
      // 'BP0001471' +
      calloutInformations.URL_Complement_Ending__c + theAccount.SMC_TECH_Sales_Office__c;
    System.debug(LoggingLevel.INFO, 'theEndpoint  :' + theEndpoint);

    //Send request
    theWrapper = sendRequestAndDeserializeResponse(
      theAccount.Id,
      theWrapper,
      theEndpoint,
      STA_UtilsStatic.ERROR_FOLLOW_DISCOUNT_PER_PRODUCT_LINE
    );
    System.debug(
      LoggingLevel.INFO,
      '>>>>>>SMC_AC_Follow_Customer -> Method getDiscountPerProductLine - END'
    );
    return theWrapper;
  }

  /**
   * @description : send request and deserialize response body to List<SMC_AC_Follow_Customer.Data>
   * @author Vincent RECASENS (Modis) | 02-23-2021
   * @param recordId
   * @param theWrapper
   * @param theEndpoint
   * @param errorMessage
   * @return WrapperCustomerInformations
   **/
  private static WrapperCustomerInformations sendRequestAndDeserializeResponse(
    Id recordId,
    WrapperCustomerInformations theWrapper,
    String theEndpoint,
    String errorMessage
  ) {
    System.debug(
      LoggingLevel.INFO,
      '>>>>>>SMC_AC_Follow_Customer -> Method sendRequestAndDeserializeResponse - START'
    );
    //Build the callout*****
    HttpRequest request = new HttpRequest();
    request.setEndpoint(theEndpoint);
    request.setMethod(STA_UtilsStatic.GET_METHOD);
    request.setHeader(
      STA_UtilsStatic.CONTENT_TYPE,
      STA_UtilsStatic.APPLICATION_JSON
    );
    request.setTimeout(120000);

    String requestBody = STA_UtilsStatic.BODY_SYSDEBUG + request.getBody(); // Body empty
    String requestQuery =
      STA_UtilsStatic.QUERY_SYSDEBUG + request.getEndpoint();

    Http http = new Http();
    HTTPResponse response = new HTTPResponse();
    try {
      response = http.send(request);
      String bodyWithCurrencyTransformToCcy = replaceCurrencyElmt(
        response.getBody()
      );
      System.debug(LoggingLevel.INFO, 'Response body : ' + response.getBody());
      System.debug(
        LoggingLevel.INFO,
        'Response body with CCY : ' + bodyWithCurrencyTransformToCcy
      );
      theWrapper.datas = (List<SMC_AC_Follow_Customer.Data>) JSON.deserialize(
        bodyWithCurrencyTransformToCcy,
        (List<SMC_AC_Follow_Customer.Data>.class)
      );
      // //Error
      // if (response.getStatusCode() != 200 && response.getStatusCode() != 204) {
      //   CalloutException calloutException = new CalloutException();
      //   calloutException.setMessage(
      //     STA_UtilsStatic.BAD_STATUS_CODE +
      //     response.getStatusCode() +
      //     ' -> BODY : ' +
      //     response.getBody()
      //   );
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
        new List<CalloutException>{ calloutException },
        errorMessage,
        STA_UtilsStatic.PICKLIST_LOGS_PROCESS_TYPE_WS,
        requestBody,
        requestQuery,
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
      SMC_UTIL_Methods_Batch.createErrorLog(
        new List<JSONException>{ jsonException },
        errorMessage,
        STA_UtilsStatic.PICKLIST_LOGS_PROCESS_TYPE_WS,
        requestBody,
        requestQuery,
        new List<String>{ recordId }
      );
    } catch (Exception e) {
      System.debug(LoggingLevel.INFO, 'Exception : ' + e);
      SMC_UTIL_Methods_Batch.createErrorLog(
        new List<Exception>{ e },
        errorMessage,
        STA_UtilsStatic.PICKLIST_LOGS_PROCESS_TYPE_WS,
        requestBody,
        requestQuery,
        new List<String>{ recordId }
      );
    }

    System.debug(
      LoggingLevel.INFO,
      '>>>>>>SMC_AC_Follow_Customer -> Method sendRequestAndDeserializeResponse - END'
    );
    return theWrapper;
  }

  /**
   * @description : remove elmt currency from response body cause "currency" is a key word in Apex and can not be used in Wrapper or DTO
   * @author Vincent RECASENS (Modis) | 02-23-2021
   * @param responseBody
   * @return String
   **/
  private static String replaceCurrencyElmt(String responseBody) {
    String responseWithoutCurrency = '';
    if (responseBody.contains('"currency"')) {
      responseWithoutCurrency = responseBody.replace('"currency"', '"ccy"');
    } else {
      responseWithoutCurrency = responseBody;
    }

    return responseWithoutCurrency;
  }

  /**
   * @description : remove elmt currency from response body cause "currency" is a key word in Apex and can not be used in Wrapper or DTO
   * @author Vincent RECASENS (Modis) | 02-23-2021
   * @param responseBody
   * @return String
   **/
  @TestVisible
  private static String removeCurrencyElmt(String responseBody) {
    String responseWithoutCurrency = '';
    if (responseBody.contains('"currency":')) {
      String[] tabStrToRemoveCurrency = responseBody.split('"currency":');
      String strToDeserialized = '';
      for (Integer i = 0; i < tabStrToRemoveCurrency.size(); ++i) {
        if (i == 0) {
          strToDeserialized += tabStrToRemoveCurrency[i];
        } else {
          strToDeserialized += tabStrToRemoveCurrency[i]
            .substring(
              tabStrToRemoveCurrency[i].indexOf(',') + 1,
              tabStrToRemoveCurrency[i].length()
            );
        }
        responseWithoutCurrency = strToDeserialized;
      }
    } else {
      responseWithoutCurrency = responseBody;
    }

    return responseWithoutCurrency;
  }

  /**
   * @description : get financial discount
   * @author Vincent RECASENS (Modis) | 07-10-2020
   * @param theAccount
   * @return WrapperCustomerInformations
   **/
  @TestVisible
  private static WrapperCustomerInformations getFamilyDiscount(
    Account theAccount,
    WrapperCustomerInformations theWrapper
  ) {
    System.debug(
      LoggingLevel.INFO,
      '>>>>>>SMC_AC_Follow_Customer -> Method getFamilyDiscount - START'
    );

    //Return value
    // List<SMC_AC_Follow_Customer.Data> datas;

    //Callout informations
    Case_Callout__mdt calloutInformations = SMC_UtilsMethod.getEndpointWebmethodCaseCallout(
      STA_UtilsStatic.FAMILIY_DISCOUNT
    );

    if(theAccount.SMC_TECH_Suffix_Smartconf__c == null || (theAccount.SMC_ERPID_PCS__c == null && theAccount.SMC_ERPID_EE__c == null)){
      return theWrapper;
    }

    String theEndpoint =
      calloutInformations.The_URL__c +
      theAccount.SMC_TECH_Suffix_Smartconf__c +
      calloutInformations.URL_Complement_Ending__c +
      (theAccount.SMC_ERPID_PCS__c != null
        ? theAccount.SMC_ERPID_PCS__c
        : theAccount.SMC_ERPID_EE__c);

    //Send request
    theWrapper = sendRequestAndDeserializeResponse(
      theAccount.Id,
      theWrapper,
      theEndpoint,
      STA_UtilsStatic.ERROR_FOLLOW_FAMILY_DISCOUNT
    );
    System.debug(
      LoggingLevel.INFO,
      '>>>>>>SMC_AC_Follow_Customer -> Method getFamilyDiscount - END'
    );
    return theWrapper;
  }

  /**
   * @description : get financial price list
   * @author Vincent RECASENS (Modis) | 07-10-2020
   * @param theAccount
   * @return WrapperCustomerInformations
   **/
  @TestVisible
  private static WrapperCustomerInformations getPriceList(
    Account theAccount,
    WrapperCustomerInformations theWrapper
  ) {
    System.debug(
      LoggingLevel.INFO,
      '>>>>>>SMC_AC_Follow_Customer -> Method getPriceList - START'
    );

    //Return value
    // List<SMC_AC_Follow_Customer.Data> datas;

    //Callout informations
    Case_Callout__mdt calloutInformations = SMC_UtilsMethod.getEndpointWebmethodCaseCallout(
      STA_UtilsStatic.PRODUCT_NET_PRICE
    );

    if(theAccount.SMC_TECH_Suffix_Smartconf__c == null || (theAccount.SMC_ERPID_PCS__c == null && theAccount.SMC_ERPID_EE__c == null)){
      return theWrapper;
    }

    String theEndpoint =
      calloutInformations.The_URL__c +
      theAccount.SMC_TECH_Suffix_Smartconf__c +
      calloutInformations.URL_Complement_Ending__c +
      (theAccount.SMC_ERPID_PCS__c != null
        ? theAccount.SMC_ERPID_PCS__c
        : theAccount.SMC_ERPID_EE__c);

    //Send request
    theWrapper = sendRequestAndDeserializeResponse(
      theAccount.Id,
      theWrapper,
      theEndpoint,
      STA_UtilsStatic.ERROR_FOLLOW_PRODUCT_NET_PRICE
    );
    System.debug(
      LoggingLevel.INFO,
      '>>>>>>SMC_AC_Follow_Customer -> Method getPriceList - END'
    );
    return theWrapper;
  }
}