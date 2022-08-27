import { LightningElement, api } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import CANCEL from "@salesforce/label/c.SMC_Cancel";
import DETAILS from "@salesforce/label/c.SMC_Details";

export default class Smc_lwc_my_orders_orderline extends NavigationMixin(
  LightningElement
) {
  @api line;
  @api cdcli;

  cancel = { CANCEL };
  details = { DETAILS };

  viewOrderDetail() {
    const pageRef = {
      type: "standard__webPage",
      attributes: {
        url: "/order-details?cdcli=" + this.cdcli + "&cdord=" + this.line.CDORD
      }
    };
    this[NavigationMixin.Navigate](pageRef);
  }

  cancelOrder() {
    console.log("cancel order " + this.line.CDORD);
  }
}