import { LightningElement, api, track } from "lwc";
import HISTORY from "@salesforce/label/c.SMC_History";
import getInformationsList from "@salesforce/apex/SMC_AC_LTG_MassSelectSP.getInformationsList";

export default class Smc_lwc_gtl_serviceproductmanagement_historic extends LightningElement {
  @api recordid;
  @api typeHsitoric;
  history = { HISTORY };
  @track historic = ["No modification"];
  @track scrollableVar = "";

  connectedCallback() {
    getInformationsList({
      recordId: this.recordid
    })
      .then(result => {
        if (result !== null && result !== undefined && result.length !== 0) {
          this.historic = result;
          if (this.historic.length > 5) {
            this.scrollableVar = "slds-scrollable";
          }
        }
      })
      .catch(error => {
        this.error = true;
        this.errorMessage += JSON.stringify(error) + "\n";
      });
  }
}