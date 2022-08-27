import { LightningElement, track, api } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getInformations from "@salesforce/apex/SMC_AC_Report_Summarize_Display.getInformations";

export default class Smc_lwc_report_summarize_display extends LightningElement {
  @api title;
  @api reportDeveloperName;
  //Element 1
  @api aggregateColumn1;
  @api typeData1;
  @api numberOfDecimal1;
  @track aggregateColumn1ToDisplay = true;
  @track typeDataCurrency1 = false;
  @track typeDataPercentOrDecimal1 = false;
  //Element 2
  @api aggregateColumn2;
  @api typeData2;
  @api numberOfDecimal2;
  @track aggregateColumn2ToDisplay = true;
  @track typeDataCurrency2 = false;
  @track typeDataPercentOrDecimal2 = false;
  //Results
  @track element1;
  @track element2;
  @track userDefaultCurrency;

  //CSS classes
  @track cssClassElement1 = "slds-size_1-of-2 figure-value";
  @track cssClassElement2 = "slds-size_1-of-2 figure-value";

  connectedCallback() {
    if (this.aggregateColumn1 === undefined) {
      this.aggregateColumn1ToDisplay = false;
      this.cssClassElement2 = "slds-size_1-of-1 figure-value";
    }
    if (this.aggregateColumn2 === undefined) {
      this.aggregateColumn2ToDisplay = false;
      this.cssClassElement1 = "slds-size_1-of-1 figure-value";
    }

    getInformations({
      reportDeveloperName: this.reportDeveloperName,
      aggregateColumn1: this.aggregateColumn1,
      aggregateColumn2: this.aggregateColumn2
    })
      .then(result => {
        if (result && result.error === undefined) {
          this.element1 = result.element1;
          this.element2 = result.element2;
          this.userCurrency = result.userCurrency;

          //Element 1
          if (this.typeData1 !== undefined && this.typeData1 === "currency") {
            this.typeDataCurrency1 = true;
          } else {
            this.typeDataPercentOrDecimal1 = true;
          }

          //Element 2
          if (this.typeData2 !== undefined && this.typeData2 === "currency") {
            this.typeDataCurrency2 = true;
          } else {
            this.typeDataPercentOrDecimal2 = true;
          }
        } else if (result && result.error !== undefined) {
          this.dispatchEvent(
            new ShowToastEvent({
              title: "Error",
              message: result.error,
              variant: "error"
            })
          );
        } else {
          this.dispatchEvent(
            new ShowToastEvent({
              title: "Error",
              message: "An error occur. Contact your salesforce administrator.",
              variant: "error"
            })
          );
        }
      })
      .catch(error => {
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Error",
            message: error,
            variant: "error"
          })
        );
      });
  }
}