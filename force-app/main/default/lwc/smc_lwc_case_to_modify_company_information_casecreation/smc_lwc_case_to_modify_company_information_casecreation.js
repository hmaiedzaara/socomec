import { LightningElement, track } from "lwc";
import createCase from "@salesforce/apex/SMC_AC_Modify_Company_Informations.createCase";
import WAIT_CREATION from "@salesforce/label/c.SMC_Wait_Creation";
import MODIF_ACC_INF from "@salesforce/label/c.SMC_Modify_account_informations";
import CANCEL from "@salesforce/label/c.SMC_Cancel";
import CREATE_CASE from "@salesforce/label/c.SMC_Create_Case";

export default class Smc_lwc_case_to_modify_company_information_casecreation extends LightningElement {
  //Custom Labels
  waitCreation = { WAIT_CREATION };
  modifAccInfLabel = { MODIF_ACC_INF };
  cancel = { CANCEL };
  createCaseLabel = { CREATE_CASE };

  //Track variable
  // @track modalIsDisplay = false;
  @track isWriting = true;
  @track inWaitingDuringCreation = false;
  @track titleMessage;
  @track bodyMessage;

  // showModal() {
  //   this.subjectCase = "";
  //   this.isWriting = true;
  // }

  onCancel() {
    this.inWaitingDuringCreation = false;
    // Send event to parent
    const selectedEvent = new CustomEvent("accountinformationmodification");
    this.dispatchEvent(selectedEvent);
  }

  subjectChange(event) {
    this.subjectCase = event.target.value;
  }

  onCaseCreation() {
    this.inWaitingDuringCreation = true;
    this.isWriting = false;
    createCase({
      subject: this.subjectCase,
      description: this.template.querySelector("lightning-textarea").value
    })
      .then(result => {
        this.inWaitingDuringCreation = false;
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Case creation",
            message: "Your request is saved. ",
            variant: "success"
          })
        );
      })
      .catch(error => {
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Case creation",
            message:
              "Your request can not be saved. Ask to your a Salesforce administrator for more details. \nERROR : " +
              error,
            variant: "error"
          })
        );
      });
    this.onCancel();
  }
}