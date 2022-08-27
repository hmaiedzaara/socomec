import { LightningElement, track, wire } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import NEED_HELP from "@salesforce/label/c.SMC_Need_Help";
import CLOSE_HELP from "@salesforce/label/c.SMC_Close_Help";
import CREATE_NEW_CASE from "@salesforce/label/c.SMC_Create_New_Case";
import CONTACT_US from "@salesforce/label/c.SMC_Contact_Us";
import ACCESS_DOC from "@salesforce/label/c.SMC_Access_Documentation";
import FAQ from "@salesforce/label/c.SMC_FAQ";
import getStickyInfos from "@salesforce/apex/SMC_AC_StickyHelp.getStickyInfos";
/* eslint-disable no-console */
/* eslint-disable no-alert */
/* eslint-disable-next-line @lwc/lwc/no-async-operation*/

export default class Smc_lwc_sticky_help extends NavigationMixin(
  LightningElement
) {
  //Custom labels
  needHelp = { NEED_HELP };
  closeHelp = { CLOSE_HELP };
  createNewCase = { CREATE_NEW_CASE };
  @track caseUrl;
  contactUs = { CONTACT_US };
  @track contactUsUrl;
  accessDoc = { ACCESS_DOC };
  @track accessDocUrl;
  faq = { FAQ };
  @track faqUrl;
  
  // Variables
  @track showSticky = false;

  connectedCallback(){
    getStickyInfos()
      .then(result => {
        let parsedResult = JSON.parse(result);
        for(let elmt in parsedResult){
          if(parsedResult[elmt].masterLabel == 'Case'){
            this.caseUrl = parsedResult[elmt].url
          }
          else if(parsedResult[elmt].masterLabel == 'Contact Support'){
            this.contactUsUrl = parsedResult[elmt].url
          }
          else if(parsedResult[elmt].masterLabel == 'Documents'){
            this.accessDocUrl = parsedResult[elmt].url
          }
          else if(parsedResult[elmt].masterLabel == 'FAQ'){
            this.faqUrl = parsedResult[elmt].url
          }
        }
      })
      .catch(error => {
        console.log(JSON.parse(JSON.stringify(error)));
      });
  }

  toogleSticky() {
    this.showSticky = !this.showSticky;
  }
}