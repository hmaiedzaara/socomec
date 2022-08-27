/**
 * @description       : This cmp is used to redirection current user to an order tracking page in according to the "secret"
 * @author            : Vincent RECASENS (Modis)
 * @group             :
 * @last modified on  : 10-26-2020
 * @last modified by  : Vincent RECASENS (Modis)
 * Modifications Log
 * Ver   Date         Author                     Modification
 * 1.0   10-26-2020   Vincent RECASENS (Modis)   Initial Version
 **/
import { LightningElement, track } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import ORDER_TRACKING from "@salesforce/label/c.SMC_Order_Tracking";
import ORDER_TRACKING_NUMBER from "@salesforce/label/c.SMC_Order_Tracking_Number";
import VALIDATE from "@salesforce/label/c.SMC_Validate";
import WARNING from "@salesforce/label/c.SMC_Warning";
import WARNING_MESSAGE from "@salesforce/label/c.SMC_OR_Missing_PdtCode";

export default class Smc_lwc_OR_order_tracking_hp extends NavigationMixin(
  LightningElement
) {
  //Variables
  @track ordercode = "";
  @track trackingorder = "";

  //Label
  orderTracking = { ORDER_TRACKING };
  orderTrackingNumberLabel = { ORDER_TRACKING_NUMBER };
  validateLabel = { VALIDATE };
  warningLabel = { WARNING };
  warningMessageLabel = { WARNING_MESSAGE };

  handleSearchOrder(event) {
    this.trackingorder = event.target.value;
  }

  //Get the input value and redirect user to the order detail page (for guest user)
  handleValidate() {
    if (this.trackingorder != undefined && this.trackingorder != "") {
      //Get Product Info from url
      const pageRef = {
        type: "standard__webPage",
        attributes: {
          url: "/order-tracking?trackingorder=" + this.trackingorder
        }
      };
      this[NavigationMixin.Navigate](pageRef);
    } else {
      this.dispatchEvent(
        new ShowToastEvent({
          title: this.warningLabel.WARNING,
          message: this.warningMessageLabel.WARNING_MESSAGE,
          variant: "warning"
        })
      );
    }
  }
}