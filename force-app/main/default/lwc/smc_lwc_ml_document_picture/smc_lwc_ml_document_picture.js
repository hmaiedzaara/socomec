import { LightningElement, api, track } from "lwc";
import checkUrl from "@salesforce/apex/SMC_AC_Marketing_Library.checkPictureUrl";
// import sendToGoogleAnalytic from "@salesforce/apex/SMC_AC_Marketing_Library.sendToGoogleAnalytic";
import NO_PICTURE_LABEL from "@salesforce/label/c.SMC_NoPicture_Path";
import NO_PICTURE from "@salesforce/resourceUrl/No_Picture";

export default class Smc_lwc_ML_document_picture extends LightningElement {
  @api defaulturl;
  @api url;
  @api documenttitle;
  @api documentid;

  @track checkedUrl;

  connectedCallback() {
    checkUrl({ url: this.url })
      .then(result => {
        if (result === NO_PICTURE_LABEL) {
          this.checkedUrl = NO_PICTURE;
        } else {
          this.checkedUrl = this.url;
        }
      })
      .catch(error => {
        console.log("error checkUrl(url : " + this.url, error);
        this.checkedUrl = NO_PICTURE;
      });
    // let tmp = this.url.split("/");
    // if (tmp[tmp.length - 1] === undefined || tmp[tmp.length - 1] === "null") {
    //   this.checkedUrl = NO_PICTURE;
    // } else {
    //   this.checkedUrl = this.url;
    // }
  }

  downloadDocument() {
    const selectedEvent = new CustomEvent("sendtoparentlwc", {
      detail: this.documenttitle
    });
    this.dispatchEvent(selectedEvent);
  }
}