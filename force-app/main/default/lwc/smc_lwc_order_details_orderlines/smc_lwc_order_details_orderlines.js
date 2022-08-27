import { LightningElement, api, track } from "lwc";
import ORDER_LINES from "@salesforce/label/c.SMC_Order_Lines_CAP";
import LINE_NUMBER from "@salesforce/label/c.SMC_Line_Number";
import PRODUCT_CODE from "@salesforce/label/c.SMC_Product_Code";
import CARRIER from "@salesforce/label/c.SMC_Carrier";
import TRACKING_NUMBER from "@salesforce/label/c.SMC_Tracking_Number";
import DELIVERY_DATE from "@salesforce/label/c.SMC_DeliveryDate";
import UNIT_PRICE from "@salesforce/label/c.SMC_Unit_Price";
import QUANTITY from "@salesforce/label/c.SMC_Quantity";
import PRICE from "@salesforce/label/c.SMC_Price";
import DISCOUNT_PERCENT from "@salesforce/label/c.SMC_Discount_Percent";
import NET_PRICE from "@salesforce/label/c.SMC_Net_Price";
import ACTIONS from "@salesforce/label/c.SMC_Actions";
import TOTAL from "@salesforce/label/c.SMC_Total";

export default class Smc_lwc_order_details_orderlines extends LightningElement {
  @api orderlines;
  @api productlabelnotavailable;
  @api fordetails;

  @track orderLinesToShow = [];
  @track total;
  @track ccy;

  //Label
  orderLinesLabel = { ORDER_LINES };
  lineNumberLabel = { LINE_NUMBER };
  productCodeLabel = { PRODUCT_CODE };
  carrierLabel = { CARRIER };
  trackingNumberLabel = { TRACKING_NUMBER };
  deliveryDateLabel = { DELIVERY_DATE };
  unitPriceLabel = { UNIT_PRICE };
  quantityLabel = { QUANTITY };
  priceLabel = { PRICE };
  discountPercentLabel = { DISCOUNT_PERCENT };
  netPriceLabel = { NET_PRICE };
  actionsLabel = { ACTIONS };
  totalLabel = { TOTAL };

  connectedCallback() {
    let tmpOrderLines = JSON.parse(JSON.stringify(this.orderlines));
    let tmpTotal = 0;
    for (let key in tmpOrderLines) {
      //Set CDPAR / CDSPS
      if (
        tmpOrderLines[key].CDPAR === undefined ||
        tmpOrderLines[key].CDPAR === null ||
        tmpOrderLines[key].CDPAR === ""
      ) {
        tmpOrderLines[key].CDPAR = tmpOrderLines[key].CDSPS;
      }
      tmpOrderLines[key].GROSSPRICE = tmpOrderLines[key].UNITPRICE;
      tmpOrderLines[key].UNITPRICE =
        tmpOrderLines[key].UNITPRICE * tmpOrderLines[key].QUANTITY;
      tmpTotal += tmpOrderLines[key].UNITPRICE;
      //Set TrackingNumber if blank
      if (
        (tmpOrderLines[key].TRACKINGNUMBER === null ||
          tmpOrderLines[key].TRACKINGNUMBER === undefined ||
          tmpOrderLines[key].TRACKINGNUMBER === "") &&
        tmpOrderLines[key].COURIER !== null &&
        tmpOrderLines[key].COURIER !== undefined &&
        tmpOrderLines[key].COURIER !== ""
      ) {
        tmpOrderLines[key].TRACKINGNUMBER = "Not yet available";
      }
      //Set date if not available
      for(let keyBis in this.productlabelnotavailable){
        if(this.productlabelnotavailable[keyBis].value === tmpOrderLines[key].DELIVERYDATE){
          tmpOrderLines[key].DELIVERYDATE = this.productlabelnotavailable[keyBis].label;
          break;
        }
      }
    }
    this.orderLinesToShow = tmpOrderLines;
    this.total = tmpTotal;
    this.ccy = tmpOrderLines[0].CCY;
  }

  /* Set background */
  get checkBackground() {
    ++this.idxBackground;
    if (!Number.isInteger(this.idxBackground / 2)) {
      return "slds-border_bottom ligth-background";
    } else {
      return "slds-border_bottom alternative-ligth-background";
    }
  }
}