import { LightningElement, api, track } from "lwc";
import sendMessage from "@salesforce/apex/SMC_AC_Message_To_Customer.createCommunityMessage";
import getContacts from "@salesforce/apex/SMC_AC_Message_To_Customer.getContactsFromAccount";
import SELECT_CONTACT from "@salesforce/label/c.SMC_Select_Contact";
import SEND from "@salesforce/label/c.SMC_Send";

export default class Smc_lwc_message_to_customer extends LightningElement {
  @api recordid;

  @track contacts;
  @track accountId;
  @track pfrId;
  @track selectedContact;
  @track mapcontactIdToContactEmail = [];

  selectContact = { SELECT_CONTACT };
  send = { SEND };

  connectedCallback() {
    // subscribe to searchKeyChange event
    getContacts({
      recordId: this.recordid
    }).then(result => {
      let parse = JSON.parse(result);
      this.contacts = parse.contacts;
      this.accountId = parse.accountId;
      this.pfrId = parse.pfrId;
      this.selectedContact = parse.contacts[0].Id;
      this.mapcontactIdToContactEmail = parse.mapcontactIdToContactEmail;
    });
  }

  handleTitle(event) {
    this.titleMessage = event.target.value;
  }

  handleSelectContact(event) {
    this.selectedContact = event.target.value;
  }

  onSend() {
    sendMessage({
      title: this.titleMessage,
      body: this.template.querySelector("lightning-textarea").value,
      selectedContact: this.selectedContact,
      accountId: this.accountId,
      pfrId: this.pfrId,
      mapcontactIdToContactEmail: this.mapcontactIdToContactEmail
    }).then(result => {
      //Close QuickAction
      this.dispatchEvent(
        new CustomEvent("SMC_LCE_CloseQuickAction_From_LWC", {
          detail: { isCreated: result }
        })
      );
    });
  }
}