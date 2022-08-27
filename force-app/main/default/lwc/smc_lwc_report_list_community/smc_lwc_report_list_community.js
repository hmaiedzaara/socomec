import { LightningElement, api, track } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getColumns from "@salesforce/apex/SMC_AC_Reporting.getColumns";
import NO_DATA from "@salesforce/label/c.SMC_NoResultFound";

export default class Smc_lwc_report_summary_community extends LightningElement {
  // @api picto;
  @api titleIcon;
  @api title;
  @api reportName;
  @api body;
  @api urlBaseToRecord;
  @api footer;
  @api link;
  @api targetObject;
  noData = { NO_DATA };

  @api nbOfColumns;
  @api nbOfRecords;

  @track isLoading = true;
  @track rows = [];
  @track column1 = [];
  @track column2 = [];
  @track lineClass;
  @track resultIsNull = false;

  @track scrollableY = null;

  connectedCallback() {
    let targetObjectLowerCase = this.targetObject.toLowerCase();
    //Get values
    getColumns({
      reportName: this.reportName,
      nbOfColumns: this.nbOfColumns,
      nbOfRecords: this.nbOfRecords
    })
      .then((result) => {
        if (result === null || result === undefined) {
          this.resultIsNull = true;
        } else {
          let parsedResult = JSON.parse(result);
          if (parsedResult.mapReportRows !== null) {
            let i = 0;
            for (let key in parsedResult.mapReportRows) {
              this.rows.push({
                key: key,
                value: parsedResult.mapReportRows[key]
              });
              let rowUrl = this.urlBaseToRecord;
              this.rows[key].urlToRecord = rowUrl.replace('[target-object-name]', targetObjectLowerCase).replace('[recordId]', parsedResult.mapReportRows[key].recordId);
                // "/customerportal/s/" +
                // targetObjectLowerCase +
                // "/" +
                // parsedResult.mapReportRows[key].recordId +
                // "/detail";
              ++i;
            }
            if (i > 4) {
              this.scrollableY = "slds-scrollable_y";
            }
          } else if (parsedResult.error !== null) {
            this.dispatchEvent(
              new ShowToastEvent({
                title: "Error",
                message: "Result error",
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
      .catch((error) => {
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Error",
            message: error,
            variant: "error"
          })
        );
        this.isLoading = false;
      });
  }
}