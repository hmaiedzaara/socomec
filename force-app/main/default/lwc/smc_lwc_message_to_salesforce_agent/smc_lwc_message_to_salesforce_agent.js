import { LightningElement, track, api } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import sendMessage from "@salesforce/apex/SMC_AC_Message_To_Salesforce_Agent.createCommunityMessage";
import MESSAGE_TO_ACCOUNT_OWNER from "@salesforce/label/c.SMC_Message_to_acocunt_owner";
import WAIT_CREATION from "@salesforce/label/c.SMC_Wait_Creation";
import MESSAGE_CREATED from "@salesforce/label/c.SMC_Message_Created";
import MESSAGE_NOT_CREATED from "@salesforce/label/c.SMC_Message_Not_Created";
import CANCEL from "@salesforce/label/c.SMC_Cancel";
import SEND from "@salesforce/label/c.SMC_Send";
/* eslint-disable @lwc/lwc/no-async-operation */

export default class Smc_lwc_message_to_salesforce_agent extends LightningElement {
  //Custom Labels
  messageToAccountOwner = { MESSAGE_TO_ACCOUNT_OWNER };
  waitCreation = { WAIT_CREATION };
  messageCreated = { MESSAGE_CREATED };
  messageNotCreated = { MESSAGE_NOT_CREATED };
  cancel = { CANCEL };
  send = { SEND };

  //Track variable
  @track modalIsDisplay = false;
  @track isWriting = false;
  @track inWaitingDuringCreation = false;
  @track isCreated = false;
  @track isNotCreated = false;
  @track titleMessage;
  @track bodyMessage;

  @api fromaccount = "false";
  @api fromcommunity;
  @track booleanFromAccount = false;

  connectedCallback() {
    this.titleMessage = "";
    this.isWriting = true;
    if (this.fromaccount === "true") {
      this.booleanFromAccount = true;
      this.showModal();
    } else {
      this.booleanFromAccount = false;
    }
  }

  showModal() {
    this.titleMessage = "";
    this.modalIsDisplay = true;
    this.isWriting = true;
  }

  onCancel() {
    this.modalIsDisplay = false;
    this.isCreated = false;
    this.isNotCreated = false;
    this.inWaitingDuringCreation = false;
    if (this.fromaccount === "true") {
      // Send event to parent
      const selectedEvent = new CustomEvent("sendingmessage");
      this.dispatchEvent(selectedEvent);
    }
  }

  titleChange(event) {
    this.titleMessage = event.target.value;
  }

  onSend() {
    this.isWriting = false;
    this.inWaitingDuringCreation = true;
    sendMessage({
      title: this.titleMessage,
      body: this.template.querySelector("lightning-textarea").value
    }).then(result => {
      console.log("onSend result");
      this.inWaitingDuringCreation = false;
      if (result === true) {
        // this.isCreated = true;
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Sending Message",
            message: "Your message is sent.",
            variant: "success"
          })
        );
      } else {
        // this.isNotCreated = true;
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Sending Message",
            message: "An error occur. Your message is not sent.",
            variant: "error"
          })
        );
      }
      this.onCancel();
    });
  }
}