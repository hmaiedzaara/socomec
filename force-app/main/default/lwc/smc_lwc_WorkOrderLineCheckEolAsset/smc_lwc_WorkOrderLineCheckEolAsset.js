import { LightningElement, api, wire, track } from "lwc";
import isEOL from "@salesforce/apex/SMC_AP_ManageWorkOrderLineItem.isLinkedAsset";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import WARNING_EOL from "@salesforce/label/c.SMC_Warning_Asset_EOL";
import WARNING_SPAREPART from "@salesforce/label/c.SMC_Warning_Asset_SparePart";
export default class Smc_lwc_WorkOrderLineCheckEolAsset extends LightningElement {
  @api recordId;
  @track
  showWarningEOL = false;
  showWarningSparePart = false;

  warningEol = { WARNING_EOL };
  warningSparePart = { WARNING_SPAREPART };

  @wire(isEOL, { workorderLineItemId: "$recordId" })
  showToast({ error, data }) {
    if (data) {
      if (data["eol"] === true) {
        const event = new ShowToastEvent({
          title: "Warning",
          message: this.warningEol.WARNING_EOL,
          variant: "error"
        });
        this.dispatchEvent(event);
        this.showWarningEOL = true;
      }
      if (data["sparePart"] === true) {
        const event = new ShowToastEvent({
          title: "Warning",
          message: this.warningSparePart,
          variant: "error"
        });
        this.dispatchEvent(event);
        this.showWarningSparePart = true;
      }
    } else if (error) {
      console.log(error);
    }
  }
}