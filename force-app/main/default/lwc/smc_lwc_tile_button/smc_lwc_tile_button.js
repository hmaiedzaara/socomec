import { LightningElement, api, track } from "lwc";
import getButtonInfo from "@salesforce/apex/SMC_AC_Tile_Button.getButtonInfo";
/* eslint-disable no-console */
/* eslint-disable no-alert */
/* eslint-disable-next-line @lwc/lwc/no-async-operation*/

export default class Smc_lwc_tile_button extends LightningElement {
  // Design attributes
  @api title;
  @api titleRename;

  @track titleIcon;
  @track listButtons;
  @track grid;
  @track columns;

  connectedCallback() {
    getButtonInfo({ selection: this.title })
      .then(result => {
        if (result) {
          this.listButtons = JSON.parse(result).listButtons;
          if (
            this.title === "My Products and Connectivity" ||
            this.title === "Connectivity and Activation"
          ) {
            this.title = "Connectivity & Activation";
            this.titleIcon = "fa fa-microchip fa-2x";
            this.columns =
              "slds-col slds-large-size_1-of-1 slds-medium-size_1-of-1 slds-size_1-of-1 products-connectivity";
          } else if (
            this.title === "Maintenance Services" ||
            this.title === "Services"
          ) {
            this.title = "Services";
            this.titleIcon = "fa fa-cog fa-2x";
            this.columns =
              "slds-col slds-large-size_1-of-1 slds-medium-size_1-of-1 slds-size_1-of-1 maintenance-service";
          } else if (this.title === "Help") {
            this.titleIcon = "fa fa-question fa-2x";
            this.columns =
              "slds-col slds-large-size_1-of-2 slds-medium-size_1-of-2 slds-size_1-of-1 help";
          }
        }
      })
      .catch(error => {
        console.log(JSON.parse(JSON.stringify(error)));
      });
  }
}