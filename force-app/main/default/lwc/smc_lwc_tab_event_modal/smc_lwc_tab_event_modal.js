import { LightningElement, api, track } from "lwc";
import EDIT_SD from "@salesforce/label/c.SMC_Edit_Start_Date";
import CANCEL from "@salesforce/label/c.SMC_Cancel";
import SAVE from "@salesforce/label/c.SMC_Save";
/* eslint-disable @lwc/lwc/no-async-operation */

export default class Smc_lwc_tab_event_modal extends LightningElement {
  editSd = { EDIT_SD };
  cancel = { CANCEL };
  save = { SAVE };

  @api largefactor;
  @track datetimePicker;
  @track datePicker;
  @track timePicker;

  datetimeSelector(event) {
    this.datetimePicker = event.target.value;
  }
  dateSelector(event) {
    this.datePicker = event.target.value;
  }
  timeSelector(event) {
    this.timePicker = event.target.value;
  }

  onCancel() {
    // Close modal
    const selectedEvent = new CustomEvent("closemodal");
    this.dispatchEvent(selectedEvent);
  }

  onSave() {
    if (this.datePicker != null && this.timePicker != null) {
      let dateTab = this.datePicker.split("-");
      let timeTab = this.timePicker.split(":");
      //Month is 0-indexed
      this.datetimePicker = new Date(
        Number(dateTab[0]),
        Number(dateTab[1]) - 1, //Month is 0-indexed
        Number(dateTab[2]),
        Number(timeTab[0]),
        Number(timeTab[1]),
        Number(timeTab[2])
      );
    }
    // Close modal
    const selectedEvent = new CustomEvent("savenewdate", {
      detail: this.datetimePicker
    });
    this.dispatchEvent(selectedEvent);
  }
}