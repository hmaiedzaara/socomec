/**
 * @description       :
 * @author            : Vincent RECASENS (Modis)
 * @group             :
 * @last modified on  : 11-03-2020
 * @last modified by  : Vincent RECASENS (Modis)
 * Modifications Log
 * Ver   Date         Author                     Modification
 * 1.0   10-05-2020   Vincent RECASENS (Modis)   Initial Version
 **/
public without sharing class SMC_DTO_DORA {
  @AuraEnabled
  public String message;

  public SMC_DTO_DORA(){}

  public SMC_DTO_DORA(String message){
    this.message = message;
  }
  /* ITEM CODE - Used in HomePage (ProductAvaibility and OrderRequest)  and NewOrder (with CDCLI)*/
  public without sharing class SMC_DTO_Get_ItemCode {
    @AuraEnabled
    public Boolean error;
    @AuraEnabled
    public String message;
    @AuraEnabled
    public List<SMC_DTO_Get_ItemCode_Data> data;

    public SMC_DTO_Get_ItemCode() {
      this.data = new List<SMC_DTO_Get_ItemCode_Data>();
    }

    public SMC_DTO_Get_ItemCode(
      Boolean error,
      String message,
      List<SMC_DTO_Get_ItemCode_Data> data
    ) {
      this.error = error;
      this.message = message;
      this.data = data;
    }
  }

  public without sharing class SMC_DTO_Get_ItemCode_With_Quantity {
    @AuraEnabled
    public Boolean error;
    @AuraEnabled
    public String message;
    @AuraEnabled
    public SMC_DTO_Get_ItemCode_Data data;

    public SMC_DTO_Get_ItemCode_With_Quantity() {}

    public SMC_DTO_Get_ItemCode_With_Quantity(
      Boolean error,
      String message,
      SMC_DTO_Get_ItemCode_Data data
    ) {
      this.error = error;
      this.message = message;
      this.data = data;
    }
  }

  // public without sharing class SMC_DTO_Get_ItemCode_With_Quantity_AltPdt {
  //   @AuraEnabled
  //   public Boolean error;
  //   @AuraEnabled
  //   public String message;
  //   @AuraEnabled
  //   public List<SMC_DTO_Get_ItemCode_Data> data;

  //   public SMC_DTO_Get_ItemCode_With_Quantity_AltPdt() {
  //   }

  //   public SMC_DTO_Get_ItemCode_With_Quantity_AltPdt(
  //     Boolean error,
  //     String message,
  //     List<SMC_DTO_Get_ItemCode_Data> data
  //   ) {
  //     this.error = error;
  //     this.message = message;
  //     this.data = data;
  //   }
  // }

  public without sharing class SMC_DTO_Get_ItemCode_Data {
    @AuraEnabled
    public String CDPAR;
    @AuraEnabled
    public String CDSPS;
    @AuraEnabled
    public String DESCRIPTION;
    @AuraEnabled
    public String AVAILABLEDATE;
    @AuraEnabled
    public String receivedAvailableDate;
    @AuraEnabled
    public String REQUESTEDDATE;
    @AuraEnabled
    public Integer QUANTITY = 1;
    @AuraEnabled
    public String CCY; //CURRENCY
    @AuraEnabled
    public Decimal GROSSPRICE; //Price without discount
    @AuraEnabled
    public Decimal price; //Price without discount
    @AuraEnabled
    public Decimal NETPRICE;
    @AuraEnabled
    public List<SMC_DTO_Get_ItemCode_Data> alternatives;
    @AuraEnabled
    public List<SMC_DTO_NotAvailableLabel> productLabelNotAvailable;
    @AuraEnabled
    public Decimal discountpercent;
    @AuraEnabled
    public Integer linenumber;
    @AuraEnabled
    public Boolean netPriceFilledInWS;
    @AuraEnabled
    public Boolean isProduct;
    @AuraEnabled
    public Boolean isTransport;
    @AuraEnabled
    public Boolean isCommissioning;
    @AuraEnabled
    public Boolean isTotal;

    public SMC_DTO_Get_ItemCode_Data() {
      this.alternatives = new List<SMC_DTO_Get_ItemCode_Data>();
      this.productLabelNotAvailable = new List<SMC_DTO_NotAvailableLabel>();
      this.isProduct = true;
      this.isTransport = false;
      this.isCommissioning = false;
      this.isTotal = false;
    }

    public SMC_DTO_Get_ItemCode_Data(
      String CDPAR,
      String DESCRIPTION,
      String AVAILABLEDATE,
      String CCY,
      Decimal GROSSPRICE
    ) {
      this.alternatives = new List<SMC_DTO_Get_ItemCode_Data>();
      this.productLabelNotAvailable = new List<SMC_DTO_NotAvailableLabel>();
      this.CDPAR = CDPAR;
      this.DESCRIPTION = DESCRIPTION;
      this.AVAILABLEDATE = AVAILABLEDATE;
      this.CCY = CCY;
      this.GROSSPRICE = GROSSPRICE;
      this.netPriceFilledInWS = false;
      this.isProduct = true;
      this.isTransport = false;
      this.isCommissioning = false;
      this.isTotal = false;
    }
  }

  public without sharing class SMC_DTO_NotAvailableLabel{
    @AuraEnabled
    public String value;
    @AuraEnabled
    public String label;

    public SMC_DTO_NotAvailableLabel() {}

    public SMC_DTO_NotAvailableLabel(String value, String label) {
      this.value = value;
      this.label = label;
    }
  }

  /* ACCOUNT - Used to find the account list (New Order) */
  public without sharing class SMC_DTO_Get_Accounts {
    @AuraEnabled
    public Boolean error;
    @AuraEnabled
    public String message;
    @AuraEnabled
    public List<SMC_DTO_Get_Account_Data> data;

    public SMC_DTO_Get_Accounts() {
      this.data = new List<SMC_DTO_Get_Account_Data>();
    }

    public SMC_DTO_Get_Accounts(
      Boolean error,
      String message,
      List<SMC_DTO_Get_Account_Data> data
    ) {
      this.error = error;
      this.message = message;
      this.data = data;
    }
  }

  /* ACCOUNT - Used to find the specific account (New Order) */
  public without sharing class SMC_DTO_Get_SpecificAccount {
    @AuraEnabled
    public Boolean error;
    @AuraEnabled
    public String message;
    @AuraEnabled
    public SMC_DTO_Get_Account_Data data;

    public SMC_DTO_Get_SpecificAccount() {
    }

    public SMC_DTO_Get_SpecificAccount(
      Boolean error,
      String message,
      SMC_DTO_Get_Account_Data data
    ) {
      this.error = error;
      this.message = message;
      this.data = data;
    }
  }

  public without sharing class SMC_DTO_Get_Account_Data {
    @AuraEnabled
    public String CDCLI; //Code client
    @AuraEnabled
    public String COMPANYNAME;
    @AuraEnabled
    public String PIVA;
    @AuraEnabled
    public String CCY;
    @AuraEnabled
    public List<SMC_DTO_Get_Account_Data_Address> addresses;

    public SMC_DTO_Get_Account_Data() {
      this.addresses = new List<SMC_DTO_Get_Account_Data_Address>();
    }

    public SMC_DTO_Get_Account_Data(
      String CDCLI,
      String COMPANYNAME,
      String PIVA,
      List<SMC_DTO_Get_Account_Data_Address> addresses
    ) {
      this.CDCLI = CDCLI;
      this.COMPANYNAME = COMPANYNAME;
      this.PIVA = PIVA;
      this.addresses = addresses;
    }
  }

  public without sharing class SMC_DTO_Get_Account_Data_Address {
    @AuraEnabled
    public String ADDRESSCODE;
    @AuraEnabled
    public String COMPANYNAME;
    @AuraEnabled
    public String ADDRESS;
    @AuraEnabled
    public String CITY;
    @AuraEnabled
    public String ZIPCODE;
    @AuraEnabled
    public String PROV;
    @AuraEnabled
    public String COUNTRY;
    @AuraEnabled
    public String concatAddress;
    @AuraEnabled
    public List<String> formattedAddress;

    public SMC_DTO_Get_Account_Data_Address() {
    }

    public SMC_DTO_Get_Account_Data_Address(
      String ADDRESSCODE,
      String COMPANYNAME,
      String ADDRESS,
      String CITY,
      String ZIPCODE,
      String PROV,
      String COUNTRY
    ) {
      this.ADDRESSCODE = ADDRESSCODE;
      this.COMPANYNAME = COMPANYNAME;
      this.ADDRESS = ADDRESS;
      this.CITY = CITY;
      this.ZIPCODE = ZIPCODE;
      this.PROV = PROV;
      this.COUNTRY = COUNTRY;
      this.concatAddress =
        this.COMPANYNAME +
        ';' +
        this.ADDRESS +
        ', ' +
        this.ZIPCODE +
        ' ' +
        this.CITY +
        ';' +
        this.PROV +
        ' ' +
        this.COUNTRY;
      this.formattedAddress = this.concatAddress.split(';');
    }

    // public Integer compareTo(Object compareTo) {
    //   SMC_DTO_ML_Document compareToGoal = (SMC_DTO_ML_Document) compareTo;

    //   // The return value of 0 indicates that both elements are equal.
    //   Integer returnValue = 0;

    //   if (this.concatAddress > compareToGoal.concatAddress) {
    //     return 1;
    //   } else if (this.concatAddress < compareToGoal.concatAddress) {
    //     return -1;
    //   }

    //   return returnValue;
    // }
  }

  /* ORDER - Used to retrieve all orders for an account (MyOrder) */
  public without sharing class SMC_DTO_Get_Order {
    @AuraEnabled
    public Boolean error;
    @AuraEnabled
    public String message;
    @AuraEnabled
    public List<SMC_DTO_Get_Order_Data> data;

    public SMC_DTO_Get_Order() {
      this.data = new List<SMC_DTO_Get_Order_Data>();
    }

    public SMC_DTO_Get_Order(
      Boolean error,
      String message,
      List<SMC_DTO_Get_Order_Data> data
    ) {
      this.error = error;
      this.message = message;
      this.data = data;
    }
  }

  /* ORDER ROWS - Used to retrieve an order*/
  public without sharing class SMC_DTO_Get_Order_Rows {
    @AuraEnabled
    public Boolean error;
    @AuraEnabled
    public String message;
    @AuraEnabled
    public SMC_DTO_Get_Order_Data data;

    public SMC_DTO_Get_Order_Rows() {
    }

    public SMC_DTO_Get_Order_Rows(
      Boolean error,
      String message,
      SMC_DTO_Get_Order_Data data
    ) {
      this.error = error;
      this.message = message;
      this.data = data;
    }
  }

  public without sharing class SMC_DTO_Get_Order_Data {
    @AuraEnabled
    public String CDORD; // Code order
    @AuraEnabled
    public String CDCLI; // Code client
    @AuraEnabled
    public String CONTACTNAME;
    @AuraEnabled
    public String CONTACTPHONE;
    @AuraEnabled
    public String CUSTREF;
    @AuraEnabled
    public String STATUS;
    @AuraEnabled
    public String ORDERDATE;
    @AuraEnabled
    public String PREFTIME;
    @AuraEnabled
    public String CCY; //CURRENCY
    @AuraEnabled
    public String AMOUNT;
    @AuraEnabled
    public Boolean TAILLIFT;
    @AuraEnabled
    public String NOTE;
    @AuraEnabled
    public SMC_DTO_Get_Account_Data_Address address;
    @AuraEnabled
    public List<SMC_DTO_Order_Data_Row> rows;
    @AuraEnabled
    public List<SMC_DTO_NotAvailableLabel> productLabelNotAvailable;

    public SMC_DTO_Get_Order_Data() {
      this.rows = new List<SMC_DTO_Order_Data_Row>();
      this.productLabelNotAvailable = new List<SMC_DTO_NotAvailableLabel>();
    }

    public SMC_DTO_Get_Order_Data(
      String CDORD,
      String CDCLI,
      String STATUS,
      String ORDERDATE,
      String CCY,
      String AMOUNT,
      SMC_DTO_Get_Account_Data_Address address,
      List<SMC_DTO_Order_Data_Row> rows
    ) {
      this.productLabelNotAvailable = new List<SMC_DTO_NotAvailableLabel>();
      this.CDORD = CDORD;
      this.CDCLI = CDCLI;
      this.STATUS = STATUS;
      this.ORDERDATE = ORDERDATE;
      this.CCY = CCY;
      this.AMOUNT = AMOUNT;
      this.address = address;
      this.rows = rows;
    }

    public SMC_DTO_Get_Order_Data(
      String CDORD,
      String CDCLI,
      String CUSTREF,
      String CONTACTNAME,
      String CONTACTPHONE,
      String STATUS,
      String ORDERDATE,
      String PREFTIME,
      String CCY,
      String AMOUNT,
      String TAILLIFT,
      String NOTE,
      SMC_DTO_Get_Account_Data_Address address,
      List<SMC_DTO_Order_Data_Row> rows
    ) {
      this.productLabelNotAvailable = new List<SMC_DTO_NotAvailableLabel>();
      this.CDORD = CDORD;
      this.CDCLI = CDCLI;
      this.CUSTREF = CUSTREF;
      this.CONTACTNAME = CONTACTNAME;
      this.CONTACTPHONE = CONTACTPHONE;
      this.STATUS = STATUS;
      this.ORDERDATE = ORDERDATE;
      this.PREFTIME = PREFTIME;
      this.CCY = CCY;
      this.AMOUNT = AMOUNT;
      this.TAILLIFT = (TAILLIFT == 'no' ? false : true);
      this.NOTE = NOTE;
      this.address = address;
      this.rows = rows;
    }
  }

  public without sharing class SMC_DTO_Order_Data_Row {
    @AuraEnabled
    public String LINENUMBER;
    @AuraEnabled
    public String CDPAR;
    @AuraEnabled
    public String CDSPS;
    @AuraEnabled
    public Integer QUANTITY;
    @AuraEnabled
    public String DELIVERYDATE;
    @AuraEnabled
    public Decimal UNITPRICE; //Net price
    @AuraEnabled
    public String COURIER;
    @AuraEnabled
    public String TRACKINGNUMBER;
    @AuraEnabled
    public List<SMC_DTO_NotAvailableLabel> productLabelNotAvailable;

    public SMC_DTO_Order_Data_Row() {
      this.productLabelNotAvailable = new List<SMC_DTO_NotAvailableLabel>();
    }

    public SMC_DTO_Order_Data_Row(
      String LINENUMBER,
      String CDPAR,
      String CDSPS,
      Integer QUANTITY,
      Decimal UNITPRICE,
      String DELIVERYDATE
    ) {
      this.productLabelNotAvailable = new List<SMC_DTO_NotAvailableLabel>();
      this.LINENUMBER = LINENUMBER;
      this.CDPAR = CDPAR;
      this.CDSPS = CDSPS;
      this.QUANTITY = QUANTITY;
      this.UNITPRICE = UNITPRICE;
      this.DELIVERYDATE = DELIVERYDATE;
    }

    public SMC_DTO_Order_Data_Row(
      String LINENUMBER,
      String CDPAR,
      String CDSPS,
      Integer QUANTITY,
      String DELIVERYDATE,
      Decimal UNITPRICE,
      String COURIER,
      String TRACKINGNUMBER
    ) {
      this.productLabelNotAvailable = new List<SMC_DTO_NotAvailableLabel>();
      this.LINENUMBER = LINENUMBER;
      this.CDPAR = CDPAR;
      this.CDSPS = CDSPS;
      this.QUANTITY = QUANTITY;
      this.DELIVERYDATE = DELIVERYDATE;
      this.UNITPRICE = UNITPRICE;
      this.COURIER = COURIER;
      this.TRACKINGNUMBER = TRACKINGNUMBER;
    }
  }

  /* ORDER ROWS - Used to retrieve an order*/
  public without sharing class SMC_DTO_Get_Order_ForGuest {
    @AuraEnabled
    public Boolean error;
    @AuraEnabled
    public String message;
    @AuraEnabled
    public SMC_DTO_Get_Order_Data_ForGuest data;
    @AuraEnabled
    public List<SMC_DTO_NotAvailableLabel> productLabelNotAvailable;

    public SMC_DTO_Get_Order_ForGuest() {
      this.productLabelNotAvailable = new List<SMC_DTO_NotAvailableLabel>();
    }

    public SMC_DTO_Get_Order_ForGuest(
      Boolean error,
      String message,
      SMC_DTO_Get_Order_Data_ForGuest data
    ) {
      this.productLabelNotAvailable = new List<SMC_DTO_NotAvailableLabel>();
      this.error = error;
      this.message = message;
      this.data = data;
    }
  }

  public without sharing class SMC_DTO_Get_Order_Data_ForGuest {
    @AuraEnabled
    public String CDORD; // Code order
    @AuraEnabled
    public String CDCLI; // Code client
    @AuraEnabled
    public String STATUS;
    @AuraEnabled
    public String ORDERDATE;
    @AuraEnabled
    public String CUSTREF;
    @AuraEnabled
    public String CCY; //CURRENCY
    @AuraEnabled
    public String AMOUNT;
    @AuraEnabled
    public SMC_DTO_Get_Account_Data_Address address;
    @AuraEnabled
    public List<SMC_DTO_Order_Data_Row_ForGuest> rows;

    public SMC_DTO_Get_Order_Data_ForGuest() {
      this.rows = new List<SMC_DTO_Order_Data_Row_ForGuest>();
    }
  }

  public without sharing class SMC_DTO_Order_Data_Row_ForGuest {
    @AuraEnabled
    public String LINENUMBER;
    @AuraEnabled
    public String CDPAR;
    @AuraEnabled
    public String CDSPS;
    @AuraEnabled
    public String QUANTITY;
    @AuraEnabled
    public String DELIVERYDATE;
    @AuraEnabled
    public String NETPRICE; //Net price
    @AuraEnabled
    public String COURIER;
    @AuraEnabled
    public String TRACKINGNUMBER;

    public SMC_DTO_Order_Data_Row_ForGuest() {
    }
  }

  /* ORDER - Used to upsert an order */
  public without sharing class SMC_DTO_Post_Order_BODY {
    @AuraEnabled
    public String APIKEY;
    @AuraEnabled
    public String USERMAIL;
    @AuraEnabled
    public String CDORD;
    @AuraEnabled
    public String CDCLI;
    @AuraEnabled
    public String CUSTREF;
    @AuraEnabled
    public String CONTACTNAME;
    @AuraEnabled
    public String CONTACTPHONE;
    @AuraEnabled
    public String EXPECTEDDATE;
    @AuraEnabled
    public String PREFTIME;
    @AuraEnabled
    public String ADDRESSCODE;
    @AuraEnabled
    public String TAILLIFT;
    @AuraEnabled
    public String NOTE;
    @AuraEnabled
    public String SECRET;
    @AuraEnabled
    public List<SMC_DTO_Order_Data_Row> rows;

    public SMC_DTO_Post_Order_BODY() {
      this.rows = new List<SMC_DTO_Order_Data_Row>();
    }

    public SMC_DTO_Post_Order_BODY(
      String APIKEY,
      String USERMAIL,
      String CDORD,
      String CDCLI,
      String ADDRESSCODE,
      String SECRET,
      String CUSTREF,
      List<SMC_DTO_Order_Data_Row> rows
    ) {
      this.APIKEY = APIKEY;
      this.USERMAIL = USERMAIL;
      this.CDORD = CDORD;
      this.CDCLI = CDCLI;
      this.ADDRESSCODE = ADDRESSCODE;
      this.SECRET = SECRET;
      this.CUSTREF = CUSTREF;
      this.rows = rows;
    }

    public SMC_DTO_Post_Order_BODY(
      String APIKEY,
      String USERMAIL,
      String CDORD,
      String CDCLI,
      String CUSTREF,
      String CONTACTNAME,
      String CONTACTPHONE,
      String EXPECTEDDATE,
      String PREFTIME,
      String ADDRESSCODE,
      String TAILLIFT,
      String NOTE,
      String SECRET,
      List<SMC_DTO_Order_Data_Row> rows
    ) {
      this.APIKEY = APIKEY;
      this.USERMAIL = USERMAIL;
      this.CDORD = CDORD;
      this.CDCLI = CDCLI;
      this.CUSTREF = CUSTREF;
      this.CONTACTNAME = CONTACTNAME;
      this.CONTACTPHONE = CONTACTPHONE;
      this.EXPECTEDDATE = EXPECTEDDATE;
      this.PREFTIME = PREFTIME;
      this.ADDRESSCODE = ADDRESSCODE;
      this.TAILLIFT = TAILLIFT;
      this.NOTE = NOTE;
      this.SECRET = SECRET;
      this.rows = rows;
    }
  }

  /* ORDER - Used to upsert an order */
  public without sharing class SMC_DTO_Post_Order_BODY_NewAddress {
    @AuraEnabled
    public String APIKEY;
    @AuraEnabled
    public String USERMAIL;
    @AuraEnabled
    public String CDORD;
    @AuraEnabled
    public String CDCLI;
    @AuraEnabled
    public String CUSTREF;
    @AuraEnabled
    public String CONTACTNAME;
    @AuraEnabled
    public String CONTACTPHONE;
    @AuraEnabled
    public String EXPECTEDDATE;
    @AuraEnabled
    public String PREFTIME;
    @AuraEnabled
    public String ADDRESSCODE;
    @AuraEnabled
    public SMC_DTO_Post_Order_NewAddress newaddress;
    @AuraEnabled
    public String TAILLIFT;
    @AuraEnabled
    public String NOTE;
    @AuraEnabled
    public String SECRET;
    @AuraEnabled
    public List<SMC_DTO_Order_Data_Row> rows;

    public SMC_DTO_Post_Order_BODY_NewAddress() {
      this.rows = new List<SMC_DTO_Order_Data_Row>();
    }

    public SMC_DTO_Post_Order_BODY_NewAddress(
      String APIKEY,
      String USERMAIL,
      String CDORD,
      String CDCLI,
      String CUSTREF,
      String CONTACTNAME,
      String CONTACTPHONE,
      String EXPECTEDDATE,
      String PREFTIME,
      String ADDRESSCODE,
      SMC_DTO_Post_Order_NewAddress newaddress,
      String TAILLIFT,
      String NOTE,
      String SECRET,
      List<SMC_DTO_Order_Data_Row> rows
    ) {
      this.APIKEY = APIKEY;
      this.USERMAIL = USERMAIL;
      this.CDORD = CDORD;
      this.CDCLI = CDCLI;
      this.CUSTREF = CUSTREF;
      this.CONTACTNAME = CONTACTNAME;
      this.CONTACTPHONE = CONTACTPHONE;
      this.EXPECTEDDATE = EXPECTEDDATE;
      this.PREFTIME = PREFTIME;
      this.ADDRESSCODE = ADDRESSCODE;
      this.newaddress = newaddress;
      this.TAILLIFT = TAILLIFT;
      this.NOTE = NOTE;
      this.SECRET = SECRET;
      this.rows = rows;
    }
  }

  public without sharing class SMC_DTO_Post_Order_NewAddress{
    @AuraEnabled
    public String COMPANYNAME;
    @AuraEnabled
    public String ADDRESS;
    @AuraEnabled
    public String CITY;
    @AuraEnabled
    public String ZIPCODE;
    @AuraEnabled
    public String PROV;
    @AuraEnabled
    public String COUNTRY;

    public SMC_DTO_Post_Order_NewAddress() {
    }

    public SMC_DTO_Post_Order_NewAddress(
      String COMPANYNAME,
      String ADDRESS,
      String CITY,
      String ZIPCODE,
      String PROV,
      String COUNTRY
    ) {
      this.COMPANYNAME = COMPANYNAME;
      this.ADDRESS = ADDRESS;
      this.CITY = CITY;
      this.ZIPCODE = ZIPCODE;
      this.PROV = PROV;
      this.COUNTRY = COUNTRY;
    }
  }

  /* USER - Used to manage users */
  public without sharing class SMC_DTO_Post_User {
    @AuraEnabled
    public String APIKEY;
    @AuraEnabled
    public String USERMAIL;
    @AuraEnabled
    public String FULLNAME;

    public SMC_DTO_Post_User() {
    }

    public SMC_DTO_Post_User(String APIKEY, String USERMAIL, String FULLNAME) {
      this.APIKEY = APIKEY;
      this.USERMAIL = USERMAIL;
      this.FULLNAME = FULLNAME;
    }
  }

  /* Generic POST result */
  public without sharing class SMC_DTO_Post_RESULT {
    @AuraEnabled
    public Boolean error;
    @AuraEnabled
    public String message;
    @AuraEnabled
    public String data;
    @AuraEnabled
    public String orderlink;

    public SMC_DTO_Post_RESULT() {
    }

    public SMC_DTO_Post_RESULT(Boolean error, String message) {
      this.error = error;
      this.message = message;
    }
  }

  public SMC_DTO_Get_ItemCode getItemCode = new SMC_DTO_Get_ItemCode();
  public SMC_DTO_Get_ItemCode_With_Quantity getItemCodeWQt = new SMC_DTO_Get_ItemCode_With_Quantity();
  // public SMC_DTO_Get_ItemCode_With_Quantity_AltPdt getItemCodeWQtAltPdt = new SMC_DTO_Get_ItemCode_With_Quantity_AltPdt();
  public SMC_DTO_Get_Accounts getAccounts = new SMC_DTO_Get_Accounts();
  public SMC_DTO_Get_SpecificAccount getSpecificAccount = new SMC_DTO_Get_SpecificAccount();
  public SMC_DTO_Get_Order getOrder = new SMC_DTO_Get_Order();
  public SMC_DTO_Get_Order_Rows getOrderRows = new SMC_DTO_Get_Order_Rows();
  public SMC_DTO_Get_Order_ForGuest getOrderForGuest = new SMC_DTO_Get_Order_ForGuest();
  public SMC_DTO_Post_Order_BODY getPostOrderBody = new SMC_DTO_Post_Order_BODY();
  public SMC_DTO_Post_User getPostNewUserBody = new SMC_DTO_Post_User();
  public SMC_DTO_Post_RESULT getPostResult = new SMC_DTO_Post_RESULT();
}