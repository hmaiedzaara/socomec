import { LightningElement, api, track } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import { loadStyle } from 'lightning/platformResourceLoader';

import lwcdatatable from '@salesforce/resourceUrl/lwcdatatable';

import initialisation from "@salesforce/apex/SMC_AC_Follow_Customer.initialisation";

import NO_DATA_TO_SHOW from "@salesforce/label/c.SMC_No_Data_To_Show";
import EMPTY_SMART_CONF from "@salesforce/label/c.SMC_Empty_Smart_Conf";
import EXPORT_EXCEL from "@salesforce/label/c.SMC_Export_Excel";
// import OPEN_PDF from "@salesforce/label/c.SMC_Open_PDF";

import FORM_FACTOR from "@salesforce/client/formFactor";

export default class Smc_lwc_customer_informations extends NavigationMixin(
  LightningElement
) {
  //Data
  // @api recordid;
  @api account;
  @api informationtoget;
  @api recordidparent;
  @api keyfield;
  @track parseResult;
  @track datas = [];
  @track columns = [];
  @track isStatistics = false;
  @track isDiscount = false;
  @track isPrice = false;
  @track isDiscountNew = false;
  @track isPriceNew = false;
  @track isDiscountPI = false;
  //DPHA - Add Discount per product line
  isDiscountPerProductLine = false;

  //UI
  @track smartConfIsEmpty = false;
  emptySmartConf = { EMPTY_SMART_CONF };
  @track noResult = false;
  noResultLabel = { NO_DATA_TO_SHOW };
  @track scroller = "";
  @track responsiveDatable = "";
  @track notSearching = false;
  @track error = "";
  @track sortBy = "";
  @track sortDirection = "asc";

  @track smallFactor = false;
  exportExcel = { EXPORT_EXCEL };

  connectedCallback() {
    this.notSearching = false;
    if (FORM_FACTOR !== "Large") {
      this.responsiveDatable = "slds-max-medium-table_stacked zoom-percent";
    }
    this.init();
  }
  renderedCallback(){
    Promise.all([
        loadStyle(this, lwcdatatable)
    ])
    .catch(error => {
      console.log(JSON.stringify(error));
    });
  }

  /** INIT FUNCTION **/
  init() {
    initialisation({
      informationToGet: this.informationtoget,
      theAccount: this.account
    })
      .then(result => {
        this.parseResult = JSON.parse(result);
        this.isStatistics = this.parseResult.isStatistics;
        this.isDiscount = this.parseResult.isDiscount;
        this.isPrice = this.parseResult.isPrice;
        this.isDiscountNew = this.parseResult.isDiscountNew;
        this.isPriceNew = this.parseResult.isPriceNew;
        this.isDiscountPI = this.parseResult.isDiscountPI;
        //DPHA - Add Discount per product line
        this.isDiscountPerProductLine = this.parseResult.isDiscountPerProductLine;
        this.smartConfIsEmpty = this.parseResult.suffixSmartConfIsEmpty;
        for (let key in this.parseResult.datas) {
          if (this.parseResult.datas[key] !== undefined) {
            if (
              JSON.parse(JSON.stringify(this.parseResult.datas[key]))
                .effectiveDate != null &&
              parseInt(
                JSON.parse(JSON.stringify(this.parseResult.datas[key]))
                  .effectiveDate.split("T")[1]
                  .split(":")[0]
              ) > 21
            ) {
              let tabDate = JSON.parse(
                JSON.stringify(this.parseResult.datas[key])
              ).effectiveDate.split("T");
              let tabTime = tabDate[1].split(":");
              this.parseResult.datas[key].effectiveDate =
                tabDate[0] + "T20:" + tabTime[1] + ":" + tabTime[2];
            }
            if (
              JSON.parse(JSON.stringify(this.parseResult.datas[key]))
                .expirationDate != null &&
              parseInt(
                JSON.parse(JSON.stringify(this.parseResult.datas[key]))
                  .expirationDate.split("T")[1]
                  .split(":")[0]
              ) > 21
            ) {
              let tabDate = JSON.parse(
                JSON.stringify(this.parseResult.datas[key])
              ).effectiveDate.split("T");
              let tabTime = tabDate[1].split(":");
              this.parseResult.datas[key].effectiveDate =
                tabDate[0] + "T20:" + tabTime[1] + ":" + tabTime[2];
            }
            this.datas.push(this.parseResult.datas[key]);
          }
        }
        for (let key in this.parseResult.columns) {
          if (this.parseResult.columns[key] !== undefined) {
            this.columns.push(this.parseResult.columns[key]);
          }
        }

        //If there is no data
        if (this.datas === undefined || this.datas.length === 0) {
          this.noResult = true;
          // } else if (
          //   (this.datas.length > 2 && this.smallFactor) ||
          //   (this.datas.length > 10 && !this.smallFactor && !this.isStatistics) ||
          //   (this.datas.length > 5 && !this.smallFactor && this.isStatistics)
          // ) {
        } else if (
          (this.datas.length > 2 && this.smallFactor) ||
          (this.datas.length > 10 && !this.smallFactor)
        ) {
          this.scroller = "tabSizing tabSizingWidth";
          this.sendToInfosParent();
        } else {
          this.scroller = "tabSizingWidth";
          this.sendToInfosParent();
        }
        this.notSearching = true;
      })
      .catch(error => {
        this.error += JSON.stringify(error) + "\n";
        this.noResult = true;
        this.notSearching = true;
      });
  }

  updateColumnSorting(event) {
    let fieldName = event.detail.fieldName;
    let sortDirection = event.detail.sortDirection;
    //assign the values
    this.sortBy = fieldName;
    this.sortDirection = sortDirection;
    //call the custom sort method.
    this.sortData(fieldName, sortDirection);
  }

  //This sorting logic here is very simple. This will be useful only for text or number field.
  // You will need to implement custom logic for handling different types of field.
  sortData(fieldName, sortDirection) {
    // serialize the data before calling sort function
    let parseData = JSON.parse(JSON.stringify(this.datas));

    // Return the value stored in the field
    let keyValue = a => {
      return a[fieldName];
    };

    // cheking reverse direction
    let isReverse = sortDirection === "asc" ? 1 : -1;

    // sorting data
    parseData.sort((x, y) => {
      x = keyValue(x) ? keyValue(x) : ""; // handling null values
      y = keyValue(y) ? keyValue(y) : "";

      // sorting values based on direction
      return isReverse * ((x > y) - (y > x));
    });

    // set the sorted data to data table data
    this.datas = parseData;
  }

  sendToInfosParent() {
    let eventName = "";
    if (this.isStatistics) {
      eventName += "stat";
    }
    if (this.isDiscount) {
      eventName += "discount";
    }
    if (this.isPrice) {
      eventName += "price";
    }
    if (this.isDiscountNew) {
      eventName += "discountnew";
    }
    if (this.isPriceNew) {
      eventName += "pricenew";
    }
    if (this.isDiscountPI) {
      eventName += "discountperitem";
    }
    //DPHA - Add Discount per product line
    if (this.isDiscountPerProductLine) {
      eventName += "discountperproductline";
    }
    this.dispatchEvent(
      new CustomEvent(eventName, {
        detail: {
          columns: this.columns,
          datas: this.datas
        }
      })
    );
  }
}