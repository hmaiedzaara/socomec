import { LightningElement, api, wire, track } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import isEOL from "@salesforce/apex/SMC_AP_ManageWorkOrder.isLinkedAssetsEOL";
export default class smc_lwc_WorkOrderCheckEolAsset extends LightningElement {
  @api recordId;
  @track
  showWarning = false;
  @wire(isEOL, { workorderId: "$recordId" })
  showToast({ error, data }) {
    if (data) {
      if (data === true) {
        const event = new ShowToastEvent({
          title: "Warning",
          message: "This asset has reached his End of Life.",
          variant: "error"
        });
        this.dispatchEvent(event);
        this.showWarning = true;
      }
    } else if (error) {
      console.log(error);
    }
  }
}