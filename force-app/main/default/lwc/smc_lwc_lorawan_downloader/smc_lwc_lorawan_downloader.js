import { LightningElement, api, track } from "lwc";
import FORM_FACTOR from "@salesforce/client/formFactor";
//Labels
import F_CLIENT from "@salesforce/label/c.SMC_CLIENT";
import F_NKE from "@salesforce/label/c.SMC_NKE";
//Methods Apex
import callApex from "@salesforce/apex/SMC_AC_LoraWan_IOT_Keys.manageLoRaWanCalloutAndPrintDatas";

export default class Smc_lwc_lorawan_downloader extends LightningElement {
  //Inputs
  @api format;
  @api requestid;
  @api useremail;
  @api deveuis;

  //Variables
  @track searching = true;
  @track responsiveDatable = "";
  @track responseFromApex;
  @track columns = [{ label: "DevEUI", fieldName: "devEUI" }];
  //Tables
  @track formatContainsCLIENT = false;
  @track formatContainsNKE = false;
  @track clientHasLine = false;
  @track clientHasInvalidLine = false;
  @track columnsClient = [];
  @track datasClient = [];
  @track datasClientInvalid = [];
  @track nkeHasLine = false;
  @track nkeHasInvalidLine = false;
  @track datasNke = "";
  @track datasNkeInvalid = "";
  //Export
  @track filenameCsv = ""; // Name of the file CSV
  @track filenameTxt = ""; // Name of the file TXT

  //Methods
  connectedCallback() {
    if (FORM_FACTOR !== "Large") {
      this.responsiveDatable = "slds-max-medium-table_stacked";
    }
    if (this.format)
      callApex({
        format: this.format,
        requestid: this.requestid,
        useremail: this.useremail,
        deveuis: this.deveuis
      })
        .then(result => {
          if (result !== null) {
            this.responseFromApex = result;
            this.searching = false;
            this.manageResponse();
          }
        })
        .catch(error => {
          this.error += JSON.stringify(error) + "\n";
          this.searching = false;
          console.log("error", this.error);
        });
  }

  manageResponse() {
    let responseApex = JSON.parse(JSON.stringify(this.responseFromApex));
    //Format contains CLIENT
    if (this.format === F_CLIENT || this.format === F_CLIENT + "_" + F_NKE) {
      this.formatContainsCLIENT = true;
      this.filenameCsv = responseApex.responseClientFileName;
      if (responseApex.responseClient.result.length > 0) {
        this.clientHasLine = true;
        this.columnsClient = responseApex.responseClientColumn;
        this.datasClient = responseApex.responseClient.result;
      }
      if (responseApex.responseClientInvalidDevEUI.length > 0) {
        this.clientHasInvalidLine = true;
        this.datasClientInvalid = responseApex.responseClientInvalidDevEUI;
      }
    }

    //Format contains NKE
    if (this.format === F_NKE || this.format === (F_CLIENT + "_" + F_NKE)) {
      this.formatContainsNKE = true;
      this.filenameTxt = responseApex.responseNkeFileName;
      if (
        responseApex.responseNkeToPrint != null &&
        responseApex.responseNkeToPrint != ""
      ) {
        this.nkeHasLine = true;
        this.datasNke =
          responseApex.responseNkeColumn + responseApex.responseNkeToPrint;
      }
      if (responseApex.responseNkeInvalidDevEUI.length > 0) {
        this.nkeHasInvalidLine = true;
        this.datasNkeInvalid = responseApex.responseNkeInvalidDevEUI;
      }
    }
  }

  handleDownloadClientLine() {
    let csv = this.buildClientCSV(this.columnsClient, this.datasClient);
    this.downloadCSV(csv);
  }

  handleDownloadClientInvalidLine() {
    let csv = this.buildInvalidLine(this.columns, this.datasClientInvalid);
    this.downloadCSV(csv);
  }

  handleDownloadNkeLine() {
    this.downloadTXT(this.datasNke);
  }

  handleDownloadNkeInvalidLine() {
    let txt = this.buildInvalidLine(this.columns, this.datasNkeInvalid);
    this.downloadTXT(txt);
  }

  buildClientCSV(column, data) {
    //Build CSV colmumn
    let itemListApiName = [];
    let finalCSVString = "";
    column.forEach(item => {
      finalCSVString += item.label + ";";
      itemListApiName.push({ name: item.fieldName });
    });
    finalCSVString = finalCSVString.slice(0, -1) + "\n";

    //Build CSV datas
    data.forEach((item, index) => {
      itemListApiName.forEach(selectedRow => {
        finalCSVString += item[selectedRow.name] + ";";
      });
      finalCSVString = finalCSVString.slice(0, -1) + "\n";
    });
    finalCSVString = finalCSVString.slice(0, -1);
    return finalCSVString;
  }

  buildInvalidLine(column, data) {
    //Build CSV colmumn
    let itemListApiName = [];
    let finalCSVString = "";
    column.forEach(item => {
      finalCSVString += item.label + ";";
      itemListApiName.push({ name: item.fieldName });
    });
    finalCSVString = finalCSVString.slice(0, -1) + "\n";

    //Build CSV datas
    data.forEach(item => {
      finalCSVString += item + "\n";
    });
    finalCSVString = finalCSVString.slice(0, -2);
    return finalCSVString;
  }

  //download a file .csv
  downloadCSV(text) {
    //Dowload CSV
    // let element = this.template.querySelector("a");
    let element = document.createElement("a");
    element.setAttribute(
      "href",
      "data:text/csv;charset=utf-8," + encodeURIComponent(text)
    );
    element.setAttribute("download", this.filenameCsv);

    element.style.display = "none";
    document.body.appendChild(element);
    element.click();
  }

  downloadTXT(text) {
    // let element = this.template.querySelector("a");
    let element = document.createElement("a");
    console.log('text', text);
    element.setAttribute(
      "href",
      "data:text/plain;charset=utf-8," + encodeURIComponent(text)
    );
    element.setAttribute("download", this.filenameTxt);

    element.style.display = "none";
    document.body.appendChild(element);
    console.log('element', JSON.parse(JSON.stringify(element)));

    element.click();
  }
}