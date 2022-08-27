import { LightningElement, api, wire, track } from "lwc";
//Label
import CUSTOMER_INFORMATIONS from "@salesforce/label/c.SMC_Customer_Informations";
import STATISTICS from "@salesforce/label/c.SMC_Statistics";
import DISCOUNT_PER_FAMILY from "@salesforce/label/c.SMC_Discount_Per_Family";
import DISCOUNT from "@salesforce/label/c.SMC_Discount";
import PRICE_LIST from "@salesforce/label/c.SMC_Price_List";
import DISCOUNT_PER_ITEM from "@salesforce/label/c.SMC_Discount_Per_Item";
import EXPORT_EXCEL from "@salesforce/label/c.SMC_Export_Excel";
//DPHA - Add Discount per product line
import DISCOUNT_PER_PRODUCT_LINE from "@salesforce/label/c.SMC_Discount_Per_Product_Line";
//Method
import getAccount from "@salesforce/apex/SMC_AC_Follow_Customer.getAccount";
import getBusinessPlan from "@salesforce/apex/SMC_AC_Follow_Customer.getBusinessPlan";

import FORM_FACTOR from "@salesforce/client/formFactor";

export default class Smc_lwc_follow_customer extends LightningElement {
  //Custom Labels
  customerInformations = { CUSTOMER_INFORMATIONS };
  statistics = { STATISTICS };
  discountPerFamily = { DISCOUNT_PER_FAMILY };
  discount = { DISCOUNT };
  priceList = { PRICE_LIST };
  discountPerItem = { DISCOUNT_PER_ITEM };
  exportExcel = { EXPORT_EXCEL };
  //DPHA - Add Discount per product line
  dicountPerProductLine = { DISCOUNT_PER_PRODUCT_LINE };

  //Datas
  @api recordId;
  @api objectApiName;
  @api showStat;
  // @track columnStat;
  // @track dataStat;
  @api showDiscount;
  // @track columnDiscount;
  // @track dataDiscount;
  @api showPrice;
  // @track columnPrice;
  // @track dataPrice;
  @api showDiscountNew;
  @api showPriceNew;
  @api showDiscountPI;
  @track columnDiscountPerItem;
  @track dataDiscountPerItem;
  @track record;
  @track error;
  @track currentAccField;
  //DPHA - Add Discount per product line
  @api showDiscountPerProductLine;

  //For Xlsx formatter
  @track xlsHeader = []; // store all the headers of the the tables
  @track workSheetNameList = []; // store all the sheets name of the the tables
  @track xlsData = []; // store all tables data
  @track filename; // Name of the file
  @track toExport = false;

  @track smallFactor = false;

  connectedCallback() {
    if (FORM_FACTOR !== "Large") {
      this.smallFactor = true;
    }
    if (this.objectApiName === "Account") {
      getAccount({ recordId: this.recordId })
        .then(result => {
          this.record = result;
          this.accountId = result.Id;
          this.filename = result.Name + ".xlsx";
        })
        .catch(error => {
          console.log(JSON.stringify(error));
        });
      // this.currentAccField = [ID_FIELD, NAME_FIELD];
    } else if (this.objectApiName === "Business Plan") {
      getBusinessPlan({ recordId: this.recordId })
        .then(result => {
          this.record = result;
          this.accountId = result.Id;
          this.filename = result.Name + ".xlsx";
        })
        .catch(error => {
          console.log(JSON.stringify(error));
        });
    }
  }

  // renderedCallback(){
  //   setTimeout(() => {
  //     this.template.querySelector("lightning-datatable_table").style = "width:100%!important; table-layout:auto!important;";
  //   }, 100);
  // }

  get accId() {
    return this.accountId;
  }

  get xlsHeaderGetter() {
    return this.xlsHeader;
  }
  get filenameGetter() {
    return this.filename;
  }
  get workSheetNameListGetter() {
    return this.workSheetNameList;
  }
  get xlsDataGetter() {
    return this.xlsData;
  }

  handleLoadXlsx(event) {
    this.toExport = true;
  }

  //Stats
  handleStat(event) {
    // this.toExport = false;
    // this.columnStat = event.detail.columns;
    // this.dataStat = event.detail.datas;
    this.xlsFormatter(event.detail.columns, event.detail.datas, STATISTICS);
  }

  //Discount
  handleDiscount(event) {
    // this.toExport = false;
    // this.columnDiscount = event.detail.columns;
    // this.dataDiscount = event.detail.datas;
    this.xlsFormatter(event.detail.columns, event.detail.datas, DISCOUNT);
  }

  //Net Price
  handlePrice(event) {
    // this.toExport = false;
    // this.columnPrice = event.detail.columns;
    // this.dataPrice = event.detail.datas;
    this.xlsFormatter(event.detail.columns, event.detail.datas, PRICE_LIST);
  }

  //Discount (New)
  handleDiscountNew(event) {
    // this.toExport = false;
    // this.columnDiscountNew = event.detail.columns;
    // this.dataDiscountNew = event.detail.datas;
    this.xlsFormatter(
      event.detail.columns,
      event.detail.datas,
      DISCOUNT
    );
  }

  //Net Price (New)
  handlePriceNew(event) {
    // this.toExport = false;
    // this.columnPrice = event.detail.columns;
    // this.dataPrice = event.detail.datas;
    this.xlsFormatter(
      event.detail.columns,
      event.detail.datas,
      PRICE_LIST
    );
  }

  //Discount Per Item
  handleDiscountPerItem(event) {
    // this.toExport = false;
    this.columnDiscountPerItem = event.detail.columns;
    this.dataDiscountPerItem = event.detail.datas;
    this.xlsFormatter(
      this.columnDiscountPerItem,
      this.dataDiscountPerItem,
      DISCOUNT_PER_ITEM
    );
  }

  //DPHA - Discount Per Product Line
  handleDiscountPerProductLine(event) {
    this.xlsFormatter(
      event.detail.columns,
      event.detail.datas,
      DISCOUNT_PER_PRODUCT_LINE
    );
  }

  // formating the data to send as input to  xlsxMain component
  xlsFormatter(column, data, sheetName) {
    this.workSheetNameList.push(sheetName);
    this.xlsHeader.push(column);
    this.xlsData.push(data);
  }

  // calling the download function from xlsxMain.js
  download() {
    this.template.querySelector("c-smc_lwc_utils_export_to_excel").download();
  }
}