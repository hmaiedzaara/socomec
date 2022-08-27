import { LightningElement, track } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getOrderFromHP from "@salesforce/apex/SMC_AC_DORA_Management.getOrderGuestUser";
import ORDER_TRACKING from "@salesforce/label/c.SMC_Order_Tracking";
import ORDER_CODE from "@salesforce/label/c.SMC_Order_Code";
import ORDER_DATE from "@salesforce/label/c.SMC_Order_Date";
import ORDER_STATUS from "@salesforce/label/c.SMC_Order_Status";
// import DELIVERY_COMPANY from "@salesforce/label/c.SMC_Delivery_Company";
import CARRIER from "@salesforce/label/c.SMC_Carrier";
import DELIVERY_TRACKING_NUMBER from "@salesforce/label/c.SMC_Delivery_Tracking_Number";
import TRACKING_NUMBER from "@salesforce/label/c.SMC_Tracking_Number";
import ORDER_LINES from "@salesforce/label/c.SMC_Order_Lines_CAP";
import LINE_NUMBER from "@salesforce/label/c.SMC_Line_Number";
import PRODUCT_CODE from "@salesforce/label/c.SMC_Product_Code";
import QUANTITY from "@salesforce/label/c.SMC_Quantity";
import DELIVERY_DATE from "@salesforce/label/c.SMC_DeliveryDate";

export default class Smc_lwc_OR_order_tracking_pp extends LightningElement {
  @track secret;
  @track order;
  // @track orderdate;
  // @track deliverycompany;
  // @track deliverytrackingnumber;
  @track isLoad = false;
  @track resultIsNull = false;
  @track noresultlabel = "";
  no = false;

  //Label
  orderTracking = { ORDER_TRACKING };
  orderCodeLabel = { ORDER_CODE };
  orderDateLabel = { ORDER_DATE };
  orderStatusLabel = { ORDER_STATUS };
  // deliveryCompanyLabel = { DELIVERY_COMPANY };
  carrierLabel = { CARRIER };
  deliveryTrackingNumberLabel = { DELIVERY_TRACKING_NUMBER };
  orderLinesLabel = { ORDER_LINES };
  lineNumberLabel = { LINE_NUMBER };
  productCodeLabel = { PRODUCT_CODE };
  trackingNumberLabel = { TRACKING_NUMBER };
  quantityLabel = { QUANTITY };
  deliveryDateLabel = { DELIVERY_DATE };

  connectedCallback() {
    /* Function not supported by InternetExplorer (IE) */
    // this.secret = new URL(window.location.href).searchParams.get(
    //   "trackingorder"
    // );
    /* Function not supported by InternetExplorer (IE)*/

    //Get secret (work with IE)
    this.secret = this.getTrackingOrder();
    //callout to get infos
    this.getOrder();
  }
  get checkBackground() {
    ++this.idxBackground;
    if (!Number.isInteger(this.idxBackground / 2)) {
      return "slds-border_bottom line-hover ligth-background";
    } else {
      return "slds-border_bottom line-hover alternative-ligth-background";
    }
  }

  getTrackingOrder() {
    var key = false,
      res = {},
      itm = null;
    // get the query string without the ?
    var qs = location.search.substring(1);
    // check for the key as an argument
    if (arguments.length > 0 && arguments[0].length > 1) key = arguments[0];
    // make a regex pattern to grab key/value
    var pattern = /([^&=]+)=([^&]*)/g;
    // loop the items in the query string, either
    // find a match to the argument, or build an object
    // with key/value pairs
    let decodeURIvar;
    while ((itm = pattern.exec(qs))) {
      if (key !== false && decodeURIComponent(itm[1]) === key)
        decodeURIvar = decodeURIComponent(itm[2]);
      else if (key === false)
        res[decodeURIComponent(itm[1])] = decodeURIComponent(itm[2]);
    }
    return res.trackingorder;
  }

  getOrder() {
    getOrderFromHP({
      secret: this.secret
    })
      .then(result => {
        if (!JSON.parse(result).getOrderForGuest.error) {
          let elmt = JSON.parse(result).getOrderForGuest.data;
          let productlabelnotavailable = JSON.parse(result).getOrderForGuest.productLabelNotAvailable;
          for (let key in elmt.rows) {
            //Set TrackingNumber if blank
            if (
              (elmt.rows[key].TRACKINGNUMBER === null ||
                elmt.rows[key].TRACKINGNUMBER === undefined ||
                elmt.rows[key].TRACKINGNUMBER === "") &&
              elmt.rows[key].COURIER !== null &&
              elmt.rows[key].COURIER !== undefined &&
              elmt.rows[key].COURIER !== ""
            ) {
              elmt.rows[key].TRACKINGNUMBER = "Not yet available";
            }
            if (
              elmt.rows[key].CDPAR === undefined ||
              elmt.rows[key].CDPAR === null ||
              elmt.rows[key].CDPAR === ""
            ) {
              elmt.rows[key].CDPAR = elmt.rows[key].CDSPS;
            }
            //Set date if not available
            for(let keyBis in productlabelnotavailable){
              if(productlabelnotavailable[keyBis].value === elmt.rows[key].DELIVERYDATE){
                elmt.rows[key].DELIVERYDATE = productlabelnotavailable[keyBis].label;
                break;
              }
            }
          }
          this.order = elmt;
          this.isLoad = true;
        } else {
          this.resultIsNull = true;
          this.noresultlabel = JSON.parse(result).getOrderForGuest.message;
        }
      })
      .catch(error => {
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Error",
            message: JSON.stringify(error),
            variant: "error"
          })
        );
      });
  }

  sendToGoogleAnalytics() {
    // Send event to parent
    const selectedEvent = new CustomEvent("ordertracking", {});
    this.dispatchEvent(selectedEvent);
  }
}