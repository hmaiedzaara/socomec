import { LightningElement, api, track } from "lwc";
import getCaseFiles from "@salesforce/apex/SMC_AC_View_Files_Case.getCaseFiles";

export default class Smc_lwc_view_files_case extends LightningElement {
  @api recordId;

  @track showList = false;
  @track buttonShowList = "Show file list";
  @track filesExist = false;
  @track filesList;
  @track mapCaseNumberToFile;

  //Init
  connectedCallback() {
    getCaseFiles({ recordId: this.recordId })
      .then(result => {
        if (result) {
          this.filesList = result;
          this.filesExist = true;
        }
      })
      .catch(error => {
        this.error += error + "\n";
        console.log(JSON.parse(JSON.stringify(this.error)));
      });
  }

  toggleShowList() {
    this.showList = !this.showList;
    if (this.showList) {
      this.buttonShowList = "Hide file list";
    } else {
      this.buttonShowList = "Show file list";
    }
  }

  get caseNumberOfTheFile() {
    this.mapCaseNumberToFile = [];
    for (let key in this.filesList) {
      if (key !== undefined) {
        let fileObj = {
          CaseNumber: key.split("/")[0],
          Id: this.filesList[key].Id,
          Title: this.filesList[key].Title,
          FileExtension: this.filesList[key].FileExtension,
          ContentSize: this.filesList[key].ContentSize
        };
        this.mapCaseNumberToFile.push(fileObj);
      }
    }
    return this.mapCaseNumberToFile;
  }
}