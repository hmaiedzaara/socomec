import { LightningElement, track } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getCalendars from "@salesforce/apex/SMC_AC_Tab_Event.getCalendars";
import getEventInformations from "@salesforce/apex/SMC_AC_Tab_Event.getEventInformations";
import saveUpdate from "@salesforce/apex/SMC_AC_Tab_Event.saveUpdate";
import CALENDAR from "@salesforce/label/c.SMC_Calendar";

import FORM_FACTOR from "@salesforce/client/formFactor";

/* eslint-disable no-console */
/* eslint-disable no-alert */
/* eslint-disable-next-line @lwc/lwc/no-async-operation*/

export default class Smc_lwc_tab_event_page extends LightningElement {
  //Labels
  calendar = { CALENDAR };
  //Datas
  @track columns = [];
  @track datas = [];
  //Spinner
  @track searchOrSave = false;
  //Filters
  @track calendars = [];
  @track selectedCalendar;
  @track modalIsDisplay = false;
  @track datePicker;
  @track queryAccountName = "";
  @track queryContactName = "";
  @track queryStartDate;
  @track queryEndDate;
  //Sorting
  @track defaultSortDirection = "asc";
  @track sortDirection = "asc";
  @track sortedBy;
  //Offset
  @track offset = 0;
  offsetSize = 50000;
  @track showMoreOrLess;
  @track reachMax;
  @track reachMin;

  @track largeFactor = true;
  @track responsiveDatable = "";

  connectedCallback() {
    if (FORM_FACTOR !== "Large") {
      this.responsiveDatable = "slds-max-medium-table_stacked";
      this.largeFactor = false;
    }
    getCalendars()
      .then(result => {
        this.selectedCalendar = "None";
        this.calendars.push({ label: "None", value: "none" });
        for (let key in result) {
          this.calendars.push({ label: result[key], value: key });
        }
      })
      .catch(error => {
        console.log(JSON.parse(JSON.stringify(error)));
      });
  }

  handleCalendarSelected(event) {
    this.selectedCalendar = event.detail;
    this.datas = [];
    this.refreshList();
  }

  handleQueryAccountName(event) {
    this.queryAccountName = event.detail;
    this.datas = [];
    this.refreshList();
  }

  handleQueryContactName(event) {
    this.queryContactName = event.detail;
    this.datas = [];
    this.refreshList();
  }

  handleQueryStartDate(event) {
    this.queryStartDate = event.detail;
    this.datas = [];
    this.refreshList();
  }
  handleQueryEndDate(event) {
    this.queryEndDate = event.detail;
    this.datas = [];
    this.refreshList();
  }

  toogleModal() {
    let rows = this.template
      .querySelector("lightning-datatable")
      .getSelectedRows();
    if (JSON.parse(JSON.stringify(rows)).length === 0 && !this.modalIsDisplay) {
      this.dispatchEvent(
        new ShowToastEvent({
          title: "No selection",
          message: "Select rows before select a start date.",
          variant: "warning"
        })
      );
    } else {
      this.modalIsDisplay = !this.modalIsDisplay;
    }
  }

  onHandleSort(event) {
    const { fieldName: sortedBy, sortDirection } = event.detail;
    const cloneData = [...this.datas];

    cloneData.sort(this.sortBy(sortedBy, sortDirection === "asc" ? 1 : -1));
    this.datas = cloneData;
    this.sortDirection = sortDirection;
    this.sortedBy = sortedBy;
  }

  refreshList() {
    //Spinner
    this.searchOrSave = true;
    //Get calendar data
    if (this.selectedCalendar === "None") {
      this.datas = [];
      //Spinner
      this.searchOrSave = false;
    } else {
      getEventInformations({
        offsetSize: this.offsetSize,
        offset: this.offset,
        queryAccountName: this.queryAccountName,
        queryContactName: this.queryContactName,
        queryStartDate: this.queryStartDate,
        queryEndDate: this.queryEndDate,
        selectedCalendar: this.selectedCalendar
      })
        .then(result => {
          this.columns = JSON.parse(result).columns;
          console.log("columns", JSON.parse(result).columns);
          if (this.datas === []) {
            this.datas = JSON.parse(result).datas;
          } else {
            Array.prototype.push.apply(this.datas, JSON.parse(result).datas);
          }
          for (let key in this.datas) {
            this.datas[key].startDate = new Date(this.datas[key].startDate);
          }
          //Show more or less datas
          this.checkedLimits();
          //Spinner
          this.searchOrSave = false;
        })
        .catch(error => {
          this.datas = [];
          console.log("error", JSON.parse(JSON.stringify(error)));
          //Spinner
          this.searchOrSave = false;
        });
    }
  }

  // Used to sort the 'Age' column
  sortBy(field, reverse, primer) {
    const key = primer
      ? function(x) {
          return primer(x[field]);
        }
      : function(x) {
          return x[field];
        };

    return function(a, b) {
      a = key(a);
      b = key(b);
      return reverse * ((a > b) - (b > a));
    };
  }

  handleSave(event) {
    //Spinner
    this.searchOrSave = true;
    let rows = this.template
      .querySelector("lightning-datatable")
      .getSelectedRows();
    saveUpdate({
      jsonSelectedRows: JSON.stringify(rows),
      dateSelected: event.detail,
      queryWithContactName: this.queryContactName
    })
      .then(result => {
        if (result) {
          this.dispatchEvent(
            new ShowToastEvent({
              title: "Updated",
              message: "Events are updated.",
              variant: "success"
            })
          );
          this.datas = [];
          this.modalIsDisplay = !this.modalIsDisplay;
          this.refreshList();
        } else {
          this.dispatchEvent(
            new ShowToastEvent({
              title: "Error during update",
              message:
                "The update can't be execute. Ask to your Salesforce admin.",
              variant: "error"
            })
          );
        }
        //Spinner
        this.searchOrSave = false;
        this.modalIsDisplay = false;
      })
      .catch(error => {
        console.log("error", JSON.parse(JSON.stringify(error)));
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Error",
            message: error,
            variant: "error"
          })
        );
        //Spinner
        this.searchOrSave = false;
        this.modalIsDisplay = false;
      });
  }

  showMore() {
    this.offset += 1;
    this.refreshList();
    this.checkedLimits();
  }

  showLess() {
    let tmpList = this.datas.reverse().splice(this.offsetSize);
    this.datas = tmpList.reverse();
    this.offset = this.offset > 0 ? this.offset - 1 : 0;
    this.checkedLimits();
  }

  checkedLimits() {
    //Set minnimal
    this.reachMin = false;
    if (this.datas.length <= this.offsetSize) {
      this.reachMin = true;
    }
    //Set maximal
    this.reachMax = true;
    if (Number.isInteger(this.datas.length / this.offsetSize)) {
      this.reachMax = false;
    }
    //Show footer or not
    this.showMoreOrLess = true;
    if (this.reachMin && this.reachMax) {
      this.showMoreOrLess = false;
    }
  }
}