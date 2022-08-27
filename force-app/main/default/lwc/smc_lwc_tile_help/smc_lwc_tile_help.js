import { LightningElement, api, track } from "lwc";
import NEED_HELP from "@salesforce/label/c.SMC_Need_Help";
import CLOSE_HELP from "@salesforce/label/c.SMC_Close_Help";
import CREATE_NEW_CASE from "@salesforce/label/c.SMC_Create_New_Case";
import CONTACT_US from "@salesforce/label/c.SMC_Contact_Us";
import ACCESS_DOC from "@salesforce/label/c.SMC_Access_Documentation";
import FAQ from "@salesforce/label/c.SMC_FAQ";
/* eslint-disable no-console */
/* eslint-disable no-alert */
/* eslint-disable-next-line @lwc/lwc/no-async-operation*/

export default class Smc_lwc_tile_help extends LightningElement {
  @api titleIcon;
  @api title;

  @track isLoading = true;

  //Custom labels
  needHelp = { NEED_HELP };
  closeHelp = { CLOSE_HELP };
  createNewCase = { CREATE_NEW_CASE };
  contactUs = { CONTACT_US };
  accessDoc = { ACCESS_DOC };
  faq = { FAQ };
}