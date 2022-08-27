/**
 * @description       : Test all DORA methods (callout, management...)
 * @author            : Vincent RECASENS (Modis)
 * @group             :
 * @last modified on  : 11-12-2020
 * @last modified by  : Vincent RECASENS (Modis)
 * Modifications Log
 * Ver   Date         Author                     Modification
 * 1.0   11-03-2020   Vincent RECASENS (Modis)   Initial Version
 **/
@IsTest(isParallel=false)
public class TEST_SMC_AP_DORA {
  @testSetup
  public static void setup() {
    Profile profileStandard = [
      SELECT Id
      FROM Profile
      WHERE Name = :STA_UtilsStatic.PROFILE_SALE_STANDARD
    ];
    User userStandard = SMC_UTIL_TestUtils.createUser(
      'standard-' + STA_UtilsStatic.USERNAME_TEST,
      'standard-' + STA_UtilsStatic.USERNAME_TEST,
      profileStandard.Id,
      'standard-' + STA_UtilsStatic.USERNAME_TEST,
      'standard-' + STA_UtilsStatic.USERNAME_TEST
    );
    userStandard.SMC_Username_Webservice_Order__c = STA_UtilsStatic.USERNAME_TEST;
    insert userStandard;

    Id netPricePermission = [
      SELECT id
      FROM PermissionSet
      WHERE Name = :STA_UtilsStatic.OVERRIDE_NET_PRICE_ONLINE_ORDERING
      LIMIT 1
    ]
    .Id;
    insert new PermissionSetAssignment(
      AssigneeId = userStandard.Id,
      PermissionSetId = netPricePermission
    );
  }

  @isTest
  public static void testGetUserNetPricePermission(){
    User userStandard = [
      SELECT Id
      FROM User
      WHERE Email = :('standard-' + STA_UtilsStatic.USERNAME_TEST)
    ];

    System.runAs(userStandard) {
      System.assert(SMC_AC_DORA_Management.getUserNetPricePermission(), 'Standard user has not the permission "SMC_NetPrice_OnlineOrdering"');
    }
  }

  @isTest
  public static void testGetMetadata() {
    User userStandard = [
      SELECT Id
      FROM User
      WHERE Email = :('standard-' + STA_UtilsStatic.USERNAME_TEST)
    ];

    System.runAs(userStandard) {
      Test.startTest();
      Map<String, String> result = SMC_AC_DORA_Management.getTechnicalLines();
      System.assertNotEquals(null, result);
      System.assert(result.size() > 0);
      Test.stopTest();
    }
  }

  @isTest
  public static void testGetEndpoint() {
    User userStandard = [
      SELECT Id, Email
      FROM User
      WHERE Email = :('standard-' + STA_UtilsStatic.USERNAME_TEST)
    ];

    System.runAs(userStandard) {
      SMC_AP_DORA_Callout calloutObj = new SMC_AP_DORA_Callout();
      Test.startTest();
      SMC_DORA_Endpoint__mdt result = calloutObj.getEndpoint(
        'accounts',
        new Map<String, String>{ 'usermail' => userStandard.Email },
        calloutObj
      );
      Test.stopTest();

      String getUrlParams = result.URL__c.split('account?')[1];
      System.assertEquals(
        userStandard.Email,
        getUrlParams.split('usermail=')[1]
      );
    }
  }

  @isTest
  public static void testCalloutMethod_GetAccounts() {
    User userStandard = [
      SELECT Id
      FROM User
      WHERE Email = :('standard-' + STA_UtilsStatic.USERNAME_TEST)
    ];

    System.runAs(userStandard) {
      Test.startTest();
      Test.setMock(
        HttpCalloutMock.class,
        new SMC_UTIL_DORA_Mock('MOCK_GET_ACCOUNTS_OK')
      );
      String returnStrDora = SMC_AC_DORA_Management.getAccounts();
      Test.stopTest();
      System.assertNotEquals('null', returnStrDora);
    }
  }

  @isTest
  public static void testCalloutMethod_GetAccountSpecific() {
    User userStandard = [
      SELECT Id
      FROM User
      WHERE Email = :('standard-' + STA_UtilsStatic.USERNAME_TEST)
    ];

    System.runAs(userStandard) {
      Test.startTest();
      Test.setMock(
        HttpCalloutMock.class,
        new SMC_UTIL_DORA_Mock('MOCK_GET_ACCOUNTS_SP_OK')
      );
      String returnStrDora = SMC_AC_DORA_Management.getSpecificAccount(
        'CLI123456'
      );
      Test.stopTest();
      System.assertNotEquals('null', returnStrDora);
    }
  }

  @isTest
  public static void testCalloutMethod_GetProducts() {
    User userStandard = [
      SELECT Id
      FROM User
      WHERE Email = :('standard-' + STA_UtilsStatic.USERNAME_TEST)
    ];

    System.runAs(userStandard) {
      Test.startTest();
      Test.setMock(
        HttpCalloutMock.class,
        new SMC_UTIL_DORA_Mock('MOCK_GET_ITEM_CODE_OK')
      );
      String returnStrDora = SMC_AC_DORA_Management.getProducts(
        'pdtAvaibilityHPWoQt',
        'CLI123456'
      );
      Test.stopTest();
      System.assertNotEquals('null', returnStrDora);
    }
  }

  @isTest
  public static void testCalloutMethod_GetItem_WQt() {
    User userStandard = [
      SELECT Id
      FROM User
      WHERE Email = :('standard-' + STA_UtilsStatic.USERNAME_TEST)
    ];

    System.runAs(userStandard) {
      Test.startTest();
      Test.setMock(
        HttpCalloutMock.class,
        new SMC_UTIL_DORA_Mock('MOCK_GET_ITEM_CODE_W_QT_OK')
      );
      String returnStrDora = SMC_AC_DORA_Management.getProductAvaibility(
        'pdtAvaibilityHPWQt',
        'CLI123456',
        'ITYSxxx',
        1
      );
      Test.stopTest();
      System.assertEquals('null', returnStrDora);
    }
  }

  @isTest
  public static void testCalloutMethod_GetOrderHeader() {
    User userStandard = [
      SELECT Id
      FROM User
      WHERE Email = :('standard-' + STA_UtilsStatic.USERNAME_TEST)
    ];

    System.runAs(userStandard) {
      Test.startTest();
      Test.setMock(
        HttpCalloutMock.class,
        new SMC_UTIL_DORA_Mock('MOCK_GET_ORDER_HEADERS_OK')
      );
      String returnStrDora = SMC_AC_DORA_Management.getOrderHeaders(
        'CLI123456'
      );
      Test.stopTest();
      System.assertNotEquals('null', returnStrDora);
    }
  }

  @isTest
  public static void testCalloutMethod_GetOrderRows() {
    User userStandard = [
      SELECT Id
      FROM User
      WHERE Email = :('standard-' + STA_UtilsStatic.USERNAME_TEST)
    ];

    System.runAs(userStandard) {
      Test.startTest();
      Test.setMock(
        HttpCalloutMock.class,
        new SMC_UTIL_DORA_Mock('MOCK_GET_ORDER_ROWS_OK')
      );
      String returnStrDora = SMC_AC_DORA_Management.getOrderRows('987654');
      Test.stopTest();
      System.assertNotEquals('null', returnStrDora);
    }
  }

  @isTest
  public static void testCalloutMethod_GetOrder_GuestUser() {
    User userStandard = [
      SELECT Id
      FROM User
      WHERE Email = :('standard-' + STA_UtilsStatic.USERNAME_TEST)
    ];

    System.runAs(userStandard) {
      Test.startTest();
      Test.setMock(
        HttpCalloutMock.class,
        new SMC_UTIL_DORA_Mock('MOCK_GET_ORDER_GU_OK')
      );
      String returnStrDora = SMC_AC_DORA_Management.getOrderGuestUser(
        'secretFromUrl'
      );
      Test.stopTest();
      System.assertNotEquals('null', returnStrDora);
    }
  }

  @isTest
  public static void testCalloutMethod_PostOrder() {
    User userStandard = [
      SELECT Id
      FROM User
      WHERE Email = :('standard-' + STA_UtilsStatic.USERNAME_TEST)
    ];

    System.runAs(userStandard) {
      Test.startTest();
      Test.setMock(
        HttpCalloutMock.class,
        new SMC_UTIL_DORA_Mock('MOCK_POST_RESULT_OK')
      );
      String returnStrDora = SMC_AC_DORA_Management.postSendOrder(
        'post_orderUpsert',
        'CLI123456',
        '987654',
        null,
        null,
        null,
        Date.today().format(),
        null,
        'no',
        null,
        'AD123456',
        null,
        JSON.serialize(
          new SMC_UTIL_DORA_Mock()
            .getMock('MOCK_GET_ITEM_CODE_OK')
            .getItemCode.data
        )
      );
      Test.stopTest();
      System.assertNotEquals('null', returnStrDora);
    }
  }

  @isTest
  public static void testCalloutMethod_Delete() {
    User userStandard = [
      SELECT Id
      FROM User
      WHERE Email = :('standard-' + STA_UtilsStatic.USERNAME_TEST)
    ];

    System.runAs(userStandard) {
      Test.startTest();
      Test.setMock(
        HttpCalloutMock.class,
        new SMC_UTIL_DORA_Mock('MOCK_POST_RESULT_OK')
      );
      String returnStrDora = SMC_AC_DORA_Management.deleteOrder('987654');
      Test.stopTest();
      System.assertNotEquals('null', returnStrDora);
    }
  }

  @isTest
  public static void testCalloutMethod_ERROR_STATUS() {
    User userStandard = [
      SELECT Id
      FROM User
      WHERE Email = :('standard-' + STA_UtilsStatic.USERNAME_TEST)
    ];

    System.runAs(userStandard) {
      Test.startTest();
      SMC_UTIL_DORA_Mock mockElmt = new SMC_UTIL_DORA_Mock(
        'MOCK_POST_RESULT_BAD',
        400
      );
      Test.setMock(HttpCalloutMock.class, mockElmt);
      String returnStrDora;
      try {
        returnStrDora = SMC_AC_DORA_Management.getAccounts();
        System.debug('testCalloutMethod_ERROR_STATUS : BAD');
      } catch (Exception e) {
        System.debug('testCalloutMethod_ERROR_STATUS : OK');
      }
      Test.stopTest();
      System.assertEquals('null', returnStrDora);
    }
  }

  @isTest
  public static void testCalloutMethod_ERROR_JSON() {
    User userStandard = [
      SELECT Id
      FROM User
      WHERE Email = :('standard-' + STA_UtilsStatic.USERNAME_TEST)
    ];

    System.runAs(userStandard) {
      Test.startTest();
      SMC_UTIL_DORA_Mock mockElmt = new SMC_UTIL_DORA_Mock('bad mock', 200);
      Test.setMock(HttpCalloutMock.class, mockElmt);
      String returnStrDora;
      try {
        returnStrDora = SMC_AC_DORA_Management.getAccounts();
        System.debug('testCalloutMethod_ERROR_JSON : BAD');
      } catch (Exception e) {
        System.debug('testCalloutMethod_ERROR_JSON : OK');
      }
      Test.stopTest();
      SMC_DTO_DORA resultTest = (SMC_DTO_DORA) JSON.deserialize(
        returnStrDora,
        SMC_DTO_DORA.class
      );
      System.assertEquals(null, resultTest.getAccounts.data);
    }
  }

  @isTest
  public static void testCacheNewOrder(){
    Profile profileStandard = [
      SELECT Id
      FROM Profile
      WHERE Name = :STA_UtilsStatic.PROFILE_SALE_STANDARD
    ];
    User userStandard = SMC_UTIL_TestUtils.createUser(
      'standardBis' + STA_UtilsStatic.USERNAME_TEST,
      'standardBis' + STA_UtilsStatic.USERNAME_TEST,
      profileStandard.Id,
      'standardBis' + STA_UtilsStatic.USERNAME_TEST,
      'standardBis' + STA_UtilsStatic.USERNAME_TEST
    );
    insert userStandard;

    System.runAs(userStandard) {
      String tmpCache = 'newOrderInCache';
      //Save in cache
      SMC_AC_DORA_Management.saveTemporaryOrderInCache(tmpCache);
      //Get cache infos
      System.assertEquals(tmpCache, SMC_AC_DORA_Management.getTemporaryOrderInCache(), 'Cache (NewOrder) is not retrieved.');
      //Reset cache
      SMC_AC_DORA_Management.clearTemporaryOrderInCache();
      //Get cache infos after reset
      System.assertEquals(null, SMC_AC_DORA_Management.getTemporaryOrderInCache(), 'Cache (NewOrder) is not reset.');
    }
  }

  @isTest
  public static void testCacheMyOrder(){
    Profile profileStandard = [
      SELECT Id
      FROM Profile
      WHERE Name = :STA_UtilsStatic.PROFILE_SALE_STANDARD
    ];
    User userStandard = SMC_UTIL_TestUtils.createUser(
      'standardBis' + STA_UtilsStatic.USERNAME_TEST,
      'standardBis' + STA_UtilsStatic.USERNAME_TEST,
      profileStandard.Id,
      'standardBis' + STA_UtilsStatic.USERNAME_TEST,
      'standardBis' + STA_UtilsStatic.USERNAME_TEST
    );
    insert userStandard;

    System.runAs(userStandard) {
      String tmpCache = 'newOrderInCache';
      //Save in cache
      SMC_AC_DORA_Management.saveTemporaryAccountInCache(tmpCache);
      //Get cache infos
      System.assertEquals(tmpCache, SMC_AC_DORA_Management.getTemporaryAccountInCache(), 'Cache (MyOrder) is not retrieved.');
    }
  }}