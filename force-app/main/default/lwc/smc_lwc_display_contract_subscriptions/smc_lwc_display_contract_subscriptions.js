import { LightningElement, track, api } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import initMethod from "@salesforce/apex/SMC_AC_Display_ContractSubscription.initMethod";

export default class Smc_lwc_display_contract_subscriptions extends LightningElement {
  @track isLoading = true;
  @track results;

  connectedCallback() {
    initMethod()
      .then(result => {
        this.results = result;
        this.isLoading = false;
      })
      .catch(error => {
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Error",
            message: "Apex error",
            variant: "error"
          })
        );
        this.isLoading = false;
      });
  }
}