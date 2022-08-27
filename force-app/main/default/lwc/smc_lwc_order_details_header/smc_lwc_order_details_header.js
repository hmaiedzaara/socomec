import { LightningElement, api } from "lwc";
import ORDER_HEADER from "@salesforce/label/c.SMC_Order_Header";
import SOCOMEC_REF from "@salesforce/label/c.SMC_Socomec_Refrence";
import ORDER_DATE from "@salesforce/label/c.SMC_Order_Date";
import ORDER_STATUS from "@salesforce/label/c.SMC_Order_Status";
import ACCOUNT from "@salesforce/label/c.SMC_Account";
import CUSTOMER_REF from "@salesforce/label/c.SMC_Customer_Reference";
import DELIVERY_ADDRESS from "@salesforce/label/c.SMC_Delivery_Address";
import STREET from "@salesforce/label/c.SMC_Street";
import CITY from "@salesforce/label/c.SMC_City";
import ZIP_POSTAL_CODE from "@salesforce/label/c.SMC_Zip_Postal_Code";
import STATE_PROV from "@salesforce/label/c.SMC_State_Province";
import COUNTRY from "@salesforce/label/c.SMC_Country";

export default class Smc_lwc_order_details_header extends LightningElement {
  @api order;

  orderHeaderLabel = { ORDER_HEADER };
  socomecRefLabel = { SOCOMEC_REF };
  orderDateLabel = { ORDER_DATE };
  orderStatusLabel = { ORDER_STATUS };
  accountLabel = { ACCOUNT };
  customerRefLabel = { CUSTOMER_REF };
  deliveryAddressLabel = { DELIVERY_ADDRESS };
  streetLabel = { STREET };
  cityLabel = { CITY };
  zipPostalCodeLabel = { ZIP_POSTAL_CODE };
  stateProvLabel = { STATE_PROV };
  countryLabel = { COUNTRY };
}