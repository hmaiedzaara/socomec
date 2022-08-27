import { LightningElement, track, api } from "lwc";
import getAccounts from "@salesforce/apex/SMC_AC_DORA_Management.getAccounts";
import getOrderHeaders from "@salesforce/apex/SMC_AC_DORA_Management.getOrderHeaders";
import getTemporaryAccountInCache from "@salesforce/apex/SMC_AC_DORA_Management.getTemporaryAccountInCache";
import saveTemporaryAccountInCache from "@salesforce/apex/SMC_AC_DORA_Management.saveTemporaryAccountInCache";
import SELECT_ACCOUNT from "@salesforce/label/c.SMC_Select_Account";
import CHOOSE_HERE from "@salesforce/label/c.SMC_Choose_Here";
import FILTER_ORDERS from "@salesforce/label/c.SMC_Filter_Orders";
import ORDER_CODE from "@salesforce/label/c.SMC_Order_Code";
import ORDER_DATE from "@salesforce/label/c.SMC_Order_Date";
import STATUS from "@salesforce/label/c.SMC_Status_Label";
import AMOUNT from "@salesforce/label/c.SMC_Amount_Label";
import ACTIONS from "@salesforce/label/c.SMC_Actions";
import SMC_TECH_AFS_BA_Identifier from "@salesforce/label/c.SMC_TECH_AFS_BA_Identifier";

export default class Smc_lwc_OR_my_orders extends LightningElement {
  //Tech variables
  @track idxBackground;
  @track haveOnlyOneAccount = false;
  //Variables
  @track accounts = [];
  @track accountKeys = [];
  @track accountsMap = new Map();
  @track cacheInfos;
  @track specificAccount;
  @track accountFromCache = false;
  @track tmpSpecificAccount;
  @track orderListFilled = false;
  @track cacheAllOrders = [];
  @track allOrders = [];
  @track allOrdersWithFilters = [];


  //Variable pagination
  pageSize = 10;
  @track offset = 0;
  @track reachMin = true;
  @track reachMax = false;

  //Label
  selectAccountLabel = { SELECT_ACCOUNT };
  chooseHereLabel = { CHOOSE_HERE };
  filterOrdersLabel = { FILTER_ORDERS };
  orderCodeLabel = { ORDER_CODE };
  orderDateLabel = { ORDER_DATE };
  statusLabel = { STATUS };
  amountLabel = { AMOUNT };
  actionsLabel = { ACTIONS };

  connectedCallback() {
    //Setup page
    this.idxBackground = 0;
    //Callout : get accounts
    this.getAllAccounts();
    //Cache : get Account
    this.getCacheInformations();
  }

  get checkBackground() {
    ++this.idxBackground;
    if (!Number.isInteger(this.idxBackground / 2)) {
      return "slds-border_bottom line-hover ligth-background";
    } else {
      return "slds-border_bottom line-hover alternative-ligth-background";
    }
  }

  setColumns() {
    let elmt = JSON.parse(JSON.stringify(this.allOrdersWithFilters));
    this.allOrders = [];
    let idx = this.offset === 0 ? 0 : this.pageSize * this.offset;
    let maxIdx = idx + this.pageSize - 1;
    for (idx; idx <= maxIdx; ++idx) {
      if (elmt[idx] === null || elmt[idx] === undefined) {
        break;
      }
      this.allOrders.push({
        CDORD: elmt[idx].CDORD,
        ORDERDATE: elmt[idx].ORDERDATE,
        STATUS: elmt[idx].STATUS,
        AMOUNT: elmt[idx].AMOUNT,
        CCY: elmt[idx].CCY
      });
    }
    this.orderListFilled = true;
    //Set pagination
    if (elmt.length <= this.pageSize) {
      this.offset = 0;
      this.reachMin = true;
      this.reachMax = true;
    } else if (this.offset === 0) {
      this.reachMin = true;
      this.reachMax = false;
    } else {
      let tmpOffset = this.allOrdersWithFilters.length / this.pageSize;
      if (!Number.isInteger(tmpOffset)) {
        tmpOffset = Math.trunc(tmpOffset);
      }
      if (this.offset === tmpOffset) {
        this.reachMax = true;
        this.reachMin = false;
      }
    }
  }

    /* MANAGE CACHE INFORMATIONS */
    getCacheInformations(){
      getTemporaryAccountInCache({})
      .then(result => {
        if(result !== null && result !== undefined && result !== ''){
          this.setInformationsFromCache(result);
        }
      })
      .catch(error => {
        this.isLoad = true;
        this.dispatchEvent(
          new ShowToastEvent({
            title: "Cache error",
            message: JSON.stringify(error),
            variant: "error"
          })
        );
      });
    }
    setInformationsFromCache(cacheInformations){
      let infos = JSON.parse(cacheInformations);
      this.specificAccount = infos.specificAccount;
      let acc = JSON.parse(JSON.stringify(this.accounts));
      if(this.specificAccount !== null && this.specificAccount != undefined){
        this.accountIsSelected = true;
        this.accounts = [];
        for (let key in acc) {
          if (infos !== true && acc[key].CDCLI === this.specificAccount.CDCLI) {
            this.specificAccount = acc[key];
          }
          else{
            this.accounts.push(acc[key]);
          }
        }
      }
      this.accountFromCache = true;
      this.getAllOrders();

    }
    saveInformationsInCache(){
      let infosToCache = {
        specificAccount: this.specificAccount, 
      }
      saveTemporaryAccountInCache({serializedAccount: JSON.stringify(infosToCache)})
      .catch(error => {
        this.dispatchEvent(
          new ShowToastEvent({
            title: "saveTemporaryAccountInCache Error",
            message: JSON.stringify(error),
            variant: "error"
          })
        );
      });
    }


  handleAccountSelector(event) {
    if(this.accountFromCache){
      this.accounts.unshift(this.specificAccount);
      this.accountFromCache = false;
    }
    this.specificAccount = this.accountsMap.get(event.target.value);
    this.saveInformationsInCache();
    this.getAllOrders();
  }

  handleFilterOrder(event) {
    this.allOrders = [];
    if (
      event.target.value === null ||
      event.target.value === undefined ||
      event.target.value === ""
    ) {
      this.allOrdersWithFilters = JSON.parse(
        JSON.stringify(this.cacheAllOrders)
      );
    }
    let elmt = JSON.parse(JSON.stringify(this.cacheAllOrders));
    for (let key in elmt) {
      if (elmt[key].CDORD.includes(event.target.value)) {
        this.allOrders.push(elmt[key]);
      }
    }
    if (this.allOrders.length <= this.pageSize) {
      this.reachMin = true;
      this.reachMax = true;
    } else {
      this.allOrdersWithFilters = this.allOrders;
      this.setColumns();
    }
  }

  //PAGINATION
  handleNextPage() {
    let tmpOffset = this.allOrdersWithFilters.length / this.pageSize;
    if (!Number.isInteger(tmpOffset)) {
      tmpOffset = Math.trunc(tmpOffset);
    }

    this.reachMin = false;
    if (this.offset < tmpOffset) {
      ++this.offset;
      if (this.offset === tmpOffset) {
        this.reachMax = true;
      }
      this.setColumns();
    } else {
      this.reachMax = true;
    }
  }

  handleLastPage() {
    let tmpOffset = this.allOrdersWithFilters.length / this.pageSize;
    if (!Number.isInteger(tmpOffset)) {
      tmpOffset = Math.trunc(tmpOffset);
    }
    this.offset = tmpOffset;
    this.reachMax = true;
    this.reachMin = false;
    this.setColumns();
  }

  handlePreviousPage() {
    this.reachMax = false;
    if (this.offset > 0) {
      --this.offset;
      if (this.offset === 0) {
        this.reachMin = true;
      }
      this.setColumns();
    } else {
      this.reachMin = true;
    }
  }

  handleFirstPage() {
    this.offset = 0;
    this.reachMin = true;
    this.reachMax = false;
    this.setColumns();
  }

  //Call server
  getAllAccounts() {
    getAccounts()
      .then(result => {
        this.accounts = JSON.parse(result).getAccounts.data;
        for (let key in this.accounts) {
          this.accountKeys.push(this.accounts[key].CDCLI);
          this.accountsMap.set(this.accounts[key].CDCLI, this.accounts[key]);
        }
        if (this.accounts === 1) {
          this.specificAccount = this.accounts;
          this.haveOnlyOneAccount = true;
          this.getAllOrders();
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
  getAllOrders() {
    getOrderHeaders({
      cdcli: JSON.parse(JSON.stringify(this.specificAccount)).CDCLI
    })
      .then(result => {
        this.cacheAllOrders = [];
        let elmt = JSON.parse(result).getOrder.data;
        for (let i = elmt.length - 1; i >= 0; --i) {
          let amount = parseFloat(elmt[i].AMOUNT);
          elmt[i].AMOUNT = amount;
          this.cacheAllOrders.push(elmt[i]);
        }
        this.allOrdersWithFilters = [];
        this.allOrdersWithFilters = this.cacheAllOrders;
        this.handleFirstPage();
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
}