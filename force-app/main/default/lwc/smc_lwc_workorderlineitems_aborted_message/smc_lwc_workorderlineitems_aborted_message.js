import { LightningElement, api, track } from "lwc";
import getWoliInfos from "@salesforce/apex/SMC_AC_WOLI_Aborted_Message.getWoliInfos"; //
import WOLI_ABORTED from "@salesforce/label/c.SMC_WOLI_Aborted";

export default class Smc_lwc_workorderlineitems_aborted_message extends LightningElement {
  @api recordId;
  @track woliAbortedExist = false;
  @track woliAborted = [];
  woliAbortedTitle = { WOLI_ABORTED };

  connectedCallback() {
    getWoliInfos({ recordId: this.recordId })
      .then(result => {
        console.log(result);
        if (result !== undefined && result.length > 0) {
          this.woliAbortedExist = true;
          this.woliAborted = result;
        }
      })
      .catch(error => {
        console.log(JSON.parse(JSON.stringify(error)));
      });
  }
}