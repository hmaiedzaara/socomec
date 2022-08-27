import { LightningElement, api, track } from "lwc";
import { NavigationMixin } from "lightning/navigation";

export default class Smc_lwc_tile_button_body extends NavigationMixin(
  LightningElement
) {
  @api element;

  @track isStandardPage = false;
  @track iconSizer = "";

  connectedCallback() {
    if (this.element.pageType === "standard__webPage") {
      this.isStandardPage = true;
    }
    if (this.element.needZoom) {
      this.iconSizer = "icon-size";
    }
  }

  navigateto() {
    const pageAttributes = {
      type: this.element.pageType,
      attributes: {
        name: this.element.pageReference
      }
    };
    this[NavigationMixin.Navigate](pageAttributes);
  }
}