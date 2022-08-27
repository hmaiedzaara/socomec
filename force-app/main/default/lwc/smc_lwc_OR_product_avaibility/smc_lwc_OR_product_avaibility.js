/**
 * @description       : This cmp is used to show the availability of a product in according to the quantity selected
 * @author            : Vincent RECASENS (Modis)
 * @group             :
 * @last modified on  : 11-25-2020
 * @last modified by  : Vincent RECASENS (Modis)
 * Modifications Log
 * Ver   Date         Author                     Modification
 * 1.0   10-26-2020   Vincent RECASENS (Modis)   Initial Version
 **/
import { LightningElement, track } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getProducts from "@salesforce/apex/SMC_AC_DORA_Management.getProducts";
import getProductAvaibility from "@salesforce/apex/SMC_AC_DORA_Management.getProductAvaibility";
import CHOOSE_HERE from "@salesforce/label/c.SMC_Choose_Here";
import PRODUCT_AVAILABILITY from "@salesforce/label/c.SMC_Product_Availability";
import PRODUCT_CODE from "@salesforce/label/c.SMC_Product_Code";
import PRODUCT_DESCRIPTION from "@salesforce/label/c.SMC_Product_Description";
import QUANTITY from "@salesforce/label/c.SMC_Quantity";
import AVAILABILITY from "@salesforce/label/c.SMC_Availability";
import QUANTITY_REFRESH from "@salesforce/label/c.SMC_OrderManagement_NewOrder_QuantityRefresh";
import ACTIONS from "@salesforce/label/c.SMC_Actions";
import REFRESH from "@salesforce/label/c.SMC_Refresh";
import NO_ALT_PDT from "@salesforce/label/c.SMC_No_Alternative_Product";
/* eslint-disable no-console */
/* eslint-disable no-alert */
/* eslint-disable-next-line @lwc/lwc/no-async-operation*/

export default class Smc_lwc_OR_product_avaibility extends LightningElement {
  //Labels
  chooseHereLabel = { CHOOSE_HERE };
  productAvailability = { PRODUCT_AVAILABILITY };
  productCodeLabel = { PRODUCT_CODE };
  productDescriptionLabel = { PRODUCT_DESCRIPTION };
  quantityLabel = { QUANTITY };
  availabilityLabel = { AVAILABILITY };
  quantityRefreshLabel = { QUANTITY_REFRESH };
  actionsLabel = { ACTIONS };
  refreshLabel = { REFRESH };

  //Variables
  @track inputValue = "";
  @track productsList = [];
  @track cdparList = [];
  @track listNotEmpty = false;
  // @track productListToShow = [];
  @track productSelected = false;
  @track specificProduct = {
    AMOUNT: "Nan",
    AVAILABLEDATE: null,
    CCY: null,
    CDPAR: "",
    CDSPS: null,
    DESCRIPTION: "",
    GROSSPRICE: null,
    QUANTITY: null,
    REQUESTEDDATE: null,
    UNITPRICE: null,
    discountpercent: null,
    isCommissioning: null,
    isProduct: null,
    isTotal: null,
    isTransport: null,
    linenumber: null,
    price: null
  };
  @track altPdts = [];
  @track emptyProduct = this.specificProduct;
  @track cdpar;
  @track quantity = 1;
  @track keepOriginal = false;

  connectedCallback() {
    this.cdparList = [];
    getProducts({ fromWhere: "pdtAvaibilityHPWoQt", cdcli: "" })
      .then(result => {
        if(JSON.parse(result).message !== null){
          return;
        }
        let elmt = JSON.parse(result).getItemCode.data;
        for (let key in elmt) {
          elmt[key].AMOUNT = parseFloat(elmt[key].AMOUNT);
          this.productsList.push(elmt[key]);
          this.cdparList.push(elmt[key].CDPAR);
        }
        if (this.productsList.length > 0) {
          this.listNotEmpty = true;
        }
      })
      .catch(error => {
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Error",
            message: JSON.stringify(error),
            variant: "error"
          })
        );
      });
  }

  //Get input value to find product
  handleProductSelected(event) {
    if (
      this.cdpar === null ||
      this.cdpar === undefined ||
      this.cdpar === "" ||
      this.cdpar !== event.detail
    ) {
      this.quantity = 1;
    }
    this.keepOriginal = false;
    this.cdpar = event.detail;
    let tmpProduct = JSON.parse(JSON.stringify(this.specificProduct));
    tmpProduct.AVAILABLEDATE = "";
    tmpProduct.CDPAR = this.cdpar;
    this.specificProduct = tmpProduct;
    this.sendToGoogleAnalytics();
    this.handleSearchProductCode();
  }

  //Manage quantity in tab
  handleChangeQuantity(event) {
    this.quantity = event.target.value;
    let tmpProduct = JSON.parse(JSON.stringify(this.specificProduct));
    tmpProduct.AVAILABLEDATE = "";
    this.specificProduct = tmpProduct;
  }

  //Callout to find product
  handleSearchProductCode() {
    //Callout : get ItemCode (with specific id) Item_Code_w_quantity_HP
    getProductAvaibility({
      fromWhere: "pdtAvaibilityHPWQt",
      cdcli: "",
      cdpar: this.cdpar,
      quantity: this.quantity
    })
      .then(result => {
        this.productSelected = false;
        let parsedResult = JSON.parse(result);
        if(parsedResult === null){
          this.dispatchEvent(
            new ShowToastEvent({
              title: "Warning",
              message: NO_ALT_PDT,
              variant: "warning"
            })
          );
          this.productSelected = false;
        }
        else if (parsedResult.getItemCodeWQt.error !== null && !parsedResult.getItemCodeWQt.error) {
          for(let key in parsedResult.getItemCodeWQt.data.productLabelNotAvailable){
            if(parsedResult.getItemCodeWQt.data.productLabelNotAvailable[key].value === parsedResult.getItemCodeWQt.data.AVAILABLEDATE){
              parsedResult.getItemCodeWQt.data.receivedAvailableDate = parsedResult.getItemCodeWQt.data.productLabelNotAvailable[key].label;
              break;
            }
          }
          if(parsedResult.getItemCodeWQt.data.receivedAvailableDate === null){
            parsedResult.getItemCodeWQt.data.receivedAvailableDate = parsedResult.getItemCodeWQt.data.AVAILABLEDATE;
          }
          this.specificProduct = parsedResult.getItemCodeWQt.data;
          this.productSelected = true;
          if(parsedResult.getItemCodeWQt.data.alternatives !== null && 
             parsedResult.getItemCodeWQt.data.alternatives.length > 0 && !this.keepOriginal){
            this.showAlternativePdt = true;
            this.altPdts = parsedResult.getItemCodeWQt.data.alternatives;
          }
        } else {
          this.specificProduct = this.emptyProduct;
          this.specificProduct.CDPAR = this.cdpar;
          this.dispatchEvent(
            new ShowToastEvent({
              title: "Warning",
              message: parsedResult.getItemCodeWQt.message,
              variant: "warning"
            })
          );
          this.productSelected = true;
        }
      })
      .catch(error => {
        this.productSelected = false;
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Error",
            message: JSON.stringify(error),
            variant: "error"
          })
        );
      });
  }

  handleAlternativeProduct(event){
    let detail = JSON.parse(JSON.stringify(event.detail));
    this.showAlternativePdt = false;
    this.altPdts = [];
    if(detail === 'keep original'){
      this.keepOriginal = true;
    }
    else if(detail === 'not interested'){
      this.productSelected = false;
      this.specificProduct = this.emptyProduct;
      this.cdpar = null;
      this.quantity = 0;
      this.keepOriginal = false;
    }
    else{
      this.keepOriginal = false;
      this.cdpar = detail;
      this.quantity = 1;
      this.handleSearchProductCode();
    }
  }

  sendToGoogleAnalytics() {
    // Send event to parent
    const selectedEvent = new CustomEvent("paselection", {
      detail: this.cdpar
    });
    this.dispatchEvent(selectedEvent);
  }
}