import { LightningElement, api, track } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { NavigationMixin } from "lightning/navigation";
import getTotalRecords from "@salesforce/apex/SMC_AC_Reporting.getTotalRecords";
import LOADING from "@salesforce/label/c.SMC_Loading";
// import NEW_CASE from "@salesforce/label/c.SMC_New_Case";

export default class Smc_lwc_report_summary_community extends NavigationMixin(
  LightningElement
) {
  // @api picto;
  @api titleIcon;
  @api title;
  @api reportName;
  @api bodyLabel;
  @api buttonLabel;
  @api urlButton;
  @api footerLabel;
  @api footerUrl;
  customLabel = { LOADING };

  @track isLoading = true;
  @track rows;
  @track dataCells;
  @track aggregatedValue = 0;
  @track resultIsNull = false;

  connectedCallback() {
    getTotalRecords({
      reportName: this.reportName
    })
      .then(result => {
        if (result === null || result === undefined) {
          this.aggregatedValue = 0;
        } else {
          let parsedResult = JSON.parse(result);
          if (parsedResult && parsedResult.totalRecords !== undefined) {
            this.aggregatedValue = parsedResult.totalRecords;
          } else if (parsedResult && parsedResult.error !== undefined) {
            this.dispatchEvent(
              new ShowToastEvent({
                title: "Error",
                message: parsedResult.error,
                variant: "error"
              })
            );
          } else {
            this.dispatchEvent(
              new ShowToastEvent({
                title: "Error",
                message:
                  "An error occur. Contact your salesforce administrator.",
                variant: "error"
              })
            );
          }
        }
        this.isLoading = false;
      })
      .catch(error => {
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Error",
            message: "Catched error : " + error,
            variant: "error"
          })
        );
        this.isLoading = false;
      });
  }
}