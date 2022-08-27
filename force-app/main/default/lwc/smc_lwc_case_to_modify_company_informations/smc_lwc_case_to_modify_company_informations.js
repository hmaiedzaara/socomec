import { LightningElement, track, api } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getAccountName from "@salesforce/apex/SMC_AC_Modify_Company_Informations.getAccountName";
import checkAdminContact from "@salesforce/apex/SMC_AC_Modify_Company_Informations.checkContactAdministrator";
import MESSAGE_TO_SALES_CONTACT from "@salesforce/label/c.SMC_Message_To_Sales_Contact";
import EDIT_CONTACTS from "@salesforce/label/c.SMC_Edit_Contacts";
import MODIF_ACC_INF from "@salesforce/label/c.SMC_Modify_account_informations";
/* eslint-disable no-console */
/* eslint-disable no-alert */
/* eslint-disable-next-line @lwc/lwc/no-async-operation*/

export default class Smc_lwc_case_to_modify_company_informations extends LightningElement {
  @api displayEditContact;
  @api displayAccountInformationModification;

  messageToSalesContact = { MESSAGE_TO_SALES_CONTACT };
  editContacts = { EDIT_CONTACTS };
  modifAccInfLabel = { MODIF_ACC_INF };

  @track accountName = "Account Name";
  @track showMessageToSalesContact = false;
  @track showEditContacts = false;
  @track showModifAccInf = false;

  connectedCallback() {
    getAccountName()
      .then(result => {
        if (result) {
          this.accountName = result;
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
    checkAdminContact()
      .then(result => {
        if (result) {
          //If cmp is paramto let display btn, check if user is the administrator to display the  btn
          if (this.displayAccountInformationModification) {
            this.displayAccountInformationModification = result;
          }
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

  handleMessageToSalesContact() {
    this.showMessageToSalesContact = !this.showMessageToSalesContact;
  }

  handleEditContacts() {
    this.showEditContacts = !this.showEditContacts;
  }

  handleModifAccInf() {
    this.showModifAccInf = !this.showModifAccInf;
  }
}