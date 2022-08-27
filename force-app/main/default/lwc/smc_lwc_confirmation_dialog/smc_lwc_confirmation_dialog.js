import { LightningElement, api, track } from "lwc";

export default class Smc_lwc_confirmation_dialog extends LightningElement {
  @api fromDoraBuyAgainOrder = false; //used to hide/show date input
  @api inputDateLabel = ""; //used to hide/show date input
  @track dateValue;

  @api visible = false; //used to hide/show dialog
  @api title = ""; //modal title
  @api name; //reference name of the component
  @api message = ""; //modal message
  @api confirmLabel = ""; //confirm button label
  @api cancelLabel = ""; //cancel button label
  @api originalMessage; //any event/message/detail to be published back to the parent component

  //handles button clicks
  handleConfirm() {
    if (this.fromDoraBuyAgainOrder && this.dateValue === undefined) {
      this.dispatchEvent(
        new ShowToastEvent({
          title: "Warning",
          message: "Please fill the requested date before confirmation.",
          variant: "warning"
        })
      );
    } else if (this.fromDoraBuyAgainOrder && this.dateValue !== undefined) {
      //dispatch a 'click' event so the parent component can handle it.
      let finalEvent = {
        originalMessage: this.originalMessage,
        inputDateValue: this.dateValue
      };
      this.dispatchEvent(
        new CustomEvent("confirmed", {
          detail: finalEvent
        })
      );
    } else if (!this.fromDoraBuyAgainOrder) {
      //dispatch a 'click' event so the parent component can handle it.
      let finalEvent = {
        originalMessage: this.originalMessage
      };
      this.dispatchEvent(
        new CustomEvent("confirmed", {
          detail: finalEvent
        })
      );
    }
  }

  handleCancel() {
    //dispatch a 'click' event so the parent component can handle it
    let finalEvent = {
      originalMessage: this.originalMessage
    };
    this.dispatchEvent(
      new CustomEvent("cancelled", {
        detail: finalEvent
      })
    );
  }

  handleChangeDate(event) {
    this.dateValue = event.target.value;
  }
}