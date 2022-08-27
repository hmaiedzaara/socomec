import { LightningElement, api, track } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getField from "@salesforce/apex/SMC_AC_Display_One_Specific_Field.getField";

export default class Smc_lwc_display_one_specific_field extends LightningElement {
  @api recordId;
  @api objectAPIName;
  @api fieldAPIName;

  @track isRichText = false;
  @track isImage = false;
  @track spinner = false;
  @track fieldToDisplay;
  @track title;
  @track fieldValue;
  @track altText;

  connectedCallback() {
    this.getFieldInfos();
  }

  getFieldInfos() {
    getField({
      recId: this.recordId,
      objectAPIName: this.objectAPIName,
      fieldAPIName: this.fieldAPIName
    })
      .then(result => {
        console.log("result", result);
        this.title = result.title;
        if (result.fieldType === "IMAGE") {
          this.isImage = true;
          this.fieldValue = result.fieldValue;
          this.altText = result.title;
        } else {
          this.isRichText = true;
          this.fieldValue = result.fieldValue;
        }
      })
      .catch(error => {
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Error",
            message: JSON.stringify(error),
            variant: "error"
          })
        );
        this.spinner = false;
      });
  }
}