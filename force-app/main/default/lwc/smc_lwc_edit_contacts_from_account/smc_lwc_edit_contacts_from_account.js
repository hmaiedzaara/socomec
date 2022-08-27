import { LightningElement, track, api } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getContacts from "@salesforce/apex/SMC_AC_Edit_Contacts_From_Account.getContacts";
import saveContacts from "@salesforce/apex/SMC_AC_Edit_Contacts_From_Account.saveContacts";
import IOT_MAIN_CONTACT from "@salesforce/label/c.SMC_IOT_Main_Contact";
import IOT_ADMINISTRATIVE_CONTACT from "@salesforce/label/c.SMC_IOT_Administrative_Contact";
import IOT_TECHNICAL_CONTACT from "@salesforce/label/c.SMC_IOT_Technical_Contact";
import REQUEST_IOT_CONTACT_MODIFICATION from "@salesforce/label/c.SMC_Request_IOT_Contact_Modification";
import WAIT_CREATION from "@salesforce/label/c.SMC_Wait_Creation";
import CANCEL from "@salesforce/label/c.SMC_Cancel";
import SAVE from "@salesforce/label/c.SMC_Save";
/* eslint-disable no-console */
/* eslint-disable no-alert */
/* eslint-disable-next-line @lwc/lwc/no-async-operation*/

export default class Smc_lwc_edit_contacts_from_account extends LightningElement {
  // Labels
  iotMainContact = { IOT_MAIN_CONTACT };
  iotAdministrativeContact = { IOT_ADMINISTRATIVE_CONTACT };
  iotTechnicalContact = { IOT_TECHNICAL_CONTACT };
  requestIOTContactModification = { REQUEST_IOT_CONTACT_MODIFICATION };
  waitCreation = { WAIT_CREATION };
  cancel = { CANCEL };
  save = { SAVE };

  // Static attributes
  @track inWaitingDuringCreation = false;

  // Dynamic attributes
  @track accountId;
  @track accountName;
  @track toogleModalSize = false;
  @track modalContentSize = "slds-modal__content slds-p-around--medium";
  @track mainContactSelectedInit;
  @track mainContactSelected;
  @track administrativeContactSelectedInit;
  @track administrativeContactSelected;
  @track technicalContactSelectedInit;
  @track technicalContactSelected;
  @track mapContacts = [];

  // Complementary message
  @track caseNumber;

  connectedCallback() {
    getContacts()
      .then(result => {
        if (result) {
          let parsedResult = JSON.parse(result);
          this.accountId = parsedResult.accountId;
          this.accountName = parsedResult.accountName;
          this.mainContactSelectedInit = parsedResult.iotMainContactId;
          this.mainContactSelected = parsedResult.iotMainContactId;
          this.administrativeContactSelectedInit =
            parsedResult.iotAdministrativeContactId;
          this.administrativeContactSelected =
            parsedResult.iotAdministrativeContactId;
          this.technicalContactSelectedInit =
            parsedResult.iotTechnicalContactId;
          this.technicalContactSelected = parsedResult.iotTechnicalContactId;
          this.mapContacts = parsedResult.mapContacts;
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
      });
  }

  onCancel() {
    this.inWaitingDuringCreation = false;
    // Send event to parent
    const selectedEvent = new CustomEvent("iotcontactmodificationrequest");
    this.dispatchEvent(selectedEvent);
  }

  handleChangeMainContact(event) {
    this.mainContactSelected = event.target.value;
  }

  handleChangeAdministrativeContact(event) {
    this.administrativeContactSelected = event.target.value;
  }

  handleChangeTechnicalContact(event) {
    this.technicalContactSelected = event.target.value;
  }

  // toogleModalContentSize() {
  //   if (this.toogleModalSize) {
  //     this.toogleModalSize = !this.toogleModalSize;
  //     this.modalContentSize = "slds-modal__content slds-p-around--medium";
  //   } else {
  //     this.toogleModalSize = !this.toogleModalSize;
  //     this.modalContentSize =
  //       "slds-modal__content slds-p-around--medium selectIsOpened";
  //   }
  // }

  onSave() {
    this.inWaitingDuringCreation = true;
    saveContacts({
      accountId: this.accountId,
      accountName: this.accountName,
      mainContactId:
        this.mainContactSelected != this.mainContactSelectedInit
          ? this.mainContactSelected
          : null,
      administrativeContactId:
        this.administrativeContactSelected !=
        this.administrativeContactSelectedInit
          ? this.administrativeContactSelected
          : null,
      technicalContactId:
        this.technicalContactSelected != this.technicalContactSelectedInit
          ? this.technicalContactSelected
          : null,
      mapContactsSerialized: JSON.stringify(this.mapContacts)
    }).then(result => {
      if (result === true) {
        this.dispatchEvent(
          new ShowToastEvent({
            title: "IOT Contacts modification",
            message: "The account is updated. Refresh your page to this it.",
            variant: "success"
          })
        );
      } else if (result === false) {
        this.dispatchEvent(
          new ShowToastEvent({
            title: "IOT Contacts modification",
            message: "An error occur. Report to your Salesforce admin.",
            variant: "error"
          })
        );
      } else {
        this.dispatchEvent(
          new ShowToastEvent({
            title: "IOT Contacts modification",
            message: "There is no change.",
            variant: "warning"
          })
        );
      }
      this.onCancel();
    });
  }
}