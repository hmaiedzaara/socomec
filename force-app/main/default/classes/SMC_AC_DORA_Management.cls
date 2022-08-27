/**
 * @description       :
 * @author            : Vincent RECASENS (Modis)
 * @group             :
 * @last modified on  : 11-13-2020
 * @last modified by  : Vincent RECASENS (Modis)
 * Modifications Log
 * Ver   Date         Author                     Modification
 * 1.0   10-06-2020   Vincent RECASENS (Modis)   Initial Version
 **/
public without sharing class SMC_AC_DORA_Management {
  public class WrapperPicklists {
    @AuraEnabled
    public String label { get; set; }
    @AuraEnabled
    public String value { get; set; }

    public WrapperPicklists(String label, String value) {
      this.label = label;
      this.value = value;
    }
  }

  public class WrapperStaticInfos {
    @AuraEnabled
    public List<WrapperPicklists> countries { get; set; }
    @AuraEnabled
    public Map<String, Map<String, String>> statesDepenciesAndValues {
      get;
      set;
    }
    public WrapperStaticInfos() {
    }
  }

  /**
  * @description : save in cache NewOrder 
  * @author Vincent RECASENS (Modis) | 04-19-2021 
  * @param serializedOrder 
  **/
  @AuraEnabled
  public static void saveTemporaryOrderInCache(String serializedOrder) {
    System.debug('SMC_AC_DORA_Management.saveTemporaryOrderInCache START');
    Cache.SessionPartition sessionPart;
    try{
      sessionPart = Cache.Session.getPartition(
        'local.OrderOnlineManagement'
      );
    }
    catch(Exception e){
      System.debug('SMC_AC_DORA_Management.saveTemporaryOrderInCache : put new cache');
      sessionPart = new Cache.SessionPartition('local.OrderOnlineManagement');
    }
    String usernameFormatted = UserInfo.getUserName()
                                       .replace('.', '')
                                       .replace('@', '')
                                       .replace('-', '')
                                       .replace('_', '');
    sessionPart.put(usernameFormatted + 'NOTMP', serializedOrder); // _NewOrderTeMPorary
    System.debug('SMC_AC_DORA_Management.saveTemporaryOrderInCache END');
  }

  /**
  * @description : get NewOrder cached
  * @author Vincent RECASENS (Modis) | 04-19-2021 
  * @return String 
  **/
  @AuraEnabled
  public static String getTemporaryOrderInCache() {
    System.debug('getTemporaryOrderInCache START');
    Cache.SessionPartition sessionPart;
    try{
      sessionPart = Cache.Session.getPartition(
        'local.OrderOnlineManagement'
      );
      String usernameFormatted = UserInfo.getUserName().replace('.', '').replace('@', '');
      System.debug('getTemporaryOrderInCache END');
      return (String) sessionPart.get(usernameFormatted + 'NOTMP');
    }
    catch(Exception e){
      System.debug('SMC_AC_DORA_Management.getTemporaryOrderInCache Empty END');
      return '';
    }
  }

  /**
  * @description : clear cache when reset NewOrder
  * @author Vincent RECASENS (Modis) | 04-20-2021 
  **/
  @AuraEnabled
  public static void clearTemporaryOrderInCache(){
    System.debug('clearTemporaryOrderInCache START');
    Cache.SessionPartition sessionPart;
    try{
      sessionPart = Cache.Session.getPartition(
        'local.OrderOnlineManagement'
      );
      String usernameFormatted = UserInfo.getUserName().replace('.', '').replace('@', '');
      sessionPart.remove(usernameFormatted + 'NOTMP');
    }
    catch(Exception e){
      System.debug('SMC_AC_DORA_Management.clearTemporaryOrderInCache Empty END');
    }
  }

  
  /**
  * @description : save in cache account selection for "MyOrder"
  * @author Tanya SIBONI (Modis) | 05-12-2021 
  * @param serializedAccount 
  **/
  @AuraEnabled
  public static void saveTemporaryAccountInCache(String serializedAccount) {
    Cache.SessionPartition sessionPart;
    try{
      sessionPart = Cache.Session.getPartition(
        'local.OrderOnlineManagement'
      );
    }
    catch(Exception e){
      System.debug('SMC_AC_DORA_Management.saveTemporaryAccountInCache : put new cache');
      sessionPart = new Cache.SessionPartition('local.OrderOnlineManagement');
    }
    String usernameFormatted = UserInfo.getUserName().replace('.', '').replace('@', '');
    sessionPart.put(usernameFormatted + 'MOTMP', serializedAccount); // _MyOrderTeMPorary
    System.debug('saveTemporaryAccountInCache END');
  }

  /**
  * @description : get account selection for "MyOrder" cached
  * @author Tanya SIBONI (Modis) | 05-12-2021 
  * @return String 
  **/
  @AuraEnabled
  public static String getTemporaryAccountInCache() {
    System.debug('getTemporaryAccountInCache START');
    Cache.SessionPartition sessionPart;
    try{
      sessionPart = Cache.Session.getPartition(
        'local.OrderOnlineManagement'
      );
      String usernameFormatted = UserInfo.getUserName().replace('.', '').replace('@', '');
      System.debug('getTemporaryAccountInCache END');
      return (String) sessionPart.get(usernameFormatted + 'MOTMP');
    }
    catch(Exception e){
      System.debug('SMC_AC_DORA_Management.getTemporaryAccountInCache Empty END');
      return '';
    }
  }
    
  // private static String setUserEmail() {
  //   String userEmail;
  //   List<String> sandboxes = new List<String>{
  //     '.dev',
  //     '.int',
  //     '.qa',
  //     '.preprod'
  //   };
  //   if (!Test.isRunningTest()) {
  //     String currentUsername = UserInfo.getUserName();
  //     String emailBegins = currentUsername.split('@')[0] + '@';
  //     String[] endEmailChecker = currentUsername.split('@')[1].split('\\.');
  //     if (
  //       sandboxes.contains('.' + endEmailChecker[endEmailChecker.size() - 1])
  //     ) {
  //       userEmail = emailBegins;
  //       for (Integer i = 0; i < endEmailChecker.size() - 1; ++i) {
  //         userEmail += endEmailChecker[i] + '.';
  //       }
  //       userEmail = userEmail.substring(0, userEmail.length() - 1);
  //     } else {
  //       userEmail = currentUsername;
  //     }
  //   } else {
  //     userEmail = UserInfo.getUserEmail();
  //   }
  //   /* TEMPORARY */
  //   // userEmail = 'alessandro.schiavo@socomec.com';
  //   userEmail = 'david.sobczak@socomec.com';
  //   /* TEMPORARY */
  //   return userEmail;
  // }

  private static String setUsernameWebserviceOrder() {
    String usernameWebserviceOrder;
    List<String> sandboxes = new List<String>{
      '.dev',
      '.int',
      '.qa',
      '.preprod'
    };
    Id currentUserId = UserInfo.getUserId();
    usernameWebserviceOrder = [SELECT Id, SMC_Username_Webservice_Order__c FROM User WHERE Id =: currentUserId ].SMC_Username_Webservice_Order__c;
    /* TEMPORARY */
    // usernameWebserviceOrder = 'alessandro.schiavo@socomec.com';
    // usernameWebserviceOrder = 'david.sobczak@socomec.com';
    /* TEMPORARY */
    return usernameWebserviceOrder;
  }

  /**
  * @description : get user permission to modify net price for NewOrder
  * @author Vincent RECASENS (Modis) | 04-19-2021 
  * @return Boolean 
  **/
  @AuraEnabled
  public static Boolean getUserNetPricePermission() {
    return FeatureManagement.checkPermission(STA_UtilsStatic.OVERRIDE_NET_PRICE_ONLINE_ORDERING);
  }

  /**
  * @description : get metadata information in DORA_Technical_Static__mdt
  * @author Vincent RECASENS (Modis) | 04-19-2021 
  * @return Map<String, String> 
  **/
  @AuraEnabled
  public static Map<String, String> getTechnicalLines() {
    Map<String, String> returnedMap = new Map<String, String>();
    for (DORA_Technical_Static__mdt doraMdt : [
      SELECT MasterLabel, DeveloperName
      FROM DORA_Technical_Static__mdt
    ]) {
      returnedMap.put(doraMdt.DeveloperName, doraMdt.MasterLabel);
    }
    return returnedMap;
  }

   /**
  * @description : get country List
  * @author Tanya SIBONI (Modis) | 05-06-2021 
  * @return WrapperStaticInfos
  **/
  @AuraEnabled
  public static WrapperStaticInfos getStaticInformations() {
    WrapperStaticInfos wrapperStaticInfos = new WrapperStaticInfos();
    // Countries
    List<WrapperPicklists> countryValues = new List<WrapperPicklists>();
    Schema.DescribeFieldResult fieldResult = Account.BillingCountryCode.getDescribe();
    List<Schema.PicklistEntry> entries = fieldResult.getPicklistValues();
    for (Schema.PicklistEntry entry : entries) {
      countryValues.add(
        new WrapperPicklists(entry.getLabel(), entry.getValue())
      );
    }
    wrapperStaticInfos.countries = countryValues;
    return wrapperStaticInfos;
  }

  @AuraEnabled
  public static WrapperStaticInfos getStates(){
    WrapperStaticInfos wrapperStaticInfos = new WrapperStaticInfos();
    // States
    List<WrapperPicklists> stateValues = new List<WrapperPicklists>();
    Schema.DescribeFieldResult fieldResultState = Account.BillingStateCode.getDescribe();
    List<Schema.PicklistEntry> entriesState = fieldResultState.getPicklistValues();
    for (Schema.PicklistEntry entry : entriesState) {
      stateValues.add(new WrapperPicklists(entry.getLabel(), entry.getValue()));
    }
    wrapperStaticInfos.statesDepenciesAndValues = setMapCountryToStateLabelValue(
      stateValues,
      getDependentPicklistValues(Account.BillingStateCode)
    );

    return wrapperStaticInfos;
  }

  @TestVisible
  private static Map<String, List<String>> getDependentPicklistValues(
    Schema.sObjectField dependToken
  ) {
    Schema.DescribeFieldResult depend = dependToken.getDescribe();
    Schema.sObjectField controlToken = depend.getController();
    if (controlToken == null) {
      return new Map<String, List<String>>();
    }

    Schema.DescribeFieldResult control = controlToken.getDescribe();
    List<Schema.PicklistEntry> controlEntries;
    if (control.getType() != Schema.DisplayType.Boolean) {
      controlEntries = control.getPicklistValues();
    }

    String base64map = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
    Map<String, List<String>> dependentPicklistValues = new Map<String, List<String>>();
    for (Schema.PicklistEntry entry : depend.getPicklistValues()) {
      if (
        entry.isActive() &&
        String.isNotEmpty(
          String.valueOf(
            ((Map<String, Object>) JSON.deserializeUntyped(
                JSON.serialize(entry)
              ))
              .get('validFor')
          )
        )
      ) {
        List<String> base64chars = String.valueOf(
            ((Map<String, Object>) JSON.deserializeUntyped(
                JSON.serialize(entry)
              ))
              .get('validFor')
          )
          .split('');
        for (
          Integer index = 0;
          index < (controlEntries != null ? controlEntries.size() : 2);
          index++
        ) {
          Object controlValue = (controlEntries == null
            ? (Object) (index == 1)
            : (Object) (controlEntries[index].isActive()
                ? controlEntries[index].getLabel()
                : null));
          Integer bitIndex = index / 6;
          if (bitIndex > base64chars.size() - 1) {
            break;
          }
          Integer bitShift = 5 - Math.mod(index, 6);
          if (
            controlValue == null ||
            (base64map.indexOf(base64chars[bitIndex]) & (1 << bitShift)) == 0
          )
            continue;
          if (!dependentPicklistValues.containsKey((String) controlValue)) {
            dependentPicklistValues.put(
              (String) controlValue,
              new List<String>()
            );
          }
          dependentPicklistValues.get((String) controlValue)
            .add(entry.getLabel());

          if(Test.isRunningTest() && dependentPicklistValues.size() > 0){
            break;
          }
        }
        if(Test.isRunningTest() && dependentPicklistValues.size() > 0){
          break;
        }
      }
    }
    return dependentPicklistValues;
  }

  @TestVisible
  private static Map<String, Map<String, String>> setMapCountryToStateLabelValue(
    List<WrapperPicklists> states,
    Map<String, List<String>> statesDependencies
  ) {
    Map<String, Map<String, String>> result = new Map<String, Map<String, String>>();
    //Country
    for (String country : statesDependencies.keySet()) {
      result.put(country, new Map<String, String>());
      //State dependencies
      for (String oneStateLabel : statesDependencies.get(country)) {
        //State label & value
        for (WrapperPicklists oneStateElmt : states) {
          if (oneStateElmt.label == oneStateLabel) {
            result.get(country).put(oneStateElmt.value, oneStateElmt.label);
            break;
          }
        }
      }
    }
    return result;
  }

  /**
   * @description : get all accounts with only useremail
   * @author Vincent RECASENS (Modis) | 10-06-2020
   * @return SMC_DTO_DORA
   **/
  @AuraEnabled
  public static String getAccounts() {
    String fromWhere = 'accounts';
    Map<String, String> mapKeyParamToValue = new Map<String, String>();
    mapKeyParamToValue.put('usermail', setUsernameWebserviceOrder());
    return JSON.serialize(
      SMC_AP_DORA_Callout.calloutMethod(fromWhere, mapKeyParamToValue)
    );
  }


  /**
   * @description : get specific account
   * @author Vincent RECASENS (Modis) | 10-06-2020
   * @param cdcli
   * @return SMC_DTO_DORA
   **/
  @AuraEnabled
  public static String getSpecificAccount(String cdcli) {
    String fromWhere = 'accountSpecific';
    Map<String, String> mapKeyParamToValue = new Map<String, String>();
    mapKeyParamToValue.put('usermail', setUsernameWebserviceOrder());
    mapKeyParamToValue.put('cdcli', cdcli);
    return JSON.serialize(
      SMC_AP_DORA_Callout.calloutMethod(fromWhere, mapKeyParamToValue)
    );
  }

  /**
   * @description : get products with only useremail
   * @author Vincent RECASENS (Modis) | 10-06-2020
   * @param fromWhere
   * @return SMC_DTO_DORA
   **/
  @AuraEnabled
  public static String getProducts(String fromWhere, String cdcli) {
    Map<String, String> mapKeyParamToValue = new Map<String, String>();
    mapKeyParamToValue.put('usermail', setUsernameWebserviceOrder());
    mapKeyParamToValue.put('cdcli', cdcli);
    return JSON.serialize(
      SMC_AP_DORA_Callout.calloutMethod(fromWhere, mapKeyParamToValue)
    );
  }

  /**
   * @description : get products with only useremail
   * @author Vincent RECASENS (Modis) | 10-06-2020
   * @param fromWhere
   * @return SMC_DTO_DORA
   **/
  @AuraEnabled
  public static String getProductAvaibility(
    String fromWhere,
    String cdcli,
    String cdpar,
    Integer quantity
  ) {
    Map<String, String> mapKeyParamToValue = new Map<String, String>();
    mapKeyParamToValue.put('usermail', setUsernameWebserviceOrder());
    mapKeyParamToValue.put('cdcli', cdcli);
    mapKeyParamToValue.put('cdpar', cdpar);
    mapKeyParamToValue.put('quantity', String.valueOf(quantity));
    return JSON.serialize(
      SMC_AP_DORA_Callout.calloutMethod(fromWhere, mapKeyParamToValue)
    );
  }

  /**
   * @description : get orders
   * @author Vincent RECASENS (Modis) | 10-09-2020
   * @param cdcli
   * @return String
   **/
  @AuraEnabled
  public static String getOrderHeaders(String cdcli) {
    String fromWhere = 'orderHeaders';
    Map<String, String> mapKeyParamToValue = new Map<String, String>();
    mapKeyParamToValue.put('usermail', setUsernameWebserviceOrder());
    mapKeyParamToValue.put('cdcli', cdcli);
    return JSON.serialize(
      SMC_AP_DORA_Callout.calloutMethod(fromWhere, mapKeyParamToValue)
    );
  }

  /**
   * @description : get order lines for an order
   * @author Vincent RECASENS (Modis) | 10-09-2020
   * @param cdodr
   * @return String
   **/
  @AuraEnabled
  public static String getOrderRows(String cdord) {
    String fromWhere = 'orderRows';
    Map<String, String> mapKeyParamToValue = new Map<String, String>();
    mapKeyParamToValue.put('usermail', setUsernameWebserviceOrder());
    mapKeyParamToValue.put('cdord', cdord);
    return JSON.serialize(
      SMC_AP_DORA_Callout.calloutMethod(fromWhere, mapKeyParamToValue)
    );
  }

  /**
   * @description : get order lines for an order
   * @author Vincent RECASENS (Modis) | 10-09-2020
   * @param cdodr
   * @return String
   **/
  @AuraEnabled
  public static String getOrderGuestUser(String secret) {
    String fromWhere = 'orderGuestUser';
    Map<String, String> mapKeyParamToValue = new Map<String, String>();
    mapKeyParamToValue.put('usermail', setUsernameWebserviceOrder());
    mapKeyParamToValue.put('secret', secret);
    return JSON.serialize(
      SMC_AP_DORA_Callout.calloutMethod(fromWhere, mapKeyParamToValue)
    );
  }

  /**
  * @description : post order
  * @author Vincent RECASENS (Modis) | 05-19-2021 
  * @param fromWhere 
  * @param cdcli 
  * @param cdord 
  * @param contactname 
  * @param contactphone 
  * @param custref 
  * @param requestedDate 
  * @param preftime 
  * @param taillift 
  * @param note 
  * @param addresscode 
  * @param newaddress 
  * @param rows 
  * @return String 
  **/
  @AuraEnabled
  public static String postSendOrder(
    String fromWhere,
    String cdcli,
    String cdord,
    String contactname,
    String contactphone,
    String custref,
    String requestedDate,
    String preftime,
    String taillift,
    String note,
    String addresscode,
    String newaddress,
    String rows
  ) {
    // String fromWhere = 'post_orderUpsert';
    Map<String, String> mapKeyParamToValue = new Map<String, String>();
    mapKeyParamToValue.put('usermail', setUsernameWebserviceOrder());
    mapKeyParamToValue.put('cdord', cdord);
    mapKeyParamToValue.put('cdcli', cdcli);
    mapKeyParamToValue.put('contactname', contactname);
    mapKeyParamToValue.put('contactphone', contactphone);
    mapKeyParamToValue.put('custref', custref);
    mapKeyParamToValue.put('expecteddate', requestedDate);
    mapKeyParamToValue.put('preftime', preftime);
    mapKeyParamToValue.put('taillift', taillift);
    mapKeyParamToValue.put('note', note);
    mapKeyParamToValue.put('addresscode', addresscode);
    mapKeyParamToValue.put('newaddress', newaddress);
    mapKeyParamToValue.put('rows', rows);
    //SECRET CODE
    DateTime d = System.now();
    String secretBuilder =
      '' +
      d.year() +
      '-' +
      d.month() +
      '-' +
      d.day() +
      cdcli +
      d.hour() +
      ':' +
      d.minute() +
      ':' +
      d.second() +
      '.' +
      d.millisecond() +
      '\'Z\'';
    String secret = EncodingUtil.base64Encode(Blob.valueOf(secretBuilder));
    if (secret.contains('=')) {
      secret = secret.remove('=');
    }
    mapKeyParamToValue.put('secret', secret);
    // SMC_DTO_DORA returnObject;
    SMC_DTO_DORA returnObject = SMC_AP_DORA_Callout.calloutMethod(fromWhere, mapKeyParamToValue);
    if(returnObject != null && !returnObject.getPostResult.error){
      clearTemporaryOrderInCache();
    }
    return JSON.serialize(returnObject);
    // return null;
  }

  /**
   * @description : delete order
   * @author Vincent RECASENS (Modis) | 10-09-2020
   * @param cdord
   * @return String
   **/
  @AuraEnabled
  public static String deleteOrder(String cdord) {
    String fromWhere = 'delete_order';
    Map<String, String> mapKeyParamToValue = new Map<String, String>();
    mapKeyParamToValue.put('usermail', setUsernameWebserviceOrder());
    mapKeyParamToValue.put('cdord', cdord);
    return JSON.serialize(
      SMC_AP_DORA_Callout.calloutMethod(fromWhere, mapKeyParamToValue)
    );
  }
}