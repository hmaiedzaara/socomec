import { LightningElement, track } from "lwc";
import NEED_HELP from "@salesforce/label/c.SMC_Need_Help";
import CLOSE_HELP from "@salesforce/label/c.SMC_Close_Help";
import CREATE_NEW_CASE from "@salesforce/label/c.SMC_Create_New_Case";
import CONTACT_US from "@salesforce/label/c.SMC_Contact_Us";
import ACCESS_DOC from "@salesforce/label/c.SMC_Access_Documentation";
// import CANCEL from "@salesforce/label/c.SMC_Cancel";
// import SEND from "@salesforce/label/c.SMC_Send";
// import getCaseCreationUrl from "@salesforce/apex/SMC_AC_Need_Help.buildUrlToRedirectToCaseCreationPage";
/* eslint-disable no-console */
/* eslint-disable no-alert */
/* eslint-disable-next-line @lwc/lwc/no-async-operation*/

export default class Smc_lwc_need_help extends LightningElement {
  //Custom labels
  needHelp = { NEED_HELP };
  closeHelp = { CLOSE_HELP };
  createNewCase = { CREATE_NEW_CASE };
  contactUs = { CONTACT_US };
  accessDoc = { ACCESS_DOC };

  @track urlCaseCreation;

  // Variables
  @track showNeedHelp = false;

  connectedCallback() {
    // getCaseCreationUrl()
    //   .then(result => {
    //     this.urlCaseCreation = result;
    //   })
    //   .catch(error => {
    //     this.error = true;
    //     this.errorMessage += JSON.stringify(error) + "\n";
    //     this.searching = false;
    //   });
  }

  toogleNeedHelpScreen() {
    this.showNeedHelp = !this.showNeedHelp;
  }
}