/**
 * @description       :
 * @author            : Vincent RECASENS (Modis)
 * @group             :
 * @last modified on  : 11-04-2020
 * @last modified by  : Vincent RECASENS (Modis)
 * Modifications Log
 * Ver   Date         Author                     Modification
 * 1.0   10-05-2020   Vincent RECASENS (Modis)   Initial Version
 **/
global class SMC_UTIL_DORA_Mock implements HttpCalloutMock {
  public String mock;
  public Integer statusCode = 200;

  global SMC_UTIL_DORA_Mock() {
  }
  global SMC_UTIL_DORA_Mock(String mock) {
    this.mock = mock;
  }
  global SMC_UTIL_DORA_Mock(String mock, Integer statusCode) {
    this.mock = mock;
    this.statusCode = statusCode;
  }

  global HTTPResponse respond(HTTPRequest req) {
    // Create a fake response
    HttpResponse res = new HttpResponse();
    res.setHeader(
      STA_UtilsStatic.CONTENT_TYPE,
      STA_UtilsStatic.APPLICATION_JSON
    );
    if (mock == 'MOCK_POST_RESULT_OK') {
      res.setBody(JSON.serialize(getMock(mock).getPostResult));
    } else if (mock == 'MOCK_GET_ACCOUNTS_SP_OK') {
      res.setBody(JSON.serialize(getMock(mock).getSpecificAccount));
    } else {
      res.setBody(JSON.serialize(getMock(mock)));
    }
    res.setStatusCode(this.statusCode);
    return res;
  }

  //Commons errors
  private static Boolean IN_ERROR = true;
  private static Boolean NOT_IN_ERROR = false;
  private static String ERROR_MESSAGE_EMPTY = '';
  private static String ERROR_MESSAGE_UNAUTHORIZED = 'Unauthorized';

  //Commons attributes
  private static String APIKEYUSER = '42ce6874-63a2-4d76-8cf3-c1a953fdd83f';
  private static String MOCK_CCY = 'EUR'; //Currency
  private static String MOCK_STATUS_CONFIRMED = 'Confirmed';
  private static String MOCK_COURIER = 'DHL';

  //User
  private static String MOCK_USERNAME = 'username@email.com';
  private static String MOCK_FULLNAME = 'Username MOCK';
  private static String MOCK_USERNAME_NEW = 'username.new@email.com';
  private static String MOCK_FULLNAME_NEW = 'Username MOCK NEW';

  //Data 1
  private static String MOCK_CDCLI_1 = 'CLI123456';
  private static String MOCK_CDPAR_1 = 'ITYSxxx';
  private static String MOCK_CDSPS_1 = 'MIS';
  private static String MOCK_CUSTREF_1 = 'IT12313';
  private static String MOCK_DESCRIPTION_1 = 'UPS ITYSxxx';
  private static String MOCK_COMPANYNAME_1 = 'COROMATIC';
  private static String MOCK_COMPANYNAME_UNDER_1 = 'COROMATIC SA';
  private static String MOCK_ADDRESSCODE_1 = 'AD123456';
  private static String MOCK_ADDRESS_1 = 'RUE DE LA RESISTANCE';
  private static String MOCK_CITY_1 = 'PARIS';
  private static String MOCK_ZIPCODE_1 = '75100';
  private static String MOCK_PROV_1 = 'PS';
  private static String MOCK_COUNTRY_1 = 'FRANCE';
  private static String MOCK_CDORD_1 = '987654';
  private static String MOCK_ORDERDATE_1 = '2020-10-01';
  private static Decimal MOCK_AMOUNT_1 = 5001.98;
  private static String MOCK_LINENUMBER_1 = '3';
  private static String MOCK_DELIVERYDATE_1 = '2020-11-05';
  private static Decimal MOCK_UNITPRICE_1 = 1510.83;
  private static Integer MOCK_QUANTITY_1 = 1;
  private static String MOCK_TRACKINGNUMBER_1 = '1541239556';
  private static SMC_DTO_DORA.SMC_DTO_Get_Account_Data_Address MOCK_FULL_ADDRESS_1 = new SMC_DTO_DORA.SMC_DTO_Get_Account_Data_Address(
    MOCK_COMPANYNAME_UNDER_1,
    MOCK_ADDRESSCODE_1,
    MOCK_ADDRESS_1,
    MOCK_CITY_1,
    MOCK_ZIPCODE_1,
    MOCK_PROV_1,
    MOCK_COUNTRY_1
  );
  private static String MOCK_SECRET_1 = EncodingUtil.convertToHex(
    Crypto.generateDigest(
      STA_UtilsStatic.SHA512,
      Blob.valueOf(MOCK_CDCLI_1 + MOCK_USERNAME)
    )
  );
  //Data 2
  private static String MOCK_CDCLI_2 = 'CLI456789';
  private static String MOCK_CDPAR_2 = 'ITYSxxxBIS';
  private static String MOCK_CDSPS_2 = 'MISB';
  private static String MOCK_CUSTREF_2 = 'IT65413';
  private static String MOCK_DESCRIPTION_2 = 'UPS ITYSxxx BIS';
  private static String MOCK_COMPANYNAME_2 = 'UTU ENGINEERING';
  private static String MOCK_COMPANYNAME_UNDER_2 = 'UTU ENGINEERING SA';
  private static String MOCK_ADDRESSCODE_2 = 'AD456789';
  private static String MOCK_ADDRESS_2 = 'RUE DE LA VICTOIRE';
  private static String MOCK_CITY_2 = 'TOULOUSE';
  private static String MOCK_ZIPCODE_2 = '31000';
  private static String MOCK_PROV_2 = 'TLS';
  private static String MOCK_COUNTRY_2 = 'FRANCE';
  private static String MOCK_CDORD_2 = '654321';
  private static String MOCK_ORDERDATE_2 = '2020-09-10';
  private static Decimal MOCK_AMOUNT_2 = 1507.13;
  private static String MOCK_LINENUMBER_2 = '6';
  private static String MOCK_DELIVERYDATE_2 = '2020-10-15';
  private static Decimal MOCK_UNITPRICE_2 = 1000.05;
  private static Integer MOCK_QUANTITY_2 = 3;
  private static String MOCK_TRACKINGNUMBER_2 = '546734194589';
  private static SMC_DTO_DORA.SMC_DTO_Get_Account_Data_Address MOCK_FULL_ADDRESS_2 = new SMC_DTO_DORA.SMC_DTO_Get_Account_Data_Address(
    MOCK_COMPANYNAME_UNDER_2,
    MOCK_ADDRESSCODE_2,
    MOCK_ADDRESS_2,
    MOCK_CITY_2,
    MOCK_ZIPCODE_2,
    MOCK_PROV_2,
    MOCK_COUNTRY_2
  );
  private static String MOCK_SECRET_2 = EncodingUtil.convertToHex(
    Crypto.generateDigest(
      STA_UtilsStatic.SHA512,
      Blob.valueOf(MOCK_CDCLI_2 + MOCK_USERNAME)
    )
  );

  //GET ITEM CODE
  @TestVisible
  private static SMC_DTO_DORA.SMC_DTO_Get_ItemCode MOCK_GET_ITEM_CODE_OK = new SMC_DTO_DORA.SMC_DTO_Get_ItemCode(
    NOT_IN_ERROR,
    ERROR_MESSAGE_EMPTY,
    new List<SMC_DTO_DORA.SMC_DTO_Get_ItemCode_Data>{
      new SMC_DTO_DORA.SMC_DTO_Get_ItemCode_Data(
        MOCK_CDPAR_1,
        MOCK_DESCRIPTION_1,
        '2020-09-30',
        'EUR',
        MOCK_UNITPRICE_1
      ) /*,
      new SMC_DTO_DORA.SMC_DTO_Get_ItemCode_Data(
        MOCK_CDPAR_2,
        MOCK_DESCRIPTION_2,
        null,
        null,
        null
      )*/
    }
  );
  @TestVisible
  private static SMC_DTO_DORA.SMC_DTO_Get_ItemCode MOCK_GET_ITEM_CODE_BAD = new SMC_DTO_DORA.SMC_DTO_Get_ItemCode(
    IN_ERROR,
    ERROR_MESSAGE_UNAUTHORIZED,
    null
  );

  //GET ITEM CODE (With Quantity)
  @TestVisible
  private static SMC_DTO_DORA.SMC_DTO_Get_ItemCode_With_Quantity MOCK_GET_ITEM_CODE_W_QT_OK = new SMC_DTO_DORA.SMC_DTO_Get_ItemCode_With_Quantity(
    NOT_IN_ERROR,
    ERROR_MESSAGE_EMPTY,
    new SMC_DTO_DORA.SMC_DTO_Get_ItemCode_Data(
      MOCK_CDPAR_1,
      MOCK_DESCRIPTION_1,
      '2020-09-30',
      'EUR',
      MOCK_UNITPRICE_1
    )
  );

  //GET ITEM CODE ALT PDT (With Quantity)
  // @TestVisible
  // private static SMC_DTO_DORA.SMC_DTO_Get_ItemCode_With_Quantity_AltPdt MOCK_GET_ITEM_CODE_W_QT_ALTPDT_OK = new SMC_DTO_DORA.SMC_DTO_Get_ItemCode_With_Quantity_AltPdt(
  //   NOT_IN_ERROR,
  //   ERROR_MESSAGE_EMPTY,
  //   new List<SMC_DTO_DORA.SMC_DTO_Get_ItemCode_Data>{
  //     new SMC_DTO_DORA.SMC_DTO_Get_ItemCode_Data(
  //       MOCK_CDPAR_1,
  //       MOCK_DESCRIPTION_1,
  //       '2020-09-30',
  //       'EUR',
  //       MOCK_UNITPRICE_1
  //     )
  //   }
  // );
  @TestVisible
  private static SMC_DTO_DORA.SMC_DTO_Get_ItemCode_With_Quantity MOCK_GET_ITEM_CODE_W_QT_BAD = new SMC_DTO_DORA.SMC_DTO_Get_ItemCode_With_Quantity(
    IN_ERROR,
    ERROR_MESSAGE_UNAUTHORIZED,
    null
  );

  //GET ACCOUNT
  @TestVisible
  private static SMC_DTO_DORA.SMC_DTO_Get_Accounts MOCK_GET_ACCOUNTS_OK = new SMC_DTO_DORA.SMC_DTO_Get_Accounts(
    NOT_IN_ERROR,
    ERROR_MESSAGE_EMPTY,
    new List<SMC_DTO_DORA.SMC_DTO_Get_Account_Data>{
      new SMC_DTO_DORA.SMC_DTO_Get_Account_Data(
        MOCK_CDCLI_1,
        MOCK_COMPANYNAME_1,
        'test',
        new List<SMC_DTO_DORA.SMC_DTO_Get_Account_Data_Address>{
          MOCK_FULL_ADDRESS_1,
          MOCK_FULL_ADDRESS_2
        }
      ),
      new SMC_DTO_DORA.SMC_DTO_Get_Account_Data(
        MOCK_CDCLI_2,
        MOCK_COMPANYNAME_2,
        'test 2',
        new List<SMC_DTO_DORA.SMC_DTO_Get_Account_Data_Address>{
          MOCK_FULL_ADDRESS_1,
          MOCK_FULL_ADDRESS_2
        }
      )
    }
  );
  @TestVisible
  private static SMC_DTO_DORA.SMC_DTO_Get_Accounts MOCK_GET_ACCOUNTS_BAD = new SMC_DTO_DORA.SMC_DTO_Get_Accounts(
    IN_ERROR,
    ERROR_MESSAGE_UNAUTHORIZED,
    null
  );

  //GET ACCOUNT (specific)
  @TestVisible
  private static SMC_DTO_DORA.SMC_DTO_Get_SpecificAccount MOCK_GET_ACCOUNTS_SP_OK = new SMC_DTO_DORA.SMC_DTO_Get_SpecificAccount(
    NOT_IN_ERROR,
    ERROR_MESSAGE_EMPTY,
    new SMC_DTO_DORA.SMC_DTO_Get_Account_Data(
      MOCK_CDCLI_1,
      MOCK_COMPANYNAME_1,
      'test',
      new List<SMC_DTO_DORA.SMC_DTO_Get_Account_Data_Address>{
        MOCK_FULL_ADDRESS_1,
        MOCK_FULL_ADDRESS_2
      }
    )
  );
  @TestVisible
  private static SMC_DTO_DORA.SMC_DTO_Get_SpecificAccount MOCK_GET_ACCOUNTS_SP_BAD = new SMC_DTO_DORA.SMC_DTO_Get_SpecificAccount(
    IN_ERROR,
    ERROR_MESSAGE_UNAUTHORIZED,
    null
  );

  //GET ORDER Headers
  @TestVisible
  private static SMC_DTO_DORA.SMC_DTO_Get_Order MOCK_GET_ORDER_HEADERS_OK = new SMC_DTO_DORA.SMC_DTO_Get_Order(
    NOT_IN_ERROR,
    ERROR_MESSAGE_EMPTY,
    new List<SMC_DTO_DORA.SMC_DTO_Get_Order_Data>{
      new SMC_DTO_DORA.SMC_DTO_Get_Order_Data(
        MOCK_CDORD_1,
        null,
        MOCK_STATUS_CONFIRMED,
        MOCK_ORDERDATE_1,
        MOCK_CCY,
        String.valueOf(MOCK_AMOUNT_1),
        null,
        null
      ),
      new SMC_DTO_DORA.SMC_DTO_Get_Order_Data(
        MOCK_CDORD_2,
        null,
        MOCK_STATUS_CONFIRMED,
        MOCK_ORDERDATE_2,
        MOCK_CCY,
        String.valueOf(MOCK_AMOUNT_2),
        null,
        null
      )
    }
  );
  @TestVisible
  private static SMC_DTO_DORA.SMC_DTO_Get_Order MOCK_GET_ORDER_BAD = new SMC_DTO_DORA.SMC_DTO_Get_Order(
    IN_ERROR,
    ERROR_MESSAGE_UNAUTHORIZED,
    null
  );

  //GET ORDER Rows
  @TestVisible
  private static SMC_DTO_DORA.SMC_DTO_Get_Order MOCK_GET_ORDER_ROWS_OK = new SMC_DTO_DORA.SMC_DTO_Get_Order(
    NOT_IN_ERROR,
    ERROR_MESSAGE_EMPTY,
    new List<SMC_DTO_DORA.SMC_DTO_Get_Order_Data>{
      new SMC_DTO_DORA.SMC_DTO_Get_Order_Data(
        MOCK_CDORD_1,
        null,
        MOCK_STATUS_CONFIRMED,
        MOCK_ORDERDATE_1,
        MOCK_CCY,
        String.valueOf(MOCK_AMOUNT_1),
        MOCK_FULL_ADDRESS_1,
        new List<SMC_DTO_DORA.SMC_DTO_Order_Data_Row>{
          new SMC_DTO_DORA.SMC_DTO_Order_Data_Row(
            MOCK_LINENUMBER_1,
            MOCK_CDPAR_1,
            MOCK_CDSPS_1,
            MOCK_QUANTITY_1,
            MOCK_DELIVERYDATE_1,
            MOCK_UNITPRICE_1,
            MOCK_COURIER,
            MOCK_TRACKINGNUMBER_1
          ),
          new SMC_DTO_DORA.SMC_DTO_Order_Data_Row(
            MOCK_LINENUMBER_2,
            MOCK_CDPAR_2,
            MOCK_CDSPS_2,
            MOCK_QUANTITY_2,
            MOCK_DELIVERYDATE_2,
            MOCK_UNITPRICE_2,
            MOCK_COURIER,
            MOCK_TRACKINGNUMBER_2
          )
        }
      ),
      new SMC_DTO_DORA.SMC_DTO_Get_Order_Data(
        MOCK_CDORD_2,
        null,
        MOCK_STATUS_CONFIRMED,
        MOCK_ORDERDATE_2,
        MOCK_CCY,
        String.valueOf(MOCK_AMOUNT_2),
        MOCK_FULL_ADDRESS_2,
        new List<SMC_DTO_DORA.SMC_DTO_Order_Data_Row>{
          new SMC_DTO_DORA.SMC_DTO_Order_Data_Row(
            MOCK_LINENUMBER_2,
            MOCK_CDPAR_2,
            MOCK_CDSPS_2,
            MOCK_QUANTITY_2,
            MOCK_DELIVERYDATE_2,
            MOCK_UNITPRICE_2,
            MOCK_COURIER,
            MOCK_TRACKINGNUMBER_2
          ),
          new SMC_DTO_DORA.SMC_DTO_Order_Data_Row(
            MOCK_LINENUMBER_1,
            MOCK_CDPAR_1,
            MOCK_CDSPS_1,
            MOCK_QUANTITY_1,
            MOCK_DELIVERYDATE_1,
            MOCK_UNITPRICE_1,
            MOCK_COURIER,
            MOCK_TRACKINGNUMBER_1
          )
        }
      )
    }
  );

  //GET ORDER Guest user
  @TestVisible
  private static SMC_DTO_DORA.SMC_DTO_Get_Order MOCK_GET_ORDER_GU_OK = new SMC_DTO_DORA.SMC_DTO_Get_Order(
    NOT_IN_ERROR,
    ERROR_MESSAGE_EMPTY,
    new List<SMC_DTO_DORA.SMC_DTO_Get_Order_Data>{
      new SMC_DTO_DORA.SMC_DTO_Get_Order_Data(
        MOCK_CDORD_2,
        MOCK_CDCLI_2,
        MOCK_STATUS_CONFIRMED,
        MOCK_ORDERDATE_2,
        MOCK_CCY,
        String.valueOf(MOCK_AMOUNT_2),
        MOCK_FULL_ADDRESS_2,
        new List<SMC_DTO_DORA.SMC_DTO_Order_Data_Row>{
          new SMC_DTO_DORA.SMC_DTO_Order_Data_Row(
            MOCK_LINENUMBER_2,
            MOCK_CDPAR_2,
            MOCK_CDSPS_2,
            MOCK_QUANTITY_2,
            MOCK_DELIVERYDATE_2,
            MOCK_UNITPRICE_2,
            MOCK_COURIER,
            MOCK_TRACKINGNUMBER_2
          ),
          new SMC_DTO_DORA.SMC_DTO_Order_Data_Row(
            MOCK_LINENUMBER_1,
            MOCK_CDPAR_1,
            MOCK_CDSPS_1,
            MOCK_QUANTITY_1,
            MOCK_DELIVERYDATE_1,
            MOCK_UNITPRICE_1,
            MOCK_COURIER,
            MOCK_TRACKINGNUMBER_1
          )
        }
      ),
      new SMC_DTO_DORA.SMC_DTO_Get_Order_Data(
        MOCK_CDORD_1,
        MOCK_CDCLI_1,
        MOCK_STATUS_CONFIRMED,
        MOCK_ORDERDATE_1,
        MOCK_CCY,
        String.valueOf(MOCK_AMOUNT_1),
        MOCK_FULL_ADDRESS_1,
        new List<SMC_DTO_DORA.SMC_DTO_Order_Data_Row>{
          new SMC_DTO_DORA.SMC_DTO_Order_Data_Row(
            MOCK_LINENUMBER_1,
            MOCK_CDPAR_1,
            MOCK_CDSPS_1,
            MOCK_QUANTITY_1,
            MOCK_DELIVERYDATE_1,
            MOCK_UNITPRICE_1,
            MOCK_COURIER,
            MOCK_TRACKINGNUMBER_1
          ),
          new SMC_DTO_DORA.SMC_DTO_Order_Data_Row(
            MOCK_LINENUMBER_2,
            MOCK_CDPAR_2,
            MOCK_CDSPS_2,
            MOCK_QUANTITY_2,
            MOCK_DELIVERYDATE_2,
            MOCK_UNITPRICE_2,
            MOCK_COURIER,
            MOCK_TRACKINGNUMBER_2
          )
        }
      )
    }
  );

  //POST ORDER
  @TestVisible
  private static SMC_DTO_DORA.SMC_DTO_Post_Order_BODY MOCK_POST_ORDER = new SMC_DTO_DORA.SMC_DTO_Post_Order_BODY(
    APIKEYUSER,
    MOCK_USERNAME,
    MOCK_CDORD_1,
    MOCK_CDCLI_1,
    MOCK_ADDRESSCODE_1,
    MOCK_SECRET_1,
    MOCK_CUSTREF_2,
    new List<SMC_DTO_DORA.SMC_DTO_Order_Data_Row>{
      new SMC_DTO_DORA.SMC_DTO_Order_Data_Row(
        MOCK_LINENUMBER_1,
        MOCK_CDPAR_1,
        MOCK_CDSPS_1,
        MOCK_QUANTITY_1,
        MOCK_DELIVERYDATE_1,
        MOCK_UNITPRICE_1,
        MOCK_COURIER,
        MOCK_TRACKINGNUMBER_1
      ),
      new SMC_DTO_DORA.SMC_DTO_Order_Data_Row(
        MOCK_LINENUMBER_2,
        MOCK_CDPAR_2,
        MOCK_CDSPS_2,
        MOCK_QUANTITY_2,
        MOCK_DELIVERYDATE_2,
        MOCK_UNITPRICE_2,
        MOCK_COURIER,
        MOCK_TRACKINGNUMBER_2
      )
    }
  );

  // //POST USER
  // @TestVisible
  // private static SMC_DTO_DORA.SMC_DTO_Post_User MOCK_POST_USER = new SMC_DTO_DORA.SMC_DTO_Post_User(
  //   APIKEYUSER,
  //   MOCK_USERNAME_NEW,
  //   MOCK_FULLNAME_NEW
  // );

  //POST RESULT
  @TestVisible
  private static SMC_DTO_DORA.SMC_DTO_Post_RESULT MOCK_POST_RESULT_OK = new SMC_DTO_DORA.SMC_DTO_Post_RESULT(
    NOT_IN_ERROR,
    ERROR_MESSAGE_EMPTY
  );
  @TestVisible
  private static SMC_DTO_DORA.SMC_DTO_Post_RESULT MOCK_POST_RESULT_BAD = new SMC_DTO_DORA.SMC_DTO_Post_RESULT(
    IN_ERROR,
    ERROR_MESSAGE_UNAUTHORIZED
  );

  /**
   * @description : serialize mock and return it
   * @author Vincent RECASENS (Modis) | 10-06-2020
   * @param mockName
   * @return String
   **/
  public SMC_DTO_DORA getMock(String mockName) {
    SMC_DTO_DORA mock = new SMC_DTO_DORA();
    switch on mockName {
      when 'MOCK_GET_ITEM_CODE_OK' {
        mock.getItemCode = MOCK_GET_ITEM_CODE_OK;
      }
      when 'MOCK_GET_ITEM_CODE_BAD' {
        mock.getItemCode = MOCK_GET_ITEM_CODE_BAD;
      }
      when 'MOCK_GET_ITEM_CODE_W_QT_OK' {
        mock.getItemCodeWQt = MOCK_GET_ITEM_CODE_W_QT_OK;
      }
      when 'MOCK_GET_ITEM_CODE_W_QT_BAD' {
        mock.getItemCodeWQt = MOCK_GET_ITEM_CODE_W_QT_BAD;
      }
      when 'MOCK_GET_ACCOUNTS_OK' {
        mock.getAccounts = MOCK_GET_ACCOUNTS_OK;
      }
      when 'MOCK_GET_ACCOUNTS_BAD' {
        mock.getAccounts = MOCK_GET_ACCOUNTS_BAD;
      }
      when 'MOCK_GET_ACCOUNTS_SP_OK' {
        mock.getSpecificAccount = MOCK_GET_ACCOUNTS_SP_OK;
      }
      when 'MOCK_GET_ACCOUNTS_SP_BAD' {
        mock.getSpecificAccount = MOCK_GET_ACCOUNTS_SP_BAD;
      }
      when 'MOCK_GET_ORDER_HEADERS_OK' {
        mock.getOrder = MOCK_GET_ORDER_HEADERS_OK;
      }
      when 'MOCK_GET_ORDER_ROWS_OK' {
        mock.getOrder = MOCK_GET_ORDER_ROWS_OK;
      }
      when 'MOCK_GET_ORDER_BAD' {
        mock.getOrder = MOCK_GET_ORDER_BAD;
      }
      when 'MOCK_GET_ORDER_GU_OK' {
        mock.getOrder = MOCK_GET_ORDER_GU_OK;
      }
      when 'MOCK_POST_ORDER' {
        mock.getPostOrderBody = MOCK_POST_ORDER;
      }
      // when 'MOCK_POST_USER' {
      //   mock.getPostNewUserBody = MOCK_POST_USER;
      // }
      when 'MOCK_POST_RESULT_OK' {
        mock.getPostResult = MOCK_POST_RESULT_OK;
      }
      when 'MOCK_POST_RESULT_BAD' {
        mock.getPostResult = MOCK_POST_RESULT_BAD;
      }
    }
    return mock;
  }
}