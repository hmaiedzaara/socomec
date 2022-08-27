import { LightningElement, api, track } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getRecords from "@salesforce/apex/SMC_AC_MyApplications.getRecords";
import NO_DATA from "@salesforce/label/c.SMC_NoResultFound";
/* eslint-disable no-console */
/* eslint-disable no-alert */
/* eslint-disable-next-line @lwc/lwc/no-async-operation*/

export default class Smc_lwc_report_summary_community extends LightningElement {
  // @api picto;
  @api titleIcon;
  @api title;
  @api footer;
  @api link;
  @api targetObject;
  @api communityLabel;
  noData = { NO_DATA };

  @track isLoading = true;
  @track datas = [];
  @track resultIsNull = false;

  @track scrollableY = null;

  connectedCallback() {
    //Get values
    getRecords({
      targetObject: this.targetObject,
      communityLabel: this.communityLabel
    })
      .then(result => {
        this.datas = JSON.parse(result);
        if (this.datas.length > 4) {
          this.scrollableY = "slds-scrollable_y";
        } else if (this.datas.length === undefined || this.datas.length === 0) {
          this.resultIsNull = true;
        }
        this.isLoading = false;
      })
      .catch(error => {
        this.resultIsNull = true;
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Error",
            message: JSON.stringify(error),
            variant: "error"
          })
        );
        this.isLoading = false;
      });
  }
  /*
  toastNoData() {
    // this.resultIsNull = true;
    this.dispatchEvent(
      new ShowToastEvent({
        title: "Error",
        message:
          "There is no url link to this product. Ask to your salesforce administrator for more informations.",
        variant: "error"
      })
    );
  }
  */
}