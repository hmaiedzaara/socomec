import { LightningElement, track } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
//Labels
import CHOOSE_HERE from "@salesforce/label/c.SMC_Choose_Here";
import ORDER_LINES from "@salesforce/label/c.SMC_Order_Lines";
import SEARCH from "@salesforce/label/c.SMC_Search";
import PRODUCT_CODE from "@salesforce/label/c.SMC_Product_Code";
import LINE_NUMBER from "@salesforce/label/c.SMC_Line_Number";
import PRODUCT_DESCRIPTION from "@salesforce/label/c.SMC_Product_Description";
import AVAILABILITY from "@salesforce/label/c.SMC_Availability";
import UNIT_PRICE from "@salesforce/label/c.SMC_Unit_Price";
import QUANTITY from "@salesforce/label/c.SMC_Quantity";
import PRICE from "@salesforce/label/c.SMC_Price";
import DISCOUNT_PERCENT from "@salesforce/label/c.SMC_Discount_Percent";
import NET_PRICE from "@salesforce/label/c.SMC_Net_Price";
import ACTIONS from "@salesforce/label/c.SMC_Actions";
import RESET from "@salesforce/label/c.SMC_Reset";
import SEND_ORDER from "@salesforce/label/c.SMC_Send_Order";
import REFRESH_LINE_LEGEND from "@salesforce/label/c.SMC_DORA_RefreshOrderLine";
import QT_OVER_MAX from "@salesforce/label/c.SMC_Quantity_Over_Max";
import NO_ALT_PDT from "@salesforce/label/c.SMC_No_Alternative_Product";
import NOT_AVAILABLE_YET from "@salesforce/label/c.SMC_Not_Available_Yet";
//Method
import getTechnicalLines from "@salesforce/apex/SMC_AC_DORA_Management.getTechnicalLines";
import getUserNetPricePermission from "@salesforce/apex/SMC_AC_DORA_Management.getUserNetPricePermission";
import getTemporaryOrderInCache from "@salesforce/apex/SMC_AC_DORA_Management.getTemporaryOrderInCache";
import saveTemporaryOrderInCache from "@salesforce/apex/SMC_AC_DORA_Management.saveTemporaryOrderInCache";
import clearTemporaryOrderInCache from "@salesforce/apex/SMC_AC_DORA_Management.clearTemporaryOrderInCache";
import getProducts from "@salesforce/apex/SMC_AC_DORA_Management.getProducts";
import getProductAvaibility from "@salesforce/apex/SMC_AC_DORA_Management.getProductAvaibility";
import postSendOrder from "@salesforce/apex/SMC_AC_DORA_Management.postSendOrder";

export default class Smc_lwc_OR_neworder extends LightningElement {
  //Label
  chooseHereLabel = { CHOOSE_HERE };
  orderLinesLabel = { ORDER_LINES };
  searchLabel = { SEARCH };
  productCodeLabel = { PRODUCT_CODE };
  lineNumberLabel = { LINE_NUMBER };
  productDescriptionLabel = { PRODUCT_DESCRIPTION };
  availabilityLabel = { AVAILABILITY };
  unitPriceLabel = { UNIT_PRICE };
  quantityLabel = { QUANTITY };
  priceLabel = { PRICE };
  discountPercentLabel = { DISCOUNT_PERCENT };
  netPriceLabel = { NET_PRICE };
  actionsLabel = { ACTIONS };
  resetLabel = { RESET };
  sendOrderLabel = { SEND_ORDER };
  refreshLineLegend = { REFRESH_LINE_LEGEND };
  qtOverMaxLabelMessage = { QT_OVER_MAX };

  //Tech variables
  @track idxBackground;
  @track haveNetPricePermission = false;
  @track haveOnlyOneAccount = false;
  //Cache
  @track isLoad = false;
  @track genralCacheInfos;
  //Variables
  @track accounts = [];
  @track specificAccount;
  @track cdcli;
  @track accountIsSelected = false;
  @track specificAddress;
  @track addressIsSelected = false;
  @track custref;
  @track contactname;
  @track contactphone;
  @track requestedDeliveryDate;
  @track preftime;
  @track taillift;
  @track note;
  @track searchedProduct;
  @track isAvaiblable = false;
  @track productIsSelected = false;
  @track cdpar;
  // @track refreshLine = true;
  @track productsList = [];
  @track cdparList = [];
  @track showAlternativePdt = false;
  @track keepOriginalProduct = false;
  @track altPdts = [];
  // @track productListToShow = [];
  @track listNotEmpty = false;
  @track lastLineNumber = 0;
  @track orderLines = [];
  @track sendOrderLines = [];
  @track technicalLines = [];
  @track transportcode;
  @track transportline;
  @track commissioningcode;
  @track commissioningline;

  /* To modify when TR and Comm will be get from WS : callout TR and Comm to fill "orderLines" */
  connectedCallback() {
    this.getCacheInformations();
    // this.setTechnicalLines(true);
  }
  /* To modify when TR and Comm will be get from WS : callout TR and Comm to fill "orderLines" */

  /* GETTER METHODS */
  get checkBackground() {
    ++this.idxBackground;
    if (!Number.isInteger(this.idxBackground / 2)) {
      return "slds-border_bottom line-hover ligth-background";
    } else {
      return "slds-border_bottom line-hover alternative-ligth-background";
    }
  }
  get testRequestedDeliveryDate() {
    return this.requestedDeliveryDate;
  }

  /* SETTER METHODS */
  setTechnicalLines(init) {
    this.technicalLines = [];
    getTechnicalLines({})
      .then(result => {
        //Transport
        let transportElmt;
        let transportKey = [];
        let transportMap = new Map();
        //Commissionning
        let commissionningElmt;
        let commissionningKey = [];
        let commissionningMap = new Map();
        //Total
        let totalElmt;
        for (let key in result) {
          if (key === "TOTAL") {
            totalElmt = {
              CDPAR: [{ label: result[key], value: key }],
              DESCRIPTION: result[key],
              NETPRICE: 0,
              CCY: "EUR",
              isProduct: false,
              isTransport: false,
              isCommissioning: false,
              isTotal: true,
              linenumber: 9
            };
          } else if (key.startsWith("STR")) {
            transportKey.push(key);
            transportMap.set(key, result[key]);
          } else if (key.startsWith("MI")) {
            commissionningKey.push(key);
            commissionningMap.set(key, result[key]);
          }
        }
        //Sort transport
        transportKey.sort();
        for (let key in transportKey) {
          if (transportElmt !== undefined && transportElmt !== null) {
            transportElmt.CDPAR.push({
              label: transportMap.get(transportKey[key]),
              value: transportKey[key]
            });
          } else {
            transportElmt = {
              CDPAR: [
                {
                  label: transportMap.get(transportKey[key]),
                  value: transportKey[key]
                }
              ],
              CDSPS: "",
              DESCRIPTION: "N/A",
              AVAILABLEDATE: "N/A",
              GROSSPRICE: 0,
              price: 0,
              NETPRICE: 0,
              QUANTITY: 0,
              discountpercent: "N/A",
              CCY: "",
              linenumber: 3,
              isProduct: false,
              isTransport: true,
              isCommissioning: false,
              isTotal: false
            };
          }
        }
        transportElmt.DESCRIPTION = transportElmt.CDPAR[0].label;
        transportElmt.CDSPS = transportElmt.CDPAR[0].value;
        //Sort commissionnig
        commissionningKey.sort();
        for (let key in commissionningKey) {
          if (commissionningElmt !== undefined && commissionningElmt !== null) {
            commissionningElmt.CDPAR.push({
              label: commissionningMap.get(commissionningKey[key]),
              value: commissionningKey[key]
            });
          } else {
            commissionningElmt = {
              CDPAR: [
                {
                  label: commissionningMap.get(commissionningKey[key]),
                  value: commissionningKey[key]
                }
              ],
              CDSPS: "",
              DESCRIPTION: "N/A",
              AVAILABLEDATE: "N/A",
              GROSSPRICE: 0,
              price: 0,
              NETPRICE: 0,
              QUANTITY: 0,
              discountpercent: "N/A",
              CCY: "",
              linenumber: 6,
              isProduct: false,
              isTransport: false,
              isCommissioning: true,
              isTotal: false
            };
          }
        }
        commissionningElmt.DESCRIPTION = commissionningElmt.CDPAR[0].label;
        commissionningElmt.CDSPS = commissionningElmt.CDPAR[0].value;
        //Set technical lines
        this.technicalLines.push(transportElmt);
        this.technicalLines.push(commissionningElmt);
        this.technicalLines.push(totalElmt);

        //Set currency if not init
        if (!init) {
          this.setCurrencyOnTechnicalLine();
        }
        else{
          this.orderLines = this.technicalLines;
          this.isLoad = true;
        }
      })
      .catch(error => {
        this.isLoad = true;
        this.dispatchEvent(
          new ShowToastEvent({
            title: "setTechnicalLines Error",
            message: error,
            variant: "error"
          })
        );
      });
  }
  setCurrencyOnTechnicalLine() {
    let tmpTechnical = JSON.parse(JSON.stringify(this.technicalLines));
    let ccy = JSON.parse(JSON.stringify(this.specificAccount)).CCY;
    this.technicalLines = [];
    this.orderLines = [];
    for (let key in tmpTechnical) {
      tmpTechnical[key].CCY = ccy;
    }
    this.technicalLines = tmpTechnical;
    this.orderLines = tmpTechnical;
    this.saveInformationsInCache();
    this.isLoad = true;
  }

  /* MANAGE CACHE INFORMATIONS */
  getCacheInformations(){
    getTemporaryOrderInCache({})
    .then(result => {
      if(result !== null && result !== undefined && result !== ''){
        this.setInformationsFromCache(result);
      }
      else{
        this.getNetPricePermission();
        this.setTechnicalLines(true);
      }
    })
    .catch(error => {
      this.isLoad = true;
      this.dispatchEvent(
        new ShowToastEvent({
          title: "Cache error",
          message: error,
          variant: "error"
        })
      );
    });
  }
  setInformationsFromCache(cacheInformations){
    let infos = JSON.parse(cacheInformations);
    this.haveNetPricePermission = infos.userHasPermissionToOverrideNetPrice;
    this.cdcli = infos.cdcli;
    this.specificAccount = infos.specificAccount;
    if(this.specificAccount !== null && this.specificAccount != undefined){
      this.accountIsSelected = true;
    }
    this.custref = infos.custref;
    this.contactname = infos.contactname;
    this.contactphone = infos.contactphone;
    this.requestedDeliveryDate = infos.requestedDeliveryDate;
    this.preftime = infos.preftime;
    if(infos.specificAddress !== null && infos.specificAddress !== undefined){
      this.specificAddress = infos.specificAddress;
    }
    else{
      this.specificAddress = null;
    }
    this.taillift = infos.taillift;
    this.note = infos.note;
    this.orderLines = infos.rows;
    //General infos
    this.genralCacheInfos = {
      cdcli: this.cdcli, 
      specificAccount: this.specificAccount, 
      custref: this.custref,
      contactname: this.contactname,
      contactphone: this.contactphone,
      requestedDeliveryDate: this.requestedDeliveryDate,
      preftime: this.preftime,
      specificAddress: this.specificAddress,
      taillift: this.taillift,
      note: this.note
    };
    this.isLoad = true;
    // if(infos.rows === null || infos.rows === undefined){
      this.getProductsList();
    // }
    if(this.orderLines !== null && this.orderLines !== undefined){
      this.productIsSelected = true;
    }
  }
  saveInformationsInCache(){
    let infosToCache = {
      userHasPermissionToOverrideNetPrice: this.haveNetPricePermission,
      cdcli: this.cdcli,
      specificAccount: this.specificAccount,
      custref: this.custref,
      contactname: this.contactname,
      contactphone: this.contactphone,
      requestedDeliveryDate: this.requestedDeliveryDate,
      preftime: this.preftime,
      taillift: (this.taillift === 'yes' ? true : false),
      specificAddress: this.specificAddress,
      note: this.note,
      rows: this.orderLines
    };
    saveTemporaryOrderInCache({serializedOrder: JSON.stringify(infosToCache)})
    .catch(error => {
      this.dispatchEvent(
        new ShowToastEvent({
          title: "saveTemporaryOrderInCache Error",
          message: error,
          variant: "error"
        })
      );
    });
  }
  clearCacheInfos(){
    clearTemporaryOrderInCache({})
    .then (result => {
      this.dispatchEvent(new CustomEvent("refreshview"));
    })
    .catch(error => {
      this.dispatchEvent(
        new ShowToastEvent({
          title: "clearTemporaryOrderInCache Error",
          message: error,
          variant: "error"
        })
      );
    });
  }

  /* HANDLER - EVENTS FROM CHILDS COMPONENTS */
  handleAccountSelected(event) {
    this.specificAccount = event.detail;
    this.cdcli = JSON.parse(JSON.stringify(this.specificAccount)).CDCLI;
    this.accountIsSelected = true;
    this.setCurrencyOnTechnicalLine();
    this.getProductsList();
  }
  handleContactNameSelected(event) {
    this.contactname = event.detail;
    this.saveInformationsInCache();
  }
  handleContactPhoneSelected(event) {
    this.contactphone = event.detail;
    this.saveInformationsInCache();
  }
  handleCustRefSelected(event) {
    this.custref = event.detail;
    this.saveInformationsInCache();
  }
  handleRequestedDeliveryDateValueSelected(event) {
    this.requestedDeliveryDate = event.detail;
    let tmpOrderLines = JSON.parse(JSON.stringify(this.orderLines));
    this.orderLines = [];
    this.orderLines = tmpOrderLines;
    this.saveInformationsInCache();
  }
  handlePreftimeSelected(event) {
    this.preftime = JSON.parse(JSON.stringify(event.detail));
    this.saveInformationsInCache();
  }
  handleAddressSelected(event) {
    this.specificAddress = event.detail;
    this.addressIsSelected = true;
    this.saveInformationsInCache();
  }
  handleTailliftSelected(event) {
    this.taillift = event.detail;
    this.saveInformationsInCache();
  }
  handleNoteSelected(event) {
    this.note = JSON.parse(JSON.stringify(event.detail));
    this.saveInformationsInCache();
  }
  handleSearchProductCode(event) {
    this.cdpar = event.detail;
    this.keepOriginalProduct = false;
    this.addProduct();
  }  
  handleAlternativeProduct(event){
    let detail = JSON.parse(JSON.stringify(event.detail));
    this.showAlternativePdt = false;
    this.altPdts = [];
    if(detail === 'keep original'){
      this.keepOriginalProduct = true;
      this.addProduct();
    }
    else if(detail === 'not interested'){
      this.keepOriginalProduct = false;
    }
    else{
      this.cdpar = detail;
      this.keepOriginalProduct = false;
      this.addProduct();
    }
  }
  handleLineModification(event) {
    let eventDetail = JSON.parse(JSON.stringify(event.detail));
    let elmts = JSON.parse(JSON.stringify(this.orderLines));
    for (let key in elmts) {
      if (eventDetail.line.linenumber === elmts[key].linenumber) {
        elmts[key] = eventDetail.line;
        this.refreshOneLine(
          JSON.parse(JSON.stringify(eventDetail.line)),
          elmts[key],
          false,
          eventDetail.discountIsChanged
        );
      }
    }
  }
  handleAvailability(event) {
    this.isAvaiblable = event.detail;
  }
  handleRefreshLineFromOrderList(event) {
    let eventDetail = JSON.parse(JSON.stringify(event.detail));
    for (let key in this.orderLines) {
      if (eventDetail.linenumber === this.orderLines[key].linenumber) {
        if (eventDetail.isProduct) {
          this.getOneProductAvaibility(
            "RefreshOneLine",
            eventDetail
          );
          break;
        } else {
          this.refreshOneLine(
            eventDetail,
            JSON.parse(JSON.stringify(this.orderLines[key])),
            true,
            false
          );
        }
      }
    }
  }
  handleLineDeletion(event) {
    this.lastLineNumber -= 3;
    let tmpOrderLines = JSON.parse(JSON.stringify(this.orderLines));
    this.orderLines = [];
    let lineIsSuppress = false;
    for (let key in tmpOrderLines) {
      if (tmpOrderLines[key].isProduct) {
        if (
          event.detail.linenumber !== tmpOrderLines[key].linenumber &&
          !lineIsSuppress
        ) {
          this.orderLines.push(tmpOrderLines[key]);
        } else if (
          event.detail.linenumber !== tmpOrderLines[key].linenumber &&
          lineIsSuppress
        ) {
          this.orderLines.push(tmpOrderLines[key]);
          this.orderLines[this.orderLines.length - 1].linenumber =
            this.orderLines[this.orderLines.length - 1].linenumber - 3;
        } else {
          lineIsSuppress = true;
        }
      } else if (!tmpOrderLines[key].isProduct && !tmpOrderLines[key].isTotal) {
        tmpOrderLines[key].linenumber = tmpOrderLines[key].linenumber - 3;
        this.orderLines.push(tmpOrderLines[key]);
      } else {
        this.orderLines.push(tmpOrderLines[key]);
      }
    }
    this.refreshTotal();
  }
  handleResetOrder() {
    // Refresh the view of the data
    this.clearCacheInfos();
  }
  handleSendOrder() {
    //Clean the list before send it
    this.sendOrderLines = [];
    let tmpOrderLines = JSON.parse(JSON.stringify(this.orderLines));
    for (let key in tmpOrderLines) {
      if (tmpOrderLines[key].price === "") {
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Warning",
            message:
              "Some lines are not refreshed. Please refresh all product lines before send your order.",
            variant: "warning"
          })
        );
        this.sendOrderLines = [];
        break;
      } else if (
        this.requestedDeliveryDate === undefined ||
        this.requestedDeliveryDate === null ||
        this.requestedDeliveryDate === ""
      ) {
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Warning",
            message: "Please enter a requested date before send the order.",
            variant: "warning"
          })
        );
        this.sendOrderLines = [];
        break;
      } else if (tmpOrderLines[key].isProduct) {
        //This line
        let tabAvailableDateForThisLine = tmpOrderLines[key].AVAILABLEDATE.split('-');
        let availableDateForThisLine = new Date();
        availableDateForThisLine.setFullYear(tabAvailableDateForThisLine[0]);
        availableDateForThisLine.setMonth(tabAvailableDateForThisLine[1]);
        availableDateForThisLine.setDate(tabAvailableDateForThisLine[2]);
        //Requested date
        let tabRequestedDateForThisLine = this.requestedDeliveryDate.split('-');
        let requestedDateForThisLine = new Date();
        requestedDateForThisLine.setFullYear(tabRequestedDateForThisLine[0]);
        requestedDateForThisLine.setMonth(tabRequestedDateForThisLine[1]);
        requestedDateForThisLine.setDate(tabRequestedDateForThisLine[2]);
        //Set requested line on the line
        if(availableDateForThisLine > requestedDateForThisLine){
          tmpOrderLines[key].REQUESTEDDATE = tmpOrderLines[key].AVAILABLEDATE;
        }
        else{
          tmpOrderLines[key].REQUESTEDDATE = this.requestedDeliveryDate;
        }
        //Add line to the list
        this.sendOrderLines.push(tmpOrderLines[key]);
      } else if (
        tmpOrderLines[key].isTransport ||
        tmpOrderLines[key].isCommissioning
      ) {
        tmpOrderLines[key].CDPAR = tmpOrderLines[key].CDSPS;
        tmpOrderLines[key].CDSPS = tmpOrderLines[key].CDSPS;
        tmpOrderLines[key].discountpercent = 0;
        if (
          tmpOrderLines[key].QUANTITY !== "N/A" &&
          tmpOrderLines[key].QUANTITY !== 0 &&
          tmpOrderLines[key].QUANTITY != "" &&
          tmpOrderLines[key].QUANTITY !== null &&
          tmpOrderLines[key].QUANTITY !== undefined
        ) {
          this.sendOrderLines.push(tmpOrderLines[key]);
        }
      }
    }

    if (this.sendOrderLines.length > 0) {
      this.sendOrder();
    }
  }

  /* METHODS FOR PAGE */
  addProduct(){
    let elmts = JSON.parse(JSON.stringify(this.productsList));
    if (this.cdpar !== undefined && this.cdpar !== "") {
      for (let key in elmts) {
        if (this.cdpar === elmts[key].CDPAR) {
          this.productIsSelected = true;
          this.getOneProductAvaibility("AddToOrder", elmts[key]);
          break;
        }
      }
    } else {
      this.dispatchEvent(
        new ShowToastEvent({
          title: "Warning",
          message: "There is an error during the product selection.",
          variant: "warning"
        })
      );
    }
  }
  sortLineAfterAddToOrder(result) {
    //Add new line to the list
    this.lastLineNumber += 3;
    let tmpOrderLines = JSON.parse(JSON.stringify(this.orderLines));
    this.orderLines = [];
    let newLine = JSON.parse(result).getItemCodeWQt.data;
    //Set line
    newLine.isProduct = true;
    newLine.linenumber = this.lastLineNumber;
    newLine.QUANTITY =
      newLine.QUANTITY === undefined || newLine.QUANTITY === null
        ? 1
        : newLine.QUANTITY;
    if(newLine.NETPRICE !== null && newLine.NETPRICE != ''){
      newLine.netPriceFilledInWS = true;
      newLine.discountpercent = 'N/A';
      newLine.GROSSPRICE = null;
      newLine.price = newLine.NETPRICE * newLine.QUANTITY;
    }
    else{
      newLine.netPriceFilledInWS = false;
      newLine.discountpercent =
        newLine.discountpercent === undefined || newLine.discountpercent === null
          ? 0
          : newLine.discountpercent;
      let discount =
        1 - (newLine.discountpercent !== 0 ? newLine.discountpercent / 100 : 0);
      newLine.NETPRICE = newLine.GROSSPRICE * discount;
      newLine.price = newLine.NETPRICE * newLine.QUANTITY;
    }
    //Check product available date
    for(let key in newLine.productLabelNotAvailable){
      if(newLine.productLabelNotAvailable[key].value === newLine.AVAILABLEDATE){
        newLine.receivedAvailableDate = newLine.productLabelNotAvailable[key].label;
        break;
      }

    }
    if(newLine.receivedAvailableDate === null){
      newLine.receivedAvailableDate = newLine.AVAILABLEDATE;
    }
    
    //Add previous line
    let transportLine;
    let commLine;
    let totalLine;
    for (let key in tmpOrderLines) {
      //Set CDSPS
      if (
        (tmpOrderLines[key].isTransport ||
          tmpOrderLines[key].isCommissioning) &&
        tmpOrderLines[key].CDPAR.length === 1
      ) {
        tmpOrderLines[key].CDSPS = tmpOrderLines[key].CDPAR[0].value;
      }
      //get tehcnical lines
      if(tmpOrderLines[key].isProduct === null || 
         tmpOrderLines[key].isProduct === undefined || 
         !tmpOrderLines[key].isProduct){
        tmpOrderLines[key].linenumber = tmpOrderLines[key].linenumber + 3;
        if(tmpOrderLines[key].isTransport)
          transportLine = tmpOrderLines[key];
        if(tmpOrderLines[key].isCommissioning)
          commLine = tmpOrderLines[key];
        if(tmpOrderLines[key].isTotal)
          totalLine = tmpOrderLines[key];
      }
      else{
        this.orderLines.push(tmpOrderLines[key]);
      }
    }
    //end of sorting
    this.orderLines.push(newLine);
    this.orderLines.push(transportLine);
    this.orderLines.push(commLine);
    this.orderLines.push(totalLine);
    this.refreshTotal();
  }
  refreshOneLine(result, lineToRefresh, isARefresh, discountIsChanged) {
    let tmpOrderLines = JSON.parse(JSON.stringify(this.orderLines));
    this.orderLines = [];
    //Refresh line
    for (let key in tmpOrderLines) {
      let newLine = tmpOrderLines[key];
      if (newLine.linenumber === lineToRefresh.linenumber) {
        //Define line type and reset result
        result.linenumber = lineToRefresh.linenumber;
        result.isProduct = lineToRefresh.isProduct;
        result.isTransport = lineToRefresh.isTransport;
        result.isCommissioning = lineToRefresh.isCommissioning;
        result.isTotal = lineToRefresh.isTotal;
        result.netPriceFilledInWS = lineToRefresh.netPriceFilledInWS;
        result.QUANTITY = result.QUANTITY !== null ? 
          result.QUANTITY : lineToRefresh.QUANTITY;
        if(isARefresh){
          //Check net price filled in WS
          if(result.NETPRICE !== null && result.NETPRICE != ''){
            result.netPriceFilledInWS = true;
            result.discountpercent = 'N/A';
            result.GROSSPRICE = null;
          }
          else if(result.discountpercent === null){
            result.netPriceFilledInWS = false;
            result.discountpercent =
              lineToRefresh.discountpercent !== null
                ? lineToRefresh.discountpercent
                : 0;
          }

          if(newLine.AVAILABLEDATE.includes('999')){
            for(let key in newLine.productLabelNotAvailable){
              if(newLine.productLabelNotAvailable[key].value === newLine.AVAILABLEDATE){
                newLine.receivedAvailableDate = newLine.productLabelNotAvailable[key].label;
                break;
              }
        
            }
          }
          if(newLine.receivedAvailableDate === null){
            newLine.receivedAvailableDate = newLine.AVAILABLEDATE;
          }
        }
        //Set line
        newLine = result;
        //User has net price permission
        if(newLine.isProduct && 
          !newLine.netPriceFilledInWS && 
          this.haveNetPricePermission &&
          !discountIsChanged &&
           newLine.GROSSPRICE !== '' && newLine.GROSSPRICE !== null &&
           newLine.NETPRICE !== '' && newLine.NETPRICE !== null){
            newLine.discountpercent = 100 - (100.0 * newLine.NETPRICE / newLine.GROSSPRICE);
        }
        //User has not net price permission
        else if (newLine.isProduct &&
                 !newLine.netPriceFilledInWS){
            //Discount != 0
            if(newLine.discountpercent !== "" &&
               newLine.discountpercent !== 0){
              newLine.NETPRICE =
                newLine.GROSSPRICE !== ""
                  ? newLine.GROSSPRICE * (1 - newLine.discountpercent / 100.0)
                  : "";
            }
            //Discount == 0
            else{
              newLine.NETPRICE = newLine.GROSSPRICE;
            }
        }
        //Price
        newLine.price =
          newLine.NETPRICE !== ""
            ? newLine.NETPRICE * newLine.QUANTITY
            : "";
      }
      this.orderLines.push(newLine);
    }
    this.refreshTotal();
  }

  refreshTotal() {
    let total = 0;
    let resetTotal = false;
    let tmpOrderLines = JSON.parse(JSON.stringify(this.orderLines));
    this.orderLines = [];
    // Need to be done complety to be sure to add all net price to the total
    for (let key in tmpOrderLines) {
      if (tmpOrderLines[key].isProduct && tmpOrderLines[key].price !== "") {
        total += tmpOrderLines[key].price;
      } else if (
        tmpOrderLines[key].isProduct &&
        tmpOrderLines[key].price === ""
      ) {
        resetTotal = true;
        break;
      } else if (
        (tmpOrderLines[key].isTransport ||
          tmpOrderLines[key].isCommissioning) &&
        tmpOrderLines[key].QUANTITY !== null &&
        tmpOrderLines[key].QUANTITY !== undefined &&
        tmpOrderLines[key].QUANTITY !== "" &&
        tmpOrderLines[key].QUANTITY !== 0 &&
        tmpOrderLines[key].price !== ""
      ) {
        total += tmpOrderLines[key].price;
      } else if (
        (tmpOrderLines[key].isTransport ||
          tmpOrderLines[key].isCommissioning) &&
        tmpOrderLines[key].QUANTITY !== null &&
        tmpOrderLines[key].QUANTITY !== undefined &&
        tmpOrderLines[key].QUANTITY !== "" &&
        tmpOrderLines[key].QUANTITY !== 0 &&
        tmpOrderLines[key].price === ""
      ) {
        resetTotal = true;
        break;
      }
    }

    //Find the total line
    for (let key in tmpOrderLines) {
      if (tmpOrderLines[key].isTotal && !resetTotal) {
        tmpOrderLines[key].price = total;
      } else if (tmpOrderLines[key].isTotal && resetTotal) {
        tmpOrderLines[key].price = "";
      }
    }
    this.orderLines = tmpOrderLines;
    this.saveInformationsInCache();
  }

  /* SEND INFGORMATIONS TO GOOGLE ANALYTICS */
  sendToGoogleAnalytics(eventName) {
    if (eventName === "ordersending") {
      // Send event to parent
      const selectedEvent = new CustomEvent(eventName, {});
      this.dispatchEvent(selectedEvent);
    } else if (eventName === "productadded") {
      // Send event to parent
      const selectedEvent = new CustomEvent(eventName, {
        detail: this.cdpar
      });
      this.dispatchEvent(selectedEvent);
    }
  }

  /* CALL APEX */
  getNetPricePermission(){
    getUserNetPricePermission({})
    .then(result => {
      this.haveNetPricePermission = result;
    })
    .catch(error => {
      this.isLoad = true;
      this.dispatchEvent(
        new ShowToastEvent({
          title: "Get 'NetPrice' permission",
          message: error,
          variant: "error"
        })
      );
    });
  }
  getProductsList() {
    getProducts({ fromWhere: "pdtAvaibilityHPWoQt", cdcli: this.cdcli })
      .then(result => {
        if (!JSON.parse(result).getItemCode.error) {
          let elmt = JSON.parse(result).getItemCode.data;
          for (let key in elmt) {
            elmt[key].AMOUNT = parseFloat(elmt[key].AMOUNT);
            this.productsList.push(elmt[key]);
            this.cdparList.push(elmt[key].CDPAR);
          }
          if (this.productsList.length > 0) {
            this.listNotEmpty = true;
            if(this.orderLines === null || this.orderLines === undefined || this.orderLines === []){
              this.setCurrencyOnTechnicalLine();
            }
          }
        } else {
          this.dispatchEvent(
            new ShowToastEvent({
              title: "Warning",
              message: JSON.parse(result).getItemCode.message,
              variant: "warning"
            })
          );
        }
      })
      .catch(error => {
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Error (get products)",
            message: error,
            variant: "error"
          })
        );
      });
  }
  getOneProductAvaibility(identifier, product) {
    //Callout : get ItemCode (with specific id) Item_Code_w_quantity_HP
    let theQuantity = 1;
    if (
      product !== null &&
      product !== undefined &&
      product.QUANTITY !== null &&
      product.QUANTITY !== undefined
    ) {
      theQuantity = product.QUANTITY;
    }
    getProductAvaibility({
      fromWhere: "pdtAvaibilityNOWQt",
      cdcli: this.cdcli,
      cdpar: product.CDPAR,
      quantity: theQuantity
    })
      .then(result => {
        let parsedResult = JSON.parse(result);
        //check altProduct
        if(parsedResult === null){
          this.dispatchEvent(
            new ShowToastEvent({
              title: "Warning",
              message: NO_ALT_PDT,
              variant: "warning"
            })
          );
        }
        else if(parsedResult.getItemCodeWQt.error !== null && !parsedResult.getItemCodeWQt.error){
          if (identifier === "AddToOrder" && 
              !this.keepOriginalProduct && 
              parsedResult.getItemCodeWQt.data.alternatives !== null && 
              parsedResult.getItemCodeWQt.data.alternatives.length > 0) {
                this.showAlternativePdt = true;
                this.altPdts = parsedResult.getItemCodeWQt.data.alternatives;
          } else if (identifier === "AddToOrder" && 
                     (this.keepOriginalProduct ||
                     parsedResult.getItemCodeWQt.data.alternatives === null || 
                     parsedResult.getItemCodeWQt.data.alternatives.length === 0)) {
            this.sendToGoogleAnalytics("productadded");
            this.sortLineAfterAddToOrder(result, product);
          }
          else if (identifier === "RefreshOneLine") {
            this.refreshOneLine(
              parsedResult.getItemCodeWQt.data,
              product,
              true,
              false
            );
          }
        }
        else if(parsedResult.getItemCodeWQt.error && parsedResult.getItemCodeWQt.message.startsWith('For this quantity')){
          this.dispatchEvent(
            new ShowToastEvent({
              title: "Buying wholesale",
              message: parsedResult.getItemCodeWQt.message,
              variant: "warning"
            })
          );
        } else if(parsedResult.getItemCodeWQtAltPdt != null && parsedResult.getItemCodeWQtAltPdt.error !== null){
          if(parsedResult.getItemCodeWQtAltPdt.data.length > 0){
            this.showAlternativePdt = true;
            this.altPdts = parsedResult.getItemCodeWQtAltPdt.data;
          }
          else{
            this.dispatchEvent(
              new ShowToastEvent({
                title: "Warning",
                message: parsedResult.getItemCodeWQtAltPdt.message,
                variant: "warning"
              })
            );
          }
        } else {
          this.dispatchEvent(
            new ShowToastEvent({
              title: "Warning",
              message: parsedResult.getItemCodeWQt.message,
              variant: "warning"
            })
          );
        }
      })
      .catch(error => {
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Error (get product avaibility)",
            message: error,
            variant: "error"
          })
        );
      });
  }
  sendOrder() {
    let addressCodeSelected = "";
    let newaddress;
    let parsedAddress = JSON.parse(JSON.stringify(this.specificAddress));
    if(
      parsedAddress !== undefined &&
      parsedAddress !== null &&
      parsedAddress !== ""){
        if (parsedAddress.isNewAddress) {
          newaddress = { 
            COMPANYNAME: parsedAddress.COMPANYNAME,
            ADDRESS : parsedAddress.ADDRESS ,
            CITY: parsedAddress.CITY,
            ZIPCODE: parsedAddress.ZIPCODE,
            PROV: parsedAddress.PROV,
            COUNTRY: parsedAddress.COUNTRY
          }
          addressCodeSelected = 'NEW ADDRESS';
        }
        else{
          addressCodeSelected = JSON.parse(JSON.stringify(this.specificAddress))
            .ADDRESSCODE;
        }
    }
    for(let key in this.sendOrderLines){
      if(this.sendOrderLines[key].discountpercent === 'N/A'){
        this.sendOrderLines[key].discountpercent = 0;
      }
      if(this.sendOrderLines[key].NETPRICE === null){
        this.sendOrderLines[key].NETPRICE = this.sendOrderLines[key].GROSSPRICE;
      }
      if(this.sendOrderLines[key].GROSSPRICE === null){
        this.sendOrderLines[key].GROSSPRICE = this.sendOrderLines[key].NETPRICE;
      }
    }
    //Callout : post new order
    postSendOrder({
      fromWhere: "post_orderUpsert",
      cdord: "",
      cdcli: this.cdcli,
      custref: this.custref,
      contactname: this.contactname,
      contactphone: this.contactphone,
      requestedDate: this.requestedDeliveryDate,
      preftime: this.preftime,
      taillift: this.taillift,
      note: this.note,
      addresscode: addressCodeSelected,
      newaddress: JSON.stringify(newaddress),
      rows: JSON.stringify(this.sendOrderLines)
    })
      .then(result => {
        if (!JSON.parse(result).getPostResult.error) {
          this.dispatchEvent(
            new ShowToastEvent({
              title: "Order sent",
              message: JSON.parse(result).getPostResult.message,
              variant: "success"
            })
          );
          this.sendToGoogleAnalytics("ordersending");
        }else {
          this.dispatchEvent(
            new ShowToastEvent({
              title: "Error",
              message: JSON.parse(result).getPostResult.message,
              variant: "error"
            })
          );
        }
      })
      .catch(error => {
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Error",
            message: error,
            variant: "error"
          })
        );
      });
  }
}