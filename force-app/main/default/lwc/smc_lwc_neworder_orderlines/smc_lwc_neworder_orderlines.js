import { LightningElement, api, track } from "lwc";
import REFRESH from "@salesforce/label/c.SMC_Refresh";
import DELETE from "@salesforce/label/c.SMC_Delete";
import NOT_AVAILABLE_YET from "@salesforce/label/c.SMC_Not_Available_Yet";
// import CHOOSE_HERE from "@salesforce/label/c.SMC_Choose_Here";

export default class Smc_lwc_neworder_orderlines extends LightningElement {
  @api line;
  @api havenetpricepermission = false;
  @api requesteddeliverydate = "";
  @track memoryequesteddeliverydate = null;
  @track haveOnlyOneCDPAR = false;
  @track deliverydatenotnull = false;
  @track deliverydatematch = false;
  @track isAvaiblable = false;
  @track waitingRefresh = true;
  
  @track previousIsDotDiscount = false;
  @track previousDiscount = 0;
  @track previousIsDotNetPrice = false;
  @track previousNetprice = 0;
  mapCharcodeToNumber =  new Map([
                                  [48,0],
                                  [49,1],
                                  [50,2],
                                  [51,3],
                                  [52,4],
                                  [53,5],
                                  [54,6],
                                  [55,7],
                                  [56,8],
                                  [57,9]
                                ]);

  //Label
  refreshLabel = { REFRESH };
  deleteLabel = { DELETE };
  // chooseHereLabel = { CHOOSE_HERE };

  connectedCallback() {
    this.memoryequesteddeliverydate = this.requesteddeliverydate;
    let trackedLineTmp = JSON.parse(JSON.stringify(this.line));
    //Set Description for multiple CDPAR (Transport and/or Commissionning)
    if (
      (trackedLineTmp.isTransport || trackedLineTmp.isCommissioning) &&
      trackedLineTmp.CDPAR.length === 1
    ) {
      trackedLineTmp.CDSPS = trackedLineTmp.CDPAR[0].value;
      trackedLineTmp.DESCRIPTION = trackedLineTmp.CDPAR[0].label;
      this.haveOnlyOneCDPAR = true;
    }
    if(trackedLineTmp.UNITPRICE !== undefined){
      trackedLineTmp.NETPRICE = trackedLineTmp.UNITPRICE
    }
    
    this.line = trackedLineTmp;
  }

  /* Set background */
  get checkBackground() {
    ++this.idxBackground;
    if (!Number.isInteger(this.idxBackground / 2)) {
      return "slds-border_bottom line-hover ligth-background";
    } else {
      return "slds-border_bottom line-hover alternative-ligth-background";
    }
  }

  get testdeliverydatenotnull() {
    //Check RequestedDateValue
    if (
      this.requesteddeliverydate !== undefined &&
      this.requesteddeliverydate !== null &&
      this.requesteddeliverydate !== ""
    ) {
      this.memoryequesteddeliverydate = (this.requesteddeliverydate != this.memoryequesteddeliverydate ? 
                                          this.requesteddeliverydate : this.memoryequesteddeliverydate);
      this.waitingRefresh = true;
      this.testdeliverydatematch();
      return true;
    }
    this.waitingRefresh = false;
    return false;
  }

  testdeliverydatematch() {
    let trackedLineTmp = JSON.parse(JSON.stringify(this.line));
    if (
      this.requesteddeliverydate !== undefined &&
      this.requesteddeliverydate !== null &&
      this.requesteddeliverydate !== "" && 
      trackedLineTmp.AVAILABLEDATE !== null && 
      trackedLineTmp.AVAILABLEDATE !== '' && 
      !trackedLineTmp.AVAILABLEDATE.includes('999')
    ) {
      let trackedLineDeliveryDate = Date.parse(trackedLineTmp.AVAILABLEDATE);
      let requestedDate = Date.parse(this.requesteddeliverydate);
      if (requestedDate >= trackedLineDeliveryDate) {
        this.isAvaiblable = true;
        trackedLineTmp.AVAILABLEDATE = this.requesteddeliverydate;
        trackedLineTmp.receivedAvailableDate = this.requesteddeliverydate;
        this.line = trackedLineTmp;
        this.sendAvailabilityToParent();
        return true;
      }
    }
    if(trackedLineTmp.AVAILABLEDATE.includes('999')){
      for(let key in trackedLineTmp.productLabelNotAvailable){
        if(trackedLineTmp.productLabelNotAvailable[key].value === trackedLineTmp.AVAILABLEDATE){
          trackedLineTmp.receivedAvailableDate = trackedLineTmp.productLabelNotAvailable[key].label;
          break;
        }
  
      }
    }
    this.line = trackedLineTmp;
    this.isAvaiblable = false;
    this.sendAvailabilityToParent();
    return false;
  }

  handleChangeDiscountKeyPress(event){
    //Check dot in number
    if(this.previousIsDotDiscount){
      event.target.value = this.previousDiscount + '.' + mapCharcodeToNumber.get(event.charCode);
      this.previousIsDotDiscount = false;
      this.previousDiscount = 0;
      this.handleChangeDiscount(event);
    }
    else{
      if(event.charCode === 46){
        this.previousIsDotDiscount = true;
        this.previousDiscount = event.target.value;
      }
      else{
        this.handleChangeDiscount(event);
      }
    }
  }
  handleChangeDiscountOnFocusOut(event){
    if(event.target.value === ''){
      event.target.value = 0.0;
    }
    this.handleChangeDiscount(event);
  }
  handleChangeDiscount(event) {
    //Check discount
    let discountChecker = event.target.value;
    if (discountChecker < 0) {
      discountChecker = 0.0;
    } else if (discountChecker > 100) {
      discountChecker = 100.0;
    }
    //Set discount
    let trackedLineTmp = JSON.parse(JSON.stringify(this.line));
    trackedLineTmp.discountpercent = parseFloat(discountChecker);
    let discount =
      1 -
      (trackedLineTmp.discountpercent !== 0
        ? trackedLineTmp.discountpercent / 100.0
        : 0.0);
    trackedLineTmp.NETPRICE = trackedLineTmp.GROSSPRICE * discount;
    trackedLineTmp.price = trackedLineTmp.NETPRICE * trackedLineTmp.QUANTITY;
    this.line = trackedLineTmp;
    this.sendLineModification(true);
  }


  handleChangeNetPriceKeyPress(event){
    //Check dot in number
    if(this.previousIsDotNetPrice){
      event.target.value = this.previousNetprice + '.' + mapCharcodeToNumber.get(event.charCode);
      this.previousIsDotNetPrice = false;
      this.previousNetprice = 0;
      this.handleChangeNetPrice(event);
    }
    else{
      if(event.charCode === 46){
        this.previousIsDotNetPrice = true;
        this.previousNetprice = event.target.value;
      }
      else{
        this.handleChangeNetPrice(event);
      }
    }
  }
  handleChangeNetPriceOnFocusOut(event){
    if(event.target.value === ''){
      event.target.value = 0.0;
    }
    this.handleChangeNetPrice(event);
  }
  handleChangeGrossPrice(event){
    //Check netprice
    let grossprice = event.target.value;
    if (grossprice < 0) {
      grossprice = 0;
    }
    //Set grossprice
    let trackedLineTmp = JSON.parse(JSON.stringify(this.line));
    trackedLineTmp.GROSSPRICE = grossprice;
    if (!trackedLineTmp.isProduct) {
      trackedLineTmp.NETPRICE = trackedLineTmp.GROSSPRICE;
      trackedLineTmp.price = trackedLineTmp.GROSSPRICE * trackedLineTmp.QUANTITY;
      this.line = trackedLineTmp;
      console.log('handleChangeGrossPrice trackedLineTmp', trackedLineTmp);
      this.sendLineModification(false);
    }
  }
  handleChangeNetPrice(event){
    //Check netprice
    let netprice = event.target.value;
    if (netprice < 0) {
      netprice = 0;
    }
    //Set grossprice
    let trackedLineTmp = JSON.parse(JSON.stringify(this.line));
    trackedLineTmp.NETPRICE = netprice;
    if (trackedLineTmp.isProduct && trackedLineTmp.NETPRICE !== trackedLineTmp.GROSSPRICE) {
      trackedLineTmp.discountpercent = 100 - (100.0 * trackedLineTmp.NETPRICE / trackedLineTmp.GROSSPRICE);
      // trackedLineTmp.discountpercent = (1 + trackedLineTmp.NETPRICE / trackedLineTmp.GROSSPRICE);
    } else if(trackedLineTmp.isProduct && trackedLineTmp.NETPRICE === trackedLineTmp.GROSSPRICE) {
      trackedLineTmp.discountpercent = 0.0;
    }
    trackedLineTmp.price = trackedLineTmp.NETPRICE * trackedLineTmp.QUANTITY;
    this.line = trackedLineTmp;
    this.sendLineModification(false);
  }

  handleChangeQuantity(event) {
    console.log('handleChangeQuantity event.detail', event.detail);
    //Check quantity
    let quantity = event.target.value;
    if (quantity < 0) {
      quantity = 0;
    }
    //Set quantity
    let trackedLineTmp = JSON.parse(JSON.stringify(this.line));
    trackedLineTmp.QUANTITY = parseInt(event.target.value, 10);
    if (trackedLineTmp.isProduct) {
      trackedLineTmp.GROSSPRICE = "";
      trackedLineTmp.price = "";
      trackedLineTmp.NETPRICE = "";
      trackedLineTmp.AVAILABLEDATE = "";
    } else {
      if (
        trackedLineTmp.GROSSPRICE != null &&
        trackedLineTmp.GROSSPRICE != 0 &&
        trackedLineTmp.QUANTITY != null &&
        trackedLineTmp.QUANTITY != 0
      ) {
        trackedLineTmp.price = trackedLineTmp.GROSSPRICE * trackedLineTmp.QUANTITY;
      }
    }
    this.line = trackedLineTmp;
    console.log('handleChangeQuantity trackedLineTmp', trackedLineTmp);
    this.waitingRefresh = false;
    this.requesteddeliverydate = null;
    this.sendLineModification(false);
  }

  selector(event) {
    let trackedLineTmp = JSON.parse(JSON.stringify(this.line));
    for (let key in trackedLineTmp.CDPAR) {
      if (trackedLineTmp.CDPAR[key].value === event.target.value) {
        trackedLineTmp.CDSPS = trackedLineTmp.CDPAR[key].value;
        trackedLineTmp.DESCRIPTION = trackedLineTmp.CDPAR[key].label;
      }
    }
    this.line = trackedLineTmp;
    this.sendLineModification(false);
  }

  /* EVENT TO PARENT */
  sendLineModification(discountIsChanged) {
    // Send event to parent
    const selectedEvent = new CustomEvent("linemodification", {
      detail: {
        line: this.line,
        discountIsChanged: discountIsChanged
      }
    });
    this.dispatchEvent(selectedEvent);
  }

  sendAvailabilityToParent() {
    // Send event to parent
    const selectedEvent = new CustomEvent("availability", {
      detail: this.isAvaiblable
    });
    this.dispatchEvent(selectedEvent);
  }

  sendRefreshLine() {
    this.requesteddeliverydate = this.memoryequesteddeliverydate;
    // Send event to parent
    const selectedEvent = new CustomEvent("refreshline", {
      detail: this.line
    });
    this.dispatchEvent(selectedEvent);
  }

  sendLineDeletion() {
    // Send event to parent
    const selectedEvent = new CustomEvent("linedeletion", {
      detail: this.line
    });
    this.dispatchEvent(selectedEvent);
  }
}