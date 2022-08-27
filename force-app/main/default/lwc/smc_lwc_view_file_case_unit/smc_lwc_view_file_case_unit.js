import { LightningElement, api, track } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import CASE_NUMBER_LABEL from "@salesforce/label/c.SMC_CaseNumber";
import BYTES_LABEL from "@salesforce/label/c.SMC_Byte_Label";
/* eslint-disable no-console */
/* eslint-disable no-alert */
/* eslint-disable-next-line @lwc/lwc/no-async-operation*/

export default class Smc_lwc_view_file_case_unit extends NavigationMixin(
  LightningElement
) {
  caseNumberLabel = { CASE_NUMBER_LABEL };
  bytesLabel = { BYTES_LABEL };
  @api thefile;
  @track icon;

  connectedCallback() {
    console.log("this.thefile.FileExtension", this.thefile.FileExtension);
    if (
      this.thefile.FileExtension === "png" ||
      this.thefile.FileExtension === "jpg"
    ) {
      this.icon = "doctype:image";
    }
    // else if() --> video
    else {
      this.icon = "doctype:" + this.thefile.FileExtension;
    }
  }

  redirectToTheFile() {
    this[NavigationMixin.Navigate]({
      type: "standard__recordPage",
      attributes: {
        recordId: this.thefile.Id,
        actionName: "view"
      }
    });
  }
}