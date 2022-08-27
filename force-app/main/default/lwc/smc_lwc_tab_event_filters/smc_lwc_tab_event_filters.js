import { LightningElement, track, api } from "lwc";
import SEARCH_BY from "@salesforce/label/c.SMC_Search_by";
import ACCOUNT_NAME from "@salesforce/label/c.SMC_Account_Name";
import CONTACT_NAME from "@salesforce/label/c.SMC_Contact_Name";
import START_DATE from "@salesforce/label/c.SMC_Start_Date";
import END_DATE from "@salesforce/label/c.SMC_End_Date";
import EDIT from "@salesforce/label/c.SMC_Edit";
/* eslint-disable @lwc/lwc/no-async-operation */
/* eslint-disable */

export default class Smc_lwc_tab_event_filters extends LightningElement {
  customLabels = {
    SEARCH_BY,
    ACCOUNT_NAME,
    CONTACT_NAME,
    START_DATE,
    END_DATE,
    EDIT
  };

  @api calendars;

  //Calendar - Date
  @track calendarSelected;
  @track startDateQueryTerm;
  //Account
  @track accountNameQueryTerm;
  @track queryAccountSent = true;
  //Contact
  @track contactNameQueryTerm;
  @track queryContactSent = true;

  calendarSelector(event) {
    //Get calendar name
    for (let key in this.calendars) {
      if (this.calendars[key].value === event.target.value) {
        // Send calendar name to parent
        const selectedEvent = new CustomEvent("calendarselected", {
          detail: this.calendars[key].label
        });
        this.dispatchEvent(selectedEvent);
      }
    }
  }

  editStartDate() {
    // Send event to parent
    const selectedEvent = new CustomEvent("openeditstartdate");
    this.dispatchEvent(selectedEvent);
  }

  handleStartDateSelected(event) {
    if (event.target.value !== undefined) {
      //Send query term
      const selectedEvent = new CustomEvent("querystartdate", {
        detail: event.target.value
      });
      this.dispatchEvent(selectedEvent);
    }
  }
  handleEndDateSelected(event) {
    if (event.target.value !== undefined) {
      //Send query term
      const selectedEvent = new CustomEvent("queryenddate", {
        detail: event.target.value
      });
      this.dispatchEvent(selectedEvent);
    }
  }

  handleAccountNameKeyUp(event) {
    if (event.target.value === undefined) {
      this.accountNameQueryTerm = "";
    } else {
      this.accountNameQueryTerm = event.target.value;
    }

    if (this.queryAccountSent) {
      this.queryAccountSent = false;
      setTimeout(() => {
        //Send query term
        const selectedEvent = new CustomEvent("queryaccountname", {
          detail: this.accountNameQueryTerm
        });
        this.dispatchEvent(selectedEvent);
        this.queryAccountSent = true;
      }, 1000);
    }
  }

  handleContactNameKeyUp(event) {
    if (event.target.value === undefined) {
      this.contactNameQueryTerm = "";
    } else {
      this.contactNameQueryTerm = event.target.value;
    }

    if (this.queryContactSent) {
      this.queryContactSent = false;
      setTimeout(() => {
        //Send query term
        const selectedEvent = new CustomEvent("querycontactname", {
          detail: this.contactNameQueryTerm
        });
        this.dispatchEvent(selectedEvent);
        this.queryContactSent = true;
      }, 1000);
    }
  }
}